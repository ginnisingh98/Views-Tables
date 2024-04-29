--------------------------------------------------------
--  DDL for Package Body OZF_FUNDS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_FUNDS_PUB" AS
/* $Header: OZFPFUNB.pls 120.7.12010000.3 2010/03/03 08:47:07 kdass ship $ */

g_pkg_name    CONSTANT VARCHAR2(30) := 'OZF_FUNDS_PUB';
G_DEBUG BOOLEAN := FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_high);

---------------------------------------------------------------------
-- PROCEDURE
--    validate_fund_items
--
-- PURPOSE
--    Validate fund items.
--
-- PARAMETERS
--    p_fund_rec: fund record to be validated
--    p_mode: CREATE or UPDATE
--    x_return_status: return status
--
-- HISTORY
--    06/29/2005  kdass Created
---------------------------------------------------------------------
PROCEDURE validate_fund_items (
   p_fund_rec           IN OUT NOCOPY   fund_rec_type
  ,p_mode               IN              VARCHAR2
  ,x_return_status      OUT NOCOPY      VARCHAR2
  )
IS
l_api_name          VARCHAR(30) := 'validate_fund_items';
l_fund_exists       NUMBER := NULL;
l_cust_setup_exists NUMBER := NULL;
l_par_fund_exists   NUMBER := NULL;
l_cat_exists        NUMBER := NULL;
l_bus_unit_exists   NUMBER := NULL;
l_thrh_exists       NUMBER := NULL;
l_task_exists       NUMBER := NULL;
l_org_exists        NUMBER := NULL;
l_ledger_exists     NUMBER := NULL;

CURSOR c_fund_exists (p_fund_id IN NUMBER) IS
   SELECT 1
   FROM  ozf_funds_all_b
   WHERE fund_type <> 'QUOTA'
     AND fund_id = p_fund_id;

CURSOR c_fund_num_exists (p_fund_number IN VARCHAR2) IS
   SELECT fund_id
   FROM  ozf_funds_all_b
   WHERE fund_type <> 'QUOTA'
     AND fund_number = p_fund_number;

CURSOR c_cust_setup (p_fund_type IN VARCHAR2) IS
   SELECT min(custom_setup_id)
   FROM  ams_custom_setups_vl
   WHERE object_type = 'FUND'
   AND application_id = 682
   AND activity_type_code = p_fund_type;

CURSOR c_cust_setup_exists (p_fund_type IN VARCHAR2, p_cust_setup_id IN NUMBER) IS
   SELECT 1
   FROM  ams_custom_setups_vl
   WHERE object_type = 'FUND'
   AND application_id = 682
   AND activity_type_code = p_fund_type
   AND custom_setup_id = p_cust_setup_id;

CURSOR c_par_fund_id_exists (p_par_fund_id IN NUMBER, p_par_fund_name IN VARCHAR) IS
   SELECT 1
   FROM  ozf_funds_all_vl
   WHERE fund_type <> 'QUOTA'
     AND fund_id = p_par_fund_id
     AND short_name = p_par_fund_name;

CURSOR c_par_fund_exists (p_par_fund_id IN NUMBER) IS
   SELECT 1
   FROM  ozf_funds_all_b
   WHERE fund_type <> 'QUOTA'
     AND fund_id = p_par_fund_id;

CURSOR c_par_fund_name_exists (p_par_fund_name IN VARCHAR2) IS
   SELECT fund_id
   FROM  ozf_funds_all_vl
   WHERE fund_type <> 'QUOTA'
     AND short_name = p_par_fund_name;

CURSOR c_cat_exists (p_category_id IN NUMBER, p_category_name IN VARCHAR2) IS
   SELECT 1
   FROM  ams_categories_vl
   WHERE arc_category_created_for = 'FUND'
     AND enabled_flag = 'Y'
     AND category_name = p_category_name
     AND category_id = p_category_id;

CURSOR c_cat_id_exists (p_category_id IN NUMBER) IS
   SELECT 1
   FROM  ams_categories_vl
   WHERE arc_category_created_for = 'FUND'
     AND enabled_flag = 'Y'
     AND category_id = p_category_id;

CURSOR c_cat_name_exists (p_category_name IN VARCHAR2) IS
   SELECT category_id
   FROM  ams_categories_vl
   WHERE arc_category_created_for = 'FUND'
     AND enabled_flag = 'Y'
     AND category_name = p_category_name;

CURSOR c_thrh_exists (p_threshold_id IN NUMBER, p_threshold_name IN VARCHAR2) IS
   SELECT 1
   FROM  ozf_thresholds_vl
   WHERE threshold_type = 'BUDGET'
     AND end_date_active > sysdate
     AND name = p_threshold_name
     AND threshold_id = p_threshold_id;

CURSOR c_thrh_id_exists (p_threshold_id IN NUMBER) IS
   SELECT 1
   FROM  ozf_thresholds_vl
   WHERE threshold_type = 'BUDGET'
     AND end_date_active > sysdate
     AND threshold_id = p_threshold_id;

CURSOR c_thrh_name_exists (p_threshold_name IN VARCHAR2) IS
   SELECT threshold_id
   FROM  ozf_thresholds_vl
   WHERE threshold_type = 'BUDGET'
     AND end_date_active > sysdate
     AND name = p_threshold_name;

CURSOR c_task_exists (p_task_id IN NUMBER, p_task_name IN VARCHAR2) IS
   SELECT 1
   FROM  ams_media_vl
   WHERE media_type_code = 'DEAL'
     AND media_name = p_task_name
     AND media_id = p_task_id;

CURSOR c_task_id_exists (p_task_id IN NUMBER) IS
   SELECT 1
   FROM  ams_media_vl
   WHERE media_type_code = 'DEAL'
     AND media_id = p_task_id;

CURSOR c_task_name_exists (p_task_name IN VARCHAR2) IS
   SELECT media_id
   FROM  ams_media_vl
   WHERE media_type_code = 'DEAL'
     AND media_name = p_task_name;

CURSOR c_bus_unit_exists (p_bus_id IN NUMBER, p_bus_name IN VARCHAR, p_org_id IN NUMBER) IS
   SELECT 1
   FROM hr_all_organization_units
   WHERE  business_group_id
          IN (SELECT business_group_id
              FROM  hr_all_organization_units
              WHERE organization_id = p_org_id
              AND NVL(date_from, SYSDATE) <= SYSDATE
              AND NVL(date_to, SYSDATE) >= SYSDATE)
      AND type = 'BU' AND NVL(date_from, SYSDATE) <= SYSDATE
      AND NVL(date_to, SYSDATE) >= SYSDATE
      AND name = p_bus_name
      AND organization_id = p_bus_id;

CURSOR c_bus_id_exists (p_bus_id IN NUMBER, p_org_id IN NUMBER) IS
   SELECT 1
   FROM hr_all_organization_units
   WHERE  business_group_id
          IN (SELECT business_group_id
              FROM  hr_all_organization_units
              WHERE organization_id = p_org_id
              AND NVL(date_from, SYSDATE) <= SYSDATE
              AND NVL(date_to, SYSDATE) >= SYSDATE)
      AND type = 'BU' AND NVL(date_from, SYSDATE) <= SYSDATE
      AND NVL(date_to, SYSDATE) >= SYSDATE
      AND organization_id = p_bus_id;

CURSOR c_bus_name_exists (p_bus_name IN VARCHAR2, p_org_id IN NUMBER) IS
   SELECT organization_id
   FROM hr_all_organization_units
   WHERE  business_group_id
          IN (SELECT business_group_id
              FROM  hr_all_organization_units
              WHERE organization_id = p_org_id
              AND NVL(date_from, SYSDATE) <= SYSDATE
              AND NVL(date_to, SYSDATE) >= SYSDATE)
      AND type = 'BU' AND NVL(date_from, SYSDATE) <= SYSDATE
      AND NVL(date_to, SYSDATE) >= SYSDATE
      AND name = p_bus_name;

CURSOR c_user_status_id (p_status_code IN VARCHAR2) IS
   SELECT user_status_id
   FROM ams_user_statuses_vl
   WHERE system_status_type = 'OZF_FUND_STATUS'
   AND system_status_code = p_status_code
   AND enabled_flag ='Y';

CURSOR c_ledger_exists (p_ledger_id IN NUMBER, p_ledger_name IN VARCHAR2) IS
   SELECT 1
   FROM  gl_ledgers_public_v
   WHERE ledger_id = p_ledger_id
     AND name = p_ledger_name;

CURSOR c_ledger_id_exists (p_ledger_id IN NUMBER) IS
   SELECT 1
   FROM  gl_ledgers_public_v
   WHERE ledger_id = p_ledger_id;

CURSOR c_ledger_name_exists (p_ledger_name IN VARCHAR2) IS
   SELECT ledger_id
   FROM  gl_ledgers_public_v
   WHERE name = p_ledger_name;

BEGIN

   IF p_fund_rec.fund_type <> fnd_api.g_miss_char AND p_fund_rec.fund_type IS NOT NULL
    AND p_fund_rec.fund_type = 'QUOTA' THEN
      RETURN;
   END IF;

   IF p_mode = 'CREATE' THEN
      p_fund_rec.fund_id := NULL;
   ELSE
      --if both fund id and fund number are null, then raise exception
      IF (p_fund_rec.fund_id = fnd_api.g_miss_num OR p_fund_rec.fund_id IS NULL) AND
         (p_fund_rec.fund_number = fnd_api.g_miss_char OR p_fund_rec.fund_number IS NULL) THEN

         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
            fnd_message.set_name('OZF', 'OZF_NO_FUND_ID_NUM');
            fnd_msg_pub.add;
         END IF;
         x_return_status := fnd_api.g_ret_sts_error;
         RETURN;

      ELSE
         --if fund id is not null
         IF p_fund_rec.fund_id <> fnd_api.g_miss_num AND p_fund_rec.fund_id IS NOT NULL THEN

            --check if the input fund_id is valid
            OPEN c_fund_exists (p_fund_rec.fund_id);
            FETCH c_fund_exists INTO l_fund_exists;
            CLOSE c_fund_exists;

            IF l_fund_exists IS NULL THEN
               IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
                  fnd_message.set_name('OZF', 'OZF_INVALID_FUND_ID');
                  fnd_msg_pub.add;
               END IF;
               x_return_status := fnd_api.g_ret_sts_error;
               RETURN;
            END IF;

         --if fund number is not null
         ELSE
            --check if the input fund_number is valid
            OPEN c_fund_num_exists (p_fund_rec.fund_number);
            FETCH c_fund_num_exists INTO p_fund_rec.fund_id;
            CLOSE c_fund_num_exists;

            IF p_fund_rec.fund_id IS NULL THEN
               IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
                  fnd_message.set_name('OZF', 'OZF_INVALID_FUND_NUM');
                  fnd_msg_pub.add;
               END IF;
               x_return_status := fnd_api.g_ret_sts_error;
               RETURN;
            END IF;
         END IF;
      END IF;
   END IF;

   --if fund name is null, then raise exception
   IF p_fund_rec.short_name = fnd_api.g_miss_char OR p_fund_rec.short_name IS NULL THEN
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
         fnd_message.set_name('OZF', 'OZF_NO_FUND_NAME');
         fnd_msg_pub.add;
      END IF;
      x_return_status := fnd_api.g_ret_sts_error;
      RETURN;
   END IF;

   --if fund type is null, then raise exception
   IF p_fund_rec.fund_type = fnd_api.g_miss_char OR p_fund_rec.fund_type IS NULL THEN
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
         fnd_message.set_name('OZF', 'OZF_NO_FUND_TYPE');
         fnd_msg_pub.add;
      END IF;
      x_return_status := fnd_api.g_ret_sts_error;
      RETURN;
   ELSE
      IF p_fund_rec.fund_type NOT IN ('FIXED', 'FULLY_ACCRUED') THEN
         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
            fnd_message.set_name('OZF', 'OZF_INVALID_FUND_TYPE');
            fnd_msg_pub.add;
         END IF;
         x_return_status := fnd_api.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

   --28-AUG-08 kdass - bug 7343771: accept custom setup passed to this API
   IF p_mode = 'CREATE' THEN
      IF (p_fund_rec.custom_setup_id = fnd_api.g_miss_num OR p_fund_rec.custom_setup_id IS NULL) THEN

         OPEN c_cust_setup (p_fund_rec.fund_type);
         FETCH c_cust_setup INTO p_fund_rec.custom_setup_id;
         CLOSE c_cust_setup;

      ELSE

         OPEN c_cust_setup_exists (p_fund_rec.fund_type, p_fund_rec.custom_setup_id);
         FETCH c_cust_setup_exists INTO l_cust_setup_exists;
         CLOSE c_cust_setup_exists;

         IF l_cust_setup_exists IS NULL THEN
            IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
               fnd_message.set_name('OZF', 'OZF_INVALID_SETUP_ID');
               fnd_msg_pub.add;
            END IF;
            x_return_status := fnd_api.g_ret_sts_error;
            RETURN;
         END IF;
      END IF;
   END IF;

   IF p_fund_rec.parent_fund_id <> fnd_api.g_miss_num AND p_fund_rec.parent_fund_id IS NOT NULL THEN
      --check if the input parent fund id is valid
      OPEN c_par_fund_exists (p_fund_rec.parent_fund_id);
      FETCH c_par_fund_exists INTO l_par_fund_exists;
      CLOSE c_par_fund_exists;

      IF l_fund_exists IS NULL THEN
         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
            fnd_message.set_name('OZF', 'OZF_INVALID_PAR_FUND_ID');
            fnd_msg_pub.add;
         END IF;
         x_return_status := fnd_api.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

   IF (p_fund_rec.parent_fund_name <> fnd_api.g_miss_char AND p_fund_rec.parent_fund_name IS NOT NULL) AND
      (p_fund_rec.parent_fund_id <> fnd_api.g_miss_num AND p_fund_rec.parent_fund_id IS NOT NULL) THEN

      --check if the input parent fund id is valid
      OPEN c_par_fund_id_exists (p_fund_rec.parent_fund_id, p_fund_rec.parent_fund_name);
      FETCH c_par_fund_id_exists INTO l_par_fund_exists;
      CLOSE c_par_fund_id_exists;

      IF l_par_fund_exists IS NULL THEN
         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
            fnd_message.set_name('OZF', 'OZF_INVALID_PAR_FUND_ID_NAME');
            fnd_msg_pub.add;
         END IF;
         x_return_status := fnd_api.g_ret_sts_error;
         RETURN;
      END IF;

   ELSIF p_fund_rec.parent_fund_id <> fnd_api.g_miss_num AND p_fund_rec.parent_fund_id IS NOT NULL THEN

      --check if the input parent fund id is valid
      OPEN c_par_fund_exists (p_fund_rec.parent_fund_id);
      FETCH c_par_fund_exists INTO l_par_fund_exists;
      CLOSE c_par_fund_exists;

      IF l_par_fund_exists IS NULL THEN
         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
            fnd_message.set_name('OZF', 'OZF_INVALID_PAR_FUND_ID');
            fnd_msg_pub.add;
         END IF;
         x_return_status := fnd_api.g_ret_sts_error;
         RETURN;
      END IF;

   ELSIF p_fund_rec.parent_fund_name <> fnd_api.g_miss_char AND p_fund_rec.parent_fund_name IS NOT NULL THEN

      --check if the input parent fund name is valid
      OPEN c_par_fund_name_exists (p_fund_rec.parent_fund_name);
      FETCH c_par_fund_name_exists INTO p_fund_rec.parent_fund_id;
      CLOSE c_par_fund_name_exists;

      IF p_fund_rec.parent_fund_id IS NULL THEN
         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
            fnd_message.set_name('OZF', 'OZF_INVALID_PAR_FUND_NAME');
            fnd_msg_pub.add;
         END IF;
         x_return_status := fnd_api.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

   IF (p_fund_rec.category_name = fnd_api.g_miss_char OR p_fund_rec.category_name IS NULL) AND
      (p_fund_rec.category_id = fnd_api.g_miss_num OR p_fund_rec.category_id IS NULL) THEN

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
         fnd_message.set_name('OZF', 'OZF_NO_CAT_ID_NAME');
         fnd_msg_pub.add;
      END IF;
      x_return_status := fnd_api.g_ret_sts_error;
      RETURN;

   ELSIF (p_fund_rec.category_name <> fnd_api.g_miss_char AND p_fund_rec.category_name IS NOT NULL) AND
      (p_fund_rec.category_id <> fnd_api.g_miss_num AND p_fund_rec.category_id IS NOT NULL) THEN

      --check if the input category id and name are valid
      OPEN c_cat_exists (p_fund_rec.category_id, p_fund_rec.category_name);
      FETCH c_cat_exists INTO l_cat_exists;
      CLOSE c_cat_exists;

      IF l_cat_exists IS NULL THEN
         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
            fnd_message.set_name('OZF', 'OZF_INVALID_CAT_ID_NAME');
            fnd_msg_pub.add;
         END IF;
         x_return_status := fnd_api.g_ret_sts_error;
         RETURN;
      END IF;

   ELSIF p_fund_rec.category_id <> fnd_api.g_miss_num AND p_fund_rec.category_id IS NOT NULL THEN

      --check if the input category id is valid
      OPEN c_cat_id_exists (p_fund_rec.category_id);
      FETCH c_cat_id_exists INTO l_cat_exists;
      CLOSE c_cat_id_exists;

      IF l_cat_exists IS NULL THEN
         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
            fnd_message.set_name('OZF', 'OZF_INVALID_CAT_ID');
            fnd_msg_pub.add;
         END IF;
         x_return_status := fnd_api.g_ret_sts_error;
         RETURN;
      END IF;

   ELSIF p_fund_rec.category_name <> fnd_api.g_miss_char AND p_fund_rec.category_name IS NOT NULL THEN

      --check if the input parent category name is valid
      OPEN c_cat_name_exists (p_fund_rec.category_name);
      FETCH c_cat_name_exists INTO p_fund_rec.category_id;
      CLOSE c_cat_name_exists;

      IF p_fund_rec.category_id IS NULL THEN
         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
            fnd_message.set_name('OZF', 'OZF_INVALID_CAT_NAME');
            fnd_msg_pub.add;
         END IF;
         x_return_status := fnd_api.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

   IF p_mode = 'CREATE' THEN
      p_fund_rec.org_id := MO_UTILS.get_default_org_id;

      IF p_fund_rec.org_id = fnd_api.g_miss_num OR p_fund_rec.org_id IS NULL THEN
         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
            fnd_message.set_name('OZF', 'OZF_NO_DEFAULT_ORG_ID');
            fnd_msg_pub.add;
         END IF;
      END IF;
   END IF;

   IF (p_fund_rec.business_unit <> fnd_api.g_miss_char AND p_fund_rec.business_unit IS NOT NULL) AND
      (p_fund_rec.business_unit_id <> fnd_api.g_miss_num AND p_fund_rec.business_unit_id IS NOT NULL) THEN

      --check if the input business unit id and name are valid
      OPEN c_bus_unit_exists (p_fund_rec.business_unit_id, p_fund_rec.business_unit, p_fund_rec.org_id);
      FETCH c_bus_unit_exists INTO l_bus_unit_exists;
      CLOSE c_bus_unit_exists;

      IF l_bus_unit_exists IS NULL THEN
         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
            fnd_message.set_name('OZF', 'OZF_INVALID_BUS_UNIT_ID_NAME');
            fnd_msg_pub.add;
         END IF;
         x_return_status := fnd_api.g_ret_sts_error;
         RETURN;
      END IF;

   ELSIF p_fund_rec.business_unit_id <> fnd_api.g_miss_num AND p_fund_rec.business_unit_id IS NOT NULL THEN

      --check if the input business_unit_id is valid
      OPEN c_bus_id_exists (p_fund_rec.business_unit_id, p_fund_rec.org_id);
      FETCH c_bus_id_exists INTO l_bus_unit_exists;
      CLOSE c_bus_id_exists;

      IF l_bus_unit_exists IS NULL THEN
         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
            fnd_message.set_name('OZF', 'OZF_INVALID_BUS_UNIT_ID');
            fnd_msg_pub.add;
         END IF;
         x_return_status := fnd_api.g_ret_sts_error;
         RETURN;
      END IF;

   ELSIF p_fund_rec.business_unit <> fnd_api.g_miss_char AND p_fund_rec.business_unit IS NOT NULL THEN

      --check if the input business unit name is valid
      OPEN c_bus_name_exists (p_fund_rec.business_unit, p_fund_rec.org_id);
      FETCH c_bus_name_exists INTO p_fund_rec.business_unit_id;
      CLOSE c_bus_name_exists;

      IF p_fund_rec.business_unit_id IS NULL THEN
         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
            fnd_message.set_name('OZF', 'OZF_INVALID_BUS_UNIT');
            fnd_msg_pub.add;
         END IF;
         x_return_status := fnd_api.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

   IF p_mode = 'CREATE' THEN
      p_fund_rec.status_code := 'DRAFT';
   END IF;

   --if status code is not null, then get the user status id
   IF p_fund_rec.status_code <> fnd_api.g_miss_char AND p_fund_rec.status_code IS NOT NULL THEN
      OPEN c_user_status_id (p_fund_rec.status_code);
      FETCH c_user_status_id INTO p_fund_rec.user_status_id;
      CLOSE c_user_status_id;
   END IF;

   --if currency code is null, then raise exception
   IF p_fund_rec.currency_code_tc = fnd_api.g_miss_char OR p_fund_rec.currency_code_tc IS NULL THEN
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
         fnd_message.set_name('OZF', 'OZF_NO_CURR_CODE');
         fnd_msg_pub.add;
      END IF;
      x_return_status := fnd_api.g_ret_sts_error;
      RETURN;
   END IF;

   IF p_fund_rec.fund_type = 'FULLY_ACCRUED' THEN

      IF p_fund_rec.accrual_basis = fnd_api.g_miss_char OR p_fund_rec.accrual_basis IS NULL THEN
         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
            fnd_message.set_name('OZF', 'OZF_NO_ACCR_BASIS');
            fnd_msg_pub.add;
         END IF;
         x_return_status := fnd_api.g_ret_sts_error;
         RETURN;
      ELSE
         IF p_fund_rec.accrual_basis NOT IN ('CUSTOMER', 'SALES') THEN
            IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
               fnd_message.set_name('OZF', 'OZF_INVALID_ACCR_BASIS');
               fnd_msg_pub.add;
            END IF;
            x_return_status := fnd_api.g_ret_sts_error;
            RETURN;
         END IF;
      END IF;

      IF p_fund_rec.accrual_phase = fnd_api.g_miss_char OR p_fund_rec.accrual_phase IS NULL THEN
         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
            fnd_message.set_name('OZF', 'OZF_NO_ACCR_PHASE');
            fnd_msg_pub.add;
         END IF;
         x_return_status := fnd_api.g_ret_sts_error;
         RETURN;
      ELSE
         IF p_fund_rec.accrual_phase NOT IN ('ACCRUAL', 'VOLUME') THEN
            IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
               fnd_message.set_name('OZF', 'OZF_INVALID_ACCR_PHASE');
               fnd_msg_pub.add;
            END IF;
            x_return_status := fnd_api.g_ret_sts_error;
            RETURN;
         END IF;
      END IF;

      IF p_fund_rec.accrual_discount_level = fnd_api.g_miss_char OR p_fund_rec.accrual_discount_level IS NULL THEN
         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
            fnd_message.set_name('OZF', 'OZF_NO_DISC_LEVEL');
            fnd_msg_pub.add;
         END IF;
         x_return_status := fnd_api.g_ret_sts_error;
         RETURN;
      ELSE
         IF p_fund_rec.accrual_discount_level NOT IN ('LINE', 'LINEGROUP') THEN
            IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
               fnd_message.set_name('OZF', 'OZF_INVALID_DISC_LEVEL');
               fnd_msg_pub.add;
            END IF;
            x_return_status := fnd_api.g_ret_sts_error;
            RETURN;
         END IF;
      END IF;

      IF p_fund_rec.accrual_basis = 'CUSTOMER' THEN
         p_fund_rec.liability_flag := NVL(p_fund_rec.liability_flag, 'Y');
      ELSE
         p_fund_rec.liability_flag := NVL(p_fund_rec.liability_flag, 'N');
      END IF;

      IF p_fund_rec.liability_flag NOT IN ('Y', 'N') THEN
         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
            fnd_message.set_name('OZF', 'OZF_INVALID_LIAB_FLAG');
            fnd_msg_pub.add;
         END IF;
         x_return_status := fnd_api.g_ret_sts_error;
         RETURN;
      END IF;

   END IF;

   IF (p_fund_rec.threshold_id <> fnd_api.g_miss_num AND p_fund_rec.threshold_id IS NOT NULL) AND
      (p_fund_rec.threshold_name <> fnd_api.g_miss_char AND p_fund_rec.threshold_name IS NOT NULL) THEN

      --check if the input threshold id and name are valid
      OPEN c_thrh_exists (p_fund_rec.threshold_id, p_fund_rec.threshold_name);
      FETCH c_thrh_exists INTO l_thrh_exists;
      CLOSE c_thrh_exists;

      IF l_thrh_exists IS NULL THEN
         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
            fnd_message.set_name('OZF', 'OZF_INVALID_BUS_UNIT_ID_NAME');
            fnd_msg_pub.add;
         END IF;
         x_return_status := fnd_api.g_ret_sts_error;
         RETURN;
      END IF;

   ELSIF p_fund_rec.threshold_id <> fnd_api.g_miss_num AND p_fund_rec.threshold_id IS NOT NULL THEN

      --check if the input threshold id is valid
      OPEN c_thrh_id_exists (p_fund_rec.threshold_id);
      FETCH c_thrh_id_exists INTO l_thrh_exists;
      CLOSE c_thrh_id_exists;

      IF l_thrh_exists IS NULL THEN
         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
            fnd_message.set_name('OZF', 'OZF_INVALID_THRH_ID');
            fnd_msg_pub.add;
         END IF;
         x_return_status := fnd_api.g_ret_sts_error;
         RETURN;
      END IF;

   ELSIF p_fund_rec.threshold_name <> fnd_api.g_miss_char AND p_fund_rec.threshold_name IS NOT NULL THEN

      --check if the input threshold name is valid
      OPEN c_thrh_name_exists (p_fund_rec.threshold_name);
      FETCH c_thrh_name_exists INTO p_fund_rec.threshold_id;
      CLOSE c_thrh_name_exists;

      IF p_fund_rec.threshold_id IS NULL THEN
         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
            fnd_message.set_name('OZF', 'OZF_INVALID_THRH_NAME');
            fnd_msg_pub.add;
         END IF;
         x_return_status := fnd_api.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

   IF (p_fund_rec.task_id <> fnd_api.g_miss_num AND p_fund_rec.task_id IS NOT NULL) AND
      (p_fund_rec.task_name <> fnd_api.g_miss_char AND p_fund_rec.task_name IS NOT NULL) THEN

      --check if the input task id and name are valid
      OPEN c_task_exists (p_fund_rec.task_id, p_fund_rec.task_name);
      FETCH c_task_exists INTO l_task_exists;
      CLOSE c_task_exists;

      IF l_task_exists IS NULL THEN
         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
            fnd_message.set_name('OZF', 'OZF_INVALID_TASK_ID_NAME');
            fnd_msg_pub.add;
         END IF;
         x_return_status := fnd_api.g_ret_sts_error;
         RETURN;
      END IF;

   ELSIF p_fund_rec.task_id <> fnd_api.g_miss_num AND p_fund_rec.task_id IS NOT NULL THEN

      --check if the input task id is valid
      OPEN c_task_id_exists (p_fund_rec.task_id);
      FETCH c_task_id_exists INTO l_task_exists;
      CLOSE c_task_id_exists;

      IF l_task_exists IS NULL THEN
         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
            fnd_message.set_name('OZF', 'OZF_INVALID_TASK_ID');
            fnd_msg_pub.add;
         END IF;
         x_return_status := fnd_api.g_ret_sts_error;
         RETURN;
      END IF;

   ELSIF p_fund_rec.task_name <> fnd_api.g_miss_char AND p_fund_rec.task_name IS NOT NULL THEN

      --check if the input task name is valid
      OPEN c_task_name_exists (p_fund_rec.task_name);
      FETCH c_task_name_exists INTO p_fund_rec.task_id;
      CLOSE c_task_name_exists;

      IF p_fund_rec.task_id IS NULL THEN
         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
            fnd_message.set_name('OZF', 'OZF_INVALID_TASK_NAME');
            fnd_msg_pub.add;
         END IF;
         x_return_status := fnd_api.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

   IF (p_fund_rec.ledger_id <> fnd_api.g_miss_num AND p_fund_rec.ledger_id IS NOT NULL) AND
      (p_fund_rec.ledger_name <> fnd_api.g_miss_char AND p_fund_rec.ledger_name IS NOT NULL) THEN

      --check if the input ledger id and name are valid
      OPEN c_ledger_exists (p_fund_rec.ledger_id, p_fund_rec.ledger_name);
      FETCH c_ledger_exists INTO l_ledger_exists;
      CLOSE c_ledger_exists;

      IF l_ledger_exists IS NULL THEN
         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
            fnd_message.set_name('OZF', 'OZF_INVALID_LEDGER_ID_NAME');
            fnd_msg_pub.add;
         END IF;
         x_return_status := fnd_api.g_ret_sts_error;
         RETURN;
      END IF;

   ELSIF p_fund_rec.ledger_id <> fnd_api.g_miss_num AND p_fund_rec.ledger_id IS NOT NULL THEN

      --check if the input ledger id is valid
      OPEN c_ledger_id_exists (p_fund_rec.ledger_id);
      FETCH c_ledger_id_exists INTO l_ledger_exists;
      CLOSE c_ledger_id_exists;

      IF l_ledger_exists IS NULL THEN
         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
            fnd_message.set_name('OZF', 'OZF_INVALID_LEDGER_ID');
            fnd_msg_pub.add;
         END IF;
         x_return_status := fnd_api.g_ret_sts_error;
         RETURN;
      END IF;

   ELSIF p_fund_rec.ledger_name <> fnd_api.g_miss_char AND p_fund_rec.ledger_name IS NOT NULL THEN

      --check if the input ledger name is valid
      OPEN c_ledger_name_exists (p_fund_rec.ledger_name);
      FETCH c_ledger_name_exists INTO p_fund_rec.ledger_id;
      CLOSE c_ledger_name_exists;

      IF p_fund_rec.ledger_id IS NULL THEN
         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
            fnd_message.set_name('OZF', 'OZF_INVALID_LEDGER_NAME');
            fnd_msg_pub.add;
         END IF;
         x_return_status := fnd_api.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

END validate_fund_items;

---------------------------------------------------------------------
-- PROCEDURE
--    Create_Fund
--
-- PURPOSE
--    Create a new fund (fixed budget).
--
-- PARAMETERS
--    p_fund_rec: the new record to be inserted
--    x_fund_id: return the fund_id of the new fund
---------------------------------------------------------------------
PROCEDURE Create_fund(
   p_api_version        IN         NUMBER
  ,p_init_msg_list      IN         VARCHAR2 := fnd_api.g_false
  ,p_commit             IN         VARCHAR2 := fnd_api.g_false
  ,p_validation_level   IN         NUMBER := fnd_api.g_valid_level_full
  ,x_return_status      OUT NOCOPY VARCHAR2
  ,x_msg_count          OUT NOCOPY NUMBER
  ,x_msg_data           OUT NOCOPY VARCHAR2
  ,p_fund_rec           IN         fund_rec_type
  ,x_fund_id            OUT NOCOPY NUMBER
   )
IS
l_modifier_list_rec ozf_offer_pub.modifier_list_rec_type;
l_modifier_line_tbl ozf_offer_pub.modifier_line_tbl_type;
l_vo_pbh_tbl        ozf_offer_pub.vo_disc_tbl_type;
l_vo_dis_tbl        ozf_offer_pub.vo_disc_tbl_type;
l_vo_prod_tbl       ozf_offer_pub.vo_prod_tbl_type;
l_qualifier_tbl     ozf_offer_pub.qualifiers_tbl_type;
l_vo_mo_tbl         ozf_offer_pub.vo_mo_tbl_type;

BEGIN

   create_fund(p_api_version       => p_api_version
              ,p_init_msg_list     => p_init_msg_list
              ,p_commit            => p_commit
              ,p_validation_level  => p_validation_level
              ,x_return_status     => x_return_status
              ,x_msg_count         => x_msg_count
              ,x_msg_data          => x_msg_data
              ,p_fund_rec          => p_fund_rec
              ,p_modifier_list_rec => l_modifier_list_rec
              ,p_modifier_line_tbl => l_modifier_line_tbl
              ,p_vo_pbh_tbl        => l_vo_pbh_tbl
              ,p_vo_dis_tbl        => l_vo_dis_tbl
              ,p_vo_prod_tbl       => l_vo_prod_tbl
              ,p_qualifier_tbl     => l_qualifier_tbl
              ,p_vo_mo_tbl         => l_vo_mo_tbl
              ,x_fund_id           => x_fund_id
              );

END Create_fund;

---------------------------------------------------------------------
-- PROCEDURE
--    Create_Fund
--
-- PURPOSE
--    Create a new fund (fully accrued budget).
--
-- PARAMETERS
--    p_fund_rec: the new record to be inserted
--    x_fund_id: return the fund_id of the new fund
---------------------------------------------------------------------
PROCEDURE Create_fund(
   p_api_version        IN         NUMBER
  ,p_init_msg_list      IN         VARCHAR2 := fnd_api.g_false
  ,p_commit             IN         VARCHAR2 := fnd_api.g_false
  ,p_validation_level   IN         NUMBER := fnd_api.g_valid_level_full
  ,x_return_status      OUT NOCOPY VARCHAR2
  ,x_msg_count          OUT NOCOPY NUMBER
  ,x_msg_data           OUT NOCOPY VARCHAR2
  ,p_fund_rec           IN         fund_rec_type
  ,p_modifier_list_rec  IN         ozf_offer_pub.modifier_list_rec_type
  ,p_modifier_line_tbl  IN         ozf_offer_pub.modifier_line_tbl_type
  ,p_vo_pbh_tbl         IN         ozf_offer_pub.vo_disc_tbl_type
  ,p_vo_dis_tbl         IN         ozf_offer_pub.vo_disc_tbl_type
  ,p_vo_prod_tbl        IN         ozf_offer_pub.vo_prod_tbl_type
  ,p_qualifier_tbl      IN         ozf_offer_pub.qualifiers_tbl_type
  ,p_vo_mo_tbl          IN         ozf_offer_pub.vo_mo_tbl_type
  ,x_fund_id            OUT NOCOPY NUMBER
   )
IS
l_api_name          VARCHAR(30) := 'Create_Fund';
l_fund_rec          OZF_FUNDS_PUB.fund_rec_type  := p_fund_rec;
l_pvt_fund_rec      OZF_Funds_PVT.fund_rec_type;
l_qp_list_header_id NUMBER;
l_error_location    NUMBER;
l_mode              VARCHAR2(6) := 'CREATE';
l_budget_tbl        ozf_offer_pub.budget_tbl_type;
l_act_product_tbl   ozf_offer_pub.act_product_tbl_type;
l_discount_tbl      ozf_offer_pub.discount_line_tbl_type;
l_excl_tbl          ozf_offer_pub.excl_rec_tbl_type;
l_offer_tier_tbl    ozf_offer_pub.offer_tier_tbl_type;
l_prod_tbl          ozf_offer_pub.prod_rec_tbl_type;
l_na_qualifier_tbl  ozf_offer_pub.na_qualifier_tbl_type;
l_modifier_list_rec ozf_offer_pub.modifier_list_rec_type := p_modifier_list_rec;

CURSOR c_list_header_id (p_fund_id IN NUMBER) IS
   SELECT plan_id
   FROM  ozf_funds_all_b
   WHERE fund_id = p_fund_id;

BEGIN

  SAVEPOINT Create_Fund_PUB;

  validate_fund_items(p_fund_rec      => l_fund_rec
                     ,p_mode          => l_mode
                     ,x_return_status => x_return_status);

  IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
     RAISE fnd_api.g_exc_unexpected_error;
  ELSIF x_return_status = fnd_api.g_ret_sts_error THEN
     RAISE fnd_api.g_exc_error;
  END IF;

  l_pvt_fund_rec.fund_id := l_fund_rec.fund_id;
  l_pvt_fund_rec.fund_number := l_fund_rec.fund_number;
  l_pvt_fund_rec.short_name := l_fund_rec.short_name;
  l_pvt_fund_rec.fund_type := l_fund_rec.fund_type;
  l_pvt_fund_rec.custom_setup_id := l_fund_rec.custom_setup_id;
  l_pvt_fund_rec.description := l_fund_rec.description;
  l_pvt_fund_rec.parent_fund_id  := l_fund_rec.parent_fund_id;
  l_pvt_fund_rec.category_id := l_fund_rec.category_id;
  l_pvt_fund_rec.business_unit_id := l_fund_rec.business_unit_id;
  l_pvt_fund_rec.status_code := l_fund_rec.status_code;
  l_pvt_fund_rec.user_status_id := l_fund_rec.user_status_id;
  l_pvt_fund_rec.start_date_active := l_fund_rec.start_date_active;
  l_pvt_fund_rec.end_date_active := l_fund_rec.end_date_active;
  l_pvt_fund_rec.start_period_name := l_fund_rec.start_period_name;
  l_pvt_fund_rec.end_period_name := l_fund_rec.end_period_name;
  l_pvt_fund_rec.original_budget := l_fund_rec.original_budget;
  l_pvt_fund_rec.holdback_amt := l_fund_rec.holdback_amt;
  l_pvt_fund_rec.currency_code_tc := l_fund_rec.currency_code_tc;
  l_pvt_fund_rec.owner := l_fund_rec.owner;
  l_pvt_fund_rec.accrual_basis := l_fund_rec.accrual_basis;
  l_pvt_fund_rec.accrual_phase := l_fund_rec.accrual_phase;
  l_pvt_fund_rec.accrual_discount_level := l_fund_rec.accrual_discount_level;
  l_pvt_fund_rec.threshold_id := l_fund_rec.threshold_id;
  l_pvt_fund_rec.task_id := l_fund_rec.task_id;
  l_pvt_fund_rec.liability_flag := l_fund_rec.liability_flag;
  l_pvt_fund_rec.accrued_liable_account := l_fund_rec.accrued_liable_account;
  l_pvt_fund_rec.ded_adjustment_account := l_fund_rec.ded_adjustment_account;
  l_pvt_fund_rec.product_spread_time_id := l_fund_rec.product_spread_time_id;
  l_pvt_fund_rec.org_id := l_fund_rec.org_id;
  l_pvt_fund_rec.ledger_id := l_fund_rec.ledger_id;

  ozf_funds_pvt.create_fund(p_api_version      => p_api_version
                           ,p_init_msg_list    => p_init_msg_list
                           ,p_commit           => p_commit
                           ,p_validation_level => p_validation_level
                           ,x_return_status    => x_return_status
                           ,x_msg_count        => x_msg_count
                           ,x_msg_data         => x_msg_data
                           ,p_fund_rec         => l_pvt_fund_rec
                           ,x_fund_id          => x_fund_id
                           );

  IF G_DEBUG THEN
     ozf_utility_pvt.debug_message('fund_type: ' || l_pvt_fund_rec.fund_type);
  END IF;

  IF l_pvt_fund_rec.fund_type   = 'FULLY_ACCRUED' THEN

     OPEN c_list_header_id(x_fund_id);
     FETCH c_list_header_id INTO l_qp_list_header_id;
     CLOSE c_list_header_id;

     l_modifier_list_rec.modifier_operation := 'UPDATE';
     l_modifier_list_rec.offer_operation := 'UPDATE';
     l_modifier_list_rec.qp_list_header_id := l_qp_list_header_id;

     IF G_DEBUG THEN
        ozf_utility_pvt.debug_message('accrual_phase: ' || l_pvt_fund_rec.accrual_phase);
     END IF;

     IF l_pvt_fund_rec.accrual_phase = 'ACCRUAL' THEN --accrual offer

        ozf_offer_pub.process_modifiers(p_init_msg_list     => p_init_msg_list
                                       ,p_api_version       => p_api_version
                                       ,p_commit            => p_commit
                                       ,x_return_status     => x_return_status
                                       ,x_msg_count         => x_msg_count
                                       ,x_msg_data          => x_msg_data
                                       ,p_offer_type        => 'ACCRUAL'
                                       ,p_modifier_list_rec => l_modifier_list_rec  --offer header details
                                       ,p_modifier_line_tbl => p_modifier_line_tbl  --discount rules
                                       ,p_qualifier_tbl     => p_qualifier_tbl      --market eligibilty
                                       ,p_budget_tbl        => l_budget_tbl
                                       ,p_act_product_tbl   => l_act_product_tbl
                                       ,p_discount_tbl      => l_discount_tbl
                                       ,p_excl_tbl          => l_excl_tbl
                                       ,p_offer_tier_tbl    => l_offer_tier_tbl
                                       ,p_prod_tbl          => l_prod_tbl
                                       ,p_na_qualifier_tbl  => l_na_qualifier_tbl
                                       ,x_qp_list_header_id => l_qp_list_header_id
                                       ,x_error_location    => l_error_location
                                       );


     ELSIF l_pvt_fund_rec.accrual_phase = 'VOLUME' THEN --volume offer

        ozf_offer_pub.process_vo(p_init_msg_list     => p_init_msg_list
                                ,p_api_version       => p_api_version
                                ,p_commit            => p_commit
                                ,x_return_status     => x_return_status
                                ,x_msg_count         => x_msg_count
                                ,x_msg_data          => x_msg_data
                                ,p_modifier_list_rec => l_modifier_list_rec --offer header detail
                                ,p_vo_pbh_tbl        => p_vo_pbh_tbl        --discount table headers
                                ,p_vo_dis_tbl        => p_vo_dis_tbl        --discount table tiers
                                ,p_vo_prod_tbl       => p_vo_prod_tbl       --discount tabel products
                                ,p_qualifier_tbl     => p_qualifier_tbl     --market eligibilty
                                ,p_vo_mo_tbl         => p_vo_mo_tbl         --market options
                                ,p_budget_tbl        => l_budget_tbl
                                ,x_qp_list_header_id => l_qp_list_header_id
                                ,x_error_location    => l_error_location
                                );
     END IF;

  END IF;

   IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
      RAISE fnd_api.g_exc_unexpected_error;
   ELSIF x_return_status = fnd_api.g_ret_sts_error THEN
      RAISE fnd_api.g_exc_error;
   END IF;

   FND_MSG_PUB.Count_And_Get (
    p_encoded => FND_API.G_FALSE,
    p_count   => x_msg_count,
    p_data    => x_msg_data
   );

   EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
   ROLLBACK TO Create_Fund_PUB;
   x_return_status := FND_API.G_RET_STS_ERROR;
   -- Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get (
   p_encoded => FND_API.G_FALSE,
   p_count   => x_msg_count,
   p_data    => x_msg_data
   );
WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   ROLLBACK TO Create_Fund_PUB;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   -- Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get (
   p_encoded => FND_API.G_FALSE,
   p_count   => x_msg_count,
   p_data    => x_msg_data
   );
WHEN OTHERS THEN
   ROLLBACK TO Create_Fund_PUB;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
   THEN
      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
   END IF;
   -- Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get (
   p_encoded => FND_API.G_FALSE,
   p_count   => x_msg_count,
   p_data    => x_msg_data
   );
END Create_Fund;
--------------------------------------------------------------------
-- PROCEDURE
--    Delete_Fund
--
-- PURPOSE
--    Delete a fund.
--
-- PARAMETERS
--    p_fund_id: the fund_id
--    p_object_version: the object_version_number
--
-- NOTES
--    1. Raise exception if the object_version_number doesn't match.
--------------------------------------------------------------------

PROCEDURE Delete_Fund(
   p_api_version       IN  NUMBER
  ,p_init_msg_list     IN  VARCHAR2 := FND_API.g_false
  ,p_commit            IN  VARCHAR2 := FND_API.g_false
  ,x_return_status     OUT NOCOPY VARCHAR2
  ,x_msg_count         OUT NOCOPY NUMBER
  ,x_msg_data          OUT NOCOPY VARCHAR2
  ,p_fund_id           IN  NUMBER
  ,p_object_version    IN  NUMBER
)

IS
l_dependent_object_tbl ams_utility_pvt.dependent_objects_tbl_type;
l_return_status  VARCHAR2(30);
l_msg_count NUMBER;
l_msg_data  VARCHAR2(30);
l_api_name       VARCHAR(30) := 'Delete_Fund';

BEGIN

   SAVEPOINT Delete_Fund_PUB;

   OZF_Fund_Extension_Pvt.delete_fund(p_api_version_number     => p_api_version
                                     ,p_init_msg_list          => p_init_msg_list
                                     ,p_commit                 => p_commit
                                     ,p_object_id              => p_fund_id
                                     ,p_object_version_number  => p_object_version
                                     ,x_return_status          => l_return_status
                                     ,x_msg_count              => l_msg_count
                                     ,x_msg_data               => l_msg_data
                                     );

   IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
      RAISE fnd_api.g_exc_unexpected_error;
   ELSIF x_return_status = fnd_api.g_ret_sts_error THEN
      RAISE fnd_api.g_exc_error;
   END IF;

   FND_MSG_PUB.Count_And_Get(
    p_encoded => FND_API.G_FALSE,
    p_count   => x_msg_count,
    p_data    => x_msg_data
    );

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
   ROLLBACK TO Delete_Fund_PUB;
   x_return_status := FND_API.G_RET_STS_ERROR;
   -- Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get (
   p_encoded => FND_API.G_FALSE,
   p_count   => x_msg_count,
   p_data    => x_msg_data
   );
WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   ROLLBACK TO Delete_Fund_PUB;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   -- Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get (
   p_encoded => FND_API.G_FALSE,
   p_count   => x_msg_count,
   p_data    => x_msg_data
   );
WHEN OTHERS THEN
   ROLLBACK TO Delete_Fund_PUB;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
   THEN
      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
   END IF;
   -- Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get (
   p_encoded => FND_API.G_FALSE,
   p_count   => x_msg_count,
   p_data    => x_msg_data
   );

END Delete_Fund;


---------------------------------------------------------------------
-- PROCEDURE
--    Update_Fund
--
-- PURPOSE
--    Update a fund.
--
-- PARAMETERS
--    p_fund_rec: the record with new items.
--    p_mode    : determines what sort of validation is to be performed during update.
--              : The mode should always be 'UPDATE' except when updating the earned or committed amount
--
-- NOTES
--    1. Raise exception if the object_version_number doesn't match.
--    2. If an attribute is passed in as FND_API.g_miss_char/num/date,
--       that column won't be updated.
----------------------------------------------------------------------
PROCEDURE Update_fund(
   p_api_version        IN         NUMBER
  ,p_init_msg_list      IN         VARCHAR2 := fnd_api.g_false
  ,p_commit             IN         VARCHAR2 := fnd_api.g_false
  ,p_validation_level   IN         NUMBER := fnd_api.g_valid_level_full
  ,x_return_status      OUT NOCOPY VARCHAR2
  ,x_msg_count          OUT NOCOPY NUMBER
  ,x_msg_data           OUT NOCOPY VARCHAR2
  ,p_fund_rec           IN         fund_rec_type
  ,p_modifier_list_rec  IN         ozf_offer_pub.modifier_list_rec_type
  ,p_modifier_line_tbl  IN         ozf_offer_pub.modifier_line_tbl_type
  ,p_vo_pbh_tbl         IN         ozf_offer_pub.vo_disc_tbl_type
  ,p_vo_dis_tbl         IN         ozf_offer_pub.vo_disc_tbl_type
  ,p_vo_prod_tbl        IN         ozf_offer_pub.vo_prod_tbl_type
  ,p_qualifier_tbl      IN         ozf_offer_pub.qualifiers_tbl_type
  ,p_vo_mo_tbl          IN         ozf_offer_pub.vo_mo_tbl_type
  )
IS
l_api_name               VARCHAR(30) := 'Update_Fund';
l_fund_rec               fund_rec_type  := p_fund_rec;
l_pvt_fund_rec           OZF_Funds_PVT.fund_rec_type;
l_fund_id                NUMBER := l_fund_rec.fund_id;
l_fund_number            VARCHAR2(200);
l_short_name             VARCHAR2(200);
l_fund_type              VARCHAR2(20);
l_custom_setup_id        NUMBER;
l_description            VARCHAR2(2000);
l_parent_fund_id         NUMBER;
l_category_id            NUMBER;
l_business_unit_id       NUMBER;
l_status_code            VARCHAR2(50);
l_start_date_active      DATE;
l_end_date_active        DATE;
l_start_period_name      VARCHAR2(20);
l_end_period_name        VARCHAR2(20);
l_original_budget        NUMBER;
l_holdback_amt           NUMBER;
l_currency_code_tc       VARCHAR2(10);
l_owner                  NUMBER;
l_accrual_basis          VARCHAR2(10);
l_accrual_phase          VARCHAR2(10);
l_accrual_discount_level VARCHAR2(10);
l_threshold_id           NUMBER;
l_task_id                NUMBER;
l_liability_flag         VARCHAR2(1);
l_accrued_liable_account NUMBER;
l_ded_adjustment_account NUMBER;
l_product_spread_time_id NUMBER;
l_object_version_number  NUMBER;
l_org_id                 NUMBER;
l_ledger_id              NUMBER;
l_mode                   VARCHAR2(6) := 'UPDATE';

CURSOR c_fund_id (p_fund_number IN VARCHAR2) IS
   SELECT fund_id
   FROM  ozf_funds_all_b
   WHERE fund_number = p_fund_number;

CURSOR c_fund_details (p_fund_id IN NUMBER) IS
   SELECT fund_number, short_name, fund_type, custom_setup_id, description, parent_fund_id, category_id,
          business_unit_id, status_code, start_date_active, end_date_active, start_period_name,
          end_period_name, original_budget, holdback_amt, currency_code_tc, owner, accrual_basis,
          accrual_phase, accrual_discount_level, threshold_id, task_id, liability_flag,
          accrued_liable_account, ded_adjustment_account, product_spread_time_id, object_version_number,
          org_id, ledger_id
   FROM  ozf_funds_all_vl
   WHERE fund_id = p_fund_id;

BEGIN

  SAVEPOINT Update_Fund_PUB;

  IF l_fund_rec.fund_id IS NULL AND l_fund_rec.fund_number IS NOT NULL THEN
      OPEN c_fund_id (l_fund_rec.fund_number);
      FETCH c_fund_id INTO l_fund_id;
      CLOSE c_fund_id;
  END IF;

  IF G_DEBUG THEN
      ozf_utility_pvt.debug_message(l_api_name || ': l_fund_id :' || l_fund_id);
  END IF;

  IF l_fund_id IS NOT NULL THEN
     OPEN c_fund_details (l_fund_id);
     FETCH c_fund_details INTO l_fund_number, l_short_name, l_fund_type, l_custom_setup_id, l_description,
                               l_parent_fund_id, l_category_id, l_business_unit_id,
                               l_status_code, l_start_date_active, l_end_date_active,
                               l_start_period_name, l_end_period_name, l_original_budget, l_holdback_amt,
                               l_currency_code_tc, l_owner, l_accrual_basis, l_accrual_phase, l_accrual_discount_level,
                               l_threshold_id, l_task_id, l_liability_flag, l_accrued_liable_account,
                               l_ded_adjustment_account, l_product_spread_time_id, l_object_version_number,
                               l_org_id, l_ledger_id;
     CLOSE c_fund_details;
  END IF;

  l_fund_rec.fund_number := NVL(l_fund_rec.fund_number,l_fund_number);
  l_fund_rec.short_name := NVL(l_fund_rec.short_name,l_short_name);
  l_fund_rec.fund_type := l_fund_type;
  l_fund_rec.custom_setup_id := l_custom_setup_id;
  l_fund_rec.description := NVL(l_fund_rec.description,l_description);
  l_fund_rec.parent_fund_id := NVL(l_fund_rec.parent_fund_id,l_parent_fund_id);
  l_fund_rec.category_id := NVL(l_fund_rec.category_id,l_category_id);
  --kdass - fixed bug 9432802
  l_fund_rec.business_unit_id := NVL(l_fund_rec.business_unit_id,l_business_unit_id);
  --l_fund_rec.business_unit_id := NVL(l_fund_rec.business_unit_id,l_description);
  l_fund_rec.status_code := NVL(l_fund_rec.status_code,l_status_code);
  l_fund_rec.start_date_active := NVL(l_fund_rec.start_date_active,l_start_date_active);
  l_fund_rec.end_date_active := NVL(l_fund_rec.end_date_active,l_end_date_active);
  l_fund_rec.start_period_name := NVL(l_fund_rec.start_period_name,l_start_period_name);
  l_fund_rec.end_period_name := NVL(l_fund_rec.end_period_name,l_end_period_name);
  l_fund_rec.original_budget := NVL(l_fund_rec.original_budget,l_original_budget);
  l_fund_rec.holdback_amt := NVL(l_fund_rec.holdback_amt,l_holdback_amt);
  l_fund_rec.currency_code_tc := l_currency_code_tc;
  l_fund_rec.owner := NVL(l_fund_rec.owner,l_owner);
  l_fund_rec.accrual_basis := l_accrual_basis;
  l_fund_rec.accrual_phase := l_accrual_phase;
  l_fund_rec.accrual_discount_level := l_accrual_discount_level;
  l_fund_rec.threshold_id := NVL(l_fund_rec.threshold_id,l_threshold_id);
  l_fund_rec.task_id := NVL(l_fund_rec.task_id,l_task_id);
  l_fund_rec.liability_flag := NVL(l_fund_rec.liability_flag,l_liability_flag);
  l_fund_rec.accrued_liable_account := NVL(l_fund_rec.accrued_liable_account,l_accrued_liable_account);
  l_fund_rec.ded_adjustment_account := NVL(l_fund_rec.ded_adjustment_account,l_ded_adjustment_account);
  l_fund_rec.product_spread_time_id := NVL(l_fund_rec.product_spread_time_id,l_product_spread_time_id);
  l_fund_rec.object_version_number := l_object_version_number;
  l_fund_rec.org_id := l_org_id;
  l_fund_rec.ledger_id := NVL(l_fund_rec.ledger_id,l_ledger_id);

  validate_fund_items(p_fund_rec      => l_fund_rec
                     ,p_mode          => l_mode
                     ,x_return_status => x_return_status);

  IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
     RAISE fnd_api.g_exc_unexpected_error;
  ELSIF x_return_status = fnd_api.g_ret_sts_error THEN
     RAISE fnd_api.g_exc_error;
  END IF;

  l_pvt_fund_rec.fund_id := l_fund_rec.fund_id;
  l_pvt_fund_rec.fund_number := l_fund_rec.fund_number;
  l_pvt_fund_rec.short_name := l_fund_rec.short_name;
  l_pvt_fund_rec.fund_type := l_fund_rec.fund_type;
  l_pvt_fund_rec.custom_setup_id := l_fund_rec.custom_setup_id;
  l_pvt_fund_rec.description := l_fund_rec.description;
  l_pvt_fund_rec.parent_fund_id  := l_fund_rec.parent_fund_id;
  l_pvt_fund_rec.category_id := l_fund_rec.category_id;
  l_pvt_fund_rec.business_unit_id := l_fund_rec.business_unit_id;
  l_pvt_fund_rec.status_code := l_fund_rec.status_code;
  l_pvt_fund_rec.user_status_id := l_fund_rec.user_status_id;
  l_pvt_fund_rec.start_date_active := l_fund_rec.start_date_active;
  l_pvt_fund_rec.end_date_active := l_fund_rec.end_date_active;
  l_pvt_fund_rec.start_period_name := l_fund_rec.start_period_name;
  l_pvt_fund_rec.end_period_name := l_fund_rec.end_period_name;
  l_pvt_fund_rec.original_budget := l_fund_rec.original_budget;
  l_pvt_fund_rec.holdback_amt := l_fund_rec.holdback_amt;
  l_pvt_fund_rec.currency_code_tc := l_fund_rec.currency_code_tc;
  l_pvt_fund_rec.owner := l_fund_rec.owner;
  l_pvt_fund_rec.accrual_basis := l_fund_rec.accrual_basis;
  l_pvt_fund_rec.accrual_phase := l_fund_rec.accrual_phase;
  l_pvt_fund_rec.accrual_discount_level := l_fund_rec.accrual_discount_level;
  l_pvt_fund_rec.threshold_id := l_fund_rec.threshold_id;
  l_pvt_fund_rec.task_id := l_fund_rec.task_id;
  l_pvt_fund_rec.liability_flag := l_fund_rec.liability_flag;
  l_pvt_fund_rec.accrued_liable_account := l_fund_rec.accrued_liable_account;
  l_pvt_fund_rec.ded_adjustment_account := l_fund_rec.ded_adjustment_account;
  l_pvt_fund_rec.product_spread_time_id := l_fund_rec.product_spread_time_id;
  l_pvt_fund_rec.object_version_number := l_fund_rec.object_version_number;
  l_pvt_fund_rec.org_id := l_fund_rec.org_id;
  l_pvt_fund_rec.ledger_id := l_fund_rec.ledger_id;

  ozf_funds_pvt.update_fund(p_api_version      => p_api_version
                           ,p_init_msg_list    => p_init_msg_list
                           ,p_commit           => p_commit
                           ,p_validation_level => p_validation_level
                           ,x_return_status    => x_return_status
                           ,x_msg_count        => x_msg_count
                           ,x_msg_data         => x_msg_data
                           ,p_fund_rec         => l_pvt_fund_rec
                           ,p_mode             => jtf_plsql_api.g_update
                           );

  IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
     RAISE fnd_api.g_exc_unexpected_error;
  ELSIF x_return_status = fnd_api.g_ret_sts_error THEN
     RAISE fnd_api.g_exc_error;
  END IF;

  FND_MSG_PUB.Count_And_Get (
    p_encoded => FND_API.G_FALSE,
    p_count   => x_msg_count,
    p_data    => x_msg_data
   );

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
   ROLLBACK TO Update_Fund_PUB;
   x_return_status := FND_API.G_RET_STS_ERROR;
   -- Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get (
   p_encoded => FND_API.G_FALSE,
   p_count   => x_msg_count,
   p_data    => x_msg_data
   );
WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   ROLLBACK TO Update_Fund_PUB;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   -- Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get (
   p_encoded => FND_API.G_FALSE,
   p_count   => x_msg_count,
   p_data    => x_msg_data
   );
WHEN OTHERS THEN
   ROLLBACK TO Update_Fund_PUB;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
   THEN
      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
   END IF;
   -- Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get (
   p_encoded => FND_API.G_FALSE,
   p_count   => x_msg_count,
   p_data    => x_msg_data
   );
END Update_Fund;

---------------------------------------------------------------------
-- PROCEDURE
--    validate_market_segment
--
-- PURPOSE
--    Validate market segment
--
-- PARAMETERS
--    p_mks_rec: market segment record to be validated
--    x_return_status: return status
--
-- HISTORY
--    06/29/2005  kdass Created
---------------------------------------------------------------------
PROCEDURE validate_market_segment (
   p_mks_rec            IN OUT NOCOPY   mks_rec_type
  ,p_mode               IN              VARCHAR2
  ,x_return_status      OUT NOCOPY      VARCHAR2
  )
IS
l_api_name               VARCHAR(30) := 'validate_market_segment';
l_act_mkt_exists         NUMBER := NULL;
l_segment_used_by_exists NUMBER := NULL;
l_segment_exists         NUMBER := NULL;
l_segment_id_exists      NUMBER := NULL;

CURSOR c_act_mkt_exists (p_activity_market_segment_id IN NUMBER) IS
   SELECT 1
   FROM  ams_act_market_segments
   WHERE activity_market_segment_id = p_activity_market_segment_id;

CURSOR c_segment_used_by_exists (p_segment_used_by_id IN NUMBER) IS
   SELECT 1
   FROM ozf_funds_all_b
   WHERE fund_id = p_segment_used_by_id;

CURSOR c_segment_exists (p_segment IN VARCHAR2) IS
   SELECT 1
   FROM  ozf_lookups
   WHERE lookup_type = 'OZF_OFFER_DEAL_CUSTOMER_TYPES'
     AND enabled_flag = 'Y'
     AND lookup_code = p_segment;

CURSOR c_segment_buyer (p_segment_id IN NUMBER) IS
   SELECT 1
   FROM  ams_party_market_segments ams, hz_parties hz
   WHERE ams.market_qualifier_type = 'BG'
     AND ams.market_qualifier_reference = hz.party_id
     AND ams.market_qualifier_reference = ams.party_id
     AND EXISTS
       ( SELECT 1
         FROM  ams_party_market_segments
         WHERE market_qualifier_type = 'BG'
          AND  market_qualifier_reference = ams.market_qualifier_reference
          AND  market_qualifier_reference <> party_id)
     AND hz.party_id = p_segment_id;

CURSOR c_segment_cust (p_segment_id IN NUMBER) IS
   SELECT 1
   FROM  qp_customers_v
   WHERE customer_id = p_segment_id;

CURSOR c_segment_billto (p_segment_id IN NUMBER) IS
   SELECT 1
   FROM  oe_invoice_to_orgs_v oito,hz_cust_accounts cust_acct,hz_parties party
   WHERE cust_acct.party_id = party.party_id
     AND oito.customer_id = cust_acct.cust_account_id
     AND oito.organization_id = p_segment_id;

CURSOR c_segment_list (p_segment_id IN NUMBER) IS
   SELECT 1
   FROM  ams_list_headers_all list, ams_list_headers_all_tl tl
   WHERE list.list_header_id = tl.list_header_id
     AND userenv('LANG') = language
     AND status_code in ( 'AVAILABLE','LOCKED','EXECUTED','EXECUTING','VALIDATED','VALIDATING')
     AND list.list_header_id = p_segment_id;

CURSOR c_segment_seg (p_segment_id IN NUMBER) IS
   SELECT 1
   FROM  ams_cells_all_b cell, ams_cells_all_tl tl
   WHERE cell.cell_id = tl.cell_id
     AND userenv('LANG') = language
     AND cell.status_code = 'AVAILABLE'
     AND cell.cell_id = p_segment_id;

CURSOR c_segment_shipto (p_segment_id IN NUMBER) IS
   SELECT 1
   FROM  qp_ship_to_orgs_v
   WHERE organization_id = p_segment_id;

CURSOR c_segment_terr (p_segment_id IN NUMBER) IS
   SELECT 1
   FROM  jtf_terr_qtype_usgs jtqu, jtf_terr jt, jtf_qual_type_usgs jqtu
   WHERE ( TRUNC(jt.start_date_active) <= TRUNC(SYSDATE)
     AND ( TRUNC(jt.end_date_active) >= TRUNC(SYSDATE) OR jt.end_date_active IS NULL ))
     AND jt.terr_id = jtqu.terr_id
     AND jtqu.qual_type_usg_id = jqtu.qual_type_usg_id
     AND jqtu.source_id = -1003
     AND jqtu.qual_type_id = -1007
     AND jt.terr_id = p_segment_id;

BEGIN

   IF p_mode = 'CREATE' THEN
      p_mks_rec.activity_market_segment_id := NULL;
   ELSE
      --if activity market segment id is null, then raise exception
      IF (p_mks_rec.activity_market_segment_id = fnd_api.g_miss_num OR p_mks_rec.activity_market_segment_id IS NULL) THEN

         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
            fnd_message.set_name('OZF', 'OZF_NO_ACT_SEG_ID');
            fnd_msg_pub.add;
         END IF;
         x_return_status := fnd_api.g_ret_sts_error;
         RETURN;
      ELSE

         --check if the input activity_market_segment_id is valid
         OPEN c_act_mkt_exists (p_mks_rec.activity_market_segment_id);
         FETCH c_act_mkt_exists INTO l_act_mkt_exists;
         CLOSE c_act_mkt_exists;

         IF l_act_mkt_exists IS NULL THEN
            IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
               fnd_message.set_name('OZF', 'OZF_INVALID_ACT_SEG_ID');
               fnd_msg_pub.add;
            END IF;
            x_return_status := fnd_api.g_ret_sts_error;
            RETURN;
         END IF;
      END IF;
   END IF;

   IF p_mks_rec.act_market_segment_used_by_id = fnd_api.g_miss_num OR p_mks_rec.act_market_segment_used_by_id IS NULL THEN
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
         fnd_message.set_name('OZF', 'OZF_NO_MKT_SEG_USED_BY_ID');
         fnd_msg_pub.add;
      END IF;
      x_return_status := fnd_api.g_ret_sts_error;
      RETURN;
   ELSE

      OPEN c_segment_used_by_exists (p_mks_rec.act_market_segment_used_by_id);
      FETCH c_segment_used_by_exists INTO l_segment_used_by_exists;
      CLOSE c_segment_used_by_exists;

      IF l_segment_used_by_exists IS NULL THEN
         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
            fnd_message.set_name('OZF', 'OZF_INVALID_MKT_SEG_USED_BY_ID');
            fnd_msg_pub.add;
         END IF;
         x_return_status := fnd_api.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

   p_mks_rec.arc_act_market_segment_used_by := 'FUND';

   IF p_mks_rec.segment_type = fnd_api.g_miss_char OR p_mks_rec.segment_type IS NULL THEN
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
         fnd_message.set_name('OZF', 'OZF_NO_SEGMENT_TYPE');
         fnd_msg_pub.add;
      END IF;
      x_return_status := fnd_api.g_ret_sts_error;
      RETURN;
   ELSE

      OPEN c_segment_exists (p_mks_rec.segment_type);
      FETCH c_segment_exists INTO l_segment_exists;
      CLOSE c_segment_exists;

      IF l_segment_exists IS NULL THEN
         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
            fnd_message.set_name('OZF', 'OZF_INVALID_SEGMENT_TYPE');
            fnd_msg_pub.add;
         END IF;
         x_return_status := fnd_api.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

   IF p_mks_rec.market_segment_id = fnd_api.g_miss_num OR p_mks_rec.market_segment_id IS NULL THEN
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
         fnd_message.set_name('OZF', 'OZF_NO_MKT_SEG_ID');
         fnd_msg_pub.add;
      END IF;
      x_return_status := fnd_api.g_ret_sts_error;
      RETURN;
   ELSE

      IF p_mks_rec.segment_type = 'BUYER' THEN --Buying Group
         OPEN c_segment_buyer (p_mks_rec.market_segment_id);
         FETCH c_segment_buyer INTO l_segment_id_exists;
         CLOSE c_segment_buyer;
      ELSIF p_mks_rec.segment_type = 'CUSTOMER' THEN --Customer Name
         OPEN c_segment_cust (p_mks_rec.market_segment_id);
         FETCH c_segment_cust INTO l_segment_id_exists;
         CLOSE c_segment_cust;
      ELSIF p_mks_rec.segment_type = 'CUSTOMER_BILL_TO' THEN --Customer - Bill TO
         OPEN c_segment_billto (p_mks_rec.market_segment_id);
         FETCH c_segment_billto INTO l_segment_id_exists;
         CLOSE c_segment_billto;
      ELSIF p_mks_rec.segment_type = 'LIST' THEN --List
         OPEN c_segment_list (p_mks_rec.market_segment_id);
         FETCH c_segment_list INTO l_segment_id_exists;
         CLOSE c_segment_list;
      ELSIF p_mks_rec.segment_type = 'SEGMENT' THEN --Segment
         OPEN c_segment_seg (p_mks_rec.market_segment_id);
         FETCH c_segment_seg INTO l_segment_id_exists;
         CLOSE c_segment_seg;
      ELSIF p_mks_rec.segment_type = 'SHIP_TO' THEN --Customer - Ship TO
         OPEN c_segment_shipto (p_mks_rec.market_segment_id);
         FETCH c_segment_shipto INTO l_segment_id_exists;
         CLOSE c_segment_shipto;
      ELSIF p_mks_rec.segment_type = 'TERRITORY' THEN --Territories
         OPEN c_segment_terr (p_mks_rec.market_segment_id);
         FETCH c_segment_terr INTO l_segment_id_exists;
         CLOSE c_segment_terr;
      END IF;

      IF l_segment_id_exists IS NULL THEN
         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
            fnd_message.set_name('OZF', 'OZF_INVALID_MKT_SEG_ID');
            fnd_msg_pub.add;
         END IF;
         x_return_status := fnd_api.g_ret_sts_error;
         RETURN;
      END IF;

   END IF;

   p_mks_rec.exclude_flag := NVL(p_mks_rec.exclude_flag, 'N');

   IF p_mks_rec.exclude_flag NOT IN ('Y', 'N') THEN
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
         fnd_message.set_name('OZF', 'OZF_INVALID_EXCLUDE_FLAG');
         fnd_msg_pub.add;
      END IF;
      x_return_status := fnd_api.g_ret_sts_error;
      RETURN;
   END IF;

END validate_market_segment;

---------------------------------------------------------------------
-- PROCEDURE
--    create_market_segment
--
-- PURPOSE
--    Creates a market segment for fund.
--
-- PARAMETERS
--    p_mks_rec    : the record with new items.
--    x_act_mks_id : return the market segment id for the fund
--
-- HISTORY
--    07/07/2005  kdass Created
----------------------------------------------------------------------
PROCEDURE create_market_segment(
   p_api_version        IN         NUMBER
  ,p_init_msg_list      IN         VARCHAR2 := fnd_api.g_false
  ,p_commit             IN         VARCHAR2 := fnd_api.g_false
  ,p_validation_level   IN         NUMBER := fnd_api.g_valid_level_full
  ,p_mks_rec            IN         mks_rec_type
  ,x_return_status      OUT NOCOPY VARCHAR2
  ,x_msg_count          OUT NOCOPY NUMBER
  ,x_msg_data           OUT NOCOPY VARCHAR2
  ,x_act_mks_id         OUT NOCOPY NUMBER)
IS
l_api_name         VARCHAR(30) := 'create_market_segment';
l_mode             VARCHAR2(6) := 'CREATE';
l_mks_rec          mks_rec_type := p_mks_rec;
l_seg_rec          ams_act_market_segments_pvt.mks_rec_type;
l_api_version      NUMBER := p_api_version;
l_init_msg_list    VARCHAR2(100) := p_init_msg_list;
l_validation_level NUMBER := p_validation_level;
l_commit           VARCHAR2(1) := p_commit;

BEGIN

   SAVEPOINT create_market_pub;

   validate_market_segment(p_mks_rec       => l_mks_rec
                          ,p_mode          => l_mode
                          ,x_return_status => x_return_status);

   IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
      RAISE fnd_api.g_exc_unexpected_error;
   ELSIF x_return_status = fnd_api.g_ret_sts_error THEN
      RAISE fnd_api.g_exc_error;
   END IF;

   l_seg_rec.market_segment_id := l_mks_rec.market_segment_id;
   l_seg_rec.act_market_segment_used_by_id := l_mks_rec.act_market_segment_used_by_id;
   l_seg_rec.arc_act_market_segment_used_by := l_mks_rec.arc_act_market_segment_used_by;
   l_seg_rec.segment_type := l_mks_rec.segment_type;
   l_seg_rec.object_version_number := l_mks_rec.object_version_number;
   l_seg_rec.exclude_flag := l_mks_rec.exclude_flag;

   ams_act_market_segments_pvt.create_market_segments(p_api_version      => l_api_version
                                                     ,p_init_msg_list    => l_init_msg_list
                                                     ,p_commit           => l_commit
                                                     ,p_validation_level => l_validation_level
                                                     ,p_mks_rec          => l_seg_rec
                                                     ,x_return_status    => x_return_status
                                                     ,x_msg_count        => x_msg_count
                                                     ,x_msg_data         => x_msg_data
                                                     ,x_act_mks_id       => x_act_mks_id
                                                     );

  IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
     RAISE fnd_api.g_exc_unexpected_error;
  ELSIF x_return_status = fnd_api.g_ret_sts_error THEN
     RAISE fnd_api.g_exc_error;
  END IF;

  FND_MSG_PUB.Count_And_Get (
    p_encoded => FND_API.G_FALSE,
    p_count   => x_msg_count,
    p_data    => x_msg_data
   );

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
   ROLLBACK TO create_market_pub;
   x_return_status := FND_API.G_RET_STS_ERROR;
   -- Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get (
   p_encoded => FND_API.G_FALSE,
   p_count   => x_msg_count,
   p_data    => x_msg_data
   );
WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   ROLLBACK TO create_market_pub;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   -- Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get (
   p_encoded => FND_API.G_FALSE,
   p_count   => x_msg_count,
   p_data    => x_msg_data
   );
WHEN OTHERS THEN
   ROLLBACK TO create_market_pub;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
   THEN
      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
   END IF;
   -- Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get (
   p_encoded => FND_API.G_FALSE,
   p_count   => x_msg_count,
   p_data    => x_msg_data
   );
END create_market_segment;

---------------------------------------------------------------------
-- PROCEDURE
--    update_market_segment
--
-- PURPOSE
--    Updates a market segment for fund.
--
-- PARAMETERS
--    p_mks_rec : the record with items to be updated.
--
-- HISTORY
--    07/07/2005  kdass Created
----------------------------------------------------------------------
PROCEDURE update_market_segment(
   p_api_version        IN         NUMBER
  ,p_init_msg_list      IN         VARCHAR2 := fnd_api.g_false
  ,p_commit             IN         VARCHAR2 := fnd_api.g_false
  ,p_validation_level   IN         NUMBER := fnd_api.g_valid_level_full
  ,p_mks_rec            IN         mks_rec_type
  ,x_return_status      OUT NOCOPY VARCHAR2
  ,x_msg_count          OUT NOCOPY NUMBER
  ,x_msg_data           OUT NOCOPY VARCHAR2)
IS
l_api_name           VARCHAR(30) := 'update_market_segment';
l_mode               VARCHAR2(6) := 'UPDATE';
l_mks_rec            mks_rec_type := p_mks_rec;
l_seg_rec            ams_act_market_segments_pvt.mks_rec_type;
l_api_version        NUMBER := p_api_version;
l_init_msg_list      VARCHAR2(100) := p_init_msg_list;
l_validation_level   NUMBER := p_validation_level;
l_commit             VARCHAR2(1) := p_commit;
l_mkt_seg_used_by_id NUMBER;
l_segment_type       VARCHAR2(30);
l_mkt_seg_id         NUMBER;
l_object_version     NUMBER;
l_exclude_flag       VARCHAR2(1);

CURSOR c_mkt_seg_details (p_act_mkt_seg_id IN NUMBER) IS
   SELECT act_market_segment_used_by_id, segment_type, market_segment_id,
          object_version_number, exclude_flag
   FROM  ams_act_market_segments
   WHERE activity_market_segment_id = p_act_mkt_seg_id;

BEGIN

   SAVEPOINT update_market_pub;

   IF l_mks_rec.activity_market_segment_id IS NOT NULL THEN
      OPEN c_mkt_seg_details (l_mks_rec.activity_market_segment_id);
      FETCH c_mkt_seg_details INTO l_mkt_seg_used_by_id, l_segment_type, l_mkt_seg_id, l_object_version, l_exclude_flag;
      CLOSE c_mkt_seg_details;
   END IF;

   l_mks_rec.act_market_segment_used_by_id :=  NVL(l_mks_rec.act_market_segment_used_by_id,l_mkt_seg_used_by_id);
   l_mks_rec.segment_type :=  NVL(l_mks_rec.segment_type,l_segment_type);
   l_mks_rec.market_segment_id := NVL(l_mks_rec.market_segment_id, l_mkt_seg_id);
   l_mks_rec.object_version_number := l_object_version;
   l_mks_rec.exclude_flag :=  NVL(l_mks_rec.exclude_flag,l_exclude_flag);

   validate_market_segment(p_mks_rec       => l_mks_rec
                          ,p_mode          => l_mode
                          ,x_return_status => x_return_status);

   IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
      RAISE fnd_api.g_exc_unexpected_error;
   ELSIF x_return_status = fnd_api.g_ret_sts_error THEN
      RAISE fnd_api.g_exc_error;
   END IF;

   l_seg_rec.activity_market_segment_id := l_mks_rec.activity_market_segment_id;
   l_seg_rec.act_market_segment_used_by_id := l_mks_rec.act_market_segment_used_by_id;
   l_seg_rec.arc_act_market_segment_used_by := l_mks_rec.arc_act_market_segment_used_by;
   l_seg_rec.segment_type := l_mks_rec.segment_type;
   l_seg_rec.market_segment_id := l_mks_rec.market_segment_id;
   l_seg_rec.object_version_number := l_mks_rec.object_version_number;
   l_seg_rec.exclude_flag := l_mks_rec.exclude_flag;

   ams_act_market_segments_pvt.update_market_segments(p_api_version      => l_api_version
                                                     ,p_init_msg_list    => l_init_msg_list
                                                     ,p_commit           => l_commit
                                                     ,p_validation_level => l_validation_level
                                                     ,p_mks_rec          => l_seg_rec
                                                     ,x_return_status    => x_return_status
                                                     ,x_msg_count        => x_msg_count
                                                     ,x_msg_data         => x_msg_data
                                                     );

   IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
      RAISE fnd_api.g_exc_unexpected_error;
   ELSIF x_return_status = fnd_api.g_ret_sts_error THEN
      RAISE fnd_api.g_exc_error;
   END IF;

   FND_MSG_PUB.Count_And_Get (
    p_encoded => FND_API.G_FALSE,
    p_count   => x_msg_count,
    p_data    => x_msg_data
   );

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
   ROLLBACK TO update_market_pub;
   x_return_status := FND_API.G_RET_STS_ERROR;
   -- Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get (
   p_encoded => FND_API.G_FALSE,
   p_count   => x_msg_count,
   p_data    => x_msg_data
   );
WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   ROLLBACK TO update_market_pub;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   -- Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get (
   p_encoded => FND_API.G_FALSE,
   p_count   => x_msg_count,
   p_data    => x_msg_data
   );
WHEN OTHERS THEN
   ROLLBACK TO update_market_pub;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
   THEN
      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
   END IF;
   -- Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get (
   p_encoded => FND_API.G_FALSE,
   p_count   => x_msg_count,
   p_data    => x_msg_data
   );
END update_market_segment;

---------------------------------------------------------------------
-- PROCEDURE
--    delete_market_segment
--
-- PURPOSE
--    Deletes a market segment for fund.
--
-- PARAMETERS
--    p_act_mks_id : the market segment to be deleted
--
-- HISTORY
--    07/07/2005  kdass Created
----------------------------------------------------------------------
/**
 * This procedure deletes a market segment for an existing fund.
 * @param p_api_version      Indicates the version of the API
 * @param p_init_msg_list    Indicates whether to initialize the message stack
 * @param p_commit           Indicates whether to commit within the program
 * @param p_act_mks_id       Market segment identifier of the market segment to be deleted
 * @param x_return_status    Status of the program
 * @param x_msg_count        Number of the messages returned by the program
 * @param x_msg_data         Return message by the program
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Delete Market Segment
 * @rep:compatibility S
 * @rep:businessevent None
 */
PROCEDURE delete_market_segment(
   p_api_version        IN         NUMBER
  ,p_init_msg_list      IN         VARCHAR2 := fnd_api.g_false
  ,p_commit             IN         VARCHAR2 := fnd_api.g_false
  ,p_act_mks_id         IN         NUMBER
  ,x_return_status      OUT NOCOPY VARCHAR2
  ,x_msg_count          OUT NOCOPY NUMBER
  ,x_msg_data           OUT NOCOPY VARCHAR2)
IS
l_api_name       VARCHAR(30) := 'delete_market_segment';
l_api_version    NUMBER := p_api_version;
l_init_msg_list  VARCHAR2(100) := p_init_msg_list;
l_commit         VARCHAR2(1) := p_commit;
l_object_version NUMBER := NULL;

CURSOR c_valid_act_mks_id IS
   SELECT object_version_number
   FROM  ams_act_market_segments
   WHERE activity_market_segment_id = p_act_mks_id;

BEGIN

   SAVEPOINT delete_market_pub;

   --if activity market segment id is null, then raise exception
   IF (p_act_mks_id = fnd_api.g_miss_num OR p_act_mks_id IS NULL) THEN

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
         fnd_message.set_name('OZF', 'OZF_NO_ACT_SEG_ID');
         fnd_msg_pub.add;
      END IF;
      RAISE fnd_api.g_exc_error;
   END IF;

   --check if the activity market segment id is valid and get the object_version_number
   OPEN c_valid_act_mks_id;
   FETCH c_valid_act_mks_id INTO l_object_version;
   CLOSE c_valid_act_mks_id;

   IF l_object_version IS NULL THEN
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
         fnd_message.set_name('OZF', 'OZF_INVALID_ACT_SEG_ID');
         fnd_msg_pub.add;
      END IF;
      RAISE fnd_api.g_exc_error;
   END IF;

   --delete market segment
   ams_act_market_segments_pvt.delete_market_segments(p_api_version    => l_api_version
                                                     ,p_init_msg_list  => l_init_msg_list
                                                     ,p_commit         => l_commit
                                                     ,p_act_mks_id     => p_act_mks_id
                                                     ,p_object_version => l_object_version
                                                     ,x_return_status  => x_return_status
                                                     ,x_msg_count      => x_msg_count
                                                     ,x_msg_data       => x_msg_data
                                                     );

  IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
     RAISE fnd_api.g_exc_unexpected_error;
  ELSIF x_return_status = fnd_api.g_ret_sts_error THEN
     RAISE fnd_api.g_exc_error;
  END IF;

  FND_MSG_PUB.Count_And_Get (
    p_encoded => FND_API.G_FALSE,
    p_count   => x_msg_count,
    p_data    => x_msg_data
   );

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
   ROLLBACK TO delete_market_pub;
   x_return_status := FND_API.G_RET_STS_ERROR;
   -- Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get (
   p_encoded => FND_API.G_FALSE,
   p_count   => x_msg_count,
   p_data    => x_msg_data
   );
WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   ROLLBACK TO delete_market_pub;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   -- Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get (
   p_encoded => FND_API.G_FALSE,
   p_count   => x_msg_count,
   p_data    => x_msg_data
   );
WHEN OTHERS THEN
   ROLLBACK TO delete_market_pub;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
   THEN
      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
   END IF;
   -- Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get (
   p_encoded => FND_API.G_FALSE,
   p_count   => x_msg_count,
   p_data    => x_msg_data
   );
END delete_market_segment;

---------------------------------------------------------------------
-- PROCEDURE
--    validate_act_product
--
-- PURPOSE
--    Validate product eligibility record
--
-- PARAMETERS
--    p_mks_rec: product eligibility record to be validated
--    x_return_status: return status
--
-- HISTORY
--    06/29/2005  kdass Created
---------------------------------------------------------------------
PROCEDURE validate_act_product (
   p_act_product_rec    IN OUT NOCOPY   act_product_rec_type
  ,p_mode               IN              VARCHAR2
  ,x_return_status      OUT NOCOPY      VARCHAR2
  )
IS
l_api_name                VARCHAR(30) := 'validate_act_product';
l_act_prod_exists         NUMBER := NULL;
l_act_prod_used_by_exists NUMBER := NULL;
l_inv_id_exists           NUMBER := NULL;

CURSOR c_act_prod_exists (p_activity_product_id IN NUMBER) IS
   SELECT 1
   FROM  ams_act_products
   WHERE activity_product_id = p_activity_product_id;

CURSOR c_act_prod_used_by_exists (p_prod_used_by IN NUMBER) IS
   SELECT 1
   FROM  ozf_funds_all_b
   WHERE fund_id = p_prod_used_by;

CURSOR c_org_id (p_prod_used_by IN NUMBER) IS
   SELECT org_id
   FROM  ozf_funds_all_b
   WHERE fund_id = p_prod_used_by;

CURSOR c_inv_id_exists (p_inventory_id IN NUMBER, p_org_id IN NUMBER) IS
   SELECT 1
   FROM mtl_system_items_b_kfv
   WHERE organization_id = p_org_id
   AND inventory_item_id = p_inventory_id;

CURSOR c_inv_name_exists (p_inventory_name IN VARCHAR2, p_org_id IN NUMBER) IS
   SELECT inventory_item_id
   FROM mtl_system_items_b_kfv
   WHERE organization_id = p_org_id
   AND concatenated_segments = p_inventory_name;

CURSOR c_cat_id_exists (p_category_id IN NUMBER) IS
   SELECT category_set_id
   FROM ENI_PROD_DEN_HRCHY_PARENTS_V
   WHERE category_id = p_category_id;

--08-MAY-2006 kdass bug 5199585 SQL ID# 17778264 - added last condition so that table uses index
CURSOR c_cat_name_exists (p_category_name IN VARCHAR2) IS
   SELECT category_id, category_set_id
   FROM ENI_PROD_DEN_HRCHY_PARENTS_V
   WHERE category_desc = p_category_name
   AND NVL(category_id, 0) = category_id;

BEGIN

   IF p_mode = 'CREATE' THEN
      p_act_product_rec.activity_product_id := NULL;
   ELSE
      --if activity product id is null, then raise exception
      IF (p_act_product_rec.activity_product_id = fnd_api.g_miss_num OR p_act_product_rec.activity_product_id IS NULL) THEN

         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
            fnd_message.set_name('OZF', 'OZF_NO_ACT_PROD_ID');
            fnd_msg_pub.add;
         END IF;
         x_return_status := fnd_api.g_ret_sts_error;
         RETURN;
      ELSE

         --check if the input activity_product_id is valid
         OPEN c_act_prod_exists (p_act_product_rec.activity_product_id);
         FETCH c_act_prod_exists INTO l_act_prod_exists;
         CLOSE c_act_prod_exists;

         IF l_act_prod_exists IS NULL THEN
            IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
               fnd_message.set_name('OZF', 'OZF_INVALID_ACT_PROD_ID');
               fnd_msg_pub.add;
            END IF;
            x_return_status := fnd_api.g_ret_sts_error;
            RETURN;
         END IF;
      END IF;
   END IF;

   IF p_act_product_rec.act_product_used_by_id = fnd_api.g_miss_num OR p_act_product_rec.act_product_used_by_id IS NULL THEN
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
         fnd_message.set_name('OZF', 'OZF_NO_PROD_USED_BY');
         fnd_msg_pub.add;
      END IF;
      x_return_status := fnd_api.g_ret_sts_error;
      RETURN;
   ELSE

      OPEN c_act_prod_used_by_exists (p_act_product_rec.act_product_used_by_id);
      FETCH c_act_prod_used_by_exists INTO l_act_prod_used_by_exists;
      CLOSE c_act_prod_used_by_exists;

      IF l_act_prod_used_by_exists IS NULL THEN
         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
            fnd_message.set_name('OZF', 'OZF_INVALID_PROD_USED_BY');
            fnd_msg_pub.add;
         END IF;
         x_return_status := fnd_api.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

   --if both inventory item id and inventory item name are null, then raise exception
   IF (p_act_product_rec.inventory_item_id = fnd_api.g_miss_num OR p_act_product_rec.inventory_item_id IS NULL) AND
      (p_act_product_rec.inventory_item_name = fnd_api.g_miss_char OR p_act_product_rec.inventory_item_name IS NULL) AND
      (p_act_product_rec.category_id = fnd_api.g_miss_num OR p_act_product_rec.category_id IS NULL) AND
      (p_act_product_rec.category_name = fnd_api.g_miss_char OR p_act_product_rec.category_name IS NULL) THEN

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
         fnd_message.set_name('OZF', 'OZF_NO_INV_ITEM_CAT');
         fnd_msg_pub.add;
      END IF;
      x_return_status := fnd_api.g_ret_sts_error;
      RETURN;

   ELSIF (p_act_product_rec.inventory_item_id <> fnd_api.g_miss_num AND p_act_product_rec.inventory_item_id IS NOT NULL) OR
         (p_act_product_rec.inventory_item_name <> fnd_api.g_miss_char AND p_act_product_rec.inventory_item_name IS NOT NULL) THEN

      OPEN c_org_id (p_act_product_rec.act_product_used_by_id);
      FETCH c_org_id INTO p_act_product_rec.organization_id;
      CLOSE c_org_id;

      --if inventory item id is not null
      IF p_act_product_rec.inventory_item_id <> fnd_api.g_miss_num AND p_act_product_rec.inventory_item_id IS NOT NULL THEN

         --check if the input inventory_item_id valid
         OPEN c_inv_id_exists (p_act_product_rec.inventory_item_id, p_act_product_rec.organization_id);
         FETCH c_inv_id_exists INTO l_inv_id_exists;
         CLOSE c_inv_id_exists;

         IF l_inv_id_exists IS NULL THEN
            IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
               fnd_message.set_name('OZF', 'OZF_INVALID_INV_ITEM_ID');
               fnd_msg_pub.add;
            END IF;
            x_return_status := fnd_api.g_ret_sts_error;
            RETURN;
         END IF;

      --if inventory item name is not null
      ELSE
         --check if the input inventory item name is valid
         OPEN c_inv_name_exists (p_act_product_rec.inventory_item_name, p_act_product_rec.organization_id);
         FETCH c_inv_name_exists INTO p_act_product_rec.inventory_item_id;
         CLOSE c_inv_name_exists;

         IF p_act_product_rec.inventory_item_id IS NULL THEN
            IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
               fnd_message.set_name('OZF', 'OZF_INVALID_INV_ITEM_NAME');
               fnd_msg_pub.add;
            END IF;
            x_return_status := fnd_api.g_ret_sts_error;
            RETURN;
         END IF;
      END IF;

      p_act_product_rec.level_type_code := 'PRODUCT';

   ELSIF (p_act_product_rec.category_id <> fnd_api.g_miss_num AND p_act_product_rec.category_id IS NOT NULL) OR
         (p_act_product_rec.category_name <> fnd_api.g_miss_char AND p_act_product_rec.category_name IS NOT NULL) THEN

      --if category id is not null
      IF p_act_product_rec.category_id <> fnd_api.g_miss_num AND p_act_product_rec.category_id IS NOT NULL THEN

         --check if the input category_id valid
         OPEN c_cat_id_exists (p_act_product_rec.category_id);
         FETCH c_cat_id_exists INTO p_act_product_rec.category_set_id;
         CLOSE c_cat_id_exists;

         IF p_act_product_rec.category_set_id IS NULL THEN
            IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
               fnd_message.set_name('OZF', 'OZF_INVALID_CATEGORY_ID');
               fnd_msg_pub.add;
            END IF;
            x_return_status := fnd_api.g_ret_sts_error;
            RETURN;
         END IF;

      --if category name is not null
      ELSE
         --check if the input category name is valid
         OPEN c_cat_name_exists (p_act_product_rec.category_name);
         FETCH c_cat_name_exists INTO p_act_product_rec.category_id, p_act_product_rec.category_set_id;
         CLOSE c_cat_name_exists;

         IF p_act_product_rec.category_id IS NULL THEN
            IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
               fnd_message.set_name('OZF', 'OZF_INVALID_CATEGORY_NAME');
               fnd_msg_pub.add;
            END IF;
            x_return_status := fnd_api.g_ret_sts_error;
            RETURN;
         END IF;
      END IF;

      p_act_product_rec.level_type_code := 'FAMILY';

   END IF;

   p_act_product_rec.arc_act_product_used_by := 'FUND';

   p_act_product_rec.primary_product_flag := NVL(p_act_product_rec.primary_product_flag, 'N');

   IF p_act_product_rec.primary_product_flag NOT IN ('Y', 'N') THEN
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
         fnd_message.set_name('OZF', 'OZF_INVALID_PRIMARY_FLAG');
         fnd_msg_pub.add;
      END IF;
      x_return_status := fnd_api.g_ret_sts_error;
      RETURN;
   END IF;

   p_act_product_rec.excluded_flag := NVL(p_act_product_rec.excluded_flag, 'N');

   IF p_act_product_rec.excluded_flag NOT IN ('Y', 'N') THEN
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
         fnd_message.set_name('OZF', 'OZF_INVALID_EXCLUDED_FLAG');
         fnd_msg_pub.add;
      END IF;
      x_return_status := fnd_api.g_ret_sts_error;
      RETURN;
   END IF;

END validate_act_product;

----------------------------------------------------------------------
-- PROCEDURE
--    create_product_eligibility
--
-- PURPOSE
--    Creates the product eligibility record for fund or quota.
--
-- PARAMETERS
--    p_act_product_rec : the record with new items
--    x_act_product_id  : return the activity product id for the fund or quota
--
-- HISTORY
--    07/11/2005  kdass Created
----------------------------------------------------------------------
PROCEDURE create_product_eligibility(
   p_api_version        IN         NUMBER
  ,p_init_msg_list      IN         VARCHAR2 := fnd_api.g_false
  ,p_commit             IN         VARCHAR2 := fnd_api.g_false
  ,p_validation_level   IN         NUMBER := fnd_api.g_valid_level_full
  ,p_act_product_rec    IN         act_product_rec_type
  ,x_return_status      OUT NOCOPY VARCHAR2
  ,x_msg_count          OUT NOCOPY NUMBER
  ,x_msg_data           OUT NOCOPY VARCHAR2
  ,x_act_product_id     OUT NOCOPY NUMBER
  )
IS
l_api_name         VARCHAR(30) := 'create_product_eligibility';
l_mode             VARCHAR2(6) := 'CREATE';
l_act_prod_rec     act_product_rec_type := p_act_product_rec;
l_act_product_rec  ams_actproduct_pvt.act_product_rec_type;
l_api_version      NUMBER := p_api_version;
l_init_msg_list    VARCHAR2(100) := p_init_msg_list;
l_validation_level NUMBER := p_validation_level;
l_commit           VARCHAR2(1) := p_commit;

BEGIN

   SAVEPOINT create_product_pub;

   validate_act_product(p_act_product_rec => l_act_prod_rec
                       ,p_mode            => l_mode
                       ,x_return_status   => x_return_status);

   IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
      RAISE fnd_api.g_exc_unexpected_error;
   ELSIF x_return_status = fnd_api.g_ret_sts_error THEN
      RAISE fnd_api.g_exc_error;
   END IF;

   l_act_product_rec.act_product_used_by_id := l_act_prod_rec.act_product_used_by_id;
   l_act_product_rec.arc_act_product_used_by := l_act_prod_rec.arc_act_product_used_by;
   l_act_product_rec.inventory_item_id := l_act_prod_rec.inventory_item_id;
   l_act_product_rec.level_type_code := l_act_prod_rec.level_type_code;
   l_act_product_rec.category_id := l_act_prod_rec.category_id;
   l_act_product_rec.category_set_id  := l_act_prod_rec.category_set_id;
   l_act_product_rec.primary_product_flag  := l_act_prod_rec.primary_product_flag;
   l_act_product_rec.excluded_flag  := l_act_prod_rec.excluded_flag;
   l_act_product_rec.organization_id := l_act_prod_rec.organization_id;

   ams_actproduct_pvt.create_act_product(p_api_version      => l_api_version
                                        ,p_init_msg_list    => l_init_msg_list
                                        ,p_commit           => l_commit
                                        ,p_validation_level => l_validation_level
                                        ,p_act_product_rec  => l_act_product_rec
                                        ,x_return_status    => x_return_status
                                        ,x_msg_count        => x_msg_count
                                        ,x_msg_data         => x_msg_data
                                        ,x_act_product_id   => x_act_product_id
                                        );

  IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
     RAISE fnd_api.g_exc_unexpected_error;
  ELSIF x_return_status = fnd_api.g_ret_sts_error THEN
     RAISE fnd_api.g_exc_error;
  END IF;

  FND_MSG_PUB.Count_And_Get (
    p_encoded => FND_API.G_FALSE,
    p_count   => x_msg_count,
    p_data    => x_msg_data
   );

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
   ROLLBACK TO create_product_pub;
   x_return_status := FND_API.G_RET_STS_ERROR;
   -- Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get (
   p_encoded => FND_API.G_FALSE,
   p_count   => x_msg_count,
   p_data    => x_msg_data
   );
WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   ROLLBACK TO create_product_pub;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   -- Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get (
   p_encoded => FND_API.G_FALSE,
   p_count   => x_msg_count,
   p_data    => x_msg_data
   );
WHEN OTHERS THEN
   ROLLBACK TO create_product_pub;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
   THEN
      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
   END IF;
   -- Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get (
   p_encoded => FND_API.G_FALSE,
   p_count   => x_msg_count,
   p_data    => x_msg_data
   );
END create_product_eligibility;

---------------------------------------------------------------------
-- PROCEDURE
--    update_product_eligibility
--
-- PURPOSE
--    Updates the product eligibility record for fund or quota.
--
-- PARAMETERS
--    p_act_product_rec : the record with items to be updated
--
-- HISTORY
--    07/11/2005  kdass Created
----------------------------------------------------------------------
PROCEDURE update_product_eligibility(
   p_api_version        IN         NUMBER
  ,p_init_msg_list      IN         VARCHAR2 := fnd_api.g_false
  ,p_commit             IN         VARCHAR2 := fnd_api.g_false
  ,p_validation_level   IN         NUMBER := fnd_api.g_valid_level_full
  ,p_act_product_rec    IN         act_product_rec_type
  ,x_return_status      OUT NOCOPY VARCHAR2
  ,x_msg_count          OUT NOCOPY NUMBER
  ,x_msg_data           OUT NOCOPY VARCHAR2
  )
IS
l_api_name         VARCHAR(30) := 'update_product_eligibility';
l_mode             VARCHAR2(6) := 'UPDATE';
l_act_prod_rec     act_product_rec_type := p_act_product_rec;
l_act_product_rec  ams_actproduct_pvt.act_product_rec_type;
l_api_version      NUMBER := p_api_version;
l_init_msg_list    VARCHAR2(100) := p_init_msg_list;
l_validation_level NUMBER := p_validation_level;
l_commit           VARCHAR2(1) := p_commit;
l_prod_used_by_id  NUMBER;
l_item_id          NUMBER;
l_cat_id           NUMBER;
l_cat_set_id       NUMBER;
l_primary_flag     VARCHAR2(1);
l_excluded_flag    VARCHAR2(1);
l_obj_ver          NUMBER;

CURSOR c_prod_elig_details (p_act_prod_id IN NUMBER) IS
   SELECT act_product_used_by_id, inventory_item_id, category_id, category_set_id,
          primary_product_flag, excluded_flag, object_version_number
   FROM  ams_act_products
   WHERE activity_product_id = p_act_prod_id;

BEGIN

   SAVEPOINT update_product_pub;

   IF l_act_prod_rec.activity_product_id IS NOT NULL THEN
      OPEN c_prod_elig_details (l_act_prod_rec.activity_product_id);
      FETCH c_prod_elig_details INTO l_prod_used_by_id, l_item_id, l_cat_id, l_cat_set_id,
            l_primary_flag, l_excluded_flag, l_obj_ver;
      CLOSE c_prod_elig_details;
   END IF;

   l_act_prod_rec.act_product_used_by_id := NVL(l_act_prod_rec.act_product_used_by_id,l_prod_used_by_id);
   l_act_prod_rec.inventory_item_id := NVL(l_act_prod_rec.inventory_item_id,l_item_id);
   l_act_prod_rec.category_id := NVL(l_act_prod_rec.category_id,l_cat_id);
   l_act_prod_rec.category_set_id  := NVL(l_act_prod_rec.category_set_id,l_cat_set_id);
   l_act_prod_rec.primary_product_flag  := NVL(l_act_prod_rec.primary_product_flag,l_primary_flag);
   l_act_prod_rec.excluded_flag  := NVL(l_act_prod_rec.excluded_flag,l_excluded_flag);
   l_act_prod_rec.object_version_number := NVL(l_act_prod_rec.object_version_number,l_obj_ver);

   validate_act_product(p_act_product_rec => l_act_prod_rec
                       ,p_mode            => l_mode
                       ,x_return_status   => x_return_status);

   IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
      RAISE fnd_api.g_exc_unexpected_error;
   ELSIF x_return_status = fnd_api.g_ret_sts_error THEN
      RAISE fnd_api.g_exc_error;
   END IF;

   l_act_product_rec.activity_product_id := l_act_prod_rec.activity_product_id;
   l_act_product_rec.act_product_used_by_id := l_act_prod_rec.act_product_used_by_id;
   l_act_product_rec.arc_act_product_used_by := l_act_prod_rec.arc_act_product_used_by;
   l_act_product_rec.inventory_item_id := l_act_prod_rec.inventory_item_id;
   l_act_product_rec.level_type_code := l_act_prod_rec.level_type_code;
   l_act_product_rec.category_id := l_act_prod_rec.category_id;
   l_act_product_rec.category_set_id  := l_act_prod_rec.category_set_id;
   l_act_product_rec.primary_product_flag  := l_act_prod_rec.primary_product_flag;
   l_act_product_rec.excluded_flag  := l_act_prod_rec.excluded_flag;
   l_act_product_rec.organization_id := l_act_prod_rec.organization_id;
   l_act_product_rec.object_version_number := l_act_prod_rec.object_version_number;
   l_act_product_rec.enabled_flag := 'Y';

   ams_actproduct_pvt.update_act_product(p_api_version      => l_api_version
                                        ,p_init_msg_list    => l_init_msg_list
                                        ,p_commit           => l_commit
                                        ,p_validation_level => l_validation_level
                                        ,p_act_product_rec  => l_act_product_rec
                                        ,x_return_status    => x_return_status
                                        ,x_msg_count        => x_msg_count
                                        ,x_msg_data         => x_msg_data
                                        );

  IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
     RAISE fnd_api.g_exc_unexpected_error;
  ELSIF x_return_status = fnd_api.g_ret_sts_error THEN
     RAISE fnd_api.g_exc_error;
  END IF;

  FND_MSG_PUB.Count_And_Get (
    p_encoded => FND_API.G_FALSE,
    p_count   => x_msg_count,
    p_data    => x_msg_data
   );

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
   ROLLBACK TO update_product_pub;
   x_return_status := FND_API.G_RET_STS_ERROR;
   -- Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get (
   p_encoded => FND_API.G_FALSE,
   p_count   => x_msg_count,
   p_data    => x_msg_data
   );
WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   ROLLBACK TO update_product_pub;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   -- Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get (
   p_encoded => FND_API.G_FALSE,
   p_count   => x_msg_count,
   p_data    => x_msg_data
   );
WHEN OTHERS THEN
   ROLLBACK TO update_product_pub;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
   THEN
      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
   END IF;
   -- Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get (
   p_encoded => FND_API.G_FALSE,
   p_count   => x_msg_count,
   p_data    => x_msg_data
   );
END update_product_eligibility;

---------------------------------------------------------------------
-- PROCEDURE
--    delete_product_eligibility
--
-- PURPOSE
--    Deletes the product eligibility record for fund or quota.
--
-- PARAMETERS
--    p_act_product_id : the product eligibility to be deleted
--
-- HISTORY
--    07/11/2005  kdass Created
----------------------------------------------------------------------
PROCEDURE delete_product_eligibility(
   p_api_version        IN         NUMBER
  ,p_init_msg_list      IN         VARCHAR2 := fnd_api.g_false
  ,p_commit             IN         VARCHAR2 := fnd_api.g_false
  ,p_act_product_id     IN         NUMBER
  ,x_return_status      OUT NOCOPY VARCHAR2
  ,x_msg_count          OUT NOCOPY NUMBER
  ,x_msg_data           OUT NOCOPY VARCHAR2
  )
IS
l_api_name       VARCHAR(30) := 'delete_product_eligibility';
l_api_version    NUMBER := p_api_version;
l_init_msg_list  VARCHAR2(100) := p_init_msg_list;
l_commit         VARCHAR2(1) := p_commit;
l_object_version NUMBER := NULL;

CURSOR c_valid_act_prod_id IS
   SELECT object_version_number
   FROM  ams_act_products
   WHERE activity_product_id = p_act_product_id;

BEGIN

   SAVEPOINT delete_product_pub;

   --if activity market segment id is null, then raise exception
   IF (p_act_product_id = fnd_api.g_miss_num OR p_act_product_id IS NULL) THEN

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
         fnd_message.set_name('OZF', 'OZF_NO_ACT_PROD_ID');
         fnd_msg_pub.add;
      END IF;
      RAISE fnd_api.g_exc_error;
   END IF;

   --check if the activity product id is valid and get the object_version_number
   OPEN c_valid_act_prod_id;
   FETCH c_valid_act_prod_id INTO l_object_version;
   CLOSE c_valid_act_prod_id;

   IF l_object_version IS NULL THEN
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
         fnd_message.set_name('OZF', 'OZF_INVALID_ACT_PROD_ID');
         fnd_msg_pub.add;
      END IF;
      RAISE fnd_api.g_exc_error;
   END IF;

   --delete product eligibility record
   ams_actproduct_pvt.delete_act_product(p_api_version    => l_api_version
                                        ,p_init_msg_list  => l_init_msg_list
                                        ,p_commit         => l_commit
                                        ,p_act_product_id => p_act_product_id
                                        ,p_object_version => l_object_version
                                        ,x_return_status  => x_return_status
                                        ,x_msg_count      => x_msg_count
                                        ,x_msg_data       => x_msg_data
                                        );

  IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
     RAISE fnd_api.g_exc_unexpected_error;
  ELSIF x_return_status = fnd_api.g_ret_sts_error THEN
     RAISE fnd_api.g_exc_error;
  END IF;

  FND_MSG_PUB.Count_And_Get (
    p_encoded => FND_API.G_FALSE,
    p_count   => x_msg_count,
    p_data    => x_msg_data
   );

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
   ROLLBACK TO delete_product_pub;
   x_return_status := FND_API.G_RET_STS_ERROR;
   -- Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get (
   p_encoded => FND_API.G_FALSE,
   p_count   => x_msg_count,
   p_data    => x_msg_data
   );
WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   ROLLBACK TO delete_product_pub;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   -- Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get (
   p_encoded => FND_API.G_FALSE,
   p_count   => x_msg_count,
   p_data    => x_msg_data
   );
WHEN OTHERS THEN
   ROLLBACK TO delete_product_pub;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
   THEN
      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
   END IF;
   -- Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get (
   p_encoded => FND_API.G_FALSE,
   p_count   => x_msg_count,
   p_data    => x_msg_data
   );
END delete_product_eligibility;

/*kdass - funds accrual process by business event descoped due to performance issues.
  added back by feliu since calling API don't descope. */
PROCEDURE increase_order_message_counter
IS
   BEGIN
     SAVEPOINT increase_order_message_counter;

    --  ozf_accrual_engine.increase_order_message_counter;

   EXCEPTION
      WHEN OTHERS THEN
         ROLLBACK TO increase_order_message_counter;
END increase_order_message_counter;


END OZF_FUNDS_PUB;

/
