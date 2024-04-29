--------------------------------------------------------
--  DDL for Package Body CSTPLPOP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSTPLPOP" AS
/* $Header: CSTLPOPB.pls 120.1 2008/02/14 12:03:53 smsasidh ship $ */
  FUNCTION po_price(l_org_id NUMBER, l_item_id NUMBER) RETURN NUMBER IS
    po_price_tmp NUMBER ;
    max_transaction_date_tmp DATE;
    transaction_id_tmp       NUMBER;

    BEGIN
      --Added hint for performance Bug # 6819625
      SELECT /*+ INDEX_JOIN (mmt3 MTL_MATERIAL_TRANSACTIONS_N1 MTL_MATERIAL_TRANSACTIONS_N15) */
      Max(Trunc(transaction_date)) transaction_date
      INTO
      max_transaction_date_tmp
      FROM
      mtl_material_transactions mmt3
      WHERE
      mmt3.organization_id = l_org_id AND
      mmt3.inventory_item_id = l_item_id AND
      mmt3.transaction_source_type_id = 1 AND
      --Added for Bug # 6819625 for MTL_MATERIAL_TRANSACTIONS_N15 index usage
      mmt3.transaction_action_id = 27 AND
      mmt3.transaction_type_id = 18;

      if (max_transaction_date_tmp is null) then
	return 0;
      end if;

      --Added hint for performance Bug # 6819625
      SELECT /*+ INDEX_JOIN (mmt2 MTL_MATERIAL_TRANSACTIONS_N1 MTL_MATERIAL_TRANSACTIONS_N15) */
      To_number(Substr(MAX(To_char(mmt2.creation_date,
      'YYYY-MM-DD-HH24-MI-SS:') ||
      To_char(mmt2.transaction_id)), 21))
      INTO
      transaction_id_tmp
      FROM
      mtl_material_transactions mmt2
      WHERE
      mmt2.organization_id = l_org_id AND
      mmt2.inventory_item_id = l_item_id AND
      mmt2.transaction_type_id = 18 AND
      --Added for Bug # 6819625 for MTL_MATERIAL_TRANSACTIONS_N15 index usage
      mmt2.transaction_action_id = 27 AND
      mmt2.transaction_source_type_id = 1 AND
      mmt2.transaction_date BETWEEN max_transaction_date_tmp
      AND max_transaction_date_tmp + 1;

      SELECT
      mmt.transaction_cost
      INTO
      po_price_tmp
      FROM
      mtl_material_transactions mmt
      WHERE
      mmt.transaction_id = transaction_id_tmp;

      RETURN po_price_tmp;
    END;
END CSTPLPOP;


/
