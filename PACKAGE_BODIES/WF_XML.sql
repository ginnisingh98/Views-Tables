--------------------------------------------------------
--  DDL for Package Body WF_XML
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WF_XML" as
/* $Header: wfmxmlb.pls 120.31.12010000.38 2021/03/04 08:13:25 ksanka ship $ */
   --
   -- Exceptions
   --
   dequeue_timeout exception;
   pragma EXCEPTION_INIT(dequeue_timeout, -25228);

   dequeue_disabled exception;
   pragma EXCEPTION_INIT(dequeue_disabled, -25226);

   dequeue_outofseq exception;
   pragma EXCEPTION_INIT(dequeue_outofseq, -25237);

   no_queue exception;
   pragma EXCEPTION_INIT(no_queue, -24010);

   -- g_fist_message
   -- Flag to control the dequeuing of the SMTP queue
   g_first_message boolean := TRUE;

   g_LOBTable wf_temp_lob.wf_temp_lob_table_type;

   TYPE wf_resourceList_rec_t IS RECORD
   (
      contentId           VARCHAR2(1000),
      fileName           VARCHAR2(1000),
      contentType               VARCHAR2(1000),
      value               VARCHAR2(4000)

   );

   TYPE resourceList_t IS TABLE OF
        wf_resourceList_rec_t INDEX BY BINARY_INTEGER;

   cursor g_urls(p_nid varchar2) is
      select WMA.TYPE, WMA.DISPLAY_NAME, WNA.TEXT_VALUE, WNA.NAME
      from WF_NOTIFICATION_ATTRIBUTES WNA, WF_NOTIFICATIONS WN,
           WF_MESSAGE_ATTRIBUTES_VL WMA
      where WNA.NOTIFICATION_ID = p_nid
      and WN.NOTIFICATION_ID = WNA.NOTIFICATION_ID
      and WN.MESSAGE_TYPE = WMA.MESSAGE_TYPE
      and WN.MESSAGE_NAME = WMA.MESSAGE_NAME
      and WMA.TYPE = 'URL'
      and WMA.ATTACH = 'N'
      and WMA.NAME = WNA.NAME;

   -- Set these constants as session level varaibles to minumise the
   -- calls to wf_core.
   g_newLine varchar2(1) := wf_core.newLine;
   g_carriageReturn varchar2(1) := wf_core.CR;
   g_install varchar2(100) := wf_core.Translate('WF_INSTALL');
   g_htmlmessage varchar2(200);
   g_urlNotification varchar2(200);
   g_urlListAttachment varchar2(200);
   -- These are only used in legacy procedures.
   g_webAgent varchar2(200) := wf_core.translate('WF_WEB_AGENT');
   g_wfSchema varchar2(200) := wf_core.translate('WF_SCHEMA');
   g_fndapi_misschr varchar2(1) := FND_API.G_MISS_CHAR;

   g_ntfDocText varchar2(30) := wf_notification.doc_text;
   g_ntfDocHtml varchar2(30) := wf_notification.doc_html;

   -- <<sstomar> : nls changes
   g_base_language             v$nls_parameters.value%TYPE  ;
   g_base_territory            v$nls_parameters.value%TYPE  ;
   g_base_codeset              v$nls_parameters.value%TYPE  ;

   -- << sstomar>> : Initialization can be done by using
   --       variables  from wf_core.nls_date_format,
   --       wf_core.nls_date_language etc. but since
   --       when calling WF_NOTIFICATION_UTIL.set/getNLSContext to retrieve
   --       defaul NLS Language etc. we can define vars. here also.
   g_base_nlsDateFormat        v$nls_parameters.value%TYPE  := wf_core.nls_date_format;
   g_base_nlsDateLanguage      v$nls_parameters.value%TYPE  := wf_core.nls_date_language;
   g_base_nlsCalendar          v$nls_parameters.value%TYPE  := wf_core.nls_calendar;
   g_base_nlsSort              v$nls_parameters.value%TYPE  := wf_core.nls_sort ;
   g_base_nlsNumericCharacters v$nls_parameters.value%TYPE  := wf_core.nls_numeric_characters;

   g_WebMail_PostScript_Msg    varchar2(1024);

   -- Bug 10202313: global variables to store status, mail_status of WF_NOTIFICATIONS table
   -- which will be passed as parameters to WF_MAIL.GetLOBMessage4() API
   g_status wf_notifications.status%TYPE;
   g_mstatus wf_notifications.mail_status%TYPE;


   -- Return TRUE if the URL points to a image file.
   -- The URL is pretested to ensure that it does NOT contain
   -- any URL parameters.
   function isImageReference(url in varchar2, renderType in varchar2)
      return boolean
   is
      extPos pls_integer;
      extStr varchar2(1000);
      params pls_integer;

      l_renderType varchar2(10);

   begin
      if (wf_log_pkg.level_procedure >= fnd_log.g_current_runtime_level) then
         wf_log_pkg.string(WF_LOG_PKG.level_statement,
                          'wf.plsql.WF_XML.isImageReference',
                          'BEGIN {'||url||'} {'||renderType||'}');
      end if;
      l_renderType := renderType;

      params := instr(url, '?');
      if (params = 0) then
         extPos := instrb(url, '.', -1, 1) + 1;
         extStr := lower(substrb(url, extPos));

         if (( l_renderType is null or l_renderType = 'IMG:') and
             extStr in ('gif','jpg','png','tif','bmp','jpeg')) then
            return true;
         else
            l_renderType := 'LNK:';
         end if;

         if l_renderType = 'LNK:' then
            return false;
         end if;
      else
         return false;
      end if;
   end isImageReference;

   -- GetRecipients
   -- IN
   --    Role
   -- OUT
   --    List of recipients with their details contained in a PL/SQL Table.
   -- NOTE
   --    A role will only be resolved to one level. If a role contains has a
   --    role associated to it, then that's as far as we go.
   procedure GetRecipients(p_role in varchar2,
                           p_recipient_list in out NOCOPY WF_DIRECTORY.wf_local_roles_tbl_type)
   is

     l_display_name wf_roles.display_name%TYPE;
     l_description wf_roles.description%TYPE;
     l_email_address wf_roles.email_address%TYPE;
     l_notification_preference wf_roles.notification_preference%TYPE;
     l_language wf_roles.language%TYPE;
     l_territory wf_roles.territory%TYPE;

     cursor urc1(role varchar2, colon binary_integer) is
     select name
     from wf_users
     where (name, orig_system, orig_system_id) in
        (select user_name, user_orig_system, user_orig_system_id
           from wf_user_roles
              where role_name = urc1.role
                and role_orig_system = substr(urc1.role, 1, urc1.colon-1)
                and role_orig_system_id = substr(urc1.role, urc1.colon+1)
                and user_name <> role_name
                and user_orig_system <> role_orig_system
                and user_orig_system_id <> role_orig_system_id)
        and notification_preference not in ('SUMMARY','QUERY')
         order by notification_preference, language;


     cursor urc2(role varchar2) is
     select name
     from wf_users
     where (name, orig_system, orig_system_id) in
        (select user_name, user_orig_system, user_orig_system_id
           from wf_user_roles
              where role_name = urc2.role
              and user_name <> role_name)
        and notification_preference not in ('SUMMARY','QUERY')
       order by notification_preference, language;

     i binary_integer := 0;
     colon binary_integer;


   begin

      -- Get role details.
      wf_directory.GetRoleInfo(p_role, l_display_name, l_email_address,
                               l_notification_preference, l_language,
                               l_territory);

      -- If the email address is NULL, then look for the members attached to
      -- the role. Only attach those roles that 'want' a notification.
      if l_email_address is not NULL
         and l_notification_preference not in ('SUMMARY','QUERY') then
         i := p_recipient_list.COUNT + 1;
         p_recipient_list(i).name            := p_role;
         p_recipient_list(i).display_name    := l_display_name;
         p_recipient_list(i).description     := l_description;
         p_recipient_list(i).notification_preference :=
                        l_notification_preference;
         p_recipient_list(i).language        := l_language;
         p_recipient_list(i).territory       := l_territory;
         p_recipient_list(i).email_address   := l_email_address;
      else
         -- The the ROLE has a blank email address, then we
         -- are interested only in resolving it one level.
         -- If this is a user with a blank email address, then no one
         -- will get a notification.
         colon := instr(p_role, ':');
         if colon > 0 then
            for urrec in urc1(p_role, colon) loop
               wf_directory.GetRoleInfo(urrec.name, l_display_name,
                                        l_email_address,
                                        l_notification_preference, l_language,
                                        l_territory);
               i := p_recipient_list.COUNT + 1;
               p_recipient_list(i).name            := p_role;
               p_recipient_list(i).display_name    := l_display_name;
               p_recipient_list(i).description     := l_description;
               p_recipient_list(i).notification_preference :=
                        l_notification_preference;
               p_recipient_list(i).language        := l_language;
               p_recipient_list(i).territory       := l_territory;
               p_recipient_list(i).email_address   := l_email_address;
            end loop;
         else
            for urrec in urc2(p_role) loop
               wf_directory.GetRoleInfo(urrec.name, l_display_name,
                                        l_email_address,
                                        l_notification_preference, l_language,
                                        l_territory);
               i := p_recipient_list.COUNT + 1;
               p_recipient_list(i).name            := p_role;
               p_recipient_list(i).display_name    := l_display_name;
               p_recipient_list(i).description     := l_description;
               p_recipient_list(i).notification_preference :=
                        l_notification_preference;
               p_recipient_list(i).language        := l_language;
               p_recipient_list(i).territory       := l_territory;
               p_recipient_list(i).email_address   := l_email_address;
            end loop;
         end if;
      end if;
   exception
      when others then
         wf_core.context('Wf_XML','GetRecipients',p_role);
         raise;
   end GetRecipients;

   -- EncodeEntityReference
   -- IN
   --    Data to be encoded
   -- RETURN
   --    Encoded data.
   -- NOTE
   --    This is needed to encode the HTML data before placing it into
   --    the XML structure. If it is placed in neat, then the XML parser
   --    will not be able to cope.
   function EncodeEntityReference(p_str in varchar2) return varchar2
   is
      l_str varchar2(32000);
   begin
      l_str := p_str;
      l_str := replace(l_str,'&','&'||'amp;');
      l_str := replace(l_str,'<','&'||'lt;');
      l_str := replace(l_str,'>','&'||'gt;');
      l_str := replace(l_str,'"','&'||'quot;');
      l_str := replace(l_str,'''','&'||'apos;');
      return l_str;
   end EncodeEntityReference;


   -- DecodeEntityReference (PRIVATE)
   -- IN
   --    Data to be decoded
   -- RETURN
   --    Decoded data.
   -- NOTE
   --    This is needed to decode the HTML data after extracting it from
   --    the XML structure.
   function DecodeEntityReference(some_text in varchar2)
   return varchar2 is
     l_amp     varchar2(1) := '&';
     buf       varchar2(32000);
   begin
     buf := some_text;
     buf := replace(buf, l_amp||'#38;', l_amp);
     buf := replace(buf, l_amp||'lt;', '<');
     buf := replace(buf, l_amp||'#60;', '<');
     buf := replace(buf, l_amp||'gt;', '>');
     buf := replace(buf, l_amp||'#92;', '\');
     buf := replace(buf, l_amp||'#39;', '''');
     buf := replace(buf, l_amp||'apos;', '''');
     buf := replace(buf, l_amp||'quot;', '"');
     buf := replace(buf, l_amp||'amp;', l_amp);
     return buf;
   exception
     when others then
       wf_core.context('Wf_Notification', 'DecodeEntityReference');
       raise;
   end DecodeEntityReference;

   -- EnqueueLOBMessage
   -- IN
   --    Queue Name
   --    Priority of the message
   --    Correlation for the message - the NID of the notification
   --       for this implementation.
   --    Message - XML encoded.
   procedure EnqueueLOBMessage(p_queue in varchar2,
                            p_priority number,
                            p_correlation in varchar2,
                            p_message in CLOB) is

      l_enqueue_options dbms_aq.enqueue_options_t;
      l_message_properties dbms_aq.message_properties_t;
      l_correlation varchar2(255) := NULL;
      l_msgid raw(16);

      l_queueu VARCHAR2(200);
      l_queueName VARCHAR2(30);
      l_queueTable VARCHAR2(200);
      l_schemaName VARCHAR2(320);
      l_msgLength NUMBER;
      l_sqlbuf VARCHAR2(2000);

      l_amount binary_integer;
      l_pos pls_integer;

      l_dequeue_options dbms_aq.dequeue_options_t;
   begin


     /** wf_message_payload_t is obsolete in 2.6.4 onwards **/
     null;

   exception
    when others then
       wf_core.context('WF_XML','EnqueueLOBMessage',p_queue,
                       to_char(p_priority),
                       p_correlation);
       raise;
   end EnqueueLOBMessage;


   -- EnqueueMessage
   -- IN
   --    Queue Name
   --    Priority of the message
   --    Correlation for the message - the NID of the notification
   --       for this implementation.
   --    Message - XML encoded.
   procedure EnqueueMessage(p_queue in varchar2,
                            p_priority number,
                            p_correlation in varchar2,
                            p_message in VARCHAR2) is

      l_enqueue_options dbms_aq.enqueue_options_t;
      l_message_properties dbms_aq.message_properties_t;
      l_correlation varchar2(255) := NULL;
      l_msgid raw(16);

      -- l_msgLob CLOB;
      l_msgLobIdx pls_integer;
      l_queueu VARCHAR2(200);
      l_queueName VARCHAR2(30);
      l_queueTable VARCHAR2(200);
      l_schemaName VARCHAR2(320);
      l_msgLength NUMBER;
      l_sqlbuf VARCHAR2(2000);

      l_amount binary_integer;
      l_pos pls_integer;

      l_dequeue_options dbms_aq.dequeue_options_t;
   begin

     /** wf_message_payload_t is obsolete in 2.6.4 onwards **/
     null;

   exception
    when others then
        -- just in case, check and free it any way.
       wf_temp_lob.ReleaseLob(g_LOBTable, l_msgLobIdx);
       wf_core.context('WF_XML','EnqueueMessage',p_queue, to_char(p_priority),
                       p_correlation);
       raise;
   end EnqueueMessage;


   -- NewLOBTag - Create a new TAG node and insert it into the
   --          Document Tree
   -- IN
   --    document as a CLOB
   --    Position to take the new Tag Node
   --    New Tag to be created
   --    Data to be added between the start and end TAGs
   --    Attribute list to be included in the opening TAG
   -- OUT
   --    The document containing the new TAG.
   function NewLOBTag (p_doc in out NOCOPY CLOB,
                    p_pos in integer,
                    p_tag in varchar2,
                    p_data in varchar2,
                    p_attribute_list IN OUT NOCOPY wf_xml_attr_table_type)
                    return integer
   is

      -- l_temp CLOB;
      l_tempStr varchar2(32000);
      l_tempIdx pls_integer;
      l_node varchar2(32000);
      l_start varchar2(32000);
      l_end varchar2(250);
      l_pos integer;
      l_nodesize number;

      l_size number;
      l_amount number;

   begin

      -- Create an instance of the node
      -- A Node is deemed to be <TAG>Data</TAG>
      -- dbms_lob.createTemporary(l_temp, TRUE, dbms_lob.CALL);
      l_tempIdx := -1;

      l_start := '<' || upper(p_tag);

      -- If there are any attributes to add to the tag, then
      -- add them now, otherwise, close off the TAG.
      if p_attribute_list.COUNT = 0 then
         l_start := l_start || '>';
      else
         for i in 1..p_attribute_list.COUNT loop
            l_start := l_start || ' ' ||
                       p_attribute_list(i).attribute || '="' ||
                       p_attribute_list(i).value || '"';
         end loop;
         l_start := l_start || '>';
      end if;

      -- Create the end TAG.
      l_end := '</' || upper(p_tag) || '>'||g_newLine;


      l_size := dbms_lob.getlength(p_doc);

      -- Create the full node to be inserted.
      l_node := l_start || p_data || l_end;
      l_nodesize := length(l_node);

      l_amount := 0;
      if l_size > 1 and l_size <> p_pos then
         -- Copy the tail end of the LOB to a holder.
         l_amount := l_size - p_pos;
         if l_amount < 32000 then
            dbms_lob.read(lob_loc => p_doc,
                          amount => l_amount,
                          offset => p_pos + 1,
                          buffer => l_tempStr);
         else
            l_tempIdx := wf_temp_lob.GetLob(g_LOBTable);
            dbms_lob.copy(dest_lob => g_LOBTable(l_tempIdx).temp_lob,
                          src_lob => p_doc,
                          amount => l_amount,
                          dest_offset => 1,
                          src_offset => p_pos +1);
         end if;
      end if;

      -- Now insert the new node into the p_pos location
      dbms_lob.Write(p_doc, l_nodesize, p_pos + 1 , l_node);

      -- Append the saved portion of the LOB
      -- If l_tempIdx is still -1, then no LOB was used or initialised
      -- but for the lob, makesure that there is something in it to be
      -- used (l_amount > 0).
      if l_tempIdx = -1 and l_amount > 0 then
         dbms_lob.write(lob_loc => p_doc,
                        amount => l_amount,
                        offset => p_pos + l_nodesize + 1,
                        buffer => l_tempStr);
      elsif l_amount > 0 then
         dbms_lob.copy(dest_lob => p_doc,
                       src_lob => g_LOBTable(l_tempIdx).temp_lob,
                       amount => l_amount ,
                       dest_offset => p_pos + l_nodesize + 1);
         wf_temp_lob.ReleaseLob(g_LOBTable, l_tempIdx);
      end if;

      l_pos := (p_pos + l_nodesize) - length(l_end);
      -- Free up the use of the temporary LOB
      -- dbms_lob.FreeTemporary(l_temp);

      if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
         wf_log_pkg.string(WF_LOG_PKG.level_statement,
                          'wf.plsql.WF_XML.newLOBTag',
                          'TAG: '||l_start||' POS: '||to_char(l_pos));
      end if;

      return l_pos;

   exception
      when others then
         wf_temp_lob.ReleaseLob(g_LOBTable, l_tempIdx);
         wf_core.context('WF_XML','NewLOBTag', p_tag);
         raise;
   end NewLOBTag;

   -- NewLOBTag - Create a new TAG node and insert it into the
   --          Document Tree
   -- IN
   --    document as a CLOB
   --    Position to take the new Tag Node
   --    New Tag to be created
   --    Data to be added between the start and end TAGs
   --    Attribute list to be included in the opening TAG
   -- OUT
   --    The document containing the new TAG.
   function NewLOBTag (p_doc in out NOCOPY CLOB,
                    p_pos in integer,
                    p_tag in varchar2,
                    p_data in CLOB,
                    p_attribute_list IN OUT NOCOPY wf_xml_attr_table_type)
                    return integer
   is

      l_tempIdx pls_integer;
      l_nodeIdx pls_integer;
      l_tempStr varchar2(32000);
      l_start varchar2(250);
      l_end varchar2(250);
      l_pos integer;
      l_nodesize number;

      l_size number;
      l_dataSize number;
      l_amount number;

   begin

      -- Create an instance of the node
      -- A Node is deemed to be <TAG>Data</TAG>
      l_tempIdx := -1;
      l_nodeIdx := wf_temp_lob.getLob(g_LOBTable);

      l_start := '<' || upper(p_tag);

      -- If there are any attributes to add to the tag, then
      -- add them now, otherwise, close off the TAG.
      if p_attribute_list.COUNT = 0 then
         l_start := l_start || '>';
      else
         for i in 1..p_attribute_list.COUNT loop
            l_start := l_start || ' ' ||
                       p_attribute_list(i).attribute || '="' ||
                       p_attribute_list(i).value || '"';
         end loop;
         l_start := l_start || '>';
      end if;

      -- Create the end TAG.
      l_end := '</' || upper(p_tag) || '>'||g_newLine;

      l_size := dbms_lob.getlength(p_doc);
      l_dataSize := dbms_lob.getlength(p_data);

      -- Create the full node to be inserted.
      dbms_lob.writeAppend(g_LOBTable(l_nodeIdx).temp_lob, length(l_start),
                           l_start);
      l_nodesize := length(l_start); -- dbms_lob.getLength(g_LOBTable(l_nodeIdx).temp_lob);
      dbms_lob.copy(dest_lob => g_LOBTable(l_nodeIdx).temp_lob,
              src_lob => p_data,
              amount => l_dataSize,
              dest_offset => l_nodesize+1,
              src_offset => 1);
      dbms_lob.writeAppend(g_LOBTable(l_nodeIdx).temp_lob, length(l_end),
                           l_end);
      l_nodesize := dbms_lob.getLength(g_LOBTable(l_nodeIdx).temp_lob);

      l_amount := 0;
      if l_size > 1 and l_size <> p_pos then
         l_amount := l_size - p_pos;
         -- Copy the tail end of the LOB to a holder.
         if l_amount < 32000 then
            dbms_lob.read(lob_loc => p_doc,
                          amount => l_amount,
                          offset => p_pos + 1,
                          buffer => l_tempStr);
         else
            l_tempIdx := wf_temp_lob.GetLob(g_LOBTable);
            dbms_lob.copy(dest_lob => g_LOBTable(l_tempIdx).temp_lob,
                          src_lob => p_doc,
                          amount => l_amount,
                          dest_offset => 1,
                          src_offset => p_pos +1);
         end if;
      end if;

      -- Now insert the new node into the p_pos location
      dbms_lob.copy(dest_lob => p_doc,
                    src_lob => g_LOBTable(l_nodeIdx).temp_lob,
                    amount => l_nodesize,
                    dest_offset => p_pos + 1);

      -- Append the saved portion of the LOB
      if l_tempIdx = -1 and l_amount > 0 then
         dbms_lob.write(lob_loc => p_doc,
                        amount => l_amount,
                        offset => p_pos + l_nodesize + 1,
                        buffer => l_tempStr);
      elsif l_tempIdx > 0 then
         if l_amount > 0 then
            dbms_lob.copy(dest_lob => p_doc,
                          src_lob => g_LOBTable(l_tempIdx).temp_lob,
                          amount => l_amount,
                          dest_offset => p_pos + l_nodesize + 1);
         end if;
         -- Free up the use of the temporary LOBs
         wf_temp_lob.releaseLOB(g_LOBTable, l_tempIdx);
      end if;


      l_pos := (p_pos + l_nodesize) - length(l_end);

      -- Free up the use of the temporary LOBs
      wf_temp_lob.releaseLOB(g_LOBTable, l_nodeIdx);

      if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
         wf_log_pkg.string(WF_LOG_PKG.level_statement,
                          'wf.plsql.WF_XML.newLOBTag',
                          'TAG: '||l_start||' POS: '||to_char(l_pos));
      end if;

      return l_pos;

   exception
      when others then
         wf_temp_lob.releaseLOB(g_LOBTable, l_tempIdx);
         wf_temp_lob.releaseLOB(g_LOBTable, l_nodeIdx);
         wf_core.context('WF_XML','NewLOBTag', p_tag);
         raise;
   end NewLOBTag;

   -- NewTag - Create a new TAG node and insert it into the
   --          Document Tree
   -- IN
   --    document as a CLOB
   --    Position to take the new Tag Node
   --    New Tag to be created
   --    Data to be added between the start and end TAGs
   --    Attribute list to be included in the opening TAG
   -- OUT
   --    The document containing the new TAG.
   function NewTag (p_doc in out NOCOPY VARCHAR2,
                    p_pos in integer ,
                    p_tag in varchar2,
                    p_data in varchar2,
                    p_attribute_list IN OUT NOCOPY wf_xml_attr_table_type)
      return integer
   is

      l_temp VARCHAR2(32000);
      l_node varchar2(32000);
      l_start varchar2(250);
      l_end varchar2(250);
      l_pos integer;
      l_nodesize number;

      l_size number;
      l_amount number;

   begin

      -- Create an instance of the node
      -- A Node is deemed to be <TAG>Data</TAG>

      l_start := '<' || upper(p_tag);

      -- If there are any attributes to add to the tag, then
      -- add them now, otherwise, close off the TAG.
      if p_attribute_list.COUNT = 0 then
         l_start := l_start || '>';
      else
         for i in 1..p_attribute_list.COUNT loop
            l_start := l_start || ' ' ||
                       p_attribute_list(i).attribute || '="' ||
                       p_attribute_list(i).value || '"';
         end loop;
         l_start := l_start || '>';
      end if;

      -- Create the end TAG.
      l_end := '</' || upper(p_tag) || '>'||g_newLine;


      l_size := length(p_doc);

      -- Create the full node to be inserted.
      l_node := l_start || p_data || l_end;
      l_nodesize := length(l_node);

      l_amount := 0;
      if l_size > 1 and l_size <> p_pos then
         -- Copy the tail end of the LOB to a holder.
         l_amount := l_size - p_pos;
         l_temp := substr(p_doc, p_pos +1, l_amount);
      end if;

      -- Now insert the new node into the p_pos location
      p_doc := substr(p_doc, 1, p_pos)||l_node;

      if Length(l_temp) > 1 then
         -- Append the saved portion of the LOB
         p_doc := p_doc||l_temp;
      end if;

      l_pos := (p_pos + l_nodesize) - length(l_end);

      if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
         wf_log_pkg.string(WF_LOG_PKG.level_statement,
                          'wf.plsql.WF_XML.newTag',
                          'TAG: '||l_start||' POS: '||to_char(l_pos));
      end if;
      return l_pos;

   exception
      when others then
         wf_core.context('WF_XML','NewTag', p_tag);
         raise;
   end NewTag;



   -- SkipLOBTag - To move return a pointer past the nominated TAG
   --           starting from a given position in the document.
   -- IN
   --    document
   --    Position to take the new Tag Node
   --    New Tag to be created
   --    Data to be added
   -- RETURN
   --   New position past the </TAG>.
   function SkipLOBTag (p_doc in out NOCOPY CLOB,
                     p_tag in varchar2,
                     p_offset in out NOCOPY integer,
                     p_occurance in out NOCOPY integer) return integer is

      l_pos integer;
      l_tag varchar2(250);

   begin

      l_tag := '</'||upper(p_tag)||'>';
      l_pos := dbms_lob.instr(p_doc, l_tag, p_offset, p_occurance);

      return l_pos + length(l_tag);

   exception
      when others then
         wf_core.context('WF_XML','SkipLOBTag', p_tag, to_char(p_offset),
                         to_char(p_occurance));
         raise;
   end SkipLOBTag;

   -- SkipTag - To move return a pointer past the nominated TAG
   --           starting from a given position in the document.
   -- IN
   --    document
   --    Position to take the new Tag Node
   --    New Tag to be created
   --    Data to be added
   -- RETURN
   --   New position past the </TAG>.
   function SkipTag (p_doc in out NOCOPY VARCHAR2,
                     p_tag in varchar2,
                     p_offset in out NOCOPY integer,
                     p_occurance in out NOCOPY integer) return integer is

      l_pos integer;
      l_tag varchar2(250);

   begin

      l_tag := '</'||upper(p_tag)||'>';
      l_pos := instr(p_doc, l_tag, p_offset, p_occurance);

      return l_pos + length(l_tag);

   exception
      when others then
         wf_core.context('WF_XML','SkipTag', p_tag, to_char(p_offset),
                         to_char(p_occurance));
         raise;
   end SkipTag;


   -- GetTagValue - Obtain the value for a given TAG from within the
   --               Document Tree
   -- IN
   --    document as a CLOB
   --    TAG to find the value of
   --    The position to start looking for the TAG from
   -- OUT
   --    Value of the TAG. ie the value between the start and end TAGs
   --    The position in the CLOB after the find
   --    The list of attributes associated with the TAG (Not implemented as yet)
   procedure GetTagValue(p_doc in out NOCOPY CLOB,
                         p_tag in varchar2,
                         p_value out NOCOPY varchar2,
                         p_pos in out NOCOPY integer,
                         p_attrlist in out NOCOPY wf_xml_attr_table_type)
   as

      l_value varchar2(32000);
      l_length integer;
      l_startTag varchar2(255);
      l_endTag varchar2(255);
      l_startPos integer;
      l_endPos integer;
      l_pos integer;
      l_occurance integer := 1;

   begin

      -- The idea is to look for the value of a tag from
      -- a given point (p_pos)
      l_pos := p_pos;
      -- Set the opening TAG. Don't use the '>' as there may be
      -- attributes set on the TAG.
      l_startTag := '<'||upper(p_tag);
      l_endTag := '</'||upper(p_tag)||'>';

      l_startPos := dbms_lob.instr(p_doc, l_startTag, l_pos, l_occurance);
      l_startPos := dbms_lob.instr(p_doc, '>', l_startPos, l_occurance) + 1;


      l_endPos := dbms_lob.instr(p_doc, l_endTag, l_startpos, l_occurance) - 1;
      l_length := l_endPos - l_startPos + 1;

      dbms_lob.read(p_doc, l_length, l_startPos, l_value);

      -- Reposition the position pointer to after the end
      -- of the current TAG set.
      p_pos := l_endPos + length(l_endTag) + 1;
      p_value := l_value;
   exception
      when others then
         wf_core.context('WF_XML','GetTagValue',p_tag, to_char(p_pos));
         raise;
   end GetTagValue;


   -- AddElementAttribute - Add an Element Attribute Value pair to the attribute
   --                       list.
   -- IN
   --    Name of the attribute
   --    Value for the attribute
   --    The attribute list to add the name/value pair to.
   procedure AddElementAttribute(p_attribute_name IN VARCHAR2,
                                 p_attribute_value IN VARCHAR2,
                                 p_attribute_list IN OUT NOCOPY wf_xml_attr_table_type)
   is
      l_index integer;
   begin
      l_index := p_attribute_list.COUNT + 1;
      p_attribute_list(l_index).attribute := p_attribute_name;
      p_attribute_list(l_index).value := p_attribute_value;
   exception
      when others then
         wf_core.context('WF_XML','AddElementAttribute',p_attribute_name,
                         p_attribute_value);
         raise;
   end;


   -- GetAttachment - Create an attachment tag for each of the URLs and
   --                 DOCUMENT attributes.
   -- IN
   --    Notification ID
   --    Document handle
   --    MIME Agent for the attachment
   --    Position in the document where to place the attachment.
   -- OUT
   --    New location of the position
   function GetAttachment(p_nid in number,
                          p_doc in out NOCOPY CLOB,
                          p_agent in varchar2,
                          p_disposition in varchar2,
                          p_doc_type in varchar2,
                          p_pos in out NOCOPY integer) return integer
   is

      l_pos integer;
      l_occurance integer := 1;
      l_tmpcontent varchar2(32000);
      -- l_content CLOB;
      l_contentIdx pls_integer;
      l_blob BLOB;
      l_atthname varchar2(255);
      l_display_type varchar2(256) := p_doc_type;
      l_content_type varchar2(256);   -- as in fnd_lobs

      l_attrlist wf_xml_attr_table_type;
      l_cbuf varchar2(32000);
      l_doc_end integer;
      l_doc_length number;
      l_start VARCHAR2(10) := '<![CDATA[';
      l_end VARCHAR2(4) := ']]>';
      l_isURLAttrs boolean;
      l_aname varchar2(30);

      l_error_result  varchar2 (2000);
      l_err_name      varchar2(30);
      l_err_message   varchar2(2000);
      l_err_stack     varchar2(4000);

      cursor c_attr(p_nid varchar2) is
      select WMA.TYPE, WMA.DISPLAY_NAME,
             decode(WMA.TYPE, 'URL', WF_NOTIFICATION.GetUrlText(WNA.TEXT_VALUE,
                    p_nid), WNA.TEXT_VALUE) URL, WNA.NAME
      from WF_NOTIFICATION_ATTRIBUTES WNA, WF_NOTIFICATIONS WN,
           WF_MESSAGE_ATTRIBUTES_VL WMA
      where WNA.NOTIFICATION_ID = p_nid
      and WN.NOTIFICATION_ID = WNA.NOTIFICATION_ID
      and WN.MESSAGE_TYPE = WMA.MESSAGE_TYPE
      and WN.MESSAGE_NAME = WMA.MESSAGE_NAME
      and (WMA.TYPE = 'URL' or WMA.TYPE = 'DOCUMENT')
      and WMA.ATTACH = 'Y'
      and WMA.NAME = WNA.NAME;

      l_extn varchar2(255);

      l_mimeType varchar2(256);
      l_encoding varchar2(256);
      l_filename varchar2(320);
      l_attr_url varchar2(32000);

   begin

      -- dbms_lob.createTemporary(l_content, TRUE, dbms_lob.CALL);

      -- Allocate LOB from WF_TEMP LOB pool.
      l_contentIdx := wf_temp_lob.getLOB(g_LOBTable);
      dbms_lob.createTemporary(l_blob, TRUE, dbms_lob.CALL);

      l_pos := p_pos;
      for l_crec in c_attr(p_nid) loop
         dbms_lob.trim(g_LOBTable(l_contentIdx).temp_lob, 0);
         if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then

            wf_log_pkg.string(WF_LOG_PKG.level_statement,
                             'wf.plsql.WF_XML.GetAttachment',
                             'Document URL {'||l_crec.url||'}');
         end if;

         if l_crec.type = 'URL' then
            l_isURLAttrs := true;
         else
            /*
            ** The mechanism to obtain PLSQL and PLSQLCLOB documents
            ** as attachments.
            */
            if upper(substr(l_crec.url,1, 6)) = 'PLSQL:' then

               -- wf_mail.getDocContent(p_nid, l_crec.name, l_display_type,
               --                       l_tmpcontent, l_error_result);
               -- bug 2879507. call wf_notification.GetAttrDoc2 to get the
               -- doc content as well as the document type

           begin
                 wf_notification.GetAttrDoc2(p_nid, l_crec.name, l_display_type,
                                         l_tmpcontent, l_content_type);
           exception
                  when others then
                     if (wf_log_pkg.level_error >=
                         fnd_log.g_current_runtime_level) then
                        wf_log_pkg.string(WF_LOG_PKG.level_error,
                          'wf.plsql.WF_XML.GetAttachment',
                          'Error when getting PLSQL Document attachment -> '||sqlerrm);
                     end if;
                     wf_core.context('WF_XML', 'GetAttachment', to_char(p_nid),
                                     l_display_type);
             raise;
               end;

               l_tmpContent := replace(l_tmpContent, g_fndapi_misschr);
               -- default to display type if no document type specified
               if (l_content_type is null) then
                  l_content_type := l_display_type;
               end if;
               -- Derrive the name for the attachment.
               WF_MAIL_UTIL.parseContentType(l_content_type, l_mimeType, l_filename,
                                l_extn, l_encoding);

               if l_filename is null or l_filename = '' then
                  l_filename := l_crec.display_name ||'.'||l_extn;
               end if;

               -- Bug 8801597
               -- <<sstomar>> : File name may have '&' character etc., due to it SAX parser at
               -- (Mailer) java layer will fail if it finds '&' only, so replace it with '&amp;'
               l_filename := WF_NOTIFICATION.SubstituteSpecialChars(l_filename);

               -- l_filename := Wf_Core.SubstituteSpecialChars(l_filename);

               AddElementAttribute('content-type',l_mimeType, l_attrlist);
               l_pos := NewLOBTag(p_doc, l_pos, 'BODYPART', '', l_attrlist);
               l_attrlist.DELETE;
               AddElementAttribute('content-type',l_mimeType, l_attrlist);
               AddElementAttribute('content-disposition',p_disposition,
                                   l_attrlist);
               AddElementAttribute('filename', l_filename, l_attrlist);
               AddElementAttribute('encoding', l_encoding, l_attrlist);
               dbms_lob.trim(g_LOBTable(l_contentIdx).temp_lob,0);
               dbms_lob.writeAppend(g_LOBTable(l_contentIdx).temp_lob,
                                    length(l_start), l_start);
               dbms_lob.writeAppend(g_LOBTable(l_contentIdx).temp_lob,
                                    length(l_tmpContent),
                                 l_tmpContent);
               dbms_lob.writeAppend(g_LOBTable(l_contentIdx).temp_lob,
                                    length(l_end), l_end);

               l_pos := NewLOBTag(p_doc, l_pos, 'MESSAGE',
                                  g_LOBTable(l_contentIdx).temp_lob,
                                 l_attrlist);
               l_pos := SkipLOBTag(p_doc, 'MESSAGE', l_pos, l_occurance);
               l_pos := SkipLOBTag(p_doc, 'BODYPART', l_pos, l_occurance);
            elsif upper(substr(l_crec.url,1, 10)) = 'PLSQLCLOB:' then
               /*
               ** For PLSQLCLOB documents.
               */
               dbms_lob.trim(g_LOBTable(l_contentIdx).temp_lob,0);
               l_content_type := '';

               --
               -- Getting Content
               -- First we call the existing APIs to render the
               -- content and then we fetch the content into
               -- the new structure.
               -- Note: LOB allocated within  wf_mail.getLOBDocContent API
               --       is released here after processing by calling
               --       WF_MAIL.CloseLob(l_display_type) api.

           begin
             wf_mail.getLOBDocContent(p_nid, l_crec.name, l_display_type,
                                          l_content_type, l_error_result);
               exception
                  when others then
                     if (wf_log_pkg.level_error >=
                         fnd_log.g_current_runtime_level) then
                        wf_log_pkg.string(WF_LOG_PKG.level_error,
                          'wf.plsql.WF_XML.GetAttachment',
                          'Error when getting PLSQL CLOB Document attachment -> '||sqlerrm);
                     end if;
                     wf_core.context('WF_XML', 'GetAttachment', to_char(p_nid),
                                     l_display_type);
             raise;
               end;

               -- default to display type is no document type is specified
               if (l_content_type is null) then
                  l_content_type := l_display_type;
               end if;
               -- Derrive the name for the attachment.
               WF_MAIL_UTIL.parseContentType(l_content_type, l_mimeType, l_filename,
                                l_extn, l_encoding);
               if l_filename is null or l_filename = '' then
                  l_filename := l_crec.display_name ||'.'||l_extn;
               end if;

               -- Bug 8801597
               -- <<sstomar>> : File name may have '&' character etc., due to it SAX parser at
               -- (Mailer) java layer will fail if it finds '&' only, so replace it with '&amp;'
               -- l_filename := Wf_Core.SubstituteSpecialChars(l_filename);
               l_filename := WF_NOTIFICATION.SubstituteSpecialChars(l_filename);

               if lower(l_mimeType) not like 'text/%' and
                  (l_encoding is null or lower(l_encoding) <> 'base64') then
                  -- Assume that there has been no encoding on a RAW
                  -- type lob. Do not include it here. Defer attaching
                  -- the content.
                  --
                  -- Build the attribute list for the attachment
                  -- including the content-type, file name etc.
                  --

                  -- First the BODYPART structure to take the MESSAGE
                  AddElementAttribute('content-type',l_mimeType, l_attrlist);
                  l_pos := NewLOBTag(p_doc, l_pos, 'BODYPART', '', l_attrlist);
                  l_attrlist.DELETE;
                  l_attr_url := Wf_Notification.GetText(l_crec.URL, p_nid, l_display_type);
                  AddElementAttribute('src', l_attr_url, l_attrlist);
                  AddElementAttribute('content-type',l_mimeType, l_attrlist);
                  AddElementAttribute('content-disposition',p_disposition,
                                      l_attrlist);
                  AddElementAttribute('filename', l_filename, l_attrlist);

                  l_pos := NewLOBTag(p_doc, l_pos, 'MESSAGE', '',
                                     l_attrlist);
                  l_pos := SkipLOBTag(p_doc, 'MESSAGE', l_pos, l_occurance);
                  l_pos := SkipLOBTag(p_doc, 'BODYPART', l_pos, l_occurance);

               else

                  -- Fetch the content
                  WF_MAIL.InitFetchLOB(l_display_type, l_doc_length);
                  l_doc_end := 0;
                  dbms_lob.writeAppend(g_LOBTable(l_contentIdx).temp_lob,
                                       length(l_start), l_start);
                  while l_doc_end = 0 loop
                     WF_MAIL.FetchLobContent(l_tmpContent, l_display_type,
                                    l_doc_end);
                     l_tmpContent := replace(l_tmpContent, g_fndapi_misschr);
                     dbms_lob.writeAppend(g_LOBTable(l_contentIdx).temp_lob,
                                          length(l_tmpContent), l_tmpContent);
                  end loop;


                  dbms_lob.writeAppend(g_LOBTable(l_contentIdx).temp_lob,
                                       length(l_end), l_end);
                  --
                  -- Build the attribute list for the attachment
                  -- including the content-type, file name etc.
                  --

                  -- First the BODYPART structure to take the MESSAGE
                  AddElementAttribute('content-type',l_mimeType, l_attrlist);
                  l_pos := NewLOBTag(p_doc, l_pos, 'BODYPART', '', l_attrlist);
                  l_attrlist.DELETE;

                  AddElementAttribute('content-type', l_mimeType, l_attrlist);
                  AddElementAttribute('content-disposition',p_disposition,
                                      l_attrlist);
                  AddElementAttribute('filename', l_filename, l_attrlist);
                  AddElementAttribute('encoding', l_encoding, l_attrlist);

                  l_pos := NewLOBTag(p_doc, l_pos, 'MESSAGE',
                                     g_LOBTable(l_contentIdx).temp_lob,
                                     l_attrlist);
                  l_pos := SkipLOBTag(p_doc, 'MESSAGE', l_pos, l_occurance);
                  l_pos := SkipLOBTag(p_doc, 'BODYPART', l_pos, l_occurance);
               end if;

                -- Release temp LOB allocated within wf_mail.getLOBDocContent
                -- i.e. wf_mail.g_html_messageIdx or wf_mail.g_text_messageIdx Locators
                WF_MAIL.CloseLob(l_display_type);

            elsif upper(substr(l_crec.url,1, 10)) = 'PLSQLBLOB:' then
               /*
               ** For PLSQLBLOB documents.
               */
               dbms_lob.trim(l_blob,0);

               --
               -- Getting Content
               -- First we call the existing APIs to render the
               -- content and then we fetch the content into
               -- the new structure.
               --
               begin
                  Wf_Notification.GetAttrBLOB(p_nid, l_crec.name,
                                              l_display_type,
                                              l_blob, l_content_type,
                                              l_aname);
               exception
                  when others then
                     if (wf_log_pkg.level_error >=
                         fnd_log.g_current_runtime_level) then
                        wf_log_pkg.string(WF_LOG_PKG.level_error,
                          'wf.plsql.WF_XML.GetAttachment',
                          'Error when getting BLOB attachment -> '||sqlerrm);
                     end if;
                     wf_core.context('WF_XML', 'GetAttachment', to_char(p_nid),
                                     l_display_type);
                     raise;
               end;

               -- default to display type is no document type is specified
               if (l_content_type is null) then
                  l_content_type := l_display_type;
               end if;
               -- Derrive the name for the attachment.
               WF_MAIL_UTIL.parseContentType(l_content_type, l_mimeType, l_filename,
                                l_extn, l_encoding);

               if l_filename is null or l_filename = '' then
                  l_filename := l_crec.display_name ||'.'||l_extn;
               end if;

               -- Bug 8801597 ( File name may have '&' character etc. )
               -- SAX parser at java layer will fail if it finds '&' only, so replace it with '&amp;'
               -- SubstituteSpecialChars API takes care if BLOB API already repalced '&' with '&amp;'
               l_filename := WF_NOTIFICATION.SubstituteSpecialChars(l_filename);

               -- First the BODYPART structure to take the MESSAGE
               AddElementAttribute('content-type',l_mimeType, l_attrlist);
               l_pos := NewLOBTag(p_doc, l_pos, 'BODYPART', '', l_attrlist);
               l_attrlist.DELETE;

               l_attr_url := Wf_Notification.GetText(l_crec.URL, p_nid, l_display_type);

               AddElementAttribute('src', l_attr_url, l_attrlist);
               AddElementAttribute('content-type',l_mimeType, l_attrlist);
               AddElementAttribute('content-disposition',p_disposition,
                                      l_attrlist);
               AddElementAttribute('filename', l_filename, l_attrlist);

               l_pos := NewLOBTag(p_doc, l_pos, 'MESSAGE', '',
                                  l_attrlist);
               l_pos := SkipLOBTag(p_doc, 'MESSAGE', l_pos, l_occurance);
               l_pos := SkipLOBTag(p_doc, 'BODYPART', l_pos, l_occurance);

            end if;
         end if;
         l_attrlist.DELETE;
      end loop;

      -- BUG 3285943 - If this is for a framework notification
      -- then we don't need the attached URLs.
      -- Bug 5456241 : Pick html / text msg body based on content-type.
      if (WF_NOTIFICATION.isFwkRegion(p_nid, l_display_type)='Y' and g_install='EMBEDDED') then
         l_isURLAttrs := FALSE;
      end if;

      if l_isURLAttrs then
         dbms_lob.trim(g_LOBTable(l_contentIdx).temp_lob,0);

         wf_mail.GetURLAttachment(p_nid, l_tmpContent, l_error_result);
         dbms_lob.writeAppend(g_LOBTable(l_contentIdx).temp_lob,
                              length(l_start), l_start);
         dbms_lob.writeAppend(g_LOBTable(l_contentIdx).temp_lob,
                              length(l_tmpContent), l_tmpContent);
         dbms_lob.writeAppend(g_LOBTable(l_contentIdx).temp_lob,
                              length(l_end), l_end);


         if l_error_result is not null or l_error_result <> '' then
            wf_core.context('WF_XML', 'GetAttachments', to_char(p_nid),
                            p_agent, to_char(p_pos));
            wf_core.token('SQLERR', l_error_result);
            wf_core.raise('WF_URLLIST_ERROR');
         end if;

         -- No need to handle "&" char in filename here as these names are seeded ones
         l_fileName := g_urlListAttachment||'.html';

         -- First the BODYPART structure to take the MESSAGE
         AddElementAttribute('content-type',l_display_type, l_attrlist);
         l_pos := NewLOBTag(p_doc, l_pos, 'BODYPART', '', l_attrlist);
         l_attrlist.DELETE;

         AddElementAttribute('content-type',g_ntfDocHtml,
                             l_attrlist);
         AddElementAttribute('content-disposition',p_disposition,
                             l_attrlist);
         AddElementAttribute('filename', l_filename, l_attrlist);

         l_pos := NewLOBTag(p_doc, l_pos, 'MESSAGE',
                            g_LOBTable(l_contentIdx).temp_lob, l_attrlist);
         l_pos := SkipLOBTag(p_doc, 'MESSAGE', l_pos, l_occurance);
         l_pos := SkipLOBTag(p_doc, 'BODYPART', l_pos, l_occurance);

      end if;

      -- relase TEMP allocated LOB
      wf_temp_lob.releaseLob(g_LOBTable, l_contentIdx);

      if (wf_log_pkg.level_procedure >= fnd_log.g_current_runtime_level) then
         wf_log_pkg.string(WF_LOG_PKG.level_procedure,
                          'wf.plsql.WF_XML.GetAttachment',
                          'END');
      end if;

      return l_pos;
   exception
      when others then
         WF_MAIL.CloseLob(l_display_type);
         wf_temp_lob.releaseLob(g_LOBTable, l_contentIdx);
         wf_core.context('WF_XML', 'GetAttachments', to_char(p_nid), p_agent,
                         to_char(p_pos));
         l_err_message := sqlerrm;
         raise;
   end GetAttachment;


   -- GetAttributes - Create an attribute tag for each of the response
   --                 required attributes.
   -- IN
   --    Notification ID
   --    Document handle
   --    MIME Agent for the attribute
   --    Location in the document to insert the new TAG(s)
   -- RETURN
   --    The new position in the docuemnt.
   function GetAttributes(p_nid in number,
                           p_doc in out NOCOPY CLOB,
                           p_agent in varchar2,
                           p_pos in out NOCOPY integer) return integer
   is

      l_pos integer;
      l_attrlist      wf_xml_attr_table_type;
      l_occurance integer := 1;
      l_error_result    varchar2 (2000);
      l_err_name      varchar2(30);
      l_err_message   varchar2(2000);
      l_err_stack     varchar2(4000);
      l_value varchar2(2000);

      cursor c1 is
      select WMA.NAME, WMA.DISPLAY_NAME, WMA.DESCRIPTION, WMA.TYPE, WMA.FORMAT,
             decode(WMA.TYPE,
               'VARCHAR2', decode(WMA.FORMAT,
                             '', WNA.TEXT_VALUE,
                             substr(WNA.TEXT_VALUE, 1, to_number(WMA.FORMAT))),
               'NUMBER', decode(WMA.FORMAT,
                           '', to_char(WNA.NUMBER_VALUE),
                           to_char(WNA.NUMBER_VALUE, WMA.FORMAT)),
               'DATE', decode(WMA.FORMAT,
                         '', to_char(WNA.DATE_VALUE),
                         to_char(WNA.DATE_VALUE, WMA.FORMAT)),
               'LOOKUP', WNA.TEXT_VALUE,
               WNA.TEXT_VALUE) VALUE
      from   WF_NOTIFICATION_ATTRIBUTES WNA,
             WF_NOTIFICATIONS WN,
             WF_MESSAGE_ATTRIBUTES_VL WMA
      where  WNA.NOTIFICATION_ID = p_nid
        and    WN.NOTIFICATION_ID = WNA.NOTIFICATION_ID
        and    WN.MESSAGE_TYPE = WMA.MESSAGE_TYPE
        and    WN.MESSAGE_NAME = WMA.MESSAGE_NAME
        and    WMA.NAME = WNA.NAME
        and    WMA.SUBTYPE = 'RESPOND'
        and    WMA.TYPE not in ('FORM', 'URL')
       order  by WMA.SEQUENCE;

   begin

      l_pos := p_pos;
      for rec in c1 loop
         l_attrlist.DELETE;
         AddElementAttribute('name',rec.name, l_attrlist);
         AddElementAttribute('type',rec.type, l_attrlist);
         if rec.format is not NULL then
            AddElementAttribute('format',rec.format, l_attrlist);
         end if;
         l_pos := NewLOBTag(p_doc, l_pos, 'ATTRIBUTE','',l_attrlist);
         l_attrlist.DELETE;
         l_pos := NewLOBTag(p_doc, l_pos, 'NAME', rec.display_name, l_attrlist);
         l_pos := SkipLOBTag(p_doc, 'NAME', l_pos, l_occurance);
         l_value := EncodeEntityReference(rec.value);
         l_pos := NewLOBTag(p_doc, l_pos, 'VALUE', rec.value, l_attrlist);

         l_pos := SkipLOBTag(p_doc, 'ATTRIBUTE', l_pos, l_occurance);

      end loop;
      return l_pos;
   exception
      when others then
         wf_core.context('WF_XML', 'GetAttributes', to_char(p_nid));
         raise;
   end GetAttributes;

   -- GetXMLMessage - Return a CLOB Document containing an XML encoded version of the
   --                 notification. No recipients list will be populated. That
   --                 will be the responsibility of the calling procedure.
   --
   -- IN
   --     notification id
   --     Protocol for the message
   --     List of recipients to recieve the notification
   --     mailer node name
   --     Web Agent for the HTML attachments
   --     Reply to address for the final notification
   --     Language for the notification
   --     Territory for the notification
   -- OUT
   --     Piority for the message
   --     A CLOB Containing the XML encoded message.
   procedure GetXMLMessage (p_nid       in  number,
                        p_protocol  in varchar2,
                        p_recipient_list in WF_DIRECTORY.wf_local_roles_tbl_type,
                        p_node      in  varchar2,
                        p_agent     in  varchar2,
                        p_replyto   in  varchar2,
                        p_nlang     in  varchar2,
                        p_nterr     in varchar2,
                        p_priority out NOCOPY number,
                        p_message in out NOCOPY CLOB)
 is
      -- l_doc             CLOB;
      l_docIdx          pls_integer;
      l_doctype         varchar(100);
      l_pos             integer;
      l_occurance       integer := 1;
      l_item_type       wf_items.item_type%TYPE;
      l_item_key        wf_items.item_key%TYPE;
      l_priority        wf_notifications.priority%TYPE;
      l_access_key      wf_notifications.access_key%TYPE;

      l_response        integer;

      l_attrlist        wf_xml_attr_table_type;
      l_receiverlist    varchar2 (4000);
      l_status          varchar2 (8);
      l_language        varchar2 (30);
      l_territory       varchar2 (30);
      l_installed_lang  varchar2 (1);
      l_str             varchar2 (250);
      l_subject         varchar2 (2000);
      l_text_body       varchar2 (32000);
      l_html_body       varchar2 (32000);
      l_body_atth       varchar2 (32000);
      l_error_result    varchar2 (2000);
      l_err_name        varchar2 (30);
      l_err_message     varchar2 (2000);
      l_err_stack       varchar2 (4000);

   begin

      -- Grab the details of the message to be enqueued using the
      -- previous interface of WF_MAIL.GetMessage.
      begin

         select installed_flag
         into l_installed_lang
         from wf_languages
         where nls_language = p_nlang
           and nls_territory = p_nterr
           and installed_flag = 'Y';

         l_language := ''''||p_nlang||'''';
         l_territory := ''''||p_nterr||'''';
      exception
         when others then
            l_language := 'AMERICAN';
            l_territory := 'AMERICA';
      end;
      dbms_session.set_nls('NLS_LANGUAGE'   , l_language);
      dbms_session.set_nls('NLS_TERRITORY'   , l_territory);

      wf_mail.getmessage(p_nid, p_node, p_agent, p_replyto,
                         l_subject, l_text_body, l_html_body, l_body_atth,
                         l_error_result);
      -- Check for any problems
      if l_error_result is not NULL then
         wf_core.token('LANG', l_language);
         wf_core.token('TERR', l_territory);
         wf_core.token('ERRMSG', l_error_result);
         wf_core.raise('WFXMLERR');
      end if;


      -- Instantiate a handle to the new document.
      -- dbms_lob.createTemporary(l_doc, TRUE, dbms_lob.session);
      l_docIdx := wf_temp_lob.getLob(g_LOBTable);

      -- Initialise the XML Document and then progressively walk
      -- through the elements. Populating them as we go.
      -- l_pos is crucial as it determines where the next nodes
      -- will be placed.
      l_str := '<?xml version="1.0"?>';
      l_pos := length(l_str);

      dbms_lob.write(g_LOBTable(l_docIdx).temp_lob, l_pos, 1, l_str);

      l_pos := NewLOBTag(g_LOBTable(l_docIdx).temp_lob, l_pos,
                         'NOTIFICATION','',l_attrlist);


      AddElementAttribute('language',p_nlang, l_attrlist);
      AddElementAttribute('territory',p_nterr, l_attrlist);
      l_pos := NewLOBTag(g_LOBTable(l_docIdx).temp_lob, l_pos, 'HEADER', '',
                         l_attrlist);
      l_attrlist.DELETE;

      -- Attach the NID
      l_pos := NewLOBTag(g_LOBTable(l_docIdx).temp_lob, l_pos, 'NID',
                         to_char(p_nid),l_attrlist);
      l_pos := SkipLOBTag(g_LOBTable(l_docIdx).temp_lob, 'NID', l_pos,                                    l_occurance);

      begin
         select priority, access_key, status
            into l_priority, l_access_key, l_status
         from wf_notifications_view
         where notification_id = p_nid;
      exception
         when NO_DATA_FOUND then
            wf_core.raise('WFNTFGM_FAILED');
      end;

      l_pos := NewLOBTag(g_LOBTable(l_docIdx).temp_lob, l_pos, 'PRIORITY',
                         to_char(l_priority), l_attrlist);
      l_pos := SkipLOBTag(g_LOBTable(l_docIdx).temp_lob, 'PRIORITY', l_pos,
                          l_occurance);
      l_pos := NewLOBTag(g_LOBTable(l_docIdx).temp_lob, l_pos, 'ACCESSKEY',
                         l_access_key, l_attrlist);
      l_pos := SkipLOBTag(g_LOBTable(l_docIdx).temp_lob, 'ACCESSKEY', l_pos,
                          l_occurance);

      -- Register the receivers as a single string of email addresses
      l_receiverlist := NULL;
      for i in 1..p_recipient_list.COUNT loop
         l_receiverlist := l_receiverlist || p_recipient_list(i).NAME || ',';
      end loop;

      l_receiverlist := substr(l_receiverlist,1,length(l_receiverlist)-1);
      l_pos := NewLOBTag(g_LOBTable(l_docIdx).temp_lob, l_pos, 'RECEIVERLIST',
                         l_receiverlist, l_attrlist);
      l_pos := SkipLOBTag(g_LOBTable(l_docIdx).temp_lob, 'RECEIVERLIST',
                          l_pos, l_occurance);

      l_pos := NewLOBTag(g_LOBTable(l_docIdx).temp_lob, l_pos, 'SENDER', '',
                         l_attrlist);
      l_pos := SkipLOBTag(g_LOBTable(l_docIdx).temp_lob, 'SENDER', l_pos,
                          l_occurance);

      l_pos := NewLOBTag(g_LOBTable(l_docIdx).temp_lob, l_pos, 'STATUS',
                         l_status, l_attrlist);
      l_pos := SkipLOBTag(g_LOBTable(l_docIdx).temp_lob, 'STATUS', l_pos,
                          l_occurance);

      l_pos := NewLOBTag(g_LOBTable(l_docIdx).temp_lob, l_pos, 'SUBJECT',
                         l_subject, l_attrlist);
      l_pos := SkipLOBTag(g_LOBTable(l_docIdx).temp_lob, 'HEADER', l_pos,
                          l_occurance);

      l_text_body := EncodeEntityReference(l_text_body);
      l_pos := NewLOBTag(g_LOBTable(l_docIdx).temp_lob, l_pos, 'BODYTEXT',
                         l_text_body, l_attrlist);
      l_pos := SkipLOBTag(g_LOBTable(l_docIdx).temp_lob, 'BODYTEXT', l_pos,                               l_occurance);

      AddElementAttribute('content-type','text/html', l_attrlist);
      AddElementAttribute('hmldesc','HTML', l_attrlist);
      AddElementAttribute('htmlagent',p_agent, l_attrlist);

      l_html_body := EncodeEntityReference(l_html_body);

      l_pos := NewLOBTag(g_LOBTable(l_docIdx).temp_lob, l_pos, 'BODYHTML',
                         l_html_body, l_attrlist);
      l_pos := SkipLOBTag(g_LOBTable(l_docIdx).temp_lob, 'BODYHTML', l_pos,
                          l_occurance);
      l_attrlist.DELETE;

      l_pos := NewLOBTag(g_LOBTable(l_docIdx).temp_lob, l_pos,
                         'ATTACHMENTLIST', '', l_attrlist);
      -- Next will be to attach all URLs and DOCUMENT attributes
      -- as attachments.
      l_pos := GetAttachment(p_nid, g_LOBTable(l_docIdx).temp_lob, p_agent,
                             NULL, l_doctype, l_pos);
      l_pos := SkipLOBTag(g_LOBTable(l_docIdx).temp_lob, 'ATTACHMENTLIST',
                          l_pos, l_occurance);

      -- Check to see if the notification is a reponse and attach
      -- the response attributes.
      l_response := 0;
      begin
        select 1 into l_response
        from dual
        where exists (select NULL
                  from WF_MESSAGE_ATTRIBUTES MA,
                       WF_NOTIFICATIONS N
                  where N.NOTIFICATION_ID = p_nid
                  and   MA.MESSAGE_TYPE = N.MESSAGE_TYPE
                  and   MA.MESSAGE_NAME = N.MESSAGE_NAME
                  and   MA.SUBTYPE = 'RESPOND');

        l_pos := NewLOBTag(g_LOBTable(l_docIdx).temp_lob, l_pos,
                           'ATTRIBUTELIST', '', l_attrlist);
        l_pos := GetAttributes(p_nid, g_LOBTable(l_docIdx).temp_lob, p_agent,
                               l_pos);

      exception
        when NO_DATA_FOUND then
           null;
      end;

      p_priority := l_priority;
      dbms_lob.copy(p_message, g_LOBTable(l_docIdx).temp_lob,
                    dbms_lob.getLength(g_LOBTable(l_docIdx).temp_lob), 1, 1);
      -- dbms_lob.freetemporary(l_doc).temp_lob);
      wf_temp_lob.releaseLob(g_LOBTable, l_docIdx);

   exception
      when others then
        wf_temp_lob.releaseLob(g_LOBTable, l_docIdx);
        wf_core.context('WF_XML', 'GetXMLMessage', to_char(p_nid), p_protocol,
                        p_node, p_nlang, p_nterr);
        raise;
   end getXMLMessage;

   -- GetShortLOBXMLMessage -
   -- Return a CLOB Document containing an XML encoded versi on of the
   --                 notification. No recipients list will be populated. That
   --                 will be the responsibility of the calling procedure.
   --
   -- IN
   --     notification id
   --     Protocol for the message
   --     List of recipients to recieve the notification
   --     mailer node name
   --     Web Agent for the HTML attachments
   --     Reply to address for the final notification
   --     Language for the notification
   --     Territory for the notification
   -- OUT
   --     Piority for the message
   --     A CLOB Containing the XML encoded message.
   procedure GetShortLOBXMLMessage (p_nid       in  number,
                            p_priority out NOCOPY number,
                            p_message in out NOCOPY CLOB)
 is
      -- l_doc             CLOB;
      l_docIdx          pls_integer;
      l_pos             integer;
      l_occurance       integer := 1;
      l_priority        wf_notifications.priority%TYPE;
      l_status          wf_notifications.status%TYPE;
      l_recipient       wf_notifications.recipient_role%TYPE;

      l_attrlist        wf_xml_attr_table_type;
      l_str             varchar2 (250);

      l_error_result    varchar2 (2000);
      l_err_name        varchar2 (30);
      l_err_message     varchar2 (2000);
      l_err_stack       varchar2 (4000);
      l_more_info_role  varchar2(320);

   begin

      -- Grab the details of the message to be enqueued using the
      -- previous interface of WF_MAIL.GetMessage.

      -- Instantiate a handle to the new document.
      -- dbms_lob.createTemporary(l_doc, TRUE, dbms_lob.session);
      l_docIdx := wf_temp_lob.getLOB(g_LOBTable);

      -- Initialise the XML Document and then progressively walk
      -- through the elements. Populating them as we go.
      -- l_pos is crucial as it determines where the next nodes
      -- will be placed.
      l_str := '<?xml version="1.0"?>';
      l_pos := length(l_str);

      dbms_lob.write(g_LOBTable(l_docIdx).temp_lob, l_pos, 1, l_str);

      l_pos := NewLOBTag(g_LOBTable(l_docIdx).temp_lob, l_pos,
                         'NOTIFICATION','',l_attrlist);

      l_pos := NewLOBTag(g_LOBTable(l_docIdx).temp_lob, l_pos,
                         'HEADER', '', l_attrlist);
      l_attrlist.DELETE;

      -- Attach the NID
      l_pos := NewLOBTag(g_LOBTable(l_docIdx).temp_lob, l_pos,
                         'NID', to_char(p_nid),l_attrlist);
      l_pos := SkipLOBTag(g_LOBTable(l_docIdx).temp_lob,
                          'NID', l_pos, l_occurance);

      begin
         select recipient_role, priority, status, more_info_role
            into l_recipient, l_priority, l_status, l_more_info_role
         from wf_notifications
         where notification_id = p_nid;
      exception
         when NO_DATA_FOUND then
            wf_core.raise('WFNTFGM_FAILED');
      end;

      l_pos := NewLOBTag(g_LOBTable(l_docIdx).temp_lob, l_pos,
                         'PRIORITY', to_char(l_priority), l_attrlist);
      l_pos := SkipLOBTag(g_LOBTable(l_docIdx).temp_lob,
                          'PRIORITY', l_pos, l_occurance);

      if (l_more_info_role is not null) then
         l_recipient := l_more_info_role;
      end if;
      l_pos := NewLOBTag(g_LOBTable(l_docIdx).temp_lob, l_pos,
                         'RECIPIENT', l_recipient, l_attrlist);
      l_pos := SkipLOBTag(g_LOBTable(l_docIdx).temp_lob,
                          'RECIPIENT', l_pos, l_occurance);

      l_pos := NewLOBTag(g_LOBTable(l_docIdx).temp_lob, l_pos,
                         'STATUS', l_status, l_attrlist);
      l_pos := SkipLOBTag(g_LOBTable(l_docIdx).temp_lob,
                          'STATUS', l_pos, l_occurance);

      p_priority := l_priority;
      dbms_lob.copy(p_message, g_LOBTable(l_docIdx).temp_lob,
                    dbms_lob.getLength(g_LOBTable(l_docIdx).temp_lob), 1, 1);
      -- dbms_lob.freetemporary(g_LOBTable(l_docIdx).temp_lob);
      wf_temp_lob.releaseLob(g_LOBTable, l_docIdx);

   exception
      when others then
        wf_temp_lob.releaseLob(g_LOBTable, l_docIdx);
        wf_core.context('WF_XML', 'GetShortLOBXMLMessage', to_char(p_nid));
        raise;
   end getShortLOBXMLMessage;

   -- GetShortXMLMessage -
   -- Return a VARCHAR Document containing an XML encoded versi on of the
   -- notification. No recipients list will be populated. That
   -- will be the responsibility of the calling procedure.
   --
   -- IN
   --     notification id
   --     Protocol for the message
   --     List of recipients to recieve the notification
   --     mailer node name
   --     Web Agent for the HTML attachments
   --     Reply to address for the final notification
   --     Language for the notification
   --     Territory for the notification
   -- OUT
   --     Piority for the message
   --     A VARCHAR Containing the XML encoded message.
   procedure GetShortXMLMessage (p_nid       in  number,
                            p_priority out NOCOPY number,
                            p_message in out NOCOPY VARCHAR2)
 is
      l_pos             integer;
      l_occurance       integer := 1;
      l_priority        wf_notifications.priority%TYPE;
      l_status          wf_notifications.status%TYPE;
      l_recipient       wf_notifications.recipient_role%TYPE;

      l_attrlist        wf_xml_attr_table_type;
      l_str             varchar2 (250);

      l_error_result    varchar2 (2000);
      l_err_name        varchar2 (30);
      l_err_message     varchar2 (2000);
      l_err_stack       varchar2 (4000);
      l_more_info_role  varchar2(320);

   begin

      -- Grab the details of the message to be enqueued using the
      -- previous interface of WF_MAIL.GetMessage.

      -- Instantiate a handle to the new document.
      p_message := '';

      -- Initialise the XML Document and then progressively walk
      -- through the elements. Populating them as we go.
      -- l_pos is crucial as it determines where the next nodes
      -- will be placed.
      l_str := '<?xml version="1.0"?>';
      l_pos := length(l_str);

      p_message := p_message||l_str;

      l_pos := NewTag(p_message, l_pos, 'NOTIFICATION',NULL,l_attrlist);

      l_pos := NewTag(p_message, l_pos, 'HEADER', NULL, l_attrlist);
      l_attrlist.DELETE;

      -- Attach the NID
      l_pos := NewTag(p_message, l_pos, 'NID', to_char(p_nid),l_attrlist);
      l_pos := SkipTag(p_message, 'NID', l_pos, l_occurance);

      begin
         select recipient_role, priority, status, more_info_role
            into l_recipient, l_priority, l_status, l_more_info_role
         from wf_notifications
         where notification_id = p_nid;
      exception
         when NO_DATA_FOUND then
            wf_core.raise('WFNTFGM_FAILED');
      end;

      l_pos := NewTag(p_message, l_pos, 'PRIORITY', to_char(l_priority),
                      l_attrlist);
      l_pos := SkipTag(p_message, 'PRIORITY', l_pos, l_occurance);

      if (l_more_info_role is not null) then
         l_recipient := l_more_info_role;
      end if;
      l_pos := NewTag(p_message, l_pos, 'RECIPIENT', l_recipient, l_attrlist);
      l_pos := SkipTag(p_message, 'RECIPIENT', l_pos, l_occurance);

      l_pos := NewTag(p_message, l_pos, 'STATUS', l_status, l_attrlist);
      l_pos := SkipTag(p_message, 'STATUS', l_pos, l_occurance);

      p_priority := l_priority;

   exception
      when others then
        wf_core.context('WF_XML', 'GetShortXMLMessage', to_char(p_nid));
        raise;
   end getShortXMLMessage;


   -- EnqueueFullNotification -
   --     To push a notification to the outbound notification queue.
   -- IN
   --    Notification ID
   procedure EnqueueFullNotification(p_nid in number) is

      l_queue_name varchar2(255);

      l_node varchar2(30);
      l_agent varchar(255) := g_webAgent;
      l_replyto varchar2(320);

      l_nlang wf_languages.nls_language%TYPE;
      l_nterr wf_languages.nls_territory%TYPE;
      l_priority number;
      -- l_message CLOB;
      l_messageIdx pls_integer;

      l_recipient_role varchar2(320);
      l_ntf_pref varchar2(30);
      l_language varchar2(30);
      l_recipient_list WF_DIRECTORY.wf_local_roles_tbl_type;
      l_recipient_lang WF_DIRECTORY.wf_local_roles_tbl_type;
      l_wf_schema varchar2(320) := g_wfSchema;

      l_err_name      varchar2(30);
      l_err_message   varchar2(2000);
      l_err_stack     varchar2(4000);

      i binary_integer := 0;
      j binary_integer := 0;

   begin

      -- Obtain the name of the recipient role, but only if a
      -- notification is needed to go out. ie the mail status
      -- indicates that a notification should be sent.
      begin
         select recipient_role
            into l_recipient_role
         from wf_notifications
         where notification_id = p_nid
           and ((MAIL_STATUS = 'MAIL' and STATUS <> 'CLOSED')
            or (MAIL_STATUS = 'INVALID'));
      exception
         when NO_DATA_FOUND then
            l_recipient_role := NULL;
         when others then
            raise;
      end;
      if l_recipient_role is not null then
         -- Determine the total list of individual recipients
         -- ordered by Protocol and then Language.
         l_recipient_list.DELETE;
         GetRecipients(l_recipient_role, l_recipient_list);

      end if;

      if l_recipient_list.COUNT > 0 then
         -- A valid role has been found for a notification
         -- that is required to go out.
         -- Prepare a LOB to contain the payload message.
         -- dbms_lob.createTemporary(l_message, TRUE, dbms_lob.SESSION);
         l_messageIdx := wf_temp_lob.getLob(g_LOBTable);

         wf_queue.set_queue_names;
         wf_queue.get_hash_queue_name (p_protocol => 'SMTP',
                                       p_inbound_outbound => 'OUTBOUND',
                                       p_queue_name   => l_queue_name);
         l_language := l_recipient_list(1).language;
         l_ntf_pref := l_recipient_list(1).notification_preference;
         l_recipient_lang.DELETE;
         j := 1;
         i := 1;


         -- Walk through the recipient list. This will be sorted by Notification
         -- preference and language. We group the recipients this way to help
         -- minimise the number of Queue messages to the number of recipients.
         loop
         exit when  i > l_recipient_list.COUNT;
            if l_ntf_pref <> l_recipient_list(i).notification_preference then
               wf_queue.get_hash_queue_name (p_protocol => 'SMTP',
                                             p_inbound_outbound => 'OUTBOUND',
                                             p_queue_name   => l_queue_name);

            end if;
            loop
            exit when (i > l_recipient_list.COUNT)
              or (l_ntf_pref <> l_recipient_list(i).notification_preference);
              j := 1;
              loop
              exit when (i > l_recipient_list.COUNT)
                     or (l_ntf_pref <> l_recipient_list(i).notification_preference)
                     or (l_language <> l_recipient_list(i).language);

                 l_recipient_lang(j) := l_recipient_list(i);
                 i := i + 1;
                 j := j + 1;
              end loop;
              -- Get an encoded payload.
              getXMLMessage(p_nid, l_ntf_pref,
                           l_recipient_lang, l_node, l_agent,
                           l_replyto,
                           l_recipient_lang(1).language,
                           l_recipient_lang(1).territory, l_priority, g_LOBTable(l_messageIdx).temp_lob);

              -- Push the message to the queue.
              enqueueLOBMessage(p_queue => l_queue_name,
                             p_priority => l_priority,
                             p_correlation => wf_queue.account_name ||':'||
                                              to_char(p_nid),
                             p_message => g_LOBTable(l_messageIdx).temp_lob);

              j := 1;
              l_recipient_lang.DELETE;
              if i <= l_recipient_list.COUNT then
                 l_ntf_pref := l_recipient_list(i).notification_preference;
              end if;
           end loop;
        end loop;
      -- dbms_lob.freetemporary(l_message);
      wf_temp_lob.releaseLob(g_LOBTable, l_messageIdx);
      end if;

   exception
      when others then
        wf_temp_lob.releaseLob(g_LOBTable, l_messageIdx);
        wf_core.context('WF_XML', 'EnqueueFullNotification', to_char(p_nid));
        raise;
   end EnqueueFullNotification;


   -- EnqueueLOBNotification - To push a notification ID to the outbound
   --                       notification queue.
   -- IN
   --    Notification ID
   procedure EnqueueLOBNotification(p_nid in number) is

      l_queue_name varchar2(255);
      l_priority number;

      l_recipient_role varchar2(320);
      -- l_message CLOB;
      l_messageIdx pls_integer;

      l_err_name      varchar2(30);
      l_err_message   varchar2(2000);
      l_err_stack     varchar2(4000);

   begin

      -- Obtain the name of the recipient role, but only if a
      -- notification is needed to go out. ie the mail status
      -- indicates that a notification should be sent.
      begin
         select recipient_role
            into l_recipient_role
         from wf_notifications
         where notification_id = p_nid
           and MAIL_STATUS in ('MAIL', 'INVALID');
      exception
         when NO_DATA_FOUND then
            l_recipient_role := NULL;
         when others then
            raise;
      end;
      if l_recipient_role is not null then
         -- A valid role has been found for a notification
         -- that is required to go out.

         -- dbms_lob.createTemporary(l_message, TRUE, dbms_lob.CALL);
         l_messageIdx := wf_temp_lob.getLob(g_LOBTable);
         -- Get an encoded payload.
         getShortLOBXMLMessage(p_nid, l_priority,
                               g_LOBTable(l_messageIdx).temp_lob);

         wf_queue.set_queue_names;
         wf_queue.get_hash_queue_name (p_protocol => 'SMTP',
                                       p_inbound_outbound => 'OUTBOUND',
                                       p_queue_name   => l_queue_name);

         -- Push the message to the queue.
         enqueueLOBMessage(p_queue => l_queue_name,
                        p_priority => l_priority,
                        p_correlation => wf_queue.account_name ||':'||
                                         to_char(p_nid),
                        p_message => g_LOBTable(l_messageIdx).temp_lob);
      end if;
      wf_temp_lob.releaseLob(g_LOBTable, l_messageIdx);

   exception
      when others then
        wf_temp_lob.releaseLob(g_LOBTable, l_messageIdx);
        wf_core.context('WF_XML', 'EnqueueLOBNotification', to_char(p_nid));
        raise;
   end EnqueueLOBNotification;

   -- EnqueueNotification - To push a notification ID to the outbound
   --                       notification queue.
   -- IN
   --    Notification ID
   procedure EnqueueNotification(p_nid in number) is

      l_queue_name varchar2(255);
      l_priority number;

      l_recipient_role varchar2(320);
      l_message VARCHAR2(32000);

      l_err_name      varchar2(30);
      l_err_message   varchar2(2000);
      l_err_stack     varchar2(4000);
      l_more_info_role varchar2(320);
   begin

      -- Obtain the name of the recipient role, but only if a
      -- notification is needed to go out. ie the mail status
      -- indicates that a notification should be sent.
      begin
         select recipient_role, more_info_role
            into l_recipient_role, l_more_info_role
         from wf_notifications
         where notification_id = p_nid
           and MAIL_STATUS in ('MAIL', 'INVALID')
           and STATUS <> 'CLOSED';
      exception
         when NO_DATA_FOUND then
            l_recipient_role := NULL;
            l_more_info_role := NULL;
         when others then
            raise;
      end;
      if (l_recipient_role is not null or l_more_info_role is not null) then
         -- A valid role has been found for a notification
         -- that is required to go out.

         -- Get an encoded payload.
         getShortXMLMessage(p_nid, l_priority, l_message);

         wf_queue.set_queue_names;
         wf_queue.get_hash_queue_name (p_protocol => 'SMTP',
                                       p_inbound_outbound => 'OUTBOUND',
                                       p_queue_name   => l_queue_name);

         -- Push the message to the queue.
         enqueueMessage(p_queue => l_queue_name,
                        p_priority => l_priority,
                        p_correlation => wf_queue.account_name ||':'||
                                         to_char(p_nid),
                        p_message => l_message);
      end if;

   exception
      when others then
        wf_core.context('WF_XML', 'EnqueueNotification', to_char(p_nid));
        raise;
   end EnqueueNotification;


   -- DequeueMessage - Remove a notification from the queue
   -- IN
   --    Queue name to operate on
   --    Correlation for the message - NID in this implementation
   -- OUT
   --    The message that is obtained from the queue.
   --    Timeout to signal whether the queue is empty.
   procedure DequeueMessage(p_queue_name in varchar2,
                            p_correlation in varchar2,
                            p_message   in out NOCOPY CLOB,
                            p_timeout out NOCOPY boolean)
   as

      l_dequeue_options dbms_aq.dequeue_options_t;
      l_message_properties dbms_aq.message_properties_t;
      l_correlation varchar2(255) := NULL;
      l_message_handle RAW(16);

   begin

      /** wf_message_payload_t is obsolete in 2.6.4 onwards **/
      null;

   exception
      when dequeue_timeout then
         p_timeout := TRUE;
      when others then
         Wf_Core.Context('WF_XML', 'DequeueMessage', p_queue_name,
                         p_correlation);
         p_timeout := FALSE;
         raise;
   end DequeueMessage;



   -- GetMessage - Get email message data
   -- IN
   --    Queue number to operate on
   -- OUT
   --    Notification ID
   --    Comma seperated list of the recipients of the notification
   --    Status of the notification - For the purpose of message templating
   --    Timout. Returns TRUE where the queue is empty.
   --    Error message
   procedure GetMessage(
       p_queue    in  number,
       p_nid          out NOCOPY number,
       p_receiverlist out NOCOPY varchar2,
       p_status      out NOCOPY varchar2,
       p_timeout      out NOCOPY integer,
       p_error_result in out NOCOPY varchar2)
   is

      l_nid number;
      l_queue_name   varchar2(255);
      l_status       varchar2(8);
      l_receiverlist varchar2(4000);

      l_message CLOB;
      l_timeout BOOLEAN;
      l_pos integer;
      l_attrlist wf_xml_attr_table_type;

      l_err_name      varchar2(30);
      l_err_message   varchar2(2000);
      l_err_stack     varchar2(4000);
      no_program_unit exception;
      pragma exception_init(no_program_unit, -6508);

   begin

      l_queue_name := g_wfSchema||'.WF_SMTP_O_'||
                      to_char(p_queue)||'_QUEUE';

      -- Grab the next available message from the queue.
      DequeueMessage(p_queue_name => l_queue_name,
                     p_correlation => NULL,
                     p_message => l_message,
                     p_timeout => l_timeout);

      -- If the result is from the queue being empty then we want to
      -- inform the caller to maybe go and do something else a while.
      if NOT l_timeout then
         -- We now have a message as a CLOB. we need to parse it
         -- to reconstruct the DOM Document.
         -- new parser

         -- Grab the components of the notification to send
         -- back to the caller

         l_pos := 1;

         GetTagValue(l_message, 'NID', l_nid, l_pos, l_attrlist);
         GetTagValue(l_message, 'RECEIVERLIST', l_receiverlist, l_pos,
                     l_attrlist);
         GetTagValue(l_message, 'STATUS', l_status, l_pos, l_attrlist);

      end if;

      p_nid := to_number(l_nid);
      p_receiverlist := l_receiverlist;
      p_status := l_status;

      if l_timeout then
         p_timeout := 1;
      else
         p_timeout := 0;
      end if;

   exception
     when no_program_unit then
       wf_core.context('WF_XML', 'GetMessage', to_char(p_queue));
       raise;

     when others then
       -- First look for a wf_core error.
       wf_core.get_error(l_err_name, l_err_message, l_err_stack);

       -- If no wf_core error look for a sql error.
       if (l_err_name is null) then
           l_err_message := sqlerrm;
       end if;

       p_error_result := l_err_message;
       wf_core.context('WF_XML', 'GetMessage', to_char(p_queue));
       raise;

   end GetMessage;

   -- GetShortMessage - Get email message data
   -- IN
   --    Queue number to operate on
   -- OUT
   --    Notification ID
   --    Comma seperated list of the recipients of the notification
   --    Status of the notification - For the purpose of message templating
   --    Timout. Returns TRUE where the queue is empty.
   --    Error message
   procedure GetShortMessage(
       p_queue    in  number,
       p_nid          out NOCOPY number,
       p_recipient out NOCOPY varchar2,
       p_status      out NOCOPY varchar2,
       p_timeout      out NOCOPY integer,
       p_error_result in out NOCOPY varchar2)
   is

       l_queue_name varchar2(200);

      l_err_name      varchar2(30);
      l_err_message   varchar2(2000);
      l_err_stack     varchar2(4000);
      no_program_unit exception;
      pragma exception_init(no_program_unit, -6508);

   begin

      l_queue_name := g_wfSchema||'.WF_SMTP_O_'||
                      to_char(p_queue)||'_QUEUE';

      GetQueueMessage(l_queue_name, p_nid, p_recipient, p_status,
                      p_timeout, p_error_result);
   exception
     when no_program_unit then
       wf_core.context('WF_XML', 'GetShortMessage', to_char(p_queue));
       raise;

     when others then
       -- First look for a wf_core error.
       wf_core.get_error(l_err_name, l_err_message, l_err_stack);

       -- If no wf_core error look for a sql error.
       if (l_err_name is null) then
           l_err_message := sqlerrm;
       end if;

       p_error_result := l_err_message;
       wf_core.context('WF_XML', 'GetShortMessage', to_char(p_queue));
       raise;

   end GetShortMessage;


   -- GetExceptionMessage - Get email message data
   -- IN
   --    Queue number to operate on
   -- OUT
   --    Notification ID
   --    Comma seperated list of the recipients of the notification
   --    Status of the notification - For the purpose of message templating
   --    Timout. Returns TRUE where the queue is empty.
   --    Error message
   procedure GetExceptionMessage(
       p_queue    in  number,
       p_nid          out NOCOPY number,
       p_recipient out NOCOPY varchar2,
       p_status      out NOCOPY varchar2,
       p_timeout      out NOCOPY boolean,
       p_error_result in out NOCOPY varchar2)
   is
      l_timeout integer;
      l_queue_name varchar2(200);

      l_err_name      varchar2(30);
      l_err_message   varchar2(2000);
      l_err_stack     varchar2(4000);
      no_program_unit exception;
      pragma exception_init(no_program_unit, -6508);

   begin

      l_queue_name := wf_queue.enable_exception_queue(
                         g_wfSchema||
                         '.WF_SMTP_O_'||to_char(p_queue)||'_QUEUE');
      if l_queue_name is not NULL then
         GetQueueMessage(l_queue_name, p_nid, p_recipient, p_status,
                         l_timeout, p_error_result);
         -- GetQueueMessage returns timeout as an integer for the benefit
         if l_timeout = 0 then
            p_timeout := FALSE;
         else
            p_timeout := TRUE;
         end if;
      else
         p_timeout := TRUE;
      end if;

   exception
     when no_program_unit then
       wf_core.context('WF_XML', 'GetExceptionMessage', to_char(p_queue));
       raise;

     when others then
       -- First look for a wf_core error.
       wf_core.get_error(l_err_name, l_err_message, l_err_stack);

       -- If no wf_core error look for a sql error.
       if (l_err_name is null) then
           l_err_message := sqlerrm;
       end if;

       p_error_result := l_err_message;
       wf_core.context('WF_XML', 'GetExceptionMessage', to_char(p_queue));
       raise;

   end GetExceptionMessage;

   -- GetQueueMessage - Get email message data
   -- IN
   --    Queue name
   -- OUT
   --    Notification ID
   --    Comma seperated list of the recipients of the notification
   --    Status of the notification - For the purpose of message templating
   --    Timout. Returns TRUE where the queue is empty.
   --    Error message
   procedure GetQueueMessage(
       p_queuename    in  varchar2,
       p_nid          out NOCOPY number,
       p_recipient    out NOCOPY varchar2,
       p_status       out NOCOPY varchar2,
       p_timeout      out NOCOPY integer,
       p_error_result in out NOCOPY varchar2)
   is

      l_message CLOB;
      l_nid number;
      l_queue_name   varchar2(255);
      l_status       varchar2(8) := NULL;
      l_currstatus   varchar2(8);
      l_recipient WF_NOTIFICATIONS.RECIPIENT_ROLE%TYPE := NULL;
      l_attrlist wf_xml_attr_table_type;
      l_timeout BOOLEAN;
      l_pos integer;
      l_statusOK boolean;

      l_err_name      varchar2(30);
      l_err_message   varchar2(2000);
      l_err_stack     varchar2(4000);
      no_program_unit exception;
      pragma exception_init(no_program_unit, -6508);

   begin

      l_queue_name := p_queuename;

      -- Grab the next available message from the queue.
      -- The lob located will contain a reference to a persistent
      -- LOB so there is not need to pre-create a temporary LOB.
      loop
         DequeueMessage(p_queue_name => l_queue_name,
                        p_correlation => NULL,
                        p_message => l_message,
                        p_timeout => l_timeout);

         -- If the result is from the queue being empty then we want to
         -- inform the caller to maybe go and do something else a while.
         if NOT l_timeout then
            -- We now have a message as a CLOB. we need to parse it
            -- to reconstruct the DOM Document.
            -- new parser

            -- Grab the components of the notification to send
            -- back to the caller

            l_pos := 1;

            GetTagValue(l_message, 'NID', l_nid, l_pos, l_attrlist);
            GetTagValue(l_message, 'RECIPIENT', l_recipient, l_pos, l_attrlist);
            GetTagValue(l_message, 'STATUS', l_status, l_pos, l_attrlist);

            -- Verify that the status of the notification is
            -- still OK.
            begin
               select status into l_currstatus
               from wf_notifications
               where notification_id = l_nid
                  and status in ('OPEN','CANCELED', 'CLOSED')
                  and mail_status in ('MAIL','INVALID','FAILED');
               l_statusOK := TRUE;
            exception
               when no_data_found then
                  l_statusOK := FALSE;
               when others then raise;
            end;
         end if;
         exit when l_timeout or l_statusOK;
      end loop;
      p_nid := to_number(l_nid);
      p_recipient := l_recipient;
      p_status := l_status;

      if l_timeout then
         p_timeout := 1;
      else
         p_timeout := 0;
      end if;

   exception
     when no_program_unit then
       wf_core.context('WF_XML', 'GetQueueMessage', p_queuename);
       raise;

     when others then
       -- First look for a wf_core error.
       wf_core.get_error(l_err_name, l_err_message, l_err_stack);

       -- If no wf_core error look for a sql error.
       if (l_err_name is null) then
           l_err_message := sqlerrm;
       end if;

       p_error_result := l_err_message;
       wf_core.context('WF_XML', 'GetQueueMessage', p_queuename);
       raise;

   end GetQueueMessage;


   -- RemoveMessage
   --    To remove any messages associated with a particular Notification ID.
   --    Note that a notification can contain more than one message. Each of
   --    these messages will have a unique message handle and could be
   --    enqueued on more than one queue.
   -- IN
   --    Queue Name to remove the messages from
   --    Correlation or the Notification ID of the messages to remove.
   -- OUT
   --    Timeout. Returns TRUE if there was nothing on the Queue
   procedure RemoveMessage(p_queue_name in varchar2,
                           p_correlation in varchar2,
                           p_timeout out NOCOPY boolean)
   is
      l_dequeue_options dbms_aq.dequeue_options_t;
      l_message_properties dbms_aq.message_properties_t;
      l_correlation varchar2(255) := NULL;
      l_message_handle RAW(16);

   begin

      /** wf_message_payload_t is obsolete in 2.6.4 onwards **/
      null;

   exception
      when others then
       Wf_Core.Context('WF_XML', 'RemoveMessage', p_queue_name, p_correlation);
       p_timeout := FALSE;
       raise;
   end RemoveMessage;


   -- RemoveNotification
   --     To remove all enqueues messages for a given notification.
   -- IN
   --    Notification ID of the message to locate and remove.
   -- NOTE
   --    This is a destructive procedure that's sole purpose is to purge the
   --    message from the queue. We only call this when we do not care for the
   --    content.
   procedure RemoveNotification (p_nid in number)
   is
      l_protocol varchar2(10);
      l_iobound varchar2(10);
      l_queue_count integer;
      l_queue_name varchar2(100);
      l_wf_schema varchar2(320);
      l_timeout boolean;
   begin

      select protocol, inbound_outbound, queue_count
         into l_protocol, l_iobound, l_queue_count
      from wf_queues
         where protocol = 'SMTP'
           and INBOUND_OUTBOUND = 'OUTBOUND'
           and DISABLE_FLAG = 'N';

      -- Walk though ALL queue names to hunt for the notifications
      wf_queue.set_queue_names;
      l_wf_schema := g_wfSchema;
      for i in 1..l_queue_count loop
         -- Build the queue name from the information we know.
         l_queue_name := l_wf_schema||'.WF_'||l_protocol||'_'||
                         substr(l_iobound,1,1)||'_'||to_char(i)||'_QUEUE';
         l_timeout := FALSE;
         while not l_timeout loop
            -- Kill all traces of the message.
            RemoveMessage(l_queue_name, wf_queue.account_name||':'||
                          to_char(p_nid), l_timeout);
         end loop;
      end loop;
      -- Remove the messages from the default Exception queues also
      for i in 1..l_queue_count loop
         -- Build the queue name from the information we know.
         l_queue_name := wf_queue.enable_exception_queue('WF_'||l_protocol||
                         '_'||substr(l_iobound,1,1)||'_'||to_char(i)||'_QUEUE');
         if l_queue_name is not NULL then
            l_timeout := FALSE;
            while not l_timeout loop
               -- Kill all traces of the message.
               RemoveMessage(l_queue_name,  wf_queue.account_name||':'||
                             to_char(p_nid), l_timeout);
            end loop;
         end if;
      end loop;

   exception
      when others then
         wf_core.context('WF_XML','RemoveNotification',to_char(p_nid));
         raise;
   end RemoveNotification;


   -- setFistMessage
   --    To set the global variable g_first_message for the deqeuing
   --    of the SMTP queue.
   -- IN
   --    'Y' to set the flag to TRUE
   procedure setFirstMessage(p_first_message IN varchar2)
   is
   begin
      if (upper(substrb(p_first_message, 1, 1)) in ('Y','T')) then
         g_first_message := TRUE;
      else
         g_first_message := FALSE;
      end if;
   end;

   --
   -- getBodyPart
   --
   procedure getBodyPart(p_doc in out NOCOPY CLOB,
                         p_nid in number,
                         p_doctype in varchar2)
   is
      l_message varchar2(32000);
      l_doc_length number := 0;
      l_doc_end integer := 0;
      l_start VARCHAR2(10) := '<![CDATA[';
      l_end VARCHAR2(4) := ']]>';
   begin

      WF_MAIL.InitFetchLOB(p_doctype, l_doc_length);
      l_doc_end := 0;
      dbms_lob.writeAppend(p_doc, length(l_start), l_start);
      while l_doc_end = 0 loop
         WF_MAIL.FetchLobContent(l_message, p_doctype, l_doc_end);
         l_message := replace(l_message, g_fndapi_misschr);
         dbms_lob.writeAppend(p_doc, length(l_message), l_message);
      end loop;

      --  bug 8515763:
      --  Adding PostScript message for Hotmail, Yahoo and Rediff users here
      --  because if we want to add within WF_MAIL.GetMessageLob3 then new global
      --  variable or API have to introduce to communicate from one pkg to another pkg.
      if( g_WebMail_PostScript_Msg is not null ) then

        dbms_lob.writeAppend(p_doc,length(g_newLine), g_newLine);
        dbms_lob.writeAppend(p_doc, length(g_WebMail_PostScript_Msg),
                                           g_WebMail_PostScript_Msg);

        -- Nullify so that for MAILATTH users, this message should NOT apear in html BODY.
        g_WebMail_PostScript_Msg := null;
      end if;

      dbms_lob.writeAppend(p_doc, length(l_end), l_end);
      WF_MAIL.CloseLob(p_doctype);

   exception
      when others then
         wf_core.context('WF_XML','getBodyPart',to_char(p_nid),p_doctype);
         raise;
   end getBodyPart;


   procedure GetNLS(base_lang out NOCOPY varchar2, base_territory OUT NOCOPY VARCHAR2,
                    base_codeset OUT NOCOPY VARCHAR2)
   is
      nls_base varchar2(100);
      underscore_pos integer;
      dot_pos integer;

   begin
      select userenv('LANGUAGE')
      into nls_base
      from sys.dual;

      underscore_pos := instr(nls_base, '_');
      dot_pos := instr(nls_base, '.');

      base_lang := substr(nls_base, 1, underscore_pos -1);
      base_territory := substr(nls_base, underscore_pos +1,
                               (dot_pos - underscore_pos)-1);
      base_codeset := substr(nls_base, dot_pos + 1);


   exception
      when others then
         wf_core.context('WF_XML','GetNLS');
         raise;
   end getNLS;


   -- SetNLS
   -- To set the NLS lang and territory of the current session
   -- IN
   -- language - a varchar2 of the language code
   -- territory - a varchar2 of the territory code.
   procedure SetNLS(language in VARCHAR2, territory in VARCHAR2)
   is
      l_language varchar2(30);
      l_territory varchar2(30);
      l_installed_flag varchar2(1);
   begin
      begin
         -- If nothing is passed in, force it to AMERICAN_AMERICA
         if language is null or language = '' then
            l_language := 'AMERICAN';
         end if;
         if territory is null or territory = '' then
            l_territory := 'AMERICA';
         end if;

         select installed_flag
         into l_installed_flag
         from wf_languages
         where nls_language = language
           and installed_flag = 'Y';

         l_language := ''''||language||'''';
         l_territory := ''''||territory||'''';
      exception
         when others then
            l_language := 'AMERICAN';
            l_territory := 'AMERICA';
      end;

      if (wf_log_pkg.level_procedure >= fnd_log.g_current_runtime_level) then
         wf_log_pkg.string(WF_LOG_PKG.level_procedure,
                          'wf.plsql.WF_XML.SetNLS',
                          'Setting Language {'||l_language||'} {'||
                          l_territory||'} - Passed in {'||language||
                          '} {'||territory||'}');
      end if;

      dbms_session.set_nls('NLS_LANGUAGE'   , l_language);
      dbms_session.set_nls('NLS_TERRITORY'   , l_territory);
   exception
      when others then
         wf_core.context('WF_XML','SetNLS', language, territory);
         raise;
   end setNLS;

   -- Parse the p_doc for the URL attributes and edit
   -- their src= reference in preperation for email.
   function ParseForInlineImages(msgBody IN OUT NOCOPY CLOB,
                                nid IN number,
                                resourceList IN OUT NOCOPY resourceList_t)
       return boolean
   is

      imgStrPos number;
      value varchar2(32000);
      newValue varchar2(32000);
      origValue varchar2(4000);
      contentId varchar2(1000);

      tmpIdx pls_integer;
      nameStart pls_integer;
      nameEnd pls_integer;
      amount number;
      tmpLength number;

      imagesFound boolean := false;

      renderType varchar2(10);
      resourceIdx pls_integer;
      fileName varchar2(1000);
      contentType varchar2(200);
      extPos pls_integer;

   begin

      resourceIdx := 1;
      resourceList.DELETE;

      imagesFound := false;

      tmpIdx := wf_temp_lob.getLob(g_LOBTable);
      for url in g_urls(nid) loop
         value := url.text_value;
         value := wf_notification.SetFrameworkAgent(value);

         -- Check if there is a render type specification on the URL
         -- Remove it and set the renderType appropriately.
         renderType := substr(value, 1, 4);
         if(renderType in ('IMG:','LNK:')) then
            value := substr(value, 5);
         else
            renderType := null;
         end if;

         if isImageReference(value, renderType) then
            origValue := value;
            value := '<IMG SRC="'||value||
                     '" alt="'|| url.display_name||'"></IMG>';
            imgStrPos := dbms_lob.instr(msgBody, value, 1, 1);
            if imgStrPos > 0 then
               dbms_lob.trim(g_LOBTable(tmpIdx).temp_lob, 0);
               dbms_lob.copy(g_LOBTable(tmpIdx).temp_lob , msgBody,
                             imgStrPos-1, 1, 1);

               nameStart := instrb(origValue, '/', -1, 1);
               if nameStart = 0 then
                  contentId := trim(value);
                  fileName := contentId;
                  contentId := replace(contentId, '.');
               else
                  contentId := trim(substrb(origValue, nameStart+1 ));
                  fileName := contentId;
                  contentId := replace(contentId, '.');
               end if;
               contentId := contentID||'.'||trim(to_char(resourceIdx));

               extPos := instrb(fileName, '.', -1, 1);
               if (extPos > 0) then
                 contentType := 'image/'||substr(fileName, extPos+1);
               else
                  contentType := 'image/*';
               end if;

               newValue := '<IMG SRC="cid:'||contentId||
                     '" alt="'|| url.display_name||
                     '"></IMG>';

               dbms_lob.writeAppend(g_LOBTable(tmpIdx).temp_lob,
                                    length(newValue), newValue);
               amount :=  dbms_lob.getlength(msgBody)-imgStrPos+length(value);
               tmpLength :=  dbms_lob.getlength(g_LOBTable(tmpIdx).temp_lob);
               dbms_lob.Copy(g_LOBTable(tmpIdx).temp_lob, msgBody, amount,
                             tmpLength+1, imgStrPos+length(value));
               dbms_lob.trim(msgBody, 0);
               dbms_lob.append(msgBody, g_LOBTable(tmpIdx).temp_lob);

               imagesFound := TRUE;
               resourceList(resourceIdx).value := origValue;
               resourceList(resourceIdx).contentId := contentId;
               resourceList(resourceIdx).fileName := fileName;
               resourceList(resourceIdx).contentType := contentType;
               resourceIdx := resourceIdx + 1;
            end if; -- Image TAG is in the messages body
         end if;    -- The URL is an image reference
      end loop;

      wf_temp_lob.releaseLob(g_LOBTable, tmpIdx);

      return imagesFound;
   exception
      when others then
         -- Release temp LOB if any error , bug 6511028
         wf_temp_lob.releaseLob(g_LOBTable, tmpIdx);

         wf_core.context('WF_XML','ParseForInlineImages',to_char(nid));
         raise;
   end ParseForInlineImages;

   -- Adds the RESOURCE tags for the inline images.
  procedure addInlineImages(doc IN OUT NOCOPY CLOB,
                            pos IN OUT NOCOPY number,
                            attrlist IN OUT NOCOPY wf_xml_attr_table_type,
                            nid IN number,
                            disposition in varchar2,
                            resourceList in resourceList_t)
   is
      extPos pls_integer;
      contentType varchar2(1000);
      value varchar2(32000);
      encodedURL varchar2(32000);
      nameStart pls_integer;
      contentId varchar2(1000);
      fileName varchar2(1000);
      occurance number := 1;

      renderType varchar2(10);

   begin
      attrlist.DELETE;

      for resourceIdx in 1..resourceList.COUNT loop

         encodedURL := wf_mail.urlEncode(resourceList(resourceIdx).value);
         AddElementAttribute('content-type', resourceList(resourceIdx).contentType, attrlist);
         AddElementAttribute('src', resourceList(resourceIdx).value, attrlist);
         AddElementAttribute('content-id', resourceList(resourceIdx).contentId, attrlist);
         AddElementAttribute('filename', resourceList(resourceIdx).fileName, attrlist);
         AddElementAttribute('content-disposition', disposition, attrlist);

         pos := NewLOBTag(doc, pos, 'RESOURCE','',attrlist);
         pos := SkipLOBTag(doc, 'RESOURCE', pos, occurance);
         attrlist.DELETE;

      end loop;

   exception
      when others then
         wf_core.context('WF_XML','addInlineImages', to_char(nid));
         raise;
   end addInlineImages;


   -- Adds a recipient element to the XML in p_doc at position p_pos.
   --
   -- p_doc The XML document to receive the RECIPIENT element
   -- p_role The WF_ROLE name of the recipient
   -- p_type The type of recipient - to, cc or bcc
   -- p_name The display name for the recipient
   -- p_email The email address for the recipient
   -- p_pos The position at which the element should be added.

   procedure addRecipient(p_doc in out nocopy varchar2,
                          p_role in varchar2,
                          p_type in varchar2,
                          p_name in varchar2,
                          p_email in varchar2,
                          p_pos in out nocopy number)
   is
      display_name varchar2(360);
      email varchar2(320);

      attrlist        wf_xml_attr_table_type;
      occurance integer := 1;

   begin
      AddElementAttribute('name', p_role, attrlist);
      AddElementAttribute('type', p_type, attrlist);
      p_pos := NewTag(p_doc, p_pos, 'RECIPIENT', '', attrlist);
      attrlist.DELETE;
      if (p_name is not null or p_name <> '') then
         display_name := replace(p_name, g_newLine);
         display_name := '<![CDATA['||display_name||']]>';
      else
         display_name := '';
      end if;
      p_pos := NewTag(p_doc, p_pos, 'NAME', display_name, attrlist);
      p_pos := SkipTag(p_doc, 'NAME', p_pos, occurance);

      email := replace(p_email, g_newLine);
      --Bug 27299652:Remove Carriage Return from email address
      email := replace(p_email, g_carriageReturn);
      email := '<![CDATA['||email||']]>';
      p_pos := NewTag(p_doc, p_pos, 'ADDRESS', email, attrlist);
      p_pos := SkipTag(p_doc, 'ADDRESS', p_pos, occurance);

      p_pos := SkipTag(p_doc, 'RECIPIENT', p_pos, occurance);
   end;

   -- Adds the recipients identified in p_list to the XML document
   -- provided in p_doc. This is a helper procedure for the processing
   -- of CC and BCC recipients.
   -- p_doc The XML Header document to be modified
   -- p_list the semicolon list of recipients
   -- p_type The type of recipient to set ("cc" or "bcc").
   -- p_pos The current pos in the p_doc to add the recipients. This
   --       value will be updated after completion to the current update point.

   procedure  addCopyRecipients(p_doc in out nocopy varchar2,
                                p_list in varchar2,
                                p_type in varchar2,
                                p_pos in out nocopy integer)
   is
      copy_recipient_list WF_MAIL_UTIL.parserStack_t;
      atPos pls_integer;

      display_name varchar2(360);
      recipient_role varchar2(320);
      email varchar2(320);
      pref varchar2(8);
      dummy varchar2(1000);
      dummy_number number;
      orig_system varchar2(30);
      orig_system_id number;

      cursor members(rname varchar2, rorig varchar2, rorigid number) is
         select UR.USER_NAME, UR.USER_ORIG_SYSTEM, UR.USER_ORIG_SYSTEM_ID
                from   WF_USER_ROLES UR
                where  UR.ROLE_NAME = rname
                  and    UR.ROLE_ORIG_SYSTEM = rorig
                  and    UR.ROLE_ORIG_SYSTEM_ID = rorigid
                  and    ((UR.USER_NAME <> UR.ROLE_NAME) or
                          (UR.USER_ORIG_SYSTEM <> UR.ROLE_ORIG_SYSTEM  and
                           UR.USER_ORIG_SYSTEM_ID <> UR.ROLE_ORIG_SYSTEM_ID));

      step varchar2(200);

   begin
      step := 'Initializing the copy list';
      copy_recipient_list.DELETE;
      copy_recipient_list := WF_MAIL_UTIL.strParser(p_list, ';');
      if (copy_recipient_list.COUNT > 0) then

         for i in 1..copy_recipient_list.COUNT loop

            step := 'Processing {'||copy_recipient_list(i)||'}';
            atPos := instrb(copy_recipient_list(i), '@', 1);
            if (atPos > 0) then
               step := 'Processing email address {'||
                       copy_recipient_list(i)||'}';
               addRecipient(p_doc => p_doc, p_role => '', p_type => p_type,
                            p_name => '', p_email => copy_recipient_list(i),
                            p_pos => p_pos);

            else

               step := 'Processing role {'||copy_recipient_list(i)||'}';

               -- Get the qualified email address but the other details
               -- are not needed.
               WF_DIRECTORY.GetRoleInfoMail(role => copy_recipient_list(i),
                                            display_name => display_name,
                                            email_address => email,
                                            notification_preference => pref,
                                            language => dummy,
                                            territory => dummy,
                                            orig_system => orig_system,
                                            orig_system_id => orig_system_id,
                                            installed_flag => dummy);
               if (email is not null and pref <> 'DISABLED') then
                  step := 'Adding role {'||copy_recipient_list(i)||
                          '} details to the document';
                  recipient_role := EncodeEntityReference(copy_recipient_list(i));
                  addRecipient(p_doc => p_doc,
                               p_role => recipient_role,
                               p_type => p_type,
                               p_name => display_name,
                               p_email => email,
                               p_pos => p_pos);

                elsif (display_name is not null) then

                   -- A null email address implies a role with members.

                   -- Recursion *could* be used here to build a list of
                   -- single memeber roles and then call the addCopyRecipients
                   -- to build the XML. Since there is no control then on
                   -- cyclic references, we will traverse the list only
                   -- at one level.
                   for r in members(copy_recipient_list(i), orig_system,
                                    orig_system_id) loop

                      step := 'Getting member role '||r.user_name||
                              'details to the document';
                      WF_DIRECTORY.GetRoleInfoMail(role => r.user_name,
                                            display_name => display_name,
                                            email_address => email,
                                            notification_preference => pref,
                                            language => dummy,
                                            territory => dummy,
                                            orig_system => dummy,
                                            orig_system_id => dummy_number,
                                            installed_flag => dummy);

                      if (email is not null and pref <> 'DISABLED') then
                         step := 'Adding member role {'||r.user_name||
                                 '} details to the document';
                         recipient_role := EncodeEntityReference(r.user_name);
                         addRecipient(p_doc => p_doc,
                                      p_role => recipient_role,
                                      p_type => p_type,
                                      p_name => display_name,
                                      p_email => email,
                                      p_pos => p_pos);
                      end if;
                   end loop; -- Memebers
                end if; -- role with members
            end if; -- Processing a role
         end loop;
      end if;
   exception
      when others then
         wf_core.context('WF_XML','addCopyRecipients', p_list, p_type,
                         step);
   end addCopyRecipients;


  -- Sets the response template delimiters for HTML messages.
  --
  -- The delimiter string, rather than containing a set of delimiters
  -- to use will contain a code that maps to the delimiters to use.
  -- This is to avoid confusion on what this value can be set to and
  -- simplifies the parsing of the string.
  --
  -- Allowable Values:
  --
  --   DEFAULT or blank - Use the hard coded defaults
  --   APOS             - '
  --   QUOTE            - "
  --   BRACKET          - [ ]
  -- IN
  -- delimiter_string - The code that represents the HTML delimiters
  --                    to use.
  --
  procedure setHtmlDelimiters(delimiter_string IN VARCHAR2)
  is
     open_html_delimiter VARCHAR2(8);
     close_html_delimiter VARCHAR2(8);
  begin

      if delimiter_string = 'DEFAULT' or delimiter_string is null then
         -- No delimiters, then use the hard coded defaults.
         open_html_delimiter := null;
         close_html_delimiter := null;
      elsif delimiter_string = 'APOS' then
         open_html_delimiter := '''';
         close_html_delimiter := '''';
      elsif delimiter_string = 'QUOTE' then
         open_html_delimiter := '"';
         close_html_delimiter := '"';
      elsif delimiter_string = 'BRACKET' then
         open_html_delimiter := '[';
         close_html_delimiter := ']';
      else
         -- Unable to recognize the value, so use the hard coded default.
         open_html_delimiter := null;
         close_html_delimiter := null;
      end if;



      wf_mail.SetResponseDelimiters(open_text => null,
                                    close_text => null,
                                    open_html => open_html_delimiter,
                                    close_html => close_html_delimiter);

  end setHtmlDelimiters;


   -- GenerateEmptyDoc (private)
   -- This procedure creates an empty XML document that is needed in different
   -- scenarios where an empty XML document is required but no e-mail notification
   -- is to be sent.
   -- IN OUT
   --   p_doc: CLOB containing the notification body
   -- IN
   --   p_nid: the notification Id being processed
   --   p_reason: the reason why the document is empty, e-mail is not being sent

   procedure GenerateEmptyDoc(p_nid number, p_pos number, p_doc IN OUT NOCOPY CLOB,
                              p_reason IN VARCHAR2, p_group BOOLEAN) is
     l_attrlist wf_xml_attr_table_type;
     l_occurance integer;
     str varchar2 (2000);
     l_pos number;

   begin

     -- Bug 13716905: added the parameter p_pos also which will be used in the
     -- call to NewLOBTag() if the p_group value is false
     l_pos := p_pos;

     -- 4104735 Empty documents now provide a document type and
     -- if a empty document, must provide a reason.
     -- <<sstomar>>: Not changing default Lang. territory settings:
     if p_group then
       str := '<?xml version="1.0" ?>';
       l_pos := length(str);
       dbms_lob.write(p_doc, l_pos, 1, str);
       AddElementAttribute('maxcount','1', l_attrlist);
       l_pos := NewLOBTag(p_doc, l_pos, 'NOTIFICATIONGROUP', '', l_attrlist);
       l_attrlist.DELETE;
     end if;

     AddElementAttribute('nid', p_nid, l_attrlist);
     AddElementAttribute('language', 'AMERICAN', l_attrlist);
     AddElementAttribute('territory', 'AMERICA', l_attrlist);
     AddElementAttribute('codeset', 'UTF8', l_attrlist);

     -- Added below default base parameters.
     AddElementAttribute('nlsDateformat', wf_core.nls_date_format, l_attrlist);
     AddElementAttribute('nlsDateLanguage', wf_core.nls_date_language, l_attrlist);
     AddElementAttribute('nlsNumericCharacters', wf_core.nls_numeric_characters, l_attrlist);
     AddElementAttribute('nlsSort', wf_core.nls_sort, l_attrlist);

     AddElementAttribute('full-document', 'N', l_attrlist);
     AddElementAttribute('reason', p_reason, l_attrlist);
     l_pos := NewLOBTag(p_doc, l_pos, 'NOTIFICATION', '', l_attrlist);
     l_attrlist.DELETE;
     if NOT p_group then
       l_pos := SkipLOBTag(p_doc, 'NOTIFICATION', l_pos, l_occurance);
     end if;
   end GenerateEmptyDoc;

   --
   -- GenerateDoc
   -- To generate the XML content for the enqueued notifications.
   procedure GenerateDoc (p_doc in out NOCOPY CLOB,
                          p_pos in out NOCOPY number,
                          p_recipient_role in varchar2,
                          p_event_name in varchar2,
                          p_event_key in varchar2,
                          p_parameter_list in wf_parameter_list_t)
   is
      -- message CLOB;
      l_sec_policy   varchar2(100);
      t_name         varchar2(100);
      messageIdx pls_integer;
      nid NUMBER;
      msgbody VARCHAR2(32000);
      end_of_msgbody BOOLEAN;
      doctype VARCHAR2(100);

      pos integer;
      amt number;
      installed VARCHAR2(1);

      orig_system VARCHAR2(100);
      orig_system_id number;

      -- <<sstomar> : nls parameters, l_nlsCurrency can be removed once
      --      it being removed from WFDS APIs
      l_nlsDateFormat        VARCHAR2(120);
      l_nlsDateLanguage      varchar2(120);
      l_nlsCalendar          varchar2(120);
      l_nlsNumericCharacters varchar2(30);
      l_nlsSort              varchar2(120);
      l_nlsLanguage          wf_roles.language%TYPE;
      l_nlsTerritory         wf_roles.territory%TYPE;
      l_nlsCodeset              VARCHAR2(30);

      --
      l_nlsCurrency      VARCHAR2(30);

      -- whether context has been changes or not.
      l_context_changed      BOOLEAN := false;

      nidStr varchar2(100);
      hdrxml varchar2(32000);
      hdrxmlPos integer;

      access_key VARCHAR2(100);
      priority NUMBER;
      recipient_role wf_roles.name%TYPE;
      status VARCHAR2(100);
      subject VARCHAR2(4000);

      role  wf_roles.name%TYPE;
      display_name wf_roles.display_name%TYPE;
      email wf_roles.email_address%TYPE;
      notification_pref wf_roles.notification_preference%TYPE;

      occurance       integer := 1;
      attrlist        wf_xml_attr_table_type;
      str             varchar2 (250);
      nodeName        varchar2(100) := '#NODE';
      agent           varchar2(100) := '#AGENT';
      replyto         varchar2(100) := '#REPLYTO';
      fromName        varchar2(100) := '#FROM';
      disposition     varchar2(100) := '#DISPOSITION';
      directResponse  varchar2(1);
      emailParser     varchar2(100);
      corrId          varchar2(128);
      htmlfilename    varchar2(100);
      urlfilename     varchar2(100);
      inlineAtt       varchar2(10);
      sendAccessKey   varchar2(10);
      stylesheetEnabled varchar2(10);
      body_atth       varchar2 (32000);
      messageType     varchar2(8);
      messageName     varchar2(30);
      error_result    varchar2 (2000);
      err_name        varchar2 (30);
      err_message     varchar2 (2000);
      err_stack       varchar2 (4000);
      moreInfoRole    varchar2(320);

      frameworkContent boolean;
      attachInlineImages varchar2(1);

      ntfURL          varchar2(2000);
      imgFound        boolean;

      bodyToken       varchar2(1);

      FromInAttr varchar2(1);
      ReplyToInAttr varchar2(1);
      EnableStyleInAttr varchar2(1);
      dummy varchar2(10);

      cc_list varchar2(4000);
      bcc_list varchar2(4000);

      delimiter_string VARCHAR2(8);

      resourceList resourceList_t;

      -- For WebBased users, notification pref. will be Overridden.
      -- as hotmail, yahoo and Rediff do not support html response.
      l_ntfPref_Overridden BOOLEAN := false;

      response_key wf_notification_attributes.text_value%TYPE;

   begin

      if (wf_log_pkg.level_procedure >= fnd_log.g_current_runtime_level) then
         wf_log_pkg.string(WF_LOG_PKG.level_procedure,
                          'wf.plsql.WF_XML.generateDoc', 'BEGIN');
      end if;

      nid := to_number(p_event_key);

      -- retrive base nls parameters
      -- Get the Base NLS.
      -- 4743123 Only set the value of base NLS params once in a session.
      -- <<sstomar>>: already being set in GENERATE function,

      -- Obtain notification information
      begin -- 3741599 no_data_found should exit gracefully.
         select ACCESS_KEY, PRIORITY, STATUS, MESSAGE_TYPE,
                MESSAGE_NAME, MORE_INFO_ROLE
         into access_key, priority, status, messageType,
              messageName, moreInfoRole
         from WF_NOTIFICATIONS
         where  NOTIFICATION_ID = nid;
      exception
         when no_data_found then
           GenerateEmptyDoc(nid, p_pos, p_doc, 'no_data_found', FALSE);
           return;
         when others then
            wf_core.context('WF_XML','GenerateDoc',to_char(nid));
            raise;
      end;

      recipient_role := p_recipient_role;

      -- <<sstomar>> :
      -- Obtain recipient's NLS information by using new API
      WF_DIRECTORY.GetRoleInfoMail2(recipient_role, display_name, email,
                                    notification_pref,
                                    orig_system,
                                    orig_system_id,
                                    installed,
                                    l_nlsLanguage ,
                                    l_nlsTerritory ,
                                    l_nlsDateFormat ,
                                    l_nlsDateLanguage ,
                                    l_nlsCalendar ,
                                    l_nlsNumericCharacters ,
                                    l_nlsSort ,
                                    l_nlsCurrency );


      if notification_pref in ('QUERY', 'SUMMARY','SUMHTML', 'DISABLED')
         or email is null then
        GenerateEmptyDoc(nid, p_pos, p_doc, 'NOTIFICATION_PREFERENCE:'||notification_pref, FALSE);
        return;
      end if;



      corrId := wf_event.getValueForParameter('Q_CORRELATION_ID',
                                              p_parameter_list);
      -- Obtain the values for the configurable items
      nodename := WF_MAILER_PARAMETER.GetValueForCorr (pNid => nid,
                                                       pCorrId => corrId,
                                                       pName => 'NODENAME',
                                                       pInAttr => dummy);

      agent := WF_MAILER_PARAMETER.GetValueForCorr (pNid => nid,
                                                       pCorrId => corrId,
                                                    pName => 'HTMLAGENT',
                                                      pInAttr => dummy);

      fromName := WF_MAILER_PARAMETER.GetValueForCorr (pNid => nid,
                                                       pCorrId => corrId,
                                                       pName => 'FROM',
                                                       pInAttr => FromInAttr);

      replyto := WF_MAILER_PARAMETER.GetValueForCorr (pNid => nid,
                                                       pCorrId => corrId,
                                                      pName => 'REPLYTO',
                                                      pInAttr => ReplyToInAttr);

      inlineAtt := WF_MAILER_PARAMETER.GetValueForCorr (pNid => nid,
                                               pCorrId => corrId,
                                               pName => 'INLINE_ATTACHMENT',
                                               pInAttr => dummy);

      sendAccessKey := WF_MAILER_PARAMETER.GetValueForCorr (pNid => nid,
                                                pCorrId => corrId,
                                                pName => 'SEND_ACCESS_KEY',
                                                pInAttr => dummy);

      stylesheetEnabled := wf_mailer_parameter.getValueForCorr(pNid => nid,
                                                pCorrId => corrId,
                                                pName => 'ENABLE_STYLESHEET',
                                                pInAttr => EnableStyleInAttr);

      -- 5393647 - Parameter to control the text/html response
      --           template delimiter
      delimiter_string := wf_mailer_parameter.getValueForCorr(pNId => nid,
                                             pCorrId => corrId,
                                             pName => 'HTML_DELIMITER',
                                             pInAttr => dummy);

      setHtmlDelimiters(upper(trim(delimiter_string)));

      -- 4676402 Support for CC and BCC. These are not configuration parameters
      -- so the values can not be retrieved through the wf_mailer_parameter
      -- interface.
      -- The precedence will be only for normal notifications. Requests
      -- for more information will not be subject to the cc and bcc
      -- handling.
      --  moreInfoRole is null : either FIRST_SEND or wf.notification.answer event.
      if (moreInfoRole is null) then
         begin
            cc_list := upper(Wf_Notification.GetAttrText(nid, '#WFM_CC'));
         exception
           when others then
             if (wf_core.error_name = 'WFNTF_ATTR') then
               wf_core.clear();
              cc_list := null;
             else
               raise;
             end if;
         end;

         begin
            bcc_list := upper(Wf_Notification.GetAttrText(nid, '#WFM_BCC'));
         exception
           when others then
             if (wf_core.error_name = 'WFNTF_ATTR') then
               wf_core.clear();
              bcc_list := null;
             else
               raise;
             end if;
         end;
      end if;
      -- Direct Response is not reconfigurable through the message attributes
      -- Use the standard API to obtain its value.
      -- They are not configurable at the message level because of the
      -- confusion caused with multiple mailers and especially those that
      -- share the same correlation ID. The value must be consisten in the
      -- PL/SQL layer as well as the Java layer.
      directResponse := WF_MAILER_PARAMETER.getValueForCorr(pCorrId => corrId,
                                                pName => 'DIRECT_RESPONSE');

      attachInlineImages := WF_MAILER_PARAMETER.GetValueForCorr (
                                                pCorrId => corrId,
                                                pName => 'ATTACH_IMAGES');
      if inlineAtt = 'Y' then
         disposition := 'inline';
      else
         disposition := 'attachment';
      end if;

      if sendAccessKey = 'Y' then
         wf_mail.Send_Access_Key_On;
      else
         wf_mail.Send_Access_Key_Off;
      end if;

      if directResponse = 'Y' then
         wf_mail.direct_response_on;
      else
         wf_mail.direct_response_off;
      end if;

      -- If we are here, we are going to generate  notification xml payload
      -- So allocate TEMP LOB now. << bug 6511028 >>
      messageIdx := wf_temp_lob.getLob(g_LOBTable);

      WF_MAIL.setContext(nid);

      --  bugs:8515763,17477210 : Temporary workaround for HOTMAIL, Yahoo and Rediff web client users.
      --  list of domains here.

      g_WebMail_PostScript_Msg := null;

      if (notification_pref = 'MAILHTML'  OR notification_pref = 'MAILHTM2') then
        if (instr (upper(email), '@HOTMAIL.') > 0  or
            instr(upper(email), '@LIVE.')   > 0    or
            -- yahoo.com, yahoo.co.in
            instr(upper(email), '@YAHOO.')         > 0   or
            instr(upper(email), '@YMAIL.COM')      > 0   or
            instr(upper(email), '@ROCKETMAIL.COM') > 0   or

	    -- rediff mail
	    instr(upper(email), '@REDIFF.COM')     > 0   or
	    instr(upper(email), '@REDIFFMAIL.COM') > 0

          ) then

          -- override pref. EXCEPT FYI notification,
          if ( WF_Notification.isFYI(nid) = false ) then
            -- Overrided ntf pref.
            notification_pref := 'MAILATTH';
            -- Use this variable to set PostScript message after NLS Context is set.
            l_ntfPref_Overridden := true;
          end if;
        end if; -- end of domain check
      end if;
      -- bug 8515763 --

      -- Set the preferred document type based on the notification preference.
      -- This variable doctype will be used when generating ATTACHMENTs as
      -- for MAILATTH type will have "Notification Detail.htm" +  attachment,if any.
      if notification_pref = 'MAILTEXT' then
         doctype := g_ntfDocText;
      elsif notification_pref in ('MAILHTML','MAILATTH','MAILHTM2') then
         doctype := g_ntfDocHtml;
      end if;

      -- bug 5456241 : Passing doctype parameter
      if (WF_NOTIFICATION.isFwkRegion(nid, doctype)='Y' and
          g_install ='EMBEDDED') then

          frameworkContent := TRUE;
          -- 3803327 Text email with framework is currently disabled
          -- until the issues with the region facet for text can be
          -- fixed.
          -- if (notification_pref = 'MAILTEXT') then
          --    notification_pref := 'MAILHTM2';
          -- elsif (notification_pref = 'MAILATTH') then
          --    notification_pref := 'MAILHTML';
          -- end if;
          -- 3803327 end.
      else
         frameworkContent := FALSE;
      end if;

      -- Get the language, territory and codeset for this notification
      -- If #WFM_* not defined or not installd, then user's language will be used
      -- If user's language also not installed then below API updates OUT params
      -- with base language, territory and charset etc..
      --
      -- TODO : Get_Ntf_Language : optimization required.
      WF_MAIL.Get_Ntf_Language(nid, l_nlsLanguage, l_nlsTerritory, l_nlsCodeset);

      -- Set NLS language and territory for this notification
      if (wf_log_pkg.level_procedure >= fnd_log.g_current_runtime_level) then
         wf_log_pkg.string(WF_LOG_PKG.level_procedure,
                           'wf.plsql.WF_XML.generateDoc',
                           'Setting User NLS {'|| l_nlsLanguage ||'} {'||l_nlsTerritory||'}'
                           || l_nlsDateFormat || '} {' || l_nlsDateLanguage  || '} {'
                           || '} {' || l_nlsCalendar || '} {' || l_nlsNumericCharacters
                           || '} {' || l_nlsSort || '}');
      end if;

      -- set user's language and territory : charset we can not chage for a session at DB layer.
      -- setNLS(l_nlsLanguage, l_nlsTerritory);

      -- Bug 11684796: Comparing user NLS parameters with the NLS parameters in WF_NOTIFICATION_UTIL
      -- package as WF_NOTIFICATION_UTIL.SetNLSContext() API sets these parameter values only
      if( ( WF_NOTIFICATION_UTIL.g_nls_language is null or
                  nvl(l_nlsLanguage, 'AMERICAN') <> WF_NOTIFICATION_UTIL.g_nls_language) or
          ( WF_NOTIFICATION_UTIL.g_nls_territory is null or
              nvl( l_nlsTerritory, 'AMERICA') <> WF_NOTIFICATION_UTIL.g_nls_territory) or
          ( WF_NOTIFICATION_UTIL.g_nls_date_format is null or
              nvl(l_nlsDateFormat , wf_core.nls_date_format) <> WF_NOTIFICATION_UTIL.g_nls_date_format)   or
          ( WF_NOTIFICATION_UTIL.g_nls_Date_Language is null or
              nvl(l_nlsDateLanguage, wf_core.nls_date_language) <> WF_NOTIFICATION_UTIL.g_nls_Date_Language) or
          ( WF_NOTIFICATION_UTIL.g_nls_Numeric_Characters is null or
              nvl(l_nlsNumericCharacters, wf_core.nls_numeric_characters) <> WF_NOTIFICATION_UTIL.g_nls_Numeric_Characters) or
          ( WF_NOTIFICATION_UTIL.g_nls_Sort is null or
              nvl(l_nlsSort,  wf_core.nls_sort)  <> WF_NOTIFICATION_UTIL.g_nls_Sort)  ) then

          -- nid, l_nlsCalendar, just set here only.
          -- at other places pass value as null.
          WF_NOTIFICATION_UTIL.SetNLSContext(nid,
                          l_nlsLanguage  ,
                          l_nlsTerritory ,
                          l_nlsDateFormat ,
                          l_nlsDateLanguage ,
                          l_nlsNumericCharacters ,
                          l_nlsSort ,
                          l_nlsCalendar );

          l_context_changed := true;
      else

         -- No need to SET context but set NID, Calendar as these two parameters
         -- are being used in WF_NOTIFICATION_UTIL.GetCalendarDate
         WF_NOTIFICATION_UTIL.setCurrentNID(nid);
         WF_NOTIFICATION_UTIL.setCurrentCalendar(l_nlsCalendar);

      END if;

      -- bug 8515763
      if(l_ntfPref_Overridden) then
        -- Assign value, so it can be checked in getBodyPart( ) API and
        -- Nullify in same API so subsequeuent call of getBodyPart( ) will not add.
        g_WebMail_PostScript_Msg := wf_core.translate('WF_WEBMAIL_POSTSCRIPT_MSG');
      end if;


      -- Initialise the XML Document and then progressively walk
      -- through the elements. Populating them as we go.
      -- l_pos is crucial as it determines where the next nodes
      -- will be placed.
      pos := p_pos;

      if frameworkContent = TRUE then
         -- Get a modified version of the message. All is rendered
         -- except for the &BODY token.
         -- NOTE: TEMP LOBs allocated within WF_MAIL.GetLobMessage4 for
         --       message body contents should be released here
         --       after processsing
     -- Bug 10202313: propagating g_status, g_mstatus values to
     -- WF_MAIL.GetLOBMessage4() API as these values may update in the meantime
         WF_MAIL.GetLobMessage4(nid, nodeName, agent, replyto,
                               recipient_role, l_nlsLanguage, l_nlsTerritory,
                               notification_pref, email,
                               display_name,
                               'N',
                               subject, body_atth,
                               error_result, bodyToken,
                   g_status, g_mstatus);

      else
         -- Bug 10202313: propagating g_status, g_mstatus values to
     -- WF_MAIL.GetLOBMessage4() API as these values may update in the meantime
         WF_MAIL.GetLobMessage4(nid, nodeName, agent, replyto,
                               recipient_role, l_nlsLanguage, l_nlsTerritory,
                               notification_pref, email,
                               display_name,
                               'Y',
                               subject, body_atth,
                               error_result, bodyToken,
                   g_status, g_mstatus);

      end if;

      if error_result is not null or error_result <> '' then
         wf_core.token('ERROR',error_result);
         wf_core.raise('WFMLR_GENERATE_FAILED');
      end if;

      g_htmlmessage := wf_core.translate('WF_HTML_MESSAGE');
      g_urlNotification := wf_core.translate('WF_URL_NOTIFICATION');
      g_urlListAttachment := wf_core.translate('WF_URLLIST_ATTACHMENT');

      -- Reset base NLS settings
      if (wf_log_pkg.level_procedure >= fnd_log.g_current_runtime_level) then
         wf_log_pkg.string(WF_LOG_PKG.level_procedure,
                           'wf.plsql.WF_XML.generateDoc',
                           'Re-Setting Base NLS {'|| g_base_language ||'} {'||g_base_territory||'}'
                           || g_base_nlsDateFormat || '} {' || g_base_nlsDateLanguage  || '} {'
                           || '} {' || g_base_nlsCalendar || '} {' || g_base_nlsNumericCharacters
                           || '} {' || g_base_nlsSort  || '}');
      end if;


      -- RESET base setting so that all XML generation
      -- processing would be in DEFAULT settings
      -- << sstomar>> :  RESETTING for base NLS can be done once ..
      --      after generating XML Payload but problem may be that
      --      Mailer which runs on default NLS may not be able to parse payload??
      --    TODO : need to check above case.
      if(l_context_changed ) then

         -- set nid, calendar once only.
         -- <<bug 8220816>> : keep WF_NOTIFICATION_UTIL.g_nid and g_calendar in global variable
         -- during life-life cycle of this API.
         WF_NOTIFICATION_UTIL.SetNLSContext(
                                 nid,
                                 g_base_language        ,
                                 g_base_territory       ,
                                 g_base_nlsDateFormat    ,
                                 g_base_nlsDateLanguage    ,
                                 g_base_nlsNumericCharacters ,
                                 g_base_nlsSort ,
                                 g_base_nlsCalendar  );

      end if;

      htmlfilename := g_htmlmessage||'.html';
      urlfilename  := g_urlNotification||'.html';

      --ER 29631318: Get the notification attribute #RESPONSE_KEY value and add it in NID string
      --Bug 30216836: If '#RESPONSE_KEY' exists use it, else use the access_key
      begin
       	select text_value
       	into response_key
       	from wf_notification_attributes
       	where notification_id = nid
       	and   name = '#RESPONSE_KEY';
      exception
         when no_data_found then
         response_key := access_key;
      end;
      nidStr := 'NID['||to_char(nid)||'/'||response_key||'@'||nodeName||']';
      if directResponse = 'Y' then
         nidStr := nidStr||'[2]';
      end if;

      AddElementAttribute('nid', p_event_key, attrlist);
      AddElementAttribute('nidstr', nidStr, attrlist);

      AddElementAttribute('language', l_nlsLanguage, attrlist);
      AddElementAttribute('territory', l_nlsTerritory, attrlist);
      AddElementAttribute('codeset', l_nlsCodeset, attrlist);
      --
      -- <<sstomar>> : NLS changes, bug 7578922
      AddElementAttribute('nlsDateformat', l_nlsDateFormat, attrlist);

      -- << REMOVE validation later> we can validate if date_language is installed or not.
      if(WF_NOTIFICATION_UTIL.isLanguageInstalled(l_nlsDateLanguage)) then
        AddElementAttribute('nlsDateLanguage', l_nlsDateLanguage, attrlist);
      else
        AddElementAttribute('nlsDateLanguage', l_nlsLanguage, attrlist);
      end if;

      AddElementAttribute('nlsNumericCharacters', l_nlsNumericCharacters, attrlist);
      AddElementAttribute('nlsSort', l_nlsSort, attrlist);

      AddElementAttribute('priority', to_char(priority), attrlist);
      AddElementAttribute('item_type', messageType, attrlist);
      AddElementAttribute('message_name', messageName, attrlist);
      AddElementAttribute('full-document', 'Y', attrlist);

      pos := NewLOBTag(p_doc, pos, 'NOTIFICATION', '', attrlist);
      attrlist.DELETE;

      hdrxmlPos := 0;
      hdrxml := '';

      hdrxmlPos := NewTag(hdrxml, hdrxmlPos, 'RECIPIENTLIST', '', attrlist);

      -- 4676402 Adding support for CC and BCC. The recipients are
      -- straight email addresses in a semi-colon seperated list.
      -- Commas should not be used as delimiters as they can appear in the
      -- email address.

      recipient_role := EncodeEntityReference(recipient_role);
      addRecipient(p_doc => hdrxml,
                   p_role => recipient_role,
                   p_type => 'to',
                   p_name => display_name,
                   p_email => email,
                   p_pos => hdrxmlPos);

      addCopyRecipients(hdrxml, cc_list, 'cc', hdrxmlPos);
      addCopyRecipients(hdrxml, bcc_list, 'bcc', hdrxmlPos);

      hdrxmlPos := SkipTag(hdrxml, 'RECIPIENTLIST', hdrxmlPos, occurance);

      -- 3692786 Only if the FROM and REPLYTO are defined as message
      --         attributes will they be put on the XML. Otherwise it will
      --         be up to what is defined for the mailer.
      if FromInAttr = 'Y' or ReplyToInAttr = 'Y' then
         hdrxmlPos := NewTag(hdrxml, hdrxmlPos, 'FROM', '', attrlist);

         if FromInAttr = 'Y' then
            fromName := replace(fromName, g_newLine);
	    -- Bug 13786156: Use CDATA for From header value as the XML parser is throwing SAXParseException
	    -- in java layer when From value is email address of the form "Display Name <name@domain>"
	    fromName := '<![CDATA['||fromName||']]>';
            hdrxmlPos := NewTag(hdrxml, hdrxmlPos, 'NAME', fromName, attrlist);
            hdrxmlPos := SkipTag(hdrxml, 'NAME', hdrxmlPos, occurance);
         end if;
         if ReplyToInAttr = 'Y' then
            replyto := replace(replyto, g_newLine);
            replyto := '<![CDATA['||replyto||']]>';
            hdrxmlPos := NewTag(hdrxml, hdrxmlPos, 'ADDRESS', replyto,
                                attrlist);
            hdrxmlPos := SkipTag(hdrxml, 'ADDRESS', hdrxmlPos, occurance);
         end if;
         hdrxmlPos := SkipTag(hdrxml, 'FROM', hdrxmlPos, occurance);
      end if;

      hdrxmlPos := NewTag(hdrxml, hdrxmlPos, 'STATUS', status, attrlist);
      hdrxmlPos := SkipTag(hdrxml, 'STATUS', hdrxmlPos, occurance);

      subject := replace(subject, g_newLine);
      subject := '<![CDATA['||subject||']]>';
      hdrxmlPos := NewTag(hdrxml, hdrxmlPos, 'SUBJECT', subject, attrlist);

      pos := NewLOBTag(p_doc, pos, 'HEADER', hdrxml, attrlist);
      pos := SkipLOBTag(p_doc, 'HEADER', pos, occurance);

      -- <<sstomar bug 6993909>> : to get #WF_SECURITY_POLICY
      --- Below API returns Template Name based on l_sec_policy . So if 'OPEN_MAIL_SECURE'
      --  it means user should view online version of ntf but user will
      --  get "notification detail.html" as attachement.
      Wf_Mail.ProcessSecurityPolicy(nid, l_sec_policy, t_name);


      /*
      ** Potentially, it could be possible for a text/plain notification
      ** but that would mean looking ahead to ensure that there are
      ** absolutely no attachments of any description.
      */
      /*
      ** The body part section of the XML structure will contain
      ** a <![CDATA ]]> construct which removes the need to URL
      ** encode the data.
      */
      if notification_pref in ('MAILTEXT','MAILATTH') then
         /*
         ** MAILTEXT and MAILATTH will have the text/plain as the
         ** primary messasge content. The others will be in the
         ** from of an attachment.
         */
         dbms_lob.trim(g_LOBTable(messageIdx).temp_lob, 0);

         -- This getBodyPart API releases temp lob allocated within
         -- WF_MAIL.GetLobMessage4 for doctype (text/plain )
         --  i.e. g_text_messageIdx locator
         getBodyPart(g_LOBTable(messageIdx).temp_lob, nid,
                     g_ntfDocText);

         -- bug 6196382 :
         -- Outer structure i.e. <CONTENT tag>'s  content-type for  fwk based ntf.
         -- should be multipart/related; otherwise Thunderbird email client
         -- will show text/html body part also with text/plain for MAILATTH user
         --

         -- << sstomar bug 6993909 >> :
         --    Always use 'multipart/mixed' with CONTENT tag for 'MAILTEXT','MAILATTH'.
         --    It should also be used when #WF_SECURITY_POLICY=NO_EMAIL
         --    i.e. t_name (Template name) ='OPEN_MAIL_SECURE'
         AddElementAttribute('content-type', 'multipart/mixed', attrlist);


         pos := NewLOBTag(p_doc, pos, 'CONTENT', '', attrlist);
         attrlist.DELETE;

         -- -- BODYPART TAG: This text/plain is a first body part for
         --              MAILATTH and MAILTEXT users.

         AddElementAttribute('content-type', g_ntfDocText,  attrlist);

         pos := NewLOBTag(p_doc, pos, 'BODYPART', '', attrlist);

         -- Same Content-Type with message TAG as there won't be Images or
         -- Other resources referring within first message BODY.
         pos := NewLOBTag(p_doc, pos, 'MESSAGE',
                          g_LOBTable(messageIdx).temp_lob, attrlist);

         pos := SkipLOBTag(p_doc, 'MESSAGE', pos, occurance);

         if frameworkContent = TRUE and bodyToken = 'Y' then
            -- Build the resource section of the XML so that the
            -- java layer can locate the notification body to
            -- merge into the template.

            ntfURL := wf_mail.urlEncode(wf_notification.getFwkBodyURL2(nid,
                                        g_ntfDocText,
                                        l_nlsLanguage,
                                        l_nlsCalendar));

            AddElementAttribute('page-type','fwk', attrlist);
            AddElementAttribute('src',ntfURL, attrlist);
            if EnableStyleInAttr = 'Y' then
               AddElementAttribute('enable-stylesheet', stylesheetEnabled,
                                   attrlist);
            end if;

            -- <<sstomar>>: These parameters may be redundant as Notification
            -- level parameter would be used for NLS context at java layer
            AddElementAttribute('language',l_nlsLanguage, attrlist);
            AddElementAttribute('territory',l_nlsTerritory, attrlist);

            AddElementAttribute('token', 'BODY', attrlist);


            pos := NewLOBTag(p_doc, pos, 'RESOURCE','',attrlist);
            attrlist.DELETE;
            pos := SkipLOBTag(p_doc, 'RESOURCE', pos, occurance);
         end if;

         pos := SkipLOBTag(p_doc, 'BODYPART', pos, occurance);
         attrlist.DELETE;
      end if; -- END for 'MAILTEXT','MAILATTH'

      if notification_pref in ('MAILHTML','MAILATTH','MAILHTM2') then

         --
         -- The HTML version of the message is only available
         -- to MAILHTML and MAILATTH recipients.
         -- MAILHTML2 is a text/html message without the additional
         -- two framed "Notification Detail.html" attachment, but other attachement
         -- may be available.
         --
         dbms_lob.trim(g_LOBTable(messageIdx).temp_lob, 0);

         -- This getBodyPart API releases temp lob allocated within
         -- WF_MAIL.GetLobMessage4 for doctype (text/html )
         -- i.e. g_html_messageIdx locator
         getBodyPart(g_LOBTable(messageIdx).temp_lob, nid,
                     g_ntfDocHtml);

         imgFound := FALSE;
         resourceList.DELETE;

         if frameworkContent = FALSE AND attachInlineImages = 'Y' then
            imgFound := ParseForInlineImages(g_LOBTable(messageIdx).temp_lob,
                                             nid, resourceList);
         end if;

         --
         -- The content-type for the CONTENT tag is based on a set of rules.
         -- It can only be multiplart/mixed or multiplart/related if it is a framework region,
         -- or there is an inline image. Inline images and framework regions are
         -- only allowed for HTML type notifications.
         --
         -- 4481199 - If the prefernce is MAILATTH, then the CONTENT
         --          element is already defined.

         -- << sstomar, bug6993909 : commenting below code block >>
         -- if (notification_pref in ('MAILHTML', 'MAILHTM2')) then
         --    if(frameworkContent = TRUE or imgFound = TRUE) then
         --       AddElementAttribute('content-type', 'multipart/related', attrlist);
         --    else
         --       AddElementAttribute('content-type', 'multipart/mixed', attrlist);
         --    end if;
         --
         --    pos := NewLOBTag(p_doc, pos, 'CONTENT', '', attrlist);
         --    attrlist.DELETE;
         -- end if;

         if (wf_log_pkg.level_procedure >= fnd_log.g_current_runtime_level) then
             wf_log_pkg.string(WF_LOG_PKG.level_procedure,
                           'wf.plsql.WF_XML.generateDoc',
                            ' Template Name returned by  Wf_Mail.ProcessSecurityPolicy: [' || t_name || ']' );

            if (frameworkContent ) then
                wf_log_pkg.string(WF_LOG_PKG.level_procedure,
                         'wf.plsql.WF_XML.generateDoc',  ' framework-Content ?: YES') ;
            else
                wf_log_pkg.string(WF_LOG_PKG.level_procedure,
                         'wf.plsql.WF_XML.generateDoc',  ' framework-Content ?: NO') ;
            end if;
         end if;

         -- << sstomar bug 6993909>> :
         -- CASE 1 : MAILHTM2
         if ( notification_pref in ('MAILHTM2') ) then

            -- MAILHTM2, text/html only be exist as a FIRST body part but may have
            -- additional attachements EXCEPT "Notification Detail.html".

            -- For CONTENT tag.
            if ((frameworkContent = true or imgFound = true) and
                ( t_name is null or t_name <>'OPEN_MAIL_SECURE') ) then

                AddElementAttribute('content-type', 'multipart/related', attrlist);
            else
               -- NOT a Fwk Content:
               -- MAILHTM2 may have INLINE / attachements resources.
               AddElementAttribute('content-type', 'multipart/mixed', attrlist);
            end if;

            pos := NewLOBTag(p_doc, pos, 'CONTENT', '', attrlist);
            attrlist.DELETE;

            -- For BODYPART tag
            -- NOTE : This would be a first BODY part so SET it text/html
            AddElementAttribute('content-type', 'text/html', attrlist);

         -- CASE 2: MAILHTML always will have "Notification Detail.html" attachement
         elsif (notification_pref in ('MAILHTML')  ) then

            -- No need to check t_name ==>'OPEN_MAIL_SECURE' because
            -- "Notification Detail.html"  always be there for MAILHTML.
            AddElementAttribute('content-type', 'multipart/mixed', attrlist);

            pos := NewLOBTag(p_doc, pos, 'CONTENT', '', attrlist);
            attrlist.DELETE;

            --  For BODYPART tag
            if ( (frameworkContent = true or imgFound = true) and
                 ( t_name is null or t_name <>'OPEN_MAIL_SECURE') ) then

               if (wf_log_pkg.level_procedure >= fnd_log.g_current_runtime_level) then
                    wf_log_pkg.string(WF_LOG_PKG.level_procedure,
                                 'wf.plsql.WF_XML.generateDoc',
                                 'Setting BODYPART content-type multipart/related');
               end if;

                -- Set Content-Type = multipart/related because this BODY MAY have
                -- other related body-parts which make aggregate body OBJECT ...
                AddElementAttribute('content-type', 'multipart/related', attrlist);
             else
                -- NO Fwk /Image ref : default text/html
                AddElementAttribute('content-type', 'text/html', attrlist);
            end if;

         -- CASE 3: MAILATTH
         else
             -- Content-Type for CONTENT tag has already been set.

             -- For MAILATTH : text/html msg body would be seen as attachement
             --              + "Notification Detail.html"
             -- BUT text/html will have references of Images / Stylesheets
             -- ( NOT be sent as INLINE attachment).

             --  For BODYPART tag
             AddElementAttribute('content-type', 'text/html', attrlist);

         end if;

         pos := NewLOBTag(p_doc, pos, 'BODYPART', '', attrlist);
         attrlist.DELETE;

         -- FOR MESSAGE tag
         AddElementAttribute('content-type',  g_ntfDocHtml, attrlist);

         if notification_pref = 'MAILATTH' then

            -- The text/html will be an attachment for MAILTEXT
            AddElementAttribute('content-disposition',disposition, attrlist);
            AddElementAttribute('filename',htmlfilename, attrlist);
         end if;

         pos := NewLOBTag(p_doc, pos, 'MESSAGE',
                          g_LOBTable(messageIdx).temp_lob, attrlist);
         pos := SkipLOBTag(p_doc, 'MESSAGE', pos, occurance);

         if frameworkContent = TRUE and bodyToken = 'Y' then
            -- Build the resource section of the XML so that the
            -- java layer can locate the notification body to
            -- merge into the template.

            ntfURL := wf_mail.urlEncode(wf_notification.getFwkBodyURL2(nid,
                                        g_ntfDocHtml,
                                        l_nlsLanguage,
                                        l_nlsCalendar));


            AddElementAttribute('page-type','fwk', attrlist);
            AddElementAttribute('src',ntfURL, attrlist);
            if EnableStyleInAttr = 'Y' then
               AddElementAttribute('enable-stylesheet', stylesheetEnabled,
                                   attrlist);
            end if;

            AddElementAttribute('language', l_nlsLanguage, attrlist);
            AddElementAttribute('territory', l_nlsTerritory, attrlist);
            AddElementAttribute('token', 'BODY', attrlist);


            pos := NewLOBTag(p_doc, pos, 'RESOURCE','',attrlist);
            attrlist.DELETE;
            pos := SkipLOBTag(p_doc, 'RESOURCE', pos, occurance);
         elsif (frameworkContent = FALSE AND imgFound = TRUE) then
            -- Add RESOURCE tags for each of the images pased in
            -- in the ParseForInlineImages
            addInlineImages(p_doc, pos, attrlist, nid, disposition,
                            resourceList);
         end if;

         pos := SkipLOBTag(p_doc, 'BODYPART', pos, occurance);
         attrlist.DELETE;
      end if;

      if notification_pref in ('MAILHTML','MAILATTH') then
         /*
         ** Adding the text/html component to the notification.
         ** This is the little two framed representation of the
         ** notification.
         **
         ** This is only available for the MAILHTML and MAILATTH recipients.
         */
         AddElementAttribute('content-type',g_ntfDocHtml, attrlist);
         pos := NewLOBTag(p_doc, pos, 'BODYPART', '', attrlist);

         body_atth := '<![CDATA['||body_atth||']]>';
         AddElementAttribute('content-disposition',disposition, attrlist);
         AddElementAttribute('filename',urlfilename, attrlist);
         pos := NewLOBTag(p_doc, pos, 'MESSAGE', body_atth, attrlist);
         pos := SkipLOBTag(p_doc, 'MESSAGE', pos, occurance);
         pos := SkipLOBTag(p_doc, 'BODYPART', pos, occurance);
         attrlist.DELETE;
      end if;


      -- Bug 5379861: Notification Reference section and Attachements of a pl/sql
      -- notificaton appears as Non-Translated.
      -- Set NLS language and territory for this notification
      if (wf_log_pkg.level_procedure >= fnd_log.g_current_runtime_level) then
         wf_log_pkg.string(WF_LOG_PKG.level_procedure,
                           'wf.plsql.WF_XML.generateDoc',
                           'Setting User NLS {'|| l_nlsLanguage ||'} {'||l_nlsTerritory||'}'
                           || l_nlsDateFormat || '} {' || l_nlsDateLanguage  || '} {'
                           || '} {' || l_nlsCalendar || '} {' || l_nlsNumericCharacters
                           || '} {' || l_nlsSort || '}');
      end if;

      -- Set  notification /user language before processing attachements.
      -- SetNLS(l_nlsLanguage, l_nlsTerritory);
      if(l_context_changed  ) then

           -- l_nlsCalendar only will be stored in global variable
           WF_NOTIFICATION_UTIL.SetNLSContext(
                           nid,
                           l_nlsLanguage  ,
                           l_nlsTerritory ,
                           l_nlsDateFormat ,
                           l_nlsDateLanguage ,
                           l_nlsNumericCharacters ,
                           l_nlsSort ,
                           l_nlsCalendar  );


      END if;

      --
      -- Next will be to attach all URLs and DOCUMENT attributes
      -- as attachments. Disposition for all URL and DOCUMENT attributes
      -- with ATTACH=Y should be attachment.
      --

      --
      -- Bug 6671568: When #WF_SECURITY_POLICY = 'NO_EMAIL' or 'ENC_EMAIL_ONLY'
      -- we should not send any other content related to the notification, either
      -- attachment or inline through e-mail.
      --

      -- << sstomar : below API is being called above so t_name have assigned (null or somevalue) .
      -- Wf_Mail.ProcessSecurityPolicy(nid, l_sec_policy, t_name);

      if (t_name is not null) then
         if (t_name <> 'OPEN_MAIL_SECURE')
         then
           pos := GetAttachment(nid, p_doc, agent, 'attachment', doctype, pos);
         end if;
      else
         pos := GetAttachment(nid, p_doc, agent, 'attachment', doctype, pos);
      end if;

      if (wf_log_pkg.level_procedure >= fnd_log.g_current_runtime_level) then
         wf_log_pkg.string(WF_LOG_PKG.level_procedure,
                           'wf.plsql.WF_XML.generateDoc',
                           'Re-Setting Base NLS {'|| g_base_language ||'} {'||g_base_territory||'}'
                           || g_base_nlsDateFormat || '} {' || g_base_nlsDateLanguage  || '} {'
                           || '} {' || g_base_nlsCalendar || '} {' || g_base_nlsNumericCharacters
                           || '} {' || g_base_nlsSort  || '}');
      end if;

      -- Bug 5379861: Reset back base language.
      -- SetNLS(g_base_language, g_base_territory);
      -- Reset base language
      if( l_context_changed ) then

           WF_NOTIFICATION_UTIL.SetNLSContext
                             (null,                 -- Resetting null for Nid is fine.
                              g_base_language        ,
                              g_base_territory       ,
                              g_base_nlsDateFormat    ,
                              g_base_nlsDateLanguage  ,
                              g_base_nlsNumericCharacters ,
                              g_base_nlsSort             ,
                              g_base_nlsCalendar   );
      end if;

      pos := SkipLOBTag(p_doc, 'CONTENT', pos, occurance);
      pos := SkipLOBTag(p_doc, 'NOTIFICATION', pos, occurance);

      p_pos := pos;
      wf_temp_lob.releaseLob(g_LOBTable, messageIdx);


      if (wf_log_pkg.level_procedure >= fnd_log.g_current_runtime_level) then
         wf_log_pkg.string(WF_LOG_PKG.level_procedure,
                         'wf.plsql.WF_XML.generateDoc', 'END');
      end if;
  exception
      when others then

        wf_temp_lob.releaseLob(g_LOBTable, messageIdx);

        --  Since within wf_mail.getLOBMessage4 we are releasing
        --  TEMP LOBs incase of any exception, so there is no need to
        --  release those LOBs here. -- WF_MAIL.CloseLob(doctype)

           if (wf_log_pkg.level_procedure >= fnd_log.g_current_runtime_level) then
           wf_log_pkg.string(WF_LOG_PKG.level_procedure,
                           'wf.plsql.WF_XML.generateDoc',
                           'Re-Setting Base NLS {'|| g_base_language ||'} {'||g_base_territory||'}'
                           || g_base_nlsDateFormat || '} {' || g_base_nlsDateLanguage  || '} {'
                           || '} {' || g_base_nlsCalendar || '} {' || g_base_nlsNumericCharacters
                           || '} {' || g_base_nlsSort  || '}');
        end if;

           -- Reset base language, in case of exception.
        -- SetNLS(g_base_language, g_base_territory);
        -- Reset base language
        WF_NOTIFICATION_UTIL.SetNLSContext(
              null,
              g_base_language        ,
              g_base_territory       ,
              g_base_nlsDateFormat    ,
              g_base_nlsDateLanguage  ,
              g_base_nlsNumericCharacters ,
              g_base_nlsSort             ,
              g_base_nlsCalendar   );



        wf_core.context('WF_XML', 'GenerateDoc', p_event_name, p_event_key);
        raise;
   end GenerateDoc;


   -- GenerateGroupDoc
   -- To generate the complete set of notification for a group.
   procedure GenerateGroupDoc(p_doc in out NOCOPY CLOB,
                              p_pos in out NOCOPY number,
                              p_recipient_role in varchar2,
                              p_notification_pref in varchar2,
                              p_orig_system in varchar2,
                              p_orig_system_id in number,
                              p_event_name in varchar2,
                              p_event_key in varchar2,
                              p_parameter_list in wf_parameter_list_t)
   is

      cursor members(rname varchar2, rorig varchar2, rorigid number) is
         select UR.USER_NAME, UR.USER_ORIG_SYSTEM, UR.USER_ORIG_SYSTEM_ID
                from   WF_USER_ROLES UR
                where  UR.ROLE_NAME = rname
                  and    UR.ROLE_ORIG_SYSTEM = rorig
                  and    UR.ROLE_ORIG_SYSTEM_ID = rorigid
                  and    ((UR.USER_NAME <> UR.ROLE_NAME) or
                          (UR.USER_ORIG_SYSTEM <> UR.ROLE_ORIG_SYSTEM  and
                           UR.USER_ORIG_SYSTEM_ID <> UR.ROLE_ORIG_SYSTEM_ID));

      members_type members%ROWTYPE;
      TYPE members_table_type is TABLE OF members%ROWTYPE
           INDEX BY BINARY_INTEGER;
      i pls_integer := 1;

      members_t members_table_type;
      attrlist        wf_xml_attr_table_type;
      inAttr    varchar2(1);
      resetNls  varchar2(10);
      corrId    varchar2(128);

   begin
      if (wf_log_pkg.level_procedure >= fnd_log.g_current_runtime_level) then
         wf_log_pkg.string(WF_LOG_PKG.level_procedure,
                          'wf.plsql.WF_XML.generateGroupDoc', 'BEGIN');
      end if;
      i := 1;
      for r in members(p_recipient_role, p_orig_system, p_orig_system_id) loop
         members_t(i).user_name := r.user_name;
         members_t(i).user_orig_system:= r.user_orig_system;
         members_t(i).user_orig_system_id:= r.user_orig_system_id;
         i := i + 1;
      end loop;


      -- 4104735 Removing the test for "p_notification_pref not in
      --         ('QUERY','SUMMARY','SUMHTML', 'DISABLED')". The rule to
      -- send or not should come from the individual memebers and not the
      -- parent role. If there are simply no members then the NULL document
      -- should be sent. The testing of the notification preference for
      -- the members will be performed again in genreateDoc.
      if members_t.count = 0 then
         -- Bug 18012941: Update the notification mail status to NULL as the
	 -- user/role has email address NULL and no members exists
	 update wf_notifications
	 set mail_status = ''
	 where notification_id = to_number(p_event_key);

	 -- No role members. Only log it for now and change the
         -- notification preference to QUERY.
         GenerateEmptyDoc(to_number(p_event_key), p_pos, p_doc, 'no_members', TRUE);
      else

         -- 4628088 Send the RESET_NLS flag if one is defined
         -- at the message level.
         corrId := wf_event.getValueForParameter('Q_CORRELATION_ID',
                                                 p_parameter_list);
         resetNls := WF_MAILER_PARAMETER.GetValueForCorr (pNid => p_event_key,
                                                     pCorrId => corrId,
                                                     pName => 'RESET_NLS',
                                                     pInAttr => inAttr);

         AddElementAttribute('maxcount',to_char(members_t.count), attrlist);
         if(inAttr = 'Y') then
            AddElementAttribute('reset-nls',resetNls, attrlist);
         end if;
         p_pos := NewLOBTag(p_doc, p_pos, 'NOTIFICATIONGROUP', '', attrlist);
         attrlist.DELETE;

         for i in 1..members_t.count loop
            generateDoc(p_doc, p_pos, members_t(i).user_name,
                        p_event_name, p_event_key, p_parameter_list);
         end loop;
      end if;

      if (wf_log_pkg.level_procedure >= fnd_log.g_current_runtime_level) then
         wf_log_pkg.string(WF_LOG_PKG.level_procedure,
                          'wf.plsql.WF_XML.generateGroupDoc', 'END');
      end if;
   exception
      when others then
         wf_core.context('WF_XML','GenerateGroupDoc',p_event_name, p_event_key);
         raise;
   end GenerateGroupDoc;

   -- GenerateMessage
   -- To generate the XML content for a single notification
   procedure GenerateMessage(p_doc in out nocopy CLOB,
                     p_event_name in varchar2,
                     p_event_key in varchar2,
                     p_parameter_list in wf_parameter_list_t)
   is
      nid NUMBER;

      pos integer;
      amt number;

      installed VARCHAR2(1);
      language  wf_roles.language%TYPE;
      territory wf_roles.territory%TYPE;
      codeset VARCHAR2(100);
      orig_system VARCHAR2(100);
      orig_system_id number;

      recipient_role wf_roles.name%TYPE;
      status VARCHAR2(100);
      mail_status VARCHAR2(100);
      str varchar2 (2000);

      role  wf_roles.name%TYPE;
      display_name wf_roles.display_name%TYPE;
      email wf_roles.email_address%TYPE;
      notification_pref wf_roles.notification_preference%TYPE;

      attrlist        wf_xml_attr_table_type;

      nodename varchar2(100);
      messageType varchar2(8);
      messageName varchar2(30);

      inAttr varchar2(1);
      resetNls varchar2(10);

   begin

      if (wf_log_pkg.level_procedure >= fnd_log.g_current_runtime_level) then
         wf_log_pkg.string(WF_LOG_PKG.level_procedure,
                          'wf.plsql.WF_XML.generateMessage', 'BEGIN');
      end if;

      nid := to_number(p_event_key);

      -- Obtain notification information
      begin -- 3741599 If there is no notification, exit gracefully
         select NVL(MORE_INFO_ROLE, RECIPIENT_ROLE), STATUS, MAIL_STATUS,
                MESSAGE_TYPE, MESSAGE_NAME
         into recipient_role, status, mail_status, messageType, messageName
         from WF_NOTIFICATIONS
         where  NOTIFICATION_ID = nid;
      exception
         when no_data_found then
           GenerateEmptyDoc(nid, 0, p_doc, 'no_data_found', TRUE);
           return;
         when others then
            wf_core.context('WF_XML','GenerateMessage',to_char(nid));
            raise;
      end;

      -- Bug 10243065. Check if this is a reassigned notification that does
      -- not need to be sent
      if wf_event.getValueForParameter('IS_DUPLICATE', p_parameter_list) = 'TRUE' then
        GenerateEmptyDoc(nid, 0, p_doc, 'Reassigned, not sent to oringinal recipient', TRUE);
        return;
      end if;

      if (wf_mail.test_flag = TRUE) then
          mail_status := 'MAIL';
          if (status not in ('OPEN','CANCELED','CLOSED')) then
             status := 'OPEN';
          end if;
       end if;

       -- Bug 10202313: store status, mail_status values into global variables
       g_status := status;
       g_mstatus := mail_status;

      if MAIL_STATUS is null or MAIL_STATUS not in ('MAIL','INVALID') then
        GenerateEmptyDoc(nid, 0, p_doc, 'Reassigned, MAIL_STATUS:'||MAIL_STATUS, TRUE);
        return;
      end if;

      -- <<sstomar>>:
      -- Call OLD  API instead of  WF_DIRECTORY.GetRoleInfoMail2
      -- here I think we are OK as we are not using other parameters.
      --
      -- Obtain recipient information
      WF_DIRECTORY.GetRoleInfoMail(recipient_role, display_name, email,
                                   notification_pref,
                                   language, territory,
                                   orig_system, orig_system_id, installed);

      if email is not null then
         -- Email address is provided. process for one recipient

         if notification_pref not in ('QUERY','SUMMARY','SUMHTML',
                                      'DISABLED') then
           str := '<?xml version="1.0" ?>';
           pos := length(str);
           dbms_lob.write(p_doc, pos, 1, str);

           -- 4628088 Send the RESET_NLS flag if one is defined
           -- at the message level.
           resetNls := WF_MAILER_PARAMETER.GetValueForCorr (pNid => nid,
                                                       pCorrId => messageType,
                                                       pName => 'RESET_NLS',
                                                       pInAttr => inAttr);

           AddElementAttribute('maxcount','1', attrlist);

           if(inAttr = 'Y') then
              AddElementAttribute('reset-nls',resetNls, attrlist);
           end if;

           pos := NewLOBTag(p_doc, pos, 'NOTIFICATIONGROUP', '', attrlist);
           attrlist.DELETE;

           -- generate XML payload
           generateDoc(p_doc, pos, recipient_role,
                       p_event_name, p_event_key, p_parameter_list);

         else
            -- This case should not be reached if the notification system
            -- is working correctly ie that a NULL is placed in the mail_status
            -- However, just in case, generate a blank NOTIFICATION element
            -- all the same.
            GenerateEmptyDoc(nid, 0, p_doc, 'NOTIFICATION_PREFERENCE:'||notification_pref, TRUE);
         end if;
      else
         -- No email address is provided. Assume that this is a
         -- role with members.
         -- Failure to yeild members will result in a notification
         -- being generated to go to the system admin and the
         -- error process to be called.
         str := '<?xml version="1.0" ?>';
         pos := length(str);
         dbms_lob.write(p_doc, pos, 1, str);
         generateGroupDoc(p_doc, pos, recipient_role, notification_pref,
                          orig_system, orig_system_id,
                          p_event_name, p_event_key, p_parameter_list);
      end if;

      if (wf_log_pkg.level_procedure >= fnd_log.g_current_runtime_level) then
         wf_log_pkg.string(WF_LOG_PKG.level_procedure,
                          'wf.plsql.WF_XML.generateMessage', 'END');
      end if;
   exception
      when others then
         wf_core.context('WF_XML','Generate',p_event_name, p_event_key);
         raise;
   end GenerateMessage;

   -- GenerateSummaryDoc
   -- To generate the XML content for the OPEN notifications.

   procedure GenerateSummaryDoc (p_doc in out NOCOPY CLOB,
                          p_pos in out NOCOPY number,
                          p_recipient_role in varchar2,
                          p_event_name in varchar2,
                          p_event_key in varchar2,
                          p_parameter_list in wf_parameter_list_t)
   is
      pos integer;
      attrlist wf_xml_attr_table_type;
      occurance integer;

      docType VARCHAR2(100);

      recipient_role VARCHAR2(100);
      display_name VARCHAR2(200);
      email VARCHAR2(1000);

      notification_pref VARCHAR2(100);

      orig_system VARCHAR2(100);
      orig_system_id number;
      installed VARCHAR2(1);

      l_nlsDateFormat        VARCHAR2(120);
      l_nlsDateLanguage      varchar2(120);
      l_nlsCalendar          varchar2(120);
      l_nlsNumericCharacters varchar2(30);
      l_nlsSort              varchar2(120);
      l_nlsCurrency          varchar2(30);

      l_nlsLanguage             VARCHAR2(120);
      l_nlsTerritory            VARCHAR2(120);
      l_nlsCodeset              VARCHAR2(30);

      l_context_changed         BOOLEAN := false;

      hdrxml varchar2(32000);
      hdrxmlPos integer;

      corrId          varchar2(128);
      nodename        varchar2(100);
      fromName        varchar2(100);
      replyto         varchar2(100);
      subject VARCHAR2(4000);

      msgbody VARCHAR2(32000);
      -- message CLOB;
      messageIdx pls_integer;
      l_lob VARCHAR2(1);
      resourceSrc varchar2(4000);
      l_renderBody varchar2(1);
      l_messageName varchar2(30);

   begin

      if (wf_log_pkg.level_event >= fnd_log.g_current_runtime_level) then
            wf_log_pkg.string(wf_log_pkg.level_event,
                              'wf.plsql.WF_XML.GenerateSummaryDoc',
                              'BEGIN');
      end if;

      recipient_role := p_recipient_role;

      corrId := wf_event.getValueForParameter('Q_CORRELATION_ID',
                                              p_parameter_list);
      messageIdx := 0;
      pos := p_pos;
      occurance := 1;

      -- Obtain recipient information
      --WF_DIRECTORY.GetRoleInfoMail(recipient_role, display_name, email,
      --                             notification_pref,
      --                            language, territory,
      --                             orig_system, orig_system_id, installed);

      -- Obtain recipient's NLS information too
      WF_DIRECTORY.GetRoleInfoMail2(recipient_role, display_name, email,
                                    notification_pref,
                                    orig_system,
                                    orig_system_id,
                                    installed,
                                    l_nlsLanguage ,
                                    l_nlsTerritory ,
                                    l_nlsDateFormat ,
                                    l_nlsDateLanguage ,
                                    l_nlsCalendar ,
                                    l_nlsNumericCharacters ,
                                    l_nlsSort ,
                                    l_nlsCurrency );


      if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
         wf_log_pkg.string(wf_log_pkg.level_statement,
                           'wf.plsql.WF_XML.GenerateSummaryDoc',
                           'ROLE {'||recipient_role||'} LANG {'||l_nlsLanguage||
                           '} TERR {'||l_nlsTerritory||' NTF {'||notification_pref||
                           '} EMAIL {'||email||'}');

      end if;

      -- XX TODO Sentinal for DISABLED case? Though there is no NID to be
      -- updated, can be used as documentation in the log
      if notification_pref not in ('SUMMARY','SUMHTML') or
         email is null then
         if (wf_log_pkg.level_exception >= fnd_log.g_current_runtime_level) then
            if email is null then
               wf_log_pkg.string(wf_log_pkg.level_exception,
                                 'wf.plsql.WF_XML.GenerateSummaryDoc',
                                 'Not generating. Recipient has a null '||
                                 'email address');
            else
               wf_log_pkg.string(wf_log_pkg.level_exception,
                                 'wf.plsql.WF_XML.GenerateSummaryDoc',
                                 'Not generating. Recipient has pref: '||
                                 notification_pref);
            end if;
         end if;
         GenerateEmptyDoc(0, p_pos, p_doc, 'NOTIFICATION_PREFERENCE:'||notification_pref, FALSE);
         return;

      end if;

      -- Set the preferred document type based on the
      -- notification preference.
      if g_install = 'EMBEDDED' then
         l_renderBody := 'N';
         l_messageName := 'SUMHTML';
         if notification_pref = 'SUMMARY' then
            docType := g_ntfDocText;
         elsif notification_pref = 'SUMHTML' then
            docType := g_ntfDocHtml;
         end if;
      else
         l_renderBody := 'Y';
         l_messageName := 'SUMMARY';
         docType := g_ntfDocText;
      end if;

      -- Get the Base NLS.
      -- << sstomar>> : already being set in GENERATE function
      -- WF_MAIL.GetSessionLanguage(base_lang, base_territory, base_codeset);

      -- If requested language is not installed, use base NLS setting
      if installed = 'N' then
         l_nlsLanguage := g_base_language;
         l_nlsTerritory := g_base_territory;
      end if;
      begin
         select nls_codeset
         into l_nlsCodeset
         from wf_languages
         where nls_language = l_nlsLanguage;
      exception
         when others then
            l_nlsCodeset := g_base_codeset;
      end;

      -- <<sstomar>> :
      --
      -- setNLS(language, territory);
      -- Set user / role's context
      if( nvl(l_nlsLanguage, 'AMERICA') <> g_base_language or
          nvl(l_nlsTerritory, 'AMERICAN') <> g_base_territory or
          nvl(l_nlsDateFormat , wf_core.nls_date_format) <> g_base_nlsDateFormat   or
          nvl(l_nlsDateLanguage,  wf_core.nls_date_language) <>  g_base_nlsDateLanguage or
          nvl(l_nlsNumericCharacters, wf_core.nls_numeric_characters) <> g_base_nlsNumericCharacters or
          nvl(l_nlsSort, wf_core.nls_sort)  <> g_base_nlsSort           ) then


         WF_NOTIFICATION_UTIL.SetNLSContext(0,
                           l_nlsLanguage  ,
                           l_nlsTerritory ,
                           l_nlsDateFormat ,
                           l_nlsDateLanguage ,
                           l_nlsNumericCharacters ,
                           l_nlsSort ,
                           l_nlsCalendar);

          l_context_changed := true;


      END if;

      -- Initialise the XML Document and then progressively walk
      -- through the elements. Populating them as we go.
      -- l_pos is crucial as it determines where the next nodes
      -- will be placed.

      l_lob := 'N';

      -- <<sstomar>>:
      --  This WF_MAIL.GetSummary2 API may allocate temp LOB depending on
      --  size of contents. We release within getBodyPart api, getBodyPart
      --  is being called below...
      WF_MAIL.GetSummary2(
       role      =>  recipient_role,
       dname     =>  display_name,
       node      =>  nodename,
       renderBody=> l_renderBody,
       contType  => docType,
       subject   => subject,
       body_text => msgbody,
       lob       => l_lob);

      --SetNLS(base_lang, base_territory);

      -- Reset base NLS Context
      if( l_context_changed ) then

          WF_NOTIFICATION_UTIL.SetNLSContext(
                                   null,
                                   g_base_language        ,
                                   g_base_territory       ,
                                   g_base_nlsDateFormat    ,
                                   g_base_nlsDateLanguage  ,
                                   g_base_nlsNumericCharacters ,
                                   g_base_nlsSort              ,
                                   g_base_nlsCalendar      );
      END if;


      -- NID hardcoded to 0 for Summary
      AddElementAttribute('nid', '0', attrlist);

      AddElementAttribute('language', l_nlsLanguage, attrlist);
      AddElementAttribute('territory', l_nlsTerritory, attrlist);
      AddElementAttribute('codeset', l_nlsCodeset, attrlist);

      AddElementAttribute('nlsDateformat', l_nlsDateFormat, attrlist);
      AddElementAttribute('nlsDateLanguage', l_nlsDateLanguage, attrlist);

      AddElementAttribute('nlsNumericCharacters', l_nlsNumericCharacters, attrlist);
      AddElementAttribute('nlsSort', l_nlsSort, attrlist);

      -- priority hardcoded to 50
      AddElementAttribute('priority', '50', attrlist);
      -- Not addding accesskey as no response processing is done for summary email
      AddElementAttribute('node', nodename, attrlist);
      -- ItemType / messageType hardcoded to WFMAIL
      AddElementAttribute('item_type', 'WFMAIL', attrlist);
      AddElementAttribute('message_name', l_messageName, attrlist);
      AddElementAttribute('full-document', 'Y', attrlist);
      pos := NewLOBTag(p_doc, pos, 'NOTIFICATION', '', attrlist);
      attrlist.DELETE;

      hdrxmlPos := 0;
      hdrxml := '';

      hdrxmlPos := NewTag(hdrxml, hdrxmlPos, 'RECIPIENTLIST', '', attrlist);

      addRecipient(p_doc => hdrxml,
                   p_role => recipient_role,
                   p_type => 'to',
                   p_name => display_name,
                   p_email => email,
                   p_pos => hdrxmlPos);

      hdrxmlPos := SkipTag(hdrxml, 'RECIPIENTLIST', hdrxmlPos, occurance);

      hdrxmlPos := NewTag(hdrxml, hdrxmlPos, 'FROM', '', attrlist);

      -- fromName := '&#FROM';
      fromName := WF_MAILER_PARAMETER.GetValueForCorr (pCorrId => corrId,
                                                       pName => 'FROM');
      fromName := replace(fromName, g_newLine);
      fromName := '<![CDATA['||fromName||']]>';
      hdrxmlPos := NewTag(hdrxml, hdrxmlPos, 'NAME', fromName, attrlist);
      hdrxmlPos := SkipTag(hdrxml, 'NAME', hdrxmlPos, occurance);

      -- replyto := '&#REPLYTO';
      replyto := WF_MAILER_PARAMETER.GetValueForCorr (pCorrId => corrId,
                                                      pName => 'REPLYTO');
      replyto := replace(replyto, g_newLine);
      replyto := '<![CDATA['||replyto||']]>';
      hdrxmlPos := NewTag(hdrxml, hdrxmlPos, 'ADDRESS', replyto, attrlist);
      hdrxmlPos := SkipTag(hdrxml, 'ADDRESS', hdrxmlPos, occurance);
      hdrxmlPos := SkipTag(hdrxml, 'FROM', hdrxmlPos, occurance);

      -- Not addding status as not needed for summary email

      subject := replace(subject, g_newLine);
      subject := '<![CDATA['||subject||']]>';
      hdrxmlPos := NewTag(hdrxml, hdrxmlPos, 'SUBJECT', subject, attrlist);

      pos := NewLOBTag(p_doc, pos, 'HEADER', hdrxml, attrlist);
      pos := SkipLOBTag(p_doc, 'HEADER', pos, occurance);

      -- <sstomar bug 6993909>>
      --  So far I did not see any issue with SUMHTML
      --  If required then outer structure can be set multipart/related
      --  for SUMHTML, text/plain for SUMMARY.
      AddElementAttribute('content-type', 'multipart/mixed', attrlist);
      pos := NewLOBTag(p_doc, pos, 'CONTENT', '', attrlist);
      attrlist.DELETE;

      /*
      ** The body part section of the XML structure will contain
      ** a <![CDATA ]]> construct which removes the need to URL
      ** encode the data.
      */
      if (l_renderBody = 'Y') then
         AddElementAttribute('content-type', 'text/plain', attrlist);
      else
         AddElementAttribute('content-type', 'multipart/related', attrlist);
      end if;
      pos := NewLOBTag(p_doc, pos, 'BODYPART', '', attrlist);
      attrlist.DELETE;

      -- Set the content-type of the MESSAGE tag to being the
      -- preferred output.
      AddElementAttribute('content-type', docType, attrlist);
      if (l_lob = 'Y') then

         -- dbms_lob.createTemporary(message, TRUE, dbms_lob.CALL);
         messageIdx := wf_temp_lob.getLob(g_LOBTable);
         dbms_lob.trim(g_LOBTable(messageIdx).temp_lob, 0);

         -- << bug 6511028 >>
         -- This getBodyPart API also releases temp lob allocated within
         -- WF_MAIL.GetSummary2 for doctype (text/plain )
         -- i.e. g_text_messageIdx locator
         getBodyPart(g_LOBTable(messageIdx).temp_lob, 1,
                     g_ntfDocText);

         pos := NewLOBTag(p_doc, pos, 'MESSAGE',
                          g_LOBTable(messageIdx).temp_lob, attrlist);
         -- release Temp lob to pool.
         wf_temp_lob.releaseLob(g_LOBTable, messageIdx);

      else

         msgbody := '<![CDATA['||msgbody||']]>';

         pos := NewLOBTag(p_doc, pos, 'MESSAGE', msgbody, attrlist);

      end if;

      pos := SkipLOBTag(p_doc, 'MESSAGE', pos, occurance);
      if l_renderBody = 'N' then
         -- If this is a HTML summary notification then
         -- create a RESOURCE tag to obtain the content from
         -- the Applications Framework
         resourceSrc := wf_mail.urlEncode(wf_notification.getSummaryUrl2(
                                          recipient_role, docType, l_nlsCalendar));
         AddElementAttribute('page-type','fwk', attrlist);
         AddElementAttribute('src', resourceSrc, attrlist);

         -- << sstomar>> : these attribute may not be used at java layer, insead of
         -- Notification level attributes would be used,
         AddElementAttribute('language', l_nlsLanguage, attrlist);
         AddElementAttribute('territory', l_nlsTerritory, attrlist);
         AddElementAttribute('token', 'SUMMARY', attrlist);
         pos := NewLOBTag(p_doc, pos, 'RESOURCE', '', attrlist);
         pos := SkipLOBTag(p_doc, 'RESOURCE', pos, occurance);
         attrList.DELETE;
      end if;
      pos := SkipLOBTag(p_doc, 'BODYPART', pos, occurance);
      attrlist.DELETE;

      pos := SkipLOBTag(p_doc, 'CONTENT', pos, occurance);
      pos := SkipLOBTag(p_doc, 'NOTIFICATION', pos, occurance);

      p_pos := pos;

      if (wf_log_pkg.level_event >= fnd_log.g_current_runtime_level) then
            wf_log_pkg.string(wf_log_pkg.level_event,
                              'wf.plsql.WF_XML.GenerateSummaryDoc',
                              'END');
      end if;

   exception
      when others then
        if (messageIdx > 0) then
           wf_temp_lob.releaseLob(g_LOBTable, messageIdx);
        end if;

        -- Reset base NLS Context in case of any EXCEPTION
        WF_NOTIFICATION_UTIL.SetNLSContext(
                                   null,
                                   g_base_language        ,
                                   g_base_territory       ,
                                   g_base_nlsDateFormat    ,
                                   g_base_nlsDateLanguage  ,
                                   g_base_nlsNumericCharacters ,
                                   g_base_nlsSort              ,
                                   g_base_nlsCalendar    );


        wf_core.context('WF_XML', 'GenerateSummaryDoc', p_event_name,
                        p_event_key);
        raise;
   end GenerateSummaryDoc;

   -- Generate
   procedure GenerateGroupSummaryDoc (p_doc in out NOCOPY CLOB,
                              p_pos in out NOCOPY number,
                              p_recipient_role in varchar2,
                              p_orig_system in varchar2,
                              p_orig_system_id in number,
                              p_event_name in varchar2,
                              p_event_key in varchar2,
                              p_parameter_list in wf_parameter_list_t)
   is

      cursor members(rname varchar2, rorig varchar2, rorigid number) is
         select UR.USER_NAME, UR.USER_ORIG_SYSTEM, UR.USER_ORIG_SYSTEM_ID
                from   WF_USER_ROLES UR
                where  UR.ROLE_NAME = rname
                  and    UR.ROLE_ORIG_SYSTEM = rorig
                  and    UR.ROLE_ORIG_SYSTEM_ID = rorigid
                  and    ((UR.USER_NAME <> UR.ROLE_NAME) or
                          (UR.USER_ORIG_SYSTEM <> UR.ROLE_ORIG_SYSTEM  and
                           UR.USER_ORIG_SYSTEM_ID <> UR.ROLE_ORIG_SYSTEM_ID));

      members_type members%ROWTYPE;
      TYPE members_table_type is TABLE OF members%ROWTYPE
           INDEX BY BINARY_INTEGER;

      i pls_integer := 1;

      members_t members_table_type;
      attrlist        wf_xml_attr_table_type;

   begin

      if (wf_log_pkg.level_event >= fnd_log.g_current_runtime_level) then
            wf_log_pkg.string(wf_log_pkg.level_event,
                              'wf.plsql.WF_XML.GenerateGroupSummaryDoc',
                              'BEGIN');
      end if;

      i := 1;
      for r in members(p_recipient_role, p_orig_system, p_orig_system_id) loop
         members_t(i).user_name := r.user_name;
         members_t(i).user_orig_system:= r.user_orig_system;
         members_t(i).user_orig_system_id:= r.user_orig_system_id;
         i := i + 1;
      end loop;

      if members_t.count = 0 then
         if (wf_log_pkg.level_event >= fnd_log.g_current_runtime_level) then
            wf_log_pkg.string(wf_log_pkg.level_event,
                              'wf.plsql.WF_XML.GenerateGroupSummaryDoc',
                              'No role members.');
         end if;
         GenerateEmptyDoc(0, p_pos, p_doc, 'no_members', TRUE);
      else

         AddElementAttribute('maxcount',to_char(members_t.count), attrlist);
         p_pos := NewLOBTag(p_doc, p_pos, 'NOTIFICATIONGROUP', '', attrlist);
         attrlist.DELETE;

         for i in 1..members_t.count loop
            GenerateSummaryDoc (p_doc, p_pos, members_t(i).user_name,
                        p_event_name, p_event_key, p_parameter_list);
         end loop;
      end if;

      if (wf_log_pkg.level_event >= fnd_log.g_current_runtime_level) then
            wf_log_pkg.string(wf_log_pkg.level_event,
                              'wf.plsql.WF_XML.GenerateGroupSummaryDoc',
                              'END');
      end if;

   exception
      when others then
         wf_core.context('WF_XML','GenerateGroupSummaryDoc ',p_event_name,
                         p_event_key);
         raise;
   end GenerateGroupSummaryDoc ;


   -- GenerateSummary
   -- To generate the XML content for the enqueued Summary notifications.
   procedure GenerateSummary (p_doc in out nocopy CLOB,
                     p_event_name in varchar2,
                     p_event_key in varchar2,
                     p_parameter_list in wf_parameter_list_t)
   is
      pos integer;

      attrlist        wf_xml_attr_table_type;
      str varchar2 (2000);

      recipient_role VARCHAR2(100);

      display_name VARCHAR2(200);
      email VARCHAR2(1000);
      notification_pref VARCHAR2(100);
      language VARCHAR2(100);
      territory VARCHAR2(100);
      orig_system VARCHAR2(100);
      orig_system_id number;
      installed VARCHAR2(1);

      e_RoleNameNotSpecified         EXCEPTION;

   begin

      if (wf_log_pkg.level_event >= fnd_log.g_current_runtime_level) then
            wf_log_pkg.string(wf_log_pkg.level_event,
                              'wf.plsql.WF_XML.GenerateSummary',
                              'BEGIN');
      end if;

      if p_parameter_list is not null then
            recipient_role := wf_event.getValueForParameter('ROLE_NAME',
                                                            p_parameter_list);
      end if;

      if recipient_role is null then
          raise e_RoleNameNotSpecified;
      end if;

      -- Initialise the XML Document and then progressively walk
      -- through the elements. Populating them as we go.
      -- l_pos is crucial as it determines where the next nodes
      -- will be placed.
      str := '<?xml version="1.0" ?>';
      pos := length(str);
      dbms_lob.write(p_doc, pos, 1, str);

      -- Obtain recipient information
      WF_DIRECTORY.GetRoleInfoMail(recipient_role, display_name, email,
                                   notification_pref,
                                   language, territory,
                                   orig_system, orig_system_id, installed);

      if email is not null or email <> '' then

         AddElementAttribute('maxcount','1', attrlist);
         pos := NewLOBTag(p_doc, pos, 'NOTIFICATIONGROUP', '', attrlist);
         attrlist.DELETE;
         -- Email address is provided. process for one recipient

         GenerateSummaryDoc (p_doc, pos, recipient_role, p_event_name,
                     p_event_key, p_parameter_list);

      else

         -- No email address is provided. Assume that this is a
         -- role with members.
         -- Failure to yeild members will result in a notification
         -- being generated to go to the system admin and the
         -- error process to be called.

         GenerateGroupSummaryDoc (p_doc, pos, recipient_role, orig_system,
                          orig_system_id, p_event_name, p_event_key,
                          p_parameter_list);

      end if;

      if (wf_log_pkg.level_event >= fnd_log.g_current_runtime_level) then
            wf_log_pkg.string(wf_log_pkg.level_event,
                              'wf.plsql.WF_XML.GenerateSummary',
                              'END');
      end if;
   exception

      when e_RoleNameNotSpecified then
         wf_core.context('WF_XML','GenerateSummary',p_event_name, p_event_key);
         raise;

      when others then
         wf_core.context('WF_XML','GenerateSummary',p_event_name, p_event_key);
         raise;
   end GenerateSummary;

   -- Generate
   -- To generate the XML content for the enqueued notifications.
   function Generate(p_event_name in varchar2,
                     p_event_key in varchar2,
                     p_parameter_list in wf_parameter_list_t)
                     return clob
   is
      l_doc CLOB;
      l_evt wf_event_t;
      l_parameters  wf_parameter_list_t;
      l_erragt wf_agent_t;

   begin
      if (wf_log_pkg.level_procedure >= fnd_log.g_current_runtime_level) then
         wf_log_pkg.string(WF_LOG_PKG.level_procedure,
                          'wf.plsql.WF_XML.generate', 'BEGIN');
      end if;
      -- We do not use the LOB pooling for the generate as the LOB
      -- is to be returned and not reused.
      dbms_lob.createTemporary(l_doc, TRUE, dbms_lob.call);


      BEGIN

         -- <<sstomar>>:
         --     Since base NLS parameters / context would be used in subsequent methods
         --     So better to set them here.
         --
         if(g_base_language         is null or
            g_base_territory        is null or
            g_base_codeset          is NULL  OR
            g_base_nlsDateFormat    is NULL  OR
            g_base_nlsDateLanguage  is NULL  OR
            g_base_nlsNumericCharacters is NULL  OR
            g_base_nlsSort              is NULL
            ) then

           WF_NOTIFICATION_UTIL.getNLSContext(
                          g_base_language        ,
                          g_base_territory       ,
                          g_base_codeset          ,
                          g_base_nlsDateFormat    ,
                          g_base_nlsDateLanguage  ,
                          g_base_nlsNumericCharacters ,
                          g_base_nlsSort    ,
                          g_base_nlsCalendar     );



         end if;

         --  <sstomar> bug 7130745 : added Question / Answere events
         if p_event_name in (wf_xml.WF_NTF_SEND_MESSAGE,
                             wf_xml.WF_NTF_CANCEL,
                             wf_xml.WF_NTF_REASIGN,
                             wf_xml.WF_NTF_SEND_QUESTION,
                             wf_xml.WF_NTF_SEND_ANSWER ) then

           GenerateMessage(l_doc, p_event_name, p_event_key,
                           p_parameter_list);

         elsif p_event_name = WF_NTF_SEND_SUMMARY then


            -- Summary events.
            GenerateSummary (l_doc, p_event_name, p_event_key, p_parameter_list);

         end if;
      exception
      when others then
         wf_core.context('WF_XML','Generate',p_event_name, p_event_key);

         -- RESET BASSE LANGUAGE
         WF_NOTIFICATION_UTIL.SetNLSContext(null,
                                   g_base_language        ,
                                   g_base_territory       ,
                                   g_base_nlsDateFormat    ,
                                   g_base_nlsDateLanguage  ,
                                   g_base_nlsNumericCharacters ,
                                   g_base_nlsSort      ,
                                   g_base_nlsCalendar );


         raise;
      end;

      if (wf_log_pkg.level_procedure >= fnd_log.g_current_runtime_level) then
         wf_log_pkg.string(WF_LOG_PKG.level_procedure,
                          'wf.plsql.WF_XML.generate', 'END');
      end if;
      return l_doc;

   end Generate;


   -- notificationIsOpen
   -- Return the current status of the notification
   function notificationIsOpen(nid in number) return boolean
   is
      l_open integer := 0;
   begin
      begin
         select 1
         into l_open
         from wf_notifications
         where notification_id = nid
           and status = 'OPEN';
      exception
         when others then l_open := 0;
      end;
      return l_open > 0;
   end notificationIsOpen;

-- GetResponseDetails
-- Gets the response details from the incoming XML Notifiction
-- structure.
--
-- IN
-- message - The XML Notification structure containing the
--           inbound response
procedure getResponseDetails(message in CLOB)
IS

l_node varchar2(4000);
l_version integer;
l_from_role varchar2(4000);
l_responses wf_responseList_t;

begin

    getResponseDetails(message => message,
                       node => l_node,
                       version => l_version,
                       fromRole => l_from_role,
                       responses => l_responses);

end getResponseDetails;

-- GetResponseDetails
-- Gets the response details from the incoming XML Notifiction
-- structure.
--
-- IN
-- message - The XML Notification structure containing the
--           inbound response
procedure getResponseDetails(message in CLOB, node out NOCOPY varchar2,
                             version out NOCOPY integer,
                             fromRole out NOCOPY varchar2,
                             responses in out NOCOPY wf_responseList_t)
IS

p xmlparser.parser;
doc xmldom.DOMDocument;

nl xmldom.DOMNodeList;
len1 number;
len2 number;
n xmldom.DOMNode;
m xmldom.DOMNode;
nnm xmldom.DOMNamedNodeMap;

fromAddress varchar2(4000);
attrname varchar2(4000);
attrval varchar2(4000);

node_data varchar2(32000);
node_name varchar2(4000);
from_node_found boolean;

attribute_found boolean;
response_count number;

response_attr_name varchar2(4000);
response_attr_val varchar2(32000);
response_attr_type varchar2(4000);
response_attr_format varchar2(4000);

step varchar2(200);

begin

   from_node_found := FALSE;
   attribute_found := FALSE;
   response_count := 0;
   responses.delete;
   node := '';
   fromRole := '';

   -- new parser
   p := xmlparser.newParser;

   -- set some characteristics
   xmlparser.setValidationMode(p, FALSE);

   -- parse input file
   xmlparser.parseClob(p, message);

   -- get document
   doc := xmlparser.getDocument(p);

   -- get all elements
   nl := xmldom.getElementsByTagName(doc, '*');
   len1 := xmldom.getLength(nl);

   -- loop through elements
   for j in 0..len1-1 loop

      n := xmldom.item(nl, j);
      node_name := xmldom.getNodeName(n);

      step := 'Processing ['||node_name||']';
      if node_name = 'NOTIFICATION' then

         -- get all attributes of element
         nnm := xmldom.getAttributes(n);

         if (xmldom.isNull(nnm) = FALSE) then

            len2 := xmldom.getLength(nnm);

            -- loop through attributes
            for i in 0..len2-1 loop

               m := xmldom.item(nnm, i);
               attrname := xmldom.getNodeName(m);

               step := 'Processing ['||node_name||'] ['||attrname||']';

               if attrname = 'node' then

                  attrval := xmldom.getNodeValue(m);
                  node := attrval;
               elsif attrname = 'version' then

                  attrval := xmldom.getNodeValue(m);
                  begin
                     version  := to_number(attrval);
                  exception
                     when others then
                        version := 0;
                  end;
               end if;

            end loop;


         end if;

      elsif node_name = 'FROM' then

         from_node_found := TRUE;

      elsif node_name = 'NAME' then

         if from_node_found then

            n := xmldom.getFirstChild(n);

            if ((not xmldom.isNull(n))
                and (xmldom.getNodeType(n) = xmldom.TEXT_NODE)) then

               node_data := xmlDom.getNodeValue(n);
               fromRole := node_data;

            end if;

         end if;

      elsif node_name = 'ADDRESS' then

         if from_node_found then

            from_node_found := FALSE;

            n := xmldom.getFirstChild(n);

            if ((not xmldom.isNull(n))
                and (xmldom.getNodeType(n) = xmldom.TEXT_NODE)) then

               node_data := xmlDom.getNodeValue(n);
               fromAddress := node_data;

               fromRole := '"'||fromRole||'" <'||fromAddress||'>';

            end if;

         end if;

      elsif node_name = 'ATTRIBUTE' then

         -- get all attributes of element
         nnm := xmldom.getAttributes(n);

         if (xmldom.isNull(nnm) = FALSE) then

            attribute_found := FALSE;
            response_attr_name := '';
            response_attr_val := '';
            response_attr_type := '';
            response_attr_format := '';

            len2 := xmldom.getLength(nnm);

            -- loop through attributes
            for i in 0..len2-1 loop

               m := xmldom.item(nnm, i);
               attrname := xmldom.getNodeName(m);

               step := 'Processing ['||node_name||'] ['||attrname||']';

               if attrname = 'name' then

                  attribute_found := TRUE;
                  attrval := xmldom.getNodeValue(m);
                  response_attr_name := attrval;

               elsif attrname = 'type' then

                  attrval := xmldom.getNodeValue(m);
                  response_attr_type := attrval;

               elsif attrname = 'format' then

                  attrval := xmldom.getNodeValue(m);
                  response_attr_format := attrval;

               end if;

            end loop;

            if attribute_found then

               n := xmldom.getFirstChild(n);

               if ((not xmldom.isNull(n)) and
                   (xmldom.getNodeType(n) = xmldom.TEXT_NODE)) then

                  node_data := substrb(xmlDom.getNodeValue(n), 1, 32000);
                  response_attr_val := node_data;
               end if;

               response_count := response_count + 1;
               responses(response_count).NAME := response_attr_name;
               responses(response_count).TYPE := response_attr_type;
               responses(response_count).FORMAT := response_attr_format;
               responses(response_count).VALUE := response_attr_val;


            end if;

         end if;

      end if;
      step := 'Fishished {'||step||'}';

   end loop;

   if (not xmldom.isNull(doc)) then
      xmldom.freeDocument (doc);
   end if;

   xmlparser.freeParser (p);

exception

when xmldom.INDEX_SIZE_ERR then
   wf_core.context('WF_XML','getResponseDetails', step);
   raise;

when xmldom.DOMSTRING_SIZE_ERR then
   wf_core.context('WF_XML','getResponseDetails', step);
   raise;

when xmldom.HIERARCHY_REQUEST_ERR then
   wf_core.context('WF_XML','getResponseDetails', step);
   raise;

when xmldom.WRONG_DOCUMENT_ERR then
   wf_core.context('WF_XML','getResponseDetails', step);
   raise;

when xmldom.INVALID_CHARACTER_ERR then
   wf_core.context('WF_XML','getResponseDetails', step);
   raise;

when xmldom.NO_DATA_ALLOWED_ERR then
   wf_core.context('WF_XML','getResponseDetails', step);
   raise;

when xmldom.NO_MODIFICATION_ALLOWED_ERR then
   wf_core.context('WF_XML','getResponseDetails', step);
   raise;

when xmldom.NOT_FOUND_ERR then
   wf_core.context('WF_XML','getResponseDetails', step);
   raise;

when xmldom.NOT_SUPPORTED_ERR then
   wf_core.context('WF_XML','getResponseDetails', step);
   raise;

when xmldom.INUSE_ATTRIBUTE_ERR then
   wf_core.context('WF_XML','getResponseDetails', step);
   raise;

when others then
   wf_core.context('WF_XML','getResponseDetails', step);
   raise;

end getResponseDetails;


   -- sendNotification
   -- This API is a wrapper to the wf_xml.enqueueNotification. It is provided
   -- as forward compatabilty for the original mailer since the call to
   -- wf_xml.enqueueNotification has been removed from
   -- wf_notification.sendSingle.
   -- To use the original mailer, one must enable the subscription that will
   -- call this rule function.
   -- IN
   -- p_subscription
   -- p_event
   -- RETURN
   -- varchar2 of the status
   function SendNotification (p_subscription_guid in raw,
                     p_event in out NOCOPY WF_EVENT_T) return varchar2
   is
      l_eventName varchar2(80);
      l_eventkey varchar(80);
      l_nid number;
   begin
      l_eventkey := p_event.GetEventKey();
      l_nid := to_number(l_eventKey);
      l_eventName := p_event.GetEventName();
      if l_eventName in (wf_xml.WF_NTF_SEND_MESSAGE, wf_xml.WF_NTF_CANCEL,
                         wf_xml.WF_NTF_REASIGN) then
         wf_xml.enqueueNotification(l_nid);
      else
         return wf_rule.default_rule(p_subscription_guid, p_event);
      end if;
      return 'SUCCESS';
   exception
      when others then
         wf_core.Context('WF_XML','SendNotification',p_event.getEventName(),
                         p_subscription_guid);
         -- Save error message and set status to INVALID so mailer will
         -- bounce an "invalid reply" message to sender.
         wf_event.SetErrorInfo(p_event, 'ERROR');
         return 'ERROR';
   end sendNotification;


   -- handleRecevieEvent
   --
   function handleReceiveEvent(p_subscription_guid in raw,
                     p_event in out NOCOPY WF_EVENT_T) return varchar2
   is
      l_eventName varchar2(80);
      l_eventkey varchar(80);
      l_paramlist wf_parameter_list_t;
      l_eventData CLOB;
      l_node varchar2(30);
      l_version integer;
      l_user varchar2(320);
      l_comment varchar2(4000);
      l_fromAddr varchar2(2000);
      l_nid number;
      l_template varchar2(30);
      l_module varchar2(200);
      l_error varchar2(2000);
      i int;
      l_responses wf_responseList_t;
      lk_type varchar2(240);
      lk_code varchar2(4000);
      lk_meaning varchar2(1000);
      l_value varchar2(4000);
      l_error_result varchar2(4000);
      l_sig_policy varchar2(100);

      l_step varchar2(240);
   begin

      l_eventkey := p_event.GetEventKey();
      l_nid := to_number(l_eventKey);
      l_eventName := p_event.GetEventName();
      l_paramList := p_event.getParameterList();
      l_eventData := p_event.getEventData();

      -- Recieve the message.
      -- Unpack the content and pass it to the
      -- routine in charge of parsing it.

      -- Allow the response handling handle the closed notification
      -- 3736816 Uncommenting and reimplementing this logic to
      -- ensure that responses to CANCELED notifications are processed
      -- but do not update anything.
      l_step := 'Checking the notification status';
      if not notificationIsOpen(l_nid) then
         begin
            lk_type := '';
            lk_code := '';
            wf_log_pkg.string(WF_LOG_PKG.LEVEL_EXCEPTION,
                            'WF_XML.handleReceiveEvent',
                            'Notification is not OPEN. Submitting response '||
                            'to provide user feedback');
            Wf_Notification.Respond(l_nid, NULL, 'email:'||l_fromAddr, action_source => 'EMAIL');  --ER Bug 27224517: Approvals Source Tracking for Mobile Approval App
         exception
            when others then
               if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
                   wf_log_pkg.string(WF_LOG_PKG.level_statement,
                                    'wf.plsql.WF_XML.handleReceiveEvent',
                                    'Exception on call to Wf_Notification.Respond NID['||l_nid||'] '||
                                    'Error Msg '||sqlerrm);
               end if;

               wf_core.Context('WF_XML','handleReceiveEvent',
                               p_event.getEventName(), p_subscription_guid);
               -- Save error message and set status to INVALID so mailer will
               -- bounce an "invalid reply" message to sender.
               WF_MAIL.HandleResponseError(l_nid, lk_type, lk_code,
                                           l_error_result);
         end;
         return 'SUCCESS';
      end if;

      l_step := 'Getting the response details';
      getResponseDetails(l_eventData, l_node, l_version, l_fromAddr,
                         l_responses);

      l_step := 'Processing the responses';
      if l_responses.COUNT > 0 then
         begin
            -- Check if this notification requires a Signature. Other than DEFAULT
            -- policies, no other policy is processed by the mailer.
            Wf_Mail.GetSignaturePolicy(l_nid, l_sig_policy);
            if (l_sig_policy is not NULL and upper(l_sig_policy) <> 'DEFAULT') then
               if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
                   wf_log_pkg.string(WF_LOG_PKG.level_statement,
                                    'wf.plsql.WF_XML.handleReceiveEvent',
                                    'Signature policy is not DEFAULT');
               end if;

               -- If a new policy is added, only wfmail.msg needs to be updated
               wf_core.context('WF_XML', 'HandleReceiveEvent',
                               to_char(l_nid), l_node, l_fromAddr);
               wf_core.token('NID', to_char(l_nid));
               wf_core.raise('WFRSPR_' || l_sig_policy);
            end if;

            for i in 1..l_responses.COUNT loop
               l_step := 'Processing the responses -> '||l_responses(i).name;

               lk_type := l_responses(i).format;

               lk_code := substrb(l_responses(i).value, 1, 4000);

               if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
                  wf_log_pkg.string(WF_LOG_PKG.level_statement,
                                    'wf.plsql.WF_XML.handleReceiveEvent',
                                    'Response VALUE ['||
                                    substrb(lk_code, 1, 100)||
                                    '] TYPE ['||lk_type||']');
               end if;

               if l_version < 3 then

                  ----------------------------------
                  -- verion < 3 is a normal response
                  ----------------------------------

                  -- Process the responses for standard responses
                  if l_responses(i).type = 'LOOKUP' then
                     -- Verify the content of the lookup. This will raise
                     -- an exception if it is not matched. GetLovMeaning
                     -- allows for nulls. This is not acceptable here.

                     lk_meaning := wf_mail.GetLovMeaning(lk_type,
                                                         lk_code);
                     if lk_meaning is null then
                        if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
                            wf_log_pkg.string(WF_LOG_PKG.level_statement,
                                            'wf.plsql.WF_XML.handleReceiveEvent',
                                            'LOV Meaning is null');
                        end if;

                        wf_core.token('TYPE', lk_type);
                        wf_core.token('CODE', lk_code);
                        wf_core.raise('WFSQL_LOOKUP_CODE');
                     end if;
                  end if;
                  if (l_responses(i).type = 'MOREINFO') then
                     null; -- discard these responses
                  --else
                  -- <<sstomar>> bug 8430385
                  ELSIF ( l_responses(i).type = 'DATE' AND lk_code IS NOT null ) then                     --
                     -- Just a note :
                     --     fnd_date.canonical_to_date stores value in
                     --     varchar2(30); so it may fail for values larger than (in bytes) that.
                     --
                     wf_notification.SetAttrDate(l_nid, l_responses(i).name,
                                                 fnd_date.canonical_to_date(lk_code));
                  elsif (l_responses(i).type = 'NUMBER' ) then
                    wf_notification.SetAttrNumber(l_nid, l_responses(i).name,
                                                  fnd_number.canonical_to_number(lk_code));
                  else
                    wf_notification.setAttrText(l_nid, l_responses(i).name,
                                                                   lk_code);
                  end if;
               end if;

               -- Only process attributes of type MOREINFO on
               -- version 3 and 4 templates.
               if l_responses(i).type = 'MOREINFO'
                  and l_version in (3, 4) then
                  if lk_code is not null then
                     if l_version = 3 then

                        if l_responses(i).name = 'WFNTF_MOREINFO_FROM' then
                           l_user := DecodeEntityReference(lk_code);
                        elsif l_responses(i).name = 'WFNTF_MOREINFO_QPROMPT' then
                           if length(l_responses(i).value) > 4000 then
                              wf_core.context('WF_XML', 'HandleReceiveEvent',
                                              l_responses(i).type,
                                              l_responses(i).name, l_step);
                              lk_code := substrb(l_responses(i).value, 1,
                                                 1000);
                              wf_core.raise('WFNTF_QUESTION_TOO_LARGE');
                           end if;
                           l_comment := lk_code;
                        end if;
                     elsif l_version = 4 then
                        if l_responses(i).name = 'WFNTF_MOREINFO_APROMPT' then
                           if length(l_responses(i).value) > 4000 then
                              wf_core.context('WF_XML', 'HandleReceiveEvent',
                                              l_responses(i).type,
                                              l_responses(i).name, l_step);
                              lk_code := substrb(l_responses(i).value, 1,
                                                 1000);
                              wf_core.raise('WFNTF_QUESTION_TOO_LARGE');
                           end if;
                           l_comment := lk_code;
                        end if;
                     end if;
                  end if;
               end if;
            end loop;

            -- Update the results of the more information to the
            -- comments table by calling the update API in the
            -- correct mode based on the template version.
            l_step := 'Updating the notification';
            if l_version = 3 then
               -- Question mode
               -- Send a email back to the sender that the More Info User is invalid
                if (l_user is null or length(trim(l_user)) = 0) then
                   wf_core.raise('WFNTF_NO_ROLE');
                elsif(l_comment is null or length(trim(l_comment)) = 0) then
                  wf_core.raise('WFNTF_NO_QUESTION');
                else
                  wf_notification.UpdateInfo2(l_nid, l_user, l_fromAddr,
                                                l_comment);
               end if;
            elsif l_version = 4 then
               -- Answer mode
               l_user := null;
               if(l_comment is null or length(trim(l_comment)) = 0) then
                 wf_core.raise('WFNTF_NO_ANSWER');
               else
                 wf_notification.UpdateInfo2(l_nid, l_user, l_fromAddr,
                                               l_comment);
               end if;
            else
               -- Do not need to preserve context
               wf_engine.preserved_context := FALSE;

               if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
                  wf_log_pkg.string(WF_LOG_PKG.level_statement,
                                    'wf.plsql.WF_XML.handleReceiveEvent',
                                    'Calling Wf_Notification.Respond');
               end if;

               Wf_Notification.Respond(nid       => l_nid,
                                       responder => 'email:'||l_fromAddr,
                                       action_source => 'EMAIL');  --ER Bug 27224517: Approvals Source Tracking for Mobile Approval App
            end if;
         exception
            when others then
               if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
                  wf_log_pkg.string(WF_LOG_PKG.level_statement,
                                    'wf.plsql.WF_XML.handleReceiveEvent',
                                    'Exception in processing the Response. Step '||l_step||
                                    ' Error Msg '||sqlerrm);
               end if;

               wf_core.Context('WF_XML','handleReceiveEvent',
                               to_char(l_nid), 'Step '||l_step);
               wf_core.context('WF_MAIL','HandleRevieveEvent', to_char(l_nid));
               -- Save error message and set status to INVALID so mailer will
               -- bounce an "invalid reply" message to sender.
               WF_MAIL.HandleResponseError(l_nid, lk_type,
                                           substrb(lk_code, 1, 1000),
                                           l_error_result);
         end;
      end if;
      return 'SUCCESS';

   exception

      when others then
         wf_core.Context('WF_XML','handleReceiveEvent',p_event.getEventName(),
                         p_subscription_guid);
         -- Save error message and set status to INVALID so mailer will
         -- bounce an "invalid reply" message to sender.
         wf_event.SetErrorInfo(p_event, 'ERROR');
         return 'ERROR';

   end handleReceiveEvent;


   -- receive
   -- Handle the notification receive events
   -- This will handle the processing of the inbound responses
   -- IN
   -- p_subscription_guid - The RAW GUID of the event subscription
   -- p_event - The WF_EVENT_T containing the event information
   -- RETURN
   -- varchar2 of the status
   function receive (p_subscription_guid in raw,
                     p_event in out NOCOPY WF_EVENT_T) return varchar2
   is
      l_eventName varchar2(80);
      result varchar2(30);
      erragt    wf_agent_t;
      l_paramlist wf_parameter_list_t;
      errMsg varchar2(4000);
      errStack varchar2(4000);

   begin

      l_eventName := p_event.GetEventName();
      l_paramList := p_event.getParameterList();

      if l_eventName = WF_NTF_RECEIVE_MESSAGE then

         result := handleReceiveEvent(p_subscription_guid, p_event);

      elsif l_eventName = WF_NTF_RECEIVE_ERROR then
         errMsg := wf_event.getValueForParameter('ERROR_MESSAGE',
                                              l_paramList);
         errStack := wf_event.getValueForParameter('ERROR_STACK',
                                              l_paramList);
         p_event.setErrorSubscription(p_subscription_guid);
         p_event.setErrorMessage(substrb(errMsg,1,4000));
         p_event.setErrorStack(substrb(errStack,1,4000));
         p_event.addParameterToList('ERROR_NAME', 'WF_NTF_RECEIVE_ERROR');
         p_event.addParameterToList('ERROR_TYPE', 'ERROR');

         erragt := wf_agent_t('WF_ERROR', wf_event.local_system_name);

         --
         -- sjm - lets just call the API directly
         --
         wf_error_qh.enqueue(p_event, erragt);

         result := 'SUCCESS';

      else

         return wf_rule.default_rule(p_subscription_guid, p_event);

      end if;

      return result;

   exception

      when others then
         wf_core.Context('WF_XML','Receive',p_event.getEventName(),
                         p_subscription_guid);
         -- Save error message and set status to INVALID so mailer will
         -- bounce an "invalid reply" message to sender.
         wf_event.SetErrorInfo(p_event, 'ERROR');
         return 'ERROR';
   end receive;

   -- SummaryRule
   -- To handle the summary notification request event
   -- and call the approapriate summary generate function for
   -- either the role or the member of the role.
   -- IN
   -- p_subscription_guid The RAW GUID for the subscription
   -- p_event The WF_EVENT_T containing the event details
   -- OUT
   -- VARCHAR2 - The status
   function SummaryRule (p_subscription_guid in raw,
                     p_event in out NOCOPY WF_EVENT_T) return varchar2
   is
      l_eventName varchar2(80);
      l_eventkey varchar(80);
      l_paramlist wf_parameter_list_t;
      type t_users is table of boolean index by varchar2(320);
      l_sum_users t_users ;

      l_event_paramlist wf_parameter_list_t;
   -- NOTE: For bug 6049086, more_info_role is included in the SQL
   --       in order to send summary mail to more_info_role and not
   --       to recepient_role if notification more_info_role is not null.
      CURSOR c_get_summary_roles is
      SELECT recipient from
       (SELECT distinct nvl(more_info_role,recipient_role) recipient
      FROM   wf_notifications
      WHERE  mail_status is null
      AND    status = 'OPEN'
      AND    rownum > 0)
      WHERE  Wf_Directory.GetRoleNtfPref(recipient) in ('SUMMARY', 'SUMHTML');

      -- returns the roles with notification preference of 'QUERY'
      -- and having some open notifications
      CURSOR c_get_query_roles is
      SELECT recipient from
        (SELECT distinct nvl(more_info_role,recipient_role) recipient
         FROM   wf_notifications
         WHERE  mail_status is null
         AND    status = 'OPEN'
         AND    rownum > 0) , wf_roles wr
      WHERE recipient = wr.NAME
      AND wr.notification_preference = 'QUERY';


      -- returns the users having the notification preference of
      -- 'SUMMARY' or 'SUMHTML' for the given role
      CURSOR c_get_sum_users(p_roleName VARCHAR2) is
      SELECT user_name
      FROM wf_user_roles wu, wf_roles wr
      WHERE wu.role_name = p_roleName
      AND  wr.name = wu.user_name
      AND  wu.user_orig_system = wr.orig_system
      AND  wu.user_orig_system_id = wr.orig_system_id
      AND  wr.notification_preference in ('SUMMARY', 'SUMHTML');


   begin

      l_eventkey := p_event.GetEventKey();
      l_eventName := p_event.GetEventName();
      l_paramList := p_event.getParameterList();

      for rec_summary_role in c_get_summary_roles loop

           l_event_paramlist := wf_parameter_list_t();
           wf_event.addParameterToList('ROLE_NAME',
                                        rec_summary_role.RECIPIENT,
                                        l_event_paramlist);
           -- Set AQs correlation id to item type i.e. 'WFMAIL'
           wf_event.addParameterToList('Q_CORRELATION_ID', 'WFMAIL:SUM',
                                        l_event_paramlist);
           wf_event.addParameterToList('NOTIFICATION_ID', '0',
                                        l_event_paramlist);

           wf_event.raise(WF_NTF_SEND_SUMMARY,
                          rec_summary_role.RECIPIENT||':'||sysdate,
                          null, l_event_paramlist);
           -- adds the users to the table l_sum_users
           l_sum_users(rec_summary_role.RECIPIENT) := true;
      end loop;

      -- Bug 8675013: raises the summary event for the users with notification
      -- preference of 'SUMMARY' or 'SUMHTML' and having open
      -- notifications received through their roles i.e the users having
      -- open notifications with preference of 'SUMMARY' or
      -- 'SUMHTML' and whose role preference is 'QUERY'

      for rec_query_role IN c_get_query_roles loop

          FOR rec_role_user IN c_get_sum_users(rec_query_role.recipient) loop

           -- Checks that the summary event is already raised for the user in
           -- cursor 'c_get_summary_roles'. If not, then only raise the event here
           if(not l_sum_users.exists(rec_role_user.user_name)) then
              l_event_paramlist := wf_parameter_list_t();
                  wf_event.addParameterToList('ROLE_NAME',
                                              rec_role_user.user_name,
                                              l_event_paramlist);
                  -- Set AQs correlation id to item type i.e. 'WFMAIL'
                  wf_event.addParameterToList('Q_CORRELATION_ID', 'WFMAIL:SUM',
                                              l_event_paramlist);
                  wf_event.addParameterToList('NOTIFICATION_ID', '0',
                                              l_event_paramlist);
                  wf_event.raise(WF_NTF_SEND_SUMMARY,
                                 rec_role_user.user_name||':'||sysdate,
                                 null, l_event_paramlist);

                  -- Bug 16397465: Add the users to the table l_sum_users once the
		  -- summary event is raised, so that duplicate notifications will
		  -- not be sent
                  l_sum_users(rec_role_user.user_name) := true;

               end if;

          END LOOP;
      END LOOP;

      return 'SUCCESS';

   exception

      when others then
         wf_core.Context('WF_XML','SummaryRule',p_event.getEventName(),
                         p_subscription_guid);
         wf_event.SetErrorInfo(p_event, 'ERROR');
         return 'ERROR';
   end SummaryRule;

   -- Parse the XML message and seperate out the main elements
   -- so that a new notification can be constructed including
   -- the information on the previous email.
   procedure getMessageDetails(pmessage IN CLOB,
                               pnode OUT NOCOPY varchar2,
                               planguage OUT NOCOPY varchar2,
                               pterritory OUT NOCOPY varchar2,
                               pcodeset OUT NOCOPY varchar2,
                               pcontentBody OUT NOCOPY varchar2,
                               psubject OUT NOCOPY varchar2,
                               pFromRole OUT NOCOPY varchar2,
                               pFromAddress OUT NOCOPY varchar2)
   is
      p xmlparser.parser;
      doc xmldom.DOMDocument;

      nl xmldom.DOMNodeList;
      len1 number;
      len2 number;
      n xmldom.DOMNode;
      m xmldom.DOMNode;
      nnm xmldom.DOMNamedNodeMap;

      from_node_found boolean := FALSE;
      fromRole varchar2(4000);
      fromAddress varchar2(4000);

      node_data varchar2(4000);
      node_name varchar2(4000);
      attrname varchar2(4000);
      attrval varchar2(4000);


      subject varchar2(4000);

      contentType varchar2(4000);
      textPlain_found boolean := FALSE;

   begin

      -- new parser
      p := xmlparser.newParser;

      -- set some characteristics
      xmlparser.setValidationMode(p, FALSE);

      -- parse input file
      xmlparser.parseClob(p, pmessage);

      -- get document
      doc := xmlparser.getDocument(p);

      -- get all elements
      nl := xmldom.getElementsByTagName(doc, '*');
      len1 := xmldom.getLength(nl);

      -- loop through elements
      for j in 0..len1-1 loop
         n := xmldom.item(nl, j);
         node_name := xmldom.getNodeName(n);

         if node_name = 'NOTIFICATION' then
            -- get all attributes of element
            nnm := xmldom.getAttributes(n);

            if (xmldom.isNull(nnm) = FALSE) then

               len2 := xmldom.getLength(nnm);

               -- loop through attributes
               for i in 0..len2-1 loop
                  m := xmldom.item(nnm, i);
                  attrname := xmldom.getNodeName(m);
                  if attrname = 'node' then
                     attrval := xmldom.getNodeValue(m);
                     pnode := attrval;
                     -- exit;
                  elsif attrname = 'language' then
                     attrval := xmldom.getNodeValue(m);
                     planguage := attrval;
                  elsif attrname = 'territory' then
                     attrval := xmldom.getNodeValue(m);
                     pterritory := attrval;
                  elsif attrname = 'codeset' then
                     attrval := xmldom.getNodeValue(m);
                     pcodeset := attrval;
                  end if;

               end loop;
            end if;
         elsif node_name = 'SUBJECT' then
            n := xmldom.getFirstChild(n);

            if ((not xmldom.isNull(n)) and
                (xmldom.getNodeType(n) = xmldom.TEXT_NODE)) then

               node_data := xmlDom.getNodeValue(n);
               psubject := node_data;

            end if;

         elsif node_name = 'FROM' then
            from_node_found := TRUE;

         elsif node_name = 'NAME' then
            if from_node_found then
               n := xmldom.getFirstChild(n);

               if ((not xmldom.isNull(n)) and
                   (xmldom.getNodeType(n) = xmldom.TEXT_NODE)) then

                  node_data := xmlDom.getNodeValue(n);
                  pfromRole := node_data;

               end if;
            end if;
         elsif node_name = 'ADDRESS' then
            if from_node_found then

               from_node_found := FALSE;

               n := xmldom.getFirstChild(n);

               if ((not xmldom.isNull(n)) and
                   (xmldom.getNodeType(n) = xmldom.TEXT_NODE)) then

                  node_data := xmlDom.getNodeValue(n);
                  pfromAddress := node_data;

               end if;
            end if;
         elsif node_name = 'MESSAGE' then

            nnm := xmldom.getAttributes(n);

            if (xmldom.isNull(nnm) = FALSE) then

               len2 := xmldom.getLength(nnm);

               -- loop through attributes
               for i in 0..len2-1 loop
                  m := xmldom.item(nnm, i);
                  attrname := xmldom.getNodeName(m);
                  if upper(attrname) = 'CONTENT-TYPE' then
                     attrval := xmldom.getNodeValue(m);
                     contentType := attrval;
                     exit;
                  end if;
               end loop;
               textPlain_found := upper(contentType) = 'TEXT/PLAIN';
            end if;
            if textPlain_found then
               n := xmldom.getFirstChild(n);

               if ((not xmldom.isNull(n)) and
                   (xmldom.getNodeType(n) = xmldom.TEXT_NODE)) then

                  node_data := xmlDom.getNodeValue(n);
                  pcontentBody := node_data;
               end if;
            end if;
         end if;
      end loop;

   end getMessageDetails;

   FUNCTION error_rule(p_subscription_guid in raw,
                    p_event in out nocopy wf_event_t) return varchar2
   is
      nid number;
      param_list wf_parameter_list_t;
      cb varchar2(240);
      ctx varchar2(2000);
      itemType varchar2(8);
      itemKey varchar2(240);
      items pls_integer;
      role varchar2(320);

      colPos1 pls_integer;
      colPos2 pls_integer;

      error_name varchar2(4000);
      error_msg varchar2(4000);
      error_stack varchar2(4000);

      -- Dynamic sql stuff
      sqlbuf varchar2(120);
      tvalue varchar2(4000) := '';
      nvalue number := '';
      dvalue date := '';
      command varchar2(200) :='ERROR';

      status varchar2(8);
      l_dummy varchar2(1);

    begin
      param_list := p_event.Parameter_List;
      nid := to_number(wf_event.getValueForParameter('NOTIFICATION_ID',
                                                   param_list));
      error_msg := p_event.getErrorMessage;
      error_stack := p_event.getErrorStack;
      begin
         select MESSAGE_TYPE, CALLBACK, CONTEXT, STATUS
         into   itemType, cb, ctx, status
         from   WF_NOTIFICATIONS
         where  NOTIFICATION_ID = nid;

         -- If the notification is closed, then do not bother
         -- to process any errors.
         if status = 'CLOSED' then
            return 'SUCCESS';
         end if;

         update wf_notifications
         set mail_status = 'ERROR'
         where notification_id = nid;

         if ctx is not null then
            colPos1 := instrb(ctx, ':', 1);
            colPos2 := instrb(ctx, ':', -1);
            if colPos1 > 0 and colPos2 > 0 then
               itemKey := substrb(ctx, colPos1+1, (colPos2 - colPos1) -1);
            else
               itemType := null;
               itemKey := null;
            end if;
         else
            itemType := null;
            itemKey := null;
         end if;

      exception
        when others then
           cb := null;
           ctx := null;
           itemType := null;
           itemKey := null;
           return 'SUCCESS';
      end;

      -- Check to see if the item type still exists and is not
      -- complete. If it does not exist or is complete, then
      -- do not bother with processing the error.
      if itemType is not null and itemKey is not null then
         begin
            select ACTIVITY_STATUS
            into status
            from wf_item_activity_statuses ias
                 , wf_process_activities pa
           where ias.item_type = itemType
             and ias.item_key = itemKey
             and ias.process_activity    = pa.instance_id
             and pa.process_name = 'ROOT';

           -- This will prevent FYI message that are in error being reported.
           -- if status = wf_engine.eng_completed then
           --    return 'SUCCESS';
           -- end if;

         exception
            when no_data_found then
               return 'SUCCESS';
            when others then
               error_msg := sqlerrm;
               wf_core.context('WF_XML','ERROR_RULE','NID['||to_char(nid)||']',
                               'CTX['||ctx||']');
               raise;
         end;
      else
         return 'SUCCESS';
      end if;

      if cb is not null then
        -- Put the error onto the stack.
        begin
            wf_core.token('ERROR_MESSAGE', error_msg);
            wf_core.token('ERROR_STACK', error_stack);
            wf_core.raise('WF_ERROR');
        exception
            when others then null;
        end;
        l_dummy := '';
        -- ### cb is from table
        -- BINDVAR_SCAN_IGNORE
        sqlbuf := 'begin '||cb||
                  '(:p1, :p2, :p3, :p4, :p5, :p6, :p7); end;';
        begin
           execute immediate sqlbuf using
             in command,
             in ctx,
             in l_dummy,
             in l_dummy,
             in out tvalue,
             in out nvalue,
             in out dvalue;
        exception
           when others then
             error_msg := sqlerrm;
             wf_core.context('WF_XML','ERROR_RULE','NID['||to_char(nid)||']',
                             'CTX['||ctx||']');
             raise;
        end;
      end if;

      return wf_rule.error_rule(p_subscription_guid, p_event);

   end error_rule;

   -- Gets the LOB content for a PLSQLCLOB
   -- IN
   -- pAPI the API to call
   -- pDoc The LOB to take the document
   procedure getDocContent(pNid in NUMBER, pAPI in VARCHAR2,
                           pDoc in out nocopy CLOB)
   is
      colon pls_integer;
      slash pls_integer;
      procname varchar2(240);
      procarg varchar2(32000);

      target   varchar2(240) := '_main';
      disptype varchar2(240) := g_ntfDocHtml;
      doctype varchar2(240);

      sqlbuf varchar2(2000);

   begin

     colon := instr(pAPI, ':');
     slash := instr(pAPI, '/');
     if (slash = 0) then
       procname := substr(pAPI, colon+1);
       procarg := '';
     else
       procname := substr(pAPI, colon+1, slash-colon-1);
       procarg := substr(pAPI, slash+1);
     end if;

     -- Dynamic sql call to procedure

     if (procarg is null) then
        procarg := '-dummy-';
     elsif pNid > 0 then
        procarg := Wf_Notification.GetText(procarg, pNid, disptype);
     end if;

     sqlbuf := 'begin '||procname||'(:p1, :p2, :p3, :p4); end;';
     execute immediate sqlbuf using
        in procarg,
        in disptype,
        in out pDoc,
        in out doctype;

   end getDocContent;

   -- Gets the LOB content for a PLSQLCLOB
   -- IN
   -- pAPI the API to call
   -- pDoc The LOB to take the document
   procedure getBDocContent(pNid in NUMBER, pAPI in VARCHAR2,
                           pDoc in out nocopy BLOB)
   is

      colon pls_integer;
      slash pls_integer;
      procname varchar2(240);
      procarg varchar2(32000);

      target   varchar2(240) := '_main';
      disptype varchar2(240) := g_ntfDocHtml;
      doctype varchar2(240);

      sqlbuf varchar2(2000);

   begin

     colon := instr(pAPI, ':');
     slash := instr(pAPI, '/');
     if (slash = 0) then
       procname := substr(pAPI, colon+1);
       procarg := '';
     else
       procname := substr(pAPI, colon+1, slash-colon-1);
       procarg := substr(pAPI, slash+1);
     end if;

     -- Dynamic sql call to procedure

     if (procarg is null) then
        procarg := '-dummy-';
     elsif pNid > 0 then
        procarg := Wf_Notification.GetText(procarg, pNid, disptype);
     end if;

     sqlbuf := 'begin '||procname||'(:p1, :p2, :p3, :p4); end;';
     execute immediate sqlbuf using
        in procarg,
        in disptype,
        in out pDoc,
        in out doctype;

   end getBDocContent;

   -- gets the size of the current LOB table
   function getLobTableSize return number
   is
   begin
      return g_LOBTable.COUNT;
   end;


   -- Send_Rule - This is the subscription rule function for the event group
   --             'oracle.apps.wf.notification.send.group'. If the message
   --             payload is not complete return 'SUCCESS' from here, hence
   --          incomplete message payload/event will not be enqueued to
   --          WF_NOTIFICATION_OUT AQ.
   -- IN
   --    p_subscription_guid Subscription GUID as a CLOB
   --    p_event Event Message
   -- OUT
   --    Status as ERROR, SUCCESS, WARNING
   function Send_Rule(p_subscription_guid in raw,
                p_event in out nocopy wf_event_t)
        return varchar2
   is
      l_eventdata CLOB := p_event.event_data;
      l_fulldocloc number;
      l_eventKey varchar2(240) := p_event.getEventKey();
   begin

      -- If the notification is to be sent to a role whose message payload
      -- has multiple values for 'full-document' parameter, in that case
      -- we should enqueue the notification to WF_NOTIFICATION_OUT queue
      -- so that email notification will be sent to the users having the
      -- full-document="Y" value

      l_fulldocloc := dbms_lob.instr(l_eventdata, 'full-document="Y"', 1, 1);

      -- If string not found checking for the lower case letter
      if( l_fulldocloc <= 0) then
        l_fulldocloc := dbms_lob.instr(l_eventdata, 'full-document="y"', 1, 1);
      end if;

      if (l_fulldocloc > 0) then
        if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
           wf_log_pkg.string(wf_log_pkg.level_statement,
                       'wf.plsql.WF_XML.Send_Rule',
                       'Full Message for the event key '||l_eventKey||'.'
               ||'Running the default rule function.');
        end if;
        return wf_rule.default_rule(p_subscription_guid, p_event);
      else

        if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
           wf_log_pkg.string(wf_log_pkg.level_statement,
                       'wf.plsql.WF_XML.Send_Rule',
                       'No Full Message for the event key '||l_eventKey||'.'
               ||'NOT enquing the message into WF_NOTIFICATION_OUT queue.');
        end if;
        return 'SUCCESS';
      end if;

   end Send_Rule;

   -- ER 6312101
   -- Bug 20858232: Get the catetories field specified in the attribute value
   -- parseFNDAttchAttr - Parses the #ATTACHMENTS attribute value and returns the entity
   --                     and pk values. The attribute value will be of format
   --                     FND:entity=<Entity>&pk1name=<KeyName>&pk1value=<KeyValue>&categories=CUSTOM105,MISC
   --
   -- IN
   --    p_attr_val     -  #ATTACHMENTS attribute value
   --
   -- OUT
   --    p_entity       -  Entity name handle
   --    p_pk1Val       -  pk1 value
   --    p_pk2Val       -  pk2 value
   --    p_pk3Val       -  pk3 value
   --    p_pk4Val       -  pk4 value
   --    p_pk5Val       -  pk5 value
   procedure parseFNDAttchAttr(p_attr_val in varchar2,
                               p_entity out nocopy varchar2,
                               p_pk1Val out nocopy varchar2,
                               p_pk2Val out nocopy varchar2,
                               p_pk3Val out nocopy varchar2,
                               p_pk4Val out nocopy varchar2,
                               p_pk5Val out nocopy varchar2,
			       p_categories out nocopy varchar2)
   is

      l_nameValueStr varchar2(600);
      j number ;
      l_token varchar2(600);

      stParser WF_MAIL_UTIL.parserStack_t;
      nameValueParser WF_MAIL_UTIL.parserStack_t;

   begin

      if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
         wf_log_pkg.string(wf_log_pkg.level_statement,
                              'wf.plsql.WF_XML.parseFNDAttchAttr',
                              'BEGIN, attr value:'||p_attr_val);
      end if;

      -- Get the name value pairs
      stParser := WF_MAIL_UTIL.strParser(p_attr_val, '&');

      for i in 1..stParser.COUNT loop
         l_nameValueStr := stParser(i);
	 if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
               wf_log_pkg.string(wf_log_pkg.level_statement,
                               'wf.plsql.WF_XML.parseFNDAttchAttr',
                               'The name value pair: :'||l_nameValueStr);
         end if;

         -- Get each token in name value pair and assign the value to corresponding
	 -- parameter
	 nameValueParser := WF_MAIL_UTIL.strParser(l_nameValueStr, '=');

         j := 1;
         while(j <= nameValueParser.COUNT) loop
	   l_token := nameValueParser(j);

           if(l_token = 'pk1value') then
              p_pk1Val := nameValueParser(j+1);
	      j := j+1;
	   end if;
	   if(l_token = 'pk2value') then
              p_pk2Val := nameValueParser(j+1);
	      j := j+1;
	   end if;
	   if(l_token = 'pk3value') then
              p_pk3Val := nameValueParser(j+1);
	      j := j+1;
	   end if;
	   if(l_token = 'pk4value') then
              p_pk4Val := nameValueParser(j+1);
	      j := j+1;
	   end if;
	   if(l_token = 'pk5value') then
              p_pk5Val := nameValueParser(j+1);
	      j := j+1;
	   end if;
           if(l_token = 'FND:entity') then
              p_entity := nameValueParser(j+1);
	      j := j+1;
	   end if;
	   if(l_token = 'categories') then
              p_categories := nameValueParser(j+1);
	      j := j+1;
	   end if;

	   j := j + 1;

	end loop;

      end loop;

      if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
         wf_log_pkg.string(wf_log_pkg.level_statement,
                      'wf.plsql.WF_XML.parseFNDAttchAttr',
                      'The pk parameters are:'|| p_pk1Val || ',' ||  p_pk2Val || ',' || p_pk3Val ||
                      ',' || p_pk4Val || ',' || p_pk5Val || ',' || p_entity || ',' || p_categories);
      end if;

   exception
      when others then
        if (wf_log_pkg.level_error >= fnd_log.g_current_runtime_level) then
            wf_log_pkg.string(WF_LOG_PKG.level_error,
                          'wf.plsql.WF_XML.parseFNDAttchAttr',
                          'Error when parsing FND attachment attribute -> '||sqlerrm);
        end if;
        wf_core.context('WF_XML', 'parseFNDAttchAttr', p_attr_val);
        raise;
   end parseFNDAttchAttr;

   -- Bug 30681832 : code changes to validate the document association with notification.
    -- get_attachment_details based on notification id
    -- IN
    -- p_nid as notification id
    -- p_doc_id  as document id
    -- OUT
    -- p_doc_id  as document id associated to notification
    -- p_media_id as mediaid associated to attached document
 procedure get_attachment_details(p_nid in number,
                                  p_doc_id in out nocopy number,
                                  p_media_id out nocopy number)
 as
    l_document_id fnd_attached_documents.document_id%type;
    l_entity_name fnd_attached_documents.entity_name%type;
    l_pk1_value fnd_attached_documents.pk1_value%type;
    l_pk2_value fnd_attached_documents.pk2_value%type;
    l_pk3_value fnd_attached_documents.pk3_value%type;
    l_pk4_value fnd_attached_documents.pk4_value%type;
    l_pk5_value fnd_attached_documents.pk5_value%type;
    l_attr_val wf_notification_attributes.text_value%type;
    l_media_id fnd_documents_vl.media_id%type;
    l_entity fnd_attached_documents.entity_name%type;
    l_categories varchar2(100);
   begin
     select text_value
     into l_attr_val
     from wf_notification_attributes
     where notification_id = p_nid
     and name = '#ATTACHMENTS';

   parseFNDAttchAttr(l_attr_val,
                     l_entity,
                     l_pk1_value,
                     l_pk2_value,
                     l_pk3_value,
                     l_pk4_value,
                     l_pk5_value,
                     l_categories);
   select fad.document_id ,
         fdv.media_id
   into l_document_id,
        l_media_id
   from fnd_attached_documents fad,
		fnd_documents_vl fdv,
		fnd_document_categories_vl fdcv
   where fad.document_id = fdv.document_id
    and fdcv.category_id = fdv.category_id
	and fad.entity_name = l_entity
    and fad.document_id = p_doc_id
    and NVL(fad.pk1_value, 'NOTSET') = NVL(l_pk1_value, 'NOTSET')
    and NVL(fad.pk2_value, 'NOTSET') = NVL(l_pk2_value, 'NOTSET')
    and NVL(fad.pk3_value, 'NOTSET') = NVL(l_pk3_value, 'NOTSET')
    and NVL(fad.pk4_value, 'NOTSET') = NVL(l_pk4_value, 'NOTSET')
	and NVL(fad.pk5_value, 'NOTSET') = NVL(l_pk5_value, 'NOTSET');
	p_doc_id := l_document_id;
	p_media_id := l_media_id;
   end;

end WF_XML;

/
