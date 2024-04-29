--------------------------------------------------------
--  DDL for Package Body ALR_MLR_PACKAGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ALR_MLR_PACKAGE" as
/* $Header: alrwfmlrb.pls 120.0 2006/08/02 22:10:11 jwsmith noship $ */

--
-- Generic mailer routines
--
-- Send
-- Calls the wf_mail.send routine to send emails to the recipients in the
-- receipient list.

procedure Send(a_idstring       in varchar2,
               a_module         in varchar2,
               a_replyto        in varchar2 default null,
               a_subject        in varchar2,
               a_message        in varchar2)
is
   clobvar CLOB := EMPTY_CLOB;
   len  BINARY_INTEGER;
begin
        dbms_lob.createtemporary(clobvar, TRUE);
        dbms_lob.open(clobvar, dbms_lob.lob_readwrite);
        len := length(a_message);
        dbms_lob.writeappend(clobvar, len, a_message);
        dbms_lob.close(clobvar);

	WF_MAIL.SEND(p_idstring => a_idstring,
                     p_module => a_module,
                     p_recipient_list => ALR_EMAIL_TABLE,
                     p_replyto => a_replyto,
                     p_subject => a_subject,
                     p_message => clobvar);

        exception
	   when others then
                APP_EXCEPTION.RAISE_EXCEPTION;

        dbms_lob.freetemporary(clobvar);

end;

procedure Send2(a_idstring       in varchar2,
               a_module         in varchar2,
               a_replyto        in varchar2 default null,
               a_subject        in varchar2,
               a_chunk1         in varchar2,
               a_chunk2         in varchar2)
is
   a_message CLOB;
   OFFSET number;
   LEN number;
begin
        DBMS_LOB.CREATETEMPORARY(a_message, FALSE);
        DBMS_LOB.OPEN(a_message, DBMS_LOB.LOB_READWRITE);
        OFFSET := 1;
        LEN := LENGTH(a_chunk1);
        DBMS_LOB.WRITE(a_message, LEN, OFFSET, a_chunk1);
        OFFSET := OFFSET + LEN;
        if (a_chunk2 is not null) then
           LEN := LENGTH(a_chunk2);
           DBMS_LOB.WRITE(a_message, LEN, OFFSET, a_chunk2);
           OFFSET := OFFSET + LEN;
        end if;
	WF_MAIL.SEND(p_idstring => a_idstring,
                     p_module => a_module,
                     p_recipient_list => ALR_EMAIL_TABLE,
                     p_replyto => a_replyto,
                     p_subject => a_subject,
                     p_message => a_message);

        DBMS_LOB.FREETEMPORARY(a_message);

        exception
	   when others then
                APP_EXCEPTION.RAISE_EXCEPTION;

end;

procedure InitRecipientList
is
begin
	ALR_EMAIL_TABLE.delete;
end;

procedure AddRecipientToList(p_name  in varchar2,
                             p_value in varchar2,
			     p_recipient_type in varchar2)
is
  j number;
begin

  if (ALR_EMAIL_TABLE.COUNT = 0) then
      ALR_EMAIL_TABLE(1).name := p_name;
      ALR_EMAIL_TABLE(1).address := p_value;
      ALR_EMAIL_TABLE(1).recipient_type := p_recipient_type;
  else
  --
  -- parameter list exists, add parameter to list
  --
      j := ALR_EMAIL_TABLE.COUNT+1;

      ALR_EMAIL_TABLE(j).name := p_name;
      ALR_EMAIL_TABLE(j).address := p_value;
      ALR_EMAIL_TABLE(j).recipient_type := p_recipient_type;

  end if;

end;

function Response(p_subscription_guid in raw,
                  p_event in out NOCOPY WF_EVENT_T) return varchar2
is

l_responses wf_xml.wf_responseList_t;
--TYPE wf_response_rec_t IS RECORD
--     NAME varchar2(30),
--     TYPE varchar2(8),
--     FORMAT varchar2(240),
--     VALUE  varchar2(32000)

l_node varchar2(30);
l_version integer;
l_from varchar2(2000);
l_eventName varchar2(80);
l_eventkey varchar2(80);
l_paramlist wf_parameter_list_t;
l_eventData CLOB;
l_messageHandle varchar2(100);
tk pls_integer;
reqid number;

-- ALP_NO_RESPONSE = "N"
-- ALP_VALID_RESPONSE = "V"
-- ALP_INVALID_RESPONSE = "I"
resp_type varchar(1);
l_alert_id varchar2(100);
l_app_id varchar2(100);

-- For event key parsing
l_node_handle varchar2(100);
l_message_handle varchar2(100);
l_morcl_id varchar2(100);
ptpos1 pls_integer;
ptpos2 pls_integer;
ptpos3 pls_integer;

--GetMessageDetails
alr_msg_dtls_tbl alr_msg_dtls_tbl_type;
count_var number;
msg_handle number;
node_handle number;
morcl_id number;

--InitResponseVar
alr_init_resp_tbl alr_init_resp_tbl_type;

-- InitValidResponses
alr_init_valid_resp_tbl alr_init_valid_resp_tbl_type;

-- GetRespActions
test_resp_set_id number;
alr_get_resp_act_tbl alr_get_resp_act_tbl_type;
alr_match_resp_act_tbl alr_match_resp_act_tbl_type;

-- GetOutputValues
alr_resp_var_values_tbl alr_resp_var_values_tbl_type;

-- SaveRespHistory
received varchar2(240);

-- SaveRespActHistory
response_msg_id number;
oracle_id number;
seq number;
version_num number;
success_flag varchar2(1);

-- CloseResp
action_set_pass_fail varchar2(1);
open_closed varchar2(1);

found number;

step varchar2(200);
begin
  if (wf_log_pkg.level_procedure >= fnd_log.g_current_runtime_level) then
        wf_log_pkg.string(WF_LOG_PKG.level_procedure,
                          'alr.plsql.ALR_MLR_PACKAGE.Response', 'BEGIN');
  end if;
  l_eventkey := p_event.GetEventKey();
  l_eventName := p_event.getEventName();
  l_paramList := p_event.getParameterList();
  l_eventData := p_event.getEventData();

  -- parse the event key into the message handle
  if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
        wf_log_pkg.string(WF_LOG_PKG.level_statement,
                          'alr.plsql.ALR_MLR_PACKAGE.Response',
                          'Parsing for the node and message handle');
  end if;

  ptpos1 := instrb(l_eventKey, '.', 1)+1;
  ptpos2 := instrb(l_eventKey, '.', -1);

  ptpos3 := length(l_eventKey);
  l_node_handle := substrb(l_eventKey, 1, ptpos1 -2);
  l_message_handle := substrb(l_eventKey, ptpos1, ptpos2 - ptpos1);
  l_morcl_id := substrb(l_eventKey, ptpos2+1, ptpos3 - ptpos2);

  -- convert to number
  msg_handle := TO_NUMBER(l_message_handle);
  node_handle := TO_NUMBER(l_node_handle);
  morcl_id    := TO_NUMBER(l_morcl_id);

  if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
        wf_log_pkg.string(WF_LOG_PKG.level_statement,
                          'alr.plsql.ALR_MLR_PACKAGE.Response',
                          'Node ['||l_node_handle||'] Msg Handle ['||
                          l_message_handle||']');
  end if;
  if l_eventName = 'oracle.apps.alr.response.receive' then
     if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
           wf_log_pkg.string(WF_LOG_PKG.level_statement,
                             'alr.plsql.ALR_MLR_PACKAGE.Response',
                             'Getting response details');
     end if;
     WF_XML.getResponseDetails(message => l_eventData,
                               node => l_node,
                               version => l_version,
                               fromRole => l_from,
                               responses => l_responses);
     if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
           wf_log_pkg.string(WF_LOG_PKG.level_statement,
                             'alr.plsql.ALR_MLR_PACKAGE.Response',
                             'Got response details from ['||l_from||']');
     end if;

     step := 'Processing responses';
     -- first check if invalid response
     if (l_responses.COUNT = 0) then
         if (wf_log_pkg.level_procedure >=
                       fnd_log.g_current_runtime_level) then
                       wf_log_pkg.string(WF_LOG_PKG.level_procedure,
                      'alr.plsql.ALR_MLR_PACKAGE.Response',
                       'Invalid response (response count is zero).');
          end if;

          -- get application id, alert id, and response set
          step := 'Getting messge details';
          GetMessageDetails(msg_handle, node_handle,
                             alr_msg_dtls_tbl);

         if (wf_log_pkg.level_procedure >=
                       fnd_log.g_current_runtime_level) then
                       wf_log_pkg.string(WF_LOG_PKG.level_procedure,
                      'alr.plsql.ALR_MLR_PACKAGE.Response',
                       'After get mesage details.');
          end if;

          step := 'Saving History';
          SaveRespHistory(msg_handle, node_handle,
                          alr_msg_dtls_tbl,
                          l_from,
                          'INVALID RESPONSE',
                          0);

         if (wf_log_pkg.level_procedure >=
                       fnd_log.g_current_runtime_level) then
                       wf_log_pkg.string(WF_LOG_PKG.level_procedure,
                      'alr.plsql.ALR_MLR_PACKAGE.Response',
                       'After saveresphist');
          end if;

          reqid := fnd_request.submit_request(application => 'ALR',
                   program => 'ALPPWF',
                  argument1 => l_node_handle,
                  argument2 => l_message_handle,
                  argument3 => l_morcl_id,
                  argument4 => 'I');
                  if (reqid = 0) then
                     if (wf_log_pkg.level_statement >=
                         fnd_log.g_current_runtime_level) then
                         wf_log_pkg.string(WF_LOG_PKG.level_statement,
                        'alr.plsql.ALR_MLR_PACKAGE.Response',
                         'The request ID retued 0. Raising -20160 app error');
                      end if;
                     raise_application_error(-20160, FND_MESSAGE.GET);
                  end if;

         if (wf_log_pkg.level_statement >=
                       fnd_log.g_current_runtime_level) then
                       wf_log_pkg.string(WF_LOG_PKG.level_statement,
                      'alr.plsql.ALR_MLR_PACKAGE.Response',
                       'Concurrent request ['||to_char(reqid)||'] submitted');
          end if;
     else
       -- process valid responses
       for tk in 1..l_responses.COUNT loop
        if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
              wf_log_pkg.string(WF_LOG_PKG.level_statement,
                                'alr.plsql.ALR_MLR_PACKAGE.Response',
                                'Processing ['||l_responses(tk).name||
                                '] ['||l_responses(tk).value||']');
        end if;

       -- Alert specific processing here
       -- Check for open responses
          count_var := OpenResponses;
          if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
                wf_log_pkg.string(WF_LOG_PKG.level_statement,
                                  'alr.plsql.ALR_MLR_PACKAGE.Response',
                                  'Open responses ['||to_char(count_var)||']');
          end if;

          step := 'Processing open responses';
          if (count_var > 0) then
             -- get application id, alert id, and response set
                step := 'Getting messge details';
                GetMessageDetails(msg_handle, node_handle,
                                  alr_msg_dtls_tbl);

                If (alr_msg_dtls_tbl(1).open_closed = 'O') then
                -- Initialize the response
                   step := 'Initializing the response';
                   InitResponseVar(alr_msg_dtls_tbl,
                                alr_init_resp_tbl);

                -- Initialize valid responses
                   step := 'Initializing the valid response';
                   InitValidResponses(alr_msg_dtls_tbl,
                                      alr_init_valid_resp_tbl);

                -- Select response actions
                   step := 'Getting the response actions';
                   GetRespActions(alr_msg_dtls_tbl,
                                  alr_init_valid_resp_tbl,
                                  alr_get_resp_act_tbl);

                   found := 0;

                -- Check user's response to see if valid response
                -- First case: They entered a text value, no variables
                   for t_counter IN 1..alr_init_valid_resp_tbl.LAST LOOP
                       -- if value in email is plain text
                     if (l_responses(tk).value = alr_init_valid_resp_tbl(t_counter).resp_text) then
                         -- insert response received into history
                         found := 1;
                         step := 'Saving History';
                         received := SYSDATE;
                         SaveRespHistory(msg_handle, node_handle,
                                 alr_msg_dtls_tbl,
                                 l_from,
                                 l_responses(tk).value,
                           alr_init_valid_resp_tbl(t_counter).resp_id);

                         -- If it matches here then they did not reply
                         -- with a response variable. So, update all
                         -- response variables with default values and
                         -- save to history.
                         step := 'Saving the value history with default values';
                         SaveRespVar(alr_msg_dtls_tbl,
                              msg_handle, node_handle,
                              alr_init_resp_tbl);

                         -- CALL CONCURRENT PROGRAM TO PERFORM ACTIONS
                         if (wf_log_pkg.level_procedure >=
                             fnd_log.g_current_runtime_level) then
                             wf_log_pkg.string(WF_LOG_PKG.level_procedure,
                             'alr.plsql.ALR_MLR_PACKAGE.Response',
                             'Submitting Action Processor');
                         end if;
                         reqid := fnd_request.submit_request(application => 'ALR',
                               program => 'ALPPWF',
                               argument1 => l_node_handle,
                               argument2 => l_message_handle,
                               argument3 => l_morcl_id,
                               argument4 => 'V',
                               argument5 => l_responses(tk).name,
                               argument6 => l_responses(tk).value,
                               argument7 => l_responses(tk).format);
                        if reqid = 0 then
                          if (wf_log_pkg.level_statement >=
                             fnd_log.g_current_runtime_level) then
                             wf_log_pkg.string(WF_LOG_PKG.level_statement,
                             'alr.plsql.ALR_MLR_PACKAGE.Response',
                              'The request ID retued 0. Raising -20160 app error');
                          end if;
                          raise_application_error(-20160, FND_MESSAGE.GET);
                        end if;
                     end if;
                   END LOOP;

               -- 2nd case is if they entered a variable but no value
               -- ? is in value.
               if (l_responses(tk).value = '?' and
                   found = 0) then
                   for t_counter in 1..alr_init_valid_resp_tbl.LAST LOOP
                     if (l_responses(tk).format =
                        alr_init_valid_resp_tbl(t_counter).resp_text) then
                        found := 1;
                        -- insert response received into history
                        step := 'Saving History';
                        SaveRespHistory(msg_handle, node_handle,
                                 alr_msg_dtls_tbl,
                                 l_from,
                                 l_responses(tk).value,
                        alr_init_valid_resp_tbl(t_counter).resp_id);

                         -- If it matches here then they did not reply
                         -- with a response variable. So, update all
                         -- response variables with default values and
                         -- save to history.
                         step := 'Saving the value history with default values';
                         SaveRespVar(alr_msg_dtls_tbl,
                              msg_handle, node_handle,
                              alr_init_resp_tbl);

                        -- CALL CONCURRENT PROGRAM TO PERFORM ACTIONS
                        if (wf_log_pkg.level_procedure >=
                             fnd_log.g_current_runtime_level) then
                             wf_log_pkg.string(WF_LOG_PKG.level_procedure,
                             'alr.plsql.ALR_MLR_PACKAGE.Response',
                             'Submitting Action Processor');
                        end if;
                        reqid := fnd_request.submit_request(application => 'ALR',
                               program => 'ALPPWF',
                               argument1 => l_node_handle,
                               argument2 => l_message_handle,
                               argument3 => l_morcl_id,
                               argument4 => 'V',
                               argument5 => l_responses(tk).name,
                               argument6 => l_responses(tk).value,
                               argument7 => l_responses(tk).format);
                        if (reqid = 0) then
                          if (wf_log_pkg.level_statement >=
                             fnd_log.g_current_runtime_level) then
                             wf_log_pkg.string(WF_LOG_PKG.level_statement,
                             'alr.plsql.ALR_MLR_PACKAGE.Response',
                              'The request ID retued 0. Raising -20160 app error');
                          end if;
                           raise_application_error(-20160, FND_MESSAGE.GET);
                        end if;
                     end if;
                   end loop;
               end if;

               -- Third case is if they entered a variable and a value
               if (found = 0) then
                  for t_counter IN 1..alr_init_valid_resp_tbl.LAST LOOP
                      if (l_responses(tk).format =
                         alr_init_valid_resp_tbl(t_counter).resp_text) then
                         found := 1;

                        -- insert response received into history
                        step := 'Saving History';
                        SaveRespHistory(msg_handle, node_handle,
                                 alr_msg_dtls_tbl,
                                 l_from,
                                 l_responses(tk).value,
                        alr_init_valid_resp_tbl(t_counter).resp_id);

                         SaveOneRespVar(alr_msg_dtls_tbl,
                              msg_handle, node_handle,
                              l_responses(tk).name,
                              l_responses(tk).value,
                              alr_init_resp_tbl);

                         -- CALL CONCURRENT PROGRAM TO PERFORM ACTIONS
                         if (wf_log_pkg.level_procedure >=
                             fnd_log.g_current_runtime_level) then
                             wf_log_pkg.string(WF_LOG_PKG.level_procedure,
                             'alr.plsql.ALR_MLR_PACKAGE.Response',
                             'Submitting Action Processor');
                         end if;
                         reqid := fnd_request.submit_request(application => 'ALR',
                               program => 'ALPPWF',
                               argument1 => l_node_handle,
                               argument2 => l_message_handle,
                               argument3 => l_morcl_id,
                               argument4 => 'V',
                               argument5 => l_responses(tk).name,
                               argument6 => l_responses(tk).value,
                               argument7 => l_responses(tk).format);
                        if (reqid = 0) then
                          if (wf_log_pkg.level_statement >=
                             fnd_log.g_current_runtime_level) then
                             wf_log_pkg.string(WF_LOG_PKG.level_statement,
                             'alr.plsql.ALR_MLR_PACKAGE.Response',
                              'The request ID retued 0. Raising -20160 app error');
                          end if;
                          raise_application_error(-20160, FND_MESSAGE.GET);
                        end if;
                      end if;
                  end loop;
               end if;

               -- last case is invalid response
               if (found=0) then
                   if (wf_log_pkg.level_procedure >=
                       fnd_log.g_current_runtime_level) then
                       wf_log_pkg.string(WF_LOG_PKG.level_procedure,
                      'alr.plsql.ALR_MLR_PACKAGE.Response',
                       'Submitting Action Processor');
                   end if;
                   reqid := fnd_request.submit_request(application => 'ALR',
                            program => 'ALPPWF',
                            argument1 => l_node_handle,
                            argument2 => l_message_handle,
                            argument3 => l_morcl_id,
                            argument4 => 'V',
                            argument5 => l_responses(tk).name,
                            argument6 => l_responses(tk).value,
                            argument7 => l_responses(tk).format);
                   if (reqid = 0) then
                          if (wf_log_pkg.level_statement >=
                             fnd_log.g_current_runtime_level) then
                             wf_log_pkg.string(WF_LOG_PKG.level_statement,
                             'alr.plsql.ALR_MLR_PACKAGE.Response',
                              'The request ID retued 0. Raising -20160 app error');
                          end if;
                      raise_application_error(-20160, FND_MESSAGE.GET);
                   end if;

               end if;

               -- Close all stmts.
               end if;
         end if;
       end loop;
     end if;
  end if;

  if (wf_log_pkg.level_procedure >= fnd_log.g_current_runtime_level) then
         wf_log_pkg.string(WF_LOG_PKG.level_procedure,
                          'alr.plsql.ALR_MLR_PACKAGE.Response', 'END');
  end if;

  return 'SUCCESS';

  exception
    when others then
       wf_core.context('ALR_MLR_PKG', 'RESPONSE', l_eventName, l_eventKey,
                       'Problem encountered when performing ['||step||']');
       wf_event.SetErrorInfo(p_event, 'ERROR');
       return 'ERROR';
end Response;

function OpenResponses return number is
   count_var number;
begin
   select count(*)
   into count_var
   from alr_actual_responses
   where open_closed = 'O';

   return (count_var);

   exception
    when others then
       wf_core.context('ALR_MLR_PKG', 'RESPONSE',
                 'Exception during OpenResponses');
       raise;
end OpenResponses;

procedure GetMessageDetails(
   msg_handle in number,
   node_handle in number,
   alr_msg_dtls_tbl out NOCOPY alr_msg_dtls_tbl_type)
is
begin
   select application_id, alert_id, response_set_id, open_closed
   into alr_msg_dtls_tbl(1).app_id,
        alr_msg_dtls_tbl(1).alert_id,
        alr_msg_dtls_tbl(1).response_set_id,
        alr_msg_dtls_tbl(1).open_closed
   from alr_actual_responses
   where message_handle=msg_handle and
         node_handle= node_handle;

   exception
    when no_data_found then
    if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
          wf_log_pkg.string(WF_LOG_PKG.level_statement,
                            'alr.plsql.ALR_MLR_PACKAGE.GetMessageDetails',
                            'Error, message handle does not exist in db.');
    end if;
    wf_core.context('ALR_MLR_PKG', 'RESPONSE',
                    'Exception during GetMessageDetails');
    raise;

    when others then
       wf_core.context('ALR_MLR_PKG', 'RESPONSE',
                       'Exception during GetMessageDetails');
       raise;
end GetMessageDetails;

procedure InitResponseVar(
   alr_msg_dtls_tbl in alr_msg_dtls_tbl_type,
   alr_init_resp_tbl out NOCOPY alr_init_resp_tbl_type)
is

   CURSOR c_responses_csr (p_app_id number,
                           p_alert_id number,
                           p_response_set_id number) IS
    select variable_number, name, data_type, default_value,
           NVL(detail_max_len,0)
    from alr_response_variables
    where  application_id = p_app_id and
           alert_id=p_alert_id and
           response_set_id=p_response_set_id;
    i number;
begin
   i := 1;
   OPEN c_responses_csr(alr_msg_dtls_tbl(1).app_id,
                        alr_msg_dtls_tbl(1).alert_id,
                        alr_msg_dtls_tbl(1).response_set_id);
   LOOP
      FETCH c_responses_csr into
         alr_init_resp_tbl(i).var_num,
         alr_init_resp_tbl(i).name,
         alr_init_resp_tbl(i).data_type,
         alr_init_resp_tbl(i).default_value,
         alr_init_resp_tbl(i).max_len;

--    response variable name can have a leading &, which we want to ignore
--    var->detail_max_len = (word)(maxlen !=0 ? maxlen : 5000);
      EXIT WHEN c_responses_csr%NOTFOUND;
      i := i + 1;
   END LOOP;
   CLOSE c_responses_csr;

   exception
    when others then
       wf_core.context('ALR_MLR_PKG', 'RESPONSE',
                       'Exception during InitResponseVar');
       raise;
end InitResponseVar;

procedure InitValidResponses(
   alr_msg_dtls_tbl in alr_msg_dtls_tbl_type,
   alr_init_valid_resp_tbl out NOCOPY alr_init_valid_resp_tbl_type)
is
   CURSOR c_validresp (p_app_id number,
                       p_alert_id number,
                       p_response_set_id number) IS
     select response_id, type, response_text, response_name
     from alr_valid_responses
     where  application_id = p_app_id and
            alert_id=p_alert_id and
            response_set_id=p_response_set_id;
     i number;
begin
   i := 1;
   OPEN c_validresp(alr_msg_dtls_tbl(1).app_id,
                    alr_msg_dtls_tbl(1).alert_id,
                    alr_msg_dtls_tbl(1).response_set_id);
   LOOP
     FETCH c_validresp
     into   alr_init_valid_resp_tbl(i).resp_id,
            alr_init_valid_resp_tbl(i).resp_type,
            alr_init_valid_resp_tbl(i).resp_text,
            alr_init_valid_resp_tbl(i).resp_name;
     exit when c_validresp%NOTFOUND;
     i := i + 1;
   END LOOP;

   CLOSE c_validresp;

   exception
    when others then
       wf_core.context('ALR_MLR_PKG', 'RESPONSE',
                       'Exception during InitValidResponses');
       raise;
end InitValidResponses;

procedure GetRespActions(
   alr_msg_dtls_tbl in alr_msg_dtls_tbl_type,
   alr_init_valid_resp_tbl in alr_init_valid_resp_tbl_type,
   alr_get_resp_act_tbl out NOCOPY alr_get_resp_act_tbl_type)
is
  CURSOR c_getrespact (p_app_id number,
                       p_alert_id number,
                       p_response_set_id number,
                       p_response_id number) IS
   select r.response_id, r.action_id, a.name, NVL(a.action_type,'R'),
          a.body, a.concurrent_program_id,
          DECODE(a.list_id, NULL, a.to_recipients, d.to_recipients),
          DECODE(a.list_id, NULL, a.cc_recipients, d.cc_recipients),
          DECODE(a.list_id, NULL, a.bcc_recipients, d.bcc_recipients),
          DECODE(a.list_id, NULL, a.print_recipients, d.print_recipients),
          DECODE(a.list_id, NULL, a.printer, d.printer),
          a.subject, a.reply_to, a.column_wrap_flag,
          a.maximum_summary_message_width, a.action_level_type,
          ' ', a.file_name, a.argument_string, a.program_application_id,
          a.list_application_id, a.response_set_id, a.follow_up_after_days,
          NVL(a.version_number,0)
   from alr_actions a, alr_distribution_lists d,
        alr_response_actions r
   where r.application_id = p_app_id and
         r.alert_id = p_alert_id and
         r.response_set_id = p_response_set_id and
         r.response_id = p_response_id and
         r.application_id = a.application_id(+) and
         r.action_id = a.action_id(+) and
         r.enabled_flag= 'Y' and
         NVL(r.end_date_active,SYSDATE)>=SYSDATE and
         r.enabled_flag = a.enabled_flag(+) and
         NVL(d.end_date_active(+),SYSDATE+1) >= SYSDATE and
         a.application_id = d.application_id(+) and
         a.list_id = d.list_id(+)
   order by r.sequence;
   i number;
   t_counter number;
begin
   i := 1;
   t_counter := 1;
   FOR t_counter IN 1..alr_init_valid_resp_tbl.LAST LOOP

       OPEN c_getrespact(alr_msg_dtls_tbl(1).app_id,
                    alr_msg_dtls_tbl(1).alert_id,
                    alr_msg_dtls_tbl(1).response_set_id,
                    alr_init_valid_resp_tbl(t_counter).resp_id);
       LOOP
          FETCH c_getrespact
            into alr_get_resp_act_tbl(i).response_id,
            alr_get_resp_act_tbl(i).action_id,
            alr_get_resp_act_tbl(i).action_name,
            alr_get_resp_act_tbl(i).action_type,
            alr_get_resp_act_tbl(i).action_body,
            alr_get_resp_act_tbl(i).conc_pgm_id,
            alr_get_resp_act_tbl(i).to_recip,
            alr_get_resp_act_tbl(i).cc_recip,
            alr_get_resp_act_tbl(i).bcc_recip,
            alr_get_resp_act_tbl(i).print_recip,
            alr_get_resp_act_tbl(i).printer,
            alr_get_resp_act_tbl(i).subject,
            alr_get_resp_act_tbl(i).reply_to,
            alr_get_resp_act_tbl(i).column_wrap_flag,
            alr_get_resp_act_tbl(i).max_sum_msg_width,
            alr_get_resp_act_tbl(i).action_level_type,
            alr_get_resp_act_tbl(i).action_level,
            alr_get_resp_act_tbl(i).file_name,
            alr_get_resp_act_tbl(i).arg_string,
            alr_get_resp_act_tbl(i).pgm_app_id,
            alr_get_resp_act_tbl(i).list_app_id,
            alr_get_resp_act_tbl(i).act_resp_set_id,
            alr_get_resp_act_tbl(i).follow_up_after_days,
            alr_get_resp_act_tbl(i).version_num;
         EXIT WHEN c_getrespact%NOTFOUND;

         i := i + 1;
       END LOOP;
       CLOSE c_getrespact;
   END LOOP;

   exception
    when others then
       wf_core.context('ALR_MLR_PKG', 'RESPONSE',
                      'Exception during GetRespActions');
       raise;
end GetRespActions;

procedure GetOutputValues(msg_handle in number,
                          node_handle in number,
                          alr_resp_var_values_tbl out NOCOPY
                          alr_resp_var_values_tbl_type)
is
   CURSOR c_resp_var_csr (p_msg_handle number,
                          p_node_handle number) IS
   select variable_name, value, data_type, detail_max_len
   from   alr_response_variable_values
   where  message_handle = p_msg_handle and
          node_handle = p_node_handle;
   i number;
begin
  i := 1;
  OPEN c_resp_var_csr(msg_handle,
                      node_handle);
  LOOP
    FETCH c_resp_var_csr into
       alr_resp_var_values_tbl(i).variable_name,
       alr_resp_var_values_tbl(i).value,
       alr_resp_var_values_tbl(i).data_type,
       alr_resp_var_values_tbl(i).detail_max_len;
    EXIT WHEN c_resp_var_csr%NOTFOUND;
    i := i + 1;
  END LOOP;
  CLOSE c_resp_var_csr;

  exception
    when others then
       wf_core.context('ALR_MLR_PKG', 'RESPONSE',
                      'Exception during GetOutputValues');
       raise;
end GetOutputValues;

procedure SaveRespHistory(msg_handle in number,
                          node_handle in number,
                          alr_msg_dtls_tbl in alr_msg_dtls_tbl_type,
                          l_from in varchar2,
                          p_response_body in varchar2,
                          p_resp_id in number)
is
   p_action_id number;
   p_version_num number;
   seq number;
   received   varchar2(240);
   p_to_recip varchar2(240);
   p_cc_recip varchar2(240);
   p_bcc_recip varchar2(240);
   p_reply_to varchar2(240);
   p_subject varchar2(240);
   maintain_history_days number;
begin

   maintain_history_days := 0;
   select maintain_history_days into
          maintain_history_days from
          alr_alerts where
          application_id=alr_msg_dtls_tbl(1).app_id and
          alert_id = alr_msg_dtls_tbl(1).alert_id;

  if (maintain_history_days > 0) then
     select action_id into p_action_id from alr_action_history
     where message_handle=msg_handle and
         node_handle=node_handle;

     select max(version_number) into p_version_num from
     alr_actions where action_id=p_action_id;

     select to_recipients, cc_recipients, bcc_recipients,
          reply_to, subject
     into   p_to_recip, p_cc_recip, p_bcc_recip,
          p_reply_to, p_subject
     from   alr_actions
     where  action_id = p_action_id and
          version_number = p_version_num;

     select alr_response_messages_s.nextval into seq from dual;
     received := SYSDATE;

     insert into alr_response_messages(message_handle, node_handle,
               application_id, alert_id, response_set_id, response_type,
               response_id, response_message_id, date_processed,
               to_recipients, cc_recipients, bcc_recipients, sent_from,
               reply_to, subject, body, received)
          values(msg_handle, node_handle, alr_msg_dtls_tbl(1).app_id,
                 alr_msg_dtls_tbl(1).alert_id,
                 alr_msg_dtls_tbl(1).response_set_id,
                 'V',
                 p_resp_id, seq,
                 SYSDATE,
                p_to_recip,
                p_cc_recip,
                p_bcc_recip,
                l_from,
                p_reply_to,
                p_subject,
                p_response_body,
                received);
    end if;

  exception
    when others then
       wf_core.context('ALR_MLR_PKG', 'RESPONSE',
                    'Exception during SaveRespHistory');
       if (wf_log_pkg.level_procedure >=
                       fnd_log.g_current_runtime_level) then
                       wf_log_pkg.string(WF_LOG_PKG.level_procedure,
                      'alr.plsql.ALR_MLR_PACKAGE.Response',
                       'Exception in SaveRespHistory');
       end if;
       raise;
end SaveRespHistory;

procedure SaveRespVar(alr_msg_dtls_tbl in alr_msg_dtls_tbl_type,
                      msg_handle in number,
                      node_handle in number,
                      alr_init_resp_tbl in
                      alr_init_resp_tbl_type)
is
i number;
begin
   i := 1;
   if (alr_init_resp_tbl.COUNT > 0) then
      for i IN 1..alr_init_resp_tbl.LAST LOOP
       insert into alr_response_variable_values(application_id, alert_id,
               response_set_id, message_handle, node_handle, variable_name,
               value, data_type, detail_max_len)
          select alr_msg_dtls_tbl(1).app_id,
                 alr_msg_dtls_tbl(1).alert_id,
                 alr_msg_dtls_tbl(1).response_set_id,
                 msg_handle,
                 node_handle,
                 alr_init_resp_tbl(i).name,
                 alr_init_resp_tbl(i).default_value,
                 alr_init_resp_tbl(i).data_type,
                 alr_init_resp_tbl(i).max_len
          from dual where not exists
          (select null from alr_response_variable_values
           where message_handle=msg_handle and
                 node_handle=node_handle and
                 variable_name=alr_init_resp_tbl(i).name);
       END LOOP;
   end if;

  exception
    when others then
       wf_core.context('ALR_MLR_PKG', 'RESPONSE',
                       'Exception during SaveResp');
       raise;

end SaveRespVar;

procedure SaveOneRespVar(alr_msg_dtls_tbl in alr_msg_dtls_tbl_type,
                      msg_handle in number,
                      node_handle in number,
                      variable_name in varchar2,
                      value in varchar2,
                      alr_init_resp_tbl in
                      alr_init_resp_tbl_type)
is
  t_counter number;

begin
   t_counter := 1;

   -- Loop through the alr_init_resp_tbl to find the
   -- variable name that matches what the user entered in the body.
   FOR t_counter IN 1..alr_init_resp_tbl.LAST loop
     if (alr_init_resp_tbl(t_counter).name = variable_name) then
       insert into alr_response_variable_values(application_id, alert_id,
               response_set_id, message_handle, node_handle, variable_name,
               value, data_type, detail_max_len)
          select alr_msg_dtls_tbl(1).app_id,
                 alr_msg_dtls_tbl(1).alert_id,
                 alr_msg_dtls_tbl(1).response_set_id,
                 msg_handle,
                 node_handle,
                 variable_name,
                 value,
                 alr_init_resp_tbl(t_counter).data_type,
                 alr_init_resp_tbl(t_counter).max_len
          from dual where not exists
          (select null from alr_response_variable_values
           where message_handle=msg_handle and
                 node_handle=node_handle and
                 variable_name=variable_name);
      end if;
    END LOOP;

  exception
    when others then
       wf_core.context('ALR_MLR_PKG', 'RESPONSE',
                       'Exception during SaveOneRespVar');
       raise;
end SaveOneRespVar;

procedure SaveRespActHistory(msg_handle in number,
                             node_handle in number,
                             response_msg_id in number,
                             oracle_id in number,
                             seq in number,
                             alr_msg_dtls_tbl in
                                alr_msg_dtls_tbl_type,
                             alr_get_resp_act_tbl in
                                alr_get_resp_act_tbl_type,
                             version_num in number,
                             success_flag in varchar2)
is
begin
   insert into alr_response_action_history(message_handle,
          node_handle, response_message_id, oracle_id, sequence, application_id,
          alert_id, action_id, version_number, success_flag)
   values (msg_handle, node_handle, response_msg_id, oracle_id,
           seq, alr_msg_dtls_tbl(1).app_id,
           alr_msg_dtls_tbl(1).alert_id,
           alr_get_resp_act_tbl(1).action_id, version_num,
           success_flag);

  exception
    when others then
       wf_core.context('ALR_MLR_PKG', 'RESPONSE',
                       'Exception during SaveRespActHistory');
       raise;
end SaveRespActHistory;

procedure CloseResp(msg_handle in number,
                    node_handle in number,
                    alr_init_valid_resp_tbl in
                        alr_init_valid_resp_tbl_type,
                    open_closed in varchar2,
                    action_set_pass_fail in varchar2)
is
begin
   update alr_actual_responses
          set response_id=alr_init_valid_resp_tbl(1).resp_id,
          open_closed= open_closed, action_set_pass_fail=action_set_pass_fail
   where  message_handle = msg_handle and node_handle=node_handle;

  exception
    when others then
       wf_core.context('ALR_MLR_PKG', 'RESPONSE',
                       'Exception during CloseResp');
       raise;
end CloseResp;

procedure Test
is

reqid number;

-- ALP_NO_RESPONSE = "N"
-- ALP_VALID_RESPONSE = "V"
-- ALP_INVALID_RESPONSE = "I"
resp_type varchar(1);

--GetResponseDetails
count_var number;
msg_handle number;
node_handle number;
alr_msg_dtls_tbl alr_msg_dtls_tbl_type;

--InitResponseVar
alr_init_resp_tbl alr_init_resp_tbl_type;

-- InitValidResponses
alr_init_valid_resp_tbl alr_init_valid_resp_tbl_type;

-- GetRespActions
alr_get_resp_act_tbl alr_get_resp_act_tbl_type;

-- GetOutputValues
alr_resp_var_values_tbl alr_resp_var_values_tbl_type;

-- SaveRespHistory
l_from varchar2(240);
received varchar2(240);

l_node_handle    varchar2(20);
l_msg_handle varchar2(20);
l_morcl_id       varchar2(20);
l_name           varchar2(20);
l_format         varchar2(20);
l_to_recip       varchar2(20);
l_cc_recip       varchar2(20);
l_bcc_recip      varchar2(20);
l_reply_to       varchar2(20);
l_subject        varchar2(20);
l_response_body  varchar2(20);

t_counter number;
found     number;
input     varchar2(20);

begin

      -- Check for open responses
         count_var := OpenResponses;
         if (count_var > 0) then
            node_handle := 1;
            msg_handle := 114145;
            l_node_handle := '1';
            l_msg_handle := '114145';
            received := SYSDATE;
            l_to_recip := 'jan.smith@oracle.com';
            l_cc_recip := 'jan.smith@oracle.com';
            l_bcc_recip := 'jan.smith@oracle.com';
            l_reply_to := 'jan.smith@oracle.com';
            l_subject := 'testing';
            l_from := 'jan.smith@oracle.com';
            found := 0;
            input := '200';
            l_name := 'TESTVAR';
            l_format := 'TESTVAR="?"';
            l_response_body := input;
            l_morcl_id := '900';


            -- get application id, alert id, and response set
            GetMessageDetails(msg_handle, node_handle,
                              alr_msg_dtls_tbl);
            -- Initialize the response
               InitResponseVar(alr_msg_dtls_tbl,
                               alr_init_resp_tbl);

            -- Initialize valid responses
               InitValidResponses(alr_msg_dtls_tbl,
                                  alr_init_valid_resp_tbl);

               GetRespActions(alr_msg_dtls_tbl,
                              alr_init_valid_resp_tbl,
                              alr_get_resp_act_tbl);

               -- Check user's response to see if valid response
                -- First case: They entered a text value, no variables
                   for t_counter IN 1..alr_init_valid_resp_tbl.LAST LOOP
                       -- if value in email is plain text
                     if (input = alr_init_valid_resp_tbl(t_counter).resp_text) then
                         -- insert response received into history
                         found := 1;
                         SaveRespHistory(msg_handle, node_handle,
                                 alr_msg_dtls_tbl,
                                 l_from,
                                 'fake body',
                         alr_init_valid_resp_tbl(t_counter).resp_id);

                         -- If it matches here then they did not reply
                         -- with a response variable. So, update all
                         -- response variables with default values and
                         -- save to history.
                         SaveRespVar(alr_msg_dtls_tbl,
                              msg_handle, node_handle,
                              alr_init_resp_tbl);

                         -- CALL CONCURRENT PROGRAM TO PERFORM ACTIONS
                         reqid := fnd_request.submit_request(application => 'ALR',
                               program => 'ALPPWF',
                               argument1 => l_node_handle,
                               argument2 => l_msg_handle,
                               argument3 => l_morcl_id,
                               argument4 => 'V',
                               argument5 => l_name,
                               argument6 => input,
                               argument7 => l_format);
                        if reqid = 0 then
                          if (wf_log_pkg.level_statement >=
                             fnd_log.g_current_runtime_level) then
                             wf_log_pkg.string(WF_LOG_PKG.level_statement,
                             'alr.plsql.ALR_MLR_PACKAGE.Response',
                              'The request ID retued 0. Raising -20160 app error');
                          end if;
                          raise_application_error(-20160, FND_MESSAGE.GET);
                        end if;
                     end if;
                   END LOOP;

              -- 2nd case is if they entered a variable but no value
               -- ? is in value.
               if (input = '?' and found = 0) then
                   for t_counter in 1..alr_init_valid_resp_tbl.LAST LOOP
                     if (l_format =
                        alr_init_valid_resp_tbl(t_counter).resp_text) then
                        found := 1;
                        -- insert response received into history
                        SaveRespHistory(msg_handle, node_handle,
                                 alr_msg_dtls_tbl,
                                 l_from,
                                 'fake body',
                         alr_init_valid_resp_tbl(t_counter).resp_id);

                         -- If it matches here then they did not reply
                         -- with a response variable. So, update all
                         -- response variables with default values and
                         -- save to history.
                         SaveRespVar(alr_msg_dtls_tbl,
                              msg_handle, node_handle,
                              alr_init_resp_tbl);

                        -- CALL CONCURRENT PROGRAM TO PERFORM ACTIONS
                        reqid := fnd_request.submit_request(application => 'ALR',
                               program => 'ALPPWF',
                               argument1 => l_node_handle,
                               argument2 => l_msg_handle,
                               argument3 => l_morcl_id,
                               argument4 => 'V',
                               argument5 => l_name,
                               argument6 => input,
                               argument7 => l_format);
                        if (reqid = 0) then
                          if (wf_log_pkg.level_statement >=
                             fnd_log.g_current_runtime_level) then
                             wf_log_pkg.string(WF_LOG_PKG.level_statement,
                             'alr.plsql.ALR_MLR_PACKAGE.Response',
                              'The request ID retued 0. Raising -20160 app error');
                          end if;
                           raise_application_error(-20160, FND_MESSAGE.GET);
                        end if;
                     end if;
                   end loop;
               end if;

               -- Third case is if they entered a variable and a value
               if (found = 0) then
                  for t_counter IN 1..alr_init_valid_resp_tbl.LAST LOOP
                      if (l_format =
                         alr_init_valid_resp_tbl(t_counter).resp_text) then
                         found := 1;

                        -- insert response received into history
                        SaveRespHistory(msg_handle, node_handle,
                                 alr_msg_dtls_tbl,
                                 l_from,
                                 'fake body',
                        alr_init_valid_resp_tbl(t_counter).resp_id);

                         SaveOneRespVar(alr_msg_dtls_tbl,
                              msg_handle, node_handle,
                              l_name,
                              input,
                              alr_init_resp_tbl);

                         -- CALL CONCURRENT PROGRAM TO PERFORM ACTIONS
                         if (wf_log_pkg.level_procedure >=
                             fnd_log.g_current_runtime_level) then
                             wf_log_pkg.string(WF_LOG_PKG.level_procedure,
                             'alr.plsql.ALR_MLR_PACKAGE.Response',
                             'Submitting Action Processor');
                         end if;
                         reqid := fnd_request.submit_request(application => 'ALR',
                               program => 'ALPPWF',
                               argument1 => l_node_handle,
                               argument2 => l_msg_handle,
                               argument3 => l_morcl_id,
                               argument4 => 'V',
                               argument5 => l_name,
                               argument6 => input,
                               argument7 => l_format);
                        if (reqid = 0) then
                          if (wf_log_pkg.level_statement >=
                             fnd_log.g_current_runtime_level) then
                             wf_log_pkg.string(WF_LOG_PKG.level_statement,
                             'alr.plsql.ALR_MLR_PACKAGE.Response',
                              'The request ID retued 0. Raising -20160 app error');
                          end if;
                          raise_application_error(-20160, FND_MESSAGE.GET);
                        end if;
                      end if;
                  end loop;
               end if;

               -- last case is invalid response
               if (found=0) then
                   reqid := fnd_request.submit_request(application => 'ALR',
                            program => 'ALPPWF',
                            argument1 => l_node_handle,
                            argument2 => l_msg_handle,
                            argument3 => l_morcl_id,
                            argument4 => 'V',
                            argument5 => l_name,
                            argument6 => input,
                            argument7 => l_format);
                   if (reqid = 0) then
                          if (wf_log_pkg.level_statement >=
                             fnd_log.g_current_runtime_level) then
                             wf_log_pkg.string(WF_LOG_PKG.level_statement,
                             'alr.plsql.ALR_MLR_PACKAGE.Response',
                              'The request ID retued 0. Raising -20160 app error');
                          end if;
                      raise_application_error(-20160, FND_MESSAGE.GET);
                   end if;

               end if;

         end if;

end Test;

end; /*ALR_MLR_PACKAGE*/

/
