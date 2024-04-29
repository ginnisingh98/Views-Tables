--------------------------------------------------------
--  DDL for Package Body AR_TRANSFER_DOCUMENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_TRANSFER_DOCUMENT" as
/*$Header: ARTRSDCB.pls 120.4.12010000.3 2009/11/17 20:45:22 nproddut ship $ */

  function validateSource(p_doc_rec in out nocopy ar_document_transfers%rowtype) return boolean is
    cursor trx is
      select 'x' from ra_customer_trx where customer_trx_id = p_doc_rec.source_id;
    l_exists varchar2(1);
    l_retcode boolean := false;
  begin
    if ar_doc_transfer_standard.isDebugOn then ar_doc_transfer_standard.debug('AR_TRANSFER_DOCUMENT.validateSource(+)'); end if;
    if p_doc_rec.source_table = 'RA_CUSTOMER_TRX' then
      open trx; fetch trx into l_exists; close trx;
      if l_exists is null then l_retcode := false;
      else l_retcode := true; end if;
    else
      l_retcode := false;
    end if;

    if not l_retcode then
      fnd_message.set_name('AR', 'AR_DOC_TRS_INV_SRC_TBL_ID');
      fnd_message.set_token('DOCUMENT_TRANSFER_ID', p_doc_rec.document_transfer_id);
      p_doc_rec.status := 'FAILED';
      p_doc_rec.exception_type := 'SYSTEM';
      p_doc_rec.exception_message := fnd_message.get;
    end if;
    if ar_doc_transfer_standard.isDebugOn then ar_doc_transfer_standard.debug('STATUS:'||p_doc_rec.status); end if;
    if ar_doc_transfer_standard.isDebugOn then ar_doc_transfer_standard.debug('AR_TRANSFER_DOCUMENT.validateSource(-)'); end if;
    return l_retcode;
  end;

  function validateTpSource(p_doc_rec in out nocopy ar_document_transfers%rowtype) return boolean is
    cursor tp is
      select 'x' from hz_party_sites where party_site_id = p_doc_rec.tp_source_id;
    l_exists varchar2(1);
    l_retcode boolean := false;
  begin
    if ar_doc_transfer_standard.isDebugOn then ar_doc_transfer_standard.debug('AR_TRANSFER_DOCUMENT.validateTpSource(+)'); end if;
    if p_doc_rec.tp_source_table = 'HZ_PARTY_SITES' then
      open tp; fetch tp into l_exists; close tp;
      if l_exists is null then l_retcode := false;
      else l_retcode := true; end if;
    else
      l_retcode := false;
    end if;

    if not l_retcode then
      fnd_message.set_name('AR', 'AR_DOC_TRS_INV_TP_SRC_TBL_ID');
      fnd_message.set_token('DOCUMENT_TRANSFER_ID', p_doc_rec.document_transfer_id);
      p_doc_rec.status := 'FAILED';
      p_doc_rec.exception_type := 'SYSTEM';
      p_doc_rec.exception_message := fnd_message.get;
    end if;
    if ar_doc_transfer_standard.isDebugOn then ar_doc_transfer_standard.debug('STATUS:'||p_doc_rec.status); end if;
    if ar_doc_transfer_standard.isDebugOn then ar_doc_transfer_standard.debug('AR_TRANSFER_DOCUMENT.validateTpSource(-)'); end if;
    return l_retcode;
  end;

  function validateEventName(p_doc_rec in out nocopy ar_document_transfers%rowtype) return boolean is
    cursor event is
      select 'x' from wf_events where name = p_doc_rec.event_name and status = 'ENABLED' and type = 'EVENT';
    l_exists varchar2(1);
    l_retcode boolean := false;
  begin
    if ar_doc_transfer_standard.isDebugOn then ar_doc_transfer_standard.debug('AR_TRANSFER_DOCUMENT.validateEventName(+)'); end if;
    open event; fetch event into l_exists; close event;
    if l_exists is null then l_retcode := false;
    else l_retcode := true; end if;
    if not l_retcode then
      fnd_message.set_name('AR', 'AR_DOC_TRS_INV_BUS_EVENT');
      fnd_message.set_token('EVENT_NAME', p_doc_rec.event_name);
      fnd_message.set_token('DOCUMENT_TRANSFER_ID', p_doc_rec.document_transfer_id);
      p_doc_rec.status := 'FAILED';
      p_doc_rec.exception_type := 'AR';
      p_doc_rec.exception_message := fnd_message.get;
    end if;
    if ar_doc_transfer_standard.isDebugOn then ar_doc_transfer_standard.debug('STATUS:'||p_doc_rec.status); end if;
    if ar_doc_transfer_standard.isDebugOn then ar_doc_transfer_standard.debug('AR_TRANSFER_DOCUMENT.validateEventName(-)'); end if;
    return l_retcode;
  end;

  function validateTrx(p_doc_rec in out nocopy ar_document_transfers%rowtype) return boolean is

    l_exists varchar2(1);
    l_retcode boolean := false;

    cursor ecxTrx is
      select 'x'
      from ecx_transactions trx,
           ecx_ext_processes proc,
           ecx_tp_headers tph,
           ecx_tp_details tpd
      where trx.transaction_type = p_doc_rec.ecx_trx_type and
            trx.transaction_subtype = p_doc_rec.ecx_trx_subtype and
            trx.party_type = p_doc_rec.ecx_party_type and
            proc.direction = 'OUT' and
            trx.transaction_id = proc.transaction_id and
            tph.tp_header_id = tpd.tp_header_id and
            tpd.ext_process_id = proc.ext_process_id and
	    tph.party_type = p_doc_rec.ecx_party_type and
	    ( tph.party_site_id,tph.party_id ) in
	    ( select /* cardinality( sites 1) */
	             sites.party_site_id,
	             sites.party_id
              from hz_party_sites sites
	      where sites.party_site_id = p_doc_rec.tp_source_id
	    );


  begin
    if ar_doc_transfer_standard.isDebugOn then
      ar_doc_transfer_standard.debug('AR_TRANSFER_DOCUMENT.validateTrx(+)');
      ar_doc_transfer_standard.debug('p_doc_rec.ecx_trx_type:'||p_doc_rec.ecx_trx_type);
      ar_doc_transfer_standard.debug('p_doc_rec.ecx_trx_subtype:'||p_doc_rec.ecx_trx_subtype);
      ar_doc_transfer_standard.debug('p_doc_rec.ecx_party_type:'||p_doc_rec.ecx_party_type);
      ar_doc_transfer_standard.debug('p_doc_rec.tp_source_id:'||p_doc_rec.tp_source_id);
    end if;

    open ecxTrx; fetch ecxTrx into l_exists; close ecxTrx;
    if l_exists is null then l_retcode := false;
    else l_retcode := true; end if;
    if ar_doc_transfer_standard.isDebugOn then ar_doc_transfer_standard.debug('l_exists:'||l_exists); end if;
    if not l_retcode then
      fnd_message.set_name('AR', 'AR_DOC_TRS_INV_TP_SETUP');
      fnd_message.set_token('DOCUMENT_TRANSFER_ID', p_doc_rec.document_transfer_id);
      p_doc_rec.status := 'FAILED';
      p_doc_rec.exception_type := 'AR';
      p_doc_rec.exception_message := fnd_message.get;
    end if;
    if ar_doc_transfer_standard.isDebugOn then ar_doc_transfer_standard.debug('STATUS:'||p_doc_rec.status); end if;
    if ar_doc_transfer_standard.isDebugOn then ar_doc_transfer_standard.debug('AR_TRANSFER_DOCUMENT.validateTrx(-)'); end if;
    return l_retcode;
  end;

  procedure validate_document_record(p_doc_rec in out nocopy ar_document_transfers%rowtype) is
  begin
    if ar_doc_transfer_standard.isDebugOn then ar_doc_transfer_standard.debug('AR_TRANSFER_DOCUMENT.validate_document_record(+)'); end if;
    if not validateSource(p_doc_rec) then return; end if;
    if not validateTpSource(p_doc_rec) then return; end if;
    if not validateEventName(p_doc_rec) then return; end if;
    if not validateTrx(p_doc_rec) then return; end if;
    if ar_doc_transfer_standard.isDebugOn then ar_doc_transfer_standard.debug('AR_TRANSFER_DOCUMENT.validate_document_record(-)');end if;
  end;

  procedure notifyToAr(p_event_name in varchar2,
                       p_subject in varchar2,
                       p_doc_pkg in varchar2,
                       p_doc_proc in varchar2,
                       p_request_id in number,
                       p_exception_type in varchar2) is
  l_url varchar2(200);

  begin
    if ar_doc_transfer_standard.isDebugOn then ar_doc_transfer_standard.debug('AR_TRANSFER_DOCUMENT.notifyAr(+)'); end if;

    l_url := 'JSP:/OA_HTML/OA.jsp?akRegionCode=ARDOCTRSPG'||'&'||
                                 'akRegionApplicationId=222'||'&'||
                                 'Query=Y'||'&'||
                                 'ExceptionType=AR';
    ar_notification_standard.raiseNotificationEvent(
                             p_event_name => p_event_name,
                             p_subject    => p_subject,
                             p_doc_pkg    => p_doc_pkg,
                             p_doc_proc   => p_doc_proc,
                             p_role_name  => 'FND_RESP222:'||to_char(fnd_global.resp_id),
                             p_url        => l_url,
                             p_user_area1 => p_request_id,
                             p_user_area2 => p_exception_type);
    if ar_doc_transfer_standard.isDebugOn then ar_doc_transfer_standard.debug('AR_TRANSFER_DOCUMENT.notifyAr(-)'); end if;
  end;

  procedure notifyToSysadmin(p_event_name in varchar2,
                             p_subject in varchar2,
                             p_doc_pkg in varchar2,
                             p_doc_proc in varchar2,
                             p_request_id in number,
                             p_exception_type in varchar2) is
  cursor role_csr is
    select 'FND_RESP1:'||to_char(responsibility_id) role_name
    from fnd_responsibility_tl
    where application_id = 1;
  l_url varchar2(200);
  begin
    if ar_doc_transfer_standard.isDebugOn then ar_doc_transfer_standard.debug('AR_TRANSFER_DOCUMENT.notifyToSysadmin(+)'); end if;
    l_url := 'JSP:/OA_HTML/OA.jsp?akRegionCode=ARDOCTRSPG'||'&'||
                                 'akRegionApplicationId=222'||'&'||
                                 'Query=Y'||'&'||
                                 'ExceptionType=SYSTEM';
    for l_role_rec in role_csr loop
      ar_notification_standard.raiseNotificationEvent(
                             p_event_name => p_event_name,
                             p_subject    => p_subject,
                             p_doc_pkg    => p_doc_pkg,
                             p_doc_proc   => p_doc_proc,
                             p_role_name  => l_role_rec.role_name,
                             p_url        => l_url,
                             p_user_area1 => p_request_id,
                             p_user_area2 => p_exception_type);
    end loop;
    if ar_doc_transfer_standard.isDebugOn then ar_doc_transfer_standard.debug('AR_TRANSFER_DOCUMENT.notifyToSysadmin(-)'); end if;
  end;

  procedure notify(p_event_name in varchar2,
                   p_subject in varchar2,
                   p_doc_pkg in varchar2,
                   p_doc_proc in varchar2,
                   p_request_id in number,
                   p_exception_type in varchar2) is
  begin
    if ar_doc_transfer_standard.isDebugOn then ar_doc_transfer_standard.debug('AR_TRANSFER_DOCUMENT.notify(+)'); end if;
    if p_exception_type = 'SYSTEM' then
      notifyToSysadmin(p_event_name,
                       p_subject,
                       p_doc_pkg,
                       p_doc_proc,
                       p_request_id,
                       p_exception_type);
    elsif p_exception_type = 'AR' then
      notifyToAr(      p_event_name,
                       p_subject,
                       p_doc_pkg,
                       p_doc_proc,
                       p_request_id,
                       p_exception_type);
    else
      notifyToSysadmin(p_event_name,
                       p_subject,
                       p_doc_pkg,
                       p_doc_proc,
                       p_request_id,
                       p_exception_type);
    end if;
    if ar_doc_transfer_standard.isDebugOn then ar_doc_transfer_standard.debug('AR_TRANSFER_DOCUMENT.notify(-)'); end if;
  end;

  procedure transfer_documents(errbuf    out NOCOPY varchar2,
                               retcode   out NOCOPY varchar2) is

    cursor doc_trs is
      select * from ar_document_transfers where status = 'WAITING';

    cursor err_trs is
      select distinct exception_type from ar_document_transfers
      where status = 'FAILED';

    l_subject varchar2(100);
    l_sqlerrm varchar2(1000);
    l_ok_rec boolean := false;
    l_trx_type varchar2(100);
    l_trx_subtype varchar2(100);
    l_msgid VARCHAR2(200);

  begin
    if ar_doc_transfer_standard.isDebugOn then ar_doc_transfer_standard.debug('AR_TRANSFER_DOCUMENT.transfer_documents(+)'); end if;
    for doc_rec in doc_trs loop
      doc_rec.request_id := fnd_global.conc_request_id;
      validate_document_record(doc_rec);
      if doc_rec.status = 'WAITING' then
        ar_doc_transfer_standard.raiseTransferEvent(
            p_event_name      => doc_rec.event_name,
            p_trx_type        => doc_rec.ecx_trx_type,
            p_trx_sub_type    => doc_rec.ecx_trx_subtype,
            p_party_id        => null,
            p_party_site_id   => doc_rec.tp_source_id,
            p_party_type      => doc_rec.ecx_party_type,
            p_doc_transfer_id => doc_rec.document_transfer_id);
        /* Bug 8320506 Updating to status STARTED in order to prevent duplication*/
            doc_rec.status := 'STARTED';
            doc_rec.document_msgid := l_msgid;
            doc_rec.last_submission_date := sysdate;
            doc_rec.exception_type := null;
            doc_rec.exception_message := null;
            ar_document_transfer_pkg.updateRow(doc_rec);
      else
        ar_document_transfer_pkg.updateRow(doc_rec);
      end if;
    end loop;
    for err_rec in err_trs loop
      if l_subject is null then
        fnd_message.set_name('AR','AR_DOC_TRS_SBJ');
        fnd_message.set_token('REQUEST_ID', fnd_global.conc_request_id);
        l_subject := fnd_message.get;
      end if;
      notify(p_event_name => 'oracle.apps.ar.transmit.notification',
             p_subject => l_subject,
             p_doc_pkg => 'AR_TRANSFER_DOCUMENT',
             p_doc_proc => 'BUILD_BATCH_ERROR_MESSAGE',
             p_request_id => fnd_global.conc_request_id,
             p_exception_type => err_rec.exception_type);
    end loop;
    retcode := 0;
    if ar_doc_transfer_standard.isDebugOn then ar_doc_transfer_standard.debug('AR_TRANSFER_DOCUMENT.transfer_documents(-)'); end if;

  exception
   when others then
     l_sqlerrm := sqlerrm(sqlcode) || fnd_global.newline ||
                   'Location: AR_TRANSFER_DOCUMENT.transfer_documents()'||fnd_global.newline||
                   'Time: '||to_char(sysdate, 'DD-MON-RRRR HH:MI:SS');
     retcode := 2;
     fnd_message.set_name('AR','AR_DOC_TRS_SBJ');
     fnd_message.set_token('REQUEST_ID', fnd_global.conc_request_id);
     l_subject := fnd_message.get;
     if ar_doc_transfer_standard.isDebugOn then
      ar_doc_transfer_standard.debug('AR_TRANSFER_DOCUMENTS.transfer_documents()EXCEPTION:'||l_sqlerrm);
     end if;
     ar_notification_standard.notifyToSysadmin(l_subject,
                                               l_sqlerrm);
  end;

  procedure build_batch_error_message_clob(	document_id	in	varchar2,
						display_type	in	varchar2,
						document	in out NOCOPY	CLOB,
						document_type	in out NOCOPY	varchar2) is
  l_buffer    varchar2(1000);
  l_item_type varchar2(30);
  l_item_key  varchar2(30);
  l_request_id number;
  l_exception_type varchar2(30);

  cursor err_csr is
    select exception_message from ar_document_transfers
    where exception_type = l_exception_type;
    --where request_id = l_request_id and exception_type = l_exception_type;

  begin
    if ar_doc_transfer_standard.isDebugOn then
      ar_doc_transfer_standard.debug('AR_TRANSFER_DOCUMENT.build_batch_error_message(+)');
    end if;
    fnd_message.set_name('AR', 'AR_DOC_TRS_BODY');
    WF_NOTIFICATION.WriteToClob(document,fnd_message.get||fnd_global.newline||fnd_global.newline);
    ar_notification_standard.parseDocumentId(document_id, l_item_type, l_item_key);
    l_request_id := wf_engine.getItemAttrText(itemType => l_item_type,
                                              itemKey  => l_item_key,
                                              aname    => 'USER_AREA1');
    l_exception_type := wf_engine.getItemAttrText(itemType => l_item_type,
                                                  itemKey  => l_item_key,
                                                  aname    => 'USER_AREA2');
    for err_rec in err_csr loop
      WF_NOTIFICATION.WriteToClob(document, err_rec.exception_message||fnd_global.newline);
    end loop;
    document_type := 'text/plain';
    if ar_doc_transfer_standard.isDebugOn then
      ar_doc_transfer_standard.debug('AR_TRANSFER_DOCUMENT.build_batch_error_message(-)');
    end if;
  end;

  procedure build_batch_error_message(	document_id	in	varchar2,
					display_type	in	varchar2,
					document	in out NOCOPY	varchar2,
					document_type	in out NOCOPY	varchar2) is
  l_buffer    varchar2(32000);
  l_item_type varchar2(30);
  l_item_key  varchar2(30);
  l_request_id number;
  l_exception_type varchar2(30);

  cursor err_csr is
    select exception_message from ar_document_transfers
    where exception_type = l_exception_type;
    --where request_id = l_request_id and exception_type = l_exception_type;

  begin
    if ar_doc_transfer_standard.isDebugOn then
      ar_doc_transfer_standard.debug('AR_TRANSFER_DOCUMENT.build_batch_error_message(+)');
    end if;
    fnd_message.set_name('AR', 'AR_DOC_TRS_BODY');

    ar_notification_standard.parseDocumentId(document_id, l_item_type, l_item_key);
    l_request_id := wf_engine.getItemAttrText(itemType => l_item_type,
                                              itemKey  => l_item_key,
                                              aname    => 'USER_AREA1');
    l_exception_type := wf_engine.getItemAttrText(itemType => l_item_type,
                                                  itemKey  => l_item_key,
                                                  aname    => 'USER_AREA2');
    for err_rec in err_csr loop
      l_buffer := l_buffer ||err_rec.exception_message||fnd_global.newline;
    end loop;
    document := fnd_message.get||fnd_global.newline||fnd_global.newline ||
                l_buffer;
    document_type := 'text/plain';

    if ar_doc_transfer_standard.isDebugOn then
      ar_doc_transfer_standard.debug('AR_TRANSFER_DOCUMENT.build_batch_error_message(-)');
    end if;
  end;


begin
  if ar_doc_transfer_standard.isDebugOn then ar_doc_transfer_standard.debug('AR_TRANSFER_DOCUMENT(+)'); end if;
  if ar_doc_transfer_standard.isDebugOn then ar_doc_transfer_standard.debug('AR_TRANSFER_DOCUMENT(-)'); end if;
end;

/
