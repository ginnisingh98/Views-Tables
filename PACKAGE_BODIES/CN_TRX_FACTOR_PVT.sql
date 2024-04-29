--------------------------------------------------------
--  DDL for Package Body CN_TRX_FACTOR_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_TRX_FACTOR_PVT" AS
   /*$Header: cnvtxftb.pls 120.3 2006/01/12 00:00:29 chanthon noship $*/
   g_pkg_name           CONSTANT VARCHAR2 (30) := 'CN_TRX_FACTOR_PVT';

--|/*-----------------------------------------------------------------------+
--|
--|  Procedure Name : CHECK_VALID_QUOTAS
--|
--|----------------------------------------------------------------------- */
   PROCEDURE check_valid_quotas (
      x_return_status            OUT NOCOPY VARCHAR2,
      x_msg_count                OUT NOCOPY NUMBER,
      x_msg_data                 OUT NOCOPY VARCHAR2,
      p_quota_name               IN       VARCHAR2,
      p_org_id                   IN       NUMBER,
      p_rev_class_name           IN       VARCHAR2,
      x_quota_id                 OUT NOCOPY NUMBER,
      x_quota_rule_id            OUT NOCOPY NUMBER,
      x_rev_class_id             OUT NOCOPY NUMBER,
      p_loading_status           IN       VARCHAR2,
      x_loading_status           OUT NOCOPY VARCHAR2
   )
   IS
      l_api_name           CONSTANT VARCHAR2 (30) := 'Validate_trx_factors';
      l_lkup_meaning                cn_lookups.meaning%TYPE;
      l_loading_status              VARCHAR2 (80);
   BEGIN
      --  Initialize API return status to success
      x_return_status := fnd_api.g_ret_sts_success;
      x_loading_status := p_loading_status;
      --+
      -- Check Miss And Null Parameters.
      --+
      l_lkup_meaning := cn_api.get_lkup_meaning ('QUOTA_NAME', 'PM_OBJECT_TYPE');

      IF ((cn_api.chk_null_char_para (p_char_para           => p_quota_name,
                                      p_obj_name            => l_lkup_meaning,
                                      p_loading_status      => x_loading_status,
                                      x_loading_status      => l_loading_status
                                     )
          ) = fnd_api.g_true
         )
      THEN
         RAISE fnd_api.g_exc_error;
      END IF;

      l_lkup_meaning := cn_api.get_lkup_meaning ('', 'PM_OBJECT_TYPE');

      IF ((cn_api.chk_null_char_para (p_char_para           => p_rev_class_name,
                                      p_obj_name            => l_lkup_meaning,
                                      p_loading_status      => x_loading_status,
                                      x_loading_status      => l_loading_status
                                     )
          ) = fnd_api.g_true
         )
      THEN
         RAISE fnd_api.g_exc_error;
      END IF;

      -- Quota ID
      x_quota_id := cn_chk_plan_element_pkg.get_quota_id (LTRIM (RTRIM (p_quota_name)), p_org_id);

      IF p_quota_name IS NOT NULL
      THEN
         IF x_quota_id IS NULL
         THEN
            IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
            THEN
               fnd_message.set_name ('CN', 'CN_PLN_NOT_EXIST');
               fnd_message.set_token ('PE_NAME', p_quota_name);
               fnd_msg_pub.ADD;
               RAISE fnd_api.g_exc_error;
            END IF;
         END IF;
      END IF;

      -- Get the Revenue Class ID
      x_rev_class_id := cn_api.get_rev_class_id (LTRIM (RTRIM (p_rev_class_name)), p_org_id);
      -- get the Quota Rule ID
      x_quota_rule_id := cn_chk_plan_element_pkg.get_quota_rule_id (x_quota_id, x_rev_class_id);

      IF p_rev_class_name IS NOT NULL
      THEN
         IF x_rev_class_id IS NULL
         THEN
            IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
            THEN
               fnd_message.set_name ('CN', 'CN_REV_CLASS_NOT_EXIST');
               fnd_msg_pub.ADD;
            END IF;

            RAISE fnd_api.g_exc_error;
         END IF;
      ELSE
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
         THEN
            fnd_message.set_name ('CN', 'CN_REV_CLASS_NOT_ASSIGNED');
            fnd_msg_pub.ADD;
         END IF;

         RAISE fnd_api.g_exc_error;
      END IF;

      IF x_quota_rule_id IS NULL
      THEN
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
         THEN
            fnd_message.set_name ('CN', 'CN_QUOTA_RULE_NOT_EXIST');
            fnd_msg_pub.ADD;
         END IF;

         RAISE fnd_api.g_exc_error;
      END IF;
   -- End Check Valid Quotas.
   END check_valid_quotas;

-- Start of comments
--    API name        : Create_Trx_Factor
--    Type            : Private.
--    Function        :
--    Pre-reqs        : None.
--    Parameters      :
--    IN              : p_api_version         IN NUMBER       Required
--                      p_init_msg_list       IN VARCHAR2     Optional
--                        Default = FND_API.G_FALSE
--                      p_commit              IN VARCHAR2     Optional
--                        Default = FND_API.G_FALSE
--                      p_validation_level    IN NUMBER       Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                      p_trx_factor        IN  trx_factor_rec_type
--    OUT             : x_return_status       OUT     VARCHAR2(1)
--                      x_msg_count           OUT     NUMBER
--                      x_msg_data            OUT     VARCHAR2(2000)
--                      x_trx_factor_id        OUT     NUMBER
--    Version :         Current version       1.0
--    Notes           : Note text
--
-- End of comments
   PROCEDURE create_trx_factor (
      p_api_version              IN       NUMBER,
      p_init_msg_list            IN       VARCHAR2 := fnd_api.g_false,
      p_commit                   IN       VARCHAR2 := fnd_api.g_false,
      p_validation_level         IN       NUMBER := fnd_api.g_valid_level_full,
      p_trx_factor               IN OUT NOCOPY trx_factor_rec_type,
      x_return_status            OUT NOCOPY VARCHAR2,
      x_msg_count                OUT NOCOPY NUMBER,
      x_msg_data                 OUT NOCOPY VARCHAR2
   )
   IS
      l_api_name           CONSTANT VARCHAR2 (30) := 'Create_Trx_Factor';
      l_api_version        CONSTANT NUMBER := 1.0;
      l_temp_count                  NUMBER;
   BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT create_trx_factor;

      -- Standard call to check for call compatibility.
      IF NOT fnd_api.compatible_api_call (l_api_version, p_api_version, l_api_name, g_pkg_name)
      THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF fnd_api.to_boolean (p_init_msg_list)
      THEN
         fnd_msg_pub.initialize;
      END IF;

      --  Initialize API return status to success
      x_return_status := fnd_api.g_ret_sts_success;
      -- API body

      -- This will never be used
      RAISE fnd_api.g_exc_unexpected_error;

      -- End of API body.
      -- Standard check of p_commit.
      IF fnd_api.to_boolean (p_commit)
      THEN
         COMMIT WORK;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
   EXCEPTION
      WHEN fnd_api.g_exc_error
      THEN
         ROLLBACK TO create_trx_factor;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         ROLLBACK TO create_trx_factor;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
      WHEN OTHERS
      THEN
         ROLLBACK TO create_trx_factor;
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
   END create_trx_factor;

   -- Start of comments
   --    API name        : Validate_Trx_Factor
   --    Type            : Private.
   --    Function        :
   --    Pre-reqs        : None.
   --    Parameters      :
   --    IN              : p_api_version         IN NUMBER       Required
   --                      p_init_msg_list       IN VARCHAR2     Optional
   --                        Default = FND_API.G_FALSE
   --                      p_commit              IN VARCHAR2     Optional
   --                        Default = FND_API.G_FALSE
   --                      p_validation_level    IN NUMBER       Optional
   --                        Default = FND_API.G_VALID_LEVEL_FULL
   --                      p_trx_factor        IN  trx_factor_rec_type
   --    OUT             : x_return_status       OUT     VARCHAR2(1)
   --                      x_msg_count           OUT     NUMBER
   --                      x_msg_data            OUT     VARCHAR2(2000)
   --                      x_trx_factor_id        OUT     NUMBER
   --    Version :         Current version       1.0
   --    Notes           : Note text
   --
   -- End of comments
   PROCEDURE validate_trx_factor (
      p_api_version              IN       NUMBER,
      p_init_msg_list            IN       VARCHAR2 := fnd_api.g_false,
      p_commit                   IN       VARCHAR2 := fnd_api.g_false,
      p_validation_level         IN       NUMBER := fnd_api.g_valid_level_full,
      p_action                   IN       VARCHAR2,
      p_trx_factor               IN OUT NOCOPY trx_factor_rec_type,
      p_old_trx_factor           IN       trx_factor_rec_type := g_miss_trx_factor_rec,
      x_return_status            OUT NOCOPY VARCHAR2,
      x_msg_count                OUT NOCOPY NUMBER,
      x_msg_data                 OUT NOCOPY VARCHAR2
   )
   IS
      l_api_name           CONSTANT VARCHAR2 (30) := 'validate_trx_factor';
      l_api_version        CONSTANT NUMBER := 1.0;
      l_temp_count                  NUMBER;
      l_trx_name                    VARCHAR2 (80);
   BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT validate_trx_factor;

      -- Standard call to check for call compatibility.
      IF NOT fnd_api.compatible_api_call (l_api_version, p_api_version, l_api_name, g_pkg_name)
      THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF fnd_api.to_boolean (p_init_msg_list)
      THEN
         fnd_msg_pub.initialize;
      END IF;

      --  Initialize API return status to success
      x_return_status := fnd_api.g_ret_sts_success;

      -- 1. name can not be null
      IF (p_trx_factor.trx_type IS NOT NULL)
      THEN
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
         THEN
            BEGIN
               --clku bug 2376751
               SELECT meaning
                 INTO l_trx_name
                 FROM cn_lookups
                WHERE lookup_type = 'TRX TYPES' AND lookup_code = p_trx_factor.trx_type;
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  fnd_message.set_name ('CN', 'CN_TRX_TYPE_NOT_EXISTS');
                  fnd_message.set_token ('TRANSACTION_TYPE', p_trx_factor.trx_type);
                  fnd_msg_pub.ADD;
                  RAISE fnd_api.g_exc_error;
            END;
         END IF;
      ELSE
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
         THEN
             IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
             THEN
                fnd_message.set_name ('CN', 'CN_INPUT_CANT_NULL');
                fnd_message.set_token ('INPUT_NAME',cn_api.get_lkup_meaning ('TRX_TYPE', 'PE_OBJECT_TYPE'));
                fnd_msg_pub.ADD;
             END IF;
         END IF ;
         RAISE fnd_api.g_exc_error;
      END IF;

      IF p_trx_factor.event_factor IS NULL
      THEN
           IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
           THEN
                fnd_message.set_name ('CN', 'CN_INPUT_CANT_NULL');
                fnd_message.set_token ('INPUT_NAME',cn_api.get_lkup_meaning ('EVENT_FACTOR', 'PE_OBJECT_TYPE'));
                fnd_msg_pub.ADD;
           END IF;
           RAISE fnd_api.g_exc_error;
      END IF ;

      IF p_trx_factor.quota_id IS NULL
      THEN
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
         THEN
            fnd_message.set_name ('CN', 'CN_INVALID_DATA');
            fnd_message.set_token ('OBJ_NAME', NVL (cn_api.get_lkup_meaning ('PE', 'INPUT_TOKEN'), 'PE'));
            fnd_msg_pub.ADD;
         END IF;

         RAISE fnd_api.g_exc_error;
      END IF;

      IF p_trx_factor.revenue_class_id IS NULL
      THEN
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
         THEN
            fnd_message.set_name ('CN', 'CN_REV_CLASS_NOT_ASSIGNED');
            fnd_msg_pub.ADD;
         END IF;
         RAISE fnd_api.g_exc_error;
      END IF;

      IF p_trx_factor.quota_rule_id IS NULL
      THEN
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
         THEN
            fnd_message.set_name ('CN', 'CN_QUOTA_RULE_NOT_EXIST');
            fnd_msg_pub.ADD;
         END IF;

         RAISE fnd_api.g_exc_error;
      END IF;

      IF p_action = 'UPDATE'
      THEN
         IF p_trx_factor.trx_type <> p_old_trx_factor.trx_type
         THEN
            IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
            THEN
               fnd_message.set_name ('CN', 'CN_FIELD_NOT_UPDATABLE');
               fnd_message.set_token ('FIELD_NAME', NVL (cn_api.get_lkup_meaning ('TRX_TYPE', 'PE_OBJECT_TYPE'), 'TRX_TYPE'));
               fnd_msg_pub.ADD;
            END IF;

            RAISE fnd_api.g_exc_error;
         END IF;

         IF p_trx_factor.quota_id <> p_old_trx_factor.quota_id
         THEN
            IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
            THEN
               fnd_message.set_name ('CN', 'CN_FIELD_NOT_UPDATABLE');
               fnd_message.set_token ('FIELD_NAME', NVL (cn_api.get_lkup_meaning ('PE', 'INPUT_TOKEN'), 'PE'));
               fnd_msg_pub.ADD;
            END IF;

            RAISE fnd_api.g_exc_error;
         END IF;

         IF p_trx_factor.quota_rule_id <> p_old_trx_factor.quota_rule_id
         THEN
            IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
            THEN
               fnd_message.set_name ('CN', 'CN_FIELD_NOT_UPDATABLE');
               fnd_message.set_token ('FIELD_NAME', NVL (cn_api.get_lkup_meaning ('RC_ASSIGN', 'PE_OBJECT_TYPE'), 'RC_ASSIGN'));
               fnd_msg_pub.ADD;
            END IF;

            RAISE fnd_api.g_exc_error;
         END IF;

         IF p_trx_factor.revenue_class_id <> p_old_trx_factor.revenue_class_id
         THEN
            IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
            THEN
               fnd_message.set_name ('CN', 'CN_FIELD_NOT_UPDATABLE');
               fnd_message.set_token ('FIELD_NAME', NVL (cn_api.get_lkup_meaning ('RC', 'INPUT_TOKEN'), 'TRX_TYPE'));
               fnd_msg_pub.ADD;
            END IF;

            RAISE fnd_api.g_exc_error;
         END IF;
      END IF;

      SELECT COUNT (*)
        INTO l_temp_count
        FROM cn_trx_factors
       WHERE revenue_class_id = p_trx_factor.revenue_class_id
         AND quota_id = p_trx_factor.quota_id
         AND quota_rule_id = p_trx_factor.quota_rule_id
         AND trx_type = p_trx_factor.trx_type
         AND trx_factor_id = p_trx_factor.trx_factor_id;

      IF l_temp_count < 1
      THEN
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
         THEN
            fnd_message.set_name ('CN', 'CN_INCONSISTENT_DATA');
            fnd_message.set_token ('INPUT1', cn_api.get_lkup_meaning ('RC', 'INPUT_TOKEN'));
            fnd_message.set_token ('INPUT2', cn_api.get_lkup_meaning ('PE', 'INPUT_TOKEN'));
            fnd_message.set_token ('INPUT3', cn_api.get_lkup_meaning ('RC_ASSIGN', 'PE_OBJECT_TYPE'));
            fnd_message.set_token ('INPUT4', cn_api.get_lkup_meaning ('TRX_TYPE', 'PE_OBJECT_TYPE'));
            fnd_message.set_token ('INPUT5', ' ');
            fnd_msg_pub.ADD;
         END IF;

         RAISE fnd_api.g_exc_error;
      END IF;

      -- 2. trx type must be unique
      SELECT COUNT (1)
        INTO l_temp_count
        FROM cn_trx_factors
       WHERE quota_rule_id = p_trx_factor.quota_rule_id
         AND trx_type = p_trx_factor.trx_type
         AND trx_factor_id <> p_trx_factor.trx_factor_id
         AND ROWNUM = 1;

      IF l_temp_count <> 0
      THEN
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
         THEN
            fnd_message.set_name ('CN', 'CN_INPUT_MUST_UNIQUE');
            fnd_msg_pub.ADD;
         END IF;

         RAISE fnd_api.g_exc_error;
      END IF;

      --DBMS_OUTPUT.PUT_LINE('OrgId:'||p_trx_factor.org_id||'|'||p_trx_factor.quota_id) ;
      IF NOT cn_plan_element_pvt.is_valid_org(p_trx_factor.org_id, p_trx_factor.quota_id)
      THEN
          RAISE fnd_api.g_exc_error;
      END IF ;

      -- 1. check object version number
      IF p_old_trx_factor.object_version_number <> NVL (p_trx_factor.object_version_number, -1)
      THEN
         fnd_message.set_name ('CN', 'CN_RECORD_CHANGED');
         fnd_msg_pub.ADD;
         RAISE fnd_api.g_exc_error;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
   EXCEPTION
      WHEN fnd_api.g_exc_error
      THEN
         ROLLBACK TO validate_trx_factor;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         ROLLBACK TO validate_trx_factor;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
      WHEN OTHERS
      THEN
         ROLLBACK TO validate_trx_factor;
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
   END validate_trx_factor;

 -- Start of comments
--      API name        : Update_Trx_Factor
--      Type            : Private.
--      Function        :
--      Pre-reqs        : None.
--      Parameters      :
--      IN              : p_api_version       IN NUMBER       Required
--                        p_init_msg_list     IN VARCHAR2     Optional
--                          Default = FND_API.G_FALSE
--                        p_commit            IN VARCHAR2     Optional
--                          Default = FND_API.G_FALSE
--                        p_validation_level  IN NUMBER       Optional
--                          Default = FND_API.G_VALID_LEVEL_FULL
--                        p_trx_factor         IN trx_factor_rec_type
--      OUT             : x_return_status     OUT     VARCHAR2(1)
--                        x_msg_count         OUT     NUMBER
--                        x_msg_data          OUT     VARCHAR2(2000)
--      Version :         Current version     1.0
--      Notes           : Note text
--
-- End of comments
   PROCEDURE update_trx_factor (
      p_api_version              IN       NUMBER,
      p_init_msg_list            IN       VARCHAR2 := fnd_api.g_false,
      p_commit                   IN       VARCHAR2 := fnd_api.g_false,
      p_validation_level         IN       NUMBER := fnd_api.g_valid_level_full,
      p_trx_factor               IN OUT NOCOPY trx_factor_rec_type,
      x_return_status            OUT NOCOPY VARCHAR2,
      x_msg_count                OUT NOCOPY NUMBER,
      x_msg_data                 OUT NOCOPY VARCHAR2
   )
   IS
      l_api_name           CONSTANT VARCHAR2 (30) := 'Update_Trx_Factor';
      l_api_version        CONSTANT NUMBER := 1.0;

      CURSOR trx_factor_csr (
         factor_id                           NUMBER
      )
      IS
         SELECT *
           FROM cn_trx_factors
          WHERE trx_factor_id = factor_id;

      l_old_trx_factor              trx_factor_csr%ROWTYPE;
      l_old_rec                     trx_factor_rec_type;
      l_temp_count                  NUMBER;
      l_quota_rule_id               NUMBER;
      l_quota_name                  cn_quotas.NAME%TYPE;
      l_loading_status              VARCHAR2 (1000);
      --clku bug 2376751
      l_row_id                      NUMBER;
      g_last_update_date            DATE := SYSDATE;
      g_last_updated_by             NUMBER := fnd_global.user_id;
      g_creation_date               DATE := SYSDATE;
      g_created_by                  NUMBER := fnd_global.user_id;
      g_last_update_login           NUMBER := fnd_global.login_id;
      l_rev_class_name              cn_revenue_classes.NAME%TYPE;
      l_factor_name                 VARCHAR2(200);
      l_note_msg                    VARCHAR2 (2000);
      l_note_id                     NUMBER;
   BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT update_trx_factor;

      -- Standard call to check for call compatibility.
      IF NOT fnd_api.compatible_api_call (l_api_version, p_api_version, l_api_name, g_pkg_name)
      THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF fnd_api.to_boolean (p_init_msg_list)
      THEN
         fnd_msg_pub.initialize;
      END IF;

      --  Initialize API return status to success
      x_return_status := fnd_api.g_ret_sts_success;

      OPEN trx_factor_csr (p_trx_factor.trx_factor_id);

      FETCH trx_factor_csr
       INTO l_old_trx_factor;

      IF trx_factor_csr%NOTFOUND
      THEN
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
         THEN
            fnd_message.set_name ('CN', 'CN_INVALID_DATA');
            fnd_message.set_token ('OBJ_NAME', NVL (cn_api.get_lkup_meaning ('TRX_FACTOR', 'PE_OBJECT_TYPE'), 'TRX_FACTOR'));
            fnd_msg_pub.ADD;
         END IF;

         RAISE fnd_api.g_exc_error;
      END IF;

      CLOSE trx_factor_csr;

      -- get the old rec
      l_old_rec.trx_factor_id := l_old_trx_factor.trx_factor_id;
      l_old_rec.revenue_class_id := l_old_trx_factor.revenue_class_id;
      l_old_rec.quota_id := l_old_trx_factor.quota_id;
      l_old_rec.quota_rule_id := l_old_trx_factor.quota_rule_id;
      l_old_rec.event_factor := l_old_trx_factor.event_factor;
      l_old_rec.trx_type := l_old_trx_factor.trx_type;
      l_old_rec.object_version_number := l_old_trx_factor.object_version_number;
      -- validate the trx factor
      validate_trx_factor (p_api_version           => l_api_version,
                           p_init_msg_list         => p_init_msg_list,
                           p_commit                => p_commit,
                           p_validation_level      => p_validation_level,
                           p_action                => 'UPDATE',
                           p_trx_factor            => p_trx_factor,
                           p_old_trx_factor        => l_old_rec,
                           x_return_status         => x_return_status,
                           x_msg_count             => x_msg_count,
                           x_msg_data              => x_msg_data
                          );

      IF (x_return_status <> fnd_api.g_ret_sts_success)
      THEN
         RAISE fnd_api.g_exc_error;
      END IF;

      -- update the record
      -- org_id depends on the plan elements org_id
      cn_trx_factors_pkg.begin_record (x_operation                  => 'UPDATE',
                                       x_rowid                      => l_row_id,
                                       x_trx_factor_id              => p_trx_factor.trx_factor_id,
                                       x_object_version_number      => p_trx_factor.object_version_number,
                                       x_event_factor               => p_trx_factor.event_factor,
                                       x_event_factor_old           => l_old_trx_factor.event_factor,
                                       x_revenue_class_id           => p_trx_factor.revenue_class_id,
                                       x_last_update_date           => g_last_update_date,
                                       x_last_updated_by            => g_last_updated_by,
                                       x_creation_date              => l_old_trx_factor.creation_date,
                                       x_created_by                 => l_old_trx_factor.created_by,
                                       x_last_update_login          => g_last_update_login,
                                       x_quota_id                   => p_trx_factor.quota_id,
                                       x_quota_rule_id              => p_trx_factor.quota_rule_id,
                                       x_trx_type                   => p_trx_factor.trx_type,
                                       x_trx_type_name              => NULL,
                                       x_program_type               => NULL,
                                       x_status_code                => NULL,
                                       x_org_id                     => NULL
                                      );

        --GENERATE NOTE FOR THE UPDATE
        IF (l_old_rec.event_factor <> p_trx_factor.event_factor) THEN
         --Get Revenue Class Name
         select NAME into l_rev_class_name from cn_revenue_classes
         where REVENUE_CLASS_ID = p_trx_factor.revenue_class_id
         and org_id = p_trx_factor.org_id;
         --Get Factor Name
         l_factor_name := cn_api.get_lkup_meaning(p_trx_factor.trx_type, 'TRX TYPES');
         --Start Creating the note
         fnd_message.set_name ('CN', 'CNR12_NOTE_COMPPLAN_ASPE_DEL');
         fnd_message.set_token('PROD', l_rev_class_name);
         fnd_message.set_token('FACTOR_TYPE', l_factor_name);
         fnd_message.set_token('OLD_FACTOR', l_old_rec.event_factor);
         fnd_message.set_token('NEW_FACTOR', p_trx_factor.event_factor);

         l_note_msg := fnd_message.get;
         jtf_notes_pub.create_note
                    (p_api_version             => 1.0,
                     x_return_status           => x_return_status,
                     x_msg_count               => x_msg_count,
                     x_msg_data                => x_msg_data,
                     p_source_object_id        => p_trx_factor.quota_id,
                     p_source_object_code      => 'CN_QUOTAS',
                     p_notes                   => l_note_msg,
                     p_notes_detail            => l_note_msg,
                     p_note_type               => 'CN_SYSGEN', -- for system generated
                     x_jtf_note_id             => l_note_id    -- returned
                     );
        END IF;

        IF (x_return_status <> fnd_api.g_ret_sts_success)
        THEN
          RAISE fnd_api.g_exc_error;
        END IF;

      -- End of API body.
      -- Standard check of p_commit.
      IF fnd_api.to_boolean (p_commit)
      THEN
         COMMIT WORK;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
   EXCEPTION
      WHEN fnd_api.g_exc_error
      THEN
         ROLLBACK TO update_trx_factor;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         ROLLBACK TO update_trx_factor;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
      WHEN OTHERS
      THEN
         ROLLBACK TO update_trx_factor;
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
   END update_trx_factor;

   -- Start of comments
   --    API name        : update_trx_factors
   --    Type            : Private.
   --    Function        :
   --    Pre-reqs        : None.
   --    Parameters      :
   --    IN              : p_api_version         IN NUMBER       Required
   --                      p_init_msg_list       IN VARCHAR2     Optional
   --                        Default = FND_API.G_FALSE
   --                      p_commit              IN VARCHAR2     Optional
   --                        Default = FND_API.G_FALSE
   --                      p_validation_level    IN NUMBER       Optional
   --                        Default = FND_API.G_VALID_LEVEL_FULL
   --                      p_trx_factor        IN  trx_factor_rec_type
   --    OUT             : x_return_status       OUT     VARCHAR2(1)
   --                      x_msg_count           OUT     NUMBER
   --                      x_msg_data            OUT     VARCHAR2(2000)
   --                      x_trx_factor_id        OUT     NUMBER
   --    Version :         Current version       1.0
   --    Notes           : Note text
   --
   -- End of comments
   PROCEDURE update_trx_factors (
      p_api_version              IN       NUMBER,
      p_init_msg_list            IN       VARCHAR2 := fnd_api.g_false,
      p_commit                   IN       VARCHAR2 := fnd_api.g_false,
      p_validation_level         IN       NUMBER := fnd_api.g_valid_level_full,
      p_org_id                   IN       NUMBER,
      p_quota_name               IN       VARCHAR2,
      p_revenue_class_name       IN       VARCHAR2 := NULL,
      p_trx_factor_rec_tbl       IN       cn_plan_element_pub.trx_factor_rec_tbl_type,
      x_return_status            OUT NOCOPY VARCHAR2,
      x_msg_count                OUT NOCOPY NUMBER,
      x_msg_data                 OUT NOCOPY VARCHAR2,
      x_loading_status           OUT NOCOPY VARCHAR2
   )
   IS
      l_api_name           CONSTANT VARCHAR2 (30) := 'Update_Trx_Factors';
      l_api_version        CONSTANT NUMBER := 1.0;
      l_quota_id                    NUMBER;
      l_quota_rule_id               NUMBER;
      l_rev_class_id                NUMBER;
      l_rev_class_name              cn_revenue_classes.NAME%TYPE;
      l_trx_factor_rec              cn_trx_factor_pvt.trx_factor_rec_type;
      l_loading_status              VARCHAR2 (80);
      l_rev_class_names_array       jtf_varchar2_table_4000;
   BEGIN
      --
      -- Standard Start of API savepoint
      -- +
      SAVEPOINT update_trx_factors;

      --+
      -- Standard call to check for call compatibility.
      --+
      IF NOT fnd_api.compatible_api_call (l_api_version, p_api_version, l_api_name, g_pkg_name)
      THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      --+
      -- Initialize message list if p_init_msg_list is set to TRUE.
      -- +
      IF fnd_api.to_boolean (p_init_msg_list)
      THEN
         fnd_msg_pub.initialize;
      END IF;

      -- +
      --  Initialize API return status to success
      --+
      x_return_status := fnd_api.g_ret_sts_success;

      IF p_trx_factor_rec_tbl.COUNT > 0
      THEN
         -- API body
         -- Store the User Input Value into The Local Variable.
         -- Standard check of p_commit.
         --+
         -- Check if plan element name is missing or null even for Delete the Q Rule
         IF ((cn_api.chk_miss_char_para (p_char_para           => p_quota_name,
                                         p_para_name           => cn_chk_plan_element_pkg.g_pe_name,
                                         p_loading_status      => x_loading_status,
                                         x_loading_status      => l_loading_status
                                        )
             ) = fnd_api.g_true
            )
         THEN
            RAISE fnd_api.g_exc_error;
         ELSIF ((cn_api.chk_null_char_para (p_char_para           => p_quota_name,
                                            p_obj_name            => cn_chk_plan_element_pkg.g_pe_name,
                                            p_loading_status      => x_loading_status,
                                            x_loading_status      => l_loading_status
                                           )
                ) = fnd_api.g_true
               )
         THEN
            RAISE fnd_api.g_exc_error;
         END IF;

         -- Get the Quota ID
         l_quota_id := cn_chk_plan_element_pkg.get_quota_id (LTRIM (RTRIM (p_quota_name)), p_org_id);

         -- Raise an Error If quota id is null but name is not null
         IF l_quota_id IS NULL AND p_quota_name IS NOT NULL
         THEN
            IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
            THEN
               fnd_message.set_name ('CN', 'CN_PLN_NOT_EXIST');
               fnd_message.set_token ('PE_NAME', p_quota_name);
               fnd_msg_pub.ADD;
            END IF;

            x_loading_status := 'CN_PLN_NOT_EXIST';
            RAISE fnd_api.g_exc_error;
         END IF;

         -- if revenue class is not given, check for all
         IF p_revenue_class_name IS NULL
         THEN
            SELECT rc.NAME AS revenue_class_name
            BULK COLLECT INTO l_rev_class_names_array
              FROM cn_quota_rules qr,
                   cn_revenue_classes rc
             WHERE qr.quota_id = l_quota_id AND qr.revenue_class_id = rc.revenue_class_id;
         ELSE
            l_rev_class_names_array := jtf_varchar2_table_4000 (p_revenue_class_name);
         END IF;

         FOR i IN l_rev_class_names_array.FIRST .. l_rev_class_names_array.LAST
         LOOP
            l_rev_class_name := RTRIM (LTRIM (l_rev_class_names_array (i)));
-------------------------------------------------------
-- Check and Fetch values of the rev class assignment
-- whose trx factors will be updated
--------------------------------------------------------
            check_valid_quotas (x_return_status       => x_return_status,
                                x_msg_count           => x_msg_count,
                                x_msg_data            => x_msg_data,
                                p_quota_name          => p_quota_name,
                                p_rev_class_name      => l_rev_class_name,
                                x_quota_id            => l_quota_id,
                                x_quota_rule_id       => l_quota_rule_id,
                                x_rev_class_id        => l_rev_class_id,
                                p_loading_status      => x_loading_status,
                                x_loading_status      => l_loading_status,
                                p_org_id              => p_org_id
                               );

            FOR i IN p_trx_factor_rec_tbl.FIRST .. p_trx_factor_rec_tbl.LAST
            LOOP
               -- fetching using the names because we dont have an id.
               l_trx_factor_rec.revenue_class_id := l_rev_class_id;
               l_trx_factor_rec.quota_id := l_quota_id;
               l_trx_factor_rec.quota_rule_id := l_quota_rule_id;
               l_trx_factor_rec.event_factor := p_trx_factor_rec_tbl (i).event_factor;
               l_trx_factor_rec.trx_type := p_trx_factor_rec_tbl (i).trx_type;

               BEGIN
                  SELECT trx_factor_id,
                         object_version_number
                    INTO l_trx_factor_rec.trx_factor_id,
                         l_trx_factor_rec.object_version_number
                    FROM cn_trx_factors
                   WHERE quota_rule_id = l_trx_factor_rec.quota_rule_id
                     AND trx_type = l_trx_factor_rec.trx_type
                     AND quota_id = l_trx_factor_rec.quota_id
                     AND revenue_class_id = l_trx_factor_rec.revenue_class_id;
               EXCEPTION
                  WHEN NO_DATA_FOUND
                  THEN
                     IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
                     THEN
                        fnd_message.set_name ('CN', 'CN_INVALID_DATA');
                        fnd_message.set_token ('OBJ_NAME', NVL (cn_api.get_lkup_meaning ('TRX_FACTOR', 'PE_OBJECT_TYPE'), 'TRX_FACTOR'));
                        fnd_msg_pub.ADD;
                     END IF;

                     RAISE fnd_api.g_exc_error;
               END;

               IF RTRIM (LTRIM (p_trx_factor_rec_tbl (i).rev_class_name)) = l_rev_class_name
               THEN
                  update_trx_factor (p_api_version           => l_api_version,
                                     p_init_msg_list         => p_init_msg_list,
                                     p_commit                => p_commit,
                                     p_validation_level      => p_validation_level,
                                     p_trx_factor            => l_trx_factor_rec,
                                     x_return_status         => x_return_status,
                                     x_msg_count             => x_msg_count,
                                     x_msg_data              => x_msg_data
                                    );

                  IF (x_return_status <> fnd_api.g_ret_sts_success)
                  THEN
                     RAISE fnd_api.g_exc_error;
                  END IF;
               ELSE
                  fnd_message.set_name ('CN', 'CN_INCONSISTENT_REV_CLASS');
                  fnd_msg_pub.ADD;
                  RAISE fnd_api.g_exc_error;
               END IF;
            END LOOP;

            cn_chk_plan_element_pkg.chk_trx_factor (x_return_status       => x_return_status,
                                                    p_quota_rule_id       => l_quota_rule_id,
                                                    p_rev_class_name      => l_rev_class_name,
                                                    p_loading_status      => x_loading_status,
                                                    x_loading_status      => l_loading_status
                                                   );
            x_loading_status := l_loading_status;

            IF (x_return_status <> fnd_api.g_ret_sts_success)
            THEN
               RAISE fnd_api.g_exc_error;
            END IF;
         END LOOP;
      END IF;

      -- End of API body.
      -- Standard check of p_commit.
      --+
      IF fnd_api.to_boolean (p_commit)
      THEN
         COMMIT WORK;
      END IF;

      --+
      -- Standard call to get message count and if count is 1, get message info.
      --+
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
   EXCEPTION
      WHEN fnd_api.g_exc_error
      THEN
         ROLLBACK TO update_trx_factors;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         ROLLBACK TO update_trx_factors;
         x_loading_status := 'UNEXPECTED_ERR';
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
      WHEN OTHERS
      THEN
         ROLLBACK TO update_trx_factors;
         x_loading_status := 'UNEXPECTED_ERR';
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
   END update_trx_factors;

-- Start of comments
--      API name        : Delete_Trx_Factor
--      Type            : Private.
--      Function        :
--      Pre-reqs        : None.
--      Parameters      :
--      IN              : p_api_version       IN NUMBER       Required
--                        p_init_msg_list     IN VARCHAR2     Optional
--                          Default = FND_API.G_FALSE
--                        p_commit            IN VARCHAR2     Optional
--                          Default = FND_API.G_FALSE
--                        p_validation_level  IN NUMBER       Optional
--                          Default = FND_API.G_VALID_LEVEL_FULL
--                        p_trx_factor         IN trx_factor_rec_type
--      OUT             : x_return_status     OUT     VARCHAR2(1)
--                        x_msg_count         OUT     NUMBER
--                        x_msg_data          OUT     VARCHAR2(2000)
--      Version :         Current version     1.0
--      Notes           : Note text
--
-- End of comments
   PROCEDURE delete_trx_factor (
      p_api_version              IN       NUMBER,
      p_init_msg_list            IN       VARCHAR2 := fnd_api.g_false,
      p_commit                   IN       VARCHAR2 := fnd_api.g_false,
      p_validation_level         IN       NUMBER := fnd_api.g_valid_level_full,
      p_trx_factor               IN OUT NOCOPY trx_factor_rec_type,
      x_return_status            OUT NOCOPY VARCHAR2,
      x_msg_count                OUT NOCOPY NUMBER,
      x_msg_data                 OUT NOCOPY VARCHAR2
   )
   IS
      l_api_name           CONSTANT VARCHAR2 (30) := 'Delete_Trx_Factor';
      l_api_version        CONSTANT NUMBER := 1.0;
      l_temp_count                  NUMBER;
   BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT delete_trx_factor;

      -- Standard call to check for call compatibility.
      IF NOT fnd_api.compatible_api_call (l_api_version, p_api_version, l_api_name, g_pkg_name)
      THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF fnd_api.to_boolean (p_init_msg_list)
      THEN
         fnd_msg_pub.initialize;
      END IF;

      --  Initialize API return status to success
      x_return_status := fnd_api.g_ret_sts_success;
      -- API body

      -- This will never be used
      RAISE fnd_api.g_exc_unexpected_error;

      -- End of API body.
      -- Standard check of p_commit.
      IF fnd_api.to_boolean (p_commit)
      THEN
         COMMIT WORK;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
   EXCEPTION
      WHEN fnd_api.g_exc_error
      THEN
         ROLLBACK TO delete_trx_factor;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         ROLLBACK TO delete_trx_factor;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
      WHEN OTHERS
      THEN
         ROLLBACK TO delete_trx_factor;
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
   END delete_trx_factor;

-- Start of comments
--      API name        : Get_Trx_Factor
--      Type            : Private.
--      Function        :
--      Pre-reqs        : None.
--      Parameters      :
--      IN              : p_api_version       IN NUMBER       Required
--                        p_init_msg_list     IN VARCHAR2     Optional
--                          Default = FND_API.G_FALSE
--                        p_commit            IN VARCHAR2     Optional
--                          Default = FND_API.G_FALSE
--                        p_validation_level  IN NUMBER       Optional
--                          Default = FND_API.G_VALID_LEVEL_FULL
--                        p_quota_rule_id      IN NUMBER
--      OUT             : x_return_status     OUT     VARCHAR2(1)
--                        x_msg_count         OUT     NUMBER
--                        x_msg_data          OUT     VARCHAR2(2000)
--                        x_trx_factor         OUT     trx_factor_tbl_type
--      Version :         Current version     1.0
--      Notes           : Note text
--
-- End of comments
   PROCEDURE get_trx_factor (
      p_api_version              IN       NUMBER,
      p_init_msg_list            IN       VARCHAR2 := fnd_api.g_false,
      p_commit                   IN       VARCHAR2 := fnd_api.g_false,
      p_validation_level         IN       NUMBER := fnd_api.g_valid_level_full,
      p_quota_rule_id            IN       NUMBER,
      x_trx_factor               OUT NOCOPY trx_factor_tbl_type,
      x_return_status            OUT NOCOPY VARCHAR2,
      x_msg_count                OUT NOCOPY NUMBER,
      x_msg_data                 OUT NOCOPY VARCHAR2
   )
   IS
      l_api_name           CONSTANT VARCHAR2 (30) := 'Get_Trx_Factor';
      l_api_version        CONSTANT NUMBER := 1.0;

      CURSOR l_trx_factor_cr
      IS
         SELECT *
           FROM cn_trx_factors
          WHERE quota_rule_id = p_quota_rule_id;

      l_counter                     NUMBER;
   BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT get_trx_factor;

      -- Standard call to check for call compatibility.
      IF NOT fnd_api.compatible_api_call (l_api_version, p_api_version, l_api_name, g_pkg_name)
      THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF fnd_api.to_boolean (p_init_msg_list)
      THEN
         fnd_msg_pub.initialize;
      END IF;

      --  Initialize API return status to success
      x_return_status := fnd_api.g_ret_sts_success;
      -- API body
      x_trx_factor := g_miss_trx_factor_rec_tb;
      l_counter := 0;

      FOR l_trx_factor IN l_trx_factor_cr
      LOOP
         l_counter := l_counter + 1;
         x_trx_factor (l_counter).trx_factor_id := l_trx_factor.trx_factor_id;
         x_trx_factor (l_counter).revenue_class_id := l_trx_factor.revenue_class_id;
         x_trx_factor (l_counter).quota_id := l_trx_factor.quota_id;
         x_trx_factor (l_counter).quota_rule_id := l_trx_factor.quota_rule_id;
         x_trx_factor (l_counter).event_factor := l_trx_factor.event_factor;
         x_trx_factor (l_counter).trx_type := l_trx_factor.trx_type;
         x_trx_factor (l_counter).object_version_number := l_trx_factor.object_version_number;
      END LOOP;

      -- End of API body.
      -- Standard check of p_commit.
      IF fnd_api.to_boolean (p_commit)
      THEN
         COMMIT WORK;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
   EXCEPTION
      WHEN fnd_api.g_exc_error
      THEN
         ROLLBACK TO get_trx_factor;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         ROLLBACK TO get_trx_factor;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
      WHEN OTHERS
      THEN
         ROLLBACK TO get_trx_factor;
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
   END get_trx_factor;
END cn_trx_factor_pvt;

/
