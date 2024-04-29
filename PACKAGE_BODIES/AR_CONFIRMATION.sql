--------------------------------------------------------
--  DDL for Package Body AR_CONFIRMATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_CONFIRMATION" AS
/*$Header: ARCONFMB.pls 115.3 2002/12/23 22:23:36 tkoshio noship $ */

  procedure initiate_confirmation_process(P_STATUS in VARCHAR2,
                                          P_ID in VARCHAR2,
                                          P_REASON_CODE in VARCHAR2,
                                          P_DESCRIPTION in VARCHAR2,
                                          P_INT_CTR_NUM in VARCHAR2) is
    cursor ar is
      select DISTINCT 'FND_RESP222:'||to_char(responsibility_id) role_name
      from fnd_responsibility_tl
      where application_id = 222;
    cursor action is
      select handler_name, handler_type from ar_confirmation_actions
      where status = p_status and (reason_code = p_reason_code or p_reason_code is null);
    cursor msgid is
      select msgid from ecx_doclogs where internal_control_number = p_int_ctr_num;
    l_handler_name varchar2(70);
    l_handler_type varchar2(30);
    l_sqlerrm varchar2(2000);
    l_subject varchar2(200);
    l_parameter_list wf_parameter_list_t := wf_parameter_list_t();
    l_plsql varchar2(2000);
    l_msgid raw(16);
    l_url varchar2(500);
    l_doc_transfer_id NUMBER;
    cursor global is
      select application_id, responsibility_id, last_updated_by
      from ar_document_transfers
      where document_transfer_id = l_doc_transfer_id;
    global_rec global%rowtype;
    l_sid number;

  begin
    l_doc_transfer_id := rtrim(ltrim(substrb(p_id,1,instrb(p_id,':',1,1)-1)));
    open global; fetch global into global_rec; close global;
    if global_rec.application_id is null or
       global_rec.responsibility_id is null or
       global_rec.last_updated_by is null then
      fnd_message.set_name('AR','AR_CONF_ACT_INV_ID_SBJ');
      l_subject := fnd_message.get;
      fnd_message.set_name('AR','AR_CONF_ACT_INV_ID_BODY');
      fnd_message.set_token('P_ID', p_id);
      l_sqlerrm := fnd_message.get;
      ar_notification_standard.notifyToSysadmin(l_subject, l_sqlerrm);
      return;
    else
      fnd_global.initialize(l_sid, global_rec.last_updated_by, global_rec.responsibility_id,
                            global_rec.application_id, null,null,0,0,null,null,null,null);
    end if;
    if ar_doc_transfer_standard.isDebugOn then
      ar_doc_transfer_standard.debug('AR_CONFIRMATION.initiate_confirmation_process(+)');
      ar_doc_transfer_standard.debug('p_status:'||p_status);
      ar_doc_transfer_standard.debug('p_reason_code:'||p_reason_code);
    end if;
    open msgid; fetch msgid into l_msgid; close msgid;
    if ar_doc_transfer_standard.isDebugOn then
      ar_doc_transfer_standard.debug('p_int_ctr_num:'||p_int_ctr_num);
      ar_doc_transfer_standard.debug('l_msgid:'||l_msgid);
    end if;
    open action; fetch action into l_handler_name, l_handler_type; close action;
    if l_handler_type = 'PLSQL' and l_handler_name is not null then
      l_plsql := 'BEGIN '||l_handler_name||'(:status,:id,:reason_code,:description,:msgid); END;';
      if ar_doc_transfer_standard.isDebugOn then ar_doc_transfer_standard.debug('l_plsql:'||l_plsql); end if;
      execute immediate l_plsql using p_status, p_id, p_reason_code, p_description, l_msgid;

    elsif l_handler_type = 'EVENT' and l_handler_name is not null then
      wf_event.AddParameterToList(
        p_name => 'P_STATUS',
        p_value => p_status,
        p_parameterlist => l_parameter_list);
      wf_event.AddParameterToList(
        p_name => 'P_ID',
        p_value => p_id,
        p_parameterlist => l_parameter_list);
      wf_event.AddParameterToList(
        p_name => 'P_REASON_CODE',
        p_value => p_reason_code,
        p_parameterlist => l_parameter_list);
      wf_event.AddParameterToList(
        p_name => 'P_DESCRIPTION',
        p_value => p_description,
        p_parameterlist => l_parameter_list);
      wf_event.AddParameterToList(
        p_name => 'P_MSGID',
        p_value => l_msgid,
        p_parameterlist => l_parameter_list);
      wf_event.raise(
        p_event_name => l_handler_name,
        p_event_key => to_char(sysdate, 'DD/MON/RRRR HH:MI:SS'),
        p_parameters => l_parameter_list);
      l_parameter_list.DELETE;

    else
      fnd_message.set_name('AR', 'AR_CONF_INVALID_SBJ');
      l_subject := fnd_message.get;
      fnd_message.set_name('AR', 'AR_CONF_INVALID');
      fnd_message.set_token('STATUS', p_status);
      fnd_message.set_token('REASON_CODE', p_reason_code);
      l_sqlerrm := fnd_message.get;

      l_url := 'JSP:/OA_HTML/OA.jsp?akRegionCode=CONFIRMATIONACTIONS_PG'||'&'||
                                   'akRegionApplicationId=222';
      for ar_rec in ar loop
        ar_notification_standard.notify(l_subject,
                                        l_sqlerrm,
                                        ar_rec.role_name,
                                        l_url);
      end loop;
    end if;
    if ar_doc_transfer_standard.isDebugOn then ar_doc_transfer_standard.debug('AR_CONFIRMATION.initiate_confirmation_process(-)'); end if;
  exception
    when others then
      l_sqlerrm := sqlerrm || fnd_global.newline||
                   'Location: AR_CONFIRMATION.initiate_confirmation_process()'||fnd_global.newline||
                   'Time: '||to_char(sysdate, 'DD-MON-RRRR HH:MI:SS');
      fnd_message.set_name('AR','AR_CONF_ERROR');
      l_subject := fnd_message.get;
      ar_notification_standard.notifyToSysadmin(l_subject, l_sqlerrm);
  end;
end;

/
