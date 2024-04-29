--------------------------------------------------------
--  DDL for Package Body CN_RT_QUOTA_ASGN_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_RT_QUOTA_ASGN_PVT" AS
   /*$Header: cnvrtqab.pls 120.5 2006/07/06 10:56:34 chanthon ship $*/
   g_pkg_name           CONSTANT VARCHAR2 (30) := 'CN_RT_QUOTA_ASGN_PVT';

--------------------------------------------------------------------------------+
-- Procedure Name Insert Node Record
--------------------------------------------------------------------------------+
   PROCEDURE insert_formula_rate_tables (
      p_quota_id                 IN       NUMBER,
      p_calc_formula_id          IN       NUMBER,
      p_rate_tables              IN OUT NOCOPY rt_quota_asgn_tbl_type
   )
   IS
      CURSOR rate_formula_date_curs
      IS
         SELECT rf.start_date,
                rf.end_date,
                rf.rate_schedule_id,
                rs.NAME,
                fml.NAME calc_formula_name
           FROM cn_rt_formula_asgns rf,
                cn_rate_schedules_all rs,
                cn_calc_formulas fml
          WHERE fml.calc_formula_id = p_calc_formula_id AND rf.rate_schedule_id = rs.rate_schedule_id AND fml.calc_formula_id = rf.calc_formula_id;

      l_rec                         rt_quota_asgn_rec_type;
      rt_date                       rate_formula_date_curs%ROWTYPE;
      l_quota_start_date            DATE := NULL;
      l_quota_end_date              DATE := NULL;
      l_rt_start_date               DATE := NULL;
      l_rt_end_date                 DATE := NULL;
      l_start_date                  DATE := NULL;
      l_end_date                    DATE := NULL;
      l_org_id                      NUMBER;
      l_key                         NUMBER;
   BEGIN
      --clku
      SELECT start_date,
             end_date,
             org_id
        INTO l_quota_start_date,
             l_quota_end_date,
             l_org_id
        FROM cn_quotas_all
       WHERE quota_id = p_quota_id;

      FOR rt_date IN rate_formula_date_curs
      LOOP
         l_rt_start_date := rt_date.start_date;
         l_rt_end_date := rt_date.end_date;
         -- bug 3602452 - reinitialize variables
         l_start_date := NULL;
         l_end_date := NULL;

         -- 4 cases to get the overlap of l_rt_dates and l_quota_dates
         IF (l_rt_end_date IS NULL AND l_quota_end_date IS NULL)
         THEN
            IF TRUNC (l_rt_start_date) >= TRUNC (l_quota_start_date)
            THEN
               l_start_date := l_rt_start_date;
            ELSE
               l_start_date := l_quota_start_date;
            END IF;

            l_end_date := NULL;
         ELSIF (l_rt_end_date IS NULL AND (TRUNC (l_quota_end_date) > TRUNC (l_rt_start_date)))
         THEN
            IF TRUNC (l_rt_start_date) >= TRUNC (l_quota_start_date)
            THEN
               l_start_date := l_rt_start_date;
            ELSE
               l_start_date := l_quota_start_date;
            END IF;

            l_end_date := l_quota_end_date;
         ELSIF (l_quota_end_date IS NULL AND (TRUNC (l_rt_end_date) > TRUNC (l_quota_start_date)))
         THEN
            IF TRUNC (l_rt_start_date) >= TRUNC (l_quota_start_date)
            THEN
               l_start_date := l_rt_start_date;
            ELSE
               l_start_date := l_quota_start_date;
            END IF;

            l_end_date := l_rt_end_date;
         ELSIF ((TRUNC (l_rt_end_date) > TRUNC (l_quota_start_date)) OR (TRUNC (l_quota_end_date) > TRUNC (l_rt_start_date)))
         THEN
            IF TRUNC (l_rt_start_date) >= TRUNC (l_quota_start_date)
            THEN
               l_start_date := l_rt_start_date;
            ELSE
               l_start_date := l_quota_start_date;
            END IF;

            IF TRUNC (l_rt_end_date) <= TRUNC (l_quota_end_date)
            THEN
               l_end_date := l_rt_end_date;
            ELSE
               l_end_date := l_quota_end_date;
            END IF;
         END IF;

         -- we only insert if there are overlap
         -- clku, fix the date not overlap issue
         IF ((l_start_date IS NOT NULL) AND (TRUNC (l_start_date) <= TRUNC (NVL (l_end_date, l_start_date))))
         THEN
            SELECT cn_rt_quota_asgns_s.NEXTVAL,
                   p_calc_formula_id,
                   p_quota_id,
                   l_start_date,
                   l_end_date,
                   rt_date.rate_schedule_id,
                   rt_date.NAME,
                   rt_date.calc_formula_name,
                   l_org_id
              INTO l_rec.rt_quota_asgn_id,
                   l_rec.calc_formula_id,
                   l_rec.quota_id,
                   l_rec.start_date,
                   l_rec.end_date,
                   l_rec.rate_schedule_id,
                   l_rec.NAME,
                   l_rec.calc_formula_name,
                   l_rec.org_id
              FROM DUAL;

            p_rate_tables (l_rec.rt_quota_asgn_id) := l_rec;
         END IF;
      END LOOP;
   END insert_formula_rate_tables;


-- -------------------------------------------------------------------------+-+
--| Procedure:   add_system_note
--| Description: Insert notes for the create, update and delete
--| operations.
--| Called From: Create_quota_rule, Update_quota_rule
--| Delete_quota_rule
-- -------------------------------------------------------------------------+-+
   PROCEDURE add_system_note(
      p_rt_quota_asgn            IN OUT NOCOPY rt_quota_asgn_rec_type,
      p_old_rt_quota_asgn        IN cn_rt_quota_asgns%ROWTYPE,
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
    l_old_rt_name VARCHAR2 (200);

   BEGIN
     -- Initialize to success
     x_return_status := fnd_api.g_ret_sts_success;
     -- Initialize other fields
     x_msg_data := fnd_api.g_null_char;
     x_msg_count := fnd_api.g_null_num;
     -- Getting the rate table name
     SELECT NAME INTO l_temp_old
     FROM CN_RATE_SCHEDULES
     WHERE RATE_SCHEDULE_ID = p_rt_quota_asgn.rate_schedule_id
     AND ORG_ID = p_rt_quota_asgn.org_id;

       IF (p_operation = 'create') THEN
         fnd_message.set_name('CN','CNR12_NOTE_PE_RT_ASGN_CRE');
         fnd_message.set_token('RT_TAB', l_temp_old);
         fnd_message.set_token('ST_DT', p_rt_quota_asgn.start_date);
         fnd_message.set_token('END_DT', p_rt_quota_asgn.end_date);
         l_plan_element_id := p_rt_quota_asgn.quota_id;
         l_temp_new := 'CN_QUOTAS';
       END IF;
       IF (p_operation = 'delete') THEN
         fnd_message.set_name ('CN', 'CNR12_NOTE_PE_RT_ASGN_DEL');
         fnd_message.set_token('RT_TAB', l_temp_old);
         fnd_message.set_token('ST_DATE', p_rt_quota_asgn.start_date);
         fnd_message.set_token('END_DATE', p_rt_quota_asgn.end_date);
         l_plan_element_id := p_rt_quota_asgn.quota_id;
         l_temp_new := 'CN_QUOTAS';
       END IF;
       IF (p_operation = 'update') THEN
         SELECT NAME INTO l_old_rt_name
         FROM CN_RATE_SCHEDULES
         WHERE RATE_SCHEDULE_ID = p_old_rt_quota_asgn.rate_schedule_id
         AND ORG_ID = p_old_rt_quota_asgn.org_id;

         fnd_message.set_name('CN','CNR12_NOTE_PE_RT_ASGN_UPD');
         fnd_message.set_token('OLD_RT_TAB', l_old_rt_name);
         fnd_message.set_token('OLD_ST_DT', p_old_rt_quota_asgn.start_date);
         fnd_message.set_token('OLD_END_DT', p_old_rt_quota_asgn.end_date);
         fnd_message.set_token('NEW_RT_TAB', l_temp_old);
         fnd_message.set_token('NEW_ST_DT', p_rt_quota_asgn.start_date);
         fnd_message.set_token('NEW_END_DT', p_rt_quota_asgn.end_date);
         l_plan_element_id := p_rt_quota_asgn.quota_id;
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
--    API name        : Create_Rt_Quota_Asgn
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
--                      p_rt_quota_asgn     IN  rt_quota_asgn_rec_type
--    OUT             : x_return_status       OUT     VARCHAR2(1)
--                      x_msg_count           OUT     NUMBER
--                      x_msg_data            OUT     VARCHAR2(2000)
--                      x_rt_quota_asgn_id        OUT     NUMBER
--    Version :         Current version       1.0
--    Notes           : Note text
--
-- End of comments
   PROCEDURE create_rate_table_assignment (
      p_api_version              IN       NUMBER,
      p_init_msg_list            IN       VARCHAR2 := fnd_api.g_false,
      p_commit                   IN       VARCHAR2 := fnd_api.g_false,
      p_validation_level         IN       NUMBER := fnd_api.g_valid_level_full,
      p_rt_quota_asgn            IN OUT NOCOPY rt_quota_asgn_rec_type,
      x_return_status            OUT NOCOPY VARCHAR2,
      x_msg_count                OUT NOCOPY NUMBER,
      x_msg_data                 OUT NOCOPY VARCHAR2
   )
   IS
      l_api_name           CONSTANT VARCHAR2 (30) := 'create_rate_table_assignment';
      l_api_version        CONSTANT NUMBER := 1.0;
      x_loading_status              VARCHAR2 (30) := ' ';
      l_temp_count                  NUMBER;
      l_calc_formula_id             NUMBER;
      g_rowid                       VARCHAR2 (30);
      g_program_type                VARCHAR2 (30);
      p_org_id                      NUMBER;
      p_rt_quota_asgn_id            NUMBER;
      p_quota_id                    NUMBER;
      p_start_date                  DATE;
      p_end_date                    DATE;
      p_rate_schedule_id            NUMBER;
      p_calc_formula_id             NUMBER;
      p_attribute_category          VARCHAR2 (150);
      p_attribute1                  VARCHAR2 (150);
      p_attribute2                  VARCHAR2 (150);
      p_attribute3                  VARCHAR2 (150);
      p_attribute4                  VARCHAR2 (150);
      p_attribute5                  VARCHAR2 (150);
      p_attribute6                  VARCHAR2 (150);
      p_attribute7                  VARCHAR2 (150);
      p_attribute8                  VARCHAR2 (150);
      p_attribute9                  VARCHAR2 (150);
      p_attribute10                 VARCHAR2 (150);
      p_attribute11                 VARCHAR2 (150);
      p_attribute12                 VARCHAR2 (150);
      p_attribute13                 VARCHAR2 (150);
      p_attribute14                 VARCHAR2 (150);
      p_attribute15                 VARCHAR2 (150);
      p_created_by                  NUMBER;
      p_creation_date               DATE;
      p_last_update_login           NUMBER;
      p_last_update_date            DATE;
      p_last_updated_by             NUMBER;
      p_object_version_number       NUMBER;
   BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT create_rt_quota_asgn;

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
      SELECT NULL,
             fnd_global.user_id,
             SYSDATE,
             fnd_global.login_id,
             SYSDATE,
             fnd_global.user_id,
             1
        INTO p_rt_quota_asgn.rt_quota_asgn_id,
             p_rt_quota_asgn.created_by,
             p_rt_quota_asgn.creation_date,
             p_rt_quota_asgn.last_update_login,
             p_rt_quota_asgn.last_update_date,
             p_rt_quota_asgn.last_updated_by,
             p_rt_quota_asgn.object_version_number
        FROM DUAL;

      -- validate this assignment
      validate_rate_table_assignment (p_api_version        => p_api_version,
                                      p_rt_quota_asgn      => p_rt_quota_asgn,
                                      p_action             => 'CREATE',
                                      x_return_status      => x_return_status,
                                      x_msg_count          => x_msg_count,
                                      x_msg_data           => x_msg_data
                                     );

      IF x_return_status <> fnd_api.g_ret_sts_success
      THEN
         RAISE fnd_api.g_exc_error;
      END IF;

      cn_rt_quota_asgns_pkg.begin_record (x_org_id                     => p_rt_quota_asgn.org_id,
                                          x_operation                  => 'INSERT',
                                          x_rowid                      => g_rowid,
                                          x_rt_quota_asgn_id           => p_rt_quota_asgn.rt_quota_asgn_id,
                                          x_calc_formula_id            => p_rt_quota_asgn.calc_formula_id,
                                          x_quota_id                   => p_rt_quota_asgn.quota_id,
                                          x_start_date                 => p_rt_quota_asgn.start_date,
                                          x_end_date                   => p_rt_quota_asgn.end_date,
                                          x_rate_schedule_id           => p_rt_quota_asgn.rate_schedule_id,
                                          x_attribute_category         => p_rt_quota_asgn.attribute_category,
                                          x_attribute1                 => p_rt_quota_asgn.attribute1,
                                          x_attribute2                 => p_rt_quota_asgn.attribute2,
                                          x_attribute3                 => p_rt_quota_asgn.attribute3,
                                          x_attribute4                 => p_rt_quota_asgn.attribute4,
                                          x_attribute5                 => p_rt_quota_asgn.attribute5,
                                          x_attribute6                 => p_rt_quota_asgn.attribute6,
                                          x_attribute7                 => p_rt_quota_asgn.attribute7,
                                          x_attribute8                 => p_rt_quota_asgn.attribute8,
                                          x_attribute9                 => p_rt_quota_asgn.attribute9,
                                          x_attribute10                => p_rt_quota_asgn.attribute10,
                                          x_attribute11                => p_rt_quota_asgn.attribute11,
                                          x_attribute12                => p_rt_quota_asgn.attribute12,
                                          x_attribute13                => p_rt_quota_asgn.attribute13,
                                          x_attribute14                => p_rt_quota_asgn.attribute14,
                                          x_attribute15                => p_rt_quota_asgn.attribute15,
                                          x_last_update_date           => p_rt_quota_asgn.last_update_date,
                                          x_last_updated_by            => p_rt_quota_asgn.last_updated_by,
                                          x_creation_date              => p_rt_quota_asgn.creation_date,
                                          x_created_by                 => p_rt_quota_asgn.created_by,
                                          x_last_update_login          => p_rt_quota_asgn.last_updated_by,
                                          x_program_type               => g_program_type,
                                          x_object_version_number      => p_rt_quota_asgn.object_version_number
                                         );

      -- Calling proc to add system note for create
      add_system_note(
            p_rt_quota_asgn,
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
         ROLLBACK TO create_rt_quota_asgn;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         ROLLBACK TO create_rt_quota_asgn;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
      WHEN OTHERS
      THEN
         ROLLBACK TO create_rt_quota_asgn;
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
   END create_rate_table_assignment;

-- Start of comments
--      API name        : Update_Rt_Quota_Asgn
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
--                        p_rt_quota_asgn         IN rt_quota_asgn_rec_type
--      OUT             : x_return_status     OUT     VARCHAR2(1)
--                        x_msg_count         OUT     NUMBER
--                        x_msg_data          OUT     VARCHAR2(2000)
--      Version :         Current version     1.0
--      Notes           : Note text
--
-- End of comments
   PROCEDURE update_rate_table_assignment (
      p_api_version              IN       NUMBER,
      p_init_msg_list            IN       VARCHAR2 := fnd_api.g_false,
      p_commit                   IN       VARCHAR2 := fnd_api.g_false,
      p_validation_level         IN       NUMBER := fnd_api.g_valid_level_full,
      p_rt_quota_asgn            IN OUT NOCOPY rt_quota_asgn_rec_type,
      x_return_status            OUT NOCOPY VARCHAR2,
      x_msg_count                OUT NOCOPY NUMBER,
      x_msg_data                 OUT NOCOPY VARCHAR2
   )
   IS
      l_api_name           CONSTANT VARCHAR2 (30) := 'update_rate_table_assignment';
      l_api_version        CONSTANT NUMBER := 1.0;
      l_err_message                 VARCHAR2 (30);
      x_loading_status              VARCHAR2 (30) := ' ';

      CURSOR l_old_rt_quota_asgn_cr
      IS
         SELECT *
           FROM cn_rt_quota_asgns
          WHERE rt_quota_asgn_id = p_rt_quota_asgn.rt_quota_asgn_id;

      l_old_rt_quota_asgn           l_old_rt_quota_asgn_cr%ROWTYPE;
      l_rt_quota_asgn               rt_quota_asgn_rec_type;
      l_temp_count                  NUMBER;
      l_start_date                  DATE;
      l_end_date                    DATE;
      g_rowid                       VARCHAR2 (30);
      g_program_type                VARCHAR2 (30);
      p_org_id                      NUMBER;
      p_rt_quota_asgn_id            NUMBER;
      p_quota_id                    NUMBER;
      p_start_date                  DATE;
      p_end_date                    DATE;
      p_rate_schedule_id            NUMBER;
      p_calc_formula_id             NUMBER;
      p_attribute_category          VARCHAR2 (150);
      p_attribute1                  VARCHAR2 (150);
      p_attribute2                  VARCHAR2 (150);
      p_attribute3                  VARCHAR2 (150);
      p_attribute4                  VARCHAR2 (150);
      p_attribute5                  VARCHAR2 (150);
      p_attribute6                  VARCHAR2 (150);
      p_attribute7                  VARCHAR2 (150);
      p_attribute8                  VARCHAR2 (150);
      p_attribute9                  VARCHAR2 (150);
      p_attribute10                 VARCHAR2 (150);
      p_attribute11                 VARCHAR2 (150);
      p_attribute12                 VARCHAR2 (150);
      p_attribute13                 VARCHAR2 (150);
      p_attribute14                 VARCHAR2 (150);
      p_attribute15                 VARCHAR2 (150);
      p_created_by                  NUMBER;
      p_creation_date               DATE;
      p_last_update_login           NUMBER;
      p_last_update_date            DATE;
      p_last_updated_by             NUMBER;
      p_object_version_number       NUMBER;
   BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT update_rt_quota_asgn;

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
      OPEN l_old_rt_quota_asgn_cr;

      FETCH l_old_rt_quota_asgn_cr
       INTO l_old_rt_quota_asgn;

      CLOSE l_old_rt_quota_asgn_cr;

      SELECT DECODE (p_rt_quota_asgn.org_id, fnd_api.g_miss_num, l_old_rt_quota_asgn.org_id, p_rt_quota_asgn.org_id),
             DECODE (p_rt_quota_asgn.rt_quota_asgn_id, fnd_api.g_miss_num, l_old_rt_quota_asgn.rt_quota_asgn_id, p_rt_quota_asgn.rt_quota_asgn_id),
             DECODE (p_rt_quota_asgn.quota_id, fnd_api.g_miss_num, l_old_rt_quota_asgn.quota_id, p_rt_quota_asgn.quota_id),
             DECODE (p_rt_quota_asgn.start_date, fnd_api.g_miss_date, TRUNC (l_old_rt_quota_asgn.start_date), TRUNC (p_rt_quota_asgn.start_date)),
             DECODE (p_rt_quota_asgn.end_date, fnd_api.g_miss_date, TRUNC (l_old_rt_quota_asgn.end_date), TRUNC (p_rt_quota_asgn.end_date)),
             DECODE (p_rt_quota_asgn.rate_schedule_id, fnd_api.g_miss_num, l_old_rt_quota_asgn.rate_schedule_id, p_rt_quota_asgn.rate_schedule_id),
             DECODE (p_rt_quota_asgn.calc_formula_id, fnd_api.g_miss_num, l_old_rt_quota_asgn.calc_formula_id, p_rt_quota_asgn.calc_formula_id),
             DECODE (p_rt_quota_asgn.attribute_category,
                     fnd_api.g_miss_char, l_old_rt_quota_asgn.attribute_category,
                     p_rt_quota_asgn.attribute_category
                    ),
             DECODE (p_rt_quota_asgn.attribute1, fnd_api.g_miss_char, l_old_rt_quota_asgn.attribute1, p_rt_quota_asgn.attribute1),
             DECODE (p_rt_quota_asgn.attribute2, fnd_api.g_miss_char, l_old_rt_quota_asgn.attribute2, p_rt_quota_asgn.attribute2),
             DECODE (p_rt_quota_asgn.attribute3, fnd_api.g_miss_char, l_old_rt_quota_asgn.attribute3, p_rt_quota_asgn.attribute3),
             DECODE (p_rt_quota_asgn.attribute4, fnd_api.g_miss_char, l_old_rt_quota_asgn.attribute4, p_rt_quota_asgn.attribute4),
             DECODE (p_rt_quota_asgn.attribute5, fnd_api.g_miss_char, l_old_rt_quota_asgn.attribute5, p_rt_quota_asgn.attribute5),
             DECODE (p_rt_quota_asgn.attribute6, fnd_api.g_miss_char, l_old_rt_quota_asgn.attribute6, p_rt_quota_asgn.attribute6),
             DECODE (p_rt_quota_asgn.attribute7, fnd_api.g_miss_char, l_old_rt_quota_asgn.attribute7, p_rt_quota_asgn.attribute7),
             DECODE (p_rt_quota_asgn.attribute8, fnd_api.g_miss_char, l_old_rt_quota_asgn.attribute8, p_rt_quota_asgn.attribute8),
             DECODE (p_rt_quota_asgn.attribute9, fnd_api.g_miss_char, l_old_rt_quota_asgn.attribute9, p_rt_quota_asgn.attribute9),
             DECODE (p_rt_quota_asgn.attribute10, fnd_api.g_miss_char, l_old_rt_quota_asgn.attribute10, p_rt_quota_asgn.attribute10),
             DECODE (p_rt_quota_asgn.attribute11, fnd_api.g_miss_char, l_old_rt_quota_asgn.attribute11, p_rt_quota_asgn.attribute11),
             DECODE (p_rt_quota_asgn.attribute12, fnd_api.g_miss_char, l_old_rt_quota_asgn.attribute12, p_rt_quota_asgn.attribute12),
             DECODE (p_rt_quota_asgn.attribute13, fnd_api.g_miss_char, l_old_rt_quota_asgn.attribute13, p_rt_quota_asgn.attribute13),
             DECODE (p_rt_quota_asgn.attribute14, fnd_api.g_miss_char, l_old_rt_quota_asgn.attribute14, p_rt_quota_asgn.attribute14),
             DECODE (p_rt_quota_asgn.attribute15, fnd_api.g_miss_char, l_old_rt_quota_asgn.attribute15, p_rt_quota_asgn.attribute15),
             fnd_global.user_id,
             SYSDATE,
             fnd_global.login_id,
             SYSDATE,
             fnd_global.user_id,
             p_rt_quota_asgn.object_version_number
        INTO p_rt_quota_asgn.org_id,
             p_rt_quota_asgn.rt_quota_asgn_id,
             p_rt_quota_asgn.quota_id,
             p_rt_quota_asgn.start_date,
             p_rt_quota_asgn.end_date,
             p_rt_quota_asgn.rate_schedule_id,
             p_rt_quota_asgn.calc_formula_id,
             p_rt_quota_asgn.attribute_category,
             p_rt_quota_asgn.attribute1,
             p_rt_quota_asgn.attribute2,
             p_rt_quota_asgn.attribute3,
             p_rt_quota_asgn.attribute4,
             p_rt_quota_asgn.attribute5,
             p_rt_quota_asgn.attribute6,
             p_rt_quota_asgn.attribute7,
             p_rt_quota_asgn.attribute8,
             p_rt_quota_asgn.attribute9,
             p_rt_quota_asgn.attribute10,
             p_rt_quota_asgn.attribute11,
             p_rt_quota_asgn.attribute12,
             p_rt_quota_asgn.attribute13,
             p_rt_quota_asgn.attribute14,
             p_rt_quota_asgn.attribute15,
             p_rt_quota_asgn.created_by,
             p_rt_quota_asgn.creation_date,
             p_rt_quota_asgn.last_update_login,
             p_rt_quota_asgn.last_update_date,
             p_rt_quota_asgn.last_updated_by,
             p_rt_quota_asgn.object_version_number
        FROM DUAL;

      -- validate
      validate_rate_table_assignment (p_api_version        => p_api_version,
                                      p_rt_quota_asgn      => p_rt_quota_asgn,
                                      p_action             => 'UPDATE',
                                      x_return_status      => x_return_status,
                                      x_msg_count          => x_msg_count,
                                      x_msg_data           => x_msg_data
                                     );

      IF x_return_status <> fnd_api.g_ret_sts_success
      THEN
         RAISE fnd_api.g_exc_error;
      END IF;

      -- 3. check object version number
      IF l_old_rt_quota_asgn.object_version_number <> p_rt_quota_asgn.object_version_number
      THEN
         fnd_message.set_name ('CN', 'CN_RECORD_CHANGED');
         fnd_msg_pub.ADD;
         RAISE fnd_api.g_exc_error;
      END IF;

      cn_rt_quota_asgns_pkg.begin_record (x_org_id                     => p_rt_quota_asgn.org_id,
                                          x_operation                  => 'UPDATE',
                                          x_rowid                      => g_rowid,
                                          x_rt_quota_asgn_id           => p_rt_quota_asgn.rt_quota_asgn_id,
                                          x_calc_formula_id            => p_rt_quota_asgn.calc_formula_id,
                                          x_quota_id                   => p_rt_quota_asgn.quota_id,
                                          x_start_date                 => p_rt_quota_asgn.start_date,
                                          x_end_date                   => p_rt_quota_asgn.end_date,
                                          x_rate_schedule_id           => p_rt_quota_asgn.rate_schedule_id,
                                          x_attribute_category         => p_rt_quota_asgn.attribute_category,
                                          x_attribute1                 => p_rt_quota_asgn.attribute1,
                                          x_attribute2                 => p_rt_quota_asgn.attribute2,
                                          x_attribute3                 => p_rt_quota_asgn.attribute3,
                                          x_attribute4                 => p_rt_quota_asgn.attribute4,
                                          x_attribute5                 => p_rt_quota_asgn.attribute5,
                                          x_attribute6                 => p_rt_quota_asgn.attribute6,
                                          x_attribute7                 => p_rt_quota_asgn.attribute7,
                                          x_attribute8                 => p_rt_quota_asgn.attribute8,
                                          x_attribute9                 => p_rt_quota_asgn.attribute9,
                                          x_attribute10                => p_rt_quota_asgn.attribute10,
                                          x_attribute11                => p_rt_quota_asgn.attribute11,
                                          x_attribute12                => p_rt_quota_asgn.attribute12,
                                          x_attribute13                => p_rt_quota_asgn.attribute13,
                                          x_attribute14                => p_rt_quota_asgn.attribute14,
                                          x_attribute15                => p_rt_quota_asgn.attribute15,
                                          x_last_update_date           => p_rt_quota_asgn.last_update_date,
                                          x_last_updated_by            => p_rt_quota_asgn.last_updated_by,
                                          x_creation_date              => p_rt_quota_asgn.creation_date,
                                          x_created_by                 => p_rt_quota_asgn.created_by,
                                          x_last_update_login          => p_rt_quota_asgn.last_updated_by,
                                          x_program_type               => g_program_type,
                                          x_object_version_number      => p_rt_quota_asgn.object_version_number
                                         );

      -- Calling proc to add system note for update
      add_system_note(
            p_rt_quota_asgn,
            l_old_rt_quota_asgn,
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
         ROLLBACK TO update_rt_quota_asgn;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         ROLLBACK TO update_rt_quota_asgn;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
      WHEN OTHERS
      THEN
         ROLLBACK TO update_rt_quota_asgn;
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
   END update_rate_table_assignment;

-- Start of comments
--      API name        : Delete_Rt_Quota_Asgn
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
--                        p_rt_quota_asgn         IN quota_asgn_rec_type
--      OUT             : x_return_status     OUT     VARCHAR2(1)
--                        x_msg_count         OUT     NUMBER
--                        x_msg_data          OUT     VARCHAR2(2000)
--      Version :         Current version     1.0
--      Notes           : Note text
--
-- End of comments
   PROCEDURE delete_rate_table_assignment (
      p_api_version              IN       NUMBER,
      p_init_msg_list            IN       VARCHAR2 := fnd_api.g_false,
      p_commit                   IN       VARCHAR2 := fnd_api.g_false,
      p_validation_level         IN       NUMBER := fnd_api.g_valid_level_full,
      p_rt_quota_asgn            IN OUT NOCOPY rt_quota_asgn_rec_type,
      x_return_status            OUT NOCOPY VARCHAR2,
      x_msg_count                OUT NOCOPY NUMBER,
      x_msg_data                 OUT NOCOPY VARCHAR2
   )
   IS
      l_api_name           CONSTANT VARCHAR2 (30) := 'delete_rate_table_assignment';
      l_api_version        CONSTANT NUMBER := 1.0;
      l_temp_count                  NUMBER;
      g_rowid                       VARCHAR2 (30);
      g_program_type                VARCHAR2 (30);
      p_org_id                      NUMBER;
      p_rt_quota_asgn_id            NUMBER;
      p_quota_id                    NUMBER;
      p_start_date                  DATE;
      p_end_date                    DATE;
      p_rate_schedule_id            NUMBER;
      p_calc_formula_id             NUMBER;
      p_attribute_category          VARCHAR2 (150);
      p_attribute1                  VARCHAR2 (150);
      p_attribute2                  VARCHAR2 (150);
      p_attribute3                  VARCHAR2 (150);
      p_attribute4                  VARCHAR2 (150);
      p_attribute5                  VARCHAR2 (150);
      p_attribute6                  VARCHAR2 (150);
      p_attribute7                  VARCHAR2 (150);
      p_attribute8                  VARCHAR2 (150);
      p_attribute9                  VARCHAR2 (150);
      p_attribute10                 VARCHAR2 (150);
      p_attribute11                 VARCHAR2 (150);
      p_attribute12                 VARCHAR2 (150);
      p_attribute13                 VARCHAR2 (150);
      p_attribute14                 VARCHAR2 (150);
      p_attribute15                 VARCHAR2 (150);
      p_created_by                  NUMBER;
      p_creation_date               DATE;
      p_last_update_login           NUMBER;
      p_last_update_date            DATE;
      p_last_updated_by             NUMBER;
      p_object_version_number       NUMBER;
/*     CURSOR rt_quota_asgns_cr(l_rt_quota_asgn_id NUMBER) IS
      SELECT rate_schedule_id,
             quota_id
      FROM   cn_rt_quota_asgns
      WHERE  rt_quota_asgn_id = l_rt_quota_asgn_id;

     l_rt_quota_asgn rt_quota_asgns_cr%ROWTYPE;*/
   BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT delete_rt_quota_asgn;

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

      /*select count(1)
        into l_temp_count
        from cn_srp_plan_assigns
       where quota_rule_id = p_quota_rule.quota_rule_id
         and rownum = 1;

      IF l_temp_count > 0 THEN

        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
      FND_MESSAGE.SET_NAME ('CN' , 'CN_QUOTA_RULE_ASGNED');
      FND_MSG_PUB.Add;
        END IF;
        RAISE FND_API.G_EXC_ERROR ;
      END IF;*/
      SELECT p_rt_quota_asgn.org_id,
             p_rt_quota_asgn.rt_quota_asgn_id,
             p_rt_quota_asgn.quota_id,
             p_rt_quota_asgn.start_date,
             p_rt_quota_asgn.end_date,
             p_rt_quota_asgn.rate_schedule_id,
             p_rt_quota_asgn.calc_formula_id,
             p_rt_quota_asgn.attribute_category,
             p_rt_quota_asgn.attribute1,
             p_rt_quota_asgn.attribute2,
             p_rt_quota_asgn.attribute3,
             p_rt_quota_asgn.attribute4,
             p_rt_quota_asgn.attribute5,
             p_rt_quota_asgn.attribute6,
             p_rt_quota_asgn.attribute7,
             p_rt_quota_asgn.attribute8,
             p_rt_quota_asgn.attribute9,
             p_rt_quota_asgn.attribute10,
             p_rt_quota_asgn.attribute11,
             p_rt_quota_asgn.attribute12,
             p_rt_quota_asgn.attribute13,
             p_rt_quota_asgn.attribute14,
             p_rt_quota_asgn.attribute15,
             fnd_global.user_id,
             SYSDATE,
             fnd_global.login_id,
             SYSDATE,
             fnd_global.user_id,
             p_rt_quota_asgn.object_version_number + 1
        INTO p_org_id,
             p_rt_quota_asgn_id,
             p_quota_id,
             p_start_date,
             p_end_date,
             p_rate_schedule_id,
             p_calc_formula_id,
             p_attribute_category,
             p_attribute1,
             p_attribute2,
             p_attribute3,
             p_attribute4,
             p_attribute5,
             p_attribute6,
             p_attribute7,
             p_attribute8,
             p_attribute9,
             p_attribute10,
             p_attribute11,
             p_attribute12,
             p_attribute13,
             p_attribute14,
             p_attribute15,
             p_created_by,
             p_creation_date,
             p_last_update_login,
             p_last_update_date,
             p_last_updated_by,
             p_object_version_number
        FROM DUAL;

      cn_comp_plans_pkg.set_status (x_comp_plan_id          => NULL,
                                    x_quota_id              => p_quota_id,
                                    x_rate_schedule_id      => p_rate_schedule_id,
                                    x_status_code           => 'INCOMPLETE',
                                    x_event                 => NULL
                                   );
      cn_rt_quota_asgns_pkg.begin_record (x_org_id                     => p_rt_quota_asgn.org_id,
                                          x_operation                  => 'DELETE',
                                          x_rowid                      => g_rowid,
                                          x_rt_quota_asgn_id           => p_rt_quota_asgn.rt_quota_asgn_id,
                                          x_calc_formula_id            => p_calc_formula_id,
                                          x_quota_id                   => p_quota_id,
                                          x_start_date                 => p_start_date,
                                          x_end_date                   => p_end_date,
                                          x_rate_schedule_id           => p_rate_schedule_id,
                                          x_attribute_category         => p_attribute_category,
                                          x_attribute1                 => p_attribute1,
                                          x_attribute2                 => p_attribute2,
                                          x_attribute3                 => p_attribute3,
                                          x_attribute4                 => p_attribute4,
                                          x_attribute5                 => p_attribute5,
                                          x_attribute6                 => p_attribute6,
                                          x_attribute7                 => p_attribute7,
                                          x_attribute8                 => p_attribute8,
                                          x_attribute9                 => p_attribute9,
                                          x_attribute10                => p_attribute10,
                                          x_attribute11                => p_attribute11,
                                          x_attribute12                => p_attribute12,
                                          x_attribute13                => p_attribute13,
                                          x_attribute14                => p_attribute14,
                                          x_attribute15                => p_attribute15,
                                          x_last_update_date           => p_last_update_date,
                                          x_last_updated_by            => p_last_updated_by,
                                          x_creation_date              => p_creation_date,
                                          x_created_by                 => p_created_by,
                                          x_last_update_login          => p_last_updated_by,
                                          x_program_type               => g_program_type,
                                          x_object_version_number      => p_rt_quota_asgn.object_version_number
                                         );

      -- Calling proc to add system note for delete
      add_system_note(
            p_rt_quota_asgn,
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
         ROLLBACK TO delete_rt_quota_asgn;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         ROLLBACK TO delete_rt_quota_asgn;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
      WHEN OTHERS
      THEN
         ROLLBACK TO delete_rt_quota_asgn;
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
   END delete_rate_table_assignment;

-- Start of comments
--      API name        : get_formula_rate_tables
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
--                        p_quota_id      IN NUMBER
--      OUT             : x_return_status     OUT     VARCHAR2(1)
--                        x_msg_count         OUT     NUMBER
--                        x_msg_data          OUT     VARCHAR2(2000)
--                        x_rt_quota_asgn     OUT     rt_quota_asgn_tbl_type
--      Version :         Current version     1.0
--      Notes           : Note text
--
-- End of comments
   PROCEDURE get_formula_rate_tables (
      p_api_version              IN       NUMBER,
      p_init_msg_list            IN       VARCHAR2 := fnd_api.g_false,
      p_commit                   IN       VARCHAR2 := fnd_api.g_false,
      p_validation_level         IN       NUMBER := fnd_api.g_valid_level_full,
      p_type                     IN       VARCHAR2 := 'FORMULA',
      p_quota_id                 IN       NUMBER,
      p_calc_formula_id          IN       NUMBER,
      x_calc_formulas            OUT NOCOPY calc_formulas_tbl_type,
      x_rate_tables              OUT NOCOPY rt_quota_asgn_tbl_type,
      x_return_status            OUT NOCOPY VARCHAR2,
      x_msg_count                OUT NOCOPY NUMBER,
      x_msg_data                 OUT NOCOPY VARCHAR2
   )
   IS
      l_rate_tables                 rt_quota_asgn_tbl_type;
      l_calc_formulas               calc_formulas_tbl_type;
      l_calc_rec                    calc_formulas_rec_type;
      l_api_name           CONSTANT VARCHAR2 (30) := 'get_formula_rate_tables';
      l_api_version        CONSTANT NUMBER := 1.0;

      CURSOR calc_edge_curs (
         l_parent_id                         NUMBER
      )
      IS
         SELECT DISTINCT child_id
                    FROM cn_calc_edges
                   WHERE edge_type = 'FE' AND parent_id IN (SELECT calc_sql_exp_id
                                                              FROM cn_formula_inputs
                                                             WHERE calc_formula_id = l_parent_id
                                                            UNION
                                                            SELECT output_exp_id
                                                              FROM cn_calc_formulas
                                                             WHERE calc_formula_id = l_parent_id);

      TYPE stack_type IS TABLE OF cn_calc_formulas.calc_formula_id%TYPE;

      l_stack                       stack_type := stack_type() ;
      l_parent_calc_formula_id      cn_calc_formulas.calc_formula_id%TYPE;
      l_child_calc_formula_id       cn_calc_formulas.calc_formula_id%TYPE;

      CURSOR rt_quota_asgn_curs (
         l_calc_formula_id                   NUMBER,
         l_quota_id                          NUMBER
      )
      IS
         SELECT rt_quota_asgn_id
           FROM cn_rt_quota_asgns
          WHERE quota_id = l_quota_id AND calc_formula_id = l_calc_formula_id;

      l_rt_quota_asgn_id            cn_rt_quota_asgns.rt_quota_asgn_id%TYPE;
   BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT get_formula_rate_tables;

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

      IF p_calc_formula_id IS NOT NULL
      THEN
         l_stack := stack_type (p_calc_formula_id);
      END IF;

      WHILE (l_stack.COUNT > 0)
      LOOP
         l_parent_calc_formula_id := l_stack (l_stack.LAST);
         l_stack.DELETE (l_stack.LAST);

         SELECT NAME,
                calc_formula_id
           INTO l_calc_rec.NAME,
                l_calc_rec.calc_formula_id
           FROM cn_calc_formulas
          WHERE calc_formula_id = l_parent_calc_formula_id;

         l_calc_formulas (l_calc_rec.calc_formula_id) := l_calc_rec;

          -- clku, bug 2812184, only insert if we have not seen this quota/formula
         -- combination before
         OPEN rt_quota_asgn_curs (l_parent_calc_formula_id, p_quota_id);

         FETCH rt_quota_asgn_curs
          INTO l_rt_quota_asgn_id;

         IF rt_quota_asgn_curs%NOTFOUND
         THEN
            insert_formula_rate_tables (p_quota_id, l_parent_calc_formula_id, l_rate_tables);
         END IF;

         CLOSE rt_quota_asgn_curs;

         OPEN calc_edge_curs (l_parent_calc_formula_id);

         LOOP
            FETCH calc_edge_curs
             INTO l_child_calc_formula_id;

            IF calc_edge_curs%FOUND
            THEN
               l_stack.EXTEND;
               l_stack (l_stack.LAST) := l_child_calc_formula_id;
            ELSE
               EXIT;
            END IF;
         END LOOP;

         CLOSE calc_edge_curs;
      END LOOP;

      x_rate_tables := l_rate_tables;
      x_calc_formulas := l_calc_formulas;

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
         ROLLBACK TO get_formula_rate_tables;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         ROLLBACK TO get_formula_rate_tables;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
      WHEN OTHERS
      THEN
         ROLLBACK TO get_formula_rate_tables;
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
   END get_formula_rate_tables;

-- Start of comments
--      API name        : validate_rate_table_assignment
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
--                        p_rt_quota_asgn         IN quota_asgn_rec_type
--      OUT             : x_return_status     OUT     VARCHAR2(1)
--                        x_msg_count         OUT     NUMBER
--                        x_msg_data          OUT     VARCHAR2(2000)
--      Version :         Current version     1.0
--      Notes           : Note text
--
-- End of comments
   PROCEDURE validate_rate_table_assignment (
      p_api_version              IN       NUMBER,
      p_init_msg_list            IN       VARCHAR2 := fnd_api.g_false,
      p_commit                   IN       VARCHAR2 := fnd_api.g_false,
      p_validation_level         IN       NUMBER := fnd_api.g_valid_level_full,
      p_action                   IN       VARCHAR2,
      p_rt_quota_asgn            IN OUT NOCOPY rt_quota_asgn_rec_type,
      p_old_rt_quota_asgn        IN       rt_quota_asgn_rec_type := g_miss_rt_quota_asgn_rec,
      x_return_status            OUT NOCOPY VARCHAR2,
      x_msg_count                OUT NOCOPY NUMBER,
      x_msg_data                 OUT NOCOPY VARCHAR2
   )
   IS
      l_api_name           CONSTANT VARCHAR2 (30) := 'validate_rate_table_assignment';
      l_api_version        CONSTANT NUMBER := 1.0;
      l_counter                     NUMBER;
      l_name                        VARCHAR2 (1000);
      l_loading_status              VARCHAR2 (240);
      l_formula_type                CN_QUOTAS.QUOTA_TYPE_CODE%TYPE ;
      l_formula_dim                 CN_CALC_FORMULAS.NUMBER_DIM%TYPE;
      l_rate_dim                    CN_RATE_SCHEDULES.NUMBER_DIM%TYPE;
   BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT check_rt_quota_asgn;

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

      IF p_action = 'DELETE'
      THEN
         NULL;
      ELSE
         IF NOT cn_plan_element_pvt.is_valid_org(p_rt_quota_asgn.org_id,p_rt_quota_asgn.quota_id)
         THEN
            RAISE fnd_api.g_exc_error;
         END IF;

         IF p_rt_quota_asgn.rate_schedule_id IS NULL
         THEN
            IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
            THEN
               fnd_message.set_name ('CN', 'CN_INPUT_CANT_NULL');
               fnd_message.set_token ('INPUT_NAME', cn_api.get_lkup_meaning ('CALC_FORMULA_ID', 'PE_OBJECT_TYPE'));
               fnd_msg_pub.ADD;
               RAISE fnd_api.g_exc_error;
            END IF;
         ELSE
            BEGIN
               SELECT NAME
                 INTO l_name
                 FROM cn_rate_schedules
                WHERE rate_schedule_id = p_rt_quota_asgn.rate_schedule_id;
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
                  THEN
                     fnd_message.set_name ('CN', 'CN_RATE_SCH_NOT_EXIST');
                     fnd_msg_pub.ADD;
                  END IF;

                  RAISE fnd_api.g_exc_error;
            END;
         END IF;

         IF p_rt_quota_asgn.quota_id IS NULL
         THEN
            IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
            THEN
               fnd_message.set_name ('CN', 'CN_INPUT_CANT_NULL');
               fnd_message.set_token ('INPUT_NAME', cn_api.get_lkup_meaning ('PE_NAME', 'INPUT_TOKEN'));
               fnd_msg_pub.ADD;
               RAISE fnd_api.g_exc_error;
            END IF;
         ELSE
            BEGIN
               SELECT name, quota_type_code
                 INTO l_name , l_formula_type
                 FROM cn_quotas
                WHERE quota_id = p_rt_quota_asgn.quota_id;
            EXCEPTION
               WHEN OTHERS
               THEN
                  IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
                  THEN
                     fnd_message.set_name ('CN', 'CN_INVALID_DATA');
                     fnd_message.set_token ('OBJ_NAME', cn_api.get_lkup_meaning ('PE_NAME', 'INPUT_TOKEN'));
                     fnd_msg_pub.ADD;
                  END IF;

                  RAISE fnd_api.g_exc_error;
            END;
         END IF;

         IF p_rt_quota_asgn.calc_formula_id IS NULL
         THEN
            IF l_formula_type = 'FORMULA'  THEN
                IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
                THEN
                   fnd_message.set_name ('CN', 'CN_INPUT_CANT_NULL');
                   fnd_message.set_token ('INPUT_NAME', cn_api.get_lkup_meaning ('CALC_FORMULA_ID', 'PE_OBJECT_TYPE'));
                   fnd_msg_pub.ADD;
                   RAISE fnd_api.g_exc_error;
                END IF;
            END IF ;
         ELSE
            BEGIN
               SELECT NAME
                 INTO l_name
                 FROM cn_calc_formulas fml
                WHERE fml.calc_formula_id = p_rt_quota_asgn.calc_formula_id;
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
                  THEN
                     fnd_message.set_name ('CN', 'CN_FORMULA_NOT_EXIST');
                     fnd_message.set_token ('FORMULA_NAME', p_rt_quota_asgn.calc_formula_id);
                     fnd_msg_pub.ADD;
                  END IF;

                  RAISE fnd_api.g_exc_error;
            END;
         END IF;

         IF (p_rt_quota_asgn.start_date IS NULL)
         THEN
            IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
            THEN
               fnd_message.set_name ('CN', 'CN_INVALID_DATA');
               fnd_message.set_token ('OBJ_NAME', cn_api.get_lkup_meaning ('START_DATE', 'PE_OBJECT_TYPE'));
               fnd_msg_pub.ADD;
            END IF;

            RAISE fnd_api.g_exc_error;
         END IF;

         -- 3.Start Date > End Date
         IF (p_rt_quota_asgn.end_date IS NOT NULL) AND (p_rt_quota_asgn.start_date > p_rt_quota_asgn.end_date)
         THEN
            IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
            THEN
               fnd_message.set_name ('CN', 'CN_DATE_RANGE_ERROR');
               fnd_msg_pub.ADD;
            END IF;

            RAISE fnd_api.g_exc_error;
         END IF;

         -- 4. Check date Effetcivity, quota rate assigns start date and end must
         -- be with start date and end date of the quota date
         cn_chk_plan_element_pkg.chk_date_effective (x_return_status       => x_return_status,
                                                     p_start_date          => p_rt_quota_asgn.start_date,
                                                     p_end_date            => p_rt_quota_asgn.end_date,
                                                     p_quota_id            => p_rt_quota_asgn.quota_id,
                                                     p_object_type         => 'RATE',
                                                     p_loading_status      => l_loading_status,
                                                     x_loading_status      => l_loading_status
                                                    );

         IF x_return_status <> fnd_api.g_ret_sts_success
         THEN
            RAISE fnd_api.g_exc_error;
         END IF;

         -- check that you dont have any rate table in the same date range
         SELECT COUNT (*)
           INTO l_counter
           FROM cn_rt_quota_asgns rta
          WHERE rta.quota_id = p_rt_quota_asgn.quota_id
            AND rta.rt_quota_asgn_id <> NVL (p_rt_quota_asgn.rt_quota_asgn_id, 0)
            AND NVL(rta.calc_formula_id,-1) = NVL(p_rt_quota_asgn.calc_formula_id,-1)
            AND rta.start_date <= NVL (p_rt_quota_asgn.end_date, rta.start_date)
            AND p_rt_quota_asgn.start_date <= NVL(rta.end_date,p_rt_quota_asgn.start_date) ;

         IF l_counter > 0
         THEN
            IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
            THEN
               fnd_message.set_name ('CN', 'CN_DATE_OVERLAP');
               fnd_msg_pub.ADD;
               RAISE fnd_api.g_exc_error;
            END IF;
         END IF;

         -- CHECK THAT NUMBER OF FORMULA DIMS = NUMBER OF RATE DIMS
        IF l_formula_type = 'FORMULA' THEN
         SELECT NUMBER_DIM INTO l_formula_dim FROM CN_CALC_FORMULAS
         WHERE calc_formula_id = p_rt_quota_asgn.calc_formula_id;
         SELECT NUMBER_DIM INTO l_rate_dim FROM CN_RATE_SCHEDULES
         WHERE rate_schedule_id = p_rt_quota_asgn.rate_schedule_id;
         IF l_formula_dim <> l_rate_dim THEN
            IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
            THEN
               fnd_message.set_name ('CN', 'CN_PE_DIMS_NOT_EQUAL');
               fnd_msg_pub.ADD;
               RAISE fnd_api.g_exc_error;
            END IF;
         END IF;

        END IF;
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
         ROLLBACK TO check_rt_quota_asgn;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         ROLLBACK TO check_rt_quota_asgn;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
      WHEN OTHERS
      THEN
         ROLLBACK TO check_rt_quota_asgn;
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
   END validate_rate_table_assignment;
END cn_rt_quota_asgn_pvt;

/
