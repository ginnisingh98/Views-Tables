--------------------------------------------------------
--  DDL for Package Body CN_QUOTA_ASSIGN_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_QUOTA_ASSIGN_PVT" AS
   /*$Header: cnvpnagb.pls 120.9 2006/05/11 06:03:40 kjayapau ship $*/
   g_pkg_name      CONSTANT VARCHAR2 (30) := 'CN_QUOTA_ASSIGN_PVT';
   g_end_of_time   CONSTANT DATE      := TO_DATE ('12-31-9999', 'MM-DD-YYYY');

-- Start of comments
--    API name        : Create_Quota_Assign
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
--                      p_quota_assign       IN  quota_assign_rec_type
--    OUT             : x_return_status       OUT     VARCHAR2(1)
--                      x_msg_count           OUT     NUMBER
--                      x_msg_data            OUT     VARCHAR2(2000)
--    Version :         Current version       1.0
--    Notes           : Note text
--
-- End of comments
   PROCEDURE create_quota_assign (
      p_api_version        IN              NUMBER,
      p_init_msg_list      IN              VARCHAR2 := fnd_api.g_false,
      p_commit             IN              VARCHAR2 := fnd_api.g_false,
      p_validation_level   IN              NUMBER
            := fnd_api.g_valid_level_full,
      p_quota_assign       IN OUT NOCOPY   quota_assign_rec_type,
      x_return_status      OUT NOCOPY      VARCHAR2,
      x_msg_count          OUT NOCOPY      NUMBER,
      x_msg_data           OUT NOCOPY      VARCHAR2
   )
   IS
      l_api_name      CONSTANT VARCHAR2 (30)         := 'Create_Quota_Assign';
      l_api_version   CONSTANT NUMBER                                  := 1.0;
      l_temp_count             NUMBER;
      l_msg_count              NUMBER;
      l_msg_data               VARCHAR2 (2000);
      l_quota_id               cn_quotas.quota_id%TYPE;
      l_quota_assign_id        cn_quota_assigns.quota_assign_id%TYPE;
      l_comp_plan_id           cn_comp_plans.comp_plan_id%TYPE;
      l_org_id                 cn_quota_assigns.org_id%TYPE;
      l_quota_tbl              cn_calc_sql_exps_pvt.num_tbl_type;
      l_note_msg               VARCHAR2 (240);
      l_note_id                NUMBER;
      l_cp_name                cn_comp_plans.NAME%TYPE;
      l_pe_name                cn_quotas.NAME%TYPE;

      CURSOR objversion_cur IS
      SELECT object_version_number
      FROM   cn_quota_assigns
      WHERE  quota_assign_id = p_quota_assign.quota_assign_id;

   BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT create_quota_assign;

      -- Standard call to check for call compatibility.
      IF NOT fnd_api.compatible_api_call (l_api_version,
                                          p_api_version,
                                          l_api_name,
                                          g_pkg_name
                                         )
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

      -- Convert fnd_api.g_miss to NULL

      -- 1. name can not be null
      IF    (p_quota_assign.comp_plan_id IS NULL)
         OR (p_quota_assign.comp_plan_id = fnd_api.g_miss_num)
         OR (p_quota_assign.quota_id IS NULL)
         OR (p_quota_assign.quota_id = fnd_api.g_miss_num)
      THEN
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
         THEN
            fnd_message.set_name ('CN', 'CN_REQ_PAR_MISSING');
            fnd_msg_pub.ADD;
         END IF;

         RAISE fnd_api.g_exc_error;
      END IF;

      -- 2. quota assign name must be unique
      SELECT COUNT (1)
        INTO l_temp_count
        FROM cn_quota_assigns
       WHERE comp_plan_id = p_quota_assign.comp_plan_id
         AND quota_id = p_quota_assign.quota_id
         AND ROWNUM = 1;

      IF l_temp_count <> 0
      THEN
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
         THEN
            fnd_message.set_name ('CN', 'CN_INPUT_MUST_UNIQUE');
            fnd_message.set_token ('INPUT_NAME',
                                   cn_api.get_lkup_meaning ('PE_NAME',
                                                            'INPUT_TOKEN'
                                                           )
                                  );
            fnd_msg_pub.ADD;
         END IF;

         RAISE fnd_api.g_exc_error;
      END IF;

      -- 3. quota dates must overlap plan dates
      SELECT COUNT (1)
        INTO l_temp_count
        FROM cn_comp_plans c, cn_quotas_v q
       WHERE c.comp_plan_id = p_quota_assign.comp_plan_id
         AND q.quota_id = p_quota_assign.quota_id
         AND GREATEST (c.start_date, q.start_date) <=
                LEAST (NVL (c.end_date, g_end_of_time),
                       NVL (q.end_date, g_end_of_time)
                      );

      IF l_temp_count = 0
      THEN
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
         THEN
            fnd_message.set_name ('CN', 'CN_PLAN_ELT_DISJOINT');
            fnd_msg_pub.ADD;
         END IF;

         RAISE fnd_api.g_exc_error;
      END IF;

      -- 4. interdependent quotas must reference only quotas with lower
      -- sequence number and must reference quotas in same plan
	IF p_quota_assign.IDQ_FLAG is null THEN

      cn_calc_sql_exps_pvt.get_dependent_plan_elts
                                        (p_api_version          => 1.0,
                                         p_node_type            => 'P',
                                         p_node_id              => p_quota_assign.quota_id,
                                         x_plan_elt_id_tbl      => l_quota_tbl,
                                         x_return_status        => x_return_status,
                                         x_msg_count            => l_msg_count,
                                         x_msg_data             => l_msg_data
                                        );

      FOR i IN 0 .. l_quota_tbl.COUNT - 1
      LOOP
         -- for each PE in this loop, make sure it exists in plan with
         -- lower seq number
         SELECT COUNT (1)
           INTO l_temp_count
           FROM cn_quota_assigns
          WHERE comp_plan_id = p_quota_assign.comp_plan_id
            AND quota_id = l_quota_tbl (i)
            AND quota_sequence < p_quota_assign.quota_sequence;

         IF l_temp_count = 0
         THEN
            IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
            THEN
               fnd_message.set_name ('CN', 'CN_IDQ_REFERENCE_NOT_VALID');
               fnd_msg_pub.ADD;
            END IF;

            RAISE fnd_api.g_exc_error;
         END IF;
      END LOOP;

	END IF;

      -- do comp plan quota assignment
      SELECT DECODE (p_quota_assign.quota_id,
                     fnd_api.g_miss_num, NULL,
                     p_quota_assign.quota_id
                    ),
             DECODE (p_quota_assign.comp_plan_id,
                     fnd_api.g_miss_num, NULL,
                     p_quota_assign.comp_plan_id
                    ),
             DECODE (p_quota_assign.org_id,
                     fnd_api.g_miss_num, NULL,
                     p_quota_assign.org_id
                    )
        INTO l_quota_id,
             l_comp_plan_id,
             l_org_id
        FROM DUAL;

      cn_quota_assigns_pkg.begin_record
                           (x_operation            => 'INSERT',
                            x_quota_id             => l_quota_id,
                            x_comp_plan_id         => l_comp_plan_id,
                            x_quota_assign_id      => p_quota_assign.quota_assign_id,
                            x_quota_sequence       => p_quota_assign.quota_sequence,
                            x_quota_id_old         => NULL,
                            x_org_id               => l_org_id
                           );
      cn_comp_plans_pkg.set_status (x_comp_plan_id          => l_comp_plan_id,
                                    x_quota_id              => NULL,
                                    x_rate_schedule_id      => NULL,
                                    x_status_code           => 'INCOMPLETE',
                                    x_event                 => NULL
                                   );


      IF (l_quota_id > 0 AND l_comp_plan_id > 0)
      THEN
         SELECT NAME
           INTO l_pe_name
           FROM cn_quotas_all
          WHERE quota_id = l_quota_id;

         SELECT NAME
           INTO l_cp_name
           FROM cn_comp_plans
          WHERE comp_plan_id = l_comp_plan_id;

         fnd_message.set_name ('CN', 'CNR12_NOTE_COMPPLAN_ASPE_AS');
         fnd_message.set_token ('PE_NAME', l_pe_name);
         fnd_message.set_token ('CP_NAME', l_cp_name);
         l_note_msg := fnd_message.get;
         jtf_notes_pub.create_note
                (p_api_version             => 1.0,
                 x_return_status           => x_return_status,
                 x_msg_count               => x_msg_count,
                 x_msg_data                => x_msg_data,
                 p_source_object_id        => l_comp_plan_id,
                                                          --l_quota_assign_id,
                 p_source_object_code      => 'CN_COMP_PLANS',
                                                         --'CN_QUOTA_ASSIGNS',
                 p_notes                   => l_note_msg,
                 p_notes_detail            => l_note_msg,
                 p_note_type               => 'CN_SYSGEN',
                                                       -- for system generated
                 x_jtf_note_id             => l_note_id            -- returned
                );
      END IF;


     OPEN objversion_cur;
     FETCH objversion_cur INTO p_quota_assign.OBJECT_VERSION_NUMBER;
     CLOSE objversion_cur;

      -- End of API body.
      -- Standard check of p_commit.
      IF fnd_api.to_boolean (p_commit)
      THEN
         COMMIT WORK;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      fnd_msg_pub.count_and_get (p_count        => x_msg_count,
                                 p_data         => x_msg_data,
                                 p_encoded      => fnd_api.g_false
                                );
   EXCEPTION
      WHEN fnd_api.g_exc_error
      THEN
         ROLLBACK TO create_quota_assign;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (p_count        => x_msg_count,
                                    p_data         => x_msg_data,
                                    p_encoded      => fnd_api.g_false
                                   );
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         ROLLBACK TO create_quota_assign;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (p_count        => x_msg_count,
                                    p_data         => x_msg_data,
                                    p_encoded      => fnd_api.g_false
                                   );
      WHEN OTHERS
      THEN
         ROLLBACK TO create_quota_assign;
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get (p_count        => x_msg_count,
                                    p_data         => x_msg_data,
                                    p_encoded      => fnd_api.g_false
                                   );
   END create_quota_assign;

-- Start of comments
--      API name        : Update_Quota_Assign
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
--                        p_quota_assign         IN quota_assign_rec_type
--      OUT             : x_return_status     OUT     VARCHAR2(1)
--                        x_msg_count         OUT     NUMBER
--                        x_msg_data          OUT     VARCHAR2(2000)
--      Version :         Current version     1.0
--      Notes           : Note text
--
-- End of comments
   PROCEDURE update_quota_assign (
      p_api_version        IN              NUMBER,
      p_init_msg_list      IN              VARCHAR2 := fnd_api.g_false,
      p_commit             IN              VARCHAR2 := fnd_api.g_false,
      p_validation_level   IN              NUMBER
            := fnd_api.g_valid_level_full,
      p_quota_assign       IN OUT NOCOPY   quota_assign_rec_type,
      x_return_status      OUT NOCOPY      VARCHAR2,
      x_msg_count          OUT NOCOPY      NUMBER,
      x_msg_data           OUT NOCOPY      VARCHAR2
   )
   IS
      l_api_name      CONSTANT VARCHAR2 (30)         := 'Update_Quota_Assign';
      l_api_version   CONSTANT NUMBER                                  := 1.0;

      CURSOR l_old_quota_assign_cr
      IS
         SELECT *
           FROM cn_quota_assigns
          WHERE quota_assign_id = p_quota_assign.quota_assign_id;

      CURSOR objversion_cur IS
      SELECT object_version_number
      FROM   cn_quota_assigns
      WHERE  quota_assign_id = p_quota_assign.quota_assign_id;

      l_old_quota_assign       l_old_quota_assign_cr%ROWTYPE;
      l_quota_assign           quota_assign_rec_type;
      l_temp_count             NUMBER;
      l_quota_id               cn_quotas.quota_id%TYPE;
      l_quota_assign_id        cn_quota_assigns.quota_assign_id%TYPE;
      l_comp_plan_id           cn_comp_plans.comp_plan_id%TYPE;
      l_quota_tbl              cn_calc_sql_exps_pvt.num_tbl_type;
      l_msg_count              NUMBER;
      l_msg_data               VARCHAR2 (2000);
      l_org_id                 cn_quota_assigns.org_id%TYPE;
      l_note_msg               VARCHAR2 (240);
      l_note_id                NUMBER;
      l_cp_name                cn_comp_plans.NAME%TYPE;
      l_pe_name                cn_quotas.NAME%TYPE;
      l_consolidated_note       VARCHAR2(2000);
      old_seq                   CN_QUOTA_ASSIGNS.QUOTA_SEQUENCE%TYPE;

   BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT update_quota_assign;

      -- Standard call to check for call compatibility.
      IF NOT fnd_api.compatible_api_call (l_api_version,
                                          p_api_version,
                                          l_api_name,
                                          g_pkg_name
                                         )
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
      IF    (p_quota_assign.comp_plan_id IS NULL)
         OR (p_quota_assign.quota_id IS NULL)
      THEN
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
         THEN
            fnd_message.set_name ('CN', 'CN_REQ_PAR_MISSING');
            fnd_msg_pub.ADD;
         END IF;

         RAISE fnd_api.g_exc_error;
      END IF;

    -- Getting Old Sequence
    select count(1) into l_temp_count from cn_quota_assigns  where quota_id = p_quota_assign.quota_id and comp_plan_id = p_quota_assign.comp_plan_id;

    IF l_temp_count <> 0
    THEN
        select QUOTA_SEQUENCE into old_seq from cn_quota_assigns  where quota_id = p_quota_assign.quota_id and comp_plan_id = p_quota_assign.comp_plan_id;
    ELSE
        old_seq := p_quota_assign.quota_sequence;
    END IF;


      -- 2. quota assign name must be unique
      SELECT COUNT (1)
        INTO l_temp_count
        FROM cn_quota_assigns
       WHERE comp_plan_id = p_quota_assign.comp_plan_id
         AND quota_id = p_quota_assign.quota_id
         AND quota_assign_id <> p_quota_assign.quota_assign_id
         AND ROWNUM = 1;

      IF l_temp_count <> 0
      THEN
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
         THEN
            fnd_message.set_name ('CN', 'CN_INPUT_MUST_UNIQUE');
            fnd_message.set_token ('INPUT_NAME',
                                   cn_api.get_lkup_meaning ('PE_NAME',
                                                            'INPUT_TOKEN'
                                                           )
                                  );
            fnd_msg_pub.ADD;
         END IF;

         RAISE fnd_api.g_exc_error;
      END IF;

      OPEN l_old_quota_assign_cr;

      FETCH l_old_quota_assign_cr
       INTO l_old_quota_assign;

      CLOSE l_old_quota_assign_cr;

      SELECT DECODE (p_quota_assign.comp_plan_id,
                     fnd_api.g_miss_num, l_old_quota_assign.comp_plan_id,
                     p_quota_assign.comp_plan_id
                    ),
             DECODE (p_quota_assign.quota_id,
                     fnd_api.g_miss_num, l_old_quota_assign.quota_id,
                     p_quota_assign.quota_id
                    ),
             p_quota_assign.quota_assign_id,
             DECODE (p_quota_assign.org_id,
                     fnd_api.g_miss_num, l_old_quota_assign.org_id,
                     p_quota_assign.org_id
                    )
        INTO l_comp_plan_id,
             l_quota_id,
             l_quota_assign_id,
             l_org_id
        FROM DUAL;

      -- 3. quota dates must overlap plan dates
      SELECT COUNT (1)
        INTO l_temp_count
        FROM cn_comp_plans c, cn_quotas_v q
       WHERE c.comp_plan_id = p_quota_assign.comp_plan_id
         AND q.quota_id = p_quota_assign.quota_id
         AND GREATEST (c.start_date, q.start_date) <=
                LEAST (NVL (c.end_date, g_end_of_time),
                       NVL (q.end_date, g_end_of_time)
                      );

      IF l_temp_count = 0
      THEN
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
         THEN
            fnd_message.set_name ('CN', 'CN_PLAN_ELT_DISJOINT');
            fnd_msg_pub.ADD;
         END IF;

         RAISE fnd_api.g_exc_error;
      END IF;

      -- 4. interdependent quotas must reference only quotas with lower
      -- sequence number and must reference quotas in same plan

	IF p_quota_assign.IDQ_FLAG is null THEN

      cn_calc_sql_exps_pvt.get_dependent_plan_elts
                                        (p_api_version          => 1.0,
                                         p_node_type            => 'P',
                                         p_node_id              => p_quota_assign.quota_id,
                                         x_plan_elt_id_tbl      => l_quota_tbl,
                                         x_return_status        => x_return_status,
                                         x_msg_count            => l_msg_count,
                                         x_msg_data             => l_msg_data
                                        );

      FOR i IN 0 .. l_quota_tbl.COUNT - 1
      LOOP
         -- for each PE in this loop, make sure it exists in plan with
         -- lower seq number
         SELECT COUNT (1)
           INTO l_temp_count
           FROM cn_quota_assigns
          WHERE comp_plan_id = p_quota_assign.comp_plan_id
            AND quota_id = l_quota_tbl (i)
            AND quota_sequence < p_quota_assign.quota_sequence;

         IF l_temp_count = 0
         THEN
            IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
            THEN
               fnd_message.set_name ('CN', 'CN_IDQ_REFERENCE_NOT_VALID');
               fnd_msg_pub.ADD;
            END IF;

            RAISE fnd_api.g_exc_error;
         END IF;
      END LOOP;

	END IF;

      -- 5. check object version number
      IF l_old_quota_assign.object_version_number <>
                                          p_quota_assign.object_version_number
      THEN
         fnd_message.set_name ('CN', 'CN_RECORD_CHANGED');
         fnd_msg_pub.ADD;
         RAISE fnd_api.g_exc_error;
      END IF;

      cn_quota_assigns_pkg.begin_record
                           (x_operation            => 'UPDATE',
                            x_quota_id             => l_quota_id,
                            x_comp_plan_id         => l_comp_plan_id,
                            x_quota_assign_id      => p_quota_assign.quota_assign_id,
                            x_quota_sequence       => p_quota_assign.quota_sequence,
                            x_quota_id_old         => l_old_quota_assign.quota_id,
                            x_org_id               => l_org_id
                           );
      cn_comp_plans_pkg.set_status (x_comp_plan_id          => l_comp_plan_id,
                                    x_quota_id              => NULL,
                                    x_rate_schedule_id      => NULL,
                                    x_status_code           => 'INCOMPLETE',
                                    x_event                 => NULL
                                   );

      l_consolidated_note := '';

      IF (p_quota_assign.quota_sequence <> old_seq)
      THEN
           SELECT NAME
           INTO l_pe_name
           FROM cn_quotas_all
          WHERE quota_id = l_quota_id;

         SELECT NAME
           INTO l_cp_name
           FROM cn_comp_plans
          WHERE comp_plan_id = l_comp_plan_id;

         fnd_message.set_name ('CN', 'CN_PA_CP_QA_CALC_SEQ_NOTES');
         fnd_message.set_token ('PE_NAME', l_pe_name);
         fnd_message.set_token ('CP_NAME', l_cp_name);
         fnd_message.set_token ('OLD_SEQ', old_seq);
         fnd_message.set_token ('NEW_SEQ', p_quota_assign.quota_sequence);
         l_consolidated_note := fnd_message.get;

      ELSE IF (l_quota_id > 0 AND l_comp_plan_id > 0)
      THEN
         SELECT NAME
           INTO l_pe_name
           FROM cn_quotas_all
          WHERE quota_id = l_quota_id;

         SELECT NAME
           INTO l_cp_name
           FROM cn_comp_plans
          WHERE comp_plan_id = l_comp_plan_id;

         fnd_message.set_name ('CN', 'CNR12_NOTE_COMPPLAN_ASPE_AS');
         fnd_message.set_token ('PE_NAME', l_pe_name);
         fnd_message.set_token ('CP_NAME', l_cp_name);
         l_note_msg := fnd_message.get;
         l_consolidated_note := l_note_msg || fnd_global.local_chr(10);
         /*jtf_notes_pub.create_note
                (p_api_version             => 1.0,
                 x_return_status           => x_return_status,
                 x_msg_count               => x_msg_count,
                 x_msg_data                => x_msg_data,
                 p_source_object_id        => l_comp_plan_id,
                                                          --l_quota_assign_id,
                 p_source_object_code      => 'CN_COMP_PLANS',
                                                         --'CN_QUOTA_ASSIGNS',
                 p_notes                   => l_note_msg,
                 p_notes_detail            => l_note_msg,
                 p_note_type               => 'CN_SYSGEN',
                                                       -- for system generated
                 x_jtf_note_id             => l_note_id            -- returned
                );*/

         SELECT NAME
           INTO l_pe_name
           FROM cn_quotas_all
          WHERE quota_id = l_old_quota_assign.quota_id;

         fnd_message.set_name ('CN', 'CNR12_NOTE_COMPPLAN_ASPE_UNAS');
         fnd_message.set_token ('PE_NAME', l_pe_name);
         fnd_message.set_token ('CP_NAME', l_cp_name);
         l_note_msg := fnd_message.get;
         l_consolidated_note := l_consolidated_note || l_note_msg ||fnd_global.local_chr(10);

         /*jtf_notes_pub.create_note
                           (p_api_version             => 1.0,
                            x_return_status           => x_return_status,
                            x_msg_count               => x_msg_count,
                            x_msg_data                => x_msg_data,
                            p_source_object_id        => l_comp_plan_id,
                            p_source_object_code      => 'CN_COMP_PLANS',
                            p_notes                   => l_note_msg,
                            p_notes_detail            => l_note_msg,
                            p_note_type               => 'CN_SYSGEN',
                                                       -- for system generated
                            x_jtf_note_id             => l_note_id -- returned
                           );*/
      END IF;
	END IF;

      IF LENGTH(l_consolidated_note) > 1 THEN

        jtf_notes_pub.create_note (p_api_version             => 1.0,
	                           x_return_status           => x_return_status,
	                           x_msg_count               => x_msg_count,
	                           x_msg_data                => x_msg_data,
	                           p_source_object_id        => l_comp_plan_id,
	                           p_source_object_code      => 'CN_COMP_PLANS',
	                           p_notes                   => l_consolidated_note,
	                           p_notes_detail            => l_consolidated_note,
	                           p_note_type               => 'CN_SYSGEN',                                                  -- for system generated
	                           x_jtf_note_id             => l_note_id                                                                 -- returned
                                   );
      END IF;

      -- End of API body.
      -- Standard check of p_commit.
     OPEN objversion_cur;
     FETCH objversion_cur into p_quota_assign.OBJECT_VERSION_NUMBER;
     CLOSE objversion_cur;

      IF fnd_api.to_boolean (p_commit)
      THEN
         COMMIT WORK;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      fnd_msg_pub.count_and_get (p_count        => x_msg_count,
                                 p_data         => x_msg_data,
                                 p_encoded      => fnd_api.g_false
                                );
   EXCEPTION
      WHEN fnd_api.g_exc_error
      THEN
         ROLLBACK TO update_quota_assign;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (p_count        => x_msg_count,
                                    p_data         => x_msg_data,
                                    p_encoded      => fnd_api.g_false
                                   );
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         ROLLBACK TO update_quota_assign;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (p_count        => x_msg_count,
                                    p_data         => x_msg_data,
                                    p_encoded      => fnd_api.g_false
                                   );
      WHEN OTHERS
      THEN
         ROLLBACK TO update_quota_assign;
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get (p_count        => x_msg_count,
                                    p_data         => x_msg_data,
                                    p_encoded      => fnd_api.g_false
                                   );
   END update_quota_assign;

-- Start of comments
--      API name        : Delete_Quota_Assign
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
--                        p_quota_assign      IN quota_assign_rec_type
--      OUT             : x_return_status     OUT     VARCHAR2(1)
--                        x_msg_count         OUT     NUMBER
--                        x_msg_data          OUT     VARCHAR2(2000)
--      Version :         Current version     1.0
--      Notes           : Note text
--
-- End of comments
   PROCEDURE delete_quota_assign (
      p_api_version        IN              NUMBER,
      p_init_msg_list      IN              VARCHAR2 := fnd_api.g_false,
      p_commit             IN              VARCHAR2 := fnd_api.g_false,
      p_validation_level   IN              NUMBER
            := fnd_api.g_valid_level_full,
      p_quota_assign       IN              quota_assign_rec_type,
      x_return_status      OUT NOCOPY      VARCHAR2,
      x_msg_count          OUT NOCOPY      NUMBER,
      x_msg_data           OUT NOCOPY      VARCHAR2
   )
   IS
      l_api_name      CONSTANT VARCHAR2 (30)         := 'Delete_Quota_Assign';
      l_api_version   CONSTANT NUMBER                                  := 1.0;
      l_temp_count             NUMBER;
      l_quota_id               cn_quotas.quota_id%TYPE;
      l_quota_assign_id        cn_quota_assigns.quota_assign_id%TYPE;
      l_comp_plan_id           cn_comp_plans.comp_plan_id%TYPE;
      l_org_id                 cn_quota_assigns.org_id%TYPE;
      l_note_msg               VARCHAR2 (240);
      l_note_id                NUMBER;
      l_cp_name                cn_comp_plans.NAME%TYPE;
      l_pe_name                cn_quotas.NAME%TYPE;
   BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT delete_quota_assign;

      -- Standard call to check for call compatibility.
      IF NOT fnd_api.compatible_api_call (l_api_version,
                                          p_api_version,
                                          l_api_name,
                                          g_pkg_name
                                         )
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

      -- do comp plan quota assignment
      BEGIN
         SELECT quota_assign_id, quota_id, comp_plan_id, org_id
           INTO l_quota_assign_id, l_quota_id, l_comp_plan_id, l_org_id
           FROM cn_quota_assigns
          WHERE quota_assign_id = p_quota_assign.quota_assign_id;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            fnd_message.set_name ('CN', 'CN_RECORD_DELETED');
            fnd_msg_pub.ADD;
            RAISE fnd_api.g_exc_unexpected_error;
      END;

      cn_quota_assigns_pkg.begin_record
                                      (x_operation            => 'DELETE',
                                       x_quota_id             => l_quota_id,
                                       x_comp_plan_id         => l_comp_plan_id,
                                       x_quota_assign_id      => l_quota_assign_id,
                                       x_quota_sequence       => NULL,
                                       x_quota_id_old         => NULL,
                                       x_org_id               => l_org_id
                                      );
      cn_comp_plans_pkg.set_status (x_comp_plan_id          => l_comp_plan_id,
                                    x_quota_id              => NULL,
                                    x_rate_schedule_id      => NULL,
                                    x_status_code           => 'INCOMPLETE',
                                    x_event                 => NULL
                                   );

      -- During deltion the logical parent is CN_COMP_PLANS for CN_QUOTA_ASSIGNS
      IF (l_quota_id > 0 AND l_comp_plan_id > 0)
      THEN
         SELECT NAME
           INTO l_pe_name
           FROM cn_quotas_all
          WHERE quota_id = l_quota_id;

         SELECT NAME
           INTO l_cp_name
           FROM cn_comp_plans
          WHERE comp_plan_id = l_comp_plan_id;

         fnd_message.set_name ('CN', 'CNR12_NOTE_COMPPLAN_ASPE_UNAS');
         fnd_message.set_token ('PE_NAME', l_pe_name);
         fnd_message.set_token ('CP_NAME', l_cp_name);
         l_note_msg := fnd_message.get;
         jtf_notes_pub.create_note
                           (p_api_version             => 1.0,
                            x_return_status           => x_return_status,
                            x_msg_count               => x_msg_count,
                            x_msg_data                => x_msg_data,
                            p_source_object_id        => l_comp_plan_id,
                            p_source_object_code      => 'CN_COMP_PLANS',
                            p_notes                   => l_note_msg,
                            p_notes_detail            => l_note_msg,
                            p_note_type               => 'CN_SYSGEN',
                                                       -- for system generated
                            x_jtf_note_id             => l_note_id -- returned
                           );
      END IF;

      -- End of API body.
      -- Standard check of p_commit.
      IF fnd_api.to_boolean (p_commit)
      THEN
         COMMIT WORK;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      fnd_msg_pub.count_and_get (p_count        => x_msg_count,
                                 p_data         => x_msg_data,
                                 p_encoded      => fnd_api.g_false
                                );
   EXCEPTION
      WHEN fnd_api.g_exc_error
      THEN
         ROLLBACK TO delete_quota_assign;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (p_count        => x_msg_count,
                                    p_data         => x_msg_data,
                                    p_encoded      => fnd_api.g_false
                                   );
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         ROLLBACK TO delete_quota_assign;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (p_count        => x_msg_count,
                                    p_data         => x_msg_data,
                                    p_encoded      => fnd_api.g_false
                                   );
      WHEN OTHERS
      THEN
         ROLLBACK TO delete_quota_assign;
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get (p_count        => x_msg_count,
                                    p_data         => x_msg_data,
                                    p_encoded      => fnd_api.g_false
                                   );
   END delete_quota_assign;

-- Start of comments
--      API name        : Get_Quota_Assign
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
--                        p_comp_plan_id      IN NUMBER
--      OUT             : x_return_status     OUT     VARCHAR2(1)
--                        x_msg_count         OUT     NUMBER
--                        x_msg_data          OUT     VARCHAR2(2000)
--                        x_quota_assign      OUT     quota_assign_tbl_type
--      Version :         Current version     1.0
--      Notes           : Note text
--
-- End of comments
   PROCEDURE get_quota_assign (
      p_api_version        IN              NUMBER,
      p_init_msg_list      IN              VARCHAR2 := fnd_api.g_false,
      p_commit             IN              VARCHAR2 := fnd_api.g_false,
      p_validation_level   IN              NUMBER
            := fnd_api.g_valid_level_full,
      p_comp_plan_id       IN              NUMBER,
      x_quota_assign       OUT NOCOPY      quota_assign_tbl_type,
      x_return_status      OUT NOCOPY      VARCHAR2,
      x_msg_count          OUT NOCOPY      NUMBER,
      x_msg_data           OUT NOCOPY      VARCHAR2
   )
   IS
      l_api_name      CONSTANT VARCHAR2 (30) := 'Get_Quota_Assign';
      l_api_version   CONSTANT NUMBER        := 1.0;
      l_counter                NUMBER;

      CURSOR l_quota_assign_cr
      IS
         SELECT   q.NAME, q.description, q.start_date, q.end_date,
                  qa.quota_assign_id, qa.quota_id, qa.comp_plan_id,
                  NVL (qa.quota_sequence, 0) quota_sequence,
                  qa.object_version_number, qa.org_id
             FROM cn_quota_assigns qa, cn_quotas_v q
            WHERE qa.comp_plan_id = p_comp_plan_id
              AND qa.quota_id = q.quota_id
         ORDER BY quota_sequence;
   BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT get_quota_assign;

      -- Standard call to check for call compatibility.
      IF NOT fnd_api.compatible_api_call (l_api_version,
                                          p_api_version,
                                          l_api_name,
                                          g_pkg_name
                                         )
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
      x_quota_assign := g_miss_quota_assign_rec_tb;
      l_counter := 0;

      FOR l_quota_assign IN l_quota_assign_cr
      LOOP
         l_counter := l_counter + 1;
         x_quota_assign (l_counter).quota_assign_id :=
                                               l_quota_assign.quota_assign_id;
         x_quota_assign (l_counter).NAME := l_quota_assign.NAME;
         x_quota_assign (l_counter).description := l_quota_assign.description;
         x_quota_assign (l_counter).quota_id := l_quota_assign.quota_id;
         x_quota_assign (l_counter).comp_plan_id :=
                                                  l_quota_assign.comp_plan_id;
         x_quota_assign (l_counter).start_date := l_quota_assign.start_date;
         x_quota_assign (l_counter).end_date := l_quota_assign.end_date;
         x_quota_assign (l_counter).quota_sequence :=
                                                l_quota_assign.quota_sequence;
         x_quota_assign (l_counter).object_version_number :=
                                         l_quota_assign.object_version_number;
         x_quota_assign (l_counter).org_id := l_quota_assign.org_id;
      END LOOP;

      -- End of API body.
      -- Standard check of p_commit.
      IF fnd_api.to_boolean (p_commit)
      THEN
         COMMIT WORK;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      fnd_msg_pub.count_and_get (p_count        => x_msg_count,
                                 p_data         => x_msg_data,
                                 p_encoded      => fnd_api.g_false
                                );
   EXCEPTION
      WHEN fnd_api.g_exc_error
      THEN
         ROLLBACK TO get_quota_assign;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (p_count        => x_msg_count,
                                    p_data         => x_msg_data,
                                    p_encoded      => fnd_api.g_false
                                   );
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         ROLLBACK TO get_quota_assign;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (p_count        => x_msg_count,
                                    p_data         => x_msg_data,
                                    p_encoded      => fnd_api.g_false
                                   );
      WHEN OTHERS
      THEN
         ROLLBACK TO get_quota_assign;
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get (p_count        => x_msg_count,
                                    p_data         => x_msg_data,
                                    p_encoded      => fnd_api.g_false
                                   );
   END get_quota_assign;
END cn_quota_assign_pvt;

/
