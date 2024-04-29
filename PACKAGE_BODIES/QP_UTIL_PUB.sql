--------------------------------------------------------
--  DDL for Package Body QP_UTIL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_UTIL_PUB" AS
/* $Header: QPXRTCNB.pls 120.9.12010000.7 2010/04/07 07:35:06 hmohamme ship $ */

l_debug VARCHAR2(3);
/************************************************************************
Utility procedure to update the qp_limit_balances table as an autonomous
transaction. This procedure is called by the Reverse_Limits procedure below.
*************************************************************************/

PROCEDURE Update_Balance(p_new_trxn_amount  IN NUMBER,
                         p_old_trxn_amount  IN NUMBER,
                         p_limit_balance_id IN NUMBER)
IS
PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN

  IF l_debug = Fnd_Api.G_TRUE THEN
  Qp_Preq_Grp.engine_debug('***Begin Update_Balance***');

  END IF;
  UPDATE qp_limit_balances
  SET    available_amount = available_amount - p_new_trxn_amount +
                            p_old_trxn_amount,
         last_update_date = SYSDATE,
         last_updated_by = Fnd_Global.user_id
  WHERE  limit_balance_id = p_limit_balance_id;

  COMMIT;

  IF l_debug = Fnd_Api.G_TRUE THEN
  Qp_Preq_Grp.engine_debug('***End Update_Balance***');

  END IF;
END Update_Balance;


/***********************************************************************
   Procedure to Reverse the Limit Balances and Transactions for a return
   or cancellation.(Public API).
***********************************************************************/
PROCEDURE Reverse_Limits (p_action_code             IN  VARCHAR2,
                          p_cons_price_request_code IN  VARCHAR2,
                          p_orig_ordered_qty        IN  NUMBER   DEFAULT NULL,
                          p_amended_qty             IN  NUMBER   DEFAULT NULL,
                          p_ret_price_request_code  IN  VARCHAR2 DEFAULT NULL,
                          p_returned_qty            IN  NUMBER   DEFAULT NULL,
                          x_return_status           OUT NOCOPY VARCHAR2,
                          x_return_message          OUT NOCOPY VARCHAR2)
IS

CURSOR trans_cur(a_cons_price_request_code    VARCHAR2)
IS
  SELECT limit_balance_id, list_header_id, list_line_id,
         price_request_type_code, price_request_code,
         pricing_phase_id, amount
  FROM   qp_limit_transactions
  WHERE  price_request_code = a_cons_price_request_code;

l_proration              NUMBER;
l_returned_amount        NUMBER;
l_consumed_amount        NUMBER;

BEGIN

  l_debug := Qp_Preq_Grp.G_DEBUG_ENGINE;
  IF l_debug = Fnd_Api.G_TRUE THEN
  Qp_Preq_Grp.engine_debug('***Begin Procedure Reverse_Limit *** ');

  END IF;
  x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

  --Price Request Code corresponding to the consuming order line is mandatory.
  IF p_cons_price_request_code IS NULL THEN
    Fnd_Message.SET_NAME('QP','QP_PARAMETER_REQUIRED');
    Fnd_Message.SET_TOKEN('PARAMETER',p_cons_price_request_code);
    x_return_message := Fnd_Message.GET;
    RAISE Fnd_Api.G_EXC_ERROR;

  END IF;

  --Action Code is mandatory.
  IF p_action_code IS NULL THEN

    Fnd_Message.SET_NAME('QP','QP_PARAMETER_REQUIRED');
    Fnd_Message.SET_TOKEN('PARAMETER',p_action_code);
    x_return_message := Fnd_Message.GET;
    RAISE Fnd_Api.G_EXC_ERROR;

  END IF;

  --Originally ordered qty must be not-null and non-zero.
  IF p_action_code <> 'CANCEL' AND
    (p_orig_ordered_qty IS NULL OR p_orig_ordered_qty = 0) THEN

    Fnd_Message.SET_NAME('QP','QP_NONZERO_PARAMETER_REQD');
    Fnd_Message.SET_TOKEN('PARAMETER',p_orig_ordered_qty);
    x_return_message := Fnd_Message.GET;
    RAISE Fnd_Api.G_EXC_ERROR;

  END IF;

  --If Action Code is 'RETURN' then the returned qty must be not null.
  IF p_action_code = 'RETURN' AND p_returned_qty IS NULL THEN

    Fnd_Message.SET_NAME('QP','QP_PARAMETER_REQUIRED');
    Fnd_Message.SET_TOKEN('PARAMETER',p_returned_qty);
    x_return_message := Fnd_Message.GET;
    RAISE Fnd_Api.G_EXC_ERROR;

  END IF;

  --If Action Code is 'RETURN' then the price_request_code of the return
  --line must be not null.
  IF p_action_code = 'RETURN' AND p_ret_price_request_code IS NULL THEN

    Fnd_Message.SET_NAME('QP','QP_PARAMETER_REQUIRED');
    Fnd_Message.SET_TOKEN('PARAMETER',p_ret_price_request_code);
    x_return_message := Fnd_Message.GET;
    RAISE Fnd_Api.G_EXC_ERROR;

  END IF;

  --If Action Code is 'AMEND' then the amended qty must be not null.
  IF p_action_code = 'AMEND' AND p_amended_qty IS NULL THEN

    Fnd_Message.SET_NAME('QP','QP_PARAMETER_REQUIRED');
    Fnd_Message.SET_TOKEN('PARAMETER',p_amended_qty);
    x_return_message := Fnd_Message.GET;
    RAISE Fnd_Api.G_EXC_ERROR;

  END IF;

  --If Action Code is 'AMEND' then the amended qty must not be greater
  --than the orignally ordered qty.
  IF p_action_code = 'AMEND' AND p_amended_qty > p_orig_ordered_qty THEN

    Fnd_Message.SET_NAME('QP','QP_PARAMETER_MUST_BE_LESSER');
    Fnd_Message.SET_TOKEN('PARAMETER1',p_amended_qty);
    Fnd_Message.SET_TOKEN('PARAMETER2',p_orig_ordered_qty);
    x_return_message := Fnd_Message.GET;
    RAISE Fnd_Api.G_EXC_ERROR;

  END IF;

  --Proration Ratio Calculation
  IF p_action_code = 'CANCEL' THEN
     l_proration := 0;
  ELSIF p_action_code = 'RETURN' THEN
     l_proration := -1 * (p_returned_qty/p_orig_ordered_qty); --Sign Change
  ELSIF p_action_code = 'AMEND' THEN
     l_proration := p_amended_qty/p_orig_ordered_qty;
  --bug#7540503
  ELSIF p_action_code = 'SPLIT_ORIG' THEN
     l_proration := p_amended_qty/p_orig_ordered_qty;
  ELSIF p_action_code = 'SPLIT_NEW' THEN
     l_proration := p_returned_qty/p_orig_ordered_qty;
   --bug#7540503
  ELSE
     Fnd_Message.SET_NAME('QP','QP_INVALID_ACTION_CODE');
     x_return_message := Fnd_Message.GET;
     RAISE Fnd_Api.G_EXC_ERROR;
  END IF;


  --For each Limit Transaction Record for Consuming line's price_request_code,
  --insert or update a return limit transaction record(if action_code is RETURN)
  --or update the consuming record if the action_code is AMEND or CANCEL.

  FOR l_cons_trans_rec IN trans_cur(p_cons_price_request_code)
  LOOP

    IF p_action_code = 'RETURN' THEN

      BEGIN
        --Check if a return record exists.
        SELECT amount
        INTO   l_returned_amount
        FROM   qp_limit_transactions
        WHERE  price_request_code = p_ret_price_request_code
        AND    list_header_id = l_cons_trans_rec.list_header_id
        AND    list_line_id = l_cons_trans_rec.list_line_id
        AND    limit_balance_id = l_cons_trans_rec.limit_balance_id;

      EXCEPTION
        WHEN NO_DATA_FOUND THEN

          --Record does not already exist,insert a new return trxn record
          INSERT INTO qp_limit_transactions
          (limit_balance_id,
           creation_date,
           created_by,
           last_update_date,
           last_updated_by,
           list_header_id,
           list_line_id,
           price_request_date,
           price_request_type_code,
           price_request_code,
           pricing_phase_id,
           amount
          )
          VALUES
          (l_cons_trans_rec.limit_balance_id,
           SYSDATE,
           Fnd_Global.user_id,
           SYSDATE,
           Fnd_Global.user_id,
           l_cons_trans_rec.list_header_id,
           l_cons_trans_rec.list_line_id,
           SYSDATE,
           l_cons_trans_rec.price_request_type_code,
           p_ret_price_request_code,
           l_cons_trans_rec.pricing_phase_id,
           l_proration * l_cons_trans_rec.amount
          );

          --Update Limit Balance record
          Update_Balance(p_new_trxn_amount =>
                                   l_proration * l_cons_trans_rec.amount,
                         p_old_trxn_amount => 0,
                         p_limit_balance_id => l_cons_trans_rec.limit_balance_id
                         );

          GOTO next_in_loop; --To next record in loop

      END; --Block around SELECT stmt to check if returned rec exists

      --Return Transaction Record exists. Update trxn amount
      UPDATE qp_limit_transactions
      SET    amount = (l_proration * l_cons_trans_rec.amount),
             last_update_date = SYSDATE,
             last_updated_by = Fnd_Global.user_id
      WHERE  price_request_code = p_ret_price_request_code
      AND    list_header_id = l_cons_trans_rec.list_header_id
      AND    list_line_id = l_cons_trans_rec.list_line_id
      AND    limit_balance_id = l_cons_trans_rec.limit_balance_id;

      --Update Limit_Balance record
      Update_Balance(p_new_trxn_amount => l_proration * l_cons_trans_rec.amount,
                     p_old_trxn_amount => l_returned_amount,
                     p_limit_balance_id => l_cons_trans_rec.limit_balance_id);

    ELSIF p_action_code IN ('CANCEL','AMEND') THEN

      BEGIN
        --A record must exist for it to be cancelled or amended.
        SELECT amount
        INTO   l_consumed_amount
        FROM   qp_limit_transactions
        WHERE  price_request_code = p_cons_price_request_code
        AND    list_header_id = l_cons_trans_rec.list_header_id
        AND    list_line_id = l_cons_trans_rec.list_line_id
        AND    limit_balance_id = l_cons_trans_rec.limit_balance_id;

      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          Fnd_Message.SET_NAME('QP','QP_LIMIT_TXN_NOT_FOUND');
          x_return_message := Fnd_Message.GET;
          RAISE Fnd_Api.G_EXC_ERROR;
      END;

      --Transaction Record to be cancelled/amended exists. Update trxn amount.
      UPDATE qp_limit_transactions
      SET    amount = (l_proration * l_cons_trans_rec.amount),
             last_update_date = SYSDATE,
             last_updated_by = Fnd_Global.user_id
      WHERE  price_request_code = p_cons_price_request_code
      AND    list_header_id = l_cons_trans_rec.list_header_id
      AND    list_line_id = l_cons_trans_rec.list_line_id
      AND    limit_balance_id = l_cons_trans_rec.limit_balance_id;

      --Update Limit_Balance record
      Update_Balance(p_new_trxn_amount => l_proration * l_cons_trans_rec.amount,
                     p_old_trxn_amount => l_consumed_amount,
                     p_limit_balance_id => l_cons_trans_rec.limit_balance_id);

    --bug#7540503
    ELSIF p_action_code = 'SPLIT_NEW' THEN
      BEGIN
        --Check if a split child record exists.
        SELECT amount
        INTO   l_returned_amount
        FROM   qp_limit_transactions
        WHERE  price_request_code = p_ret_price_request_code
        AND    list_header_id = l_cons_trans_rec.list_header_id
        AND    list_line_id = l_cons_trans_rec.list_line_id
        AND    limit_balance_id = l_cons_trans_rec.limit_balance_id;

      EXCEPTION
        WHEN NO_DATA_FOUND THEN

          --Record does not already exist,insert a new return trxn record
          INSERT INTO qp_limit_transactions
          (limit_balance_id,
           creation_date,
           created_by,
           last_update_date,
           last_updated_by,
           list_header_id,
           list_line_id,
           price_request_date,
           price_request_type_code,
           price_request_code,
           pricing_phase_id,
           amount
          )
          VALUES
          (l_cons_trans_rec.limit_balance_id,
           sysdate,
           fnd_global.user_id,
           sysdate,
           fnd_global.user_id,
           l_cons_trans_rec.list_header_id,
           l_cons_trans_rec.list_line_id,
           sysdate,
           l_cons_trans_rec.price_request_type_code,
           p_ret_price_request_code,
           l_cons_trans_rec.pricing_phase_id,
           l_proration * l_cons_trans_rec.amount
          );

          --Update Limit Balance record
          Update_Balance(p_new_trxn_amount =>
                                   l_proration * l_cons_trans_rec.amount,
                         p_old_trxn_amount => 0,
                         p_limit_balance_id => l_cons_trans_rec.limit_balance_id
                         );

          GOTO next_in_loop; --To next record in loop

      END; --Block around SELECT stmt to check if split child rec exists

    ELSIF p_action_code = 'SPLIT_ORIG' THEN
      BEGIN
        --A record must exist for it to updated.
        SELECT amount
        INTO   l_consumed_amount
        FROM   qp_limit_transactions
        WHERE  price_request_code = p_cons_price_request_code
        AND    list_header_id = l_cons_trans_rec.list_header_id
        AND    list_line_id = l_cons_trans_rec.list_line_id
        AND    limit_balance_id = l_cons_trans_rec.limit_balance_id;

      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          FND_MESSAGE.SET_NAME('QP','QP_LIMIT_TXN_NOT_FOUND');
          x_return_message := FND_MESSAGE.GET;
          RAISE FND_API.G_EXC_ERROR;
      END;

      --Transaction Record to be updated exists. Update trxn amount.
      UPDATE qp_limit_transactions
      SET    amount = (l_proration * l_cons_trans_rec.amount),
             last_update_date = sysdate,
             last_updated_by = fnd_global.user_id
      WHERE  price_request_code = p_cons_price_request_code
      AND    list_header_id = l_cons_trans_rec.list_header_id
      AND    list_line_id = l_cons_trans_rec.list_line_id
      AND    limit_balance_id = l_cons_trans_rec.limit_balance_id;

      --Update Limit_Balance record
      Update_Balance(p_new_trxn_amount => l_proration * l_cons_trans_rec.amount,
                     p_old_trxn_amount => l_consumed_amount,
                     p_limit_balance_id => l_cons_trans_rec.limit_balance_id);
    --bug#7540503

    END IF; --If p_action_code is 'RETURN', 'CANCEL' or 'AMEND'

  <<next_in_loop>>
    NULL;
  END LOOP;--Loop over limit trxn records of consuming price_request_code

  IF l_debug = Fnd_Api.G_TRUE THEN
  Qp_Preq_Grp.engine_debug('***End Procedure Reverse_Limit*** ');

  END IF;
EXCEPTION
  WHEN Fnd_Api.G_EXC_ERROR THEN
    x_return_status := Fnd_Api.G_RET_STS_ERROR;

  WHEN OTHERS THEN
    x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
    x_return_message := SUBSTR(SQLERRM,1,2000);

END Reverse_Limits;

/***********************************************************************
   Procedure to Determine how many lines to pass to the pricing engine
***********************************************************************/

-- p_freight_call_flag added below for bug 3006670
PROCEDURE Get_Order_Lines_Status(p_event_code IN VARCHAR2,
                                 x_order_status_rec OUT NOCOPY ORDER_LINES_STATUS_REC_TYPE,
                                 p_freight_call_flag IN VARCHAR2 := 'N',
                                 p_request_type_code IN VARCHAR2 DEFAULT NULL) IS

CURSOR l_all_lines_info_cur(p_event_code1 VARCHAR2) IS
SELECT 'X'
FROM   qp_pricing_phases a , qp_event_phases b
WHERE  a.pricing_phase_id = b.pricing_phase_id
AND    (a.oid_exists = 'Y' OR a.line_group_exists = 'Y' OR a.rltd_exists = 'Y')
AND    b.pricing_event_code IN (SELECT DECODE(ROWNUM
          ,1 ,SUBSTR(p_event_code,1,INSTR(p_event_code1,',',1,1)-1)
          ,2 ,SUBSTR(p_event_code , INSTR(p_event_code1,',',1,ROWNUM-1) + 1,
             INSTR(p_event_code1,',',1,ROWNUM)-1 - INSTR(p_event_code1,',',1,ROWNUM-1))
          ,3 ,SUBSTR(p_event_code , INSTR(p_event_code1,',',1,ROWNUM-1) + 1,
              INSTR(p_event_code1,',',1,ROWNUM)-1 - INSTR(p_event_code1,',',1,ROWNUM-1))
          ,4 ,SUBSTR(p_event_code , INSTR(p_event_code1,',',1,ROWNUM-1) + 1,
              INSTR(p_event_code1,',',1,ROWNUM)-1 - INSTR(p_event_code1,',',1,ROWNUM-1))
          ,5 ,SUBSTR(p_event_code , INSTR(p_event_code1,',',1,ROWNUM-1) + 1,
              INSTR(p_event_code1,',',1,ROWNUM)-1 - INSTR(p_event_code1,',',1,ROWNUM-1))
          ,6 ,SUBSTR(p_event_code , INSTR(p_event_code1,',',1,ROWNUM-1) + 1,
              INSTR(p_event_code1,',',1,ROWNUM)-1 - INSTR(p_event_code1,',',1,ROWNUM-1)))
         FROM  qp_event_phases
         WHERE ROWNUM < 7)
AND    ROWNUM = 1;

/* For bug 3006670 (if p_freight_call_flag = 'Y')
 * all_lines_flag should return 'N' if additional buylines exist for a PRG
 * that means if rltd_exists='Y' but oid_exists and line_group_exists both ='N',
 * then all_lines_flag should be 'N'
 * (logically, this is equivalent to checking (oid_exists='Y' OR line_group='Y'))
 * the l_all_lines_info_cur_freight cursor has been modified to reflect this
 */
CURSOR l_all_lines_info_cur_freight(p_event_code1 VARCHAR2) IS
SELECT 'X'
FROM   qp_pricing_phases a , qp_event_phases b
WHERE  a.pricing_phase_id = b.pricing_phase_id
AND    (a.oid_exists = 'Y' OR a.line_group_exists = 'Y')
AND    b.pricing_event_code IN (SELECT DECODE(ROWNUM
          ,1 ,SUBSTR(p_event_code,1,INSTR(p_event_code1,',',1,1)-1)
          ,2 ,SUBSTR(p_event_code , INSTR(p_event_code1,',',1,ROWNUM-1) + 1,
             INSTR(p_event_code1,',',1,ROWNUM)-1 - INSTR(p_event_code1,',',1,ROWNUM-1))
          ,3 ,SUBSTR(p_event_code , INSTR(p_event_code1,',',1,ROWNUM-1) + 1,
              INSTR(p_event_code1,',',1,ROWNUM)-1 - INSTR(p_event_code1,',',1,ROWNUM-1))
          ,4 ,SUBSTR(p_event_code , INSTR(p_event_code1,',',1,ROWNUM-1) + 1,
              INSTR(p_event_code1,',',1,ROWNUM)-1 - INSTR(p_event_code1,',',1,ROWNUM-1))
          ,5 ,SUBSTR(p_event_code , INSTR(p_event_code1,',',1,ROWNUM-1) + 1,
              INSTR(p_event_code1,',',1,ROWNUM)-1 - INSTR(p_event_code1,',',1,ROWNUM-1))
          ,6 ,SUBSTR(p_event_code , INSTR(p_event_code1,',',1,ROWNUM-1) + 1,
              INSTR(p_event_code1,',',1,ROWNUM)-1 - INSTR(p_event_code1,',',1,ROWNUM-1)))
         FROM  qp_event_phases
         WHERE ROWNUM < 7)
AND    ROWNUM = 1;

-- l_summary_line_info_cur and l_changed_lines_info_cur were combined into one
-- cursor for performance bug 3756506.
-- passing p_mod_level_code='ORDER' is equiv. to l_summary_line_info_cur
-- passing p_mod_level_code='LINE' is equiv. to l_changed_lines_info_cur
-- [julin/4676740] tuned EXISTS clause
CURSOR l_line_info_cur(p_event_code1 VARCHAR2, p_mod_level_code VARCHAR2) IS
SELECT 'X'
FROM
      (SELECT DECODE(ROWNUM
          ,1 ,SUBSTR(p_event_code,1,INSTR(p_event_code1,',',1,1)-1)
          ,2 ,SUBSTR(p_event_code , INSTR(p_event_code1,',',1,ROWNUM-1) + 1,
             INSTR(p_event_code1,',',1,ROWNUM)-1 - INSTR(p_event_code1,',',1,ROWNUM-1))
          ,3 ,SUBSTR(p_event_code , INSTR(p_event_code1,',',1,ROWNUM-1) + 1,
              INSTR(p_event_code1,',',1,ROWNUM)-1 - INSTR(p_event_code1,',',1,ROWNUM-1))
          ,4 ,SUBSTR(p_event_code , INSTR(p_event_code1,',',1,ROWNUM-1) + 1,
              INSTR(p_event_code1,',',1,ROWNUM)-1 - INSTR(p_event_code1,',',1,ROWNUM-1))
          ,5 ,SUBSTR(p_event_code , INSTR(p_event_code1,',',1,ROWNUM-1) + 1,
              INSTR(p_event_code1,',',1,ROWNUM)-1 - INSTR(p_event_code1,',',1,ROWNUM-1))
          ,6 ,SUBSTR(p_event_code , INSTR(p_event_code1,',',1,ROWNUM-1) + 1,
              INSTR(p_event_code1,',',1,ROWNUM)-1 - INSTR(p_event_code1,',',1,ROWNUM-1))) PRICING_EVENT_CD
         FROM  qp_event_phases
         WHERE pricing_phase_id > 1
         AND   ROWNUM < 7) C,
         QP_EVENT_PHASES B
WHERE B.PRICING_EVENT_CODE = C.PRICING_EVENT_CD
AND   EXISTS (SELECT 'x'
            FROM qp_list_lines a
            WHERE a.pricing_phase_id = b.pricing_phase_id
            AND   a.modifier_level_code=p_mod_level_code
            AND   ROWNUM=1)
AND ROWNUM=1;

CURSOR l_line_info_ptess_cur(p_event_code1 VARCHAR2, p_mod_level_code VARCHAR2) IS
SELECT 'X'
FROM  qp_event_phases b
WHERE b.pricing_event_code IN (SELECT DECODE(ROWNUM
          ,1 ,SUBSTR(p_event_code,1,INSTR(p_event_code1,',',1,1)-1)
          ,2 ,SUBSTR(p_event_code , INSTR(p_event_code1,',',1,ROWNUM-1) + 1,
             INSTR(p_event_code1,',',1,ROWNUM)-1 - INSTR(p_event_code1,',',1,ROWNUM-1))
          ,3 ,SUBSTR(p_event_code , INSTR(p_event_code1,',',1,ROWNUM-1) + 1,
              INSTR(p_event_code1,',',1,ROWNUM)-1 - INSTR(p_event_code1,',',1,ROWNUM-1))
          ,4 ,SUBSTR(p_event_code , INSTR(p_event_code1,',',1,ROWNUM-1) + 1,
              INSTR(p_event_code1,',',1,ROWNUM)-1 - INSTR(p_event_code1,',',1,ROWNUM-1))
          ,5 ,SUBSTR(p_event_code , INSTR(p_event_code1,',',1,ROWNUM-1) + 1,
              INSTR(p_event_code1,',',1,ROWNUM)-1 - INSTR(p_event_code1,',',1,ROWNUM-1))
          ,6 ,SUBSTR(p_event_code , INSTR(p_event_code1,',',1,ROWNUM-1) + 1,
              INSTR(p_event_code1,',',1,ROWNUM)-1 - INSTR(p_event_code1,',',1,ROWNUM-1)))
         FROM  qp_event_phases
         WHERE pricing_phase_id > 1
         AND   ROWNUM < 7)
AND   EXISTS (SELECT /*+ ORDERED */ 'x' -- [julin/4261562] added active_flag and PTE/SS filters
            FROM qp_list_header_phases lhb, qp_list_headers_b qph, qp_price_req_sources_v qprs, qp_list_lines a
            WHERE lhb.pricing_phase_id = b.pricing_phase_id
            AND   qph.list_header_id = lhb.list_header_id
            AND   qph.active_flag = 'Y'
            AND   qprs.request_type_code = p_request_type_code
            AND   qprs.source_system_code = qph.source_system_code
            AND   a.pricing_phase_id = b.pricing_phase_id
            AND   a.list_header_id = qph.list_header_id
            AND   a.modifier_level_code = p_mod_level_code
            AND   ROWNUM=1)
AND ROWNUM=1;

CURSOR l_pricing_phase_exists_cur IS
SELECT 'X'
FROM   qp_event_phases
WHERE  pricing_event_code = p_event_code
AND    pricing_phase_id = 1;


l_pricing_phase_id NUMBER;
l_line_group_exists QP_PRICING_PHASES.LINE_GROUP_EXISTS%TYPE :='U';
l_oid_exists QP_PRICING_PHASES.OID_EXISTS%TYPE :='U';
l_rltd_exists QP_PRICING_PHASES.RLTD_EXISTS%TYPE :='U';
l_list_line_type QP_LIST_LINES.LIST_LINE_TYPE_CODE%TYPE :='XXX';
l_order_status_rec Qp_Util_Pub.ORDER_LINES_STATUS_REC_TYPE;
l_dummy VARCHAR2(1);
BEGIN
  l_debug := Qp_Preq_Grp.G_DEBUG_ENGINE;
  l_dummy := NULL;

  -- bug 3006670
  -- use alternate cursor if freight call
  IF p_freight_call_flag = 'Y' THEN
    OPEN l_all_lines_info_cur_freight(p_event_code || ',');
    FETCH l_all_lines_info_cur_freight INTO l_dummy;
    CLOSE l_all_lines_info_cur_freight;
  ELSE
    OPEN l_all_lines_info_cur(p_event_code || ',') ;
    FETCH l_all_lines_info_cur INTO l_dummy;
    CLOSE l_all_lines_info_cur;
  END IF;

  IF (l_dummy = 'X') THEN
   l_order_status_rec.ALL_LINES_FLAG := 'Y';
  ELSE
   l_order_status_rec.ALL_LINES_FLAG := 'N';
  END IF;

  l_dummy := NULL;

  -- 3756506, this used to call l_summary_line_info_cur
  -- [julin/4676740] using separate cursor when req type given
  IF (p_request_type_code IS NOT NULL) THEN
    OPEN l_line_info_ptess_cur(p_event_code || ',', 'ORDER');
    FETCH l_line_info_ptess_cur INTO l_dummy;
    CLOSE l_line_info_ptess_cur;
  ELSE
    OPEN l_line_info_cur(p_event_code || ',', 'ORDER');
    FETCH l_line_info_cur INTO l_dummy;
    CLOSE l_line_info_cur;
  END IF;

  IF (l_dummy = 'X') THEN
   l_order_status_rec.SUMMARY_LINE_FLAG := 'Y';
  ELSE
   l_order_status_rec.SUMMARY_LINE_FLAG := 'N';
  END IF;

  l_dummy := NULL;

  OPEN l_pricing_phase_exists_cur;
  FETCH l_pricing_phase_exists_cur INTO l_dummy;
  CLOSE l_pricing_phase_exists_cur;

  IF (l_dummy = 'X') THEN
   l_order_status_rec.CHANGED_LINES_FLAG := 'Y';
  ELSE
   l_order_status_rec.CHANGED_LINES_FLAG := 'N';
  END IF;

 IF (l_order_status_rec.CHANGED_LINES_FLAG = 'N') THEN

   -- 3756506, this used to call l_changed_lines_info_cur
   -- [julin/4676740] using separate cursor when req type given
   IF (p_request_type_code IS NOT NULL) THEN
     OPEN l_line_info_ptess_cur(p_event_code || ',', 'LINE');
     FETCH l_line_info_ptess_cur INTO l_dummy;
     CLOSE l_line_info_ptess_cur;
   ELSE
     OPEN l_line_info_cur(p_event_code || ',', 'LINE');
     FETCH l_line_info_cur INTO l_dummy;
     CLOSE l_line_info_cur;
   END IF;

   IF (l_dummy = 'X') THEN
    l_order_status_rec.CHANGED_LINES_FLAG := 'Y';
   ELSE
    l_order_status_rec.CHANGED_LINES_FLAG := 'N';
   END IF;

 END IF;

  x_order_status_rec := l_order_status_rec;

EXCEPTION
  WHEN OTHERS THEN
   IF l_debug = Fnd_Api.G_TRUE THEN
   Qp_Preq_Grp.engine_debug('Error in Procedure Get_Order_Lines_Status');

   END IF;
END Get_Order_Lines_Status;

/***********************************************************************
   Change done for bug 7241731/7596981.
   Procedure to Determine how many lines to pass to the pricing engine
   during a manual modifier call. Currently there is no column in
   qp_pricing_phases that will indicate exclusive presence of a manual
   linegroup modifier for particular phases.
   Due to which a query on qp_list_lines was used earlier in
   GET_MANUAL_ADV_STATUS procedure of OEXVADJB package. That cursor is
   causing performance issue for some customers.
   Final fix will be to add such a column in qp_pricing_phases table.
   Meanwhile, this procedure is written to use manual_modifier_flag and
   line_group_exists from qp_pricing_phases to determine the manual Linegroup
   status which will take care of most of the customer set-up cases.
   Once the change is made to add a column to the qp_pricing_table this
   procedure will be changed to look at that column value.
  ***********************************************************************/


PROCEDURE Get_Manual_All_Lines_Status(p_event_code IN VARCHAR2,
                                      x_manual_all_lines_status OUT NOCOPY VARCHAR2) IS

CURSOR l_manual_all_lines_info_cur(p_event_code1 VARCHAR2) IS
SELECT 'Y'
FROM   qp_pricing_phases a , qp_event_phases b
WHERE  a.pricing_phase_id = b.pricing_phase_id
AND    a.line_group_exists = 'Y' -- no need to consider PRG/OID for manual mod call
AND    a.manual_modifier_flag in ('M','B') -- phases tagged to have manual modifiers
AND    b.pricing_event_code IN (SELECT DECODE(ROWNUM
          ,1 ,SUBSTR(p_event_code,1,INSTR(p_event_code1,',',1,1)-1)
          ,2 ,SUBSTR(p_event_code , INSTR(p_event_code1,',',1,ROWNUM-1) + 1,
             INSTR(p_event_code1,',',1,ROWNUM)-1 - INSTR(p_event_code1,',',1,ROWNUM-1))
          ,3 ,SUBSTR(p_event_code , INSTR(p_event_code1,',',1,ROWNUM-1) + 1,
              INSTR(p_event_code1,',',1,ROWNUM)-1 - INSTR(p_event_code1,',',1,ROWNUM-1))
          ,4 ,SUBSTR(p_event_code , INSTR(p_event_code1,',',1,ROWNUM-1) + 1,
              INSTR(p_event_code1,',',1,ROWNUM)-1 - INSTR(p_event_code1,',',1,ROWNUM-1))
          ,5 ,SUBSTR(p_event_code , INSTR(p_event_code1,',',1,ROWNUM-1) + 1,
              INSTR(p_event_code1,',',1,ROWNUM)-1 - INSTR(p_event_code1,',',1,ROWNUM-1))
          ,6 ,SUBSTR(p_event_code , INSTR(p_event_code1,',',1,ROWNUM-1) + 1,
              INSTR(p_event_code1,',',1,ROWNUM)-1 - INSTR(p_event_code1,',',1,ROWNUM-1)))
         FROM  qp_event_phases
         WHERE ROWNUM < 7)
AND    ROWNUM = 1;

BEGIN
l_debug := QP_PREQ_GRP.G_DEBUG_ENGINE;

IF l_debug = FND_API.G_TRUE THEN
QP_PREQ_GRP.engine_debug(' Inside Get_Manual_All_Lines_Status ');
END IF;

x_manual_all_lines_status := 'N';

OPEN l_manual_all_lines_info_cur(p_event_code || ',') ;
FETCH l_manual_all_lines_info_cur INTO x_manual_all_lines_status;
CLOSE l_manual_all_lines_info_cur;

IF l_debug = FND_API.G_TRUE THEN
QP_PREQ_GRP.engine_debug(' x_manual_all_lines_status :'||x_manual_all_lines_status);
QP_PREQ_GRP.engine_debug(' Leaving Get_Manual_All_Lines_Status ');
END IF;

EXCEPTION
  WHEN OTHERS THEN

   IF l_debug = FND_API.G_TRUE THEN
   QP_PREQ_GRP.engine_debug('Error in Procedure Get_Manual_All_Lines_Status');
   END IF;

END Get_Manual_All_Lines_Status;

/***********************************************************************
   Procedure to Validate a Given Price List with a Currency_code
***********************************************************************/

PROCEDURE Validate_Price_list_Curr_code
(
    l_price_list_id	        IN NUMBER
   ,l_currency_code             IN VARCHAR2
   ,l_pricing_effective_date    IN DATE
   ,l_validate_result          OUT NOCOPY VARCHAR2
)
IS

l_select    VARCHAR2(1);
l_temp_date   DATE;

CURSOR c_validate_plist_curr_multi
IS

SELECT 'X'
FROM   qp_currency_details a
      ,qp_list_headers_b   b
WHERE  a.currency_header_id = b.currency_header_id
AND    a.to_currency_code = l_currency_code
AND    b.list_header_id = l_price_list_id
AND    TRUNC(l_temp_date) >= TRUNC(NVL(a.start_date_active, l_temp_date))
AND    TRUNC(l_temp_date) <= TRUNC(NVL(a.end_date_active, l_temp_date))
AND    TRUNC(l_temp_date) >= TRUNC(NVL(b.start_date_active, l_temp_date))
AND    TRUNC(l_temp_date) <= TRUNC(NVL(b.end_date_active, l_temp_date));


CURSOR c_validate_pl_curr_no_multi
IS

SELECT 'X'
FROM   qp_list_headers_b
WHERE  currency_code = l_currency_code
AND    list_header_id = l_price_list_id
AND    TRUNC(l_temp_date) >= TRUNC(NVL(start_date_active, l_temp_date))
AND    TRUNC(l_temp_date) <= TRUNC(NVL(end_date_active, l_temp_date));

BEGIN

  IF l_pricing_effective_date IS NULL THEN
     l_temp_date := SYSDATE;
  ELSE
     l_temp_date := l_pricing_effective_date;
  END IF;

  -- Added new profile (QP_MULTI_CURRENCY_USAGE) with default value 'Y' to maintain current behaviour,
  -- bug 2943033
  IF  UPPER(Fnd_Profile.value('QP_MULTI_CURRENCY_INSTALLED'))  IN ('Y', 'YES') AND
      (NVL(Fnd_Profile.value('QP_MULTI_CURRENCY_USAGE'), 'Y') = 'Y') THEN
   IF l_debug = Fnd_Api.G_TRUE THEN
   Qp_Preq_Grp.engine_debug('validate price list - multi-currency');

   END IF;

    --Multi-Currency is installed
    OPEN c_validate_plist_curr_multi;
    FETCH c_validate_plist_curr_multi INTO l_select;

    IF c_validate_plist_curr_multi%FOUND THEN

      l_validate_result := 'Y';
      CLOSE c_validate_plist_curr_multi;

    ELSE
      l_validate_result := 'N';
      CLOSE c_validate_plist_curr_multi;

    END IF;

  ELSE  --Multi-Currency is not installed

   IF l_debug = Fnd_Api.G_TRUE THEN
   Qp_Preq_Grp.engine_debug('validate price list - no multi-currency');

   END IF;
    OPEN c_validate_pl_curr_no_multi;
    FETCH c_validate_pl_curr_no_multi INTO l_select;

    IF c_validate_pl_curr_no_multi%FOUND THEN

      l_validate_result := 'Y';
      CLOSE c_validate_pl_curr_no_multi;

    ELSE
      l_validate_result := 'N';
      CLOSE c_validate_pl_curr_no_multi;

    END IF;

  END IF; --Multi-Currency is installed


   IF l_debug = Fnd_Api.G_TRUE THEN
   Qp_Preq_Grp.engine_debug('validate price list - result is ' || l_validate_result);

   END IF;
EXCEPTION
  WHEN OTHERS THEN
    l_validate_result := 'N';

    IF Fnd_Msg_Pub.Check_Msg_Level(Fnd_Msg_Pub.G_MSG_LVL_ERROR) THEN
        Fnd_Message.SET_NAME('QP', 'QP_ERR_VALID_PRICELIST_N_CURR');
    END IF;

     IF c_validate_plist_curr_multi%ISOPEN THEN
       CLOSE c_validate_plist_curr_multi;
     END IF;

     IF c_validate_pl_curr_no_multi%ISOPEN THEN
       CLOSE c_validate_pl_curr_no_multi;
     END IF;
END  Validate_Price_list_Curr_code;

/***********************************************************************
   Procedure to get all the currency code(s) for a given price list
***********************************************************************/
PROCEDURE Get_Currency
(
    l_price_list_id		IN NUMBER
   ,l_pricing_effective_date    IN DATE
   ,l_currency_code_tbl        OUT NOCOPY CURRENCY_CODE_TBL
)
IS

l_temp_date    DATE;
-- Cursor to get currency code list without multi-currency installed
CURSOR c_currency_no_multi
IS

SELECT currency_code
      ,name		currency_name
      ,PRECISION	currency_precision
FROM   fnd_currencies_vl
WHERE  currency_flag = 'Y'
AND    enabled_flag = 'Y'
AND    TRUNC(NVL(start_date_active, SYSDATE)) <= TRUNC(SYSDATE)
AND    TRUNC(NVL(end_date_active, SYSDATE)) >= TRUNC(SYSDATE)
ORDER BY currency_code;

-- Cursor to get currency code list with multi-currency installed
CURSOR c_currency_multi
IS

SELECT DISTINCT a.currency_code         currency_code
      ,a.name		       currency_name
      ,a.PRECISION             currency_precision
FROM   fnd_currencies_vl   a
      ,qp_currency_details b
      ,qp_list_headers_b   c
WHERE  c.list_header_id = l_price_list_id
AND    b.currency_header_id = c.currency_header_id
AND    a.currency_code = b.to_currency_code
AND    c.list_type_code IN ('PRL', 'AGR')
AND    a.currency_flag = 'Y'
AND    a.enabled_flag = 'Y'
AND    TRUNC(l_temp_date) >= TRUNC(NVL(b.start_date_active, l_temp_date))
AND    TRUNC(l_temp_date) <= TRUNC(NVL(b.end_date_active, l_temp_date))
AND    TRUNC(l_temp_date) >= TRUNC(NVL(c.start_date_active, l_temp_date))
AND    TRUNC(l_temp_date) <= TRUNC(NVL(c.end_date_active, l_temp_date))
ORDER BY a.currency_code;

l_currency_no_multi        c_currency_no_multi%ROWTYPE;
l_currency_multi      	   c_currency_multi%ROWTYPE;

l_currency_header_id     NUMBER;
l_counter		 NUMBER;


BEGIN

   IF l_pricing_effective_date IS NULL THEN
      l_temp_date := SYSDATE;
   ELSE
      l_temp_date := l_pricing_effective_date;
   END IF;


  -- Added new profile (QP_MULTI_CURRENCY_USAGE) with default value 'Y' to maintain current behaviour,
  -- bug 2943033
   IF  UPPER(Fnd_Profile.value('QP_MULTI_CURRENCY_INSTALLED'))  IN ('Y', 'YES')
       AND (NVL(Fnd_Profile.value('QP_MULTI_CURRENCY_USAGE'), 'Y') = 'Y')
       AND l_price_list_id IS NOT NULL 		THEN

       -- Multi Currency is installed on and calling prog pass a price list
         l_counter := 1;

         OPEN  c_currency_multi;
         LOOP

           FETCH c_currency_multi INTO l_currency_multi;
           EXIT WHEN c_currency_multi%NOTFOUND;

             l_currency_code_tbl(l_counter).currency_code := l_currency_multi.currency_code;
             l_currency_code_tbl(l_counter).currency_name := l_currency_multi.currency_name;
             l_currency_code_tbl(l_counter).currency_precision :=l_currency_multi.currency_precision;

             l_counter := l_counter + 1;

         END LOOP;

         CLOSE c_currency_multi;


   ELSE

       -- Multi Currency is not installed or Multi Currency is installed but calling prog pass no price list
         l_counter := 1;

         OPEN c_currency_no_multi;
         LOOP

           FETCH c_currency_no_multi INTO l_currency_no_multi;
           EXIT WHEN c_currency_no_multi%NOTFOUND;

             l_currency_code_tbl(l_counter).currency_code := l_currency_no_multi.currency_code;
             l_currency_code_tbl(l_counter).currency_name := l_currency_no_multi.currency_name;
             l_currency_code_tbl(l_counter).currency_precision :=l_currency_no_multi.currency_precision;

             l_counter := l_counter + 1;

         END LOOP;

         CLOSE c_currency_no_multi;

   END IF;


EXCEPTION

   WHEN OTHERS THEN

     IF Fnd_Msg_Pub.Check_Msg_Level(Fnd_Msg_Pub.G_MSG_LVL_ERROR) THEN
        Fnd_Message.SET_NAME('QP', 'QP_ERROR_GET_CURR_F_PRICELIST');
     END IF;

     IF c_currency_multi%ISOPEN THEN
       CLOSE c_currency_multi;
     END IF;

     IF c_currency_no_multi%ISOPEN THEN
       CLOSE c_currency_no_multi;
     END IF;

END Get_Currency;

/***********************************************************************
    Procedure to get price list(s) for a given currency code
  Bug 3018412 - added the condition to select the data for all source systems belonging to a pte_code
***********************************************************************/
PROCEDURE Get_Price_List
(
    l_currency_code 		IN VARCHAR2
   ,l_pricing_effective_date    IN DATE
   ,l_agreement_id              IN NUMBER
   ,l_blanket_reference_id      IN VARCHAR2 DEFAULT NULL
   ,l_price_list_tbl           OUT NOCOPY price_list_tbl
   ,l_sold_to_org_id            IN NUMBER DEFAULT NULL
)

IS

   l_temp_date                     DATE;
--passing null org_id to OE_Sys_Parameters for moac so that it will return CUSTOMER_RELATIONSHIPS_FLAG
--for the org_context set -- build_contexts API or calling app would have set 'single' org context
l_org_id NUMBER := Qp_Util.get_org_id;
l_cust_relation_flag VARCHAR2(30);
--OE_Sys_Parameters.VALUE('CUSTOMER_RELATIONSHIPS_FLAG', l_org_id);

CURSOR c_price_list_multi
IS

SELECT  DISTINCT qlhv.list_header_id      price_list_id
       ,qlhv.name	         name
       ,qlhv.description         description
       ,qlhv.start_date_active   start_date_active
       ,qlhv.end_date_active     end_date_active
FROM    qp_list_headers_vl   qlhv
       ,qp_currency_details  qdt
WHERE   qlhv.currency_header_id = qdt.currency_header_id
AND     qdt.to_currency_code = l_currency_code
AND     qlhv.active_flag = 'Y'
--added for MOAC
--commented out below 2 lines for MOAC as the ORG_ID check is built into the view qp_list_headers_vl
--AND     (((nvl(qlhv.global_flag,'Y') = 'Y' or qlhv.orig_org_id = fnd_profile.Value('ORG_ID')) and
--         qp_security.security_on = 'Y') or qp_security.security_on = 'N')
AND     qlhv.list_type_code = 'PRL'
-- If there is a blanket reference show all standard pricelist and
-- all shareable BSO PL's and all PL's attached to the referenced blanket.
-- Otherwise show only standard PL's.
AND     (
          (    l_blanket_reference_id IS NULL
           AND NVL(qlhv.list_source_code,' ') <> 'BSO'
          )
          OR
          ( l_blanket_reference_id IS NOT NULL
            AND
            (     (    NVL(qlhv.shareable_flag,'Y') = 'Y'
                  AND  NVL(qlhv.list_source_code,' ') = 'BSO'
                  )
             OR  NVL(qlhv.orig_system_header_ref,-9999) = l_blanket_reference_id
             OR  NVL(qlhv.list_source_code,' ') <> 'BSO'
            )
          )
        )   -- Blanket Pricing
--AND     NVL(to_date(:parameter.lov_char_param1), TRUNC(sysdate))
AND     l_temp_date
        BETWEEN
        NVL(TRUNC(qlhv.start_date_active), l_temp_date)  AND
        NVL(TRUNC(qlhv.end_date_active), l_temp_date)
--AND     NVL(to_date(:parameter.lov_char_param1), TRUNC(sysdate))
AND     l_temp_date
        BETWEEN
        NVL(TRUNC(qdt.start_date_active), l_temp_date)  AND
        NVL(TRUNC(qdt.end_date_active), l_temp_date)
--AND     :parameter.lov_num_param1 IS NULL
AND     l_agreement_id IS NULL
--AND     qdt.to_currency_code = NVL(:order.transactional_curr_code, qdt.to_currency_code)
--AND     qdt.to_currency_code = NVL(l_order_transac_curr_code, qdt.to_currency_code)
AND qlhv.source_system_code IN (SELECT qpss.application_short_name
                                  FROM qp_pte_source_systems qpss
                               WHERE qpss.pte_code = Fnd_Profile.value('QP_PRICING_TRANSACTION_ENTITY'))
UNION
SELECT  DISTINCT qlhv.list_header_id      price_list_id
       ,qlhv.name	         name
       ,qlhv.description         description
       ,qlhv.start_date_active   start_date_active
       ,qlhv.end_date_active     end_date_active
FROM    qp_list_headers_vl   qlhv
       ,oe_agreements        oa
       ,qp_currency_details  qdt
WHERE   (  (    oa.price_list_id = qlhv.list_header_id
            AND qlhv.list_type_code IN ('PRL', 'AGR')   )
        OR
            qlhv.list_type_code = 'PRL'
        )
AND     qlhv.active_flag = 'Y'
-- If there is a blanket reference show all standard pricelist and
-- all shareable BSO PL's and all PL's attached to the referenced blanket.
-- Otherwise show only standard PL's.
AND     (
          (    l_blanket_reference_id IS NULL
           AND NVL(qlhv.list_source_code,' ') <> 'BSO'
          )
          OR
          ( l_blanket_reference_id IS NOT NULL
            AND
            (     (    NVL(qlhv.shareable_flag,'Y') = 'Y'
                  AND  NVL(qlhv.list_source_code,' ') = 'BSO'
                  )
             OR  NVL(qlhv.orig_system_header_ref,-9999) = l_blanket_reference_id
             OR  NVL(qlhv.list_source_code,' ') <> 'BSO'
            )
          )
        )   -- Blanket Pricing
--added for MOAC
--commented out below 2 lines for MOAC as the ORG_ID check is built into the view qp_list_headers_vl
--AND     (((nvl(qlhv.global_flag,'Y') = 'Y' or qlhv.orig_org_id = fnd_profile.Value('ORG_ID')) and
--         qp_security.security_on = 'Y') or qp_security.security_on = 'N')
AND     qlhv.currency_header_id = qdt.currency_header_id
AND     qdt.to_currency_code = l_currency_code
--AND     NVL(to_date(:parameter.lov_char_param1), TRUNC(sysdate))
AND     l_temp_date
        BETWEEN
        NVL(TRUNC(qlhv.start_date_active), l_temp_date)  AND
        NVL(TRUNC(qlhv.end_date_active), l_temp_date)
--AND     NVL(to_date(:parameter.lov_char_param1), TRUNC(sysdate))
AND     l_temp_date
        BETWEEN
        NVL(TRUNC(qdt.start_date_active), l_temp_date)  AND
        NVL(TRUNC(qdt.end_date_active), l_temp_date)
--AND     :parameter.lov_num_param1 = oa.agreement_id
AND     l_agreement_id = oa.agreement_id
--AND     :parameter.lov_num_param1 IS NOT NULL
AND     l_agreement_id IS NOT NULL
--AND     qdt.to_currency_code = NVL(:order.transactional_curr_code, qdt.to_currency_code)
--AND     qdt.to_currency_code = NVL(l_order_transac_curr_code, qdt.to_currency_code)
AND     qdt.to_currency_code = NVL(l_currency_code, qdt.to_currency_code)
AND qlhv.source_system_code IN (SELECT qpss.application_short_name
                                  FROM qp_pte_source_systems qpss
                               WHERE qpss.pte_code = Fnd_Profile.value('QP_PRICING_TRANSACTION_ENTITY'))
UNION
SELECT  DISTINCT qlhv.list_header_id      price_list_id
       ,qlhv.name	         name
       ,qlhv.description         description
       ,qlhv.start_date_active   start_date_active
       ,qlhv.end_date_active     end_date_active
FROM    qp_list_headers_vl   qlhv
       ,oe_agreements        oa
       ,qp_currency_details  qdt
WHERE   (  (    oa.price_list_id = qlhv.list_header_id
            AND qlhv.list_type_code IN ('PRL', 'AGR')   )
        OR
            qlhv.list_type_code = 'PRL'
        )
AND     qlhv.active_flag = 'Y'
-- If there is a blanket reference show all standard pricelist and
-- all shareable BSO PL's and all PL's attached to the referenced blanket.
-- Otherwise show only standard PL's.
AND     (
          (    l_blanket_reference_id IS NULL
           AND NVL(qlhv.list_source_code,' ') <> 'BSO'
          )
          OR
          ( l_blanket_reference_id IS NOT NULL
            AND
            (     (    NVL(qlhv.shareable_flag,'Y') = 'Y'
                  AND  NVL(qlhv.list_source_code,' ') = 'BSO'
                  )
             OR  NVL(qlhv.orig_system_header_ref,-9999) = l_blanket_reference_id
             OR  NVL(qlhv.list_source_code,' ') <> 'BSO'
            )
          )
        )   -- Blanket Pricing
--added for MOAC
--commented out below 2 lines for MOAC as the ORG_ID check is built into the view qp_list_headers_vl
--AND     (((nvl(qlhv.global_flag,'Y') = 'Y' or qlhv.orig_org_id = fnd_profile.Value('ORG_ID')) and
--         qp_security.security_on = 'Y')  or qp_security.security_on = 'N')
AND     qlhv.currency_header_id = qdt.currency_header_id
AND     qdt.to_currency_code = l_currency_code
AND     l_temp_date
        BETWEEN
        NVL(TRUNC(qlhv.start_date_active), l_temp_date)  AND
        NVL(TRUNC(qlhv.end_date_active), l_temp_date)
AND     l_temp_date
        BETWEEN
        NVL(TRUNC(qdt.start_date_active), l_temp_date)  AND
        NVL(TRUNC(qdt.end_date_active), l_temp_date)
AND     l_agreement_id IS NULL
AND     qdt.to_currency_code = NVL(l_currency_code, qdt.to_currency_code)
AND     l_sold_to_org_id IS NOT NULL
AND( oa.sold_to_org_id = l_sold_to_org_id OR
	oa.sold_to_org_id IS NULL OR
	oa.sold_to_org_id = -1 OR
	oa.sold_to_org_id IN (
		SELECT r.cust_account_id FROM
        	hz_cust_acct_relate r
		WHERE r.related_cust_account_id = l_sold_to_org_id AND
		r.status = 'A' AND l_cust_relation_flag = 'Y'))
AND qlhv.source_system_code IN (SELECT qpss.application_short_name
                                  FROM qp_pte_source_systems qpss
                               WHERE qpss.pte_code = Fnd_Profile.value('QP_PRICING_TRANSACTION_ENTITY'))
ORDER BY name;


CURSOR c_price_list_no_multi
IS

SELECT  qlhv.list_header_id      price_list_id
       ,qlhv.name	         name
       ,qlhv.description         description
       ,qlhv.start_date_active   start_date_active
       ,qlhv.end_date_active     end_date_active
FROM    qp_list_headers_vl   qlhv
WHERE   list_type_code  = 'PRL'
AND     qlhv.active_flag = 'Y'
--added for MOAC
--commented out below 2 lines for MOAC as the ORG_ID check is built into the view qp_list_headers_vl
--AND     (((nvl(qlhv.global_flag,'Y') = 'Y' or qlhv.orig_org_id = fnd_profile.Value('ORG_ID')) and
--        qp_security.security_on = 'Y')  or qp_security.security_on = 'N')
--AND     NVL(to_date(:parameter.lov_char_param1), TRUNC(sysdate))
-- If there is a blanket reference show all standard pricelist and
-- all shareable BSO PL's and all PL's attached to the referenced blanket.
-- Otherwise show only standard PL's.
AND     (
          (    l_blanket_reference_id IS NULL
           AND NVL(qlhv.list_source_code,' ') <> 'BSO'
          )
          OR
          ( l_blanket_reference_id IS NOT NULL
            AND
            (     (    NVL(qlhv.shareable_flag,'Y') = 'Y'
                  AND  NVL(qlhv.list_source_code,' ') = 'BSO'
                  )
             OR  NVL(qlhv.orig_system_header_ref,-9999) = l_blanket_reference_id
             OR  NVL(qlhv.list_source_code,' ') <> 'BSO'
            )
          )
        )   -- Blanket Pricing
AND     l_temp_date
        BETWEEN
        NVL(TRUNC(start_date_active), l_temp_date)  AND
        NVL(TRUNC(end_date_active), l_temp_date)
--AND     :parameter.lov_num_param1 IS NULL
AND     l_agreement_id IS NULL
--AND     currency_code = NVL(l_order_transac_curr_code, currency_code)
AND    currency_code = NVL(l_currency_code, currency_code)
AND qlhv.source_system_code IN (SELECT qpss.application_short_name
                                  FROM qp_pte_source_systems qpss
                               WHERE qpss.pte_code = Fnd_Profile.value('QP_PRICING_TRANSACTION_ENTITY'))
UNION
SELECT
        qlhv.list_header_id       price_list_id
       ,qlhv.name                 name
       ,qlhv.description          description
       ,qlhv.start_date_active    start_date_active
       ,qlhv.end_date_active      end_date_active
FROM
        qp_list_headers_vl  qlhv
       ,oe_agreements       oa
WHERE   (  (oa.price_list_id = qlhv.list_header_id   AND
            qlhv.list_type_code IN ('PRL', 'AGR'))
        OR
            qlhv.list_type_code = 'PRL'
        )
--AND     NVL(to_date(:parameter.lov_char_param1), TRUNC(sysdate)) BETWEEN
-- If there is a blanket reference show all standard pricelist and
-- all shareable BSO PL's and all PL's attached to the referenced blanket.
-- Otherwise show only standard PL's.
AND     (
          (    l_blanket_reference_id IS NULL
           AND NVL(qlhv.list_source_code,' ') <> 'BSO'
          )
          OR
          ( l_blanket_reference_id IS NOT NULL
            AND
            (     (    NVL(qlhv.shareable_flag,'Y') = 'Y'
                  AND  NVL(qlhv.list_source_code,' ') = 'BSO'
                  )
             OR  NVL(qlhv.orig_system_header_ref,-9999) = l_blanket_reference_id
             OR  NVL(qlhv.list_source_code,' ') <> 'BSO'
            )
          )
        )   -- Blanket Pricing
--added for MOAC
--commented out below 2 lines for MOAC as the ORG_ID check is built into the view qp_list_headers_vl
--AND     (((nvl(qlhv.global_flag,'Y') = 'Y' or qlhv.orig_org_id = fnd_profile.Value('ORG_ID')) and
--         qp_security.security_on = 'Y')  or qp_security.security_on = 'N')
AND     l_temp_date
        BETWEEN
        NVL(TRUNC(qlhv.start_date_active),  l_temp_date)   AND
        NVL(TRUNC(qlhv.end_date_active),  l_temp_date)
--AND     :parameter.lov_num_param1 = oa.agreement_id
AND     l_agreement_id = oa.agreement_id
--AND     :parameter.lov_num_param1 IS NOT NULL
AND     l_agreement_id IS NOT NULL
--AND     currency_code = NVL(l_order_transac_curr_code, currency_code)
AND     currency_code = NVL(l_currency_code, currency_code)
AND qlhv.source_system_code IN (SELECT qpss.application_short_name
                                  FROM qp_pte_source_systems qpss
                               WHERE qpss.pte_code = Fnd_Profile.value('QP_PRICING_TRANSACTION_ENTITY'))
UNION
SELECT
        qlhv.list_header_id       price_list_id
       ,qlhv.name                 name
       ,qlhv.description          description
       ,qlhv.start_date_active    start_date_active
       ,qlhv.end_date_active      end_date_active
FROM
        qp_list_headers_vl  qlhv
       ,oe_agreements       oa
WHERE   (  (oa.price_list_id = qlhv.list_header_id   AND
            qlhv.list_type_code IN ('PRL', 'AGR'))
        OR
            qlhv.list_type_code = 'PRL'
        )
-- If there is a blanket reference show all standard pricelist and
-- all shareable BSO PL's and all PL's attached to the referenced blanket.
-- Otherwise show only standard PL's.
AND     (
          (    l_blanket_reference_id IS NULL
           AND NVL(qlhv.list_source_code,' ') <> 'BSO'
          )
          OR
          ( l_blanket_reference_id IS NOT NULL
            AND
            (     (    NVL(qlhv.shareable_flag,'Y') = 'Y'
                  AND  NVL(qlhv.list_source_code,' ') = 'BSO'
                  )
             OR  NVL(qlhv.orig_system_header_ref,-9999) = l_blanket_reference_id
             OR  NVL(qlhv.list_source_code,' ') <> 'BSO'
            )
          )
        )   -- Blanket Pricing
--added for MOAC
--commented out below 2 lines for MOAC as the ORG_ID check is built into the view qp_list_headers_vl
--AND     (((nvl(qlhv.global_flag,'Y') = 'Y' or qlhv.orig_org_id = fnd_profile.Value('ORG_ID')) and
--         qp_security.security_on = 'Y') or qp_security.security_on = 'N')
AND     l_temp_date
        BETWEEN
        NVL(TRUNC(qlhv.start_date_active),  l_temp_date)   AND
        NVL(TRUNC(qlhv.end_date_active),  l_temp_date)
AND     l_agreement_id IS NULL
AND     currency_code = NVL(l_currency_code, currency_code)
AND     l_sold_to_org_id IS NOT NULL
AND( oa.sold_to_org_id = l_sold_to_org_id OR
	oa.sold_to_org_id IS NULL OR
	oa.sold_to_org_id = -1 OR
	oa.sold_to_org_id IN (
		SELECT r.cust_account_id FROM
		hz_cust_acct_relate r
		WHERE r.related_cust_account_id = l_sold_to_org_id AND
		r.status = 'A' AND l_cust_relation_flag = 'Y'))
AND qlhv.source_system_code IN (SELECT qpss.application_short_name
                                  FROM qp_pte_source_systems qpss
                               WHERE qpss.pte_code = Fnd_Profile.value('QP_PRICING_TRANSACTION_ENTITY'))
ORDER BY name;

l_price_list_multi	c_price_list_multi%ROWTYPE;
l_price_list_no_multi   c_price_list_no_multi%ROWTYPE;
l_counter		NUMBER;


BEGIN
--added for moac to call oe_sys_params with a valid org_id
  IF l_org_id IS NOT NULL THEN
    l_cust_relation_flag  := Oe_Sys_Parameters.VALUE('CUSTOMER_RELATIONSHIPS_FLAG',l_org_id);
  ELSE
    l_cust_relation_flag := '';
  END IF;
    l_debug := Qp_Preq_Grp.G_DEBUG_ENGINE;
    IF l_debug = Fnd_Api.G_TRUE THEN
    Oe_Debug_Pub.ADD('QP_UTIL_PUB.Get_Price_List BEGIN ');
    Oe_Debug_Pub.ADD('l_currency_code = ' || l_currency_code);
    Oe_Debug_Pub.ADD('l_pricing_effective_date = ' ||l_pricing_effective_date);
    Oe_Debug_Pub.ADD('l_agreement_id = ' || l_agreement_id);

    END IF;
   IF l_pricing_effective_date IS NULL THEN
      l_temp_date  := TRUNC(SYSDATE);
   ELSE
      l_temp_date  := TRUNC(l_pricing_effective_date);
   END IF;

  -- Added new profile (QP_MULTI_CURRENCY_USAGE) with default value 'Y' to maintain current behaviour,
  -- bug 2943033
   IF  UPPER(Fnd_Profile.value('QP_MULTI_CURRENCY_INSTALLED'))  IN ('Y', 'YES')
       AND (NVL(Fnd_Profile.value('QP_MULTI_CURRENCY_USAGE'), 'Y') = 'Y')
       AND l_currency_code IS NOT NULL 		THEN

       -- Multi Currency is installed on and calling prog pass a currency_code
         l_counter := 1;

         OPEN  c_price_list_multi;
         LOOP

           FETCH c_price_list_multi INTO l_price_list_multi;
           EXIT WHEN c_price_list_multi%NOTFOUND;

             l_price_list_tbl(l_counter).price_list_id  := l_price_list_multi.price_list_id;
--dbms_output.put_line('price_list_id: '|| l_price_list_tbl(l_counter).price_list_id);
             l_price_list_tbl(l_counter).name := l_price_list_multi.name;
--dbms_output.put_line('name: '|| l_price_list_tbl(l_counter).name);
             l_price_list_tbl(l_counter).description := l_price_list_multi.description;
--dbms_output.put_line('description: ' ||l_price_list_tbl(l_counter).description);
             l_price_list_tbl(l_counter).start_date_active := l_price_list_multi.start_date_active;
--dbms_output.put_line('start_date_active: '|| l_price_list_tbl(l_counter).start_date_active);
             l_price_list_tbl(l_counter).end_date_active := l_price_list_multi.start_date_active;
--dbms_output.put_line('end_date_active: '|| l_price_list_tbl(l_counter).end_date_active);
             l_counter := l_counter + 1;

         END LOOP;

         CLOSE c_price_list_multi;

   ELSE

       -- Multi Currency is not installed or Multi Currency is installed but calling prog pass no currency_code
         l_counter := 1;

         OPEN c_price_list_no_multi;
         LOOP

           FETCH c_price_list_no_multi INTO l_price_list_no_multi;
           EXIT WHEN c_price_list_no_multi%NOTFOUND;

             l_price_list_tbl(l_counter).price_list_id  := l_price_list_no_multi.price_list_id;
             l_price_list_tbl(l_counter).name := l_price_list_no_multi.name;
             l_price_list_tbl(l_counter).description := l_price_list_no_multi.description;
             l_price_list_tbl(l_counter).start_date_active := l_price_list_no_multi.start_date_active;
             l_price_list_tbl(l_counter).end_date_active := l_price_list_no_multi.start_date_active;

             l_counter := l_counter + 1;

         END LOOP;

         CLOSE c_price_list_no_multi;

   END IF;


EXCEPTION
   WHEN OTHERS THEN

     IF Fnd_Msg_Pub.Check_Msg_Level(Fnd_Msg_Pub.G_MSG_LVL_ERROR) THEN
        Fnd_Message.SET_NAME('QP', 'QP_ERROR_GET_PRICELIST_F_CURR');
     END IF;

     IF c_price_list_multi%ISOPEN THEN
       CLOSE c_price_list_multi;
     END IF;

     IF c_price_list_no_multi%ISOPEN THEN
       CLOSE c_price_list_no_multi;
     END IF;

END Get_Price_list;

/*
  Bug 3018412 - added the condition to select the data for all source systems belonging to a pte_code
*/
PROCEDURE Get_Price_Lists
(
    p_currency_code             IN VARCHAR2 DEFAULT NULL
   ,p_price_lists_tbl           OUT NOCOPY price_lists_tbl
)
IS

l_temp_date             DATE;
l_counter               NUMBER;

CURSOR c_price_list_blkt
IS
SELECT list_header_id price_list_id,
       name name,
       description description,
       -rounding_factor rounding_factor,
       start_date_active start_date_active,
       end_date_active  end_date_active
FROM   qp_list_headers_vl
WHERE  list_type_code IN ('PRL' ,'AGR') AND
       NVL(active_flag,'N') ='Y'
--added for MOAC
--commented out below 2 lines for MOAC as the ORG_ID check is built into the view qp_list_headers_vl
--       (((nvl(global_flag,'Y') = 'Y' or orig_org_id = fnd_profile.Value('ORG_ID'))
--       and qp_security.security_on = 'Y') or  qp_security.security_on = 'N')
AND source_system_code IN (SELECT qpss.application_short_name
                             FROM qp_pte_source_systems qpss
                          WHERE qpss.pte_code = Fnd_Profile.value('QP_PRICING_TRANSACTION_ENTITY'))
ORDER BY name;

CURSOR c_price_list_ttyp
IS
SELECT list_header_id price_list_id,
       name name,
       description description,
       -rounding_factor rounding_factor,
       start_date_active start_date_active,
       end_date_active  end_date_active
FROM   qp_list_headers_vl
WHERE  currency_code = p_currency_code
--added for MOAC
--commented out below 2 lines for MOAC as the ORG_ID check is built into the view qp_list_headers_vl
--       (((nvl(global_flag,'Y') = 'Y' or orig_org_id =  fnd_profile.Value('ORG_ID'))
--       and qp_security.security_on = 'Y') or  qp_security.security_on = 'N') and
AND    TRUNC(l_temp_date) BETWEEN NVL(TRUNC(start_date_active), TRUNC(l_temp_date)) AND
       NVL(TRUNC(end_date_active), TRUNC(l_temp_date)) AND
       list_type_code = 'PRL'
AND source_system_code IN (SELECT qpss.application_short_name
                             FROM qp_pte_source_systems qpss
                          WHERE qpss.pte_code = Fnd_Profile.value('QP_PRICING_TRANSACTION_ENTITY'))
ORDER BY name;

l_price_list_ttyp   c_price_list_ttyp%ROWTYPE;
l_price_list_blkt   c_price_list_blkt%ROWTYPE;

BEGIN

   l_debug := Qp_Preq_Grp.G_DEBUG_ENGINE;
   IF l_debug = Fnd_Api.G_TRUE THEN
      Oe_Debug_Pub.ADD('QP_UTIL_PUB.Get_Price_Lists BEGIN ');
      Oe_Debug_Pub.ADD('p_currency_code = ' || p_currency_code);
   END IF;

   l_temp_date  := TRUNC(SYSDATE);

   IF  p_currency_code IS NOT NULL THEN

       -- calling program passed currency_code
       l_counter := 1;

       OPEN  c_price_list_ttyp;
       LOOP

           FETCH c_price_list_ttyp INTO l_price_list_ttyp;
           EXIT WHEN c_price_list_ttyp%NOTFOUND;

           p_price_lists_tbl(l_counter).price_list_id  := l_price_list_ttyp.price_list_id;
           p_price_lists_tbl(l_counter).name := l_price_list_ttyp.name;
           p_price_lists_tbl(l_counter).description := l_price_list_ttyp.description;
           p_price_lists_tbl(l_counter).rounding_factor := l_price_list_ttyp.rounding_factor;
           p_price_lists_tbl(l_counter).start_date_active := l_price_list_ttyp.start_date_active;
           p_price_lists_tbl(l_counter).end_date_active := l_price_list_ttyp.start_date_active;

           l_counter := l_counter + 1;

       END LOOP;

       CLOSE c_price_list_ttyp;
   ELSE

       -- calling program did not pass currency_code
       l_counter := 1;

       OPEN  c_price_list_blkt;
       LOOP

           FETCH c_price_list_blkt INTO l_price_list_blkt;
           EXIT WHEN c_price_list_blkt%NOTFOUND;

           p_price_lists_tbl(l_counter).price_list_id  := l_price_list_blkt.price_list_id;
           p_price_lists_tbl(l_counter).name := l_price_list_blkt.name;
           p_price_lists_tbl(l_counter).description := l_price_list_blkt.description;
           p_price_lists_tbl(l_counter).rounding_factor := l_price_list_blkt.rounding_factor;
           p_price_lists_tbl(l_counter).start_date_active := l_price_list_blkt.start_date_active;
           p_price_lists_tbl(l_counter).end_date_active := l_price_list_blkt.start_date_active;

           l_counter := l_counter + 1;

       END LOOP;

       CLOSE c_price_list_blkt;

   END IF;


EXCEPTION
   WHEN OTHERS THEN

     IF Fnd_Msg_Pub.Check_Msg_Level(Fnd_Msg_Pub.G_MSG_LVL_ERROR) THEN
        Fnd_Message.SET_NAME('QP', 'QP_ERROR_GET_PRICING_OBJECT');
        Fnd_Message.SET_TOKEN('PRICING_OBJECT','Price Lists');
     END IF;

     IF c_price_list_blkt%ISOPEN THEN
       CLOSE c_price_list_blkt;
     END IF;

     IF c_price_list_ttyp%ISOPEN THEN
       CLOSE c_price_list_ttyp;
     END IF;

END Get_Price_Lists;

PROCEDURE Get_Agreement
(
    p_sold_to_org_id            IN NUMBER DEFAULT NULL
   ,p_transaction_type_id       IN NUMBER DEFAULT NULL
   ,p_pricing_effective_date    IN DATE
   ,p_agreement_tbl            OUT NOCOPY agreement_tbl
)
IS

l_temp_date            DATE;
--passing null org_id to OE_Sys_Parameters for moac so that it will return CUSTOMER_RELATIONSHIPS_FLAG
--for the org_context set -- build_contexts API or calling app would have set 'single' org context
l_cust_relation_flag   VARCHAR2(30) := Oe_Sys_Parameters.VALUE('CUSTOMER_RELATIONSHIPS_FLAG', NULL);

-- 4865226, SQL repositroy performance fix for shareable memory
CURSOR c_agreement
IS
SELECT SUBSTRB(a.agreement_name,1,300) agreement_name, a.agreement_id agreement_id,
       a.agreement_type, q.name price_list_name, p.party_name customer_name,
       t.name payment_term_name, a.start_date_active, a.end_date_active
FROM   oe_agreements_lov_v a, qp_list_headers_vl q,
       hz_parties p, hz_cust_accounts c, ra_terms_tl t,
--       qp_list_headers_b l,
       oe_transaction_types_all ot
WHERE a.sold_to_org_id IN (
                           SELECT TO_NUMBER(p_sold_to_org_id) FROM dual
                           UNION
                           SELECT -1 FROM dual
                           UNION
                           SELECT r.cust_account_id FROM hz_cust_acct_relate r
                           WHERE  r.related_cust_account_id = p_sold_to_org_id AND
                                  l_cust_relation_flag = 'Y' AND
                                  r.status  = 'A' ) AND
      l_temp_date BETWEEN
                  TRUNC(NVL(a.start_date_active, ADD_MONTHS(SYSDATE, -10000))) AND
                  TRUNC(NVL(a.end_date_active, ADD_MONTHS(SYSDATE, +10000))) AND
      a.price_list_id = q.list_header_id
--added for MOAC
--commented out below 2 lines for MOAC as the ORG_ID check is built into the view qp_list_headers_vl
--      (((nvl(q.global_flag,'Y') = 'Y' or q.orig_org_id = fnd_profile.Value('ORG_ID')) and
--      qp_security.security_on = 'Y') or qp_security.security_on = 'N') and
AND   a.price_list_id = q.list_header_id AND
--      q.language = userenv('LANG') and
      a.sold_to_org_id = c.cust_account_id(+) AND
      c.party_id = p.party_id(+) AND
      a.term_id = t.term_id(+) AND
      ot.transaction_type_id = p_transaction_type_id AND
      DECODE(ot.agreement_type_code,NULL,NVL(a.agreement_type, -9999),
             ot.agreement_type_code) =  NVL(a.agreement_type, -9999) AND
      t.LANGUAGE(+) = USERENV('LANG')
ORDER BY 1;

--bug7192230 Adding two new cursors

CURSOR c_agreement_no_org
IS
select substr(a.agreement_name,1,300) agreement_name, a.agreement_id agreement_id,
       a.agreement_type, q.name price_list_name, null customer_name,
       t.name payment_term_name, a.start_date_active, a.end_date_active
from   oe_agreements_lov_v a, qp_list_headers_vl q, ra_terms_tl t,
       oe_transaction_types_all ot
where l_temp_date between
                  trunc(nvl(a.start_date_active, add_months(sysdate, -10000))) and
                  trunc(nvl(a.end_date_active, add_months(sysdate, +10000))) and
      a.price_list_id = q.list_header_id and
      --(((nvl(l.global_flag,'Y') = 'Y' or l.orig_org_id = fnd_profile.Value('ORG_ID')) and
      --qp_security.security_on = 'Y') or qp_security.security_on = 'N') and
      --a.price_list_id = q.list_header_id and
      --q.language = userenv('LANG') and
      a.term_id = t.term_id(+) and
      ot.transaction_type_id = p_transaction_type_id and
      decode(ot.agreement_type_code,null,nvl(a.agreement_type, -9999),
             ot.agreement_type_code) =  nvl(a.agreement_type, -9999) and
      t.language(+) = userenv('LANG')
order by 1;

CURSOR c_agreement_no_trtype
IS
select substr(a.agreement_name,1,300) agreement_name, a.agreement_id agreement_id,
       a.agreement_type, q.name price_list_name, p.party_name customer_name,
       null payment_term_name, a.start_date_active, a.end_date_active
from   oe_agreements_lov_v a, qp_list_headers_vl q,
       hz_parties p, hz_cust_accounts c --, qp_list_headers_b l
where a.sold_to_org_id in (
                           select to_number(p_sold_to_org_id) from dual
                           union
                           select -1 from dual
                           union
                           select r.cust_account_id from hz_cust_acct_relate r
                           where  r.related_cust_account_id = p_sold_to_org_id and
                                  l_cust_relation_flag = 'Y' and
                                  r.status  = 'A' ) and
      l_temp_date between
                  trunc(nvl(a.start_date_active, add_months(sysdate, -10000))) and
                  trunc(nvl(a.end_date_active, add_months(sysdate, +10000))) and
      a.price_list_id = q.list_header_id and
      --(((nvl(l.global_flag,'Y') = 'Y' or l.orig_org_id = fnd_profile.Value('ORG_ID')) and
      --qp_security.security_on = 'Y') or qp_security.security_on = 'N') and
      --a.price_list_id = q.list_header_id and
      --q.language = userenv('LANG') and
      a.sold_to_org_id = c.cust_account_id(+) and
      c.party_id = p.party_id(+)
order by 1;

--bug7192230 Adding cursors end

--bug7192230 Updating name of the cursor from c_agreement_no_org to c_agreement_no_org_no_trtype

CURSOR c_agreement_no_org_no_trtype
IS
SELECT SUBSTRB(a.agreement_name,1,300) agreement_name, a.agreement_id agreement_id,
       a.agreement_type, q.name price_list_name, NULL customer_name,
       NULL payment_term_name, a.start_date_active, a.end_date_active
FROM   oe_agreements_lov_v a, qp_list_headers_vl q
--, qp_list_headers_b l
WHERE  l_temp_date BETWEEN
                  TRUNC(NVL(a.start_date_active, ADD_MONTHS(SYSDATE, -10000))) AND
                  TRUNC(NVL(a.end_date_active, ADD_MONTHS(SYSDATE, +10000))) AND
      a.price_list_id = q.list_header_id
--added for MOAC
--commented out below 2 lines for MOAC as the ORG_ID check is built into the view qp_list_headers_vl
--      (((nvl(q.global_flag,'Y') = 'Y' or q.orig_org_id = fnd_profile.Value('ORG_ID')) and
--      qp_security.security_on = 'Y') or qp_security.security_on = 'N') and
AND   a.price_list_id = q.list_header_id
--      q.language = userenv('LANG')
ORDER BY 1;

l_agreement   c_agreement%ROWTYPE;
l_counter     NUMBER := 0;

BEGIN
   Oe_Debug_Pub.ADD('QP_UTIL_PUB.Get_Agreement BEGIN ');
   Oe_Debug_Pub.ADD('p_pricing_effective_date = ' ||p_pricing_effective_date);

   IF p_pricing_effective_date IS NULL THEN
      l_temp_date  := TRUNC(SYSDATE);
   ELSE
      l_temp_date  := TRUNC(p_pricing_effective_date);
   END IF;

   IF  p_sold_to_org_id IS NOT NULL AND p_transaction_type_id IS NOT NULL THEN
       -- calling program passed sold_to_org_id and transaction_type_id

    Oe_Debug_Pub.ADD('p_sold_to_org_id = ' || p_sold_to_org_id);
    Oe_Debug_Pub.ADD('p_transaction_type_id = ' || p_transaction_type_id);


       OPEN c_agreement;
       LOOP

         FETCH c_agreement INTO l_agreement;
         EXIT WHEN c_agreement%NOTFOUND;

         l_counter := l_counter + 1;

         p_agreement_tbl(l_counter).agreement_name  := l_agreement.agreement_name;
         p_agreement_tbl(l_counter).agreement_id  := l_agreement.agreement_id;
         p_agreement_tbl(l_counter).agreement_type  := l_agreement.agreement_type;
         p_agreement_tbl(l_counter).price_list_name  := l_agreement.price_list_name;
         p_agreement_tbl(l_counter).customer_name  := l_agreement.customer_name;
         p_agreement_tbl(l_counter).payment_term_name  := l_agreement.payment_term_name;
         p_agreement_tbl(l_counter).start_date_active  := l_agreement.start_date_active;
         p_agreement_tbl(l_counter).end_date_active  := l_agreement.end_date_active;

       END LOOP;

       CLOSE c_agreement;

   ELSIF  p_sold_to_org_id IS NULL and p_transaction_type_id IS NOT NULL THEN -- added condition for bug7192230
       -- calling program did not pass sold_to_org_id and passed only transaction_type_id

       oe_debug_pub.add('p_sold_to_org_id = ' || p_sold_to_org_id);
       oe_debug_pub.add('p_transaction_type_id = ' || p_transaction_type_id);


       OPEN c_agreement_no_org;
       LOOP

         FETCH c_agreement_no_org INTO l_agreement;
         EXIT WHEN c_agreement_no_org%NOTFOUND;

         l_counter := l_counter + 1;

         p_agreement_tbl(l_counter).agreement_name  :=l_agreement.agreement_name;
         p_agreement_tbl(l_counter).agreement_id  := l_agreement.agreement_id;
         p_agreement_tbl(l_counter).agreement_type  :=l_agreement.agreement_type;
         p_agreement_tbl(l_counter).price_list_name  :=l_agreement.price_list_name;
         p_agreement_tbl(l_counter).customer_name  := l_agreement.customer_name;
         p_agreement_tbl(l_counter).payment_term_name  :=l_agreement.payment_term_name;
         p_agreement_tbl(l_counter).start_date_active  :=l_agreement.start_date_active;
         p_agreement_tbl(l_counter).end_date_active  :=l_agreement.end_date_active;

       END LOOP;

       CLOSE c_agreement_no_org;

    ELSIF  p_sold_to_org_id IS NOT NULL and p_transaction_type_id IS NULL THEN -- added condition for bug7192230
       -- calling program passed sold_to_org_id and did not pass transaction_type_id

       oe_debug_pub.add('p_sold_to_org_id = ' || p_sold_to_org_id);
       oe_debug_pub.add('p_transaction_type_id = ' || p_transaction_type_id);


       OPEN c_agreement_no_trtype;
       LOOP

         FETCH c_agreement_no_trtype INTO l_agreement;
         EXIT WHEN c_agreement_no_trtype%NOTFOUND;

         l_counter := l_counter + 1;

         p_agreement_tbl(l_counter).agreement_name  :=l_agreement.agreement_name;
         p_agreement_tbl(l_counter).agreement_id  := l_agreement.agreement_id;
         p_agreement_tbl(l_counter).agreement_type  :=l_agreement.agreement_type;
         p_agreement_tbl(l_counter).price_list_name  :=l_agreement.price_list_name;
         p_agreement_tbl(l_counter).customer_name  := l_agreement.customer_name;
         p_agreement_tbl(l_counter).payment_term_name  :=l_agreement.payment_term_name;
         p_agreement_tbl(l_counter).start_date_active  :=l_agreement.start_date_active;
         p_agreement_tbl(l_counter).end_date_active  :=l_agreement.end_date_active;

       END LOOP;

       CLOSE c_agreement_no_trtype;

   ELSE
       -- calling program did not pass sold_to_org_id and transaction_type_id

       OPEN c_agreement_no_org_no_trtype; -- bug7192230
       LOOP

         FETCH c_agreement_no_org_no_trtype INTO l_agreement;  -- bug7192230
         EXIT WHEN c_agreement_no_org_no_trtype%NOTFOUND; -- bug7192230

         l_counter := l_counter + 1;

         p_agreement_tbl(l_counter).agreement_name  := l_agreement.agreement_name;
         p_agreement_tbl(l_counter).agreement_id  := l_agreement.agreement_id;
         p_agreement_tbl(l_counter).agreement_type  := l_agreement.agreement_type;
         p_agreement_tbl(l_counter).price_list_name  := l_agreement.price_list_name;
         p_agreement_tbl(l_counter).customer_name  := l_agreement.customer_name;
         p_agreement_tbl(l_counter).payment_term_name  := l_agreement.payment_term_name;
         p_agreement_tbl(l_counter).start_date_active  := l_agreement.start_date_active;
         p_agreement_tbl(l_counter).end_date_active  := l_agreement.end_date_active;

       END LOOP;

       CLOSE c_agreement_no_org_no_trtype;  -- bug7192230
   END IF;

EXCEPTION
   WHEN OTHERS THEN

     IF Fnd_Msg_Pub.Check_Msg_Level(Fnd_Msg_Pub.G_MSG_LVL_ERROR) THEN
        Fnd_Message.SET_NAME('QP', 'QP_ERROR_GET_PRICING_OBJECT');
        Fnd_Message.SET_TOKEN('PRICING_OBJECT','Agreements');
     END IF;

     IF c_agreement%ISOPEN THEN
       CLOSE c_agreement;
     END IF;

     IF c_agreement_no_org%ISOPEN THEN
       CLOSE c_agreement_no_org;
     END IF;

     IF c_agreement_no_org_no_trtype%ISOPEN THEN -- added conditions for bug7192230
       CLOSE c_agreement_no_org_no_trtype;
     END IF;

     IF c_agreement_no_trtype%ISOPEN THEN -- added conditions for bug7192230
       CLOSE c_agreement_no_trtype;
     END IF;
END Get_Agreement;


/***********************************************************************
  called by pricing engine
***********************************************************************/
FUNCTION get_rounding_factor
(
    p_use_multi_currency       IN VARCHAR2
    ,p_price_list_id            IN NUMBER
    ,p_currency_code            IN VARCHAR2
    ,p_pricing_effective_date   IN DATE
) RETURN NUMBER
IS
  l_rounding_factor    NUMBER;
  l_status_code        VARCHAR2(1);
BEGIN
  l_debug := Qp_Preq_Grp.G_DEBUG_ENGINE;
  IF l_debug = Fnd_Api.G_TRUE THEN
  Oe_Debug_Pub.ADD('BEGIN qp_util_pub.get_rounding_factor');
  Oe_Debug_Pub.ADD('p_use_multi_currency = ' || p_use_multi_currency);
  Oe_Debug_Pub.ADD('p_price_list_id = ' || p_price_list_id);
  Oe_Debug_Pub.ADD('p_currency_code = ' || p_currency_code);
  Oe_Debug_Pub.ADD('p_pricing_effective_date = ' || p_pricing_effective_date);

  END IF;
  round_price(p_operand               => NULL
             ,p_rounding_factor       => NULL
             ,p_use_multi_currency    => p_use_multi_currency
             ,p_price_list_id         => p_price_list_id
             ,p_currency_code         => p_currency_code
             ,p_pricing_effective_date  => p_pricing_effective_date
             ,x_rounded_operand       => l_rounding_factor
             ,x_status_code           => l_status_code
             ,p_operand_type          => 'R'
             );

  IF l_status_code = Fnd_Api.G_RET_STS_UNEXP_ERROR THEN
          RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
  END IF;
  IF l_debug = Fnd_Api.G_TRUE THEN
  Oe_Debug_Pub.ADD('l_rounding_factor = ' || l_rounding_factor);
  Oe_Debug_Pub.ADD('l_status_code = ' || l_status_code);
  Oe_Debug_Pub.ADD('END qp_util_pub.get_rounding_factor');

  END IF;
  RETURN(l_rounding_factor);

END get_rounding_factor;

/***********************************************************************
    Procedure to Get Rounded Value
***********************************************************************/
  -- round_price.p_operand_type could be 'A' for adjustment amount or 'S' for item price
  -- or 'R' when called from get_rounding_factor
  -- when p_operand_type get the value 'R' then x_rounded_operand returns rounding factor
PROCEDURE round_price
                      (p_operand                IN    NUMBER
                      ,p_rounding_factor        IN    NUMBER
                      ,p_use_multi_currency     IN    VARCHAR2
                      ,p_price_list_id          IN    NUMBER
                      ,p_currency_code          IN    VARCHAR2
                      ,p_pricing_effective_date IN    DATE
                      ,x_rounded_operand        IN OUT NOCOPY   NUMBER
                      ,x_status_code            IN OUT NOCOPY   VARCHAR2
                      ,p_operand_type           IN VARCHAR2 DEFAULT 'S'
                     )
IS

  l_multi_currency_installed   VARCHAR2(1);
  l_use_multi_currency   VARCHAR2(1);
  l_rounding_factor            NUMBER;
  l_pricing_effective_date     DATE;
  l_rounding_options           VARCHAR2(30);
  l_oe_unit_price_rounding     VARCHAR2(30);

BEGIN
  l_debug := Qp_Preq_Grp.G_DEBUG_ENGINE;
  IF l_debug = Fnd_Api.G_TRUE THEN
  Oe_Debug_Pub.ADD('BEGIN round_price');
  Oe_Debug_Pub.ADD('p_operand = ' || p_operand);
  Oe_Debug_Pub.ADD('p_rounding_factor = ' || p_rounding_factor);
  Oe_Debug_Pub.ADD('p_use_multi_currency = ' || p_use_multi_currency);
  Oe_Debug_Pub.ADD('p_price_list_id = ' || p_price_list_id);
  Oe_Debug_Pub.ADD('p_currency_code = ' || p_currency_code);
  Oe_Debug_Pub.ADD('p_pricing_effective_date = ' || p_pricing_effective_date);
  Oe_Debug_Pub.ADD('p_operand_type = ' || p_operand_type);

  END IF;
  IF p_operand_type <> 'R' AND p_operand IS NULL THEN
     IF Oe_Msg_Pub.Check_Msg_Level(Oe_Msg_Pub.G_MSG_LVL_ERROR) THEN
            Fnd_Message.SET_NAME('QP','QP_ATTRIBUTE_REQUIRED');
            Fnd_Message.SET_TOKEN('ATTRIBUTE','Operand');
            Oe_Msg_Pub.ADD;
     END IF;
    RAISE Fnd_Api.G_EXC_ERROR;
  END IF;

  IF p_operand_type <> 'R' AND G_ROUNDING_OPTIONS IS NULL THEN
     G_ROUNDING_OPTIONS := NVL(Fnd_Profile.Value('QP_SELLING_PRICE_ROUNDING_OPTIONS'), 'NO_ROUND');
  END IF;

  l_rounding_options := G_ROUNDING_OPTIONS;

  IF l_debug = Fnd_Api.G_TRUE THEN
  Oe_Debug_Pub.ADD('Profile : rounding options = ' || l_rounding_options);

  END IF;
  -- check the Om profile for backward compatibility
  -- in scenario like this file is shipped to customer but the corresponding OM change is not shipped
  -- The OM change is to delete this OM profile and reply totally on QP_SELLING_PRICE_ROUNDING_OPTIONS
  IF p_operand_type <> 'R' AND G_OE_UNIT_PRICE_ROUNDING IS NULL THEN
     G_OE_UNIT_PRICE_ROUNDING := NVL(Fnd_Profile.Value('OE_UNIT_PRICE_ROUNDING'), 'N');
  END IF;

  l_oe_unit_price_rounding := G_OE_UNIT_PRICE_ROUNDING;

  IF l_debug = Fnd_Api.G_TRUE THEN
  Oe_Debug_Pub.ADD('Profile : OE unit price rounding = ' || l_oe_unit_price_rounding);

  END IF;
  IF ( (p_operand_type = 'A' AND l_rounding_options = 'ROUND_ADJ')
         OR
       ((p_operand_type = 'S') AND (l_rounding_options = 'ROUND_ADJ' OR
                                    l_rounding_options = 'NO_ROUND_ADJ')
       )
         OR
       (p_operand_type = 'R')
         OR
       (l_oe_unit_price_rounding = 'Y')
     ) THEN
         IF l_debug = Fnd_Api.G_TRUE THEN
         Oe_Debug_Pub.ADD('Do rounding ');
         END IF;
         --dbms_output.put_line('Do rounding ');

  IF p_rounding_factor IS NOT NULL THEN
     l_rounding_factor := p_rounding_factor;
  END IF;

  IF p_pricing_effective_date IS NULL THEN
     l_pricing_effective_date := TRUNC(SYSDATE);
  ELSE
     l_pricing_effective_date := p_pricing_effective_date;
  END IF;

  IF p_price_list_id IS NOT NULL AND
     p_currency_code IS NOT NULL AND
     l_pricing_effective_date IS NOT NULL THEN
        -- it means called by OM

        IF G_MULTI_CURRENCY IS NULL THEN
           Fnd_Profile.get('QP_MULTI_CURRENCY_INSTALLED', l_multi_currency_installed);
           l_multi_currency_installed := NVL(l_multi_currency_installed, 'N');
           G_MULTI_CURRENCY := l_multi_currency_installed;
        END IF;

        l_multi_currency_installed := G_MULTI_CURRENCY;
        IF l_debug = Fnd_Api.G_TRUE THEN
        Oe_Debug_Pub.ADD('l_multi_currency_installed = ' || l_multi_currency_installed);

        END IF;

        IF p_use_multi_currency = 'Y' THEN
          l_use_multi_currency := p_use_multi_currency;
        ELSE
          IF G_MULTI_CURRENCY_USAGE IS NULL THEN
             -- Added new profile (QP_MULTI_CURRENCY_USAGE) with default value 'N' to maintain
             -- current behaviour,bug 2943033
             G_MULTI_CURRENCY_USAGE := NVL(Fnd_Profile.value('QP_MULTI_CURRENCY_USAGE'), 'N');
          END IF;
          l_use_multi_currency := G_MULTI_CURRENCY_USAGE;
        END IF;

        IF l_debug = Fnd_Api.G_TRUE THEN
           Oe_Debug_Pub.ADD('l_use_multi_currency = ' || l_use_multi_currency);
        END IF;

        IF l_multi_currency_installed = 'Y' AND l_use_multi_currency = 'Y' THEN
           -- using rownum < 2 because there could be more than 1 effective records for a
           -- to_currency_code but note that selling_rounding_factor will be same

             IF l_debug = Fnd_Api.G_TRUE THEN
             Oe_Debug_Pub.ADD('round_price - multi-currency installed');

             END IF;
             -- cache the rounding_factor for price list id, currency and date
           IF p_price_list_id = G_PRICE_LIST_ID AND
              p_currency_code = G_CURRENCY_CODE AND
              l_pricing_effective_date = G_PRICING_EFF_DATE THEN

                 IF l_debug = Fnd_Api.G_TRUE THEN
                 Oe_Debug_Pub.ADD('round_price - getting rounding factor from cache');
                 END IF;
                 l_rounding_factor := G_ROUNDING_FACTOR;
           ELSE
                IF l_debug = Fnd_Api.G_TRUE THEN
                Oe_Debug_Pub.ADD('round_price - getting rounding factor from database');

                END IF;
                 SELECT qcdt.selling_rounding_factor
                   INTO l_rounding_factor
                   FROM qp_list_headers_b qb, qp_currency_details qcdt
                  WHERE qb.list_header_id = p_price_list_id
                    AND qcdt.currency_header_id = qb.currency_header_id
                    AND qcdt.to_currency_code = p_currency_code
                    AND l_pricing_effective_date BETWEEN
                        NVL(TRUNC(QCDT.START_DATE_ACTIVE),l_PRICING_EFFECTIVE_DATE)
                        AND NVL(TRUNC(QCDT.END_DATE_ACTIVE),l_PRICING_EFFECTIVE_DATE)
                    AND ROWNUM < 2;

                 G_PRICE_LIST_ID := p_price_list_id;
                 G_CURRENCY_CODE := p_currency_code;
                 G_PRICING_EFF_DATE := l_pricing_effective_date;
                 G_ROUNDING_FACTOR := l_rounding_factor;

           END IF;

        ELSE -- multi_currency not installed, not used

             IF l_debug = Fnd_Api.G_TRUE THEN
             Oe_Debug_Pub.ADD('round_price - multi-currency NOT installed');

             END IF;
             -- cache the rounding_factor for price list id
           IF p_price_list_id = G_PRICE_LIST_ID THEN
               IF l_debug = Fnd_Api.G_TRUE THEN
               Oe_Debug_Pub.ADD('round_price - getting rounding factor from cache');
               END IF;
               l_rounding_factor := G_ROUNDING_FACTOR;
           ELSE
              IF l_debug = Fnd_Api.G_TRUE THEN
              Oe_Debug_Pub.ADD('round_price - getting rounding factor from database');

              END IF;
              SELECT qb.rounding_factor
                INTO l_rounding_factor
                FROM qp_list_headers_b qb
               WHERE qb.list_header_id = p_price_list_id;
               /* for bug 2350218
                 and qb.currency_code = p_currency_code
                 and l_pricing_effective_date BETWEEN
                     NVL(TRUNC(QB.START_DATE_ACTIVE),l_PRICING_EFFECTIVE_DATE)
                     AND NVL(TRUNC(QB.END_DATE_ACTIVE),l_PRICING_EFFECTIVE_DATE);
               */

                 G_PRICE_LIST_ID := p_price_list_id;
                 G_ROUNDING_FACTOR := l_rounding_factor;
           END IF;

        END IF;

  END IF; --p_price_list_id, p_currency_code values not null

  IF l_debug = Fnd_Api.G_TRUE THEN
  Oe_Debug_Pub.ADD('l_rounding_factor = ' || l_rounding_factor);

  END IF;
  IF l_rounding_factor IS NOT NULL THEN
     IF p_operand_type = 'R' THEN
        x_rounded_operand := l_rounding_factor;
     ELSE
        x_rounded_operand := ROUND(p_operand, l_rounding_factor * -1);
     END IF;
  ELSE
     x_rounded_operand := p_operand;
  END IF;

  ELSE /* if p_operand_type = 'A' .......*/
     IF l_debug = Fnd_Api.G_TRUE THEN
     Oe_Debug_Pub.ADD('NO rounding');
     END IF;
     --dbms_output.put_line('NO rounding');
     x_rounded_operand := p_operand;
  END IF; /* p_operand_type */

  x_status_code := Fnd_Api.G_RET_STS_SUCCESS;

  IF l_debug = Fnd_Api.G_TRUE THEN
  Oe_Debug_Pub.ADD('x_rounded_operand = ' || x_rounded_operand);
  Oe_Debug_Pub.ADD('x_status_code = ' || x_status_code);
  Oe_Debug_Pub.ADD('END round_price');
  END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
      IF l_debug = Fnd_Api.G_TRUE THEN
      Oe_Debug_Pub.ADD('round_price - NO_DATA_FOUND exception');
      END IF;
      x_status_code := Fnd_Api.G_RET_STS_ERROR;
      IF Fnd_Msg_Pub.Check_Msg_Level(Fnd_Msg_Pub.G_MSG_LVL_ERROR) THEN
         Fnd_Message.SET_NAME('QP','QP_NO_RECORD_FOR_ROUNDING');
         Fnd_Message.SET_TOKEN('PRICE_LIST', p_price_list_id);
         Fnd_Message.SET_TOKEN('CURRENCY', p_currency_code);
      END IF;

    WHEN Fnd_Api.G_EXC_ERROR THEN

      IF l_debug = Fnd_Api.G_TRUE THEN
      Oe_Debug_Pub.ADD('round_price - EXPECTED exception');
      END IF;
      x_status_code := Fnd_Api.G_RET_STS_ERROR;

    WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
      IF l_debug = Fnd_Api.G_TRUE THEN
      Oe_Debug_Pub.ADD('round_price - UNEXPECTED exception');

      END IF;
      x_status_code := Fnd_Api.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN
      IF l_debug = Fnd_Api.G_TRUE THEN
      Oe_Debug_Pub.ADD('round_price - OTHERS exception');
      END IF;
      x_status_code := Fnd_Api.G_RET_STS_UNEXP_ERROR;

      IF Fnd_Msg_Pub.Check_Msg_Level(Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR)
      THEN
             Fnd_Msg_Pub.Add_Exc_Msg
                (G_PKG_NAME
                , 'Round Price'
                );
      END IF;

END round_price;


--to be used by OM-QP Integration to call new code path for QP.G
--if there are only basic modifiers in setup
FUNCTION Basic_Pricing_Setup RETURN VARCHAR2 IS
x_basic_pricing_setup VARCHAR2(1) := 'N';
BEGIN
        Fnd_Profile.Get('QP_BASIC_MODIFIERS_SETUP',x_basic_pricing_setup);
RETURN x_basic_pricing_setup;
END Basic_Pricing_Setup;

PROCEDURE Reprice_Debug_Engine_Request(
                                p_request_id IN NUMBER,
                                x_request_id OUT NOCOPY NUMBER,
                                x_return_status OUT NOCOPY VARCHAR2,
                                x_return_status_text OUT NOCOPY VARCHAR2)
IS
 p_line_tbl                  Qp_Preq_Grp.LINE_TBL_TYPE;
 p_qual_tbl                  Qp_Preq_Grp.QUAL_TBL_TYPE;
 p_line_attr_tbl             Qp_Preq_Grp.LINE_ATTR_TBL_TYPE;
 p_related_lines_tbl         Qp_Preq_Grp.RELATED_LINES_TBL_TYPE;

 p_line_detail_tbl           Qp_Preq_Grp.LINE_DETAIL_TBL_TYPE;
 p_line_detail_qual_tbl      Qp_Preq_Grp.LINE_DETAIL_QUAL_TBL_TYPE;
 p_line_detail_attr_tbl      Qp_Preq_Grp.LINE_DETAIL_ATTR_TBL_TYPE;

 p_control_rec               Qp_Preq_Grp.CONTROL_RECORD_TYPE;

 x_line_tbl                  Qp_Preq_Grp.LINE_TBL_TYPE;
 x_line_qual                 Qp_Preq_Grp.QUAL_TBL_TYPE;
 x_line_attr_tbl             Qp_Preq_Grp.LINE_ATTR_TBL_TYPE;
 x_line_detail_tbl           Qp_Preq_Grp.LINE_DETAIL_TBL_TYPE;
 x_line_detail_qual_tbl      Qp_Preq_Grp.LINE_DETAIL_QUAL_TBL_TYPE;
 x_line_detail_attr_tbl      Qp_Preq_Grp.LINE_DETAIL_ATTR_TBL_TYPE;
 x_related_lines_tbl         Qp_Preq_Grp.RELATED_LINES_TBL_TYPE;

 l_return_status VARCHAR2(240);
 l_return_status_text VARCHAR2(240);

 CURSOR cl_req_dbg IS
     SELECT *
     FROM   qp_debug_req
     WHERE  request_id = p_request_id;

 CURSOR cl_lines_dbg(p_req_id NUMBER) IS
     SELECT *
     FROM   qp_debug_req_lines
     WHERE  request_id = p_req_id;

 CURSOR cl_qual_dbg(p_req_id NUMBER) IS
     SELECT *
     FROM   qp_debug_req_line_attrs
     WHERE  request_id = p_req_id AND
             attribute_type = 'QUALIFIER' AND
	    line_detail_index IS NULL;

 CURSOR cl_line_attr_dbg(p_req_id NUMBER) IS
     SELECT *
     FROM   qp_debug_req_line_attrs
     WHERE  request_id = p_req_id AND
            attribute_type IN ('PRODUCT','PRICING') AND
	    line_detail_index IS NULL;

 CURSOR cl_ldets_dbg(p_req_id NUMBER) IS
     SELECT *
     FROM   qp_debug_req_ldets
     WHERE  request_id = p_req_id;


 CURSOR cl_rltd_dbg(p_req_id NUMBER) IS
     SELECT *
     FROM   qp_debug_req_rltd_lines
     WHERE  request_id = p_req_id AND
	    relationship_type_code = Qp_Preq_Grp.G_SERVICE_LINE;


 l_dbg_req_rec      qp_debug_req%ROWTYPE;

 --l_dbg_req_lines    qp_debug_req_lines%ROWTYPE;
 --l_dbg_req_ldets    qp_debug_req_ldets%ROWTYPE;
 --l_dbg_req_qual     qp_debug_req_line_attrs%ROWTYPE;
 --l_dbg_req_attr     qp_debug_req_line_attrs%ROWTYPE;
 --l_dbg_req_rltd     qp_debug_req_rltd_lines%ROWTYPE;

 I NUMBER;
BEGIN
    l_debug := Qp_Preq_Grp.G_DEBUG_ENGINE;
    IF l_debug = Fnd_Api.G_TRUE THEN
    Oe_Debug_Pub.ADD('QP_UTIL_PUB.Reprice_Debug_Engine_Request BEGIN');
    Oe_Debug_Pub.ADD('p_request_id = ' || p_request_id);
    END IF;
    --dbms_output.put_line('Reprice_Debug_Engine_Request Begins');

    /* profile settings */
    Fnd_Profile.PUT('QP_DEBUG','Y');
    x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
    x_return_status_text := 'Routine: QP_UTIL_PUB.Reprice_Debug_Engine_Request SUCCESS';

    IF ( p_request_id IS NULL) THEN
	x_return_status := Fnd_Api.G_RET_STS_ERROR;
	x_return_status_text := 'Need request_id for Reprice_Debug_Engine_Request API';
        RETURN;
    END IF;

    /* reconstruct p_contrl_rec */
    OPEN cl_req_dbg;
        FETCH cl_req_dbg INTO l_dbg_req_rec;
    CLOSE cl_req_dbg;

    IF (l_dbg_req_rec.request_id IS NULL) THEN
	x_return_status := Fnd_Api.G_RET_STS_ERROR;
	x_return_status_text := 'No debug record exists for request_id'||p_request_id;
        RETURN;
    END IF;

    p_control_rec.pricing_event := l_dbg_req_rec.pricing_event;
    p_control_rec.calculate_flag := l_dbg_req_rec.calculate_flag;
    p_control_rec.simulation_flag := l_dbg_req_rec.simulation_flag;
    p_control_rec.rounding_flag := l_dbg_req_rec.rounding_flag;
    p_control_rec.GSA_CHECK_FLAG:=l_dbg_req_rec.GSA_CHECK_FLAG;
    p_control_rec.GSA_DUP_CHECK_FLAG:= l_dbg_req_rec.GSA_DUP_CHECK_FLAG
;
    p_control_rec.temp_table_insert_flag := l_dbg_req_rec.temp_table_insert_flag;
    --p_control_rec.temp_table_insert_flag := 'Y';
    p_control_rec.manual_discount_flag := l_dbg_req_rec.manual_discount_flag;
    p_control_rec.debug_flag := l_dbg_req_rec.debug_flag;
    p_control_rec.source_order_amount_flag := l_dbg_req_rec.source_order_amount_flag;
    p_control_rec.public_api_call_flag := l_dbg_req_rec.public_api_call_flag;
    p_control_rec.manual_adjustments_call_flag:= l_dbg_req_rec.manual_adjustments_call_flag;
    p_control_rec.check_cust_view_flag := l_dbg_req_rec.check_cust_view_flag;
    p_control_rec.request_type_code:=l_dbg_req_rec.request_type_code;
    p_control_rec.view_code:=l_dbg_req_rec.view_code;
     --USE_MULTI_CURRENCY VARCHAR2(1) default 'N'; vivek
     --USER_CONVERSION_RATE NUMBER default NULL; vivek
     --USER_CONVERSION_TYPE VARCHAR2(30) default NULL; vivek
     --function_currency:= l_dbg_req_rec.currency_code;vivek
    p_control_rec.function_currency:= l_dbg_req_rec.currency_code;


    /* recontruct p_line_tbl */
    I := 0;
    FOR cl IN cl_lines_dbg(p_request_id)
    LOOP
        I:= I+1;
        --dbms_output.put_line('line index '||cl.line_Index||' cnt '|| I);

        p_line_tbl(I).request_type_code :=cl.request_type_code;
        --p_line_tbl(I).pricing_event :=cl.request_type_code;
        --p_line_tbl(I).header_id :=cl.price_list_header_id;
        p_line_tbl(I).line_Index :=cl.line_Index;
        p_line_tbl(I).line_id :=cl.line_id;
        p_line_tbl(I).line_type_code := cl.line_type_code;
        p_line_tbl(I).pricing_effective_date := cl.pricing_effective_date;
        p_line_tbl(I).active_date_first := cl.start_date_active_first;
        p_line_tbl(I).active_date_first_type := cl.active_date_first_type;
        p_line_tbl(I).active_date_second := cl.start_date_active_second;
        p_line_tbl(I).active_date_second_type :=cl.active_date_second_type;
        p_line_tbl(I).line_quantity := cl.line_quantity;
        p_line_tbl(I).line_uom_code := cl.line_uom_code;
        p_line_tbl(I).uom_quantity := cl.uom_quantity;
        p_line_tbl(I).priced_quantity := cl.priced_quantity;
        p_line_tbl(I).priced_uom_code := cl.priced_uom_code;
        p_line_tbl(I).currency_code := cl.currency_code;
	--dbms_output.put_line('currency '||p_line_tbl(I).currency_code);
        p_line_tbl(I).unit_price := cl.unit_price;
        p_line_tbl(I).percent_price := cl.percent_price;
        p_line_tbl(I).adjusted_unit_price := cl.adjusted_unit_price;
        p_line_tbl(I).updated_adjusted_unit_price := cl.updated_adjusted_unit_price;
        p_line_tbl(I).parent_price := cl.parent_price;
        p_line_tbl(I).parent_quantity := cl.parent_quantity;
        p_line_tbl(I).rounding_factor := cl.rounding_factor;
        p_line_tbl(I).parent_uom_code := cl.parent_uom_code;
        --p_line_tbl(I).price_phase_id := cl.price_flag;
        p_line_tbl(I).price_flag := cl.price_flag;
        p_line_tbl(I).processed_code := cl.processed_code;
        p_line_tbl(I).price_request_code := cl.price_request_code;
        p_line_tbl(I).hold_code := cl.hold_code;
        p_line_tbl(I).hold_text := cl.hold_text;
        p_line_tbl(I).status_code := cl.pricing_status_code;
        p_line_tbl(I).status_text := cl.pricing_status_text;
        p_line_tbl(I).usage_pricing_type := cl.usage_pricing_type;
        --p_line_tbl(I).line_category := cl.usage_pricing_type;
        --p_line_tbl(I).contract_start_date := cl.usage_pricing_type;
        --p_line_tbl(I).contract_end_date := cl.usage_pricing_type;
        --p_line_tbl(I).line_unit_price := cl.usage_pricing_type;
    END LOOP;

    /* reconstruct p_line_attr_tbl */
    I := 0;
    FOR cl IN cl_line_attr_dbg(p_request_id)
    LOOP
        I := I+1;
        --dbms_output.put_line('line index '||cl.line_Index||' cnt '||i);
        p_line_attr_tbl(I).LINE_INDEX := cl.LINE_INDEX;
        p_line_attr_tbl(I).PRICING_CONTEXT :=cl.context;
        p_line_attr_tbl(I).PRICING_ATTRIBUTE :=cl.attribute;
        p_line_attr_tbl(I).PRICING_ATTR_VALUE_FROM  := cl.value_from;
        p_line_attr_tbl(I).PRICING_ATTR_VALUE_TO  := cl.value_to;
        p_line_attr_tbl(I).VALIDATED_FLAG :=cl.VALIDATED_FLAG;
        p_line_attr_tbl(I).STATUS_CODE :=cl.PRICING_STATUS_CODE;
        p_line_attr_tbl(I).STATUS_TEXT :=cl.PRICING_STATUS_TEXT;
    END LOOP;

    /* reconstruct p_qual_tbl */
    I := 0;
    FOR cl IN cl_qual_dbg(p_request_id)
    LOOP
        I := I+1;
        --dbms_output.put_line('line index '||cl.line_Index||' cnt '||i);
        p_qual_tbl(i).LINE_INDEX := cl.LINE_INDEX;
        p_qual_tbl(i).QUALIFIER_CONTEXT :=cl.context;
        p_qual_tbl(i).QUALIFIER_ATTRIBUTE :=cl.attribute;
        p_qual_tbl(i).QUALIFIER_ATTR_VALUE_FROM := cl.value_from;
        p_qual_tbl(i).QUALIFIER_ATTR_VALUE_TO := cl.value_to;
        p_qual_tbl(i).COMPARISON_OPERATOR_CODE := cl.COMPARISON_OPERATOR_TYPE_CODE;
        p_qual_tbl(i).VALIDATED_FLAG :=cl.VALIDATED_FLAG;
        p_qual_tbl(i).STATUS_CODE :=cl.PRICING_STATUS_CODE;
        p_qual_tbl(i).STATUS_TEXT :=cl.PRICING_STATUS_TEXT;
    END LOOP;

    /* reconstruct p_line_detail_tbl */
    I := 0;
    FOR cl IN cl_ldets_dbg(p_request_id)
    LOOP
        I := I+1;
        --dbms_output.put_line('line index '||cl.line_Index||' cnt '||i);
        p_line_detail_tbl(i).LINE_DETAIL_INDEX := cl.LINE_DETAIL_INDEX;
        --p_line_detail_tbl(i).LINE_DETAIL_ID := cl.LINE_INDEX;
        p_line_detail_tbl(i).LINE_DETAIL_TYPE_CODE := cl.LINE_DETAIL_TYPE_CODE;
        p_line_detail_tbl(i).LINE_INDEX := cl.LINE_INDEX;
        p_line_detail_tbl(i).LIST_HEADER_ID := cl.CREATED_FROM_LIST_HEADER_ID;
        p_line_detail_tbl(i).LIST_LINE_ID := cl.CREATED_FROM_LIST_LINE_ID;
        p_line_detail_tbl(i).LIST_LINE_TYPE_CODE := cl.CREATED_FROM_LIST_TYPE_CODE;
        p_line_detail_tbl(i).SUBSTITUTION_TYPE_CODE := cl.SUBSTITUTION_TYPE_CODE;
        p_line_detail_tbl(i).SUBSTITUTION_FROM := cl.SUBSTITUTION_VALUE_FROM;
        p_line_detail_tbl(i).SUBSTITUTION_TO := cl.SUBSTITUTION_VALUE_TO;
        p_line_detail_tbl(i).AUTOMATIC_FLAG := cl.AUTOMATIC_FLAG;
        p_line_detail_tbl(i).OPERAND_CALCULATION_CODE := cl.OPERAND_CALCULATION_CODE;
        p_line_detail_tbl(i).OPERAND_VALUE := cl.OPERAND_VALUE;
        p_line_detail_tbl(i).PRICING_GROUP_SEQUENCE := cl.PRICING_GROUP_SEQUENCE;
        p_line_detail_tbl(i).PRICE_BREAK_TYPE_CODE := cl.PRICE_BREAK_TYPE_CODE;
        p_line_detail_tbl(i).CREATED_FROM_LIST_TYPE_CODE := cl.CREATED_FROM_LIST_TYPE_CODE;
        p_line_detail_tbl(i).PRICING_PHASE_ID := cl.PRICING_PHASE_ID;
        --p_line_detail_tbl(i).LIST_PRICE := cl.LINE_INDEX;
        p_line_detail_tbl(i).LINE_QUANTITY := cl.LINE_QUANTITY;
        p_line_detail_tbl(i).ADJUSTMENT_AMOUNT := cl.ADJUSTMENT_AMOUNT;
        p_line_detail_tbl(i).APPLIED_FLAG := cl.APPLIED_FLAG;
        p_line_detail_tbl(i).MODIFIER_LEVEL_CODE := cl.MODIFIER_LEVEL_CODE;
        p_line_detail_tbl(i).STATUS_CODE := cl.PRICING_STATUS_CODE;
        p_line_detail_tbl(i).STATUS_TEXT := cl.PRICING_STATUS_TEXT;
        --p_line_detail_tbl(i).SUBSTITUTION_ATTRIBUTE := cl
        p_line_detail_tbl(i).ACCRUAL_FLAG := cl.ACCRUAL_FLAG;
        p_line_detail_tbl(i).LIST_LINE_NO := cl.LIST_LINE_NO;
        --p_line_detail_tbl(i).ESTIM_GL_VALUE := cl.
        p_line_detail_tbl(i).ACCRUAL_CONVERSION_RATE := cl.ACCRUAL_CONVERSION_RATE;
        p_line_detail_tbl(i).OVERRIDE_FLAG := cl.OVERRIDE_FLAG;
        p_line_detail_tbl(i).PRINT_ON_INVOICE_FLAG := cl.PRINT_ON_INVOICE_FLAG;
        --p_line_detail_tbl(i).INVENTORY_ITEM_ID := cl.
        --p_line_detail_tbl(i).ORGANIZATION_ID := cl.LINE_INDEX;
        --p_line_detail_tbl(i).RELATED_ITEM_ID := cl.LINE_INDEX;
        --p_line_detail_tbl(i).RELATIONSHIP_TYPE_ID := cl.LINE_INDEX;
        p_line_detail_tbl(i).ESTIM_ACCRUAL_RATE := cl.ESTIM_ACCRUAL_RATE;
        --p_line_detail_tbl(i).EXPIRATION_DATE := cl.
        --p_line_detail_tbl(i).BENEFIT_PRICE_LIST_LINE_ID := cl.LINE_INDEX;
        p_line_detail_tbl(i).RECURRING_FLAG := cl.RECURRING_FLAG;
        --p_line_detail_tbl(i).BENEFIT_LIMIT := cl.LINE_INDEX;
        p_line_detail_tbl(i).CHARGE_TYPE_CODE := cl.CHARGE_TYPE_CODE;
        p_line_detail_tbl(i).CHARGE_SUBTYPE_CODE := cl.CHARGE_SUBTYPE_CODE;
        --p_line_detail_tbl(i).INCLUDE_ON_RETURNS_FLAG := cl.LINE_INDEX;
        p_line_detail_tbl(i).BENEFIT_QTY := cl.BENEFIT_QTY;
        p_line_detail_tbl(i).BENEFIT_UOM_CODE := cl.BENEFIT_UOM_CODE;
        --p_line_detail_tbl(i).PRORATION_TYPE_CODE := cl.
        --p_line_detail_tbl(i).SOURCE_SYSTEM_CODE := cl.LINE_INDEX;
        --p_line_detail_tbl(i).REBATE_TRANSACTION_TYPE_CODE := cl.LINE_INDEX;
        p_line_detail_tbl(i).SECONDARY_PRICELIST_IND := cl.SECONDARY_PRICELIST_IND;
        --p_line_detail_tbl(i).GROUP_VALUE := cl.LINE_INDEX;
        --p_line_detail_tbl(i).COMMENTS := cl.LINE_INDEX;
        p_line_detail_tbl(i).UPDATED_FLAG := cl.UPDATED_FLAG;
        p_line_detail_tbl(i).PROCESS_CODE := cl.PROCESS_CODE;
        p_line_detail_tbl(i).LIMIT_CODE := cl.LIMIT_CODE;
        p_line_detail_tbl(i).LIMIT_TEXT := cl.LIMIT_TEXT;
        p_line_detail_tbl(i).FORMULA_ID := cl.PRICE_FORMULA_ID;
        p_line_detail_tbl(i).CALCULATION_CODE := cl.OPERAND_CALCULATION_CODE;
        p_line_detail_tbl(i).ROUNDING_FACTOR := cl.ROUNDING_FACTOR;
        --p_line_detail_tbl(i).currency_detail_id := cl.LINE_INDEX;
        --p_line_detail_tbl(i).currency_header_id:= cl.LINE_INDEX;
        --p_line_detail_tbl(i).selling_rounding_factor:= cl.LINE_INDEX;
        --p_line_detail_tbl(i).order_currency:= cl.LINE_INDEX;
        --p_line_detail_tbl(i).pricing_effective_date:= cl.LINE_INDEX;
        --p_line_detail_tbl(i).base_currency_code:= cl.LINE_INDEX;
        p_line_detail_tbl(i).change_reason_code:= cl.LINE_INDEX;
        p_line_detail_tbl(i).change_reason_text:= cl.LINE_INDEX;
    END LOOP;

    /* recontruct p_related_lines_tbl */
    I := 0;
    FOR cl IN cl_rltd_dbg(p_request_id)
    LOOP
        I := I+1;
        --dbms_output.put_line('line index '||cl.line_Index||' cnt '||i);
        p_related_lines_tbl(i).LINE_INDEX := cl.LINE_INDEX;
        p_related_lines_tbl(i).LINE_DETAIL_INDEX :=cl.LINE_DETAIL_INDEX;
        p_related_lines_tbl(i).RELATIONSHIP_TYPE_CODE :=cl.RELATIONSHIP_TYPE_CODE;
        p_related_lines_tbl(i).RELATED_LINE_INDEX := cl.RELATED_LINE_INDEX;
        p_related_lines_tbl(i).RELATED_LINE_DETAIL_INDEX := cl.RELATED_LINE_DETAIL_INDEX;
        p_related_lines_tbl(i).STATUS_CODE :=cl.PRICING_STATUS_CODE;
        p_related_lines_tbl(i).STATUS_TEXT :=cl.PRICING_STATUS_TEXT;
    END LOOP;

    /* debug info */
    Oe_Debug_Pub.G_DIR :='/sqlcom/log';
    Oe_Debug_Pub.Initialize;
    Oe_Debug_Pub.debug_on;
    Oe_Debug_Pub.SetDebugLevel(10);
    IF l_debug = Fnd_Api.G_TRUE THEN
    Oe_Debug_Pub.ADD('Before Process_Order',1);

    END IF;
    --dbms_output.put_line('The File is'|| oe_debug_pub.Set_Debug_Mode('FILE'));
    --dbms_output.put_line('The debug is ' || oe_debug_pub.g_debug);
    --l_version :=  qp_preq_grp.GET_VERSION;
    --dbms_output.put_line('Testing version '||l_version);
    --dbms_output.put_line('Debug2: ' || oe_debug_pub.g_debug);
    --dbms_output.put_line('Debug2: ');

    /* call engine pub API */
    Qp_Preq_Pub.PRICE_REQUEST
       (p_line_tbl,
        p_qual_tbl,
        p_line_attr_tbl,
        p_line_detail_tbl,
        p_line_detail_qual_tbl,
        p_line_detail_attr_tbl,
        p_related_lines_tbl,
        p_control_rec,
        x_line_tbl,
        x_line_qual,
        x_line_attr_tbl,
        x_line_detail_tbl,
        x_line_detail_qual_tbl,
        x_line_detail_attr_tbl,
        x_related_lines_tbl,
        l_return_status,
        l_return_status_text);
    --dbms_output.put_line('Return Status l_return_status '||  l_return_status);
    --dbms_output.put_line('Return Status text l_return_status_text '||  l_return_status_text);
    --dbms_output.put_line('+-----Information returned to caller:----------+ ');

    IF l_return_status <> Fnd_Api.G_RET_STS_SUCCESS THEN
	x_return_status := l_return_status;
	x_return_status_text := l_return_status_text;
    END IF;

    x_request_id := Qp_Copy_Debug_Pvt.REQUEST_ID;

EXCEPTION
    WHEN OTHERS THEN
	x_return_status := Fnd_Api.G_RET_STS_ERROR;
        x_return_status_text := 'Routine: QP_UTIL_PUB.Reprice_Debug_Engine_Request ERROR'||SQLERRM;
END Reprice_Debug_Engine_Request;

-- New procedure as per bug 2943038, required by Quoting
PROCEDURE Get_Price_List_Currency
(
    p_price_list_id             IN NUMBER
   ,x_sql_string                OUT NOCOPY VARCHAR2
)
IS
  l_no_multi_curr_sql VARCHAR2(2000) := 'SELECT distinct fnd.currency_code,fnd.name
    FROM fnd_currencies_vl fnd, qp_list_headers_b qlh
   WHERE fnd.currency_code = qlh.currency_code AND qlh.list_type_code in (''PRL'', ''AGR'')
     AND fnd.currency_flag = ''Y'' AND fnd.enabled_flag = ''Y''';

  l_multi_curr_sql  VARCHAR2(2000) := 'SELECT distinct fnd.currency_code,fnd.name
    FROM fnd_currencies_vl fnd, qp_currency_details qcd, qp_list_headers_b qlh
   WHERE qcd.currency_header_id = qlh.currency_header_id AND fnd.currency_code = qcd.to_currency_code
     AND qlh.list_type_code in (''PRL'', ''AGR'') and fnd.currency_flag = ''Y''
     AND fnd.enabled_flag = ''Y''';
BEGIN
   IF NVL(Fnd_Profile.value('QP_MULTI_CURRENCY_INSTALLED'), 'N') = 'Y'
      AND (NVL(Fnd_Profile.value('QP_MULTI_CURRENCY_USAGE'), 'Y') = 'Y') THEN
        x_sql_string := l_multi_curr_sql;

   ELSE
        x_sql_string := l_no_multi_curr_sql;

   END IF;

   IF p_price_list_id IS NOT NULL THEN
      x_sql_string := x_sql_string || ' and qlh.list_header_id = ' || p_price_list_id;
   END IF;

EXCEPTION
   WHEN OTHERS THEN
     IF Fnd_Msg_Pub.Check_Msg_Level(Fnd_Msg_Pub.G_MSG_LVL_ERROR) THEN
        Fnd_Message.SET_NAME('QP', 'QP_ERROR_GET_CURR_F_PRICELIST');
     END IF;

END Get_Price_List_Currency;

FUNCTION HVOP_Pricing_Setup RETURN VARCHAR2 IS
ret_val VARCHAR2(1) := 'N';
BEGIN
     IF Qp_Java_Engine_Util_Pub.Java_Engine_Running = 'Y' THEN
             ret_val := NVL (Fnd_Profile.Value('QP_HVOP_PRICING_SETUP'), 'N');
     END IF;
     RETURN ret_val;

EXCEPTION
     WHEN OTHERS THEN
     		 RETURN 'N';
END HVOP_Pricing_Setup;


FUNCTION HVOP_Pricing_ON RETURN VARCHAR2 IS
  ret_val VARCHAR2(1) := 'N';
BEGIN
     IF Qp_Java_Engine_Util_Pub.Java_Engine_Running = 'Y' THEN
             ret_val := NVL(Qp_Bulk_Preq_Grp.G_HVOP_pricing_ON,'N');
     END IF;
     RETURN ret_val;
EXCEPTION
     WHEN OTHERS THEN
                 RETURN 'N';
END HVOP_Pricing_ON;

--Fix for bug 3550303 to reset the QP_BULK_PREQ_GRP.G_HVOP_pricing_ON
--at the end of HVOP pricing call
PROCEDURE RESET_HVOP_PRICING_ON IS
BEGIN
 l_debug := Qp_Preq_Grp.G_DEBUG_ENGINE;
  IF HVOP_Pricing_ON = 'Y' THEN
    IF l_debug = Fnd_Api.G_TRUE THEN
      Qp_Preq_Grp.Engine_debug('HVOP_Pricing_On is: '||Qp_Bulk_Preq_Grp.G_HVOP_pricing_ON);
      Qp_Preq_Grp.Engine_debug('Resetting HVOP_Pricing_On at the end');
    END IF;--l_debug
    Qp_Bulk_Preq_Grp.G_HVOP_pricing_ON := 'N';
    IF l_debug = Fnd_Api.G_TRUE THEN
      Qp_Preq_Grp.Engine_debug('HVOP_Pricing_On Now Reset to: '||Qp_Bulk_Preq_Grp.G_HVOP_pricing_ON);
    END IF;--l_debug
  END IF;--HVOP_Pricing_ON
EXCEPTION
WHEN OTHERS THEN
Qp_Bulk_Preq_Grp.G_HVOP_pricing_ON := 'N';
END RESET_HVOP_PRICING_ON;

-- New procedure for bug 3118385
PROCEDURE Get_Attribute_Text(p_attributes_tbl  IN OUT NOCOPY attribute_tbl)
IS
  l_segment_code   VARCHAR2(80);
BEGIN
  IF p_attributes_tbl.COUNT > 0 THEN
    FOR i IN 1..p_attributes_tbl.COUNT
    LOOP
      -- find context text
      IF p_attributes_tbl(i).attribute_type IN ('PRODUCT', 'PRICING') THEN
         p_attributes_tbl(i).context_text := Qp_Util.get_context('QP_ATTR_DEFNS_PRICING',
                                                                 p_attributes_tbl(i).context_code);
      ELSIF p_attributes_tbl(i).attribute_type = 'QUALIFIER' THEN
         p_attributes_tbl(i).context_text := Qp_Util.get_context('QP_ATTR_DEFNS_QUALIFIER',
                                                                 p_attributes_tbl(i).context_code);
      END IF;

      -- find attribute text
      IF p_attributes_tbl(i).attribute_type IN ('PRODUCT', 'PRICING') THEN
         Qp_Util.Get_Attribute_Code(p_FlexField_Name  =>  'QP_ATTR_DEFNS_PRICING',
                                    p_Context_Name    =>  p_attributes_tbl(i).context_code,
                                    p_attribute       =>  p_attributes_tbl(i).attribute_code,
                                    x_attribute_code  => p_attributes_tbl(i).attribute_text,
                                    x_segment_name    => l_segment_code);
      ELSIF p_attributes_tbl(i).attribute_type = 'QUALIFIER' THEN
         Qp_Util.Get_Attribute_Code(p_FlexField_Name  =>  'QP_ATTR_DEFNS_QUALIFIER',
                                    p_Context_Name    =>  p_attributes_tbl(i).context_code,
                                    p_attribute       =>  p_attributes_tbl(i).attribute_code,
                                    x_attribute_code  => p_attributes_tbl(i).attribute_text,
                                    x_segment_name    => l_segment_code);
      END IF;

      -- find attribute value text
      IF p_attributes_tbl(i).attribute_type = 'PRODUCT' THEN
        p_attributes_tbl(i).attribute_value_from_text :=
             Qp_Price_List_Line_Util.Get_Product_Value('QP_ATTR_DEFNS_PRICING'
                                                       ,p_attributes_tbl(i).context_code
                                                       ,p_attributes_tbl(i).attribute_code
                                                       ,p_attributes_tbl(i).attribute_value_from
                                                      );

      ELSIF p_attributes_tbl(i).attribute_type = 'PRICING' THEN
        p_attributes_tbl(i).attribute_value_from_text :=
                            Qp_Util.Get_Attribute_Value('QP_ATTR_DEFNS_PRICING'
                                                        ,p_attributes_tbl(i).context_code
                                                        ,p_attributes_tbl(i).attribute_code
                                                        ,p_attributes_tbl(i).attribute_value_from
                                                        ,p_attributes_tbl(i).operator
                                                      );
      ELSIF p_attributes_tbl(i).attribute_type = 'QUALIFIER' THEN
        p_attributes_tbl(i).attribute_value_from_text :=
                            Qp_Util.Get_Attribute_Value('QP_ATTR_DEFNS_QUALIFIER'
                                                        ,p_attributes_tbl(i).context_code
                                                        ,p_attributes_tbl(i).attribute_code
                                                        ,p_attributes_tbl(i).attribute_value_from
                                                        ,p_attributes_tbl(i).operator
                                                      );
      END IF;
    END LOOP;
  END IF;

END Get_Attribute_Text;

 -- This procedure fetchs price lists and modifier lists specific to a blanket.
 -- i.e. pricing data with list_source_code of Blanket and orig_system_header_ref of this blanket header
PROCEDURE Get_Blanket_Pricelist_Modifier(
 p_blanket_header_id		IN	NUMBER
,x_price_list_tbl		OUT	NOCOPY Qp_Price_List_Pub.Price_List_Tbl_Type
,x_modifier_list_tbl		OUT	NOCOPY Qp_Modifiers_Pub.Modifier_List_Tbl_Type
,x_return_status		OUT	NOCOPY VARCHAR2
,x_msg_count			OUT	NOCOPY NUMBER
,x_msg_data			OUT	NOCOPY VARCHAR2
)
IS
l_PRICE_LIST_rec		Qp_Price_List_Pub.Price_List_Rec_Type;
l_PRICE_LIST_tbl		Qp_Price_List_Pub.Price_List_Tbl_Type;
l_MODIFIER_LIST_rec		Qp_Modifiers_Pub.Modifier_List_Rec_Type;
l_MODIFIER_LIST_tbl		Qp_Modifiers_Pub.Modifier_List_Tbl_Type;

CURSOR blanket_price_lists( p_blkt_header_id NUMBER) IS
  SELECT list_header_id FROM qp_list_headers_b
  WHERE list_source_code = 'BSO'
  AND orig_system_header_ref = p_blkt_header_id
  AND list_type_code = 'PRL';

CURSOR blanket_modifier_lists( p_blkt_header_id NUMBER) IS
  SELECT list_header_id FROM qp_list_headers_b
  WHERE list_source_code = 'BSO'
  AND orig_system_header_ref = p_blkt_header_id
  AND list_type_code NOT IN ('PRL','AGR');

BEGIN
-- Get Pricelist
	FOR I IN blanket_price_lists(p_blanket_header_id) LOOP

	        l_PRICE_LIST_rec := Qp_Price_List_Util.Query_Row
		(   p_list_header_id              => I.list_header_id
	        );

		l_PRICE_LIST_tbl(l_PRICE_LIST_tbl.COUNT + 1) := l_PRICE_LIST_rec;

	END LOOP;

	x_PRICE_LIST_tbl := l_PRICE_LIST_tbl;

-- Get Modifier list
	FOR I IN blanket_modifier_lists(p_blanket_header_id) LOOP

	        l_MODIFIER_LIST_rec := Qp_Modifier_List_Util.Query_Row
		(   p_list_header_id              => I.list_header_id
	        );

		l_MODIFIER_LIST_tbl(l_MODIFIER_LIST_tbl.COUNT + 1) := l_MODIFIER_LIST_rec;

	END LOOP;

	x_MODIFIER_LIST_tbl := l_MODIFIER_LIST_tbl;

    --  Set return status.

	x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

    --  Get message count and data

	Oe_Msg_Pub.Count_And_Get
	(   p_count                       => x_msg_count
	,   p_data                        => x_msg_data
	);


EXCEPTION
    WHEN NO_DATA_FOUND THEN
	x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;

        IF Oe_Msg_Pub.Check_Msg_Level(Oe_Msg_Pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            Oe_Msg_Pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Get_Blanket_Pricelist_Modifier'
            );
        END IF;

        --  Get message count and data

        Oe_Msg_Pub.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

	Oe_Debug_Pub.ADD('END Get_Blanket_Price in QPXRTCNB');

    WHEN OTHERS THEN

	x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;

        IF Oe_Msg_Pub.Check_Msg_Level(Oe_Msg_Pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            Oe_Msg_Pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Get_Blanket_Pricelist_Modifier'
            );
        END IF;

        --  Get message count and data

        Oe_Msg_Pub.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

	Oe_Debug_Pub.ADD('END Get_Blanket_Pricelist_Modifier in QPXRTCNB');
END Get_Blanket_Pricelist_Modifier;

PROCEDURE Check_Pricing_Attributes (
         P_Api_Version_Number           IN   NUMBER          := 1,
         P_Init_Msg_List                IN   VARCHAR2        := Fnd_Api.G_FALSE,
         P_Commit                       IN   VARCHAR2        := Fnd_Api.G_FALSE,
         P_Inventory_Id                 IN   NUMBER          := Fnd_Api.G_MISS_NUM,
         P_Price_List_Id                IN   NUMBER          := Fnd_Api.G_MISS_NUM,
         X_Check_Return_Status_qp       OUT  NOCOPY VARCHAR2,
         x_msg_count                    OUT  NOCOPY NUMBER,
         x_msg_data                     OUT  NOCOPY VARCHAR2)
IS



CURSOR c_check_qpprc_atr IS
SELECT 'X'
FROM
 QP_PRICING_ATTRIBUTES A,
 QP_LIST_LINES L,
 QP_LIST_HEADERS_B QLH
WHERE
 A.LIST_HEADER_ID = P_Price_List_Id  AND
 A.PRODUCT_ATTRIBUTE_CONTEXT = 'ITEM'  AND
 A.PRODUCT_ATTRIBUTE IN ( 'PRICING_ATTRIBUTE1','PRICING_ATTRIBUTE3'  ) AND
 A.PRODUCT_ATTR_VALUE IN ( TO_CHAR(P_Inventory_Id),'ALL'  ) AND
 A.PRICING_PHASE_ID = 1 AND
 A.QUALIFICATION_IND IN (4,6,20,22) AND
 A.EXCLUDER_FLAG = 'N' AND
 (EXISTS  (SELECT  NULL
           FROM    QP_PRICE_FORMULA_LINES FL
           WHERE FL.PRICE_FORMULA_LINE_TYPE_CODE IN ('PRA','ML') AND
           FL.PRICE_FORMULA_ID = L.PRICE_BY_FORMULA_ID)
  OR
          (A.PRICING_ATTRIBUTE_CONTEXT <> 'VOLUME'))  AND
 L.LIST_LINE_ID = A.LIST_LINE_ID  AND
 L.LIST_LINE_TYPE_CODE = 'PLL' AND
 QLH.LIST_HEADER_ID = L.LIST_HEADER_ID  AND
 QLH.LIST_TYPE_CODE = 'PRL'  AND
 NVL(QLH.START_DATE_ACTIVE, SYSDATE) <= SYSDATE  AND NVL(QLH.END_DATE_ACTIVE,SYSDATE) >= SYSDATE
  AND
 NVL(L.START_DATE_ACTIVE,SYSDATE) <= SYSDATE  AND NVL(L.END_DATE_ACTIVE, SYSDATE) >= SYSDATE
 AND
ROWNUM < 2;


l_count NUMBER;
l_list_line_id NUMBER;
c_check_qpprc_atr_rec    c_check_qpprc_atr%ROWTYPE;

BEGIN
        X_Check_Return_Status_qp := Fnd_Api.G_FALSE;

                OPEN  c_check_qpprc_atr;
                FETCH  c_check_qpprc_atr  INTO c_check_qpprc_atr_rec;
        IF c_check_qpprc_atr%FOUND THEN
                X_Check_Return_Status_qp := Fnd_Api.G_TRUE;
        END IF;
        CLOSE  c_check_qpprc_atr;

END  Check_Pricing_Attributes;


PROCEDURE Check_Pricing_Attributes (
     P_Api_Version_Number          IN   NUMBER    := 1,
     P_Init_Msg_List               IN   VARCHAR2  := Fnd_Api.G_FALSE,
     P_Commit                      IN   VARCHAR2  := Fnd_Api.G_FALSE,
     P_Inventory_Id                IN   NUMBER    := Fnd_Api.G_MISS_NUM,
     P_Price_List_Id               IN   NUMBER    := Fnd_Api.G_MISS_NUM,
     X_Check_Return_Status_qp        OUT NOCOPY VARCHAR2,
     x_return_status               OUT NOCOPY VARCHAR2,
     x_msg_count                     OUT NOCOPY NUMBER,
     x_msg_data                      OUT NOCOPY VARCHAR2)
IS


CURSOR c_check_qpprc_atr IS
SELECT 'X'
FROM
 QP_PRICING_ATTRIBUTES A,
 QP_LIST_LINES L,
 QP_LIST_HEADERS_B QLH
WHERE
 A.LIST_HEADER_ID = P_Price_List_Id  AND
 A.PRODUCT_ATTRIBUTE_CONTEXT = 'ITEM'  AND
 A.PRODUCT_ATTRIBUTE IN ( 'PRICING_ATTRIBUTE1','PRICING_ATTRIBUTE3'  ) AND
 A.PRODUCT_ATTR_VALUE IN ( TO_CHAR(P_Inventory_Id),'ALL'  ) AND
 A.PRICING_PHASE_ID = 1 AND
 A.QUALIFICATION_IND IN (4,6,20,22) AND
 A.EXCLUDER_FLAG = 'N' AND
 (EXISTS  (SELECT  NULL
           FROM    QP_PRICE_FORMULA_LINES FL
           WHERE FL.PRICE_FORMULA_LINE_TYPE_CODE IN ('PRA','ML') AND
           FL.PRICE_FORMULA_ID = L.PRICE_BY_FORMULA_ID)
  OR
          (A.PRICING_ATTRIBUTE_CONTEXT <> 'VOLUME'))  AND
 L.LIST_LINE_ID = A.LIST_LINE_ID  AND
 L.LIST_LINE_TYPE_CODE = 'PLL' AND
 QLH.LIST_HEADER_ID = L.LIST_HEADER_ID  AND
 QLH.LIST_TYPE_CODE = 'PRL'  AND
 NVL(QLH.START_DATE_ACTIVE, SYSDATE) <= SYSDATE  AND NVL(QLH.END_DATE_ACTIVE,SYSDATE) >= SYSDATE
  AND
 NVL(L.START_DATE_ACTIVE,SYSDATE) <= SYSDATE  AND NVL(L.END_DATE_ACTIVE, SYSDATE) >= SYSDATE
 AND
ROWNUM < 2;

/*
    CURSOR l_pricing_attribs IS
    SELECT distinct pricing_attribute_context, pricing_attribute
    FROM  qp_pricing_attributes
    WHERE product_attribute IN ('PRICING_ATTRIBUTE1','PRICING_ATTRIBUTE3')
    AND product_attribute_context = 'ITEM'
    AND product_attr_value IN (to_char(P_Inventory_Id),'ALL')
    AND ((pricing_attribute_context IS NOT NULL AND  pricing_attribute IS NOT NULL )
         AND (pricing_attribute_context <> 'VOLUME'
                    AND pricing_attribute NOT IN ('PRICING_ATTRIBUTE10','PRICING_ATTRIBUTE12'
))
        );
*/

CURSOR l_pricing_attribs IS
SELECT DISTINCT pricing_attribute_context, pricing_attribute
FROM  qp_pricing_attributes
WHERE list_header_id = P_Price_List_Id
AND ( product_attribute IN ('PRICING_ATTRIBUTE1','PRICING_ATTRIBUTE3')
AND product_attribute_context = 'ITEM'
AND product_attr_value IN (TO_CHAR(P_Inventory_Id),'ALL')
AND ((pricing_attribute_context IS NOT NULL AND  pricing_attribute IS NOT NULL )
AND (pricing_attribute_context <> 'VOLUME'
AND pricing_attribute NOT IN ('PRICING_ATTRIBUTE10','PRICING_ATTRIBUTE12'))) )
UNION ALL
SELECT DISTINCT pricing_attribute_context, pricing_attribute
FROM  qp_pricing_attributes
WHERE list_header_id IN (
SELECT FL.price_modifier_list_id
FROM
 QP_PRICING_ATTRIBUTES A,
 QP_LIST_LINES L,
 QP_LIST_HEADERS_B QLH,
 QP_PRICE_FORMULA_LINES FL
WHERE
 A.LIST_HEADER_ID = P_Price_List_Id  AND
 A.PRODUCT_ATTRIBUTE_CONTEXT = 'ITEM'  AND
 A.PRODUCT_ATTRIBUTE IN ( 'PRICING_ATTRIBUTE1','PRICING_ATTRIBUTE3'  ) AND
 A.PRODUCT_ATTR_VALUE IN ( TO_CHAR(P_Inventory_Id),'ALL'  ) AND
 A.PRICING_PHASE_ID = 1 AND
 A.QUALIFICATION_IND IN (4,6,20,22) AND
 A.EXCLUDER_FLAG = 'N' AND
 FL.PRICE_FORMULA_LINE_TYPE_CODE IN ('PRA','ML') AND
 FL.PRICE_FORMULA_ID = L.PRICE_BY_FORMULA_ID AND
 L.LIST_LINE_ID = A.LIST_LINE_ID  AND
 L.LIST_LINE_TYPE_CODE = 'PLL' AND
 QLH.LIST_HEADER_ID = L.LIST_HEADER_ID  AND
 QLH.LIST_TYPE_CODE = 'PRL'  AND
 NVL(QLH.START_DATE_ACTIVE, SYSDATE) <= SYSDATE  AND NVL(QLH.END_DATE_ACTIVE,SYSDATE) >= SYSDATE  AND
 NVL(L.START_DATE_ACTIVE,SYSDATE) <= SYSDATE  AND NVL(L.END_DATE_ACTIVE, SYSDATE) >= SYSDATE
)
UNION ALL
SELECT DISTINCT FL.pricing_attribute_context, FL.pricing_attribute
FROM
 QP_PRICING_ATTRIBUTES A,
 QP_LIST_LINES L,
 QP_LIST_HEADERS_B QLH,
 QP_PRICE_FORMULA_LINES FL
WHERE
 A.LIST_HEADER_ID = P_Price_List_Id  AND
 A.PRODUCT_ATTRIBUTE_CONTEXT = 'ITEM'  AND
 A.PRODUCT_ATTRIBUTE IN ( 'PRICING_ATTRIBUTE1','PRICING_ATTRIBUTE3'  ) AND
 A.PRODUCT_ATTR_VALUE IN ( TO_CHAR(P_Inventory_Id),'ALL'  ) AND
 L.LIST_LINE_ID = A.LIST_LINE_ID  AND
 L.LIST_LINE_TYPE_CODE = 'PLL' AND
 FL.PRICE_FORMULA_LINE_TYPE_CODE = 'PRA' AND --IN ('PRA','ML') AND, BUG No: 9155255
 FL.PRICE_FORMULA_ID = L.PRICE_BY_FORMULA_ID AND
 QLH.LIST_HEADER_ID = L.LIST_HEADER_ID  AND
 QLH.LIST_TYPE_CODE = 'PRL'  AND
 NVL(QLH.START_DATE_ACTIVE, SYSDATE) <= SYSDATE  AND NVL(QLH.END_DATE_ACTIVE,SYSDATE) >= SYSDATE  AND
 NVL(L.START_DATE_ACTIVE,SYSDATE) <= SYSDATE  AND NVL(L.END_DATE_ACTIVE, SYSDATE) >= SYSDATE
;


l_api_name              CONSTANT VARCHAR2(30) := 'Check_Pricing_Attributes';
l_api_version_number    CONSTANT NUMBER   := 1.0;
l_count                 NUMBER;
l_list_line_id          NUMBER;
c_check_qpprc_atr_rec    c_check_qpprc_atr%ROWTYPE;
l_found                 VARCHAR2(1);
v_pricing_attr_ctxt     VARCHAR2(60);
v_pricing_attr          VARCHAR2(60);
l_condition_id          VARCHAR2(60);
l_context_name          VARCHAR2(60);
l_attr_def_condition_id VARCHAR2(60);


G_USER_ID                     NUMBER := Fnd_Global.USER_ID;
G_LOGIN_ID                    NUMBER := Fnd_Global.CONC_LOGIN_ID;

BEGIN


    x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
    X_Check_Return_Status_qp := Fnd_Api.G_FALSE;

    OPEN  c_check_qpprc_atr;
    FETCH c_check_qpprc_atr INTO c_check_qpprc_atr_rec;
    IF c_check_qpprc_atr%FOUND THEN
                X_Check_Return_Status_qp := Fnd_Api.G_TRUE;
    END IF;
    CLOSE  c_check_qpprc_atr;


IF X_Check_Return_Status_qp = Fnd_Api.G_TRUE THEN
 l_found := 0;
 OPEN l_pricing_attribs;
       LOOP
           FETCH l_pricing_attribs INTO v_pricing_attr_ctxt, v_pricing_attr;
           EXIT WHEN l_pricing_attribs%NOTFOUND;

           BEGIN
              SELECT 1
              INTO l_found
              FROM qp_prc_contexts_b con, qp_segments_b seg, qp_pte_segments pte
              WHERE con.prc_context_code = v_pricing_attr_ctxt
              AND   seg.prc_context_id = con.prc_context_id
              AND   seg.segment_mapping_column = v_pricing_attr
              AND   seg.segment_id = pte.segment_id
              AND   pte.pte_code = 'ORDFUL' -- 4055210
			  AND   ROWNUM < 2; -- 4055210
           EXCEPTION
               WHEN NO_DATA_FOUND THEN
                   l_found := 0;
           END;

           IF l_found = 1 THEN
           BEGIN
              SELECT 1
              INTO l_found
              FROM qp_prc_contexts_b con, qp_segments_b seg, qp_attribute_sourcing src
              WHERE con.prc_context_code = v_pricing_attr_ctxt
              AND   seg.prc_context_id = con.prc_context_id
              AND   seg.segment_mapping_column = v_pricing_attr
              AND   seg.segment_id = src.segment_id
              AND   src.request_type_code = 'ASO'-- 4055210
			  AND   ROWNUM < 2; -- 4055210

           EXCEPTION
               WHEN NO_DATA_FOUND THEN
                   l_found := 0;
           END;

           END IF;

       END LOOP;
        CLOSE l_pricing_attribs;
      IF l_found = 1 THEN
         X_Check_Return_Status_qp := 'SOURCED';
      ELSE
         X_Check_Return_Status_qp := 'NOT_SOURCED';
      END IF;
ELSE
   X_Check_Return_Status_qp := 'NO_ATTRIBUTES';
END IF;-- IF X_Check_Return_Status_qp = FND_API.G_TRUE


EXCEPTION
      WHEN OTHERS THEN
        Oe_Debug_Pub.ADD('Error in Get_Pricing_attributes');

END Check_Pricing_Attributes;


/*--bug 3228829
OM needs API to update the lines_tmp table
this API will take care of updating i/f tables java engine is installed
and update temp tables when plsql engine is installed*/
PROCEDURE Update_Lines(p_update_type IN VARCHAR2, p_line_id IN NUMBER,
                       p_line_index IN NUMBER, p_priced_quantity IN NUMBER) IS
BEGIN
l_debug := Qp_Preq_Grp.G_DEBUG_ENGINE;
IF Qp_Java_Engine_Util_Pub.Java_Engine_Running = 'N' THEN
  IF l_debug = Fnd_Api.G_TRUE THEN
    Qp_Preq_Grp.engine_debug('Java engine not installed '
    ||' line_id '||p_line_id||' line_index '||p_line_index
    ||' p_priced_quantity '||p_priced_quantity||' p_update_type '||p_update_type);
  END IF;
  IF p_update_type = 'UPDATE_LINE_ID' THEN
    IF p_line_index IS NOT NULL THEN
      UPDATE qp_npreq_lines_tmp SET line_id = p_line_id
      WHERE line_index = p_line_index;
    END IF;--p_line_index IS NOT NULL
  ELSIF p_update_type = 'UPDATE_PRICED_QUANTITY' THEN
    IF p_line_id IS NOT NULL THEN
      UPDATE qp_npreq_lines_tmp SET priced_quantity = p_priced_quantity
      WHERE line_id = p_line_id;
    END IF;--p_line_id IS NOT NULL
  ELSIF  p_update_type = 'MAKE_STATUS_INVALID' THEN
    IF p_line_id IS NOT NULL THEN
      UPDATE qp_npreq_lines_tmp SET process_status = 'NOT_VALID'
      WHERE line_id = p_line_id;
    END IF;--p_line_id IS NOT NULL
  END IF;
ELSE
  IF l_debug = Fnd_Api.G_TRUE THEN
    Qp_Preq_Grp.engine_debug('Java engine installed '
    ||' line_id '||p_line_id||' line_index '||p_line_index
    ||' p_priced_quantity '||p_priced_quantity||' p_update_type '||p_update_type);
  END IF;
  IF p_update_type = 'UPDATE_LINE_ID' THEN
    IF p_line_index IS NOT NULL THEN
      UPDATE qp_int_lines SET line_id = p_line_id
      WHERE line_index = p_line_index;
    END IF;--p_line_index IS NOT NULL
  ELSIF p_update_type = 'UPDATE_PRICED_QUANTITY' THEN
    IF p_line_id IS NOT NULL THEN
      UPDATE qp_int_lines SET priced_quantity = p_priced_quantity
      WHERE line_id = p_line_id;
    END IF;--p_line_id IS NOT NULL
  ELSIF  p_update_type = 'MAKE_STATUS_INVALID' THEN
    IF p_line_id IS NOT NULL THEN
      UPDATE qp_int_lines SET process_status = 'NOT_VALID'
      WHERE line_id = p_line_id;
    END IF;--p_line_id IS NOT NULL
  END IF;
END IF;--java engine installed

END Update_Lines;

PROCEDURE Flex_Enabled_Status (p_flexfields_name IN VARCHAR2, x_status OUT NOCOPY VARCHAR2)
IS
BEGIN
  IF (FND_FLEX_APIS.is_descr_setup(661, p_flexfields_name)) THEN
    x_status:= 'Y';
  ELSE
    x_status:='N';
  END IF;
END Flex_Enabled_Status;

END Qp_Util_Pub;

/
