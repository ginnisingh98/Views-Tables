--------------------------------------------------------
--  DDL for Package Body CN_QUOTA_RULE_UPLIFT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_QUOTA_RULE_UPLIFT_PVT" AS
   /*$Header: cnvrlutb.pls 120.6 2006/05/17 00:28:59 chanthon ship $*/
   g_pkg_name           CONSTANT VARCHAR2 (30) := 'CN_QUOTA_RULE_UPLIFT_PVT';

-- -------------------------------------------------------------------------+-+
--| Procedure:   add_system_note
--| Description: Insert notes for the create, update and delete
--| operations.
--| Called From: Create_quota_rule, Update_quota_rule
--| Delete_quota_rule
-- -------------------------------------------------------------------------+-+
   PROCEDURE add_system_note(
      p_quota_rule_uplift        IN OUT NOCOPY quota_rule_uplift_rec_type,
      p_quota_id                 IN NUMBER,
      p_old_quota_rule_uplift    IN cn_quota_rule_uplifts%ROWTYPE,
      p_operation                IN VARCHAR2,
      x_return_status            OUT NOCOPY VARCHAR2,
      x_msg_count                OUT NOCOPY NUMBER,
      x_msg_data                 OUT NOCOPY VARCHAR2
   )
   IS

    l_note_msg VARCHAR2 (2000);
    l_plan_element_id NUMBER;
    l_note_id NUMBER;
    l_temp_old VARCHAR2 (200);
    l_temp_new VARCHAR2 (200);
    l_consolidated_note VARCHAR2(2000);

   BEGIN
     -- Initialize to success
     x_return_status := fnd_api.g_ret_sts_success;
     -- Initialize other fields
     x_msg_data := fnd_api.g_null_char;
     x_msg_count := fnd_api.g_null_num;
     IF (p_operation <> 'update') THEN
       IF (p_operation = 'create') THEN
         fnd_message.set_name('CN','CNR12_NOTE_PE_ELIGPROD_CREATE');
         fnd_message.set_token('PROD', p_quota_rule_uplift.rev_class_name);
         fnd_message.set_token('ST_DATE', p_quota_rule_uplift.start_date);
         fnd_message.set_token('ED_DATE', p_quota_rule_uplift.end_date);
         l_plan_element_id := p_quota_id;
         l_temp_new := 'CN_QUOTAS';
       END IF;
       IF (p_operation = 'delete') THEN
         fnd_message.set_name ('CN', 'CNR12_NOTE_PE_ELIG_EDATE_UPD');
         fnd_message.set_token('ELIGPROD', p_quota_rule_uplift.rev_class_name);
         fnd_message.set_token('ST_DATE', p_quota_rule_uplift.start_date);
         fnd_message.set_token('ED_DATE', p_quota_rule_uplift.end_date);
         l_plan_element_id := p_quota_id;
         l_temp_new := 'CN_QUOTAS';
       END IF;
       l_note_msg := fnd_message.get;
       jtf_notes_pub.create_note
                    (p_api_version             => 1.0,
                     x_return_status           => x_return_status,
                     x_msg_count               => x_msg_count,
                     x_msg_data                => x_msg_data,
                     p_source_object_id        => l_plan_element_id,
                     p_source_object_code      => l_temp_new,
                     p_notes                   => l_note_msg,
                     p_notes_detail            => l_note_msg,
                     p_note_type               => 'CN_SYSGEN', -- for system generated
                     x_jtf_note_id             => l_note_id    -- returned
                     );
     ELSE
        --DATE RANGE WAS CHANGED
        l_consolidated_note := '';
        IF (p_quota_rule_uplift.start_date <> p_quota_rule_uplift.start_date_old
            OR p_quota_rule_uplift.end_date <> p_quota_rule_uplift.end_date_old) THEN
         fnd_message.set_name ('CN', 'CNR12_NOTE_PE_ELIGPROD_UPDATE');
         fnd_message.set_token('PROD', p_quota_rule_uplift.rev_class_name);
         fnd_message.set_token('OLD_ST_DATE', p_quota_rule_uplift.start_date_old);
         fnd_message.set_token('OLD_ED_DATE', p_quota_rule_uplift.end_date_old);
         fnd_message.set_token('NEW_ST_DATE', p_quota_rule_uplift.start_date);
         fnd_message.set_token('NEW_ED_DATE', p_quota_rule_uplift.end_date);
         l_plan_element_id := p_quota_id;
         l_temp_new := 'CN_QUOTAS';

         l_note_msg := fnd_message.get;
         l_consolidated_note := l_note_msg || fnd_global.local_chr(10);
/*         jtf_notes_pub.create_note
                    (p_api_version             => 1.0,
                     x_return_status           => x_return_status,
                     x_msg_count               => x_msg_count,
                     x_msg_data                => x_msg_data,
                     p_source_object_id        => l_plan_element_id,
                     p_source_object_code      => l_temp_new,
                     p_notes                   => l_note_msg,
                     p_notes_detail            => l_note_msg,
                     p_note_type               => 'CN_SYSGEN', -- for system generated
                     x_jtf_note_id             => l_note_id    -- returned
                     );*/
        END IF;
        --MULTIPLIER WAS CHANGED
        IF (p_quota_rule_uplift.quota_factor <> p_old_quota_rule_uplift.quota_factor) THEN
         fnd_message.set_name ('CN', 'CNR12_NOTE_FORMULA_INT_UPD');
         fnd_message.set_token('PROD', p_quota_rule_uplift.rev_class_name);
         fnd_message.set_token('ST_DATE', p_quota_rule_uplift.start_date);
         fnd_message.set_token('ED_DATE', p_quota_rule_uplift.end_date);
         fnd_message.set_token('OLD_MULTI',p_old_quota_rule_uplift.quota_factor);
         fnd_message.set_token('NEW_MULTI',p_quota_rule_uplift.quota_factor );
         l_plan_element_id := p_quota_id;
         l_temp_new := 'CN_QUOTAS';

         l_note_msg := fnd_message.get;
         l_consolidated_note := l_consolidated_note || l_note_msg || fnd_global.local_chr(10);
/*         jtf_notes_pub.create_note
                    (p_api_version             => 1.0,
                     x_return_status           => x_return_status,
                     x_msg_count               => x_msg_count,
                     x_msg_data                => x_msg_data,
                     p_source_object_id        => l_plan_element_id,
                     p_source_object_code      => l_temp_new,
                     p_notes                   => l_note_msg,
                     p_notes_detail            => l_note_msg,
                     p_note_type               => 'CN_SYSGEN', -- for system generated
                     x_jtf_note_id             => l_note_id    -- returned
                     ); */
        END IF;
        --EARNINGS FACTOR WAS CHANGED
        IF (p_quota_rule_uplift.payment_factor <> p_old_quota_rule_uplift.payment_factor) THEN
         fnd_message.set_name ('CN', 'CNR12_NOTE_COMPPLAN_ASPE_CRE');
         fnd_message.set_token('ELIG', p_quota_rule_uplift.rev_class_name);
         fnd_message.set_token('ST_DATE', p_quota_rule_uplift.start_date);
         fnd_message.set_token('ED_DATE', p_quota_rule_uplift.end_date);
         fnd_message.set_token('OLD_FACTOR', p_old_quota_rule_uplift.payment_factor);
         fnd_message.set_token('NEW_FACTOR', p_quota_rule_uplift.payment_factor);
         l_plan_element_id := p_quota_id;
         l_temp_new := 'CN_QUOTAS';

         l_note_msg := fnd_message.get;
         l_consolidated_note := l_consolidated_note || l_note_msg || fnd_global.local_chr(10);
/*         jtf_notes_pub.create_note
                    (p_api_version             => 1.0,
                     x_return_status           => x_return_status,
                     x_msg_count               => x_msg_count,
                     x_msg_data                => x_msg_data,
                     p_source_object_id        => l_plan_element_id,
                     p_source_object_code      => l_temp_new,
                     p_notes                   => l_note_msg,
                     p_notes_detail            => l_note_msg,
                     p_note_type               => 'CN_SYSGEN', -- for system generated
                     x_jtf_note_id             => l_note_id    -- returned
                     );*/
        END IF;

        IF LENGTH(l_consolidated_note) > 1 THEN
         jtf_notes_pub.create_note (p_api_version          => 1.0,
	                           x_return_status           => x_return_status,
	                           x_msg_count               => x_msg_count,
	                           x_msg_data                => x_msg_data,
	                           p_source_object_id        => l_plan_element_id,
	                           p_source_object_code      => 'CN_QUOTAS',
	                           p_notes                   => l_consolidated_note,
	                           p_notes_detail            => l_consolidated_note,
	                           p_note_type               => 'CN_SYSGEN',                                                  -- for system generated
	                           x_jtf_note_id             => l_note_id                                                                 -- returned
                               );
        END IF;


     END IF;
     EXCEPTION
       WHEN fnd_api.g_exc_error
       THEN
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
       WHEN fnd_api.g_exc_unexpected_error
       THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
       WHEN OTHERS
       THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, 'add_system_note');
         END IF;
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);

   END add_system_note;



-- Start of comments
--      API name        : Delete_Quota_Rule_Uplift
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
--                        p_quota_rule_uplift IN quota_rule_uplift_rec_type
--      OUT             : x_return_status     OUT     VARCHAR2(1)
--                        x_msg_count         OUT     NUMBER
--                        x_msg_data          OUT     VARCHAR2(2000)
--      Version :         Current version     1.0
--      Notes           : Note text
--
-- End of comments
   PROCEDURE validate_uplift (
      p_api_version              IN       NUMBER,
      p_init_msg_list            IN       VARCHAR2 := fnd_api.g_false,
      p_commit                   IN       VARCHAR2 := fnd_api.g_false,
      p_validation_level         IN       NUMBER := fnd_api.g_valid_level_full,
      p_action                   IN       VARCHAR2,
      p_quota_rule_uplift        IN OUT NOCOPY quota_rule_uplift_rec_type,
      p_old_quota_rule_uplift    IN       quota_rule_uplift_rec_type := g_miss_quota_uplift_rec,
      x_return_status            OUT NOCOPY VARCHAR2,
      x_msg_count                OUT NOCOPY NUMBER,
      x_msg_data                 OUT NOCOPY VARCHAR2
   )
   IS
      l_api_name           CONSTANT VARCHAR2 (30) := 'validate_uplift';
      l_api_version        CONSTANT NUMBER := 1.0;
      l_temp_count                  NUMBER;
      l_loading_status              VARCHAR2 (240);
   BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT validate_uplift;

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

      -- if the Quota Rule uplift iD is null then Error message
      IF p_quota_rule_uplift.quota_rule_uplift_id IS NULL
      THEN
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
         THEN
            fnd_message.set_name ('CN', 'CN_INVALID_UPDATE_REC');
            fnd_msg_pub.ADD;
         END IF;

         RAISE fnd_api.g_exc_error;
      END IF;

      IF p_action = 'DELETE'
      THEN
         -- Check wheather delete is Allowed, this only first and last record can be deleted
         cn_chk_plan_element_pkg.chk_uplift_iud (x_return_status             => x_return_status,
                                                 p_start_date                => p_quota_rule_uplift.start_date,
                                                 p_end_date                  => p_quota_rule_uplift.end_date,
                                                 p_iud_flag                  => 'D',
                                                 p_quota_rule_id             => p_quota_rule_uplift.quota_rule_id,
                                                 p_quota_rule_uplift_id      => p_quota_rule_uplift.quota_rule_uplift_id,
                                                 p_loading_status            => l_loading_status,
                                                 x_loading_status            => l_loading_status
                                                );

         IF (x_return_status <> fnd_api.g_ret_sts_success)
         THEN
            IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
            THEN
               fnd_message.set_name ('CN', 'CN_UPLIFT_DELETE_NOT_ALLOWED');
               fnd_msg_pub.ADD;
            END IF;

            RAISE fnd_api.g_exc_error;
         END IF;
      END IF;

      -- API body
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
         ROLLBACK TO validate_uplift;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         ROLLBACK TO validate_uplift;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
      WHEN OTHERS
      THEN
         ROLLBACK TO validate_uplift;
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
   END validate_uplift;

-- Start of comments
--    API name        : Create_Quota_Uplift
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
--                      p_quota_rule_uplift   IN  quota_rule_uplift_rec_type
--    OUT             : x_return_status       OUT     VARCHAR2(1)
--                      x_msg_count           OUT     NUMBER
--                      x_msg_data            OUT     VARCHAR2(2000)
--                      x_quota_rule_uplift_id        OUT     NUMBER
--    Version :         Current version       1.0
--    Notes           : Note text
--
-- End of comments
   PROCEDURE create_uplift (
      p_api_version              IN       NUMBER,
      p_init_msg_list            IN       VARCHAR2 := fnd_api.g_false,
      p_commit                   IN       VARCHAR2 := fnd_api.g_false,
      p_validation_level         IN       NUMBER := fnd_api.g_valid_level_full,
      p_quota_rule_uplift        IN OUT NOCOPY quota_rule_uplift_rec_type,
      x_return_status            OUT NOCOPY VARCHAR2,
      x_msg_count                OUT NOCOPY NUMBER,
      x_msg_data                 OUT NOCOPY VARCHAR2
   )
   IS
      l_api_name           CONSTANT VARCHAR2 (30) := 'Create_Quota_Rule_Uplift';
      l_api_version        CONSTANT NUMBER := 1.0;
      l_temp_count                  NUMBER;
      l_loading_status              VARCHAR2 (50);
      l_rev_uplift_rec_tbl          quota_rule_uplift_tbl_type;
      l_quota_rule_id               NUMBER;
      l_quota_name                  cn_quotas.NAME%TYPE;
      l_start_date                  DATE;
      l_end_date                    DATE;
      l_null_date          CONSTANT DATE := TO_DATE ('31-12-9999', 'DD-MM-YYYY');
      l_quota_id                    NUMBER;
   BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT create_quota_rule_uplift;

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

      -- 1. name can not be null
      --clku
      IF (p_quota_rule_uplift.start_date IS NULL) OR (p_quota_rule_uplift.start_date = fnd_api.g_miss_date)
      THEN
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
         THEN
            fnd_message.set_name ('CN', 'CN_INPUT_CANT_NULL');
            fnd_message.set_token ('INPUT_NAME', cn_api.get_lkup_meaning ('SD', 'INPUT_TOKEN'));
            fnd_msg_pub.ADD;
         END IF;

         RAISE fnd_api.g_exc_error;
      END IF;

      -- 2. quota rule uplift name must be unique
      SELECT DECODE (p_quota_rule_uplift.quota_rule_id, fnd_api.g_miss_num, NULL, p_quota_rule_uplift.quota_rule_id),
             DECODE (p_quota_rule_uplift.start_date, fnd_api.g_miss_date, NULL, p_quota_rule_uplift.start_date),
             DECODE (p_quota_rule_uplift.end_date, fnd_api.g_miss_date, NULL, p_quota_rule_uplift.end_date),
             DECODE (p_quota_rule_uplift.payment_factor, NULL, 0, p_quota_rule_uplift.payment_factor),
             DECODE (p_quota_rule_uplift.quota_factor, NULL, 0, p_quota_rule_uplift.quota_factor),
             p_quota_rule_uplift.org_id,
             p_quota_rule_uplift.quota_rule_id
        INTO l_quota_rule_id,
             l_rev_uplift_rec_tbl (1).start_date,
             l_rev_uplift_rec_tbl (1).end_date,
             l_rev_uplift_rec_tbl (1).payment_factor,
             l_rev_uplift_rec_tbl (1).quota_factor,
             l_rev_uplift_rec_tbl (1).org_id,
             l_rev_uplift_rec_tbl (1).quota_rule_id
        FROM DUAL;

      SELECT q.start_date,
             NVL (q.end_date, l_null_date),
             q.quota_id
        INTO l_start_date,
             l_end_date,
             l_quota_id
        FROM cn_quotas q,
             cn_quota_rules qr
       WHERE qr.quota_rule_id = l_quota_rule_id AND q.quota_id = qr.quota_id;

      IF (l_rev_uplift_rec_tbl (1).start_date < l_start_date) OR (NVL (l_rev_uplift_rec_tbl (1).end_date, l_null_date) > l_end_date)
      THEN
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
         THEN
            fnd_message.set_name ('CN', 'CN_RC_INVALID_DATE_RANGE');
            fnd_msg_pub.ADD;
         END IF;

         RAISE fnd_api.g_exc_error;
      END IF;

      SELECT r.NAME,
             q.NAME
        INTO l_rev_uplift_rec_tbl (1).rev_class_name,
             l_quota_name
        FROM cn_revenue_classes r,
             cn_quotas q,
             cn_quota_rules qr
       WHERE qr.quota_rule_id = l_quota_rule_id AND r.revenue_class_id = qr.revenue_class_id AND q.quota_id = qr.quota_id;

      cn_quota_rule_uplifts_grp.create_quota_rule_uplift (p_api_version             => 1.0,
                                                          p_init_msg_list           => 'T',
                                                          p_commit                  => 'F',
                                                          p_validation_level        => 100,
                                                          x_return_status           => x_return_status,
                                                          x_msg_count               => x_msg_count,
                                                          x_msg_data                => x_msg_data,
                                                          p_quota_name              => l_quota_name,
                                                          p_rev_uplift_rec_tbl      => l_rev_uplift_rec_tbl,
                                                          x_loading_status          => l_loading_status
                                                         );
      -- repopulate variables
      p_quota_rule_uplift.org_id := l_rev_uplift_rec_tbl (1).org_id;
      p_quota_rule_uplift.quota_rule_uplift_id := l_rev_uplift_rec_tbl (1).quota_rule_uplift_id;
      p_quota_rule_uplift.quota_rule_id := l_rev_uplift_rec_tbl (1).quota_rule_id;
      p_quota_rule_uplift.start_date := l_rev_uplift_rec_tbl (1).start_date;
      p_quota_rule_uplift.end_date := l_rev_uplift_rec_tbl (1).end_date;
      p_quota_rule_uplift.payment_factor := l_rev_uplift_rec_tbl (1).payment_factor;
      p_quota_rule_uplift.quota_factor := l_rev_uplift_rec_tbl (1).quota_factor;
      p_quota_rule_uplift.object_version_number := l_rev_uplift_rec_tbl (1).object_version_number;
      p_quota_rule_uplift.rev_class_name := l_rev_uplift_rec_tbl (1).rev_class_name;
      p_quota_rule_uplift.rev_class_name_old := l_rev_uplift_rec_tbl (1).rev_class_name_old;
      p_quota_rule_uplift.start_date_old := l_rev_uplift_rec_tbl (1).start_date_old;
      p_quota_rule_uplift.end_date_old := l_rev_uplift_rec_tbl (1).end_date_old;

      IF (x_return_status <> fnd_api.g_ret_sts_success)
      THEN
         RAISE fnd_api.g_exc_error;
      END IF;

      -- Calling proc to add system note for create
      add_system_note(
            p_quota_rule_uplift,
            l_quota_id,
            null,
            'create',
            x_return_status,
            x_msg_count,
            x_msg_data
            );
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
         ROLLBACK TO create_quota_rule_uplift;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         ROLLBACK TO create_quota_rule_uplift;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
      WHEN OTHERS
      THEN
         ROLLBACK TO create_quota_rule_uplift;
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
   END create_uplift;

-- Start of comments
--      API name        : Update_Uplift
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
--                        p_quota_rule_uplift IN quota_rule_uplift_rec_type
--      OUT             : x_return_status     OUT     VARCHAR2(1)
--                        x_msg_count         OUT     NUMBER
--                        x_msg_data          OUT     VARCHAR2(2000)
--      Version :         Current version     1.0
--      Notes           : Note text
--
-- End of comments
   PROCEDURE update_uplift (
      p_api_version              IN       NUMBER,
      p_init_msg_list            IN       VARCHAR2 := fnd_api.g_false,
      p_commit                   IN       VARCHAR2 := fnd_api.g_false,
      p_validation_level         IN       NUMBER := fnd_api.g_valid_level_full,
      p_quota_rule_uplift        IN OUT NOCOPY quota_rule_uplift_rec_type,
      x_return_status            OUT NOCOPY VARCHAR2,
      x_msg_count                OUT NOCOPY NUMBER,
      x_msg_data                 OUT NOCOPY VARCHAR2
   )
   IS
      l_api_name           CONSTANT VARCHAR2 (30) := 'Update_Quota_Rule_Uplift';
      l_api_version        CONSTANT NUMBER := 1.0;

      CURSOR l_old_quota_rule_uplift_cr
      IS
         SELECT *
           FROM cn_quota_rule_uplifts
          WHERE quota_rule_uplift_id = p_quota_rule_uplift.quota_rule_uplift_id;

      l_old_quota_rule_uplift       l_old_quota_rule_uplift_cr%ROWTYPE;
      l_quota_rule_uplift           quota_rule_uplift_rec_type;
      l_temp_count                  NUMBER;
      l_loading_status              VARCHAR2 (50);
      l_rev_uplift_rec_tbl          quota_rule_uplift_tbl_type;
      l_quota_rule_id               NUMBER;
      l_quota_name                  cn_quotas.NAME%TYPE;
      l_start_date                  DATE;
      l_end_date                    DATE;
      l_null_date          CONSTANT DATE := TO_DATE ('31-12-9999', 'DD-MM-YYYY');
      l_quota_id                    NUMBER;
   BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT update_quota_rule_uplift;

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

      -- 1. name can not be null
      IF (p_quota_rule_uplift.start_date IS NULL)
      THEN
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
         THEN
            fnd_message.set_name ('CN', 'CN_INPUT_CANT_NULL');
            fnd_message.set_token ('INPUT_NAME', cn_api.get_lkup_meaning ('SD', 'INPUT_TOKEN'));
            fnd_msg_pub.ADD;
         END IF;

         RAISE fnd_api.g_exc_error;
      END IF;

      -- 2. trx type must be unique
      SELECT COUNT (1)
        INTO l_temp_count
        FROM cn_quota_rule_uplifts
       WHERE quota_rule_id = p_quota_rule_uplift.quota_rule_id
         AND TRUNC (start_date) = TRUNC (p_quota_rule_uplift.start_date)
         AND quota_rule_uplift_id <> p_quota_rule_uplift.quota_rule_uplift_id
         AND ROWNUM = 1;

      IF l_temp_count <> 0
      THEN
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
         THEN
            fnd_message.set_name ('CN', 'CN_INPUT_MUST_UNIQUE');
            fnd_message.set_token ('INPUT_NAME', cn_api.get_lkup_meaning ('SD', 'INPUT_TOKEN'));
            fnd_msg_pub.ADD;
         END IF;

         RAISE fnd_api.g_exc_error;
      END IF;

      OPEN l_old_quota_rule_uplift_cr;

      FETCH l_old_quota_rule_uplift_cr
       INTO l_old_quota_rule_uplift;

      CLOSE l_old_quota_rule_uplift_cr;

      SELECT DECODE (p_quota_rule_uplift.quota_rule_id, fnd_api.g_miss_num, l_old_quota_rule_uplift.quota_rule_id, p_quota_rule_uplift.quota_rule_id),
             DECODE (p_quota_rule_uplift.start_date, fnd_api.g_miss_date, l_old_quota_rule_uplift.start_date, p_quota_rule_uplift.start_date),
             DECODE (p_quota_rule_uplift.end_date, fnd_api.g_miss_date, l_old_quota_rule_uplift.end_date, p_quota_rule_uplift.end_date),
             DECODE (p_quota_rule_uplift.payment_factor, NULL, 0, p_quota_rule_uplift.payment_factor),
             DECODE (p_quota_rule_uplift.quota_factor, NULL, 0, p_quota_rule_uplift.quota_factor),
             l_old_quota_rule_uplift.start_date,
             l_old_quota_rule_uplift.end_date,
             l_old_quota_rule_uplift.org_id
        INTO l_rev_uplift_rec_tbl (1).quota_rule_id,
             l_rev_uplift_rec_tbl (1).start_date,
             l_rev_uplift_rec_tbl (1).end_date,
             l_rev_uplift_rec_tbl (1).payment_factor,
             l_rev_uplift_rec_tbl (1).quota_factor,
             l_rev_uplift_rec_tbl (1).start_date_old,
             l_rev_uplift_rec_tbl (1).end_date_old,
             l_rev_uplift_rec_tbl (1).org_id
        FROM DUAL;

      l_quota_rule_id := l_rev_uplift_rec_tbl (1).quota_rule_id;

      SELECT q.start_date,
             NVL (q.end_date, l_null_date),
             q.quota_id
        INTO l_start_date,
             l_end_date,
             l_quota_id
        FROM cn_quotas q,
             cn_quota_rules qr
       WHERE qr.quota_rule_id = l_quota_rule_id AND q.quota_id = qr.quota_id;

      IF l_old_quota_rule_uplift.object_version_number <> p_quota_rule_uplift.object_version_number
      THEN
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
         THEN

            fnd_message.set_name ('CN', 'CN_RECORD_CHANGED');
            fnd_msg_pub.ADD;
         END IF;

         RAISE fnd_api.g_exc_error;
      END IF;

      IF (l_rev_uplift_rec_tbl (1).start_date < l_start_date) OR (NVL (l_rev_uplift_rec_tbl (1).end_date, l_null_date) > l_end_date)
      THEN
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
         THEN
            fnd_message.set_name ('CN', 'CN_RC_INVALID_DATE_RANGE');
            fnd_msg_pub.ADD;
         END IF;

         RAISE fnd_api.g_exc_error;
      END IF;

      SELECT r.NAME,
             q.NAME
        INTO l_rev_uplift_rec_tbl (1).rev_class_name,
             l_quota_name
        FROM cn_revenue_classes r,
             cn_quotas q,
             cn_quota_rules qr
       WHERE qr.quota_rule_id = l_quota_rule_id AND r.revenue_class_id = qr.revenue_class_id AND q.quota_id = qr.quota_id;

      SELECT r.NAME
        INTO l_rev_uplift_rec_tbl (1).rev_class_name_old
        FROM cn_revenue_classes r,
             cn_quota_rules qr
       WHERE qr.quota_rule_id = l_old_quota_rule_uplift.quota_rule_id AND r.revenue_class_id = qr.revenue_class_id;

      cn_quota_rule_uplifts_grp.update_quota_rule_uplift (p_api_version             => p_api_version,
                                                          p_init_msg_list           => p_init_msg_list,
                                                          p_commit                  => p_commit,
                                                          p_validation_level        => p_validation_level,
                                                          x_return_status           => x_return_status,
                                                          x_msg_count               => x_msg_count,
                                                          x_msg_data                => x_msg_data,
                                                          p_quota_name              => l_quota_name,
                                                          p_rev_uplift_rec_tbl      => l_rev_uplift_rec_tbl,
                                                          x_loading_status          => l_loading_status
                                                         );
      -- repopulate variables
      p_quota_rule_uplift.org_id := l_rev_uplift_rec_tbl (1).org_id;
      p_quota_rule_uplift.quota_rule_uplift_id := l_rev_uplift_rec_tbl (1).quota_rule_uplift_id;
      p_quota_rule_uplift.quota_rule_id := l_rev_uplift_rec_tbl (1).quota_rule_id;
      p_quota_rule_uplift.start_date := l_rev_uplift_rec_tbl (1).start_date;
      p_quota_rule_uplift.end_date := l_rev_uplift_rec_tbl (1).end_date;
      p_quota_rule_uplift.payment_factor := l_rev_uplift_rec_tbl (1).payment_factor;
      p_quota_rule_uplift.quota_factor := l_rev_uplift_rec_tbl (1).quota_factor;
      p_quota_rule_uplift.object_version_number := l_rev_uplift_rec_tbl (1).object_version_number;
      p_quota_rule_uplift.rev_class_name := l_rev_uplift_rec_tbl (1).rev_class_name;
      p_quota_rule_uplift.rev_class_name_old := l_rev_uplift_rec_tbl (1).rev_class_name_old;
      p_quota_rule_uplift.start_date_old := l_rev_uplift_rec_tbl (1).start_date_old;
      p_quota_rule_uplift.end_date_old := l_rev_uplift_rec_tbl (1).end_date_old;

      IF (x_return_status <> fnd_api.g_ret_sts_success)
      THEN
         RAISE fnd_api.g_exc_error;
      END IF;

      -- Calling proc to add system note for update
      add_system_note(
            p_quota_rule_uplift,
            l_quota_id,
            l_old_quota_rule_uplift,
            'update',
            x_return_status,
            x_msg_count,
            x_msg_data
            );
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
         ROLLBACK TO update_quota_rule_uplift;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         ROLLBACK TO update_quota_rule_uplift;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
      WHEN OTHERS
      THEN
         ROLLBACK TO update_quota_rule_uplift;
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
   END update_uplift;

-- Start of comments
--      API name        : Delete_Uplift
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
--                        p_quota_rule_uplift         IN quota_rule_uplift_rec_type
--      OUT             : x_return_status     OUT     VARCHAR2(1)
--                        x_msg_count         OUT     NUMBER
--                        x_msg_data          OUT     VARCHAR2(2000)
--      Version :         Current version     1.0
--      Notes           : Note text
--
-- End of comments
   PROCEDURE delete_uplift (
      p_api_version              IN       NUMBER,
      p_init_msg_list            IN       VARCHAR2 := fnd_api.g_false,
      p_commit                   IN       VARCHAR2 := fnd_api.g_false,
      p_validation_level         IN       NUMBER := fnd_api.g_valid_level_full,
      p_quota_rule_uplift        IN OUT NOCOPY quota_rule_uplift_rec_type,
      x_return_status            OUT NOCOPY VARCHAR2,
      x_msg_count                OUT NOCOPY NUMBER,
      x_msg_data                 OUT NOCOPY VARCHAR2
   )
   IS
      l_api_name           CONSTANT VARCHAR2 (30) := 'Delete_Quota_Rule_Uplift';
      l_api_version        CONSTANT NUMBER := 1.0;
      l_temp_count                  NUMBER;
      l_loading_status              VARCHAR2 (50);
      l_rev_uplift_rec_tbl          quota_rule_uplift_tbl_type;
      l_quota_rule_id               NUMBER;
      l_quota_name                  cn_quotas.NAME%TYPE;
      l_quota_id                    NUMBER;
   BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT delete_quota_rule_uplift;

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
      SELECT r.NAME,
             q.NAME,
             qru.start_date,
             qru.end_date,
             q.org_id,
             q.quota_id
        INTO l_rev_uplift_rec_tbl (1).rev_class_name,
             l_quota_name,
             l_rev_uplift_rec_tbl (1).start_date,
             l_rev_uplift_rec_tbl (1).end_date,
             l_rev_uplift_rec_tbl (1).org_id,
             l_quota_id
        FROM cn_revenue_classes r,
             cn_quotas q,
             cn_quota_rules qr,
             cn_quota_rule_uplifts qru
       WHERE qr.quota_rule_id = qru.quota_rule_id
         AND r.revenue_class_id = qr.revenue_class_id
         AND q.quota_id = qr.quota_id
         AND qru.quota_rule_uplift_id = p_quota_rule_uplift.quota_rule_uplift_id;

      cn_quota_rule_uplifts_grp.delete_quota_rule_uplift (p_api_version             => 1.0,
                                                          p_init_msg_list           => 'T',
                                                          p_commit                  => 'F',
                                                          p_validation_level        => 100,
                                                          x_return_status           => x_return_status,
                                                          x_msg_count               => x_msg_count,
                                                          x_msg_data                => x_msg_data,
                                                          p_quota_name              => l_quota_name,
                                                          p_rev_uplift_rec_tbl      => l_rev_uplift_rec_tbl,
                                                          x_loading_status          => l_loading_status
                                                         );


      IF (x_return_status <> fnd_api.g_ret_sts_success)
      THEN
         RAISE fnd_api.g_exc_error;
      END IF;

      p_quota_rule_uplift.rev_class_name := l_rev_uplift_rec_tbl (1).rev_class_name;
      -- Calling proc to add system note for delete
      add_system_note(
            p_quota_rule_uplift,
            l_quota_id,
            null,
            'delete',
            x_return_status,
            x_msg_count,
            x_msg_data
            );
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
         ROLLBACK TO delete_quota_rule_uplift;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         ROLLBACK TO delete_quota_rule_uplift;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
      WHEN OTHERS
      THEN
         ROLLBACK TO delete_quota_rule_uplift;
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
   END delete_uplift;

END cn_quota_rule_uplift_pvt;

/
