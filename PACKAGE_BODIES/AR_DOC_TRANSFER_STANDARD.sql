--------------------------------------------------------
--  DDL for Package Body AR_DOC_TRANSFER_STANDARD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_DOC_TRANSFER_STANDARD" as
/*$Header: ARDOCTFB.pls 120.13.12010000.2 2009/09/10 05:59:31 nproddut ship $ */

  PG_DEBUG varchar2(1);
  PG_DEBUG_PATH varchar2(1000);


  PROCEDURE CallbackFunction(p_item_type      IN VARCHAR2,
                             p_item_key       IN VARCHAR2,
                             p_actid          IN NUMBER,
                             p_funmode        IN VARCHAR2,
                             p_result         OUT NOCOPY VARCHAR2) is
    l_org_id NUMBER;

  begin
    l_org_id := WF_ENGINE.GetItemAttrNumber(p_item_type,
                                            p_item_key,
                                            'ORG_ID');

    if ( p_funmode = 'SET_CTX' ) then
      if (l_org_id is not null) then
         --replaced the call to fnd_client_info with mo_global[bug 5729562]
         mo_global.set_policy_context('S',l_org_id);
      end if;
      p_result := 'TRUE';
      return;
    end if;

    if ( p_funmode = 'TEST_CTX') then
      if(l_org_id is not null) then
         --replaced the call to fnd_client_info with mo_global[bug 5729562]
         mo_global.set_policy_context('S',l_org_id);
      end if;
      IF (nvl(rtrim(substrb(USERENV('CLIENT_INFO'), 1, 10)),'NULL') = nvl(to_char(l_org_id),'NULL')) THEN
        p_result := 'TRUE';
      ELSE
        p_result := 'FALSE';
      END IF;
      return;
    end if;
  end;

  function  otaCallBackRule(p_subscription_guid in     raw,
                            p_event            in out nocopy wf_event_t) return varchar2 is
    l_msgid raw(16);
    l_extType varchar2(80);
    l_extSubType varchar2(80);
    l_msg varchar2(4000);
    l_returnCode varchar2(240);
    l_errType varchar2(10);
  begin
    if isDebugOn then debug('AR_DOC_TRANSFER_STANDARD.otaCallBackRule(+)'); end if;

    l_msgid := p_event.getValueForParameter('ECX_MSGID');
    l_extType := p_event.getValueForParameter('ECX_TRANSACTION_TYPE');
    l_extSubType := p_event.getValueForParameter('ECX_TRANSACTION_SUBTYPE');
    l_returnCode := p_event.getValueForParameter('ECX_RETURN_CODE');
    l_msg := p_event.getValueForParameter('ECX_ERROR_MSG');
    fnd_message.set_name('ECX', l_msg);
    l_msg := fnd_message.get;
    if l_returnCode <> '0' and l_msg is not null then
      l_errType := 'SYSTEM';
    end if;
    if l_extType = 'INVOICE' and l_extSubType = 'PROCESS' then
      update ar_document_transfers
      set status = decode(l_returnCode,'0','TRANSMITTED','FAILED'),
          exception_message = decode(l_returnCode, '0', null, l_msg),
          exception_type = l_errType
      where document_msgid = l_msgid;
    end if;
    if isDebugOn then debug('AR_DOC_TRANSFER_STANDARD.otaCallBackRule(-)'); end if;
    return 'SUCCESS';
  exception
    when others then
      if isDebugOn then
        debug('AR_DOC_TRANSFER_STANDARD.otaCallBackRule(Exception)');
        debug(sqlerrm);
      end if;
      return 'ERROR';
  end;

  procedure debug(p_line in varchar2) is
  begin
    arp_standard.debug(p_line);
  end;

  function isDebugOn return boolean is
    l_path varchar2(200);
  begin
    if pg_debug in ('Y', 'C') then
      return true;
    else
      return false;
    end if;
  exception
    when others then
      return false;
  end;


  procedure updateStatus is
  begin
    if isDebugOn then debug('AR_DOC_TRANSFER_STANDARD.updateStatus(+)'); end if;
    /*
    update ar_document_transfers doc
    set doc.status = 'TRANSMITTED'
    where doc.status = 'STARTED' and
          exists (select 'X'
                  from   ecx_out_process_v ecx
                  where	 ecx.document_id = doc.document_transfer_id and
			 ecx.transaction_type = doc.ecx_trx_type and
			 ecx.transaction_subtype = doc.ecx_trx_subtype and
			 ecx.party_site_id = doc.tp_source_id and
			 ecx.out_msgid = doc.document_msgid and
			 ltrim(rtrim(ecx.delivery_status)) = '0');
    update ar_document_transfers doc
    set doc.status = 'FAILED',
        doc.exception_type = 'SYSTEM',
        doc.exception_message = 'Oracle Transport Agent: maximum transport attempts exceeded.'||
                                'Please contact System administrator'
    where doc.status = 'STARTED' and
          exists (select 'X'
                  from   ecx_out_process_v ecx
                  where	 ecx.document_id = doc.document_transfer_id and
			 ecx.transaction_type = doc.ecx_trx_type and
			 ecx.transaction_subtype = doc.ecx_trx_subtype and
			 ecx.party_site_id = doc.tp_source_id and
			 ecx.out_msgid = doc.document_msgid and
			 ltrim(rtrim(ecx.delivery_status)) <> '0');
    */
    if isDebugOn then debug('AR_DOC_TRANSFER_STANDARD.updateStatus(-)');end if;
  end;


  procedure email_transfer(	ITEMTYPE  IN      VARCHAR2,
               			ITEMKEY   IN      VARCHAR2,
               			ACTID     IN      NUMBER,
               			FUNCMODE  IN      VARCHAR2,
	               		RESULTOUT IN OUT NOCOPY VARCHAR2) is
  begin
    if isDebugOn then debug('AR_DOC_TRANSFER_STANDARD.email_transfer(-)');end if;
    if isDebugOn then debug('AR_DOC_TRANSFER_STANDARD.email_transfer(-)');end if;
  end;

  procedure edi_transfer(	ITEMTYPE  IN      VARCHAR2,
               			ITEMKEY   IN      VARCHAR2,
               			ACTID     IN      NUMBER,
               			FUNCMODE  IN      VARCHAR2,
               			RESULTOUT IN OUT NOCOPY VARCHAR2) is
  begin
    if isDebugOn then debug('AR_DOC_TRANSFER_STANDARD.edi_transfer(-)');end if;
    if isDebugOn then debug('AR_DOC_TRANSFER_STANDARD.edi_transfer(-)');end if;
  end;


  procedure xml_transfer(	ITEMTYPE  IN      VARCHAR2,
	               		ITEMKEY   IN      VARCHAR2,
        	       		ACTID     IN      NUMBER,
               			FUNCMODE  IN      VARCHAR2,
               			RESULTOUT IN OUT NOCOPY VARCHAR2) is

  l_doc_transfer_id VARCHAR2(200);
  l_doc_trx_type varchar2(200);
  l_msgid VARCHAR2(200);
  l_sqlerrm VARCHAR2(2000);
  l_subject VARCHAR2(200);
  cursor doc is select * from ar_document_transfers
                where document_transfer_id = l_doc_transfer_id;

  doc_rec doc%rowtype;
  l_x varchar2(1);
  l_org_id NUMBER;


  begin
    if isDebugOn then debug('AR_DOC_TRANSFER_STANDARD.xml_transfer(+)');end if;

    l_doc_transfer_id  := wf_engine.getItemAttrText(itemtype,
                                                    itemkey,
                                                    'ECX_DOCUMENT_ID');
    l_doc_trx_type  := wf_engine.getItemAttrText(itemtype,
                                                 itemkey,
                                                 'ECX_TRANSACTION_TYPE');
    open doc; fetch doc into doc_rec; close doc;


    begin

      if fnd_global.org_id is not null then
        if doc_rec.source_table = 'RA_CUSTOMER_TRX' then
          select org_id into l_org_id from ra_customer_trx_all
          where customer_trx_id = doc_rec.source_id;

          if l_org_id is not null then
            --replaced the call to fnd_client_info with mo_global[bug 5729562]
            mo_global.set_policy_context('S',l_org_id);
          end if;

        end if;
      end if;

      if isDebugOn then debug('ECX_STANDARD.SEND(+)');end if;
      ECX_STANDARD.SEND(ITEMTYPE,ITEMKEY,ACTID,FUNCMODE,RESULTOUT);
      l_msgid := wf_engine.GetItemAttrText(itemtype,
                                           itemkey,
                                           'ECX_MSGID_ATTR');
      update ecx_doclogs
        set cb_event_name = 'oracle.apps.ar.transmit.otaCallback',
            cb_event_key = to_char(sysdate, 'DD-MON-RRRR-HHMISS')
        where msgid = HEXTORAW( l_msgid );


      if isDebugOn then debug('ECX_STANDARD.SEND(-)');end if;

    exception
      when others then
        resultout := 'COMPLETE';
        doc_rec.status := 'FAILED';
        doc_rec.exception_type := 'SYSTEM';
        fnd_message.set_name('ECX','ECX_ERROR_EMAIL_HEADER');
        fnd_message.set_token('TRANSACTION_TYPE',l_doc_trx_type);
        fnd_message.set_token('DOCUMENT_NUMBER',l_doc_transfer_id);
        doc_rec.exception_message := fnd_message.get ||
                                     fnd_global.newline||
                                     sqlerrm;
        ar_document_transfer_pkg.updateRow(doc_rec);
        return;
    end;

    l_msgid := wf_engine.GetItemAttrText(itemtype,
                                         itemkey,
                                         'ECX_MSGID_ATTR');
    if isDebugOn then
      debug('l_doc_transfer_id:'||l_doc_transfer_id);
      debug('l_msgid:'||l_msgid);
      debug('doc_rec.dcument_transfer_id:'||to_char(doc_rec.document_transfer_id));
    end if;
    doc_rec.status := 'STARTED';
    doc_rec.document_msgid := l_msgid;
    doc_rec.last_submission_date := sysdate;
    doc_rec.exception_type := null;
    doc_rec.exception_message := null;
    if isDebugOn then
      debug('doc_rec.status:'||doc_rec.status);
      debug('doc_rec.document_msgid:'||doc_rec.document_msgid);
    end if;
    ar_document_transfer_pkg.updateRow(doc_rec);
    resultout := 'COMPLETE';
    if isDebugOn then
      debug('AR_DOC_TRANSFER_STANDARD.xml_transfer(-)');
    end if;
  end;

procedure raiseTransferEvent(p_event_name       in VARCHAR2,
                             p_trx_type         in VARCHAR2,
                             p_trx_sub_type     in VARCHAR2,
                             p_party_id         in NUMBER,
                             p_party_site_id    in NUMBER,
                             p_party_type       in VARCHAR2,
                             p_doc_transfer_id  in NUMBER) is

  l_parameter_list  wf_parameter_list_t := wf_parameter_list_t();
  l_itemkey varchar2(100);
  begin
    if isDebugOn then
      debug('AR_DOC_TRANSFER_STANDARD.raiseTransferEvent(+)');
      debug('p_event_name:'||p_event_name);
      debug('p_trx_type:'||p_trx_type);
      debug('p_trx_sub_type:'||p_trx_sub_type);
      debug('p_party_id:'||p_party_id);
      debug('p_party_site_id:'||p_party_site_id);
      debug('p_party_type:'||p_party_type);
      debug('p_doc_transfer_id:'||p_doc_transfer_id);
    end if;
    l_itemkey := to_char(p_doc_transfer_id)||':'||to_char(sysdate, 'DD-MON-RRRR-HHMISS');
    if isDebugOn then debug('l_itemkey:'||l_itemkey); end if;

    wf_event.AddParameterToList (
      p_name => 'ECX_TRANSACTION_TYPE',
      p_value => p_trx_type,
      p_parameterlist => l_parameter_list );

    wf_event.AddParameterToList (
      p_name => 'ECX_TRANSACTION_SUBTYPE',
      p_value => p_trx_sub_type,
      p_parameterlist => l_parameter_list );

    wf_event.AddParameterToList (
      p_name => 'ECX_PARTY_ID',
      p_value => NULL,
      p_parameterlist => l_parameter_list );

    wf_event.AddParameterToList(
      p_name => 'ECX_PARTY_SITE_ID',
      p_value => p_party_site_id,
      p_parameterlist => l_parameter_list );

    wf_event.AddParameterToList(
      p_name => 'ECX_PARTY_TYPE',
      p_value => p_party_type,
      p_parameterlist => l_parameter_list );

    wf_event.AddParameterToList (
      p_name => 'ECX_DOCUMENT_ID',
      p_value => p_doc_transfer_id,
      p_parameterlist => l_parameter_list );

    wf_event.AddParameterToList (
      p_name => 'ORG_ID',
      p_value => fnd_global.org_id,
      p_parameterlist => l_parameter_list );

    wf_event.raise(
      p_event_name  => p_event_name,
      p_event_key   => l_itemkey,
      p_parameters  => l_parameter_list);

    l_parameter_list.DELETE;
    if isDebugOn then debug('AR_DOC_TRANSFER_STANDARD.raiseTransferEvent(-)'); end if;
  end;

begin
  PG_DEBUG := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

  select decode(instrb(value,',',1,1),0,value,substrb(value, 1, instrb(value, ',',1)-1))
  into PG_DEBUG_PATH from v$parameter
  where name = 'utl_file_dir';

  if PG_DEBUG in ('Y','C') then
    arp_standard.enable_file_debug(PG_DEBUG_PATH, 'AR_DOCUMENT_TRANSFER.log');
  end if;
exception
  when others then
    PG_DEBUG := 'N';
end;

/
