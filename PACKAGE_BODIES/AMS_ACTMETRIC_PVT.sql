--------------------------------------------------------
--  DDL for Package Body AMS_ACTMETRIC_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_ACTMETRIC_PVT" AS
/* $Header: amsvamtb.pls 120.14.12010000.2 2010/05/10 08:56:39 amlal ship $ */

------------------------------------------------------------------------------
--
-- NAME
--    AMS_ActMetric_PVT  12.0
--
-- HISTORY
-- 20-Jun-1999 choang@us    Created package.
-- 11-Oct-1999 ptendulk@us  Made changes according to new standards.
--                          Added some Validations, Seperated from Common
--                          Objects
-- 01/18/2000  bgeorge      reviewed code, added isseeded function to the body
-- 03/10/2000  bgeorge      added code for updating functional actual value
--                          for MANUAL metrics
-- 04/17/2000  tdonohoe@us  modified all procedures to include columns added
--                          for 11.5.2 release to support Heirarchy traversal.
-- 05/08/2000  tdonohoe@us  modified API to allow a metric to be associated
--                          with a Forecast (FCST).
-- 06/28/2000  rchahal@us   modified API to allow a metric to be associated
--                          with a Fund (FUND).
-- 07/05/2000  khung@us     change metric_category from 701 to 901 (#1331391)
-- 07/11/2000  svatsa@us    Created a forward declaration for the API
--                          Create_ActMetric so that it can be called
--                          recursively from the api Create_ParentActMetric.
-- 08/17/2000  sveerave@us  modified Default_func_currency function to return
--                          default currency from profile 'AMS_DEFAULT_CURR_CODE'
-- 08/24/2000  sveerave@us  modified to include call-out for
--                          check_freeze_status in create, update and delete
-- 08/28/2000  sveerave@us  Modified to convert/default metric values with
--                          currencies and with out currencies in case of
--                          manual or non-manual type metrics. in
--                          Default_ActMetric procedure
-- 10/11/2000  SVEERAVE@US  Modified to include the procedure for flipping
--                          the ROLLUP metrics currency to main object's
--                          currency.  Included procedure Init_ActMetric_Rec
-- 11/07/2000  SVEERAVE@US  Modified to include the call to
--                          modify_object_attribute to uncheck when metrics
--                          are deleted in delete_metrics api
-- 11/15/2000  SVEERAVE@US  Modifed delete api to check for existence of
--                          child before deleting the metric.
-- 04/03/2001  DMVINCEN@US  Added validation to prevent delete of parent
--                          rollup activity metrics.
-- 04/17/2001  DMVINCEN@US  Removed modify_object_attribute because it is
--                          obsolete.
-- 04/17/2001  HUILI@US     Added act_metric_date and description.
-- 04/27/2001  DMVINCEN@US  Changed ams_p_actmetrics_v to join of tables.
-- 04/27/2001  DMVINCEN@US  Added SUMMARY calculation type #1753241
-- 04/30/2001  DMVINCEN@US  Delete metrics need to refresh parents.
-- 05/07/2001  huili        Added "depend_act_metric" field
-- 05/17/2001  DMVINCEN     Removed depend,trans date,desc for 11.5.4.11
-- 06/07/2001  DMVINCEN     Allow ROLLUP and SUMMARY to assign to any object.
-- 06/21/2001  DMVINCEN     Change hierarchy for 11.5.6 with Programs.
-- 06/21/2001  DMVINCEN     Added depend,trans date,desc for 11.5.6.
-- 06/21/2001  DMVINCEN     Removed modify_object_attribute for 11.5.6.
-- 08/21/2001  DMVINCEN     Set the transaction currency code on each update.
-- 09/10/2001  HUILI        Added the "Have_Published" module.
-- 09/21/2001  HUILI        Added the "Get_Object_Info" module.
-- 10/15/2001  DMVINCEN     Add function metrics only once.
-- 10/16/2001  HUILI        Set the "trans_actual_value" and "func_actual_value"
--                          to "NULL" while attaching a function metric to a
--                          business object.
-- 11/27/2001  DMVINCEN     Added History recording.  Not utilized yet.
-- 11/27/2001  DMVINCEN     Added Results cue card support.  Get_Results.
-- 11/27/2001  HUILI        Added Get_Date_Buckets for results support.
-- 12/05/2001  DMVINCEN     Added Convert_Currency_Vector and
--                          Convert_Currency_Object for chart support.
-- 12/18/2001  DMVINCEN     Convert_Currency: no round if p_round is false.
--                          Bug 1630029.
-- 12/18/2001  DMVINCEN     Allow seeded metrics to be removed from objects.
-- 12/20/2001  DMVINCEN     Unit testing corrections to GET_RESULTS.
-- 12/20/2001  DMVINCEN     Turned on history recording.
-- 01/14/2002  HUILI        Bug fix #2159316.
-- 02/06/2002  DMVINCEN     BUG2214496: Corrected history delta calculation.
-- 03/08/2002  DMVINCEN     Added function_used_by_id, arc_function_used_by.
-- 03/11/2002  DMVINCEN     Added dialog components as valid objects.
-- 03/18/2002  DMVINCEN     BUG2214486: View history date slice validations.
-- 04/04/2002  DMVINCEN     Added recursive delete.
-- 04/04/2002  DMVINCEN     Removing rollups removes reference from child.
-- 04/04/2002  DMVINCEN     Changed posting costs to transaction currency.
-- 07/16/2002  DMVINCEN     BUG2462396: Post costs for events prior to start.
-- 07/24/2002  DMVINCEN     BUG2462396: Use specific statuses for post cost.
-- 10/10/2002  HUILI        BUG #2610168
-- 10/21/2002  YZHAO        11.5.9 Add new fields for budget allocation
-- 11/18/2002  DMVINCEN     Fixed problems introduced by adding NOCOPY.
-- 01/17/2003  DMVINCEN     NOCOPY problems reoccured in default_actmetric.
-- 12/27/2002  DMVINCEN     BUG #2729040: Fixed rollback issues.
-- 02/20/2003  DMVINCEN     BUG2813600: Delete history calculated wrong.
-- 02/20/2003  DMVINCEN     When Delete history shows zeros.
-- 03/05/2003  DMVINCEN     BUG2486379: Show post costs error from budgets.
-- 03/11/2003  DMVINCEN     BUG2845365: Removed dialogue support.
-- 05/07/2003  sunkumar     overloaded validate_actmetric_record to incorporate
--                          p_operation_mode ('CREATE', 'UPDATE', or 'DELETE'
-- 17-Sep-2003 sunkumar     Object level locking introduced
-- 10/02/2003  dmvincen     Added forecasted_variable_value.
-- 10/08/2003  dmvincen     Exclude formulas from posting.
-- 11/14/2003  dmvincen     Set formula's dirty flag.
-- 12/16/2003  dmvincen     Added ALIST to lock_object.
-- 02/09/2004  dmvincen     BUG3430397: Post budget to OZF.
-- 02/10/2004  dmvincen     Variable metrics reuse the same multiplier.
-- 02/10/2004  dmvincen     Set dirty flags for variable metrics.
-- 03/08/2004  dmvincen     BUG3463791: Removed redundant frozen message.
-- 04/21/2004  sunkumar     sqlbind fixes
-- 04/21/2004  dmvincen     Added Convert_to_trans_value for graph support.
-- 11/10/2004  dmvincen     BUG3815334: Limit history results to default rows.
-- 11/22/2004  dmvincen     BUG4028377: Prevent duplicate assignment of funcs.
-- 04-Jan-2005 choang       bug 4102008: event status was not vaildated in
--                          check_freeze_status.
-- 19-May-2005 choang       Added call to ams_access_pvt.check_update_access
--                          in validate act metric.
-- 06/07/2005  dmvincen     BUG4391308: Added locking on update.
-- 10/12/2005  dmvincen     BUG4661335: Actual value check for creation.
-- 12/06/2005  dmvincen     BUG4747088: Check fore var val on update active.
-- 12/16/2005  dmvincen     BUG4868582: Expose Freeze status for UI.
-- 01/25/2006  dmvincen     BUG4669529: Show first incremental value.
-----------------------------------------------------------------------------

--
-- Global variables and constants.

G_PKG_NAME CONSTANT VARCHAR2(30) := 'AMS_ACTMETRIC_PVT'; -- Name of the current package.
G_DEBUG_FLAG                  VARCHAR2(1)  := 'N';
G_CREATE CONSTANT VARCHAR2(30) := 'CREATE';
G_UPDATE CONSTANT VARCHAR2(30) := 'UPDATE';
G_DELETE CONSTANT VARCHAR2(30) := 'DELETE';
G_IS_DIRTY CONSTANT VARCHAR2(30) := 'Y';
G_METRIC CONSTANT VARCHAR2(30) := 'METRIC';
G_CATEGORY CONSTANT VARCHAR2(30) := 'CATEGORY';
G_FORMULA CONSTANT VARCHAR2(30) := 'FORMULA';
G_CATEGORY_COSTS        CONSTANT NUMBER := 901;
G_CATEGORY_REVENUES     CONSTANT NUMBER := 902;
G_VARIABLE CONSTANT VARCHAR2(30) := 'VARIABLE';
TYPE date_bucket_type IS TABLE OF DATE;
TYPE number_table IS TABLE OF NUMBER;

-- Forward Declarations Begin
AMS_DEBUG_HIGH_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

PROCEDURE Record_History(
   p_actmet_id                  IN NUMBER,
   p_action                     IN VARCHAR2,
   x_return_status              OUT NOCOPY VARCHAR2,
   x_msg_count                  OUT NOCOPY NUMBER,
   x_msg_data                   OUT NOCOPY VARCHAR2
);

PROCEDURE Create_ActMetric2 (
   p_api_version                IN  NUMBER,
   p_init_msg_list              IN  VARCHAR2 := Fnd_Api.G_FALSE,
   p_commit                     IN  VARCHAR2 := Fnd_Api.G_FALSE,
   p_validation_level           IN  NUMBER   := Fnd_Api.G_Valid_Level_Full,

   x_return_status              OUT NOCOPY VARCHAR2,
   x_msg_count                  OUT NOCOPY NUMBER,
   x_msg_data                   OUT NOCOPY VARCHAR2,

   p_act_metric_rec             IN  act_metric_rec_type,
   x_activity_metric_id         OUT NOCOPY NUMBER
);


PROCEDURE Validate_ActMetric_Record (
   p_act_metric_rec  IN  act_metric_rec_type,
   p_complete_rec    IN  act_metric_rec_type,
   p_operation_mode  IN VARCHAR2,
   x_return_status   OUT NOCOPY VARCHAR2
);


/*sunkumar 21-apr-2004 added*/
FUNCTION Validate_Object_Exists (
   p_object_type  IN  varchar2,
   p_object_id   IN  number
)
RETURN VARCHAR2;


-- Forward Declarations End


PROCEDURE Create_ActMetric (
   p_api_version                IN  NUMBER,
   p_init_msg_list              IN  VARCHAR2 := Fnd_Api.G_FALSE,
   p_commit                     IN  VARCHAR2 := Fnd_Api.G_FALSE,
   --p_commit                     IN  VARCHAR2 := Fnd_Api.G_TRUE,
   p_validation_level           IN  NUMBER   := Fnd_Api.G_Valid_Level_Full,

   x_return_status              OUT NOCOPY VARCHAR2,
   x_msg_count                  OUT NOCOPY NUMBER,
   x_msg_data                   OUT NOCOPY VARCHAR2,

   p_act_metric_rec             IN  act_metric_rec_type,
   x_activity_metric_id         OUT NOCOPY NUMBER
) IS

   L_API_NAME        CONSTANT VARCHAR2(30) := 'Create_ActMetric';
   l_is_locked       varchar2(1);
BEGIN

   SAVEPOINT sp_create_actmetric;

   x_return_status      := Fnd_Api.G_RET_STS_SUCCESS;
   x_activity_metric_id := NULL;

   --LOCK TABLE AMS_ACT_METRICS_ALL IN EXCLUSIVE MODE;

   l_is_locked := Lock_Object(
         p_api_version           => p_api_version,
         p_init_msg_list         => p_init_msg_list,
         p_arc_act_metric_used_by => p_act_metric_rec.arc_act_metric_used_by,
         p_act_metric_used_by_id => p_act_metric_rec.act_metric_used_by_id,
         x_return_status         => x_return_status,
         x_msg_count             => x_msg_count,
         x_msg_data              => x_msg_data);

   IF x_return_status <> Fnd_Api.G_RET_STS_SUCCESS or
      l_is_locked = FND_API.G_FALSE THEN
      RAISE Fnd_Api.G_EXC_ERROR;
   END IF;

   Create_ActMetric2 (
         p_api_version           => p_api_version,
         p_init_msg_list         => p_init_msg_list,
         p_commit                => p_commit,
         p_validation_level      => p_validation_level,
         x_return_status         => x_return_status,
         x_msg_count             => x_msg_count,
         x_msg_data              => x_msg_data,
         p_act_metric_rec        => p_act_metric_rec,
         x_activity_metric_id    => x_activity_metric_id);

   -- If any errors happen abort API.
   IF x_return_status <> Fnd_Api.G_RET_STS_SUCCESS THEN
      RAISE Fnd_Api.G_EXC_ERROR;
   END IF;

   --COMMIT WORK;

   IF Fnd_Api.to_boolean(p_commit) THEN
      COMMIT;
   END IF;

   --
   -- Standard API to get message count, and if 1,
   -- set the message data OUT NOCOPY variable.
   --
   Fnd_Msg_Pub.Count_And_Get (
      p_count           =>    x_msg_count,
      p_data            =>    x_msg_data,
      p_encoded         =>    Fnd_Api.G_FALSE
   );

EXCEPTION
   WHEN Fnd_Api.G_EXC_ERROR THEN
      ROLLBACK TO sp_create_actmetric;
      x_return_status := Fnd_Api.G_RET_STS_ERROR;
      Fnd_Msg_Pub.Count_And_Get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data,
         p_encoded         =>   FND_API.G_FALSE
      );
   WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO sp_create_actmetric;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      Fnd_Msg_Pub.Count_And_Get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data,
         p_encoded         =>   FND_API.G_FALSE
      );
   WHEN OTHERS THEN
      ROLLBACK TO sp_create_actmetric;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      IF Fnd_Msg_Pub.Check_Msg_Level (Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR) THEN
         Fnd_Msg_Pub.Add_Exc_Msg (G_PKG_NAME, L_API_NAME);
      END IF;
      Fnd_Msg_Pub.Count_And_Get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data,
         p_encoded       =>   FND_API.G_FALSE
      );
END Create_ActMetric;

-- Start of comments
-- NAME
--    Get_Object_Info
--
-- PURPOSE
--    To get information for a specific business object.
--
-- NOTES
--
-- HISTORY
-- 09/21/2001   HuiLi         Created.
--
-- End of comments
PROCEDURE Get_Object_Info (
   p_obj_type     IN  VARCHAR2,
   p_obj_id       IN NUMBER,
   x_flag         OUT NOCOPY VARCHAR2,
   x_currency     OUT NOCOPY VARCHAR2
) IS

   --campaign and program
   CURSOR c_check_camp_prog_status (p_camp_id IN NUMBER)
   IS
      SELECT NVL (transaction_currency_code, functional_currency_code) AS currency_code, status_code
      FROM ams_campaigns_all_b
      WHERE campaign_id = p_camp_id;
      --AND UPPER(status_code) IN  ('COMPLETED', 'ACTIVE', 'CANCELLED', 'SUBMITTED_BA');

   --campaign schedule
   CURSOR c_check_campsch_status (p_schedule_id IN NUMBER)
   IS
      SELECT NVL (transaction_currency_code, functional_currency_code) AS currency_code, status_code
      FROM ams_campaign_schedules_b
      WHERE schedule_id = p_schedule_id;
      --AND UPPER(status_code) IN ('ACTIVE', 'CANCELLED', 'COMPLETED');

   --deliverable
   CURSOR c_check_deliv_status (p_deliv_id IN NUMBER)
   IS
      SELECT NVL (transaction_currency_code, currency_code) AS currency_code, status_code
      FROM ams_deliverables_all_b
      WHERE deliverable_id = p_deliv_id;
      --AND UPPER(status_code) IN ('SUBMITTED_BA', 'CANCELLED', 'AVAILABLE');

   --event
   CURSOR c_check_event_status (p_event_id IN NUMBER)
   IS
      SELECT currency_code_tc AS currency_code, system_status_code
          -- active_flag, active_from_date
      FROM ams_event_headers_all_b
      WHERE event_header_id = p_event_id;
      --AND active_flag = 'Y'
      --AND active_from_date < SYSDATE;

   --event schedule and one-off event
   CURSOR c_check_eventsch_status (p_ev_id IN NUMBER)
   IS
      SELECT currency_code_tc AS currency_code, system_status_code
      FROM ams_event_offers_all_b
      WHERE event_offer_id = p_ev_id;
      --AND UPPER(system_status_code) IN ('ACTIVE', 'SUBMITTED_BA', 'CLOSED', 'CANCELLED');

   l_status_code VARCHAR2(2000);
   -- l_active_flag VARCHAR2(1);
   -- l_active_date DATE;
   l_currency_code VARCHAR2(15);

BEGIN

   x_flag := 'N';
   IF UPPER(p_obj_type) IN ('CAMP', 'RCAM') THEN
      OPEN c_check_camp_prog_status (p_obj_id);
      FETCH c_check_camp_prog_status INTO l_currency_code, l_status_code;
      IF c_check_camp_prog_status%FOUND AND
         UPPER(l_status_code) IN
            ('ACTIVE', 'CANCELLED', 'COMPLETED', 'SUBMITTED_BA') THEN
         x_flag := 'Y';
      END IF;
      CLOSE c_check_camp_prog_status;
   ELSIF UPPER(p_obj_type) = 'CSCH' THEN
      OPEN c_check_campsch_status(p_obj_id);
      FETCH c_check_campsch_status INTO l_currency_code, l_status_code;
      IF c_check_campsch_status%FOUND
         AND UPPER(l_status_code) IN
            ('ACTIVE', 'CANCELLED', 'COMPLETED', 'SUBMITTED_BA') THEN
         x_flag := 'Y';
      END IF;
      CLOSE c_check_campsch_status;
   ELSIF UPPER(p_obj_type) = 'DELV' THEN
      OPEN c_check_deliv_status(p_obj_id);
      FETCH c_check_deliv_status INTO l_currency_code, l_status_code;
      IF c_check_deliv_status%FOUND
         AND UPPER(l_status_code) IN ('SUBMITTED_BA', 'CANCELLED', 'AVAILABLE')
      THEN
         x_flag := 'Y';
      END IF;
      CLOSE c_check_deliv_status;
   ELSIF UPPER(p_obj_type) = 'EVEH' THEN
      OPEN c_check_event_status(p_obj_id);
      FETCH c_check_event_status INTO l_currency_code, l_status_code;
          -- l_active_flag, l_active_date;
      IF c_check_event_status%FOUND
         AND UPPER(l_status_code) IN
            ('ACTIVE', 'CANCELLED', 'COMPLETED', 'SUMBITTED_BA')
         -- AND UPPER(l_active_flag) = 'Y'
         -- AND l_active_date < SYSDATE
      THEN
         x_flag := 'Y';
      END IF;
      CLOSE c_check_event_status;
   ELSIF UPPER(p_obj_type) IN ('EONE', 'EVEO') THEN
      OPEN c_check_eventsch_status(p_obj_id);
      FETCH c_check_eventsch_status INTO l_currency_code, l_status_code;
      IF c_check_eventsch_status%FOUND
         AND UPPER(l_status_code) IN
             ('ACTIVE', 'CANCELLED', 'COMPLETED', 'SUBMITTED_BA') THEN
         x_flag := 'Y';
      END IF;
      CLOSE c_check_eventsch_status;
   END IF;
   x_currency := l_currency_code;

END Get_Object_Info;


-- Start of comments
-- NAME
--    Have_Published
--
-- PURPOSE
--    To publish the object must be active, canceled or completed.
--
-- NOTES
--
-- HISTORY
-- 09/11/2001   HuiLi         Created.
--
-- End of comments
PROCEDURE Have_Published (
   p_obj_type     IN  VARCHAR2,
   p_obj_id       IN NUMBER,
   x_flag         OUT NOCOPY VARCHAR2
) IS

   --campaign and program
   CURSOR c_check_camp_prog_status (p_camp_id IN NUMBER)
   IS
     SELECT 1
     FROM ams_campaigns_all_b
     WHERE campaign_id = p_camp_id
     AND UPPER(status_code) IN ('ACTIVE', 'AVAILABLE', 'CANCELLED', 'PLANNING');

   --campaign schedule
   CURSOR c_check_campsch_status (p_schedule_id IN NUMBER)
   IS
     SELECT 1
     FROM ams_campaign_schedules_b
     WHERE schedule_id = p_schedule_id
     AND UPPER(status_code) IN ('ACTIVE', 'AVAILABLE', 'CANCELLED', 'PLANNING');

   --deliverable
   CURSOR c_check_deliv_status (p_deliv_id IN NUMBER)
   IS
      SELECT 1
      FROM ams_deliverables_all_b
      WHERE deliverable_id = p_deliv_id
      AND UPPER(status_code) IN ('CANCELLED', 'AVAILABLE');

   --event
   CURSOR c_check_event_status (p_event_id IN NUMBER)
   IS
      SELECT 1
      FROM ams_event_headers_all_b
      WHERE event_header_id = p_event_id
      AND UPPER(system_status_code) IN
         ('ACTIVE', 'AVAILABLE', 'CANCELLED', 'PLANNING')
      --AND active_flag = 'Y'
      --AND active_from_date < SYSDATE
      ;

   --event schedule and one-off event
   CURSOR c_check_eventsch_status (p_ev_id IN NUMBER)
   IS
      SELECT 1
      FROM ams_event_offers_all_b
      WHERE event_offer_id = p_ev_id
      AND UPPER(system_status_code) IN
          ('ACTIVE', 'AVAILABLE', 'CANCELLED', 'PLANNING');

   l_status_code NUMBER := NULL;

BEGIN

   x_flag := 'N';
   IF UPPER(p_obj_type) IN ('CAMP', 'RCAM') THEN
      OPEN c_check_camp_prog_status (p_obj_id);
      FETCH c_check_camp_prog_status INTO l_status_code;
      IF c_check_camp_prog_status%FOUND THEN
         x_flag := 'Y';
      END IF;
      CLOSE c_check_camp_prog_status;
   ELSIF UPPER(p_obj_type) = 'CSCH' THEN
      OPEN c_check_campsch_status(p_obj_id);
      FETCH c_check_campsch_status INTO l_status_code;
      IF c_check_campsch_status%FOUND THEN
         x_flag := 'Y';
      END IF;
      CLOSE c_check_campsch_status;
   ELSIF UPPER(p_obj_type) = 'DELV' THEN
      OPEN c_check_deliv_status(p_obj_id);
      FETCH c_check_deliv_status INTO l_status_code;
      IF c_check_deliv_status%FOUND THEN
         x_flag := 'Y';
      END IF;
      CLOSE c_check_deliv_status;
   ELSIF UPPER(p_obj_type) = 'EVEH' THEN
      OPEN c_check_event_status(p_obj_id);
      FETCH c_check_event_status INTO l_status_code;
      IF c_check_event_status%FOUND THEN
         x_flag := 'Y';
      END IF;
      CLOSE c_check_event_status;
   ELSIF UPPER(p_obj_type) IN ('EONE', 'EVEO') THEN
      OPEN c_check_eventsch_status(p_obj_id);
      FETCH c_check_eventsch_status INTO l_status_code;
      IF c_check_eventsch_status%FOUND THEN
         x_flag := 'Y';
      END IF;
      CLOSE c_check_eventsch_status;
   END IF;
END Have_Published;

-- Start of comments
-- NAME
--    Init_ActMetric_Rec
--
-- PURPOSE
--    This Procedure will initialize the Record for Activity Metric.
--    It will be called before call to Update Activity Metric
--
-- NOTES
--
-- HISTORY
-- 10/11/2000   SVEERAVE         Created.
-- 05/07/2001   HuiLi            Added the "depend_act_metric" field
--
-- End of comments

PROCEDURE Init_ActMetric_Rec(
   x_act_metric_rec  IN OUT NOCOPY  Ams_Actmetric_Pvt.Act_metric_rec_type
)  IS
BEGIN
  x_act_metric_rec.activity_metric_id                := Fnd_Api.G_MISS_NUM ;
  x_act_metric_rec.last_update_date                  := Fnd_Api.G_MISS_DATE ;
  x_act_metric_rec.last_updated_by                   := Fnd_Api.G_MISS_NUM ;
  x_act_metric_rec.creation_date                     := Fnd_Api.G_MISS_DATE ;
  x_act_metric_rec.created_by                        := Fnd_Api.G_MISS_NUM ;
  x_act_metric_rec.last_update_login                 := Fnd_Api.G_MISS_NUM ;
  x_act_metric_rec.object_version_number             := Fnd_Api.G_MISS_NUM ;
  x_act_metric_rec.act_metric_used_by_id             := Fnd_Api.G_MISS_NUM ;
  x_act_metric_rec.arc_act_metric_used_by            := Fnd_Api.G_MISS_CHAR ;
  x_act_metric_rec.purchase_req_raised_flag          := Fnd_Api.G_MISS_CHAR ;
  x_act_metric_rec.application_id                    := Fnd_Api.G_MISS_NUM ;
  x_act_metric_rec.sensitive_data_flag               := Fnd_Api.G_MISS_CHAR ;
  x_act_metric_rec.budget_id                         := Fnd_Api.G_MISS_NUM ;
  x_act_metric_rec.metric_id                         := Fnd_Api.G_MISS_NUM ;
  x_act_metric_rec.transaction_currency_code         := Fnd_Api.G_MISS_CHAR ;
  x_act_metric_rec.trans_forecasted_value            := Fnd_Api.G_MISS_NUM ;
  x_act_metric_rec.trans_committed_value             := Fnd_Api.G_MISS_NUM ;
  x_act_metric_rec.trans_actual_value                := Fnd_Api.G_MISS_NUM ;
  x_act_metric_rec.functional_currency_code          := Fnd_Api.G_MISS_CHAR ;
  x_act_metric_rec.func_forecasted_value             := Fnd_Api.G_MISS_NUM ;
  x_act_metric_rec.dirty_flag                        := Fnd_Api.G_MISS_CHAR ;
  x_act_metric_rec.func_committed_value              := Fnd_Api.G_MISS_NUM ;
  x_act_metric_rec.func_actual_value                 := Fnd_Api.G_MISS_NUM ;
  x_act_metric_rec.last_calculated_date              := Fnd_Api.G_MISS_DATE ;
  x_act_metric_rec.variable_value                    := Fnd_Api.G_MISS_NUM ;
  x_act_metric_rec.forecasted_variable_value         := Fnd_Api.G_MISS_NUM;
  x_act_metric_rec.computed_using_function_value     := Fnd_Api.G_MISS_NUM ;
  x_act_metric_rec.metric_uom_code                   := Fnd_Api.G_MISS_CHAR ;
  x_act_metric_rec.org_id                            := Fnd_Api.G_MISS_NUM ;
  x_act_metric_rec.difference_since_last_calc        := Fnd_Api.G_MISS_NUM ;
  x_act_metric_rec.activity_metric_origin_id         := Fnd_Api.G_MISS_NUM ;
  x_act_metric_rec.arc_activity_metric_origin        := Fnd_Api.G_MISS_CHAR ;
  x_act_metric_rec.days_since_last_refresh           := Fnd_Api.G_MISS_NUM ;
  x_act_metric_rec.scenario_id                       := Fnd_Api.G_MISS_NUM ;
  /* yzhao: 09/24/2001 add following lines */
  x_act_metric_rec.summarize_to_metric               := Fnd_Api.G_MISS_NUM ;
  x_act_metric_rec.rollup_to_metric                  := Fnd_Api.G_MISS_NUM ;
  x_act_metric_rec.hierarchy_id                      := Fnd_Api.G_MISS_NUM ;
  x_act_metric_rec.start_node                        := Fnd_Api.G_MISS_NUM ;
  x_act_metric_rec.from_level                        := Fnd_Api.G_MISS_NUM ;
  x_act_metric_rec.to_level                          := Fnd_Api.G_MISS_NUM ;
  x_act_metric_rec.from_date                         := Fnd_Api.G_MISS_DATE ;
  x_act_metric_rec.TO_DATE                           := Fnd_Api.G_MISS_DATE ;
  x_act_metric_rec.amount1                           := Fnd_Api.G_MISS_NUM ;
  x_act_metric_rec.amount2                           := Fnd_Api.G_MISS_NUM ;
  x_act_metric_rec.amount3                           := Fnd_Api.G_MISS_NUM ;
  x_act_metric_rec.percent1                          := Fnd_Api.G_MISS_NUM ;
  x_act_metric_rec.percent2                          := Fnd_Api.G_MISS_NUM ;
  x_act_metric_rec.percent3                          := Fnd_Api.G_MISS_NUM ;
  x_act_metric_rec.published_flag                    := Fnd_Api.G_MISS_CHAR ;
  x_act_metric_rec.pre_function_name                 := Fnd_Api.G_MISS_CHAR ;
  x_act_metric_rec.post_function_name                := Fnd_Api.G_MISS_CHAR ;
  -- x_act_metric_rec.security_group_id                 := Fnd_Api.G_MISS_NUM ;
  /* yzhao: 09/24/2001 ends */
  x_act_metric_rec.attribute_category                := Fnd_Api.G_MISS_CHAR ;
  x_act_metric_rec.attribute1                        := Fnd_Api.G_MISS_CHAR ;
  x_act_metric_rec.attribute2                        := Fnd_Api.G_MISS_CHAR ;
  x_act_metric_rec.attribute3                        := Fnd_Api.G_MISS_CHAR ;
  x_act_metric_rec.attribute4                        := Fnd_Api.G_MISS_CHAR ;
  x_act_metric_rec.attribute5                        := Fnd_Api.G_MISS_CHAR ;
  x_act_metric_rec.attribute6                        := Fnd_Api.G_MISS_CHAR ;
  x_act_metric_rec.attribute7                        := Fnd_Api.G_MISS_CHAR ;
  x_act_metric_rec.attribute8                        := Fnd_Api.G_MISS_CHAR ;
  x_act_metric_rec.attribute9                        := Fnd_Api.G_MISS_CHAR ;
  x_act_metric_rec.attribute10                       := Fnd_Api.G_MISS_CHAR ;
  x_act_metric_rec.attribute11                       := Fnd_Api.G_MISS_CHAR ;
  x_act_metric_rec.attribute12                       := Fnd_Api.G_MISS_CHAR ;
  x_act_metric_rec.attribute13                       := Fnd_Api.G_MISS_CHAR ;
  x_act_metric_rec.attribute14                       := Fnd_Api.G_MISS_CHAR ;
  x_act_metric_rec.attribute15                       := Fnd_Api.G_MISS_CHAR ;
  x_act_metric_rec.description                       := Fnd_Api.G_MISS_CHAR ;
  x_act_metric_rec.act_metric_date                   := Fnd_Api.G_MISS_DATE ;
  x_act_metric_rec.depend_act_metric                 := Fnd_Api.G_MISS_NUM ;
  x_act_metric_rec.function_used_by_id               := Fnd_Api.G_MISS_NUM ;
  x_act_metric_rec.arc_function_used_by              := Fnd_Api.G_MISS_CHAR ;
  /* 05/15/2002 yzhao: 11.5.9 add 6 new columns for top-down bottom-up budgeting */
  x_act_metric_rec.hierarchy_type                    := Fnd_Api.G_MISS_CHAR ;
  x_act_metric_rec.status_code                       := Fnd_Api.G_MISS_CHAR ;
  x_act_metric_rec.method_code                       := Fnd_Api.G_MISS_CHAR ;
  x_act_metric_rec.action_code                       := Fnd_Api.G_MISS_CHAR ;
  x_act_metric_rec.basis_year                        := Fnd_Api.G_MISS_NUM ;
  x_act_metric_rec.ex_start_node                     := Fnd_Api.G_MISS_CHAR ;
  /* 05/15/2002 yzhao: add ends */
END Init_ActMetric_Rec;


-- Start of comments
-- API Name       IsSeeded
-- Type           Private
-- Pre-reqs       None.
-- Function       Returns whether the given ID is that of a seeded record.
--
-- Parameters
--    IN          p_id                                          IN  NUMBER
--    OUT NOCOPY         Returns the boolean Value to show
--                                hether the metric is seeded or not
-- Version        Current version: 1.0
--                Previous version: 1.0
--                Initial version: 1.0
-- End of comments

FUNCTION IsSeeded (
   p_id        IN NUMBER
)
RETURN BOOLEAN ;

-----------------------------------------------------------------------------
-- NAME
--    Make_ActMetric_Dirty
-- PURPOSE
--    Given an activity metric id, update the dirty_flag of the activity metric
--    and that of all the activity metrics above it in the hierarchy.
-- HISTORY
-- 13-Oct-2000 choang   Created.
----------------------------------------------------------------------------
PROCEDURE Make_ActMetric_Dirty (
   p_activity_metric_id IN NUMBER
)
IS
BEGIN
   -- update for summarize_to_metric
   UPDATE ams_act_metrics_all
   SET dirty_flag = G_IS_DIRTY
   WHERE activity_metric_id IN (
            SELECT activity_metric_id
            FROM   ams_act_metrics_all
            START WITH activity_metric_id = p_activity_metric_id
            CONNECT BY activity_metric_id = PRIOR summarize_to_metric)
   AND dirty_flag <> G_IS_DIRTY
   ;

   -- update for rollup_to_metric
   UPDATE ams_act_metrics_all
   SET dirty_flag = G_IS_DIRTY
   WHERE activity_metric_id IN (
            SELECT activity_metric_id
            FROM   ams_act_metrics_all
            START WITH activity_metric_id = p_activity_metric_id
            CONNECT BY activity_metric_id = PRIOR rollup_to_metric)
   AND dirty_flag <> G_IS_DIRTY
   ;

   -- update effected formulas
   update ams_act_metrics_all
   set dirty_flag = G_IS_DIRTY
   where activity_metric_id in
   (select a.activity_metric_id
   from ams_act_metrics_all a, ams_metrics_all_b m, ams_metric_formulas f,
        ams_act_metrics_all b, ams_metrics_all_b c
   where a.metric_id = m.metric_id
   and m.metric_id = f.metric_id
   and b.metric_id = c.metric_id
   and a.arc_act_metric_used_by = b.arc_act_metric_used_by
   and a.act_metric_used_by_id = b.act_metric_used_by_id
   and m.metric_calculation_type = G_FORMULA
   and a.last_update_date > b.last_update_date
   and ((b.metric_id = f.source_id and f.source_type = G_METRIC)
      or (c.metric_category = f.source_id and f.source_type = G_CATEGORY))
   and b.activity_metric_id = p_activity_metric_id)
   and dirty_flag <> G_IS_DIRTY;

   -- Update for effected variable metrics.
   UPDATE ams_act_metrics_all
     SET dirty_flag = G_IS_DIRTY
   WHERE activity_metric_id IN
     (SELECT a.activity_metric_id
        FROM ams_act_metrics_all a, ams_metrics_all_b b,
             ams_act_metrics_all c
       WHERE a.metric_id = b.metric_id
         AND b.accrual_type = G_VARIABLE
         AND a.arc_act_metric_used_by = c.arc_act_metric_used_by
         AND a.act_metric_used_by_id = c.act_metric_used_by_id
         AND c.activity_metric_id = p_activity_metric_id
         AND TO_NUMBER(NVL(b.compute_using_function,'-1')) = c.metric_id);

END Make_ActMetric_Dirty;



/* 07/11/2000 svatsa@us    Create_ParentActMetric */
-- Start of comments
-- NAME
--    Create_ParentActMetric
--
--
-- PURPOSE
--    Creates an association of a metric to a business object
--    by creating a record in AMS_ACT_METRICS_ALL by calling Create_ActMetric2.
--
-- NOTES
--
-- HISTORY
-- 07/11/2000   svatsa@us      Created.
-- 05/01/2001   dmvincen@us    Added return of the summarize actmetric.
--
-- End of comments

PROCEDURE Create_ParentActMetric
  (p_api_version                IN      NUMBER
  ,p_init_msg_list              IN  VARCHAR2 := Fnd_Api.G_FALSE
  ,p_commit                     IN  VARCHAR2 := Fnd_Api.G_FALSE
  ,p_validation_level           IN  NUMBER   := Fnd_Api.G_Valid_Level_Full
  ,p_act_metric_rec             IN OUT NOCOPY act_metric_rec_type
  ,x_act_metric_id              OUT NOCOPY NUMBER
  )
IS
  -- Local variables to accept the out parameters from the api Create_ActMetric2
  l_return_status      VARCHAR2(1);
  l_msg_count          NUMBER;
  l_msg_data           VARCHAR2(2000);

  -- Cursor to check if the entry for summary metric_id for
  -- a given act_metric_used_by_id and arc_act_metric_used_by already exists
  CURSOR c_exist_parent_entry (cv_metric_id NUMBER
                              ,cv_act_metric_used_by_id  NUMBER
                              ,cv_arc_act_metric_used_by VARCHAR2) IS
    SELECT activity_metric_id
    FROM   ams_act_metrics_all
    WHERE  metric_id              = cv_metric_id
    AND    act_metric_used_by_id  = cv_act_metric_used_by_id
    AND    arc_act_metric_used_by = cv_arc_act_metric_used_by;


  -- Local variable for storing the activity_metric_id selected by the cursor
  -- c_exist_parent_entry
  l_act_metric_id NUMBER;


BEGIN

  -- Check if the entry for summary metric already exists
  OPEN  c_exist_parent_entry (p_act_metric_rec.metric_id
                             ,p_act_metric_rec.act_metric_used_by_id
                             ,p_act_metric_rec.arc_act_metric_used_by);
  FETCH c_exist_parent_entry INTO l_act_metric_id;
  CLOSE c_exist_parent_entry;

  -- Conditionally call the Api Create_ActMetric2 for creating
  -- the record for summary metric
  IF l_act_metric_id IS NULL THEN
     Create_ActMetric2
      (p_api_version        => p_api_version
      ,p_init_msg_list      => p_init_msg_list
      ,p_commit             => p_commit
      ,p_validation_level   => p_validation_level
      ,x_return_status      => l_return_status
      ,x_msg_count          => l_msg_count
      ,x_msg_data           => l_msg_data
      ,p_act_metric_rec     => p_act_metric_rec
      ,x_activity_metric_id => l_act_metric_id
      );
  END IF;

  x_act_metric_id := l_act_metric_id;

END Create_ParentActMetric;

---------------------------------------------------------------------
-- PROCEDURE
--   GET_TRANS_CURR_CODE
--
-- PURPOSE
--    Finds the transaction currency code.
--
-- PARAMETERS
--   p_obj_id                   IN  NUMBER
--   p_obj_type                 IN  VARCHAR2
--   x_trans_curr_code          OUT NOCOPY VARCHAR2
--
-- NOTES
--
-- HISTORY
--  06/19/2001  DMVINCEN   Created
--
-- End of comments
----------------------------------------------------------------------
PROCEDURE Get_Trans_curr_code
  (p_obj_id                     IN  NUMBER
  ,p_obj_type                   IN  VARCHAR2
  ,x_trans_curr_code            OUT NOCOPY VARCHAR2
  )
IS
    -- select transaction_currency_code for campaign
    CURSOR c_get_camp_trans_curr(l_obj_id       NUMBER) IS
    SELECT transaction_currency_code
    FROM ams_campaigns_all_b
    WHERE campaign_id = l_obj_id;

    -- select transaction_currency_code for campaign schedule
    CURSOR c_get_csch_trans_curr(l_obj_id       NUMBER) IS
    SELECT transaction_currency_code
    FROM ams_campaign_schedules_b
    WHERE schedule_id = l_obj_id;

    -- select transaction_currency_code for event offer
    CURSOR c_get_eveo_trans_curr(l_obj_id       NUMBER) IS
    SELECT currency_code_tc
    FROM ams_event_offers_all_b
    WHERE event_offer_id = l_obj_id;

    -- select transaction_currency_code for event header
    CURSOR c_get_eveh_trans_curr(l_obj_id       NUMBER) IS
    SELECT currency_code_tc
    FROM ams_event_headers_all_b
    WHERE event_header_id = l_obj_id;

    -- select transaction_currency_code for deliverable
    CURSOR c_get_delv_trans_curr(l_obj_id       NUMBER) IS
    SELECT transaction_currency_code
    FROM ams_deliverables_all_b
    WHERE deliverable_id = l_obj_id;

    l_obj_trans_curr    VARCHAR2(15);
BEGIN
   --Get the trans currency code for parent object
   IF p_obj_type IN ('RCAM', 'CAMP') THEN
      OPEN c_get_camp_trans_curr(p_obj_id);
      FETCH c_get_camp_trans_curr INTO l_obj_trans_curr;
      CLOSE c_get_camp_trans_curr;
   ELSIF p_obj_type = 'CSCH' THEN
      OPEN c_get_csch_trans_curr(p_obj_id);
      FETCH c_get_csch_trans_curr INTO l_obj_trans_curr;
      CLOSE c_get_csch_trans_curr;
   ELSIF p_obj_type IN ('EONE', 'EVEO') THEN
      OPEN c_get_eveo_trans_curr(p_obj_id);
      FETCH c_get_eveo_trans_curr INTO l_obj_trans_curr;
      CLOSE c_get_eveo_trans_curr;
   ELSIF p_obj_type = 'EVEH' THEN
      OPEN c_get_eveh_trans_curr(p_obj_id);
      FETCH c_get_eveh_trans_curr INTO l_obj_trans_curr;
      CLOSE c_get_eveh_trans_curr;
   ELSIF p_obj_type = 'DELV' THEN
      OPEN c_get_delv_trans_curr(p_obj_id);
      FETCH c_get_delv_trans_curr INTO l_obj_trans_curr;
      CLOSE c_get_delv_trans_curr;
   END IF;
        x_trans_curr_code  := l_obj_trans_curr;
END Get_Trans_curr_code;

/* 10/11/2000 sveerave@us    Sync_rollup_currency */
---------------------------------------------------------------------
-- PROCEDURE
--   SYNC_ROLLUP_CURRENCY
--
-- PURPOSE
--    Flips the trasaction currency code of rollup metrics to parent object's
--    transaction currency code and calls the refresh metrics API.
--
-- PARAMETERS
--   p_obj_id                   IN  NUMBER
--   p_obj_type                 IN  VARCHAR2
--  x_return_status             OUR VARCHAR2
--
-- NOTES
--    1. Get parent object's transaction currency code
--    2. Flip the rollup metrics currency to parent object's transaction
--                      currency code
--    3. Do the above only for ROLLUP metrics
--
-- HISTORY
-- 10/11/2000   SVEERAVE@us      Created.
--
-- End of comments
----------------------------------------------------------------------

PROCEDURE Sync_rollup_currency
  (p_obj_id                     IN  NUMBER
  ,p_obj_type                   IN  VARCHAR2
  ,x_return_status              OUT NOCOPY VARCHAR2
  ) IS

    -- select rollup metrics of currency category
    CURSOR c_get_rollup_metrics(l_obj_id NUMBER, l_obj_type VARCHAR2) IS
      SELECT activity_metric_id, transaction_currency_code,
             trans_actual_value, trans_forecasted_value
      FROM ams_act_metrics_all actmet, ams_metrics_all_b met
      WHERE actmet.metric_id = met.metric_id
      AND metric_calculation_type IN ('ROLLUP', 'SUMMARY')
      AND arc_act_metric_used_by = l_obj_type
      AND act_metric_used_by_id = l_obj_id
      AND transaction_currency_code IS NOT NULL;

    -- Check the metrics category
    CURSOR c_check_met_category(l_met_id NUMBER) IS
    SELECT metric_category
    FROM  ams_metrics_all_b
    WHERE metric_id = l_met_id;

    --Local variables to accept the out parameters from the api Create_ActMetric2
    l_msg_count          NUMBER;
    l_msg_data           VARCHAR2(2000);
    l_act_metric_id     NUMBER;
    l_act_metric_trans_curr     VARCHAR2(15);
    l_actual_val        NUMBER;
    l_forecasted_val    NUMBER;
    l_act_metric_rec    Ams_Actmetric_Pvt.act_metric_rec_type;
    l_obj_trans_curr    VARCHAR2(15);

BEGIN

  --Get all the ROLLUP currency type metrics for the passed in obj id, obj type
   OPEN c_get_rollup_metrics(p_obj_id, p_obj_type);
   LOOP
      FETCH c_get_rollup_metrics
         INTO l_act_metric_id, l_act_metric_trans_curr,
              l_actual_val, l_forecasted_val ;
      EXIT WHEN c_get_rollup_metrics%NOTFOUND;
      --Get the trans currency code for current object
      Get_Trans_curr_code(p_obj_id, p_obj_type, l_obj_trans_curr);

      -- Flip the currencies only when they are different.
      IF l_obj_trans_curr <> l_act_metric_trans_curr THEN
         -- Initialize ActMetric_Rec for the update
         Init_ActMetric_Rec(x_act_metric_rec => l_act_metric_rec);
         l_act_metric_rec.activity_metric_id  := l_act_metric_id;
         l_act_metric_rec.transaction_currency_code := l_obj_trans_curr;
         l_act_metric_rec.trans_actual_value := NULL;
         l_act_metric_rec.trans_forecasted_value := NULL;

         -- Call the update API
         Ams_Actmetric_Pvt.update_actmetric (
               p_api_version                => 1.0,
               p_act_metric_rec             => l_act_metric_rec,
               x_return_status              => x_return_status,
               x_msg_count                  => l_msg_count,
               x_msg_data                   => l_msg_data);

         IF x_return_status = Fnd_Api.G_RET_STS_ERROR THEN
            IF(l_msg_count > 0) THEN
               FOR i IN 1 .. l_msg_count
               LOOP
                  l_msg_data := Fnd_Msg_Pub.get(i, Fnd_Api.g_false);
               END LOOP;
            END IF;
            CLOSE c_get_rollup_metrics;
            RAISE Fnd_Api.G_EXC_ERROR;
         ELSIF x_return_status = Fnd_Api.G_RET_STS_UNEXP_ERROR THEN
            CLOSE c_get_rollup_metrics;
            RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
         END IF; -- for IF l_return_status = FND_API.G_RET_STS_ERROR
     END IF; --   IF l_obj_trans_curr <> l_act_metric_trans_curr THEN
  END LOOP;
  CLOSE c_get_rollup_metrics;

END sync_rollup_currency;


-- Start of comments
-- NAME
--    Default_ActMetric
--
--
-- PURPOSE
--    Defaults the Activty Metric . also does Currency Conversion to
--    keep Transaction and currency Conversion in Sync.
--
-- NOTES
--
-- HISTORY
-- 10/25/1999   ptendulk   Created
-- 08/28/2000   SVEERAVE   Modified to convert/default metric values with
--                         currencies and with out currencies in case of manual
--                         or non-manual type metrics.  Replaced API call for
--                         currency conversions with centralized AMS_UTILITY_PVT
--                         api.
-- 10/11/2000   SVEERAVE   Defaulted trans_currency_code to be that of parent
--                         object's
-- End of comments

PROCEDURE Default_ActMetric(
   p_init_msg_list          IN  VARCHAR2 := Fnd_Api.G_FALSE,
   --p_act_metric_rec         IN  act_metric_rec_type,
   p_validation_mode        IN  VARCHAR2 ,
   x_complete_rec           IN OUT NOCOPY act_metric_rec_type,
   x_return_status          OUT NOCOPY VARCHAR2,
   x_msg_count              OUT NOCOPY NUMBER,
   x_msg_data               OUT NOCOPY VARCHAR2
)
IS
   --huili@ 05/08/2001 to handle variable metrics
   CURSOR c_met_det(l_met_id NUMBER) IS
      SELECT sensitive_data_flag,
             default_uom_code,
             metric_calculation_type,
             metric_category, accrual_type,
             display_type
      FROM   ams_metrics_all_b
      WHERE  metric_id = l_met_id ;

   l_met_det_rec c_met_det%ROWTYPE ;
   l_obj_trans_curr     VARCHAR2(15);
   l_return_status              VARCHAR2(1);
   l_curr_return_status VARCHAR2(1) := Fnd_Api.G_RET_STS_SUCCESS;
   l_current_date       DATE := SYSDATE;
   l_trans_actual_value number;
   l_trans_forecasted_value number;

BEGIN
   --
   -- Initialize message list if p_init_msg_list is set to TRUE.
   --
   IF Fnd_Api.To_Boolean (p_init_msg_list) THEN
      Fnd_Msg_Pub.Initialize;
   END IF;

   --
   -- Initialize API return status to success.
   --
   x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

--   x_complete_rec := p_act_metric_rec;

--   OPEN c_met_det(p_act_metric_rec.metric_id);
   OPEN c_met_det(x_complete_rec.metric_id);
   FETCH c_met_det INTO l_met_det_rec;
   CLOSE c_met_det;

   IF p_validation_mode = Jtf_Plsql_Api.g_create THEN
   -- Insert Mode

      -- Default Sensitive data Flag and UOM code if not sent to the API
      IF (x_complete_rec.sensitive_data_flag IS NULL OR
          x_complete_rec.metric_uom_code IS NULL) THEN
         IF x_complete_rec.sensitive_data_flag IS NULL  THEN
            x_complete_rec.sensitive_data_flag :=
                                        l_met_det_rec.sensitive_data_flag ;
         END IF;
         IF x_complete_rec.metric_uom_code IS NULL  THEN
            x_complete_rec.metric_uom_code := l_met_det_rec.default_uom_code;
         END IF;
      END IF ;
      -- DMVINCEN 05/25/2001: Added for posting data.
      IF l_met_det_rec.metric_category = 901 then
         x_complete_rec.published_flag := 'N';
      END IF;
   END IF ;

   -- Following code is Common for both Update and Insert Mode

   -- default the currencies.
--   IF (l_met_det_rec.metric_category IN (901,902)) THEN
   IF (l_met_det_rec.metric_category IN (901,902) or
       l_met_det_rec.display_type = 'CURRENCY') THEN
      -- This default functional currency is the overriding currency even
      -- when the functional currency is passed.
      x_complete_rec.functional_currency_code := Default_Func_Currency;

      -- Default the transaction currency from the parent object's
      -- transaction currency.
      IF x_complete_rec.transaction_currency_code IS NULL OR
         l_met_det_rec.metric_calculation_type IN ('SUMMARY', 'ROLLUP') THEN
         Get_Trans_curr_code(x_complete_rec.act_metric_used_by_id,
            x_complete_rec.arc_act_metric_used_by, l_obj_trans_curr);
         IF l_obj_trans_curr IS NOT NULL THEN
            x_complete_rec.transaction_currency_code := l_obj_trans_curr;
         ELSE
            x_complete_rec.transaction_currency_code := Default_Func_Currency;
         END IF;
      --ELSE
      --   x_complete_rec.transaction_currency_code :=
      --      p_act_metric_rec.transaction_currency_code;
      END IF;
   ELSE -- Non currency metric.
      x_complete_rec.functional_currency_code := NULL;
      x_complete_rec.transaction_currency_code := NULL;
   END IF; -- for IF (l_met_det_rec.metric_category  IN (901,902)) THEN

   -- In case of manual metrics, drive with transaction values
   -- if 1) funcional and transaction values are not null or
   --    2) transactional is not null and functional is null
   -- otherwise, i.e. functional is not null and transaction is null
   --              drive with functional value.

   IF l_met_det_rec.metric_calculation_type IN ('MANUAL', 'FUNCTION') THEN
      IF x_complete_rec.transaction_currency_code IS NOT NULL AND
         x_complete_rec.transaction_currency_code <> Fnd_Api.G_MISS_CHAR THEN

         l_trans_actual_value := x_complete_rec.trans_actual_value;
         l_trans_forecasted_value := x_complete_rec.trans_forecasted_value;
         -- Round the transaction values to the Minimum Accountable Unit.
         Convert_Currency2 (
            x_return_status  => l_curr_return_status,
            p_from_currency  => x_complete_rec.transaction_currency_code,
            p_to_currency    => x_complete_rec.transaction_currency_code,
            p_conv_date      => l_current_date,
            p_from_amount    => l_trans_actual_value,
            x_to_amount      => x_complete_rec.trans_actual_value,
            p_from_amount2   => l_trans_forecasted_value,
            x_to_amount2     => x_complete_rec.trans_forecasted_value,
            p_round          => Fnd_Api.G_TRUE);

         IF (x_complete_rec.func_actual_value IS NOT NULL AND
             x_complete_rec.func_actual_value <> Fnd_Api.G_MISS_NUM) AND
            (x_complete_rec.trans_actual_value IS NULL
            /* OR l_met_det_rec.accrual_type = 'VARIABLE' */) THEN

            -- drive with func value

            Convert_Currency (
               x_return_status  => l_curr_return_status,
               p_from_currency  => x_complete_rec.functional_currency_code,
               p_to_currency    => x_complete_rec.transaction_currency_code,
               p_conv_date      => l_current_date,
               p_from_amount    => NVL(x_complete_rec.func_actual_value,0),
               x_to_amount      => x_complete_rec.trans_actual_value,
               p_round          => Fnd_Api.G_TRUE);
            IF l_curr_return_status <> Fnd_Api.G_RET_STS_SUCCESS THEN
               RAISE Fnd_Api.G_EXC_ERROR;
            END IF;
         ELSIF x_complete_rec.trans_actual_value IS NOT NULL AND
            x_complete_rec.trans_actual_value <> Fnd_Api.G_MISS_NUM THEN
            -- drive with trans value
            Convert_Currency (
               x_return_status  => l_curr_return_status,
               p_from_currency  => x_complete_rec.transaction_currency_code,
               p_to_currency    => x_complete_rec.functional_currency_code,
               p_conv_date      => l_current_date,
               p_from_amount    => NVL(x_complete_rec.trans_actual_value,0),
               x_to_amount      => x_complete_rec.func_actual_value,
               p_round          => Fnd_Api.G_FALSE);

            IF l_curr_return_status <> Fnd_Api.G_RET_STS_SUCCESS THEN
               RAISE Fnd_Api.G_EXC_ERROR;
            END IF;
         END IF;

         IF (x_complete_rec.func_forecasted_value IS NOT NULL AND
            x_complete_rec.func_forecasted_value <> Fnd_Api.G_MISS_NUM) AND
            (x_complete_rec.trans_forecasted_value IS NULL) THEN
            -- drive with func value
            Convert_Currency (
             x_return_status => l_curr_return_status,
             p_from_currency => x_complete_rec.functional_currency_code,
             p_to_currency   => x_complete_rec.transaction_currency_code,
             p_conv_date     => l_current_date,
             p_from_amount   => NVL(x_complete_rec.func_forecasted_value,0),
             x_to_amount     => x_complete_rec.trans_forecasted_value,
             p_round         => Fnd_Api.G_TRUE);
            IF l_curr_return_status <> Fnd_Api.G_RET_STS_SUCCESS THEN
               RAISE Fnd_Api.G_EXC_ERROR;
            END IF;
         ELSIF (x_complete_rec.trans_forecasted_value IS NOT NULL AND
            x_complete_rec.trans_forecasted_value <> Fnd_Api.G_MISS_NUM) THEN
            --drive with trans value
            Convert_Currency (
               x_return_status => l_curr_return_status,
               p_from_currency => x_complete_rec.transaction_currency_code,
               p_to_currency   => x_complete_rec.functional_currency_code,
               p_conv_date     => l_current_date,
               p_from_amount   =>NVL(x_complete_rec.trans_forecasted_value,0),
               x_to_amount     => x_complete_rec.func_forecasted_value,
               p_round         => Fnd_Api.G_FALSE);
            IF l_curr_return_status <> Fnd_Api.G_RET_STS_SUCCESS THEN
               RAISE Fnd_Api.G_EXC_ERROR;
            END IF;

         END IF;

      -- in case of non-currencies handle in the same way as above.
      ELSE
         IF (x_complete_rec.func_actual_value IS NOT NULL AND
            x_complete_rec.func_actual_value <> Fnd_Api.G_MISS_NUM) AND
            (x_complete_rec.trans_actual_value IS NULL) THEN
            -- drive with func value
            x_complete_rec.trans_actual_value :=
                                      x_complete_rec.func_actual_value;
         ELSE
            -- drive with trans value.
            x_complete_rec.func_actual_value :=
                                      x_complete_rec.trans_actual_value;
         END IF;

         IF (x_complete_rec.func_forecasted_value IS NOT NULL AND
            x_complete_rec.func_forecasted_value <> Fnd_Api.G_MISS_NUM) AND
            (x_complete_rec.trans_forecasted_value IS NULL) THEN
            -- drive with func value.
            x_complete_rec.trans_forecasted_value :=
                                      x_complete_rec.func_forecasted_value;
         ELSE
            -- drive with trans value.
            x_complete_rec.func_forecasted_value :=
                                      x_complete_rec.trans_forecasted_value;
         END IF;

      END IF; --IF  p_act_metric_rec.transaction_currency_code IS NOT NULL AND

        -- In case of non-manual metrics, drive with functional values
        -- if 1. funcional and transaction values are not null or
        --         2. functional is not null and transactional is null
        -- otherwise, i.e. transaction is not null and functional is null
        --    - drive with transactional value.

   ELSE  -- NOT MANUAL (SUMMARY,ROLLUP)

      -- Now do currency conversions if this metric is currency metric and
      -- transaction currency code is passed.
      IF  (x_complete_rec.transaction_currency_code IS NOT NULL AND
         x_complete_rec.transaction_currency_code <> Fnd_Api.G_MISS_CHAR) THEN
         -- Convert transaction amount to functional amount when only
         -- transaction amount is passed.
         IF (x_complete_rec.trans_actual_value IS NOT NULL AND
            x_complete_rec.trans_actual_value <> Fnd_Api.G_MISS_NUM) AND
            (x_complete_rec.func_actual_value IS NULL) THEN
            Convert_Currency (
               x_return_status => l_curr_return_status,
               p_from_currency => x_complete_rec.transaction_currency_code,
               p_to_currency   => x_complete_rec.functional_currency_code,
               p_conv_date     => l_current_date,
               p_from_amount   => NVL(x_complete_rec.trans_actual_value,0),
               x_to_amount     => x_complete_rec.func_actual_value,
               p_round         => Fnd_Api.G_FALSE);
            IF l_curr_return_status <> Fnd_Api.G_RET_STS_SUCCESS THEN
               RAISE Fnd_Api.G_EXC_ERROR;
            END IF;

         -- drive with func values.
         ELSIF (x_complete_rec.func_actual_value IS NOT NULL AND
              x_complete_rec.func_actual_value <> Fnd_Api.G_MISS_NUM) THEN
            Convert_Currency (
                   x_return_status => l_curr_return_status,
                   p_from_currency => x_complete_rec.functional_currency_code,
                   p_to_currency   => x_complete_rec.transaction_currency_code,
                   p_conv_date     => l_current_date,
                   p_from_amount   => NVL(x_complete_rec.func_actual_value,0),
                   x_to_amount     => x_complete_rec.trans_actual_value,
                   p_round         => Fnd_Api.G_TRUE);
            IF l_curr_return_status <> Fnd_Api.G_RET_STS_SUCCESS THEN
               RAISE Fnd_Api.G_EXC_ERROR;
            END IF;

         END IF; -- (p_act_metric_rec.trans_actual_value IS NOT NULL AND

         -- Convert forecasted values
         -- If func values are passed drive with them otherwise with
         -- trans values

         IF (x_complete_rec.trans_forecasted_value IS NOT NULL AND
            x_complete_rec.trans_forecasted_value <> Fnd_Api.G_MISS_NUM) AND
            (x_complete_rec.func_forecasted_value IS NULL) THEN
             Convert_Currency (
                x_return_status => l_curr_return_status,
                p_from_currency => x_complete_rec.transaction_currency_code,
                p_to_currency   => x_complete_rec.functional_currency_code,
                p_conv_date     => l_current_date,
                p_from_amount => NVL(x_complete_rec.trans_forecasted_value,0),
                x_to_amount     =>  x_complete_rec.func_forecasted_value,
                p_round         => Fnd_Api.G_FALSE);
            IF l_curr_return_status <> Fnd_Api.G_RET_STS_SUCCESS THEN
               RAISE Fnd_Api.G_EXC_ERROR;
            END IF;

         -- drive with func values.
         ELSIF (x_complete_rec.func_forecasted_value IS NOT NULL AND
              x_complete_rec.func_forecasted_value <> Fnd_Api.G_MISS_NUM) THEN
            Convert_Currency (
                x_return_status => l_curr_return_status,
                p_from_currency => x_complete_rec.functional_currency_code,
                p_to_currency   => x_complete_rec.transaction_currency_code,
                p_conv_date     => l_current_date,
                p_from_amount  => NVL(x_complete_rec.func_forecasted_value,0),
                x_to_amount     => x_complete_rec.trans_forecasted_value,
                p_round         => Fnd_Api.G_TRUE);
            IF l_curr_return_status <> Fnd_Api.G_RET_STS_SUCCESS THEN
               RAISE Fnd_Api.G_EXC_ERROR;
            END IF;
         END IF; --if for p_act_metric_rec.func_forecasted_value IS NOT NULL AND

      ELSE -- Transaction currency code is null
         IF (x_complete_rec.trans_actual_value IS NOT NULL AND
           x_complete_rec.trans_actual_value <> Fnd_Api.G_MISS_NUM) AND
           (x_complete_rec.func_actual_value IS NULL) THEN
            x_complete_rec.func_actual_value :=
                                         x_complete_rec.trans_actual_value;
         ELSE
            x_complete_rec.trans_actual_value :=
                                         x_complete_rec.func_actual_value;
         END IF;
         IF (x_complete_rec.trans_forecasted_value IS NOT NULL AND
           x_complete_rec.trans_forecasted_value <> Fnd_Api.G_MISS_NUM) AND
           (x_complete_rec.func_forecasted_value IS NULL) THEN
            x_complete_rec.func_forecasted_value :=
                                         x_complete_rec.trans_forecasted_value;
         ELSE
            x_complete_rec.trans_forecasted_value:=
                                         x_complete_rec.func_forecasted_value ;
         END IF;
      END IF;  --IF  p_act_metric_rec.transaction_currency_code IS NOT NULL

   END IF; -- IF l_met_det_rec.metric_calculation_type = 'MANUAL'

/*EXCEPTION
  WHEN GL_CURRENCY_API.NO_RATE THEN
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
      -- No rate exist for for given conversion date and type between
      -- transaction currency and functional currency
      FND_MESSAGE.Set_Name('AMS', 'AMS_METR_NO_RATE');
      FND_MSG_PUB.Add;
    END IF;
    x_return_status := FND_API.G_RET_STS_ERROR;

    -- If any error happens abort API.
    RETURN;
  WHEN GL_CURRENCY_API.INVALID_CURRENCY THEN
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
      -- Atleast One of the two Currencies specified is invalid
      FND_MESSAGE.Set_Name('AMS', 'AMS_METR_INVALID_CURR');
      FND_MSG_PUB.Add;
    END IF;
    x_return_status := FND_API.G_RET_STS_ERROR;

    -- If any error happens abort API.
    RETURN;
*/
END Default_ActMetric ;

FUNCTION Check_Freeze_Status (
   p_object_type     IN  VARCHAR2,
	p_object_id       IN  NUMBER,
   p_operation_mode  IN  VARCHAR2)  -- 'C','U','D' for Create, Update, or Delete
RETURN VARCHAR2
IS
   -- Cursors for checking of statuses when the object is active.
   -- Relevant in Update.
   CURSOR c_camp_active(id NUMBER) IS
      SELECT Fnd_Api.G_TRUE
      FROM ams_campaigns_all_b
      WHERE campaign_id = id
      AND status_code IN ('SUBMITTED_BA', 'ACTIVE');

   CURSOR c_csch_active(id NUMBER) IS
      SELECT Fnd_Api.G_TRUE
      FROM ams_campaign_schedules_b
      WHERE schedule_id = id
      AND status_code = 'ACTIVE';

   CURSOR c_delv_active(id NUMBER) IS
      SELECT Fnd_Api.G_TRUE
      FROM ams_deliverables_all_b
      WHERE deliverable_id = id
      AND status_code IN ('SUBMITTED_BA', 'AVAILABLE');

   CURSOR c_eveh_active(id NUMBER) IS
      SELECT Fnd_Api.G_TRUE
      FROM ams_event_headers_all_b
      WHERE event_header_id = id
      AND system_status_code IN ('ACTIVE',  'SUBMITTED_BA');

   CURSOR c_eveo_active(id NUMBER) IS
      SELECT Fnd_Api.G_TRUE
      FROM ams_event_offers_all_b
      WHERE event_offer_id = id
      AND system_status_code IN ('SUBMITTED_BA', 'ACTIVE');

   --sunkumar 04/30/2003
   -- Added cursors for checking of statuses when the object is active,
   -- completed or cancelled. Relevant in delete.
   CURSOR c_camp_delete(id NUMBER) IS
      SELECT Fnd_Api.G_TRUE
      FROM ams_campaigns_all_b
      WHERE campaign_id = id
      AND status_code IN ('SUBMITTED_BA', 'ACTIVE', 'COMPLETED', 'CANCELLED');

   CURSOR c_csch_delete(id NUMBER) IS
      SELECT Fnd_Api.G_TRUE
      FROM ams_campaign_schedules_b
      WHERE schedule_id = id
      AND status_code IN ('SUBMITTED_BA', 'ACTIVE', 'COMPLETED', 'CANCELLED');

   CURSOR c_delv_delete(id NUMBER) IS
      SELECT Fnd_Api.G_TRUE
      FROM ams_deliverables_all_b
      WHERE deliverable_id = id
      AND status_code IN ('SUBMITTED_BA', 'AVAILABLE', 'CANCELLED', 'ARCHIVED');

   CURSOR c_eveh_delete(id NUMBER) IS
      SELECT Fnd_Api.G_TRUE
      FROM ams_event_headers_all_b
      WHERE event_header_id = id
      AND system_status_code IN ('ACTIVE', 'CANCELLED', 'SUBMITTED_BA','COMPLETED');

   CURSOR c_eveo_delete(id NUMBER) IS
      SELECT Fnd_Api.G_TRUE
      FROM ams_event_offers_all_b
      WHERE event_offer_id = id
      AND system_status_code IN ('SUBMITTED_BA', 'ACTIVE', 'CANCELLED', 'COMPLETED');

   l_return_value VARCHAR2(1) := Fnd_Api.G_FALSE;

BEGIN
   IF p_operation_mode =G_UPDATE THEN

      IF p_object_type IN ('RCAM', 'CAMP') THEN
         OPEN c_camp_active(p_object_id);
         FETCH c_camp_active INTO l_return_value;
         CLOSE c_camp_active;

      ELSIF (p_object_type = 'CSCH') THEN
         OPEN c_csch_active(p_object_id);
         FETCH c_csch_active INTO l_return_value;
         CLOSE c_csch_active;

      ELSIF (p_object_type = 'DELV') THEN
         OPEN c_delv_active(p_object_id);
         FETCH c_delv_active INTO l_return_value;
         CLOSE c_delv_active;
      -- choang - 04-jan-2005 - bug 4102008
      -- uncommented code to perform validation on events freeze status
      ELSIF (p_object_type = 'EVEH') THEN
         OPEN c_eveh_active(p_object_id);
         FETCH c_eveh_active INTO l_return_value;
         CLOSE c_eveh_active;

      ELSIF p_object_type IN ('EONE', 'EVEO') THEN
         OPEN c_eveo_active(p_object_id);
         FETCH c_eveo_active INTO l_return_value;
         CLOSE c_eveo_active;
     END IF;

   --sunkumar 04/30/2003
   --added logic for restriction on delete depending on object status
   ELSIF p_operation_mode =G_DELETE THEN

      IF p_object_type IN ('RCAM', 'CAMP') THEN
         OPEN c_camp_delete(p_object_id);
         FETCH c_camp_delete INTO l_return_value;
         CLOSE c_camp_delete;

      ELSIF (p_object_type = 'CSCH') THEN
         OPEN c_csch_delete(p_object_id);
         FETCH c_csch_delete INTO l_return_value;
         CLOSE c_csch_delete;

      ELSIF (p_object_type = 'DELV') THEN
         OPEN c_delv_delete(p_object_id);
         FETCH c_delv_delete INTO l_return_value;
         CLOSE c_delv_delete;

      ELSIF (p_object_type = 'EVEH') THEN
         OPEN c_eveh_delete(p_object_id);
         FETCH c_eveh_delete INTO l_return_value;
         CLOSE c_eveh_delete;

      ELSIF p_object_type IN ('EONE', 'EVEO') THEN
         OPEN c_eveo_delete(p_object_id);
         FETCH c_eveo_delete INTO l_return_value;
         CLOSE c_eveo_delete;


      END IF;
   END IF;

   return l_return_value;

END;

-- Start of comments
-- NAME
--    check_freeze_status
--
--
-- PURPOSE
--    Checks whether the budget is frozen by making a call-out for campaign API.
--
-- NOTES
--    This method will be called in update, create, delete APIs
--    to allow or not to allow opertaions intended.

-- HISTORY
-- 08/24/2000           SVEERAVE   Created.
-- 09/13/2000           BGEORGE    modified
-- 05/jan/2005          choang     bug 4102008(11.5.9) / 4104833(11.5.11)


PROCEDURE Check_Freeze_Status (
   p_act_metric_rec             IN  act_metric_rec_type,
   p_operation_mode             IN  VARCHAR2 ,  -- 'C','U','D' for Create, Update, or Delete
   x_freeze_status              OUT NOCOPY VARCHAR2, -- True or False
   x_return_status              OUT NOCOPY VARCHAR2)

IS
  l_return_value VARCHAR2(30);
BEGIN

	 l_return_value := Check_Freeze_Status(
	    p_object_type => p_act_metric_rec.arc_act_metric_used_by,
		 p_object_id => p_act_metric_rec.act_metric_used_by_id,
		 p_operation_mode => p_operation_mode);
   --
   -- Initialize procedure return status to success.
   --
   x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
   -- make a call to API that will be provided in future, and based on that
   -- return OUT NOCOPY parameters.
   -- for time being, return FALSE always
   x_freeze_status := l_return_value;

END;


-- Start of comments
-- NAME
--    Create_ActMetric2
--
--
-- PURPOSE
--    Creates an association of a metric to a business
--    object by creating a record in AMS_ACT_METRICS_ALL.
--
-- NOTES
--
-- HISTORY
-- 05/26/1999   choang         Created.
-- 10/9/1999    ptendulk       Modified According to new Standards
-- 14/Apr-2000  tdonohoe@us    Added new columns for 11.5.2 into insert statement.
-- 06-28-2000   rchahal@us     Modified to allow metric creation for Fund.
-- 07/11/2000   svatsa@us      Updated the API to allow for creating Summary ActMetric
--                             for a given metric_id.
-- 08/24/2000    sveerave@us  Included call-out for check_freeze_status at beginning.
-- End of comments

PROCEDURE Create_ActMetric2 (
   p_api_version                IN  NUMBER,
   p_init_msg_list              IN  VARCHAR2 := Fnd_Api.G_FALSE,
   p_commit                     IN  VARCHAR2 := Fnd_Api.G_FALSE,
   p_validation_level           IN  NUMBER   := Fnd_Api.G_Valid_Level_Full,

   x_return_status              OUT NOCOPY VARCHAR2,
   x_msg_count                  OUT NOCOPY NUMBER,
   x_msg_data                   OUT NOCOPY VARCHAR2,

   p_act_metric_rec             IN  act_metric_rec_type,
   x_activity_metric_id         OUT NOCOPY NUMBER
)

IS
   --
   -- Standard API information constants.
   --
   L_API_VERSION     CONSTANT NUMBER := 1.0;
   L_API_NAME        CONSTANT VARCHAR2(30) := 'Create_ActMetric2';
   L_FULL_NAME       CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| L_API_NAME;


   l_return_status   VARCHAR2(1); -- Return value from procedures.
   l_act_metrics_rec act_metric_rec_type := p_act_metric_rec;

   -- huili@ added on 05/08/2001
   l_dep_act_metric_rec act_metric_rec_type;
   l_dep_act_met_id NUMBER;
   -- end

   l_act_metr_count     NUMBER ;


   CURSOR c_act_metr_count(l_act_metric_id IN NUMBER) IS
      SELECT COUNT(1)
      FROM   ams_act_metrics_all
      WHERE  activity_metric_id = l_act_metric_id;

   CURSOR c_act_met_id IS
      SELECT ams_act_metrics_all_s.NEXTVAL
      FROM   dual;

  -- 05/07/2001 huili for checking the "VARIABLE"
  --CURSOR c_dep_info (l_metric_id NUMBER) IS
  --  SELECT accrual_type, compute_using_function
  --  FROM ams_metrics_all_b
  --  WHERE metric_id = l_metric_id;

  -- 06/27/2001 huili changed to check enable flag of a metric
  --CURSOR c_met_enflag (l_met_id NUMBER) IS
  --  SELECT enabled_flag,
  --       FROM ams_metrics_all_b
  --       WHERE metric_id = l_met_id;

  CURSOR c_met_info (l_met_id NUMBER) IS
    SELECT enabled_flag,  metric_calculation_type,
           summary_metric_id, sensitive_data_flag,
           accrual_type, compute_using_function
    FROM ams_metrics_all_b
    WHERE metric_id = l_met_id;
  l_met_info c_met_info%ROWTYPE;

  CURSOR c_get_multiplier_metric(l_metric_id INTEGER,
        l_object_type VARCHAR2, l_object_id INTEGER)
   IS
   SELECT activity_metric_id
     FROM ams_act_metrics_all
    WHERE arc_act_metric_used_by = l_object_type
      AND act_metric_used_by_id = l_object_id
      AND metric_id = l_metric_id;

  l_depend_act_metric_id INTEGER;
  l_accrual_type VARCHAR2(30);
  l_compute_using_function VARCHAR2(4000);

  -- Local variables to hold the values returned by the
  -- cursor c_get_parent_metric
  l_summary_metric_id   NUMBER;
  l_sensitive_data_flag VARCHAR2(1);
  -- Local record variable for the parent metric
  l_parent_act_metrics_rec  act_metric_rec_type; -- := p_act_metric_rec;
  l_freeze_status                       VARCHAR2(1):= Fnd_Api.G_FALSE;
  l_summarize_to_metric NUMBER;
  l_today DATE := SYSDATE;
  l_org_id         NUMBER;

BEGIN
   --
   -- Initialize savepoint.
   --
   --SAVEPOINT Create_ActMetric2_pvt;

   IF (AMS_DEBUG_HIGH_ON) THEN
      Ams_Utility_Pvt.Debug_Message(l_full_name||': start');
   END IF;


   l_org_id := fnd_profile.value('DEFAULT_ORG_ID');

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
   x_activity_metric_id := NULL;
   --
   -- Begin API Body.
   --

   OPEN c_met_info (p_act_metric_rec.metric_id);
   FETCH c_met_info INTO l_met_info;
   l_summary_metric_id := l_met_info.summary_metric_id;
   l_sensitive_data_flag := l_met_info.sensitive_data_flag;
   l_accrual_type := l_met_info.accrual_type;
   l_compute_using_function := l_met_info.compute_using_function;
   IF UPPER(l_met_info.metric_calculation_type) = 'FUNCTION' THEN
      l_act_metrics_rec.trans_actual_value := NULL;
      l_act_metrics_rec.func_actual_value := NULL;
   END IF;
   CLOSE c_met_info;

   IF UPPER(l_met_info.enabled_flag) = 'N'
    AND UPPER(l_met_info.metric_calculation_type) IN ('MANUAL', 'FUNCTION') THEN
      -- choang - 26-dec-2002 - ignore the metric when create activity metric
      --                        requested.
      IF (AMS_DEBUG_HIGH_ON) THEN
         Ams_Utility_Pvt.Debug_Message(l_full_name||': ignore metric id: ' || p_act_metric_rec.metric_id);
      END IF;

      RETURN;
--      l_return_status := Fnd_Api.G_RET_STS_ERROR;
--      RAISE Fnd_Api.G_EXC_ERROR;
   END IF;
   -- END

   -- Make a call-out to check the frozen status.
   -- If it is frozen, disallow the operation.
   Check_Freeze_Status (p_act_metric_rec,
                        G_CREATE, -- Create is operation mode
                        l_freeze_status,
                        l_return_status);

   IF (l_freeze_status = Fnd_Api.G_TRUE)  THEN
          -- frozen to create the record
      IF Fnd_Msg_Pub.Check_Msg_Level (Fnd_Msg_Pub.G_MSG_LVL_ERROR) THEN
         Fnd_Message.Set_Name('AMS', 'AMS_METR_FROZEN');
         Fnd_Msg_Pub.ADD;
      END IF;
                l_return_status := Fnd_Api.G_RET_STS_ERROR;
        END IF;
   -- If it is frozen, or any errors happen abort API.

   IF l_return_status = Fnd_Api.G_RET_STS_ERROR THEN
      RAISE Fnd_Api.G_EXC_ERROR;
   ELSIF l_return_status = Fnd_Api.G_RET_STS_UNEXP_ERROR THEN
      RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Check for existence of parent metric for this given metric_id
   IF l_summary_metric_id IS NOT NULL THEN
     -- Initialize the record variable for not null values
     l_parent_act_metrics_rec.act_metric_used_by_id  :=
                                    l_act_metrics_rec.act_metric_used_by_id;
     l_parent_act_metrics_rec.arc_act_metric_used_by :=
                                    l_act_metrics_rec.arc_act_metric_used_by;
     l_parent_act_metrics_rec.application_id         :=
                                    l_act_metrics_rec.application_id;
     l_parent_act_metrics_rec.sensitive_data_flag    := l_sensitive_data_flag;
     l_parent_act_metrics_rec.metric_id              := l_summary_metric_id;
     l_parent_act_metrics_rec.dirty_flag             := G_IS_DIRTY;

     -- Create a conditional entry for the parent metric.
     -- Conditional test is in Create_ParentActMetric.
     Create_ParentActMetric
         (p_api_version      => p_api_version
         ,p_init_msg_list    => p_init_msg_list
         ,p_commit           => Fnd_Api.g_false
         ,p_validation_level => p_validation_level
         ,p_act_metric_rec   => l_parent_act_metrics_rec
         ,x_act_metric_id    => l_summarize_to_metric
         );

   END IF;

   l_act_metrics_rec.summarize_to_metric := l_summarize_to_metric;

   IF l_act_metrics_rec.hierarchy_type = FND_API.G_MISS_CHAR then
        l_act_metrics_rec.hierarchy_type := NULL;
   END IF;
   IF l_act_metrics_rec.status_code = FND_API.G_MISS_CHAR then
        l_act_metrics_rec.status_code := NULL;
   END IF;
   IF l_act_metrics_rec.method_code = FND_API.G_MISS_CHAR then
        l_act_metrics_rec.method_code := NULL;
   END IF;
   IF l_act_metrics_rec.action_code = FND_API.G_MISS_CHAR then
        l_act_metrics_rec.action_code := NULL;
   END IF;
   IF l_act_metrics_rec.basis_year = FND_API.G_MISS_NUM then
        l_act_metrics_rec.basis_year := NULL;
   END IF;
   IF l_act_metrics_rec.ex_start_node = FND_API.G_MISS_CHAR then
        l_act_metrics_rec.ex_start_node := NULL;
   END IF;


   -- Default Sensitive data Flag, UOM code if not sent to the API
   -- Do Currency Conversion after defaulting functional currency code
   Default_ActMetric(
            p_init_msg_list       => p_init_msg_list,
            --p_act_metric_rec      => l_act_metrics_rec,
            p_validation_mode     => Jtf_Plsql_Api.g_create,
            x_complete_rec        => l_act_metrics_rec,
            x_return_status       => l_return_status,
            x_msg_count           => x_msg_count,
            x_msg_data            => x_msg_data
        );

   -- If any errors happen abort API.
   IF l_return_status = Fnd_Api.G_RET_STS_ERROR THEN
      RAISE Fnd_Api.G_EXC_ERROR;
   ELSIF l_return_status = Fnd_Api.G_RET_STS_UNEXP_ERROR THEN
      RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
   END IF;

   --
   -- Validate the record before inserting.
   --
   Validate_ActMetric (
      p_api_version               => l_api_version,
      p_init_msg_list             => p_init_msg_list,
      p_validation_level          => p_validation_level,
      x_msg_count                 => x_msg_count,
      x_msg_data                  => x_msg_data,
      x_return_status             => l_return_status,
      p_act_metric_rec            => l_act_metrics_rec
   );

   -- If any errors happen abort API.
   IF l_return_status = Fnd_Api.G_RET_STS_ERROR THEN
      RAISE Fnd_Api.G_EXC_ERROR;
   ELSIF l_return_status = Fnd_Api.G_RET_STS_UNEXP_ERROR THEN
      RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
   END IF;

   --
   -- Debug message.
   --
   IF (AMS_DEBUG_HIGH_ON) THEN
      Ams_Utility_Pvt.debug_message(l_full_name ||': insert');
   END IF;

   IF l_act_metrics_rec.activity_metric_id IS NULL THEN
      LOOP
      --
      -- Set the value for the PK.
         OPEN c_act_met_id;
         FETCH c_act_met_id INTO l_act_metrics_rec.activity_metric_id;
         CLOSE c_act_met_id;

         OPEN  c_act_metr_count(l_act_metrics_rec.activity_metric_id);
         FETCH c_act_metr_count INTO l_act_metr_count ;
         CLOSE c_act_metr_count ;

         EXIT WHEN l_act_metr_count = 0 ;
      END LOOP ;
   END IF;



      IF (AMS_DEBUG_HIGH_ON) THEN
         Ams_Utility_Pvt.Debug_Message(l_full_name||': The org id is ' || l_org_id);
      END IF;
   --
   -- Insert into the base table.
   --
   INSERT INTO ams_act_metrics_all (
         activity_metric_id,
         creation_date,
         created_by,
         last_update_date,
         last_updated_by,
         last_update_login,
         object_version_number,
         act_metric_used_by_id,
         arc_act_metric_used_by,
         purchase_req_raised_flag,
         application_id,
         sensitive_data_flag,
         budget_id,
         metric_id,
         transaction_currency_code,
         trans_forecasted_value,
         trans_committed_value,
         trans_actual_value,
         functional_currency_code,
         func_forecasted_value,
         dirty_flag,
         func_committed_value,
         func_actual_value,
         last_calculated_date,
         variable_value,
         forecasted_variable_value,
         computed_using_function_value,
         metric_uom_code,
         org_id,
         attribute_category,
         difference_since_last_calc,
         activity_metric_origin_id,
         arc_activity_metric_origin,
         days_since_last_refresh,
         scenario_id,
         SUMMARIZE_TO_METRIC,
         hierarchy_id,
         start_node,
         from_level,
         to_level,
         from_date,
         TO_DATE,
         amount1,
         amount2,
         amount3,
         percent1,
         percent2,
         percent3,
         published_flag,
         pre_function_name,
         post_function_name,
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
         description,
         act_metric_date,
         depend_act_metric,
         function_used_by_id,
         arc_function_used_by,
         /* 05/15/2002 yzhao: 11.5.9 add 6 new columns for top-down bottom-up budgeting */
         hierarchy_type,
         status_code,
         method_code,
         action_code,
         basis_year,
         ex_start_node
         /* 05/15/2002 yzhao: add ends */
   )
   VALUES (
        l_act_metrics_rec.activity_metric_id,
        l_today,
        Fnd_Global.User_ID,
        l_today,
        Fnd_Global.User_ID,
        Fnd_Global.Conc_Login_ID,
         1, --Object Version Number
         l_act_metrics_rec.act_metric_used_by_id,
         l_act_metrics_rec.arc_act_metric_used_by,
         NVL(l_act_metrics_rec.purchase_req_raised_flag,'N'),
         l_act_metrics_rec.application_id,
         l_act_metrics_rec.sensitive_data_flag,
         l_act_metrics_rec.budget_id,
         l_act_metrics_rec.metric_id,
         l_act_metrics_rec.transaction_currency_code,
         l_act_metrics_rec.trans_forecasted_value,
         l_act_metrics_rec.trans_committed_value,
         l_act_metrics_rec.trans_actual_value,
         l_act_metrics_rec.functional_currency_code,
         l_act_metrics_rec.func_forecasted_value,
         NVL(l_act_metrics_rec.dirty_flag,G_IS_DIRTY),
         l_act_metrics_rec.func_committed_value,
         l_act_metrics_rec.func_actual_value,
         l_act_metrics_rec.last_calculated_date,
         l_act_metrics_rec.variable_value,
        l_act_metrics_rec.forecasted_variable_value,
         l_act_metrics_rec.computed_using_function_value,
         l_act_metrics_rec.metric_uom_code,
         l_org_id, --TO_NUMBER (SUBSTRB (USERENV ('CLIENT_INFO'), 1, 10)) , -- org_id
         l_act_metrics_rec.attribute_category,
         l_act_metrics_rec.difference_since_last_calc,
         l_act_metrics_rec.activity_metric_origin_id,
         l_act_metrics_rec.arc_activity_metric_origin,
         l_act_metrics_rec.days_since_last_refresh,
         l_act_metrics_rec.scenario_id,
         l_act_metrics_rec.SUMMARIZE_TO_METRIC,
         l_act_metrics_rec.hierarchy_id,
        l_act_metrics_rec.start_node,
        l_act_metrics_rec.from_level,
        l_act_metrics_rec.to_level,
        l_act_metrics_rec.from_date,
        l_act_metrics_rec.TO_DATE,
        l_act_metrics_rec.amount1,
        l_act_metrics_rec.amount2,
        l_act_metrics_rec.amount3,
        l_act_metrics_rec.percent1,
        l_act_metrics_rec.percent2,
        l_act_metrics_rec.percent3,
        l_act_metrics_rec.published_flag,
        l_act_metrics_rec.pre_function_name,
        l_act_metrics_rec.post_function_name,
        l_act_metrics_rec.attribute1,
        l_act_metrics_rec.attribute2,
        l_act_metrics_rec.attribute3,
        l_act_metrics_rec.attribute4,
        l_act_metrics_rec.attribute5,
        l_act_metrics_rec.attribute6,
        l_act_metrics_rec.attribute7,
        l_act_metrics_rec.attribute8,
        l_act_metrics_rec.attribute9,
        l_act_metrics_rec.attribute10,
        l_act_metrics_rec.attribute11,
        l_act_metrics_rec.attribute12,
        l_act_metrics_rec.attribute13,
        l_act_metrics_rec.attribute14,
        l_act_metrics_rec.attribute15,
        l_act_metrics_rec.description,
        l_act_metrics_rec.act_metric_date,
        l_act_metrics_rec.depend_act_metric,
        l_act_metrics_rec.function_used_by_id,
        l_act_metrics_rec.arc_function_used_by,
        /* 05/15/2002 yzhao: 11.5.9 add 6 new columns for top-down bottom-up budgeting */
        l_act_metrics_rec.hierarchy_type,
        l_act_metrics_rec.status_code,
        l_act_metrics_rec.method_code,
        l_act_metrics_rec.action_code,
        l_act_metrics_rec.basis_year,
        l_act_metrics_rec.ex_start_node
        /* 05/15/2002 yzhao: add ends */
     );

   -- huili@ 04/19/2001
   --OPEN c_dep_info (l_act_metrics_rec.metric_id);
   --FETCH c_dep_info INTO l_accrual_type, l_compute_using_function;
   --CLOSE c_dep_info;

   IF l_accrual_type IS NOT NULL
      AND l_accrual_type = G_VARIABLE
      AND l_compute_using_function IS NOT NULL THEN

   IF (AMS_DEBUG_HIGH_ON) THEN
      Ams_Utility_Pvt.Debug_Message(l_full_name||': Variable Metric id='||
         l_act_metrics_rec.metric_id);
      Ams_Utility_Pvt.Debug_Message(l_full_name||': compute_using_function='||
         l_compute_using_function||'.');
   END IF;

      -- Check for a multiplier metric.
      OPEN c_get_multiplier_metric(TO_NUMBER(l_compute_using_function),
          l_act_metrics_rec.arc_act_metric_used_by,
          l_act_metrics_rec.act_metric_used_by_id);
      l_depend_act_metric_id := NULL;
      FETCH c_get_multiplier_metric INTO l_depend_act_metric_id;
      CLOSE c_get_multiplier_metric;

      -- If a multiplier metric does not exist create one.
      IF l_depend_act_metric_id IS NULL THEN

         l_dep_act_metric_rec.depend_act_metric :=
            l_act_metrics_rec.activity_metric_id;
         l_dep_act_metric_rec.metric_id :=
            TO_NUMBER(l_compute_using_function);
         l_dep_act_metric_rec.act_metric_used_by_id :=
            l_act_metrics_rec.act_metric_used_by_id;
         l_dep_act_metric_rec.arc_act_metric_used_by :=
            l_act_metrics_rec.arc_act_metric_used_by;
         l_dep_act_metric_rec.application_id :=
            l_act_metrics_rec.application_id;
         l_dep_act_metric_rec.sensitive_data_flag :=
            l_act_metrics_rec.sensitive_data_flag;
         l_dep_act_metric_rec.budget_id :=
            l_act_metrics_rec.budget_id;
         l_dep_act_metric_rec.description :=
            l_act_metrics_rec.description;
         l_dep_act_metric_rec.dirty_flag := G_IS_DIRTY;
         Create_ActMetric2 (
            p_api_version           => p_api_version,
            p_init_msg_list         => p_init_msg_list,
            p_commit                => p_commit,
            p_validation_level      => p_validation_level,
            x_return_status         => l_return_status,
            x_msg_count             => x_msg_count,
            x_msg_data              => x_msg_data,
            p_act_metric_rec        => l_dep_act_metric_rec,
            x_activity_metric_id    => l_dep_act_met_id);
         -- If any errors happen abort API.
         IF l_return_status = Fnd_Api.G_RET_STS_ERROR THEN
            RAISE Fnd_Api.G_EXC_ERROR;
         ELSIF l_return_status = Fnd_Api.G_RET_STS_UNEXP_ERROR THEN
            RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
         END IF;

--   dmvincen 02/10/2004: no longer useful.
--      UPDATE ams_act_metrics_all
--      SET depend_act_metric = l_dep_act_met_id
--      WHERE activity_metric_id = l_act_metrics_rec.activity_metric_id;
      END IF;
   END IF;
   -- finish addition

  -- Record this record in history table.
  Record_History(l_act_metrics_rec.activity_metric_id, G_CREATE,
                 l_return_status, x_msg_count, x_msg_data);

  -- update all the parent object's rollup metrics or this object's summary
  -- metrics dirty_flag to 'Y' -- SVEERAVE, 10/13/00
  IF NVL(l_act_metrics_rec.dirty_flag,G_IS_DIRTY) = G_IS_DIRTY THEN
    Make_ActMetric_Dirty(l_act_metrics_rec.activity_metric_id);
  END IF;

-- finish

   --
   -- Set OUT NOCOPY value.
   --
   x_activity_metric_id := l_act_metrics_rec.activity_metric_id;

   --
   -- End API Body.
   --

   --
   -- Standard check for commit request.
   --
   --IF Fnd_Api.To_Boolean (p_commit) THEN
   --   COMMIT WORK;
   --END IF;

   --
   -- Standard API to get message count, and if 1,
   -- set the message data OUT NOCOPY variable.
   --
   --Fnd_Msg_Pub.Count_And_Get (
   --   p_count           =>    x_msg_count,
   --   p_data            =>    x_msg_data,
   --   p_encoded         =>    Fnd_Api.G_FALSE
   --);

      --
   -- Add success message to message list.
   --
   IF (AMS_DEBUG_HIGH_ON) THEN
      Ams_Utility_Pvt.debug_message(l_full_name ||': end Success');
   END IF;

/*
EXCEPTION
   WHEN Fnd_Api.G_EXC_ERROR THEN
      ROLLBACK TO Create_ActMetric2_pvt;
      --ROLLBACK;
      x_return_status := Fnd_Api.G_RET_STS_ERROR;
      Fnd_Msg_Pub.Count_And_Get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data,
         p_encoded         =>   FND_API.G_FALSE
      );
   WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Create_ActMetric2_pvt;
      --ROLLBACK;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      Fnd_Msg_Pub.Count_And_Get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data,
         p_encoded         =>   FND_API.G_FALSE
      );
   WHEN OTHERS THEN
      ROLLBACK TO Create_ActMetric2_pvt;
      --ROLLBACK;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      IF Fnd_Msg_Pub.Check_Msg_Level (Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR) THEN
         Fnd_Msg_Pub.Add_Exc_Msg (G_PKG_NAME, L_API_NAME);
      END IF;
      Fnd_Msg_Pub.Count_And_Get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data,
         p_encoded       =>   FND_API.G_FALSE
      );
*/
END Create_ActMetric2;

-- Start of comments
-- NAME
--    Update_ActMetric
--
-- PURPOSE
--   Updates a metric in AMS_ACT_METRICS_ALL given the
--   record for the metrics.
--
-- NOTES
--
-- HISTORY
-- 05/26/1999   choang         Created.
-- 10/9/1999    ptendulk       Modified According to new Standards
-- 17-Apr-2000  tdonohoe       Added new columns to Update statement to
--                             support 11.5.2 release.
-- 08/24/2000    sveerave@us  Included call-out for check_freeze_status at
--                            beginning.
-- 05/07/2001   huili@        Added invalidating corresponding variable metrics
-- End of comments




PROCEDURE Update_ActMetric (
   p_api_version                IN  NUMBER,
   p_init_msg_list              IN  VARCHAR2 := Fnd_Api.G_FALSE,
   p_commit                     IN  VARCHAR2 := Fnd_Api.G_FALSE,
   p_validation_level           IN  NUMBER := Fnd_Api.G_VALID_LEVEL_FULL,

   x_return_status              OUT NOCOPY VARCHAR2,
   x_msg_count                  OUT NOCOPY NUMBER,
   x_msg_data                   OUT NOCOPY VARCHAR2,
   p_act_metric_rec             IN  act_metric_rec_type
)
IS
   L_API_VERSION    CONSTANT NUMBER := 1.0;
   L_API_NAME       CONSTANT VARCHAR2(30) := 'UPDATE_ACTMETRIC';
   L_FULL_NAME      CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

   l_return_status   VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
   l_actmet_rec act_metric_rec_type := p_act_metric_rec;
   l_freeze_status   VARCHAR2(1) := Fnd_Api.G_FALSE;
   l_reprocess_rec   VARCHAR2(1) := Fnd_Api.G_FALSE;

   -- huili@ added to invalidate corresponding activity variable metrics
   l_depend_act_metric NUMBER;
   CURSOR c_check_var_met (l_activity_metric_id NUMBER) IS
      SELECT depend_act_metric
      FROM ams_act_metrics_all a, ams_metrics_all_b b
      WHERE activity_metric_id = l_activity_metric_id
      AND a.metric_id = b.metric_id
      AND b.accrual_type <> G_VARIABLE;
   -- end

--    CURSOR c_get_calc_type (l_metric_id NUMBER) IS
--                 SELECT metric_calculation_type
--                   FROM ams_metrics_all_b
--                  WHERE metric_id = l_metric_id;
   l_calc_type VARCHAR2(10);
   l_cost_table OZF_Fund_Adjustment_Pvt.cost_tbl_type;
   l_cost_rec OZF_Fund_Adjustment_Pvt.cost_rec_type;

BEGIN



   IF (AMS_DEBUG_HIGH_ON) THEN

   Ams_Utility_Pvt.debug_message('Now updating act met id: '||p_act_metric_rec.activity_metric_id);

   END IF;
   --
   -- Initialize savepoint.
   --
   SAVEPOINT Update_ActMetric_pvt;
   --
   -- Output debug message.
   --
   IF (AMS_DEBUG_HIGH_ON) THEN
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
   -- Begin API Body
   --
   -- Debug Message

   IF (AMS_DEBUG_HIGH_ON) THEN
      Ams_Utility_Pvt.debug_message(l_full_name ||': validate');
   END IF;

   -- BUG4391308: Added locking to prevent overwriting.
   Lock_ActMetric ( 1.0, fnd_api.G_FALSE,
             l_return_status, x_msg_count, x_msg_data,
             l_actmet_rec.activity_metric_id,
             l_actmet_rec.object_version_number);

   IF l_return_status = Fnd_Api.G_RET_STS_ERROR THEN
      RAISE Fnd_Api.G_EXC_ERROR;
   ELSIF l_return_status = Fnd_Api.G_RET_STS_UNEXP_ERROR THEN
      RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
   END IF;
   -- BUG4391308: End

   -- replace g_miss_char/num/date with current column values
   Complete_ActMetric_Rec(p_act_metric_rec, l_actmet_rec);


   IF (AMS_DEBUG_HIGH_ON) THEN
      Ams_Utility_Pvt.debug_message(l_full_name ||': select calc type, metric_id ='||l_actmet_rec.metric_id);
   END IF;

   SELECT metric_calculation_type
     INTO l_calc_type
     FROM ams_metrics_all_b
    WHERE metric_id = l_actmet_rec.metric_id;

   -- Data entegrity check.
   IF l_calc_type IN ('SUMMARY', 'ROLLUP','FORMULA') THEN
      l_actmet_rec.published_flag := NULL;
   ELSIF l_actmet_rec.published_flag NOT IN ('Y', 'N', 'T') THEN
      l_actmet_rec.published_flag := 'N';
   END IF;

   -- DMVINCEN 06/05/2001: If value is posted to budget do not update.
   IF l_actmet_rec.published_flag = 'Y' THEN
      IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.g_msg_lvl_error) THEN
         l_actmet_rec.trans_actual_value := Fnd_Api.G_MISS_NUM;
         l_actmet_rec.func_actual_value := Fnd_Api.G_MISS_NUM;
         l_reprocess_rec := Fnd_Api.G_TRUE;
      END IF;
   END IF;

   IF l_reprocess_rec = Fnd_Api.G_TRUE THEN
      Complete_ActMetric_Rec(l_actmet_rec, l_actmet_rec);
   END IF;

   -- Do Currency Conversion
   Default_ActMetric(
         p_init_msg_list       => p_init_msg_list,
        -- p_act_metric_rec      => l_actmet_rec,
         p_validation_mode     => Jtf_Plsql_Api.G_UPDATE,
         x_complete_rec        => l_actmet_rec,
         x_return_status       => l_return_status,
         x_msg_count           => x_msg_count,
         x_msg_data            => x_msg_data  ) ;
   -- If any errors happen abort API.
   IF l_return_status = Fnd_Api.G_RET_STS_ERROR THEN
      RAISE Fnd_Api.G_EXC_ERROR;
   ELSIF l_return_status = Fnd_Api.G_RET_STS_UNEXP_ERROR THEN
      RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
   END IF;

   IF p_validation_level >= Jtf_Plsql_Api.g_valid_level_item THEN
      Validate_ActMetric_items(
         p_act_metric_rec  => l_actmet_rec,
         p_validation_mode => Jtf_Plsql_Api.g_update,
         x_return_status   => l_return_status
      );
      IF l_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
         RAISE Fnd_Api.g_exc_unexpected_error;
      ELSIF l_return_status = Fnd_Api.g_ret_sts_error THEN
         RAISE Fnd_Api.g_exc_error;
      END IF;
   END IF;


   -- replace g_miss_char/num/date with current column values
   --Complete_ActMetric_Rec(l_actmet_rec, l_actmet_rec);

   IF p_validation_level >= Jtf_Plsql_Api.g_valid_level_record THEN

     Validate_ActMetric_Record(
         p_act_metric_rec  => l_actmet_rec,
         p_complete_rec    => l_actmet_rec,
         p_operation_mode  => G_UPDATE,
         x_return_status   => l_return_status
      );
      IF l_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
         RAISE Fnd_Api.g_exc_unexpected_error;
      ELSIF l_return_status = Fnd_Api.g_ret_sts_error THEN
         RAISE Fnd_Api.g_exc_error;
      END IF;
   END IF;

   -- Post a new cost item to the budget.
   IF l_actmet_rec.published_flag = 'T' THEN
      l_return_status := FND_API.G_RET_STS_SUCCESS;
      l_actmet_rec.published_flag := 'Y';
      l_cost_rec.cost_id := l_actmet_rec.activity_metric_id;
      l_cost_rec.cost_amount := l_actmet_rec.trans_actual_value;
      l_cost_rec.cost_desc := '';
      l_cost_rec.cost_curr := l_actmet_rec.transaction_currency_code;
      l_cost_table(1) := l_cost_rec;
      OZF_Fund_Adjustment_Pvt.create_budget_amt_utilized(
         p_budget_used_by_id   => l_actmet_rec.act_metric_used_by_id,
         p_budget_used_by_type => l_actmet_rec.arc_act_metric_used_by,
         p_currency            => l_actmet_rec.transaction_currency_code,
         p_cost_tbl            => l_cost_table,
         p_api_version         => l_api_version,
         x_return_status       => l_return_status,
         x_msg_count           => x_msg_count,
         x_msg_data            => x_msg_data);
      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         -- BUG2486379: Display budget utilization errors.
         -- Fnd_Msg_Pub.Initialize;
         Fnd_Message.set_name('AMS', 'AMS_MET_NO_POST');
         Fnd_Msg_Pub.ADD;
         --IF (AMS_DEBUG_HIGH_ON) THEN
         --   Ams_Utility_Pvt.debug_message('You can not post this cost!');
         --END IF;
      END IF;
      IF l_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
         RAISE Fnd_Api.g_exc_unexpected_error;
      ELSIF l_return_status = Fnd_Api.g_ret_sts_error THEN
         RAISE Fnd_Api.g_exc_error;
      END IF;
   END IF;

   IF (AMS_DEBUG_HIGH_ON) THEN
     Ams_Utility_Pvt.debug_message(l_full_name ||': update Activity Metrics Table');
   END IF;

   -- Update AMS_ACT_METRICS_ALL
   UPDATE ams_act_metrics_all
      SET object_version_number= object_version_number + 1,
          act_metric_used_by_id    = l_actmet_rec.act_metric_used_by_id,
          arc_act_metric_used_by   = l_actmet_rec.arc_act_metric_used_by,
          purchase_req_raised_flag = l_actmet_rec.purchase_req_raised_flag,
          application_id           = l_actmet_rec.application_id,
          sensitive_data_flag      = l_actmet_rec.sensitive_data_flag,
          budget_id                = l_actmet_rec.budget_id ,
          metric_id                = l_actmet_rec.metric_id,
          transaction_currency_code= l_actmet_rec.transaction_currency_code,
          trans_forecasted_value   = l_actmet_rec.trans_forecasted_value,
          trans_committed_value    = l_actmet_rec.trans_committed_value,
          trans_actual_value       = l_actmet_rec.trans_actual_value,
          functional_currency_code = l_actmet_rec.functional_currency_code,
          func_forecasted_value    = l_actmet_rec.func_forecasted_value,
          func_committed_value     = l_actmet_rec.func_committed_value,
          func_actual_value        = l_actmet_rec.func_actual_value,
          dirty_flag               = l_actmet_rec.dirty_flag,
          last_calculated_date     = l_actmet_rec.last_calculated_date,
          variable_value           = l_actmet_rec.variable_value,
          forecasted_variable_value= l_actmet_rec.forecasted_variable_value,
          computed_using_function_value =
                     l_actmet_rec.computed_using_function_value,
          metric_uom_code          = l_actmet_rec.metric_uom_code,
          difference_since_last_calc = l_actmet_rec.difference_since_last_calc,
          activity_metric_origin_id= l_actmet_rec.activity_metric_origin_id,
          arc_activity_metric_origin = l_actmet_rec.arc_activity_metric_origin,
          hierarchy_id             = l_actmet_rec.hierarchy_id,
          start_node               = l_actmet_rec.start_node,
          from_level               = l_actmet_rec.from_level,
          to_level                 = l_actmet_rec.to_level,
          from_date                = l_actmet_rec.from_date,
          TO_DATE                  = l_actmet_rec.TO_DATE,
          amount1                  = l_actmet_rec.amount1,
          amount2                  = l_actmet_rec.amount2,
          amount3                  = l_actmet_rec.amount3,
          percent1                 = l_actmet_rec.percent1,
          percent2                 = l_actmet_rec.percent2,
          percent3                 = l_actmet_rec.percent3,
          published_flag           = l_actmet_rec.published_flag,
          pre_function_name        = l_actmet_rec.pre_function_name,
          post_function_name       = l_actmet_rec.post_function_name,
          last_update_date         = SYSDATE,
          last_updated_by          = Fnd_Global.User_ID,
          last_update_login        = Fnd_Global.Conc_Login_ID,
          attribute_category       = l_actmet_rec.attribute_category,
          attribute1               = l_actmet_rec.attribute1,
          attribute2               = l_actmet_rec.attribute2,
          attribute3               = l_actmet_rec.attribute3,
          attribute4               = l_actmet_rec.attribute4,
          attribute5               = l_actmet_rec.attribute5,
          attribute6               = l_actmet_rec.attribute6,
          attribute7               = l_actmet_rec.attribute7,
          attribute8               = l_actmet_rec.attribute8,
          attribute9               = l_actmet_rec.attribute9,
          attribute10              = l_actmet_rec.attribute10,
          attribute11              = l_actmet_rec.attribute11,
          attribute12              = l_actmet_rec.attribute12,
          attribute13              = l_actmet_rec.attribute13,
          attribute14              = l_actmet_rec.attribute14,
          attribute15              = l_actmet_rec.attribute15,
          description              = l_actmet_rec.description,
          act_metric_date          = l_actmet_rec.act_metric_date,
          depend_act_metric        = l_actmet_rec.depend_act_metric,
          function_used_by_id      = l_actmet_rec.function_used_by_id,
          arc_function_used_by     = l_actmet_rec.arc_function_used_by,
          /* 05/15/2002 yzhao: 11.5.9 add 6 new columns for top-down bottom-up budgeting */
          hierarchy_type           = l_actmet_rec.hierarchy_type,
          status_code              = l_actmet_rec.status_code,
          method_code              = l_actmet_rec.method_code,
          action_code              = l_actmet_rec.action_code,
          basis_year               = l_actmet_rec.basis_year,
          ex_start_node            = l_actmet_rec.ex_start_node
          /* 05/15/2002 yzhao: add ends */
      WHERE activity_metric_id = l_actmet_rec.activity_metric_id;

   IF  (SQL%NOTFOUND)
   THEN
      --
      -- Add error message to API message list.
      --
      IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.g_msg_lvl_error) THEN
         Fnd_Message.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
         Fnd_Msg_Pub.ADD;
      END IF;
      RAISE Fnd_Api.g_exc_error;
   END IF;

   -- huili@ added to invalidate the corresponding variable activity metrics
   OPEN c_check_var_met (l_actmet_rec.activity_metric_id);
   FETCH c_check_var_met INTO l_depend_act_metric;
   IF c_check_var_met%FOUND AND l_depend_act_metric IS NOT NULL THEN
      UPDATE ams_act_metrics_all
      SET dirty_flag = G_IS_DIRTY
      WHERE activity_metric_id = l_depend_act_metric;

      IF  (SQL%NOTFOUND) THEN
         --
         -- Add error message to API message list.
         --
         IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.g_msg_lvl_error) THEN
            Fnd_Message.set_name('AMS', 'AMS_API_VARREC_NOT_FOUND');
            Fnd_Msg_Pub.ADD;
         END IF;
         RAISE Fnd_Api.g_exc_error;
      END IF;
   END IF;
   CLOSE c_check_var_met;
   --END

   -- Record any change in the history table.
   Record_History(l_actmet_rec.activity_metric_id, G_UPDATE,
                 x_return_status, x_msg_count, x_msg_data);

  -- update all the parent object's rollup metrics or this object's
  -- summary metrics dirty_flag to 'Y' -- SVEERAVE, 10/13/00
  IF NVL(l_actmet_rec.dirty_flag,G_IS_DIRTY) = G_IS_DIRTY THEN
    Make_ActMetric_Dirty(l_actmet_rec.activity_metric_id);
  END IF;
   --
   -- End API Body
   --

   IF Fnd_Api.to_boolean(p_commit) THEN
      COMMIT;
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
   -- Debug message.
   --
   IF (AMS_DEBUG_HIGH_ON) THEN
      Ams_Utility_Pvt.debug_message(l_full_name ||': end');
   END IF;


EXCEPTION
   WHEN Fnd_Api.G_EXC_ERROR THEN
      ROLLBACK TO Update_ActMetric_pvt;
      x_return_status := Fnd_Api.G_RET_STS_ERROR;
      Fnd_Msg_Pub.Count_And_Get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data,
         p_encoded       =>     FND_API.G_FALSE
      );
   WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Update_ActMetric_pvt;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      Fnd_Msg_Pub.Count_And_Get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data,
         p_encoded       =>   FND_API.G_FALSE
      );
   WHEN OTHERS THEN
      ROLLBACK TO Update_ActMetric_pvt;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      IF Fnd_Msg_Pub.Check_Msg_Level (Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR) THEN
         Fnd_Msg_Pub.Add_Exc_Msg (G_PKG_NAME, L_API_NAME);
      END IF;
      Fnd_Msg_Pub.Count_And_Get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data,
         p_encoded       =>   FND_API.G_FALSE
      );
END Update_ActMetric;

-- Start of comments
-- NAME
--    Delete_ActMetric
--
-- PURPOSE
--    Deletes the association of a metric to a business
--    object by creating a record in AMS_ACT_METRICS_ALL.
--
-- NOTES
--
-- HISTORY
-- 05/26/1999   choang        Created.
-- 10/9/1999    ptendulk      Modified according to new standards
-- 08/24/2000   sveerave@us   Included call-out for check_freeze_status
--                            at beginning.
-- 12/18/2001   DMVINCEN      Removed seeded data restriction.
-- 04/04/2002   DMVINCEN      When rollup metrics are removed the
--                            subordinate records are nulled.
--
-- End of comments

PROCEDURE Delete_ActMetric (
   p_api_version              IN  NUMBER,
   p_init_msg_list            IN  VARCHAR2 := Fnd_Api.G_FALSE,
   p_commit                   IN  VARCHAR2 := Fnd_Api.G_FALSE,
   x_return_status            OUT NOCOPY VARCHAR2,
   x_msg_count                OUT NOCOPY NUMBER,
   x_msg_data                 OUT NOCOPY VARCHAR2,
   p_activity_metric_id       IN  NUMBER,
   p_object_version_number    IN  NUMBER
)
IS
   L_API_VERSION         CONSTANT NUMBER := 1.0;
   L_API_NAME            CONSTANT VARCHAR2(30) := 'DELETE_ACTMETRIC';
   L_FULL_NAME           CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

   l_return_status       VARCHAR2(1);
   l_freeze_status       VARCHAR2(1) := Fnd_Api.G_FALSE;
   l_act_metric_rec      act_metric_rec_type;
   l_child_activity_metric_id NUMBER;
   l_child_type          VARCHAR2(30);


   --sunkumar 05/30/2003 added for seting the token in error message AMS_METR_DELETE
   l_object_name AMS_LOOKUPS.MEANING%TYPE;
   -- DMVINCEN Added check for rollup children.
   -- DMVINCEN 04/04/2002: Retrieve the child ids and relation ships.
   CURSOR c_check_child_exists(l_act_metric_id NUMBER) IS
      SELECT activity_metric_id, 'SUMMARY'
      FROM ams_act_metrics_all
      WHERE summarize_to_metric = l_act_metric_id
      UNION ALL
      SELECT activity_metric_id, 'ROLLUP'
      FROM ams_act_metrics_all
      WHERE rollup_to_metric = l_act_metric_id;

   CURSOR c_actmet_details(l_act_metric_id NUMBER) IS
       SELECT  activity_metric_id,
                 last_update_date,
                 last_updated_by,
                 creation_date,
                 created_by,
                 last_update_login,
                 object_version_number,
                 act_metric_used_by_id,
                 arc_act_metric_used_by,
                 purchase_req_raised_flag,
                 application_id,
                 sensitive_data_flag,
                 budget_id,
                 metric_id,
                 transaction_currency_code,
                 trans_forecasted_value,
                 trans_committed_value,
                 trans_actual_value,
                 functional_currency_code,
                 func_forecasted_value,
                 dirty_flag,
                 func_committed_value,
                 func_actual_value,
                 last_calculated_date,
                 variable_value,
                 forecasted_variable_value,
                 computed_using_function_value,
                 metric_uom_code,
                 org_id,
                 difference_since_last_calc,
                 activity_metric_origin_id,
                 arc_activity_metric_origin,
                 days_since_last_refresh,
                 scenario_id,
                 SUMMARIZE_TO_METRIC,
                 ROLLUP_TO_METRIC,
                 hierarchy_id,
                 start_node,
                 from_level,
                 to_level,
                 from_date,
                 TO_DATE,
                 amount1,
                 amount2,
                 amount3,
                 percent1,
                 percent2,
                 percent3,
                 published_flag,
                 pre_function_name ,
                 post_function_name,
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
                 description,
                 act_metric_date,
                 depend_act_metric,
                 function_used_by_id,
                 arc_function_used_by,
                 /* 05/15/2002 yzhao: 11.5.9 add 6 new columns for top-down bottom-up budgeting */
                 hierarchy_type,
                 status_code,
                 method_code,
                 action_code,
                 basis_year,
                 ex_start_node
                 /* 05/15/2002 yzhao: add ends */
     FROM ams_act_metrics_all
     WHERE activity_metric_id = l_act_metric_id;

  -- huili@ added on 05/07/2001
  CURSOR c_depend_met_id (l_act_met_id NUMBER) IS
  SELECT depend_act_metric, object_version_number
  FROM ams_act_metrics_all
  WHERE activity_metric_id = l_act_met_id;

  l_depend_act_met_id NUMBER;
  l_depend_version_num NUMBER;

   l_dummy   NUMBER;

BEGIN
   --
   -- Initialize savepoint.
   --
   SAVEPOINT Delete_ActMetric_pvt;

   --
   -- Output debug message.
   --
   IF (AMS_DEBUG_HIGH_ON) THEN
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
   -- Check if record is seeded.
   --
   -- DMVINCEN: There is no reason for this restriction.
--    IF IsSeeded (p_activity_metric_id) THEN
--       IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.g_msg_lvl_error)
--       THEN
--          Fnd_Message.set_name('AMS', 'AMS_METR_SEEDED_METR');
--          Fnd_Msg_Pub.ADD;
--       END IF;
--
--       RAISE Fnd_Api.G_EXC_ERROR;
--    END IF;


   --
   -- Initialize API return status to success.
   --
   x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

   --
   -- Begin API Body.
   --
   -- Following part is added by sveerave on 11/15/00 for fix of bug 1500023
   --
   -- Check if childs exist. If exists then prevent deletion
   -- DMVINCEN 04/04/2002: Allow rollup metrics to be deleted by removing
   -- the reference from the child metric.
   --
   OPEN c_check_child_exists(p_activity_metric_id);
   LOOP
      FETCH c_check_child_exists
         INTO l_child_activity_metric_id, l_child_type;
      EXIT WHEN c_check_child_exists%NOTFOUND;
      EXIT WHEN l_child_type = 'SUMMARY';
      UPDATE ams_act_metrics_all
         SET rollup_to_metric = NULL
         WHERE activity_metric_id = l_child_activity_metric_id;
   END LOOP;
   CLOSE c_check_child_exists;

   IF l_child_type = 'SUMMARY' THEN
      IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.g_msg_lvl_error) THEN
         Fnd_Message.set_name('AMS', 'AMS_METR_CANT_DELETE_PARENT');
         Fnd_Msg_Pub.ADD;
      END IF;
      RAISE Fnd_Api.g_exc_error;
   END IF;
   -- end for the bug fix, sveerave.

   -- Get all the details of the activity metric record for passing to
        -- freeze validation.
   OPEN  c_actmet_details(p_activity_metric_id);
   FETCH c_actmet_details INTO l_act_metric_rec;
   IF (c_actmet_details%NOTFOUND) THEN
      IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.g_msg_lvl_error) THEN
         Fnd_Message.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
         Fnd_Msg_Pub.ADD;
      END IF;
      RAISE Fnd_Api.g_exc_error;
   END IF;

   CLOSE c_actmet_details;

   -- Make a call-out to check the frozen status.
        -- If it is frozen, disallow the operation.
   Check_Freeze_Status (l_act_metric_rec,
                        G_DELETE, -- Delete is operation mode
                        l_freeze_status,
                        l_return_status);

    IF (l_freeze_status = Fnd_Api.G_TRUE)  THEN
             -- frozen to create the record
      IF Fnd_Msg_Pub.Check_Msg_Level (Fnd_Msg_Pub.G_MSG_LVL_ERROR) THEN
       -- sunkumar 04/30/2003 added message for delete status of objects depending on status (ACTIVE, CANCELLED, COMPLETED)
    l_object_name := ams_utility_pvt.get_lookup_meaning(
             'AMS_SYS_ARC_QUALIFIER',l_act_metric_rec.arc_act_metric_used_by);
    Fnd_Message.Set_Name('AMS', 'AMS_METR_DELETE');
         Fnd_Message.set_token('OBJECT', l_object_name);
         Fnd_Msg_Pub.ADD;
      END IF;
      l_return_status := Fnd_Api.G_RET_STS_ERROR;
   END IF;


   IF l_return_status = Fnd_Api.G_RET_STS_ERROR THEN
      RAISE Fnd_Api.G_EXC_ERROR;
   ELSIF l_return_status = Fnd_Api.G_RET_STS_UNEXP_ERROR THEN
      RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
   END IF;



   IF (l_freeze_status = Fnd_Api.G_TRUE)  THEN
          -- frozen to create the record
      IF Fnd_Msg_Pub.Check_Msg_Level (Fnd_Msg_Pub.G_MSG_LVL_ERROR) THEN
         Fnd_Message.Set_Name('AMS', 'AMS_METR_FROZEN');
         Fnd_Msg_Pub.ADD;
      END IF;
      l_return_status := Fnd_Api.G_RET_STS_ERROR;
   END IF;

   -- If it is frozen, or any errors happen abort API.
   IF l_return_status = Fnd_Api.G_RET_STS_ERROR THEN
      RAISE Fnd_Api.G_EXC_ERROR;
   ELSIF l_return_status = Fnd_Api.G_RET_STS_UNEXP_ERROR THEN
      RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- If the actual value has been posted to the budget do not delete.
   IF l_act_metric_rec.published_flag = 'Y' THEN
      IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.g_msg_lvl_error) THEN
         Fnd_Message.SET_NAME('AMS', 'AMS_METR_PUBLISHED');
         Fnd_Msg_Pub.ADD;
      END IF;
      RAISE Fnd_Api.g_exc_error;
   END IF;

   -- Debug message.
   IF (AMS_DEBUG_HIGH_ON) THEN
      Ams_Utility_Pvt.debug_message(l_full_name ||': delete with Validation');
   END IF;

   -- huili added on 05/07/2001 to check dependent activity metrics
        l_depend_act_met_id := NULL;
        l_depend_version_num := NULL;
   OPEN c_depend_met_id (p_activity_metric_id);
   FETCH c_depend_met_id INTO l_depend_act_met_id, l_depend_version_num;
   CLOSE c_depend_met_id;

   -- Record any change in the history table.
   Record_History(p_activity_metric_id, G_DELETE,
                 x_return_status, x_msg_count, x_msg_data);

   DELETE FROM ams_act_metrics_all
    WHERE activity_metric_id = p_activity_metric_id
      AND object_version_number = p_object_version_number;

   IF SQL%NOTFOUND THEN
      IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.g_msg_lvl_error) THEN
         Fnd_Message.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
         Fnd_Msg_Pub.ADD;
      END IF;
      RAISE Fnd_Api.g_exc_error;
   END IF;

   -- DMVINCEN 04/30/2001 Parent metrics need to be re-evaluated
   Make_ActMetric_Dirty(l_act_metric_rec.rollup_to_metric);
   Make_ActMetric_Dirty(l_act_metric_rec.summarize_to_metric);

   IF l_depend_act_met_id IS NOT NULL THEN

      UPDATE ams_act_metrics_all
         SET depend_act_metric = NULL
         WHERE activity_metric_id = l_depend_act_met_id;

      Delete_ActMetric (
         p_api_version              => p_api_version,
         p_init_msg_list            => Fnd_Api.G_FALSE,
         p_commit                   => Fnd_Api.G_FALSE,
         x_return_status            => x_return_status,
         x_msg_count                => x_msg_count,
         x_msg_data                 => x_msg_data,
         p_activity_metric_id       => l_depend_act_met_id,
         p_object_version_number    => l_depend_version_num);

      IF x_return_status = Fnd_Api.G_RET_STS_ERROR THEN
         RAISE Fnd_Api.G_EXC_ERROR;
      ELSIF x_return_status = Fnd_Api.G_RET_STS_UNEXP_ERROR THEN
         RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
      END IF;
   END IF;

   -- end

   --
   -- End API Body.
   --

   IF Fnd_Api.To_Boolean (p_commit) THEN
      COMMIT WORK;
   END IF;

   --
   -- Debug message.
   --
   IF (AMS_DEBUG_HIGH_ON) THEN
      Ams_Utility_Pvt.debug_message(l_full_name ||': End');
   END IF;

   --
   -- Standard API to get message count, and if 1,
   -- set the message data OUT NOCOPY variable.
   --
   Fnd_Msg_Pub.Count_And_Get (
      p_count           =>    x_msg_count,
      p_data            =>    x_msg_data,
      p_encoded         =>    Fnd_Api.G_FALSE
   );

EXCEPTION
   WHEN Fnd_Api.G_EXC_ERROR THEN
      ROLLBACK TO Delete_ActMetric_pvt;
      x_return_status := Fnd_Api.G_RET_STS_ERROR;
      Fnd_Msg_Pub.Count_And_Get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data,
         p_encoded       =>   FND_API.G_FALSE
      );
   WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Delete_ActMetric_pvt;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      Fnd_Msg_Pub.Count_And_Get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data,
         p_encoded       =>   FND_API.G_FALSE
      );
   WHEN OTHERS THEN
      ROLLBACK TO Delete_ActMetric_pvt;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      IF Fnd_Msg_Pub.Check_Msg_Level (Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR) THEN
         Fnd_Msg_Pub.Add_Exc_Msg (G_PKG_NAME, L_API_NAME);
      END IF;
      Fnd_Msg_Pub.Count_And_Get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data,
         p_encoded       =>   FND_API.G_FALSE
      );
END Delete_ActMetric;

-- Start of comments
-- NAME
--    Delete_ActMetric
--
-- PURPOSE
--    Recursively delete metrics associated to a business object.
--    If the activity metric id and object version number are null,
--    then all metrics associated with that object are removed.
--    If the activity metric id and object version number are not null,
--    then that activity metric and all subordinate metrics are removed.
--    Only activity metrics at the given object level are removed.
--    The preceding Delete_ActMetric is called for the actual delete.
--
-- NOTES
--
-- HISTORY
-- 04/02/2002   DMVINCEN      Created
--
-- End of comments

PROCEDURE Delete_ActMetric (
   p_api_version              IN  NUMBER,
   p_init_msg_list            IN  VARCHAR2 := Fnd_Api.G_FALSE,
   p_commit                   IN  VARCHAR2 := Fnd_Api.G_FALSE,

   x_return_status            OUT NOCOPY VARCHAR2,
   x_msg_count                OUT NOCOPY NUMBER,
   x_msg_data                 OUT NOCOPY VARCHAR2,

   p_arc_act_metric_used_by   IN  VARCHAR2,
   p_act_metric_used_by_id    IN  NUMBER,
   p_activity_metric_id       IN  NUMBER := NULL,
   p_object_version_number    IN  NUMBER := NULL
)
IS
   L_API_VERSION         CONSTANT NUMBER := 1.0;
   L_API_NAME            CONSTANT VARCHAR2(30) := 'DELETE_ACTMETRIC';
   L_FULL_NAME           CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

   l_return_status       VARCHAR2(1);
   l_activity_metric_id  NUMBER;
   l_object_version_number  NUMBER;
   l_activity_metric_ids number_table;
   l_object_version_numbers number_table;

   CURSOR c_get_top_level_act_metrics(l_arc_act_metric_used_by VARCHAR2,
         l_act_metric_used_by_id NUMBER)
     IS
     SELECT activity_metric_id, object_version_number
     FROM ams_act_metrics_all
     WHERE summarize_to_metric is NULL
     AND arc_act_metric_used_by = l_arc_act_metric_used_by
     AND act_metric_used_by_id = l_act_metric_used_by_id;

   CURSOR c_get_next_level_act_metrics(l_arc_act_metric_used_by VARCHAR2,
         l_act_metric_used_by_id NUMBER,
         l_activity_metric_id NUMBER)
     IS
     SELECT activity_metric_id, object_version_number
     FROM ams_act_metrics_all
     WHERE summarize_to_metric = l_activity_metric_id
     AND arc_act_metric_used_by = l_arc_act_metric_used_by
     AND act_metric_used_by_id = l_act_metric_used_by_id;

BEGIN
   --
   -- Initialize savepoint.
   --
--   SAVEPOINT Delete_ActMetric_By_Object_pvt;

   --
   -- Output debug message.
   --
   IF (AMS_DEBUG_HIGH_ON) THEN
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

   IF p_activity_metric_id IS NULL AND
      p_object_version_number IS NULL THEN

      -- Find all activity metrics from the top down.
      OPEN c_get_top_level_act_metrics(
          p_arc_act_metric_used_by,
          p_act_metric_used_by_id);
      FETCH c_get_top_level_act_metrics
         BULK COLLECT INTO l_activity_metric_ids, l_object_version_numbers;
      CLOSE c_get_top_level_act_metrics;

      IF l_activity_metric_ids.COUNT > 0 THEN
         FOR l_index IN l_activity_metric_ids.FIRST..l_activity_metric_ids.LAST
         LOOP
            -- Recursively delete the next level down.
            Delete_actmetric(
               p_api_version => p_api_version,
               p_init_msg_list   => Fnd_Api.G_FALSE,
               p_commit          => Fnd_Api.G_FALSE,
               x_return_status => l_return_status,
               x_msg_count => x_msg_count,
               x_msg_data => x_msg_data,
               p_arc_act_metric_used_by => p_arc_act_metric_used_by,
               p_act_metric_used_by_id => p_act_metric_used_by_id,
               p_activity_metric_id => l_activity_metric_ids(l_index),
               p_object_version_number => l_object_version_numbers(l_index));

            IF l_return_status = Fnd_Api.G_RET_STS_ERROR THEN
               RAISE Fnd_Api.G_EXC_ERROR;
            ELSIF l_return_status = Fnd_Api.G_RET_STS_UNEXP_ERROR THEN
               RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
            END IF;

         END LOOP;
      END IF;

   ELSIF p_object_version_number IS NOT NULL AND
         p_activity_metric_id IS NOT NULL THEN

      -- Find all the activity metrics below the current.
      OPEN c_get_next_level_act_metrics(p_arc_act_metric_used_by,
         p_act_metric_used_by_id, p_activity_metric_id);
      FETCH c_get_next_level_act_metrics
         BULK COLLECT INTO l_activity_metric_ids, l_object_version_numbers;
      CLOSE c_get_next_level_act_metrics;

      IF l_activity_metric_ids.COUNT > 0 THEN
         FOR l_index IN l_activity_metric_ids.FIRST..l_activity_metric_ids.LAST
         LOOP

            -- Recursively delete the next level down.
            Delete_actmetric(
               p_api_version => p_api_version,
               p_init_msg_list   => Fnd_Api.G_FALSE,
               p_commit          => Fnd_Api.G_FALSE,
               x_return_status => l_return_status,
               x_msg_count => x_msg_count,
               x_msg_data => x_msg_data,
               p_arc_act_metric_used_by => p_arc_act_metric_used_by,
               p_act_metric_used_by_id => p_act_metric_used_by_id,
               p_activity_metric_id => l_activity_metric_ids(l_index),
               p_object_version_number => l_object_version_numbers(l_index));

            IF l_return_status = Fnd_Api.G_RET_STS_ERROR THEN
               RAISE Fnd_Api.G_EXC_ERROR;
            ELSIF l_return_status = Fnd_Api.G_RET_STS_UNEXP_ERROR THEN
               RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
            END IF;

         END LOOP;
      END IF;

      -- Delete the top activity metric passed in.
      Delete_actmetric(
         p_api_version => p_api_version,
         p_init_msg_list   => Fnd_Api.G_FALSE,
         p_commit          => Fnd_Api.G_FALSE,
         x_return_status => l_return_status,
         x_msg_count => x_msg_count,
         x_msg_data => x_msg_data,
         p_activity_metric_id => p_activity_metric_id,
         p_object_version_number => p_object_version_number);

      IF l_return_status = Fnd_Api.G_RET_STS_ERROR THEN
         RAISE Fnd_Api.G_EXC_ERROR;
      ELSIF l_return_status = Fnd_Api.G_RET_STS_UNEXP_ERROR THEN
         RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
      END IF;

   END IF;

   --
   -- End API Body.
   --

   IF Fnd_Api.To_Boolean (p_commit) THEN
      COMMIT WORK;
   END IF;

   --
   -- Debug message.
   --
   IF (AMS_DEBUG_HIGH_ON) THEN
      Ams_Utility_Pvt.debug_message(l_full_name ||': End');
   END IF;

   --
   -- Standard API to get message count, and if 1,
   -- set the message data OUT NOCOPY variable.
   --
   Fnd_Msg_Pub.Count_And_Get (
      p_count           =>    x_msg_count,
      p_data            =>    x_msg_data,
      p_encoded         =>    Fnd_Api.G_FALSE
   );

EXCEPTION
   WHEN Fnd_Api.G_EXC_ERROR THEN
--      ROLLBACK TO Delete_ActMetric_By_Object_pvt;
      x_return_status := Fnd_Api.G_RET_STS_ERROR;
      Fnd_Msg_Pub.Count_And_Get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data,
         p_encoded       =>   FND_API.G_FALSE
      );
   WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
--      ROLLBACK TO Delete_ActMetric_By_Object_pvt;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      Fnd_Msg_Pub.Count_And_Get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data,
         p_encoded       =>   FND_API.G_FALSE
      );
   WHEN OTHERS THEN
--      ROLLBACK TO Delete_ActMetric_By_Object_pvt;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      IF Fnd_Msg_Pub.Check_Msg_Level (Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR) THEN
         Fnd_Msg_Pub.Add_Exc_Msg (G_PKG_NAME, L_API_NAME);
      END IF;
      Fnd_Msg_Pub.Count_And_Get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data,
         p_encoded       =>   FND_API.G_FALSE
      );
END Delete_ActMetric;


-- Start of comments
-- NAME
--    Lock_ActMetric
--
-- PURPOSE
--    Lock the given row in AMS_ACT_METRICS_ALL.
--
-- NOTES
--
-- HISTORY
-- 05/26/1999   choang         Created.
-- 10/9/1999    ptendulk       Modified according to new standards
--
-- End of comments

PROCEDURE Lock_ActMetric (
   p_api_version           IN  NUMBER,
   p_init_msg_list         IN  VARCHAR2 := Fnd_Api.G_FALSE,

   x_return_status         OUT NOCOPY VARCHAR2,
   x_msg_count             OUT NOCOPY NUMBER,
   x_msg_data              OUT NOCOPY VARCHAR2,

   p_activity_metric_id    IN  NUMBER,
   p_object_version_number IN  NUMBER
)
IS
   L_API_VERSION      CONSTANT NUMBER := 1.0;
   L_API_NAME         CONSTANT VARCHAR2(30) := 'LOCK_ACTMETRIC';
   L_FULL_NAME        CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

   l_activity_metric_id    NUMBER;
   l_metrics_name          VARCHAR2(240);

   CURSOR c_act_metrics_info IS
      SELECT activity_metric_id
      FROM ams_act_metrics_all
      WHERE activity_metric_id = p_activity_metric_id
      AND object_version_number = p_object_version_number
      FOR UPDATE OF activity_metric_id NOWAIT;

   CURSOR c_metric_info(p_act_metric_id NUMBER) IS
      SELECT metrics_name
      FROM ams_metrics_vl m, ams_act_metrics_all a
      WHERE m.metric_id = a.metric_id
      AND activity_metric_id = p_act_metric_id;
BEGIN
   --
   -- Output debug message.
   --
   IF (AMS_DEBUG_HIGH_ON) THEN
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
   -- Begin API Body
   --
   IF (AMS_DEBUG_HIGH_ON) THEN
      Ams_Utility_Pvt.debug_message(l_full_name||': lock');
   END IF;


   OPEN c_act_metrics_info;
   FETCH c_act_metrics_info INTO l_activity_metric_id;
   IF  (c_act_metrics_info%NOTFOUND)
   THEN
      CLOSE c_act_metrics_info;
          -- Error, check the msg level and added an error message to the
          -- API message list
      IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.g_msg_lvl_error) THEN
         l_metrics_name := null;
         OPEN c_metric_info(p_activity_metric_id);
         FETCH c_metric_info INTO l_metrics_name;
         CLOSE c_metric_info;
         IF l_metrics_name is not null THEN
            Fnd_Message.set_name('AMS', 'AMS_METR_RECORD_NOT_FOUND');
            Fnd_Message.set_token('METRIC', l_metrics_name);
            Fnd_Msg_Pub.ADD;
         ELSE
            Fnd_Message.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
            Fnd_Msg_Pub.ADD;
         END IF;
      END IF;
      RAISE Fnd_Api.g_exc_error;
   END IF;
   CLOSE c_act_metrics_info;


   --
   -- Standard API to get message count, and if 1,
   -- set the message data OUT NOCOPY variable.
   --
   Fnd_Msg_Pub.Count_And_Get (
      p_count           =>    x_msg_count,
      p_data            =>    x_msg_data,
      p_encoded         =>    Fnd_Api.G_FALSE
   );

   --
   -- Debug message.
   --
   IF (AMS_DEBUG_HIGH_ON) THEN
      Ams_Utility_Pvt.debug_message(l_full_name ||': end');
   END IF;


EXCEPTION
   WHEN Fnd_Api.G_EXC_ERROR THEN
      x_return_status := Fnd_Api.G_RET_STS_ERROR;
      Fnd_Msg_Pub.Count_And_Get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data,
         p_encoded       =>   FND_API.G_FALSE
      );
   WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      Fnd_Msg_Pub.Count_And_Get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data,
         p_encoded       =>   FND_API.G_FALSE
      );
   WHEN Ams_Utility_Pvt.RESOURCE_LOCKED THEN
      x_return_status := Fnd_Api.G_RET_STS_ERROR ;

          IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.g_msg_lvl_error) THEN
                   Fnd_Message.set_name('AMS', 'AMS_API_RESOURCE_LOCKED');
                   Fnd_Msg_Pub.ADD;
          END IF;

      Fnd_Msg_Pub.Count_And_Get (
         p_count         =>      x_msg_count,
         p_data          =>      x_msg_data,
         p_encoded      =>      Fnd_Api.G_FALSE
      );
   WHEN OTHERS THEN
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      IF Fnd_Msg_Pub.Check_Msg_Level (Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR) THEN
         Fnd_Msg_Pub.Add_Exc_Msg (G_PKG_NAME, L_API_NAME);
      END IF;
      Fnd_Msg_Pub.Count_And_Get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data,
         p_encoded          =>      Fnd_Api.G_FALSE
                       );
END Lock_ActMetric;

-- Start of comments
-- NAME
--    Validate_ActMetric
--
-- PURPOSE
--   Validation API for Activity metrics.
--

-- NOTES
--
-- HISTORY
-- 05/26/1999   choang         Created.
-- 10/9/1999    ptendulk           Modified according to new standards
--
-- End of comments

PROCEDURE Validate_ActMetric (
   p_api_version                IN  NUMBER,
   p_init_msg_list              IN  VARCHAR2 := Fnd_Api.G_FALSE,
   p_validation_level           IN  NUMBER   := Fnd_Api.G_Valid_Level_Full,

   x_return_status              OUT NOCOPY VARCHAR2,
   x_msg_count                  OUT NOCOPY NUMBER,
   x_msg_data                   OUT NOCOPY VARCHAR2,

   p_act_metric_rec            IN  act_metric_rec_type
)
IS
   L_API_VERSION    CONSTANT NUMBER := 1.0;
   L_API_NAME       CONSTANT VARCHAR2(30) := 'VALIDATE_ACTMETRIC';
   L_FULL_NAME      CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

   l_return_status  VARCHAR2(1);

BEGIN
   --
   -- Output debug message.
   --
   IF (AMS_DEBUG_HIGH_ON) THEN
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

   IF (AMS_DEBUG_HIGH_ON) THEN
      Ams_Utility_Pvt.debug_message(l_full_name||': Validate items');
   END IF;

   -- Validate required items in the record.
   IF p_validation_level >= Jtf_Plsql_Api.g_valid_level_item THEN

       Validate_ActMetric_items(
         p_act_metric_rec      => p_act_metric_rec,
         p_validation_mode         => Jtf_Plsql_Api.g_create,
         x_return_status           => l_return_status
      );

      -- If any errors happen abort API.
      IF l_return_status = Fnd_Api.G_RET_STS_UNEXP_ERROR THEN
         RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
      ELSIF l_return_status = Fnd_Api.G_RET_STS_ERROR THEN
         RAISE Fnd_Api.G_EXC_ERROR;
      END IF;
   END IF;

   IF (AMS_DEBUG_HIGH_ON) THEN
      Ams_Utility_Pvt.debug_message(l_full_name||': check record');
   END IF;

   IF p_validation_level >= Jtf_Plsql_Api.g_valid_level_record THEN
      Validate_ActMetric_record(
         p_act_metric_rec       => p_act_metric_rec,
         p_complete_rec         => NULL,
         x_return_status        => l_return_status
      );

      IF l_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
         RAISE Fnd_Api.g_exc_unexpected_error;
      ELSIF l_return_status = Fnd_Api.g_ret_sts_error THEN
         RAISE Fnd_Api.g_exc_error;
      END IF;
   END IF;

   --
   -- End API Body.
   --

   --
   -- Standard API to get message count, and if 1,
   -- set the message data OUT NOCOPY variable.
   --
   Fnd_Msg_Pub.Count_And_Get (
      p_count           =>    x_msg_count,
      p_data            =>    x_msg_data,
      p_encoded         =>    Fnd_Api.G_FALSE
   );

   IF (AMS_DEBUG_HIGH_ON) THEN
      Ams_Utility_Pvt.debug_message(l_full_name ||': end');
   END IF;

EXCEPTION
   WHEN Fnd_Api.G_EXC_ERROR THEN
      x_return_status := Fnd_Api.G_RET_STS_ERROR;
      Fnd_Msg_Pub.Count_And_Get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data,
         p_encoded       =>   FND_API.G_FALSE
      );
   WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      Fnd_Msg_Pub.Count_And_Get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data,
         p_encoded       =>   FND_API.G_FALSE
      );
   WHEN OTHERS THEN
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      IF Fnd_Msg_Pub.Check_Msg_Level (Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR) THEN
         Fnd_Msg_Pub.Add_Exc_Msg (G_PKG_NAME, L_API_NAME);
      END IF;
      Fnd_Msg_Pub.Count_And_Get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data,
         p_encoded       =>   FND_API.G_FALSE
      );
END Validate_ActMetric;


-- Start of comments.
--
-- NAME
--    Check_Req_ActMetrics_Items
--
-- PURPOSE
--    Validate required items metrics associated with business
--    objects.
--
-- NOTES
--
-- HISTORY
-- 05/26/1999     choang    Created.
-- 10/9/1999      ptendulk  Modified According to new standards.
--
-- End of comments.

PROCEDURE Check_Req_ActMetrics_Items (
   p_act_metric_rec                   IN act_metric_rec_type,
   x_return_status                     OUT NOCOPY VARCHAR2
)
IS
BEGIN
   -- Initialize return status to success.
   x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

   -- APPLICATION_ID

   IF p_act_metric_rec.application_id IS NULL
   THEN
          -- missing required fields
      IF Fnd_Msg_Pub.Check_Msg_Level (Fnd_Msg_Pub.G_MSG_LVL_ERROR)
      THEN -- MMSG
         Fnd_Message.Set_Name('AMS', 'AMS_METR_MISSING_APP_ID');
         Fnd_Msg_Pub.ADD;
      END IF;

      x_return_status := Fnd_Api.G_RET_STS_ERROR;

      -- If any error happens abort API.
      RETURN;
   END IF;

   -- ARC_METRIC_USED_FOR_OBJECT

   IF  p_act_metric_rec.arc_act_metric_used_by IS NULL
   THEN
      -- missing required fields
      IF Fnd_Msg_Pub.Check_Msg_Level (Fnd_Msg_Pub.G_MSG_LVL_ERROR)
      THEN -- MMSG
         Fnd_Message.Set_Name('AMS', 'AMS_METR_MISSING_ARC_USED_FOR');
         Fnd_Msg_Pub.ADD;
      END IF;

      x_return_status := Fnd_Api.G_RET_STS_ERROR;

      -- If any error happens abort API.
      RETURN;
   END IF;


   -- ACT_METRIC_USED_BY_ID

   IF p_act_metric_rec.act_metric_used_by_id IS NULL
   THEN
      -- missing required fields
      IF Fnd_Msg_Pub.Check_Msg_Level (Fnd_Msg_Pub.G_MSG_LVL_ERROR)
      THEN -- MMSG
         Fnd_Message.Set_Name('AMS', 'AMS_METR_MISSING_ARC_USED_FOR');
         Fnd_Msg_Pub.ADD;
      END IF;

      x_return_status := Fnd_Api.G_RET_STS_ERROR;

      -- If any error happens abort API.
      RETURN;
   END IF;

   -- METRIC_ID

   IF p_act_metric_rec.metric_id IS NULL
   THEN
      -- missing required fields
      IF Fnd_Msg_Pub.Check_Msg_Level (Fnd_Msg_Pub.G_MSG_LVL_ERROR)
      THEN -- MMSG
         Fnd_Message.Set_Name('AMS', 'AMS_METR_MISSING_METRIC_ID');
         Fnd_Msg_Pub.ADD;
      END IF;

      x_return_status := Fnd_Api.G_RET_STS_ERROR;

      -- If any error happens abort API.
      RETURN;
   END IF;

   /*----------------------------------------------------------------
   -- commented by bgeorge om 01/18/2000, removed UOM as a req item
   -- METRIC_UOM_CODE

   IF p_act_metric_rec.metric_uom_code IS NULL
   THEN
      -- missing required fields
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
      THEN -- MMSG
         FND_MESSAGE.Set_Name('AMS', 'AMS_METR_MISSING_UOM');
         FND_MSG_PUB.Add;
      END IF;

      x_return_status := FND_API.G_RET_STS_ERROR;

      -- If any error happens abort API.
      RETURN;
   END IF;
   -- end of comment  01/18/2000
   ---------------------------------------------------------------*/


   -- Sensitive Data flag

   IF p_act_metric_rec.sensitive_data_flag IS NULL
   THEN
      -- missing required fields
      IF Fnd_Msg_Pub.Check_Msg_Level (Fnd_Msg_Pub.G_MSG_LVL_ERROR)
      THEN -- MMSG
         Fnd_Message.Set_Name('AMS', 'AMS_METR_MISSING_SENSITIVE');
         Fnd_Msg_Pub.ADD;
      END IF;

      x_return_status := Fnd_Api.G_RET_STS_ERROR;

      -- If any error happens abort API.
      RETURN;
   END IF;


EXCEPTION
   WHEN OTHERS THEN
      RAISE;
END Check_Req_ActMetrics_Items;


--
-- Start of comments.
--
-- NAME
--    Check_ActMetric_UK_Items
--
-- PURPOSE
--    Perform Uniqueness check for Activity metrics.
--
-- NOTES
--
-- HISTORY
-- 10/9/1999      ptendulk                      Created.
-- 11/22/2004     dmvincen  BUG4026377: Prevent duplicate function assignment.
--
-- End of comments.


PROCEDURE Check_ActMetric_UK_Items(
   p_act_metric_rec      IN  act_metric_rec_type,
   p_validation_mode     IN  VARCHAR2 := Jtf_Plsql_Api.g_create,
   x_return_status       OUT NOCOPY VARCHAR2
)
IS
   l_where_clause VARCHAR2(2000); -- Used By Check_Uniqueness
   l_test VARCHAR2(1) := NULL;
   CURSOR c_check_function(l_metric_id NUMBER,
         l_arc_act_metric_used_by VARCHAR2,
         l_act_metric_used_by_id NUMBER,
         l_arc_function_used_by VARCHAR2,
         l_function_used_by_id NUMBER) IS
      SELECT 'x'
      FROM ams_metrics_all_b b
      WHERE metric_id = l_metric_id
      AND ((metric_calculation_type = 'FUNCTION'
      AND NOT EXISTS (SELECT 'x' FROM ams_act_metrics_all a
          WHERE a.metric_id = b.metric_id
          AND a.arc_act_metric_used_by = l_arc_act_metric_used_by
          AND a.act_metric_used_by_id = l_act_metric_used_by_id
          AND NVL(a.arc_function_used_by,'IS NULL') =
              NVL(l_arc_function_used_by,'IS NULL')
          AND NVL(a.function_used_by_id,-1) = NVL(l_function_used_by_id,-1)
          ))
      OR metric_calculation_type <> 'FUNCTION');

BEGIN

   x_return_status := Fnd_Api.g_ret_sts_success;

   -- For Create_ActMetric2, when activity_metric_id is passed in, we need to
   -- check if this activity_metric_id is unique.
   IF p_validation_mode = Jtf_Plsql_Api.g_create
      AND p_act_metric_rec.activity_metric_id IS NOT NULL
   THEN
          l_where_clause := ' activity_metric_id = '||p_act_metric_rec.activity_metric_id ;

      IF Ams_Utility_Pvt.Check_Uniqueness(
                        p_table_name      => 'ams_act_metrics_all',
                        p_where_clause    => l_where_clause
                        ) = Fnd_Api.g_false
                THEN
         IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.g_msg_lvl_error)
                        THEN
            Fnd_Message.set_name('AMS', 'AMS_METR_ACT_DUP_ID');
            Fnd_Msg_Pub.ADD;
         END IF;
         x_return_status := Fnd_Api.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

   -- check other unique items

   -- Function metrics may only be added once.
   IF p_validation_mode = Jtf_Plsql_Api.g_create THEN
      l_test := NULL;
      OPEN c_check_function(p_act_metric_rec.metric_id,
         p_act_metric_rec.arc_act_metric_used_by,
         p_act_metric_rec.act_metric_used_by_id,
         p_act_metric_rec.arc_function_used_by,
         p_act_metric_rec.function_used_by_id);
      FETCH c_check_function INTO l_test;
      CLOSE c_check_function;

      IF l_test IS NULL THEN
         IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.g_msg_lvl_error) THEN
            Fnd_Message.set_name('AMS', 'AMS_ACT_MET_DUP_FUNCTION');
            Fnd_Msg_Pub.ADD;
         END IF;
         x_return_status := Fnd_Api.g_ret_sts_error;
      END IF;

   END IF;

END Check_ActMetric_Uk_Items;


--
-- Start of comments.
--
-- NAME
--    Check_ActMetric_Items
--
-- PURPOSE
--    Perform item level validation for Activity metrics.
--
-- NOTES
--
-- HISTORY
-- 05/26/1999     choang   Created.
-- 10/9/1999      ptendulk Modified According to new Standards
-- 05/08/2000     tdonohoe Modified, do not perform Metric_Id Check if the Activity Metric
--                         is associated with a Forecast.
-- 06-28-2000     rchahal@us     Modified to allow metric creation for Fund.
-- 30-oct-2003    choang   enh 3141834: changed validation for arc_metric_used_for_object
--                         and metric_origin.
--
-- End of comments.

PROCEDURE Check_ActMetric_Items (
   p_act_metric_rec        IN  act_metric_rec_type,
   x_return_status         OUT NOCOPY VARCHAR2
)
IS
   l_item_name             VARCHAR2(30);  -- Used to standardize error messages.
   l_act_metrics_rec       act_metric_rec_type := p_act_metric_rec;
   l_return_status         VARCHAR2(1);

   l_table_name            VARCHAR2(30);
   l_pk_name               VARCHAR2(30);
   l_pk_value              VARCHAR2(30);
   l_pk_data_type          VARCHAR2(30);
   l_additional_where_clause VARCHAR2(4000);  -- Used by Check_FK_Exists.
   l_lookup_type           VARCHAR2(30);

   CURSOR c_arc_metric_usage (p_object_type IN VARCHAR2) IS
      SELECT 1
      FROM   ams_lookups
      WHERE  lookup_type IN ('AMS_METRIC_OBJECT_TYPE', 'AMS_METRIC_ROLLUP_TYPE', 'AMS_METRIC_ALLOCATION_TYPE')
      AND    lookup_code = p_object_type
      ;
   l_dummy                 NUMBER;


  /*sunkumar april-20-2004*/
  CURSOR c_check_metric_id(p_metric_id number) IS
    SELECT 1 from ams_metrics_all_b
    WHERE METRIC_ID = p_metric_id;

  CURSOR c_check_currency(p_CURRENCY_CODE varchar2, p_enabled_flag varchar2)  IS
   SELECT 1 from FND_CURRENCIES
   WHERE CURRENCY_CODE = p_CURRENCY_CODE
   and enabled_flag = p_enabled_flag;

BEGIN
   -- Initialize return status to success.
   x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

   --
   -- Begin Validate Referential
   --

   -- METRIC_ID
   -- Do not validate FK if NULL
   -- Do not validate if Activity Metric is associated with a Forecast.


   OPEN c_check_metric_id(l_act_metrics_rec.metric_id);
    IF c_check_metric_id%NOTFOUND
    THEN
            IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
            THEN
               FND_MESSAGE.Set_Name('AMS', 'AMS_METR_INVALID_MET');
               FND_MSG_PUB.ADD;
            END IF;

            x_return_status := FND_API.G_RET_STS_ERROR;
            CLOSE c_check_metric_id;
            RETURN;
        END IF;
   CLOSE c_check_metric_id;

   -- TRANSACTION_CURRENCY_CODE
   -- Do not validate FK if NULL
   IF l_act_metrics_rec.transaction_currency_code <> Fnd_Api.G_MISS_CHAR THEN

      OPEN c_check_currency(l_act_metrics_rec.transaction_currency_code,'Y');
      IF c_check_currency%NOTFOUND
      THEN
            IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
            THEN
               FND_MESSAGE.Set_Name('AMS', 'AMS_METR_INVALID_TRANS_CUR');
               FND_MSG_PUB.ADD;
            END IF;

            x_return_status := FND_API.G_RET_STS_ERROR;
            CLOSE c_check_currency;
            RETURN;
      END IF;
      CLOSE c_check_currency;

   END IF;


      -- FUNCTIONAL_CURRENCY_CODE
   -- Do not validate FK if NULL
   IF l_act_metrics_rec.functional_currency_code <> Fnd_Api.G_MISS_CHAR THEN

      OPEN c_check_currency(l_act_metrics_rec.functional_currency_code,'Y');
    IF c_check_currency%NOTFOUND
    THEN
            IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
            THEN
               FND_MESSAGE.Set_Name('AMS', 'AMS_METR_INVALID_FUNC_CUR');
               FND_MSG_PUB.ADD;
            END IF;

            x_return_status := FND_API.G_RET_STS_ERROR;
            RETURN;
        END IF;
   CLOSE c_check_currency;

     END IF;


      /*
      l_table_name               := 'FND_CURRENCIES';
      l_pk_name                  := 'CURRENCY_CODE';
      l_pk_value                 := l_act_metrics_rec.transaction_currency_code;
      l_pk_data_type             := Ams_Utility_Pvt.G_VARCHAR2;
      l_additional_where_clause  := ' enabled_flag = ''Y''';
      IF Ams_Utility_Pvt.Check_FK_Exists (
             p_table_name                       => l_table_name
            ,p_pk_name                      => l_pk_name
            ,p_pk_value                     => l_pk_value
            ,p_pk_data_type                 => l_pk_data_type
            ,p_additional_where_clause  => l_additional_where_clause
         ) = Fnd_Api.G_FALSE
      THEN
         IF Fnd_Msg_Pub.Check_Msg_Level (Fnd_Msg_Pub.G_MSG_LVL_ERROR)
         THEN
                 Fnd_Message.Set_Name('AMS', 'AMS_METR_INVALID_TRANS_CUR');
                 Fnd_Msg_Pub.ADD;
                 END IF;

                 x_return_status := Fnd_Api.G_RET_STS_ERROR;
              RETURN;
      END IF;  -- Check_FK_Exists*/



      /*l_table_name               := 'FND_CURRENCIES';
      l_pk_name                  := 'CURRENCY_CODE';
      l_pk_value                 := l_act_metrics_rec.functional_currency_code;
      l_pk_data_type             := Ams_Utility_Pvt.G_VARCHAR2;
      l_additional_where_clause  := ' enabled_flag = ''Y''';

      IF Ams_Utility_Pvt.Check_FK_Exists (
             p_table_name                       => l_table_name
            ,p_pk_name                      => l_pk_name
            ,p_pk_value                     => l_pk_value
            ,p_pk_data_type                 => l_pk_data_type
            ,p_additional_where_clause  => l_additional_where_clause
         ) = Fnd_Api.G_FALSE
      THEN
         IF Fnd_Msg_Pub.Check_Msg_Level (Fnd_Msg_Pub.G_MSG_LVL_ERROR)
         THEN
            Fnd_Message.Set_Name('AMS', 'AMS_METR_INVALID_FUNC_CUR');
            Fnd_Msg_Pub.ADD;
         END IF;

         x_return_status := Fnd_Api.G_RET_STS_ERROR;
         RETURN;
      END IF;  -- Check_FK_Exists*/



   --
   -- End Validate Referential
   --

   --
   -- Begin Validate Flags
   --

      -- SENSITIVE_DATA_FLAG
   IF l_act_metrics_rec.sensitive_data_flag <> Fnd_Api.G_MISS_CHAR THEN
      IF Ams_Utility_Pvt.Is_Y_Or_N (l_act_metrics_rec.sensitive_data_flag)
                                                          = Fnd_Api.G_FALSE
      THEN
         IF Fnd_Msg_Pub.Check_Msg_Level (Fnd_Msg_Pub.G_MSG_LVL_ERROR)
         THEN
            Fnd_Message.Set_Name('AMS', 'AMS_METR_INVALID_SENS_FLAG');
            Fnd_Msg_Pub.ADD;
         END IF;

         x_return_status := Fnd_Api.G_RET_STS_ERROR;
         RETURN;
      END IF; -- Is_Y_Or_N
   END IF;

   --
   -- End Validate Flags
   --

   --
   -- Begin Validate LOOKUPS
   --
   -- choang - 30-oct-2003 - enh 3141834: use lookup AMS_METRIC_OBJECT_TYPE,
   --                        AMS_METRIC_ALLOCATION_TYPE, AMS_METRIC_ROLLUP_TYPE
   -- ARC_METRIC_USED_FOR_OBJECT
   IF l_act_metrics_rec.arc_act_metric_used_by <> FND_API.g_miss_char THEN
      l_dummy := NULL;
      OPEN c_arc_metric_usage(l_act_metrics_rec.arc_act_metric_used_by);
      FETCH c_arc_metric_usage INTO l_dummy;
      CLOSE c_arc_metric_usage;
      IF l_dummy IS NULL THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            Fnd_Message.Set_Name ('AMS', 'AMS_METR_INVALID_USED_BY');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
      END IF;
   END IF;

   -- ARC_ACTIVITY_METRIC_ORIGIN
   -- DMVINCEN 03/11/2002: Added Dialog Components.
   -- DMVINCEN 03/11/2003: Removed Dialogue Components.
   IF l_act_metrics_rec.arc_activity_metric_origin <> Fnd_Api.G_MISS_CHAR THEN
      l_dummy := NULL;
      OPEN c_arc_metric_usage(l_act_metrics_rec.arc_activity_metric_origin);
      FETCH c_arc_metric_usage INTO l_dummy;
      CLOSE c_arc_metric_usage;
      IF l_dummy IS NULL THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            Fnd_Message.Set_Name ('AMS', 'AMS_METR_INVALID_ORIGIN');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
      END IF;
   END IF;

   --
   -- End Validate LOOKUPS
   --

   --
   -- End Other Business Rule Validations
   --

EXCEPTION
   WHEN OTHERS THEN
      RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
END Check_ActMetric_Items;

--
-- Start of comments.
--
-- NAME
--    Validate_ActMetric_Record
--
-- PURPOSE
--    Perform Record Level and Other business validations for metrics.
--
-- NOTES
--
-- HISTORY
-- 10/11/1999     ptendulk  Created.
-- 05/08/2000     tdonohoe  Modified, do not perform FK check on Metric_Id
--                          if Activity Metric is associated with a Forecast.
-- 06/28/2000     rchahal   Modified, do not perform FK check on Metric_Id
--                          if Activity Metric is associated with a Fund.
-- 05/01/2003     choang    bug 2931351 - restrict update of costs and revenues
-- 05/19/2005     choang    Added edit metric access check.
-- End of comments.

PROCEDURE Validate_ActMetric_record(
   p_act_metric_rec   IN  act_metric_rec_type,
   p_complete_rec     IN  act_metric_rec_type,
   x_return_status    OUT NOCOPY VARCHAR2
)
IS
BEGIN
   Validate_ActMetric_Record (
      p_act_metric_rec  => p_act_metric_rec,
      p_complete_rec    => p_complete_rec,
      p_operation_mode  => G_CREATE,
      x_return_status   => x_return_status
   );
END;


--
-- Start of comments.
--
-- NAME
--    Validate_ActMetric_Record
--
-- PURPOSE
--    Perform Record Level and Other business validations for metrics.  Allow for
--    different types of validation based on the type of database operation.
--
-- NOTES
--
-- HISTORY
-- 06-May-2003    choang   bug 2931351 - restrict update of costs and revenues
-- End of comments.

PROCEDURE Validate_ActMetric_record(
   p_act_metric_rec  IN  act_metric_rec_type,
   p_complete_rec    IN  act_metric_rec_type,
   p_operation_mode  IN VARCHAR2,
   x_return_status   OUT NOCOPY VARCHAR2
)
IS
   L_ALLOW_ACTUAL_UPDATE_METR  CONSTANT VARCHAR2(30) := 'AMS_ALLOW_ACTUAL_UPDATE';

   l_act_metrics_rec              act_metric_rec_type := p_act_metric_rec ;

   l_table_name                  VARCHAR2(30);
   l_pk_name                     VARCHAR2(30);
   l_pk_value                    VARCHAR2(30);
   l_pk_data_type                VARCHAR2(30);
   l_additional_where_clause     VARCHAR2(4000);  -- Used by Check_FK_Exists.

   l_allow_actual_update         VARCHAR2(1);
   l_freeze_status               VARCHAR2(1);

   l_return_status                               VARCHAR2(1);

   CURSOR c_metric_details (p_metric_id IN NUMBER) IS
      SELECT uom_type,
             metric_calculation_type,
             arc_metric_used_for_object,
             metric_category
      FROM   ams_metrics_all_b
      WHERE metric_id = p_metric_id;
   l_metric_details_rec    c_metric_details%ROWTYPE;

   l_object_name AMS_LOOKUPS.MEANING%TYPE;

   CURSOR c_ref_metric (p_act_metric_id NUMBER) IS
      SELECT func_actual_value,
             trans_forecasted_value,
             forecasted_variable_value
      FROM   ams_act_metrics_all
      WHERE  activity_metric_id = p_act_metric_id;



  CURSOR c_check_uom(p_uom_code varchar2,p_uom_class varchar2 ) IS
    SELECT 1 from MTL_UNITS_OF_MEASURE
    WHERE UOM_CODE = p_uom_code
    AND   uom_class = p_uom_class;

   l_ref_metric_rec     c_ref_metric%ROWTYPE;
BEGIN

   x_return_status := Fnd_Api.g_ret_sts_success;

   -- Initialize any values that are needed from
   -- the database to do comparisons in the validation.
   OPEN c_metric_details (l_act_metrics_rec.metric_id);
   FETCH c_metric_details INTO l_metric_details_rec;
   CLOSE c_metric_details;

   OPEN c_ref_metric (l_act_metrics_rec.activity_metric_id);
   FETCH c_ref_metric INTO l_ref_metric_rec;
   CLOSE c_ref_metric;

   -- Used for validation of forecast and actual value
   -- updates.
   Check_Freeze_Status (l_act_metrics_rec,
                        G_UPDATE, -- Update is operation mode
                        l_freeze_status,
                        l_return_status);

   -- Validate Update Mode --
   IF p_operation_mode = G_UPDATE THEN
      --
      -- choang - 11-may-2005 - validate edit metric access
      IF AMS_Access_PVT.check_update_access (
            p_object_id           => l_act_metrics_rec.act_metric_used_by_id,
            p_object_type         => l_act_metrics_rec.arc_act_metric_used_by,
            p_user_or_role_id     => AMS_Utility_PVT.get_resource_id (FND_GLOBAL.user_id),
            p_user_or_role_type   => 'USER') <> 'F' THEN
         x_return_status := Fnd_Api.G_RET_STS_ERROR;
         FND_MESSAGE.set_name ('AMS', 'AMS_NO_METRIC_UPDATE_ACCESS');
         FND_MESSAGE.set_token('OBJECT',
                               AMS_Utility_PVT.get_object_name(l_act_metrics_rec.arc_act_metric_used_by,
                                                               l_act_metrics_rec.act_metric_used_by_id)
                              );
         FND_MSG_PUB.add;
         -- exit the program immediately after this
         -- validation fails because it defines the
         -- entry requirement for executing any other
         -- logic for activity metrics; this is as if
         -- the validation is done at a "higher" level
         -- before the act metric API is invoked.
         RETURN;
      END IF;

      --
      -- choang - 01-may-2003 - validate forecast value update
      -- moved from the main update api
      --
      IF (l_freeze_status = Fnd_Api.G_TRUE)
         AND ((nvl(l_act_metrics_rec.trans_forecasted_value,0) <> FND_API.g_miss_num
            AND NVL (l_act_metrics_rec.trans_forecasted_value, 0) <>
                NVL (l_ref_metric_rec.trans_forecasted_value, 0) )
           OR ( nvl(l_act_metrics_rec.forecasted_variable_value,0) <> FND_API.g_miss_num
         AND NVL (l_act_metrics_rec.forecasted_variable_value, 0) <>
             NVL (l_ref_metric_rec.forecasted_variable_value, 0) ) )
         AND l_metric_details_rec.metric_category IN
              (G_CATEGORY_COSTS, G_CATEGORY_REVENUES)
         AND l_metric_details_rec.metric_calculation_type IN
              ('MANUAL', 'FUNCTION') THEN
         -- frozen to update the forecast COST.
         -- this portion calls the Complete_ActMetric_Rec
         -- to set trans_forecasted_value back to
         -- its original value

         IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.g_msg_lvl_error) THEN
              l_object_name := ams_utility_pvt.get_lookup_meaning(
                     'AMS_SYS_ARC_QUALIFIER',
                     l_act_metrics_rec.arc_act_metric_used_by);
              Fnd_Message.set_name('AMS', 'AMS_UPDATE_FORECAST');
              Fnd_Message.set_token('OBJECT', l_object_name);
              Fnd_Msg_Pub.ADD;
         END IF;  --msg_pub if
         x_return_status := Fnd_Api.G_RET_STS_ERROR;
      END IF;

      --
      -- bug 2931351 - disallow update of actuals before active
      --
      -- Make a call-out to check the frozen status.
      -- If it is frozen, disallow the operation.
      -- Use NVL for comparison of NULLs to 0 because
      -- refresh engine updates NULL metrics to 0.
      IF l_act_metrics_rec.trans_actual_value <> FND_API.g_miss_num
         AND NVL (l_act_metrics_rec.trans_actual_value, 0) <>
                NVL (l_ref_metric_rec.func_actual_value, 0)
         AND l_metric_details_rec.metric_category IN
                (G_CATEGORY_COSTS, G_CATEGORY_REVENUES)
         AND l_metric_details_rec.metric_calculation_type IN
                ('MANUAL', 'FUNCTION') THEN
         l_allow_actual_update :=
                NVL(Fnd_Profile.Value (L_ALLOW_ACTUAL_UPDATE_METR),'N');

          --sunkumar 04/30/2003
          --added profile option to restrict updation of actuals
         IF (l_allow_actual_update = 'N') THEN
            --object is not active and profile is N hence do not allow update
            IF (l_freeze_status = Fnd_Api.G_FALSE) THEN
               IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.g_msg_lvl_error) THEN
                  Fnd_Message.set_name('AMS', 'AMS_METR_UPDATE_ACTUAL');
                  Fnd_Msg_Pub.ADD;
               END IF;  --msg_pub if

               x_return_status := Fnd_Api.G_RET_STS_ERROR;
            END IF;  --freeze status if
         END IF;  --profile if
      END IF;  -- check if func_actual_value changed
   -- Validate Create Mode --
   ELSIF p_operation_mode = G_CREATE THEN
      --
      -- bug 4661335 - disallow create of actuals before active
      --
      -- Make a call-out to check the frozen status.
      -- If it is frozen, disallow the operation.
      -- Use NVL for comparison of NULLs to 0 because
      -- refresh engine updates NULL metrics to 0.
      IF l_act_metrics_rec.trans_actual_value <> FND_API.g_miss_num
         AND NVL (l_act_metrics_rec.trans_actual_value, 0) <> 0
         AND l_metric_details_rec.metric_category IN
                (G_CATEGORY_COSTS, G_CATEGORY_REVENUES)
         AND l_metric_details_rec.metric_calculation_type IN
                ('MANUAL', 'FUNCTION') THEN
         l_allow_actual_update :=
                NVL(Fnd_Profile.Value (L_ALLOW_ACTUAL_UPDATE_METR),'N');

          -- Profile option to restrict updation of actuals.
         IF (l_allow_actual_update = 'N') THEN
            --object is not active and profile is N hence do not allow update
            IF (l_freeze_status = Fnd_Api.G_FALSE) THEN
               IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.g_msg_lvl_error) THEN
                  Fnd_Message.set_name('AMS', 'AMS_METR_UPDATE_ACTUAL');
                  Fnd_Msg_Pub.ADD;
               END IF;  --msg_pub if

               x_return_status := Fnd_Api.G_RET_STS_ERROR;
            END IF;  --freeze status if
         END IF;  --profile if
      END IF;  -- check if func_actual_value changed


      NULL; -- nothing here yet
   -- Validate Delete Mode --
   ELSIF p_operation_mode = G_DELETE THEN
      NULL; -- nothing here yet
   END IF;

   -- Validate All Modes --
    IF l_act_metrics_rec.arc_act_metric_used_by <> Fnd_Api.G_MISS_CHAR THEN

       IF l_act_metrics_rec.act_metric_used_by_id = Fnd_Api.G_MISS_NUM THEN
          l_act_metrics_rec.act_metric_used_by_id  :=
                                      p_complete_rec.act_metric_used_by_id;
       END IF;

       IF l_act_metrics_rec.metric_id = Fnd_Api.G_MISS_NUM THEN
          l_act_metrics_rec.metric_id  := p_complete_rec.metric_id;
       END IF;

          -- DMVINCEN 06/07/2001
          -- The object type must match between the metric and the object
          -- being assigned only if the calculation type is MANUAL or FUNCTION.
          -- SUMMARY or ROLLUP metrics can be assigned to any object.
          IF l_metric_details_rec.metric_calculation_type IS NULL OR
             (l_metric_details_rec.metric_calculation_type IN ('MANUAL', 'FUNCTION') AND
              l_metric_details_rec.arc_metric_used_for_object <> l_act_metrics_rec.arc_act_metric_used_by)
          THEN

            IF Fnd_Msg_Pub.Check_Msg_Level (Fnd_Msg_Pub.G_MSG_LVL_ERROR)
            THEN
               Fnd_Message.Set_Name('AMS', 'AMS_METR_INVALID_ACT_USAGE');
               Fnd_Msg_Pub.ADD;
            END IF;

            x_return_status := Fnd_Api.G_RET_STS_ERROR;
         END IF;  -- Check_FK_Exists

      -- Get table_name and pk_name for the ARC qualifier.
   /*sunkumar 21-apr-2004 added*/
    IF Validate_Object_Exists(
                p_object_type => l_act_metrics_rec.arc_act_metric_used_by
                 ,p_object_id     => l_act_metrics_rec.act_metric_used_by_id
    ) = Fnd_Api.G_FALSE
      THEN
            IF Fnd_Msg_Pub.Check_Msg_Level (Fnd_Msg_Pub.G_MSG_LVL_ERROR) THEN
            l_object_name := ams_utility_pvt.get_lookup_meaning(
             'AMS_SYS_ARC_QUALIFIER',l_act_metrics_rec.arc_act_metric_used_by);
            Fnd_Message.Set_Name ('AMS', 'AMS_METR_INVALID_OBJECT');
            Fnd_Message.Set_Token('OBJTYPE',l_object_name);
            Fnd_Message.Set_Token('OBJID',l_pk_value);
            Fnd_Msg_Pub.ADD;
            END IF;

            x_return_status := Fnd_Api.G_RET_STS_ERROR;
      END IF;

   END IF;

   -- METRIC_UOM_CODE
   IF l_act_metrics_rec.metric_uom_code <> Fnd_Api.G_MISS_CHAR THEN
      IF l_act_metrics_rec.metric_id = Fnd_Api.G_MISS_NUM THEN
         l_act_metrics_rec.metric_id  := p_complete_rec.metric_id ;
      END IF;

    OPEN c_check_uom(l_act_metrics_rec.metric_uom_code,l_metric_details_rec.uom_type);
    IF c_check_uom%NOTFOUND
    THEN
            IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
            THEN
               FND_MESSAGE.Set_Name('AMS', 'AMS_METR_INVALID_UOM');
               FND_MSG_PUB.ADD;
            END IF;

            x_return_status := FND_API.G_RET_STS_ERROR;
            CLOSE c_check_uom;
            RETURN;
        END IF;
     CLOSE c_check_uom;
   END IF;

   IF l_act_metrics_rec.arc_activity_metric_origin <> Fnd_Api.G_MISS_CHAR THEN
      IF l_act_metrics_rec.activity_metric_origin_id = Fnd_Api.G_MISS_NUM THEN
         l_act_metrics_rec.activity_metric_origin_id :=
                                     p_complete_rec.activity_metric_origin_id;
      END IF;

          -- Get table_name and pk_name for the ARC qualifier.
   /*sunkumar 21-apr-2004 added*/
    IF Validate_Object_Exists(
                p_object_type => l_act_metrics_rec.arc_act_metric_used_by
                 ,p_object_id     => l_act_metrics_rec.act_metric_used_by_id
    ) = Fnd_Api.G_FALSE
      THEN
         IF Fnd_Msg_Pub.Check_Msg_Level (Fnd_Msg_Pub.G_MSG_LVL_ERROR) THEN
         Fnd_Message.Set_Name ('AMS', 'AMS_METR_INVALID_ORIGIN');
         Fnd_Msg_Pub.ADD;
         END IF;

         x_return_status := Fnd_Api.G_RET_STS_ERROR;
      END IF;
   END IF;

   --
   -- Other Business Rule Validations
   --
END Validate_ActMetric_record;



--
-- Start of comments.
--
-- NAME
--    Validate_ActMetric_Items
--
-- PURPOSE
--    Perform All Item level validation for Activity metrics.
--
-- NOTES
--
-- HISTORY
-- 10/11/1999     ptendulk            Created.
--
-- End of comments.

PROCEDURE Validate_ActMetric_items(
   p_act_metric_rec    IN  act_metric_rec_type,
   p_validation_mode   IN  VARCHAR2 := Jtf_Plsql_Api.g_create,
   x_return_status     OUT NOCOPY VARCHAR2
)
IS
BEGIN

   Check_Req_ActMetrics_Items(
      p_act_metric_rec  => p_act_metric_rec,
      x_return_status    => x_return_status
   );
   IF x_return_status <> Fnd_Api.g_ret_sts_success THEN
      RETURN;
   END IF;

   Check_ActMetric_Uk_Items(
      p_act_metric_rec    => p_act_metric_rec,
      p_validation_mode   => p_validation_mode,
      x_return_status     => x_return_status
   );

   IF x_return_status <> Fnd_Api.g_ret_sts_success THEN
      RETURN;
   END IF;

   Check_ActMetric_Items(
      p_act_metric_rec   => p_act_metric_rec,
      x_return_status     => x_return_status
   );

   IF x_return_status <> Fnd_Api.g_ret_sts_success THEN
      RETURN;
   END IF;



END Validate_ActMetric_items;

--
-- Begin of section added by ptendulk - 10/11/1999
--
-- NAME
--    Complete_Metric_Rec
--
-- PURPOSE
--   Returns the Initialized Activity Metric Record
--
-- NOTES
--
-- HISTORY
-- 07/19/1999   choang         Created.
--
PROCEDURE Complete_ActMetric_Rec(
   p_act_metric_rec      IN  act_metric_rec_type,
   x_complete_rec        IN OUT NOCOPY act_metric_rec_type
)
IS
   CURSOR c_act_metric IS
   SELECT *
     FROM ams_act_metrics_all
    WHERE activity_metric_id = p_act_metric_rec.activity_metric_id;

   l_act_metric_rec  c_act_metric%ROWTYPE;
BEGIN

   x_complete_rec := p_act_metric_rec;

   OPEN c_act_metric;
   FETCH c_act_metric INTO l_act_metric_rec;
   IF c_act_metric%NOTFOUND THEN
      CLOSE c_act_metric;
      IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.g_msg_lvl_error) THEN
         Fnd_Message.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
         Fnd_Msg_Pub.ADD;
      END IF;
      RAISE Fnd_Api.g_exc_error;
   END IF;
   CLOSE c_act_metric;


   IF p_act_metric_rec.act_metric_used_by_id = Fnd_Api.G_MISS_NUM THEN
      x_complete_rec.act_metric_used_by_id := l_act_metric_rec.act_metric_used_by_id;
   END IF;

   IF p_act_metric_rec.arc_act_metric_used_by = Fnd_Api.G_MISS_CHAR THEN
      x_complete_rec.arc_act_metric_used_by := l_act_metric_rec.arc_act_metric_used_by;
   END IF;

   IF p_act_metric_rec.purchase_req_raised_flag = Fnd_Api.G_MISS_CHAR THEN
      x_complete_rec.purchase_req_raised_flag := l_act_metric_rec.purchase_req_raised_flag;
   END IF;

   IF p_act_metric_rec.application_id = Fnd_Api.G_MISS_NUM THEN
      x_complete_rec.application_id := l_act_metric_rec.application_id;
   END IF;

   IF p_act_metric_rec.sensitive_data_flag = Fnd_Api.G_MISS_CHAR THEN
      x_complete_rec.sensitive_data_flag := l_act_metric_rec.sensitive_data_flag;
   END IF;

   IF p_act_metric_rec.budget_id = Fnd_Api.G_MISS_NUM THEN
      x_complete_rec.budget_id := l_act_metric_rec.budget_id;
   END IF;

   IF p_act_metric_rec.metric_id = Fnd_Api.G_MISS_NUM THEN
      x_complete_rec.metric_id := l_act_metric_rec.metric_id;
   END IF;

   IF p_act_metric_rec.transaction_currency_code = Fnd_Api.G_MISS_CHAR THEN
      x_complete_rec.transaction_currency_code := l_act_metric_rec.transaction_currency_code;
   END IF;

   IF NVL(p_act_metric_rec.trans_forecasted_value,-1) = Fnd_Api.G_MISS_NUM THEN
      x_complete_rec.trans_forecasted_value := l_act_metric_rec.trans_forecasted_value;
   END IF;

   IF p_act_metric_rec.trans_committed_value = Fnd_Api.G_MISS_NUM THEN
      x_complete_rec.trans_committed_value := l_act_metric_rec.trans_committed_value;
   END IF;

   IF p_act_metric_rec.trans_actual_value = Fnd_Api.G_MISS_NUM THEN
      x_complete_rec.trans_actual_value := l_act_metric_rec.trans_actual_value;
   END IF;

   IF p_act_metric_rec.functional_currency_code = Fnd_Api.G_MISS_CHAR THEN
      x_complete_rec.functional_currency_code := l_act_metric_rec.functional_currency_code;
   END IF;

   IF p_act_metric_rec.func_forecasted_value = Fnd_Api.G_MISS_NUM THEN
      x_complete_rec.func_forecasted_value := l_act_metric_rec.func_forecasted_value;
   END IF;

   IF p_act_metric_rec.func_committed_value = Fnd_Api.G_MISS_NUM THEN
      x_complete_rec.func_committed_value := l_act_metric_rec.func_committed_value;
   END IF;

   IF p_act_metric_rec.func_actual_value = Fnd_Api.G_MISS_NUM THEN
      x_complete_rec.func_actual_value := l_act_metric_rec.func_actual_value;
   END IF;

   IF p_act_metric_rec.dirty_flag = Fnd_Api.G_MISS_CHAR THEN
     IF (l_act_metric_rec.trans_actual_value <>
                                        x_complete_rec.trans_actual_value) OR
       (l_act_metric_rec.transaction_currency_code <>
                                        x_complete_rec.transaction_currency_code) OR
       (l_act_metric_rec.trans_forecasted_value <>
                                        x_complete_rec.trans_forecasted_value) OR
       (l_act_metric_rec.variable_value <>
                                        x_complete_rec.variable_value) or
       (l_act_metric_rec.forecasted_variable_value <>
                                        x_complete_rec.forecasted_variable_value) THEN
                --SVEERAVE, 10/16/00 to default dirty_flag to Y incase of changes in
                -- actual/forecasted values.
          x_complete_rec.dirty_flag := G_IS_DIRTY;
--      x_complete_rec.dirty_flag := l_act_metric_rec.dirty_flag;
     ELSE
          x_complete_rec.dirty_flag := NVL(l_act_metric_rec.dirty_flag,G_IS_DIRTY);
     END IF;
   END IF;

   IF p_act_metric_rec.last_calculated_date = Fnd_Api.G_MISS_DATE THEN
      x_complete_rec.last_calculated_date := l_act_metric_rec.last_calculated_date;
   END IF;

   IF p_act_metric_rec.variable_value = Fnd_Api.G_MISS_NUM THEN
      x_complete_rec.variable_value := l_act_metric_rec.variable_value;
   END IF;

   IF p_act_metric_rec.forecasted_variable_value = Fnd_Api.G_MISS_NUM THEN
      x_complete_rec.forecasted_variable_value := l_act_metric_rec.forecasted_variable_value;
   END IF;

   IF p_act_metric_rec.computed_using_function_value = Fnd_Api.G_MISS_NUM THEN
      x_complete_rec.computed_using_function_value := l_act_metric_rec.computed_using_function_value;
   END IF;

   IF p_act_metric_rec.metric_uom_code = Fnd_Api.G_MISS_CHAR THEN
      x_complete_rec.metric_uom_code := l_act_metric_rec.metric_uom_code;
   END IF;

   IF p_act_metric_rec.attribute_category = Fnd_Api.G_MISS_CHAR THEN
      x_complete_rec.attribute_category := l_act_metric_rec.attribute_category;
   END IF;

   IF p_act_metric_rec.difference_since_last_calc = Fnd_Api.G_MISS_NUM THEN
      x_complete_rec.difference_since_last_calc := l_act_metric_rec.difference_since_last_calc;
   END IF;

   IF p_act_metric_rec.activity_metric_origin_id = Fnd_Api.G_MISS_NUM THEN
      x_complete_rec.activity_metric_origin_id := l_act_metric_rec.activity_metric_origin_id;
   END IF;

   IF p_act_metric_rec.arc_activity_metric_origin = Fnd_Api.G_MISS_CHAR THEN
      x_complete_rec.arc_activity_metric_origin := l_act_metric_rec.arc_activity_metric_origin;
   END IF;

   IF p_act_metric_rec.days_since_last_refresh = Fnd_Api.G_MISS_NUM THEN
      x_complete_rec.days_since_last_refresh := l_act_metric_rec.days_since_last_refresh;
   END IF;

   IF p_act_metric_rec.scenario_id = Fnd_Api.G_MISS_NUM THEN
      x_complete_rec.scenario_id := l_act_metric_rec.scenario_id;
   END IF;

   /***************************************************************/
   /*added 17-Apr-2000 tdonohoe@us support 11.5.2 columns         */
   /***************************************************************/

   IF p_act_metric_rec.hierarchy_id = Fnd_Api.G_MISS_NUM THEN
      x_complete_rec.hierarchy_id := l_act_metric_rec.hierarchy_id;
   END IF;

   IF p_act_metric_rec.start_node  = Fnd_Api.G_MISS_NUM THEN
      x_complete_rec.start_node   := l_act_metric_rec.start_node;
   END IF;

   IF p_act_metric_rec.from_level  = Fnd_Api.G_MISS_NUM THEN
      x_complete_rec.from_level   := l_act_metric_rec.from_level;
   END IF;

   IF p_act_metric_rec.to_level  = Fnd_Api.G_MISS_NUM THEN
      x_complete_rec.to_level   := l_act_metric_rec.to_level;
   END IF;

   IF p_act_metric_rec.from_date  = Fnd_Api.G_MISS_DATE THEN
      x_complete_rec.from_date   := l_act_metric_rec.from_date;
   END IF;

   IF p_act_metric_rec.TO_DATE  = Fnd_Api.G_MISS_DATE THEN
      x_complete_rec.TO_DATE   := l_act_metric_rec.TO_DATE;
   END IF;

   IF p_act_metric_rec.amount1  = Fnd_Api.G_MISS_NUM THEN
      x_complete_rec.amount1   := l_act_metric_rec.amount1;
   END IF;

   IF p_act_metric_rec.amount2  = Fnd_Api.G_MISS_NUM THEN
      x_complete_rec.amount2   := l_act_metric_rec.amount2;
   END IF;

   IF p_act_metric_rec.amount3  = Fnd_Api.G_MISS_NUM THEN
      x_complete_rec.amount3   := l_act_metric_rec.amount3;
   END IF;

   IF p_act_metric_rec.percent1  = Fnd_Api.G_MISS_NUM THEN
      x_complete_rec.percent1   := l_act_metric_rec.percent1;
   END IF;

   IF p_act_metric_rec.percent2  = Fnd_Api.G_MISS_NUM THEN
      x_complete_rec.percent2   := l_act_metric_rec.percent2;
   END IF;

   IF p_act_metric_rec.percent3  = Fnd_Api.G_MISS_NUM THEN
      x_complete_rec.percent3   := l_act_metric_rec.percent3;
   END IF;

   IF p_act_metric_rec.published_flag  = Fnd_Api.G_MISS_CHAR THEN
      x_complete_rec.published_flag   := l_act_metric_rec.published_flag;
   END IF;

   IF p_act_metric_rec.pre_function_name  = Fnd_Api.G_MISS_CHAR THEN
      x_complete_rec.pre_function_name   := l_act_metric_rec.pre_function_name;
   END IF;

   IF p_act_metric_rec.post_function_name  = Fnd_Api.G_MISS_CHAR THEN
      x_complete_rec.post_function_name   := l_act_metric_rec.post_function_name;
   END IF;

   IF p_act_metric_rec.attribute1 = Fnd_Api.G_MISS_CHAR THEN
      x_complete_rec.attribute1 := l_act_metric_rec.attribute1;
   END IF;

   IF p_act_metric_rec.attribute2 = Fnd_Api.G_MISS_CHAR THEN
      x_complete_rec.attribute2 := l_act_metric_rec.attribute2;
   END IF;

   IF p_act_metric_rec.attribute3 = Fnd_Api.G_MISS_CHAR THEN
      x_complete_rec.attribute3 := l_act_metric_rec.attribute3;
   END IF;

   IF p_act_metric_rec.attribute4 = Fnd_Api.G_MISS_CHAR THEN
      x_complete_rec.attribute4 := l_act_metric_rec.attribute4;
   END IF;

   IF p_act_metric_rec.attribute5 = Fnd_Api.G_MISS_CHAR THEN
      x_complete_rec.attribute5 := l_act_metric_rec.attribute5;
   END IF;

   IF p_act_metric_rec.attribute6 = Fnd_Api.G_MISS_CHAR THEN
      x_complete_rec.attribute6 := l_act_metric_rec.attribute6;
   END IF;

   IF p_act_metric_rec.attribute7 = Fnd_Api.G_MISS_CHAR THEN
      x_complete_rec.attribute7 := l_act_metric_rec.attribute7;
   END IF;

   IF p_act_metric_rec.attribute8 = Fnd_Api.G_MISS_CHAR THEN
      x_complete_rec.attribute8 := l_act_metric_rec.attribute8;
   END IF;

   IF p_act_metric_rec.attribute9 = Fnd_Api.G_MISS_CHAR THEN
      x_complete_rec.attribute9 := l_act_metric_rec.attribute9;
   END IF;

   IF p_act_metric_rec.attribute10 = Fnd_Api.G_MISS_CHAR THEN
      x_complete_rec.attribute10 := l_act_metric_rec.attribute10;
   END IF;

   IF p_act_metric_rec.attribute11 = Fnd_Api.G_MISS_CHAR THEN
      x_complete_rec.attribute11 := l_act_metric_rec.attribute11;
   END IF;

   IF p_act_metric_rec.attribute12 = Fnd_Api.G_MISS_CHAR THEN
      x_complete_rec.attribute12 := l_act_metric_rec.attribute12;
   END IF;

   IF p_act_metric_rec.attribute13 = Fnd_Api.G_MISS_CHAR THEN
      x_complete_rec.attribute13 := l_act_metric_rec.attribute13;
   END IF;

   IF p_act_metric_rec.attribute14 = Fnd_Api.G_MISS_CHAR THEN
      x_complete_rec.attribute14 := l_act_metric_rec.attribute14;
   END IF;

   IF p_act_metric_rec.attribute15 = Fnd_Api.G_MISS_CHAR THEN
      x_complete_rec.attribute15 := l_act_metric_rec.attribute15;
   END IF;

-- DMVINCEN 05/01/2001: New columns.
   IF p_act_metric_rec.act_metric_date = Fnd_Api.G_MISS_DATE THEN
      x_complete_rec.act_metric_date := l_act_metric_rec.act_metric_date;
   END IF;

   IF p_act_metric_rec.description = Fnd_Api.G_MISS_CHAR THEN
      x_complete_rec.description := l_act_metric_rec.description;
   END IF;

-- DMVINCEN 05/01/2001: End new columns.

   IF p_act_metric_rec.depend_act_metric = Fnd_Api.G_MISS_NUM THEN
      x_complete_rec.depend_act_metric := l_act_metric_rec.depend_act_metric;
   END IF;

-- DMVINCEN 03/08/2002:

   IF p_act_metric_rec.function_used_by_id = Fnd_Api.G_MISS_NUM THEN
      x_complete_rec.function_used_by_id := l_act_metric_rec.function_used_by_id;
   END IF;

   IF p_act_metric_rec.arc_function_used_by = Fnd_Api.G_MISS_CHAR THEN
      x_complete_rec.arc_function_used_by := l_act_metric_rec.arc_function_used_by;
   END IF;

   /* 05/15/2002 yzhao: add 6 new columns for top-down bottom-up budgeting */
   IF p_act_metric_rec.hierarchy_type = Fnd_Api.G_MISS_CHAR THEN
      x_complete_rec.hierarchy_type := l_act_metric_rec.hierarchy_type;
   END IF;

   IF p_act_metric_rec.status_code = Fnd_Api.G_MISS_CHAR THEN
      x_complete_rec.status_code := l_act_metric_rec.status_code;
   END IF;

   IF p_act_metric_rec.method_code = Fnd_Api.G_MISS_CHAR THEN
      x_complete_rec.method_code := l_act_metric_rec.method_code;
   END IF;

   IF p_act_metric_rec.action_code = Fnd_Api.G_MISS_CHAR THEN
      x_complete_rec.action_code := l_act_metric_rec.action_code;
   END IF;

   IF p_act_metric_rec.basis_year = Fnd_Api.G_MISS_NUM THEN
      x_complete_rec.basis_year := l_act_metric_rec.basis_year;
   END IF;

   IF p_act_metric_rec.ex_start_node = Fnd_Api.G_MISS_CHAR THEN
      x_complete_rec.ex_start_node := l_act_metric_rec.ex_start_node;
   END IF;
   /* 05/15/2002 yzhao: add ends */

END Complete_ActMetric_Rec ;

--
-- End of section added by choang.
--
-- NAME
--    SetCommittedVal
--
-- PURPOSE
--   Updates the functional committed value of a specific
--   metric that is associated with the given business
--   entity.
--
-- NOTES
--
-- HISTORY
-- 07/19/1999   choang         Created.
-- 10/13/1999   ptendulk           Modified According to new standards
--

PROCEDURE SetCommittedVal (
   p_api_version                 IN NUMBER,
   p_init_msg_list               IN VARCHAR2 := Fnd_Api.G_FALSE,
   p_commit                      IN VARCHAR2 := Fnd_Api.G_FALSE,
   p_validation_level            IN NUMBER   := Fnd_Api.G_VALID_LEVEL_FULL,

   x_return_status               OUT NOCOPY VARCHAR2,
   x_msg_count                   OUT NOCOPY NUMBER,
   x_msg_data                    OUT NOCOPY VARCHAR2,

   p_arc_act_metric_used_by      IN VARCHAR2,
   p_act_metric_used_by_id       IN NUMBER,
   p_metric_id                   IN NUMBER,
   p_func_committed_value        IN NUMBER
)
IS
   L_API_VERSION         CONSTANT NUMBER := 1.0;
   L_API_NAME            CONSTANT VARCHAR2(30) := 'SETCOMMITTEDVAL';
   L_FULL_NAME           CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| L_API_NAME;

   l_return_status       VARCHAR2(1);

BEGIN
   --
   -- Initialize savepoint.
   --
   SAVEPOINT SetCommittedVal_SavePoint;

   --
   -- Output debug message.
   --
   IF (AMS_DEBUG_HIGH_ON) THEN
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

   --
   -- Output debug message.
   --
   IF (AMS_DEBUG_HIGH_ON) THEN
      Ams_Utility_Pvt.debug_message(l_full_name||': Update');
   END IF;

   UPDATE ams_act_metrics_all
      SET   func_committed_value = p_func_committed_value
      WHERE arc_act_metric_used_by = p_arc_act_metric_used_by
      AND   act_metric_used_by_id = p_act_metric_used_by_id
      AND   metric_id = p_metric_id ;
   IF SQL%NOTFOUND THEN
      --
      -- The metric for the given business entity does not
      -- exist.  Add the proper message and raise an error.
      RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
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
   -- set the message data OUT NOCOPY variable.
   --
   Fnd_Msg_Pub.Count_And_Get (
      p_count           =>    x_msg_count,
      p_data            =>    x_msg_data,
      p_encoded         =>    Fnd_Api.G_FALSE
   );

   --
   -- Output debug message.
   --
   IF (AMS_DEBUG_HIGH_ON) THEN
      Ams_Utility_Pvt.debug_message(l_full_name||': End');
   END IF;


EXCEPTION
   WHEN Fnd_Api.G_EXC_ERROR THEN
      ROLLBACK TO SetCommittedVal_SavePoint;
      x_return_status := Fnd_Api.G_RET_STS_ERROR;
      Fnd_Msg_Pub.Count_And_Get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data,
         p_encoded       =>   FND_API.G_FALSE
      );
   WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO SetCommittedVal_SavePoint;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      Fnd_Msg_Pub.Count_And_Get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data,
         p_encoded       =>   FND_API.G_FALSE
      );
   WHEN OTHERS THEN
      ROLLBACK TO SetCommittedVal_SavePoint;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      IF Fnd_Msg_Pub.Check_Msg_Level (Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR) THEN
         Fnd_Msg_Pub.Add_Exc_Msg (G_PKG_NAME, L_API_NAME);
      END IF;
      Fnd_Msg_Pub.Count_And_Get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data,
         p_encoded       =>   FND_API.G_FALSE
      );
END SetCommittedVal;

--
-- End of section added by choang - 07/19/1999.
--
--
-- NAME
--    IsSeeded
--
-- PURPOSE
--    Returns whether the given ID is that of a seeded record.
--
-- NOTES
--    As of creation of the function, a seeded record has an ID
--    less than 30,000.
--
-- HISTORY
-- 10/15/1999   ptendulk         Created.
-- 01/18/200    bgeorge         modified to check for IDs below 10000
--
FUNCTION IsSeeded (
   p_id        IN NUMBER
)
RETURN BOOLEAN
IS
   CURSOR c_met_id(l_act_met_id NUMBER) IS
      SELECT metric_id
      FROM   ams_act_metrics_all
      WHERE activity_metric_id =l_act_met_id;
   l_met_rec NUMBER;
BEGIN

  OPEN c_met_id(p_id);
  FETCH c_met_id INTO l_met_rec ;
  CLOSE c_met_id ;
  IF l_met_rec < 10000 THEN
     RETURN TRUE;
  END IF;

  RETURN FALSE;
END IsSeeded;

--
-- NAME
--    Default_Func_Currency
--
-- PURPOSE
--    Returns the functional currency for the transaction, Will only be called
--    if the Metric is Currency Metric
--
-- NOTES
--    This function is not complete as of 10/19/1999 , Pending Issue

--
-- HISTORY
-- 10/15/1999   ptendulk         Created.
-- 08/17/2000   sveerave         modified to get the value from profile.
FUNCTION Default_Func_Currency
RETURN VARCHAR2
IS
BEGIN
   RETURN Fnd_Profile.Value('AMS_DEFAULT_CURR_CODE');
--   RETURN 'USD';
END Default_Func_Currency;

---------------------------------------------------------------------
-- PROCEDURE
--   check_forecasted_cost
--
-- PURPOSE
--    Checks forecasted amount against object's budget amount, and passes out message in case it is exceeded.
--
-- PARAMETERS
        --p_obj_type    IN      VARCHAR2,
        --p_obj_id      IN      NUMBER,
        --p_category_id IN      NUMBER,
        --p_exceeded    OUT NOCOPY     VARCHAR2,
        --p_message     OUT NOCOPY     VARCHAR2)--
-- NOTES
--    1. Does only for cost type metrics
--    2. budget will always have transaction amount. metrics will always have functional amount. So, comparisons are made
--       after conversion to common currency, default func currency.
----------------------------------------------------------------------

PROCEDURE check_forecasted_cost(p_obj_type      IN      VARCHAR2,
                                p_obj_id        IN      NUMBER,
                                p_category_id   IN      NUMBER,
                                x_exceeded      OUT NOCOPY     VARCHAR2,
                                x_message       OUT NOCOPY     VARCHAR2) IS

     -- select budget amounts for campaign
     CURSOR c_get_camp_budget_amounts(l_obj_id       NUMBER) IS
         SELECT budget_amount_tc, transaction_currency_code,
               budget_amount_fc, functional_currency_code
         FROM ams_campaigns_all_b
         WHERE campaign_id = l_obj_id;

     -- select budget amounts for campaign
     CURSOR c_get_csch_budget_amounts(l_obj_id       NUMBER) IS
         SELECT budget_amount_tc, transaction_currency_code,
               budget_amount_fc, functional_currency_code
         FROM ams_campaign_schedules_b
         WHERE schedule_id = l_obj_id;

     -- select budget amounts for event offer
     CURSOR c_get_eveof_budget_amounts(l_obj_id      NUMBER) IS
         SELECT fund_amount_tc, currency_code_tc,
               fund_amount_fc, currency_code_fc
         FROM ams_event_offers_all_b
         WHERE event_offer_id = l_obj_id;

     -- select budget amounts for event header
     CURSOR c_get_evehd_budget_amounts(l_obj_id      NUMBER) IS
         SELECT fund_amount_tc, currency_code_tc,
               fund_amount_fc, currency_code_fc
         FROM ams_event_headers_all_b
         WHERE event_header_id = l_obj_id;

     -- select budget amounts for deliverable
     CURSOR c_get_deliv_budget_amounts(l_obj_id      NUMBER) IS
         SELECT budget_amount_tc, transaction_currency_code,
               budget_amount_fc, functional_currency_code
         FROM ams_deliverables_all_b
         WHERE deliverable_id = l_obj_id;

     -- select forecasted amounts for actmetric
     CURSOR c_get_actmet_fore_amounts(l_obj_type     VARCHAR2,
                                      l_obj_id      NUMBER,
                                      l_category_id NUMBER) IS
         SELECT trans_forecasted_value,
               transaction_currency_code,
               func_forecasted_value,
               functional_currency_code
         FROM ams_act_metrics_all actmet, ams_metrics_all_b met
         WHERE actmet.metric_id = met.metric_id
          AND arc_act_metric_used_by = l_obj_type
          AND act_metric_used_by_id  = l_obj_id
          AND metric_category = l_category_id
          AND summarize_to_metric IS NULL
          AND metric_calculation_type <> 'FORMULA';

     l_trans_budget_curr_code        VARCHAR2(15);
     l_func_budget_curr_code         VARCHAR2(15);
     l_trans_budget_amount           NUMBER;
     l_func_budget_amount            NUMBER;
     l_actmet_trans_curr_code        VARCHAR2(15);
     l_actmet_func_curr_code         VARCHAR2(15);
     l_actmet_trans_fore_amount      NUMBER;
     l_actmet_func_fore_amount       NUMBER;
     l_sum_func_fore_amount          NUMBER := 0;
     l_default_func_curr_code        VARCHAR2(15);
     l_return_status                 VARCHAR2(1);
     l_top_level_exists              VARCHAR2(1) := 'F';
     l_current_date                  DATE := SYSDATE;
     l_sum_tran_fore_amount          NUMBER := 0;


BEGIN
   -- do only for costs
   IF p_category_id = 901 THEN
      -- default x_exceeded flag
      x_exceeded := 'N';
      -- get default functional currency code
      l_default_func_curr_code := Default_Func_Currency;

      -- Get forecasted costs for the top level activity metric and sum them.
      OPEN c_get_actmet_fore_amounts(p_obj_type, p_obj_id, p_category_id);
      LOOP
         FETCH c_get_actmet_fore_amounts
            INTO l_actmet_trans_fore_amount,
                 l_actmet_trans_curr_code,
                 l_actmet_func_fore_amount,
                 l_actmet_func_curr_code;
         EXIT WHEN c_get_actmet_fore_amounts%NOTFOUND;
         -- convert act met currency into default currency.
         IF l_default_func_curr_code <> l_actmet_func_curr_code THEN
            Convert_Currency (
                      x_return_status      => l_return_status,
                      p_from_currency      => l_actmet_func_curr_code,
                      p_to_currency        => l_default_func_curr_code,
                      p_conv_date          => l_current_date,
                      p_from_amount        => NVL(l_actmet_func_fore_amount,0),
                      x_to_amount          => l_actmet_func_fore_amount,
                      p_round         => Fnd_Api.G_FALSE);
                 IF l_return_status = Fnd_Api.G_RET_STS_UNEXP_ERROR THEN
                         RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
                 ELSIF l_return_status = Fnd_Api.G_RET_STS_ERROR THEN
                         RAISE Fnd_Api.G_EXC_ERROR;
                 END IF;
         END IF;
         l_sum_func_fore_amount := l_sum_func_fore_amount
                                    + NVL(l_actmet_func_fore_amount,0);
         IF (l_top_level_exists = 'F') THEN
            l_top_level_exists := 'T';
         END IF;
      END LOOP;
      CLOSE c_get_actmet_fore_amounts;

      -- Get the budget amounts for the passed in object
      -- if top level actmet record exists.
      IF (l_top_level_exists = 'T') THEN
         -- for campaigns
         IF p_obj_type IN ('RCAM', 'CAMP') THEN
              OPEN c_get_camp_budget_amounts(p_obj_id);
              FETCH c_get_camp_budget_amounts
               INTO l_trans_budget_amount,
                     l_trans_budget_curr_code,
                     l_func_budget_amount,
                     l_func_budget_curr_code;
            IF c_get_camp_budget_amounts%NOTFOUND THEN
               CLOSE c_get_camp_budget_amounts;
               RAISE Fnd_Api.G_EXC_ERROR;
            END IF;
            CLOSE c_get_camp_budget_amounts;
         -- for campaign schedules
         ELSIF p_obj_type = 'CSCH' THEN
              OPEN c_get_csch_budget_amounts(p_obj_id);
              FETCH c_get_csch_budget_amounts
               INTO l_trans_budget_amount,
                     l_trans_budget_curr_code,
                     l_func_budget_amount,
                     l_func_budget_curr_code;
            IF c_get_csch_budget_amounts%NOTFOUND THEN
               CLOSE c_get_csch_budget_amounts;
               RAISE Fnd_Api.G_EXC_ERROR;
            END IF;
            CLOSE c_get_csch_budget_amounts;
         -- for event offers
         ELSIF p_obj_type IN ('EONE', 'EVEO') THEN
            OPEN c_get_eveof_budget_amounts(p_obj_id);
            FETCH c_get_eveof_budget_amounts
               INTO l_trans_budget_amount,
                   l_trans_budget_curr_code,
                   l_func_budget_amount,
                   l_func_budget_curr_code;
            IF c_get_eveof_budget_amounts%NOTFOUND THEN
               CLOSE c_get_eveof_budget_amounts;
               RAISE Fnd_Api.G_EXC_ERROR;
            END IF;
            CLOSE c_get_eveof_budget_amounts;
         -- for event headers
         ELSIF p_obj_type = 'EVEH' THEN
            OPEN c_get_evehd_budget_amounts(p_obj_id);
            FETCH c_get_evehd_budget_amounts
               INTO l_trans_budget_amount,
                     l_trans_budget_curr_code,
                     l_func_budget_amount,
                     l_func_budget_curr_code;
            IF c_get_evehd_budget_amounts%NOTFOUND THEN
               CLOSE c_get_evehd_budget_amounts;
               RAISE Fnd_Api.G_EXC_ERROR;
            END IF;
            CLOSE c_get_evehd_budget_amounts;
         -- for deliverables
         ELSIF p_obj_type = 'DELV' THEN
            OPEN c_get_deliv_budget_amounts(p_obj_id);
            FETCH c_get_deliv_budget_amounts
             INTO l_trans_budget_amount,
                  l_trans_budget_curr_code,
                  l_func_budget_amount,
                  l_func_budget_curr_code;
            IF c_get_deliv_budget_amounts%NOTFOUND THEN
               CLOSE c_get_deliv_budget_amounts;
               RAISE Fnd_Api.G_EXC_ERROR;
            END IF;
            CLOSE c_get_deliv_budget_amounts;

         END IF; -- IF p_obj_type = 'CAMP'

         -- convert func budget currency into default currency.
         IF l_default_func_curr_code <> l_trans_budget_curr_code THEN
            Convert_Currency (
                   x_return_status      => l_return_status,
                   p_from_currency      => l_default_func_curr_code,
                   p_to_currency        => l_trans_budget_curr_code,
                   p_conv_date          => l_current_date,
                   p_from_amount        => NVL(l_sum_func_fore_amount,0),
                   x_to_amount          => l_sum_tran_fore_amount,
                   p_round         => Fnd_Api.G_TRUE);
            IF l_return_status = Fnd_Api.G_RET_STS_UNEXP_ERROR THEN
               RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
            ELSIF l_return_status = Fnd_Api.G_RET_STS_ERROR THEN
               RAISE Fnd_Api.G_EXC_ERROR;
            END IF;
         END IF;

         -- compare values in the same defualt functional currency
         IF (NVL(l_sum_tran_fore_amount,0) > NVL(l_trans_budget_amount,0)) THEN
            x_exceeded := 'Y';
         END IF;
      END IF;

      IF x_exceeded = 'Y' THEN
         x_message := 'AMS_METR_EXCEED_FORECAST';
      END IF; --      IF x_exceeded = FND_API.G_TRUE

   END IF; -- IF p_category_id = 901

END check_forecasted_cost;

---------------------------------------------------------------------
-- PROCEDURE
--   Invalidate_Rollup
--
-- PURPOSE
--    Sets the rollup_to_metric to null when the parent object is changed.
--
-- PARAMETERS
--    p_used_by_type
--    p_used_by_id
-- NOTES
--    1. Set the dirty flags for all the rollup metrics so the refresh engine
--       will recalculate.
--    2. Set the rollup_to_metric field to NULL because the associations have
--       changed.  This will make the refresh engine recalculate the
--       rollup associations.
--    3. When the hierarchy of business objects gets changed including deletion
--       and modification, this stored procedure needs to be called for the
--       child business object. For example, when a user modifies the parent
--       of a campaign, call this procedure against the child campaign.
--       Another example, when a user changes an event associated with a
--       campaign, call this stored procedure for old event object. One more
--       example, when a user delete a deliverable from a campaign, call this
--       stored procedure for the deliverable being deleted. You do not need
--       to call this module when you add parent or child
--       to a businness object.
----------------------------------------------------------------------
PROCEDURE Invalidate_Rollup(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := Fnd_Api.g_false,
   p_commit            IN  VARCHAR2 := Fnd_Api.G_FALSE,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_used_by_type      IN VARCHAR2,
   p_used_by_id        IN NUMBER
)
IS

   L_API_VERSION    CONSTANT NUMBER := 1.0;
   L_API_NAME       CONSTANT VARCHAR2(30) := 'INVALIDATE_ROLLUP';
   L_FULL_NAME      CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

   l_return_status  VARCHAR2(1);

   CURSOR c_find_rollups(l_used_by_type VARCHAR2, l_used_by_id NUMBER) IS
       SELECT activity_metric_id
         FROM ams_act_metrics_all
        WHERE arc_act_metric_used_by = l_used_by_type
         AND act_metric_used_by_id = l_used_by_id
         AND rollup_to_metric IS NOT NULL;
   l_act_metrics_rec c_find_rollups%ROWTYPE;

   l_used_by_type VARCHAR2(100) := p_used_by_type;
BEGIN
   IF (AMS_DEBUG_HIGH_ON) THEN

   Ams_Utility_Pvt.debug_message('Invalidating object: '||p_used_by_type||
                        ', '||p_used_by_id);
   END IF;

   --
   -- Initialize savepoint.
   --
   SAVEPOINT invalidate_rollup_pvt;
   --
   -- Output debug message.
   --
   IF (AMS_DEBUG_HIGH_ON) THEN

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

   FOR l_act_metrics_rec IN c_find_rollups(l_used_by_type, p_used_by_id)
   LOOP
      Make_Actmetric_Dirty(l_act_metrics_rec.activity_metric_id);
   END LOOP;

   UPDATE ams_act_metrics_all
      SET rollup_to_metric = NULL
    WHERE arc_act_metric_used_by = l_used_by_type
      AND act_metric_used_by_id = p_used_by_id
      AND rollup_to_metric IS NOT NULL;

   IF Fnd_Api.to_boolean(p_commit) THEN
      COMMIT;
   END IF;

   --
   -- Standard API to get message count, and if 1,
   -- set the message data OUT NOCOPY variable.
   --
   Fnd_Msg_Pub.Count_And_Get (
      p_count           =>    x_msg_count,
      p_data            =>    x_msg_data,
      p_encoded         =>    Fnd_Api.G_FALSE
   );

   --
   -- Debug message.
   --
   IF (AMS_DEBUG_HIGH_ON) THEN

   Ams_Utility_Pvt.debug_message(l_full_name ||': END');
   END IF;

EXCEPTION
   WHEN Fnd_Api.G_EXC_ERROR THEN
      ROLLBACK TO Invalidate_Rollup_pvt;
      x_return_status := Fnd_Api.G_RET_STS_ERROR;
      Fnd_Msg_Pub.Count_And_Get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data,
         p_encoded       =>   FND_API.G_FALSE
      );
   WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Invalidate_Rollup_pvt;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      Fnd_Msg_Pub.Count_And_Get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data,
         p_encoded       =>   FND_API.G_FALSE
      );
   WHEN OTHERS THEN
      ROLLBACK TO Invalidate_Rollup_pvt;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      IF Fnd_Msg_Pub.Check_Msg_Level (Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR) THEN
         Fnd_Msg_Pub.Add_Exc_Msg (G_PKG_NAME, L_API_NAME);
      END IF;
      Fnd_Msg_Pub.Count_And_Get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data,
         p_encoded       =>   FND_API.G_FALSE
      );
END Invalidate_Rollup;

-- Start of comments
-- NAME
--    Post_Costs
--
-- PURPOSE
--   Post costs to the budget.
--
-- NOTES
--
-- HISTORY
--   06/01/2001  DMVINCEN Created

-- End of comments

PROCEDURE Post_Costs (
   p_api_version                IN  NUMBER,
   p_init_msg_list              IN  VARCHAR2 := Fnd_Api.G_FALSE,
   p_commit                     IN  VARCHAR2 := Fnd_Api.G_FALSE,
   p_validation_level           IN  NUMBER := Fnd_Api.G_VALID_LEVEL_FULL,

   x_return_status              OUT NOCOPY VARCHAR2,
   x_msg_count                  OUT NOCOPY NUMBER,
   x_msg_data                   OUT NOCOPY VARCHAR2,

   p_obj_type                   IN  VARCHAR2,
   p_obj_id                     IN  NUMBER
)
IS
   L_API_VERSION    CONSTANT NUMBER := 1.0;
   L_API_NAME       CONSTANT VARCHAR2(30) := 'POST_COSTS';
   L_FULL_NAME      CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

   CURSOR c_get_post_metrics(l_obj_type VARCHAR2, l_obj_id NUMBER) IS
      SELECT activity_metric_id,
             func_actual_value,
             '' description,
             functional_currency_code
        FROM ams_act_metrics_all amet
       WHERE arc_act_metric_used_by = l_obj_type
         AND act_metric_used_by_id = l_obj_id
         AND (published_flag IS NULL OR published_flag = 'N')
         AND EXISTS
             (SELECT 'x' FROM ams_metrics_all_b met
               WHERE met.metric_id = amet.metric_id
                 AND metric_calculation_type IN
                  ('FUNCTION', 'MANUAL')
                 AND metric_category = 901) -- Costs only
      FOR UPDATE OF published_flag NOWAIT;

   l_cost_table OZF_Fund_Adjustment_Pvt.cost_tbl_type;
   l_cost_rec OZF_Fund_Adjustment_Pvt.cost_rec_type;
   l_func_currency VARCHAR2(30);

BEGIN
   IF (AMS_DEBUG_HIGH_ON) THEN
      Ams_Utility_Pvt.debug_message('Now posting costs FOR object: '||p_obj_type||':'||p_obj_id);
   END IF;

   --
   -- Initialize savepoint.
   --
   SAVEPOINT Post_ActMetric_pvt;
   --
   -- Output debug message.
   --
   IF (AMS_DEBUG_HIGH_ON) THEN
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

   OPEN c_get_post_metrics(p_obj_type, p_obj_id);
   LOOP
      FETCH c_get_post_metrics INTO l_cost_rec;
      EXIT WHEN c_get_post_metrics%NOTFOUND;

      l_func_currency := l_cost_rec.cost_curr;
      l_cost_table(c_get_post_metrics%ROWCOUNT) := l_cost_rec;

      UPDATE ams_act_metrics_all
         SET published_flag = 'Y'
       WHERE CURRENT OF c_get_post_metrics;

   END LOOP;
   CLOSE c_get_post_metrics;

   IF l_cost_table.COUNT > 0 THEN
      OZF_Fund_Adjustment_Pvt.create_budget_amt_utilized(
         p_budget_used_by_id   => p_obj_id,
         p_budget_used_by_type => p_obj_type,
         p_currency            => l_func_currency,
         p_cost_tbl            => l_cost_table,
         p_api_version         => l_api_version,
         x_return_status       => x_return_status,
         x_msg_count           => x_msg_count,
         x_msg_data            => x_msg_data);
   END IF;

   --
   -- End API Body
   --

   IF Fnd_Api.to_boolean(p_commit) THEN
      COMMIT;
   END IF;

   --
   -- Standard API to get message count, and if 1,
   -- set the message data OUT NOCOPY variable.
   --
   Fnd_Msg_Pub.Count_And_Get (
      p_count           =>    x_msg_count,
      p_data            =>    x_msg_data,
      p_encoded         =>    Fnd_Api.G_FALSE
   );

   --
   -- Debug message.
   --
   IF (AMS_DEBUG_HIGH_ON) THEN
      Ams_Utility_Pvt.debug_message(l_full_name ||': END');
   END IF;


EXCEPTION
   WHEN Fnd_Api.G_EXC_ERROR THEN
      ROLLBACK TO Post_ActMetric_pvt;
      x_return_status := Fnd_Api.G_RET_STS_ERROR;
      Fnd_Msg_Pub.Count_And_Get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data,
         p_encoded       =>   FND_API.G_FALSE
      );
   WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Post_ActMetric_pvt;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      Fnd_Msg_Pub.Count_And_Get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data,
         p_encoded       =>   FND_API.G_FALSE
      );
   WHEN OTHERS THEN
      ROLLBACK TO Post_ActMetric_pvt;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      IF Fnd_Msg_Pub.Check_Msg_Level (Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR) THEN
         Fnd_Msg_Pub.Add_Exc_Msg (G_PKG_NAME, L_API_NAME);
      END IF;
      Fnd_Msg_Pub.Count_And_Get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data,
         p_encoded       =>   FND_API.G_FALSE
      );
END Post_Costs;

--
-- Procedure
--   get_info
--
-- Purpose
--  Gets the currency type information about given currency.
--    Also set the x_invalid_currency flag if the given currency is invalid.
--
-- History
--   15-JUL-97  W Wong   Created
--   10-JUL-01  dmvincen Transfered here from GL_CURRENCY_API
--
-- Arguments
--   x_currency    Currency to be checked
--   x_eff_date    Effecitve date
--   x_conversion_rate   Fixed rate for conversion
--   x_mau                    Minimum accountable unit
--   x_currency_type     Type of currency specified in x_currency
--
PROCEDURE get_info(
   x_currency        VARCHAR2,
   x_mau       IN OUT NOCOPY   NUMBER,
   x_xau       IN OUT NOCOPY   NUMBER ) IS

BEGIN
   -- Get currency information from FND_CURRENCIES table
   SELECT NVL( minimum_accountable_unit, POWER( 10, (-1 * PRECISION))),
      POWER( 10, (-1 * EXTENDED_PRECISION))
   INTO   x_mau, x_xau
   FROM   FND_CURRENCIES
   WHERE  currency_code = x_currency;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      RAISE Gl_Currency_Api.INVALID_CURRENCY;

END get_info;

---------------------------------------------------------------------
-- PROCEDURE
--    Convert_Currency
-- DESCRIPTION
--    This procedure is copied from GL_CURRENCY_API so that rounding can be
--    controlled.  The functional currency need not be rounded because
--    precision will be lost when converting to other currencies.
--    The displayed currencies must be rounded.
-- NOTE
--    Modified from code done by ptendulk, and choang.
-- HISTORY
-- 09-Aug-2001 dmvincen      Created.
---------------------------------------------------------------------
PROCEDURE Convert_Currency (
   x_return_status      OUT NOCOPY VARCHAR2,
   p_from_currency      IN  VARCHAR2,
   p_to_currency        IN  VARCHAR2,
   p_conv_date          IN  DATE,
   p_from_amount        IN  NUMBER,
   x_to_amount          OUT NOCOPY NUMBER,
   p_round              IN VARCHAR2
)
IS
   l_from_dummy  NUMBER := NULL;
   l_to_dummy    NUMBER;
BEGIN
   Convert_Currency2(
      x_return_status => x_return_status,
      p_from_currency => p_from_currency,
      p_to_currency   => p_to_currency,
      p_conv_date     => p_conv_date,
      p_from_amount   => p_from_amount,
      x_to_amount     => x_to_amount,
      p_from_amount2  => l_from_dummy,
      x_to_amount2    => l_to_dummy,
      p_round         => p_round);
END Convert_Currency;

---------------------------------------------------------------------
-- PROCEDURE
--    Convert_Currency2
-- DESCRIPTION
--    This procedure is copied from GL_CURRENCY_API so that rounding can be
--    controlled.  The functional currency need not be rounded because
--    precision will be lost when converting to other currencies.
--    The displayed currencies must be rounded.
-- NOTE
--    Modified from code done by ptendulk, and choang.
-- HISTORY
-- 09-Aug-2001 dmvincen      Created.
-- 18-Dec-2001 dmvincen      Removed rounding when p_round is false.
---------------------------------------------------------------------
PROCEDURE Convert_Currency2 (
   x_return_status      OUT NOCOPY VARCHAR2,
   p_from_currency      IN  VARCHAR2,
   p_to_currency        IN  VARCHAR2,
   p_conv_date          IN  DATE,
   p_from_amount        IN  NUMBER,
   x_to_amount          OUT NOCOPY NUMBER,
   p_from_amount2       IN  NUMBER,
   x_to_amount2         OUT NOCOPY NUMBER,
   p_round              IN VARCHAR2
)
IS
   L_CONVERSION_TYPE_PROFILE  CONSTANT VARCHAR2(30) := 'AMS_CURR_CONVERSION_TYPE';
   L_MAX_ROLL_DAYS         CONSTANT NUMBER := -1;  -- Negative so API rolls back to find the last conversion rate.
   l_denominator           NUMBER;  -- Not used in Marketing.
   l_numerator             NUMBER;  -- Not used in Marketing.
   l_rate                  NUMBER;  -- Not used in Marketing.
   to_rate                 NUMBER;
   to_mau                  NUMBER;
   to_xau                  NUMBER;
   to_type                 VARCHAR2(8);
   l_conversion_type       VARCHAR2(30);  -- Currency conversion type; see API documention for details.
BEGIN
   -- Initialize return status.
   x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

   -- Get the currency conversion type from profile option
   l_conversion_type := Fnd_Profile.Value (L_CONVERSION_TYPE_PROFILE);

   -- Check if both currencies are identical
   IF ( p_from_currency = p_to_currency ) THEN
--       l_denominator      := 1;
--       l_numerator        := 1;
--       l_rate             := 1;
      IF p_round = Fnd_Api.G_TRUE THEN
         get_info( p_to_currency, to_mau, to_xau );
         IF p_from_amount IS NOT NULL THEN
            x_to_amount := ROUND( p_from_amount / to_mau ) * to_mau;
         END IF;
         IF p_from_amount2 IS NOT NULL THEN
            x_to_amount2 := ROUND( p_from_amount2 / to_mau ) * to_mau;
         END IF;
      ELSE
          x_to_amount := p_from_amount;
          x_to_amount2 := p_from_amount2;
      END IF;
      RETURN;
   END IF;

   -- Get currency information from the to_currency ( for use in rounding )
   get_info ( p_to_currency, to_mau, to_xau );

   --
   -- Find out the conversion rate using the given conversion type
   -- and conversion date.
   --
   Gl_Currency_Api.get_closest_triangulation_rate(
                     p_from_currency,
                     p_to_currency,
                     p_conv_date,
                     l_conversion_type,
                     L_MAX_ROLL_DAYS,
                     l_denominator,
                     l_numerator,
                     l_rate );

   -- Calculate the converted amount using triangulation method
   x_to_amount := ( p_from_amount / l_denominator ) * l_numerator;
   x_to_amount2 := ( p_from_amount2 / l_denominator ) * l_numerator;

   IF p_round = Fnd_Api.G_TRUE THEN
      -- Rounding to the correct precision and minumum accountable units
      x_to_amount := ROUND( x_to_amount / to_mau ) * to_mau;
      x_to_amount2 := ROUND( x_to_amount2 / to_mau ) * to_mau;
   END IF;

EXCEPTION
   WHEN Gl_Currency_Api.NO_RATE THEN
      IF Fnd_Msg_Pub.Check_Msg_Level (Fnd_Msg_Pub.G_MSG_LVL_ERROR) THEN
         Fnd_Message.Set_Name ('AMS', 'AMS_NO_RATE');
         Fnd_Message.Set_Token ('CURRENCY_FROM', p_from_currency);
         Fnd_Message.Set_Token ('CURRENCY_TO', p_to_currency);
         Fnd_Msg_Pub.ADD;
      END IF;
      x_return_status := Fnd_Api.G_RET_STS_ERROR;
   WHEN Gl_Currency_Api.INVALID_CURRENCY THEN
      IF Fnd_Msg_Pub.Check_Msg_Level (Fnd_Msg_Pub.G_MSG_LVL_ERROR) THEN
         Fnd_Message.Set_Name ('AMS', 'AMS_INVALID_CURR');
         Fnd_Message.Set_Token ('CURRENCY_FROM', p_from_currency);
         Fnd_Message.Set_Token ('CURRENCY_TO', p_to_currency);
         Fnd_Msg_Pub.ADD;
      END IF;
      x_return_status := Fnd_Api.G_RET_STS_ERROR;
END Convert_Currency2;

---------------------------------------------------------------------
-- PROCEDURE
--    Convert_Currency_Vector
-- DESCRIPTION
--    This procedure is copied from GL_CURRENCY_API so that rounding can be
--    controlled.  The functional currency need not be rounded because
--    precision will be lost when converting to other currencies.
--    The displayed currencies must be rounded.
--    Supports converting a vector of currency amount.
-- NOTE
--    Modified from code done by ptendulk, and choang.
-- HISTORY
-- 05-Dec-2001 dmvincen      Created.
-- 18-Dec-2001 dmvincen      Removed unnecessary rounding.
---------------------------------------------------------------------
PROCEDURE Convert_Currency_Vector (
   x_return_status      OUT NOCOPY VARCHAR2,
   p_from_currency      IN  VARCHAR2,
   p_to_currency        IN  VARCHAR2,
   p_conv_date          IN  DATE,
   p_amounts            IN OUT NOCOPY CURRENCY_TABLE,
   p_round              IN VARCHAR2
)
IS
   L_CONVERSION_TYPE_PROFILE  CONSTANT VARCHAR2(30) := 'AMS_CURR_CONVERSION_TYPE';
   L_MAX_ROLL_DAYS         CONSTANT NUMBER := -1;  -- Negative so API rolls back to find the last conversion rate.
   l_denominator           NUMBER := 1;
   l_numerator             NUMBER := 1;
   l_rate                  NUMBER := 1;
   to_rate                 NUMBER;
   to_mau                  NUMBER;
   to_xau                  NUMBER;
   to_type                 VARCHAR2(8);
   l_conversion_type       VARCHAR2(30);  -- Currency conversion type; see API documention for details.
   l_index                 NUMBER;
BEGIN
   -- Initialize return status.
   x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

   -- Get the currency conversion type from profile option
   l_conversion_type := Fnd_Profile.Value (L_CONVERSION_TYPE_PROFILE);

   -- Check if both currencies are identical
   IF ( p_from_currency <> p_to_currency ) THEN
      --
      -- Find out the conversion rate using the given conversion type
      -- and conversion date.
      --
      Gl_Currency_Api.get_closest_triangulation_rate(
                        p_from_currency,
                        p_to_currency,
                        p_conv_date,
                        l_conversion_type,
                        L_MAX_ROLL_DAYS,
                        l_denominator,
                        l_numerator,
                        l_rate );
   END IF;

   get_info( p_to_currency, to_mau, to_xau );

   l_index := p_amounts.first;
   LOOP
      EXIT WHEN l_index IS NULL;
      IF p_amounts.EXISTS(l_index) AND p_amounts(l_index) IS NOT NULL THEN
         p_amounts(l_index) := ( p_amounts(l_index) / l_denominator ) * l_numerator;
         IF p_round = Fnd_Api.G_TRUE THEN
            p_amounts(l_index) := ROUND( p_amounts(l_index) / to_mau ) * to_mau;
         END IF;
      END IF;
      l_index := p_amounts.NEXT(l_index);
   END LOOP;

EXCEPTION
   WHEN Gl_Currency_Api.NO_RATE THEN
      IF Fnd_Msg_Pub.Check_Msg_Level (Fnd_Msg_Pub.G_MSG_LVL_ERROR) THEN
         Fnd_Message.Set_Name ('AMS', 'AMS_NO_RATE');
         Fnd_Message.Set_Token ('CURRENCY_FROM', p_from_currency);
         Fnd_Message.Set_Token ('CURRENCY_TO', p_to_currency);
         Fnd_Msg_Pub.ADD;
      END IF;
      x_return_status := Fnd_Api.G_RET_STS_ERROR;
   WHEN Gl_Currency_Api.INVALID_CURRENCY THEN
      IF Fnd_Msg_Pub.Check_Msg_Level (Fnd_Msg_Pub.G_MSG_LVL_ERROR) THEN
         Fnd_Message.Set_Name ('AMS', 'AMS_INVALID_CURR');
         Fnd_Message.Set_Token ('CURRENCY_FROM', p_from_currency);
         Fnd_Message.Set_Token ('CURRENCY_TO', p_to_currency);
         Fnd_Msg_Pub.ADD;
      END IF;
      x_return_status := Fnd_Api.G_RET_STS_ERROR;
END Convert_Currency_Vector;

---------------------------------------------------------------------
-- PROCEDURE
--    Convert_Currency_Object
-- DESCRIPTION
--    This procedure is copied from GL_CURRENCY_API so that rounding can be
--    controlled.  The functional currency need not be rounded because
--    precision will be lost when converting to other currencies.
--    The displayed currencies must be rounded.
--    Supports converting amount to transaction currency of object.
-- NOTE
--    Modified from code done by ptendulk, and choang.
-- HISTORY
-- 05-Dec-2001 dmvincen      Created.
---------------------------------------------------------------------
PROCEDURE Convert_Currency_Object (
   x_return_status      OUT NOCOPY VARCHAR2,
   p_object_id          IN  NUMBER,
   p_object_type        IN  VARCHAR2,
   p_conv_date          IN  DATE,
   p_amounts            IN OUT NOCOPY CURRENCY_TABLE,
   p_round              IN VARCHAR2
)
IS
   l_func_currency VARCHAR2(15);
   l_trans_currency VARCHAR2(15);
BEGIN
   l_func_currency := Default_Func_Currency;
   Get_Trans_curr_code(p_object_id, p_object_type, l_trans_currency);
   Convert_Currency_Vector (
      x_return_status      => x_return_status,
      p_from_currency      => l_func_currency,
      p_to_currency        => l_trans_currency,
      p_conv_date          => p_conv_date,
      p_amounts            => p_amounts,
      p_round              => p_round);
END Convert_Currency_Object;

---------------------------------------------------------------------
-- PROCEDURE
--    Convert_to_trans_value
-- DESCRIPTION
--    For chart support to convert to transaction value within a query.
-- NOTE
-- HISTORY
-- 19-APR-2004 dmvincen      Created.
---------------------------------------------------------------------
FUNCTION convert_to_trans_value(
   p_func_value in NUMBER,
   p_object_type in VARCHAR2,
   p_object_id in NUMBER,
   p_display_type in VARCHAR2
   )
RETURN NUMBER
IS
  l_trans_curr_code VARCHAR2(15);
  l_func_curr_code VARCHAR2(15);
  l_return_value NUMBER;
  l_return_status VARCHAR2(1);
BEGIN
 IF (p_display_type = 'CURRENCY')
 THEN
    get_trans_curr_code(p_object_id,p_object_type,l_trans_curr_code);
    l_func_curr_code := default_func_currency;
    IF (NVL(l_trans_curr_code,'NULL') <> NVL(l_func_curr_code,'NULL'))
    THEN
       convert_currency(
                  x_return_status   => l_return_status,
                  p_from_currency   => l_func_curr_code,
                  p_to_currency     => l_trans_curr_code,
                  p_from_amount     => NVL(p_func_value,0),
                  x_to_amount       => l_return_value,
                  p_round           => Fnd_Api.G_TRUE
       );
    ELSE
       l_return_value := p_func_value;
    END IF;
 ELSIF (p_display_type = 'PERCENT')
 THEN
    l_return_value := p_func_value * 100;
 ELSE -- INTEGER
    l_return_value := p_func_value;
 END IF;
 return l_return_value;
END;

---------------------------------------------------------------------
-- PROCEDURE
--    Record_History
-- DESCRIPTION
--    Record changes in the activity metrics for a historical record.
--    Functional values are the only significant items.
--    Historical records are record once per day.  The last value of the
--    day is stored.
--    p_action is in G_CREATE, G_UPDATE, G_DELETE
-- NOTE
-- HISTORY
-- 20-NOV-2001 dmvincen      Created.
-- 06-FEB-2002 dmvincen      BUG2214496: Corrected history delta calculation.
---------------------------------------------------------------------
PROCEDURE Record_History(
   p_actmet_id                  IN NUMBER,
   p_action                     IN VARCHAR2,
   x_return_status              OUT NOCOPY VARCHAR2,
   x_msg_count                  OUT NOCOPY NUMBER,
   x_msg_data                   OUT NOCOPY VARCHAR2
)
IS
   L_API_VERSION    CONSTANT NUMBER := 1.0;
   L_API_NAME       CONSTANT VARCHAR2(30) := 'Record_History';
   L_FULL_NAME      CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

   -- find the most recent fact record for the activity metric id.
   CURSOR c_get_history_by_id(l_act_metric_id NUMBER) IS
      SELECT func_forecasted_value, func_actual_value, functional_currency_code,
             last_update_date, act_met_hst_id, object_version_number,
             func_forecasted_delta, func_actual_delta
      FROM ams_act_metric_hst
      WHERE activity_metric_id = l_act_metric_id
      AND last_update_date =
          (SELECT MAX(last_update_date)
            FROM ams_act_metric_hst
            WHERE activity_metric_id = l_act_metric_id);

   CURSOR c_actmet_details(l_act_metric_id NUMBER) IS
       SELECT  activity_metric_id,
                 last_update_date,
                 last_updated_by,
                 creation_date,
                 created_by,
                 last_update_login,
                 object_version_number,
                 act_metric_used_by_id,
                 arc_act_metric_used_by,
                 purchase_req_raised_flag,
                 application_id,
                 sensitive_data_flag,
                 budget_id,
                 metric_id,
                 transaction_currency_code,
                 trans_forecasted_value,
                 trans_committed_value,
                 trans_actual_value,
                 functional_currency_code,
                 func_forecasted_value,
                 dirty_flag,
                 func_committed_value,
                 func_actual_value,
                 last_update_date,
                 variable_value,
                 forecasted_variable_value,
                 computed_using_function_value,
                 metric_uom_code,
                 org_id,
                 difference_since_last_calc,
                 activity_metric_origin_id,
                 arc_activity_metric_origin,
                 days_since_last_refresh,
                 scenario_id,
                 SUMMARIZE_TO_METRIC,
                 ROLLUP_TO_METRIC,
                 hierarchy_id,
                 start_node,
                 from_level,
                 to_level,
                 from_date,
                 TO_DATE,
                 amount1,
                 amount2,
                 amount3,
                 percent1,
                 percent2,
                 percent3,
                 published_flag,
                 pre_function_name ,
                 post_function_name,
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
                 description,
                 act_metric_date,
                 depend_act_metric,
                 function_used_by_id,
                 arc_function_used_by,
                 /* 05/15/2002 yzhao: add 6 new columns for top-down bottom-up budgeting */
                 hierarchy_type,
                 status_code,
                 method_code,
                 action_code,
                 basis_year,
                 ex_start_node
                 /* 05/15/2002 yzhao: add ends */
     FROM ams_act_metrics_all
     WHERE activity_metric_id = l_act_metric_id;

   CURSOR c_get_new_history_id IS
      SELECT ams_act_metric_hst_s.NEXTVAL
      FROM dual;

   CURSOR c_check_history_id(l_test_id NUMBER) IS
      SELECT COUNT(*)
      FROM ams_act_metric_hst
      WHERE act_met_hst_id = l_test_id;

   l_func_forecasted_value NUMBER;
   l_func_actual_value NUMBER;
   l_functional_currency_code VARCHAR2(15);
   l_last_update_date DATE;
   l_new_record CHAR(1) := FND_API.G_FALSE;
   l_act_met_hst_id NUMBER;
   l_history_id_count NUMBER;
   l_object_version_number NUMBER;
   l_func_forecasted_delta NUMBER;
   l_func_actual_delta NUMBER;
   l_today DATE;
   l_actmet_rec act_metric_rec_type;
   error_message VARCHAR2(2000);
BEGIN

   --
   -- Initialize API return status to success.
   --
   x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

   OPEN c_actmet_details(p_actmet_id);
   FETCH c_actmet_details INTO l_actmet_rec;
   IF c_actmet_details%NOTFOUND THEN
      CLOSE c_actmet_details;
      RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
   END IF;
   CLOSE c_actmet_details;

   -- BUG2813600: Delete history, set to current date and zero.
   IF p_action = G_DELETE THEN
      l_actmet_rec.last_update_date := SYSDATE;
      l_actmet_rec.func_forecasted_value := 0;
      l_actmet_rec.trans_forecasted_value := 0;
      l_actmet_rec.func_actual_value := 0;
      l_actmet_rec.trans_actual_value := 0;
      l_actmet_rec.func_committed_value := 0;
      l_actmet_rec.trans_committed_value := 0;
      l_actmet_rec.VARIABLE_VALUE := 0;
      l_actmet_rec.FORECASTED_VARIABLE_VALUE := 0;
      l_actmet_rec.COMPUTED_USING_FUNCTION_VALUE := 0;
   END IF;
   -- BUG2813600: end.

   IF p_action = G_CREATE THEN
      l_new_record := FND_API.G_TRUE;
      l_func_forecasted_delta := NVL(l_actmet_rec.func_forecasted_value,0);
      l_func_actual_delta := NVL(l_actmet_rec.func_actual_value,0);
   ELSE
      OPEN c_get_history_by_id(p_actmet_id);
      FETCH c_get_history_by_id
         INTO l_func_forecasted_value,
              l_func_actual_value,
              l_functional_currency_code,
              l_last_update_date,
              l_act_met_hst_id,
              l_object_version_number,
              l_func_forecasted_delta,
              l_func_actual_delta;
      IF c_get_history_by_id%NOTFOUND THEN
         l_new_record := FND_API.G_TRUE;
      END IF;
      CLOSE c_get_history_by_id;
   END IF;

   -- Validate a change since the last fact.
   IF l_new_record = FND_API.G_FALSE AND
      (p_action = G_DELETE OR
       NVL(l_func_forecasted_value,0) <>
            NVL(l_actmet_rec.func_forecasted_value,0) OR
       NVL(l_func_actual_value,0) <> NVL(l_actmet_rec.func_actual_value,0) OR
       NVL(l_functional_currency_code,'NULL') <>
            NVL(l_actmet_rec.functional_currency_code,'NULL'))
   THEN
      -- If change occurs within the same day as last, update.
      IF TRUNC(l_last_update_date) = TRUNC(l_actmet_rec.last_update_date)
      THEN
         -- update the current history record.
         -- l_actmet_rec := p_actmet_rec;
         -- BUG2214496: Wrap values with nvl.
         l_func_forecasted_delta := NVL(l_func_forecasted_delta,0) +
                                    NVL(l_actmet_rec.func_forecasted_value,0) -
                                    NVL(l_func_forecasted_value,0);
         l_func_actual_delta := NVL(l_func_actual_delta,0) +
                                NVL(l_actmet_rec.func_actual_value,0) -
                                NVL(l_func_actual_value,0);
         UPDATE ams_act_metric_hst
         SET LAST_UPDATE_DATE = l_actmet_rec.LAST_UPDATE_DATE,
            LAST_UPDATED_BY = l_actmet_rec.LAST_UPDATED_BY,
            CREATION_DATE = l_actmet_rec.CREATION_DATE,
            CREATED_BY = l_actmet_rec.CREATED_BY,
            LAST_UPDATE_LOGIN = l_actmet_rec.LAST_UPDATE_LOGIN,
            OBJECT_VERSION_NUMBER = l_actmet_rec.OBJECT_VERSION_NUMBER,
            ACT_METRIC_USED_BY_ID = l_actmet_rec.ACT_METRIC_USED_BY_ID,
            ARC_ACT_METRIC_USED_BY = l_actmet_rec.ARC_ACT_METRIC_USED_BY,
            APPLICATION_ID = l_actmet_rec.APPLICATION_ID,
            METRIC_ID = l_actmet_rec.METRIC_ID,
            TRANSACTION_CURRENCY_CODE = l_actmet_rec.TRANSACTION_CURRENCY_CODE,
            TRANS_FORECASTED_VALUE = l_actmet_rec.TRANS_FORECASTED_VALUE,
            TRANS_COMMITTED_VALUE = l_actmet_rec.TRANS_COMMITTED_VALUE,
            TRANS_ACTUAL_VALUE = l_actmet_rec.TRANS_ACTUAL_VALUE,
            FUNCTIONAL_CURRENCY_CODE = l_actmet_rec.FUNCTIONAL_CURRENCY_CODE,
            FUNC_FORECASTED_VALUE = l_actmet_rec.FUNC_FORECASTED_VALUE,
            FUNC_COMMITTED_VALUE = l_actmet_rec.FUNC_COMMITTED_VALUE,
            DIRTY_FLAG = l_actmet_rec.DIRTY_FLAG,
            FUNC_ACTUAL_VALUE = l_actmet_rec.FUNC_ACTUAL_VALUE,
            LAST_CALCULATED_DATE = l_actmet_rec.LAST_CALCULATED_DATE,
            VARIABLE_VALUE = l_actmet_rec.VARIABLE_VALUE,
            COMPUTED_USING_FUNCTION_VALUE = l_actmet_rec.COMPUTED_USING_FUNCTION_VALUE,
            METRIC_UOM_CODE = l_actmet_rec.METRIC_UOM_CODE,
            ORG_ID = l_actmet_rec.ORG_ID,
            DIFFERENCE_SINCE_LAST_CALC = l_actmet_rec.DIFFERENCE_SINCE_LAST_CALC,
            ACTIVITY_METRIC_ORIGIN_ID = l_actmet_rec.ACTIVITY_METRIC_ORIGIN_ID,
            ARC_ACTIVITY_METRIC_ORIGIN = l_actmet_rec.ARC_ACTIVITY_METRIC_ORIGIN,
            DAYS_SINCE_LAST_REFRESH = l_actmet_rec.DAYS_SINCE_LAST_REFRESH,
            SUMMARIZE_TO_METRIC = l_actmet_rec.SUMMARIZE_TO_METRIC,
            ROLLUP_TO_METRIC = l_actmet_rec.ROLLUP_TO_METRIC,
            SCENARIO_ID = l_actmet_rec.SCENARIO_ID,
            ATTRIBUTE_CATEGORY = l_actmet_rec.ATTRIBUTE_CATEGORY,
            ATTRIBUTE1 = l_actmet_rec.ATTRIBUTE1,
            ATTRIBUTE2 = l_actmet_rec.ATTRIBUTE2,
            ATTRIBUTE3 = l_actmet_rec.ATTRIBUTE3,
            ATTRIBUTE4 = l_actmet_rec.ATTRIBUTE4,
            ATTRIBUTE5 = l_actmet_rec.ATTRIBUTE5,
            ATTRIBUTE6 = l_actmet_rec.ATTRIBUTE6,
            ATTRIBUTE7 = l_actmet_rec.ATTRIBUTE7,
            ATTRIBUTE8 = l_actmet_rec.ATTRIBUTE8,
            ATTRIBUTE9 = l_actmet_rec.ATTRIBUTE9,
            ATTRIBUTE10 = l_actmet_rec.ATTRIBUTE10,
            ATTRIBUTE11 = l_actmet_rec.ATTRIBUTE11,
            ATTRIBUTE12 = l_actmet_rec.ATTRIBUTE12,
            ATTRIBUTE13 = l_actmet_rec.ATTRIBUTE13,
            ATTRIBUTE14 = l_actmet_rec.ATTRIBUTE14,
            ATTRIBUTE15 = l_actmet_rec.ATTRIBUTE15,
            DESCRIPTION = l_actmet_rec.DESCRIPTION,
            ACT_METRIC_DATE = l_actmet_rec.ACT_METRIC_DATE,
            ARC_FUNCTION_USED_BY = l_actmet_rec.ARC_FUNCTION_USED_BY,
            FUNCTION_USED_BY_ID = l_actmet_rec.FUNCTION_USED_BY_ID,
            PURCHASE_REQ_RAISED_FLAG = l_actmet_rec.PURCHASE_REQ_RAISED_FLAG,
            SENSITIVE_DATA_FLAG = l_actmet_rec.SENSITIVE_DATA_FLAG,
            BUDGET_ID = l_actmet_rec.BUDGET_ID,
            FORECASTED_VARIABLE_VALUE = l_actmet_rec.FORECASTED_VARIABLE_VALUE,
            HIERARCHY_ID = l_actmet_rec.HIERARCHY_ID,
            PUBLISHED_FLAG = l_actmet_rec.PUBLISHED_FLAG,
            PRE_FUNCTION_NAME = l_actmet_rec.PRE_FUNCTION_NAME,
            POST_FUNCTION_NAME = l_actmet_rec.POST_FUNCTION_NAME,
            START_NODE = l_actmet_rec.START_NODE,
            FROM_LEVEL = l_actmet_rec.FROM_LEVEL,
            TO_LEVEL = l_actmet_rec.TO_LEVEL,
            FROM_DATE = l_actmet_rec.FROM_DATE,
            TO_DATE = l_actmet_rec.TO_DATE,
            AMOUNT1 = l_actmet_rec.AMOUNT1,
            AMOUNT2 = l_actmet_rec.AMOUNT2,
            AMOUNT3 = l_actmet_rec.AMOUNT3,
            PERCENT1 = l_actmet_rec.PERCENT1,
            PERCENT2 = l_actmet_rec.PERCENT2,
            PERCENT3 = l_actmet_rec.PERCENT3,
            STATUS_CODE = l_actmet_rec.STATUS_CODE,
            ACTION_CODE = l_actmet_rec.ACTION_CODE,
            METHOD_CODE = l_actmet_rec.METHOD_CODE,
            BASIS_YEAR = l_actmet_rec.BASIS_YEAR,
            EX_START_NODE = l_actmet_rec.EX_START_NODE,
            HIERARCHY_TYPE = l_actmet_rec.HIERARCHY_TYPE,
            DEPEND_ACT_METRIC = l_actmet_rec.DEPEND_ACT_METRIC,
            FUNC_FORECASTED_DELTA = l_func_forecasted_delta,
            FUNC_ACTUAL_DELTA = l_func_actual_delta
         WHERE act_met_hst_id = l_act_met_hst_id
         AND object_version_number = l_object_version_number;
      ELSE
         -- Values have not changed since yesterday, insert for today.
         l_new_record := FND_API.G_TRUE;
      END IF;
   END IF;

   IF l_new_record = FND_API.G_TRUE THEN
      -- Generate a new fact id.
      LOOP
          OPEN c_get_new_history_id;
          FETCH c_get_new_history_id INTO l_act_met_hst_id;
          CLOSE c_get_new_history_id;

          -- Validate uniqueness.
          OPEN c_check_history_id(l_act_met_hst_id);
          FETCH c_check_history_id INTO l_history_id_count;
          CLOSE c_check_history_id;

          EXIT WHEN l_history_id_count = 0;
      END LOOP;

      -- BUG2214496: Wrap values with nvl.
      l_func_forecasted_delta := NVL(l_actmet_rec.func_forecasted_value,0) -
                                 NVL(l_func_forecasted_value,0);
      l_func_actual_delta := NVL(l_actmet_rec.func_actual_value,0) -
                             NVL(l_func_actual_value,0);

      -- Insert a new fact record.
      INSERT INTO ams_act_metric_hst
         (ACT_MET_HST_ID,
         ACTIVITY_METRIC_ID,
         LAST_UPDATE_DATE,
         LAST_UPDATED_BY,
         CREATION_DATE,
         CREATED_BY,
         LAST_UPDATE_LOGIN,
         OBJECT_VERSION_NUMBER,
         ACT_METRIC_USED_BY_ID,
         ARC_ACT_METRIC_USED_BY,
         APPLICATION_ID,
         METRIC_ID,
         TRANSACTION_CURRENCY_CODE,
         TRANS_FORECASTED_VALUE,
         TRANS_COMMITTED_VALUE,
         TRANS_ACTUAL_VALUE,
         FUNCTIONAL_CURRENCY_CODE,
         FUNC_FORECASTED_VALUE,
         FUNC_COMMITTED_VALUE,
         DIRTY_FLAG,
         FUNC_ACTUAL_VALUE,
         LAST_CALCULATED_DATE,
         VARIABLE_VALUE,
         COMPUTED_USING_FUNCTION_VALUE,
         METRIC_UOM_CODE,
         ORG_ID,
         DIFFERENCE_SINCE_LAST_CALC,
         ACTIVITY_METRIC_ORIGIN_ID,
         ARC_ACTIVITY_METRIC_ORIGIN,
         DAYS_SINCE_LAST_REFRESH,
         SUMMARIZE_TO_METRIC,
         ROLLUP_TO_METRIC,
         SCENARIO_ID,
         ATTRIBUTE_CATEGORY,
         ATTRIBUTE1,
         ATTRIBUTE2,
         ATTRIBUTE3,
         ATTRIBUTE4,
         ATTRIBUTE5,
         ATTRIBUTE6,
         ATTRIBUTE7,
         ATTRIBUTE8,
         ATTRIBUTE9,
         ATTRIBUTE10,
         ATTRIBUTE11,
         ATTRIBUTE12,
         ATTRIBUTE13,
         ATTRIBUTE14,
         ATTRIBUTE15,
         DESCRIPTION,
         ACT_METRIC_DATE,
         ARC_FUNCTION_USED_BY,
         FUNCTION_USED_BY_ID,
         PURCHASE_REQ_RAISED_FLAG,
         SENSITIVE_DATA_FLAG,
         BUDGET_ID,
         FORECASTED_VARIABLE_VALUE,
         HIERARCHY_ID,
         PUBLISHED_FLAG,
         PRE_FUNCTION_NAME,
         POST_FUNCTION_NAME,
         START_NODE,
         FROM_LEVEL,
         TO_LEVEL,
         FROM_DATE,
         TO_DATE,
         AMOUNT1,
         AMOUNT2,
         AMOUNT3,
         PERCENT1,
         PERCENT2,
         PERCENT3,
         STATUS_CODE,
         ACTION_CODE,
         METHOD_CODE,
         BASIS_YEAR,
         EX_START_NODE,
         HIERARCHY_TYPE,
         DEPEND_ACT_METRIC,
         FUNC_FORECASTED_DELTA,
         FUNC_ACTUAL_DELTA)
      VALUES
         (L_ACT_MET_HST_ID,
         l_actmet_rec.ACTIVITY_METRIC_ID,
         l_actmet_rec.LAST_UPDATE_DATE,
         l_actmet_rec.LAST_UPDATED_BY,
         l_actmet_rec.CREATION_DATE,
         l_actmet_rec.CREATED_BY,
         l_actmet_rec.LAST_UPDATE_LOGIN,
         l_actmet_rec.OBJECT_VERSION_NUMBER,
         l_actmet_rec.ACT_METRIC_USED_BY_ID,
         l_actmet_rec.ARC_ACT_METRIC_USED_BY,
         l_actmet_rec.APPLICATION_ID,
         l_actmet_rec.METRIC_ID,
         l_actmet_rec.TRANSACTION_CURRENCY_CODE,
         l_actmet_rec.TRANS_FORECASTED_VALUE,
         l_actmet_rec.TRANS_COMMITTED_VALUE,
         l_actmet_rec.TRANS_ACTUAL_VALUE,
         l_actmet_rec.FUNCTIONAL_CURRENCY_CODE,
         l_actmet_rec.FUNC_FORECASTED_VALUE,
         l_actmet_rec.FUNC_COMMITTED_VALUE,
         l_actmet_rec.DIRTY_FLAG,
         l_actmet_rec.FUNC_ACTUAL_VALUE,
         l_actmet_rec.LAST_CALCULATED_DATE,
         l_actmet_rec.VARIABLE_VALUE,
         l_actmet_rec.COMPUTED_USING_FUNCTION_VALUE,
         l_actmet_rec.METRIC_UOM_CODE,
         l_actmet_rec.ORG_ID,
         l_actmet_rec.DIFFERENCE_SINCE_LAST_CALC,
         l_actmet_rec.ACTIVITY_METRIC_ORIGIN_ID,
         l_actmet_rec.ARC_ACTIVITY_METRIC_ORIGIN,
         l_actmet_rec.DAYS_SINCE_LAST_REFRESH,
         l_actmet_rec.SUMMARIZE_TO_METRIC,
         l_actmet_rec.ROLLUP_TO_METRIC,
         l_actmet_rec.SCENARIO_ID,
         l_actmet_rec.ATTRIBUTE_CATEGORY,
         l_actmet_rec.ATTRIBUTE1,
         l_actmet_rec.ATTRIBUTE2,
         l_actmet_rec.ATTRIBUTE3,
         l_actmet_rec.ATTRIBUTE4,
         l_actmet_rec.ATTRIBUTE5,
         l_actmet_rec.ATTRIBUTE6,
         l_actmet_rec.ATTRIBUTE7,
         l_actmet_rec.ATTRIBUTE8,
         l_actmet_rec.ATTRIBUTE9,
         l_actmet_rec.ATTRIBUTE10,
         l_actmet_rec.ATTRIBUTE11,
         l_actmet_rec.ATTRIBUTE12,
         l_actmet_rec.ATTRIBUTE13,
         l_actmet_rec.ATTRIBUTE14,
         l_actmet_rec.ATTRIBUTE15,
         l_actmet_rec.DESCRIPTION,
         l_actmet_rec.ACT_METRIC_DATE,
         l_actmet_rec.ARC_FUNCTION_USED_BY,
         l_actmet_rec.FUNCTION_USED_BY_ID,
         l_actmet_rec.PURCHASE_REQ_RAISED_FLAG,
         l_actmet_rec.SENSITIVE_DATA_FLAG,
         l_actmet_rec.BUDGET_ID,
         l_actmet_rec.FORECASTED_VARIABLE_VALUE,
         l_actmet_rec.HIERARCHY_ID,
         l_actmet_rec.PUBLISHED_FLAG,
         l_actmet_rec.PRE_FUNCTION_NAME,
         l_actmet_rec.POST_FUNCTION_NAME,
         l_actmet_rec.START_NODE,
         l_actmet_rec.FROM_LEVEL,
         l_actmet_rec.TO_LEVEL,
         l_actmet_rec.FROM_DATE,
         l_actmet_rec.TO_DATE,
         l_actmet_rec.AMOUNT1,
         l_actmet_rec.AMOUNT2,
         l_actmet_rec.AMOUNT3,
         l_actmet_rec.PERCENT1,
         l_actmet_rec.PERCENT2,
         l_actmet_rec.PERCENT3,
         l_actmet_rec.STATUS_CODE,
         l_actmet_rec.ACTION_CODE,
         l_actmet_rec.METHOD_CODE,
         l_actmet_rec.BASIS_YEAR,
         l_actmet_rec.EX_START_NODE,
         l_actmet_rec.HIERARCHY_TYPE,
         l_actmet_rec.DEPEND_ACT_METRIC,
         l_func_forecasted_delta,
         l_func_actual_delta
         );
   END IF;

EXCEPTION
   WHEN Fnd_Api.G_EXC_ERROR THEN
      x_return_status := Fnd_Api.G_RET_STS_ERROR;
      Fnd_Msg_Pub.Count_And_Get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data,
         p_encoded       =>   FND_API.G_FALSE
      );
   WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      Fnd_Msg_Pub.Count_And_Get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data,
         p_encoded       =>   FND_API.G_FALSE
      );
   WHEN OTHERS THEN
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      error_message := SQLERRM;
      IF Fnd_Msg_Pub.Check_Msg_Level (Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR) THEN
         Fnd_Msg_Pub.Add_Exc_Msg (G_PKG_NAME, L_API_NAME);
      END IF;
      Fnd_Msg_Pub.Count_And_Get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data,
         p_encoded       =>   FND_API.G_FALSE
      );
END Record_History;

-- API Name       Get_Date_Buckets
-- Type           Public
-- Pre-reqs       None.
-- Function       Generate date buckets according to the start date, end date
--                and time interval.
-- Parameters
--    IN          p_start_date                  IN DATE       Required
--                p_end_date                    IN DATE       Required
--                p_interval_amount             IN NUMBER     Required
--                p_interval_unit               IN VARCHAR2   Required
--    OUT NOCOPY         x_date_buckets                OUT NOCOPY date_bucket_type
-- Version        Current version: 1.0
--                Previous version: 1.0
--                Initial version: 1.0
-- HISTORY
-- 11/21/2001     huili         Created.
-- 01/25/2006     dmvincen   BUG4669529: Include prior date bucket.
-- End of comments
PROCEDURE Get_Date_Buckets (
   p_start_date       IN  DATE,
   p_end_date         IN  DATE,
   p_interval_amount  IN  NUMBER,
   p_interval_unit    IN  VARCHAR2, -- 'DAY', 'WK', 'MTH', 'YR'
   x_date_buckets     OUT NOCOPY date_bucket_type,
   x_return_status    OUT NOCOPY VARCHAR2
) IS
 l_date_bucket  DATE := null;
 l_date_buckets  date_bucket_type := date_bucket_type();
 l_bucket_count NUMBER := 1;
 l_last_bucket number := null;
 l_max_bucket_count number;
 L_NUM_DAYS_WEEK CONSTANT NUMBER := 7;
 L_NUM_MONTHS_YEAR CONSTANT NUMBER := 12;

BEGIN
 --
   -- Initialize API return status to success.
   --
   x_return_status := FND_API.G_RET_STS_SUCCESS;

 -- BUG 3815334: Use profile for max buckets.
 -- This is the same profile that DCF uses for report page length.
 l_max_bucket_count :=
              nvl(fnd_profile.value('JTF_PROFILE_DEFAULT_NUM_ROWS'),10);
 IF p_start_date IS NULL
  OR p_end_date IS NULL
  OR TRUNC(p_start_date) > TRUNC(p_end_date)
  OR p_interval_amount IS NULL
  OR p_interval_amount < 0
  OR p_interval_unit IS NULL
  OR p_interval_unit NOT IN ('DAY', 'WEEK', 'MONTH', 'YEAR') THEN
  x_return_status := FND_API.G_RET_STS_ERROR;
  RETURN;
 END IF;

  -- Initialize first date bucket to the prior period for incrementals.
   IF p_interval_unit = 'DAY' THEN
     l_date_bucket := p_start_date - p_interval_amount;
   ELSIF p_interval_unit = 'WEEK' THEN
     l_date_bucket := p_start_date - p_interval_amount * L_NUM_DAYS_WEEK;
   ELSIF p_interval_unit = 'MONTH' THEN
     l_date_bucket := ADD_MONTHS (p_start_date, - p_interval_amount);
   ELSIF p_interval_unit = 'YEAR' THEN
     l_date_bucket := ADD_MONTHS (p_start_date, - p_interval_amount *
                                  L_NUM_MONTHS_YEAR);
   END IF;

 l_date_buckets.DELETE;
 --l_bucket_count := l_date_buckets.COUNT + 1;
 l_date_buckets.extend(L_MAX_BUCKET_COUNT+1);
 FOR l_bucket_count in 1..L_MAX_BUCKET_COUNT+1
 LOOP
   l_last_bucket := l_bucket_count;
   l_date_buckets(l_bucket_count) := l_date_bucket;
   IF p_interval_unit = 'DAY' THEN
     l_date_bucket := l_date_bucket + p_interval_amount;
   ELSIF p_interval_unit = 'WEEK' THEN
     l_date_bucket := l_date_bucket + p_interval_amount * L_NUM_DAYS_WEEK;
   ELSIF p_interval_unit = 'MONTH' THEN
     l_date_bucket := ADD_MONTHS (l_date_bucket, p_interval_amount);
   ELSIF p_interval_unit = 'YEAR' THEN
     l_date_bucket := ADD_MONTHS (l_date_bucket, p_interval_amount *
                                  L_NUM_MONTHS_YEAR);
   ELSE
     EXIT;
   END IF;
   EXIT WHEN TRUNC(l_date_bucket) > TRUNC(p_end_date);
 END LOOP;
 l_date_buckets.delete(l_last_bucket+1,l_date_buckets.last);
 x_date_buckets := l_date_buckets;
END;

---------------------------------------------------------------------
-- PROCEDURE
--    Get_Results
-- DESCRIPTION
--    Return the results for results cue card.
--    Output only.  No updates.
-- NOTE
-- HISTORY
-- 27-NOV-2001 dmvincen      Created.
-- 20-DEC-2003 dmvincen  Fixed Deleted metrics show zero for all history.
-- 01-JAN-2006 dmvincen  BUG4669529: Calculate first incremental value.
---------------------------------------------------------------------
PROCEDURE GET_RESULTS(
   p_api_version                IN  NUMBER,
   p_init_msg_list              IN  VARCHAR2 := Fnd_Api.G_FALSE,
   x_return_status              OUT NOCOPY VARCHAR2,
   x_msg_count                  OUT NOCOPY NUMBER,
   x_msg_data                   OUT NOCOPY VARCHAR2,

   p_metric_id IN NUMBER,
   p_object_type IN VARCHAR2,
   p_object_id IN NUMBER,
   p_value_type IN VARCHAR2,
   p_from_date IN DATE,
   p_to_date IN DATE,
   p_increment IN NUMBER,
   p_interval_unit IN VARCHAR2,
   x_result_table OUT NOCOPY result_table
)
IS
   L_API_VERSION    CONSTANT NUMBER := 1.0;
   L_API_NAME       CONSTANT VARCHAR2(30) := 'GET_RESULTS';
   L_FULL_NAME      CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

  CURSOR c_get_hist_details(l_metric_id NUMBER,
                     l_object_type VARCHAR2,
                     l_object_id NUMBER) IS
      SELECT min(last_update_date)
      FROM ams_act_metric_hst
      WHERE metric_id = l_metric_id
      AND arc_act_metric_used_by = l_object_type
      AND act_metric_used_by_id = l_object_id;

  CURSOR c_metric_details(l_metric_id NUMBER) IS
     SELECT metric_calculation_type, metric_category, display_type
     FROM ams_metrics_all_b
     WHERE metric_id = l_metric_id;
  l_metric_details c_metric_details%ROWTYPE;

  CURSOR c_get_slice_manual(l_metric_id NUMBER,
                     l_object_type VARCHAR2,
                     l_object_id NUMBER,
                     l_slice_date DATE) IS
  -- Fixed so deleted activity metrics show correct values.
     SELECT a.last_update_date slice_date,
            a.functional_currency_code currency_code,
            NVL(SUM(a.func_forecasted_value),0) forecasted_value,
            NVL(SUM(a.func_actual_value),0) actual_value
     FROM ams_act_metric_hst a
     WHERE (a.act_met_hst_id, a.activity_metric_id) IN
           (SELECT MAX(b.act_met_hst_id), b.activity_metric_id
            FROM ams_act_metric_hst b
            WHERE b.metric_id = l_metric_id
              AND b.arc_act_metric_used_by = l_object_type
              AND b.act_metric_used_by_id = l_object_id
            AND TRUNC(b.last_update_date) <= TRUNC(l_slice_date)
            GROUP BY b.activity_metric_id)
     GROUP BY a.last_update_date, a.functional_currency_code;

  CURSOR c_get_slice_other(l_metric_id NUMBER,
                     l_object_type VARCHAR2,
                     l_object_id NUMBER,
                     l_slice_date DATE) IS
     SELECT a.last_update_date slice_date,
            a.functional_currency_code currency_code,
            NVL(a.func_forecasted_value,0) forecasted_value,
            NVL(a.func_actual_value,0) actual_value
     FROM ams_act_metric_hst a
     WHERE a.last_update_date =
           (SELECT MAX(b.last_update_date)
            FROM ams_act_metric_hst b
            WHERE b.metric_id = l_metric_id
            AND b.arc_act_metric_used_by = l_object_type
            AND b.act_metric_used_by_id = l_object_id
            AND TRUNC(b.last_update_date) <= TRUNC(l_slice_date))
     AND a.metric_id = l_metric_id
     AND a.arc_act_metric_used_by = l_object_type
     AND a.act_metric_used_by_id = l_object_id;

   l_date_buckets date_bucket_type;
   l_result_table result_table;
   l_result_record result_record;
   l_trans_currency_code VARCHAR2(15);
   l_date_index NUMBER;
   l_result_index NUMBER;
   l_last_forecasted_value NUMBER;
   l_last_actual_value NUMBER;
   l_start_date DATE := NULL;
   l_end_date DATE := NULL;
BEGIN
   --
   -- Output debug message.
   --
   IF (AMS_DEBUG_HIGH_ON) THEN
      Ams_Utility_Pvt.debug_message(l_full_name||': START');
      Ams_Utility_Pvt.debug_message('Generating results FOR object: '||
          p_object_type||':'||p_object_id||', metric id'||p_metric_id);
      Ams_Utility_Pvt.debug_message('FROM/TO/interval/unit: '||
          p_from_date||'/'||p_to_date||'/'||p_increment||'/'||p_interval_unit);
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
   Get_Trans_curr_code
     (p_obj_id            => p_object_id,
      p_obj_type          => p_object_type,
      x_trans_curr_code   => l_trans_currency_code
     );

   OPEN c_metric_details(p_metric_id);
   FETCH c_metric_details INTO l_metric_details;
   IF c_metric_details%NOTFOUND THEN
      CLOSE c_metric_details;
      x_return_status := Fnd_Api.G_RET_STS_ERROR;
      RAISE Fnd_Api.G_EXC_ERROR;
   END IF;
   CLOSE c_metric_details;

   OPEN c_get_hist_details(p_metric_id, p_object_type, p_object_id);
   FETCH c_get_hist_details INTO l_start_date;
   IF c_get_hist_details%NOTFOUND OR l_start_date IS NULL THEN
      CLOSE c_get_hist_details;
      x_return_status := Fnd_Api.G_RET_STS_ERROR;
      RAISE Fnd_Api.G_EXC_ERROR;
   END IF;
   CLOSE c_get_hist_details;

   IF TRUNC(p_from_date) > TRUNC(l_start_date) THEN
      l_start_date := p_from_date;
   END IF;

   IF TRUNC(l_start_date) > TRUNC(p_to_date) THEN
      l_end_date := l_start_date;
   ELSE
      l_end_date := p_to_date;
   END IF;

   IF TRUNC(l_start_date) >= TRUNC(SYSDATE) THEN
      l_start_date := TRUNC(SYSDATE);
   END IF;

   IF TRUNC(l_end_date) >= TRUNC(SYSDATE) THEN
      l_end_date := TRUNC(SYSDATE);
   END IF;

   Get_Date_Buckets (
      p_start_date       => l_start_date,
      p_end_date         => l_end_date,
      p_interval_amount  => p_increment,
      p_interval_unit    => p_interval_unit, -- 'DAY', 'WK', 'MTH', 'YR'
      x_date_buckets     => l_date_buckets,
      x_return_status    => x_return_status
   );
   IF x_return_status = Fnd_Api.G_RET_STS_ERROR THEN
      RETURN;
   END IF;

   l_result_table := result_table();
   l_result_table.extend(l_date_buckets.COUNT);

   l_date_index := l_date_buckets.first;
   l_result_index := l_result_table.first;

   LOOP
      EXIT WHEN l_date_index IS NULL;
      EXIT WHEN l_result_index IS NULL;
      EXIT WHEN NOT l_date_buckets.EXISTS(l_date_index);
      EXIT WHEN NOT l_result_table.EXISTS(l_result_index);
      IF l_metric_details.display_type = 'CURRENCY' THEN
         l_result_record.currency_code := l_trans_currency_code;
      ELSE
         l_result_record.currency_code := NULL;
      END IF;
      l_result_record.forecasted_value := 0;
      l_result_record.actual_value := 0;
      l_result_record.slice_date := l_date_buckets(l_date_index);
      l_result_table(l_result_index) := l_result_record;
      IF l_metric_details.metric_calculation_type = 'MANUAL' THEN
         OPEN c_get_slice_manual(p_metric_id, p_object_type,
                                 p_object_id, l_date_buckets(l_date_index));
         LOOP
            FETCH c_get_slice_manual INTO l_result_record;
            EXIT WHEN c_get_slice_manual%NOTFOUND;
            -- Multiple rows are returned if multiple currencies.
            -- Convert all currencies to the transactional.
            IF l_metric_details.display_type = 'CURRENCY' AND
               l_result_record.currency_code <> l_trans_currency_code
            THEN
               Convert_Currency2 (
                  x_return_status   => x_return_status,
                  p_from_currency   => l_result_record.currency_code,
                  p_to_currency     => l_trans_currency_code,
                  p_from_amount     => NVL(l_result_record.forecasted_value,0),
                  x_to_amount       => l_result_record.forecasted_value,
                  p_from_amount2    => NVL(l_result_record.actual_value,0),
                  x_to_amount2      => l_result_record.actual_value,
                  p_round           => Fnd_Api.G_TRUE
               );
               l_result_record.currency_code := l_trans_currency_code;
            END IF;
            l_result_table(l_result_index).forecasted_value :=
                    l_result_table(l_result_index).forecasted_value +
                    l_result_record.forecasted_value;
            l_result_table(l_result_index).actual_value :=
                    l_result_table(l_result_index).actual_value +
                    l_result_record.actual_value;
         END LOOP;
         CLOSE c_get_slice_manual;
      ELSE -- Other than manual.
         OPEN c_get_slice_other(p_metric_id, p_object_type,
                                p_object_id, l_date_buckets(l_date_index));
         -- Only one row is expected for each date.
         FETCH c_get_slice_other INTO l_result_record;
         IF c_get_slice_other%FOUND THEN
            -- Synchronize the currency to transactional;
            IF l_metric_details.display_type = 'CURRENCY' AND
               l_result_record.currency_code <> l_trans_currency_code
            THEN
               Convert_Currency2 (
                  x_return_status   => x_return_status,
                  p_from_currency   => l_result_record.currency_code,
                  p_to_currency     => l_trans_currency_code,
                  p_from_amount     => NVL(l_result_record.forecasted_value,0),
                  x_to_amount       => l_result_record.forecasted_value,
                  p_from_amount2    => NVL(l_result_record.actual_value,0),
                  x_to_amount2      => l_result_record.actual_value,
                  p_round           => Fnd_Api.G_TRUE
               );
               l_result_record.currency_code := l_trans_currency_code;
            END IF;
            l_result_table(l_result_index) := l_result_record;
         END IF;
         CLOSE c_get_slice_other;
      END IF;
      IF p_value_type = 'INCREMENTAL' THEN
         IF l_date_index = l_date_buckets.first THEN
            l_last_forecasted_value := l_result_table(l_result_index).forecasted_value;
            l_last_actual_value := l_result_table(l_result_index).actual_value;
            l_result_table(l_result_index).forecasted_value := 0;
            l_result_table(l_result_index).actual_value := 0;
         ELSE
            l_result_record := l_result_table(l_result_index);
            l_result_table(l_result_index).forecasted_value :=
               l_result_table(l_result_index).forecasted_value -
               l_last_forecasted_value;
            l_result_table(l_result_index).actual_value :=
               l_result_table(l_result_index).actual_value -
               l_last_actual_value;
            l_last_forecasted_value := l_result_record.forecasted_value;
            l_last_actual_value := l_result_record.actual_value;
         END IF;
      END IF;
      l_result_table(l_result_index).slice_date := l_date_buckets(l_date_index);
      l_date_index := l_date_buckets.NEXT(l_date_index);
      l_result_index := l_result_table.NEXT(l_result_index);
   END LOOP;
   -- Removed the first element because it is the period before the selection.
   l_result_table.delete(l_result_table.first);

   x_result_table := l_result_table;

   IF (AMS_DEBUG_HIGH_ON) THEN
      Ams_Utility_Pvt.debug_message('Generated: '||x_result_table.COUNT||' results');
   END IF;

   --
   -- End API Body
   --

   --
   -- Standard API to get message count, and if 1,
   -- set the message data OUT NOCOPY variable.
   --
   Fnd_Msg_Pub.Count_And_Get (
      p_count           =>    x_msg_count,
      p_data            =>    x_msg_data,
      p_encoded         =>    Fnd_Api.G_FALSE
   );

   --
   -- Debug message.
   --
   IF (AMS_DEBUG_HIGH_ON) THEN
      Ams_Utility_Pvt.debug_message(l_full_name ||': END');
   END IF;

EXCEPTION
   WHEN Fnd_Api.G_EXC_ERROR THEN
      x_return_status := Fnd_Api.G_RET_STS_ERROR;
      Fnd_Msg_Pub.Count_And_Get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data,
         p_encoded       =>   FND_API.G_FALSE
      );
   WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      Fnd_Msg_Pub.Count_And_Get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data,
         p_encoded       =>   FND_API.G_FALSE
      );
   WHEN OTHERS THEN
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      IF Fnd_Msg_Pub.Check_Msg_Level (Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR) THEN
         Fnd_Msg_Pub.Add_Exc_Msg (G_PKG_NAME, L_API_NAME);
      END IF;
      Fnd_Msg_Pub.Count_And_Get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data,
         p_encoded       =>   FND_API.G_FALSE
      );
END get_results;

--======================================================================
-- procedure
--    copy_act_metrics
--
-- PURPOSE
--    Created to copy activity metrics
--
-- HISTORY
--    13-may-2003 sunkumar created
--======================================================================
   procedure copy_act_metrics (
   p_api_version            IN   NUMBER,
   p_init_msg_list          IN   VARCHAR2 := FND_API.G_FALSE,
   p_commit                 IN  VARCHAR2 := Fnd_Api.G_FALSE,
   p_validation_level       IN  NUMBER   := Fnd_Api.G_Valid_Level_Full,
   p_source_object_type     IN   VARCHAR2,
   p_source_object_id       IN   NUMBER,
   p_target_object_id       IN   NUMBER,
   x_return_status          OUT NOCOPY  VARCHAR2,
   x_msg_count              OUT NOCOPY  NUMBER,
   x_msg_data               OUT NOCOPY  VARCHAR2
   )
   IS

    L_API_VERSION          CONSTANT NUMBER := 1.0;
    L_API_NAME             CONSTANT VARCHAR2(30) := 'COPY_ACT_METRICS';
    L_FULL_NAME            CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

    l_return_status        VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;

    l_source_object_type   VARCHAR2(30) := p_source_object_type;
    l_source_object_id     NUMBER := p_source_object_id;
    l_target_object_id     NUMBER := p_target_object_id;

    l_activity_metric_id   NUMBER;
    l_metric_id            NUMBER;
    l_accrual_type         VARCHAR2(30);
    metrics_rec AMS_ACTMETRIC_PVT.act_metric_rec_type;
    x_activity_metric_id   NUMBER;

    --select the details from the source object
     CURSOR c_act_met_details(c_source_object_type varchar2, c_source_object_id NUMBER) IS
       SELECT  activity_metric_id,
                 last_update_date,
                 last_updated_by,
                 creation_date,
                 created_by,
                 last_update_login,
                 object_version_number,
                 act_metric_used_by_id,
                 arc_act_metric_used_by,
                 purchase_req_raised_flag,
                 application_id,
                 sensitive_data_flag,
                 budget_id,
                 metric_id,
                 transaction_currency_code,
                 trans_forecasted_value,
                 trans_committed_value,
                 trans_actual_value,
                 functional_currency_code,
                 func_forecasted_value,
                 dirty_flag,
                 func_committed_value,
                 func_actual_value,
                 last_calculated_date,
                 variable_value,
                 forecasted_variable_value,
                 computed_using_function_value,
                 metric_uom_code,
                 org_id,
                 difference_since_last_calc,
                 activity_metric_origin_id,
                 arc_activity_metric_origin,
                 days_since_last_refresh,
                 scenario_id,
                 SUMMARIZE_TO_METRIC,
                 ROLLUP_TO_METRIC,
                 hierarchy_id,
                 start_node,
                 from_level,
                 to_level,
                 from_date,
                 TO_DATE,
                 amount1,
                 amount2,
                 amount3,
                 percent1,
                 percent2,
                 percent3,
                 published_flag,
                 pre_function_name ,
                 post_function_name,
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
                 description,
                 act_metric_date,
                 depend_act_metric,
                 function_used_by_id,
                 arc_function_used_by,
                 hierarchy_type,
                 status_code,
                 method_code,
                 action_code,
                 basis_year,
                 ex_start_node
     FROM ams_act_metrics_all
     WHERE arc_act_metric_used_by = c_source_object_type
       and act_metric_used_by_id = c_source_object_id;

    -- metrics_rec c_act_met_details%ROWTYPE;
    --check for existance of activity metrics in the target object
    CURSOR c_exist_metric_target (cv_metric_id NUMBER
                                 ,cv_act_metric_used_by_id  NUMBER
                                 ,cv_arc_act_metric_used_by VARCHAR2)    IS

   SELECT activity_metric_id
   FROM   ams_act_metrics_all
   WHERE  metric_id              = cv_metric_id
   AND    act_metric_used_by_id  = cv_act_metric_used_by_id
   AND    arc_act_metric_used_by = cv_arc_act_metric_used_by;

   --check for the accrual type for the metric id (in case activity metric exists for the target object
   cursor c_check_accrual_type( ca_metric_id number) IS
       select accrual_type
       from ams_metrics_all_b
       where   metric_id = ca_metric_id;

BEGIN --begin copy_act_metrics

   -- Initialize savepoint.
   SAVEPOINT Copy_Metric_pvt;

   IF (AMS_DEBUG_HIGH_ON) THEN
   Ams_Utility_Pvt.Debug_Message(l_full_name||': start');
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.To_Boolean (p_init_msg_list) THEN
      FND_MSG_PUB.Initialize;
   END IF;

   -- Standard check for API version compatibility.
   IF NOT FND_API.Compatible_API_Call (L_API_VERSION,
                                       p_api_version,
                                       L_API_NAME,
                                       G_PKG_NAME)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize API return status to success.
   x_return_status := FND_API.G_RET_STS_SUCCESS;

     validate_objects(
      p_api_version           => p_api_version,
      p_init_msg_list         => p_init_msg_list,
      --p_commit                => p_commit,
      p_validation_level      => p_validation_level,
      p_source_object_type    => l_source_object_type,
      p_source_object_id      => l_source_object_id,
      p_target_object_id      => l_target_object_id,
      x_return_status         => x_return_status,
      x_msg_count             => x_msg_count,
      x_msg_data              => x_msg_data
      );

   IF x_return_status = Fnd_Api.G_RET_STS_ERROR THEN
      RAISE Fnd_Api.G_EXC_ERROR;

   ELSIF x_return_status = Fnd_Api.G_RET_STS_UNEXP_ERROR THEN
      RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
        END IF;

     open c_act_met_details(l_source_object_type,l_source_object_id);
     LOOP
        FETCH c_act_met_details INTO metrics_rec;
        EXIT WHEN c_act_met_details%NOTFOUND;

        l_activity_metric_id := 0;

         OPEN c_exist_metric_target(metrics_rec.metric_id,l_target_object_id,l_source_object_type);
            FETCH c_exist_metric_target INTO l_activity_metric_id;
         CLOSE c_exist_metric_target;

         -- metric from source object  exist in the target
         IF  l_activity_metric_id <> 0 THEN
             --initialize the accrual type value
             l_accrual_type := NULL;
             OPEN c_check_accrual_type(metrics_rec.metric_id);
             FETCH c_check_accrual_type INTO l_accrual_type;
             CLOSE c_check_accrual_type;

             --if accrual type is variable update the variable value.
             IF l_accrual_type=G_VARIABLE
             THEN
               UPDATE ams_act_metrics_all
               SET
                  object_version_number     = object_version_number + 1,
                  last_update_date          = SYSDATE,
                  last_updated_by           = Fnd_Global.User_ID,
                  last_update_login         = Fnd_Global.Conc_Login_ID,
                  variable_value            = metrics_rec.variable_value,
                  forecasted_variable_value = metrics_rec.forecasted_variable_value
               WHERE activity_metric_id     = l_activity_metric_id
               and   metric_id              = metrics_rec.metric_id
               and   arc_act_metric_used_by = l_source_object_type
               and   act_metric_used_by_id  = l_target_object_id;
             END IF;  --accrual type variable

        --metric from source object do not exist in the target call create to insert record.
        ELSE
            metrics_rec.trans_forecasted_value := NULL;
            metrics_rec.trans_actual_value     := NULL;
            metrics_rec.func_forecasted_value  := NULL;
            metrics_rec.func_actual_value      := NULL;
            metrics_rec.activity_metric_id     := NULL;
            metrics_rec.act_metric_used_by_id  := l_target_object_id;
            metrics_rec.application_id := 530;
            x_activity_metric_id := NULL;

            --call create_actmetric to get the entries in the table

          Create_ActMetric (
             p_api_version           => p_api_version,
                  p_init_msg_list         => p_init_msg_list,
                  --p_commit                => p_commit,
                  p_validation_level      => p_validation_level,
                  x_return_status         => x_return_status,
                  x_msg_count             => x_msg_count,
                  x_msg_data              => x_msg_data,
                  p_act_metric_rec        => metrics_rec,
                  x_activity_metric_id    => x_activity_metric_id);

            -- If any errors happen abort API.
          IF x_return_status <> Fnd_Api.G_RET_STS_SUCCESS THEN
             RAISE Fnd_Api.G_EXC_ERROR;
          END IF;
       END IF; --if activity metric exist for target.

    END LOOP;
    CLOSE c_act_met_details;

   -- End API Body.

   -- Standard check for commit request.
   IF FND_API.To_Boolean (p_commit) THEN
      COMMIT;
   END IF;

    Fnd_Msg_Pub.Count_And_Get (
      p_count           =>    x_msg_count,
      p_data            =>    x_msg_data,
      p_encoded         =>    Fnd_Api.G_FALSE
   );

   --
   -- Debug message.
   --
   IF (AMS_DEBUG_HIGH_ON) THEN
      Ams_Utility_Pvt.debug_message(l_full_name ||': END');
   END IF;

   EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Copy_Metric_pvt;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.g_false,
          p_count   => x_msg_count,
               p_data    => x_msg_data
         );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Copy_Metric_pvt;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get (
         p_encoded => FND_API.g_false,
              p_count   => x_msg_count,
                        p_data    => x_msg_data
            );

   WHEN OTHERS THEN
      ROLLBACK TO Copy_Metric_pvt;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
         FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, L_API_NAME);
      END IF;

      FND_MSG_PUB.Count_And_Get (
         p_encoded => FND_API.g_false,
              p_count   => x_msg_count,
              p_data    => x_msg_data
      );

   End copy_act_metrics;

--======================================================================
-- procedure
--    validate_objects
--
-- PURPOSE
--    Created to validate the values while copying activity metrics
--
-- HISTORY
--    13-may-2003 sunkumar created
--======================================================================

PROCEDURE validate_objects(
p_api_version                IN   NUMBER,
p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
p_validation_level           IN  NUMBER   := Fnd_Api.G_Valid_Level_Full,
p_source_object_type         IN   VARCHAR2,
p_source_object_id           IN   NUMBER,
p_target_object_id           IN   NUMBER,
x_return_status              OUT NOCOPY  VARCHAR2,
x_msg_count                  OUT NOCOPY  NUMBER,
x_msg_data                   OUT NOCOPY  VARCHAR2
)

IS
   L_API_VERSION    CONSTANT NUMBER := 1.0;
   L_API_NAME       CONSTANT VARCHAR2(30) := 'VALIDATE_OBJECTS';
   L_FULL_NAME      CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

   l_return_status      VARCHAR2(1):=FND_API.G_RET_STS_SUCCESS;
   l_source_object_type VARCHAR2(30) := p_source_object_type;
   l_source_object_id    NUMBER := p_source_object_id;
   l_target_object_id   NUMBER := p_target_object_id;

   l_source_object_exists VARCHAR2(1) := Fnd_Api.G_FALSE;
   l_target_object_exists VARCHAR2(1) := Fnd_Api.G_FALSE;
   l_valid_object         VARCHAR2(1) := Fnd_Api.G_FALSE;

   l_object_name  AMS_LOOKUPS.MEANING%TYPE;
   --cursors to check for existance of various objects.
   CURSOR c_check_camp(id NUMBER) IS
      SELECT Fnd_Api.G_TRUE
      FROM ams_campaigns_all_b
      WHERE campaign_id = id;

   CURSOR c_check_csch(id NUMBER) IS
      SELECT Fnd_Api.G_TRUE
      FROM ams_campaign_schedules_b
      WHERE schedule_id = id;

   CURSOR c_check_delv(id NUMBER) IS
      SELECT Fnd_Api.G_TRUE
      FROM ams_deliverables_all_b
      WHERE deliverable_id = id;

   CURSOR c_check_eveh(id NUMBER) IS
      SELECT Fnd_Api.G_TRUE
      FROM ams_event_headers_all_b
      WHERE event_header_id = id;

   CURSOR c_check_eveo(id NUMBER) IS
      SELECT Fnd_Api.G_TRUE
      FROM ams_event_offers_all_b
      WHERE event_offer_id = id;

BEGIN

   -- Output debug message.
   IF (AMS_DEBUG_HIGH_ON) THEN
      Ams_Utility_Pvt.debug_message(l_full_name||': start');
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF Fnd_Api.To_Boolean (p_init_msg_list) THEN
      Fnd_Msg_Pub.Initialize;
   END IF;

   -- Standard check for API version compatibility.
   IF NOT Fnd_Api.Compatible_API_Call (L_API_VERSION,
                                       p_api_version,
                                       L_API_NAME,
                                       G_PKG_NAME)
   THEN
      RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize API return status to success.
   x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

   -- Begin API Body.
   IF (AMS_DEBUG_HIGH_ON) THEN
    Ams_Utility_Pvt.debug_message(l_full_name||': Validate items');
  END IF;

  --check source object exists
  IF (l_source_object_type IN ('RCAM', 'CAMP')) THEN
         OPEN c_check_camp(l_source_object_id);
         FETCH c_check_camp INTO l_source_object_exists;
         CLOSE c_check_camp;
    l_valid_object :=  Fnd_Api.G_TRUE;

  ELSIF (l_source_object_type = 'CSCH') THEN
    OPEN c_check_csch(l_source_object_id);
    FETCH c_check_csch INTO l_source_object_exists;
    CLOSE c_check_csch;
    l_valid_object :=  Fnd_Api.G_TRUE;

  ELSIF (l_source_object_type = 'DELV') THEN
    OPEN c_check_delv(l_source_object_id);
    FETCH c_check_delv INTO l_source_object_exists;
    CLOSE c_check_delv;
    l_valid_object :=  Fnd_Api.G_TRUE;

  ELSIF (l_source_object_type = 'EVEH') THEN
    OPEN c_check_eveh(l_source_object_id);
    FETCH c_check_eveh INTO l_source_object_exists;
    CLOSE c_check_eveh;
    l_valid_object :=  Fnd_Api.G_TRUE;

  ELSIF (l_source_object_type IN ('EONE' , 'EVEO')) THEN
    OPEN c_check_eveo(l_source_object_id);
    FETCH c_check_eveo INTO l_source_object_exists;
    CLOSE c_check_eveo;
      l_valid_object :=  Fnd_Api.G_TRUE;

  END IF;

  l_object_name := ams_utility_pvt.get_lookup_meaning('AMS_SYS_ARC_QUALIFIER', l_source_object_type);

  --the object type passed is not a valid one for metrics.
  IF (l_valid_object = Fnd_Api.G_FALSE) THEN
      IF Fnd_Msg_Pub.Check_Msg_Level (Fnd_Msg_Pub.G_MSG_LVL_ERROR) THEN
         Fnd_Message.Set_Name('AMS', 'AMS_COPY_INVALID_OBJECTS');
         Fnd_Msg_Pub.ADD;
      END IF;
      l_return_status := Fnd_Api.G_RET_STS_ERROR;

  END IF;

  --check if source object was not found
  IF (l_source_object_exists = Fnd_Api.G_FALSE)  THEN
      IF Fnd_Msg_Pub.Check_Msg_Level (Fnd_Msg_Pub.G_MSG_LVL_ERROR) THEN
          Fnd_Message.Set_Name('AMS', 'AMS_COPY_INVALID_SOURCE');
         Fnd_Message.set_token('OBJECT', l_object_name);
    Fnd_Msg_Pub.ADD;
      END IF;
         l_return_status := Fnd_Api.G_RET_STS_ERROR;
  END IF;

  --check target object exists
  IF (l_source_object_type IN ('RCAM', 'CAMP')) THEN
         OPEN c_check_camp(l_target_object_id);
         FETCH c_check_camp INTO l_target_object_exists;
         CLOSE c_check_camp;

  ELSIF (l_source_object_type = 'CSCH') THEN
    OPEN c_check_csch(l_target_object_id);
    FETCH c_check_csch INTO l_target_object_exists;
    CLOSE c_check_csch;

  ELSIF (l_source_object_type = 'DELV') THEN
    OPEN c_check_delv(l_target_object_id);
    FETCH c_check_delv INTO l_target_object_exists;
    CLOSE c_check_delv;

  ELSIF (l_source_object_type = 'EVEH') THEN
    OPEN c_check_eveh(l_target_object_id);
    FETCH c_check_eveh INTO l_target_object_exists;
    CLOSE c_check_eveh;

  ELSIF (l_source_object_type IN ('EONE' , 'EVEO')) THEN
    OPEN c_check_eveo(l_target_object_id);
    FETCH c_check_eveo INTO l_target_object_exists;
    CLOSE c_check_eveo;

  END IF;

  --check if target object was not found
  IF (l_target_object_exists = Fnd_Api.G_FALSE)  THEN
      IF Fnd_Msg_Pub.Check_Msg_Level (Fnd_Msg_Pub.G_MSG_LVL_ERROR) THEN
         Fnd_Message.Set_Name('AMS', 'AMS_COPY_INVALID_TARGET');
         Fnd_Message.set_token('OBJECT', l_object_name);
    Fnd_Msg_Pub.ADD;
      END IF;
      l_return_status := Fnd_Api.G_RET_STS_ERROR;

  END IF;

   -- End API Body.

   -- Standard API to get message count, and if 1,
   -- set the message data OUT variable.
   FND_MSG_PUB.Count_And_Get (
      p_count           =>    x_msg_count,
      p_data            =>    x_msg_data,
      p_encoded         =>    FND_API.G_FALSE
   );

   -- Add success message to message list.
   IF (AMS_DEBUG_HIGH_ON) THEN
   Ams_Utility_Pvt.debug_message(l_full_name ||': end Success');
   END IF;

   x_return_status := l_return_status;

END validate_objects;

--======================================================================
-- FUNCTION
--    Lock_Object
--
-- PURPOSE
--    Locks object to prevent duplicates.
--
-- HISTORY
--
--======================================================================
FUNCTION Lock_Object(
   p_api_version                IN  NUMBER,
   p_init_msg_list              IN  VARCHAR2 := Fnd_Api.G_FALSE,
   p_arc_act_metric_used_by     IN VARCHAR2,
   p_act_metric_used_by_id      IN NUMBER,
   x_return_status              OUT NOCOPY VARCHAR2,
   x_msg_count                  OUT NOCOPY NUMBER,
   x_msg_data                   OUT NOCOPY VARCHAR2)
return varchar2
IS
   L_API_VERSION    CONSTANT NUMBER := 1.0;
   L_API_NAME       CONSTANT VARCHAR2(30) := 'LOCK_OBJECT';
   L_FULL_NAME      CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

   l_sql   VARCHAR2(4000);
   l_count NUMBER;
   l_return_status VARCHAR2(1);
   l_table_name VARCHAR2(30);
   l_pk_name VARCHAR2(30);

BEGIN
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
   IF (p_arc_act_metric_used_by ='CSCH') THEN
      l_table_name    := 'AMS_CAMPAIGN_SCHEDULES_B';
      l_pk_name       := 'SCHEDULE_ID';
   ELSIF (p_arc_act_metric_used_by ='CAMP') THEN
      l_table_name    := 'AMS_CAMPAIGNS_ALL_B';
      l_pk_name       := 'CAMPAIGN_ID';
   ELSIF (p_arc_act_metric_used_by ='EVEO') THEN
      l_table_name    := 'AMS_EVENT_OFFERS_ALL_B';
      l_pk_name       := 'EVENT_OFFER_ID';
   ELSIF (p_arc_act_metric_used_by ='EONE') THEN
      l_table_name    := 'AMS_EVENT_OFFERS_ALL_B';
      l_pk_name       := 'EVENT_OFFER_ID';
   ELSIF (p_arc_act_metric_used_by ='EVEH') THEN
      l_table_name    := 'AMS_EVENT_HEADERS_ALL_B';
      l_pk_name       := 'EVENT_HEADER_ID';
   ELSIF (p_arc_act_metric_used_by ='DELV') THEN
      l_table_name    := 'AMS_DELIVERABLES_ALL_B';
      l_pk_name       := 'DELIVERABLE_ID';
   ELSIF (p_arc_act_metric_used_by = 'RCAM') THEN
      l_table_name    := 'AMS_CAMPAIGNS_ALL_B';
      l_pk_name       := 'CAMPAIGN_ID';
   ELSIF (p_arc_act_metric_used_by = 'ALIST') THEN
      l_table_name    := 'AMS_ACT_LISTS';
      l_pk_name       := 'ACT_LIST_HEADER_ID';
   ELSE
      AMS_Utility_PVT.error_message ('AMS_INVALID_SYS_QUAL', 'SYS_QUALIFIER', p_arc_act_metric_used_by);
      x_return_status := FND_API.g_ret_sts_unexp_error;
      l_table_name    := NULL;
      l_pk_name       := NULL;
   END IF;

   l_count := 0;
   if x_return_status = Fnd_Api.G_RET_STS_SUCCESS then
      l_sql := 'UPDATE ' || UPPER(l_table_name) ||
         ' SET object_version_number = object_version_number '||
         ' WHERE ' || UPPER(l_pk_name) || ' = :b1 ';

   IF (AMS_DEBUG_HIGH_ON) THEN
      ams_utility_pvt.debug_message('SQL statement: '||l_sql);
   END IF;

      BEGIN
         EXECUTE IMMEDIATE l_sql
         USING p_act_metric_used_by_id;
         l_count := 1;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            l_count := 0;
      END;

   end if;

   BEGIN
      EXECUTE IMMEDIATE l_sql
      USING p_act_metric_used_by_id;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         l_count := 0;
   END;

   IF l_count = 0 THEN
      RETURN FND_API.g_false;
   ELSE
      RETURN FND_API.g_true;
   END IF;

END Lock_Object;

--
-- PROCEDURE
--    delete_actmetrics_assoc
--
-- DESCRIPTION
--    Delete all activity metrics associated to the given object.
--
-- REQUIREMENT
--    bug 3410962: ALIST integration for deleting lists from target group
--
-- HISTORY
-- 30-Jan-2004 choang   Created.
--
PROCEDURE delete_actmetrics_assoc (
   p_api_version     IN NUMBER,
   p_init_msg_list   IN VARCHAR2 := FND_API.G_FALSE,
   p_commit          IN VARCHAR2 := FND_API.G_FALSE,
   p_object_type     IN VARCHAR2,
   p_object_id       IN NUMBER,
   x_return_status   OUT NOCOPY VARCHAR2,
   x_msg_count       OUT NOCOPY NUMBER,
   x_msg_data        OUT NOCOPY VARCHAR2
)
IS
   L_API_NAME     CONSTANT VARCHAR2(60) := 'Delete ActMetric Associations';
   L_API_VERSION  CONSTANT NUMBER := 1.0;
BEGIN
   SAVEPOINT delete_actmetrics_assoc;

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

   DELETE FROM ams_act_metrics_all
   WHERE arc_act_metric_used_by = p_object_type
   AND   act_metric_used_by_id = p_object_id;

   IF p_commit = FND_API.G_TRUE THEN
      COMMIT;
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      ROLLBACK TO delete_actmetrics_assoc;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
         FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, L_API_NAME);
      END IF;

      FND_MSG_PUB.Count_And_Get (
         p_encoded => FND_API.g_false,
         p_count   => x_msg_count,
         p_data    => x_msg_data
      );
END delete_actmetrics_assoc;

--
-- PROCEDURE
--    Validate_Object_Exists
--
-- DESCRIPTION
--    Check for object existance.
--
-- HISTORY
-- 21-Apr-2004 sunkumar Created
--
FUNCTION Validate_Object_Exists (
   p_object_type  IN  varchar2,
   p_object_id   IN  number
)
RETURN VARCHAR2
IS

   CURSOR c_campaign_metric(p_campaign_id number) IS
   SELECT 1 FROM AMS_CAMPAIGNS_ALL_B
   WHERE CAMPAIGN_ID = p_campaign_id;


   CURSOR c_campaign_schedule_metric(p_campaign_schedule_id number) IS
   SELECT 1 FROM AMS_CAMPAIGN_SCHEDULES_B
   WHERE schedule_ID = p_campaign_schedule_id;

   CURSOR c_deliverable_metric(p_deliverable_id number) IS
   SELECT 1 FROM AMS_DELIVERABLES_ALL_B
   WHERE deliverable_ID = p_deliverable_id;

   CURSOR c_event_schedule_metric(p_event_schedule_id number) IS
   SELECT 1 FROM AMS_EVENT_OFFERS_ALL_B
   WHERE EVENT_OFFER_ID = p_event_schedule_id
   and event_object_type = 'EVEO';

   CURSOR c_one_off_metric(p_one_off_id number) IS
   SELECT 1 FROM AMS_EVENT_OFFERS_ALL_B
   WHERE EVENT_OFFER_ID = p_one_off_id
   and event_object_type = 'EONE';


   CURSOR c_event_metric(p_event_id number) IS
   SELECT 1 FROM AMS_EVENT_HEADERS_ALL_B
   WHERE EVENT_HEADER_ID = p_event_id;


   CURSOR c_act_list_metric(p_act_list_id number) IS
   SELECT 1 FROM AMS_ACT_LISTS
   WHERE ACT_LIST_HEADER_ID = p_act_list_id;

   l_count NUMBER;
BEGIN


   IF (p_object_type ='CSCH') THEN

      OPEN c_campaign_schedule_metric(p_object_id);
      IF c_campaign_schedule_metric%NOTFOUND
          THEN l_count := 0;
          ELSE l_count := 1;
      END IF;
      CLOSE c_campaign_schedule_metric;


   ELSIF (p_object_type ='CAMP' OR p_object_type = 'RCAM') THEN

      OPEN c_campaign_metric(p_object_id);
      IF c_campaign_metric%NOTFOUND
           THEN l_count := 0;
           ELSE l_count := 1;
      END IF;
      CLOSE c_campaign_metric;


   ELSIF (p_object_type ='EVEO') THEN

      OPEN c_event_schedule_metric(p_object_id);

      IF c_event_schedule_metric%NOTFOUND
      THEN l_count := 0;
        ELSE l_count := 1;
      END IF;

      CLOSE c_event_schedule_metric;

   ELSIF (p_object_type ='EONE') THEN

      OPEN c_one_off_metric(p_object_id);

      IF c_one_off_metric%NOTFOUND
        THEN l_count := 0;
        ELSE l_count := 1;
      END IF;

      CLOSE c_one_off_metric;

   ELSIF (p_object_type ='EVEH') THEN

      OPEN c_event_metric(p_object_id);

      IF c_event_metric%NOTFOUND
        THEN l_count := 0;
        ELSE l_count := 1;
      END IF;

      CLOSE c_event_metric;

   ELSIF (p_object_type ='DELV') THEN

      OPEN c_deliverable_metric(p_object_id);

      IF c_deliverable_metric%NOTFOUND
        THEN l_count := 0;
        ELSE l_count := 1;
      END IF;

      CLOSE c_deliverable_metric;

   ELSIF (p_object_type = 'ALIST') THEN

      OPEN c_act_list_metric(p_object_id);
      IF c_act_list_metric%NOTFOUND
        THEN l_count := 0;
        ELSE l_count := 1;
      END IF;

      CLOSE c_act_list_metric;

   ELSE
      l_count := 0;

   END IF;

   IF l_count = 0 THEN
      RETURN FND_API.g_false;
   ELSE
      RETURN FND_API.g_true;
   END IF;


END Validate_Object_Exists;

--
-- FUNCTION
--   CAN_POST_TO_BUDGET
--
-- DESCRIPTION
--   Determine if the object has an approved budget and the correct status
--   for posting costs to budgets.
--
-- RETURN
--   VARCHAR2 - TRUE, FALSE
--
--  REQUIREMENT
--   BUG 4868582: Post to budget only with actual values entered.
--
-- HISTORY
--   15-Dec-2005 dmvincen  Created.
FUNCTION CAN_POST_TO_BUDGET(p_object_type IN VARCHAR2, p_object_id IN NUMBER)
RETURN VARCHAR2
IS
  CURSOR c_has_approved_budget(l_object_type VARCHAR2,l_object_id NUMBER)
  IS
       select count(1) budget_count
       from ozf_act_budgets
		 where transfer_type = 'REQUEST'
		 and  arc_act_budget_used_by = l_object_type
		 and  act_budget_used_by_id = l_object_id
		 and  budget_source_type = 'FUND'
		 and  status_code = 'APPROVED';

  l_return_val VARCHAR2(30) := FND_API.G_FALSE;
  l_budget_count NUMBER;
  l_status VARCHAR2(30);
  l_currency VARCHAR2(30);
BEGIN
	 open c_has_approved_budget(p_object_type, p_object_id);
	 fetch c_has_approved_budget INTO l_budget_count;
	 CLOSE c_has_approved_budget;

	 Get_Object_Info (
		 p_obj_type     => p_object_type,
		 p_obj_id       => p_object_id,
       x_flag         => l_status,
       x_currency     => l_currency
		);

	IF l_budget_count > 0 AND l_status = 'Y' THEN
	   l_return_val := FND_API.G_TRUE;
	END IF;

	return l_return_val;

END can_post_to_budget;

END Ams_Actmetric_Pvt;

/
