--------------------------------------------------------
--  DDL for Package Body ARP_AUTOAPPLY_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_AUTOAPPLY_API" AS
/*$Header: ARATAPPB.pls 120.0.12010000.11 2009/05/12 07:46:11 aghoraka noship $*/
  PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');
  G_PROGRAM_ID             NUMBER    := 111;
  G_PROGRAM_APPLICATION_ID NUMBER    := 222;
  G_CREATED_BY             NUMBER    := -222;
  G_LAST_UPDATED_BY        NUMBER    := -222;
  G_LAST_UPDATE_LOGIN      NUMBER    := -222;
  g_next_reco_id           NUMBER;
  g_prev_reco_num          NUMBER;
  G_MAX_ARRAY_SIZE         NUMBER    := 1000;

  TYPE l_processed_rules_tab IS TABLE OF AR_CASH_AUTOMATCHES.AUTOMATCH_ID%TYPE
                                                      INDEX BY BINARY_INTEGER;
  l_processed_rules l_processed_rules_tab;
  g_reco_index NUMBER := 0;
  reco_id_arr reco_id_tab;
  remit_ref_id_arr remit_ref_id_tab;
  customer_id_arr customer_id_tab;
  customer_site_use_id_arr customer_site_use_id_tab;
  resolved_matching_number_arr resolved_matching_number_tab;
  resolved_matching_date_arr resolved_matching_date_tab;
  resolved_matching_class_arr resolved_matching_class_tab;
  resolved_match_currency_arr resolved_match_currency_tab;
  match_resolved_using_arr match_resolved_using_tab;
  cons_inv_id_arr cons_inv_id_tab;
  match_score_value_arr match_score_value_tab;
  match_reason_code_arr match_reason_code_tab;
  org_id_arr org_id_tab;
  automatch_id_arr automatch_id_tab;
  priority_arr priority_tab;
  reco_num_arr reco_num_tab;
  customer_trx_id_arr customer_trx_id_tab;
  payment_schedule_id_arr payment_schedule_id_tab;
  amount_applied_arr amount_applied_tab;
  amount_applied_from_arr amount_applied_from_tab;
  trans_to_receipt_rate_arr trans_to_receipt_rate_tab;
  receipt_currency_code_arr receipt_currency_code_tab;
  receipt_date_arr receipt_date_tab;
  recommendation_reason_arr recommendation_reason_tab;
  discount_taken_earned_arr discount_taken_earned_tab;
  discount_taken_unearned_arr discount_taken_unearned_tab;

  PROCEDURE gen_str_transformations(p_rule_id IN NUMBER
                                    , x_trans_format_str OUT NOCOPY VARCHAR2
                                    , x_rem_format_str OUT NOCOPY VARCHAR2
                                    , x_trans_float_str OUT NOCOPY VARCHAR2
                                    , x_rem_float_str OUT NOCOPY VARCHAR2);

  PROCEDURE insert_invoice_recos (p_automatch_id IN NUMBER
                                  , p_use_matching_date IN VARCHAR2
                                  , p_trans_format_str IN VARCHAR2
                                  , p_rem_format_str  IN VARCHAR2
                                  , p_trans_float_str IN VARCHAR2
                                  , p_rem_float_str IN VARCHAR2
                                  , p_worker_number IN NUMBER
                                  , p_request_id IN NUMBER);

  PROCEDURE insert_po_recos (p_automatch_id IN NUMBER
                            , p_use_matching_date IN VARCHAR2
                            , p_trans_format_str IN VARCHAR2
                            , p_rem_format_str  IN VARCHAR2
                            , p_trans_float_str IN VARCHAR2
                            , p_rem_float_str IN VARCHAR2
                            , p_worker_number IN NUMBER
                            , p_request_id IN NUMBER);

  PROCEDURE insert_so_recos (p_automatch_id IN NUMBER
                            , p_use_matching_date IN VARCHAR2
                            , p_trans_format_str IN VARCHAR2
                            , p_rem_format_str  IN VARCHAR2
                            , p_trans_float_str IN VARCHAR2
                            , p_rem_float_str IN VARCHAR2
                            , p_worker_number IN NUMBER
                            , p_request_id IN NUMBER);

  PROCEDURE insert_contract_recos (p_automatch_id IN NUMBER
                                  , p_use_matching_date IN VARCHAR2
                                  , p_trans_format_str IN VARCHAR2
                                  , p_rem_format_str  IN VARCHAR2
                                  , p_trans_float_str IN VARCHAR2
                                  , p_rem_float_str IN VARCHAR2
                                  , p_worker_number IN NUMBER
                                  , p_request_id IN NUMBER);

  PROCEDURE insert_attribute_recos (p_automatch_id IN NUMBER
                                  , p_use_matching_date IN VARCHAR2
                                  , p_trans_format_str IN VARCHAR2
                                  , p_rem_format_str  IN VARCHAR2
                                  , p_trans_float_str IN VARCHAR2
                                  , p_rem_float_str IN VARCHAR2
                                  , p_worker_number IN NUMBER
                                  , p_attribute_number IN VARCHAR2
                                  , p_request_id IN NUMBER);

  PROCEDURE insert_waybill_recos (p_automatch_id IN NUMBER
                                  , p_use_matching_date IN VARCHAR2
                                  , p_trans_format_str IN VARCHAR2
                                  , p_rem_format_str  IN VARCHAR2
                                  , p_trans_float_str IN VARCHAR2
                                  , p_rem_float_str IN VARCHAR2
                                  , p_worker_number IN NUMBER
                                  , p_request_id IN NUMBER);

  PROCEDURE insert_bfb_recos (p_automatch_id IN NUMBER
                                , p_use_matching_date IN VARCHAR2
                                , p_trans_format_str IN VARCHAR2
                                , p_rem_format_str  IN VARCHAR2
                                , p_trans_float_str IN VARCHAR2
                                , p_rem_float_str IN VARCHAR2
                                , p_worker_number IN NUMBER
                                , p_request_id IN NUMBER);

  PROCEDURE insert_reference_recos (p_automatch_id IN NUMBER
                                  , p_use_matching_date IN VARCHAR2
                                  , p_trans_format_str IN VARCHAR2
                                  , p_rem_format_str  IN VARCHAR2
                                  , p_trans_float_str IN VARCHAR2
                                  , p_rem_float_str IN VARCHAR2
                                  , p_worker_number IN NUMBER
                                  , p_request_id IN NUMBER);

  PROCEDURE validate_trx_recos( p_req_id IN NUMBER
                                , p_worker_number IN NUMBER);

  PROCEDURE apply_trx_recos(p_req_id         IN NUMBER
                            , p_worker_number  IN NUMBER);

  PROCEDURE copy_current_record(  p_current_reco IN OUT NOCOPY selected_recos_table
                                , p_selected_recos IN selected_recos_table
                                , p_index IN NUMBER);

  PROCEDURE process_single_reco(p_current_reco IN OUT NOCOPY selected_recos_table
                                , p_match_resolved_using IN VARCHAR2);

  PROCEDURE clear_reco_lines_struct;

  PROCEDURE populate_reco_line_struct(p_current_reco IN selected_recos_table
                                    , p_match_resolved_using IN VARCHAR2
                                    , p_recommendation_id IN NUMBER
                                    , p_recommendation_reason IN VARCHAR2);

  PROCEDURE insert_recos(p_request_id IN NUMBER);

  PROCEDURE calc_amount_app_and_disc(
                    p_customer_id IN AR_PAYMENT_SCHEDULES.customer_id%TYPE
                    , p_bill_to_site_use_id IN AR_PAYMENT_SCHEDULES.customer_site_use_id%TYPE
                    , p_invoice_currency_code IN AR_PAYMENT_SCHEDULES.invoice_currency_code%TYPE
                    , p_ps_id IN AR_PAYMENT_SCHEDULES.payment_schedule_id%TYPE
                    , p_term_id IN AR_PAYMENT_SCHEDULES.term_id%TYPE
                    , p_terms_sequence_number IN AR_PAYMENT_SCHEDULES.terms_sequence_number%TYPE
                    , p_trx_date IN AR_PAYMENT_SCHEDULES.trx_date%TYPE
                    , p_allow_overapp_flag IN RA_CUST_TRX_TYPES.allow_overapplication_flag%TYPE
                    , p_partial_discount_flag IN RA_TERMS.partial_discount_flag%TYPE
                    , p_input_amount IN AR_CASH_REMIT_REFS.amount_applied%TYPE
                    , p_amount_due_original IN AR_PAYMENT_SCHEDULES.amount_due_original%TYPE
                    , p_amount_due_remaining IN AR_PAYMENT_SCHEDULES.amount_due_remaining%TYPE
                    , p_discount_taken_earned IN AR_PAYMENT_SCHEDULES.discount_taken_earned%TYPE
                    , p_discount_taken_unearned IN AR_PAYMENT_SCHEDULES.discount_taken_unearned%TYPE
                    , p_cash_receipt_id IN AR_CASH_RECEIPTS.cash_receipt_id%TYPE
                    , x_out_amount_to_apply OUT NOCOPY NUMBER
                    , x_out_discount_to_take OUT NOCOPY NUMBER);

  PROCEDURE calc_amt_applied_from(
                    p_currency_code IN VARCHAR2,
                    p_amount_applied IN ar_payments_interface.amount_applied1%type,
                    p_trans_to_receipt_rate IN ar_payments_interface.trans_to_receipt_rate1%type,
                    amount_applied_from OUT NOCOPY ar_payments_interface.amount_applied_from1%type);

  PROCEDURE calc_amt_applied(
                    p_invoice_currency_code IN VARCHAR2,
                    p_amount_applied_from IN ar_payments_interface.amount_applied_from1%type,
                    p_trans_to_receipt_rate IN ar_payments_interface.trans_to_receipt_rate1%type,
                    amount_applied OUT NOCOPY ar_payments_interface.amount_applied1%type);

/*===========================================================================+
 * PROCEDURE                                                                 *
 *     LOG()                                                                 *
 * DESCRIPTION                                                               *
 *   Writes the message to debug log.                                        *
 * SCOPE - LOCAL                                                             *
 * ARGUMENTS                                                                 *
 *              IN  : p_msg - Message                                        *
 *              OUT : NONE                                                   *
 * RETURNS      NONE                     				                             *
 * ALGORITHM                                                                 *
 *                                                                           *
 * NOTES -                                                                   *
 *                                                                           *
 * MODIFICATION HISTORY -  09/03/2009 - Created by AGHORAKA	     	           *
 *                                                                           *
 +===========================================================================*/

  PROCEDURE log(p_msg VARCHAR2) IS
  BEGIN
      arp_standard.debug('AutoApply: ' || p_msg || ' : ' || TO_CHAR(SYSDATE,'DD/MM/YY hh:mi:ss'));
  END;

/*===========================================================================+
 * FUNCTION                                                                  *
 *     GET_NEXT_RECO_ID()                                                    *
 * DESCRIPTION                                                               *
 *   Generates the recommendation id from sequence ar_cash_recos_s           *
 * SCOPE - LOCAL                                                             *
 * ARGUMENTS                                                                 *
 *              IN  : p_reco_num - Recommendation Number                     *
 * RETURNS      NUMBER                  				                             *
 * ALGORITHM                                                                 *
 * Generate a new sequence if p_reco_num passed is equal to 1.               *
 * NOTES -                                                                   *
 *  The function will be called for every insert execution but we need to    *
 *  generate a new sequence only for a new recommendation (not for each line)*
 * MODIFICATION HISTORY -  09/03/2009 - Created by AGHORAKA	     	           *
 *                                                                           *
 +===========================================================================*/

  FUNCTION get_next_reco_id( p_reco_num IN NUMBER)
  RETURN NUMBER IS
  l_reco_id NUMBER;
  BEGIN
    IF  p_reco_num = 1 AND NVL(g_prev_reco_num, -1) <> 1 THEN
        SELECT ar_cash_recos_s.nextval
        INTO l_reco_id
        FROM DUAL;
        g_next_reco_id := l_reco_id;
        g_prev_reco_num := p_reco_num;
    ELSIF p_reco_num = 1 AND g_prev_reco_num = 1 THEN
        g_prev_reco_num := -1;
    ELSE
        g_prev_reco_num := p_reco_num;
    END IF;

    RETURN g_next_reco_id;
  END get_next_reco_id;

/*===========================================================================+
 * FUNCTION                                                                  *
 *     IS_RULE_PROCESSED()                                                   *
 * DESCRIPTION                                                               *
 *   Checks if an Automatch Rule is already processed in the current run.    *
 * SCOPE - LOCAL                                                             *
 * ARGUMENTS                                                                 *
 *              IN  : p_rule_id - Automatch Rule ID                          *
 *              OUT : NONE                                                   *
 * RETURNS      BOOLEAN                  				                             *
 * ALGORITHM                                                                 *
 *   Table l_processed_rules is used to store the rules already processed in *
 * the current run. The function first checks if a rule is present in the    *
 * table l_processed_rules via linear search. If present retuns TRUE. Other  *
 * wise add the rule to the table and retun FALSE.                           *
 * NOTES -                                                                   *
 *                                                                           *
 * MODIFICATION HISTORY -  09/03/2009 - Created by AGHORAKA	     	           *
 *                                                                           *
 +===========================================================================*/

  FUNCTION is_rule_processed (  p_rule_id IN NUMBER)
  RETURN BOOLEAN IS
    l_table_size  NUMBER;
    i             NUMBER;
  BEGIN
    IF (PG_DEBUG IN ('Y', 'C')) THEN
        log('arp_autoapply_api.is_rule_processed(+)');
        log('Rule Id: '||p_rule_id);
    END IF;
    l_table_size := NVL(l_processed_rules.last, 0);

    FOR i IN 1..l_table_size LOOP
      IF l_processed_rules(i) = p_rule_id THEN
        IF (PG_DEBUG IN ('Y', 'C')) THEN
          log('Rule already processed.');
          log('arp_autoapply_api.is_rule_processed(-)');
        END IF;
        RETURN TRUE;
      END IF;
    END LOOP;

    l_processed_rules(l_table_size + 1) := p_rule_id;
    IF (PG_DEBUG IN ('Y', 'C')) THEN
      log('New Rule.');
      log('arp_autoapply_api.is_rule_processed(-)');
    END IF;
    RETURN FALSE;
  END is_rule_processed;

/*===========================================================================+
 * PROCEDURE                                                                 *
 *     GEN_STR_TRANSFORMATIONS()                                             *
 * DESCRIPTION                                                               *
 *    Generate regular expressions for remittance and document reference     *
 * string transformations using the setup at 'AutoMatch Rule'.               *
 * SCOPE - LOCAL                                                             *
 * ARGUMENTS                                                                 *
 *              IN  : p_rule_id Automatch Rule Identifier.                   *
 *              OUT : x_trans_format_str Document Number transformation String
 *                    x_rem_format_str Remittance Number transformation String
 *                                                                           *
 * RETURNS      NONE                    				                             *
 * ALGORITHM                                                                 *
 *    1. Fetch string type, location and padding values for the current auto *
 * identifier.                                                               *
 *    2. Build regular expressions based on the above values.                *
 *    3. If more than one transformation rows are added for any reference,   *
 * are combined using 'AND' operator.                                        *
 * NOTES -                                                                   *
 * Example :                                                                 *
 *   String_Type_Code : Document                                             *
 *   String_Location_Code : Front                                            *
 *   Padding_Value_Code : ZERO                                               *
 *   Number_Of_Positions : 3                                                 *
 *   Padding_Value_Code : Space                                              *
 *   Number_Of_Positions : 2                                                 *
 *   Padding_Value_Code : Back                                               *
 *   Padding_Value_Code : ANY                                                *
 *   Number_Of_Positions : 2                                                 *
 *   Transformation String : ^([0]{3}[ ]{2})(.*)(.{2})$                      *
 * MODIFICATION HISTORY -  09/03/2009 - Created by AGHORAKA	     	           *
 *                                                                           *
 +===========================================================================*/

  PROCEDURE gen_str_transformations(p_rule_id IN NUMBER
                                    , x_trans_format_str OUT NOCOPY VARCHAR2
                                    , x_rem_format_str OUT NOCOPY VARCHAR2
                                    , x_trans_float_str OUT NOCOPY VARCHAR2
                                    , x_rem_float_str OUT NOCOPY VARCHAR2)IS
      CURSOR rule_dtls (p_rule_id NUMBER) IS
      SELECT string_type_code type,
      string_location_code location,
      DECODE(padding_value_code, 'ZERO',  '[0]',
                                 'SPACE', '[ ]',
                                 'ANY',   '.',
                                 padding_value_code) value,
      DECODE(padding_value_code, 'ANY',  NVL(TO_CHAR(number_of_positions),'9999'),
                                 'ZERO', NVL(TO_CHAR(number_of_positions),'1,'),
                                 'SPACE', NVL(TO_CHAR(number_of_positions),'1,')) position
                                  /* When no of positions is not mentioned replace all the occurences */
      FROM ar_cash_automatch_dtls
      WHERE automatch_id = p_rule_id
      ORDER BY string_type_code ASC, string_location_code ASC, padding_sequence ASC;

      l_trx_ft_exp VARCHAR2(1000) := '^(';
      l_rmt_ft_exp VARCHAR2(1000) := '^(';
      l_trx_fl_exp VARCHAR2(1000);
      l_trx_bk_exp VARCHAR2(1000) := ')$';
      l_rmt_bk_exp VARCHAR2(1000) := ')$';
      l_rmt_fl_exp VARCHAR2(1000);

  BEGIN
      IF (PG_DEBUG IN ('Y', 'C')) THEN
        log('arp_autoapply_api.gen_regexp(+)');
        log('Rule Id: '||p_rule_id);
      END IF;
      FOR r_rule_dtls IN  rule_dtls(p_rule_id) LOOP
        IF (r_rule_dtls.type = 'DOCUMENT') THEN /* Document Number */
          IF (r_rule_dtls.location = 'FRONT') THEN
              l_trx_ft_exp := l_trx_ft_exp || r_rule_dtls.value || '{' || r_rule_dtls.position || '}';
          ELSIF (r_rule_dtls.location = 'BACK') THEN
              l_trx_bk_exp := r_rule_dtls.value || '{' || r_rule_dtls.position || '}' || l_trx_bk_exp;
          ELSIF (r_rule_dtls.location = 'FLOAT') THEN
              l_trx_fl_exp := l_trx_fl_exp || '|' || r_rule_dtls.value;
          END IF;
        ELSIF (r_rule_dtls.type = 'REMITTANCE') THEN /* Remittance Number */
          IF (r_rule_dtls.location = 'FRONT') THEN
              l_rmt_ft_exp := l_rmt_ft_exp || r_rule_dtls.value || '{' || r_rule_dtls.position || '}';
          ELSIF (r_rule_dtls.location = 'BACK') THEN
              l_rmt_bk_exp := r_rule_dtls.value || '{' || r_rule_dtls.position || '}' || l_rmt_bk_exp;
          ELSIF (r_rule_dtls.location = 'FLOAT') THEN
              l_rmt_fl_exp := l_rmt_fl_exp || '|' || r_rule_dtls.value;
          END IF;
        END IF;
      END LOOP;

      x_trans_format_str := l_trx_ft_exp || ')' || '(.*)' || '(' || l_trx_bk_exp;
      x_trans_float_str  := LTRIM(l_trx_fl_exp, '|');
      x_rem_format_str   := l_rmt_ft_exp || ')' || '(.*)' || '(' || l_rmt_bk_exp;
      x_rem_float_str    := LTRIM(l_rmt_fl_exp, '|');

      IF (PG_DEBUG IN ('Y', 'C')) THEN
        log('Transaction Expression : '|| l_trx_ft_exp || ')' || '(.*)' || '(' || l_trx_bk_exp);
        log('Transaction Float Expression : ' || x_trans_float_str);
        log('Remittance Expression : '|| l_rmt_ft_exp || ')' || '(.*)' || '(' || l_rmt_bk_exp);
        log('Remittance Float Expression : ' || x_rem_float_str);
        log('ar_automatch_pkg.gen_regexp(-)');
      END IF;
  EXCEPTION
  WHEN OTHERS THEN
      log('Exception from ar_automatch_pkg.gen_regexp');
      log(SQLERRM);
      RAISE;
  END gen_str_transformations;

/*===========================================================================+
 * PROCEDURE                                                                 *
 *     AUTO_APPLY_MASTER()                                                   *
 * DESCRIPTION                                                               *
 *   Automatic Cash Application Master Program                               *
 * SCOPE - PUBLIC                                                            *
 * ARGUMENTS                                                                 *
 *              IN  : p_org_id Operating Unit identifier                     *
 *                    p_receipt_no_l Receipt Number Low                      *
 *                    p_receipt_no_h Receipt Number High                     *
 *                    p_batch_name_l Batch Name Low                          *
 *                    p_batch_name_h Batch Name High                         *
 *                    p_min_unapp_amt Minimun Unapplied Amount on the Receipt*
 *                    p_receipt_date_l Receipt Date Low                      *
 *                    p_receipt_date_h Receipt Date High                     *
 *                    p_receipt_method_l Receipt Method Low                  *
 *                    p_receipt_method_h Receipt Method High                 *
 *                    p_customer_name_l Customer Name Low                    *
 *                    p_customer_name_h Customer Name High                   *
 *                    p_customer_no_l Customer Number Low                    *
 *                    p_customer_no_h Customer Number High                   *
 *                    p_batch_id Batch Identifier                            *
 *                    p_transmission_id Transmission Identifier              *
 *                    p_called_from Calling Program Name                     *
 *                    p_total_workers No of Instances                        *
 *              OUT : P_ERRBUF Error Message Buffer                          *
 *                    P_RETCODE Return Code                                  *
 *                                                                           *
 * RETURNS      NONE                    				                             *
 * ALGORITHM                                                                 *
 *   1. Delete data from ar_cash_remit_refs_interim, if any data is present. *
 *      The table is truncated at the end of each run. However if any data   *
 *      exists inside the interim event necause of any unhandled exception in*
 *      the previous run, just a precautionary measure to retrunc the table  *
 *   2. Populate ar_cash_Remit_refs_interim with data from ar_cash_remit_refs*
 *      based on the parameters provided to the concurrent program.          *
 *   3. Update the references with status 'AR_AA_RULE_SET_INACTIVE' which    *
 *      are associated to a rule set that is inactive.                       *
 *   4. Spawn the child process or directly call auto_apply_child() process  *
 *      based on the 'No of Instances' parameter.                            *
 *   5. Update the references with status 'AR_AA_SUGG_FOUND'/'AR_AA_NO_MATCH'*
 *      based on the number of receommendations generated for the remittances*
 *      that are not automatically applied.                                  *
 *   6. Update the receipt's WORK_ITEM_EXCEPTION_REASON for the receipts that*
 *      have unapplied remittance lines at the end of the program.           *
 * NOTES -                                                                   *
 *   This program is the starting point for 'AR_AUTOAPPLY_API'. This is      *
 * called from XML report                                                    *
 * MODIFICATION HISTORY -  09/03/2009 - Created by AGHORAKA	     	           *
 *                                                                           *
 +===========================================================================*/

  PROCEDURE auto_apply_master ( P_ERRBUF              OUT NOCOPY VARCHAR2
                              , P_RETCODE             OUT NOCOPY NUMBER
                              , p_org_id              IN NUMBER
                              , p_receipt_no_l        IN VARCHAR2
                              , p_receipt_no_h        IN VARCHAR2
                              , p_batch_name_l        IN VARCHAR2
                              , p_batch_name_h        IN VARCHAR2
                              , p_min_unapp_amt       IN NUMBER
                              , p_receipt_date_l      IN VARCHAR2
                              , p_receipt_date_h      IN VARCHAR2
                              , p_receipt_method_l    IN VARCHAR2
                              , p_receipt_method_h    IN VARCHAR2
                              , p_customer_name_l     IN VARCHAR2
                              , p_customer_name_h     IN VARCHAR2
                              , p_customer_no_l       IN VARCHAR2
                              , p_customer_no_h       IN VARCHAR2
                              , p_batch_id            IN NUMBER
                              , p_transmission_id     IN NUMBER
                              , p_called_from         IN VARCHAR2
                              , p_total_workers       IN NUMBER) IS

      l_insert_stmt   VARCHAR2(30000) := NULL;
      l_from_clause   VARCHAR2(1000)  := NULL;
      l_where_clause  VARCHAR2(10000) := NULL;
      l_use_cr        VARCHAR2(1)     := 'N';
      l_use_rm        VARCHAR2(1)     := 'N';
      l_use_bat       VARCHAR2(1)     := 'N';
      l_use_cust      VARCHAR2(1)     := 'N';
      l_use_party     VARCHAR2(1)     := 'N';
      l_worker_number NUMBER;
      l_complete		        BOOLEAN := FALSE;
      l_receipt_date_low AR_CASH_RECEIPTS.receipt_date%TYPE;
      l_receipt_date_high AR_CASH_RECEIPTS.receipt_date%TYPE;
      l_errbuf        VARCHAR2(1000);
      l_retcode       NUMBER;

      insert_gt       INTEGER;
      l_rows_inserted INTEGER;

      TYPE req_status_typ  IS RECORD (
            request_id       NUMBER(15),
            dev_phase        VARCHAR2(255),
            dev_status       VARCHAR2(255),
            message          VARCHAR2(2000),
            phase            VARCHAR2(255),
            status           VARCHAR2(255));

    TYPE req_status_tab_typ   IS TABLE OF req_status_typ INDEX BY BINARY_INTEGER;

    l_req_status_tab   req_status_tab_typ;

      /*=======================================================================+
      * PROCEDURE                                                             *
      *   SUBMIT_SUBREQUEST() -                                               *
      * DESCRIPTION                                                           *
      *   This procedure launches the child programs for AutoApply Process    *
      *									                                                      *
      * SCOPE - LOCAL                                                         *
      *									                                                      *
      * ARGUMENTS  : IN  :p_worker_number - Worker Number                     *
      *                   p_org_id - Operating Unit Identifier                *
      *                                                                       *
      *              OUT :     None                                            *
      * RETURNS    : NONE                    				                          *
      *                                                                       *
      * NOTES -                                                               *
      *                                                                       *
      * MODIFICATION HISTORY -  09/03/2009 - Created by AGHORAKA	     	      *
      +=======================================================================*/
      PROCEDURE submit_subrequest ( p_worker_number IN NUMBER,
                                    p_org_id IN NUMBER) IS
        l_request_id NUMBER(15);
      BEGIN
        IF (PG_DEBUG IN ('Y', 'C')) THEN
          log('arp_autoapply_api.submit_subrequest(+)');
          log('Worker No : '|| p_worker_number);
        END IF;

      	FND_REQUEST.SET_ORG_ID(p_org_id);

      	l_request_id := FND_REQUEST.submit_request( 'AR', 'ARATAPPC',
                        'Auto Cash Application Child Program',
                        SYSDATE,
                        FALSE,
                        p_worker_number);

      	IF (l_request_id = 0) THEN
      	    log('Can not start for worker_id: ' ||p_worker_number );
      	    P_ERRBUF := fnd_Message.get;
      	    P_RETCODE := 2;
      	    return;
      	ELSE
      	    commit;
      	    log('child request id: ' ||l_request_id || ' started for worker_id: ' ||p_worker_number );
      	END IF;

      	 l_req_status_tab(p_worker_number).request_id := l_request_id;
      	 IF (PG_DEBUG IN ('Y', 'C')) THEN
          log('arp_autoapply_api.submit_subrequest(-)');
        END IF;
        EXCEPTION
        WHEN OTHERS THEN
          log('Exception from arp_autoapply_api.submit_subrequest');
          log(SQLERRM);
          RAISE;
    END submit_subrequest;

  BEGIN
      IF (PG_DEBUG IN ('Y', 'C')) THEN
          log('arp_autoapply_api.auto_apply_master(+)');
          log('Org Id : ' || p_org_id);
          log('Receipt Number From ' || p_receipt_no_l || ' To ' || p_receipt_no_h);
          log('Batch Name From ' || p_batch_name_l || ' To ' || p_batch_name_h);
          log('Minimun Unapplied Amount : ' || p_min_unapp_amt);
          log('Receipt Date From ' || p_receipt_date_l || ' To ' || p_receipt_date_h);
          log('Customer Name From ' || p_customer_name_l || ' To ' || p_customer_name_h);
          log('Customer Number From ' || p_customer_no_l || ' To ' || p_customer_no_h);
          log('Batch ID : ' || p_batch_id);
          log('Transmission ID : ' || p_transmission_id);
          log('Called From : ' || p_called_from);
          log('Total Workers : ' || p_total_workers);
      END IF;
      delete_interim_records; /* Call to delete records from interface table */
      G_PROGRAM_ID             := arp_standard.profile.program_id;
      G_PROGRAM_APPLICATION_ID := arp_standard.application_id;
      G_CREATED_BY             := arp_standard.profile.user_id;
      G_LAST_UPDATED_BY        := arp_standard.profile.user_id;
      G_LAST_UPDATE_LOGIN      := arp_standard.profile.last_update_login;
      /* Fetch the data from ar_cash_remit_refs table for the current run
         based on the parameters */
      l_insert_stmt := ' INSERT INTO AR_CASH_REMIT_REFS_INTERIM
                       (   REMIT_REFERENCE_ID,
                           RECEIPT_REFERENCE_STATUS,
                           AUTOMATCH_SET_ID,
                           CASH_RECEIPT_ID,
                           REFERENCE_SOURCE,
                           CUSTOMER_ID,
                           CUSTOMER_NUMBER,
                           BANK_ACCOUNT_NUMBER,
                           TRANSIT_ROUTING_NUMBER,
                           INVOICE_REFERENCE,
                           MATCHING_REFERENCE_DATE,
                           INSTALLMENT_REFERENCE,
                           INVOICE_CURRENCY_CODE,
                           AMOUNT_APPLIED,
                           AMOUNT_APPLIED_FROM,
                           TRANS_TO_RECEIPT_RATE,
                           TRANSMISSION_ID,
                           BATCH_ID,
                           WORKER_NUMBER)
                       SELECT ref.REMIT_REFERENCE_ID,
                           ''AR_AM_NEW'',
                           cr.AUTOMATCH_SET_ID,
                           ref.CASH_RECEIPT_ID,
                           ref.REFERENCE_SOURCE,
                           cr.PAY_FROM_CUSTOMER,
                           ref.CUSTOMER_NUMBER,
                           ref.BANK_ACCOUNT_NUMBER,
                           ref.TRANSIT_ROUTING_NUMBER,
                           ref.INVOICE_REFERENCE,
                           ref.MATCHING_REFERENCE_DATE,
                           ref.INSTALLMENT_NUMBER,
                           ref.INVOICE_CURRENCY_CODE,
                           ref.AMOUNT_APPLIED,
                           ref.AMOUNT_APPLIED_FROM,
                           ref.TRANS_TO_RECEIPT_RATE,
                           ref.TRANSMISSION_ID,
                           ref.BATCH_ID,
                           MOD( ref.CASH_RECEIPT_ID, :b_total_workers) + 1';

      l_from_clause := ' FROM   AR_CASH_REMIT_REFS ref
                                , AR_CASH_RECEIPTS cr ';

      l_where_clause := ' WHERE  ref.auto_applied           = ''N''
                          AND    ref.manually_applied       = ''N''
                          AND    ref.resolved_matching_number = ''NULL''
                          AND    ref.invoice_reference          IS NOT NULL
                          AND    cr.cash_receipt_id         = ref.cash_receipt_id ';

      IF p_called_from = 'ARCABP' and NVL(p_transmission_id, -1) > 0 THEN
      /* Called From Lockbox */
      l_from_clause := l_from_clause || ', ar_batches bat ';
      l_where_clause := l_where_clause ||
                        ' AND    ref.batch_id          = bat.batch_id
			                    AND 	 bat.transmission_id   = :b_transmission_id ';

      ELSIF p_called_from = 'ARCABP' and NVL(p_transmission_id, -1) <= 0 THEN
      /* Called From QuickCash */
      l_where_clause := l_where_clause ||
                        ' AND    ref.batch_id                 = :b_batch_id ';
      ELSE /* Called From Concurrent Program */
          IF p_receipt_no_l IS NOT NULL THEN
              l_where_clause := l_where_clause || ' AND cr.receipt_number >= :b_receipt_no_l ';
          END IF;
          IF p_receipt_no_h IS NOT NULL THEN
              l_where_clause := l_where_clause || ' AND cr.receipt_number <= :b_receipt_no_h ';
          END IF;
          IF p_batch_name_l IS NOT NULL THEN
              l_where_clause := l_where_clause || ' AND bat.name >= :b_batch_name_l ';
              l_use_bat := 'Y';
          END IF;
          IF p_batch_name_h IS NOT NULL THEN
              l_where_clause := l_where_clause || ' AND bat.name <= :b_batch_name_h ';
              l_use_bat := 'Y';
          END IF;
          IF p_min_unapp_amt IS NOT NULL THEN
              l_from_clause := l_from_clause || ' , AR_PAYMENT_SCHEDULES ps ';
              l_where_clause := l_where_clause || ' AND ps.amount_due_remaining * -1 >= :b_min_unapp_amt
                                  AND ps.cash_receipt_id = ref.cash_receipt_id ';
          END IF;
          IF p_receipt_date_l IS NOT NULL THEN
              l_receipt_date_low := fnd_date.canonical_to_date(p_receipt_date_l);
              l_where_clause := l_where_clause || ' AND cr.receipt_date >= :b_receipt_date_l ';
          END IF;
          IF p_receipt_date_h IS NOT NULL THEN
              l_receipt_date_high := fnd_date.canonical_to_date(p_receipt_date_h);
              l_where_clause := l_where_clause || ' AND cr.receipt_date <= :b_receipt_date_h ';
          END IF;
          IF p_receipt_method_l IS NOT NULL THEN
              l_where_clause := l_where_clause || ' AND rm.name >= :b_receipt_method_l ';
              l_use_rm := 'Y';
          END IF;
          IF p_receipt_method_h IS NOT NULL THEN
              l_where_clause := l_where_clause || ' AND rm.name <= :b_receipt_method_h ';
              l_use_rm := 'Y';
          END IF;
          IF p_customer_name_l IS NOT NULL THEN
              l_where_clause := l_where_clause || ' AND party.party_name >= :b_customer_name_l ';
              l_use_party := 'Y';
          END IF;
          IF p_customer_name_h IS NOT NULL THEN
              l_where_clause := l_where_clause || ' AND party.party_name <= :b_customer_name_h ';
              l_use_party := 'Y';
          END IF;
          IF p_customer_no_l IS NOT NULL THEN
              l_where_clause := l_where_clause || ' AND cust.account_number >= :b_customer_no_l ';
              l_use_cust := 'Y';
          END IF;
          IF p_customer_no_h IS NOT NULL THEN
              l_where_clause := l_where_clause || ' AND cust.account_number <= :b_customer_no_h ';
              l_use_cust := 'Y';
          END IF;
          IF l_use_rm = 'Y' THEN
              l_from_clause := l_from_clause || ' , AR_RECEIPT_METHODS rm ';
              l_where_clause := l_where_clause || ' AND cr.receipt_method_id = rm.receipt_method_id ';
          END IF;
          IF l_use_bat = 'Y' THEN
              l_from_clause := l_from_clause || ' , AR_BATCHES bat
                                                  , AR_CASH_RECEIPT_HISTORY crh ';
              l_where_clause := l_where_clause || ' AND bat.batch_id = crh.batch_id
                                      AND crh.cash_receipt_id = ref.cash_receipt_id ';
          END IF;
          IF l_use_cust = 'Y' THEN
              l_from_clause := l_from_clause || ' , HZ_CUST_ACCOUNTS cust ';
              l_where_clause := l_where_clause || ' AND cust.cust_account_id = NVL(ref.customer_id, cr.pay_from_customer)';
          END IF;
          IF l_use_party = 'Y' THEN
              IF l_use_cust = 'Y' THEN
                  l_from_clause := l_from_clause || ' , HZ_PARTIES party ';
                  l_where_clause := l_where_clause ||
                                     'AND party.party_id = cust.party_id ';
              ELSE
                  l_from_clause := l_from_clause || ' , HZ_CUST_ACCOUNTS cust
                                                      , HZ_PARTIES party ';
                  l_where_clause := l_where_clause ||
                                     ' AND party.party_id = cust.party_id
                                       AND cust.cust_account_id = NVL(ref.customer_id, cr.pay_from_customer)';
              END IF;
          END IF;
      END IF;

      l_insert_stmt := l_insert_stmt || l_from_clause || l_where_clause;
      log('Insert Statement : ' || l_insert_stmt);
      insert_gt := dbms_sql.open_cursor;
      dbms_sql.parse (insert_gt,l_insert_stmt,dbms_sql.v7);

      dbms_sql.bind_variable ( insert_gt, ':b_total_workers', p_total_workers);
      IF p_called_from = 'ARCABP' and NVL(p_transmission_id, -1) > 0 THEN
      dbms_sql.bind_variable ( insert_gt, ':b_transmission_id', p_transmission_id);
      ELSIF p_called_from = 'ARCABP' and NVL(p_transmission_id, -1) <= 0 THEN
      dbms_sql.bind_variable ( insert_gt, ':b_batch_id', p_batch_id);
      ELSE
      IF p_receipt_no_l IS NOT NULL THEN
          dbms_sql.bind_variable ( insert_gt, ':b_receipt_no_l', p_receipt_no_l);
      END IF;
      IF p_receipt_no_h IS NOT NULL THEN
          dbms_sql.bind_variable ( insert_gt, ':b_receipt_no_h', p_receipt_no_h);
      END IF;
      IF p_batch_name_l IS NOT NULL THEN
          dbms_sql.bind_variable ( insert_gt, ':b_batch_name_l', p_batch_name_l);
      END IF;
      IF p_batch_name_h IS NOT NULL THEN
          dbms_sql.bind_variable ( insert_gt, ':b_batch_name_h', p_batch_name_h);
      END IF;
      IF p_min_unapp_amt IS NOT NULL THEN
          dbms_sql.bind_variable ( insert_gt, ':b_min_unapp_amt', p_min_unapp_amt);
      END IF;
      IF p_receipt_date_l IS NOT NULL THEN
          dbms_sql.bind_variable ( insert_gt, ':b_receipt_date_l', l_receipt_date_low);
      END IF;
      IF p_receipt_date_h IS NOT NULL THEN
          dbms_sql.bind_variable ( insert_gt, ':b_receipt_date_h', l_receipt_date_high);
      END IF;
      IF p_receipt_method_l IS NOT NULL THEN
          dbms_sql.bind_variable ( insert_gt, ':b_receipt_method_l', p_receipt_method_l);
      END IF;
      IF p_receipt_method_h IS NOT NULL THEN
          dbms_sql.bind_variable ( insert_gt, ':b_receipt_method_h', p_receipt_method_h);
      END IF;
      IF p_customer_name_l IS NOT NULL THEN
          dbms_sql.bind_variable ( insert_gt, ':b_customer_name_l', p_customer_name_l);
      END IF;
      IF p_customer_name_h IS NOT NULL THEN
          dbms_sql.bind_variable ( insert_gt, ':b_customer_name_h', p_customer_name_h);
      END IF;
      IF p_customer_no_l IS NOT NULL THEN
          dbms_sql.bind_variable ( insert_gt, ':b_customer_no_l', p_customer_no_l);
      END IF;
      IF p_customer_no_h IS NOT NULL THEN
          dbms_sql.bind_variable ( insert_gt, ':b_customer_no_h', p_customer_no_h);
      END IF;
      END IF;

      l_rows_inserted := dbms_sql.execute( insert_gt);

      /* * Mark the rows with status 'AR_AA_RULE_SET_INACTIVE'  if the  *
         * rule set provided in the receipt is not active as per the    *
         * receipt date. These references will not be processed further *
         * by the Automatic Cash Application Program                    * */

      UPDATE  ar_cash_remit_refs_interim cri
      SET     cri.receipt_reference_status = 'AR_AA_RULE_SET_INACTIVE'
      WHERE   cri.cash_receipt_id IN (
      SELECT  distinct cr.cash_receipt_id
      FROM    ar_cash_remit_refs_interim cri1,
              ar_cash_auto_rule_sets aca,
              ar_cash_receipts cr
      WHERE cr.cash_receipt_id = cri1.cash_receipt_id
      AND   cr.automatch_set_id = aca.automatch_set_id
      AND   (cr.receipt_date < NVL(aca.start_date, cr.receipt_date)
            OR cr.receipt_date > NVL(aca.end_date, to_date('31/12/4712','DD/MM/YYYY'))
            OR NVL(aca.active_flag, 'N') = 'N')
      )
      AND   cri.receipt_reference_status = 'AR_AM_NEW';

      /* * Mark references with status 'AR_AA_AUTOAPPLY_NOT_SET' if auto  *
         * match set id is not present in both receipt and reference info * */
      UPDATE  ar_cash_remit_refs_interim
      SET     receipt_reference_status = 'AR_AA_RULE_SET_NOT_PASSED'
      WHERE   automatch_set_id IS NULL
      AND     receipt_reference_status = 'AR_AM_NEW';

      UPDATE  ar_cash_remit_refs_interim
      SET     receipt_reference_status = 'AR_AA_AMT_NOT_PASSED'
      WHERE   amount_applied IS NULL
      AND     amount_applied_from IS NULL
      AND     receipt_reference_status = 'AR_AM_NEW';

      /* * Delete Suggestions for the references that will be processed in *
         * the current run. This is to avoid duplicate recommendations     *
         * getting generated and to handle the cases where a refernce no is*
         * changed after the previous run. Refer bug 8396831               * */

      DELETE FROM ar_cash_reco_lines lines
      WHERE EXISTS (
      SELECT 'Suggestion Exists'
      FROM ar_cash_recos rec, ar_cash_remit_refs_interim ref
      WHERE rec.recommendation_id = lines.recommendation_id
      AND   rec.remit_reference_id = ref.remit_reference_id
      AND   ref.receipt_reference_status = 'AR_AM_NEW'
      );

      DELETE FROM ar_cash_recos rec
      WHERE EXISTS(
      SELECT 'Suggestion Exists'
      FROM ar_cash_remit_refs_interim ref
      WHERE rec.remit_reference_id = ref.remit_reference_id
      AND   ref.receipt_reference_status = 'AR_AM_NEW'
      );

      commit;

      IF p_total_workers > 1 THEN
        FOR l_worker_number IN 1..p_total_workers LOOP
          	log('worker # : ' || l_worker_number );
          	submit_subrequest (l_worker_number,p_org_id);
        END LOOP;

        IF PG_DEBUG in ('Y', 'C') THEN
    	       log ( 'The Master program waits for child processes');
        END IF;

        -- Wait for the completion of the submitted requests
        FOR i in 1..p_total_workers LOOP

          l_complete := FND_CONCURRENT.WAIT_FOR_REQUEST(
          request_id   => l_req_status_tab(i).request_id,
          interval     => 30,
          max_wait     => 144000,
          phase        => l_req_status_tab(i).phase,
          status       => l_req_status_tab(i).status,
          dev_phase    => l_req_status_tab(i).dev_phase,
          dev_status   => l_req_status_tab(i).dev_status,
          message      => l_req_status_tab(i).message);

          IF l_req_status_tab(i).dev_phase <> 'COMPLETE' THEN
            P_RETCODE := 2;
            log('Worker # '|| i||' has a phase '||l_req_status_tab(i).dev_phase);
          ELSIF l_req_status_tab(i).dev_phase = 'COMPLETE'
               AND l_req_status_tab(i).dev_status <> 'NORMAL' THEN
            P_RETCODE := 2;
            log('Worker # '|| i||' completed with status '||l_req_status_tab(i).dev_status);
          ELSE
            log('Worker # '|| i||' completed successfully');
          END IF;

        END LOOP;

        log('Return Code : ' || p_retcode);

        IF NVL( p_retcode, -1) = 2 THEN
    	     log(' - Child program failed.' );
        ELSE
    	     log(' - Child programs completed successfully' );
        END IF;

      ELSE
        auto_apply_child(l_errbuf, l_retcode, p_total_workers);
      END IF;
      /* * AutoCash Application Process Completed. Now update the receipt_   *
         * reference_status for the unapplied references with either No Match*
         * Found or Suggestions found based on recommendations generated     * */
      UPDATE ar_cash_remit_refs_interim cri
      SET cri.receipt_reference_status = DECODE(
                   ( SELECT 'MATCH_FOUND'
                     FROM ar_cash_recos
                     WHERE remit_reference_id = cri.remit_reference_id
                     AND rownum = 1 ),'MATCH_FOUND','AR_AA_SUGG_FOUND','AR_AA_NO_MATCH')
      WHERE cri.receipt_reference_status = 'AR_AM_NEW';

      UPDATE  ar_cash_remit_refs crr
      SET     crr.receipt_reference_status = (SELECT cri.receipt_reference_status
      FROM    ar_cash_remit_refs_interim cri
      WHERE   crr.remit_reference_id = cri.remit_reference_id
      AND     cri.receipt_reference_status IN ('AR_AA_SUGG_FOUND', 'AR_AA_NO_MATCH', 'AR_AA_RULE_SET_INACTIVE', 'AR_AA_RULE_SET_NOT_PASSED', 'AR_AA_AMT_NOT_PASSED'))
      WHERE   crr.remit_reference_id IN (SELECT cri.remit_reference_id
      FROM    ar_cash_remit_refs_interim cri
      WHERE   crr.remit_reference_id = cri.remit_reference_id
      AND     cri.receipt_reference_status IN ('AR_AA_SUGG_FOUND', 'AR_AA_NO_MATCH', 'AR_AA_RULE_SET_INACTIVE', 'AR_AA_RULE_SET_NOT_PASSED', 'AR_AA_AMT_NOT_PASSED'))
      AND     crr.receipt_reference_status <> 'AR_AA_INV_APPLIED';

      /* * If a receipt has any unapplied remittance line, update the        *
         * receipt work_item_exception_reason with the exception reason      *
         * defined at the AutoMatchRule Setup                                * */
      UPDATE ar_cash_receipts_all cr
      SET WORK_ITEM_EXCEPTION_REASON =
      (SELECT exception_reason
      FROM ar_cash_auto_rule_sets
      WHERE automatch_set_id = cr.automatch_set_id)
      WHERE cash_receipt_id IN
      (SELECT distinct cash_receipt_id
      FROM ar_cash_remit_refs_interim cri
      WHERE receipt_reference_status IN ('AR_AA_NO_MATCH','AR_AA_SUGG_FOUND')
      );

      COMMIT;

      IF (PG_DEBUG IN ('Y', 'C')) THEN
          log('arp_autoapply_api.auto_apply_master(-)');
      END IF;
      EXCEPTION
      WHEN OTHERS THEN
          log('Exception from arp_autoapply_api.auto_apply_master');
          log(SQLERRM);
          RAISE;

  END  auto_apply_master;

/*===========================================================================+
 * PROCEDURE                                                                 *
 *     AUTO_APPLY_CHILD()                                                    *
 * DESCRIPTION                                                               *
 *   Automatic Cash Application Child program                                *
 * SCOPE - PUBLIC                                                            *
 * ARGUMENTS                                                                 *
 *              IN  : p_worker_number Worker Number                          *
 *              OUT : NONE                                                   *
 *                                                                           *
 * RETURNS      NONE                    				                             *
 * ALGORITHM                                                                 *
 *   1. Fetch distinct Automatch Set Identifiers associated to the receipts  *
 *      allocated for the current worker.                                    *
 *   2. Fetch active Automatch Rules associated with each Automatch Sets.    *
 *   3. For each Automatch Set                                               *
 *        For each active Automatch Rule inside a rule set                   *
 *           Check if the rule is already processed (refer Notes below)      *
 *             If processed Skip. Proceed with next rule.                    *
 *             Else                                                          *
 *              Generate String Transformations.                             *
 *              Create recommendations based on Match_By option.             *
 *   4. Validate the recommendations generated.                              *
 *   5. Apply the valid recommendations.                                     *
 * NOTES -                                                                   *
 *   1. The check if a rule is active wrt receipt date is made while inserting
 *      recommendations.                                                     *
 *   2. Recommendations are inserted once per each automatch rule. Meaning if*
 *      a rule R1 is part of two sets S1, S2 and suppose we are processing S1*
 *      first, then for all the references that have either S1 or S2 as rule *
 *      sets recommendations for the rule R1 are generated while processing S1
 *      itself. So there is no need to insert recommendations again while    *
 *      processing S2. Hence whenever a rule is fetched for a rule set, first*
 *      check is made to see if the rule is already processed as part of any *
 *      other rule set.                                                      *
 * MODIFICATION HISTORY -  09/03/2009 - Created by AGHORAKA	     	           *
 *                                                                           *
 +===========================================================================*/

  PROCEDURE auto_apply_child( P_ERRBUF OUT NOCOPY VARCHAR2
                              , P_RETCODE OUT NOCOPY NUMBER
                              , p_worker_number IN NUMBER) IS
      CURSOR  auto_rule_set_cur(p_worker_number IN NUMBER) IS
          SELECT distinct automatch_set_id
          FROM   AR_CASH_REMIT_REFS_INTERIM
          WHERE  worker_number = p_worker_number
          AND    receipt_reference_status = 'AR_AM_NEW';

      CURSOR  auto_rule_cursor(p_automatch_set_id IN NUMBER) IS
          SELECT  aca.automatch_id automatch_id,
                  aca.matching_option matching_option,
                  NVL(aca.use_matching_date, 'N') use_matching_date
          FROM    AR_CASH_AUTOMATCHES aca,
                  AR_CASH_AUTOMATCH_RULE_MAP acm
          WHERE   acm.automatch_set_id = p_automatch_set_id
          AND     aca.automatch_id = acm.automatch_id
          AND     NVL(aca.active_flag, 'N') = 'Y'
          ORDER BY acm.priority;

      l_worker_number     NUMBER;
      l_automatch_set_id  NUMBER;
      l_automatch_id      NUMBER;
      l_matching_option   VARCHAR2(30);
      l_use_matching_date VARCHAR2(10);
      l_trans_format_str  VARCHAR2(1000);
      l_trans_float_str   VARCHAR2(1000);
      l_rem_format_str    VARCHAR2(1000);
      l_rem_float_str     VARCHAR2(1000);
      p_request_id        NUMBER := -1;
  BEGIN
      IF (PG_DEBUG IN ('Y', 'C')) THEN
          log('arp_autoapply_api.auto_apply_child(+)');
          log('Worker Number : ' || p_worker_number);
      END IF;
      l_worker_number := p_worker_number;
      p_request_id    := arp_standard.profile.request_id;

      FOR auto_rule_set_var in auto_rule_set_cur(l_worker_number)
      LOOP
          l_automatch_set_id := auto_rule_set_var.automatch_set_id;
          FOR auto_rule_var in auto_rule_cursor(l_automatch_set_id)
          LOOP
              l_automatch_id := auto_rule_var.automatch_id;
              l_matching_option := auto_rule_var.matching_option;
              l_use_matching_date := auto_rule_var.use_matching_date;

              IF NOT is_rule_processed (l_automatch_id) THEN
                gen_str_transformations(p_rule_id => l_automatch_id
                                        , x_trans_format_str => l_trans_format_str
                                        , x_rem_format_str => l_rem_format_str
                                        , x_trans_float_str => l_trans_float_str
                                        , x_rem_float_str => l_rem_float_str );
                IF l_matching_option = 'INVOICE' THEN
                    insert_invoice_recos(l_automatch_id,
                                         l_use_matching_date,
                                         l_trans_format_str,
                                         l_rem_format_str,
                                         l_trans_float_str,
                                         l_rem_float_str,
                                         l_worker_number,
                                         p_request_id);
                ELSIF l_matching_option = 'SALES_ORDER' THEN
                    insert_so_recos(l_automatch_id,
                                         l_use_matching_date,
                                         l_trans_format_str,
                                         l_rem_format_str,
                                         l_trans_float_str,
                                         l_rem_float_str,
                                         l_worker_number,
                                         p_request_id);
                ELSIF l_matching_option = 'PURCHASE_ORDER' THEN
                    insert_po_recos(l_automatch_id,
                                         l_use_matching_date,
                                         l_trans_format_str,
                                         l_rem_format_str,
                                         l_trans_float_str,
                                         l_rem_float_str,
                                         l_worker_number,
                                         p_request_id);
                ELSIF l_matching_option = 'CONSOLIDATE_BILL' THEN
                    insert_bfb_recos(l_automatch_id,
                                         l_use_matching_date,
                                         l_trans_format_str,
                                         l_rem_format_str,
                                         l_trans_float_str,
                                         l_rem_float_str,
                                         l_worker_number,
                                         p_request_id);
                ELSIF l_matching_option = 'WAY_BILL' THEN
                    insert_waybill_recos(l_automatch_id,
                                         l_use_matching_date,
                                         l_trans_format_str,
                                         l_rem_format_str,
                                         l_trans_float_str,
                                         l_rem_float_str,
                                         l_worker_number,
                                         p_request_id);
                ELSIF substr(l_matching_option, 1, 11) = 'INT_HDR_ATT' THEN
                    insert_attribute_recos(l_automatch_id,
                                         l_use_matching_date,
                                         l_trans_format_str,
                                         l_rem_format_str,
                                         l_trans_float_str,
                                         l_rem_float_str,
                                         l_worker_number,
                                         substr(l_matching_option, 12),
                                         p_request_id);
                ELSIF l_matching_option = 'SERVICE_CONTRACT' THEN
                    insert_contract_recos(l_automatch_id,
                                         l_use_matching_date,
                                         l_trans_format_str,
                                         l_rem_format_str,
                                         l_trans_float_str,
                                         l_rem_float_str,
                                         l_worker_number,
                                         p_request_id);
                ELSIF l_matching_option = 'REFERENCE_NUMBER' THEN
                    insert_reference_recos(l_automatch_id,
                                         l_use_matching_date,
                                         l_trans_format_str,
                                         l_rem_format_str,
                                         l_trans_float_str,
                                         l_rem_float_str,
                                         l_worker_number,
                                         p_request_id);
                END IF;
              END IF;
          END LOOP;
      END LOOP;
      validate_trx_recos(p_request_id, p_worker_number);

      apply_trx_recos(p_request_id, p_worker_number);

      IF (PG_DEBUG IN ('Y', 'C')) THEN
          log('arp_autoapply_api.auto_apply_child(-)');
      END IF;
      EXCEPTION
      WHEN OTHERS THEN
          log('Exception from arp_autoapply_api.auto_apply_main');
          log(SQLERRM);
          RAISE;
  END auto_apply_child;

/*===========================================================================+
 * PROCEDURE                                                                 *
 *     INSERT_INVOICE_RECOS()                                                *
 * DESCRIPTION                                                               *
 *   Inserts recommendations for transaction numbers                         *
 * SCOPE - LOCAL                                                             *
 * ARGUMENTS                                                                 *
 *              IN  : p_automatch_id Automatch Rule Identifier               *
 *                    p_use_matching_date Use Matching Date [ALWAYS/For      *
 *                    Duplicates/NULL]                                       *
 *                    p_trans_format_str Transaction Number Format String    *
 *                    p_rem_format_str Reference Number Format String        *
 *                    p_worker_number Current Worker Number                  *
 *                    p_request_id Request ID                                *
 *              OUT : None                                                   *
 *                                                                           *
 * RETURNS      NONE                    				                             *
 * ALGORITHM                                                                 *
 *   1. For all open transactions satisfying all the setup conditions calculate
 *      the matching score of transaction number with the reference number   *
 *      given in the remittance lines (ar_cash_remit_refs_all)               *
 *   2. If match_score > suggested threshold value specified at the AutoMatch*
 *      setup, insert into ar_cash_recos, ar_cash_reco_lines as a recommenda *
 *      -tion.                                                               *
 * NOTES -                                                                   *
 *   1. Tables with _ALL is used in INSERT statement as multi-table insert is*
 *      not possible on secured synonyms (ar_cash_recos and ar_cash_reco_lines)
 *   2. If pay_unrelated_customer is set to 'Yes' or the reference/receipt is*
 *      unidentified then transactions for all the customers are considered. *
 *      Otherwise only the transactions related to the paying customer of the*
 *      receipt are considered.                                              *
 *   3. An invoice can have multiple installments; which means there is a    *
 *      possibility that the receipt is applied against multiple payment     *
 *      schedules for the same transaction. ar_cash_recos contains header    *
 *      level information like resolved number(trx number), trx date etc.,   *
 *      where as ar_cash_reco_lines contains the sepecific ps information for*
 *      the resolved transaction.                                            *
 *                                                                           *
 * MODIFICATION HISTORY -  09/03/2009 - Created by AGHORAKA	     	           *
 *                                                                           *
 +===========================================================================*/

  PROCEDURE insert_invoice_recos (p_automatch_id IN NUMBER
                                  , p_use_matching_date IN VARCHAR2
                                  , p_trans_format_str IN VARCHAR2
                                  , p_rem_format_str  IN VARCHAR2
                                  , p_trans_float_str IN VARCHAR2
                                  , p_rem_float_str IN VARCHAR2
                                  , p_worker_number IN NUMBER
                                  , p_request_id IN NUMBER) IS
  CURSOR select_recos IS
        SELECT         ref.remit_reference_id remit_reference_id,
                       ref.amount_applied ref_amount_applied,
                       ref.amount_applied_from ref_amount_applied_from,
                       ref.trans_to_receipt_rate ref_trans_to_receipt_rate,
                       ref.cash_receipt_id cash_receipt_id,
                       cr.pay_from_customer pay_from_customer,
                       cr.customer_site_use_id cr_customer_site_use_id,
                       ps.customer_trx_id customer_trx_id,
                       ps.customer_id customer_id,
                       ps.customer_site_use_id customer_site_use_id,
                       ps.trx_number resolved_matching_number,
                       ps.terms_sequence_number terms_sequence_number,
                       decode(am.match_date_by,
                        'INT_HDR_ATT1', fnd_conc_date.string_to_date(trx.interface_header_attribute1),
                        'INT_HDR_ATT10', fnd_conc_date.string_to_date(trx.interface_header_attribute10),
                        'INT_HDR_ATT11', fnd_conc_date.string_to_date(trx.interface_header_attribute11),
                        'INT_HDR_ATT12', fnd_conc_date.string_to_date(trx.interface_header_attribute12),
                        'INT_HDR_ATT13', fnd_conc_date.string_to_date(trx.interface_header_attribute13),
                        'INT_HDR_ATT14', fnd_conc_date.string_to_date(trx.interface_header_attribute14),
                        'INT_HDR_ATT15', fnd_conc_date.string_to_date(trx.interface_header_attribute15),
                        'INT_HDR_ATT2', fnd_conc_date.string_to_date(trx.interface_header_attribute2),
                        'INT_HDR_ATT3', fnd_conc_date.string_to_date(trx.interface_header_attribute3),
                        'INT_HDR_ATT4', fnd_conc_date.string_to_date(trx.interface_header_attribute4),
                        'INT_HDR_ATT5', fnd_conc_date.string_to_date(trx.interface_header_attribute5),
                        'INT_HDR_ATT6', fnd_conc_date.string_to_date(trx.interface_header_attribute6),
                        'INT_HDR_ATT7', fnd_conc_date.string_to_date(trx.interface_header_attribute7),
                        'INT_HDR_ATT8', fnd_conc_date.string_to_date(trx.interface_header_attribute8),
                        'INT_HDR_ATT9', fnd_conc_date.string_to_date(trx.interface_header_attribute9),
                        'PURCH_ORDER_DATE', trx.purchase_order_date,
                        'TRANS_DATE', trx.trx_date,
                        NULL)  resolved_matching_date,
                       ps.trx_date trx_date,
                       ps.class resolved_matching_class,
                       ps.invoice_currency_code resolved_match_currency,
                       ps.amount_due_original amount_due_original,
                       ps.amount_due_remaining amount_due_remaining,
                       ps.discount_taken_earned discount_taken_earned,
                       ps.discount_taken_unearned discount_taken_unearned,
                       ARPCURR.CURRROUND(ps.amount_due_remaining, ps.invoice_currency_code ) amount_applied,
                       ROUND(NVL(ref.trans_to_receipt_rate,
                                 DECODE(ps.invoice_currency_code, cr.currency_code, NULL,
                                           NVL( ARP_AUTOAPPLY_API.get_cross_curr_rate(
                                                      ref.amount_applied,
                                                      ref.amount_applied_from,
                                                      ps.invoice_currency_code,
                                                      cr.currency_code
                                                      )
                                                , GL_CURRENCY_API.GET_RATE_SQL(
                                                        ps.invoice_currency_code,
                                                        cr.currency_code,
                                                        cr.receipt_date,
                                                       arp_standard.sysparm.CROSS_CURRENCY_RATE_TYPE )
                                              )
                                       )
                                ),38) trans_to_receipt_rate,
                       NULL amount_applied_from, -- will be calculated later for xcurr app.
                       ps.payment_schedule_id payment_schedule_id,
                       NULL cons_inv_id,         -- Not used here. Useful for BFBs. So null value selected.
                       UTL_MATCH.edit_distance_similarity(REGEXP_REPLACE(REGEXP_REPLACE(ps.trx_number, p_trans_format_str, '\2'), p_trans_float_str, ''),
                                                          REGEXP_REPLACE(REGEXP_REPLACE(ref.invoice_reference, p_rem_format_str, '\2'), p_rem_float_str, '')) match_score_value,
                       ps.org_id org_id,
                       ps.term_id term_id,
                       am.automatch_id automatch_id,
                       am.use_matching_date use_matching_date,
                       am.use_matching_amount use_matching_amount,
                       am.auto_match_threshold auto_match_threshold,
                       amp.priority priority,
                       cr.currency_code receipt_currency_code,
                       cr.receipt_date receipt_date,
                       ctt.allow_overapplication_flag allow_overapplication_flag,
                       tr.partial_discount_flag partial_discount_flag,
                       RANK() OVER (PARTITION BY ps.trx_number, ps.customer_site_use_id,
                                    ref.remit_reference_id, ps.customer_trx_id
                                    ORDER BY ps.payment_schedule_id) AS  reco_num
        FROM           ar_cash_automatches am,
                       ar_cash_automatch_rule_map amp,
                       ar_cash_remit_refs_interim ref,
                       ar_cash_receipts cr,
                       ar_payment_schedules ps,
                       ra_customer_trx trx,
                       ra_cust_trx_types ctt,
                       ra_terms tr
        WHERE          am.automatch_id               = p_automatch_id
        AND            amp.automatch_id              = am.automatch_id
        AND            amp.automatch_set_id          = ref.automatch_set_id
        AND            ref.worker_number             = p_worker_number
        AND            ref.receipt_reference_status  = 'AR_AM_NEW'
        AND            cr.cash_receipt_id            = ref.cash_receipt_id
        AND            cr.receipt_date BETWEEN NVL(am.start_date, cr.receipt_date)
                                       AND NVL(am.end_date, to_date('31/12/4712','DD/MM/YYYY'))
        AND            ps.trx_number IS NOT NULL
        AND            ps.selected_for_receipt_batch_id IS NULL
        AND            UTL_MATCH.edit_distance_similarity(REGEXP_REPLACE(REGEXP_REPLACE(ps.trx_number, p_trans_format_str, '\2'), p_trans_float_str, ''),
                                                          REGEXP_REPLACE(REGEXP_REPLACE(ref.invoice_reference, p_rem_format_str, '\2'), p_rem_float_str, '')) >= am.sugg_match_threshold
        AND            ps.class                     NOT IN ('PMT', 'GUAR')
        AND            ps.payment_schedule_id        > 0
        AND            ps.status                    = 'OP'
        AND            ps.terms_sequence_number     = NVL(ref.installment_reference,
                                                          ps.terms_sequence_number)
        AND            ps.customer_id IN (SELECT  DECODE(ARP_STANDARD.sysparm.pay_unrelated_invoices_flag,'Y', ps.customer_id,
                                                               NVL(cr.pay_from_customer, ps.customer_id))
                                          FROM    DUAL
                                          UNION   ALL
                                          SELECT  related_cust_account_id
                                          FROM    hz_cust_acct_relate_all rel
                                          WHERE   rel.cust_account_id = cr.pay_from_customer
                                          AND     rel.bill_to_flag    = 'Y'
                                          AND     rel.status          = 'A'
                                          AND     ARP_STANDARD.sysparm.pay_unrelated_invoices_flag <> 'Y'
                                          UNION   ALL
                                          SELECT  rel.related_cust_account_id
                                          FROM    ar_paying_relationships_v rel,
                                                  hz_cust_accounts acc
                                          WHERE   acc.cust_account_id = cr.pay_from_customer
                                          AND     acc.party_id        = rel.party_id
                                          AND     cr.receipt_date   >= effective_start_date
                                          AND     cr.receipt_date   <= effective_end_date
                                          AND     ARP_STANDARD.sysparm.pay_unrelated_invoices_flag <> 'Y' )
        AND           trx.customer_trx_id           = ps.customer_trx_id
        AND           tr.term_id(+)                 = ps.term_id
        AND           ps.cust_trx_type_id           = ctt.cust_trx_type_id;
    l_selected_recos              selected_recos_table;
    l_current_reco                selected_recos_table;
    l_current_fetch_count         NUMBER;
    l_outer_index                 NUMBER;
    l_current_reco_line           NUMBER;
    got_current_block             BOOLEAN;
  BEGIN
    IF (PG_DEBUG IN ('Y', 'C')) THEN
          log('arp_autoapply_api.insert_invoice_recos(+)');
          log('Auto Match ID :'||p_automatch_id);
          log('Worker Number :'||p_worker_number);
    END IF;
    OPEN select_recos;
    LOOP
      FETCH select_recos BULK COLLECT INTO l_selected_recos LIMIT G_MAX_ARRAY_SIZE;
      log('Count : '||l_selected_recos.COUNT);
      IF l_selected_recos.COUNT = 0 THEN
        IF l_current_reco.count > 0 THEN
          process_single_reco(l_current_reco
                              , 'INVOICE');
          l_current_reco.DELETE;
          insert_recos(p_request_id);
          clear_reco_lines_struct;
        END IF;
        EXIT;
      END IF;
      l_current_fetch_count := l_selected_recos.COUNT;
      l_outer_index := 1;
      LOOP
        IF l_outer_index > l_current_fetch_count THEN
          insert_recos(p_request_id);
          clear_reco_lines_struct;
          EXIT;
        END IF;
        got_current_block := FALSE;
        LOOP
          l_current_reco_line := l_current_reco.COUNT;
          IF l_current_reco_line = 0 THEN
            log('If Statement');
            copy_current_record(l_current_reco, l_selected_recos, l_outer_index);
            l_outer_index := l_outer_index + 1;
          ELSE
            IF l_current_reco(l_current_reco_line).reco_num < l_selected_recos(l_outer_index).reco_num THEN
              log('Else-If');
              copy_current_record(l_current_reco, l_selected_recos, l_outer_index);
              l_outer_index := l_outer_index + 1;
            ELSE
              log('Else-Else');
              got_current_block := TRUE;
            END IF;
          END IF;
          IF got_current_block = TRUE OR l_outer_index > l_current_fetch_count THEN
            EXIT;
          END IF;
        END LOOP;
        IF l_outer_index > l_current_fetch_count THEN
          insert_recos(p_request_id);
          clear_reco_lines_struct;
          EXIT;
        END IF;
        process_single_reco(l_current_reco
                            , 'INVOICE');
        l_current_reco.DELETE;
      END LOOP;
    END LOOP;

    IF (PG_DEBUG IN ('Y', 'C')) THEN
      log('arp_autoapply_api.insert_invoice_recos(-)');
    END IF;
    EXCEPTION
    WHEN OTHERS THEN
          log('Exception from arp_autoapply_api.insert_invoice_recos');
          log(SQLERRM);
          RAISE;
  END insert_invoice_recos;

/*===========================================================================+
 * PROCEDURE                                                                 *
 *     INSERT_PO_RECOS()                                                     *
 * DESCRIPTION                                                               *
 *   Inserts recommendations for Purchase Orders                             *
 * SCOPE - LOCAL                                                             *
 * ARGUMENTS                                                                 *
 *              IN  : p_automatch_id Automatch Rule Identifier               *
 *                    p_use_matching_date Use Matching Date [ALWAYS/For      *
 *                    Duplicates/NULL]                                       *
 *                    p_trans_format_str Transaction Number Format String    *
 *                    p_rem_format_str Reference Number Format String        *
 *                    p_worker_number Current Worker Number                  *
 *                    p_request_id Request ID                                *
 *              OUT : None                                                   *
 *                                                                           *
 * RETURNS      NONE                    				                             *
 * ALGORITHM                                                                 *
 *   1. For all open POs satisfying all the setup conditions calculate       *
 *      the matching score of purchase order number with the reference number*
 *      given in the remittance lines (ar_cash_remit_refs_all)               *
 *   2. If match_score > suggested threshold value specified at the AutoMatch*
 *      setup, insert into ar_cash_recos, ar_cash_reco_lines as a recommenda *
 *      -tion.                                                               *
 * NOTES -                                                                   *
 *   1. Tables with _ALL is used in INSERT statement as multi-table insert is*
 *      not possible on secured synonyms (ar_cash_recos and ar_cash_reco_lines)
 *   2. If pay_unrelated_customer is set to 'Yes' or the reference/receipt is*
 *      unidentified then transactions for all the customers are considered. *
 *      Otherwise only the transactions related to the paying customer of the*
 *      receipt are considered.                                              *
 *   3. A PO can have multiple invoices; which means there is a possibility  *
 *      that the receipt is applied against multiple payment schedules for   *
 *      the same transaction. ar_cash_recos contains header level information*
 *      level information like resolved number(purchase order)etc.,          *
 *      where as ar_cash_reco_lines contains the sepecific ps information for*
 *      the resolved transaction.                                            *
 *                                                                           *
 * MODIFICATION HISTORY -  09/03/2009 - Created by AGHORAKA	     	           *
 *                                                                           *
 +===========================================================================*/

  PROCEDURE insert_po_recos (p_automatch_id IN NUMBER
                            , p_use_matching_date IN VARCHAR2
                            , p_trans_format_str IN VARCHAR2
                            , p_rem_format_str  IN VARCHAR2
                            , p_trans_float_str IN VARCHAR2
                            , p_rem_float_str IN VARCHAR2
                            , p_worker_number IN NUMBER
                            , p_request_id IN NUMBER) IS
  CURSOR select_recos IS
    SELECT         ref.remit_reference_id remit_reference_id,
                         ref.amount_applied ref_amount_applied,
                         ref.amount_applied_from ref_amount_applied_from,
                         ref.trans_to_receipt_rate ref_trans_to_receipt_rate,
                         ref.cash_receipt_id cash_receipt_id,
                         cr.pay_from_customer pay_from_customer,
                         cr.customer_site_use_id cr_customer_site_use_id,
                         ps.customer_trx_id customer_trx_id,
                         ps.customer_id,
                         ps.customer_site_use_id customer_site_use_id,
                         trx.purchase_order resolved_matching_number,
                         ps.terms_sequence_number terms_sequence_number,
                         decode(am.match_date_by,
                                'INT_HDR_ATT1', fnd_conc_date.string_to_date(trx.interface_header_attribute1),
                                'INT_HDR_ATT10', fnd_conc_date.string_to_date(trx.interface_header_attribute10),
                                'INT_HDR_ATT11', fnd_conc_date.string_to_date(trx.interface_header_attribute11),
                                'INT_HDR_ATT12', fnd_conc_date.string_to_date(trx.interface_header_attribute12),
                                'INT_HDR_ATT13', fnd_conc_date.string_to_date(trx.interface_header_attribute13),
                                'INT_HDR_ATT14', fnd_conc_date.string_to_date(trx.interface_header_attribute14),
                                'INT_HDR_ATT15', fnd_conc_date.string_to_date(trx.interface_header_attribute15),
                                'INT_HDR_ATT2', fnd_conc_date.string_to_date(trx.interface_header_attribute2),
                                'INT_HDR_ATT3', fnd_conc_date.string_to_date(trx.interface_header_attribute3),
                                'INT_HDR_ATT4', fnd_conc_date.string_to_date(trx.interface_header_attribute4),
                                'INT_HDR_ATT5', fnd_conc_date.string_to_date(trx.interface_header_attribute5),
                                'INT_HDR_ATT6', fnd_conc_date.string_to_date(trx.interface_header_attribute6),
                                'INT_HDR_ATT7', fnd_conc_date.string_to_date(trx.interface_header_attribute7),
                                'INT_HDR_ATT8', fnd_conc_date.string_to_date(trx.interface_header_attribute8),
                                'INT_HDR_ATT9', fnd_conc_date.string_to_date(trx.interface_header_attribute9),
                                'PURCH_ORDER_DATE', trx.purchase_order_date,
                                'TRANS_DATE', trx.trx_date, NULL)  resolved_matching_date,
                         ps.trx_date trx_date,
                         ps.class resolved_matching_class,
                         trx.invoice_currency_code resolved_match_currency,
                         ps.amount_due_original amount_due_original,
                         ps.amount_due_remaining amount_due_remaining,
                         ps.discount_taken_earned discount_taken_earned,
                         ps.discount_taken_unearned discount_taken_unearned,
                         ARPCURR.CURRROUND(ps.amount_due_remaining, ps.invoice_currency_code ) amount_applied,
                         ROUND(NVL(ref.trans_to_receipt_rate,
                                 DECODE(ps.invoice_currency_code, cr.currency_code, NULL,
                                           NVL( ARP_AUTOAPPLY_API.get_cross_curr_rate(
                                                      ref.amount_applied,
                                                      ref.amount_applied_from,
                                                      ps.invoice_currency_code,
                                                      cr.currency_code
                                                      )
                                                , GL_CURRENCY_API.GET_RATE_SQL(
                                                        ps.invoice_currency_code,
                                                        cr.currency_code,
                                                        cr.receipt_date,
                                                       arp_standard.sysparm.CROSS_CURRENCY_RATE_TYPE )
                                              )
                                       )
                                ),38) trans_to_receipt_rate,
                         NULL amount_applied_from, -- will be calculated later for xcurr app.
                         ps.payment_schedule_id,
                         NULL cons_inv_id,         -- Not used here. Useful for BFBs. So null value selected.
                         UTL_MATCH.edit_distance_similarity(REGEXP_REPLACE(REGEXP_REPLACE(trx.purchase_order, p_trans_format_str, '\2'), p_trans_float_str, ''),
                                                            REGEXP_REPLACE(REGEXP_REPLACE(ref.invoice_reference, p_rem_format_str, '\2'), p_rem_float_str, '')) match_score_value,
                         ps.org_id,
                         ps.term_id term_id,
                         am.automatch_id,
                         am.use_matching_date use_matching_date,
                         am.use_matching_amount use_matching_amount,
                         am.auto_match_threshold auto_match_threshold,
                         amp.priority priority,
                         cr.currency_code receipt_currency_code,
                         cr.receipt_date,
                         ctt.allow_overapplication_flag allow_overapplication_flag,
                         tr.partial_discount_flag partial_discount_flag,
                         RANK() OVER (PARTITION BY trx.purchase_order, ps.customer_site_use_id,
                                      ref.remit_reference_id, ps.customer_trx_id
                              ORDER BY ps.payment_schedule_id) AS  reco_num
          FROM           ar_cash_automatches am,
                         ar_cash_automatch_rule_map amp,
                         ar_cash_remit_refs_interim ref,
                         ar_cash_receipts cr,
                         ra_customer_trx trx,
                         ar_payment_schedules ps,
                         ra_cust_trx_types ctt,
                         ra_terms tr
          WHERE          am.automatch_id               = p_automatch_id
          AND            amp.automatch_id              = am.automatch_id
          AND            amp.automatch_set_id          = ref.automatch_set_id
          AND            ref.worker_number             = p_worker_number
          AND            ref.receipt_reference_status  = 'AR_AM_NEW'
          AND            cr.cash_receipt_id            = ref.cash_receipt_id
          AND            cr.receipt_date BETWEEN NVL(am.start_date, cr.receipt_date)
                                         AND NVL(am.end_date, to_date('31/12/4712','DD/MM/YYYY'))
          AND            trx.purchase_order              IS NOT NULL
          AND            UTL_MATCH.edit_distance_similarity(REGEXP_REPLACE(REGEXP_REPLACE(trx.purchase_order, p_trans_format_str, '\2'), p_trans_float_str, ''),
                                                            REGEXP_REPLACE(REGEXP_REPLACE(ref.invoice_reference, p_rem_format_str, '\2'), p_rem_float_str, '')) >= am.sugg_match_threshold
          AND            ps.customer_trx_id            = trx.customer_trx_id
          AND            ps.selected_for_receipt_batch_id IS NULL
          AND            ps.class                     NOT IN ('PMT', 'GUAR')
          AND            ps.payment_schedule_id        > 0
          AND            ps.status                      = 'OP'
          AND            ps.customer_id IN (SELECT  DECODE(ARP_STANDARD.sysparm.pay_unrelated_invoices_flag,'Y', ps.customer_id,
                                                                 NVL(cr.pay_from_customer, ps.customer_id))
                                            FROM    DUAL
                                            UNION   ALL
                                            SELECT  related_cust_account_id
                                            FROM    hz_cust_acct_relate_all rel
                                            WHERE   rel.cust_account_id = cr.pay_from_customer
                                            AND     rel.bill_to_flag    = 'Y'
                                            AND     rel.status          = 'A'
                                            AND     ARP_STANDARD.sysparm.pay_unrelated_invoices_flag <> 'Y'
                                            UNION   ALL
                                            SELECT  rel.related_cust_account_id
                                            FROM    ar_paying_relationships_v rel,
                                                    hz_cust_accounts acc
                                            WHERE   acc.cust_account_id = cr.pay_from_customer
                                            AND     acc.party_id        = rel.party_id
                                            AND     cr.receipt_date    >= effective_start_date
                                            AND     cr.receipt_date    <= effective_end_date
                                            AND     ARP_STANDARD.sysparm.pay_unrelated_invoices_flag <> 'Y' )
        AND           tr.term_id(+)                 = ps.term_id
        AND           ps.cust_trx_type_id           = ctt.cust_trx_type_id;
    l_selected_recos              selected_recos_table;
    l_current_reco                selected_recos_table;
    l_current_fetch_count         NUMBER;
    l_outer_index                 NUMBER;
    l_current_reco_line           NUMBER;
    got_current_block             BOOLEAN;
  BEGIN
    IF (PG_DEBUG IN ('Y', 'C')) THEN
        log('arp_autoapply_api.insert_po_recos(+)');
    END IF;
    OPEN select_recos;
    LOOP
      FETCH select_recos BULK COLLECT INTO l_selected_recos LIMIT G_MAX_ARRAY_SIZE;
      log('Count : '||l_selected_recos.COUNT);
      IF l_selected_recos.COUNT = 0 THEN
        IF l_current_reco.count > 0 THEN
          process_single_reco(l_current_reco
                              , 'PURCHASE ORDER');
          l_current_reco.DELETE;
          insert_recos(p_request_id);
          clear_reco_lines_struct;
        END IF;
        EXIT;
      END IF;
      l_current_fetch_count := l_selected_recos.COUNT;
      l_outer_index := 1;
      LOOP
        IF l_outer_index > l_current_fetch_count THEN
          insert_recos(p_request_id);
          clear_reco_lines_struct;
          EXIT;
        END IF;
        got_current_block := FALSE;
        LOOP
          l_current_reco_line := l_current_reco.COUNT;
          IF l_current_reco_line = 0 THEN
            copy_current_record(l_current_reco, l_selected_recos, l_outer_index);
            l_outer_index := l_outer_index + 1;
          ELSE
            IF l_current_reco(l_current_reco_line).reco_num < l_selected_recos(l_outer_index).reco_num THEN
              log('Else-If');
              copy_current_record(l_current_reco, l_selected_recos, l_outer_index);
              l_outer_index := l_outer_index + 1;
            ELSE
              got_current_block := TRUE;
            END IF;
          END IF;
          IF got_current_block = TRUE OR l_outer_index > l_current_fetch_count THEN
            EXIT;
          END IF;
        END LOOP;
        IF l_outer_index > l_current_fetch_count THEN
          insert_recos(p_request_id);
          clear_reco_lines_struct;
          EXIT;
        END IF;
        process_single_reco(l_current_reco
                            , 'PURCHASE ORDER');
        l_current_reco.DELETE;
      END LOOP;
    END LOOP;
    IF (PG_DEBUG IN ('Y', 'C')) THEN
      log('arp_autoapply_api.insert_po_recos(-)');
    END IF;
    EXCEPTION
    WHEN OTHERS THEN
          log('Exception from arp_autoapply_api.insert_po_recos');
          log(SQLERRM);
          RAISE;
  END insert_po_recos;

/*===========================================================================+
 * PROCEDURE                                                                 *
 *     INSERT_SO_RECOS()                                                     *
 * DESCRIPTION                                                               *
 *   Inserts recommendations for Sales Orders                                *
 * SCOPE - LOCAL                                                             *
 * ARGUMENTS                                                                 *
 *              IN  : p_automatch_id Automatch Rule Identifier               *
 *                    p_use_matching_date Use Matching Date [ALWAYS/For      *
 *                    Duplicates/NULL]                                       *
 *                    p_trans_format_str Transaction Number Format String    *
 *                    p_rem_format_str Reference Number Format String        *
 *                    p_worker_number Current Worker Number                  *
 *                    p_request_id Request ID                                *
 *              OUT : None                                                   *
 *                                                                           *
 * RETURNS      NONE                    				                             *
 * ALGORITHM                                                                 *
 *   1. For all open SOs satisfying all the setup conditions calculate       *
 *      the matching score of sales order number with the reference number   *
 *      given in the remittance lines (ar_cash_remit_refs_all)               *
 *   2. If match_score > suggested threshold value specified at the AutoMatch*
 *      setup, insert into ar_cash_recos, ar_cash_reco_lines as a recommenda *
 *      -tion.                                                               *
 * NOTES -                                                                   *
 *   1. Tables with _ALL is used in INSERT statement as multi-table insert is*
 *      not possible on secured synonyms (ar_cash_recos and ar_cash_reco_lines)
 *   2. If pay_unrelated_customer is set to 'Yes' or the reference/receipt is*
 *      unidentified then transactions for all the customers are considered. *
 *      Otherwise only the transactions related to the paying customer of the*
 *      receipt are considered.                                              *
 *   3. A SO can have multiple invoices; which means there is a possibility  *
 *      that the receipt is applied against multiple payment schedules for   *
 *      the same transaction. ar_cash_recos contains header level information*
 *      level information like resolved number(sales order number)etc.,      *
 *      where as ar_cash_reco_lines contains the sepecific ps information for*
 *      the resolved transaction.                                            *
 *                                                                           *
 * MODIFICATION HISTORY -  09/03/2009 - Created by AGHORAKA	     	           *
 *                                                                           *
 +===========================================================================*/

  PROCEDURE insert_so_recos (p_automatch_id IN NUMBER
                            , p_use_matching_date IN VARCHAR2
                            , p_trans_format_str IN VARCHAR2
                            , p_rem_format_str  IN VARCHAR2
                            , p_trans_float_str IN VARCHAR2
                            , p_rem_float_str IN VARCHAR2
                            , p_worker_number IN NUMBER
                            , p_request_id IN NUMBER) IS
        CURSOR select_recos IS
      SELECT             ref.remit_reference_id remit_reference_id,
                         ref.amount_applied ref_amount_applied,
                         ref.amount_applied_from ref_amount_applied_from,
                         ref.trans_to_receipt_rate ref_trans_to_receipt_rate,
                         ref.cash_receipt_id cash_receipt_id,
                         cr.pay_from_customer pay_from_customer,
                         cr.customer_site_use_id cr_customer_site_use_id,
                         ps.customer_trx_id customer_trx_id,
                         ps.customer_id,
                         ps.customer_site_use_id customer_site_use_id,
                         lin.sales_order resolved_matching_number,
                         ps.terms_sequence_number terms_sequence_number,
                         decode(am.match_date_by,
                          'INT_HDR_ATT1', fnd_conc_date.string_to_date(trx.interface_header_attribute1),
                          'INT_HDR_ATT10', fnd_conc_date.string_to_date(trx.interface_header_attribute10),
                          'INT_HDR_ATT11', fnd_conc_date.string_to_date(trx.interface_header_attribute11),
                          'INT_HDR_ATT12', fnd_conc_date.string_to_date(trx.interface_header_attribute12),
                          'INT_HDR_ATT13', fnd_conc_date.string_to_date(trx.interface_header_attribute13),
                          'INT_HDR_ATT14', fnd_conc_date.string_to_date(trx.interface_header_attribute14),
                          'INT_HDR_ATT15', fnd_conc_date.string_to_date(trx.interface_header_attribute15),
                          'INT_HDR_ATT2', fnd_conc_date.string_to_date(trx.interface_header_attribute2),
                          'INT_HDR_ATT3', fnd_conc_date.string_to_date(trx.interface_header_attribute3),
                          'INT_HDR_ATT4', fnd_conc_date.string_to_date(trx.interface_header_attribute4),
                          'INT_HDR_ATT5', fnd_conc_date.string_to_date(trx.interface_header_attribute5),
                          'INT_HDR_ATT6', fnd_conc_date.string_to_date(trx.interface_header_attribute6),
                          'INT_HDR_ATT7', fnd_conc_date.string_to_date(trx.interface_header_attribute7),
                          'INT_HDR_ATT8', fnd_conc_date.string_to_date(trx.interface_header_attribute8),
                          'INT_HDR_ATT9', fnd_conc_date.string_to_date(trx.interface_header_attribute9),
                          'PURCH_ORDER_DATE', trx.purchase_order_date,
                          'TRANS_DATE', trx.trx_date,
                          NULL)  resolved_matching_date,
                         ps.trx_date trx_date,
                         ps.class resolved_matching_class,
                         ps.invoice_currency_code resolved_match_currency,
                         ps.amount_due_original amount_due_original,
                         ps.amount_due_remaining amount_due_remaining,
                         ps.discount_taken_earned discount_taken_earned,
                         ps.discount_taken_unearned discount_taken_unearned,
                         ARPCURR.CURRROUND(ps.amount_due_remaining, ps.invoice_currency_code ) amount_applied,
                         ROUND(NVL(ref.trans_to_receipt_rate,
                                   DECODE(ps.invoice_currency_code, cr.currency_code, NULL,
                                             NVL( ARP_AUTOAPPLY_API.get_cross_curr_rate(
                                                        ref.amount_applied,
                                                        ref.amount_applied_from,
                                                        ps.invoice_currency_code,
                                                        cr.currency_code
                                                        )
                                                  , GL_CURRENCY_API.GET_RATE_SQL(
                                                          ps.invoice_currency_code,
                                                          cr.currency_code,
                                                          cr.receipt_date,
                                                         arp_standard.sysparm.CROSS_CURRENCY_RATE_TYPE )
                                                )
                                         )
                                  ),38) trans_to_receipt_rate,
                         NULL amount_applied_from, -- will be calculated later for xcurr app.
                         ps.payment_schedule_id payment_schedule_id,
                         NULL cons_inv_id,         -- Not used here. Useful for BFBs. So null value selected.
                         UTL_MATCH.edit_distance_similarity(REGEXP_REPLACE(REGEXP_REPLACE(lin.sales_order, p_trans_format_str, '\2'), p_trans_float_str, ''),
                                                            REGEXP_REPLACE(REGEXP_REPLACE(ref.invoice_reference, p_rem_format_str, '\2'), p_rem_float_str, '')) match_score_value,
                         ps.org_id,
                         ps.term_id term_id,
                         am.automatch_id automatch_id,
                         am.use_matching_date use_matching_date,
                         am.use_matching_amount use_matching_amount,
                         am.auto_match_threshold auto_match_threshold,
                         amp.priority priority,
                         cr.currency_code receipt_currency_code,
                         cr.receipt_date receipt_date,
                         ctt.allow_overapplication_flag allow_overapplication_flag,
                         tr.partial_discount_flag partial_discount_flag,
                         RANK() OVER (PARTITION BY lin.sales_order, ps.customer_site_use_id,
                                      ref.remit_reference_id, ps.customer_trx_id
                              ORDER BY ps.payment_schedule_id) AS  reco_num
          FROM           ar_cash_automatches am,
                         ar_cash_automatch_rule_map amp,
                         ar_cash_remit_refs_interim ref,
                         ar_cash_receipts cr,
                         ra_customer_trx_lines lin,
                         ar_payment_schedules ps,
                         ra_customer_trx trx,
                         ra_cust_trx_types ctt,
                        ra_terms tr
          WHERE          am.automatch_id               = p_automatch_id
          AND            amp.automatch_id              = am.automatch_id
          AND            amp.automatch_set_id          = ref.automatch_set_id
          AND            ref.worker_number             = p_worker_number
          AND            ref.receipt_reference_status  = 'AR_AM_NEW'
          AND            cr.cash_receipt_id            = ref.cash_receipt_id
          AND            cr.receipt_date BETWEEN NVL(am.start_date, cr.receipt_date)
                                         AND NVL(am.end_date, to_date('31/12/4712','DD/MM/YYYY'))
          AND            lin.interface_line_context   <> 'OKS CONTRACTS'
          AND            lin.sales_order                 IS NOT NULL
          AND            UTL_MATCH.edit_distance_similarity(REGEXP_REPLACE(REGEXP_REPLACE(lin.sales_order, p_trans_format_str, '\2'), p_trans_float_str, ''),
                                                            REGEXP_REPLACE(REGEXP_REPLACE(ref.invoice_reference, p_rem_format_str, '\2'), p_rem_float_str, '')) >= am.sugg_match_threshold
          AND            ps.customer_trx_id            = lin.customer_trx_id
          AND            trx.customer_trx_id           = ps.customer_trx_id
                        /* Added to fetch values from Header Attributes */
          AND            ps.selected_for_receipt_batch_id IS NULL
          AND            ps.class                     NOT IN ('PMT', 'GUAR')
          AND            ps.payment_schedule_id        > 0
          AND            ps.status                      = 'OP'
          AND            ps.customer_id IN (SELECT  DECODE(ARP_STANDARD.sysparm.pay_unrelated_invoices_flag,'Y', ps.customer_id,
                                                                 NVL(cr.pay_from_customer, ps.customer_id))
                                            FROM    DUAL
                                            UNION   ALL
                                            SELECT  related_cust_account_id
                                            FROM    hz_cust_acct_relate_all rel
                                            WHERE   rel.cust_account_id = cr.pay_from_customer
                                            AND     rel.bill_to_flag    = 'Y'
                                            AND     rel.status          = 'A'
                                            AND     ARP_STANDARD.sysparm.pay_unrelated_invoices_flag <> 'Y'
                                            UNION   ALL
                                            SELECT  rel.related_cust_account_id
                                            FROM    ar_paying_relationships_v rel,
                                                    hz_cust_accounts acc
                                            WHERE   acc.cust_account_id = cr.pay_from_customer
                                            AND     acc.party_id        = rel.party_id
                                            AND     cr.receipt_date    >= effective_start_date
                                            AND     cr.receipt_date    <= effective_end_date
                                            AND     ARP_STANDARD.sysparm.pay_unrelated_invoices_flag <> 'Y' )
          AND           tr.term_id(+)                 = ps.term_id
          AND           ps.cust_trx_type_id           = ctt.cust_trx_type_id;
    l_selected_recos              selected_recos_table;
    l_current_reco                selected_recos_table;
    l_current_fetch_count         NUMBER;
    l_outer_index                 NUMBER;
    l_current_reco_line           NUMBER;
    got_current_block             BOOLEAN;
  BEGIN
    IF (PG_DEBUG IN ('Y', 'C')) THEN
      log('arp_autoapply_api.insert_so_recos(+)');
    END IF;
    OPEN select_recos;
    LOOP
      FETCH select_recos BULK COLLECT INTO l_selected_recos LIMIT G_MAX_ARRAY_SIZE;
      log('Count : '||l_selected_recos.COUNT);
      IF l_selected_recos.COUNT = 0 THEN
        IF l_current_reco.count > 0 THEN
          process_single_reco(l_current_reco
                              , 'SALES ORDER');
          l_current_reco.DELETE;
          insert_recos(p_request_id);
          clear_reco_lines_struct;
        END IF;
        EXIT;
      END IF;
      l_current_fetch_count := l_selected_recos.COUNT;
      l_outer_index := 1;
      LOOP
        IF l_outer_index > l_current_fetch_count THEN
          insert_recos(p_request_id);
          clear_reco_lines_struct;
          EXIT;
        END IF;
        got_current_block := FALSE;
        LOOP
          l_current_reco_line := l_current_reco.COUNT;
          IF l_current_reco_line = 0 THEN
            copy_current_record(l_current_reco, l_selected_recos, l_outer_index);
            l_outer_index := l_outer_index + 1;
          ELSE
            IF l_current_reco(l_current_reco_line).reco_num < l_selected_recos(l_outer_index).reco_num THEN
              copy_current_record(l_current_reco, l_selected_recos, l_outer_index);
              l_outer_index := l_outer_index + 1;
            ELSE
              got_current_block := TRUE;
            END IF;
          END IF;
          IF got_current_block = TRUE OR l_outer_index > l_current_fetch_count THEN
            EXIT;
          END IF;
        END LOOP;
        IF l_outer_index > l_current_fetch_count THEN
          insert_recos(p_request_id);
          clear_reco_lines_struct;
          EXIT;
        END IF;
        process_single_reco(l_current_reco
                            , 'SALES ORDER');
        l_current_reco.DELETE;
      END LOOP;
    END LOOP;
    IF (PG_DEBUG IN ('Y', 'C')) THEN
      log('arp_autoapply_api.insert_so_recos(-)');
    END IF;
    EXCEPTION
    WHEN OTHERS THEN
          log('Exception from arp_autoapply_api.insert_so_recos');
          log(SQLERRM);
          RAISE;
  END insert_so_recos;

/*===========================================================================+
 * PROCEDURE                                                                 *
 *     INSERT_CONTRACT_RECOS()                                               *
 * DESCRIPTION                                                               *
 *   Inserts recommendations for Sales Contracts                             *
 * SCOPE - LOCAL                                                             *
 * ARGUMENTS                                                                 *
 *              IN  : p_automatch_id Automatch Rule Identifier               *
 *                    p_use_matching_date Use Matching Date [ALWAYS/For      *
 *                    Duplicates/NULL]                                       *
 *                    p_trans_format_str Transaction Number Format String    *
 *                    p_rem_format_str Reference Number Format String        *
 *                    p_worker_number Current Worker Number                  *
 *                    p_request_id Request ID                                *
 *              OUT : None                                                   *
 *                                                                           *
 * RETURNS      NONE                    				                             *
 * ALGORITHM                                                                 *
 *   1. For all open contracts satisfying all the setup conditions calculate *
 *      the matching score of contract number with the reference number   *
 *      given in the remittance lines (ar_cash_remit_refs_all)               *
 *   2. If match_score > suggested threshold value specified at the AutoMatch*
 *      setup, insert into ar_cash_recos, ar_cash_reco_lines as a recommenda *
 *      -tion.                                                               *
 * NOTES -                                                                   *
 *   1. Tables with _ALL is used in INSERT statement as multi-table insert is*
 *      not possible on secured synonyms (ar_cash_recos and ar_cash_reco_lines)
 *   2. If pay_unrelated_customer is set to 'Yes' or the reference/receipt is*
 *      unidentified then transactions for all the customers are considered. *
 *      Otherwise only the transactions related to the paying customer of the*
 *      receipt are considered.                                              *
 *   3. A Contract can have multiple invoices;which means there is a possibility
 *      that the receipt is applied against multiple payment schedules for   *
 *      the same transaction. ar_cash_recos contains header level information*
 *      level information like resolved number(contract number)etc.,         *
 *      where as ar_cash_reco_lines contains the sepecific ps information for*
 *      the resolved transaction.                                            *
 *                                                                           *
 * MODIFICATION HISTORY -  09/03/2009 - Created by AGHORAKA	     	           *
 *                                                                           *
 +===========================================================================*/

  PROCEDURE insert_contract_recos (p_automatch_id IN NUMBER
                                  , p_use_matching_date IN VARCHAR2
                                  , p_trans_format_str IN VARCHAR2
                                  , p_rem_format_str  IN VARCHAR2
                                  , p_trans_float_str IN VARCHAR2
                                  , p_rem_float_str IN VARCHAR2
                                  , p_worker_number IN NUMBER
                                  , p_request_id IN NUMBER) IS
        CURSOR select_recos IS
      SELECT             ref.remit_reference_id remit_reference_id,
                         ref.amount_applied ref_amount_applied,
                         ref.amount_applied_from ref_amount_applied_from,
                         ref.trans_to_receipt_rate ref_trans_to_receipt_rate,
                         ref.cash_receipt_id cash_receipt_id,
                         cr.pay_from_customer pay_from_customer,
                         cr.customer_site_use_id cr_customer_site_use_id,
                         ps.customer_trx_id customer_trx_id,
                         ps.customer_id,
                         ps.customer_site_use_id customer_site_use_id,
                         lin.sales_order resolved_matching_number,
                         ps.terms_sequence_number terms_sequence_number,
                         decode(am.match_date_by,
                          'INT_HDR_ATT1', fnd_conc_date.string_to_date(trx.interface_header_attribute1),
                          'INT_HDR_ATT10', fnd_conc_date.string_to_date(trx.interface_header_attribute10),
                          'INT_HDR_ATT11', fnd_conc_date.string_to_date(trx.interface_header_attribute11),
                          'INT_HDR_ATT12', fnd_conc_date.string_to_date(trx.interface_header_attribute12),
                          'INT_HDR_ATT13', fnd_conc_date.string_to_date(trx.interface_header_attribute13),
                          'INT_HDR_ATT14', fnd_conc_date.string_to_date(trx.interface_header_attribute14),
                          'INT_HDR_ATT15', fnd_conc_date.string_to_date(trx.interface_header_attribute15),
                          'INT_HDR_ATT2', fnd_conc_date.string_to_date(trx.interface_header_attribute2),
                          'INT_HDR_ATT3', fnd_conc_date.string_to_date(trx.interface_header_attribute3),
                          'INT_HDR_ATT4', fnd_conc_date.string_to_date(trx.interface_header_attribute4),
                          'INT_HDR_ATT5', fnd_conc_date.string_to_date(trx.interface_header_attribute5),
                          'INT_HDR_ATT6', fnd_conc_date.string_to_date(trx.interface_header_attribute6),
                          'INT_HDR_ATT7', fnd_conc_date.string_to_date(trx.interface_header_attribute7),
                          'INT_HDR_ATT8', fnd_conc_date.string_to_date(trx.interface_header_attribute8),
                          'INT_HDR_ATT9', fnd_conc_date.string_to_date(trx.interface_header_attribute9),
                          'PURCH_ORDER_DATE', trx.purchase_order_date,
                          'TRANS_DATE', trx.trx_date,
                          NULL)  resolved_matching_date,
                         ps.trx_date trx_date,
                         ps.class resolved_matching_class,
                         ps.invoice_currency_code resolved_match_currency,
                         ps.amount_due_original amount_due_original,
                         ps.amount_due_remaining amount_due_remaining,
                         ps.discount_taken_earned discount_taken_earned,
                         ps.discount_taken_unearned discount_taken_unearned,
                         ARPCURR.CURRROUND(ps.amount_due_remaining, ps.invoice_currency_code ) amount_applied,
                         ROUND(NVL(ref.trans_to_receipt_rate,
                                   DECODE(ps.invoice_currency_code, cr.currency_code, NULL,
                                             NVL( ARP_AUTOAPPLY_API.get_cross_curr_rate(
                                                        ref.amount_applied,
                                                        ref.amount_applied_from,
                                                        ps.invoice_currency_code,
                                                        cr.currency_code
                                                        )
                                                  , GL_CURRENCY_API.GET_RATE_SQL(
                                                          ps.invoice_currency_code,
                                                          cr.currency_code,
                                                          cr.receipt_date,
                                                         arp_standard.sysparm.CROSS_CURRENCY_RATE_TYPE )
                                                )
                                         )
                                  ),38) trans_to_receipt_rate,
                         NULL amount_applied_from, -- will be calculated later for xcurr app.
                         ps.payment_schedule_id payment_schedule_id,
                         NULL cons_inv_id,         -- Not used here. Useful for BFBs. So null value selected.
                         UTL_MATCH.edit_distance_similarity(REGEXP_REPLACE(REGEXP_REPLACE(lin.sales_order, p_trans_format_str, '\2'), p_trans_float_str, ''),
                                                            REGEXP_REPLACE(REGEXP_REPLACE(ref.invoice_reference, p_rem_format_str, '\2'), p_rem_float_str, '')) match_score_value,
                         ps.org_id,
                         ps.term_id term_id,
                         am.automatch_id automatch_id,
                         am.use_matching_date use_matching_date,
                         am.use_matching_amount use_matching_amount,
                         am.auto_match_threshold auto_match_threshold,
                         amp.priority priority,
                         cr.currency_code receipt_currency_code,
                         cr.receipt_date receipt_date,
                         ctt.allow_overapplication_flag allow_overapplication_flag,
                         tr.partial_discount_flag partial_discount_flag,
                         RANK() OVER (PARTITION BY lin.sales_order, ps.customer_site_use_id,
                                      ref.remit_reference_id, ps.customer_trx_id
                              ORDER BY ps.payment_schedule_id) AS  reco_num
          FROM           ar_cash_automatches am,
                         ar_cash_automatch_rule_map amp,
                         ar_cash_remit_refs_interim ref,
                         ar_cash_receipts cr,
                         ra_customer_trx_lines lin,
                         ar_payment_schedules ps,
                         ra_customer_trx trx,
                         ra_cust_trx_types ctt,
                         ra_terms tr
          WHERE          am.automatch_id               = p_automatch_id
          AND            amp.automatch_id              = am.automatch_id
          AND            amp.automatch_set_id          = ref.automatch_set_id
          AND            ref.worker_number             = p_worker_number
          AND            ref.receipt_reference_status  = 'AR_AM_NEW'
          AND            cr.cash_receipt_id            = ref.cash_receipt_id
          AND            cr.receipt_date BETWEEN NVL(am.start_date, cr.receipt_date)
                                         AND NVL(am.end_date, to_date('31/12/4712','DD/MM/YYYY'))
          AND            lin.interface_line_context    = 'OKS CONTRACTS'
          AND            lin.sales_order                 IS NOT NULL
          AND            UTL_MATCH.edit_distance_similarity(REGEXP_REPLACE(REGEXP_REPLACE(lin.sales_order, p_trans_format_str, '\2'), p_trans_float_str, ''),
                                                            REGEXP_REPLACE(REGEXP_REPLACE(ref.invoice_reference, p_rem_format_str, '\2'), p_rem_float_str, '')) >= am.sugg_match_threshold
          AND            ps.customer_trx_id            = lin.customer_trx_id
          AND            trx.customer_trx_id           = ps.customer_trx_id
                    /* Added to fetch the date from Header Attribute Columns */
          AND            ps.selected_for_receipt_batch_id IS NULL
          AND            ps.class                     NOT IN ('PMT', 'GUAR')
          AND            ps.payment_schedule_id        > 0
          AND            ps.status                      = 'OP'
          AND            ps.customer_id IN (SELECT  DECODE(ARP_STANDARD.sysparm.pay_unrelated_invoices_flag,'Y', ps.customer_id,
                                                                 NVL(cr.pay_from_customer, ps.customer_id))
                                            FROM    DUAL
                                            UNION   ALL
                                            SELECT  related_cust_account_id
                                            FROM    hz_cust_acct_relate_all rel
                                            WHERE   rel.cust_account_id = cr.pay_from_customer
                                            AND     rel.bill_to_flag    = 'Y'
                                            AND     rel.status          = 'A'
                                            AND     ARP_STANDARD.sysparm.pay_unrelated_invoices_flag <> 'Y'
                                            UNION   ALL
                                            SELECT  rel.related_cust_account_id
                                            FROM    ar_paying_relationships_v rel,
                                                    hz_cust_accounts acc
                                            WHERE   acc.cust_account_id = cr.pay_from_customer
                                            AND     acc.party_id        = rel.party_id
                                            AND     cr.receipt_date    >= effective_start_date
                                            AND     cr.receipt_date    <= effective_end_date
                                            AND     ARP_STANDARD.sysparm.pay_unrelated_invoices_flag <> 'Y' )
          AND           tr.term_id(+)                 = ps.term_id
          AND           ps.cust_trx_type_id           = ctt.cust_trx_type_id;
    l_selected_recos              selected_recos_table;
    l_current_reco                selected_recos_table;
    l_current_fetch_count         NUMBER;
    l_outer_index                 NUMBER;
    l_current_reco_line           NUMBER;
    got_current_block             BOOLEAN;
  BEGIN
    IF (PG_DEBUG IN ('Y', 'C')) THEN
      log('arp_autoapply_api.insert_contract_recos(+)');
    END IF;
    OPEN select_recos;
    LOOP
      FETCH select_recos BULK COLLECT INTO l_selected_recos LIMIT G_MAX_ARRAY_SIZE;
      log('Count : '||l_selected_recos.COUNT);
      IF l_selected_recos.COUNT = 0 THEN
        IF l_current_reco.count > 0 THEN
          process_single_reco(l_current_reco
                              , 'SERVICE CONTRACT');
          l_current_reco.DELETE;
          insert_recos(p_request_id);
          clear_reco_lines_struct;
        END IF;
        EXIT;
      END IF;
      l_current_fetch_count := l_selected_recos.COUNT;
      l_outer_index := 1;
      LOOP
        IF l_outer_index > l_current_fetch_count THEN
          insert_recos(p_request_id);
          clear_reco_lines_struct;
          EXIT;
        END IF;
        got_current_block := FALSE;
        LOOP
          l_current_reco_line := l_current_reco.COUNT;
          IF l_current_reco_line = 0 THEN
            copy_current_record(l_current_reco, l_selected_recos, l_outer_index);
            l_outer_index := l_outer_index + 1;
          ELSE
            IF l_current_reco(l_current_reco_line).reco_num < l_selected_recos(l_outer_index).reco_num THEN
              copy_current_record(l_current_reco, l_selected_recos, l_outer_index);
              l_outer_index := l_outer_index + 1;
            ELSE
              got_current_block := TRUE;
            END IF;
          END IF;
          IF got_current_block = TRUE OR l_outer_index > l_current_fetch_count THEN
            EXIT;
          END IF;
        END LOOP;
        IF l_outer_index > l_current_fetch_count THEN
          insert_recos(p_request_id);
          clear_reco_lines_struct;
          EXIT;
        END IF;
        process_single_reco(l_current_reco
                            , 'SERVICE CONTRACT');
        l_current_reco.DELETE;
      END LOOP;
    END LOOP;
    IF (PG_DEBUG IN ('Y', 'C')) THEN
        log('arp_autoapply_api.insert_contract_recos(-)');
    END IF;
    EXCEPTION
    WHEN OTHERS THEN
          log('Exception from arp_autoapply_api.insert_contract_recos');
          log(SQLERRM);
          RAISE;
  END insert_contract_recos;

/*===========================================================================+
 * PROCEDURE                                                                 *
 *     INSERT_ATTRIBUTE_RECOS()                                              *
 * DESCRIPTION                                                               *
 *   Inserts recommendations for transaction numbers (Matched with interface *
 *   header attribute)                                                       *
 * SCOPE - LOCAL                                                             *
 * ARGUMENTS                                                                 *
 *              IN  : p_automatch_id Automatch Rule Identifier               *
 *                    p_use_matching_date Use Matching Date [ALWAYS/For      *
 *                    Duplicates/NULL]                                       *
 *                    p_trans_format_str Transaction Number Format String    *
 *                    p_rem_format_str Reference Number Format String        *
 *                    p_worker_number Current Worker Number                  *
 *                    p_attribute_number Header Attribute Number that has to *
 *                     be matches with (1-16)                                *
 *                    p_request_id Request ID                                *
 *              OUT : None                                                   *
 *                                                                           *
 * RETURNS      NONE                    				                             *
 * ALGORITHM                                                                 *
 *   1. For all open transactions satisfying all the setup conditions calculate
 *      the matching score of header attribute value with the reference number
 *      given in the remittance lines (ar_cash_remit_refs_all)               *
 *   2. If match_score > suggested threshold value specified at the AutoMatch*
 *      setup, insert into ar_cash_recos, ar_cash_reco_lines as a recommenda *
 *      -tion.                                                               *
 * NOTES -                                                                   *
 *   1. Tables with _ALL is used in INSERT statement as multi-table insert is*
 *      not possible on secured synonyms (ar_cash_recos and ar_cash_reco_lines)
 *   2. If pay_unrelated_customer is set to 'Yes' or the reference/receipt is*
 *      unidentified then transactions for all the customers are considered. *
 *      Otherwise only the transactions related to the paying customer of the*
 *      receipt are considered.                                              *
 *   3. An invoice can have multiple installments; which means there is a    *
 *      possibility that the receipt is applied against multiple payment     *
 *      schedules for the same transaction. ar_cash_recos contains header    *
 *      level information like resolved number(trx number), trx date etc.,   *
 *      where as ar_cash_reco_lines contains the sepecific ps information for*
 *      the resolved transaction.                                            *
 *                                                                           *
 * MODIFICATION HISTORY -  09/03/2009 - Created by AGHORAKA	     	           *
 *                                                                           *
 +===========================================================================*/

  PROCEDURE insert_attribute_recos (p_automatch_id IN NUMBER
                                  , p_use_matching_date IN VARCHAR2
                                  , p_trans_format_str IN VARCHAR2
                                  , p_rem_format_str  IN VARCHAR2
                                  , p_trans_float_str IN VARCHAR2
                                  , p_rem_float_str IN VARCHAR2
                                  , p_worker_number IN NUMBER
                                  , p_attribute_number IN VARCHAR2
                                  , p_request_id IN NUMBER) IS
  l_sel_stmt  VARCHAR2(12000) := 'SELECT     ref.remit_reference_id remit_reference_id,
                             ref.amount_applied ref_amount_applied,
                             ref.amount_applied_from ref_amount_applied_from,
                             ref.trans_to_receipt_rate ref_trans_to_receipt_rate,
                             ref.cash_receipt_id cash_receipt_id,
                             cr.pay_from_customer pay_from_customer,
                             cr.customer_site_use_id cr_customer_site_use_id,
                             ps.customer_trx_id customer_trx_id,
                             ps.customer_id,
                             ps.customer_site_use_id customer_site_use_id,
                             trx.trx_number resolved_matching_number,
                             ps.terms_sequence_number terms_sequence_number,
                             decode(am.match_date_by,
                            ''INT_HDR_ATT1'', fnd_conc_date.string_to_date(trx.interface_header_attribute1),
                            ''INT_HDR_ATT10'', fnd_conc_date.string_to_date(trx.interface_header_attribute10),
                            ''INT_HDR_ATT11'', fnd_conc_date.string_to_date(trx.interface_header_attribute11),
                            ''INT_HDR_ATT12'', fnd_conc_date.string_to_date(trx.interface_header_attribute12),
                            ''INT_HDR_ATT13'', fnd_conc_date.string_to_date(trx.interface_header_attribute13),
                            ''INT_HDR_ATT14'', fnd_conc_date.string_to_date(trx.interface_header_attribute14),
                            ''INT_HDR_ATT15'', fnd_conc_date.string_to_date(trx.interface_header_attribute15),
                            ''INT_HDR_ATT2'', fnd_conc_date.string_to_date(trx.interface_header_attribute2),
                            ''INT_HDR_ATT3'', fnd_conc_date.string_to_date(trx.interface_header_attribute3),
                            ''INT_HDR_ATT4'', fnd_conc_date.string_to_date(trx.interface_header_attribute4),
                            ''INT_HDR_ATT5'', fnd_conc_date.string_to_date(trx.interface_header_attribute5),
                            ''INT_HDR_ATT6'', fnd_conc_date.string_to_date(trx.interface_header_attribute6),
                            ''INT_HDR_ATT7'', fnd_conc_date.string_to_date(trx.interface_header_attribute7),
                            ''INT_HDR_ATT8'', fnd_conc_date.string_to_date(trx.interface_header_attribute8),
                            ''INT_HDR_ATT9'', fnd_conc_date.string_to_date(trx.interface_header_attribute9),
                            ''PURCH_ORDER_DATE'', trx.purchase_order_date,
                            ''TRANS_DATE'', trx.trx_date,
                            NULL)  resolved_matching_date,
                             ps.trx_date trx_date,
                             ps.class resolved_matching_class,
                             ps.invoice_currency_code resolved_match_currency,
                             ps.amount_due_original amount_due_original,
                             ps.amount_due_remaining amount_due_remaining,
                             ps.discount_taken_earned discount_taken_earned,
                             ps.discount_taken_unearned discount_taken_unearned,
                             ARPCURR.CURRROUND(ps.amount_due_remaining, ps.invoice_currency_code ) amount_applied,
                             ROUND(NVL(ref.trans_to_receipt_rate,
                                 DECODE(ps.invoice_currency_code, cr.currency_code, NULL,
                                           NVL( ARP_AUTOAPPLY_API.get_cross_curr_rate(
                                                      ref.amount_applied,
                                                      ref.amount_applied_from,
                                                      ps.invoice_currency_code,
                                                      cr.currency_code
                                                      )
                                                , GL_CURRENCY_API.GET_RATE_SQL(
                                                        ps.invoice_currency_code,
                                                        cr.currency_code,
                                                        cr.receipt_date,
                                                       ar_setup.value(''AR_CROSS_CURRENCY_RATE_TYPE'',null) )
                                              )
                                       )
                                      ),38) trans_to_receipt_rate,
                             NULL amount_applied_from, -- will be calculated later for xcurr app.
                             ps.payment_schedule_id payment_schedule_id,
                             NULL cons_inv_id,         -- Not used here. Useful for BFBs. So null value selected.
                             UTL_MATCH.edit_distance_similarity(REGEXP_REPLACE(REGEXP_REPLACE(trx.interface_header_attribute'|| p_attribute_number ||', :b_trans_format_str, ''\2''), :b_trans_float_str, ''''),
                                                                REGEXP_REPLACE(REGEXP_REPLACE(ref.invoice_reference, :b_rem_format_str, ''\2''), :b_rem_float_str, '''')) match_score_value,
                             ps.org_id org_id,
                             ps.term_id term_id,
                             am.automatch_id automatch_id,
                             am.use_matching_date use_matching_date,
                             am.use_matching_amount use_matching_amount,
                             am.auto_match_threshold auto_match_threshold,
                             amp.priority priority,
                             cr.currency_code receipt_currency_code,
                             cr.receipt_date receipt_date,
                             ctt.allow_overapplication_flag allow_overapplication_flag,
                             tr.partial_discount_flag partial_discount_flag,
                             RANK() OVER (PARTITION BY trx.interface_header_attribute' || p_attribute_number ||', ps.customer_site_use_id,
                                          ref.remit_reference_id, ps.customer_trx_id
                                  ORDER BY ps.payment_schedule_id) AS  reco_num
              FROM           ar_cash_automatches am,
                             ar_cash_automatch_rule_map amp,
                             ar_cash_remit_refs_interim ref,
                             ar_cash_receipts cr,
                             ra_customer_trx trx,
                             ar_payment_schedules ps,
                             ra_cust_trx_types ctt,
                             ra_terms tr
              WHERE          am.automatch_id               = :b_automatch_id
              AND            amp.automatch_id              = am.automatch_id
              AND            amp.automatch_set_id          = ref.automatch_set_id
              AND            ref.worker_number             = :b_worker_number
              AND            ref.receipt_reference_status  = ''AR_AM_NEW''
              AND            cr.cash_receipt_id            = ref.cash_receipt_id
              AND            cr.receipt_date BETWEEN NVL(am.start_date, cr.receipt_date)
                                             AND NVL(am.end_date, to_date(''31/12/4712'',''DD/MM/YYYY''))
              AND            trx.interface_header_attribute'|| p_attribute_number || ' IS NOT NULL
              AND            UTL_MATCH.edit_distance_similarity(REGEXP_REPLACE(REGEXP_REPLACE(trx.interface_header_attribute'|| p_attribute_number ||', :b_trans_format_str, ''\2''), :b_trans_float_str, ''''),
                                                                REGEXP_REPLACE(REGEXP_REPLACE(ref.invoice_reference, :b_rem_format_str, ''\2''), :b_rem_float_str, '''')) >= am.sugg_match_threshold
              AND            ps.customer_trx_id            = trx.customer_trx_id
              AND            ps.selected_for_receipt_batch_id IS NULL
              AND            ps.class                     NOT IN (''PMT'', ''GUAR'')
              AND            ps.status                     = ''OP''
              AND            ps.terms_sequence_number     = NVL(ref.installment_reference,
                                                          ps.terms_sequence_number)
              AND            ps.payment_schedule_id        > 0
              AND            ps.customer_id IN (SELECT  DECODE(:b_pay_unrelated_invoices_flag,''Y'', ps.customer_id,
                                                                     NVL(cr.pay_from_customer, ps.customer_id))
                                                FROM    DUAL
                                                UNION   ALL
                                                SELECT  related_cust_account_id
                                                FROM    hz_cust_acct_relate_all rel
                                                WHERE   rel.cust_account_id = cr.pay_from_customer
                                                AND     rel.bill_to_flag    = ''Y''
                                                AND     rel.status          = ''A''
                                                AND     :b_pay_unrelated_invoices_flag <> ''Y''
                                                UNION   ALL
                                                SELECT  rel.related_cust_account_id
                                                FROM    ar_paying_relationships_v rel,
                                                        hz_cust_accounts acc
                                                WHERE   acc.cust_account_id = cr.pay_from_customer
                                                AND     acc.party_id        = rel.party_id
                                                AND     cr.receipt_date    >= effective_start_date
                                                AND     cr.receipt_date    <= effective_end_date
                                                AND     :b_pay_unrelated_invoices_flag <> ''Y'' )
              AND           trx.customer_trx_id           = ps.customer_trx_id
              AND           tr.term_id(+)                 = ps.term_id
              AND           ps.cust_trx_type_id           = ctt.cust_trx_type_id';

  TYPE SelectRecoType IS REF CURSOR;
  select_recos                  SelectRecoType;
  l_selected_recos              selected_recos_table;
  l_current_reco                selected_recos_table;
  l_current_fetch_count         NUMBER;
  l_outer_index                 NUMBER;
  l_current_reco_line           NUMBER;
  got_current_block             BOOLEAN;
  BEGIN
    IF (PG_DEBUG IN ('Y', 'C')) THEN
        log('arp_autoapply_api.insert_attribute_recos(+)');
        log('SQL : '||l_sel_stmt);
    END IF;

    OPEN select_recos FOR l_sel_stmt USING p_trans_format_str,
                                           p_trans_float_str,
                                           p_rem_format_str,
                                           p_rem_float_str,
                                           p_automatch_id,
                                           p_worker_number,
                                           p_trans_format_str,
                                           p_trans_float_str,
                                           p_rem_format_str,
                                           p_rem_float_str,
                                           ARP_STANDARD.sysparm.pay_unrelated_invoices_flag,
                                           ARP_STANDARD.sysparm.pay_unrelated_invoices_flag,
                                           ARP_STANDARD.sysparm.pay_unrelated_invoices_flag;
  LOOP
      FETCH select_recos BULK COLLECT INTO l_selected_recos LIMIT G_MAX_ARRAY_SIZE;
      log('Count : '||l_selected_recos.COUNT);
      IF l_selected_recos.COUNT = 0 THEN
        IF l_current_reco.count > 0 THEN
          process_single_reco(l_current_reco
                              , 'INTERFACE HEADER ATTRIBUTE'||p_attribute_number);
          l_current_reco.DELETE;
          insert_recos(p_request_id);
          clear_reco_lines_struct;
        END IF;
        EXIT;
      END IF;
      l_current_fetch_count := l_selected_recos.COUNT;
      l_outer_index := 1;
      LOOP
        IF l_outer_index > l_current_fetch_count THEN
          insert_recos(p_request_id);
          clear_reco_lines_struct;
          EXIT;
        END IF;
        got_current_block := FALSE;
        LOOP
          l_current_reco_line := l_current_reco.COUNT;
          IF l_current_reco_line = 0 THEN
            log('If Statement');
            copy_current_record(l_current_reco, l_selected_recos, l_outer_index);
            l_outer_index := l_outer_index + 1;
          ELSE
            IF l_current_reco(l_current_reco_line).reco_num < l_selected_recos(l_outer_index).reco_num THEN
              log('Else-If');
              copy_current_record(l_current_reco, l_selected_recos, l_outer_index);
              l_outer_index := l_outer_index + 1;
            ELSE
              log('Else-Else');
              got_current_block := TRUE;
            END IF;
          END IF;
          IF got_current_block = TRUE OR l_outer_index > l_current_fetch_count THEN
            EXIT;
          END IF;
        END LOOP;
        IF l_outer_index > l_current_fetch_count THEN
          insert_recos(p_request_id);
          clear_reco_lines_struct;
          EXIT;
        END IF;
        process_single_reco(l_current_reco
                            , 'INTERFACE HEADER ATTRIBUTE'||p_attribute_number);
        l_current_reco.DELETE;
      END LOOP;
    END LOOP;

    IF (PG_DEBUG IN ('Y', 'C')) THEN
        log('arp_autoapply_api.insert_attribute_recos(-)');
    END IF;
    EXCEPTION
    WHEN OTHERS THEN
          log('Exception from arp_autoapply_api.insert_attribute_recos');
          log(SQLERRM);
          RAISE;
  END insert_attribute_recos;

/*===========================================================================+
 * PROCEDURE                                                                 *
 *     INSERT_WAYBILL_RECOS()                                                *
 * DESCRIPTION                                                               *
 *   Inserts recommendations for Waybill Numbers                             *
 * SCOPE - LOCAL                                                             *
 * ARGUMENTS                                                                 *
 *              IN  : p_automatch_id Automatch Rule Identifier               *
 *                    p_use_matching_date Use Matching Date [ALWAYS/For      *
 *                    Duplicates/NULL]                                       *
 *                    p_trans_format_str Transaction Number Format String    *
 *                    p_rem_format_str Reference Number Format String        *
 *                    p_worker_number Current Worker Number                  *
 *                    p_request_id Request ID                                *
 *              OUT : None                                                   *
 *                                                                           *
 * RETURNS      NONE                    				                             *
 * ALGORITHM                                                                 *
 *   1. For all open way bills satisfying all the setup conditions calculate *
 *      the matching score of way bill number with the reference number      *
 *      given in the remittance lines (ar_cash_remit_refs_all)               *
 *   2. If match_score > suggested threshold value specified at the AutoMatch*
 *      setup, insert into ar_cash_recos, ar_cash_reco_lines as a recommenda *
 *      -tion.                                                               *
 * NOTES -                                                                   *
 *   1. Tables with _ALL is used in INSERT statement as multi-table insert is*
 *      not possible on secured synonyms (ar_cash_recos and ar_cash_reco_lines)
 *   2. If pay_unrelated_customer is set to 'Yes' or the reference/receipt is*
 *      unidentified then transactions for all the customers are considered. *
 *      Otherwise only the transactions related to the paying customer of the*
 *      receipt are considered.                                              *
 *   3. ar_cash_recos contains header level information like resolved        *
 *      number(way bill number)etc., where as ar_cash_reco_lines contains the*
 *      sepecific ps information for the resolved transaction.               *
 *                                                                           *
 * MODIFICATION HISTORY -  09/03/2009 - Created by AGHORAKA	     	           *
 *                                                                           *
 +===========================================================================*/

  PROCEDURE insert_waybill_recos (p_automatch_id IN NUMBER
                                  , p_use_matching_date IN VARCHAR2
                                  , p_trans_format_str IN VARCHAR2
                                  , p_rem_format_str  IN VARCHAR2
                                  , p_trans_float_str IN VARCHAR2
                                  , p_rem_float_str IN VARCHAR2
                                  , p_worker_number IN NUMBER
                                  , p_request_id IN NUMBER) IS
    CURSOR select_recos IS
      SELECT             ref.remit_reference_id remit_reference_id,
                         ref.amount_applied ref_amount_applied,
                         ref.amount_applied_from ref_amount_applied_from,
                         ref.trans_to_receipt_rate ref_trans_to_receipt_rate,
                         ref.cash_receipt_id cash_receipt_id,
                         cr.pay_from_customer pay_from_customer,
                         cr.customer_site_use_id cr_customer_site_use_id,
                         ps.customer_trx_id customer_trx_id,
                         ps.customer_id,
                         ps.customer_site_use_id customer_site_use_id,
                         trx.waybill_number resolved_matching_number,
                         ps.terms_sequence_number terms_sequence_number,
                         decode(am.match_date_by,
                          'INT_HDR_ATT1', fnd_conc_date.string_to_date(trx.interface_header_attribute1),
                          'INT_HDR_ATT10', fnd_conc_date.string_to_date(trx.interface_header_attribute10),
                          'INT_HDR_ATT11', fnd_conc_date.string_to_date(trx.interface_header_attribute11),
                          'INT_HDR_ATT12', fnd_conc_date.string_to_date(trx.interface_header_attribute12),
                          'INT_HDR_ATT13', fnd_conc_date.string_to_date(trx.interface_header_attribute13),
                          'INT_HDR_ATT14', fnd_conc_date.string_to_date(trx.interface_header_attribute14),
                          'INT_HDR_ATT15', fnd_conc_date.string_to_date(trx.interface_header_attribute15),
                          'INT_HDR_ATT2', fnd_conc_date.string_to_date(trx.interface_header_attribute2),
                          'INT_HDR_ATT3', fnd_conc_date.string_to_date(trx.interface_header_attribute3),
                          'INT_HDR_ATT4', fnd_conc_date.string_to_date(trx.interface_header_attribute4),
                          'INT_HDR_ATT5', fnd_conc_date.string_to_date(trx.interface_header_attribute5),
                          'INT_HDR_ATT6', fnd_conc_date.string_to_date(trx.interface_header_attribute6),
                          'INT_HDR_ATT7', fnd_conc_date.string_to_date(trx.interface_header_attribute7),
                          'INT_HDR_ATT8', fnd_conc_date.string_to_date(trx.interface_header_attribute8),
                          'INT_HDR_ATT9', fnd_conc_date.string_to_date(trx.interface_header_attribute9),
                          'PURCH_ORDER_DATE', trx.purchase_order_date,
                          'TRANS_DATE', trx.trx_date,
                          NULL)  resolved_matching_date,
                         ps.trx_date trx_date,
                         ps.class resolved_matching_class,
                         ps.invoice_currency_code resolved_match_currency,
                         ps.amount_due_original amount_due_original,
                         ps.amount_due_remaining amount_due_remaining,
                         ps.discount_taken_earned discount_taken_earned,
                         ps.discount_taken_unearned discount_taken_unearned,
                         ARPCURR.CURRROUND(ps.amount_due_remaining, ps.invoice_currency_code ) amount_applied,
                         ROUND(NVL(ref.trans_to_receipt_rate,
                                   DECODE(ps.invoice_currency_code, cr.currency_code, NULL,
                                             NVL( ARP_AUTOAPPLY_API.get_cross_curr_rate(
                                                        ref.amount_applied,
                                                        ref.amount_applied_from,
                                                        ps.invoice_currency_code,
                                                        cr.currency_code
                                                        )
                                                  , GL_CURRENCY_API.GET_RATE_SQL(
                                                          ps.invoice_currency_code,
                                                          cr.currency_code,
                                                          cr.receipt_date,
                                                         arp_standard.sysparm.CROSS_CURRENCY_RATE_TYPE )
                                                )
                                         )
                                  ),38) trans_to_receipt_rate,
                         NULL amount_applied_from, -- will be calculated later for xcurr app.
                         ps.payment_schedule_id payment_schedule_id,
                         NULL cons_inv_id,         -- Not used here. Useful for BFBs. So null value selected.
                         UTL_MATCH.edit_distance_similarity(REGEXP_REPLACE(REGEXP_REPLACE(trx.waybill_number, p_trans_format_str, '\2'), p_trans_float_str, ''),
                                                            REGEXP_REPLACE(REGEXP_REPLACE(ref.invoice_reference, p_rem_format_str, '\2'), p_rem_float_str, '')) match_score_value,
                         ps.org_id,
                         ps.term_id term_id,
                         am.automatch_id,
                         am.use_matching_date use_matching_date,
                         am.use_matching_amount use_matching_amount,
                         am.auto_match_threshold auto_match_threshold,
                         amp.priority priority,
                         cr.currency_code receipt_currency_code,
                         cr.receipt_date,
                         ctt.allow_overapplication_flag allow_overapplication_flag,
                         tr.partial_discount_flag partial_discount_flag,
                         RANK() OVER (PARTITION BY trx.waybill_number, ps.customer_site_use_id,
                                      ref.remit_reference_id, ps.customer_trx_id
                              ORDER BY ps.payment_schedule_id) AS  reco_num
          FROM           ar_cash_automatches am,
                         ar_cash_automatch_rule_map amp,
                         ar_cash_remit_refs_interim ref,
                         ar_cash_receipts cr,
                         ra_customer_trx trx,
                         ar_payment_schedules ps,
                         ra_cust_trx_types ctt,
                         ra_terms tr
          WHERE          am.automatch_id               = p_automatch_id
          AND            amp.automatch_id              = am.automatch_id
          AND            amp.automatch_set_id          = ref.automatch_set_id
          AND            ref.worker_number             = p_worker_number
          AND            ref.receipt_reference_status  = 'AR_AM_NEW'
          AND            cr.cash_receipt_id            = ref.cash_receipt_id
          AND            cr.receipt_date BETWEEN NVL(am.start_date, cr.receipt_date)
                                         AND NVL(am.end_date, to_date('31/12/4712','DD/MM/YYYY'))
          AND            trx.waybill_number              IS NOT NULL
          AND            UTL_MATCH.edit_distance_similarity(REGEXP_REPLACE(REGEXP_REPLACE(trx.waybill_number, p_trans_format_str, '\2'), p_trans_float_str, ''),
                                                            REGEXP_REPLACE(REGEXP_REPLACE(ref.invoice_reference, p_rem_format_str, '\2'), p_rem_float_str, '')) >= am.sugg_match_threshold
          AND            ps.customer_trx_id            = trx.customer_trx_id
          AND            ps.selected_for_receipt_batch_id IS NULL
          AND            ps.class                     NOT IN ('PMT', 'GUAR')
          AND            ps.payment_schedule_id        > 0
          AND            ps.status                      = 'OP'
          AND            ps.customer_id IN (SELECT  DECODE(ARP_STANDARD.sysparm.pay_unrelated_invoices_flag,'Y', ps.customer_id,
                                                                 NVL(cr.pay_from_customer, ps.customer_id))
                                            FROM    DUAL
                                            UNION   ALL
                                            SELECT  related_cust_account_id
                                            FROM    hz_cust_acct_relate_all rel
                                            WHERE   rel.cust_account_id = cr.pay_from_customer
                                            AND     rel.bill_to_flag    = 'Y'
                                            AND     rel.status          = 'A'
                                            AND     ARP_STANDARD.sysparm.pay_unrelated_invoices_flag <> 'Y'
                                            UNION   ALL
                                            SELECT  rel.related_cust_account_id
                                            FROM    ar_paying_relationships_v rel,
                                                    hz_cust_accounts acc
                                            WHERE   acc.cust_account_id = cr.pay_from_customer
                                            AND     acc.party_id        = rel.party_id
                                            AND     cr.receipt_date    >= effective_start_date
                                            AND     cr.receipt_date    <= effective_end_date
                                            AND     ARP_STANDARD.sysparm.pay_unrelated_invoices_flag <> 'Y' )
          AND           tr.term_id(+)                 = ps.term_id
          AND           ps.cust_trx_type_id           = ctt.cust_trx_type_id;
    l_selected_recos              selected_recos_table;
    l_current_reco                selected_recos_table;
    l_current_fetch_count         NUMBER;
    l_outer_index                 NUMBER;
    l_current_reco_line           NUMBER;
    got_current_block             BOOLEAN;
  BEGIN
    IF (PG_DEBUG IN ('Y', 'C')) THEN
        log('arp_autoapply_api.insert_waybill_recos(+)');
    END IF;
    OPEN select_recos;
    LOOP
      FETCH select_recos BULK COLLECT INTO l_selected_recos LIMIT G_MAX_ARRAY_SIZE;
      log('Count : '||l_selected_recos.COUNT);
      IF l_selected_recos.COUNT = 0 THEN
        IF l_current_reco.count > 0 THEN
          process_single_reco(l_current_reco
                              , 'WAYBILL NUMBER');
          l_current_reco.DELETE;
          insert_recos(p_request_id);
          clear_reco_lines_struct;
        END IF;
        EXIT;
      END IF;
      l_current_fetch_count := l_selected_recos.COUNT;
      l_outer_index := 1;
      LOOP
        IF l_outer_index > l_current_fetch_count THEN
          insert_recos(p_request_id);
          clear_reco_lines_struct;
          EXIT;
        END IF;
        got_current_block := FALSE;
        LOOP
          l_current_reco_line := l_current_reco.COUNT;
          IF l_current_reco_line = 0 THEN
            copy_current_record(l_current_reco, l_selected_recos, l_outer_index);
            l_outer_index := l_outer_index + 1;
          ELSE
            IF l_current_reco(l_current_reco_line).reco_num < l_selected_recos(l_outer_index).reco_num THEN
              copy_current_record(l_current_reco, l_selected_recos, l_outer_index);
              l_outer_index := l_outer_index + 1;
            ELSE
              got_current_block := TRUE;
            END IF;
          END IF;
          IF got_current_block = TRUE OR l_outer_index > l_current_fetch_count THEN
            EXIT;
          END IF;
        END LOOP;
        IF l_outer_index > l_current_fetch_count THEN
          insert_recos(p_request_id);
          clear_reco_lines_struct;
          EXIT;
        END IF;
        process_single_reco(l_current_reco
                            , 'WAYBILL NUMBER');
        l_current_reco.DELETE;
      END LOOP;
    END LOOP;
    IF (PG_DEBUG IN ('Y', 'C')) THEN
        log('arp_autoapply_api.insert_waybill_recos(-)');
    END IF;
    EXCEPTION
    WHEN OTHERS THEN
          log('Exception from arp_autoapply_api.insert_waybill_recos');
          log(SQLERRM);
          RAISE;
  END insert_waybill_recos;

/*===========================================================================+
 * PROCEDURE                                                                 *
 *     INSERT_BFB_RECOS()                                                    *
 * DESCRIPTION                                                               *
 *   Inserts recommendations for Balance Forward Bills                       *
 * SCOPE - LOCAL                                                             *
 * ARGUMENTS                                                                 *
 *              IN  : p_automatch_id Automatch Rule Identifier               *
 *                    p_use_matching_date Use Matching Date [ALWAYS/For      *
 *                    Duplicates/NULL]                                       *
 *                    p_trans_format_str Transaction Number Format String    *
 *                    p_rem_format_str Reference Number Format String        *
 *                    p_worker_number Current Worker Number                  *
 *                    p_request_id Request ID                                *
 *              OUT : None                                                   *
 *                                                                           *
 * RETURNS      NONE                    				                             *
 * ALGORITHM                                                                 *
 *   1. For all open bfbs satisfying all the setup conditions calculate      *
 *      the matching score of bfb number with the reference number           *
 *      given in the remittance lines (ar_cash_remit_refs_all)               *
 *   2. If match_score > suggested threshold value specified at the AutoMatch*
 *      setup, insert into ar_cash_recos, ar_cash_reco_lines as a recommenda *
 *      -tion.                                                               *
 * NOTES -                                                                   *
 *   1. Tables with _ALL is used in INSERT statement as multi-table insert is*
 *      not possible on secured synonyms (ar_cash_recos and ar_cash_reco_lines)
 *   2. If pay_unrelated_customer is set to 'Yes' or the reference/receipt is*
 *      unidentified then transactions for all the customers are considered. *
 *      Otherwise only the transactions related to the paying customer of the*
 *      receipt are considered.                                              *
 *   3. A bfb can have multiple invoices; which means there is a possibility *
 *      that the receipt is applied against multiple payment schedules for   *
 *      the same transaction. ar_cash_recos contains header level information*
 *      level information like resolved number(bfb number)etc.,              *
 *      where as ar_cash_reco_lines contains the sepecific ps information for*
 *      the resolved transaction.                                            *
 *                                                                           *
 * MODIFICATION HISTORY -  09/03/2009 - Created by AGHORAKA	     	           *
 *                                                                           *
 +===========================================================================*/

  PROCEDURE insert_bfb_recos (p_automatch_id IN NUMBER
                                , p_use_matching_date IN VARCHAR2
                                , p_trans_format_str IN VARCHAR2
                                , p_rem_format_str  IN VARCHAR2
                                , p_trans_float_str IN VARCHAR2
                                , p_rem_float_str IN VARCHAR2
                                , p_worker_number IN NUMBER
                                , p_request_id IN NUMBER) IS
    CURSOR select_recos IS
        SELECT           ref.remit_reference_id remit_reference_id,
                         ref.amount_applied ref_amount_applied,
                         ref.amount_applied_from ref_amount_applied_from,
                         ref.trans_to_receipt_rate ref_trans_to_receipt_rate,
                         ref.cash_receipt_id cash_receipt_id,
                         cr.pay_from_customer pay_from_customer,
                         cr.customer_site_use_id cr_customer_site_use_id,
                         ps.customer_trx_id customer_trx_id,
                         ci.customer_id,
                         ci.site_use_id customer_site_use_id,
                         ci.cons_billing_number resolved_matching_number,
                         ps.terms_sequence_number terms_sequence_number,
                         decode(am.match_date_by, 'BAL_FWD_BILL_DATE', trunc(ci.billing_date), NULL) resolved_matching_date,
                         ps.trx_date trx_date,
                         ps.class resolved_matching_class,
                         ci.currency_code resolved_match_currency,
                         ps.amount_due_original amount_due_original,
                         ps.amount_due_remaining amount_due_remaining,
                         ps.discount_taken_earned discount_taken_earned,
                         ps.discount_taken_unearned discount_taken_unearned,
                         ARPCURR.CURRROUND(ps.amount_due_remaining, ps.invoice_currency_code ) amount_applied,
                         ROUND(NVL(ref.trans_to_receipt_rate,
                                 DECODE(ps.invoice_currency_code, cr.currency_code, NULL,
                                           NVL( ARP_AUTOAPPLY_API.get_cross_curr_rate(
                                                      ref.amount_applied,
                                                      ref.amount_applied_from,
                                                      ps.invoice_currency_code,
                                                      cr.currency_code
                                                      )
                                                , GL_CURRENCY_API.GET_RATE_SQL(
                                                        ps.invoice_currency_code,
                                                        cr.currency_code,
                                                        cr.receipt_date,
                                                       arp_standard.sysparm.CROSS_CURRENCY_RATE_TYPE )
                                              )
                                       )
                                ),38) trans_to_receipt_rate,
                         NULL amount_applied_from, -- will be calculated later for xcurr app.
                         ps.payment_schedule_id payment_schedule_id,
                         ci.cons_inv_id cons_inv_id,
                         UTL_MATCH.edit_distance_similarity(REGEXP_REPLACE(REGEXP_REPLACE(ci.cons_billing_number, p_trans_format_str, '\2'), p_trans_float_str, ''),
                                                            REGEXP_REPLACE(REGEXP_REPLACE(ref.invoice_reference, p_rem_format_str, '\2'), p_rem_float_str, '')) match_score_value,
                         ci.org_id,
                         ps.term_id term_id,
                         am.automatch_id automatch_id,
                         am.use_matching_date use_matching_date,
                         am.use_matching_amount use_matching_amount,
                         am.auto_match_threshold auto_match_threshold,
                         amp.priority priority,
                         cr.currency_code receipt_currency_code,
                         cr.receipt_date receipt_date,
                         ctt.allow_overapplication_flag allow_overapplication_flag,
                         tr.partial_discount_flag partial_discount_flag,
                         RANK() OVER (PARTITION BY ci.cons_billing_number, ci.site_use_id, ref.remit_reference_id
                              ORDER BY ps.due_date, ps.payment_schedule_id) AS  reco_num
          FROM           ar_cash_automatches am,
                         ar_cash_automatch_rule_map amp,
                         ar_cash_remit_refs_interim ref,
                         ar_cash_receipts cr,
                         ar_cons_inv ci,
                         ar_payment_schedules ps,
                         ra_customer_trx trx,
                         ra_cust_trx_types ctt,
                         ra_terms tr
          WHERE          am.automatch_id               = p_automatch_id
          AND            amp.automatch_id              = am.automatch_id
          AND            amp.automatch_set_id          = ref.automatch_set_id
          AND            ref.worker_number             = p_worker_number
          AND            ref.receipt_reference_status  = 'AR_AM_NEW'
          AND            cr.cash_receipt_id            = ref.cash_receipt_id
          AND            cr.receipt_date BETWEEN NVL(am.start_date, cr.receipt_date)
                                         AND NVL(am.end_date, to_date('31/12/4712','DD/MM/YYYY'))
          AND            UTL_MATCH.edit_distance_similarity(REGEXP_REPLACE(REGEXP_REPLACE(ci.cons_billing_number, p_trans_format_str, '\2'), p_trans_float_str, ''),
                                                            REGEXP_REPLACE(REGEXP_REPLACE(ref.invoice_reference, p_rem_format_str, '\2'), p_rem_float_str, ''))  >= am.sugg_match_threshold
          AND            ps.cons_inv_id                = ci.cons_inv_id
          AND            ps.selected_for_receipt_batch_id IS NULL
          AND            ps.class                     NOT IN ('PMT', 'GUAR')
          AND            ps.payment_schedule_id        > 0
          AND            ps.status                      = 'OP'
          AND            ps.customer_id IN (SELECT  DECODE(ARP_STANDARD.sysparm.pay_unrelated_invoices_flag,'Y', ps.customer_id,
                                                                 NVL(cr.pay_from_customer, ps.customer_id))
                                            FROM    DUAL
                                            UNION   ALL
                                            SELECT  related_cust_account_id
                                            FROM    hz_cust_acct_relate_all rel
                                            WHERE   rel.cust_account_id = cr.pay_from_customer
                                            AND     rel.bill_to_flag    = 'Y'
                                            AND     rel.status          = 'A'
                                            AND     ARP_STANDARD.sysparm.pay_unrelated_invoices_flag <> 'Y'
                                            UNION   ALL
                                            SELECT  rel.related_cust_account_id
                                            FROM    ar_paying_relationships_v rel,
                                                    hz_cust_accounts acc
                                            WHERE   acc.cust_account_id = cr.pay_from_customer
                                            AND     acc.party_id        = rel.party_id
                                            AND     cr.receipt_date    >= effective_start_date
                                            AND     cr.receipt_date    <= effective_end_date
                                            AND     ARP_STANDARD.sysparm.pay_unrelated_invoices_flag <> 'Y'  )
          AND           trx.customer_trx_id           = ps.customer_trx_id
          AND           tr.term_id(+)                 = ps.term_id
          AND           ps.cust_trx_type_id           = ctt.cust_trx_type_id;
    l_selected_recos              selected_recos_table;
    l_current_reco                selected_recos_table;
    l_current_fetch_count         NUMBER;
    l_outer_index                 NUMBER;
    l_current_reco_line           NUMBER;
    got_current_block             BOOLEAN;
    BEGIN
    IF (PG_DEBUG IN ('Y', 'C')) THEN
        log('arp_autoapply_api.insert_bfb_recos(+)');
    END IF;

    OPEN select_recos;
    LOOP
      FETCH select_recos BULK COLLECT INTO l_selected_recos LIMIT G_MAX_ARRAY_SIZE;
      log('Count : '||l_selected_recos.COUNT);
      IF l_selected_recos.COUNT = 0 THEN
        IF l_current_reco.count > 0 THEN
          process_single_reco(l_current_reco
                              , 'BALANCE FORWARD BILL');
          l_current_reco.DELETE;
          insert_recos(p_request_id);
          clear_reco_lines_struct;
        END IF;
        EXIT;
      END IF;
      l_current_fetch_count := l_selected_recos.COUNT;
      l_outer_index := 1;
      LOOP
        IF l_outer_index > l_current_fetch_count THEN
          insert_recos(p_request_id);
          clear_reco_lines_struct;
          EXIT;
        END IF;
        got_current_block := FALSE;
        LOOP
          l_current_reco_line := l_current_reco.COUNT;
          IF l_current_reco_line = 0 THEN
            log('If Statement');
            copy_current_record(l_current_reco, l_selected_recos, l_outer_index);
            l_outer_index := l_outer_index + 1;
          ELSE
            IF l_current_reco(l_current_reco_line).reco_num < l_selected_recos(l_outer_index).reco_num THEN
              log('Else-If');
              copy_current_record(l_current_reco, l_selected_recos, l_outer_index);
              l_outer_index := l_outer_index + 1;
            ELSE
              log('Else-Else');
              got_current_block := TRUE;
            END IF;
          END IF;
          IF got_current_block = TRUE OR l_outer_index > l_current_fetch_count THEN
            EXIT;
          END IF;
        END LOOP;
        IF l_outer_index > l_current_fetch_count THEN
          insert_recos(p_request_id);
          clear_reco_lines_struct;
          EXIT;
        END IF;
        process_single_reco(l_current_reco
                            , 'BALANCE FORWARD BILL');
        l_current_reco.DELETE;
      END LOOP;
    END LOOP;

    IF (PG_DEBUG IN ('Y', 'C')) THEN
        log('arp_autoapply_api.insert_bfb_recos(-)');
    END IF;
    EXCEPTION
    WHEN OTHERS THEN
          log('Exception from arp_autoapply_api.insert_bfb_recos');
          log(SQLERRM);
          RAISE;
  END insert_bfb_recos;
/*===========================================================================+
 * PROCEDURE                                                                 *
 *     INSERT_REFERENCE_RECOS()                                              *
 * DESCRIPTION                                                               *
 *   Inserts recommendations for transaction numbers (Matched with reference *
 *   number ra_customer_trx.ct_reference)                                    *
 * SCOPE - LOCAL                                                             *
 * ARGUMENTS                                                                 *
 *              IN  : p_automatch_id Automatch Rule Identifier               *
 *                    p_use_matching_date Use Matching Date [ALWAYS/For      *
 *                    Duplicates/NULL]                                       *
 *                    p_trans_format_str Transaction Number Format String    *
 *                    p_rem_format_str Reference Number Format String        *
 *                    p_worker_number Current Worker Number                  *
 *                    p_request_id Request ID                                *
 *              OUT : None                                                   *
 *                                                                           *
 * RETURNS      NONE                    				                             *
 * ALGORITHM                                                                 *
 *   1. For all open transactions satisfying all the setup conditions calculate
 *      the matching score of trx reference number with the reference number *
 *      given in the remittance lines (ar_cash_remit_refs_all)               *
 *   2. If match_score > suggested threshold value specified at the AutoMatch*
 *      setup, insert into ar_cash_recos, ar_cash_reco_lines as a recommenda *
 *      -tion.                                                               *
 * NOTES -                                                                   *
 *   1. Tables with _ALL is used in INSERT statement as multi-table insert is*
 *      not possible on secured synonyms (ar_cash_recos and ar_cash_reco_lines)
 *   2. If pay_unrelated_customer is set to 'Yes' or the reference/receipt is*
 *      unidentified then transactions for all the customers are considered. *
 *      Otherwise only the transactions related to the paying customer of the*
 *      receipt are considered.                                              *
 *   3. An invoice can have multiple installments; which means there is a    *
 *      possibility that the receipt is applied against multiple payment     *
 *      schedules for the same transaction. ar_cash_recos contains header    *
 *      level information like resolved number(trx number), trx date etc.,   *
 *      where as ar_cash_reco_lines contains the sepecific ps information for*
 *      the resolved transaction.                                            *
 *                                                                           *
 * MODIFICATION HISTORY -  09/03/2009 - Created by AGHORAKA	     	           *
 *                                                                           *
 +===========================================================================*/

  PROCEDURE insert_reference_recos (p_automatch_id IN NUMBER
                                  , p_use_matching_date IN VARCHAR2
                                  , p_trans_format_str IN VARCHAR2
                                  , p_rem_format_str  IN VARCHAR2
                                  , p_trans_float_str IN VARCHAR2
                                  , p_rem_float_str IN VARCHAR2
                                  , p_worker_number IN NUMBER
                                  , p_request_id IN NUMBER) IS
    CURSOR select_recos IS
      SELECT         ref.remit_reference_id remit_reference_id,
                       ref.amount_applied ref_amount_applied,
                       ref.amount_applied_from ref_amount_applied_from,
                       ref.trans_to_receipt_rate ref_trans_to_receipt_rate,
                       ref.cash_receipt_id cash_receipt_id,
                       cr.pay_from_customer pay_from_customer,
                       cr.customer_site_use_id cr_customer_site_use_id,
                       ps.customer_trx_id customer_trx_id,
                       ps.customer_id,
                       ps.customer_site_use_id customer_site_use_id,
                       ps.trx_number resolved_matching_number,
                       ps.terms_sequence_number terms_sequence_number,
                       decode(am.match_date_by,
                        'INT_HDR_ATT1', fnd_conc_date.string_to_date(trx.interface_header_attribute1),
                        'INT_HDR_ATT10', fnd_conc_date.string_to_date(trx.interface_header_attribute10),
                        'INT_HDR_ATT11', fnd_conc_date.string_to_date(trx.interface_header_attribute11),
                        'INT_HDR_ATT12', fnd_conc_date.string_to_date(trx.interface_header_attribute12),
                        'INT_HDR_ATT13', fnd_conc_date.string_to_date(trx.interface_header_attribute13),
                        'INT_HDR_ATT14', fnd_conc_date.string_to_date(trx.interface_header_attribute14),
                        'INT_HDR_ATT15', fnd_conc_date.string_to_date(trx.interface_header_attribute15),
                        'INT_HDR_ATT2', fnd_conc_date.string_to_date(trx.interface_header_attribute2),
                        'INT_HDR_ATT3', fnd_conc_date.string_to_date(trx.interface_header_attribute3),
                        'INT_HDR_ATT4', fnd_conc_date.string_to_date(trx.interface_header_attribute4),
                        'INT_HDR_ATT5', fnd_conc_date.string_to_date(trx.interface_header_attribute5),
                        'INT_HDR_ATT6', fnd_conc_date.string_to_date(trx.interface_header_attribute6),
                        'INT_HDR_ATT7', fnd_conc_date.string_to_date(trx.interface_header_attribute7),
                        'INT_HDR_ATT8', fnd_conc_date.string_to_date(trx.interface_header_attribute8),
                        'INT_HDR_ATT9', fnd_conc_date.string_to_date(trx.interface_header_attribute9),
                        'PURCH_ORDER_DATE', trx.purchase_order_date,
                        'TRANS_DATE', trx.trx_date,
                        NULL)  resolved_matching_date,
                       ps.trx_date trx_date,
                       ps.class resolved_matching_class,
                       ps.invoice_currency_code resolved_match_currency,
                       ps.amount_due_original amount_due_original,
                       ps.amount_due_remaining amount_due_remaining,
                       ps.discount_taken_earned discount_taken_earned,
                       ps.discount_taken_unearned discount_taken_unearned,
                       ARPCURR.CURRROUND(ps.amount_due_remaining, ps.invoice_currency_code ) amount_applied,
                       ROUND(NVL(ref.trans_to_receipt_rate,
                                 DECODE(ps.invoice_currency_code, cr.currency_code, NULL,
                                           NVL( ARP_AUTOAPPLY_API.get_cross_curr_rate(
                                                      ref.amount_applied,
                                                      ref.amount_applied_from,
                                                      ps.invoice_currency_code,
                                                      cr.currency_code
                                                      )
                                                , GL_CURRENCY_API.GET_RATE_SQL(
                                                        ps.invoice_currency_code,
                                                        cr.currency_code,
                                                        cr.receipt_date,
                                                       arp_standard.sysparm.CROSS_CURRENCY_RATE_TYPE )
                                              )
                                       )
                                ),38) trans_to_receipt_rate,
                       NULL amount_applied_from, -- will be calculated later for xcurr app.
                       ps.payment_schedule_id payment_schedule_id,
                       NULL cons_inv_id,         -- Not used here. Useful for BFBs. So null value selected.
                       UTL_MATCH.edit_distance_similarity(REGEXP_REPLACE(REGEXP_REPLACE(trx.ct_reference, p_trans_format_str, '\2'), p_trans_float_str, ''),
                                                          REGEXP_REPLACE(REGEXP_REPLACE(ref.invoice_reference, p_rem_format_str, '\2'), p_rem_float_str, '')) match_score_value,
                       ps.org_id,
                       ps.term_id term_id,
                       am.automatch_id automatch_id,
                       am.use_matching_date use_matching_date,
                       am.use_matching_amount use_matching_amount,
                       am.auto_match_threshold auto_match_threshold,
                       amp.priority priority,
                       cr.currency_code receipt_currency_code,
                       cr.receipt_date receipt_date,
                       ctt.allow_overapplication_flag allow_overapplication_flag,
                       tr.partial_discount_flag partial_discount_flag,
                       RANK() OVER (PARTITION BY trx.ct_reference, ps.customer_site_use_id,
                                    ref.remit_reference_id, ps.customer_trx_id
                            ORDER BY ps.payment_schedule_id) AS  reco_num
        FROM           ar_cash_automatches am,
                       ar_cash_automatch_rule_map amp,
                       ar_cash_remit_refs_interim ref,
                       ar_cash_receipts cr,
                       ar_payment_schedules ps,
                       ra_customer_trx trx,
                       ra_cust_trx_types ctt,
                       ra_terms tr
        WHERE          am.automatch_id               = p_automatch_id
        AND            amp.automatch_id              = am.automatch_id
        AND            amp.automatch_set_id          = ref.automatch_set_id
        AND            ref.worker_number             = p_worker_number
        AND            ref.receipt_reference_status = 'AR_AM_NEW'
        AND            cr.cash_receipt_id            = ref.cash_receipt_id
        AND            cr.receipt_date BETWEEN NVL(am.start_date, cr.receipt_date)
                                       AND NVL(am.end_date, to_date('31/12/4712','DD/MM/YYYY'))
        AND            trx.ct_reference              IS NOT NULL
        AND            UTL_MATCH.edit_distance_similarity(REGEXP_REPLACE(REGEXP_REPLACE(trx.ct_reference, p_trans_format_str, '\2'), p_trans_float_str, ''),
                                                          REGEXP_REPLACE(REGEXP_REPLACE(ref.invoice_reference, p_rem_format_str, '\2'), p_rem_float_str, '')) >= am.sugg_match_threshold
        AND            ps.customer_trx_id            = trx.customer_trx_id
        AND            ps.selected_for_receipt_batch_id IS NULL
        AND            ps.class                     NOT IN ('PMT', 'GUAR')
        AND            ps.payment_schedule_id        > 0
        AND            ps.status                    = 'OP'
        AND            ps.terms_sequence_number     = NVL(ref.installment_reference,
                                                          ps.terms_sequence_number)
        AND            ps.customer_id IN (SELECT  DECODE(ARP_STANDARD.sysparm.pay_unrelated_invoices_flag,'Y', ps.customer_id,
                                                               NVL(cr.pay_from_customer, ps.customer_id))
                                          FROM    DUAL
                                          UNION   ALL
                                          SELECT  related_cust_account_id
                                          FROM    hz_cust_acct_relate_all rel
                                          WHERE   rel.cust_account_id = cr.pay_from_customer
                                          AND     rel.bill_to_flag    = 'Y'
                                          AND     rel.status          = 'A'
                                          AND     ARP_STANDARD.sysparm.pay_unrelated_invoices_flag <> 'Y'
                                          UNION   ALL
                                          SELECT  rel.related_cust_account_id
                                          FROM    ar_paying_relationships_v rel,
                                                  hz_cust_accounts acc
                                          WHERE   acc.cust_account_id = cr.pay_from_customer
                                          AND     acc.party_id        = rel.party_id
                                          AND     cr.receipt_date   >= effective_start_date
                                          AND     cr.receipt_date   <= effective_end_date
                                          AND     ARP_STANDARD.sysparm.pay_unrelated_invoices_flag <> 'Y' )
        AND           tr.term_id(+)                 = ps.term_id
        AND           ps.cust_trx_type_id           = ctt.cust_trx_type_id;
    l_selected_recos              selected_recos_table;
    l_current_reco                selected_recos_table;
    l_current_fetch_count         NUMBER;
    l_outer_index                 NUMBER;
    l_current_reco_line           NUMBER;
    got_current_block             BOOLEAN;
  BEGIN
    IF (PG_DEBUG IN ('Y', 'C')) THEN
          log('arp_autoapply_api.insert_reference_recos(+)');
    END IF;
      OPEN select_recos;
    LOOP
      FETCH select_recos BULK COLLECT INTO l_selected_recos LIMIT G_MAX_ARRAY_SIZE;
      log('Count : '||l_selected_recos.COUNT);
      IF l_selected_recos.COUNT = 0 THEN
        IF l_current_reco.count > 0 THEN
          process_single_reco(l_current_reco
                              , 'REFERENCE NUMBER');
          l_current_reco.DELETE;
          insert_recos(p_request_id);
          clear_reco_lines_struct;
        END IF;
        EXIT;
      END IF;
      l_current_fetch_count := l_selected_recos.COUNT;
      l_outer_index := 1;
      LOOP
        IF l_outer_index > l_current_fetch_count THEN
          insert_recos(p_request_id);
          clear_reco_lines_struct;
          EXIT;
        END IF;
        got_current_block := FALSE;
        LOOP
          l_current_reco_line := l_current_reco.COUNT;
          IF l_current_reco_line = 0 THEN
            copy_current_record(l_current_reco, l_selected_recos, l_outer_index);
            l_outer_index := l_outer_index + 1;
          ELSE
            IF l_current_reco(l_current_reco_line).reco_num < l_selected_recos(l_outer_index).reco_num THEN
              copy_current_record(l_current_reco, l_selected_recos, l_outer_index);
              l_outer_index := l_outer_index + 1;
            ELSE
              got_current_block := TRUE;
            END IF;
          END IF;
          IF got_current_block = TRUE OR l_outer_index > l_current_fetch_count THEN
            EXIT;
          END IF;
        END LOOP;
        IF l_outer_index > l_current_fetch_count THEN
          insert_recos(p_request_id);
          clear_reco_lines_struct;
          EXIT;
        END IF;
        process_single_reco(l_current_reco
                            , 'REFERENCE NUMBER');
        l_current_reco.DELETE;
      END LOOP;
    END LOOP;
    IF (PG_DEBUG IN ('Y', 'C')) THEN
      log('arp_autoapply_api.insert_reference_recos(-)');
    END IF;
    EXCEPTION
    WHEN OTHERS THEN
          log('Exception from arp_autoapply_api.insert_reference_recos');
          log(SQLERRM);
          RAISE;
  END insert_reference_recos;

/*===========================================================================+
 * PROCEDURE                                                                 *
 *     VALIDATE_TRX_RECOS()                                                  *
 * DESCRIPTION                                                               *
 *   Validates the recommendations generated for each reference. At the end  *
 *   of validation, only one valid recommendation should exist for application
 *   for each reference.                                                     *
 * SCOPE - LOCAL                                                             *
 * ARGUMENTS                                                                 *
 *              IN  : p_worker_number Current Worker Number                  *
 *                    p_req_id Request ID                                    *
 *              OUT : None                                                   *
 *                                                                           *
 * RETURNS      NONE                    				                             *
 * ALGORITHM                                                                 *
 *   A recommendation will be unvalid for one of the following reasons :     *
 *   1. AR_AA_BELOW_TRX_TSLD : Header Level Validation                       *
 *      Match Score is less than Automatic Threshold value set at the        *
 *      automatch rule setup.                                                *
 *   2. AR_AA_DATE_MISMATCH : Header Level Validation                        *
 *      If Use_Matching_Date = 'ALWAYS' and if the matching_date provided at *
 *      the reference is not equal to the recommendation date.               *
 *   3. AR_AA_AMOUNT_MISMATCH : Line Level Validation                        *
 *      If Use_Matching_Amount = 'ALWAYS' and if the amount_applied provided *
 *      at the reference is not equal to the open balance of transaction.    *
 *   4. AR_AA_CURR_NO_MATCH : Line Level Validation                          *
 *      If reference currency code, if provided, is not equal to             *
 *      recommendation currency code.                                        *
 *   5. AR_AA_NO_XCURR_RATE : Line Level Validation                          *
 *      If exchange rate is not provided in case of a cross currency app.    *
 *   6. AR_AA_INVALID_RATE : Line Level Validation                           *
 *      If invalid rate is provided for fixed rate currencies.               *
 *   7. AR_AA_NAT_APP_VIO : Line Level Validation                            *
 *      Natural Application Violation                                        *
 *   8. AR_AA_OVER_APPLN : Line Level Validation                             *
 *      Over Application                                                     *
 *   9. AR_AA_MUL_APP_TRX : Line Level Validation                            *
 *      If the same PS is already applied by the same receipt.               *
 *  10. AR_AA_MUL_RECO_TRX : Line Level Validtion                            *
 *      If the same transaction is selected for different references.        *
 *  11. AR_AA_DUPLICATE_RECOS : Header Level Validation                      *
 *      If two recommendations with same number is selected for a reference. *
 *  12. AR_AA_MULT_RECOS : Header Level Validation                           *
 *      If more than one recommendations are valid for a reference.          *
 *  13. AR_AA_CUST_NOT_UNIQUE : Header Level Validation                      *
 *      If all the recommendations does not belong to a same customer in case*
 *      if the receipt is unidentified.                                      *
 *  Finally at the end of validation the valid payment schedules selected    *
 *  for application are locked. This is done to counter the possibility of a *
 *  deadlock if the process is run with multiple workers. In such a case a PS*
 *  may be selected for different references for different workers.          *
 *  Final valid status at the end of validation : AR_AA_INV_LOCKED           *
 * NOTES -                                                                   *
 *   1. Validate Recos is called once per each worker.                       *
 *
 * MODIFICATION HISTORY -  09/03/2009 - Created by AGHORAKA	     	           *
 *                                                                           *
 +===========================================================================*/
PROCEDURE validate_trx_recos( p_req_id IN NUMBER
                              , p_worker_number IN NUMBER) IS
    TYPE psid_tab IS TABLE OF ar_payment_schedules.payment_schedule_id%TYPE INDEX BY PLS_INTEGER;
    locked_ps_records psid_tab;
    BEGIN
      IF (PG_DEBUG IN ('Y', 'C')) THEN
        log('arp_autoapply_api.validate_trx_recos(+)');
      END IF;

     /* * If Use_Matching_Date is set to 'ALWAYS' in Automatch Rule Setup *
        * resolved_matching_date of the recommendations must equal the    *
        * reference matching date provided by the user. If the date is not*
        * provided in 'Remittance Lines', then it will be treated as a mis*
        * match.                                                          * */

     UPDATE ar_cash_recos rec
     SET rec.match_reason_code = 'AR_AA_DATE_MISMATCH'
     WHERE rec.request_id = p_req_id
     AND    match_reason_code      = 'AR_AM_INV_THRESHOLD'
     AND EXISTS ( SELECT 'Date Not Matching'
                 FROM ar_cash_automatches am,
                      ar_cash_remit_refs_interim ref
                 WHERE am.automatch_id = rec.automatch_id
                 AND   ref.remit_reference_id = rec.remit_reference_id
                 AND   am.use_matching_date = 'ALWAYS'
                 AND   trunc(rec.resolved_matching_date) <> NVL(ref.matching_reference_date, to_date('31/12/4712','DD/MM/YYYY'))
               );
     IF (PG_DEBUG IN ('Y', 'C')) THEN
          log('No. of recos updated to Date Mismatch: ' || SQL%ROWCOUNT );
     END IF;

     UPDATE ar_cash_reco_lines l
     SET    recommendation_reason  = 'AR_AA_DATE_MISMATCH'
     WHERE  recommendation_id     IN (SELECT recommendation_id
                                     FROM   ar_cash_recos r
                                     WHERE    match_reason_code        = 'AR_AA_DATE_MISMATCH'
                                     AND    request_id               = l.request_id)
     AND    request_id             = p_req_id;

     IF (PG_DEBUG IN ('Y', 'C')) THEN
          log('No. of reco lines updated to Date Mismatch: ' || SQL%ROWCOUNT );
     END IF;

     /* * If Use_Matching_Amount is set to 'Yes', then the transaction  *
        * balance must equal the amount applied of the remittance line  * */
     /*UPDATE ar_cash_recos rec
     SET rec.match_reason_code = 'AR_AA_AMOUNT_MISMATCH'
     WHERE rec.request_id = p_req_id
     AND   match_reason_code      = 'AR_AM_INV_THRESHOLD'
     AND EXISTS ( SELECT ref.remit_reference_id
                FROM  ar_cash_reco_lines lin,
                      ar_cash_automatches am,
                      ar_cash_remit_refs_interim ref
                WHERE lin.request_id = p_req_id
                AND   am.automatch_id = rec.automatch_id
                AND   am.use_matching_amount = 'ALWAYS'
                AND   rec.recommendation_id = lin.recommendation_id
                AND   ref.remit_reference_id = rec.remit_reference_id
                GROUP BY ref.remit_reference_id, NVL(ref.amount_applied, ARPCURR.CURRROUND((ref.amount_applied_from / NVL(lin.trans_to_receipt_rate, 1)), lin.receipt_currency_code))
                HAVING SUM(lin.amount_applied) <> NVL(ref.amount_applied, ARPCURR.CURRROUND((ref.amount_applied_from / NVL(lin.trans_to_receipt_rate, 1)), lin.receipt_currency_code))
               );

      IF (PG_DEBUG IN ('Y', 'C')) THEN
          log('No. of recos updated to Amount Mismatch: ' || SQL%ROWCOUNT );
      END IF;

      UPDATE ar_cash_reco_lines l
      SET    recommendation_reason  = 'AR_AA_AMOUNT_MISMATCH'
      WHERE  recommendation_id     IN (SELECT recommendation_id
                                     FROM   ar_cash_recos r
                                     WHERE    match_reason_code        = 'AR_AA_AMOUNT_MISMATCH'
                                     AND    request_id               = l.request_id)
      AND    request_id             = p_req_id;

      IF (PG_DEBUG IN ('Y', 'C')) THEN
          log('No. of reco lines updated to Amount Mismatch: ' || SQL%ROWCOUNT );
      END IF;*/

     --Do not apply the transaction if the currency provided is different to that of the transaction
     UPDATE ar_cash_reco_lines l
     SET    recommendation_reason  = 'AR_AA_CURR_NO_MATCH'
     WHERE  EXISTS                   (SELECT 'Inconsistent Currency'
                                      FROM   ar_cash_recos rec,
                                             ar_cash_remit_refs_interim ref,
                                             ar_payment_schedules ps
                                      WHERE  rec.recommendation_id    = l.recommendation_id
                                      AND    ref.remit_reference_id   = rec.remit_reference_id
                                      AND    ref.worker_number        = p_worker_number
                                      AND    ps.payment_schedule_id   = l.payment_schedule_id
                                      AND    ps.invoice_currency_code<> NVL(ref.invoice_currency_code,
                                                                            ps.invoice_currency_code))
     AND    request_id             = p_req_id
     AND    recommendation_reason  = 'AR_AM_INV_THRESHOLD';

     IF (PG_DEBUG IN ('Y', 'C')) THEN
          log('No. of recos updated to No Currency Match: ' || SQL%ROWCOUNT );
     END IF;

     --Do not autoapply a PS if any 2 of amount applied, amount applied from and trans to receipt rate
     --is not provided in the reference
     UPDATE ar_cash_reco_lines l
     SET    recommendation_reason  = 'AR_AA_NO_XCURR_RATE'
     WHERE  EXISTS                   (SELECT 'No X Rate Info'
                                      FROM   ar_payment_schedules ps
                                      WHERE  l.payment_schedule_id    = ps.payment_schedule_id
                                      AND    l.receipt_currency_code <> ps.invoice_currency_code
                                      AND    (l.trans_to_receipt_rate  IS NULL
                                             OR l.trans_to_receipt_rate = -1))
     AND    request_id             = p_req_id
     AND    recommendation_reason  = 'AR_AM_INV_THRESHOLD';

     IF (PG_DEBUG IN ('Y', 'C')) THEN
          log('No. of recos updated to No Exchange Rate: ' || SQL%ROWCOUNT );
     END IF;

     --Invalid rate provided for fixed rate currencies
     UPDATE ar_cash_reco_lines l
     SET    recommendation_reason  = 'AR_AA_INVALID_RATE'
     WHERE (EXISTS                   (SELECT 'Same Currency'
                                      FROM   ar_payment_schedules ps
                                      WHERE  l.payment_schedule_id    = ps.payment_schedule_id
                                      AND    l.receipt_currency_code  = ps.invoice_currency_code
                                      AND    l.trans_to_receipt_rate  IS NOT NULL)
       OR   EXISTS                   (SELECT 'Wrong rate for fixed rate currency'
                                      FROM   ar_payment_schedules ps
                                      WHERE  l.payment_schedule_id    = ps.payment_schedule_id
                                      AND    GL_CURRENCY_API.IS_FIXED_RATE(ps.invoice_currency_code,
                                                                           l.receipt_currency_code,
                                                                           l.receipt_date) = 'Y'
                                      AND    l.trans_to_receipt_rate <> ROUND(GL_CURRENCY_API.GET_RATE_SQL(
                                                                                   ps.invoice_currency_code,
                                                                                   l.receipt_currency_code,
                                                                                   l.receipt_date,
                                                                                   null), 38)))
     AND    request_id             = p_req_id
     AND    recommendation_reason  = 'AR_AM_INV_THRESHOLD';

     IF (PG_DEBUG IN ('Y', 'C')) THEN
          log('No. of recos updated to Invalid Rate: ' || SQL%ROWCOUNT );
     END IF;

     --Update the status if the application is not a  natural application or an over application
     UPDATE ar_cash_reco_lines l
     SET    recommendation_reason  = (SELECT CASE  WHEN SIGN(l.amount_applied*ps.amount_due_remaining) = -1
                                                                         THEN 'AR_AA_NAT_APP_VIO'
                                                   ELSE recommendation_reason
                                             END
                                      FROM   ar_payment_schedules ps
                                      WHERE  ps.payment_schedule_id = l.payment_schedule_id)
     WHERE    request_id             = p_req_id
     AND    recommendation_reason  = 'AR_AM_INV_THRESHOLD';

     IF (PG_DEBUG IN ('Y', 'C')) THEN
          log('No. of recos updated to Nat Appn Vio/Over Appn: ' || SQL%ROWCOUNT );
     END IF;

     --Prevent same PS applied twice to the same receipt
     UPDATE ar_cash_reco_lines l
     SET    recommendation_reason  = 'AR_AA_MUL_APP_TRX'
     WHERE (   EXISTS               (SELECT 'PS already Applied'
                                      FROM   ar_cash_recos rec,
                                             ar_cash_remit_refs_interim ref,
                                             ar_receivable_applications ra
                                      WHERE  rec.recommendation_id    = l.recommendation_id
                                      AND    ref.remit_reference_id   = rec.remit_reference_id
                                      AND    ra.cash_receipt_id       = ref.cash_receipt_id
                                      AND    ref.worker_number        = p_worker_number
                                      AND    l.payment_schedule_id    = ra.applied_payment_schedule_id
                                      AND    ra.display               = 'Y')
           )
     AND    request_id             = p_req_id
     AND    recommendation_reason  = 'AR_AM_INV_THRESHOLD';

     IF (PG_DEBUG IN ('Y', 'C')) THEN
          log('No. of recos updated to Multiple Application on same receipt: ' || SQL%ROWCOUNT );
     END IF;

     /* Prevent application if the same PS is selected for any other reco
        Since we are validating per worker, at the end of validation there is
        a chance that same PS is selected by two receipts from diff workers */
     /* UPDATE ar_cash_reco_lines l
     SET    recommendation_reason  = 'AR_AA_MUL_RECO_TRX'
     WHERE  EXISTS                   (SELECT 'PS eligible for more than one reference'
                                      FROM   ar_cash_reco_lines l1,
                                             ar_cash_recos rec,
                                             ar_cash_recos rec1
                                      WHERE  l.payment_schedule_id    = l1.payment_schedule_id
                                      AND    l.recommendation_id     <> l1.recommendation_id
                                      AND    rec.recommendation_id = l.recommendation_id
                                      AND    rec1.recommendation_id = l1.recommendation_id
                                      AND    rec.remit_reference_id <> rec1.remit_reference_id
                                      AND    l1.recommendation_reason = 'AR_AM_INV_THRESHOLD'
                                      AND    l1.request_id         = p_req_id)
     AND    request_id             = p_req_id
     AND    recommendation_reason  = 'AR_AM_INV_THRESHOLD';

     IF (PG_DEBUG IN ('Y', 'C')) THEN
          log('No. of recos updated to Same Trx for multiple Recos: ' || SQL%ROWCOUNT );
     END IF; */
     /*
     UPDATE ar_cash_recos rec
     SET    rec.match_reason_code = 'AR_AA_DUPLICATE_RECOS'
     WHERE  rec.recommendation_id IN
            (SELECT  recommendation_id
            FROM    ar_cash_recos
            WHERE   request_id = p_req_id
            AND     (resolved_matching_number, match_resolved_using, remit_reference_id) IN
            (
            SELECT  resolved_matching_number, match_resolved_using, remit_reference_id
            FROM    ar_cash_recos rec
            WHERE   rec.request_id = p_req_id
            AND     rec.match_reason_code      = 'AR_AM_INV_THRESHOLD'
            GROUP BY resolved_matching_number, match_resolved_using, remit_reference_id
            HAVING COUNT(*) > 1
            )
            MINUS
            SELECT  recommendation_id
            FROM    ar_cash_recos rec
            WHERE   request_id = p_req_id
            AND     (resolved_matching_number, match_resolved_using, remit_reference_id, resolved_matching_date) IN
            (
            SELECT  resolved_matching_number, match_resolved_using, remit_reference_id, resolved_matching_date
            FROM    ar_cash_recos rec1
            WHERE   request_id = p_req_id
            AND     (resolved_matching_number, match_resolved_using, remit_reference_id) IN
            (
            SELECT  resolved_matching_number, match_resolved_using, remit_reference_id
            FROM    ar_cash_recos rec
            WHERE   rec.request_id = p_req_id
            GROUP BY resolved_matching_number, match_resolved_using, remit_reference_id
            HAVING COUNT(*) > 1
            )
            AND     trunc(rec1.resolved_matching_date) = (SELECT  decode(am.use_matching_date,
                                                            'DUPLICATE', nvl(ref.matching_reference_date, rec1.resolved_matching_date),
                                                            rec1.resolved_matching_date)
                                              FROM    ar_cash_remit_refs_interim ref,
                                                      ar_cash_automatches am
                                              WHERE   ref.worker_number = p_worker_number
                                              AND     ref.remit_reference_id = rec1.remit_reference_id
                                              AND     am.automatch_id = rec1.automatch_id)
             AND     EXISTS ( SELECT ref.remit_reference_id
                            FROM  ar_cash_reco_lines lin,
                                  ar_cash_automatches am,
                                  ar_cash_remit_refs_interim ref
                            WHERE lin.request_id = p_req_id
                            AND   am.automatch_id = rec.automatch_id
                            AND   am.use_matching_amount = 'DUPLICATE'
                            AND   rec.recommendation_id = lin.recommendation_id
                            AND   ref.remit_reference_id = rec1.remit_reference_id
                            GROUP BY ref.remit_reference_id, NVL(ref.amount_applied, ARPCURR.CURRROUND((ref.amount_applied_from / NVL(lin.trans_to_receipt_rate, 1)), lin.receipt_currency_code))
                            HAVING SUM(lin.amount_applied) = NVL(ref.amount_applied, ARPCURR.CURRROUND((ref.amount_applied_from / NVL(lin.trans_to_receipt_rate, 1)), lin.receipt_currency_code))
                           )
            GROUP BY resolved_matching_number, match_resolved_using, remit_reference_id, resolved_matching_date
            HAVING count(*) = 1
            )
            AND    rec.match_reason_code      = 'AR_AM_INV_THRESHOLD'
            )
     AND    rec.request_id             = p_req_id
     AND    rec.match_reason_code      = 'AR_AM_INV_THRESHOLD';

     IF (PG_DEBUG IN ('Y', 'C')) THEN
          log('No. of recos updated to Duplicate Recos: ' || SQL%ROWCOUNT );
     END IF; */

     UPDATE ar_cash_recos rec
     SET    rec.match_reason_code  = 'AR_AA_DUPLICATE_RECOS'
     WHERE  request_id = p_req_id
     AND (resolved_matching_number, match_resolved_using, remit_reference_id )
     IN  ( SELECT  resolved_matching_number,
                      match_resolved_using     ,
                      remit_reference_id
             FROM     ar_cash_recos rec
             WHERE    rec.request_id        = p_req_id
                  AND rec.match_reason_code = 'AR_AM_INV_THRESHOLD'
             GROUP BY resolved_matching_number,
                      match_resolved_using    ,
                      remit_reference_id
             HAVING   COUNT(*) > 1);

     IF (PG_DEBUG IN ('Y', 'C')) THEN
          log('No. of recos updated to Duplicate Recos: ' || SQL%ROWCOUNT );
     END IF;

     DECLARE
      CURSOR dup_recos_cur IS
      SELECT rec.recommendation_id,
             rec.remit_reference_id,
             rec.resolved_matching_date,
             ref.matching_reference_date,
             sum(NVL(lin.amount_applied, 0)) amount_applied,
             sum(NVL(lin.discount_taken_earned, 0)) discount_taken_earned,
             ps.amount_due_remaining,
             lin.customer_trx_id,
             lin.receipt_date,
             am.use_matching_date,
             am.use_matching_amount
      FROM   ar_cash_recos rec,
             ar_cash_reco_lines lin,
             ar_cash_remit_refs_interim ref,
             ar_cash_automatches am,
             ar_payment_schedules ps
      WHERE  rec.request_id = p_req_id
      AND    rec.match_reason_code  = 'AR_AA_DUPLICATE_RECOS'
      AND    ref.remit_reference_id = rec.remit_reference_id
      AND    ref.worker_number = p_worker_number
      AND    lin.recommendation_id = rec.recommendation_id
      AND    am.automatch_id = rec.automatch_id
      AND    ps.customer_trx_id = lin.customer_trx_id
      GROUP BY rec.recommendation_id,
               rec.remit_reference_id,
               rec.resolved_matching_date,
               ref.matching_reference_date,
               ps.amount_due_remaining,
               lin.customer_trx_id,
               lin.receipt_date,
               am.use_matching_date,
               am.use_matching_amount
      ORDER BY rec.remit_reference_id, rec.recommendation_id;

      l_rm_frm_dup_count NUMBER;
      l_old_remit_reference_id NUMBER := -1;
      l_rec_count NUMBER;
      l_passed_amount BOOLEAN;
      l_passed_date BOOLEAN;
      TYPE l_rm_frm_dup_rec_tbl IS TABLE OF ar_cash_recos.recommendation_id%TYPE INDEX BY BINARY_INTEGER;
      l_rm_frm_dup_rec l_rm_frm_dup_rec_tbl;
      i NUMBER;
      l_discount NUMBER;
    BEGIN
    l_rm_frm_dup_count := 1;
    FOR rec in dup_recos_cur LOOP
      IF rec.remit_reference_id <> l_old_remit_reference_id THEN
        l_old_remit_reference_id := rec.remit_reference_id;
        l_rec_count := 0;
      END IF;
      l_passed_amount := FALSE;
      l_passed_date := FALSE;
      IF rec.use_matching_date = 'DUPLICATE' THEN
        IF trunc(rec.resolved_matching_date) = rec.matching_reference_date THEN
          l_passed_date := TRUE;
        END IF;
      ELSE
        l_passed_date := TRUE;
      END IF;
      IF rec.use_matching_amount = 'DUPLICATE' THEN
        IF rec.amount_applied + rec.discount_taken_earned = rec.amount_due_remaining THEN
          l_passed_amount := TRUE;
        END IF;
      ELSE
        l_passed_amount := TRUE;
      END IF;
      IF l_passed_amount AND l_passed_date THEN
        l_rec_count := l_rec_count + 1;
        IF l_rec_count > 1 THEN
          l_rm_frm_dup_rec.DELETE(l_rm_frm_dup_count-1);
          l_rm_frm_dup_count := l_rm_frm_dup_count - 1;
          EXIT;
        END IF;
        l_rm_frm_dup_rec(l_rm_frm_dup_count) := rec.recommendation_id;
        l_rm_frm_dup_count := l_rm_frm_dup_count + 1;
      END IF;
    END LOOP;

    FORALL i IN 1..NVL(l_rm_frm_dup_rec.LAST, 0)
         UPDATE ar_cash_recos
         SET    match_reason_code = 'AR_AM_INV_THRESHOLD'
         WHERE  request_id = p_req_id
         AND    match_reason_code = 'AR_AA_DUPLICATE_RECOS'
         AND    recommendation_id = l_rm_frm_dup_rec(i);

    IF (PG_DEBUG IN ('Y', 'C')) THEN
          log('No. of recos Corrected: ' || SQL%ROWCOUNT );
     END IF;
  END;

     UPDATE ar_cash_reco_lines l
      SET    recommendation_reason  = 'AR_AA_DUPLICATE_RECOS'
      WHERE  recommendation_id     IN (SELECT recommendation_id
                                     FROM   ar_cash_recos r
                                     WHERE    match_reason_code        = 'AR_AA_DUPLICATE_RECOS'
                                     AND    request_id               = l.request_id)
      AND    request_id             = p_req_id;

      IF (PG_DEBUG IN ('Y', 'C')) THEN
          log('No. of reco lines updated to Duplicate Recos: ' || SQL%ROWCOUNT );
      END IF;

       --Check if customer can be uniquely identified if not yet identified
     UPDATE ar_cash_recos rec
     SET    match_reason_code      = 'AR_AA_CUST_NOT_UNIQUE'
     WHERE  remit_reference_id       IN (SELECT remit_reference_id
                                      FROM   ar_cash_remit_refs_interim ref1
                                      WHERE  cash_receipt_id IN (
                                            SELECT cr.cash_receipt_id
                                            FROM   ar_cash_receipts cr,
                                                   ar_cash_remit_refs_interim ref,
                                                   ar_cash_recos rec,
                                                   ar_cash_reco_lines recl
                                            WHERE  cr.autoapply_flag          = 'Y'
                                            AND    cr.pay_from_customer         IS NULL
                                            AND    cr.cash_receipt_id         = ref.cash_receipt_id
                                            AND    ref.remit_reference_id     = rec.remit_reference_id
                                            AND    ref.worker_number          = p_worker_number
                                            AND    recl.recommendation_id     = rec.recommendation_id
                                            AND    recl.recommendation_reason = 'AR_AM_INV_THRESHOLD'
                                            AND    EXISTS (SELECT 'Reco of Different Customer'
                                                           FROM   ar_cash_remit_refs_interim ref2,
                                                                  ar_cash_recos rec1,
                                                                  ar_cash_reco_lines recl1
                                                           WHERE  ref2.cash_receipt_id        = ref.cash_receipt_id
                                                           AND    rec1.remit_reference_id     = ref2.remit_reference_id
                                                           AND    recl1.recommendation_id     = rec1.recommendation_id
                                                           AND    recl1.recommendation_reason = 'AR_AM_INV_THRESHOLD'
                                                           AND    rec.recommendation_id      <> rec1.recommendation_id
                                                           AND    rec.pay_from_customer      <> rec1.pay_from_customer
                                                           AND    rec1.request_id             = p_req_id
                                                           AND    ref2.worker_number          = p_worker_number))
                                            AND    ref1.worker_number             = p_worker_number)
     AND    match_reason_code      = 'AR_AM_INV_THRESHOLD'
     AND    request_id             = p_req_id;
     IF (PG_DEBUG IN ('Y', 'C')) THEN
        log('No. of recos updated to Non Unique Customer: ' || SQL%ROWCOUNT );
     END IF;

     UPDATE ar_cash_reco_lines l
     SET    recommendation_reason  = 'AR_AA_CUST_NOT_UNIQUE'
     WHERE  recommendation_id     IN (SELECT recommendation_id
                                      FROM   ar_cash_recos
                                      WHERE  match_reason_code      = 'AR_AA_CUST_NOT_UNIQUE'
                                      AND    request_id             = p_req_id)
     AND    request_id             = p_req_id
     AND    recommendation_reason  = 'AR_AM_INV_THRESHOLD';

      --Multiple recos for same reference
     UPDATE ar_cash_recos rec
     SET    match_reason_code = 'AR_AA_MULT_RECOS'
     WHERE  EXISTS         (SELECT 'Multiple Recos'
                                FROM   ar_cash_recos rec1,
                                       ar_cash_reco_lines lin
                                WHERE  rec1.remit_reference_id   = rec.remit_reference_id
                                AND    rec1.recommendation_id   <> rec.recommendation_id
                                AND    lin.recommendation_id     = rec1.recommendation_id
                                AND    lin.recommendation_reason = 'AR_AM_INV_THRESHOLD'
                                AND    (CASE
                                        WHEN rec1.match_score_value > rec.match_score_value THEN 'T'
                                        WHEN rec1.match_score_value = rec.match_score_value THEN
                                          CASE WHEN rec1.priority >= rec.priority THEN 'T'
                                          END
                                        END) = 'T'
                                AND    lin.request_id             = p_req_id)
     AND   EXISTS              (SELECT 'Applicable Reco Exist'
                                FROM   ar_cash_reco_lines lin
                                WHERE  lin.recommendation_id = rec.recommendation_id
                                AND    lin.recommendation_reason = 'AR_AM_INV_THRESHOLD'
                                AND    lin.request_id             = p_req_id)
     AND    request_id             = p_req_id
     AND    match_reason_code      = 'AR_AM_INV_THRESHOLD';

     IF (PG_DEBUG IN ('Y', 'C')) THEN
          log('No. of recos updated to Multiple Recos: ' || SQL%ROWCOUNT );
     END IF;

     UPDATE ar_cash_reco_lines l
     SET    recommendation_reason = 'AR_AA_MULT_RECOS'
     WHERE  EXISTS             (SELECT 'Many Types of Recos'
                                FROM   ar_cash_recos rec
                                WHERE  l.recommendation_id       = rec.recommendation_id
                                AND    rec.match_reason_code     = 'AR_AA_MULT_RECOS'
                                AND    rec.request_id             = p_req_id)
     AND    recommendation_reason = 'AR_AM_INV_THRESHOLD'
     AND    request_id             = p_req_id;
     IF (PG_DEBUG IN ('Y', 'C')) THEN
          log('No. of reco lines updated to Multiple Recos: ' || SQL%ROWCOUNT );
     END IF;

     --Check if the allocated receipt amounts of all the valid recos exceed the receipt amount/balance
     UPDATE ar_cash_recos rec
     SET    match_reason_code      = 'AR_AA_REMIT_EXCEEDED'
     WHERE  remit_reference_id       IN
                              (SELECT remit_reference_id
                              FROM   ar_cash_remit_refs_interim
                              WHERE  cash_receipt_id IN (
                                    SELECT ps.cash_receipt_id
                                    FROM   ar_payment_schedules ps,
                                           ar_cash_receipts cr,
                                           ar_cash_remit_refs_interim ref,
                                           ar_cash_recos rec,
                                           ar_cash_reco_lines recl
                                    WHERE  ps.cash_receipt_id         = cr.cash_receipt_id
                                    AND    ps.cash_receipt_id         = ref.cash_receipt_id
                                    AND    ref.remit_reference_id     = rec.remit_reference_id
                                    AND    ref.worker_number          = p_worker_number
                                    AND    recl.recommendation_id     = rec.recommendation_id
                                    AND    recl.recommendation_reason = 'AR_AM_INV_THRESHOLD'
                                    AND    recl.request_id            = p_req_id
                                    GROUP BY ps.cash_receipt_id, ps.amount_due_remaining
                                    HAVING ps.amount_due_remaining*-1 < SUM(NVL(recl.amount_applied_from,
                                                                                 recl.amount_applied))))
     AND    match_reason_code      = 'AR_AM_INV_THRESHOLD'
     AND    request_id             = p_req_id;
     IF (PG_DEBUG IN ('Y', 'C')) THEN
        log('No. of recos updated to Remittance amount exceeded: ' || SQL%ROWCOUNT );
     END IF;

     UPDATE ar_cash_reco_lines l
     SET    recommendation_reason  = 'AR_AA_REMIT_EXCEEDED'
     WHERE  recommendation_id     IN (SELECT recommendation_id
                                      FROM   ar_cash_recos
                                      WHERE  match_reason_code      = 'AR_AA_REMIT_EXCEEDED'
                                      AND    request_id             = p_req_id)
     AND    request_id             = p_req_id
     AND    recommendation_reason  = 'AR_AM_INV_THRESHOLD';
     IF (PG_DEBUG IN ('Y', 'C')) THEN
          log('No. of reco lines updated to Remittance amount exceeded: ' || SQL%ROWCOUNT );
     END IF;

    /* * Update the unidentified cash receipts with the customer number of *
       * the valid recommendations.                                        * */

    DECLARE
    CURSOR unid_receipts IS
      SELECT distinct cash_receipt_id
      FROM ar_cash_remit_refs_interim
      WHERE worker_number = p_worker_number
      AND customer_id IS NULL;

    l_cash_receipt_id AR_CASH_REMIT_REFS_INTERIM.cash_receipt_id%TYPE;
    l_customer_id AR_CASH_RECOS.pay_from_customer%TYPE;
    v_msg_count  NUMBER(4);
    v_msg_data   VARCHAR2(1000);
    v_return_status VARCHAR2(5);
    v_status    VARCHAR2(100);
    loop_index  NUMBER;
    BEGIN
    FOR unid_receipts_rec in unid_receipts LOOP
      l_cash_receipt_id := unid_receipts_rec.cash_receipt_id;
      SELECT decode(count(distinct rec.pay_from_customer),
                        1, max(rec.pay_from_customer),
                        NULL)
      INTO l_customer_id
      FROM ar_cash_recos rec,
           ar_cash_remit_refs_interim ref
      WHERE rec.request_id = p_req_id
      AND   ref.cash_receipt_id = l_cash_receipt_id
      AND   rec.remit_reference_id = ref.remit_reference_id
      AND   ref.worker_number = p_worker_number
      AND   rec.match_reason_code = 'AR_AM_INV_THRESHOLD';
      IF l_customer_id IS NOT NULL THEN
        log('Calling unid_to_unapp');
        log('Cash receipt Id : ' || l_cash_receipt_id);
        log('Customer Id : '|| l_customer_id);
        AR_RECEIPT_UPDATE_API_PUB.update_receipt_unid_to_unapp(
        p_api_version                  => 1.0,
        x_return_status                => v_return_status,
        x_msg_count                    => v_msg_count,
        x_msg_data                     => v_msg_data,
        --p_commit                       => FND_API.G_TRUE,
        p_cash_receipt_id              => l_cash_receipt_id,
        p_pay_from_customer            => l_customer_id,
        x_status                       => v_status
        );
        log('Return Status '||v_return_status);

        IF v_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          UPDATE ar_cash_recos
          SET     match_reason_code      = 'AR_AA_CUST_UNID'
          WHERE  remit_reference_id  IN (SELECT ref1.remit_reference_id
                                          FROM   ar_cash_remit_refs_interim ref1
                                          WHERE  ref1.cash_receipt_id = l_cash_receipt_id)
          AND    match_reason_code      = 'AR_AM_INV_THRESHOLD'
          AND    request_id             = p_req_id;
        END IF;
      END IF;
    END LOOP;
    UPDATE ar_cash_reco_lines l
    SET    recommendation_reason  = 'AR_AA_CUST_UNID'
    WHERE  recommendation_id     IN (SELECT recommendation_id
                                    FROM   ar_cash_recos
                                    WHERE  match_reason_code      = 'AR_AA_CUST_UNID'
                                    AND    request_id             = p_req_id)
    AND    request_id             = p_req_id
    AND    recommendation_reason  = 'AR_AM_INV_THRESHOLD';
    END;

    SELECT ps.payment_schedule_id
     BULK COLLECT INTO locked_ps_records
     FROM   ar_payment_schedules ps,
            ar_cash_reco_lines lines
     WHERE  lines.request_id = p_req_id
     AND    lines.recommendation_reason = 'AR_AM_INV_THRESHOLD'
     AND    ps.payment_schedule_id = lines.payment_schedule_id
     FOR UPDATE OF ps.amount_due_remaining SKIP LOCKED;

     FORALL i IN 1..NVL(locked_ps_records.LAST, 0)
       UPDATE ar_cash_reco_lines
       SET    recommendation_reason = 'AR_AA_INV_LOCKED'
       WHERE  request_id = p_req_id
       AND    recommendation_reason = 'AR_AM_INV_THRESHOLD'
       AND    payment_schedule_id = locked_ps_records(i);


    IF (PG_DEBUG IN ('Y', 'C')) THEN
        log('arp_autoapply_api.validate_trx_recos(-)');
    END IF;
    EXCEPTION
     WHEN OTHERS THEN
          log('Exception from arp_autoapply_api.validate_trx_recos');
          log(SQLERRM);
          RAISE;
  END validate_trx_recos;

/*===========================================================================+
 * PROCEDURE                                                                 *
 *     APPLY_TRX_RECOS()                                                     *
 * DESCRIPTION                                                               *
 *   Apply all valid recommendations and update the reference with resolved  *
 *   matching numbers.                                                       *
 * SCOPE - LOCAL                                                             *
 * ARGUMENTS                                                                 *
 *              IN  : p_worker_number Current Worker Number                  *
 *                    p_req_id Request ID                                    *
 *              OUT : None                                                   *
 *                                                                           *
 * RETURNS      NONE                    				                             *
 * ALGORITHM                                                                 *
 *  1. Select Valid Recommendation lines ( with status 'AR_AA_INV_LOCKED')   *
 *  2. For all recommendation lines                                          *
 *  3. Select Next Recommendation Line                                       *
 *  4. Apply the transaction                                                 *
 *  5. Compute the remaining balace for the reference                        *
 *  6. If balance > 0 go to Step 3.                                          *
 *  7. Update the referene with Resolved matching number, currency etc .     *
 *  8. Delete the recommendations for the references that were (automatically)
 *     applied.                                                              *
 * NOTES -                                                                   *
 *   1. APPLY_TRX_RECOS is called once per each worker.                      *
 *                                                                           *
 * MODIFICATION HISTORY -  09/03/2009 - Created by AGHORAKA	     	           *
 *                                                                           *
 +===========================================================================*/

  PROCEDURE apply_trx_recos(p_req_id         IN NUMBER
                            , p_worker_number  IN NUMBER)  IS

     l_return_status        VARCHAR2(10);
     l_msg_count            NUMBER;
     l_msg_data             VARCHAR2(3000);
     l_amount_rem           NUMBER;
     l_line_num             NUMBER;
     l_remit_reference_id   NUMBER;
     l_old_remit_reference_id NUMBER := -1;
     l_ref_amt_applied      NUMBER;
     loop_index             NUMBER;
     l_ref_amt_applied_from NUMBER;
     l_rec_currency_code    ar_cash_receipts.currency_code%TYPE;
     l_amount_applied       BOOLEAN;
     l_amount_applied_from  BOOLEAN;

     CURSOR app_reco_cur IS
      SELECT  distinct rec.remit_reference_id
      FROM    ar_cash_recos rec
      WHERE rec.request_id = p_req_id
      AND   rec.match_reason_code = 'AR_AM_INV_THRESHOLD'
      AND   rec.match_resolved_using     <> 'BALANCE FORWARD BILL';

    CURSOR app_reco_line_cur(p_remit_reference_id NUMBER) IS
      SELECT  ref.cash_receipt_id,
              rec.remit_reference_id,
              NVL(ref.amount_applied, ARPCURR.CURRROUND((ref.amount_applied_from / NVL(lin.trans_to_receipt_rate, 1)), lin.receipt_currency_code)) ref_amount_applied,
              lin.amount_applied,
              lin.payment_schedule_id,
              lin.amount_applied_from,
              lin.trans_to_receipt_rate,
              lin.recommendation_id,
              lin.line_number,
              lin.receipt_currency_code,
              rec.resolved_match_currency
       FROM   ar_cash_remit_refs_interim ref,
              ar_cash_recos rec,
              ar_cash_reco_lines lin
       WHERE rec.remit_reference_id = p_remit_reference_id
       AND   ref.remit_reference_id        = rec.remit_reference_id
       AND   rec.recommendation_id         = lin.recommendation_id
       AND   ref.worker_number             = p_worker_number
       AND   lin.recommendation_reason     = 'AR_AA_INV_LOCKED'
       AND   rec.match_resolved_using     <> 'BALANCE FORWARD BILL'
       AND   lin.request_id                = p_req_id
       ORDER BY lin.recommendation_id, lin.line_number;

     CURSOR bfb_recos_cur(p_worker_number NUMBER) IS
      SELECT  rec.remit_reference_id,
              rec.cons_inv_id,
              rec.recommendation_id,
              ref.amount_applied,
              ref.amount_applied_from,
              ref.cash_receipt_id,
              cr.currency_code
      FROM   ar_cash_recos rec,
             ar_cash_remit_refs_interim ref,
             ar_cash_receipts cr
      WHERE rec.request_id = p_req_id
      AND   rec.match_reason_code = 'AR_AM_INV_THRESHOLD'
      AND   rec.match_resolved_using = 'BALANCE FORWARD BILL'
      AND   ref.remit_reference_id = rec.remit_reference_id
      AND   ref.worker_number = p_worker_number
      AND   cr.cash_receipt_id = ref.cash_receipt_id;

     CURSOR bfb_lines_cur(p_reco_id NUMBER) IS
      SELECT  lin.recommendation_id,
              lin.line_number,
              lin.payment_schedule_id,
              lin.customer_trx_id,
              lin.amount_applied,
              lin.amount_applied_from,
              lin.trans_to_receipt_rate,
              ps.invoice_currency_code
      FROM  ar_cash_reco_lines lin,
            ar_payment_schedules ps
      WHERE lin.recommendation_id = p_reco_id
      AND   lin.request_id                = p_req_id
      AND   lin.recommendation_reason     = 'AR_AA_INV_LOCKED'
      AND   ps.payment_schedule_id        = lin.payment_schedule_id
      ORDER BY lin.recommendation_id, lin.line_number;

  BEGIN
     IF (PG_DEBUG IN ('Y', 'C')) THEN
          log('arp_autoapply_api.apply_trx_recos(+)');
          log('p_req_id: ' || p_req_id);
          log('p_worker_number: ' || p_worker_number);
     END IF;
    FOR app_reco IN app_reco_cur LOOP
      l_remit_reference_id := app_reco.remit_reference_id;
      FOR app_line IN app_reco_line_cur(l_remit_reference_id) LOOP
        IF l_old_remit_reference_id <> l_remit_reference_id THEN
          l_ref_amt_applied := app_line.ref_amount_applied;
          l_old_remit_reference_id := l_remit_reference_id;
        END IF;
        app_line.amount_applied := LEAST(app_line.amount_applied, l_ref_amt_applied);
        IF app_line.receipt_currency_code <> app_line.resolved_match_currency THEN
          calc_amt_applied_from(
          p_currency_code => app_line.receipt_currency_code,
          p_amount_applied => app_line.amount_applied,
          p_trans_to_receipt_rate => app_line.trans_to_receipt_rate,
          amount_applied_from => app_line.amount_applied_from);
        ELSE
          app_line.amount_applied_from := NULL;
        END IF;

        IF (PG_DEBUG IN ('Y', 'C')) THEN
          log('Calling Apply API with parameters:');
          log('p_cash_receipt_id:            ' || app_line.cash_receipt_id);
          log('p_applied_payment_schedule_id:' || app_line.payment_schedule_id);
          log('p_amount_applied:             ' || app_line.amount_applied);
        END IF;

        AR_RECEIPT_API_PUB.APPLY(
        p_api_version                  => 1.0,
        x_return_status                => l_return_status,
        x_msg_count                    => l_msg_count,
        x_msg_data                     => l_msg_data,
        p_cash_receipt_id              => app_line.cash_receipt_id,
        p_applied_payment_schedule_id  => app_line.payment_schedule_id,
        p_amount_applied               => app_line.amount_applied,
        p_amount_applied_from          => app_line.amount_applied_from,
        p_trans_to_receipt_rate        => app_line.trans_to_receipt_rate,
        p_org_id                       => ARP_STANDARD.sysparm.org_id);

        IF (PG_DEBUG IN ('Y', 'C')) THEN
          log('Apply API Status :'|| l_return_status);
        END IF;

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          UPDATE ar_cash_reco_lines
          SET    recommendation_reason   = 'AR_AA_REC_APP_IN_ERROR'
          WHERE  recommendation_id       = app_line.recommendation_id
          AND    line_number             = app_line.line_number;

          FOR loop_index in 1..l_msg_count LOOP
        	  l_msg_data := FND_MSG_PUB.Get(FND_MSG_PUB.G_NEXT,FND_API.G_FALSE);
        	  IF l_msg_data IS NULL THEN
        	   EXIT;
        	  END IF;
        	  log('Error From Receipt API :' || loop_index ||' ---'||l_msg_data);
        	END LOOP;
        ELSE
          l_ref_amt_applied := l_ref_amt_applied - app_line.amount_applied;
          EXIT WHEN l_ref_amt_applied = 0;
        END IF;
      END LOOP;
    END LOOP;
    FOR bfb_reco IN bfb_recos_cur(p_worker_number) LOOP
      l_remit_reference_id    := bfb_reco.remit_reference_id;
      l_ref_amt_applied       := bfb_reco.amount_applied;
      l_ref_amt_applied_from  := bfb_reco.amount_applied_from;
      l_rec_currency_code     := bfb_reco.currency_code;
      IF l_ref_amt_applied IS NOT NULL THEN
        l_amount_applied := TRUE;
      ELSIF l_ref_amt_applied_from IS NOT NULL THEN
        l_amount_applied_from := TRUE;
      END IF;
      FOR bfb_line in bfb_lines_cur(bfb_reco.recommendation_id) LOOP
          IF l_amount_applied THEN
            bfb_line.amount_applied := LEAST(bfb_line.amount_applied, l_ref_amt_applied);
            IF l_rec_currency_code <> bfb_line.invoice_currency_code THEN
              calc_amt_applied_from(
                p_currency_code => l_rec_currency_code,
                p_amount_applied => bfb_line.amount_applied,
                p_trans_to_receipt_rate => bfb_line.trans_to_receipt_rate,
                amount_applied_from => bfb_line.amount_applied_from);
            ELSE
              bfb_line.amount_applied_from := NULL;
            END IF;
          ELSIF l_amount_applied_from THEN
            bfb_line.amount_applied_from := least(bfb_line.amount_applied_from, nvl(l_ref_amt_applied_from, l_ref_amt_applied));
            IF l_rec_currency_code <> bfb_line.invoice_currency_code THEN
              calc_amt_applied(
                p_invoice_currency_code => bfb_line.invoice_currency_code,
                p_amount_applied_from => bfb_line.amount_applied_from,
                p_trans_to_receipt_rate => bfb_line.trans_to_receipt_rate,
                amount_applied => bfb_line.amount_applied);
            ELSE
              bfb_line.amount_applied := bfb_line.amount_applied_from;
            END IF;
          END IF;

          IF (PG_DEBUG IN ('Y', 'C')) THEN
            log('Calling Apply API with parameters:');
            log('p_cash_receipt_id:            ' || bfb_reco.cash_receipt_id);
            log('p_applied_payment_schedule_id:' || bfb_line.payment_schedule_id);
            log('p_amount_applied:             ' || bfb_line.amount_applied);
          END IF;

          AR_RECEIPT_API_PUB.APPLY(
                p_api_version                  => 1.0,
                x_return_status                => l_return_status,
                x_msg_count                    => l_msg_count,
                x_msg_data                     => l_msg_data,
                p_cash_receipt_id              => bfb_reco.cash_receipt_id,
                p_applied_payment_schedule_id  => bfb_line.payment_schedule_id,
                p_amount_applied               => bfb_line.amount_applied,
                p_amount_applied_from          => bfb_line.amount_applied_from,
                p_trans_to_receipt_rate        => bfb_line.trans_to_receipt_rate,
                p_org_id                       => ARP_STANDARD.SYSPARM.org_id);

          IF (PG_DEBUG IN ('Y', 'C')) THEN
            log('Apply API Status :'|| l_return_status);
          END IF;

          IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            UPDATE ar_cash_reco_lines
            SET    recommendation_reason   = 'AR_AA_REC_APP_IN_ERROR'
            WHERE  recommendation_id       = bfb_line.recommendation_id
            AND    line_number             = bfb_line.line_number;
            FOR loop_index in 1..l_msg_count LOOP
          	  l_msg_data := FND_MSG_PUB.Get(FND_MSG_PUB.G_NEXT,FND_API.G_FALSE);
          	  IF l_msg_data IS NULL THEN
          	   EXIT;
          	  END IF;
          	  log('Error From Receipt API :' || loop_index ||' ---'||l_msg_data);
          	END LOOP;
          ELSE
            IF l_amount_applied THEN
              l_ref_amt_applied := l_ref_amt_applied - bfb_line.amount_applied;
              EXIT WHEN l_ref_amt_applied = 0;
            ELSIF l_amount_applied_from THEN
              l_ref_amt_applied_from := l_ref_amt_applied_from - bfb_line.amount_applied_from;
              EXIT WHEN l_ref_amt_applied_from = 0;
            END IF;
          END IF;
        END LOOP;
     END LOOP;

     UPDATE ar_cash_remit_refs ref
     SET   (receipt_reference_status,
            resolved_matching_number,
            auto_applied,
            match_score_value,
            resolved_matching_date,
            invoice_currency_code,
            match_resolved_using)      =(SELECT 'AR_AA_INV_APPLIED',
                                          rec.resolved_matching_number,
                                          'Y',
                                          rec.match_score_value,
                                          rec.resolved_matching_date,
                                          rec.resolved_match_currency,
                                          rec.automatch_id
                                     FROM   ar_cash_recos rec,
                                            ar_cash_reco_lines lin
                                     WHERE  ref.remit_reference_id = rec.remit_reference_id
                                     AND    lin.recommendation_id  = rec.recommendation_id
                                     AND    rec.request_id          = p_req_id
                                     AND    recommendation_type    = 'TRX'
                                     AND    lin.recommendation_reason  = 'AR_AA_INV_LOCKED'
                                     AND    rownum =1)
      WHERE  EXISTS                  (SELECT 'Found Match'
                                     FROM   ar_cash_recos rec,
                                            ar_cash_reco_lines lin
                                     WHERE  ref.remit_reference_id = rec.remit_reference_id
                                     AND    lin.recommendation_id  = rec.recommendation_id
                                     AND    lin.request_id          = p_req_id
                                     AND    recommendation_type    = 'TRX'
                                     AND    lin.recommendation_reason  = 'AR_AA_INV_LOCKED');
     IF (PG_DEBUG IN ('Y', 'C')) THEN
          log('No. of References updated with Resolved Matching Number: ' || SQL%ROWCOUNT );
     END IF;

     DELETE FROM ar_cash_reco_lines lin
     WHERE  EXISTS                  (SELECT 'Delete Recos'
                                     FROM   ar_cash_remit_refs ref,
                                            ar_cash_recos rec
                                     WHERE  ref.receipt_reference_status = 'AR_AA_INV_APPLIED'
                                     AND    lin.recommendation_id    = rec.recommendation_id
                                     AND    rec.remit_reference_id   = ref.remit_reference_id)
     AND    request_id          = p_req_id;

     DELETE FROM ar_cash_recos rec
     WHERE  EXISTS                  (SELECT 'Delete Recos'
                                     FROM   ar_cash_remit_refs ref
                                     WHERE  ref.receipt_reference_status = 'AR_AA_INV_APPLIED'
                                     AND    rec.remit_reference_id   = ref.remit_reference_id)
     AND    request_id          = p_req_id
     AND    recommendation_type    = 'TRX';

     IF (PG_DEBUG IN ('Y', 'C')) THEN
          log('No. of Recos deleted: ' || SQL%ROWCOUNT );
     END IF;
     IF (PG_DEBUG IN ('Y', 'C')) THEN
          log('arp_autoapply_api.apply_trx_recos(-)' );
     END IF;
  EXCEPTION
     WHEN OTHERS THEN
          log('Exception from arp_autoapply_api.apply_trx_recos');
          log(SQLERRM);
          RAISE;
  END apply_trx_recos;

  PROCEDURE copy_current_record(  p_current_reco IN OUT NOCOPY selected_recos_table
                              , p_selected_recos IN selected_recos_table
                              , p_index IN NUMBER) IS
  i NUMBER;
  BEGIN
    IF (PG_DEBUG IN ('Y', 'C')) THEN
      log('copy_current_record()+');
      log('p_index : '|| p_index);
    END IF;
    i := p_current_reco.COUNT + 1;
    p_current_reco(i).remit_reference_id           := p_selected_recos(p_index).remit_reference_id;
    p_current_reco(i).ref_amount_applied           := p_selected_recos(p_index).ref_amount_applied;
    p_current_reco(i).ref_amount_applied_from      := p_selected_recos(p_index).ref_amount_applied_from;
    p_current_reco(i).ref_trans_to_receipt_rate    := p_selected_recos(p_index).ref_trans_to_receipt_rate;
    p_current_reco(i).payment_schedule_id          := p_selected_recos(p_index).payment_schedule_id;
    p_current_reco(i).amount_applied               := p_selected_recos(p_index).amount_applied;
    p_current_reco(i).amount_applied_from          := p_selected_recos(p_index).amount_applied_from;
    p_current_reco(i).cash_receipt_id              := p_selected_recos(p_index).cash_receipt_id;
    p_current_reco(i).pay_from_customer            := p_selected_recos(p_index).pay_from_customer;
    p_current_reco(i).cr_customer_site_use_id      := p_selected_recos(p_index).cr_customer_site_use_id;
    p_current_reco(i).amount_due_original          := p_selected_recos(p_index).amount_due_original;
    p_current_reco(i).amount_due_remaining         := p_selected_recos(p_index).amount_due_remaining;
    p_current_reco(i).discount_taken_earned        := p_selected_recos(p_index).discount_taken_earned;
    p_current_reco(i).discount_taken_unearned      := p_selected_recos(p_index).discount_taken_unearned;
    p_current_reco(i).customer_trx_id              := p_selected_recos(p_index).customer_trx_id;
    p_current_reco(i).customer_id                  := p_selected_recos(p_index).customer_id;
    p_current_reco(i).customer_site_use_id         := p_selected_recos(p_index).customer_site_use_id;
    p_current_reco(i).resolved_matching_number     := p_selected_recos(p_index).resolved_matching_number;
    p_current_reco(i).terms_sequence_number        := p_selected_recos(p_index).terms_sequence_number;
    p_current_reco(i).resolved_matching_date       := p_selected_recos(p_index).resolved_matching_date;
    p_current_reco(i).trx_date                     := p_selected_recos(p_index).trx_date;
    p_current_reco(i).resolved_matching_class      := p_selected_recos(p_index).resolved_matching_class;
    p_current_reco(i).resolved_match_currency      := p_selected_recos(p_index).resolved_match_currency;
    p_current_reco(i).amount_applied               := p_selected_recos(p_index).amount_applied;
    p_current_reco(i).amount_applied_from          := p_selected_recos(p_index).amount_applied_from;
    p_current_reco(i).trans_to_receipt_rate        := p_selected_recos(p_index).trans_to_receipt_rate;
    p_current_reco(i).payment_schedule_id          := p_selected_recos(p_index).payment_schedule_id;
    p_current_reco(i).match_score_value            := p_selected_recos(p_index).match_score_value;
    p_current_reco(i).org_id                       := p_selected_recos(p_index).org_id;
    p_current_reco(i).term_id                      := p_selected_recos(p_index).term_id;
    p_current_reco(i).automatch_id                 := p_selected_recos(p_index).automatch_id;
    p_current_reco(i).use_matching_date            := p_selected_recos(p_index).use_matching_date;
    p_current_reco(i).use_matching_amount          := p_selected_recos(p_index).use_matching_amount;
    p_current_reco(i).auto_match_threshold         := p_selected_recos(p_index).auto_match_threshold;
    p_current_reco(i).priority                     := p_selected_recos(p_index).priority;
    p_current_reco(i).receipt_currency_code        := p_selected_recos(p_index).receipt_currency_code;
    p_current_reco(i).receipt_date                 := p_selected_recos(p_index).receipt_date;
    p_current_reco(i).allow_overapplication_flag   := p_selected_recos(p_index).allow_overapplication_flag;
    p_current_reco(i).partial_discount_flag        := p_selected_recos(p_index).partial_discount_flag;
    p_current_reco(i).reco_num                     := p_selected_recos(p_index).reco_num;
    IF (PG_DEBUG IN ('Y', 'C')) THEN
      log('copy_current_record()-');
    END IF;
  END copy_current_record;

  PROCEDURE process_single_reco(p_current_reco IN OUT NOCOPY selected_recos_table
                                , p_match_resolved_using IN VARCHAR2) IS
    l_block_index              NUMBER;
    l_recommendation_id        NUMBER;
    l_recommendation_reason    VARCHAR2(30);
    l_use_matching_date        AR_CASH_AUTOMATCHES.use_matching_date%TYPE;
    l_use_matching_amount      AR_CASH_AUTOMATCHES.use_matching_amount%TYPE;
    l_ref_amount_applied       AR_CASH_REMIT_REFS.amount_applied%TYPE;
    l_ref_amount_applied_from  AR_CASH_REMIT_REFS.amount_applied_from%TYPE;
    l_ref_orig_amount          AR_CASH_REMIT_REFS.amount_applied%TYPE;
    l_ref_rem_amount           AR_CASH_REMIT_REFS.amount_applied%TYPE;
    l_trans_to_receipt_rate    AR_CASH_REMIT_REFS.trans_to_receipt_rate%TYPE;
    l_res_matching_date        AR_PAYMENT_SCHEDULES.trx_date%TYPE;
    l_match_score_value        AR_CASH_RECOS.match_score_value%TYPE;
    l_receipt_currency_code    AR_CASH_RECEIPTS.currency_code%TYPE;
    l_resolved_match_currency  AR_PAYMENT_SCHEDULES.invoice_currency_code%TYPE;
    l_trx_amt_due_rem          AR_CASH_REMIT_REFS.amount_applied%TYPE := 0;
    l_discount_taken           AR_CASH_RECO_LINES.discount_taken_earned%TYPE := 0;
    l_amount_applied           AR_CASH_REMIT_REFS.amount_applied%TYPE;
    l_out_amount_to_apply      AR_CASH_REMIT_REFS.amount_applied%TYPE;
    l_out_discount_to_take     AR_CASH_REMIT_REFS.amount_applied%TYPE;
    l_valid                    VARCHAR2(1);
  BEGIN
    IF (PG_DEBUG IN ('Y', 'C')) THEN
      log('process_single_reco()+');
    END IF;
    SELECT  ar_cash_recos_s.nextval
    INTO    l_recommendation_id
    FROM    dual;
    l_recommendation_reason := 'AR_AM_INV_THRESHOLD';
    l_use_matching_date := p_current_reco(1).use_matching_date;
    l_use_matching_amount := p_current_reco(1).use_matching_amount;
    l_ref_amount_applied := p_current_reco(1).ref_amount_applied;
    l_ref_amount_applied_from := p_current_reco(1).ref_amount_applied_from;
    l_trans_to_receipt_rate := p_current_reco(1).trans_to_receipt_rate;
    l_res_matching_date := p_current_reco(1).resolved_matching_date;
    l_match_score_value := p_current_reco(1).match_score_value;
    l_receipt_currency_code := p_current_reco(1).receipt_currency_code;
    l_resolved_match_currency := p_current_reco(1).resolved_match_currency;

    IF l_receipt_currency_code = l_resolved_match_currency THEN
      IF l_ref_amount_applied IS NULL THEN
        l_ref_amount_applied := l_ref_amount_applied_from;
      END IF;
    ELSE
      /* In case of cross currency transaction, calculate the missing values */
      IF l_ref_amount_applied IS NULL THEN
        calc_amt_applied(
          p_invoice_currency_code => l_resolved_match_currency,
          p_amount_applied_from => l_ref_amount_applied_from,
          p_trans_to_receipt_rate => l_trans_to_receipt_rate,
          amount_applied => l_ref_amount_applied);
      ELSIF l_ref_amount_applied_from IS NULL THEN
        calc_amt_applied_from(
          p_currency_code => l_receipt_currency_code,
          p_amount_applied => l_ref_amount_applied,
          p_trans_to_receipt_rate => l_trans_to_receipt_rate,
          amount_applied_from => l_ref_amount_applied_from);
      END IF;
      /* At this point we have all values related to a xcurr application.
         Validate the values */
      AR_CC_LOCKBOX.are_values_valid(
        p_invoice_currency_code => l_resolved_match_currency,
        p_amount_applied_from => l_ref_amount_applied_from,
        p_trans_to_receipt_rate => l_trans_to_receipt_rate,
        p_amount_applied => l_ref_amount_applied,
        p_currency_code => l_receipt_currency_code,
        valid => l_valid
      );
      IF l_valid <> 'Y' THEN
        l_recommendation_reason := 'AR_AA_INV_XCURR_APP';
      END IF;
    END IF;
    l_ref_orig_amount := l_ref_amount_applied;
    l_ref_rem_amount := l_ref_amount_applied;
    FOR l_index in 1..p_current_reco.LAST LOOP
      l_trx_amt_due_rem := l_trx_amt_due_rem + p_current_reco(l_index).amount_applied;
      IF l_ref_rem_amount > 0 THEN
        l_amount_applied := LEAST(l_ref_rem_amount, p_current_reco(l_index).amount_applied);
        log('l_amount_applied :'||l_amount_applied);
        calc_amount_app_and_disc(
                        p_customer_id => NVL(p_current_reco(l_index).pay_from_customer,
                                             p_current_reco(l_index).customer_id)
                        , p_bill_to_site_use_id => NVL(p_current_reco(l_index).cr_customer_site_use_id,
                                                      p_current_reco(l_index).customer_site_use_id)
                        , p_invoice_currency_code => l_resolved_match_currency
                        , p_ps_id => p_current_reco(l_index).payment_schedule_id
                        , p_term_id => p_current_reco(l_index).term_id
                        , p_terms_sequence_number => p_current_reco(l_index).terms_sequence_number
                        , p_trx_date => p_current_reco(l_index).trx_date
                        , p_allow_overapp_flag => p_current_reco(l_index).allow_overapplication_flag
                        , p_partial_discount_flag => p_current_reco(l_index).partial_discount_flag
                        , p_input_amount => l_amount_applied
                        , p_amount_due_original => p_current_reco(l_index).amount_due_original
                        , p_amount_due_remaining => p_current_reco(l_index).amount_due_remaining
                        , p_discount_taken_earned => p_current_reco(l_index).discount_taken_earned
                        , p_discount_taken_unearned => p_current_reco(l_index).discount_taken_unearned
                        , p_cash_receipt_id => p_current_reco(l_index).cash_receipt_id
                        , x_out_amount_to_apply => l_out_amount_to_apply
                        , x_out_discount_to_take => l_out_discount_to_take);
        p_current_reco(l_index).discount_taken_earned := NVL(l_out_discount_to_take, 0);
        l_discount_taken := l_discount_taken + NVL(l_out_discount_to_take, 0);
        log('l_out_amount_to_apply : '||l_out_amount_to_apply);
        IF l_amount_applied <> l_out_amount_to_apply THEN
          log('If');
          p_current_reco(l_index).amount_applied := l_out_amount_to_apply;
        ELSE
          log('Else');
          p_current_reco(l_index).amount_applied := l_amount_applied;
        END IF;
        log('Amount Applied :'||p_current_reco(l_index).amount_applied);
        IF NVL(l_trans_to_receipt_rate, -1) <> -1 THEN
          calc_amt_applied_from(
            p_currency_code => l_receipt_currency_code,
            p_amount_applied => p_current_reco(l_index).amount_applied,
            p_trans_to_receipt_rate => l_trans_to_receipt_rate,
            amount_applied_from => p_current_reco(l_index).amount_applied_from);
        END IF;
        l_ref_rem_amount := l_ref_rem_amount - p_current_reco(l_index).amount_applied;
      ELSE
        p_current_reco(l_index).amount_applied := 0;
      END IF;
    END LOOP;
    IF l_recommendation_reason = 'AR_AM_INV_THRESHOLD' THEN
      IF p_current_reco(1).match_score_value < p_current_reco(1).auto_match_threshold THEN
        l_recommendation_reason := 'AR_AA_BELOW_TRX_TSLD';
      ELSIF p_current_reco(1).use_matching_amount = 'ALWAYS' THEN
        IF l_ref_amount_applied <> l_trx_amt_due_rem - NVL(l_discount_taken, 0) THEN
          log('Ref Amt :' || l_ref_amount_applied);
          log('Trx Amt :' || l_trx_amt_due_rem);
          l_recommendation_reason := 'AR_AA_AMOUNT_MISMATCH';
        END IF;
      ELSIF l_ref_rem_amount <> 0 THEN
        IF p_current_reco(1).allow_overapplication_flag = 'Y'
          AND p_match_resolved_using <> 'BALANCE FORWARD BILL' THEN
          p_current_reco(p_current_reco.LAST).amount_applied := p_current_reco(p_current_reco.LAST).amount_applied +
                                                                l_ref_rem_amount;
          l_ref_rem_amount := 0;
        ELSE
          IF l_ref_orig_amount > l_trx_amt_due_rem THEN
            l_recommendation_reason := 'AR_AA_OVER_APPLN';
          END IF;
        END IF;
      END IF;
    END IF;
    populate_reco_line_struct(p_current_reco
                              , p_match_resolved_using
                              , l_recommendation_id
                              , l_recommendation_reason);
    IF (PG_DEBUG IN ('Y', 'C')) THEN
      log('process_single_reco()-');
    END IF;
    EXCEPTION
      WHEN OTHERS THEN
        log('Exception from arp_autoapply_api.process_single_reco');
        log(SQLERRM);
        RAISE;
  END process_single_reco;

  PROCEDURE populate_reco_line_struct(p_current_reco IN selected_recos_table
                                    , p_match_resolved_using IN VARCHAR2
                                    , p_recommendation_id IN NUMBER
                                    , p_recommendation_reason IN VARCHAR2) IS
  l_index NUMBER;
  BEGIN
    IF (PG_DEBUG IN ('Y', 'C')) THEN
      log('populate_reco_line_struct()+');
      log('Recommendation ID : '||p_recommendation_id);
      log('Recommendation Reason : '||p_recommendation_reason);
      log('Match Resolved Using : '||p_match_resolved_using);
    END IF;
    g_reco_index := reco_id_arr.COUNT;
    FOR l_index IN 1 .. NVL(p_current_reco.LAST, 0) LOOP
      IF p_current_reco(l_index).amount_applied <> 0 THEN
      g_reco_index := g_reco_index + 1;

      reco_id_arr(g_reco_index) := p_recommendation_id;
      remit_ref_id_arr(g_reco_index) := p_current_reco(l_index).remit_reference_id;
      customer_id_arr(g_reco_index) := p_current_reco(l_index).customer_id;
      customer_site_use_id_arr(g_reco_index) := p_current_reco(l_index).customer_site_use_id;
      resolved_matching_number_arr(g_reco_index) := p_current_reco(l_index).resolved_matching_number;
      resolved_matching_date_arr(g_reco_index) := p_current_reco(l_index).resolved_matching_date;
      resolved_matching_class_arr(g_reco_index) := p_current_reco(l_index).resolved_matching_class;
      resolved_match_currency_arr(g_reco_index) := p_current_reco(l_index).resolved_match_currency;
      match_resolved_using_arr(g_reco_index) := p_match_resolved_using;
      cons_inv_id_arr(g_reco_index) := p_current_reco(l_index).cons_inv_id;
      match_score_value_arr(g_reco_index) := p_current_reco(l_index).match_score_value;
      match_reason_code_arr(g_reco_index) := p_recommendation_reason;
      org_id_arr(g_reco_index) := p_current_reco(l_index).org_id;
      automatch_id_arr(g_reco_index) := p_current_reco(l_index).automatch_id;
      priority_arr(g_reco_index) := p_current_reco(l_index).priority;
      reco_num_arr(g_reco_index) := p_current_reco(l_index).reco_num;
      customer_trx_id_arr(g_reco_index) := p_current_reco(l_index).customer_trx_id;
      payment_schedule_id_arr(g_reco_index) := p_current_reco(l_index).payment_schedule_id;
      amount_applied_arr(g_reco_index) := p_current_reco(l_index).amount_applied;
      amount_applied_from_arr(g_reco_index) := p_current_reco(l_index).amount_applied_from;
      trans_to_receipt_rate_arr(g_reco_index) := p_current_reco(l_index).trans_to_receipt_rate;
      receipt_currency_code_arr(g_reco_index) := p_current_reco(l_index).receipt_currency_code;
      receipt_date_arr(g_reco_index) := p_current_reco(l_index).receipt_date;
      discount_taken_earned_arr(g_reco_index) := p_current_reco(l_index).discount_taken_earned;
      discount_taken_unearned_arr(g_reco_index) := p_current_reco(l_index).discount_taken_unearned;
    END IF;
    END LOOP;
    IF (PG_DEBUG IN ('Y', 'C')) THEN
      log('populate_reco_line_struct()-');
    END IF;
    EXCEPTION
      WHEN OTHERS THEN
        log('Exception from arp_autoapply_api.populate_reco_line_struct');
        log(SQLERRM);
        RAISE;
  END populate_reco_line_struct;

  PROCEDURE clear_Reco_lines_struct IS
  BEGIN
    IF (PG_DEBUG IN ('Y', 'C')) THEN
      log('clear_Reco_lines_struct()+');
    END IF;
    g_reco_index := 0;
    reco_id_arr.DELETE;
    remit_ref_id_arr.DELETE;
    customer_id_arr.DELETE;
    customer_site_use_id_arr.DELETE;
    resolved_matching_number_arr.DELETE;
    resolved_matching_date_arr.DELETE;
    resolved_matching_class_arr.DELETE;
    resolved_match_currency_arr.DELETE;
    match_resolved_using_arr.DELETE;
    cons_inv_id_arr.DELETE;
    match_score_value_arr.DELETE;
    match_reason_code_arr.DELETE;
    org_id_arr.DELETE;
    priority_arr.DELETE;
    reco_num_arr.DELETE;
    customer_trx_id_arr.DELETE;
    payment_schedule_id_arr.DELETE;
    amount_applied_arr.DELETE;
    amount_applied_from_arr.DELETE;
    trans_to_receipt_rate_arr.DELETE;
    receipt_currency_code_arr.DELETE;
    receipt_date_arr.DELETE;
    recommendation_reason_arr.DELETE;
    discount_taken_earned_arr.DELETE;
    discount_taken_unearned_arr.DELETE;
    IF (PG_DEBUG IN ('Y', 'C')) THEN
      log('clear_Reco_lines_struct()-');
    END IF;
    EXCEPTION
      WHEN OTHERS THEN
        log('Exception from arp_autoapply_api.clear_Reco_lines_struct');
        log(SQLERRM);
        RAISE;
  END clear_Reco_lines_struct;

  PROCEDURE insert_recos(p_request_id IN NUMBER) IS
    l_reco_index NUMBER;
    l_reco_line_index NUMBER;
    TYPE rec_rows_tab IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
    rec_rows_arr rec_rows_tab;
    l_index NUMBER;
  BEGIN
    IF (PG_DEBUG IN ('Y', 'C')) THEN
      log('insert_recos()+');
    END IF;

    FOR l_reco_index IN 1 .. NVL(reco_num_arr.LAST, 0)  LOOP
        IF reco_num_arr(l_reco_index) = 1 THEN
        INSERT
        INTO ar_cash_recos_all (
                   recommendation_id,
                   recommendation_type,
                   recommendation_source,
                   remit_reference_id,
                   pay_from_customer,
                   customer_site_use_id,
                   resolved_matching_number,
                   resolved_matching_date,
                   resolved_matching_class,
                   resolved_match_currency,
                   cons_inv_id,
                   match_resolved_using,
                   match_score_value,
                   match_reason_code,
                   recommendation_status,
                   autoapply_status,
                   org_id,
                   created_by,
                   creation_date,
                   last_updated_by,
                   last_update_date,
                   last_update_login,
                   program_application_id,
                   program_id,
                   program_update_date,
                   request_id,
                   automatch_id,
                   priority)
        VALUES   (reco_id_arr(l_reco_index),
                 'TRX',
                 'AUTOMATCH',
                 remit_ref_id_arr(l_reco_index),
                 customer_id_arr(l_reco_index),
                 customer_site_use_id_arr(l_reco_index),
                 resolved_matching_number_arr(l_reco_index),
                 resolved_matching_date_arr(l_reco_index),
                 resolved_matching_class_arr(l_reco_index),
                 resolved_match_currency_arr(l_reco_index),
                 cons_inv_id_arr(l_reco_index),
                 match_resolved_using_arr(l_reco_index),
                 match_score_value_arr(l_reco_index),
                 match_reason_code_arr(l_reco_index),
                 'CREATED',
                 'NONE',
                 org_id_arr(l_reco_index),
                 g_created_by,
                 SYSDATE,
                 g_last_updated_by,
                 SYSDATE,
                 g_last_update_login,
                 g_program_application_id,
                 g_program_id,
                 SYSDATE,
                 p_request_id,
                 automatch_id_arr(l_reco_index),
                 priority_arr(l_reco_index));
        END IF;
        END LOOP;

    FORALL l_reco_line_index IN 1 .. NVL(reco_id_arr.LAST, 0)
      INSERT INTO ar_cash_reco_lines_all (
                 recommendation_id,
                 line_number,
                 customer_trx_id,
                 payment_schedule_id,
                 amount_applied,
                 amount_applied_from,
                 trans_to_receipt_rate,
                 receipt_currency_code,
                 receipt_date,
                 org_id,
                 created_by,
                 creation_date,
                 last_updated_by,
                 last_update_date,
                 last_update_login,
                 program_application_id,
                 program_id,
                 program_update_date,
                 request_id,
                 recommendation_reason,
                 discount_taken_earned)
      SELECT     reco_id_arr(l_reco_line_index),
                 reco_num_arr(l_reco_line_index),
                 customer_trx_id_arr(l_reco_line_index),
                 payment_schedule_id_arr(l_reco_line_index),
                 amount_applied_arr(l_reco_line_index),
                 amount_applied_from_arr(l_reco_line_index),
                 trans_to_receipt_rate_arr(l_reco_line_index),
                 receipt_currency_code_arr(l_reco_line_index),
                 receipt_date_arr(l_reco_line_index),
                 org_id_arr(l_reco_line_index),
                 g_created_by,
                 SYSDATE,
                 g_last_updated_by,
                 SYSDATE,
                 g_last_update_login,
                 g_program_application_id,
                 g_program_id,
                 SYSDATE,
                 p_request_id,
                 match_reason_code_arr(l_reco_line_index),
                 discount_taken_earned_arr(l_reco_line_index)
      FROM DUAL;
    IF (PG_DEBUG IN ('Y', 'C')) THEN
      log('insert_recos()+');
    END IF;
    EXCEPTION
      WHEN OTHERS THEN
          log('Exception from arp_autoapply_api.insert_recos');
          log(SQLERRM);
          RAISE;
  END insert_recos;

  FUNCTION get_cross_curr_rate(p_amount_applied IN ar_cash_remit_refs.amount_applied%TYPE
                             , p_amount_applied_from IN ar_cash_remit_refs.amount_applied_from%TYPE
                             , p_inv_curr_code IN ar_payment_schedules.invoice_currency_code%TYPE
                             , p_rec_curr_code IN ar_cash_receipts.currency_code%TYPE)
  RETURN NUMBER IS
    l_cross_curr_rate NUMBER;
    l_amount_applied  ar_cash_remit_refs.amount_applied%TYPE;
    l_amount_applied_from ar_cash_remit_refs.amount_applied_from%TYPE;
    l_inv_curr_code ar_payment_schedules.invoice_currency_code%TYPE;
    l_rec_curr_code ar_cash_receipts.currency_code%TYPE;
  BEGIN
    l_amount_applied := NVL(p_amount_applied, 0);
    l_amount_applied_from := NVL(p_amount_applied_from, 0);
    l_inv_curr_code := p_inv_curr_code;
    l_rec_curr_code := p_rec_curr_code;

    AR_CC_LOCKBOX.calc_cross_rate (
    p_amount_applied => l_amount_applied,
    p_amount_applied_from => l_amount_applied_from,
    p_inv_curr_code => l_inv_curr_code,
    p_rec_curr_code => l_rec_curr_code,
    p_cross_rate => l_cross_curr_rate);

    RETURN l_cross_curr_rate;
  END get_cross_curr_rate;

  PROCEDURE calc_amount_app_and_disc(
                    p_customer_id IN AR_PAYMENT_SCHEDULES.customer_id%TYPE
                    , p_bill_to_site_use_id IN AR_PAYMENT_SCHEDULES.customer_site_use_id%TYPE
                    , p_invoice_currency_code IN AR_PAYMENT_SCHEDULES.invoice_currency_code%TYPE
                    , p_ps_id IN AR_PAYMENT_SCHEDULES.payment_schedule_id%TYPE
                    , p_term_id IN AR_PAYMENT_SCHEDULES.term_id%TYPE
                    , p_terms_sequence_number IN AR_PAYMENT_SCHEDULES.terms_sequence_number%TYPE
                    , p_trx_date IN AR_PAYMENT_SCHEDULES.trx_date%TYPE
                    , p_allow_overapp_flag IN RA_CUST_TRX_TYPES.allow_overapplication_flag%TYPE
                    , p_partial_discount_flag IN RA_TERMS.partial_discount_flag%TYPE
                    , p_input_amount IN AR_CASH_REMIT_REFS.amount_applied%TYPE
                    , p_amount_due_original IN AR_PAYMENT_SCHEDULES.amount_due_original%TYPE
                    , p_amount_due_remaining IN AR_PAYMENT_SCHEDULES.amount_due_remaining%TYPE
                    , p_discount_taken_earned IN AR_PAYMENT_SCHEDULES.discount_taken_earned%TYPE
                    , p_discount_taken_unearned IN AR_PAYMENT_SCHEDULES.discount_taken_unearned%TYPE
                    , p_cash_receipt_id IN AR_CASH_RECEIPTS.cash_receipt_id%TYPE
                    , x_out_amount_to_apply OUT  NOCOPY NUMBER
                    , x_out_discount_to_take OUT NOCOPY NUMBER) IS
  l_customer_id AR_PAYMENT_SCHEDULES.customer_id%TYPE;
  l_bill_to_site_use_id AR_PAYMENT_SCHEDULES.customer_site_use_id%TYPE;
  l_invoice_currency_code AR_PAYMENT_SCHEDULES.invoice_currency_code%TYPE;
  l_ps_id AR_PAYMENT_SCHEDULES.payment_schedule_id%TYPE;
  l_term_id AR_PAYMENT_SCHEDULES.term_id%TYPE;
  l_terms_sequence_number AR_PAYMENT_SCHEDULES.terms_sequence_number%TYPE;
  l_trx_date AR_PAYMENT_SCHEDULES.trx_date%TYPE;
  l_allow_overapp_flag RA_CUST_TRX_TYPES.allow_overapplication_flag%TYPE;
  l_partial_discount_flag RA_TERMS.partial_discount_flag%TYPE;
  l_input_amount AR_CASH_REMIT_REFS.amount_applied%TYPE;
  l_amount_due_original AR_PAYMENT_SCHEDULES.amount_due_original%TYPE;
  l_amount_due_remaining AR_PAYMENT_SCHEDULES.amount_due_remaining%TYPE;
  l_discount_taken_earned AR_PAYMENT_SCHEDULES.discount_taken_earned%TYPE;
  l_discount_taken_unearned AR_PAYMENT_SCHEDULES.discount_taken_unearned%TYPE;
  l_cash_receipt_id AR_CASH_RECEIPTS.cash_receipt_id%TYPE;

  ln_earned_disc_pct		    NUMBER;
  ln_best_disc_pct		      NUMBER;
  ln_out_discount_date      DATE;
  ln_out_earned_discount    NUMBER;
  ln_out_unearned_discount 	NUMBER;

  l_allow_discount VARCHAR2(1);
  l_grace_days     NUMBER;
BEGIN
  IF (PG_DEBUG IN ('Y', 'C')) THEN
        log('arp_autoapply_api.calc_amount_app_and_disc(+)');
  END IF;
  l_customer_id := p_customer_id;
  l_bill_to_site_use_id := p_bill_to_site_use_id;
  l_invoice_currency_code := p_invoice_currency_code;
  l_ps_id := p_ps_id;
  l_term_id := p_term_id;
  l_terms_sequence_number := p_terms_sequence_number;
  l_trx_date := p_trx_date;
  l_allow_overapp_flag := p_allow_overapp_flag;
  l_partial_discount_flag := p_partial_discount_flag;
  l_input_amount := p_input_amount;
  l_amount_due_original := p_amount_due_original;
  l_amount_due_remaining := p_amount_due_remaining;
  l_discount_taken_earned := p_discount_taken_earned;
  l_discount_taken_unearned := p_discount_taken_unearned;

  SELECT NVL(NVL(site.discount_terms, cust.discount_terms),'Y')
  INTO  l_allow_discount
  FROM
    hz_customer_profiles      cust
  , hz_customer_profiles      site
  WHERE
        cust.cust_account_id          = l_customer_id
  AND   cust.site_use_id              IS NULL
  AND   site.cust_account_id (+)      = cust.cust_account_id
  AND   site.site_use_id (+)          = l_bill_to_site_use_id;

  SELECT NVL(NVL(site.discount_grace_days, cust.discount_grace_days),0)
  INTO  l_grace_days
  FROM
    hz_customer_profiles 	cust
  , hz_customer_profiles 	site
  , hz_cust_accounts		cust_acct
  WHERE
    	  cust_acct.cust_account_id 	= l_customer_id
  AND   cust.cust_account_id 		= cust_acct.cust_account_id
  AND   cust.site_use_id 		IS NULL
  AND   site.cust_account_id (+) 	= cust_acct.cust_account_id
  AND   site.site_use_id (+) 		= NVL(l_BILL_TO_SITE_USE_ID, -4444);

  arp_calculate_discount.discounts_cover(
        --*** IN
        p_mode 			=> 3 /* Default */
      , p_invoice_currency_code 	=> l_invoice_currency_code
      , p_ps_id 			=> l_ps_id
      , p_term_id			=> l_term_id
      , p_terms_sequence_number	=> l_terms_sequence_number
      , p_trx_date		=> l_trx_date
      , p_apply_date		=> trunc(sysdate)
      , p_grace_days		=> l_grace_days
      , p_default_amt_apply_flag	=> 'PMT'
      , p_partial_discount_flag	=> l_partial_discount_flag
      , p_calc_discount_on_lines_flag=>NULL
      , p_allow_overapp_flag	=> l_allow_overapp_flag
      , p_close_invoice_flag	=> 'N'
      , p_input_amount		=> l_input_amount
      , p_amount_due_original	=> l_amount_due_original
      , p_amount_due_remaining	=> l_amount_due_remaining
      , p_discount_taken_earned	=> l_discount_taken_earned
      , p_discount_taken_unearned	=> l_discount_taken_unearned
      , p_amount_line_items_original=> NULL
      , p_module_name		=> 'ARATAPPM'
      , p_module_version		=> '1.0'
        --*** OUT
      , p_earned_disc_pct		=> ln_earned_disc_pct
      , p_best_disc_pct		=> ln_best_disc_pct
      , p_out_discount_date	=> ln_out_discount_date
      , p_out_earned_discount	=> ln_out_earned_discount
      , p_out_unearned_discount	=> ln_out_unearned_discount
      , p_out_amount_to_apply	=> x_out_amount_to_apply
      , p_out_discount_to_take	=> x_out_discount_to_take
      , p_cash_receipt_id       => l_cash_receipt_id
      , p_allow_discount        => l_allow_discount
  	);
  IF (PG_DEBUG IN ('Y', 'C')) THEN
        log('arp_autoapply_api.calc_amount_app_and_disc(-)');
  END IF;
  EXCEPTION
    WHEN OTHERS THEN
      log('Exception from arp_autoapply_api.calc_amount_app_and_disc()');
      log(SQLERRM);
      RAISE;
END;

PROCEDURE calc_amt_applied_from(
  p_currency_code IN VARCHAR2,
  p_amount_applied IN ar_payments_interface.amount_applied1%type,
  p_trans_to_receipt_rate IN ar_payments_interface.trans_to_receipt_rate1%type,
  amount_applied_from OUT NOCOPY ar_payments_interface.amount_applied_from1%type
                               ) IS
--
l_mau                           NUMBER;
l_precision                     NUMBER(1);
l_extended_precision            NUMBER;
--

BEGIN
--
  log( 'calc_amt_applied_from() +' );
  log('p_amount_applied = ' || to_char(p_amount_applied));
  log('p_trans_to_receipt_rate = ' || to_char(p_trans_to_receipt_rate));
  log('p curr code = ' || p_currency_code);

     fnd_currency.Get_Info(
                             p_currency_code,
                             l_precision,
                             l_extended_precision,
                             l_mau);
     IF (l_mau IS NOT NULL) THEN
            amount_applied_from :=
                  ROUND((p_amount_applied *
                         p_trans_to_receipt_rate) /
                         l_mau) * l_mau;
     ELSE
            amount_applied_from :=
                  ROUND((p_amount_applied *
                         p_trans_to_receipt_rate),
                         l_precision);
     END IF;  /* l_mau is not null */

  /* after amount_applied_from is calculated, we need to remove
     the decimal place since the value stored in the interim
     table and then transfered to the interface tables is stored
     with an implied decimal */

  log('p_amount_applied_from = ' || to_char(amount_applied_from));
  log( 'calc_amt_applied_from() -' );

END calc_amt_applied_from;

PROCEDURE calc_amt_applied(
  p_invoice_currency_code IN VARCHAR2,
  p_amount_applied_from IN ar_payments_interface.amount_applied_from1%type,
  p_trans_to_receipt_rate IN ar_payments_interface.trans_to_receipt_rate1%type,
  amount_applied OUT NOCOPY ar_payments_interface.amount_applied1%type
                           ) IS

--
l_mau                           NUMBER;
l_precision                     NUMBER(1);
l_extended_precision            NUMBER;
--

BEGIN
  log( 'calc_amt_applied() +' );
  log('p_amount_applied_from = ' || to_char(p_amount_applied_from));
  log('p_trans_to_receipt_rate = ' || to_char(p_trans_to_receipt_rate));
  log('p inv curr code = ' || p_invoice_currency_code);

 fnd_currency.Get_Info(
                        p_invoice_currency_code,
                        l_precision,
                        l_extended_precision,
                        l_mau);
    IF (l_mau IS NOT NULL) THEN
          amount_applied :=
                 ROUND((p_amount_applied_from /
                        p_trans_to_receipt_rate) /
                        l_mau) * l_mau;
    ELSE
         amount_applied:=
                 ROUND((p_amount_applied_from /
                        p_trans_to_receipt_rate),
                        l_precision);
    END IF;  /* l_mau is not null */

  log('p_amount_applied = ' || to_char(amount_applied));
  log( 'calc_amt_applied() -' );

END calc_amt_applied;


/*===========================================================================+
 * PROCEDURE                                                                 *
 *     DELETE_INTERIM_RECORDS()                                              *
 * DESCRIPTION                                                               *
 *   Delete records from ar_cash_remit_refs_interim.                         *
 * SCOPE - LOCAL                                                             *
 * ARGUMENTS                                                                 *
 *              IN  : None                                                   *
 *              OUT : None                                                   *
 *                                                                           *
 * RETURNS      NONE                    				                             *
 * ALGORITHM                                                                 *
 *  1. Delete records from ar_cash_remit_refs_interim.                       *
 * NOTES -                                                                   *
 *   1. This is called from the XML report                                   *
 *                                                                           *
 * MODIFICATION HISTORY -  09/03/2009 - Created by AGHORAKA	     	           *
 *                                                                           *
 +===========================================================================*/
  PROCEDURE delete_interim_records IS
  BEGIN
     IF (PG_DEBUG IN ('Y', 'C')) THEN
          log('arp_autoapply_api.delete_interim_records()+' );
     END IF;
    DELETE FROM ar_cash_remit_refs_interim;
    IF (PG_DEBUG IN ('Y', 'C')) THEN
          log('No. of records deleted: ' || SQL%ROWCOUNT );
     END IF;
     IF (PG_DEBUG IN ('Y', 'C')) THEN
          log('arp_autoapply_api.delete_interim_records(-)' );
     END IF;
  EXCEPTION
     WHEN OTHERS THEN
          log('Exception from arp_autoapply_api.delete_interim_records');
          log(SQLERRM);
          RAISE;
  END delete_interim_records;

END ARP_AUTOAPPLY_API;

/
