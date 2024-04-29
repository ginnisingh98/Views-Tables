--------------------------------------------------------
--  DDL for Package Body OZF_VOLUME_CALCULATION_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_VOLUME_CALCULATION_PUB" AS
/* $Header: ozfpvocb.pls 120.22.12010000.5 2010/10/15 08:49:45 nirprasa ship $ */
--
-- NAME
--   OZF_VOLUME_CALCULATION_PUB
--
-- HISTORY
--    02/23/2007 kdass     fixed bug 5754500 - if the order_line_id is being passed as a result
--                         of a split, then use split_from_line_id in the call to the cursor.
--    04/20/2007 inanaiah  fixed bug 5975678 - handled creation/update of ozf_order_group_prod records for Splits
--    05/10/2007 nirprasa  fixed bug 6021635 - changed cursor c_offer_id_om for backdated adjustments created for booked orders.
--    05/14/2007 kdass     fixed bug 6008340
--    06/22/2007 nirprasa  fixed bug 6140749 - changed OE_ORDER_LINES to OE_ORDER_LINES_ALL
--    09/19/2008 nirprasa  fixed bug 6998502 - VOLUME OFFERS ARE NOT APPLIED CORRECTLY ON A SALES ORDER
--    09/19/2008 nirprasa  fixed bug 7353241 - VOLUME OFFER CALCULATIONS INCORRECT FOR SINGLE UNIT ACCRUALS
--    11/24/2008 nirprasa  fixed bug 7030415 - R12SIP WE CAN'T SETUP CURRENY CONVERSION TYPE FOR SPECIFIC OPERATING UNIT
--    05/04/2009 kdass     fixed bug 8421406 - BENEFICIARY WITHIN THE MARKET OPTIONS DO NOT WORK
--    15/10/2010 nirprasa  fixed bug 9027785 - BENEFICIARY IS INCORRECT FOR RETURN ORDERS UNLESS THEY ARE REPRICED
------------------------------------------------------------------------------

G_PKG_NAME      CONSTANT VARCHAR2(30):='OZF_VOLUME_CALCULATION_PUB';
G_FILE_NAME     CONSTANT VARCHAR2(12):='ozfpvocb.pls';


PROCEDURE get_group_pbh_prod
(
   p_offer_id           IN  NUMBER
  ,p_list_header_id     IN  NUMBER
  ,p_list_line_id       IN  NUMBER
  ,p_req_line_attrs_tbl IN  QP_RUNTIME_SOURCE.accum_req_line_attrs_tbl
  ,p_order_line_id      IN  NUMBER
  ,x_group_no           OUT NOCOPY NUMBER
  ,x_vol_track_type     OUT NOCOPY VARCHAR2
  ,x_combine_schedule   OUT NOCOPY VARCHAR2
  ,x_pbh_line_id        OUT NOCOPY NUMBER
  ,x_pord_attribute     OUT NOCOPY VARCHAR2
  ,x_prod_attr_value    OUT NOCOPY VARCHAR2
  ,x_indirect_flag      OUT NOCOPY VARCHAR2
)
IS
  CURSOR c_precedence(p_group_no NUMBER) IS
  SELECT precedence, offer_market_option_id
  FROM   ozf_offr_market_options
  WHERE  group_number = p_group_no
  AND    qp_list_header_id = p_list_header_id;

  CURSOR c_market_options(p_offer_market_option_id NUMBER) IS
  SELECT combine_schedule_flag, volume_tracking_level_code
  FROM   ozf_offr_market_options
  WHERE  offer_id = p_offer_id
  AND    offer_market_option_id = p_offer_market_option_id;
-- above cursors can be combined. offer_id is not needed as qp_list_header_id is present in table
  CURSOR c_pbh_line_id IS
  SELECT offer_discount_line_id
  FROM   ozf_qp_discounts
  WHERE  list_line_id = p_list_line_id;

  CURSOR c_existing_values(p_indirect_flag VARCHAR2,l_order_line_id NUMBER) IS
  SELECT group_no, volume_track_type, combine_schedule_yn, pbh_line_id, prod_attribute, prod_attr_value
  FROM   ozf_order_group_prod
  WHERE  order_line_id = l_order_line_id
  AND    indirect_flag = p_indirect_flag
  AND    offer_id      = p_offer_id;

  l_precedence             NUMBER := fnd_api.g_miss_num;
  l_dummy1                 NUMBER;
  l_dummy2                 NUMBER;
  l_offer_market_option_id NUMBER;
  l_vol_track_type         VARCHAR2(30);
  l_combine_schedule       VARCHAR2(1);
  l_split_from_line_id     NUMBER;
  l_group_prod_order_line_id NUMBER;
  l_api_name               CONSTANT VARCHAR2(30) := 'get_group_pbh_prod';
BEGIN
  SAVEPOINT get_group_pbh_prod;

  IF ozf_order_price_pvt.g_resale_line_tbl.COUNT = 0 THEN
    x_indirect_flag := 'O';
  ELSE
    IF ozf_order_price_pvt.g_resale_line_tbl(1).resale_table_type  = 'IFACE' THEN
      x_indirect_flag := 'I';
    ELSIF ozf_order_price_pvt.g_resale_line_tbl(1).resale_table_type  = 'RESALE' THEN
      x_indirect_flag := 'R';
    END IF;
  END IF;

  x_group_no := -9999;

  --kdass fixed bug 6008340
  l_group_prod_order_line_id := p_order_line_id;

  IF x_indirect_flag = 'O' THEN
     select split_from_line_id into l_split_from_line_id from OE_ORDER_LINES_ALL where line_id =  p_order_line_id;
     IF (l_split_from_line_id IS NOT NULL) THEN
        l_group_prod_order_line_id := l_split_from_line_id;
     END IF;
  END IF;

  IF p_req_line_attrs_tbl.COUNT = 0 THEN
    OPEN  c_existing_values(x_indirect_flag,l_group_prod_order_line_id);
    FETCH c_existing_values INTO x_group_no, x_vol_track_type, x_combine_schedule, x_pbh_line_id, x_pord_attribute, x_prod_attr_value;
    CLOSE c_existing_values;
  ELSE
    FOR i IN p_req_line_attrs_tbl.FIRST..p_req_line_attrs_tbl.LAST LOOP
      IF p_req_line_attrs_tbl(i).attribute_type = 'PRODUCT' THEN
        x_pord_attribute := p_req_line_attrs_tbl(i).attribute;
        x_prod_attr_value := p_req_line_attrs_tbl(i).value;
      ELSIF p_req_line_attrs_tbl(i).attribute_type = 'QUALIFIER' THEN
        OPEN  c_precedence(p_req_line_attrs_tbl(i).grouping_no);
        FETCH c_precedence INTO l_dummy1, l_dummy2;
        CLOSE c_precedence;

        IF l_dummy1 < l_precedence THEN
          l_precedence := l_dummy1;
          l_offer_market_option_id := l_dummy2;
          x_group_no := p_req_line_attrs_tbl(i).grouping_no;
        END IF;
/*
        IF p_req_line_attrs_tbl(i).attribute IN ('DISTRIBUTOR', 'DISTRIBUTOR_LIST', 'DISTRIBUTOR_SEGMENT', 'DISTRIBUTOR_TERRITORY') OR p_req_line_attrs_tbl(i).value = 'INDIRECT' THEN
          x_indirect_flag := 'Y';
        END IF;*/
      END IF;
    END LOOP;

    IF x_group_no = -9999 THEN
      x_combine_schedule := 'N';
      x_vol_track_type := 'ACCOUNT';
    ELSE
      OPEN  c_market_options(l_offer_market_option_id);
      FETCH c_market_options INTO x_combine_schedule, x_vol_track_type;
      CLOSE c_market_options;
    END IF;

    OPEN  c_pbh_line_id;
    FETCH c_pbh_line_id INTO x_pbh_line_id;
    CLOSE c_pbh_line_id;
  END IF;

  EXCEPTION
     WHEN OTHERS THEN
     ROLLBACK TO get_group_pbh_prod;
     IF Fnd_Msg_Pub.Check_Msg_Level ( Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR )
     THEN
        Fnd_Msg_Pub.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;

END get_group_pbh_prod;


PROCEDURE insert_volume(
   p_init_msg_list     IN  VARCHAR2
  ,p_api_version       IN  NUMBER
  ,p_commit            IN  VARCHAR2
  ,x_return_status     OUT NOCOPY VARCHAR2
  ,x_msg_count         OUT NOCOPY NUMBER
  ,x_msg_data          OUT NOCOPY VARCHAR2
  ,p_volume_detail_rec IN  ozf_sales_transactions_pvt.sales_transaction_rec_type
  ,p_qp_list_header_id IN  NUMBER
  ,p_offer_id          IN  NUMBER
  ,p_indirect_flag     IN  VARCHAR2
  ,p_sign              IN  NUMBER)
IS
  CURSOR c_group_prod(p_offer_id NUMBER, p_line_id NUMBER, p_indirect_flag VARCHAR2) IS
  SELECT group_no, volume_track_type, combine_schedule_yn, pbh_line_id, volume_type, include_volume_flag
  FROM   ozf_order_group_prod
  WHERE  offer_id = p_offer_id
  AND    order_line_id = p_line_id
  AND    indirect_flag = p_indirect_flag;

  CURSOR c_group_volume_exists(p_offer_id NUMBER, p_group_no NUMBER, p_pbh_lind_id NUMBER) IS
  SELECT 'Y'
  FROM   ozf_volume_summary
  WHERE  offer_id = p_offer_id
  AND    group_no = p_group_no
  AND    pbh_line_id = p_pbh_lind_id;

  CURSOR c_individual_volume_exists(p_offer_id NUMBER, p_individual_type VARCHAR2, p_individual_id NUMBER, p_pbh_line_id NUMBER) IS
  SELECT 'Y'
  FROM   ozf_volume_summary
  WHERE  offer_id = p_offer_id
  AND    individual_type = p_individual_type
  AND    individual_id = p_individual_id
  AND    pbh_line_id = p_pbh_line_id;

  CURSOR c_pbh_lines(p_offer_id NUMBER) IS
  SELECT offer_discount_line_id
  FROM   ozf_offer_discount_lines
  WHERE  offer_id = p_offer_id
  AND    tier_type = 'PBH';

  CURSOR c_line_processed(p_offer_id NUMBER, p_source_code VARCHAR2, p_line_id NUMBER) IS
  SELECT 'Y'
  FROM   ozf_volume_detail
  WHERE  offer_id = p_offer_id
  AND    source_code = p_source_code
  AND    order_line_id = p_line_id;

  CURSOR c_currency_code(p_offer_id NUMBER) IS
  SELECT NVL(transaction_currency_code, fund_request_curr_code)
  FROM   ozf_offers
  WHERE  offer_id = p_offer_id;

  CURSOR c_order_line_type(p_line_id NUMBER) IS
  SELECT reference_header_id, reference_line_id, line_category_code, return_context, return_attribute1, return_attribute2
  FROM   oe_order_lines_all
  WHERE  line_id = p_line_id;
  l_order_line_type c_order_line_type%ROWTYPE;

  CURSOR c_rma_ref_line_detail(p_offer_id NUMBER, p_line_id NUMBER, p_indirect_flag VARCHAR2) IS
  SELECT offer_id, qp_list_header_id, group_no, volume_track_type, combine_schedule_yn, pbh_line_id, volume_type, prod_attribute, prod_attr_value, apply_discount_flag, include_volume_flag, indirect_flag
  FROM   ozf_order_group_prod
  WHERE  offer_id = p_offer_id
  AND    order_line_id = p_line_id
  AND    indirect_flag = p_indirect_flag;
  l_rma_ref_line_detail c_rma_ref_line_detail%ROWTYPE;

  --Added for bug 7030415
   CURSOR c_get_conversion_type( p_org_id IN NUMBER) IS
   SELECT exchange_rate_type
   FROM   ozf_sys_parameters_all
   WHERE  org_id = p_org_id;

  l_group_no            NUMBER;
  l_volume_track_type   VARCHAR2(30);
  l_combine_schedule_yn VARCHAR2(1);
  l_pbh_line_id         NUMBER;
  l_split_from_line_id  NUMBER;
  l_volume_type         VARCHAR2(30);
  l_include_volume      VARCHAR2(1);
  l_current_volume      NUMBER;
  l_volume_exists       VARCHAR2(1);
  l_line_processed      VARCHAR2(1) := 'N';
  l_api_name            CONSTANT VARCHAR2(30) := 'insert_volume';
  l_currency_code       VARCHAR2(15);
  l_convert_amt         NUMBER;
  l_return_status       VARCHAR2(1);
  l_exchange_rate_type  VARCHAR2(30) := FND_API.G_MISS_CHAR;
  l_rate                NUMBER;
BEGIN
  SAVEPOINT create_volume;
  x_return_status := Fnd_Api.g_ret_sts_success;
  ozf_utility_pvt.write_conc_log('========================= Insert Volume =========================');
  ozf_utility_pvt.write_conc_log('offer_id: ' || p_offer_id);

  IF p_offer_id IS NOT NULL THEN
  OPEN  c_line_processed(p_offer_id, p_volume_detail_rec.source_code, p_volume_detail_rec.line_id);
  FETCH c_line_processed INTO l_line_processed;
  CLOSE c_line_processed;
ozf_utility_pvt.write_conc_log('line processed ' || l_line_processed);
  IF l_line_processed = 'N' THEN
    IF p_volume_detail_rec.source_code = 'OM' THEN
      OPEN  c_order_line_type(p_volume_detail_rec.line_id);
      FETCH c_order_line_type INTO l_order_line_type;
      CLOSE c_order_line_type;

      IF l_order_line_type.line_category_code = 'RETURN' AND l_order_line_type.reference_line_id IS NOT NULL THEN -- return order with reference SO#
        OPEN  c_rma_ref_line_detail(p_offer_id, l_order_line_type.reference_line_id, p_indirect_flag);
        FETCH c_rma_ref_line_detail INTO l_rma_ref_line_detail;
        CLOSE c_rma_ref_line_detail;

        INSERT INTO ozf_order_group_prod
        (
           order_group_prod_id
          ,creation_date
          ,created_by
          ,last_update_date
          ,last_updated_by
          ,last_update_login
          ,order_line_id
          ,offer_id
          ,qp_list_header_id
          ,group_no
          ,volume_track_type
          ,combine_schedule_yn
          ,pbh_line_id
          ,volume_type
          ,prod_attribute
          ,prod_attr_value
          ,apply_discount_flag
          ,include_volume_flag
          ,indirect_flag
        )
        VALUES
        (  ozf_order_group_prod_s.NEXTVAL
          ,SYSDATE
          ,FND_GLOBAL.user_id
          ,SYSDATE
          ,FND_GLOBAL.user_id
          ,FND_GLOBAL.conc_login_id
          ,p_volume_detail_rec.line_id
          ,l_rma_ref_line_detail.offer_id
          ,l_rma_ref_line_detail.qp_list_header_id
          ,l_rma_ref_line_detail.group_no
          ,l_rma_ref_line_detail.volume_track_type
          ,l_rma_ref_line_detail.combine_schedule_yn
          ,l_rma_ref_line_detail.pbh_line_id
          ,l_rma_ref_line_detail.volume_type
          ,l_rma_ref_line_detail.prod_attribute
          ,l_rma_ref_line_detail.prod_attr_value
          ,l_rma_ref_line_detail.apply_discount_flag
          ,l_rma_ref_line_detail.include_volume_flag
          ,l_rma_ref_line_detail.indirect_flag
        );
      END IF;
    END IF;

    --ozf_utility_pvt.write_conc_log('offer_id: ' || p_offer_id);

    --kdass fixed bug 6008340
    OPEN  c_group_prod(p_offer_id, p_volume_detail_rec.line_id, p_indirect_flag);
    FETCH c_group_prod INTO l_group_no, l_volume_track_type, l_combine_schedule_yn, l_pbh_line_id, l_volume_type, l_include_volume;
    CLOSE c_group_prod;

    IF p_indirect_flag = 'O' THEN
       select split_from_line_id into l_split_from_line_id from OE_ORDER_LINES_ALL where line_id =  p_volume_detail_rec.line_id;
       IF (l_split_from_line_id IS NOT NULL) THEN
          ozf_utility_pvt.write_conc_log('split_from_line_id: ' || l_split_from_line_id);
          OPEN  c_group_prod(p_offer_id, l_split_from_line_id, p_indirect_flag);
          FETCH c_group_prod INTO l_group_no, l_volume_track_type, l_combine_schedule_yn, l_pbh_line_id, l_volume_type, l_include_volume;
          CLOSE c_group_prod;
       END IF;
    END IF;

    ozf_utility_pvt.write_conc_log('group_no: ' || l_group_no);
    ozf_utility_pvt.write_conc_log('volume_track_type ' || l_volume_track_type);
    ozf_utility_pvt.write_conc_log('combine_schedule_yn ' || l_combine_schedule_yn);
    ozf_utility_pvt.write_conc_log('pbh_line_id ' || l_pbh_line_id);
    ozf_utility_pvt.write_conc_log('volume_type ' || l_volume_type);
    ozf_utility_pvt.write_conc_log('include_volume ' || l_include_volume);
    ozf_utility_pvt.write_conc_log('p_sign ' || p_sign);
    ozf_utility_pvt.write_conc_log('quantity ' || p_volume_detail_rec.quantity);
    ozf_utility_pvt.write_conc_log('amount ' || p_volume_detail_rec.amount);

  IF l_volume_type = 'PRICING_ATTRIBUTE10' THEN
    IF p_volume_detail_rec.source_code = 'IS' THEN
      l_current_volume := p_volume_detail_rec.quantity;
    ELSE
      l_current_volume := p_sign * p_volume_detail_rec.quantity;
    END IF;
  ELSIF l_volume_type = 'PRICING_ATTRIBUTE12' THEN
    OPEN  c_currency_code(p_offer_id);
    FETCH c_currency_code INTO l_currency_code;
    CLOSE c_currency_code;

    IF l_currency_code <> p_volume_detail_rec.currency_code THEN
        --Added for bug 7030415
        OPEN c_get_conversion_type(p_volume_detail_rec.org_id);
        FETCH c_get_conversion_type INTO l_exchange_rate_type;
        CLOSE c_get_conversion_type;

      ozf_utility_pvt.convert_currency(x_return_status => l_return_status
                                      ,p_from_currency => p_volume_detail_rec.currency_code
                                      ,p_to_currency   => l_currency_code
                                      ,p_conv_type     => l_exchange_rate_type --nirprasa, Added for bug 7030415
                                      ,p_conv_date     => p_volume_detail_rec.transaction_date
                                      ,p_from_amount   => p_volume_detail_rec.amount
                                      ,x_to_amount     => l_convert_amt
                                      ,x_rate          => l_rate); --7030415

      IF l_return_status <> fnd_api.g_ret_sts_success THEN
        ozf_utility_pvt.write_conc_log('Convert Currency failed');
        RAISE Fnd_Api.g_exc_unexpected_error;
      END IF;

      IF p_volume_detail_rec.source_code = 'OM' THEN
        l_current_volume := l_convert_amt; -- for OM return order, amount is already negative
      ELSE
        l_current_volume := p_sign * l_convert_amt; -- for IDSM amount is always positive. need to convert for retrun order
      END IF;
    ELSE
      IF p_volume_detail_rec.source_code = 'OM' THEN
        l_current_volume := p_volume_detail_rec.amount; -- for OM return order, amount is already negative
      ELSE
        l_current_volume := p_sign * p_volume_detail_rec.amount; -- for IDSM amount is always positive. need to convert for retrun order
      END IF;
    END IF;
  END IF;
ozf_utility_pvt.write_conc_log('l_current_volume ' || l_current_volume);
  IF l_include_volume = 'Y' THEN
    -- process volume detail
    INSERT INTO ozf_volume_detail
    (
       volume_detail_id
      ,creation_date
      ,created_by
      ,last_update_date
      ,last_updated_by
      ,last_update_login
      ,offer_id
      ,qp_list_header_id
      ,distributor_acct_id
      ,cust_account_id
      ,bill_to_site_use_id
      ,ship_to_site_use_id
      ,inventory_item_id
      ,volume_type
      ,uom_code
      ,currency_code
      ,volume
      ,group_no
      ,volume_track_type
      ,order_line_id
      ,transaction_date
      ,pbh_line_id
      ,include_volume_flag
      ,source_code
    )
    VALUES
    (
       ozf_volume_detail_s.NEXTVAL
      ,SYSDATE
      ,FND_GLOBAL.user_id
      ,SYSDATE
      ,FND_GLOBAL.user_id
      ,FND_GLOBAL.conc_login_id
      ,p_offer_id
      ,p_qp_list_header_id
      ,p_volume_detail_rec.sold_from_cust_account_id
      ,p_volume_detail_rec.sold_to_cust_account_id
      ,p_volume_detail_rec.bill_to_site_use_id
      ,p_volume_detail_rec.ship_to_site_use_id
      ,p_volume_detail_rec.inventory_item_id
      ,l_volume_type
      ,p_volume_detail_rec.uom_code
      ,l_currency_code
      ,l_current_volume
      ,l_group_no
      ,l_volume_track_type
      ,p_volume_detail_rec.line_id
      ,p_volume_detail_rec.transaction_date
      ,l_pbh_line_id
      ,l_include_volume
      ,p_volume_detail_rec.source_code
    );

    -- process volume summary
    -- 1. group's volume
    IF l_volume_track_type = 'GROUP' THEN
      l_volume_exists := 'N';
      OPEN  c_group_volume_exists(p_offer_id, l_group_no, l_pbh_line_id);
      FETCH c_group_volume_exists INTO l_volume_exists;
      CLOSE c_group_volume_exists;
ozf_utility_pvt.write_conc_log('group ' || l_volume_exists);
      IF l_volume_exists = 'Y' THEN -- update group's volume
        IF l_combine_schedule_yn = 'Y' THEN -- update all pbh lines
          UPDATE ozf_volume_summary
          SET    group_volume = group_volume + l_current_volume,
                 last_update_date = SYSDATE,
                 last_updated_by = FND_GLOBAL.user_id,
                 last_update_login = FND_GLOBAL.conc_login_id
          WHERE  offer_id = p_offer_id
          AND    group_no = l_group_no;
        ELSE -- update one pbh line only
          UPDATE ozf_volume_summary
          SET    group_volume = group_volume + l_current_volume,
                 last_update_date = SYSDATE,
                 last_updated_by = FND_GLOBAL.user_id,
                 last_update_login = FND_GLOBAL.conc_login_id
          WHERE  offer_id = p_offer_id
          AND    group_no = l_group_no
          AND    pbh_line_id = l_pbh_line_id;
        END IF;
      ELSE -- insert group's volume
        IF l_combine_schedule_yn = 'Y' THEN -- insert all pbh lines
          FOR l_pbh_line IN c_pbh_lines(p_offer_id) LOOP
            INSERT INTO ozf_volume_summary
            (
               volume_summary_id
              ,creation_date
              ,created_by
              ,last_update_date
              ,last_updated_by
              ,last_update_login
              ,offer_id
              ,qp_list_header_id
              ,group_no
              ,group_volume
              ,pbh_line_id
            )
            VALUES
            (
               ozf_volume_summary_s.NEXTVAL
              ,SYSDATE
              ,FND_GLOBAL.user_id
              ,SYSDATE
              ,FND_GLOBAL.user_id
              ,FND_GLOBAL.conc_login_id
              ,p_offer_id
              ,p_qp_list_header_id
              ,l_group_no
              ,l_current_volume
              ,l_pbh_line.offer_discount_line_id
            );
          END LOOP;
        ELSE -- insert one pbh line
          INSERT INTO ozf_volume_summary
          (
             volume_summary_id
            ,creation_date
            ,created_by
            ,last_update_date
            ,last_updated_by
            ,last_update_login
            ,offer_id
            ,qp_list_header_id
            ,group_no
            ,group_volume
            ,pbh_line_id
          )
          VALUES
          (
             ozf_volume_summary_s.NEXTVAL
            ,SYSDATE
            ,FND_GLOBAL.user_id
            ,SYSDATE
            ,FND_GLOBAL.user_id
            ,FND_GLOBAL.conc_login_id
            ,p_offer_id
            ,p_qp_list_header_id
            ,l_group_no
            ,l_current_volume
            ,l_pbh_line_id
          );
        END IF; -- end combine schedule
      END IF; -- end l_volume_exists
    END IF; -- end l_volume_track_type = 'GROUP'

    -- 2. distributor's volume
    --IF p_volume_detail_rec.sold_from_cust_account_id IS NOT NULL AND p_volume_detail_rec.sold_from_cust_account_id <> fnd_api.g_miss_num THEN
    IF p_indirect_flag = 'R' THEN -- indirect sales
    l_volume_exists := 'N';
    OPEN  c_individual_volume_exists(p_offer_id, 'DISTRIBUTOR', p_volume_detail_rec.sold_from_cust_account_id, l_pbh_line_id);
    FETCH c_individual_volume_exists INTO l_volume_exists;
    CLOSE c_individual_volume_exists;
ozf_utility_pvt.write_conc_log('distributor ' || l_volume_exists);
    IF l_volume_exists = 'Y' THEN -- update distributor's volume
      UPDATE ozf_volume_summary
      SET    individual_volume = individual_volume + l_current_volume,
             last_update_date = SYSDATE,
             last_updated_by = FND_GLOBAL.user_id,
             last_update_login = FND_GLOBAL.conc_login_id
      WHERE  offer_id = p_offer_id
      AND    individual_type = 'DISTRIBUTOR'
      AND    individual_id = p_volume_detail_rec.sold_from_cust_account_id
      AND    pbh_line_id = l_pbh_line_id;
    ELSE -- insert distributor's volume
      INSERT INTO ozf_volume_summary
      (
         volume_summary_id
        ,creation_date
        ,created_by
        ,last_update_date
        ,last_updated_by
        ,last_update_login
        ,offer_id
        ,qp_list_header_id
        ,individual_type
        ,individual_id
        ,individual_volume
        ,pbh_line_id
      )
      VALUES
      (
         ozf_volume_summary_s.NEXTVAL
        ,SYSDATE
        ,FND_GLOBAL.user_id
        ,SYSDATE
        ,FND_GLOBAL.user_id
        ,FND_GLOBAL.conc_login_id
        ,p_offer_id
        ,p_qp_list_header_id
        ,'DISTRIBUTOR'
        ,p_volume_detail_rec.sold_from_cust_account_id
        ,l_current_volume
        ,l_pbh_line_id
      );
    END IF;
    END IF; -- end distributor's volume

    -- 3. customer's volume
    l_volume_exists := 'N';
    OPEN  c_individual_volume_exists(p_offer_id, 'ACCOUNT', p_volume_detail_rec.sold_to_cust_account_id, l_pbh_line_id);
    FETCH c_individual_volume_exists INTO l_volume_exists;
    CLOSE c_individual_volume_exists;
ozf_utility_pvt.write_conc_log('account ' || l_volume_exists);
    IF l_volume_exists = 'Y' THEN -- update customer's volume
      UPDATE ozf_volume_summary
      SET    individual_volume = individual_volume + l_current_volume,
             last_update_date = SYSDATE,
             last_updated_by = FND_GLOBAL.user_id,
             last_update_login = FND_GLOBAL.conc_login_id
      WHERE  offer_id = p_offer_id
      AND    individual_type = 'ACCOUNT'
      AND    individual_id = p_volume_detail_rec.sold_to_cust_account_id
      AND    pbh_line_id = l_pbh_line_id;
    ELSE -- insert customer's volume
      INSERT INTO ozf_volume_summary
      (
         volume_summary_id
        ,creation_date
        ,created_by
        ,last_update_date
        ,last_updated_by
        ,last_update_login
        ,offer_id
        ,qp_list_header_id
        ,individual_type
        ,individual_id
        ,individual_volume
        ,pbh_line_id
      )
      VALUES
      (
         ozf_volume_summary_s.NEXTVAL
        ,SYSDATE
        ,FND_GLOBAL.user_id
        ,SYSDATE
        ,FND_GLOBAL.user_id
        ,FND_GLOBAL.conc_login_id
        ,p_offer_id
        ,p_qp_list_header_id
        ,'ACCOUNT'
        ,p_volume_detail_rec.sold_to_cust_account_id
        ,l_current_volume
        ,l_pbh_line_id
      );
    END IF;

    -- 4. bill_to's volume
    l_volume_exists := 'N';
    OPEN  c_individual_volume_exists(p_offer_id, 'BILL_TO', p_volume_detail_rec.bill_to_site_use_id, l_pbh_line_id);
    FETCH c_individual_volume_exists INTO l_volume_exists;
    CLOSE c_individual_volume_exists;
ozf_utility_pvt.write_conc_log('bill_to ' || l_volume_exists);
    IF l_volume_exists = 'Y' THEN -- update bill_to's volume
      UPDATE ozf_volume_summary
      SET    individual_volume = individual_volume + l_current_volume,
             last_update_date = SYSDATE,
             last_updated_by = FND_GLOBAL.user_id,
             last_update_login = FND_GLOBAL.conc_login_id
      WHERE  offer_id = p_offer_id
      AND    individual_type = 'BILL_TO'
      AND    individual_id = p_volume_detail_rec.bill_to_site_use_id
      AND    pbh_line_id = l_pbh_line_id;
    ELSE -- insert bill_to's volume
      INSERT INTO ozf_volume_summary
      (
         volume_summary_id
        ,creation_date
        ,created_by
        ,last_update_date
        ,last_updated_by
        ,last_update_login
        ,offer_id
        ,qp_list_header_id
        ,individual_type
        ,individual_id
        ,individual_volume
        ,pbh_line_id
      )
      VALUES
      (
         ozf_volume_summary_s.NEXTVAL
        ,SYSDATE
        ,FND_GLOBAL.user_id
        ,SYSDATE
        ,FND_GLOBAL.user_id
        ,FND_GLOBAL.conc_login_id
        ,p_offer_id
        ,p_qp_list_header_id
        ,'BILL_TO'
        ,p_volume_detail_rec.bill_to_site_use_id
        ,l_current_volume
        ,l_pbh_line_id
      );
    END IF;

    -- 5. ship_to's volume
    l_volume_exists := 'N';
    OPEN  c_individual_volume_exists(p_offer_id, 'SHIP_TO', p_volume_detail_rec.ship_to_site_use_id, l_pbh_line_id);
    FETCH c_individual_volume_exists INTO l_volume_exists;
    CLOSE c_individual_volume_exists;
ozf_utility_pvt.write_conc_log('ship to ' || l_volume_exists);
    IF l_volume_exists = 'Y' THEN -- update ship_to's volume
      UPDATE ozf_volume_summary
      SET    individual_volume = individual_volume + l_current_volume,
             last_update_date = SYSDATE,
             last_updated_by = FND_GLOBAL.user_id,
             last_update_login = FND_GLOBAL.conc_login_id
      WHERE  offer_id = p_offer_id
      AND    individual_type = 'SHIP_TO'
      AND    individual_id = p_volume_detail_rec.ship_to_site_use_id
      AND    pbh_line_id = l_pbh_line_id;
    ELSE -- insert ship_to's volume
      INSERT INTO ozf_volume_summary
      (
         volume_summary_id
        ,creation_date
        ,created_by
        ,last_update_date
        ,last_updated_by
        ,last_update_login
        ,offer_id
        ,qp_list_header_id
        ,individual_type
        ,individual_id
        ,individual_volume
        ,pbh_line_id
      )
      VALUES
      (
         ozf_volume_summary_s.NEXTVAL
        ,SYSDATE
        ,FND_GLOBAL.user_id
        ,SYSDATE
        ,FND_GLOBAL.user_id
        ,FND_GLOBAL.conc_login_id
        ,p_offer_id
        ,p_qp_list_header_id
        ,'SHIP_TO'
        ,p_volume_detail_rec.ship_to_site_use_id
        ,l_current_volume
        ,l_pbh_line_id
      );
    END IF;
  END IF; -- end l_include_volume = 'Y'
  END IF; -- end line_processed = 'N'
  END IF; -- end offer_id is null

  EXCEPTION
     WHEN OTHERS THEN
     x_return_status := Fnd_Api.g_ret_sts_unexp_error;
     ROLLBACK TO insert_volume;
     IF Fnd_Msg_Pub.Check_Msg_Level ( Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR )
     THEN
        Fnd_Msg_Pub.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
     Fnd_Msg_Pub.Count_AND_Get
       ( p_count      =>      x_msg_count,
         p_data       =>      x_msg_data,
         p_encoded    =>      Fnd_Api.G_FALSE
        );
END insert_volume;


PROCEDURE create_volume
(
   p_init_msg_list     IN  VARCHAR2
  ,p_api_version       IN  NUMBER
  ,p_commit            IN  VARCHAR2
  ,x_return_status     OUT NOCOPY VARCHAR2
  ,x_msg_count         OUT NOCOPY NUMBER
  ,x_msg_data          OUT NOCOPY VARCHAR2
  ,p_volume_detail_rec IN  ozf_sales_transactions_pvt.sales_transaction_rec_type
  ,p_qp_list_header_id IN  NUMBER
  ,x_apply_discount    OUT NOCOPY VARCHAR2
)
IS
   CURSOR c_offer_id_om(p_order_line_id NUMBER, p_object_type VARCHAR2) IS
  SELECT off.offer_id, off.qp_list_header_id
  FROM   ozf_offers off, ozf_funds_utilized_all_b utl
  WHERE  off.qp_list_header_id = utl.plan_id
  AND    off.offer_type = 'VOLUME_OFFER'
  AND    utl.plan_type = 'OFFR'
  AND    utl.order_line_id = p_order_line_id
 --AND    ((off.volume_offer_type = 'ACCRUAL' AND utl.utilization_type IN ('ACCRUAL', 'SALES_ACCRUAL'))
 -- Need to consider the backdated adjustment created for booked orders
 --changed for bug 6021635
  AND    ((off.volume_offer_type = 'ACCRUAL' AND (utl.utilization_type IN ('ACCRUAL', 'SALES_ACCRUAL') or (utl.utilization_type IN ('ACCRUAL', 'SALES_ACCRUAL','ADJUSTMENT')
  AND utl.price_adjustment_id=-1)))
          OR (off.volume_offer_type = 'OFF_INVOICE' AND utl.utilization_type = 'UTILIZED'))
--  AND    utl.utilization_type = DECODE(off.volume_offer_type, 'ACCRUAL', 'ACCRUAL', 'OFF_INVOICE', 'UTILIZED')
  AND    utl.object_type = p_object_type;

  CURSOR c_offer_id_is(p_order_line_id NUMBER, p_object_type VARCHAR2) IS
  SELECT off.offer_id, off.qp_list_header_id
  FROM   ozf_offers off, ozf_funds_utilized_all_b utl
  WHERE  off.qp_list_header_id = utl.plan_id
  AND    off.offer_type = 'VOLUME_OFFER'
  AND    utl.plan_type = 'OFFR'
  AND    utl.object_id = p_order_line_id
  AND    ((off.volume_offer_type = 'ACCRUAL' AND utl.utilization_type IN ('ACCRUAL', 'SALES_ACCRUAL'))
          OR (off.volume_offer_type = 'OFF_INVOICE' AND utl.utilization_type = 'UTILIZED'))
--  AND    utl.utilization_type = DECODE(off.volume_offer_type, 'ACCRUAL', 'ACCRUAL', 'OFF_INVOICE', 'UTILIZED')
  AND    utl.object_type = p_object_type;

  CURSOR c_offer_id IS
  SELECT offer_id, qp_list_header_id
  FROM   ozf_offers
  WHERE  offer_type = 'VOLUME_OFFER'
  AND    qp_list_header_id = p_qp_list_header_id;

  l_offer_id            NUMBER;
  l_qp_list_header_id   NUMBER;
  l_object_type         VARCHAR2(30);
  l_indirect_flag       VARCHAR2(1);
  l_sign                NUMBER;
  l_api_name            CONSTANT VARCHAR2(30) := 'create_volume';

BEGIN
  SAVEPOINT create_volume;
  x_return_status := Fnd_Api.g_ret_sts_success;
  ozf_utility_pvt.write_conc_log('========================= Create Volume =========================');
ozf_utility_pvt.write_conc_log('enter creat_volume : ' || p_volume_detail_rec.line_id);
ozf_utility_pvt.write_conc_log('source_code ' || p_volume_detail_rec.source_code);
ozf_utility_pvt.write_conc_log('transfer_type ' || p_volume_detail_rec.transfer_type);
ozf_utility_pvt.write_conc_log('sold_from_cust_account_id ' || p_volume_detail_rec.sold_from_cust_account_id);
ozf_utility_pvt.write_conc_log('sold_to_cust_account_id ' || p_volume_detail_rec.sold_to_cust_account_id);
ozf_utility_pvt.write_conc_log('bill_to_site_use_id ' || p_volume_detail_rec.bill_to_site_use_id);
ozf_utility_pvt.write_conc_log('ship_to_site_use_id ' || p_volume_detail_rec.ship_to_site_use_id);
ozf_utility_pvt.write_conc_log('inventory_item_id ' || p_volume_detail_rec.inventory_item_id);
ozf_utility_pvt.write_conc_log('qp_list_header_id ' || p_qp_list_header_id);

  IF p_volume_detail_rec.source_code = 'OM' THEN
    l_object_type := 'ORDER';
    l_indirect_flag := 'O';

    IF p_volume_detail_rec.transfer_type = 'IN' THEN -- for OM, IN = sales OUT = return
      l_sign := 1;
    ELSIF p_volume_detail_rec.transfer_type = 'OUT' THEN
      l_sign := -1;
    END IF;

    IF p_qp_list_header_id IS NULL OR p_qp_list_header_id = fnd_api.g_miss_num THEN
      FOR l_offer_id_om IN c_offer_id_om(p_volume_detail_rec.line_id, l_object_type) loop
        ozf_utility_pvt.write_conc_log('OM offer_id 1: ' || l_offer_id_om.offer_id);
        insert_volume(
          p_init_msg_list     => p_init_msg_list
         ,p_api_version       => p_api_version
         ,p_commit            => p_commit
         ,x_return_status     => x_return_status
         ,x_msg_count         => x_msg_count
         ,x_msg_data          => x_msg_data
         ,p_volume_detail_rec => p_volume_detail_rec
         ,p_qp_list_header_id => l_offer_id_om.qp_list_header_id
         ,p_offer_id          => l_offer_id_om.offer_id
         ,p_indirect_flag     => l_indirect_flag
         ,p_sign              => l_sign);
      END LOOP;
    ELSE
      OPEN  c_offer_id;
      FETCH c_offer_id INTO l_offer_id, l_qp_list_header_id;
      CLOSE c_offer_id;

      ozf_utility_pvt.write_conc_log('OM offer_id 2: ' || l_offer_id);
      insert_volume(
        p_init_msg_list     => p_init_msg_list
       ,p_api_version       => p_api_version
       ,p_commit            => p_commit
       ,x_return_status     => x_return_status
       ,x_msg_count         => x_msg_count
       ,x_msg_data          => x_msg_data
       ,p_volume_detail_rec => p_volume_detail_rec
       ,p_qp_list_header_id => l_qp_list_header_id
       ,p_offer_id          => l_offer_id
       ,p_indirect_flag     => l_indirect_flag
       ,p_sign              => l_sign);
    END IF;
  ELSIF p_volume_detail_rec.source_code = 'IS' THEN
    l_object_type := 'TP_ORDER';
    l_indirect_flag := 'R';

    IF p_volume_detail_rec.transfer_type = 'IN' THEN -- for IS, IN = return OUT = sales
      l_sign := -1;
    ELSIF p_volume_detail_rec.transfer_type = 'OUT' THEN
      l_sign := 1;
    END IF;

    IF p_qp_list_header_id IS NULL OR p_qp_list_header_id = fnd_api.g_miss_num THEN
      FOR l_offer_id_is IN c_offer_id_is(p_volume_detail_rec.line_id, l_object_type) LOOP
        ozf_utility_pvt.write_conc_log('IS offer_id 1: ' || l_offer_id_is.offer_id);
        insert_volume(
          p_init_msg_list     => p_init_msg_list
         ,p_api_version       => p_api_version
         ,p_commit            => p_commit
         ,x_return_status     => x_return_status
         ,x_msg_count         => x_msg_count
         ,x_msg_data          => x_msg_data
         ,p_volume_detail_rec => p_volume_detail_rec
         ,p_qp_list_header_id => l_offer_id_is.qp_list_header_id
         ,p_offer_id          => l_offer_id_is.offer_id
         ,p_indirect_flag     => l_indirect_flag
         ,p_sign              => l_sign);
      END LOOP;
    ELSE
      OPEN  c_offer_id;
      FETCH c_offer_id INTO l_offer_id, l_qp_list_header_id;
      CLOSE c_offer_id;

      ozf_utility_pvt.write_conc_log('IS offer_id 2: ' || l_offer_id);
      insert_volume(
        p_init_msg_list     => p_init_msg_list
       ,p_api_version       => p_api_version
       ,p_commit            => p_commit
       ,x_return_status     => x_return_status
       ,x_msg_count         => x_msg_count
       ,x_msg_data          => x_msg_data
       ,p_volume_detail_rec => p_volume_detail_rec
       ,p_qp_list_header_id => l_qp_list_header_id
       ,p_offer_id          => l_offer_id
       ,p_indirect_flag     => l_indirect_flag
       ,p_sign              => l_sign);
    END IF;
  END IF;
ozf_utility_pvt.write_conc_log('indirect_flag ' || l_indirect_flag);

  EXCEPTION
     WHEN OTHERS THEN
     x_return_status := Fnd_Api.g_ret_sts_unexp_error;
     ROLLBACK TO create_volume;
     IF Fnd_Msg_Pub.Check_Msg_Level ( Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR )
     THEN
        Fnd_Msg_Pub.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
     Fnd_Msg_Pub.Count_AND_Get
       ( p_count      =>      x_msg_count,
         p_data       =>      x_msg_data,
         p_encoded    =>      Fnd_Api.G_FALSE
        );
END create_volume;


PROCEDURE get_as_of_date_volume
(
   p_offer_id            IN  NUMBER
  ,p_distributor_acct_id IN  NUMBER
  ,p_cust_account_id     IN  NUMBER
  ,p_bill_to             IN  NUMBER
  ,p_ship_to             IN  NUMBER
  ,p_group_no            IN  NUMBER
  ,p_combine_schedule    IN  VARCHAR2
  ,p_volume_track_type   IN  VARCHAR2
  ,p_pbh_line_id         IN  NUMBER
  ,p_transaction_date    IN  DATE
  ,p_order_line_id       IN  NUMBER
  ,p_source_code         IN  VARCHAR2
  ,x_acc_volume          OUT NOCOPY NUMBER
)
IS
  -- julou bug 6348078. volume before trx_date
  CURSOR c_group_volume(p_volume_track_id NUMBER) IS
  SELECT NVL(SUM(volume), 0)
  FROM   ozf_volume_detail
  WHERE  include_volume_flag = 'Y'
  AND    offer_id = p_offer_id
  AND    group_no = p_volume_track_id
  AND    pbh_line_id = p_pbh_line_id
  AND    transaction_date < p_transaction_date;

  CURSOR c_dist_volume(p_volume_track_id NUMBER) IS
  SELECT NVL(SUM(volume), 0)
  FROM   ozf_volume_detail
  WHERE  include_volume_flag = 'Y'
  AND    offer_id = p_offer_id
  AND    distributor_acct_id = p_volume_track_id
  AND    pbh_line_id = p_pbh_line_id
  AND    transaction_date < p_transaction_date;

  CURSOR c_customer_volume(p_volume_track_id NUMBER) IS
  SELECT NVL(SUM(volume), 0)
  FROM   ozf_volume_detail
  WHERE  include_volume_flag = 'Y'
  AND    offer_id = p_offer_id
  AND    cust_account_id = p_volume_track_id
  AND    pbh_line_id = p_pbh_line_id
  AND    transaction_date < p_transaction_date;

  CURSOR c_billto_volume(p_volume_track_id NUMBER) IS
  SELECT NVL(SUM(volume), 0)
  FROM   ozf_volume_detail
  WHERE  include_volume_flag = 'Y'
  AND    offer_id = p_offer_id
  AND    bill_to_site_use_id = p_volume_track_id
  AND    pbh_line_id = p_pbh_line_id
  AND    transaction_date < p_transaction_date;

  CURSOR c_shipto_volume(p_volume_track_id NUMBER) IS
  SELECT NVL(SUM(volume), 0)
  FROM   ozf_volume_detail
  WHERE  include_volume_flag = 'Y'
  AND    offer_id = p_offer_id
  AND    ship_to_site_use_id = p_volume_track_id
  AND    pbh_line_id = p_pbh_line_id
  AND    transaction_date < p_transaction_date;

  CURSOR c_combine_group_volume(p_volume_track_id NUMBER) IS
  SELECT NVL(SUM(volume), 0)
  FROM   ozf_volume_detail
  WHERE  include_volume_flag = 'Y'
  AND    offer_id = p_offer_id
  AND    group_no = p_volume_track_id
  AND    transaction_date < p_transaction_date;

  CURSOR c_combine_dist_volume(p_volume_track_id NUMBER) IS
  SELECT NVL(SUM(volume), 0)
  FROM   ozf_volume_detail
  WHERE  include_volume_flag = 'Y'
  AND    offer_id = p_offer_id
  AND    distributor_acct_id = p_volume_track_id
  AND    transaction_date < p_transaction_date;

  CURSOR c_combine_customer_volume(p_volume_track_id NUMBER) IS
  SELECT NVL(SUM(volume), 0)
  FROM   ozf_volume_detail
  WHERE  include_volume_flag = 'Y'
  AND    offer_id = p_offer_id
  AND    cust_account_id = p_volume_track_id
  AND    transaction_date < p_transaction_date;

  CURSOR c_combine_billto_volume(p_volume_track_id NUMBER) IS
  SELECT NVL(SUM(volume), 0)
  FROM   ozf_volume_detail
  WHERE  include_volume_flag = 'Y'
  AND    offer_id = p_offer_id
  AND    bill_to_site_use_id = p_volume_track_id
  AND    transaction_date < p_transaction_date;

  CURSOR c_combine_shipto_volume(p_volume_track_id NUMBER) IS
  SELECT NVL(SUM(volume), 0)
  FROM   ozf_volume_detail
  WHERE  include_volume_flag = 'Y'
  AND    offer_id = p_offer_id
  AND    ship_to_site_use_id = p_volume_track_id
  AND    transaction_date < p_transaction_date;

  CURSOR c_trx_date_volume_pk IS -- PK of volume rec for given order_line_id.
  SELECT volume_detail_id
  FROM   ozf_volume_detail
  WHERE  include_volume_flag = 'Y'
  AND    offer_id = p_offer_id
  AND    source_code = p_source_code
  AND    order_line_id = p_order_line_id;

  l_pk NUMBER := NULL;

  -- volume of trx_date. if multiple entries found, sum volume by primary key.
  CURSOR c_group_volume2(p_volume_track_id NUMBER, p_volume_detail_id NUMBER) IS
  SELECT NVL(SUM(volume), 0)
  FROM   ozf_volume_detail
  WHERE  include_volume_flag = 'Y'
  AND    offer_id = p_offer_id
  AND    group_no = p_volume_track_id
  AND    pbh_line_id = p_pbh_line_id
  AND    transaction_date = p_transaction_date
  AND    volume_detail_id <= p_volume_detail_id;

  CURSOR c_dist_volume2(p_volume_track_id NUMBER, p_volume_detail_id NUMBER) IS
  SELECT NVL(SUM(volume), 0)
  FROM   ozf_volume_detail
  WHERE  include_volume_flag = 'Y'
  AND    offer_id = p_offer_id
  AND    distributor_acct_id = p_volume_track_id
  AND    pbh_line_id = p_pbh_line_id
  AND    transaction_date = p_transaction_date
  AND    volume_detail_id <= p_volume_detail_id;

  CURSOR c_customer_volume2(p_volume_track_id NUMBER, p_volume_detail_id NUMBER) IS
  SELECT NVL(SUM(volume), 0)
  FROM   ozf_volume_detail
  WHERE  include_volume_flag = 'Y'
  AND    offer_id = p_offer_id
  AND    cust_account_id = p_volume_track_id
  AND    pbh_line_id = p_pbh_line_id
  AND    transaction_date = p_transaction_date
  AND    volume_detail_id <= p_volume_detail_id;

  -- fix for bug 7353241
/*The trunc function is needed by off-invoice volume offeras transaction_date in
ozf_volume_detail is 00:00:00.
The input parameter p_transaction_date has to be truncated before comparing with table value.
On the other hand, trunc screws accrual incentive. As you know the calculation has two parts,
one for transactions before the day, the other for transactions on the day.
This is mainly for IDSM transactions as transactions may not come in the order of time.
So we need 2 cursors to handle two types of incentive of volume offer.*/

  CURSOR c_customer_volume3(p_volume_track_id NUMBER, p_volume_detail_id NUMBER) IS
  SELECT NVL(SUM(volume), 0)
  FROM   ozf_volume_detail
  WHERE  include_volume_flag = 'Y'
  AND    offer_id = p_offer_id
  AND    cust_account_id = p_volume_track_id
  AND    pbh_line_id = p_pbh_line_id
  AND    trunc(transaction_date) = trunc(p_transaction_date)
  AND    volume_detail_id <= p_volume_detail_id;

  CURSOR c_billto_volume2(p_volume_track_id NUMBER, p_volume_detail_id NUMBER) IS
  SELECT NVL(SUM(volume), 0)
  FROM   ozf_volume_detail
  WHERE  include_volume_flag = 'Y'
  AND    offer_id = p_offer_id
  AND    bill_to_site_use_id = p_volume_track_id
  AND    pbh_line_id = p_pbh_line_id
  AND    transaction_date = p_transaction_date
  AND    volume_detail_id <= p_volume_detail_id;

  CURSOR c_shipto_volume2(p_volume_track_id NUMBER, p_volume_detail_id NUMBER) IS
  SELECT NVL(SUM(volume), 0)
  FROM   ozf_volume_detail
  WHERE  include_volume_flag = 'Y'
  AND    offer_id = p_offer_id
  AND    ship_to_site_use_id = p_volume_track_id
  AND    pbh_line_id = p_pbh_line_id
  AND    transaction_date = p_transaction_date
  AND    volume_detail_id <= p_volume_detail_id;

  CURSOR c_combine_group_volume2(p_volume_track_id NUMBER, p_volume_detail_id NUMBER) IS
  SELECT NVL(SUM(volume), 0)
  FROM   ozf_volume_detail
  WHERE  include_volume_flag = 'Y'
  AND    offer_id = p_offer_id
  AND    group_no = p_volume_track_id
  AND    transaction_date = p_transaction_date
  AND    volume_detail_id <= p_volume_detail_id;

  CURSOR c_combine_dist_volume2(p_volume_track_id NUMBER, p_volume_detail_id NUMBER) IS
  SELECT NVL(SUM(volume), 0)
  FROM   ozf_volume_detail
  WHERE  include_volume_flag = 'Y'
  AND    offer_id = p_offer_id
  AND    distributor_acct_id = p_volume_track_id
  AND    transaction_date = p_transaction_date
  AND    volume_detail_id <= p_volume_detail_id;

  CURSOR c_combine_customer_volume2(p_volume_track_id NUMBER, p_volume_detail_id NUMBER) IS
  SELECT NVL(SUM(volume), 0)
  FROM   ozf_volume_detail
  WHERE  include_volume_flag = 'Y'
  AND    offer_id = p_offer_id
  AND    cust_account_id = p_volume_track_id
  AND    transaction_date = p_transaction_date
  AND    volume_detail_id <= p_volume_detail_id;

  CURSOR c_combine_billto_volume2(p_volume_track_id NUMBER, p_volume_detail_id NUMBER) IS
  SELECT NVL(SUM(volume), 0)
  FROM   ozf_volume_detail
  WHERE  include_volume_flag = 'Y'
  AND    offer_id = p_offer_id
  AND    bill_to_site_use_id = p_volume_track_id
  AND    transaction_date = p_transaction_date
  AND    volume_detail_id <= p_volume_detail_id;

  CURSOR c_combine_shipto_volume2(p_volume_track_id NUMBER, p_volume_detail_id NUMBER) IS
  SELECT NVL(SUM(volume), 0)
  FROM   ozf_volume_detail
  WHERE  include_volume_flag = 'Y'
  AND    offer_id = p_offer_id
  AND    ship_to_site_use_id = p_volume_track_id
  AND    transaction_date = p_transaction_date
  AND    volume_detail_id <= p_volume_detail_id;

  CURSOR c_volume_offer_type IS
  SELECT volume_offer_type
  FROM   ozf_offers
  WHERE  offer_id = p_offer_id;

  l_volume_offer_type  VARCHAR2(30);
  l_volume_b4_trx_date NUMBER;
  l_volume_of_trx_date NUMBER;
BEGIN
  ozf_utility_pvt.write_conc_log('==================== get_as_of_date_volume ====================');

  OPEN  c_trx_date_volume_pk;
  FETCH c_trx_date_volume_pk INTO l_pk;
  CLOSE c_trx_date_volume_pk;
  ozf_utility_pvt.write_conc_log('PK is ' || l_pk);

  IF p_combine_schedule = 'N' THEN
    IF p_volume_track_type = 'GROUP' THEN
        OPEN  c_group_volume(p_group_no);
        FETCH c_group_volume INTO l_volume_b4_trx_date;
        CLOSE c_group_volume;

        OPEN  c_group_volume2(p_group_no, l_pk);
        FETCH c_group_volume2 INTO l_volume_of_trx_date;
        CLOSE c_group_volume2;
    ELSIF p_volume_track_type = 'DISTRIBUTOR' THEN
        OPEN  c_dist_volume(p_distributor_acct_id);
        FETCH c_dist_volume INTO l_volume_b4_trx_date;
        CLOSE c_dist_volume;

        OPEN  c_dist_volume2(p_distributor_acct_id, l_pk);
        FETCH c_dist_volume2 INTO l_volume_of_trx_date;
        CLOSE c_dist_volume2;
    ELSIF p_volume_track_type = 'ACCOUNT' THEN
        OPEN  c_customer_volume(p_cust_account_id);
        FETCH c_customer_volume INTO l_volume_b4_trx_date;
        CLOSE c_customer_volume;

        --Fix for bug 7353241

        OPEN c_volume_offer_type;
        FETCH c_volume_offer_type INTO l_volume_offer_type;
        CLOSE c_volume_offer_type;

        IF l_volume_offer_type = 'ACCRUAL' THEN
                OPEN  c_customer_volume2(p_cust_account_id, l_pk);
                FETCH c_customer_volume2 INTO l_volume_of_trx_date;
                CLOSE c_customer_volume2;
        ELSIF l_volume_offer_type = 'OFF_INVOICE' THEN
                OPEN  c_customer_volume3(p_cust_account_id, l_pk);
                FETCH c_customer_volume3 INTO l_volume_of_trx_date;
                CLOSE c_customer_volume3;
        END IF;
    ELSIF p_volume_track_type = 'BILL_TO' THEN
        OPEN  c_billto_volume(p_bill_to);
        FETCH c_billto_volume INTO l_volume_b4_trx_date;
        CLOSE c_billto_volume;

        OPEN  c_billto_volume2(p_bill_to, l_pk);
        FETCH c_billto_volume2 INTO l_volume_of_trx_date;
        CLOSE c_billto_volume2;
    ELSIF p_volume_track_type = 'SHIP_TO' THEN
        OPEN  c_shipto_volume(p_ship_to);
        FETCH c_shipto_volume INTO l_volume_b4_trx_date;
        CLOSE c_shipto_volume;

        OPEN  c_shipto_volume2(p_ship_to, l_pk);
        FETCH c_shipto_volume2 INTO l_volume_of_trx_date;
        CLOSE c_shipto_volume2;
    END IF;
  ELSE
    IF p_volume_track_type = 'GROUP' THEN
        OPEN  c_combine_group_volume(p_group_no);
        FETCH c_combine_group_volume INTO l_volume_b4_trx_date;
        CLOSE c_combine_group_volume;

        OPEN  c_combine_group_volume2(p_group_no, l_pk);
        FETCH c_combine_group_volume2 INTO l_volume_of_trx_date;
        CLOSE c_combine_group_volume2;
    ELSIF p_volume_track_type = 'DISTRIBUTOR' THEN
        OPEN  c_combine_dist_volume(p_distributor_acct_id);
        FETCH c_combine_dist_volume INTO l_volume_b4_trx_date;
        CLOSE c_combine_dist_volume;

        OPEN  c_combine_dist_volume2(p_distributor_acct_id, l_pk);
        FETCH c_combine_dist_volume2 INTO l_volume_of_trx_date;
        CLOSE c_combine_dist_volume2;
    ELSIF p_volume_track_type = 'ACCOUNT' THEN
        OPEN  c_combine_customer_volume(p_cust_account_id);
        FETCH c_combine_customer_volume INTO l_volume_b4_trx_date;
        CLOSE c_combine_customer_volume;

        OPEN  c_combine_customer_volume2(p_cust_account_id, l_pk);
        FETCH c_combine_customer_volume2 INTO l_volume_of_trx_date;
        CLOSE c_combine_customer_volume2;
    ELSIF p_volume_track_type = 'BILL_TO' THEN
        OPEN  c_combine_billto_volume(p_bill_to);
        FETCH c_combine_billto_volume INTO l_volume_b4_trx_date;
        CLOSE c_combine_billto_volume;

        OPEN  c_combine_billto_volume2(p_bill_to, l_pk);
        FETCH c_combine_billto_volume2 INTO l_volume_of_trx_date;
        CLOSE c_combine_billto_volume2;
    ELSIF p_volume_track_type = 'SHIP_TO' THEN
        OPEN  c_combine_shipto_volume(p_ship_to);
        FETCH c_combine_shipto_volume INTO l_volume_b4_trx_date;
        CLOSE c_combine_shipto_volume;

        OPEN  c_combine_shipto_volume2(p_ship_to, l_pk);
        FETCH c_combine_shipto_volume2 INTO l_volume_of_trx_date;
        CLOSE c_combine_shipto_volume2;
    END IF;
  END IF;

  x_acc_volume := l_volume_b4_trx_date + l_volume_of_trx_date;

  ozf_utility_pvt.write_conc_log('volume b4 trx_date ' || l_volume_b4_trx_date);
  ozf_utility_pvt.write_conc_log('volume of trx_date ' || l_volume_of_trx_date);
  ozf_utility_pvt.write_conc_log('as_of_date_volume ' || x_acc_volume);

  IF x_acc_volume IS NULL THEN
    x_acc_volume := 0;
  END IF;
END get_as_of_date_volume;

PROCEDURE get_volume -- overload version 1, used by pricing
(
   p_offer_id         IN  NUMBER
  ,p_cust_acct_id     IN  NUMBER
  ,p_bill_to          IN  NUMBER
  ,p_ship_to          IN  NUMBER
  ,p_group_no         IN  NUMBER
  ,p_vol_track_type   IN  VARCHAR2
  ,p_pbh_line_id      IN  NUMBER
  ,p_combine_schedule IN VARCHAR2
  ,x_acc_volume       OUT NOCOPY NUMBER
)
IS
  CURSOR c_group_volume IS
  SELECT group_volume
  FROM   ozf_volume_summary
  WHERE  offer_id = p_offer_id
  AND    group_no = p_group_no
  AND    pbh_line_id = p_pbh_line_id;

  CURSOR c_individual_volume(p_volume_track_type VARCHAR2, p_volume_track_id NUMBER) IS
  SELECT individual_volume
  FROM   ozf_volume_summary
  WHERE  offer_id = p_offer_id
  AND    individual_type = p_vol_track_type
  AND    individual_id = p_volume_track_id
  AND    pbh_line_id = p_pbh_line_id;

  CURSOR c_combine_individual_volume(p_volume_track_type VARCHAR2, p_volume_track_id NUMBER) IS
  SELECT SUM(individual_volume)
  FROM   ozf_volume_summary
  WHERE  offer_id = p_offer_id
  AND    individual_type = p_vol_track_type
  AND    individual_id = p_volume_track_id;

  l_volume_track_type VARCHAR2(30);
  l_volume_track_id   NUMBER;
  l_api_name          CONSTANT VARCHAR2(30) := 'get_volume';
BEGIN
  SAVEPOINT get_volume;

  IF p_vol_track_type = 'GROUP' THEN
    OPEN  c_group_volume;
    FETCH c_group_volume INTO x_acc_volume;
    CLOSE c_group_volume;
  ELSE
    IF p_vol_track_type = 'ACCOUNT' THEN
      l_volume_track_id := p_cust_acct_id;
    ELSIF p_vol_track_type = 'BILL_TO' THEN
      l_volume_track_id := p_bill_to;
    ELSIF p_vol_track_type = 'SHIP_TO' THEN
      l_volume_track_id := p_ship_to;
    END IF;

    IF p_combine_schedule = 'N' THEN
      OPEN  c_individual_volume(p_vol_track_type, l_volume_track_id);
      FETCH c_individual_volume INTO x_acc_volume;
      CLOSE c_individual_volume;
    ELSE
      OPEN  c_combine_individual_volume(p_vol_track_type, l_volume_track_id);
      FETCH c_combine_individual_volume INTO x_acc_volume;
      CLOSE c_combine_individual_volume;
    END IF;
  END IF;

  IF x_acc_volume IS NULL THEN
    x_acc_volume := 0;
  END IF;

  EXCEPTION
     WHEN OTHERS THEN
     ROLLBACK TO get_volume;
     IF Fnd_Msg_Pub.Check_Msg_Level ( Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR )
     THEN
        Fnd_Msg_Pub.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
END get_volume;


PROCEDURE get_volume -- overload version 2, used by budget
(
   p_init_msg_list       IN  VARCHAR2
  ,p_api_version         IN  NUMBER
  ,p_commit              IN  VARCHAR2
  ,x_return_status       OUT NOCOPY VARCHAR2
  ,x_msg_count           OUT NOCOPY NUMBER
  ,x_msg_data            OUT NOCOPY VARCHAR2
  ,p_qp_list_header_id   IN  NUMBER
  ,p_order_line_id       IN  NUMBER
  ,p_source_code         IN  VARCHAR2 -- OM or IS
  ,p_trx_date            IN  DATE
  ,x_acc_volume          OUT NOCOPY NUMBER
)
IS
  CURSOR c_volume_detail IS
  SELECT billto_cust_account_id, bill_to_site_use_id, ship_to_site_use_id
  FROM   ozf_funds_utilized_all_b
  WHERE  (p_source_code = 'OM' AND object_type = 'ORDER' AND order_line_id = p_order_line_id)
  OR     (p_source_code = 'IS' AND object_type = 'TP_ORDER' AND object_id = p_order_line_id);

  CURSOR c_dist_acct_id IS
  SELECT sold_from_cust_account_id
  FROM   ozf_resale_lines_all
  WHERE  resale_line_id = p_order_line_id;

  CURSOR c_combine_schedule(l_qp_list_header_id NUMBER, l_order_line_id NUMBER) IS
  SELECT offer_id, combine_schedule_yn, apply_discount_flag, group_no, volume_track_type, pbh_line_id
  FROM   ozf_order_group_prod
  WHERE  qp_list_header_id = l_qp_list_header_id
  AND    order_line_id = l_order_line_id
  AND    indirect_flag = DECODE(p_source_code, 'OM', 'O', 'IS', 'R');

  CURSOR c_preset_volume(p_offer_id NUMBER, p_group_no NUMBER, p_pbh_line_id NUMBER) IS
  SELECT a.volume_from
  FROM   ozf_offer_discount_lines a, ozf_market_preset_tiers b, ozf_offr_market_options c
  WHERE  a.offer_discount_line_id = b.dis_offer_discount_id
  AND    b. pbh_offer_discount_id = p_pbh_line_id
  AND    b.offer_market_option_id = c.offer_market_option_id
  AND    c.offer_id = p_offer_id
  AND    c.group_number = p_group_no;

  l_offer_id            NUMBER;
  l_distributor_acct_id NUMBER;
  l_cust_account_id     NUMBER;
  l_bill_to             NUMBER;
  l_ship_to             NUMBER;
  l_group_no            NUMBER;
  l_volume_track_type   VARCHAR2(30);
  l_pbh_line_id         NUMBER;
  l_combine_schedule    VARCHAR2(1);
  l_apply_discount      VARCHAR2(1);
  l_acc_volume          NUMBER;
  l_split_from_line_id  NUMBER;
  l_preset_volume       NUMBER;
  l_trx_date            DATE;
  l_api_name            CONSTANT VARCHAR2(30) := 'get_volume_2';
BEGIN
  SAVEPOINT get_volume_2;
  x_return_status := Fnd_Api.g_ret_sts_success;

  OPEN  c_volume_detail;
  FETCH c_volume_detail INTO l_cust_account_id, l_bill_to, l_ship_to;
  CLOSE c_volume_detail;

  IF p_source_code = 'IS' THEN
    OPEN  c_dist_acct_id;
    FETCH c_dist_acct_id INTO l_distributor_acct_id;
    CLOSE c_dist_acct_id;
  ELSIF p_source_code = 'OM' THEN
    l_distributor_acct_id := NULL;
  END IF;

  --kdass fixed bug 6008340
  OPEN  c_combine_schedule(p_qp_list_header_id, p_order_line_id);
  FETCH c_combine_schedule INTO l_offer_id, l_combine_schedule, l_apply_discount, l_group_no, l_volume_track_type, l_pbh_line_id;
  CLOSE c_combine_schedule;

  IF p_source_code = 'OM' THEN
     SELECT split_from_line_id into l_split_from_line_id from OE_ORDER_LINES_ALL where line_id =  p_order_line_id;
     IF (l_split_from_line_id IS NOT NULL) then
        OPEN  c_combine_schedule(p_qp_list_header_id, l_split_from_line_id);
        FETCH c_combine_schedule INTO l_offer_id, l_combine_schedule, l_apply_discount, l_group_no, l_volume_track_type, l_pbh_line_id;
        CLOSE c_combine_schedule;
     END IF;
  END IF;

  l_trx_date := p_trx_date;

ozf_utility_pvt.write_conc_log('in api ' || l_api_name || ' -- ready to call get_as_of_date_volume');
ozf_utility_pvt.write_conc_log('apply discount ' || l_apply_discount);
ozf_utility_pvt.write_conc_log('other values');
ozf_utility_pvt.write_conc_log('l_offer_id/l_qp_list_header_id/l_cust_account_id/l_bill_to/l_ship_to');
ozf_utility_pvt.write_conc_log(l_offer_id || '/' || p_qp_list_header_id || '/' || l_cust_account_id || '/' || l_bill_to || '/' || l_ship_to);
ozf_utility_pvt.write_conc_log('l_group_no/l_combine_schedule/l_volume_track_type/l_pbh_line_id');
ozf_utility_pvt.write_conc_log(l_group_no || '/' || l_combine_schedule || '/' || l_volume_track_type || '/' || l_pbh_line_id);
ozf_utility_pvt.write_conc_log('p_source_code/p_order_line_id/l_trx_date');
ozf_utility_pvt.write_conc_log(p_source_code || '/' || p_order_line_id || '/' || to_char(l_trx_date, 'YYYY-MM-DD HH:MI:SS'));

  IF l_apply_discount = 'N' THEN
    x_acc_volume := 0;
  ELSE
    get_as_of_date_volume
    (
       p_offer_id            => l_offer_id
      ,p_distributor_acct_id => l_distributor_acct_id
      ,p_cust_account_id     => l_cust_account_id
      ,p_bill_to             => l_bill_to
      ,p_ship_to             => l_ship_to
      ,p_group_no            => l_group_no
      ,p_combine_schedule    => l_combine_schedule
      ,p_volume_track_type   => l_volume_track_type
      ,p_pbh_line_id         => l_pbh_line_id
      ,p_transaction_date    => l_trx_date
      ,p_order_line_id       => p_order_line_id
      ,p_source_code         => p_source_code
      ,x_acc_volume          => l_acc_volume
    );
ozf_utility_pvt.write_conc_log('calculated volume: ' || l_acc_volume);
    IF l_acc_volume IS NULL THEN
      l_acc_volume := 0;
    END IF;

    OPEN  c_preset_volume(l_offer_id, l_group_no, l_pbh_line_id);
    FETCH c_preset_volume INTO l_preset_volume;
    CLOSE c_preset_volume;
ozf_utility_pvt.write_conc_log('preset volume: ' || l_preset_volume);
    IF l_preset_volume IS NULL THEN
      l_preset_volume := 0;
    END IF;

    IF l_acc_volume > l_preset_volume THEN
      x_acc_volume := l_acc_volume;
    ELSE
      x_acc_volume := l_preset_volume;
    END IF;
  END IF;

  EXCEPTION
     WHEN OTHERS THEN
     x_return_status := Fnd_Api.g_ret_sts_unexp_error;
     ROLLBACK TO get_volume_2;
     IF Fnd_Msg_Pub.Check_Msg_Level ( Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR )
     THEN
        Fnd_Msg_Pub.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
     Fnd_Msg_Pub.Count_AND_Get
       ( p_count      =>      x_msg_count,
         p_data       =>      x_msg_data,
         p_encoded    =>      Fnd_Api.G_FALSE
        );
END get_volume;


FUNCTION get_numeric_attribute_value
(
  p_list_line_id         IN NUMBER
 ,p_list_line_no         IN VARCHAR2
 ,p_order_header_id      IN NUMBER
 ,p_order_line_id        IN NUMBER
 ,p_price_effective_date IN DATE
 ,p_req_line_attrs_tbl   IN qp_runtime_source.accum_req_line_attrs_tbl
 ,p_accum_rec            IN qp_runtime_source.accum_record_type
)
RETURN NUMBER IS
  CURSOR c_offer_id IS
  SELECT o.qp_list_header_id, o.offer_id
  FROM   ozf_offers o, qp_list_lines q
  WHERE  o.qp_list_header_id = q.list_header_id
  AND    q.list_line_id = p_list_line_id;

  CURSOR c_order_detail IS
  SELECT unit_selling_price, pricing_quantity, sold_to_org_id, ship_to_org_id, invoice_to_org_id, actual_shipment_date
  FROM   oe_order_lines_all
  WHERE  line_id = p_order_line_id;

  CURSOR c_resale_detail IS
  SELECT quantity, amount, sold_from_cust_account_id, sold_to_cust_account_id, ship_to_site_use_id, bill_to_site_use_id, transaction_date
  FROM   ozf_sales_transactions
  WHERE  line_id = p_order_line_id;

  CURSOR c_interface_detail IS
  SELECT quantity, quantity * selling_price, sold_from_cust_account_id, bill_to_cust_account_id, ship_to_site_use_id, bill_to_site_use_id, date_ordered
  FROM   ozf_resale_lines_int_all
  WHERE  resale_line_int_id = p_order_line_id;

  CURSOR c_discount_volume(p_offer_id NUMBER, p_prod_attribute VARCHAR2, p_prod_attr_value VARCHAR2) IS
  SELECT apply_discount_flag, include_volume_flag
  FROM   ozf_offer_discount_products
  WHERE  product_context = 'ITEM'
  AND    product_attribute = p_prod_attribute
  AND    product_attr_value = p_prod_attr_value
  AND    offer_id = p_offer_id;

  CURSOR c_order_group_prod_id(p_offer_id NUMBER, p_line_id NUMBER, p_indirect_flag VARCHAR2) IS
  SELECT order_group_prod_id
  FROM   ozf_order_group_prod
  WHERE  order_line_id = p_line_id
  AND    offer_id = p_offer_id
  AND    indirect_flag = p_indirect_flag;

  CURSOR c_volume_type(p_pbh_line_id NUMBER) IS
  SELECT volume_type
  FROM   ozf_offer_discount_lines
  WHERE  offer_discount_line_id = p_pbh_line_id;

  CURSOR c_preset_volume(p_offer_id NUMBER, p_group_no NUMBER, p_pbh_line_id NUMBER) IS
  SELECT a.volume_from
  FROM   ozf_offer_discount_lines a, ozf_market_preset_tiers b, ozf_offr_market_options c
  WHERE  a.offer_discount_line_id = b.dis_offer_discount_id
  AND    b. pbh_offer_discount_id = p_pbh_line_id
  AND    b.offer_market_option_id = c.offer_market_option_id
  AND    c.offer_id = p_offer_id
  AND    c.group_number = p_group_no;

  l_list_header_id   NUMBER;
  l_offer_id         NUMBER;
  l_group_no         NUMBER;
  l_pbh_line_id      NUMBER;
  l_prod_attribute   VARCHAR2(30);
  l_prod_attr_value  VARCHAR2(240);
  l_indirect_flag    VARCHAR2(1);
  l_price            NUMBER;
  l_quantity         NUMBER;
  l_amount           NUMBER;
  l_distributor      NUMBER;
  l_sold_to          NUMBER;
  l_ship_to          NUMBER;
  l_bill_to          NUMBER;
  l_trx_date         DATE;
  l_split_from_line_id  NUMBER;
  l_group_prod_order_line_id NUMBER;
  l_apply_discount   VARCHAR2(1);
  l_include_volume   VARCHAR2(1);
  l_id               NUMBER;
  l_volume_type      VARCHAR2(30);
  l_vol_track_type   VARCHAR2(30);
  l_combine_schedule VARCHAR2(1);
  l_current_volume   NUMBER;
  l_preset_volume    NUMBER;
  l_acc_volume       NUMBER;
  l_volume           NUMBER;
  l_api_name         CONSTANT VARCHAR2(30) := 'get_numeric_attribute_value';
--  l_rec_count number;
BEGIN
/*
  INSERT INTO om_qp_temp(id, rec_req_type, access_date, line_index)
  VALUES(om_qp_temp_s.nextval, 'START', SYSDATE, -9999);

  l_rec_count := p_req_line_attrs_tbl.COUNT;

  INSERT INTO om_qp_temp(
    id,
    rec_context,
    rec_attr,
    access_date,
    line_index,
    group_num,
    order_line_id,
    list_line_id)
  VALUES(om_qp_temp_s.nextval,
    p_accum_rec.context,
    p_accum_rec.attribute,
    sysdate,
    0,
    l_rec_count,
    p_order_line_id,
    p_list_line_id);

  FOR i IN 1..p_req_line_attrs_tbl.COUNT LOOP
    INSERT INTO om_qp_temp(
      id,
      access_date,
      line_index,
      attr_type,
      context,
      attr,
      attr_value,
      group_num,
      order_line_id,
      list_line_id)
    VALUES(
      om_qp_temp_s.nextval,
      sysdate,
      p_req_line_attrs_tbl(i).line_index,
      p_req_line_attrs_tbl(i).attribute_type,
      p_req_line_attrs_tbl(i).context,
      p_req_line_attrs_tbl(i).attribute,
      p_req_line_attrs_tbl(i).value,
      p_req_line_attrs_tbl(i).grouping_no,
      p_order_line_id,
      p_list_line_id);
  END LOOP;
*/
  SAVEPOINT get_numeric_attribute_value;

  IF OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL.COUNT > 0 THEN
    IF OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(1).batch_type <> 'TP_ACCRUAL' THEN
      RETURN 0;
    END IF;
  END IF;

  OPEN  c_offer_id;
  FETCH c_offer_id INTO l_list_header_id, l_offer_id;
  CLOSE c_offer_id;

  get_group_pbh_prod
  (
     p_offer_id           => l_offer_id
    ,p_list_header_id     => l_list_header_id
    ,p_list_line_id       => p_list_line_id
    ,p_req_line_attrs_tbl => p_req_line_attrs_tbl
    ,p_order_line_id      => p_order_line_id
    ,x_group_no           => l_group_no
    ,x_vol_track_type     => l_vol_track_type
    ,x_combine_schedule   => l_combine_schedule
    ,x_pbh_line_id        => l_pbh_line_id
    ,x_pord_attribute     => l_prod_attribute
    ,x_prod_attr_value    => l_prod_attr_value
    ,x_indirect_flag      => l_indirect_flag
  );

  OPEN  c_volume_type(l_pbh_line_id);
  FETCH c_volume_type INTO l_volume_type;
  CLOSE c_volume_type;

  OPEN  c_discount_volume(l_offer_id, l_prod_attribute, l_prod_attr_value);
  FETCH c_discount_volume INTO l_apply_discount, l_include_volume;
  CLOSE c_discount_volume;

  --kdass fixed bug 6008340
  l_group_prod_order_line_id := p_order_line_id;

  IF l_indirect_flag = 'O' THEN
     select split_from_line_id into l_split_from_line_id from OE_ORDER_LINES_ALL where line_id =  p_order_line_id;
     IF (l_split_from_line_id IS NOT NULL) THEN
        --l_group_prod_order_line_id := l_split_from_line_id;
        -- inanaiah: Added for bug 5975678 fix
        IF (p_order_line_id = l_split_from_line_id) THEN
           -- This happens when SO is split, the first child split has the same line_id as the parent SO
           l_group_prod_order_line_id := l_split_from_line_id;
        ELSE
           -- For the second, third,...splits, the selected split records need to be created/updated in ozf_order_group_prod
           -- In the earlier version the l_split_from_line_id record of ozf_order_group_prod was updated with
           -- order_line_id = p_order_line_id
           -- resulting in losing the l_split_from_line_id record in ozf_order_group_prod.
           l_group_prod_order_line_id := p_order_line_id;
        END IF;
     END IF;
  END IF;

  OPEN  c_order_group_prod_id(l_offer_id, l_group_prod_order_line_id, l_indirect_flag);
  FETCH c_order_group_prod_id INTO l_id;
  CLOSE c_order_group_prod_id;

  IF l_id IS NULL THEN
    INSERT INTO ozf_order_group_prod
    (
       order_group_prod_id
      ,creation_date
      ,created_by
      ,last_update_date
      ,last_updated_by
      ,last_update_login
      ,order_line_id
      ,offer_id
      ,qp_list_header_id
      ,group_no
      ,volume_track_type
      ,combine_schedule_yn
      ,pbh_line_id
      ,volume_type
      ,prod_attribute
      ,prod_attr_value
      ,apply_discount_flag
      ,include_volume_flag
      ,indirect_flag
    )
    VALUES
    (  ozf_order_group_prod_s.NEXTVAL
      ,SYSDATE
      ,FND_GLOBAL.user_id
      ,SYSDATE
      ,FND_GLOBAL.user_id
      ,FND_GLOBAL.conc_login_id
      ,p_order_line_id
      ,l_offer_id
      ,l_list_header_id
      ,l_group_no
      ,l_vol_track_type
      ,l_combine_schedule
      ,l_pbh_line_id
      ,l_volume_type
      ,l_prod_attribute
      ,l_prod_attr_value
      ,l_apply_discount
      ,l_include_volume
      ,l_indirect_flag
    );
  ELSE
    UPDATE ozf_order_group_prod
    SET    last_update_date    = SYSDATE,
           last_updated_by     = FND_GLOBAL.user_id,
           last_update_login   = FND_GLOBAL.conc_login_id,
           order_line_id       = p_order_line_id,
           offer_id            = l_offer_id,
           qp_list_header_id   = l_list_header_id,
           group_no            = l_group_no,
           volume_track_type   = l_vol_track_type,
           combine_schedule_yn = l_combine_schedule,
           pbh_line_id         = l_pbh_line_id,
           volume_type         = l_volume_type,
           prod_attribute      = l_prod_attribute,
           prod_attr_value     = l_prod_attr_value,
           apply_discount_flag = l_apply_discount,
           include_volume_flag = l_include_volume,
           indirect_flag       = l_indirect_flag
    WHERE  order_group_prod_id = l_id;
  END IF;

  IF l_indirect_flag = 'O' THEN -- from OM, call overload version 1
    OPEN  c_order_detail;
    FETCH c_order_detail INTO l_price, l_quantity, l_sold_to, l_ship_to, l_bill_to, l_trx_date;
    CLOSE c_order_detail;

    IF l_volume_type = 'PRICING_ATTRIBUTE10' THEN
      l_current_volume := l_quantity;
    ELSIF l_volume_type = 'PRICING_ATTRIBUTE12' THEN
      l_current_volume := l_price * l_quantity;
    END IF;

      get_volume
      (
         p_offer_id         => l_offer_id
        ,p_cust_acct_id     => l_sold_to
        ,p_bill_to          => l_bill_to
        ,p_ship_to          => l_ship_to
        ,p_group_no         => l_group_no
        ,p_vol_track_type   => l_vol_track_type
        ,p_pbh_line_id      => l_pbh_line_id
        ,p_combine_schedule => l_combine_schedule
        ,x_acc_volume       => l_acc_volume
      );
  ELSE -- from IDSM, call as of date volume
    IF l_indirect_flag = 'R' THEN
      OPEN  c_resale_detail;
      FETCH c_resale_detail INTO l_quantity, l_amount, l_distributor, l_sold_to, l_ship_to, l_bill_to, l_trx_date;
      CLOSE c_resale_detail;
    ELSIF l_indirect_flag = 'I' THEN
      OPEN  c_interface_detail;
      FETCH c_interface_detail INTO l_quantity, l_amount, l_distributor, l_sold_to, l_ship_to, l_bill_to, l_trx_date;
      CLOSE c_interface_detail;
    END IF;

    IF l_volume_type = 'PRICING_ATTRIBUTE10' THEN
      l_current_volume := l_quantity;
    ELSIF l_volume_type = 'PRICING_ATTRIBUTE12' THEN
      l_current_volume := l_amount;
    END IF;

      get_as_of_date_volume
      (
         p_offer_id            => l_offer_id
        ,p_distributor_acct_id => l_distributor
        ,p_cust_account_id     => l_sold_to
        ,p_bill_to             => l_bill_to
        ,p_ship_to             => l_ship_to
        ,p_group_no            => l_group_no
        ,p_combine_schedule    => l_combine_schedule
        ,p_volume_track_type   => l_vol_track_type
        ,p_pbh_line_id         => l_pbh_line_id
        ,p_transaction_date    => l_trx_date
        ,p_order_line_id       => p_order_line_id
        ,p_source_code         => 'IS'
        ,x_acc_volume          => l_acc_volume
      );
  END IF;

  IF l_acc_volume IS NULL THEN
    l_acc_volume := 0;
  END IF;

  OPEN  c_preset_volume(l_offer_id, l_group_no, l_pbh_line_id);
  FETCH c_preset_volume INTO l_preset_volume;
  CLOSE c_preset_volume;

  IF l_preset_volume IS NULL THEN
    l_preset_volume := 0;
  END IF;

  IF l_acc_volume > l_preset_volume THEN
    l_volume := l_acc_volume;
  ELSE
    l_volume := l_preset_volume;
  END IF;

/* commenting out so that both includevolume Y and N the l_volume is returned */
/*
  IF l_include_volume = 'N' THEN
    l_volume := l_volume - l_current_volume;
  END IF;
*/
  RETURN l_volume;

  EXCEPTION
     WHEN OTHERS THEN
     ROLLBACK TO get_numeric_attribute_value;
     IF Fnd_Msg_Pub.Check_Msg_Level ( Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR )
     THEN
        Fnd_Msg_Pub.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
END get_numeric_attribute_value;


FUNCTION get_beneficiary
(
   p_offer_id        IN NUMBER
  ,p_order_line_id   IN NUMBER
)
RETURN NUMBER
IS

/*
  CURSOR c_group_no IS
  SELECT group_no
  FROM   ozf_volume_detail
  WHERE  offer_id = p_offer_id
  AND    cust_account_id = p_cust_account_id
  AND    transaction_date =
         (
         SELECT MAX(transaction_date)
         FROM   ozf_volume_detail
         WHERE  cust_account_id = p_cust_account_id
         AND    offer_id = p_offer_id
         );

*/
--04-MAY-09 kdass bug 8421406
CURSOR c_group_no IS
  SELECT group_no
  FROM   ozf_order_group_prod
  WHERE  offer_id = p_offer_id
  AND    order_line_id = p_order_line_id;

/*
  CURSOR c_beneficiary(p_group_no NUMBER) IS
  SELECT a.beneficiary_party_id
  FROM   ozf_offr_market_options a, ozf_offr_market_options b
  WHERE  a.offer_market_option_id = b.offer_market_option_id
  AND    b.offer_id = p_offer_id
  AND    b.group_number = p_group_no;
*/
  CURSOR c_beneficiary(p_group_no NUMBER) IS
  SELECT beneficiary_party_id
  FROM   ozf_offr_market_options
  WHERE  offer_id = p_offer_id
  AND    group_number = p_group_no;

  l_group_no    NUMBER;
  l_beneficiary NUMBER;
BEGIN
  OPEN  c_group_no;
  FETCH c_group_no INTO l_group_no;
  CLOSE c_group_no;

  OPEN  c_beneficiary(l_group_no);
  FETCH c_beneficiary INTO l_beneficiary;
  CLOSE c_beneficiary;

  IF l_beneficiary IS NULL THEN
    l_beneficiary := 0;
  END IF;

  RETURN l_beneficiary;
END get_beneficiary;


PROCEDURE update_tracking_line
(
   p_init_msg_list     IN  VARCHAR2
  ,p_api_version       IN  NUMBER
  ,p_commit            IN  VARCHAR2
  ,x_return_status     OUT NOCOPY VARCHAR2
  ,x_msg_count         OUT NOCOPY NUMBER
  ,x_msg_data          OUT NOCOPY VARCHAR2
  ,p_list_header_id    IN  NUMBER
  ,p_interface_line_id IN  NUMBER
  ,p_resale_line_id    IN  NUMBER
)
IS
  l_api_name CONSTANT VARCHAR2(30) := 'update_tracking_line';
BEGIN
  SAVEPOINT update_tracking_line;

  x_return_status := Fnd_Api.g_ret_sts_success;

  UPDATE ozf_order_group_prod
  SET    order_line_id = p_resale_line_id,
         indirect_flag = 'R'
  WHERE  qp_list_header_id = p_list_header_id
  AND    order_line_id = p_interface_line_id
  AND    indirect_flag = 'I';

  EXCEPTION
     WHEN OTHERS THEN
     x_return_status := Fnd_Api.g_ret_sts_unexp_error;
     ROLLBACK TO update_tracking_line;
     IF Fnd_Msg_Pub.Check_Msg_Level ( Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR )
     THEN
        Fnd_Msg_Pub.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
     Fnd_Msg_Pub.Count_AND_Get
       ( p_count      =>      x_msg_count,
         p_data       =>      x_msg_data,
         p_encoded    =>      Fnd_Api.G_FALSE
        );
END update_tracking_line;


--------------------------
-- Used by Volume Tracking
-- Will return a value only if tracking by GROUP.
--------------------------
FUNCTION get_group_volume
(
p_offer_id        IN NUMBER
,p_group_number    IN NUMBER
,p_pbh_line_id     IN NUMBER
)
RETURN NUMBER
IS
l_group_volume NUMBER;
BEGIN

  select nvl(group_volume,0)  into l_group_volume from ozf_volume_summary
  where offer_id = p_offer_id
  and   group_no = p_group_number
  and   pbh_line_id = p_pbh_line_id;

  return  l_group_volume;
  END get_group_volume;

FUNCTION get_product_volume
(
p_offer_id           IN NUMBER
,p_pbh_line_id        IN NUMBER
,p_cust_account_id    IN NUMBER
,p_bill_to_id         IN NUMBER
,p_ship_to_id         IN NUMBER
)
RETURN NUMBER
IS
l_product_volume NUMBER;
BEGIN

  select sum(volume) customer_volume
    into l_product_volume
    from ozf_volume_detail
  where offer_id = p_offer_id
    and cust_account_id = p_cust_account_id
    and pbh_line_id = p_pbh_line_id
    and bill_to_site_use_id = nvl(p_bill_to_id, bill_to_site_use_id)
    and ship_to_site_use_id = nvl(p_ship_to_id, ship_to_site_use_id);

 return l_product_volume;
END;

FUNCTION get_actual_tier
(
p_offer_id        IN NUMBER
,p_inventory_item_id IN NUMBER
,p_pbh_line_id     IN NUMBER
,p_cust_account_id    IN NUMBER
,p_bill_to_id         IN NUMBER
,p_ship_to_id         IN NUMBER
)
RETURN VARCHAR2
IS
l_volume_range  VARCHAR2(30);
l_volume        NUMBER;
BEGIN

  l_volume := get_product_volume(p_offer_id,p_pbh_line_id,p_cust_account_id,p_bill_to_id,p_ship_to_id);

  select volume_from ||'-' || volume_to into l_volume_range
    from ozf_offer_discount_lines
   where offer_id = p_offer_id
     and parent_discount_line_id = p_pbh_line_id
     and l_volume between volume_from and volume_to;

  return l_volume_range;

END get_actual_tier;

FUNCTION get_actual_discount
(
p_offer_id        IN NUMBER
,p_inventory_item_id IN NUMBER
,p_pbh_line_id     IN NUMBER
,p_cust_account_id    IN NUMBER
,p_bill_to_id         IN NUMBER
,p_ship_to_id         IN NUMBER
)
RETURN VARCHAR2
IS
l_actual_discount  NUMBER;
l_volume        NUMBER;
BEGIN

  l_volume := get_product_volume(p_offer_id,p_pbh_line_id,p_cust_account_id,p_bill_to_id,p_ship_to_id);

  select discount into l_actual_discount
    from ozf_offer_discount_lines
   where offer_id = p_offer_id
     and parent_discount_line_id = p_pbh_line_id
     and l_volume between volume_from and volume_to;

  return l_actual_discount;

END get_actual_discount;


FUNCTION get_preset_tier
(
p_offer_id        IN NUMBER
,p_pbh_line_id     IN NUMBER
,p_group_no        IN NUMBER
)
RETURN VARCHAR2
IS
l_volume_range  VARCHAR2(30);
l_volume        NUMBER;
BEGIN

  select c.volume_from ||'-' || c.volume_to into l_volume_range
    from ozf_offr_market_options a,
         ozf_market_preset_tiers b,
         ozf_offer_discount_lines c
   where a.offer_id = p_offer_id
     and b.offer_market_option_id = a.offer_market_option_id
     and a.group_number = p_group_no
     and b.pbh_offer_discount_id = p_pbh_line_id
     and c.offer_discount_line_id = b.dis_offer_discount_id;

  return l_volume_range;

END get_preset_tier;

FUNCTION get_preset_discount
(
p_offer_id        IN NUMBER
,p_pbh_line_id     IN NUMBER
,p_group_no        IN NUMBER
)
RETURN VARCHAR2
IS
l_actual_discount  NUMBER;
l_volume        NUMBER;
BEGIN

  select c.discount into l_actual_discount
    from ozf_offr_market_options a,
         ozf_market_preset_tiers b,
         ozf_offer_discount_lines c
   where a.offer_id = p_offer_id
     and b.offer_market_option_id = a.offer_market_option_id
     and a.group_number = p_group_no
     and b.pbh_offer_discount_id = p_pbh_line_id
     and c.offer_discount_line_id = b.dis_offer_discount_id;

  return l_actual_discount;

END get_preset_discount;

FUNCTION get_payout_accrual
(
p_offer_id           IN NUMBER
,p_item_id            IN NUMBER
,p_cust_account_id    IN NUMBER
,p_bill_to_id         IN NUMBER
,p_ship_to_id         IN NUMBER
)
RETURN VARCHAR2
IS
l_payout_accrual  NUMBER;
l_qp_list_header_id NUMBER;
BEGIN

select qp_list_header_id into l_qp_list_header_id from ozf_offers where offer_id = p_offer_id;

SELECT SUM(uti.plan_curr_amount) into l_payout_accrual
 FROM ozf_funds_utilized_all_b uti
WHERE uti.utilization_type IN ('UTILIZED','ACCRUAL','ADJUSTMENT','CHARGEBACK','LEAD_ACCRUAL')
  AND plan_type = 'OFFR'
  AND plan_id = l_qp_list_header_id
  and product_id = p_item_id
  and cust_account_id = p_cust_account_id
  and bill_to_site_use_id = nvl(p_bill_to_id, bill_to_site_use_id)
  and ship_to_site_use_id = nvl(p_ship_to_id, ship_to_site_use_id)
  AND gl_posted_flag NOT in('N','F');

return l_payout_accrual;

END;

FUNCTION get_approx_actual_accrual
(
p_offer_id           IN NUMBER
,p_pbh_line_id        IN NUMBER
,p_group_no           IN NUMBER
,p_item_id            IN NUMBER
,p_cust_account_id    IN NUMBER
,p_bill_to_id         IN NUMBER
,p_ship_to_id         IN NUMBER
)
RETURN VARCHAR2
IS
l_actual_accrual NUMBER;
l_actual_discount  NUMBER;
l_preset_discount NUMBER;
l_payout_accrual NUMBER;

BEGIN

l_actual_discount := get_actual_discount(p_offer_id,p_item_id,p_pbh_line_id,p_cust_account_id, p_bill_to_id, p_ship_to_id);
l_preset_discount := get_preset_discount(p_offer_id,p_pbh_line_id,p_group_no);
l_payout_accrual  := get_payout_accrual(p_offer_id, p_item_id,p_cust_account_id, p_bill_to_id, p_ship_to_id);

if (l_preset_discount > l_actual_discount) then
  l_actual_accrual := (((l_payout_accrual * 100)/l_preset_discount)*l_actual_discount)/100;
else
  l_actual_accrual := l_payout_accrual;
end if;

return l_actual_accrual;

END;

--nirprasa, added function for bug 9027785
--This function will be called by OM directly whenever order copy functionality is used at original price.
--It will take all the values of the original order line and will copy the same for new order line in ozf_order_group_prod table.

FUNCTION copy_order_group_details
( p_from_order_line_id        IN NUMBER
 ,p_to_order_line_id    IN NUMBER
)
RETURN NUMBER IS
 l_api_name CONSTANT VARCHAR2(30) := 'copy_order_group_details';
 l_req_line_attrs_tbl     qp_runtime_source.accum_req_line_attrs_tbl;
 l_accum_rec              qp_runtime_source.accum_record_type;
 l_volume                   NUMBER;
 l_list_line_id              NUMBER;
 l_qp_list_header_id    NUMBER;


  CURSOR c_list_line_id(p_qp_list_header_id IN NUMBER) IS
  select list_line_id
  from oe_price_adjustments
  where list_line_type_code='PBH'
  and list_header_id=p_qp_list_header_id
  and line_id= p_to_order_line_id;

  CURSOR c_existing_lines IS
  SELECT group_no, volume_track_type, combine_schedule_yn, pbh_line_id, prod_attribute, prod_attr_value,qp_list_header_id
  FROM   ozf_order_group_prod
  WHERE  order_line_id = p_from_order_line_id
  AND    indirect_flag = 'O';
  --AND    qp_list_header_id = p_list_header_id;

  i NUMBER := 1;

  BEGIN
    SAVEPOINT copy_order_group_details;

     FOR adjustment_line_rec IN c_existing_lines LOOP
         OPEN  c_list_line_id(adjustment_line_rec.qp_list_header_id);
         FETCH c_list_line_id INTO l_list_line_id;
         CLOSE c_list_line_id;
         IF adjustment_line_rec.prod_attribute IS NOT NULL AND adjustment_line_rec.prod_attribute <> FND_API.G_MISS_CHAR THEN
             l_req_line_attrs_tbl(i).attribute_type := 'PRODUCT';
             l_req_line_attrs_tbl(i).attribute := adjustment_line_rec.prod_attribute;
             l_req_line_attrs_tbl(i).value := adjustment_line_rec.prod_attr_value;
         END IF;
         IF adjustment_line_rec.group_no <> -9999 THEN
             i := i+1;
             l_req_line_attrs_tbl(i).attribute_type := 'QUALIFIER';
             l_req_line_attrs_tbl(i).grouping_no := adjustment_line_rec.group_no;
         END IF;
         i := i+1;
         l_volume := OZF_VOLUME_CALCULATION_PUB.Get_numeric_attribute_value(l_list_line_id,
                               null,
                               null,
                               p_to_order_line_id,
                               null,
                               l_req_line_attrs_tbl,
                               l_accum_rec
                               );
     END LOOP;

    RETURN l_volume;
  EXCEPTION
     WHEN OTHERS THEN
     ROLLBACK TO copy_order_group_details;
     IF Fnd_Msg_Pub.Check_Msg_Level ( Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR )
     THEN
        Fnd_Msg_Pub.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
END copy_order_group_details;

END OZF_VOLUME_CALCULATION_PUB;

/
