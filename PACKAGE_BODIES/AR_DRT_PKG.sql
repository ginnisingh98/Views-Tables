--------------------------------------------------------
--  DDL for Package Body AR_DRT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_DRT_PKG" AS
/* $Header: ARDRTPKB.pls 120.0.12010000.9 2018/09/03 09:49:36 sunagesh noship $ */

PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'Y');

  l_package varchar2(33) DEFAULT 'AR_DRT_PKG. ';


/*=======================================================================+
 |  PROCEDURE write_log
 |  Implement log writer
 +=======================================================================*/

  PROCEDURE write_log
    (message       IN         varchar2
	,stage		 IN					varchar2) IS
  BEGIN

				if fnd_log.g_current_runtime_level<=fnd_log.level_procedure then
					fnd_log.string(fnd_log.level_procedure,message,stage);
				end if;
  END write_log;

/*=======================================================================+
 |  PROCEDURE add_to_results
 |  Implement helper procedure add record corresponding to an
 |  error/warning/error
 +=======================================================================*/

/*  PROCEDURE add_to_results
    (  person_id     IN     number
	    ,entity_type	 IN			varchar2
	    ,status 		   IN			varchar2
     	,msgcode		   IN			varchar2
	    ,msgaplid		   IN			number
     ,result_tbl     IN OUT NOCOPY result_tbl_type) IS

	n number(15);

  BEGIN

	   n := result_tbl.count + 1;
    result_tbl(n).person_id := person_id;
    result_tbl(n).entity_type := entity_type;
    result_tbl(n).status := status;
    result_tbl(n).msgcode := msgcode;
    FND_MESSAGE.SET_NAME ('AR',msgcode);
    result_tbl(n).msgtext := FND_MESSAGE.GET;

  end add_to_results;

*/

/*=======================================================================+
 |  PROCEDURE ar_tca_drc
 |  Implement Core HR specific DRC for TCA entity type
 +=======================================================================*/

  PROCEDURE ar_tca_drc
		(person_id       IN         number
		,result_tbl    OUT NOCOPY per_drt_pkg.result_tbl_type) IS

  l_proc varchar2(72);
  p_party_id varchar2(20);
  n number;
  l_temp varchar2(20);
  l_count number;

  l_credit_app_exists varchar2(1) := 'N';
  l_case_folders_exists varchar2(1) := 'N';
  l_open_credit_memos varchar2(1) := 'N';
  l_open_transactions varchar2(1) := 'N';
  l_pend_ai_transactions varchar2(1) := 'N';
  l_unclear_receipts varchar2(1) := 'N';
  l_pending_lockbox_trx varchar2(1) := 'N';
  l_pending_quickcash_trx varchar2(1) := 'N';
  l_unapp_receipts varchar2(1) := 'N';
  l_open_bill_receivables varchar2(1) := 'N';

  -- Bug No. 27954783
  l_location_id  hz_party_sites.location_id%TYPE;

  CURSOR location_trx(p_party_id NUMBER) IS
  SELECT LOCATION_ID
  FROM HZ_PARTY_SITES
  WHERE (PARTY_ID IN
  ( SELECT p_party_id FROM dual
  UNION
  SELECT PARTY_ID
  FROM HZ_RELATIONSHIPS
  WHERE SUBJECT_ID       = p_party_id
  AND SUBJECT_TABLE_NAME = 'HZ_PARTIES'
  AND SUBJECT_TYPE       = 'PERSON'
  ));
  --modified cursor query for bug 28588759
  /*SELECT location_id
    FROM hz_party_sites
   WHERE party_id = p_party_id
     OR (party_id  IN
              (SELECT party_id
                 FROM hz_relationships
                WHERE subject_id         = p_party_id
                  AND subject_table_name = 'HZ_PARTIES'
                  AND subject_type       = 'PERSON'
              ));*/

BEGIN
  IF PG_DEBUG in ('Y', 'C') THEN
    arp_standard.debug(  'ar_tca_drc()+');
  END IF;

  p_party_id := person_id;

/*
  n := process_code.count + 1;

  process_code (n).person_id := p_party_id;

  process_code (n).entity_type := 'AR';

  process_code (n).status := 'S';

  process_code (n).msgcode := 'AR_FIN_CREDIT_APP_EXISTS';

  process_code (n).msgtext := 'There are pending credit requests related to the party.';
*/
/* To be used for OCM
  l_count :=0;


  BEGIN

    SELECT  count(*) into l_count
    FROM    ar_cmgt_credit_requests cr
    WHERE   cr.party_id = p_party_id
    AND status in ('SAVE', 'SUBMIT', 'IN_PROCESS')
    AND ROWNUM = 1;

    IF (l_count <> 0) THEN

      IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug(  'ar_fin_drc()-> Failure in credit requests');
      END IF;

  			ar_drt_pkg.add_to_results
  			  (person_id => person_id
              ,entity_type => 'TCA'
  			  ,status => 'E'
  			  ,msgcode => 'AR_FIN_CREDIT_APP_EXISTS'
  			  ,msgaplid => 222
  			  ,result_tbl => result_tbl);


    END IF;

  END;
*/
/* To be used for OCM
  l_count :=0;

  BEGIN
    SELECT  count(*)
    INTO    l_count
    FROM    ar_cmgt_case_folders cr
    WHERE   cr.party_id = p_party_id
    AND status in ('REFRESH', 'CREATED', 'SAVED')
    AND ROWNUM = 1;

    IF (l_count <> 0 ) THEN


      IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug(  'ar_fin_drc()-> Failure in case folders');
      END IF;

  			ar_drt_pkg.add_to_results
  			  (person_id => person_id
    			  ,entity_type => 'TCA'
  			  ,status => 'E'
  			  ,msgcode => 'AR_FIN_CASE_FOLDER_EXISTS'
  			  ,msgaplid => 222
  			  ,result_tbl => result_tbl);

    END IF;


  END;
*/



  l_count :=0;

  BEGIN
    SELECT  count(*)
    INTO    l_count
    FROM    ra_cm_requests_all cr,
            ra_customer_trx_all trx
    WHERE   cr.customer_trx_id = trx.customer_trx_id
    AND     cr.status not in ('COMPLETE','CANCELLED','NOT_APPROVED')
    AND     trx.bill_to_customer_id in (select cust_account_id
                                        from hz_cust_accounts
                                        where party_id = p_party_id
                                        )
    AND ROWNUM = 1;

    IF (l_count <> 0 ) THEN


      IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug(  'ar_fin_drc()-> Failure in credit memos');
      END IF;
  			per_drt_pkg.add_to_results
  			  (person_id => person_id
    			  ,entity_type => 'TCA'
  			  ,status => 'E'
  			  ,msgcode => 'AR_OPEN_CREDIT_MEMOS'
  			  ,msgaplid => 222
  			  ,result_tbl => result_tbl);


    END IF;


  END;


  l_count := 0;

  BEGIN
    SELECT  count(*)
    INTO    l_count
    FROM    ar_payment_schedules_all ps,
            ra_customer_trx_all trx,
            ra_cust_trx_types_all ttyp
    WHERE   trx.customer_trx_id = ps.customer_trx_id
    AND     trx.bill_to_customer_id = ps.customer_id
    AND     trx.cust_trx_type_id = ttyp.cust_trx_type_id
    AND     ttyp.type in ('INV', 'DM', 'CM')
    AND     trx.bill_to_customer_id in (select cust_account_id
                                        from hz_cust_accounts
                                        where party_id = p_party_id
                                        )
    AND ps.status = 'OP'
    AND ROWNUM = 1;

    IF (l_count <> 0 ) THEN


      IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug(  'ar_fin_drc()-> Failure in open transactions');
      END IF;

  			per_drt_pkg.add_to_results
  			  (person_id => person_id
    			  ,entity_type => 'TCA'
  			  ,status => 'E'
  			  ,msgcode => 'AR_OPEN_TRANSACTIONS'
  			  ,msgaplid => 222
  			  ,result_tbl => result_tbl);


    END IF;


  END;


  l_count := 0;
  BEGIN
    SELECT  count(*)
    INTO    l_count
    FROM    ra_interface_lines_all inf
    WHERE   inf.orig_system_bill_customer_id in (select cust_account_id
                                                 from hz_cust_accounts
                                                 where party_id = p_party_id
                                                 )
    AND NVL(interface_status, '~') <> 'P'
    AND ROWNUM = 1;

    IF (l_count <> 0 ) THEN


      IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug(  'ar_fin_drc()-> Failure in pending Autoinvoice interface transactions');
      END IF;

  			per_drt_pkg.add_to_results
  			  (person_id => person_id
    			  ,entity_type => 'TCA'
  			  ,status => 'E'
  			  ,msgcode => 'AR_PEND_AI_TRX'
  			  ,msgaplid => 222
  			  ,result_tbl => result_tbl);


    END IF;


  END;


  l_count := 0;
  BEGIN
    SELECT  count(*)
    INTO    l_count
    FROM    ar_cash_receipts_all cr,
            ar_cash_receipt_history_all crh
    WHERE   cr.pay_from_customer in (select cust_account_id
                                     from hz_cust_accounts
                                     where party_id = p_party_id
                                     )
    AND crh.cash_receipt_id = cr.cash_receipt_id
    AND crh.current_record_flag = 'Y'
    AND crh.status not in ('CLEARED', 'REVERSED')
    AND ROWNUM = 1;

    IF (l_count <> 0) THEN


      IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug(  'ar_fin_drc()-> Failure in unclear receipts for the party.');
      END IF;

  			per_drt_pkg.add_to_results
  			  (person_id => person_id
    			  ,entity_type => 'TCA'
  			  ,status => 'E'
  			  ,msgcode => 'AR_UNCLEAR_RECEIPTS'
  			  ,msgaplid => 222
  			  ,result_tbl => result_tbl);


    END IF;


  END;


  l_count := 0;

  BEGIN
    SELECT  count(*)
    INTO    l_count
    FROM    ar_interim_cash_receipts_all icr
    WHERE   icr.pay_from_customer in (select cust_account_id
                                      from hz_cust_accounts
                                      where party_id = p_party_id
                                      )
   -- AND icr.status <> 'UNAPP'  -- Commented for Bug 27993188
    AND ROWNUM = 1;

    IF (l_count <> 0) THEN

      IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug(  'ar_fin_drc()-> Failure in pending lockbox transactions for the party.');
      END IF;

  			per_drt_pkg.add_to_results
  			  (person_id => person_id
    			  ,entity_type => 'TCA'
  			  ,status => 'E'
  			  ,msgcode => 'AR_PENDING_LOCKBOX_TRX'
  			  ,msgaplid => 222
  			  ,result_tbl => result_tbl);


    END IF;

  END;


  l_count := 0;
  BEGIN
    SELECT  count(*)
    INTO    l_count
    FROM    ar_payments_interface_all pi
    WHERE   pi.customer_id in (select cust_account_id
                               from hz_cust_accounts
                               where party_id = p_party_id
                               )
    AND ROWNUM = 1;

    IF (l_count <> 0) THEN


      IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug(  'ar_fin_drc()-> Failure in pending quick cash transactions for the party.');
      END IF;

        per_drt_pkg.add_to_results
  			  (person_id => person_id
    			  ,entity_type => 'TCA'
  			  ,status => 'E'
  			  ,msgcode => 'AR_PENDING_QUICKCASH_TRX'
  			  ,msgaplid => 222
  			  ,result_tbl => result_tbl);


    END IF;


  END;


  l_count := 0;
  BEGIN
    SELECT  count(*)
    INTO    l_count
    FROM    ar_payment_schedules_all ps,
            ar_cash_receipts_all cr,
            ar_cash_receipt_history_all crh
    WHERE   cr.pay_from_customer in (select cust_account_id
                                     from hz_cust_accounts
                                     where party_id = p_party_id
                                     )
    AND     crh.cash_receipt_id = cr.cash_receipt_id
    AND     ps.cash_receipt_id = cr.cash_receipt_id
    AND     ps.status = 'OP'
    AND     ps.amount_due_remaining <> 0
    AND ROWNUM = 1;

    IF (l_count <> 0) THEN


      IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug(  'ar_fin_drc()-> Failure in unapplied receipts for the party..');
      END IF;
  			per_drt_pkg.add_to_results
  			  (person_id => person_id
    			  ,entity_type => 'TCA'
  			  ,status => 'E'
  			  ,msgcode => 'AR_UNAPP_RECEIPTS'
  			  ,msgaplid => 222
  			  ,result_tbl => result_tbl);


    END IF;

  END;



  l_count := 0;

  BEGIN

    SELECT  count(*)
    INTO    l_count
    FROM    ar_payment_schedules_all ps,
            ra_customer_trx_all trx,
            ra_cust_trx_types_all ttyp
    WHERE   trx.customer_trx_id = ps.customer_trx_id
    AND     trx.cust_trx_type_id = ttyp.cust_trx_type_id
    AND     ttyp.type = 'BR'
    AND     ps.customer_id in (select cust_account_id
                                        from hz_cust_accounts
                                        where party_id = p_party_id
                                        )
    AND ps.status = 'OP'
    AND ROWNUM = 1;

    IF (l_count <> 0) THEN


      IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug(  'ar_fin_drc()-> Failure in open bill receivables for the party.');
      END IF;

  			per_drt_pkg.add_to_results
  			  (person_id => person_id
    			  ,entity_type => 'TCA'
  			  ,status => 'E'
  			  ,msgcode => 'AR_OPEN_BILL_RECEIVABLES'
  			  ,msgaplid => 222
  			  ,result_tbl => result_tbl);

    END IF;


  END;

  -- Start Bug No.  27954783
  BEGIN
    OPEN location_trx(p_party_id);
    LOOP
      FETCH  location_trx INTO l_location_id;
    EXIT WHEN location_trx%NOTFOUND;

      IF ARH_ADDR_PKG.check_tran_for_all_accts(l_location_id) THEN
         per_drt_pkg.add_to_results
      			  (person_id => person_id
        			,entity_type => 'TCA'
      			  ,status => 'E'
      			  ,msgcode => 'AR_CUST_ADDR_HAS_TRANSACTION'
      			  ,msgaplid => 222
      			  ,result_tbl => result_tbl);
      EXIT;
      END IF;

    END LOOP;
    CLOSE location_trx;
  END;
  -- End Bug No.  27954783


END ar_tca_drc;

/*=======================================================================+
 |  PROCEDURE ar_hr_drc
 |  Implement Core HR specific DRC for HR entity type
 +=======================================================================*/

  PROCEDURE ar_hr_drc
    (person_id       IN         number
    ,result_tbl    OUT NOCOPY per_drt_pkg.result_tbl_type) IS

  l_proc varchar2(72) := l_package|| 'ar_hr_drc';
  BEGIN
    write_log ('Entering:'|| l_proc,'10');

    /* Skeleton Alone no action item as per Project */

    write_log ('Leaving:'|| l_proc,'10');
  END  ar_hr_drc;



/*=======================================================================+
 |  PROCEDURE ar_fnd_drc
 |  Implement Core HR specific DRC for FND entity type
 +=======================================================================*/

  PROCEDURE ar_fnd_drc
    (person_id       IN         number
    ,result_tbl    OUT NOCOPY per_drt_pkg.result_tbl_type) IS

  l_proc varchar2(72) := l_package|| 'ar_fnd_drc';
  BEGIN
    write_log ('Entering:'|| l_proc,'10');

    /* Skeleton Alone no action item as per Project */

    write_log ('Leaving:'|| l_proc,'10');
  END  ar_fnd_drc;


END ar_drt_pkg;

/
