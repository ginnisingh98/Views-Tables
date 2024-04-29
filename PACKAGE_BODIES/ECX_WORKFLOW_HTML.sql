--------------------------------------------------------
--  DDL for Package Body ECX_WORKFLOW_HTML
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ECX_WORKFLOW_HTML" as
/* $Header: ECXWHTMB.pls 120.9 2006/03/16 02:04:55 gsingh ship $ */

-- ListECXMSGQueueMessages
--   Lists Queue Messages for ECXMSG ADT
--   in P_QUEUE_NAME       Queue Name
--   in P_TRANSACTION_TYPE ECX Transaction Type
--   in P_DOCUMENT_NUMBER  ECX Document Number
--   in P_PARTY_SITE_ID    ECX Party Site Id
--   in P_MESSAGE_STATUS   Queue Message Status
--   in P_MESSAGE_ID       Queue Message Id

procedure ListECXMSGQueueMessages (
  P_QUEUE_NAME        in varchar2 ,
  P_TRANSACTION_TYPE  in varchar2 ,
  P_DOCUMENT_NUMBER   in varchar2 ,
  P_PARTY_SITE_ID     in varchar2 ,
  P_MESSAGE_STATUS    in varchar2 ,
  P_MESSAGE_ID        in varchar2
) is
  username                 varchar2(30);   -- Username to query
  admin_role               varchar2(30); -- Role for admin mode
  realname                 varchar2(240);   -- Display name of username
  s0                       varchar2(2000);       -- Dummy
  admin_mode               varchar2(1) := 'N';
  l_media                  varchar2(240) := wfa_html.image_loc;
  l_icon                   varchar2(40) := 'FNDILOV.gif';
  l_text                   varchar2(240) := '';
  l_onmouseover            varchar2(240) := wf_core.translate ('WFPREF_LOV');
  l_url                    varchar2(4000);
  l_error_msg              varchar2(240);
  l_more_data              BOOLEAN := TRUE;
  l_queue_table             varchar2(30);
  i                        binary_integer;
  /*
  ** Added to display Queue Table USER_DATA field
  */
  TYPE queue_contents_t IS REF CURSOR;
  l_qcontents              queue_contents_t;
  l_msgstate               number;
  l_charmsgstate           varchar2(240);
  l_msg_id                 RAW(16);
  l_payload                clob;
  l_state                  number;
  l_qtable                 varchar2(240);
  l_liketranstype          varchar2(240);
  l_likedocnumber          varchar2(240);
  l_likepartysiteid        varchar2(240);
  l_message                system.ecxmsg;
  l_sqlstmt                varchar2(32000);

begin
  -- Check current user has admin authority
  wfa_sec.GetSession(username);
  username := upper(username);
  wf_directory.GetRoleInfo(username, realname, s0, s0, s0, s0);

  admin_role := wf_core.translate('WF_ADMIN_ROLE');
  if (admin_role = '*' or
     Wf_Directory.IsPerformer(username, admin_role)) then
         admin_mode := 'Y';
  else

     l_error_msg := wf_core.translate('WFPREF_INVALID_ADMIN');

  end if;

  -- Check if Accessible
  wf_event_html.isAccessible('AGENTS');

  -- Set page title
  htp.htmlOpen;
  htp.headOpen;
  htp.p('<BASE TARGET="_top">');
  htp.title(wf_core.translate('WFQUEUE_MESSAGE_TITLE'));
  wfa_html.create_help_function('wf/links/t_l.htm?T_LQUEM');
  htp.headClose;
  wfa_sec.Header(FALSE,  owa_util.get_owa_service_path ||'wf_event_html.FindECXMSGQueue
Message?p_queue_name='||p_queue_name||'&'||'p_type=ECXMSG', wf_core.translate('WFQUEUE_MESSAGE_TITLE'), TRUE);
  htp.br;

  IF (admin_mode = 'N') THEN
     htp.center(htf.bold(l_error_msg));
     return;
  END IF;

   -- Column headers
  htp.tableOpen('border=1 cellpadding=3 bgcolor=white width="100%"
      summary="' || wf_core.translate('WFQUEUE_MESSAGE_TITLE') || '"');
  htp.tableRowOpen(cattributes=>'bgcolor=#006699');


  htp.tableHeader(cvalue=>'<font color=#FFFFFF>'||
                  wf_core.translate('MESSAGETYPE')||'</font>',
                  calign=>'Center',
                  cattributes=>'id="' ||
                    wf_core.translate('MESSAGETYPE') || '"');
  htp.tableHeader(cvalue=>'<font color=#FFFFFF>'||
                  wf_core.translate('MESSAGESTANDARD')||'</font>',
                  calign=>'Center',
                  cattributes=>'id="' ||
                    wf_core.translate('MESSAGESTANDARD') || '"');
  htp.tableHeader(cvalue=>'<font color=#FFFFFF>'||
                  wf_core.translate('TRANSACTIONTYPE')||'</font>',
                  calign=>'Center',
                  cattributes=>'id="' ||
                    wf_core.translate('TRANSACTIONTYPE') || '"');
  htp.tableHeader(cvalue=>'<font color=#FFFFFF>'||
                  wf_core.translate('TRANSACTIONSUBTYPE')||'</font>',
                  calign=>'Center',
                  cattributes=>'id="' ||
                    wf_core.translate('TRANSACTIONSUBTYPE') || '"');
  htp.tableHeader(cvalue=>'<font color=#FFFFFF>'||
                  wf_core.translate('DOCUMENTNUMBER')||'</font>',
                  calign=>'Center',
                  cattributes=>'id="' ||
                    wf_core.translate('DOCUMENTNUMBER') || '"');
  htp.tableHeader(cvalue=>'<font color=#FFFFFF>'||
                  wf_core.translate('PARTYID')||'</font>',
                  calign=>'Center',
                  cattributes=>'id="' ||
                    wf_core.translate('PARTYID') || '"');
  htp.tableHeader(cvalue=>'<font color=#FFFFFF>'||
                  wf_core.translate('PARTYSITEID')||'</font>',
                  calign=>'Center',
                  cattributes=>'id="' ||
                    wf_core.translate('PARTYSITEID') || '"');
  htp.tableHeader(cvalue=>'<font color=#FFFFFF>'||
                  wf_core.translate('PARTYTYPE')||'</font>',
                  calign=>'Center',
                  cattributes=>'id="' ||
                    wf_core.translate('PARTYTYPE') || '"');
  htp.tableHeader(cvalue=>'<font color=#FFFFFF>'||
                  wf_core.translate('PROTOCOLTYPE')||'</font>',
                  calign=>'Center',
                  cattributes=>'id="' ||
                    wf_core.translate('PROTOCOLTYPE') || '"');
  htp.tableHeader(cvalue=>'<font color=#FFFFFF>'||
                  wf_core.translate('PROTOCOLADDRESS')||'</font>',
                  calign=>'Center',
                  cattributes=>'id="' ||
                    wf_core.translate('PROTOCOLADDRESS') || '"');
  htp.tableHeader(cvalue=>'<font color=#FFFFFF>'||
                  wf_core.translate('ATTRIBUTE1')||'</font>',
                  calign=>'Center',
                  cattributes=>'id="' ||
                    wf_core.translate('ATTRIBUTE1') || '"');
  htp.tableHeader(cvalue=>'<font color=#FFFFFF>'||
                  wf_core.translate('ATTRIBUTE2')||'</font>',
                  calign=>'Center',
                  cattributes=>'id="' ||
                    wf_core.translate('ATTRIBUTE2') || '"');
  htp.tableHeader(cvalue=>'<font color=#FFFFFF>'||
                  wf_core.translate('ATTRIBUTE3')||'</font>',
                  calign=>'Center',
                  cattributes=>'id="' ||
                    wf_core.translate('ATTRIBUTE3') || '"');
  htp.tableHeader(cvalue=>'<font color=#FFFFFF>'||
                  wf_core.translate('ATTRIBUTE4')||'</font>',
                  calign=>'Center',
                  cattributes=>'id="' ||
                    wf_core.translate('ATTRIBUTE4') || '"');
  htp.tableHeader(cvalue=>'<font color=#FFFFFF>'||
                  wf_core.translate('ATTRIBUTE5')||'</font>',
                  calign=>'Center',
                  cattributes=>'id="' ||
                    wf_core.translate('ATTRIBUTE5') || '"');
  htp.tableHeader(cvalue=>'<font color=#FFFFFF>'||
                  wf_core.translate('MESSAGESTATE')||'</font>',
                  calign=>'Center',
                  cattributes=>'id="' ||
                    wf_core.translate('MESSAGESTATE') || '"');
  htp.tableHeader(cvalue=>'<font color=#FFFFFF>'||
                  wf_core.translate('XMLEVENTDATA')||'</font>',
                  calign=>'Center',
                  cattributes=>'id="' ||
                  wf_core.translate('XMLEVENTDATA') || '"');

  htp.tableHeader(cvalue=>'<font color=#FFFFFF>'||
                  wf_core.translate('TXTEVENTDATA')||'</font>',
                  calign=>'Center',
                  cattributes=>'id="' ||
                    wf_core.translate('TXTEVENTDATA') || '"');
  htp.tableRowClose;
  htp.tableRowOpen;
  htp.tableRowClose;

  -- Determine the Queue Table based on the Queue Name
  SELECT queue_table INTO l_qtable
  FROM all_queues
  WHERE name = p_queue_name
AND owner IN ('APPS');

  -- Convert the character message state to numbers
  IF p_message_status = 'READY' THEN
    l_state := 0;
  ELSIF p_message_status = 'WAIT' THEN
    l_state := 1;
  ELSIF p_message_status = 'PROCESSED' THEN
    l_state := 2;
  ELSIF p_message_status = 'EXPIRED' THEN
    l_state := 3;
  ELSIF p_message_status = 'ANY' THEN
    l_state := 100;
  END IF;

  -- Create Filters for Event Name and Event Key
  IF p_transaction_type IS NULL THEN
      l_liketranstype := '%';
  ELSE
      l_liketranstype := '%'||upper(p_transaction_type)||'%';
  END IF;

  IF p_document_number IS NULL THEN
      l_likedocnumber := '%';
  ELSE
      l_likedocnumber := '%'||upper(p_document_number)||'%';
  END IF;


  IF p_party_site_id IS NULL THEN
      l_likepartysiteid := '%';
  ELSE
      l_likepartysiteid := '%'||upper(p_party_site_id)||'%';
  END IF;

  -- Show rows that match our criteria
  if l_state = 100 then
    l_sqlstmt := 'SELECT msgid, state, user_data FROM '||l_qtable||
                ' WHERE 100 = :b AND q_name = :c';
  else
    l_sqlstmt := 'SELECT msgid, state, user_data FROM '||l_qtable||
                 ' WHERE STATE = :b AND q_name = :c';
  end if;

  OPEN l_qcontents FOR l_sqlstmt USING l_state, p_queue_name;
  LOOP
    FETCH l_qcontents INTO l_msg_id,
                                l_msgstate,
                                l_message;

    EXIT WHEN l_qcontents%NOTFOUND;

    -- Convert Numeric Message State to characters
    IF l_msgstate = 0 THEN
      l_charmsgstate := (wf_core.translate('READY'));
    ELSIF l_msgstate = 1 THEN
      l_charmsgstate := (wf_core.translate('WAIT'));
    ELSIF l_msgstate = 2 THEN
      l_charmsgstate := (wf_core.translate('PROCESSED'));
    ELSIF l_msgstate = 3 THEN
      l_charmsgstate := (wf_core.translate('EXPIRED'));
    ELSE
      l_charmsgstate := (wf_core.translate('UNKNOWN'));
    END IF;


    IF (upper(l_message.transaction_type) LIKE l_liketranstype
        OR l_message.transaction_type IS NULL)
    AND ( upper(l_message.document_number) LIKE l_likedocnumber
         OR l_message.document_number IS NULL )
    AND ( upper(l_message.party_site_id) LIKE l_likepartysiteid
         OR l_message.party_site_id IS NULL ) THEN

      htp.tableRowOpen(null, 'TOP');

      htp.p('<!-- Msg Id '||l_msg_id||' -->');

      if l_message.message_type is not null then
      htp.tableData(l_message.message_type, 'left', cattributes=>'headers="' ||
              wf_core.translate('MESSAGETYPE') || '"');
      else
        htp.tableData('&'||'nbsp','left',cattributes=>'headers=""');
      end if;

      if l_message.message_standard is not null then
      htp.tableData(l_message.message_standard, 'left', cattributes=>'headers="'
 ||
              wf_core.translate('MESSAGESTANDARD') || '"');
      else
        htp.tableData('&'||'nbsp','left',cattributes=>'headers=""');
      end if;

      if l_message.transaction_type is not null then
      htp.tableData(l_message.transaction_type, 'left', cattributes=>'headers="'
 ||
              wf_core.translate('TRANSACTIONTYPE') || '"');
      else
        htp.tableData('&'||'nbsp','left',cattributes=>'headers=""');
      end if;

      if l_message.transaction_subtype is not null then
      htp.tableData(l_message.transaction_subtype, 'left', cattributes=>'headers
="' ||
              wf_core.translate('TRANSACTIONSUBTYPE') || '"');
      else
        htp.tableData('&'||'nbsp','left',cattributes=>'headers=""');
      end if;

      if l_message.document_number is not null then
      htp.tableData(l_message.document_number, 'left', cattributes=>'headers="'
||
              wf_core.translate('DOCUMENTNUMBER') || '"');
      else
        htp.tableData('&'||'nbsp','left',cattributes=>'headers=""');
      end if;

      if l_message.partyid is not null then
      htp.tableData(l_message.partyid, 'left', cattributes=>'headers="' ||
              wf_core.translate('PARTYID') || '"');
      else
        htp.tableData('&'||'nbsp','left',cattributes=>'headers=""');
      end if;

      if l_message.party_site_id is not null then
      htp.tableData(l_message.party_site_id, 'left', cattributes=>'headers="' ||
              wf_core.translate('PARTYSITEID') || '"');
      else
        htp.tableData('&'||'nbsp','left',cattributes=>'headers=""');
      end if;

      if l_message.party_type is not null then
      htp.tableData(l_message.party_type, 'left', cattributes=>'headers="' ||
              wf_core.translate('PARTYTYPE') || '"');
      else
        htp.tableData('&'||'nbsp','left',cattributes=>'headers=""');
      end if;

      if l_message.protocol_type is not null then
      htp.tableData(l_message.protocol_type, 'left', cattributes=>'headers="' ||
              wf_core.translate('PROTOCOLTYPE') || '"');
      else
        htp.tableData('&'||'nbsp','left',cattributes=>'headers=""');
      end if;

      if l_message.protocol_address is not null then
      htp.tableData(l_message.protocol_address, 'left', cattributes=>'headers="'
 ||
              wf_core.translate('PROTOCOLADDRESS') || '"');
      else
        htp.tableData('&'||'nbsp','left',cattributes=>'headers=""');
      end if;

      if l_message.attribute1 is not null then
        htp.tableData(l_message.attribute1,'left', cattributes=>'headers
="' || wf_core.translate('ATTRIBUTE1') || '"');
      else
        htp.tableData('&'||'nbsp','left',cattributes=>'headers=""');
      end if;

      if l_message.attribute2 is not null then
        htp.tableData(l_message.attribute2,'left', cattributes=>'headers
="' || wf_core.translate('ATTRIBUTE2') || '"');
      else
        htp.tableData('&'||'nbsp','left',cattributes=>'headers=""');
      end if;

      if l_message.attribute3 is not null then
        htp.tableData(l_message.attribute3,'left', cattributes=>'headers
="' || wf_core.translate('ATTRIBUTE3') || '"');
      else
        htp.tableData('&'||'nbsp','left',cattributes=>'headers=""');
      end if;

      if l_message.attribute4 is not null then
        htp.tableData(l_message.attribute4,'left', cattributes=>'headers
="' || wf_core.translate('ATTRIBUTE4') || '"');
      else
        htp.tableData('&'||'nbsp','left',cattributes=>'headers=""');
      end if;

      if l_message.attribute5 is not null then
        htp.tableData(l_message.attribute5,'left', cattributes=>'headers
="' || wf_core.translate('ATTRIBUTE5') || '"');
      else
        htp.tableData('&'||'nbsp','left',cattributes=>'headers=""');
      end if;

      htp.tableData(l_charmsgstate,'center', cattributes=>'headers="' ||
          wf_core.translate('MESSAGESTATE') || '"');

      htp.tableData(htf.anchor2(curl=>wfa_html.base_url||
                                  '/wf_event_html.EventDataContents?p_message_id
='||l_msg_id
||'&'||'p_queue_table='||'APPS.'||l_qtable||'&'||'p_mimetype=text/xml',
                 ctext=>'<IMG SRC="'||wfa_html.image_loc||'affind.gif"
                          alt="' || wf_core.translate('FIND') || '"
                              BORDER=0>'),
                              'center', cattributes=>'valign="MIDDLE"
                 headers="' || wf_core.translate('XMLEVENTDATA') || '"');
      htp.tableData(htf.anchor2(curl=>wfa_html.base_url||
                                  '/wf_event_html.EventDataContents?p_message_id
='||l_msg_id
||'&'||'p_queue_table='||'APPS.'||l_qtable||'&'||'p_mimetype=text',
                 ctext=>'<IMG SRC="'||wfa_html.image_loc||'affind.gif"
                          alt="' || wf_core.translate('FIND') || '"
                              BORDER=0>'),
                              'center', cattributes=>'valign="MIDDLE"
                 headers="' || wf_core.translate('TXTEVENTDATA') || '"');
  END IF;

  END LOOP;
  CLOSE l_qcontents;

  htp.tableclose;

  htp.br;

  wfa_sec.Footer;

  htp.htmlClose;

exception
  when others then
    rollback;
    Wf_Core.Context('ECX_WORKFLOW_HTML', 'ListECXMSGQueueMessages',
                    p_queue_name);
    wfe_html_util.Error;
    --raise;
end ListECXMSGQueueMessages;


-- ListECX_INENGOBJQueueMessages
--   Lists Queue Messages for ECX_INENGOBJ ADT
--   in P_QUEUE_NAME   Queue Name
--   in P_MESSAGE_STATUS Queue Message Status
--   in P_MESSAGE_ID   ECX Message Id

procedure ListECX_INENGOBJQueueMessages (
  P_QUEUE_NAME        in varchar2 ,
  P_MESSAGE_STATUS    in   varchar2 ,
  P_MESSAGE_ID        in      varchar2
) is
  username                 varchar2(30);   -- Username to query
  admin_role               varchar2(30); -- Role for admin mode
  realname                 varchar2(240);   -- Display name of username
  s0                       varchar2(2000);       -- Dummy
  admin_mode               varchar2(1) := 'N';
  l_media                  varchar2(240) := wfa_html.image_loc;
  l_icon                   varchar2(40) := 'FNDILOV.gif';
  l_text                   varchar2(240) := '';
  l_onmouseover            varchar2(240) := wf_core.translate ('WFPREF_LOV');
  l_url                    varchar2(4000);
  l_error_msg              varchar2(240);
  l_more_data              BOOLEAN := TRUE;
  l_queue_table             varchar2(30);
  i                        binary_integer;
  /*
  ** Added to display Queue Table USER_DATA field
  */
  TYPE queue_contents_t IS REF CURSOR;
  l_qcontents              queue_contents_t;
  l_msgstate               number;
  l_charmsgstate           varchar2(240);
  l_msg_id                 RAW(16);
  l_payload                clob;
  l_state                  number;
  l_qtable                 varchar2(240);
  l_likemsgid              varchar2(240);
  l_message                system.ecx_inengobj;
  l_sqlstmt                varchar2(32000);

begin
  -- Check current user has admin authority
  wfa_sec.GetSession(username);
  username := upper(username);
  wf_directory.GetRoleInfo(username, realname, s0, s0, s0, s0);

  admin_role := wf_core.translate('WF_ADMIN_ROLE');
  if (admin_role = '*' or
     Wf_Directory.IsPerformer(username, admin_role)) then
         admin_mode := 'Y';
  else

     l_error_msg := wf_core.translate('WFPREF_INVALID_ADMIN');

  end if;

  -- Check if Accessible
  wf_event_html.isAccessible('AGENTS');

  -- Set page title
  htp.htmlOpen;
  htp.headOpen;
  htp.p('<BASE TARGET="_top">');
  htp.title(wf_core.translate('WFQUEUE_MESSAGE_TITLE'));
  wfa_html.create_help_function('wf/links/t_l.htm?T_LQUEM');
  htp.headClose;
  wfa_sec.Header(FALSE,  owa_util.get_owa_service_path ||'wf_event_html.FindECX_INENGOBJQueue
Message?p_queue_name='||p_queue_name||'&'||'p_type=INENGOBJ', wf_core.translate('WFQUEUE_MESSAGE_TITLE'), TRUE)
;
  htp.br;

  IF (admin_mode = 'N') THEN
     htp.center(htf.bold(l_error_msg));
     return;
  END IF;

   -- Column headers
  htp.tableOpen('border=1 cellpadding=3 bgcolor=white width="100%"
      summary="' || wf_core.translate('WFQUEUE_MESSAGE_TITLE') || '"');
  htp.tableRowOpen(cattributes=>'bgcolor=#006699');
  htp.tableHeader(cvalue=>'<font color=#FFFFFF>'||
                  wf_core.translate('MESSAGEID')||'</font>',
                  calign=>'Center',
                  cattributes=>'id="' ||
                    wf_core.translate('MESSAGEID') || '"');
  htp.tableHeader(cvalue=>'<font color=#FFFFFF>'||
                  wf_core.translate('DEBUGMODE')||'</font>',
                  calign=>'Center',
                  cattributes=>'id="' ||
                    wf_core.translate('DEBUGMODE') || '"');
  htp.tableHeader(cvalue=>'<font color=#FFFFFF>'||
                  wf_core.translate('MESSAGESTATE')||'</font>',
                  calign=>'Center',
                  cattributes=>'id="' ||
                    wf_core.translate('MESSAGESTATE') || '"');
  htp.tableRowClose;
  htp.tableRowOpen;
  htp.tableRowClose;

  -- Determine the Queue Table based on the Queue Name
  SELECT queue_table INTO l_qtable
  FROM all_queues
  WHERE name = p_queue_name
 AND owner IN ('APPS');

  -- Convert the character message state to numbers
  IF p_message_status = 'READY' THEN
    l_state := 0;
  ELSIF p_message_status = 'WAIT' THEN
    l_state := 1;
  ELSIF p_message_status = 'PROCESSED' THEN
    l_state := 2;
  ELSIF p_message_status = 'EXPIRED' THEN
    l_state := 3;
  ELSIF p_message_status = 'ANY' THEN
    l_state := 100;
  END IF;

  -- Create Filters for Event Name and Event Key
  IF p_message_id IS NULL THEN
      l_likemsgid := '%';
  ELSE
      l_likemsgid := '%'||upper(p_message_id)||'%';
  END IF;

  -- Show rows that match our criteria
  if l_state = 100 then
    l_sqlstmt := 'SELECT msgid, state, user_data FROM '||l_qtable||
                ' WHERE 100 = :b AND q_name = :c';
  else
    l_sqlstmt := 'SELECT msgid, state, user_data FROM '||l_qtable||
                 ' WHERE STATE = :b AND q_name = :c';
  end if;

  OPEN l_qcontents FOR l_sqlstmt USING l_state, p_queue_name;
  LOOP
    FETCH l_qcontents INTO l_msg_id,
                                l_msgstate,
                                l_message;

    EXIT WHEN l_qcontents%NOTFOUND;

    -- Convert Numeric Message State to characters
    IF l_msgstate = 0 THEN
      l_charmsgstate := (wf_core.translate('READY'));
    ELSIF l_msgstate = 1 THEN
      l_charmsgstate := (wf_core.translate('WAIT'));
    ELSIF l_msgstate = 2 THEN
      l_charmsgstate := (wf_core.translate('PROCESSED'));
    ELSIF l_msgstate = 3 THEN
      l_charmsgstate := (wf_core.translate('EXPIRED'));
    ELSE
      l_charmsgstate := (wf_core.translate('UNKNOWN'));
    END IF;


    IF (upper(l_message.msgid) LIKE l_likemsgid
        OR l_message.msgid IS NULL) THEN

      htp.tableRowOpen(null, 'TOP');

      htp.p('<!-- Msg Id '||l_msg_id||' -->');

      if l_message.msgid is not null then
      htp.tableData(l_message.msgid, 'left', cattributes=>'headers="' ||
              wf_core.translate('MESSAGEID') || '"');
      else
       htp.tableData('&'||'nbsp','left',cattributes=>'headers=""');
      end if;

      if l_message.debug_mode is not null then
      htp.tableData(l_message.debug_mode, 'left', cattributes=>'headers="'
 ||
              wf_core.translate('DEBUGMODE') || '"');
      else
        htp.tableData('&'||'nbsp','left',cattributes=>'headers=""');
      end if;

     htp.tableData(l_charmsgstate,'center', cattributes=>'headers="' ||
          wf_core.translate('MESSAGESTATE') || '"');
  END IF;

  END LOOP;
  CLOSE l_qcontents;

  htp.tableclose;

  htp.br;

  wfa_sec.Footer;

  htp.htmlClose;

exception
  when others then
    rollback;
    Wf_Core.Context('ECX_WORKFLOW_HTML', 'ListECX_INENGOBJQueueMessages',
                    p_queue_name);
    wfe_html_util.Error;
    --raise;
end ListECX_INENGOBJQueueMessages;

end ECX_WORKFLOW_HTML;

/
