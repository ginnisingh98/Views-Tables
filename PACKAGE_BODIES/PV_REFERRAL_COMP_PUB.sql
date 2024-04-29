--------------------------------------------------------
--  DDL for Package Body PV_REFERRAL_COMP_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PV_REFERRAL_COMP_PUB" as
/* $Header: pvxvrfcb.pls 120.0 2005/05/27 15:53:55 appldev noship $*/

/*************************************************************************************/
/*                                                                                   */
/*                                                                                   */
/*                                                                                   */
/*                    Global Variable Declaration                                    */
/*                                                                                   */
/*                                                                                   */
/*                                                                                   */
/*************************************************************************************/
g_log_to_file        VARCHAR2(5)  := 'N';
g_pkg_name           VARCHAR2(30) := 'PV_REFERRAL_COMP_PUB';
g_api_name           VARCHAR2(30);
g_RETCODE            VARCHAR2(10) := '0';
g_module_name        VARCHAR2(48);

PV_DEBUG_HIGH_ON boolean :=
   FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
PV_DEBUG_LOW_ON boolean :=
   FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
PV_DEBUG_MEDIUM_ON boolean :=
   FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);
PV_DEBUG_ERROR_ON boolean :=
   FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_ERROR);


/*************************************************************************************/
/*                                                                                   */
/*                                                                                   */
/*                                                                                   */
/*                    private procedure declaration                                  */
/*                                                                                   */
/*                                                                                   */
/*                                                                                   */
/*************************************************************************************/
PROCEDURE Debug(
   p_msg_string      IN VARCHAR2,
   p_msg_type        IN VARCHAR2 := 'PV_DEBUG_MESSAGE',
   p_token_type      IN VARCHAR2 := 'TEXT',
   p_statement_level IN NUMBER   := FND_LOG.LEVEL_PROCEDURE
);

PROCEDURE Set_Message(
    p_msg_name      IN      VARCHAR2,
    p_token1        IN      VARCHAR2 := NULL,
    p_token1_value  IN      VARCHAR2 := NULL,
    p_token2        IN      VARCHAR2 := NULL,
    p_token2_value  IN      VARCHAR2 := NULL,
    p_token3        IN      VARCHAR2 := NULL,
    p_token3_value  IN      VARCHAR2 := NULL,
    p_statement_level IN NUMBER   := FND_LOG.LEVEL_PROCEDURE
);

PROCEDURE write_conc_log;


-- -----------------------------------------------------------------------------
-- This may not be needed anymore.
-- -----------------------------------------------------------------------------
FUNCTION Get_Partner_Account (
   p_partner_id    IN NUMBER
)
RETURN NUMBER
;



--=============================================================================+
--| Public Procedure                                                           |
--|    Get_Beneficiary                                                         |
--|                                                                            |
--| Parameters                                                                 |
--|    IN                                                                      |
--|    OUT                                                                     |
--|                                                                            |
--|                                                                            |
--| NOTES                                                                      |
--|                                                                            |
--| HISTORY                                                                    |
--|                                                                            |
--==============================================================================
PROCEDURE Get_Beneficiary (
   p_api_version           IN  NUMBER,
   p_init_msg_list         IN  VARCHAR2  := FND_API.g_false,
   p_commit                IN  VARCHAR2  := FND_API.g_false,
   p_validation_level      IN  NUMBER    := FND_API.g_valid_level_full,
   p_order_header_id       IN  NUMBER,
   p_order_line_id         IN  NUMBER,
   p_offer_id              IN  NUMBER,
   x_beneficiary_id        OUT NOCOPY NUMBER,
   x_referral_id           OUT NOCOPY NUMBER,
   x_return_status         OUT NOCOPY VARCHAR2,
   x_msg_count             OUT NOCOPY NUMBER,
   x_msg_data              OUT NOCOPY VARCHAR2
)
IS
   l_api_version          NUMBER       := 1;
   l_returned_order_flag  BOOLEAN      := FALSE;


   TYPE t_ref_cursor IS REF CURSOR;
   l_ref_cursor      t_ref_cursor;


   CURSOR c_returned_order IS
      SELECT line_id
      FROM   oe_order_lines_all
      WHERE  flow_status_code = 'RETURNED' AND
             header_id        = p_order_header_id AND
             line_id          = p_order_line_id;

/*
   CURSOR c_matching_referral IS
      SELECT referral_id, partner_id,
             COUNT(*) OVER (PARTITION BY counter) outer_counter
      FROM  (SELECT referral_id, partner_id, 'x' counter
             FROM   pv_referrals_b
             WHERE  order_id = p_order_header_id);
*/

   -- -------------------------------------------------------------------
   -- Given an order, find out if there are any referrals linked with
   -- this order. The SQL returns the oldest referrals first.
   -- Note that we don't need to check the referral status for this
   -- because a referral that is associated with an order cannot be
   -- expired, manually closed, etc.
   -- -------------------------------------------------------------------
   CURSOR c_matching_referral IS
      SELECT referral_id, partner_id, referral_status, claim_id,
             partner_cust_account_id
      FROM   pv_referrals_b
      WHERE  order_id = p_order_header_id AND
             claim_id IS NULL
      ORDER  by creation_date ASC;

   -- -------------------------------------------------------------------
   -- Given an order and a referral, find out if there are any matching
   -- products.
   --
   -- Here a referral can only be considered when its status is either
   -- 'APPROVED', 'MANUAL_EXTEND', and 'CLOSED_OPPTY_WON'.
   -- -------------------------------------------------------------------
   CURSOR c_matching_line (pc_referral_id NUMBER) IS
      SELECT LINE.inventory_item_id
      FROM   pv_referred_products    PROD,
             pv_referrals_b          REF,
             oe_order_lines_all      LINE,
             mtl_item_categories     MIC,
             eni_prod_denorm_hrchy_v DENORM,
             pv_ge_benefits_vl  BENFT
      WHERE  REF.referral_id              = pc_referral_id AND
             REF.referral_status          IN ('APPROVED', 'MANUAL_EXTEND', 'CLOSED_OPPTY_WON') AND
             PROD.referral_id             = REF.referral_id AND
             LINE.header_id               = p_order_header_id AND
             LINE.line_id                 = p_order_line_id AND
             LINE.inventory_item_id       = MIC.inventory_item_id AND
             MIC.category_set_id          = DENORM.category_set_id AND
             MIC.category_id              = DENORM.child_id AND
             PROD.product_category_set_id = DENORM.category_set_id AND
             PROD.product_category_id     = DENORM.parent_id AND
             REF.benefit_id               = BENFT.benefit_id AND
             BENFT.additional_info_1      = p_offer_id;


   -- --------------------------------------------------------------------------
   -- We only want to consider active referrals. An active referral is defined
   -- as one whose referral status is either 'APPROVED', 'MANUAL_EXTEND' or
   -- 'CLOSED_OPPTY_WON'.
   -- There is a concurrent program that will update referrals to appropriate
   -- status (e.g. 'EXPIRED', 'CLOSED_DEAD_LEAD', 'CLOSED_LOST_OPPTY', etc.)
   -- --------------------------------------------------------------------------
   CURSOR c_matching_referral_2 IS
      SELECT *
      FROM  (
         SELECT REF.referral_id, REF.partner_id, REF.partner_cust_account_id
         FROM   pv_referrals_b          REF,
                pv_referred_products    PROD,
                pv_ge_benefits_b        BENFT,
                oe_order_headers_all    HEADER,
                oe_order_lines_all      LINE,
                hz_cust_accounts        ACCOUNT,
                mtl_item_categories     MIC,
                eni_prod_denorm_hrchy_v DENORM
         WHERE  BENFT.additional_info_1      = p_offer_id AND
                BENFT.benefit_id             = REF.benefit_id AND
                REF.referral_id              = PROD.referral_id AND
                REF.order_id                 IS NULL AND
                REF.claim_id                 IS NULL AND
                REF.referral_status          IN ('APPROVED', 'MANUAL_EXTEND', 'CLOSED_OPPTY_WON') AND
                HEADER.header_id             = p_order_header_id AND
                LINE.line_id                 = p_order_line_id AND
                HEADER.header_id             = LINE.header_id AND
                LINE.flow_status_code        <> 'CANCELLED' AND
                LINE.inventory_item_id       = MIC.inventory_item_id AND
                MIC.category_set_id          = DENORM.category_set_id AND
                MIC.category_id              = DENORM.child_id AND
                PROD.product_category_set_id = DENORM.category_set_id AND
                PROD.product_category_id     = DENORM.parent_id AND
                HEADER.sold_to_org_id        = ACCOUNT.cust_account_id AND
                ACCOUNT.party_id             = REF.customer_party_id
         ORDER  BY REF.creation_date ASC
      )
      WHERE ROWNUM = 1;

   -- --------------------------------------------------------------------------
   -- Template Cursor
   -- --------------------------------------------------------------------------
   CURSOR c_template IS
      SELECT referral_id, partner_cust_account_id, claim_id, 1 outer_counter
      FROM   pv_referrals_b
      WHERE  referral_id = 1;

   lc_template c_template%ROWTYPE;

   -- --------------------------------------------------------------------------
   -- Returned Order.
   -- Use dynamic SQL because Oracle 8i PL/SQL does not support using OVER...
   -- PARTITION in a static SQL.
   -- --------------------------------------------------------------------------
   l_returned_order_match_sql VARCHAR2(32000) :=
     'SELECT referral_id,
             partner_cust_account_id,
             claim_id,
             COUNT(*) OVER (PARTITION BY counter) outer_counter
      FROM  (
         SELECT REF.referral_id,
                REF.partner_cust_account_id,
                REF.claim_id,
                1 counter
         FROM   pv_referrals_b          REF,
                pv_referred_products    PROD,
                pv_ge_benefits_b        BENFT,
                oe_order_headers_all    HEADER,
                oe_order_lines_all      LINE,
                hz_cust_accounts        ACCOUNT,
                mtl_item_categories     MIC,
                eni_prod_denorm_hrchy_v DENORM
         WHERE  BENFT.additional_info_1      = :p_offer_id AND
                BENFT.benefit_id             = REF.benefit_id AND
                REF.referral_id              = PROD.referral_id AND
                REF.order_id                 IS NOT NULL AND
                HEADER.header_id             = :p_order_header_id AND
                LINE.line_id                 = :p_order_line_id AND
                HEADER.header_id             = LINE.header_id AND
                LINE.inventory_item_id       = MIC.inventory_item_id AND
                MIC.category_set_id          = DENORM.category_set_id AND
                MIC.category_id              = DENORM.child_id AND
                PROD.product_category_set_id = DENORM.category_set_id AND
                PROD.product_category_id     = DENORM.parent_id AND
                HEADER.sold_to_org_id        = ACCOUNT.cust_account_id AND
                ACCOUNT.party_id             = REF.customer_party_id AND
                REF.creation_date            < LINE.creation_date
             )';

BEGIN
   g_api_name := 'Get_Beneficiary';

   Debug('Calling ' || g_pkg_name || '.' || g_api_name);
   Debug('order_header_id = ' || p_order_header_id);
   Debug('order_line_id = ' || p_order_line_id);
   Debug('offer_id = ' || p_offer_id);

   -------------------- initialize -------------------------
   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   IF NOT FND_API.compatible_api_call(
         l_api_version,
         p_api_version,
         g_api_name,
         g_pkg_name
   ) THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;


   ---------------------- Source code -----------------------

   -- --------------------------------------------------------------------
   -- Check if this is a returned order.
   -- --------------------------------------------------------------------
   FOR x IN c_returned_order LOOP
      l_returned_order_flag := TRUE;
   END LOOP;


   -- ====================================================================
   -- ====================================================================
   --                     Process "normal" orders.
   -- ====================================================================
   -- ====================================================================
   IF (NOT l_returned_order_flag) THEN
      -- --------------------------------------------------------------------
      -- If there is one or more referrals associated with this order,
      -- go through all the matching referrals, starting with the oldest one
      -- (--> ORDER  by creation_date ASC),
      -- to find out if the product (item) matches between the referral and
      -- and the order line. If a matche is found, get the beneficiary_id
      -- and referral_id and all's done.
      -- --------------------------------------------------------------------
      FOR x IN c_matching_referral LOOP
         FOR y IN c_matching_line(x.referral_id) LOOP
            x_beneficiary_id := x.partner_cust_account_id;
            x_referral_id    := x.referral_id;
            Debug('Beneficiary Found: ' || x_beneficiary_id);
            Write_Conc_Log;
            RETURN;
         END LOOP;
      END LOOP;


      -- --------------------------------------------------------------------
      -- If it comes to this part of code, it means one of the following
      -- conditions is true:
      -- (1) There are currently no referrals associated with this order.
      -- (2) There is at least one referral associated with this order, but
      --     the logic above cannot find a matching product within those
      --     referrals.
      --
      -- In any case, we will search for all the active and unassigned
      -- referrals for a product/offer/customer match.
      -- --------------------------------------------------------------------
      FOR x IN c_matching_referral_2 LOOP
         x_beneficiary_id := x.partner_cust_account_id;
         x_referral_id    := x.referral_id;

         -- -----------------------------------------------------------------
         -- Associate the order with this referral.
         -- -----------------------------------------------------------------
         UPDATE pv_referrals_b
         SET    order_id = p_order_header_id
         WHERE  referral_id = x.referral_id AND
                order_id IS NULL;

         Debug('Beneficiary Found: ' || x_beneficiary_id);
         Write_Conc_Log;
      END LOOP;



   -- ====================================================================
   -- ====================================================================
   --                     Process returned orders.
   -- ====================================================================
   -- ====================================================================

   -- --------------------------------------------------------------------
   -- Find a matching referral for the returned order.
   --
   -- A returned order has to be unambiguously matched to a referral
   -- for the negative accrual to be made on it (In the FOR LOOP below,
   -- x.count has to be 1).
   --
   -- Note that a matching referral is a referral that already has an
   -- order tied to it, but does not yet have a claim created for it,
   -- and has a referral creation date that is earlier than the order
   -- creation date. However, it is irrespective of the referral expiration
   -- date since an returned order can happen at any time.
   -- --------------------------------------------------------------------
   ELSE
      OPEN l_ref_cursor FOR l_returned_order_match_sql
      USING p_offer_id, p_order_header_id, p_order_line_id;

      LOOP
         FETCH l_ref_cursor INTO lc_template;
         EXIT WHEN (l_ref_cursor%NOTFOUND OR lc_template.outer_counter <> 1);

         IF (lc_template.claim_id IS NULL AND lc_template.outer_counter = 1) THEN
            x_beneficiary_id := lc_template.partner_cust_account_id;
            x_referral_id    := lc_template.referral_id;

            Debug('Beneficiary Found: ' || x_beneficiary_id);
            Write_Conc_Log;
         END IF;
      END LOOP;

      CLOSE l_ref_cursor;
   END IF;


   Write_Conc_Log;


   -------------------- Exception --------------------------
   EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         FND_MSG_PUB.Count_And_Get( p_encoded   =>  FND_API.G_FALSE,
                                    p_count     =>  x_msg_count,
                                    p_data      =>  x_msg_data);

         Write_Conc_Log;

      WHEN FND_API.g_exc_unexpected_error THEN
         x_return_status := FND_API.g_ret_sts_unexp_error;
         FND_MSG_PUB.count_and_get(
               p_encoded => FND_API.g_false,
               p_count   => x_msg_count,
               p_data    => x_msg_data
         );

         Write_Conc_Log;

      WHEN OTHERS THEN
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
           FND_MSG_PUB.add_exc_msg(g_pkg_name, g_api_name);
        END IF;

        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.count_and_get(
              p_encoded => FND_API.g_false,
              p_count   => x_msg_count,
              p_data    => x_msg_data
        );

         Write_Conc_Log;
END Get_Beneficiary;
-- ========================End of Get_Beneficiary==============================



--=============================================================================+
--| Public Procedure                                                           |
--|    Check_Order_Completion                                                  |
--|                                                                            |
--| Parameters                                                                 |
--|    IN                                                                      |
--|    OUT                                                                     |
--|                                                                            |
--|                                                                            |
--| NOTES                                                                      |
--|                                                                            |
--| HISTORY                                                                    |
--|                                                                            |
--==============================================================================
PROCEDURE Check_Order_Completion (
   ERRBUF              OUT  NOCOPY VARCHAR2,
   RETCODE             OUT  NOCOPY VARCHAR2,
   p_log_to_file       IN   VARCHAR2 := 'Y'
)
IS
   i                        NUMBER;
   l_incomplete_order       BOOLEAN;
   l_return_status          VARCHAR2(100);
   l_msg_count              NUMBER;
   l_msg_data               VARCHAR2(500);
   l_claim_rec              ozf_partner_claim_grp.claim_rec_type;
   l_empty_claim_rec        ozf_partner_claim_grp.claim_rec_type;
   l_promotion_activity_rec ozf_partner_claim_grp.promotion_activity_rec_type;
   l_empty_promo_act_rec    ozf_partner_claim_grp.promotion_activity_rec_type;
   l_claim_id               NUMBER;
   l_claim_number           VARCHAR2(30);
   l_claim_amount           NUMBER;
   l_total_start            NUMBER;
   l_elapsed_time           NUMBER;
   l_referral_counter       NUMBER := 1;
   l_operating_unit         VARCHAR2(240);

   -- -------------------------------------------------------------------------
   -- The SQL finds all the referrals in the system that has an order
   -- associated with it but does not have a claim created for it yet.
   --
   -- QUESTION: can a referral be "manually closed" when it has an order
   -- associated with it?  Why not?  --> David.
   -- -------------------------------------------------------------------------
   CURSOR c_incomplete_orders IS
      SELECT REF.referral_name,
             REF.referral_id,
             REF.referral_code,
             REF.currency_code,
             REF.partner_cust_account_id,
             REF.org_id,
	     REF.partner_id,
             BENFT.additional_info_1 offer_id,
	     BENFT.benefit_id
      FROM   pv_referrals_vl  REF,
             pv_ge_benefits_b BENFT
      WHERE  BENFT.benefit_id = REF.benefit_id AND
             REF.order_id     > 0 AND
             REF.claim_id     IS NULL;

   -- -------------------------------------------------------------------------
   -- The SQL/cursor below checks for order completion of a referral.
   --
   -- Note that under referral, C in C1, C2, and C3 stands for category_id
   -- for Single Product Hierarhcy. A category_id can contain one or more
   -- inventory items as is in the case of C2 --> P2, P3.
   --
   -- The following is an example of an order that is not complete since for
   -- order line #3 (L3), there is no accrual made for that line.
   -- In case (2), the order is complete since there is at least one accrual
   -- made for every matching line between the referral and the order.
   --
   -- (1)
   -- Referral          Order             Accrual
   -- --------          -----             --------
   --       C1  ----->  L1 P1  -------->  A1 A2 A3
   --       C2  ----->  L2 P2  -------->        A4
   --       C2  ----->  L3 P2  -------->      null
   --       C2  ----->  L4 P3  -------->        A5
   --       C3          L5 P4
   --       C5          L6 P6
   --
   -- (2)
   -- Referral          Order             Accrual
   -- --------          -----             --------
   --       C1  ----->  L1 P1  -------->  A1 A2 A3
   --       C2  ----->  L2 P2  -------->        A4
   --       C2  ----->  L3 P2  -------->     A6 A7
   --       C2  ----->  L4 P3  -------->        A5
   --       C3          L5 P4
   --       C5          L6 P6
   --
   -- Note that in the SQL below, x stands for the join between Referral
   -- and Order, which UTL stands for the "Accrual" in the diagram above.
   --
   -- -------------------------------------------------------------------------
   CURSOR c_ref_order_line_match (pc_referral_id NUMBER) IS
     SELECT  DISTINCT x.order_id, x.line_id, UTL.utilization_id,
             UTL.org_id, UTL.exchange_rate_type, UTL.exchange_rate_date,
	     UTL.exchange_rate, UTL.currency_code
     FROM
     (SELECT ACCRUAL.plan_type,
             ACCRUAL.plan_id,
             ACCRUAL.utilization_id,
             ACCRUAL.utilization_type,
             ACCRUAL.reference_type,
             ACCRUAL.reference_id,
             ACCRUAL.org_id,
             ACCRUAL.cust_account_id,
             ACCRUAL.object_id order_header_id,
             ACCRUAL.order_line_id,
	     ACCRUAL.currency_code,
	     ACCRUAL.exchange_rate_type,
	     ACCRUAL.exchange_rate_date,
	     ACCRUAL.exchange_rate
      FROM   ozf_funds_utilized_all_b ACCRUAL
      WHERE  ACCRUAL.object_type = 'ORDER'
     ) UTL,
     (SELECT PROD.product_category_id,
             REF.order_id,
             LINE.line_id,
             MIC.inventory_item_id,
             LINE.flow_status_code,
             OFFER.qp_list_header_id,
             REF.referral_id,
             REF.partner_cust_account_id
      FROM   pv_referrals_b           REF,
             pv_referred_products     PROD,
             pv_ge_benefits_b         BENFT,
             oe_order_headers_all     HEADER,
             oe_order_lines_all       LINE,
             mtl_item_categories      MIC,
             eni_prod_denorm_hrchy_v  DENORM,
             ozf_offers               OFFER
      WHERE  REF.referral_id              = pc_referral_id AND
             BENFT.benefit_id             = REF.benefit_id AND
             REF.referral_status          IN ('APPROVED', 'MANUAL_EXTEND', 'CLOSED_OPPTY_WON') AND
             REF.referral_id              = PROD.referral_id AND
             REF.order_id                 = HEADER.header_id AND
             HEADER.header_id             = LINE.header_id AND
             LINE.flow_status_code        <> 'CANCELLED' AND
             LINE.inventory_item_id       = MIC.inventory_item_id AND
             MIC.category_set_id          = DENORM.category_set_id AND
             MIC.category_id              = DENORM.child_id AND
             PROD.product_category_set_id = DENORM.category_set_id AND
             PROD.product_category_id     = DENORM.parent_id AND
             BENFT.additional_info_1      = OFFER.offer_id
      ) x
      WHERE  UTL.plan_type           (+)  = 'OFFR' AND
             UTL.plan_id             (+)  = x.qp_list_header_id AND  -- not offer_id!
             UTL.utilization_type    (+)  = 'LEAD_ACCRUAL' AND
             UTL.reference_type      (+)  = 'LEAD_REFERRAL' AND
             UTL.reference_id        (+)  = x.referral_id AND
             UTL.cust_account_id     (+)  = x.partner_cust_account_id AND
             UTL.order_header_id     (+)  = x.order_id AND
             UTL.order_line_id       (+)  = x.line_id;

BEGIN
   g_api_name := 'Check_Order_Completion';

   -- -----------------------------------------------------------------------
   -- Set variables.
   -- -----------------------------------------------------------------------
   l_total_start := dbms_utility.get_time;

   g_module_name := 'Referral Compensation: Order Completion CC';

   dbms_application_info.set_module(
      module_name => g_module_name,
      action_name => 'STARTUP'
   );

   IF (p_log_to_file <> 'Y') THEN
      g_log_to_file := 'N';
   ELSE
      g_log_to_file := 'Y';
   END IF;


   -- -----------------------------------------------------------------------
   -- Start time message...
   -- -----------------------------------------------------------------------
   Debug(p_msg_string => TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI:SS'),
         p_msg_type   => 'PV_ORDER_COMPLETE_START_TIME',
         p_token_type => 'P_DATE_TIME',
         p_statement_level => FND_LOG.LEVEL_EVENT
   );

   -- --------------------------------------------------------------------------
   -- Get all (active) referrals that has an order associated with it, but no
   -- claims created for it.
   -- --------------------------------------------------------------------------
   FOR x IN c_incomplete_orders LOOP
      l_incomplete_order := FALSE;
      i                  := 0;

      dbms_application_info.set_module(
         module_name => g_module_name,
         action_name => 'Checking Referral #' || l_referral_counter
      );

      Debug('Referral #' || l_referral_counter);
      Debug('Checking "' || x.referral_name || '" (referral_id = ' ||
            x.referral_id || ') for order completion...');

      l_referral_counter := l_referral_counter + 1;

      -- -----------------------------------------------------------------
      -- Set up claim parameters
      -- -----------------------------------------------------------------
      l_claim_id                       := null;
      l_claim_number                   := null;
      l_claim_amount                   := null;
      l_claim_rec                      := l_empty_claim_rec;
      l_promotion_activity_rec         := l_empty_promo_act_rec;


      -- -----------------------------------------------------------------------
      -- For each of the referrals retrieved above, check if the order is
      -- complete.
      -- -----------------------------------------------------------------------
      FOR y IN c_ref_order_line_match(x.referral_id) LOOP
         i := i + 1;

         IF (y.utilization_id IS NULL) THEN
            l_incomplete_order := TRUE;
            EXIT;
         END IF;

         -- ---------------------------------------------------------------------
         -- Set the ord_id and currency info for the claim.
	 -- These values should be derived from the accrual, whose values are same
	 -- as that of the order. They should not be derived from partner's
	 -- responsibility.
	 -- ---------------------------------------------------------------------
	 l_claim_rec.org_id                 := y.org_id;
         l_claim_rec.currency_code          := y.currency_code;
	 l_claim_rec.exchange_rate_type     := y.exchange_rate_type;
	 l_claim_rec.exchange_rate_date     := y.exchange_rate_date;
	 l_claim_rec.exchange_rate          := y.exchange_rate;
      END LOOP;


      IF (l_incomplete_order OR i = 0) THEN
         Set_Message(
            p_msg_name      => 'PV_REFERRAL_ORDER_NOT_COMPLETE'
         );

	 Debug('-----------------------------------------------------------------------------');
      END IF;

      -- -----------------------------------------------------------------------
      -- If the order is "complete", create a claim for this referral.
      -- If creating claim fails for this referral, still need to go on to
      -- the next referral. That's why there is a BEGIN-END block here.
      -- -----------------------------------------------------------------------
      IF ((NOT l_incomplete_order) AND i > 0) THEN
         Set_Message(
            p_msg_name      => 'PV_REFERRAL_ORDER_COMPLETE'
         );

         BEGIN
            -- -----------------------------------------------------------------
            -- Set up claim parameters
            -- -----------------------------------------------------------------
            l_claim_rec.source_object_id       := x.referral_id;
            l_claim_rec.source_object_class    := 'REFERRAL';
            l_claim_rec.source_object_number   := SUBSTR(x.referral_code, 1, 30);
            l_claim_rec.cust_account_id        := x.partner_cust_account_id;
            l_claim_rec.pay_to_cust_account_id := x.partner_cust_account_id;

            FOR z IN (SELECT qp_list_header_id FROM ozf_offers WHERE offer_id = x.offer_id) LOOP
               l_promotion_activity_rec.offer_id    := z.qp_list_header_id;
            END LOOP;

            l_promotion_activity_rec.reference_type := 'LEAD_REFERRAL';
            l_promotion_activity_rec.reference_id   := l_claim_rec.source_object_id;


            -- -----------------------------------------------------------------
            -- Create claim
            -- -----------------------------------------------------------------
            ozf_partner_claim_grp.Create_Claim(
               p_api_version_number     => 1.0,
               p_claim_rec              => l_claim_rec,
               p_promotion_activity_rec => l_promotion_activity_rec,
               x_claim_id               => l_claim_id,
               x_claim_number           => l_claim_number,
               x_claim_amount           => l_claim_amount,
               x_return_status          => l_return_status,
               x_msg_count              => l_msg_count,
               x_msg_data               => l_msg_data
            );

            IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
               RAISE FND_API.G_EXC_ERROR;

            ELSIF (l_return_status = FND_API.g_ret_sts_unexp_error) THEN
               RAISE FND_API.g_exc_unexpected_error;
            END IF;


            -- -----------------------------------------------------------------
            -- Link the claim to the referral and update referral status.
            -- -----------------------------------------------------------------
            UPDATE pv_referrals_b
            SET    claim_id                = l_claim_id,
                   claim_number            = l_claim_number,
                   actual_compensation_amt = l_claim_amount,
                   actual_currency_code    = l_claim_rec.currency_code,
                   referral_status         = 'COMP_INITIATED'
            WHERE  referral_id = x.referral_id;


            -- -------------------------------------------------
            -- Raise business event
            -- oracle.apps.pv.benefit.referral.statusChange
            -- -------------------------------------------------
            pv_benft_status_change.status_change_raise(
               p_api_version_number  => 1.0,
               p_init_msg_list       => FND_API.G_FALSE,
               p_commit              => FND_API.G_FALSE,
               p_event_name          => 'oracle.apps.pv.benefit.referral.statusChange',
               p_benefit_id          => x.benefit_id,
               p_entity_id           => x.referral_id,
               p_status_code         => 'COMP_INITIATED',
               p_partner_id          => x.partner_id,
               p_msg_callback_api    => 'pv_benft_status_change.REFERRAL_SET_MSG_ATTRS',
               p_user_callback_api   => 'pv_benft_status_change.REFERRAL_RETURN_USERLIST',
               x_return_status       => l_return_status,
               x_msg_count           => l_msg_count,
               x_msg_data            => l_msg_data);

            if (l_return_status <>  FND_API.G_RET_STS_SUCCESS) then
                raise FND_API.G_EXC_ERROR;
            end if;

            -- -------------------------------------------------
            -- Log the event.
            -- -------------------------------------------------
            pv_benft_status_change.STATUS_CHANGE_LOGGING(
               p_api_version_number  => 1.0,
               p_init_msg_list       => FND_API.G_FALSE,
               p_commit              => FND_API.G_FALSE,
               p_benefit_id          => x.benefit_id,
               P_STATUS              => 'COMP_INITIATED',
               p_entity_id           => x.referral_id,
               p_partner_id          => x.partner_id,
               x_return_status       => l_return_status,
               x_msg_count           => l_msg_count,
               x_msg_data            => l_msg_data
           );

            if (l_return_status <>  FND_API.G_RET_STS_SUCCESS) then
                raise FND_API.G_EXC_ERROR;
            end if;

            -- -------------------------------------------------
            -- Commit the changes.
            -- -------------------------------------------------
            COMMIT;


            Set_Message(
                p_msg_name      => 'PV_REFERRAL_CLAIM_CREATED',
                p_token1        => 'CLAIM_ID',
                p_token1_value  => l_claim_id,
                p_token2        => 'CLAIM_NUMBER',
                p_token2_value  => l_claim_number,
                p_token3        => 'CLAIM_AMOUNT',
                p_token3_value  => l_claim_amount
            );

            -- -----------------------------------------------------------------
            -- Display the org_id and the operating unit that the claim is
	    -- created in.
            -- -----------------------------------------------------------------
            FOR z IN (SELECT name
                      FROM   hr_organization_units
                      WHERE  organization_id = l_claim_rec.org_id)
	    LOOP
               l_operating_unit := z.name;
	    END LOOP;

	    Debug('org_id       = ' || l_claim_rec.org_id);
	    Debug('Organization = ' || l_operating_unit);
	    Debug('-----------------------------------------------------------------------------');


         --------------------------- Exception ---------------------------------
         EXCEPTION
            WHEN FND_API.G_EXC_ERROR THEN
               Debug('Creating claim exception ........................................');
               l_return_status := FND_API.G_RET_STS_ERROR;
               FND_MSG_PUB.Count_And_Get( p_encoded   =>  FND_API.G_FALSE,
                                          p_count     =>  l_msg_count,
                                          p_data      =>  l_msg_data);

               Write_Conc_Log;

               g_RETCODE := '1';
   	       Debug('-----------------------------------------------------------------------------');

            WHEN FND_API.g_exc_unexpected_error THEN
               Debug('Creating claim exception ........................................');
               l_return_status := FND_API.g_ret_sts_unexp_error;
               FND_MSG_PUB.count_and_get(
                     p_encoded => FND_API.g_false,
                     p_count   => l_msg_count,
                     p_data    => l_msg_data
               );

               Write_Conc_Log;

               g_RETCODE := '1';
   	       Debug('-----------------------------------------------------------------------------');

            WHEN OTHERS THEN
               Debug('Creating claim exception ........................................');
              IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
                 FND_MSG_PUB.add_exc_msg(g_pkg_name, g_api_name);
              END IF;

              l_return_status := FND_API.G_RET_STS_ERROR;
              FND_MSG_PUB.count_and_get(
                    p_encoded => FND_API.g_false,
                    p_count   => l_msg_count,
                    p_data    => l_msg_data
              );

               Write_Conc_Log;

               g_RETCODE := '1';
   	       Debug('-----------------------------------------------------------------------------');

         END;
      END IF;
   END LOOP;


   -- -------------------------------------------------------------------------
   -- Display End Time Message.
   -- -------------------------------------------------------------------------
   Debug(p_msg_string => TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI:SS'),
         p_msg_type   => 'PV_ORDER_COMPLETION_END_TIME',
         p_token_type => 'P_DATE_TIME',
         p_statement_level =>FND_LOG.LEVEL_EVENT
   );


   l_elapsed_time := DBMS_UTILITY.get_time - l_total_start;
   Debug('=====================================================================');
   Debug('Total Elapsed Time: ' || l_elapsed_time || ' hsec' || ' = ' ||
         ROUND((l_elapsed_time/6000), 2) || ' minutes');
   Debug('=====================================================================');


END Check_Order_Completion;
-- ======================End of Check_Order_Completion===========================




--=============================================================================+
--| Public Procedure                                                           |
--|    Update_Referral_Status                                                  |
--|                                                                            |
--| Parameters                                                                 |
--|    IN                                                                      |
--|    OUT                                                                     |
--|                                                                            |
--|                                                                            |
--| NOTES                                                                      |
--|                                                                            |
--| HISTORY                                                                    |
--|                                                                            |
--==============================================================================
PROCEDURE Update_Referral_Status (
   p_api_version           IN  NUMBER,
   p_init_msg_list         IN  VARCHAR2  := FND_API.g_false,
   p_commit                IN  VARCHAR2  := FND_API.g_false,
   p_validation_level      IN  NUMBER    := FND_API.g_valid_level_full,
   p_offer_id              IN  NUMBER,
   p_pass_validation_flag  IN  VARCHAR2,
   x_return_status         OUT NOCOPY VARCHAR2,
   x_msg_count             OUT NOCOPY NUMBER,
   x_msg_data              OUT NOCOPY VARCHAR2
)
IS
   l_benefit_status_code VARCHAR2(50);
   l_api_version         NUMBER := 1;

BEGIN
   g_api_name := 'Update_Referral_Status';

   -------------------- initialize -------------------------
   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   IF NOT FND_API.compatible_api_call(
         l_api_version,
         p_api_version,
         g_api_name,
         g_pkg_name
   ) THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;


   ---------------------- Source code -----------------------
   IF (UPPER(p_pass_validation_flag) NOT IN ('Y', 'N')) THEN
      Debug('p_pass_validation_flag can only be either ''Y'' or ''N''');
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   -- ------------------------------------------------------------
   -- Benefit status code lookup is: pv_benefit_status.
   --
   -- If the budget validation is successful, update the benefit
   -- status to ACTIVE. Otherwise, update it to 'FAILED_VALIDATION'
   -- ------------------------------------------------------------
   IF (UPPER(p_pass_validation_flag) = 'Y') THEN
      l_benefit_status_code := 'ACTIVE';

   ELSE
      l_benefit_status_code := 'FAILED_VALIDATION';
   END IF;

   UPDATE pv_ge_benefits_b
   SET    benefit_status_code = l_benefit_status_code
   WHERE  additional_info_1 = p_offer_id;

   -------------------- Exception --------------------------
   EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         FND_MSG_PUB.Count_And_Get( p_encoded   =>  FND_API.G_FALSE,
                                    p_count     =>  x_msg_count,
                                    p_data      =>  x_msg_data);

      WHEN FND_API.g_exc_unexpected_error THEN
         x_return_status := FND_API.g_ret_sts_unexp_error;
         FND_MSG_PUB.count_and_get(
               p_encoded => FND_API.g_false,
               p_count   => x_msg_count,
               p_data    => x_msg_data
         );

      WHEN OTHERS THEN
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
           FND_MSG_PUB.add_exc_msg(g_pkg_name, g_api_name);
        END IF;

        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.count_and_get(
              p_encoded => FND_API.g_false,
              p_count   => x_msg_count,
              p_data    => x_msg_data
        );

END Update_Referral_Status;
-- ======================End of Update_Referral_Status===========================


--=============================================================================+
--|  Private Function                                                          |
--|                                                                            |
--|    Get_Partner_Account                                                     |
--|                                                                            |
--|  Parameters                                                                |
--|  IN                                                                        |
--|  OUT                                                                       |
--|                                                                            |
--|                                                                            |
--| NOTES:                                                                     |
--|                                                                            |
--| HISTORY                                                                    |
--|                                                                            |
--==============================================================================
FUNCTION Get_Partner_Account (
   p_partner_id    IN NUMBER
)
RETURN NUMBER
IS
   -- --------------------------------------------------------------------------
   -- A partner can have multiple customer_account_id's. For now, we will just
   -- pick the one with the lowest cust_account_id.
   --
   -- Note that in 11.5.10, a partner will always have a cust_account_id.
   -- The following query will always return something.
   -- --------------------------------------------------------------------------
   CURSOR c IS
      SELECT MIN(cust_account_id) cust_account_id
      FROM   pv_partner_profiles a,
             hz_cust_accounts    b
      WHERE  a.partner_id       = p_partner_id AND
             a.partner_party_id = b.party_id;

   l_partner_account_id NUMBER;

BEGIN
   FOR x IN c LOOP
      l_partner_account_id := x.cust_account_id;
   END LOOP;

   RETURN l_partner_account_id;
END Get_Partner_Account;
-- ===========================End of Get_Partner_Account========================



--=============================================================================+
--|  Private Procedure                                                         |
--|                                                                            |
--|    Write_Conc_Log                                                          |
--|                                                                            |
--|  Parameters                                                                |
--|  IN                                                                        |
--|  OUT                                                                       |
--|                                                                            |
--|                                                                            |
--| NOTES:                                                                     |
--|                                                                            |
--| HISTORY                                                                    |
--|                                                                            |
--==============================================================================
PROCEDURE Write_Conc_Log IS
    l_count NUMBER;
    l_msg   VARCHAR2(2000);
    l_cnt   NUMBER ;

BEGIN
    l_count := FND_MSG_PUB.count_msg;

    FOR l_cnt IN 1 .. l_count
    LOOP
        l_msg := FND_MSG_PUB.get(l_cnt, FND_API.g_false);
        FND_FILE.PUT_LINE(FND_FILE.LOG, '(' || l_cnt || ') ' || l_msg);
    END LOOP;
END Write_Conc_Log;
-- =============================End of Write_Conc_Log===========================



--=============================================================================+
--|  Private Procedure                                                         |
--|                                                                            |
--|    Debug                                                                   |
--|                                                                            |
--|  Parameters                                                                |
--|  IN                                                                        |
--|  OUT                                                                       |
--|                                                                            |
--|                                                                            |
--| NOTES:                                                                     |
--|                                                                            |
--| HISTORY                                                                    |
--|                                                                            |
--==============================================================================
PROCEDURE Debug(
   p_msg_string      IN VARCHAR2,
   p_msg_type        IN VARCHAR2 := 'PV_DEBUG_MESSAGE',
   p_token_type      IN VARCHAR2 := 'TEXT',
   p_statement_level IN NUMBER   := FND_LOG.LEVEL_PROCEDURE
)
IS
BEGIN
   FND_MESSAGE.Set_Name('PV', p_msg_type);
   FND_MESSAGE.Set_Token(p_token_type, p_msg_string);

   IF (g_log_to_file = 'N') THEN
      FND_MSG_PUB.Add;

   ELSIF (g_log_to_file = 'Y') THEN
      FND_FILE.PUT_LINE( FND_FILE.LOG,  fnd_message.get );
   END IF;

   IF (p_statement_level >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(p_statement_level,
         'pv.plsql.' || g_pkg_name || '.' || g_api_name,
         p_msg_string
      );
   END IF;
END Debug;
-- =================================End of Debug================================


--=============================================================================+
--|  Public Procedure                                                          |
--|                                                                            |
--|    Set_Message                                                             |
--|                                                                            |
--|  Parameters                                                                |
--|  IN                                                                        |
--|  OUT                                                                       |
--|                                                                            |
--|                                                                            |
--| NOTES:                                                                     |
--|                                                                            |
--| HISTORY                                                                    |
--|                                                                            |
--==============================================================================
PROCEDURE Set_Message(
    p_msg_name      IN      VARCHAR2,
    p_token1        IN      VARCHAR2 := NULL,
    p_token1_value  IN      VARCHAR2 := NULL,
    p_token2        IN      VARCHAR2 := NULL,
    p_token2_value  IN      VARCHAR2 := NULL,
    p_token3        IN      VARCHAR2 := NULL,
    p_token3_value  IN      VARCHAR2 := NULL,
    p_statement_level IN NUMBER   := FND_LOG.LEVEL_PROCEDURE
)
IS
BEGIN
   FND_MESSAGE.Set_Name('PV', p_msg_name);

   IF (p_token1 IS NOT NULL) THEN
      FND_MESSAGE.Set_Token(p_token1, p_token1_value);
   END IF;

   IF (p_token2 IS NOT NULL) THEN
      FND_MESSAGE.Set_Token(p_token2, p_token2_value);
   END IF;

   IF (p_token3 IS NOT NULL) THEN
      FND_MESSAGE.Set_Token(p_token3, p_token3_value);
   END IF;

   IF (p_statement_level >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.MESSAGE(
         p_statement_level,
         'pv.plsql.' || g_pkg_name || '.' || g_api_name,
         FALSE
      );
   END IF;

   IF (g_log_to_file = 'N') THEN
      FND_MSG_PUB.Add;

   ELSIF (g_log_to_file = 'Y') THEN
      FND_FILE.PUT_LINE(FND_FILE.LOG,  fnd_message.get);
   END IF;

END Set_Message;
-- ==============================End of Set_Message==============================

END PV_REFERRAL_COMP_PUB;

/
