--------------------------------------------------------
--  DDL for Package Body QP_LIMIT_TRANSACTIONS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_LIMIT_TRANSACTIONS_PVT" AS
/* $Header: QPXVLTDB.pls 120.1 2005/12/27 13:57:58 gtippire noship $ */

l_debug VARCHAR2(3);

/************************************************************************
 Procedure to autonomously update qp_limit_balances table.
 ***********************************************************************/
PROCEDURE Update_Balance(p_amount           IN  NUMBER,
                         p_limit_balance_id IN  NUMBER)
IS
PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
/*
INDX,qp_limit_transactions_pvt.update.upd1,QP_LIMIT_BALANCES_U1,LIMIT_BALANCE_ID,1
*/
    --sql statement upd1
    UPDATE qp_limit_balances
    SET    available_amount = available_amount + p_amount
    WHERE  limit_balance_id = p_limit_balance_id;

    COMMIT;

END Update_Balance;


/***********************************************************************
   Procedure to Delete a Limit Transaction record for an event and phase
   combination that does not have a corresponding modifier in the
   qp_npreq_ldets_tmp table.
***********************************************************************/
PROCEDURE Delete (p_pricing_event_code IN  VARCHAR2,
                  x_return_status      OUT NOCOPY VARCHAR2)
IS
/*
INDX,qp_limit_transactions_pvt.delete.limit_trans_cur,QP_LIMIT_TRANSACTIONS_U1,PRICE_REQUEST_CODE,1
INDX,qp_limit_transactions_pvt.delete.limit_trans_cur,QP_LIMIT_TRANSACTIONS_U1,LIST_HEADER_ID,2
INDX,qp_limit_transactions_pvt.delete.limit_trans_cur,QP_LIMIT_TRANSACTIONS_U1,LIST_LINE_ID,3
INDX,qp_limit_transactions_pvt.delete.limit_trans_cur,QP_LIMIT_TRANSACTIONS_U1,LIMIT_BALANCE_ID,4
INDX,qp_limit_transactions_pvt.delete.limit_trans_cur,qp_npreq_ldets_tmp_N1,LINE_INDEX,1
INDX,qp_limit_transactions_pvt.delete.limit_trans_cur,qp_npreq_ldets_tmp_N1,PRICING_STATUS_CODE,2
INDX,qp_limit_transactions_pvt.delete.limit_trans_cur,qp_npreq_ldets_tmp_N1,PRICING_PHASE_ID,3
INDX,qp_limit_transactions_pvt.delete.limit_trans_cur,qp_npreq_ldets_tmp_N1,CREATED_FROM_LIST_HEADER_ID,4
INDX,qp_limit_transactions_pvt.delete.limit_trans_cur,qp_npreq_ldets_tmp_N1,CREATED_FROM_LIST_LINE_ID,5
INDX,qp_limit_transactions_pvt.delete.limit_trans_cur,QP_EVENT_PHASES_U1,PRICING_EVENT_CODE,1
INDX,qp_limit_transactions_pvt.delete.limit_trans_cur,QP_EVENT_PHASES_U1,PRICING_PHASE_ID,2
*/
CURSOR limit_trans_cur(a_pricing_event_code VARCHAR2)
IS
  SELECT t.limit_balance_id, t.list_header_id, t.list_line_id,
         t.price_request_code, t.pricing_phase_id, t.amount
  FROM   qp_limit_transactions t, qp_npreq_lines_tmp b
  WHERE  t.pricing_phase_id IN (SELECT pricing_phase_id
                                FROM   qp_event_phases evt
--                                WHERE pricing_event_code = a_pricing_event_code)
                                --fix for bug 4765137
                                WHERE instr(a_pricing_event_code, evt.pricing_event_code || ',') > 0)
  AND    t.price_request_code = b.price_request_code
  AND    NOT EXISTS (SELECT 'X'
                     FROM   qp_npreq_ldets_tmp l
                     WHERE  l.created_from_list_header_id = t.list_header_id
                     AND    l.created_from_list_line_id = t.list_line_id
                     AND    l.pricing_phase_id = t.pricing_phase_id
                     AND    l.line_index = b.line_index
                     AND    l.pricing_status_code = QP_PREQ_GRP.G_STATUS_NEW);

BEGIN
  l_debug := QP_PREQ_GRP.G_DEBUG_ENGINE;
  IF l_debug = FND_API.G_TRUE THEN
  QP_PREQ_GRP.engine_debug('***Begin Procedure Delete*** ');
  QP_PREQ_GRP.engine_debug('***Begin Procedure Delete***: price_event: '|| p_pricing_event_code);

  for cl in (select line.line_index, line.price_request_code, trx.list_header_id, trx.pricing_phase_id
             from qp_npreq_lines_tmp line, qp_limit_transactions trx
             where trx.price_request_code = line.price_request_code)
  LOOP
    QP_PREQ_GRP.engine_debug('Limit transactions for current lines '||cl.line_index||' price_reqCode '||cl.price_request_code||' listhdrid '||cl.list_header_id);
    for cl1 in (select ldet.created_from_list_header_id, ldet.pricing_status_code
                from qp_npreq_ldets_tmp ldet
                where ldet.created_from_list_header_id = cl.list_header_id
                and ldet.line_index = cl.line_index
                and ldet.pricing_phase_id in (select pricing_phase_id
                                              from qp_event_phases evt
                                              where instr(p_pricing_event_code, evt.pricing_event_code || ',') > 0))
    LOOP
      QP_PREQ_GRP.engine_debug('adjustments for above transactions '||cl1.created_from_list_header_id||' status '||cl1.pricing_status_code);
    END LOOP;
  END LOOP;

  END IF;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  FOR l_rec IN limit_trans_cur(p_pricing_event_code)
  LOOP
    IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.engine_debug('***Deleting LimitbalanceId: '||l_rec.limit_balance_id||' pricereqcode '||l_rec.price_request_code);
    END IF;

    --For each transaction record selected in the cursor increment the
    --corresponding limit balance by the transaction amount
    Update_Balance(l_rec.amount, l_rec.limit_balance_id);

    --Then delete the transaction record
/*
INDX,qp_limit_transactions_pvt.delete.del1,QP_LIMIT_TRANSACTIONS_U1,PRICE_REQUEST_CODE,1
INDX,qp_limit_transactions_pvt.delete.del1,QP_LIMIT_TRANSACTIONS_U1,LIST_HEADER_ID,2
INDX,qp_limit_transactions_pvt.delete.del1,QP_LIMIT_TRANSACTIONS_U1,LIST_LINE_ID,3
INDX,qp_limit_transactions_pvt.delete.del1,QP_LIMIT_TRANSACTIONS_U1,LIMIT_BALANCE_ID,4
*/
    --sql statement del1
    DELETE FROM qp_limit_transactions
    WHERE  limit_balance_id = l_rec.limit_balance_id
    AND    list_header_id  = l_rec.list_header_id
    AND    list_line_id  = l_rec.list_line_id
    AND    price_request_code  = l_rec.price_request_code;

  END LOOP; --Loop over records in limit_trans_cur

  IF l_debug = FND_API.G_TRUE THEN
  QP_PREQ_GRP.engine_debug('***End Procedure Delete*** ');

  END IF;
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN

           x_return_status := FND_API.G_RET_STS_ERROR;

           IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
           THEN
               FND_MESSAGE.SET_NAME('QP','QP_INVALID_FORMULA');
           END IF;

--         RAISE;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

--         RAISE;

    WHEN OTHERS THEN
           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
           THEN
               FND_MSG_PUB.Add_Exc_Msg
                  (G_PKG_NAME
                  , 'Check Balance'
                  );
           END IF;

--         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Delete;

END QP_LIMIT_TRANSACTIONS_PVT;

/
