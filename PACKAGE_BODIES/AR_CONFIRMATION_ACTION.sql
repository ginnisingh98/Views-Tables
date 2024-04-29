--------------------------------------------------------
--  DDL for Package Body AR_CONFIRMATION_ACTION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_CONFIRMATION_ACTION" AS
/*$Header: ARCOATNB.pls 120.2 2005/07/22 09:48:27 naneja noship $ */

procedure update_status(p_status in varchar2,
                        p_doc_transfer_id in NUMBER,
                        p_msgid  in VARCHAR2,
			p_exception_message in varchar2 default null,
			p_exception_type in varchar2 default null) is
  cursor doc is
    select * from ar_document_transfers
    where document_transfer_id = p_doc_transfer_id;
  doc_rec ar_document_transfers%rowtype;

  begin
    if ar_doc_transfer_standard.isDebugOn then ar_doc_transfer_standard.debug('AR_CONFIRMATION_ACTION.update_status(+)'); end if;
    open doc; fetch doc into doc_rec; close doc;
    doc_rec.confirmation_msgid := p_msgid;
    doc_rec.status := p_status;
    doc_rec.exception_message := p_exception_message;
    doc_rec.exception_type := p_exception_type;
    ar_document_transfer_pkg.updateRow(doc_rec);
    if ar_doc_transfer_standard.isDebugOn then ar_doc_transfer_standard.debug('AR_CONFIRMATION_ACTION.update_status(-)'); end if;
  end;

function parseAndValidateId(p_id in varchar2,
                            p_doc_transfer_id out nocopy  number,
                            p_responsibility_id out nocopy number,
                            p_trx_number out nocopy varchar2,
                            p_trx_date out nocopy date,
                            p_currency out nocopy varchar2,
                            p_line_number out nocopy number) return boolean is
  l_exists varchar2(1);
  l_retcode boolean;
  l_trx_id varchar2(50);
  l_trx_line_id varchar2(50);
  l_doc_transfer_id varchar2(50);
  cursor trx is select dt.responsibility_id,
                       dt.status,
                       trx.trx_number,
                       trx.trx_date,
                       trx.INVOICE_CURRENCY_CODE,
                       trxl.line_number
                from ar_document_transfers dt,
                     ra_customer_trx trx,
                     ra_customer_trx_lines trxl
                where dt.document_transfer_id = l_doc_transfer_id and
                      trx.customer_trx_id = l_trx_id and
                      trxl.customer_trx_line_id(+) = l_trx_line_id and
                      dt.source_table = 'RA_CUSTOMER_TRX' and
                      dt.source_id = trx.customer_trx_id and
                      trx.customer_trx_id = trxl.customer_trx_id(+);
  l_trx_rec trx%rowtype;
  begin
    if ar_doc_transfer_standard.isDebugOn then ar_doc_transfer_standard.debug('AR_CONFIRMATION_ACTION.parseAndValidateId(+)'); end if;
    l_doc_transfer_id := rtrim(ltrim(substrb(p_id,1,instrb(p_id,':',1,1)-1)));
    if instrb(p_id, ':',1,2) = 0 then --Header Only
      l_trx_id := rtrim(ltrim(substrb(p_id, instrb(p_id,':',1,1)+1)));
    else -- Header and Line
      l_trx_id := rtrim(ltrim(substrb(p_id, instrb(p_id,':',1,1)+1,instrb(p_id,':',1,2)-1)));
      l_trx_line_id := rtrim(ltrim(substrb(p_id, instrb(p_id,':',1,2)+1)));
    end if;

    if ar_doc_transfer_standard.isDebugOn then
      ar_doc_transfer_standard.debug('l_doc_transfer_id:'||l_doc_transfer_id);
      ar_doc_transfer_standard.debug('l_trx_id:'||l_trx_id);
      ar_doc_transfer_standard.debug('l_trx_line_id:'||l_trx_line_id);
    end if;
    open trx; fetch trx into l_trx_rec; close trx;
    if ar_doc_transfer_standard.isDebugOn then
      ar_doc_transfer_standard.debug('l_trx_rec.trx_number:'||l_trx_rec.trx_number);
      ar_doc_transfer_standard.debug('l_trx_rec.trx_date:'||to_char(l_trx_rec.trx_date));
      ar_doc_transfer_standard.debug('l_trx_rec.invoice_currency_code:'||l_trx_rec.invoice_currency_code);
      ar_doc_transfer_standard.debug('l_trx_rec.line_number:'||l_trx_rec.line_number);
    end if;
    if l_trx_rec.trx_number is null then
      l_retcode := false;
    else
      l_retcode := true;
      p_doc_transfer_id := l_doc_transfer_id;
      p_responsibility_id := l_trx_rec.responsibility_id;
      p_trx_number := l_trx_rec.trx_number;
      p_trx_date := l_trx_rec.trx_date;
      p_currency := l_trx_rec.INVOICE_CURRENCY_CODE;
      p_line_number := l_trx_rec.line_number;
    end if;
    if ar_doc_transfer_standard.isDebugOn then ar_doc_transfer_standard.debug('AR_CONFIRMATION_ACTION.parseAndValidateId(-)'); end if;
    return l_retcode;
  end;

procedure notifyToSysadmin(p_id in varchar2) is
  l_subject varchar2(200);
  l_body varchar2(4000);
  begin
    if ar_doc_transfer_standard.isDebugOn then ar_doc_transfer_standard.debug('AR_CONFIRMATION_ACTION.notifyToSysadmin(+)'); end if;
    fnd_message.set_name('AR','AR_CONF_ACT_INV_ID_SBJ');
    l_subject := fnd_message.get;
    fnd_message.set_name('AR','AR_CONF_ACT_INV_ID_BODY');
    fnd_message.set_token('P_ID', p_id);
    l_body := fnd_message.get;
    ar_notification_standard.notifyToSysadmin(l_subject, l_body);
    if ar_doc_transfer_standard.isDebugOn then ar_doc_transfer_standard.debug('AR_CONFIRMATION_ACTION.notifyToSysadmin(-)'); end if;
  end;

procedure processRejection(p_id in varchar2, p_reason_code in varchar2, p_msgid in varchar2) is
  l_doc_transfer_id number;
  l_trx_number varchar2(20);
  l_trx_date date;
  l_invoice_currency varchar2(15);
  l_line_number number;
  l_responsibility_id number;
  l_subject varchar2(200);
  l_body varchar2(4000);
  l_msg varchar2(240);
  l_url varchar2(500);
  cursor ap_lookups is
    select description from ap_lookup_codes
    where lookup_type = 'REJECT CODE' and lookup_code = p_reason_code;

  begin
    if ar_doc_transfer_standard.isDebugOn then
      ar_doc_transfer_standard.debug('AR_CONFIRMATION_ACTION.processRejection(+)');
      ar_doc_transfer_standard.debug('p_id:'||p_id);
      ar_doc_transfer_standard.debug('p_reason_code:'||p_reason_code);
      ar_doc_transfer_standard.debug('p_msgid:'||p_msgid);
    end if;
    if parseAndValidateId(p_id => p_id,
                          p_doc_transfer_id => l_doc_transfer_id,
                          p_responsibility_id => l_responsibility_id,
                          p_trx_number => l_trx_number,
                          p_trx_date => l_trx_date,
                          p_currency => l_invoice_currency,
                          p_line_number => l_line_number) then
      fnd_message.set_name('AR', 'AR_CONF_ACT_CUST_MSG_SBJ');
      l_subject := fnd_message.get;
      if l_line_number is null then
        fnd_message.set_name('AR','AR_CONF_ACT_CUST_MSG_BODY1');
      else
        fnd_message.set_name('AR','AR_CONF_ACT_CUST_MSG_BODY2');
        fnd_message.set_token('LINE_NUMBER',to_char(l_line_number));
      end if;
      fnd_message.set_token('TRX_NUMBER', l_trx_number);
      fnd_message.set_token('TRX_DATE', to_char(l_trx_date));
      fnd_message.set_token('CURRENCY', l_invoice_currency);
      l_body := fnd_message.get||fnd_global.newline||fnd_global.newline;
      open ap_lookups; fetch ap_lookups into l_msg; close ap_lookups;
      l_body := l_body||l_msg;
      l_url := 'JSP:/OA_HTML/OA.jsp?akRegionCode=ARDOCTRSPG'||'&'||
                                   'akRegionApplicationId=222'||'&'||
                                   'Query=Y'||'&'||
                                   'DocumentTransferNumber='||to_char(l_doc_transfer_id);
      ar_notification_standard.notify(l_subject,
                                      l_body,
                                      'FND_RESP222:'||to_char(l_responsibility_id),
                                      l_url);
      update_status('REJECTED', l_doc_transfer_id, p_msgid, l_body, 'AR');
    else
      notifyToSysadmin(p_id);
    end if;
    if ar_doc_transfer_standard.isDebugOn then ar_doc_transfer_standard.debug('AR_CONFIRMATION_ACTION.processRejection(-)');end if;
  end;


procedure SUCCESSFUL_TRANSMISSION(      P_STATUS in VARCHAR2,
                                        P_ID in VARCHAR2,
                                        P_REASON_CODE in VARCHAR2,
                                        P_DESCRIPTION in VARCHAR2,
                                        P_MSGID in VARCHAR2) is
  l_doc_transfer_id number;
  l_trx_number varchar2(20);
  l_trx_date date;
  l_invoice_currency varchar2(15);
  l_line_number number;
  l_responsibility_id number;
  begin
    if ar_doc_transfer_standard.isDebugOn then ar_doc_transfer_standard.debug('AR_CONFIRMATION_ACTION.SUCCESSFUL_TRANSMISSION(+)'); end if;
    if parseAndValidateId(p_id => p_id,
                          p_doc_transfer_id => l_doc_transfer_id,
                          p_responsibility_id => l_responsibility_id,
                          p_trx_number => l_trx_number,
                          p_trx_date => l_trx_date,
                          p_currency => l_invoice_currency,
                          p_line_number => l_line_number) then
      update_status('ACCEPTED', l_doc_transfer_id, p_msgid);
    else
      notifyToSysadmin(p_id);
    end if;
    if ar_doc_transfer_standard.isDebugOn then ar_doc_transfer_standard.debug('AR_CONFIRMATION_ACTION.SUCCESSFUL_TRANSMISSION(-)'); end if;
  end;

procedure DUPL_INV_NUM_IN_IMPORT(       P_STATUS in VARCHAR2,
                                        P_ID in VARCHAR2,
                                        P_REASON_CODE in VARCHAR2,
                                        P_DESCRIPTION in VARCHAR2,
                                        P_MSGID in VARCHAR2) is

  begin
    if ar_doc_transfer_standard.isDebugOn then ar_doc_transfer_standard.debug('AR_CONFIRMATION_ACTION.DUPL_INV_NUM_IN_IMPORT(+)'); end if;
    processRejection(p_id, p_reason_code, p_msgid);
    if ar_doc_transfer_standard.isDebugOn then ar_doc_transfer_standard.debug('AR_CONFIRMATION_ACTION.DUPL_INV_NUM_IN_IMPORT(-)'); end if;
  end;

procedure DUPLICATE_INVOICE_NUMBER(     P_STATUS in VARCHAR2,
                                        P_ID in VARCHAR2,
                                        P_REASON_CODE in VARCHAR2,
                                        P_DESCRIPTION in VARCHAR2,
                                        P_MSGID in VARCHAR2) is
  begin
    if ar_doc_transfer_standard.isDebugOn then ar_doc_transfer_standard.debug('AR_CONFIRMATION_ACTION.DUPLICATE_INVOICE_NUMBER(+)'); end if;
    processRejection(p_id, p_reason_code, p_msgid);
    if ar_doc_transfer_standard.isDebugOn then ar_doc_transfer_standard.debug('AR_CONFIRMATION_ACTION.DUPLICATE_INVOICE_NUMBER(-)'); end if;
  end;

procedure DUPLICATE_LINE_NUMBER(        P_STATUS in VARCHAR2,
                                        P_ID in VARCHAR2,
                                        P_REASON_CODE in VARCHAR2,
                                        P_DESCRIPTION in VARCHAR2,
                                        P_MSGID in VARCHAR2) is
  begin
    if ar_doc_transfer_standard.isDebugOn then ar_doc_transfer_standard.debug('AR_CONFIRMATION_ACTION.DUPLICATE_LINE_NUMBER(+)'); end if;
    processRejection(p_id, p_reason_code, p_msgid);
    if ar_doc_transfer_standard.isDebugOn then ar_doc_transfer_standard.debug('AR_CONFIRMATION_ACTION.DUPLICATE_LINE_NUMBER(-)'); end if;
  end;


procedure INCONSISTENT_CURR(            P_STATUS in VARCHAR2,
                                        P_ID in VARCHAR2,
                                        P_REASON_CODE in VARCHAR2,
                                        P_DESCRIPTION in VARCHAR2,
                                        P_MSGID in VARCHAR2) is
  begin
    if ar_doc_transfer_standard.isDebugOn then ar_doc_transfer_standard.debug('AR_CONFIRMATION_ACTION.INCONSISTENT_CURR(+)'); end if;
    processRejection(p_id, p_reason_code, p_msgid);
    if ar_doc_transfer_standard.isDebugOn then ar_doc_transfer_standard.debug('AR_CONFIRMATION_ACTION.INCONSISTENT_CURR(-)'); end if;
  end;


procedure INCONSISTENT_PO_SUPPLIER(     P_STATUS in VARCHAR2,
                                        P_ID in VARCHAR2,
                                        P_REASON_CODE in VARCHAR2,
                                        P_DESCRIPTION in VARCHAR2,
                                        P_MSGID in VARCHAR2) is
  begin
    if ar_doc_transfer_standard.isDebugOn then ar_doc_transfer_standard.debug('AR_CONFIRMATION_ACTION.INCONSISTENT_PO_SUPPLIER(+)'); end if;
    processRejection(p_id, p_reason_code, p_msgid);
    if ar_doc_transfer_standard.isDebugOn then ar_doc_transfer_standard.debug('AR_CONFIRMATION_ACTION.INCONSISTENT_PO_SUPPLIER(-)'); end if;
  end;


procedure INVALID_LINE_AMOUNT(          P_STATUS in VARCHAR2,
                                        P_ID in VARCHAR2,
                                        P_REASON_CODE in VARCHAR2,
                                        P_DESCRIPTION in VARCHAR2,
                                        P_MSGID in VARCHAR2) is
  begin
    if ar_doc_transfer_standard.isDebugOn then ar_doc_transfer_standard.debug('AR_CONFIRMATION_ACTION.INVALID_LINE_AMOUNT(+)'); end if;
    processRejection(p_id, p_reason_code, p_msgid);
    if ar_doc_transfer_standard.isDebugOn then ar_doc_transfer_standard.debug('AR_CONFIRMATION_ACTION.INVALID_LINE_AMOUNT(-)'); end if;
  end;


procedure INVALID_INVOICE_AMOUNT(       P_STATUS in VARCHAR2,
                                        P_ID in VARCHAR2,
                                        P_REASON_CODE in VARCHAR2,
                                        P_DESCRIPTION in VARCHAR2,
                                        P_MSGID in VARCHAR2) is
  begin
    if ar_doc_transfer_standard.isDebugOn then ar_doc_transfer_standard.debug('AR_CONFIRMATION_ACTION.INVALID_INVOICE_AMOUNT(+)'); end if;
    processRejection(p_id, p_reason_code, p_msgid);
    if ar_doc_transfer_standard.isDebugOn then ar_doc_transfer_standard.debug('AR_CONFIRMATION_ACTION.INVALID_INVOICE_AMOUNT(-)'); end if;
  end;


procedure INVALID_PO_INFO(              P_STATUS in VARCHAR2,
                                        P_ID in VARCHAR2,
                                        P_REASON_CODE in VARCHAR2,
                                        P_DESCRIPTION in VARCHAR2,
                                        P_MSGID in VARCHAR2) is
  begin
    if ar_doc_transfer_standard.isDebugOn then ar_doc_transfer_standard.debug('AR_CONFIRMATION_ACTION.INVALID_PO_INFO(+)'); end if;
    processRejection(p_id, p_reason_code, p_msgid);
    if ar_doc_transfer_standard.isDebugOn then ar_doc_transfer_standard.debug('AR_CONFIRMATION_ACTION.INVALID_PO_INFO(-)'); end if;
  end;


procedure INVALID_PO_NUM(               P_STATUS in VARCHAR2,
                                        P_ID in VARCHAR2,
                                        P_REASON_CODE in VARCHAR2,
                                        P_DESCRIPTION in VARCHAR2,
                                        P_MSGID in VARCHAR2) is
  begin
    if ar_doc_transfer_standard.isDebugOn then ar_doc_transfer_standard.debug('AR_CONFIRMATION_ACTION.INVALID_PO_NUM(+)'); end if;
    processRejection(p_id, p_reason_code, p_msgid);
    if ar_doc_transfer_standard.isDebugOn then ar_doc_transfer_standard.debug('AR_CONFIRMATION_ACTION.INVALID_PO_NUM(-)'); end if;
  end;


procedure INVALID_PO_RELEASE_INFO(      P_STATUS in VARCHAR2,
                                        P_ID in VARCHAR2,
                                        P_REASON_CODE in VARCHAR2,
                                        P_DESCRIPTION in VARCHAR2,
                                        P_MSGID in VARCHAR2) is
  begin
    if ar_doc_transfer_standard.isDebugOn then ar_doc_transfer_standard.debug('AR_CONFIRMATION_ACTION.INVALID_PO_RELEASE_INFO(+)'); end if;
    processRejection(p_id, p_reason_code, p_msgid);
    if ar_doc_transfer_standard.isDebugOn then ar_doc_transfer_standard.debug('AR_CONFIRMATION_ACTION.INVALID_PO_RELEASE_INFO(-)'); end if;
  end;


procedure INVALID_PO_RELEASE_NUM(       P_STATUS in VARCHAR2,
                                        P_ID in VARCHAR2,
                                        P_REASON_CODE in VARCHAR2,
                                        P_DESCRIPTION in VARCHAR2,
                                        P_MSGID in VARCHAR2) is
  begin
    if ar_doc_transfer_standard.isDebugOn then ar_doc_transfer_standard.debug('AR_CONFIRMATION_ACTION.INVALID_PO_RELEASE_NUM(+)'); end if;
    processRejection(p_id, p_reason_code, p_msgid);
    if ar_doc_transfer_standard.isDebugOn then ar_doc_transfer_standard.debug('AR_CONFIRMATION_ACTION.INVALID_PO_RELEASE_NUM(-)'); end if;
  end;


procedure INVALID_PO_SHIPMENT_NUM(      P_STATUS in VARCHAR2,
                                        P_ID in VARCHAR2,
                                        P_REASON_CODE in VARCHAR2,
                                        P_DESCRIPTION in VARCHAR2,
                                        P_MSGID in VARCHAR2) is
  begin
    if ar_doc_transfer_standard.isDebugOn then ar_doc_transfer_standard.debug('AR_CONFIRMATION_ACTION.INVALID_PO_SHIPMENT_NUM(+)'); end if;
    processRejection(p_id, p_reason_code, p_msgid);
    if ar_doc_transfer_standard.isDebugOn then ar_doc_transfer_standard.debug('AR_CONFIRMATION_ACTION.INVALID_PO_SHIPMENT_NUM(-)'); end if;
  end;


procedure INVALID_PRICE_QUANTITY(       P_STATUS in VARCHAR2,
                                        P_ID in VARCHAR2,
                                        P_REASON_CODE in VARCHAR2,
                                        P_DESCRIPTION in VARCHAR2,
                                        P_MSGID in VARCHAR2) is
  begin
    if ar_doc_transfer_standard.isDebugOn then ar_doc_transfer_standard.debug('AR_CONFIRMATION_ACTION.INVALID_PRICE_QUANTITY(+)'); end if;
    processRejection(p_id, p_reason_code, p_msgid);
    if ar_doc_transfer_standard.isDebugOn then ar_doc_transfer_standard.debug('AR_CONFIRMATION_ACTION.INVALID_PRICE_QUANTITY(-)'); end if;
  end;


procedure INVALID_QUANTITY(             P_STATUS in VARCHAR2,
                                        P_ID in VARCHAR2,
                                        P_REASON_CODE in VARCHAR2,
                                        P_DESCRIPTION in VARCHAR2,
                                        P_MSGID in VARCHAR2) is
  begin
    if ar_doc_transfer_standard.isDebugOn then ar_doc_transfer_standard.debug('AR_CONFIRMATION_ACTION.(+)'); end if;
    processRejection(p_id, p_reason_code, p_msgid);
    if ar_doc_transfer_standard.isDebugOn then ar_doc_transfer_standard.debug('AR_CONFIRMATION_ACTION.(-)'); end if;
  end;


procedure INVALID_SUPPLIER(             P_STATUS in VARCHAR2,
                                        P_ID in VARCHAR2,
                                        P_REASON_CODE in VARCHAR2,
                                        P_DESCRIPTION in VARCHAR2,
                                        P_MSGID in VARCHAR2) is
  begin
    if ar_doc_transfer_standard.isDebugOn then ar_doc_transfer_standard.debug('AR_CONFIRMATION_ACTION.INVALID_SUPPLIER(+)'); end if;
    processRejection(p_id, p_reason_code, p_msgid);
    if ar_doc_transfer_standard.isDebugOn then ar_doc_transfer_standard.debug('AR_CONFIRMATION_ACTION.INVALID_SUPPLIER(-)'); end if;
  end;



procedure INVALID_SUPPLIER_SITE(        P_STATUS in VARCHAR2,
                                        P_ID in VARCHAR2,
                                        P_REASON_CODE in VARCHAR2,
                                        P_DESCRIPTION in VARCHAR2,
                                        P_MSGID in VARCHAR2) is
  begin
    if ar_doc_transfer_standard.isDebugOn then ar_doc_transfer_standard.debug('AR_CONFIRMATION_ACTION.INVALID_SUPPLIER_SITE(+)'); end if;
    processRejection(p_id, p_reason_code, p_msgid);
    if ar_doc_transfer_standard.isDebugOn then ar_doc_transfer_standard.debug('AR_CONFIRMATION_ACTION.INVALID_SUPPLIER_SITE(-)'); end if;
  end;


procedure INVALID_UNIT_PRICE(           P_STATUS in VARCHAR2,
                                        P_ID in VARCHAR2,
                                        P_REASON_CODE in VARCHAR2,
                                        P_DESCRIPTION in VARCHAR2,
                                        P_MSGID in VARCHAR2) is
  begin
    if ar_doc_transfer_standard.isDebugOn then ar_doc_transfer_standard.debug('AR_CONFIRMATION_ACTION.INVALID_UNIT_PRICE(+)'); end if;
    processRejection(p_id, p_reason_code, p_msgid);
    if ar_doc_transfer_standard.isDebugOn then ar_doc_transfer_standard.debug('AR_CONFIRMATION_ACTION.INVALID_UNIT_PRICE(-)'); end if;
  end;


procedure NO_PO_LINE_NUM(               P_STATUS in VARCHAR2,
                                        P_ID in VARCHAR2,
                                        P_REASON_CODE in VARCHAR2,
                                        P_DESCRIPTION in VARCHAR2,
                                        P_MSGID in VARCHAR2) is
  begin
    if ar_doc_transfer_standard.isDebugOn then ar_doc_transfer_standard.debug('AR_CONFIRMATION_ACTION.NO_PO_LINE_NUM(+)'); end if;
    processRejection(p_id, p_reason_code, p_msgid);
    if ar_doc_transfer_standard.isDebugOn then ar_doc_transfer_standard.debug('AR_CONFIRMATION_ACTION.NO_PO_LINE_NUM(-)'); end if;
  end;


procedure NO_SUPPLIER(                  P_STATUS in VARCHAR2,
                                        P_ID in VARCHAR2,
                                        P_REASON_CODE in VARCHAR2,
                                        P_DESCRIPTION in VARCHAR2,
                                        P_MSGID in VARCHAR2) is
  begin
    if ar_doc_transfer_standard.isDebugOn then ar_doc_transfer_standard.debug('AR_CONFIRMATION_ACTION.NO_SUPPLIER(+)'); end if;
    processRejection(p_id, p_reason_code, p_msgid);
    if ar_doc_transfer_standard.isDebugOn then ar_doc_transfer_standard.debug('AR_CONFIRMATION_ACTION.NO_SUPPLIER(-)'); end if;
  end;


procedure RELEASE_MISSNG(               P_STATUS in VARCHAR2,
                                        P_ID in VARCHAR2,
                                        P_REASON_CODE in VARCHAR2,
                                        P_DESCRIPTION in VARCHAR2,
                                        P_MSGID in VARCHAR2) is
  begin
    if ar_doc_transfer_standard.isDebugOn then ar_doc_transfer_standard.debug('AR_CONFIRMATION_ACTION.RELEASE_MISSNG(+)'); end if;
    processRejection(p_id, p_reason_code, p_msgid);
    if ar_doc_transfer_standard.isDebugOn then ar_doc_transfer_standard.debug('AR_CONFIRMATION_ACTION.RELEASE_MISSNG(-)'); end if;
  end;

begin
  if ar_doc_transfer_standard.isDebugOn then ar_doc_transfer_standard.debug('AR_CONFIRMATION_ACTION(+)'); end if;
  if ar_doc_transfer_standard.isDebugOn then ar_doc_transfer_standard.debug('AR_CONFIRMATION_ACTION(-)'); end if;
end;

/
