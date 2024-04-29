--------------------------------------------------------
--  DDL for Package Body CN_ROLE_PLANS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_ROLE_PLANS_PUB" AS
/* $Header: cnprlplb.pls 120.11 2007/07/26 01:10:20 appldev ship $ */
   g_pkg_name    CONSTANT VARCHAR2 (30) := 'CN_ROLE_PLANS_PUB';
   g_file_name   CONSTANT VARCHAR2 (12) := 'cnprlplb.pls';
   g_last_update_date     DATE          := SYSDATE;
   g_last_updated_by      NUMBER        := fnd_global.user_id;
   g_creation_date        DATE          := SYSDATE;
   g_created_by           NUMBER        := fnd_global.user_id;
   g_last_update_login    NUMBER        := fnd_global.login_id;
   g_miss_job_title       NUMBER        := -99;
   g_rowid                VARCHAR2 (15);
   g_program_type         VARCHAR2 (30);


PROCEDURE business_event(
   p_operation            IN VARCHAR2,
   p_pre_or_post	  IN VARCHAR2,
   p_role_plan_id         IN cn_role_plans.role_plan_id%TYPE,
   p_role_plan_rec        IN role_plan_rec_type
  ) IS

   l_key        VARCHAR2(80);
   l_event_name VARCHAR2(80);
   l_list       wf_parameter_list_t;

BEGIN

   -- p_operation = Add, Update, Remove
   l_event_name := 'oracle.apps.cn.events.setup.roleplans.' || p_operation || '.' || p_pre_or_post;

   --Get the item key
   l_key := l_event_name || '-' || p_role_plan_id;

   -- build parameter list as appropriate
   IF (p_operation = 'create') THEN
      wf_event.AddParameterToList('COMP_PLAN_ID',p_role_plan_rec.comp_plan_id,l_list);
      wf_event.AddParameterToList('ROLE_ID',p_role_plan_rec.role_id,l_list);
      wf_event.AddParameterToList('START_DATE',p_role_plan_rec.start_date,l_list);
      wf_event.AddParameterToList('END_DATE',p_role_plan_rec.end_date,l_list);

    ELSIF (p_operation = 'update') THEN
      l_key := l_key || '-' || p_role_plan_rec.object_version_number;

      wf_event.AddParameterToList('COMP_PLAN_ID',p_role_plan_rec.comp_plan_id,l_list);
      wf_event.AddParameterToList('ROLE_ID',p_role_plan_rec.role_id,l_list);
      wf_event.AddParameterToList('START_DATE',p_role_plan_rec.start_date,l_list);
      wf_event.AddParameterToList('END_DATE',p_role_plan_rec.end_date,l_list);

    ELSIF (p_operation = 'delete') THEN
      wf_event.AddParameterToList('COMP_PLAN_ID',p_role_plan_rec.comp_plan_id,l_list);
      wf_event.AddParameterToList('ROLE_ID',p_role_plan_rec.role_id,l_list);
      wf_event.AddParameterToList('START_DATE',p_role_plan_rec.start_date,l_list);
      wf_event.AddParameterToList('END_DATE',p_role_plan_rec.end_date,l_list);
   END IF;

   -- Raise Event
   wf_event.raise
     (p_event_name        => l_event_name,
      p_event_key         => l_key,
      p_parameters        => l_list);

   l_list.DELETE;

END business_event;


-- ----------------------------------------------------------------------------*
-- Function : valid_role_name
-- Desc     : check if the role_name exists in cn_roles
-- ---------------------------------------------------------------------------*
   FUNCTION valid_role_name (p_role_name cn_roles.NAME%TYPE)
      RETURN BOOLEAN
   IS
      CURSOR l_cur (l_role_name cn_roles.NAME%TYPE)
      IS
         SELECT *
           FROM cn_roles
          WHERE NAME = l_role_name;

      l_rec   l_cur%ROWTYPE;
   BEGIN
      OPEN l_cur (p_role_name);

      FETCH l_cur
       INTO l_rec;

      IF (l_cur%NOTFOUND)
      THEN
         CLOSE l_cur;

         RETURN FALSE;
      ELSE
         CLOSE l_cur;

         RETURN TRUE;
      END IF;
   END valid_role_name;

-- ----------------------------------------------------------------------------*
-- Function : valid_comp_plan_name
-- Desc     : check if the comp_plan_name exists in cn_comp_plans
-- ---------------------------------------------------------------------------*
   FUNCTION valid_comp_plan_name (
      p_comp_plan_name   cn_comp_plans.NAME%TYPE,
      p_org_id           cn_comp_plans.org_id%TYPE
   )
      RETURN BOOLEAN
   IS
      CURSOR l_cur (
         l_comp_plan_name   cn_comp_plans.NAME%TYPE,
         l_org_id           cn_comp_plans.org_id%TYPE
      )
      IS
         SELECT *
           FROM cn_comp_plans
          WHERE NAME = l_comp_plan_name AND org_id = l_org_id;

      l_rec   l_cur%ROWTYPE;
   BEGIN
      OPEN l_cur (p_comp_plan_name, p_org_id);

      FETCH l_cur
       INTO l_rec;

      IF (l_cur%NOTFOUND)
      THEN
         CLOSE l_cur;

         RETURN FALSE;
      ELSE
         CLOSE l_cur;

         RETURN TRUE;
      END IF;
   END valid_comp_plan_name;

-- ----------------------------------------------------------------------------*
-- Function : valid_role_plan_id
-- Desc     : check if the role_plan_id exists in cn_roles
-- ---------------------------------------------------------------------------*
   FUNCTION valid_role_plan_id (
      p_role_plan_id   cn_role_plans.role_plan_id%TYPE
   )
      RETURN BOOLEAN
   IS
      CURSOR l_cur (l_role_plan_id cn_role_plans.role_plan_id%TYPE)
      IS
         SELECT *
           FROM cn_role_plans
          WHERE role_plan_id = l_role_plan_id;

      l_rec   l_cur%ROWTYPE;
   BEGIN
      OPEN l_cur (p_role_plan_id);

      FETCH l_cur
       INTO l_rec;

      IF (l_cur%NOTFOUND)
      THEN
         CLOSE l_cur;

         RETURN FALSE;
      ELSE
         CLOSE l_cur;

         RETURN TRUE;
      END IF;
   END valid_role_plan_id;

-- ----------------------------------------------------------------------------*
-- Function : is_exist
-- Desc     : check if the role_plan_id exists in cn_role_plans
-- ---------------------------------------------------------------------------*
   FUNCTION is_exist (p_role_plan_id cn_role_plans.role_plan_id%TYPE)
      RETURN BOOLEAN
   IS
      CURSOR l_cur (l_role_plan_id cn_role_plans.role_plan_id%TYPE)
      IS
         SELECT *
           FROM cn_role_plans
          WHERE role_plan_id = l_role_plan_id;

      l_rec   l_cur%ROWTYPE;
   BEGIN
      OPEN l_cur (p_role_plan_id);

      FETCH l_cur
       INTO l_rec;

      IF (l_cur%NOTFOUND)
      THEN
         CLOSE l_cur;

         RETURN FALSE;
      ELSE
         CLOSE l_cur;

         RETURN TRUE;
      END IF;
   END is_exist;

-- ----------------------------------------------------------------------------*
-- Procedure: check_valid_insert
-- Desc     : check if the record is valid to insert into cn_role_plans
--            called in create_role_plan before inserting a role-plan
--            assignment
-- ----------------------------------------------------------------------------*
   PROCEDURE check_valid_insert (
      x_return_status    OUT NOCOPY      VARCHAR2,
      x_msg_count        OUT NOCOPY      NUMBER,
      x_msg_data         OUT NOCOPY      VARCHAR2,
      p_role_plan_rec    IN              role_plan_rec_type,
      x_role_id          OUT NOCOPY      cn_roles.role_id%TYPE,
      x_comp_plan_id     OUT NOCOPY      cn_comp_plans.comp_plan_id%TYPE,
      p_loading_status   IN              VARCHAR2,
      x_loading_status   OUT NOCOPY      VARCHAR2
   )
   IS
      l_api_name   CONSTANT VARCHAR2 (30)      := 'check_valid_insert';

-- CHANTHON: Added ORG_ID as a param
      CURSOR l_cur (
         l_role_id   cn_roles.role_id%TYPE,
         l_org_id    cn_role_plans.org_id%TYPE
      )
      IS
         SELECT start_date, end_date, comp_plan_id
           FROM cn_role_plans
          WHERE role_id = l_role_id AND org_id = l_org_id;

-- CHANTHON: Added the ORG_ID as a param
      CURSOR l_cp_cur (
         l_comp_plan_name   cn_comp_plans.NAME%TYPE,
         l_org_id           cn_comp_plans.org_id%TYPE
      )
      IS
         SELECT start_date, end_date
           FROM cn_comp_plans
          WHERE NAME = l_comp_plan_name AND org_id = l_org_id;

      l_cp_rec              l_cp_cur%ROWTYPE;
   BEGIN
      --  Initialize API return status to success
      x_return_status := fnd_api.g_ret_sts_success;
      x_loading_status := p_loading_status;

      -- Start of API body

      -- validate the following issues

      -- role_name can not be missing or null
      IF (cn_api.chk_miss_null_char_para
                                    (p_char_para           => p_role_plan_rec.role_name,
                                     p_obj_name            => g_role_name,
                                     p_loading_status      => x_loading_status,
                                     x_loading_status      => x_loading_status
                                    ) = fnd_api.g_true
         )
      THEN
         RAISE fnd_api.g_exc_error;
      END IF;

      -- comp_plan_name can not be missing or null
      IF (cn_api.chk_miss_null_char_para
                               (p_char_para           => p_role_plan_rec.comp_plan_name,
                                p_obj_name            => g_cp_name,
                                p_loading_status      => x_loading_status,
                                x_loading_status      => x_loading_status
                               ) = fnd_api.g_true
         )
      THEN
         RAISE fnd_api.g_exc_error;
      END IF;

      -- start_date can not be null
      -- start_date can not be missing
      -- start_date < end_date if end_date is null
      IF ((cn_api.invalid_date_range
                                  (p_start_date             => p_role_plan_rec.start_date,
                                   p_end_date               => p_role_plan_rec.end_date,
                                   p_end_date_nullable      => fnd_api.g_true,
                                   p_loading_status         => x_loading_status,
                                   x_loading_status         => x_loading_status
                                  )
          ) = fnd_api.g_true
         )
      THEN
         RAISE fnd_api.g_exc_error;
      END IF;

      -- role_name must exist in cn_roles
      IF NOT valid_role_name (p_role_plan_rec.role_name)
      THEN
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
         THEN
            fnd_message.set_name ('CN', 'CN_RL_ASGN_ROLE_NOT_EXIST');
            fnd_message.set_token ('ROLE_NAME', p_role_plan_rec.role_name);
            fnd_msg_pub.ADD;
         END IF;

         x_loading_status := 'CN_RL_ASGN_ROLE_NOT_EXIST';
         RAISE fnd_api.g_exc_error;
      ELSE
-- CHANTHON: ORG_ID need not be passed here
         x_role_id := cn_api.get_role_id (p_role_plan_rec.role_name);
      END IF;

      -- comp_plan_name must exist in cn_comp_plans
      IF NOT valid_comp_plan_name (p_role_plan_rec.comp_plan_name,
                                   p_role_plan_rec.org_id
                                  )
      THEN
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
         THEN
            fnd_message.set_name ('CN', 'CN_RL_ASGN_CP_NOT_EXIST');
            fnd_message.set_token ('COMP_PLAN',
                                   p_role_plan_rec.comp_plan_name
                                  );
            fnd_msg_pub.ADD;
         END IF;

         x_loading_status := 'CN_RL_ASGN_CP_NOT_EXIST';
         RAISE fnd_api.g_exc_error;
      ELSE
         x_comp_plan_id :=
            cn_api.get_cp_id (p_role_plan_rec.comp_plan_name,
                              p_role_plan_rec.org_id
                             );
      END IF;

      -- (start_date, end_date) is within comp plan's (start_date, end_date)
      OPEN l_cp_cur (p_role_plan_rec.comp_plan_name, p_role_plan_rec.org_id);

      FETCH l_cp_cur
       INTO l_cp_rec;

      IF (l_cp_cur%NOTFOUND)
      THEN
         -- normally this won't happen as it has been valided previously
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
         THEN
            fnd_message.set_name ('CN', 'CN_RL_ASGN_CP_NOT_EXIST');
            fnd_message.set_token ('COMP_PLAN',
                                   p_role_plan_rec.comp_plan_name
                                  );
            fnd_msg_pub.ADD;
         END IF;

         x_loading_status := 'CN_RL_ASGN_CP_NOT_EXIST';

         CLOSE l_cp_cur;

         RAISE fnd_api.g_exc_error;
      ELSE
         IF NOT cn_api.date_range_within (p_role_plan_rec.start_date,
                                          p_role_plan_rec.end_date,
                                          l_cp_rec.start_date,
                                          l_cp_rec.end_date
                                         )
         THEN
            IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
            THEN
               fnd_message.set_name ('CN', 'CN_RL_CP_DATE_RANGE_NOT_WITHIN');
               fnd_message.set_token ('START_DATE',
                                      p_role_plan_rec.start_date
                                     );
               fnd_message.set_token ('END_DATE', p_role_plan_rec.end_date);
               fnd_message.set_token ('CP_START_DATE', l_cp_rec.start_date);
               fnd_message.set_token ('CP_END_DATE', l_cp_rec.end_date);
               fnd_message.set_token ('COMP_PLAN_NAME',
                                      p_role_plan_rec.comp_plan_name
                                     );
               fnd_msg_pub.ADD;
            END IF;

            x_loading_status := 'CN_RL_CP_DATE_RANGE_NOT_WITHIN';

            CLOSE l_cp_cur;

            RAISE fnd_api.g_exc_error;
         END IF;

         CLOSE l_cp_cur;
      END IF;

-- CHANTHON: Adding the Org_id in the cursor.
   -- If existing any same role_id in cn_role_plans THEN
   -- check no overlap and no gap
      FOR l_rec IN l_cur (x_role_id, p_role_plan_rec.org_id)
      LOOP
         IF cn_api.date_range_overlap (l_rec.start_date,
                                       l_rec.end_date,
                                       p_role_plan_rec.start_date,
                                       p_role_plan_rec.end_date
                                      )
         THEN
            IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
            THEN
               fnd_message.set_name ('CN', 'CN_RL_ROLE_PLAN_OVERLAP');
               fnd_message.set_token ('COMP_PLAN_NAME',
                                      cn_api.get_cp_name (l_rec.comp_plan_id)
                                     );
               fnd_message.set_token ('START_DATE', l_rec.start_date);
               fnd_message.set_token ('END_DATE', l_rec.end_date);
               fnd_msg_pub.ADD;
            END IF;

            x_loading_status := 'CN_RL_ROLE_PLAN_OVERLAP';
            RAISE fnd_api.g_exc_error;
         END IF;
      END LOOP;

      -- End of API body.

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
   END check_valid_insert;

-- ----------------------------------------------------------------------------*
-- Procedure: check_valid_update
-- Desc     : check if the record is valid to update in cn_role_plans
--            called in update_role_plan before updating a role
-- ----------------------------------------------------------------------------*
   PROCEDURE check_valid_update (
      x_return_status       OUT NOCOPY      VARCHAR2,
      x_msg_count           OUT NOCOPY      NUMBER,
      x_msg_data            OUT NOCOPY      VARCHAR2,
      p_role_plan_rec_old   IN              role_plan_rec_type,
      p_role_plan_rec_new   IN              role_plan_rec_type,
      x_role_plan_id_old    OUT NOCOPY      cn_role_plans.role_plan_id%TYPE,
      x_role_id             OUT NOCOPY      cn_roles.role_id%TYPE,
      x_comp_plan_id        OUT NOCOPY      cn_comp_plans.comp_plan_id%TYPE,
      x_date_update_only    OUT NOCOPY      VARCHAR2,
      p_loading_status      IN              VARCHAR2,
      x_loading_status      OUT NOCOPY      VARCHAR2
   )
   IS
      l_api_name   CONSTANT VARCHAR2 (30)             := 'check_valid_update';
      tmp_start_date        cn_role_plans.start_date%TYPE;
      tmp_end_date          cn_role_plans.end_date%TYPE;

-- CHANTHON: Adding ORG_ID.. This cursor is used to check for whether the
-- role id already exists for another role_plan_id. If it does then the date overlap is
-- being checked. So org_id is required.
      CURSOR l_cur (
         l_role_id        cn_role_plans.role_id%TYPE,
         l_role_plan_id   cn_role_plans.role_plan_id%TYPE,
         l_org_id         cn_role_plans.org_id%TYPE
      )
      IS
         SELECT start_date, end_date, comp_plan_id
           FROM cn_role_plans
          WHERE role_id = l_role_id
            AND org_id = l_org_id
            AND role_plan_id <> l_role_plan_id;

-- CHANTHON: Id based so ORG_ID not required
      CURSOR l_old_cur (l_role_plan_id cn_role_plans.role_plan_id%TYPE)
      IS
         SELECT *
           FROM cn_role_plans
          WHERE role_plan_id = l_role_plan_id;

      l_old_rec             l_old_cur%ROWTYPE;

-- CHANTHON: Id based so ORG_ID not required
      CURSOR l_cp_cur (l_comp_plan_id cn_comp_plans.comp_plan_id%TYPE)
      IS
         SELECT start_date, end_date
           FROM cn_comp_plans
          WHERE comp_plan_id = l_comp_plan_id;

      l_cp_rec              l_cp_cur%ROWTYPE;
   BEGIN
      --  Initialize API return status to success
      x_return_status := fnd_api.g_ret_sts_success;
      x_loading_status := p_loading_status;
      -- Start of API body

      -- validate the following issues

      -- old role_plan_id must exist in cn_role_plans
      x_role_plan_id_old :=
         cn_api.get_role_plan_id (p_role_plan_rec_old.role_name,
                                  p_role_plan_rec_old.comp_plan_name,
                                  p_role_plan_rec_old.start_date,
                                  p_role_plan_rec_old.end_date,
                                  p_role_plan_rec_old.org_id
                                 );

      IF (x_role_plan_id_old IS NULL)
      THEN
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
         THEN
            fnd_message.set_name ('CN', 'CN_RL_UPD_ROLE_PLAN_NOT_EXIST');
            fnd_msg_pub.ADD;
         END IF;

         x_loading_status := 'CN_RL_UPD_ROLE_PLAN_NOT_EXIST';
         RAISE fnd_api.g_exc_error;
      END IF;

      -- new role_name can not be null
      -- note that new role_name can be missing
      IF (cn_api.chk_null_char_para
                                (p_char_para           => p_role_plan_rec_new.role_name,
                                 p_obj_name            => g_role_name,
                                 p_loading_status      => x_loading_status,
                                 x_loading_status      => x_loading_status
                                ) = fnd_api.g_true
         )
      THEN
         RAISE fnd_api.g_exc_error;
      END IF;

      -- new comp_plan_name can not be null
      -- note that new comp_plan_name can be missing
      IF (cn_api.chk_null_char_para
                           (p_char_para           => p_role_plan_rec_new.comp_plan_name,
                            p_obj_name            => g_cp_name,
                            p_loading_status      => x_loading_status,
                            x_loading_status      => x_loading_status
                           ) = fnd_api.g_true
         )
      THEN
         RAISE fnd_api.g_exc_error;
      END IF;

      -- new start_date can not be null
      -- note that new start_date can be missing
      IF (cn_api.chk_null_date_para
                               (p_date_para           => p_role_plan_rec_new.start_date,
                                p_obj_name            => g_start_date,
                                p_loading_status      => x_loading_status,
                                x_loading_status      => x_loading_status
                               ) = fnd_api.g_true
         )
      THEN
         RAISE fnd_api.g_exc_error;
      END IF;

      -- if new start_date is missing then
      --    tmp_start_date := old start_date
      -- else
      --    tmp_start_date := new start_date
      -- end if

      -- if new end_date is missing then
      --    tmp_end_date := old end_date
      -- else
      --    tmp_end_date := new end_date
      -- end if

      -- check tmp_start_date < tmp_end_date if tmp_end_date is not null
      OPEN l_old_cur (x_role_plan_id_old);

      FETCH l_old_cur
       INTO l_old_rec;

      IF (l_old_cur%NOTFOUND)
      THEN
         -- normally, this should not happen as the existance has
         -- been validated previously
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
         THEN
            fnd_message.set_name ('CN', 'CN_RL_UPD_ROLE_PLAN_NOT_EXIST');
            fnd_msg_pub.ADD;
         END IF;

         x_loading_status := 'CN_RL_UPD_ROLE_PLAN_NOT_EXIST';

         CLOSE l_old_cur;

         RAISE fnd_api.g_exc_error;
      ELSE
         IF (p_role_plan_rec_new.start_date = fnd_api.g_miss_date)
         THEN
            tmp_start_date := l_old_rec.start_date;
         ELSE
            tmp_start_date := p_role_plan_rec_new.start_date;
         END IF;

         IF (p_role_plan_rec_new.end_date = fnd_api.g_miss_date)
         THEN
            tmp_end_date := l_old_rec.end_date;
         ELSE
            tmp_end_date := p_role_plan_rec_new.end_date;
         END IF;

         IF (tmp_end_date IS NOT NULL) AND (tmp_start_date > tmp_end_date)
         THEN
            IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
            THEN
               fnd_message.set_name ('CN', 'CN_RL_INVALID_DATE_RANGE');
               fnd_message.set_token ('START_DATE', tmp_start_date);
               fnd_message.set_token ('END_DATE', tmp_end_date);
               fnd_msg_pub.ADD;
            END IF;

            x_loading_status := 'CN_RL_INVALID_DATE_RANGE';

            CLOSE l_old_cur;

            RAISE fnd_api.g_exc_error;
         END IF;

         CLOSE l_old_cur;
      END IF;

      -- make sure the create_module is OSC if we are trying to change it within
      -- OSC.  if it were created in SFP (from a generic push) and we change it
      -- in OSC then it would get out of sync with SFP (we would need a "pull"
      -- operation to get it back in sync).  the user needs to make the necessary
      -- changes in SFP and reapply the push.
      IF NVL (l_old_rec.create_module, 'OSC') = 'SFP'
      THEN
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
         THEN
            fnd_message.set_name ('CN', 'CN_RP_CREATED_IN_SFP');
            fnd_msg_pub.ADD;
         END IF;

         x_loading_status := 'CN_RP_CREATED_IN_SFP';
         RAISE fnd_api.g_exc_error;
      END IF;

      -- if new role_name is not missing then new role_name must exist in cn_roles
      IF (p_role_plan_rec_new.role_name <> fnd_api.g_miss_char)
      THEN
         x_role_id := cn_api.get_role_id (p_role_plan_rec_new.role_name);

         IF (x_role_id IS NULL)
         THEN
            IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
            THEN
               fnd_message.set_name ('CN', 'CN_RL_ASGN_ROLE_NOT_EXIST');
               fnd_message.set_token ('ROLE_NAME',
                                      p_role_plan_rec_new.role_name
                                     );
               fnd_msg_pub.ADD;
            END IF;

            x_loading_status := 'CN_RL_ASGN_ROLE_NOT_EXIST';
            RAISE fnd_api.g_exc_error;
         END IF;
      ELSE
         OPEN l_old_cur (x_role_plan_id_old);

         FETCH l_old_cur
          INTO l_old_rec;

         IF (l_old_cur%NOTFOUND)
         THEN
            -- normally, this should not happen as the existance has
            -- been validated previously
            IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
            THEN
               fnd_message.set_name ('CN', 'CN_RL_UPD_ROLE_PLAN_NOT_EXIST');
               fnd_msg_pub.ADD;
            END IF;

            x_loading_status := 'CN_RL_UPD_ROLE_PLAN_NOT_EXIST';

            CLOSE l_old_cur;

            RAISE fnd_api.g_exc_error;
         ELSE
            x_role_id := l_old_rec.role_id;

            CLOSE l_old_cur;
         END IF;
      END IF;

      -- if new comp_plan_name is not missing then
      -- new comp_plan_name must exist in cn_comp_plans
      IF (p_role_plan_rec_new.comp_plan_name <> fnd_api.g_miss_char)
      THEN
         x_comp_plan_id :=
            cn_api.get_cp_id (p_role_plan_rec_new.comp_plan_name,
                              p_role_plan_rec_new.org_id
                             );

         IF (x_comp_plan_id IS NULL)
         THEN
            IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
            THEN
               fnd_message.set_name ('CN', 'CN_RL_ASGN_CP_NOT_EXIST');
               fnd_message.set_token ('COMP_PLAN',
                                      p_role_plan_rec_new.comp_plan_name
                                     );
               fnd_msg_pub.ADD;
            END IF;

            x_loading_status := 'CN_RL_ASGN_CP_NOT_EXIST';
            RAISE fnd_api.g_exc_error;
         END IF;
      ELSE
         OPEN l_old_cur (x_role_plan_id_old);

         FETCH l_old_cur
          INTO l_old_rec;

         IF (l_old_cur%NOTFOUND)
         THEN
            -- normally, this should not happen as the existance has
            -- been validated previously
            IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
            THEN
               fnd_message.set_name ('CN', 'CN_RL_UPD_ROLE_PLAN_NOT_EXIST');
               fnd_msg_pub.ADD;
            END IF;

            x_loading_status := 'CN_RL_UPD_ROLE_PLAN_NOT_EXIST';

            CLOSE l_old_cur;

            RAISE fnd_api.g_exc_error;
         ELSE
            x_comp_plan_id := l_old_rec.comp_plan_id;

            CLOSE l_old_cur;
         END IF;
      END IF;

      -- (start_date, end_date) is within comp plan's (start_date, end_date)
      OPEN l_cp_cur (x_comp_plan_id);

      FETCH l_cp_cur
       INTO l_cp_rec;

      IF (l_cp_cur%NOTFOUND)
      THEN
         -- normally this won't happen as it has been valided previously
         x_loading_status := 'CN_RL_ASGN_CP_NOT_EXIST';

         CLOSE l_cp_cur;

         RAISE fnd_api.g_exc_error;
      ELSE
         IF NOT cn_api.date_range_within (tmp_start_date,
                                          tmp_end_date,
                                          l_cp_rec.start_date,
                                          l_cp_rec.end_date
                                         )
         THEN
            IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
            THEN
               fnd_message.set_name ('CN', 'CN_RL_CP_DATE_RANGE_NOT_WITHIN');
               fnd_message.set_token ('START_DATE', tmp_start_date);
               fnd_message.set_token ('END_DATE', tmp_end_date);
               fnd_message.set_token ('CP_START_DATE', l_cp_rec.start_date);
               fnd_message.set_token ('CP_END_DATE', l_cp_rec.end_date);
               fnd_message.set_token ('COMP_PLAN_NAME',
                                      cn_api.get_cp_name (x_comp_plan_id)
                                     );
               fnd_msg_pub.ADD;
            END IF;

            x_loading_status := 'CN_RL_CP_DATE_RANGE_NOT_WITHIN';

            CLOSE l_cp_cur;

            RAISE fnd_api.g_exc_error;
         END IF;

         CLOSE l_cp_cur;
      END IF;

--CHANTHON: Adding the org_id param in the cursor. Should be the org_id of the updated record.
   -- If existing any same role_id in cn_role_plans THEN
   -- check no overlap
      FOR l_rec IN l_cur (x_role_id,
                          x_role_plan_id_old,
                          p_role_plan_rec_new.org_id
                         )
      LOOP
         IF cn_api.date_range_overlap (l_rec.start_date,
                                       l_rec.end_date,
                                       tmp_start_date,
                                       tmp_end_date
                                      )
         THEN
            IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
            THEN
               fnd_message.set_name ('CN', 'CN_RL_ROLE_PLAN_OVERLAP');
               fnd_message.set_token ('COMP_PLAN_NAME',
                                      cn_api.get_cp_name (l_rec.comp_plan_id)
                                     );
               fnd_message.set_token ('START_DATE', l_rec.start_date);
               fnd_message.set_token ('END_DATE', l_rec.end_date);
               fnd_msg_pub.ADD;
            END IF;

            x_loading_status := 'CN_RL_ROLE_PLAN_OVERLAP';
            RAISE fnd_api.g_exc_error;
         END IF;
      END LOOP;

      -- Checking if it is date_update_only
      OPEN l_old_cur (x_role_plan_id_old);

      FETCH l_old_cur
       INTO l_old_rec;

      IF (l_old_cur%NOTFOUND)
      THEN
         -- normally, this should not happen as the existence has
         -- been validated previously
         x_loading_status := 'CN_RL_UPD_ROLE_PLAN_NOT_EXIST';

         CLOSE l_old_cur;

         RAISE fnd_api.g_exc_error;
      ELSE
         IF (   (x_role_id <> l_old_rec.role_id)
             OR (x_comp_plan_id <> l_old_rec.comp_plan_id)
            )
         THEN
            x_date_update_only := fnd_api.g_false;
         ELSE
            x_date_update_only := fnd_api.g_true;
         END IF;

         CLOSE l_old_cur;
      END IF;

      -- End of API body.

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
   END check_valid_update;

-- ----------------------------------------------------------------------------*
-- Procedure: check_valid_delete
-- Desc     : check if the record is valid to delete from cn_role_plans
--            called in delete_role_plan before deleting a role
-- ----------------------------------------------------------------------------*
   PROCEDURE check_valid_delete (
      x_return_status    OUT NOCOPY      VARCHAR2,
      x_msg_count        OUT NOCOPY      NUMBER,
      x_msg_data         OUT NOCOPY      VARCHAR2,
      p_role_plan_rec    IN              role_plan_rec_type,
      x_role_plan_id     OUT NOCOPY      NUMBER,
      p_loading_status   IN              VARCHAR2,
      x_loading_status   OUT NOCOPY      VARCHAR2
   )
   IS
      l_api_name   CONSTANT VARCHAR2 (30) := 'check_valid_delete';
   BEGIN
      --  Initialize API return status to success
      x_return_status := fnd_api.g_ret_sts_success;
      x_loading_status := p_loading_status;
      -- Start of API body

      -- Valide the following issues

      -- Checke if the p_role_plan_id does exist.
      x_role_plan_id :=
         cn_api.get_role_plan_id (p_role_plan_rec.role_name,
                                  p_role_plan_rec.comp_plan_name,
                                  p_role_plan_rec.start_date,
                                  p_role_plan_rec.end_date,
                                  p_role_plan_rec.org_id
                                 );

      IF (x_role_plan_id IS NULL)
      THEN
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
         THEN
            fnd_message.set_name ('CN', 'CN_RL_DEL_ROLE_PLAN_NOT_EXIST');
            fnd_msg_pub.ADD;
         END IF;

         x_loading_status := 'CN_RL_DEL_ROLE_PLAN_NOT_EXIST';
         RAISE fnd_api.g_exc_error;
      END IF;

      -- End of API body.

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
   END check_valid_delete;

-- --------------------------------------------------------------------------*
-- Procedure: srp_plan_assignment_for_insert
-- --------------------------------------------------------------------------*
   PROCEDURE srp_plan_assignment_for_insert (
      p_role_id          IN              cn_roles.role_id%TYPE,
      p_role_plan_id     IN              cn_role_plans.role_plan_id%TYPE,
      x_return_status    OUT NOCOPY      VARCHAR2,
      p_loading_status   IN              VARCHAR2,
      x_loading_status   OUT NOCOPY      VARCHAR2,
      p_org_id           IN              cn_role_plans.org_id%TYPE
   )
   IS
         /* CURSOR l_cur IS
         select sr.srp_role_id                srp_role_id,
                nvl(srd.job_title_id, G_MISS_JOB_TITLE) job_title_id,
           nvl(srd.plan_activate_status, 'NOT_PUSHED') push_status
      from cn_srp_roles                  sr,
           cn_srp_role_dtls              srd
          where role_id                     = p_role_id
            and srd.role_model_id is NULL
            -- CHANGED FOR MODELING IMPACT
       and sr.srp_role_id              = srd.srp_role_id(+);*/

      --CHANTHON:Added org id in the cursor
      CURSOR l_cur
      IS
         SELECT srp_role_id
           FROM cn_srp_roles
          WHERE role_id = p_role_id AND org_id = p_org_id;

      l_rec                  l_cur%ROWTYPE;
      l_return_status        VARCHAR2 (2000);
      l_msg_count            NUMBER;
      l_msg_data             VARCHAR2 (2000);
      l_srp_plan_assign_id   cn_srp_plan_assigns.srp_plan_assign_id%TYPE;
      l_loading_status       VARCHAR2 (2000);
   BEGIN
      --  Initialize API return status to success
      x_return_status := fnd_api.g_ret_sts_success;
      x_loading_status := p_loading_status;

      FOR l_rec IN l_cur
      LOOP
         -- see here if it is necessary to insert into cn_srp_plan_assigns
         -- the create_module here is OSC.
         -- if the job title not assigned yet (original OSC case) or
         -- status is PUSHED (salesrep push done, treat as OSC record), then
         -- call SPA.insert
         -- if l_rec.job_title_id = G_MISS_JOB_TITLE OR
         --   l_rec.push_status  = 'PUSHED'         THEN

         -- dbms_output.put_line('insert into cn_srp_plan_assigns...');
         -- dbms_output.put_line('p_srp_role_id = ' || l_rec.srp_role_id);
         -- dbms_output.put_line('p_role_plan_id = ' || p_role_plan_id);
         cn_srp_plan_assigns_pvt.create_srp_plan_assigns
                               (p_api_version             => 1.0,
                                x_return_status           => l_return_status,
                                x_msg_count               => l_msg_count,
                                x_msg_data                => l_msg_data,
                                p_srp_role_id             => l_rec.srp_role_id,
                                p_role_plan_id            => p_role_plan_id,
                                x_srp_plan_assign_id      => l_srp_plan_assign_id,
                                x_loading_status          => l_loading_status
                               );

         IF (l_return_status <> fnd_api.g_ret_sts_success)
         THEN
            x_return_status := l_return_status;
            x_loading_status := l_loading_status;
            EXIT;
         END IF;
      -- end if;
      END LOOP;
   END srp_plan_assignment_for_insert;

-- --------------------------------------------------------------------------*
-- Procedure: srp_plan_assignment_for_update
-- --------------------------------------------------------------------------*
   PROCEDURE srp_plan_assignment_for_update (
      p_role_id            IN              cn_roles.role_id%TYPE,
      p_role_id_old        IN              cn_roles.role_id%TYPE,
      p_role_plan_id       IN              cn_role_plans.role_plan_id%TYPE,
      p_date_update_only   IN              VARCHAR2,
      x_return_status      OUT NOCOPY      VARCHAR2,
      p_loading_status     IN              VARCHAR2,
      x_loading_status     OUT NOCOPY      VARCHAR2,
      p_org_id             IN              cn_role_plans.org_id%TYPE,
      p_org_id_old         IN              cn_role_plans.org_id%TYPE
   )
   IS
         /* CURSOR l_cur IS
         select sr.srp_role_id                srp_role_id,
                nvl(srd.job_title_id, G_MISS_JOB_TITLE) job_title_id,
           nvl(srd.plan_activate_status, 'NOT_PUSHED') push_status
      from cn_srp_roles                  sr,
           cn_srp_role_dtls              srd
          where role_id                     = p_role_id
            and srd.role_model_id is NULL
            -- CHANGED FOR MODELING IMPACT
       and sr.srp_role_id              = srd.srp_role_id(+);*/
      CURSOR l_cur
      IS
         SELECT srp_role_id
           FROM cn_srp_roles
          WHERE role_id = p_role_id AND org_id = p_org_id;

      CURSOR l_cur_del
      IS
         SELECT srp_role_id
           FROM cn_srp_roles
          WHERE role_id = p_role_id_old AND org_id = p_org_id_old;

      l_rec                  l_cur%ROWTYPE;
      l_rec_del              l_cur_del%ROWTYPE;
      l_return_status        VARCHAR2 (2000);
      l_msg_count            NUMBER;
      l_msg_data             VARCHAR2 (2000);
      l_srp_plan_assign_id   cn_srp_plan_assigns.srp_plan_assign_id%TYPE;
      l_loading_status       VARCHAR2 (2000);
   BEGIN
      --  Initialize API return status to success
      x_return_status := fnd_api.g_ret_sts_success;
      x_loading_status := p_loading_status;

      -- see here if it is necessary to update cn_srp_plan_assigns...
      -- the create_module here is OSC.
      -- if the job title not assigned yet (original OSC case) or
      -- status is PUSHED (salesrep push done, treat as OSC record), then
      -- call SPA.update
      IF (p_date_update_only = fnd_api.g_true)
      THEN
         FOR l_rec IN l_cur
         LOOP
            -- if l_rec.job_title_id = G_MISS_JOB_TITLE OR
            --   l_rec.push_status  = 'PUSHED'         THEN
            cn_srp_plan_assigns_pvt.update_srp_plan_assigns
                                        (p_api_version         => 1.0,
                                         x_return_status       => l_return_status,
                                         x_msg_count           => l_msg_count,
                                         x_msg_data            => l_msg_data,
                                         p_srp_role_id         => l_rec.srp_role_id,
                                         p_role_plan_id        => p_role_plan_id,
                                         x_loading_status      => l_loading_status
                                        );

            IF (l_return_status <> fnd_api.g_ret_sts_success)
            THEN
               x_return_status := l_return_status;
               x_loading_status := l_loading_status;
               EXIT;
            END IF;
         -- end if;
         END LOOP;
      ELSE
--CHANTHON: Updating the srp records. delete all the old records and
--create new srp records.
         FOR l_rec_del IN l_cur_del
         LOOP
            -- if l_rec.job_title_id = G_MISS_JOB_TITLE OR
            --   l_rec.push_status  = 'PUSHED'         THEN
            cn_srp_plan_assigns_pvt.delete_srp_plan_assigns
                                        (p_api_version         => 1.0,
                                         x_return_status       => l_return_status,
                                         x_msg_count           => l_msg_count,
                                         x_msg_data            => l_msg_data,
                                         p_srp_role_id         => l_rec_del.srp_role_id,
                                         p_role_plan_id        => p_role_plan_id,
                                         x_loading_status      => l_loading_status
                                        );

            IF (l_return_status <> fnd_api.g_ret_sts_success)
            THEN
               x_return_status := l_return_status;
               x_loading_status := l_loading_status;
               EXIT;
            END IF;
         END LOOP;

         FOR l_rec IN l_cur
         LOOP
            cn_srp_plan_assigns_pvt.create_srp_plan_assigns
                               (p_api_version             => 1.0,
                                x_return_status           => l_return_status,
                                x_msg_count               => l_msg_count,
                                x_msg_data                => l_msg_data,
                                p_srp_role_id             => l_rec.srp_role_id,
                                p_role_plan_id            => p_role_plan_id,
                                x_srp_plan_assign_id      => l_srp_plan_assign_id,
                                x_loading_status          => l_loading_status
                               );

            IF (l_return_status <> fnd_api.g_ret_sts_success)
            THEN
               x_return_status := l_return_status;
               x_loading_status := l_loading_status;
               EXIT;
            END IF;
         -- end if;
         END LOOP;
      END IF;
   END srp_plan_assignment_for_update;

-- --------------------------------------------------------------------------*
-- Procedure: srp_plan_assignment_for_delete
-- --------------------------------------------------------------------------*
   PROCEDURE srp_plan_assignment_for_delete (
      p_role_id          IN              cn_roles.role_id%TYPE,
      p_role_plan_id     IN              cn_role_plans.role_plan_id%TYPE,
      x_return_status    OUT NOCOPY      VARCHAR2,
      p_loading_status   IN              VARCHAR2,
      x_loading_status   OUT NOCOPY      VARCHAR2,
      p_org_id           IN              cn_role_plans.org_id%TYPE
   )
   IS
      CURSOR l_cur
      IS
         SELECT srp_role_id
           FROM cn_srp_roles
          WHERE role_id = p_role_id AND org_id = p_org_id;

      l_rec                  l_cur%ROWTYPE;
      l_return_status        VARCHAR2 (2000);
      l_msg_count            NUMBER;
      l_msg_data             VARCHAR2 (2000);
      l_srp_plan_assign_id   cn_srp_plan_assigns.srp_plan_assign_id%TYPE;
      l_loading_status       VARCHAR2 (2000);
   BEGIN
      --  Initialize API return status to success
      x_return_status := fnd_api.g_ret_sts_success;
      x_loading_status := p_loading_status;

      FOR l_rec IN l_cur
      LOOP
         cn_srp_plan_assigns_pvt.delete_srp_plan_assigns
                           (p_api_version           => 1.0,
                            p_validation_level      => fnd_api.g_valid_level_full,
                            x_return_status         => l_return_status,
                            x_msg_count             => l_msg_count,
                            x_msg_data              => l_msg_data,
                            p_srp_role_id           => l_rec.srp_role_id,
                            p_role_plan_id          => p_role_plan_id,
                            x_loading_status        => l_loading_status
                           );

         IF (l_return_status <> fnd_api.g_ret_sts_success)
         THEN
            x_return_status := l_return_status;
            x_loading_status := l_loading_status;
            EXIT;
         END IF;
      END LOOP;
   END srp_plan_assignment_for_delete;

-- --------------------------------------------------------------------------*
-- Procedure: create_role_plan
-- --------------------------------------------------------------------------*
-- CHANTHON: Added the out params role plan id and obj ver num
   PROCEDURE create_role_plan (
      p_api_version        IN              NUMBER,
      p_init_msg_list      IN              VARCHAR2 := fnd_api.g_false,
      p_commit             IN              VARCHAR2 := fnd_api.g_false,
      p_validation_level   IN              NUMBER
            := fnd_api.g_valid_level_full,
      x_return_status      OUT NOCOPY      VARCHAR2,
      x_loading_status     OUT NOCOPY      VARCHAR2,
      x_msg_count          OUT NOCOPY      NUMBER,
      x_msg_data           OUT NOCOPY      VARCHAR2,
      p_role_plan_rec      IN              role_plan_rec_type
            := g_miss_role_plan_rec,
      x_role_plan_id       OUT NOCOPY      NUMBER,
      x_obj_ver_num        OUT NOCOPY      NUMBER
   )
   IS
      l_api_name       CONSTANT VARCHAR2 (30)           := 'Create_Role_Plan';
      l_api_version    CONSTANT NUMBER                                 := 1.0;
      l_role_plan_id            cn_role_plans.role_plan_id%TYPE;
      l_role_id                 cn_roles.role_id%TYPE;
      l_comp_plan_id            cn_comp_plans.comp_plan_id%TYPE;
      l_object_version_number   cn_role_plans.object_version_number%TYPE := 1;
      -- Declaration for user hooks
      l_rec                     role_plan_rec_type;
      l_oai_array               jtf_usr_hks.oai_data_array_type;
      l_bind_data_id            NUMBER;
      l_org_id                  NUMBER;
      l_status                  VARCHAR2(1);
      l_note_msg                    VARCHAR2 (240);
      l_note_id                     NUMBER;
   BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT create_role_plan;

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

      -- START OF MOAC ORG_ID VALIDATION

      l_org_id := p_role_plan_rec.org_id;
      mo_global.validate_orgid_pub_api(org_id => l_org_id,
                                    status => l_status);

      if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                    'cn.plsql.cn_role_plans_pub.create_role_plan.org_validate',
	      		    'Validated org_id = ' || l_org_id || ' status = '||l_status);
      end if;
      -- END OF MOAC ORG_ID VALIDATION

      -- Assign the parameter to a local variable to be passed to Pre, Post
      -- and Business APIs
      l_rec := p_role_plan_rec;

-- CHANTHON: Added to get the comp plan name and role name when the ids are provided
      IF (l_rec.role_name IS NULL AND l_rec.comp_plan_name IS NULL)
      THEN
         l_rec.comp_plan_name :=
                            cn_api.get_cp_name (p_role_plan_rec.comp_plan_id);
         l_rec.role_name := cn_api.get_role_name (p_role_plan_rec.role_id);
      END IF;

      -- User hooks

      --  Customer pre-processing section
      IF jtf_usr_hks.ok_to_execute ('CN_ROLE_PLANS_PUB',
                                    'CREATE_ROLE_PLAN',
                                    'B',
                                    'C'
                                   )
      THEN
         cn_role_plans_pub_cuhk.create_role_plan_pre
                                   (p_api_version           => p_api_version,
                                    p_init_msg_list         => p_init_msg_list,
                                    p_commit                => p_commit,
                                    p_validation_level      => p_validation_level,
                                    x_return_status         => x_return_status,
                                    x_loading_status        => x_loading_status,
                                    x_msg_count             => x_msg_count,
                                    x_msg_data              => x_msg_data,
                                    p_role_plan_rec         => l_rec
                                   );

         IF (x_return_status = fnd_api.g_ret_sts_error)
         THEN
            RAISE fnd_api.g_exc_error;
         ELSIF (x_return_status = fnd_api.g_ret_sts_unexp_error)
         THEN
            RAISE fnd_api.g_exc_unexpected_error;
         END IF;
      END IF;

      -- Vertical industry pre-processing section
      IF jtf_usr_hks.ok_to_execute ('CN_ROLE_PLANS_PUB',
                                    'CREATE_ROLE_PLAN',
                                    'B',
                                    'V'
                                   )
      THEN
         cn_role_plans_pub_vuhk.create_role_plan_pre
                                   (p_api_version           => p_api_version,
                                    p_init_msg_list         => p_init_msg_list,
                                    p_commit                => p_commit,
                                    p_validation_level      => p_validation_level,
                                    x_return_status         => x_return_status,
                                    x_loading_status        => x_loading_status,
                                    x_msg_count             => x_msg_count,
                                    x_msg_data              => x_msg_data,
                                    p_role_plan_rec         => l_rec
                                   );

         IF (x_return_status = fnd_api.g_ret_sts_error)
         THEN
            RAISE fnd_api.g_exc_error;
         ELSIF (x_return_status = fnd_api.g_ret_sts_unexp_error)
         THEN
            RAISE fnd_api.g_exc_unexpected_error;
         END IF;
      END IF;

      -- Start of API body

      -- CHANTHON: Changed the param from p_role_plan_rec to l_rec
      check_valid_insert (x_return_status       => x_return_status,
                          x_msg_count           => x_msg_count,
                          x_msg_data            => x_msg_data,
                          p_role_plan_rec       => l_rec,
                          x_role_id             => l_role_id,
                          x_comp_plan_id        => l_comp_plan_id,
                          p_loading_status      => x_loading_status,     -- in
                          x_loading_status      => x_loading_status     -- out
                         );

      IF (x_return_status <> fnd_api.g_ret_sts_success)
      THEN
         RAISE fnd_api.g_exc_error;
      ELSE
         SELECT cn_role_plans_s.NEXTVAL
           INTO l_role_plan_id
           FROM DUAL;

-- CHANTHON: Setting the role plan id out param
         x_role_plan_id := l_role_plan_id;
--CHANTHON: Added org id and obj_ver_num in the insert

--- *** Business Events *** ---
   business_event
     (p_operation              => 'create',
      p_pre_or_post	       => 'pre',
      p_role_plan_id           => l_role_plan_id,
      p_role_plan_rec	       => l_rec);


         cn_role_plans_pkg.insert_row
                  (x_rowid                      => g_rowid,
                   x_role_plan_id               => l_role_plan_id,
                   x_role_id                    => l_role_id,
                   x_comp_plan_id               => l_comp_plan_id,
                   x_start_date                 => p_role_plan_rec.start_date,
                   x_end_date                   => p_role_plan_rec.end_date,
                   x_create_module              => 'OSC',
                   x_attribute_category         => p_role_plan_rec.attribute_category,
                   x_attribute1                 => p_role_plan_rec.attribute1,
                   x_attribute2                 => p_role_plan_rec.attribute2,
                   x_attribute3                 => p_role_plan_rec.attribute3,
                   x_attribute4                 => p_role_plan_rec.attribute4,
                   x_attribute5                 => p_role_plan_rec.attribute5,
                   x_attribute6                 => p_role_plan_rec.attribute6,
                   x_attribute7                 => p_role_plan_rec.attribute7,
                   x_attribute8                 => p_role_plan_rec.attribute8,
                   x_attribute9                 => p_role_plan_rec.attribute9,
                   x_attribute10                => p_role_plan_rec.attribute10,
                   x_attribute11                => p_role_plan_rec.attribute11,
                   x_attribute12                => p_role_plan_rec.attribute12,
                   x_attribute13                => p_role_plan_rec.attribute13,
                   x_attribute14                => p_role_plan_rec.attribute14,
                   x_attribute15                => p_role_plan_rec.attribute15,
                   x_created_by                 => g_created_by,
                   x_creation_date              => g_creation_date,
                   x_last_update_login          => g_last_update_login,
                   x_last_update_date           => g_last_update_date,
                   x_last_updated_by            => g_last_updated_by,
                   x_org_id                     => p_role_plan_rec.org_id,
                   x_object_version_number      => l_object_version_number
                  );

		   /*   System Generated - Create Note Functionality */
		 fnd_message.set_name ('CN', 'CN_ROLE_PLAN_CRE');
		fnd_message.set_token ('NEWVALUE', l_rec.role_name);
		 fnd_message.set_token ('NAME', l_rec.comp_plan_name);
		 l_note_msg := fnd_message.get;
		 jtf_notes_pub.create_note
                           (p_api_version             => 1.0,
                            x_return_status           => x_return_status,
                            x_msg_count               => x_msg_count,
                            x_msg_data                => x_msg_data,
                            p_source_object_id        => l_rec.comp_plan_id,
                            p_source_object_code      => 'CN_COMP_PLANS',
                            p_notes                   => l_note_msg,
                            p_notes_detail            => l_note_msg,
                            p_note_type               => 'CN_SYSGEN', -- for system generated
                            x_jtf_note_id             => l_note_id    -- returned
                           );

      -- Call srp-plan assignment API to insert
--CHANTHON: Added the org_id for insert into srp
         srp_plan_assignment_for_insert (p_role_id             => l_role_id,
                                         p_role_plan_id        => l_role_plan_id,
                                         x_return_status       => x_return_status,
                                         p_loading_status      => x_loading_status,
                                         x_loading_status      => x_loading_status,
                                         p_org_id              => l_rec.org_id
                                        );

         IF (x_return_status <> fnd_api.g_ret_sts_success)
         THEN
            RAISE fnd_api.g_exc_error;
         END IF;
      END IF;

      -- End of API body

      -- Post processing hooks

      -- User hooks

      --  Customer post-processing section
      IF jtf_usr_hks.ok_to_execute ('CN_ROLE_PLANS_PUB',
                                    'CREATE_ROLE_PLAN',
                                    'A',
                                    'V'
                                   )
      THEN
         cn_role_plans_pub_cuhk.create_role_plan_post
                                   (p_api_version           => p_api_version,
                                    p_init_msg_list         => p_init_msg_list,
                                    p_commit                => p_commit,
                                    p_validation_level      => p_validation_level,
                                    x_return_status         => x_return_status,
                                    x_loading_status        => x_loading_status,
                                    x_msg_count             => x_msg_count,
                                    x_msg_data              => x_msg_data,
                                    p_role_plan_rec         => l_rec
                                   );

         IF (x_return_status = fnd_api.g_ret_sts_error)
         THEN
            RAISE fnd_api.g_exc_error;
         ELSIF (x_return_status = fnd_api.g_ret_sts_unexp_error)
         THEN
            RAISE fnd_api.g_exc_unexpected_error;
         END IF;
      END IF;

      -- Vertical industry post-processing section
      IF jtf_usr_hks.ok_to_execute ('CN_ROLE_PLANS_PUB',
                                    'CREATE_ROLE_PLAN',
                                    'A',
                                    'C'
                                   )
      THEN
         cn_role_plans_pub_vuhk.create_role_plan_post
                                   (p_api_version           => p_api_version,
                                    p_init_msg_list         => p_init_msg_list,
                                    p_commit                => p_commit,
                                    p_validation_level      => p_validation_level,
                                    x_return_status         => x_return_status,
                                    x_loading_status        => x_loading_status,
                                    x_msg_count             => x_msg_count,
                                    x_msg_data              => x_msg_data,
                                    p_role_plan_rec         => l_rec
                                   );

         IF (x_return_status = fnd_api.g_ret_sts_error)
         THEN
            RAISE fnd_api.g_exc_error;
         ELSIF (x_return_status = fnd_api.g_ret_sts_unexp_error)
         THEN
            RAISE fnd_api.g_exc_unexpected_error;
         END IF;
      END IF;

      -- Message enable hook
      IF jtf_usr_hks.ok_to_execute ('CN_ROLE_PLANS_PUB',
                                    'CREATE_ROLE_PLAN',
                                    'M',
                                    'M'
                                   )
      THEN
         IF cn_role_plans_pub_cuhk.ok_to_generate_msg
                                                    (p_role_plan_rec      => l_rec)
         THEN
    -- Clear bind variables
--  XMLGEN.clearBindValues;

            -- Set values for bind variables,
    -- call this for all bind variables in the business object
--  XMLGEN.setBindValue('SRP_PMT_PLAN_ID', x_srp_pmt_plan_id);

            -- Get a ID for workflow/ business object instance
            l_bind_data_id := jtf_usr_hks.get_bind_data_id;
            --  Do this for all the bind variables in the Business Object
            jtf_usr_hks.load_bind_data (l_bind_data_id,
                                        'ROLE_PLAN_ID',
                                        l_role_plan_id,
                                        'S',
                                        'S'
                                       );
            -- Message generation API
            jtf_usr_hks.generate_message (p_prod_code         => 'CN',
                                          p_bus_obj_code      => 'ROLE_PLAN',
                                          p_bus_obj_name      => 'ROLE_PLAN',
                                          p_action_code       => 'I',
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

-- CHANTHON: Getting the Object Version Number
      x_obj_ver_num := l_object_version_number;

--- *** Business Events *** ---
      business_event
           (p_operation              => 'create',
            p_pre_or_post	       => 'post',
	p_role_plan_id           => l_role_plan_id,
      p_role_plan_rec	       => l_rec);


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
         ROLLBACK TO create_role_plan;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (p_count        => x_msg_count,
                                    p_data         => x_msg_data,
                                    p_encoded      => fnd_api.g_false
                                   );
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         ROLLBACK TO create_role_plan;
         x_loading_status := 'UNEXPECTED_ERR';
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (p_count        => x_msg_count,
                                    p_data         => x_msg_data,
                                    p_encoded      => fnd_api.g_false
                                   );
      WHEN OTHERS
      THEN
         ROLLBACK TO create_role_plan;
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
   END create_role_plan;

-- --------------------------------------------------------------------------*
-- Procedure: Update_Role_Plan
-- CHANTHON: Modified p_ovn to IN OUT param
-- --------------------------------------------------------------------------*
   PROCEDURE update_role_plan (
      p_api_version         IN              NUMBER,
      p_init_msg_list       IN              VARCHAR2 := fnd_api.g_false,
      p_commit              IN              VARCHAR2 := fnd_api.g_false,
      p_validation_level    IN              NUMBER
            := fnd_api.g_valid_level_full,
      x_return_status       OUT NOCOPY      VARCHAR2,
      x_loading_status      OUT NOCOPY      VARCHAR2,
      x_msg_count           OUT NOCOPY      NUMBER,
      x_msg_data            OUT NOCOPY      VARCHAR2,
      p_role_plan_rec_old   IN              role_plan_rec_type
            := g_miss_role_plan_rec,
      p_ovn                 IN OUT NOCOPY   cn_role_plans.object_version_number%TYPE,
      p_role_plan_rec_new   IN              role_plan_rec_type
            := g_miss_role_plan_rec,
      p_role_plan_id        IN              cn_role_plans.role_plan_id%TYPE
   )
   IS
--p_role_plan_id should be NULL if passing p_role_plan_rec_old
      l_api_name      CONSTANT VARCHAR2 (30)            := 'Update_Role_Plan';
      l_api_version   CONSTANT NUMBER                            := 1.0;
      l_role_plan_id_old       cn_role_plans.role_plan_id%TYPE;
      l_role_id                cn_roles.role_id%TYPE;
      l_comp_plan_id           cn_comp_plans.comp_plan_id%TYPE;
      l_date_update_only       VARCHAR2 (1);
      -- Declaration for user hooks
      l_rec_old                role_plan_rec_type;
      l_rec_new                role_plan_rec_type;
      l_oai_array              jtf_usr_hks.oai_data_array_type;
      l_bind_data_id           NUMBER;
      l_org_id                 NUMBER;
      l_status                 VARCHAR2(1);
      l_note_msg                    VARCHAR2 (240);
      l_note_id                     NUMBER;
      l_consolidated_note           VARCHAR2(2000);
      l_consolidated_note_new           VARCHAR2(2000);
   BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT update_role_plan;

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
      x_loading_status := 'CN_UPDATED';

      -- Assign the parameter to a local variable to be passed to Pre, Post
      -- and Business APIs
      l_rec_old := p_role_plan_rec_old;
      l_rec_new := p_role_plan_rec_new;

-- CHANTHON: Added to select the orignial record before updation BEGIN QUERY
-- The role plan id should be passed in as null if the original record
-- before updating is available.
      IF (p_role_plan_id IS NOT NULL)
      THEN
         SELECT cn_api.g_miss_char role_name,
                role_id,
                cn_api.g_miss_char comp_plan_name,
                comp_plan_id,
                start_date,
                end_date,
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
                object_version_number,
                org_id
           INTO l_rec_old
           FROM cn_role_plans
          WHERE role_plan_id = p_role_plan_id;
      END IF;

      -- CHANTHON: Added to select the orignial record before updation END OF QUERY

      -- START OF MOAC ORG_ID VALIDATION
      l_org_id := l_rec_old.org_id;
      mo_global.validate_orgid_pub_api(org_id => l_org_id,
                                       status => l_status);

      if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                    'cn.plsql.cn_role_plans_pub.update_role_plan.org_validate',
	      		    'Validated org_id = ' || l_org_id || ' status = '||l_status);
      end if;

      if (nvl(p_role_plan_rec_new.org_id, l_org_id)
            <> nvl(l_rec_old.org_id, l_org_id)) then
        FND_MESSAGE.SET_NAME ('FND' , 'FND_MO_OU_CANNOT_UPDATE');
        if (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
          FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR,
                       'cn.plsql.cn_role_plans_pub.update_role_plan.error',
	       		       true);
        end if;

        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
  	      FND_MESSAGE.SET_NAME ('FND' , 'FND_MO_OU_CANNOT_UPDATE');
	      FND_MSG_PUB.Add;
        END IF;

        RAISE FND_API.G_EXC_ERROR ;
      end if;
      -- END OF MOAC ORG_ID VALIDATION

      -- CHANTHON: Added to get the comp plan and role names given the ids
      IF (l_rec_new.role_name IS NULL AND l_rec_new.comp_plan_name IS NULL)
      THEN
         l_rec_old.comp_plan_name :=
                                  cn_api.get_cp_name (l_rec_old.comp_plan_id);
         l_rec_old.role_name := cn_api.get_role_name (l_rec_old.role_id);
         l_rec_new.comp_plan_name :=
                        cn_api.get_cp_name (p_role_plan_rec_new.comp_plan_id);
         l_rec_new.role_name :=
                           cn_api.get_role_name (p_role_plan_rec_new.role_id);
      END IF;

      -- User hooks

      --  Customer pre-processing section
      IF jtf_usr_hks.ok_to_execute ('CN_ROLE_PLANS_PUB',
                                    'UPDATE_ROLE_PLAN',
                                    'B',
                                    'C'
                                   )
      THEN
         cn_role_plans_pub_cuhk.update_role_plan_pre
                                   (p_api_version            => p_api_version,
                                    p_init_msg_list          => p_init_msg_list,
                                    p_commit                 => p_commit,
                                    p_validation_level       => p_validation_level,
                                    x_return_status          => x_return_status,
                                    x_loading_status         => x_loading_status,
                                    x_msg_count              => x_msg_count,
                                    x_msg_data               => x_msg_data,
                                    p_role_plan_rec_old      => l_rec_old,
                                    p_role_plan_rec_new      => l_rec_new
                                   );

         IF (x_return_status = fnd_api.g_ret_sts_error)
         THEN
            RAISE fnd_api.g_exc_error;
         ELSIF (x_return_status = fnd_api.g_ret_sts_unexp_error)
         THEN
            RAISE fnd_api.g_exc_unexpected_error;
         END IF;
      END IF;

      -- Vertical industry pre-processing section
      IF jtf_usr_hks.ok_to_execute ('CN_ROLE_PLANS_PUB',
                                    'UPDATE_ROLE_PLAN',
                                    'B',
                                    'V'
                                   )
      THEN
         cn_role_plans_pub_vuhk.update_role_plan_pre
                                   (p_api_version            => p_api_version,
                                    p_init_msg_list          => p_init_msg_list,
                                    p_commit                 => p_commit,
                                    p_validation_level       => p_validation_level,
                                    x_return_status          => x_return_status,
                                    x_loading_status         => x_loading_status,
                                    x_msg_count              => x_msg_count,
                                    x_msg_data               => x_msg_data,
                                    p_role_plan_rec_old      => l_rec_old,
                                    p_role_plan_rec_new      => l_rec_new
                                   );

         IF (x_return_status = fnd_api.g_ret_sts_error)
         THEN
            RAISE fnd_api.g_exc_error;
         ELSIF (x_return_status = fnd_api.g_ret_sts_unexp_error)
         THEN
            RAISE fnd_api.g_exc_unexpected_error;
         END IF;
      END IF;

--CHANTHON:
-- Replaced p_role_plan_rec_old with l_rec_old,
-- and p_role_plan_rec_new with l_rec_new

      -- Start of API body
      check_valid_update (x_return_status          => x_return_status,
                          x_msg_count              => x_msg_count,
                          x_msg_data               => x_msg_data,
                          p_role_plan_rec_old      => l_rec_old,
                          p_role_plan_rec_new      => l_rec_new,
                          x_role_plan_id_old       => l_role_plan_id_old,
                          x_role_id                => l_role_id,
                          x_comp_plan_id           => l_comp_plan_id,
                          x_date_update_only       => l_date_update_only,
                          p_loading_status         => x_loading_status,  -- in
                          x_loading_status         => x_loading_status  -- out
                         );

      -- x_return_status is failure for all failure cases,
      IF (x_return_status <> fnd_api.g_ret_sts_success)
      THEN
         RAISE fnd_api.g_exc_error;
      ELSE
-- CHANTHON: Added ORG_ID in the update

--- *** Business Events *** ---
   business_event
     (p_operation              => 'update',
     p_pre_or_post	       => 'pre',
     p_role_plan_id           => l_role_plan_id_old,
      p_role_plan_rec    => l_rec_old);

         cn_role_plans_pkg.update_row
             (x_role_plan_id               => l_role_plan_id_old,
              x_role_id                    => l_role_id,
              x_comp_plan_id               => l_comp_plan_id,
              x_start_date                 => p_role_plan_rec_new.start_date,
              x_end_date                   => p_role_plan_rec_new.end_date,
              x_attribute_category         => p_role_plan_rec_new.attribute_category,
              x_attribute1                 => p_role_plan_rec_new.attribute1,
              x_attribute2                 => p_role_plan_rec_new.attribute2,
              x_attribute3                 => p_role_plan_rec_new.attribute3,
              x_attribute4                 => p_role_plan_rec_new.attribute4,
              x_attribute5                 => p_role_plan_rec_new.attribute5,
              x_attribute6                 => p_role_plan_rec_new.attribute6,
              x_attribute7                 => p_role_plan_rec_new.attribute7,
              x_attribute8                 => p_role_plan_rec_new.attribute8,
              x_attribute9                 => p_role_plan_rec_new.attribute9,
              x_attribute10                => p_role_plan_rec_new.attribute10,
              x_attribute11                => p_role_plan_rec_new.attribute11,
              x_attribute12                => p_role_plan_rec_new.attribute12,
              x_attribute13                => p_role_plan_rec_new.attribute13,
              x_attribute14                => p_role_plan_rec_new.attribute14,
              x_attribute15                => p_role_plan_rec_new.attribute15,
              x_created_by                 => g_created_by,
              x_creation_date              => g_creation_date,
              x_last_update_login          => g_last_update_login,
              x_last_update_date           => g_last_update_date,
              x_last_updated_by            => g_last_updated_by,
              x_object_version_number      => p_ovn,
              x_org_id                     => l_rec_new.org_id
             );

            l_consolidated_note := '';
            l_consolidated_note_new := '';
	     --Notes when the Role is changed in RolePlam Assignment
           IF (l_rec_new.role_name <> fnd_api.g_miss_char AND l_rec_new.role_name IS NOT NULL
               AND l_rec_old.role_name <> fnd_api.g_miss_char AND l_rec_old.role_name IS NOT NULL
               AND l_rec_new.role_name <> l_rec_old.role_name)
           THEN
                --Notes for Old Role being unassigned
                fnd_message.set_name ('CN', 'CN_ROLE_PLAN_DEL');
                fnd_message.set_token ('NEWVALUE', l_rec_old.role_name);
                fnd_message.set_token ('NAME', l_rec_old.comp_plan_name);
                l_note_msg := fnd_message.get;
                l_consolidated_note := l_consolidated_note || l_note_msg || fnd_global.local_chr(10);
                /*
                jtf_notes_pub.create_note
                           (p_api_version             => 1.0,
                            x_return_status           => x_return_status,
                            x_msg_count               => x_msg_count,
                            x_msg_data                => x_msg_data,
                            p_source_object_id        => l_rec_old.comp_plan_id,
                            p_source_object_code      => 'CN_COMP_PLANS',
                            p_notes                   => l_note_msg,
                            p_notes_detail            => l_note_msg,
                            p_note_type               => 'CN_SYSGEN', -- for system generated
                            x_jtf_note_id             => l_note_id    -- returned
                           );
                           */
                --Notes for New Role being assigned
                fnd_message.set_name ('CN', 'CN_ROLE_PLAN_CRE');
                fnd_message.set_token ('NEWVALUE', l_rec_new.role_name);
                fnd_message.set_token ('NAME', l_rec_new.comp_plan_name);
                l_note_msg := fnd_message.get;
                l_consolidated_note := l_consolidated_note || l_note_msg || fnd_global.local_chr(10);
                /*
                jtf_notes_pub.create_note
                           (p_api_version             => 1.0,
                            x_return_status           => x_return_status,
                            x_msg_count               => x_msg_count,
                            x_msg_data                => x_msg_data,
                            p_source_object_id        => l_rec_new.comp_plan_id,
                            p_source_object_code      => 'CN_COMP_PLANS',
                            p_notes                   => l_note_msg,
                            p_notes_detail            => l_note_msg,
                            p_note_type               => 'CN_SYSGEN', -- for system generated
                            x_jtf_note_id             => l_note_id    -- returned
                           );
                           */
            ELSE IF (l_rec_new.comp_plan_name <> fnd_api.g_miss_char AND l_rec_new.comp_plan_name IS NOT NULL
                    AND l_rec_old.comp_plan_name <> fnd_api.g_miss_char AND l_rec_old.comp_plan_name IS NOT NULL
                    AND l_rec_new.comp_plan_name <> l_rec_old.comp_plan_name)
            THEN
                --Notes for Role being unassigned from Old Compplan
                    fnd_message.set_name ('CN', 'CN_ROLE_PLAN_DEL');
                    fnd_message.set_token ('NEWVALUE', l_rec_old.role_name);
                    fnd_message.set_token ('NAME', l_rec_old.comp_plan_name);
                    l_note_msg := fnd_message.get;
                    l_consolidated_note := l_consolidated_note || l_note_msg || fnd_global.local_chr(10);
                    /*
                    jtf_notes_pub.create_note
                           (p_api_version             => 1.0,
                            x_return_status           => x_return_status,
                            x_msg_count               => x_msg_count,
                            x_msg_data                => x_msg_data,
                            p_source_object_id        => l_rec_old.comp_plan_id,
                            p_source_object_code      => 'CN_COMP_PLANS',
                            p_notes                   => l_note_msg,
                            p_notes_detail            => l_note_msg,
                            p_note_type               => 'CN_SYSGEN', -- for system generated
                            x_jtf_note_id             => l_note_id    -- returned
                           );
                           */
                --Notes for Role being assigned to New Compplan
                    fnd_message.set_name ('CN', 'CN_ROLE_PLAN_CRE');
                    fnd_message.set_token ('NEWVALUE', l_rec_new.role_name);
                    fnd_message.set_token ('NAME', l_rec_new.comp_plan_name);
                    l_note_msg := fnd_message.get;
                    l_consolidated_note_new := l_consolidated_note_new || l_note_msg || fnd_global.local_chr(10);
                    /*
                    jtf_notes_pub.create_note
                           (p_api_version             => 1.0,
                            x_return_status           => x_return_status,
                            x_msg_count               => x_msg_count,
                            x_msg_data                => x_msg_data,
                            p_source_object_id        => l_rec_new.comp_plan_id,
                            p_source_object_code      => 'CN_COMP_PLANS',
                            p_notes                   => l_note_msg,
                            p_notes_detail            => l_note_msg,
                            p_note_type               => 'CN_SYSGEN', -- for system generated
                            x_jtf_note_id             => l_note_id    -- returned
                           );
                           */
             ELSE IF (l_rec_new.start_date <> l_rec_old.start_date)
                  THEN
                --Notes for changing start date for RolePlan assignment
                    fnd_message.set_name ('CN', 'CN_ROLE_PLAN_START_DATE_UPD');
                    fnd_message.set_token ('OLDVALUE', l_rec_old.start_date);
                    fnd_message.set_token ('NEWVALUE', l_rec_new.start_date);
                    fnd_message.set_token ('NAME', l_rec_new.role_name);
                    l_note_msg := fnd_message.get;
                    l_consolidated_note := l_consolidated_note || l_note_msg || fnd_global.local_chr(10);
                    /*
                    jtf_notes_pub.create_note
                           (p_api_version             => 1.0,
                            x_return_status           => x_return_status,
                            x_msg_count               => x_msg_count,
                            x_msg_data                => x_msg_data,
                            p_source_object_id        => l_rec_old.comp_plan_id,
                            p_source_object_code      => 'CN_COMP_PLANS',
                            p_notes                   => l_note_msg,
                            p_notes_detail            => l_note_msg,
                            p_note_type               => 'CN_SYSGEN', -- for system generated
                            x_jtf_note_id             => l_note_id    -- returned
                               );
                               */
                  END IF;
                  IF ((l_rec_old.end_date is null OR l_rec_old.end_date = fnd_api.G_MISS_DATE)
                      AND (l_rec_new.end_date is not null AND l_rec_new.end_date <> fnd_api.G_MISS_DATE))
                  THEN
                --Notes for setting end date for RolePlan assignment
                    fnd_message.set_name ('CN', 'CN_ROLE_PLAN_END_DATE_NULL_UPD');
                    fnd_message.set_token ('NEWVALUE', l_rec_new.end_date);
                    fnd_message.set_token ('NAME', l_rec_new.role_name);
                    l_note_msg := fnd_message.get;
                    l_consolidated_note := l_consolidated_note || l_note_msg || fnd_global.local_chr(10);
                    /*
                    jtf_notes_pub.create_note
                           (p_api_version             => 1.0,
                            x_return_status           => x_return_status,
                            x_msg_count               => x_msg_count,
                            x_msg_data                => x_msg_data,
                            p_source_object_id        => l_rec_old.comp_plan_id,
                            p_source_object_code      => 'CN_COMP_PLANS',
                            p_notes                   => l_note_msg,
                            p_notes_detail            => l_note_msg,
                            p_note_type               => 'CN_SYSGEN', -- for system generated
                            x_jtf_note_id             => l_note_id    -- returned
                             );
                             */
                  ELSE IF ((l_rec_new.end_date is null OR l_rec_new.end_date = fnd_api.G_MISS_DATE)
                      AND (l_rec_old.end_date is not null AND l_rec_old.end_date <> fnd_api.G_MISS_DATE))
                  THEN
                --Notes for removing end date for RolePlan assignment
                    fnd_message.set_name ('CN', 'CN_ROLE_PLAN_END_DATE_UPD_NULL');
                    fnd_message.set_token ('NAME', l_rec_new.role_name);
                    l_note_msg := fnd_message.get;
                    l_consolidated_note := l_consolidated_note || l_note_msg || fnd_global.local_chr(10);
                    /*
                    jtf_notes_pub.create_note
                           (p_api_version             => 1.0,
                            x_return_status           => x_return_status,
                            x_msg_count               => x_msg_count,
                            x_msg_data                => x_msg_data,
                            p_source_object_id        => l_rec_old.comp_plan_id,
                            p_source_object_code      => 'CN_COMP_PLANS',
                            p_notes                   => l_note_msg,
                            p_notes_detail            => l_note_msg,
                            p_note_type               => 'CN_SYSGEN', -- for system generated
                            x_jtf_note_id             => l_note_id    -- returned
                           );
                           */

                  ELSE IF (l_rec_new.end_date <> l_rec_old.end_date)
                  THEN
                --Notes for changing end date for RolePlan assignment
                    fnd_message.set_name ('CN', 'CN_ROLE_PLAN_END_DATE_UPD');
                    fnd_message.set_token ('OLDVALUE', l_rec_old.end_date);
                    fnd_message.set_token ('NEWVALUE', l_rec_new.end_date);
                    fnd_message.set_token ('NAME', l_rec_new.role_name);
                    l_note_msg := fnd_message.get;
                    l_consolidated_note := l_consolidated_note || l_note_msg || fnd_global.local_chr(10);
                    /*
                    jtf_notes_pub.create_note
                           (p_api_version             => 1.0,
                            x_return_status           => x_return_status,
                            x_msg_count               => x_msg_count,
                            x_msg_data                => x_msg_data,
                            p_source_object_id        => l_rec_old.comp_plan_id,
                            p_source_object_code      => 'CN_COMP_PLANS',
                            p_notes                   => l_note_msg,
                            p_notes_detail            => l_note_msg,
                            p_note_type               => 'CN_SYSGEN', -- for system generated
                            x_jtf_note_id             => l_note_id    -- returned
                           );
                           */
                  END IF;
                  END IF;
                  END IF;
               END IF;
           END IF;

           IF LENGTH(l_consolidated_note) > 1 THEN

        jtf_notes_pub.create_note (p_api_version             => 1.0,
	                           x_return_status           => x_return_status,
	                           x_msg_count               => x_msg_count,
	                           x_msg_data                => x_msg_data,
	                           p_source_object_id        => l_rec_old.comp_plan_id,
	                           p_source_object_code      => 'CN_COMP_PLANS',
	                           p_notes                   => l_consolidated_note,
	                           p_notes_detail            => l_consolidated_note,
	                           p_note_type               => 'CN_SYSGEN',                                                  -- for system generated
	                           x_jtf_note_id             => l_note_id                                                                 -- returned
                                   );
           END IF;
           IF LENGTH(l_consolidated_note_new) > 1 THEN

        jtf_notes_pub.create_note (p_api_version             => 1.0,
	                           x_return_status           => x_return_status,
	                           x_msg_count               => x_msg_count,
	                           x_msg_data                => x_msg_data,
	                           p_source_object_id        => l_rec_new.comp_plan_id,
	                           p_source_object_code      => 'CN_COMP_PLANS',
	                           p_notes                   => l_consolidated_note_new,
	                           p_notes_detail            => l_consolidated_note_new,
	                           p_note_type               => 'CN_SYSGEN',                                                  -- for system generated
	                           x_jtf_note_id             => l_note_id                                                                 -- returned
                                   );
           END IF;
--CHANTHON: Selecting the object version number
         SELECT object_version_number
           INTO p_ovn
           FROM cn_role_plans
          WHERE role_plan_id = l_role_plan_id_old;

         -- Call srp assignment API to update

         -- IF UPDATE is only for start_date and end_date THEN call srp_plan_assigns.update
         -- IF the update will change comp plan then
         -- call srp_plan_assign.delete then insert

         --CHANTHON: Added the org_id for the original and updated comp plan
         srp_plan_assignment_for_update
                                    (p_role_id               => l_role_id,
                                     p_role_id_old           => l_rec_old.role_id,
                                     p_role_plan_id          => l_role_plan_id_old,
                                     p_date_update_only      => l_date_update_only,
                                     x_return_status         => x_return_status,
                                     p_loading_status        => x_loading_status,
                                     x_loading_status        => x_loading_status,
                                     p_org_id                => l_rec_new.org_id,
                                     p_org_id_old            => l_rec_old.org_id
                                    );

         IF (x_return_status <> fnd_api.g_ret_sts_success)
         THEN
            RAISE fnd_api.g_exc_error;
         END IF;
      END IF;

      -- End of API body

--- *** Business Events *** ---
   business_event
     (p_operation              => 'update',
     p_pre_or_post	       => 'post',
     p_role_plan_id           => l_role_plan_id_old,
      p_role_plan_rec    => l_rec_new);


      -- Post processing hooks

      -- User hooks

      --  Customer post-processing section
      IF jtf_usr_hks.ok_to_execute ('CN_ROLE_PLANS_PUB',
                                    'UPDATE_ROLE_PLAN',
                                    'A',
                                    'V'
                                   )
      THEN
         cn_role_plans_pub_cuhk.update_role_plan_post
                                   (p_api_version            => p_api_version,
                                    p_init_msg_list          => p_init_msg_list,
                                    p_commit                 => p_commit,
                                    p_validation_level       => p_validation_level,
                                    x_return_status          => x_return_status,
                                    x_loading_status         => x_loading_status,
                                    x_msg_count              => x_msg_count,
                                    x_msg_data               => x_msg_data,
                                    p_role_plan_rec_old      => l_rec_old,
                                    p_role_plan_rec_new      => l_rec_new
                                   );

         IF (x_return_status = fnd_api.g_ret_sts_error)
         THEN
            RAISE fnd_api.g_exc_error;
         ELSIF (x_return_status = fnd_api.g_ret_sts_unexp_error)
         THEN
            RAISE fnd_api.g_exc_unexpected_error;
         END IF;
      END IF;

      -- Vertical industry post-processing section
      IF jtf_usr_hks.ok_to_execute ('CN_ROLE_PLANS_PUB',
                                    'UPDATE_ROLE_PLAN',
                                    'A',
                                    'C'
                                   )
      THEN
         cn_role_plans_pub_vuhk.update_role_plan_post
                                   (p_api_version            => p_api_version,
                                    p_init_msg_list          => p_init_msg_list,
                                    p_commit                 => p_commit,
                                    p_validation_level       => p_validation_level,
                                    x_return_status          => x_return_status,
                                    x_loading_status         => x_loading_status,
                                    x_msg_count              => x_msg_count,
                                    x_msg_data               => x_msg_data,
                                    p_role_plan_rec_old      => l_rec_old,
                                    p_role_plan_rec_new      => l_rec_new
                                   );

         IF (x_return_status = fnd_api.g_ret_sts_error)
         THEN
            RAISE fnd_api.g_exc_error;
         ELSIF (x_return_status = fnd_api.g_ret_sts_unexp_error)
         THEN
            RAISE fnd_api.g_exc_unexpected_error;
         END IF;
      END IF;

      -- Message enable hook
      IF jtf_usr_hks.ok_to_execute ('CN_ROLE_PLANS_PUB',
                                    'UPDATE_ROLE_PLAN',
                                    'M',
                                    'M'
                                   )
      THEN
         IF cn_role_plans_pub_cuhk.ok_to_generate_msg
                                                (p_role_plan_rec      => l_rec_new)
         THEN
    -- Clear bind variables
--  XMLGEN.clearBindValues;

            -- Set values for bind variables,
    -- call this for all bind variables in the business object
--  XMLGEN.setBindValue('SRP_PMT_PLAN_ID', x_srp_pmt_plan_id);

            -- Get a ID for workflow/ business object instance
            l_bind_data_id := jtf_usr_hks.get_bind_data_id;
            --  Do this for all the bind variables in the Business Object
            jtf_usr_hks.load_bind_data (l_bind_data_id,
                                        'ROLE_PLAN_ID',
                                        l_role_plan_id_old,
                                        'S',
                                        'S'
                                       );
            -- Message generation API
            jtf_usr_hks.generate_message (p_prod_code         => 'CN',
                                          p_bus_obj_code      => 'ROLE_PLAN',
                                          p_bus_obj_name      => 'ROLE_PLAN',
                                          p_action_code       => 'I',
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
         ROLLBACK TO update_role_plan;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (p_count        => x_msg_count,
                                    p_data         => x_msg_data,
                                    p_encoded      => fnd_api.g_false
                                   );
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         ROLLBACK TO update_role_plan;
         x_loading_status := 'UNEXPECTED_ERR';
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (p_count        => x_msg_count,
                                    p_data         => x_msg_data,
                                    p_encoded      => fnd_api.g_false
                                   );
      WHEN OTHERS
      THEN
         ROLLBACK TO update_role_plan;
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
   END update_role_plan;

-- --------------------------------------------------------------------------*
-- Procedure: Delete_Role_Plan
-- --------------------------------------------------------------------------*
   PROCEDURE delete_role_plan (
      p_api_version        IN              NUMBER,
      p_init_msg_list      IN              VARCHAR2 := fnd_api.g_false,
      p_commit             IN              VARCHAR2 := fnd_api.g_false,
      p_validation_level   IN              NUMBER
            := fnd_api.g_valid_level_full,
      x_return_status      OUT NOCOPY      VARCHAR2,
      x_loading_status     OUT NOCOPY      VARCHAR2,
      x_msg_count          OUT NOCOPY      NUMBER,
      x_msg_data           OUT NOCOPY      VARCHAR2,
      p_role_plan_rec      IN              role_plan_rec_type
            := g_miss_role_plan_rec
   )
   IS
      l_api_name      CONSTANT VARCHAR2 (30)            := 'Delete_Role_Plan';
      l_api_version   CONSTANT NUMBER                            := 1.0;
      l_role_plan_id           cn_role_plans.role_plan_id%TYPE;
      l_role_id                cn_roles.role_id%TYPE;
      -- Declaration for user hooks
      l_rec                    role_plan_rec_type;
      l_oai_array              jtf_usr_hks.oai_data_array_type;
      l_bind_data_id           NUMBER;
      l_org_id                 NUMBER;
      l_status                 VARCHAR2(1);
      l_note_msg                    VARCHAR2 (240);
      l_note_id                     NUMBER;
   BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT delete_role_plan;

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
      x_loading_status := 'CN_DELETED';

      -- START OF MOAC ORG_ID VALIDATION
      l_org_id := p_role_plan_rec.org_id;
      mo_global.validate_orgid_pub_api(org_id => l_org_id,
                                    status => l_status);

      if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                    'cn.plsql.cn_role_plans_pub.delete_role_plan.org_validate',
	      		    'Validated org_id = ' || l_org_id || ' status = '||l_status);
      end if;
      -- END OF MOAC ORG_ID VALIDATION

      -- Assign the parameter to a local variable to be passed to Pre, Post
      -- and Business APIs
      l_rec := p_role_plan_rec;

      --CHANTHON: Added to get the comp plan name and role name
      IF ((l_rec.role_name IS NULL or l_rec.role_name = cn_api.G_MISS_CHAR)
          AND (l_rec.comp_plan_name IS NULL or l_rec.comp_plan_name = cn_api.G_MISS_CHAR))
      THEN
         l_rec.comp_plan_name :=
                            cn_api.get_cp_name (p_role_plan_rec.comp_plan_id);
         l_rec.role_name := cn_api.get_role_name (p_role_plan_rec.role_id);
      END IF;

      -- User hooks

      --  Customer pre-processing section
      IF jtf_usr_hks.ok_to_execute ('CN_ROLE_PLANS_PUB',
                                    'DELETE_ROLE_PLAN',
                                    'B',
                                    'C'
                                   )
      THEN
         cn_role_plans_pub_cuhk.delete_role_plan_pre
                                   (p_api_version           => p_api_version,
                                    p_init_msg_list         => p_init_msg_list,
                                    p_commit                => p_commit,
                                    p_validation_level      => p_validation_level,
                                    x_return_status         => x_return_status,
                                    x_loading_status        => x_loading_status,
                                    x_msg_count             => x_msg_count,
                                    x_msg_data              => x_msg_data,
                                    p_role_plan_rec         => l_rec
                                   );

         IF (x_return_status = fnd_api.g_ret_sts_error)
         THEN
            RAISE fnd_api.g_exc_error;
         ELSIF (x_return_status = fnd_api.g_ret_sts_unexp_error)
         THEN
            RAISE fnd_api.g_exc_unexpected_error;
         END IF;
      END IF;

      -- Vertical industry pre-processing section
      IF jtf_usr_hks.ok_to_execute ('CN_ROLE_PLANS_PUB',
                                    'DELETE_ROLE_PLAN',
                                    'B',
                                    'V'
                                   )
      THEN
         cn_role_plans_pub_vuhk.delete_role_plan_pre
                                   (p_api_version           => p_api_version,
                                    p_init_msg_list         => p_init_msg_list,
                                    p_commit                => p_commit,
                                    p_validation_level      => p_validation_level,
                                    x_return_status         => x_return_status,
                                    x_loading_status        => x_loading_status,
                                    x_msg_count             => x_msg_count,
                                    x_msg_data              => x_msg_data,
                                    p_role_plan_rec         => l_rec
                                   );

         IF (x_return_status = fnd_api.g_ret_sts_error)
         THEN
            RAISE fnd_api.g_exc_error;
         ELSIF (x_return_status = fnd_api.g_ret_sts_unexp_error)
         THEN
            RAISE fnd_api.g_exc_unexpected_error;
         END IF;
      END IF;

   -- Start of API body

--- *** Business Events *** ---
   business_event
     (p_operation              => 'delete',
     p_pre_or_post	       => 'pre',
     p_role_plan_id           => l_role_plan_id,
      p_role_plan_rec    => l_rec);


-- CHANTHON: Changed p_role-plan_rec to l_rec
      check_valid_delete (x_return_status       => x_return_status,
                          x_msg_count           => x_msg_count,
                          x_msg_data            => x_msg_data,
                          p_role_plan_rec       => l_rec,
                          x_role_plan_id        => l_role_plan_id,
                          p_loading_status      => x_loading_status,     -- in
                          x_loading_status      => x_loading_status     -- out
                         );

      IF (x_return_status <> fnd_api.g_ret_sts_success)
      THEN
         RAISE fnd_api.g_exc_error;
      ELSE
         -- need to call srp assignment API to delete
         l_role_id := cn_api.get_role_id(l_rec.role_name);
         srp_plan_assignment_for_delete
                                       (p_role_id             => l_role_id,
                                        p_role_plan_id        => l_role_plan_id,
                                        x_return_status       => x_return_status,
                                        p_loading_status      => x_loading_status,
                                        x_loading_status      => x_loading_status,
                                        p_org_id              => l_rec.org_id
                                       );

         IF (x_return_status <> fnd_api.g_ret_sts_success)
         THEN
            RAISE fnd_api.g_exc_error;
         END IF;

         -- Added as part of 12+ enhancment
         -- When a plan has been unassigned from role
         -- then we do not want rows in cn_scenario_plans_all
         -- table which contains role_plan_id

          CN_SCENARIOS_PVT.delete_scenario_plans(p_api_version           => p_api_version,
                                                p_init_msg_list         => p_init_msg_list,
                                                p_commit                => p_commit,
                                                p_validation_level      => p_validation_level,
                                                p_role_plan_id => l_role_plan_id,
                                                p_comp_plan_id => null,
                                                p_role_id => null,
                                                x_return_status => x_return_status,
                                                x_msg_count => x_msg_count,
                                                x_msg_data => x_msg_data);

         IF (x_return_status = fnd_api.g_ret_sts_error)
         THEN
            RAISE fnd_api.g_exc_error;
         ELSIF (x_return_status = fnd_api.g_ret_sts_unexp_error)
         THEN
            RAISE fnd_api.g_exc_unexpected_error;
         END IF;
         -- Ends 12+ enhancement

         -- delete_row
         cn_role_plans_pkg.delete_row (x_role_plan_id => l_role_plan_id);

	  /*   System Generated - Create Note Functionality */
        fnd_message.set_name ('CN', 'CN_ROLE_PLAN_DEL');
        fnd_message.set_token ('NEWVALUE', l_rec.role_name);
        fnd_message.set_token ('NAME', l_rec.comp_plan_name);
        l_note_msg := fnd_message.get;
        jtf_notes_pub.create_note
                           (p_api_version             => 1.0,
                            x_return_status           => x_return_status,
                            x_msg_count               => x_msg_count,
                            x_msg_data                => x_msg_data,
                            p_source_object_id        => l_rec.comp_plan_id,
                            p_source_object_code      => 'CN_COMP_PLANS',
                            p_notes                   => l_note_msg,
                            p_notes_detail            => l_note_msg,
                            p_note_type               => 'CN_SYSGEN', -- for system generated
                            x_jtf_note_id             => l_note_id    -- returned
                           );

      END IF;

      -- End of API body

      --- *** Business Events *** ---
      business_event
           (p_operation              => 'delete',
            p_pre_or_post	       => 'post',
	    p_role_plan_id           => l_role_plan_id,
            p_role_plan_rec    => l_rec);

      -- Post processing hooks

      -- User hooks

      --  Customer post-processing section
      IF jtf_usr_hks.ok_to_execute ('CN_ROLE_PLANS_PUB',
                                    'DELETE_ROLE_PLAN',
                                    'A',
                                    'V'
                                   )
      THEN
         cn_role_plans_pub_cuhk.delete_role_plan_post
                                   (p_api_version           => p_api_version,
                                    p_init_msg_list         => p_init_msg_list,
                                    p_commit                => p_commit,
                                    p_validation_level      => p_validation_level,
                                    x_return_status         => x_return_status,
                                    x_loading_status        => x_loading_status,
                                    x_msg_count             => x_msg_count,
                                    x_msg_data              => x_msg_data,
                                    p_role_plan_rec         => l_rec
                                   );

         IF (x_return_status = fnd_api.g_ret_sts_error)
         THEN
            RAISE fnd_api.g_exc_error;
         ELSIF (x_return_status = fnd_api.g_ret_sts_unexp_error)
         THEN
            RAISE fnd_api.g_exc_unexpected_error;
         END IF;
      END IF;

      -- Vertical industry post-processing section
      IF jtf_usr_hks.ok_to_execute ('CN_ROLE_PLANS_PUB',
                                    'DELETE_ROLE_PLAN',
                                    'A',
                                    'C'
                                   )
      THEN
         cn_role_plans_pub_vuhk.delete_role_plan_post
                                   (p_api_version           => p_api_version,
                                    p_init_msg_list         => p_init_msg_list,
                                    p_commit                => p_commit,
                                    p_validation_level      => p_validation_level,
                                    x_return_status         => x_return_status,
                                    x_loading_status        => x_loading_status,
                                    x_msg_count             => x_msg_count,
                                    x_msg_data              => x_msg_data,
                                    p_role_plan_rec         => l_rec
                                   );

         IF (x_return_status = fnd_api.g_ret_sts_error)
         THEN
            RAISE fnd_api.g_exc_error;
         ELSIF (x_return_status = fnd_api.g_ret_sts_unexp_error)
         THEN
            RAISE fnd_api.g_exc_unexpected_error;
         END IF;
      END IF;

      -- Message enable hook
      IF jtf_usr_hks.ok_to_execute ('CN_ROLE_PLANS_PUB',
                                    'DELETE_ROLE_PLAN',
                                    'M',
                                    'M'
                                   )
      THEN
         IF cn_role_plans_pub_cuhk.ok_to_generate_msg
                                                    (p_role_plan_rec      => l_rec)
         THEN
    -- Clear bind variables
    --  XMLGEN.clearBindValues;

            -- Set values for bind variables,
            -- call this for all bind variables in the business object
            --  XMLGEN.setBindValue('SRP_PMT_PLAN_ID', x_srp_pmt_plan_id);

            -- Get a ID for workflow/ business object instance
            l_bind_data_id := jtf_usr_hks.get_bind_data_id;
            --  Do this for all the bind variables in the Business Object
            jtf_usr_hks.load_bind_data (l_bind_data_id,
                                        'ROLE_PLAN_ID',
                                        l_role_plan_id,
                                        'S',
                                        'S'
                                       );
            -- Message generation API
            jtf_usr_hks.generate_message (p_prod_code         => 'CN',
                                          p_bus_obj_code      => 'ROLE_PLAN',
                                          p_bus_obj_name      => 'ROLE_PLAN',
                                          p_action_code       => 'I',
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
         ROLLBACK TO delete_role_plan;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (p_count        => x_msg_count,
                                    p_data         => x_msg_data,
                                    p_encoded      => fnd_api.g_false
                                   );
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         ROLLBACK TO delete_role_plan;
         x_loading_status := 'UNEXPECTED_ERR';
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (p_count        => x_msg_count,
                                    p_data         => x_msg_data,
                                    p_encoded      => fnd_api.g_false
                                   );
      WHEN OTHERS
      THEN
         ROLLBACK TO delete_role_plan;
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
   END delete_role_plan;

END cn_role_plans_pub;

/
