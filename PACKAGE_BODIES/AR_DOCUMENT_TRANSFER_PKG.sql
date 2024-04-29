--------------------------------------------------------
--  DDL for Package Body AR_DOCUMENT_TRANSFER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_DOCUMENT_TRANSFER_PKG" as
/*$Header: ARDCUMTB.pls 115.1 2002/12/23 22:40:05 tkoshio noship $ */

procedure insertRow(P_DOCUMENT_TRANSFER_REC IN AR_DOCUMENT_TRANSFERS%ROWTYPE) is
  begin
    if ar_doc_transfer_standard.isDebugOn then ar_doc_transfer_standard.debug('AR_DOCUMENT_TRANSFER_PKG.insertRow(+)'); end if;
    if ar_doc_transfer_standard.isDebugOn then ar_doc_transfer_standard.debug('AR_DOCUMENT_TRANSFER_PKG.insertRow(-)'); end if;
  end;

procedure deleteRow(P_DOCUMENT_TRANSFER_ID  IN NUMBER) is
  begin
    if ar_doc_transfer_standard.isDebugOn then ar_doc_transfer_standard.debug('AR_DOCUMENT_TRANSFER_PKG.deleteRow(+)'); end if;
    delete from ar_document_transfers
    where document_transfer_id = p_document_transfer_id;
    if ar_doc_transfer_standard.isDebugOn then ar_doc_transfer_standard.debug('AR_DOCUMENT_TRANSFER_PKG.deleteRow(-)'); end if;
  end;

procedure updateRow(P_DOCUMENT_TRANSFER_REC IN AR_DOCUMENT_TRANSFERS%ROWTYPE) is
  begin
    if ar_doc_transfer_standard.isDebugOn then
      ar_doc_transfer_standard.debug('AR_DOCUMENT_TRANSFER_PKG.updateRow(+)');
      ar_doc_transfer_standard.debug('document_transfer_id:'||p_document_transfer_rec.document_transfer_id);
      ar_doc_transfer_standard.debug('status:'||p_document_transfer_rec.status);
      ar_doc_transfer_standard.debug('document_msgid:'||p_document_transfer_rec.document_msgid);
    end if;
    update ar_document_transfers
    set last_updated_by    = fnd_global.user_id,
        last_update_date   = sysdate,
        SOURCE_ID          = p_document_transfer_rec.source_id,
        SOURCE_TABLE       = p_document_transfer_rec.source_table,
        TP_SOURCE_TABLE    = p_document_transfer_rec.tp_source_table,
        TP_SOURCE_ID       = p_document_transfer_rec.tp_source_id,
        STATUS             = p_document_transfer_rec.status,
        EVENT_NAME         = p_document_transfer_rec.event_name,
        ECX_TRX_TYPE       = p_document_transfer_rec.ecx_trx_type,
        ECX_TRX_SUBTYPE    = p_document_transfer_rec.ecx_trx_subtype,
        ECX_PARTY_TYPE     = p_document_transfer_rec.ecx_party_type,
        EMAIL_ADDRESS      = p_document_transfer_rec.email_address,
        DOCUMENT_MSGID     = p_document_transfer_rec.document_msgid,
        CONFIRMATION_MSGID = p_document_transfer_rec.confirmation_msgid,
        EXCEPTION_TYPE     = p_document_transfer_rec.exception_type,
        EXCEPTION_MESSAGE  = p_document_transfer_rec.exception_message,
        REQUEST_ID         = p_document_transfer_rec.request_id,
        APPLICATION_ID     = p_document_transfer_rec.application_id,
        RESPONSIBILITY_ID  = p_document_transfer_rec.responsibility_id,
	LAST_SUBMISSION_DATE = p_document_transfer_rec.LAST_SUBMISSION_DATE
    where document_transfer_id = p_document_transfer_rec.document_transfer_id;
    if ar_doc_transfer_standard.isDebugOn then ar_doc_transfer_standard.debug('AR_DOCUMENT_TRANSFER_PKG.updateRow(-)'); end if;
  end;

begin
  if ar_doc_transfer_standard.isDebugOn then ar_doc_transfer_standard.debug('AR_DOCUMENT_TRANSFER_PKG(+)'); end if;
  if ar_doc_transfer_standard.isDebugOn then ar_doc_transfer_standard.debug('AR_DOCUMENT_TRANSFER_PKG(-)'); end if;
end;

/
