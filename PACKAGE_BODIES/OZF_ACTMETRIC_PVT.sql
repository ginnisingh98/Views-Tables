--------------------------------------------------------
--  DDL for Package Body OZF_ACTMETRIC_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_ACTMETRIC_PVT" AS
/* $Header: ozfvamtb.pls 120.1.12010000.2 2008/08/05 09:08:22 kdass ship $ */

------------------------------------------------------------------------------
--
-- NAME
--    OZF_ActMetric_PVT  11.5.10
--
-- HISTORY
-- 05/07/2003  KDASS     migrate to ozf from ams_actmetric_pvt for budget allocation, quota allocation and forecast
-- Fri Nov 21 2003:5/42 PM RSSHARMA     Changed reference to ams_terr_v to ozf_terr_v
-- kvattiku April 23, 04 Update extra paramters in Quota
-- rimehrot May 7, 04    Added error message for Quota and changed all error messages to OZF from AMS.
-----------------------------------------------------------------------------

--
-- Global variables and constants.

G_PKG_NAME CONSTANT VARCHAR2(30) := 'OZF_ACTMETRIC_PVT'; -- Name of the current package.
G_DEBUG_FLAG                  VARCHAR2(1)  := 'N';
G_CREATE  VARCHAR2(30) := 'CREATE';
G_UPDATE  VARCHAR2(30) := 'UPDATE';
G_DELETE  VARCHAR2(30) := 'DELETE';
G_CATEGORY_COSTS        CONSTANT NUMBER := 901;
G_CATEGORY_REVENUES     CONSTANT NUMBER := 902;
TYPE date_bucket_type IS TABLE OF DATE;
TYPE number_table IS TABLE OF NUMBER;

-- Forward Declarations Begin
OZF_DEBUG_HIGH_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
OZF_DEBUG_LOW_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
OZF_DEBUG_MEDIUM_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

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
-- Forward Declarations End


PROCEDURE Create_ActMetric (
   p_api_version                IN  NUMBER,
   p_init_msg_list              IN  VARCHAR2 := Fnd_Api.G_FALSE,
   --p_commit                     IN  VARCHAR2 := Fnd_Api.G_FALSE,
   p_commit                     IN  VARCHAR2 := Fnd_Api.G_TRUE,
   p_validation_level           IN  NUMBER   := Fnd_Api.G_Valid_Level_Full,

   x_return_status              OUT NOCOPY VARCHAR2,
   x_msg_count                  OUT NOCOPY NUMBER,
   x_msg_data                   OUT NOCOPY VARCHAR2,

   p_act_metric_rec             IN  act_metric_rec_type,
   x_activity_metric_id         OUT NOCOPY NUMBER
) IS

   L_API_NAME        CONSTANT VARCHAR2(30) := 'Create_ActMetric';
BEGIN

   SAVEPOINT sp_create_actmetric;

   x_return_status      := Fnd_Api.G_RET_STS_SUCCESS;
   x_activity_metric_id := NULL;

   LOCK TABLE OZF_ACT_METRICS_ALL IN EXCLUSIVE MODE;

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
   x_act_metric_rec  IN OUT NOCOPY  Ozf_Actmetric_Pvt.Act_metric_rec_type
)  IS
BEGIN
   RETURN;
END Init_ActMetric_Rec;






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

   -- 05/22/2002 yzhao: 11.5.9 default setting for budget allocation
   IF (x_complete_rec.arc_act_metric_used_by='FUND') THEN
       IF (x_complete_rec.hierarchy_type IN ('BUDGET_HIER', 'BUDGET_CATEGORY', 'HR_ORG') ) THEN
           -- set start_level, end_level for budget allocation
           IF (x_complete_rec.from_level IS NULL OR
               x_complete_rec.from_level = Fnd_Api.G_MISS_NUM) THEN
               x_complete_rec.from_level := 1;
           END IF;
           IF (x_complete_rec.to_level IS NULL OR
               x_complete_rec.to_level = Fnd_Api.G_MISS_NUM) THEN
               x_complete_rec.to_level :=  OZF_Fund_allocations_Pvt.g_max_end_level;
           END IF;

           -- set 'Ex-Start-Node' if 'ADD ONTO EXISTING BUDGET' and start node is the same as the budget
           IF (x_complete_rec.action_code = 'TRANSFER_TO_BUDGET' AND
               x_complete_rec.start_node = x_complete_rec.act_metric_used_by_id) THEN
               x_complete_rec.ex_start_node := 'Y';
           ELSE
               x_complete_rec.ex_start_node := 'N';
           END IF;
       END IF;

   END IF;
   -- 05/22/2002 yzhao: add ends

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



-- Start of comments
-- NAME
--    Create_ActMetric2
--
--
-- PURPOSE
--    Creates an association of a metric to a business
--    object by creating a record in OZF_ACT_METRICS_ALL.
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

   l_act_metr_count     NUMBER ;


   CURSOR c_act_metr_count(l_act_metric_id IN NUMBER) IS
      SELECT COUNT(1)
      FROM   ozf_act_metrics_all
      WHERE  activity_metric_id = l_act_metric_id;

   CURSOR c_act_met_id IS
      SELECT ozf_act_metrics_all_s.NEXTVAL
      FROM   dual;


BEGIN
   --
   -- Initialize savepoint.
   --
   --SAVEPOINT Create_ActMetric2_pvt;

   IF (OZF_DEBUG_HIGH_ON) THEN
      ozf_utility_pvt.Debug_Message(l_full_name||': start');
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
   x_activity_metric_id := NULL;
   --
   -- Begin API Body.
   --

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
   IF (OZF_DEBUG_HIGH_ON) THEN

   ozf_utility_pvt.debug_message(l_full_name ||': insert');
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

   --dbms_output.put_line('Stat Before Insert : '||l_return_status);

   --
   -- Insert into the base table.
   --
   INSERT INTO ozf_act_metrics_all (
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
         ex_start_node,
         /* 05/15/2002 yzhao: add ends */
         product_spread_time_id,
         start_period_name,
         end_period_name
   )
   VALUES (
        l_act_metrics_rec.activity_metric_id,
        sysdate,
        Fnd_Global.User_ID,
        sysdate,
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
         NVL(l_act_metrics_rec.dirty_flag,'Y'),
         l_act_metrics_rec.func_committed_value,
         l_act_metrics_rec.func_actual_value,
         l_act_metrics_rec.last_calculated_date,
         l_act_metrics_rec.variable_value,
         l_act_metrics_rec.computed_using_function_value,
         l_act_metrics_rec.metric_uom_code,
         MO_UTILS.get_default_org_id , -- org_id
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
        l_act_metrics_rec.ex_start_node,
        /* 05/15/2002 yzhao: add ends */
        l_act_metrics_rec.product_spread_time_id,
        l_act_metrics_rec.start_period_name,
        l_act_metrics_rec.end_period_name
     );




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
   IF (OZF_DEBUG_HIGH_ON) THEN
      ozf_utility_pvt.debug_message(l_full_name ||': end Success');
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
--   Updates a metric in OZF_ACT_METRICS_ALL given the
--   record for the metrics.
--
-- NOTES
--
-- HISTORY
-- 05/26/1999   choang         Created.
-- 10/9/1999    ptendulk       Modified According to new Standards
-- 17-Apr-2000  tdonohoe       Added new columns to Update statement to
--                             support 11.5.2 release.
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

BEGIN



   IF (OZF_DEBUG_HIGH_ON) THEN

   ozf_utility_pvt.debug_message('Now updating act met id: '||p_act_metric_rec.activity_metric_id);

   END IF;
   --
   -- Initialize savepoint.
   --
   SAVEPOINT Update_ActMetric_pvt;
   --
   -- Output debug message.
   --
   IF (OZF_DEBUG_HIGH_ON) THEN
       ozf_utility_pvt.debug_message(l_full_name||': start');
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

   IF (OZF_DEBUG_HIGH_ON) THEN
      ozf_utility_pvt.debug_message(l_full_name ||': validate');
   END IF;

   -- replace g_miss_char/num/date with current column values
   Complete_ActMetric_Rec(p_act_metric_rec, l_actmet_rec);


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


   IF (OZF_DEBUG_HIGH_ON) THEN
     ozf_utility_pvt.debug_message(l_full_name ||': update Activity Metrics Table');
   END IF;

   -- Update OZF_ACT_METRICS_ALL
   UPDATE ozf_act_metrics_all
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
          /* 05/15/2002 yzhao: 11.5.9 add 6 new columns for top-down bottom-up  budgeting */
          hierarchy_type           = l_actmet_rec.hierarchy_type,
          status_code              = l_actmet_rec.status_code,
          method_code              = l_actmet_rec.method_code,
          action_code              = l_actmet_rec.action_code,
          basis_year               = l_actmet_rec.basis_year,
          ex_start_node            = l_actmet_rec.ex_start_node,
          /* 05/15/2002 yzhao: add ends */

	  /* kvattiku April 23, 04 Update extra paramters in Quota */
	  product_spread_time_id   = l_actmet_rec.product_spread_time_id,
	  start_period_name        = l_actmet_rec.start_period_name,
	  end_period_name          = l_actmet_rec.end_period_name
    WHERE activity_metric_id = l_actmet_rec.activity_metric_id;

   IF  (SQL%NOTFOUND)
   THEN
      --
      -- Add error message to API message list.
      --
      IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.g_msg_lvl_error) THEN
         Fnd_Message.set_name('OZF', 'OZF_API_RECORD_NOT_FOUND');
         Fnd_Msg_Pub.ADD;
      END IF;
      RAISE Fnd_Api.g_exc_error;
   END IF;

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
   IF (OZF_DEBUG_HIGH_ON) THEN
      ozf_utility_pvt.debug_message(l_full_name ||': end');
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
   IF (OZF_DEBUG_HIGH_ON) THEN
      ozf_utility_pvt.debug_message(l_full_name||': start');
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

   IF (OZF_DEBUG_HIGH_ON) THEN
      ozf_utility_pvt.debug_message(l_full_name||': Validate items');
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

   IF (OZF_DEBUG_HIGH_ON) THEN
      ozf_utility_pvt.debug_message(l_full_name||': check record');
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

   IF (OZF_DEBUG_HIGH_ON) THEN
      ozf_utility_pvt.debug_message(l_full_name ||': end');
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
         Fnd_Message.Set_Name('OZF', 'OZF_METR_MISSING_APP_ID');
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
         Fnd_Message.Set_Name('OZF', 'OZF_METR_MISSING_ARC_USED_FOR');
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
         Fnd_Message.Set_Name('OZF', 'OZF_METR_MISSING_ARC_USED_FOR');
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
         Fnd_Message.Set_Name('OZF', 'OZF_METR_MISSING_METRIC_ID');
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
         FND_MESSAGE.Set_Name('OZF', 'OZF_METR_MISSING_UOM');
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
         Fnd_Message.Set_Name('OZF', 'OZF_METR_MISSING_SENSITIVE');
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
      AND NOT EXISTS (SELECT 'x' FROM ozf_act_metrics_all a
          WHERE a.metric_id = b.metric_id
          AND a.arc_act_metric_used_by = l_arc_act_metric_used_by
          AND a.act_metric_used_by_id = l_act_metric_used_by_id
          AND NVL(a.arc_function_used_by,'') = NVL(l_arc_function_used_by,'')
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

      IF ozf_utility_pvt.Check_Uniqueness(
                        p_table_name      => 'ozf_act_metrics_all',
                        p_where_clause    => l_where_clause
                        ) = Fnd_Api.g_false
                THEN
         IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.g_msg_lvl_error)
                        THEN
            Fnd_Message.set_name('OZF', 'OZF_METR_ACT_DUP_ID');
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
            Fnd_Message.set_name('OZF', 'OZF_ACT_MET_DUP_FUNCTION');
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

BEGIN
   -- Initialize return status to success.
   x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

   --

   --
   -- Begin Validate Referential
   --

   -- METRIC_ID
   -- Do not validate FK if NULL
   -- Do not validate if Activity Metric is associated with a Forecast.


   IF l_act_metrics_rec.arc_act_metric_used_by <> Fnd_Api.G_MISS_CHAR AND
      ( l_act_metrics_rec.arc_act_metric_used_by NOT IN ('FCST', 'FUND') )
   THEN --added 05-08-2000 tdonohoe
        --added 06-28-2000 rchahal

      IF l_act_metrics_rec.metric_id <> Fnd_Api.G_MISS_NUM THEN
         l_table_name               := 'AMS_METRICS_VL';
         l_pk_name                  := 'METRIC_ID';
         l_pk_value                 := l_act_metrics_rec.metric_id;
         l_pk_data_type             := ozf_utility_pvt.G_NUMBER;
         l_additional_where_clause  := NULL ;

         IF ozf_utility_pvt.Check_FK_Exists (
               p_table_name                 => l_table_name
              ,p_pk_name                            => l_pk_name
              ,p_pk_value                           => l_pk_value
              ,p_pk_data_type               => l_pk_data_type
              ,p_additional_where_clause      => l_additional_where_clause
             ) = Fnd_Api.G_FALSE
         THEN
              IF Fnd_Msg_Pub.Check_Msg_Level (Fnd_Msg_Pub.G_MSG_LVL_ERROR)
              THEN
                 Fnd_Message.Set_Name('OZF', 'OZF_METR_INVALID_MET');
                 Fnd_Msg_Pub.ADD;
              END IF;

                 x_return_status := Fnd_Api.G_RET_STS_ERROR;
                 RETURN;
          END IF;  -- Check_FK_Exists

      END IF;
   END IF;--added 05-08-2000 tdonohoe

   -- TRANSACTION_CURRENCY_CODE
   -- Do not validate FK if NULL
   IF l_act_metrics_rec.transaction_currency_code <> Fnd_Api.G_MISS_CHAR THEN
      l_table_name               := 'FND_CURRENCIES';
      l_pk_name                  := 'CURRENCY_CODE';
      l_pk_value                 := l_act_metrics_rec.transaction_currency_code;
      l_pk_data_type             := ozf_utility_pvt.G_VARCHAR2;
      l_additional_where_clause  := ' enabled_flag = ''Y''';
      IF ozf_utility_pvt.Check_FK_Exists (
             p_table_name                       => l_table_name
            ,p_pk_name                      => l_pk_name
            ,p_pk_value                     => l_pk_value
            ,p_pk_data_type                 => l_pk_data_type
            ,p_additional_where_clause  => l_additional_where_clause
         ) = Fnd_Api.G_FALSE
      THEN
         IF Fnd_Msg_Pub.Check_Msg_Level (Fnd_Msg_Pub.G_MSG_LVL_ERROR)
         THEN
                 Fnd_Message.Set_Name('OZF', 'OZF_METR_INVALID_TRANS_CUR');
                 Fnd_Msg_Pub.ADD;
                 END IF;

                 x_return_status := Fnd_Api.G_RET_STS_ERROR;
              RETURN;
      END IF;  -- Check_FK_Exists
   END IF;

   -- FUNCTIONAL_CURRENCY_CODE
   -- Do not validate FK if NULL
   IF l_act_metrics_rec.functional_currency_code <> Fnd_Api.G_MISS_CHAR THEN
      l_table_name               := 'FND_CURRENCIES';
      l_pk_name                  := 'CURRENCY_CODE';
      l_pk_value                 := l_act_metrics_rec.functional_currency_code;
      l_pk_data_type             := ozf_utility_pvt.G_VARCHAR2;
      l_additional_where_clause  := ' enabled_flag = ''Y''';

      IF ozf_utility_pvt.Check_FK_Exists (
             p_table_name                       => l_table_name
            ,p_pk_name                      => l_pk_name
            ,p_pk_value                     => l_pk_value
            ,p_pk_data_type                 => l_pk_data_type
            ,p_additional_where_clause  => l_additional_where_clause
         ) = Fnd_Api.G_FALSE
      THEN
         IF Fnd_Msg_Pub.Check_Msg_Level (Fnd_Msg_Pub.G_MSG_LVL_ERROR)
         THEN
            Fnd_Message.Set_Name('OZF', 'OZF_METR_INVALID_FUNC_CUR');
            Fnd_Msg_Pub.ADD;
         END IF;

         x_return_status := Fnd_Api.G_RET_STS_ERROR;
         RETURN;
      END IF;  -- Check_FK_Exists

   END IF;

   --
   -- End Validate Referential
   --

   --
   -- Begin Validate Flags
   --

      -- SENSITIVE_DATA_FLAG
   IF l_act_metrics_rec.sensitive_data_flag <> Fnd_Api.G_MISS_CHAR THEN
      IF ozf_utility_pvt.Is_Y_Or_N (l_act_metrics_rec.sensitive_data_flag)
                                                          = Fnd_Api.G_FALSE
      THEN
         IF Fnd_Msg_Pub.Check_Msg_Level (Fnd_Msg_Pub.G_MSG_LVL_ERROR)
         THEN
            Fnd_Message.Set_Name('OZF', 'OZF_METR_INVALID_SENS_FLAG');
            Fnd_Msg_Pub.ADD;
         END IF;

         x_return_status := Fnd_Api.G_RET_STS_ERROR;
         RETURN;
      END IF; -- Check_FK_Exists
   END IF;

   --
   -- End Validate Flags
   --

   --
   -- Begin Validate LOOKUPS
   --

   --
   -- End Validate LOOKUPS
   --


   -- ARC_METRIC_USED_FOR_OBJECT
   -- DMVINCEN 03/11/2002: Added Dialog Components.
    -- DMVINCEN 03/11/2003: Removed Dialogue Components.
   IF l_act_metrics_rec.arc_act_metric_used_by <> Fnd_Api.G_MISS_CHAR THEN
      IF l_act_metrics_rec.arc_act_metric_used_by NOT IN
         ('CAMP','CSCH','EVEH','EVEO','DELV','FUND','FCST','RCAM','EONE')
         --'DILG','AMS_COMP_START','AMS_COMP_SHOW_WEB_PAGE','AMS_COMP_END')
      THEN
         IF Fnd_Msg_Pub.Check_Msg_Level (Fnd_Msg_Pub.G_MSG_LVL_ERROR) THEN
            Fnd_Message.Set_Name ('OZF', 'OZF_METR_INVALID_USED_BY');
            Fnd_Msg_Pub.ADD;
         END IF;

         x_return_status := Fnd_Api.G_RET_STS_ERROR;
         RETURN;
      END IF;
   END IF;

   -- ARC_ACTIVITY_METRIC_ORIGIN
   -- DMVINCEN 03/11/2002: Added Dialog Components.
    -- DMVINCEN 03/11/2003: Removed Dialogue Components.
   IF l_act_metrics_rec.arc_activity_metric_origin <> Fnd_Api.G_MISS_CHAR THEN
      IF l_act_metrics_rec.arc_activity_metric_origin NOT IN
         ('CAMP','CSCH','EVEH','EVEO','DELV','FUND','FCST','RCAM','EONE')
         --'DILG','AMS_COMP_START','AMS_COMP_SHOW_WEB_PAGE','AMS_COMP_END')
      THEN
         IF Fnd_Msg_Pub.Check_Msg_Level (Fnd_Msg_Pub.G_MSG_LVL_ERROR) THEN
            Fnd_Message.Set_Name ('OZF', 'OZF_METR_INVALID_ORIGIN');
            Fnd_Msg_Pub.ADD;
         END IF;

         x_return_status := Fnd_Api.G_RET_STS_ERROR;
         RETURN;
      END IF;
   END IF;

   --
   -- End Other Business Rule Validations
   --

EXCEPTION
   WHEN OTHERS THEN
      RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
END Check_ActMetric_Items;


-- Start of comments
-- NAME
--    Validate_Alloc_Record
--
-- PURPOSE
--   Validate budget allocation
--      allocation amount can not exceed avail amt
--      start level <= end level
--      start date <= end date
--      start date >= budget start date
--      end date <= budget end date
--      start node falls in the start level
--      can not set 'ex-start-node' if start level = end level
--
-- NOTES
--
-- HISTORY
--   08/03/2001  YZHAO Created
--   05/15/2002  YZHAO Updated for 11.5.9 Top-down Bottom-up Budgeting
--   02/20/2003  YZHAO 11.5.9: can not set 'ex-start-node' if start level = end level
-- End of comments

PROCEDURE Validate_Alloc_Record (
   p_act_metric_rec             IN  act_metric_rec_type,
   x_return_status              OUT NOCOPY VARCHAR2
)
IS
   l_start_node                 NUMBER;
   l_available_budget           NUMBER;
   l_fund_type                  VARCHAR(30);
   l_budget_start_date          DATE;
   l_budget_end_date            DATE;
   l_alloc_start_date           DATE;
   l_alloc_end_date             DATE;
   l_default_start_date         DATE := TO_DATE('01/01/1900', 'DD/MM/YYYY');
   l_default_end_date           DATE := TO_DATE('31/12/2900', 'DD/MM/YYYY');

   -- rimehrot, fixed sql repository violation 14892133
   CURSOR  c_get_budget_info IS
     SELECT (NVL(original_budget, 0) - NVL(holdback_amt, 0) + NVL(transfered_in_amt,0) - NVL(transfered_out_amt, 0))
          , NVL(start_date_active, l_default_start_date)
          , NVL(end_date_active, l_default_end_date)
	  , fund_type
       FROM ozf_funds_all_b
      WHERE fund_id = p_act_metric_rec.act_metric_used_by_id;

   CURSOR  c_check_start_node_terr IS
     SELECT 1
       FROM ozf_terr_v
      WHERE hierarchy_id = p_act_metric_rec.hierarchy_id
        AND level_depth = p_act_metric_rec.from_level
        AND node_id = p_act_metric_rec.start_node;

BEGIN

      x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
      IF NOT (Fnd_Msg_Pub.Check_Msg_Level (Fnd_Msg_Pub.G_MSG_LVL_ERROR)) THEN
         RETURN;
      END IF;

      /* yzhao: 11.5.9 need to add check required items for top-down bottom-up budgeting
          action_code, hierarchy_type, hierarch_id, from_level, start_node, end_level(TERR or GEOGRAPHY only)
          method_code, fact_value, status_code
      */

      OPEN c_get_budget_info;
      FETCH c_get_budget_info INTO l_available_budget, l_budget_start_date, l_budget_end_date, l_fund_type;
      CLOSE c_get_budget_info;

      /* Can not allocate if available budget amount is 0 */
      IF (l_available_budget = 0) THEN
          x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
           IF l_fund_type = 'QUOTA' THEN
                Fnd_Message.set_name('OZF', 'OZF_TP_ALLOCNOAVAIL_ERROR');
           ELSE
                Fnd_Message.set_name('OZF', 'OZF_FUND_ALLOCNOAVAIL_ERROR');
           END IF;
          Fnd_Msg_Pub.ADD;
      END IF;

      /* allocation amount can not exceed available amount */
      IF (p_act_metric_rec.func_actual_value > l_available_budget) THEN
          x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
           IF l_fund_type = 'QUOTA' THEN
                Fnd_Message.set_name('OZF', 'OZF_TP_ALLOCAMOUNT_ERROR');
           ELSE
                Fnd_Message.set_name('OZF', 'OZF_FUND_ALLOCAMOUNT_ERROR');
           END IF;
          Fnd_Message.set_token('ALLOCAMT', p_act_metric_rec.func_actual_value);
          Fnd_Message.set_token('BUDAMT', l_available_budget);
          Fnd_Msg_Pub.ADD;
      END IF;

      /* check start level <= end level  */
      IF (p_act_metric_rec.from_level <> Fnd_Api.g_miss_num AND
          p_act_metric_rec.to_level <> Fnd_Api.g_miss_num) THEN
          IF (NVL(p_act_metric_rec.from_level, 0) > NVL(p_act_metric_rec.to_level, 1000)) THEN
              x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
              Fnd_Message.set_name('OZF', 'OZF_FUND_ALLOCLEVEL_ERROR');
              Fnd_Msg_Pub.ADD;
          END IF;

          /* 11.5.9: can not set 'ex-start-node' if start level = end level */
          IF (p_act_metric_rec.ex_start_node = 'Y' AND
              p_act_metric_rec.from_level = p_act_metric_rec.to_level) THEN
              x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
              Fnd_Message.set_name('OZF', 'OZF_FUND_ALLOCEXSTNODE_ERROR');
              Fnd_Msg_Pub.ADD;
          END IF;
      END IF;

      IF (p_act_metric_rec.from_date <> Fnd_Api.g_miss_date) THEN
          l_alloc_start_date := NVL(p_act_metric_rec.from_date, l_default_start_date);
      END IF;

      IF (p_act_metric_rec.TO_DATE <> Fnd_Api.g_miss_date) THEN
          l_alloc_end_date := NVL(p_act_metric_rec.TO_DATE, l_default_end_date);
      END IF;

      /* check start date >= budget start date   */
      IF (l_alloc_start_date < l_budget_start_date) THEN
          x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
           IF l_fund_type = 'QUOTA' THEN
                Fnd_Message.set_name('OZF', 'OZF_TP_ALLOCSTARTDATE_ERROR');
           ELSE
                Fnd_Message.set_name('OZF', 'OZF_FUND_ALLOCSTARTDATE_ERROR');
           END IF;
          Fnd_Msg_Pub.ADD;
      END IF;

      /* check end date <= budget end date      */
      IF (l_alloc_end_date > l_budget_end_date) THEN
          x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
	   IF l_fund_type = 'QUOTA' THEN
                Fnd_Message.set_name('OZF', 'OZF_TP_ALLOCENDDATE_ERROR');
           ELSE
                Fnd_Message.set_name('OZF', 'OZF_FUND_ALLOCENDDATE_ERROR');
           END IF;
           Fnd_Msg_Pub.ADD;
      END IF;

      /* check start date <= end date   */
      IF (l_alloc_start_date > l_alloc_end_date) THEN
          x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
          Fnd_Message.set_name('OZF', 'OZF_FUND_ALLOCDATE_ERROR');
          Fnd_Msg_Pub.ADD;
      END IF;

      /* check start node falls in the start level  */
      IF (p_act_metric_rec.HIERARCHY_TYPE = 'TERRITORY') THEN
          OPEN c_check_start_node_terr;
          FETCH c_check_start_node_terr INTO l_start_node;
          IF c_check_start_node_terr%NOTFOUND THEN
              x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
              Fnd_Message.set_name('OZF', 'OZF_FUND_ALLOCSTARTNODE_ERROR');
              Fnd_Msg_Pub.ADD;
          END IF;
          CLOSE c_check_start_node_terr;
      /*  for future release
      ELSIF (p_act_metric_rec.HIERARCHY_TYPE = 'GEOGRAPHY') THEN
       */
      END IF;

      /* 11.5.9: method 'PRIOR_YEARS_SALE' can only be used by 'TERRITORY' hierarchy and must have year set */
      IF (p_act_metric_rec.method_code = 'PRIOR_SALES_TOTAL') THEN
          IF (p_act_metric_rec.hierarchy_type <> 'TERRITORY') THEN
              x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
              Fnd_Message.set_name('OZF', 'OZF_FUND_ALLOCPRISALE_ERROR');
              Fnd_Msg_Pub.ADD;
          END IF;
          IF (p_act_metric_rec.basis_year is null) THEN
              x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
              Fnd_Message.set_name('OZF', 'OZF_FUND_ALLOCBASISYEAR_ERROR');
              Fnd_Msg_Pub.ADD;
          END IF;
      END IF;

EXCEPTION
   WHEN OTHERS THEN
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;

END Validate_Alloc_Record;


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

   l_return_status                               VARCHAR2(1);

   l_object_name AMS_LOOKUPS.MEANING%TYPE;

   CURSOR c_ref_metric (p_act_metric_id NUMBER) IS
      SELECT func_actual_value,
             trans_forecasted_value
      FROM   ozf_act_metrics_all
      WHERE  activity_metric_id = p_act_metric_id;
   l_ref_metric_rec     c_ref_metric%ROWTYPE;
BEGIN

   x_return_status := Fnd_Api.g_ret_sts_success;

   OPEN c_ref_metric (l_act_metrics_rec.activity_metric_id);
   FETCH c_ref_metric INTO l_ref_metric_rec;
   CLOSE c_ref_metric;


   -- Validate All Modes --
    IF l_act_metrics_rec.arc_act_metric_used_by <> Fnd_Api.G_MISS_CHAR THEN

       IF l_act_metrics_rec.act_metric_used_by_id = Fnd_Api.G_MISS_NUM THEN
          l_act_metrics_rec.act_metric_used_by_id  :=
                                      p_complete_rec.act_metric_used_by_id;
       END IF;

       IF l_act_metrics_rec.metric_id = Fnd_Api.G_MISS_NUM THEN
          l_act_metrics_rec.metric_id  := p_complete_rec.metric_id;
       END IF;


      -- Get table_name and pk_name for the ARC qualifier.
      ozf_utility_pvt.Get_Qual_Table_Name_And_PK (
         p_sys_qual       => l_act_metrics_rec.arc_act_metric_used_by,
         x_return_status  => l_return_status,
         x_table_name     => l_table_name,
         x_pk_name        => l_pk_name
      );

      l_pk_value                 := l_act_metrics_rec.act_metric_used_by_id;
      l_pk_data_type             := ozf_utility_pvt.G_NUMBER;
      l_additional_where_clause  := NULL;

      IF ozf_utility_pvt.Check_FK_Exists (
             p_table_name                   => l_table_name
            ,p_pk_name                      => l_pk_name
            ,p_pk_value                     => l_pk_value
            ,p_pk_data_type                 => l_pk_data_type
            ,p_additional_where_clause      => l_additional_where_clause
         ) = Fnd_Api.G_FALSE
      THEN
            IF Fnd_Msg_Pub.Check_Msg_Level (Fnd_Msg_Pub.G_MSG_LVL_ERROR) THEN
            l_object_name := ozf_utility_pvt.get_lookup_meaning(
             'AMS_SYS_ARC_QUALIFIER',l_act_metrics_rec.arc_act_metric_used_by);
            Fnd_Message.Set_Name ('OZF', 'OZF_METR_INVALID_OBJECT');
            Fnd_Message.Set_Token('OBJTYPE',l_object_name);
            Fnd_Message.Set_Token('OBJID',l_pk_value);
            Fnd_Msg_Pub.ADD;
            END IF;

            x_return_status := Fnd_Api.G_RET_STS_ERROR;
      END IF;

      -- 08/06/2001 yzhao: validation for budget allocation
      IF l_act_metrics_rec.arc_act_metric_used_by = 'FUND' THEN
         Validate_Alloc_Record (
            p_act_metric_rec => l_act_metrics_rec,
            x_return_status  => l_return_status
         );
         IF l_return_status <> Fnd_Api.G_RET_STS_SUCCESS THEN
            x_return_status := l_return_status;
         END IF;
      END IF;

   END IF;

   -- METRIC_UOM_CODE
   IF l_act_metrics_rec.metric_uom_code <> Fnd_Api.G_MISS_CHAR THEN
      IF l_act_metrics_rec.metric_id = Fnd_Api.G_MISS_NUM THEN
         l_act_metrics_rec.metric_id  := p_complete_rec.metric_id ;
      END IF;

      /* yzhao: is METRIC_UOM_CODE used in our code? should it be removed? */
      l_table_name               := 'MTL_UNITS_OF_MEASURE';
      l_pk_name                  := 'UOM_CODE';
      l_pk_value                 := l_act_metrics_rec.metric_uom_code;
      l_pk_data_type             := ozf_utility_pvt.G_VARCHAR2;
      -- l_additional_where_clause  := ' uom_class = ''' || l_metric_details_rec.uom_type || '''' ;

      IF ozf_utility_pvt.Check_FK_Exists (
             p_table_name                       => l_table_name
            ,p_pk_name                      => l_pk_name
            ,p_pk_value                     => l_pk_value
            ,p_pk_data_type                 => l_pk_data_type
            ,p_additional_where_clause  => l_additional_where_clause
         ) = Fnd_Api.G_FALSE
      THEN
         IF Fnd_Msg_Pub.Check_Msg_Level (Fnd_Msg_Pub.G_MSG_LVL_ERROR)
         THEN
            Fnd_Message.Set_Name('OZF', 'OZF_METR_INVALID_UOM');
            Fnd_Msg_Pub.ADD;
         END IF;

         x_return_status := Fnd_Api.G_RET_STS_ERROR;
      END IF; -- Check_FK_Exists
   END IF;


   IF l_act_metrics_rec.arc_activity_metric_origin <> Fnd_Api.G_MISS_CHAR THEN
      IF l_act_metrics_rec.activity_metric_origin_id = Fnd_Api.G_MISS_NUM THEN
         l_act_metrics_rec.activity_metric_origin_id :=
                                     p_complete_rec.activity_metric_origin_id;
      END IF;

          -- Get table_name and pk_name for the ARC qualifier.
      ozf_utility_pvt.Get_Qual_Table_Name_And_PK (
         p_sys_qual      => l_act_metrics_rec.arc_activity_metric_origin,
         x_return_status => l_return_status,
         x_table_name    => l_table_name,
         x_pk_name       => l_pk_name
      );

      l_pk_value                 := l_act_metrics_rec.activity_metric_origin_id;
      l_pk_data_type             := ozf_utility_pvt.G_NUMBER;
      l_additional_where_clause  := NULL;

      IF ozf_utility_pvt.Check_FK_Exists (
             p_table_name                   => l_table_name
            ,p_pk_name                      => l_pk_name
            ,p_pk_value                     => l_pk_value
            ,p_pk_data_type                 => l_pk_data_type
            ,p_additional_where_clause      => l_additional_where_clause
         ) = Fnd_Api.G_FALSE
      THEN
         IF Fnd_Msg_Pub.Check_Msg_Level (Fnd_Msg_Pub.G_MSG_LVL_ERROR) THEN
         Fnd_Message.Set_Name ('OZF', 'OZF_METR_INVALID_ORIGIN');
         Fnd_Msg_Pub.ADD;
         END IF;

         x_return_status := Fnd_Api.G_RET_STS_ERROR;
      END IF;
   END IF;

   --
   -- Other Business Rule Validations
   --
/*
EXCEPTION
   WHEN OTHERS THEN
      RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
*/
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
     FROM ozf_act_metrics_all
    WHERE activity_metric_id = p_act_metric_rec.activity_metric_id;

   l_act_metric_rec  c_act_metric%ROWTYPE;
BEGIN

   x_complete_rec := p_act_metric_rec;

   OPEN c_act_metric;
   FETCH c_act_metric INTO l_act_metric_rec;
   IF c_act_metric%NOTFOUND THEN
      CLOSE c_act_metric;
      IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.g_msg_lvl_error) THEN
         Fnd_Message.set_name('OZF', 'OZF_API_RECORD_NOT_FOUND');
         Fnd_Msg_Pub.ADD;
      END IF;
      RAISE Fnd_Api.g_exc_error;
   END IF;
   CLOSE c_act_metric;


   IF p_act_metric_rec.act_metric_used_by_id = Fnd_Api.G_MISS_NUM THEN
      x_complete_rec.act_metric_used_by_id := NULL;
   END IF;
   IF p_act_metric_rec.act_metric_used_by_id IS NULL THEN
      x_complete_rec.act_metric_used_by_id := l_act_metric_rec.act_metric_used_by_id;
   END IF;

   IF p_act_metric_rec.arc_act_metric_used_by = Fnd_Api.G_MISS_CHAR THEN
      x_complete_rec.arc_act_metric_used_by := NULL;
   END IF;
   IF p_act_metric_rec.arc_act_metric_used_by IS NULL THEN
      x_complete_rec.arc_act_metric_used_by := l_act_metric_rec.arc_act_metric_used_by;
   END IF;

   IF p_act_metric_rec.purchase_req_raised_flag = Fnd_Api.G_MISS_CHAR THEN
      x_complete_rec.purchase_req_raised_flag := NULL;
   END IF;
   IF p_act_metric_rec.purchase_req_raised_flag IS NULL THEN
      x_complete_rec.purchase_req_raised_flag := l_act_metric_rec.purchase_req_raised_flag;
   END IF;

   IF p_act_metric_rec.application_id = Fnd_Api.G_MISS_NUM THEN
      x_complete_rec.application_id := NULL;
   END IF;
   IF p_act_metric_rec.application_id IS NULL THEN
      x_complete_rec.application_id := l_act_metric_rec.application_id;
   END IF;

   IF p_act_metric_rec.sensitive_data_flag = Fnd_Api.G_MISS_CHAR THEN
      x_complete_rec.sensitive_data_flag := NULL;
   END IF;
   IF p_act_metric_rec.sensitive_data_flag IS NULL THEN
      x_complete_rec.sensitive_data_flag := l_act_metric_rec.sensitive_data_flag;
   END IF;

   IF p_act_metric_rec.budget_id = Fnd_Api.G_MISS_NUM THEN
      x_complete_rec.budget_id := NULL;
   END IF;
   IF p_act_metric_rec.budget_id IS NULL THEN
      x_complete_rec.budget_id := l_act_metric_rec.budget_id;
   END IF;

   IF p_act_metric_rec.metric_id = Fnd_Api.G_MISS_NUM THEN
      x_complete_rec.metric_id := NULL;
   END IF;
   IF p_act_metric_rec.metric_id IS NULL THEN
      x_complete_rec.metric_id := l_act_metric_rec.metric_id;
   END IF;

   IF p_act_metric_rec.transaction_currency_code = Fnd_Api.G_MISS_CHAR THEN
      x_complete_rec.transaction_currency_code := NULL;
   END IF;
   IF p_act_metric_rec.transaction_currency_code IS NULL THEN
      x_complete_rec.transaction_currency_code := l_act_metric_rec.transaction_currency_code;
   END IF;

   IF NVL(p_act_metric_rec.trans_forecasted_value,-1) = Fnd_Api.G_MISS_NUM THEN
      x_complete_rec.trans_forecasted_value := NULL;
   END IF;
   IF NVL(p_act_metric_rec.trans_forecasted_value,-1) IS NULL THEN
      x_complete_rec.trans_forecasted_value := l_act_metric_rec.trans_forecasted_value;
   END IF;

   IF p_act_metric_rec.trans_committed_value = Fnd_Api.G_MISS_NUM THEN
      x_complete_rec.trans_committed_value := NULL;
   END IF;
   IF p_act_metric_rec.trans_committed_value IS NULL THEN
      x_complete_rec.trans_committed_value := l_act_metric_rec.trans_committed_value;
   END IF;

   IF p_act_metric_rec.trans_actual_value = Fnd_Api.G_MISS_NUM THEN
      x_complete_rec.trans_actual_value := NULL;
   END IF;
   IF p_act_metric_rec.trans_actual_value IS NULL THEN
      x_complete_rec.trans_actual_value := l_act_metric_rec.trans_actual_value;
   END IF;

   IF p_act_metric_rec.functional_currency_code = Fnd_Api.G_MISS_CHAR THEN
      x_complete_rec.functional_currency_code := NULL;
   END IF;
   IF p_act_metric_rec.functional_currency_code IS NULL THEN
      x_complete_rec.functional_currency_code := l_act_metric_rec.functional_currency_code;
   END IF;

   IF p_act_metric_rec.func_forecasted_value = Fnd_Api.G_MISS_NUM THEN
      x_complete_rec.func_forecasted_value := NULL;
   END IF;
   IF p_act_metric_rec.func_forecasted_value IS NULL THEN
      x_complete_rec.func_forecasted_value := l_act_metric_rec.func_forecasted_value;
   END IF;

   IF p_act_metric_rec.func_committed_value = Fnd_Api.G_MISS_NUM THEN
      x_complete_rec.func_committed_value := NULL;
   END IF;
   IF p_act_metric_rec.func_committed_value IS NULL THEN
      x_complete_rec.func_committed_value := l_act_metric_rec.func_committed_value;
   END IF;

   IF p_act_metric_rec.func_actual_value = Fnd_Api.G_MISS_NUM THEN
      x_complete_rec.func_actual_value := NULL;
   END IF;
   IF p_act_metric_rec.func_actual_value IS NULL THEN
      x_complete_rec.func_actual_value := l_act_metric_rec.func_actual_value;
   END IF;

   IF p_act_metric_rec.dirty_flag = Fnd_Api.G_MISS_CHAR THEN
    x_complete_rec.dirty_flag := NULL;
   END IF;
   IF p_act_metric_rec.dirty_flag IS NULL THEN
     IF (l_act_metric_rec.trans_actual_value <>
                                        x_complete_rec.trans_actual_value) OR
       (l_act_metric_rec.transaction_currency_code <>
                                        x_complete_rec.transaction_currency_code) OR
       (l_act_metric_rec.trans_forecasted_value <>
                                        x_complete_rec.trans_forecasted_value) OR
       (l_act_metric_rec.variable_value <>
                                        x_complete_rec.variable_value) THEN
                --SVEERAVE, 10/16/00 to default dirty_flag to Y incase of changes in
                -- actual/forecasted values.
          x_complete_rec.dirty_flag := 'Y';
     ELSE
          x_complete_rec.dirty_flag := NVL(l_act_metric_rec.dirty_flag,'Y');
     END IF;
   END IF;

   IF p_act_metric_rec.last_calculated_date = Fnd_Api.G_MISS_DATE THEN
      x_complete_rec.last_calculated_date := NULL;
   END IF;
   IF p_act_metric_rec.last_calculated_date IS NULL THEN
      x_complete_rec.last_calculated_date := l_act_metric_rec.last_calculated_date;
   END IF;

   IF p_act_metric_rec.variable_value = Fnd_Api.G_MISS_NUM THEN
      x_complete_rec.variable_value := NULL;
   END IF;
   IF p_act_metric_rec.variable_value IS NULL THEN
      x_complete_rec.variable_value := l_act_metric_rec.variable_value;
   END IF;

   IF p_act_metric_rec.computed_using_function_value = Fnd_Api.G_MISS_NUM THEN
      x_complete_rec.computed_using_function_value := NULL;
   END IF;
   IF p_act_metric_rec.computed_using_function_value IS NULL THEN
      x_complete_rec.computed_using_function_value := l_act_metric_rec.computed_using_function_value;
   END IF;

   IF p_act_metric_rec.metric_uom_code = Fnd_Api.G_MISS_CHAR THEN
      x_complete_rec.metric_uom_code := NULL;
   END IF;
   IF p_act_metric_rec.metric_uom_code IS NULL THEN
      x_complete_rec.metric_uom_code := l_act_metric_rec.metric_uom_code;
   END IF;

   IF p_act_metric_rec.attribute_category = Fnd_Api.G_MISS_CHAR THEN
      x_complete_rec.attribute_category := NULL;
   END IF;
   IF p_act_metric_rec.attribute_category IS NULL THEN
      x_complete_rec.attribute_category := l_act_metric_rec.attribute_category;
   END IF;

   IF p_act_metric_rec.difference_since_last_calc = Fnd_Api.G_MISS_NUM THEN
      x_complete_rec.difference_since_last_calc := NULL;
   END IF;
   IF p_act_metric_rec.difference_since_last_calc IS NULL THEN
      x_complete_rec.difference_since_last_calc := l_act_metric_rec.difference_since_last_calc;
   END IF;

   IF p_act_metric_rec.activity_metric_origin_id = Fnd_Api.G_MISS_NUM THEN
      x_complete_rec.activity_metric_origin_id := NULL;
   END IF;
   IF p_act_metric_rec.activity_metric_origin_id IS NULL THEN
      x_complete_rec.activity_metric_origin_id := l_act_metric_rec.activity_metric_origin_id;
   END IF;

   IF p_act_metric_rec.arc_activity_metric_origin = Fnd_Api.G_MISS_CHAR THEN
      x_complete_rec.arc_activity_metric_origin := NULL;
   END IF;
   IF p_act_metric_rec.arc_activity_metric_origin IS NULL THEN
      x_complete_rec.arc_activity_metric_origin := l_act_metric_rec.arc_activity_metric_origin;
   END IF;

   IF p_act_metric_rec.days_since_last_refresh = Fnd_Api.G_MISS_NUM THEN
      x_complete_rec.days_since_last_refresh := NULL;
   END IF;
   IF p_act_metric_rec.days_since_last_refresh IS NULL THEN
      x_complete_rec.days_since_last_refresh := l_act_metric_rec.days_since_last_refresh;
   END IF;

   IF p_act_metric_rec.scenario_id = Fnd_Api.G_MISS_NUM THEN
      x_complete_rec.scenario_id := NULL;
   END IF;
   IF p_act_metric_rec.scenario_id IS NULL THEN
      x_complete_rec.scenario_id := l_act_metric_rec.scenario_id;
   END IF;

   /***************************************************************/
   /*added 17-Apr-2000 tdonohoe@us support 11.5.2 columns         */
   /***************************************************************/

   IF p_act_metric_rec.hierarchy_id = Fnd_Api.G_MISS_NUM THEN
      x_complete_rec.hierarchy_id := NULL;
   END IF;
   IF p_act_metric_rec.hierarchy_id IS NULL THEN
      x_complete_rec.hierarchy_id := l_act_metric_rec.hierarchy_id;
   END IF;

   IF p_act_metric_rec.start_node  = Fnd_Api.G_MISS_NUM THEN
      x_complete_rec.start_node   := NULL;
   END IF;
   IF p_act_metric_rec.start_node  IS NULL THEN
      x_complete_rec.start_node   := l_act_metric_rec.start_node;
   END IF;

   IF p_act_metric_rec.from_level  = Fnd_Api.G_MISS_NUM THEN
      x_complete_rec.from_level   := NULL;
   END IF;
   IF p_act_metric_rec.from_level  IS NULL THEN
      x_complete_rec.from_level   := l_act_metric_rec.from_level;
   END IF;

   IF p_act_metric_rec.to_level  = Fnd_Api.G_MISS_NUM THEN
      x_complete_rec.to_level   := NULL;
   END IF;
   IF p_act_metric_rec.to_level  IS NULL THEN
      x_complete_rec.to_level   := l_act_metric_rec.to_level;
   END IF;

   IF p_act_metric_rec.from_date  = Fnd_Api.G_MISS_DATE THEN
      x_complete_rec.from_date   := NULL;
   END IF;
   IF p_act_metric_rec.from_date  IS NULL THEN
      x_complete_rec.from_date   := l_act_metric_rec.from_date;
   END IF;

   IF p_act_metric_rec.TO_DATE  = Fnd_Api.G_MISS_DATE THEN
      x_complete_rec.TO_DATE   := NULL;
   END IF;
   IF p_act_metric_rec.TO_DATE  IS NULL THEN
      x_complete_rec.TO_DATE   := l_act_metric_rec.TO_DATE;
   END IF;

   IF p_act_metric_rec.amount1  = Fnd_Api.G_MISS_NUM THEN
      x_complete_rec.amount1   := NULL;
   END IF;
   IF p_act_metric_rec.amount1  IS NULL THEN
      x_complete_rec.amount1   := l_act_metric_rec.amount1;
   END IF;

   IF p_act_metric_rec.amount2  = Fnd_Api.G_MISS_NUM THEN
      x_complete_rec.amount2   := NULL;
   END IF;
   IF p_act_metric_rec.amount2  IS NULL THEN
      x_complete_rec.amount2   := l_act_metric_rec.amount2;
   END IF;

   IF p_act_metric_rec.amount3  = Fnd_Api.G_MISS_NUM THEN
      x_complete_rec.amount3   := NULL;
   END IF;
   IF p_act_metric_rec.amount3  IS NULL THEN
      x_complete_rec.amount3   := l_act_metric_rec.amount3;
   END IF;

   IF p_act_metric_rec.percent1  = Fnd_Api.G_MISS_NUM THEN
      x_complete_rec.percent1   := NULL;
   END IF;
   IF p_act_metric_rec.percent1  IS NULL THEN
      x_complete_rec.percent1   := l_act_metric_rec.percent1;
   END IF;

   IF p_act_metric_rec.percent2  = Fnd_Api.G_MISS_NUM THEN
      x_complete_rec.percent2   := NULL;
   END IF;
   IF p_act_metric_rec.percent2  IS NULL THEN
      x_complete_rec.percent2   := l_act_metric_rec.percent2;
   END IF;

   IF p_act_metric_rec.percent3  = Fnd_Api.G_MISS_NUM THEN
      x_complete_rec.percent3   := NULL;
   END IF;
   IF p_act_metric_rec.percent3  IS NULL THEN
      x_complete_rec.percent3   := l_act_metric_rec.percent3;
   END IF;

   IF p_act_metric_rec.published_flag  = Fnd_Api.G_MISS_CHAR THEN
      x_complete_rec.published_flag   := NULL;
   END IF;
   IF p_act_metric_rec.published_flag  IS NULL THEN
      x_complete_rec.published_flag   := l_act_metric_rec.published_flag;
   END IF;

   IF p_act_metric_rec.pre_function_name  = Fnd_Api.G_MISS_CHAR THEN
      x_complete_rec.pre_function_name   := NULL;
   END IF;
   IF p_act_metric_rec.pre_function_name  IS NULL THEN
      x_complete_rec.pre_function_name   := l_act_metric_rec.pre_function_name;
   END IF;

   IF p_act_metric_rec.post_function_name  = Fnd_Api.G_MISS_CHAR THEN
      x_complete_rec.post_function_name   := NULL;
   END IF;
   IF p_act_metric_rec.post_function_name  IS NULL THEN
      x_complete_rec.post_function_name   := l_act_metric_rec.post_function_name;
   END IF;

   IF p_act_metric_rec.attribute1 = Fnd_Api.G_MISS_CHAR THEN
      x_complete_rec.attribute1 := NULL;
   END IF;
   IF p_act_metric_rec.attribute1 IS NULL THEN
      x_complete_rec.attribute1 := l_act_metric_rec.attribute1;
   END IF;

   IF p_act_metric_rec.attribute2 = Fnd_Api.G_MISS_CHAR THEN
      x_complete_rec.attribute2 := NULL;
   END IF;
   IF p_act_metric_rec.attribute2 IS NULL THEN
      x_complete_rec.attribute2 := l_act_metric_rec.attribute2;
   END IF;

   IF p_act_metric_rec.attribute3 = Fnd_Api.G_MISS_CHAR THEN
      x_complete_rec.attribute3 := NULL;
   END IF;
   IF p_act_metric_rec.attribute3 IS NULL THEN
      x_complete_rec.attribute3 := l_act_metric_rec.attribute3;
   END IF;

   IF p_act_metric_rec.attribute4 = Fnd_Api.G_MISS_CHAR THEN
      x_complete_rec.attribute4 := NULL;
   END IF;
   IF p_act_metric_rec.attribute4 IS NULL THEN
      x_complete_rec.attribute4 := l_act_metric_rec.attribute4;
   END IF;

   IF p_act_metric_rec.attribute5 = Fnd_Api.G_MISS_CHAR THEN
      x_complete_rec.attribute5 := NULL;
   END IF;
   IF p_act_metric_rec.attribute5 IS NULL THEN
      x_complete_rec.attribute5 := l_act_metric_rec.attribute5;
   END IF;

   IF p_act_metric_rec.attribute6 = Fnd_Api.G_MISS_CHAR THEN
      x_complete_rec.attribute6 := NULL;
   END IF;
   IF p_act_metric_rec.attribute6 IS NULL THEN
      x_complete_rec.attribute6 := l_act_metric_rec.attribute6;
   END IF;

   IF p_act_metric_rec.attribute7 = Fnd_Api.G_MISS_CHAR THEN
      x_complete_rec.attribute7 := NULL;
   END IF;
   IF p_act_metric_rec.attribute7 IS NULL THEN
      x_complete_rec.attribute7 := l_act_metric_rec.attribute7;
   END IF;

   IF p_act_metric_rec.attribute8 = Fnd_Api.G_MISS_CHAR THEN
      x_complete_rec.attribute8 := NULL;
   END IF;
   IF p_act_metric_rec.attribute8 IS NULL THEN
      x_complete_rec.attribute8 := l_act_metric_rec.attribute8;
   END IF;

   IF p_act_metric_rec.attribute9 = Fnd_Api.G_MISS_CHAR THEN
      x_complete_rec.attribute9 := NULL;
   END IF;
   IF p_act_metric_rec.attribute9 IS NULL THEN
      x_complete_rec.attribute9 := l_act_metric_rec.attribute9;
   END IF;

   IF p_act_metric_rec.attribute10 = Fnd_Api.G_MISS_CHAR THEN
      x_complete_rec.attribute10 := NULL;
   END IF;
   IF p_act_metric_rec.attribute10 IS NULL THEN
      x_complete_rec.attribute10 := l_act_metric_rec.attribute10;
   END IF;

   IF p_act_metric_rec.attribute11 = Fnd_Api.G_MISS_CHAR THEN
      x_complete_rec.attribute11 := NULL;
   END IF;
   IF p_act_metric_rec.attribute11 IS NULL THEN
      x_complete_rec.attribute11 := l_act_metric_rec.attribute11;
   END IF;

   IF p_act_metric_rec.attribute12 = Fnd_Api.G_MISS_CHAR THEN
      x_complete_rec.attribute12 := NULL;
   END IF;
   IF p_act_metric_rec.attribute12 IS NULL THEN
      x_complete_rec.attribute12 := l_act_metric_rec.attribute12;
   END IF;

   IF p_act_metric_rec.attribute13 = Fnd_Api.G_MISS_CHAR THEN
      x_complete_rec.attribute13 := NULL;
   END IF;
   IF p_act_metric_rec.attribute13 IS NULL THEN
      x_complete_rec.attribute13 := l_act_metric_rec.attribute13;
   END IF;

   IF p_act_metric_rec.attribute14 = Fnd_Api.G_MISS_CHAR THEN
      x_complete_rec.attribute14 := NULL;
   END IF;
   IF p_act_metric_rec.attribute14 IS NULL THEN
      x_complete_rec.attribute14 := l_act_metric_rec.attribute14;
   END IF;

   IF p_act_metric_rec.attribute15 = Fnd_Api.G_MISS_CHAR THEN
      x_complete_rec.attribute15 := NULL;
   END IF;
   IF p_act_metric_rec.attribute15 IS NULL THEN
      x_complete_rec.attribute15 := l_act_metric_rec.attribute15;
   END IF;

-- DMVINCEN 05/01/2001: New columns.
   IF p_act_metric_rec.act_metric_date = Fnd_Api.G_MISS_DATE THEN
      x_complete_rec.act_metric_date := NULL;
   END IF;
   IF p_act_metric_rec.act_metric_date IS NULL THEN
      x_complete_rec.act_metric_date := l_act_metric_rec.act_metric_date;
   END IF;

   IF p_act_metric_rec.description = Fnd_Api.G_MISS_CHAR THEN
      x_complete_rec.description := NULL;
   END IF;
   IF p_act_metric_rec.description IS NULL THEN
      x_complete_rec.description := l_act_metric_rec.description;
   END IF;

-- DMVINCEN 05/01/2001: End new columns.

   IF p_act_metric_rec.depend_act_metric = Fnd_Api.G_MISS_NUM THEN
      x_complete_rec.depend_act_metric := NULL;
   END IF;
   IF p_act_metric_rec.depend_act_metric IS NULL THEN
      x_complete_rec.depend_act_metric := l_act_metric_rec.depend_act_metric;
   END IF;

-- DMVINCEN 03/08/2002:

   IF p_act_metric_rec.function_used_by_id = Fnd_Api.G_MISS_NUM THEN
      x_complete_rec.function_used_by_id := NULL;
   END IF;
   IF p_act_metric_rec.function_used_by_id IS NULL THEN
      x_complete_rec.function_used_by_id := l_act_metric_rec.function_used_by_id;
   END IF;

   IF p_act_metric_rec.arc_function_used_by = Fnd_Api.G_MISS_CHAR THEN
      x_complete_rec.arc_function_used_by := NULL;
   END IF;
   IF p_act_metric_rec.arc_function_used_by IS NULL THEN
      x_complete_rec.arc_function_used_by := l_act_metric_rec.arc_function_used_by;
   END IF;

   /* 05/15/2002 yzhao: add 6 new columns for top-down bottom-up budgeting */
   IF p_act_metric_rec.hierarchy_type = Fnd_Api.G_MISS_CHAR THEN
      x_complete_rec.hierarchy_type := NULL;
   END IF;
   IF p_act_metric_rec.hierarchy_type IS NULL THEN
      x_complete_rec.hierarchy_type := l_act_metric_rec.hierarchy_type;
   END IF;

   IF p_act_metric_rec.status_code = Fnd_Api.G_MISS_CHAR THEN
      x_complete_rec.status_code := NULL;
   END IF;
   IF p_act_metric_rec.status_code IS NULL THEN
      x_complete_rec.status_code := l_act_metric_rec.status_code;
   END IF;

   IF p_act_metric_rec.method_code = Fnd_Api.G_MISS_CHAR THEN
      x_complete_rec.method_code := NULL;
   END IF;
   IF p_act_metric_rec.method_code IS NULL THEN
      x_complete_rec.method_code := l_act_metric_rec.method_code;
   END IF;

   IF p_act_metric_rec.action_code = Fnd_Api.G_MISS_CHAR THEN
      x_complete_rec.action_code := NULL;
   END IF;
   IF p_act_metric_rec.action_code IS NULL THEN
      x_complete_rec.action_code := l_act_metric_rec.action_code;
   END IF;

   IF p_act_metric_rec.basis_year = Fnd_Api.G_MISS_NUM THEN
      x_complete_rec.basis_year := NULL;
   END IF;
   IF p_act_metric_rec.basis_year IS NULL THEN
      x_complete_rec.basis_year := l_act_metric_rec.basis_year;
   END IF;

   IF p_act_metric_rec.ex_start_node = Fnd_Api.G_MISS_CHAR THEN
      x_complete_rec.ex_start_node := NULL;
   END IF;
   IF p_act_metric_rec.ex_start_node IS NULL THEN
      x_complete_rec.ex_start_node := l_act_metric_rec.ex_start_node;
   END IF;
   /* 05/15/2002 yzhao: add ends */

   IF p_act_metric_rec.product_spread_time_id = Fnd_Api.G_MISS_NUM THEN
      x_complete_rec.product_spread_time_id := NULL;
   END IF;
   IF p_act_metric_rec.product_spread_time_id IS NULL THEN
      x_complete_rec.product_spread_time_id := l_act_metric_rec.product_spread_time_id;
   END IF;

   IF p_act_metric_rec.start_period_name = Fnd_Api.G_MISS_CHAR THEN
      x_complete_rec.start_period_name := NULL;
   END IF;
   IF p_act_metric_rec.start_period_name IS NULL THEN
      x_complete_rec.start_period_name := l_act_metric_rec.start_period_name;
   END IF;

   IF p_act_metric_rec.end_period_name = Fnd_Api.G_MISS_CHAR THEN
      x_complete_rec.end_period_name := NULL;
   END IF;
   IF p_act_metric_rec.end_period_name IS NULL THEN
      x_complete_rec.end_period_name := l_act_metric_rec.end_period_name;
   END IF;

END Complete_ActMetric_Rec ;


END Ozf_Actmetric_Pvt;

/
