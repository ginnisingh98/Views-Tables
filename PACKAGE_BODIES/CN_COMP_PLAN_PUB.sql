--------------------------------------------------------
--  DDL for Package Body CN_COMP_PLAN_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_COMP_PLAN_PUB" AS
/* $Header: cnpcpb.pls 120.8.12010000.3 2009/09/01 04:12:47 scannane ship $ */
   g_pkg_name    CONSTANT VARCHAR2 (30) := 'CN_COMP_PLAN_PUB';
   g_file_name   CONSTANT VARCHAR2 (12) := 'cnpcpb.pls';
   g_rowid                VARCHAR2 (30);
   g_program_type         VARCHAR2 (30);

--| ----------------------------------------------------------------------+
--| Procedure : valid_pe_assign
--| Desc : Procedure to validate plan element assignment to a compensation
--|        plan.
--| --------------------------------------------------------------------+
   PROCEDURE valid_pe_assign
   (
      x_return_status    OUT NOCOPY      VARCHAR2,
      x_msg_count        OUT NOCOPY      NUMBER,
      x_msg_data         OUT NOCOPY      VARCHAR2,
      p_cp_name          IN              VARCHAR2,
      p_pe_name          IN              VARCHAR2,
      p_cp_start_date    IN              DATE,
      p_cp_end_date      IN              DATE,
      p_loading_status   IN              VARCHAR2,
      p_org_id           IN              NUMBER,
      x_cp_id            OUT NOCOPY      NUMBER,
      x_pe_id            OUT NOCOPY      NUMBER,
      x_loading_status   OUT NOCOPY      VARCHAR2
   )
   IS
      l_api_name        CONSTANT VARCHAR2 (30)           := 'valid_pe_assign';
      l_dummy                    NUMBER;
      l_rc_overlap               cn_comp_plans.allow_rev_class_overlap%TYPE;
      l_rev_class_total          NUMBER                                  := 0;
      l_rev_class_total_unique   NUMBER                                  := 0;
      l_quota_type_code          cn_quotas.quota_type_code%TYPE;
      l_quota_start_date         DATE;
      l_quota_end_date           DATE;
	l_flag			   BOOLEAN;

      -- Since cn_dim_hier_periods is gone, we also need to change this
      CURSOR check_overlap_curs (
         l_cp_id                    NUMBER,
         l_rev_class_hierarchy_id   NUMBER
      )
      IS
         SELECT COUNT (de.value_external_id),
                COUNT (DISTINCT de.value_external_id)
           FROM cn_dim_explosion de,
                cn_quota_rules qr,
                cn_quota_assigns qa,
                cn_quotas_v q,
                cn_dim_hierarchies dh
          WHERE dh.header_dim_hierarchy_id = l_rev_class_hierarchy_id
            AND (   (    q.end_date IS NULL
                     AND NVL (TRUNC (dh.end_date), TRUNC (q.start_date)) >=
                                                          TRUNC (q.start_date)
                    )
                 OR (    q.end_date IS NOT NULL
                     AND (   TRUNC (dh.start_date) BETWEEN TRUNC (q.start_date)
                                                       AND TRUNC (q.end_date)
                          OR (    TRUNC (dh.start_date) < TRUNC (q.start_date)
                              AND NVL (TRUNC (dh.end_date),
                                       TRUNC (q.end_date))
                                     BETWEEN TRUNC (q.start_date)
                                         AND TRUNC (q.end_date)
                             )
                         )
                    )
                )
            AND de.dim_hierarchy_id = dh.dim_hierarchy_id
            AND de.ancestor_external_id = qr.revenue_class_id
            AND qr.quota_id = qa.quota_id
            AND qa.comp_plan_id = l_cp_id
            AND qa.quota_id = q.quota_id
            -- only formula and external have revenue classes
            -- Modified
            AND q.quota_type_code IN ('EXTERNAL', 'FORMULA');
   BEGIN
      --  Initialize API return status to success
      x_return_status := fnd_api.g_ret_sts_success;
      x_loading_status := p_loading_status;

      -- API body
      -- Check if CP exist
      BEGIN
         SELECT comp_plan_id, allow_rev_class_overlap
           INTO x_cp_id, l_rc_overlap
           FROM cn_comp_plans
          WHERE NAME = p_cp_name AND org_id = p_org_id;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
            THEN
               fnd_message.set_name ('CN', 'CN_CP_NOT_EXIST');
               fnd_message.set_token ('CP_NAME', p_cp_name);
               fnd_msg_pub.ADD;
            END IF;

            x_loading_status := 'CN_CP_NOT_EXIST';
            RAISE fnd_api.g_exc_error;
      END;

      -- Check if PE exist
      BEGIN
         SELECT quota_id, quota_type_code, start_date,
                end_date
           INTO x_pe_id, l_quota_type_code, l_quota_start_date,
                l_quota_end_date
           FROM cn_quotas_v
          WHERE NAME = p_pe_name AND org_id = p_org_id ;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
            THEN
               fnd_message.set_name ('CN', 'CN_PLN_NOT_EXIST');
               fnd_message.set_token ('PE_NAME', p_pe_name);
               fnd_msg_pub.ADD;
            END IF;

            x_loading_status := 'CN_PLN_NOT_EXIST';
            RAISE fnd_api.g_exc_error;
      END;

      -- Check if already assigned( duplicate assigned )
      BEGIN
         SELECT 1
           INTO l_dummy
           FROM SYS.DUAL
          WHERE NOT EXISTS (
                           SELECT 1
                             FROM cn_quota_assigns
                            WHERE quota_id = x_pe_id
                                  AND comp_plan_id = x_cp_id);
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
            THEN
               fnd_message.set_name ('CN', 'PLN_QUOTA_ASSIGNED');
               fnd_msg_pub.ADD;
            END IF;

            x_loading_status := 'PLN_QUOTA_ASSIGNED';
            GOTO end_api;
      END;

      -- Check unique rev class of Allow_rev_class_overlap = N
      IF l_rc_overlap = 'N'
      THEN
         OPEN check_overlap_curs (x_cp_id,
                                  cn_global_var.g_rev_class_hierarchy_id
                                 );

         FETCH check_overlap_curs
          INTO l_rev_class_total, l_rev_class_total_unique;

         CLOSE check_overlap_curs;

         IF l_rev_class_total <> l_rev_class_total_unique
         THEN
            IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
            THEN
               fnd_message.set_name ('CN', 'PLN_PLAN_DUP_REV_CLASS');
               fnd_message.set_token ('PLAN_NAME', p_cp_name);
               fnd_msg_pub.ADD;
            END IF;

            x_loading_status := 'PLN_PLAN_DUP_REV_CLASS';
            RAISE fnd_api.g_exc_error;
         END IF;
      END IF;

	-- Date Range check for Plan element
	    IF (l_quota_end_date is null AND l_quota_start_date > p_cp_end_date) THEN
            l_flag := true;
    ELSE IF (p_cp_end_date is null AND l_quota_end_date < p_cp_start_date) THEN

            l_flag := true;

        ELSE IF (p_cp_end_date is not null AND
            l_quota_end_date is not null AND
            l_quota_start_date not between p_cp_start_date and p_cp_end_date OR
            l_quota_end_date not between p_cp_start_date and p_cp_end_date) THEN

            l_flag := true;

            END IF;
        END IF;
    END IF;

         IF l_flag = true
         THEN
            IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
            THEN
               fnd_message.set_name ('CN', 'CN_PLAN_ELT_DISJOINT');
               fnd_msg_pub.ADD;
            END IF;

            x_loading_status := 'CN_PLAN_ELT_DISJOINT';
            RAISE fnd_api.g_exc_error;
         END IF;


      -- End of API body.
      <<end_api>>
      NULL;
      -- Standard call to get message count and if count is 1, get message info.
      fnd_msg_pub.count_and_get (p_count        => x_msg_count,
                                 p_data         => x_msg_data,
                                 p_encoded      => fnd_api.g_false
                                );
   EXCEPTION
      WHEN fnd_api.g_exc_error
      THEN
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (p_count        => x_msg_count,
                                    p_data         => x_msg_data,
                                    p_encoded      => fnd_api.g_false
                                   );
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         x_loading_status := 'UNEXPECTED_ERR';
         fnd_msg_pub.count_and_get (p_count        => x_msg_count,
                                    p_data         => x_msg_data,
                                    p_encoded      => fnd_api.g_false
                                   );
      WHEN OTHERS
      THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         x_loading_status := 'UNEXPECTED_ERR';

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get (p_count        => x_msg_count,
                                    p_data         => x_msg_data,
                                    p_encoded      => fnd_api.g_false
                                   );
   END valid_pe_assign;

--| ----------------------------------------------------------------------+
--| Procedure : Create_Plan_Element_Assign
--| Desc : Procedure to create a new plan element assigned
--| --------------------------------------------------------------------- +
   PROCEDURE create_plan_element_assign (
      p_api_version         IN              NUMBER,
      p_init_msg_list       IN              VARCHAR2 := fnd_api.g_false,
      p_commit              IN              VARCHAR2 := fnd_api.g_false,
      p_validation_level    IN              NUMBER
            := fnd_api.g_valid_level_full,
      x_return_status       OUT NOCOPY      VARCHAR2,
      x_msg_count           OUT NOCOPY      NUMBER,
      x_msg_data            OUT NOCOPY      VARCHAR2,
      p_comp_plan_name      IN              cn_comp_plans.NAME%TYPE,
      p_comp_start_date     IN              DATE,
      p_comp_end_date       IN              DATE,
      p_plan_element_name   IN              cn_quotas.NAME%TYPE,
      p_org_id              IN              cn_quotas.org_id%TYPE,
      x_loading_status      OUT NOCOPY      VARCHAR2
   )
   IS
      l_api_name      CONSTANT VARCHAR2 (30)  := 'Create_Plan_Element_Assign';
      l_api_version   CONSTANT NUMBER                                  := 1.0;
      l_lk_meaning             cn_lookups.meaning%TYPE;
      l_comp_plan_id           cn_quota_assigns.comp_plan_id%TYPE;
      l_pe_id                  cn_quota_assigns.quota_id%TYPE;
      l_quota_assign_id        cn_quota_assigns.quota_assign_id%TYPE;
      l_loading_status         VARCHAR2 (1000);
   BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT create_plan_element_assign;

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
      l_loading_status := 'CN_INSERTED';
      -- API body
      --
      -- Valid plan element assignment
      --
      valid_pe_assign (x_return_status       => x_return_status,
                       x_msg_count           => x_msg_count,
                       x_msg_data            => x_msg_data,
                       p_cp_name             => LTRIM (RTRIM (p_comp_plan_name)
                                                      ),
                       p_pe_name             => LTRIM
                                                   (RTRIM (p_plan_element_name)
                                                   ),
                       p_cp_start_date       => p_comp_start_date,
                       p_cp_end_date         => p_comp_end_date,
                       p_loading_status      => l_loading_status,
                       p_org_id              => p_org_id,
                       x_cp_id               => l_comp_plan_id,
                       x_pe_id               => l_pe_id,
                       x_loading_status      => x_loading_status
                      );

      IF (x_return_status <> fnd_api.g_ret_sts_success)
      THEN
         RAISE fnd_api.g_exc_error;
      ELSIF x_loading_status <> 'PLN_QUOTA_ASSIGNED'
      THEN
         -- Create comp plan into cn_comp_plans
         cn_quota_assigns_pkg.begin_record
                                     (x_operation            => 'INSERT',
                                      x_comp_plan_id         => l_comp_plan_id,
                                      x_quota_id             => l_pe_id,
                                      x_quota_assign_id      => l_quota_assign_id,
                                      x_quota_id_old         => NULL,
                                      x_quota_sequence       => 0,
                                      x_org_id               => p_org_id
                                     );
         -- check the overlap
         l_loading_status := x_loading_status;
         cn_api.check_revenue_class_overlap
                                        (p_comp_plan_id        => l_comp_plan_id,
                                         p_rc_overlap          => NULL,
                                         p_loading_status      => l_loading_status,
                                         x_loading_status      => x_loading_status,
                                         x_return_status       => x_return_status
                                        );

         IF (x_return_status <> fnd_api.g_ret_sts_success)
         THEN
            RAISE fnd_api.g_exc_error;
         END IF;
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
         ROLLBACK TO create_plan_element_assign;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (p_count        => x_msg_count,
                                    p_data         => x_msg_data,
                                    p_encoded      => fnd_api.g_false
                                   );
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         ROLLBACK TO create_plan_element_assign;
         x_loading_status := 'UNEXPECTED_ERR';
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (p_count        => x_msg_count,
                                    p_data         => x_msg_data,
                                    p_encoded      => fnd_api.g_false
                                   );
      WHEN OTHERS
      THEN
         ROLLBACK TO create_plan_element_assign;
         x_loading_status := 'UNEXPECTED_ERR';
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get (p_count        => x_msg_count,
                                    p_data         => x_msg_data,
                                    p_encoded      => fnd_api.g_false
                                   );
   END create_plan_element_assign;

--|--------------------------------------------------------------------------+
--|Procedure: chk_cp_consistent
--|Desc     : The same compensation plan  already exist in the database, this
--|           procedure will check if all input for this comp plan is as
--|           the same as those exists in the database
--|--------------------------------------------------------------------------+
   PROCEDURE chk_cp_consistent (
      x_return_status    OUT NOCOPY      VARCHAR2,
      p_cp_rec           IN              comp_plan_rec_type,
      p_loading_status   IN              VARCHAR2,
      x_loading_status   OUT NOCOPY      VARCHAR2
   )
   IS
      l_api_name   CONSTANT VARCHAR2 (30)             := 'chk_cp_consistent';

      CURSOR c_cp_csr
      IS
         SELECT NAME, description, start_date, end_date, status_code,
                allow_rev_class_overlap
           FROM cn_comp_plans
          WHERE NAME = p_cp_rec.NAME
          AND   org_id = p_cp_rec.org_id;


      l_cp_csr              c_cp_csr%ROWTYPE;
      l_lkup_meaning        cn_lookups.meaning%TYPE;
   BEGIN
      x_return_status := fnd_api.g_ret_sts_success;
      x_loading_status := p_loading_status;

      OPEN c_cp_csr;

      FETCH c_cp_csr
       INTO l_cp_csr;

      IF c_cp_csr%NOTFOUND
      THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      -- Check description consistent
      IF (l_cp_csr.description <> p_cp_rec.description)
      THEN
         -- Error, check the msg level and add an error message to the
         -- API message list
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
         THEN
            fnd_message.set_name ('CN', 'CN_CP_NOT_CONSISTENT');
            fnd_message.set_token ('CP_NAME', p_cp_rec.NAME);
            l_lkup_meaning :=
                           cn_api.get_lkup_meaning ('DESC', 'CP_OBJECT_TYPE');
            fnd_message.set_token ('OBJ_NAME', l_lkup_meaning);
            fnd_msg_pub.ADD;
         END IF;

         x_loading_status := 'CN_CP_NOT_CONSISTENT';
         RAISE fnd_api.g_exc_error;
      END IF;

      -- Check start period consistent
      IF (TRUNC (l_cp_csr.start_date) <> TRUNC (p_cp_rec.start_date))
      THEN
         -- Error, check the msg level and add an error message to the
         -- API message list
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
         THEN
            fnd_message.set_name ('CN', 'CN_CP_NOT_CONSISTENT');
            fnd_message.set_token ('CP_NAME', p_cp_rec.NAME);
            l_lkup_meaning :=
                     cn_api.get_lkup_meaning ('START_DATE', 'CP_OBJECT_TYPE');
            fnd_message.set_token ('OBJ_NAME', l_lkup_meaning);
            fnd_msg_pub.ADD;
         END IF;

         x_loading_status := 'CN_CP_NOT_CONSISTENT';
         RAISE fnd_api.g_exc_error;
      END IF;

      -- Check end period consistent
      IF (NVL (TRUNC (l_cp_csr.end_date), fnd_api.g_miss_date) <>
                          NVL (TRUNC (p_cp_rec.end_date), fnd_api.g_miss_date)
         )
      THEN
         -- Error, check the msg level and add an error message to the
         -- API message list
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
         THEN
            fnd_message.set_name ('CN', 'CN_CP_NOT_CONSISTENT');
            fnd_message.set_token ('CP_NAME', p_cp_rec.NAME);
            l_lkup_meaning :=
                       cn_api.get_lkup_meaning ('END_DATE', 'CP_OBJECT_TYPE');
            fnd_message.set_token ('OBJ_NAME', l_lkup_meaning);
            fnd_msg_pub.ADD;
         END IF;

         x_loading_status := 'CN_CP_NOT_CONSISTENT';
         RAISE fnd_api.g_exc_error;
      END IF;

      -- Check allow rc overlap consistent
      IF (l_cp_csr.allow_rev_class_overlap <> p_cp_rec.rc_overlap)
      THEN
         -- Error, check the msg level and add an error message to the
         -- API message list
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
         THEN
            fnd_message.set_name ('CN', 'CN_CP_NOT_CONSISTENT');
            fnd_message.set_token ('CP_NAME', p_cp_rec.NAME);
            l_lkup_meaning :=
                cn_api.get_lkup_meaning ('REV_CLS_OVERLAP', 'CP_OBJECT_TYPE');
            fnd_message.set_token ('OBJ_NAME', l_lkup_meaning);
            fnd_msg_pub.ADD;
         END IF;

         x_loading_status := 'CN_CP_NOT_CONSISTENT';
         RAISE fnd_api.g_exc_error;
      END IF;

      CLOSE c_cp_csr;
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
   END chk_cp_consistent;

--| ----------------------------------------------------------------------+
--| Procedure : valid_comp_plan
--| Desc : Procedure to validate comp plan, will not valid pe assigned
--|        use valid_pe_assign() to check pe assignment
--| ---------------------------------------------------------------------+
   PROCEDURE valid_comp_plan (
      x_return_status    OUT NOCOPY      VARCHAR2,
      x_msg_count        OUT NOCOPY      NUMBER,
      x_msg_data         OUT NOCOPY      VARCHAR2,
      p_cp_rec           IN              comp_plan_rec_type,
      p_loading_status   IN              VARCHAR2,
      x_loading_status   OUT NOCOPY      VARCHAR2
   )
   IS
      l_api_name   CONSTANT VARCHAR2 (30)                := 'valid_comp_plan';
      l_start_date          cn_periods.start_date%TYPE;
      l_end_date            cn_periods.end_date%TYPE;
      l_lkup_meaning        cn_lookups.meaning%TYPE;
      l_loading_status      VARCHAR2 (30);
   BEGIN
      --  Initialize API return status to success
      x_return_status := fnd_api.g_ret_sts_success;
      x_loading_status := p_loading_status;
      -- API body
      -- Check if comp plan name is null
      l_lkup_meaning := cn_api.get_lkup_meaning ('CP_NAME', 'CP_OBJECT_TYPE');
      l_loading_status := x_loading_status; -- copy status to override NOCOPY

      IF ((cn_api.chk_null_char_para (p_char_para           => p_cp_rec.NAME,
                                      p_obj_name            => l_lkup_meaning,
                                      p_loading_status      => l_loading_status,
                                      x_loading_status      => x_loading_status
                                     )
          ) = fnd_api.g_true
         )
      THEN
         RAISE fnd_api.g_exc_error;
      END IF;

      -- Check Start Date  can not be missing or NULL
      l_lkup_meaning :=
                      cn_api.get_lkup_meaning ('START_DATE', 'CP_OBJECT_TYPE');
      l_loading_status := x_loading_status;  -- copy status to override NOCOPY

      IF ((cn_chk_plan_element_pkg.chk_miss_date_para
                                        (p_date_para           => p_cp_rec.start_date,
                                         p_para_name           => l_lkup_meaning,
                                         p_loading_status      => l_loading_status,
                                         x_loading_status      => x_loading_status
                                        )
          ) = fnd_api.g_true
         )
      THEN
         RAISE fnd_api.g_exc_error;
      ELSIF ((cn_chk_plan_element_pkg.chk_null_date_para
                                        (p_date_para           => p_cp_rec.start_date,
                                         p_obj_name            => l_lkup_meaning,
                                         p_loading_status      => l_loading_status,
                                         x_loading_status      => x_loading_status
                                        )
             ) = fnd_api.g_true
            )
      THEN
         RAISE fnd_api.g_exc_error;
      END IF;

      -- Check if rc_overlap is null and must be 'Y' or 'N'
      l_lkup_meaning :=
                 cn_api.get_lkup_meaning ('REV_CLS_OVERLAP', 'CP_OBJECT_TYPE');

      IF (p_cp_rec.rc_overlap NOT IN ('Y', 'N'))
      THEN
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
         THEN
            fnd_message.set_name ('CN', 'CN_INVALID_DATA');
            fnd_message.set_token ('OBJ_NAME', l_lkup_meaning);
            fnd_msg_pub.ADD;
         END IF;

         x_loading_status := 'CN_INVALID_DATA';
         RAISE fnd_api.g_exc_error;
      END IF;

      l_loading_status := x_loading_status;  -- copy status to override NOCOPY

      IF ((cn_api.chk_null_char_para (p_char_para           => p_cp_rec.rc_overlap,
                                      p_obj_name            => l_lkup_meaning,
                                      p_loading_status      => l_loading_status,
                                      x_loading_status      => x_loading_status
                                     )
          ) = fnd_api.g_true
         )
      THEN
         RAISE fnd_api.g_exc_error;
      END IF;

      -- Check if CP already exist, if so , check for consistency otherwise
      -- check for start/end period range
      BEGIN
         SELECT 'CP_EXIST'
           INTO x_loading_status
           FROM cn_comp_plans
          WHERE NAME = p_cp_rec.NAME
          AND   org_id = p_cp_rec.org_id;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            NULL;
      END;

      IF x_loading_status = 'CP_EXIST'
      THEN
         --
         -- Valid Rule : Check comp plan consistency
         --
         l_loading_status := x_loading_status;
         -- copy status to override NOCOPY
         chk_cp_consistent (x_return_status       => x_return_status,
                            p_cp_rec              => p_cp_rec,
                            p_loading_status      => l_loading_status,
                            x_loading_status      => x_loading_status
                           );

         IF (x_return_status <> fnd_api.g_ret_sts_success)
         THEN
            RAISE fnd_api.g_exc_error;
         END IF;
      ELSE
         --
         -- Validate Rule : End period must be greater than Start period
         --
         IF (    p_cp_rec.end_date IS NOT NULL
             AND p_cp_rec.end_date < p_cp_rec.start_date
            )
         THEN
            IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
            THEN
               fnd_message.set_name ('CN', 'CN_INVALID_DATE_RANGE');
               fnd_msg_pub.ADD;
            END IF;

            x_loading_status := 'INVALID_END_DATE';
            RAISE fnd_api.g_exc_error;
         END IF;
      END IF;

      -- End of API body.
      <<end_api>>
      NULL;
      -- Standard call to get message count and if count is 1, get message info.
      fnd_msg_pub.count_and_get (p_count        => x_msg_count,
                                 p_data         => x_msg_data,
                                 p_encoded      => fnd_api.g_false
                                );
   EXCEPTION
      WHEN fnd_api.g_exc_error
      THEN
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (p_count        => x_msg_count,
                                    p_data         => x_msg_data,
                                    p_encoded      => fnd_api.g_false
                                   );
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         x_loading_status := 'UNEXPECTED_ERR';
         fnd_msg_pub.count_and_get (p_count        => x_msg_count,
                                    p_data         => x_msg_data,
                                    p_encoded      => fnd_api.g_false
                                   );
      WHEN OTHERS
      THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         x_loading_status := 'UNEXPECTED_ERR';

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get (p_count        => x_msg_count,
                                    p_data         => x_msg_data,
                                    p_encoded      => fnd_api.g_false
                                   );
   END valid_comp_plan;

--| ----------------------------------------------------------------------+
--| Procedure : Create_Comp_Plan
--| Desc : Procedure to create a new compensation plan or add a plan
--|        element to an existing compensation plan
--| ---------------------------------------------------------------------+
   PROCEDURE create_comp_plan (
      p_api_version        IN              NUMBER,
      p_init_msg_list      IN              VARCHAR2,
      p_commit             IN              VARCHAR2,
      p_validation_level   IN              NUMBER,
      x_return_status      OUT NOCOPY      VARCHAR2,
      x_msg_count          OUT NOCOPY      NUMBER,
      x_msg_data           OUT NOCOPY      VARCHAR2,
      p_comp_plan_rec      IN              comp_plan_rec_type,
      x_loading_status     OUT NOCOPY      VARCHAR2,
      x_comp_plan_id       IN OUT NOCOPY      NUMBER
   )
   IS
      l_api_name      CONSTANT VARCHAR2 (30)            := 'Create_Comp_Plan';
      l_api_version   CONSTANT NUMBER                           := 1.0;
      l_cp_rec                 comp_plan_rec_type     := g_miss_comp_plan_rec;
      l_lk_meaning             cn_lookups.meaning%TYPE;
      l_index                  NUMBER;
      l_start_date             cn_periods.start_date%TYPE;
      l_end_date               cn_periods.start_date%TYPE;
      l_status_code            cn_comp_plans.status_code%TYPE;
      l_new_cp_flag            VARCHAR2 (1)                     := 'N';
      l_p_comp_plan_rec        comp_plan_rec_type;
      l_oai_array              jtf_usr_hks.oai_data_array_type;
      l_bind_data_id           NUMBER;
      l_loading_status         VARCHAR2 (30);
      l_note_msg               VARCHAR2 (240);
      l_note_id                NUMBER;
      l_status                 VARCHAR2(30);

        l_p_return_status VARCHAR2(50) ;
        l_p_msg_count NUMBER ;
        l_p_msg_data varchar2(240) ;

      l_p_cp_rec CN_COMP_PLAN_PVT.comp_plan_rec_type;

   BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT create_comp_plan;

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
      x_loading_status := 'CN_INSERTED';
      -- API body
      l_p_comp_plan_rec := p_comp_plan_rec;

      -- Validating the MOAC Org Id
      mo_global.validate_orgid_pub_api(org_id => l_p_comp_plan_rec.ORG_ID,status => l_status);

      --dbms_output.put_line('Going into pre processing ');
      IF jtf_usr_hks.ok_to_execute ('CN_COMP_PLAN_PUB',
                                    'CREATE_COMP_PLAN',
                                    'B',
                                    'C'
                                   )
      THEN
         cn_comp_plan_cuhk.create_comp_plan_pre
                                   (p_api_version           => p_api_version,
                                    p_init_msg_list         => p_init_msg_list,
                                    p_commit                => fnd_api.g_false,
                                    p_validation_level      => p_validation_level,
                                    x_return_status         => x_return_status,
                                    x_msg_count             => x_msg_count,
                                    x_msg_data              => x_msg_data,
                                    p_comp_plan_rec         => l_p_comp_plan_rec,
                                    x_loading_status        => x_loading_status
                                   );

         IF (x_return_status = fnd_api.g_ret_sts_error)
         THEN
            RAISE fnd_api.g_exc_error;
         ELSIF (x_return_status = fnd_api.g_ret_sts_unexp_error)
         THEN
            RAISE fnd_api.g_exc_unexpected_error;
         END IF;
      END IF;

      IF jtf_usr_hks.ok_to_execute ('CN_COMP_PLAN_PUB',
                                    'CREATE_COMP_PLAN',
                                    'B',
                                    'V'
                                   )
      THEN
         cn_comp_plan_vuhk.create_comp_plan_pre
                                   (p_api_version           => p_api_version,
                                    p_init_msg_list         => p_init_msg_list,
                                    p_commit                => fnd_api.g_false,
                                    p_validation_level      => p_validation_level,
                                    x_return_status         => x_return_status,
                                    x_msg_count             => x_msg_count,
                                    x_msg_data              => x_msg_data,
                                    p_comp_plan_rec         => l_p_comp_plan_rec,
                                    x_loading_status        => x_loading_status
                                   );

         IF (x_return_status = fnd_api.g_ret_sts_error)
         THEN
            RAISE fnd_api.g_exc_error;
         ELSIF (x_return_status = fnd_api.g_ret_sts_unexp_error)
         THEN
            RAISE fnd_api.g_exc_unexpected_error;
         END IF;
      END IF;

--dbms_output.put_line('Executed for pre processing API');

      -- Trim spaces before/after user input string and assign default value
      SELECT DECODE (l_p_comp_plan_rec.NAME,
                     fnd_api.g_miss_char, NULL,
                     LTRIM (RTRIM (l_p_comp_plan_rec.NAME))
                    )
        INTO l_cp_rec.NAME
        FROM SYS.DUAL;

      SELECT DECODE (l_p_comp_plan_rec.start_date,
                     fnd_api.g_miss_date, NULL,
                     l_p_comp_plan_rec.start_date
                    )
        INTO l_cp_rec.start_date
        FROM SYS.DUAL;

      SELECT DECODE (l_p_comp_plan_rec.end_date,
                     fnd_api.g_miss_date, NULL,
                     l_p_comp_plan_rec.end_date
                    )
        INTO l_cp_rec.end_date
        FROM SYS.DUAL;

      SELECT DECODE (l_p_comp_plan_rec.description,
                     fnd_api.g_miss_char, NULL,
                     LTRIM (RTRIM (l_p_comp_plan_rec.description))
                    )
        INTO l_cp_rec.description
        FROM SYS.DUAL;

      SELECT DECODE (l_p_comp_plan_rec.plan_element_name,
                     fnd_api.g_miss_char, NULL,
                     LTRIM (RTRIM (l_p_comp_plan_rec.plan_element_name))
                    )
        INTO l_cp_rec.plan_element_name
        FROM SYS.DUAL;

      SELECT DECODE (l_p_comp_plan_rec.org_id,
                     fnd_api.g_miss_char, NULL,
                     LTRIM (RTRIM (l_p_comp_plan_rec.org_id))
                    )
        INTO l_cp_rec.org_id
        FROM SYS.DUAL;

      -- Set status_code lookup code = INCOMPLETE
      /* SELECT lookup_code INTO l_cp_rec.status
        FROM cn_lookups
        WHERE lookup_type = 'PLAN_OBJECT_STATUS'
        AND Upper(meaning) = 'INCOMPLETE'; */
      l_cp_rec.status := 'INCOMPLETE';

      -- Get rc_overlap lookup_code
      SELECT DECODE (l_p_comp_plan_rec.rc_overlap,
                     fnd_api.g_miss_char, 'No',
                     LTRIM (RTRIM (l_p_comp_plan_rec.rc_overlap))
                    )
        INTO l_lk_meaning
        FROM SYS.DUAL;


       /* BEGIN
          SELECT lookup_code INTO l_cp_rec.rc_overlap
      FROM fnd_lookups
      WHERE lookup_type = 'YES_NO'
      AND Upper(meaning) = Upper(l_lk_meaning);
       EXCEPTION
          WHEN no_data_found THEN
       l_cp_rec.rc_overlap := SUBSTRB(l_lk_meaning,1,1);
       END; */

      -- 7330382:R12.CN.B scannane
      SELECT DECODE (l_p_comp_plan_rec.sum_trx,
                     fnd_api.g_miss_char, 'No',
                     LTRIM (RTRIM (l_p_comp_plan_rec.sum_trx))
                    )
        INTO l_lk_meaning
        FROM SYS.DUAL;

      SELECT DECODE (l_p_comp_plan_rec.rc_overlap,
                     fnd_api.g_miss_char, 'N',
                     NULL, 'N',
                     LTRIM (RTRIM (l_p_comp_plan_rec.rc_overlap))
                    )
        INTO l_cp_rec.rc_overlap
        FROM SYS.DUAL;

      -- 7330382:R12.CN.B scannane
      SELECT DECODE (l_p_comp_plan_rec.sum_trx,
                     fnd_api.g_miss_char, 'N',
                     NULL, 'N',
                     LTRIM (RTRIM (l_p_comp_plan_rec.sum_trx))
                    )
        INTO l_cp_rec.sum_trx
        FROM SYS.DUAL;

      --
      -- Valid compensation plan
      --
      l_loading_status := x_loading_status;  -- copy status to override NOCOPY
      valid_comp_plan (x_return_status       => x_return_status,
                       x_msg_count           => x_msg_count,
                       x_msg_data            => x_msg_data,
                       p_cp_rec              => l_cp_rec,
                       p_loading_status      => l_loading_status,
                       x_loading_status      => x_loading_status
                      );

      IF (x_return_status <> fnd_api.g_ret_sts_success)
      THEN
         RAISE fnd_api.g_exc_error;
      ELSIF x_loading_status <> 'CP_EXIST'
      THEN
         -- Create comp plan into cn_comp_plans
         cn_comp_plans_pkg.begin_record
               (x_operation                        => 'INSERT',
                x_rowid                            => g_rowid,
                x_comp_plan_id                     => x_comp_plan_id,
                x_name                             => l_cp_rec.NAME,
                x_description                      => l_cp_rec.description,
                x_start_date                       => l_cp_rec.start_date,
                x_end_date                         => l_cp_rec.end_date,
                x_status_code                      => l_cp_rec.status,
                x_allow_rev_class_overlap          => l_cp_rec.rc_overlap,
                x_last_update_date                 => SYSDATE,
                x_last_updated_by                  => fnd_global.user_id,
                x_creation_date                    => SYSDATE,
                x_created_by                       => fnd_global.user_id,
                x_last_update_login                => fnd_global.login_id,
                x_program_type                     => g_program_type,
                x_start_date_old                   => NULL,
                x_end_date_old                     => NULL,
                x_allow_rev_class_overlap_old      => NULL,
                x_sum_trx_flag                     => l_cp_rec.sum_trx,
                x_attribute_category               => l_p_comp_plan_rec.attribute_category,
                x_attribute1                       => l_p_comp_plan_rec.attribute1,
                x_attribute2                       => l_p_comp_plan_rec.attribute2,
                x_attribute3                       => l_p_comp_plan_rec.attribute3,
                x_attribute4                       => l_p_comp_plan_rec.attribute4,
                x_attribute5                       => l_p_comp_plan_rec.attribute5,
                x_attribute6                       => l_p_comp_plan_rec.attribute6,
                x_attribute7                       => l_p_comp_plan_rec.attribute7,
                x_attribute8                       => l_p_comp_plan_rec.attribute8,
                x_attribute9                       => l_p_comp_plan_rec.attribute9,
                x_attribute10                      => l_p_comp_plan_rec.attribute10,
                x_attribute11                      => l_p_comp_plan_rec.attribute11,
                x_attribute12                      => l_p_comp_plan_rec.attribute12,
                x_attribute13                      => l_p_comp_plan_rec.attribute13,
                x_attribute14                      => l_p_comp_plan_rec.attribute14,
                x_attribute15                      => l_p_comp_plan_rec.attribute15,
                x_org_id                           => l_p_comp_plan_rec.org_id
               );
         l_new_cp_flag := 'Y';

         /* Added the Notes for R12 */

         l_status_code := l_cp_rec.status;
         fnd_message.set_name ('CN', 'CNR12_NOTE_COMPPLAN_CREATE');
         fnd_message.set_token ('CP_NAME', l_cp_rec.NAME);
         l_note_msg := fnd_message.get;
         jtf_notes_pub.create_note
                           (p_api_version             => 1.0,
                            x_return_status           => x_return_status,
                            x_msg_count               => x_msg_count,
                            x_msg_data                => x_msg_data,
                            p_source_object_id        => x_comp_plan_id,
                            p_source_object_code      => 'CN_COMP_PLANS',
                            p_notes                   => l_note_msg,
                            p_notes_detail            => l_note_msg,
                            p_note_type               => 'CN_SYSGEN', -- for system generated
                            x_jtf_note_id             => l_note_id -- returned
                           );
      ELSE
         -- Comp plan already exist, get comp_plan_id ,status_code
         SELECT comp_plan_id, status_code
           INTO x_comp_plan_id, l_status_code
           FROM cn_comp_plans
          WHERE NAME = l_cp_rec.NAME
          AND org_id = l_cp_rec.org_id;
      END IF;

      -- If plan element name is not null, Create Plan Element Assignment
      IF (l_cp_rec.plan_element_name IS NOT NULL)
      THEN
         -- Create Plan Element Assignment, will set status code = INCOMPLETE
         create_plan_element_assign
                          (p_api_version            => 1.0,
                           x_return_status          => x_return_status,
                           x_msg_count              => x_msg_count,
                           x_msg_data               => x_msg_data,
                           p_comp_plan_name         => l_cp_rec.NAME,
                           p_comp_start_date        => l_cp_rec.start_date,
                           p_comp_end_date          => l_cp_rec.end_date,
                           p_plan_element_name      => l_cp_rec.plan_element_name,
                           p_org_id                 => l_p_comp_plan_rec.org_id,
                           x_loading_status         => x_loading_status
                          );

         IF (x_return_status <> fnd_api.g_ret_sts_success)
         THEN
            -- fail validate
            RAISE fnd_api.g_exc_error;
         ELSIF (x_loading_status = 'PLN_QUOTA_ASSIGNED')
         THEN
            -- PE already assigned to this cp, need to show error mesg in upload
            -- function
            GOTO end_api_body;
         END IF;
            l_p_cp_rec.comp_plan_id := x_comp_plan_id;

            cn_comp_plan_pvt.validate_comp_plan(
            p_api_version        => l_api_version,
            p_init_msg_list            => p_init_msg_list,
            p_commit                   => p_commit,
            p_validation_level         => p_validation_level,
            p_comp_plan                => l_p_cp_rec,
            x_return_status            => l_p_return_status,
            x_msg_count                => l_p_msg_count,
            x_msg_data                 => l_p_msg_data
            );
      END IF;

      -- Pass all validation, set status = COMPLETE
      --  only if it's a new Comp plan or
      --  the original status_code = COMPLETE
      /*IF    (    (l_new_cp_flag = 'Y')
             AND (l_cp_rec.plan_element_name IS NOT NULL)
            )
         OR ((l_new_cp_flag = 'N') AND (l_status_code = 'COMPLETE'))
      THEN
         cn_comp_plans_pkg.set_status (x_comp_plan_id          => x_comp_plan_id,
                                       x_quota_id              => NULL,
                                       x_rate_schedule_id      => NULL,
                                       x_status_code           => 'COMPLETE',
                                       x_event                 => NULL
                                      );
      END IF;*/
      -- End of API body.
      <<end_api_body>>
      NULL;

/*  Post processing     */
-- dbms_output.put_line('calling post processing API');
      IF jtf_usr_hks.ok_to_execute ('CN_COMP_PLAN_PUB',
                                    'CREATE_COMP_PLAN',
                                    'A',
                                    'V'
                                   )
      THEN
         cn_comp_plan_vuhk.create_comp_plan_post
                                   (p_api_version           => p_api_version,
                                    p_init_msg_list         => p_init_msg_list,
                                    p_commit                => fnd_api.g_false,
                                    p_validation_level      => p_validation_level,
                                    x_return_status         => x_return_status,
                                    x_msg_count             => x_msg_count,
                                    x_msg_data              => x_msg_data,
                                    p_comp_plan_rec         => l_p_comp_plan_rec,
                                    x_loading_status        => x_loading_status
                                   );

         IF (x_return_status = fnd_api.g_ret_sts_error)
         THEN
            RAISE fnd_api.g_exc_error;
         ELSIF (x_return_status = fnd_api.g_ret_sts_unexp_error)
         THEN
            RAISE fnd_api.g_exc_unexpected_error;
         END IF;
      END IF;

      IF jtf_usr_hks.ok_to_execute ('CN_COMP_PLAN_PUB',
                                    'CREATE_COMP_PLAN',
                                    'A',
                                    'C'
                                   )
      THEN
         cn_comp_plan_cuhk.create_comp_plan_post
                                   (p_api_version           => p_api_version,
                                    p_init_msg_list         => p_init_msg_list,
                                    p_commit                => fnd_api.g_false,
                                    p_validation_level      => p_validation_level,
                                    x_return_status         => x_return_status,
                                    x_msg_count             => x_msg_count,
                                    x_msg_data              => x_msg_data,
                                    p_comp_plan_rec         => l_p_comp_plan_rec,
                                    x_loading_status        => x_loading_status
                                   );

         IF (x_return_status = fnd_api.g_ret_sts_error)
         THEN
            RAISE fnd_api.g_exc_error;
         ELSIF (x_return_status = fnd_api.g_ret_sts_unexp_error)
         THEN
            RAISE fnd_api.g_exc_unexpected_error;
         END IF;
      END IF;

--dbms_output.put_line(' Executed for post processing API');

      /* Following code is for message generation */
      IF jtf_usr_hks.ok_to_execute ('CN_COMP_PLAN_PUB',
                                    'CREATE_COMP_PLAN',
                                    'M',
                                    'M'
                                   )
      THEN
         IF (cn_comp_plan_cuhk.ok_to_generate_msg
                                         (p_comp_plan_rec      => l_p_comp_plan_rec)
            )
         THEN
            -- XMLGEN.clearBindValues;
            -- XMLGEN.setBindValue('COMP_PLAN_NAME', l_cp_rec.name);
            l_bind_data_id := jtf_usr_hks.get_bind_data_id;
            jtf_usr_hks.load_bind_data (l_bind_data_id,
                                        'COMP_PLAN_NAME',
                                        l_cp_rec.NAME,
                                        'S',
                                        'T'
                                       );
            jtf_usr_hks.generate_message (p_prod_code         => 'CN',
                                          p_bus_obj_code      => 'CP',
                                          p_bus_obj_name      => 'COMP_PLAN',
                                          p_action_code       => 'I',
                                          /* I - Insert  */
                                          p_bind_data_id      => l_bind_data_id,
                                          p_oai_param         => NULL,
                                          p_oai_array         => l_oai_array,
                                          x_return_code       => x_return_status
                                         );

            IF (x_return_status = fnd_api.g_ret_sts_error)
            THEN
               RAISE fnd_api.g_exc_error;
            ELSIF (x_return_status = fnd_api.g_ret_sts_unexp_error)
            THEN
               RAISE fnd_api.g_exc_unexpected_error;
            END IF;
         END IF;
      END IF;

      x_return_status := fnd_api.g_ret_sts_success;

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
         ROLLBACK TO create_comp_plan;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (p_count        => x_msg_count,
                                    p_data         => x_msg_data,
                                    p_encoded      => fnd_api.g_false
                                   );
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         ROLLBACK TO create_comp_plan;
         x_loading_status := 'UNEXPECTED_ERR';
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (p_count        => x_msg_count,
                                    p_data         => x_msg_data,
                                    p_encoded      => fnd_api.g_false
                                   );
      WHEN OTHERS
      THEN
         ROLLBACK TO create_comp_plan;
         x_loading_status := 'UNEXPECTED_ERR';
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get (p_count        => x_msg_count,
                                    p_data         => x_msg_data,
                                    p_encoded      => fnd_api.g_false
                                   );
   END create_comp_plan;
END cn_comp_plan_pub;

/
