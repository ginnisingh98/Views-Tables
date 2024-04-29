--------------------------------------------------------
--  DDL for Package Body AR_ECAPP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_ECAPP_PKG" AS
/*$Header: ARECAPPB.pls 120.2.12010000.3 2009/04/22 05:55:41 naneja noship $*/

PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

PROCEDURE UPDATE_STATUS(
			totalRows	IN NUMBER,
			txn_id_Tab	IN JTF_VARCHAR2_TABLE_100,
			req_type_Tab	IN JTF_VARCHAR2_TABLE_100,
			Status_Tab	IN JTF_NUMBER_TABLE,
			updatedt_Tab	IN JTF_DATE_TABLE,
			refcode_Tab	IN JTF_VARCHAR2_TABLE_100,
			o_status	OUT NOCOPY VARCHAR2,
			o_errcode	OUT NOCOPY VARCHAR2,
			o_errmsg	OUT NOCOPY VARCHAR2,
			o_statusindiv_Tab IN OUT NOCOPY JTF_VARCHAR2_TABLE_100
			) AS

cnt	number := 0;
extendRows  INTEGER:=1;
BEGIN

IF PG_DEBUG in ('Y', 'C') THEN
    fnd_file.put_line(FND_FILE.LOG,'AR_ECAPP_PKG.UPDATE_STATUS()+');
    fnd_file.put_line(FND_FILE.LOG, totalRows);
    arp_standard.debug ('Inserting record into ar_settlement_errors_gt table');
END IF;

   FORALL i in 1 .. totalRows
   insert into ar_settlement_errors_gt(
					txn_id,
					req_type,
					Status,
					updatedt,
					refcode)
				values(
					txn_id_tab(i),
					req_type_tab(i),
					Status_tab(i),
					updatedt_tab(i),
					refcode_tab(i)
					);

    IF PG_DEBUG in ('Y', 'C') THEN
	arp_standard.debug ('Number of rows inserted: ' ||sql%rowcount);
	arp_standard.debug ('Printing the IN parametr list from IBY');
    IF txn_id_tab.count > 0 THEN
    FOR i in 1 .. totalRows LOOP
	cnt := cnt + 1;
	arp_standard.debug ('txn_id_Tab(' || cnt || ')' || txn_id_Tab(i)) ;
	arp_standard.debug ('req_type_Tab(' || cnt || ')' || req_type_Tab(i)) ;
	arp_standard.debug ('Status_Tab(' || cnt || ')' || Status_Tab(i)) ;
	arp_standard.debug ('updatedt_Tab(' || cnt || ')' || updatedt_Tab(i)) ;
	arp_standard.debug ('refcode_Tab(' || cnt || ')' || refcode_Tab(i)) ;
    END LOOP;
    END IF;
	arp_standard.debug ('Calling correct_settlement_error routine');
    END IF;
    correct_settlement_error ;

    /***************************************************************
     * All these records are processed. Pass TRUE in the OUT table *
     * o_statusindiv_Tab to set the records so that they would not *
     * be passed again.                                            *
     ***************************************************************/
    o_statusindiv_Tab := JTF_VARCHAR2_TABLE_100();
    FOR i in 1 .. totalRows LOOP
        o_statusindiv_Tab.extend(extendRows);
	o_statusindiv_Tab(i) := 'TRUE';
    END LOOP;

IF PG_DEBUG in ('Y', 'C') THEN
    fnd_file.put_line(FND_FILE.LOG,'AR_ECAPP_PKG.UPDATE_STATUS()-');
END IF;

EXCEPTION
    WHEN OTHERS THEN
    fnd_file.put_line(FND_FILE.LOG,'AR_ECAPP_PKG.UPDATE_STATUS() - Exception');
    fnd_file.put_line(FND_FILE.LOG, sqlerrm);
END;



PROCEDURE correct_settlement_error AS

l_cash_receipt_id	AR_ECAPP_PKG.t_cash_receipt_id;
l_receipt_number	AR_ECAPP_PKG.t_receipt_number;
l_org_id		AR_ECAPP_PKG.t_org_id;
l_bepcode		AR_ECAPP_PKG.t_bepcode;
l_bepmessage		AR_ECAPP_PKG.t_bepmessage;
l_instrtype		AR_ECAPP_PKG.t_instrtype;

l_request_id		AR_ECAPP_PKG.t_request_id;
l_cc_org_id		AR_ECAPP_PKG.t_org_id;

l_receipt_info		AR_RECEIPT_API_PUB.CR_ID_TABLE;
l_empty_receipt_info    AR_RECEIPT_API_PUB.CR_ID_TABLE;
l_called_from		varchar2(30);
l_return_status		varchar2(10);
l_msg_count		number;
l_msg_data		varchar2(2000);

l_error_buf		varchar2(240);
l_ret_code		varchar2(240);


j		number;
k		number;
l_call_api	varchar2(1);
l_last_record	varchar2(1);
l_org_return_status VARCHAR2(1);


CURSOR C1 IS
SELECT	cr.cash_receipt_id, cr.receipt_number, cr.org_id,
	summ.bepcode, summ.bepmessage, summ.instrtype
FROM	ar_cash_receipts_all cr, ar_cash_receipt_history_all crh ,
	ar_settlement_errors_gt gt, iby_trxn_summaries_all summ,
	iby_fndcpt_tx_operations op
WHERE gt.Status in (1, 5, 10)
AND summ.status in (1, 5, 10)
AND gt.req_type in ('ORAPMTCAPTURE', 'ORAPMTRETURN', 'ORAPMTCREDIT', 'ORAPMTVOID')
AND summ.transactionid = gt.txn_id
AND summ.reqtype = gt.req_type
AND op.transactionid = summ.transactionid
and cr.payment_trxn_extension_id = op.trxn_extension_id
and cr.cash_receipt_id = crh.cash_receipt_id
and cr.org_id	=  crh.org_id
and crh.status = 'REMITTED'
and crh.current_record_flag = 'Y'
AND NOT EXISTS
   (SELECT 1
    FROM ar_settlement_errors_gt gt_in
    WHERE gt_in.txn_id = gt.txn_id
    AND gt_in.status = 0)
AND summ.rowid IN
     (SELECT max(rowid)
      FROM iby_trxn_summaries_all summ_in
      WHERE summ.transactionid = summ_in.transactionid
      AND summ_in.status in (1, 5, 10))
ORDER by cr.org_id, cr.cash_receipt_id;



BEGIN

   IF PG_DEBUG in ('Y', 'C') THEN
       fnd_file.put_line(FND_FILE.LOG,'AR_ECAPP_PKG.correct_settlement_error()+');
   END IF;

   l_called_from	:= 'SUBMIT_OFFLINE';

   IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug('Open Cursor C1');
   END IF;

   OPEN C1;
   FETCH C1 BULK COLLECT INTO
	l_cash_receipt_id,
	l_receipt_number,
	l_org_id,
	l_bepcode,
	l_bepmessage,
	l_instrtype;
   CLOSE C1;

   IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug('Close Cursor C1');
   END IF;

   fnd_file.put_line(FND_FILE.LOG,'Receipts being processed' || '     ' || 'Operating Unit');
   fnd_file.put_line(FND_FILE.LOG, '------------------------'|| '     ' || '--------------');

   k := l_org_id.count;
   j := 0;
   l_call_api := 'N';
   IF l_org_id.count > 0 THEN
   FOR i in l_org_id.first..l_org_id.last
   LOOP
	l_last_record := 'N';

	IF i = k THEN
	   l_Last_record := 'Y';
	   l_call_api := 'Y';
	END IF;

	IF l_last_record <> 'Y' THEN
           IF l_org_id(i) <> l_org_id(i+1) THEN
		l_call_api := 'Y';
           END IF;
        END IF;

	fnd_file.put_line(FND_FILE.LOG,rpad(substr(l_receipt_number(i),1,24),24, ' ' ) || '     ' || l_org_id(i));
	j := j+1;
	l_receipt_info.cash_receipt_id(j)   :=  l_cash_receipt_id(i);
	l_receipt_info.cc_error_code(j)	    :=  l_bepcode(i);
	l_receipt_info.cc_error_text(j)	    :=  l_bepmessage(i);
	l_receipt_info.cc_instrtype(j)	    :=  l_instrtype(i);

	IF l_call_api = 'Y'
	THEN

	    IF PG_DEBUG in ('Y', 'C')
	    THEN
		arp_standard.debug('Setting Org Context for Org_Id: '||l_org_id(i));
	    END IF;

	    /*mo_global.set_policy_context('S', l_org_id(i));*/
            ar_mo_cache_utils.set_org_context_in_api(p_org_id =>l_org_id(i),
                                             p_return_status =>l_org_return_status);
	    IF l_org_return_status <> FND_API.G_RET_STS_SUCCESS THEN
               fnd_file.put_line(FND_FILE.LOG,'l_org_return_status '|| l_org_return_status);
	       fnd_file.put_line(FND_FILE.LOG,'Org not getting processed '|| l_org_id(i));
	    ELSE

	      BEGIN
	        IF PG_DEBUG in ('Y', 'C')
		THEN
		    fnd_file.put_line(FND_FILE.LOG,'Calling API Reverse_Remittances_in_err');
		END IF;

		    AR_RECEIPT_API_PUB.Reverse_Remittances_in_err (
					p_api_version      => 1.0,
					p_cash_receipts_id => l_receipt_info,
					p_called_from      => l_called_from,
					p_commit           => FND_API.G_TRUE,
					x_return_status    => l_return_status,
					x_msg_count        => l_msg_count,
					x_msg_data         => l_msg_data
					);

		    IF l_return_status <> FND_API.G_RET_STS_SUCCESS
		    THEN
			-- Dump the error message in log for only those errored receipts.
			fnd_file.put_line(FND_FILE.LOG,'l_return_status '|| l_return_status);
			fnd_file.put_line(FND_FILE.LOG,'l_msg_count '|| l_msg_count);
			fnd_file.put_line(FND_FILE.LOG,'l_msg_data '|| l_msg_data);
			APP_EXCEPTION.RAISE_EXCEPTION;
		    END IF;

	      EXCEPTION
		WHEN OTHERS THEN
	        -- Dump the error message in log for only those errored receipts.
	    	fnd_file.put_line(FND_FILE.LOG,'l_return_status '|| l_return_status);
		fnd_file.put_line(FND_FILE.LOG,'l_msg_count '|| l_msg_count);
		fnd_file.put_line(FND_FILE.LOG,'l_msg_data '|| l_msg_data);
		fnd_file.put_line(FND_FILE.LOG,'Sqlerrm '|| sqlerrm);
		RAISE;
	      END;

	    END IF;
	    j := 0;
	    l_call_api := 'N';
	    l_receipt_info.cash_receipt_id := l_empty_receipt_info.cash_receipt_id;
	    l_receipt_info.cc_error_code := l_empty_receipt_info.cc_error_code;
	    l_receipt_info.cc_error_text := l_empty_receipt_info.cc_error_text;
	    l_receipt_info.cc_instrtype := l_empty_receipt_info.cc_instrtype;
        END IF;
   END LOOP;
   ELSE
      fnd_file.put_line(FND_FILE.LOG,'No receipts in Error for reverting remittance');
      RETURN;
   END IF;

/* Now call ARP_CORRECT_CC_ERRORS code to correct predefined errors */
/* This routine takes Request_Id as a parameter. Here request ID need to be gathered.*/

   BEGIN

	IF PG_DEBUG in ('Y', 'C') THEN
	    fnd_file.put_line(FND_FILE.LOG,'Call ARP_CORRECT_CC_ERRORS.cc_auto_correct_cover()+');
	END IF;


	SELECT DISTINCT cr.request_id , cr.org_id
	BULK   COLLECT INTO   l_request_id, l_cc_org_id
	FROM   ar_cash_receipts_all cr,
	       ar_cash_receipt_history_all crh
	WHERE  cr.cash_receipt_id = crh.cash_receipt_id
	AND    cr.org_id	  =  crh.org_id
	AND    cr.cc_error_flag   = 'Y'
	AND    crh.status	  = 'CONFIRMED'
	AND    crh.current_record_flag = 'Y'
	AND    crh.request_id     = fnd_global.conc_request_id;

        IF l_request_id.count > 0 THEN
	FOR i in l_request_id.first .. l_request_id.last LOOP
	Begin

	    IF PG_DEBUG in ('Y', 'C') THEN
		arp_standard.debug('Setting org context before calling CC Auto Correct');
		arp_standard.debug('Org ID: ' || l_cc_org_id(i));
		arp_standard.debug('Request ID: ' || l_request_id(i));
	    END IF;

		mo_global.set_policy_context('S', l_cc_org_id(i));

		ARP_CORRECT_CC_ERRORS.cc_auto_correct(
					errbuf		=>  l_error_buf,
					retcode		=>  l_ret_code,
					p_request_id	=>  l_request_id(i),
					p_mode		=>  'REMITTANCE' );
		IF l_ret_code <> 0 THEN
			fnd_file.put_line(FND_FILE.LOG,l_error_buf);
			APP_EXCEPTION.RAISE_EXCEPTION;
		END IF;

	EXCEPTION
	    WHEN OTHERS THEN
		fnd_file.put_line(FND_FILE.LOG,'Exception inner ARP_CORRECT_CC_ERRORS.cc_auto_correct ' || sqlerrm);
		RAISE;
	END;
	END LOOP;
        END IF;

	IF PG_DEBUG in ('Y', 'C') THEN
	    fnd_file.put_line(FND_FILE.LOG,'Call ARP_CORRECT_CC_ERRORS.cc_auto_correct_cover()-');
	END IF;

   EXCEPTION
       WHEN NO_DATA_FOUND THEN
	fnd_file.put_line(FND_FILE.LOG,'No receipt fetched for Credit Card Error Correction');

       WHEN OTHERS THEN
	fnd_file.put_line(FND_FILE.LOG,'Exception outer ARP_CORRECT_CC_ERRORS.cc_auto_correct ' || sqlerrm);
	RAISE;
   END;
   /* ARP_CORRECT_CC_ERRORS code ends here */


   IF PG_DEBUG in ('Y', 'C') THEN
	fnd_file.put_line(FND_FILE.LOG,'AR_ECAPP_PKG.correct_settlement_error()-');
   END IF;


EXCEPTION
   WHEN OTHERS THEN
	fnd_file.put_line(FND_FILE.LOG,'Exception AR_ECAPP_PKG.correct_settlement_error ' || sqlerrm);
	RAISE;
END;



END AR_ECAPP_PKG;

/
