--------------------------------------------------------
--  DDL for Package Body OZF_SYS_PARAMETERS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_SYS_PARAMETERS_PVT" AS
/* $Header: ozfvsysb.pls 120.13.12010000.4 2009/07/27 09:30:40 nirprasa ship $ */

g_pkg_name   CONSTANT VARCHAR2(30):='OZF_Sys_Parameters_PVT';

G_DEBUG BOOLEAN := FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_high);




-- PROCEDURE
--    Check_Batch_Tolerances
--
-- HISTORY
--    05/18/2004  upoluri  Create.
---------------------------------------------------------------------
PROCEDURE Check_Batch_Tolerances(
   p_sys_parameters_rec IN  sys_parameters_rec_type
  ,x_return_status      OUT NOCOPY VARCHAR2
)
IS

BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   IF (p_sys_parameters_rec.header_tolerance_calc_code is null
         AND p_sys_parameters_rec.header_tolerance_operand is not null)
         THEN
               IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
               THEN
                  FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_BATCH_TOL_TYPE_REQ');
                  FND_MSG_PUB.add;
              END IF;
              x_return_status := FND_API.g_ret_sts_error;
              RETURN;
      ELSIF (p_sys_parameters_rec.header_tolerance_calc_code is not null
         AND p_sys_parameters_rec.header_tolerance_operand is null)
         THEN
               IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
               THEN
                  FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_BATCH_TOL_VAL_REQ');
                  FND_MSG_PUB.add;
              END IF;
              x_return_status := FND_API.g_ret_sts_error;
              RETURN;
      END IF;

      IF (p_sys_parameters_rec.line_tolerance_calc_code is null
         AND p_sys_parameters_rec.line_tolerance_operand is not null )
         THEN
               IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
               THEN
                  FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_LINE_TOL_TYPE_REQ');
                  FND_MSG_PUB.add;
              END IF;
              x_return_status := FND_API.g_ret_sts_error;
              RETURN;
      ELSIF (p_sys_parameters_rec.line_tolerance_calc_code is not null
         AND p_sys_parameters_rec.line_tolerance_operand is null)
         THEN
               IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
               THEN
                  FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_LINE_TOL_VAL_REQ');
                  FND_MSG_PUB.add;
              END IF;
              x_return_status := FND_API.g_ret_sts_error;
              RETURN;
      END IF;

      -- For Rule Based Settlement
       IF (p_sys_parameters_rec.credit_matching_thold_type is null
         AND p_sys_parameters_rec.credit_tolerance_operand is not null )
         THEN
               IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
               THEN
                  FND_MESSAGE.set_name('OZF', 'OZF_CREDIT_THRES_TYPE_REQ');
                  FND_MSG_PUB.add;
              END IF;
              x_return_status := FND_API.g_ret_sts_error;
              RETURN;
      ELSIF (p_sys_parameters_rec.credit_tolerance_operand is null
         AND p_sys_parameters_rec.credit_matching_thold_type is not null)
         THEN
               IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
               THEN
                  FND_MESSAGE.set_name('OZF', 'OZF_CREDIT_THRES_VAL_REQ');
                  FND_MSG_PUB.add;
              END IF;
              x_return_status := FND_API.g_ret_sts_error;
              RETURN;
      END IF;

      -- For Rule Based Settlement
     IF(p_sys_parameters_rec.credit_matching_thold_type = '%' AND
       p_sys_parameters_rec.credit_tolerance_operand is not null AND p_sys_parameters_rec.credit_tolerance_operand > 100)
       THEN
              IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
               THEN
                  FND_MESSAGE.set_name('OZF', 'OZF_CREDIT_THRES_VALIDATION');
                  FND_MSG_PUB.add;
              END IF;
              x_return_status := FND_API.g_ret_sts_error;
              RETURN;
      END IF;


END Check_Batch_Tolerances;

---------------------------------------------------------------------
-- PROCEDURE
--    Create_Sys_Parameters
--
-- HISTORY
--    06/12/2000  mchang  Create.
--    08/31/2000  mchang  Updated: insert 4 more columns.
--    03/15/2001  mchang  Updated: insert autopay setting columns.
---------------------------------------------------------------------
PROCEDURE Create_Sys_Parameters(
   p_api_version       IN  NUMBER
  ,p_init_msg_list     IN  VARCHAR2  := FND_API.g_false
  ,p_commit            IN  VARCHAR2  := FND_API.g_false
  ,p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full

  ,x_return_status     OUT NOCOPY VARCHAR2
  ,x_msg_count         OUT NOCOPY NUMBER
  ,x_msg_data          OUT NOCOPY VARCHAR2

  ,p_sys_parameters_rec IN  sys_parameters_rec_type
  ,x_set_of_books_id    OUT NOCOPY NUMBER
)
IS

   l_api_version CONSTANT NUMBER       := 1.0;
   l_api_name    CONSTANT VARCHAR2(30) := 'Create_Sys_Parameters';
   l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

   l_last_updated_by       NUMBER;
   l_created_by            NUMBER;
   l_last_update_login     NUMBER;
   l_org_id                NUMBER;
   l_post_to_gl            VARCHAR2(1);
   l_transfer_to_gl        VARCHAR2(1);

   l_return_status         VARCHAR2(1);
   l_sys_parameters_rec    sys_parameters_rec_type := p_sys_parameters_rec;
   l_object_version_number NUMBER := 1;
   l_books_id_count        NUMBER;

   l_set_of_books_id       NUMBER;
   l_set_of_books          VARCHAR2(30);


   -- Cursor to validate the uniqueness of the set_of_books_id
   CURSOR c_books_id_count(cv_org_id IN NUMBER) IS
   SELECT  COUNT(set_of_books_id)
     FROM  ozf_sys_parameters;
     --WHERE org_id = cv_org_id;
     --WHERE set_of_books_id = cv_books_id;

BEGIN

   --------------------- initialize -----------------------
   SAVEPOINT Create_Sys_Parameters;

   IF g_debug THEN
      OZF_Utility_PVT.debug_message(l_full_name||': start');
   END IF;

   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   IF NOT FND_API.compatible_api_call(
         l_api_version,
         p_api_version,
         l_api_name,
         g_pkg_name
   ) THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   x_return_status := FND_API.g_ret_sts_success;

   l_last_updated_by := NVL(FND_GLOBAL.user_id,-1);
   l_created_by := NVL(FND_GLOBAL.user_id,-1);
   l_last_update_login := NVL(FND_GLOBAL.conc_login_id,-1);

   l_post_to_gl := l_sys_parameters_rec.post_to_gl;  -- Bug 4760420

   --bugfix 4743804
    IF l_post_to_gl IS NULL OR l_post_to_gl = FND_API.G_MISS_CHAR
   THEN
      l_post_to_gl:=FND_API.g_false;
   END IF;

   IF l_transfer_to_gl  IS NULL OR l_transfer_to_gl = FND_API.G_MISS_CHAR
   THEN
      l_transfer_to_gl:=FND_API.g_false;
   END IF;
   --end bugfix 4743804

   l_org_id := l_sys_parameters_rec.org_id;  -- R12 Enhancements

   ----------------------- validate -----------------------
   IF g_debug THEN
      OZF_Utility_PVT.debug_message(l_full_name ||': validate');
   END IF;

   -- validate the uniqueness of the set_of_books_id
   IF p_sys_parameters_rec.set_of_books_id IS NULL THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_SET_OF_BOOKS_NULL');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
   ELSE
      --OPEN c_books_id_count(p_sys_parameters_rec.set_of_books_id);
      OPEN c_books_id_count(l_org_id);
      FETCH c_books_id_count INTO l_books_id_count;
      CLOSE c_books_id_count;

      -- R12 : Commented below condition, to add multiple system parameters.
     /* IF l_books_id_count > 0 THEN
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
           FND_MESSAGE.set_name('OZF', 'OZF_SET_OF_BOOKS_EXIST');
           FND_MSG_PUB.add;
        END IF;
        RAISE FND_API.g_exc_error;
      END IF;  */
   END IF;

   -- Get the set_of_books_id for given org_id
   MO_UTILS.Get_Ledger_Info (
     p_operating_unit     =>  l_sys_parameters_rec.org_id,
     p_ledger_id          =>  l_set_of_books_id,
     p_ledger_name        =>  l_set_of_books
   );

   l_sys_parameters_rec.set_of_books_id := l_set_of_books_id;

   Validate_Sys_Parameters(
      p_api_version         => l_api_version,
      p_init_msg_list       => p_init_msg_list,
      p_validation_level    => p_validation_level,
      x_return_status       => l_return_status,
      x_msg_count           => x_msg_count,
      x_msg_data            => x_msg_data,
      p_sys_parameters_rec  => l_sys_parameters_rec
   );

   IF l_return_status = FND_API.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
   ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

  -------------------------- insert --------------------------
  IF g_debug THEN
     OZF_Utility_PVT.debug_message(l_full_name ||': insert');
  END IF;

  INSERT INTO ozf_sys_parameters_all (
       set_of_books_id
      ,object_version_number
      ,last_update_date
      ,last_updated_by
      ,creation_date
      ,created_by
      ,last_update_login
      ,request_id
      ,program_application_id
      ,program_update_date
      ,program_id
      ,created_from
      ,post_to_gl
      ,transfer_to_gl_in
      ,ap_payment_term_id
      ,rounding_level_flag
      ,gl_id_rounding
      ,gl_id_ded_clearing
      ,gl_id_ded_adj
      ,gl_id_accr_promo_liab
      ,gl_id_ded_adj_clearing
      ,gl_rec_ded_account
      ,gl_rec_clearing_account
      ,gl_cost_adjustment_acct
      ,gl_contra_liability_acct
      ,gl_pp_accrual_acct
      ,gl_date_type
      ,days_due
      ,claim_type_id
      ,reason_code_id
      ,autopay_claim_type_id
      ,autopay_reason_code_id
      ,autopay_flag
      ,autopay_periodicity
      ,autopay_periodicity_type
      ,accounting_method_option
      ,billback_trx_type_id
      ,cm_trx_type_id
      ,attribute_category
      ,attribute1
      ,attribute2
      ,attribute3
      ,attribute4
      ,attribute5
      ,attribute6
      ,attribute7
      ,attribute8
      ,attribute9
      ,attribute10
      ,attribute11
      ,attribute12
      ,attribute13
      ,attribute14
      ,attribute15
      ,org_id
      ,batch_source_id
      ,payables_source
      ,default_owner_id
      ,auto_assign_flag
      ,exchange_rate_type
      ,order_type_id
      --11.5.10 enhancements
          , gl_acct_for_offinv_flag
          --, short_payment_reason_code_id
          , cb_trx_type_id
          , pos_write_off_threshold
          , neg_write_off_threshold
          , adj_rec_trx_id
          , wo_rec_trx_id
          , neg_wo_rec_trx_id
          , un_earned_pay_allow_to
          , un_earned_pay_thold_type
          , un_earned_pay_thold_amount
          , un_earned_pay_thold_flag
          , header_tolerance_calc_code
          , header_tolerance_operand
          , line_tolerance_calc_code
          , line_tolerance_operand

      , ship_debit_accrual_flag
      , ship_debit_calc_type
      , inventory_tracking_flag
      , end_cust_relation_flag
      , auto_tp_accrual_flag
      , gl_balancing_flex_value
      , prorate_earnings_flag
      , sales_credit_default_type
      , net_amt_for_mass_settle_flag

      ,claim_tax_incl_flag
      --For Rule Based Settlement
      ,rule_based
      ,approval_new_credit
      ,approval_matched_credit
      ,cust_name_match_type
      ,credit_matching_thold_type
      ,credit_tolerance_operand
      -- For Price Protection Parallel Approval ER
      ,automate_notification_days
      -- For SSD Default Adjustment Types
      ,ssd_inc_adj_type_id
      ,ssd_dec_adj_type_id
  )
  VALUES (
       l_sys_parameters_rec.set_of_books_id
      ,l_object_version_number
      ,SYSDATE                                -- LAST_UPDATE_DATE
      ,l_last_updated_by                      -- LAST_UPDATED_BY
      ,SYSDATE                                -- CREATION_DATE
      ,l_created_by                           -- CREATED_BY
      ,l_last_update_login                    -- LAST_UPDATE_LOGIN
      ,FND_GLOBAL.CONC_REQUEST_ID             -- REQUEST_ID
      ,FND_GLOBAL.PROG_APPL_ID                -- PROGRAM_APPLICATION_ID
      ,SYSDATE                                -- PROGRAM_UPDATE_DATE
      ,FND_GLOBAL.CONC_PROGRAM_ID             -- PROGRAM_ID
      ,l_sys_parameters_rec.created_from      -- CREATED_FROM
      ,l_post_to_gl
      ,l_transfer_to_gl
      ,l_sys_parameters_rec.ap_payment_term_id
      ,l_sys_parameters_rec.rounding_level_flag
      ,l_sys_parameters_rec.gl_id_rounding
      ,l_sys_parameters_rec.gl_id_ded_clearing
      ,l_sys_parameters_rec.gl_id_ded_adj
      ,l_sys_parameters_rec.gl_id_accr_promo_liab
      ,l_sys_parameters_rec.gl_id_ded_adj_clearing
      ,l_sys_parameters_rec.gl_rec_ded_account
      ,l_sys_parameters_rec.gl_rec_clearing_account
      ,l_sys_parameters_rec.gl_cost_adjustment_acct
      ,l_sys_parameters_rec.gl_contra_liability_acct
      ,l_sys_parameters_rec.gl_pp_accrual_acct
      ,l_sys_parameters_rec.gl_date_type
      ,l_sys_parameters_rec.days_due
      ,l_sys_parameters_rec.claim_type_id
      ,l_sys_parameters_rec.reason_code_id
      ,l_sys_parameters_rec.autopay_claim_type_id
      ,l_sys_parameters_rec.autopay_reason_code_id
      ,l_sys_parameters_rec.autopay_flag
      ,l_sys_parameters_rec.autopay_periodicity
      ,l_sys_parameters_rec.autopay_periodicity_type
      ,l_sys_parameters_rec.accounting_method_option
      ,l_sys_parameters_rec.billback_trx_type_id
      ,l_sys_parameters_rec.cm_trx_type_id
      ,l_sys_parameters_rec.attribute_category
      ,l_sys_parameters_rec.attribute1
      ,l_sys_parameters_rec.attribute2
      ,l_sys_parameters_rec.attribute3
      ,l_sys_parameters_rec.attribute4
      ,l_sys_parameters_rec.attribute5
      ,l_sys_parameters_rec.attribute6
      ,l_sys_parameters_rec.attribute7
      ,l_sys_parameters_rec.attribute8
      ,l_sys_parameters_rec.attribute9
      ,l_sys_parameters_rec.attribute10
      ,l_sys_parameters_rec.attribute11
      ,l_sys_parameters_rec.attribute12
      ,l_sys_parameters_rec.attribute13
      ,l_sys_parameters_rec.attribute14
      ,l_sys_parameters_rec.attribute15
      ,l_org_id                                       -- org_id
      ,l_sys_parameters_rec.batch_source_id
      ,l_sys_parameters_rec.payables_source
      ,l_sys_parameters_rec.default_owner_id
      ,l_sys_parameters_rec.auto_assign_flag
      ,l_sys_parameters_rec.exchange_rate_type
      ,l_sys_parameters_rec.order_type_id
      --11.5.10 enhancements
      ,l_sys_parameters_rec.gl_acct_for_offinv_flag
      --,l_sys_parameters_rec.short_payment_reason_code_id
      ,l_sys_parameters_rec.cb_trx_type_id
      ,l_sys_parameters_rec.pos_write_off_threshold
      ,l_sys_parameters_rec.neg_write_off_threshold
      ,l_sys_parameters_rec.adj_rec_trx_id
      ,l_sys_parameters_rec.wo_rec_trx_id
      ,l_sys_parameters_rec.neg_wo_rec_trx_id
      ,l_sys_parameters_rec.un_earned_pay_allow_to
      ,l_sys_parameters_rec.un_earned_pay_thold_type
      ,l_sys_parameters_rec.un_earned_pay_threshold
      ,l_sys_parameters_rec.un_earned_pay_thold_flag
      ,l_sys_parameters_rec.header_tolerance_calc_code
      ,l_sys_parameters_rec.header_tolerance_operand
      ,l_sys_parameters_rec.line_tolerance_calc_code
      ,l_sys_parameters_rec.line_tolerance_operand

      ,l_sys_parameters_rec.ship_debit_accrual_flag
      ,l_sys_parameters_rec.ship_debit_calc_type
      ,l_sys_parameters_rec.inventory_tracking_flag
      ,l_sys_parameters_rec.end_cust_relation_flag
      ,l_sys_parameters_rec.auto_tp_accrual_flag
      ,l_sys_parameters_rec.gl_balancing_flex_value
      ,l_sys_parameters_rec.prorate_earnings_flag
      ,l_sys_parameters_rec.sales_credit_default_type
      ,l_sys_parameters_rec.net_amt_for_mass_settle_flag
      ,l_sys_parameters_rec.claim_tax_incl_flag
      ,l_sys_parameters_rec.rule_based
      ,l_sys_parameters_rec.approval_new_credit
      ,l_sys_parameters_rec.approval_matched_credit
      ,l_sys_parameters_rec.cust_name_match_type
      ,l_sys_parameters_rec.credit_matching_thold_type
      ,l_sys_parameters_rec.credit_tolerance_operand
      ,l_sys_parameters_rec.automate_notification_days
      ,l_sys_parameters_rec.ssd_inc_adj_type_id
      ,l_sys_parameters_rec.ssd_dec_adj_type_id
      );

  ------------------------- finish -------------------------------
  x_set_of_books_id := l_sys_parameters_rec.set_of_books_id;

  -- Check for commit
  IF FND_API.to_boolean(p_commit) THEN
    COMMIT;
  END IF;

  FND_MSG_PUB.count_and_get(
         p_encoded => FND_API.g_false,
         p_count   => x_msg_count,
         p_data    => x_msg_data
  );

  IF g_debug THEN
     OZF_Utility_PVT.debug_message(l_full_name ||': end');
  END IF;

EXCEPTION
    WHEN FND_API.g_exc_error THEN
      ROLLBACK TO Create_Sys_Parameters;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get (
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
          );

    WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO Create_Sys_Parameters;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get (
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
          );


    WHEN OTHERS THEN
      ROLLBACK TO Create_Sys_Parameters;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error)
                THEN
         FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      FND_MSG_PUB.count_and_get(
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
          );

END Create_Sys_Parameters;


---------------------------------------------------------------
-- PROCEDURE
--    Delete_Sys_Parameters
--
-- HISTORY
--    06/12/2000  mchang  Create.
---------------------------------------------------------------
PROCEDURE Delete_Sys_Parameters(
   p_api_version       IN  NUMBER
  ,p_init_msg_list     IN  VARCHAR2 := FND_API.g_false
  ,p_commit            IN  VARCHAR2 := FND_API.g_false

  ,x_return_status     OUT NOCOPY VARCHAR2
  ,x_msg_count         OUT NOCOPY NUMBER
  ,x_msg_data          OUT NOCOPY VARCHAR2

  ,p_set_of_books_id   IN  NUMBER
  ,p_object_version    IN  NUMBER
)
IS

   l_api_version CONSTANT NUMBER       := 1.0;
   l_api_name    CONSTANT VARCHAR2(30) := 'Delete_Sys_Parameters';
   l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
   l_org_id      NUMBER :=  MO_GLOBAL.GET_CURRENT_ORG_ID();  -- R12 Enhancements

BEGIN

   --------------------- initialize -----------------------
   SAVEPOINT Delete_Sys_Parameters;

   IF g_debug THEN
      OZF_Utility_PVT.debug_message(l_full_name||': start');
   END IF;

   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   IF NOT FND_API.compatible_api_call(
         l_api_version,
         p_api_version,
         l_api_name,
         g_pkg_name
   ) THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   ------------------------ delete ------------------------
   IF g_debug THEN
      OZF_Utility_PVT.debug_message(l_full_name ||': delete');
   END IF;

   DELETE FROM ozf_sys_parameters_all
     WHERE set_of_books_id = p_set_of_books_id
     AND   object_version_number = p_object_version
     AND   org_id = l_org_id; -- R12 Enhancements

   IF (SQL%NOTFOUND) THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
       THEN
         FND_MESSAGE.set_name('OZF', 'OZF_API_RECORD_NOT_FOUND');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
   END IF;

   -------------------- finish --------------------------
   IF FND_API.to_boolean(p_commit) THEN
      COMMIT;
   END IF;

   FND_MSG_PUB.count_and_get(
         p_encoded => FND_API.g_false,
         p_count   => x_msg_count,
         p_data    => x_msg_data
   );

   IF g_debug THEN
      OZF_Utility_PVT.debug_message(l_full_name ||': end');
   END IF;

EXCEPTION
   WHEN FND_API.g_exc_error THEN
      ROLLBACK TO Delete_Sys_Parameters;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO Delete_Sys_Parameters;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN OTHERS THEN
      ROLLBACK TO Delete_Sys_Parameters;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error)
                THEN
         FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

END Delete_Sys_Parameters;


-------------------------------------------------------------------
-- PROCEDURE
--    Lock_Sys_Parameters
--
-- HISTORY
--    06/12/2000  mchang  Create.
--------------------------------------------------------------------
PROCEDURE Lock_Sys_Parameters(
   p_api_version       IN  NUMBER
  ,p_init_msg_list     IN  VARCHAR2 := FND_API.g_false

  ,x_return_status     OUT NOCOPY VARCHAR2
  ,x_msg_count         OUT NOCOPY NUMBER
  ,x_msg_data          OUT NOCOPY VARCHAR2

  ,p_set_of_books_id   IN  NUMBER
  ,p_object_version    IN  NUMBER
)
IS

   l_api_version  CONSTANT NUMBER       := 1.0;
   l_api_name     CONSTANT VARCHAR2(30) := 'Lock_Sys_Parameters';
   l_full_name    CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

   l_set_of_books_id      NUMBER;

   CURSOR c_sys_para IS
   SELECT  set_of_books_id
     FROM  ozf_sys_parameters_all
     WHERE set_of_books_id = p_set_of_books_id
     AND   object_version_number = p_object_version
   FOR UPDATE OF set_of_books_id NOWAIT;

BEGIN

   -------------------- initialize ------------------------
   IF g_debug THEN
      OZF_Utility_PVT.debug_message(l_full_name||': start');
   END IF;

   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   IF NOT FND_API.compatible_api_call(
         l_api_version,
         p_api_version,
         l_api_name,
         g_pkg_name
   ) THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   ------------------------ lock -------------------------
   IF g_debug THEN
      OZF_Utility_PVT.debug_message(l_full_name||': lock');
   END IF;

   OPEN  c_sys_para;
   FETCH c_sys_para INTO l_set_of_books_id;
   IF (c_sys_para%NOTFOUND) THEN
      CLOSE c_sys_para;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_API_RECORD_NOT_FOUND');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
   END IF;
   CLOSE c_sys_para;

   -------------------- finish --------------------------
   FND_MSG_PUB.count_and_get(
         p_encoded => FND_API.g_false,
         p_count   => x_msg_count,
         p_data    => x_msg_data
   );

   IF g_debug THEN
      OZF_Utility_PVT.debug_message(l_full_name ||': end');
   END IF;

EXCEPTION
   WHEN OZF_Utility_PVT.resource_locked THEN
      x_return_status := FND_API.g_ret_sts_error;
                IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
                   FND_MESSAGE.set_name('OZF', 'OZF_API_RESOURCE_LOCKED');
                   FND_MSG_PUB.add;
                END IF;

      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

        WHEN FND_API.g_exc_error THEN
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN FND_API.g_exc_unexpected_error THEN
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN OTHERS THEN
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error)
                THEN
         FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

END Lock_Sys_Parameters;


---------------------------------------------------------------------
-- PROCEDURE
--    Update_Sys_Parameters
--
-- HISTORY
--    06/12/2000  mchang  Create.
--    08/31/2000  mchang  Updated: insert 4 more columns.
--    03/15/2001  mchang  Updated: insert autopay setting columns.
----------------------------------------------------------------------
PROCEDURE Update_Sys_Parameters(
   p_api_version             IN  NUMBER
  ,p_init_msg_list           IN  VARCHAR2  := FND_API.g_false
  ,p_commit                  IN  VARCHAR2  := FND_API.g_false
  ,p_validation_level        IN  NUMBER    := FND_API.g_valid_level_full

  ,x_return_status           OUT NOCOPY VARCHAR2
  ,x_msg_count               OUT NOCOPY NUMBER
  ,x_msg_data                OUT NOCOPY VARCHAR2

  ,p_sys_parameters_rec      IN  sys_parameters_rec_type
  ,p_mode                    IN  VARCHAR2 := JTF_PLSQL_API.g_update
  ,x_object_version_number   OUT NOCOPY NUMBER
)
IS

   l_api_version CONSTANT   NUMBER := 1.0;
   l_api_name    CONSTANT   VARCHAR2(30) := 'Update_Sys_Parameters';
   l_full_name   CONSTANT   VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

   l_last_updated_by        NUMBER;
   l_last_update_login      NUMBER;

   l_sys_parameters_rec     sys_parameters_rec_type;
   l_return_status          VARCHAR2(1);
   l_mode                   VARCHAR2(30);
   l_object_version_number  NUMBER;
   -- l_org_id                 NUMBER := MO_GLOBAL.GET_CURRENT_ORG_ID();  -- R12 Enhancements

   l_set_of_books_id       NUMBER;
   l_set_of_books          VARCHAR2(30);


BEGIN

   -------------------- initialize -------------------------
   SAVEPOINT Update_Sys_Parameters;

   IF g_debug THEN
      OZF_Utility_PVT.debug_message(l_full_name||': start');
   END IF;

   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   IF NOT FND_API.compatible_api_call(
         l_api_version,
         p_api_version,
         l_api_name,
         g_pkg_name
   ) THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   l_last_updated_by := NVL(FND_GLOBAL.user_id,-1);
   l_last_update_login := NVL(FND_GLOBAL.conc_login_id,-1);

   ----------------------- validate ----------------------
   IF g_debug THEN
      OZF_Utility_PVT.debug_message(l_full_name ||': validate');
   END IF;

   IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
      Check_Sys_Parameters_Items(
         p_sys_parameters_rec   => p_sys_parameters_rec,
         p_validation_mode      => JTF_PLSQL_API.g_update,
         x_return_status        => l_return_status
      );
      IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      ELSIF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      END IF;
   END IF;

   -- replace g_miss_char/num/date with current column values
   Complete_Sys_Parameters_Rec(
         p_sys_parameters_rec =>  p_sys_parameters_rec
        ,x_complete_rec       =>  l_sys_parameters_rec
   );

   IF p_validation_level >= JTF_PLSQL_API.g_valid_level_record THEN
      Check_Sys_Parameters_Record(
         p_sys_parameters_rec => p_sys_parameters_rec,
         p_complete_rec       => l_sys_parameters_rec,
         p_mode               => p_mode,
         x_return_status      => l_return_status
      );
      IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      ELSIF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      END IF;
   END IF;

   --Check the tolerances.
   Check_Batch_Tolerances(
      p_sys_parameters_rec =>  l_sys_parameters_rec,
      x_return_status      =>  l_return_status
    );
   IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
   ELSIF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
   END IF;

   l_object_version_number := l_sys_parameters_rec.object_version_number + 1;
ozf_utility_pvt.debug_message('Object version number is :'||
l_sys_parameters_rec.object_version_number);

ozf_utility_pvt.debug_message('Orgid is :'||p_sys_parameters_rec.org_id);
ozf_utility_pvt.debug_message('l_sys_parameters_rec.transfer_to_gl_in :'||l_sys_parameters_rec.transfer_to_gl_in);

-- Get the set_of_books_id for given org_id
   MO_UTILS.Get_Ledger_Info (
     p_operating_unit     =>  p_sys_parameters_rec.org_id,
     p_ledger_id          =>  l_set_of_books_id,
     p_ledger_name        =>  l_set_of_books
   );

   l_sys_parameters_rec.set_of_books_id := l_set_of_books_id;

   -------------------------- update --------------------
   IF g_debug THEN
      OZF_Utility_PVT.debug_message(l_full_name ||': update');
   END IF;
   UPDATE ozf_sys_parameters_all SET
       set_of_books_id                  = l_sys_parameters_rec.set_of_books_id
      ,object_version_number            = l_object_version_number
      ,last_update_date                 = SYSDATE
      ,last_updated_by                  = l_last_updated_by
      ,last_update_login                = l_last_update_login
      ,request_id                       = FND_GLOBAL.CONC_REQUEST_ID
      ,program_application_id           = FND_GLOBAL.PROG_APPL_ID
      ,program_update_date              = SYSDATE
      ,program_id                       = FND_GLOBAL.CONC_PROGRAM_ID
      ,created_from                     = l_sys_parameters_rec.created_from
      ,post_to_gl                       = l_sys_parameters_rec.post_to_gl
      ,transfer_to_gl_in                = l_sys_parameters_rec.transfer_to_gl_in
      ,ap_payment_term_id               = l_sys_parameters_rec.ap_payment_term_id
      ,rounding_level_flag              = l_sys_parameters_rec.rounding_level_flag
      ,gl_id_rounding                   = l_sys_parameters_rec.gl_id_rounding
      ,gl_id_ded_clearing               = l_sys_parameters_rec.gl_id_ded_clearing
      ,gl_id_ded_adj                    = l_sys_parameters_rec.gl_id_ded_adj
      ,gl_id_accr_promo_liab            = l_sys_parameters_rec.gl_id_accr_promo_liab
      ,gl_id_ded_adj_clearing           = l_sys_parameters_rec.gl_id_ded_adj_clearing
      ,gl_rec_ded_account               = l_sys_parameters_rec.gl_rec_ded_account
      ,gl_rec_clearing_account          = l_sys_parameters_rec.gl_rec_clearing_account
      ,gl_cost_adjustment_acct          = l_sys_parameters_rec.gl_cost_adjustment_acct
      ,gl_contra_liability_acct         = l_sys_parameters_rec.gl_contra_liability_acct
      ,gl_pp_accrual_acct               = l_sys_parameters_rec.gl_pp_accrual_acct
      ,gl_date_type                     = l_sys_parameters_rec.gl_date_type
      ,days_due                         = l_sys_parameters_rec.days_due
      ,claim_type_id                    = l_sys_parameters_rec.claim_type_id
      ,reason_code_id                   = l_sys_parameters_rec.reason_code_id
      ,autopay_claim_type_id            = l_sys_parameters_rec.autopay_claim_type_id
      ,autopay_reason_code_id           = l_sys_parameters_rec.autopay_reason_code_id
      ,autopay_flag                     = l_sys_parameters_rec.autopay_flag
      ,autopay_periodicity              = l_sys_parameters_rec.autopay_periodicity
      ,autopay_periodicity_type         = l_sys_parameters_rec.autopay_periodicity_type
      ,accounting_method_option         = l_sys_parameters_rec.accounting_method_option
      ,billback_trx_type_id             = l_sys_parameters_rec.billback_trx_type_id
      ,cm_trx_type_id                   = l_sys_parameters_rec.cm_trx_type_id
      ,attribute_category               = l_sys_parameters_rec.attribute_category
      ,attribute1                       = l_sys_parameters_rec.attribute1
      ,attribute2                       = l_sys_parameters_rec.attribute2
      ,attribute3                       = l_sys_parameters_rec.attribute3
      ,attribute4                       = l_sys_parameters_rec.attribute4
      ,attribute5                       = l_sys_parameters_rec.attribute5
      ,attribute6                       = l_sys_parameters_rec.attribute6
      ,attribute7                       = l_sys_parameters_rec.attribute7
      ,attribute8                       = l_sys_parameters_rec.attribute8
      ,attribute9                       = l_sys_parameters_rec.attribute9
      ,attribute10                      = l_sys_parameters_rec.attribute10
      ,attribute11                      = l_sys_parameters_rec.attribute11
      ,attribute12                      = l_sys_parameters_rec.attribute12
      ,attribute13                      = l_sys_parameters_rec.attribute13
      ,attribute14                      = l_sys_parameters_rec.attribute14
      ,attribute15                      = l_sys_parameters_rec.attribute15
      --,org_id                         = l_sys_parameters_rec.org_id
      ,batch_source_id                  = l_sys_parameters_rec.batch_source_id
      ,payables_source                  = l_sys_parameters_rec.payables_source
      ,default_owner_id                 = l_sys_parameters_rec.default_owner_id
      ,auto_assign_flag                 = l_sys_parameters_rec.auto_assign_flag
      ,exchange_rate_type               = l_sys_parameters_rec.exchange_rate_type
      ,order_type_id                    = l_sys_parameters_rec.order_type_id
      --11.5.10 enhancements
      ,gl_acct_for_offinv_flag          = l_sys_parameters_rec.gl_acct_for_offinv_flag
      --,short_payment_reason_code_id   = l_sys_parameters_rec.short_payment_reason_code_id
      ,cb_trx_type_id                   = l_sys_parameters_rec.cb_trx_type_id
      ,pos_write_off_threshold          = l_sys_parameters_rec.pos_write_off_threshold
      ,neg_write_off_threshold          = l_sys_parameters_rec.neg_write_off_threshold
      ,adj_rec_trx_id                   = l_sys_parameters_rec.adj_rec_trx_id
      ,wo_rec_trx_id                    = l_sys_parameters_rec.wo_rec_trx_id
      ,neg_wo_rec_trx_id                = l_sys_parameters_rec.neg_wo_rec_trx_id
      ,un_earned_pay_allow_to           = l_sys_parameters_rec.un_earned_pay_allow_to
      ,un_earned_pay_thold_type         = l_sys_parameters_rec.un_earned_pay_thold_type
      ,un_earned_pay_thold_amount       = l_sys_parameters_rec.un_earned_pay_threshold
      ,un_earned_pay_thold_flag         = l_sys_parameters_rec.un_earned_pay_thold_flag
      ,header_tolerance_calc_code       = l_sys_parameters_rec.header_tolerance_calc_code
      ,header_tolerance_operand         = l_sys_parameters_rec.header_tolerance_operand
      ,line_tolerance_calc_code         = l_sys_parameters_rec.line_tolerance_calc_code
      ,line_tolerance_operand           = l_sys_parameters_rec.line_tolerance_operand

     ,ship_debit_accrual_flag          = l_sys_parameters_rec.ship_debit_accrual_flag
      ,ship_debit_calc_type             = l_sys_parameters_rec.ship_debit_calc_type
      ,inventory_tracking_flag          = l_sys_parameters_rec.inventory_tracking_flag
      ,end_cust_relation_flag           = l_sys_parameters_rec.end_cust_relation_flag
      ,auto_tp_accrual_flag             = l_sys_parameters_rec.auto_tp_accrual_flag
      ,gl_balancing_flex_value          = l_sys_parameters_rec.gl_balancing_flex_value
      ,prorate_earnings_flag            = l_sys_parameters_rec.prorate_earnings_flag
      ,sales_credit_default_type        = l_sys_parameters_rec.sales_credit_default_type
      ,net_amt_for_mass_settle_flag     = l_sys_parameters_rec.net_amt_for_mass_settle_flag
      ,claim_tax_incl_flag              =  l_sys_parameters_rec.claim_tax_incl_flag
      -- For Rule Based Settlement
      ,rule_based                       =  l_sys_parameters_rec.rule_based
      ,approval_new_credit              =  l_sys_parameters_rec.approval_new_credit
      ,approval_matched_credit          =  l_sys_parameters_rec.approval_matched_credit
      ,cust_name_match_type             =  l_sys_parameters_rec.cust_name_match_type
      ,credit_matching_thold_type       =  l_sys_parameters_rec.credit_matching_thold_type
      ,credit_tolerance_operand         =  l_sys_parameters_rec.credit_tolerance_operand
      -- For Price Protection Parallel Approval ER
      ,automate_notification_days       = l_sys_parameters_rec.automate_notification_days
      -- For SSD Default Adjustment Types
      ,ssd_inc_adj_type_id                            =  l_sys_parameters_rec.ssd_inc_adj_type_id
      ,ssd_dec_adj_type_id                            =  l_sys_parameters_rec.ssd_dec_adj_type_id
       WHERE object_version_number = l_sys_parameters_rec.object_version_number
        --AND org_id = l_org_id; -- R12 Enhancements
       AND org_id = p_sys_parameters_rec.org_id;

   IF (SQL%NOTFOUND) THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_API_RECORD_NOT_FOUND');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
   END IF;

   -------------------- finish --------------------------

   x_object_version_number := l_object_version_number;

   -- Check for commit
   IF FND_API.to_boolean(p_commit) THEN
      COMMIT;
   END IF;

   FND_MSG_PUB.count_and_get(
         p_encoded => FND_API.g_false,
         p_count   => x_msg_count,
         p_data    => x_msg_data
   );

   IF g_debug THEN
      OZF_Utility_PVT.debug_message(l_full_name ||': end');
   END IF;

EXCEPTION

   WHEN FND_API.g_exc_error THEN
      ROLLBACK TO Update_Sys_Parameters;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO Update_Sys_Parameters;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN OTHERS THEN
      ROLLBACK TO Update_Sys_Parameters;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error)
                THEN
         FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

END Update_Sys_Parameters;


--------------------------------------------------------------------
-- PROCEDURE
--    Validate_Sys_Parameters
--
-- HISTORY
--    06/12/2000  mchang  Create.
--------------------------------------------------------------------
PROCEDURE Validate_Sys_Parameters(
   p_api_version        IN  NUMBER
  ,p_init_msg_list      IN  VARCHAR2  := FND_API.g_false
  ,p_validation_level   IN  NUMBER    := FND_API.g_valid_level_full

  ,x_return_status      OUT NOCOPY VARCHAR2
  ,x_msg_count          OUT NOCOPY NUMBER
  ,x_msg_data           OUT NOCOPY VARCHAR2

  ,p_sys_parameters_rec IN  sys_parameters_rec_type
)
IS

   l_api_version CONSTANT NUMBER       := 1.0;
   l_api_name    CONSTANT VARCHAR2(30) := 'Validate_Sys_Parameters';
   l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

   l_return_status VARCHAR2(1);

BEGIN

   ----------------------- initialize --------------------
   IF g_debug THEN
      OZF_Utility_PVT.debug_message(l_full_name||': start');
   END IF;

   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   IF NOT FND_API.compatible_api_call(
         l_api_version,
         p_api_version,
         l_api_name,
         g_pkg_name
   ) THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   x_return_status := FND_API.g_ret_sts_success;

   ---------------------- validate ------------------------
   IF g_debug THEN
      OZF_Utility_PVT.debug_message(l_full_name||': check items');
   END IF;

   IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
      Check_Sys_Parameters_Items(
         p_sys_parameters_rec   => p_sys_parameters_rec,
         p_validation_mode      => JTF_PLSQL_API.g_create,
         x_return_status        => l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      ELSIF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      END IF;
   END IF;

   IF g_debug THEN
      OZF_Utility_PVT.debug_message(l_full_name||': check record');
   END IF;

   IF p_validation_level >= JTF_PLSQL_API.g_valid_level_record THEN
      Check_Sys_Parameters_Record(
         p_sys_parameters_rec   => p_sys_parameters_rec,
         p_complete_rec         => NULL,
         x_return_status        => l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      ELSIF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      END IF;
   END IF;


   --Check the tolerances.
   Check_Batch_Tolerances(
      p_sys_parameters_rec =>  p_sys_parameters_rec,
      x_return_status      =>  l_return_status
    );
   IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
   ELSIF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
   END IF;


   -------------------- finish --------------------------
   FND_MSG_PUB.count_and_get(
         p_encoded => FND_API.g_false,
         p_count   => x_msg_count,
         p_data    => x_msg_data
   );

   IF g_debug THEN
      OZF_Utility_PVT.debug_message(l_full_name ||': end');
   END IF;

EXCEPTION

   WHEN FND_API.g_exc_error THEN
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN FND_API.g_exc_unexpected_error THEN
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN OTHERS THEN
      x_return_status := FND_API.g_ret_sts_unexp_error;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error)
                THEN
         FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

END Validate_Sys_Parameters;


---------------------------------------------------------------------
-- PROCEDURE
--    Check_Sys_Para_Req_Items
--
-- HISTORY
--    06/12/2000  mchang  Create.
---------------------------------------------------------------------
PROCEDURE Check_Sys_Para_Req_Items(
   p_sys_parameters_rec IN  sys_parameters_rec_type
  ,x_return_status      OUT NOCOPY VARCHAR2
)
IS
BEGIN

   x_return_status := FND_API.g_ret_sts_success;

END Check_Sys_Para_Req_Items;


---------------------------------------------------------------------
-- PROCEDURE
--    Check_Sys_Para_Uk_Items
--
-- HISTORY
--    06/12/2000  mchang  Create.
---------------------------------------------------------------------
PROCEDURE Check_Sys_Para_Uk_Items(
   p_sys_parameters_rec IN  sys_parameters_rec_type
  ,p_validation_mode    IN  VARCHAR2 := JTF_PLSQL_API.g_create
  ,x_return_status      OUT NOCOPY VARCHAR2
)
IS
   l_valid_flag  VARCHAR2(1);
BEGIN

   x_return_status := FND_API.g_ret_sts_success;

END Check_Sys_Para_Uk_Items;


---------------------------------------------------------------------
-- PROCEDURE
--    Check_Sys_Para_Fk_Items
--
-- HISTORY
--    06/12/2000  mchang  Create.
---------------------------------------------------------------------
PROCEDURE Check_Sys_Para_Fk_Items(
   p_sys_parameters_rec IN  sys_parameters_rec_type
  ,x_return_status      OUT NOCOPY VARCHAR2
)
IS
BEGIN

   x_return_status := FND_API.g_ret_sts_success;

   -- check other fk items

END Check_Sys_Para_Fk_Items;


---------------------------------------------------------------------
-- PROCEDURE
--    Check_Sys_Para_Lookup_Items
--
-- HISTORY
--    04/25/2000  mchang  Create.
---------------------------------------------------------------------
PROCEDURE Check_Sys_Para_Lookup_Items(
   p_sys_parameters_rec IN  sys_parameters_rec_type
  ,x_return_status      OUT NOCOPY VARCHAR2
)
IS
BEGIN

   x_return_status := FND_API.g_ret_sts_success;

   -- check other lookup codes

END Check_Sys_Para_Lookup_Items;


---------------------------------------------------------------------
-- PROCEDURE
--    Check_Sys_Para_Flag_Items
--
-- HISTORY
--    06/12/2000  mchang  Create.
--    08/31/2000  mchang  Updated: check flag column value (FND_API.G_TRUE/FALSE)
---------------------------------------------------------------------
PROCEDURE Check_Sys_Para_Flag_Items(
   p_sys_parameters_rec IN  sys_parameters_rec_type
  ,x_return_status      OUT NOCOPY VARCHAR2
)
IS
BEGIN

   x_return_status := FND_API.g_ret_sts_success;

   ----------------------- POST_TO_GL ------------------------
   IF p_sys_parameters_rec.post_to_gl <> FND_API.g_miss_char
      AND p_sys_parameters_rec.post_to_gl IS NOT NULL
   THEN
      IF p_sys_parameters_rec.post_to_gl <> FND_API.g_true
        AND p_sys_parameters_rec.post_to_gl <> FND_API.g_false
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_BAD_FLAG');
                                FND_MESSAGE.set_token('FLAG', 'POST_TO_GL');
            FND_MSG_PUB.add;
         END IF;

         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

   ----------------------- TRANSFER_TO_GL_IN ------------------------
   IF p_sys_parameters_rec.transfer_to_gl_in <> FND_API.g_miss_char
      AND p_sys_parameters_rec.transfer_to_gl_in IS NOT NULL
   THEN
      IF p_sys_parameters_rec.transfer_to_gl_in <> FND_API.g_true
        AND p_sys_parameters_rec.transfer_to_gl_in <> FND_API.g_false
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_BAD_FLAG');
                                FND_MESSAGE.set_token('FLAG', 'TRANSFER_TO_GL_IN');
            FND_MSG_PUB.add;
         END IF;

         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

   ----------------------- ROUNDING_LEVEL_FLAG ------------------------
   IF p_sys_parameters_rec.rounding_level_flag <> FND_API.g_miss_char
      AND p_sys_parameters_rec.rounding_level_flag IS NOT NULL
   THEN
      IF p_sys_parameters_rec.rounding_level_flag <> FND_API.g_true
        AND p_sys_parameters_rec.rounding_level_flag <> FND_API.g_false
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_BAD_FLAG');
                                FND_MESSAGE.set_token('FLAG', 'ROUNDING_LEVEL_FLAG');
            FND_MSG_PUB.add;
         END IF;

         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

   ----------------------- AUTOPAY_FLAG ------------------------
   IF p_sys_parameters_rec.autopay_flag <> FND_API.g_miss_char
      AND p_sys_parameters_rec.autopay_flag IS NOT NULL
   THEN
      IF p_sys_parameters_rec.autopay_flag <> FND_API.g_true
        AND p_sys_parameters_rec.autopay_flag <> FND_API.g_false
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_BAD_FLAG');
                                FND_MESSAGE.set_token('FLAG', 'AUTOPAY_FLAG');
            FND_MSG_PUB.add;
         END IF;

         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

   -- check other flags

END Check_Sys_Para_Flag_Items;


---------------------------------------------------------------------
-- PROCEDURE
--    Check_Sys_Parameters_Items
--
-- HISTORY
--    06/12/2000  mchang  Create.
---------------------------------------------------------------------
PROCEDURE Check_Sys_Parameters_Items(
   p_sys_parameters_rec IN  sys_parameters_rec_type
  ,p_validation_mode    IN  VARCHAR2 := JTF_PLSQL_API.g_create
  ,x_return_status      OUT NOCOPY VARCHAR2
)
IS

l_dummy NUMBER;

CURSOR  c_order_trx_type(cv_id NUMBER)
IS
   SELECT 1
   FROM oe_transaction_types_vl
   WHERE transaction_type_id = cv_id;

BEGIN

   Check_Sys_Para_Req_Items(
      p_sys_parameters_rec  => p_sys_parameters_rec
     ,x_return_status       => x_return_status
   );

   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   Check_Sys_Para_Uk_Items(
      p_sys_parameters_rec  => p_sys_parameters_rec
     ,p_validation_mode     => p_validation_mode
     ,x_return_status       => x_return_status
   );

   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   Check_Sys_Para_Fk_Items(
      p_sys_parameters_rec  => p_sys_parameters_rec
     ,x_return_status       => x_return_status
   );

   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   Check_Sys_Para_Lookup_Items(
      p_sys_parameters_rec  => p_sys_parameters_rec
     ,x_return_status       => x_return_status
   );

   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   Check_Sys_Para_Flag_Items(
      p_sys_parameters_rec  => p_sys_parameters_rec
     ,x_return_status       => x_return_status
   );

   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   --Check the validity of OM Transaction type
   IF p_sys_parameters_rec.order_type_id IS NOT NULL THEN
      OPEN c_order_trx_type(p_sys_parameters_rec.order_type_id);
      FETCH c_order_trx_type INTO l_dummy;
      CLOSE c_order_trx_type;

      IF l_dummy <> 1 THEN
          IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
            THEN
               FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_INVALID_OM_TRX_TYPE');
               FND_MSG_PUB.add;
           END IF;
           x_return_status := FND_API.g_ret_sts_error;
           RETURN;
      END IF;
   END IF;

END Check_Sys_Parameters_Items;



---------------------------------------------------------------------
-- PROCEDURE
--    Check_Sys_Parameters_Record
--
-- HISTORY
--    06/12/2000  mchang  Create.
---------------------------------------------------------------------
PROCEDURE Check_Sys_Parameters_Record(
   p_sys_parameters_rec IN  sys_parameters_rec_type
  ,p_complete_rec       IN  sys_parameters_rec_type := NULL
  ,p_mode               IN  VARCHAR2 := JTF_PLSQL_API.g_create
  ,x_return_status      OUT NOCOPY VARCHAR2
)
IS

BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   -- do other record level checkings

END Check_Sys_Parameters_Record;


---------------------------------------------------------------------
-- PROCEDURE
--    Init_Sys_Parameters_Rec
--
-- HISTORY
--    06/12/2000  mchang  Create.
---------------------------------------------------------------------
PROCEDURE Init_Sys_Parameters_Rec(
   x_sys_parameters_rec   OUT NOCOPY  sys_parameters_rec_type
)
IS
BEGIN


   RETURN;
END Init_Sys_Parameters_Rec;


---------------------------------------------------------------------
-- PROCEDURE
--    Complete_Sys_Parameters_Rec
--
-- HISTORY
--    06/12/2000  mchang  Create.
---------------------------------------------------------------------
PROCEDURE Complete_Sys_Parameters_Rec(
   p_sys_parameters_rec IN  sys_parameters_rec_type
  ,x_complete_rec       OUT NOCOPY sys_parameters_rec_type
)
IS

   CURSOR c_sys_para IS
   SELECT
      set_of_books_id,
      object_version_number,
      last_update_date,
      last_updated_by,
      creation_date,
      created_by,
      last_update_login,
      request_id,
      program_application_id,
      program_update_date,
      program_id,
      created_from,
      post_to_gl,
      transfer_to_gl_in,
      ap_payment_term_id,
      rounding_level_flag,
      gl_id_rounding,
      gl_id_ded_clearing,
      gl_id_ded_adj,
      gl_id_accr_promo_liab,
      gl_id_ded_adj_clearing,
      gl_rec_ded_account,
      gl_rec_clearing_account,
      gl_cost_adjustment_acct,
      gl_contra_liability_acct ,
      gl_pp_accrual_acct ,
      gl_date_type,
      days_due,
      claim_type_id,
      reason_code_id,
      autopay_claim_type_id,
      autopay_reason_code_id,
      autopay_flag,
      autopay_periodicity,
      autopay_periodicity_type,
      accounting_method_option,
      billback_trx_type_id,
      cm_trx_type_id,
      attribute_category,
      attribute1,
      attribute2,
      attribute3,
      attribute4,
      attribute5,
      attribute6,
      attribute7,
      attribute8,
      attribute9,
      attribute10,
      attribute11,
      attribute12,
      attribute13,
      attribute14,
      attribute15,
      org_id,
      batch_source_id,
      payables_source,
      default_owner_id,
      auto_assign_flag,
      exchange_rate_type,
      order_type_id,
      --11.5.10 enhancements.
      gl_acct_for_offinv_flag,
      --short_payment_reason_code_id,
      cb_trx_type_id,
          pos_write_off_threshold,
          neg_write_off_threshold,
          adj_rec_trx_id,
          wo_rec_trx_id,
          neg_wo_rec_trx_id,
          un_earned_pay_allow_to,
          un_earned_pay_thold_type,
          un_earned_pay_thold_amount,
          un_earned_pay_thold_flag,
          header_tolerance_calc_code,
          header_tolerance_operand,
          line_tolerance_calc_code,
          line_tolerance_operand,

          ship_debit_accrual_flag,
          ship_debit_calc_type,
          inventory_tracking_flag,
          end_cust_relation_flag,
          auto_tp_accrual_flag,
          gl_balancing_flex_value,
          prorate_earnings_flag,
          sales_credit_default_type,
          net_amt_for_mass_settle_flag,
          claim_tax_incl_flag,
          --For Rule Based Settment
         rule_based,
         approval_new_credit,
         approval_matched_credit,
         cust_name_match_type,
         credit_matching_thold_type,
         credit_tolerance_operand,
         --For Price Protection Parallel Approval
         automate_notification_days,
         --For SSD Default Adjustment Types
         ssd_inc_adj_type_id,
         ssd_dec_adj_type_id
    FROM  ozf_sys_parameters;


   l_sys_parameters_rec  c_sys_para%ROWTYPE;

BEGIN

   x_complete_rec := p_sys_parameters_rec;

   OPEN c_sys_para;
   FETCH c_sys_para INTO l_sys_parameters_rec;
   IF c_sys_para%NOTFOUND THEN
      CLOSE c_sys_para;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_API_RECORD_NOT_FOUND');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
   END IF;
   CLOSE c_sys_para;

  IF p_sys_parameters_rec.object_version_number = FND_API.G_MISS_NUM THEN
     x_complete_rec.object_version_number := NULL;
  END IF;
  IF p_sys_parameters_rec.object_version_number IS NULL THEN
     x_complete_rec.object_version_number := l_sys_parameters_rec.object_version_number;
  END IF;

  IF p_sys_parameters_rec.post_to_gl = FND_API.G_MISS_CHAR  THEN
  x_complete_rec.post_to_gl := NULL;

  END IF;
  IF p_sys_parameters_rec.post_to_gl IS NULL THEN
     x_complete_rec.post_to_gl := l_sys_parameters_rec.post_to_gl;
  END IF;
  IF p_sys_parameters_rec.transfer_to_gl_in = FND_API.G_MISS_CHAR THEN
  ozf_utility_pvt.debug_message('IN transfer_to_gl_in = FND_API.G_MISS_CHAR');
     --Commented as transfer_to_gl_in cannot be NULL and as this object is not displayed, the same value is retained.
     --x_complete_rec.transfer_to_gl_in := NULL;
     x_complete_rec.transfer_to_gl_in := l_sys_parameters_rec.transfer_to_gl_in;
  END IF;
  IF p_sys_parameters_rec.transfer_to_gl_in IS NULL THEN
     x_complete_rec.transfer_to_gl_in := l_sys_parameters_rec.transfer_to_gl_in;
  END IF;

  IF p_sys_parameters_rec.ap_payment_term_id = FND_API.G_MISS_NUM  THEN
     x_complete_rec.ap_payment_term_id := NULL;
  END IF;
  IF p_sys_parameters_rec.ap_payment_term_id IS NULL THEN
     x_complete_rec.ap_payment_term_id := l_sys_parameters_rec.ap_payment_term_id;
  END IF;

  IF p_sys_parameters_rec.rounding_level_flag = FND_API.G_MISS_CHAR THEN
     x_complete_rec.rounding_level_flag := NULL;
  END IF;
  IF p_sys_parameters_rec.rounding_level_flag IS NULL THEN
     x_complete_rec.rounding_level_flag := l_sys_parameters_rec.rounding_level_flag;
  END IF;

  IF p_sys_parameters_rec.gl_id_rounding = FND_API.G_MISS_NUM  THEN
     x_complete_rec.gl_id_rounding := NULL;
  END IF;
  IF p_sys_parameters_rec.gl_id_rounding IS NULL THEN
     x_complete_rec.gl_id_rounding := l_sys_parameters_rec.gl_id_rounding;
  END IF;

  IF p_sys_parameters_rec.gl_id_ded_clearing = FND_API.G_MISS_NUM THEN
     x_complete_rec.gl_id_ded_clearing := NULL;
  END IF;
  IF p_sys_parameters_rec.gl_id_ded_clearing IS NULL THEN
     x_complete_rec.gl_id_ded_clearing := l_sys_parameters_rec.gl_id_ded_clearing;
  END IF;

  IF p_sys_parameters_rec.gl_id_ded_adj = FND_API.G_MISS_NUM  THEN
     x_complete_rec.gl_id_ded_adj := NULL;
  END IF;
  IF p_sys_parameters_rec.gl_id_ded_adj IS NULL THEN
     x_complete_rec.gl_id_ded_adj := l_sys_parameters_rec.gl_id_ded_adj;
  END IF;

  IF p_sys_parameters_rec.gl_id_accr_promo_liab = FND_API.G_MISS_NUM  THEN
     x_complete_rec.gl_id_accr_promo_liab := NULL;
  END IF;
  IF p_sys_parameters_rec.gl_id_accr_promo_liab IS NULL THEN
     x_complete_rec.gl_id_accr_promo_liab := l_sys_parameters_rec.gl_id_accr_promo_liab;
  END IF;

  IF p_sys_parameters_rec.gl_id_ded_adj_clearing = FND_API.G_MISS_NUM  THEN
     x_complete_rec.gl_id_ded_adj_clearing := NULL;
  END IF;
  IF p_sys_parameters_rec.gl_id_ded_adj_clearing IS NULL THEN
     x_complete_rec.gl_id_ded_adj_clearing := l_sys_parameters_rec.gl_id_ded_adj_clearing;
  END IF;

  IF p_sys_parameters_rec.gl_rec_ded_account = FND_API.G_MISS_NUM  THEN
     x_complete_rec.gl_rec_ded_account := NULL;
  END IF;
  IF p_sys_parameters_rec.gl_rec_ded_account IS NULL THEN
     x_complete_rec.gl_rec_ded_account := l_sys_parameters_rec.gl_rec_ded_account;
  END IF;


  IF p_sys_parameters_rec.gl_rec_clearing_account = FND_API.G_MISS_NUM  THEN
     x_complete_rec.gl_rec_clearing_account := NULL;
  END IF;
  IF p_sys_parameters_rec.gl_rec_clearing_account IS NULL THEN
     x_complete_rec.gl_rec_clearing_account := l_sys_parameters_rec.gl_rec_clearing_account;
  END IF;

  IF p_sys_parameters_rec.gl_cost_adjustment_acct = FND_API.G_MISS_NUM  THEN
     x_complete_rec.gl_cost_adjustment_acct := NULL;
  END IF;
  IF p_sys_parameters_rec.gl_cost_adjustment_acct IS NULL THEN
     x_complete_rec.gl_cost_adjustment_acct := l_sys_parameters_rec.gl_cost_adjustment_acct;
  END IF;

  IF p_sys_parameters_rec.gl_contra_liability_acct = FND_API.G_MISS_NUM  THEN
     x_complete_rec.gl_contra_liability_acct := NULL;
  END IF;
  IF p_sys_parameters_rec.gl_contra_liability_acct IS NULL THEN
     x_complete_rec.gl_contra_liability_acct := l_sys_parameters_rec.gl_contra_liability_acct;
  END IF;

  IF p_sys_parameters_rec.gl_pp_accrual_acct = FND_API.G_MISS_NUM  THEN
     x_complete_rec.gl_pp_accrual_acct := NULL;
  END IF;
  IF p_sys_parameters_rec.gl_pp_accrual_acct IS NULL THEN
     x_complete_rec.gl_pp_accrual_acct := l_sys_parameters_rec.gl_pp_accrual_acct;
  END IF;


  IF p_sys_parameters_rec.gl_date_type = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.gl_date_type := NULL;
  END IF;
  IF p_sys_parameters_rec.gl_date_type IS NULL THEN
     x_complete_rec.gl_date_type := l_sys_parameters_rec.gl_date_type;
  END IF;


  IF p_sys_parameters_rec.days_due = FND_API.G_MISS_NUM  THEN
     x_complete_rec.days_due := NULL;
  END IF;
  IF p_sys_parameters_rec.days_due IS NULL THEN
     x_complete_rec.days_due := l_sys_parameters_rec.days_due;
  END IF;


  IF p_sys_parameters_rec.claim_type_id = FND_API.G_MISS_NUM  THEN
     x_complete_rec.claim_type_id := NULL;
  END IF;
  IF p_sys_parameters_rec.claim_type_id IS NULL THEN
     x_complete_rec.claim_type_id := l_sys_parameters_rec.claim_type_id;
  END IF;


  IF p_sys_parameters_rec.reason_code_id = FND_API.G_MISS_NUM  THEN
     x_complete_rec.reason_code_id := NULL;
  END IF;
  IF p_sys_parameters_rec.reason_code_id IS NULL THEN
     x_complete_rec.reason_code_id := l_sys_parameters_rec.reason_code_id;
  END IF;


  IF p_sys_parameters_rec.autopay_claim_type_id = FND_API.G_MISS_NUM  THEN
     x_complete_rec.autopay_claim_type_id := NULL;
  END IF;
  IF p_sys_parameters_rec.autopay_claim_type_id IS NULL THEN
     x_complete_rec.autopay_claim_type_id := l_sys_parameters_rec.autopay_claim_type_id;
  END IF;


  IF p_sys_parameters_rec.autopay_reason_code_id = FND_API.G_MISS_NUM  THEN
     x_complete_rec.autopay_reason_code_id := NULL;
  END IF;
  IF p_sys_parameters_rec.autopay_reason_code_id IS NULL THEN
     x_complete_rec.autopay_reason_code_id := l_sys_parameters_rec.autopay_reason_code_id;
  END IF;


  IF p_sys_parameters_rec.autopay_flag = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.autopay_flag := NULL;
  END IF;
  IF p_sys_parameters_rec.autopay_flag IS NULL THEN
     x_complete_rec.autopay_flag := l_sys_parameters_rec.autopay_flag;
  END IF;


  IF p_sys_parameters_rec.autopay_periodicity = FND_API.G_MISS_NUM  THEN
     x_complete_rec.autopay_periodicity := NULL;
  END IF;
  IF p_sys_parameters_rec.autopay_periodicity IS NULL THEN
     x_complete_rec.autopay_periodicity := l_sys_parameters_rec.autopay_periodicity;
  END IF;


  IF p_sys_parameters_rec.autopay_periodicity_type = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.autopay_periodicity_type := NULL;
  END IF;
  IF p_sys_parameters_rec.autopay_periodicity_type IS NULL THEN
     x_complete_rec.autopay_periodicity_type := l_sys_parameters_rec.autopay_periodicity_type;
  END IF;


  IF p_sys_parameters_rec.accounting_method_option = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.accounting_method_option := NULL;
  END IF;
  IF p_sys_parameters_rec.accounting_method_option IS NULL THEN
     x_complete_rec.accounting_method_option := l_sys_parameters_rec.accounting_method_option;
  END IF;

  IF p_sys_parameters_rec.billback_trx_type_id = FND_API.G_MISS_NUM  THEN
     x_complete_rec.billback_trx_type_id := NULL;
  END IF;
  IF p_sys_parameters_rec.billback_trx_type_id IS NULL THEN
     x_complete_rec.billback_trx_type_id := l_sys_parameters_rec.billback_trx_type_id;
  END IF;

  IF p_sys_parameters_rec.cm_trx_type_id = FND_API.G_MISS_NUM  THEN
     x_complete_rec.cm_trx_type_id := NULL;
  END IF;
  IF p_sys_parameters_rec.cm_trx_type_id IS NULL THEN
     x_complete_rec.cm_trx_type_id := l_sys_parameters_rec.cm_trx_type_id;
  END IF;

  IF p_sys_parameters_rec.attribute_category = FND_API.G_MISS_CHAR THEN
     x_complete_rec.attribute_category := NULL;
  END IF;
  IF p_sys_parameters_rec.attribute_category IS NULL THEN
     x_complete_rec.attribute_category := l_sys_parameters_rec.attribute_category;
  END IF;

  IF p_sys_parameters_rec.attribute1 = FND_API.G_MISS_CHAR THEN
     x_complete_rec.attribute1 := NULL;
  END IF;
  IF p_sys_parameters_rec.attribute1 IS NULL THEN
     x_complete_rec.attribute1 := l_sys_parameters_rec.attribute1;
  END IF;

  IF p_sys_parameters_rec.attribute2 = FND_API.G_MISS_CHAR THEN
     x_complete_rec.attribute2 := NULL;
  END IF;
  IF p_sys_parameters_rec.attribute2 IS NULL THEN
     x_complete_rec.attribute2 := l_sys_parameters_rec.attribute2;
  END IF;

  IF p_sys_parameters_rec.attribute3 = FND_API.G_MISS_CHAR THEN
     x_complete_rec.attribute3 := NULL;
  END IF;
  IF p_sys_parameters_rec.attribute3 IS NULL THEN
     x_complete_rec.attribute3 := l_sys_parameters_rec.attribute3;
  END IF;

  IF p_sys_parameters_rec.attribute4 = FND_API.G_MISS_CHAR THEN
     x_complete_rec.attribute4 := NULL;
  END IF;
  IF p_sys_parameters_rec.attribute4 IS NULL THEN
     x_complete_rec.attribute4 := l_sys_parameters_rec.attribute4;
  END IF;

  IF p_sys_parameters_rec.attribute5 = FND_API.G_MISS_CHAR THEN
     x_complete_rec.attribute5 := NULL;
  END IF;
  IF p_sys_parameters_rec.attribute5 IS NULL THEN
     x_complete_rec.attribute5 := l_sys_parameters_rec.attribute5;
  END IF;

  IF p_sys_parameters_rec.attribute6 = FND_API.G_MISS_CHAR THEN
     x_complete_rec.attribute6 := NULL;
  END IF;
  IF p_sys_parameters_rec.attribute6 IS NULL THEN
     x_complete_rec.attribute6 := l_sys_parameters_rec.attribute6;
  END IF;

  IF p_sys_parameters_rec.attribute7 = FND_API.G_MISS_CHAR THEN
     x_complete_rec.attribute7 := NULL;
  END IF;
  IF p_sys_parameters_rec.attribute7 IS NULL THEN
     x_complete_rec.attribute7 := l_sys_parameters_rec.attribute7;
  END IF;

  IF p_sys_parameters_rec.attribute8 = FND_API.G_MISS_CHAR THEN
     x_complete_rec.attribute8 := NULL;
  END IF;
  IF p_sys_parameters_rec.attribute8 IS NULL THEN
     x_complete_rec.attribute8 := l_sys_parameters_rec.attribute8;
  END IF;

  IF p_sys_parameters_rec.attribute9 = FND_API.G_MISS_CHAR THEN
     x_complete_rec.attribute9 := NULL;
  END IF;
  IF p_sys_parameters_rec.attribute9 IS NULL THEN
     x_complete_rec.attribute9 := l_sys_parameters_rec.attribute9;
  END IF;

  IF p_sys_parameters_rec.attribute10 = FND_API.G_MISS_CHAR THEN
     x_complete_rec.attribute10 := NULL;
  END IF;
  IF p_sys_parameters_rec.attribute10 IS NULL THEN
     x_complete_rec.attribute10 := l_sys_parameters_rec.attribute10;
  END IF;

  IF p_sys_parameters_rec.attribute11 = FND_API.G_MISS_CHAR THEN
     x_complete_rec.attribute11 := NULL;
  END IF;
  IF p_sys_parameters_rec.attribute11 IS NULL THEN
     x_complete_rec.attribute11 := l_sys_parameters_rec.attribute11;
  END IF;

  IF p_sys_parameters_rec.attribute12 = FND_API.G_MISS_CHAR THEN
     x_complete_rec.attribute12 := NULL;
  END IF;
  IF p_sys_parameters_rec.attribute12 IS NULL THEN
     x_complete_rec.attribute12 := l_sys_parameters_rec.attribute12;
  END IF;

  IF p_sys_parameters_rec.attribute13 = FND_API.G_MISS_CHAR THEN
     x_complete_rec.attribute13 := NULL;
  END IF;
  IF p_sys_parameters_rec.attribute13 IS NULL THEN
     x_complete_rec.attribute13 := l_sys_parameters_rec.attribute13;
  END IF;

  IF p_sys_parameters_rec.attribute14 = FND_API.G_MISS_CHAR THEN
     x_complete_rec.attribute14 := NULL;
  END IF;
  IF p_sys_parameters_rec.attribute14 IS NULL THEN
     x_complete_rec.attribute14 := l_sys_parameters_rec.attribute14;
  END IF;

  IF p_sys_parameters_rec.attribute15 = FND_API.G_MISS_CHAR THEN
     x_complete_rec.attribute15 := NULL;
  END IF;
  IF p_sys_parameters_rec.attribute15 IS NULL THEN
     x_complete_rec.attribute15 := l_sys_parameters_rec.attribute15;
  END IF;

  IF p_sys_parameters_rec.org_id = FND_API.G_MISS_NUM THEN
     x_complete_rec.org_id := NULL;
  END IF;
  IF p_sys_parameters_rec.org_id IS NULL THEN
     x_complete_rec.org_id := l_sys_parameters_rec.org_id;
  END IF;

  IF p_sys_parameters_rec.batch_source_id = FND_API.G_MISS_NUM THEN
     x_complete_rec.batch_source_id := NULL;
  END IF;
  IF p_sys_parameters_rec.batch_source_id IS NULL THEN
     x_complete_rec.batch_source_id := l_sys_parameters_rec.batch_source_id;
  END IF;

  IF p_sys_parameters_rec.payables_source = FND_API.G_MISS_CHAR THEN
     x_complete_rec.payables_source := NULL;
  END IF;
  IF p_sys_parameters_rec.payables_source IS NULL THEN
     x_complete_rec.payables_source := l_sys_parameters_rec.payables_source;
  END IF;

  IF p_sys_parameters_rec.default_owner_id = FND_API.G_MISS_NUM THEN
     x_complete_rec.default_owner_id := NULL;
  END IF;
  IF p_sys_parameters_rec.default_owner_id IS NULL THEN
     x_complete_rec.default_owner_id := l_sys_parameters_rec.default_owner_id;
  END IF;

  IF p_sys_parameters_rec.auto_assign_flag = FND_API.G_MISS_CHAR THEN
     x_complete_rec.auto_assign_flag := NULL;
  END IF;
  IF p_sys_parameters_rec.auto_assign_flag IS NULL THEN
     x_complete_rec.auto_assign_flag := l_sys_parameters_rec.auto_assign_flag;
  END IF;

  IF p_sys_parameters_rec.exchange_rate_type = FND_API.G_MISS_CHAR THEN
     x_complete_rec.exchange_rate_type := NULL;
  END IF;
  IF p_sys_parameters_rec.exchange_rate_type IS NULL THEN
     x_complete_rec.exchange_rate_type := l_sys_parameters_rec.exchange_rate_type;
  END IF;

   IF p_sys_parameters_rec.order_type_id = FND_API.G_MISS_NUM THEN
     x_complete_rec.order_type_id := NULL;
  END IF;
   IF p_sys_parameters_rec.order_type_id IS NULL THEN
     x_complete_rec.order_type_id := l_sys_parameters_rec.order_type_id;
  END IF;

    --11.5.10 enhancements
  IF p_sys_parameters_rec.gl_acct_for_offinv_flag = FND_API.G_MISS_CHAR THEN
     x_complete_rec.gl_acct_for_offinv_flag := NULL;
  END IF;
   IF p_sys_parameters_rec.gl_acct_for_offinv_flag IS NULL THEN
     x_complete_rec.gl_acct_for_offinv_flag := l_sys_parameters_rec.gl_acct_for_offinv_flag;
  END IF;

  /*
  IF p_sys_parameters_rec.short_payment_reason_code_id = FND_API.G_MISS_NUM THEN
     x_complete_rec.short_payment_reason_code_id := NULL;
  END IF;
   IF p_sys_parameters_rec.short_payment_reason_code_id IS NULL THEN
     x_complete_rec.short_payment_reason_code_id := l_sys_parameters_rec.short_payment_reason_code_id;
  END IF;
  */

  IF p_sys_parameters_rec.cb_trx_type_id = FND_API.G_MISS_NUM THEN
     x_complete_rec.cb_trx_type_id := NULL;
  END IF;
   IF p_sys_parameters_rec.cb_trx_type_id IS NULL THEN
     x_complete_rec.cb_trx_type_id := l_sys_parameters_rec.cb_trx_type_id;
  END IF;

  IF p_sys_parameters_rec.pos_write_off_threshold = FND_API.G_MISS_NUM THEN
     x_complete_rec.pos_write_off_threshold := NULL;
  END IF;
   IF p_sys_parameters_rec.pos_write_off_threshold IS NULL THEN
     x_complete_rec.pos_write_off_threshold := l_sys_parameters_rec.pos_write_off_threshold;
  END IF;

  IF p_sys_parameters_rec.neg_write_off_threshold = FND_API.G_MISS_NUM THEN
     x_complete_rec.neg_write_off_threshold := NULL;
  END IF;
   IF p_sys_parameters_rec.neg_write_off_threshold IS NULL THEN
     x_complete_rec.neg_write_off_threshold := l_sys_parameters_rec.neg_write_off_threshold;
  END IF;

  IF p_sys_parameters_rec.adj_rec_trx_id = FND_API.G_MISS_NUM THEN
     x_complete_rec.adj_rec_trx_id := NULL;
  END IF;
   IF p_sys_parameters_rec.adj_rec_trx_id IS NULL THEN
     x_complete_rec.adj_rec_trx_id := l_sys_parameters_rec.adj_rec_trx_id;
  END IF;

  IF p_sys_parameters_rec.wo_rec_trx_id = FND_API.G_MISS_NUM THEN
     x_complete_rec.wo_rec_trx_id := NULL;
  END IF;
   IF p_sys_parameters_rec.wo_rec_trx_id IS NULL THEN
     x_complete_rec.wo_rec_trx_id := l_sys_parameters_rec.wo_rec_trx_id;
  END IF;

  IF p_sys_parameters_rec.neg_wo_rec_trx_id = FND_API.G_MISS_NUM THEN
     x_complete_rec.neg_wo_rec_trx_id := NULL;
  END IF;
   IF p_sys_parameters_rec.neg_wo_rec_trx_id IS NULL THEN
     x_complete_rec.neg_wo_rec_trx_id := l_sys_parameters_rec.neg_wo_rec_trx_id;
  END IF;

  IF p_sys_parameters_rec.un_earned_pay_allow_to = FND_API.G_MISS_CHAR THEN
     x_complete_rec.un_earned_pay_allow_to := NULL;
  END IF;
   IF p_sys_parameters_rec.un_earned_pay_allow_to IS NULL THEN
     x_complete_rec.un_earned_pay_allow_to := l_sys_parameters_rec.un_earned_pay_allow_to;
  END IF;

  IF p_sys_parameters_rec.un_earned_pay_thold_type = FND_API.G_MISS_CHAR THEN
     x_complete_rec.un_earned_pay_thold_type := NULL;
  END IF;
   IF p_sys_parameters_rec.un_earned_pay_thold_type IS NULL THEN
     x_complete_rec.un_earned_pay_thold_type := l_sys_parameters_rec.un_earned_pay_thold_type;
  END IF;

  IF p_sys_parameters_rec.un_earned_pay_threshold = FND_API.G_MISS_NUM THEN
     x_complete_rec.un_earned_pay_threshold := NULL;
  END IF;
   IF p_sys_parameters_rec.un_earned_pay_threshold IS NULL THEN
     x_complete_rec.un_earned_pay_threshold := l_sys_parameters_rec.un_earned_pay_thold_amount;
  END IF;

  IF p_sys_parameters_rec.un_earned_pay_thold_flag = FND_API.G_MISS_CHAR THEN
     x_complete_rec.un_earned_pay_thold_flag := NULL;
  END IF;
   IF p_sys_parameters_rec.un_earned_pay_thold_flag IS NULL THEN
     x_complete_rec.un_earned_pay_thold_flag := l_sys_parameters_rec.un_earned_pay_thold_flag;
  END IF;

  IF p_sys_parameters_rec.header_tolerance_calc_code = FND_API.G_MISS_CHAR THEN
     x_complete_rec.header_tolerance_calc_code := NULL;
  END IF;
   IF p_sys_parameters_rec.header_tolerance_calc_code IS NULL THEN
     x_complete_rec.header_tolerance_calc_code := l_sys_parameters_rec.header_tolerance_calc_code;
  END IF;

  IF p_sys_parameters_rec.header_tolerance_operand = FND_API.G_MISS_NUM THEN
     x_complete_rec.header_tolerance_operand := NULL;
  END IF;
   IF p_sys_parameters_rec.header_tolerance_operand IS NULL THEN
     x_complete_rec.header_tolerance_operand := l_sys_parameters_rec.header_tolerance_operand;
  END IF;

  IF p_sys_parameters_rec.line_tolerance_calc_code = FND_API.G_MISS_CHAR THEN
     x_complete_rec.line_tolerance_calc_code := NULL;
  END IF;
   IF p_sys_parameters_rec.line_tolerance_calc_code IS NULL THEN
     x_complete_rec.line_tolerance_calc_code := l_sys_parameters_rec.line_tolerance_calc_code;
  END IF;

  IF p_sys_parameters_rec.line_tolerance_operand = FND_API.G_MISS_NUM THEN
     x_complete_rec.line_tolerance_operand := NULL;
  END IF;
   IF p_sys_parameters_rec.line_tolerance_operand IS NULL THEN
     x_complete_rec.line_tolerance_operand := l_sys_parameters_rec.line_tolerance_operand;
  END IF;

  IF p_sys_parameters_rec.ship_debit_accrual_flag = FND_API.G_MISS_CHAR THEN
     x_complete_rec.ship_debit_accrual_flag := NULL;
  END IF;
   IF p_sys_parameters_rec.ship_debit_accrual_flag IS NULL THEN
     x_complete_rec.ship_debit_accrual_flag := l_sys_parameters_rec.ship_debit_accrual_flag;
  END IF;

  IF p_sys_parameters_rec.ship_debit_calc_type = FND_API.G_MISS_CHAR THEN
     x_complete_rec.ship_debit_calc_type := NULL;
  END IF;
   IF p_sys_parameters_rec.ship_debit_calc_type IS NULL THEN
     x_complete_rec.ship_debit_calc_type := l_sys_parameters_rec.ship_debit_calc_type;
  END IF;

  IF p_sys_parameters_rec.inventory_tracking_flag = FND_API.G_MISS_CHAR THEN
     x_complete_rec.inventory_tracking_flag := NULL;
  END IF;
   IF p_sys_parameters_rec.inventory_tracking_flag IS NULL THEN
     x_complete_rec.inventory_tracking_flag := l_sys_parameters_rec.inventory_tracking_flag;
  END IF;

  IF p_sys_parameters_rec.end_cust_relation_flag = FND_API.G_MISS_CHAR THEN
     x_complete_rec.end_cust_relation_flag := NULL;
  END IF;
   IF p_sys_parameters_rec.end_cust_relation_flag IS NULL THEN
     x_complete_rec.end_cust_relation_flag := l_sys_parameters_rec.end_cust_relation_flag;
  END IF;

  IF p_sys_parameters_rec.auto_tp_accrual_flag = FND_API.G_MISS_CHAR THEN
     x_complete_rec.auto_tp_accrual_flag := NULL;
  END IF;
   IF p_sys_parameters_rec.auto_tp_accrual_flag IS NULL THEN
     x_complete_rec.auto_tp_accrual_flag := l_sys_parameters_rec.auto_tp_accrual_flag;
  END IF;

  IF p_sys_parameters_rec.gl_balancing_flex_value = FND_API.G_MISS_CHAR THEN
     x_complete_rec.gl_balancing_flex_value := NULL;
  END IF;
   IF p_sys_parameters_rec.gl_balancing_flex_value IS NULL THEN
     x_complete_rec.gl_balancing_flex_value := l_sys_parameters_rec.gl_balancing_flex_value;
  END IF;

  IF p_sys_parameters_rec.prorate_earnings_flag = FND_API.G_MISS_CHAR THEN
     x_complete_rec.prorate_earnings_flag := NULL;
  END IF;
  IF p_sys_parameters_rec.prorate_earnings_flag IS NULL THEN
     x_complete_rec.prorate_earnings_flag := l_sys_parameters_rec.prorate_earnings_flag;
  END IF;

  IF p_sys_parameters_rec.sales_credit_default_type = FND_API.G_MISS_CHAR THEN
     x_complete_rec.sales_credit_default_type := NULL;
  END IF;
  IF p_sys_parameters_rec.sales_credit_default_type IS NULL THEN
     x_complete_rec.sales_credit_default_type := l_sys_parameters_rec.sales_credit_default_type;
  END IF;

  IF p_sys_parameters_rec.net_amt_for_mass_settle_flag = FND_API.G_MISS_CHAR THEN
     x_complete_rec.net_amt_for_mass_settle_flag := NULL;
  END IF;
  IF p_sys_parameters_rec.net_amt_for_mass_settle_flag IS NULL THEN
     x_complete_rec.net_amt_for_mass_settle_flag := l_sys_parameters_rec.net_amt_for_mass_settle_flag;
  END IF;

  IF p_sys_parameters_rec.claim_tax_incl_flag = FND_API.G_MISS_CHAR THEN
     x_complete_rec.claim_tax_incl_flag := NULL;
  END IF;
  IF p_sys_parameters_rec.claim_tax_incl_flag IS NULL THEN
     x_complete_rec.claim_tax_incl_flag := l_sys_parameters_rec.claim_tax_incl_flag;
  END IF;
  --For Rule Based Settlement
  IF p_sys_parameters_rec.rule_based = FND_API.G_MISS_CHAR THEN
     x_complete_rec.rule_based := NULL;
  END IF;
   IF p_sys_parameters_rec.rule_based IS NULL THEN
     x_complete_rec.rule_based := l_sys_parameters_rec.rule_based;
  END IF;
  IF p_sys_parameters_rec.approval_new_credit = FND_API.G_MISS_CHAR THEN
     x_complete_rec.approval_new_credit := NULL;
  END IF;
   IF p_sys_parameters_rec.approval_new_credit IS NULL THEN
     x_complete_rec.approval_new_credit := l_sys_parameters_rec.approval_new_credit;
  END IF;
  IF p_sys_parameters_rec.approval_matched_credit = FND_API.G_MISS_CHAR THEN
     x_complete_rec.approval_matched_credit := NULL;
  END IF;
   IF p_sys_parameters_rec.approval_matched_credit IS NULL THEN
     x_complete_rec.approval_matched_credit := l_sys_parameters_rec.approval_matched_credit;
  END IF;
  IF p_sys_parameters_rec.cust_name_match_type = FND_API.G_MISS_CHAR THEN
     x_complete_rec.cust_name_match_type := NULL;
  END IF;
   IF p_sys_parameters_rec.cust_name_match_type IS NULL THEN
     x_complete_rec.cust_name_match_type := l_sys_parameters_rec.cust_name_match_type;
  END IF;
  IF p_sys_parameters_rec.credit_matching_thold_type = FND_API.G_MISS_CHAR THEN
     x_complete_rec.credit_matching_thold_type := NULL;
  END IF;
   IF p_sys_parameters_rec.credit_matching_thold_type IS NULL THEN
     x_complete_rec.credit_matching_thold_type := l_sys_parameters_rec.credit_matching_thold_type;
  END IF;

  IF p_sys_parameters_rec.credit_tolerance_operand = FND_API.G_MISS_NUM THEN
     x_complete_rec.credit_tolerance_operand := NULL;
  END IF;
   IF p_sys_parameters_rec.credit_tolerance_operand IS NULL THEN
     x_complete_rec.credit_tolerance_operand := l_sys_parameters_rec.credit_tolerance_operand;
  END IF;

  -- For Price Protection Parallel Approval
  IF p_sys_parameters_rec.automate_notification_days = FND_API.G_MISS_NUM THEN
     x_complete_rec.automate_notification_days := NULL;
  END IF;
  IF p_sys_parameters_rec.automate_notification_days IS NULL THEN
     x_complete_rec.automate_notification_days := l_sys_parameters_rec.automate_notification_days;
  END IF;

  -- For SSD Default Adjustment Types
  IF p_sys_parameters_rec.ssd_inc_adj_type_id = FND_API.G_MISS_NUM THEN
     x_complete_rec.ssd_inc_adj_type_id := NULL;
  END IF;
  IF p_sys_parameters_rec.ssd_inc_adj_type_id IS NULL THEN
     x_complete_rec.ssd_inc_adj_type_id := l_sys_parameters_rec.ssd_inc_adj_type_id;
  END IF;

  IF p_sys_parameters_rec.ssd_dec_adj_type_id = FND_API.G_MISS_NUM THEN
     x_complete_rec.ssd_dec_adj_type_id := NULL;
  END IF;
  IF p_sys_parameters_rec.ssd_dec_adj_type_id IS NULL THEN
     x_complete_rec.ssd_dec_adj_type_id := l_sys_parameters_rec.ssd_dec_adj_type_id;
  END IF;


END Complete_Sys_Parameters_Rec;

END OZF_Sys_Parameters_PVT;

/
