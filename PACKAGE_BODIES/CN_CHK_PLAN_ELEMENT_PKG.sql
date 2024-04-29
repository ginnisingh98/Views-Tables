--------------------------------------------------------
--  DDL for Package Body CN_CHK_PLAN_ELEMENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_CHK_PLAN_ELEMENT_PKG" AS
/* $Header: cnchkpeb.pls 120.5 2005/10/17 05:30:54 chanthon ship $ */
   g_pkg_name           CONSTANT VARCHAR2 (30) := 'CN_CHK_PLAN_ELEMENT_PKG';
   g_file_name          CONSTANT VARCHAR2 (12) := 'cnchkpeb.pls';

-- ----------------------------------------------------------------------------+
-- Procedure: valid_rate_table
-- Desc     : Valid input for Rate Table
-- ----------------------------------------------------------------------------+
   PROCEDURE valid_rate_table (
      x_return_status            OUT NOCOPY VARCHAR2,
      p_pe_rec                   IN       pe_rec_type := g_miss_pe_rec,
      p_loading_status           IN       VARCHAR2,
      x_loading_status           OUT NOCOPY VARCHAR2
   )
   IS
      l_api_name           CONSTANT VARCHAR2 (30) := 'valid_rate_table';
      l_tmp                         NUMBER := 0;
--      l_tier_unit_code  cn_rate_schedules.tier_unit_code%TYPE
--                            := FND_API.G_MISS_CHAR;
      l_comm_unit_code              cn_rate_schedules.commission_unit_code%TYPE := fnd_api.g_miss_char;
   BEGIN
/*
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   x_loading_status := p_loading_status;

   -- Rate Table CAN NOT NULL if plan element type is not 'DRAW or MANUAL'
   IF (p_pe_rec.quota_type_code IN
       ('TARGET','REVENUE','UNIT_BASED_QUOTA','UNIT_BASED_NON_QUOTA',
  'DISCOUNT','MARGIN') ) THEN
      IF (p_pe_rec.rate_table_id IS NULL) THEN
   -- Rasie error when user Pass in Rate table Name = NULL
   IF (cn_api.pe_char_field_cannot_null
       ( p_char_field => p_pe_rec.rate_table_name,
         p_pe_type   => p_pe_rec.quota_type_code,
         p_obj_name  => G_RATE_TB,
         p_token1    => NULL ,
         p_token2    => NULL ,
         p_token3    => NULL ,
         p_loading_status => x_loading_status,
         x_loading_status => x_loading_status) = FND_API.G_FALSE) THEN
      RAISE FND_API.G_EXC_ERROR ;
   END IF;
   -- Rasie error when user missing Pass in Rate table Name
   IF ( (cn_api.chk_miss_char_para
         ( p_char_para => p_pe_rec.rate_table_name,
     p_para_name => G_RATE_TB,
     p_loading_status => x_loading_status,
     x_loading_status => x_loading_status)) = FND_API.G_TRUE) THEN
      RAISE FND_API.G_EXC_ERROR ;
   END IF;
   -- Rasie error when user pass in rate table name not exist in
   -- cn_rate_schedules
   IF (CN_API.get_rate_table_id(p_pe_rec.rate_table_name)) IS NULL THEN
            IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
              THEN
               FND_MESSAGE.SET_NAME ('CN' , 'CN_RATE_SCH_NOT_EXIST');
               FND_MSG_PUB.Add;
            END IF;
            x_loading_status := 'CN_RATE_SCH_NOT_EXIST';
            RAISE FND_API.G_EXC_ERROR ;
   END IF ;
       ELSIF p_pe_rec.rate_table_name IS NULL THEN
   -- Rate_table_id not null and rate_table_name null, check if
   -- Rate_table_id is exist in DB
   IF (CN_API.get_rate_table_name(p_pe_rec.rate_table_id)) IS NULL THEN
            IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
              THEN
               FND_MESSAGE.SET_NAME ('CN' , 'CN_RATE_SCH_NOT_EXIST');
               FND_MSG_PUB.Add;
            END IF;
            x_loading_status := 'CN_RATE_SCH_NOT_EXIST';
            RAISE FND_API.G_EXC_ERROR ;
   END IF ;
       ELSE
   -- If rate_table_id and rate_table_name both are not missing or null,
   -- make sure they're compatible, access to same record in
   -- CN_RATE_SCHEDULES
   IF(p_pe_rec.rate_table_id <>
      CN_API.get_rate_table_id(p_pe_rec.rate_table_name)) THEN
      -- Error, check the msg level and add an error message to the
      -- API message list
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
         FND_MESSAGE.SET_NAME ('CN' , 'CN_VALUE_ID_ERROR');
         FND_MESSAGE.SET_TOKEN('VALUE_NAME', G_RATE_TB || ' : '
             || p_pe_rec.rate_table_name);
         FND_MESSAGE.SET_TOKEN('ID_NAME',G_RATE_TB_ID || ' : ' ||
             p_pe_rec.rate_table_id);
         FND_MSG_PUB.Add;
      END IF;
      x_loading_status := 'CN_VALUE_ID_ERROR';
      RAISE FND_API.G_EXC_ERROR ;
   END IF;
      END IF;
   END IF ; -- end quota_type_code
   --+
   -- check tier/commission unit code
   --+
   SELECT tier_unit_code, commission_unit_code
     INTO l_tier_unit_code, l_comm_unit_code
     FROM cn_rate_schedules rs
     WHERE rs.rate_schedule_id =  p_pe_rec.rate_table_id;
   -- check tier unit code
   IF p_pe_rec.quota_type_code IN ('TARGET','UNIT_BASED_QUOTA') THEN
      IF l_tier_unit_code <> 'PERCENT' THEN
   IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
     THEN
      FND_MESSAGE.SET_NAME ('CN' , 'PLN_QUOTA_SCHED_INCOMPAT_TP');
      FND_MESSAGE.SET_TOKEN ('PLAN_NAME',NULL);
      FND_MESSAGE.SET_TOKEN ('QUOTA_NAME',p_pe_rec.name);
      FND_MSG_PUB.Add;
   END IF;
      x_loading_status := 'PLN_QUOTA_SCHED_INCOMPAT_TP';
      RAISE FND_API.G_EXC_ERROR ;
      END IF;
   ELSIF p_pe_rec.quota_type_code IN ('REVENUE','UNIT_BASED_NON_QUOTA') THEN
      IF l_tier_unit_code <> 'AMOUNT' THEN
   IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
     THEN
      FND_MESSAGE.SET_NAME ('CN' , 'PLN_QUOTA_SCHED_INCOMPAT_RA');
      FND_MESSAGE.SET_TOKEN ('PLAN_NAME',NULL);
      FND_MESSAGE.SET_TOKEN ('QUOTA_NAME',p_pe_rec.name);
      FND_MSG_PUB.Add;
   END IF;
      x_loading_status := 'PLN_QUOTA_SCHED_INCOMPAT_RA';
      RAISE FND_API.G_EXC_ERROR ;
      END IF;
   ELSIF p_pe_rec.quota_type_code IN ('DISCOUNT','MARGIN') THEN
      IF l_tier_unit_code <> 'PERCENT' THEN
   IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
     THEN
      FND_MESSAGE.SET_NAME ('CN' , 'PLN_QUOTA_SCHED_INCOMPAT_DP');
      FND_MESSAGE.SET_TOKEN ('PLAN_NAME',NULL);
      FND_MESSAGE.SET_TOKEN ('QUOTA_NAME',p_pe_rec.name);
      FND_MSG_PUB.Add;
   END IF;
      x_loading_status := 'PLN_QUOTA_SCHED_INCOMPAT_DP';
      RAISE FND_API.G_EXC_ERROR ;
      END IF;
   END IF;
   -- check commission unit code
   IF p_pe_rec.payment_type_code IN ('PAYMENT','TRANSACTION') THEN
      IF l_comm_unit_code <> 'PERCENT' THEN
   IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
     THEN
      FND_MESSAGE.SET_NAME ('CN' , 'PLN_QUOTA_SCHED_INCOMPAT_PP');
      FND_MESSAGE.SET_TOKEN ('PLAN_NAME',NULL);
      FND_MESSAGE.SET_TOKEN ('QUOTA_NAME',p_pe_rec.name);
      FND_MSG_PUB.Add;
   END IF;
   x_loading_status := 'PLN_QUOTA_SCHED_INCOMPAT_PP';
      RAISE FND_API.G_EXC_ERROR ;
      END IF;
   ELSIF p_pe_rec.payment_type_code = 'FIXED' THEN
      IF l_comm_unit_code <> 'AMOUNT' THEN
   IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
     THEN
      FND_MESSAGE.SET_NAME ('CN' , 'PLN_QUOTA_SCHED_INCOMPAT_FA');
      FND_MESSAGE.SET_TOKEN('PLAN_NAME',NULL);
      FND_MESSAGE.SET_TOKEN('QUOTA_NAME',p_pe_rec.name);
      FND_MSG_PUB.Add;
   END IF;
   x_loading_status := 'PLN_QUOTA_SCHED_INCOMPAT_FA';
      RAISE FND_API.G_EXC_ERROR ;
      END IF;
   END IF ;
   -- Check if rate table doesn't have any rate tiers
   SELECT COUNT(*)
     INTO l_tmp
     FROM cn_rate_tiers rt
     WHERE rt.rate_schedule_id = p_pe_rec.rate_table_id
     ;
   IF l_tmp = 0 THEN
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
  THEN
   FND_MESSAGE.SET_NAME ('CN' , 'PLN_SCHEDULE_NO_TIERS');
   FND_MESSAGE.SET_TOKEN('PLAN_NAME',NULL);
   FND_MESSAGE.SET_TOKEN('QUOTA_NAME',p_pe_rec.name);
   FND_MESSAGE.SET_TOKEN('SCHEDULE_NAME',p_pe_rec.rate_table_name);
   FND_MSG_PUB.Add;
      END IF;
      x_loading_status := 'PLN_SCHEDULE_NO_TIERS';
      RAISE FND_API.G_EXC_ERROR ;
   END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      x_loading_status := 'UNEXPECTED_ERR';

   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      x_loading_status := 'UNEXPECTED_ERR';
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,l_api_name );
      END IF;
*/
      fnd_message.set_name ('CN', 'CN_PACKAGE_OBSELETE');
      fnd_msg_pub.ADD;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      x_loading_status := 'CN_PACKAGE_OBSELETE';
      RAISE fnd_api.g_exc_error;
   END valid_rate_table;

-- ----------------------------------------------------------------------------+
-- Procedure: valid_disc_rate_table
-- Desc     : Valid input for Discount Rate Table
-- ----------------------------------------------------------------------------+
   PROCEDURE valid_disc_rate_table (
      x_return_status            OUT NOCOPY VARCHAR2,
      p_pe_rec                   IN       pe_rec_type := g_miss_pe_rec,
      p_loading_status           IN       VARCHAR2,
      x_loading_status           OUT NOCOPY VARCHAR2
   )
   IS
      l_api_name           CONSTANT VARCHAR2 (30) := 'valid_disc_rate_table';
      l_tmp                         NUMBER := 0;
--      l_tier_unit_code cn_rate_schedules.tier_unit_code%TYPE
--                            := FND_API.G_MISS_CHAR;
      l_comm_unit_code              cn_rate_schedules.commission_unit_code%TYPE := fnd_api.g_miss_char;
   BEGIN
/*   x_return_status := FND_API.G_RET_STS_SUCCESS;
   x_loading_status := p_loading_status;

   -- Disc Rate Table CAN NOT NULL if plan element type is Rev quota, Rev non
   -- quota and discount option code = payment or quota
   IF (p_pe_rec.quota_type_code IN ('TARGET','REVENUE') ) AND
     (p_pe_rec.disc_option_code IN ('PAYMENT','QUOTA')) THEN
      IF (p_pe_rec.disc_rate_table_id IS NULL) THEN
   -- Rasie error when user Pass in Discount Rate table Name = NULL
   IF (cn_api.pe_char_field_cannot_null
       ( p_char_field => p_pe_rec.disc_rate_table_name,
         p_pe_type   => p_pe_rec.quota_type_code,
         p_obj_name  => G_DISC_RATE_TB,
         p_token1    => G_DISC_OPTION ||' = '||
         cn_api.get_lkup_meaning
         (p_pe_rec.disc_option_code,'DISCOUNT_OPTION'),
         p_token2    => NULL ,
         p_token3    => NULL ,
         p_loading_status => x_loading_status,
         x_loading_status => x_loading_status) = FND_API.G_FALSE) THEN
      RAISE FND_API.G_EXC_ERROR ;
   END IF;
   -- Rasie error when user missing Pass in Discount Rate table Name
   IF ( (cn_api.chk_miss_char_para
         ( p_char_para => p_pe_rec.disc_rate_table_name,
     p_para_name => G_DISC_RATE_TB,
     p_loading_status => x_loading_status,
     x_loading_status => x_loading_status)) = FND_API.G_TRUE) THEN
      RAISE FND_API.G_EXC_ERROR ;
   END IF;
   -- Rasie error when user pass in dicsount rate table name not exist in
   -- cn_rate_schedules
   IF (CN_API.get_rate_table_id(p_pe_rec.disc_rate_table_name)) IS NULL
     THEN
            IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
              THEN
               FND_MESSAGE.SET_NAME ('CN' , 'PLN_QUOTA_DISC_SCHED_REQUIRED');
               FND_MSG_PUB.Add;
            END IF;
            x_loading_status := 'PLN_QUOTA_DISC_SCHED_REQUIRED';
            RAISE FND_API.G_EXC_ERROR ;
   END IF ;
       ELSIF p_pe_rec.disc_rate_table_name IS NULL THEN
   -- Disc_Rate_table_id not null and disc_rate_table_name null, check if
   -- Disc_rate_table_id is exist in DB
   IF (CN_API.get_rate_table_name(p_pe_rec.disc_rate_table_id)) IS NULL
     THEN
            IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
              THEN
               FND_MESSAGE.SET_NAME ('CN' ,'PLN_QUOTA_DISC_SCHED_REQUIRED');
               FND_MSG_PUB.Add;
            END IF;
            x_loading_status := 'PLN_QUOTA_DISC_SCHED_REQUIRED';
            RAISE FND_API.G_EXC_ERROR ;
   END IF ;
       ELSE
   -- If disc_rate_table_id and disc_rate_table_name both are not
   -- missing or null,
   -- make sure they're compatible, access to same record in
   -- CN_RATE_SCHEDULES
   IF(p_pe_rec.disc_rate_table_id <>
      CN_API.get_rate_table_id(p_pe_rec.disc_rate_table_name)) THEN
      -- Error, check the msg level and add an error message to the
      -- API message list
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
         FND_MESSAGE.SET_NAME ('CN' , 'CN_VALUE_ID_ERROR');
         FND_MESSAGE.SET_TOKEN('VALUE_NAME',G_DISC_RATE_TB ||' : '
             ||p_pe_rec.disc_rate_table_name);
         FND_MESSAGE.SET_TOKEN('ID_NAME',G_DISC_RATE_TB_ID || ' : '||
             p_pe_rec.disc_rate_table_id);
         FND_MSG_PUB.Add;
      END IF;
      x_loading_status := 'CN_VALUE_ID_ERROR';
      RAISE FND_API.G_EXC_ERROR ;
   END IF;
      END IF;

      -- Check discount rate table <> rate table
      IF p_pe_rec.rate_table_id = p_pe_rec.disc_rate_table_id THEN
   IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
     THEN
      FND_MESSAGE.SET_NAME ('CN' , 'DISC_RATE_TABLE_SAME');
      FND_MSG_PUB.Add;
   END IF;
      x_loading_status := 'DISC_RATE_TABLE_SAME';
      RAISE FND_API.G_EXC_ERROR ;
      END IF;

      --+
      -- check tier/commission unit code
      --+
      SELECT tier_unit_code, commission_unit_code
  INTO l_tier_unit_code, l_comm_unit_code
  FROM cn_rate_schedules rs
  WHERE rs.rate_schedule_id =  p_pe_rec.disc_rate_table_id;
      IF l_tier_unit_code <> 'PERCENT' OR
  l_comm_unit_code <> 'PERCENT' THEN
   IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
     THEN
      FND_MESSAGE.SET_NAME ('CN' , 'PLN_QUOTA_DISC_SCHED_NOT_PP');
      FND_MESSAGE.SET_TOKEN('PLAN_NAME',NULL);
      FND_MESSAGE.SET_TOKEN('QUOTA_NAME',p_pe_rec.name);
      FND_MSG_PUB.Add;
   END IF;
      x_loading_status := 'PLN_QUOTA_DISC_SCHED_NOT_PP';
      RAISE FND_API.G_EXC_ERROR ;
      END IF;

      -- Check if rate table doesn't have any rate tiers
      SELECT COUNT(*)
  INTO l_tmp
  FROM cn_rate_tiers rt
  WHERE rt.rate_schedule_id = p_pe_rec.disc_rate_table_id
  ;
      IF l_tmp = 0 THEN
   IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
     THEN
      FND_MESSAGE.SET_NAME ('CN' , 'PLN_SCHEDULE_NO_TIERS');
      FND_MESSAGE.SET_TOKEN('PLAN_NAME',NULL);
      FND_MESSAGE.SET_TOKEN('QUOTA_NAME',p_pe_rec.name);
      FND_MESSAGE.set_token
        ('SCHEDULE_NAME',p_pe_rec.disc_rate_table_name);
      FND_MSG_PUB.Add;
   END IF;
   x_loading_status := 'PLN_SCHEDULE_NO_TIERS';
   RAISE FND_API.G_EXC_ERROR ;
      END IF;

   END IF ; -- end quota_type_code

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      x_loading_status := 'UNEXPECTED_ERR';

   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      x_loading_status := 'UNEXPECTED_ERR';
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,l_api_name );
      END IF;
*/
      fnd_message.set_name ('CN', 'CN_PACKAGE_OBSELETE');
      fnd_msg_pub.ADD;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      x_loading_status := 'CN_PACKAGE_OBSELETE';
      RAISE fnd_api.g_exc_error;
   END valid_disc_rate_table;

-- ----------------------------------------------------------------------------+
-- Procedure: validate_org_id
-- Desc     : Valid input for Org ID
-- ----------------------------------------------------------------------------+
   PROCEDURE validate_org_id (
      org_id                     IN       NUMBER
   )
   IS
      l_api_name           CONSTANT VARCHAR2 (30) := 'valid_revenue_class';
   BEGIN
      IF org_id IS NULL
      THEN
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
         THEN
            fnd_message.set_name ('CN', 'CN_INPUT_CANT_NULL');
            fnd_message.set_token ('INPUT_NAME', cn_api.get_lkup_meaning ('ORGANIZATION', 'PE_OBJECT_TYPE'));
            fnd_msg_pub.ADD;
         END IF;

         RAISE fnd_api.g_exc_error;
      END IF;
   END validate_org_id;

-- ----------------------------------------------------------------------------+
-- Procedure: valid_revenue_class
-- Desc     : Check input for Revenue Class
-- ----------------------------------------------------------------------------+
   PROCEDURE valid_revenue_class (
      x_return_status            OUT NOCOPY VARCHAR2,
      p_pe_rec                   IN       pe_rec_type := g_miss_pe_rec,
      p_revenue_class_id_old     IN       NUMBER := NULL,
      p_loading_status           IN       VARCHAR2,
      x_loading_status           OUT NOCOPY VARCHAR2
   )
   IS
      l_api_name           CONSTANT VARCHAR2 (30) := 'valid_revenue_class';
      l_loading_status              VARCHAR2 (80);
   BEGIN
      -- Added the one more parameter to check the old revenue class
      x_return_status := fnd_api.g_ret_sts_success;
      x_loading_status := p_loading_status;

      -- Revenue Class CAN NOT NULL if plan element type is COMMISSION
      IF (p_pe_rec.incentive_type_code IN ('COMMISSION'))
      THEN
         IF (p_pe_rec.rev_class_id IS NULL)
         THEN
            -- Rasie error when user Pass in revenue class Name = NULL
            IF (cn_api.pe_char_field_cannot_null (p_char_field          => p_pe_rec.rev_class_name,
                                                  p_pe_type             => p_pe_rec.quota_type_code,
                                                  p_obj_name            => g_rev_cls_name,
                                                  p_token1              => NULL,
                                                  p_token2              => NULL,
                                                  p_token3              => NULL,
                                                  p_loading_status      => x_loading_status,
                                                  x_loading_status      => l_loading_status
                                                 ) = fnd_api.g_false
               )
            THEN
               RAISE fnd_api.g_exc_error;
            END IF;

            -- Rasie error when user missing Pass in revenue class Name
            IF ((cn_api.chk_miss_char_para (p_char_para           => p_pe_rec.rev_class_name,
                                            p_para_name           => g_rev_cls_name,
                                            p_loading_status      => x_loading_status,
                                            x_loading_status      => l_loading_status
                                           )
                ) = fnd_api.g_true
               )
            THEN
               RAISE fnd_api.g_exc_error;
            END IF;

            -- Rasie error when user pass in revenue class name not exist in
            -- cn_revenue_classes
            IF (cn_api.get_rev_class_id (p_pe_rec.rev_class_name, p_pe_rec.org_id)) IS NULL
            THEN
               IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
               THEN
                  fnd_message.set_name ('CN', 'CN_REV_CLASS_NOT_EXIST');
                  fnd_msg_pub.ADD;
               END IF;

               x_loading_status := 'CN_REV_CLASS_NOT_EXIST';
               RAISE fnd_api.g_exc_error;
            END IF;
         ELSIF p_pe_rec.rev_class_name IS NULL
         THEN
            -- Rev_class_id not null and rev_class_name null, check if
            -- Rev_class_id is exist in DB
            IF (cn_api.get_rev_class_name (p_pe_rec.rev_class_id)) IS NULL
            THEN
               IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
               THEN
                  fnd_message.set_name ('CN', 'CN_REV_CLASS_NOT_EXIST');
                  fnd_msg_pub.ADD;
               END IF;

               x_loading_status := 'CN_REV_CLASS_NOT_EXIST';
               RAISE fnd_api.g_exc_error;
            END IF;
         ELSE
            -- If rev_class_id and rev_class_name both are not
            -- missing or null,
            -- make sure they're compatible, access to same record in
            -- CN_RATE_SCHEDULES
            IF (p_pe_rec.rev_class_id <> cn_api.get_rev_class_id (p_pe_rec.rev_class_name, p_pe_rec.org_id))
            THEN
               -- Error, check the msg level and add an error message to the
               -- API message list
               IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
               THEN
                  fnd_message.set_name ('CN', 'CN_VALUE_ID_ERROR');
                  fnd_message.set_token ('VALUE_NAME', g_rev_cls_name || ' : ' || p_pe_rec.rev_class_name);
                  fnd_message.set_token ('ID_NAME', g_rev_cls_id || ' : ' || p_pe_rec.rev_class_id);
                  fnd_msg_pub.ADD;
               END IF;

               x_loading_status := 'CN_VALUE_ID_ERROR';
               RAISE fnd_api.g_exc_error;
            END IF;
         END IF;

         --+
         -- Validate Rule :
         --    rev_class_target >= 0,
         --+
         IF p_pe_rec.rev_class_target < 0
         THEN
            IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
            THEN
               fnd_message.set_name ('CN', 'CN_REV_TARGET_GT_ZERO');
               fnd_msg_pub.ADD;
            END IF;

            x_loading_status := 'CN_REV_TARGET_GT_ZERO';
            RAISE fnd_api.g_exc_error;
         END IF;

         --+
         -- Validate Rule :
         --   Checks if p_pe_rec.rev_class_id is a parent in a hierarchy
         --   for any other p_pe_rec.rev_class_id already saved in the database
         --   for the p_pe_rec.quota_id
         IF (NOT (cn_quota_rules_pkg.check_rev_class_hier (x_revenue_class_id          => p_pe_rec.rev_class_id,
                                                           x_revenue_class_id_old      => p_revenue_class_id_old,
                                                           x_quota_id                  => p_pe_rec.quota_id,
                                                           x_start_period_id           => NULL,
                                                           x_end_period_id             => NULL
                                                          )
                 )
            )
         THEN
            IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
            THEN
               fnd_msg_pub.ADD;
            END IF;

            x_loading_status := 'REV_CLASS_HIER_CHECK';
            RAISE fnd_api.g_exc_error;
         END IF;
      END IF;                                                                                                                   -- end quota_type_code
   EXCEPTION
      WHEN fnd_api.g_exc_error
      THEN
         x_return_status := fnd_api.g_ret_sts_error;
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         x_loading_status := 'UNEXPECTED_ERR';
      WHEN OTHERS
      THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         x_loading_status := 'UNEXPECTED_ERR';

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;
   END valid_revenue_class;

-- ----------------------------------------------------------------------------+
-- Procedure: chk_dr_man_pe
-- Desc     : Check input for DRAW and MANUAL type plan element
-- ----------------------------------------------------------------------------+
   PROCEDURE chk_dr_man_pe (
      x_return_status            OUT NOCOPY VARCHAR2,
      p_pe_rec                   IN       pe_rec_type := g_miss_pe_rec,
      p_loading_status           IN       VARCHAR2,
      x_loading_status           OUT NOCOPY VARCHAR2
   )
   IS
      l_api_name           CONSTANT VARCHAR2 (30) := 'chk_dr_man_pe';
      l_yes                         fnd_lookups.meaning%TYPE;
      l_no                          fnd_lookups.meaning%TYPE;
   BEGIN
/*   x_return_status := FND_API.G_RET_STS_SUCCESS;
   x_loading_status := p_loading_status;

   SELECT meaning INTO l_yes FROM fnd_lookups
     WHERE lookup_code = 'Y' AND lookup_type = 'YES_NO';
   SELECT meaning INTO l_no FROM fnd_lookups
     WHERE lookup_code = 'N' AND lookup_type = 'YES_NO';
   --+
   -- Validate Rule :
   --   trx_group_code = NULL, payment_type_code=NULL, disc_option_code =NONE
   --   cumulative flag = N, split_flag = N, itd_flag = N
   --   Payment Amount =
   --      NULL : if it's MANUAL type pe
   --      NOT NULL : if it's DRAW type pe
   --   Rate Table = NULL, Discount Rate Table = NULL, Revenue Class = NULL
   --+
   -- Check trx_group_code  for  DRAW and MANUAUL PE type
   IF ( (cn_api.pe_char_field_must_null
   ( p_char_field => p_pe_rec.trx_group_code,
     p_pe_type   => p_pe_rec.quota_type_code,
     p_obj_name  => G_TRX_GROUP,
     p_token1    => NULL ,
     p_token2    => NULL ,
     p_token3    => NULL ,
     p_loading_status => x_loading_status,
     x_loading_status => x_loading_status)) = FND_API.G_FALSE) THEN
      RAISE FND_API.G_EXC_ERROR ;
   END IF;
   -- Check payment_type_code  for  DRAW and MANUAUL PE type
   IF ( (cn_api.pe_char_field_must_null
   ( p_char_field => p_pe_rec.payment_type_code,
     p_pe_type   => p_pe_rec.quota_type_code,
     p_obj_name  => G_PAYMENT_TYPE,
     p_token1    => NULL ,
     p_token2    => NULL ,
     p_token3    => NULL ,
     p_loading_status => x_loading_status,
     x_loading_status => x_loading_status)) = FND_API.G_FALSE) THEN
      RAISE FND_API.G_EXC_ERROR ;
   END IF;
    -- Check disc_option_code  for  DRAW and MANUAUL PE type
   IF (p_pe_rec.disc_option_code <> 'NONE') THEN
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
  THEN
   FND_MESSAGE.SET_NAME ('CN' , 'CN_DISC_OPTION_MUST_NONE');
   FND_MESSAGE.SET_TOKEN ('PLAN_TYPE',
        cn_api.get_lkup_meaning
        (p_pe_rec.quota_type_code,'QUOTA_TYPE'));
   FND_MSG_PUB.Add;
      END IF;
      x_loading_status := 'CN_DISC_OPTION_MUST_NONE';
      RAISE FND_API.G_EXC_ERROR ;
   END IF;
   -- Check cumulative_flag = N for  DRAW and MANUAUL PE type
   IF (p_pe_rec.cumulative_flag <> 'N') THEN
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
  THEN
   FND_MESSAGE.SET_NAME ('CN' , 'CN_CUM_FLAG_MUST_BE');
   FND_MESSAGE.SET_TOKEN ('OBJ_VALUE',l_no);
   FND_MESSAGE.SET_TOKEN ('PLAN_TYPE',
        cn_api.get_lkup_meaning
        (p_pe_rec.quota_type_code,'QUOTA_TYPE'));
   FND_MESSAGE.SET_TOKEN ('TOKEN1',NULL);
   FND_MSG_PUB.Add;
      END IF;
      x_loading_status := 'CN_CUM_FLAG_MUST_BE';
      RAISE FND_API.G_EXC_ERROR ;
   END IF;
    -- Check split_flag = N for  DRAW and MANUAUL PE type
   IF (p_pe_rec.split_flag <> 'N') THEN
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
  THEN
   FND_MESSAGE.SET_NAME ('CN' , 'CN_SPLIT_FLAG_MUST_BE');
   FND_MESSAGE.SET_TOKEN ('OBJ_VALUE',l_no);
   FND_MESSAGE.SET_TOKEN ('PLAN_TYPE',
        cn_api.get_lkup_meaning
        (p_pe_rec.quota_type_code,'QUOTA_TYPE'));
   FND_MESSAGE.SET_TOKEN ('TOKEN1',NULL);
   FND_MESSAGE.SET_TOKEN ('TOKEN2',NULL);
   FND_MESSAGE.SET_TOKEN ('TOKEN3',NULL);
   FND_MSG_PUB.Add;
      END IF;
      x_loading_status := 'CN_SPLIT_FLAG_MUST_BE';
      RAISE FND_API.G_EXC_ERROR ;
   END IF;
    -- Check itd_flag = N for  DRAW and MANUAUL PE type
   IF (p_pe_rec.itd_flag <> 'N') THEN
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
  THEN
   FND_MESSAGE.SET_NAME ('CN' , 'CN_ITD_FLAG_MUST_BE');
   FND_MESSAGE.SET_TOKEN ('OBJ_VALUE',l_no);
   FND_MESSAGE.SET_TOKEN ('PLAN_TYPE',
        cn_api.get_lkup_meaning
        (p_pe_rec.quota_type_code,'QUOTA_TYPE'));
   FND_MESSAGE.SET_TOKEN ('TOKEN1',NULL);
   FND_MSG_PUB.Add;
      END IF;
      x_loading_status := 'CN_ITD_FLAG_MUST_BE';
      RAISE FND_API.G_EXC_ERROR ;
   END IF;
   --   Payment Amount =
   --      NULL : if it's MANUAL type pe
   --      NOT NULL : if it's DRAW type pe
   IF (p_pe_rec.quota_type_code = 'DRAW') THEN
      IF (cn_api.pe_num_field_cannot_null
    ( p_num_field => p_pe_rec.payment_amount,
      p_pe_type   => p_pe_rec.quota_type_code,
      p_obj_name  => G_DRAW_AMOUNT,
      p_token1    => NULL ,
      p_token2    => NULL ,
      p_token3    => NULL ,
      p_loading_status => x_loading_status,
      x_loading_status => x_loading_status) = FND_API.G_FALSE) THEN
   RAISE FND_API.G_EXC_ERROR ;
      END IF;
    ELSIF (p_pe_rec.quota_type_code = 'MANUAL') THEN
      IF (cn_api.pe_num_field_must_null
    ( p_num_field => p_pe_rec.payment_amount,
      p_pe_type   => p_pe_rec.quota_type_code,
      p_obj_name  => G_PAYMENT_AMOUT,
      p_token1    => NULL ,
      p_token2    => NULL ,
      p_token3    => NULL ,
      p_loading_status => x_loading_status,
      x_loading_status => x_loading_status) = FND_API.G_FALSE) THEN
   RAISE FND_API.G_EXC_ERROR ;
      END IF;
   END IF;
   -- Check  for  Rate Table = NULL in DRAW and MANUAUL PE type
   IF (cn_api.pe_num_field_must_null
       ( p_num_field => p_pe_rec.rate_table_id,
   p_pe_type   => p_pe_rec.quota_type_code,
   p_obj_name  => G_RATE_TB,
   p_token1    => NULL ,
   p_token2    => NULL ,
   p_token3    => NULL ,
   p_loading_status => x_loading_status,
   x_loading_status => x_loading_status) = FND_API.G_FALSE) THEN
      RAISE FND_API.G_EXC_ERROR ;
   END IF;
   -- Check  for  Discount Rate Table = NULL  in DRAW and MANUAUL PE type
   IF (cn_api.pe_num_field_must_null
       ( p_num_field => p_pe_rec.disc_rate_table_id,
   p_pe_type   => p_pe_rec.quota_type_code,
   p_obj_name  => G_DISC_RATE_TB,
   p_token1    => NULL ,
   p_token2    => NULL ,
   p_token3    => NULL ,
   p_loading_status => x_loading_status,
   x_loading_status => x_loading_status) = FND_API.G_FALSE) THEN
      RAISE FND_API.G_EXC_ERROR ;
   END IF;
    -- Check  for  Revenue Class = NULL in DRAW and MANUAUL PE type
   IF (cn_api.pe_num_field_must_null
       ( p_num_field => p_pe_rec.rev_class_id,
   p_pe_type   => p_pe_rec.quota_type_code,
   p_obj_name  => G_REV_CLS_NAME,
   p_token1    => NULL ,
   p_token2    => NULL ,
   p_token3    => NULL ,
   p_loading_status => x_loading_status,
   x_loading_status => x_loading_status) = FND_API.G_FALSE) THEN
      RAISE FND_API.G_EXC_ERROR ;
   END IF;
   -- Check for target =0  in DRAW and MANUAUL PE type: target = 0
   IF (p_pe_rec.target <> 0) THEN
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
  THEN
   FND_MESSAGE.SET_NAME ('CN' , 'CN_PE_TARGET_MUST_BE');
   FND_MESSAGE.SET_TOKEN ('OBJ_VALUE','= 0');
   FND_MESSAGE.SET_TOKEN ('PLAN_TYPE',
        cn_api.get_lkup_meaning
        (p_pe_rec.quota_type_code,'QUOTA_TYPE'));
   FND_MESSAGE.SET_TOKEN ('TOKEN1',NULL);
   FND_MSG_PUB.Add;
      END IF;
      x_loading_status := 'CN_PE_TARGET_MUST_BE';
      RAISE FND_API.G_EXC_ERROR ;
   END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      x_loading_status := 'UNEXPECTED_ERR';

   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      x_loading_status := 'UNEXPECTED_ERR';
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,l_api_name );
      END IF;
*/
      fnd_message.set_name ('CN', 'CN_PACKAGE_OBSELETE');
      fnd_msg_pub.ADD;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      x_loading_status := 'CN_PACKAGE_OBSELETE';
      RAISE fnd_api.g_exc_error;
   END chk_dr_man_pe;

-- ----------------------------------------------------------------------------+
-- Procedure: chk_revenue_quota_pe
-- Desc     : Check input for  REVENUE QUOTA type plan element
-- ----------------------------------------------------------------------------+
   PROCEDURE chk_revenue_quota_pe (
      x_return_status            OUT NOCOPY VARCHAR2,
      p_pe_rec                   IN       pe_rec_type := g_miss_pe_rec,
      p_loading_status           IN       VARCHAR2,
      x_loading_status           OUT NOCOPY VARCHAR2
   )
   IS
      l_api_name           CONSTANT VARCHAR2 (30) := 'chk_revenue_quota_pe';
      l_yes                         fnd_lookups.meaning%TYPE;
      l_no                          fnd_lookups.meaning%TYPE;
   BEGIN
/*   x_return_status := FND_API.G_RET_STS_SUCCESS;
   x_loading_status := p_loading_status;

   SELECT meaning INTO l_yes FROM fnd_lookups
     WHERE lookup_code = 'Y' AND lookup_type = 'YES_NO';
   SELECT meaning INTO l_no FROM fnd_lookups
     WHERE lookup_code = 'N' AND lookup_type = 'YES_NO';

   --+
   -- Validate Rule : cumulative flag Y only
   --+
   IF (p_pe_rec.cumulative_flag <> 'Y') THEN
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
  THEN
   FND_MESSAGE.SET_NAME ('CN' , 'CN_CUM_FLAG_MUST_BE');
   FND_MESSAGE.SET_TOKEN ('OBJ_VALUE',l_yes);
   FND_MESSAGE.SET_TOKEN ('PLAN_TYPE',
        cn_api.get_lkup_meaning
        (p_pe_rec.quota_type_code,'QUOTA_TYPE'));
   FND_MESSAGE.SET_TOKEN ('TOKEN1',NULL);
   FND_MSG_PUB.Add;
      END IF;
      x_loading_status := 'CN_CUM_FLAG_MUST_BE';
      RAISE FND_API.G_EXC_ERROR ;
   END IF;
   --+
   -- Check input for 'Group By' case (trx_group_code = 'GROUP')
   --+
   IF p_pe_rec.trx_group_code = 'GROUP' THEN
      --+
      -- Validate Rule : Groupby
      -- ITD Flag = N ,split flag = N , target > 0
      -- Payment Amount
      --   NOT NULL : if payment type code = Payment amount %
      --   NULL : if payment type code = Fixed amount or applied Trx %
      --+
      -- Check itd_flag  = N
      IF (p_pe_rec.itd_flag <> 'N') THEN
   IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
     THEN
      FND_MESSAGE.SET_NAME ('CN' , 'CN_ITD_FLAG_MUST_BE');
      FND_MESSAGE.SET_TOKEN ('OBJ_VALUE',l_no);
      FND_MESSAGE.SET_TOKEN ('PLAN_TYPE',
           cn_api.get_lkup_meaning
           (p_pe_rec.quota_type_code,'QUOTA_TYPE'));
      FND_MESSAGE.SET_TOKEN ('TOKEN1',G_TRX_GROUP||' = '||
           cn_api.get_lkup_meaning
           (p_pe_rec.trx_group_code,'QUOTA_TRX_GROUP'))
        ;
      FND_MSG_PUB.Add;
   END IF;
   x_loading_status := 'CN_ITD_FLAG_MUST_BE';
   RAISE FND_API.G_EXC_ERROR ;
      END IF;
      -- Check split_flag = N
      IF (p_pe_rec.split_flag <> 'N') THEN
   IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
     THEN
      FND_MESSAGE.SET_NAME ('CN' , 'CN_SPLIT_FLAG_MUST_BE');
      FND_MESSAGE.SET_TOKEN ('OBJ_VALUE',l_no);
      FND_MESSAGE.SET_TOKEN ('PLAN_TYPE',
           cn_api.get_lkup_meaning
           (p_pe_rec.quota_type_code,'QUOTA_TYPE'));
      FND_MESSAGE.SET_TOKEN ('TOKEN1',G_TRX_GROUP ||' = '||
           cn_api.get_lkup_meaning
           (p_pe_rec.trx_group_code,'QUOTA_TRX_GROUP'))
        ;
      FND_MESSAGE.SET_TOKEN ('TOKEN2',NULL);
      FND_MESSAGE.SET_TOKEN ('TOKEN3',NULL);
      FND_MSG_PUB.Add;
   END IF;
   x_loading_status := 'CN_SPLIT_FLAG_MUST_BE';
   RAISE FND_API.G_EXC_ERROR ;
      END IF;
      -- Check target > 0
      IF (p_pe_rec.target <= 0) THEN
   IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
     THEN
      FND_MESSAGE.SET_NAME ('CN' , 'CN_TARGET_CANNOT_ZERO');
      FND_MSG_PUB.Add;
   END IF;
   x_loading_status := 'CN_TARGET_CANNOT_ZERO';
   RAISE FND_API.G_EXC_ERROR ;
      END IF;
      -- Check Payment Amount
      -- NOT NULL : if payment type code = Payment amount %
      -- NULL : if payment type code = Fixed amount or applied Trx %
      IF p_pe_rec.payment_type_code = 'PAYMENT' THEN
   IF (cn_api.pe_num_field_cannot_null
       ( p_num_field => p_pe_rec.payment_amount,
         p_pe_type   => p_pe_rec.quota_type_code,
         p_obj_name  => G_PAYMENT_AMOUT,
         p_token1    => G_TRX_GROUP||' = '||
         cn_api.get_lkup_meaning
         (p_pe_rec.trx_group_code,'QUOTA_TRX_GROUP'),
         p_token2    => G_PAYMENT_TYPE ||' = '||
         cn_api.get_lkup_meaning
         (p_pe_rec.payment_type_code,'QUOTA_PAYMENT_TYPE'),
         p_token3    => NULL ,
         p_loading_status => x_loading_status,
         x_loading_status => x_loading_status) = FND_API.g_false)
     THEN
      RAISE FND_API.G_EXC_ERROR ;
   END IF;
       ELSIF p_pe_rec.payment_type_code IN ('TRANSACTION','FIXED') AND
   (cn_api.pe_num_field_must_null
    ( p_num_field => p_pe_rec.payment_amount,
      p_pe_type   => p_pe_rec.quota_type_code,
      p_obj_name  => G_PAYMENT_AMOUT,
      p_token1    => G_TRX_GROUP||' = '||
      cn_api.get_lkup_meaning
      (p_pe_rec.trx_group_code,'QUOTA_TRX_GROUP'),
      p_token2    => G_PAYMENT_TYPE||' = '||
      cn_api.get_lkup_meaning
      (p_pe_rec.payment_type_code,'QUOTA_PAYMENT_TYPE'),
      p_token3    => NULL ,
      p_loading_status => x_loading_status,
      x_loading_status => x_loading_status) = FND_API.g_false)
     THEN
   RAISE FND_API.G_EXC_ERROR ;
      END IF;
   END IF ;
   --+
   -- Check input for 'Individual' case (trx_group_code = 'INDIVIDUAL')
   --+
   IF p_pe_rec.trx_group_code = 'INDIVIDUAL' THEN
      -- Check for Non-Interval-To-Date case : itd_flag = 'N'
      --+
      -- Validate Rule :
      --   target > 0,
      --   split_flag = N if Payment Type = Payment amount %or Fixed Amount
      --   Payment Amount
      --     NOT NULL : if payment type code = Payment amount %
      --     NULL : if payment type code = Fixed amount or applied Trx %
      --+
      IF p_pe_rec.itd_flag = 'N' THEN
   -- Check target > 0
   IF (p_pe_rec.target <= 0) THEN
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
         FND_MESSAGE.SET_NAME ('CN' , 'CN_TARGET_CANNOT_ZERO');
         FND_MSG_PUB.Add;
      END IF;
      x_loading_status := 'CN_TARGET_CANNOT_ZERO';
      RAISE FND_API.G_EXC_ERROR ;
   END IF;
   -- Check split_flag = N if Payment Type = Payment amount %
   -- or Fixed Amount
   IF (p_pe_rec.payment_type_code IN ('PAYMENT','FIXED')) AND
     (p_pe_rec.split_flag <> 'N') THEN
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
         FND_MESSAGE.SET_NAME ('CN' , 'CN_SPLIT_FLAG_MUST_BE');
         FND_MESSAGE.SET_TOKEN ('OBJ_VALUE',l_no);
         FND_MESSAGE.SET_TOKEN ('PLAN_TYPE',
              cn_api.get_lkup_meaning
              (p_pe_rec.quota_type_code,'QUOTA_TYPE'));
         FND_MESSAGE.SET_TOKEN ('TOKEN1',G_TRX_GROUP||' = '||
              cn_api.get_lkup_meaning
              (p_pe_rec.trx_group_code,
               'QUOTA_TRX_GROUP'));
         FND_MESSAGE.SET_TOKEN ('TOKEN2',G_PAYMENT_TYPE||' = '||
              cn_api.get_lkup_meaning
              (p_pe_rec.payment_type_code,
               'QUOTA_PAYMENT_TYPE'));
         FND_MESSAGE.SET_TOKEN ('TOKEN3',G_ITD||' = '||
              p_pe_rec.itd_flag);
         FND_MSG_PUB.Add;
      END IF;
      x_loading_status := 'CN_SPLIT_FLAG_MUST_BE';
      RAISE FND_API.G_EXC_ERROR ;
   END IF;
   -- Check Payment Amount
   -- NOT NULL : if payment type code = Payment amount %
   -- NULL : if payment type code = Fixed amount or applied Trx %
   IF p_pe_rec.payment_type_code = 'PAYMENT' THEN
      IF  (cn_api.pe_num_field_cannot_null
      ( p_num_field => p_pe_rec.payment_amount,
        p_pe_type   => p_pe_rec.quota_type_code,
        p_obj_name  => G_PAYMENT_AMOUT,
        p_token1    => G_TRX_GROUP||' = '||
                       cn_api.get_lkup_meaning
                       (p_pe_rec.trx_group_code,'QUOTA_TRX_GROUP'),
        p_token2    => G_PAYMENT_TYPE||' = '||
                cn_api.get_lkup_meaning
                (p_pe_rec.payment_type_code,'QUOTA_PAYMENT_TYPE'),
        p_token3    => G_ITD||' = '||p_pe_rec.itd_flag,
        p_loading_status => x_loading_status,
        x_loading_status => x_loading_status) = FND_API.g_false)
        THEN
         RAISE FND_API.G_EXC_ERROR ;
      END IF;
    ELSIF p_pe_rec.payment_type_code IN ('TRANSACTION','FIXED') AND
      (cn_api.pe_num_field_must_null
       ( p_num_field => p_pe_rec.payment_amount,
         p_pe_type   => p_pe_rec.quota_type_code,
         p_obj_name  => G_PAYMENT_AMOUT,
         p_token1    => G_TRX_GROUP||' = '||
                        cn_api.get_lkup_meaning
                        (p_pe_rec.trx_group_code,'QUOTA_TRX_GROUP'),
         p_token2    => G_PAYMENT_TYPE||' = '||
                        cn_api.get_lkup_meaning
                       (p_pe_rec.payment_type_code,'QUOTA_PAYMENT_TYPE'),
         p_token3    => G_ITD||' = '||p_pe_rec.itd_flag,
         p_loading_status => x_loading_status,
         x_loading_status => x_loading_status) = FND_API.G_FALSE)
        THEN
      RAISE FND_API.G_EXC_ERROR ;
   END IF;
       ELSIF p_pe_rec.itd_flag = 'Y' THEN
   -- Check for Interval-To-Date case : itd_flag = 'Y'
   --+
   -- Validate Rule :
   --   target = 0,
   --   No Fixed Amount payment type allowed
   --   split_flag = N if Payment Type= Payment amount % or Applied Trx%
   --   Payment Amount = 0
   --+
   -- Check target = 0
   IF (p_pe_rec.target <> 0) THEN
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
         FND_MESSAGE.SET_NAME ('CN' , 'CN_PE_TARGET_MUST_BE');
         FND_MESSAGE.SET_TOKEN ('OBJ_VALUE','= 0');
         FND_MESSAGE.SET_TOKEN ('PLAN_TYPE',
              cn_api.get_lkup_meaning
              (p_pe_rec.quota_type_code,'QUOTA_TYPE'));
         FND_MESSAGE.SET_TOKEN ('TOKEN1',
              G_ITD||' = '||p_pe_rec.itd_flag);
         FND_MSG_PUB.Add;
      END IF;
      x_loading_status := 'CN_PE_TARGET_MUST_BE';
      RAISE FND_API.G_EXC_ERROR ;
   END IF;
   -- Check no 'Fixed Amount' payment type allowed
   IF p_pe_rec.payment_type_code = 'FIXED' THEN
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
         FND_MESSAGE.SET_NAME ('CN' ,'CN_ITD_NO_FIXED_AMOUNT');
         FND_MSG_PUB.Add;
      END IF;
      x_loading_status := 'CN_ITD_NO_FIXED_AMOUNT';
      RAISE FND_API.G_EXC_ERROR ;
   END IF;
   -- Check split_flag = N if Payment Type = Payment amount %
   -- or Applied Trx %
   IF (p_pe_rec.payment_type_code IN ('PAYMENT','TRANSACTION')) AND
     (p_pe_rec.split_flag <> 'N') THEN
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
         FND_MESSAGE.SET_NAME ('CN' , 'CN_SPLIT_FLAG_MUST_BE');
         FND_MESSAGE.SET_TOKEN ('OBJ_VALUE',l_no);
         FND_MESSAGE.SET_TOKEN ('PLAN_TYPE',
              cn_api.get_lkup_meaning
              (p_pe_rec.quota_type_code,'QUOTA_TYPE'));
         FND_MESSAGE.SET_TOKEN ('TOKEN1', G_TRX_GROUP||' = '||
              cn_api.get_lkup_meaning
              (p_pe_rec.trx_group_code,
               'QUOTA_TRX_GROUP'));
         FND_MESSAGE.SET_TOKEN ('TOKEN2', G_PAYMENT_TYPE||' = '||
              cn_api.get_lkup_meaning
              (p_pe_rec.payment_type_code,
               'QUOTA_PAYMENT_TYPE'));
         FND_MESSAGE.SET_TOKEN ('TOKEN3',
              G_ITD||' = '||p_pe_rec.itd_flag);
         FND_MSG_PUB.Add;
      END IF;
      x_loading_status := 'CN_SPLIT_FLAG_MUST_BE';
      RAISE FND_API.G_EXC_ERROR ;
   END IF;
   -- Check Payment Amount : Must be 0
   IF (p_pe_rec.payment_amount <> 0) THEN
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
         FND_MESSAGE.SET_NAME ('CN' , 'CN_PE_PAYMENT_AMT_MUST_BE');
         FND_MESSAGE.SET_TOKEN ('OBJ_VALUE','= 0');
         FND_MESSAGE.SET_TOKEN ('PLAN_TYPE',
              cn_api.get_lkup_meaning
              (p_pe_rec.quota_type_code,'QUOTA_TYPE'));
         FND_MESSAGE.SET_TOKEN ('TOKEN1',G_TRX_GROUP||' = '||
              cn_api.get_lkup_meaning
              (p_pe_rec.trx_group_code,
               'QUOTA_TRX_GROUP'));
         FND_MESSAGE.SET_TOKEN ('TOKEN2',G_PAYMENT_TYPE||' = '||
              cn_api.get_lkup_meaning
              (p_pe_rec.payment_type_code,
               'QUOTA_PAYMENT_TYPE'));
         FND_MESSAGE.SET_TOKEN ('TOKEN3',
              G_ITD||' = '||p_pe_rec.itd_flag);
         FND_MSG_PUB.Add;
      END IF;
      x_loading_status := 'CN_PE_PAYMENT_AMT_MUST_BE';
      RAISE FND_API.G_EXC_ERROR ;
   END IF;
      END IF ; -- end ITD_FLAG
   END IF ; -- end INDIVIDUAL
   -- Check rate table
   valid_rate_table
     ( x_return_status  => x_return_status,
       p_pe_rec         => p_pe_rec,
       p_loading_status => x_loading_status,
       x_loading_status => x_loading_status);
   IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE FND_API.G_EXC_ERROR ;
   END IF;
   -- Check discount rate table
   IF (p_pe_rec.disc_option_code IN ('PAYMENT','QUOTA')) THEN
      valid_disc_rate_table
  ( x_return_status  => x_return_status,
    p_pe_rec         => p_pe_rec,
    p_loading_status => x_loading_status,
    x_loading_status => x_loading_status);
      IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
   RAISE FND_API.G_EXC_ERROR ;
      END IF;
    ELSE
      -- Check  for  Discount Rate Table must be NULL
      IF (cn_api.pe_num_field_must_null
    ( p_num_field => p_pe_rec.disc_rate_table_id,
      p_pe_type   => p_pe_rec.quota_type_code,
      p_obj_name  => G_DISC_RATE_TB,
      p_token1    =>
      G_DISC_OPTION||' = '||
      cn_api.get_lkup_meaning
      (p_pe_rec.disc_option_code,'DISCOUNT_OPTION'),
      p_token2    => NULL ,
      p_token3    => NULL ,
      p_loading_status => x_loading_status,
      x_loading_status => x_loading_status) = FND_API.G_FALSE) THEN
   RAISE FND_API.G_EXC_ERROR ;
      END IF;
   END IF;

   -- Check rc
   valid_revenue_class
     ( x_return_status  => x_return_status,
       p_pe_rec         => p_pe_rec,
       p_loading_status => x_loading_status,
       x_loading_status => x_loading_status);
   IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE FND_API.G_EXC_ERROR ;
   END IF;


EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      x_loading_status := 'UNEXPECTED_ERR';

   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      x_loading_status := 'UNEXPECTED_ERR';
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,l_api_name );
      END IF;
*/
      fnd_message.set_name ('CN', 'CN_PACKAGE_OBSELETE');
      fnd_msg_pub.ADD;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      x_loading_status := 'CN_PACKAGE_OBSELETE';
      RAISE fnd_api.g_exc_error;
   END chk_revenue_quota_pe;

-- ----------------------------------------------------------------------------+
-- Procedure: chk_unit_quota_pe
-- Desc     : Check input for  UNIT QUOTA type plan element
-- ----------------------------------------------------------------------------+
   PROCEDURE chk_unit_quota_pe (
      x_return_status            OUT NOCOPY VARCHAR2,
      p_pe_rec                   IN       pe_rec_type := g_miss_pe_rec,
      p_loading_status           IN       VARCHAR2,
      x_loading_status           OUT NOCOPY VARCHAR2
   )
   IS
      l_api_name           CONSTANT VARCHAR2 (30) := 'chk_unit_quota_pe';
      l_yes                         fnd_lookups.meaning%TYPE;
      l_no                          fnd_lookups.meaning%TYPE;
   BEGIN
/*   x_return_status := FND_API.G_RET_STS_SUCCESS;
   x_loading_status := p_loading_status;

   SELECT meaning INTO l_yes FROM fnd_lookups
     WHERE lookup_code = 'Y' AND lookup_type = 'YES_NO';
   SELECT meaning INTO l_no FROM fnd_lookups
     WHERE lookup_code = 'N' AND lookup_type = 'YES_NO';
   --+
   -- Validate Rule : cumulative flag Y only
   --+
   IF (p_pe_rec.cumulative_flag <> 'Y') THEN
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
  THEN
   FND_MESSAGE.SET_NAME ('CN' , 'CN_CUM_FLAG_MUST_BE');
   FND_MESSAGE.SET_TOKEN ('OBJ_VALUE',l_yes);
   FND_MESSAGE.SET_TOKEN ('PLAN_TYPE',
        cn_api.get_lkup_meaning
        (p_pe_rec.quota_type_code,'QUOTA_TYPE'));
   FND_MESSAGE.SET_TOKEN ('TOKEN1',NULL);
   FND_MSG_PUB.Add;
      END IF;
      x_loading_status := 'CN_CUM_FLAG_MUST_BE';
      RAISE FND_API.G_EXC_ERROR ;
   END IF;
   --+
   -- Check input for 'Group By' case (trx_group_code = 'GROUP')
   --+
   IF p_pe_rec.trx_group_code = 'GROUP' THEN
      --+
      -- Validate Rule : Groupby
      -- ITD Flag = N ,split flag = N , target > 0
      -- Payment Amount
      --   NOT NULL : if payment type code = Payment amount %
      --   NULL : if payment type code = Fixed amount or applied Trx %
      --+
      -- Check itd_flag  = N
      IF (p_pe_rec.itd_flag <> 'N') THEN
   IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
     THEN
      FND_MESSAGE.SET_NAME ('CN' , 'CN_ITD_FLAG_MUST_BE');
      FND_MESSAGE.SET_TOKEN ('OBJ_VALUE',l_no);
      FND_MESSAGE.SET_TOKEN ('PLAN_TYPE',
           cn_api.get_lkup_meaning
           (p_pe_rec.quota_type_code,'QUOTA_TYPE'));
      FND_MESSAGE.SET_TOKEN ('TOKEN1', G_TRX_GROUP||' = '||
           cn_api.get_lkup_meaning
                (p_pe_rec.trx_group_code,'QUOTA_TRX_GROUP'));
      FND_MSG_PUB.Add;
   END IF;
   x_loading_status := 'CN_ITD_FLAG_MUST_BE';
   RAISE FND_API.G_EXC_ERROR ;
      END IF;
      -- Check split_flag = N
      IF (p_pe_rec.split_flag <> 'N') THEN
   IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
     THEN
      FND_MESSAGE.SET_NAME ('CN' , 'CN_SPLIT_FLAG_MUST_BE');
      FND_MESSAGE.SET_TOKEN ('OBJ_VALUE',l_no);
      FND_MESSAGE.SET_TOKEN ('PLAN_TYPE',
           cn_api.get_lkup_meaning
           (p_pe_rec.quota_type_code,'QUOTA_TYPE'));
      FND_MESSAGE.SET_TOKEN ('TOKEN1', G_TRX_GROUP||' = '||
           cn_api.get_lkup_meaning
           (p_pe_rec.trx_group_code,'QUOTA_TRX_GROUP'))
        ;
      FND_MESSAGE.SET_TOKEN ('TOKEN2',NULL);
      FND_MESSAGE.SET_TOKEN ('TOKEN3',NULL);
      FND_MSG_PUB.Add;
   END IF;
   x_loading_status := 'CN_SPLIT_FLAG_MUST_BE';
   RAISE FND_API.G_EXC_ERROR ;
      END IF;
      -- Check target > 0
      IF (p_pe_rec.target <= 0) THEN
   IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
     THEN
      FND_MESSAGE.SET_NAME ('CN' , 'CN_TARGET_CANNOT_ZERO');
      FND_MSG_PUB.Add;
   END IF;
   x_loading_status := 'CN_TARGET_CANNOT_ZERO';
   RAISE FND_API.G_EXC_ERROR ;
      END IF;
      -- Check Payment Amount
      -- NOT NULL : if payment type code = Payment amount %
      -- NULL : if payment type code = Fixed amount or applied Trx %
      IF p_pe_rec.payment_type_code = 'PAYMENT' THEN
   IF (cn_api.pe_num_field_cannot_null
       ( p_num_field => p_pe_rec.payment_amount,
         p_pe_type   => p_pe_rec.quota_type_code,
         p_obj_name  => G_PAYMENT_AMOUT,
         p_token1    => G_TRX_GROUP||' = '||
                        cn_api.get_lkup_meaning
                        (p_pe_rec.trx_group_code,'QUOTA_TRX_GROUP'),
         p_token2    => G_PAYMENT_TYPE||' = '||
                        cn_api.get_lkup_meaning
                        (p_pe_rec.payment_type_code,
             'QUOTA_PAYMENT_TYPE'),
         p_token3    => NULL ,
         p_loading_status => x_loading_status,
         x_loading_status => x_loading_status) = FND_API.g_false)
     THEN
      RAISE FND_API.G_EXC_ERROR ;
   END IF;
       ELSIF p_pe_rec.payment_type_code IN ('TRANSACTION','FIXED') AND
   (cn_api.pe_num_field_must_null
    ( p_num_field => p_pe_rec.payment_amount,
      p_pe_type   => p_pe_rec.quota_type_code,
      p_obj_name  => G_PAYMENT_AMOUT,
      p_token1    => G_TRX_GROUP||' = '||
                     cn_api.get_lkup_meaning
                     (p_pe_rec.trx_group_code,'QUOTA_TRX_GROUP'),
      p_token2    => G_PAYMENT_TYPE||' = '||
                     cn_api.get_lkup_meaning
                     (p_pe_rec.payment_type_code,'QUOTA_PAYMENT_TYPE'),
      p_token3    => NULL ,
      p_loading_status => x_loading_status,
      x_loading_status => x_loading_status) = FND_API.g_false)
     THEN
   RAISE FND_API.G_EXC_ERROR ;
      END IF;
   END IF ;
   --+
   -- Check input for 'Individual' case (trx_group_code = 'INDIVIDUAL')
   --+
   IF p_pe_rec.trx_group_code = 'INDIVIDUAL' THEN
      -- Check for Non-Interval-To-Date case : itd_flag = 'N'
      --+
      -- Validate Rule :
      --   target > 0,
      --   split_flag = N if Payment Type = Payment amount %or Fixed Amount
      --   Payment Amount
      --     NOT NULL : if payment type code = Payment amount %
      --     NULL : if payment type code = Fixed amount or applied Trx %
      --+
      IF p_pe_rec.itd_flag = 'N' THEN
   -- Check target > 0
   IF (p_pe_rec.target <= 0) THEN
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
         FND_MESSAGE.SET_NAME ('CN' , 'CN_TARGET_CANNOT_ZERO');
         FND_MSG_PUB.Add;
      END IF;
      x_loading_status := 'CN_TARGET_CANNOT_ZERO';
      RAISE FND_API.G_EXC_ERROR ;
   END IF;
   -- Check split_flag = N if Payment Type = Payment amount %
   -- or Fixed Amount
   IF (p_pe_rec.payment_type_code IN ('PAYMENT','FIXED')) AND
     (p_pe_rec.split_flag <> 'N') THEN
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
         FND_MESSAGE.SET_NAME ('CN' , 'CN_SPLIT_FLAG_MUST_BE');
         FND_MESSAGE.SET_TOKEN ('OBJ_VALUE',l_no);
         FND_MESSAGE.SET_TOKEN ('PLAN_TYPE',
              cn_api.get_lkup_meaning
              (p_pe_rec.quota_type_code,'QUOTA_TYPE'));
         FND_MESSAGE.SET_TOKEN ('TOKEN1', G_TRX_GROUP||' = '||
              cn_api.get_lkup_meaning
              (p_pe_rec.trx_group_code,
               'QUOTA_TRX_GROUP'));
         FND_MESSAGE.SET_TOKEN ('TOKEN2',G_PAYMENT_TYPE||' = '||
              cn_api.get_lkup_meaning
              (p_pe_rec.payment_type_code,
               'QUOTA_PAYMENT_TYPE'));
         FND_MESSAGE.SET_TOKEN ('TOKEN3',
              G_ITD||' = '||p_pe_rec.itd_flag);
         FND_MSG_PUB.Add;
      END IF;
      x_loading_status := 'CN_SPLIT_FLAG_MUST_BE';
      RAISE FND_API.G_EXC_ERROR ;
   END IF;
   -- Check Payment Amount
   -- NOT NULL : if payment type code = Payment amount %
   -- NULL : if payment type code = Fixed amount or applied Trx %
   IF p_pe_rec.payment_type_code = 'PAYMENT' THEN
      IF  (cn_api.pe_num_field_cannot_null
      ( p_num_field => p_pe_rec.payment_amount,
        p_pe_type   => p_pe_rec.quota_type_code,
        p_obj_name  => G_PAYMENT_AMOUT,
        p_token1    => G_TRX_GROUP||' = '||
                       cn_api.get_lkup_meaning
                       (p_pe_rec.trx_group_code,'QUOTA_TRX_GROUP'),
        p_token2    => G_PAYMENT_TYPE||' = '||
                       cn_api.get_lkup_meaning
                      (p_pe_rec.payment_type_code,
           'QUOTA_PAYMENT_TYPE'),
        p_token3    => G_ITD||' = '||p_pe_rec.itd_flag,
        p_loading_status => x_loading_status,
        x_loading_status => x_loading_status) = FND_API.g_false)
        THEN
         RAISE FND_API.G_EXC_ERROR ;
      END IF;
    ELSIF p_pe_rec.payment_type_code IN ('TRANSACTION','FIXED') AND
      (cn_api.pe_num_field_must_null
       ( p_num_field => p_pe_rec.payment_amount,
         p_pe_type   => p_pe_rec.quota_type_code,
         p_obj_name  => G_PAYMENT_AMOUT,
         p_token1    => G_TRX_GROUP||' = '||
                        cn_api.get_lkup_meaning
                        (p_pe_rec.trx_group_code,'QUOTA_TRX_GROUP'),
         p_token2    => G_PAYMENT_TYPE||' = '||
                        cn_api.get_lkup_meaning
                       (p_pe_rec.payment_type_code,
            'QUOTA_PAYMENT_TYPE'),
         p_token3    => G_ITD||' = '||p_pe_rec.itd_flag,
         p_loading_status => x_loading_status,
         x_loading_status => x_loading_status) = FND_API.G_FALSE)
        THEN
      RAISE FND_API.G_EXC_ERROR ;
   END IF;
       ELSIF p_pe_rec.itd_flag = 'Y' THEN
   -- Check for Interval-To-Date case : itd_flag = 'Y'
   --+
   -- Validate Rule :
   --   target = 0,
   --   No Fixed Amount payment type allowed
   --   split_flag = N if Payment Type= Payment amount % or Applied Trx%
   --   Payment Amount = 0
   --+
   -- Check target = 0
   IF (p_pe_rec.target <> 0) THEN
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
         FND_MESSAGE.SET_NAME ('CN' , 'CN_PE_TARGET_MUST_BE');
         FND_MESSAGE.SET_TOKEN ('OBJ_VALUE','= 0');
         FND_MESSAGE.SET_TOKEN ('PLAN_TYPE',
              cn_api.get_lkup_meaning
              (p_pe_rec.quota_type_code,'QUOTA_TYPE'));
         FND_MESSAGE.SET_TOKEN ('TOKEN1',
              G_ITD||' = '||p_pe_rec.itd_flag);
         FND_MSG_PUB.Add;
      END IF;
      x_loading_status := 'CN_PE_TARGET_MUST_BE';
      RAISE FND_API.G_EXC_ERROR ;
   END IF;
   -- Check no 'Fixed Amount' payment type allowed
   IF p_pe_rec.payment_type_code = 'FIXED' THEN
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
         FND_MESSAGE.SET_NAME ('CN' ,'CN_ITD_NO_FIXED_AMOUNT');
         FND_MSG_PUB.Add;
      END IF;
      x_loading_status := 'CN_ITD_NO_FIXED_AMOUNT';
      RAISE FND_API.G_EXC_ERROR ;
   END IF;
   -- Check split_flag = N if Payment Type = Payment amount %
   -- or Applied Trx %
   IF (p_pe_rec.payment_type_code IN ('PAYMENT','TRANSACTION')) AND
     (p_pe_rec.split_flag <> 'N') THEN
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
         FND_MESSAGE.SET_NAME ('CN' , 'CN_SPLIT_FLAG_MUST_BE');
         FND_MESSAGE.SET_TOKEN ('OBJ_VALUE',l_no);
         FND_MESSAGE.SET_TOKEN ('PLAN_TYPE',
              cn_api.get_lkup_meaning
              (p_pe_rec.quota_type_code,'QUOTA_TYPE'));
         FND_MESSAGE.SET_TOKEN ('TOKEN1', G_TRX_GROUP||' = '||
              cn_api.get_lkup_meaning
              (p_pe_rec.trx_group_code,
               'QUOTA_TRX_GROUP'));
         FND_MESSAGE.SET_TOKEN ('TOKEN2', G_PAYMENT_TYPE||' = '||
              cn_api.get_lkup_meaning
              (p_pe_rec.payment_type_code,
               'QUOTA_PAYMENT_TYPE'));
         FND_MESSAGE.SET_TOKEN ('TOKEN3',
              G_ITD||' = '||p_pe_rec.itd_flag);
              FND_MSG_PUB.Add;
      END IF;
      x_loading_status := 'CN_SPLIT_FLAG_MUST_BE';
      RAISE FND_API.G_EXC_ERROR ;
   END IF;
   -- Check Payment Amount : Must be 0
   IF (p_pe_rec.payment_amount <> 0) THEN
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
         FND_MESSAGE.SET_NAME ('CN' , 'CN_PE_PAYMENT_AMT_MUST_BE');
         FND_MESSAGE.SET_TOKEN ('OBJ_VALUE','= 0');
         FND_MESSAGE.SET_TOKEN ('PLAN_TYPE',
              cn_api.get_lkup_meaning
              (p_pe_rec.quota_type_code,'QUOTA_TYPE'));
         FND_MESSAGE.SET_TOKEN ('TOKEN1', G_TRX_GROUP||' = '||
              cn_api.get_lkup_meaning
              (p_pe_rec.trx_group_code,
               'QUOTA_TRX_GROUP'));
         FND_MESSAGE.SET_TOKEN ('TOKEN2', G_PAYMENT_TYPE||' = '||
              cn_api.get_lkup_meaning
              (p_pe_rec.payment_type_code,
               'QUOTA_PAYMENT_TYPE'));
         FND_MESSAGE.SET_TOKEN ('TOKEN3',
              G_ITD||' = '||p_pe_rec.itd_flag);
         FND_MSG_PUB.Add;
      END IF;
      x_loading_status := 'CN_PE_PAYMENT_AMT_MUST_BE';
      RAISE FND_API.G_EXC_ERROR ;
   END IF;
      END IF ; -- end ITD_FLAG
   END IF ; -- end INDIVIDUAL
   -- Check rate table
   valid_rate_table
     ( x_return_status  => x_return_status,
       p_pe_rec         => p_pe_rec,
       p_loading_status => x_loading_status,
       x_loading_status => x_loading_status);
   IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE FND_API.G_EXC_ERROR ;
   END IF;
   -- Check discount rate table = Not Allowed
   -- Discount Option Code must = NONE is validate when calling
   -- valid_lookup_code() from valid_plan_element
   IF (cn_api.pe_num_field_must_null
       ( p_num_field => p_pe_rec.disc_rate_table_id,
   p_pe_type   => p_pe_rec.quota_type_code,
   p_obj_name  => G_DISC_RATE_TB,
   p_token1    => NULL ,
   p_token2    => NULL ,
   p_token3    => NULL ,
   p_loading_status => x_loading_status,
   x_loading_status => x_loading_status) = FND_API.g_false)
      THEN
      RAISE FND_API.G_EXC_ERROR ;
   END IF;
   -- Check rc
   valid_revenue_class
     ( x_return_status  => x_return_status,
       p_pe_rec         => p_pe_rec,
       p_loading_status => x_loading_status,
       x_loading_status => x_loading_status);
   IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE FND_API.G_EXC_ERROR ;
   END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      x_loading_status := 'UNEXPECTED_ERR';

   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      x_loading_status := 'UNEXPECTED_ERR';
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,l_api_name );
      END IF;
*/
      fnd_message.set_name ('CN', 'CN_PACKAGE_OBSELETE');
      fnd_msg_pub.ADD;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      x_loading_status := 'CN_PACKAGE_OBSELETE';
      RAISE fnd_api.g_exc_error;
   END chk_unit_quota_pe;

-- ----------------------------------------------------------------------------+
-- Procedure: chk_revenue_non_quota_pe
-- Desc     : Check input for  REVENUE QUOTA type plan element
-- ----------------------------------------------------------------------------+
   PROCEDURE chk_revenue_non_quota_pe (
      x_return_status            OUT NOCOPY VARCHAR2,
      p_pe_rec                   IN       pe_rec_type := g_miss_pe_rec,
      p_loading_status           IN       VARCHAR2,
      x_loading_status           OUT NOCOPY VARCHAR2
   )
   IS
      l_api_name           CONSTANT VARCHAR2 (30) := 'chk_revenue_non_quota_pe';
      l_yes                         fnd_lookups.meaning%TYPE;
      l_no                          fnd_lookups.meaning%TYPE;
   BEGIN
/*   x_return_status := FND_API.G_RET_STS_SUCCESS;
   x_loading_status := p_loading_status;

   SELECT meaning INTO l_yes FROM fnd_lookups
     WHERE lookup_code = 'Y' AND lookup_type = 'YES_NO';
   SELECT meaning INTO l_no FROM fnd_lookups
     WHERE lookup_code = 'N' AND lookup_type = 'YES_NO';
   --+
   -- Validate Rule :
   --  target = 0, ITD Flag = N
   --+
   -- Check target = 0
   IF (p_pe_rec.target <> 0) THEN
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
  THEN
   FND_MESSAGE.SET_NAME ('CN' , 'CN_PE_TARGET_MUST_BE');
   FND_MESSAGE.SET_TOKEN ('OBJ_VALUE','= 0');
   FND_MESSAGE.SET_TOKEN ('PLAN_TYPE',
        cn_api.get_lkup_meaning
        (p_pe_rec.quota_type_code,'QUOTA_TYPE'));
   FND_MESSAGE.SET_TOKEN ('TOKEN1',NULL);
   FND_MSG_PUB.Add;
      END IF;
      x_loading_status := 'CN_PE_TARGET_MUST_BE';
      RAISE FND_API.G_EXC_ERROR ;
   END IF;
   -- Check itd_flag  = N
   IF (p_pe_rec.itd_flag <> 'N') THEN
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
  THEN
   FND_MESSAGE.SET_NAME ('CN' , 'CN_ITD_FLAG_MUST_BE');
   FND_MESSAGE.SET_TOKEN ('OBJ_VALUE',l_no);
   FND_MESSAGE.SET_TOKEN ('PLAN_TYPE',
        cn_api.get_lkup_meaning
        (p_pe_rec.quota_type_code,'QUOTA_TYPE'));
   FND_MESSAGE.SET_TOKEN ('TOKEN1',NULL);
   FND_MSG_PUB.Add;
      END IF;
      x_loading_status := 'CN_ITD_FLAG_MUST_BE';
      RAISE FND_API.G_EXC_ERROR ;
   END IF;
   -- Check input for 'Group By' case (trx_group_code = 'GROUP')
   --+
   IF p_pe_rec.trx_group_code = 'GROUP' THEN
      --+
      -- Validate Rule : Groupby
      -- Cumulative Flag = N ,split flag = N ,
      -- Payment Amount
      --   NOT NULL : if payment type code = Payment amount %
      --   NULL : if payment type code = Fixed amount or applied Trx %
      --+
      -- Check Cumulative Flag = N
      IF (p_pe_rec.cumulative_flag <> 'N') THEN
   IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
     THEN
      FND_MESSAGE.SET_NAME ('CN' , 'CN_CUM_FLAG_MUST_BE');
      FND_MESSAGE.SET_TOKEN ('OBJ_VALUE',l_no);
      FND_MESSAGE.SET_TOKEN ('PLAN_TYPE',
           cn_api.get_lkup_meaning
           (p_pe_rec.quota_type_code,'QUOTA_TYPE'));
      FND_MESSAGE.SET_TOKEN ('TOKEN1', G_TRX_GROUP||' = '||
          cn_api.get_lkup_meaning
          (p_pe_rec.trx_group_code,'QUOTA_TRX_GROUP'));
      FND_MSG_PUB.Add;
   END IF;
   x_loading_status := 'CN_CUM_FLAG_MUST_BE';
   RAISE FND_API.G_EXC_ERROR ;
      END IF;
      -- Check split_flag = N
      IF (p_pe_rec.split_flag <> 'N') THEN
   IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
     THEN
      FND_MESSAGE.SET_NAME ('CN' , 'CN_SPLIT_FLAG_MUST_BE');
      FND_MESSAGE.SET_TOKEN ('OBJ_VALUE',l_no);
      FND_MESSAGE.SET_TOKEN ('PLAN_TYPE',
           cn_api.get_lkup_meaning
           (p_pe_rec.quota_type_code,'QUOTA_TYPE'));
      FND_MESSAGE.SET_TOKEN ('TOKEN1', G_TRX_GROUP||' = '||
           cn_api.get_lkup_meaning
          (p_pe_rec.trx_group_code,'QUOTA_TRX_GROUP'));
      FND_MESSAGE.SET_TOKEN ('TOKEN2',NULL);
      FND_MESSAGE.SET_TOKEN ('TOKEN3',NULL);
      FND_MSG_PUB.Add;
   END IF;
   x_loading_status := 'CN_SPLIT_FLAG_MUST_BE';
   RAISE FND_API.G_EXC_ERROR ;
      END IF;
      -- Check Payment Amount
      -- NOT NULL : if payment type code = Payment amount %
      -- NULL : if payment type code = Fixed amount or applied Trx %
      IF p_pe_rec.payment_type_code = 'PAYMENT' THEN
   IF (cn_api.pe_num_field_cannot_null
       ( p_num_field => p_pe_rec.payment_amount,
         p_pe_type   => p_pe_rec.quota_type_code,
         p_obj_name  => G_PAYMENT_AMOUT,
         p_token1    => G_TRX_GROUP||' = '||
                        cn_api.get_lkup_meaning
                        (p_pe_rec.trx_group_code,'QUOTA_TRX_GROUP'),
         p_token2    => G_PAYMENT_TYPE||' = '||
                        cn_api.get_lkup_meaning
                        (p_pe_rec.payment_type_code,
             'QUOTA_PAYMENT_TYPE'),
         p_token3    => NULL ,
         p_loading_status => x_loading_status,
         x_loading_status => x_loading_status) = FND_API.g_false)
     THEN
      RAISE FND_API.G_EXC_ERROR ;
   END IF;
       ELSIF p_pe_rec.payment_type_code IN ('TRANSACTION','FIXED') AND
   (cn_api.pe_num_field_must_null
    ( p_num_field => p_pe_rec.payment_amount,
      p_pe_type   => p_pe_rec.quota_type_code,
      p_obj_name  => G_PAYMENT_AMOUT,
      p_token1    => G_TRX_GROUP||' = '||
                     cn_api.get_lkup_meaning
                     (p_pe_rec.trx_group_code,'QUOTA_TRX_GROUP'),
      p_token2    => G_PAYMENT_TYPE||' = '||
                     cn_api.get_lkup_meaning
                     (p_pe_rec.payment_type_code,
          'QUOTA_PAYMENT_TYPE'),
      p_token3    => NULL ,
      p_loading_status => x_loading_status,
      x_loading_status => x_loading_status) = FND_API.g_false)
     THEN
   RAISE FND_API.G_EXC_ERROR ;
      END IF;
   END IF ;  -- end GROUP BY

   --+
   -- Check input for 'Individual' case (trx_group_code = 'INDIVIDUAL')
   --+
   IF p_pe_rec.trx_group_code = 'INDIVIDUAL' THEN
      IF  p_pe_rec.payment_type_code = 'TRANSACTION' THEN
   -- Check for Payment Type = Applied Trx % case
   --+
   -- Validate Rule :
   --   payment amount = NULL
   --   split flag = N if cumulative flag = N
   --+
   -- Check payment amount = NULL
   IF (cn_api.pe_num_field_must_null
       ( p_num_field => p_pe_rec.payment_amount,
         p_pe_type   => p_pe_rec.quota_type_code,
         p_obj_name  => G_PAYMENT_AMOUT,
         p_token1    => G_TRX_GROUP||' = '||
                        cn_api.get_lkup_meaning
                        (p_pe_rec.trx_group_code,'QUOTA_TRX_GROUP'),
         p_token2    => G_PAYMENT_TYPE||' = '||
                        cn_api.get_lkup_meaning
                        (p_pe_rec.payment_type_code,
             'QUOTA_PAYMENT_TYPE'),
         p_token3    => NULL ,
         p_loading_status => x_loading_status,
         x_loading_status => x_loading_status) = FND_API.g_false)
     THEN
      RAISE FND_API.G_EXC_ERROR ;
   END IF;
   -- Check split flag = N if cumulative flag = N
   IF (p_pe_rec.cumulative_flag = 'N') AND
     (p_pe_rec.split_flag <> 'N') THEN
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
         FND_MESSAGE.SET_NAME ('CN' , 'CN_SPLIT_FLAG_MUST_BE');
         FND_MESSAGE.SET_TOKEN ('OBJ_VALUE',l_no);
         FND_MESSAGE.SET_TOKEN ('PLAN_TYPE',
              cn_api.get_lkup_meaning
              (p_pe_rec.quota_type_code,'QUOTA_TYPE'));
         FND_MESSAGE.SET_TOKEN ('TOKEN1', G_TRX_GROUP||' = '||
              cn_api.get_lkup_meaning
              (p_pe_rec.trx_group_code,
               'QUOTA_TRX_GROUP'));
         FND_MESSAGE.SET_TOKEN ('TOKEN2', G_PAYMENT_TYPE||' = '||
              cn_api.get_lkup_meaning
              (p_pe_rec.payment_type_code,
               'QUOTA_PAYMENT_TYPE'));
         FND_MESSAGE.SET_TOKEN ('TOKEN3',G_ACCMULATE||' = '||
              p_pe_rec.cumulative_flag);
         FND_MSG_PUB.Add;
      END IF;
      x_loading_status := 'CN_SPLIT_FLAG_MUST_BE';
      RAISE FND_API.G_EXC_ERROR ;
   END IF;
       ELSIF  p_pe_rec.payment_type_code IN ('PAYMENT','FIXED') THEN
   -- Check for Payment Type = Payment Amount % or Fixed Amount case
   --+
   -- Validate Rule :
   --   split flag = N
   -- Payment Amount
   --   NOT NULL : if payment type code = Payment amount %
   --   NULL : if payment type code = Fixed amount
   --+
   -- Check split_flag = N
   IF (p_pe_rec.split_flag <> 'N') THEN
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
         FND_MESSAGE.SET_NAME ('CN' , 'CN_SPLIT_FLAG_MUST_BE');
         FND_MESSAGE.SET_TOKEN ('OBJ_VALUE',l_no);
         FND_MESSAGE.SET_TOKEN ('PLAN_TYPE',
              cn_api.get_lkup_meaning
              (p_pe_rec.quota_type_code,'QUOTA_TYPE'));
         FND_MESSAGE.SET_TOKEN ('TOKEN1', G_TRX_GROUP||' = '||
              cn_api.get_lkup_meaning
              (p_pe_rec.trx_group_code,
               'QUOTA_TRX_GROUP'));
         FND_MESSAGE.SET_TOKEN ('TOKEN2', G_PAYMENT_TYPE||' = '||
              cn_api.get_lkup_meaning
              (p_pe_rec.payment_type_code,
               'QUOTA_PAYMENT_TYPE'));
         FND_MESSAGE.SET_TOKEN ('TOKEN3',NULL);
         FND_MSG_PUB.Add;
      END IF;
      x_loading_status := 'CN_SPLIT_FLAG_MUST_BE';
      RAISE FND_API.G_EXC_ERROR ;
   END IF;
   -- Check Payment Amount
   -- NOT NULL : if payment type code = Payment amount %
   -- NULL : if payment type code = Fixed amount
   IF p_pe_rec.payment_type_code = 'PAYMENT' THEN
      IF (cn_api.pe_num_field_cannot_null
    ( p_num_field => p_pe_rec.payment_amount,
      p_pe_type   => p_pe_rec.quota_type_code,
      p_obj_name  => G_PAYMENT_AMOUT,
      p_token1    => G_TRX_GROUP||' = '||
                     cn_api.get_lkup_meaning
                     (p_pe_rec.trx_group_code,'QUOTA_TRX_GROUP'),
      p_token2    => G_PAYMENT_TYPE||' = '||
                     cn_api.get_lkup_meaning
                     (p_pe_rec.payment_type_code,
          'QUOTA_PAYMENT_TYPE'),
      p_token3    => NULL ,
      p_loading_status => x_loading_status,
      x_loading_status => x_loading_status) = FND_API.g_false)
        THEN
         RAISE FND_API.G_EXC_ERROR ;
      END IF;
    ELSIF p_pe_rec.payment_type_code = 'FIXED' AND
      (cn_api.pe_num_field_must_null
       ( p_num_field => p_pe_rec.payment_amount,
         p_pe_type   => p_pe_rec.quota_type_code,
         p_obj_name  => G_PAYMENT_AMOUT,
         p_token1    => G_TRX_GROUP||' = '||
                        cn_api.get_lkup_meaning
                        (p_pe_rec.trx_group_code,'QUOTA_TRX_GROUP'),
         p_token2    => G_PAYMENT_TYPE||' = '||
                        cn_api.get_lkup_meaning
                        (p_pe_rec.payment_type_code,
             'QUOTA_PAYMENT_TYPE'),
         p_token3    => NULL ,
         p_loading_status => x_loading_status,
         x_loading_status => x_loading_status) = FND_API.g_false)
      THEN
      RAISE FND_API.G_EXC_ERROR ;
   END IF;
      END IF ; -- end IF payment_type_code = TRANSACTION
   END IF ; -- end INDIVIDUAL

   -- Check rate table
   valid_rate_table
     ( x_return_status  => x_return_status,
       p_pe_rec         => p_pe_rec,
       p_loading_status => x_loading_status,
       x_loading_status => x_loading_status);
   IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE FND_API.G_EXC_ERROR ;
   END IF;
   -- Check discount rate table
   IF (p_pe_rec.disc_option_code IN ('PAYMENT','QUOTA')) THEN
      valid_disc_rate_table
  ( x_return_status  => x_return_status,
    p_pe_rec         => p_pe_rec,
    p_loading_status => x_loading_status,
    x_loading_status => x_loading_status);
      IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
   RAISE FND_API.G_EXC_ERROR ;
      END IF;
    ELSE
      -- Check  for  Discount Rate Table must be NULL
      IF (cn_api.pe_num_field_must_null
    ( p_num_field => p_pe_rec.disc_rate_table_id,
      p_pe_type   => p_pe_rec.quota_type_code,
      p_obj_name  => G_DISC_RATE_TB,
      p_token1    =>
      G_DISC_OPTION||' = '||
      cn_api.get_lkup_meaning
      (p_pe_rec.disc_option_code,'DISCOUNT_OPTION'),
      p_token2    => NULL ,
      p_token3    => NULL ,
      p_loading_status => x_loading_status,
      x_loading_status => x_loading_status) = FND_API.G_FALSE) THEN
   RAISE FND_API.G_EXC_ERROR ;
      END IF;
   END IF;
   -- Check rc
   valid_revenue_class
     ( x_return_status  => x_return_status,
       p_pe_rec         => p_pe_rec,
       p_loading_status => x_loading_status,
       x_loading_status => x_loading_status);
   IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE FND_API.G_EXC_ERROR ;
   END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      x_loading_status := 'UNEXPECTED_ERR';

   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      x_loading_status := 'UNEXPECTED_ERR';
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,l_api_name );
      END IF;
*/
      fnd_message.set_name ('CN', 'CN_PACKAGE_OBSELETE');
      fnd_msg_pub.ADD;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      x_loading_status := 'CN_PACKAGE_OBSELETE';
      RAISE fnd_api.g_exc_error;
   END chk_revenue_non_quota_pe;

-- ----------------------------------------------------------------------------+
-- Procedure: chk_unit_non_quota_pe
-- Desc     : Check input for  UNIT NONE QUOTA type plan element
-- ----------------------------------------------------------------------------+
   PROCEDURE chk_unit_non_quota_pe (
      x_return_status            OUT NOCOPY VARCHAR2,
      p_pe_rec                   IN       pe_rec_type := g_miss_pe_rec,
      p_loading_status           IN       VARCHAR2,
      x_loading_status           OUT NOCOPY VARCHAR2
   )
   IS
      l_api_name           CONSTANT VARCHAR2 (30) := 'chk_unit_non_quota_pe';
      l_yes                         fnd_lookups.meaning%TYPE;
      l_no                          fnd_lookups.meaning%TYPE;
   BEGIN
/*   x_return_status := FND_API.G_RET_STS_SUCCESS;
   x_loading_status := p_loading_status;

   SELECT meaning INTO l_yes FROM fnd_lookups
     WHERE lookup_code = 'Y' AND lookup_type = 'YES_NO';
   SELECT meaning INTO l_no FROM fnd_lookups
     WHERE lookup_code = 'N' AND lookup_type = 'YES_NO';
   --+
   -- Validate Rule :
   --  target = 0, ITD Flag = N
   --+
   -- Check target = 0
   IF (p_pe_rec.target <> 0) THEN
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
  THEN
   FND_MESSAGE.SET_NAME ('CN' , 'CN_PE_TARGET_MUST_BE');
   FND_MESSAGE.SET_TOKEN ('OBJ_VALUE','= 0');
   FND_MESSAGE.SET_TOKEN ('PLAN_TYPE',
        cn_api.get_lkup_meaning
        (p_pe_rec.quota_type_code,'QUOTA_TYPE'));
   FND_MESSAGE.SET_TOKEN ('TOKEN1',NULL);
   FND_MSG_PUB.Add;
      END IF;
      x_loading_status := 'CN_PE_TARGET_MUST_BE';
      RAISE FND_API.G_EXC_ERROR ;
   END IF;
   -- Check itd_flag  = N
   IF (p_pe_rec.itd_flag <> 'N') THEN
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
  THEN
   FND_MESSAGE.SET_NAME ('CN' , 'CN_ITD_FLAG_MUST_BE');
   FND_MESSAGE.SET_TOKEN ('OBJ_VALUE',l_no);
   FND_MESSAGE.SET_TOKEN ('PLAN_TYPE',
        cn_api.get_lkup_meaning
        (p_pe_rec.quota_type_code,'QUOTA_TYPE'));
   FND_MESSAGE.SET_TOKEN ('TOKEN1',NULL);
   FND_MSG_PUB.Add;
      END IF;
      x_loading_status := 'CN_ITD_FLAG_MUST_BE';
      RAISE FND_API.G_EXC_ERROR ;
   END IF;
   -- Check input for 'Group By' case (trx_group_code = 'GROUP')
   --+
   IF p_pe_rec.trx_group_code = 'GROUP' THEN
      --+
      -- Validate Rule : Groupby
      -- Cumulative Flag = N ,split flag = N ,
      -- Payment Amount
      --   NOT NULL : if payment type code = Payment amount %
      --   NULL : if payment type code = Fixed amount or applied Trx %
      --+
      -- Check Cumulative Flag = N
      IF (p_pe_rec.cumulative_flag <> 'N') THEN
   IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
     THEN
      FND_MESSAGE.SET_NAME ('CN' , 'CN_CUM_FLAG_MUST_BE');
      FND_MESSAGE.SET_TOKEN ('OBJ_VALUE',l_no);
      FND_MESSAGE.SET_TOKEN ('PLAN_TYPE',
           cn_api.get_lkup_meaning
           (p_pe_rec.quota_type_code,'QUOTA_TYPE'));
      FND_MESSAGE.SET_TOKEN ('TOKEN1', G_TRX_GROUP||' = '||
           cn_api.get_lkup_meaning
           (p_pe_rec.trx_group_code,'QUOTA_TRX_GROUP'))
        ;
      FND_MSG_PUB.Add;
   END IF;
   x_loading_status := 'CN_CUM_FLAG_MUST_BE';
   RAISE FND_API.G_EXC_ERROR ;
      END IF;
      -- Check split_flag = N
      IF (p_pe_rec.split_flag <> 'N') THEN
   IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
     THEN
      FND_MESSAGE.SET_NAME ('CN' , 'CN_SPLIT_FLAG_MUST_BE');
      FND_MESSAGE.SET_TOKEN ('OBJ_VALUE',l_no);
      FND_MESSAGE.SET_TOKEN ('PLAN_TYPE',
           cn_api.get_lkup_meaning
           (p_pe_rec.quota_type_code,'QUOTA_TYPE'));
      FND_MESSAGE.SET_TOKEN ('TOKEN1', G_TRX_GROUP||' = '||
           cn_api.get_lkup_meaning
           (p_pe_rec.trx_group_code,'QUOTA_TRX_GROUP'))
        ;
      FND_MESSAGE.SET_TOKEN ('TOKEN2',NULL);
      FND_MESSAGE.SET_TOKEN ('TOKEN3',NULL);
      FND_MSG_PUB.Add;
   END IF;
   x_loading_status := 'CN_SPLIT_FLAG_MUST_BE';
   RAISE FND_API.G_EXC_ERROR ;
      END IF;
      -- Check Payment Amount
      -- NOT NULL : if payment type code = Payment amount %
      -- NULL : if payment type code = Fixed amount or applied Trx %
      IF p_pe_rec.payment_type_code = 'PAYMENT' THEN
   IF (cn_api.pe_num_field_cannot_null
       ( p_num_field => p_pe_rec.payment_amount,
         p_pe_type   => p_pe_rec.quota_type_code,
         p_obj_name  => G_PAYMENT_AMOUT,
         p_token1    => G_TRX_GROUP||' = '||
                        cn_api.get_lkup_meaning
                        (p_pe_rec.trx_group_code,'QUOTA_TRX_GROUP'),
         p_token2    => G_PAYMENT_TYPE||' = '||
                        cn_api.get_lkup_meaning
                       (p_pe_rec.payment_type_code,
            'QUOTA_PAYMENT_TYPE'),
         p_token3    => NULL ,
         p_loading_status => x_loading_status,
         x_loading_status => x_loading_status) = FND_API.g_false)
     THEN
      RAISE FND_API.G_EXC_ERROR ;
   END IF;
       ELSIF p_pe_rec.payment_type_code IN ('TRANSACTION','FIXED') AND
   (cn_api.pe_num_field_must_null
    ( p_num_field => p_pe_rec.payment_amount,
      p_pe_type   => p_pe_rec.quota_type_code,
      p_obj_name  => G_PAYMENT_AMOUT,
      p_token1    => G_TRX_GROUP||' = '||
                     cn_api.get_lkup_meaning
                     (p_pe_rec.trx_group_code,'QUOTA_TRX_GROUP'),
      p_token2    => G_PAYMENT_TYPE||' = '||
                     cn_api.get_lkup_meaning
                     (p_pe_rec.payment_type_code,
          'QUOTA_PAYMENT_TYPE'),
      p_token3    => NULL ,
      p_loading_status => x_loading_status,
      x_loading_status => x_loading_status) = FND_API.g_false)
     THEN
   RAISE FND_API.G_EXC_ERROR ;
      END IF;
   END IF ;  -- end GROUP BY

   --+
   -- Check input for 'Individual' case (trx_group_code = 'INDIVIDUAL')
   --+
   IF p_pe_rec.trx_group_code = 'INDIVIDUAL' THEN
      IF  p_pe_rec.payment_type_code = 'TRANSACTION' THEN
   -- Check for Payment Type = Applied Trx % case
   --+
   -- Validate Rule :
   --   payment amount = NULL
   --   split flag = N if cumulative flag = N
   --+
   -- Check payment amount = NULL
   IF (cn_api.pe_num_field_must_null
       ( p_num_field => p_pe_rec.payment_amount,
         p_pe_type   => p_pe_rec.quota_type_code,
         p_obj_name  => G_PAYMENT_AMOUT,
         p_token1    => G_TRX_GROUP||' = '||
                        cn_api.get_lkup_meaning
                        (p_pe_rec.trx_group_code,'QUOTA_TRX_GROUP'),
         p_token2    => G_PAYMENT_TYPE||' = '||
                        cn_api.get_lkup_meaning
                        (p_pe_rec.payment_type_code,
             'QUOTA_PAYMENT_TYPE'),
         p_token3    => NULL ,
         p_loading_status => x_loading_status,
         x_loading_status => x_loading_status) = FND_API.g_false)
     THEN
      RAISE FND_API.G_EXC_ERROR ;
   END IF;
   -- Check split flag = N if cumulative flag = N
   IF (p_pe_rec.cumulative_flag = 'N') AND
     (p_pe_rec.split_flag <> 'N') THEN
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
         FND_MESSAGE.SET_NAME ('CN' , 'CN_SPLIT_FLAG_MUST_BE');
         FND_MESSAGE.SET_TOKEN ('OBJ_VALUE',l_no);
         FND_MESSAGE.SET_TOKEN ('PLAN_TYPE',
              cn_api.get_lkup_meaning
              (p_pe_rec.quota_type_code,'QUOTA_TYPE'));
         FND_MESSAGE.SET_TOKEN ('TOKEN1', G_TRX_GROUP||' = '||
              cn_api.get_lkup_meaning
              (p_pe_rec.trx_group_code,
               'QUOTA_TRX_GROUP'));
         FND_MESSAGE.SET_TOKEN ('TOKEN2', G_PAYMENT_TYPE||' = '||
              cn_api.get_lkup_meaning
              (p_pe_rec.payment_type_code,
               'QUOTA_PAYMENT_TYPE'));
         FND_MESSAGE.SET_TOKEN ('TOKEN3', G_ACCMULATE||' = '||
              p_pe_rec.cumulative_flag);
         FND_MSG_PUB.Add;
      END IF;
      x_loading_status := 'CN_SPLIT_FLAG_MUST_BE';
      RAISE FND_API.G_EXC_ERROR ;
   END IF;
       ELSIF  p_pe_rec.payment_type_code IN ('PAYMENT','FIXED') THEN
   -- Check for Payment Type = Payment Amount % or Fixed Amount case
   --+
   -- Validate Rule :
   --   split flag = N
   -- Payment Amount
   --   NOT NULL : if payment type code = Payment amount %
   --   NULL : if payment type code = Fixed amount
   --+
   -- Check split_flag = N
   IF (p_pe_rec.split_flag <> 'N') THEN
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
         FND_MESSAGE.SET_NAME ('CN' , 'CN_SPLIT_FLAG_MUST_BE');
         FND_MESSAGE.SET_TOKEN ('OBJ_VALUE',l_no);
         FND_MESSAGE.SET_TOKEN ('PLAN_TYPE',
              cn_api.get_lkup_meaning
              (p_pe_rec.quota_type_code,'QUOTA_TYPE'));
         FND_MESSAGE.SET_TOKEN ('TOKEN1', G_TRX_GROUP||' = '||
              cn_api.get_lkup_meaning
              (p_pe_rec.trx_group_code,
               'QUOTA_TRX_GROUP'));
         FND_MESSAGE.SET_TOKEN ('TOKEN2',G_PAYMENT_TYPE||' = '||
              cn_api.get_lkup_meaning
              (p_pe_rec.payment_type_code,
               'QUOTA_PAYMENT_TYPE'));
         FND_MESSAGE.SET_TOKEN ('TOKEN3',NULL);
         FND_MSG_PUB.Add;
      END IF;
      x_loading_status := 'CN_SPLIT_FLAG_MUST_BE';
      RAISE FND_API.G_EXC_ERROR ;
   END IF;
   -- Check Payment Amount
   -- NOT NULL : if payment type code = Payment amount %
   -- NULL : if payment type code = Fixed amount
   IF p_pe_rec.payment_type_code = 'PAYMENT' THEN
      IF (cn_api.pe_num_field_cannot_null
    ( p_num_field => p_pe_rec.payment_amount,
      p_pe_type   => p_pe_rec.quota_type_code,
      p_obj_name  => G_PAYMENT_AMOUT,
      p_token1    => G_TRX_GROUP||' = '||
                     cn_api.get_lkup_meaning
                     (p_pe_rec.trx_group_code,'QUOTA_TRX_GROUP'),
      p_token2    => G_PAYMENT_TYPE||' = '||
                     cn_api.get_lkup_meaning
                     (p_pe_rec.payment_type_code,
          'QUOTA_PAYMENT_TYPE'),
      p_token3    => NULL ,
      p_loading_status => x_loading_status,
      x_loading_status => x_loading_status) = FND_API.g_false)
        THEN
         RAISE FND_API.G_EXC_ERROR ;
      END IF;
    ELSIF p_pe_rec.payment_type_code = 'FIXED' AND
      (cn_api.pe_num_field_must_null
       ( p_num_field => p_pe_rec.payment_amount,
         p_pe_type   => p_pe_rec.quota_type_code,
         p_obj_name  => G_PAYMENT_AMOUT,
         p_token1    => G_TRX_GROUP||' = '||
                        cn_api.get_lkup_meaning
                        (p_pe_rec.trx_group_code,'QUOTA_TRX_GROUP'),
         p_token2    => G_PAYMENT_TYPE||' = '||
                        cn_api.get_lkup_meaning
                        (p_pe_rec.payment_type_code,
             'QUOTA_PAYMENT_TYPE'),
         p_token3    => NULL ,
         p_loading_status => x_loading_status,
         x_loading_status => x_loading_status) = FND_API.g_false)
      THEN
      RAISE FND_API.G_EXC_ERROR ;
   END IF;
      END IF ; -- end IF payment_type_code = TRANSACTION
   END IF ; -- end INDIVIDUAL

   -- Check rate table
   valid_rate_table
     ( x_return_status  => x_return_status,
       p_pe_rec         => p_pe_rec,
       p_loading_status => x_loading_status,
       x_loading_status => x_loading_status);
   IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE FND_API.G_EXC_ERROR ;
   END IF;
   -- Check discount rate table = Not Allowed
   -- Discount Option Code must = NONE is validate when calling
   -- valid_lookup_code() from valid_plan_element
   IF (cn_api.pe_num_field_must_null
       ( p_num_field => p_pe_rec.disc_rate_table_id,
   p_pe_type   => p_pe_rec.quota_type_code,
   p_obj_name  => G_DISC_RATE_TB,
   p_token1    => NULL ,
   p_token2    => NULL ,
   p_token3    => NULL ,
   p_loading_status => x_loading_status,
   x_loading_status => x_loading_status) = FND_API.g_false)
      THEN
      RAISE FND_API.G_EXC_ERROR ;
   END IF;
   -- Check rc
   valid_revenue_class
     ( x_return_status  => x_return_status,
       p_pe_rec         => p_pe_rec,
       p_loading_status => x_loading_status,
       x_loading_status => x_loading_status);
   IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE FND_API.G_EXC_ERROR ;
   END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      x_loading_status := 'UNEXPECTED_ERR';

   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      x_loading_status := 'UNEXPECTED_ERR';
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,l_api_name );
      END IF;
*/
      fnd_message.set_name ('CN', 'CN_PACKAGE_OBSELETE');
      fnd_msg_pub.ADD;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      x_loading_status := 'CN_PACKAGE_OBSELETE';
      RAISE fnd_api.g_exc_error;
   END chk_unit_non_quota_pe;

-- ----------------------------------------------------------------------------+
-- Procedure: chk_discount_margin_pe
-- Desc     : Check input for  DISCOUNT or MARGIN type plan element
-- ----------------------------------------------------------------------------+
   PROCEDURE chk_discount_margin_pe (
      x_return_status            OUT NOCOPY VARCHAR2,
      p_pe_rec                   IN       pe_rec_type := g_miss_pe_rec,
      p_loading_status           IN       VARCHAR2,
      x_loading_status           OUT NOCOPY VARCHAR2
   )
   IS
      l_api_name           CONSTANT VARCHAR2 (30) := 'chk_disc_margin_pe';
      l_yes                         fnd_lookups.meaning%TYPE;
      l_no                          fnd_lookups.meaning%TYPE;
   BEGIN
/*   x_return_status := FND_API.G_RET_STS_SUCCESS;
   x_loading_status := p_loading_status;

   SELECT meaning INTO l_yes FROM fnd_lookups
     WHERE lookup_code = 'Y' AND lookup_type = 'YES_NO';
   SELECT meaning INTO l_no FROM fnd_lookups
     WHERE lookup_code = 'N' AND lookup_type = 'YES_NO';
   --+
   -- Validate Rule :
   --   target = 0
   --   split_flag = N, cumulative_flag = N , itd_flag = N
   --   Apply Txn Type = 'GroupBy' NOT ALLOWED
   -- Payment Amount
   --   NOT NULL : if payment type code = Payment amount %
   --   NULL : if payment type code = Fixed amount or applied Trx %
   --+
   -- Check target = 0
   IF (p_pe_rec.target <> 0) THEN
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
  THEN
   FND_MESSAGE.SET_NAME ('CN' , 'CN_PE_TARGET_MUST_BE');
   FND_MESSAGE.SET_TOKEN ('OBJ_VALUE','= 0');
   FND_MESSAGE.SET_TOKEN ('PLAN_TYPE',
        cn_api.get_lkup_meaning
        (p_pe_rec.quota_type_code,'QUOTA_TYPE'));
   FND_MESSAGE.SET_TOKEN ('TOKEN1',NULL);
   FND_MSG_PUB.Add;
      END IF;
      x_loading_status := 'CN_PE_TARGET_MUST_BE';
      RAISE FND_API.G_EXC_ERROR ;
   END IF;
   -- Check split_flag = N
   IF (p_pe_rec.split_flag <> 'N') THEN
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
  THEN
   FND_MESSAGE.SET_NAME ('CN' , 'CN_SPLIT_FLAG_MUST_BE');
   FND_MESSAGE.SET_TOKEN ('OBJ_VALUE',l_no);
   FND_MESSAGE.SET_TOKEN ('PLAN_TYPE',
        cn_api.get_lkup_meaning
        (p_pe_rec.quota_type_code,'QUOTA_TYPE'));
   FND_MESSAGE.SET_TOKEN ('TOKEN1',NULL);
   FND_MESSAGE.SET_TOKEN ('TOKEN2',NULL);
   FND_MESSAGE.SET_TOKEN ('TOKEN3',NULL);
   FND_MSG_PUB.Add;
      END IF;
      x_loading_status := 'CN_SPLIT_FLAG_MUST_BE';
      RAISE FND_API.G_EXC_ERROR ;
   END IF;
   -- Check cumulative_flag = N for Discount and Margin PE type
   IF (p_pe_rec.cumulative_flag <> 'N') THEN
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
  THEN
   FND_MESSAGE.SET_NAME ('CN' , 'CN_CUM_FLAG_MUST_BE');
   FND_MESSAGE.SET_TOKEN ('OBJ_VALUE',l_no);
   FND_MESSAGE.SET_TOKEN ('PLAN_TYPE',
        cn_api.get_lkup_meaning
        (p_pe_rec.quota_type_code,'QUOTA_TYPE'));
   FND_MESSAGE.SET_TOKEN ('TOKEN1',NULL);
   FND_MSG_PUB.Add;
      END IF;
      x_loading_status := 'CN_CUM_FLAG_MUST_BE';
      RAISE FND_API.G_EXC_ERROR ;
   END IF;
   -- Check itd_flag = N for Discount and Margin PE type
   IF (p_pe_rec.itd_flag <> 'N') THEN
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
  THEN
   FND_MESSAGE.SET_NAME ('CN' , 'CN_ITD_FLAG_MUST_BE');
   FND_MESSAGE.SET_TOKEN ('OBJ_VALUE',l_no);
   FND_MESSAGE.SET_TOKEN ('PLAN_TYPE',
        cn_api.get_lkup_meaning
        (p_pe_rec.quota_type_code,'QUOTA_TYPE'));
   FND_MESSAGE.SET_TOKEN ('TOKEN1',NULL);
   FND_MSG_PUB.Add;
      END IF;
      x_loading_status := 'CN_ITD_FLAG_MUST_BE';
      RAISE FND_API.G_EXC_ERROR ;
   END IF;
   -- Check Apply Txn Type = 'GroupBy' NOT ALLOWED
   IF p_pe_rec.trx_group_code = 'GROUP' THEN
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
  THEN
   FND_MESSAGE.SET_NAME ('CN' , 'DISC_MARGIN_INDIVIDUAL_ONLY');
   FND_MSG_PUB.Add;
      END IF;
      x_loading_status := 'DISC_MARGIN_INDIVIDUAL_ONLY';
      RAISE FND_API.G_EXC_ERROR ;
   END IF;
   -- Check Payment Amount
   --   NOT NULL : if payment type code = Payment amount %
   --   NULL : if payment type code = Fixed amount or applied Trx %
   IF p_pe_rec.payment_type_code = 'PAYMENT' THEN
      IF (cn_api.pe_num_field_cannot_null
    ( p_num_field => p_pe_rec.payment_amount,
      p_pe_type   => p_pe_rec.quota_type_code,
      p_obj_name  => G_PAYMENT_AMOUT,
      p_token1    => G_TRX_GROUP||' = '||
                     cn_api.get_lkup_meaning
                     (p_pe_rec.trx_group_code,'QUOTA_TRX_GROUP'),
      p_token2    => G_PAYMENT_TYPE||' = '||
                     cn_api.get_lkup_meaning
                     (p_pe_rec.payment_type_code,
          'QUOTA_PAYMENT_TYPE'),
      p_token3    => NULL ,
      p_loading_status => x_loading_status,
      x_loading_status => x_loading_status) = FND_API.g_false)
  THEN
   RAISE FND_API.G_EXC_ERROR ;
      END IF;
    ELSIF p_pe_rec.payment_type_code IN ('TRANSACTION','FIXED') AND
      (cn_api.pe_num_field_must_null
       ( p_num_field => p_pe_rec.payment_amount,
   p_pe_type   => p_pe_rec.quota_type_code,
   p_obj_name  => G_PAYMENT_AMOUT,
   p_token1    => G_TRX_GROUP||' = '||
                  cn_api.get_lkup_meaning
                  (p_pe_rec.trx_group_code,'QUOTA_TRX_GROUP'),
   p_token2    => G_PAYMENT_TYPE||' = '||
                  cn_api.get_lkup_meaning
                  (p_pe_rec.payment_type_code,
       'QUOTA_PAYMENT_TYPE'),
   p_token3    => NULL ,
   p_loading_status => x_loading_status,
   x_loading_status => x_loading_status) = FND_API.g_false)
      THEN
      RAISE FND_API.G_EXC_ERROR ;
   END IF;
   -- Check rate table
   valid_rate_table
     ( x_return_status  => x_return_status,
       p_pe_rec         => p_pe_rec,
       p_loading_status => x_loading_status,
       x_loading_status => x_loading_status);
   IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE FND_API.G_EXC_ERROR ;
   END IF;
   -- Check discount rate table = Not Allowed
   IF (cn_api.pe_num_field_must_null
       ( p_num_field => p_pe_rec.disc_rate_table_id,
   p_pe_type   => p_pe_rec.quota_type_code,
   p_obj_name  => G_DISC_RATE_TB,
   p_token1    => NULL ,
   p_token2    => NULL ,
   p_token3    => NULL ,
   p_loading_status => x_loading_status,
   x_loading_status => x_loading_status) = FND_API.g_false)
      THEN
      RAISE FND_API.G_EXC_ERROR ;
   END IF;

   -- Check rc
   valid_revenue_class
     ( x_return_status  => x_return_status,
       p_pe_rec         => p_pe_rec,
       p_loading_status => x_loading_status,
       x_loading_status => x_loading_status);
   IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE FND_API.G_EXC_ERROR ;
   END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      x_loading_status := 'UNEXPECTED_ERR';

   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      x_loading_status := 'UNEXPECTED_ERR';
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,l_api_name );
      END IF;
*/
      fnd_message.set_name ('CN', 'CN_PACKAGE_OBSELETE');
      fnd_msg_pub.ADD;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      x_loading_status := 'CN_PACKAGE_OBSELETE';
      RAISE fnd_api.g_exc_error;
   END chk_discount_margin_pe;

-- ----------------------------------------------------------------------------+
-- Procedure: chk_trx_factor
-- Desc     : Check Trx Factors
--   Error when
--   1. No factors assigned
--   2. key factors don't total to 100% (Warning)
-- ----------------------------------------------------------------------------+
   PROCEDURE chk_trx_factor (
      x_return_status            OUT NOCOPY VARCHAR2,
      p_quota_rule_id                     NUMBER,
      p_rev_class_name                    VARCHAR2,
      p_loading_status           IN       VARCHAR2,
      x_loading_status           OUT NOCOPY VARCHAR2
   )
   IS
      CURSOR c_factors
      IS
         SELECT event_factor,
                trx_type
           FROM cn_trx_factors
          WHERE quota_rule_id = p_quota_rule_id;

      l_factor_csr                  c_factors%ROWTYPE;
      key_factor_total              NUMBER;
      l_api_name           CONSTANT VARCHAR2 (30) := 'chk_trx_factor';
      l_pe_name                     cn_quotas.NAME%TYPE;
   BEGIN
      x_return_status := fnd_api.g_ret_sts_success;
      x_loading_status := p_loading_status;
      key_factor_total := 0;

      OPEN c_factors;

      LOOP
         FETCH c_factors
          INTO l_factor_csr;

         IF c_factors%ROWCOUNT = 0
         THEN
            IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
            THEN
               fnd_message.set_name ('CN', 'PLN_QUOTA_RULE_NO_FACTORS');
               fnd_message.set_token ('REV_CLASS_NAME', p_rev_class_name);
               fnd_msg_pub.ADD;
            END IF;

            x_loading_status := 'PLN_QUOTA_RULE_NO_FACTORS';
            RAISE fnd_api.g_exc_error;
         ELSE
            IF c_factors%NOTFOUND
            THEN
               IF key_factor_total <> 100
               THEN
                  -- Warning message only.
                  IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
                  THEN
                     SELECT q.NAME
                       INTO l_pe_name
                       FROM cn_quotas q,
                            cn_quota_rules qr
                      WHERE qr.quota_rule_id = p_quota_rule_id AND q.quota_id = qr.quota_id;

                     fnd_message.set_name ('CN', 'PLN_QUOTA_RULE_FACTORS_NOT_100');
                     fnd_message.set_token ('PLAN_NAME', NULL);
                     fnd_message.set_token ('QUOTA_NAME', l_pe_name);
                     fnd_message.set_token ('REV_CLASS_NAME', p_rev_class_name);
                     fnd_msg_pub.ADD;
                     RAISE fnd_api.g_exc_error;
                  END IF;

                  x_loading_status := 'PLN_QUOTA_RULE_FACTORS_NOT_100';
                  GOTO end_loop;
               END IF;

               EXIT;                                                                                                                      -- exit loop
            ELSE
               IF (l_factor_csr.trx_type = 'ORD' OR l_factor_csr.trx_type = 'INV' OR l_factor_csr.trx_type = 'PMT')
               THEN
                  key_factor_total := key_factor_total + l_factor_csr.event_factor;

               END IF;
            END IF;                                                                                                                     -- sqlnotfound
         END IF;                                                                                                                           -- rowcount
      END LOOP;

      <<end_loop>>
      NULL;


      CLOSE c_factors;
   END chk_trx_factor;

--| -----------------------------------------------------------------------+
--|   Function Name : Get_Quota_id
--| ---------------------------------------------------------------------+
   FUNCTION get_quota_id (
      p_quota_name                        VARCHAR2,
      p_org_id NUMBER
   )
      RETURN cn_quotas.quota_id%TYPE
   IS
      l_quota_id                    cn_quotas.quota_id%TYPE;
   BEGIN
      SELECT quota_id
        INTO l_quota_id
        FROM cn_quotas_v
       WHERE NAME = p_quota_name
       AND   org_id = p_org_id ;

      RETURN l_quota_id;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         RETURN NULL;
   END get_quota_id;

--| -----------------------------------------------------------------------+
--|   Function Name : Get_calc_formula_name
--| ---------------------------------------------------------------------+
   FUNCTION get_calc_formula_name (
      p_calc_formula_id                   NUMBER
   )
      RETURN cn_calc_formulas.NAME%TYPE
   IS
      l_cf_name                     cn_calc_formulas.NAME%TYPE;
   BEGIN
      SELECT NAME
        INTO l_cf_name
        FROM cn_calc_formulas
       WHERE calc_formula_id = p_calc_formula_id;

      RETURN l_cf_name;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         RETURN NULL;
   END get_calc_formula_name;

--| -----------------------------------------------------------------------+
--|   Function Name : Get_calc_formula_name
--| ---------------------------------------------------------------------+
   FUNCTION get_calc_formula_id (
      p_calc_formula_name                 VARCHAR2,
      p_org_id														NUMBER
   )
      RETURN cn_calc_formulas.calc_formula_id%TYPE
   IS
      l_cf_id                       cn_calc_formulas.calc_formula_id%TYPE;
   BEGIN
      SELECT calc_formula_id
        INTO l_cf_id
        FROM cn_calc_formulas
       WHERE NAME = p_calc_formula_name and org_id = p_org_id;

      RETURN l_cf_id;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         RETURN NULL;
   END get_calc_formula_id;

--| -----------------------------------------------------------------------+
--|   Function Name : Get_Credit_Type
--| ---------------------------------------------------------------------+
   FUNCTION get_credit_type (
      p_credit_type_id                    NUMBER
   )
      RETURN cn_credit_types.NAME%TYPE
   IS
      l_c_type                      cn_credit_types.NAME%TYPE;
   BEGIN
      SELECT NAME
        INTO l_c_type
        FROM cn_credit_types
       WHERE credit_type_id = p_credit_type_id;

      RETURN l_c_type;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         RETURN NULL;
   END get_credit_type;

--| -----------------------------------------------------------------------+
--| Function Name :  get_interval_name
--| Desc : To Get the Interval Name  using the Interval  Type ID
--| ---------------------------------------------------------------------+
   FUNCTION get_interval_name (
      p_interval_type_id                  NUMBER,
      p_org_id														NUMBER
   )
      RETURN cn_interval_types.NAME%TYPE
   IS
      l_name                        cn_interval_types.NAME%TYPE;
   BEGIN
      SELECT NAME
        INTO l_name
        FROM cn_interval_types
       WHERE interval_type_id = p_interval_type_id
       AND org_id = p_org_id;

      RETURN l_name;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         RETURN NULL;
   END get_interval_name;

--| -----------------------------------------------------------------------+
--| Function Name :  get_quota_rule_id
--| Desc : Get the Quota Rule ID  using the quota_id, Revenue_class_id
--| ---------------------------------------------------------------------+
   FUNCTION get_quota_rule_id (
      p_quota_id                          NUMBER,
      p_rev_class_id                      NUMBER
   )
      RETURN cn_quota_rules.quota_rule_id%TYPE
   IS
      l_quota_rule_id               cn_quota_rules.quota_rule_id%TYPE;
   BEGIN
      SELECT quota_rule_id
        INTO l_quota_rule_id
        FROM cn_quota_rules
       WHERE quota_id = p_quota_id AND revenue_class_id = p_rev_class_id;

      RETURN l_quota_rule_id;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         RETURN NULL;
   END get_quota_rule_id;

--| -----------------------------------------------------------------------+
--| Function Name :  get_uplift_start_date
--| Desc : Get theuplift start Date using quota id, quota Rule ID
--| ---------------------------------------------------------------------+
   FUNCTION get_uplift_start_date (
      p_quota_rule_id                     NUMBER
   )
      RETURN cn_quota_rule_uplifts.start_date%TYPE
   IS
      l_start_date                  cn_quota_rule_uplifts.start_date%TYPE;

      CURSOR get_date
      IS
         SELECT   end_date + 1
             FROM cn_quota_rule_uplifts
            WHERE quota_rule_id = p_quota_rule_id
         ORDER BY end_date DESC;
   BEGIN
      OPEN get_date;

      FETCH get_date
       INTO l_start_date;

      CLOSE get_date;

      RETURN l_start_date;
   END get_uplift_start_date;

--| -----------------------------------------------------------------------+
--| Function Name :  get_quota_rule_uplift_id
--| Desc : Get the Quota Rule UPLIFT ID  using the quota_rule_id,
-- start Date, end Date
--| ---------------------------------------------------------------------+
   FUNCTION get_quota_rule_uplift_id (
      p_quota_rule_id                     NUMBER,
      p_start_date                        DATE,
      p_end_date                          DATE
   )
      RETURN cn_quota_rule_uplifts.quota_rule_uplift_id%TYPE
   IS
      l_quota_rule_uplift_id        cn_quota_rule_uplifts.quota_rule_uplift_id%TYPE;

      CURSOR get_quota_rule_uplift_id_curs
      IS
         SELECT quota_rule_uplift_id
           FROM cn_quota_rule_uplifts
          WHERE quota_rule_id = p_quota_rule_id AND TRUNC (start_date) = TRUNC (p_start_date) AND TRUNC (end_date) = TRUNC (p_end_date);

      CURSOR get_quota_rule_uplift_id_curs1
      IS
         SELECT quota_rule_uplift_id
           FROM cn_quota_rule_uplifts
          WHERE quota_rule_id = p_quota_rule_id AND TRUNC (start_date) = TRUNC (p_start_date) AND TRUNC (end_date) IS NULL;
   BEGIN
      IF p_end_date IS NOT NULL
      THEN
         OPEN get_quota_rule_uplift_id_curs;

         FETCH get_quota_rule_uplift_id_curs
          INTO l_quota_rule_uplift_id;

         CLOSE get_quota_rule_uplift_id_curs;
      ELSE
         OPEN get_quota_rule_uplift_id_curs1;

         FETCH get_quota_rule_uplift_id_curs1
          INTO l_quota_rule_uplift_id;

         CLOSE get_quota_rule_uplift_id_curs1;
      END IF;

      RETURN l_quota_rule_uplift_id;
   END get_quota_rule_uplift_id;

--| -----------------------------------------------------------------------+
--| Function Name :  get_rt_quota_asgn_id
--| Desc : Get the rt Quota Asgn ID  using the quota_id,
--| start Date, end Date
--| ---------------------------------------------------------------------+
   FUNCTION get_rt_quota_asgn_id (
      p_quota_id                          NUMBER,
      p_rate_schedule_id                  NUMBER,
      p_calc_formula_id                   NUMBER,
      p_start_date                        DATE,
      p_end_date                          DATE
   )
      RETURN cn_rt_quota_asgns.rt_quota_asgn_id%TYPE
   IS
      l_rt_quota_asgn_id            cn_rt_quota_asgns.rt_quota_asgn_id%TYPE;

      CURSOR get_rt_quota_asgn_id_curs
      IS
         SELECT rt_quota_asgn_id
           FROM cn_rt_quota_asgns
          WHERE quota_id = p_quota_id
            AND rate_schedule_id = p_rate_schedule_id
            AND calc_formula_id = p_calc_formula_id
            AND TRUNC (start_date) = TRUNC (p_start_date)
            AND TRUNC (end_date) = TRUNC (p_end_date);

      CURSOR get_rt_quota_asgn_id_curs1
      IS
         SELECT rt_quota_asgn_id
           FROM cn_rt_quota_asgns
          WHERE quota_id = p_quota_id
            AND rate_schedule_id = p_rate_schedule_id
            AND calc_formula_id = p_calc_formula_id
            AND TRUNC (start_date) = TRUNC (p_start_date)
            AND TRUNC (end_date) IS NULL;
   BEGIN
      IF p_end_date IS NOT NULL
      THEN
         OPEN get_rt_quota_asgn_id_curs;

         FETCH get_rt_quota_asgn_id_curs
          INTO l_rt_quota_asgn_id;

         CLOSE get_rt_quota_asgn_id_curs;
      ELSE
         OPEN get_rt_quota_asgn_id_curs1;

         FETCH get_rt_quota_asgn_id_curs1
          INTO l_rt_quota_asgn_id;

         CLOSE get_rt_quota_asgn_id_curs1;
      END IF;

      RETURN l_rt_quota_asgn_id;
   END get_rt_quota_asgn_id;

-- This Procedure check whether the
-- whether Parent Plan Element's date range is within the referenced Element's
-- date range
   PROCEDURE check_create_pe_self_ref (
      x_calc_formula_id          IN       NUMBER,
      x_parent_start_date        IN       DATE,
      x_parent_end_date          IN       DATE
   )
   IS
      l_parent_calc_formula_id      cn_calc_formulas.calc_formula_id%TYPE;
      l_child_calc_formula_id       cn_calc_formulas.calc_formula_id%TYPE;
      parent_quota_id               NUMBER;
      child_quota_id                NUMBER;
      nt                            cn_calc_sql_exps_pvt.num_tbl_type;
      new_ss                        VARCHAR2 (4000);
      l_calc_sql_exp                VARCHAR2 (4000);
      l_parent_start_date           DATE;
      l_parent_end_date             DATE;
      l_child_start_date            DATE;
      l_child_end_date              DATE;
      rs                            VARCHAR2 (50);
      mc                            NUMBER;
      md                            VARCHAR2 (50);
   BEGIN
      cn_calc_sql_exps_pvt.get_dependent_plan_elts (p_api_version          => 1.0,
                                                    p_node_type            => 'F',
                                                    p_node_id              => x_calc_formula_id,
                                                    x_plan_elt_id_tbl      => nt,
                                                    x_return_status        => rs,
                                                    x_msg_count            => mc,
                                                    x_msg_data             => md
                                                   );

      IF rs <> 'S'
      THEN
         RAISE fnd_api.g_exc_error;
      ELSE                                                                                                                    --if return status = 'S'
         IF (nt.COUNT > 0)
         THEN
            FOR i IN 0 .. (nt.COUNT - 1)
            LOOP
               child_quota_id := nt (i);
               -- check for parent and child plan element date range
               l_parent_start_date := x_parent_start_date;
               l_parent_end_date := x_parent_end_date;

               SELECT start_date,
                      end_date
                 INTO l_child_start_date,
                      l_child_end_date
                 FROM cn_quotas
                WHERE quota_id = child_quota_id;

               -- check date range between the parent and child plan element
               IF (l_parent_start_date < l_child_start_date)
               THEN
                  IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
                  THEN
                     -- Need to define message 'CN_PE_CANNOT_REF_ITSEF' in SEED115
                     fnd_message.set_name ('CN', 'CN_PPE_WITHIN_CPE');
                     fnd_msg_pub.ADD;
                  END IF;

                  RAISE fnd_api.g_exc_error;
               END IF;                                                                                     -- l_child_start_date < l_parent_start_date

               IF ((l_parent_end_date IS NULL) AND (l_child_end_date IS NOT NULL))
               THEN
                  IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
                  THEN
                     -- Need to define message 'CN_PE_CED_CANNOT_BEFORE_PED' in SEED115
                     fnd_message.set_name ('CN', 'CN_PPE_WITHIN_CPE');
                     fnd_msg_pub.ADD;
                  END IF;

                  RAISE fnd_api.g_exc_error;
               END IF;                                                           -- ((l_child_end_date is NULL) AND (l_parent_child_date is not NULL))

               IF ((l_parent_end_date IS NOT NULL) AND (l_child_end_date IS NOT NULL)) AND (l_parent_end_date > l_child_end_date)
               THEN
                  IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
                  THEN
                     -- Need to define message 'CN_PE_CED_CANNOT_BEFORE_PED' in SEED115
                     fnd_message.set_name ('CN', 'CN_PPE_WITHIN_CPE');
                     fnd_msg_pub.ADD;
                  END IF;

                  RAISE fnd_api.g_exc_error;
               END IF;                                                                                     -- ( l_child_end_date > l_parent_end_date )
            END LOOP;                                                                                                                           -- for
         END IF;                                                                                                                         -- nt.count>0
      END IF;
   END check_create_pe_self_ref;

   PROCEDURE validate_formula (
      p_plan_element             IN       cn_chk_plan_element_pkg.pe_rec_type  --cn_plan_element_pvt.plan_element_rec_type
   )
   IS
      l_loading_status              VARCHAR2 (100);
      x_return_status               VARCHAR2 (100);
      x_loading_status              VARCHAR2 (100);
      l_formula_type                cn_calc_formulas.formula_type%TYPE;
      l_api_name                    VARCHAR2 (100) := 'validate_formula';
      l_calc_name                   cn_calc_formulas.NAME%TYPE;
   BEGIN

      -- Validate the Quota Type with the Respective Column
      -- Check if the quota type is formula then the formula name must be not null
      -- Check if the quota type is formula the package name must be null
      IF (p_plan_element.quota_type_code = 'FORMULA')
      THEN

          BEGIN
             SELECT NAME
               INTO l_calc_name
               FROM cn_calc_formulas
              WHERE calc_formula_id = p_plan_element.calc_formula_id;
          EXCEPTION
             WHEN NO_DATA_FOUND
             THEN
                IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
                THEN
                   fnd_message.set_name ('CN', 'CN_FORMULA_NOT_EXIST');
                   fnd_message.set_token ('FORMULA_NAME', p_plan_element.calc_formula_id);
                   fnd_msg_pub.ADD;
                END IF;

                x_loading_status := 'FORMULA_NOT_EXIST';
                RAISE fnd_api.g_exc_error;
          END;

         -- if Quota type is Formula, then Formula is Mandatory and
         -- Package name must be null
         cn_chk_plan_element_pkg.chk_formula_quota_pe (x_return_status       => x_return_status,
                                                       p_pe_rec              => p_plan_element,
                                                       p_loading_status      => x_loading_status,
                                                       x_loading_status      => l_loading_status
                                                      );
         x_loading_status := l_loading_status;

         IF (x_return_status <> fnd_api.g_ret_sts_success)
         THEN
            RAISE fnd_api.g_exc_error;
         END IF;
      ELSIF (p_plan_element.quota_type_code = 'EXTERNAL')
      THEN
         -- if Quota type is External Package name is Mandatory and
         -- formula must be null
         cn_chk_plan_element_pkg.chk_external_quota_pe (x_return_status       => x_return_status,
                                                        p_pe_rec              => p_plan_element,
                                                        p_loading_status      => x_loading_status,
                                                        x_loading_status      => l_loading_status
                                                       );

         IF (x_return_status <> fnd_api.g_ret_sts_success)
         THEN
            RAISE fnd_api.g_exc_error;
         END IF;
      ELSIF (p_plan_element.quota_type_code = 'NONE')
      THEN
         -- If quota type is NONE, both Formula and package must be null
         cn_chk_plan_element_pkg.chk_other_quota_pe (x_return_status       => x_return_status,
                                                     p_pe_rec              => p_plan_element,
                                                     p_loading_status      => x_loading_status,
                                                     x_loading_status      => l_loading_status
                                                    );

         IF (x_return_status <> fnd_api.g_ret_sts_success)
         THEN
            RAISE fnd_api.g_exc_error;
         END IF;
      END IF;

      -- 2.1 check For match of the INCENTIVE_TYPE_CODE against the type of the formula assigned.
      IF (p_plan_element.calc_formula_id IS NOT NULL)
      THEN
         BEGIN
            SELECT formula_type
              INTO l_formula_type
              FROM cn_calc_formulas
             WHERE calc_formula_id = p_plan_element.calc_formula_id;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
               THEN
                  fnd_message.set_name ('CN', 'CN_INVALID_DATA');
                  fnd_message.set_token ('OBJ_NAME', cn_chk_plan_element_pkg.g_formula_id);
                  fnd_msg_pub.ADD;
               END IF;

               RAISE fnd_api.g_exc_error;
         END;

         IF (p_plan_element.incentive_type_code = 'BONUS') AND (l_formula_type = 'C')
         THEN
            IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
            THEN
               fnd_message.set_name ('CN', 'CN_CANNOT_ASSIGN_FORMULA');
               fnd_message.set_token ('FORMULA_TYPE', cn_api.get_lkup_meaning ('COMMISSION', 'INCENTIVE_TYPE'));
               fnd_message.set_token ('PE_INC_TYPE', cn_api.get_lkup_meaning ('BONUS', 'INCENTIVE_TYPE'));
               fnd_msg_pub.ADD;
            END IF;

            RAISE fnd_api.g_exc_error;
         END IF;

         IF (p_plan_element.incentive_type_code = 'COMMISSION') AND (l_formula_type = 'B')
         THEN
            IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
            THEN
               fnd_message.set_name ('CN', 'CN_CANNOT_ASSIGN_FORMULA');
               fnd_message.set_token ('FORMULA_TYPE', cn_api.get_lkup_meaning ('BONUS', 'INCENTIVE_TYPE'));
               fnd_message.set_token ('PE_INC_TYPE', cn_api.get_lkup_meaning ('COMMISSION', 'INCENTIVE_TYPE'));
               fnd_msg_pub.ADD;
            END IF;

            RAISE fnd_api.g_exc_error;
         END IF;
      END IF;

      -- check the date range or the referenced plan element in formula assigned if any.
      IF (p_plan_element.calc_formula_id IS NOT NULL)
      THEN
         check_create_pe_self_ref (x_calc_formula_id        => p_plan_element.calc_formula_id,
                                   x_parent_start_date      => p_plan_element.start_date,
                                   x_parent_end_date        => p_plan_element.end_date
                                  );
      END IF;
   END validate_formula;

-- ----------------------------------------------------------------------------+
-- Procedure: chk_formula_quota_pe
-- Desc     : Check input for  Formula Quota type plan element
-- ----------------------------------------------------------------------------+
   PROCEDURE chk_formula_quota_pe (
      x_return_status            OUT NOCOPY VARCHAR2,
      p_pe_rec                   IN       cn_chk_plan_element_pkg.pe_rec_type ,--cn_plan_element_pvt.plan_element_rec_type,
      p_loading_status           IN       VARCHAR2,
      x_loading_status           OUT NOCOPY VARCHAR2
   )
   IS
      l_api_name           CONSTANT VARCHAR2 (30) := 'chk_formula_quota_pe';
      l_loading_status              VARCHAR2 (80);
   BEGIN
      x_return_status := fnd_api.g_ret_sts_success;
      x_loading_status := p_loading_status;

      --+
      -- Validate Rule : if quota type is formula
      -- package Name = NULL, calc_formula_id must be not NULL.
      -- incentive_type should not be Manual.
      IF ((cn_api.pe_char_field_must_null (p_char_field          => p_pe_rec.package_name,
                                           p_pe_type             => p_pe_rec.quota_type_code,
                                           p_obj_name            => g_package_name,
                                           p_token1              => NULL,
                                           p_token2              => NULL,
                                           p_token3              => NULL,
                                           p_loading_status      => x_loading_status,
                                           x_loading_status      => l_loading_status
                                          )
          ) = fnd_api.g_false
         )
      THEN
         RAISE fnd_api.g_exc_error;
      END IF;

      IF (cn_api.pe_num_field_cannot_null (p_num_field           => p_pe_rec.calc_formula_id,
                                           p_pe_type             => p_pe_rec.quota_type_code,
                                           p_obj_name            => g_formula_name,
                                           p_token1              => NULL,
                                           p_token2              => NULL,
                                           p_token3              => NULL,
                                           p_loading_status      => x_loading_status,
                                           x_loading_status      => l_loading_status
                                          ) = fnd_api.g_false
         )
      THEN
         RAISE fnd_api.g_exc_error;
      END IF;

      IF (p_pe_rec.incentive_type_code = 'MANUAL')
      THEN
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
         THEN
            fnd_message.set_name ('CN', 'CN_INCENTIVE_TYPE_MUST_BE');
            fnd_message.set_token ('OBJ_VALUE', 'Bonus or Commission');
            fnd_message.set_token ('PLAN_TYPE', cn_api.get_lkup_meaning (p_pe_rec.quota_type_code, 'QUOTA_TYPE'));
            fnd_msg_pub.ADD;
         END IF;

         x_loading_status := 'CN_INCENTIVE_TYPE_MUST_BE';
         RAISE fnd_api.g_exc_error;
      END IF;
   EXCEPTION
      WHEN fnd_api.g_exc_error
      THEN
         x_return_status := fnd_api.g_ret_sts_error;
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         x_loading_status := 'UNEXPECTED_ERR';
      WHEN OTHERS
      THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         x_loading_status := 'UNEXPECTED_ERR';

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;
   END chk_formula_quota_pe;

 -- ----------------------------------------------------------------------------+
-- Procedure: chk_external_quota_pe
-- Desc     : Check input for External Quota type plan element
-- ----------------------------------------------------------------------------+
   PROCEDURE chk_external_quota_pe (
      x_return_status            OUT NOCOPY VARCHAR2,
      p_pe_rec                   IN       cn_chk_plan_element_pkg.pe_rec_type , --cn_plan_element_pvt.plan_element_rec_type,
      p_loading_status           IN       VARCHAR2,
      x_loading_status           OUT NOCOPY VARCHAR2
   )
   IS
      l_api_name           CONSTANT VARCHAR2 (30) := 'chk_external_quota_pe';
      l_loading_status              VARCHAR2 (80);
   BEGIN
      x_return_status := fnd_api.g_ret_sts_success;
      x_loading_status := p_loading_status;

      --+
      -- Validate Rule : if quota type is EXTERNAL
      -- package Name must not be Null, Calc_Fromula_id must be null.
      -- incentive_type should not be MANUAL
      IF ((cn_api.pe_num_field_must_null (p_num_field           => p_pe_rec.calc_formula_id,
                                          p_pe_type             => p_pe_rec.quota_type_code,
                                          p_obj_name            => g_formula_name,
                                          p_token1              => NULL,
                                          p_token2              => NULL,
                                          p_token3              => NULL,
                                          p_loading_status      => x_loading_status,
                                          x_loading_status      => l_loading_status
                                         )
          ) = fnd_api.g_false
         )
      THEN
         RAISE fnd_api.g_exc_error;
      END IF;

      IF (cn_api.pe_char_field_cannot_null (p_char_field          => p_pe_rec.package_name,
                                            p_pe_type             => p_pe_rec.quota_type_code,
                                            p_obj_name            => g_package_name,
                                            p_token1              => NULL,
                                            p_token2              => NULL,
                                            p_token3              => NULL,
                                            p_loading_status      => x_loading_status,
                                            x_loading_status      => l_loading_status
                                           ) = fnd_api.g_false
         )
      THEN
         RAISE fnd_api.g_exc_error;
      END IF;

      IF (p_pe_rec.incentive_type_code = 'MANUAL')
      THEN
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
         THEN
            fnd_message.set_name ('CN', 'CN_INCENTIVE_TYPE_MUST_BE');
            fnd_message.set_token ('OBJ_VALUE', 'Bonus or Commission');
            fnd_message.set_token ('PLAN_TYPE', cn_api.get_lkup_meaning (p_pe_rec.quota_type_code, 'QUOTA_TYPE'));
            fnd_msg_pub.ADD;
         END IF;

         x_loading_status := 'CN_INCENTIVE_TYPE_MUST_BE';
         RAISE fnd_api.g_exc_error;
      END IF;
   EXCEPTION
      WHEN fnd_api.g_exc_error
      THEN
         x_return_status := fnd_api.g_ret_sts_error;
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         x_loading_status := 'UNEXPECTED_ERR';
      WHEN OTHERS
      THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         x_loading_status := 'UNEXPECTED_ERR';

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;
   END chk_external_quota_pe;

 -- ----------------------------------------------------------------------------+
-- Procedure: chk_others_quota_pe
-- Desc     : Check input for other Quota type plan element
-- ----------------------------------------------------------------------------+
   PROCEDURE chk_other_quota_pe (
      x_return_status            OUT NOCOPY VARCHAR2,
      p_pe_rec                   IN       cn_chk_plan_element_pkg.pe_rec_type , --cn_plan_element_pvt.plan_element_rec_type,
      p_loading_status           IN       VARCHAR2,
      x_loading_status           OUT NOCOPY VARCHAR2
   )
   IS
      l_api_name           CONSTANT VARCHAR2 (30) := 'chk_other_quota_pe';
      l_loading_status              VARCHAR2 (80);
   BEGIN
      x_return_status := fnd_api.g_ret_sts_success;
      x_loading_status := p_loading_status;

      --+
      -- Validate Rule : if quota type is OTHER
      -- package Name must  be Null, Calc_Fromula_id must be null.
      -- incentive_type must me  MANUAL
      IF ((cn_api.pe_num_field_must_null (p_num_field           => p_pe_rec.calc_formula_id,
                                          p_pe_type             => p_pe_rec.quota_type_code,
                                          p_obj_name            => g_formula_name,
                                          p_token1              => NULL,
                                          p_token2              => NULL,
                                          p_token3              => NULL,
                                          p_loading_status      => x_loading_status,
                                          x_loading_status      => l_loading_status
                                         )
          ) = fnd_api.g_false
         )
      THEN
         RAISE fnd_api.g_exc_error;
      END IF;

      IF ((cn_api.pe_char_field_must_null (p_char_field          => p_pe_rec.package_name,
                                           p_pe_type             => p_pe_rec.quota_type_code,
                                           p_obj_name            => g_package_name,
                                           p_token1              => NULL,
                                           p_token2              => NULL,
                                           p_token3              => NULL,
                                           p_loading_status      => x_loading_status,
                                           x_loading_status      => l_loading_status
                                          )
          ) = fnd_api.g_false
         )
      THEN
         RAISE fnd_api.g_exc_error;
      END IF;

      IF (p_pe_rec.incentive_type_code NOT IN ('MANUAL'))
      THEN
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
         THEN
            fnd_message.set_name ('CN', 'CN_INCENTIVE_TYPE_MUST_BE');
            fnd_message.set_token ('OBJ_VALUE', 'Manual');
            fnd_message.set_token ('PLAN_TYPE', cn_api.get_lkup_meaning (p_pe_rec.quota_type_code, 'QUOTA_TYPE'));
            fnd_msg_pub.ADD;
         END IF;

         x_loading_status := 'CN_INCENTIVE_TYPE_MUST_BE';
         RAISE fnd_api.g_exc_error;
      END IF;
   EXCEPTION
      WHEN fnd_api.g_exc_error
      THEN
         x_return_status := fnd_api.g_ret_sts_error;
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         x_loading_status := 'UNEXPECTED_ERR';
      WHEN OTHERS
      THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         x_loading_status := 'UNEXPECTED_ERR';

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;
   END chk_other_quota_pe;

--| -----------------------------------------------------------------------+
--|   Procedure Name :  chk_miss_date_para
--|   Desc : Check for missing parameters -- Date type
--| ---------------------------------------------------------------------+
   FUNCTION chk_miss_date_para (
      p_date_para                IN       DATE,
      p_para_name                IN       VARCHAR2,
      p_loading_status           IN       VARCHAR2,
      x_loading_status           OUT NOCOPY VARCHAR2
   )
      RETURN VARCHAR2
   IS
      l_return_code                 VARCHAR2 (1) := fnd_api.g_false;
   BEGIN
      x_loading_status := p_loading_status;

      IF (p_date_para = fnd_api.g_miss_date)
      THEN
         -- Error, check the msg level and add an error message to the
         -- API message list
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
         THEN
            fnd_message.set_name ('CN', 'CN_MISS_PARAMETER');
            fnd_message.set_token ('PARA_NAME', p_para_name);
            fnd_msg_pub.ADD;
         END IF;

         x_loading_status := 'CN_MISS_PARAMETER';
         l_return_code := fnd_api.g_true;
      END IF;

      RETURN l_return_code;
   END chk_miss_date_para;

--| -----------------------------------------------------------------------+
--|   Function Name :  chk_null_date_para
--|   Desc : Check for Null parameters -- Date type
--| ---------------------------------------------------------------------+
   FUNCTION chk_null_date_para (
      p_date_para                IN       DATE,
      p_obj_name                 IN       VARCHAR2,
      p_loading_status           IN       VARCHAR2,
      x_loading_status           OUT NOCOPY VARCHAR2
   )
      RETURN VARCHAR2
   IS
      l_return_code                 VARCHAR2 (1) := fnd_api.g_false;
   BEGIN
      x_loading_status := p_loading_status;

      IF (p_date_para IS NULL)
      THEN
         -- Error, check the msg level and add an error message to the
         -- API message list
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
         THEN
            fnd_message.set_name ('CN', 'CN_CANNOT_NULL');
            fnd_message.set_token ('OBJ_NAME', p_obj_name);
            fnd_msg_pub.ADD;
         END IF;

         x_loading_status := 'CN_CANNOT_NULL';
         l_return_code := fnd_api.g_true;
      END IF;

      RETURN l_return_code;
   END chk_null_date_para;

--| -----------------------------------------------------------------------+
--|  PROCEDURE Name : chk_date_effective
--|   Desc : Check Date effectivity for accelerator
--| -----------------------------------------------------------------------+
   PROCEDURE chk_date_effective (
      x_return_status            OUT NOCOPY VARCHAR2,
      p_start_date               IN       DATE,
      p_end_date                 IN       DATE,
      p_quota_id                 IN       NUMBER,
      p_object_type              IN       VARCHAR2,
      p_loading_status           IN       VARCHAR2,
      x_loading_status           OUT NOCOPY VARCHAR2
   )
   IS
      l_tmp                         NUMBER;

      CURSOR quota_curs
      IS
         SELECT start_date,
                end_date
           FROM cn_quotas
          WHERE quota_id = p_quota_id;

      l_record_info                 quota_curs%ROWTYPE;
      l_api_name           CONSTANT VARCHAR2 (30) := 'chk_date_effective';
   BEGIN
      x_loading_status := p_loading_status;
      x_return_status := fnd_api.g_ret_sts_success;

      IF p_quota_id IS NOT NULL
      THEN
         OPEN quota_curs;

         FETCH quota_curs
          INTO l_record_info;

         CLOSE quota_curs;

         IF (   TRUNC (p_start_date) < TRUNC (l_record_info.start_date)
             OR (p_end_date IS NULL AND l_record_info.end_date IS NOT NULL)
             OR (p_end_date IS NOT NULL AND l_record_info.end_date IS NOT NULL AND TRUNC (p_end_date) > TRUNC (l_record_info.end_date))
            )
         THEN
            IF UPPER (p_object_type) = 'UPLIFT'
            THEN
               IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
               THEN
                  fnd_message.set_name ('CN', 'CN_UPLIFT_DATE_EFFECTIVE');
                  fnd_msg_pub.ADD;
               END IF;

               x_loading_status := 'UPLIFT_DATE_EFFECTIVE';
               RAISE fnd_api.g_exc_error;
            ELSE
               IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
               THEN
                  fnd_message.set_name ('CN', 'CN_RATE_DATE_EFFECTIVE');
                  fnd_msg_pub.ADD;
               END IF;

               x_loading_status := 'RATE_DATE_EFFECTIVE';
               RAISE fnd_api.g_exc_error;
            END IF;
         END IF;
      END IF;
   EXCEPTION
      WHEN fnd_api.g_exc_error
      THEN
         x_return_status := fnd_api.g_ret_sts_error;
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         x_loading_status := 'UNEXPECTED_ERR';
      WHEN OTHERS
      THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         x_loading_status := 'UNEXPECTED_ERR';

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;
   END chk_date_effective;

--| -----------------------------------------------------------------------+
--|  PROCEDURE Name : chk_rate_quota_update_delete
--|   Desc : Check rate Quota Update Delete
--| -----------------------------------------------------------------------+
   PROCEDURE chk_rate_quota_iud (
      x_return_status            OUT NOCOPY VARCHAR2,
      p_start_date               IN       DATE,
      p_end_date                 IN       DATE,
      p_iud_flag                 IN       VARCHAR2,
      p_quota_id                 IN       NUMBER,
      p_calc_formula_id          IN       NUMBER,
      p_rt_quota_asgn_id         IN       NUMBER,
      p_loading_status           IN       VARCHAR2,
      x_loading_status           OUT NOCOPY VARCHAR2
   )
   IS
      CURSOR prev
      IS
         SELECT   start_date,
                  end_date
             FROM cn_rt_quota_asgns
            WHERE quota_id = p_quota_id
              AND calc_formula_id = p_calc_formula_id
              AND rt_quota_asgn_id <> NVL (p_rt_quota_asgn_id, 0)
              AND TRUNC (start_date) < TRUNC (p_start_date)
         ORDER BY start_date DESC;

      CURSOR NEXT
      IS
         SELECT   start_date,
                  end_date
             FROM cn_rt_quota_asgns
            WHERE quota_id = p_quota_id
              AND calc_formula_id = p_calc_formula_id
              AND rt_quota_asgn_id <> NVL (p_rt_quota_asgn_id, 0)
              AND TRUNC (start_date) > TRUNC (p_start_date)
         ORDER BY start_date ASC;

      l_start_date                  DATE;
      l_end_date                    DATE;
   BEGIN
      --  Initialize API return status to success
      x_return_status := fnd_api.g_ret_sts_success;
      x_loading_status := p_loading_status;

      --+
      -- get are there any record previously
      --+
      IF p_iud_flag IN ('I', 'U')
      THEN
         OPEN prev;

         FETCH prev
          INTO l_start_date,
               l_end_date;

         CLOSE prev;

         IF l_start_date IS NOT NULL AND TRUNC (NVL (l_end_date, fnd_api.g_miss_date)) + 1 <> TRUNC (p_start_date)
         THEN
            x_loading_status := 'CN_RATE_OP_NOT_ALLOWED';
            x_return_status := fnd_api.g_ret_sts_error;
         END IF;

         l_start_date := NULL;
         l_end_date := NULL;

         IF x_return_status <> fnd_api.g_ret_sts_error
         THEN
            --+
            -- Get are there any records available after this
            --+
            OPEN NEXT;

            FETCH NEXT
             INTO l_start_date,
                  l_end_date;

            CLOSE NEXT;

            IF l_start_date IS NOT NULL AND TRUNC (l_start_date) - 1 <> TRUNC (NVL (p_end_date, fnd_api.g_miss_date))
            THEN
               x_loading_status := 'CN_RATE_OP_NOT_ALLOWED';
               x_return_status := fnd_api.g_ret_sts_error;
            END IF;
         END IF;
      ELSIF p_iud_flag = 'D'
      THEN
         -- You cannot deletE the middle record in the rates
         -- delete middle record may cause invalid seq and
         -- date overlap
         OPEN prev;

         FETCH prev
          INTO l_start_date,
               l_end_date;

         CLOSE prev;

         IF l_start_date IS NOT NULL
         THEN
            l_start_date := NULL;
            l_end_date := NULL;

            OPEN NEXT;

            FETCH NEXT
             INTO l_start_date,
                  l_end_date;

            CLOSE NEXT;

            IF l_start_date IS NOT NULL
            THEN
               x_loading_status := 'CN_RATE_OP_NOT_ALLOWED';
               x_return_status := fnd_api.g_ret_sts_error;
            END IF;
         END IF;
      END IF;
   END chk_rate_quota_iud;

--| -----------------------------------------------------------------------+
--|  PROCEDURE Name : chk_Uplift_insert_update_delete
--|   Desc : Check Uplift Insert Update Delete
--| -----------------------------------------------------------------------+
   PROCEDURE chk_uplift_iud (
      x_return_status            OUT NOCOPY VARCHAR2,
      p_start_date               IN       DATE,
      p_end_date                 IN       DATE,
      p_iud_flag                 IN       VARCHAR2,
      p_quota_rule_id            IN       NUMBER,
      p_quota_rule_uplift_id     IN       NUMBER,
      p_loading_status           IN       VARCHAR2,
      x_loading_status           OUT NOCOPY VARCHAR2
   )
   IS
      CURSOR prev
      IS
         SELECT   start_date,
                  end_date
             FROM cn_quota_rule_uplifts
            WHERE quota_rule_id = p_quota_rule_id
              AND quota_rule_uplift_id <> NVL (p_quota_rule_uplift_id, 0)
              AND TRUNC (start_date) < TRUNC (p_start_date)
         ORDER BY start_date DESC;

      CURSOR NEXT
      IS
         SELECT   start_date,
                  end_date
             FROM cn_quota_rule_uplifts
            WHERE quota_rule_id = p_quota_rule_id
              AND quota_rule_uplift_id <> NVL (p_quota_rule_uplift_id, 0)
              AND TRUNC (start_date) > TRUNC (p_start_date)
         ORDER BY start_date ASC;

      l_start_date                  DATE;
      l_end_date                    DATE;
   BEGIN
      --  Initialize API return status to success
      x_return_status := fnd_api.g_ret_sts_success;
      x_loading_status := p_loading_status;

      IF p_iud_flag IN ('I', 'U')
      THEN
         --+
         -- get are there any record previously
         --+
         OPEN prev;

         FETCH prev
          INTO l_start_date,
               l_end_date;

         CLOSE prev;

         IF l_start_date IS NOT NULL AND TRUNC (NVL (l_end_date, fnd_api.g_miss_date)) + 1 <> TRUNC (p_start_date)
         THEN
            x_loading_status := 'CN_UPLIFT_OP_NOT_ALLOWED';
            x_return_status := fnd_api.g_ret_sts_error;
         END IF;

         l_start_date := NULL;
         l_end_date := NULL;

         IF x_return_status <> fnd_api.g_ret_sts_error
         THEN
            --+
            -- Get are there any records available after this
            --+
            OPEN NEXT;

            FETCH NEXT
             INTO l_start_date,
                  l_end_date;

            CLOSE NEXT;

            IF l_start_date IS NOT NULL AND TRUNC (l_start_date) - 1 <> TRUNC (NVL (p_end_date, fnd_api.g_miss_date))
            THEN
               x_loading_status := 'CN_UPLIFT_OP_NOT_ALLOWED';
               x_return_status := fnd_api.g_ret_sts_error;
            END IF;
         END IF;
      ELSIF p_iud_flag = 'D'
      THEN
         -- You cannot delete the middle record in the rates
         -- delete middle record may cause invalid seq and
         -- date overlap
         OPEN prev;

         FETCH prev
          INTO l_start_date,
               l_end_date;

         CLOSE prev;

         IF l_start_date IS NOT NULL
         THEN
            l_start_date := NULL;
            l_end_date := NULL;

            OPEN NEXT;

            FETCH NEXT
             INTO l_start_date,
                  l_end_date;

            CLOSE NEXT;

            IF l_start_date IS NOT NULL
            THEN
               x_loading_status := 'CN_UPLIFT_OP_NOT_ALLOWED';
               x_return_status := fnd_api.g_ret_sts_error;
            END IF;
         END IF;
      END IF;
   END chk_uplift_iud;

--| -----------------------------------------------------------------------+
--|   Function Name : Get_Quota_type
--| ---------------------------------------------------------------------+
   FUNCTION get_quota_type (
      p_quota_id                          NUMBER
   )
      RETURN cn_quotas.quota_type_code%TYPE
   IS
      l_quota_type                  cn_quotas.quota_type_code%TYPE;
   BEGIN
      SELECT quota_type_code
        INTO l_quota_type
        FROM cn_quotas
       WHERE quota_id = p_quota_id;

      RETURN l_quota_type;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         RETURN NULL;
   END get_quota_type;

--| -----------------------------------------------------------------------+
--|  PROCEDURE Name : chk_formula_rate_date
--|   Desc : Check Date effectivity for rate
--| -----------------------------------------------------------------------+
   PROCEDURE chk_formula_rate_date (
      x_return_status            OUT NOCOPY VARCHAR2,
      p_start_date               IN       DATE,
      p_end_date                 IN       DATE,
      p_quota_name               IN       VARCHAR2,
      p_calc_formula_id          IN       NUMBER,
      p_calc_formula_name        IN       VARCHAR2,
      p_loading_status           IN       VARCHAR2,
      x_loading_status           OUT NOCOPY VARCHAR2
   )
   IS
      l_null_date          CONSTANT DATE := TO_DATE ('31-12-3000', 'DD-MM-YYYY');
      l_tmp                         NUMBER;
         /* CURSOR rt_formula_curs IS
      SELECT  Count(1)
        FROM cn_rt_formula_asgns
        WHERE calc_formula_id = p_calc_formula_id
        and (  start_Date < p_start_date
        or ( p_end_date IS NOT NULL
            and end_date IS NULL )
        or  end_date  > p_end_date ); */
      l_record_found                NUMBER;
      l_api_name           CONSTANT VARCHAR2 (30) := 'chk_formula_rate_date';
      l_temp_start_date             DATE := NULL;
      l_temp_end_date               DATE := NULL;
      l_temp_count                  NUMBER;
   BEGIN
      x_loading_status := p_loading_status;
      x_return_status := fnd_api.g_ret_sts_success;

      IF p_calc_formula_id IS NOT NULL
      THEN
         -- OPEN rt_formula_curs;
         -- FETCH rt_formula_curs INTO l_record_found;
         -- CLOSE rt_formula_curs;

         --   IF l_record_found  > 0  THEN
         SELECT MIN (start_date),
                MAX (NVL (end_date, l_null_date))
           INTO l_temp_start_date,
                l_temp_end_date
           FROM cn_rt_formula_asgns
          WHERE calc_formula_id = p_calc_formula_id;

         IF l_temp_start_date IS NOT NULL AND ((p_start_date < l_temp_start_date) OR (NVL (p_end_date, l_null_date) > l_temp_end_date))
         THEN
            IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
            THEN
               fnd_message.set_name ('CN', 'CN_FRT_DT_NOT_WITHIN_QUOTA');
               fnd_msg_pub.ADD;
            END IF;

            x_loading_status := 'RT_DATE_NOT_WITHIN_QUOTA';
            RAISE fnd_api.g_exc_error;
         END IF;
      END IF;
   EXCEPTION
      WHEN fnd_api.g_exc_error
      THEN
         x_return_status := fnd_api.g_ret_sts_error;
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         x_loading_status := 'UNEXPECTED_ERR';
      WHEN OTHERS
      THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         x_loading_status := 'UNEXPECTED_ERR';

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;
   END chk_formula_rate_date;

--| -----------------------------------------------------------------------+
--|  PROCEDURE Name : chk_comp_plan_date
--|   Desc : Check chk_comp_plan_date
--|          This program will check the start date and end date when
--|          when user try to update the plan element start date and
--|          and end date after the plan element has been assigned to
--|          to a comp plan.
--|          Case 1
--|                 comp_plan_start_date must greater than quota start date
--|          Case 2
--|                 comp_plan_end_date must less than quota end date
--|          Case 3
--|                 comp Plan end date is null and Quota end is not null
--|
--|          All the above three cases cannot be accepted when a PE
--|          Start date and end date changes, if plan element already
--|          to a comp plan
--|  We don't do case 1, 2 and 3 any more. All we check here is whether
--|  plan element date and comp plan date overlap or not.
--|  Last modified by Kai Chen, 11/15/99
--| -----------------------------------------------------------------------+
   PROCEDURE chk_comp_plan_date (
      x_return_status            OUT NOCOPY VARCHAR2,
      p_start_date               IN       DATE,
      p_end_date                 IN       DATE,
      p_quota_name               IN       VARCHAR2,
      p_quota_id                 IN       NUMBER,
      p_loading_status           IN       VARCHAR2,
      x_loading_status           OUT NOCOPY VARCHAR2
   )
   IS
      l_tmp                         NUMBER;

      CURSOR comp_plan_curs
      IS
         SELECT cp.start_date,
                cp.end_date
           FROM cn_quota_assigns cq,
                cn_comp_plans cp
          WHERE cq.comp_plan_id = cp.comp_plan_id AND cq.quota_id = p_quota_id;

      l_record_found                NUMBER;
      l_api_name           CONSTANT VARCHAR2 (30) := 'chk_comp_plan_date';
   BEGIN
      x_loading_status := p_loading_status;
      x_return_status := fnd_api.g_ret_sts_success;

      IF p_quota_id IS NOT NULL
      THEN
         FOR l_rec IN comp_plan_curs
         LOOP
            IF (NOT cn_api.date_range_overlap (l_rec.start_date, l_rec.end_date, p_start_date, p_end_date))
            THEN
               IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
               THEN
                  fnd_message.set_name ('CN', 'CN_CP_DT_NOT_WITHIN_QUOTA');
                  fnd_msg_pub.ADD;
               END IF;

               x_loading_status := 'CP_DATE_NOT_WITHIN_QUOTA';
               RAISE fnd_api.g_exc_error;
            END IF;
         END LOOP;
      END IF;
   EXCEPTION
      WHEN fnd_api.g_exc_error
      THEN
         x_return_status := fnd_api.g_ret_sts_error;
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         x_loading_status := 'UNEXPECTED_ERR';
      WHEN OTHERS
      THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         x_loading_status := 'UNEXPECTED_ERR';

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;
   END chk_comp_plan_date;

--| -----------------------------------------------------------------------+
--|  PROCEDURE Name : chk_uplift_date
--|   Desc : Check Date effectivity for rate
--| -----------------------------------------------------------------------+
   PROCEDURE chk_uplift_date (
      x_return_status            OUT NOCOPY VARCHAR2,
      p_start_date               IN       DATE,
      p_end_date                 IN       DATE,
      p_quota_name               IN       VARCHAR2,
      p_quota_id                 IN       NUMBER,
      p_loading_status           IN       VARCHAR2,
      x_loading_status           OUT NOCOPY VARCHAR2
   )
   IS
      l_tmp                         NUMBER;

      CURSOR uplift_curs
      IS
         SELECT COUNT (1)
           FROM cn_quota_rule_uplifts u,
                cn_quota_rules r
          WHERE r.quota_id = p_quota_id
            AND r.quota_rule_id = u.quota_rule_id
            AND (u.start_date < p_start_date OR (p_end_date IS NOT NULL AND u.end_date IS NULL) OR u.end_date > p_end_date);

      l_record_found                NUMBER;
      l_api_name           CONSTANT VARCHAR2 (30) := 'chk_uplift_date';
   BEGIN
      x_loading_status := p_loading_status;
      x_return_status := fnd_api.g_ret_sts_success;

      IF p_quota_id IS NOT NULL
      THEN
         OPEN uplift_curs;

         FETCH uplift_curs
          INTO l_record_found;

         CLOSE uplift_curs;

         IF l_record_found > 0
         THEN
            IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
            THEN
               fnd_message.set_name ('CN', 'CN_UPLIFT_DT_NOT_WIN_QUOTA');
               fnd_msg_pub.ADD;
            END IF;

            x_loading_status := 'UPLIFT_DATE_NOT_WIN_QUOTA';
            RAISE fnd_api.g_exc_error;
         END IF;
      END IF;
   EXCEPTION
      WHEN fnd_api.g_exc_error
      THEN
         x_return_status := fnd_api.g_ret_sts_error;
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         x_loading_status := 'UNEXPECTED_ERR';
      WHEN OTHERS
      THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         x_loading_status := 'UNEXPECTED_ERR';

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;
   END chk_uplift_date;

--| -----------------------------------------------------------------------+
--|  PROCEDURE Name : chk_rate_quota_date
--|   Desc : Check Date effectivity for rate
--| -----------------------------------------------------------------------+
   PROCEDURE chk_rate_quota_date (
      x_return_status            OUT NOCOPY VARCHAR2,
      p_start_date               IN       DATE,
      p_end_date                 IN       DATE,
      p_quota_name               IN       VARCHAR2,
      p_quota_id                 IN       NUMBER,
      p_loading_status           IN       VARCHAR2,
      x_loading_status           OUT NOCOPY VARCHAR2
   )
   IS
      l_tmp                         NUMBER;

      CURSOR rate_quota_curs
      IS
         SELECT COUNT (1)
           FROM cn_rt_quota_asgns u
          WHERE u.quota_id = p_quota_id
                AND (u.start_date < p_start_date OR (p_end_date IS NOT NULL AND u.end_date IS NULL) OR u.end_date > p_end_date);

      l_record_found                NUMBER;
      l_api_name           CONSTANT VARCHAR2 (30) := 'chk_rate_quota_date';
   BEGIN
      x_loading_status := p_loading_status;
      x_return_status := fnd_api.g_ret_sts_success;

      IF p_quota_id IS NOT NULL
      THEN
         OPEN rate_quota_curs;

         FETCH rate_quota_curs
          INTO l_record_found;

         CLOSE rate_quota_curs;

         IF l_record_found > 0
         THEN
            IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
            THEN
               fnd_message.set_name ('CN', 'CN_RQ_DT_NOT_WIN_QUOTA');
               fnd_msg_pub.ADD;
            END IF;

            x_loading_status := 'RQ_DATE_NOT_WIN_QUOTA';
            RAISE fnd_api.g_exc_error;
         END IF;
      END IF;
   EXCEPTION
      WHEN fnd_api.g_exc_error
      THEN
         x_return_status := fnd_api.g_ret_sts_error;
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         x_loading_status := 'UNEXPECTED_ERR';
      WHEN OTHERS
      THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         x_loading_status := 'UNEXPECTED_ERR';

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;
   END chk_rate_quota_date;
END cn_chk_plan_element_pkg;

/
