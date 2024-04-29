--------------------------------------------------------
--  DDL for Package Body AR_CAO_ASSIGN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_CAO_ASSIGN_PKG" AS
/* $Header: ARCAOAB.pls 120.0.12010000.7 2010/03/02 06:46:27 rviriyal noship $*/

PROCEDURE write_debug_and_log(p_message IN VARCHAR2) IS

BEGIN

  IF FND_GLOBAL.CONC_REQUEST_ID is not null THEN

    fnd_file.put_line(FND_FILE.LOG,p_message);

  END IF;

  arp_standard.debug(p_message);

EXCEPTION
WHEN others THEN
    NULL;
END;

PROCEDURE spawn_child_requests(p_operating_unit              IN NUMBER,
                         p_receipt_date_from   IN VARCHAR2,
                         p_receipt_date_to     IN VARCHAR2,
                         p_cust_prof_class     IN NUMBER,
                         p_max_num_workers     IN NUMBER) IS

l_reqid          NUMBER;

BEGIN

FOR i in 1..(p_max_num_workers-1) LOOP

    l_reqid := FND_REQUEST.SUBMIT_REQUEST('AR',
                                         'ARCAOAB',
                                         'Assign Cash Application Work Items',
                                         sysdate,
                                         FALSE,
                                         p_operating_unit,
                                         p_receipt_date_from,
                                         p_receipt_date_to,
                                         p_cust_prof_class,
                                         p_max_num_workers,
                                         i);
   write_debug_and_log('Request ID' || l_reqid);

END LOOP;

END spawn_child_requests;

/*
This function is used to check if a given user has access to the Cash Application Worker Queue Page.
user_id  User id to which the check is done.
valid_flag  Can have values Y or N.
            Y - Check if the user currently has access to the function AR_CASH_APPLN_WORK_QUEUE
                This validity check is done only if the Grant flag of the function directly is unchecked or
                the function directly is present in the exclusion list of the user responsibilities.
            N - Check if the user is associate to that function
*/

FUNCTION check_access(user_id IN NUMBER,   valid_flag IN VARCHAR2) RETURN NUMBER IS

 CURSOR valid_resp(user_id_bind NUMBER, curr_date DATE) IS
SELECT frv.responsibility_id
FROM fnd_responsibility frv,
  fnd_compiled_menu_functions fcmf,
  fnd_form_functions fff,
  fnd_user_resp_groups_direct urg
WHERE fff.function_name = 'AR_CASH_APPLN_WORK_QUEUE'
 AND fcmf.function_id = fff.function_id
 AND frv.menu_id = fcmf.menu_id
 AND fcmf.grant_flag = 'Y'
 AND fff.function_id NOT IN
  (SELECT frf.action_id
   FROM fnd_resp_functions frf
   WHERE frf.action_id = fff.function_id
   AND frf.rule_type = 'F'
   AND frf.application_id = 222
   AND frf.responsibility_id = frv.responsibility_id)
AND curr_date BETWEEN nvl(urg.start_date,   curr_date)
 AND nvl(urg.end_date,   curr_date)
 AND urg.user_id = user_id_bind
 AND urg.responsibility_id = frv.responsibility_id
 AND frv.application_id = 222;

CURSOR all_resp(user_id_bind NUMBER) IS
SELECT frv.responsibility_id
FROM fnd_responsibility frv,
  fnd_compiled_menu_functions fcmf,
  fnd_form_functions fff,
  fnd_user_resp_groups_direct urg
WHERE fff.function_name = 'AR_CASH_APPLN_WORK_QUEUE'
 AND fcmf.function_id = fff.function_id
 AND frv.menu_id = fcmf.menu_id
 AND urg.user_id = user_id_bind
 AND urg.responsibility_id = frv.responsibility_id
 AND frv.application_id = 222;


curr_date date;

valid_resp_list valid_resp % rowtype;
all_resp_list all_resp % rowtype;



BEGIN

  IF valid_flag = 'Y' THEN

    curr_date := TRUNC(sysdate);

    OPEN valid_resp(user_id, curr_date);
    FETCH valid_resp
    INTO valid_resp_list;

    IF valid_resp % FOUND THEN
      CLOSE valid_resp;
      RETURN 1;
    ELSE
      CLOSE valid_resp;
      RETURN 0;
    END IF;

  ELSE

    OPEN all_resp(user_id);
    FETCH all_resp
    INTO all_resp_list;

    IF all_resp % FOUND THEN
      CLOSE all_resp;
      RETURN 1;
    ELSE
      CLOSE all_resp;
      RETURN 0;
    END IF;

  END IF;

  EXCEPTION

    WHEN OTHERS THEN
      RETURN 0;

END;


PROCEDURE assign_work_items( errbuf                OUT NOCOPY VARCHAR2,
                             retcode               OUT NOCOPY NUMBER,
                             p_operating_unit              IN NUMBER,
                             p_receipt_date_from   IN VARCHAR2,
                             p_receipt_date_to     IN VARCHAR2,
                             p_cust_prof_class     IN NUMBER,
                             p_max_num_workers     IN NUMBER,
                             p_worker_no           IN NUMBER) IS

TYPE c_receipts  IS REF CURSOR ;
C_receipts_cur c_receipts;
C_receipt_stmt VARCHAR2(5000);


l_max_num_workers NUMBER;
l_worker_no NUMBER;

TYPE L_receipts_type IS RECORD
    (cash_receipt_id    NUMBER(15),
      cust_account_id        NUMBER(15),
      site_use_id         NUMBER(15),
      profile_class_id  NUMBER(15),
      country     hz_locations.country%TYPE,
      org_id          NUMBER(15),
      currency_code  ar_cash_receipts_all.currency_code%TYPE,
      unidentified_amount NUMBER,
      unapplied_amount  NUMBER,
      ATTRIBUTE1 VARCHAR2(50),
      ATTRIBUTE2 VARCHAR2(50),
      ATTRIBUTE3 VARCHAR2(50),
      ATTRIBUTE4 VARCHAR2(50),
      ATTRIBUTE5 VARCHAR2(50),
      ATTRIBUTE6 VARCHAR2(50),
      ATTRIBUTE7 VARCHAR2(50),
      ATTRIBUTE8 VARCHAR2(50),
      ATTRIBUTE9 VARCHAR2(50),
      ATTRIBUTE10 VARCHAR2(50));

TYPE ReceiptsTabTyp IS TABLE OF L_receipts_type
INDEX BY BINARY_INTEGER;

receipts_tab ReceiptsTabTyp;

TYPE L_results_type IS RECORD
      (cash_receipt_id     DBMS_SQL.NUMBER_TABLE,
      cash_appln_owner_id  DBMS_SQL.NUMBER_TABLE);

results_tab L_results_type;

BEGIN

    write_debug_and_log('ar_cao_assign_pkg.assign_work_items (+)');

    mo_global.init('AR');
    write_debug_and_log('Operating Unit : '|| p_operating_unit);
    write_debug_and_log('Receipt Date From : '|| p_receipt_date_from);
    write_debug_and_log('Receipt Date To : '|| p_receipt_date_to);
    write_debug_and_log('Customer Profile Class : '|| p_cust_prof_class);
    write_debug_and_log('Max Workers : '|| p_max_num_workers);
    write_debug_and_log('Worker Number : '|| p_worker_no);


    IF p_max_num_workers is null THEN
      l_max_num_workers := 1;
    ELSE
      l_max_num_workers := p_max_num_workers;
    END IF;

    IF p_worker_no is null THEN
      l_worker_no := 0;
    ELSE
      l_worker_no := p_worker_no;
    END IF;

    IF l_worker_no = 0 THEN
      spawn_child_requests(p_operating_unit,
                           p_receipt_date_from,
                           p_receipt_date_to,
                           p_cust_prof_class,
                           l_max_num_workers);
    END IF;


    C_receipt_stmt := 'SELECT acr.cash_receipt_id, ' ||
                          'hca.cust_account_id, ' ||
                          'hcsu.site_use_id, '||
                          'nvl(hcp1.profile_class_id,   hcp.profile_class_id) profile_class_id, '||
                          'hl.country, '||
                          'acr.org_id, '||
                          'acr.currency_code, '||
                          'decode(acr.status,   ''UNID'',   ABS(aps.amount_due_remaining),   0) unidentified_amount, '||
                          'decode(acr.status,   ''UNAPP'',   ABS(aps.amount_due_remaining),   0) unapplied_amount, '||
                          'null,null,null,null,null,null,null,null,null,null ' ||
                          'FROM ar_cash_receipts acr, '||
                          'hz_cust_accounts hca, '||
                          'hz_cust_site_uses hcsu, '||
                          'hz_locations hl, '||
                          'hz_party_sites hps, '||
                          'hz_cust_acct_sites hcas, '||
                          'ar_payment_schedules aps, '||
                          'hz_customer_profiles hcp, '||
                          'hz_customer_profiles hcp1 '||
                          'WHERE acr.pay_from_customer = hca.cust_account_id(+) '||
                          'AND acr.customer_site_use_id = hcsu.site_use_id(+) '||
                          'AND hcsu.cust_acct_site_id = hcas.cust_acct_site_id(+) '||
                          'AND hcas.party_site_id = hps.party_site_id(+) '||
                          'AND hps.location_id = hl.location_id(+) '||
                          'AND acr.cash_receipt_id = aps.cash_receipt_id '||
                          'AND acr.type = ''CASH'' '||
                          'AND acr.cash_appln_owner_id IS NULL '||
                          'AND acr.status IN(''UNAPP'',   ''UNID'') '||
                          'AND hca.cust_account_id = hcp.cust_account_id(+) '||
                          'AND hcp.site_use_id IS NULL '||
                          'AND hcsu.site_use_id = hcp1.site_use_id(+) '||
                          'and mod(acr.cash_receipt_id,'|| l_max_num_workers ||
                          ') = decode( ' ||l_max_num_workers ||
                          ', 0, acr.cash_receipt_id, mod(' || l_worker_no|| ','|| l_max_num_workers || '))';

      IF p_operating_unit is not null THEN
          C_receipt_stmt := C_receipt_stmt || ' AND acr.org_id = ' || p_operating_unit;
      END IF;
      IF p_receipt_date_from is not null THEN
           C_receipt_stmt := C_receipt_stmt || ' AND acr.receipt_date >= trunc(to_date(''' || p_receipt_date_from || ''', ''YYYY/MM/DD HH24:MI:SS''))';
      END IF;
      IF p_receipt_date_to is not null THEN
           C_receipt_stmt := C_receipt_stmt || ' AND acr.receipt_date <= trunc(to_date(''' || p_receipt_date_to || ''', ''YYYY/MM/DD HH24:MI:SS''))';
      END IF;
      IF p_cust_prof_class is not null THEN
           C_receipt_stmt := C_receipt_stmt || ' AND (hcp1.profile_class_id = ' || p_cust_prof_class || ' OR hcp.profile_class_id =' || p_cust_prof_class || ')';
      END IF;

      write_debug_and_log(' Query :' || C_receipt_stmt);

      OPEN C_receipts_cur for C_receipt_stmt;

      FETCH C_receipts_cur BULK COLLECT INTO receipts_tab;

      CLOSE C_receipts_cur;

      write_debug_and_log('Number of records: '|| receipts_tab.count);

      delete from AR_CASH_RECPT_RULE_PARAM_GT;

      FORALL i in receipts_tab.first..receipts_tab.last
        INSERT INTO AR_CASH_RECPT_RULE_PARAM_GT values receipts_tab(i);

      AR_CUSTOM_PARAMS_HOOK_PKG.populateCAOwnerAttributes();
      write_debug_and_log('Invoking Rule Engine');


      /* Invoke Rule Engine */
      FUN_RULE_PUB.apply_rule_bulk('AR',
                                    'CASH_APPLICATION_OWNER_ASSIGN',
                                    'AR_CASH_RECPT_RULE_PARAM_GT',
                                    null,
                                    'cash_receipt_id');

      write_debug_and_log('Returned from Rule Engine');

      SELECT ID, RESULT_VALUE BULK COLLECT INTO results_tab from FUN_RULE_BULK_RESULT_GT;

      /* Update the AR_Cash_Receipts table with the result values */

      FORALL i in results_tab.cash_receipt_id.first..results_tab.cash_receipt_id.last
        UPDATE ar_cash_receipts_all
        set CASH_APPLN_OWNER_ID = results_tab.cash_appln_owner_id(i),
        WORK_ITEM_ASSIGNMENT_DATE = sysdate,
        WORK_ITEM_STATUS_CODE = 'NEW'
        where CASH_RECEIPT_ID = results_tab.cash_receipt_id(i)
	and results_tab.cash_appln_owner_id(i) is not null;

      write_debug_and_log('Receipts which are not assigned to any Cash Application Owner:');

      FOR i in 1..results_tab.cash_receipt_id.count LOOP
      	IF  results_tab.cash_appln_owner_id(i) is null THEN
		 write_debug_and_log(results_tab.cash_receipt_id(i));
	END IF;
      END LOOP;

      delete from FUN_RULE_BULK_RESULT_GT;

      write_debug_and_log('ar_cao_assign_pkg.assign_work_items (-)');

  EXCEPTION
    WHEN OTHERS THEN
      write_debug_and_log(sqlerrm);

END;

END ar_cao_assign_pkg;

/
