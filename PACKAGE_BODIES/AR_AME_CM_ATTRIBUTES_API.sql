--------------------------------------------------------
--  DDL for Package Body AR_AME_CM_ATTRIBUTES_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_AME_CM_ATTRIBUTES_API" AS
/* $Header: ARAMEATB.pls 120.7 2005/09/06 17:16:01 vcrisost noship $ */

/*=======================================================================+
 |  Package Global Constants
 +=======================================================================*/


--- Get the customer id
FUNCTION get_customer_id (p_transaction_id IN  NUMBER)
    RETURN NUMBER IS

    CURSOR cust_id (p_txn_id NUMBER) IS
        SELECT rct.bill_to_customer_id
        FROM   hz_cust_accounts bill_to_cust,
               hz_parties party,
               ra_customer_trx  rct
        WHERE  rct.bill_to_customer_id = bill_to_cust.cust_account_id
        AND    bill_to_cust.party_id = party.party_id
        AND    rct.customer_trx_id =
                 (SELECT r.customer_trx_id
                  FROM   ar_lookups l, ra_cm_requests r
                  WHERE  r.request_id = p_txn_id
                  AND    r.cm_reason_code = l.lookup_code
                  AND    l.lookup_type = 'CREDIT_MEMO_REASON');


    l_customer_id ra_customer_trx.bill_to_customer_id%TYPE;

BEGIN

  OPEN cust_id (p_transaction_id);
  FETCH cust_id INTO l_customer_id;
  CLOSE cust_id;

  RETURN l_customer_id;

  --- Exception Handling code
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
       RAISE;

    WHEN OTHERS THEN
       RAISE;

END get_customer_id;


-- Get the customer transaction id
FUNCTION get_customer_trx_id (p_transaction_id IN  NUMBER)
    RETURN NUMBER IS

    CURSOR cust_t_id (p_txn_id NUMBER) IS
        SELECT r.customer_trx_id
        FROM   ar_lookups l,
               ra_cm_requests r
        WHERE  r.request_id = p_txn_id
        AND    r.cm_reason_code = l.lookup_code
        AND    l.lookup_type = 'CREDIT_MEMO_REASON';

    l_customer_trx_id ra_cm_requests.customer_trx_id%TYPE;

BEGIN

  OPEN cust_t_id(p_transaction_id);
  FETCH cust_t_id INTO l_customer_trx_id;
  CLOSE cust_t_id;

  RETURN l_customer_trx_id;

  --- Exception Handling code
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
       RAISE;

    WHEN OTHERS THEN
       RAISE;

END get_customer_trx_id;


--- Get the bill to use id
FUNCTION get_bill_to_use_id (p_transaction_id IN  NUMBER)
    RETURN NUMBER IS

    CURSOR bill_id (p_txn_id NUMBER) IS
        SELECT rct.bill_to_site_use_id
        FROM   hz_cust_accounts bill_to_cust,
               hz_parties party,
               ra_customer_trx  rct
        WHERE  rct.bill_to_customer_id = bill_to_cust.cust_account_id
        AND    bill_to_cust.party_id = party.party_id
        AND    rct.customer_trx_id =
                 (SELECT r.customer_trx_id
                  FROM   ar_lookups l,ra_cm_requests r
                  WHERE  r.request_id = p_txn_id
                  AND    r.cm_reason_code = l.lookup_code
                  AND    l.lookup_type = 'CREDIT_MEMO_REASON');

    l_bill_to_use_id ra_customer_trx.bill_to_site_use_id%TYPE;

BEGIN

  OPEN bill_id(p_transaction_id);
  FETCH bill_id INTO l_bill_to_use_id;
  CLOSE bill_id;

  RETURN l_bill_to_use_id;

  --- Exception Handling code
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
       RAISE;

    WHEN OTHERS THEN
       RAISE;

END get_bill_to_use_id;


--- Get the collector id
FUNCTION get_collector_id (p_transaction_id IN  NUMBER)
    RETURN VARCHAR2 IS

    -- 4566177 : pick up collector at site and header level, the order by clause will cause the
    -- cursor to return site level first in cases where both site and header, the code will use
    -- the first value returned
    CURSOR coll_id (p_customer_id NUMBER, p_bill_to_use_id NUMBER) IS
      SELECT  'person_id:' || col.employee_id, cp.site_use_id
      FROM    ar_collectors col,
              hz_customer_profiles cp
      WHERE   cp.collector_id    = col.collector_id
      AND     cp.cust_account_id = p_customer_id
      AND     (cp.site_use_id    = p_bill_to_use_id
               OR cp.site_use_id is NULL)
      ORDER by cp.site_use_id;

    -- In the cursor above the syntax can be changed
    -- as shown below to work with dynamic pre-approver
    -- SELECT  'first:pre:person_id:' || col.employee_id


    l_customer_id ra_customer_trx.bill_to_customer_id%TYPE;
    l_bill_to_use_id ra_customer_trx.bill_to_site_use_id%TYPE;
    -- l_collector_id ar_collectors.employee_id%TYPE;
    l_collector_id VARCHAR2(50);
    l_site_use_id  VARCHAR2(50);

BEGIN

  l_customer_id    := get_customer_id (p_transaction_id);
  l_bill_to_use_id := get_bill_to_use_id (p_transaction_id);

  OPEN coll_id(l_customer_id, l_bill_to_use_id);
  FETCH coll_id INTO l_collector_id, l_site_use_id;
  CLOSE coll_id;

  RETURN l_collector_id;

  --- Exception Handling code
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
       RAISE;

    WHEN OTHERS THEN
       RAISE;

END get_collector_id;


/*  All of these functions are very similar in structure and style.
 *  They all are used to get the value of certain attributes.  We
 *  do not know the type of the attributes, so we use the values in
 *  the tables where the data is obtained.
 */

--- Get the non default person id
FUNCTION get_non_default_person_id (p_transaction_id IN  NUMBER)
    RETURN NUMBER IS

    l_person_id wf_item_attribute_values.number_value%TYPE;

BEGIN


    l_person_id :=  wf_engine.GetItemAttrNumber(
                        itemtype => c_item_type,
                        itemkey => p_transaction_id,
                        aname => 'NON_DEFAULT_START_PERSON_ID');

    RETURN l_person_id;

END get_non_default_person_id;


--- Get requestor person id
FUNCTION get_requestor_person_id (p_transaction_id IN  NUMBER)
    RETURN NUMBER IS

    l_person_id wf_item_attribute_values.number_value%TYPE;

BEGIN

    l_person_id :=  wf_engine.GetItemAttrNumber(
                       itemtype =>  c_item_type,
                       itemkey =>  p_transaction_id,
                       aname =>  'REQUESTOR_ID');

    RETURN l_person_id;

END get_requestor_person_id;


--- Get the approval path
FUNCTION get_approval_path (p_transaction_id IN  NUMBER)
    RETURN VARCHAR2 IS

  l_approval_path wf_item_attribute_values.text_value%TYPE;

BEGIN

  l_approval_path :=  wf_engine.GetItemAttrText(
                         itemtype => c_item_type,
                         itemkey => p_transaction_id,
                         aname => 'APPROVAL_PATH');

  RETURN l_approval_path;

END get_approval_path;


--- Get the reason code
FUNCTION get_reason_code (p_transaction_id IN  NUMBER)
    RETURN VARCHAR2 IS

    l_reason_code wf_item_attribute_values.text_value%TYPE;

BEGIN

    l_reason_code :=  wf_engine.GetItemAttrText(
                        itemtype => c_item_type,
                        itemkey => p_transaction_id,
                        aname => 'REASON');

    RETURN l_reason_code;

END get_reason_code;


--- Get the transaction amount
FUNCTION get_transaction_amount (p_transaction_id IN  NUMBER)
    RETURN NUMBER IS

    l_txn_amount wf_item_attribute_values.number_value%TYPE;

BEGIN

    l_txn_amount :=  wf_engine.GetItemAttrNumber(
                        itemtype => c_item_type,
                        itemkey => p_transaction_id,
                        aname => 'TOTAL_CREDIT_TO_INVOICE');

    RETURN l_txn_amount;

END get_transaction_amount;

-- Get Approver ID
FUNCTION get_approver_id (p_transaction_id IN  NUMBER)
    RETURN NUMBER IS

    l_approver_id wf_item_attribute_values.number_value%TYPE;

BEGIN

    l_approver_id :=  wf_engine.GetItemAttrNumber(
                        itemtype => c_item_type,
                        itemkey => p_transaction_id,
                        aname => 'APPROVER_ID');

    RETURN l_approver_id;

END get_approver_id;


-- Get Approver User Name
FUNCTION get_approver_user_name (p_transaction_id IN  NUMBER)
    RETURN VARCHAR2 IS

    l_approver_user_name wf_item_attribute_values.text_value%TYPE;

BEGIN

    l_approver_user_name :=  wf_engine.GetItemAttrText(
                        itemtype => c_item_type,
                        itemkey => p_transaction_id,
                        aname => 'APPROVER_USER_NAME');

    RETURN l_approver_user_name;

END get_approver_user_name;


-- Get Batch Source Name
FUNCTION get_batch_source_name (p_transaction_id IN  NUMBER)
    RETURN VARCHAR2 IS

    l_batch_source_name wf_item_attribute_values.text_value%TYPE;

BEGIN

    l_batch_source_name :=  wf_engine.GetItemAttrText(
                        itemtype => c_item_type,
                        itemkey => p_transaction_id,
                        aname => 'BATCH_SOURCE_NAME');

    RETURN l_batch_source_name;

END get_batch_source_name;


-- Get Bill to Customer Name
FUNCTION get_bill_to_customer_name (p_transaction_id IN  NUMBER)
    RETURN VARCHAR2 IS

    l_bill_to_customer_name wf_item_attribute_values.text_value%TYPE;

BEGIN

    l_bill_to_customer_name :=  wf_engine.GetItemAttrText(
                        itemtype => c_item_type,
                        itemkey => p_transaction_id,
                        aname => 'BILL_TO_CUSTOMER_NAME');

    RETURN l_bill_to_customer_name;

END get_bill_to_customer_name;


-- Get Bill to Customer Number
FUNCTION get_bill_to_customer_number (p_transaction_id IN  NUMBER)
    RETURN VARCHAR2 IS

    l_bill_to_customer_number wf_item_attribute_values.text_value%TYPE;

BEGIN

    l_bill_to_customer_number :=  wf_engine.GetItemAttrText(
                        itemtype => c_item_type,
                        itemkey => p_transaction_id,
                        aname => 'BILL_TO_CUSTOMER_NUMBER');

    RETURN l_bill_to_customer_number;

END get_bill_to_customer_number;


-- Get Collector Employee Id
FUNCTION get_collector_employee_id (p_transaction_id IN  NUMBER)
    RETURN NUMBER IS

    l_collector_employee_id wf_item_attribute_values.number_value%TYPE;

BEGIN

    l_collector_employee_id :=  wf_engine.GetItemAttrNumber(
                        itemtype => c_item_type,
                        itemkey => p_transaction_id,
                        aname => 'COLLECTOR_EMPLOYEE_ID');

    RETURN l_collector_employee_id;

END get_collector_employee_id;


-- Get Collector Name
FUNCTION get_collector_name (p_transaction_id IN  NUMBER)
    RETURN VARCHAR2 IS

    l_collector_name wf_item_attribute_values.text_value%TYPE;

BEGIN

    l_collector_name :=  wf_engine.GetItemAttrText(
                        itemtype => c_item_type,
                        itemkey => p_transaction_id,
                        aname => 'COLLECTOR_NAME');

    RETURN l_collector_name;

END get_collector_name;


-- Get Collector User Name
FUNCTION get_collector_user_name (p_transaction_id IN  NUMBER)
    RETURN VARCHAR2 IS

    l_collector_user_name wf_item_attribute_values.text_value%TYPE;

BEGIN

    l_collector_user_name :=  wf_engine.GetItemAttrText(
                        itemtype => c_item_type,
                        itemkey => p_transaction_id,
                        aname => 'COLLECTOR_USER_NAME');

    RETURN l_collector_user_name;

END get_collector_user_name;


-- Get Currency Code
FUNCTION get_currency_code (p_transaction_id IN  NUMBER)
    RETURN VARCHAR2 IS

    l_currency_code wf_item_attribute_values.text_value%TYPE;

BEGIN

    l_currency_code :=  wf_engine.GetItemAttrText(
                        itemtype => c_item_type,
                        itemkey => p_transaction_id,
                        aname => 'CURRENCY_CODE');

    RETURN l_currency_code;

END get_currency_code;


-- Get Customer Name
FUNCTION get_customer_name (p_transaction_id IN  NUMBER)
    RETURN VARCHAR2 IS

    l_customer_name wf_item_attribute_values.text_value%TYPE;

BEGIN

    l_customer_name :=  wf_engine.GetItemAttrText(
                        itemtype => c_item_type,
                        itemkey => p_transaction_id,
                        aname => 'CUSTOMER_NAME');

    RETURN l_customer_name;

END get_customer_name;


-- Get Original Transaction Number
FUNCTION get_orig_trx_number (p_transaction_id IN  NUMBER)
    RETURN VARCHAR2 IS

    l_orig_trx_number wf_item_attribute_values.text_value%TYPE;

BEGIN

    l_orig_trx_number :=  wf_engine.GetItemAttrText(
                        itemtype => c_item_type,
                        itemkey => p_transaction_id,
                        aname => 'ORIG_TRX_NUMBER');

    RETURN l_orig_trx_number;

END get_orig_trx_number;


-- Get Requestor Id
FUNCTION get_requestor_id (p_transaction_id IN  NUMBER)
    RETURN NUMBER IS

    l_requestor_id wf_item_attribute_values.number_value%TYPE;

BEGIN

    l_requestor_id :=  wf_engine.GetItemAttrNumber(
                        itemtype => c_item_type,
                        itemkey => p_transaction_id,
                        aname => 'REQUESTOR_ID');

    RETURN l_requestor_id;

END get_requestor_id;


-- Get Requestor User Name
FUNCTION get_requestor_user_name (p_transaction_id IN  NUMBER)
    RETURN VARCHAR2 IS

    l_requestor_user_name wf_item_attribute_values.text_value%TYPE;

BEGIN

    l_requestor_user_name :=  wf_engine.GetItemAttrText(
                        itemtype => c_item_type,
                        itemkey => p_transaction_id,
                        aname => 'REQUESTOR_USER_NAME');

    RETURN l_requestor_user_name;

END get_requestor_user_name;


-- Get Ship to Customer Name
FUNCTION get_ship_to_customer_name (p_transaction_id IN  NUMBER)
    RETURN VARCHAR2 IS

    l_ship_to_customer_name wf_item_attribute_values.text_value%TYPE;

BEGIN

    l_ship_to_customer_name :=  wf_engine.GetItemAttrText(
                        itemtype => c_item_type,
                        itemkey => p_transaction_id,
                        aname => 'SHIP_TO_CUSTOMER_NAME');

    RETURN l_ship_to_customer_name;

END get_ship_to_customer_name;


-- Get Ship to Customer Number
FUNCTION get_ship_to_customer_number (p_transaction_id IN  NUMBER)
    RETURN VARCHAR2 IS

    l_ship_to_customer_number wf_item_attribute_values.text_value%TYPE;

BEGIN

    l_ship_to_customer_number :=  wf_engine.GetItemAttrText(
                        itemtype => c_item_type,
                        itemkey => p_transaction_id,
                        aname => 'SHIP_TO_CUSTOMER_NUMBER');

    RETURN l_ship_to_customer_number;

END get_ship_to_customer_number;


-- Tax Ex Certification Number
FUNCTION get_tax_ex_cert_num (p_transaction_id IN  NUMBER)
    RETURN VARCHAR2 IS

    l_tax_ex_cert_num 	wf_item_attribute_values.text_value%TYPE;

BEGIN

    l_tax_ex_cert_num :=  wf_engine.GetItemAttrText(
                        itemtype => c_item_type,
                        itemkey => p_transaction_id,
                        aname => 'TAX_EX_CERT_NUM');

    RETURN l_tax_ex_cert_num;

END get_tax_ex_cert_num;


-- primary salesperson user name
FUNCTION get_salesrep_user_name (p_transaction_id IN  NUMBER)
    RETURN VARCHAR2 IS

    l_salesrep_user_name wf_item_attribute_values.text_value%TYPE;

BEGIN

    l_salesrep_user_name :=  wf_engine.GetItemAttrText(
                        itemtype => c_item_type,
                        itemkey => p_transaction_id,
                        aname => 'SALESREP_USER_NAME');

    RETURN l_salesrep_user_name;

END get_salesrep_user_name;

-- transaction type name
FUNCTION get_transaction_type_name (p_transaction_id IN  NUMBER)
    RETURN VARCHAR2 IS


  CURSOR trx_types IS
    SELECT tt.name
    FROM   ar_lookups l,
           ra_cm_requests r,
           ra_customer_trx t,
           ra_cust_trx_types tt
    WHERE  r.request_id = p_transaction_id
    AND    r.cm_reason_code = l.lookup_code
    AND    l.lookup_type = 'CREDIT_MEMO_REASON'
    AND    t.customer_trx_id = r.customer_trx_id
    AND    t.cust_trx_type_id = tt.cust_trx_type_id;

    l_trx_type_name wf_item_attribute_values.text_value%TYPE;

BEGIN

    OPEN trx_types;
    FETCH trx_types INTO l_trx_type_name;
    CLOSE trx_types;

    RETURN l_trx_type_name;

END get_transaction_type_name;

-- transaction context
FUNCTION get_transaction_context (p_transaction_id IN  NUMBER)
    RETURN VARCHAR2 IS

  CURSOR trx_types IS
    SELECT interface_line_context
    FROM   ar_lookups l,
           ra_cm_requests r,
           ra_customer_trx_lines tl
    WHERE  r.request_id = p_transaction_id
    AND    r.cm_reason_code = l.lookup_code
    AND    l.lookup_type = 'CREDIT_MEMO_REASON'
    AND    tl.customer_trx_id = r.customer_trx_id
    AND    tl.interface_line_context IS NOT NULL
    AND    rownum = 1;

    l_trx_type_name wf_item_attribute_values.text_value%TYPE;

BEGIN

    OPEN trx_types;
    FETCH trx_types INTO l_trx_type_name;
    CLOSE trx_types;

    RETURN l_trx_type_name;

END get_transaction_context;


END ar_ame_cm_attributes_api;

/
