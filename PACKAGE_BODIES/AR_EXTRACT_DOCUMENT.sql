--------------------------------------------------------
--  DDL for Package Body AR_EXTRACT_DOCUMENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_EXTRACT_DOCUMENT" as
/*$Header: AREXTDCB.pls 120.9 2006/04/05 13:44:02 nsomawar noship $ */
/*Removed gscc warnings NOCOPY hint Bug 4462243*/
  procedure extract_documents(errbuf    out NOCOPY varchar2,
                              retcode   out NOCOPY varchar2,
                              argument1 in  varchar2,
                              argument2 in  varchar2,
                              argument3 in  varchar2,
                              argument4 in  varchar2,
                              argument5 in  varchar2,
                              argument6 in  varchar2,
                              argument7 in  varchar2,
                              argument8 in  varchar2) is

  l_trx_class 		VARCHAR2(20);
  l_trx_type_id		NUMBER;
  l_trx_number_low	VARCHAR2(20);
  l_trx_number_high	VARCHAR2(20);
  l_cust_class		VARCHAR2(30);
  l_cust_account_id	NUMBER;
  l_trx_date_low	DATE;
  l_trx_date_high	DATE;

  l_sqlerrm		VARCHAR2(2000);
  l_subject		VARCHAR2(200);

  CURSOR c_pending_trx IS
    select trx.customer_trx_id
    from   ar_document_transfers xfr,
           ra_customer_trx       trx
    where  xfr.status = 'WAITING' and
           xfr.source_id = trx.customer_trx_id and
           trx.PRINTING_PENDING <> 'N' and
           trx.PRINTING_COUNT is null and
           trx.PRINTING_LAST_PRINTED is null and
           trx.PRINTING_ORIGINAL_DATE is null and
           trx.LAST_PRINTED_SEQUENCE_NUM is null;

  begin
    if ar_doc_transfer_standard.isDebugOn then ar_doc_transfer_standard.debug('AR_EXTRACT_DOCUMENT.extract_documents(+)'); end if;
    if ar_doc_transfer_standard.isDebugOn then ar_doc_transfer_standard.debug('AR_EXTRACT_DOCUMENT.extract_documents(+)'); end if;
    l_trx_class 	:= argument1;
    if ar_doc_transfer_standard.isDebugOn then ar_doc_transfer_standard.debug('l_trx_class:'||l_trx_class); end if;
    l_trx_type_id	:= argument2;
    if ar_doc_transfer_standard.isDebugOn then ar_doc_transfer_standard.debug('l_trx_type_id:'||to_char(l_trx_type_id)); end if;
    l_trx_number_low	:= argument3;
    if ar_doc_transfer_standard.isDebugOn then ar_doc_transfer_standard.debug('l_trx_number_low:'||l_trx_number_low); end if;
    l_trx_number_high	:= argument4;
    if ar_doc_transfer_standard.isDebugOn then ar_doc_transfer_standard.debug('l_trx_number_high:'||l_trx_number_high); end if;
    l_cust_class	:= argument5;
    if ar_doc_transfer_standard.isDebugOn then ar_doc_transfer_standard.debug('l_cust_class:'||l_cust_class); end if;
    l_cust_account_id	:= argument6;
    if ar_doc_transfer_standard.isDebugOn then ar_doc_transfer_standard.debug('l_cust_account_id:'||to_char(l_cust_account_id)); end if;
    l_trx_date_low      := to_date(argument7,'yyyy/mm/dd hh24:mi:ss');  /* Bug 5110228 - added Mask for fnd_standard_date */
    /* l_trx_date_low	:= argument7; */
    if ar_doc_transfer_standard.isDebugOn then ar_doc_transfer_standard.debug('l_trx_date_low:'||to_char(l_trx_date_low)); end if;
    l_trx_date_high     := to_date(argument8,'yyyy/mm/dd hh24:mi:ss');  /* Bug 5110228 - added Mask for fnd_standard_date */
    /* l_trx_date_high	:= argument8; */
    if ar_doc_transfer_standard.isDebugOn then ar_doc_transfer_standard.debug('l_trx_date_high:'||to_char(l_trx_date_high)); end if;

    ar_doc_transfer_standard.updateStatus;

    insert into ar_document_transfers
	(	DOCUMENT_TRANSFER_ID,
		SOURCE_ID,
		SOURCE_TABLE,
	 	TP_SOURCE_TABLE,
	 	TP_SOURCE_ID,
		ECX_TRX_TYPE,
		ECX_TRX_SUBTYPE,
		ECX_PARTY_TYPE,
                EVENT_NAME,
		STATUS,
	 	REQUEST_ID,
	 	APPLICATION_ID,
	 	RESPONSIBILITY_ID,
                CREATION_DATE,
                CREATED_BY,
                LAST_UPDATE_DATE,
                LAST_UPDATED_BY,
		LAST_SUBMISSION_DATE,
		DOCUMENT_MSGID
      	)
      	(select AR_DOCUMENT_TRANSFERS_S.nextval,
		SOURCE_ID,
		SOURCE_TABLE,
		TP_SOURCE_TABLE,
		TP_SOURCE_ID,
		ECX_TRX_TYPE,
		ECX_TRX_SUBTYPE,
		ECX_PARTY_TYPE,
                EVENT_NAME,
		'WAITING',
		FND_GLOBAL.CONC_REQUEST_ID,
		FND_GLOBAL.RESP_APPL_ID,
		FND_GLOBAL.RESP_ID,
		SYSDATE,
		FND_GLOBAL.USER_ID,
		SYSDATE,
		FND_GLOBAL.USER_ID,
		NULL,
		NULL
	 from ar_document_transfers_v d
    	 where 	(l_trx_class is null or d.trx_class = l_trx_class) and
        	(l_trx_type_id is null or d.trx_type_id = l_trx_type_id) and
          	(l_trx_number_low is null or l_trx_number_low <= d.trx_number) and
          	(l_trx_number_high is null or d.trx_number <= l_trx_number_high) and
          	(l_cust_class is null or d.cust_class = l_cust_class) and
          	(l_cust_account_id is null or d.cust_account_id = l_cust_account_id) and
          	(l_trx_date_low is null or l_trx_date_low <= d.trx_date) and
          	(l_trx_date_high is null or d.trx_date <= l_trx_date_high));
    /* 4188835 - If we are updating the printing columns for a trx,
       we need to freeze it in the eyes of eTax */
    FOR trx in c_pending_trx LOOP
      arp_etax_util.global_document_update(trx.customer_trx_id,null,'PRINT');
    END LOOP;

    update ra_customer_trx
    set PRINTING_PENDING = 'N',
        PRINTING_COUNT = 1,
        PRINTING_LAST_PRINTED = sysdate,
        PRINTING_ORIGINAL_DATE = sysdate,
        LAST_PRINTED_SEQUENCE_NUM = 1
    where customer_trx_id in (select source_id from ar_document_transfers where status = 'WAITING') and
          PRINTING_PENDING <> 'N' and
          PRINTING_COUNT is null and
          PRINTING_LAST_PRINTED is null and
          PRINTING_ORIGINAL_DATE is null and
          LAST_PRINTED_SEQUENCE_NUM is null;

    retcode := 0;    -- SUCCESS
    if ar_doc_transfer_standard.isDebugOn then
      ar_doc_transfer_standard.debug('AR_EXTRACT_DOCUMENT.extract_documents(-)');
    end if;

  exception
    when no_data_found then
      if ar_doc_transfer_standard.isDebugOn then
        ar_doc_transfer_standard.debug('AR_EXTRACT_DOCUMENT.extract_documents(): NO Invoice Fetched');
      end if;

    when others then
      l_sqlerrm := sqlerrm(sqlcode) || fnd_global.newline ||
                   'Location: AR_EXTRACT_DOCUMENT.extract_documents()'||fnd_global.newline||
                   'Time: '||to_char(sysdate, 'DD-MON-RRRR HH:MI:SS');
      retcode := 2;
      fnd_message.set_name('AR','AR_DOC_EXT_SBJ');
      fnd_message.set_token('REQUEST_ID', fnd_global.conc_request_id);
      l_subject := fnd_message.get;
      if ar_doc_transfer_standard.isDebugOn then
        ar_doc_transfer_standard.debug('AR_EXTRACT_DOCUMENT.extract_documents()EXCEPTION:'||l_sqlerrm);
      end if;
      ar_notification_standard.notifyToSysadmin(l_subject,
                                                l_sqlerrm);
  end;
begin
  if ar_doc_transfer_standard.isDebugOn then ar_doc_transfer_standard.debug('AR_EXTRACT_DOCUMENT(+)'); end if;
  if ar_doc_transfer_standard.isDebugOn then ar_doc_transfer_standard.debug('AR_EXTRACT_DOCUMENT(-)'); end if;
end;

/
