--------------------------------------------------------
--  DDL for Package Body AMS_DELIVERABLE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_DELIVERABLE_PVT" AS
/* $Header: amsvdelb.pls 120.1.12010000.3 2010/05/12 04:16:22 amlal ship $ */

g_pkg_name  CONSTANT VARCHAR2(30):='AMS_Deliverable_PVT';

---------------------------------------------------------------------
-- PROCEDURE
--    create_pricelist_header
--
-- HISTORY
--    02/16/2000  khung@us  Create.
---------------------------------------------------------------------

AMS_DEBUG_HIGH_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

PROCEDURE create_pricelist_header
(
  p_api_version             IN  NUMBER,
  p_init_msg_list           IN  VARCHAR2 := FND_API.g_false,
  p_return_values           IN  VARCHAR2 := FND_API.g_false,
  p_commit                  IN  VARCHAR2 := FND_API.g_false,
  p_deliv_rec               IN  deliv_rec_type,
  x_return_status           OUT NOCOPY VARCHAR2,
  x_msg_count               OUT NOCOPY NUMBER,
  x_msg_data                OUT NOCOPY VARCHAR2,
  x_pricelist_header_id     OUT NOCOPY NUMBER
);
--------------------------------------------------------------------
--
-- PROCEDURE
--  deliverable_cancellation
--
-- HISTORY
-- 10/04/2000   musman@us  Create
--
---------------------------------------------------------------------
PROCEDURE Deliverable_Cancellation
(
  p_deliverable_rec  IN deliv_rec_type,
  x_return_status OUT NOCOPY   VARCHAR2
  );

---------------------------------------------------------------------
-- PROCEDURE
--    create_pricelist_line
--
-- HISTORY
--    02/17/2000  khung@us  Create.
---------------------------------------------------------------------

PROCEDURE create_pricelist_line
(
  p_api_version             IN  NUMBER,
  p_init_msg_list           IN  VARCHAR2 := FND_API.g_false,
  p_return_values           IN  VARCHAR2 := FND_API.g_false,
  p_commit                  IN  VARCHAR2 := FND_API.g_false,
  p_price_hdr_id            IN  NUMBER,
  p_deliv_rec               IN  deliv_rec_type,
  x_return_status           OUT NOCOPY VARCHAR2,
  x_msg_count               OUT NOCOPY NUMBER,
  x_msg_data                OUT NOCOPY VARCHAR2,
  x_pricelist_line_id       OUT NOCOPY NUMBER
);

---------------------------------------------------------------------
-- PROCEDURE
--    create_jtf_attachment
--
-- HISTORY
--    02/22/2000  khung@us  Create.
---------------------------------------------------------------------

PROCEDURE create_jtf_attachment
(
  p_used_by             IN  VARCHAR2,
  p_used_by_id          IN  NUMBER,
  p_file_id             IN  NUMBER,
  p_file_name           IN  VARCHAR2,
  p_att_type            IN  VARCHAR2,
  p_file_ver            IN  VARCHAR2,
  x_return_status       OUT NOCOPY VARCHAR2,
  x_msg_count           OUT NOCOPY NUMBER,
  x_msg_data            OUT NOCOPY VARCHAR2,
  x_att_id              OUT NOCOPY NUMBER
);

-------------------------------------------------------------------
-- PROCEDURE
--    check_owner_id
--
-- HISTORY
-- 03/14/2001 musman@us  Created
-------------------------------------------------------------------

PROCEDURE check_owner_id
(
    p_deliv_rec      IN        deliv_rec_type,
    x_return_status  OUT NOCOPY       VARCHAR2
);
-------------------------------------------------------------------
-- PROCEDURE
--    check_budget_lines
--
-- HISTORY
-- 04/05/2001 musman@us  Create
-------------------------------------------------------------------

PROCEDURE check_budget_lines
(
    p_deliv_rec      IN        deliv_rec_type,
    x_return_status  OUT NOCOPY       VARCHAR2
);
-------------------------------------------------------------------
-- PROCEDURE
--    check_inv_item
--
-- HISTORY
-- 11/26/2002 musman@us  Create
-------------------------------------------------------------------

PROCEDURE check_inv_item
(
    p_deliv_rec      IN    deliv_rec_type,
    x_return_status  OUT NOCOPY   VARCHAR2
    );

-------------------------------------------------------------------
-- PROCEDURE
--    create_inv_item
--
-- HISTORY
-- 02/25/2002 musman@us  Create
-------------------------------------------------------------------

PROCEDURE creat_inv_item
(
    p_deliv_rec      IN    deliv_rec_type,
    x_inv_id           OUT NOCOPY   NUMBER,
    x_org_id           OUT NOCOPY   NUMBER,
    x_return_status  OUT NOCOPY   VARCHAR2,
    x_msg_count      OUT NOCOPY   NUMBER,
    x_msg_data       OUT NOCOPY   VARCHAR2
    );
-------------------------------------------------------------------
-- PROCEDURE
--    check_inactive_deliv
--
-- HISTORY
-- 02/25/2002 musman@us  Create
-------------------------------------------------------------------

PROCEDURE check_inactive_deliv
(
    p_deliv_rec      IN        deliv_rec_type,
    x_return_status  OUT NOCOPY       VARCHAR2
);

-------------------------------------------------------------------
-- PROCEDURE
--    check_periods
--
-- HISTORY
-- 02/21/2001  musman@us Created
-------------------------------------------------------------------
PROCEDURE check_periods
( p_deliv_Rec             IN   deliv_rec_type
 ,x_deliverable_calendar  OUT NOCOPY  VARCHAR2
 ,x_return_status         OUT NOCOPY  VARCHAR2);

------------------------------------------------------------------
-- Function
--    Approval_required_flag
-- Purpose
--    This function will return the approval required flag for the
--    given custom setup.
-- History
--   07/31/2001   musman@us  created
------------------------------------------------------------------
FUNCTION Approval_Required_Flag
( p_custom_setup_id    IN   NUMBER ,
  p_approval_type      IN   VARCHAR2
 ) RETURN VARCHAR2;



--------------------------------------------------------------------
-- PROCEDURE
--    create_deliverable
--
-- HISTORY
--    10/09/1999    khung@us    Create.
--   24-Aug-2000    choang      Added l_task_planned_start_date to
--                              make the start date less than the
--                              the end date.
---------------------------------------------------------------------

PROCEDURE create_deliverable
(
  p_api_version         IN  NUMBER,
  p_init_msg_list       IN  VARCHAR2 := FND_API.g_false,
  p_commit              IN  VARCHAR2 := FND_API.g_false,
  p_validation_level    IN  NUMBER   := FND_API.g_valid_level_full,

  x_return_status       OUT NOCOPY VARCHAR2,
  x_msg_count           OUT NOCOPY NUMBER,
  x_msg_data            OUT NOCOPY VARCHAR2,

  p_deliv_rec           IN  deliv_rec_type,
  x_deliv_id            OUT NOCOPY NUMBER

)
IS

   l_api_version    CONSTANT NUMBER       := 1.0;
   l_api_name       CONSTANT VARCHAR2(30) := 'create_deliverable';
   l_full_name      CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

   l_return_status  VARCHAR2(1);
   l_deliv_rec      deliv_rec_type := p_deliv_rec;
   l_deliv_count    NUMBER;
   l_status_code    VARCHAR2(30);

   l_obj_type       VARCHAR2(30);
   l_obj_id         NUMBER;
   l_setup_id       NUMBER;
   l_task_planned_start_date  DATE := SYSDATE;

   CURSOR c_deliv_seq IS
   SELECT ams_deliverables_all_b_s.NEXTVAL
     FROM DUAL;

   CURSOR c_deliv_count(deliv_id IN NUMBER) IS
   SELECT COUNT(*)
     FROM ams_deliverables_vl
    WHERE deliverable_id = deliv_id;

   CURSOR c_status_code(status_id IN NUMBER) IS
   SELECT system_status_code
     FROM ams_user_statuses_vl
    WHERE system_status_type = 'AMS_DELIV_STATUS'
      AND user_status_id = status_id;

   CURSOR c_get_custom_setup_id IS
   SELECT custom_setup_id
     FROM ams_custom_setups_b
    WHERE object_type = 'DELV';
/*
   CURSOR c_get_status_id(status_code IN VARCHAR2) IS
   SELECT user_status_id
     -- SQLID: 11753160 fix FROM ams_user_statuses_vl a
     FROM ams_user_statuses_b a
    WHERE system_status_type = 'AMS_DELIV_STATUS'
      AND system_Status_code = status_code
      AND a.user_status_id = (SELECT MIN(b.user_status_id)
                              --SQLID: 11753160 fix FROM ams_user_statuses_vl b
			      FROM ams_user_statuses_b b
                              WHERE b.system_status_type = a.system_status_type
                              AND a.system_status_code = b.system_Status_code) ;
                              */

   -- soagrawa replaced the above cursor with the following cursor, for R12 drop 4 sql id 14419805
   -- refer bug 4956974
   -- still not sure why MIN is being used instead of default flag = 'Y' : open issue
   CURSOR c_get_status_id(status_code IN VARCHAR2) IS
   SELECT min(user_status_id)
     FROM ams_user_statuses_b a
    WHERE system_status_type = 'AMS_DELIV_STATUS'
      AND system_Status_code = status_code;


   -- variables for task creation
   x_task_id            NUMBER;

   -- variables for task assignment creation
   x_task_assignment_id NUMBER;

   x_deliv_rec_from_init   deliv_rec_type ;
   x_deliv_rec   deliv_rec_type ;
   l_msg_count     NUMBER;
   l_msg_data      VARCHAR2(2000);

   l_access_rec               AMS_Access_PVT.access_rec_type;

   l_association_rec          AMS_Associations_PVT.association_rec_type;
   l_object_association_id    NUMBER;

   l_trim_task_name       VARCHAR2(80);
   l_source_object_name   VARCHAR2(80);

   l_org_id         NUMBER;

BEGIN

   --------------------- initialize -----------------------
   SAVEPOINT create_deliverable;

   IF (AMS_DEBUG_HIGH_ON) THEN
   AMS_Utility_PVT.debug_message(l_full_name||': start');
   END IF;

   l_org_id := fnd_profile.value('DEFAULT_ORG_ID');

   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   IF NOT FND_API.compatible_api_call
   (
         l_api_version,
         p_api_version,
         l_api_name,
         g_pkg_name
   ) THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   x_return_status := FND_API.g_ret_sts_success;

   /* added by musman
     if the periods exist then only the calendar values has to updated
   */
   IF ((l_deliv_rec.start_period_name IS NOT NULL)
   OR (l_deliv_rec.end_period_name IS NOT NULL)) THEN

      -- default deliverable_calendar
      IF l_deliv_rec.deliverable_calendar IS NULL THEN
         l_deliv_rec.deliverable_calendar := FND_PROFILE.value('AMS_CAMPAIGN_DEFAULT_CALENDER');
      END IF;

    END IF;

   ----------------------- validate -----------------------
   IF (AMS_DEBUG_HIGH_ON) THEN
   AMS_Utility_PVT.debug_message(l_full_name ||': validate');
   END IF;

   IF l_deliv_rec.transaction_currency_code IS NULL
   OR l_deliv_rec.transaction_currency_code = FND_API.G_MISS_CHAR
   THEN
      l_deliv_rec.transaction_currency_code := l_deliv_rec.currency_code;
   END IF;

   -- calling the public apis validate_delieverable
   -- validate_deliverable
   ams_deliverable_pub.validate_deliverable
   (
      p_api_version_number    => l_api_version,
      p_init_msg_list      => FND_API.g_false,
      p_validation_level   => p_validation_level,
      --p_validation_mode    => JTF_PLSQL_API.g_create,
      x_return_status      => l_return_status,
      x_msg_count          => x_msg_count,
      x_msg_data           => x_msg_data,
      p_deliv_rec          => l_deliv_rec
   );

   IF l_return_status = FND_API.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
   ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   -------------------------- insert --------------------------
   IF (AMS_DEBUG_HIGH_ON) THEN
   AMS_Utility_PVT.debug_message(l_full_name ||': insert');
   END IF;

   IF l_deliv_rec.deliverable_id IS NULL THEN
   LOOP
      OPEN c_deliv_seq;
      FETCH c_deliv_seq INTO l_deliv_rec.deliverable_id;
      CLOSE c_deliv_seq;

      OPEN c_deliv_count(l_deliv_rec.deliverable_id);
      FETCH c_deliv_count INTO l_deliv_count;
      CLOSE c_deliv_count;

      EXIT WHEN l_deliv_count = 0;
   END LOOP;
   END IF;


   /* added musman since all the deliverables has to be created with status new */
   IF l_deliv_rec.user_status_id IS NOT NULL THEN
      OPEN c_status_code(l_deliv_rec.user_status_id);
      FETCH c_status_code INTO l_status_code;
      CLOSE c_status_code;
   ELSE
      l_status_code := 'NEW';
      OPEN c_get_status_id(l_status_code);
      FETCH c_get_status_id INTO l_deliv_Rec.user_status_id;
      CLOSE c_get_status_id;
   END IF;
   /*
   OPEN c_status_code(l_deliv_rec.user_status_id);
   FETCH c_status_code INTO l_status_code;
   CLOSE c_status_code;
   */
   l_deliv_rec.status_code := l_status_code;




   INSERT INTO ams_deliverables_all_b(
      deliverable_id,
      last_update_date,
      last_updated_by,
      creation_date,
      created_by,
      last_update_login,
      object_version_number,
      language_code,
      version,
      application_id,
      user_status_id,
      status_code,
      status_date,
      active_flag,
      private_flag,
      owner_user_id,
      org_id,
      fund_source_id,
      fund_source_type,
      category_type_id,
      category_sub_type_id,
      kit_flag,
      can_fulfill_electronic_flag,
      can_fulfill_physical_flag,
      jtf_amv_item_id,
      inventory_flag,
      transaction_currency_code,
      functional_currency_code,
      budget_amount_tc,
      budget_amount_fc,
      actual_avail_from_date,
      actual_avail_to_date,
      forecasted_complete_date,
      actual_complete_date,
      replaced_by_deliverable_id,
      inventory_item_id,
      inventory_item_org_id,
      pricelist_header_id,
      pricelist_line_id,
      non_inv_ctrl_code,
      non_inv_quantity_on_hand,
      non_inv_quantity_on_order,
      non_inv_quantity_on_reserve,
      chargeback_amount,
      chargeback_amount_curr_code,
      deliverable_code,
      deliverable_pick_flag,
      currency_code,
      forecasted_cost,
      actual_cost,
      forecasted_responses,
      actual_responses,
      country,
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
      chargeback_uom ,
      deliverable_calendar,
      start_period_name,
      end_period_name,
      country_id,
      custom_setup_id,
      email_content_type
      )  VALUES (
      l_deliv_rec.deliverable_id,
      SYSDATE,
      FND_GLOBAL.user_id,
      SYSDATE,
      FND_GLOBAL.user_id,
      FND_GLOBAL.conc_login_id,
      1,  -- object_version_number
      l_deliv_rec.language_code,
      l_deliv_rec.version,
      l_deliv_rec.application_id,
      l_deliv_rec.user_status_id,
      l_deliv_rec.status_code,
      l_deliv_rec.status_date,
      NVL(l_deliv_rec.active_flag, 'Y'),
      NVL(l_deliv_rec.private_flag, 'N'),
      l_deliv_rec.owner_user_id,
      l_org_id, -- org_id
      l_deliv_rec.fund_source_id,
      l_deliv_rec.fund_source_type,
      l_deliv_rec.category_type_id,
      l_deliv_rec.category_sub_type_id,
      NVL(l_deliv_rec.kit_flag, 'N'),
      NVL(l_deliv_rec.can_fulfill_electronic_flag, 'N'),
      NVL(l_deliv_rec.can_fulfill_physical_flag, 'N'),
      l_deliv_rec.jtf_amv_item_id,
      NVL(l_deliv_rec.inventory_flag, 'N'),
      l_deliv_rec.transaction_currency_code,--l_deliv_rec.currency_code, /* since defaulted to currency_code if it is null */
      l_deliv_rec.functional_currency_code,
      l_deliv_rec.budget_amount_tc,
      l_deliv_rec.budget_amount_fc,
      l_deliv_rec.actual_avail_from_date,
      l_deliv_rec.actual_avail_to_date,
      l_deliv_rec.forecasted_complete_date,
      l_deliv_rec.actual_complete_date,
      l_deliv_rec.replaced_by_deliverable_id,
      l_deliv_rec.inventory_item_id,
      l_deliv_rec.inventory_item_org_id,
      l_deliv_rec.pricelist_header_id,
      l_deliv_rec.pricelist_line_id,
      l_deliv_rec.non_inv_ctrl_code,
      l_deliv_rec.non_inv_quantity_on_hand,
      l_deliv_rec.non_inv_quantity_on_order,
      l_deliv_rec.non_inv_quantity_on_reserve,
      l_deliv_rec.chargeback_amount,
      l_deliv_rec.chargeback_amount_curr_code,
      l_deliv_rec.deliverable_code,
      NVL(l_deliv_rec.deliverable_pick_flag, 'N'),
      l_deliv_rec.currency_code,
      l_deliv_rec.forecasted_cost,
      l_deliv_rec.actual_cost,
      l_deliv_rec.forecasted_responses,
      l_deliv_rec.actual_responses,
      l_deliv_rec.country,
      l_deliv_rec.attribute_category,
      l_deliv_rec.attribute1,
      l_deliv_rec.attribute2,
      l_deliv_rec.attribute3,
      l_deliv_rec.attribute4,
      l_deliv_rec.attribute5,
      l_deliv_rec.attribute6,
      l_deliv_rec.attribute7,
      l_deliv_rec.attribute8,
      l_deliv_rec.attribute9,
      l_deliv_rec.attribute10,
      l_deliv_rec.attribute11,
      l_deliv_rec.attribute12,
      l_deliv_rec.attribute13,
      l_deliv_rec.attribute14,
      l_deliv_rec.attribute15,
      l_deliv_rec.chargeback_uom ,
      l_deliv_rec.deliverable_calendar,
      l_deliv_rec.start_period_name,
      l_deliv_rec.end_period_name,
      l_deliv_rec.country_id,
      l_deliv_Rec.setup_id,
      l_deliv_Rec.email_content_type
   );

   INSERT INTO ams_deliverables_all_tl(
      deliverable_id,
      language,
      last_update_date,
      last_updated_by,
      creation_date,
      created_by,
      last_update_login,
      source_lang,
      deliverable_name,
      description
   )
   SELECT
      l_deliv_rec.deliverable_id,
      l.language_code,
      SYSDATE,
      FND_GLOBAL.user_id,
      SYSDATE,
      FND_GLOBAL.user_id,
      FND_GLOBAL.conc_login_id,
      USERENV('LANG'),
      l_deliv_rec.deliverable_name,
      l_deliv_rec.description
   FROM fnd_languages l
   WHERE l.installed_flag in ('I', 'B')
   AND NOT EXISTS(
         SELECT NULL
         FROM ams_deliverables_all_tl t
         WHERE t.deliverable_id = l_deliv_rec.deliverable_id
         AND t.language = l.language_code );

   l_obj_type   := 'DELV';
   l_obj_id     := l_deliv_rec.deliverable_id;


/* commentend  by musman
   --since ams_object_attributes table will not be used anymore.
   -- insert into ams_object_attributes table
   -- for R2 deliverable screens cue card implementation
   -- add by khung@us 03/15/2000

   OPEN c_get_custom_setup_id;
   FETCH c_get_custom_setup_id INTO l_setup_id;
   CLOSE c_get_custom_setup_id;

   -- create object attributes
   IF (AMS_DEBUG_HIGH_ON) THEN
   AMS_Utility_PVT.debug_message('calling AMS_ObjectAttribute_PVT.create_object_attributes');
   END IF;

   AMS_ObjectAttribute_PVT.create_object_attributes(
      l_api_version,
      FND_API.g_false,  -- p_init_msg_list - use same message queue as the calling API
      FND_API.g_false,  -- p_commit - commiting will cause problem with rollback in the calling API
      p_validation_level,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_obj_type,
      l_obj_id,
      l_setup_id
   );

    IF l_return_status = FND_API.g_ret_sts_error THEN
        RAISE FND_API.g_exc_error;
    ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
        RAISE FND_API.g_exc_unexpected_error;
    END IF;
    */
      l_access_rec.act_access_to_object_id := l_obj_id;
      l_access_rec.arc_act_access_to_object := l_obj_type;
      l_access_rec.user_or_role_id := l_deliv_rec.owner_user_id;
      l_access_rec.arc_user_or_role_type := 'USER';
      l_access_rec.owner_flag := 'Y';

      /*
      --- hp bug fix
      IF (AMS_ACCESS_PVT.CHECK_ADMIN_ACCESS(l_deliv_rec.owner_user_id)) THEN
         l_access_rec.admin_flag := 'Y';
      ELSE
         l_access_rec.admin_flag := 'N';
      END IF;
     */
      l_access_rec.admin_flag := 'Y';  /* bug fix for Hp: */
      l_access_rec.delete_flag := 'N';
      AMS_Access_PVT.create_access (
         p_api_version        => 1.0,
         p_init_msg_list      => FND_API.G_FALSE,
         p_commit             => FND_API.G_FALSE,
         p_validation_level   => FND_API.G_VALID_LEVEL_FULL,
         x_return_status      => x_return_status,
         x_msg_count          => x_msg_count,
         x_msg_data           => x_msg_data,
         p_access_rec         => l_access_rec,
         x_access_id          => l_access_rec.activity_access_id
      );
      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;


   /*added by musman this to create jtf_Amv_item_item if it is a electronic deliverable */
   init_deliv_rec(x_deliv_rec_from_init);

   x_deliv_rec_from_init.deliverable_id := l_deliv_rec.deliverable_id;
   complete_deliv_rec(x_deliv_rec_from_init, x_deliv_rec);
   IF (x_deliv_Rec.can_fulfill_electronic_flag = 'Y')
   THEN
      IF (AMS_DEBUG_HIGH_ON) THEN
      AMS_Utility_PVT.debug_message('THE object version number is '||x_deliv_rec.object_version_number);
      END IF;
      x_deliv_Rec.object_version_number := 1;
      update_deliverable
        (p_api_version      => 1.0,
         p_commit           => p_commit,
         x_return_status    => l_return_status,
         x_msg_count        => l_msg_count,
         x_msg_data         => l_msg_data,
         p_deliv_rec        => x_deliv_rec
         );
    END IF;

    IF l_return_status <> FND_API.g_ret_sts_success THEN
       IF (AMS_DEBUG_HIGH_ON) THEN

       AMS_Utility_PVT.debug_message(l_full_name||': in the exception of call to update');
       END IF;
       x_msg_count := l_msg_count;
       x_msg_data := l_msg_data;
       RAISE FND_API.G_EXC_ERROR;
    END IF;


   -- attach seeded metrics
   IF (AMS_DEBUG_HIGH_ON) THEN
   AMS_Utility_PVT.debug_message('calling AMS_RefreshMetric_PVT.copy_seeded_metric');
   END IF;

   AMS_RefreshMetric_PVT.copy_seeded_metric(
      p_api_version             => 1.0,
      x_return_status           => l_return_status,
      x_msg_count               => x_msg_count,
      x_msg_data                => x_msg_data,
      p_arc_act_metric_used_by  =>'DELV',
      p_act_metric_used_by_id   => l_deliv_rec.deliverable_id,
      p_act_metric_used_by_type => NULL
   );

   IF l_return_status = FND_API.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
   ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;


   -- create task
   IF (AMS_DEBUG_HIGH_ON) THEN
   AMS_Utility_PVT.debug_message('calling AMS_TASK_PVT.Create_task');
   END IF;

   IF SYSDATE > l_deliv_rec.forecasted_complete_date THEN
      l_task_planned_start_date := l_deliv_rec.forecasted_complete_date;
   END IF;
   l_trim_task_name := 'Prep. task for - '||substr(l_deliv_rec.deliverable_name,1,62);

   l_source_object_name := substr(l_deliv_rec.deliverable_name,1,80);


   AMS_TASK_PVT.Create_task
   (
    p_api_version               =>  l_api_version,
    p_init_msg_list             =>  FND_API.g_false,  -- use the same message queue as the calling API
    p_commit                    =>  FND_API.g_false,  -- committing in the called api will cause problems with rollback in the calling API
    p_task_id                   =>  NULL,
    p_task_name                 =>  l_trim_task_name, -- 'Prep. task for - '||l_deliv_rec.deliverable_name,
    p_task_type_id              =>  15,
    p_task_status_id            =>  14,   -- in jtf_task_statuses_vl, 13 is Unassigned
    p_task_priority_id          =>  3,
    p_owner_id                  =>  l_deliv_rec.owner_user_id,
    p_owner_type_code           =>  'RS_EMPLOYEE',
    p_private_flag              =>  'N',
    p_planned_start_date        =>  l_task_planned_start_date,
    p_planned_end_date          =>  l_deliv_rec.forecasted_complete_date,
    p_actual_start_date         =>  NULL,
    p_actual_end_date           =>  l_deliv_rec.forecasted_complete_date,
    p_source_object_type_code   =>  'AMS_DELV',
    p_source_object_id          =>  l_deliv_rec.deliverable_id,
    p_source_object_name        =>  l_source_object_name ,--l_deliv_rec.deliverable_name,  -- because jtfObject seed data has changed. TO_CHAR(l_deliv_rec.deliverable_id),
    x_return_status             =>  l_return_status,
    x_msg_count                 =>  x_msg_count,
    x_msg_data                  =>  x_msg_data,
    x_task_id                   =>  x_task_id
 );

   IF (AMS_DEBUG_HIGH_ON) THEN
   AMS_UTILITY_PVT.debug_message('the return status from :'||l_return_status);
   END IF;

   IF l_return_status = FND_API.g_ret_sts_error THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
         FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

    RAISE FND_API.g_exc_error;

   ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error)
         THEN
         FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   -- create task assignment
   IF (AMS_DEBUG_HIGH_ON) THEN
   AMS_Utility_PVT.debug_message('calling AMS_TASK_PVT.Create_Task_Assignment');
   END IF;

   AMS_TASK_PVT.Create_Task_Assignment (
    p_api_version               =>  l_api_version,
    p_init_msg_list             =>  FND_API.g_false,
    p_commit                    =>  FND_API.g_false,
    p_task_id                   =>  x_task_id,
    p_resource_type_code        =>  'RS_EMPLOYEE',
    p_resource_id               =>  l_deliv_rec.owner_user_id,
    p_assignment_status_id      =>  1,
    x_return_status             =>  l_return_status,
    x_msg_count                 =>  x_msg_count,
    x_msg_data                  =>  x_msg_data,
    x_task_assignment_id        =>  x_task_assignment_id
   );

   IF l_return_status = FND_API.g_ret_sts_error THEN

      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error)
         THEN
         FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
      RAISE FND_API.g_exc_error;
   ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN

      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error)
         THEN
         FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   -------------------- code added by abhola ---------------------
   --------- ams_association pvt. create association ------------

   if (l_deliv_rec.associate_flag = 'Y') then
      if ( l_deliv_rec.deliverable_id IS NOT NULL ) then
         l_association_rec.master_object_id   := l_deliv_rec.master_object_id;
         l_association_rec.master_object_type := l_deliv_rec.master_object_type;
         l_association_rec.using_object_id    := l_deliv_rec.deliverable_id;
         l_association_rec.using_object_type  := 'DELV';
         l_association_rec.primary_flag       := 'Y';
         l_association_rec.usage_type :='USED_BY';

         AMS_Associations_PVT.create_association
            (   p_api_version               =>  l_api_version,
                p_init_msg_list             =>  FND_API.g_false,
                p_commit                    =>  FND_API.g_false,
                p_validation_level          =>  FND_API.G_VALID_LEVEL_FULL,
                x_return_status             =>  l_return_status,
                x_msg_count                 =>  x_msg_count,
                x_msg_data                  =>  x_msg_data,
                p_association_rec           =>  l_association_rec,
                x_object_association_id     =>  l_object_association_id
            );
         IF l_return_status = FND_API.g_ret_sts_error THEN
            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error)   THEN
               FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
            END IF;
            FND_MSG_PUB.count_and_get
            (
                    p_encoded => FND_API.g_false,
                    p_count   => x_msg_count,
                    p_data    => x_msg_data
            );
            RAISE FND_API.g_exc_error;
         ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error)   THEN
               FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
            END IF;
            FND_MSG_PUB.count_and_get
            (
                    p_encoded => FND_API.g_false,
                    p_count   => x_msg_count,
                    p_data    => x_msg_data
            );
            RAISE FND_API.g_exc_unexpected_error;
         END IF;
      end if;
   end if;
   ----------------- end code added by abhola  --------------------
   ------------------------- finish -------------------------------
   x_deliv_id := l_deliv_rec.deliverable_id;

   IF FND_API.to_boolean(p_commit) THEN
      COMMIT;
   END IF;

   FND_MSG_PUB.count_and_get(
         p_encoded => FND_API.g_false,
         p_count   => x_msg_count,
         p_data    => x_msg_data
   );

   IF (AMS_DEBUG_HIGH_ON) THEN
   AMS_Utility_PVT.debug_message(l_full_name ||': end');
   END IF;

EXCEPTION

   WHEN FND_API.g_exc_error THEN
      ROLLBACK TO create_deliverable;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO create_deliverable;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN OTHERS THEN
      ROLLBACK TO create_deliverable;
      x_return_status := FND_API.g_ret_sts_unexp_error ;

      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error)
         THEN
         FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

END create_deliverable;


--------------------------------------------------------------------
-- PROCEDURE
--    delete_deliverable (creative)
--
-- HISTORY
--    10/09/99  khung  Create.
--------------------------------------------------------------------

PROCEDURE delete_deliverable
(
  p_api_version     IN  NUMBER,
  p_init_msg_list   IN  VARCHAR2 := FND_API.g_false,
  p_commit          IN  VARCHAR2 := FND_API.g_false,

  x_return_status   OUT NOCOPY VARCHAR2,
  x_msg_count       OUT NOCOPY NUMBER,
  x_msg_data        OUT NOCOPY VARCHAR2,

  p_deliv_id        IN  NUMBER,
  p_object_version  IN  NUMBER
)
IS

  l_api_version     CONSTANT NUMBER       := 1.0;
  l_api_name        CONSTANT VARCHAR2(30) := 'delete_deliverable';
  l_full_name       CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

BEGIN

   --------------------- initialize -----------------------
   SAVEPOINT delete_deliverable;

   IF (AMS_DEBUG_HIGH_ON) THEN
   AMS_Utility_PVT.debug_message(l_full_name||': start');
   END IF;

   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   IF NOT FND_API.compatible_api_call(
         l_api_version,
         p_api_version,
         l_api_name,
         g_pkg_name
   ) THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   ------------------------ delete ------------------------
   IF (AMS_DEBUG_HIGH_ON) THEN
   AMS_Utility_PVT.debug_message(l_full_name ||': delete');
   END IF;

   DELETE FROM ams_deliverables_all_b
   WHERE deliverable_id = p_deliv_id
   AND object_version_number = p_object_version;

   IF (SQL%NOTFOUND) THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
         FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
   END IF;

   DELETE FROM ams_deliverables_all_tl
   WHERE deliverable_id = p_deliv_id;

   IF (SQL%NOTFOUND) THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
         FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
   END IF;

   -------------------- finish --------------------------
   IF FND_API.to_boolean(p_commit) THEN
      COMMIT;
   END IF;

   FND_MSG_PUB.count_and_get(
         p_encoded => FND_API.g_false,
         p_count   => x_msg_count,
         p_data    => x_msg_data
   );

   IF (AMS_DEBUG_HIGH_ON) THEN
   AMS_Utility_PVT.debug_message(l_full_name ||': end');
   END IF;

EXCEPTION

   WHEN FND_API.g_exc_error THEN
      ROLLBACK TO delete_deliverable;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO delete_deliverable;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN OTHERS THEN
      ROLLBACK TO delete_deliverable;
      x_return_status := FND_API.g_ret_sts_unexp_error ;

      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error)
      THEN
         FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );


END delete_deliverable;

-------------------------------------------------------------------
-- PROCEDURE
--    lock_deliverable
--
-- HISTORY
--    10/09/99  khung  Create.
--------------------------------------------------------------------

PROCEDURE lock_deliverable
(
   p_api_version    IN  NUMBER,
   p_init_msg_list  IN  VARCHAR2 := FND_API.g_false,

   x_return_status  OUT NOCOPY VARCHAR2,
   x_msg_count      OUT NOCOPY NUMBER,
   x_msg_data       OUT NOCOPY VARCHAR2,

   p_deliv_id       IN  NUMBER,
   p_object_version IN  NUMBER
)
IS

   l_api_version    CONSTANT NUMBER       := 1.0;
   l_api_name       CONSTANT VARCHAR2(30) := 'lock_deliverable';
   l_full_name      CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

   l_deliv_id       NUMBER;

   CURSOR c_deliv_b IS
   SELECT deliverable_id
     FROM ams_deliverables_all_b
    WHERE deliverable_id = p_deliv_id
      AND object_version_number = p_object_version
   FOR UPDATE OF deliverable_id NOWAIT;

   CURSOR c_deliv_tl IS
   SELECT deliverable_id
     FROM ams_deliverables_all_tl
    WHERE deliverable_id = p_deliv_id
      AND USERENV('LANG') IN (language, source_lang)
   FOR UPDATE OF deliverable_id NOWAIT;

BEGIN

   -------------------- initialize ------------------------
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message(l_full_name||': start');
   END IF;

   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   IF NOT FND_API.compatible_api_call(
         l_api_version,
         p_api_version,
         l_api_name,
         g_pkg_name
   ) THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   ------------------------ lock -------------------------
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message(l_full_name||': lock');
   END IF;

   OPEN c_deliv_b;
   FETCH c_deliv_b INTO l_deliv_id;
   IF (c_deliv_b%NOTFOUND) THEN
      CLOSE c_deliv_b;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
   END IF;
   CLOSE c_deliv_b;

   OPEN c_deliv_tl;
   CLOSE c_deliv_tl;

   -------------------- finish --------------------------
   FND_MSG_PUB.count_and_get(
         p_encoded => FND_API.g_false,
         p_count   => x_msg_count,
         p_data    => x_msg_data
   );

EXCEPTION

   WHEN AMS_Utility_PVT.resource_locked THEN
      x_return_status := FND_API.g_ret_sts_error;
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
           FND_MESSAGE.set_name('AMS', 'AMS_API_RESOURCE_LOCKED');
           FND_MSG_PUB.add;
        END IF;

      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN FND_API.g_exc_error THEN
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN FND_API.g_exc_unexpected_error THEN
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN OTHERS THEN
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error)
         THEN
         FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );


END lock_deliverable;


---------------------------------------------------------------------
-- PROCEDURE
--    update_deliverable (creative)
--
-- HISTORY
--    10/09/99  khung  Create.
-- 13-Sep-2000 choang   Changed call for workflow approval from ams_wfcmpapr_pvt
--                      to ams_approval_pvt.
----------------------------------------------------------------------

PROCEDURE update_deliverable
(
  p_api_version         IN  NUMBER,
  p_init_msg_list       IN  VARCHAR2 := FND_API.g_false,
  p_commit              IN  VARCHAR2 := FND_API.g_false,
  p_validation_level    IN  NUMBER   := FND_API.g_valid_level_full,

  x_return_status       OUT NOCOPY VARCHAR2,
  x_msg_count           OUT NOCOPY NUMBER,
  x_msg_data            OUT NOCOPY VARCHAR2,

  p_deliv_rec           IN  deliv_rec_type
)
IS

   l_api_version        CONSTANT NUMBER := 1.0;
   l_api_name           CONSTANT VARCHAR2(30) := 'update_deliverable';
   l_full_name          CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

   l_deliv_status_type         CONSTANT VARCHAR2(30) := 'AMS_DELIV_STATUS';
   l_reject_status_code      VARCHAR2(30) := 'DENIED_BA';

   l_deliv_rec      deliv_rec_type := p_deliv_rec;
   l_return_status      VARCHAR2(1);

   l_custom_setup_attr  VARCHAR2(10);
   l_approval_type      VARCHAR2(10);

   l_approval_for       VARCHAR2(10)    :=  'DELV';
   l_new_status_code    VARCHAR2(30);
   l_reject_status_id   NUMBER;


   l_pricelist_header_id NUMBER;
   l_modifier_list_rec  qp_modifiers_pub.modifier_list_rec_type;
   l_price_hdr_name     VARCHAR2(240);
   l_modifiers_tbl      qp_modifiers_pub.modifiers_tbl_type;

   -- Inventory
   l_ii_return_status   VARCHAR2(1);
   inv_creation_error   EXCEPTION;

   l_item_rec           INV_Item_GRP.Item_rec_type;
   x_item_rec           INV_Item_GRP.Item_rec_type;
   x_error_tbl          INV_Item_GRP.Error_tbl_type;

   -- add the following profile option for bug 1350422
   -- added by khung@us 07/11/2000
   l_inv_profile   VARCHAR2(1);
   l_qp_profile    VARCHAR2(1);

   -- JTF amv item
   jtf_inv_item_creation_error EXCEPTION;
   l_jtf_amv_item_rec   JTF_AMV_ITEM_PUB.item_rec_type;
   x_jtf_amv_item_id    NUMBER;
   l_jtf_delv_item_id   NUMBER;
   l_jtf_att_count      NUMBER;
   l_jtf_used_by        VARCHAR2(30);
   l_jtf_used_by_id     NUMBER;
   l_att_id             NUMBER;

   l_msg_count          NUMBER;
   l_msg_data           VARCHAR2(2000);

   l_notes_from_requester  VARCHAR2(2000);
   l_item_type          VARCHAR2(30) := 'AMSAPRV';
   l_workflowprocess    VARCHAR2(30) := 'AMS_APPROVAL';

   CURSOR c_new_status_code(status_id IN NUMBER) IS
   SELECT system_status_code
     FROM ams_user_statuses_vl
    WHERE user_status_id = status_id;

   CURSOR c_user_status_id (p_status_code IN VARCHAR2) IS
      SELECT user_status_id
      FROM   ams_user_statuses_vl
      WHERE  system_status_type = l_deliv_status_type
      AND    system_status_code = p_status_code
      AND    default_flag = 'Y';

   CURSOR c_orig_stat_rec(p_deliverable_id IN NUMBER) IS
   SELECT user_status_id, status_code
     FROM ams_deliverables_vl
    WHERE deliverable_id = p_deliverable_id;

   l_orig_stat_rec c_orig_stat_rec%ROWTYPE;
/*
  -- SQLID : 11753349 Fix by musman
  -- commented out cursor which are not being used
   CURSOR c_inv_item_id(p_inv_item_num IN VARCHAR2) IS
   SELECT distinct(inventory_item_id)
     FROM mtl_system_items_b_kfv
    WHERE segment1 = p_inv_item_num;

   CURSOR c_pricelist_header_id IS
   SELECT distinct(pricelist_header_id)
     FROM ams_deliverables_vl;
*/
   CURSOR c_jtf_item_id (p_deliv_id IN NUMBER) IS
   SELECT jtf_amv_item_id
     FROM ams_deliverables_vl
    WHERE deliverable_id = p_deliv_id;

   CURSOR c_jtf_att_count (p_deliv_id IN NUMBER) IS
   SELECT count(1)
     FROM jtf_amv_attachments_v
    WHERE attachment_used_by_id = p_deliv_id
      AND attachment_used_by = 'AMS_DELV';

   CURSOR c_jtf_file_rec (p_deliv_id IN NUMBER) IS
   SELECT file_id, file_name, attachment_type, version
     FROM jtf_amv_attachments_v
    WHERE attachment_used_by_id = p_deliv_id
      AND attachment_used_by = 'AMS_DELV'
      AND creation_date = (
          SELECT max(creation_date) FROM jtf_amv_attachments_v
           WHERE attachment_used_by_id = p_deliv_id
             AND attachment_used_by = 'AMS_DELV');

   l_jtf_file_rec c_jtf_file_rec%ROWTYPE;


CURSOR get_attachments_rec (p_deliv_id IN NUMBER, p_itm_id IN NUMBER) IS
   SELECT file_id, file_name, attachment_type, version
     FROM jtf_amv_attachments_v
    WHERE attachment_used_by_id = p_deliv_id
      AND attachment_used_by = 'AMS_DELV'
      AND file_id NOT IN
                ( select file_id
                    from jtf_amv_attachments_v
             where attachment_used_by_id = p_itm_id
                        and attachment_used_by = 'ITEM' );

   l_attachments_rec get_attachments_rec%ROWTYPE;


   CURSOR  c_get_ob_ver_num(delv_id IN NUMBER)  IS
         SELECT object_version_number
         from ams_deliverables_all_b where deliverable_id = delv_id;

   l_dummy NUMBER;
   l_pending_budget_stat VARCHAR2(50);
   l_pending_budget_stat_id NUMBER;
   l_new_budget_stat_id NUMBER;

   l_deliverable_calendar VARCHAR2(15);

    CURSOR get_owner_id(deliv_id IN NUMBER)
   IS
   SELECT owner_user_id
   FROM ams_deliverables_all_b
   WHERE deliverable_id = deliv_id;

   l_owner_user_id NUMBER;

   CURSOR check_budget(deliv_id IN NUMBER)
   IS
   SELECT DISTINCT 'Y'
   FROM ams_act_budgets
   WHERE arc_act_budget_used_by='DELV'
   AND act_budget_used_by_id = deliv_id;

   l_budget_lines_exist   VARCHAR2(1) := 'N';

   CURSOR get_detl(deliv_id IN NUMBER)
   IS
   SELECT kit_flag, inventory_flag,non_inv_quantity_on_hand
   FROM ams_deliverables_all_b
   WHERE deliverable_id = deliv_id;

   l_kit_flag VARCHAR2(1) ;
   l_inventory_flag VARCHAR2(1);
   l_quantity     NUMBER;

     --01/24/02  added for access check bug #2764852 mukumar start

   l_user_id  NUMBER;
   l_res_id   NUMBER;

   CURSOR get_res_id(l_user_id IN NUMBER) IS
   SELECT resource_id
   FROM ams_jtf_rs_emp_v
   WHERE user_id = l_user_id;
     --01/24/02  added for access check bug #2764852 mukumar end


BEGIN

   -------------------- initialize -------------------------
   SAVEPOINT update_deliverable;

   IF (AMS_DEBUG_HIGH_ON) THEN
   AMS_Utility_PVT.debug_message(l_full_name||': start');
   END IF;

   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   IF NOT FND_API.compatible_api_call(
         l_api_version,
         p_api_version,
         l_api_name,
         g_pkg_name
   ) THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   ----------------------- validate ----------------------
     --01/24/02  added for access check bug #2764852 mukumar start

   l_user_id := FND_GLOBAL.User_Id;

   IF (AMS_DEBUG_HIGH_ON) THEN
      AMS_Utility_PVT.debug_message(' CHECK ACCESS l_user_id is ' ||l_user_id );
   END IF;
   if l_user_id IS NOT NULL then
      open get_res_id(l_user_id);
      fetch get_res_id into l_res_id;
      close get_res_id;
   end if;
   if AMS_ACCESS_PVT.check_update_access(l_deliv_rec.deliverable_id, 'DELV', l_res_id, 'USER') = 'N' then
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('AMS', 'AMS_EVO_NO_UPDATE_ACCESS');-- reusing the message
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
   end if;
  --01/24/02  added for access check bug #2764852 mukumar end

   IF (AMS_DEBUG_HIGH_ON) THEN
     AMS_Utility_PVT.debug_message(l_full_name ||': validate');
     AMS_Utility_PVT.debug_message('l_deliv_rec.transaction_currency_code:'||l_deliv_rec.transaction_currency_code);
     AMS_Utility_PVT.debug_message('l_deliv_rec.currency_code:'||l_deliv_rec.currency_code);
   END IF;


   IF l_deliv_rec.transaction_currency_code = FND_API.G_MISS_CHAR
   OR l_deliv_rec.transaction_currency_code IS NULL
   THEN
      l_deliv_rec.transaction_currency_code := l_deliv_rec.currency_code;
   END IF;

   -- replace g_miss_char/num/date with current column values
   complete_deliv_rec(p_deliv_rec, l_deliv_rec);

   -- checking the values of periods and deliverable_calendar
   IF (AMS_DEBUG_HIGH_ON) THEN
   AMS_Utility_PVT.debug_message(l_full_name ||':checking the period name');
   END IF;


   IF ( (l_deliv_rec.start_period_name IS NOT NULL)
   OR   (l_deliv_rec.end_period_name IS NOT NULL)) THEN

         check_periods(
         p_deliv_rec              => l_deliv_rec
         ,x_deliverable_calendar  => l_deliverable_calendar
         ,x_return_status         => l_return_Status
         );

      IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      ELSIF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_success THEN
         l_deliv_Rec.deliverable_calendar := l_deliverable_calendar;
      END IF;
   ELSIF ((l_deliv_rec.start_period_name IS NULL)
   AND   (l_deliv_rec.end_period_name IS NULL)) THEN
      l_deliv_Rec.deliverable_calendar := null;

   END IF;


   IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
 -- calling the public apis validate_delieverable
   -- validate_deliverable
     ams_deliverable_pub.validate_deliverable
     (
        p_api_version_number    => l_api_version,
        p_init_msg_list      => FND_API.g_false,
        p_validation_level   => p_validation_level,
        p_validation_mode    => JTF_PLSQL_API.g_update,
        x_return_status      => l_return_status,
        x_msg_count          => x_msg_count,
        x_msg_data           => x_msg_data,
        p_deliv_rec          => l_deliv_rec
     );


   /*
      check_deliv_items(
         p_deliv_rec       => l_deliv_rec,
         p_validation_mode => JTF_PLSQL_API.g_update,
         x_return_status   => l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      ELSIF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      END IF;
   END IF;

   IF p_validation_level >= JTF_PLSQL_API.g_valid_level_record THEN

      IF (AMS_DEBUG_HIGH_ON) THEN
        AMS_Utility_PVT.debug_message('check_deliv_record');
      END IF;

      check_deliv_record(
         p_deliv_rec      => l_deliv_rec,
         p_complete_rec   => l_deliv_rec,
         x_return_status  => l_return_status
         );
	 */

      IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      ELSIF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      END IF;
   END IF;

   OPEN c_new_status_code(l_deliv_rec.user_status_id);
   FETCH c_new_status_code INTO l_new_status_code;
   CLOSE c_new_status_code;

   l_deliv_rec.status_code := l_new_status_code;

   OPEN c_orig_stat_rec(l_deliv_rec.deliverable_id);
   FETCH c_orig_stat_rec INTO l_orig_stat_rec;
   CLOSE c_orig_stat_rec;

-- for cancellation change  musman 10/04/00
   IF l_deliv_rec.status_code IN ('CANCELLED', 'ARCHIVED') THEN
      Deliverable_cancellation(l_deliv_rec, l_return_status);
      IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      ELSIF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      END IF;
    END IF;

-- Bug 1350422 modified by khung 07/11/2000
-- get values of profile options to call inv/qp profile options.
-- By default we will call the inv/qp api. We will not call the api
-- only if user explicitly set this profile option to 'N'

   l_inv_profile := FND_PROFILE.Value('AMS_INV_API_CALLOUT');--'Y';
   l_qp_profile := FND_PROFILE.Value('AMS_QP_PRICING_CALLOUT');--'Y';

-- changed the profile option defaults to 'N'
   IF l_inv_profile IS NULL THEN
      l_inv_profile := 'N';
   END IF;

   IF l_qp_profile IS NULL THEN
      l_qp_profile := 'N';
   END IF;


   IF (l_deliv_rec.replaced_by_deliverable_id IS NOT NULL) THEN
      l_deliv_rec.status_code := 'SUPERCEDED';
      OPEN c_user_status_id (l_deliv_rec.status_code);
      FETCH c_user_status_id INTO l_deliv_rec.user_status_id;
      CLOSE c_user_status_id;
   END IF;

   IF ((l_new_status_code = 'CANCELLED') OR
       (l_new_status_code = 'ARCHIVED') OR
       (l_new_status_Code = 'EXPIRED'))THEN
        l_deliv_rec.active_flag := 'N';
   END IF;

   OPEN get_detl(l_deliv_rec.deliverable_id);
   FETCH get_detl INTO l_kit_flag,l_inventory_flag, l_quantity;
   CLOSE get_detl;

   -- if user has wrongly entered data on quantity and selected inventory option
   IF (--l_inventory_flag = 'Y'    AND
   l_deliv_rec.non_inv_quantity_on_hand > 0
   AND l_deliv_rec.inventory_flag = 'Y')
   THEN
      l_deliv_rec.non_inv_quantity_on_hand :=  l_quantity;
   END IF;

   IF  l_inv_profile = 'Y'
   AND  l_deliv_rec.inventory_flag = 'Y'
   AND  l_deliv_rec.inventory_item_id IS NULL
   AND (l_kit_Flag = 'N'
       OR (l_kit_flag ='Y'  AND l_qp_profile ='Y'))
   THEN
      creat_inv_item (
         p_deliv_rec      =>   l_deliv_rec,
         x_inv_id         =>   l_deliv_rec.inventory_item_id,
         x_org_id         =>   l_deliv_rec.inventory_item_org_id,
         x_return_status  =>   x_return_status,
         x_msg_count      =>   x_msg_count,
         x_msg_data       =>   x_msg_data
         );

      IF x_return_status = FND_API.g_ret_sts_unexp_error THEN
        RAISE FND_API.g_exc_unexpected_error;
      ELSIF x_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      END IF;

   -- this is needed if the user passes the inv_id,org_id from the public api
   -- validating whether the inv item has reqd attributes set.
   ELSIF  l_inv_profile = 'Y'
   AND  l_deliv_rec.inventory_flag = 'Y'
   AND  l_inventory_flag ='N'    --old inventory flag
   AND  nvl(l_deliv_rec.inventory_item_id,-4) <> -4
   AND  nvl(l_deliv_rec.inventory_item_org_id,-4) <> -4
   AND (l_kit_Flag = 'N'
       OR (l_kit_flag ='Y'  AND l_qp_profile ='Y'))
   THEN

      check_inv_item(
         p_deliv_rec     =>  l_deliv_rec
        ,x_return_status =>  x_return_status);

      IF x_return_status = FND_API.g_ret_sts_unexp_error THEN
        RAISE FND_API.g_exc_unexpected_error;
      ELSIF x_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      END IF;

   END IF;
   -- End Inventory creation
         -- Begin Price List API call-out
         -- modify by khung 07/11/2000

   -- JTF Amv Item API call-out

   IF (l_deliv_rec.can_fulfill_electronic_flag = 'Y') THEN
      l_jtf_att_count := 0;

      OPEN c_jtf_att_count(l_deliv_rec.deliverable_id);
      FETCH c_jtf_att_count INTO l_jtf_att_count;
      CLOSE c_jtf_att_count;

      OPEN c_jtf_item_id(l_deliv_rec.deliverable_id);
      FETCH c_jtf_item_id INTO l_jtf_delv_item_id;
      CLOSE c_jtf_item_id;

      /***********************************************************************************
      -- commented by ABHOLA
      THIS line is commented as we want to create JTF_AMV item even if there are no attachments
      IF ((l_jtf_delv_item_id IS NULL) AND (l_jtf_att_count > 0) ) THEN
      **************************************************************************************/
      IF (l_jtf_delv_item_id IS NULL) THEN
         l_jtf_amv_item_rec.item_name :='DELV-'||substr(l_deliv_rec.deliverable_name,1,235);--l_deliv_rec.deliverable_name;
         l_jtf_amv_item_rec.application_id := 520;
         l_jtf_amv_item_rec.item_type := 'FILE_ITEM';
         l_jtf_amv_item_rec.content_type_id := 10;
         l_jtf_amv_item_rec.owner_id := FND_GLOBAL.user_id;

         JTF_AMV_ITEM_PUB.Create_Item
         (
            p_api_version   =>  1.0,
            p_init_msg_list =>  FND_API.g_true,
            p_commit        =>  FND_API.g_false,
            x_return_status =>  l_return_status,
            x_msg_count     =>  l_msg_count,
            x_msg_data      =>  l_msg_data,
            p_item_rec      =>  l_jtf_amv_item_rec,
            x_item_id       =>  x_jtf_amv_item_id
         );
         x_return_status := l_return_status;

         IF l_return_status <> FND_API.g_ret_sts_success THEN
            RAISE jtf_inv_item_creation_error;
         ELSE
            l_deliv_rec.jtf_amv_item_id := x_jtf_amv_item_id;
            l_jtf_delv_item_id := x_jtf_amv_item_id;
         END IF;
      END IF;

      -- abhola added ' AND (l_jtf_att_count > 0) '  in the IF clause
      -----------------------------------------------------------
      IF (AMS_DEBUG_HIGH_ON) THEN

      ams_utility_pvt.debug_message (' delv item id '||l_jtf_delv_item_id||' attacth '||l_jtf_att_count);
      END IF;

      IF ( (l_jtf_delv_item_id IS NOT NULL) AND (l_jtf_att_count > 0) )  THEN
         -- create jtf_amv_attachment for ITEM
         /*******************
         OPEN c_jtf_file_rec(l_deliv_rec.deliverable_id);
         FETCH c_jtf_file_rec INTO l_jtf_file_rec;
         CLOSE c_jtf_file_rec;
         *******************/
         OPEN get_attachments_rec(l_deliv_rec.deliverable_id,l_jtf_delv_item_id);
            LOOP
               FETCH get_attachments_rec INTO l_attachments_rec;
               EXIT WHEN get_attachments_rec%NOTFOUND;

               l_jtf_used_by := 'ITEM';
               l_jtf_used_by_id := l_deliv_rec.jtf_amv_item_id;

               create_jtf_attachment
               (
                  p_used_by         =>  l_jtf_used_by,
                  p_used_by_id      =>  l_jtf_used_by_id,
                  p_file_id         =>  l_attachments_rec.file_id,       -- l_jtf_file_rec.file_id,
                  p_file_name       =>  l_attachments_rec.file_name,     -- l_jtf_file_rec.file_name,
                  p_att_type        =>  l_jtf_file_rec.attachment_type,  -- l_jtf_file_rec.attachment_type,
                  p_file_ver        =>  l_jtf_file_rec.version,          -- l_jtf_file_rec.version,
                  x_return_status   =>  l_return_status,
                  x_msg_count       =>  l_msg_count,
                  x_msg_data        =>  l_msg_data,
                  x_att_id          =>  l_att_id
               );
            END LOOP ;
         CLOSE get_attachments_rec;
      END IF;
   END IF; -- end JTF Amv Item API call-out
   ------------------------------------------------------------------------
   -- This piece of code added by ABHOLA
   -- if status code is AVAILABLE and Budget Approval is REQ - BAPL attr present
   -- in custom setup then change status code to SUBMITTED_BA
   -- set these var to original values
   -- so that in case the belwo IF condiion does not meets
   -- the status should not be updated by wrong values
   --
   -- the status order rule has been changed i.e ,from NEW the status can go to
   -- BUDGET_APPR or  CANCELLED and not directly to AVAILABLE. so doing the following changes
   -- by musman 08/08/01
/*
--  by musman 07/29/02
--  since the call to approvals is done
--  in the api AMS_DeliverableRules_PVT.update_delv_status

-- l_pending_budget_stat_id := l_deliv_rec.user_status_id;
-- l_new_budget_stat_id    :=  l_deliv_rec.user_status_id;  -- to send in to approvalpvt
-- l_pending_budget_stat    := l_deliv_rec.status_code;

-- IF ((l_orig_stat_rec.status_code = 'NEW'
--   OR l_orig_stat_rec.status_code ='DENIED_BA')
-- AND (l_new_status_code = 'BUDGET_APPR')) THEN
--
--    l_reject_status_code   := 'DENIED_BA';
--    l_custom_setup_attr    := 'BAPL';
--    l_approval_type        := 'BUDGET';
--    l_pending_budget_stat  := 'SUBMITTED_BA';
--    l_workflowprocess      := 'AMS_APPROVAL';

-- ELSIF ((l_orig_stat_rec.status_code = 'BUDGET_APPR'
--        OR l_orig_stat_rec.status_code = 'DENIED_TA')
--  AND (l_new_status_code = 'AVAILABLE')) THEN
--
--    l_reject_status_code   := 'DENIED_TA';
--    l_custom_setup_attr    := 'CAPL';
--    l_approval_type        := 'CONCEPT';
--    l_pending_budget_stat  := 'SUBMITTED_TA';
--    l_workflowprocess      := 'AMS_CONCEPT_APPROVAL';
-- END If;


-- IF  (   (l_orig_stat_rec.status_code = 'NEW'
--       OR l_orig_stat_rec.status_code ='DENIED_BA')
--     AND (l_new_status_code = 'BUDGET_APPR'))
-- OR (    (l_orig_stat_rec.status_code = 'BUDGET_APPR'
--       OR l_orig_stat_rec.status_code ='DENIED_TA')
--     AND (l_new_status_code = 'AVAILABLE'))
-- THEN
--
--    OPEN c_user_status_id (l_reject_status_code);
      FETCH c_user_status_id INTO l_reject_status_id;
--    CLOSE c_user_status_id;
--
--    IF (AMS_DEBUG_HIGH_ON) THEN        AMS_UTILITY_PVT.debug_message(' the approval reqd flag gives : '||Approval_required_flag( l_deliv_rec.setup_id, l_custom_setup_attr));    END IF;
--    IF Approval_required_flag( l_deliv_rec.setup_id, l_custom_setup_attr) = FND_API.g_true
--    THEN
--       -- choang - 13-sep-2000
--       -- Change of approval process.
--       -- flip the status to pending budget approval
--        IF (AMS_DEBUG_HIGH_ON) THEN                ams_utility_pvt.debug_message (' Inside the if changing the status :'||l_dummy);        END IF;
--        -- l_pending_budget_stat := 'SUBMITTED_BA';
--
--       OPEN c_user_status_id (l_pending_budget_stat);
--       FETCH c_user_status_id INTO l_pending_budget_stat_id;
--       CLOSE c_user_status_id;

--       IF (AMS_DEBUG_HIGH_ON) THEN              ams_utility_pvt.debug_message (' l_pending_budget_stat_id :  '||l_pending_budget_stat_id);       END IF;
--    ELSIF Approval_required_flag( l_deliv_rec.setup_id, l_custom_setup_attr) = FND_API.g_false
--    THEN
--       l_pending_budget_stat_id :=l_deliv_rec.user_status_id;
--       l_pending_budget_stat :=   l_deliv_rec.status_code;
--    END IF;  -- if approval needed / BAPL exists

-- END IF;
   -----------------------------------------
   -- End of code added by ABHOLA
   -----------------------------------------

*/

   OPEN get_owner_id(l_deliv_rec.deliverable_id);
   FETCH get_owner_id INTO l_owner_user_id;
   CLOSE get_owner_id;
/*
-- IF l_deliv_rec.status_code = 'AVAILABLE'
-- AND l_deliv_rec.private_flag = 'Y'
-- THEN
--    l_deliv_rec.private_flag := 'N';
-- END IF;
*/

   IF (AMS_DEBUG_HIGH_ON) THEN
   ams_utility_pvt.debug_message (l_full_name || ' - status_code: ' || l_deliv_rec.status_code);
   END IF;

   UPDATE ams_deliverables_all_b
   SET last_update_date = SYSDATE,
      last_updated_by = FND_GLOBAL.user_id,
      last_update_login = FND_GLOBAL.conc_login_id,
      object_version_number = l_deliv_rec.object_version_number + 1,
      language_code = l_deliv_rec.language_code,
      version = l_deliv_rec.version,
      application_id = l_deliv_rec.application_id,
--    user_status_id = l_pending_budget_stat_id,
--    status_code = l_pending_budget_stat,
--    status_date = l_deliv_rec.status_date,
      active_flag = l_deliv_rec.active_flag,
      private_flag = l_deliv_rec.private_flag,
      owner_user_id = l_deliv_rec.owner_user_id,
      fund_source_id = l_deliv_rec.fund_source_id,
      fund_source_type = l_deliv_rec.fund_source_type,
      category_type_id = l_deliv_rec.category_type_id,
      category_sub_type_id = l_deliv_rec.category_sub_type_id,
      kit_flag = l_deliv_rec.kit_flag,
      can_fulfill_electronic_flag = l_deliv_rec.can_fulfill_electronic_flag,
      can_fulfill_physical_flag = l_deliv_rec.can_fulfill_physical_flag,
      jtf_amv_item_id = l_deliv_rec.jtf_amv_item_id,
      inventory_flag = l_deliv_rec.inventory_flag,
      transaction_currency_code = l_deliv_rec.transaction_currency_code, /* because defaulted to l_deliv_rec.currency_code if transaction currency is null*/
      functional_currency_code = l_deliv_rec.functional_currency_code,
      budget_amount_tc = l_deliv_rec.budget_amount_tc,
      budget_amount_fc = l_deliv_rec.budget_amount_fc,
      actual_avail_from_date = l_deliv_rec.actual_avail_from_date,
      actual_avail_to_date = l_deliv_rec.actual_avail_to_date,
      forecasted_complete_date = l_deliv_rec.forecasted_complete_date,
      actual_complete_date = l_deliv_rec.actual_complete_date,
      replaced_by_deliverable_id = l_deliv_rec.replaced_by_deliverable_id,
      inventory_item_id = l_deliv_rec.inventory_item_id,
      inventory_item_org_id = l_deliv_rec.inventory_item_org_id,
      pricelist_header_id = l_deliv_rec.pricelist_header_id,
      pricelist_line_id = l_deliv_rec.pricelist_line_id,
      non_inv_ctrl_code = l_deliv_rec.non_inv_ctrl_code,
      non_inv_quantity_on_hand = l_deliv_rec.non_inv_quantity_on_hand,
      non_inv_quantity_on_order = l_deliv_rec.non_inv_quantity_on_order,
      non_inv_quantity_on_reserve = l_deliv_rec.non_inv_quantity_on_reserve,
      chargeback_amount = l_deliv_rec.chargeback_amount,
      chargeback_amount_curr_code = l_deliv_rec.chargeback_amount_curr_code,
      deliverable_code = l_deliv_rec.deliverable_code,
      deliverable_pick_flag = l_deliv_rec.deliverable_pick_flag,
      currency_code = l_deliv_rec.currency_code,
      forecasted_cost = l_deliv_rec.forecasted_cost,
      actual_cost = l_deliv_rec.actual_cost,
      forecasted_responses = l_deliv_rec.forecasted_responses,
      actual_responses = l_deliv_rec.actual_responses,
      country = l_deliv_rec.country,
      attribute_category = l_deliv_rec.attribute_category,
      attribute1 = l_deliv_rec.attribute1,
      attribute2 = l_deliv_rec.attribute2,
      attribute3 = l_deliv_rec.attribute3,
      attribute4 = l_deliv_rec.attribute4,
      attribute5 = l_deliv_rec.attribute5,
      attribute6 = l_deliv_rec.attribute6,
      attribute7 = l_deliv_rec.attribute7,
      attribute8 = l_deliv_rec.attribute8,
      attribute9 = l_deliv_rec.attribute9,
      attribute10 = l_deliv_rec.attribute10,
      attribute11 = l_deliv_rec.attribute11,
      attribute12 = l_deliv_rec.attribute12,
      attribute13 = l_deliv_rec.attribute13,
      attribute14 = l_deliv_rec.attribute14,
      attribute15 = l_deliv_rec.attribute15,
      chargeback_uom = l_deliv_rec.chargeback_uom,
      deliverable_calendar = l_deliv_rec.deliverable_calendar,
      start_period_name = l_deliv_rec.start_period_name,
      end_period_name = l_deliv_rec.end_period_name,
      email_content_type = l_deliv_rec.email_content_type
   WHERE deliverable_id = l_deliv_rec.deliverable_id
   AND object_version_number = l_deliv_rec.object_version_number;
   IF (AMS_DEBUG_HIGH_ON) THEN

   ams_utility_pvt.debug_message ('values id '||l_deliv_rec.deliverable_id||' ver '||l_deliv_rec.object_version_number||l_pending_budget_stat_id||l_pending_budget_stat);
   END IF;


   IF (SQL%NOTFOUND) THEN
      IF (AMS_DEBUG_HIGH_ON) THEN

      ams_utility_pvt.debug_message (' SQL NOT FOUND ');
      END IF;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
   END IF;
   IF (AMS_DEBUG_HIGH_ON) THEN

   ams_utility_pvt.debug_message (l_full_name ||' end of update 1 ');
   END IF;
   UPDATE ams_deliverables_all_tl
   SET deliverable_name = l_deliv_rec.deliverable_name,
      description = l_deliv_rec.description,
      last_update_date = SYSDATE,
      last_updated_by = FND_GLOBAL.user_id,
      last_update_login = FND_GLOBAL.conc_login_id,
      source_lang = USERENV('LANG')
   WHERE deliverable_id = l_deliv_rec.deliverable_id
   AND USERENV('LANG') IN (language, source_lang);

   IF (SQL%NOTFOUND) THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
   END IF;

   IF (l_Deliv_rec.owner_user_id <> FND_API.g_miss_NUM
   AND l_owner_user_id <> l_deliv_Rec.owner_user_id )
   THEN
      AMS_Access_PVT.update_object_owner
      (   p_api_version        => 1.0
         ,p_init_msg_list      => FND_API.G_FALSE
         ,p_commit             => FND_API.G_FALSE
         ,p_validation_level   => p_validation_level
         ,x_return_status      => x_return_status
         ,x_msg_count          => x_msg_count
         ,x_msg_data           => x_msg_data
         ,p_object_type        => 'DELV'
         ,p_object_id          => l_deliv_Rec.deliverable_id
         ,p_resource_id        => l_deliv_rec.owner_user_id
         ,p_old_resource_id    => l_owner_user_id
         );
         IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
             RAISE FND_API.G_EXC_ERROR;
         END IF;
   END IF;

    -------------------------------------
   -- This piece of code added by ABHOLA
   -------------------------------------
/*
--  by musman 07/29/02
 --  since the call to approvals is done
 --  in the api AMS_DeliverableRules_PVT.update_delv_status
--   IF ((l_orig_stat_rec.status_code = 'NEW'
--   OR  l_orig_stat_rec.status_code = 'DENIED_BA')
--      AND (l_new_status_code = 'BUDGET_APPR'))
--   OR ((l_orig_stat_rec.status_code = 'BUDGET_APPR'
--     OR l_orig_stat_rec.status_code = 'DENIED_TA')
--      AND (l_new_status_code = 'AVAILABLE'))
--   THEN
--
--      OPEN c_user_status_id (l_reject_status_code);
--      FETCH c_user_status_id INTO l_reject_status_id;
--      CLOSE c_user_status_id;
--
--      ****************************************
--      -- by ABHOLA on Oct 31 2001
--      -- commented out this code to check budget lines
--      -- this code check will happen in WKFLOW api
--      --
--      -- musman checking whether budget lines exist.
--
--       OPEN check_budget(l_deliv_rec.deliverable_id);
--       FETCH check_budget INTO l_budget_lines_exist;
--       CLOSE check_budget;
--
--
--       IF Approval_required_flag( l_deliv_rec.setup_id, 'BAPL') = FND_API.g_true
--       AND l_budget_lines_exist = 'N' THEN
--
--           IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
--             FND_MESSAGE.set_name('AMS', 'AMS_EVE_NO_BGT_SRC');
--             FND_MSG_PUB.add;
--           END IF;
--           RAISE FND_API.g_exc_error;
--      END IF;
--     *****************************************
--
--      IF (AMS_DEBUG_HIGH_ON) THEN            AMS_UTILITY_PVT.debug_message('after update the approval reqd flag gives : '||Approval_required_flag( l_deliv_rec.setup_id, 'BAPL')||' and fnd_api.g_true :'|| FND_API.g_true);      END IF;
--      IF Approval_required_flag( l_deliv_rec.setup_id, l_custom_setup_attr) = FND_API.g_true
--      THEN
--
           -- choang - 13-sep-2000
--         -- Change of approval process.
--
--         OPEN c_get_ob_ver_num(l_deliv_rec.deliverable_id);
--            FETCH c_get_ob_ver_num INTO l_dummy;
--         CLOSE c_get_ob_ver_num;
--         IF (AMS_DEBUG_HIGH_ON) THEN                  ams_utility_pvt.debug_message (' OBJ VER NUM 2   '||l_dummy);         END IF;
--
--         AMS_Approval_PVT.StartProcess (
--            p_activity_type         => l_approval_for,
--            p_activity_id           => l_deliv_rec.deliverable_id,
--            p_approval_type         => l_approval_type,
--            p_object_version_number => l_dummy,
--            p_orig_stat_id          => l_orig_stat_rec.user_status_id,
--            p_new_stat_id           => l_new_budget_stat_id,        --- l_pending_budget_stat_id,
--            p_reject_stat_id        => l_reject_status_id,
--            p_requester_userid      => AMS_Utility_PVT.get_resource_id (FND_GLOBAL.user_id),
--            p_notes_from_requester  => l_notes_from_requester,
--            p_workflowprocess       => l_workflowprocess,
--            p_item_type             => l_item_type
--         );
--       IF (AMS_DEBUG_HIGH_ON) THEN              ams_utility_pvt.debug_message (' after the start process ');       END IF;
--    END IF;  -- if approval needed / l_custom_setup_attr (BAPL/CAPL) exists
-- END IF;
*/
   -----------------------------------------------------
   -- end of code added by ABHOLA
   -----------------------------------------------------
 AMS_DeliverableRules_PVT.update_delv_status
   (
      p_deliverable_id   => l_deliv_rec.deliverable_id
     ,p_user_status_id   => l_deliv_rec.user_status_id
   );

-- IF x_return_status <> FND_API.g_ret_sts_success
-- THEN
--    RAISE FND_API.g_exc_error;
-- END IF;

   IF (AMS_DEBUG_HIGH_ON) THEN



   ams_utility_pvt.debug_message (l_full_name ||' end of update 2 ');

   END IF;
   -------------------- finish --------------------------
   IF FND_API.to_boolean(p_commit) THEN
      COMMIT;
   END IF;

   FND_MSG_PUB.count_and_get(
         p_encoded => FND_API.g_false,
         p_count   => x_msg_count,
         p_data    => x_msg_data
   );

   IF (AMS_DEBUG_HIGH_ON) THEN



   AMS_Utility_PVT.debug_message(l_full_name ||': end');

   END IF;

EXCEPTION

   WHEN FND_API.g_exc_error THEN
      ROLLBACK TO update_deliverable;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO update_deliverable;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN inv_creation_error THEN
      /*-modify on 08/07/2000 khung
      --FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
--            p_count   => x_msg_count,
--            p_data    => x_msg_data
--      );*/
       ROLLBACK TO update_deliverable;
       FOR i IN 1 .. x_error_tbl.count LOOP
          FND_MSG_PUB.count_and_get(
                p_encoded => FND_API.g_false,
                p_count   => x_msg_count,
                p_data    => x_error_tbl(i).message_text
          );
          IF (AMS_DEBUG_HIGH_ON) THEN

          AMS_Utility_PVT.debug_message(l_full_name ||'the error text is '||x_error_tbl(i).message_text);
          END IF;
       END LOOP;

   WHEN jtf_inv_item_creation_error THEN
      ROLLBACK TO update_deliverable;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN OTHERS THEN
      ROLLBACK TO update_deliverable;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error)  THEN
        FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      FND_MSG_PUB.count_and_get(
         p_encoded => FND_API.g_false,
         p_count   => x_msg_count,
         p_data    => x_msg_data
      );
END update_deliverable;

---------------------------------------------------------------------
-- PROCEDURE
--    validate_deliverable
--
-- HISTORY
--    10/09/99  khung  Create.
----------------------------------------------------------------------

PROCEDURE validate_deliverable
(
   p_api_version        IN  NUMBER,
   p_init_msg_list      IN  VARCHAR2  := FND_API.g_false,
   p_validation_level   IN  NUMBER    := FND_API.g_valid_level_full,
   p_validation_mode    IN  VARCHAR2,
   x_return_status      OUT NOCOPY VARCHAR2,
   x_msg_count          OUT NOCOPY NUMBER,
   x_msg_data           OUT NOCOPY VARCHAR2,
   p_deliv_rec          IN  deliv_rec_type
)
IS

   l_api_version        CONSTANT NUMBER       := 1.0;
   l_api_name           CONSTANT VARCHAR2(30) := 'validate_deliverable';
   l_full_name          CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
   l_return_status      VARCHAR2(1);

BEGIN

  ----------------------- initialize --------------------
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message(l_full_name||': start');
   END IF;

   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   IF NOT FND_API.compatible_api_call(
         l_api_version,
         p_api_version,
         l_api_name,
         g_pkg_name
   ) THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   x_return_status := FND_API.g_ret_sts_success;

   ---------------------- validate ------------------------
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message(l_full_name||': check items');
   END IF;

   IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
      check_deliv_items(
         p_deliv_rec       => p_deliv_rec,
         p_validation_mode => p_validation_mode, --JTF_PLSQL_API.g_create,
         x_return_status   => l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      ELSIF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      END IF;
   END IF;

   IF (AMS_DEBUG_HIGH_ON) THEN
   AMS_Utility_PVT.debug_message(l_full_name||': check record');
   END IF;

   IF p_validation_level >= JTF_PLSQL_API.g_valid_level_record
   AND p_validation_mode = JTF_PLSQL_API.g_create
   THEN

      check_deliv_record(
         p_deliv_rec      => p_deliv_rec,
         p_complete_rec   => NULL,
         x_return_status  => l_return_status
      );
      IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      ELSIF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      END IF;

   ELSIF p_validation_level >= JTF_PLSQL_API.g_valid_level_record
   AND p_validation_mode = JTF_PLSQL_API.g_update
   THEN

      check_deliv_record(
         p_deliv_rec      => p_deliv_rec,
         p_complete_rec   => p_deliv_rec,
         x_return_status  => l_return_status
      );
      IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      ELSIF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      END IF;

   END IF;

   -------------------- finish --------------------------
   FND_MSG_PUB.count_and_get(
         p_encoded => FND_API.g_false,
         p_count   => x_msg_count,
         p_data    => x_msg_data
   );

   IF (AMS_DEBUG_HIGH_ON) THEN



   AMS_Utility_PVT.debug_message(l_full_name ||': end');

   END IF;

EXCEPTION

   WHEN FND_API.g_exc_error THEN
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN FND_API.g_exc_unexpected_error THEN
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN OTHERS THEN
      x_return_status := FND_API.g_ret_sts_unexp_error;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error)
      THEN
         FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );


END validate_deliverable;

---------------------------------------------------------------------
-- PROCEDURE
--    check_deliv_req_items
--
-- HISTORY
--    10/11/99  khung  Create.
---------------------------------------------------------------------
PROCEDURE check_deliv_req_items(
   p_deliv_rec      IN  deliv_rec_type,
   x_return_status  OUT NOCOPY VARCHAR2
)
IS
BEGIN

   x_return_status := FND_API.g_ret_sts_success;

   -------------------- put required items here ---------------------

   IF p_deliv_rec.language_code IS NULL THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
      THEN
         FND_MESSAGE.set_name('AMS', 'AMS_DELIV_NO_LANGUAGE_CODE');
         FND_MSG_PUB.add;
      END IF;

      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
   END IF;

   IF p_deliv_rec.deliverable_name IS NULL THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
      THEN
         FND_MESSAGE.set_name('AMS', 'AMS_DELIV_NO_DELIVERABLE_NAME');
         FND_MSG_PUB.add;
      END IF;

      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
   END IF;

   IF p_deliv_rec.actual_avail_from_date IS NULL THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
      THEN
         FND_MESSAGE.set_name('AMS', 'AMS_DELIV_NO_FROM_DATE');
         FND_MSG_PUB.add;
      END IF;

      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
   END IF;

   IF p_deliv_rec.actual_avail_to_date IS NULL THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
      THEN
         FND_MESSAGE.set_name('AMS', 'AMS_DELIV_NO_TO_DATE');
         FND_MSG_PUB.add;
      END IF;

      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
   END IF;

   IF p_deliv_rec.forecasted_complete_date IS NULL THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
      THEN
         FND_MESSAGE.set_name('AMS', 'AMS_DELIV_NO_FOREC_DATE');
         FND_MSG_PUB.add;
      END IF;

      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
   END IF;

   IF p_deliv_rec.owner_user_id IS NULL THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
      THEN
         FND_MESSAGE.set_name('AMS', 'AMS_EVT_REG_NO_OWNER_ID');
         FND_MSG_PUB.add;
      END IF;

      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
   END IF;

   IF p_deliv_rec.setup_id IS NULL THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
      THEN
         FND_MESSAGE.set_name('AMS', 'AMS_FUND_NO_CUSTOM_SETUP');
         FND_MSG_PUB.add;
      END IF;

      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
   END IF;

   IF p_deliv_rec.country_id IS NULL THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
      THEN
         FND_MESSAGE.set_name('AMS', 'AMS_DILG_BAD_CITY');
         FND_MSG_PUB.add;
      END IF;

      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
   END IF;

  IF p_deliv_rec.category_Type_id IS NULL THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
      THEN
         FND_MESSAGE.set_name('AMS', 'AMS_ACT_CAT_NO_CATEGORY_ID');
         FND_MSG_PUB.add;
      END IF;

      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
   END IF;

   IF p_deliv_rec.category_sub_Type_id IS NULL THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
      THEN
         FND_MESSAGE.set_name('AMS', 'AMS_SUB_CATEGORY_IS_MISSING');
         FND_MSG_PUB.add;
      END IF;

      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
   END IF;

   IF p_deliv_rec.version IS NULL THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
      THEN
         FND_MESSAGE.set_name('AMS', 'AMS_DELV_VERSION_MISSING');
         FND_MSG_PUB.add;
      END IF;

      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
   END IF;

   IF p_deliv_rec.transaction_currency_code IS NULL THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
      THEN
         FND_MESSAGE.set_name('AMS', 'AMS_CAMP_BUDGET_NO_CURRENCY');
         FND_MSG_PUB.add;
      END IF;

      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
   END IF;

END check_deliv_req_items;

---------------------------------------------------------------------
-- PROCEDURE
--    check_deliv_uk_items
--
-- HISTORY
--    10/11/99  khung  Create.
---------------------------------------------------------------------

PROCEDURE check_deliv_uk_items(
   p_deliv_rec          IN  deliv_rec_type,
   p_validation_mode    IN  VARCHAR2,
   x_return_status      OUT NOCOPY VARCHAR2
)
IS
   l_where_clause       VARCHAR2(2000);
   l_valid_flag         VARCHAR2(1);

   cursor c_check_uniq ( del_nm IN VARCHAR2, del_ver IN VARCHAR2 )
          IS
          SELECT 'N'
            FROM  ams_deliverables_vl
        WHERE  deliverable_name = del_nm
                AND  version = del_ver;


   cursor c_check_uniq_u ( del_nm IN VARCHAR2, del_ver IN VARCHAR2 , del_id IN NUMBER )
          IS
          SELECT 'N'
            FROM  ams_deliverables_vl
        WHERE  deliverable_name = del_nm
                AND  version = del_ver
          AND  deliverable_id <>  del_id;


         l_uniq_flag    VARCHAR2(1);
         l_uniq_flag_u  VARCHAR2(1);


BEGIN

   x_return_status := FND_API.g_ret_sts_success;

   -- For create_deliverable, when deliverable_id is passed in, we need to
   -- check if this deliverable_id is unique.
   IF p_validation_mode = JTF_PLSQL_API.g_create
      AND p_deliv_rec.deliverable_id IS NOT NULL
   THEN
      IF AMS_Utility_PVT.check_uniqueness(
            'ams_deliverables_vl',
            'deliverable_id = ' || p_deliv_rec.deliverable_id
            ) = FND_API.g_false
     THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
        THEN
            FND_MESSAGE.set_name('AMS', 'AMS_DELIV_DUPLICATE_ID');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

  IF (AMS_DEBUG_HIGH_ON) THEN
  AMS_Utility_PVT.debug_message(': start of check create '||p_deliv_rec.deliverable_name||' -'||p_deliv_rec.version);
  END IF;
   -- Check if deliverable_name/version is unique.
   IF p_validation_mode = JTF_PLSQL_API.g_create
   THEN
      l_uniq_flag := 'Y';
      OPEN  c_check_uniq(p_deliv_rec.deliverable_name, p_deliv_rec.version);
      FETCH c_check_uniq INTO l_uniq_flag;
      IF (AMS_DEBUG_HIGH_ON) THEN
         AMS_Utility_PVT.debug_message(' Flag '||l_uniq_flag);
      END IF;
      CLOSE c_check_uniq;

      IF (l_uniq_flag = 'N')
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
            THEN
            FND_MESSAGE.set_name('AMS', 'AMS_DELIV_DUP_NAME_VERSION');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

   IF (AMS_DEBUG_HIGH_ON) THEN
   AMS_Utility_PVT.debug_message(': start of check update ');
   END IF;

   -- check name and ver uniquiness  in update mode

   IF p_validation_mode = JTF_PLSQL_API.g_update
   THEN
      l_uniq_flag_u := 'Y';
      OPEN  c_check_uniq_u(p_deliv_rec.deliverable_name,p_deliv_rec.version,p_deliv_rec.deliverable_id);
      FETCH c_check_uniq_u INTO l_uniq_flag_u;
      CLOSE c_check_uniq_u;
      IF (AMS_DEBUG_HIGH_ON) THEN
         AMS_Utility_PVT.debug_message('val of l_uniq_flag_u'||l_uniq_flag_u);
      END IF;

      IF (l_uniq_flag_u = 'N')
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
            THEN
            FND_MESSAGE.set_name('AMS', 'AMS_DELIV_DUP_NAME_VERSION');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

   --IF p_validation_mode = JTF_PLSQL_API.g_create THEN
   --   l_valid_flag := AMS_Utility_PVT.check_uniqueness(
   --      'ams_deliverabless_vl',
   --      'deliverable_name = ''' || p_deliv_rec.deliverable_name ||
   --      '''AND version = ' || p_deliv_rec.version
   --IF p_validation_mode = JTF_PLSQL_API.g_create THEN
   --   l_valid_flag := AMS_Utility_PVT.check_uniqueness(
   --      'ams_deliverabless_vl',
   --      'deliverable_name = ''' || p_deliv_rec.deliverable_name ||
   --      '''AND version = ' || p_deliv_rec.version
   --   );
   --ELSE
   --   l_valid_flag := AMS_Utility_PVT.check_uniqueness(
   --      'ams_deliverables_vl',
   --      'deliverable_name = ''' || p_deliv_rec.deliverable_name ||
   --      ''' AND deliverable_id <> ' || p_deliv_rec.deliverable_id
   --   );
   --END IF;
   --IF l_valid_flag = FND_API.g_false THEN
   --   IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
   --   THEN
   --      FND_MESSAGE.set_name('AMS', 'AMS_DELIV_DUPLICATE_NAME');
   --      FND_MSG_PUB.add;
   --   END IF;
   --   x_return_status := FND_API.g_ret_sts_error;
   --   RETURN;
   --END IF;

   -- check other unique items

END check_deliv_uk_items;

---------------------------------------------------------------------
-- PROCEDURE
--    check_deliv_fk_items
--
-- HISTORY
--    10/11/99  khung  Create.
---------------------------------------------------------------------
PROCEDURE check_deliv_fk_items(
   p_deliv_rec      IN  deliv_rec_type,
   x_return_status  OUT NOCOPY VARCHAR2
)
IS
BEGIN

   x_return_status := FND_API.g_ret_sts_success;
   -- check other fk items

   --------------------- owner_user_id ------------------------
  IF p_deliv_rec.owner_user_id <> FND_API.g_miss_num
  THEN
      IF AMS_Utility_PVT.check_fk_exists(
--            'ams_jtf_rs_emp_v',
            'jtf_rs_resource_extns',
            'resource_id',
            p_deliv_rec.owner_user_id
         ) = FND_API.g_false
      THEN
         AMS_Utility_PVT.Error_Message('AMS_CAMP_BAD_OWNER_USER_ID');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

   --------------------- application_id ------------------------
   IF p_deliv_rec.application_id <> FND_API.g_miss_num
   THEN
      IF AMS_Utility_PVT.check_fk_exists(
            'fnd_application',
            'application_id',
            p_deliv_rec.application_id
         ) = FND_API.g_false
      THEN
         AMS_Utility_PVT.Error_Message('AMS_API_NO_APPLICATION_ID');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

   --------------------- category_type_id ------------------------
   IF p_deliv_rec.category_type_id <> FND_API.g_miss_num
   AND p_deliv_rec.category_type_id IS NOT NULL
   THEN
      IF AMS_Utility_PVT.check_fk_exists(
           'ams_categories_b',
           'category_id',
            p_deliv_rec.category_type_id
         ) = FND_API.g_false
      THEN
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
        THEN
           FND_MESSAGE.set_name('AMS', 'AMS_FUND_BAD_CATEGORY_ID');
           FND_MSG_PUB.add;
        END IF;
        x_return_status := FND_API.g_ret_sts_error;
        RETURN;
      END IF;
   END IF;

   --------------------- category_sub_type_id ------------------------
   IF p_deliv_rec.category_sub_type_id <> FND_API.g_miss_num
   AND p_deliv_rec.category_sub_type_id IS NOT NULL
   THEN
      IF AMS_Utility_PVT.check_fk_exists(
           'ams_categories_b',
           'category_id',
            p_deliv_rec.category_sub_type_id
         ) = FND_API.g_false
      THEN
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
        THEN
           FND_MESSAGE.set_name('AMS', 'AMS_SUB_CATEGORY_IS_MISSING');
           FND_MSG_PUB.add;
        END IF;
        x_return_status := FND_API.g_ret_sts_error;
        RETURN;
      END IF;
   END IF;

   --------------------- custom_setup_id ----------------------------
   IF p_deliv_rec.setup_id <> FND_API.g_miss_num
   AND p_deliv_rec.setup_id IS NOT NULL
   THEN
      IF AMS_Utility_PVT.check_fk_exists(
           'ams_custom_setups_b',
           'custom_setup_id',
            p_deliv_rec.setup_id
         ) = FND_API.g_false
      THEN
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
        THEN
           FND_MESSAGE.set_name('AMS', 'AMS_CAMP_BAD_CUSTOM_SETUP');
           FND_MSG_PUB.add;
        END IF;
        x_return_status := FND_API.g_ret_sts_error;
        RETURN;
      END IF;

   END IF;

   --------------------- country_id ----------------------------
   IF p_deliv_rec.country_id <> FND_API.g_miss_num
   AND p_deliv_rec.country_id IS NOT NULL
   THEN
      IF AMS_Utility_PVT.check_fk_exists(
            'jtf_loc_hierarchies_b',
            'location_hierarchy_id',
            p_deliv_rec.country_id,
            AMS_Utility_PVT.g_number,
            NULL
         ) = FND_API.g_false
      THEN
         AMS_Utility_PVT.Error_Message('AMS_CSCH_BAD_COUNTRY');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

   --------------------- Currency_code  ----------------------------
   IF p_deliv_rec.currency_code <> FND_API.g_miss_char
   AND p_deliv_rec.currency_code IS NOT NULL
   THEN
      IF AMS_Utility_PVT.check_fk_exists(
            'fnd_currencies',
            'currency_code',
            p_deliv_rec.currency_code,
            AMS_Utility_PVT.g_varchar2,
            NULL
         ) = FND_API.g_false
      THEN
         AMS_Utility_PVT.Error_Message('AMS_TRIG_INVALID_CURR');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

   ---------------------Transaction_Currency_code  ----------------------------
   IF p_deliv_rec.transaction_currency_code <> FND_API.g_miss_char
   AND p_deliv_rec.transaction_currency_code IS NOT NULL
   THEN
      IF AMS_Utility_PVT.check_fk_exists(
            'fnd_currencies',
            'currency_code',
            p_deliv_rec.transaction_currency_code,
            AMS_Utility_PVT.g_varchar2,
            NULL
         ) = FND_API.g_false
      THEN
         AMS_Utility_PVT.Error_Message('AMS_TRIG_INVALID_CURR');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

   --------------------- Language  ----------------------------
   IF p_deliv_rec.language_code <> FND_API.g_miss_char
   AND p_deliv_rec.language_code IS NOT NULL
   THEN
      IF AMS_Utility_PVT.check_fk_exists(
            'fnd_languages',
            'language_code',
            p_deliv_rec.language_code,
            AMS_Utility_PVT.g_varchar2,
            NULL
         ) = FND_API.g_false
      THEN
         AMS_Utility_PVT.Error_Message('AMS_CAMP_BAD_LANG');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

END check_deliv_fk_items;

---------------------------------------------------------------------
-- PROCEDURE
--    check_deliv_lookup_items
--
-- HISTORY
--    10/11/99  khung  Create.
---------------------------------------------------------------------
PROCEDURE check_deliv_lookup_items(
   p_deliv_rec      IN  deliv_rec_type,
   x_return_status  OUT NOCOPY VARCHAR2
)
IS
BEGIN

   x_return_status := FND_API.g_ret_sts_success;

   ----------------------- status_code ------------------------
   IF p_deliv_rec.status_code <> FND_API.g_miss_char THEN
      IF AMS_Utility_PVT.check_lookup_exists(
            p_lookup_type => 'AMS_DELIV_STATUS',
            p_lookup_code => p_deliv_rec.status_code
         ) = FND_API.g_false
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('AMS', 'AMS_DELIV_BAD_STATUS_CODE');
            FND_MSG_PUB.add;
         END IF;

         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

   -- check other lookup codes

END check_deliv_lookup_items;


---------------------------------------------------------------------
-- PROCEDURE
--    check_deliv_flag_items
--
-- HISTORY
--    10/11/99  khung  Create.
---------------------------------------------------------------------
PROCEDURE check_deliv_flag_items(
   p_deliv_rec      IN  deliv_rec_type,
   p_validation_mode IN VARCHAR2,
   x_return_status  OUT NOCOPY VARCHAR2
)
IS

CURSOR get_flags(delivId IN NUMBER)
IS
SELECT can_fulfill_electronic_flag
      ,can_fulfill_physical_flag
      ,inventory_flag
      ,non_inv_quantity_on_hand
      ,kit_flag
      ,status_code
FROM ams_deliverables_all_b
WHERE deliverable_id = delivId;


l_api_name VARCHAR2(30) := 'check_deliv_flag_items';
l_old_electronic_flag VARCHAR2(1);
l_old_inventory_flag VARCHAR2(1);
l_old_physical_flag VARCHAR2(1);
l_quantity_on_hand NUMBER;
l_old_kit_flag   VARCHAR2(1);
l_status_code    VARCHAR2(30);


l_check_deliv_has_kit VARCHAR2(1) := 'N';

-- Check if this deliverable is a kit
  CURSOR is_deliv_kit(l_deliverable_id IN NUMBER )
  IS select  count(*)
       from  ams_deliv_kit_items
      where  deliverable_kit_id = l_deliverable_id;

  -- Check if this deliverable is part of a kit
   CURSOR is_deliv_kit_part(l_deliverable_id IN NUMBER )
    IS select  count(*)
         from  ams_deliv_kit_items
        where  deliverable_kit_part_id = l_deliverable_id;

  l_kits_check NUMBER;
  l_qp_profile         varchar2(1) := FND_PROFILE.Value('AMS_QP_PRICING_CALLOUT');

BEGIN

   IF l_qp_profile IS NULL THEN
      l_qp_profile := 'N';
   END IF;

   x_return_status := FND_API.g_ret_sts_success;

   -- validation added for the public apis

   IF  p_validation_mode = JTF_PLSQL_API.g_create
   THEN
      IF NVL(p_deliv_rec.inventory_flag,'N') = 'Y'
      THEN
         AMS_UTILITY_PVT.error_message('AMS_DELV_NO_INV_CRE');
         --- Inventory option can be enabled only after the deliverable is created.
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

   IF NVL(p_deliv_rec.can_fulfill_electronic_flag,'N') = NVL(p_deliv_rec.can_fulfill_physical_flag,'N')
   THEN
      AMS_UTILITY_PVT.error_message('AMS_DELV_PHY_OR_ELEC');
      --Please select this deliverable as physical or electronic.
      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
   END IF;

   IF NVL(p_deliv_rec.can_fulfill_electronic_flag ,'N') ='Y'
   AND p_deliv_rec.non_inv_quantity_on_hand > 0
   THEN
      AMS_UTILITY_PVT.error_message('AMS_DELV_NO_QUAN_ELEC');
      --- Quantity cannot be tracked for electronic deliverable. Please change your options
      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
   END IF;
  -- validation added for the public api -- end
   ----------------------- rollup_flag ------------------------
   IF p_deliv_rec.kit_flag <> FND_API.g_miss_char
      AND p_deliv_rec.kit_flag IS NOT NULL
   THEN
      IF AMS_Utility_PVT.is_Y_or_N(p_deliv_rec.kit_flag) = FND_API.g_false
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('AMS', 'AMS_DELIV_BAD_KIT_FLAG');
            FND_MSG_PUB.add;
         END IF;

         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

   ------------ Electronic,Physical and Inventory Flag -----------------------
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_UTILITY_PVT.debug_message(l_api_name||' : going to check the FLAGS');
   END IF;

   OPEN get_flags(p_deliv_rec.deliverable_id);
   FETCH get_flags INTO l_old_electronic_flag
                        ,l_old_physical_flag
                        ,l_old_inventory_flag
                        ,l_quantity_on_hand
                        ,l_old_kit_flag
                        ,l_status_code;
   CLOSE get_flags;




   -- When a deliv status is available,flags which identifies the charateristic of deliv cannot be updated.
   -- 01/29/03  added extra conditon to check the status (CANCELLED,ARCHIVED,EXPIRED)  disallow user to chnage the delivery method flag  check bug #2764840 mukumar start
   IF ( (l_status_code = 'AVAILABLE' OR l_status_code = 'CANCELLED' OR l_status_code = 'ARCHIVED' OR l_status_code = 'EXPIRED')
   AND( (l_old_electronic_flag = 'Y' AND p_deliv_rec.can_fulfill_electronic_flag = 'N')
       OR (l_old_physical_flag = 'Y' AND p_deliv_rec.can_fulfill_physical_flag = 'N')
       OR (l_old_inventory_flag = 'Y' AND p_deliv_rec.inventory_flag = 'N')
       OR (l_old_inventory_flag = 'N' AND p_deliv_rec.inventory_flag = 'Y')
       OR (l_old_kit_flag = 'Y' AND p_deliv_rec.kit_flag = 'N')
       OR (l_old_kit_flag = 'N' AND p_deliv_rec.kit_flag = 'Y'))
      )
   THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
      THEN
         FND_MESSAGE.set_name('AMS', 'AMS_DELV_NO_UPD_AVAL_STATUS');
         FND_MSG_PUB.add;
      END IF;
      x_return_status :=  FND_API.g_ret_sts_error;
      RETURN;
   END IF;

   IF (l_old_electronic_flag='N'
   AND p_deliv_rec.can_fulfill_electronic_flag = 'Y'
   AND l_old_inventory_flag ='Y' )THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
      THEN
         FND_MESSAGE.set_name('AMS', 'AMS_DELIV_CANT_CHANGE_EFLAG');
         FND_MSG_PUB.add;
      END IF;
      x_return_status :=  FND_API.g_ret_sts_error;
      RETURN;
   END IF;


   -- if an inv item is attached ,cannot make electronic to physical
   IF (l_old_physical_flag='N'
   AND p_deliv_rec.can_fulfill_physical_flag = 'Y'
   AND l_old_inventory_flag ='Y' )THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
      THEN
         FND_MESSAGE.set_name('AMS', 'AMS_DELIV_CANT_CHANGE_PFLAG');
         FND_MSG_PUB.add;
      END IF;
      x_return_status :=  FND_API.g_ret_sts_error;
      RETURN;
   -- if an inv item is attached ,cannot change phy-inventoried to stock manually
   -- except if kit_flag is 'Y' and pricing profile is 'N'
   ELSIF (l_old_inventory_flag ='Y'
   AND p_deliv_rec.inventory_flag='N'
   AND p_deliv_rec.can_fulfill_physical_flag = 'Y'
   AND (p_deliv_rec.kit_flag ='N' OR (p_deliv_rec.kit_flag='Y' and l_qp_profile='Y')))
   THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
      THEN
         FND_MESSAGE.set_name('AMS', 'AMS_DELIV_CANT_CHANGE_PFLAG');
         FND_MSG_PUB.add;
      END IF;
      x_return_status :=  FND_API.g_ret_sts_error;
      RETURN;
   END IF;

   IF (AMS_DEBUG_HIGH_ON) THEN
     AMS_UTILITY_PVT.debug_message(l_api_name||' :checking the electronic flag cross checking  the quantity on hand of physical');
   END IF;

   IF (l_old_electronic_flag='N'
   AND p_deliv_rec.can_fulfill_electronic_flag = 'Y'
   AND l_quantity_on_hand >0 )THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
      THEN
         FND_MESSAGE.set_name('AMS', 'AMS_DELIV_CANT_CHANGE_EFLAG');
         FND_MSG_PUB.add;
      END IF;
      x_return_status :=  FND_API.g_ret_sts_error;
      RETURN;
   END IF;

   IF (AMS_DEBUG_HIGH_ON) THEN
      AMS_UTILITY_PVT.debug_message(l_api_name||':cross checking  the quantity on hand of physical and inventory');
   END IF;
   IF (l_old_inventory_flag='N'
   AND p_deliv_rec.inventory_flag = 'Y'
   AND l_quantity_on_hand >0 )THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
      THEN
         FND_MESSAGE.set_name('AMS', 'AMS_DELIV_CANT_CHANGE_IFLAG');
         FND_MSG_PUB.add;
      END IF;
      x_return_status :=  FND_API.g_ret_sts_error;
      RETURN;
   END IF;

   --- before updating the physical and electronic flag checking whether it has kit parts

   IF (AMS_DEBUG_HIGH_ON) THEN
      AMS_UTILITY_PVT.debug_message(l_api_name||':cross checking  whether it has kit parts');
   END IF;

   OPEN   is_deliv_kit(p_deliv_rec.deliverable_id);
   FETCH  is_deliv_kit INTO  l_kits_check;
   CLOSE  is_deliv_kit;

   IF (l_old_electronic_flag='Y'
   AND  p_deliv_rec.can_fulfill_electronic_flag = 'N'
   AND l_kits_check > 0)
   THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
      THEN
         FND_MESSAGE.set_name('AMS', 'AMS_DELIV_CANT_CHANGE_PFLAG');
         FND_MSG_PUB.add;
      END IF;
      x_return_status :=  FND_API.g_ret_sts_error;
      RETURN;
   END IF;

   IF (l_old_physical_flag='Y'
   AND  p_deliv_rec.can_fulfill_electronic_flag = 'Y'
   AND l_kits_check > 0)
   THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
      THEN
         FND_MESSAGE.set_name('AMS', 'AMS_DELIV_CANT_CHANGE_EFLAG');
         FND_MSG_PUB.add;
      END IF;
      x_return_status :=  FND_API.g_ret_sts_error;
      RETURN;
   END IF;

   IF ( p_deliv_rec.can_fulfill_physical_flag = 'Y'
   AND l_old_inventory_flag ='N'
   AND  p_deliv_rec.inventory_flag = 'Y'
   AND l_kits_check > 0)
   THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
      THEN
         FND_MESSAGE.set_name('AMS', 'AMS_DELIV_CANT_CHANGE_IFLAG');
         FND_MSG_PUB.add;
      END IF;
      x_return_status :=  FND_API.g_ret_sts_error;
      RETURN;
   END IF;

   -- cannot change the stock manually deliv to physically inventoried if it as phys- inv kit.
   IF ( p_deliv_rec.can_fulfill_physical_flag = 'Y'
   AND l_old_inventory_flag ='Y'
   AND  p_deliv_rec.inventory_flag = 'N'
   AND l_kits_check > 0)
   THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
      THEN
         FND_MESSAGE.set_name('AMS', 'AMS_DELIV_CANT_CHANGE_PFLAG');
         FND_MSG_PUB.add;
      END IF;
      x_return_status :=  FND_API.g_ret_sts_error;
      RETURN;
/*
   ELSIF ( p_deliv_rec.can_fulfill_physical_flag = 'Y'
   AND l_old_inventory_flag ='Y'
   AND  p_deliv_rec.inventory_flag = 'N'
   AND l_kits_check > 0
   AND p_deliv_rec.non_inv_quantity_on_hand >0)
   THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
      THEN
         FND_MESSAGE.set_name('AMS', 'AMS_DELIV_CANT_CHANGE_PFLAG');
         FND_MSG_PUB.add;
      END IF;
      x_return_status :=  FND_API.g_ret_sts_error;
      RETURN;
      */
   END IF;

   -- added by abhola
   -- Check whether the deliverable is a part of a kit or is itself a kit.
   --if DELIV is part of KIT the KIT FLAG cannot be updated to Y
   --IF DELIV is a KIT, the KIT FLAG cannot be updated to N

   -- If the deliv is a kit, cannot upd kit flag to 'N'
   if ((l_kits_check > 0) AND (p_deliv_rec.kit_flag = 'N')) then
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
      THEN
         FND_MESSAGE.set_name('AMS', 'AMS_CANNOT_UPD_KIT_TO_N');
         FND_MSG_PUB.add;
      END IF;
      x_return_status :=  FND_API.g_ret_sts_error;
      RETURN;
   end if;

   l_kits_check := 0;
   -- If the deliv is a part of a  kit, cannot upd kit flag to 'Y'
   OPEN   is_deliv_kit_part(p_deliv_rec.deliverable_id);
   FETCH  is_deliv_kit_part INTO  l_kits_check;
   CLOSE  is_deliv_kit_part;

   if ((l_kits_check > 0) AND (p_deliv_rec.kit_flag = 'Y')) then
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
      THEN
         FND_MESSAGE.set_name('AMS', 'AMS_CANNOT_UPD_KIT_TO_Y');
         FND_MSG_PUB.add;
      END IF;
     x_return_status := FND_API.g_ret_sts_error;
     RETURN;
   end if;
   -- end by abhola

   --Kit options cannot be updated if the inventory flag is 'Y'
   IF ((l_old_kit_flag = 'N'
   AND p_deliv_rec.kit_flag = 'Y'
   AND l_old_inventory_flag = 'Y')
   OR (l_old_kit_flag = 'Y'
   AND p_deliv_rec.kit_flag ='N'
   AND l_old_inventory_flag ='Y'))
   THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
      THEN
         FND_MESSAGE.set_name('AMS', 'AMS_DELIV_CANT_UPD_KIT');
         FND_MSG_PUB.add;
      END IF;
      x_return_status :=  FND_API.g_ret_sts_error;
      RETURN;
   END IF;

   -- check whether the deliv is a part of a kit before updating the electronic,physical,inventory flags
   IF (l_old_electronic_flag='Y'
   AND  p_deliv_rec.can_fulfill_electronic_flag = 'N'
   AND l_kits_check > 0)
   THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
      THEN
         FND_MESSAGE.set_name('AMS', 'AMS_DELIV_CANT_CHANGE_PFLAG');
         FND_MSG_PUB.add;
      END IF;
      x_return_status :=  FND_API.g_ret_sts_error;
      RETURN;
   END IF;

   IF (l_old_physical_flag='Y'
   AND  p_deliv_rec.can_fulfill_electronic_flag = 'Y'
   AND l_kits_check > 0)  --l_check_deliv_has_kit = 'Y')
   THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
      THEN
         FND_MESSAGE.set_name('AMS', 'AMS_DELIV_CANT_CHANGE_EFLAG');
         FND_MSG_PUB.add;
      END IF;
      x_return_status :=  FND_API.g_ret_sts_error;
      RETURN;
   END IF;

   IF ( p_deliv_rec.can_fulfill_physical_flag = 'Y'
   AND l_old_inventory_flag ='N'
   AND  p_deliv_rec.inventory_flag = 'Y'
   AND l_kits_check > 0)
   THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
      THEN
         FND_MESSAGE.set_name('AMS', 'AMS_DELIV_CANT_CHANGE_IFLAG');
         FND_MSG_PUB.add;
      END IF;
      x_return_status :=  FND_API.g_ret_sts_error;
      RETURN;
   END IF;

   -- cannot change the stock manually deliv to physically inventoried if it is part of phys- inv kit.
   IF ( p_deliv_rec.can_fulfill_physical_flag = 'Y'
   AND l_old_inventory_flag ='Y'
   AND  p_deliv_rec.inventory_flag = 'N'
   AND l_kits_check > 0)
   THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
      THEN
         FND_MESSAGE.set_name('AMS', 'AMS_DELIV_CANT_CHANGE_PFLAG');
         FND_MSG_PUB.add;
      END IF;
      x_return_status :=  FND_API.g_ret_sts_error;
      RETURN;
   END IF;



END check_deliv_flag_items;


---------------------------------------------------------------------
-- PROCEDURE
--    check_deliv_items
--
-- HISTORY
--    10/11/99  khung  Create.
---------------------------------------------------------------------
PROCEDURE check_deliv_items
(
   p_deliv_rec          IN  deliv_rec_type,
   p_validation_mode    IN  VARCHAR2 := JTF_PLSQL_API.g_create,
   x_return_status      OUT NOCOPY VARCHAR2
)
IS
   l_dummy     NUMBER;

   CURSOR c_period (l_name IN VARCHAR2) IS
      SELECT 1
      FROM   dual
      WHERE EXISTS (
                     SELECT 1
                     FROM   gl_periods_v
                     WHERE  period_set_name = p_deliv_rec.deliverable_calendar
                     AND    period_name = l_name)
      ;
BEGIN

/* 01/29/03  commented out to allow user to chnage th status  check bug #2764840 mukumar start

   check_inactive_deliv
   (  p_deliv_rec      => p_deliv_rec,
      x_return_status  => x_return_status
   );

   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;
01/29/03  commented out to allow user to chnage th status  check bug #2764840 mukumar end */


   check_deliv_req_items
   (
      p_deliv_rec      => p_deliv_rec,
      x_return_status  => x_return_status
   );

   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   check_deliv_uk_items
   (
      p_deliv_rec       => p_deliv_rec,
      p_validation_mode => p_validation_mode,
      x_return_status   => x_return_status
   );

   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   check_deliv_fk_items
   (
      p_deliv_rec      => p_deliv_rec,
      x_return_status  => x_return_status
   );

   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   check_deliv_lookup_items
   (
      p_deliv_rec       => p_deliv_rec,
      x_return_status   => x_return_status
   );

   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   check_deliv_flag_items
   (
      p_deliv_rec       => p_deliv_rec,
      p_validation_mode => p_validation_mode,
      x_return_status   => x_return_status
   );

   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   check_owner_id
   (
      p_deliv_rec       => p_deliv_Rec,
      x_return_status   => x_return_status
   );

   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   IF (AMS_DEBUG_HIGH_ON) THEN
   AMS_Utility_PVT.debug_message('Checking the budget lines :');
   END IF;

   check_budget_lines
   (
     p_deliv_rec      => p_deliv_rec,
     x_return_status  => x_Return_status
   );

   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   IF (AMS_DEBUG_HIGH_ON) THEN
   AMS_Utility_PVT.debug_message('Start Period Name:'|| p_deliv_rec.start_period_name );
   AMS_Utility_PVT.debug_message('End Period Name:'|| p_deliv_rec.end_period_name );
   AMS_Utility_PVT.debug_message('Deliverable Calendar:'|| p_deliv_rec.deliverable_calendar );
   END IF;

   IF p_deliv_rec.start_period_name IS NOT NULL THEN
      OPEN c_period (p_deliv_rec.start_period_name);
      FETCH c_period INTO l_dummy;
      IF c_period%NOTFOUND THEN
         x_return_status := FND_API.g_ret_sts_error;
         AMS_Utility_PVT.error_message ('AMS_CAMP_BAD_START_PERIOD');
      END IF;
      CLOSE c_period;
   END IF;

   IF p_deliv_rec.end_period_name iS NOT NULL THEN
      OPEN c_period (p_deliv_rec.end_period_name);
      FETCH c_period INTO l_dummy;
      IF c_period%NOTFOUND THEN
         x_return_status := FND_API.g_ret_sts_error;
         AMS_Utility_PVT.error_message ('AMS_CAMP_BAD_END_PERIOD');
      END IF;
      CLOSE c_period;
   END IF;

END check_deliv_items;


---------------------------------------------------------------------
-- PROCEDURE
--    check_deliv_record
--
-- HISTORY
--    10/11/99  khung  Create.
---------------------------------------------------------------------

PROCEDURE check_deliv_record
(
   p_deliv_rec      IN  deliv_rec_type,
   p_complete_rec   IN  deliv_rec_type := NULL,
   x_return_status  OUT NOCOPY VARCHAR2
)
IS
   l_dummy       NUMBER;
   l_start_date  DATE;
   l_end_date    DATE;
   l_fore_comp_date DATE;

   CURSOR c_calendar (l_calendar_name IN VARCHAR2) IS
      SELECT 1
      FROM   dual
      WHERE  EXISTS (SELECT 1
                     FROM gl_periods_v
                     WHERE period_set_name = l_calendar_name);

   CURSOR c_period (l_name IN VARCHAR2) IS
      SELECT start_date, end_date
      FROM   gl_periods_v
      WHERE  period_set_name = p_deliv_rec.deliverable_calendar
      AND    period_name = l_name;
   l_start_rec    c_period%ROWTYPE;
   l_end_rec      c_period%ROWTYPE;
BEGIN

   x_return_status := FND_API.g_ret_sts_success;

   IF p_deliv_rec.actual_avail_from_date <> FND_API.g_miss_date
      OR p_deliv_rec.actual_avail_to_date <> FND_API.g_miss_date
   THEN
      IF p_deliv_rec.actual_avail_from_date = FND_API.g_miss_date THEN
         l_start_date := p_complete_rec.actual_avail_from_date;
      ELSE
         l_start_date := p_deliv_rec.actual_avail_from_date;
      END IF;

      IF p_deliv_rec.actual_avail_to_date = FND_API.g_miss_date THEN
         l_end_date := p_complete_rec.actual_avail_to_date;
      ELSE
         l_end_date := p_deliv_rec.actual_avail_to_date;
      END IF;

      IF l_start_date > l_end_date THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('AMS', 'AMS_DELIV_DATE_AFTER_DATE');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
      END IF;
   END IF;

   IF p_deliv_rec.actual_avail_from_date <> FND_API.g_miss_date
      OR p_deliv_rec.forecasted_complete_date <> FND_API.g_miss_date
   THEN
      IF p_deliv_rec.actual_avail_from_date = FND_API.g_miss_date THEN
         l_start_date := p_complete_rec.actual_avail_from_date;
      ELSE
         l_start_date := p_deliv_rec.actual_avail_from_date;
      END IF;

      IF p_deliv_rec.forecasted_complete_date = FND_API.g_miss_date THEN
         l_fore_comp_date := p_complete_rec.forecasted_complete_date;
      ELSE
         l_fore_comp_date := p_deliv_rec.forecasted_complete_date;
      END IF;

      IF l_start_date < l_fore_comp_date THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('AMS', 'AMS_DELIV_FOREC_AFTER_START');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
      END IF;

/* remove on 06/07/2000 by khung
      IF p_deliv_rec.deliverable_id IS NULL THEN  -- only for creation
          IF l_fore_comp_date < SYSDATE THEN
             IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
             THEN
                FND_MESSAGE.set_name('AMS', 'AMS_DELIV_FOREC_BEFORE_TODAY');
                FND_MSG_PUB.add;
             END IF;
             x_return_status := FND_API.g_ret_sts_error;
          END IF;
      END IF;
*/
   END IF;

   -- do other record level checkings

   -- start period and end period validation
   IF p_deliv_rec.start_period_name IS NOT NULL OR p_deliv_rec.end_period_name IS NOT NULL THEN
      -- validate calendr exists only if start or end period is chosen
      OPEN c_calendar (p_deliv_rec.deliverable_calendar);
      FETCH c_calendar INTO l_dummy;
      IF c_calendar%NOTFOUND THEN
         x_return_status := FND_API.g_ret_sts_error;
         AMS_Utility_PVT.error_message ('AMS_CAMP_NO_CAMPAIGN_CALENDAR');
      END IF;
      CLOSE c_calendar;
   END IF;

   IF p_deliv_rec.start_period_name IS NOT NULL THEN
      OPEN c_period (p_deliv_rec.start_period_name);
      FETCH c_period INTO l_start_rec;
      CLOSE c_period;
   END IF;

   IF p_deliv_rec.end_period_name IS NOT NULL THEN
      OPEN c_period (p_deliv_rec.end_period_name);
      FETCH c_period INTO l_end_rec;
      CLOSE c_period;
   END IF;

   --
   -- The start period start date should be
   -- before the end period end date
   IF l_start_rec.start_date IS NOT NULL AND l_end_rec.end_date IS NOT NULL THEN
      IF l_start_rec.start_date > l_end_rec.end_date THEN
         x_return_status := FND_API.g_ret_sts_error;
         AMS_Utility_PVT.error_message ('AMS_CAMP_BAD_PERIODS');
      END IF;
   END IF;

   --
   -- Available From date should be within
   -- the given start period date range.
   IF l_start_rec.start_date IS NOT NULL THEN
      IF p_complete_rec.actual_avail_from_date < l_start_rec.start_date OR p_complete_rec.actual_avail_from_date > l_start_rec.end_date THEN
         x_return_status := FND_API.g_ret_sts_error;
         AMS_Utility_PVT.error_message ('AMS_DELV_OUT_START_DATE');
      END IF;
   END IF;

   --
   -- Available To date should be within the
   -- given end period date range.
   IF l_end_rec.start_date IS NOT NULL THEN
      IF p_complete_rec.actual_avail_to_date < l_end_rec.start_date OR p_complete_rec.actual_avail_to_date > l_end_rec.end_date THEN
         x_return_status := FND_API.g_ret_sts_error;
         AMS_Utility_PVT.error_message ('AMS_DELV_OUT_END_DATE');
      END IF;
   END IF;


END check_deliv_record;


---------------------------------------------------------------------
-- PROCEDURE
--    init_deliv_rec
--
-- HISTORY
--    10/11/99  khung  Create.
---------------------------------------------------------------------

PROCEDURE init_deliv_rec
(
   x_deliv_rec      OUT NOCOPY deliv_rec_type
)
IS

BEGIN

    IF (AMS_DEBUG_HIGH_ON) THEN
    AMS_Utility_PVT.debug_message('IN THE INIT_DELIV REC');
    END IF;
   x_deliv_rec.deliverable_id := FND_API.g_miss_num;
   x_deliv_rec.last_update_date := FND_API.g_miss_date;
   x_deliv_rec.last_updated_by := FND_API.g_miss_num;
   x_deliv_rec.creation_date := FND_API.g_miss_date;
   x_deliv_rec.created_by := FND_API.g_miss_num;
   x_deliv_rec.last_update_login := FND_API.g_miss_num;
   x_deliv_rec.object_version_number := FND_API.g_miss_num;
   x_deliv_rec.language_code := FND_API.g_miss_char;
   x_deliv_rec.version := FND_API.g_miss_char;
   x_deliv_rec.application_id := FND_API.g_miss_num;
   x_deliv_rec.user_status_id := FND_API.g_miss_num;
   x_deliv_rec.status_code := FND_API.g_miss_char;
   x_deliv_rec.status_date := FND_API.g_miss_date;
   x_deliv_rec.active_flag := FND_API.g_miss_char;
   x_deliv_rec.private_flag := FND_API.g_miss_char;
   x_deliv_rec.owner_user_id := FND_API.g_miss_num;
   x_deliv_rec.fund_source_id := FND_API.g_miss_num;
   x_deliv_rec.fund_source_type := FND_API.g_miss_char;
   x_deliv_rec.category_type_id := FND_API.g_miss_num;
   x_deliv_rec.category_sub_type_id := FND_API.g_miss_num;
   x_deliv_rec.kit_flag := FND_API.g_miss_char;
   x_deliv_rec.can_fulfill_electronic_flag := FND_API.g_miss_char;
   x_deliv_rec.can_fulfill_physical_flag := FND_API.g_miss_char;
   x_deliv_rec.jtf_amv_item_id := FND_API.g_miss_num;
   x_deliv_rec.inventory_flag := FND_API.g_miss_char;
   x_deliv_rec.transaction_currency_code := FND_API.g_miss_char;
   x_deliv_rec.functional_currency_code := FND_API.g_miss_char;
   x_deliv_rec.budget_amount_tc := FND_API.g_miss_num;
   x_deliv_rec.budget_amount_fc := FND_API.g_miss_num;
   x_deliv_rec.actual_avail_from_date := FND_API.g_miss_date;
   x_deliv_rec.actual_avail_to_date := FND_API.g_miss_date;
   x_deliv_rec.forecasted_complete_date := FND_API.g_miss_date;
   x_deliv_rec.actual_complete_date := FND_API.g_miss_date;
   x_deliv_rec.replaced_by_deliverable_id := FND_API.g_miss_num;
   x_deliv_rec.inventory_item_id := FND_API.g_miss_num;
   x_deliv_rec.inventory_item_org_id := FND_API.g_miss_num;
   x_deliv_rec.pricelist_header_id := FND_API.g_miss_num;
   x_deliv_rec.pricelist_line_id := FND_API.g_miss_num;
   x_deliv_rec.non_inv_ctrl_code := FND_API.g_miss_char;
   x_deliv_rec.non_inv_quantity_on_hand := FND_API.g_miss_num;
   x_deliv_rec.non_inv_quantity_on_order := FND_API.g_miss_num;
   x_deliv_rec.non_inv_quantity_on_reserve := FND_API.g_miss_num;
   x_deliv_rec.chargeback_amount := FND_API.g_miss_num;
   x_deliv_rec.chargeback_amount_curr_code := FND_API.g_miss_char;
   x_deliv_rec.deliverable_code := FND_API.g_miss_char;
   x_deliv_rec.deliverable_pick_flag := FND_API.g_miss_char;
   x_deliv_rec.currency_code := FND_API.g_miss_char;
   x_deliv_rec.forecasted_cost := FND_API.g_miss_num;
   x_deliv_rec.actual_cost := FND_API.g_miss_num;
   x_deliv_rec.forecasted_responses := FND_API.g_miss_num;
   x_deliv_rec.actual_responses := FND_API.g_miss_num;
   x_deliv_rec.country_id := FND_API.g_miss_num;
   x_deliv_rec.setup_id := FND_API.g_miss_num;
   x_deliv_rec.attribute_category := FND_API.g_miss_char;
   x_deliv_rec.attribute1 := FND_API.g_miss_char;
   x_deliv_rec.attribute2 := FND_API.g_miss_char;
   x_deliv_rec.attribute3 := FND_API.g_miss_char;
   x_deliv_rec.attribute4 := FND_API.g_miss_char;
   x_deliv_rec.attribute5 := FND_API.g_miss_char;
   x_deliv_rec.attribute6 := FND_API.g_miss_char;
   x_deliv_rec.attribute7 := FND_API.g_miss_char;
   x_deliv_rec.attribute8 := FND_API.g_miss_char;
   x_deliv_rec.attribute9 := FND_API.g_miss_char;
   x_deliv_rec.attribute10 := FND_API.g_miss_char;
   x_deliv_rec.attribute11 := FND_API.g_miss_char;
   x_deliv_rec.attribute12 := FND_API.g_miss_char;
   x_deliv_rec.attribute13 := FND_API.g_miss_char;
   x_deliv_rec.attribute14 := FND_API.g_miss_char;
   x_deliv_rec.attribute15 := FND_API.g_miss_char;
   x_deliv_rec.chargeback_uom := FND_API.g_miss_char;
   x_deliv_rec.deliverable_name := FND_API.g_miss_char;
   x_deliv_rec.description := FND_API.g_miss_char;
   x_deliv_rec.deliverable_calendar := FND_API.g_miss_char;
   x_deliv_rec.start_period_name := FND_API.g_miss_char;
   x_deliv_rec.end_period_name := FND_API.g_miss_char;

END init_deliv_rec;

---------------------------------------------------------------------
-- PROCEDURE
--    complete_deliv_rec
--
-- HISTORY
--    10/11/99  khung  Create.
---------------------------------------------------------------------
PROCEDURE complete_deliv_rec
(
   p_deliv_rec      IN  deliv_rec_type,
   x_complete_rec   OUT NOCOPY deliv_rec_type
)
IS

   CURSOR c_deliv IS
   SELECT *
     FROM ams_deliverables_vl
    WHERE deliverable_id = p_deliv_rec.deliverable_id;

   l_deliv_rec  c_deliv%ROWTYPE;

BEGIN

   IF (AMS_DEBUG_HIGH_ON) THEN



   AMS_Utility_PVT.debug_message('complete_deliv_rec...');

   END IF;

   x_complete_rec := p_deliv_rec;

   OPEN c_deliv;
   FETCH c_deliv INTO l_deliv_rec;
   IF c_deliv%NOTFOUND THEN
      CLOSE c_deliv;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
   END IF;
   CLOSE c_deliv;

   IF p_deliv_rec.language_code = FND_API.g_miss_char THEN
      x_complete_rec.language_code := l_deliv_rec.language_code;
   END IF;

   IF p_deliv_rec.version = FND_API.g_miss_char THEN
      x_complete_rec.version := l_deliv_rec.version;
   END IF;

   IF p_deliv_rec.application_id = FND_API.g_miss_num THEN
      x_complete_rec.application_id := l_deliv_rec.application_id;
   END IF;

   IF p_deliv_rec.user_status_id = FND_API.g_miss_num THEN
      x_complete_rec.user_status_id := l_deliv_rec.user_status_id;
   END IF;

   IF p_deliv_rec.status_code = FND_API.g_miss_char THEN
      x_complete_rec.status_code := l_deliv_rec.status_code;
   END IF;

   IF p_deliv_rec.status_date = FND_API.g_miss_date THEN
      x_complete_rec.status_date := l_deliv_rec.status_date;
   END IF;

   IF p_deliv_rec.active_flag = FND_API.g_miss_char THEN
      x_complete_rec.active_flag := l_deliv_rec.active_flag;
   END IF;

   IF p_deliv_rec.private_flag = FND_API.g_miss_char THEN
      x_complete_rec.private_flag := l_deliv_rec.private_flag;
   END IF;

   IF p_deliv_rec.owner_user_id = FND_API.g_miss_num THEN
      x_complete_rec.owner_user_id := l_deliv_rec.owner_user_id;
   END IF;

   IF p_deliv_rec.fund_source_id = FND_API.g_miss_num THEN
      x_complete_rec.fund_source_id := l_deliv_rec.fund_source_id;
   END IF;

   IF p_deliv_rec.fund_source_type = FND_API.g_miss_char THEN
      x_complete_rec.fund_source_type := l_deliv_rec.fund_source_type;
   END IF;

   IF p_deliv_rec.category_type_id = FND_API.g_miss_num THEN
      x_complete_rec.category_type_id := l_deliv_rec.category_type_id;
   END IF;

   IF p_deliv_rec.category_sub_type_id = FND_API.g_miss_num THEN
      x_complete_rec.category_sub_type_id := l_deliv_rec.category_sub_type_id;
   END IF;

   IF p_deliv_rec.kit_flag = FND_API.g_miss_char THEN
      x_complete_rec.kit_flag := l_deliv_rec.kit_flag;
   END IF;

   IF p_deliv_rec.can_fulfill_electronic_flag = FND_API.g_miss_char THEN
      x_complete_rec.can_fulfill_electronic_flag := l_deliv_rec.can_fulfill_electronic_flag;
   END IF;

   IF p_deliv_rec.can_fulfill_physical_flag = FND_API.g_miss_char THEN
      x_complete_rec.can_fulfill_physical_flag := l_deliv_rec.can_fulfill_physical_flag;
   END IF;

   IF p_deliv_rec.jtf_amv_item_id = FND_API.g_miss_num THEN
      x_complete_rec.jtf_amv_item_id := l_deliv_rec.jtf_amv_item_id;
   END IF;

   IF p_deliv_rec.inventory_flag = FND_API.g_miss_char THEN
      x_complete_rec.inventory_flag := l_deliv_rec.inventory_flag;
   END IF;

   IF p_deliv_rec.transaction_currency_code = FND_API.g_miss_char THEN
      x_complete_rec.transaction_currency_code := l_deliv_rec.transaction_currency_code;
   END IF;

   IF p_deliv_rec.functional_currency_code = FND_API.g_miss_char THEN
      x_complete_rec.functional_currency_code := l_deliv_rec.functional_currency_code;
   END IF;

   IF p_deliv_rec.budget_amount_tc = FND_API.g_miss_num THEN
      x_complete_rec.budget_amount_tc := l_deliv_rec.budget_amount_tc;
   END IF;

   IF p_deliv_rec.budget_amount_fc = FND_API.g_miss_num THEN
      x_complete_rec.budget_amount_fc := l_deliv_rec.budget_amount_fc;
   END IF;

   IF p_deliv_rec.actual_avail_from_date = FND_API.g_miss_date THEN
      x_complete_rec.actual_avail_from_date := l_deliv_rec.actual_avail_from_date;
   END IF;

   IF p_deliv_rec.actual_avail_to_date = FND_API.g_miss_date THEN
      x_complete_rec.actual_avail_to_date := l_deliv_rec.actual_avail_to_date;
   END IF;

   IF p_deliv_rec.forecasted_complete_date = FND_API.g_miss_date THEN
      x_complete_rec.forecasted_complete_date := l_deliv_rec.forecasted_complete_date;
   END IF;

   IF p_deliv_rec.actual_complete_date = FND_API.g_miss_date THEN
      x_complete_rec.actual_complete_date := l_deliv_rec.actual_complete_date;
   END IF;

   IF p_deliv_rec.replaced_by_deliverable_id = FND_API.g_miss_num THEN
      x_complete_rec.replaced_by_deliverable_id := l_deliv_rec.replaced_by_deliverable_id;
   END IF;

   IF p_deliv_rec.inventory_item_id = FND_API.g_miss_num THEN
      x_complete_rec.inventory_item_id := l_deliv_rec.inventory_item_id;
   END IF;

   IF p_deliv_rec.inventory_item_org_id = FND_API.g_miss_num THEN
      x_complete_rec.inventory_item_org_id := l_deliv_rec.inventory_item_org_id;
   END IF;

   IF p_deliv_rec.pricelist_header_id = FND_API.g_miss_num THEN
      x_complete_rec.pricelist_header_id := l_deliv_rec.pricelist_header_id;
   END IF;

   IF p_deliv_rec.pricelist_line_id = FND_API.g_miss_num THEN
      x_complete_rec.pricelist_line_id := l_deliv_rec.pricelist_line_id;
   END IF;

   IF p_deliv_rec.non_inv_ctrl_code = FND_API.g_miss_char THEN
      x_complete_rec.non_inv_ctrl_code := l_deliv_rec.non_inv_ctrl_code;
   END IF;

   IF p_deliv_rec.non_inv_quantity_on_hand = FND_API.g_miss_num THEN
      x_complete_rec.non_inv_quantity_on_hand := l_deliv_rec.non_inv_quantity_on_hand;
   END IF;

   IF p_deliv_rec.non_inv_quantity_on_order = FND_API.g_miss_num THEN
      x_complete_rec.non_inv_quantity_on_order := l_deliv_rec.non_inv_quantity_on_order;
   END IF;

   IF p_deliv_rec.non_inv_quantity_on_reserve = FND_API.g_miss_num THEN
      x_complete_rec.non_inv_quantity_on_reserve := l_deliv_rec.non_inv_quantity_on_reserve;
   END IF;

   IF p_deliv_rec.chargeback_amount = FND_API.g_miss_num THEN
      x_complete_rec.chargeback_amount := l_deliv_rec.chargeback_amount;
   END IF;

   IF p_deliv_rec.chargeback_amount_curr_code = FND_API.g_miss_char THEN
      x_complete_rec.chargeback_amount_curr_code := l_deliv_rec.chargeback_amount_curr_code;
   END IF;

   IF p_deliv_rec.deliverable_code = FND_API.g_miss_char THEN
      x_complete_rec.deliverable_code := l_deliv_rec.deliverable_code;
   END IF;

   IF p_deliv_rec.deliverable_pick_flag = FND_API.g_miss_char THEN
      x_complete_rec.deliverable_pick_flag := l_deliv_rec.deliverable_pick_flag;
   END IF;

   IF p_deliv_rec.currency_code = FND_API.g_miss_char THEN
      x_complete_rec.currency_code := l_deliv_rec.currency_code;
   END IF;

   IF p_deliv_rec.forecasted_cost = FND_API.g_miss_num THEN
      x_complete_rec.forecasted_cost := l_deliv_rec.forecasted_cost;
   END IF;

   IF p_deliv_rec.actual_cost = FND_API.g_miss_num THEN
      x_complete_rec.actual_cost := l_deliv_rec.actual_cost;
   END IF;

   IF p_deliv_rec.forecasted_responses = FND_API.g_miss_num THEN
      x_complete_rec.forecasted_responses := l_deliv_rec.forecasted_responses;
   END IF;

   IF p_deliv_rec.actual_responses = FND_API.g_miss_num THEN
      x_complete_rec.actual_responses := l_deliv_rec.actual_responses;
   END IF;

   IF p_deliv_rec.country = FND_API.g_miss_char THEN
      x_complete_rec.country := l_deliv_rec.country;
   END IF;

   IF p_deliv_rec.attribute_category = FND_API.g_miss_char THEN
      x_complete_rec.attribute_category := l_deliv_rec.attribute_category;
   END IF;

   IF p_deliv_rec.attribute1 = FND_API.g_miss_char THEN
      x_complete_rec.attribute1 := l_deliv_rec.attribute1;
   END IF;

   IF p_deliv_rec.attribute2 = FND_API.g_miss_char THEN
      x_complete_rec.attribute2 := l_deliv_rec.attribute2;
   END IF;

   IF p_deliv_rec.attribute3 = FND_API.g_miss_char THEN
      x_complete_rec.attribute3 := l_deliv_rec.attribute3;
   END IF;

   IF p_deliv_rec.attribute4 = FND_API.g_miss_char THEN
      x_complete_rec.attribute4 := l_deliv_rec.attribute4;
   END IF;

   IF p_deliv_rec.attribute5 = FND_API.g_miss_char THEN
      x_complete_rec.attribute5 := l_deliv_rec.attribute5;
   END IF;

   IF p_deliv_rec.attribute6 = FND_API.g_miss_char THEN
      x_complete_rec.attribute6 := l_deliv_rec.attribute6;
   END IF;

   IF p_deliv_rec.attribute7 = FND_API.g_miss_char THEN
      x_complete_rec.attribute7 := l_deliv_rec.attribute7;
   END IF;

   IF p_deliv_rec.attribute8 = FND_API.g_miss_char THEN
      x_complete_rec.attribute8 := l_deliv_rec.attribute8;
   END IF;

   IF p_deliv_rec.attribute9 = FND_API.g_miss_char THEN
      x_complete_rec.attribute9 := l_deliv_rec.attribute9;
   END IF;

   IF p_deliv_rec.attribute10 = FND_API.g_miss_char THEN
      x_complete_rec.attribute10 := l_deliv_rec.attribute10;
   END IF;

   IF p_deliv_rec.attribute11 = FND_API.g_miss_char THEN
      x_complete_rec.attribute11 := l_deliv_rec.attribute11;
   END IF;

   IF p_deliv_rec.attribute12 = FND_API.g_miss_char THEN
      x_complete_rec.attribute12 := l_deliv_rec.attribute12;
   END IF;

   IF p_deliv_rec.attribute13 = FND_API.g_miss_char THEN
      x_complete_rec.attribute13 := l_deliv_rec.attribute13;
   END IF;

   IF p_deliv_rec.attribute14 = FND_API.g_miss_char THEN
      x_complete_rec.attribute14 := l_deliv_rec.attribute14;
   END IF;

   IF p_deliv_rec.attribute15 = FND_API.g_miss_char THEN
      x_complete_rec.attribute15 := l_deliv_rec.attribute15;
   END IF;

   IF p_deliv_rec.chargeback_uom = FND_API.g_miss_char THEN
      x_complete_rec.chargeback_uom := l_deliv_rec.chargeback_uom;
   END IF;

   IF p_deliv_rec.deliverable_name = FND_API.g_miss_char THEN
      x_complete_rec.deliverable_name := l_deliv_rec.deliverable_name;
   END IF;

   IF p_deliv_rec.description = FND_API.g_miss_char THEN
      x_complete_rec.description := l_deliv_rec.description;
   END IF;

   IF p_deliv_rec.deliverable_calendar = FND_API.g_miss_char THEN
      x_complete_rec.deliverable_calendar := l_deliv_rec.deliverable_calendar;
   END IF;

   IF p_deliv_rec.start_period_name = FND_API.g_miss_char THEN
      x_complete_rec.start_period_name := l_deliv_rec.start_period_name;
   END IF;

   IF p_deliv_rec.end_period_name = FND_API.g_miss_char THEN
      x_complete_rec.end_period_name := l_deliv_rec.end_period_name;
   END IF;

   IF p_deliv_rec.country_id = FND_API.g_miss_num THEN
      x_complete_rec.country_id := l_deliv_rec.country_id;
   END IF;

   IF p_deliv_rec.Setup_id = FND_API.g_miss_num THEN
      x_complete_rec.Setup_id := l_deliv_rec.custom_setup_id;
   END IF;

END complete_deliv_rec;


---------------------------------------------------------------------
-- PROCEDURE
--    create_pricelist_header
--
-- HISTORY
--    02/16/2000  khung@us  Create.
---------------------------------------------------------------------

PROCEDURE create_pricelist_header
(
  p_api_version             IN  NUMBER,
  p_init_msg_list           IN  VARCHAR2 := FND_API.g_false,
  p_return_values           IN  VARCHAR2 := FND_API.g_false,
  p_commit                  IN  VARCHAR2 := FND_API.g_false,
  p_deliv_rec               IN  deliv_rec_type,
  x_return_status           OUT NOCOPY VARCHAR2,
  x_msg_count               OUT NOCOPY NUMBER,
  x_msg_data                OUT NOCOPY VARCHAR2,
  x_pricelist_header_id     OUT NOCOPY NUMBER
)

IS
   l_api_version            CONSTANT NUMBER       := 1.0;
   l_api_name               CONSTANT VARCHAR2(30) := 'create_pricelist_header';
   l_full_name              CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

   l_return_status          VARCHAR2(1);
   l_msg_count              NUMBER;
   l_msg_data               VARCHAR2(2000);

   p_price_list_rec         qp_price_list_pub.price_list_rec_type;
   p_price_list_val_rec     qp_price_list_pub.price_list_val_rec_type;
   p_price_list_line_tbl    qp_price_list_pub.price_list_line_tbl_type;
   p_price_list_line_val_tbl      qp_price_list_pub.price_list_line_val_tbl_type;
   p_qualifiers_tbl         qp_qualifier_rules_pub.qualifiers_tbl_type;
   p_qualifiers_val_tbl     qp_qualifier_rules_pub.qualifiers_val_tbl_type;
   p_pricing_attr_tbl       qp_price_list_pub.pricing_attr_tbl_type;
   p_pricing_attr_val_tbl   qp_price_list_pub.pricing_attr_val_tbl_type;

   l_price_list_rec         qp_price_list_pub.price_list_rec_type;
   l_price_list_val_rec     qp_price_list_pub.price_list_val_rec_type;
   l_price_list_line_tbl    qp_price_list_pub.price_list_line_tbl_type;
   l_price_list_line_val_tbl      qp_price_list_pub.price_list_line_val_tbl_type;
   l_qualifiers_tbl         qp_qualifier_rules_pub.qualifiers_tbl_type;
   l_qualifiers_val_tbl     qp_qualifier_rules_pub.qualifiers_val_tbl_type;
   l_pricing_attr_tbl       qp_price_list_pub.pricing_attr_tbl_type;
   l_pricing_attr_val_tbl   qp_price_list_pub.pricing_attr_val_tbl_type;

BEGIN

   --dbms_output.put_line('create List header called');
   x_return_status := FND_API.g_ret_sts_success;

   p_price_list_rec.name := 'Deliverable Inventory HDR';
   p_price_list_rec.created_by := p_deliv_rec.owner_user_id;
   p_price_list_rec.creation_date := sysdate;
   p_price_list_rec.currency_code := FND_PROFILE.Value('AMS_DEFAULT_CURR_CODE');
   p_price_list_rec.list_type_code := 'PRL';
   p_price_list_rec.description := 'Deliverable Inventory HDR';
   p_price_list_rec.start_date_active := p_deliv_rec.actual_avail_from_date;
   --p_price_list_rec.end_date_active := p_deliv_rec.actual_avail_to_date;
   p_price_list_rec.operation :=QP_GLOBALS.G_OPR_CREATE;

   IF (AMS_DEBUG_HIGH_ON) THEN
   AMS_Utility_PVT.debug_message(l_full_name ||': create pricelist header...');
   END IF;

   QP_PRICE_LIST_PUB.Process_Price_List(
        p_api_version_number      => 1.0,
        p_init_msg_list           => FND_API.g_false,
        p_return_values           => FND_API.G_TRUE,
        p_commit                  => FND_API.g_false,
        x_return_status           => l_return_status,
        x_msg_count               => l_msg_count,
        x_msg_data                => l_msg_data,
        p_price_list_rec          => p_price_list_rec,
        p_price_list_val_rec      => p_price_list_val_rec,
        p_price_list_line_tbl     => p_price_list_line_tbl ,
        p_price_list_line_val_tbl => p_price_list_line_val_tbl  ,
        p_qualifiers_tbl          => p_qualifiers_tbl,
        p_qualifiers_val_tbl      => p_qualifiers_val_tbl,
        p_pricing_attr_tbl        => p_pricing_attr_tbl,
        p_pricing_attr_val_tbl    => p_pricing_attr_val_tbl,
        x_price_list_rec          => l_price_list_rec,
        x_price_list_val_rec      => l_price_list_val_rec,
        x_price_list_line_tbl     => l_price_list_line_tbl ,
        x_price_list_line_val_tbl => l_price_list_line_val_tbl  ,
        x_qualifiers_tbl          => l_qualifiers_tbl,
        x_qualifiers_val_tbl      => l_qualifiers_val_tbl,
        x_pricing_attr_tbl        => l_pricing_attr_tbl,
        x_pricing_attr_val_tbl    => l_pricing_attr_val_tbl
    );

    x_pricelist_header_id := l_price_list_rec.list_header_id;
    x_return_status := l_return_status;

   IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
       RAISE FND_API.g_exc_unexpected_error;
   ELSIF l_return_status = FND_API.g_ret_sts_error THEN
       RAISE FND_API.g_exc_error;
   END IF;

   IF p_commit = FND_API.g_true THEN
      COMMIT WORK;
   END IF;
END create_pricelist_header;

---------------------------------------------------------------------
-- PROCEDURE
--    create_pricelist_line
--
-- HISTORY
--    02/17/2000  khung@us  Create.
---------------------------------------------------------------------

PROCEDURE create_pricelist_line
(
  p_api_version             IN  NUMBER,
  p_init_msg_list           IN  VARCHAR2 := FND_API.g_false,
  p_return_values           IN  VARCHAR2 := FND_API.g_false,
  p_commit                  IN  VARCHAR2 := FND_API.g_false,
  p_price_hdr_id            IN  NUMBER,
  p_deliv_rec               IN  deliv_rec_type,
  x_return_status           OUT NOCOPY VARCHAR2,
  x_msg_count               OUT NOCOPY NUMBER,
  x_msg_data                OUT NOCOPY VARCHAR2,
  x_pricelist_line_id       OUT NOCOPY NUMBER
)
IS
   l_api_version            CONSTANT NUMBER       := 1.0;
   l_api_name               CONSTANT VARCHAR2(30) := 'create_pricelist_line';
   l_full_name              CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

   l_return_status          VARCHAR2(1);
   l_msg_count              NUMBER;
   l_msg_data               VARCHAR2(2000);

   p_price_list_rec         qp_price_list_pub.price_list_rec_type;
   p_price_list_val_rec     qp_price_list_pub.price_list_val_rec_type;
   p_price_list_line_tbl    qp_price_list_pub.price_list_line_tbl_type;
   p_price_list_line_val_tbl      qp_price_list_pub.price_list_line_val_tbl_type;
   p_qualifiers_tbl         qp_qualifier_rules_pub.qualifiers_tbl_type;
   p_qualifiers_val_tbl     qp_qualifier_rules_pub.qualifiers_val_tbl_type;
   p_pricing_attr_tbl       qp_price_list_pub.pricing_attr_tbl_type;
   p_pricing_attr_val_tbl   qp_price_list_pub.pricing_attr_val_tbl_type;

   l_price_list_rec         qp_price_list_pub.price_list_rec_type;
   l_price_list_val_rec     qp_price_list_pub.price_list_val_rec_type;
   l_price_list_line_tbl    qp_price_list_pub.price_list_line_tbl_type;
   l_price_list_line_val_tbl      qp_price_list_pub.price_list_line_val_tbl_type;
   l_qualifiers_tbl         qp_qualifier_rules_pub.qualifiers_tbl_type;
   l_qualifiers_val_tbl     qp_qualifier_rules_pub.qualifiers_val_tbl_type;
   l_pricing_attr_tbl       qp_price_list_pub.pricing_attr_tbl_type;
   l_pricing_attr_val_tbl   qp_price_list_pub.pricing_attr_val_tbl_type;

BEGIN

   --dbms_output.put_line('create List line called');
   x_return_status := FND_API.g_ret_sts_success;

   p_price_list_line_tbl(1).list_header_id := p_price_hdr_id;
   --dbms_output.put_line('p_price_hdr_id: '||p_price_hdr_id);
   p_price_list_line_tbl(1).list_line_type_code := 'PLL';
   p_price_list_line_tbl(1).base_uom_code := 'EA';
   p_price_list_line_tbl(1).created_by := p_deliv_rec.owner_user_id;
   p_price_list_line_tbl(1).inventory_item_id := p_deliv_rec.inventory_item_id;
   p_price_list_line_tbl(1).start_date_active := p_deliv_rec.actual_avail_from_date;
   p_price_list_line_tbl(1).end_date_active := p_deliv_rec.actual_avail_to_date;
   p_price_list_line_tbl(1).organization_id := p_deliv_rec.inventory_item_org_id;
   p_price_list_line_tbl(1).operation :=QP_GLOBALS.G_OPR_CREATE;
   p_price_list_line_tbl(1).automatic_flag := 'Y';
  -- if p_deliv_rec.PRICELIST_LIST_PRICE is NULL or p_deliv_rec.PRICELIST_LIST_PRICE = FND_API.g_miss_num then
      p_price_list_line_tbl(1).list_price := 0;
   --else
   --p_price_list_line_tbl(1).list_price := p_deliv_rec.PRICELIST_LIST_PRICE;
   --end if;

   IF (AMS_DEBUG_HIGH_ON) THEN
   AMS_Utility_PVT.debug_message(l_full_name ||': create pricelist line...');
   END IF;

   QP_PRICE_LIST_PUB.Process_Price_List(
        p_api_version_number        => 1.0,
        p_init_msg_list             => FND_API.g_false,
        p_return_values             => FND_API.G_TRUE,
        p_commit                    => FND_API.g_false,
        x_return_status             => l_return_status,
        x_msg_count                 => l_msg_count,
        x_msg_data                  => l_msg_data,
        p_price_list_rec            => p_price_list_rec,
        p_price_list_val_rec        => p_price_list_val_rec,
        p_price_list_line_tbl       => p_price_list_line_tbl ,
        p_price_list_line_val_tbl   => p_price_list_line_val_tbl  ,
        p_qualifiers_tbl            => p_qualifiers_tbl,
        p_qualifiers_val_tbl        => p_qualifiers_val_tbl,
        p_pricing_attr_tbl          => p_pricing_attr_tbl,
        p_pricing_attr_val_tbl      => p_pricing_attr_val_tbl,
        x_price_list_rec            => l_price_list_rec,
        x_price_list_val_rec        => l_price_list_val_rec,
        x_price_list_line_tbl       => l_price_list_line_tbl ,
        x_price_list_line_val_tbl   => l_price_list_line_val_tbl  ,
        x_qualifiers_tbl            => l_qualifiers_tbl,
        x_qualifiers_val_tbl        => l_qualifiers_val_tbl,
        x_pricing_attr_tbl          => l_pricing_attr_tbl,
        x_pricing_attr_val_tbl      => l_pricing_attr_val_tbl
    );

   x_pricelist_line_id := l_PRICE_LIST_LINE_tbl(1).list_line_id;
   x_return_status := l_return_status;

   IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
       RAISE FND_API.g_exc_unexpected_error;
   ELSIF l_return_status = FND_API.g_ret_sts_error THEN
       RAISE FND_API.g_exc_error;
   END IF;

   IF p_commit = FND_API.g_true THEN
      COMMIT WORK;
   END IF;
END create_pricelist_line;

PROCEDURE create_jtf_attachment
(
  p_used_by             IN  VARCHAR2,
  p_used_by_id          IN  NUMBER,
  p_file_id             IN  NUMBER,
  p_file_name           IN  VARCHAR2,
  p_att_type            IN  VARCHAR2,
  p_file_ver            IN  VARCHAR2,
  x_return_status       OUT NOCOPY VARCHAR2,
  x_msg_count           OUT NOCOPY NUMBER,
  x_msg_data            OUT NOCOPY VARCHAR2,
  x_att_id              OUT NOCOPY NUMBER
) IS

   l_api_name           CONSTANT VARCHAR2(30) := 'create_jtf_attachment';

   l_api_version        NUMBER := 1.0;
   l_init_msg_list      VARCHAR2(1) := FND_API.g_false;
   l_commit             VARCHAR2(1) := FND_API.g_false;
   l_validation_level   NUMBER := FND_API.g_valid_level_full;
   l_return_status      VARCHAR2(1);
   l_msg_count          NUMBER;
   l_msg_data           VARCHAR2(2000);

   l_att_rec            jtf_amv_attachment_pub.act_attachment_rec_type;
   l_att_id             NUMBER;

BEGIN

   x_return_status  := FND_API.g_ret_sts_success;

   l_att_rec.attachment_used_by := p_used_by;
   l_att_rec.attachment_used_by_id := p_used_by_id;
   l_att_rec.file_id := p_file_id;
   l_att_rec.file_name := p_file_name;
   l_att_rec.attachment_type := p_att_type;
   l_att_rec.version := p_file_ver;
   IF l_att_rec.attachment_used_by = 'AMS_DELV' THEN
       l_att_rec.application_id := 530;
   ELSE
       l_att_rec.application_id := 520;
   END IF;
   l_att_rec.owner_user_id := FND_GLOBAL.user_id;
   l_att_rec.can_fulfill_electronic_flag := 'Y';

   jtf_amv_attachment_pub.create_act_attachment(
      p_api_version         =>  l_api_version,
      p_init_msg_list       =>  l_init_msg_list,
      p_commit              =>  l_commit,
      p_validation_level    =>  l_validation_level,
      x_return_status       =>  l_return_status,
      x_msg_count           =>  l_msg_count,
      x_msg_data            =>  l_msg_data,
      p_act_attachment_rec  =>  l_att_rec,
      x_act_attachment_id   =>  l_att_id
   );

   x_att_id := l_att_id;
   x_return_status := l_return_status;
   x_msg_count := l_msg_count;
   x_msg_data := l_msg_data;

END create_jtf_attachment;


-----------------------------------------------------------------
PROCEDURE Deliverable_Cancellation
   (p_deliverable_rec   IN  deliv_rec_type,
    x_return_status  OUT NOCOPY VARCHAR2 )
IS
   l_api_name     CONSTANT VARCHAR2(30) := 'Deliverable_Cancellation';
   l_full_name    CONSTANT VARCHAR2(60) := g_pkg_name||'.'||l_api_name;
   l_using_object_type  CONSTANT VARCHAR2(30) := 'DELV';
   l_item_type    CONSTANT VARCHAR2(30) :=  'AMSAPRV';
   l_workflowprocess CONSTANT VARCHAR2(30) :=   'AMS_DELV_CANCELLATION';
   l_master_object_id   NUMBER;
   l_master_object_type VARCHAR2(30);
   l_user_id      NUMBER;
   l_resource_id     NUMBER;
   l_object_name     VARCHAR2(240);
   l_object_type_name VARCHAR2(240);

   l_count NUMBER := 0 ;

 CURSOR c_parent_deliv(p_deliverable_id IN NUMBER) IS
   SELECT   DISTINCT master_object_id,
      master_object_type
   FROM  ams_object_associations
   WHERE using_object_type = l_using_object_type
   AND   using_object_id   = p_deliverable_id;

   l_parent_deliv_rec c_parent_deliv%ROWTYPE;

CURSOR c_camp(l_master_object_id IN NUMBER) IS
   SELECT owner_user_id ,campaign_name
   FROM ams_campaigns_vl
   WHERE campaign_id = l_master_object_id;


CURSOR c_eveh(l_master_object_id IN NUMBER) IS
   SELECT owner_user_id, event_header_name
   FROM ams_event_headers_vl
   WHERE event_header_id = l_master_object_id;

CURSOR c_eveo(l_master_object_id IN NUMBER) IS
   SELECT owner_user_id, event_offer_name
   FROM ams_event_offers_vl
   WHERE event_offer_id = l_master_object_id;

BEGIN
   x_return_status := FND_API.g_ret_sts_success;
   OPEN c_parent_deliv(p_deliverable_rec.deliverable_id);
   LOOP
      FETCH c_parent_deliv INTO l_parent_deliv_rec;
      EXIT WHEN c_parent_deliv%NOTFOUND;
      l_count := l_count + 1;
      l_master_object_id   := l_parent_deliv_rec.master_object_id;
      l_master_object_type := l_parent_deliv_rec.master_object_type;
      IF l_master_object_type ='CAMP' THEN
         OPEN c_camp(l_master_object_id);
         FETCH c_camp INTO l_user_id, l_object_name;
         CLOSE c_camp;
      ELSIF l_master_object_type ='EVEH' THEN
         OPEN c_eveh(l_master_object_id);
         FETCH c_eveh INTO l_user_id, l_object_name;
         CLOSE c_eveh;
      ELSIF l_master_object_type ='EVEO' THEN
         OPEN c_eveo(l_master_object_id);
         FETCH c_eveo INTO l_user_id, l_object_name;
         CLOSE c_eveo;
      END IF;

      l_object_type_name := AMS_UTILITY_PVT.get_lookup_meaning('AMS_SYS_ARC_QUALIFIER', l_master_object_type);
      AMS_approval_pvt.delvStartProcess(
         p_deliverable_id     =>  p_deliverable_rec.deliverable_id,
         p_deliverable_name   =>  p_deliverable_rec.deliverable_name,
         p_object_version_number => p_deliverable_rec.object_version_number,
         p_usedby_object_id   => l_parent_deliv_rec.master_object_id,
         p_usedby_object_name => l_object_name,
         p_usedby_object_type_name => l_object_type_name,
         p_requester_userid   =>  AMS_UTILITY_PVT.get_resource_id(FND_GLOBAL.USER_ID),
         p_deliverable_userid => l_user_id,
         p_workflowprocess    => l_workflowprocess,
         p_item_type          => l_item_type
         );
   END LOOP;
   CLOSE c_parent_deliv;

   /*
   --if the deliverable is not associated to any objects,when
   --the owner or team member changes the status to cancelled
   --the notification will be sent to the owner of deliverable.
   */

   IF l_count = 0 THEN

     l_user_id := p_deliverable_rec.owner_user_id;
     l_master_object_id := p_deliverable_rec.deliverable_id;
     l_object_name := p_deliverable_rec.deliverable_name;

     l_object_type_name := AMS_UTILITY_PVT.get_lookup_meaning('AMS_SYS_ARC_QUALIFIER', 'DELV');

     AMS_approval_pvt.delvStartProcess(
         p_deliverable_id     =>  p_deliverable_rec.deliverable_id,
         p_deliverable_name   =>  p_deliverable_rec.deliverable_name,
         p_object_version_number => p_deliverable_rec.object_version_number,
         p_usedby_object_id   => l_master_object_id,
         p_usedby_object_name => l_object_name,
         p_usedby_object_type_name => l_object_type_name,
         p_requester_userid   =>  AMS_UTILITY_PVT.get_resource_id(FND_GLOBAL.USER_ID),
         p_deliverable_userid => l_user_id,
         p_workflowprocess    => l_workflowprocess,
         p_item_type          => l_item_type
         );
   END IF;
/*
EXCEPTION
   WHEN others THEN
      IF c_parent_deliv%ISOPEN THEN
         CLOSE c_parent_deliv;
      END IF;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message(l_full_name||' Unhandled Error');
      END IF;
*/
END Deliverable_Cancellation;

-------------------------------------------------------------------
-- PROCEDURE
--    check_periods
--
-------------------------------------------------------------------
PROCEDURE check_periods(
   p_deliv_Rec             IN   deliv_rec_type
  ,x_deliverable_calendar  OUT NOCOPY  VARCHAR2
  ,x_return_status         OUT NOCOPY  VARCHAR2)
IS

CURSOR c_get_period_dets(deliv_id IN NUMBER)
IS SELECT start_period_name
         ,end_period_name
         ,deliverable_calendar
   FROM ams_deliverables_all_b
   WHERE deliverable_id = deliv_id;

l_get_period_cur  c_get_period_Dets%ROWTYPE;
l_deliverable_calendar VARCHAR2(15) := FND_PROFILE.value('AMS_CAMPAIGN_DEFAULT_CALENDER');


BEGIN

   x_return_status := FND_API.g_ret_sts_success;

   OPEN c_get_period_dets(p_deliv_rec.deliverable_id);
   FETCH c_get_period_dets INTO l_get_period_cur;
   CLOSE c_get_period_dets;

   IF ( (NVL(l_get_period_cur.start_period_name,'%%') <> NVL(p_deliv_rec.start_period_name,'%%') )
   OR ( NVL(l_get_period_cur.end_period_name,'$$') <> NVL(p_deliv_rec.end_period_name,'$$') ))
   THEN

      IF ( NVL(l_get_period_cur.deliverable_calendar,'**') <> NVL(l_deliverable_calendar, '**') ) THEN
         x_deliverable_calendar := FND_PROFILE.value('AMS_CAMPAIGN_DEFAULT_CALENDER');
      ELSE
         x_deliverable_calendar := l_get_period_cur.deliverable_calendar;
      END IF;
   ELSE
      x_deliverable_calendar := l_get_period_cur.deliverable_calendar;
   END IF;


EXCEPTION
 WHEN OTHERS THEN
      x_return_status := FND_API.g_ret_sts_unexp_error ;
END check_periods;

-------------------------------------------------------------------
-- PROCEDURE
--    check_owner_id
--
--
-------------------------------------------------------------------

PROCEDURE check_owner_id
(
    p_deliv_rec      IN        deliv_rec_type,
    x_return_status  OUT NOCOPY       VARCHAR2
) IS


   CURSOR c_owner_id(deliv_id IN NUMBER)
   IS
   SELECT owner_user_id
   FROM ams_deliverables_all_b
   WHERE deliverable_id = deliv_id;
   l_owner_user_id NUMBER;
   l_resource_id NUMBER := AMS_UTILITY_PVT.get_resource_id(FND_GLOBAL.User_id);

BEGIN

   x_return_status := FND_API.g_ret_sts_success;


   IF p_deliv_rec.owner_user_id <> FND_API.g_miss_num THEN

      OPEN c_owner_id(p_deliv_rec.deliverable_id);
      FETCH c_owner_id INTO l_owner_user_id;
      CLOSE c_owner_id;

      IF ( (AMS_ACCESS_PVT.CHECK_ADMIN_ACCESS(p_deliv_rec.owner_user_id) = FALSE)
      AND (l_owner_user_id <> l_resource_id)
      AND (l_owner_user_id <> p_deliv_rec.owner_user_id))
      THEN

         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('AMS', 'AMS_DELIV_CANT_CHANGE_OWNER');
            FND_MSG_PUB.add;
         END IF;

         x_return_status := FND_API.g_ret_sts_error;
         RETURN;

      END IF;
   END IF;


END check_owner_id;

-------------------------------------------------------------------
-- PROCEDURE
--    check_budget_lines
--
--
-------------------------------------------------------------------

PROCEDURE check_budget_lines
(
    p_deliv_rec      IN        deliv_rec_type,
    x_return_status  OUT NOCOPY       VARCHAR2
) IS




   CURSOR get_currency_code(deliv_id IN NUMBER)
   IS
   SELECT currency_code
   FROM ams_deliverables_all_b
   WHERE deliverable_id = deliv_id;

   CURSOR check_budget(deliv_id IN NUMBER)
   IS
   SELECT 'Y'
   FROM ams_act_budgets
   WHERE arc_act_budget_used_by='DELV'
   AND act_budget_used_by_id = deliv_id;

   l_currency_code  VARCHAR2(15);
   l_budget_lines VARCHAR2(1) := 'N';

BEGIN

   x_return_status := FND_API.g_ret_sts_success;

   IF p_deliv_rec.currency_code <> FND_API.g_miss_char THEN

      OPEN get_currency_code(p_deliv_rec.deliverable_id);
      FETCH get_currency_code INTO l_currency_code;
      CLOSE get_currency_code;

      IF (l_currency_code <> p_deliv_rec.currency_code) THEN
          OPEN check_budget(p_deliv_rec.deliverable_id);
          FETCH check_budget INTO l_budget_lines;
          CLOSE check_budget;

          IF l_budget_lines = 'Y' THEN
             IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
             THEN
                FND_MESSAGE.set_name('AMS', 'AMS_DELIV_CANT_CHANGE_CURRENCY');
                FND_MSG_PUB.add;
             END IF;
             x_return_status := FND_API.g_ret_sts_error;
             RETURN;
          END IF;
      END IF;
   END IF;
   IF (AMS_DEBUG_HIGH_ON) THEN
   AMS_UTILITY_PVT.debug_message('check budget lines is checked with no errors');
   END IF;
END check_budget_lines;

-------------------------------------------------------------------------
-- Function
--    Approval_required_flag
--
--
--------------------------------------------------------------------------
FUNCTION Approval_Required_Flag
( p_custom_setup_id    IN   NUMBER ,
  p_approval_type      IN   VARCHAR2
)
RETURN VARCHAR2 IS
   CURSOR c_custom_attr IS
   SELECT attr_available_flag
   FROM   ams_custom_setup_attr
   WHERE  custom_setup_id = p_custom_setup_id
   AND    object_attribute = p_approval_type ;

   l_flag VARCHAR2(1) ;
BEGIN

   OPEN c_custom_attr;
   FETCH c_custom_attr INTO l_flag ;
   CLOSE c_custom_attr ;

   IF l_flag = 'Y' THEN
      l_flag := FND_API.g_true;
   ELSIF l_flag = 'N' THEN
      l_flag := FND_API.g_false;
   END IF;

   RETURN l_flag ;

END Approval_Required_Flag;

-------------------------------------------------------------------
-- PROCEDURE
--    check_budget_lines
--
--  02/25/02  musman created
-------------------------------------------------------------------


PROCEDURE creat_inv_item
(
    p_deliv_rec        IN    deliv_rec_type,
    x_inv_id           OUT NOCOPY   NUMBER,
    x_org_id           OUT NOCOPY   NUMBER,
    x_return_status    OUT NOCOPY   VARCHAR2,
    x_msg_count        OUT NOCOPY   NUMBER,
    x_msg_data         OUT NOCOPY   VARCHAR2

)
IS

   l_full_name  VARCHAR2(40) := 'Private creat_inv_item';

  -- Inventory
   inv_creation_error   EXCEPTION;

   l_item_rec           AMS_ITEM_OWNER_PVT.ITEM_REC_TYPE; -- INV_Item_GRP.Item_rec_type;
   x_item_rec           AMS_ITEM_OWNER_PVT.ITEM_REC_TYPE; --INV_Item_GRP.Item_rec_type;
   x_error_tbl          AMS_ITEM_OWNER_PVT.Error_tbl_type; --INV_Item_GRP.Error_tbl_type;
   l_item_owner_rec     AMS_ITEM_OWNER_PVT.ITEM_OWNER_Rec_Type;

   l_qp_profile         varchar2(1) := FND_PROFILE.Value('AMS_QP_PRICING_CALLOUT');
   l_org_Id             NUMBER      := FND_PROFILE.Value('AMS_ITEM_ORGANIZATION_ID');

   x_item_return_status  Varchar2(1) ;
   x_item_owner_id       NUMBER;

BEGIN

   x_return_status := FND_API.g_ret_sts_success;
   -- Begin Inventory creation

   IF l_qp_profile IS NULL THEN
      l_qp_profile := 'N';
   END IF;


   IF (AMS_DEBUG_HIGH_ON) THEN
      AMS_Utility_PVT.debug_message(l_full_name ||' orgID:'||p_deliv_rec.inventory_item_org_id);
      AMS_Utility_PVT.debug_message(l_full_name ||' itemNumber:'||p_deliv_rec.item_number);
      AMS_Utility_PVT.debug_message(l_full_name ||' kitFlag:'||p_deliv_rec.kit_Flag);
      AMS_Utility_PVT.debug_message(l_full_name ||' Price Profile :'||l_qp_profile);
   END IF;

   IF (p_deliv_rec.item_number IS NULL
   OR p_deliv_rec.item_number = FND_API.g_miss_char)
   THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
      THEN
         FND_MESSAGE.set_name('AMS', 'AMS_DELIV_ENTER_PROPER_PARTNO');
         FND_MSG_PUB.add;
      END IF;
      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
   END IF;

   IF (l_org_Id IS NULL)
   THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
      THEN
         FND_MESSAGE.set_name('AMS', 'AMS_PROD_PROFILE_TIP');
         FND_MSG_PUB.add;
      END IF;
      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
   END IF;


   l_item_owner_rec.is_master_item := 'Y';
   l_item_owner_rec.owner_id := p_deliv_rec.owner_user_id;

   l_item_rec.item_number := p_deliv_rec.item_number;
   --l_item_rec.segment1 := 'DELIV'||p_deliv_rec.deliverable_id;
   l_item_rec.organization_id := FND_PROFILE.Value ('AMS_ITEM_ORGANIZATION_ID'); -- new org_id

   l_item_rec.description := 'DELIV-'||p_deliv_rec.deliverable_name;
   l_item_rec.long_description := 'DELIV-'||p_deliv_rec.description;
   l_item_rec.collateral_flag := 'Y';
   l_item_rec.costing_enabled_flag := 'Y';
   l_item_rec.customer_order_flag := 'Y';
   l_item_rec.customer_order_enabled_flag := 'Y';
   l_item_rec.shippable_item_flag := 'Y';

   IF (AMS_DEBUG_HIGH_ON)
   THEN
      AMS_Utility_PVT.debug_message(l_full_name ||' Cal  To Inv API ');
      AMS_Utility_PVT.debug_message(l_full_name ||' Org Id '||l_item_rec.organization_id);
      AMS_Utility_PVT.debug_message(l_full_name ||' Item Number '|| l_item_rec.item_number);
      AMS_Utility_PVT.debug_message(l_full_name ||'Desc '||l_item_rec.description );
   END IF;

   AMS_ITEM_OWNER_PVT.Create_item_owner(
       P_Api_Version_Number  =>   1.0,
       X_Return_Status       =>   x_return_status,
       X_Msg_Count           =>   x_msg_count,
       X_Msg_Data            =>   x_msg_data,
       P_ITEM_OWNER_Rec      =>   l_item_owner_rec,
       X_ITEM_OWNER_ID       =>   x_item_owner_id ,  ---  for create api
       P_ITEM_REC_In         =>   l_item_rec,
       P_ITEM_REC_Out        =>   x_item_rec,
       x_item_return_status  =>   x_item_return_status,
       x_Error_tbl           =>   x_error_tbl );

   /*
   INV_Item_GRP.Create_Item
   ( p_commit           =>     FND_API.g_false
   , p_validation_level =>     fnd_api.g_VALID_LEVEL_FULL
   , p_Item_rec         =>     l_item_rec
   , x_Item_rec         =>     x_item_rec
   , x_return_status    =>     x_return_status
   , x_Error_tbl        =>     x_error_tbl
   );

   */

   IF (AMS_DEBUG_HIGH_ON) THEN
   AMS_Utility_PVT.debug_message(l_full_name ||' Status of Inv API '||x_return_status);
   END IF;

   IF ( x_return_status <> FND_API.g_ret_sts_success
   OR  x_item_return_status <> FND_API.g_ret_sts_success )
   THEN
      RAISE inv_creation_error;
   ELSE
      x_inv_id := x_item_rec.inventory_item_id;
      x_org_id := x_item_rec.organization_id;
   END IF;

EXCEPTION
WHEN inv_creation_error THEN
   IF x_item_return_status <> FND_API.g_ret_sts_success
   THEN
      x_msg_count  := x_error_tbl.count;
      FOR i IN 1 .. x_error_tbl.count LOOP
         /*
         FND_MSG_PUB.count_and_get(
             p_encoded => FND_API.g_false,
             p_count   => x_msg_count,
             p_data    => x_error_tbl(i).message_text
          );  */
         IF x_error_tbl(i).message_name IS NOT NULL
         THEN
            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
            THEN
               FND_MESSAGE.set_name('INV', x_error_tbl(i).message_name);
               FND_MSG_PUB.add;
            END IF;
         END IF;
         IF (AMS_DEBUG_HIGH_ON) THEN

         AMS_Utility_PVT.debug_message(l_full_name ||'the error text is '||x_error_tbl(i).message_text);
         END IF;
      END LOOP;
   END IF;
   x_return_status := FND_API.g_ret_sts_error;
   RETURN;
END creat_inv_item;

-------------------------------------------------------------------
-- PROCEDURE
--    check_inactive_deliv
--
-- HISTORY
-- 02/25/2002 musman@us  Create
-------------------------------------------------------------------

PROCEDURE check_inactive_deliv
(
    p_deliv_rec      IN        deliv_rec_type,
    x_return_status  OUT NOCOPY       VARCHAR2
)IS



   CURSOR get_active_flag(deliv_id IN NUMBER)
   IS
   SELECT active_flag
   FROM ams_deliverables_all_b
   WHERE deliverable_id = deliv_id;

   l_active_flag VARCHAR2(1) := 'Y';

BEGIN

   x_return_status := FND_API.g_ret_sts_success;

   OPEN get_active_flag(p_deliv_rec.deliverable_id);
   FETCH get_active_flag INTO l_active_flag;
   CLOSE get_active_flag;

   IF l_active_flag = 'N'
   THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
      THEN
         FND_MESSAGE.set_name('AMS', 'AMS_DELIV_CANT_UPD_INACTIVE');
         FND_MSG_PUB.add;
      END IF;
      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
   END IF;

   IF (AMS_DEBUG_HIGH_ON) THEN



   AMS_UTILITY_PVT.debug_message('check budget lines is checked with no errors');

   END IF;

END check_inactive_deliv;

-------------------------------------------------------------------
-- PROCEDURE
--    check_inv_item
--
-- HISTORY
-- 02/25/2002 musman@us  Create
-------------------------------------------------------------------
PROCEDURE check_inv_item
(
    p_deliv_rec      IN    deliv_rec_type,
    x_return_status  OUT NOCOPY   VARCHAR2
 )
IS

   CURSOR get_flag(inv_id IN NUMBER
                  ,org_id IN NUMBER)
   IS
   SELECT collateral_flag
      ,costing_enabled_flag
      ,customer_order_flag
      ,customer_order_enabled_flag
      ,shippable_item_flag
   FROM mtl_system_items_b
   WHERE inventory_item_id = inv_id
   AND organization_id = org_id;

   l_flag_rec get_flag%ROWTYPE;

   l_active_flag VARCHAR2(1) := 'Y';

BEGIN

   x_return_status := FND_API.g_ret_sts_success;

   OPEN get_flag(p_deliv_rec.inventory_item_id,p_deliv_rec.inventory_item_org_id);
   FETCH get_flag INTO l_flag_rec;
   CLOSE get_flag;

   IF (p_deliv_rec.can_fulfill_electronic_flag) = 'N'
   THEN   /* this is reqd because for electronic delv picking up inv item only with collateral flag as 'Y' */

      IF l_flag_rec.collateral_flag = 'N'
      OR l_flag_rec.costing_enabled_flag = 'N'
      OR l_flag_rec.customer_order_flag = 'N'
      OR l_flag_rec.customer_order_enabled_flag = 'N'
      OR l_flag_rec.shippable_item_flag = 'N'
      THEN
         AMS_UTILITY_PVT.error_message('AMS_DELV_API_BAD_INV');
         --Program Error: Inventory item  passed to the API ,should hava the value set to "Y" for the following flags collateral_flag
         --,costing_enabled_flag,customer_order_flag,customer_order_enabled_flag,shippable_item_flag.
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   ELSE
      IF l_flag_rec.collateral_flag = 'N'
      THEN
         AMS_UTILITY_PVT.error_message('AMS_DELV_API_BAD_INV_COLL');
         --Program Error: Inventory item  passed to the API ,should have the value set to "Y" for collateral_flag
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;


   IF (AMS_DEBUG_HIGH_ON) THEN
   AMS_UTILITY_PVT.debug_message('check inv item is checked with no errors');
   END IF;

END check_inv_item;


END AMS_Deliverable_PVT;

/
