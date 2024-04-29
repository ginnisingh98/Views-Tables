--------------------------------------------------------
--  DDL for Package Body OZF_QUOTA_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_QUOTA_PUB" AS
/* $Header: OZFPQUOB.pls 120.5 2006/06/01 15:23:09 mgudivak noship $ */

g_pkg_name    CONSTANT VARCHAR2(30) := 'OZF_QUOTA_PUB';
G_DEBUG BOOLEAN := FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_high);

PROCEDURE generate_product_spread(
   p_api_version        IN              NUMBER
  ,p_init_msg_list      IN              VARCHAR2 := fnd_api.g_false
  ,p_commit             IN              VARCHAR2 := fnd_api.g_false
  ,p_validation_level   IN              NUMBER   := fnd_api.g_valid_level_full
  ,p_quota_id           IN              NUMBER
  ,x_return_status      OUT NOCOPY      VARCHAR2
  ,x_error_number       OUT NOCOPY      NUMBER
  ,x_error_message      OUT NOCOPY      VARCHAR2) ;

PROCEDURE create_allocation(
   p_api_version        IN              NUMBER
  ,p_init_msg_list      IN              VARCHAR2 := fnd_api.g_false
  ,p_commit             IN              VARCHAR2 := fnd_api.g_false
  ,p_validation_level   IN              NUMBER   := fnd_api.g_valid_level_full
  ,p_alloc_rec          IN              alloc_rec_type
  ,x_return_status      OUT NOCOPY      VARCHAR2
  ,x_msg_count          OUT NOCOPY      NUMBER
  ,x_msg_data           OUT NOCOPY      VARCHAR2
  ,x_alloc_id           OUT NOCOPY      NUMBER) ;

PROCEDURE publish_allocation(
   p_api_version        IN              NUMBER
  ,p_init_msg_list      IN              VARCHAR2 := fnd_api.g_false
  ,p_commit             IN              VARCHAR2 := fnd_api.g_false
  ,p_validation_level   IN              NUMBER   := fnd_api.g_valid_level_full
  ,p_alloc_id           IN              NUMBER
  ,x_return_status      OUT NOCOPY      VARCHAR2
  ,x_msg_count          OUT NOCOPY      NUMBER
  ,x_msg_data           OUT NOCOPY      VARCHAR2) ;


PROCEDURE validate_time_period (p_period_type_id IN NUMBER,
                                p_time_id IN NUMBER,
                                x_return_status      OUT NOCOPY VARCHAR2)
IS

CURSOR c_chk_period(p_time_id IN NUMBER) IS
SELECT 1 FROM ozf_time_ent_period WHERE ent_period_id = p_time_id;

CURSOR c_chk_qtr(p_time_id IN NUMBER) IS
SELECT 1 FROM ozf_time_ent_qtr WHERE ent_qtr_id = p_time_id;

l_time_id NUMBER;

BEGIN

      IF p_period_type_id IS NULL OR p_period_type_id NOT IN (32,64)
      THEN
         --
         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error)
         THEN
            fnd_message.set_name('OZF', 'OZF_QUOTA_INVALID_PERIOD');
            fnd_message.set_token('VALUE', p_period_type_id);
            fnd_msg_pub.add;
         END IF;
         x_return_status := fnd_api.g_ret_sts_error;
      ELSE

         IF p_period_type_id = 32
         THEN
             open c_chk_period(p_time_id);
             fetch c_chk_period INTO l_time_id;
             close c_chk_period;
         ELSE
             open c_chk_qtr(p_time_id);
             fetch c_chk_qtr INTO l_time_id;
             close c_chk_qtr;
         END IF;

         IF l_time_id IS NULL
         THEN
         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error)
         THEN
            fnd_message.set_name('OZF', 'OZF_QUOTA_INVALID_TIMEID');
            fnd_message.set_token('VALUE', p_time_id);
            fnd_msg_pub.add;
         END IF;
         x_return_status := fnd_api.g_ret_sts_error;
         END IF;

      END IF;

END validate_time_period;

---------------------------------------------------------------------
-- PROCEDURE
--    validate_quota_attributes
--
-- PURPOSE
--    Validate quota attributes.
--
-- PARAMETERS
--    p_quota_rec: quota record to be validated
--    p_mode: CREATE or UPDATE
--    x_return_status: return status
--
-- HISTORY
--    06/29/2005  kdass Created

/*
Required
--------
quota_id
quota_number
short_name
custom_setup_id
user_status_id
start_period_name
end_period_name
quota_amount
owner
product_spread_time_id

Foreign Keys
------------
quota_id
parent_quota_id
custom_setup_id
user_status_id
owner
threshold_id
product_spread_time_id

Columns allowed to update
-------------------------
short_name
description
quota_amount
owner
threshold_id

Derived
-------
status_code
start_date_active
end_date_active
currency_code_tc
created_from
*/
---------------------------------------------------------------------
PROCEDURE validate_quota_attributes (
   p_quota_rec          IN OUT NOCOPY   quota_rec_type
  ,p_mode               IN              VARCHAR2
  ,p_method             IN              VARCHAR2 := FND_API.G_MISS_CHAR
  ,p_fund_rec           IN OUT NOCOPY   OZF_Funds_Pub.fund_rec_type
  ,x_return_status      OUT NOCOPY      VARCHAR2
  )
IS
l_api_name      VARCHAR(30) := 'Validate_Quota_Attributes';
l_quota_exists  NUMBER := NULL;
l_period_exists NUMBER := NULL;
l_custom_setup_exists NUMBER := NULL;
l_owner_exists  NUMBER := NULL;
l_threshold_exists NUMBER := NULL;
l_dummy_date        DATE := NULL;

-- Columns to default
l_status_code       VARCHAR2(30);
l_start_date_active DATE := NULL;
l_end_date_active   DATE := NULL;
l_currency_code_tc  VARCHAR2(30);
l_created_from      VARCHAR2(30);

CURSOR c_quota_exists (p_quota_id IN NUMBER) IS
   SELECT 1
   FROM  ozf_funds_all_b
   WHERE fund_type = 'QUOTA'
     AND fund_id = p_quota_id;

CURSOR c_quota_num_exists (p_quota_number IN VARCHAR2) IS
   SELECT fund_id
   FROM  ozf_funds_all_b
   WHERE fund_type = 'QUOTA'
     AND fund_number = p_quota_number;

CURSOR c_custom_setup_exists (p_custom_setup_id IN NUMBER) IS
   SELECT custom_setup_id
   FROM  ams_custom_setups_vl
   WHERE object_type = 'FUND'
     AND application_id = 682
     AND activity_type_code = 'QUOTA'
     AND custom_setup_id = p_custom_setup_id;

CURSOR c_period_exists (p_period IN VARCHAR2) IS
   SELECT start_date, end_date FROM OZF_TIME_ENT_PERIOD
   WHERE name = p_period
   UNION ALL
   SELECT start_date, end_date FROM OZF_TIME_ENT_QTR
   WHERE name = p_period
   UNION ALL
   SELECT start_date, end_date FROM OZF_TIME_ENT_YEAR
   WHERE name = p_period;

CURSOR c_user_status_id (p_user_status_id IN NUMBER) IS
   SELECT system_status_code
   FROM ams_user_statuses_vl
   WHERE system_status_type = 'OZF_FUND_STATUS'
   AND user_status_id  = p_user_status_id
   AND enabled_flag ='Y';

CURSOR c_resource_exists (p_resource_id IN NUMBER) IS
   SELECT 1
   FROM jtf_rs_resource_extns
   WHERE resource_id = p_resource_id
   AND category = 'EMPLOYEE';

CURSOR c_threshold_exists (p_threshold_id IN NUMBER) IS
  SELECT 1
  FROM ozf_thresholds_all_b
  WHERE threshold_id = p_threshold_id
  AND threshold_type = 'QUOTA';

BEGIN

   IF G_DEBUG THEN
      ozf_utility_pvt.debug_message('Start Procedure: '|| l_api_name);
   END IF;

   IF p_mode = 'CREATE'
   THEN
      -- Reset quota id value if provided
      p_quota_rec.quota_id := NULL;

      -- Required Column Check ------------------------
      -- Short_Name
      IF p_quota_rec.short_name = fnd_api.g_miss_char
         OR
         p_quota_rec.short_name IS NULL
      THEN
         --
         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error)
         THEN
            fnd_message.set_name('OZF', 'OZF_QUOTA_MISSING_COL_VALUE');
            fnd_message.set_token('COL_NAME','SHORT_NAME');
            fnd_msg_pub.add;
         END IF;
         x_return_status := fnd_api.g_ret_sts_error;
      END IF;

      -- Custom_Setup_Id
      IF p_quota_rec.custom_setup_id = fnd_api.g_miss_num
         OR
         p_quota_rec.custom_setup_id IS NULL
      THEN
         --
         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error)
         THEN
            fnd_message.set_name('OZF', 'OZF_QUOTA_MISSING_COL_VALUE');
            fnd_message.set_token('COL_NAME','CUSTOM_SETUP_ID');
            fnd_msg_pub.add;
         END IF;
         x_return_status := fnd_api.g_ret_sts_error;
       END IF;

      -- User_Status_Id
      IF p_quota_rec.user_status_id = fnd_api.g_miss_num
         OR
         p_quota_rec.user_status_id IS NULL
      THEN
         --
         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error)
         THEN
            fnd_message.set_name('OZF', 'OZF_QUOTA_MISSING_COL_VALUE');
            fnd_message.set_token('COL_NAME','USER_STATUS_ID');
            fnd_msg_pub.add;
         END IF;
         x_return_status := fnd_api.g_ret_sts_error;
      END IF;

      -- Start_Period_Name
      IF p_quota_rec.start_period_name = fnd_api.g_miss_char
         OR
         p_quota_rec.start_period_name IS NULL
      THEN
         --
         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error)
         THEN
            fnd_message.set_name('OZF', 'OZF_QUOTA_MISSING_COL_VALUE');
            fnd_message.set_token('COL_NAME','START_PERIOD_NAME');
            fnd_msg_pub.add;
         END IF;
         x_return_status := fnd_api.g_ret_sts_error;
       END IF;

       --  End_Period_Name
      IF p_quota_rec.start_period_name = fnd_api.g_miss_char
         OR
         p_quota_rec.start_period_name IS NULL
      THEN
         --
         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error)
         THEN
            fnd_message.set_name('OZF', 'OZF_QUOTA_MISSING_COL_VALUE');
            fnd_message.set_token('COL_NAME','END_PERIOD_NAME');
            fnd_msg_pub.add;
         END IF;
         x_return_status := fnd_api.g_ret_sts_error;
       END IF;

      -- Quota_Amount
      IF p_quota_rec.quota_amount = fnd_api.g_miss_num
         OR
         p_quota_rec.quota_amount IS NULL
      THEN
         --
         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error)
         THEN
            fnd_message.set_name('OZF', 'OZF_QUOTA_MISSING_COL_VALUE');
            fnd_message.set_token('COL_NAME','QUOTA_AMOUNT');
            fnd_msg_pub.add;
         END IF;
         x_return_status := fnd_api.g_ret_sts_error;
       END IF;

      -- Owner
      IF p_quota_rec.owner = fnd_api.g_miss_num
         OR
         p_quota_rec.owner IS NULL
      THEN
         --
         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error)
         THEN
            fnd_message.set_name('OZF', 'OZF_QUOTA_MISSING_COL_VALUE');
            fnd_message.set_token('COL_NAME','OWNER');
            fnd_msg_pub.add;
         END IF;
         x_return_status := fnd_api.g_ret_sts_error;
      END IF;

      -- Product_Spread_Time_Id
      IF p_quota_rec.product_spread_time_id = fnd_api.g_miss_num
         OR
         p_quota_rec.product_spread_time_id IS NULL
      THEN
         --
         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error)
         THEN
            fnd_message.set_name('OZF', 'OZF_QUOTA_MISSING_COL_VALUE');
            fnd_message.set_token('COL_NAME','PRODUCT_SPREAD_TIME_ID');
            fnd_msg_pub.add;
         END IF;
         x_return_status := fnd_api.g_ret_sts_error;
      END IF;

      -- Return Error when all the required columns are checked
      IF x_return_status = fnd_api.g_ret_sts_error
      THEN
          RETURN;
      END IF;

      -- End Required Column Check ------------------

      -- Check Foreign Key for columns that are valid for Create mode only

      -- If Parent_Quota_Id is provided, then it should be valid
      IF p_quota_rec.parent_quota_id <> fnd_api.g_miss_num
         AND
         p_quota_rec.parent_quota_id IS NOT NULL
      THEN
         --
         -- Parent_Quota_Id should be populated only
         -- when method is MANUAL. If method is ALLOCATION
         -- then, the quota hierarchy is created automatically
         --
         IF p_method = 'ALLOCATE'
         THEN
            --
               IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error)
               THEN
                   fnd_message.set_name('OZF', 'OZF_QUOTA_INVALID_COL_VALUE');
                   fnd_message.set_token('COL_NAME', 'PARENT_QUOTA_ID');
                   fnd_msg_pub.add;
               END IF;
               x_return_status := fnd_api.g_ret_sts_error;
               RETURN;
            --
         ELSE
            --
            OPEN c_quota_exists (p_quota_rec.parent_quota_id);
            FETCH c_quota_exists INTO l_quota_exists;
            CLOSE c_quota_exists;

            IF l_quota_exists IS NULL
            THEN
              --
               IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error)
               THEN
                   fnd_message.set_name('OZF', 'OZF_QUOTA_INVALID_COL_VALUE');
                   fnd_message.set_token('COL_NAME', 'PARENT_QUOTA_ID');
                   fnd_msg_pub.add;
               END IF;
               x_return_status := fnd_api.g_ret_sts_error;
               RETURN;
            END IF;
            --
         END IF;
         --
      END IF;  -- Check Parent Quota Id

      -- Custom_Setup_Id
      IF p_quota_rec.custom_setup_id <> fnd_api.g_miss_num
         AND
         p_quota_rec.custom_setup_id IS NOT NULL
      THEN
         OPEN c_custom_setup_exists (p_quota_rec.custom_setup_id);
         FETCH c_custom_setup_exists INTO l_custom_setup_exists;
         CLOSE c_custom_setup_exists;

         IF l_custom_setup_exists IS NULL
         THEN
              IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error)
              THEN
                  fnd_message.set_name('OZF', 'OZF_QUOTA_INVALID_COL_VALUE');
                  fnd_message.set_token('COL_NAME', 'CUSTOM_SETUP_ID');
                  fnd_msg_pub.add;
              END IF;
              x_return_status := fnd_api.g_ret_sts_error;
              RETURN;
         END IF;
         --
      END IF;

      -- User_Status_Id
      IF p_quota_rec.user_status_id <> fnd_api.g_miss_num
         AND
         p_quota_rec.user_status_id IS NOT NULL
      THEN
         OPEN c_user_status_id (p_quota_rec.user_status_id);
         FETCH c_user_status_id INTO l_status_code;
         CLOSE c_user_status_id;

         IF l_status_code IS NULL
         THEN
              IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error)
              THEN
                  fnd_message.set_name('OZF', 'OZF_QUOTA_INVALID_COL_VALUE');
                  fnd_message.set_token('COL_NAME', 'USER_STATUS_ID');
                  fnd_msg_pub.add;
              END IF;
              x_return_status := fnd_api.g_ret_sts_error;
              RETURN;
         END IF;
         --
      END IF;

      -- Start_Period_Name
      IF p_quota_rec.start_period_name <> fnd_api.g_miss_char
         AND
         p_quota_rec.start_period_name IS NOT NULL
      THEN
         OPEN c_period_exists (p_quota_rec.start_period_name);
         FETCH c_period_exists INTO l_start_date_active, l_dummy_date;
         CLOSE c_period_exists;

         IF l_start_date_active IS NULL
         THEN
              IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error)
              THEN
                 fnd_message.set_name('OZF', 'OZF_QUOTA_INVALID_COL_VALUE');
                 fnd_message.set_token('COL_NAME', 'START_PERIOD_NAME');
                 fnd_msg_pub.add;
              END IF;
              x_return_status := fnd_api.g_ret_sts_error;
              RETURN;
         END IF;
         --
      END IF;

      -- End_Period_Name
      IF p_quota_rec.end_period_name <> fnd_api.g_miss_char
         AND
         p_quota_rec.end_period_name IS NOT NULL
      THEN
         OPEN c_period_exists (p_quota_rec.end_period_name);
         FETCH c_period_exists INTO l_dummy_date, l_end_date_active;
         CLOSE c_period_exists;

         IF l_end_date_active IS NULL
         THEN
              IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error)
              THEN
                 fnd_message.set_name('OZF', 'OZF_QUOTA_INVALID_COL_VALUE');
                 fnd_message.set_token('COL_NAME', 'END_PERIOD_NAME');
                 fnd_msg_pub.add;
              END IF;
              x_return_status := fnd_api.g_ret_sts_error;
              RETURN;
         END IF;
         --
      END IF;

      -- Product_Spread_Time_Id
      IF p_quota_rec.product_spread_time_id <> fnd_api.g_miss_num
         AND
         p_quota_rec.product_spread_time_id IS NOT NULL
      THEN

         IF p_quota_rec.product_spread_time_id NOT IN ('32', '64')
         THEN
              IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error)
              THEN
                 fnd_message.set_name('OZF', 'OZF_QUOTA_INVALID_COL_VALUE');
                 fnd_message.set_token('COL_NAME', 'PRODUCT_SPREAD_TIME_ID');
                 fnd_msg_pub.add;
              END IF;
              x_return_status := fnd_api.g_ret_sts_error;
              RETURN;
         END IF;
         --
      END IF;

      -- End checking foreign keys for columns in create mode

   END IF; -- End Create Mode

   -- The following columns can be updated also. So do the foreign
   -- key check in both create and update
   -- 1. Owner
   -- 2. Threshold_Id

      -- Owner
      IF p_quota_rec.owner <> fnd_api.g_miss_num
         AND
         p_quota_rec.owner IS NOT NULL
      THEN

         OPEN c_resource_exists (p_quota_rec.owner);
         FETCH c_resource_exists INTO l_owner_exists;
         CLOSE c_resource_exists;

         IF l_owner_exists IS NULL
         THEN
              IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error)
              THEN
                 fnd_message.set_name('OZF', 'OZF_QUOTA_INVALID_COL_VALUE');
                 fnd_message.set_token('COL_NAME', 'OWNER');
                 fnd_msg_pub.add;
              END IF;
              x_return_status := fnd_api.g_ret_sts_error;
              RETURN;
         END IF;
         --
      END IF;

      -- Threshold_Id
      IF p_quota_rec.threshold_id <> fnd_api.g_miss_num
         AND
         p_quota_rec.threshold_id IS NOT NULL
      THEN
         --
         OPEN c_threshold_exists (p_quota_rec.threshold_id);
         FETCH c_threshold_exists INTO l_threshold_exists;
         CLOSE c_threshold_exists;

         IF l_threshold_exists IS NULL
         THEN
            --
            IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error)
            THEN
                fnd_message.set_name('OZF', 'OZF_QUOTA_INVALID_COL_VALUE');
                fnd_message.set_token('COL_NAME', 'THRESHOLD_ID');
                fnd_msg_pub.add;
            END IF;
            x_return_status := fnd_api.g_ret_sts_error;
            RETURN;
         END IF;
         --
      END IF;
      -- End foreign key check

  IF p_mode = 'UPDATE'
  THEN

      -- UPDATE MODE
      --if both quota id and quota number are null, then raise exception
      IF (p_quota_rec.quota_id = fnd_api.g_miss_num OR p_quota_rec.quota_id IS NULL)
         AND
         (p_quota_rec.quota_number = fnd_api.g_miss_char OR p_quota_rec.quota_number IS NULL)
      THEN

         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
            fnd_message.set_name('OZF', 'OZF_NO_QUOTA_ID_NUM');
            fnd_msg_pub.add;
         END IF;
         x_return_status := fnd_api.g_ret_sts_error;
         RETURN;

      ELSE
         --if quota id is not null it takes precedence over quota number
         IF p_quota_rec.quota_id <> fnd_api.g_miss_num
            AND p_quota_rec.quota_id IS NOT NULL
         THEN

            --check if the input quota_id is valid
            OPEN c_quota_exists (p_quota_rec.quota_id);
            FETCH c_quota_exists INTO l_quota_exists;
            CLOSE c_quota_exists;

            IF l_quota_exists IS NULL THEN
               IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
                  fnd_message.set_name('OZF', 'OZF_INVALID_QUOTA_ID');
                  fnd_msg_pub.add;
               END IF;
               x_return_status := fnd_api.g_ret_sts_error;
               RETURN;
            END IF;

         --if quota number is not null
         ELSE
            --check if the input quota_number is valid
            OPEN c_quota_num_exists (p_quota_rec.quota_number);
            FETCH c_quota_num_exists INTO p_quota_rec.quota_id;
            CLOSE c_quota_num_exists;

            IF p_quota_rec.quota_id IS NULL THEN
               IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
                  fnd_message.set_name('OZF', 'OZF_INVALID_QUOTA_NUM');
                  fnd_msg_pub.add;
               END IF;
               x_return_status := fnd_api.g_ret_sts_error;
               RETURN;
            END IF;
            --
         END IF; -- End quota_id number check
         --
      END IF; -- End Quota ID and Quota Num Check
      --
   END IF; -- End Update Mode


   -- Populate the Fund Record

   -- Derived Columns
   p_fund_rec.start_date_active := l_start_date_active;
   p_fund_rec.end_date_active := l_end_date_active;
   p_fund_rec.status_code := l_status_code;
   p_fund_rec.currency_code_tc := fnd_profile.value ('OZF_TP_COMMON_CURRENCY');
   --p_fund_rec.created_from := p_method;  TODO: Add to Fund record
   -- TODO: Add DFF attributes to fund record.

   p_fund_rec.parent_fund_id := p_quota_rec.parent_quota_id;
   p_fund_rec.fund_number := p_quota_rec.quota_number;
   p_fund_rec.short_name := p_quota_rec.short_name;
   p_fund_rec.fund_type := 'QUOTA';
   p_fund_rec.custom_setup_id := p_quota_rec.custom_setup_id;
   p_fund_rec.description := p_quota_rec.description;
   p_fund_rec.category_id := '10001'; --from FundEO.getCreateAPIRec()
   p_fund_rec.user_status_id := p_quota_rec.user_status_id;
   p_fund_rec.start_period_name := p_quota_rec.start_period_name;
   p_fund_rec.end_period_name := p_quota_rec.end_period_name;
   p_fund_rec.original_budget := p_quota_rec.quota_amount;
   p_fund_rec.owner := p_quota_rec.owner;
   p_fund_rec.threshold_id := p_quota_rec.threshold_id;
   p_fund_rec.product_spread_time_id := p_quota_rec.product_spread_time_id;

   IF G_DEBUG THEN
      ozf_utility_pvt.debug_message('End Procedure: '|| l_api_name);
   END IF;

END validate_quota_attributes;


PROCEDURE validate_product_record(p_init_msg_list     IN VARCHAR2,
                                  x_Return_Status     OUT NOCOPY VARCHAR2,
                                  x_msg_count         OUT NOCOPY NUMBER,
                                  x_msg_data          OUT NOCOPY VARCHAR2,
                                  p_quota_id          IN NUMBER,
                                  p_quota_products_rec IN quota_products_rec_type,
                                 x_act_product_rec   OUT NOCOPY AMS_ActProduct_PVT.act_Product_rec_type)
IS

 l_api_name      VARCHAR(30) := 'Validate_Product_Record';

l_quota_products_rec   quota_products_rec_type := p_quota_products_rec;
l_act_product_rec AMS_ActProduct_PVT.act_Product_rec_type ;

BEGIN
   IF G_DEBUG THEN
      ozf_utility_pvt.debug_message('Start Procedure: '|| l_api_name);
   END IF;

     x_return_status := FND_API.G_RET_STS_SUCCESS;

     -- Default values
     l_act_product_rec.ACT_PRODUCT_USED_BY_ID         := p_quota_id;
     l_act_product_rec.ARC_ACT_PRODUCT_USED_BY        := 'FUND';
     l_act_product_rec.PRIMARY_PRODUCT_FLAG           := 'N';
     l_act_product_rec.ENABLED_FLAG                   := 'Y';
     l_act_product_rec.EXCLUDED_FLAG                  := 'N';

     IF l_quota_products_rec.item_type <> fnd_api.g_miss_char
        AND
        l_quota_products_rec.item_type IS NOT NULL
     THEN
        --
          IF l_quota_products_rec.item_type NOT IN ('PRODUCT','FAMILY')
          THEN
            --
              IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error)
              THEN
                  fnd_message.set_name('OZF', 'OZF_QUOTA_INVALID_COL_VALUE');
                  fnd_message.set_token('COL_NAME', 'ITEM_TYPE');
                  fnd_msg_pub.add;
              END IF;
              x_return_status := fnd_api.g_ret_sts_error;
              RETURN;
          ELSE
            --
              l_act_product_rec.level_type_code    :=  l_quota_products_rec.item_type;
              IF l_quota_products_rec.item_type = 'PRODUCT'
              THEN
                 l_act_product_rec.ORGANIZATION_ID    :=  l_quota_products_rec.organization_id;
                 l_act_product_rec.INVENTORY_ITEM_ID  :=  l_quota_products_rec.item_id;
              ELSE
                 l_act_product_rec.CATEGORY_ID        :=  l_quota_products_rec.item_id;
                 l_act_product_rec.CATEGORY_SET_ID    :=  l_quota_products_rec.category_set_id;
              END IF;
            --
          END IF;
       --
     ELSE
       --
         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error)
         THEN
            fnd_message.set_name('OZF', 'OZF_QUOTA_MISSING_COL_VALUE');
            fnd_message.set_token('COL_NAME','ITEM_TYPE');
            fnd_msg_pub.add;
         END IF;
         x_return_status := fnd_api.g_ret_sts_error;
       --
     END IF;

     x_act_product_rec := l_act_product_rec;

   IF G_DEBUG THEN
      ozf_utility_pvt.debug_message('End Procedure: '|| l_api_name);
   END IF;

EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN
         x_return_status     := FND_API.G_RET_STS_ERROR ;
         FND_MSG_PUB.Count_And_Get
         (  P_count          =>   x_msg_count,
            P_data           =>   x_msg_data
         );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          X_return_status     := FND_API.G_RET_STS_UNEXP_ERROR;
          FND_MSG_PUB.Count_And_Get
          (  p_count          =>   x_msg_count,
             p_data           =>   x_msg_data
          );

  WHEN OTHERS THEN
       x_return_status        := FND_API.G_RET_STS_UNEXP_ERROR;
       IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
       THEN
             FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,
                                      'Others exception inside Validate_Product_Record'
                                      || sqlerrm);
       END IF;

END validate_product_record;


PROCEDURE create_quota_header(
   p_api_version		IN             NUMBER
  ,p_init_msg_list     		IN             VARCHAR2 := fnd_api.g_false
  ,p_commit            		IN             VARCHAR2 := fnd_api.g_false
  ,p_validation_level  		IN             NUMBER   := fnd_api.g_valid_level_full
  ,x_return_status     		OUT NOCOPY     VARCHAR2
  ,x_msg_count         		OUT NOCOPY     NUMBER
  ,x_msg_data          		OUT NOCOPY     VARCHAR2
  ,p_method            		IN             VARCHAR2
  ,p_mode                       IN             VARCHAR2
  ,p_quota_rec         		IN   	       quota_rec_type
  ,p_quota_markets_tbl          IN             quota_markets_tbl_type
  ,p_quota_products_tbl		IN             quota_products_tbl_type
  ,x_quota_id          		OUT NOCOPY     NUMBER  )
IS

l_api_name             CONSTANT VARCHAR2(30) := 'Create_Quota_Header';
l_quota_rec            quota_rec_type := p_quota_rec;
l_quota_markets_tbl    quota_markets_tbl_type := p_quota_markets_tbl;
l_quota_products_tbl   quota_products_tbl_type := p_quota_products_tbl;
l_act_product_rec      AMS_ActProduct_PVT.act_Product_rec_type;
l_product_id           NUMBER;
l_act_mks_id	       NUMBER;

-- Fund related variables

l_fund_rec              OZF_Funds_Pub.fund_rec_type;
l_mks_rec		OZF_Funds_Pub.mks_rec_type;
l_modifier_list_rec     ozf_offer_pub.modifier_list_rec_type;
l_modifier_line_tbl     ozf_offer_pub.modifier_line_tbl_type;
l_vo_pbh_tbl            ozf_offer_pub.vo_disc_tbl_type;
l_vo_dis_tbl            ozf_offer_pub.vo_disc_tbl_type;
l_vo_prod_tbl           ozf_offer_pub.vo_prod_tbl_type;
l_qualifier_tbl         ozf_offer_pub.qualifiers_tbl_type;
l_vo_mo_tbl             ozf_offer_pub.vo_mo_tbl_type;

BEGIN

   --  Initialize API return status to success
   IF G_DEBUG THEN
      ozf_utility_pvt.debug_message('Start Procedure: '|| l_api_name);
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   validate_quota_attributes( p_quota_rec     => l_quota_rec
                             ,p_mode          => p_mode
                             ,p_method        => p_method
                             ,p_fund_rec      => l_fund_rec
                             ,x_return_status => x_return_status);

   IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
      RAISE fnd_api.g_exc_unexpected_error;
   ELSIF x_return_status = fnd_api.g_ret_sts_error THEN
      RAISE fnd_api.g_exc_error;
   END IF;

   ozf_funds_pub.create_fund(p_api_version       => p_api_version
                            ,p_init_msg_list     => p_init_msg_list
                            ,p_commit            => p_commit
                            ,p_validation_level  => p_validation_level
                            ,x_return_status     => x_return_status
                            ,x_msg_count         => x_msg_count
                            ,x_msg_data          => x_msg_data
                            ,p_fund_rec          => l_fund_rec
                            ,p_modifier_list_rec => l_modifier_list_rec
                            ,p_modifier_line_tbl => l_modifier_line_tbl
                            ,p_vo_pbh_tbl        => l_vo_pbh_tbl
                            ,p_vo_dis_tbl        => l_vo_dis_tbl
                            ,p_vo_prod_tbl       => l_vo_prod_tbl
                            ,p_qualifier_tbl     => l_qualifier_tbl
                            ,p_vo_mo_tbl         => l_vo_mo_tbl
                            ,x_fund_id           => x_quota_id
                            );

   IF G_DEBUG THEN
      ozf_utility_pvt.debug_message('Quota ID: ' || x_quota_id);
      ozf_utility_pvt.debug_message('Return Status: ' || x_return_status);
   END IF;

   IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_ERROR;
   END IF;


   IF p_quota_markets_tbl.COUNT > 0
   THEN
       --
       FOR l_quota_market_counter IN 1..p_quota_markets_tbl.COUNT
       LOOP
           --
              l_quota_markets_tbl(l_quota_market_counter).act_market_segment_used_by_id := x_quota_id;
              l_quota_markets_tbl(l_quota_market_counter).arc_act_market_segment_used_by := 'FUND';
           --
              l_mks_rec := l_quota_markets_tbl(l_quota_market_counter);

              OZF_FUNDS_PUB. create_market_segment(
		   	p_api_version
		  	,p_init_msg_list
		 	 ,p_commit
		  	,p_validation_level
		  	,l_mks_rec
		  	,x_return_status
		  	,x_msg_count
		  	,x_msg_data
		  	,l_act_mks_id );

             IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                RAISE FND_API.G_EXC_ERROR;
             END IF;
            --
       END LOOP;
       --
   END IF;


   FOR l_counter IN 1..l_quota_products_tbl.COUNT
   LOOP

      IF l_quota_products_tbl(l_counter).item_type <> 'OTHERS'
      THEN
         --
         validate_product_record(p_init_msg_list    => FND_API.G_FALSE,
                                 x_Return_Status    => x_return_status,
                                 x_msg_count        => x_msg_count,
                                 x_msg_data         => x_msg_data,
                                 p_quota_id         => x_quota_id,
                                 p_quota_products_rec => l_quota_products_tbl(l_counter),
                                 x_act_product_rec    => l_act_product_rec);

         IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE FND_API.G_EXC_ERROR;
         END IF;

         ams_actproduct_pvt.create_act_product(
                             p_api_version       => p_api_version
                            ,p_init_msg_list     => p_init_msg_list
                            ,p_commit            => p_commit
                            ,p_validation_level  => p_validation_level
                            ,x_return_status     => x_return_status
                            ,x_msg_count         => x_msg_count
                            ,x_msg_data          => x_msg_data
                            ,p_act_Product_rec   => l_act_product_rec
                            ,x_act_Product_id    => l_product_id );

         IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE FND_API.G_EXC_ERROR;
         END IF;
     END IF;
     --
   END LOOP;

   IF G_DEBUG THEN
      ozf_utility_pvt.debug_message('End Procedure: '|| l_api_name);
   END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
         x_return_status     := FND_API.G_RET_STS_ERROR ;
         FND_MSG_PUB.Count_And_Get
         (  P_count          =>   x_msg_count,
            P_data           =>   x_msg_data
         );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          X_return_status     := FND_API.G_RET_STS_UNEXP_ERROR;
          FND_MSG_PUB.Count_And_Get
          (  p_count          =>   x_msg_count,
             p_data           =>   x_msg_data
          );

  WHEN OTHERS THEN
       x_return_status        := FND_API.G_RET_STS_UNEXP_ERROR;
       IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
       THEN
             FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,
                                      'Others exception inside Create_Quota_Header'
                                      || sqlerrm);
       END IF;

END create_quota_header;

---------------------------------------------------------------------
-- PROCEDURE
--    validate_alloc_attributes
--
-- PURPOSE
--    Validate allocation attributes.
--
-- PARAMETERS
--    p_alloc_rec: allocation record to be validated
--    x_return_status: return status
--
-- HISTORY
--    07/04/2005  kdass Created
---------------------------------------------------------------------
PROCEDURE validate_alloc_attributes (
   p_alloc_rec          IN OUT NOCOPY   alloc_rec_type
  ,x_return_status      OUT NOCOPY      VARCHAR2
  )
IS
l_api_name      VARCHAR(30) := 'validate_alloc_attributes';
l_quota_exists  NUMBER := NULL;
l_period_exists NUMBER := NULL;

CURSOR c_quota_exists (p_quota_id IN NUMBER) IS
   SELECT 1
   FROM  ozf_funds_all_b
   WHERE fund_type = 'QUOTA'
     AND fund_id = p_quota_id;

CURSOR c_quota_num_exists (p_quota_number IN VARCHAR2) IS
   SELECT fund_id
   FROM  ozf_funds_all_b
   WHERE fund_type = 'QUOTA'
     AND fund_number = p_quota_number;

CURSOR c_period_exists (p_period IN VARCHAR2) IS
   SELECT 1 FROM OZF_TIME_ENT_PERIOD
   WHERE name = p_period
   UNION
   SELECT 1 FROM OZF_TIME_ENT_QTR
   WHERE name = p_period
   UNION
   SELECT 1 FROM OZF_TIME_ENT_YEAR
   WHERE name = p_period;

CURSOR c_from_date (p_period IN VARCHAR2) IS
   SELECT start_date
   FROM gl_periods_v
   WHERE period_set_name = fnd_profile.value ('AMS_CAMPAIGN_DEFAULT_CALENDER')
     AND period_name = p_period;

CURSOR c_to_date (p_period IN VARCHAR2) IS
   SELECT end_date
   FROM  gl_periods_v
   WHERE period_set_name = fnd_profile.value ('AMS_CAMPAIGN_DEFAULT_CALENDER')
     AND period_name = p_period;

CURSOR c_product_spread (p_quota_id IN NUMBER) IS
   SELECT product_spread_time_id
   FROM  ozf_funds_all_b
   WHERE fund_id = p_quota_id;

CURSOR c_hier_id_exists (p_hier_id IN NUMBER) IS
   SELECT heirarchy_id
   FROM  ozf_terr_levels_all
   WHERE heirarchy_id = p_hier_id;

CURSOR c_from_level_exists (p_hier_id IN NUMBER, p_from_level IN NUMBER) IS
   SELECT level_depth
   FROM  ozf_terr_levels_all
   WHERE heirarchy_id = p_hier_id
     AND level_depth = p_from_level;

CURSOR c_to_level_exists (p_hier_id IN NUMBER, p_from_level IN NUMBER, p_to_level IN NUMBER) IS
   SELECT level_depth
   FROM  ozf_terr_levels_all
   WHERE heirarchy_id = p_hier_id
     AND level_depth >= p_from_level
     AND level_depth = p_to_level;

CURSOR c_start_node_exists (p_hier_id IN NUMBER, p_from_level IN NUMBER) IS
   SELECT node_id
   FROM  ozf_terr_v
   WHERE hierarchy_id = p_hier_id
     AND level_depth = p_from_level;

CURSOR c_method_code_exists (p_method_code IN VARCHAR2) IS
   SELECT lookup_code
   FROM  ozf_lookups
   WHERE lookup_type = 'OZF_FUND_ALLOC_METHOD'
     AND lookup_code = p_method_code;

BEGIN
   IF G_DEBUG THEN
      ozf_utility_pvt.debug_message('Start Procedure: '|| l_api_name);
   END IF;

   --if both quota id and quota number are null, then raise exception
   IF (p_alloc_rec.quota_id = fnd_api.g_miss_num OR p_alloc_rec.quota_id IS NULL) AND
      (p_alloc_rec.quota_number = fnd_api.g_miss_char OR p_alloc_rec.quota_number IS NULL) THEN

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
         fnd_message.set_name('OZF', 'OZF_NO_QUOTA_ID_NUM');
         fnd_msg_pub.add;
      END IF;
      x_return_status := fnd_api.g_ret_sts_error;
      RETURN;

   ELSE
      --if quota id is not null
      IF p_alloc_rec.quota_id <> fnd_api.g_miss_num AND p_alloc_rec.quota_id IS NOT NULL THEN

         --check if the input quota_id is valid
         OPEN c_quota_exists (p_alloc_rec.quota_id);
         FETCH c_quota_exists INTO l_quota_exists;
         CLOSE c_quota_exists;

         IF l_quota_exists IS NULL THEN
            IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
               fnd_message.set_name('OZF', 'OZF_INVALID_QUOTA_ID');
               fnd_msg_pub.add;
            END IF;
            x_return_status := fnd_api.g_ret_sts_error;
            RETURN;
         END IF;

      --if quota number is not null
      ELSE
         --check if the input quota_number is valid
         OPEN c_quota_num_exists (p_alloc_rec.quota_number);
         FETCH c_quota_num_exists INTO p_alloc_rec.quota_id;
         CLOSE c_quota_num_exists;

         IF p_alloc_rec.quota_id IS NULL THEN
            IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
               fnd_message.set_name('OZF', 'OZF_INVALID_QUOTA_NUM');
               fnd_msg_pub.add;
            END IF;
            x_return_status := fnd_api.g_ret_sts_error;
            RETURN;
         END IF;
      END IF;
   END IF;

   --if hierarchy id is null, then raise exception
   IF p_alloc_rec.hierarchy_id = fnd_api.g_miss_num OR p_alloc_rec.hierarchy_id IS NULL THEN
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
         fnd_message.set_name('OZF', 'OZF_NO_HIER_ID');
         fnd_msg_pub.add;
      END IF;
      x_return_status := fnd_api.g_ret_sts_error;
      RETURN;
   ELSE
      --check if the input hierarchy id is valid
      OPEN c_hier_id_exists (p_alloc_rec.hierarchy_id);
      FETCH c_hier_id_exists INTO p_alloc_rec.hierarchy_id;
      CLOSE c_hier_id_exists;

      IF p_alloc_rec.hierarchy_id IS NULL THEN
         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
            fnd_message.set_name('OZF', 'OZF_INVALID_HIER_ID');
            fnd_msg_pub.add;
         END IF;
         x_return_status := fnd_api.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

   --if from level is null, then raise exception
   IF p_alloc_rec.from_level = fnd_api.g_miss_num OR p_alloc_rec.from_level IS NULL THEN
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
         fnd_message.set_name('OZF', 'OZF_NO_FROM_LEVEL');
         fnd_msg_pub.add;
      END IF;
      x_return_status := fnd_api.g_ret_sts_error;
      RETURN;
   ELSE
      --check if the from level is valid
      OPEN c_from_level_exists (p_alloc_rec.hierarchy_id, p_alloc_rec.from_level);
      FETCH c_from_level_exists INTO p_alloc_rec.from_level;
      CLOSE c_from_level_exists;

      IF p_alloc_rec.from_level IS NULL THEN
         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
            fnd_message.set_name('OZF', 'OZF_INVALID_FROM_LEVEL');
            fnd_msg_pub.add;
         END IF;
         x_return_status := fnd_api.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

   --if to level is null, then raise exception
   IF p_alloc_rec.to_level = fnd_api.g_miss_num OR p_alloc_rec.to_level IS NULL THEN
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
         fnd_message.set_name('OZF', 'OZF_NO_TO_LEVEL');
         fnd_msg_pub.add;
      END IF;
      x_return_status := fnd_api.g_ret_sts_error;
      RETURN;
   ELSE
      --check if the to level is valid
      OPEN c_to_level_exists (p_alloc_rec.hierarchy_id, p_alloc_rec.from_level, p_alloc_rec.to_level);
      FETCH c_to_level_exists INTO p_alloc_rec.to_level;
      CLOSE c_to_level_exists;

      IF p_alloc_rec.to_level IS NULL THEN
         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
            fnd_message.set_name('OZF', 'OZF_INVALID_TO_LEVEL');
            fnd_msg_pub.add;
         END IF;
         x_return_status := fnd_api.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

   --if start node is null, then raise exception
   IF p_alloc_rec.start_node = fnd_api.g_miss_num OR p_alloc_rec.start_node IS NULL THEN
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
         fnd_message.set_name('OZF', 'OZF_NO_START_NODE');
         fnd_msg_pub.add;
      END IF;
      x_return_status := fnd_api.g_ret_sts_error;
      RETURN;
   ELSE
      --check if the start node is valid
      OPEN c_start_node_exists (p_alloc_rec.hierarchy_id, p_alloc_rec.from_level);
      FETCH c_start_node_exists INTO p_alloc_rec.start_node;
      CLOSE c_start_node_exists;

      IF p_alloc_rec.start_node IS NULL THEN
         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
            fnd_message.set_name('OZF', 'OZF_INVALID_START_NODE');
            fnd_msg_pub.add;
         END IF;
         x_return_status := fnd_api.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

   --if start period name is null
   IF p_alloc_rec.start_period_name = fnd_api.g_miss_char OR p_alloc_rec.start_period_name IS NULL THEN
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
         fnd_message.set_name('OZF', 'OZF_NO_START_PERIOD');
         fnd_msg_pub.add;
      END IF;
      x_return_status := fnd_api.g_ret_sts_error;
      RETURN;
   ELSE
      --check if the input start period name is valid
      OPEN c_period_exists (p_alloc_rec.start_period_name);
      FETCH c_period_exists INTO l_period_exists;
      CLOSE c_period_exists;

      IF l_period_exists IS NULL THEN
         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
            fnd_message.set_name('OZF', 'OZF_INVALID_START_PERIOD');
            fnd_msg_pub.add;
         END IF;
         x_return_status := fnd_api.g_ret_sts_error;
         RETURN;
      END IF;
      l_period_exists := NULL;
   END IF;

   --if end period name is null
   IF p_alloc_rec.end_period_name = fnd_api.g_miss_char OR p_alloc_rec.end_period_name IS NULL THEN
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
         fnd_message.set_name('OZF', 'OZF_NO_END_PERIOD');
         fnd_msg_pub.add;
      END IF;
      x_return_status := fnd_api.g_ret_sts_error;
      RETURN;
   ELSE
      --check if the input end period name is valid
      OPEN c_period_exists (p_alloc_rec.end_period_name);
      FETCH c_period_exists INTO l_period_exists;
      CLOSE c_period_exists;

      IF l_period_exists IS NULL THEN
         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
            fnd_message.set_name('OZF', 'OZF_INVALID_END_PERIOD');
            fnd_msg_pub.add;
         END IF;
         x_return_status := fnd_api.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

   OPEN c_from_date (p_alloc_rec.start_period_name);
   FETCH c_from_date INTO p_alloc_rec.from_date;
   CLOSE c_from_date;

   OPEN c_to_date (p_alloc_rec.end_period_name);
   FETCH c_to_date INTO p_alloc_rec.to_date;
   CLOSE c_to_date;

   --if allocation amount is null, then raise exception
   IF p_alloc_rec.alloc_amount = fnd_api.g_miss_num OR p_alloc_rec.alloc_amount IS NULL THEN
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
         fnd_message.set_name('OZF', 'OZF_NO_ALLOC_AMT');
         fnd_msg_pub.add;
      END IF;
      x_return_status := fnd_api.g_ret_sts_error;
      RETURN;
   END IF;

   --if method code is null, then raise exception
   IF p_alloc_rec.method_code = fnd_api.g_miss_char OR p_alloc_rec.method_code IS NULL THEN
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
         fnd_message.set_name('OZF', 'OZF_NO_METHOD_CODE');
         fnd_msg_pub.add;
      END IF;
      x_return_status := fnd_api.g_ret_sts_error;
      RETURN;
   ELSE
      --check if the method code is valid
      OPEN c_method_code_exists (p_alloc_rec.method_code);
      FETCH c_method_code_exists INTO p_alloc_rec.method_code;
      CLOSE c_method_code_exists;

      IF p_alloc_rec.method_code IS NULL THEN
         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
            fnd_message.set_name('OZF', 'OZF_INVALID_METHOD_CODE');
            fnd_msg_pub.add;
         END IF;
         x_return_status := fnd_api.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

   --if basis year is null, then raise exception
   IF p_alloc_rec.basis_year = fnd_api.g_miss_num OR p_alloc_rec.basis_year IS NULL
    AND p_alloc_rec.method_code = 'PRIOR_SALES_TOTAL' THEN
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
         fnd_message.set_name('OZF', 'OZF_NO_BASIS_YEAR');
         fnd_msg_pub.add;
      END IF;
      x_return_status := fnd_api.g_ret_sts_error;
      RETURN;
   END IF;

   OPEN c_product_spread (p_alloc_rec.quota_id);
   FETCH c_product_spread INTO p_alloc_rec.product_spread_time_id;
   CLOSE c_product_spread;

   IF G_DEBUG THEN
      ozf_utility_pvt.debug_message('End Procedure: '|| l_api_name);
   END IF;

END validate_alloc_attributes;

 FUNCTION get_product_allocation_id
   RETURN NUMBER IS
   l_api_version   CONSTANT NUMBER       := 1.0;
   l_api_name      CONSTANT VARCHAR2(30) := 'get_product_allocation_id';
   l_full_api_name CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

   CURSOR product_seq_csr IS
          SELECT  ozf_product_allocations_s.NEXTVAL
          FROM DUAL;

   CURSOR product_alloc_count_csr(p_product_alloc_id in number) IS
          SELECT count(p.product_allocation_id)
          FROM   ozf_product_allocations p
          WHERE  p.product_allocation_id = p_product_alloc_id;

   l_count number := -1;
   l_product_alloc_id  number := -1;

  BEGIN

   --OZF_UTILITY_PVT.debug_message('Private API: ' || l_full_api_name || ' -- start');

   OPEN product_seq_csr;
   FETCH product_seq_csr INTO l_product_alloc_id;
   CLOSE product_seq_csr;

   LOOP
	OPEN product_alloc_count_csr(l_product_alloc_id);
	FETCH product_alloc_count_csr into l_count;
	CLOSE product_alloc_count_csr;

	EXIT WHEN l_count = 0;

	OPEN product_seq_csr;
	FETCH product_seq_csr INTO l_product_alloc_id;
	CLOSE product_seq_csr;

   END LOOP;

   return l_product_alloc_id;

   EXCEPTION
     WHEN OTHERS THEN
          OZF_UTILITY_PVT.debug_message(l_full_api_name||' : OTHERS EXCEPTION = '||sqlerrm(sqlcode));
  END get_product_allocation_id;

 FUNCTION get_time_allocation_id
   RETURN NUMBER IS
   l_api_version   CONSTANT NUMBER       := 1.0;
   l_api_name      CONSTANT VARCHAR2(30) := 'get_time_allocation_id';
   l_full_api_name CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

   CURSOR time_seq_csr IS
          SELECT  ozf_time_allocations_s.NEXTVAL
          FROM DUAL;

   CURSOR time_alloc_count_csr(p_time_alloc_id in number) IS
          SELECT count(t.time_allocation_id)
          FROM   ozf_time_allocations t
          WHERE  t.time_allocation_id = p_time_alloc_id;

   l_count number := -1;
   l_time_alloc_id  number := -1;

  BEGIN

   --OZF_UTILITY_PVT.debug_message('Private API: ' || l_full_api_name || ' -- start');

   OPEN time_seq_csr;
   FETCH time_seq_csr INTO l_time_alloc_id;
   CLOSE time_seq_csr;

   LOOP
	OPEN time_alloc_count_csr(l_time_alloc_id);
	FETCH time_alloc_count_csr into l_count;
	CLOSE time_alloc_count_csr;

	EXIT WHEN l_count = 0;

	OPEN time_seq_csr;
	FETCH time_seq_csr INTO l_time_alloc_id;
	CLOSE time_seq_csr;

   END LOOP;

   return l_time_alloc_id;

   EXCEPTION
     WHEN OTHERS THEN
          OZF_UTILITY_PVT.debug_message(l_full_api_name||' : OTHERS EXCEPTION = '||sqlerrm(sqlcode));
  END get_time_allocation_id;

 FUNCTION get_account_allocation_id
   RETURN NUMBER IS
   l_api_version   CONSTANT NUMBER       := 1.0;
   l_api_name      CONSTANT VARCHAR2(30) := 'get_account_allocation_id';
   l_full_api_name CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

   CURSOR account_seq_csr IS
          SELECT  ozf_account_allocations_s.NEXTVAL
          FROM DUAL;

   CURSOR account_alloc_count_csr(p_account_alloc_id in number) IS
          SELECT count(account_allocation_id)
          FROM   ozf_account_allocations
          WHERE  account_allocation_id = p_account_alloc_id;

   l_count number := -1;
   l_account_alloc_id  number := -1;

  BEGIN

   --OZF_UTILITY_PVT.debug_message('Private API: ' || l_full_api_name || ' -- start');

   OPEN account_seq_csr;
   FETCH account_seq_csr INTO l_account_alloc_id;
   CLOSE account_seq_csr;

   LOOP
	OPEN account_alloc_count_csr(l_account_alloc_id);
	FETCH account_alloc_count_csr into l_count;
	CLOSE account_alloc_count_csr;

	EXIT WHEN l_count = 0;

	OPEN account_seq_csr;
	FETCH account_seq_csr INTO l_account_alloc_id;
	CLOSE account_seq_csr;

   END LOOP;

   return l_account_alloc_id;

   EXCEPTION
     WHEN OTHERS THEN
          OZF_UTILITY_PVT.debug_message(l_full_api_name||' : OTHERS EXCEPTION = '||sqlerrm(sqlcode));
  END get_account_allocation_id;

-- This procedure can be called to create product allocations
-- to a Quota or an Account
PROCEDURE Create_Product_Alloc_Record(
              p_api_version         IN   NUMBER
             ,p_init_msg_list       IN   VARCHAR2 := fnd_api.g_false
             ,p_commit              IN   VARCHAR2 := fnd_api.g_false
             ,p_validation_level    IN   NUMBER   := fnd_api.g_valid_level_full
             ,x_return_status       OUT NOCOPY  VARCHAR2
             ,x_msg_count           OUT NOCOPY  NUMBER
             ,x_msg_data            OUT NOCOPY  VARCHAR2
             ,p_product_alloc_rec    IN ozf_product_allocations%ROWTYPE
             ,x_product_allocation_id OUT NOCOPY NUMBER )
IS

   l_api_name      VARCHAR(30) := 'Create_Product_Alloc_Record';

  l_product_allocation_id NUMBER;
  l_org_id                NUMBER;
  l_object_version_number NUMBER := 1;

BEGIN

   IF G_DEBUG THEN
      ozf_utility_pvt.debug_message('Start Procedure: '|| l_api_name);
   END IF;

     x_return_status := FND_API.G_RET_STS_SUCCESS;

       l_product_allocation_id            := get_product_allocation_id;

     -- Call the Insert here
       Ozf_Product_Allocations_Pkg.Insert_Row(
          px_product_allocation_id  => l_product_allocation_id,
          p_allocation_for          => p_product_alloc_rec.allocation_for,
          p_allocation_for_id       => p_product_alloc_rec.allocation_for_id,
          p_fund_id                 => p_product_alloc_rec.fund_id,
          p_item_type               => p_product_alloc_rec.item_type,
          p_item_id                 => p_product_alloc_rec.item_id,
          p_selected_flag           => p_product_alloc_rec.selected_flag,
          p_target                  => NVL(p_product_alloc_rec.target, 0),
          p_lysp_sales              => NVL(p_product_alloc_rec.lysp_sales, 0),
          p_parent_product_allocation_id  => p_product_alloc_rec.parent_product_allocation_id,
          px_object_version_number  => l_object_version_number,
          p_creation_date           => SYSDATE,
          p_created_by              => FND_GLOBAL.USER_ID,
          p_last_update_date        => SYSDATE,
          p_last_updated_by         => FND_GLOBAL.USER_ID,
          p_last_update_login       => FND_GLOBAL.conc_login_id,
          p_attribute_category      => p_product_alloc_rec.attribute_category,
          p_attribute1  => p_product_alloc_rec.attribute1,
          p_attribute2  => p_product_alloc_rec.attribute2,
          p_attribute3  => p_product_alloc_rec.attribute3,
          p_attribute4  => p_product_alloc_rec.attribute4,
          p_attribute5  => p_product_alloc_rec.attribute5,
          p_attribute6  => p_product_alloc_rec.attribute6,
          p_attribute7  => p_product_alloc_rec.attribute7,
          p_attribute8  => p_product_alloc_rec.attribute8,
          p_attribute9  => p_product_alloc_rec.attribute9,
          p_attribute10  => p_product_alloc_rec.attribute10,
          p_attribute11  => p_product_alloc_rec.attribute11,
          p_attribute12  => p_product_alloc_rec.attribute12,
          p_attribute13  => p_product_alloc_rec.attribute13,
          p_attribute14  => p_product_alloc_rec.attribute14,
          p_attribute15  => p_product_alloc_rec.attribute15,
          px_org_id      => l_org_id
        );

     -- If succesfull, set the out variables
     -- If there is a error, calling routine will handle it
     x_product_allocation_Id          := l_product_allocation_id;
     x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF G_DEBUG THEN
      ozf_utility_pvt.debug_message('End Procedure: '|| l_api_name);
   END IF;

EXCEPTION
    WHEN OTHERS THEN
          X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
          THEN
             FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, 'Others exception in Create_Product_Alloc_Record');
          END IF;

END Create_Product_Alloc_Record;

PROCEDURE Create_Account_Alloc_Record(
              p_api_version         IN   NUMBER
             ,p_init_msg_list       IN   VARCHAR2 := fnd_api.g_false
             ,p_commit              IN   VARCHAR2 := fnd_api.g_false
             ,p_validation_level    IN   NUMBER   := fnd_api.g_valid_level_full
             ,x_return_status       OUT NOCOPY  VARCHAR2
             ,x_msg_count           OUT NOCOPY  NUMBER
             ,x_msg_data            OUT NOCOPY  VARCHAR2
             ,p_account_alloc_rec    IN ozf_account_allocations%ROWTYPE
             ,x_account_allocation_id OUT NOCOPY NUMBER )
IS
   l_api_name      VARCHAR(30) := 'Create_Account_Alloc_Record';

  l_account_allocation_id NUMBER;
  l_org_id                NUMBER;
  l_object_version_number NUMBER := 1;

BEGIN

   IF G_DEBUG THEN
      ozf_utility_pvt.debug_message('Start Procedure: '|| l_api_name);
   END IF;

     x_return_status := FND_API.G_RET_STS_SUCCESS;

     -- Call the Insert here
       l_account_allocation_id := get_account_allocation_id;

       Ozf_Account_Allocations_Pkg.Insert_Row(
          px_Account_allocation_id        => l_account_allocation_id,
          p_allocation_for                => p_account_alloc_rec.allocation_for,
          p_allocation_for_id             => p_account_alloc_rec.allocation_for_id,
          p_cust_account_id               => p_account_alloc_rec.cust_account_id,
          p_site_use_id                   => p_account_alloc_rec.site_use_id,
          p_site_use_code                 => 'SHIP_TO',
          p_location_id                   => p_account_alloc_rec.location_id,
          p_bill_to_site_use_id           => p_account_alloc_rec.bill_to_site_use_id,
          p_bill_to_location_id           => p_account_alloc_rec.bill_to_location_id,
          p_parent_party_id               => p_account_alloc_rec.parent_party_id,
          p_rollup_party_id               => p_account_alloc_rec.rollup_party_id,
          p_selected_flag                 => p_account_alloc_rec.selected_flag,
          p_target                        => p_account_alloc_rec.target,
          p_lysp_sales                    => p_account_alloc_rec.lysp_sales,
          p_parent_Account_allocation_id  => p_account_alloc_rec.parent_Account_allocation_id,
          px_object_version_number        => l_object_version_number,
          p_creation_date                 => SYSDATE,
          p_created_by                    => FND_GLOBAL.USER_ID,
          p_last_update_date              => SYSDATE,
          p_last_updated_by               => FND_GLOBAL.USER_ID,
          p_last_update_login             => FND_GLOBAL.conc_login_id,
          p_attribute_category            => p_account_alloc_rec.attribute_category,
          p_attribute1                    => p_account_alloc_rec.attribute1,
          p_attribute2                    => p_account_alloc_rec.attribute2,
          p_attribute3                    => p_account_alloc_rec.attribute3,
          p_attribute4                    => p_account_alloc_rec.attribute4,
          p_attribute5                    => p_account_alloc_rec.attribute5,
          p_attribute6                    => p_account_alloc_rec.attribute6,
          p_attribute7                    => p_account_alloc_rec.attribute7,
          p_attribute8                    => p_account_alloc_rec.attribute8,
          p_attribute9                    => p_account_alloc_rec.attribute9,
          p_attribute10                   => p_account_alloc_rec.attribute10,
          p_attribute11                   => p_account_alloc_rec.attribute11,
          p_attribute12                   => p_account_alloc_rec.attribute12,
          p_attribute13                   => p_account_alloc_rec.attribute13,
          p_attribute14                   => p_account_alloc_rec.attribute14,
          p_attribute15                   => p_account_alloc_rec.attribute15,
          px_org_id                       => l_org_id
        );


     -- If succesfull, set the out variables
     -- If there is a error, calling routine will handle it
     x_account_allocation_Id          := l_account_allocation_id;
     x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF G_DEBUG THEN
      ozf_utility_pvt.debug_message('End Procedure: '|| l_api_name);
   END IF;

EXCEPTION
    WHEN OTHERS THEN
          X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
          THEN
             FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, 'Others exception in Create_Account_Alloc_Record');
          END IF;

END Create_Account_Alloc_Record;


PROCEDURE Create_Time_Alloc_Record(
              p_api_version         IN   NUMBER
             ,p_init_msg_list       IN   VARCHAR2 := fnd_api.g_false
             ,p_commit              IN   VARCHAR2 := fnd_api.g_false
             ,p_validation_level    IN   NUMBER   := fnd_api.g_valid_level_full
             ,x_return_status       OUT NOCOPY  VARCHAR2
             ,x_msg_count           OUT NOCOPY  NUMBER
             ,x_msg_data            OUT NOCOPY  VARCHAR2
             ,p_time_alloc_rec      IN ozf_time_allocations%ROWTYPE
             ,x_time_allocation_id OUT NOCOPY NUMBER )
IS

   l_api_name      VARCHAR(30) := 'Create_Time_Alloc_Record';

  l_time_allocation_id    NUMBER;
  l_org_id                NUMBER;
  l_object_version_number NUMBER := 1;

BEGIN
   IF G_DEBUG THEN
      ozf_utility_pvt.debug_message('Start Procedure: '|| l_api_name);
   END IF;

     x_return_status := FND_API.G_RET_STS_SUCCESS;

     l_time_allocation_id := get_time_allocation_id;
     -- Call the Insert here

        Ozf_Time_Allocations_Pkg.Insert_Row(
           px_time_allocation_id  => l_time_allocation_id,
           p_allocation_for       => p_time_alloc_rec.allocation_for,
           p_allocation_for_id    => p_time_alloc_rec.allocation_for_id,
           p_time_id              => p_time_alloc_rec.time_id,
           p_period_type_id       => p_time_alloc_rec.period_type_id,
           p_target               => NVL(p_time_alloc_rec.target, 0),
           p_lysp_sales           => NVL(p_time_alloc_rec.lysp_sales, 0),
           px_object_version_number  => l_object_version_number,
           p_creation_date        => SYSDATE,
           p_created_by           => FND_GLOBAL.USER_ID,
           p_last_update_date     => SYSDATE,
           p_last_updated_by      => FND_GLOBAL.USER_ID,
           p_last_update_login    => FND_GLOBAL.conc_login_id,
           p_attribute_category   => p_time_alloc_rec.attribute_category,
           p_attribute1   => p_time_alloc_rec.attribute1,
           p_attribute2   => p_time_alloc_rec.attribute2,
           p_attribute3   => p_time_alloc_rec.attribute3,
           p_attribute4   => p_time_alloc_rec.attribute4,
           p_attribute5   => p_time_alloc_rec.attribute5,
           p_attribute6   => p_time_alloc_rec.attribute6,
           p_attribute7   => p_time_alloc_rec.attribute7,
           p_attribute8   => p_time_alloc_rec.attribute8,
           p_attribute9   => p_time_alloc_rec.attribute9,
           p_attribute10  => p_time_alloc_rec.attribute10,
           p_attribute11  => p_time_alloc_rec.attribute11,
           p_attribute12  => p_time_alloc_rec.attribute12,
           p_attribute13  => p_time_alloc_rec.attribute13,
           p_attribute14  => p_time_alloc_rec.attribute14,
           p_attribute15  => p_time_alloc_rec.attribute15,
           px_org_id      => l_org_id
         );

     -- If succesfull, set the out variables
     -- If there is a error, calling routine will handle it
     x_time_allocation_Id  := l_time_allocation_id;
     x_return_status       := FND_API.G_RET_STS_SUCCESS;

   IF G_DEBUG THEN
      ozf_utility_pvt.debug_message('End Procedure: '|| l_api_name);
   END IF;

EXCEPTION

    WHEN OTHERS THEN
          X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
          THEN
             FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, 'Others exception in Create_Time_Alloc_Record');
          END IF;

END Create_Time_Alloc_Record;



-- This should be a public procedure.
-- Users should be able to create add new Product Spread Records to
-- Existing Quotas
PROCEDURE Create_Quota_Product_Spread(
              p_api_version         IN   NUMBER
             ,p_init_msg_list       IN   VARCHAR2 := fnd_api.g_false
             ,p_commit              IN   VARCHAR2 := fnd_api.g_false
             ,p_validation_level    IN   NUMBER   := fnd_api.g_valid_level_full
             ,x_return_status       OUT NOCOPY  VARCHAR2
             ,x_msg_count           OUT NOCOPY  NUMBER
             ,x_msg_data            OUT NOCOPY  VARCHAR2
             ,p_allocation_for        IN VARCHAR2
             ,p_allocation_for_id     IN NUMBER
             ,p_quota_products_tbl    IN quota_products_tbl_type
             ,p_quota_prod_spread_tbl IN quota_prod_spread_tbl_type )
IS

   l_api_name              VARCHAR(30)   := 'create_quota_product_spread';
   l_product_alloc_rec      ozf_product_allocations%ROWTYPE;
   l_time_alloc_rec      ozf_time_allocations%ROWTYPE;

   l_product_allocation_id NUMBER;
   l_time_allocation_id    NUMBER;
   l_object_version_number NUMBER := 1;

BEGIN
  --
  SAVEPOINT CREATE_QUOTA_PRODUCT_SPREAD;

  IF G_DEBUG THEN
     ozf_utility_pvt.debug_message('Start Procedure: '|| l_api_name );
  END IF;

  --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- p_quota_products_tbl will already have record by now

  IF (p_quota_prod_spread_tbl.count  = 0 ) Then
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
         FND_MESSAGE.Set_Name('OZF', 'OZF_QUOTA_MISSING_PROD_SPREAD');
         FND_MSG_PUB.ADD;
      END IF;
      x_return_status := FND_API.G_RET_STS_ERROR;
      RAISE FND_API.G_EXC_ERROR;
  END IF;

  FOR l_product_counter IN 1..p_quota_products_tbl.count
  LOOP
       -- Insert record into ozf_product_allocations
       l_product_alloc_rec := NULL;

       IF p_allocation_for IS NOT NULL
       THEN
          l_product_alloc_rec.allocation_for    := p_allocation_for;
       END IF;

       IF p_allocation_for_id IS NOT NULL
       THEN
           l_product_alloc_rec.allocation_for_id := p_allocation_for_id;
       END IF;

       IF p_allocation_for = 'FUND'
       THEN
          l_product_alloc_rec.fund_id           := p_allocation_for_id;
       END IF;

       IF ( p_quota_products_tbl(l_product_counter).item_type = 'FAMILY')
       THEN
          l_product_alloc_rec.item_type := 'PRICING_ATTRIBUTE2';
       ELSIF ( p_quota_products_tbl(l_product_counter).item_type = 'PRODUCT')
       THEN
          l_product_alloc_rec.item_type := 'PRICING_ATTRIBUTE1';
       ELSE
          l_product_alloc_rec.item_type := 'OTHERS';
       END IF;

       l_product_alloc_rec.item_id       := p_quota_products_tbl(l_product_counter).item_id;
       l_product_alloc_rec.selected_flag := 'N';
       l_product_alloc_rec.target        := NVL(p_quota_products_tbl(l_product_counter).target, 0) ;
       l_product_alloc_rec.lysp_sales    := NVL(p_quota_products_tbl(l_product_counter).lysp_sales,0);

       Create_Product_Alloc_Record(
          p_api_version        => p_api_version
         ,p_init_msg_list      => p_init_msg_list
         ,p_commit             => p_commit
         ,p_validation_level   => p_validation_level
         ,x_return_status      => x_return_status
         ,x_msg_count          => x_msg_count
         ,x_msg_data           => x_msg_data
         ,p_product_alloc_rec     => l_product_alloc_rec
         ,x_product_allocation_id => l_product_allocation_id ) ;

        IF x_return_status = FND_API.G_RET_STS_ERROR THEN
           RAISE FND_API.g_exc_unexpected_error;
        ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.g_exc_unexpected_error;
        END IF;

       /* Target Spread Record Type
        time_allocation_id		NUMBER
        allocation_for			VARCHAR2(30)
        allocation_for_id		NUMBER
        allocation_for_tbl_index	NUMBER
        time_id			NUMBER
        period_type_id			NUMBER
        target				NUMBER
        lysp_sales			NUMBER);
       */

       FOR l_TimeSpread_Counter IN p_quota_prod_spread_tbl.first..p_quota_prod_spread_tbl.last
       LOOP
         --
           -- Create time spread record for the corresponding product record
           IF p_quota_prod_spread_tbl(l_TimeSpread_Counter).allocation_for_tbl_index = l_product_counter
           THEN

               l_time_alloc_rec     := NULL;

               l_time_alloc_rec.allocation_for     := 'PROD';
               l_time_alloc_rec.allocation_for_id  := l_product_allocation_id;
               l_time_alloc_rec.time_id            := p_quota_prod_spread_tbl(l_TimeSpread_Counter).time_id;
               l_time_alloc_rec.period_type_id     := p_quota_prod_spread_tbl(l_TimeSpread_Counter).period_type_id;
               l_time_alloc_rec.target             := p_quota_prod_spread_tbl(l_TimeSpread_Counter).target;
               l_time_alloc_rec.lysp_sales         := p_quota_prod_spread_tbl(l_TimeSpread_Counter).lysp_sales;

               validate_time_period (l_time_alloc_rec.period_type_id,
                                     l_time_alloc_rec.time_id ,
                                     x_return_status);

              IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                 RAISE FND_API.g_exc_unexpected_error;
              ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 RAISE FND_API.g_exc_unexpected_error;
              END IF;

               Create_Time_Alloc_Record(
                  p_api_version        => p_api_version
                 ,p_init_msg_list      => p_init_msg_list
                 ,p_commit             => p_commit
                 ,p_validation_level   => p_validation_level
                 ,x_return_status      => x_return_status
                 ,x_msg_count          => x_msg_count
                 ,x_msg_data           => x_msg_data
                 ,p_time_alloc_rec     => l_time_alloc_rec
                 ,x_time_allocation_id => l_time_allocation_id ) ;

              IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                 RAISE FND_API.g_exc_unexpected_error;
              ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 RAISE FND_API.g_exc_unexpected_error;
              END IF;

           END IF;
         --
      END LOOP; -- Time counter

  END LOOP; -- Product counter
   --

  IF G_DEBUG THEN
     ozf_utility_pvt.debug_message('End Procedure: '|| l_api_name );
  END IF;

   FND_MSG_PUB.Count_And_Get (
    p_encoded => FND_API.G_FALSE,
    p_count   =>   x_msg_count,
    p_data    =>   x_msg_data
   );

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
   ROLLBACK TO create_quota_product_spread;
   x_return_status := FND_API.G_RET_STS_ERROR;
   -- Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                            ,p_count   => x_msg_count
                            ,p_data    => x_msg_data
                            );
WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   ROLLBACK TO create_quota_product_spread;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   -- Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                            ,p_count   => x_msg_count
                            ,p_data    => x_msg_data
                            );
WHEN OTHERS THEN
   ROLLBACK TO create_quota_product_spread;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
   END IF;
   -- Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                            ,p_count   => x_msg_count
                            ,p_data    => x_msg_data
                            );

END Create_Quota_Product_Spread;

PROCEDURE Create_Quota_Account_Spread(
              p_api_version         IN   NUMBER
             ,p_init_msg_list       IN   VARCHAR2 := fnd_api.g_false
             ,p_commit              IN   VARCHAR2 := fnd_api.g_false
             ,p_validation_level    IN   NUMBER   := fnd_api.g_valid_level_full
             ,x_return_status       OUT NOCOPY  VARCHAR2
             ,x_msg_count           OUT NOCOPY  NUMBER
             ,x_msg_data            OUT NOCOPY  VARCHAR2
             ,p_fund_id             IN  NUMBER
             ,p_quota_accounts_tbl  IN quota_accounts_tbl_type
             ,p_account_spread_tbl  IN account_spread_tbl_type
             ,p_account_products_tbl IN account_products_tbl_type
             ,p_acct_prod_spread_tbl IN acct_prod_spread_tbl_type )
IS

  l_quota_accounts_tbl  quota_accounts_tbl_type := p_quota_accounts_tbl;
  l_account_spread_tbl  account_spread_tbl_type := p_account_spread_tbl;
  l_account_products_tbl account_products_tbl_type := p_account_products_tbl;
  l_acct_prod_spread_tbl acct_prod_spread_tbl_type := p_acct_prod_spread_tbl;

  l_account_allocation_id NUMBER;
  l_time_allocation_id    NUMBER;
  l_account_alloc_rec ozf_account_allocations%ROWTYPE;
  l_time_alloc_rec ozf_time_allocations%ROWTYPE;

  l_prod_acct_index 		NUMBER;
  l_prod_sprd_index 		NUMBER ;
  l_prod_for_this_acct_tbl      quota_products_tbl_type;
  l_prod_sprd_for_this_acct_tbl quota_prod_spread_tbl_type;

  l_ship_to_site_use_id		NUMBER;
  l_cust_account_id		NUMBER;
  l_location_id			NUMBER;
  l_bill_to_site_use_id		NUMBER;
  l_bill_to_location_id		NUMBER;
  l_parent_party_id		NUMBER;
  l_rollup_party_id		NUMBER;

  CURSOR c_site_info (p_site_use_id NUMBER,
                      p_site_use_code VARCHAR2)
  IS
     SELECT party_site.party_id,
            acct_site.cust_account_id,
            party_site.location_id,
	    site_use.bill_to_site_use_id
     FROM hz_cust_acct_sites_all acct_site,
          hz_party_sites         party_site,
          hz_cust_site_uses_all  site_use
     WHERE site_use.site_use_id = p_site_use_id
     AND   site_use.site_use_code = p_site_use_code
     AND   site_use.cust_acct_site_id = acct_site.cust_acct_site_id
     AND   acct_site.party_site_id = party_site.party_site_id ;

BEGIN
   --
   SAVEPOINT create_quota_account_spread;
   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF (p_quota_accounts_tbl.count  = 0 ) Then
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
         FND_MESSAGE.Set_Name('OZF', 'OZF_QUOTA_MISSING_ACCOUNTS');
         FND_MSG_PUB.ADD;
      END IF;
      x_return_status := FND_API.G_RET_STS_ERROR;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   IF (p_account_spread_tbl.count  = 0 ) Then
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
         FND_MESSAGE.Set_Name('OZF', 'OZF_QUOTA_MISSING_ACCT_SPREAD');
         FND_MSG_PUB.ADD;
      END IF;
      x_return_status := FND_API.G_RET_STS_ERROR;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   FOR l_account_counter IN 1..p_quota_accounts_tbl.count
   LOOP
      --
       l_account_alloc_rec := NULL;

       l_account_alloc_rec.allocation_for    := 'FUND';
       l_account_alloc_rec.allocation_for_id := p_fund_id;
       l_account_alloc_rec.selected_flag     := p_quota_accounts_tbl(l_account_counter).selected_flag;
       l_ship_to_site_use_id              := p_quota_accounts_tbl(l_account_counter).ship_to_site_use_id;

       IF l_ship_to_site_use_id <> -9999
       THEN
          --
          OPEN c_site_info(l_ship_to_site_use_id,'SHIP_TO');
          FETCH c_site_info INTO l_rollup_party_id,l_cust_account_id,l_location_id,l_bill_to_site_use_id;
          CLOSE c_site_info;
          --
       ELSE
          -- UNALLOC Record
          l_cust_account_id := -9999;
          l_bill_to_site_use_id := -9999;
          l_rollup_party_id := -9999;
          --
       END IF;

       IF (l_rollup_party_id IS NULL) Then
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
             FND_MESSAGE.Set_Name('OZF', 'OZF_QUOTA_INVALID_SHIP_TO');
             FND_MSG_PUB.ADD;
          END IF;
          x_return_status := FND_API.G_RET_STS_ERROR;
          RAISE FND_API.G_EXC_ERROR;
       END IF;

       l_account_alloc_rec.cust_account_id     := l_cust_account_id;
       l_account_alloc_rec.location_id         := l_location_id;
       l_account_alloc_rec.bill_to_site_use_id := l_bill_to_site_use_id;
       l_account_alloc_rec.rollup_party_id     := l_rollup_party_id;

       IF l_bill_to_site_use_id IS NOT NULL
       THEN

          IF l_bill_to_site_use_id <> -9999
          THEN
            --
            OPEN c_site_info(l_bill_to_site_use_id,'BILL_TO');
            FETCH c_site_info INTO l_parent_party_id,l_cust_account_id,l_bill_to_location_id,l_bill_to_site_use_id;
            CLOSE c_site_info;
            l_account_alloc_rec.bill_to_location_id := l_bill_to_location_id;
            l_account_alloc_rec.parent_party_id     := l_parent_party_id;
            --
          ELSE
            --
            l_account_alloc_rec.parent_party_id := -9999;
            --
          END IF;

       END IF;

       l_account_alloc_rec.site_use_id       := p_quota_accounts_tbl(l_account_counter).ship_to_site_use_id;
       l_account_alloc_rec.target            := p_quota_accounts_tbl(l_account_counter).target;
       l_account_alloc_rec.lysp_sales        := p_quota_accounts_tbl(l_account_counter).lysp_sales;

       Create_Account_Alloc_Record(
          p_api_version        => p_api_version
         ,p_init_msg_list      => p_init_msg_list
         ,p_commit             => p_commit
         ,p_validation_level   => p_validation_level
         ,x_return_status      => x_return_status
         ,x_msg_count          => x_msg_count
         ,x_msg_data           => x_msg_data
         ,p_account_alloc_rec     => l_account_alloc_rec
         ,x_account_allocation_id => l_account_allocation_id ) ;

       IF x_return_status = FND_API.G_RET_STS_ERROR THEN
           RAISE FND_API.g_exc_unexpected_error;
       ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.g_exc_unexpected_error;
       END IF;

       IF l_account_alloc_rec.parent_party_id = -9999
       THEN
          -- This is the UNALLOC record. It will not have
          -- Time Spread or Product Allocation
          GOTO NEXT_ACCT;
       END IF;

       -- Done Creating Account Allocation Record
       -- Start Creating Time Spread for the Account Record
       FOR l_TimeSpread_Counter IN p_account_spread_tbl.first..p_account_spread_tbl.last
       LOOP
           --
           -- Create time spread record for the corresponding product record
           IF p_account_spread_tbl(l_TimeSpread_Counter).allocation_for_tbl_index = l_account_counter
           THEN

               l_time_alloc_rec     := NULL;

               l_time_alloc_rec.allocation_for     := 'CUST';
               l_time_alloc_rec.allocation_for_id  := l_account_allocation_id;
               l_time_alloc_rec.time_id            := p_account_spread_tbl(l_TimeSpread_Counter).time_id;
               l_time_alloc_rec.period_type_id     := p_account_spread_tbl(l_TimeSpread_Counter).period_type_id;
               l_time_alloc_rec.target             := p_account_spread_tbl(l_TimeSpread_Counter).target;
               l_time_alloc_rec.lysp_sales         := p_account_spread_tbl(l_TimeSpread_Counter).lysp_sales;

               validate_time_period (l_time_alloc_rec.period_type_id,
                                     l_time_alloc_rec.time_id ,
                                     x_return_status);

              IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                 RAISE FND_API.g_exc_unexpected_error;
              ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 RAISE FND_API.g_exc_unexpected_error;
              END IF;

               Create_Time_Alloc_Record(
                  p_api_version        => p_api_version
                 ,p_init_msg_list      => p_init_msg_list
                 ,p_commit             => p_commit
                 ,p_validation_level   => p_validation_level
                 ,x_return_status      => x_return_status
                 ,x_msg_count          => x_msg_count
                 ,x_msg_data           => x_msg_data
                 ,p_time_alloc_rec     => l_time_alloc_rec
                 ,x_time_allocation_id => l_time_allocation_id ) ;

              IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                 RAISE FND_API.g_exc_unexpected_error;
              ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 RAISE FND_API.g_exc_unexpected_error;
              END IF;

           END IF;
         --
       END LOOP; -- Time counter
       -- Done Creating Time Spread for the Account

       -- Create Account Products and Product Spread if provided
       -- Account Counter is l_account_counter
       -- account_allocation_id is l_account_allocation_id

       IF (p_account_products_tbl.COUNT = 0 OR p_acct_prod_spread_tbl.COUNT = 0 )
       THEN
          GOTO NEXT_ACCT;
       END IF;

       l_prod_acct_index := 0;
       l_prod_sprd_index := 0;
       l_prod_for_this_acct_tbl.DELETE;
       l_prod_sprd_for_this_acct_tbl.DELETE;

       FOR l_AccountProduct_Counter IN 1..p_account_products_tbl.COUNT
       LOOP
           --
           -- Populate l_prod_for_acct_tbl
           IF ( p_account_products_tbl(l_AccountProduct_Counter).allocation_for_tbl_index = l_account_counter )
           THEN
               --
               l_prod_acct_index := l_prod_acct_index + 1;
               l_prod_for_this_acct_tbl(l_prod_acct_index) := p_account_products_tbl(l_AccountProduct_Counter);

               FOR  l_AcctProdSprd_Counter IN 1..p_acct_prod_spread_tbl.COUNT
               LOOP
                   -- Populate l_prod_spread_for_acct_tbl
                   --
                   IF (p_acct_prod_spread_tbl(l_AcctProdSprd_Counter).allocation_for_tbl_index = l_AccountProduct_Counter)
                   THEN
                       --
                       l_prod_sprd_index := l_prod_sprd_index + 1;
                       l_prod_sprd_for_this_acct_tbl(l_prod_sprd_index) := p_acct_prod_spread_tbl(l_AcctProdSprd_Counter);
                   END IF;
                   --
               END LOOP;
               --
           END IF; -- End account-product match
           --
       END LOOP; -- Done scanning products for the account

       -- Create Product Spread for the account
       Create_Quota_Product_Spread(
          p_api_version        => p_api_version
         ,p_init_msg_list      => p_init_msg_list
         ,p_commit             => p_commit
         ,p_validation_level   => p_validation_level
         ,x_return_status      => x_return_status
         ,x_msg_count          => x_msg_count
         ,x_msg_data           => x_msg_data
         ,p_allocation_for     => 'CUST'
         ,p_allocation_for_id  => l_account_allocation_id
         ,p_quota_products_tbl    => l_prod_for_this_acct_tbl
         ,p_quota_prod_spread_tbl => l_prod_sprd_for_this_acct_tbl );

       IF x_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.g_exc_unexpected_error;
        ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.g_exc_unexpected_error;
        END IF;

       <<NEXT_ACCT>>
       NULL;
   END LOOP; -- Process Next Account

   --
   FND_MSG_PUB.Count_And_Get (
    p_encoded => FND_API.G_FALSE,
    p_count   =>   x_msg_count,
    p_data    =>   x_msg_data
   );

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
   ROLLBACK TO create_quota_account_spread;
   x_return_status := FND_API.G_RET_STS_ERROR;
   -- Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                            ,p_count   => x_msg_count
                            ,p_data    => x_msg_data
                            );
WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   ROLLBACK TO create_quota_account_spread;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   -- Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                            ,p_count   => x_msg_count
                            ,p_data    => x_msg_data
                            );
WHEN OTHERS THEN
   ROLLBACK TO create_quota_account_spread;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,'Create_Quota_Account_Spread');
   END IF;
   -- Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                            ,p_count   => x_msg_count
                            ,p_data    => x_msg_data
                            );

END Create_Quota_Account_Spread;

---------------------------------------------------------------------
-- PROCEDURE
--    create_quota
--
-- PURPOSE
--    Create a new quota.
--
-- PARAMETERS
--    p_quota_rec: the new record to be inserted
--    x_quota_id: return the quota_id of the new quota
--
-- HISTORY
--    06/29/2005  kdass Created
---------------------------------------------------------------------
PROCEDURE create_quota(
   p_api_version                IN              NUMBER
  ,p_init_msg_list              IN              VARCHAR2 := fnd_api.g_false
  ,p_commit                     IN              VARCHAR2 := fnd_api.g_false
  ,p_validation_level           IN              NUMBER   := fnd_api.g_valid_level_full
  ,x_return_status              OUT NOCOPY      VARCHAR2
  ,x_msg_count                  OUT NOCOPY      NUMBER
  ,x_msg_data                   OUT NOCOPY      VARCHAR2
  ,p_method                     IN              VARCHAR2 := 'MANUAL'
  ,p_quota_rec                  IN              quota_rec_type
  ,p_quota_markets_tbl          IN              quota_markets_tbl_type
  ,p_quota_products_tbl         IN              quota_products_tbl_type
  ,p_quota_prod_spread_tbl   	IN              quota_prod_spread_tbl_type
  ,p_quota_accounts_tbl         IN              quota_accounts_tbl_type
  ,p_account_spread_tbl         IN              account_spread_tbl_type
  ,p_account_products_tbl       IN              account_products_tbl_type
  ,p_acct_prod_spread_tbl       IN              acct_prod_spread_tbl_type
  ,p_alloc_rec                  IN              alloc_rec_type
  ,x_quota_id                   OUT NOCOPY     NUMBER
  )
IS
l_api_name              VARCHAR(30)   := 'Create_Quota';
l_mode                  VARCHAR2(6)   := 'CREATE';
l_alloc_id              NUMBER;

l_quota_rec             quota_rec_type             := p_quota_rec;
l_quota_markets_tbl     quota_markets_tbl_type     := p_quota_markets_tbl;
l_quota_products_tbl    quota_products_tbl_type    := p_quota_products_tbl;
l_quota_prod_spread_tbl quota_prod_spread_tbl_type := p_quota_prod_spread_tbl;
l_quota_accounts_tbl    quota_accounts_tbl_type    := p_quota_accounts_tbl;
l_account_spread_tbl    account_spread_tbl_type    := p_account_spread_tbl;
l_account_products_tbl  account_products_tbl_type  := p_account_products_tbl;
l_acct_prod_spread_tbl  acct_prod_spread_tbl_type  := p_acct_prod_spread_tbl;
l_alloc_rec             alloc_rec_type             := p_alloc_rec;

BEGIN

   SAVEPOINT create_quota;

   IF G_DEBUG THEN
     ozf_utility_pvt.debug_message('Start Procedure: '|| l_api_name );
   END IF;

   -- First Validate p_method ---------------------------------------------------
   -- Default is 'MANUAL'
   IF p_method NOT IN ('MANUAL', 'ALLOCATION')
   THEN
      --
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
           fnd_message.set_name('OZF', 'OZF_QUOTA_INVALID_COL_VALUE');
           fnd_message.set_token('COL_NAME', 'P_METHOD');
           fnd_msg_pub.add;
      END IF;
      x_return_status := fnd_api.g_ret_sts_error;
      RAISE fnd_api.g_exc_error;
      --
   END IF;

   ------------------------------------------------------------------------------

   -- Products are always required
   IF (p_quota_products_tbl.COUNT = 0 )
   THEN
         IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
            FND_MESSAGE.Set_Name('OZF', 'OZF_QUOTA_MISSING_PRODUCTS');
            FND_MSG_PUB.ADD;
         END IF;
         x_return_status := FND_API.G_RET_STS_ERROR;
         raise FND_API.G_EXC_ERROR;
   END IF;

   -- Create_Quota_Header will create quota and associate products
   -- These both are always required by any quota

   Create_Quota_Header(
          p_api_version        => p_api_version
         ,p_init_msg_list      => p_init_msg_list
         ,p_commit             => p_commit
         ,p_validation_level   => p_validation_level
         ,x_return_status      => x_return_status
         ,x_msg_count          => x_msg_count
         ,x_msg_data           => x_msg_data
         ,p_method             => p_method
         ,p_mode               => l_mode
         ,p_quota_rec          => l_quota_rec
         ,p_quota_markets_tbl  => l_quota_markets_tbl
         ,p_quota_products_tbl => l_quota_products_tbl
         ,x_quota_id            => x_quota_id  );

   IF G_DEBUG THEN
      ozf_utility_pvt.debug_message('Quota ID: ' || x_quota_id);
      ozf_utility_pvt.debug_message('Return Status: ' || x_return_status);
   END IF;

   IF x_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.g_exc_unexpected_error;
   ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   IF p_method = 'ALLOCATION'
   THEN
     --
        generate_product_spread(
          p_api_version        => p_api_version
         ,p_init_msg_list      => p_init_msg_list
         ,p_commit             => p_commit
         ,p_validation_level   => p_validation_level
         ,p_quota_id           => x_quota_id
         ,x_return_status      => x_return_status
         ,x_error_number       =>  x_msg_count
         ,x_error_message      => x_msg_data );

        IF x_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.g_exc_unexpected_error;
        ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.g_exc_unexpected_error;
        END IF;

        l_alloc_rec.quota_id := x_quota_id;

        create_allocation(
          p_api_version        => p_api_version
         ,p_init_msg_list      => p_init_msg_list
         ,p_commit             => p_commit
         ,p_validation_level   => p_validation_level
         ,p_alloc_rec          => l_alloc_rec
         ,x_return_status      => x_return_status
         ,x_msg_count          => x_msg_count
         ,x_msg_data           => x_msg_data
         ,x_alloc_id           => l_alloc_id);

        IF x_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.g_exc_unexpected_error;
        ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.g_exc_unexpected_error;
        END IF;

        publish_allocation(
          p_api_version        => p_api_version
         ,p_init_msg_list      => p_init_msg_list
         ,p_commit             => p_commit
         ,p_validation_level   => p_validation_level
         ,p_alloc_id          =>  l_alloc_id
         ,x_return_status      => x_return_status
         ,x_msg_count          => x_msg_count
         ,x_msg_data           => x_msg_data );

       IF x_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.g_exc_unexpected_error;
        ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.g_exc_unexpected_error;
        END IF;

   END IF;

   IF p_method = 'MANUAL'
   THEN
     --
       Create_Quota_Product_Spread(
          p_api_version        => p_api_version
         ,p_init_msg_list      => p_init_msg_list
         ,p_commit             => p_commit
         ,p_validation_level   => p_validation_level
         ,x_return_status      => x_return_status
         ,x_msg_count          => x_msg_count
         ,x_msg_data           => x_msg_data
         ,p_allocation_for     => 'FUND'
         ,p_allocation_for_id  => x_quota_id
         ,p_quota_products_tbl => l_quota_products_tbl
         ,p_quota_prod_spread_tbl => l_quota_prod_spread_tbl );

       IF x_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.g_exc_unexpected_error;
        ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.g_exc_unexpected_error;
        END IF;

       IF p_quota_accounts_tbl.COUNT <> 0
       THEN
         --
           Create_Quota_Account_Spread(
              p_api_version        => p_api_version
             ,p_init_msg_list      => p_init_msg_list
             ,p_commit             => p_commit
             ,p_validation_level   => p_validation_level
             ,x_return_status      => x_return_status
             ,x_msg_count          => x_msg_count
             ,x_msg_data           => x_msg_data
             ,p_fund_id            => x_quota_id
             ,p_quota_accounts_tbl => l_quota_accounts_tbl
             ,p_account_spread_tbl => l_account_spread_tbl
             ,p_account_products_tbl  => l_account_products_tbl
             ,p_acct_prod_spread_tbl  => l_acct_prod_spread_tbl);
          --
       END IF;

       IF x_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.g_exc_unexpected_error;
       ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.g_exc_unexpected_error;
       END IF;

     --
   END IF;


   IF G_DEBUG THEN
     ozf_utility_pvt.debug_message('End Procedure: '|| l_api_name );
   END IF;

   FND_MSG_PUB.Count_And_Get (
    p_encoded => FND_API.G_FALSE,
    p_count   =>   x_msg_count,
    p_data    =>   x_msg_data
   );

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
   ROLLBACK TO create_quota;
   x_return_status := FND_API.G_RET_STS_ERROR;
   -- Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                            ,p_count   => x_msg_count
                            ,p_data    => x_msg_data
                            );
WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   ROLLBACK TO create_quota;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   -- Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                            ,p_count   => x_msg_count
                            ,p_data    => x_msg_data
                            );
WHEN OTHERS THEN
   ROLLBACK TO create_quota;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
   END IF;
   -- Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                            ,p_count   => x_msg_count
                            ,p_data    => x_msg_data
                            );
END create_quota;

---------------------------------------------------------------------
-- PROCEDURE
--    update_quota
--
-- PURPOSE
--    Update quota.
--
-- PARAMETERS
--    p_quota_rec: the record with new items.
--
-- HISTORY
--    06/29/2005  kdass Created
---------------------------------------------------------------------
PROCEDURE update_quota(
   p_api_version        IN              NUMBER
  ,p_init_msg_list      IN              VARCHAR2 := fnd_api.g_false
  ,p_commit             IN              VARCHAR2 := fnd_api.g_false
  ,p_validation_level   IN              NUMBER   := fnd_api.g_valid_level_full
  ,x_return_status      OUT NOCOPY      VARCHAR2
  ,x_msg_count          OUT NOCOPY      NUMBER
  ,x_msg_data           OUT NOCOPY      VARCHAR2
  ,p_quota_rec          IN              quota_rec_type
  )
IS
l_api_name               VARCHAR(30) := 'update_quota';
l_mode                   VARCHAR2(6) := 'UPDATE';
l_quota_rec              quota_rec_type := p_quota_rec;
l_fund_rec               OZF_Funds_Pub.fund_rec_type;
l_api_version            NUMBER := p_api_version;
l_init_msg_list          VARCHAR2(100) := p_init_msg_list;
l_validation_level       NUMBER := p_validation_level;
l_commit                 VARCHAR2(1) := p_commit;
l_quota_number           VARCHAR2(200);
l_short_name             VARCHAR2(200);
l_custom_setup_id        NUMBER;
l_description            VARCHAR2(2000);
l_status_code            VARCHAR2(50);
l_user_status_id         NUMBER;
l_start_period_name      VARCHAR2(20);
l_end_period_name        VARCHAR2(20);
l_quota_amount           NUMBER;
l_currency_code_tc       VARCHAR2(10);
l_owner                  NUMBER;
l_threshold_id           NUMBER;
l_product_spread_time_id NUMBER;
l_object_version_number  NUMBER;
l_quota_id               NUMBER := l_quota_rec.quota_id;
l_modifier_list_rec      ozf_offer_pub.modifier_list_rec_type;
l_modifier_line_tbl      ozf_offer_pub.modifier_line_tbl_type;
l_vo_pbh_tbl             ozf_offer_pub.vo_disc_tbl_type;
l_vo_dis_tbl             ozf_offer_pub.vo_disc_tbl_type;
l_vo_prod_tbl            ozf_offer_pub.vo_prod_tbl_type;
l_qualifier_tbl          ozf_offer_pub.qualifiers_tbl_type;
l_vo_mo_tbl              ozf_offer_pub.vo_mo_tbl_type;

CURSOR c_quota_id (quota_number IN VARCHAR2) IS
   SELECT fund_id
   FROM  ozf_funds_all_b
   WHERE fund_number = quota_number;

CURSOR c_quota_details (quota_id IN NUMBER) IS
   SELECT fund_number, short_name, custom_setup_id, description, status_code,
          user_status_id, start_period_name, end_period_name, original_budget,
          currency_code_tc, owner, threshold_id, product_spread_time_id, object_version_number
   FROM  ozf_funds_all_vl
   WHERE fund_id = quota_id;

BEGIN

   SAVEPOINT update_quota;

   IF l_quota_rec.quota_id IS NULL AND l_quota_rec.quota_number IS NOT NULL THEN
      OPEN c_quota_id (l_quota_rec.quota_number);
      FETCH c_quota_id INTO l_quota_id;
      CLOSE c_quota_id;
   END IF;

   IF G_DEBUG THEN
      ozf_utility_pvt.debug_message(l_api_name || ': l_quota_id :' || l_quota_id);
   END IF;

   IF l_quota_id IS NOT NULL THEN
      OPEN c_quota_details (l_quota_id);
      FETCH c_quota_details INTO l_quota_number, l_short_name, l_custom_setup_id, l_description,
                                 l_status_code, l_user_status_id, l_start_period_name, l_end_period_name,
                                 l_quota_amount, l_currency_code_tc, l_owner, l_threshold_id,
                                 l_product_spread_time_id, l_object_version_number;
      CLOSE c_quota_details;
   END IF;

   IF G_DEBUG THEN
      ozf_utility_pvt.debug_message(l_api_name || ': l_quota_amount :' || l_quota_amount);
      ozf_utility_pvt.debug_message(l_api_name || ': l_product_spread_time_id :' || l_product_spread_time_id);
   END IF;

   l_quota_rec.quota_number := NVL(l_quota_rec.quota_number,l_quota_number);
   l_quota_rec.short_name := NVL(l_quota_rec.short_name,l_short_name);
   l_quota_rec.custom_setup_id := NVL(l_quota_rec.custom_setup_id,l_custom_setup_id);
   l_quota_rec.description := NVL(l_quota_rec.description,l_description);
   l_quota_rec.status_code := NVL(l_quota_rec.status_code,l_status_code);
   l_quota_rec.start_period_name := NVL(l_quota_rec.start_period_name,l_start_period_name);
   l_quota_rec.end_period_name := NVL(l_quota_rec.end_period_name,l_end_period_name);
   l_quota_rec.quota_amount := NVL(l_quota_rec.quota_amount,l_quota_amount);
   l_quota_rec.currency_code_tc := NVL(l_quota_rec.currency_code_tc,l_currency_code_tc);
   l_quota_rec.owner := NVL(l_quota_rec.owner,l_owner);
   l_quota_rec.threshold_id := NVL(l_quota_rec.threshold_id,l_threshold_id);
   l_quota_rec.product_spread_time_id := NVL(l_quota_rec.product_spread_time_id,l_product_spread_time_id);


   validate_quota_attributes( p_quota_rec     => l_quota_rec
                             ,p_mode          => 'UPDATE'
                             ,p_method        =>  'MANUAL'
                             ,p_fund_rec      => l_fund_rec
                             ,x_return_status => x_return_status);

   IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
      RAISE fnd_api.g_exc_unexpected_error;
   ELSIF x_return_status = fnd_api.g_ret_sts_error THEN
      RAISE fnd_api.g_exc_error;
   END IF;

   l_fund_rec.fund_id := l_quota_rec.quota_id;
   l_fund_rec.fund_number := l_quota_rec.quota_number;
   l_fund_rec.fund_type := 'QUOTA';
   l_fund_rec.short_name := l_quota_rec.short_name;
   l_fund_rec.custom_setup_id := l_quota_rec.custom_setup_id;
   l_fund_rec.description := l_quota_rec.description;
   l_fund_rec.category_id := '10001';
   l_fund_rec.status_code := l_quota_rec.status_code;
   l_fund_rec.user_status_id := l_quota_rec.user_status_id;
   l_fund_rec.start_period_name := l_quota_rec.start_period_name;
   l_fund_rec.end_period_name := l_quota_rec.end_period_name;
   l_fund_rec.start_date_active := l_quota_rec.start_date_active;
   l_fund_rec.end_date_active := l_quota_rec.end_date_active;
   l_fund_rec.original_budget := l_quota_rec.quota_amount;
   l_fund_rec.currency_code_tc := l_quota_rec.currency_code_tc;
   l_fund_rec.owner := l_quota_rec.owner;
   l_fund_rec.threshold_id := l_quota_rec.threshold_id;
   l_fund_rec.product_spread_time_id := l_quota_rec.product_spread_time_id;
   -- l_fund_rec.object_version_number := l_quota_rec.object_version_number;

   -- update quota
   ozf_funds_pub.update_fund(p_api_version       => l_api_version
                            ,p_init_msg_list     => l_init_msg_list
                            ,p_commit            => l_commit
                            ,p_validation_level  => l_validation_level
                            ,x_return_status     => x_return_status
                            ,x_msg_count         => x_msg_count
                            ,x_msg_data          => x_msg_data
                            ,p_fund_rec          => l_fund_rec
                            ,p_modifier_list_rec => l_modifier_list_rec
                            ,p_modifier_line_tbl => l_modifier_line_tbl
                            ,p_vo_pbh_tbl        => l_vo_pbh_tbl
                            ,p_vo_dis_tbl        => l_vo_dis_tbl
                            ,p_vo_prod_tbl       => l_vo_prod_tbl
                            ,p_qualifier_tbl     => l_qualifier_tbl
                            ,p_vo_mo_tbl         => l_vo_mo_tbl
                            );

   IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
      RAISE fnd_api.g_exc_unexpected_error;
   ELSIF x_return_status = fnd_api.g_ret_sts_error THEN
      RAISE fnd_api.g_exc_error;
   END IF;

   FND_MSG_PUB.Count_And_Get (
    p_encoded => FND_API.G_FALSE,
    p_count   =>   x_msg_count,
    p_data    =>   x_msg_data
   );

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
   ROLLBACK TO update_quota;
   x_return_status := FND_API.G_RET_STS_ERROR;
   -- Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                            ,p_count   => x_msg_count
                            ,p_data    => x_msg_data
                            );
WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   ROLLBACK TO update_quota;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   -- Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                            ,p_count   => x_msg_count
                            ,p_data    => x_msg_data
                            );
WHEN OTHERS THEN
   ROLLBACK TO update_quota;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
   END IF;
   -- Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                            ,p_count   => x_msg_count
                            ,p_data    => x_msg_data
                            );
END Update_Quota;

PROCEDURE Update_Quota_Product_Spread(
              p_api_version         IN   NUMBER
             ,p_init_msg_list       IN   VARCHAR2 := fnd_api.g_false
             ,p_commit              IN   VARCHAR2 := fnd_api.g_false
             ,p_validation_level    IN   NUMBER   := fnd_api.g_valid_level_full
             ,x_return_status       OUT NOCOPY  VARCHAR2
             ,x_msg_count           OUT NOCOPY  NUMBER
             ,x_msg_data            OUT NOCOPY  VARCHAR2
             ,p_quota_products_tbl    IN quota_products_tbl_type
             ,p_quota_prod_spread_tbl IN quota_prod_spread_tbl_type )
IS

   l_api_name              VARCHAR(30)   := 'update_quota_product_spread';
   l_product_allocation_id NUMBER;
   l_time_allocation_id NUMBER;
   l_object_version_number NUMBER;

   CURSOR c_chk_prod_alloc_id (p_product_allocation_id NUMBER) IS
   SELECT product_allocation_id,
          object_version_number
   FROM ozf_product_allocations
   WHERE product_allocation_id = p_product_allocation_id;

   CURSOR c_chk_time_alloc_id (p_time_allocation_id NUMBER) IS
   SELECT time_allocation_id,
          object_version_number
   FROM ozf_time_allocations
   WHERE time_allocation_id = p_time_allocation_id;

BEGIN
  --
  SAVEPOINT UPDATE_QUOTA_PRODUCT_SPREAD;

  IF G_DEBUG THEN
     ozf_utility_pvt.debug_message('Start Procedure: '|| l_api_name );
  END IF;

  --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  ---------------------------------------------

  IF  p_quota_products_tbl.COUNT > 0
  THEN
      --
      FOR l_prod_alloc_counter IN 1..p_quota_products_tbl.COUNT
      LOOP
          --
          OPEN c_chk_prod_alloc_id ( p_quota_products_tbl(l_prod_alloc_counter).product_allocation_id);
          FETCH c_chk_prod_alloc_id INTO l_product_allocation_id ,
                                         l_object_version_number;
          CLOSE c_chk_prod_alloc_id;

          IF l_product_allocation_id IS NULL
          THEN
              --
              IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error)
              THEN
                   fnd_message.set_name('OZF', 'OZF_QUOTA_INVALID_COL_VALUE');
                   fnd_message.set_token('COL_NAME', 'PRODUCT_ALLOCATION_ID');
                   fnd_msg_pub.add;
              END IF;
              x_return_status := fnd_api.g_ret_sts_error;
              RETURN;
              --
          END IF;


          UPDATE ozf_product_allocations
          SET target     = NVL(p_quota_products_tbl(l_prod_alloc_counter).target, target),
              lysp_sales = NVL(p_quota_products_tbl(l_prod_alloc_counter).lysp_sales, lysp_sales),
              object_version_number = l_object_version_number + 1 ,
              last_update_date = SYSDATE,
              last_updated_by  = FND_GLOBAL.USER_ID
          WHERE product_allocation_id = l_product_allocation_id;
          --
      END LOOP; -- Done updating Product Allocations
      --
  END IF;

  IF p_quota_prod_spread_tbl.COUNT > 0
  THEN
      --
      FOR l_prod_sprd_counter IN 1..p_quota_prod_spread_tbl.COUNT
      LOOP
         --
          OPEN c_chk_time_alloc_id (p_quota_prod_spread_tbl(l_prod_sprd_counter).time_allocation_id);
          FETCH c_chk_time_alloc_id INTO l_time_allocation_id ,
                                         l_object_version_number;
          CLOSE c_chk_time_alloc_id;

          IF l_time_allocation_id IS NULL
          THEN
              --
              IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error)
              THEN
                   fnd_message.set_name('OZF', 'OZF_QUOTA_INVALID_COL_VALUE');
                   fnd_message.set_token('COL_NAME', 'TIME_ALLOCATION_ID');
                   fnd_msg_pub.add;
              END IF;
              x_return_status := fnd_api.g_ret_sts_error;
              RETURN;
              --
          END IF;


          UPDATE ozf_time_allocations
          SET target     = NVL(p_quota_prod_spread_tbl(l_prod_sprd_counter).target, target),
              lysp_sales = NVL(p_quota_prod_spread_tbl(l_prod_sprd_counter).lysp_sales, lysp_sales),
              object_version_number = l_object_version_number + 1 ,
              last_update_date = SYSDATE,
              last_updated_by  = FND_GLOBAL.USER_ID
          WHERE time_allocation_id = l_time_allocation_id;
         --
      END LOOP;
      --
   END IF;
  ---------------------------------------------

  IF G_DEBUG THEN
     ozf_utility_pvt.debug_message('End Procedure: '|| l_api_name );
  END IF;

   FND_MSG_PUB.Count_And_Get (
    p_encoded => FND_API.G_FALSE,
    p_count   =>   x_msg_count,
    p_data    =>   x_msg_data
   );

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
   ROLLBACK TO update_quota_product_spread;
   x_return_status := FND_API.G_RET_STS_ERROR;
   -- Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                            ,p_count   => x_msg_count
                            ,p_data    => x_msg_data
                            );

WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   ROLLBACK TO update_quota_product_spread;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   -- Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                            ,p_count   => x_msg_count
                            ,p_data    => x_msg_data
                            );
WHEN OTHERS THEN
   ROLLBACK TO update_quota_product_spread;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
   END IF;
   -- Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                            ,p_count   => x_msg_count
                            ,p_data    => x_msg_data
                            );

END Update_Quota_Product_Spread;


PROCEDURE Update_Quota_Account_Spread(
              p_api_version         IN   NUMBER
             ,p_init_msg_list       IN   VARCHAR2 := fnd_api.g_false
             ,p_commit              IN   VARCHAR2 := fnd_api.g_false
             ,p_validation_level    IN   NUMBER   := fnd_api.g_valid_level_full
             ,x_return_status       OUT NOCOPY  VARCHAR2
             ,x_msg_count           OUT NOCOPY  NUMBER
             ,x_msg_data            OUT NOCOPY  VARCHAR2
             ,p_quota_accounts_tbl  IN quota_accounts_tbl_type
             ,p_account_spread_tbl  IN account_spread_tbl_type  )
IS
   l_api_name              VARCHAR(30)   := 'update_quota_account_spread';
   l_account_allocation_id NUMBER;
   l_time_allocation_id NUMBER;
   l_object_version_number NUMBER;

   CURSOR c_chk_acct_alloc_id (p_account_allocation_id NUMBER) IS
   SELECT account_allocation_id,
          object_version_number
   FROM ozf_account_allocations
   WHERE account_allocation_id = p_account_allocation_id;

   CURSOR c_chk_time_alloc_id (p_time_allocation_id NUMBER) IS
   SELECT time_allocation_id,
          object_version_number
   FROM ozf_time_allocations
   WHERE time_allocation_id = p_time_allocation_id;

BEGIN
  --
  SAVEPOINT UPDATE_QUOTA_ACCOUNT_SPREAD;

  IF G_DEBUG THEN
     ozf_utility_pvt.debug_message('Start Procedure: '|| l_api_name );
  END IF;

  --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  ---------------------------------------------

  IF  p_quota_accounts_tbl.COUNT > 0
  THEN
      --
      FOR l_acct_alloc_counter IN 1..p_quota_accounts_tbl.COUNT
      LOOP
          --
          OPEN c_chk_acct_alloc_id ( p_quota_accounts_tbl(l_acct_alloc_counter).account_allocation_id);
          FETCH c_chk_acct_alloc_id INTO l_account_allocation_id ,
                                         l_object_version_number;
          CLOSE c_chk_acct_alloc_id;

          IF l_account_allocation_id IS NULL
          THEN
              --
              IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error)
              THEN
                   fnd_message.set_name('OZF', 'OZF_QUOTA_INVALID_COL_VALUE');
                   fnd_message.set_token('COL_NAME', 'ACCOUNT_ALLOCATION_ID');
                   fnd_msg_pub.add;
              END IF;
              x_return_status := fnd_api.g_ret_sts_error;
              RETURN;
              --
          END IF;


          UPDATE ozf_account_allocations
          SET target     = NVL(p_quota_accounts_tbl(l_acct_alloc_counter).target, target),
              lysp_sales = NVL(p_quota_accounts_tbl(l_acct_alloc_counter).lysp_sales, lysp_sales),
              object_version_number = l_object_version_number + 1 ,
              last_update_date = SYSDATE,
              last_updated_by  = FND_GLOBAL.USER_ID
          WHERE account_allocation_id = l_account_allocation_id;
          --
      END LOOP; -- Done updating Account Allocations
      --
  END IF;

  IF p_account_spread_tbl.COUNT > 0
  THEN
      --
      FOR l_acct_sprd_counter IN 1..p_account_spread_tbl.COUNT
      LOOP
         --
          OPEN c_chk_time_alloc_id (p_account_spread_tbl(l_acct_sprd_counter).time_allocation_id);
          FETCH c_chk_time_alloc_id INTO l_time_allocation_id ,
                                         l_object_version_number;
          CLOSE c_chk_time_alloc_id;

          IF l_time_allocation_id IS NULL
          THEN
              --
              IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error)
              THEN
                   fnd_message.set_name('OZF', 'OZF_QUOTA_INVALID_COL_VALUE');
                   fnd_message.set_token('COL_NAME', 'TIME_ALLOCATION_ID');
                   fnd_msg_pub.add;
              END IF;
              x_return_status := fnd_api.g_ret_sts_error;
              RETURN;
              --
          END IF;


          UPDATE ozf_time_allocations
          SET target     = NVL(p_account_spread_tbl(l_acct_sprd_counter).target, target),
              lysp_sales = NVL(p_account_spread_tbl(l_acct_sprd_counter).lysp_sales, lysp_sales),
              object_version_number = l_object_version_number + 1 ,
              last_update_date = SYSDATE,
              last_updated_by  = FND_GLOBAL.USER_ID
          WHERE time_allocation_id = l_time_allocation_id;
         --
      END LOOP;
      --
   END IF;
  ---------------------------------------------

  IF G_DEBUG THEN
     ozf_utility_pvt.debug_message('End Procedure: '|| l_api_name );
  END IF;

   FND_MSG_PUB.Count_And_Get (
    p_encoded => FND_API.G_FALSE,
    p_count   =>   x_msg_count,
    p_data    =>   x_msg_data
   );

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
   ROLLBACK TO update_quota_account_spread;
   x_return_status := FND_API.G_RET_STS_ERROR;
   -- Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                            ,p_count   => x_msg_count
                            ,p_data    => x_msg_data
                            );

WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   ROLLBACK TO update_quota_account_spread;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   -- Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                            ,p_count   => x_msg_count
                            ,p_data    => x_msg_data
                            );
WHEN OTHERS THEN
   ROLLBACK TO update_quota_account_spread;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
   END IF;
   -- Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                            ,p_count   => x_msg_count
                            ,p_data    => x_msg_data
                            );


END Update_Quota_Account_Spread ;

PROCEDURE delete_quota_allocations ( p_quota_id IN NUMBER) IS

CURSOR c_child_quotas (c_quota_id NUMBER) IS
SELECT fund_id
from ozf_funds_all_b
where fund_type = 'QUOTA'
and parent_fund_id = c_quota_id;

BEGIN

FOR i IN c_child_quotas(p_quota_id)
LOOP

  delete_quota_allocations(i.fund_id);

END LOOP;


delete from ozf_time_allocations
where allocation_for = 'PROD'
and allocation_for_id in ( select product_allocation_id
                           from ozf_product_allocations
                           where allocation_for = 'CUST'
                           and allocation_for_id in ( select account_allocation_id
                                                      from ozf_account_allocations
                                                      where allocation_for = 'FUND'
                                                      and allocation_for_id = p_quota_id)
                          );

delete from ozf_product_allocations
where allocation_for = 'CUST'
and allocation_for_id in ( select account_allocation_id
                           from ozf_account_allocations
                           where allocation_for = 'FUND'
                           and allocation_for_id = p_quota_id);


delete from ozf_time_allocations
where allocation_for = 'CUST'
and allocation_for_id in (select account_allocation_id
                          from ozf_account_allocations
                          where allocation_for = 'FUND'
                          and allocation_for_id = p_quota_id ) ;

delete from ozf_account_allocations
where allocation_for = 'FUND'
and allocation_for_id = p_quota_id ;

delete from ozf_time_allocations
where allocation_for = 'PROD'
and allocation_for_id in (select product_allocation_id
                          from ozf_product_allocations
                          where allocation_for = 'FUND'
                          and allocation_for_id = p_quota_id ) ;

delete from ozf_product_allocations
where allocation_for = 'FUND'
and allocation_for_id = p_quota_id;

END;


---------------------------------------------------------------------
-- PROCEDURE
--    delete_quota
--
-- PURPOSE
--    Delete a quota.
--
-- PARAMETERS
--    p_quota_id: the quota id
--
-- HISTORY
--    07/04/2005  kdass Created
---------------------------------------------------------------------
PROCEDURE delete_quota(
   p_api_version        IN              NUMBER
  ,p_init_msg_list      IN              VARCHAR2 := fnd_api.g_false
  ,p_commit             IN              VARCHAR2 := fnd_api.g_false
  ,p_quota_id           IN              NUMBER
  ,x_return_status      OUT NOCOPY      VARCHAR2
  ,x_msg_count          OUT NOCOPY      NUMBER
  ,x_msg_data           OUT NOCOPY      VARCHAR2
  )
IS
l_api_name              VARCHAR(30) := 'delete_quota';
l_api_version           NUMBER := p_api_version;
l_init_msg_list         VARCHAR2(100) := p_init_msg_list;
l_commit                VARCHAR2(1) := p_commit;
l_object_version        NUMBER;

CURSOR c_valid_quota IS
   SELECT object_version_number
   FROM  ozf_funds_all_b
   WHERE fund_type = 'QUOTA'
     AND fund_id = p_quota_id ;


BEGIN

   SAVEPOINT delete_quota;

   --if quota id is null, then raise exception
   IF (p_quota_id = fnd_api.g_miss_num OR p_quota_id IS NULL) THEN

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
         fnd_message.set_name('OZF', 'OZF_NO_QUOTA_ID');
         fnd_msg_pub.add;
      END IF;
      RAISE fnd_api.g_exc_error;
   END IF;

   --check if the quota id is valid and get the object_version_number
   OPEN c_valid_quota;
   FETCH c_valid_quota INTO l_object_version;
   CLOSE c_valid_quota;

   IF l_object_version IS NULL THEN
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
         fnd_message.set_name('OZF', 'OZF_INVALID_QUOTA_ID');
         fnd_msg_pub.add;
      END IF;
      RAISE fnd_api.g_exc_error;
   END IF;

   delete_quota_allocations(p_quota_id);

   -- delete quota
   OZF_FUNDS_PUB.delete_fund(p_api_version      => l_api_version
                            ,p_init_msg_list    => l_init_msg_list
                            ,p_commit           => l_commit
                            ,p_fund_id          => p_quota_id
                            ,p_object_version   => l_object_version
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
    p_count   =>   x_msg_count,
    p_data    =>   x_msg_data
   );

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
   ROLLBACK TO delete_quota;
   x_return_status := FND_API.G_RET_STS_ERROR;
   -- Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                            ,p_count   => x_msg_count
                            ,p_data    => x_msg_data
                            );
WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   ROLLBACK TO delete_quota;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   -- Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                            ,p_count   => x_msg_count
                            ,p_data    => x_msg_data
                            );
WHEN OTHERS THEN
   ROLLBACK TO delete_quota;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
   END IF;
   -- Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                            ,p_count   => x_msg_count
                            ,p_data    => x_msg_data
                            );
END delete_quota;

---------------------------------------------------------------------
-- PROCEDURE
--    generate_product_spread
--
-- PURPOSE
--    Create product spread for quota.
--
-- PARAMETERS
--    p_quota_id: the quota id
--
-- HISTORY
--    07/04/2005  kdass Created
---------------------------------------------------------------------
PROCEDURE generate_product_spread(
   p_api_version        IN              NUMBER
  ,p_init_msg_list      IN              VARCHAR2 := fnd_api.g_false
  ,p_commit             IN              VARCHAR2 := fnd_api.g_false
  ,p_validation_level   IN              NUMBER   := fnd_api.g_valid_level_full
  ,p_quota_id           IN              NUMBER
  ,x_return_status      OUT NOCOPY      VARCHAR2
  ,x_error_number       OUT NOCOPY      NUMBER
  ,x_error_message      OUT NOCOPY      VARCHAR2
  )
IS
l_api_name              VARCHAR(30) := 'generate_product_spread';
l_api_version           NUMBER := p_api_version;
l_init_msg_list         VARCHAR2(100) := p_init_msg_list;
l_validation_level      NUMBER := p_validation_level;
l_commit                VARCHAR2(1) := p_commit;
l_valid_quota           NUMBER := NULL;
l_prod_exists           NUMBER := NULL;

CURSOR c_valid_quota IS
   SELECT 1
   FROM  ozf_funds_all_b
   WHERE fund_type = 'QUOTA'
     AND fund_id = p_quota_id;

CURSOR c_product_exists IS
   SELECT 1
   FROM ams_act_products
   WHERE act_product_used_by_id = p_quota_id
   and arc_act_product_used_by = 'FUND';

BEGIN

   SAVEPOINT generate_product_spread;

   --if quota id is null, then raise exception
   IF (p_quota_id = fnd_api.g_miss_num OR p_quota_id IS NULL) THEN

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
         fnd_message.set_name('OZF', 'OZF_NO_QUOTA_ID');
         fnd_msg_pub.add;
      END IF;
      RAISE fnd_api.g_exc_error;
   END IF;

   --check if the quota id is valid and get the object_version_number
   OPEN c_valid_quota;
   FETCH c_valid_quota INTO l_valid_quota;
   CLOSE c_valid_quota;

   IF l_valid_quota IS NULL THEN
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
         fnd_message.set_name('OZF', 'OZF_INVALID_QUOTA_ID');
         fnd_msg_pub.add;
      END IF;
      RAISE fnd_api.g_exc_error;
   END IF;

   --check if the quota has any products
   OPEN c_product_exists;
   FETCH c_product_exists INTO l_prod_exists;
   CLOSE c_product_exists;

   IF l_prod_exists IS NULL THEN
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
         fnd_message.set_name('OZF', 'OZF_QUOTA_NO_PROD');
         fnd_msg_pub.add;
      END IF;
      RAISE fnd_api.g_exc_error;
   END IF;

   -- create product spread for quota
   OZF_ALLOCATION_ENGINE_PVT.setup_product_spread(p_api_version         => l_api_version
                                                 ,p_init_msg_list       => l_init_msg_list
                                                 ,p_commit              => l_commit
                                                 ,p_validation_level    => l_validation_level
                                                 ,x_return_status       => x_return_status
                                                 ,x_error_number        => x_error_number
                                                 ,x_error_message       => x_error_message
                                                 ,p_mode                => 'CREATE'
                                                 ,p_obj_id              => p_quota_id
                                                 ,p_context             => 'ROOT'
                                                 );

   IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
      RAISE fnd_api.g_exc_unexpected_error;
   ELSIF x_return_status = fnd_api.g_ret_sts_error THEN
      RAISE fnd_api.g_exc_error;
   END IF;

   FND_MSG_PUB.Count_And_Get(p_count   => x_error_number,
                             p_data    => x_error_message);

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
   ROLLBACK TO generate_product_spread;
   x_return_status := FND_API.G_RET_STS_ERROR;
   FND_MSG_PUB.Count_And_Get(p_count   => x_error_number,
                             p_data    => x_error_message);
WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   ROLLBACK TO generate_product_spread;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   FND_MSG_PUB.Count_And_Get(p_count   => x_error_number,
                             p_data    => x_error_message);
WHEN OTHERS THEN
   ROLLBACK TO generate_product_spread;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
   END IF;
   FND_MSG_PUB.Count_And_Get(p_count   => x_error_number,
                             p_data    => x_error_message);
END generate_product_spread;

---------------------------------------------------------------------
-- PROCEDURE
--    create_allocation
--
-- PURPOSE
--    Create quota allocation.
--
-- PARAMETERS
--    p_alloc_rec: the new record to be inserted
--    x_alloc_id: returns the allocation id of the new allocation
--
-- HISTORY
--    07/04/2005  kdass Created
---------------------------------------------------------------------
PROCEDURE create_allocation(
   p_api_version        IN              NUMBER
  ,p_init_msg_list      IN              VARCHAR2 := fnd_api.g_false
  ,p_commit             IN              VARCHAR2 := fnd_api.g_false
  ,p_validation_level   IN              NUMBER   := fnd_api.g_valid_level_full
  ,p_alloc_rec          IN              alloc_rec_type
  ,x_return_status      OUT NOCOPY      VARCHAR2
  ,x_msg_count          OUT NOCOPY      NUMBER
  ,x_msg_data           OUT NOCOPY      VARCHAR2
  ,x_alloc_id           OUT NOCOPY      NUMBER
  )
IS
l_api_name              VARCHAR(30) := 'create_allocation';
l_alloc_rec             alloc_rec_type := p_alloc_rec;
l_act_metric_rec        OZF_ACTMETRIC_PVT.act_metric_rec_type;
l_api_version           NUMBER := p_api_version;
l_init_msg_list         VARCHAR2(100) := p_init_msg_list;
l_validation_level      NUMBER := p_validation_level;
l_commit                VARCHAR2(1) := p_commit;
l_spread_exists         NUMBER := NULL;

CURSOR c_product_spread_exists (p_quota_id IN NUMBER) IS
   SELECT 1
   FROM  ozf_product_allocations
   WHERE fund_id = p_quota_id;

BEGIN

   SAVEPOINT create_allocation;

   validate_alloc_attributes(p_alloc_rec     => l_alloc_rec
                            ,x_return_status => x_return_status);

   IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
      RAISE fnd_api.g_exc_unexpected_error;
   ELSIF x_return_status = fnd_api.g_ret_sts_error THEN
      RAISE fnd_api.g_exc_error;
   END IF;

   --check if the product spread exists
   OPEN c_product_spread_exists (l_alloc_rec.quota_id);
   FETCH c_product_spread_exists INTO l_spread_exists;
   CLOSE c_product_spread_exists;

   IF l_spread_exists IS NULL THEN
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
         fnd_message.set_name('OZF', 'OZF_NO_PROD_SPREAD'); -- product spread needs to be created before creating allocation
         fnd_msg_pub.add;
      END IF;
      RAISE fnd_api.g_exc_error;
   END IF;

   l_act_metric_rec.act_metric_used_by_id := l_alloc_rec.quota_id;
   l_act_metric_rec.arc_act_metric_used_by := 'FUND';
   l_act_metric_rec.application_id := '682';
   l_act_metric_rec.metric_id := '55';
   l_act_metric_rec.sensitive_data_flag := 'N';
   l_act_metric_rec.status_code := 'NEW';
   l_act_metric_rec.action_code := 'CREATE_NEW_BUDGET';
   l_act_metric_rec.hierarchy_type := 'TERRITORY';
   l_act_metric_rec.ex_start_node := 'N';
   l_act_metric_rec.hierarchy_id := l_alloc_rec.hierarchy_id;
   l_act_metric_rec.from_level := l_alloc_rec.from_level;
   l_act_metric_rec.to_level := l_alloc_rec.to_level;
   l_act_metric_rec.start_node := l_alloc_rec.start_node;
   l_act_metric_rec.start_period_name := l_alloc_rec.start_period_name;
   l_act_metric_rec.end_period_name := l_alloc_rec.end_period_name;
   l_act_metric_rec.from_date := l_alloc_rec.from_date;
   l_act_metric_rec.to_date := l_alloc_rec.to_date;
   l_act_metric_rec.func_actual_value := l_alloc_rec.alloc_amount;
   l_act_metric_rec.method_code := l_alloc_rec.method_code;
   l_act_metric_rec.basis_year := l_alloc_rec.basis_year;
   l_act_metric_rec.product_spread_time_id := l_alloc_rec.product_spread_time_id;

   -- create quota allocation
   ozf_actmetric_pvt.create_actmetric(p_api_version             => l_api_version
                                     ,p_init_msg_list           => l_init_msg_list
                                     ,p_commit                  => l_commit
                                     ,p_validation_level        => l_validation_level
                                     ,x_return_status           => x_return_status
                                     ,x_msg_count               => x_msg_count
                                     ,x_msg_data                => x_msg_data
                                     ,p_act_metric_rec          => l_act_metric_rec
                                     ,x_activity_metric_id      => x_alloc_id
                                     );

   IF x_alloc_id IS NOT NULL THEN
      ozf_quota_allocations_pvt.create_quota_alloc_hierarchy(p_api_version      => l_api_version
                                                            ,p_init_msg_list    => l_init_msg_list
                                                            ,p_commit           => l_commit
                                                            ,x_return_status    => x_return_status
                                                            ,x_msg_count        => x_msg_count
                                                            ,x_msg_data         => x_msg_data
                                                            ,p_alloc_id         => x_alloc_id
                                                            );
   END IF;

   IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
      RAISE fnd_api.g_exc_unexpected_error;
   ELSIF x_return_status = fnd_api.g_ret_sts_error THEN
      RAISE fnd_api.g_exc_error;
   END IF;

   FND_MSG_PUB.Count_And_Get (
    p_encoded => FND_API.G_FALSE,
    p_count   =>   x_msg_count,
    p_data    =>   x_msg_data
   );

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
   ROLLBACK TO create_allocation;
   x_return_status := FND_API.G_RET_STS_ERROR;
   -- Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                            ,p_count   => x_msg_count
                            ,p_data    => x_msg_data
                            );
WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   ROLLBACK TO create_allocation;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   -- Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                            ,p_count   => x_msg_count
                            ,p_data    => x_msg_data
                            );
WHEN OTHERS THEN
   ROLLBACK TO create_allocation;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
   END IF;
   -- Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                            ,p_count   => x_msg_count
                            ,p_data    => x_msg_data
                            );
END create_allocation;

---------------------------------------------------------------------
-- PROCEDURE
--    publish_allocation
--
-- PURPOSE
--    Publish quota allocation.
--
-- PARAMETERS
--    p_alloc_id: allocation id
--
-- HISTORY
--    07/04/2005  kdass Created
---------------------------------------------------------------------
PROCEDURE publish_allocation(
   p_api_version        IN              NUMBER
  ,p_init_msg_list      IN              VARCHAR2 := fnd_api.g_false
  ,p_commit             IN              VARCHAR2 := fnd_api.g_false
  ,p_validation_level   IN              NUMBER   := fnd_api.g_valid_level_full
  ,p_alloc_id           IN              NUMBER
  ,x_return_status      OUT NOCOPY      VARCHAR2
  ,x_msg_count          OUT NOCOPY      NUMBER
  ,x_msg_data           OUT NOCOPY      VARCHAR2
  )
IS
l_api_name              VARCHAR(30) := 'publish_allocation';
l_api_version           NUMBER := p_api_version;
l_init_msg_list         VARCHAR2(100) := p_init_msg_list;
l_validation_level      NUMBER := p_validation_level;
l_commit                VARCHAR2(1) := p_commit;
l_valid_alloc           NUMBER := NULL;
l_alloc_status          VARCHAR2(20);
l_alloc_obj_ver         NUMBER;

CURSOR c_valid_alloc IS
   SELECT 1
   FROM ozf_act_metrics_all
   WHERE activity_metric_id = p_alloc_id;

CURSOR c_alloc_details IS
   SELECT status_code, object_version_number
   FROM ozf_act_metrics_all
   WHERE activity_metric_id = p_alloc_id;

BEGIN


   SAVEPOINT publish_allocation;

   --check if the allocation id is valid
   OPEN c_valid_alloc;
   FETCH c_valid_alloc INTO l_valid_alloc;
   CLOSE c_valid_alloc;

   IF l_valid_alloc IS NULL THEN
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
         fnd_message.set_name('OZF', 'OZF_INVALID_ALLOC_ID');
         fnd_msg_pub.add;
      END IF;
      RAISE fnd_api.g_exc_error;
   END IF;

   OPEN c_alloc_details;
   FETCH c_alloc_details INTO l_alloc_status, l_alloc_obj_ver;
   CLOSE c_alloc_details;

   ozf_fund_allocations_pvt.publish_allocation(p_api_version            => l_api_version
                                              ,p_init_msg_list          => l_init_msg_list
                                              ,p_commit                 => l_commit
                                              ,p_validation_level       => l_validation_level
                                              ,p_alloc_id               => p_alloc_id
                                              ,p_alloc_status           => l_alloc_status
                                              ,p_alloc_obj_ver          => l_alloc_obj_ver
                                              ,x_return_status          => x_return_status
                                              ,x_msg_count              => x_msg_count
                                              ,x_msg_data               => x_msg_data
                                              );

   IF x_return_status = fnd_api.g_ret_sts_error THEN
      RAISE fnd_api.g_exc_error;
   ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   ozf_quota_allocations_pvt.publish_allocation(p_api_version           => l_api_version
                                               ,p_init_msg_list         => l_init_msg_list
                                               ,p_commit                => l_commit
                                               ,p_validation_level      => l_validation_level
                                               ,p_alloc_id              => p_alloc_id
                                               ,x_return_status         => x_return_status
                                               ,x_msg_count             => x_msg_count
                                               ,x_msg_data              => x_msg_data
                                               );

   IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
      RAISE fnd_api.g_exc_unexpected_error;
   ELSIF x_return_status = fnd_api.g_ret_sts_error THEN
      RAISE fnd_api.g_exc_error;
   END IF;

   FND_MSG_PUB.Count_And_Get (
    p_encoded => FND_API.G_FALSE,
    p_count   =>   x_msg_count,
    p_data    =>   x_msg_data
   );

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
   ROLLBACK TO publish_allocation;
   x_return_status := FND_API.G_RET_STS_ERROR;
   -- Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                            ,p_count   => x_msg_count
                            ,p_data    => x_msg_data
                            );
WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   ROLLBACK TO publish_allocation;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   -- Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                            ,p_count   => x_msg_count
                            ,p_data    => x_msg_data
                            );
WHEN OTHERS THEN
   ROLLBACK TO publish_allocation;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
   END IF;
   -- Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                            ,p_count   => x_msg_count
                            ,p_data    => x_msg_data
                            );
END publish_allocation;

---------------------------------------------------------------------
-- PROCEDURE
--    update_alloc_status
--
-- PURPOSE
--    Update quota allocation status.
--
-- PARAMETERS
--    p_alloc_id: allocation id
--    p_alloc_status: allocation status
--
-- HISTORY
--    07/04/2005  kdass Created
---------------------------------------------------------------------
PROCEDURE update_alloc_status(
   p_api_version        IN              NUMBER
  ,p_init_msg_list      IN              VARCHAR2 := fnd_api.g_false
  ,p_commit             IN              VARCHAR2 := fnd_api.g_false
  ,p_validation_level   IN              NUMBER   := fnd_api.g_valid_level_full
  ,p_alloc_id           IN              NUMBER
  ,p_alloc_status       IN              VARCHAR2
  ,x_return_status      OUT NOCOPY      VARCHAR2
  ,x_msg_count          OUT NOCOPY      NUMBER
  ,x_msg_data           OUT NOCOPY      VARCHAR2
  )
IS
l_api_name              VARCHAR(30) := 'create_allocation';
l_api_version           NUMBER := p_api_version;
l_init_msg_list         VARCHAR2(100) := p_init_msg_list;
l_validation_level      NUMBER := p_validation_level;
l_commit                VARCHAR2(1);
l_alloc_obj_ver         NUMBER;

CURSOR c_valid_alloc IS
   SELECT object_version_number
   FROM ozf_act_metrics_all
   WHERE activity_metric_id = p_alloc_id;

BEGIN
null;
/*
   SAVEPOINT update_alloc_status;

   --check if the allocation id is valid and get the object_version_number
   OPEN c_valid_alloc;
   FETCH c_valid_alloc INTO l_alloc_obj_ver;
   CLOSE c_valid_alloc;

   IF l_alloc_obj_ver IS NULL THEN
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
         fnd_message.set_name('OZF', 'OZF_INVALID_ALLOC_ID');
         fnd_msg_pub.add;
      END IF;
      RAISE fnd_api.g_exc_error;
   END IF;

   ozf_fund_allocations_pvt.update_alloc_status(p_api_version           => l_api_version
                                               ,p_init_msg_list         => l_init_msg_list
                                               ,p_commit                => l_commit
                                               ,p_validation_level      => l_validation_level
                                               ,p_alloc_id              => p_alloc_id
                                               ,p_alloc_status          => p_alloc_status
                                               ,p_alloc_obj_ver         => l_alloc_obj_ver
                                               ,x_return_status         => x_return_status
                                               ,x_msg_count             => x_msg_count
                                               ,x_msg_data              => x_msg_data
                                               );

   IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
      RAISE fnd_api.g_exc_unexpected_error;
   ELSIF x_return_status = fnd_api.g_ret_sts_error THEN
      RAISE fnd_api.g_exc_error;
   END IF;

   FND_MSG_PUB.Count_And_Get (
    p_encoded => FND_API.G_FALSE,
    p_count   =>   x_msg_count,
    p_data    =>   x_msg_data
   );
*/
EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
   ROLLBACK TO update_alloc_status;
   x_return_status := FND_API.G_RET_STS_ERROR;
   -- Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                            ,p_count   => x_msg_count
                            ,p_data    => x_msg_data
                            );
WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   ROLLBACK TO update_alloc_status;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   -- Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                            ,p_count   => x_msg_count
                            ,p_data    => x_msg_data
                            );
WHEN OTHERS THEN
   ROLLBACK TO update_alloc_status;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
   END IF;
   -- Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                            ,p_count   => x_msg_count
                            ,p_data    => x_msg_data
                            );
END update_alloc_status;

END OZF_QUOTA_PUB;

/
