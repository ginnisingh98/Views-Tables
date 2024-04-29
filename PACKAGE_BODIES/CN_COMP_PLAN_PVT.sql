--------------------------------------------------------
--  DDL for Package Body CN_COMP_PLAN_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_COMP_PLAN_PVT" AS
   /*$Header: cnvcmpnb.pls 120.21.12010000.3 2009/09/01 04:13:38 scannane ship $*/
   g_pkg_name           CONSTANT VARCHAR2 (30) := 'CN_COMP_PLAN_PVT';


PROCEDURE business_event(
   p_operation            IN VARCHAR2,
   p_pre_or_post	  IN VARCHAR2,
   p_comp_plan	  	  IN comp_plan_rec_type
  ) IS

   l_key        VARCHAR2(80);
   l_event_name VARCHAR2(80);
   l_list       wf_parameter_list_t;

BEGIN

   -- p_operation = Add, Update, Remove
   l_event_name := 'oracle.apps.cn.events.setup.compplan.' || p_operation || '.' || p_pre_or_post;

   --Get the item key
   l_key := l_event_name || '-' || p_comp_plan.COMP_PLAN_ID;

   -- build parameter list as appropriate
   IF (p_operation = 'create') THEN
      wf_event.AddParameterToList('COMP_PLAN_ID',p_comp_plan.COMP_PLAN_ID,l_list);
      wf_event.AddParameterToList('NAME',p_comp_plan.NAME,l_list);

    ELSIF (p_operation = 'update') THEN
      l_key := l_key || '-' || p_comp_plan.OBJECT_VERSION_NUMBER;

      wf_event.AddParameterToList('COMP_PLAN_ID',p_comp_plan.COMP_PLAN_ID,l_list);
      wf_event.AddParameterToList('NAME',p_comp_plan.NAME,l_list);

    ELSIF (p_operation = 'delete') THEN
      wf_event.AddParameterToList('COMP_PLAN_ID',p_comp_plan.COMP_PLAN_ID,l_list);
      wf_event.AddParameterToList('NAME',p_comp_plan.NAME,l_list);
   END IF;

   -- Raise Event
   wf_event.raise
     (p_event_name        => l_event_name,
      p_event_key         => l_key,
      p_parameters        => l_list);

   l_list.DELETE;

END business_event;


   FUNCTION get_ovn (
      p_id                       IN       NUMBER
   )
      RETURN NUMBER
   IS
      l_num                         NUMBER;
   BEGIN
      SELECT object_version_number
        INTO l_num
        FROM cn_comp_plans_all
       WHERE comp_plan_id = p_id;

      RETURN l_num;
   END;

   PROCEDURE check_org_id (
      p_id                       IN       NUMBER
   )
   IS
   BEGIN
      IF p_id IS NULL
      THEN
         fnd_message.set_name ('FND', 'MO_OU_REQUIRED');
         fnd_msg_pub.ADD;
         RAISE fnd_api.g_exc_error;
      END IF;
   END;

-- Start of comments
--    API name        : Create_Comp_Plan
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
--                      p_comp_plan       IN  comp_plan_rec_type
--    OUT             : x_return_status       OUT     VARCHAR2(1)
--                      x_msg_count           OUT     NUMBER
--                      x_msg_data            OUT     VARCHAR2(2000)
--                      x_comp_plan_id        OUT     NUMBER
--    Version :         Current version       1.0
--    Notes           : Note text
--
-- End of comments
   PROCEDURE create_comp_plan (
      p_api_version              IN       NUMBER,
      p_init_msg_list            IN       VARCHAR2 := fnd_api.g_false,
      p_commit                   IN       VARCHAR2 := fnd_api.g_false,
      p_validation_level         IN       NUMBER := fnd_api.g_valid_level_full,
      p_comp_plan                IN OUT NOCOPY comp_plan_rec_type,
      x_comp_plan_id             OUT NOCOPY NUMBER,
      x_return_status            OUT NOCOPY VARCHAR2,
      x_msg_count                OUT NOCOPY NUMBER,
      x_msg_data                 OUT NOCOPY VARCHAR2
   )
   IS
      l_api_name           CONSTANT VARCHAR2 (30) := 'Create_Comp_Plan';
      l_api_version        CONSTANT NUMBER := 1.0;
      l_temp_count                  NUMBER;
      l_comp_rec                    cn_comp_plan_pub.comp_plan_rec_type;
      l_loading_status              VARCHAR2 (50);
      l_note_msg                    VARCHAR2 (240);
      l_note_id                     NUMBER;
   BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT create_comp_plan;

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
      x_comp_plan_id := p_comp_plan.comp_plan_id;
      -- *** Check the ORG_ID is null or not ***
      check_org_id (p_comp_plan.org_id);

      -- Convert fnd_api.g_miss to NULL

      -- 1. name can not be null
      IF    (p_comp_plan.NAME IS NULL)
         OR (p_comp_plan.NAME = fnd_api.g_miss_char)
         OR (p_comp_plan.start_date IS NULL)
         OR (p_comp_plan.start_date = fnd_api.g_miss_date)
      THEN
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
         THEN
            fnd_message.set_name ('CN', 'CN_REQ_PAR_MISSING');
            fnd_msg_pub.ADD;
         END IF;

         RAISE fnd_api.g_exc_error;
      END IF;

      -- 2. comp plan name must be unique
      SELECT COUNT (1)
        INTO l_temp_count
        FROM cn_comp_plans
       WHERE NAME = p_comp_plan.NAME AND org_id = p_comp_plan.org_id AND ROWNUM = 1;

      IF l_temp_count <> 0
      THEN
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
         THEN
            fnd_message.set_name ('CN', 'CN_INPUT_MUST_UNIQUE');
            fnd_message.set_token ('INPUT_NAME', cn_api.get_lkup_meaning ('NAME', 'INPUT_TOKEN'));
            fnd_msg_pub.ADD;
         END IF;

         RAISE fnd_api.g_exc_error;
      END IF;

      -- start date > end date
      IF (p_comp_plan.end_date IS NOT NULL) AND (p_comp_plan.start_date > p_comp_plan.end_date)
      THEN
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
         THEN
            fnd_message.set_name ('CN', 'CN_DATE_RANGE_ERROR');
            fnd_msg_pub.ADD;
         END IF;

         RAISE fnd_api.g_exc_error;
      END IF;

      -- calling public api
      SELECT DECODE (p_comp_plan.NAME, fnd_api.g_miss_char, NULL, p_comp_plan.NAME),
             DECODE (p_comp_plan.description, fnd_api.g_miss_char, NULL, p_comp_plan.description),
             'INCOMPLETE',
             DECODE (p_comp_plan.allow_rev_class_overlap, fnd_api.g_miss_char, NULL, p_comp_plan.allow_rev_class_overlap),
             DECODE (p_comp_plan.sum_trx_flag, fnd_api.g_miss_char, NULL, p_comp_plan.sum_trx_flag),
             DECODE (p_comp_plan.start_date, fnd_api.g_miss_date, NULL, TRUNC (p_comp_plan.start_date)),
             DECODE (p_comp_plan.end_date, fnd_api.g_miss_date, NULL, TRUNC (p_comp_plan.end_date)),
             NULL,
             DECODE (p_comp_plan.attribute_category, fnd_api.g_miss_char, NULL, p_comp_plan.attribute_category),
             DECODE (p_comp_plan.attribute1, fnd_api.g_miss_char, NULL, p_comp_plan.attribute1),
             DECODE (p_comp_plan.attribute2, fnd_api.g_miss_char, NULL, p_comp_plan.attribute2),
             DECODE (p_comp_plan.attribute3, fnd_api.g_miss_char, NULL, p_comp_plan.attribute3),
             DECODE (p_comp_plan.attribute4, fnd_api.g_miss_char, NULL, p_comp_plan.attribute4),
             DECODE (p_comp_plan.attribute5, fnd_api.g_miss_char, NULL, p_comp_plan.attribute5),
             DECODE (p_comp_plan.attribute6, fnd_api.g_miss_char, NULL, p_comp_plan.attribute6),
             DECODE (p_comp_plan.attribute7, fnd_api.g_miss_char, NULL, p_comp_plan.attribute7),
             DECODE (p_comp_plan.attribute8, fnd_api.g_miss_char, NULL, p_comp_plan.attribute8),
             DECODE (p_comp_plan.attribute9, fnd_api.g_miss_char, NULL, p_comp_plan.attribute9),
             DECODE (p_comp_plan.attribute10, fnd_api.g_miss_char, NULL, p_comp_plan.attribute10),
             DECODE (p_comp_plan.attribute11, fnd_api.g_miss_char, NULL, p_comp_plan.attribute11),
             DECODE (p_comp_plan.attribute12, fnd_api.g_miss_char, NULL, p_comp_plan.attribute12),
             DECODE (p_comp_plan.attribute13, fnd_api.g_miss_char, NULL, p_comp_plan.attribute13),
             DECODE (p_comp_plan.attribute14, fnd_api.g_miss_char, NULL, p_comp_plan.attribute14),
             DECODE (p_comp_plan.attribute15, fnd_api.g_miss_char, NULL, p_comp_plan.attribute15),
             DECODE (p_comp_plan.org_id, fnd_api.g_miss_char, NULL, p_comp_plan.org_id)
        INTO l_comp_rec.NAME,
             l_comp_rec.description,
             l_comp_rec.status,
             l_comp_rec.rc_overlap,
             l_comp_rec.sum_trx,
             l_comp_rec.start_date,
             l_comp_rec.end_date,
             l_comp_rec.plan_element_name,
             l_comp_rec.attribute_category,
             l_comp_rec.attribute1,
             l_comp_rec.attribute2,
             l_comp_rec.attribute3,
             l_comp_rec.attribute4,
             l_comp_rec.attribute5,
             l_comp_rec.attribute6,
             l_comp_rec.attribute7,
             l_comp_rec.attribute8,
             l_comp_rec.attribute9,
             l_comp_rec.attribute10,
             l_comp_rec.attribute11,
             l_comp_rec.attribute12,
             l_comp_rec.attribute13,
             l_comp_rec.attribute14,
             l_comp_rec.attribute15,
             l_comp_rec.org_id
        FROM DUAL;

      -- *** Adding the org_id ***
      l_comp_rec.org_id := p_comp_plan.org_id;

      --- *** Business Events ***---
      business_event
           (p_operation              => 'create',
            p_pre_or_post	       => 'pre',
      p_comp_plan	       => p_comp_plan);


      cn_comp_plan_pub.create_comp_plan (p_api_version           => p_api_version,
                                         p_init_msg_list         => p_init_msg_list,
                                         p_commit                => p_commit,
                                         p_validation_level      => p_validation_level,
                                         x_return_status         => x_return_status,
                                         x_msg_count             => x_msg_count,
                                         x_msg_data              => x_msg_data,
                                         p_comp_plan_rec         => l_comp_rec,
                                         x_comp_plan_id          => x_comp_plan_id,
                                         x_loading_status        => l_loading_status
                                        );

      IF (x_return_status <> fnd_api.g_ret_sts_success)
      THEN
         RAISE fnd_api.g_exc_error;
      END IF;

      p_comp_plan.object_version_number := get_ovn (x_comp_plan_id);


      --- *** Business Events *** ---
      business_event
                 (p_operation              => 'create',
                  p_pre_or_post	     => 'post',
      p_comp_plan	             => p_comp_plan);


      /* System Generated - Create Note Functionality */
      /* This code is later needed when the Public --> Pvt instead of pvt --> public
      fnd_message.set_name ('CN', 'CNR12_NOTE_COMPPLAN_CREATE');
      fnd_message.set_token ('CP_NAME', l_comp_rec.NAME);
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
                            x_jtf_note_id             => l_note_id    -- returned
                           );
       */

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
         ROLLBACK TO create_comp_plan;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         ROLLBACK TO create_comp_plan;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
      WHEN OTHERS
      THEN
         ROLLBACK TO create_comp_plan;
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
   END create_comp_plan;

-- Start of comments
--      API name        : Update_Comp_Plan
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
--                        p_comp_plan         IN comp_plan_rec_type
--      OUT             : x_return_status     OUT     VARCHAR2(1)
--                        x_msg_count         OUT     NUMBER
--                        x_msg_data          OUT     VARCHAR2(2000)
--      Version :         Current version     1.0
--      Notes           : Note text
--
-- End of comments
   PROCEDURE update_comp_plan (
      p_api_version              IN       NUMBER,
      p_init_msg_list            IN       VARCHAR2 := fnd_api.g_false,
      p_commit                   IN       VARCHAR2 := fnd_api.g_false,
      p_validation_level         IN       NUMBER := fnd_api.g_valid_level_full,
      p_comp_plan                IN OUT NOCOPY comp_plan_rec_type,
      x_return_status            OUT NOCOPY VARCHAR2,
      x_msg_count                OUT NOCOPY NUMBER,
      x_msg_data                 OUT NOCOPY VARCHAR2
   )
   IS
      l_api_name           CONSTANT VARCHAR2 (30) := 'Update_Comp_Plan';
      l_api_version        CONSTANT NUMBER := 1.0;
      g_last_update_date            DATE := SYSDATE;
      g_last_updated_by             NUMBER := fnd_global.user_id;
      g_creation_date               DATE := SYSDATE;
      g_created_by                  NUMBER := fnd_global.user_id;
      g_last_update_login           NUMBER := fnd_global.login_id;
      g_rowid                       VARCHAR2 (30);

      CURSOR l_old_comp_plan_cr
      IS
         SELECT *
           FROM cn_comp_plans
          WHERE comp_plan_id = p_comp_plan.comp_plan_id;

      l_old_comp_plan               l_old_comp_plan_cr%ROWTYPE;
      l_comp_plan                   comp_plan_rec_type;
      l_temp_count                  NUMBER;
      l_start_date                  DATE;
      l_end_date                    DATE;
      l_name                        cn_comp_plans.NAME%TYPE;
      l_description                 cn_comp_plans.description%TYPE;
      l_overlap                     cn_comp_plans.allow_rev_class_overlap%TYPE;
      l_sum_trx                     CN_COMP_PLANS.SUM_TRX_FLAG%TYPE;
      l_comp_plan_id                cn_comp_plans.comp_plan_id%TYPE := p_comp_plan.comp_plan_id;
      l_loading_status              VARCHAR2 (50);
      l_return_status               VARCHAR2 (50);
      l_attribute_category          VARCHAR2 (150);
      l_attribute1                  VARCHAR2 (150);
      l_attribute2                  VARCHAR2 (150);
      l_attribute3                  VARCHAR2 (150);
      l_attribute4                  VARCHAR2 (150);
      l_attribute5                  VARCHAR2 (150);
      l_attribute6                  VARCHAR2 (150);
      l_attribute7                  VARCHAR2 (150);
      l_attribute8                  VARCHAR2 (150);
      l_attribute9                  VARCHAR2 (150);
      l_attribute10                 VARCHAR2 (150);
      l_attribute11                 VARCHAR2 (150);
      l_attribute12                 VARCHAR2 (150);
      l_attribute13                 VARCHAR2 (150);
      l_attribute14                 VARCHAR2 (150);
      l_attribute15                 VARCHAR2 (150);
      l_org_id                      NUMBER;
      l_note_msg                    VARCHAR2 (240);
      l_note_id                     NUMBER;
      l_consolidated_note           VARCHAR2(2000);
   BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT update_comp_plan;

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
      -- *** Check the ORG_ID is null or not ***
      check_org_id (p_comp_plan.org_id);

      -- 1. name can not be null
      IF (p_comp_plan.NAME IS NULL) OR (p_comp_plan.start_date IS NULL)
      THEN
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
         THEN
            fnd_message.set_name ('CN', 'CN_REQ_PAR_MISSING');
            fnd_msg_pub.ADD;
         END IF;

         RAISE fnd_api.g_exc_error;
      END IF;

      -- 2. comp plan name must be unique
      SELECT COUNT (1)
        INTO l_temp_count
        FROM cn_comp_plans
       WHERE NAME = p_comp_plan.NAME AND comp_plan_id <> p_comp_plan.comp_plan_id AND org_id = p_comp_plan.org_id AND ROWNUM = 1;

      IF l_temp_count <> 0
      THEN
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
         THEN
            fnd_message.set_name ('CN', 'CN_INPUT_MUST_UNIQUE');
            fnd_message.set_token ('INPUT_NAME', cn_api.get_lkup_meaning ('NAME', 'INPUT_TOKEN'));
            fnd_msg_pub.ADD;
         END IF;

         RAISE fnd_api.g_exc_error;
      END IF;

      -- clku 7/10/2001, bug 1689518
      -- 3. check whether the revenue classes of the plan elements assigned overlap,
      --    give out a warning if revenue classes overlap.
      /*IF p_comp_plan.allow_rev_class_overlap = 'N'
      THEN
         check_revenue_class_overlap (p_comp_plan_id        => p_comp_plan.comp_plan_id,
                                      p_rc_overlap          => p_comp_plan.allow_rev_class_overlap,
                                      p_loading_status      => l_loading_status,
                                      x_loading_status      => l_loading_status,
                                      x_return_status       => l_return_status
                                     );
      -- don't care about the return status here. If it is not 'SUCCESS', we
      -- just return the message as a warning message and let the user carry on
      -- saving the Comp Plan.
      END IF;*/

      OPEN l_old_comp_plan_cr;

      FETCH l_old_comp_plan_cr
       INTO l_old_comp_plan;

      CLOSE l_old_comp_plan_cr;

      SELECT DECODE (p_comp_plan.start_date, fnd_api.g_miss_date, TRUNC (l_old_comp_plan.start_date), TRUNC (p_comp_plan.start_date)),
             DECODE (p_comp_plan.end_date, fnd_api.g_miss_date, TRUNC (l_old_comp_plan.end_date), TRUNC (p_comp_plan.end_date))
        INTO l_start_date,
             l_end_date
        FROM DUAL;

      -- start date > end date
      IF (l_end_date IS NOT NULL) AND (l_start_date > l_end_date)
      THEN
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
         THEN
            fnd_message.set_name ('CN', 'CN_DATE_RANGE_ERROR');
            fnd_msg_pub.ADD;
         END IF;

         RAISE fnd_api.g_exc_error;
      END IF;

      -- call table handler
      SELECT DECODE (p_comp_plan.NAME, fnd_api.g_miss_char, l_old_comp_plan.NAME, p_comp_plan.NAME),
             DECODE (p_comp_plan.description, fnd_api.g_miss_char, l_old_comp_plan.description, p_comp_plan.description),
             DECODE (p_comp_plan.allow_rev_class_overlap,
                     fnd_api.g_miss_char, l_old_comp_plan.allow_rev_class_overlap,
                     p_comp_plan.allow_rev_class_overlap
                    ),
             DECODE (p_comp_plan.sum_trx_flag,
                      fnd_api.g_miss_char, l_old_comp_plan.sum_trx_flag,
                      p_comp_plan.sum_trx_flag
                     ),
             DECODE (p_comp_plan.attribute_category, fnd_api.g_miss_char, l_old_comp_plan.attribute_category, p_comp_plan.attribute_category),
             DECODE (p_comp_plan.attribute1, fnd_api.g_miss_char, l_old_comp_plan.attribute1, p_comp_plan.attribute1),
             DECODE (p_comp_plan.attribute2, fnd_api.g_miss_char, l_old_comp_plan.attribute2, p_comp_plan.attribute2),
             DECODE (p_comp_plan.attribute3, fnd_api.g_miss_char, l_old_comp_plan.attribute3, p_comp_plan.attribute3),
             DECODE (p_comp_plan.attribute4, fnd_api.g_miss_char, l_old_comp_plan.attribute4, p_comp_plan.attribute4),
             DECODE (p_comp_plan.attribute5, fnd_api.g_miss_char, l_old_comp_plan.attribute5, p_comp_plan.attribute5),
             DECODE (p_comp_plan.attribute6, fnd_api.g_miss_char, l_old_comp_plan.attribute6, p_comp_plan.attribute6),
             DECODE (p_comp_plan.attribute7, fnd_api.g_miss_char, l_old_comp_plan.attribute7, p_comp_plan.attribute7),
             DECODE (p_comp_plan.attribute8, fnd_api.g_miss_char, l_old_comp_plan.attribute8, p_comp_plan.attribute8),
             DECODE (p_comp_plan.attribute9, fnd_api.g_miss_char, l_old_comp_plan.attribute9, p_comp_plan.attribute9),
             DECODE (p_comp_plan.attribute10, fnd_api.g_miss_char, l_old_comp_plan.attribute10, p_comp_plan.attribute10),
             DECODE (p_comp_plan.attribute11, fnd_api.g_miss_char, l_old_comp_plan.attribute11, p_comp_plan.attribute11),
             DECODE (p_comp_plan.attribute12, fnd_api.g_miss_char, l_old_comp_plan.attribute12, p_comp_plan.attribute12),
             DECODE (p_comp_plan.attribute13, fnd_api.g_miss_char, l_old_comp_plan.attribute13, p_comp_plan.attribute13),
             DECODE (p_comp_plan.attribute14, fnd_api.g_miss_char, l_old_comp_plan.attribute14, p_comp_plan.attribute14),
             DECODE (p_comp_plan.attribute15, fnd_api.g_miss_char, l_old_comp_plan.attribute15, p_comp_plan.attribute15),
             DECODE (p_comp_plan.org_id, fnd_api.g_miss_char, l_old_comp_plan.org_id, p_comp_plan.org_id)
        INTO l_name,
             l_description,
             l_overlap,
             l_sum_trx,
             l_attribute_category,
             l_attribute1,
             l_attribute2,
             l_attribute3,
             l_attribute4,
             l_attribute5,
             l_attribute6,
             l_attribute7,
             l_attribute8,
             l_attribute9,
             l_attribute10,
             l_attribute11,
             l_attribute12,
             l_attribute13,
             l_attribute14,
             l_attribute15,
             l_org_id
        FROM DUAL;

      -- 3. check object version number
      IF l_old_comp_plan.object_version_number <> p_comp_plan.object_version_number
      THEN
         fnd_message.set_name ('CN', 'CN_RECORD_CHANGED');
         fnd_msg_pub.ADD;
         RAISE fnd_api.g_exc_error;
      END IF;

      -- 4. check for consistency in date range assignment
       -- check plan element assignments - they just have to intersect
       -- role, salesrep assignments have to be contained with in comp plan range
      SELECT COUNT (1)
        INTO l_temp_count
        FROM cn_quotas_v q,
             cn_quota_assigns qa
       WHERE q.quota_id = qa.quota_id
         AND qa.comp_plan_id = l_comp_plan_id
         AND GREATEST (start_date, l_start_date) > LEAST (NVL (end_date, l_end_date), l_end_date);

      -- if end date null then cond doesn't pass, but that's okay
      IF l_temp_count > 0
      THEN
         fnd_message.set_name ('CN', 'CN_PLAN_ELT_DISJOINT');
         fnd_msg_pub.ADD;
         RAISE fnd_api.g_exc_error;
      END IF;

      SELECT COUNT (1)
        INTO l_temp_count
        FROM cn_role_plans
       WHERE comp_plan_id = l_comp_plan_id AND (start_date < l_start_date OR (end_date IS NULL AND l_end_date IS NOT NULL) OR (end_date > l_end_date));

      IF l_temp_count > 0
      THEN
         fnd_message.set_name ('CN', 'CN_ROLE_NOT_WITHIN_PLAN');
         fnd_msg_pub.ADD;
         RAISE fnd_api.g_exc_error;
      END IF;

      -- since srp assignments always within role assignments, then we
      -- don't need to check those
      SELECT org_id
        INTO l_org_id
        FROM cn_comp_plans
       WHERE comp_plan_id = l_comp_plan_id;

--- *** Business Events *** ---
   business_event
     (p_operation              => 'update',
     p_pre_or_post	       => 'pre',
      p_comp_plan    	       => p_comp_plan);


      cn_comp_plans_pkg.begin_record (x_operation                        => 'UPDATE',
                                      x_rowid                            => g_rowid,
                                      x_comp_plan_id                     => l_comp_plan_id,
                                      x_name                             => l_name,
                                      x_description                      => l_description,
                                      x_start_date                       => l_start_date,
                                      x_end_date                         => l_end_date,
                                      x_status_code                      => 'INCOMPLETE',
                                      x_allow_rev_class_overlap          => l_overlap,
                                      x_sum_trx_flag                      => l_sum_trx,
                                      x_last_update_date                 => g_last_update_date,
                                      x_last_updated_by                  => g_last_updated_by,
                                      x_creation_date                    => g_creation_date,
                                      x_created_by                       => g_created_by,
                                      x_last_update_login                => g_last_update_login,
                                      x_program_type                     => 'PL/SQL',
                                      x_start_date_old                   => l_old_comp_plan.start_date,
                                      x_end_date_old                     => l_old_comp_plan.end_date,
                                      x_allow_rev_class_overlap_old      => l_old_comp_plan.allow_rev_class_overlap,
                                      x_attribute_category               => l_attribute_category,
                                      x_attribute1                       => l_attribute1,
                                      x_attribute2                       => l_attribute2,
                                      x_attribute3                       => l_attribute3,
                                      x_attribute4                       => l_attribute4,
                                      x_attribute5                       => l_attribute5,
                                      x_attribute6                       => l_attribute6,
                                      x_attribute7                       => l_attribute7,
                                      x_attribute8                       => l_attribute8,
                                      x_attribute9                       => l_attribute9,
                                      x_attribute10                      => l_attribute10,
                                      x_attribute11                      => l_attribute11,
                                      x_attribute12                      => l_attribute12,
                                      x_attribute13                      => l_attribute13,
                                      x_attribute14                      => l_attribute14,
                                      x_attribute15                      => l_attribute15,
                                      x_org_id                           => l_org_id
                                     );
      p_comp_plan.object_version_number := get_ovn (l_comp_plan_id);

--- *** Business Events *** ---

business_event
     (p_operation              => 'update',
     p_pre_or_post	       => 'post',
      p_comp_plan   	       => p_comp_plan);


      /* Adding Notes Information */

      /* 1. Check if the name has been changed */
      l_consolidated_note := '';
      IF (p_comp_plan.NAME <> fnd_api.g_miss_char AND p_comp_plan.NAME IS NOT NULL AND p_comp_plan.NAME <> l_old_comp_plan.NAME)
      THEN
         -- Need to add note CNR12_NOTE_COMPPLAN_UPDATE
         fnd_message.set_name ('CN', 'CNR12_NOTE_COMPPLAN_UPDATE');
         fnd_message.set_token ('OLD_CP_NAME', l_old_comp_plan.NAME);
         fnd_message.set_token ('NEW_CP_NAME', p_comp_plan.NAME);
         l_note_msg := fnd_message.get;
         l_consolidated_note := l_note_msg || fnd_global.local_chr(10);

         /*
         jtf_notes_pub.create_note (p_api_version             => 1.0,
                                    x_return_status           => x_return_status,
                                    x_msg_count               => x_msg_count,
                                    x_msg_data                => x_msg_data,
                                    p_source_object_id        => l_old_comp_plan.comp_plan_id,
                                    p_source_object_code      => 'CN_COMP_PLANS',
                                    p_notes                   => l_note_msg,
                                    p_notes_detail            => l_note_msg,
                                    p_note_type               => 'CN_SYSGEN',                                                  -- for system generated
                                    x_jtf_note_id             => l_note_id                                                                 -- returned
                                   );
         */
      END IF;

      /* 2. Check if the start date has been changed */
      IF (p_comp_plan.start_date <> fnd_api.g_miss_date AND p_comp_plan.start_date IS NOT NULL
          AND p_comp_plan.start_date <> l_old_comp_plan.start_date
         )
      THEN
         -- Need to add note CNR12_NOTE_COMPPLAN_SDATE_CRE
         fnd_message.set_name ('CN', 'CNR12_NOTE_COMPPLAN_SDATE_CRE');
         fnd_message.set_token ('OLD_ST_DATE', TO_CHAR (l_old_comp_plan.start_date));
         fnd_message.set_token ('NEW_ST_DATE', TO_CHAR (p_comp_plan.start_date));
         l_note_msg := fnd_message.get;
         l_consolidated_note := l_consolidated_note || l_note_msg || fnd_global.local_chr(10);

         /*
         jtf_notes_pub.create_note (p_api_version             => 1.0,
                                    x_return_status           => x_return_status,
                                    x_msg_count               => x_msg_count,
                                    x_msg_data                => x_msg_data,
                                    p_source_object_id        => l_old_comp_plan.comp_plan_id,
                                    p_source_object_code      => 'CN_COMP_PLANS',
                                    p_notes                   => l_note_msg,
                                    p_notes_detail            => l_note_msg,
                                    p_note_type               => 'CN_SYSGEN',                                                  -- for system generated
                                    x_jtf_note_id             => l_note_id                                                                 -- returned
                                   );
         */
      END IF;

      /* 3. Check if the end date has been changed */
      IF (p_comp_plan.end_date <> fnd_api.g_miss_date AND p_comp_plan.end_date IS NOT NULL AND p_comp_plan.end_date <> l_old_comp_plan.end_date)
      THEN
         -- Need to add note CNR12_NOTE_COMPPLAN_EDATE_UPD
         fnd_message.set_name ('CN', 'CNR12_NOTE_COMPPLAN_EDATE_UPD');
         fnd_message.set_token ('OLD_END_DATE', TO_CHAR (l_old_comp_plan.end_date));
         fnd_message.set_token ('NEW_END_DATE', TO_CHAR (p_comp_plan.end_date));
         l_note_msg := fnd_message.get;
         l_consolidated_note := l_consolidated_note || l_note_msg || fnd_global.local_chr(10);
         /*
         jtf_notes_pub.create_note (p_api_version             => 1.0,
                                    x_return_status           => x_return_status,
                                    x_msg_count               => x_msg_count,
                                    x_msg_data                => x_msg_data,
                                    p_source_object_id        => l_old_comp_plan.comp_plan_id,
                                    p_source_object_code      => 'CN_COMP_PLANS',
                                    p_notes                   => l_note_msg,
                                    p_notes_detail            => l_note_msg,
                                    p_note_type               => 'CN_SYSGEN',                                                  -- for system generated
                                    x_jtf_note_id             => l_note_id                                                                 -- returned
                                   );
         */
      END IF;

      /* 4. Allow Revenue Class Overlap flag --> Changed to N */
      IF (    p_comp_plan.allow_rev_class_overlap <> fnd_api.g_miss_char
          AND p_comp_plan.allow_rev_class_overlap IS NOT NULL
          AND p_comp_plan.allow_rev_class_overlap <> l_old_comp_plan.allow_rev_class_overlap
          AND p_comp_plan.allow_rev_class_overlap = 'N'
         )
      THEN
         -- Need to add note CNR12_NOTE_COMPPLAN_ELIG_UPD2
         fnd_message.set_name ('CN', 'CNR12_NOTE_COMPPLAN_ELIG_UPD2');
         l_note_msg := fnd_message.get;
         l_consolidated_note := l_consolidated_note || l_note_msg || fnd_global.local_chr(10);
         /*
         jtf_notes_pub.create_note (p_api_version             => 1.0,
                                    x_return_status           => x_return_status,
                                    x_msg_count               => x_msg_count,
                                    x_msg_data                => x_msg_data,
                                    p_source_object_id        => l_old_comp_plan.comp_plan_id,
                                    p_source_object_code      => 'CN_COMP_PLANS',
                                    p_notes                   => l_note_msg,
                                    p_notes_detail            => l_note_msg,
                                    p_note_type               => 'CN_SYSGEN',                                                  -- for system generated
                                    x_jtf_note_id             => l_note_id                                                                 -- returned
                                   );
         */
      END IF;

      /* 5. Allow Revenue Class Overlap flag --> Changed to Y */
      IF (    p_comp_plan.allow_rev_class_overlap <> fnd_api.g_miss_char
          AND p_comp_plan.allow_rev_class_overlap IS NOT NULL
          AND p_comp_plan.allow_rev_class_overlap <> l_old_comp_plan.allow_rev_class_overlap
          AND p_comp_plan.allow_rev_class_overlap = 'Y'
         )
      THEN
         -- Need to add note CNR12_NOTE_COMPPLAN_ELIG_UPD1
         fnd_message.set_name ('CN', 'CNR12_NOTE_COMPPLAN_ELIG_UPD1');
         l_note_msg := fnd_message.get;
         l_consolidated_note := l_consolidated_note || l_note_msg || fnd_global.local_chr(10);
         /*
         jtf_notes_pub.create_note (p_api_version             => 1.0,
                                    x_return_status           => x_return_status,
                                    x_msg_count               => x_msg_count,
                                    x_msg_data                => x_msg_data,
                                    p_source_object_id        => l_old_comp_plan.comp_plan_id,
                                    p_source_object_code      => 'CN_COMP_PLANS',
                                    p_notes                   => l_note_msg,
                                    p_notes_detail            => l_note_msg,
                                    p_note_type               => 'CN_SYSGEN',                                                  -- for system generated
                                    x_jtf_note_id             => l_note_id                                                                 -- returned
                                   );
         */
      END IF;


      IF LENGTH(l_consolidated_note) > 1 THEN

        jtf_notes_pub.create_note (p_api_version             => 1.0,
	                           x_return_status           => x_return_status,
	                           x_msg_count               => x_msg_count,
	                           x_msg_data                => x_msg_data,
	                           p_source_object_id        => l_old_comp_plan.comp_plan_id,
	                           p_source_object_code      => 'CN_COMP_PLANS',
	                           p_notes                   => l_consolidated_note,
	                           p_notes_detail            => l_consolidated_note,
	                           p_note_type               => 'CN_SYSGEN',                                                  -- for system generated
	                           x_jtf_note_id             => l_note_id                                                                 -- returned
                                   );
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
         ROLLBACK TO update_comp_plan;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         ROLLBACK TO update_comp_plan;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
      WHEN OTHERS
      THEN
         ROLLBACK TO update_comp_plan;
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
   END update_comp_plan;

-- Start of comments
--      API name        : Delete_Comp_Plan
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
--                        p_comp_plan         IN comp_plan_rec_type
--      OUT             : x_return_status     OUT     VARCHAR2(1)
--                        x_msg_count         OUT     NUMBER
--                        x_msg_data          OUT     VARCHAR2(2000)
--      Version :         Current version     1.0
--      Notes           : Note text
--
-- End of comments
   PROCEDURE delete_comp_plan (
      p_api_version              IN       NUMBER,
      p_init_msg_list            IN       VARCHAR2 := fnd_api.g_false,
      p_commit                   IN       VARCHAR2 := fnd_api.g_false,
      p_validation_level         IN       NUMBER := fnd_api.g_valid_level_full,
      p_comp_plan                IN OUT NOCOPY comp_plan_rec_type,
      x_return_status            OUT NOCOPY VARCHAR2,
      x_msg_count                OUT NOCOPY NUMBER,
      x_msg_data                 OUT NOCOPY VARCHAR2
   )
   IS
      l_api_name           CONSTANT VARCHAR2 (30) := 'Delete_Comp_Plan';
      l_api_version        CONSTANT NUMBER := 1.0;
      l_temp_count                  NUMBER;
      l_dummy_row_id                VARCHAR2 (18);
      l_comp_plan_id                cn_comp_plans.comp_plan_id%TYPE := p_comp_plan.comp_plan_id;
      l_note_msg                    VARCHAR2 (240);
      l_note_id                     NUMBER;
      l_org_id                      NUMBER := -999;
      l_cp_name                     cn_comp_plans.NAME%TYPE := NULL;
   BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT delete_comp_plan;

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
      -- *** Check the ORG_ID is null or not ***
      check_org_id (p_comp_plan.org_id);
      l_org_id := p_comp_plan.org_id;
      l_comp_plan_id := p_comp_plan.comp_plan_id;
      -- delete the comp plan
      BEGIN
           SELECT NAME INTO l_cp_name from CN_COMP_PLANS where comp_plan_id = l_comp_plan_id;
      EXCEPTION
      WHEN OTHERS THEN
        NULL;
      END;


--- *** Business Events *** ---
business_event
     (p_operation              => 'delete',
     p_pre_or_post	       => 'pre',
      p_comp_plan    	       => p_comp_plan);

      cn_comp_plans_pkg.begin_record (x_operation                        => 'DELETE',
                                      x_rowid                            => l_dummy_row_id,
                                      x_comp_plan_id                     => l_comp_plan_id,
                                      x_name                             => NULL,
                                      x_last_update_date                 => NULL,
                                      x_last_updated_by                  => NULL,
                                      x_creation_date                    => NULL,
                                      x_created_by                       => NULL,
                                      x_last_update_login                => NULL,
                                      x_description                      => NULL,
                                      x_start_date                       => NULL,
                                      x_start_date_old                   => NULL,
                                      x_end_date                         => NULL,
                                      x_end_date_old                     => NULL,
                                      x_program_type                     => 'API',
                                      x_status_code                      => NULL,
                                      x_allow_rev_class_overlap          => NULL,
                                      x_allow_rev_class_overlap_old      => NULL,
                                      x_sum_trx_flag                     => NULL,
                                      x_attribute_category               => NULL,
                                      x_attribute1                       => NULL,
                                      x_attribute2                       => NULL,
                                      x_attribute3                       => NULL,
                                      x_attribute4                       => NULL,
                                      x_attribute5                       => NULL,
                                      x_attribute6                       => NULL,
                                      x_attribute7                       => NULL,
                                      x_attribute8                       => NULL,
                                      x_attribute9                       => NULL,
                                      x_attribute10                      => NULL,
                                      x_attribute11                      => NULL,
                                      x_attribute12                      => NULL,
                                      x_attribute13                      => NULL,
                                      x_attribute14                      => NULL,
                                      x_attribute15                      => NULL,
                                      x_org_id                           => NULL
                                     );
--- *** Business Events *** ---
business_event
           (p_operation              => 'delete',
           p_pre_or_post             => 'post',
      	   p_comp_plan    	     => p_comp_plan);


      /* Added the Notes for R12 */
      IF (l_org_id <> -999)
      THEN
         fnd_message.set_name ('CN', 'CNR12_NOTE_COMPPLAN_DELETE');
         fnd_message.set_token ('CP_NAME', l_cp_name);
         l_note_msg := fnd_message.get;
         jtf_notes_pub.create_note (p_api_version             => 1.0,
                                    x_return_status           => x_return_status,
                                    x_msg_count               => x_msg_count,
                                    x_msg_data                => x_msg_data,
                                    p_source_object_id        => l_org_id,
                                    p_source_object_code      => 'CN_DELETED_OBJECTS',
                                    p_notes                   => l_note_msg,
                                    p_notes_detail            => l_note_msg,
                                    p_note_type               => 'CN_SYSGEN',                                                  -- for system generated
                                    x_jtf_note_id             => l_note_id                                                                 -- returned
                                   );
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
         ROLLBACK TO delete_comp_plan;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         ROLLBACK TO delete_comp_plan;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
      WHEN OTHERS
      THEN
         ROLLBACK TO delete_comp_plan;
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
   END delete_comp_plan;

-- Start of comments
--      API name        : Get_Comp_Plan_Sum
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
--                        p_start_record      IN      NUMBER
--                          Default = -1
--                        p_fetch_size        IN      NUMBER
--                          Default = -1
--                        p_search_name       IN      VARCHAR2
--                          Default = '%'
--                        p_search_date       IN      DATE
--                          Default = FND_API.G_MISS_DATE
--                        p_search_status     IN      VARCHAR2
--                          Default = FND_API.G_MISS_CHAR
--      OUT             : x_return_status     OUT     VARCHAR2(1)
--                        x_msg_count         OUT     NUMBER
--                        x_msg_data          OUT     VARCHAR2(2000)
--                        x_comp_plan         OUT     comp_plan_tbl_type
--                        x_total_record      OUT     NUMBER
--      Version :         Current version     1.0
--      Notes           : Note text
--
-- End of comments
   PROCEDURE get_comp_plan_sum (
      p_api_version              IN       NUMBER,
      p_init_msg_list            IN       VARCHAR2 := fnd_api.g_false,
      p_commit                   IN       VARCHAR2 := fnd_api.g_false,
      p_validation_level         IN       NUMBER := fnd_api.g_valid_level_full,
      p_start_record             IN       NUMBER := -1,
      p_fetch_size               IN       NUMBER := -1,
      p_search_name              IN       VARCHAR2 := '%',
      p_search_date              IN       DATE := fnd_api.g_miss_date,
      p_search_status            IN       VARCHAR2 := fnd_api.g_miss_char,
      x_comp_plan                OUT NOCOPY comp_plan_tbl_type,
      x_total_record             OUT NOCOPY NUMBER,
      x_return_status            OUT NOCOPY VARCHAR2,
      x_msg_count                OUT NOCOPY NUMBER,
      x_msg_data                 OUT NOCOPY VARCHAR2
   )
   IS
      l_api_name           CONSTANT VARCHAR2 (30) := 'Get_Comp_Plan_Sum';
      l_api_version        CONSTANT NUMBER := 1.0;
      l_counter                     NUMBER;

      CURSOR l_comp_plan_cr
      IS
         SELECT   *
             FROM cn_comp_plans
            WHERE UPPER (NAME) LIKE UPPER (p_search_name)
              AND status_code = DECODE (p_search_status, 'NULL', status_code, p_search_status)
              AND TRUNC (start_date) >= TRUNC (NVL (p_search_date, start_date))
         ORDER BY NAME;
   BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT get_comp_plan_sum;

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
      x_comp_plan := g_miss_comp_plan_rec_tb;
      l_counter := 0;
      x_total_record := 0;

      FOR l_comp_plan IN l_comp_plan_cr
      LOOP
         x_total_record := x_total_record + 1;

         IF (p_fetch_size = -1) OR (x_total_record >= p_start_record AND x_total_record <= (p_start_record + p_fetch_size - 1))
         THEN
            -- assign values of the row to x_srp_list
            l_counter := l_counter + 1;
            x_comp_plan (l_counter).comp_plan_id := l_comp_plan.comp_plan_id;
            x_comp_plan (l_counter).NAME := l_comp_plan.NAME;
            x_comp_plan (l_counter).description := l_comp_plan.description;
            x_comp_plan (l_counter).status_code := l_comp_plan.status_code;
            x_comp_plan (l_counter).complete_flag := l_comp_plan.complete_flag;
            x_comp_plan (l_counter).allow_rev_class_overlap := l_comp_plan.allow_rev_class_overlap;
            x_comp_plan (l_counter).start_date := l_comp_plan.start_date;
            x_comp_plan (l_counter).end_date := l_comp_plan.end_date;
            x_comp_plan (l_counter).object_version_number := l_comp_plan.object_version_number;
         END IF;
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
         ROLLBACK TO get_comp_plan_sum;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         ROLLBACK TO get_comp_plan_sum;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
      WHEN OTHERS
      THEN
         ROLLBACK TO get_comp_plan_sum;
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
   END get_comp_plan_sum;

-- Start of comments
--      API name        : Get_Comp_Plan_Dtl
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
--                        x_comp_plan         OUT     comp_plan_tbl_type
--      Version :         Current version     1.0
--      Notes           : Note text
--
-- End of comments
   PROCEDURE get_comp_plan_dtl (
      p_api_version              IN       NUMBER,
      p_init_msg_list            IN       VARCHAR2 := fnd_api.g_false,
      p_commit                   IN       VARCHAR2 := fnd_api.g_false,
      p_validation_level         IN       NUMBER := fnd_api.g_valid_level_full,
      p_comp_plan_id             IN       NUMBER,
      x_comp_plan                OUT NOCOPY comp_plan_tbl_type,
      x_return_status            OUT NOCOPY VARCHAR2,
      x_msg_count                OUT NOCOPY NUMBER,
      x_msg_data                 OUT NOCOPY VARCHAR2
   )
   IS
      l_api_name           CONSTANT VARCHAR2 (30) := 'Get_Comp_Plan_Dtl';
      l_api_version        CONSTANT NUMBER := 1.0;

      CURSOR l_comp_plan_cr
      IS
         SELECT *
           FROM cn_comp_plans
          WHERE comp_plan_id = p_comp_plan_id;

      l_comp_plan                   l_comp_plan_cr%ROWTYPE;
   BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT get_comp_plan_dtl;

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
      OPEN l_comp_plan_cr;

      LOOP
         FETCH l_comp_plan_cr
          INTO l_comp_plan;

         EXIT WHEN l_comp_plan_cr%NOTFOUND;
         x_comp_plan (1).comp_plan_id := l_comp_plan.comp_plan_id;
         x_comp_plan (1).NAME := l_comp_plan.NAME;
         x_comp_plan (1).description := l_comp_plan.description;
         x_comp_plan (1).status_code := l_comp_plan.status_code;
         x_comp_plan (1).complete_flag := l_comp_plan.complete_flag;
         x_comp_plan (1).allow_rev_class_overlap := l_comp_plan.allow_rev_class_overlap;
         -- 7330382:R12.CN.B scannane
         x_comp_plan (1).sum_trx_flag := l_comp_plan.sum_trx_flag;
         x_comp_plan (1).start_date := l_comp_plan.start_date;
         x_comp_plan (1).end_date := l_comp_plan.end_date;
         x_comp_plan (1).object_version_number := l_comp_plan.object_version_number;
         x_comp_plan (1).attribute_category := l_comp_plan.attribute_category;
         x_comp_plan (1).attribute1 := l_comp_plan.attribute1;
         x_comp_plan (1).attribute2 := l_comp_plan.attribute2;
         x_comp_plan (1).attribute3 := l_comp_plan.attribute3;
         x_comp_plan (1).attribute4 := l_comp_plan.attribute4;
         x_comp_plan (1).attribute5 := l_comp_plan.attribute5;
         x_comp_plan (1).attribute6 := l_comp_plan.attribute6;
         x_comp_plan (1).attribute7 := l_comp_plan.attribute7;
         x_comp_plan (1).attribute8 := l_comp_plan.attribute8;
         x_comp_plan (1).attribute9 := l_comp_plan.attribute9;
         x_comp_plan (1).attribute10 := l_comp_plan.attribute10;
         x_comp_plan (1).attribute11 := l_comp_plan.attribute11;
         x_comp_plan (1).attribute12 := l_comp_plan.attribute12;
         x_comp_plan (1).attribute13 := l_comp_plan.attribute13;
         x_comp_plan (1).attribute14 := l_comp_plan.attribute14;
         x_comp_plan (1).attribute15 := l_comp_plan.attribute15;
      END LOOP;

      IF l_comp_plan_cr%ROWCOUNT = 0
      THEN
         x_comp_plan := g_miss_comp_plan_rec_tb;
      END IF;

      CLOSE l_comp_plan_cr;

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
         ROLLBACK TO get_comp_plan_dtl;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         ROLLBACK TO get_comp_plan_dtl;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
      WHEN OTHERS
      THEN
         ROLLBACK TO get_comp_plan_dtl;
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
   END get_comp_plan_dtl;

-- Start of comments
--      API name        : Get_Sales_Role
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
--                        x_sales_role        OUT     sales_role_tbl_type
--      Version :         Current version     1.0
--      Notes           : Note text
--
-- End of comments
   PROCEDURE get_sales_role (
      p_api_version              IN       NUMBER,
      p_init_msg_list            IN       VARCHAR2 := fnd_api.g_false,
      p_commit                   IN       VARCHAR2 := fnd_api.g_false,
      p_validation_level         IN       NUMBER := fnd_api.g_valid_level_full,
      p_comp_plan_id             IN       NUMBER,
      x_sales_role               OUT NOCOPY sales_role_tbl_type,
      x_return_status            OUT NOCOPY VARCHAR2,
      x_msg_count                OUT NOCOPY NUMBER,
      x_msg_data                 OUT NOCOPY VARCHAR2
   )
   IS
      l_api_name           CONSTANT VARCHAR2 (30) := 'Get_Sales_Role';
      l_api_version        CONSTANT NUMBER := 1.0;

      CURSOR l_sales_role_cr
      IS
         SELECT r.NAME,
                r.description,
                p.start_date,
                p.end_date,
                p.object_version_number,
                r.role_id
           FROM cn_role_plans p,
                cn_roles r
          WHERE p.comp_plan_id = p_comp_plan_id AND r.role_id = p.role_id;

      l_sales_role                  l_sales_role_cr%ROWTYPE;
      l_counter                     NUMBER;
   BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT get_sales_role;

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
      x_sales_role := g_miss_sales_role_rec_tb;
      l_counter := 0;

      FOR l_sales_role IN l_sales_role_cr
      LOOP
         l_counter := l_counter + 1;
         x_sales_role (l_counter).NAME := l_sales_role.NAME;
         x_sales_role (l_counter).description := l_sales_role.description;
         x_sales_role (l_counter).start_date := l_sales_role.start_date;
         x_sales_role (l_counter).end_date := l_sales_role.end_date;
         x_sales_role (l_counter).role_id := l_sales_role.role_id;
         x_sales_role (l_counter).object_version_number := l_sales_role.object_version_number;
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
         ROLLBACK TO get_sales_role;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         ROLLBACK TO get_sales_role;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
      WHEN OTHERS
      THEN
         ROLLBACK TO get_sales_role;
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
   END get_sales_role;

-- Start of comments
--      API name        : Validate_Comp_Plan
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
--                        p_comp_plan         IN comp_plan_rec_type
--      OUT             : x_return_status     OUT     VARCHAR2(1)
--                        x_msg_count         OUT     NUMBER
--                        x_msg_data          OUT     VARCHAR2(2000)
--      Version :         Current version     1.0
--      Notes           : Note text
--
-- End of comments
   PROCEDURE validate_comp_plan (
      p_api_version              IN       NUMBER,
      p_init_msg_list            IN       VARCHAR2 := fnd_api.g_false,
      p_commit                   IN       VARCHAR2 := fnd_api.g_false,
      p_validation_level         IN       NUMBER := fnd_api.g_valid_level_full,
      p_comp_plan                IN       comp_plan_rec_type,
      x_return_status            OUT NOCOPY VARCHAR2,
      x_msg_count                OUT NOCOPY NUMBER,
      x_msg_data                 OUT NOCOPY VARCHAR2
   )
   IS
      l_api_name           CONSTANT VARCHAR2 (30) := 'Validate_Comp_Plan';
      l_api_version        CONSTANT NUMBER := 1.0;
      l_temp_count                  NUMBER;
      l_dummy_row_id                VARCHAR2 (18);

      CURSOR l_old_comp_plan_cr
      IS
         SELECT *
           FROM cn_comp_plans
          WHERE comp_plan_id = p_comp_plan.comp_plan_id;

      l_old_comp_plan               l_old_comp_plan_cr%ROWTYPE;
      l_loading_status              VARCHAR2 (50);
      l_p_loading_status            VARCHAR2 (50);
      l_return_status               VARCHAR2 (50);
      l_incomp_forms                VARCHAR2 (500);
      l_status_code                 VARCHAR2 (30);

      CURSOR incomp_formulas
      IS
         SELECT f.NAME
           FROM cn_quota_assigns qa,
                cn_quotas_v q,
                cn_calc_formulas f
          WHERE qa.comp_plan_id = p_comp_plan.comp_plan_id
            AND q.quota_id = qa.quota_id
            AND q.calc_formula_id = f.calc_formula_id
            AND f.formula_status = 'INCOMPLETE';
   BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT validate_comp_plan;

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
      -- *** Check the ORG_ID is null or not ***
      --check_org_id(p_comp_plan.org_id);

      -- 1. need to have plan element assigned
      SELECT COUNT (1)
        INTO l_temp_count
        FROM cn_quota_assigns
       WHERE comp_plan_id = p_comp_plan.comp_plan_id AND ROWNUM = 1;

      IF l_temp_count = 0
      THEN
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
         THEN
            fnd_message.set_name ('CN', 'CN_NO_PE_ASSIGNED');
            fnd_msg_pub.ADD;
         END IF;

         RAISE fnd_api.g_exc_error;
      END IF;

      -- 2. cannot have incomplete formula assigned
      FOR f IN incomp_formulas
      LOOP
         IF l_incomp_forms IS NOT NULL
         THEN
            l_incomp_forms := l_incomp_forms || ', ';
         END IF;

         l_incomp_forms := l_incomp_forms || f.NAME;
      END LOOP;

      IF l_incomp_forms IS NOT NULL
      THEN
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
         THEN
            fnd_message.set_name ('CN', 'CN_INCOMP_FORMULA');
            fnd_message.set_token ('FORMULA_NAME', l_incomp_forms);
            fnd_msg_pub.ADD;
         END IF;

         RAISE fnd_api.g_exc_error;
      END IF;

      OPEN l_old_comp_plan_cr;

      FETCH l_old_comp_plan_cr
       INTO l_old_comp_plan;

      CLOSE l_old_comp_plan_cr;

      l_p_loading_status := 'VALID_PLAN';
      cn_comp_plan_pvt.check_revenue_class_overlap(p_comp_plan_id => p_comp_plan.comp_plan_id,
      p_rc_overlap          => l_old_comp_plan.allow_rev_class_overlap,
      p_sum_trx_flag        => l_old_comp_plan.sum_trx_flag,
      p_loading_status      => l_p_loading_status,
      x_loading_status      => l_loading_status,
      x_return_status       => x_return_status
      );

      IF l_loading_status = 'VALID_PLAN' THEN

      -- call table handler
      cn_comp_plans_pkg.end_record (x_rowid                        => l_dummy_row_id,
                                    x_comp_plan_id                 => p_comp_plan.comp_plan_id,
                                    x_name                         => l_old_comp_plan.NAME,
                                    x_description                  => l_old_comp_plan.description,
                                    x_start_date                   => l_old_comp_plan.start_date,
                                    x_end_date                     => l_old_comp_plan.end_date,
                                    x_program_type                 => NULL,
                                    x_status_code                  => l_old_comp_plan.status_code,
                                    x_allow_rev_class_overlap      => l_old_comp_plan.allow_rev_class_overlap,
                                    x_sum_trx_flag                 => l_old_comp_plan.sum_trx_flag
                                   );
      END IF;

      SELECT status_code
        INTO l_status_code
        FROM cn_comp_plans
       WHERE comp_plan_id = p_comp_plan.comp_plan_id;

      IF l_status_code <> 'COMPLETE'
      THEN
	x_return_status := fnd_api.g_ret_sts_error;
	--RAISE fnd_api.g_exc_error;
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
         ROLLBACK TO validate_comp_plan;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         ROLLBACK TO validate_comp_plan;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
      WHEN OTHERS
      THEN
         ROLLBACK TO validate_comp_plan;
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
   END validate_comp_plan;

--| -----------------------------------------------------------------------=
--| Procedure Name : check_revenue_class_overlap
--| Desc : Pass in Comp  Plan ID
--|        pass in Comp Plan Name
--| Note:  Comented out the overlap check
--| ---------------------------------------------------------------------=
   PROCEDURE check_revenue_class_overlap (
      p_comp_plan_id             IN       NUMBER,
      p_rc_overlap               IN       VARCHAR2,
      p_sum_trx_flag             IN       VARCHAR2,
      p_loading_status           IN       VARCHAR2,
      x_loading_status           OUT NOCOPY VARCHAR2,
      x_return_status            OUT NOCOPY VARCHAR2
   )
   IS
      l_rev_class_total             NUMBER := 0;
      l_rev_class_total_unique      NUMBER := 0;
      l_comp_plan_name              cn_comp_plans.NAME%TYPE;
      l_rc_overlap                  VARCHAR2 (03);
      l_sum_trx                     VARCHAR2(03);

      /*   CURSOR check_overlap_curs IS
           SELECT  count(value_external_id), count( distinct value_external_id)
        FROM cn_dim_explosion  de,
        cn_quota_rules         qr,
        cn_quota_assigns       qa,
        cn_quotas_v              q,
        cn_dim_hier_periods    dh,
        cn_periods             cp
        WHERE dh.header_hierarchy_id = cn_global_var.g_rev_class_hierarchy_id
        AND cp.start_date            >= q.start_date
        AND cp.end_date              <= nvl(q.end_date,cp.end_date)
        AND cp.period_id             = dh.period_id
        AND de.dim_hierarchy_id      = dh.dim_hierarchy_id
        AND de.ancestor_external_id  = qr.revenue_class_id
        AND qr.quota_id              = qa.quota_id
        AND qa.comp_plan_id          = p_comp_plan_id
        AND qa.quota_id              = q.quota_id
        AND q.quota_type_code IN ('EXTERNAL', 'FORMULA')
        GROUP BY cp.period_id
        HAVING  count(value_external_id) <> count( distinct value_external_id)
        ;
       */

      -- Since cn_dim_hier_periods is gone, we also need to change this
	/*
      CURSOR check_overlap_curs
      IS
SELECT COUNT (de.value_external_id),COUNT (distinct de.value_external_id)
           FROM cn_dim_explosion de,
                cn_quota_rules qr,
                cn_quota_assigns qa,

 (select q1.quota_id, q1.start_date, q1.end_Date
  from   cn_quotas_v q1, cn_quota_assigns qa
             where
             qa.comp_plan_id = p_comp_plan_id
             and qa.quota_id = q1.quota_id
             and exists
             (
                select 1 from   cn_quotas_v q2, cn_quota_assigns qa1
                where
                qa1.comp_plan_id = p_comp_plan_id
                and qa1.quota_id = q2.quota_id
                and q1.quota_id <> q2.quota_id
                and ((q1.end_date is null OR trunc(q1.end_date) >= trunc(q2.start_Date))
                AND (q2.end_date is null OR trunc(q1.start_date) <= trunc(q2.end_date)))

             )
   ) q,

                cn_dim_hierarchies dh
          WHERE
        ( (q.end_date is null OR trunc(q.end_date) >= trunc(dh.start_date))
         AND (dh.end_date is null OR trunc(q.start_date) <= trunc(dh.end_date)) )
            AND de.dim_hierarchy_id = dh.dim_hierarchy_id
            AND de.ancestor_external_id = qr.revenue_class_id
            AND qr.quota_id = qa.quota_id
            AND qa.comp_plan_id = p_comp_plan_id
            AND qa.quota_id = q.quota_id; */

        result boolean;

   BEGIN
      x_return_status := fnd_api.g_ret_sts_success;
      x_loading_status := p_loading_status;

      BEGIN
         SELECT NAME,
                NVL (p_rc_overlap, allow_rev_class_overlap),
                sum_trx_flag
           INTO l_comp_plan_name,
                l_rc_overlap,
                l_sum_trx
           FROM cn_comp_plans
          WHERE comp_plan_id = p_comp_plan_id;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
            THEN
               fnd_message.set_name ('CN', 'CN_CP_NOT_EXIST');
               fnd_msg_pub.ADD;
            END IF;

            x_loading_status := 'CN_CP_NOT_EXIST';
            x_return_status := fnd_api.g_ret_sts_error;
      END;

      IF l_rc_overlap = 'N'
      THEN

       /*  OPEN check_overlap_curs;

         FETCH check_overlap_curs
          INTO l_rev_class_total,
               l_rev_class_total_unique;

         CLOSE check_overlap_curs; */

         result := CN_COMP_PLANS_PKG.check_unique_rev_class(p_comp_plan_id, l_comp_plan_name, l_rc_overlap,l_sum_trx);


         IF (result = false)
         THEN

           /* IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
            THEN
               fnd_message.set_name ('CN', 'PLN_PLAN_DUP_REV_CLASS');
               fnd_message.set_token ('PLAN_NAME', l_comp_plan_name);
               fnd_msg_pub.ADD;
            END IF; */

            x_loading_status := 'PLN_PLAN_DUP_REV_CLASS';
            x_return_status := fnd_api.g_ret_sts_error;
         END IF;
      END IF;
   END check_revenue_class_overlap;

-- Get salespeople assigned to the plan
   PROCEDURE get_assigned_salesreps (
      p_comp_plan_id             IN       NUMBER,
      p_range_low                IN       NUMBER,
      p_range_high               IN       NUMBER,
      x_total_rows               OUT NOCOPY NUMBER,
      x_result_tbl               OUT NOCOPY srp_plan_assign_tbl_type
   )
   IS
      l_index                       NUMBER := 0;

      CURSOR get_data
      IS
         SELECT   spa.srp_plan_assign_id,
                  spa.salesrep_id,
                  spa.role_id,
                  r.NAME role_name,
                  s.NAME salesrep_name,
                  s.employee_number,
                  spa.start_date,
                  spa.end_date
             FROM cn_srp_plan_assigns spa,
                  cn_salesreps s,
                  cn_roles r,
                  cn_srp_roles sr,
                  cn_role_plans rp
            WHERE spa.comp_plan_id = p_comp_plan_id
              AND spa.salesrep_id = s.salesrep_id
              AND spa.role_id = r.role_id
              AND sr.srp_role_id = spa.srp_role_id
              AND rp.role_plan_id = spa.role_plan_id
         ORDER BY s.NAME;
   BEGIN
      x_total_rows := 0;

      FOR c IN get_data
      LOOP
         x_total_rows := x_total_rows + 1;

         IF x_total_rows BETWEEN p_range_low AND p_range_high
         THEN
            l_index := l_index + 1;
            x_result_tbl (l_index) := c;
         END IF;
      END LOOP;
   END get_assigned_salesreps;


-- =====================================================
-- || Procedure: Duplicate_Comp_plan
-- || Description: This Procedure creates a copy of Compplan
-- || in the same Instance and Operating Unit.
-- || This is a Shallow Copy means Children components
-- || are not copied. Children components from the
-- || original Compplan will point to this new
-- || Compplan.
-- =====================================================
   PROCEDURE duplicate_comp_plan  (
     	p_api_version       	IN  NUMBER,
      	p_init_msg_list     	IN  VARCHAR2 := FND_API.G_FALSE,
      	p_commit            	IN  VARCHAR2 := FND_API.G_FALSE,
      	p_validation_level  	IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
      	p_comp_plan_id   		IN  CN_COMP_PLANS.COMP_PLAN_ID%TYPE,
      	p_org_id                IN  NUMBER,
      	x_return_status         OUT NOCOPY VARCHAR2,
      	x_msg_count             OUT NOCOPY NUMBER,
      	x_msg_data              OUT NOCOPY VARCHAR2,
      	x_comp_plan_id          OUT NOCOPY CN_COMP_PLANS.COMP_PLAN_ID%TYPE) IS
        l_api_name                CONSTANT VARCHAR2(30) := 'Duplicate_Comp_Plan';

     l_api_version             CONSTANT NUMBER       := 1.0;


     CURSOR get_comp_plan_data IS
       Select * from cn_comp_plans_all
       Where comp_plan_id = p_comp_plan_id
       And org_id = p_org_id;

     CURSOR get_quota_assign_data IS
       Select * from cn_quota_assigns_all
       Where comp_plan_id = p_comp_plan_id;

       l_comp_plan get_comp_plan_data%rowtype;
       l_comp_plan_rec   comp_plan_rec_type;

       l_quota_assign_rec  CN_QUOTA_ASSIGN_PVT.quota_assign_rec_type;

       l_unique_name varchar2(30);

BEGIN

   -- Standard Start of API savepoint

   SAVEPOINT   duplicate_comp_plan;

   -- Standard call to check for call compatibility.

   IF NOT FND_API.Compatible_API_Call (l_api_version ,
                                       p_api_version ,
                                       l_api_name,
                                       G_PKG_NAME )
     THEN

      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.

   IF FND_API.to_Boolean( p_init_msg_list ) THEN

      FND_MSG_PUB.initialize;

   END IF;

   --  Initialize API return status to success

   x_return_status := FND_API.G_RET_STS_SUCCESS;


Open get_comp_plan_data;
fetch get_comp_plan_data into l_comp_plan;

IF get_comp_plan_data%notfound THEN
 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

-- calling public api
      SELECT
             DECODE (l_comp_plan.description, fnd_api.g_miss_char, NULL, l_comp_plan.description),
             'INCOMPLETE',
             DECODE (l_comp_plan.allow_rev_class_overlap, fnd_api.g_miss_char, NULL, l_comp_plan.allow_rev_class_overlap),
             -- 7330382:R12.CN.B scannane
             DECODE (l_comp_plan.sum_trx_flag, fnd_api.g_miss_char, NULL, l_comp_plan.sum_trx_flag),
             DECODE (l_comp_plan.start_date, fnd_api.g_miss_date, NULL, TRUNC (l_comp_plan.start_date)),
             DECODE (l_comp_plan.end_date, fnd_api.g_miss_date, NULL, TRUNC (l_comp_plan.end_date)),
             DECODE (l_comp_plan.attribute_category, fnd_api.g_miss_char, NULL, l_comp_plan.attribute_category),
             DECODE (l_comp_plan.attribute1, fnd_api.g_miss_char, NULL, l_comp_plan.attribute1),
             DECODE (l_comp_plan.attribute2, fnd_api.g_miss_char, NULL, l_comp_plan.attribute2),
             DECODE (l_comp_plan.attribute3, fnd_api.g_miss_char, NULL, l_comp_plan.attribute3),
             DECODE (l_comp_plan.attribute4, fnd_api.g_miss_char, NULL, l_comp_plan.attribute4),
             DECODE (l_comp_plan.attribute5, fnd_api.g_miss_char, NULL, l_comp_plan.attribute5),
             DECODE (l_comp_plan.attribute6, fnd_api.g_miss_char, NULL, l_comp_plan.attribute6),
             DECODE (l_comp_plan.attribute7, fnd_api.g_miss_char, NULL, l_comp_plan.attribute7),
             DECODE (l_comp_plan.attribute8, fnd_api.g_miss_char, NULL, l_comp_plan.attribute8),
             DECODE (l_comp_plan.attribute9, fnd_api.g_miss_char, NULL, l_comp_plan.attribute9),
             DECODE (l_comp_plan.attribute10, fnd_api.g_miss_char, NULL, l_comp_plan.attribute10),
             DECODE (l_comp_plan.attribute11, fnd_api.g_miss_char, NULL, l_comp_plan.attribute11),
             DECODE (l_comp_plan.attribute12, fnd_api.g_miss_char, NULL, l_comp_plan.attribute12),
             DECODE (l_comp_plan.attribute13, fnd_api.g_miss_char, NULL, l_comp_plan.attribute13),
             DECODE (l_comp_plan.attribute14, fnd_api.g_miss_char, NULL, l_comp_plan.attribute14),
             DECODE (l_comp_plan.attribute15, fnd_api.g_miss_char, NULL, l_comp_plan.attribute15),
             DECODE (l_comp_plan.org_id, fnd_api.g_miss_char, NULL, l_comp_plan.org_id)
        INTO
             l_comp_plan_rec.description,
             l_comp_plan_rec.status_code,
             l_comp_plan_rec.allow_rev_class_overlap,
             -- 7330382:R12.CN.B scannane
             l_comp_plan_rec.sum_trx_flag,
             l_comp_plan_rec.start_date,
             l_comp_plan_rec.end_date,
             l_comp_plan_rec.attribute_category,
             l_comp_plan_rec.attribute1,
             l_comp_plan_rec.attribute2,
             l_comp_plan_rec.attribute3,
             l_comp_plan_rec.attribute4,
             l_comp_plan_rec.attribute5,
             l_comp_plan_rec.attribute6,
             l_comp_plan_rec.attribute7,
             l_comp_plan_rec.attribute8,
             l_comp_plan_rec.attribute9,
             l_comp_plan_rec.attribute10,
             l_comp_plan_rec.attribute11,
             l_comp_plan_rec.attribute12,
             l_comp_plan_rec.attribute13,
             l_comp_plan_rec.attribute14,
             l_comp_plan_rec.attribute15,
             l_comp_plan_rec.org_id
        FROM DUAL;

l_comp_plan_rec.object_version_number := 1;

CN_PLANCOPY_UTIL_PVT.get_unique_name_for_component(p_comp_plan_id,
                        p_org_id,'PLAN',null,null,l_unique_name,
                        x_return_status,x_msg_count,
                        x_msg_data);

IF (x_return_status <> fnd_api.g_ret_sts_success)
      THEN
         RAISE fnd_api.g_exc_error;
END IF;

l_comp_plan_rec.name := l_unique_name;

create_comp_plan(p_api_version,FND_API.G_FALSE,
                 FND_API.G_FALSE,p_validation_level,
                 l_comp_plan_rec,x_comp_plan_id,x_return_status,
                 x_msg_count,x_msg_data);

IF (x_return_status <> fnd_api.g_ret_sts_success)
      THEN
         RAISE fnd_api.g_exc_error;
END IF;

FOR j in  get_quota_assign_data
LOOP

l_quota_assign_rec.comp_plan_id := x_comp_plan_id;
l_quota_assign_rec.quota_id := j.quota_id;
l_quota_assign_rec.org_id := j.org_id;
l_quota_assign_rec.object_version_number := 1;
l_quota_assign_rec.quota_sequence := j.quota_sequence;

CN_QUOTA_ASSIGN_PVT.create_quota_assign(p_api_version,FND_API.G_FALSE,
                 FND_API.G_FALSE,p_validation_level,
                 l_quota_assign_rec,x_return_status,
                 x_msg_count,x_msg_data);

IF (x_return_status <> fnd_api.g_ret_sts_success)
      THEN
         RAISE fnd_api.g_exc_error;
END IF;
END LOOP;



   -- Standard check of p_commit.

   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;

   -- Standard call to get message count and if count is 1, get message info.

   FND_MSG_PUB.Count_And_Get
     (p_count                 =>      x_msg_count             ,
      p_data                  =>      x_msg_data              ,
      p_encoded               =>      FND_API.G_FALSE         );

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO duplicate_comp_plan;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.count_and_get
	(p_count                 =>      x_msg_count             ,
	 p_data                  =>      x_msg_data              ,
	 p_encoded               =>      FND_API.G_FALSE         );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO duplicate_comp_plan;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.count_and_get
	(p_count                 =>      x_msg_count             ,
	 p_data                  =>      x_msg_data              ,
	 p_encoded               =>      FND_API.G_FALSE         );

   WHEN OTHERS THEN
      ROLLBACK TO duplicate_comp_plan;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF      FND_MSG_PUB.check_msg_level
	(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	THEN
	 FND_MSG_PUB.add_exc_msg
	   (G_PKG_NAME          ,
	    l_api_name           );
      END IF;

      FND_MSG_PUB.count_and_get
	(p_count                 =>      x_msg_count             ,
	 p_data                  =>      x_msg_data              ,
	 p_encoded               =>      FND_API.G_FALSE         );

END duplicate_comp_plan;



END cn_comp_plan_pvt;

/
