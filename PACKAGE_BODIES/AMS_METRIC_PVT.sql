--------------------------------------------------------
--  DDL for Package Body AMS_METRIC_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_METRIC_PVT" AS
/* $Header: amsvmtcb.pls 120.1 2005/08/24 23:08:56 dmvincen noship $ */

------------------------------------------------------------------------------
--
-- NAME
--    AMS_Metrics_PVT
--
-- HISTORY
-- 25-may-1999    choang@us  Created package.
-- 26-may-1999    choang@us  Completed create API.  Created templates and
--                           definitions for all other API's.
-- 27-may-1999    choang@us  Added check_req_metrics_rec.
-- 28-may-1999    choang@us  Completed update, delete and lock API's.  Added
--                           validate_metric_items. Began procedure for
--                           validating child entities.  Completed
--                           validate_metric API and added ORG_ID to create and
--                           update.  Began creating template
--                           API's for activity metrics.
-- 31-may-1999    choang@us  Updated package qualifier for utility functions to
--                           use AMS_Utility_PVT instead of AMS_Global_PVT.
-- 01-jun-1999    choang@us  Added insert and update API for activity metrics
--                           -- untested.
-- 02-jun-1999    choang@us  Began on lock API.
-- 07-jun-1999    choang@us  Added validate rec types extracted from global
--                           package.  Removed references to global package for
--                           validate rec types.
-- 08-jun-1999    choang@us  Added dummy procedure for defaulting values.
--                           Completed lock and delete API's for activity
--                           metrics.  Completed procedure for item level
--                           validation for activity metrics.  Changed order of
--                           parameter list for API standards.
-- 10-jun-1999    choang@us  Corrected validate API for metrics and activity
--                           metrics to return the rec as an OUT variable --
--                           this allows default values to be set properly.
--                           Modified case of packages, procedures and functions
--                           to conform to standards.
-- 14-jun-1999    choang@us  Updated all case standards for procedure
--                           references.
-- 22-jun-1999    choang@us  Moved activity metrics to common objects package.
-- 17-jul-1999    choang@us  Added validation for delete and update of seed
--                           data.  Added 'get' API's for metric values and
--                           metric category values.  Added refresh and refresh
--                           all API's. Added API for update of committed value.
-- 30-jul-1999    choang@us  Completed calculation engine for summary -- needs
--                           testing, but no data yet.  Added addition item
--                           level validation to implement business rules for
--                           hierarchy rollup and summarization.
-- 04-aug-1999    choang@us  Consolidated refresh and refresh all into one
--                           procedure by adding flag to refresh API to
--                           indicate whether to refresh one metric or
--                           all associated metrics.
-- 15-aug-1999   ptendulk@us Removed references to G_MISS_NUM and G_MISS_CHAR;
--                           fixed child entity validation logic.
-- 01-sep-1999   choang@us   Made the following specs public:
--                           Validate_Metric_Items, IsSeeded,
--                           Validate_Metric_Child per request of ptendulk.
-- 04-Oct-1999   ptendulk@us Added Changed Metric Refresh Engine(UOM and
--                           Currency Conversion)
-- 09-Oct-1999   ptendulk@us Seperated Metric package with Refresh Engine
--                           Package and made changes according to new
--                           standards.
-- 01/18/2000    bgeorge     Reviewed code, made UOM non-required, removed
--                           function ISSEEDED from the specs.
-- 17-Apr-2000 tdonohoe@us   Added columns to metric_rec_type to support
--                           11.5.2 release.
-- 07/17/2000     khung@us   bug 1356700 fix. modify check_uniqueness() where
--                           clause
-- 11/15/2000    sveerave@us bug 1490374 fix. removed reference to
--                           check_uniqueness and added new logic.
-- 11/28/2000    sveerave@us  bug 1499845 fix.
-- 04/27/2001   dmvincen@us  Added SUMMARY metric calculation type. #1753241
-- 05/04/2001   dmvincen@us  Allow name and enable to update even if assigned.
-- 05/15/2001   dmvincen@us  Allow SUMMARY even if not seeded.  For 11.5.4.11.
-- 06/07/2001   huili@       Alow rollup metric to summarize to metrics of
--                           different business types for 11.5.5
-- 06/14/2001   huili        Comment out validation for "VARIABLE" metrics.
-- 06/19/2001   dmvincen     Added RCAM and EONE object types.
-- 06/29/2001   huili        Bug fix #1831746.
-- 07/09/2001   huili        Bug fix #1865864.
-- 09/07/2001   huili        Added the "Validate_Metric_Program" function.
-- 10/04/2001   dmvincen     Added used with ANY for rollup and summary metrics.
-- 10/08/2001   huili        Remove the message initialization in the
--                           "Get_Function_Type".
-- 10/09/2001   huili        Remove the schema checking for seeded function
--                           metrics.
-- 10/12/2001   huili        Pass the "FND_API.G_FALSE" to the "p_encoded"
--                           parameter of the "FND_MSG_PUB.Count_And_Get"
--                           module.
-- 10/29/2001   huili        Add the " Inter_Metric_Validation" module and link
--                           it to the "update_metric" module.
-- 12/26/2001   dmvincen     Metrics can rollup to any type of object.
-- 12/27/2001   dmvincen     Seeded metrics can update enabled flag.
-- 03/13/2002   dmvincen     Added dialog components.
-- 03/13/2002   dmvincen     Rollup/summary object type is always 'ANY'.
--                           No validation required.
-- 04/03/2002   dmvincen     Summary and Rollups have 'ANY' used with.
-- 06/14/2002   dmvincen     BUG2411660: Test for dependent metric corrected.
-- 07/09/2002   dmvincen     BUG2450504,2448534,2448518: Set encoding to false.
-- 11/18/2002   dmvincen     Added EONE.
-- 01/08/2003   dmvincen     BUG2741868: Disable summary metrics.
-- 03/04/2003   dmvincen     BUG2830166: Update metric name.
-- 03/11/2003   dmvincen     BUG2845365: Removed Dialogue components.
-- 08/27/2003   sunkumar     BUG3116703: Modified Validate_Metric_Program
-- 08/29/2003   dmvincen     Adding display type.
-- 02/19/2004   sunkumar      bug#3453994
-- 02/24/2004   dmvincen     BUG3465714: Record validation on create.
-- 04/20/2004   sunkumar     removed reference to ams_utility_pvt.checkcheck_fk_exists
-- 06/17/2004   sunkumar     BUG#3697901: Function Type not setting up
-- 06/18/2004   sunkumar     removed reference to get_function_type instead
--                           setting up the function/procedure flag in
--                           Validate_Metric_Program, Made
--                           Validate_Metric_Program a procedure, earlier it
--                           was a function.
-- 11/10/2004   dmvincen     BUG3792709: Fixed program validation.
-- 06-Jan-2006  choang       Bug 4107480: fixed update api to calc func_type all the
--                           time and removed obsoleted procedure get_function_type
-------------------------------------------------------------------------------

--
-- Global variables and constants.

G_PKG_NAME CONSTANT VARCHAR2(30) := 'AMS_METRIC_PVT'; -- Name of the current package.
G_DEBUG_FLAG VARCHAR2(1) := 'Y';

G_ROLLUP CONSTANT VARCHAR2(30) := 'ROLLUP';
G_SUMMARY CONSTANT VARCHAR2(30) := 'SUMMARY';
G_MANUAL CONSTANT VARCHAR2(30) := 'MANUAL';
G_FUNCTION CONSTANT VARCHAR2(30) := 'FUNCTION';
G_FORMULA CONSTANT VARCHAR2(30) := 'FORMULA';

G_FIXED CONSTANT VARCHAR2(30) := 'FIXED';
G_VARIABLE CONSTANT VARCHAR2(30) := 'VARIABLE';

G_COST_ID NUMBER := 901;
G_REVENUE_ID NUMBER :=902;

-- Start of comments
-- API Name       IsSeeded
-- Type           Private
-- Pre-reqs       None.
-- Function       Returns whether the given ID is that of a seeded record.
-- Parameters
--    IN          p_id            IN ams_metrics_all_vl.metric_id%TYPE  Required
--    OUT         Boolean (True/FALSE)
-- Version        Current version: 1.0
--                Previous version: 1.0
--                Initial version: 1.0
-- End of comments
FUNCTION IsSeeded (
   p_id        IN NUMBER
) RETURN BOOLEAN ;

PROCEDURE Complete_Metric_Rec(
   p_metric_rec      IN  metric_rec_type,
   x_complete_rec    IN OUT NOCOPY metric_rec_type,
   x_old_metric_rec  IN OUT NOCOPY metric_rec_type,
   x_seeded_ok       IN OUT NOCOPY BOOLEAN
);

--
-- Start of comments.
--
-- NAME
--    Inter_Metric_Validation
--
-- PURPOSE
--    Validation for all metrics (rollup, summary parents and children, variable metrics)
--    which have relationship with this one.
--
-- NOTES
--
-- HISTORY
-- 10/26/2001     huili            Created.
--
-- End of comments.
PROCEDURE Inter_Metric_Validation (
   p_metric_rec       IN  metric_rec_type,
   x_return_status    OUT NOCOPY VARCHAR2
)
IS
   CURSOR c_metric IS
   SELECT metric_id, metric_calculation_type, metric_category, accrual_type
   FROM ams_metrics_all_b
   WHERE metric_id = p_metric_rec.metric_id;

   l_metric_rec  c_metric%ROWTYPE;

   CURSOR c_check_rollup_children (p_met_id NUMBER) IS
   SELECT 1
   FROM ams_metrics_all_b
   WHERE metric_parent_id = p_met_id;

   CURSOR c_check_summary_children (p_met_id NUMBER) IS
   SELECT metric_id
   FROM ams_metrics_all_b
   WHERE summary_metric_id = p_met_id;

   l_check_children NUMBER;

   CURSOR c_check_variable_met (p_met_id NUMBER) IS
   SELECT metric_id
   FROM ams_metrics_all_b
   WHERE to_number(compute_using_function) = p_met_id;

BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   OPEN c_metric;
   FETCH c_metric INTO l_metric_rec;
   CLOSE c_metric;

   l_check_children := NULL;

   --
   -- can not update if rollup children exist and category or used with mismatch
   --
   IF l_metric_rec.metric_calculation_type = G_ROLLUP THEN
      OPEN c_check_rollup_children (l_metric_rec.metric_id);
      FETCH c_check_rollup_children INTO l_check_children;
      CLOSE c_check_rollup_children;
      IF l_check_children IS NOT NULL
         AND ( p_metric_rec.metric_calculation_type <>
               l_metric_rec.metric_calculation_type
              OR p_metric_rec.metric_category <> l_metric_rec.metric_category )
      THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         RETURN;
      END IF;

   --
   -- Can not update if summary children exist and category or
   -- used with mismatch
   --
   ELSIF l_metric_rec.metric_calculation_type = G_SUMMARY THEN
      OPEN c_check_summary_children (l_metric_rec.metric_id);
      FETCH c_check_summary_children INTO l_check_children;
      CLOSE c_check_summary_children;
      IF l_check_children IS NOT NULL THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         RETURN;
      END IF;

   --
   -- check variable metric: If a variable metric depends on this.
   --
   ELSIF l_metric_rec.metric_calculation_type IN (G_MANUAL, G_FUNCTION)
      AND l_metric_rec.accrual_type = G_FIXED THEN
      OPEN c_check_variable_met (l_metric_rec.metric_id);
      FETCH c_check_variable_met INTO l_check_children;
      CLOSE c_check_variable_met;
      -- BUG2411660: Test for dependent metric corrected.
      -- IF l_check_children IS NULL THEN
      IF l_check_children IS NOT NULL THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         RETURN;
      END IF;
   END IF;
END;

PROCEDURE Validate_Metric_Program (
   p_func_name        IN VARCHAR2,
   x_func_type        OUT NOCOPY VARCHAR2,
   x_return_status    OUT NOCOPY VARCHAR2
);


FUNCTION Is_Valid_Metric_Program (
   p_exec_string        IN VARCHAR2
) RETURN BOOLEAN;



-- Start of comments
-- NAME
--    Create_Metric
--
-- PURPOSE
--   Creates a metric in AMS_METRICS_ALL_B given the
--   record for the metrics.
--
-- NOTES
--
-- HISTORY
-- 05/26/1999   choang      Created.
-- 10/9/1999    ptendulk    Modified According to new Standards
-- 17-Apr-2000  tdonohoe    Added columns to support 11.5.2 release.
--
-- End of comments

PROCEDURE Create_Metric (
   p_api_version                IN      NUMBER,
   p_init_msg_list              IN  VARCHAR2 := FND_API.G_FALSE,
   p_commit                     IN  VARCHAR2 := FND_API.G_FALSE,
   p_validation_level           IN  NUMBER   := FND_API.G_Valid_Level_Full,

   x_return_status              OUT NOCOPY VARCHAR2,
   x_msg_count                  OUT NOCOPY NUMBER,
   x_msg_data                   OUT NOCOPY VARCHAR2,

   p_metric_rec                 IN  metric_rec_type,
   x_metric_id                  OUT NOCOPY NUMBER
)
IS
   --
   -- Standard API information constants.
   --
   L_API_VERSION     CONSTANT NUMBER := 1.0;
   L_API_NAME        CONSTANT VARCHAR2(30) := 'CREATE_METRIC';
   L_FULL_NAME       CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| L_API_NAME;


   l_return_status   VARCHAR2(1); -- Return value from procedures.
   l_metrics_rec     metric_rec_type := p_metric_rec;
   l_metr_count      NUMBER ;

   l_func_type       VARCHAR2(1) := NULL;

   CURSOR c_metr_count(l_metric_id IN NUMBER) IS
      SELECT COUNT(1)
      FROM   ams_metrics_all_b
      WHERE  metric_id = l_metric_id;

   CURSOR c_metric_id IS
      SELECT ams_metrics_all_b_s.NEXTVAL
      FROM   dual;
BEGIN
   --
   -- Initialize savepoint.
   --
   SAVEPOINT Create_Metric_pvt;

   Ams_Utility_Pvt.Debug_Message(l_full_name||': start');

   --
   -- Initialize message list if p_init_msg_list is set to TRUE.
   --
   IF FND_API.To_Boolean (p_init_msg_list) THEN
      FND_MSG_PUB.Initialize;
   END IF;

   --
   -- Standard check for API version compatibility.
   --
   IF NOT FND_API.Compatible_API_Call (L_API_VERSION,
                                       p_api_version,
                                       L_API_NAME,
                                       G_PKG_NAME)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;


   --
   -- Initialize API return status to success.
   --
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   --
   -- Begin API Body.
   --
   IF g_debug_flag = 'Y' THEN
       NULL;
         --DBMS_OUTPUT.put_line(l_full_name||': Validate');
   END IF;

   --
   -- Validate the record before inserting.
   --
   Validate_Metric (
      p_api_version               => l_api_version,
      p_init_msg_list             => p_init_msg_list,
      p_validation_level          => p_validation_level,
      x_msg_count                 => x_msg_count,
      x_msg_data                  => x_msg_data,
      x_return_status             => l_return_status,
      p_metric_rec                => l_metrics_rec
   );

   -- If any errors happen abort API.
   IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
   ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   --
   -- Debug message.
   --
   Ams_Utility_Pvt.debug_message(l_full_name ||': insert');

   IF l_metrics_rec.metric_id IS NULL THEN
     LOOP
       --
       -- Set the value for the PK.
        OPEN c_metric_id;
        FETCH c_metric_id INTO l_metrics_rec.metric_id;
        CLOSE c_metric_id;

        OPEN  c_metr_count(l_metrics_rec.metric_id);
        FETCH c_metr_count INTO l_metr_count ;
        CLOSE c_metr_count ;

        EXIT WHEN l_metr_count = 0 ;
     END LOOP ;
   END IF;

   --function metric
   IF UPPER(l_metrics_rec.metric_calculation_type) = G_FUNCTION THEN
      IF l_metrics_rec.function_name IS NULL
         OR l_metrics_rec.function_name = FND_API.G_MISS_CHAR THEN
         FND_MESSAGE.Set_Name ('AMS', 'AMS_MET_FUNC_BLANK');
         FND_MSG_PUB.ADD;
         RAISE FND_API.G_EXC_ERROR;
   END IF;
   l_metrics_rec.function_name := UPPER (l_metrics_rec.function_name);

   Validate_Metric_Program (p_func_name => l_metrics_rec.function_name,
                      x_func_type => l_func_type,
                      x_return_status => l_return_status);

   IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
   END IF;

--   elsif UPPER(l_metrics_rec.metric_calculation_type) = G_FORMULA THEN
--      l_metrics_rec.metric_category := null;
--      l_metrics_rec.metric_sub_category := null;
   END IF;

   --
   -- Insert into the base table.
   --
   INSERT INTO ams_metrics_all_b (
          metric_id,

          creation_date,
          created_by,
          last_update_date,
          last_updated_by,
          last_update_login,

          object_version_number,
          application_id,
          arc_metric_used_for_object,
          metric_calculation_type,
          metric_category,
          accrual_type,
          value_type,
          sensitive_data_flag,
          enabled_flag,
          metric_sub_category,
          function_name,
          metric_parent_id,
          summary_metric_id,
          compute_using_function,
          default_uom_code,
          uom_type,
          formula,
          org_id,
          hierarchy_id,
          set_function_name,
          function_type,
          display_type,
			 target_type,
			 denorm_code
   )
   VALUES (
          l_metrics_rec.metric_id,

          SYSDATE,
          FND_GLOBAL.User_ID,
          SYSDATE,
          FND_GLOBAL.User_ID,
          FND_GLOBAL.Conc_Login_ID,
          1, --Object Version Number
          l_metrics_rec.application_id,
          l_metrics_rec.arc_metric_used_for_object,
          l_metrics_rec.metric_calculation_type,
          l_metrics_rec.metric_category,
          l_metrics_rec.accrual_type,
          l_metrics_rec.value_type,
          l_metrics_rec.sensitive_data_flag,
          l_metrics_rec.enabled_flag,
          l_metrics_rec.metric_sub_category,
          l_metrics_rec.function_name,
          l_metrics_rec.metric_parent_id,
          l_metrics_rec.summary_metric_id,
          l_metrics_rec.compute_using_function,
          l_metrics_rec.default_uom_code,
          l_metrics_rec.uom_type,
          l_metrics_rec.formula,
          TO_NUMBER (SUBSTRB (USERENV ('CLIENT_INFO'), 1, 10)),  -- org_id
          l_metrics_rec.hierarchy_id,
          l_metrics_rec.set_function_name,
          l_func_type,
          l_metrics_rec.display_type,
			 l_metrics_rec.target_type,
			 l_metrics_rec.denorm_code
   );

   -- Debug message.
   --
   Ams_Utility_Pvt.debug_message(l_full_name ||': insert TL ');

   --
   -- Insert into the translation table.
   --
   INSERT INTO ams_metrics_all_tl (
          metric_id,
          last_update_date,
          last_updated_by,
          creation_date,
          created_by,
          last_update_login,
          source_lang,
          metrics_name,
          description,
          formula_display,
          LANGUAGE
   )
   SELECT l_metrics_rec.metric_id,
          SYSDATE,
          FND_GLOBAL.User_ID,
          SYSDATE,
          FND_GLOBAL.User_ID,
          FND_GLOBAL.Conc_Login_ID,
          USERENV ('LANG'),
          l_metrics_rec.metrics_name,
          l_metrics_rec.description,
          l_metrics_rec.formula_display,
          l.language_code
   FROM fnd_languages l
   WHERE l.installed_flag IN ('I', 'B')
   AND NOT EXISTS ( SELECT NULL
                    FROM ams_metrics_all_tl t
                    WHERE t.metric_id = l_metrics_rec.metric_id
                    AND t.LANGUAGE = l.language_code);


   --
   -- Set OUT value.
   --
   x_metric_id := l_metrics_rec.metric_id;

   --
   -- End API Body.
   --

   --
   -- Standard check for commit request.
   --
   IF FND_API.To_Boolean (p_commit) THEN
      COMMIT WORK;
   END IF;

   --
   -- Standard API to get message count, and if 1,
   -- set the message data OUT variable.
   --
   FND_MSG_PUB.Count_And_Get (
      p_count           =>    x_msg_count,
      p_data            =>    x_msg_data,
      p_encoded         =>    FND_API.G_FALSE
   );

      --
   -- Add success message to message list.
   --
   Ams_Utility_Pvt.debug_message(l_full_name ||': end Success');


EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Create_Metric_pvt;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get (
         p_encoded => FND_API.g_false,
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data
      );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Create_Metric_pvt;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get (
         p_encoded => FND_API.g_false,
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data
      );
   WHEN OTHERS THEN
      ROLLBACK TO Create_Metric_pvt;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, L_API_NAME);
      END IF;
      FND_MSG_PUB.Count_And_Get (
         p_encoded => FND_API.g_false,
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data
      );
END Create_Metric;

-- Start of comments
-- NAME
--    Update_Metric
--
-- PURPOSE
--   Updates a metric in AMS_METRICS_ALL_B given the
--   record for the metrics.
--
-- NOTES
--
-- HISTORY
-- 05/26/1999   choang      Created.
-- 10/9/1999    ptendulk    Modified According to new Standards
-- 17-Apr-2000  tdonohoe    Added columns to support 11.5.2 release.
--
-- End of comments

PROCEDURE Update_Metric (
   p_api_version         IN      NUMBER,
   p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE,
   p_commit              IN  VARCHAR2 := FND_API.G_FALSE,
   p_validation_level    IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,

   x_return_status       OUT NOCOPY VARCHAR2,
   x_msg_count           OUT NOCOPY NUMBER,
   x_msg_data            OUT NOCOPY VARCHAR2,

   p_metric_rec          IN      metric_rec_type
)
IS
   L_API_VERSION         CONSTANT NUMBER := 1.0;
   L_API_NAME            CONSTANT VARCHAR2(30) := 'UPDATE_METRIC';
   L_FULL_NAME           CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;


   l_return_status       VARCHAR2(1);
   l_metrics_rec         metric_rec_type;-- := p_metric_rec;
   l_old_metrics_rec     metric_rec_type;
   l_func_type           VARCHAR2(1) := NULL;
   l_seeded_ok           BOOLEAN;

BEGIN
   --
   -- Initialize savepoint.
   --
   SAVEPOINT Update_Metric_pvt;

   --
   -- Output debug message.
   --
   Ams_Utility_Pvt.debug_message(l_full_name||': start');

   --
   -- Initialize message list if p_init_msg_list is set to TRUE.
   --
   IF FND_API.To_Boolean (p_init_msg_list) THEN
      FND_MSG_PUB.Initialize;
   END IF;

   --
   -- Standard check for API version compatibility.
   --
   IF NOT FND_API.Compatible_API_Call (L_API_VERSION,
                                       p_api_version,
                                       L_API_NAME,
                                       G_PKG_NAME)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   --
   -- Initialize API return status to success.
   --
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- replace g_miss_char/num/date with current column values
   Complete_Metric_Rec(p_metric_rec, l_metrics_rec, l_old_metrics_rec, l_seeded_ok);

   --
   -- Begin API Body
   --
   Inter_Metric_Validation (
      p_metric_rec => l_metrics_rec,
      x_return_status => l_return_status
   );

   IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
      Validate_Metric_Child (
         p_metric_id              => l_metrics_rec.metric_id,
         x_return_status          => l_return_status
         );
   END IF;

   IF l_return_status = FND_API.g_ret_sts_error THEN
      IF l_metrics_rec.metric_calculation_type <>
		        l_old_metrics_rec.metric_calculation_type
         OR l_metrics_rec.metric_category <> l_old_metrics_rec.metric_category
         OR l_metrics_rec.accrual_type <> l_old_metrics_rec.accrual_type
         OR l_metrics_rec.value_type <> l_old_metrics_rec.value_type
         OR l_metrics_rec.arc_metric_used_for_object <>
			     l_old_metrics_rec.arc_metric_used_for_object
         OR l_metrics_rec.display_type <> l_old_metrics_rec.display_type
			OR l_metrics_rec.target_type <> l_old_metrics_rec.target_type
      THEN
      -- Add error message to API message list.
      --
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name('AMS', 'AMS_METR_INVALID_UPDT_CHLD');
                  FND_MSG_PUB.ADD;
         END IF;
         RAISE FND_API.g_exc_error;
      ELSE
         l_return_status := FND_API.G_RET_STS_SUCCESS;
      END IF;
   ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

--   Ams_Utility_Pvt.debug_message(l_full_name ||': validate');

   IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
      Validate_Metric_items(
         p_metric_rec      => l_metrics_rec,
         p_validation_mode => JTF_PLSQL_API.g_update,
         x_return_status   => l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      ELSIF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      END IF;
   END IF;

   -- If seeded then only update of enable flag is permitted.
   IF (NOT l_seeded_ok) AND IsSeeded (l_metrics_rec.metric_id) THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
      THEN
         FND_MESSAGE.set_name('AMS', 'AMS_METR_SEEDED_METR2');
         FND_MSG_PUB.ADD;
      END IF;

      RAISE FND_API.G_EXC_ERROR;
   END IF;

   IF p_validation_level >= JTF_PLSQL_API.g_valid_level_record THEN
      Validate_Metric_Record(
         p_metric_rec     => p_metric_rec,
         p_complete_rec   => l_metrics_rec,
         x_return_status  => l_return_status
      );


      IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      ELSIF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      END IF;
   END IF;

--   Ams_Utility_Pvt.debug_message(l_full_name ||': update Metrics Base Table');

   --function metric
   IF UPPER(l_metrics_rec.metric_calculation_type) = G_FUNCTION THEN
      IF l_metrics_rec.function_name IS NULL
         OR l_metrics_rec.function_name = FND_API.G_MISS_CHAR THEN
         FND_MESSAGE.Set_Name ('AMS', 'AMS_MET_FUNC_BLANK');
         FND_MSG_PUB.ADD;
         RAISE FND_API.G_EXC_ERROR;
      END IF;
      l_metrics_rec.function_name := UPPER (l_metrics_rec.function_name);

      -- choang - 06-jan-2005 - bug 4107480
      -- Removed the restriction that func_type only be calculated for
      -- non-seeded metrics; now func_type is calculated for all.
      Validate_Metric_Program (p_func_name => l_metrics_rec.function_name,
                     x_func_type => l_func_type,
                     x_return_status => l_return_status);

      IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
   END IF;

   -- Update AMS_METRICS_ALL_B
   UPDATE ams_metrics_all_b
      SET object_version_number       = l_metrics_rec.object_version_number + 1,
          application_id              = l_metrics_rec.application_id,
          arc_metric_used_for_object  =l_metrics_rec.arc_metric_used_for_object,
          metric_calculation_type     = l_metrics_rec.metric_calculation_type,
          metric_category             = l_metrics_rec.metric_category,
          accrual_type                = l_metrics_rec.accrual_type,
          value_type                  = l_metrics_rec.value_type,
          sensitive_data_flag         = l_metrics_rec.sensitive_data_flag,
          enabled_flag                = l_metrics_rec.enabled_flag,
          metric_sub_category         = l_metrics_rec.metric_sub_category,
          function_name               = l_metrics_rec.function_name,
          metric_parent_id            = l_metrics_rec.metric_parent_id,
          summary_metric_id           = l_metrics_rec.summary_metric_id,
          compute_using_function      = l_metrics_rec.compute_using_function,
          default_uom_code            = l_metrics_rec.default_uom_code,
          uom_type                    = l_metrics_rec.uom_type,
          formula                     = l_metrics_rec.formula,
          last_update_date            = SYSDATE,
          last_updated_by             = FND_GLOBAL.User_ID,
          last_update_login           = FND_GLOBAL.Conc_Login_ID,
          hierarchy_id                = l_metrics_rec.hierarchy_id,
          set_function_name           = l_metrics_rec.set_function_name,
          function_type               = l_func_type,
          display_type                = l_metrics_rec.display_type,
          target_type                 = l_metrics_rec.target_type,
			 denorm_code                 = l_metrics_rec.denorm_code
    WHERE metric_id = l_metrics_rec.metric_id;

   IF  (SQL%NOTFOUND)
   THEN
      --
      -- Add error message to API message list.
      --
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
         FND_MSG_PUB.ADD;
      END IF;
      RAISE FND_API.g_exc_error;
   END IF;

   -- Debug message.
   Ams_Utility_Pvt.debug_message(l_full_name ||': updateMetrics TL Table');

   -- Update AMS_METRICS_ALL_TL
   UPDATE ams_metrics_all_tl
      SET metrics_name       = l_metrics_rec.metrics_name,
          description        = l_metrics_rec.description,
          formula_display    = l_metrics_rec.formula_display,
          last_update_date   = SYSDATE,
          last_updated_by    = FND_GLOBAL.User_ID,
          last_update_login  = FND_GLOBAL.Conc_Login_ID,
          source_lang        = USERENV ('LANG')
    WHERE metric_id = l_metrics_rec.metric_id
      AND USERENV ('LANG') IN (LANGUAGE, source_lang);

   IF  (SQL%NOTFOUND)
   THEN
      --
      -- Add error message to API message list.
      --
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
         FND_MSG_PUB.ADD;
      END IF;
      RAISE FND_API.g_exc_error;

   END IF;

   --
   -- End API Body
   --

   IF FND_API.to_boolean(p_commit) THEN
      COMMIT;
   END IF;

   --
   -- Standard API to get message count, and if 1,
   -- set the message data OUT variable.
   --
   FND_MSG_PUB.Count_And_Get (
      p_count           =>    x_msg_count,
      p_data            =>    x_msg_data,
      p_encoded         =>    FND_API.G_FALSE
   );

   --
   -- Debug message.
   --
   Ams_Utility_Pvt.debug_message(l_full_name ||': end');


EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Update_Metric_pvt;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get (
         p_encoded => FND_API.g_false,
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data
      );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Update_Metric_pvt;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get (
         p_encoded => FND_API.g_false,
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data
      );
   WHEN OTHERS THEN
      ROLLBACK TO Update_Metric_pvt;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, L_API_NAME);
      END IF;
      FND_MSG_PUB.Count_And_Get (
         p_encoded => FND_API.g_false,
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data
      );
END Update_Metric;

-- Start of comments
-- NAME
--    Delete_Metric
--
-- PURPOSE
--   Deletes a metric in AMS_METRICS_ALL_B given the
--   key identifier for the metric.
--
-- NOTES
--
-- HISTORY
-- 05/26/1999   choang         Created.
-- 10/9/1999    ptendulk           Modified according to new standards
--
-- End of comments

PROCEDURE Delete_Metric (
   p_api_version              IN  NUMBER,
   p_init_msg_list            IN  VARCHAR2 := FND_API.G_FALSE,
   p_commit                   IN  VARCHAR2 := FND_API.G_FALSE,

   x_return_status            OUT NOCOPY VARCHAR2,
   x_msg_count                OUT NOCOPY NUMBER,
   x_msg_data                 OUT NOCOPY VARCHAR2,

   p_metric_id                IN  NUMBER,
   p_object_version_number    IN  NUMBER
)
IS
   L_API_VERSION              CONSTANT NUMBER := 1.0;
   L_API_NAME                 CONSTANT VARCHAR2(30) := 'DELETE_METRIC';
   L_FULL_NAME                            CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

   l_return_status            VARCHAR2(1);

   CURSOR c_child_met_id (l_met_id NUMBER) IS
   SELECT metric_id
   FROM ams_metrics_all_b
   WHERE metric_parent_id = l_met_id;

   --huili added on 08/14/2001
   CURSOR c_check_depend_met (l_met_id NUMBER) IS
   SELECT metric_id
   FROM ams_metrics_all_b
   WHERE COMPUTE_USING_FUNCTION = TO_CHAR(l_met_id);

   CURSOR c_sum_met_id (l_met_id NUMBER) IS
   SELECT metric_id
   FROM ams_metrics_all_b
   WHERE SUMMARY_METRIC_ID = l_met_id;

   l_sum_met_id               NUMBER := NULL;
   l_dep_met_id               NUMBER := NULL;
   l_child_met_id             NUMBER := NULL;
BEGIN
   --
   -- Initialize savepoint.
   --
   SAVEPOINT Delete_Metric_pvt;

   --
   -- Output debug message.
   --
   Ams_Utility_Pvt.debug_message(l_full_name||': start');

   --
   -- Initialize message list if p_init_msg_list is set to TRUE.
   --
   IF FND_API.To_Boolean (p_init_msg_list) THEN
      FND_MSG_PUB.Initialize;
   END IF;

   --
   -- Standard check for API version compatibility.
   --
   IF NOT FND_API.Compatible_API_Call (L_API_VERSION,
                                       p_api_version,
                                       L_API_NAME,
                                       G_PKG_NAME)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   --
   -- Check if record is seeded.
   IF IsSeeded (p_metric_id) THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
      THEN
         FND_MESSAGE.set_name('AMS', 'AMS_METR_SEEDED_METR3');
         FND_MSG_PUB.ADD;
      END IF;

      RAISE FND_API.G_EXC_ERROR;
   END IF;

   --
   -- Initialize API return status to success.
   --
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   --
   -- Begin API Body.
   --

      Validate_Metric_Child (
         p_metric_id              => p_metric_id,
         x_return_status          => l_return_status
      );

      -- If any errors happen abort API.

      IF l_return_status = FND_API.G_RET_STS_ERROR THEN
         IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)  THEN
            FND_MESSAGE.set_name('AMS', 'AMS_METR_CHILD_EXIST');
            FND_MSG_PUB.ADD;
         END IF;
         RAISE FND_API.G_EXC_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

   --huili added on 07/09/2001 for bug fix #1865864
   l_child_met_id := NULL;
   OPEN c_child_met_id (p_metric_id);
   FETCH c_child_met_id INTO l_child_met_id;
   CLOSE c_child_met_id;

   IF l_child_met_id IS NOT NULL THEN
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)  THEN
         FND_MSG_PUB.Initialize;
         FND_MESSAGE.set_name('AMS', 'AMS_MET_ROLL_CHILD_EXISTS');
         FND_MSG_PUB.ADD;
      END IF;
      RAISE FND_API.G_EXC_ERROR;
   END IF;
   -- end addition

   --huili added on 08/14/2001 for checking for dependent metric
   l_dep_met_id := NULL;
   OPEN c_check_depend_met (p_metric_id);
   FETCH c_check_depend_met INTO l_dep_met_id;
   CLOSE c_check_depend_met;

   IF l_dep_met_id IS NOT NULL THEN
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)  THEN
         FND_MSG_PUB.Initialize;
         FND_MESSAGE.set_name('AMS', 'AMS_MET_DEP_EXISTS');
         FND_MSG_PUB.ADD;
      END IF;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   l_sum_met_id := NULL;
   OPEN c_sum_met_id (p_metric_id);
   FETCH c_sum_met_id INTO l_sum_met_id;
   CLOSE c_sum_met_id;

   IF l_sum_met_id IS NOT NULL THEN
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)  THEN
         FND_MSG_PUB.Initialize;
         FND_MESSAGE.set_name('AMS', 'AMS_MET_SUM_CHILD_EXISTS');
         FND_MSG_PUB.ADD;
      END IF;
      RAISE FND_API.G_EXC_ERROR;
   END IF;
   -- end addition

      -- Debug message.
          Ams_Utility_Pvt.debug_message(l_full_name ||': delete with Validation');

      DELETE FROM ams_metrics_all_b
      WHERE metric_id = p_metric_id
          AND object_version_number = p_object_version_number;


          IF (SQL%NOTFOUND) THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
                 THEN
                FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
                FND_MSG_PUB.ADD;
         END IF;
         RAISE FND_API.g_exc_error;
          END IF;


      DELETE FROM ams_metrics_all_tl
      WHERE metric_id = p_metric_id;

          IF (SQL%NOTFOUND) THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
                 THEN
                FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
                FND_MSG_PUB.ADD;
         END IF;
         RAISE FND_API.g_exc_error;
          END IF;

     -- 02-SEP-2003: dmvincen - formula metrics support.
     delete from ams_metric_formulas
     where metric_id = p_metric_id;
     -- No need to check if not found.

   --
   -- End API Body.
   --

   IF FND_API.To_Boolean (p_commit) THEN
      COMMIT WORK;
   END IF;

   --
   -- Debug message.
   --
          Ams_Utility_Pvt.debug_message(l_full_name ||': End');


   --
   -- Standard API to get message count, and if 1,
   -- set the message data OUT variable.
   --
   FND_MSG_PUB.Count_And_Get (
      p_count           =>    x_msg_count,
      p_data            =>    x_msg_data,
      p_encoded         =>    FND_API.G_FALSE
   );

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Delete_Metric_pvt;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get (
         p_encoded => FND_API.g_false,
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data
      );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Delete_Metric_pvt;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get (
         p_encoded => FND_API.g_false,
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data
      );
   WHEN OTHERS THEN
      ROLLBACK TO Delete_Metric_pvt;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, L_API_NAME);
      END IF;
      FND_MSG_PUB.Count_And_Get (
         p_encoded => FND_API.g_false,
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data
      );
END Delete_Metric;

-- Start of comments
-- NAME
--    Lock_Metric
--
-- PURPOSE
--    Perform a row lock of the metrics identified in the
--    given row.
--
-- NOTES
--
-- HISTORY
-- 05/26/1999   choang         Created.
-- 10/9/1999    ptendulk           Modified according to new standards
--
-- End of comments

PROCEDURE Lock_Metric (
   p_api_version           IN  NUMBER,
   p_init_msg_list         IN  VARCHAR2 := FND_API.G_FALSE,

   x_return_status         OUT NOCOPY VARCHAR2,
   x_msg_count             OUT NOCOPY NUMBER,
   x_msg_data              OUT NOCOPY VARCHAR2,

   p_metric_id             IN  NUMBER,
   p_object_version_number IN  NUMBER
)
IS
   L_API_VERSION           CONSTANT NUMBER := 1.0;
   L_API_NAME              CONSTANT VARCHAR2(30) := 'LOCK_METRIC';
   L_FULL_NAME                     CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

   l_metric_id                     NUMBER;

   CURSOR c_metrics_info IS
      SELECT metric_id
      FROM ams_metrics_all_b
      WHERE metric_id = p_metric_id
      AND object_version_number = p_object_version_number
      FOR UPDATE OF metric_id NOWAIT;

   CURSOR c_language IS
      SELECT metric_id
      FROM   ams_metrics_all_tl
      WHERE  metric_id = p_metric_id
      AND    USERENV('LANG') IN (LANGUAGE, source_lang)
      FOR    UPDATE OF metric_id NOWAIT;
BEGIN
   --
   -- Output debug message.
   --
   Ams_Utility_Pvt.debug_message(l_full_name||': start');

   --
   -- Initialize message list if p_init_msg_list is set to TRUE.
   --
   IF FND_API.To_Boolean (p_init_msg_list) THEN
      FND_MSG_PUB.Initialize;
   END IF;

   --
   -- Standard check for API version compatibility.
   --
   IF NOT FND_API.Compatible_API_Call (L_API_VERSION,
                                       p_api_version,
                                       L_API_NAME,
                                       G_PKG_NAME)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   --
   -- Initialize API return status to success.
   --
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   --
   -- Begin API Body
   --
   Ams_Utility_Pvt.debug_message(l_full_name||': lock');


   OPEN c_metrics_info;
   FETCH c_metrics_info INTO l_metric_id;
   IF  (c_metrics_info%NOTFOUND)
   THEN
      CLOSE c_metrics_info;
          -- Error, check the msg level and added an error message to the
          -- API message list
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
         FND_MSG_PUB.ADD;
      END IF;
      RAISE FND_API.g_exc_error;
   END IF;
   CLOSE c_metrics_info;

   OPEN  c_language;
   CLOSE c_language;

   --
   -- Standard API to get message count, and if 1,
   -- set the message data OUT variable.
   --
   FND_MSG_PUB.Count_And_Get (
      p_count           =>    x_msg_count,
      p_data            =>    x_msg_data,
      p_encoded         =>    FND_API.G_FALSE
   );

   --
   -- Debug message.
   --
   Ams_Utility_Pvt.debug_message(l_full_name ||': end');


EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data
      );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get (
         p_encoded => FND_API.g_false,
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data
      );
   WHEN Ams_Utility_Pvt.RESOURCE_LOCKED THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;

          IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
                   FND_MESSAGE.set_name('AMS', 'AMS_API_RESOURCE_LOCKED');
                   FND_MSG_PUB.ADD;
          END IF;

      FND_MSG_PUB.Count_And_Get (
         p_count         =>      x_msg_count,
         p_data          =>      x_msg_data,
             p_encoded      =>      FND_API.G_FALSE
      );
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, L_API_NAME);
      END IF;
      FND_MSG_PUB.Count_And_Get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data,
                 p_encoded          =>      FND_API.G_FALSE
                       );
END Lock_Metric;

-- Start of comments
-- NAME
--    Validate_Metric
--
-- PURPOSE
--   Validation API for metrics.
--

-- NOTES
--
-- HISTORY
-- 05/26/1999   choang         Created.
-- 10/9/1999    ptendulk           Modified according to new standards
--
-- End of comments

PROCEDURE Validate_Metric (
   p_api_version                IN  NUMBER,
   p_init_msg_list              IN  VARCHAR2 := FND_API.G_FALSE,
   p_validation_level           IN  NUMBER   := FND_API.G_Valid_Level_Full,

   x_return_status              OUT NOCOPY VARCHAR2,
   x_msg_count                  OUT NOCOPY NUMBER,
   x_msg_data                   OUT NOCOPY VARCHAR2,

   p_metric_rec                 IN  metric_rec_type
)
IS
   L_API_VERSION               CONSTANT NUMBER := 1.0;
   L_API_NAME                  CONSTANT VARCHAR2(30) := 'VALIDATE_METRIC';
   L_FULL_NAME                             CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;


   l_return_status             VARCHAR2(1);

BEGIN
   --
   -- Output debug message.
   --
   Ams_Utility_Pvt.debug_message(l_full_name||': start');

   --
   -- Initialize message list if p_init_msg_list is set to TRUE.
   --
   IF FND_API.To_Boolean (p_init_msg_list) THEN
      FND_MSG_PUB.Initialize;
   END IF;

   --
   -- Standard check for API version compatibility.
   --
   IF NOT FND_API.Compatible_API_Call (L_API_VERSION,
                                       p_api_version,
                                       L_API_NAME,
                                       G_PKG_NAME)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   --
   -- Initialize API return status to success.
   --
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   --
   -- Begin API Body.
   --

   Ams_Utility_Pvt.debug_message(l_full_name||': Validate items');

   -- Validate required items in the record.
   IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN

       Validate_Metric_items(
         p_metric_rec      => p_metric_rec,
         p_validation_mode => JTF_PLSQL_API.g_create,
         x_return_status   => l_return_status
      );


          -- If any errors happen abort API.
          IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                  RAISE FND_API.G_EXC_ERROR;
          END IF;
   END IF;

          Ams_Utility_Pvt.debug_message(l_full_name||': check record');

   IF p_validation_level >= JTF_PLSQL_API.g_valid_level_record THEN
      -- dmvincen 02/24/2004: set p_complete_rec to p_metric_rec from null.
      Validate_Metric_record(
         p_metric_rec     => p_metric_rec,
         p_complete_rec   => p_metric_rec,
         x_return_status  => l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      ELSIF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      END IF;
   END IF;

   --
   -- End API Body.
   --

   --
   -- Standard API to get message count, and if 1,
   -- set the message data OUT variable.
   --
   FND_MSG_PUB.Count_And_Get (
      p_count           =>    x_msg_count,
      p_data            =>    x_msg_data,
      p_encoded         =>    FND_API.G_FALSE
   );



   Ams_Utility_Pvt.debug_message(l_full_name ||': end');



EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get (
         p_encoded => FND_API.g_false,
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data
      );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get (
         p_encoded => FND_API.g_false,
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data
      );
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, L_API_NAME);
      END IF;
      FND_MSG_PUB.Count_And_Get (
         p_encoded => FND_API.g_false,
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data
      );
END Validate_Metric;


-- Start of comments.
--
-- NAME
--    Check_Req_Metrics_Items
--
-- PURPOSE
--    Check for all required fields in ASM_METRICS_ALL_VL has
--    a value; if value is NULL, then Add an error message to
--    the API message list.
--
-- NOTES
--
-- HISTORY
-- 05/26/1999     choang            Created.
-- 10/9/1999      ptendulk                      Modified According to new standards
--
-- End of comments.

PROCEDURE Check_Req_Metrics_Items (
   p_metric_rec                       IN metric_rec_type,
   x_return_status                     OUT NOCOPY VARCHAR2
)
IS
BEGIN
   -- Initialize return status to success.
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- VIEW_APPLICATION_ID

   IF p_metric_rec.application_id IS NULL
   THEN
          -- missing required fields
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
      THEN -- MMSG
         FND_MESSAGE.Set_Name('AMS', 'AMS_METR_MISSING_APP_ID');
         FND_MSG_PUB.ADD;
      END IF;

      x_return_status := FND_API.G_RET_STS_ERROR;

      -- If any error happens abort API.
      RETURN;
   END IF;

   -- ARC_METRIC_USED_FOR_OBJECT

   IF  p_metric_rec.arc_metric_used_for_object IS NULL
   THEN
      -- missing required fields
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
      THEN -- MMSG
         FND_MESSAGE.Set_Name('AMS', 'AMS_METR_MISSING_ARC_USED_FOR');
         FND_MSG_PUB.ADD;
      END IF;

      x_return_status := FND_API.G_RET_STS_ERROR;

      -- If any error happens abort API.
      RETURN;
   END IF;

   -- METRIC_CALCULATION_TYPE

   IF p_metric_rec.metric_calculation_type IS NULL
   THEN
      -- missing required fields
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
      THEN -- MMSG
         FND_MESSAGE.Set_Name('AMS', 'AMS_METR_MISSING_CALC_TYPE');
         FND_MSG_PUB.ADD;
      END IF;

      x_return_status := FND_API.G_RET_STS_ERROR;

      -- If any error happens abort API.
      RETURN;
   END IF;

   -- METRIC_CATEGORY

   IF p_metric_rec.metric_calculation_type <> G_FORMULA AND
      p_metric_rec.metric_category IS NULL
   THEN
      -- missing required fields
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
      THEN -- MMSG
         FND_MESSAGE.Set_Name('AMS', 'AMS_METR_MISSING_CATEGORY');
         FND_MSG_PUB.ADD;
      END IF;

      x_return_status := FND_API.G_RET_STS_ERROR;

      -- If any error happens abort API.
      RETURN;
   END IF;

   -- ACCRUAL_TYPE

   IF p_metric_rec.accrual_type IS NULL
   THEN
      -- missing required fields
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
      THEN -- MMSG
         FND_MESSAGE.Set_Name('AMS', 'AMS_METR_MISSING_ACCRUAL_TYPE');
         FND_MSG_PUB.ADD;
      END IF;

      x_return_status := FND_API.G_RET_STS_ERROR;

      -- If any error happens abort API.
      RETURN;
   END IF;

   -- VALUE_TYPE

   IF p_metric_rec.value_type IS NULL
   THEN
      -- missing required fields
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
      THEN -- MMSG
         FND_MESSAGE.Set_Name('AMS', 'AMS_METR_MISSING_VAL_TYPE');
         FND_MSG_PUB.ADD;
      END IF;

      x_return_status := FND_API.G_RET_STS_ERROR;

      -- If any error happens abort API.
      RETURN;
   END IF;

   -- SENSITIVE_DATA_FLAG

   IF p_metric_rec.sensitive_data_flag IS NULL
   THEN
      -- missing required fields
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
      THEN -- MMSG
         FND_MESSAGE.Set_Name('AMS', 'AMS_METR_MISSING_SENSITIVE');
         FND_MSG_PUB.ADD;
      END IF;

      x_return_status := FND_API.G_RET_STS_ERROR;

      -- If any error happens abort API.
      RETURN;
   END IF;

   -- ENABLED_FLAG

   IF p_metric_rec.enabled_flag  IS NULL
   THEN
      -- missing required fields
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
      THEN -- MMSG
         FND_MESSAGE.Set_Name('AMS', 'AMS_METR_MISSING_ENABLED_FLAG');
         FND_MSG_PUB.ADD;
      END IF;

      x_return_status := FND_API.G_RET_STS_ERROR;

      -- If any error happens abort API.
      RETURN;
   END IF;

   -- Uom Type
 /*------------------------------------------------------------
 --commented by Bgeorge on 01/18/00
 --removed the functional requirement for the
 --below two columns uom_type + default_uom_code

   IF p_metric_rec.uom_type  IS NULL
   THEN
      -- missing required fields
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
      THEN -- MMSG
         FND_MESSAGE.Set_Name('AMS', 'AMS_METR_MISSING_UOM_TYPE');
         FND_MSG_PUB.Add;
      END IF;

      x_return_status := FND_API.G_RET_STS_ERROR;

      -- If any error happens abort API.
      RETURN;
   END IF;

   -- Default UOM Code

   IF p_metric_rec.default_uom_code  IS NULL
   THEN
      -- missing required fields
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
      THEN -- MMSG
         FND_MESSAGE.Set_Name('AMS', 'AMS_METR_MISSING_DEF_UOM');
         FND_MSG_PUB.Add;
      END IF;

      x_return_status := FND_API.G_RET_STS_ERROR;

      -- If any error happens abort API.
      RETURN;
   END IF;

 --end comment 01/18/00
 ---------------------------------------------------------------------*/

   -- METRICS_NAME

   IF p_metric_rec.metrics_name IS NULL
   THEN
      -- missing required fields
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
      THEN -- MMSG
         FND_MESSAGE.Set_Name('AMS', 'AMS_METR_MISSING_NAME');
         FND_MSG_PUB.ADD;
      END IF;

      x_return_status := FND_API.G_RET_STS_ERROR;

      -- If any error happens abort API.
      RETURN;
   END IF;

   -- DISPLAY_TYPE

   IF p_metric_rec.DISPLAY_TYPE IS NULL
   THEN
      -- missing required fields
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
      THEN -- MMSG
         FND_MESSAGE.Set_Name('AMS', 'AMS_METR_MISSING_DISPLAY_TYPE');
         FND_MSG_PUB.ADD;
      END IF;

      x_return_status := FND_API.G_RET_STS_ERROR;

      -- If any error happens abort API.
      RETURN;
   END IF;

EXCEPTION
   WHEN OTHERS THEN
      RAISE;
END Check_Req_Metrics_Items;


--
-- Start of comments.
--
-- NAME
--    Check_Metric_UK_Items
--
-- PURPOSE
--    Perform Uniqueness check for metrics.
--
-- NOTES
--
-- HISTORY
-- 10/9/1999      ptendulk                      Created.
--
-- End of comments.


PROCEDURE Check_Metric_UK_Items(
   p_metric_rec      IN  metric_rec_type,
   p_validation_mode IN  VARCHAR2 := JTF_PLSQL_API.g_create,
   x_return_status   OUT NOCOPY VARCHAR2
)
IS
   l_where_clause VARCHAR2(2000); -- Used By Check_Uniqueness

   CURSOR c_crt_get_dup_names(p_metrics_name VARCHAR2,
               p_arc_metric_used_for_object VARCHAR2) IS
     SELECT 1
     FROM ams_metrics_vl
     WHERE UPPER(METRICS_NAME) = UPPER(p_metrics_name)
        AND arc_metric_used_for_object = p_arc_metric_used_for_object;

   CURSOR c_upd_get_dup_names(p_metrics_name VARCHAR2,
               p_arc_metric_used_for_object VARCHAR2, p_metric_id NUMBER) IS
     SELECT 1
     FROM ams_metrics_vl
     WHERE UPPER(METRICS_NAME) = UPPER(p_metrics_name)
        AND arc_metric_used_for_object = p_arc_metric_used_for_object
        AND metric_id <> p_metric_id ;
   l_dummy NUMBER;

BEGIN

   x_return_status := FND_API.g_ret_sts_success;

   -- For create_metric, when metric_id is passed in, we need to
   -- check if this metric_id is unique.
   IF p_validation_mode = JTF_PLSQL_API.g_create
      AND p_metric_rec.metric_id IS NOT NULL
   THEN
      l_where_clause := ' metric_id = '||p_metric_rec.metric_id ;

      IF Ams_Utility_Pvt.Check_Uniqueness(
            p_table_name      => 'ams_metrics_vl',
            p_where_clause    => l_where_clause
            ) = FND_API.g_false
        THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
            THEN
            FND_MESSAGE.set_name('AMS', 'AMS_METR_DUP_ID');
            FND_MSG_PUB.ADD;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

   -- Check if Metric_name is unique. Need to handle create and
   -- update differently.

   -- Following code is commented and added new logic below this in order to fix bug # 1490374

/*   -- Unique METRICS_NAME and usage level
   l_where_clause := ' UPPER(METRICS_NAME) = ''' ||
                                                UPPER(p_metric_rec.metrics_name) ||
                  ''' AND arc_metric_used_for_object = ''' ||
                                                p_metric_rec.arc_metric_used_for_object || '''';

   -- For Updates, must also check that uniqueness is not checked against the
        -- same record.
   IF p_validation_mode <> JTF_PLSQL_API.g_create THEN
      l_where_clause := l_where_clause || ' AND metric_id <> ' ||
                                                                p_metric_rec.metric_id;

   END IF;

   IF AMS_Utility_PVT.Check_Uniqueness(
        p_table_name      => 'ams_metrics_vl',
        p_where_clause    => l_where_clause
        ) = FND_API.g_false
   THEN
       IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
       THEN
           FND_MESSAGE.set_name('AMS', 'AMS_METR_DUP_NAME');
           FND_MSG_PUB.add;
       END IF;
       x_return_status := FND_API.g_ret_sts_error;
       RETURN;
   END IF;
*/
   -- For Updates, must also check that uniqueness is not checked against the same record.
   IF p_validation_mode <> JTF_PLSQL_API.g_create THEN
      OPEN c_upd_get_dup_names(p_metric_rec.metrics_name,
                                        p_metric_rec.arc_metric_used_for_object,p_metric_rec.metric_id);
      FETCH c_upd_get_dup_names INTO l_dummy;
      IF c_upd_get_dup_names%FOUND THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name('AMS', 'AMS_METR_DUP_NAME');
            FND_MSG_PUB.ADD;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
      END IF;
      CLOSE c_upd_get_dup_names;
      RETURN;
   ELSE
      OPEN c_crt_get_dup_names(p_metric_rec.metrics_name,
                                                        p_metric_rec.arc_metric_used_for_object);
      FETCH c_crt_get_dup_names INTO l_dummy;
      IF c_crt_get_dup_names%FOUND THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name('AMS', 'AMS_METR_DUP_NAME');
            FND_MSG_PUB.ADD;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
      END IF;
      CLOSE c_crt_get_dup_names;
      RETURN;
   END IF;

   -- check other unique items

END Check_Metric_Uk_Items;


--
-- Start of comments.
--
-- NAME
--    Check_Metric_Items
--
-- PURPOSE
--    Perform item level validation for metrics.
--
-- NOTES
--
-- HISTORY
-- 05/26/1999     choang            Created.
-- 10/9/1999      ptendulk                      Modified According to new Standards
--
-- End of comments.

PROCEDURE Check_Metric_Items (
   p_metric_rec                       IN  metric_rec_type,
   x_return_status                    OUT NOCOPY VARCHAR2
)
IS
   l_item_name                   VARCHAR2(30);  -- Used to standardize error messages.
   l_metrics_rec                 metric_rec_type := p_metric_rec;
   l_return_status               VARCHAR2(1);

   l_table_name                  VARCHAR2(30);
   l_pk_name                     VARCHAR2(30);
   l_pk_value                    VARCHAR2(30);
   l_pk_data_type                VARCHAR2(30);
   l_additional_where_clause     VARCHAR2(4000);  -- Used by Check_FK_Exists.
   l_lookup_type                 VARCHAR2(30);

   Cursor c_check_object_type(l_arc_metric_used_for_object VARCHAR2) is
      select count(1) from ams_lookups
      where lookup_type in ('AMS_METRIC_ROLLUP_TYPE', 'AMS_METRIC_OBJECT_TYPE', 'AMS_METRIC_ALLOCATION_TYPE')
      and lookup_code = l_arc_metric_used_for_object;

   Cursor c_check_special_type(l_arc_metric_used_for_object VARCHAR2) is
      select count(1) from ams_lookups
      where lookup_type in ('AMS_METRIC_SPECIAL_TYPE')
      and lookup_code = l_arc_metric_used_for_object;

   Cursor c_check_all_type(l_arc_metric_used_for_object VARCHAR2) is
      select count(1) from ams_lookups
      where lookup_type in ('AMS_METRIC_SPECIAL_TYPE', 'AMS_METRIC_ROLLUP_TYPE',
           'AMS_METRIC_OBJECT_TYPE', 'AMS_METRIC_ALLOCATION_TYPE')
      and lookup_code = l_arc_metric_used_for_object;


  /*sunkumar 20-april-2004 removed reference to check_fk_exists of utility package*/

  CURSOR c_check_metric_id(p_metric_id number, p_metric_calculation varchar2) IS
    SELECT 1 from ams_metrics_vl
    WHERE METRIC_ID = p_metric_id
    AND   metric_calculation_type = p_metric_calculation;


  CURSOR c_check_uom(p_uom_type varchar2) IS
    SELECT 1 from MTL_UOM_CLASSES
    WHERE UOM_CLASS = p_uom_type;


  CURSOR c_check_category(p_category_id number) IS
    SELECT 1 from AMS_CATEGORIES_VL
    WHERE CATEGORY_ID = p_category_id
    AND   enabled_flag = 'Y'
    AND   arc_category_created_for = 'METR';

  /*End changes sunkumar*/

   l_count number;

BEGIN
   -- Initialize return status to success.
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   --

   --
   -- Begin Validate Referential
   --

   -- METRIC_PARENT_ID
   -- Do not validate FK if NULL

   IF (l_metrics_rec.metric_parent_id <> FND_API.G_MISS_NUM
   AND l_metrics_rec.metric_parent_id IS NOT NULL) THEN

    OPEN c_check_metric_id(l_metrics_rec.metric_parent_id,G_ROLLUP);
    IF c_check_metric_id%NOTFOUND
    THEN
            IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
            THEN
               FND_MESSAGE.Set_Name('AMS', 'AMS_METR_INVALID_PARENT_MET');
               FND_MSG_PUB.ADD;
            END IF;

            x_return_status := FND_API.G_RET_STS_ERROR;
            CLOSE c_check_metric_id;
       RETURN;
        END IF;
   CLOSE c_check_metric_id;

   /* end changes sunkumar */

   END IF;

    /*commented by sunkumar 20-april-2004 */
    /*  l_table_name               := 'AMS_METRICS_VL';
      l_pk_name                  := 'METRIC_ID';
      l_pk_value                 := l_metrics_rec.metric_parent_id;
      l_pk_data_type             := Ams_Utility_Pvt.G_NUMBER;
      l_additional_where_clause  := ' metric_calculation_type = '''||G_ROLLUP||'''';

      IF Ams_Utility_Pvt.Check_FK_Exists (
             p_table_name                       => l_table_name
            ,p_pk_name                      => l_pk_name
            ,p_pk_value                     => l_pk_value
            ,p_pk_data_type                 => l_pk_data_type
            ,p_additional_where_clause  => l_additional_where_clause
         ) = FND_API.G_FALSE
      THEN
         IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
         THEN
            FND_MESSAGE.Set_Name('AMS', 'AMS_METR_INVALID_PARENT_MET');
            FND_MSG_PUB.ADD;
         END IF;

         x_return_status := FND_API.G_RET_STS_ERROR;
         RETURN;*/

    /*added by sunkumar for alternate to the code commented above 20-apr-2004*/




   -- SUMMARY_METRIC_ID
   IF l_metrics_rec.summary_metric_id <> FND_API.G_MISS_NUM AND
      l_metrics_rec.summary_metric_id IS NOT NULL THEN


        OPEN c_check_metric_id(l_metrics_rec.metric_parent_id,G_SUMMARY);
    IF c_check_metric_id%NOTFOUND
    THEN
            IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
            THEN
               FND_MESSAGE.Set_Name('AMS', 'AMS_METR_INVALID_SUMMARY_MET');
               FND_MSG_PUB.ADD;
            END IF;

            x_return_status := FND_API.G_RET_STS_ERROR;
            CLOSE c_check_metric_id;
            RETURN;
        END IF;
      CLOSE c_check_metric_id;



   END IF;


     /*   l_table_name               := 'AMS_METRICS_VL';
      l_pk_name                  := 'METRIC_ID';
      l_pk_value                 := l_metrics_rec.summary_metric_id;
      l_pk_data_type             := Ams_Utility_Pvt.G_NUMBER;
      l_additional_where_clause  := ' metric_calculation_type = '''||G_SUMMARY||'''';

    IF Ams_Utility_Pvt.Check_FK_Exists (
             p_table_name                       => l_table_name
            ,p_pk_name                      => l_pk_name
            ,p_pk_value                     => l_pk_value
            ,p_pk_data_type                 => l_pk_data_type
            ,p_additional_where_clause  => l_additional_where_clause
         ) = FND_API.G_FALSE
      THEN
         IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
         THEN
            FND_MESSAGE.Set_Name('AMS', 'AMS_METR_INVALID_SUMMARY_MET');
            FND_MSG_PUB.ADD;
         END IF;

         x_return_status := FND_API.G_RET_STS_ERROR;
         RETURN;
      END IF;  -- Check_FK_Exists*/




   -- UOM_CLASS
   IF l_metrics_rec.uom_type <> FND_API.G_MISS_CHAR THEN

      OPEN c_check_uom(l_metrics_rec.uom_type);
    IF c_check_uom%NOTFOUND
    THEN
            IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
            THEN
               FND_MESSAGE.Set_Name('AMS', 'AMS_METR_INVALID_UOM_TYPE');
               FND_MSG_PUB.ADD;
            END IF;

            x_return_status := FND_API.G_RET_STS_ERROR;
       CLOSE c_check_uom;
            RETURN;
        END IF;
     CLOSE c_check_uom;

   END IF;


    /*  l_table_name               := 'MTL_UOM_CLASSES';
      l_pk_name                  := 'UOM_CLASS';
      l_pk_value                 := l_metrics_rec.uom_type;
      l_pk_data_type             := Ams_Utility_Pvt.G_VARCHAR2;
      l_additional_where_clause  := NULL;

      IF Ams_Utility_Pvt.Check_FK_Exists (
             p_table_name                       => l_table_name
            ,p_pk_name                      => l_pk_name
            ,p_pk_value                     => l_pk_value
            ,p_pk_data_type                 => l_pk_data_type
            ,p_additional_where_clause  => l_additional_where_clause
         ) = FND_API.G_FALSE
      THEN
         IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
         THEN
                 FND_MESSAGE.Set_Name('AMS', 'AMS_METR_INVALID_UOM_TYPE');
                 FND_MSG_PUB.ADD;
                        END IF;

                        x_return_status := FND_API.G_RET_STS_ERROR;
              RETURN;
      END IF; -- Check_FK_Exists*/



         -- Metric_category
   IF l_metrics_rec.metric_category <> FND_API.G_MISS_NUM THEN


      OPEN c_check_category(l_metrics_rec.metric_category);
    IF c_check_category%NOTFOUND
    THEN
            IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
            THEN
               FND_MESSAGE.Set_Name('AMS', 'AMS_METR_INVALID_CATEGORY');
               FND_MSG_PUB.ADD;
            END IF;

            x_return_status := FND_API.G_RET_STS_ERROR;
       CLOSE c_check_category;
            RETURN;
        END IF;
     CLOSE c_check_category;

   END IF;


      /*l_table_name               := 'AMS_CATEGORIES_VL';
      l_pk_name                  := 'CATEGORY_ID';
      l_pk_value                 := l_metrics_rec.metric_category;
      l_pk_data_type             := Ams_Utility_Pvt.G_NUMBER;
      l_additional_where_clause  := ' enabled_flag = ''Y'''||
                                    ' and arc_category_created_for = ''METR''';

      IF Ams_Utility_Pvt.Check_FK_Exists (
             p_table_name                   => l_table_name
            ,p_pk_name                      => l_pk_name
            ,p_pk_value                     => l_pk_value
            ,p_pk_data_type                 => l_pk_data_type
            ,p_additional_where_clause      => l_additional_where_clause
         ) = FND_API.G_FALSE
      THEN
         IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
            FND_MESSAGE.Set_Name ('AMS', 'AMS_METR_INVALID_CATEGORY');
            FND_MSG_PUB.ADD;
         END IF;

         x_return_status := FND_API.G_RET_STS_ERROR;
         RETURN;
      END IF;*/




   --
   -- End Validate Referential
   --

   --
   -- Begin Validate Flags
   --

      -- SENSITIVE_DATA_FLAG
   IF l_metrics_rec.sensitive_data_flag <> FND_API.G_MISS_CHAR THEN
      IF Ams_Utility_Pvt.Is_Y_Or_N(l_metrics_rec.sensitive_data_flag)
             = FND_API.G_FALSE
      THEN
         IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
         THEN
            FND_MESSAGE.Set_Name('AMS', 'AMS_METR_INVALID_SENS_FLAG');
            FND_MSG_PUB.ADD;
         END IF;

         x_return_status := FND_API.G_RET_STS_ERROR;
         RETURN;
      END IF; -- Is_Y_Or_N
   END IF;

      -- ENABLED_FLAG
   IF l_metrics_rec.enabled_flag <> FND_API.G_MISS_CHAR THEN
      IF Ams_Utility_Pvt.Is_Y_Or_N(l_metrics_rec.enabled_flag)
              = FND_API.G_FALSE
      THEN
         IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
         THEN
            FND_MESSAGE.Set_Name('AMS', 'AMS_METR_INVALID_ENABLED_FLAG');
            FND_MSG_PUB.ADD;
         END IF;

         x_return_status := FND_API.G_RET_STS_ERROR;
         RETURN;
      END IF; -- Is_Y_Or_N
   END IF;

   --
   -- End Validate Flags
   --

   --
   -- Begin Validate LOOKUPS
   --

   -- ACCRUAL_TYPE
   IF l_metrics_rec.accrual_type <> FND_API.G_MISS_CHAR THEN
      l_lookup_type := 'AMS_METRIC_ACCRUAL_TYPE';
      IF Ams_Utility_Pvt.Check_Lookup_Exists (
            p_lookup_table_name   => 'AMS_LOOKUPS'
           ,p_lookup_type         => l_lookup_type
           ,p_lookup_code         => l_metrics_rec.accrual_type
         ) = FND_API.G_FALSE
      THEN
         IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
            FND_MESSAGE.Set_Name ('AMS', 'AMS_METR_INVALID_ACCRUAL_TYPE');
            FND_MSG_PUB.ADD;
         END IF;

         x_return_status := FND_API.G_RET_STS_ERROR;
         RETURN;
      END IF;
   END IF;

   -- METRIC_CALCULATION_TYPE
   -- DMVINCEN 05/15/2001: Allow SUMMARY for 11.5.4.11 (change in 11.5.5).
   IF l_metrics_rec.metric_calculation_type <> FND_API.G_MISS_CHAR THEN
      l_lookup_type := 'AMS_METRIC_CALCULATION_TYPE';
      IF -- l_metrics_rec.metric_calculation_type <> G_SUMMARY AND
         Ams_Utility_Pvt.Check_Lookup_Exists (
            p_lookup_table_name   => 'AMS_LOOKUPS'
           ,p_lookup_type         => l_lookup_type
           ,p_lookup_code         => l_metrics_rec.metric_calculation_type
         ) = FND_API.G_FALSE
      THEN
         IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
            FND_MESSAGE.Set_Name ('AMS', 'AMS_METR_INVALID_CALC_TYPE');
            FND_MSG_PUB.ADD;
         END IF;

         x_return_status := FND_API.G_RET_STS_ERROR;
         RETURN;
      END IF;
   END IF;


   -- VALUE_TYPE
   IF l_metrics_rec.DISPLAY_TYPE <> FND_API.G_MISS_CHAR THEN
      l_lookup_type := 'AMS_METRIC_DISPLAY_TYPE';
      IF Ams_Utility_Pvt.Check_Lookup_Exists (
            p_lookup_table_name         => 'AMS_LOOKUPS'
           ,p_lookup_type                   => l_lookup_type
           ,p_lookup_code                   => l_metrics_rec.DISPLAY_TYPE
         ) = FND_API.G_FALSE
      THEN
         IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
            FND_MESSAGE.Set_Name ('AMS', 'API_INCOMPLETE_INFO');
            FND_MESSAGE.Set_Token ('PARAM', l_lookup_type, FALSE);
            FND_MSG_PUB.ADD;
         END IF;

         x_return_status := FND_API.G_RET_STS_ERROR;
         RETURN;
      END IF;
  END IF;

   -- VALUE_TYPE
   IF l_metrics_rec.value_type <> FND_API.G_MISS_CHAR THEN
      l_lookup_type := 'AMS_METRIC_VALUE_TYPE';
      IF Ams_Utility_Pvt.Check_Lookup_Exists (
            p_lookup_table_name         => 'AMS_LOOKUPS'
           ,p_lookup_type                   => l_lookup_type
           ,p_lookup_code                   => l_metrics_rec.value_type
         ) = FND_API.G_FALSE
      THEN
         IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
            FND_MESSAGE.Set_Name ('AMS', 'API_INCOMPLETE_INFO');
            FND_MESSAGE.Set_Token ('PARAM', l_lookup_type, FALSE);
            FND_MSG_PUB.ADD;
         END IF;

         x_return_status := FND_API.G_RET_STS_ERROR;
         RETURN;
      END IF;
  END IF;

   --
   -- End Validate LOOKUPS
   --

   -- 17-Apr-2000 tdonohoe@us modified, added FUND and FCST qualifiers.
   -- 11-Mar-2002 DMVINCEN Added components.
   -- 11-Mar-2003 BUG2845365: Removed dialgue components.
   -- ARC_METRIC_USED_FOR_OBJECT
   IF l_metrics_rec.arc_metric_used_for_object <> FND_API.G_MISS_CHAR THEN
      l_count := 0;
      IF l_metrics_rec.metric_calculation_type in (G_FUNCTION, G_MANUAL) THEN
         OPEN c_check_object_type(l_metrics_rec.arc_metric_used_for_object);
         fetch c_check_object_type into l_count;
         close c_check_object_type;
      ELSIF l_metrics_rec.metric_calculation_type in (G_ROLLUP, G_SUMMARY) THEN
         OPEN c_check_special_type(l_metrics_rec.arc_metric_used_for_object);
         fetch c_check_special_type into l_count;
         close c_check_special_type;
      ELSIF l_metrics_rec.metric_calculation_type in (G_FORMULA) THEN
         OPEN c_check_all_type(l_metrics_rec.arc_metric_used_for_object);
         fetch c_check_all_type into l_count;
         close c_check_all_type;
      END IF;
      if l_count = 0 then
/***
      IF (l_metrics_rec.arc_metric_used_for_object NOT IN
         ('CAMP','CSCH','EVEH','EVEO','DELV','FUND','FCST', 'EONE')
         --'DILG', 'AMS_COMP_START','AMS_COMP_SHOW_WEB_PAGE','AMS_COMP_END')
         AND l_metrics_rec.metric_calculation_type in (G_FUNCTION, G_MANUAL))
      OR (l_metrics_rec.arc_metric_used_for_object <> 'ANY'
         AND l_metrics_rec.metric_calculation_type in (G_ROLLUP, G_SUMMARY))

--      l_lookup_type := 'AMS_SYS_ARC_QUALIFIER';
--      IF AMS_Utility_PVT.Check_Lookup_Exists (
--            p_lookup_table_name => 'AMS_LOOKUPS'
--           ,p_lookup_type       => l_lookup_type
--           ,p_lookup_code       => l_metrics_rec.arc_metric_used_for_object
--        ) = FND_API.G_FALSE
      THEN
***/
         IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
            FND_MESSAGE.Set_Name ('AMS', 'AMS_METR_INVALID_USED_BY');
            FND_MSG_PUB.ADD;
         END IF;

         x_return_status := FND_API.G_RET_STS_ERROR;
         RETURN;
      END IF;
   END IF;



   -- Validate FUNCTION_NAME
   -- Validate that the Function is created in database


   --
   -- End Other Business Rule Validations
   --

EXCEPTION
   WHEN OTHERS THEN

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      RETURN;
--      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Check_Metric_Items;

/**** OBSOLETE: DMVINCEN 03/04/2003
--
-- Start of comments.
--
-- NAME
--    Check_Valid_Parent
--
-- PURPOSE
--    Check the Validity of the Metric Parent For e.g. The metric Connected to
--    Campaign Schedule can be rolled up into metric Connected to Campaigns only.
--
-- NOTES
--
-- HISTORY
-- 10/11/1999     ptendulk            Created.
-- 06/10/2001     huili               Changed to apply the new hierarchy for
--                                    the new revision 11.5.5
-- 06/19/2001     dmvincen   Change of hierarchy for 11.5.6
--
-- End of comments.
PROCEDURE Check_Valid_Parent(p_metric_used_by          IN  VARCHAR2,
                             p_parent_metric_used_by   IN  VARCHAR2,
                             x_return_status           OUT NOCOPY VARCHAR2 )
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   -- If Child is Attached to Program then Parent must be attached to Program
   IF p_metric_used_by = 'RCAM' AND
      p_parent_metric_used_by <> 'RCAM'
   THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      RETURN;
   END IF;

   -- If Child is Attached to Campaign then Parent must be attached to Program
   IF p_metric_used_by = 'CAMP' AND
      p_parent_metric_used_by <> 'RCAM'
   THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      RETURN;
   END IF;

   -- If Child is Attached to Campaign Schedule then Parent must be attached to Campaign
   IF p_metric_used_by = 'CSCH' AND
      p_parent_metric_used_by <> 'CAMP'
   THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      RETURN;
   END IF;

   -- Deliverable Child can not be rolled up into any other entity
   IF p_metric_used_by = 'DELV'
   THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      RETURN;
   END IF;

   --06/10/2001 huili changed logic
        -- If Child is Attached to Event Header then Parent must be attached to Program
   IF p_metric_used_by = 'EVEH' AND
      p_parent_metric_used_by <> 'RCAM'
   THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      RETURN;
   END IF;

   -- If Child is Attached to Event Offer then Parent must be attached to
   -- Event Header or Event Offer
   IF p_metric_used_by = 'EVEO' AND
      p_parent_metric_used_by <> 'EVEH'
   THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      RETURN;
   END IF;

   -- If Child is Attached to One Off Event then Parent must be attached to Program
        --06/25/2001 huili for debug
        --FND_MESSAGE.set_name('AMS', p_parent_metric_used_by);
   --FND_MSG_PUB.add;
   IF p_metric_used_by = 'EONE' AND
      p_parent_metric_used_by <> 'RCAM'
   THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      RETURN;
   END IF;

END Check_Valid_Parent;
***** OBSOLETE: dmvincen 03/04/2003 ****/

--
-- Start of comments.
--
-- NAME
--    Validate_Metric_Record
--
-- PURPOSE
--    Perform Record Level and Other business validations for metrics.
--
-- NOTES
--
-- HISTORY
-- 10/11/1999     ptendulk            Created.
-- 12/26/2001     dmvincen     Any parent type if valid.
--
-- End of comments.

PROCEDURE Validate_Metric_record(
   p_metric_rec       IN  metric_rec_type,
   p_complete_rec     IN  metric_rec_type,
   x_return_status    OUT NOCOPY VARCHAR2
)
IS

--  l_metrics_rec           metric_rec_type := p_metric_rec ;

   CURSOR c_summary_metric(l_metric_id number) IS
      SELECT   met.*
      FROM     ams_metrics_vl met
      WHERE    met.metric_id = l_metric_id
      ;
   l_summary_metric_rec       c_summary_metric%ROWTYPE;

   CURSOR c_rollup_metric(l_metric_id number) IS
      SELECT   met.*
      FROM     ams_metrics_vl met
      WHERE    met.metric_id = l_metric_id
      ;

   l_rollup_metric_rec        c_rollup_metric%ROWTYPE;

   -- Following cursors are defined to check that Metric can either be Summary
   -- Metric or Rollup Metric but not both.

   CURSOR c_rollup_count(l_metric_id number) IS
   SELECT COUNT(1)
   FROM   ams_metrics_vl
   WHERE  metric_parent_id = l_metric_id ;

   CURSOR c_summary_count(l_metric_id number) IS
   SELECT COUNT(1)
   FROM   ams_metrics_vl
   WHERE  summary_metric_id = l_metric_id ;

   CURSOR c_check_multiplier (l_metric_id number) IS
   select metric_category, ARC_METRIC_USED_FOR_OBJECT, metric_calculation_type
   from ams_metrics_all_b
   where metric_id = l_metric_id;

   CURSOR c_get_category_name (l_category_id number) is
   SELECT category_name
   FROM ams_categories_vl
   where category_id = l_category_id;


    /*sunkumar 20 april 2004*/
    CURSOR c_check_subcategory(p_category_id number,p_parent_category_id number ) IS
    SELECT 1 from AMS_CATEGORIES_VL
    WHERE CATEGORY_ID = p_category_id
    AND   enabled_flag = 'Y'
    AND   arc_category_created_for = 'METR'
    AND   parent_category_id = p_parent_category_id;



    CURSOR c_check_uom(p_uom_code varchar2,p_uom_class varchar2 ) IS
    SELECT 1 from MTL_UNITS_OF_MEASURE
    WHERE UOM_CODE = p_uom_code
    AND   uom_class = p_uom_class;

    /*sunkumar 20 april 2004*/

   l_category_id number;
   l_object_type varchar2(30);
   l_calculation_type varchar2(30);
   l_name ams_lookups.meaning%TYPE;

   l_count                        NUMBER := 0;
   l_valid_chld_flag  VARCHAR2(1);

   l_table_name                  VARCHAR2(30);
   l_pk_name                     VARCHAR2(30);
   l_pk_value                    VARCHAR2(30);
   l_pk_data_type                VARCHAR2(30);
   l_additional_where_clause     VARCHAR2(4000);  -- Used by Check_FK_Exists.

BEGIN

   x_return_status := FND_API.g_ret_sts_success;

   IF --l_metrics_rec.metric_sub_category <> FND_API.G_MISS_NUM    AND
      p_complete_rec.metric_sub_category IS NOT NULL   THEN
--      IF l_metrics_rec.metric_category = FND_API.G_MISS_NUM THEN
--         l_metrics_rec.metric_category := p_complete_rec.metric_category ;
--      END IF;

       /*sunkumar 20 april 2004*/
       OPEN c_check_subcategory(p_complete_rec.metric_sub_category,p_complete_rec.metric_category);
    IF c_check_subcategory%NOTFOUND
    THEN
            IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
            THEN
               FND_MESSAGE.Set_Name('AMS', 'AMS_METR_INVALID_SUB_CATEGORY');
               FND_MSG_PUB.ADD;
            END IF;

            x_return_status := FND_API.G_RET_STS_ERROR;
            CLOSE c_check_subcategory;
            RETURN;
        END IF;
     CLOSE c_check_subcategory;

     END IF;


      IF p_complete_rec.default_uom_code IS NOT NULL AND
      p_complete_rec.uom_type IS NOT NULL THEN

      OPEN c_check_uom(p_complete_rec.default_uom_code,p_complete_rec.uom_type);
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




       END IF; -- default_uom_code is not null


      /*l_table_name               := 'AMS_CATEGORIES_VL';
      l_pk_name                  := 'CATEGORY_ID';
      l_pk_value                 := p_complete_rec.metric_sub_category;
      l_pk_data_type             := Ams_Utility_Pvt.G_NUMBER;
      l_additional_where_clause  := ' enabled_flag = ''Y'''||
                                    ' and arc_category_created_for = ''METR'''||
                                    ' and parent_category_id = '||
                                      p_complete_rec.metric_category;

      IF Ams_Utility_Pvt.Check_FK_Exists (
             p_table_name                   => l_table_name
            ,p_pk_name                      => l_pk_name
            ,p_pk_value                     => l_pk_value
            ,p_pk_data_type                 => l_pk_data_type
            ,p_additional_where_clause      => l_additional_where_clause
         ) = FND_API.G_FALSE
      THEN
         IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
            FND_MESSAGE.Set_Name ('AMS', 'AMS_METR_INVALID_SUB_CATEGORY');
            FND_MSG_PUB.ADD;
         END IF;

         x_return_status := FND_API.G_RET_STS_ERROR;
         RETURN;
      END IF; */


   -- DEFAULT_UOM_CODE
--   IF l_metrics_rec.default_uom_code <> FND_API.G_MISS_CHAR THEN



--      IF l_metrics_rec.uom_type = FND_API.G_MISS_CHAR THEN
 --        l_metrics_rec.uom_type := p_complete_rec.uom_type ;
--      END IF;
   /*   l_table_name               := 'MTL_UNITS_OF_MEASURE';
      l_pk_name                  := 'UOM_CODE';
      l_pk_value                 := p_complete_rec.default_uom_code;
      l_pk_data_type             := Ams_Utility_Pvt.G_VARCHAR2;
      l_additional_where_clause  := ' uom_class = '''||p_complete_rec.uom_type||'''';

      IF Ams_Utility_Pvt.Check_FK_Exists (
             p_table_name                   => l_table_name
            ,p_pk_name                      => l_pk_name
            ,p_pk_value                     => l_pk_value
            ,p_pk_data_type                 => l_pk_data_type
            ,p_additional_where_clause      => l_additional_where_clause
         ) = FND_API.G_FALSE
      THEN
         IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
         THEN
            FND_MESSAGE.Set_Name('AMS', 'AMS_METR_INVALID_UOM');
            FND_MSG_PUB.ADD;
         END IF;

         x_return_status := FND_API.G_RET_STS_ERROR;
         RETURN;
      END IF; -- Check_FK_Exists*/



/*****
   IF (l_metrics_rec.metric_calculation_type <> FND_API.G_MISS_CHAR
      OR l_metrics_rec.function_name <> FND_API.G_MISS_CHAR
      OR l_metrics_rec.compute_using_function <> FND_API.G_MISS_CHAR
      OR l_metrics_rec.accrual_type <> FND_API.G_MISS_CHAR)
   THEN
      IF l_metrics_rec.metric_calculation_type = FND_API.G_MISS_CHAR THEN
         l_metrics_rec.metric_calculation_type :=
               p_complete_rec.metric_calculation_type ;
      END IF;

      IF l_metrics_rec.function_name = FND_API.G_MISS_CHAR THEN
         l_metrics_rec.function_name := p_complete_rec.function_name ;
      END IF;

      IF l_metrics_rec.compute_using_function = FND_API.G_MISS_CHAR THEN
         l_metrics_rec.compute_using_function :=
               p_complete_rec.compute_using_function ;
      END IF;

      IF l_metrics_rec.accrual_type = FND_API.G_MISS_CHAR THEN
         l_metrics_rec.accrual_type := p_complete_rec.accrual_type ;
      END IF;
*****/
      -- Has to change when routine for Validate Function is done
      IF p_complete_rec.accrual_type = G_FIXED THEN
         IF p_complete_rec.compute_using_function IS NOT NULL THEN
            IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
               FND_MESSAGE.Set_Name ('AMS', 'AMS_METR_INVALID_ACCR_VAR_FUN');
               FND_MSG_PUB.ADD;
            END IF;
            x_return_status := FND_API.G_RET_STS_ERROR;
            RETURN;
         ELSE -- compute_using_function is null
            IF p_complete_rec.metric_calculation_type = G_FUNCTION THEN
               IF p_complete_rec.function_name IS NULL THEN
                  IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                  THEN
                     FND_MESSAGE.Set_Name ('AMS', 'AMS_METR_INVALID_CALC_FUNC');
                     FND_MSG_PUB.ADD;
                  END IF;
                  x_return_status := FND_API.G_RET_STS_ERROR;
                  RETURN;
               END IF; -- function_name is null
            ELSE -- metric_calculation_type <> G_FUNCTION
               IF p_complete_rec.function_name IS NOT NULL THEN
                  IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                  THEN
                     FND_MESSAGE.Set_Name ('AMS', 'AMS_METR_INVALID_CALC_FUNC');
                     FND_MSG_PUB.ADD;
                  END IF;
                  x_return_status := FND_API.G_RET_STS_ERROR;
                  RETURN;
               END IF; -- function_name is not null
            END IF; -- metric_calculation_type = 'FUNCTION'
         END IF; -- compute_using_function is not null
      ELSIF p_complete_rec.accrual_type = G_VARIABLE THEN
      /** NOT TRUE ANY MORE
         IF p_complete_rec.function_name IS NOT NULL THEN
            IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
               FND_MESSAGE.Set_Name ('AMS', 'AMS_METR_INVALID_ACCR_FUN');
               FND_MSG_PUB.ADD;
            END IF;
            x_return_status := FND_API.G_RET_STS_ERROR;
            RETURN;
         END IF; -- function_name is not null
      **/
         IF p_complete_rec.compute_using_function IS NULL THEN
            IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
               FND_MESSAGE.Set_Name ('AMS', 'AMS_METR_INVALID_COMP_FUNC');
               FND_MSG_PUB.ADD;
            END IF;
            x_return_status := FND_API.G_RET_STS_ERROR;
            RETURN;
         ELSE
            OPEN c_check_multiplier(
                 to_number(p_complete_rec.compute_using_function));
            l_category_id := null;
            l_object_type := null;
            l_calculation_type := null;
            FETCH c_check_multiplier
                INTO l_category_id, l_object_type, l_calculation_type;
            IF c_check_multiplier%NOTFOUND THEN
               IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                  FND_MESSAGE.Set_Name ('AMS', 'AMS_METR_INVALID_MULTI_METR');
                  FND_MSG_PUB.ADD;
               END IF;
               x_return_status := FND_API.G_RET_STS_ERROR;
            END IF;
            CLOSE c_check_multiplier;
            IF l_category_id IN (G_COST_ID,G_REVENUE_ID) THEN
               IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                  OPEN c_get_category_name(l_category_id);
                  FETCH c_get_category_name INTO l_name;
                  CLOSE c_get_category_name;
                  FND_MESSAGE.Set_Name ('AMS', 'AMS_METR_INVALID_MULTI_CAT');
                  FND_MESSAGE.set_token('CATEGORY',
                          NVL(l_name,to_char(l_category_id)), FALSE);
                  FND_MSG_PUB.ADD;
               END IF;
               x_return_status := FND_API.G_RET_STS_ERROR;
            END IF;
            IF l_object_type <> p_complete_rec.arc_metric_used_for_object THEN
               IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                  FND_MESSAGE.Set_Name ('AMS', 'AMS_METR_INVALID_MULTI_OBJ');
                  l_name := AMS_UTILITY_PVT.get_lookup_meaning(
                         'AMS_METRIC_OBJECT_TYPE',l_object_type);
                  FND_MESSAGE.set_token('OBJECT',
                         NVL(l_name,l_object_type), FALSE);
                  FND_MSG_PUB.ADD;
               END IF;
               x_return_status := FND_API.G_RET_STS_ERROR;
            END IF;
            IF l_calculation_type NOT IN (G_MANUAL, G_FUNCTION) THEN
               IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                  FND_MESSAGE.Set_Name ('AMS', 'AMS_METR_INVALID_MULTI_CALC');
                  l_name := AMS_UTILITY_PVT.get_lookup_meaning(
                         'AMS_METRIC_CALCULATION_TYPE',l_calculation_type);
                  FND_MESSAGE.set_token('CALCULATION',
                         NVL(l_name,l_calculation_type), FALSE);
                  FND_MSG_PUB.ADD;
               END IF;
               x_return_status := FND_API.G_RET_STS_ERROR;
            END IF;
         END IF; -- compute_using_function is null

      END IF; -- accrual_type = 'FIXED'
--   END IF; --  metric_calculation_type <> G_MISS_CHAR

   --
   -- Begin Other Business Rule Validations
   --
/*****
   IF (l_metrics_rec.metric_parent_id <> FND_API.G_MISS_NUM     OR
      l_metrics_rec.summary_metric_id <> FND_API.G_MISS_NUM )  AND
      (l_metrics_rec.metric_parent_id IS NOT NULL     OR
      l_metrics_rec.summary_metric_id IS NOT NULL      )
   THEN
      IF l_metrics_rec.metric_parent_id = FND_API.G_MISS_NUM THEN
         l_metrics_rec.metric_parent_id := p_complete_rec.metric_parent_id ;
      END IF;

      IF l_metrics_rec.summary_metric_id = FND_API.G_MISS_NUM THEN
         l_metrics_rec.summary_metric_id := p_complete_rec.summary_metric_id ;
      END IF;
/* **** DMVINCEN 04/27/2001 - Allow both same level and parent level.
      IF (l_metrics_rec.summary_metric_id <> FND_API.G_MISS_NUM AND
         l_metrics_rec.metric_parent_id  <> FND_API.G_MISS_NUM ) AND
         (l_metrics_rec.summary_metric_id IS NOT NULL  AND
         l_metrics_rec.metric_parent_id  IS NOT NULL  )
      THEN
         IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
            FND_MESSAGE.Set_Name ('AMS', 'AMS_METR_INVALID_ROLL_SUMM');
            FND_MSG_PUB.Add;
         END IF;
         x_return_status := FND_API.G_RET_STS_ERROR;
         RETURN;
      END IF;
***** * /
   END IF;
****/
   -- DMVINCEN 04/27/2001 - Summary metrics may not rollup.
   IF p_complete_rec.metric_calculation_type = G_SUMMARY AND
      p_complete_rec.metric_parent_id IS NOT NULL --AND
      --l_metrics_rec.metric_parent_id <> FND_API.G_MISS_NUM
   THEN
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
         FND_MESSAGE.Set_Name ('AMS', 'AMS_METR_SUMM_NOT_ROLL');
         FND_MSG_PUB.ADD;
      END IF;
      x_return_status := FND_API.G_RET_STS_ERROR;
      RETURN;
   END IF;

   -- Validate ROLLUP_METRIC_ID

   IF --l_metrics_rec.metric_parent_id <> FND_API.G_MISS_NUM AND
      p_complete_rec.metric_parent_id IS NOT NULL THEN

   -- Check if this Parent Metric is Summary Metric of any other Metric
   OPEN c_summary_count(p_complete_rec.metric_id);
   FETCH c_summary_count INTO l_count;
   CLOSE c_summary_count;

   IF l_count > 0 THEN
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
         FND_MESSAGE.Set_Name ('AMS', 'AMS_METR_INVALID_ROLL_SUMM');
         FND_MSG_PUB.ADD;
      END IF;

      x_return_status := FND_API.G_RET_STS_ERROR;
      RETURN;
   END IF;

   OPEN c_rollup_metric(p_complete_rec.metric_parent_id);
   FETCH c_rollup_metric INTO l_rollup_metric_rec;
   --
   -- Don't have to verify that the metric exists
   -- because we already did the referential integrity
   -- check earlier.
   --
   CLOSE c_rollup_metric;

   -- Check whether the child metric is attached to a activity
   -- which is child of the activity attached to Parent metric
   -- (For e.g. If Metric M1 is Attached to Campaign C1, Metric M1a rolls up
   -- into M1 and is Attached to schedule Csh1 THEN csh1 must be child of
   -- Campaign C1

   -- 12/16/2001 dmvincen : Any parent type is valid.
--    Check_Valid_Parent(
--       p_metric_used_by => l_metrics_rec.arc_metric_used_for_object,
--       p_parent_metric_used_by => l_rollup_metric_rec.arc_metric_used_for_object,
--       x_return_status                 => x_return_status );


--       IF x_return_status =  FND_API.G_RET_STS_ERROR THEN
--
--          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
--             FND_MESSAGE.Set_Name ('AMS', 'AMS_METR_INVALID_PARENT');
--             FND_MSG_PUB.ADD;
--          END IF;
--          RETURN;
--       END IF;

      -- METRIC_CATEGORY
--      IF l_metrics_rec.metric_category = FND_API.G_MISS_NUM THEN
--         l_metrics_rec.metric_category := p_complete_rec.metric_category ;
--      END IF;
      -- The parent rollup metric category must be the same as the child's.
      IF p_complete_rec.metric_category <> l_rollup_metric_rec.metric_category
      THEN
         IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
            FND_MESSAGE.Set_Name ('AMS', 'AMS_METR_INVALID_ROLL_CAT');
            FND_MSG_PUB.ADD;
         END IF;

         x_return_status := FND_API.G_RET_STS_ERROR;
         RETURN;
      END IF;

      -- VALUE_TYPE
      -- The parent rollup metric return type must be the same as the child's.
      -- i.e. Numeric Metric can not be rolled up into Ratio Metric
--      IF l_metrics_rec.value_type = FND_API.G_MISS_CHAR THEN
--         l_metrics_rec.value_type := p_complete_rec.value_type ;
--      END IF;

      IF p_complete_rec.value_type <> l_rollup_metric_rec.value_type THEN
         IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
            FND_MESSAGE.Set_Name ('AMS', 'AMS_METR_INVALID_ROLL_VAL');
            FND_MSG_PUB.ADD;
         END IF;

         x_return_status := FND_API.G_RET_STS_ERROR;
         RETURN;
      END IF;

      -- UOM_TYPE
      -- The parent rollup metric unit of measure must be the same as the child's.
--      IF l_metrics_rec.uom_type = FND_API.G_MISS_CHAR THEN
--         l_metrics_rec.uom_type := p_complete_rec.uom_type ;
--      END IF;

      IF p_complete_rec.uom_type <> l_rollup_metric_rec.uom_type THEN
         IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
            FND_MESSAGE.Set_Name ('AMS', 'AMS_METR_INVALID_ROLL_UOM');
            FND_MSG_PUB.ADD;
         END IF;

         x_return_status := FND_API.G_RET_STS_ERROR;
         RETURN;
      END IF;


      -- Following Code is Commented by ptendulk as Metric can never be
      -- Rolledup into Metric of same Usage type

      -- ARC_METRIC_USED_FOR_OBJECT
      -- The return value type of the parent metric must be the same as
      -- that of the child's.
--      IF l_metrics_rec.arc_metric_used_for_object <>
--           l_rollup_metric_rec.arc_metric_used_for_object THEN
--         IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
--            FND_MESSAGE.Set_Name ('AMS', 'AMS_ARC_QUALIFIER_NOT_SAME');
--            FND_MESSAGE.Set_Token ('PARAM', l_lookup_type, FALSE);
--            FND_MSG_PUB.Add;
--         END IF;
--
--         x_return_status := FND_API.G_RET_STS_ERROR;
--      END IF;

   END IF;

      -- Validate SUMMARY_METRIC_ID
   IF --l_metrics_rec.summary_metric_id <>  FND_API.G_MISS_NUM AND
      p_complete_rec.summary_metric_id IS NOT NULL  THEN
      -- Check if this Parent Metric is Rollup Metric of any other Metric
      /*****
      OPEN c_rollup_count(p_complete_rec.metric_id);
      FETCH c_rollup_count INTO l_count;
      CLOSE c_rollup_count;

      IF l_count > 0 THEN
         IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
            FND_MESSAGE.Set_Name ('AMS', 'AMS_METR_INVALID_ROLL_SUMM');
            FND_MSG_PUB.ADD;
         END IF;

         x_return_status := FND_API.G_RET_STS_ERROR;
         RETURN;
      END IF;
      ****/
      OPEN c_summary_metric(p_complete_rec.summary_metric_id);
      FETCH c_summary_metric INTO l_summary_metric_rec;
      --
      -- Don't have to verify that the metric exists
      -- because we already did the referential integrity
      -- check earlier.
      --
      CLOSE c_summary_metric;

      -- METRIC_CATEGORY
--      IF l_metrics_rec.metric_category = FND_API.G_MISS_NUM THEN
--         l_metrics_rec.metric_category := p_complete_rec.metric_category ;
--      END IF;
      -- The parent rollup metric category must be the same as the child's.
      IF p_complete_rec.metric_category <> l_summary_metric_rec.metric_category
      THEN
         IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
            FND_MESSAGE.Set_Name ('AMS', 'AMS_METR_INVALID_SUMM_CAT');
            FND_MSG_PUB.ADD;
         END IF;

         x_return_status := FND_API.G_RET_STS_ERROR;
         RETURN;
      END IF;

      -- UOM_TYPE
      --    IF l_metrics_rec.uom_type = FND_API.G_MISS_CHAR THEN
      --           l_metrics_rec.uom_type := p_complete_rec.uom_type ;
      --    END IF;
      -- The parent rollup metric unit of measure must be the same as the child's.
      IF p_complete_rec.uom_type <> l_summary_metric_rec.uom_type THEN
         IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
            FND_MESSAGE.Set_Name ('AMS', 'AMS_METR_INVALID_SUMM_UOM');
            FND_MSG_PUB.ADD;
         END IF;

         x_return_status := FND_API.G_RET_STS_ERROR;
         RETURN;
      END IF;

      -- VALUE_TYPE
      --    IF l_metrics_rec.value_type = FND_API.G_MISS_CHAR THEN
      --           l_metrics_rec.value_type := p_complete_rec.value_type ;
      --    END IF;
      -- The return value type of the parent metric must be the same
      -- as that of the child's.
      IF p_complete_rec.value_type <> l_summary_metric_rec.value_type THEN
         IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
            FND_MESSAGE.Set_Name ('AMS', 'AMS_METR_INVALID_SUMM_VAL');
            FND_MSG_PUB.ADD;
         END IF;

         x_return_status := FND_API.G_RET_STS_ERROR;
         RETURN;
      END IF;

      -- ARC_METRIC_USED_FOR_OBJECT
      --IF l_metrics_rec.arc_metric_used_for_object = FND_API.G_MISS_CHAR THEN
      --   l_metrics_rec.arc_metric_used_for_object :=
      --      p_complete_rec.arc_metric_used_for_object ;
      --END IF;
      -- The return value type of the parent metric must be the same as that
      -- of the child's.
      --06/07/2001 huili allow rollup metric to summarize to metrics of
      --different business types
      -- 03/13/2002 dmvincen: Summary and Rollup have object type of ANY.
      -- This code is not applicable.
--      IF l_metrics_rec.arc_metric_used_for_object <>
--          l_summary_metric_rec.arc_metric_used_for_object
--         AND l_metrics_rec.metric_calculation_type <> G_ROLLUP THEN
--         IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
--            FND_MESSAGE.Set_Name ('AMS', 'AMS_METR_INVALID_SUMM_OBJ');
--            FND_MSG_PUB.ADD;
--         END IF;

--         x_return_status := FND_API.G_RET_STS_ERROR;
--         RETURN;
--      END IF;
   END IF;

    --06/22/2001 huili recovered
    --06/14/2001 huili comment out
    --huili added on 05/10/2001
   IF p_complete_rec.accrual_type = 'VARIABLE'
      AND p_complete_rec.metric_category <> 901
      AND p_complete_rec.metric_category <> 902 THEN
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
         FND_MESSAGE.Set_Name ('AMS', 'AMS_METR_INVALID_CATEGORY');
         FND_MSG_PUB.ADD;
      END IF;
      x_return_status := FND_API.G_RET_STS_ERROR;
      RETURN;
   END IF;

   -- 04-OCT-2001 DMVINCEN New object type for summary and rollup.
   IF p_complete_rec.arc_metric_used_for_object <> 'ANY' AND
      p_complete_rec.metric_calculation_type IN (G_ROLLUP, G_SUMMARY)
   THEN
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
         FND_MESSAGE.Set_Name ('AMS', 'AMS_METR_INVALID_USED_CALC');
         FND_MSG_PUB.ADD;
      END IF;

      x_return_status := FND_API.G_RET_STS_ERROR;
      RETURN;
   END IF;

   -- 04-OCT-2001 DMVINCEN New object type for summary and rollup.
   IF p_complete_rec.arc_metric_used_for_object = 'ANY' AND
      p_complete_rec.metric_calculation_type NOT IN (G_ROLLUP, G_SUMMARY, G_FORMULA)
   THEN
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
         FND_MESSAGE.Set_Name ('AMS', 'AMS_METR_INVALID_CALC_USED');
         FND_MSG_PUB.ADD;
      END IF;

      x_return_status := FND_API.G_RET_STS_ERROR;
      RETURN;
   END IF;

EXCEPTION
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          RETURN ;

END Validate_Metric_record;

--
-- Start of comments.
--
-- NAME
--    Validate_Metric_Items
--
-- PURPOSE
--    Perform All Item level validation for metrics.
--
-- NOTES
--
-- HISTORY
-- 10/11/1999     ptendulk            Created.
--
-- End of comments.

PROCEDURE Validate_Metric_items(
   p_metric_rec        IN  metric_rec_type,
   p_validation_mode   IN  VARCHAR2 := JTF_PLSQL_API.g_create,
   x_return_status     OUT NOCOPY VARCHAR2
)
IS
BEGIN
   Check_Req_Metrics_Items(
      p_metric_rec       => p_metric_rec,
      x_return_status    => x_return_status
   );

   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   Check_Metric_Uk_Items(
      p_metric_rec        => p_metric_rec,
      p_validation_mode   => p_validation_mode,
      x_return_status     => x_return_status
   );

   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   Check_Metric_Items(
      p_metric_rec     => p_metric_rec,
      x_return_status  => x_return_status
   );

   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;



END Validate_Metric_items;


--
-- Start of comments.
--
-- NAME
--    Validate_Metric_Child
--
-- PURPOSE
--    Perform child entity validation for metrics.
--
-- NOTES
--
-- HISTORY
-- 05/26/1999     choang            Created.
--
-- End of comments.

PROCEDURE Validate_Metric_Child (
   p_metric_id        IN  NUMBER,
   x_return_status    OUT NOCOPY VARCHAR2
)
IS
--   l_item_name      VARCHAR2(30);  -- Used to standardize error messages.
   l_metric_id        NUMBER := p_metric_id;
   l_return_status    VARCHAR2(1);

    CURSOR c_check_metric_id(p_metric_id number) IS
    SELECT 1 from AMS_ACT_METRICS_ALL
    WHERE METRIC_ID = p_metric_id ;


BEGIN
   -- Initialize return status to success.
   x_return_status := FND_API.G_RET_STS_SUCCESS;

    OPEN c_check_metric_id(l_metric_id);
    IF c_check_metric_id%NOTFOUND
    THEN
                 x_return_status := FND_API.G_RET_STS_ERROR;
         RETURN;
        END IF;
     CLOSE c_check_metric_id;



   -- AMS_ACT_METRICS_ALL
   /*IF Ams_Utility_Pvt.Check_FK_Exists (
            p_table_name          => 'AMS_ACT_METRICS_ALL',
            p_pk_name             => 'METRIC_ID',
            p_pk_value            => l_metric_id,
            p_pk_data_type        => Ams_Utility_Pvt.G_NUMBER
         ) = FND_API.G_TRUE
   THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      RETURN;
   END IF;
*/
   -- Do not validate FK if NULL
--   IF l_metrics_rec.metric_parent_id IS NULL THEN
--      l_metrics_validate_fk_rec.metric_parent_id := FND_API.G_FALSE;
--   END IF;
--   IF l_metrics_validate_fk_rec.metric_parent_id = FND_API.G_TRUE THEN
      -- AMS_METRICS_VL
      -- Start of the changes made by PTENDULK on 08/19/1999
      -- The check is modified to check whether this metric id is parent metric
      -- id of any other id

      -- Original Code

--       IF AMS_Utility_PVT.Check_FK_Exists (
--            p_table_name          => 'AMS_METRICS_VL',
--            p_pk_name             => 'METRIC_ID',
--            p_pk_value            => l_metrics_rec.metric_parent_id
--         ) = FND_API.G_TRUE
--      THEN
      -- Modified Code

      --
      -- Check that the metric is not used by another metric as
      -- it's parent.

-- comment out the following for bug 1356700 fix
-- 07/17/2000 khung
--      IF AMS_Utility_PVT.Check_FK_Exists (
--            p_table_name          => 'AMS_METRICS_VL',
--            p_pk_name             => 'METRIC_PARENT_ID',
--            p_pk_value            => l_metric_id,
--            p_pk_data_type        => AMS_Utility_PVT.G_NUMBER
--         ) = FND_API.G_TRUE
      -- End of the changes made by PTENDULK on 08/19/1999
--      THEN
--            IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
--            THEN
--               FND_MESSAGE.Set_Name('AMS', 'AMS_METR_CHILD_EXIST');
--               FND_MSG_PUB.Add;
--            END IF;
--         x_return_status := FND_API.G_RET_STS_ERROR;
--         RETURN;
--     END IF;
-- end of change 07/17/2000 khung

--   IF l_metrics_rec.summary_metric_id IS NULL THEN
--      l_metrics_validate_fk_rec.summary_metric_id := FND_API.G_FALSE;
--   END IF;
--   IF l_metrics_validate_fk_rec.summary_metric_id = FND_API.G_TRUE THEN
      -- AMS_METRICS_VL
      -- Start of the changes made by PTENDULK on 08/19/1999
      -- The check is modified to check whether this metric id is Summary metric
      -- id of any other metric id
      -- Original Code
--      IF AMS_Utility_PVT.Check_FK_Exists (
--            p_table_name          => 'AMS_METRICS_VL',
--            p_pk_name             => 'METRIC_ID',
--            p_pk_value            => l_metrics_rec.summary_metric_id
--         ) = FND_API.G_TRUE

      -- Modified Code
      --
      -- Check that the metric is not used by another metric as
      -- it's summary rollup.

-- comment out the following for bug 1356700 fix
-- 07/17/2000 khung
--      IF AMS_Utility_PVT.Check_FK_Exists (
--            p_table_name          => 'AMS_METRICS_VL',
--            p_pk_name             => 'SUMMARY_METRIC_ID',
--            p_pk_value            => l_metric_id,
--            p_pk_data_type        => AMS_Utility_PVT.G_NUMBER
--         ) = FND_API.G_TRUE
-- End of the changes made by PTENDULK on 08/19/1999
--      THEN

--         IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
--         THEN
--            FND_MESSAGE.Set_Name('AMS', 'AMS_METR_CHILD_EXIST');
--            FND_MSG_PUB.Add;
--         END IF;
--         x_return_status := FND_API.G_RET_STS_ERROR;
--         RETURN;
--      END IF;
-- end of change 07/17/2000 khung
EXCEPTION
   WHEN OTHERS THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          RETURN ;
END Validate_Metric_Child;

--
-- Begin of section added by ptendulk - 10/11/1999
--
-- NAME
--    Complete_Metric_Rec
--
-- PURPOSE
--   Return the functional forecasted value, committed value, actual
--   value, and the functional currency code for a given metric.
--
-- NOTES
--
-- HISTORY
-- 07/19/1999   choang   Created.
-- 17-Apr-2000  tdonohoe Added columns to support 11.5.2 release.
--
PROCEDURE Complete_Metric_Rec(
   p_metric_rec      IN  metric_rec_type,
   x_complete_rec    IN OUT NOCOPY metric_rec_type,
   x_old_metric_rec  IN OUT NOCOPY metric_rec_type,
   x_seeded_ok       IN OUT NOCOPY BOOLEAN
)
IS
   CURSOR c_metric(p_metric_id number) return metric_rec_type IS
   SELECT metric_id
          ,last_update_date
          ,last_updated_by
          ,creation_date
          ,created_by
          ,last_update_login
          ,object_version_number
          ,application_id
          ,arc_metric_used_for_object
          ,metric_calculation_type
          ,metric_category
          ,accrual_type
          ,value_type
          ,sensitive_data_flag
          ,enabled_flag
          ,metric_sub_category
          ,function_name
          ,metric_parent_id
          ,summary_metric_id
          ,compute_using_function
          ,default_uom_code
          ,uom_type
          ,formula
          ,metrics_name
          ,description
          ,formula_display
          ,hierarchy_id
          ,set_function_name
          ,display_type
			 ,target_type
			 ,denorm_code
     FROM ams_metrics_vl
    WHERE metric_id = p_metric_rec.metric_id;

   --l_metric_rec  c_metric%ROWTYPE;
BEGIN

   x_complete_rec := p_metric_rec;

   OPEN c_metric(p_metric_rec.metric_id);
   FETCH c_metric INTO x_old_metric_rec;
   IF c_metric%NOTFOUND THEN
      CLOSE c_metric;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
         FND_MSG_PUB.ADD;
      END IF;
      RAISE FND_API.g_exc_error;
   END IF;
   CLOSE c_metric;

   IF p_metric_rec.application_id = FND_API.G_MISS_NUM THEN
      x_complete_rec.application_id := x_old_metric_rec.application_id;
   END IF;

   IF p_metric_rec.arc_metric_used_for_object = FND_API.G_MISS_CHAR THEN
      x_complete_rec.arc_metric_used_for_object := x_old_metric_rec.arc_metric_used_for_object;
   END IF;

   IF p_metric_rec.metric_calculation_type    = FND_API.G_MISS_CHAR THEN
      x_complete_rec.metric_calculation_type := x_old_metric_rec.metric_calculation_type ;
   END IF;

   IF p_metric_rec.metric_category   = FND_API.G_MISS_NUM THEN
      x_complete_rec.metric_category  := x_old_metric_rec.metric_category  ;
   END IF;

   IF p_metric_rec.accrual_type    = FND_API.G_MISS_CHAR THEN
      x_complete_rec.accrual_type  := x_old_metric_rec.accrual_type  ;
   END IF;

   IF p_metric_rec.value_type    = FND_API.G_MISS_CHAR THEN
      x_complete_rec.value_type  := x_old_metric_rec.value_type  ;
   END IF;

   IF p_metric_rec.sensitive_data_flag    = FND_API.G_MISS_CHAR THEN
      x_complete_rec.sensitive_data_flag  := x_old_metric_rec.sensitive_data_flag;
   END IF;

   IF p_metric_rec.enabled_flag      = FND_API.G_MISS_CHAR THEN
      x_complete_rec.enabled_flag    := x_old_metric_rec.enabled_flag    ;
   END IF;

   IF p_metric_rec.metric_sub_category      = FND_API.G_MISS_NUM THEN
      x_complete_rec.metric_sub_category := x_old_metric_rec.metric_sub_category ;
   END IF;

   IF p_metric_rec.function_name    = FND_API.G_MISS_CHAR THEN
      x_complete_rec.function_name := x_old_metric_rec.function_name ;
   END IF;

   IF p_metric_rec.metric_parent_id   = FND_API.G_MISS_NUM THEN
      x_complete_rec.metric_parent_id := x_old_metric_rec.metric_parent_id       ;
   END IF;

   IF p_metric_rec.enabled_flag      = FND_API.G_MISS_CHAR THEN
      x_complete_rec.enabled_flag    := x_old_metric_rec.enabled_flag    ;
   END IF;

   IF p_metric_rec.summary_metric_id     = FND_API.G_MISS_NUM THEN
      x_complete_rec.summary_metric_id := x_old_metric_rec.summary_metric_id ;
   END IF;

   IF p_metric_rec.compute_using_function   = FND_API.G_MISS_CHAR THEN
      x_complete_rec.compute_using_function := x_old_metric_rec.compute_using_function ;
   END IF;

   IF p_metric_rec.default_uom_code   = FND_API.G_MISS_CHAR THEN
      x_complete_rec.default_uom_code := x_old_metric_rec.default_uom_code     ;
   END IF;

   IF p_metric_rec.uom_type    = FND_API.G_MISS_CHAR THEN
      x_complete_rec.uom_type  := x_old_metric_rec.uom_type   ;
   END IF;

   IF p_metric_rec.formula    = FND_API.G_MISS_CHAR THEN
      x_complete_rec.formula  := x_old_metric_rec.formula         ;
   END IF;

   IF p_metric_rec.metrics_name  = FND_API.G_MISS_CHAR THEN
      x_complete_rec.metrics_name  := x_old_metric_rec.metrics_name   ;
   END IF;

   IF p_metric_rec.description    = FND_API.G_MISS_CHAR THEN
      x_complete_rec.description  := x_old_metric_rec.description;
   END IF;

   IF p_metric_rec.formula_display    = FND_API.G_MISS_CHAR THEN
      x_complete_rec.formula_display  := x_old_metric_rec.formula_display;
   END IF;

   -- 17-Apr-2000 tdonohoe@us added.
   IF p_metric_rec.hierarchy_id    = FND_API.G_MISS_NUM THEN
      x_complete_rec.hierarchy_id  := x_old_metric_rec.hierarchy_id;
   END IF;

   -- 17-Apr-2000 tdonohoe@us added.
   IF p_metric_rec.set_function_name    = FND_API.G_MISS_CHAR THEN
      x_complete_rec.set_function_name  := x_old_metric_rec.set_function_name;
   END IF;

   if p_metric_rec.display_type = FND_API.G_MISS_CHAR then
      x_complete_rec.display_type := x_old_metric_rec.display_type;
   end if;

   if p_metric_rec.target_type = FND_API.G_MISS_CHAR then
      x_complete_rec.target_type := x_old_metric_rec.target_type;
   end if;

   if p_metric_rec.denorm_code = FND_API.G_MISS_CHAR then
      x_complete_rec.denorm_code := x_old_metric_rec.denorm_code;
   end if;

   x_seeded_ok := TRUE;

   IF x_old_metric_rec.metrics_name <> x_complete_rec.metrics_name OR
      x_old_metric_rec.application_id <> x_complete_rec.application_id OR
      x_old_metric_rec.arc_metric_used_for_object <> x_complete_rec.arc_metric_used_for_object OR
      x_old_metric_rec.metric_calculation_type <> x_complete_rec.metric_calculation_type OR
      x_old_metric_rec.metric_category <> x_complete_rec.metric_category OR
      x_old_metric_rec.accrual_type <> x_complete_rec.accrual_type OR
      x_old_metric_rec.value_type <> x_complete_rec.value_type OR
      x_old_metric_rec.sensitive_data_flag <> x_complete_rec.sensitive_data_flag OR
      NVL(x_old_metric_rec.metric_sub_category,FND_API.G_MISS_NUM) <>
         NVL(x_complete_rec.metric_sub_category,FND_API.G_MISS_NUM) OR
      NVL(x_old_metric_rec.function_name,FND_API.G_MISS_CHAR) <>
         NVL(x_complete_rec.function_name,FND_API.G_MISS_CHAR) OR
      NVL(x_old_metric_rec.metric_parent_id,FND_API.G_MISS_NUM) <>
         NVL(x_complete_rec.metric_parent_id,FND_API.G_MISS_NUM) OR
      NVL(x_old_metric_rec.summary_metric_id,FND_API.G_MISS_NUM) <>
         NVL(x_complete_rec.summary_metric_id,FND_API.G_MISS_NUM) OR
      NVL(x_old_metric_rec.compute_using_function,FND_API.G_MISS_CHAR) <>
         NVL(x_complete_rec.compute_using_function,FND_API.G_MISS_CHAR) OR
      NVL(x_old_metric_rec.default_uom_code,FND_API.G_MISS_CHAR) <>
         NVL(x_complete_rec.default_uom_code,FND_API.G_MISS_CHAR) OR
      NVL(x_old_metric_rec.uom_type,FND_API.G_MISS_CHAR) <>
         NVL(x_complete_rec.uom_type,FND_API.G_MISS_CHAR) OR
      NVL(x_old_metric_rec.formula,FND_API.G_MISS_CHAR) <>
         NVL(x_complete_rec.formula,FND_API.G_MISS_CHAR) OR
      NVL(x_old_metric_rec.hierarchy_id,FND_API.G_MISS_NUM) <>
         NVL(x_complete_rec.hierarchy_id,FND_API.G_MISS_NUM) OR
      NVL(x_old_metric_rec.set_function_name,FND_API.G_MISS_CHAR) <>
         NVL(x_complete_rec.set_function_name,FND_API.G_MISS_CHAR) THEN
      x_seeded_ok := FALSE;
   END IF;
END Complete_Metric_Rec ;

--
-- End of section added by choang.
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
--    less than 10,000.
--
-- HISTORY
-- 07/19/1999   choang         Created.
-- 01/16/00     bgeorge         Modified to check for ID <10000
--
FUNCTION IsSeeded (
   p_id        IN NUMBER
)
RETURN BOOLEAN
IS
BEGIN
   IF p_id < 10000 THEN
      RETURN TRUE;
   END IF;

   RETURN FALSE;
END IsSeeded;


-- NAME
--    Validate_Metric_Program
--
-- PURPOSE
--    Validate the metric program and determine whether it is
--    a function or procedure.
--
-- Logic of validation:
--
--   Validate the custom code for a function:
--
--   If Yes: Set the function Type to 'Y' and return success.
--
--   If No: Validate the custom code for a procedure, check is made
--          for the validation to go thru for both UI level and refresh
--          and system level refresh.
--
--     If Yes: Set the function type to 'N' and return success.
--
--     If NO: Set the function type to null and return error with
--            the error message.
--
-- NOTES
--
-- HISTORY
-- 06/18/2004     sunkumar  Created.
-- 08/09/2004     sunkumar  Validation ammendment.
-- 11/10/2004     dmvincen  BUG 3792709: Fixed validation logic.

PROCEDURE Validate_Metric_Program (
   p_func_name        IN VARCHAR2,
   x_func_type        OUT NOCOPY VARCHAR2,
   x_return_status    OUT NOCOPY VARCHAR2
)
IS

   l_parse_string varchar2(4000);
   l_return_status   VARCHAR2(1); -- Return value from procedures.
   l_func_type       VARCHAR2(1) := NULL;

   BEGIN

   x_func_type := NULL;
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   l_parse_string := 'DECLARE l_num_value NUMBER; Begin l_num_value := '||
                      p_func_name || '(10000); end;';

   IF Is_Valid_Metric_Program (p_exec_string => l_parse_string) THEN

      x_func_type := 'Y';

   ELSE

      l_parse_string := 'begin '|| p_func_name ||'; end;';

      IF Is_Valid_Metric_Program (p_exec_string => l_parse_string) THEN

         l_parse_string := 'begin '|| p_func_name ||'(''CSCH'', 10000); end;';

         IF Is_Valid_Metric_Program (p_exec_string => l_parse_string) THEN

            x_func_type := 'N';

         END IF;

      END IF;

   END IF;

   IF x_func_type is null THEN

      FND_MESSAGE.Set_Name ('AMS', 'AMS_MET_FUNC_INVALID_DETAILS');
      FND_MSG_PUB.ADD;
      x_return_status := FND_API.G_RET_STS_ERROR;

   END IF;

 END Validate_Metric_Program;




--
-- Start of comments.
--
-- NAME
--    Is_Valid_Metric_Program
--
-- PURPOSE
--    Checks wether the custom procedure/function is a valid one
--
-- NOTES
--
-- HISTORY
-- 06/18/2004     sunkumar            Created.
-- 08/09/2004     sunkumar            indentation
--
-- End of comments.

FUNCTION Is_Valid_Metric_Program (
   p_exec_string   IN VARCHAR2
) RETURN BOOLEAN
IS
   cursor_num integer;
BEGIN

   cursor_num := dBMS_sql.open_cursor;
   dbms_sql.parse(cursor_num, p_exec_string, dbms_sql.native);
   dbms_sql.close_cursor(cursor_num);

RETURN TRUE;
EXCEPTION
  WHEN OTHERS THEN
  dbms_sql.close_cursor(cursor_num);
  RETURN FALSE;
END Is_Valid_Metric_Program;

END Ams_Metric_Pvt;

/
