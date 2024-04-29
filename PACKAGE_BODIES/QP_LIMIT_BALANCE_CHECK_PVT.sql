--------------------------------------------------------
--  DDL for Package Body QP_LIMIT_BALANCE_CHECK_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_LIMIT_BALANCE_CHECK_PVT" AS
/* $Header: QPXVLCKB.pls 120.7.12010000.16 2017/04/04 06:50:34 jputta ship $ */


/**********************************************************************
   Utility Function to Update Limit Balance and the adjustment on the
   ldets table(s).
***********************************************************************/
     l_debug VARCHAR2(3);
PROCEDURE Build_Message_Text(p_List_Header_Id            IN      NUMBER
                            ,p_List_Line_Id              IN      NUMBER
                            ,p_Limit_Id                  IN      NUMBER
                            ,p_full_available_amount     IN      NUMBER
                            ,p_wanted_amount             IN      NUMBER
                            ,p_limit_code                IN      VARCHAR2           -- EXCEEDED or ADJUSTED
                            ,p_limit_level               IN      VARCHAR2           -- H or L
                            ,p_operand_value             IN      NUMBER
                            ,p_operand_calculation_code  IN      VARCHAR2
                            ,p_least_percent             IN      NUMBER
                            ,p_message_text              OUT NOCOPY    VARCHAR2
                            )
IS
l_modifier_name             VARCHAR2(240);
l_list_line_no              VARCHAR2(30);
l_limit_number              NUMBER;
l_message_text              VARCHAR2(2000);
l_limit_exceeded_by         NUMBER;
l_original_modifier_value   NUMBER := 0; --defined as number for bug 4912649 (10,2) := 0;
l_operator_name             VARCHAR2(80);
l_limit_msg_adj_val_prc     NUMBER := FND_PROFILE.VALUE('QP_LIMIT_MSG_ADJ_VAL_PRECISION');

BEGIN
   l_debug := QP_PREQ_GRP.G_DEBUG_ENGINE;

   IF l_debug = FND_API.G_TRUE THEN
     QP_PREQ_GRP.engine_debug('*** Entering Build_Message_Text ****');
     QP_PREQ_GRP.engine_debug('Limit Level '||p_limit_level);
   END IF;

   IF p_limit_level = 'H' THEN
     BEGIN
      select name into l_modifier_name from qp_list_headers_vl
      where list_header_id = p_List_Header_Id;
     EXCEPTION
      when no_data_found then
        IF l_debug = FND_API.G_TRUE THEN
          QP_PREQ_GRP.engine_debug('*** list header not found for id ***' || p_List_Header_Id);
        END IF;
     END;
   END IF;

   IF p_limit_level = 'L' THEN
     BEGIN
      select list_line_no into l_list_line_no from qp_list_lines
      where list_line_id = p_List_Line_Id;
     EXCEPTION
      when no_data_found then
        IF l_debug = FND_API.G_TRUE THEN
          QP_PREQ_GRP.engine_debug('*** list line not found for id ***' || p_List_Line_Id);
        END IF;
     END;
   END IF;

   BEGIN
   select limit_number into l_limit_number from qp_limits
   where limit_id = p_Limit_Id;
   EXCEPTION
    when no_data_found then
        IF l_debug = FND_API.G_TRUE THEN
          QP_PREQ_GRP.engine_debug('*** limit not found for id ***'||p_Limit_Id);
        END IF;
   END;

   BEGIN
   select meaning into l_operator_name from qp_lookups
   where LOOKUP_TYPE = 'ARITHMETIC_OPERATOR' and lookup_code = p_operand_calculation_code;
   EXCEPTION
    when no_data_found then
        IF l_debug = FND_API.G_TRUE THEN
          QP_PREQ_GRP.engine_debug('*** lookup code found ***');
        END IF;
   END;

   IF l_debug = FND_API.G_TRUE THEN
   QP_PREQ_GRP.engine_debug('######INSIDE BUILD_MESSAGE_TEXT######- ARITHMETIC_OPERATOR ' || p_operand_calculation_code);

   QP_PREQ_GRP.engine_debug('######INSIDE BUILD_MESSAGE_TEXT######- ARITHMETIC_OPERATOR ' || l_operator_name);

   END IF;
   l_limit_exceeded_by := p_wanted_amount - p_full_available_amount;
   l_original_modifier_value := (100 * p_operand_value)/p_least_percent;

   IF (p_limit_code = QP_PREQ_GRP.G_STATUS_LIMIT_EXCEEDED) THEN
      IF (p_limit_level = 'H') THEN
         FND_MESSAGE.SET_NAME('QP','QP_HEADER_LIMIT_EXCEEDED');
         FND_MESSAGE.SET_TOKEN('PROMOTION_NUMBER',l_modifier_name);
         FND_MESSAGE.SET_TOKEN('LIMIT_NUMBER',l_limit_number);
         FND_MESSAGE.SET_TOKEN('LIMIT_EXCEEDED_BY',nvl(l_limit_exceeded_by,0));
         l_message_text := FND_MESSAGE.GET;
      ELSIF (p_limit_level = 'L') THEN
         FND_MESSAGE.SET_NAME('QP','QP_LINE_LIMIT_EXCEEDED');
         FND_MESSAGE.SET_TOKEN('MODIFIER_NUMBER',l_list_line_no);
         FND_MESSAGE.SET_TOKEN('LIMIT_NUMBER',l_limit_number);
         FND_MESSAGE.SET_TOKEN('LIMIT_EXCEEDED_BY',nvl(l_limit_exceeded_by,0));
         l_message_text := FND_MESSAGE.GET;
      END IF;
   END IF;

   IF (p_limit_code = QP_PREQ_GRP.G_STATUS_LIMIT_ADJUSTED) THEN
      IF (p_limit_level = 'H') THEN
         FND_MESSAGE.SET_NAME('QP','QP_HEADER_LIMIT_ADJUSTED');
         FND_MESSAGE.SET_TOKEN('PROMOTION_NUMBER',l_modifier_name);
         FND_MESSAGE.SET_TOKEN('LIMIT_NUMBER',l_limit_number);
         IF (l_limit_msg_adj_val_prc IS NULL) THEN
			FND_MESSAGE.SET_TOKEN('OPERAND',l_original_modifier_value);
            FND_MESSAGE.SET_TOKEN('PERCENT',p_operand_value);
		 ELSE
            FND_MESSAGE.SET_TOKEN('OPERAND',round(l_original_modifier_value,l_limit_msg_adj_val_prc));
            FND_MESSAGE.SET_TOKEN('PERCENT',round(p_operand_value,l_limit_msg_adj_val_prc));
		 END IF;
         FND_MESSAGE.SET_TOKEN('OPERATOR',l_operator_name);
         l_message_text := FND_MESSAGE.GET;
      ELSIF (p_limit_level = 'L') THEN
         FND_MESSAGE.SET_NAME('QP','QP_LINE_LIMIT_ADJUSTED');
         FND_MESSAGE.SET_TOKEN('MODIFIER_NUMBER',l_list_line_no);
         FND_MESSAGE.SET_TOKEN('LIMIT_NUMBER',l_limit_number);
         IF (l_limit_msg_adj_val_prc IS NULL) THEN
            FND_MESSAGE.SET_TOKEN('OPERAND',l_original_modifier_value);
            FND_MESSAGE.SET_TOKEN('PERCENT',p_operand_value);
		 ELSE
		    FND_MESSAGE.SET_TOKEN('OPERAND',round(l_original_modifier_value,l_limit_msg_adj_val_prc));
            FND_MESSAGE.SET_TOKEN('PERCENT',round(p_operand_value,l_limit_msg_adj_val_prc));
		 END IF;
         FND_MESSAGE.SET_TOKEN('OPERATOR',l_operator_name);
         l_message_text := FND_MESSAGE.GET;
      END IF;
   END IF;

   p_message_text := l_message_text;

   IF l_debug = FND_API.G_TRUE THEN
     QP_PREQ_GRP.engine_debug('*** Leaving Build_Message_Text ****');
   END IF;

END Build_Message_Text;

FUNCTION Update_Balance (x_return_text OUT NOCOPY VARCHAR2)
RETURN VARCHAR2
IS
PRAGMA AUTONOMOUS_TRANSACTION;

l_percent             NUMBER := 100;
l_given_amount        NUMBER;

e_balance_not_available  EXCEPTION;
l_return_status       VARCHAR2(1);

BEGIN
  l_debug := QP_PREQ_GRP.G_DEBUG_ENGINE;
  IF l_debug = FND_API.G_TRUE THEN
  QP_PREQ_GRP.engine_debug('------------------------');
  QP_PREQ_GRP.engine_debug('***Begin Update_Balance***');

  END IF;
 IF g_limit_balance_line.COUNT > 0 THEN

  --Get the minimum available_percent across all limitbalances for a given line
  FOR i IN g_limit_balance_line.FIRST..g_limit_balance_line.LAST
  LOOP
    IF l_debug = FND_API.G_TRUE THEN
    QP_PREQ_GRP.engine_debug('Processing g_limit_balance_line ' || i);

    END IF;
    IF g_limit_balance_line(i).hard_limit_exceeded THEN
      IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.engine_debug('Hard Limit with 0 balance encountered. ' ||
         'Deleting all Balance lines for current list_line_id. ');
      END IF;
      g_limit_balance_line.DELETE; -- No need to process balances further
      l_return_status := FND_API.G_RET_STS_SUCCESS;
      RETURN l_return_status;
           --without updating any of the limits for current list_line_id
    END IF;

    l_percent := least(l_percent, g_limit_balance_line(i).available_percent);
    IF l_debug = FND_API.G_TRUE THEN
    QP_PREQ_GRP.engine_debug('least percent so far' || l_percent);
    END IF;
  END LOOP;

  --Perform Update or Insert into qp_limit_balances as required.
  FOR i IN g_limit_balance_line.FIRST..g_limit_balance_line.LAST
  LOOP
    IF l_debug = FND_API.G_TRUE THEN
    QP_PREQ_GRP.engine_debug('Processing limit '||g_limit_balance_line(i).limit_id);

    QP_PREQ_GRP.engine_debug('Limit Level Code '||
                               g_limit_balance_line(i).limit_level_code);
    QP_PREQ_GRP.engine_debug('Organization Context '||
         g_limit_balance_line(i).organization_attr_context);
    QP_PREQ_GRP.engine_debug('Organization Attribute '||
         g_limit_balance_line(i).organization_attribute);
    QP_PREQ_GRP.engine_debug('Organization Attr Value '||
         g_limit_balance_line(i).organization_attr_value);
    QP_PREQ_GRP.engine_debug('Multival Attr1 Context '||
         g_limit_balance_line(i).multival_attr1_context);
    QP_PREQ_GRP.engine_debug('Multival Attribute1 '||
         g_limit_balance_line(i).multival_attribute1);
    QP_PREQ_GRP.engine_debug('Multival Attr1 Value '||
         g_limit_balance_line(i).multival_attr1_value);
    QP_PREQ_GRP.engine_debug('Multival Attr2 Context '||
         g_limit_balance_line(i).multival_attr2_context);
    QP_PREQ_GRP.engine_debug('Multival Attribute2 '||
         g_limit_balance_line(i).multival_attribute2);
    QP_PREQ_GRP.engine_debug('Multival Attr2 Value '||
         g_limit_balance_line(i).multival_attr2_value);
    QP_PREQ_GRP.engine_debug('Balance Price Request Code '||
         g_limit_balance_line(i).bal_price_request_code);
    QP_PREQ_GRP.engine_debug('Amount Given '||l_given_amount);
    QP_PREQ_GRP.engine_debug('Limit Id '|| g_limit_balance_line(i).limit_id);
    QP_PREQ_GRP.engine_debug('Limit Balance Id '||
                                     g_limit_balance_line(i).limit_balance_id);


    END IF;

/* this code is to avoid decimal consumption in usage basis limits bug#20534445*/
	IF g_limit_balance_line(i).basis = 'USAGE' THEN
		l_given_amount := 1;
	ELSE
		l_given_amount := round((l_percent/100) * g_limit_balance_line(i).wanted_amount,2);
	END IF;
    --l_given_amount := round((l_percent/100) * g_limit_balance_line(i).wanted_amount,2);

    IF g_limit_balance_line(i).process_action = g_update THEN
      IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.engine_debug('Update Required');

      END IF;
      IF g_limit_balance_line(i).limit_level_code = 'ACROSS_TRANSACTION' THEN
/*
INDX,qp_limit_balance_check_pvt.update_balance.upd1,QP_LIMIT_BALANCES_U1,LIMIT_BALANCE_ID,1
*/
        --sql statement upd1
-- 9938422  limit available amount becomes zero when it is less than 0.04 with
      /*  UPDATE qp_limit_balances
        SET    available_amount = round(available_amount,2) - l_given_amount
                           + nvl(g_limit_balance_line(i).transaction_amount, 0),*/
	UPDATE qp_limit_balances
	SET    available_amount = DECODE (ROUND(round(available_amount,2) - l_given_amount
                           + nvl(g_limit_balance_line(i).transaction_amount, 0),1),0,0,round(available_amount,2) - l_given_amount
                           + nvl(g_limit_balance_line(i).transaction_amount, 0)),
               last_update_date = sysdate,
               last_updated_by = fnd_global.user_id
        WHERE  round(available_amount,2) >=
                   DECODE(g_limit_balance_line(i).limit_exceed_action_code,
                          'HARD', l_given_amount -
                             nvl(g_limit_balance_line(i).transaction_amount, 0),
                           -999999999999999999999999999
                          )
        AND    limit_balance_id = g_limit_balance_line(i).limit_balance_id;

      ELSIF g_limit_balance_line(i).limit_level_code = 'TRANSACTION' THEN
/*
INDX,qp_limit_balance_check_pvt.update_balance.upd2,QP_LIMIT_BALANCES_U1,LIMIT_BALANCE_ID,1
*/
        --sql statement upd2
	-- 9938422  limit available amount becomes zero when it is less than 0.04 with

        UPDATE qp_limit_balances
	SET    available_amount = DECODE (ROUND(round(available_amount,2) - l_given_amount
                           + nvl(g_limit_balance_line(i).transaction_amount, 0),1),0,0,round(available_amount,2) - l_given_amount
                           + nvl(g_limit_balance_line(i).transaction_amount, 0)),
               last_update_date = sysdate,
               last_updated_by = fnd_global.user_id
        WHERE  round(available_amount,2) >=
                   DECODE(g_limit_balance_line(i).limit_exceed_action_code,
                          'HARD',l_given_amount -
                             nvl(g_limit_balance_line(i).transaction_amount, 0),
                           -99999999999999999999999999999
                          )
        AND    limit_balance_id = g_limit_balance_line(i).limit_balance_id
        AND    price_request_code =
                     g_limit_balance_line(i).bal_price_request_code;
     /*   UPDATE qp_limit_balances
        SET    available_amount = round(available_amount,2) - l_given_amount
                           + nvl(g_limit_balance_line(i).transaction_amount, 0),
               last_update_date = sysdate,
               last_updated_by = fnd_global.user_id
        WHERE  round(available_amount,2) >=
                   DECODE(g_limit_balance_line(i).limit_exceed_action_code,
                          'HARD',l_given_amount -
                             nvl(g_limit_balance_line(i).transaction_amount, 0),
                           -99999999999999999999999999999
                          )
        AND    limit_balance_id = g_limit_balance_line(i).limit_balance_id
        AND    price_request_code =
                     g_limit_balance_line(i).bal_price_request_code;  */

      END IF; --If limit_level_code = 'ACROSS_TRANSACTION'

      --Calculated Limit Balance no longer available. Raise error.
      IF SQL%ROWCOUNT = 0 THEN
        IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.engine_debug('Balance no longer available ');
        END IF;
        RAISE E_BALANCE_NOT_AVAILABLE;
      END IF;

    ELSIF g_limit_balance_line(i).process_action = g_insert THEN
      IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.engine_debug('Insert Required');

      QP_PREQ_GRP.engine_debug('given_amount '|| l_given_amount);
      QP_PREQ_GRP.engine_debug('transaction_amount '||
                          nvl(g_limit_balance_line(i).transaction_amount, 0));

      END IF;
      INSERT INTO qp_limit_balances
        (limit_id,
         limit_balance_id,
         creation_date,
         created_by,
         last_update_date,
         last_updated_by,
         available_amount,
         reserved_amount,
         consumed_amount,
         organization_attr_context,
         organization_attribute,
         organization_attr_value,
         multival_attr1_context,
         multival_attribute1,
         multival_attr1_value,
         multival_attr1_type,
         multival_attr1_datatype,
         multival_attr2_context,
         multival_attribute2,
         multival_attr2_value,
         multival_attr2_type,
         multival_attr2_datatype,
         price_request_code
        )
      VALUES
        (g_limit_balance_line(i).limit_id,
         g_limit_balance_line(i).limit_balance_id,
         sysdate,
         fnd_global.user_id,
         sysdate,
         fnd_global.user_id,
         DECODE(ROUND(g_limit_balance_line(i).limit_amount - l_given_amount
                          + nvl(g_limit_balance_line(i).transaction_amount, 0),1),0,0,g_limit_balance_line(i).limit_amount - l_given_amount
                          + nvl(g_limit_balance_line(i).transaction_amount, 0)),
         0,
         0,
         g_limit_balance_line(i).organization_attr_context,
         g_limit_balance_line(i).organization_attribute,
         g_limit_balance_line(i).organization_attr_value,
         g_limit_balance_line(i).multival_attr1_context,
         g_limit_balance_line(i).multival_attribute1,
         g_limit_balance_line(i).multival_attr1_value,
         g_limit_balance_line(i).multival_attr1_type,
         g_limit_balance_line(i).multival_attr1_datatype,
         g_limit_balance_line(i).multival_attr2_context,
         g_limit_balance_line(i).multival_attribute2,
         g_limit_balance_line(i).multival_attr2_value,
         g_limit_balance_line(i).multival_attr2_type,
         g_limit_balance_line(i).multival_attr2_datatype,
         g_limit_balance_line(i).bal_price_request_code
        );

    END IF;

    IF l_debug = FND_API.G_TRUE THEN
    QP_PREQ_GRP.engine_debug('amount given'||l_given_amount);
    END IF;
    g_limit_balance_line(i).given_amount := l_given_amount;
    g_limit_balance_line(i).least_percent := l_percent;


    IF g_limit_balance_line(i).created_from_list_line_type IN
            ('DIS', 'SUR', 'FREIGHT_CHARGE', 'PBH')
    AND g_limit_balance_line(i).operand_calculation_code IN
            ('%', 'AMT', 'LUMPSUM')
    THEN
      g_limit_balance_line(i).operand_value :=
              (l_percent/100) * g_limit_balance_line(i).operand_value;

    ELSIF g_limit_balance_line(i).created_from_list_line_type IN
            ('DIS', 'SUR', 'FREIGHT_CHARGE', 'PBH')
    AND   g_limit_balance_line(i).operand_calculation_code = 'NEWPRICE'
    THEN
      g_limit_balance_line(i).operand_value :=
              g_limit_balance_line(i).operand_value -
              (100 - l_percent)/100 * g_limit_balance_line(i).adjustment_amount;

    END IF;

    IF g_limit_balance_line(i).created_from_list_line_type IN
            ('DIS', 'SUR', 'FREIGHT_CHARGE', 'PBH')
    AND g_limit_balance_line(i).basis = 'ACCRUAL'
    THEN
      g_limit_balance_line(i).benefit_qty :=
              (l_percent/100) * g_limit_balance_line(i).benefit_qty;
    END IF;

  END LOOP;

 END IF; --g_limit_balance_line.COUNT > 0

  COMMIT;

  IF l_debug = FND_API.G_TRUE THEN
  QP_PREQ_GRP.engine_debug('***End Update_Balance***');
  QP_PREQ_GRP.engine_debug('------------------------');

  END IF;
  l_return_status := FND_API.G_RET_STS_SUCCESS;
  x_return_text := 'Success';

  RETURN l_return_status;

EXCEPTION
 WHEN DUP_VAL_ON_INDEX THEN
   IF l_debug = FND_API.G_TRUE THEN
   QP_PREQ_GRP.engine_debug('Insert Failed with Duplicate Value on Index');
   END IF;
   l_return_status := FND_API.G_RET_STS_ERROR;
   x_return_text := 'Insert Failed with Duplicate Value on Index error ' ||
                    'in procedure Update_Balance';
   ROLLBACK;
   RETURN l_return_status;

 WHEN E_BALANCE_NOT_AVAILABLE THEN
   IF l_debug = FND_API.G_TRUE THEN
   QP_PREQ_GRP.engine_debug('Limit Balance no longer available.Update Failed.');
   END IF;
   l_return_status := FND_API.G_RET_STS_ERROR;
   x_return_text := 'Update Failed in procedure Update_Balance because ' ||
                    'Limit Balance no longer available';
   ROLLBACK;
   RETURN l_return_status;

 WHEN OTHERS THEN
   IF l_debug = FND_API.G_TRUE THEN
   QP_PREQ_GRP.engine_debug('Other Exception in Update_Balance');
   QP_PREQ_GRP.engine_debug(substr(sqlerrm, 1, 240));
   END IF;
   l_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   x_return_text := substr(sqlerrm, 1, 2000);
   ROLLBACK;
   RETURN l_return_status;

END Update_Balance;


/***********************************************************************
   Utility Function to recalculate available balance before updating the
   limit_balance table. Called after update_balance fails the first time.
***********************************************************************/

FUNCTION Recheck_Balance
RETURN BOOLEAN
IS
l_full_available_amount  NUMBER := 0;
l_message                VARCHAR2(240);

BEGIN

 l_debug := QP_PREQ_GRP.G_DEBUG_ENGINE;
 --Increment the recheck loop count everytime the Function is entered.
 G_LOOP_COUNT := G_LOOP_COUNT + 1;

  IF l_debug = FND_API.G_TRUE THEN
  QP_PREQ_GRP.engine_debug('***Begin Recheck_Balance***');

  END IF;
 IF g_limit_balance_line.COUNT > 0 THEN

  FOR i IN g_limit_balance_line.FIRST..g_limit_balance_line.LAST
  LOOP
    IF g_limit_balance_line(i).each_attr_exists = 'N' THEN
      IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.engine_debug('Each attr does not exist');
      END IF;
      BEGIN

        IF g_limit_balance_line(i).limit_level_code = 'ACROSS_TRANSACTION' THEN
/*
INDX,qp_limit_balance_check_pvt.recheck_balance.sel1,QP_LIMIT_BALANCES_U2,LIMIT_ID,1
*/
          --sql statement sel1
          SELECT available_amount
          INTO   l_full_available_amount
          FROM   qp_limit_balances
          WHERE  limit_id = g_limit_balance_line(i).limit_id;

        ELSIF g_limit_balance_line(i).limit_level_code = 'TRANSACTION' THEN
/*
INDX,qp_limit_balance_check_pvt.recheck_balance.sel2,QP_LIMIT_BALANCES_N1,LIMIT_ID,1
INDX,qp_limit_balance_check_pvt.recheck_balance.sel2,QP_LIMIT_BALANCES_N1,PRICE_REQUEST_CODE,2
*/
          --sql statement sel2
          SELECT available_amount
          INTO   l_full_available_amount
          FROM   qp_limit_balances
          WHERE  limit_id = g_limit_balance_line(i).limit_id
          AND    price_request_code =
                     g_limit_balance_line(i).bal_price_request_code;

        END IF; --IF limit_level_code = 'ACROSS_TRANSACTION'

      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          l_full_available_amount := g_limit_balance_line(i).limit_amount;
          g_limit_balance_line(i).process_action := g_insert;

        WHEN TOO_MANY_ROWS THEN
          IF l_debug = FND_API.G_TRUE THEN
          QP_PREQ_GRP.engine_debug(substr(sqlerrm, 1, 240));

          END IF;
          IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
            FND_MESSAGE.SET_NAME('QP','QP_MULT_LIMIT_BALANCES');
            FND_MESSAGE.SET_TOKEN('LIMIT', g_limit_balance_line(i).limit_id);
            l_message := FND_MESSAGE.GET;

            --Update the lines_tmp table with the translated error message.
/*
INDX,qp_limit_balance_check_pvt.recheck_balance.upd1,qp_npreq_lines_tmp_N1,LINE_INDEX,1
*/
            --sql statement upd1
            UPDATE qp_npreq_lines_tmp
            SET    pricing_status_text = l_message,
                   pricing_status_code = QP_PREQ_GRP.G_STATUS_OTHER_ERRORS
            WHERE  line_index = g_limit_balance_line(i).line_index;

            --Update the ldets_tmp table with the translated error message.
/*
INDX,qp_limit_balance_check_pvt.recheck_balance.upd2,qp_npreq_ldets_tmp_N1,LINE_INDEX,1
INDX,qp_limit_balance_check_pvt.recheck_balance.upd2,qp_npreq_ldets_tmp_N1,CREATED_FROM_LIST_LINE_ID,5
*/
            --sql statement upd2
            UPDATE qp_npreq_ldets_tmp
            SET    pricing_status_text = l_message,
                   pricing_status_code = QP_PREQ_GRP.G_STATUS_OTHER_ERRORS
            WHERE  line_index = g_limit_balance_line(i).line_index
            AND    created_from_list_line_id =
                          g_limit_balance_line(i).list_line_id;

            IF l_debug = FND_API.G_TRUE THEN
            QP_PREQ_GRP.engine_debug(l_message);

            END IF;
          END IF;

          --Set the hard_limit_exceeded flag to true. So that the record in
          --ldets_tmp table is set to deleted status.
          g_limit_balance_line(i).hard_limit_exceeded := TRUE;
          RAISE;

        WHEN OTHERS THEN
          IF l_debug = FND_API.G_TRUE THEN
          QP_PREQ_GRP.engine_debug(substr(sqlerrm, 1, 240));

          END IF;
          IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
            FND_MESSAGE.SET_NAME('QP','QP_ERROR_IN_LIMIT_PROCESSING');
            l_message := FND_MESSAGE.GET;

            --Update the lines_tmp table with the translated error message.
/*
INDX,qp_limit_balance_check_pvt.recheck_balance.upd3,qp_npreq_lines_tmp_N1,LINE_INDEX,1
*/
            --sql statement upd3
            UPDATE qp_npreq_lines_tmp
            SET    pricing_status_text = l_message,
                   pricing_status_code = QP_PREQ_GRP.G_STATUS_OTHER_ERRORS
            WHERE  line_index = g_limit_balance_line(i).line_index;

            --Update the ldets_tmp table with the translated error message.
/*
INDX,qp_limit_balance_check_pvt.recheck_balance.upd4,qp_npreq_ldets_tmp_N1,LINE_INDEX,1
INDX,qp_limit_balance_check_pvt.recheck_balance.upd4,qp_npreq_ldets_tmp_N1,CREATED_FROM_LIST_LINE_ID,5
*/
            --sql statement upd4
            UPDATE qp_npreq_ldets_tmp
            SET    pricing_status_text = l_message,
                   pricing_status_code = QP_PREQ_GRP.G_STATUS_OTHER_ERRORS
            WHERE  line_index = g_limit_balance_line(i).line_index
            AND    created_from_list_line_id =
                          g_limit_balance_line(i).list_line_id;

            IF l_debug = FND_API.G_TRUE THEN
            QP_PREQ_GRP.engine_debug(l_message);

            END IF;
          END IF;

          --Set the hard_limit_exceeded flag to true. So that the record in
          --ldets_tmp table is set to deleted status.
          g_limit_balance_line(i).hard_limit_exceeded := TRUE;
          RAISE;

      END;--End of Block around Select Stmt when limit does not have each attrs

    ELSIF g_limit_balance_line(i).each_attr_exists = 'Y' THEN
      IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.engine_debug('Each attr exists');
      END IF;
      BEGIN

        IF g_limit_balance_line(i).limit_level_code = 'ACROSS_TRANSACTION' THEN
/*
INDX,qp_limit_balance_check_pvt.recheck_balance.sel3,QP_LIMIT_BALANCES_U1,LIMIT_BALANCE_ID,1
*/
          --sql statement sel3
          SELECT available_amount
          INTO   l_full_available_amount
          FROM   qp_limit_balances
          WHERE  limit_balance_id = g_limit_balance_line(i).limit_balance_id;

        ELSIF g_limit_balance_line(i).limit_level_code = 'TRANSACTION' THEN
/*
INDX,qp_limit_balance_check_pvt.recheck_balance.sel4,QP_LIMIT_BALANCES_N1,LIMIT_ID,1
INDX,qp_limit_balance_check_pvt.recheck_balance.sel4,QP_LIMIT_BALANCES_N1,PRICE_REQUEST_CODE,2
*/
          --sql statement sel4
          SELECT available_amount
          INTO   l_full_available_amount
          FROM   qp_limit_balances
          WHERE  limit_id = g_limit_balance_line(i).limit_id
          AND    price_request_code =
                     g_limit_balance_line(i).bal_price_request_code;

        END IF; --IF limit_level_code = 'ACROSS_TRANSACTION'

      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          l_full_available_amount := g_limit_balance_line(i).limit_amount;
          g_limit_balance_line(i).process_action := g_insert;

        WHEN TOO_MANY_ROWS THEN
          IF l_debug = FND_API.G_TRUE THEN
          QP_PREQ_GRP.engine_debug(substr(sqlerrm, 1, 240));

          END IF;
          IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
            FND_MESSAGE.SET_NAME('QP','QP_MULT_LIMIT_BALANCES');
            FND_MESSAGE.SET_TOKEN('LIMIT', g_limit_balance_line(i).limit_id);
            l_message := FND_MESSAGE.GET;

            --Update the lines_tmp table with the translated error message.
/*
INDX,qp_limit_balance_check_pvt.recheck_balance.upd5,qp_npreq_lines_tmp_N1,LINE_INDEX,1
*/
            --sql statement upd5
            UPDATE qp_npreq_lines_tmp
            SET    pricing_status_text = l_message,
                   pricing_status_code = QP_PREQ_GRP.G_STATUS_OTHER_ERRORS
            WHERE  line_index = g_limit_balance_line(i).line_index;

            --Update the ldets_tmp table with the translated error message.
/*
INDX,qp_limit_balance_check_pvt.recheck_balance.upd6,qp_npreq_ldets_tmp_N1,LINE_INDEX,1
INDX qp_limit_balance_check_pvt.recheck_balance.upd6,qp_npreq_ldets_tmp_N1,CREATED_FROM_LIST_LINE_ID,5
*/
            --sql statement upd6
            UPDATE qp_npreq_ldets_tmp
            SET    pricing_status_text = l_message,
                   pricing_status_code = QP_PREQ_GRP.G_STATUS_OTHER_ERRORS
            WHERE  line_index = g_limit_balance_line(i).line_index
            AND    created_from_list_line_id =
                          g_limit_balance_line(i).list_line_id;

            IF l_debug = FND_API.G_TRUE THEN
            QP_PREQ_GRP.engine_debug(l_message);

            END IF;
          END IF;

          --Set the hard_limit_exceeded flag to true. So that the record in
          --ldets_tmp table is set to deleted status.
          g_limit_balance_line(i).hard_limit_exceeded := TRUE;
          RAISE;

        WHEN OTHERS THEN
          IF l_debug = FND_API.G_TRUE THEN
          QP_PREQ_GRP.engine_debug(substr(sqlerrm, 1, 240));

          END IF;
          IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
            FND_MESSAGE.SET_NAME('QP','QP_ERROR_IN_LIMIT_PROCESSING');
            l_message := FND_MESSAGE.GET;

            --Update the lines_tmp table with the translated error message.
/*
INDX,qp_limit_balance_check_pvt.recheck_balance.upd7,qp_npreq_lines_tmp_N1,LINE_INDEX,1
*/
            --sql statement upd7
            UPDATE qp_npreq_lines_tmp
            SET    pricing_status_text = l_message,
                   pricing_status_code = QP_PREQ_GRP.G_STATUS_OTHER_ERRORS
            WHERE  line_index = g_limit_balance_line(i).line_index;

            --Update the ldets_tmp table with the translated error message.
/*
INDX,qp_limit_balance_check_pvt.recheck_balance.upd8,qp_npreq_ldets_tmp_N1,LINE_INDEX,1
INDX,qp_limit_balance_check_pvt.recheck_balance.upd8,qp_npreq_ldets_tmp_N1,CREATED_FROM_LIST_LINE_ID,5
*/
            --sql statement upd8
            UPDATE qp_npreq_ldets_tmp
            SET    pricing_status_text = l_message,
                   pricing_status_code = QP_PREQ_GRP.G_STATUS_OTHER_ERRORS
            WHERE  line_index = g_limit_balance_line(i).line_index
            AND    created_from_list_line_id =
                          g_limit_balance_line(i).list_line_id;

            IF l_debug = FND_API.G_TRUE THEN
            QP_PREQ_GRP.engine_debug(l_message);

            END IF;
          END IF;

          --Set the hard_limit_exceeded flag to true. So that the record in
          --ldets_tmp table is set to deleted status.
          g_limit_balance_line(i).hard_limit_exceeded := TRUE;
          RAISE;

      END;--End of Block around Select Stmt when limit has each attrs

    END IF; --If each_attr_exists

    IF l_debug = FND_API.G_TRUE THEN
    QP_PREQ_GRP.engine_debug('Action to take '||g_limit_balance_line(i).process_action);

    END IF;
    --Check the Limit Transaction Table to see if the same request has a
    --record. If so, this is a repricing request so populate the
    --transaction_amount in the balanceline plsql table for later use.
    BEGIN
/*
INDX,qp_limit_balance_check_pvt.recheck_balance.sel5,QP_LIMIT_TRANSACTIONS_U1,PRICE_REQUEST_CODE,1
INDX,qp_limit_balance_check_pvt.recheck_balance.sel5,QP_LIMIT_TRANSACTIONS_U1,LIST_HEADER_ID,2
INDX,qp_limit_balance_check_pvt.recheck_balance.sel5,QP_LIMIT_TRANSACTIONS_U1,LIST_LINE_ID,3
INDX,qp_limit_balance_check_pvt.recheck_balance.sel5,QP_LIMIT_TRANSACTIONS_U1,LIMIT_BALANCE_ID,4
*/
      --sql statement sel5
      SELECT amount
      INTO   g_limit_balance_line(i).transaction_amount
      FROM   qp_limit_transactions
      WHERE  price_request_code = g_limit_balance_line(i).price_request_code
      AND    list_header_id = g_limit_balance_line(i).list_header_id
      AND    list_line_id = g_limit_balance_line(i).list_line_id
      AND    limit_balance_id = g_limit_balance_line(i).limit_balance_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        g_limit_balance_line(i).transaction_amount := null;
    END;


    --Increment the full_available_amount by the transaction_amount
    l_full_available_amount := l_full_available_amount +
                         nvl(g_limit_balance_line(i).transaction_amount, 0);

    g_limit_balance_line(i).full_available_amount := l_full_available_amount;

    --fix for bug 4765137 to remove the modifier if limit balance is zero or
    --negative for a hard limit on new or repriced orders
    IF l_full_available_amount <= 0 AND
       g_limit_balance_line(i).limit_exceed_action_code = 'HARD'
    THEN
      g_limit_balance_line(i).hard_limit_exceeded := TRUE;
      RETURN FALSE;
    END IF;

    IF g_limit_balance_line(i).limit_exceed_action_code = 'HARD' THEN

      g_limit_balance_line(i).available_amount :=
          least(l_full_available_amount, g_limit_balance_line(i).wanted_amount);

--10023220
      IF g_limit_balance_line(i).wanted_amount > l_full_available_amount AND ((g_limit_balance_line(i).wanted_amount - l_full_available_amount) NOT BETWEEN  0 AND 0.1 ) THEN
        g_limit_balance_line(i).limit_code :=
                   QP_PREQ_GRP.G_STATUS_LIMIT_ADJUSTED;
      ELSE
        g_limit_balance_line(i).limit_code :=
                   QP_PREQ_GRP.G_STATUS_LIMIT_CONSUMED;
      END IF; --if p_wanted_amount > l_full_available_amount

    ELSE --Soft Limit

      g_limit_balance_line(i).available_amount :=
                g_limit_balance_line(i).wanted_amount;

      IF g_limit_balance_line(i).line_category = 'RETURN' THEN

         g_limit_balance_line(i).limit_code :=
                QP_PREQ_GRP.G_STATUS_LIMIT_CONSUMED;

      ELSE --If line_category is not 'RETURN'

         IF g_limit_balance_line(i).wanted_amount > l_full_available_amount
         THEN
           g_limit_balance_line(i).limit_code :=
                      QP_PREQ_GRP.G_STATUS_LIMIT_EXCEEDED;
         ELSE
           g_limit_balance_line(i).limit_code :=
                      QP_PREQ_GRP.G_STATUS_LIMIT_CONSUMED;
         END IF; --If wanted_amount > l_full_available_amount

      END IF;--If line_category is 'RETURN'

    END IF;--Hard or Soft limit

    IF g_limit_balance_line(i).wanted_amount <> 0 THEN
       g_limit_balance_line(i).available_percent :=
        ABS(g_limit_balance_line(i).available_amount/
            g_limit_balance_line(i).wanted_amount) * 100;
    ELSE
      g_limit_balance_line(i).available_percent := 100;
    END IF;

    g_limit_balance_line(i).hard_limit_exceeded := FALSE;
    RETURN TRUE;

  END LOOP; --over the g_limit_balance_lines

 END IF; --g_limit_balance_line.COUNT > 0

  IF l_debug = FND_API.G_TRUE THEN
  QP_PREQ_GRP.engine_debug('***End Recheck_Balance***');

  END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF l_debug = FND_API.G_TRUE THEN
    QP_PREQ_GRP.engine_debug(substr(sqlerrm, 1, 240));
    END IF;
    RETURN FALSE;
END Recheck_Balance;


/**********************************************************************
   Utility Function to Populate a pl/sql table with information on the
   the Limit, Limit Balance, etc. so that the main procedure Process_Limits
   can process the limits. Returns TRUE/FALSE if limit is available/not.
***********************************************************************/
FUNCTION Check_Balance(p_limit_rec           IN   Limit_Rec,
                       p_wanted_amount       IN   NUMBER,
                       x_skip_limit          OUT  NOCOPY BOOLEAN)
RETURN BOOLEAN
IS

l_limit_balance_line     Limit_Balance_Line_Tbl;
i                        INTEGER;
l_full_available_amount  NUMBER;
l_message                VARCHAR2(240);

/*
INDX,qp_limit_balance_check_pvt.check_balance.request_attr_cur,qp_npreq_line_attrs_tmp_N2,PRICING_STATUS_CODE,1
INDX,qp_limit_balance_check_pvt.check_balance.request_attr_cur,qp_npreq_line_attrs_tmp_N2,CONTEXT,3
INDX,qp_limit_balance_check_pvt.check_balance.request_attr_cur,qp_npreq_line_attrs_tmp_N2,ATTRIBUTE,4
INDX,qp_limit_balance_check_pvt.check_balance.request_attr_cur,qp_npreq_line_attrs_tmp_N2,LINE_INDEX,6
*/
CURSOR request_attr_cur(a_line_index NUMBER, a_context VARCHAR2,
                        a_attribute VARCHAR2)
IS
  SELECT context, attribute, value_from, attribute_type, datatype
  FROM   qp_npreq_line_attrs_tmp
  WHERE  line_index = a_line_index
  AND    context = a_context
  AND    attribute = a_attribute
  AND    pricing_status_code = QP_PREQ_GRP.G_STATUS_UNCHANGED;

TYPE each_attr_rec_type IS RECORD
(context         VARCHAR2(30),
 attribute       VARCHAR2(30),
 value           VARCHAR2(240)
);

TYPE each_attr_table_type IS TABLE OF each_attr_rec_type
  INDEX BY BINARY_INTEGER;

l_org_table      each_attr_table_type;
l_cust_table     each_attr_table_type;
l_item_table     each_attr_table_type;

i1               NUMBER := 1;
i2               NUMBER := 1;
i3               NUMBER := 1;

E_ORDER_PRICE_REQ_CODE_NULL    EXCEPTION;

BEGIN

  l_debug := QP_PREQ_GRP.G_DEBUG_ENGINE;
  IF l_debug = FND_API.G_TRUE THEN
  QP_PREQ_GRP.engine_debug('***Begin Check_Balance***');
  END IF;
  IF g_Limit_balance_line.COUNT = 0 THEN
    i:=1;
  ELSE
    i := g_limit_balance_line.LAST + 1;
  END IF;
  x_skip_limit := FALSE;

  IF l_debug = FND_API.G_TRUE THEN
  QP_PREQ_GRP.engine_debug('populating limit_balance_line '||i);
  QP_PREQ_GRP.engine_debug('limit_id '||p_limit_rec.limit_id);

  END IF;
  IF p_limit_rec.each_attr_exists = 'N'  THEN
  --If limit has no each (pure non-each) or no attributes
  --(For such cases a balance record will always exist since setup creates one)
    IF l_debug = FND_API.G_TRUE THEN
    QP_PREQ_GRP.engine_debug('No Each-type attributes defined for this limit');

    END IF;
    g_limit_balance_line(i).limit_id := p_limit_rec.limit_id;
    g_limit_balance_line(i).line_index := p_limit_rec.line_index;
    g_limit_balance_line(i).list_header_id :=
                                   p_limit_rec.created_from_list_header_id;
    g_limit_balance_line(i).list_line_id :=
                                   p_limit_rec.created_from_list_line_id;
    g_limit_balance_line(i).wanted_amount := p_wanted_amount;
    g_limit_balance_line(i).each_attr_exists := p_limit_rec.each_attr_exists;
    g_limit_balance_line(i).limit_amount := p_limit_rec.amount;
    g_limit_balance_line(i).basis := p_limit_rec.basis;
    g_limit_balance_line(i).limit_exceed_action_code :=
                                   p_limit_rec.limit_exceed_action_code;
    g_limit_balance_line(i).adjustment_amount := p_limit_rec.adjustment_amount;
    g_limit_balance_line(i).operand_value := p_limit_rec.operand_value;
    g_limit_balance_line(i).benefit_qty := p_limit_rec.benefit_qty;
    g_limit_balance_line(i).created_from_list_line_type :=
                                   p_limit_rec.created_from_list_line_type;
    g_limit_balance_line(i).pricing_group_sequence :=
                                   p_limit_rec.pricing_group_sequence;
    g_limit_balance_line(i).operand_calculation_code :=
                                   p_limit_rec.operand_calculation_code;
    g_limit_balance_line(i).limit_level := p_limit_rec.limit_level;
    g_limit_balance_line(i).limit_hold_flag := p_limit_rec.limit_hold_flag;
    --Populate bal_price_request_code for limit_balances table
    IF p_limit_rec.limit_level_code = 'ACROSS_TRANSACTION' THEN
      g_limit_balance_line(i).bal_price_request_code :=  NULL;
    ELSIF p_limit_rec.limit_level_code = 'TRANSACTION' THEN
      g_limit_balance_line(i).bal_price_request_code :=
                                   QP_PREQ_GRP.G_ORDER_PRICE_REQUEST_CODE;
    END IF; --If limit_level_code  = 'ACROSS_TRANSACTION'
    IF l_debug = FND_API.G_TRUE THEN
    QP_PREQ_GRP.engine_debug('bal_price_request_code '||
                   g_limit_balance_line(i).bal_price_request_code);
    END IF;
    --Populate price_request_code from limits_cur for limit_transns table
    g_limit_balance_line(i).price_request_code :=
                                   p_limit_rec.price_request_code;
    g_limit_balance_line(i).request_type_code := p_limit_rec.request_type_code;
    g_limit_balance_line(i).line_category := p_limit_rec.line_category;
    g_limit_balance_line(i).pricing_phase_id := p_limit_rec.pricing_phase_id;
    g_limit_balance_line(i).limit_level_code := p_limit_rec.limit_level_code;
    g_limit_balance_line(i).line_detail_index := p_limit_rec.line_detail_index;

    BEGIN

      IF  p_limit_rec.limit_level_code = 'ACROSS_TRANSACTION' THEN
/*
INDX,qp_limit_balance_check_pvt.check_balance.sel1,QP_LIMIT_BALANCES_U2,LIMIT_ID,1
*/
        --sql statement sel1
        SELECT available_amount, limit_balance_id
        INTO   l_full_available_amount, g_limit_balance_line(i).limit_balance_id
        FROM   qp_limit_balances
        WHERE  limit_id = p_limit_rec.limit_id;

      ELSIF  p_limit_rec.limit_level_code = 'TRANSACTION' THEN
/*
INDX,qp_limit_balance_check_pvt.check_balance.sel2,QP_LIMIT_BALANCES_N1,LIMIT_ID,1
INDX,qp_limit_balance_check_pvt.check_balance.sel2,QP_LIMIT_BALANCES_N1,PRICE_REQUEST_CODE,2
*/

        --If g_order_price_request_code is null then raise an error.
        IF QP_PREQ_GRP.G_ORDER_PRICE_REQUEST_CODE IS NULL THEN
          RAISE E_ORDER_PRICE_REQ_CODE_NULL;
        END IF;

        --sql statement sel2
        SELECT available_amount, limit_balance_id
        INTO   l_full_available_amount, g_limit_balance_line(i).limit_balance_id
        FROM   qp_limit_balances
        WHERE  limit_id = p_limit_rec.limit_id
        AND    price_request_code =
                      g_limit_balance_line(i).bal_price_request_code;

      END IF; --If limit_level_code is 'ACROSS_TRANSACTION'

      g_limit_balance_line(i).process_action := g_update;

      IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.engine_debug('Available Balance '|| l_full_available_amount);

      END IF;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
         select qp_limit_balances_s.nextval
         into g_limit_balance_line(i).limit_balance_id from dual;
         l_full_available_amount := p_limit_rec.amount;
         g_limit_balance_line(i).process_action := g_insert;
         IF l_debug = FND_API.G_TRUE THEN
         QP_PREQ_GRP.engine_debug('Balance Record Missing');

         END IF;
      WHEN E_ORDER_PRICE_REQ_CODE_NULL THEN

         IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
         THEN
           FND_MESSAGE.SET_NAME('QP','QP_ORDER_PRICE_REQ_CODE_NULL');
           l_message := FND_MESSAGE.GET;

           --Update the lines_tmp table with the translated error message.
/*
INDX,qp_limit_balance_check_pvt.check_balance.upd9,qp_npreq_lines_tmp_N1,LINE_INDEX,1
*/
           --sql statement upd9
           UPDATE qp_npreq_lines_tmp
           SET    pricing_status_text = l_message,
                  pricing_status_code = QP_PREQ_GRP.G_STATUS_OTHER_ERRORS
           WHERE  line_index = g_limit_balance_line(i).line_index;

           --Update the ldets_tmp table with the translated error message.
/*
INDX,qp_limit_balance_check_pvt.check_balance.upd10,qp_npreq_ldets_tmp_N1,LINE_INDEX,1
INDX,qp_limit_balance_check_pvt.check_balance.upd10,qp_npreq_ldets_tmp_N1,CREATED_FROM_LIST_LINE_ID,5
*/
           --sql statement upd10
           UPDATE qp_npreq_ldets_tmp
           SET    pricing_status_text = l_message,
                  pricing_status_code = QP_PREQ_GRP.G_STATUS_OTHER_ERRORS
           WHERE  line_index = g_limit_balance_line(i).line_index
           AND    created_from_list_line_id =
                         g_limit_balance_line(i).list_line_id;

           IF l_debug = FND_API.G_TRUE THEN
           QP_PREQ_GRP.engine_debug(l_message);

           END IF;
         END IF;

      WHEN TOO_MANY_ROWS THEN
         IF l_debug = FND_API.G_TRUE THEN
         QP_PREQ_GRP.engine_debug(substr(sqlerrm, 1, 240));

         END IF;
         IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
         THEN
           FND_MESSAGE.SET_NAME('QP','QP_MULT_LIMIT_BALANCES');
           FND_MESSAGE.SET_TOKEN('LIMIT', g_limit_balance_line(i).limit_id);
           l_message := FND_MESSAGE.GET;

           --Update the lines_tmp table with the translated error message.
/*
INDX,qp_limit_balance_check_pvt.check_balance.upd1,qp_npreq_lines_tmp_N1,LINE_INDEX,1
*/
           --sql statement upd1
           UPDATE qp_npreq_lines_tmp
           SET    pricing_status_text = l_message,
                  pricing_status_code = QP_PREQ_GRP.G_STATUS_OTHER_ERRORS
           WHERE  line_index = g_limit_balance_line(i).line_index;

           --Update the ldets_tmp table with the translated error message.
/*
INDX,qp_limit_balance_check_pvt.check_balance.upd2,qp_npreq_ldets_tmp_N1,LINE_INDEX,1
INDX,qp_limit_balance_check_pvt.check_balance.upd2,qp_npreq_ldets_tmp_N1,CREATED_FROM_LIST_LINE_ID,5
*/
           --sql statement upd2
           UPDATE qp_npreq_ldets_tmp
           SET    pricing_status_text = l_message,
                  pricing_status_code = QP_PREQ_GRP.G_STATUS_OTHER_ERRORS
           WHERE  line_index = g_limit_balance_line(i).line_index
           AND    created_from_list_line_id =
                         g_limit_balance_line(i).list_line_id;

           IF l_debug = FND_API.G_TRUE THEN
           QP_PREQ_GRP.engine_debug(l_message);

           END IF;
         END IF;

         --Set the hard_limit_exceeded flag to true. So that the record in
         --ldets_tmp table is set to deleted status.
         g_limit_balance_line(i).hard_limit_exceeded := TRUE;
         RAISE;

     WHEN OTHERS THEN
         IF l_debug = FND_API.G_TRUE THEN
         QP_PREQ_GRP.engine_debug(substr(sqlerrm, 1, 240));

         END IF;
         IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
         THEN
           FND_MESSAGE.SET_NAME('QP','QP_ERROR_IN_LIMIT_PROCESSING');
           l_message := FND_MESSAGE.GET;
           l_message := substr(ltrim(rtrim(l_message))||l_message, 1, 2000);
           --Update the lines_tmp table with the translated error message.
/*
INDX,qp_limit_balance_check_pvt.check_balance.upd3,qp_npreq_lines_tmp_N1,LINE_INDEX,1
*/
           --sql statement upd3
           UPDATE qp_npreq_lines_tmp
           SET    pricing_status_text = l_message,
                  pricing_status_code = QP_PREQ_GRP.G_STATUS_OTHER_ERRORS
           WHERE  line_index = g_limit_balance_line(i).line_index;

           --Update the ldets_tmp table with the translated error message.
/*
INDX,qp_limit_balance_check_pvt.check_balance.upd4,qp_npreq_ldets_tmp_N1,LINE_INDEX,1
INDX,qp_limit_balance_check_pvt.check_balance.upd4,qp_npreq_ldets_tmp_N1,CREATED_FROM_LIST_LINE_ID,5
*/
           --sql statement upd4
           UPDATE qp_npreq_ldets_tmp
           SET    pricing_status_text = l_message,
                  pricing_status_code = QP_PREQ_GRP.G_STATUS_OTHER_ERRORS
           WHERE  line_index = g_limit_balance_line(i).line_index
           AND    created_from_list_line_id =
                         g_limit_balance_line(i).list_line_id;

           IF l_debug = FND_API.G_TRUE THEN
           QP_PREQ_GRP.engine_debug(l_message);

           END IF;
         END IF;

         --Set the hard_limit_exceeded flag to true. So that the record in
         --ldets_tmp table is set to deleted status.
         g_limit_balance_line(i).hard_limit_exceeded := TRUE;
         RAISE;

    END;--Block around select stmt when no each attr exists

    --Check the Limit Transaction Table to see if the same request has a
    --record. If so, this is a repricing request so populate the
    --transaction_amount in the balanceline plsql table for later use.
    BEGIN
/*
INDX,qp_limit_balance_check_pvt.check_balance.sel3,QP_LIMIT_TRANSACTIONS_U1,PRICE_REQUEST_CODE,1
INDX,qp_limit_balance_check_pvt.check_balance.sel3,QP_LIMIT_TRANSACTIONS_U1,LIST_HEADER_ID,2
INDX,qp_limit_balance_check_pvt.check_balance.sel3,QP_LIMIT_TRANSACTIONS_U1,LIST_LINE_ID,3
INDX,qp_limit_balance_check_pvt.check_balance.sel3,QP_LIMIT_TRANSACTIONS_U1,LIMIT_BALANCE_ID,4
*/
      --sql statement sel3
      SELECT amount
      INTO   g_limit_balance_line(i).transaction_amount
      FROM   qp_limit_transactions
      WHERE  price_request_code = p_limit_rec.price_request_code
      AND    list_header_id = p_limit_rec.created_from_list_header_id
      AND    list_line_id = p_limit_rec.created_from_list_line_id
      AND    limit_balance_id = g_limit_balance_line(i).limit_balance_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        g_limit_balance_line(i).transaction_amount := null;
    END;


    --Increment the full_available_amount by the transaction_amount
    l_full_available_amount := l_full_available_amount +
                         nvl(g_limit_balance_line(i).transaction_amount, 0);

    g_limit_balance_line(i).full_available_amount := l_full_available_amount;

    --fix for bug 4765137 to remove the modifier if limit balance is zero or
    --negative for a hard limit on new or repriced orders
    IF l_full_available_amount <= 0 AND
       p_limit_rec.limit_exceed_action_code = 'HARD'
    THEN
      g_limit_balance_line(i).hard_limit_exceeded := TRUE;
      RETURN FALSE;
    END IF;

    IF p_limit_rec.limit_exceed_action_code = 'HARD' THEN

      g_limit_balance_line(i).available_amount :=
            least(l_full_available_amount, p_wanted_amount);


--10023220
      IF p_wanted_amount > l_full_available_amount AND ((p_wanted_amount - l_full_available_amount) NOT BETWEEN 0 AND 0.1 )THEN
        g_limit_balance_line(i).limit_code :=
              QP_PREQ_GRP.G_STATUS_LIMIT_ADJUSTED;
      ELSE
        g_limit_balance_line(i).limit_code :=
              QP_PREQ_GRP.G_STATUS_LIMIT_CONSUMED;
      END IF; --if p_wanted_amount > l_full_available_amount

    ELSE --Soft Limit

      g_limit_balance_line(i).available_amount := p_wanted_amount;

      IF g_limit_balance_line(i).line_category = 'RETURN' THEN

         g_limit_balance_line(i).limit_code :=
               QP_PREQ_GRP.G_STATUS_LIMIT_CONSUMED;

      ELSE--If line_category is not 'RETURN'

         IF p_wanted_amount > l_full_available_amount
         THEN
           g_limit_balance_line(i).limit_code :=
                       QP_PREQ_GRP.G_STATUS_LIMIT_EXCEEDED;
         ELSE
           g_limit_balance_line(i).limit_code :=
                       QP_PREQ_GRP.G_STATUS_LIMIT_CONSUMED;
         END IF; --If wanted_amount > l_full_available_amount

      END IF;--If  line_category is 'RETURN'

    END IF; --If limit_exceed_action_code = 'HARD'

    IF l_debug = FND_API.G_TRUE THEN
    QP_PREQ_GRP.engine_debug('p_wanted_amount '||p_wanted_amount);
    QP_PREQ_GRP.engine_debug('available_amount '||
                                g_limit_balance_line(i).available_amount);

    END IF;
    IF p_wanted_amount <> 0 THEN
      g_limit_balance_line(i).available_percent :=
          ABS(g_limit_balance_line(i).available_amount/p_wanted_amount)*100;
    ELSE
      g_limit_balance_line(i).available_percent := 100;
    END IF;

    IF l_debug = FND_API.G_TRUE THEN
    QP_PREQ_GRP.engine_debug('available_percent '||
                                g_limit_balance_line(i).available_percent);
    END IF;

    g_limit_balance_line(i).hard_limit_exceeded := FALSE;
    IF l_debug = FND_API.G_TRUE THEN
    QP_PREQ_GRP.engine_debug('***End Check_Balance***');
    END IF;
    RETURN TRUE;

  ELSIF p_limit_rec.each_attr_exists = 'Y' THEN
  --Mixed case where both Each and Non-Each Attributes exist for the limit
  --and pure Each case
    IF l_debug = FND_API.G_TRUE THEN
    QP_PREQ_GRP.engine_debug('Each-type attributes defined for this limit');
    END IF;

    --Fetch all the org, customer and item type context,attribute and value
    --combinations for the current list_line from the request line attrs table.
    FOR l_org_rec IN request_attr_cur(p_limit_rec.line_index,
                               p_limit_rec.organization_attr_context,
                               p_limit_rec.organization_attribute)
    LOOP
      l_org_table(i1).context := l_org_rec.context;
      l_org_table(i1).attribute := l_org_rec.attribute;
      l_org_table(i1).value := l_org_rec.value_from;
      i1 := i1+1;
    END LOOP;

    FOR l_cust_rec IN request_attr_cur(p_limit_rec.line_index,
                               p_limit_rec.multival_attr1_context,
                               p_limit_rec.multival_attribute1)
    LOOP
      l_cust_table(i2).context := l_cust_rec.context;
      l_cust_table(i2).attribute := l_cust_rec.attribute;
      l_cust_table(i2).value := l_cust_rec.value_from;
      i2 := i2+1;
    END LOOP;

    FOR l_item_rec IN request_attr_cur(p_limit_rec.line_index,
                               p_limit_rec.multival_attr2_context,
                               p_limit_rec.multival_attribute2)
    LOOP
      l_item_table(i3).context := l_item_rec.context;
      l_item_table(i3).attribute := l_item_rec.attribute;
      l_item_table(i3).value := l_item_rec.value_from;
      i3 := i3+1;
    END LOOP;

      IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.engine_debug('Organization Attr Count '|| l_org_table.count);
      QP_PREQ_GRP.engine_debug('Attribute1 Count '|| l_cust_table.count);
      QP_PREQ_GRP.engine_debug('Attribute2 Count '|| l_item_table.count);

      END IF;
    --If for any of org, customer and item limit attribute setup for 'EACH'
    --value doesn't have any corresponding records from the request attrs table
    --mark limit to be skipped and return from check_balance function.
    IF p_limit_rec.organization_attr_context <> 'NA' AND
       l_org_table.COUNT = 0
    OR p_limit_rec.multival_attr1_context <> 'NA' AND
       l_cust_table.COUNT = 0
    OR p_limit_rec.multival_attr2_context <> 'NA' AND
       l_item_table.COUNT = 0
    THEN
      IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.engine_debug('Skipping Limit '|| p_limit_rec.limit_id);
      END IF;
      x_skip_limit := TRUE;
      RETURN TRUE;
    END IF;

    --If an each attribute is not defined in limit and count of request line
    --attributes = 0 then insert a dummy record to enable cartesian product.
    IF p_limit_rec.organization_attr_context = 'NA' AND
       l_org_table.COUNT=0
    THEN
       l_org_table(1).context := 'NA';
       l_org_table(1).attribute := 'NA';
       l_org_table(1).value := 'NA';
    END IF;

    IF p_limit_rec.multival_attr1_context = 'NA' AND
       l_cust_table.COUNT=0
    THEN
       l_cust_table(1).context := 'NA';
       l_cust_table(1).attribute := 'NA';
       l_cust_table(1).value := 'NA';
    END IF;

    IF p_limit_rec.multival_attr2_context = 'NA' AND
       l_item_table.COUNT=0
    THEN
       l_item_table(1).context := 'NA';
       l_item_table(1).attribute := 'NA';
       l_item_table(1).value := 'NA';
    END IF;

    FOR j IN l_org_table.FIRST..l_org_table.LAST
    LOOP
      FOR k IN l_cust_table.FIRST..l_cust_table.LAST
      LOOP
        FOR m IN l_item_table.FIRST..l_item_table.LAST
        LOOP
          g_limit_balance_line(i).limit_id := p_limit_rec.limit_id;
          g_limit_balance_line(i).line_index := p_limit_rec.line_index;
          g_limit_balance_line(i).list_header_id :=
                        p_limit_rec.created_from_list_header_id;
          g_limit_balance_line(i).list_line_id :=
                        p_limit_rec.created_from_list_line_id;
          g_limit_balance_line(i).wanted_amount := p_wanted_amount;
          g_limit_balance_line(i).each_attr_exists :=
                        p_limit_rec.each_attr_exists;
          g_limit_balance_line(i).limit_amount := p_limit_rec.amount;
          g_limit_balance_line(i).basis := p_limit_rec.basis;
          g_limit_balance_line(i).limit_exceed_action_code :=
                        p_limit_rec.limit_exceed_action_code;
          g_limit_balance_line(i).adjustment_amount :=
                        p_limit_rec.adjustment_amount;
          g_limit_balance_line(i).operand_value :=
                        p_limit_rec.operand_value;
          g_limit_balance_line(i).benefit_qty := p_limit_rec.benefit_qty;
          g_limit_balance_line(i).created_from_list_line_type :=
                        p_limit_rec.created_from_list_line_type;
          g_limit_balance_line(i).pricing_group_sequence :=
                        p_limit_rec.pricing_group_sequence;
          g_limit_balance_line(i).operand_calculation_code :=
                        p_limit_rec.operand_calculation_code;
          g_limit_balance_line(i).limit_level := p_limit_rec.limit_level;
          g_limit_balance_line(i).limit_hold_flag :=
                        p_limit_rec.limit_hold_flag;
          --Populate bal_price_request_code for limit_balances table
          IF p_limit_rec.limit_level_code = 'ACROSS_TRANSACTION' THEN
            g_limit_balance_line(i).bal_price_request_code :=  NULL;
          ELSIF p_limit_rec.limit_level_code = 'TRANSACTION' THEN
            g_limit_balance_line(i).bal_price_request_code :=
                        QP_PREQ_GRP.G_ORDER_PRICE_REQUEST_CODE;
          END IF;--If limit_level_code = 'ACROSS_TRANSACTION'
          IF l_debug = FND_API.G_TRUE THEN
          QP_PREQ_GRP.engine_debug('bal_price_request_code '||
                   g_limit_balance_line(i).bal_price_request_code);
          END IF;
          --Populate price_request_code for limit_transactions table
          g_limit_balance_line(i).price_request_code :=
                        p_limit_rec.price_request_code;
          g_limit_balance_line(i).request_type_code :=
                        p_limit_rec.request_type_code;
          g_limit_balance_line(i).line_category := p_limit_rec.line_category;
          g_limit_balance_line(i).pricing_phase_id :=
                        p_limit_rec.pricing_phase_id;
          g_limit_balance_line(i).limit_level_code :=
                        p_limit_rec.limit_level_code;
          g_limit_balance_line(i).line_detail_index :=
                        p_limit_rec.line_detail_index;

          BEGIN
            IF p_limit_rec.limit_level_code = 'ACROSS_TRANSACTION' THEN

/*
INDX,qp_limit_balance_check_pvt.check_balance.sel4,QP_LIMIT_BALANCES_U2,LIMIT_ID,1
INDX,qp_limit_balance_check_pvt.check_balance.sel4,QP_LIMIT_BALANCES_U2,ORGANIZATION_ATTR_CONTEXT,2
INDX,qp_limit_balance_check_pvt.check_balance.sel4,QP_LIMIT_BALANCES_U2,ORGANIZATION_ATTRIBUTE,3
INDX,qp_limit_balance_check_pvt.check_balance.sel4,QP_LIMIT_BALANCES_U2,ORGANIZATION_ATTR_VALUE,4
INDX,qp_limit_balance_check_pvt.check_balance.sel4,QP_LIMIT_BALANCES_U2,MULTIVAL_ATTR1_CONTEXT,5
INDX,qp_limit_balance_check_pvt.check_balance.sel4,QP_LIMIT_BALANCES_U2,MULTIVAL_ATTRIBUTE1,6
INDX,qp_limit_balance_check_pvt.check_balance.sel4,QP_LIMIT_BALANCES_U2,MULTIVAL_ATTR1_VALUE,7
INDX,qp_limit_balance_check_pvt.check_balance.sel4,QP_LIMIT_BALANCES_U2,MULTIVAL_ATTR2_CONTEXT,8
INDX,qp_limit_balance_check_pvt.check_balance.sel4,QP_LIMIT_BALANCES_U2,MULTIVAL_ATTRIBUTE2,9
INDX,qp_limit_balance_check_pvt.check_balance.sel4,QP_LIMIT_BALANCES_U2,MULTIVAL_ATTR2_VALUE,10
*/
              --sql statement sel4
              SELECT available_amount, limit_balance_id,
                     organization_attr_context, organization_attribute,
                     organization_attr_value,
                     multival_attr1_context, multival_attribute1,
                     multival_attr1_value, multival_attr1_type,
                     multival_attr1_datatype,
                     multival_attr2_context, multival_attribute2,
                     multival_attr2_value, multival_attr2_type,
                     multival_attr2_datatype
              INTO   l_full_available_amount,
                     g_limit_balance_line(i).limit_balance_id,
                     g_limit_balance_line(i).organization_attr_context,
                     g_limit_balance_line(i).organization_attribute,
                     g_limit_balance_line(i).organization_attr_value,
                     g_limit_balance_line(i).multival_attr1_context,
                     g_limit_balance_line(i).multival_attribute1,
                     g_limit_balance_line(i).multival_attr1_value,
                     g_limit_balance_line(i).multival_attr1_type,
                     g_limit_balance_line(i).multival_attr1_datatype,
                     g_limit_balance_line(i).multival_attr2_context,
                     g_limit_balance_line(i).multival_attribute2,
                     g_limit_balance_line(i).multival_attr2_value,
                     g_limit_balance_line(i).multival_attr2_type,
                     g_limit_balance_line(i).multival_attr2_datatype
              FROM   qp_limit_balances
              WHERE  limit_id = p_limit_rec.limit_id
              AND    organization_attr_context = l_org_table(j).context
              AND    organization_attribute = l_org_table(j).attribute
              AND    organization_attr_value = l_org_table(j).value
              AND    multival_attr1_context = l_cust_table(k).context
              AND    multival_attribute1 = l_cust_table(k).attribute
              AND    multival_attr1_value = l_cust_table(k).value
              AND    multival_attr2_context = l_item_table(m).context
              AND    multival_attribute2 = l_item_table(m).attribute
              AND    multival_attr2_value = l_item_table(m).value;

            ELSIF p_limit_rec.limit_level_code = 'TRANSACTION' THEN

/*
INDX,qp_limit_balance_check_pvt.check_balance.sel5,QP_LIMIT_BALANCES_U2,LIMIT_ID,1
INDX,qp_limit_balance_check_pvt.check_balance.sel5,QP_LIMIT_BALANCES_U2,ORGANIZATION_ATTR_CONTEXT,2
INDX,qp_limit_balance_check_pvt.check_balance.sel5,QP_LIMIT_BALANCES_U2,ORGANIZATION_ATTRIBUTE,3
INDX,qp_limit_balance_check_pvt.check_balance.sel5,QP_LIMIT_BALANCES_U2,ORGANIZATION_ATTR_VALUE,4
INDX,qp_limit_balance_check_pvt.check_balance.sel5,QP_LIMIT_BALANCES_U2,MULTIVAL_ATTR1_CONTEXT,5
INDX,qp_limit_balance_check_pvt.check_balance.sel5,QP_LIMIT_BALANCES_U2,MULTIVAL_ATTRIBUTE1,6
INDX,qp_limit_balance_check_pvt.check_balance.sel5,QP_LIMIT_BALANCES_U2,MULTIVAL_ATTR1_VALUE,7
INDX,qp_limit_balance_check_pvt.check_balance.sel5,QP_LIMIT_BALANCES_U2,MULTIVAL_ATTR2_CONTEXT,8
INDX,qp_limit_balance_check_pvt.check_balance.sel5,QP_LIMIT_BALANCES_U2,MULTIVAL_ATTRIBUTE2,9
INDX,qp_limit_balance_check_pvt.check_balance.sel5,QP_LIMIT_BALANCES_U2,MULTIVAL_ATTR2_VALUE,10
INDX,qp_limit_balance_check_pvt.check_balance.sel5,QP_LIMIT_BALANCES_U2,PRICE_REQUEST_CODE,11
*/
              --If g_order_price_request_code is null then raise an error.
              IF QP_PREQ_GRP.G_ORDER_PRICE_REQUEST_CODE IS NULL THEN
                RAISE E_ORDER_PRICE_REQ_CODE_NULL;
              END IF;

              --sql statement sel5
              SELECT available_amount, limit_balance_id,
                     organization_attr_context, organization_attribute,
                     organization_attr_value,
                     multival_attr1_context, multival_attribute1,
                     multival_attr1_value, multival_attr1_type,
                     multival_attr1_datatype,
                     multival_attr2_context, multival_attribute2,
                     multival_attr2_value, multival_attr2_type,
                     multival_attr2_datatype
              INTO   l_full_available_amount,
                     g_limit_balance_line(i).limit_balance_id,
                     g_limit_balance_line(i).organization_attr_context,
                     g_limit_balance_line(i).organization_attribute,
                     g_limit_balance_line(i).organization_attr_value,
                     g_limit_balance_line(i).multival_attr1_context,
                     g_limit_balance_line(i).multival_attribute1,
                     g_limit_balance_line(i).multival_attr1_value,
                     g_limit_balance_line(i).multival_attr1_type,
                     g_limit_balance_line(i).multival_attr1_datatype,
                     g_limit_balance_line(i).multival_attr2_context,
                     g_limit_balance_line(i).multival_attribute2,
                     g_limit_balance_line(i).multival_attr2_value,
                     g_limit_balance_line(i).multival_attr2_type,
                     g_limit_balance_line(i).multival_attr2_datatype
              FROM   qp_limit_balances
              WHERE  limit_id = p_limit_rec.limit_id
              AND    organization_attr_context = l_org_table(j).context
              AND    organization_attribute = l_org_table(j).attribute
              AND    organization_attr_value = l_org_table(j).value
              AND    multival_attr1_context = l_cust_table(k).context
              AND    multival_attribute1 = l_cust_table(k).attribute
              AND    multival_attr1_value = l_cust_table(k).value
              AND    multival_attr2_context = l_item_table(m).context
              AND    multival_attribute2 = l_item_table(m).attribute
              AND    multival_attr2_value = l_item_table(m).value
              AND    price_request_code =
                            g_limit_balance_line(i).bal_price_request_code;

            END IF;--If limit_level_code = 'ACROSS_TRANSACTION'

            g_limit_balance_line(i).process_action := g_update;

            IF l_debug = FND_API.G_TRUE THEN
            QP_PREQ_GRP.engine_debug('Available Balance '|| l_full_available_amount);
            END IF;
          EXCEPTION
            WHEN NO_DATA_FOUND THEN

               select qp_limit_balances_s.nextval
               into g_limit_balance_line(i).limit_balance_id from dual;

               g_limit_balance_line(i).organization_attr_context
                     := l_org_table(j).context;
               g_limit_balance_line(i).organization_attribute
                     := l_org_table(j).attribute;
               g_limit_balance_line(i).organization_attr_value
                     := l_org_table(j).value;

               g_limit_balance_line(i).multival_attr1_context
                     := l_cust_table(k).context;
               g_limit_balance_line(i).multival_attribute1
                     := l_cust_table(k).attribute;
               g_limit_balance_line(i).multival_attr1_value
                     := l_cust_table(k).value;
               g_limit_balance_line(i).multival_attr1_type
                     := p_limit_rec.multival_attr1_type;
               g_limit_balance_line(i).multival_attr1_datatype
                     := p_limit_rec.multival_attr1_datatype;

               g_limit_balance_line(i).multival_attr2_context
                     := l_item_table(m).context;
               g_limit_balance_line(i).multival_attribute2
                     := l_item_table(m).attribute;
               g_limit_balance_line(i).multival_attr2_value
                     := l_item_table(m).value;
               g_limit_balance_line(i).multival_attr2_type
                     := p_limit_rec.multival_attr2_type;
               g_limit_balance_line(i).multival_attr2_datatype
                     := p_limit_rec.multival_attr2_datatype;

               l_full_available_amount := p_limit_rec.amount;
               g_limit_balance_line(i).process_action := g_insert;

            WHEN E_ORDER_PRICE_REQ_CODE_NULL THEN

               IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
               THEN
                 FND_MESSAGE.SET_NAME('QP','QP_ORDER_PRICE_REQ_CODE_NULL');
                 l_message := FND_MESSAGE.GET;

                 --Update the lines_tmp table with the translated error message.
/*
INDX,qp_limit_balance_check_pvt.check_balance.upd11,qp_npreq_lines_tmp_N1,LINE_INDEX,1
*/
                 --sql statement upd11
                 UPDATE qp_npreq_lines_tmp
                 SET    pricing_status_text = l_message,
                        pricing_status_code = QP_PREQ_GRP.G_STATUS_OTHER_ERRORS
                 WHERE  line_index = g_limit_balance_line(i).line_index;

                 --Update the ldets_tmp table with the translated error message.
/*
INDX,qp_limit_balance_check_pvt.check_balance.upd12,qp_npreq_ldets_tmp_N1,LINE_INDEX,1
INDX,qp_limit_balance_check_pvt.check_balance.upd12,qp_npreq_ldets_tmp_N1,CREATED_FROM_LIST_LINE_ID,5
*/
                 --sql statement upd12
                 UPDATE qp_npreq_ldets_tmp
                 SET    pricing_status_text = l_message,
                        pricing_status_code = QP_PREQ_GRP.G_STATUS_OTHER_ERRORS
                 WHERE  line_index = g_limit_balance_line(i).line_index
                 AND    created_from_list_line_id =
                               g_limit_balance_line(i).list_line_id;

                 IF l_debug = FND_API.G_TRUE THEN
                 QP_PREQ_GRP.engine_debug(l_message);

                 END IF;
               END IF;

            WHEN TOO_MANY_ROWS THEN
               IF l_debug = FND_API.G_TRUE THEN
               QP_PREQ_GRP.engine_debug(substr(sqlerrm, 1, 240));

               END IF;
               IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
               THEN
                 FND_MESSAGE.SET_NAME('QP','QP_MULT_LIMIT_BALANCES');
                 FND_MESSAGE.SET_TOKEN('LIMIT', g_limit_balance_line(i).limit_id);
                 l_message := FND_MESSAGE.GET;

                 --Update the lines_tmp table with the translated error message.
/*
INDX,qp_limit_balance_check_pvt.check_balance.upd5,qp_npreq_lines_tmp_N1,LINE_INDEX,1
*/
                 --sql statement upd5
                 UPDATE qp_npreq_lines_tmp
                 SET    pricing_status_text = l_message,
                        pricing_status_code = QP_PREQ_GRP.G_STATUS_OTHER_ERRORS
                 WHERE  line_index = g_limit_balance_line(i).line_index;

                 --Update the ldets_tmp table with the translated error message.
/*
INDX,qp_limit_balance_check_pvt.check_balance.upd6,qp_npreq_ldets_tmp_N1,LINE_INDEX,1
INDX,qp_limit_balance_check_pvt.check_balance.upd6,qp_npreq_ldets_tmp_N1,CREATED_FROM_LIST_LINE_ID,5
*/
                 --sql statement upd6
                 UPDATE qp_npreq_ldets_tmp
                 SET    pricing_status_text = l_message,
                        pricing_status_code =
                             QP_PREQ_GRP.G_STATUS_OTHER_ERRORS
                 WHERE  line_index = g_limit_balance_line(i).line_index
                 AND    created_from_list_line_id =
                               g_limit_balance_line(i).list_line_id;

                 IF l_debug = FND_API.G_TRUE THEN
                 QP_PREQ_GRP.engine_debug(l_message);

                 END IF;
               END IF;

               --Set the hard_limit_exceeded flag to true. So that the record in
               --ldets_tmp table is set to deleted status.
               g_limit_balance_line(i).hard_limit_exceeded := TRUE;
               RAISE;

           WHEN OTHERS THEN
               IF l_debug = FND_API.G_TRUE THEN
               QP_PREQ_GRP.engine_debug(substr(sqlerrm, 1, 240));

               END IF;
               IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
               THEN
                 FND_MESSAGE.SET_NAME('QP','QP_ERROR_IN_LIMIT_PROCESSING');
                 l_message := FND_MESSAGE.GET;
                 l_message := substr(ltrim(rtrim(l_message))||l_message, 1, 2000);

                 --Update the lines_tmp table with the translated error message.
/*
INDX,qp_limit_balance_check_pvt.check_balance.upd7,qp_npreq_lines_tmp_N1,LINE_INDEX,1
*/
                 --sql statement upd7
                 UPDATE qp_npreq_lines_tmp
                 SET    pricing_status_text = l_message,
                        pricing_status_code = QP_PREQ_GRP.G_STATUS_OTHER_ERRORS
                 WHERE  line_index = g_limit_balance_line(i).line_index;

                 --Update the ldets_tmp table with the translated error message.
/*
INDX,qp_limit_balance_check_pvt.check_balance.upd8,qp_npreq_ldets_tmp_N1,LINE_INDEX,1
INDX,qp_limit_balance_check_pvt.check_balance.upd8,qp_npreq_ldets_tmp_N1,CREATED_FROM_LIST_LINE_ID,5
*/
                   --sql statement upd8
                   UPDATE qp_npreq_ldets_tmp
                   SET    pricing_status_text = l_message,
                          pricing_status_code =
                               QP_PREQ_GRP.G_STATUS_OTHER_ERRORS
                   WHERE  line_index = g_limit_balance_line(i).line_index
                   AND    created_from_list_line_id =
                                 g_limit_balance_line(i).list_line_id;

                 IF l_debug = FND_API.G_TRUE THEN
                 QP_PREQ_GRP.engine_debug(l_message);

                 END IF;
               END IF;

               --Set the hard_limit_exceeded flag to true. So that the record in
               --ldets_tmp table is set to deleted status.
               g_limit_balance_line(i).hard_limit_exceeded := TRUE;
               RAISE;

          END;--Block around select stmt when no each attr exists

          --Check the Limit Transaction Table to see if the same request has a
          --record. If so, this is a repricing request so populate the
          --transaction_amount in the balanceline plsql table for later use.
          BEGIN
/*
INDX,qp_limit_balance_check_pvt.check_balance.sel6,QP_LIMIT_TRANSACTIONS_U1,PRICE_REQUEST_CODE,1
INDX,qp_limit_balance_check_pvt.check_balance.sel6,QP_LIMIT_TRANSACTIONS_U1,LIST_HEADER_ID,2
INDX,qp_limit_balance_check_pvt.check_balance.sel6,QP_LIMIT_TRANSACTIONS_U1,LIST_LINE_ID,3
INDX,qp_limit_balance_check_pvt.check_balance.sel6,QP_LIMIT_TRANSACTIONS_U1,LIMIT_BALANCE_ID,4
*/
            --sql statement sel6
            SELECT amount
            INTO   g_limit_balance_line(i).transaction_amount
            FROM   qp_limit_transactions
            WHERE  price_request_code = p_limit_rec.price_request_code
            AND    list_header_id = p_limit_rec.created_from_list_header_id
            AND    list_line_id = p_limit_rec.created_from_list_line_id
            AND    limit_balance_id = g_limit_balance_line(i).limit_balance_id;
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              g_limit_balance_line(i).transaction_amount := null;
          END;


          --Increment the full_available_amount by the transaction_amount
          l_full_available_amount := l_full_available_amount +
                         nvl(g_limit_balance_line(i).transaction_amount, 0);

    --fix for bug 4765137 to remove the modifier if limit balance is zero or
    --negative for a hard limit on new or repriced orders
          IF l_full_available_amount <= 0 AND
             p_limit_rec.limit_exceed_action_code = 'HARD'
          THEN
            g_limit_balance_line(i).hard_limit_exceeded := TRUE;
            RETURN FALSE;
          END IF;

          IF p_limit_rec.limit_exceed_action_code = 'HARD'
          THEN
            g_limit_balance_line(i).available_amount :=
                  least(l_full_available_amount, p_wanted_amount);


--10023220
            IF p_wanted_amount > l_full_available_amount AND ((p_wanted_amount - l_full_available_amount) NOT BETWEEN 0 AND 0.1 )THEN
              g_limit_balance_line(i).limit_code :=
                          QP_PREQ_GRP.G_STATUS_LIMIT_ADJUSTED;
            ELSE
              g_limit_balance_line(i).limit_code :=
                          QP_PREQ_GRP.G_STATUS_LIMIT_CONSUMED;
            END IF; --if p_wanted_amount > l_full_available_amount

          ELSE --Soft Limit
            g_limit_balance_line(i).available_amount := p_wanted_amount;

            IF g_limit_balance_line(i).line_category = 'RETURN' THEN

               g_limit_balance_line(i).limit_code :=
                          QP_PREQ_GRP.G_STATUS_LIMIT_CONSUMED;

            ELSE --If line_category is not 'RETURN'

               IF p_wanted_amount > l_full_available_amount
               THEN
                 g_limit_balance_line(i).limit_code :=
                            QP_PREQ_GRP.G_STATUS_LIMIT_EXCEEDED;
               ELSE
                 g_limit_balance_line(i).limit_code :=
                            QP_PREQ_GRP.G_STATUS_LIMIT_CONSUMED;
               END IF; --If wanted_amount > l_full_available_amount

            END IF; --If line_category is 'RETURN'

          END IF; --If limit_exceed_action_code is 'HARD'

          IF l_debug = FND_API.G_TRUE THEN
          QP_PREQ_GRP.engine_debug('p_wanted_amount '||p_wanted_amount);
          QP_PREQ_GRP.engine_debug('available_amount '||
                                g_limit_balance_line(i).available_amount);

          END IF;
          IF p_wanted_amount <> 0 THEN
            g_limit_balance_line(i).available_percent :=
              ABS(g_limit_balance_line(i).available_amount/p_wanted_amount)*100;
          ELSE
            g_limit_balance_line(i).available_percent := 100;
          END IF;

          IF l_debug = FND_API.G_TRUE THEN
          QP_PREQ_GRP.engine_debug('available_percent '||
                                g_limit_balance_line(i).available_percent);

          END IF;
          g_limit_balance_line(i).hard_limit_exceeded := FALSE;

          i := i + 1; --Increment i for the next balance line for the limit.

        END LOOP; --over l_item_table
      END LOOP; --over l_cust_table
    END LOOP; --over l_org_table

    IF l_debug = FND_API.G_TRUE THEN
    QP_PREQ_GRP.engine_debug('***End Check_balance***');
    END IF;
    RETURN TRUE;

  END IF; --If Each Attributes Exist for the Limit

EXCEPTION
  WHEN OTHERS THEN
    IF l_debug = FND_API.G_TRUE THEN
    QP_PREQ_GRP.engine_debug(substr(sqlerrm, 1, 240));
    END IF;
    RETURN FALSE;
END Check_Balance;


/**********************************************************************
   Utility Function to serve as a wrapper around calls to check_balance.
   So that repeated calls can be made elegantly.
***********************************************************************/
FUNCTION Check_Balance_Wrapper(p_limit_rec           IN  Limit_Rec,
                               x_skip_limit          OUT NOCOPY BOOLEAN)
RETURN BOOLEAN
IS
 l_limit_available  BOOLEAN := FALSE;
 l_skip_limit       BOOLEAN := FALSE;
 l_wanted_amount    NUMBER;
 l_amt_exist_flag VARCHAR2(2) := 'N'; --bug#13371371
 l_modifier_level_code	   VARCHAR2(30) := ''; --bug#13371371
BEGIN
--bug#13371371
      select MODIFIER_LEVEL_CODE into l_modifier_level_code
      from qp_list_lines where list_line_id = p_limit_rec.created_from_list_line_id;

      IF l_modifier_level_code = 'LINEGROUP' THEN

      BEGIN
	      select 'Y' into l_amt_exist_flag
	      from qp_pricing_attributes
	      where list_line_id = p_limit_rec.created_from_list_line_id
	      AND pricing_attribute_context = 'VOLUME'
	      AND pricing_attribute = 'PRICING_ATTRIBUTE12';
       EXCEPTION
	  WHEN OTHERS THEN
	    IF l_debug = FND_API.G_TRUE THEN
	       QP_PREQ_GRP.engine_debug('results not found' || SQLERRM);
	    END IF;
	     l_amt_exist_flag := 'N';
        END;
      END IF;
  IF l_amt_exist_flag = 'Y' AND p_limit_rec.operand_calculation_code = 'LUMPSUM' AND p_limit_rec.unit_price = 0 THEN
	l_wanted_amount := 0;
  END IF;
--bug#13371371

  IF p_limit_rec.basis = 'USAGE' THEN

     IF p_limit_rec.line_category = 'RETURN' THEN
       l_wanted_amount := -1;
     ELSE
       l_wanted_amount := 1;
     END IF;

  ELSIF p_limit_rec.basis = 'QUANTITY' THEN

     IF p_limit_rec.line_category = 'RETURN' THEN
       l_wanted_amount := -1 * p_limit_rec.quantity_wanted;
     ELSE
       l_wanted_amount := p_limit_rec.quantity_wanted;
     END IF;

  ELSIF p_limit_rec.basis = 'ACCRUAL' THEN

     IF p_limit_rec.line_category = 'RETURN' THEN
       l_wanted_amount := -1 * p_limit_rec.accrual_wanted;
     ELSE
       l_wanted_amount := p_limit_rec.accrual_wanted;
     END IF;

  ELSIF p_limit_rec.basis = 'COST' THEN

     IF p_limit_rec.line_category = 'RETURN' THEN
       l_wanted_amount := -1 * p_limit_rec.cost_wanted;
     ELSE
       l_wanted_amount := p_limit_rec.cost_wanted;
     END IF;
  ELSIF p_limit_rec.basis = 'CHARGE' THEN

     IF p_limit_rec.line_category = 'RETURN' THEN
       l_wanted_amount := p_limit_rec.cost_wanted;
     ELSE
       l_wanted_amount := -1 * p_limit_rec.cost_wanted;
     END IF;

  ELSIF p_limit_rec.basis = 'GROSS_REVENUE' THEN

     IF p_limit_rec.line_category = 'RETURN' THEN
       l_wanted_amount := -1 * p_limit_rec.gross_revenue_wanted;
     ELSE
       l_wanted_amount := p_limit_rec.gross_revenue_wanted;
     END IF;

  END IF; --Set the appropriate wanted_amount for different types of limit basis

  --Then call the Check_Balance function
  l_limit_available := Check_Balance(p_limit_rec => p_limit_rec,
	   p_wanted_amount => l_wanted_amount,
           x_skip_limit =>  l_skip_limit);

  x_skip_limit := l_skip_limit;
  RETURN l_limit_available;

EXCEPTION
  WHEN OTHERS THEN
    IF l_debug = FND_API.G_TRUE THEN
    QP_PREQ_GRP.engine_debug(substr(sqlerrm, 1, 240));
    END IF;
    RETURN FALSE;
END Check_Balance_Wrapper;


/**************************************************************************
   The following is the main procedure to match and evaluate if the
   limit balance has been exceeded for each request line and appropriately
   update the request line.
***************************************************************************/
PROCEDURE Process_Limits(x_return_status OUT NOCOPY VARCHAR2,
                         x_return_text   OUT NOCOPY VARCHAR2)
IS
/*
INDX,qp_limit_balance_check_pvt.process_limits.limits_cur,qp_npreq_ldets_tmp_N4,PRICING_STATUS_CODE,1
INDX,qp_limit_balance_check_pvt.process_limits.limits_cur,qp_npreq_ldets_tmp_N4,HEADER_LIMIT_EXISTS,2
INDX,qp_limit_balance_check_pvt.process_limits.limits_cur,QP_LIMITS_N1,LIST_HEADER_ID,1
INDX,qp_limit_balance_check_pvt.process_limits.limits_cur,QP_LIMITS_N1,LIST_LINE_ID,2
INDX,qp_limit_balance_check_pvt.process_limits.limits_cur,QP_LIMIT_ATTRIBUTES_N1,LIMIT_ID,1
INDX,qp_limit_balance_check_pvt.process_limits.limits_cur,qp_npreq_line_attrs_tmp_N2,PRICING_STATUS_CODE,1
INDX,qp_limit_balance_check_pvt.process_limits.limits_cur,qp_npreq_line_attrs_tmp_N2,ATTRIBUTE_TYPE,2
INDX,qp_limit_balance_check_pvt.process_limits.limits_cur,qp_npreq_line_attrs_tmp_N2,CONTEXT,3
INDX,qp_limit_balance_check_pvt.process_limits.limits_cur,qp_npreq_line_attrs_tmp_N2,ATTRIBUTE,4
INDX,qp_limit_balance_check_pvt.process_limits.limits_cur,qp_npreq_line_attrs_tmp_N2,VALUE_FROM,5
INDX,qp_limit_balance_check_pvt.process_limits.limits_cur,qp_npreq_line_attrs_tmp_N2,LINE_INDEX,6
INDX,qp_limit_balance_check_pvt.process_limits.limits_cur,qp_npreq_lines_tmp_N1,LINE_INDEX,1
*/
CURSOR limits_cur
IS
--Statement to select line-level limits for pure Non-each and mixed cases
  SELECT /*+ ordered use_nl (l a rl q) index(rl qp_preq_line_attrs_tmp_N2) */
         r.line_index, r.created_from_list_header_id,
	 r.created_from_list_line_id, 'L' limit_level, l.limit_id,
         l.amount, l.limit_exceed_action_code, l.basis, l.limit_hold_flag,
	 l.limit_level_code, r.adjustment_amount, r.benefit_qty,
         r.created_from_list_line_type, r.pricing_group_sequence,
         r.operand_calculation_code, q.price_request_code,
         q.request_type_code, q.line_category,
         r.operand_value, q.unit_price, l.each_attr_exists, r.pricing_phase_id,
         l.non_each_attr_count, l.total_attr_count, r.line_detail_index,
         decode(l.organization_flag,
                'Y','PARTY','NA') organization_attr_context,
         decode(l.organization_flag,
                'Y','QUALIFIER_ATTRIBUTE3','NA') organization_attribute,
         nvl(l.multival_attr1_context,'NA')  multival_attr1_context,
         nvl(l.multival_attribute1,'NA')     multival_attribute1,
         nvl(l.multival_attr1_type,'NA')     multival_attr1_type,
         nvl(l.multival_attr1_datatype,'NA') multival_attr1_datatype,
         nvl(l.multival_attr2_context,'NA')  multival_attr2_context,
         nvl(l.multival_attribute2,'NA')     multival_attribute2,
         nvl(l.multival_attr2_type,'NA')     multival_attr2_type,
         nvl(l.multival_attr2_datatype,'NA') multival_attr2_datatype,
         (q.priced_quantity * q.unit_price)  gross_revenue_wanted,
         -(decode(q.line_type_code,
                'ORDER', -(decode(r.operand_calculation_code,
                                '%', q.unit_price * r.operand_value/100,
                                r.operand_value)),
                r.adjustment_amount * q.priced_quantity)) cost_wanted,
         /*decode(r.operand_calculation_code,
                QP_PREQ_GRP.G_LUMPSUM_DISCOUNT, r.benefit_qty,
                r.benefit_qty * q.priced_quantity) accrual_wanted, -- 3598337, see bug for explanation*/
                r.benefit_qty  accrual_wanted, --4328118, see bug for explanation.
         q.priced_quantity                               quantity_wanted
  FROM   qp_npreq_ldets_tmp r, qp_limits l,
	 qp_limit_attributes a, qp_npreq_line_attrs_tmp rl, qp_npreq_lines_tmp q
  WHERE  r.created_from_list_header_id = l.list_header_id
  AND    r.created_from_list_line_id = l.list_line_id
  AND    r.pricing_status_code = QP_PREQ_GRP.G_STATUS_NEW
  AND    r.applied_flag = 'Y' -- [5385851/5322832]
  AND    r.header_limit_exists = 'Y' --common flag for both header and line
  AND    r.CREATED_FROM_LIST_LINE_TYPE NOT IN ('OID','PRG','CIE','IUE','TSN') --Bug#4101675
  AND    l.limit_id = a.limit_id
  AND    a.limit_attribute_context = rl.context
  AND    a.limit_attribute = rl.attribute
  AND    a.limit_attr_value =  rl.value_from
  AND    a.limit_attribute_type = rl.attribute_type
  AND    rl.pricing_status_code = QP_PREQ_GRP.G_STATUS_UNCHANGED
  AND    r.line_index = rl.line_index
  AND    r.line_index = q.line_index
  GROUP  BY r.line_index, r.created_from_list_header_id,
	    r.created_from_list_line_id, 'L', l.limit_id,
            l.amount, l.limit_exceed_action_code, l.basis, l.limit_hold_flag,
	    l.limit_level_code, r.adjustment_amount, r.benefit_qty,
            r.created_from_list_line_type, r.pricing_group_sequence,
            r.operand_calculation_code, q.price_request_code,
            q.request_type_code, q.line_category, r.operand_value, q.unit_price,
            l.each_attr_exists, r.pricing_phase_id, l.non_each_attr_count,
            l.total_attr_count, r.line_detail_index, l.organization_flag,
            l.multival_attr1_context, l.multival_attribute1,
            l.multival_attr1_type, l.multival_attr1_datatype,
            l.multival_attr2_context, l.multival_attribute2,
            l.multival_attr2_type, l.multival_attr2_datatype,
            q.priced_quantity, q.line_type_code
  HAVING count(*) = (select count(*)
                     from   qp_limit_attributes la
                     where  la.limit_id = l.limit_id)

  UNION

--Statement to select line-level limits for pure Each and no limit attrs cases
  SELECT r.line_index, r.created_from_list_header_id,
	 r.created_from_list_line_id, 'L' limit_level, l.limit_id,
         l.amount, l.limit_exceed_action_code, l.basis, l.limit_hold_flag,
	 l.limit_level_code, r.adjustment_amount, r.benefit_qty,
         r.created_from_list_line_type, r.pricing_group_sequence,
         r.operand_calculation_code, q.price_request_code,
         q.request_type_code, q.line_category,
         r.operand_value, q.unit_price, l.each_attr_exists, r.pricing_phase_id,
         l.non_each_attr_count, l.total_attr_count, r.line_detail_index,
         decode(l.organization_flag,
                'Y','PARTY','NA') organization_attr_context,
         decode(l.organization_flag,
                'Y','QUALIFIER_ATTRIBUTE3','NA') organization_attribute,
         nvl(l.multival_attr1_context,'NA')  multival_attr1_context,
         nvl(l.multival_attribute1,'NA')     multival_attribute1,
         nvl(l.multival_attr1_type,'NA')     multival_attr1_type,
         nvl(l.multival_attr1_datatype,'NA') multival_attr1_datatype,
         nvl(l.multival_attr2_context,'NA')  multival_attr2_context,
         nvl(l.multival_attribute2,'NA')     multival_attribute2,
         nvl(l.multival_attr2_type,'NA')     multival_attr2_type,
         nvl(l.multival_attr2_datatype,'NA') multival_attr2_datatype,
         (q.priced_quantity * q.unit_price)  gross_revenue_wanted,
         -(decode(q.line_type_code,
                'ORDER', -(decode(r.operand_calculation_code,
                                '%', q.unit_price * r.operand_value/100,
                                r.operand_value)),
                r.adjustment_amount * q.priced_quantity)) cost_wanted,
         /*decode(r.operand_calculation_code,
                QP_PREQ_GRP.G_LUMPSUM_DISCOUNT, r.benefit_qty,
                r.benefit_qty * q.priced_quantity) accrual_wanted, -- 3598337, see bug for explanation*/
                r.benefit_qty  accrual_wanted, --4328118, see bug for explanation.
         q.priced_quantity                               quantity_wanted
  FROM   qp_npreq_ldets_tmp r, qp_limits l, qp_npreq_lines_tmp q
  WHERE  r.created_from_list_header_id = l.list_header_id
  AND    r.created_from_list_line_id = l.list_line_id
  AND    r.pricing_status_code = QP_PREQ_GRP.G_STATUS_NEW
  AND    r.applied_flag = 'Y' -- [5385851/5322832]
  AND    r.header_limit_exists = 'Y' --common flag for both header and line
  AND    r.CREATED_FROM_LIST_LINE_TYPE NOT IN ('OID','PRG','CIE','IUE','TSN') --Bug#4101675
  AND    r.line_index = q.line_index
  AND    l.non_each_attr_count = 0

  UNION

--Statement to select header-level limits for pure Non-each and mixed cases
  SELECT r.line_index, r.created_from_list_header_id,
	 r.created_from_list_line_id, 'H' limit_level, l.limit_id,
         l.amount, l.limit_exceed_action_code, l.basis, l.limit_hold_flag,
	 l.limit_level_code, r.adjustment_amount, r.benefit_qty,
         r.created_from_list_line_type, r.pricing_group_sequence,
         r.operand_calculation_code, q.price_request_code,
         q.request_type_code, q.line_category,
         r.operand_value, q.unit_price, l.each_attr_exists, r.pricing_phase_id,
         l.non_each_attr_count, l.total_attr_count, r.line_detail_index,
         decode(l.organization_flag,
                'Y','PARTY','NA') organization_attr_context,
         decode(l.organization_flag,
                'Y','QUALIFIER_ATTRIBUTE3','NA') organization_attribute,
         nvl(l.multival_attr1_context,'NA')  multival_attr1_context,
         nvl(l.multival_attribute1,'NA')     multival_attribute1,
         nvl(l.multival_attr1_type,'NA')     multival_attr1_type,
         nvl(l.multival_attr1_datatype,'NA') multival_attr1_datatype,
         nvl(l.multival_attr2_context,'NA')  multival_attr2_context,
         nvl(l.multival_attribute2,'NA')     multival_attribute2,
         nvl(l.multival_attr2_type,'NA')     multival_attr2_type,
         nvl(l.multival_attr2_datatype,'NA') multival_attr2_datatype,
         (q.priced_quantity * q.unit_price)  gross_revenue_wanted,
         -(decode(q.line_type_code,
                'ORDER', decode(r.operand_calculation_code,
                                '%', q.unit_price * r.operand_value/100,
                                r.operand_value),
                r.adjustment_amount * q.priced_quantity)) cost_wanted,
        /* decode(r.operand_calculation_code,
                QP_PREQ_GRP.G_LUMPSUM_DISCOUNT, r.benefit_qty,
                r.benefit_qty * q.priced_quantity) accrual_wanted, -- 3598337, see bug for explanation*/
                r.benefit_qty  accrual_wanted, --4328118, see bug for explanation.
         q.priced_quantity                               quantity_wanted
  FROM   qp_npreq_ldets_tmp r, qp_limits l,
	 qp_limit_attributes a, qp_npreq_line_attrs_tmp rl, qp_npreq_lines_tmp q
  WHERE  r.created_from_list_header_id = l.list_header_id
  AND    l.list_line_id = -1
  AND    r.pricing_status_code = QP_PREQ_GRP.G_STATUS_NEW
  AND    r.applied_flag = 'Y' -- [5385851/5322832]
  AND    r.header_limit_exists = 'Y' --common flag for both header and line
  AND    r.CREATED_FROM_LIST_LINE_TYPE NOT IN ('OID','PRG','CIE','IUE','TSN') --Bug#4101675
  AND    l.limit_id = a.limit_id
  AND    a.limit_attribute_context = rl.context
  AND    a.limit_attribute = rl.attribute
  AND    a.limit_attr_value =  rl.value_from
  AND    a.limit_attribute_type = rl.attribute_type
  AND    rl.pricing_status_code = QP_PREQ_GRP.G_STATUS_UNCHANGED
  AND    r.line_index = rl.line_index
  AND    r.line_index = q.line_index
  GROUP  BY r.line_index, r.created_from_list_header_id,
	    r.created_from_list_line_id, 'H', l.limit_id,
            l.amount, l.limit_exceed_action_code, l.basis, l.limit_hold_flag,
	    l.limit_level_code, r.adjustment_amount, r.benefit_qty,
            r.created_from_list_line_type, r.pricing_group_sequence,
            r.operand_calculation_code, q.price_request_code,
            q.request_type_code, q.line_category, r.operand_value, q.unit_price,
            l.each_attr_exists, r.pricing_phase_id, l.non_each_attr_count,
            l.total_attr_count, r.line_detail_index, l.organization_flag,
            l.multival_attr1_context, l.multival_attribute1,
            l.multival_attr1_type, l.multival_attr1_datatype,
            l.multival_attr2_context, l.multival_attribute2,
            l.multival_attr2_type, l.multival_attr2_datatype,
            q.priced_quantity, q.line_type_code
  HAVING count(*) = (select count(*)
                     from   qp_limit_attributes la
                     where  la.limit_id = l.limit_id)

  UNION

--Statement to select headerlevel limits for pure Each and no limit attrs cases
  SELECT r.line_index, r.created_from_list_header_id,
	 r.created_from_list_line_id, 'H' limit_level, l.limit_id,
         l.amount, l.limit_exceed_action_code, l.basis, l.limit_hold_flag,
	 l.limit_level_code, r.adjustment_amount, r.benefit_qty,
         r.created_from_list_line_type, r.pricing_group_sequence,
         r.operand_calculation_code, q.price_request_code,
         q.request_type_code, q.line_category,
         r.operand_value, q.unit_price, l.each_attr_exists, r.pricing_phase_id,
         l.non_each_attr_count, l.total_attr_count, r.line_detail_index,
         decode(l.organization_flag,
                'Y','PARTY','NA') organization_attr_context,
         decode(l.organization_flag,
                'Y','QUALIFIER_ATTRIBUTE3','NA') organization_attribute,
         nvl(l.multival_attr1_context,'NA')  multival_attr1_context,
         nvl(l.multival_attribute1,'NA')     multival_attribute1,
         nvl(l.multival_attr1_type,'NA')     multival_attr1_type,
         nvl(l.multival_attr1_datatype,'NA') multival_attr1_datatype,
         nvl(l.multival_attr2_context,'NA')  multival_attr2_context,
         nvl(l.multival_attribute2,'NA')     multival_attribute2,
         nvl(l.multival_attr2_type,'NA')     multival_attr2_type,
         nvl(l.multival_attr2_datatype,'NA') multival_attr2_datatype,
         (q.priced_quantity * q.unit_price)  gross_revenue_wanted,
         -(decode(q.line_type_code,
                'ORDER', -(decode(r.operand_calculation_code,
                                '%', q.unit_price * r.operand_value/100,
                                r.operand_value)),
                r.adjustment_amount * q.priced_quantity)) cost_wanted,
         /*decode(r.operand_calculation_code,
                QP_PREQ_GRP.G_LUMPSUM_DISCOUNT, r.benefit_qty,
                r.benefit_qty * q.priced_quantity) accrual_wanted, -- 3598337, see bug for explanation*/
                r.benefit_qty  accrual_wanted, --4328118, see bug for explanation.
         q.priced_quantity                               quantity_wanted
  FROM   qp_npreq_ldets_tmp r, qp_limits l, qp_npreq_lines_tmp q
  WHERE  r.created_from_list_header_id = l.list_header_id
  AND    l.list_line_id = -1
  AND    r.pricing_status_code = QP_PREQ_GRP.G_STATUS_NEW
  AND    r.applied_flag = 'Y' -- [5385851/5322832]
  AND    r.header_limit_exists = 'Y' --common flag for both header and line
  AND    r.CREATED_FROM_LIST_LINE_TYPE NOT IN ('OID','PRG','CIE','IUE','TSN') --Bug#4101675
  AND    r.line_index = q.line_index
  AND    l.non_each_attr_count = 0

  ORDER BY 1,2,3,4,5;
--That is, order by r.line_index, r.created_from_list_header_id, r.created_from_list_line_id, limit_level, l.limit_id


l_limit_available          BOOLEAN := FALSE;
l_retcode                  BOOLEAN := FALSE;
l_available_amount         NUMBER;
l_limit_exceed_action_code VARCHAR2(30);
l_req_attr_value           VARCHAR2(240);
l_limit_text               VARCHAR2(2000) := '';
l_return_status            VARCHAR2(1);

l_old_limit_rec            limits_cur%ROWTYPE;
l_skip_header              BOOLEAN := FALSE;
l_skip_line                BOOLEAN := FALSE;
l_skip_limit               BOOLEAN := FALSE;

l_limit_code               VARCHAR2(30) := '';
l_hold_code                VARCHAR2(240) := '';

TYPE number_table is table of NUMBER index by BINARY_INTEGER; --Bug 4457725
l_processed_limits_tbl     number_table; --Bug 4457725
l_processed_limit_count    NUMBER := 1; --Bug 4457725
l_processed                BOOLEAN; --Bug 4457725
l_modifier_level_code	   VARCHAR2(30) := ''; --Bug 4457725

BEGIN

  l_debug := QP_PREQ_GRP.G_DEBUG_ENGINE;
  IF l_debug = FND_API.G_TRUE THEN
  QP_PREQ_GRP.engine_debug('***Begin Process_Limits***');

  END IF;
  --Initialize x_return_status
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  x_return_text := 'Success';

  --Reset global plsql table storing limit balances
  g_limit_balance_line.DELETE;

  --Initialize list_line_id, list_header_id and line_index in l_old_limit_rec
  l_old_limit_rec.created_from_list_line_id := -9999999;
  l_old_limit_rec.created_from_list_header_id := -9999999;
  l_old_limit_rec.line_index := -9999999;

  FOR l_limit_rec IN limits_cur
  LOOP

    IF l_debug = FND_API.G_TRUE THEN
    QP_PREQ_GRP.engine_debug('========================');
    QP_PREQ_GRP.engine_debug('In limits_cur loop');

    QP_PREQ_GRP.engine_debug('list header id of previous limit ' || l_old_limit_rec.created_from_list_header_id);
    QP_PREQ_GRP.engine_debug('list header id of current limit ' || l_limit_rec.created_from_list_header_id);
    QP_PREQ_GRP.engine_debug('------------------------');
    QP_PREQ_GRP.engine_debug('list_line_id of previous limit ' || l_old_limit_rec.created_from_list_line_id);
    QP_PREQ_GRP.engine_debug('list_line_id of current limit ' || l_limit_rec.created_from_list_line_id);
    QP_PREQ_GRP.engine_debug('------------------------');
    QP_PREQ_GRP.engine_debug('line_index of previous limit ' || l_old_limit_rec.line_index);
    QP_PREQ_GRP.engine_debug('line_index of current limit ' || l_limit_rec.line_index);
    QP_PREQ_GRP.engine_debug('------------------------');

    END IF;
    --If Skip_line flag is true then skip all limits until list_line_id changes
    --or until line_index changes.
    IF l_skip_line AND
       l_limit_rec.created_from_list_line_id =
                 l_old_limit_rec.created_from_list_line_id AND
       l_limit_rec.line_index =
                 l_old_limit_rec.line_index
    THEN
      IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.engine_debug('skipping limit '|| l_limit_rec.limit_id ||
                       'for line '||l_limit_rec.created_from_list_line_id);

      END IF;
      l_old_limit_rec := l_limit_rec;
      GOTO limits_loop;  --to next record in limits_cur loop
    END IF;

    --If Skip_header flag is true, skip all limits until list_header_id changes
    --or until line_index changes.
    IF l_skip_header AND
       l_limit_rec.created_from_list_header_id =
                 l_old_limit_rec.created_from_list_header_id AND
       l_limit_rec.line_index =
                 l_old_limit_rec.line_index
    THEN
      IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.engine_debug('skipping limit '|| l_limit_rec.limit_id ||
                       'for header '||l_limit_rec.created_from_list_header_id);

      END IF;
      l_old_limit_rec := l_limit_rec;
      GOTO limits_loop; --to next record in limits_cur loop
    END IF;

    l_skip_line := FALSE;
    l_skip_header := FALSE;


    --If list_line_id or line_index changes
    IF (l_old_limit_rec.created_from_list_line_id <>
                                l_limit_rec.created_from_list_line_id AND
        l_old_limit_rec.created_from_list_line_id >= 0)
                --no need to execute this for the first time.
       OR
       (l_old_limit_rec.line_index <> l_limit_rec.line_index AND
        l_old_limit_rec.line_index >= 0)
                --no need to execute this for the first time.
    THEN

      --Bug 4457725] Added to check for Group of Lines modifier such that a limit
      --is applied only once for a group
      select MODIFIER_LEVEL_CODE into l_modifier_level_code
      from qp_list_lines where list_line_id = l_old_limit_rec.created_from_list_line_id;
      IF l_debug = FND_API.G_TRUE THEN
         QP_PREQ_GRP.engine_debug('Modifier Level '||l_modifier_level_code);
      END IF;

      IF l_modifier_level_code = 'LINEGROUP' AND l_processed_limits_tbl.COUNT > 0 AND l_limit_rec.basis = 'USAGE'  --9645844
      THEN
         l_processed := false;
         FOR j in l_processed_limits_tbl.FIRST..l_processed_limits_tbl.LAST
         LOOP
            IF l_processed_limits_tbl(j) = l_old_limit_rec.limit_id THEN
               l_processed := true;
               exit;
            END IF;
         END LOOP;
     END IF;

     IF l_modifier_level_code = 'LINEGROUP' AND l_processed AND l_limit_rec.basis = 'USAGE'   --9645844
     THEN
        IF l_debug = FND_API.G_TRUE THEN
           QP_PREQ_GRP.engine_debug('Line Group Modifier with limit id '||l_old_limit_rec.limit_id||' already processed');
        END IF;
	--Clear the global plsql table storing limits info.
	g_limit_balance_line.DELETE;

	--Skip updating the limit balance if limit is processed already
        GOTO next_record;
     END IF;

      G_LOOP_COUNT := 0; --Initialize whenever line_index or list_line_id
                         --changes, i.e., before each loop
      LOOP
        IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.engine_debug('Change in list_line_id or line_index. ' ||
                                 'Update limit balance. Loop through ' ||
                                 'Recheck_balance and Update_Balance, if ' ||
                                 'necessary ');

        END IF;
        l_return_status := Update_Balance(x_return_text);

	IF l_modifier_level_code = 'LINEGROUP' AND l_limit_rec.basis = 'USAGE' THEN  --9645844
	   l_processed_limits_tbl(l_processed_limit_count) := l_old_limit_rec.limit_id;
  	   l_processed_limit_count := l_processed_limit_count+1;
	END IF;

        IF l_return_status = FND_API.G_RET_STS_ERROR THEN

          IF G_LOOP_COUNT <= G_MAX_LOOP_COUNT THEN
            l_retcode := Recheck_Balance;
          ELSE
            RAISE FND_API.G_EXC_ERROR;
          END IF;

        ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

        ELSE --If Update_Balance successful
         IF g_limit_balance_line.COUNT > 0 THEN

          --Reset limit_code and limit_text when line_index or
          --list_line_id changes.
          IF (l_old_limit_rec.created_from_list_line_id <>
                                l_limit_rec.created_from_list_line_id) OR
             (l_old_limit_rec.line_index <> l_limit_rec.line_index)
          THEN
            l_limit_code := '';
            l_limit_text := '';
          END IF;

          --Reset hold_code when list_line_id changes.
          IF (l_old_limit_rec.line_index <> l_limit_rec.line_index) THEN
            l_hold_code := '';
          END IF;

          FOR j IN g_limit_balance_line.FIRST..g_limit_balance_line.LAST
          LOOP

            IF (g_limit_balance_line(j).limit_code =
                             QP_PREQ_GRP.G_STATUS_LIMIT_ADJUSTED)
               OR
               (g_limit_balance_line(j).limit_code =
                      QP_PREQ_GRP.G_STATUS_LIMIT_EXCEEDED AND
                l_limit_code IS NULL)
            THEN

              l_limit_code := g_limit_balance_line(j).limit_code;

              Build_Message_Text(
                p_List_Header_Id => g_limit_balance_line(j).list_header_id
               ,p_List_Line_Id => g_limit_balance_line(j).list_line_id
               ,p_Limit_Id => g_limit_balance_line(j).limit_id
               ,p_full_available_amount => g_limit_balance_line(j).full_available_amount
               ,p_wanted_amount => g_limit_balance_line(j).wanted_amount
               ,p_limit_code => g_limit_balance_line(j).limit_code
               ,p_limit_level => g_limit_balance_line(j).limit_level
               ,p_operand_value => g_limit_balance_line(j).operand_value
               ,p_operand_calculation_code => g_limit_balance_line(j).operand_calculation_code
               ,p_least_percent => g_limit_balance_line(j).least_percent
               ,p_message_text => l_limit_text
              );

              IF l_debug = FND_API.G_TRUE THEN
              QP_PREQ_GRP.engine_debug('################# ' || l_limit_text);

              END IF;
            END IF;

            IF g_limit_balance_line(j).limit_hold_flag = 'Y' AND
               g_limit_balance_line(j).limit_code IN
                        (QP_PREQ_GRP.G_STATUS_LIMIT_ADJUSTED,
                         QP_PREQ_GRP.G_STATUS_LIMIT_EXCEEDED)
            THEN
              l_hold_code := QP_PREQ_GRP.G_STATUS_LIMIT_HOLD;
            END IF;

            IF g_limit_balance_line(j).limit_hold_flag = 'N' AND
               g_limit_balance_line(j).limit_code IN
                        (QP_PREQ_GRP.G_STATUS_LIMIT_ADJUSTED,
                         QP_PREQ_GRP.G_STATUS_LIMIT_EXCEEDED)
            THEN
              l_hold_code := QP_PREQ_GRP.G_STATUS_LIMIT_ADJUSTED;
            END IF;

            IF l_debug = FND_API.G_TRUE THEN
            QP_PREQ_GRP.engine_debug('Hold Flag is ' || g_limit_balance_line(j).limit_hold_flag );
            QP_PREQ_GRP.engine_debug('Hold Code is ' || l_hold_code);

            END IF;
            --Do the following update for all list line types
/*
INDX,qp_limit_balance_check_pvt.process_limits.upd1,qp_npreq_ldets_tmp_N1,LINE_INDEX,1
INDX,qp_limit_balance_check_pvt.process_limits.upd1,qp_npreq_ldets_tmp_N1,PRICING_STATUS_CODE,2
INDX,qp_limit_balance_check_pvt.process_limits.upd1,qp_npreq_ldets_tmp_N1,CREATED_FROM_LIST_LINE_ID,5
*/
            --sql statement upd1
            UPDATE qp_npreq_ldets_tmp
            SET    operand_value = g_limit_balance_line(j).operand_value,
                   benefit_qty = g_limit_balance_line(j).benefit_qty,
                   limit_code = l_limit_code,
                   limit_text = l_limit_text
            WHERE  line_index = g_limit_balance_line(j).line_index
            AND    created_from_list_line_id =
                       g_limit_balance_line(j).list_line_id
            AND    pricing_status_code = QP_PREQ_GRP.G_STATUS_NEW;

            --Update the Child Break Lines for 'PBH' lines
            IF g_limit_balance_line(j).created_from_list_line_type = 'PBH'
            THEN
/*
INDX,qp_limit_balance_check_pvt.process_limits.upd2,qp_npreq_ldets_tmp_N1,LINE_INDEX,1
INDX,qp_limit_balance_check_pvt.process_limits.upd2,qp_npreq_ldets_tmp_N1,PRICING_STATUS_CODE,2
INDX,qp_limit_balance_check_pvt.process_limits.upd2,qp_npreq_ldets_tmp_N1,CREATED_FROM_LIST_LINE_ID,5
INDX,qp_limit_balance_check_pvt.process_limits.upd2,QP_RLTD_LINES_TMP_INDEX,LINE_INDEX,1
*/
              --sql statement upd2
              UPDATE qp_npreq_ldets_tmp a
              SET    a.operand_value = DECODE(
                        g_limit_balance_line(j).operand_calculation_code,
                        '%', (g_limit_balance_line(j).least_percent/100) *
                                g_limit_balance_line(j).operand_value,
                        'AMT', (g_limit_balance_line(j).least_percent/100) *
                                  g_limit_balance_line(j).operand_value,
                        'LUMPSUM', (g_limit_balance_line(j).least_percent/100)
                                      * g_limit_balance_line(j).operand_value,
                        'NEWPRICE', g_limit_balance_line(j).operand_value -
                            (100 - g_limit_balance_line(j).least_percent)/100
                               * g_limit_balance_line(j).adjustment_amount,
                        g_limit_balance_line(j).operand_value),

                     a.benefit_qty = DECODE(
                        g_limit_balance_line(j).basis,
                        'ACCRUAL', (g_limit_balance_line(j).least_percent/100)
                                      * g_limit_balance_line(j).benefit_qty,
                        g_limit_balance_line(j).benefit_qty),

                     a.limit_code = l_limit_code,
                     a.limit_text = l_limit_text

              WHERE  a.line_index = g_limit_balance_line(j).line_index
              AND    a.created_from_list_line_id =
                         g_limit_balance_line(j).list_line_id
              AND    a.pricing_status_code = QP_PREQ_GRP.G_STATUS_NEW
              AND    a.line_detail_index IN
                        (SELECT b.related_line_detail_index
                         FROM   qp_npreq_rltd_lines_tmp b
                         WHERE  b.line_index = a.line_index
                         AND    b.relationship_type_code = 'PRICE_BREAK'
                         AND    b.line_detail_index =
                                  g_limit_balance_line(j).line_detail_index);

            END IF;--If created_from_list_line_type = 'PBH'

            IF l_debug = FND_API.G_TRUE THEN
            QP_PREQ_GRP.engine_debug('line_index '||
                                g_limit_balance_line(j).line_index);
            QP_PREQ_GRP.engine_debug('limit_code '||
                                g_limit_balance_line(j).limit_code);
            QP_PREQ_GRP.engine_debug('list_line_id '||
                                g_limit_balance_line(j).list_line_id);
            QP_PREQ_GRP.engine_debug('benefit_qty '||
                                g_limit_balance_line(j).benefit_qty);
            QP_PREQ_GRP.engine_debug('operand_value '||
                                g_limit_balance_line(j).operand_value);

            END IF;
            --Update Hold_Code
/*
INDX,qp_limit_balance_check_pvt.process_limits.upd3,qp_npreq_lines_tmp_N1,LINE_INDEX,1
*/
            --sql statement upd3
            UPDATE qp_npreq_lines_tmp
            SET    hold_code = DECODE(hold_code, QP_PREQ_GRP.G_STATUS_LIMIT_HOLD, QP_PREQ_GRP.G_STATUS_LIMIT_HOLD, l_hold_code)
            WHERE  line_index = g_limit_balance_line(j).line_index;

     IF l_debug = FND_API.G_TRUE THEN
     QP_PREQ_GRP.engine_debug('Hold Flag is Y');
     QP_PREQ_GRP.engine_debug('Hold Code is '||QP_PREQ_GRP.G_STATUS_LIMIT_HOLD);

     END IF;

            IF g_limit_balance_line(j).transaction_amount is null THEN
               INSERT INTO qp_limit_transactions
               (
                limit_balance_id,
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
               (
                g_limit_balance_line(j).limit_balance_id,
                sysdate,
                fnd_global.user_id,
                sysdate,
                fnd_global.user_id,
                g_limit_balance_line(j).list_header_id,
                g_limit_balance_line(j).list_line_id,
                sysdate,
                g_limit_balance_line(j).request_type_code,
                g_limit_balance_line(j).price_request_code,
                g_limit_balance_line(j).pricing_phase_id,
                g_limit_balance_line(j).given_amount
               );

            ELSIF g_limit_balance_line(j).transaction_amount <>
                               g_limit_balance_line(j).given_amount THEN
/*
INDX,qp_limit_balance_check_pvt.process_limits.upd4,QP_LIMIT_TRANSACTIONS_U1,PRICE_REQUEST_CODE,1
INDX,qp_limit_balance_check_pvt.process_limits.upd4,QP_LIMIT_TRANSACTIONS_U1,LIST_HEADER_ID,2
INDX,qp_limit_balance_check_pvt.process_limits.upd4,QP_LIMIT_TRANSACTIONS_U1,LIST_LINE_ID,3
INDX,qp_limit_balance_check_pvt.process_limits.upd4,QP_LIMIT_TRANSACTIONS_U1,LIMIT_BALANCE_ID,4
*/
               --sql statement upd4
               update qp_limit_transactions
               set    amount = g_limit_balance_line(j).given_amount,
                      last_update_date = sysdate,
                      last_updated_by = fnd_global.user_id,
                      price_request_date = sysdate
               where limit_balance_id = g_limit_balance_line(j).limit_balance_id               and   list_header_id = g_limit_balance_line(j).list_header_id
               and   list_line_id = g_limit_balance_line(j).list_line_id
               and  price_request_code =
                          g_limit_balance_line(j).price_request_code;

            END IF; --If transaction_amount is null

          END LOOP; --through limit balance lines

         END IF; --g_limit_balance_line.COUNT > 0

          IF l_debug = FND_API.G_TRUE THEN
          QP_PREQ_GRP.engine_debug('Done Updating Balances when line changed');

          END IF;
          --Clear the global plsql table storing limits info.
          g_limit_balance_line.DELETE;
          EXIT;

        END IF; --If Update_Balance returns Error

      END LOOP;

    END IF; --If list_line_id or line_index has changed

    <<next_record>>
    l_limit_available := Check_Balance_Wrapper(p_limit_rec => l_limit_rec,
                                               x_skip_limit => l_skip_limit);

    IF NOT l_limit_available THEN

      IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.engine_debug('Limit not available - hard limit with 0 balance');

      END IF;
      --If Header-level limit, then skip all limits and go to the next
      --list_header limit.  Elseif line_level go to the next line_level limit.
      IF l_limit_rec.limit_level = 'H' THEN
        IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.engine_debug('Header Level Limit '||
                          l_limit_rec.limit_id ||' not available');
        END IF;
/*
INDX,qp_limit_balance_check_pvt.process_limits.upd5,qp_npreq_ldets_tmp_N1,LINE_INDEX,1
INDX,qp_limit_balance_check_pvt.process_limits.upd5,qp_npreq_ldets_tmp_N1,PRICING_STATUS_CODE,2
INDX,qp_limit_balance_check_pvt.process_limits.upd5,qp_npreq_ldets_tmp_N1,CREATED_FROM_LIST_HEADER_ID,4
*/
        --sql statement upd5
        UPDATE qp_npreq_ldets_tmp
        SET    pricing_status_code = QP_PREQ_GRP.G_STATUS_DELETED
        WHERE  created_from_list_header_id =
                            l_limit_rec.created_from_list_header_id
        AND    line_index = l_limit_rec.line_index
        AND    pricing_status_code = QP_PREQ_GRP.G_STATUS_NEW;

        l_skip_header := TRUE;

      ELSIF l_limit_rec.limit_level = 'L' THEN
        IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.engine_debug('Line Level Limit '||
                          l_limit_rec.limit_id ||' not available');
        END IF;
/*
INDX,qp_limit_balance_check_pvt.process_limits.upd6,qp_npreq_ldets_tmp_N1,LINE_INDEX,1
INDX,qp_limit_balance_check_pvt.process_limits.upd6,qp_npreq_ldets_tmp_N1,PRICING_STATUS_CODE,2
INDX,qp_limit_balance_check_pvt.process_limits.upd6,qp_npreq_ldets_tmp_N1,CREATED_FROM_LIST_LINE_ID,5
*/
        --sql statement upd6
        UPDATE qp_npreq_ldets_tmp
        SET    pricing_status_code = QP_PREQ_GRP.G_STATUS_DELETED
        WHERE  created_from_list_line_id =
                            l_limit_rec.created_from_list_line_id
        AND    line_index = l_limit_rec.line_index
        AND    pricing_status_code = QP_PREQ_GRP.G_STATUS_NEW;

        l_skip_line := TRUE;

      END IF;

    ELSIF l_limit_available AND l_skip_limit THEN

      IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.engine_debug('limit ' || l_limit_rec.limit_id ||
                            ' available but' || 'skipped - does not qualify');
      END IF;
      l_skip_limit := FALSE;
      GOTO limits_loop; --to next record in limits_cur loop

    END IF; --If NOT l_limit_available

    l_old_limit_rec := l_limit_rec;

    IF l_debug = FND_API.G_TRUE THEN
    QP_PREQ_GRP.engine_debug('Repeat limits_cur loop for next limit - if any');
    END IF;
    <<limits_loop>>
    null;
  END LOOP; --loop over main limits_cur


  --Loop to update balance for the last list line of the limits_cur loop
  --(Boundary condition)

  IF l_old_limit_rec.created_from_list_line_id >= 0 THEN
     --no need to execute this the first time, when no limits to be processed

  G_LOOP_COUNT := 0; --Initialize before boundary condition loop

  LOOP
    IF l_debug = FND_API.G_TRUE THEN
    QP_PREQ_GRP.engine_debug('***Start Boundary condition processing***');
    END IF;

      select MODIFIER_LEVEL_CODE into l_modifier_level_code
      from qp_list_lines where list_line_id = l_old_limit_rec.created_from_list_line_id;
      IF l_debug = FND_API.G_TRUE THEN
         QP_PREQ_GRP.engine_debug('Modifier Level '||l_modifier_level_code);
      END IF;

      IF l_modifier_level_code = 'LINEGROUP' AND l_processed_limits_tbl.COUNT > 0 AND l_old_limit_rec.basis = 'USAGE'   --9645844
      THEN
         l_processed := false;
         FOR j in l_processed_limits_tbl.FIRST..l_processed_limits_tbl.LAST
         LOOP
            IF l_processed_limits_tbl(j) = l_old_limit_rec.limit_id THEN
               l_processed := true;
               exit;
            END IF;
         END LOOP;
      END IF;

     IF l_modifier_level_code = 'LINEGROUP' AND l_processed AND l_old_limit_rec.basis = 'USAGE'   --9645844
     THEN
        IF l_debug = FND_API.G_TRUE THEN
          QP_PREQ_GRP.engine_debug('***Boundary condition GroupOfLines Limit already processed***');
        END IF;
	EXIT;
     END IF;

    l_return_status := Update_Balance(x_return_text);

    IF l_modifier_level_code = 'LINEGROUP' AND l_old_limit_rec.basis = 'USAGE' THEN  --9645844
       l_processed_limits_tbl(l_processed_limit_count) := l_old_limit_rec.limit_id;
       l_processed_limit_count := l_processed_limit_count+1;
    END IF;

    IF l_debug = FND_API.G_TRUE THEN
     QP_PREQ_GRP.engine_debug('Update_Balance l_return_status ' ||l_return_status);
    END IF;

    IF l_return_status = FND_API.G_RET_STS_ERROR THEN

      IF G_LOOP_COUNT <= G_MAX_LOOP_COUNT THEN
        l_retcode := Recheck_Balance;
      ELSE
        RAISE FND_API.G_EXC_ERROR;
      END IF;

    ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    ELSE --If Update_Balance successful

     IF g_limit_balance_line.COUNT > 0 THEN

      --Reset limit_code and limit_text when line_index for boundary condition
      --processing.
      l_limit_code := '';
      l_limit_text := '';

      --Reset hold_code for boundary condition processing.
      l_hold_code := '';

      FOR j IN g_limit_balance_line.FIRST..g_limit_balance_line.LAST
      LOOP

        IF g_limit_balance_line(j).limit_code =
                         QP_PREQ_GRP.G_STATUS_LIMIT_ADJUSTED
           OR
           (g_limit_balance_line(j).limit_code =
                  QP_PREQ_GRP.G_STATUS_LIMIT_EXCEEDED AND
            l_limit_code IS NULL)
        THEN

          l_limit_code := g_limit_balance_line(j).limit_code;

          IF l_debug = FND_API.G_TRUE THEN
            QP_PREQ_GRP.engine_debug('Before Buid_Message_Text');
          END IF;

          Build_Message_Text(
             p_List_Header_Id => g_limit_balance_line(j).list_header_id
            ,p_List_Line_Id => g_limit_balance_line(j).list_line_id
            ,p_Limit_Id => g_limit_balance_line(j).limit_id
            ,p_full_available_amount => g_limit_balance_line(j).full_available_amount
            ,p_wanted_amount => g_limit_balance_line(j).wanted_amount
            ,p_limit_code => g_limit_balance_line(j).limit_code
            ,p_limit_level => g_limit_balance_line(j).limit_level
            ,p_operand_value => g_limit_balance_line(j).operand_value
            ,p_operand_calculation_code => g_limit_balance_line(j).operand_calculation_code
            ,p_least_percent => g_limit_balance_line(j).least_percent
            ,p_message_text => l_limit_text
            );

          IF l_debug = FND_API.G_TRUE THEN
          QP_PREQ_GRP.engine_debug('################# ' || l_limit_text);

          END IF;
        END IF;

        IF g_limit_balance_line(j).limit_hold_flag = 'Y' AND
           g_limit_balance_line(j).limit_code IN
                    (QP_PREQ_GRP.G_STATUS_LIMIT_ADJUSTED,
                     QP_PREQ_GRP.G_STATUS_LIMIT_EXCEEDED)
        THEN
          IF l_debug = FND_API.G_TRUE THEN
            QP_PREQ_GRP.engine_debug('label 1');
          END IF;
          l_hold_code := QP_PREQ_GRP.G_STATUS_LIMIT_HOLD;
        END IF;

        IF g_limit_balance_line(j).limit_hold_flag = 'N' AND
           g_limit_balance_line(j).limit_code IN
                    (QP_PREQ_GRP.G_STATUS_LIMIT_ADJUSTED,
                     QP_PREQ_GRP.G_STATUS_LIMIT_EXCEEDED)
        THEN
          IF l_debug = FND_API.G_TRUE THEN
            QP_PREQ_GRP.engine_debug('label 2');
          END IF;
           l_hold_code := QP_PREQ_GRP.G_STATUS_LIMIT_ADJUSTED;
        END IF;

        IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.engine_debug('Hold Flag is ' || g_limit_balance_line(j).limit_hold_flag );
        QP_PREQ_GRP.engine_debug('Hold Code is ' || l_hold_code);

        END IF;
        --Do the following update for all list line types
/*
INDX,qp_limit_balance_check_pvt.process_limits.upd7,qp_npreq_ldets_tmp_N1,LINE_INDEX,1
INDX,qp_limit_balance_check_pvt.process_limits.upd7,qp_npreq_ldets_tmp_N1,PRICING_STATUS_CODE,2
INDX,qp_limit_balance_check_pvt.process_limits.upd7,qp_npreq_ldets_tmp_N1,CREATED_FROM_LIST_LINE_ID,5
*/
        --sql statement upd7
        UPDATE qp_npreq_ldets_tmp
        SET    operand_value = g_limit_balance_line(j).operand_value,
               benefit_qty = g_limit_balance_line(j).benefit_qty,
               limit_code = l_limit_code,
               limit_text = l_limit_text
        WHERE  line_index = g_limit_balance_line(j).line_index
        AND    created_from_list_line_id =
                   g_limit_balance_line(j).list_line_id
        AND    pricing_status_code = QP_PREQ_GRP.G_STATUS_NEW;

          IF l_debug = FND_API.G_TRUE THEN
            QP_PREQ_GRP.engine_debug('label 3');
          END IF;

        --Update the Child Break Lines for 'PBH' lines
        IF g_limit_balance_line(j).created_from_list_line_type = 'PBH' THEN
/*
INDX,qp_limit_balance_check_pvt.process_limits.upd8,qp_npreq_ldets_tmp_N1,LINE_INDEX,1
INDX,qp_limit_balance_check_pvt.process_limits.upd8,qp_npreq_ldets_tmp_N1,PRICING_STATUS_CODE,2
INDX,qp_limit_balance_check_pvt.process_limits.upd8,qp_npreq_ldets_tmp_N1,CREATED_FROM_LIST_LINE_ID,5
INDX,qp_limit_balance_check_pvt.process_limits.upd8,QP_RLTD_LINES_TMP_INDEX,LINE_INDEX,1
*/
          --sql statement upd8
          UPDATE qp_npreq_ldets_tmp a
          SET    a.operand_value = DECODE(
                    g_limit_balance_line(j).operand_calculation_code,
                    '%', (g_limit_balance_line(j).least_percent/100) *
                            g_limit_balance_line(j).operand_value,
                    'AMT', (g_limit_balance_line(j).least_percent/100) *
                              g_limit_balance_line(j).operand_value,
                    'LUMPSUM', (g_limit_balance_line(j).least_percent/100)
                                  * g_limit_balance_line(j).operand_value,
                    'NEWPRICE', g_limit_balance_line(j).operand_value -
                        (100 - g_limit_balance_line(j).least_percent)/100
                           * g_limit_balance_line(j).adjustment_amount,
                     g_limit_balance_line(j).operand_value),

                 a.benefit_qty = DECODE(
                    g_limit_balance_line(j).basis,
                    'ACCRUAL', (g_limit_balance_line(j).least_percent/100) *
                                  g_limit_balance_line(j).benefit_qty,
                    g_limit_balance_line(j).benefit_qty),

                 a.limit_code = l_limit_code,
                 a.limit_text = l_limit_text

          WHERE  a.line_index = g_limit_balance_line(j).line_index
          AND    a.created_from_list_line_id =
                     g_limit_balance_line(j).list_line_id
          AND    a.pricing_status_code = QP_PREQ_GRP.G_STATUS_NEW
          AND    a.line_detail_index IN
                     (SELECT b.related_line_detail_index
                      FROM   qp_npreq_rltd_lines_tmp b
                      WHERE  b.line_index = a.line_index
                      AND    b.relationship_type_code = 'PRICE_BREAK'
                      AND    b.line_detail_index =
                               g_limit_balance_line(j).line_detail_index);

          IF l_debug = FND_API.G_TRUE THEN
            QP_PREQ_GRP.engine_debug('label 4');
          END IF;
		--bug#12916970
		QP_PREQ_GRP.engine_debug('operand_calculation_code-DK-'||g_limit_balance_line(j).operand_calculation_code);
		 UPDATE qp_npreq_rltd_lines_tmp a
			  SET    a.operand = g_limit_balance_line(j).operand_value
			  WHERE  a.line_index = g_limit_balance_line(j).line_index
			  AND    a.list_line_id =
				     g_limit_balance_line(j).list_line_id
			  AND    a.pricing_status_code = QP_PREQ_GRP.G_STATUS_NEW
			  AND    a.line_detail_index  =
					       g_limit_balance_line(j).line_detail_index;

			  IF l_debug = FND_API.G_TRUE THEN
			    QP_PREQ_GRP.engine_debug('label 123-rows updated-'||sql%rowcount);
			  END IF;
		--bug#12916970
        END IF;--If created_from_list_line_type = 'PBH'

        IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.engine_debug('line_index '||
                                g_limit_balance_line(j).line_index);
        QP_PREQ_GRP.engine_debug('limit_code '||
                                g_limit_balance_line(j).limit_code);
        QP_PREQ_GRP.engine_debug('list_line_id '||
                                g_limit_balance_line(j).list_line_id);
        QP_PREQ_GRP.engine_debug('benefit_qty '||
                                g_limit_balance_line(j).benefit_qty);
        QP_PREQ_GRP.engine_debug('operand_value '||
                                g_limit_balance_line(j).operand_value);

        END IF;
/*
INDX,qp_limit_balance_check_pvt.process_limits.upd9,qp_npreq_lines_tmp_N1,LINE_INDEX,1
*/
        --sql statement upd9

        UPDATE qp_npreq_lines_tmp
        SET    hold_code = DECODE(hold_code, QP_PREQ_GRP.G_STATUS_LIMIT_HOLD, QP_PREQ_GRP.G_STATUS_LIMIT_HOLD, l_hold_code)
        WHERE  line_index = g_limit_balance_line(j).line_index;

        IF g_limit_balance_line(j).transaction_amount is null THEN

          IF l_debug = FND_API.G_TRUE THEN
            QP_PREQ_GRP.engine_debug('transaction amount is null');
          END IF;

           IF l_debug = FND_API.G_TRUE THEN
           QP_PREQ_GRP.engine_debug('Inserting Into qp_limit_transactions');
           END IF;

           INSERT INTO qp_limit_transactions
           (
             limit_balance_id,
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
           (
             g_limit_balance_line(j).limit_balance_id,
             sysdate,
             fnd_global.user_id,
             sysdate,
             fnd_global.user_id,
             g_limit_balance_line(j).list_header_id,
             g_limit_balance_line(j).list_line_id,
             sysdate,
             g_limit_balance_line(j).request_type_code,
             g_limit_balance_line(j).price_request_code,
             g_limit_balance_line(j).pricing_phase_id,
             g_limit_balance_line(j).given_amount
           );

        ELSIF g_limit_balance_line(j).transaction_amount <>
                              g_limit_balance_line(j).given_amount THEN

           IF l_debug = FND_API.G_TRUE THEN
           QP_PREQ_GRP.engine_debug('Updating qp_limit_transactions');

           END IF;
/*
INDX,qp_limit_balance_check_pvt.process_limits.upd10,QP_LIMIT_TRANSACTIONS_U1,PRICE_REQUEST_CODE,1
INDX,qp_limit_balance_check_pvt.process_limits.upd10,QP_LIMIT_TRANSACTIONS_U1,LIST_HEADER_ID,2
INDX,qp_limit_balance_check_pvt.process_limits.upd10,QP_LIMIT_TRANSACTIONS_U1,LIST_LINE_ID,3
INDX,qp_limit_balance_check_pvt.process_limits.upd10,QP_LIMIT_TRANSACTIONS_U1,LIMIT_BALANCE_ID,4
*/
           --sql statement upd10
           update qp_limit_transactions
           set    amount = g_limit_balance_line(j).given_amount,
                  last_update_date = sysdate,
                  last_updated_by = fnd_global.user_id,
                  price_request_date = sysdate
           where limit_balance_id = g_limit_balance_line(j).limit_balance_id
           and   list_header_id = g_limit_balance_line(j).list_header_id
           and   list_line_id = g_limit_balance_line(j).list_line_id
           and   price_request_code =
                      g_limit_balance_line(j).price_request_code;

        END IF; --If transaction_amount is null

       END LOOP; --through limit balance lines
      END IF; --g_limit_balance_line.COUNT > 0

      --Clear the global plsql table storing limits info.
      g_limit_balance_line.DELETE;
      IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.engine_debug('***End Boundary condition processing***');
      END IF;
      EXIT;
    END IF; --If Update_Balance returns Error
  END LOOP; --Boundary condition loop

  END IF; --IF l_old_limit_rec.created_from_list_line_id >= 0

  IF l_debug = FND_API.G_TRUE THEN
  QP_PREQ_GRP.engine_debug('***End Process_Limits***');

  END IF;
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN

	   x_return_status := FND_API.G_RET_STS_ERROR;
         --x_return_text is already set by Update_Balance

           IF l_debug = FND_API.G_TRUE THEN
           QP_PREQ_GRP.engine_debug('Expected Error in Process_Limits');
           QP_PREQ_GRP.engine_debug(substr(sqlerrm, 1, 240));

           END IF;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

	   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
           x_return_text := substr(sqlerrm, 1, 2000);

           IF l_debug = FND_API.G_TRUE THEN
           QP_PREQ_GRP.engine_debug('Unexpected Error in Process_Limits');
           QP_PREQ_GRP.engine_debug(substr(sqlerrm, 1, 240));

           END IF;
    WHEN OTHERS THEN

	   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
           x_return_text := substr(sqlerrm, 1, 2000);

           IF l_debug = FND_API.G_TRUE THEN
           QP_PREQ_GRP.engine_debug('Other Error in Process_Limits');
           QP_PREQ_GRP.engine_debug(substr(sqlerrm, 1, 240));

           END IF;
END Process_Limits;

END QP_LIMIT_BALANCE_CHECK_PVT;

/
