--------------------------------------------------------
--  DDL for Package Body AR_NOTIFICATION_STANDARD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_NOTIFICATION_STANDARD" as
/*$Header: ARNOTSTB.pls 120.3 2005/07/22 12:45:32 naneja noship $ */

  cursor role_csr is
    select 'FND_RESP1:'||to_char(responsibility_id) role_name
    from fnd_responsibility_tl
    where application_id = 1;

/*  cursor role_csr is
    select name role_name
    from   wf_roles
    where  name = fnd_global.user_name; */

  function createUrl(p_function in varchar2) return varchar2 is
    l_url varchar2(1000);
    l_function_id NUMBER;
    cursor func is select function_id from fnd_form_functions_vl
                   where function_name = p_function;
  begin
    if ar_doc_transfer_standard.isDebugOn then ar_doc_transfer_standard.debug('AR_NOTIFICATION_STANDARD.createUrl(+)'); end if;
    open func; fetch func into l_function_id; close func;
    fnd_profile.get('APPS_WEB_AGENT', l_url);
    l_url := l_url||'OracleApps.RF?F=';
    l_url := l_url||icx_call.encrypt2(fnd_global.resp_appl_id||'*'||
                                      fnd_global.resp_id||'*'||
                                      fnd_global.security_group_id||'*'||
                                      l_function_id||'*'||
                                      icx_sec.getsessioncookie());
    if ar_doc_transfer_standard.isDebugOn then ar_doc_transfer_standard.debug('AR_NOTIFICATION_STANDARD.createUrl(-)');end if;
    return l_url;
  end;

  procedure build_error_message(document_id	in	varchar2,
				display_type	in	varchar2,
				document	in out	NOCOPY varchar2,
				document_type	in out	NOCOPY varchar2) is
  l_buffer varchar2(32000);
  l_item_type varchar2(30);
  l_item_key  varchar2(30);

  begin
    if ar_doc_transfer_standard.isDebugOn then ar_doc_transfer_standard.debug('AR_NOTIFICATION_STANDARD.build_error_message(+)'); end if;
    fnd_message.set_name('AR', 'AR_DOC_TRS_BODY');
    ar_notification_standard.parseDocumentId(document_id, l_item_type, l_item_key);
    l_buffer := wf_engine.getItemAttrText(itemType => l_item_type,
                                          itemKey  => l_item_key,
                                          aname    => 'USER_AREA1');
    document := fnd_message.get||fnd_global.newline||fnd_global.newline||l_buffer;
    document_type := 'text/plain';
    if ar_doc_transfer_standard.isDebugOn then ar_doc_transfer_standard.debug('AR_NOTIFICATION_STANDARD.build_error_message(-)'); end if;
  end;

/*
  procedure build_error_message_clob(document_id	in	varchar2,
				     display_type	in	varchar2,
				     document	in out NOCOPY clob,
				     document_type	in out NOCOPY	varchar2) is
  l_buffer varchar2(1000);
  l_item_type varchar2(30);
  l_item_key  varchar2(30);

  begin
    if ar_doc_transfer_standard.isDebugOn then ar_doc_transfer_standard.debug('AR_NOTIFICATION_STANDARD.build_error_message(+)'); end if;
    fnd_message.set_name('AR', 'AR_DOC_TRS_BODY');
    WF_NOTIFICATION.WriteToClob(document,fnd_message.get||fnd_global.newline||fnd_global.newline);

    ar_notification_standard.parseDocumentId(document_id, l_item_type, l_item_key);
    l_buffer := wf_engine.getItemAttrText(itemType => l_item_type,
                                          itemKey  => l_item_key,
                                          aname    => 'USER_AREA1');
    WF_NOTIFICATION.WriteToClob(document,l_buffer);
    document_type := 'text/plain';
    if ar_doc_transfer_standard.isDebugOn then ar_doc_transfer_standard.debug('AR_NOTIFICATION_STANDARD.build_error_message(-)'); end if;
  end;
*/

  procedure notify(p_subject in varchar2,
                   p_sqlerrm in varchar2,
                   p_role_name in varchar2,
                   p_url in varchar2) is
  begin
    if ar_doc_transfer_standard.isDebugOn then ar_doc_transfer_standard.debug('AR_NOTIFICATION_STANDARD.notify(+)'); end if;
    raiseNotificationEvent(p_event_name => 'oracle.apps.ar.transmit.notification',
                           p_subject    => p_subject,
                           p_doc_pkg    => 'AR_NOTIFICATION_STANDARD',
                           p_doc_proc   => 'BUILD_ERROR_MESSAGE',
                           p_role_name  => p_role_name,
                           p_url        => p_url,
                           p_user_area1 => p_sqlerrm);
    if ar_doc_transfer_standard.isDebugOn then ar_doc_transfer_standard.debug('AR_NOTIFICATION_STANDARD.notify(-)'); end if;
  end;


  procedure notifyToSysadmin(p_subject in varchar2,
                             p_sqlerrm in varchar2,
                             p_url in varchar2) is
  begin
    if ar_doc_transfer_standard.isDebugOn then
      ar_doc_transfer_standard.debug('AR_NOTIFICATION_STANDARD.notifyToSysadmin(+)');
      ar_doc_transfer_standard.debug('p_subject:'||p_subject);
      ar_doc_transfer_standard.debug('p_sqlerrm:'||p_sqlerrm);
      ar_doc_transfer_standard.debug('p_url:'||p_url);
    end if;

    for l_role_rec in role_csr loop

      raiseNotificationEvent(p_event_name => 'oracle.apps.ar.transmit.notification',
                             p_subject    => p_subject,
                             p_doc_pkg    => 'AR_NOTIFICATION_STANDARD',
                             p_doc_proc   => 'BUILD_ERROR_MESSAGE',
                             p_role_name  => l_role_rec.role_name,
                             p_url        => p_url,
                             p_user_area1 => p_sqlerrm);
    end loop;
    if ar_doc_transfer_standard.isDebugOn then ar_doc_transfer_standard.debug('AR_NOTIFICATION_STANDARD.notifyToSysadmin(-)');end if;
  exception
    when others then
      if ar_doc_transfer_standard.isDebugOn then
        ar_doc_transfer_standard.debug('AR_NOTIFICATION_STANDARD.notifyToSysadmin()EXCEPTION:'||sqlerrm);
      end if;
  end;


procedure parseDocumentId(p_document_id in varchar2,
                          p_item_type   out NOCOPY varchar2,
                          p_item_key    out NOCOPY varchar2) is

  begin
    if ar_doc_transfer_standard.isDebugOn then
      ar_doc_transfer_standard.debug('AR_NOTIFICATION_STANDARD.parseDocumentId(+)');
      ar_doc_transfer_standard.debug('p_document_id:'||p_document_id);
    end if;
    p_item_type := substrb(p_document_id, 1, instrb(p_document_id,':')-1);
    p_item_key  := substrb(p_document_id, instrb(p_document_id,':')+1);
    if ar_doc_transfer_standard.isDebugOn then
      ar_doc_transfer_standard.debug('p_item_type:'||p_item_type);
      ar_doc_transfer_standard.debug('p_item_key:'||p_item_key);
      ar_doc_transfer_standard.debug('AR_NOTIFICATION_STANDARD.parseDocumetnID(-)');
    end if;
  end;

procedure compileMessage(ITEMTYPE  IN      VARCHAR2,
                         ITEMKEY   IN      VARCHAR2,
                         ACTID     IN      NUMBER,
                         FUNCMODE  IN      VARCHAR2,
                         RESULTOUT IN OUT NOCOPY  VARCHAR2) is

  l_role_name VARCHAR2(320);
  l_aname VARCHAR2(200);
  l_msg_doc_procedure VARCHAR2(30);
  l_msg_doc_package   VARCHAR2(30);
  l_plsql_block       VARCHAR2(100);
  l_subject           VARCHAR2(1000);
  l_email_address     VARCHAR2(200);
  l_url               VARCHAR2(1000);

  begin
    if ar_doc_transfer_standard.isDebugOn then ar_doc_transfer_standard.debug('AR_NOTIFICATION_STANDARD.compileMessage(+)');end if;
    resultout := 'COMPLETE';
    if ar_doc_transfer_standard.isDebugOn then ar_doc_transfer_standard.debug('AR_NOTIFICATION_STANDARD.compileMessage(+)');end if;
  end;

procedure isURLEmpty(ITEMTYPE  IN      VARCHAR2,
                     ITEMKEY   IN      VARCHAR2,
                     ACTID     IN      NUMBER,
                     FUNCMODE  IN      VARCHAR2,
                     RESULTOUT IN OUT NOCOPY  VARCHAR2) is
  isEmpty      VARCHAR2(1) := 'T';

  begin
    if ar_doc_transfer_standard.isDebugOn then ar_doc_transfer_standard.debug('AR_NOTIFICATION_STANDARD.isURLEmpty(+)'); end if;
    if wf_engine.getItemAttrText(itemtype   => itemtype,
                                 itemkey    => itemkey,
                                 aname      => 'URL') is not null then
      isEmpty := 'F';
    end if;
    resultout := 'COMPLETE:'||isEmpty;
    if ar_doc_transfer_standard.isDebugOn then ar_doc_transfer_standard.debug('RESULTOUT:'||resultout); end if;
    if ar_doc_transfer_standard.isDebugOn then ar_doc_transfer_standard.debug('AR_NOTIFICATION_STANDARD.isURLEmpty(-)'); end if;
  end;

procedure isMessageEmpty(ITEMTYPE  IN      VARCHAR2,
                         ITEMKEY   IN      VARCHAR2,
                         ACTID     IN      NUMBER,
                         FUNCMODE  IN      VARCHAR2,
                         RESULTOUT IN OUT NOCOPY  VARCHAR2) is

  isEmpty      VARCHAR2(1) := 'T';

  begin
    if ar_doc_transfer_standard.isDebugOn then ar_doc_transfer_standard.debug('AR_NOTIFICATION_STANDARD.isMessageEmpty(+)'); end if;
    if wf_engine.getItemAttrText(itemtype   => itemtype,
                                 itemkey    => itemkey,
                                 aname      => 'MSG_DOC') is not null then
      isEmpty := 'F';
    end if;
    resultout := 'COMPLETE:'||isEmpty;
    if ar_doc_transfer_standard.isDebugOn then ar_doc_transfer_standard.debug('RESULTOUT:'||resultout); end if;
    if ar_doc_transfer_standard.isDebugOn then ar_doc_transfer_standard.debug('AR_NOTIFICATION_STANDARD.isMessageEmpty(-)'); end if;
  end;


procedure raiseNotificationEvent(p_event_name     in VARCHAR2,
                                 p_subject        in VARCHAR2,
                                 p_doc_pkg        in VARCHAR2,
                                 p_doc_proc       in VARCHAR2,
                                 p_role_name      in VARCHAR2,
                                 p_url            in VARCHAR2,
                                 p_user_area1     in VARCHAR2,
                                 p_user_area2     in VARCHAR2,
                                 p_user_area3     in VARCHAR2,
                                 p_user_area4     in VARCHAR2,
                                 p_user_area5     in VARCHAR2) is

  l_parameter_list  wf_parameter_list_t := wf_parameter_list_t();
  l_itemkey varchar2(30);
  l_plsqldoc varchar2(200);
  begin
    if ar_doc_transfer_standard.isDebugOn then
      ar_doc_transfer_standard.debug('AR_NOTIFICATION_STANDARD.raiseNotificationEvent(+)');
      ar_doc_transfer_standard.debug('p_event_name:'||p_event_name);
      ar_doc_transfer_standard.debug('p_subject:'||p_subject);
      ar_doc_transfer_standard.debug('p_doc_pkg:'||p_doc_pkg);
      ar_doc_transfer_standard.debug('p_doc_proc:'||p_doc_proc);
      ar_doc_transfer_standard.debug('p_rol_name:'||p_role_name);
      ar_doc_transfer_standard.debug('p_url:'||p_url);
      ar_doc_transfer_standard.debug('p_user_area1:'||p_user_area1);
      ar_doc_transfer_standard.debug('p_user_area2:'||p_user_area2);
      ar_doc_transfer_standard.debug('p_user_area3:'||p_user_area3);
      ar_doc_transfer_standard.debug('p_user_area4:'||p_user_area4);
      ar_doc_transfer_standard.debug('p_user_area5:'||p_user_area5);
    end if;
    l_itemkey := to_char(sysdate, 'DD-MON-RRRR-HHMISS');
    l_plsqldoc:= 'plsql:'||p_doc_pkg||'.'||p_doc_proc||'/'||'ARNTFCTN:'||l_itemkey;
    if ar_doc_transfer_standard.isDebugOn then ar_doc_transfer_standard.debug('l_itemkey:'||l_itemkey); end if;
    if ar_doc_transfer_standard.isDebugOn then ar_doc_transfer_standard.debug('l_plsqldoc:'||l_plsqldoc); end if;
    --
    -- Set following Event Parameters:
    --
    wf_event.AddParameterToList(
      p_name => 'SUBJECT',
      p_value => p_subject,
      p_parameterlist => l_parameter_list);

    wf_event.AddParameterToList(
      p_name => 'MSG_DOC',
      p_value => l_plsqldoc,
      p_parameterlist => l_parameter_list);

    wf_event.AddParameterToList(
      p_name => 'USER_TO_BE_NOTIFIED',
      p_value => p_role_name,
      p_parameterlist => l_parameter_list);

    wf_event.AddParameterToList(
      p_name => 'URL',
      p_value => p_url,
      p_parameterlist => l_parameter_list);

    wf_event.AddParameterToList(
      p_name => 'USER_AREA1',
      p_value => p_user_area1,
      p_parameterlist => l_parameter_list);

    wf_event.AddParameterToList(
      p_name => 'USER_AREA2',
      p_value => p_user_area2,
      p_parameterlist => l_parameter_list);

    wf_event.AddParameterToList(
      p_name => 'USER_AREA3',
      p_value => p_user_area3,
      p_parameterlist => l_parameter_list);

    wf_event.AddParameterToList(
      p_name => 'USER_AREA4',
      p_value => p_user_area4,
      p_parameterlist => l_parameter_list);

    wf_event.AddParameterToList(
      p_name => 'USER_AREA5',
      p_value => p_user_area5,
      p_parameterlist => l_parameter_list);

    wf_event.raise(
      p_event_name      => p_event_name,
      p_event_key       => l_itemkey,
      p_parameters      => l_parameter_list);

    l_parameter_list.DELETE;

    if ar_doc_transfer_standard.isDebugOn then
      ar_doc_transfer_standard.debug('AR_NOTIFICATION_STANDARD.raiseNotificationEvent(-)');
    end if;

  exception
    when others then
      raise;
  end;

begin
  if ar_doc_transfer_standard.isDebugOn then ar_doc_transfer_standard.debug('AR_NOTIFICATION_STANDARD(+)'); end if;
  if ar_doc_transfer_standard.isDebugOn then ar_doc_transfer_standard.debug('AR_NOTIFICATION_STANDARD(-)'); end if;
end;

/
