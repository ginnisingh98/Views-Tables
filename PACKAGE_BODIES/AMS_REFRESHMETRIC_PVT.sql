--------------------------------------------------------
--  DDL for Package Body AMS_REFRESHMETRIC_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_REFRESHMETRIC_PVT" AS
/* $Header: amsvmrsb.pls 120.5 2006/02/09 17:29:23 rmajumda ship $ */
--------------------------------------------------------------------------------
--
-- NAME
--    AMS_refreshMetric_PVT for 11.5.6
--
-- HISTORY
-- 19-Oct-1999  ptendulk@us  Created
-- 27-FEB-2000  bgeorge      Modified to call the trigger API for metrics
--                           refresh in the copy_seeded_metrics
-- 05/08/2000   BGEORGE      a. added proc to be called from CC
--                           b. commented call to create triggers
--                           c. added call to check object attribute
-- 07/17/2000     khung      bug 1356700 fix. add check category_id in
--                           copy_seeded_metric
-- 08/17/2000     sveerave   Included procedure to associate metrics for the
--                           dependent objects in the parent object
-- 10/11/2000     SVEERAVE   Removed Init_ActMetric_Rec from here and placed
--                           in AMS_ACTMETRICS_PVT
-- 02/12/2001    dmvincen    BUG# 1603925
--                           Fixed create_refresh_parent_level to only
--                           invalidate the parent on refresh.  And fixed
--                           some code hierarchies to match levels for
--                           easier reading.
-- 04/04/2001    dmvincen    Call new metrics engine for rollup.
-- 04/30/2001    dmvincen    Rollup Changes #1753241
-- 06/14/2001    huili       Set values for "VARIABLE" metrics to 0 since it not
--                           supported by 11.5.5
-- 06/19/2001    huili       Comment out the "create_refresh_assoc_metrics"
--                           call in the "Refresh_Metric" module.
-- 06/27/2001    huili       Added calculation for forecasted value.
-- 06/29/2001    dmvincen    Generate Rollups even if no dirty flags set.
-- 06/29/2001    dmvincen    Rollup and Summarize only using activity metric ids
-- 07/02/2001    huili       Adjust the "arc_act_metric_used_by" field while
--                           creating parent activity metrics.
-- 08/07/2001    huili       Remove rollup from a "Deliverable" to other business object.
-- 08/16/2001    dmvincen    BUG# 1868868: Only rollup cancel objects if actual
--                           values have been accrued.
-- 08/16/2001    dmvincen    Ensure only same currencies are being added up.
--                           Set the functional currencies to the default.
-- 08/31/2001    huili       Added the "Exec_Procedure" function.
-- 10/10/2001    huili       Added fix for checking the function_type.
-- 10/24/2001    dmvincen    Fixed logic for checking cancelled objects.
-- 12/24/2001    dmvincen    Uncommented create_refresh_assoc_metric, and fixed
--                           cursor leaks. (Merged from 11.5.4.07E)
-- 15-Jan-2002   huili        Added the "p_update_history" to the
--                            "Refresh_Act_metrics" module.
-- 02/26/2002    dmvincen    New Feature: Modify the Copy_Seeded_metrics to
--                           utilize new metric template structures.
-- 03/27/2002    dmvincen    Added support for dialogs and components to
--                           Copy_Seeded_Metrics.
-- 03/28/2002    dmvincen    Dialog refresh must refresh all components.
-- 03/28/2002    dmvincen    Call procedures for dialog NOT components.
-- 06/13/2002    dmvincen    BUG2385692: Fixed function metric update.
-- 17-Sep-2003   sunkumar    Object level locking introduced
-- 09-Feb-2004   dmvincen    Copy_seeded_metrics includes 'ANY' object type.
-- 21-Nov-2005   dmvincen    BUG4742384: Copy by fixed then variable.
--
------------------------------------------------------------------------------
--
-- Global variables and constants.
G_PKG_NAME CONSTANT VARCHAR2(30) := 'AMS_REFRESHMETRIC_PVT'; -- Name of the current package.
G_DEBUG_FLAG VARCHAR2(1)  := 'N';

-- Forward Declarations Begin
AMS_DEBUG_HIGH_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

-- Forward Declaration for Calculate_Metric as it is removed from specs, SVEERAVE, 10/19/00
PROCEDURE Calculate_Metric (
   p_api_version                 IN    NUMBER,
   p_init_msg_list               IN    VARCHAR2 := Fnd_Api.G_FALSE,
   p_commit                      IN    VARCHAR2 := Fnd_Api.G_FALSE,
   x_return_status               OUT   NOCOPY VARCHAR2,
   x_msg_count                   OUT   NOCOPY NUMBER,
   x_msg_data                    OUT   NOCOPY VARCHAR2,
   p_activity_metric_id          IN    NUMBER,
--   p_act_metric_used_by_id       IN    NUMBER,
--   p_arc_act_metric_used_by      IN    VARCHAR2,
--   p_act_metric_uom_code         IN    VARCHAR2,
   x_actual_value                OUT   NOCOPY NUMBER,
   x_forecasted_value            OUT   NOCOPY NUMBER,
   p_refresh_function            IN    VARCHAR2 := Fnd_Api.G_TRUE,
   p_func_currency_code          IN    VARCHAR2);

PROCEDURE Exec_Procedure (
   p_arc_act_metric_used_by   IN VARCHAR2,
   p_act_metric_used_by_id    IN NUMBER,
   p_function_name            IN VARCHAR2
);

PROCEDURE Run_Object_Procedures (
   p_arc_act_metric_used_by   IN VARCHAR2,
   p_act_metric_used_by_id    IN NUMBER);

/**
 Commenting out dialog related packages since Dialog Objects
 are obsolete.

PROCEDURE Refresh_Components(
   p_api_version                 IN     NUMBER,
   p_init_msg_list               IN     VARCHAR2 := Fnd_Api.G_TRUE,
   p_commit                      IN     VARCHAR2 := Fnd_Api.G_FALSE,
   x_return_status               OUT    NOCOPY VARCHAR2,
   x_msg_count                   OUT    NOCOPY NUMBER,
   x_msg_data                    OUT    NOCOPY VARCHAR2,
   p_arc_act_metric_used_by      IN     VARCHAR2,
   p_act_metric_used_by_id       IN     NUMBER,
   p_refresh_function            IN     VARCHAR2 := Fnd_Api.G_TRUE
);
**/
-- NAME
--    create_refresh_parent_level
--
-- PURPOSE
-- procedure below checks for the existence of the
-- rollup metrics at the parent Marketing entity level
-- if this is not existing a new row is created in the
-- ams_act_metrics_all and also calls refresh for the
-- parent entity..
--
-- NOTES
--
-- HISTORY
-- 08/14/2000  bgeorge    Created.
-- 02/12/2001  dmvincen   This function now only invalidates the parent.
--
PROCEDURE  create_refresh_parent_level (
        p_activity_metric_id IN NUMBER,
        p_metric_id IN NUMBER,
        p_act_metric_used_by_id IN NUMBER,
        p_arc_act_metric_used_by IN VARCHAR2,
        p_dirty IN VARCHAR2
--        p_func_actual_value IN NUMBER,
--        p_func_forecasted_value IN  NUMBER
)
IS

   --Check if the metric has a rollup parent defined.
   CURSOR c_check_parent(l_metric_id NUMBER) IS
      SELECT metric_parent_id
      FROM ams_metrics_all_b
      WHERE metric_id = l_metric_id;
   l_metric_parent_id NUMBER;

   --check for the parent campaign
   CURSOR c_check_parent_campaign(l_act_metric_used_by_id NUMBER) IS
      SELECT parent_campaign_id
      FROM ams_campaigns_all_b
      WHERE campaign_id = l_act_metric_used_by_id;

   --check for the parent event
   CURSOR c_check_parent_event(l_act_metric_used_by_id NUMBER) IS
      SELECT event_header_id
      FROM ams_event_offers_all_b
      WHERE event_offer_id = l_act_metric_used_by_id;
   l_parent_obj NUMBER;

   -- 06/24/2001 huili added
   --check for the parent event
   CURSOR c_check_parent_event_o(l_act_metric_used_by_id NUMBER) IS
      SELECT event_header_id
      FROM ams_event_offers_all_b
      WHERE event_offer_id = l_act_metric_used_by_id;

   --check for the parent event
   CURSOR c_check_parent_event_h(l_act_metric_used_by_id NUMBER) IS
      SELECT parent_event_header_id
      FROM ams_event_headers_all_b
      WHERE event_header_id = l_act_metric_used_by_id;

   -- 06/23/2001 huili changed the "c_check_event_camp"
   -- 06/07/2001 huili added two cursors
   --check another type of parent event: execution campaign
   CURSOR c_check_event_camp (l_act_metric_used_by_id NUMBER) IS
      SELECT program_id
      FROM ams_event_headers_all_b
      WHERE event_header_id = l_act_metric_used_by_id;

   CURSOR c_check_camp_type (l_camp_id NUMBER) IS
      SELECT rollup_type
      FROM ams_campaigns_all_b
      WHERE campaign_id = l_camp_id;

   -- 06/23/2001 huili added
   --check the parent campaign for schedule
   CURSOR c_check_parent_schedule (l_act_metric_used_by_id NUMBER) IS
      SELECT campaign_id
      FROM ams_campaign_schedules_b
      WHERE schedule_id = l_act_metric_used_by_id;

   CURSOR c_check_parent_one_event(l_act_metric_used_by_id NUMBER) IS
      SELECT parent_id
      FROM ams_event_offers_all_b
      WHERE event_offer_id = l_act_metric_used_by_id
      AND parent_type = 'RCAM';
   -- END

   -- check if act_metrics exists
   CURSOR c_verify_act_metric(l_metric_parent_id NUMBER,
      l_obj_id NUMBER,
      l_obj_code VARCHAR2) IS
      SELECT activity_metric_id
      FROM ams_act_metrics_all
      WHERE metric_id = l_metric_parent_id
      AND act_metric_used_by_id = l_obj_id
      AND arc_act_metric_used_by = l_obj_code;

   l_parent_obj_code VARCHAR2(30) := p_arc_act_metric_used_by;
   l_act_flag NUMBER :=0;
   l_act_metrics_rec Ams_Actmetric_Pvt.act_metric_rec_type;
   l_return_status VARCHAR2(1);
   l_msg_count NUMBER;
   l_msg_data  VARCHAR2(2000);
   l_act_met_id NUMBER;
   l_is_locked varchar2(1);

BEGIN

    SAVEPOINT create_refresh_parent_sp;

   OPEN c_check_parent(p_metric_id);
   FETCH c_check_parent INTO l_metric_parent_id;
   CLOSE c_check_parent;

   l_parent_obj := NULL;
   l_parent_obj_code := NULL;

   -- 06/24/2001 huili changed to add new hierarchy
   IF l_metric_parent_id IS NOT NULL THEN
      -- campaign/program to program
      IF p_arc_act_metric_used_by IN ('CAMP', 'RCAM' ) THEN
         OPEN c_check_parent_campaign(p_act_metric_used_by_id);
         FETCH c_check_parent_campaign INTO l_parent_obj;
         CLOSE c_check_parent_campaign;
         l_parent_obj_code := 'RCAM';
      -- schedule to campaign
      ELSIF p_arc_act_metric_used_by = 'CSCH' THEN
         OPEN c_check_parent_schedule (p_act_metric_used_by_id);
         FETCH c_check_parent_schedule INTO l_parent_obj;
         CLOSE c_check_parent_schedule;
         l_parent_obj_code := 'CAMP';
      -- Event Schedule to Event
      ELSIF p_arc_act_metric_used_by = 'EVEO' THEN
         OPEN c_check_parent_event_o (p_act_metric_used_by_id);
         FETCH c_check_parent_event_o INTO l_parent_obj;
         CLOSE c_check_parent_event_o;
         l_parent_obj_code := 'EVEH';
      -- Event to Program
      ELSIF p_arc_act_metric_used_by = 'EVEH' THEN
         OPEN c_check_event_camp (p_act_metric_used_by_id);
         FETCH c_check_event_camp INTO l_parent_obj;
         CLOSE c_check_event_camp;
         IF l_parent_obj IS NOT NULL THEN
           l_parent_obj_code := 'RCAM';
         END IF;
      -- One Off Event to Program
      ELSIF p_arc_act_metric_used_by = 'EONE' THEN
         OPEN c_check_parent_one_event (p_act_metric_used_by_id);
         FETCH c_check_parent_one_event INTO l_parent_obj;
         CLOSE c_check_parent_one_event;
         l_parent_obj_code := 'RCAM';
      ELSE
         RETURN;
      END IF;

      IF l_parent_obj IS NOT NULL THEN
       l_is_locked := ams_actmetric_pvt.lock_object(
            p_api_version            => 1 ,
            p_init_msg_list          => Fnd_Api.G_FALSE,
            p_arc_act_metric_used_by => l_parent_obj_code,
            p_act_metric_used_by_id  => l_parent_obj,
            x_return_status         => l_return_status,
            x_msg_count             => l_msg_count,
            x_msg_data              => l_msg_data);

         IF l_return_status = Fnd_Api.G_RET_STS_ERROR THEN
            RAISE Fnd_Api.G_EXC_ERROR;
         ELSIF l_return_status = Fnd_Api.G_RET_STS_UNEXP_ERROR THEN
            RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
         elsif l_is_locked = FND_API.G_FALSE THEN
            -- the object needs to be lock by this process.
            RAISE ams_utility_pvt.resource_locked;
         END IF;


         OPEN c_verify_act_metric(l_metric_parent_id,
                 l_parent_obj, l_parent_obj_code);
         FETCH c_verify_act_metric INTO l_act_met_id;

         IF c_verify_act_metric%NOTFOUND
            -- AND (l_parent_obj IS NOT NULL)
            THEN
            l_act_metrics_rec.act_metric_used_by_id := l_parent_obj;
            l_act_metrics_rec.arc_act_metric_used_by := l_parent_obj_code;
            l_act_metrics_rec.metric_id := l_metric_parent_id;
            l_act_metrics_rec.func_actual_value := NULL; --p_func_actual_value;
            l_act_metrics_rec.func_forecasted_value := NULL; --p_func_forecasted_value;
            l_act_metrics_rec.application_id := 530;
            Ams_Actmetric_Pvt.Create_ActMetric (
               p_api_version                => 1.0,
               p_act_metric_rec             => l_act_metrics_rec,
               x_return_status              => l_return_status,
               x_msg_count                  => l_msg_count,
               x_msg_data                   => l_msg_data,
               x_activity_metric_id       => l_act_met_id);

            IF l_return_status = Fnd_Api.G_RET_STS_ERROR THEN
               RAISE Fnd_Api.G_EXC_ERROR;
            ELSIF l_return_status = Fnd_Api.G_RET_STS_UNEXP_ERROR THEN
               RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
            END IF;

         -- DMVINCEN: After selecting the primary key this is not null.
         -- ELSIF l_act_met_id is NOT NULL
         -- THEN -- IF c_verify_act_metric%NOTFOUND  THEN
         ELSE
            IF p_dirty = 'Y' THEN
               -- 02/12/2001 dmvincen - make the parent metric dirty
               -- but do not refresh the data.
               Ams_Actmetric_Pvt.Make_actmetric_dirty(l_act_met_id);
            END IF;

            IF l_return_status = Fnd_Api.G_RET_STS_ERROR THEN
               RAISE Fnd_Api.G_EXC_ERROR;
            ELSIF l_return_status = Fnd_Api.G_RET_STS_UNEXP_ERROR THEN
               RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
            END IF;

         END IF;  -- IF c_verify_act_metric%NOTFOUND  THEN
         CLOSE c_verify_act_metric;

         -- DMVINCEN 04/30/2001: update the rollup to field.
         UPDATE ams_act_metrics_all
            SET rollup_to_metric = l_act_met_id
            WHERE activity_metric_id = p_activity_metric_id;

      END IF; -- parent_obj not null
   END IF;  --IF l_metric_parent_id <> 0 THEN

exception
   when others then
      rollback to create_refresh_parent_sp;
      raise;

END create_refresh_parent_level;

-- NAME
--     refresh_assoc_metrics
--
-- PURPOSE
--   The procedure will refresh(create or update) act metrics for the master
--   object depending upon association objects.
--   If there are any dependent objects for a master object, and these
--   dependent objects have any top level metrics, this procedure creates or
--   refreshes the association metric for the master object.
--
-- NOTES
--   Tables used: ams_object_associations,ams_metric_accruals,ams_act_metrics_all
--   This algorithm is driven on ams_metric_accruals table.
-- HISTORY
-- 10/04/2000   sveerave         Created.
-- 08/16/2001   dmvincen  Not all cursors were being closed.

PROCEDURE refresh_assoc_metrics ( p_accr_met_acc_id NUMBER,
                                  p_master_obj_id NUMBER,
                                  p_master_obj_type VARCHAR2
)
IS

   -- Get accrual metric details
   CURSOR c_get_accr_met_details(l_accr_met_acc_id NUMBER) IS
           SELECT using_object, used_object, metric_id, metric_type_id
           FROM ams_metric_accruals
           WHERE ams_metric_acc_id = l_accr_met_acc_id;
   l_accr_met_rec  c_get_accr_met_details%ROWTYPE;
   l_accr_found  VARCHAR2(1) := Fnd_Api.G_FALSE;

   --Get top level metrics details for the child object.
   CURSOR c_get_child_summary_metrics(l_master_obj_type VARCHAR2,
                            l_master_obj_id NUMBER,
                           l_metric_type_id NUMBER)IS
      SELECT actmet.activity_metric_id,
             actmet.metric_id,
             actmet.func_actual_value,
             actmet.func_forecasted_value,
             actmet.functional_currency_code,
             objassoc.object_association_id
        FROM ams_act_metrics_all actmet,
             ams_metrics_all_b met,
             ams_object_associations objassoc
       WHERE actmet.metric_id = met.metric_id
         AND objassoc.master_object_type = l_master_obj_type
         AND objassoc.master_object_id = l_master_obj_id
         AND actmet.act_metric_used_by_id = objassoc.using_object_id
         AND actmet.arc_act_metric_used_by = objassoc.using_object_type
         AND met.metric_category = l_metric_type_id
         AND met.summary_metric_id IS NULL;

   l_child_summary_actmet_rec      c_get_child_summary_metrics%ROWTYPE;
--Check whether there is already an instance is existing for the
   --accrual metric in the parent object metrics.
   CURSOR c_get_master_accrual_actmet(l_master_object_type    VARCHAR2,
                                   l_master_object_id      NUMBER,
                                   l_metric_id     NUMBER) IS
      SELECT  activity_metric_id
        FROM ams_act_metrics_all
       WHERE arc_act_metric_used_by = l_master_object_type
         AND act_metric_used_by_id = l_master_object_id
         AND metric_id = l_metric_id;
   l_master_found VARCHAR2(1) := Fnd_Api.G_FALSE;
   l_sum_forecasted_value  NUMBER;
   l_sum_actual_value      NUMBER;
   l_refresh               VARCHAR2(1) := 'N';
   l_default_currency      VARCHAR2(15) := Ams_Actmetric_Pvt.Default_Func_Currency;
   l_act_metric_id         NUMBER;
   l_act_metric_rec        Ams_Actmetric_Pvt.act_metric_rec_type;
   l_return_status         VARCHAR2(1);
   l_msg_count             NUMBER;
   l_msg_data              VARCHAR2(2000);
   l_current_date  DATE := SYSDATE;

BEGIN


   -- get accrual metric details
   OPEN c_get_accr_met_details(p_accr_met_acc_id);
   FETCH c_get_accr_met_details INTO l_accr_met_rec;
   IF c_get_accr_met_details%FOUND THEN
      l_accr_found := Fnd_Api.G_TRUE;
   END IF;
   CLOSE c_get_accr_met_details;
   IF l_accr_found = Fnd_Api.G_TRUE THEN
      -- initialize the sum values;
      l_sum_actual_value := 0;
      l_sum_forecasted_value := 0;
      -- get toplevel metric for one or more child objects
      OPEN c_get_child_summary_metrics(p_master_obj_type, p_master_obj_id,
                                       l_accr_met_rec.metric_type_id);
      LOOP
         FETCH c_get_child_summary_metrics INTO l_child_summary_actmet_rec;
         EXIT WHEN c_get_child_summary_metrics%NOTFOUND;
         l_refresh := 'Y';
         -- do currency conversions if any
         IF l_child_summary_actmet_rec.functional_currency_code IS NOT NULL AND
            l_child_summary_actmet_rec.functional_currency_code <>
                l_default_currency THEN
            -- Convert currency into default currency
            IF NVL(l_child_summary_actmet_rec.func_actual_value,0) <> 0 OR
               NVL(l_child_summary_actmet_rec.func_forecasted_value,0) <> 0 THEN
               Ams_Actmetric_Pvt.CONVERT_CURRENCY2 (
                  x_return_status => l_return_status,
                  p_from_currency => l_child_summary_actmet_rec.functional_currency_code,
                  p_to_currency   => l_default_currency,
                  p_conv_date     => l_current_date,
                  p_from_amount   => l_child_summary_actmet_rec.func_actual_value,
                  x_to_amount     => l_child_summary_actmet_rec.func_actual_value,
                  p_from_amount2  => l_child_summary_actmet_rec.func_forecasted_value,
                  x_to_amount2    => l_child_summary_actmet_rec.func_forecasted_value,
                  p_round         => Fnd_Api.G_FALSE);
            END IF;
         END IF; -- IF (l_child_summary_actmet_rec.transaction_currency_code IS NOT NULL) AND
         l_sum_actual_value := l_sum_actual_value +
                               l_child_summary_actmet_rec.func_actual_value;
         l_sum_forecasted_value := l_sum_forecasted_value +
                               l_child_summary_actmet_rec.func_forecasted_value;
      END LOOP;
      CLOSE c_get_child_summary_metrics;

      IF l_refresh = 'Y' THEN
         OPEN c_get_master_accrual_actmet( p_master_obj_type, p_master_obj_id,
            l_accr_met_rec.metric_id);
         FETCH c_get_master_accrual_actmet INTO l_act_metric_id;
         IF c_get_master_accrual_actmet%FOUND THEN
            l_master_found := Fnd_Api.G_TRUE;
         END IF;
         CLOSE c_get_master_accrual_actmet;
         IF l_master_found = Fnd_Api.G_TRUE THEN
            -- Update the accrual metrics's VALUES FROM child object's summary level metric
            -- Initialize the record type for Activity Metric update
            Ams_Actmetric_Pvt.Init_ActMetric_Rec(x_act_metric_rec => l_act_metric_rec );
            l_act_metric_rec.activity_metric_id  := l_act_metric_id;
            l_act_metric_rec.func_actual_value  := l_sum_actual_value;
            l_act_metric_rec.func_forecasted_value  := l_sum_forecasted_value;
            l_act_metric_rec.trans_actual_value := NULL;
            l_act_metric_rec.trans_forecasted_value := NULL;
            IF l_accr_met_rec.metric_type_id IN (901,902) THEN
               l_act_metric_rec.functional_currency_code := l_default_currency;
            ELSE
               l_act_metric_rec.functional_currency_code := NULL;
            END IF;
            Ams_Actmetric_Pvt.update_actmetric (
                    p_api_version                => 1.0,
                    p_commit                     => Fnd_Api.G_FALSE,
                    p_validation_level           => Fnd_Api.g_valid_level_full,
                    p_act_metric_rec             => l_act_metric_rec,
                    x_return_status              => l_return_status,
                    x_msg_count                  => l_msg_count,
                    x_msg_data                   => l_msg_data);

            IF l_return_status = Fnd_Api.G_RET_STS_ERROR THEN
               IF(l_msg_count > 0) THEN
                  FOR i IN 1 .. l_msg_count
                  LOOP
                     l_msg_data := Fnd_Msg_Pub.get(i, Fnd_Api.g_false);
                  END LOOP;
               END IF;
               RAISE Fnd_Api.G_EXC_ERROR;
            ELSIF l_return_status = Fnd_Api.G_RET_STS_UNEXP_ERROR THEN
               RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
            END IF; -- for IF l_return_status = FND_API.G_RET_STS_ERROR
         ELSE -- for c_get_master_accrual_actmet%FOUND

            --Create the instance of accrual metric in the master object metrics.
            l_act_metric_rec.act_metric_used_by_id := p_master_obj_id;
            l_act_metric_rec.arc_act_metric_used_by := p_master_obj_type;
            l_act_metric_rec.metric_id := l_accr_met_rec.metric_id;
            l_act_metric_rec.func_actual_value  := l_sum_actual_value;
            l_act_metric_rec.func_forecasted_value  := l_sum_forecasted_value;
            l_act_metric_rec.sensitive_data_flag := 'N';
            l_act_metric_rec.application_id:=530;
            l_act_metric_rec.activity_metric_origin_id :=
                  l_child_summary_actmet_rec.object_association_id;
            IF l_accr_met_rec.metric_type_id IN (901,902) THEN
               l_act_metric_rec.functional_currency_code := l_default_currency;
            ELSE
               l_act_metric_rec.functional_currency_code := NULL;
            END IF;
            Ams_Actmetric_Pvt.Create_ActMetric (
               p_api_version     => 1.0,
               p_act_metric_rec  => l_act_metric_rec,
               x_return_status   => l_return_status,
               x_msg_count       => l_msg_count,
               x_msg_data        => l_msg_data,
               x_activity_metric_id => l_act_metric_id);
            IF l_return_status = Fnd_Api.G_RET_STS_ERROR THEN
               IF l_msg_count > 0 THEN
                  FOR i IN 1 .. l_msg_count
                  LOOP
                     l_msg_data := Fnd_Msg_Pub.get(i, Fnd_Api.g_false);
                  END LOOP;
               END IF;
               RAISE Fnd_Api.G_EXC_ERROR;
            ELSIF l_return_status = Fnd_Api.G_RET_STS_UNEXP_ERROR THEN
               RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
            END IF; -- for IF l_return_status = FND_API.G_RET_STS_ERROR
         END IF; -- for c_get_master_accrual_actmet%FOUND
      END IF; -- for   IF l_refresh = 'Y'
   END IF; --for IF c_get_accr_met_details%FOUND

END refresh_assoc_metrics;

-- NAME
--     create_refresh_assoc_metrics
--
-- PURPOSE
--   The procedure will handle metrics for association objects.
--   If there are any dependent objects for a master object, and these
--   dependent objects have any top level metrics, this procedure creates
--   or refreshes the association metric for the master object.
--
-- NOTES
--   Tables used: ams_object_associations,ams_metric_accruals,ams_metrics_all_b,ams_act_metrics_all
--   This procedure is called in Refresh_metrics for each distinct combination
--   of parent_object_id, parent_object_type
--   This method only creates act metric accruals and calls
--   refresh_assoc_metrics for creation/update of activity metrics.
-- HISTORY
-- 08/15/2000   sveerave Created.
-- 10/03/2000   SVEERAVE Modified to refresh correctly if there are multiple
--                       child objects for master object.
-- 10/04/2000   SVEERAVE separated refresh algorithm into refresh_assoc_metrics.
PROCEDURE  create_refresh_assoc_metrics(
                                p_master_object_type IN VARCHAR2,
                                p_master_object_id IN NUMBER)
IS
   --Get associated child objects for the parent object.
   CURSOR c_get_child_objects (l_master_object_type VARCHAR2,
                               l_master_object_id NUMBER) IS
      SELECT object_association_id,
              using_object_type child_object_type,
              using_object_id  child_object_id
      FROM ams_object_associations
      WHERE master_object_type = l_master_object_type
        AND master_object_id = l_master_object_id;

   l_child_obj_rec         c_get_child_objects%ROWTYPE;

   --Get top level metrics details for the child object.
   CURSOR c_get_child_summary_metrics(     l_child_object_type VARCHAR2,
                                l_child_object_id NUMBER)IS
      SELECT actmet.activity_metric_id child_actmet_id,
         met.metric_category child_metric_type_id ,
         actmet.metric_id child_metric_id,
         met.value_type child_met_value_type
      FROM ams_act_metrics_all actmet, ams_metrics_all_b met
      WHERE actmet.arc_act_metric_used_by = l_child_object_type
        AND actmet.act_metric_used_by_id = l_child_object_id
        AND met.summary_metric_id IS NULL
        AND actmet.metric_id = met.metric_id;

   l_child_summary_actmet_rec      c_get_child_summary_metrics%ROWTYPE;

   --Get top level metrics details for the parent object.
   CURSOR c_get_parent_summary_metrics(    l_master_object_type VARCHAR2,
                                l_master_object_id NUMBER,
                                l_metric_type_id NUMBER) IS
      SELECT activity_metric_id  parent_summary_actmet_id,
               met.metric_id  parent_summary_met_id
      FROM ams_act_metrics_all actmet, ams_metrics_all_b met
      WHERE actmet.metric_id = met.metric_id
        AND arc_act_metric_used_by = l_master_object_type
        AND act_metric_used_by_id = l_master_object_id
        AND metric_category = l_metric_type_id
        AND metric_calculation_type = 'SUMMARY'
        AND summarize_to_metric IS NULL;

   l_parent_summary_actmet_rec     c_get_parent_summary_metrics%ROWTYPE;

   --Check whether any metric is registered with the master_object type,
   -- child_object_type, metric_type, and get its metric_id
   CURSOR c_get_metric_accrual(    l_master_object_type VARCHAR2,
                                l_child_object_type VARCHAR2,
                                l_metric_type_id        NUMBER) IS
      SELECT accr.ams_metric_acc_id
      FROM ams_metric_accruals accr, ams_metrics_all_b met
      WHERE accr.using_object = l_master_object_type
         AND accr.used_object = l_child_object_type
         AND accr.metric_type_id = l_metric_type_id
         AND accr.metric_id = met.metric_id;
   --    AND met.enabled_flag = 'Y';
   l_metric_accr_found VARCHAR2(1) := Fnd_Api.G_FALSE;

   -- Get category name when id is passed
   CURSOR c_get_category_name(l_category_id NUMBER) IS
      SELECT category_name
      FROM ams_categories_vl
      WHERE category_id = l_category_id;

   CURSOR c_next_metric_accrual_id IS
      SELECT ams_metric_accruals_s.NEXTVAL
      FROM dual;

   l_act_metric_rec        Ams_Actmetric_Pvt.act_metric_rec_type;
   l_metric_rec            Ams_Metric_Pvt.metric_rec_type;
   l_accrual_metric_id     NUMBER;
   l_category_name         VARCHAR2(120);
   l_object_type_meaning   VARCHAR2(80);
   l_return_status         VARCHAR2(1);
   l_msg_count             NUMBER;
   l_msg_data              VARCHAR2(2000);
   l_act_metric_id         NUMBER;
   l_flag                  NUMBER := 0;
   l_metric_id               NUMBER;

BEGIN

   -- Get all the objects associated with the master object that was sent
   -- in the call-out
   OPEN c_get_child_objects(p_master_object_type, p_master_object_id);
   LOOP

      FETCH c_get_child_objects INTO l_child_obj_rec;

      EXIT WHEN c_get_child_objects%NOTFOUND;
      -- Get top level metric type for the child object.
      OPEN c_get_child_summary_metrics(l_child_obj_rec.child_object_type,
                              l_child_obj_rec.child_object_id);
      LOOP

         FETCH c_get_child_summary_metrics INTO  l_child_summary_actmet_rec;

         EXIT WHEN c_get_child_summary_metrics%NOTFOUND;
         OPEN c_get_metric_accrual(p_master_object_type,
                              l_child_obj_rec.child_object_type,
                              l_child_summary_actmet_rec.child_metric_type_id);
         FETCH c_get_metric_accrual INTO l_accrual_metric_id;

         IF c_get_metric_accrual%FOUND  THEN
            l_metric_accr_found := Fnd_Api.G_TRUE;
         END IF;
         CLOSE c_get_metric_accrual;
         IF l_metric_accr_found = Fnd_Api.G_FALSE THEN
            -- Create new accrual metric in metrics table and register it in
            -- ams_metric_accruals populate accrual metric name as child
            -- object name + - + metrics type get metric type name from
            -- the category id
            OPEN c_get_category_name(
                            l_child_summary_actmet_rec.child_metric_type_id);
            FETCH c_get_category_name INTO l_category_name;
            CLOSE c_get_category_name;
            l_category_name := SUBSTR(l_category_name,1,85);
            --Get meaning for the child object type
            l_object_type_meaning :=
                  Ams_Utility_Pvt.get_lookup_meaning('AMS_SYS_ARC_QUALIFIER',
                              l_child_obj_rec.child_object_type);
            l_object_type_meaning := SUBSTR(l_object_type_meaning,1,30);
            -- Assign values to the accrual metric that is being created
            l_metric_rec.metrics_name :=
                              l_object_type_meaning||'-'||l_category_name;
            l_metric_rec.description :=
                              l_object_type_meaning||'-'||l_category_name;
            l_metric_rec.arc_metric_used_for_object := p_master_object_type;
            l_metric_rec.metric_calculation_type := 'ROLLUP';
            l_metric_rec.metric_category :=
                              l_child_summary_actmet_rec.child_metric_type_id;
            l_metric_rec.accrual_type := 'FIXED';
            l_metric_rec.application_id     := 530;
            l_metric_rec.sensitive_data_flag := 'N';
            l_metric_rec.enabled_flag := 'Y';
            -- assign value_type as the child object's metric
            l_metric_rec.value_type :=
                              l_child_summary_actmet_rec.child_met_value_type;
            --summary_metric_id to be that of the master object's metric_id
            OPEN c_get_parent_summary_metrics(p_master_object_type,
                             p_master_object_id,
                             l_child_summary_actmet_rec.child_metric_type_id);
            FETCH c_get_parent_summary_metrics
               INTO l_parent_summary_actmet_rec;
            IF c_get_parent_summary_metrics%FOUND THEN
               l_metric_rec.summary_metric_id :=
                            l_parent_summary_actmet_rec.parent_summary_met_id;
            ELSE
               l_metric_rec.summary_metric_id := NULL;
            END IF;
            CLOSE c_get_parent_summary_metrics;

            Ams_Metric_Pvt.Create_Metric(
                    p_api_version   => 1.0,
                    p_init_msg_list => Fnd_Api.G_TRUE,
                    x_return_status => l_return_status,
                    x_msg_count     => l_msg_count,
                    x_msg_data      => l_msg_data,
                    p_metric_rec    => l_metric_rec,
                    x_metric_id     => l_metric_id);

            IF l_return_status = Fnd_Api.G_RET_STS_ERROR THEN
               IF l_msg_count > 0 THEN
                  FOR i IN 1 .. l_msg_count
                  LOOP
                     l_msg_data := Fnd_Msg_Pub.get(i, Fnd_Api.g_false);
                  END LOOP;
               END IF;
               --CLOSE c_get_metric_accrual;
               CLOSE c_get_child_summary_metrics;
               CLOSE c_get_child_objects;
               RAISE Fnd_Api.G_EXC_ERROR;
            ELSIF l_return_status = Fnd_Api.G_RET_STS_UNEXP_ERROR THEN
               --CLOSE c_get_metric_accrual;
               CLOSE c_get_child_summary_metrics;
               CLOSE c_get_child_objects;
               RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
            END IF;

            OPEN c_next_metric_accrual_id;
            FETCH c_next_metric_accrual_id INTO l_accrual_metric_id;
            CLOSE c_next_metric_accrual_id;

            -- Register the metric in ams_metric_accruals by creating a row.
            INSERT INTO ams_metric_accruals(
                    AMS_METRIC_ACC_ID,
                    LAST_UPDATE_DATE,
                    LAST_UPDATED_BY,
                    CREATION_DATE,
                    CREATED_BY,
                    LAST_UPDATE_LOGIN,
                    OBJECT_VERSION_NUMBER,
                    USING_OBJECT,
                    USED_OBJECT,
                    METRIC_ID,
                    METRIC_TYPE_ID)
            VALUES(
                    l_accrual_metric_id,
                    SYSDATE,
                    Fnd_Global.User_ID,
                    SYSDATE,
                    Fnd_Global.User_ID,
                    Fnd_Global.Conc_Login_ID,
                    1,
                    p_master_object_type,
                    l_child_obj_rec.child_object_type,
                    l_metric_id,
                    l_child_summary_actmet_rec.child_metric_type_id);

         END IF; -- for c_get_metric_accrual%NOTFOUND
         refresh_assoc_metrics(l_accrual_metric_id,
                         p_master_object_id,p_master_object_type);
         --CLOSE c_get_metric_accrual;
      END LOOP;
      -- inside c_get_child_summary_metrics
      CLOSE c_get_child_summary_metrics;
   END LOOP; -- inside c_get_child_objects
   CLOSE c_get_child_objects;
END create_refresh_assoc_metrics;

-- NAME
--    GetMetricCatVal
--
-- PURPOSE
--   Return the functional forecasted value, committed value, actual
--   value depending on Return type for a given metric.
--
-- NOTES
--
-- HISTORY
-- 10/13/1999   ptendulk         Created.
--
PROCEDURE GetMetCatVal (
   x_return_status               OUT NOCOPY VARCHAR2,
   p_arc_act_metric_used_by      IN  VARCHAR2,
   p_act_metric_used_by_id       IN  NUMBER,
   p_metric_category             IN  VARCHAR2,
   p_return_type                 IN  VARCHAR2,
   x_value                       OUT NOCOPY NUMBER
)
IS
   CURSOR c_sum_metrics(l_metric_id IN NUMBER,
                        l_arc_act_metric_used_by VARCHAR2) IS
    SELECT   metric_id
      FROM   ams_metrics_all_b
          WHERE   arc_metric_used_for_object = l_arc_act_metric_used_by
          START WITH metric_id = l_metric_id
          CONNECT BY PRIOR summary_metric_id = metric_id
          ORDER BY LEVEL DESC ;

   CURSOR c_cat_metrics IS
     SELECT act.activity_metric_id activity_metric_id,
            met.metric_id metric_id
     FROM  ams_act_metrics_all act,ams_metrics_vl met
     WHERE met.metric_id = act.metric_id
     AND      act.arc_act_metric_used_by = p_arc_act_metric_used_by
     AND      act.act_metric_used_by_id  = p_act_metric_used_by_id
     AND      met.metric_category =  p_metric_category ;
   CURSOR c_amount(l_met_id IN NUMBER) IS
     SELECT NVL(func_actual_value,0) func_actual_value,
            NVL(func_forecasted_value,0) func_forecasted_value,
            NVL(func_committed_value,0) func_committed_value
     FROM  ams_act_metrics_all
     WHERE metric_id = l_met_id
     AND      arc_act_metric_used_by = p_arc_act_metric_used_by
     AND      act_metric_used_by_id  = p_act_metric_used_by_id ;
   l_cat_met_rec c_cat_metrics%ROWTYPE ;
   l_sum_met_rec c_sum_metrics%ROWTYPE ;
   l_amount_rec  c_amount%ROWTYPE ;
BEGIN
   --
   -- Initialize API return status to success.
   --
   x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
   --
   -- Begin API Body.
   --
   -- Take the First Metric ID of all the Metrics attached to this Usage and of
   -- this class
   OPEN c_cat_metrics;
   FETCH c_cat_metrics INTO l_cat_met_rec;
   CLOSE c_cat_metrics ;
   -- This Cursor will Find out Summary Metric of all the metrics attached to
   -- this usage type (for e.g. Total Cost )
   OPEN c_sum_metrics(l_cat_met_rec.metric_id, p_arc_act_metric_used_by) ;
   FETCH c_sum_metrics INTO l_sum_met_rec;
   IF c_sum_metrics%NOTFOUND THEN
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
     RETURN;
   END IF ;
   CLOSE c_sum_metrics;
   -- Following Cursor will Find out the value for this summary metric and
   -- for this Usage
   -- ASSUMPTIONS : There will be only one Summary Metric(e.g. Total Cost)
   -- attached to one Usage(For e.g. Camp C1)
   OPEN  c_amount(l_sum_met_rec.metric_id) ;
   FETCH c_amount INTO l_amount_rec ;
   CLOSE c_amount ;
   --
   -- Set OUT values.
   --
   --   This amount is in Functional Currency Code
   IF p_return_type = 'ACTUAL' THEN
     x_value := l_amount_rec.func_actual_value ;
   ELSIF p_return_type = 'FORECASTED' THEN
     x_value := l_amount_rec.func_forecasted_value ;
   ELSIF p_return_type = 'COMMITTED' THEN
     x_value := l_amount_rec.func_committed_value ;
   END IF;
   --
   -- End API Body.
   --
EXCEPTION
   WHEN OTHERS THEN
     x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
     RETURN;
END GetMetCatVal;
-- NAME
--    Get_Met_Apport_Val
--
-- PURPOSE
--   Returns the Value of the Approtioned Metric
--
-- NOTES
--
-- HISTORY
-- 10/20/1999   ptendulk         Created.
--
PROCEDURE Get_Met_Apport_Val(
   p_obj_association_id          IN  NUMBER,
   x_return_status               OUT NOCOPY VARCHAR2,
   x_apportioned_value           OUT NOCOPY NUMBER
)
IS
   l_return_status         VARCHAR2(1);
   CURSOR c_obj_det IS
   SELECT master_object_type,
         master_object_id,
         using_object_type,
         using_object_id   ,
         TO_NUMBER(DECODE(usage_type,'CREATED',100,'USED_BY',
           NVL(pct_of_cost_to_charge_used_by,0))) pct_of_cost_to_charge_used_by,
         cost_frozen_flag
   FROM   ams_object_associations
   WHERE  object_association_id = p_obj_association_id ;
   CURSOR c_amt_met IS
      SELECT func_actual_value
      FROM   ams_act_metrics_all
      WHERE  activity_metric_origin_id = p_obj_association_id  ;
   l_obj_det_rec       c_obj_det%ROWTYPE ;
   l_amount                NUMBER ;
   l_apport_value          NUMBER ;
BEGIN
   --
   -- Initialize API return status to success.
   --
   x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
   --
   -- Begin API Body
   --
   OPEN  c_obj_det ;
   FETCH c_obj_det INTO l_obj_det_rec ;
   CLOSE c_obj_det ;
--   If Cost frozen flag is 'Y' don't apportion Metric
   IF l_obj_det_rec.cost_frozen_flag = 'N' THEN
      -- Call Proc to get the Value of the
      GetMetCatVal (
         x_return_status              => l_return_status,
         p_arc_act_metric_used_by     => l_obj_det_rec.using_object_type,
         p_act_metric_used_by_id      => l_obj_det_rec.using_object_id,
         p_metric_category            => 'COST', --Apportioning only for Cost
         p_return_type                => 'ACTUAL', -- Return the Actual Value
         x_value                      => l_amount
      );
      IF l_return_status = Fnd_Api.G_RET_STS_SUCCESS THEN
         l_apport_value :=
              l_amount * l_obj_det_rec.pct_of_cost_to_charge_used_by/100 ;
      ELSE
         x_return_status := l_return_status ;
         RETURN;
      END IF;
   ELSE
      OPEN  c_amt_met;
      FETCH c_amt_met INTO l_apport_value;
      CLOSE c_amt_met;
   END IF;
   --
   -- Set Output Variables.
   --
   x_apportioned_value := l_apport_value;
   --
   -- End API Body.
   --
EXCEPTION
   WHEN OTHERS THEN
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
END Get_Met_Apport_Val;
--
-- NAME
--    Convert_Uom
--
-- PURPOSE
--    This Procedure will  call the Inventory API to convert Uom
--    It will return the calculated quantity (in UOM of to_uom_code )
--    All the Calculations to calculate Value of the metrics
--    are done in Base Uom defined for that Metric. So the First step before
--    calculation starts is to convert the UOM into Base UOM.
--    Once the Value is calculated it's converted back to the Original UOM
--    Activity Metric table will be updated with this UOM
-- NOTES
--
-- HISTORY
-- 09/30/1999     ptendulk            Created.
--
FUNCTION Convert_Uom(
   p_from_uom_code  IN  VARCHAR2,
   p_to_uom_code    IN  VARCHAR2,
   p_from_quantity  IN      NUMBER,
   p_precision      IN      NUMBER   DEFAULT NULL,
   p_from_uom_name  IN  VARCHAR2 DEFAULT NULL,
   p_to_uom_name    IN  VARCHAR2 DEFAULT NULL
)
RETURN NUMBER
IS
   l_to_quantity    NUMBER ;
BEGIN
   -- Call UOM Conversion API. Pass Item ID as 0 as the UOM is not attached to Item
   l_to_quantity := Inv_Convert.Inv_Um_Convert (
       item_id        => 0 ,      -- As This is Standard Conversion
         PRECISION    => p_precision,
         from_quantity=> p_from_quantity,
       from_unit      => p_from_uom_code,
       to_unit        => p_to_uom_code,
       from_name      => p_from_uom_name,
       to_name        => p_to_uom_name ) ;
    RETURN l_to_quantity ;
EXCEPTION
   WHEN OTHERS THEN
      l_to_quantity  := -1 ;
      RETURN l_to_quantity ;
END Convert_Uom;

--
-- NAME
--    Fetch_Manual
--
-- PURPOSE
--   For the Metric of Type Manual this Function will get
--   value of the Metrices from Activity_metric table and
--   will return the values
--
-- NOTES
--
-- HISTORY
-- 09/29/1999   ptendulk  Created
---08/28/2000   SVEERAVE  Modified from function to procedure, and also included
--                        OUT parameter of func_forecasted_value
-- 08/16/2001   dmvincen  Syncronize functional currency.
PROCEDURE Fetch_Manual (
   p_activity_metric_id         IN NUMBER,
   x_func_actual_value          OUT NOCOPY NUMBER,
   x_func_forecasted_value      OUT NOCOPY NUMBER,
   p_func_currency_code         IN VARCHAR2
)
IS
   CURSOR c_act_metric(l_activity_metric_id NUMBER) IS
        SELECT  trans_actual_value,
                trans_forecasted_value,
                transaction_currency_code,
                NVL(func_actual_value,0) actual,
                NVL(func_forecasted_value, 0) forecasted,
                functional_currency_code
        FROM    ams_act_metrics_all
        WHERE   activity_metric_id = l_activity_metric_id;
   l_trans_actual_value NUMBER;
   l_trans_forecasted_value NUMBER;
   l_trans_currency_code VARCHAR2(15);
   l_func_currency_code VARCHAR2(15);
   l_return_status VARCHAR2(1);

BEGIN
   OPEN  c_act_metric(p_activity_metric_id);
   FETCH c_act_metric
      INTO l_trans_actual_value, l_trans_forecasted_value, l_trans_currency_code,
           x_func_actual_value, x_func_forecasted_value, l_func_currency_code;
   CLOSE c_act_metric;
   IF l_trans_currency_code IS NOT NULL AND l_func_currency_code IS NOT NULL
      AND l_func_currency_code <> p_func_currency_code THEN
      Ams_Actmetric_Pvt.CONVERT_CURRENCY2(
         x_return_status => l_return_status,
         p_from_currency => l_trans_currency_code,
         p_to_currency   => p_func_currency_code,
         -- p_conv_date     => SYSDATE,
         p_from_amount   => l_trans_actual_value,
         x_to_amount     => x_func_actual_value,
         p_from_amount2  => l_trans_forecasted_value,
         x_to_amount2    => x_func_forecasted_value,
         p_round         => Fnd_Api.G_FALSE
      );
   END IF;

END Fetch_Manual;

--
-- NAME
--    Exec_Function
--
-- PURPOSE
--    Executes the given function using values derived from the
--    activity_metric_id.
--    Return the value derived from the given function.
--
-- NOTES
--    Use Native Dynamic SQL (8i feature) for executing the function.
--    If a currency value is returned it must be in the default currency.
--
-- HISTORY
-- 07/05/1999     choang            Created.
--
FUNCTION Exec_Function (
   p_activity_metric_id       IN NUMBER,
   p_function_name            IN VARCHAR2
)
RETURN NUMBER
IS
   l_return_value          NUMBER;
   l_sql_str               VARCHAR2(4000);
BEGIN
   l_sql_str := 'BEGIN :return_value := ' || p_function_name || '( :activity_metric_id ); END;';
   EXECUTE IMMEDIATE l_sql_str
      USING OUT l_return_value, IN p_activity_metric_id;
   RETURN l_return_value;
END Exec_Function;

-------------------------------------------------------------------------------
-- NAME
--    Make_Functions_Dirty
-- PURPOSE
--    For all activity metrics of type FUNCTION, if the function's evaluated
--    value is different from it's original value, update the activity metric
--    to reflect the change and make it dirty, which also makes all activity
--    metrics above it in the hierarchy dirty.
-- HISTORY
-- 13-Oct-2000 choang   Created.
-- 08/16/2001  dmvincen Syncronize the functional currency to the default.
-------------------------------------------------------------------------------
/*** OBSOLETE BUG4924982 ***
PROCEDURE Make_Functions_Dirty
IS
   l_new_func_value     NUMBER;
   l_act_metric_rec     Ams_Actmetric_Pvt.Act_Metric_Rec_Type;

   l_return_status      VARCHAR2(1);
   l_msg_count          NUMBER;
   l_msg_data           VARCHAR2(4000);
   cntr NUMBER := 1;
   CURSOR c_functions IS
      SELECT /*+ first_rows * / activity_metric_id,
             function_name,
             func_actual_value,
             last_calculated_date,
             functional_currency_code
      FROM   ams_act_metrics_all actmet, ams_metrics_all_b met
      WHERE  actmet.metric_id = met.metric_id
      AND arc_act_metric_used_by IN
         ('RCAM', 'CAMP', 'CSCH', 'DELV', 'EVEH', 'EVEO', 'EONE')
          --BUG2845365: Remove dialogue components.
          --'DILG', 'AMS_COMP_START', 'AMS_COMP_SHOW_WEB_PAGE', 'AMS_COMP_END')
      AND metric_calculation_type = 'FUNCTION';

   l_function_rec    c_functions%ROWTYPE;
   l_current_date  DATE :=  SYSDATE;
   l_default_currency VARCHAR2(15) := Ams_Actmetric_Pvt.DEFAULT_FUNC_CURRENCY;
BEGIN

   OPEN c_functions;
   LOOP
      FETCH c_functions INTO l_function_rec;
      EXIT WHEN c_functions%NOTFOUND;
      l_new_func_value := Exec_Function (l_function_rec.activity_metric_id,
                                l_function_rec.function_name);

      IF l_new_func_value <> l_function_rec.func_actual_value THEN
         Ams_Actmetric_Pvt.Init_ActMetric_Rec(x_act_metric_rec => l_act_metric_rec );
         l_act_metric_rec.activity_metric_id :=
               l_function_rec.activity_metric_id;
         l_act_metric_rec.func_actual_value := l_new_func_value;
         -- BUG2385692: Set transaction values to recalculate.
         l_act_metric_rec.trans_actual_value := NULL;
         IF l_function_rec.functional_currency_code IS NOT NULL THEN
            l_act_metric_rec.functional_currency_code := l_default_currency;
         END IF;
         l_act_metric_rec.difference_since_last_calc :=
               l_new_func_value - l_function_rec.func_actual_value;
         l_act_metric_rec.days_since_last_refresh :=
               l_current_date - l_function_rec.last_calculated_date;
         l_act_metric_rec.last_calculated_date := l_current_date;
         l_act_metric_rec.dirty_flag := 'Y';

         Ams_Actmetric_Pvt.Update_ActMetric (
            p_api_version                => 1.0,
            p_init_msg_list              => Fnd_Api.g_false,
            p_commit                     => Fnd_Api.G_FALSE,
            p_validation_level           => Fnd_Api.g_valid_level_full,
            p_act_metric_rec             => l_act_metric_rec,
            x_return_status              => l_return_status,
            x_msg_count                  => l_msg_count,
            x_msg_data                   => l_msg_data);
         IF l_return_status = Fnd_Api.G_RET_STS_ERROR THEN
            RAISE Fnd_Api.G_EXC_ERROR;
         ELSIF l_return_status = Fnd_Api.G_RET_STS_UNEXP_ERROR THEN
            RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
         END IF;
      END IF;
   END LOOP;
   CLOSE c_functions;
END Make_Functions_Dirty;
*** OBSOLETE BUG4924982 ***/

--
-- NAME
--    check_object_status
--
-- PURPOSE
--   Check if the business object has been canceled.
--
-- NOTES
--
-- HISTORY
-- 08/16/2001  dmvincen  Created
--
PROCEDURE check_object_status(
   p_arc_act_metric_used_by IN VARCHAR2,
   p_act_metric_used_by_id IN NUMBER,
   x_is_canceled OUT NOCOPY VARCHAR2
)
IS
   CURSOR c_camp(id NUMBER) IS
      SELECT Fnd_Api.G_TRUE
      FROM ams_campaigns_all_b
      WHERE campaign_id = id
      AND status_code = 'CANCELLED';

   CURSOR c_csch(id NUMBER) IS
      SELECT Fnd_Api.G_TRUE
      FROM ams_campaign_schedules_b
      WHERE schedule_id = id
      AND status_code = 'CANCELLED';

   CURSOR c_delv(id NUMBER) IS
      SELECT Fnd_Api.G_TRUE
      FROM ams_deliverables_all_b
      WHERE deliverable_id = id
      AND status_code = 'CANCELLED';

   CURSOR c_eveh(id NUMBER) IS
      SELECT Fnd_Api.G_TRUE
      FROM ams_event_headers_all_b
      WHERE event_header_id = id
      AND system_status_code = 'CANCELLED';

   CURSOR c_eveo(id NUMBER) IS
      SELECT Fnd_Api.G_TRUE
      FROM ams_event_offers_all_b
      WHERE event_offer_id = id
      AND system_status_code IN ('CANCELLED');

   l_is_canceled VARCHAR2(1) := Fnd_Api.G_FALSE;

BEGIN
   IF p_arc_act_metric_used_by IN ('RCAM', 'CAMP') THEN
      OPEN c_camp(p_act_metric_used_by_id);
      FETCH c_camp INTO l_is_canceled;
      CLOSE c_camp;

   ELSIF (p_arc_act_metric_used_by = 'CSCH') THEN
      OPEN c_csch(p_act_metric_used_by_id);
      FETCH c_csch INTO l_is_canceled;
      CLOSE c_csch;

   ELSIF (p_arc_act_metric_used_by = 'DELV') THEN
      OPEN c_delv(p_act_metric_used_by_id);
      FETCH c_delv INTO l_is_canceled;
      CLOSE c_delv;

   ELSIF (p_arc_act_metric_used_by = 'EVEH') THEN
      OPEN c_eveh(p_act_metric_used_by_id);
      FETCH c_eveh INTO l_is_canceled;
      CLOSE c_eveh;

   ELSIF p_arc_act_metric_used_by IN ('EONE', 'EVEO') THEN
      OPEN c_eveo(p_act_metric_used_by_id);
      FETCH c_eveo INTO l_is_canceled;
      CLOSE c_eveo;

   END IF;

   x_is_canceled := l_is_canceled;

END check_object_status;

--
-- Begin of section added by ptendulk- 09/29/1999
--
-- NAME
--    Exec_Rollup
--
-- PURPOSE
--   For the Metric of Type ROLLUP this Procedure will calculate
--   value of the Metrices at lower level and aggregates/averages them
--   to Upper Level
--
-- NOTES
--
-- HISTORY
-- 09/29/1999   ptendulk           Created
-- 10/19/2000   SVEERAVE           Removed savepoints and percolated exceptions above.
--                                 Added p_refresh_function parameter.
-- 08/16/2001   dmvincen  Make sure the all the currency values are added up
--                        as the same currency code.
-- 08/16/2001   dmvincen  Check if the child object is canceled.  No not rollup
--                        values if no actual value has accrued.
PROCEDURE Exec_Rollup (
   p_api_version                IN      NUMBER,
   p_init_msg_list              IN      VARCHAR2 := Fnd_Api.G_False,
   p_commit                     IN      VARCHAR2 := Fnd_Api.G_False,
   x_return_status              OUT     NOCOPY VARCHAR2,
   x_msg_count                  OUT     NOCOPY NUMBER,
   x_msg_data                   OUT     NOCOPY VARCHAR2,
   p_act_metric_id              IN      NUMBER,
   p_metric_value_type          IN      VARCHAR2,
   x_actual_value               OUT     NOCOPY NUMBER,
   x_forecasted_value           OUT     NOCOPY NUMBER,
   p_func_currency_code         IN      VARCHAR2
)
IS
   L_API_VERSION        CONSTANT NUMBER := 1.0;
   L_API_NAME           VARCHAR2(30) := 'Exec_Rollup';
   L_FULL_NAME          CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
   l_function_name      VARCHAR2(30);

   -- Order by is used to prevent redundant queries of the same object.
   CURSOR c_met_child_rollup(l_activity_metric_id NUMBER)
      IS
      SELECT activity_metric_id,
         arc_act_metric_used_by,
         act_metric_used_by_id,
         --metric_uom_code,
         NVL(func_actual_value, 0) func_actual_value,
         NVL(func_forecasted_value, 0) func_forecasted_value,
         functional_currency_code,
         NVL(trans_actual_value, 0) trans_actual_value,
         NVL(trans_forecasted_value, 0) trans_forecasted_value,
         transaction_currency_code
      FROM  ams_act_metrics_all
      WHERE  rollup_to_metric = l_activity_metric_id
      ORDER BY arc_act_metric_used_by, act_metric_used_by_id;
   l_met_child_rec        c_met_child_rollup%ROWTYPE;

   -- Variables to store calculated Values
   l_actual_value       NUMBER ;
   l_forecasted_value   NUMBER;
   l_cnt_chld NUMBER := 0; -- Count No of childs This will be used to calculate average
   -- Variables to store final calculated Values (These will be passed Along
   -- with Activity Metric to Update Activity Metric API
   l_final_actual_value         NUMBER := 0 ;
   l_final_forecasted_value     NUMBER := 0;
   l_valid_chld_flg             VARCHAR2(1):= Fnd_Api.G_False;
   l_arc_act_metric_used_by     VARCHAR2(80);
   l_act_metric_used_by_id      NUMBER;
   l_is_canceled                VARCHAR2(1);
   l_return_status              VARCHAR2(1);
BEGIN
   --
   -- Output debug message.
   --
   IF AMS_DEBUG_HIGH_ON THEN
   Ams_Utility_Pvt.debug_message(l_full_name||': START');
   END IF;
   --
   -- Initialize message list if p_init_msg_list is set to TRUE.
   --
   IF Fnd_Api.To_Boolean (p_init_msg_list) THEN
      Fnd_Msg_Pub.Initialize;
   END IF;
   -- Standard check for API version compatibility.
   --
   IF NOT Fnd_Api.Compatible_API_Call (L_API_VERSION,
                                       p_api_version,
                                       L_API_NAME,
                                       G_PKG_NAME)
   THEN
      RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
   END IF;
   --
   -- Initialize API return status to success.
   --
   x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
   --
   -- Begin API Body.
   --
   OPEN c_met_child_rollup(p_act_metric_id);
   LOOP
      FETCH c_met_child_rollup INTO l_met_child_rec;
      EXIT WHEN c_met_child_rollup%NOTFOUND;
      -- check for canceled object only if we have not previously checked.
      IF l_arc_act_metric_used_by IS NULL OR
         (l_arc_act_metric_used_by <> l_met_child_rec.arc_act_metric_used_by OR
         l_act_metric_used_by_id <> l_met_child_rec.act_metric_used_by_id)
      THEN
         l_arc_act_metric_used_by := l_met_child_rec.arc_act_metric_used_by;
         l_act_metric_used_by_id := l_met_child_rec.act_metric_used_by_id;
         l_is_canceled := Fnd_Api.G_FALSE;
         check_object_status( l_arc_act_metric_used_by,
                              l_act_metric_used_by_id,
                              l_is_canceled);
      END IF;
      -- canceled must only rollup if actual costs were accrued.
      IF l_is_canceled = Fnd_Api.G_FALSE OR
         l_met_child_rec.func_actual_value <> 0
      THEN
         IF l_met_child_rec.functional_currency_code IS NOT NULL AND
            l_met_child_rec.functional_currency_code <> p_func_currency_code
         THEN
            -- Syncronize the currency code with the default.
            Ams_Actmetric_Pvt.CONVERT_CURRENCY2(
               x_return_status => l_return_status,
               p_from_currency => l_met_child_rec.transaction_currency_code,
               p_to_currency   => p_func_currency_code,
               -- p_conv_date     => SYSDATE,
               p_from_amount   => l_met_child_rec.trans_actual_value,
               x_to_amount     => l_actual_value,
               p_from_amount2  => l_met_child_rec.trans_forecasted_value,
               x_to_amount2    => l_forecasted_value,
               p_round         => Fnd_Api.G_FALSE
            );
         ELSE
            l_actual_value := l_met_child_rec.func_actual_value;
            l_forecasted_value := l_met_child_rec.func_forecasted_value;
         END IF;
         --   Child Exist
         --  Count the Number of child entities
         l_cnt_chld := l_cnt_chld + 1 ;
         l_final_actual_value := l_final_actual_value +
                  l_actual_value;
         l_final_forecasted_value := l_final_forecasted_value +
                 l_forecasted_value;
      END IF;
   END LOOP;
   CLOSE c_met_child_rollup;
   -- Now If the Value type is 'R' (It's Ratio Metric) , Devide the SUM
   -- by number of childs , it will give you average
   IF p_metric_value_type = 'R' AND l_cnt_chld > 0 THEN
      l_final_actual_value      :=  l_final_actual_value / l_cnt_chld;
      l_final_forecasted_value  :=  l_final_forecasted_value / l_cnt_chld;
   END IF;
   x_actual_value       := l_final_actual_value ;
   x_forecasted_value   := l_final_forecasted_value;

   --
   -- End API Body.
   --
   --
   -- Standard check for commit request.
   --
   IF Fnd_Api.To_Boolean(p_commit) THEN
      COMMIT WORK;
   END IF;
   --
   -- Standard API to get message count, and if 1,
   -- set the message data OUT variable.
   --
   Fnd_Msg_Pub.Count_And_Get (
      p_count           =>    x_msg_count,
      p_data            =>    x_msg_data,
      p_encoded         =>    Fnd_Api.G_FALSE
   );
   --Ams_Utility_Pvt.debug_message(l_full_name ||': end');
EXCEPTION
   WHEN Fnd_Api.G_EXC_ERROR THEN
      x_return_status := Fnd_Api.G_RET_STS_ERROR;
      Fnd_Msg_Pub.Count_And_Get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data,
         p_encoded       =>   FND_API.G_FALSE
      );
      RAISE Fnd_Api.G_EXC_ERROR;

   WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      Fnd_Msg_Pub.Count_And_Get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data,
         p_encoded       =>   FND_API.G_FALSE
      );
      RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR ;
   WHEN OTHERS THEN
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      IF Fnd_Msg_Pub.Check_Msg_Level (Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR) THEN
         Fnd_Msg_Pub.Add_Exc_Msg (G_PKG_NAME, L_API_NAME);
      END IF;
      Fnd_Msg_Pub.Count_And_Get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data,
         p_encoded       =>     FND_API.G_FALSE
      );
      RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR ;
END Exec_Rollup;

--
-- Begin of section added by ptendulk- 09/29/1999
--
-- NAME
--    Exec_Summary
--
-- PURPOSE
--   For the Metric of Type SUMMARY this Procedure will calculate
--   value of the Metrices at lower level and aggregates/averages them
--   to Upper Level
--
-- NOTES
--
-- HISTORY
-- 09/29/1999   ptendulk           Created
-- 10/19/2000   SVEERAVE           Removed savepoints and percolated exceptions above.
--                                 Added p_refresh_function parameter.
-- 08/16/2001   dmvincen   Add up all the child values as the same currency.
PROCEDURE Exec_Summary (
   p_api_version                IN      NUMBER,
   p_init_msg_list              IN      VARCHAR2 := Fnd_Api.G_False,
   p_commit                     IN      VARCHAR2 := Fnd_Api.G_False,
   x_return_status              OUT     NOCOPY VARCHAR2,
   x_msg_count                  OUT     NOCOPY NUMBER,
   x_msg_data                   OUT     NOCOPY VARCHAR2,
   p_act_metric_id              IN      NUMBER,
   p_metric_value_type          IN      VARCHAR2,
   x_actual_value               OUT     NOCOPY NUMBER,
   x_forecasted_value           OUT     NOCOPY NUMBER,
   p_refresh_function           IN      VARCHAR2 := Fnd_Api.G_TRUE,
   p_func_currency_code         IN      VARCHAR2
)
IS
   L_API_VERSION        CONSTANT NUMBER := 1.0;
   L_API_NAME           VARCHAR2(30) := 'Exec_Summary';
   L_FULL_NAME          CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
   l_function_name      VARCHAR2(30);

   -- This Cursor will Select the Details for the Activity Metric ID
   -- For the Child Summary Metric The Only Difference from the cursor above
   -- is It checks the children are attached to the same Usage level as parent
   CURSOR c_met_child_sum(l_activity_metric_id NUMBER)
      IS
      SELECT activity_metric_id,
         arc_act_metric_used_by,
         act_metric_used_by_id,
         metric_uom_code
      FROM   ams_act_metrics_all
      WHERE summarize_to_metric = l_activity_metric_id;
   l_met_child_sum_rec        c_met_child_sum%ROWTYPE;

   -- Variables to store calculated Values
   l_actual_value       NUMBER ;
   l_forecasted_value   NUMBER;
   l_cnt_chld NUMBER := 0; -- Count No of childs This will be used to calculate average
   -- Variables to store final calculated Values (These will be passed Along
   -- with Activity Metric to Update Activity Metric API
   l_final_actual_value         NUMBER := 0 ;
   l_final_forecasted_value     NUMBER := 0;
   l_valid_chld_flg             VARCHAR2(1):= Fnd_Api.G_False ;
BEGIN
   --
   -- Output debug message.
   --
   IF AMS_DEBUG_HIGH_ON THEN
   Ams_Utility_Pvt.debug_message(l_full_name||': start');
   END IF;
   --
   -- Initialize message list if p_init_msg_list is set to TRUE.
   --
   IF Fnd_Api.To_Boolean (p_init_msg_list) THEN
      Fnd_Msg_Pub.Initialize;
   END IF;
   -- Standard check for API version compatibility.
   --
   IF NOT Fnd_Api.Compatible_API_Call (L_API_VERSION,
                                       p_api_version,
                                       L_API_NAME,
                                       G_PKG_NAME)
   THEN
      RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
   END IF;
   --
   -- Initialize API return status to success.
   --
   x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
   --
   -- Begin API Body.
   --
   OPEN c_met_child_sum(p_act_metric_id);
   LOOP
      FETCH c_met_child_sum INTO l_met_child_sum_rec;
      EXIT WHEN c_met_child_sum%NOTFOUND;
      l_cnt_chld := l_cnt_chld + 1 ;
      -- Give Recursive call to Calculate Metric
      -- to find out the value of the Child Metric
      Calculate_Metric (
          p_api_version            => l_api_version,
          p_init_msg_list          => p_init_msg_list,
          p_commit                 => p_commit ,
          x_return_status          => x_return_status,
          x_msg_count              => x_msg_count,
          x_msg_data               => x_msg_data,
          p_activity_metric_id     =>
                  l_met_child_sum_rec.activity_metric_id,
          x_actual_value            => l_actual_value,
          x_forecasted_value        => l_forecasted_value,
          p_refresh_function        => p_refresh_function,
          p_func_currency_code      => p_func_currency_code
      );
      -- If any errors happen abort API.
      IF x_return_status = Fnd_Api.G_RET_STS_ERROR THEN
         CLOSE c_met_child_sum ;
         RAISE Fnd_Api.G_EXC_ERROR;
      ELSIF x_return_status = Fnd_Api.G_RET_STS_UNEXP_ERROR THEN
         CLOSE c_met_child_sum ;
         RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
      END IF;

      l_final_actual_value :=
             l_final_actual_value + NVL(l_actual_value,0);
      l_final_forecasted_value :=
             l_final_forecasted_value + NVL(l_forecasted_value,0);

   END LOOP;
   CLOSE c_met_child_sum;
   -- Now If the Value type is 'R' (It's Ratio Metric) , Devide the Sum
   -- by number of childs , it will give you average
   IF p_metric_value_type = 'R' AND l_cnt_chld > 0 THEN
      l_final_actual_value      :=  l_final_actual_value / l_cnt_chld;
      l_final_forecasted_value  :=  l_final_forecasted_value / l_cnt_chld;
   END IF;
   x_actual_value       := l_final_actual_value ;
   x_forecasted_value   := l_final_forecasted_value;

   --
   -- End API Body.
   --
   --
   -- Standard check for commit request.
   --
   IF Fnd_Api.To_Boolean(p_commit) THEN
      COMMIT WORK;
   END IF;
   --
   -- Standard API to get message count, and if 1,
   -- set the message data OUT variable.
   --
   Fnd_Msg_Pub.Count_And_Get (
      p_count           =>    x_msg_count,
      p_data            =>    x_msg_data,
      p_encoded         =>    Fnd_Api.G_FALSE
   );
   IF AMS_DEBUG_HIGH_ON THEN
   Ams_Utility_Pvt.debug_message(l_full_name ||': end');
   END IF;
EXCEPTION
   WHEN Fnd_Api.G_EXC_ERROR THEN
      x_return_status := Fnd_Api.G_RET_STS_ERROR;
      Fnd_Msg_Pub.Count_And_Get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data,
         p_encoded       =>     FND_API.G_FALSE
      );
      RAISE Fnd_Api.G_EXC_ERROR;

   WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      Fnd_Msg_Pub.Count_And_Get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data,
         p_encoded       =>     FND_API.G_FALSE
      );
      RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR ;
   WHEN OTHERS THEN
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      IF Fnd_Msg_Pub.Check_Msg_Level (Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR) THEN
         Fnd_Msg_Pub.Add_Exc_Msg (G_PKG_NAME, L_API_NAME);
      END IF;
      Fnd_Msg_Pub.Count_And_Get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data,
         p_encoded       =>     FND_API.G_FALSE
      );
      RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR ;
END Exec_Summary;

--
-- Begin of section added by ptendulk - 09/28/1999
--
-- NAME
--    Calculate_Metric
--
-- PURPOSE
--   This Procedure checks the Calculation type of the Metrics
--   in question and calls appropriate function
--   (For e.g Function Fetch_Manual is called for Manual type of Matrics)
--   This Process calls the Update Activity metric API at Last stage
--   which updates the Activity Metric table with the calculated values
--   as part of Metric Refresh. This one also includes the Calls to
--   the appropreate apis to Update Usages with refreshed metric values.
--   For e.g Update_campaign for updating Campaign Cost
--
-- NOTES
--
--
-- HISTORY
-- 09/28/1999   ptendulk        Created
-- 08/28/2000   SVEERAVE        Modified to include forecasted value in the rollup.
-- 10/19/2000   SVEERAVE        Removed savepoints and percolated exceptions above, and removed it from specs.
--                              Added p_refresh_function parameter.
-- 08/16/2001   dmvincen   Add up the currency as the same currency code.
-- 08/16/2001   dmvincen   Syncronize the functional currencies to default.
-- 08/16/2001   dmvincen   Removed redundant parameters.
-- 08/29/2001   huili      Added function_type checking for function metrics.


PROCEDURE Calculate_Metric (
   p_api_version            IN    NUMBER,
   p_init_msg_list          IN    VARCHAR2 := Fnd_Api.G_FALSE,
   p_commit                 IN    VARCHAR2 := Fnd_Api.G_FALSE,
   x_return_status          OUT   NOCOPY VARCHAR2,
   x_msg_count              OUT   NOCOPY NUMBER,
   x_msg_data               OUT   NOCOPY VARCHAR2,
--   p_metric_id                   IN    NUMBER,
   p_activity_metric_id     IN    NUMBER,
--    p_act_metric_used_by_id       IN    NUMBER,
--    p_arc_act_metric_used_by IN   VARCHAR2,
--    p_act_metric_uom_code         IN   VARCHAR2,
   x_actual_value           OUT   NOCOPY NUMBER,
   x_forecasted_value       OUT   NOCOPY NUMBER,
   p_refresh_function       IN     VARCHAR2 := Fnd_Api.G_TRUE,
   p_func_currency_code     IN     VARCHAR2)
IS
   L_API_VERSION         CONSTANT NUMBER := 1.0;
   L_API_NAME            VARCHAR2(30) := 'Calculate_Metric';
   L_FULL_NAME           CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
   l_function_name       VARCHAR2(30);
   -------------------------------------------------------------
   --   Define Record type , this will be passed to activity
   --   metric API for Updation
   -------------------------------------------------------------
   l_act_metrics_rec              Ams_Actmetric_Pvt.act_metric_rec_type;
   CURSOR c_met_cal_type(l_metric_id NUMBER) IS
      SELECT value_type,              -- Ratio / Numeric
             metric_calculation_type, -- Manual/Function/...
             accrual_type,            -- Fixed/Variable
             function_name ,    -- will be used only if it is Function Metric
             compute_using_function,--Will be used only if it is Variable Metric
             default_uom_code,       -- Will be Used for UOM Conversion
             function_type

      --FROM     ams_metrics_vl
      FROM     ams_metrics_all_b
      WHERE    metric_id = l_metric_id;
   l_cal_type_rec       c_met_cal_type%ROWTYPE;
   l_metric_found       VARCHAR2(1) := Fnd_Api.G_FALSE;
   -------------------------------------------
   -- Variables to store calculated Values
   -------------------------------------------
   l_actual_value       NUMBER ;
   l_forecasted_value   NUMBER;
   l_func_currency_code VARCHAR2(15);
   --------------------------------------------------------------------
   -- Count No of childs This will be used to calculate average
   --------------------------------------------------------------------
   l_cnt_chld      NUMBER := 0;
   ----------------------------------------------------------------------------
   -- Variables to store final calculated Values (These will be passed Along
   -- with Activity Metric ID to Update Activity Metric API
   ----------------------------------------------------------------------------
   --functional actual, and forecasted values in metric's DEFAULT uom
   l_final_actual_value         NUMBER := 0 ;
   l_final_forecasted_value     NUMBER := 0 ;
   --functional actual, and forecasted values in act metric's uom
   l_conv_uom_forecasted_value  NUMBER := 0;
   l_conv_uom_actual_value      NUMBER := 0 ;
   --transaction actual, and forecasted currency values in act metric's uom
   l_conv_curr_value            NUMBER := 0 ;
   l_trans_curr_forecasted_value NUMBER := 0 ;
   l_compute_using_function_value       NUMBER ;

   -------------------------------------------------------
   -- Cursor to select Origin ID of the Activity Metric
   -- It will be used only in case of Apportioned Metric.
   -------------------------------------------------------
   CURSOR c_origin(l_activity_metric_id NUMBER) IS
      SELECT activity_metric_origin_id,
             NVL(last_calculated_date,SYSDATE) last_calculated_date,
             NVL(func_actual_value,0) func_actual_value,
             NVL(func_forecasted_value,0) func_forecasted_value,
             metric_id, variable_value, depend_act_metric, dirty_flag,
             act_metric_used_by_id, arc_act_metric_used_by,
             metric_uom_code,
             transaction_currency_code,
             functional_currency_code,
             NVL(trans_actual_value,0) trans_actual_value,
             NVL(trans_forecasted_value,0) trans_forecasted_value
      FROM   ams_act_metrics_all
      WHERE  activity_metric_id = l_activity_metric_id
      for update of trans_actual_value, trans_forecasted_value,
         func_actual_value, func_forecasted_value,
         functional_currency_code, computed_using_function_value,
         difference_since_last_calc, days_since_last_refresh,
         last_calculated_date, dirty_flag,
         last_updated_by, last_update_login,
         object_version_number
      nowait ;
   l_origin_rec c_origin%ROWTYPE ;
   -------------------------------------------------------
   -- Cursor to identify that it is an association activity metric.
   -------------------------------------------------------
   CURSOR c_check_assoc_metric(l_metric_id NUMBER) IS
        SELECT 1
        FROM ams_metric_accruals
        WHERE metric_id = l_metric_id;
   l_flag       NUMBER;
   l_current_date  DATE := SYSDATE;

   -- huili on 06/22/2001 changed the calculation method for variable metrics
   CURSOR c_var_met_info (l_act_metric_id NUMBER) IS
      SELECT func_actual_value, func_forecasted_value
      FROM ams_act_metrics_all
      WHERE activity_metric_id = l_act_metric_id;

   l_return_status              VARCHAR2(1);

BEGIN
   IF AMS_DEBUG_HIGH_ON THEN
   Ams_Utility_Pvt.debug_message('Now Ref/Calculating act met id: '||p_activity_metric_id);
   END IF;

   --
   -- Initialize savepoint.
   --
--   SAVEPOINT CALCULATE_METRIC_SAVEPOINT;
   --
   -- Output debug message.
   --
   IF AMS_DEBUG_HIGH_ON THEN
   Ams_Utility_Pvt.debug_message(l_full_name||': start');
   END IF;
   --
   -- Initialize message list if p_init_msg_list is set to TRUE.
   --
   IF Fnd_Api.To_Boolean (p_init_msg_list) THEN
      Fnd_Msg_Pub.Initialize;
   END IF;
   --
   -- Standard check for API version compatibility.
   --
   IF NOT Fnd_Api.Compatible_API_Call (L_API_VERSION,
                                       p_api_version,
                                       L_API_NAME,
                                       G_PKG_NAME)
   THEN
      RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
   END IF;
   --
   -- Initialize API return status to success.
   --
   x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
   --
   -- Begin API Body.
   --
   -- Store the Original values of the Metric
   OPEN  c_origin(p_activity_metric_id);
   FETCH c_origin INTO l_origin_rec ;
   CLOSE c_origin ;
   -------------------------------------------------------------
   -- procedure below checks for the existence of the
   -- rollup metrics at the parent Marketing entity level
   -- if this is not existing a new row is created in the
   -- ams_act_metrics_all and also calls refresh for the
   -- parent entity.
   -------------------------------------------------------------

   create_refresh_parent_level(
           p_activity_metric_id => p_activity_metric_id,
           p_metric_id => l_origin_rec.metric_id,
           p_act_metric_used_by_id => l_origin_rec.act_metric_used_by_id,
           p_arc_act_metric_used_by => l_origin_rec.arc_act_metric_used_by,
           p_dirty => l_origin_rec.dirty_flag
   );

   OPEN  c_met_cal_type(l_origin_rec.metric_id);
   FETCH c_met_cal_type INTO l_cal_type_rec;
   IF c_met_cal_type%FOUND THEN
      l_metric_found := Fnd_Api.G_TRUE;
   END IF;
   CLOSE c_met_cal_type;

   ------------------------------------------
   -- If details exist in ams_metrics_all_b
   ------------------------------------------
   IF l_metric_found = Fnd_Api.G_TRUE THEN
      -----------------------------------------------------
      -- If this metrics is of FIXED calculation type
      -----------------------------------------------------
      IF l_cal_type_rec.accrual_type = 'FIXED' THEN
         ----------------------------------------------------
         -- for FIXED metrics, if this of MANUAL entry type
         -- then just grab the values and update
         -----------------------------------------------------
         IF l_cal_type_rec.metric_calculation_type = 'MANUAL' THEN
            Fetch_Manual(   p_activity_metric_id => p_activity_metric_id,
                         x_func_actual_value => l_actual_value,
                         x_func_forecasted_value => l_forecasted_value,
                         p_func_currency_code => p_func_currency_code);
            IF (l_cal_type_rec.default_uom_code IS NOT NULL) AND
               (l_origin_rec.metric_uom_code IS NOT NULL) THEN
               --------------------------------------------------------------
               -- Convert the Actual value calculated into Base UOM amount
               -- While Updating Activity Metric Table with refreshed metric
               -- value, This will be converted back to UOM of this Activity
               -- Metric
               -----------------------------------------------------------------
               l_final_actual_value := Convert_Uom(
                        p_from_uom_code => l_origin_rec.metric_uom_code,
                        p_to_uom_code   => l_cal_type_rec.default_uom_code,
                        p_from_quantity => l_actual_value);
               l_final_forecasted_value := Convert_Uom(
                        p_from_uom_code => l_origin_rec.metric_uom_code,
                        p_to_uom_code   => l_cal_type_rec.default_uom_code,
                        p_from_quantity => l_forecasted_value);
               IF (l_final_actual_value < 0) OR (l_final_forecasted_value < 0)
               THEN
                  l_final_actual_value := 0 ;
                  l_final_forecasted_value := 0 ;
                  RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
               END IF; --check final value
            ELSE
               l_final_actual_value := l_actual_value;
               l_final_forecasted_value := l_forecasted_value;
            END IF; --if there is UOM
            ----------------------------------------------------
            -- for FIXED metrics, if this of FUNCTION type
            -- then execute the function and update
            -- no need of forecasted values for FUNCTION types as it is
            -- basically of MANUAL or ROLLUP
            -----------------------------------------------------
         ELSIF l_cal_type_rec.metric_calculation_type = 'FUNCTION' THEN
            --AND l_cal_type_rec.function_type = 'Y' THEN
            -- Calculate the value only when refresh_function is TRUE,
            -- SVEERAVE, 10/16/00
            IF p_refresh_function = Fnd_Api.G_TRUE
               AND l_cal_type_rec.function_type = 'Y' THEN
               l_actual_value := Exec_Function(
                     p_activity_metric_id => p_activity_metric_id,
                     p_function_name      => l_cal_type_rec.function_name);
               -- refresh the forecasted value as function execution might
               -- change forecasted values. -- 12/14/00 SVEERAVE
               -- OPEN  c_origin(p_activity_metric_id);
               -- FETCH c_origin INTO l_origin_rec;
               -- CLOSE c_origin;
               l_forecasted_value := l_origin_rec.func_forecasted_value;
            ELSE
               l_actual_value := l_origin_rec.func_actual_value;
               l_forecasted_value := l_origin_rec.func_forecasted_value;
            END IF;

            IF (l_cal_type_rec.default_uom_code IS NOT NULL) AND
               (l_origin_rec.metric_uom_code IS NOT NULL) THEN
            --------------------------------------------------------------------
            -- Convert the Actual value calculated into Base UOM amount
            -- While Updating Activity Metric Table with refreshed metric value,
            -- This will be converted back to UOM of this Activity Metric
            --------------------------------------------------------------------
               l_final_actual_value := Convert_Uom(
                        p_from_uom_code => l_origin_rec.metric_uom_code,
                        p_to_uom_code   => l_cal_type_rec.default_uom_code,
                        p_from_quantity => NVL(l_actual_value,0));
               l_final_forecasted_value := Convert_Uom(
                        p_from_uom_code => l_origin_rec.metric_uom_code,
                        p_to_uom_code   => l_cal_type_rec.default_uom_code,
                        p_from_quantity => NVL(l_forecasted_value,0));
               IF l_final_actual_value < 0 THEN
                  l_final_actual_value := 0 ;
                  RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
               END IF; --check final value
            ELSE
               IF l_origin_rec.transaction_currency_code IS NOT NULL AND
                  l_origin_rec.functional_currency_code IS NOT NULL AND
                  l_origin_rec.functional_currency_code <> p_func_currency_code
               THEN
                  l_func_currency_code := p_func_currency_code;
                  Ams_Actmetric_Pvt.CONVERT_CURRENCY2(
                     x_return_status => l_return_status,
                     p_from_currency => l_origin_rec.transaction_currency_code,
                     p_to_currency   => l_func_currency_code,
                     -- p_conv_date     => SYSDATE,
                     p_from_amount   => l_origin_rec.trans_actual_value,
                     x_to_amount     => l_actual_value,
                     p_from_amount2  => l_origin_rec.trans_forecasted_value,
                     x_to_amount2    => l_forecasted_value,
                     p_round         => Fnd_Api.G_FALSE
                  );
               ELSE
                   l_func_currency_code := l_origin_rec.functional_currency_code;
               END IF;
               l_final_actual_value := l_actual_value;
               l_final_forecasted_value := l_forecasted_value;
            END IF; --if there is UOM
         ----------------------------------------------------
         -- for FIXED metrics, if this of ROLLUP type
         -- then calculate metrics from lower level and update
         -----------------------------------------------------
         ELSIF l_cal_type_rec.metric_calculation_type IN ('ROLLUP', 'SUMMARY')
         THEN
            ------------------------------------------------------
            -- First Check if it is Apportioned Metric
            ------------------------------------------------------
            IF l_origin_rec.activity_metric_origin_id IS NOT NULL THEN

               -------------------------------------------
               -- Check whether it is association activity metric
               -------------------------------------------
               OPEN c_check_assoc_metric(l_origin_rec.metric_id);
               FETCH c_check_assoc_metric INTO l_flag;
               IF c_check_assoc_metric%FOUND THEN
                  -- do nothing in case of association activity metric.
                  l_final_actual_value := l_origin_rec.func_actual_value;
                  l_final_forecasted_value :=l_origin_rec.func_forecasted_value;

               ELSE
                  -------------------------------------------
                  -- Get the Value of the Apportioned Metric
                  -- no need to compute forecasted values in case of
                  -- apportioned metrics
                  -------------------------------------------
                  Get_Met_Apport_Val(
                           p_obj_association_id =>
                           l_origin_rec.activity_metric_origin_id,
                           x_return_status      => x_return_status,
                           x_apportioned_value  => l_actual_value);
                  IF (l_cal_type_rec.default_uom_code IS NOT NULL) AND
                     (l_origin_rec.metric_uom_code IS NOT NULL) THEN
                     ----------------------------------------------------------
                     -- Convert the Actual value calculated into Base UOM amount
                     -- While Updating Activity Metric Table with refreshed
                     -- metric value, this will be converted back to UOM of
                     -- this Activity Metric
                     ----------------------------------------------------------
                     l_final_actual_value := Convert_Uom(
                        p_from_uom_code => l_origin_rec.metric_uom_code,
                        p_to_uom_code   => l_cal_type_rec.default_uom_code,
                        p_from_quantity => l_actual_value);
                     IF l_final_actual_value < 0 THEN
                        l_final_actual_value := 0 ;
                        RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
                     END IF; --check final value
                  ELSE
                     l_final_actual_value := l_actual_value;
                  END IF; --if there is UOM
               END IF; --IF c_check_assoc_metric%FOUND
               CLOSE c_check_assoc_metric;
               ------------------------------------------------------
               -- If this is not apportioned metrics
               ------------------------------------------------------
            ELSE
               ---------------------------------------------------
               -- Check if this a Rollup Metrics Or Summary Metric
               ---------------------------------------------------
               IF l_cal_type_rec.metric_calculation_type = 'ROLLUP' THEN
                  -----------------------------------
                  -- This is for vertical Rollup Metric
                  ----------------------------------
                  ----------------------------------------------------------
                  -- Call Exec Rollup  to go to Lower Level and Calculate
                  -- Metric Value. This Proc is called in the Loop so will
                  -- be executed for each child of the Rollup Metric
                  -- The Parameter p_metric_type will tell this Proc whether
                  -- the metric is Rollup or Summary The Only difference
                  -- between calculation of Summary and Rollup Metric is
                  -- For Rollup Metric we have to validate the Child entity
                  ----------------------------------------------------------
                  Exec_Rollup(
                      p_api_version        => l_api_version,
                      p_init_msg_list      => p_init_msg_list,
                      p_commit             => p_commit,
                      x_return_status      => x_return_status,
                      x_msg_count          => x_msg_count,
                      x_msg_data           => x_msg_data,
                      p_act_metric_id      => p_activity_metric_id,
                      x_actual_value       => l_actual_value,
                      x_forecasted_value   => l_forecasted_value,
                      p_metric_value_type  => l_cal_type_rec.value_type,
                      p_func_currency_code => p_func_currency_code);
                  ------------------------------------
                  -- If any errors happen abort API.
                  ------------------------------------
                  IF x_return_status = Fnd_Api.G_RET_STS_ERROR THEN
                     RAISE Fnd_Api.G_EXC_ERROR;
                  ELSIF x_return_status = Fnd_Api.G_RET_STS_UNEXP_ERROR THEN
                     RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
                  END IF;
                  ---------------------------------------
                  -- Sum-up the values returned for the
                  -- child metrics
                  ---------------------------------------
                  l_final_actual_value    := NVL(l_actual_value,0) ;
                  l_final_forecasted_value:= NVL(l_forecasted_value,0);
                  --------------------------------------------------
                  -- Now If the Value type is 'R' (It's Ratio Metric,
                  -- Divide the Sum by number of childs , it will
                  -- give you average
                  --------------------------------------------------
--                   IF l_cal_type_rec.value_type = 'R' THEN
--                      l_final_actual_value            :=
--                         l_final_actual_value / l_cnt_chld;
--                      l_final_forecasted_value:=
--                         l_final_forecasted_value / l_cnt_chld;
--                   END IF;
                  -------------------------------------------------------
                  -- if the count of rollup metrics is less than or
                  -- equal to 0, this may a be a summarization
                  -------------------------------------------------------
               ELSE
                  ------------------------------------------
                  -- check for horizontal summary metrics
                  ------------------------------------------
                  IF l_cal_type_rec.metric_calculation_type = 'SUMMARY' THEN
                     ----------------------------------
                     -- It is hori Summary Metric
                     ----------------------------------
                     ----------------------------------------------------------
                     -- Call Exec Rollup  to go to Lower Level and Calculate
                     -- Metric Value. This Proc is called in the Loop so will
                     -- be executed for each child of the Rollup Metric
                     -- The Parameter p_metric_type will tell this Proc whether
                     -- the metric is Rollup or Summary The Only difference
                     -- between calculation of Summary and Rollup Metric is
                     -- For Rollup Metric we have to validate the Child entity
                     ----------------------------------------------------------
                     Exec_Summary(p_api_version    => l_api_version,
                         p_init_msg_list  => p_init_msg_list,
                         p_commit         => p_commit ,
                         x_return_status  => x_return_status,
                         x_msg_count      => x_msg_count,
                         x_msg_data       => x_msg_data,
                         p_act_metric_id  => p_activity_metric_id,
                         x_actual_value  => l_actual_value ,
                         x_forecasted_value=> l_forecasted_value ,
                         p_metric_value_type=> l_cal_type_rec.value_type,
                         p_refresh_function => p_refresh_function,
                         p_func_currency_code => p_func_currency_code);
                     ----------------------------------
                     -- If any errors happen abort API.
                     ----------------------------------
                     IF x_return_status = Fnd_Api.G_RET_STS_ERROR THEN
                        RAISE Fnd_Api.G_EXC_ERROR;
                     ELSIF x_return_status = Fnd_Api.G_RET_STS_UNEXP_ERROR THEN
                        RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
                     END IF;
                     ---------------------------------------
                     -- Sum-up the values returned for the
                     -- child metrics
                     ---------------------------------------
                     l_final_actual_value     := NVL(l_actual_value,0);
                     l_final_forecasted_value := NVL(l_forecasted_value,0);
                     --------------------------------------------------
                     -- Now If the Value type is 'R' (It's Ratio Metric,
                     -- Divide the Sum by number of childs , it will
                     -- give you average
                     --------------------------------------------------
--                      IF l_cal_type_rec.value_type = 'R' THEN
--                         l_final_actual_value :=  l_final_actual_value / l_cnt_chld;
--                         l_final_forecasted_value :=  l_final_forecasted_value / l_cnt_chld;
--                      END IF;
                     -----------------------------------------------------
                     -- if no rows are found for rollup or summary then
                     -----------------------------------------------------
                  END IF ;         -- For Summary
               END IF; -- For Rollup
               IF l_origin_rec.functional_currency_code IS NOT NULL THEN
                  l_func_currency_code := p_func_currency_code;
               ELSE
                  l_func_currency_code := NULL;
               END IF;
            END IF;  -- For Apport
         END IF ;     -- For Cal_type
      -------------------------------------------------------------------
      -- if this is not a FIXED type metrics, then it is VARIABLE type
      -- this requires that another function be executed to calculate
      -- the metrics. No need to compute forecasted in VARIABLE type.
      -------------------------------------------------------------------
      ELSIF l_cal_type_rec.accrual_type = 'VARIABLE' THEN

         ----------------------------------------------------------
         -- execute the function
         ----------------------------------------------------------
         -- 06/22/2001 huili change
         -- 06/14/2001 huili commented out since it is not supported by 11.5.5
         --l_compute_using_function_value := Exec_Function(
         --        p_activity_metric_id => p_activity_metric_id,
         --        p_function_name => l_cal_type_rec.compute_using_function);
         --l_compute_using_function_value := 0;

         l_actual_value := NULL;
         l_forecasted_value := NULL;

         OPEN c_var_met_info (l_origin_rec.depend_act_metric);
         FETCH c_var_met_info INTO l_actual_value, l_forecasted_value;
         CLOSE c_var_met_info;

         ----------------------------------------------------------
         -- now actual value is multiple of the value from the
         -- function and that read for variable value from the
         -- table.
         ----------------------------------------------------------
         l_actual_value := NVL(l_actual_value,0)
                           * NVL(l_origin_rec.variable_value,0);
         l_forecasted_value := NVL(l_forecasted_value,0);
         -- end of change

         IF (l_cal_type_rec.default_uom_code IS NOT NULL) AND
            (l_origin_rec.metric_uom_code IS NOT NULL) THEN
            -------------------------------------------------------------------
            -- Convert the Actual value calculated into Base UOM amount
            -- While Updating Activity Metric Table with refreshed metric value,
            --  This will be converted back to UOM of this Activity Metric
            -------------------------------------------------------------------
            l_final_actual_value := Convert_Uom(
                 p_from_uom_code => l_origin_rec.metric_uom_code,
                 p_to_uom_code   => l_cal_type_rec.default_uom_code,
                 p_from_quantity => l_actual_value);

            --06/28/2001 huili
            l_final_forecasted_value := Convert_Uom(
                    p_from_uom_code => l_origin_rec.metric_uom_code,
                    p_to_uom_code   => l_cal_type_rec.default_uom_code,
                    p_from_quantity => l_forecasted_value);

            IF l_final_actual_value < 0 THEN
               l_final_actual_value := 0 ;
               RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
            END IF; --check final value
         ELSE
            IF l_origin_rec.functional_currency_code IS NOT NULL THEN
               l_func_currency_code := p_func_currency_code;
            ELSE
               l_func_currency_code := NULL;
            END IF;
            l_final_actual_value := l_actual_value;
            l_final_forecasted_value := l_forecasted_value;
         END IF; --if there is UOM
      END IF;      -- For Fixed/Var
   END IF ;         --   For %FOUND
   ---------------------------------------------------------------
   -- Added by bgeorge to make sure the transac actual value
   -- reflects the func actual value if there is no UOM or
   -- Currency conversion
   ---------------------------------------------------------------

   l_conv_uom_actual_value := l_final_actual_value;
   l_conv_uom_forecasted_value := l_final_forecasted_value;

   IF (l_cal_type_rec.default_uom_code IS NOT NULL) AND
      (l_origin_rec.metric_uom_code IS NOT NULL) THEN
      ---------------------------------------------------------------
      -- Convert the UOM Back to the Original UOM (As the Value
      -- Calculated is in Default UOM of this Metric )
      ---------------------------------------------------------------
      l_conv_uom_actual_value := Convert_Uom(
           p_from_uom_code => l_cal_type_rec.default_uom_code,
           p_to_uom_code   => l_origin_rec.metric_uom_code,
           p_from_quantity => l_final_actual_value);
      l_conv_uom_forecasted_value := Convert_Uom(
           p_from_uom_code => l_cal_type_rec.default_uom_code,
           p_to_uom_code   => l_origin_rec.metric_uom_code,
           p_from_quantity => l_final_forecasted_value);
      IF (l_conv_uom_actual_value < 0) OR (l_conv_uom_forecasted_value < 0) THEN
         l_final_actual_value := 0 ;
         l_final_forecasted_value := 0;
         RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
      END IF;
   END IF;
   ----------------------------------------------
   -- set return value for this procedure
   ----------------------------------------------
   x_actual_value       := l_final_actual_value ;
   x_forecasted_value   := l_final_forecasted_value;

   -------------------------------------------------------------
   -- Initialize the record type for Activity Metric update
   -------------------------------------------------------------
   Ams_Actmetric_Pvt.Init_ActMetric_Rec(x_act_metric_rec => l_act_metrics_rec );
   -- BUG2385692: Set transaction values to recalculate.
   l_act_metrics_rec.trans_actual_value       := NULL;
   l_act_metrics_rec.trans_forecasted_value   := NULL;
   l_act_metrics_rec.func_actual_value        := l_conv_uom_actual_value;
   l_act_metrics_rec.func_forecasted_value    := l_conv_uom_forecasted_value;
   l_act_metrics_rec.functional_currency_code := l_func_currency_code;
   l_act_metrics_rec.activity_metric_id       := p_activity_metric_id;
   l_act_metrics_rec.computed_using_function_value :=
                        l_compute_using_function_value;
   l_act_metrics_rec.difference_since_last_calc :=
      l_act_metrics_rec.func_actual_value - l_origin_rec.func_actual_value;
   l_act_metrics_rec.days_since_last_refresh  :=
      l_current_date - l_origin_rec.last_calculated_date;
   l_act_metrics_rec.last_calculated_date     := l_current_date;
   l_act_metrics_rec.dirty_flag               := 'N';

    Ams_Actmetric_Pvt.update_actmetric (
            p_api_version                => l_api_version,
            p_init_msg_list              => p_init_msg_list,
            p_commit                     => Fnd_Api.G_FALSE,
            p_validation_level           => Fnd_Api.g_valid_level_full,
            p_act_metric_rec             => l_act_metrics_rec,
            x_return_status              => x_return_status,
            x_msg_count                  => x_msg_count,
            x_msg_data                   => x_msg_data);

    IF x_return_status = Fnd_Api.G_RET_STS_ERROR THEN
       RAISE Fnd_Api.G_EXC_ERROR;
    ELSIF x_return_status = Fnd_Api.G_RET_STS_UNEXP_ERROR THEN
       RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
    END IF;

   -- Call Campaign API /Deliverable API/Events API to update the values
   -- Chect the x_return_status after the Update
   -- Handle the Error
   --
   -- End API Body.
   --
   --
   -- Standard check for commit request.
   --
   IF Fnd_Api.To_Boolean (p_commit) THEN
      COMMIT WORK;
   END IF;
   --
   -- Standard API to get message count, and if 1,
   -- set the message data OUT variable.
   --
   Fnd_Msg_Pub.Count_And_Get (
      p_count           =>    x_msg_count,
      p_data            =>    x_msg_data,
      p_encoded         =>    Fnd_Api.G_FALSE
   );
   --
   -- Add success message to message list.
   --
   IF AMS_DEBUG_HIGH_ON THEN
   Ams_Utility_Pvt.debug_message(l_full_name ||': end');
   END IF;
EXCEPTION
   WHEN Fnd_Api.G_EXC_ERROR THEN
--      ROLLBACK TO CALCULATE_METRIC_SAVEPOINT;
      x_return_status := Fnd_Api.G_RET_STS_ERROR;
      Fnd_Msg_Pub.Count_And_Get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data,
         p_encoded       =>     FND_API.G_FALSE
      );
      RAISE Fnd_Api.G_EXC_ERROR;
   WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
--      ROLLBACK TO CALCULATE_METRIC_SAVEPOINT;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      Fnd_Msg_Pub.Count_And_Get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data,
         p_encoded       =>     FND_API.G_FALSE
      );
      RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR ;
    when ams_utility_pvt.resource_locked then
         Fnd_Message.set_name('AMS', 'AMS_API_RESOURCE_LOCKED');
         Fnd_Msg_Pub.ADD;
      RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR ;
   WHEN OTHERS THEN
--      ROLLBACK TO CALCULATE_METRIC_SAVEPOINT;

      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      IF Fnd_Msg_Pub.Check_Msg_Level (Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR) THEN
         Fnd_Msg_Pub.Add_Exc_Msg (G_PKG_NAME, L_API_NAME);
      END IF;
      Fnd_Msg_Pub.Count_And_Get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data,
         p_encoded       =>     FND_API.G_FALSE
      );
      RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR ;

END Calculate_Metric;

-- Start of comments
-- NAME
--    Copy_seeded_Metric
--
-- PURPOSE
--    This Procedure is called when a new Usage(Campaign/Event/Del.) is Created
--    This will check the templates defined for the given usage ,usage type
--    and will copy the metrics associated with this Template to the Activity
--    Metric.
--    For e.g. when Campaign c1 is created with type type1 , this process will
--    check the template defined for campaigns (or if avilable Template for this
--    Campaign for this campaign type )  .If Metric M1,M2,M3 are attached to
--    Campaigns then the rows are inserted into Activity Metric table for
--    M1,M2,M3 attached to C1.
--
-- NOTES
--
-- HISTORY
-- 10/06/1999   ptendulk         Created.
-- 27-FEB-2000    bgeorge        Modified to call the trigger API for metrics
--                               refresh in the copy_seeded_metrics
-- 05/08/2000     bgeorge        Commented out the call to create triggers
-- 07/17/2000     khung    bug 1356700 fix. add check category_id in copy_seeded_metric
-- 02/26/2002   dmvincen   New Feature: Metric Templates extended features.
-- 25-dec-2002    choang         added enabled_flag to cursor c_tpl_all_metrics
-- 27-oct-2003    choang         Enh 3130095: optimized metric cursor and removed assocs
-- 02-nov-2003    choang         Enh 3199867: added support for Tracking custom setup
-- 21-Nov-2005   dmvincen BUG4742384: Copy fixed then variable.
-- End of comments

PROCEDURE Copy_Seeded_Metric (
   p_api_version                 IN  NUMBER,
   p_init_msg_list               IN  VARCHAR2 := Fnd_Api.G_FALSE,
   p_commit                      IN  VARCHAR2 := Fnd_Api.G_FALSE,
   x_return_status               OUT NOCOPY VARCHAR2,
   x_msg_count                   OUT NOCOPY NUMBER,
   x_msg_data                    OUT NOCOPY VARCHAR2,
   p_arc_act_metric_used_by      IN  VARCHAR2 ,
   p_act_metric_used_by_id       IN  NUMBER ,
   p_act_metric_used_by_type     IN  VARCHAR2
)
IS
   L_API_VERSION      CONSTANT NUMBER := 1.0;
   L_API_NAME         CONSTANT VARCHAR2(30) := 'Copy_Seeded_Metric';
   L_FULL_NAME        CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

   -- choang - 27-oct-2003
   -- enh 3130095: tuned query and use new schema for picking
   -- up the correct metrics to copy.
   -- when custom setup is involved, admins have the option
   -- to include or exclude any of the cue-cards:
   --    costs and revenues map to cateogry 901 and 902
   --    all other metrics go into the other cue-card
   --Bug# 3335711 - 23-dec-2003 - sunkumar -  added check for object type
   --BUG4742384: Copy fixed metrics first then variable.
   CURSOR c_tpl_all_metrics (l_object_type IN VARCHAR2,
                             l_setup_id IN NUMBER,
                             p_cost_flag IN NUMBER,
                             p_amet_flag IN NUMBER,
                             p_track_flag IN NUMBER) IS
      SELECT DISTINCT met.metric_id, met.metric_category, met.accrual_type
      FROM ams_metrics_all_b met, ams_met_tpl_details det, ams_met_tpl_headers_b tpl
      WHERE
      met.arc_metric_used_for_object IN ( l_object_type, 'ANY')
      AND met.enabled_flag = 'Y'
      AND met.metric_id = det.metric_id
      AND tpl.metric_tpl_header_id = det.metric_tpl_header_id
      AND tpl.enabled_flag = 'Y'
      AND det.enabled_flag = 'Y'
      AND ((1 = p_track_flag) OR
           (EXISTS (SELECT 1
                  FROM ams_categories_b cat
                  WHERE cat.category_id = met.metric_category
                  AND ((1 = p_cost_flag AND category_id IN (901, 902)) OR
                       (1 = p_amet_flag AND category_id NOT IN (901, 902))
                  AND enabled_flag = 'Y'))))
      AND ((tpl.association_type = 'OBJECT_TYPE'
           AND tpl.used_by_code = l_object_type)
       OR (tpl.association_type = 'CUSTOM_SETUP'
           AND tpl.used_by_id = l_setup_id))
      order by met.accrual_type
      ;

/***
   -- choang - 27-oct-2003
   -- enh 3130095: obsoleted query; no longer using met_tpl_assocs
   -- and the query had three full table scans in explain plan on
   -- dev instance mktd2r10 and mktu2r10.
   CURSOR c_tpl_all_metrics(l_object_type VARCHAR2, l_setup_id NUMBER) IS
      SELECT metric_id, metric_category
      FROM ams_metrics_all_b met
      WHERE met.arc_metric_used_for_object = l_object_type
      AND met.metric_calculation_type IN ('MANUAL', 'FUNCTION')
      AND met.enabled_flag = 'Y'
      AND metric_id IN
        (SELECT metric_id
         FROM ams_met_tpl_details dtl
         WHERE enabled_flag = 'Y'
         AND metric_tpl_header_id IN
            (SELECT metric_tpl_header_id FROM ams_met_tpl_headers_vl
             WHERE enabled_flag = 'Y'
             AND metric_tpl_header_id IN
                (SELECT metric_tpl_header_id FROM ams_met_tpl_assocs
                 WHERE enabled_flag = 'Y'
                 AND ASSOCIATION_TYPE = 'OBJECT_TYPE'
                 AND used_by_code = l_object_type
                 UNION ALL
                 SELECT metric_tpl_header_id FROM ams_met_tpl_assocs
                 WHERE enabled_flag = 'Y'
                 AND ASSOCIATION_TYPE = 'CUSTOM_SETUP'
                 AND used_by_id = l_setup_id
                )
            )
         )
      ;
***/

   CURSOR c_setup_attrs (p_custom_setup_id NUMBER) IS
      SELECT MAX (DECODE (object_attribute, 'COST', 1, 0)) cost_flag
           , MAX (DECODE (object_attribute, 'AMET', 1, 0)) amet_flag
           , MAX (DECODE (object_attribute, 'TRACK', 1, 0)) track_flag
      FROM ams_custom_setup_attr
      WHERE attr_available_flag = 'Y'
      AND custom_setup_id = p_custom_setup_id
      AND object_attribute IN ('COST', 'AMET', 'TRACK')
      ;

/*** cursor does one pass
   CURSOR c_setup_attrs(p_custom_setup_id NUMBER) IS
      SELECT object_attribute
      FROM ams_custom_setup_attr
      WHERE attr_available_flag = 'Y'
      AND custom_setup_id = p_custom_setup_id
      AND object_attribute IN ('COST', 'AMET');
***/

   l_setup_rec            c_setup_attrs%ROWTYPE;
   l_object_attribute ams_custom_setup_attr.OBJECT_ATTRIBUTE%TYPE;
   l_metric_id NUMBER;
   l_metric_category NUMBER;
   l_custom_setup_id NUMBER := NULL;
   l_act_metrics_rec Ams_Actmetric_Pvt.act_metric_rec_type;
   l_activity_metric_id      NUMBER;
   l_accrual_type VARCHAR2(2000);

   CURSOR c_get_camp_setup(p_campaign_id NUMBER) IS
      SELECT custom_setup_id
      FROM ams_campaigns_all_b
      WHERE campaign_id = p_campaign_id;

   CURSOR c_get_csch_setup(p_schedule_id NUMBER) IS
      SELECT custom_setup_id
      FROM AMS_CAMPAIGN_SCHEDULES_B
      WHERE schedule_id = p_schedule_id;

   CURSOR c_get_eveh_setup(p_event_id NUMBER) IS
      SELECT setup_type_id
      FROM AMS_EVENT_HEADERS_ALL_B
      WHERE EVENT_HEADER_ID = p_event_id;

   CURSOR c_get_eveo_setup(p_event_offer_id NUMBER) IS
      SELECT setup_type_id
      FROM AMS_EVENT_OFFERS_ALL_B
      WHERE EVENT_OFFER_ID = p_event_offer_id;

   CURSOR c_get_delv_setup(p_deliverable_id NUMBER) IS
      SELECT custom_setup_id
      FROM AMS_DELIVERABLES_ALL_B
      WHERE DELIVERABLE_ID = p_deliverable_id;

/*** choang - 27-oct-2003 - removed old code see previous version for commented code ***/
BEGIN
   --
   -- Initialize savepoint.
   --
   SAVEPOINT Copy_Seeded_Metric_pvt;
   --
   -- Output debug message.
   --
   IF AMS_DEBUG_HIGH_ON THEN
      Ams_Utility_Pvt.debug_message(l_full_name||': START');
      END IF;
   --
   -- Initialize message list if p_init_msg_list is set to TRUE.
   --
   IF Fnd_Api.To_Boolean (p_init_msg_list) THEN
      Fnd_Msg_Pub.Initialize;
   END IF;
   --
   -- Standard check for API version compatibility.
   --
   IF NOT Fnd_Api.Compatible_API_Call (L_API_VERSION,
                                       p_api_version,
                                       L_API_NAME,
                                       G_PKG_NAME)
   THEN
      RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
   END IF;
   --
   -- Initialize API return status to success.
   --
   x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
   --
   -- Begin API Body
   --
   IF p_arc_act_metric_used_by IN ('RCAM', 'CAMP') THEN
      OPEN c_get_camp_setup(p_act_metric_used_by_id);
      FETCH c_get_camp_setup INTO l_custom_setup_id;
      CLOSE c_get_camp_setup;
   ELSIF p_arc_act_metric_used_by IN ('CSCH') THEN
      OPEN c_get_csch_setup(p_act_metric_used_by_id);
      FETCH c_get_csch_setup INTO l_custom_setup_id;
      CLOSE c_get_csch_setup;
   ELSIF p_arc_act_metric_used_by IN ('EVEH') THEN
      OPEN c_get_eveh_setup(p_act_metric_used_by_id);
      FETCH c_get_eveh_setup INTO l_custom_setup_id;
      CLOSE c_get_eveh_setup;
   ELSIF p_arc_act_metric_used_by IN ('EVEO', 'EONE') THEN
      OPEN c_get_eveo_setup(p_act_metric_used_by_id);
      FETCH c_get_eveo_setup INTO l_custom_setup_id;
      CLOSE c_get_eveo_setup;
   ELSIF p_arc_act_metric_used_by IN ('DELV') THEN
      OPEN c_get_delv_setup(p_act_metric_used_by_id);
      FETCH c_get_delv_setup INTO l_custom_setup_id;
      CLOSE c_get_delv_setup;
   /***** BUG2845365: Remove dialogue Components. *****
   ELSIF p_arc_act_metric_used_by IN ('DILG') THEN
      OPEN c_get_dilg_setup(p_act_metric_used_by_id);
      FETCH c_get_dilg_setup INTO l_custom_setup_id;
      CLOSE c_get_dilg_setup;
   ELSIF p_arc_act_metric_used_by in
        ('AMS_COMP_START', 'AMS_COMP_SHOW_WEB_PAGE', 'AMS_COMP_END') THEN
        l_has_amet := fnd_api.g_true;
   ****** BUG2845365 ******/
   END IF;

   -- choang - 27-oct-2003 - flag consists of 1 or 0
   l_setup_rec.cost_flag := 1;
   l_setup_rec.amet_flag := 1;
   l_setup_rec.track_flag := 1;

   IF l_custom_setup_id IS NULL THEN
      l_custom_setup_id := -1; -- undefined setup.
   ELSE
      OPEN c_setup_attrs(l_custom_setup_id);
      FETCH c_setup_attrs INTO l_setup_rec;
      CLOSE c_setup_attrs;

   END IF;

   OPEN c_tpl_all_metrics(p_arc_act_metric_used_by,
                          l_custom_setup_id,
                          l_setup_rec.cost_flag,
                          l_setup_rec.amet_flag,
                          l_setup_rec.track_flag);
   LOOP
      FETCH c_tpl_all_metrics INTO l_metric_id, l_metric_category,
            l_accrual_type;
      EXIT WHEN c_tpl_all_metrics%NOTFOUND;
   IF AMS_DEBUG_HIGH_ON THEN
      Ams_Utility_Pvt.debug_message(l_full_name||': Metric_Id='||l_metric_id);
   END IF;
/*** choang - 27-oct-2003 - optimized to filter in the metric query
      IF (l_has_cost = FND_API.G_TRUE AND l_metric_category IN (901,902)) OR
         (l_has_amet = FND_API.G_TRUE AND l_metric_category NOT IN (901,902)) THEN
***/
         l_act_metrics_rec.metric_id := l_metric_id ;
         l_act_metrics_rec.arc_act_metric_used_by := p_arc_act_metric_used_by;
         l_act_metrics_rec.act_metric_used_by_id  := p_act_metric_used_by_id;
         l_act_metrics_rec.application_id := 530  ; -- Oracle Marketing
         Ams_Actmetric_Pub.Create_ActMetric (
               p_api_version                => p_api_version,
               p_init_msg_list              => Fnd_Api.G_FALSE,
               p_commit                     => Fnd_Api.G_FALSE,
               p_validation_level           => Fnd_Api.g_valid_level_full,
               p_act_metric_rec             => l_act_metrics_rec,
               x_return_status              => x_return_status,
               x_msg_count                  => x_msg_count,
               x_msg_data                   => x_msg_data,
               x_activity_metric_id         => l_activity_metric_id
               );
         -- If any errors happen abort API.
         IF x_return_status = Fnd_Api.G_RET_STS_ERROR THEN
               RAISE Fnd_Api.G_EXC_ERROR;
         ELSIF x_return_status = Fnd_Api.G_RET_STS_UNEXP_ERROR THEN
               RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
         END IF;
/***      END IF; ***/
   END LOOP;
   CLOSE c_tpl_all_metrics;
/*** choang - 27-oct-2003 - removed old code from 2000
   -- Bug fix 1265154
   -- 05/08/2000  BGEORGE
***/
   -- End API Body
   --
   --
   -- Standard API to get message count, and if 1,
   -- set the message data OUT variable.
   --
   Fnd_Msg_Pub.Count_And_Get (
      p_count           =>    x_msg_count,
      p_data            =>    x_msg_data,
      p_encoded         =>    Fnd_Api.G_FALSE
   );
   --
   -- Debug message.
   --
   IF AMS_DEBUG_HIGH_ON THEN
   Ams_Utility_Pvt.debug_message(l_full_name ||': END');
   END IF;
EXCEPTION
   WHEN Fnd_Api.G_EXC_ERROR THEN
      ROLLBACK TO Copy_Seeded_Metric_pvt;
      x_return_status := Fnd_Api.G_RET_STS_ERROR;
      Fnd_Msg_Pub.Count_And_Get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data,
         p_encoded       =>     FND_API.G_FALSE
      );
   WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Copy_Seeded_Metric_pvt;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      Fnd_Msg_Pub.Count_And_Get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data,
         p_encoded       =>     FND_API.G_FALSE
      );
   WHEN OTHERS THEN
      ROLLBACK TO Copy_Seeded_Metric_pvt;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      IF Fnd_Msg_Pub.Check_Msg_Level (Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR) THEN
         Fnd_Msg_Pub.Add_Exc_Msg (G_PKG_NAME, L_API_NAME);
      END IF;
      Fnd_Msg_Pub.Count_And_Get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data,
         p_encoded       =>     FND_API.G_FALSE
      );
END Copy_seeded_Metric;
--
-- NAME
--    Get_Apport_Met_ID
--
-- PURPOSE
--    Returns the Metric ID for the apportioned Metric.
--
-- NOTES
--    This function is not complete as of 10/19/1999 , Pending Issue
--
-- HISTORY
-- 10/22/1999   ptendulk         Created.
--
FUNCTION Get_Apport_Met_ID(p_master_object_type IN VARCHAR2)
RETURN NUMBER
IS
BEGIN
-- Will have to be changed
   RETURN 10000;
END Get_Apport_Met_ID;
-- Start of comments
-- NAME
--    Create_Apport_Metric
--
-- PURPOSE
--    This Procedure is called when a new Object association is created.
--    This will create Activity Metric in AMS_ACT_METRICS_ALL with the details
--    of the association.
--
-- NOTES
--
-- HISTORY
-- 10/06/1999   ptendulk         Created.
--
-- End of comments
PROCEDURE Create_Apport_Metric(
   p_api_version                 IN  NUMBER,
   p_init_msg_list               IN  VARCHAR2 := Fnd_Api.G_FALSE,
   p_commit                      IN  VARCHAR2 := Fnd_Api.G_FALSE,
   x_return_status               OUT NOCOPY VARCHAR2,
   x_msg_count                   OUT NOCOPY NUMBER,
   x_msg_data                    OUT NOCOPY VARCHAR2,
   p_obj_association_id          IN  NUMBER
)
IS
   L_API_VERSION     CONSTANT NUMBER := 1.0;
   L_API_NAME        CONSTANT VARCHAR2(30) := 'Create_Apportioned_Metric';
   L_FULL_NAME       CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| L_API_NAME;
   CURSOR c_obj_det  IS
      SELECT master_object_type,
             master_object_id
      FROM   ams_object_associations
      WHERE  object_association_id = p_obj_association_id ;
   CURSOR c_act_met             IS
       SELECT COUNT(1)
       FROM      ams_act_metrics_all
       WHERE  activity_metric_origin_id = p_obj_association_id ;
   l_obj_det_rec       c_obj_det%ROWTYPE ;
   -- Initialize Activity Metric Record type for Insertion/Updation of Act. Metric
   l_act_metrics_rec Ams_Actmetric_Pvt.act_metric_rec_type ;
   l_amount   NUMBER;
   l_count    NUMBER;
   l_activity_metric_id  NUMBER  ;
   l_return_status VARCHAR2(1) ;
BEGIN
   --
   -- Initialize savepoint.
   --
   SAVEPOINT Create_App_Metric_pvt;
   --
   -- Output debug message.
   --
   IF AMS_DEBUG_HIGH_ON THEN
   Ams_Utility_Pvt.Debug_Message(l_full_name||': START');
   END IF;
   --
   -- Initialize message list if p_init_msg_list is set to TRUE.
   --
   IF Fnd_Api.To_Boolean (p_init_msg_list) THEN
      Fnd_Msg_Pub.Initialize;
   END IF;
   --
   -- Standard check for API version compatibility.
   --
   IF NOT Fnd_Api.Compatible_API_Call (L_API_VERSION,
                                       p_api_version,
                                       L_API_NAME,
                                       G_PKG_NAME)
   THEN
      RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
   END IF;
   --
   -- Initialize API return status to success.
   --
   x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
   --
   -- Begin API Body
   --
   Get_Met_Apport_Val(
              p_obj_association_id   => p_obj_association_id,
              x_return_status        => x_return_status,
              x_apportioned_value       => l_amount
   ) ;
   OPEN  c_act_met ;
   FETCH c_act_met INTO l_count ;
   CLOSE c_act_met ;
   IF l_count > 0 THEN
      -- Update Activity Metric
      -- Initialize the record type for Activity Metric updation
      Ams_Actmetric_Pvt.Init_ActMetric_Rec(
            x_act_metric_rec => l_act_metrics_rec );
      l_act_metrics_rec.activity_metric_origin_id := p_obj_association_id ;
      l_act_metrics_rec.func_actual_value := l_amount ;
      l_act_metrics_rec.trans_actual_value :=
            l_act_metrics_rec.func_actual_value ;
      Ams_Actmetric_Pvt.Update_ActMetric (
           p_api_version                => l_api_version,
           p_init_msg_list              => p_init_msg_list,
           p_commit                     => Fnd_Api.G_FALSE,
           p_validation_level           => Fnd_Api.g_valid_level_full,
           p_act_metric_rec             => l_act_metrics_rec,
           x_return_status              => l_return_status,
           x_msg_count                  => x_msg_count,
           x_msg_data                   => x_msg_data
      );
   ELSE
      -- Insert Activity Metric
      OPEN  c_obj_det ;
      FETCH c_obj_det INTO l_obj_det_rec ;
      CLOSE c_obj_det ;
      l_act_metrics_rec.activity_metric_origin_id := p_obj_association_id ;
      l_act_metrics_rec.func_actual_value := l_amount ;
      l_act_metrics_rec.trans_actual_value := l_amount ;
      -- Give call to routine which will decide the Apportioned Metric ID for
      -- this Activity Metric
      l_act_metrics_rec.metric_id :=
            Get_Apport_Met_ID(l_obj_det_rec.master_object_type) ;
      l_act_metrics_rec.act_metric_used_by_id :=
            l_obj_det_rec.master_object_id;
      l_act_metrics_rec.arc_act_metric_used_by :=
            l_obj_det_rec.master_object_type;
      l_act_metrics_rec.application_id         := 530 ;
      -- Give Call to Default_Func_Currency to decide default Currency code
      l_act_metrics_rec.functional_currency_code  :=
          Ams_Actmetric_Pvt.default_func_currency ;
      l_act_metrics_rec.transaction_currency_code :=
          l_act_metrics_rec.functional_currency_code ;
      Ams_Actmetric_Pub.Create_ActMetric (
            p_api_version                => l_api_version,
            p_init_msg_list              => p_init_msg_list,
            p_commit                     => Fnd_Api.G_FALSE,
            p_validation_level           => Fnd_Api.g_valid_level_full,
            p_act_metric_rec             => l_act_metrics_rec,
            x_return_status              => l_return_status,
            x_msg_count                  => x_msg_count,
            x_msg_data                   => x_msg_data,
            x_activity_metric_id         => l_activity_metric_id
      );
   END IF;
   -- If any errors happen abort API.
   IF l_return_status = Fnd_Api.G_RET_STS_ERROR THEN
      RAISE Fnd_Api.G_EXC_ERROR;
   ELSIF l_return_status = Fnd_Api.G_RET_STS_UNEXP_ERROR THEN
      RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
   END IF;
      --
   -- Standard API to get message count, and if 1,
   -- set the message data OUT variable.
   --
   Fnd_Msg_Pub.Count_And_Get (
      p_count           =>    x_msg_count,
      p_data            =>    x_msg_data,
      p_encoded         =>    Fnd_Api.G_FALSE
   );
   --
   -- Add success message to message list.
   --
   IF AMS_DEBUG_HIGH_ON THEN
   Ams_Utility_Pvt.debug_message(l_full_name ||': END Success');
   END IF;
EXCEPTION
   WHEN Fnd_Api.G_EXC_ERROR THEN
      ROLLBACK TO Create_App_Metric_pvt;
      x_return_status := Fnd_Api.G_RET_STS_ERROR;
      Fnd_Msg_Pub.Count_And_Get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data,
         p_encoded       =>     FND_API.G_FALSE
      );
   WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Create_App_Metric_pvt;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      Fnd_Msg_Pub.Count_And_Get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data,
         p_encoded       =>     FND_API.G_FALSE
      );
   WHEN OTHERS THEN
      ROLLBACK TO Create_App_Metric_pvt;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      IF Fnd_Msg_Pub.Check_Msg_Level (Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR) THEN
         Fnd_Msg_Pub.Add_Exc_Msg (G_PKG_NAME, L_API_NAME);
      END IF;
      Fnd_Msg_Pub.Count_And_Get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data,
         p_encoded       =>     FND_API.G_FALSE
      );
END Create_Apport_Metric;

-- Start of Comments
--
-- NAME
--   Refresh_Act_metrics
--
-- PURPOSE
--   This procedure wraps around Refresh_Metric and is called
--   from concurrent program
--
-- NOTES
--
--
-- HISTORY
--   05/02/1999      bgeorge    created
-- End of Comments


PROCEDURE Refresh_Act_metrics (
          errbuf        OUT    NOCOPY VARCHAR2,
          retcode       OUT    NOCOPY NUMBER,
          p_update_history IN  VARCHAR2 := Fnd_Api.G_FALSE
)
IS
BEGIN
   -- DMVINCEN: 04-APR-2001: New routine.
   Ams_Actmetrics_Engine_Pvt.Refresh_Act_Metrics_Engine(
                        x_errbuf => errbuf,
                        x_retcode => retcode,
                         p_update_history => p_update_history);
END Refresh_Act_Metrics;

-- Start of comments
-- NAME
--    Refresh_Metric
--
-- PURPOSE
--   Re-calculate the value for a given activity metric.
--
-- NOTES
--
-- HISTORY
-- 07/05/1999   choang     Created.
-- 09/28/1999   ptendulk   Modified
-- 08/16/2001   dmvincen   Pass the default currency to syncronize.
-- 08/16/2001   dmvincen   Removed unused parameters from calculate_metric
-- 08/30/2001   huili      Added call to the procedure "Run_Object_Procedures".
PROCEDURE Refresh_Metric (
   p_api_version                 IN     NUMBER,
   p_init_msg_list               IN     VARCHAR2 := Fnd_Api.G_TRUE,
   p_commit                      IN     VARCHAR2 := Fnd_Api.G_FALSE,
   x_return_status               OUT    NOCOPY VARCHAR2,
   x_msg_count                   OUT    NOCOPY NUMBER,
   x_msg_data                    OUT    NOCOPY VARCHAR2,
   p_activity_metric_id          IN     NUMBER,
   p_refresh_type                IN     VARCHAR2,
   p_refresh_function            IN     VARCHAR2 := Fnd_Api.G_TRUE
)
IS
   L_API_VERSION      CONSTANT NUMBER := 1.0;
   L_API_NAME         VARCHAR2(30) := 'Refresh_Metric';
   L_FULL_NAME        CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
   l_function_name    VARCHAR2(30);
   l_actual_value        NUMBER;
   l_forecasted_value NUMBER;

   -- This Cursor will Select the Metric ID and
        -- Usage details for the Activity Metrics
   CURSOR c_act_metric(l_act_metric_id NUMBER) IS
      SELECT metric_id,
      arc_act_metric_used_by,
      act_metric_used_by_id,
      metric_uom_code
      FROM ams_act_metrics_all
      WHERE activity_metric_id = l_act_metric_id;
   l_act_metric_rec         c_act_metric%ROWTYPE;
   --
   -- Retrieve all associated activities for the given
   -- business entity, identified by the combination of
   -- ARC_ACT_METRIC_USED_BY and ACT_METRIC_USED_BY_ID.
        --
   CURSOR c_all_metrics(l_arc_act_metric_used_by VARCHAR2,
                        l_act_metric_used_by_id NUMBER) IS
      SELECT activity_metric_id,actmet.metric_id,actmet.dirty_flag,
            met.metric_calculation_type
      FROM   ams_act_metrics_all actmet, ams_metrics_all_b met
      WHERE  actmet.metric_id = met.metric_id
      AND    actmet.arc_act_metric_used_by = l_arc_act_metric_used_by
      AND    actmet.act_metric_used_by_id = l_act_metric_used_by_id
      AND    actmet.summarize_to_metric IS NULL;
      --AND   (dirty_flag = 'Y' OR metric_calculation_type = 'FUNCTION');

      -- select only the dirty records or FUNCTION type records,
      -- added SVEERAVE - 10/13/00,12/14/00
   l_all_metrics_rec       c_all_metrics%ROWTYPE;
BEGIN
   --
   -- Initialize savepoint.
   --
   SAVEPOINT Refresh_Metric_SavePoint;
   --
   -- Output debug message.
   --
   IF AMS_DEBUG_HIGH_ON THEN
   Ams_Utility_Pvt.debug_message(l_full_name||': START');
   END IF;
   --
   -- Initialize message list if p_init_msg_list is set to TRUE.
   --
   IF Fnd_Api.To_Boolean (p_init_msg_list) THEN
      Fnd_Msg_Pub.Initialize;
   END IF;
   --
   -- Standard check for API version compatibility.
   --
   IF NOT Fnd_Api.Compatible_API_Call (L_API_VERSION,
                                       p_api_version,
                                       L_API_NAME,
                                       G_PKG_NAME)
   THEN
      RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
   END IF;
   --
   -- Initialize API return status to success.
   --
   x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
   --
   -- Begin API Body.
   --



   OPEN c_act_metric(p_activity_metric_id);
   FETCH c_act_metric INTO l_act_metric_rec;
   IF c_act_metric%NOTFOUND THEN
      -- activity metric not found
      IF Fnd_Msg_Pub.Check_Msg_Level (Fnd_Msg_Pub.G_MSG_LVL_ERROR)
      THEN -- MMSG
         Fnd_Message.Set_Name('AMS', 'AMS_METR_INVALID_ACT_METR');
         Fnd_Msg_Pub.ADD;
      END IF;
      CLOSE c_act_metric;
      RAISE Fnd_Api.G_EXC_ERROR;
   END IF;
   CLOSE c_act_metric;

   Run_Object_Procedures (
      p_arc_act_metric_used_by => l_act_metric_rec.arc_act_metric_used_by,
      p_act_metric_used_by_id  => l_act_metric_rec.act_metric_used_by_id);

   -- Refresh or Create the association metric between dependent
   -- and master objects.

   -- 06/19/2001 huili commented out since it is out of date
   --create_refresh_assoc_metrics(l_act_metric_rec.arc_act_metric_used_by,
   --                           l_act_metric_rec.act_metric_used_by_id);

   IF p_refresh_type = 'ONE'
   THEN
   -- Only Current Activity Metric Has to be refreshed
      Calculate_Metric (
         p_api_version            => l_api_version ,
         p_init_msg_list          => p_init_msg_list,
         p_commit                 => Fnd_Api.G_FALSE,
         x_return_status          => x_return_status,
         x_msg_count              => x_msg_count,
         x_msg_data               => x_msg_data,
         p_activity_metric_id     => p_activity_metric_id,
--          p_act_metric_used_by_id  => l_act_metric_rec.act_metric_used_by_id,
--          p_arc_act_metric_used_by => l_act_metric_rec.arc_act_metric_used_by,
--          p_act_metric_uom_code    => l_act_metric_rec.metric_uom_code,
         x_actual_value              => l_actual_value,
         x_forecasted_value          => l_forecasted_value,
         p_refresh_function          => p_refresh_function,
         p_func_currency_code     => Ams_Actmetric_Pvt.DEFAULT_FUNC_CURRENCY);
      -- If any errors happen abort API.
      IF x_return_status = Fnd_Api.G_RET_STS_ERROR THEN
         RAISE Fnd_Api.G_EXC_ERROR;
      ELSIF x_return_status = Fnd_Api.G_RET_STS_UNEXP_ERROR THEN
         RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
      END IF;

   ELSIF p_refresh_type = 'ALL'
        THEN
   -- All the Activity Metrics attached to the current usage has to be refreshed
      OPEN c_all_metrics(l_act_metric_rec.arc_act_metric_used_by,
                         l_act_metric_rec.act_metric_used_by_id);
      LOOP
         FETCH c_all_metrics INTO l_all_metrics_rec;
         EXIT WHEN c_all_metrics%NOTFOUND;
   IF AMS_DEBUG_MEDIUM_ON THEN
         Ams_Utility_Pvt.debug_message('Now Calling Calc Met FOR: '||
             l_act_metric_rec.act_metric_used_by_id||'-'||
             l_act_metric_rec.arc_act_metric_used_by);
             END IF;
         Calculate_Metric (
           p_api_version            => l_api_version ,
           p_init_msg_list          => p_init_msg_list,
           p_commit                 => Fnd_Api.G_FALSE,
           x_return_status          => x_return_status,
           x_msg_count              => x_msg_count,
           x_msg_data               => x_msg_data,
           p_activity_metric_id     => l_all_metrics_rec.activity_metric_id,
--         p_act_metric_used_by_id  => l_act_metric_rec.act_metric_used_by_id,
--         p_arc_act_metric_used_by => l_act_metric_rec.arc_act_metric_used_by,
--         p_act_metric_uom_code    => l_act_metric_rec.metric_uom_code,
           x_actual_value           => l_actual_value,
           x_forecasted_value       => l_forecasted_value,
           p_refresh_function       => p_refresh_function,
           p_func_currency_code     => Ams_Actmetric_Pvt.DEFAULT_FUNC_CURRENCY);

         -- If any errors happen abort API.
         IF x_return_status = Fnd_Api.G_RET_STS_ERROR THEN
            RAISE Fnd_Api.G_EXC_ERROR;
         ELSIF x_return_status = Fnd_Api.G_RET_STS_UNEXP_ERROR THEN
            RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
         END IF;
      END LOOP;
   END IF;
   --
   -- End API Body.
   --
   --
   -- Standard check for commit request.
   --
   IF Fnd_Api.To_Boolean (p_commit) THEN
      COMMIT WORK;
   END IF;
   --
   -- Standard API to get message count, and if 1,
   -- set the message data OUT variable.
   --
   Fnd_Msg_Pub.Count_And_Get (
      p_count           =>    x_msg_count,
      p_data            =>    x_msg_data,
      p_encoded         =>    Fnd_Api.G_FALSE
   );
   --
   -- Add success message to message list.
   --
   IF AMS_DEBUG_HIGH_ON THEN
   Ams_Utility_Pvt.debug_message(l_full_name ||': END');
   END IF;
EXCEPTION
   WHEN Fnd_Api.G_EXC_ERROR THEN
      ROLLBACK TO Refresh_Metric_SavePoint;
      x_return_status := Fnd_Api.G_RET_STS_ERROR;
      Fnd_Msg_Pub.Count_And_Get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data,
         p_encoded       =>     FND_API.G_FALSE
      );
   WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Refresh_Metric_SavePoint;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      Fnd_Msg_Pub.Count_And_Get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data,
         p_encoded       =>     FND_API.G_FALSE
      );
   WHEN OTHERS THEN
      ROLLBACK TO Refresh_Metric_SavePoint;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      IF Fnd_Msg_Pub.Check_Msg_Level (Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR) THEN
         Fnd_Msg_Pub.Add_Exc_Msg (G_PKG_NAME, L_API_NAME);
      END IF;
      Fnd_Msg_Pub.Count_And_Get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data,
         p_encoded       =>     FND_API.G_FALSE
      );
END Refresh_Metric;

-- Start of comments
-- NAME
--    Refresh_Metric
--
-- PURPOSE
--   Re-calculate the value for a given activity metric.
--   This accepts the object information to do the refresh.
--
-- NOTES
--
-- HISTORY
-- 08/16/2001  dmvincen  Created
--
PROCEDURE Refresh_Metric (
   p_api_version                 IN     NUMBER,
   p_init_msg_list               IN     VARCHAR2 := Fnd_Api.G_TRUE,
   p_commit                      IN     VARCHAR2 := Fnd_Api.G_FALSE,
   x_return_status               OUT    NOCOPY VARCHAR2,
   x_msg_count                   OUT    NOCOPY NUMBER,
   x_msg_data                    OUT    NOCOPY VARCHAR2,
   p_arc_act_metric_used_by      IN     VARCHAR2,
   p_act_metric_used_by_id       IN     NUMBER,
   p_refresh_function            IN     VARCHAR2 := Fnd_Api.G_TRUE
)
IS
   L_API_VERSION      CONSTANT NUMBER := 1.0;
   L_API_NAME         VARCHAR2(30) := 'Refresh_Metric';
   L_FULL_NAME        CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
   l_function_name    VARCHAR2(30);
   l_actual_value        NUMBER;
   l_forecasted_value NUMBER;

   -- This Cursor will Select the Metric ID and
        -- Usage details for the Activity Metrics
--    CURSOR c_act_metric(l_act_metric_id NUMBER) IS
--       SELECT metric_id,
--       arc_act_metric_used_by,
--       act_metric_used_by_id,
--       metric_uom_code
--       FROM ams_act_metrics_all
--       WHERE activity_metric_id = l_act_metric_id;
--    l_act_metric_rec         c_act_metric%ROWTYPE;
   --
   -- Retrieve all associated activities for the given
   -- business entity, identified by the combination of
   -- ARC_ACT_METRIC_USED_BY and ACT_METRIC_USED_BY_ID.
        --

   CURSOR c_all_metrics(l_arc_act_metric_used_by VARCHAR2,
                        l_act_metric_used_by_id NUMBER) IS
      SELECT activity_metric_id,actmet.metric_id,actmet.dirty_flag,
            met.metric_calculation_type,actmet.metric_uom_code
      FROM   ams_act_metrics_all actmet, ams_metrics_all_b met
      WHERE  actmet.metric_id = met.metric_id
      AND    actmet.arc_act_metric_used_by = l_arc_act_metric_used_by
      AND    actmet.act_metric_used_by_id = l_act_metric_used_by_id
      AND    actmet.summarize_to_metric IS NULL;
      --AND   (dirty_flag = 'Y' OR metric_calculation_type = 'FUNCTION');

      -- select only the dirty records or FUNCTION type records,
      -- added SVEERAVE - 10/13/00,12/14/00
   l_all_metrics_rec       c_all_metrics%ROWTYPE;
   l_is_locked VARCHAR2(1);
BEGIN
   --
   -- Initialize savepoint.
   --
   SAVEPOINT Refresh_Metric_SavePoint2;
   --
   -- Output debug message.
   --
   IF AMS_DEBUG_HIGH_ON THEN
   Ams_Utility_Pvt.debug_message(l_full_name||': START');
   END IF;
   --
   -- Initialize message list if p_init_msg_list is set to TRUE.
   --
   IF Fnd_Api.To_Boolean (p_init_msg_list) THEN
      Fnd_Msg_Pub.Initialize;
   END IF;
   --
   -- Standard check for API version compatibility.
   --
   IF NOT Fnd_Api.Compatible_API_Call (L_API_VERSION,
                                       p_api_version,
                                       L_API_NAME,
                                       G_PKG_NAME)
   THEN
      RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
   END IF;
   --
   -- Initialize API return status to success.
   --
   x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
   --
   -- Begin API Body.

   l_is_locked := ams_actmetric_pvt.lock_object(
      p_api_version            => l_api_version ,
      p_init_msg_list          => Fnd_Api.G_FALSE,
      p_arc_act_metric_used_by => p_arc_act_metric_used_by,
      p_act_metric_used_by_id  => p_act_metric_used_by_id,
      x_return_status         => x_return_status,
      x_msg_count             => x_msg_count,
      x_msg_data              => x_msg_data);

   IF x_return_status = Fnd_Api.G_RET_STS_ERROR THEN
      RAISE Fnd_Api.G_EXC_ERROR;
   ELSIF x_return_status = Fnd_Api.G_RET_STS_UNEXP_ERROR THEN
      RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
   elsif l_is_locked = FND_API.G_FALSE THEN
      -- the object needs to be lock by this process.
      RAISE ams_utility_pvt.resource_locked;
   END IF;

   --
   -- Replace the body: 11/19/2002
   ams_actmetrics_engine_PVT.Refresh_Act_Metrics_Engine
          (p_api_version => p_api_version,
           p_init_msg_list => p_init_msg_list,
           p_arc_act_metric_used_by => p_arc_act_metric_used_by,
           p_act_metric_used_by_id => p_act_metric_used_by_id,
           x_return_status          => x_return_status,
           x_msg_count              => x_msg_count,
           x_msg_data               => x_msg_data,
           p_commit        => FND_API.G_FALSE,
           p_run_functions => FND_API.G_TRUE--,
           --p_update_history => fnd_api.g_false
   );
/****** OBSOLETE 11/19/2002: Using engine.
   Run_Object_Procedures (
      p_arc_act_metric_used_by => p_arc_act_metric_used_by,
      p_act_metric_used_by_id  => p_act_metric_used_by_id);

   -- All the Activity Metrics attached to the current usage has to be refreshed
   OPEN c_all_metrics(p_arc_act_metric_used_by,
                      p_act_metric_used_by_id);
   LOOP
      FETCH c_all_metrics INTO l_all_metrics_rec;
      EXIT WHEN c_all_metrics%NOTFOUND;
--          Ams_Utility_Pvt.debug_message('Now Calling Calc Met FOR: '||
--              p_arc_act_metric_used_by||'-'||
--              p_act_metric_used_by_id);
      Calculate_Metric (
        p_api_version            => l_api_version ,
        p_init_msg_list          => p_init_msg_list,
        p_commit                 => Fnd_Api.G_FALSE,
        x_return_status          => x_return_status,
        x_msg_count              => x_msg_count,
        x_msg_data               => x_msg_data,
        p_activity_metric_id     => l_all_metrics_rec.activity_metric_id,
--      p_act_metric_used_by_id  => l_act_metric_rec.act_metric_used_by_id,
--      p_arc_act_metric_used_by => l_act_metric_rec.arc_act_metric_used_by,
--      p_act_metric_uom_code    => l_act_metric_rec.metric_uom_code,
        x_actual_value           => l_actual_value,
        x_forecasted_value       => l_forecasted_value,
        p_refresh_function       => p_refresh_function,
        p_func_currency_code     => Ams_Actmetric_Pvt.DEFAULT_FUNC_CURRENCY);

      -- If any errors happen abort API.
      IF x_return_status = Fnd_Api.G_RET_STS_ERROR THEN
         CLOSE c_all_metrics;
         RAISE Fnd_Api.G_EXC_ERROR;
      ELSIF x_return_status = Fnd_Api.G_RET_STS_UNEXP_ERROR THEN
         CLOSE c_all_metrics;
         RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
      END IF;
   END LOOP;
   CLOSE c_all_metrics;

   -- DMVINCEN 03/28/2002: Iterate through all components for the dialog.
   -- BUG2845365: Removed dialogue support.
   IF p_arc_act_metric_used_by = 'DILG' THEN
      Refresh_Components(
         p_api_version                 => p_api_version,
         p_init_msg_list               => Fnd_Api.G_FALSE,
         p_commit                      => p_commit,
         x_return_status               => x_return_status,
         x_msg_count                   => x_msg_count,
         x_msg_data                    => x_msg_data,
         p_arc_act_metric_used_by      => p_arc_act_metric_used_by,
         p_act_metric_used_by_id       => p_act_metric_used_by_id,
         p_refresh_function            => p_refresh_function
      );
   END IF;
***** OBSOLETE 11/19/2002: Using engine. */
   --
   -- End API Body.
   --
   --
   -- Standard check for commit request.
   --
   IF Fnd_Api.To_Boolean (p_commit) THEN
      COMMIT WORK;
   END IF;
   --
   -- Standard API to get message count, and if 1,
   -- set the message data OUT variable.
   --
   Fnd_Msg_Pub.Count_And_Get (
      p_count           =>    x_msg_count,
      p_data            =>    x_msg_data,
      p_encoded         =>    Fnd_Api.G_FALSE
   );
   --
   -- Add success message to message list.
   --
   IF AMS_DEBUG_HIGH_ON THEN
   Ams_Utility_Pvt.debug_message(l_full_name ||': END');
   END IF;
   EXCEPTION
   when ams_utility_pvt.resource_locked then
      ROLLBACK TO Refresh_Metric_SavePoint2;
      Fnd_Message.set_name('AMS', 'AMS_API_RESOURCE_LOCKED');
      Fnd_Msg_Pub.ADD;
      x_return_status := Fnd_Api.G_RET_STS_ERROR;
      Fnd_Msg_Pub.Count_And_Get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data,
         p_encoded       =>     FND_API.G_FALSE
      );
/*
EXCEPTION
   WHEN Fnd_Api.G_EXC_ERROR THEN
      --ROLLBACK TO Refresh_Metric_SavePoint;
      x_return_status := Fnd_Api.G_RET_STS_ERROR;
      Fnd_Msg_Pub.Count_And_Get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data,
         p_encoded       =>     FND_API.G_FALSE
      );
   WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
      --ROLLBACK TO Refresh_Metric_SavePoint;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      Fnd_Msg_Pub.Count_And_Get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data,
         p_encoded       =>     FND_API.G_FALSE
      );
   WHEN OTHERS THEN
      --ROLLBACK TO Refresh_Metric_SavePoint;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      IF Fnd_Msg_Pub.Check_Msg_Level (Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR) THEN
         Fnd_Msg_Pub.Add_Exc_Msg (G_PKG_NAME, L_API_NAME);
      END IF;
      Fnd_Msg_Pub.Count_And_Get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data,
         p_encoded       =>     FND_API.G_FALSE
      );
*/
END Refresh_Metric;

--
-- NAME
--    Exec_Procedure
--
-- PURPOSE
--    Executes the given function stored procedure using object type and object
--    id as parameters.
--
-- NOTES
--    Use Native Dynamic SQL (8i feature) for executing the function.
--
-- HISTORY
-- 08/29/2001     huili             Created.
--
PROCEDURE Exec_Procedure (
   p_arc_act_metric_used_by   IN VARCHAR2,
   p_act_metric_used_by_id    IN NUMBER,
   p_function_name            IN VARCHAR2)
IS
BEGIN
   IF p_arc_act_metric_used_by IS NOT NULL
      AND p_arc_act_metric_used_by IN
        ('CAMP', 'CSCH', 'DELV', 'EVEO', 'EVEH', 'RCAM', 'EONE')
        -- BUG2845365: Remove dialogue components.
        --'DILG')
          --, 'AMS_COMP_START', 'AMS_COMP_SHOW_WEB_PAGE', 'AMS_COMP_END')
      AND p_act_metric_used_by_id IS NOT NULL
      AND p_function_name IS NOT NULL THEN
      EXECUTE IMMEDIATE 'BEGIN ' || p_function_name ||
             '( :p_arc_act_metric_used_by, :p_act_metric_used_by_id ); END;'
      USING IN p_arc_act_metric_used_by, p_act_metric_used_by_id;
   END IF;
EXCEPTION
  WHEN OTHERS THEN
     RETURN;
END Exec_Procedure;

--
-- NAME
--    Run_Object_Procedures
--
-- PURPOSE
--    Executes all stored procedures accociated with a business object.
--
-- NOTES
--    Use Native Dynamic SQL (8i feature) for executing the function.
--
-- HISTORY
-- 08/29/2001     huili             Created.
--
PROCEDURE Run_Object_Procedures (
   p_arc_act_metric_used_by   IN VARCHAR2,
   p_act_metric_used_by_id    IN NUMBER)
IS
   TYPE t_procedures IS TABLE OF ams.ams_metrics_all_b.function_name%TYPE;

   l_function_list t_procedures;
   l_function_name ams.ams_metrics_all_b.function_name%TYPE;

   CURSOR c_all_procedures (p_arc_act_metric_used_by VARCHAR2,
                            p_act_metric_used_by_id  NUMBER)
   IS
     SELECT DISTINCT function_name
     FROM ams_metrics_all_b
     WHERE metric_id IN (SELECT metric_id
                         FROM ams_act_metrics_all
                         WHERE arc_act_metric_used_by = p_arc_act_metric_used_by
                         AND act_metric_used_by_id = p_act_metric_used_by_id)
     AND function_type = 'N';
BEGIN

   OPEN c_all_procedures (p_arc_act_metric_used_by, p_act_metric_used_by_id);
   FETCH c_all_procedures BULK COLLECT INTO l_function_list;
   CLOSE c_all_procedures;

   IF l_function_list.COUNT > 0 THEN
      FOR l_index IN l_function_list.FIRST..l_function_list.LAST
      LOOP
         l_function_name := l_function_list(l_index);

         Exec_Procedure (
            p_arc_act_metric_used_by => p_arc_act_metric_used_by,
            p_act_metric_used_by_id  => p_act_metric_used_by_id,
            p_function_name => l_function_name);
      END LOOP;
   END IF;

EXCEPTION
  WHEN OTHERS THEN
     RETURN;
END Run_Object_Procedures;


/** Commenting Out the package since Dialog Objects are obsolete.
    Bug#5029304
 **/
/**
-- Start of comments
-- NAME
--    Refresh_Metric
--
-- PURPOSE
--   Re-calculate metrics for the components with in a dialog.
--
-- NOTES
--
-- HISTORY
-- 03/28/2002  dmvincen  Created
--
PROCEDURE Refresh_Components(
   p_api_version                 IN     NUMBER,
   p_init_msg_list               IN     VARCHAR2 := Fnd_Api.G_TRUE,
   p_commit                      IN     VARCHAR2 := Fnd_Api.G_FALSE,
   x_return_status               OUT    NOCOPY VARCHAR2,
   x_msg_count                   OUT    NOCOPY NUMBER,
   x_msg_data                    OUT    NOCOPY VARCHAR2,
   p_arc_act_metric_used_by      IN     VARCHAR2,
   p_act_metric_used_by_id       IN     NUMBER,
   p_refresh_function            IN     VARCHAR2 := Fnd_Api.G_TRUE
)
IS
   L_API_VERSION      CONSTANT NUMBER := 1.0;
   L_API_NAME         VARCHAR2(30) := 'Refresh_Component';
   L_FULL_NAME        CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

   CURSOR c_get_components(p_dialog_id NUMBER) IS
      SELECT flow_component_id obj_id,component_type_code obj_type
      FROM ams_dlg_flow_comps_b
      WHERE dialog_id= p_dialog_id;

   l_object_id NUMBER;
   l_object_type VARCHAR2(30);
BEGIN

   --
   -- Output debug message.
   --
   IF AMS_DEBUG_HIGH_ON THEN
   Ams_Utility_Pvt.debug_message(l_full_name||': START');
   END IF;
   --
   -- Initialize message list if p_init_msg_list is set to TRUE.
   --
   IF Fnd_Api.To_Boolean (p_init_msg_list) THEN
      Fnd_Msg_Pub.Initialize;
   END IF;
   --
   -- Standard check for API version compatibility.
   --
--    IF NOT Fnd_Api.Compatible_API_Call (L_API_VERSION,
--                                        p_api_version,
--                                        L_API_NAME,
--                                        G_PKG_NAME)
--    THEN
--       RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
--    END IF;
   --
   -- Initialize API return status to success.
   --
   x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
   OPEN c_get_components(p_act_metric_used_by_id);
   LOOP
      FETCH c_get_components INTO l_object_id, l_object_type;
      EXIT WHEN c_get_components%NOTFOUND;
   IF AMS_DEBUG_MEDIUM_ON THEN
      Ams_Utility_Pvt.debug_message(l_full_name||': refresh component:'||
          l_object_type||'/'||l_object_id);
          END IF;
      Refresh_Metric(
            p_api_version    => p_api_version,
            p_init_msg_list  => Fnd_Api.G_FALSE,
            p_commit         => Fnd_Api.G_FALSE,
            x_return_status  => x_return_status,
            x_msg_count      => x_msg_count,
            x_msg_data       => x_msg_data,
            p_arc_act_metric_used_by => l_object_type,
            p_act_metric_used_by_id  => l_object_id,
            p_refresh_function       => Fnd_Api.G_FALSE);
      IF x_return_status = Fnd_Api.G_RET_STS_ERROR THEN
         CLOSE c_get_components;
         RAISE Fnd_Api.G_EXC_ERROR;
      ELSIF x_return_status = Fnd_Api.G_RET_STS_UNEXP_ERROR THEN
         CLOSE c_get_components;
         RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
      END IF;
   END LOOP;
   CLOSE c_get_components;

   --
   -- Standard check for commit request.
   --
   IF Fnd_Api.To_Boolean (p_commit) THEN
      COMMIT WORK;
   END IF;
   --
   -- Standard API to get message count, and if 1,
   -- set the message data OUT variable.
   --
   Fnd_Msg_Pub.Count_And_Get (
      p_count           =>    x_msg_count,
      p_data            =>    x_msg_data,
      p_encoded         =>    Fnd_Api.G_FALSE
   );
   --
   -- Add success message to message list.
   --
   IF AMS_DEBUG_HIGH_ON THEN
   Ams_Utility_Pvt.debug_message(l_full_name ||': END');
   END IF;
EXCEPTION
   WHEN Fnd_Api.G_EXC_ERROR THEN
      ROLLBACK TO Refresh_Metric_SavePoint;
      x_return_status := Fnd_Api.G_RET_STS_ERROR;
      Fnd_Msg_Pub.Count_And_Get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data,
         p_encoded       =>     FND_API.G_FALSE
      );
   WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Refresh_Metric_SavePoint;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      Fnd_Msg_Pub.Count_And_Get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data,
         p_encoded       =>     FND_API.G_FALSE
      );
   WHEN OTHERS THEN
      ROLLBACK TO Refresh_Metric_SavePoint;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      IF Fnd_Msg_Pub.Check_Msg_Level (Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR) THEN
         Fnd_Msg_Pub.Add_Exc_Msg (G_PKG_NAME, L_API_NAME);
      END IF;
      Fnd_Msg_Pub.Count_And_Get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data,
         p_encoded       =>     FND_API.G_FALSE
      );
END Refresh_Components;

**/


END Ams_Refreshmetric_Pvt ;

/
