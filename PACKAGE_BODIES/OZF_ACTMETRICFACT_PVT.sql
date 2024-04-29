--------------------------------------------------------
--  DDL for Package Body OZF_ACTMETRICFACT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_ACTMETRICFACT_PVT" AS
/* $Header: ozfvamfb.pls 120.1.12010000.2 2008/08/13 06:20:58 kdass ship $ */

---------------------------------------------------------------------------------------------------
--
-- NAME
--    Ozf_Actmetricfact_Pvt
--
-- HISTORY
-- 20-Jun-1999 tdonohoe Created  package.
-- 28-Jun 2000 tdonohoe Modified Check_ActMetricFact_Items to allow the same node to appear on a
--                      hierarchy combined with a unique formula_id.
-- 31-Jul-2000 tdonohoe comment out code to fix bug 1362107.
-- 03-Apr-2001 yzhao    add validate_fund_facts
-- 08-Aug-2005 mkothari added 4 new columns for forecasting based on 3rd party baseline sales
--------------------------------------------------------------------------------------------------

--
-- Global variables and constants.

G_PKG_NAME           CONSTANT VARCHAR2(30) := 'Ozf_Actmetricfact_Pvt'; -- Name of the current package.
G_DEBUG_FLAG          VARCHAR2(1)  := 'N';
G_DEBUG BOOLEAN := FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_high);


-- Start of comments
-- NAME
--    Default_ActMetricFact
--
--
-- PURPOSE
--    Defaults the Activty Metric Fact .
--
-- NOTES
--
-- HISTORY
-- 24-Apr-2000    tdonohoe  Created.
--
-- End of comments

OZF_DEBUG_HIGH_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
OZF_DEBUG_LOW_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
OZF_DEBUG_MEDIUM_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

PROCEDURE Default_ActMetricFact(
   p_init_msg_list          IN  VARCHAR2 := FND_API.G_FALSE,
   p_act_metric_fact_rec    IN  act_metric_fact_rec_type,
   p_validation_mode        IN  VARCHAR2 ,
   x_complete_rec           OUT NOCOPY act_metric_fact_rec_type,
   x_return_status         OUT NOCOPY VARCHAR2,
   x_msg_count              OUT NOCOPY NUMBER,
   x_msg_data               OUT NOCOPY VARCHAR2
)
IS

BEGIN
   --
   -- Initialize message list if p_init_msg_list is set to TRUE.
   --
   IF FND_API.To_Boolean (p_init_msg_list) THEN
      FND_MSG_PUB.Initialize;
   END IF;

   --
   -- Initialize API return status to success.
   --
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   x_complete_rec := p_act_metric_fact_rec;

     -- Insert Mode
     IF ((p_validation_mode = JTF_PLSQL_API.g_create) OR (p_validation_mode = JTF_PLSQL_API.g_update)) THEN

         IF  p_act_metric_fact_rec.trans_forecasted_value IS NULL  THEN
             x_complete_rec.trans_forecasted_value := 0;
         END IF;

         IF  p_act_metric_fact_rec.base_quantity IS NULL  THEN
             x_complete_rec.base_quantity := 0;
         END IF;

         IF  p_act_metric_fact_rec.functional_currency_code IS NULL  THEN
             x_complete_rec.functional_currency_code := 'NONE';
         END IF;

         IF  p_act_metric_fact_rec.func_forecasted_value IS NULL  THEN
             x_complete_rec.func_forecasted_value := 0;
         END IF;

         IF  p_act_metric_fact_rec.de_metric_id IS NULL  THEN
             x_complete_rec.de_metric_id := 0;
         END IF;

         IF  p_act_metric_fact_rec.time_id1 IS NULL  THEN
             x_complete_rec.time_id1 := 0;
         END IF;

         IF  p_act_metric_fact_rec.value_type IS NULL  THEN
             x_complete_rec.value_type := 'NUMERIC';
         END IF;

     END IF;

END Default_ActMetricFact ;


-- Start of comments
-- API Name       Init_ActMetricFact_Rec
-- Type           Private
-- Function       This Process initialize Activity Metric Fact record
-- Parameters
--    OUT NOCOPY         x_fact_rec           OUT NOCOPY act_metric_rec_fact_type
-- History
--    05/30/2002  created by Ying Zhao
-- End of comments

PROCEDURE Init_ActMetricFact_Rec(
   x_fact_rec        OUT NOCOPY act_metric_fact_rec_type
)
IS
BEGIN
	RETURN;
END Init_ActMetricFact_Rec;


-- Start of comments
-- NAME
--    Create_ActMetricFact
--
--
-- PURPOSE
--    Creates a result entry for the Activity Metric.

--
-- NOTES
--
-- HISTORY
-- 18-Apr-2000  tdonohoe@us    Created.
--
-- End of comments

PROCEDURE Create_ActMetricFact (
   p_api_version                IN  NUMBER,
   p_init_msg_list              IN  VARCHAR2 := FND_API.G_FALSE,
   p_commit                     IN  VARCHAR2 := FND_API.G_FALSE,
   p_validation_level           IN  NUMBER   := FND_API.G_Valid_Level_Full,

   x_return_status              OUT NOCOPY VARCHAR2,
   x_msg_count                  OUT NOCOPY NUMBER,
   x_msg_data                   OUT NOCOPY VARCHAR2,

   p_act_metric_fact_rec        IN  act_metric_fact_rec_type,
   x_activity_metric_fact_id    OUT NOCOPY NUMBER
)
IS
   --
   -- Standard API information constants.
   --
   L_API_VERSION                  CONSTANT NUMBER := 1.0;
   L_API_NAME                     CONSTANT VARCHAR2(30) := 'CREATE_ACTMETRICFACT';
   L_FULL_NAME                 CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| L_API_NAME;


   l_return_status                VARCHAR2(1); -- Return value from procedures.
   l_act_metric_fact_rec          act_metric_fact_rec_type := p_act_metric_fact_rec;
   l_act_metric_fact_count        NUMBER ;

   l_sql_err_msg varchar2(4000);

   CURSOR c_act_metric_fact_count(l_act_metric_fact_id IN NUMBER) IS
      SELECT count(1)
      FROM   ozf_act_metric_facts_all
      WHERE  activity_metric_fact_id = l_act_metric_fact_id;

   CURSOR c_act_metric_fact_id IS
      SELECT ozf_act_metric_facts_all_s.NEXTVAL
      FROM   dual;

BEGIN
   --
   -- Initialize savepoint.
   --

   SAVEPOINT Create_ActMetricFact_Pvt;

   IF (OZF_DEBUG_HIGH_ON) THEN



   OZF_Utility_PVT.Debug_Message(l_full_name||': start');

   END IF;

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



   Default_ActMetricFact
       ( p_init_msg_list        => p_init_msg_list,
        p_act_metric_fact_rec  => p_act_metric_fact_rec,
        p_validation_mode      => JTF_PLSQL_API.g_create,
        x_complete_rec         => l_act_metric_fact_rec,
        x_return_status        => l_return_status,
        x_msg_count            => x_msg_count,
        x_msg_data             => x_msg_data  ) ;

   -- If any errors happen abort API.
   IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
   ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;




   --
   -- Validate the record before inserting.
   --


   IF l_act_metric_fact_rec.activity_metric_fact_id IS NULL THEN
         LOOP
         --
         -- Set the value for the PK.
              OPEN c_act_metric_fact_id;
            FETCH c_act_metric_fact_id INTO l_act_metric_fact_rec.activity_metric_fact_id;
            CLOSE c_act_metric_fact_id;

         OPEN  c_act_metric_fact_count(l_act_metric_fact_rec.activity_metric_fact_id);
         FETCH c_act_metric_fact_count INTO l_act_metric_fact_count ;
         CLOSE c_act_metric_fact_count ;

         EXIT WHEN l_act_metric_fact_count = 0 ;
      END LOOP ;
   END IF;




   Validate_ActMetFact (
      p_api_version               => l_api_version,
      p_init_msg_list             => p_init_msg_list,
      p_validation_level          => p_validation_level,
      x_msg_count                 => x_msg_count,
      x_msg_data                  => x_msg_data,
      x_return_status             => l_return_status,
      p_act_metric_fact_rec       => l_act_metric_fact_rec
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
   IF (OZF_DEBUG_HIGH_ON) THEN

   OZF_Utility_PVT.debug_message(l_full_name ||': insert');
   END IF;



   --
   -- Insert into the base table.
   --


   Insert into ozf_act_metric_facts_all (
               activity_metric_fact_id,
               last_update_date,
               last_updated_by,
               creation_date,
               created_by,
               last_update_login,
               object_version_number,
               act_metric_used_by_id,
               arc_act_metric_used_by,
               value_type           ,
               activity_metric_id   ,
               activity_geo_area_id ,
               activity_product_id  ,
               transaction_currency_code,
               trans_forecasted_value   ,
               base_quantity            ,
               functional_currency_code ,
               func_forecasted_value    ,
               org_id                   ,
               de_metric_id             ,
               de_geographic_area_id    ,
               de_geographic_area_type  ,
               de_inventory_item_id     ,
               de_inventory_item_org_id ,
               time_id1                 ,
               time_id2                 ,
               time_id3                 ,
               time_id4                 ,
               time_id5                 ,
               time_id6                 ,
               time_id7                 ,
               time_id8                 ,
               time_id9                 ,
               time_id10                ,
               time_id11                ,
               time_id12                ,
               time_id13                ,
               time_id14                ,
               time_id15                ,
               time_id16                ,
               time_id17                ,
               time_id18                ,
               time_id19                ,
               time_id20                ,
               time_id21                ,
               time_id22                ,
               time_id23                ,
               time_id24                ,
               time_id25                ,
               time_id26                ,
               time_id27                ,
               time_id28                ,
               time_id29                ,
               time_id30                ,
               time_id31                ,
               time_id32                ,
               time_id33                ,
               time_id34                ,
               time_id35                ,
               time_id36                ,
               time_id37                ,
               time_id38                ,
               time_id39                ,
               time_id40                ,
               time_id41                ,
               time_id42                ,
               time_id43                ,
               time_id44                ,
               time_id45                ,
               time_id46                ,
               time_id47                ,
               time_id48                ,
               time_id49                ,
               time_id50                ,
               time_id51                ,
               time_id52                ,
               time_id53                ,
               hierarchy_id             ,
               node_id                  ,
               level_depth              ,
               formula_id               ,
               from_date                ,
               to_date                  ,
               fact_value               ,
               fact_percent             ,
               root_fact_id             ,
               previous_fact_id         ,
               fact_type                ,
               fact_reference           ,
               forward_buy_quantity     ,
               /* 05/21/2002 yzhao: add 11 new columns for top-down bottom-up budgeting */
               status_code              ,
               hierarchy_type           ,
               approval_date            ,
               recommend_total_amount   ,
               recommend_hb_amount      ,
               request_total_amount     ,
               request_hb_amount        ,
               actual_total_amount      ,
               actual_hb_amount         ,
               base_total_pct           ,
               base_hb_pct              ,
               /* 05/21/2002 yzhao: add ends */
               /* 08/12/2005 mkothari: added 4 new columns for forecasting with 3rd party baseline sales */
               baseline_sales           ,
               tpr_percent              ,
               lift_factor              ,
               incremental_sales
               /* 08/12/2005 mkothari: add ends */
   )
   VALUES (    l_act_metric_fact_rec.activity_metric_fact_id,
               SYSDATE,
               FND_GLOBAL.User_ID,
               SYSDATE,
               FND_GLOBAL.User_ID,
               FND_GLOBAL.Conc_Login_ID,
               1, --OBJECT_VERSION_NUMBER
               l_act_metric_fact_rec.act_metric_used_by_id,
               l_act_metric_fact_rec.arc_act_metric_used_by,
               l_act_metric_fact_rec.value_type           ,
               l_act_metric_fact_rec.activity_metric_id   ,
               l_act_metric_fact_rec.activity_geo_area_id ,
               l_act_metric_fact_rec.activity_product_id  ,
               l_act_metric_fact_rec.transaction_currency_code,
               l_act_metric_fact_rec.trans_forecasted_value   ,
               l_act_metric_fact_rec.base_quantity            ,
               l_act_metric_fact_rec.functional_currency_code ,
               l_act_metric_fact_rec.func_forecasted_value    ,
               MO_UTILS.get_default_org_id , -- org_id
               l_act_metric_fact_rec.de_metric_id             ,
               l_act_metric_fact_rec.de_geographic_area_id    ,
               l_act_metric_fact_rec.de_geographic_area_type  ,
               l_act_metric_fact_rec.de_inventory_item_id     ,
               l_act_metric_fact_rec.de_inventory_item_org_id ,
               l_act_metric_fact_rec.time_id1                 ,
               l_act_metric_fact_rec.time_id2                 ,
               l_act_metric_fact_rec.time_id3                 ,
               l_act_metric_fact_rec.time_id4                 ,
               l_act_metric_fact_rec.time_id5                 ,
               l_act_metric_fact_rec.time_id6                 ,
               l_act_metric_fact_rec.time_id7                 ,
               l_act_metric_fact_rec.time_id8                 ,
               l_act_metric_fact_rec.time_id9                 ,
               l_act_metric_fact_rec.time_id10                ,
               l_act_metric_fact_rec.time_id11                ,
               l_act_metric_fact_rec.time_id12                ,
               l_act_metric_fact_rec.time_id13                ,
               l_act_metric_fact_rec.time_id14                ,
               l_act_metric_fact_rec.time_id15                ,
               l_act_metric_fact_rec.time_id16                ,
               l_act_metric_fact_rec.time_id17                ,
               l_act_metric_fact_rec.time_id18                ,
               l_act_metric_fact_rec.time_id19                ,
               l_act_metric_fact_rec.time_id20                ,
               l_act_metric_fact_rec.time_id21                ,
               l_act_metric_fact_rec.time_id22                ,
               l_act_metric_fact_rec.time_id23                ,
               l_act_metric_fact_rec.time_id24                ,
               l_act_metric_fact_rec.time_id25                ,
               l_act_metric_fact_rec.time_id26                ,
               l_act_metric_fact_rec.time_id27                ,
               l_act_metric_fact_rec.time_id28                ,
               l_act_metric_fact_rec.time_id29                ,
               l_act_metric_fact_rec.time_id30                ,
               l_act_metric_fact_rec.time_id31                ,
               l_act_metric_fact_rec.time_id32                ,
               l_act_metric_fact_rec.time_id33                ,
               l_act_metric_fact_rec.time_id34                ,
               l_act_metric_fact_rec.time_id35                ,
               l_act_metric_fact_rec.time_id36                ,
               l_act_metric_fact_rec.time_id37                ,
               l_act_metric_fact_rec.time_id38                ,
               l_act_metric_fact_rec.time_id39                ,
               l_act_metric_fact_rec.time_id40                ,
               l_act_metric_fact_rec.time_id41                ,
               l_act_metric_fact_rec.time_id42                ,
               l_act_metric_fact_rec.time_id43                ,
               l_act_metric_fact_rec.time_id44                ,
               l_act_metric_fact_rec.time_id45                ,
               l_act_metric_fact_rec.time_id46                ,
               l_act_metric_fact_rec.time_id47                ,
               l_act_metric_fact_rec.time_id48                ,
               l_act_metric_fact_rec.time_id49                ,
               l_act_metric_fact_rec.time_id50                ,
               l_act_metric_fact_rec.time_id51                ,
               l_act_metric_fact_rec.time_id52                ,
               l_act_metric_fact_rec.time_id53                ,
               l_act_metric_fact_rec.hierarchy_id             ,
               l_act_metric_fact_rec.node_id                  ,
               l_act_metric_fact_rec.level_depth              ,
               l_act_metric_fact_rec.formula_id               ,
               l_act_metric_fact_rec.from_date                ,
               l_act_metric_fact_rec.to_date                  ,
               l_act_metric_fact_rec.fact_value               ,
               l_act_metric_fact_rec.fact_percent             ,
               l_act_metric_fact_rec.root_fact_id             ,
               l_act_metric_fact_rec.previous_fact_id         ,
               l_act_metric_fact_rec.fact_type                ,
               l_act_metric_fact_rec.fact_reference           ,
               l_act_metric_fact_rec.forward_buy_quantity     ,
               /* 05/21/2002 yzhao: add 11 new columns for top-down bottom-up budgeting */
               l_act_metric_fact_rec.status_code              ,
               l_act_metric_fact_rec.hierarchy_type           ,
               l_act_metric_fact_rec.approval_date            ,
               l_act_metric_fact_rec.recommend_total_amount   ,
               l_act_metric_fact_rec.recommend_hb_amount      ,
               l_act_metric_fact_rec.request_total_amount     ,
               l_act_metric_fact_rec.request_hb_amount        ,
               l_act_metric_fact_rec.actual_total_amount      ,
               l_act_metric_fact_rec.actual_hb_amount         ,
               l_act_metric_fact_rec.base_total_pct           ,
               l_act_metric_fact_rec.base_hb_pct              ,
               /* 05/21/2002 yzhao: add ends */
               /* 08/12/2005 mkothari: added 4 new columns for forecasting with 3rd party baseline sales */
               l_act_metric_fact_rec.baseline_sales           ,
               l_act_metric_fact_rec.tpr_percent              ,
               l_act_metric_fact_rec.lift_factor              ,
               l_act_metric_fact_rec.incremental_sales
               /* 08/12/2005 mkothari: add ends */
           );

   -- If any errors happen abort API.
   IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
   ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;




   -- finish

   --
   -- Set OUT NOCOPY value.
   --
   x_activity_metric_fact_id := l_act_metric_fact_rec.activity_metric_fact_id;

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
   -- set the message data OUT NOCOPY variable.
   --
   FND_MSG_PUB.Count_And_Get (
      p_count           =>    x_msg_count,
      p_data            =>    x_msg_data,
      p_encoded         =>    FND_API.G_FALSE
   );

      --
   -- Add success message to message list.
   --
   IF (OZF_DEBUG_HIGH_ON) THEN

   OZF_Utility_PVT.debug_message(l_full_name ||': end Success');
   END IF;




EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN


      ROLLBACK TO Create_ActMetricFact_Pvt;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data
      );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN



      ROLLBACK TO Create_ActMetricFact_Pvt;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data
      );
   WHEN OTHERS THEN


      ROLLBACK TO Create_ActMetricFact_Pvt;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, L_API_NAME);
      END IF;
      FND_MSG_PUB.Count_And_Get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data
      );
END Create_ActMetricFact;


-- Start of comments
-- NAME
--    Update_ActMetricFact
--
-- PURPOSE
--   Updates an entry in the  ozf_act_metric_facts_all table for
--   a given activity_metric record.
--
-- NOTES
--
-- HISTORY
-- 18-Apr-2000  tdonohoe  Created.
--
-- End of comments

PROCEDURE Update_ActMetricFact (
   p_api_version                IN  NUMBER,
   p_init_msg_list              IN  VARCHAR2 := FND_API.G_FALSE,
   p_commit                     IN  VARCHAR2 := FND_API.G_FALSE,
   p_validation_level           IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,

   x_return_status              OUT NOCOPY VARCHAR2,
   x_msg_count                  OUT NOCOPY NUMBER,
   x_msg_data                   OUT NOCOPY VARCHAR2,

   p_act_metric_fact_rec        IN     act_metric_fact_rec_type
)
IS
   L_API_VERSION                CONSTANT NUMBER := 1.0;
   L_API_NAME                   CONSTANT VARCHAR2(30) := 'UPDATE_ACTMETRICFACT';
   L_FULL_NAME           CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;


   l_return_status              VARCHAR2(1);
   l_act_metric_fact_rec        act_metric_fact_rec_type := p_act_metric_fact_rec;
   l_temp_act_metric_fact_rec act_metric_fact_rec_type ;
BEGIN

   --
   -- Initialize savepoint.
   --
   SAVEPOINT Update_ActMetricFact_Pvt;

   --
   -- Output debug message.
   --
   IF (OZF_DEBUG_HIGH_ON) THEN

   OZF_Utility_PVT.debug_message(l_full_name||': start');
   END IF;

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
   -- Debug Message


   Default_ActMetricFact
       ( p_init_msg_list        => p_init_msg_list,
        p_act_metric_fact_rec  => p_act_metric_fact_rec,
        p_validation_mode      => JTF_PLSQL_API.G_UPDATE,
        x_complete_rec         => l_act_metric_fact_rec,
        x_return_status        => l_return_status,
        x_msg_count            => x_msg_count,
        x_msg_data             => x_msg_data  ) ;
-- dbms_output.put_line(l_full_name || ' default_actmetricfact returns ' || l_return_status);
   -- If any errors happen abort API.
   IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
   ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;


   IF (OZF_DEBUG_HIGH_ON) THEN





   OZF_Utility_PVT.debug_message(l_full_name ||': validate');


   END IF;

   -- yzhao: 06/11/2002 complete record before validation so missed values can be filled in
   -- replace g_miss_char/num/date with current column values

   -- mgudivak: November Fifteenth.
   -- Added NOCOPY for the out variable. Hence in and out cannot have the same name.

   l_temp_act_metric_fact_rec := l_act_metric_fact_rec;

   Complete_ActMetFact_Rec(p_act_metric_fact_rec => l_temp_act_metric_fact_rec,
                           x_complete_fact_rec => l_act_metric_fact_rec);


   IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
      Validate_ActMetFact_Items(
         p_act_metric_fact_rec  => l_act_metric_fact_rec,
         p_validation_mode      => JTF_PLSQL_API.g_update,
         x_return_status        => l_return_status
      );
-- dbms_output.put_line(l_full_name || ' validate_items returns ' || l_return_status);
      IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      ELSIF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      END IF;
   END IF;


   IF p_validation_level >= JTF_PLSQL_API.g_valid_level_record THEN
      Validate_ActMetFact_Rec(
         p_act_metric_fact_rec     => p_act_metric_fact_rec,
         p_complete_fact_rec         => l_act_metric_fact_rec,
         x_return_status         => l_return_status
      );
      IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      ELSIF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      END IF;

   END IF;


   IF (OZF_DEBUG_HIGH_ON) THEN





   OZF_Utility_PVT.debug_message(l_full_name ||': Update Activity Metric Facts Table');


   END IF;



   Update ozf_act_metric_facts_all Set
               object_version_number     =   object_version_number + 1,
               last_update_date          =   SYSDATE,
               last_updated_by           =   NVL(fnd_global.user_id, -1),
               last_update_login         =   NVL(fnd_global.conc_login_id, -1),
               act_metric_used_by_id     =   l_act_metric_fact_rec.act_metric_used_by_id,
               arc_act_metric_used_by    =   l_act_metric_fact_rec.arc_act_metric_used_by,
               value_type                =   l_act_metric_fact_rec.value_type,
               activity_metric_id        =   l_act_metric_fact_rec.activity_metric_id,
               activity_geo_area_id      =   l_act_metric_fact_rec.activity_geo_area_id,
               activity_product_id       =   l_act_metric_fact_rec.activity_product_id,
               transaction_currency_code =   l_act_metric_fact_rec.transaction_currency_code,
               trans_forecasted_value    =   l_act_metric_fact_rec.trans_forecasted_value,
               base_quantity             =   l_act_metric_fact_rec.base_quantity,
               functional_currency_code  =   l_act_metric_fact_rec.functional_currency_code,
               func_forecasted_value     =   l_act_metric_fact_rec.func_forecasted_value,
               org_id                    =   l_act_metric_fact_rec.org_id,
               de_metric_id              =   l_act_metric_fact_rec.de_metric_id,
               de_geographic_area_id     =  l_act_metric_fact_rec.de_geographic_area_id,
               de_geographic_area_type   =  l_act_metric_fact_rec.de_geographic_area_type,
               de_inventory_item_id      =  l_act_metric_fact_rec.de_inventory_item_id,
               de_inventory_item_org_id  =  l_act_metric_fact_rec.de_inventory_item_org_id,
               time_id1                  =  l_act_metric_fact_rec.time_id1,
               time_id2                  =  l_act_metric_fact_rec.time_id2,
               time_id3                  =  l_act_metric_fact_rec.time_id3,
               time_id4                  =  l_act_metric_fact_rec.time_id4,
               time_id5                  =  l_act_metric_fact_rec.time_id5,
               time_id6                  =  l_act_metric_fact_rec.time_id6,
               time_id7                  =  l_act_metric_fact_rec.time_id7,
               time_id8                  =  l_act_metric_fact_rec.time_id8,
               time_id9                  =  l_act_metric_fact_rec.time_id9,
               time_id10                 =  l_act_metric_fact_rec.time_id10,
               time_id11                 =  l_act_metric_fact_rec.time_id11,
               time_id12                 =  l_act_metric_fact_rec.time_id12,
               time_id13                 =  l_act_metric_fact_rec.time_id13,
               time_id14                 =  l_act_metric_fact_rec.time_id14,
               time_id15                 =  l_act_metric_fact_rec.time_id15,
               time_id16                 =  l_act_metric_fact_rec.time_id16,
               time_id17                 =  l_act_metric_fact_rec.time_id17,
               time_id18                 =  l_act_metric_fact_rec.time_id18,
               time_id19                 =  l_act_metric_fact_rec.time_id19,
               time_id20                 =  l_act_metric_fact_rec.time_id20,
               time_id21                 =  l_act_metric_fact_rec.time_id21,
               time_id22                 =  l_act_metric_fact_rec.time_id22,
               time_id23                 =  l_act_metric_fact_rec.time_id23,
               time_id24                 =  l_act_metric_fact_rec.time_id24,
               time_id25                 =  l_act_metric_fact_rec.time_id25,
               time_id26                 =  l_act_metric_fact_rec.time_id26,
               time_id27                 =  l_act_metric_fact_rec.time_id27,
               time_id28                 =  l_act_metric_fact_rec.time_id28,
               time_id29                 =  l_act_metric_fact_rec.time_id29,
               time_id30                 =  l_act_metric_fact_rec.time_id30,
               time_id31                 =  l_act_metric_fact_rec.time_id31,
               time_id32                 =  l_act_metric_fact_rec.time_id32,
               time_id33                 =  l_act_metric_fact_rec.time_id33,
               time_id34                 =  l_act_metric_fact_rec.time_id34,
               time_id35                 =  l_act_metric_fact_rec.time_id35,
               time_id36                 =  l_act_metric_fact_rec.time_id36,
               time_id37                 =  l_act_metric_fact_rec.time_id37,
               time_id38                 =  l_act_metric_fact_rec.time_id38,
               time_id39                 =  l_act_metric_fact_rec.time_id39,
               time_id40                 =  l_act_metric_fact_rec.time_id40,
               time_id41                 =  l_act_metric_fact_rec.time_id41,
               time_id42                 =  l_act_metric_fact_rec.time_id42,
               time_id43                 =  l_act_metric_fact_rec.time_id43,
               time_id44                 =  l_act_metric_fact_rec.time_id44,
               time_id45                 =  l_act_metric_fact_rec.time_id45,
               time_id46                 =  l_act_metric_fact_rec.time_id46,
               time_id47                 =  l_act_metric_fact_rec.time_id47,
               time_id48                 =  l_act_metric_fact_rec.time_id48,
               time_id49                 =  l_act_metric_fact_rec.time_id49,
               time_id50                 =  l_act_metric_fact_rec.time_id50,
               time_id51                 =  l_act_metric_fact_rec.time_id51,
               time_id52                 =  l_act_metric_fact_rec.time_id52,
               time_id53                 =  l_act_metric_fact_rec.time_id53,
               hierarchy_id              =  l_act_metric_fact_rec.hierarchy_id,
               node_id                   =  l_act_metric_fact_rec.node_id,
               level_depth               =  l_act_metric_fact_rec.level_depth,
               formula_id                =  l_act_metric_fact_rec.formula_id,
               from_date                 =  l_act_metric_fact_rec.from_date,
               to_date                   =  l_act_metric_fact_rec.to_date,
               fact_value                =  l_act_metric_fact_rec.fact_value,
               fact_percent              =  l_act_metric_fact_rec.fact_percent,
               root_fact_id              =  l_act_metric_fact_rec.root_fact_id,
               previous_fact_id          =  l_act_metric_fact_rec.previous_fact_id,
               fact_type                 =  l_act_metric_fact_rec.fact_type,
               fact_reference            =  l_act_metric_fact_rec.fact_reference,
               forward_buy_quantity      =  l_act_metric_fact_rec.forward_buy_quantity,
               /* 05/21/2002 yzhao: add 11 new columns for top-down bottom-up budgeting */
               status_code               =  l_act_metric_fact_rec.status_code,
               hierarchy_type            =  l_act_metric_fact_rec.hierarchy_type,
               approval_date             =  l_act_metric_fact_rec.approval_date,
               recommend_total_amount    =  l_act_metric_fact_rec.recommend_total_amount,
               recommend_hb_amount       =  l_act_metric_fact_rec.recommend_hb_amount,
               request_total_amount      =  l_act_metric_fact_rec.request_total_amount,
               request_hb_amount         =  l_act_metric_fact_rec.request_hb_amount,
               actual_total_amount       =  l_act_metric_fact_rec.actual_total_amount,
               actual_hb_amount          =  l_act_metric_fact_rec.actual_hb_amount,
               base_total_pct            =  l_act_metric_fact_rec.base_total_pct,
               base_hb_pct               =  l_act_metric_fact_rec.base_hb_pct ,
               /* 05/21/2002 yzhao: add ends */
               /* 08/12/2005 mkothari: added 4 new columns for forecasting with 3rd party baseline sales */
               baseline_sales            =  l_act_metric_fact_rec.baseline_sales,
               tpr_percent               =  l_act_metric_fact_rec.tpr_percent,
               lift_factor               =  l_act_metric_fact_rec.lift_factor,
               incremental_sales         =  l_act_metric_fact_rec.incremental_sales
               /* 08/12/2005 mkothari: add ends */
    Where      activity_metric_fact_id   =  l_act_metric_fact_rec.activity_metric_fact_id;

    IF  (SQL%NOTFOUND)
    THEN
      --
      -- Add error message to API message list.
      --
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_API_RECORD_NOT_FOUND');
         FND_MSG_PUB.add;
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
   -- set the message data OUT NOCOPY variable.
   --
   FND_MSG_PUB.Count_And_Get (
      p_count           =>    x_msg_count,
      p_data            =>    x_msg_data,
      p_encoded         =>    FND_API.G_FALSE
   );

   --
   -- Debug message.
   --
   IF (OZF_DEBUG_HIGH_ON) THEN

   OZF_Utility_PVT.debug_message(l_full_name ||': end');
   END IF;


EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN



      ROLLBACK TO Update_ActMetricFact_pvt;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data
      );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN



      ROLLBACK TO Update_ActMetricFact_pvt;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data
      );
   WHEN OTHERS THEN



      ROLLBACK TO Update_ActMetricFact_pvt;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, L_API_NAME);
      END IF;
      FND_MSG_PUB.Count_And_Get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data
      );
END Update_ActMetricFact;


--
-- NAME
--    Complete_MetricFact_Rec
--
-- PURPOSE
--   Returns the Initialized Activity Metric Fact Record
--
-- NOTES
--
-- HISTORY
-- 21-Apr-2000 tdonohoe Created.
--
PROCEDURE Complete_ActMetFact_Rec(
   p_act_metric_fact_rec IN  act_metric_fact_rec_type,
   x_complete_fact_rec   OUT NOCOPY act_metric_fact_rec_type
)
IS
   CURSOR c_act_metric_fact IS
   SELECT *
   FROM ozf_act_metric_facts_all
   WHERE activity_metric_fact_id = p_act_metric_fact_rec.activity_metric_fact_id;

   l_act_metric_fact_rec  c_act_metric_fact%ROWTYPE;
BEGIN

   x_complete_fact_rec := p_act_metric_fact_rec;

   OPEN c_act_metric_fact;
   FETCH c_act_metric_fact INTO l_act_metric_fact_rec;
   IF c_act_metric_fact%NOTFOUND THEN
      CLOSE c_act_metric_fact;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_API_RECORD_NOT_FOUND');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
   END IF;
   CLOSE c_act_metric_fact;


   IF p_act_metric_fact_rec.activity_metric_fact_id = FND_API.G_MISS_NUM THEN
      x_complete_fact_rec.activity_metric_fact_id  := NULL;
   END IF;
   IF p_act_metric_fact_rec.activity_metric_fact_id IS NULL THEN
      x_complete_fact_rec.activity_metric_fact_id  := l_act_metric_fact_rec.activity_metric_fact_id;
   END IF;

   IF p_act_metric_fact_rec.act_metric_used_by_id = FND_API.G_MISS_NUM THEN
      x_complete_fact_rec.act_metric_used_by_id  :=  NULL;
   END IF;
   IF p_act_metric_fact_rec.act_metric_used_by_id IS NULL THEN
      x_complete_fact_rec.act_metric_used_by_id  :=  l_act_metric_fact_rec.act_metric_used_by_id;
   END IF;

   IF p_act_metric_fact_rec.arc_act_metric_used_by =  FND_API.G_MISS_CHAR THEN
      x_complete_fact_rec.arc_act_metric_used_by  := NULL;
   END IF;
   IF p_act_metric_fact_rec.arc_act_metric_used_by IS NULL THEN
      x_complete_fact_rec.arc_act_metric_used_by  := l_act_metric_fact_rec.arc_act_metric_used_by;
   END IF;

   IF p_act_metric_fact_rec.value_type =  FND_API.G_MISS_CHAR THEN
      x_complete_fact_rec.value_type  := NULL;
   END IF;
   IF p_act_metric_fact_rec.value_type IS NULL THEN
      x_complete_fact_rec.value_type  := l_act_metric_fact_rec.value_type;
   END IF;

   IF p_act_metric_fact_rec.activity_metric_id = FND_API.G_MISS_NUM THEN
      x_complete_fact_rec.activity_metric_id  :=  NULL;
   END IF;
   IF p_act_metric_fact_rec.activity_metric_id IS NULL THEN
      x_complete_fact_rec.activity_metric_id  :=  l_act_metric_fact_rec.activity_metric_id;
   END IF;

   IF p_act_metric_fact_rec.activity_geo_area_id = FND_API.G_MISS_NUM THEN
      x_complete_fact_rec.activity_geo_area_id  :=  NULL;
   END IF;
   IF p_act_metric_fact_rec.activity_geo_area_id IS NULL THEN
      x_complete_fact_rec.activity_geo_area_id  :=  l_act_metric_fact_rec.activity_geo_area_id;
   END IF;

   IF p_act_metric_fact_rec.activity_product_id = FND_API.G_MISS_NUM THEN
      x_complete_fact_rec.activity_product_id  :=  NULL;
   END IF;
   IF p_act_metric_fact_rec.activity_product_id IS NULL THEN
      x_complete_fact_rec.activity_product_id  :=  l_act_metric_fact_rec.activity_product_id;
   END IF;

   IF p_act_metric_fact_rec.transaction_currency_code = FND_API.G_MISS_CHAR THEN
      x_complete_fact_rec.transaction_currency_code  :=  NULL;
   END IF;
   IF p_act_metric_fact_rec.transaction_currency_code IS NULL THEN
      x_complete_fact_rec.transaction_currency_code  :=  l_act_metric_fact_rec.transaction_currency_code;
   END IF;

   IF p_act_metric_fact_rec.trans_forecasted_value = FND_API.G_MISS_NUM THEN
      x_complete_fact_rec.trans_forecasted_value  :=  NULL;
   END IF;
   IF p_act_metric_fact_rec.trans_forecasted_value IS NULL THEN
      x_complete_fact_rec.trans_forecasted_value  :=  l_act_metric_fact_rec.trans_forecasted_value;
   END IF;

   IF p_act_metric_fact_rec.base_quantity = FND_API.G_MISS_NUM THEN
      x_complete_fact_rec.base_quantity  :=  NULL;
   END IF;
   IF p_act_metric_fact_rec.base_quantity IS NULL THEN
      x_complete_fact_rec.base_quantity  :=  l_act_metric_fact_rec.base_quantity;
   END IF;

   IF p_act_metric_fact_rec.functional_currency_code = FND_API.G_MISS_CHAR THEN
      x_complete_fact_rec.functional_currency_code  :=  NULL;
   END IF;
   IF p_act_metric_fact_rec.functional_currency_code IS NULL THEN
      x_complete_fact_rec.functional_currency_code  :=  l_act_metric_fact_rec.functional_currency_code;
   END IF;

   IF p_act_metric_fact_rec.func_forecasted_value = FND_API.G_MISS_NUM THEN
      x_complete_fact_rec.func_forecasted_value  :=  NULL;
   END IF;
   IF p_act_metric_fact_rec.func_forecasted_value IS NULL THEN
      x_complete_fact_rec.func_forecasted_value  :=  l_act_metric_fact_rec.func_forecasted_value;
   END IF;

   IF p_act_metric_fact_rec.org_id = FND_API.G_MISS_NUM THEN
      x_complete_fact_rec.org_id  :=  NULL;
   END IF;
   IF p_act_metric_fact_rec.org_id IS NULL THEN
      x_complete_fact_rec.org_id  :=  l_act_metric_fact_rec.org_id;
   END IF;

   IF p_act_metric_fact_rec.de_metric_id = FND_API.G_MISS_NUM THEN
      x_complete_fact_rec.de_metric_id  :=  NULL;
   END IF;
   IF p_act_metric_fact_rec.de_metric_id IS NULL THEN
      x_complete_fact_rec.de_metric_id  :=  l_act_metric_fact_rec.de_metric_id;
   END IF;

   IF p_act_metric_fact_rec.de_geographic_area_id = FND_API.G_MISS_NUM THEN
      x_complete_fact_rec.de_geographic_area_id  :=  NULL;
   END IF;
   IF p_act_metric_fact_rec.de_geographic_area_id IS NULL THEN
      x_complete_fact_rec.de_geographic_area_id  :=  l_act_metric_fact_rec.de_geographic_area_id;
   END IF;

   IF p_act_metric_fact_rec.de_geographic_area_type = FND_API.G_MISS_CHAR THEN
      x_complete_fact_rec.de_geographic_area_type :=  NULL;
   END IF;
   IF p_act_metric_fact_rec.de_geographic_area_type IS NULL THEN
      x_complete_fact_rec.de_geographic_area_type :=  l_act_metric_fact_rec.de_geographic_area_type;
   END IF;

   IF p_act_metric_fact_rec.de_inventory_item_id = FND_API.G_MISS_NUM THEN
      x_complete_fact_rec.de_inventory_item_id  :=  NULL;
   END IF;
   IF p_act_metric_fact_rec.de_inventory_item_id IS NULL THEN
      x_complete_fact_rec.de_inventory_item_id  :=  l_act_metric_fact_rec.de_inventory_item_id;
   END IF;

   IF p_act_metric_fact_rec.de_inventory_item_org_id = FND_API.G_MISS_NUM THEN
      x_complete_fact_rec.de_inventory_item_org_id  :=  NULL;
   END IF;
   IF p_act_metric_fact_rec.de_inventory_item_org_id IS NULL THEN
      x_complete_fact_rec.de_inventory_item_org_id  :=  l_act_metric_fact_rec.de_inventory_item_org_id;
   END IF;

   IF p_act_metric_fact_rec.time_id1 = FND_API.G_MISS_NUM THEN
      x_complete_fact_rec.time_id1  :=  NULL;
   END IF;
   IF p_act_metric_fact_rec.time_id1 IS NULL THEN
      x_complete_fact_rec.time_id1  :=  l_act_metric_fact_rec.time_id1;
   END IF;

   IF p_act_metric_fact_rec.time_id2 = FND_API.G_MISS_NUM THEN
      x_complete_fact_rec.time_id2  :=  NULL;
   END IF;
   IF p_act_metric_fact_rec.time_id2 IS NULL THEN
      x_complete_fact_rec.time_id2  :=  l_act_metric_fact_rec.time_id2;
   END IF;

   IF p_act_metric_fact_rec.time_id3 = FND_API.G_MISS_NUM THEN
      x_complete_fact_rec.time_id3  :=  NULL;
   END IF;
   IF p_act_metric_fact_rec.time_id3 IS NULL THEN
      x_complete_fact_rec.time_id3  :=  l_act_metric_fact_rec.time_id3;
   END IF;

   IF p_act_metric_fact_rec.time_id4 = FND_API.G_MISS_NUM THEN
      x_complete_fact_rec.time_id4  :=  NULL;
   END IF;
   IF p_act_metric_fact_rec.time_id4 IS NULL THEN
      x_complete_fact_rec.time_id4  :=  l_act_metric_fact_rec.time_id4;
   END IF;

   IF p_act_metric_fact_rec.time_id5 = FND_API.G_MISS_NUM THEN
      x_complete_fact_rec.time_id5  :=  NULL;
   END IF;
   IF p_act_metric_fact_rec.time_id5 IS NULL THEN
      x_complete_fact_rec.time_id5  :=  l_act_metric_fact_rec.time_id5;
   END IF;

   IF p_act_metric_fact_rec.time_id6 = FND_API.G_MISS_NUM THEN
      x_complete_fact_rec.time_id6  :=  NULL;
   END IF;
   IF p_act_metric_fact_rec.time_id6 IS NULL THEN
      x_complete_fact_rec.time_id6  :=  l_act_metric_fact_rec.time_id6;
   END IF;

   IF p_act_metric_fact_rec.time_id7 = FND_API.G_MISS_NUM THEN
      x_complete_fact_rec.time_id7  :=  NULL;
   END IF;
   IF p_act_metric_fact_rec.time_id7 IS NULL THEN
      x_complete_fact_rec.time_id7  :=  l_act_metric_fact_rec.time_id7;
   END IF;

   IF p_act_metric_fact_rec.time_id8 = FND_API.G_MISS_NUM THEN
      x_complete_fact_rec.time_id8  :=  NULL;
   END IF;
   IF p_act_metric_fact_rec.time_id8 IS NULL THEN
      x_complete_fact_rec.time_id8  :=  l_act_metric_fact_rec.time_id8;
   END IF;

   IF p_act_metric_fact_rec.time_id9 = FND_API.G_MISS_NUM THEN
      x_complete_fact_rec.time_id9  :=  NULL;
   END IF;
   IF p_act_metric_fact_rec.time_id9 IS NULL THEN
      x_complete_fact_rec.time_id9  :=  l_act_metric_fact_rec.time_id9;
   END IF;

   IF p_act_metric_fact_rec.time_id10 = FND_API.G_MISS_NUM THEN
      x_complete_fact_rec.time_id10  :=  NULL;
   END IF;
   IF p_act_metric_fact_rec.time_id10 IS NULL THEN
      x_complete_fact_rec.time_id10  :=  l_act_metric_fact_rec.time_id10;
   END IF;

   IF p_act_metric_fact_rec.time_id11 = FND_API.G_MISS_NUM THEN
      x_complete_fact_rec.time_id11  :=  NULL;
   END IF;
   IF p_act_metric_fact_rec.time_id11 IS NULL THEN
      x_complete_fact_rec.time_id11  :=  l_act_metric_fact_rec.time_id11;
   END IF;

   IF p_act_metric_fact_rec.time_id12 = FND_API.G_MISS_NUM THEN
      x_complete_fact_rec.time_id12  :=  NULL;
   END IF;
   IF p_act_metric_fact_rec.time_id12 IS NULL THEN
      x_complete_fact_rec.time_id12  :=  l_act_metric_fact_rec.time_id12;
   END IF;

   IF p_act_metric_fact_rec.time_id13 = FND_API.G_MISS_NUM THEN
      x_complete_fact_rec.time_id13  :=  NULL;
   END IF;
   IF p_act_metric_fact_rec.time_id13 IS NULL THEN
      x_complete_fact_rec.time_id13  :=  l_act_metric_fact_rec.time_id13;
   END IF;

   IF p_act_metric_fact_rec.time_id14 = FND_API.G_MISS_NUM THEN
      x_complete_fact_rec.time_id14  :=  NULL;
   END IF;
   IF p_act_metric_fact_rec.time_id14 IS NULL THEN
      x_complete_fact_rec.time_id14  :=  l_act_metric_fact_rec.time_id14;
   END IF;

   IF p_act_metric_fact_rec.time_id15 = FND_API.G_MISS_NUM THEN
      x_complete_fact_rec.time_id15  :=  NULL;
   END IF;
   IF p_act_metric_fact_rec.time_id15 IS NULL THEN
      x_complete_fact_rec.time_id15  :=  l_act_metric_fact_rec.time_id15;
   END IF;

   IF p_act_metric_fact_rec.time_id16 = FND_API.G_MISS_NUM THEN
      x_complete_fact_rec.time_id16  :=  NULL;
   END IF;
   IF p_act_metric_fact_rec.time_id16 IS NULL THEN
      x_complete_fact_rec.time_id16  :=  l_act_metric_fact_rec.time_id16;
   END IF;

   IF p_act_metric_fact_rec.time_id17 = FND_API.G_MISS_NUM THEN
      x_complete_fact_rec.time_id17  :=  NULL;
   END IF;
   IF p_act_metric_fact_rec.time_id17 IS NULL THEN
      x_complete_fact_rec.time_id17  :=  l_act_metric_fact_rec.time_id17;
   END IF;

   IF p_act_metric_fact_rec.time_id18 = FND_API.G_MISS_NUM THEN
      x_complete_fact_rec.time_id18  :=  NULL;
   END IF;
   IF p_act_metric_fact_rec.time_id18 IS NULL THEN
      x_complete_fact_rec.time_id18  :=  l_act_metric_fact_rec.time_id18;
   END IF;

   IF p_act_metric_fact_rec.time_id19 = FND_API.G_MISS_NUM THEN
      x_complete_fact_rec.time_id19  :=  NULL;
   END IF;
   IF p_act_metric_fact_rec.time_id19 IS NULL THEN
      x_complete_fact_rec.time_id19  :=  l_act_metric_fact_rec.time_id19;
   END IF;

   IF p_act_metric_fact_rec.time_id20 = FND_API.G_MISS_NUM THEN
      x_complete_fact_rec.time_id20  :=  NULL;
   END IF;
   IF p_act_metric_fact_rec.time_id20 IS NULL THEN
      x_complete_fact_rec.time_id20  :=  l_act_metric_fact_rec.time_id20;
   END IF;

   IF p_act_metric_fact_rec.time_id21 = FND_API.G_MISS_NUM THEN
      x_complete_fact_rec.time_id21  :=  NULL;
   END IF;
   IF p_act_metric_fact_rec.time_id21 IS NULL THEN
      x_complete_fact_rec.time_id21  :=  l_act_metric_fact_rec.time_id21;
   END IF;

   IF p_act_metric_fact_rec.time_id22 = FND_API.G_MISS_NUM THEN
      x_complete_fact_rec.time_id22  :=  NULL;
   END IF;
   IF p_act_metric_fact_rec.time_id22 IS NULL THEN
      x_complete_fact_rec.time_id22  :=  l_act_metric_fact_rec.time_id22;
   END IF;

   IF p_act_metric_fact_rec.time_id23 = FND_API.G_MISS_NUM THEN
      x_complete_fact_rec.time_id23  :=  NULL;
   END IF;
   IF p_act_metric_fact_rec.time_id23 IS NULL THEN
      x_complete_fact_rec.time_id23  :=  l_act_metric_fact_rec.time_id23;
   END IF;

   IF p_act_metric_fact_rec.time_id24 = FND_API.G_MISS_NUM THEN
      x_complete_fact_rec.time_id24  :=  NULL;
   END IF;
   IF p_act_metric_fact_rec.time_id24 IS NULL THEN
      x_complete_fact_rec.time_id24  :=  l_act_metric_fact_rec.time_id24;
   END IF;

   IF p_act_metric_fact_rec.time_id25 = FND_API.G_MISS_NUM THEN
      x_complete_fact_rec.time_id25  :=  NULL;
   END IF;
   IF p_act_metric_fact_rec.time_id25 IS NULL THEN
      x_complete_fact_rec.time_id25  :=  l_act_metric_fact_rec.time_id25;
   END IF;

   IF p_act_metric_fact_rec.time_id26 = FND_API.G_MISS_NUM THEN
      x_complete_fact_rec.time_id26  :=  NULL;
   END IF;
   IF p_act_metric_fact_rec.time_id26 IS NULL THEN
      x_complete_fact_rec.time_id26  :=  l_act_metric_fact_rec.time_id26;
   END IF;

   IF p_act_metric_fact_rec.time_id27 = FND_API.G_MISS_NUM THEN
      x_complete_fact_rec.time_id27  :=  NULL;
   END IF;
   IF p_act_metric_fact_rec.time_id27 IS NULL THEN
      x_complete_fact_rec.time_id27  :=  l_act_metric_fact_rec.time_id27;
   END IF;

   IF p_act_metric_fact_rec.time_id28 = FND_API.G_MISS_NUM THEN
      x_complete_fact_rec.time_id28  :=  NULL;
   END IF;
   IF p_act_metric_fact_rec.time_id28 IS NULL THEN
      x_complete_fact_rec.time_id28  :=  l_act_metric_fact_rec.time_id28;
   END IF;

   IF p_act_metric_fact_rec.time_id29 = FND_API.G_MISS_NUM THEN
      x_complete_fact_rec.time_id29  :=  NULL;
   END IF;
   IF p_act_metric_fact_rec.time_id29 IS NULL THEN
      x_complete_fact_rec.time_id29  :=  l_act_metric_fact_rec.time_id29;
   END IF;

   IF p_act_metric_fact_rec.time_id30 = FND_API.G_MISS_NUM THEN
      x_complete_fact_rec.time_id30  :=  NULL;
   END IF;
   IF p_act_metric_fact_rec.time_id30 IS NULL THEN
      x_complete_fact_rec.time_id30  :=  l_act_metric_fact_rec.time_id30;
   END IF;

   IF p_act_metric_fact_rec.time_id31 = FND_API.G_MISS_NUM THEN
      x_complete_fact_rec.time_id31  :=  NULL;
   END IF;
   IF p_act_metric_fact_rec.time_id31 IS NULL THEN
      x_complete_fact_rec.time_id31  :=  l_act_metric_fact_rec.time_id31;
   END IF;

   IF p_act_metric_fact_rec.time_id32 = FND_API.G_MISS_NUM THEN
      x_complete_fact_rec.time_id32  :=  NULL;
   END IF;
   IF p_act_metric_fact_rec.time_id32 IS NULL THEN
      x_complete_fact_rec.time_id32  :=  l_act_metric_fact_rec.time_id32;
   END IF;

   IF p_act_metric_fact_rec.time_id33 = FND_API.G_MISS_NUM THEN
      x_complete_fact_rec.time_id33  :=  NULL;
   END IF;
   IF p_act_metric_fact_rec.time_id33 IS NULL THEN
      x_complete_fact_rec.time_id33  :=  l_act_metric_fact_rec.time_id33;
   END IF;

   IF p_act_metric_fact_rec.time_id34 = FND_API.G_MISS_NUM THEN
      x_complete_fact_rec.time_id34  :=  NULL;
   END IF;
   IF p_act_metric_fact_rec.time_id34 IS NULL THEN
      x_complete_fact_rec.time_id34  :=  l_act_metric_fact_rec.time_id34;
   END IF;

   IF p_act_metric_fact_rec.time_id35 = FND_API.G_MISS_NUM THEN
      x_complete_fact_rec.time_id35  :=  NULL;
   END IF;
   IF p_act_metric_fact_rec.time_id35 IS NULL THEN
      x_complete_fact_rec.time_id35  :=  l_act_metric_fact_rec.time_id35;
   END IF;

   IF p_act_metric_fact_rec.time_id36 = FND_API.G_MISS_NUM THEN
      x_complete_fact_rec.time_id36  :=  NULL;
   END IF;
   IF p_act_metric_fact_rec.time_id36 IS NULL THEN
      x_complete_fact_rec.time_id36  :=  l_act_metric_fact_rec.time_id36;
   END IF;

   IF p_act_metric_fact_rec.time_id37 = FND_API.G_MISS_NUM THEN
      x_complete_fact_rec.time_id37  :=  NULL;
   END IF;
   IF p_act_metric_fact_rec.time_id37 IS NULL THEN
      x_complete_fact_rec.time_id37  :=  l_act_metric_fact_rec.time_id37;
   END IF;

   IF p_act_metric_fact_rec.time_id38 = FND_API.G_MISS_NUM THEN
      x_complete_fact_rec.time_id38  :=  NULL;
   END IF;
   IF p_act_metric_fact_rec.time_id38 IS NULL THEN
      x_complete_fact_rec.time_id38  :=  l_act_metric_fact_rec.time_id38;
   END IF;

   IF p_act_metric_fact_rec.time_id39 = FND_API.G_MISS_NUM THEN
      x_complete_fact_rec.time_id39  :=  NULL;
   END IF;
   IF p_act_metric_fact_rec.time_id39 IS NULL THEN
      x_complete_fact_rec.time_id39  :=  l_act_metric_fact_rec.time_id39;
   END IF;

   IF p_act_metric_fact_rec.time_id40 = FND_API.G_MISS_NUM THEN
      x_complete_fact_rec.time_id40  :=  NULL;
   END IF;
   IF p_act_metric_fact_rec.time_id40 IS NULL THEN
      x_complete_fact_rec.time_id40  :=  l_act_metric_fact_rec.time_id40;
   END IF;

   IF p_act_metric_fact_rec.time_id41 = FND_API.G_MISS_NUM THEN
      x_complete_fact_rec.time_id41  :=  NULL;
   END IF;
   IF p_act_metric_fact_rec.time_id41 IS NULL THEN
      x_complete_fact_rec.time_id41  :=  l_act_metric_fact_rec.time_id41;
   END IF;

   IF p_act_metric_fact_rec.time_id42 = FND_API.G_MISS_NUM THEN
      x_complete_fact_rec.time_id42  :=  NULL;
   END IF;
   IF p_act_metric_fact_rec.time_id42 IS NULL THEN
      x_complete_fact_rec.time_id42  :=  l_act_metric_fact_rec.time_id42;
   END IF;

   IF p_act_metric_fact_rec.time_id43 = FND_API.G_MISS_NUM THEN
      x_complete_fact_rec.time_id43  :=  NULL;
   END IF;
   IF p_act_metric_fact_rec.time_id43 IS NULL THEN
      x_complete_fact_rec.time_id43  :=  l_act_metric_fact_rec.time_id43;
   END IF;

   IF p_act_metric_fact_rec.time_id44 = FND_API.G_MISS_NUM THEN
      x_complete_fact_rec.time_id44  :=  NULL;
   END IF;
   IF p_act_metric_fact_rec.time_id44 IS NULL THEN
      x_complete_fact_rec.time_id44  :=  l_act_metric_fact_rec.time_id44;
   END IF;

   IF p_act_metric_fact_rec.time_id45 = FND_API.G_MISS_NUM THEN
      x_complete_fact_rec.time_id45  :=  NULL;
   END IF;
   IF p_act_metric_fact_rec.time_id45 IS NULL THEN
      x_complete_fact_rec.time_id45  :=  l_act_metric_fact_rec.time_id45;
   END IF;

   IF p_act_metric_fact_rec.time_id46 = FND_API.G_MISS_NUM THEN
      x_complete_fact_rec.time_id46  :=  NULL;
   END IF;
   IF p_act_metric_fact_rec.time_id46 IS NULL THEN
      x_complete_fact_rec.time_id46  :=  l_act_metric_fact_rec.time_id46;
   END IF;

   IF p_act_metric_fact_rec.time_id47 = FND_API.G_MISS_NUM THEN
      x_complete_fact_rec.time_id47  :=  NULL;
   END IF;
   IF p_act_metric_fact_rec.time_id47 IS NULL THEN
      x_complete_fact_rec.time_id47  :=  l_act_metric_fact_rec.time_id47;
   END IF;

   IF p_act_metric_fact_rec.time_id48 = FND_API.G_MISS_NUM THEN
      x_complete_fact_rec.time_id48  :=  NULL;
   END IF;
   IF p_act_metric_fact_rec.time_id48 IS NULL THEN
      x_complete_fact_rec.time_id48  :=  l_act_metric_fact_rec.time_id48;
   END IF;

   IF p_act_metric_fact_rec.time_id49 = FND_API.G_MISS_NUM THEN
      x_complete_fact_rec.time_id49  :=  NULL;
   END IF;
   IF p_act_metric_fact_rec.time_id49 IS NULL THEN
      x_complete_fact_rec.time_id49  :=  l_act_metric_fact_rec.time_id49;
   END IF;

   IF p_act_metric_fact_rec.time_id50 = FND_API.G_MISS_NUM THEN
      x_complete_fact_rec.time_id50  :=  NULL;
   END IF;
   IF p_act_metric_fact_rec.time_id50 IS NULL THEN
      x_complete_fact_rec.time_id50  :=  l_act_metric_fact_rec.time_id50;
   END IF;

   IF p_act_metric_fact_rec.time_id51 = FND_API.G_MISS_NUM THEN
      x_complete_fact_rec.time_id51  :=  NULL;
   END IF;
   IF p_act_metric_fact_rec.time_id51 IS NULL THEN
      x_complete_fact_rec.time_id51  :=  l_act_metric_fact_rec.time_id51;
   END IF;

   IF p_act_metric_fact_rec.time_id52 = FND_API.G_MISS_NUM THEN
      x_complete_fact_rec.time_id52  :=  NULL;
   END IF;
   IF p_act_metric_fact_rec.time_id52 IS NULL THEN
      x_complete_fact_rec.time_id52  :=  l_act_metric_fact_rec.time_id52;
   END IF;

   IF p_act_metric_fact_rec.time_id53 = FND_API.G_MISS_NUM THEN
      x_complete_fact_rec.time_id53  :=  NULL;
   END IF;
   IF p_act_metric_fact_rec.time_id53 IS NULL THEN
      x_complete_fact_rec.time_id53  :=  l_act_metric_fact_rec.time_id53;
   END IF;

   IF p_act_metric_fact_rec.hierarchy_id = FND_API.G_MISS_NUM THEN
      x_complete_fact_rec.hierarchy_id  :=  NULL;
   END IF;
   IF p_act_metric_fact_rec.hierarchy_id IS NULL THEN
      x_complete_fact_rec.hierarchy_id  :=  l_act_metric_fact_rec.hierarchy_id;
   END IF;

   IF p_act_metric_fact_rec.node_id = FND_API.G_MISS_NUM THEN
      x_complete_fact_rec.node_id  :=  NULL;
   END IF;
   IF p_act_metric_fact_rec.node_id IS NULL THEN
      x_complete_fact_rec.node_id  :=  l_act_metric_fact_rec.node_id;
   END IF;

   IF p_act_metric_fact_rec.level_depth = FND_API.G_MISS_NUM THEN
      x_complete_fact_rec.level_depth  :=  NULL;
   END IF;
   IF p_act_metric_fact_rec.level_depth IS NULL THEN
      x_complete_fact_rec.level_depth  :=  l_act_metric_fact_rec.level_depth;
   END IF;

   IF p_act_metric_fact_rec.formula_id = FND_API.G_MISS_NUM THEN
      x_complete_fact_rec.formula_id  :=  NULL;
   END IF;
   IF p_act_metric_fact_rec.formula_id IS NULL THEN
      x_complete_fact_rec.formula_id  :=  l_act_metric_fact_rec.formula_id;
   END IF;

   IF p_act_metric_fact_rec.from_date = FND_API.G_MISS_DATE THEN
      x_complete_fact_rec.from_date  :=  NULL;
   END IF;
   IF p_act_metric_fact_rec.from_date IS NULL THEN
      x_complete_fact_rec.from_date  :=  l_act_metric_fact_rec.from_date;
   END IF;

   IF p_act_metric_fact_rec.to_date = FND_API.G_MISS_DATE THEN
      x_complete_fact_rec.to_date  :=  NULL;
   END IF;
   IF p_act_metric_fact_rec.to_date IS NULL THEN
      x_complete_fact_rec.to_date  :=  l_act_metric_fact_rec.to_date;
   END IF;

   IF p_act_metric_fact_rec.fact_value = FND_API.G_MISS_NUM THEN
      x_complete_fact_rec.fact_value  :=  NULL;
   END IF;
   IF p_act_metric_fact_rec.fact_value IS NULL THEN
      x_complete_fact_rec.fact_value  :=  l_act_metric_fact_rec.fact_value;
   END IF;

   IF p_act_metric_fact_rec.fact_percent = FND_API.G_MISS_NUM THEN
      x_complete_fact_rec.fact_percent  :=  NULL;
   END IF;
   IF p_act_metric_fact_rec.fact_percent IS NULL THEN
      x_complete_fact_rec.fact_percent  :=  l_act_metric_fact_rec.fact_percent;
   END IF;

   IF p_act_metric_fact_rec.root_fact_id = FND_API.G_MISS_NUM THEN
      x_complete_fact_rec.root_fact_id  :=  NULL;
   END IF;
   IF p_act_metric_fact_rec.root_fact_id IS NULL THEN
      x_complete_fact_rec.root_fact_id  :=  l_act_metric_fact_rec.root_fact_id;
   END IF;

   IF p_act_metric_fact_rec.previous_fact_id = FND_API.G_MISS_NUM THEN
      x_complete_fact_rec.previous_fact_id  :=  NULL;
   END IF;
   IF p_act_metric_fact_rec.previous_fact_id IS NULL THEN
      x_complete_fact_rec.previous_fact_id  :=  l_act_metric_fact_rec.previous_fact_id;
   END IF;

   IF p_act_metric_fact_rec.fact_type = FND_API.G_MISS_CHAR THEN
      x_complete_fact_rec.fact_type  :=  NULL;
   END IF;
   IF p_act_metric_fact_rec.fact_type IS NULL THEN
      x_complete_fact_rec.fact_type  :=  l_act_metric_fact_rec.fact_type;
   END IF;

   IF p_act_metric_fact_rec.fact_reference = FND_API.G_MISS_CHAR THEN
      x_complete_fact_rec.fact_reference  :=  NULL;
   END IF;
   IF p_act_metric_fact_rec.fact_reference IS NULL THEN
      x_complete_fact_rec.fact_reference  :=  l_act_metric_fact_rec.fact_reference;
   END IF;

   IF p_act_metric_fact_rec.forward_buy_quantity = FND_API.G_MISS_NUM THEN
      x_complete_fact_rec.forward_buy_quantity  :=  NULL;
   END IF;
   IF p_act_metric_fact_rec.forward_buy_quantity IS NULL THEN
      x_complete_fact_rec.forward_buy_quantity  :=  l_act_metric_fact_rec.forward_buy_quantity;
   END IF;

   /* 05/21/2002 yzhao: add 11 new columns for top-down bottom-up budgeting */
   IF p_act_metric_fact_rec.status_code = FND_API.G_MISS_CHAR THEN
      x_complete_fact_rec.status_code  :=  NULL;
   END IF;
   IF p_act_metric_fact_rec.status_code IS NULL THEN
      x_complete_fact_rec.status_code  :=  l_act_metric_fact_rec.status_code;
   END IF;

   IF p_act_metric_fact_rec.hierarchy_type = FND_API.G_MISS_CHAR THEN
      x_complete_fact_rec.hierarchy_type  :=  NULL;
   END IF;
   IF p_act_metric_fact_rec.hierarchy_type IS NULL THEN
      x_complete_fact_rec.hierarchy_type  :=  l_act_metric_fact_rec.hierarchy_type;
   END IF;

   IF p_act_metric_fact_rec.approval_date = FND_API.G_MISS_DATE THEN
      x_complete_fact_rec.approval_date  :=  NULL;
   END IF;
   IF p_act_metric_fact_rec.approval_date IS NULL THEN
      x_complete_fact_rec.approval_date  :=  l_act_metric_fact_rec.approval_date;
   END IF;

   IF p_act_metric_fact_rec.recommend_total_amount = FND_API.G_MISS_NUM THEN
      x_complete_fact_rec.recommend_total_amount  :=  NULL;
   END IF;
   IF p_act_metric_fact_rec.recommend_total_amount IS NULL THEN
      x_complete_fact_rec.recommend_total_amount  :=  l_act_metric_fact_rec.recommend_total_amount;
   END IF;

   IF p_act_metric_fact_rec.recommend_hb_amount = FND_API.G_MISS_NUM THEN
      x_complete_fact_rec.recommend_hb_amount  :=  NULL;
   END IF;
   IF p_act_metric_fact_rec.recommend_hb_amount IS NULL THEN
      x_complete_fact_rec.recommend_hb_amount  :=  l_act_metric_fact_rec.recommend_hb_amount;
   END IF;

   IF p_act_metric_fact_rec.request_total_amount = FND_API.G_MISS_NUM THEN
      x_complete_fact_rec.request_total_amount  :=  NULL;
   END IF;
   IF p_act_metric_fact_rec.request_total_amount IS NULL THEN
      x_complete_fact_rec.request_total_amount  :=  l_act_metric_fact_rec.request_total_amount;
   END IF;

   IF p_act_metric_fact_rec.request_hb_amount = FND_API.G_MISS_NUM THEN
      x_complete_fact_rec.request_hb_amount  :=  NULL;
   END IF;
   IF p_act_metric_fact_rec.request_hb_amount IS NULL THEN
      x_complete_fact_rec.request_hb_amount  :=  l_act_metric_fact_rec.request_hb_amount;
   END IF;

   IF p_act_metric_fact_rec.actual_total_amount = FND_API.G_MISS_NUM THEN
      x_complete_fact_rec.actual_total_amount  :=  NULL;
   END IF;
   IF p_act_metric_fact_rec.actual_total_amount IS NULL THEN
      x_complete_fact_rec.actual_total_amount  :=  l_act_metric_fact_rec.actual_total_amount;
   END IF;

   IF p_act_metric_fact_rec.actual_hb_amount = FND_API.G_MISS_NUM THEN
      x_complete_fact_rec.actual_hb_amount  :=  NULL;
   END IF;
   IF p_act_metric_fact_rec.actual_hb_amount IS NULL THEN
      x_complete_fact_rec.actual_hb_amount  :=  l_act_metric_fact_rec.actual_hb_amount;
   END IF;

   IF p_act_metric_fact_rec.base_total_pct = FND_API.G_MISS_NUM THEN
      x_complete_fact_rec.base_total_pct  :=  NULL;
   END IF;
   IF p_act_metric_fact_rec.base_total_pct IS NULL THEN
      x_complete_fact_rec.base_total_pct  :=  l_act_metric_fact_rec.base_total_pct;
   END IF;

   IF p_act_metric_fact_rec.base_hb_pct = FND_API.G_MISS_NUM THEN
      x_complete_fact_rec.base_hb_pct  :=  NULL;
   END IF;
   IF p_act_metric_fact_rec.base_hb_pct IS NULL THEN
      x_complete_fact_rec.base_hb_pct  :=  l_act_metric_fact_rec.base_hb_pct;
   END IF;
   /* 05/21/2002 yzhao: add ends */

   /* 08/12/2005 mkothari: added 4 new columns for forecasting with 3rd party baseline sales */
   IF p_act_metric_fact_rec.baseline_sales = FND_API.G_MISS_NUM THEN
      x_complete_fact_rec.baseline_sales  :=  NULL;
   END IF;
   IF p_act_metric_fact_rec.baseline_sales IS NULL THEN
      x_complete_fact_rec.baseline_sales  :=  l_act_metric_fact_rec.baseline_sales;
   END IF;

   IF p_act_metric_fact_rec.tpr_percent = FND_API.G_MISS_NUM THEN
      x_complete_fact_rec.tpr_percent  :=  NULL;
   END IF;
   IF p_act_metric_fact_rec.tpr_percent IS NULL THEN
      x_complete_fact_rec.tpr_percent  :=  l_act_metric_fact_rec.tpr_percent;
   END IF;

   IF p_act_metric_fact_rec.lift_factor = FND_API.G_MISS_NUM THEN
      x_complete_fact_rec.lift_factor  :=  NULL;
   END IF;
   IF p_act_metric_fact_rec.lift_factor IS NULL THEN
      x_complete_fact_rec.lift_factor  :=  l_act_metric_fact_rec.lift_factor;
   END IF;

   IF p_act_metric_fact_rec.incremental_sales = FND_API.G_MISS_NUM THEN
      x_complete_fact_rec.incremental_sales  :=  NULL;
   END IF;
   IF p_act_metric_fact_rec.incremental_sales IS NULL THEN
      x_complete_fact_rec.incremental_sales  :=  l_act_metric_fact_rec.incremental_sales;
   END IF;
   /* 08/12/2005 mkothari: add ends */

END Complete_ActMetFact_Rec ;


-- Start of comments
-- NAME
--    Validate_ActMetFact
--
-- PURPOSE
--   Validation API for Activity metric facts table.
--

-- NOTES
--
-- HISTORY
-- 24-Apr-2000 tdonohoe  Created.

--
-- End of comments

PROCEDURE Validate_ActMetFact (
   p_api_version                IN  NUMBER,
   p_init_msg_list              IN  VARCHAR2 := FND_API.G_FALSE,
   p_validation_level           IN  NUMBER   := FND_API.G_Valid_Level_Full,

   x_return_status              OUT NOCOPY VARCHAR2,
   x_msg_count                  OUT NOCOPY NUMBER,
   x_msg_data                   OUT NOCOPY VARCHAR2,

   p_act_metric_fact_rec        IN  act_metric_fact_rec_type
)
IS
   L_API_VERSION               CONSTANT NUMBER := 1.0;
   L_API_NAME                  CONSTANT VARCHAR2(30) := 'VALIDATE_ACTMETRICFACT';
   L_FULL_NAME              CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;


   l_return_status             VARCHAR2(1);

BEGIN
   --
   -- Output debug message.
   --
   IF (OZF_DEBUG_HIGH_ON) THEN

   OZF_Utility_PVT.debug_message(l_full_name||': start');
   END IF;

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

   IF (OZF_DEBUG_HIGH_ON) THEN



   OZF_Utility_PVT.debug_message(l_full_name||': Validate items');

   END IF;



   -- Validate required items in the record.
   IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN

       Validate_ActMetFact_Items(
         p_act_metric_fact_rec     => p_act_metric_fact_rec,
         p_validation_mode        => JTF_PLSQL_API.g_create,
         x_return_status          => l_return_status
      );

      -- If any errors happen abort API.
      IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;
   END IF;

      IF (OZF_DEBUG_HIGH_ON) THEN



      OZF_Utility_PVT.debug_message(l_full_name||': check record');

      END IF;




  IF p_validation_level >= JTF_PLSQL_API.g_valid_level_record THEN
      Validate_ActMetFact_Rec(
         p_act_metric_fact_rec   => p_act_metric_fact_rec,
         p_complete_fact_rec        => NULL,
         x_return_status       => l_return_status
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
   -- set the message data OUT NOCOPY variable.
   --
   FND_MSG_PUB.Count_And_Get (
      p_count           =>    x_msg_count,
      p_data            =>    x_msg_data,
      p_encoded         =>    FND_API.G_FALSE
   );



   IF (OZF_DEBUG_HIGH_ON) THEN







   OZF_Utility_PVT.debug_message(l_full_name ||': end');



   END IF;



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
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data
      );
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, L_API_NAME);
      END IF;
      FND_MSG_PUB.Count_And_Get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data
      );
END Validate_ActMetFact;


-- Start of comments.
--
-- NAME
--    Check_Req_ActMetricFact_Items
--
-- PURPOSE
--    Validate required metric fact items.
--
-- NOTES
--
-- HISTORY
-- 24-Apr-2000 tdonohoe  Created.
--
-- End of comments.

PROCEDURE Check_Req_ActMetricFact_Items (
   p_act_metric_fact_rec  IN act_metric_fact_rec_type,
   x_return_status        OUT NOCOPY VARCHAR2
)
IS
BEGIN
   -- Initialize return status to success.
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   --ACT_METRIC_USED_BY_ID




   IF p_act_metric_fact_rec.act_metric_used_by_id IS NULL
   THEN
         -- missing required fields
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
      THEN -- MMSG
         FND_MESSAGE.Set_Name('OZF', 'OZF_METR_MISSING_ARC_USED_FOR');
         FND_MSG_PUB.Add;
      END IF;

      x_return_status := FND_API.G_RET_STS_ERROR;

      -- If any error happens abort API.
      RETURN;
   END IF;

   --ARC_ACT_METRIC_USED_BY



   IF p_act_metric_fact_rec.arc_act_metric_used_by IS NULL
   THEN
         -- missing required fields
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
      THEN -- MMSG
         FND_MESSAGE.Set_Name('OZF', 'OZF_METR_MISSING_ARC_USED_FOR');
         FND_MSG_PUB.Add;
      END IF;

      x_return_status := FND_API.G_RET_STS_ERROR;

      -- If any error happens abort API.
      RETURN;
   END IF;

   --VALUE_TYPE



   IF p_act_metric_fact_rec.value_type IS NULL
   THEN
         -- missing required fields
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
      THEN -- MMSG
         FND_MESSAGE.Set_Name('OZF', 'OZF_METR_MISSING_VAL_TYPE');
         FND_MSG_PUB.Add;
      END IF;

      x_return_status := FND_API.G_RET_STS_ERROR;

      -- If any error happens abort API.
      RETURN;
   END IF;

   --ACTIVITY_METRIC_ID




   IF p_act_metric_fact_rec.activity_metric_id IS NULL
   THEN
         -- missing required fields
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
      THEN -- MMSG
         FND_MESSAGE.Set_Name('OZF', 'OZF_METR_MISSING_ACT_METRIC_ID');
         FND_MSG_PUB.Add;
      END IF;

      x_return_status := FND_API.G_RET_STS_ERROR;

      -- If any error happens abort API.
      RETURN;
   END IF;

   --TRANS_FORECASTED_VALUE



   IF p_act_metric_fact_rec.trans_forecasted_value IS NULL
   THEN
         -- missing required fields
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
      THEN -- MMSG
         FND_MESSAGE.Set_Name('OZF', 'OZF_METR_MISSING_TRAN_FCST_VAL');
         FND_MSG_PUB.Add;
      END IF;

      x_return_status := FND_API.G_RET_STS_ERROR;

      -- If any error happens abort API.
      RETURN;
   END IF;




   --FUNCTIONAL_CURRENCY_CODE
   IF p_act_metric_fact_rec.functional_currency_code IS NULL
   THEN
         -- missing required fields
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
      THEN -- MMSG
         FND_MESSAGE.Set_Name('OZF', 'OZF_METR_MISSING_FUNC_CUR_CODE');
         FND_MSG_PUB.Add;
      END IF;

      x_return_status := FND_API.G_RET_STS_ERROR;

      -- If any error happens abort API.
      RETURN;
   END IF;

   --FUNC_FORECASTED_VALUE



   IF p_act_metric_fact_rec.func_forecasted_value IS NULL
   THEN
         -- missing required fields
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
      THEN -- MMSG
         FND_MESSAGE.Set_Name('OZF', 'OZF_METR_MISSING_FUNC_FCST_VAL');
         FND_MSG_PUB.Add;
      END IF;

      x_return_status := FND_API.G_RET_STS_ERROR;

      -- If any error happens abort API.
      RETURN;
   END IF;

   --DE_METRIC_ID




   IF p_act_metric_fact_rec.de_metric_id IS NULL
   THEN
         -- missing required fields
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
      THEN -- MMSG
         FND_MESSAGE.Set_Name('OZF', 'OZF_METR_MISSING_METRIC_ID');
         FND_MSG_PUB.Add;
      END IF;

      x_return_status := FND_API.G_RET_STS_ERROR;

      -- If any error happens abort API.
      RETURN;
   END IF;

   --TIME_ID1




   IF p_act_metric_fact_rec.time_id1 IS NULL
   THEN
         -- missing required fields
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
      THEN -- MMSG
         FND_MESSAGE.Set_Name('OZF', 'OZF_METR_MISSING_TIME_ID1');
         FND_MSG_PUB.Add;
      END IF;

      x_return_status := FND_API.G_RET_STS_ERROR;

      -- If any error happens abort API.
      RETURN;
   END IF;



   -------------------------------------------------------------------------------------
   --When a Hierarchy Id is present then the node_id and fact_value fields are mandatory
   -------------------------------------------------------------------------------------
   IF p_act_metric_fact_rec.hierarchy_id IS NOT NULL AND p_act_metric_fact_rec.hierarchy_id <> FND_API.G_MISS_NUM
   THEN






        IF p_act_metric_fact_rec.node_id IS NULL
        THEN



            -- missing required fields
             IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
             THEN -- MMSG
             FND_MESSAGE.Set_Name('OZF', 'OZF_METR_MISSING_NODE_ID');
             FND_MSG_PUB.Add;
             END IF;

             x_return_status := FND_API.G_RET_STS_ERROR;

             -- If any error happens abort API.
             RETURN;
         END IF;




        IF p_act_metric_fact_rec.fact_value IS NULL
        THEN
            -- missing required fields
             IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
             THEN -- MMSG
             FND_MESSAGE.Set_Name('OZF', 'OZF_METR_MISSING_FACT_VAL');
             FND_MSG_PUB.Add;
             END IF;

             x_return_status := FND_API.G_RET_STS_ERROR;

             -- If any error happens abort API.
             RETURN;
         END IF;

   END IF;

EXCEPTION
   WHEN OTHERS THEN
      RAISE;
END Check_Req_ActMetricFact_Items;


--
-- Start of comments.
--
-- NAME
--    Check_ActMetricFact_UK_Items
--
-- PURPOSE
--    Perform Uniqueness check for Activity metric facts.
--
-- NOTES
--
-- HISTORY
-- 24-Apr-2000    tdonohoe Created.
-- End of comments.


PROCEDURE Check_ActMetricFact_UK_Items(
   p_act_metric_fact_rec IN  act_metric_fact_rec_type,
   p_validation_mode      IN  VARCHAR2 := JTF_PLSQL_API.g_create,
   x_return_status        OUT NOCOPY VARCHAR2
)
IS
   l_where_clause VARCHAR2(2000); -- Used By Check_Uniqueness
BEGIN

   x_return_status := FND_API.g_ret_sts_success;

   -- For Create_ActMetricFact, when activity_metric_fact_id is passed in, we need to
   -- check if this activity_metric_id is unique.
   IF p_validation_mode = JTF_PLSQL_API.g_create
      AND p_act_metric_fact_rec.activity_metric_fact_id IS NOT NULL
   THEN

      l_where_clause := ' activity_metric_fact_id = '||p_act_metric_fact_rec.activity_metric_fact_id ;

      IF OZF_Utility_PVT.Check_Uniqueness(
               p_table_name      => 'ozf_act_metric_facts_all',
            p_where_clause    => l_where_clause
            ) = FND_API.g_false
        THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
            THEN
            FND_MESSAGE.set_name('OZF', 'OZF_METR_FACT_DUP_ID');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;


END Check_ActMetricFact_Uk_Items;


--
-- Start of comments.
--
-- NAME
--    Check_ActMetricFact_Items
--
-- PURPOSE
--    Perform item level validation for Activity metric facts.
--
-- NOTES
--
-- HISTORY
-- 24-Apr-2000 tdonohoe Created.
-- 28-Jun 2000 tdonohoe Modified Check_ActMetricFact_Items to allow the same node to appear on a
--                      hierarchy combined with a unique formula_id.
-- End of comments.

PROCEDURE Check_ActMetricFact_Items (
   p_act_metric_fact_rec IN  act_metric_fact_rec_type,
   x_return_status       OUT NOCOPY VARCHAR2
)
IS
   l_item_name                   VARCHAR2(30);  -- Used to standardize error messages.
   l_act_metric_fact_rec         act_metric_fact_rec_type := p_act_metric_fact_rec;
   l_return_status               VARCHAR2(1);


   l_table_name                  VARCHAR2(30);
   l_pk_name                     VARCHAR2(30);
   l_pk_value                    VARCHAR2(30);
   l_pk_data_type                VARCHAR2(30);
   l_additional_where_clause     VARCHAR2(4000);  -- Used by Check_FK_Exists.
   l_lookup_type                 VARCHAR2(30);

   CURSOR c_hierarchy_node_check(p_hierarchy_id number,p_node_id number,p_act_metric_fact_id number,p_act_metric_id number,p_formula_id number) IS
   SELECT 1 from ozf_act_metric_facts_all
   WHERE hierarchy_id            = p_hierarchy_id
   AND   node_id                 = p_node_id
   AND   formula_id              = p_formula_id
   AND   activity_metric_fact_id <> p_act_metric_fact_id
   AND   activity_metric_id      = p_act_metric_id;

   l_fact_exists number;


BEGIN
   -- Initialize return status to success.
   x_return_status := FND_API.G_RET_STS_SUCCESS;



   -- ACTIVITY_METRIC_ID
   -- Do not validate FK if NULL

   IF l_act_metric_fact_rec.activity_metric_id <> FND_API.G_MISS_NUM THEN
      l_table_name               := 'OZF_ACT_METRICS_ALL';
      l_pk_name                  := 'ACTIVITY_METRIC_ID';
      l_pk_value                 := l_act_metric_fact_rec.activity_metric_id;
      l_pk_data_type             := OZF_Utility_PVT.G_NUMBER;
      l_additional_where_clause  := NULL ;

      IF OZF_Utility_PVT.Check_FK_Exists (
             p_table_name            => l_table_name
            ,p_pk_name                    => l_pk_name
            ,p_pk_value                    => l_pk_value
            ,p_pk_data_type                => l_pk_data_type
            ,p_additional_where_clause  => l_additional_where_clause
         ) = FND_API.G_FALSE
      THEN
         IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
         THEN
             FND_MESSAGE.Set_Name('OZF', 'OZF_METR_INVALID_MET');
             FND_MSG_PUB.Add;
         END IF;

         x_return_status := FND_API.G_RET_STS_ERROR;
         RETURN;
      END IF;  -- Check_FK_Exists

   END IF;



   -- ARC_ACT_METRIC_USED_BY
   IF l_act_metric_fact_rec.arc_act_metric_used_by <> FND_API.G_MISS_CHAR THEN
      IF l_act_metric_fact_rec.arc_act_metric_used_by NOT IN
           ('CAMP','CSCH','EVEH','EVEO','DELV','FUND','FCST')
      THEN
         IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
            FND_MESSAGE.Set_Name ('OZF', 'OZF_METR_INVALID_USED_BY');
            FND_MSG_PUB.Add;
         END IF;

     x_return_status := FND_API.G_RET_STS_ERROR;
      RETURN;
      END IF;
   END IF;

 -----------------------------------------------------------------------
 --End of Comments                                                    --
 -----------------------------------------------------------------------
   ----------------------------------------------------------------------------------
   --When a Hierarchy and Node are specified then a check must be done to verify
   --that the node is unique in the set of result entries for this activity metric.
   ----------------------------------------------------------------------------------
   IF l_act_metric_fact_rec.hierarchy_id <> FND_API.G_MISS_NUM  THEN

       OPEN c_hierarchy_node_check(l_act_metric_fact_rec.hierarchy_id,
                                   l_act_metric_fact_rec.node_id,
                   l_act_metric_fact_rec.activity_metric_fact_id,
                   l_act_metric_fact_rec.activity_metric_id,
                   l_act_metric_fact_rec.formula_id);

       FETCH c_hierarchy_node_check INTO l_fact_exists;





       IF c_hierarchy_node_check%FOUND THEN
          CLOSE c_hierarchy_node_check;
          IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
             FND_MESSAGE.set_name('OZF', 'OZF_METR_FACT_DUP_NODE_ID');
             FND_MSG_PUB.add;
         RAISE FND_API.g_exc_error;
          END IF;
       ELSE
           CLOSE c_hierarchy_node_check;
       END IF;
   END IF;

EXCEPTION
   WHEN OTHERS THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Check_ActMetricFact_Items;


--
-- Start of comments.
--
-- NAME
--    Validate_ActMetFact_Rec
--
-- PURPOSE
--    Perform Record Level and Other business validations for metric facts.
--
-- NOTES
--
-- HISTORY
-- 24-Apr-2000 tdonohoe Created.
--
-- End of comments.

PROCEDURE Validate_ActMetFact_Rec(
   p_act_metric_fact_rec   IN  act_metric_fact_rec_type,
   p_complete_fact_rec     IN  act_metric_fact_rec_type,
   x_return_status         OUT NOCOPY VARCHAR2
)
IS

   l_act_metric_fact_rec   act_metric_fact_rec_type := p_act_metric_fact_rec;

   l_table_name                  VARCHAR2(30);
   l_pk_name                     VARCHAR2(30);
   l_pk_value                    VARCHAR2(30);
   l_pk_data_type                VARCHAR2(30);
   l_additional_where_clause     VARCHAR2(4000);  -- Used by Check_FK_Exists.

   l_return_status                  VARCHAR2(1);


BEGIN

   x_return_status := FND_API.g_ret_sts_success;

   IF l_act_metric_fact_rec.arc_act_metric_used_by <> FND_API.G_MISS_CHAR      THEN

      IF l_act_metric_fact_rec.act_metric_used_by_id = FND_API.G_MISS_NUM THEN
           l_act_metric_fact_rec.act_metric_used_by_id  := p_complete_fact_rec.act_metric_used_by_id ;
      END IF;

      IF l_act_metric_fact_rec.activity_metric_id = FND_API.G_MISS_NUM THEN
           l_act_metric_fact_rec.activity_metric_id  := p_complete_fact_rec.activity_metric_id ;
      END IF;

      -- first Check whether the Metric is attached to same usage or not
          l_table_name               := 'OZF_ACT_METRICS_ALL';
          l_pk_name                  := 'ACTIVITY_METRIC_ID';
          l_pk_value                 := l_act_metric_fact_rec.activity_metric_id;
          l_pk_data_type             := OZF_Utility_PVT.G_NUMBER;
          l_additional_where_clause  := ' arc_act_metric_used_by = '||''''||
                                   l_act_metric_fact_rec.arc_act_metric_used_by||'''' ;



      IF OZF_Utility_PVT.Check_FK_Exists (
             p_table_name            => l_table_name
            ,p_pk_name                    => l_pk_name
            ,p_pk_value                    => l_pk_value
            ,p_pk_data_type                => l_pk_data_type
            ,p_additional_where_clause      => l_additional_where_clause
         ) = FND_API.G_FALSE
      THEN

         IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
         THEN
             FND_MESSAGE.Set_Name('OZF', 'OZF_METR_INVALID_ACT_USAGE');
             FND_MSG_PUB.Add;
         END IF;

         x_return_status := FND_API.G_RET_STS_ERROR;

             RETURN;

      END IF;  -- Check_FK_Exists


      /*

      -- Get table_name and pk_name for the ARC qualifier.
      OZF_Utility_PVT.Get_Qual_Table_Name_And_PK (
         p_sys_qual                     => l_act_metric_fact_rec.arc_act_metric_used_by,
         x_return_status                => l_return_status,
         x_table_name                   => l_table_name,
         x_pk_name                      => l_pk_name
      );



      l_pk_value                 := l_act_metric_fact_rec.act_metric_used_by_id;
      l_pk_data_type             := OZF_Utility_PVT.G_NUMBER;
      l_additional_where_clause  := NULL;

      IF OZF_Utility_PVT.Check_FK_Exists (
             p_table_name                   => l_table_name
            ,p_pk_name                      => l_pk_name
            ,p_pk_value                     => l_pk_value
            ,p_pk_data_type                 => l_pk_data_type
            ,p_additional_where_clause      => NULL
         ) = FND_API.G_FALSE
      THEN
            IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
            FND_MESSAGE.Set_Name ('OZF', 'OZF_METR_INVALID_USED_BY');
            FND_MSG_PUB.Add;
            END IF;

            x_return_status := FND_API.G_RET_STS_ERROR;
          RETURN;
      END IF;
     */

   END IF;

EXCEPTION
   WHEN OTHERS THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;


END Validate_ActMetFact_Rec;


--
-- Start of comments.
--
-- NAME
--    Validate_ActMetFact_Items
--
-- PURPOSE
--    Perform All Item level validation for Activity metric facts.
--
-- NOTES
--
-- HISTORY
-- 24-Apr-2000 tdonohoe  Created.
--
-- End of comments.

PROCEDURE Validate_ActMetFact_Items (
   p_act_metric_fact_rec    IN  act_metric_fact_rec_type,
   p_validation_mode        IN  VARCHAR2 := JTF_PLSQL_API.g_create,
   x_return_status          OUT NOCOPY VARCHAR2
)
IS
BEGIN



   Check_Req_ActMetricFact_Items(
      p_act_metric_fact_rec  => p_act_metric_fact_rec,
      x_return_status        => x_return_status
   );
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;



   Check_ActMetricFact_Uk_Items(
      p_act_metric_fact_rec    => p_act_metric_fact_rec,
      p_validation_mode        => p_validation_mode,
      x_return_status          => x_return_status
   );

   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;



   Check_ActMetricFact_Items(
      p_act_metric_fact_rec   => p_act_metric_fact_rec,
      x_return_status         => x_return_status
   );

   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

END Validate_ActMetFact_Items;

-- Start of comments
-- NAME
--    Default_Formula
--
--
-- PURPOSE
--    Defaults the Activity Metric Formula.
--
-- NOTES
--
-- HISTORY
-- 31-May-2000	tdonohoe  Created.
--
-- End of comments

PROCEDURE Default_Formula(
   p_init_msg_list          IN  VARCHAR2 := FND_API.G_FALSE,
   p_formula_rec            IN  ozf_formula_rec_type,
   p_validation_mode        IN  VARCHAR2 ,
   x_complete_rec           OUT NOCOPY ozf_formula_rec_type,
   x_return_status 	    OUT NOCOPY VARCHAR2,
   x_msg_count              OUT NOCOPY NUMBER,
   x_msg_data               OUT NOCOPY VARCHAR2
)
IS

BEGIN
   --
   -- Initialize message list if p_init_msg_list is set to TRUE.
   --
   IF FND_API.To_Boolean (p_init_msg_list) THEN
      FND_MSG_PUB.Initialize;
   END IF;

   --
   -- Initialize API return status to success.
   --
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   x_complete_rec := p_formula_rec;

     -- Insert Mode
     IF ((p_validation_mode = JTF_PLSQL_API.g_create) OR (p_validation_mode = JTF_PLSQL_API.g_update)) THEN
            NULL;
     END IF;

END Default_Formula ;


-- Start of comments
-- NAME
--    Default_Formula_Entry
--
--
-- PURPOSE
--    Defaults the Activity Metric Formula Entry.
--
-- NOTES
--
-- HISTORY
-- 01-Jun-2000	tdonohoe  Created.
--
-- End of comments

PROCEDURE Default_Formula_Entry(
   p_init_msg_list          IN  VARCHAR2 := FND_API.G_FALSE,
   p_formula_entry_rec      IN  ozf_formula_entry_rec_type,
   p_validation_mode        IN  VARCHAR2 ,
   x_complete_entry_rec     OUT NOCOPY ozf_formula_entry_rec_type,
   x_return_status 	    OUT NOCOPY VARCHAR2,
   x_msg_count              OUT NOCOPY NUMBER,
   x_msg_data               OUT NOCOPY VARCHAR2
)
IS

BEGIN
   --
   -- Initialize message list if p_init_msg_list is set to TRUE.
   --
   IF FND_API.To_Boolean (p_init_msg_list) THEN
      FND_MSG_PUB.Initialize;
   END IF;

   --
   -- Initialize API return status to success.
   --
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   x_complete_entry_rec := p_formula_entry_rec;

     -- Insert Mode
     IF ((p_validation_mode = JTF_PLSQL_API.g_create) OR (p_validation_mode = JTF_PLSQL_API.g_update)) THEN

         NULL;
     END IF;

END Default_Formula_Entry ;



-- Start of comments.
--
-- NAME
--    Check_Req_Formula_Items
--
-- PURPOSE
--    Validate required activity metric formula items.
--
-- NOTES
--
-- HISTORY
-- 31-May-2000 tdonohoe  Created.
--
-- End of comments.

PROCEDURE Check_Req_Formula_Items (
   p_formula_rec  IN ozf_formula_rec_type,
   x_return_status        OUT NOCOPY VARCHAR2
)
IS
BEGIN
   -- Initialize return status to success.
   x_return_status := FND_API.G_RET_STS_SUCCESS;


   --ACTIVITY_METRIC_ID

   IF p_formula_rec.activity_metric_id IS NULL
   THEN
      -- missing required fields
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
      THEN -- MMSG
         FND_MESSAGE.Set_Name('OZF', 'OZF_FML_MISSING_ACT_METRIC_ID');
         FND_MSG_PUB.Add;
      END IF;

      x_return_status := FND_API.G_RET_STS_ERROR;

      -- If any error happens abort API.
      RETURN;
   END IF;

   --LEVEL_DEPTH

   IF p_formula_rec.level_depth IS NULL
   THEN
      -- missing required fields
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
      THEN -- MMSG
         FND_MESSAGE.Set_Name('OZF', 'OZF_FML_MISSING_LEVEL_DEPTH');
         FND_MSG_PUB.Add;
      END IF;

      x_return_status := FND_API.G_RET_STS_ERROR;

      -- If any error happens abort API.
      RETURN;
   END IF;


EXCEPTION
   WHEN OTHERS THEN
      RAISE;
END Check_Req_Formula_Items;


-- Start of comments.
--
-- NAME
--    Check_Req_Formula_Entry_Items
--
-- PURPOSE
--    Validate required activity metric formula entry items.
--
-- NOTES
--
-- HISTORY
-- 01-Jun-2000 tdonohoe  Created.
--
-- End of comments.

PROCEDURE Check_Req_Formula_Entry_Items (
   p_formula_entry_rec    IN ozf_formula_entry_rec_type,
   x_return_status        OUT NOCOPY VARCHAR2
)
IS
BEGIN
   -- Initialize return status to success.
   x_return_status := FND_API.G_RET_STS_SUCCESS;



   --FORMULA_ID

   IF p_formula_entry_rec.formula_id IS NULL
   THEN
      -- missing required fields
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
      THEN -- MMSG
         FND_MESSAGE.Set_Name('OZF', 'OZF_FML_MISSING_FORMULA_ID');
         FND_MSG_PUB.Add;
      END IF;

      x_return_status := FND_API.G_RET_STS_ERROR;

      -- If any error happens abort API.
      RETURN;
   END IF;

   --ORDER_NUMBER
   IF p_formula_entry_rec.order_number IS NULL
   THEN
      -- missing required fields
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
      THEN -- MMSG
         FND_MESSAGE.Set_Name('OZF', 'OZF_FML_MISSING_ORDER_NUM');
         FND_MSG_PUB.Add;
      END IF;

      x_return_status := FND_API.G_RET_STS_ERROR;

      -- If any error happens abort API.
      RETURN;
   END IF;

   -- FORMULA_ENTRY_TYPE
   IF p_formula_entry_rec.formula_entry_type IS NULL
   THEN
      -- missing required fields
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
      THEN -- MMSG
         FND_MESSAGE.Set_Name('OZF', 'OZF_FML_MISSING_ENT_TYPE');
         FND_MSG_PUB.Add;
      END IF;

      x_return_status := FND_API.G_RET_STS_ERROR;

      -- If any error happens abort API.
      RETURN;
   END IF;

      -- OBJECT_VERSION_NUMBER
   IF p_formula_entry_rec.object_version_number IS NULL
   THEN
      -- missing required fields
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
      THEN -- MMSG
         FND_MESSAGE.Set_Name('OZF', 'OZF_FML_MISSING_OBJ_NUM');
         FND_MSG_PUB.Add;
      END IF;

      x_return_status := FND_API.G_RET_STS_ERROR;

      -- If any error happens abort API.
      RETURN;
   END IF;

EXCEPTION
   WHEN OTHERS THEN
      RAISE;
END Check_Req_Formula_Entry_Items;



--
-- Start of comments.
--
-- NAME
--    Check_Formula_UK_Items
--
-- PURPOSE
--    Perform Uniqueness check for Activity metric formulas.
--
-- NOTES
--
-- HISTORY
-- 31-May-2000	tdonohoe Created.
--
-- End of comments.


PROCEDURE Check_Formula_UK_Items(
   p_formula_rec    IN  ozf_formula_rec_type,
   p_validation_mode 	 IN  VARCHAR2 := JTF_PLSQL_API.g_create,
   x_return_status   	 OUT NOCOPY VARCHAR2
)
IS

   l_formula_count number;

   CURSOR c_formula_type IS
   SELECT COUNT(*)
   FROM   ozf_act_metric_formulas
   WHERE  formula_type       = p_formula_rec.formula_type
   AND    activity_metric_id = p_formula_rec.activity_metric_id
   AND    level_depth        = p_formula_rec.level_depth
   AND    formula_id        <> p_formula_rec.formula_id;


BEGIN

   x_return_status := FND_API.g_ret_sts_success;

      OPEN   c_formula_type;
      FETCH  c_formula_type INTO l_formula_count;
      CLOSE  c_formula_type;

      IF (l_formula_count > 0) THEN
            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN

               FND_MESSAGE.set_name('OZF', 'OZF_FML_MAX_LEVEL');
               FND_MSG_PUB.add;
            END IF;
            x_return_status := FND_API.g_ret_sts_error;
            RETURN;
      END IF;

END Check_Formula_Uk_Items;

--
-- Start of comments.
--
-- NAME
--    Check_Formula_Entry_UK_Items
--
-- PURPOSE
--    Perform Uniqueness check for Activity metric formula entries.
--
-- NOTES
--
-- HISTORY
-- 01-Jun-2000	tdonohoe Created.
--
-- End of comments.
PROCEDURE Check_Formula_Entry_UK_Items(
   p_formula_entry_rec   IN  ozf_formula_entry_rec_type,
   p_validation_mode 	 IN  VARCHAR2 := JTF_PLSQL_API.g_create,
   x_return_status   	 OUT NOCOPY VARCHAR2
)
IS

   l_formula_entry_count number;

   CURSOR c_formula_entry_type IS
   SELECT COUNT(*)
   FROM   ozf_act_metric_form_ent
   WHERE  formula_id         =  p_formula_entry_rec.formula_id
   AND    order_number       =  p_formula_entry_rec.order_number
   AND    formula_entry_id   <> p_formula_entry_rec.formula_entry_id;


BEGIN

   x_return_status := FND_API.g_ret_sts_success;

 /*
      OPEN   c_formula_entry_type;
      FETCH  c_formula_entry_type INTO l_formula_entry_count;
      CLOSE  c_formula_entry_type;

      IF (l_formula_entry_count > 0) THEN
            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN

               FND_MESSAGE.set_name('OZF', 'OZF_FML_ENT_DUP_ORDNUM');
               FND_MSG_PUB.add;
            END IF;
            x_return_status := FND_API.g_ret_sts_error;
            RETURN;
      END IF;
  */
END Check_Formula_Entry_Uk_Items;




--
-- Start of comments.
--
-- NAME
--    Check_Formula_Items
--
-- PURPOSE
--    Perform item level validation for activity metric formulas.
--
-- NOTES
--
-- HISTORY
-- 31-May-2000 tdonohoe Created.
--
-- End of comments.

PROCEDURE Check_Formula_Items (
   p_formula_rec         IN  ozf_formula_rec_type,
   x_return_status       OUT NOCOPY VARCHAR2
)
IS
   l_item_name                   VARCHAR2(30);  -- Used to standardize error messages.
   l_formula_rec                 ozf_formula_rec_type := p_formula_rec;
   l_return_status               VARCHAR2(1);

BEGIN
   -- Initialize return status to success.
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   --FORMULA_TYPE

   IF l_formula_rec.formula_type <> FND_API.G_MISS_CHAR THEN


      IF ozf_utility_pvt.check_lookup_exists(p_lookup_type => 'OZF_FORMULA_TYPE',
                                             p_lookup_code => l_formula_rec.formula_type) = FND_API.g_false THEN

          IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
                 FND_MESSAGE.set_name('OZF', 'OZF_FML_INVALID_TYPE');
                 FND_MSG_PUB.add;
          END IF;

          x_return_status := FND_API.g_ret_sts_error;
          RETURN;
       END IF;
   END IF;

EXCEPTION
   WHEN OTHERS THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Check_Formula_Items;


--
-- Start of comments.
--
-- NAME
--    Check_Formula_Entry_Items
--
-- PURPOSE
--    Perform item level validation for activity metric formula entries.
--
-- NOTES
--
-- HISTORY
-- 01-Jun-2000 tdonohoe Created.
--
-- End of comments.

PROCEDURE Check_Formula_Entry_Items (
   p_formula_entry_rec   IN  ozf_formula_entry_rec_type,
   x_return_status       OUT NOCOPY VARCHAR2
)
IS
   l_item_name                   VARCHAR2(30);  -- Used to standardize error messages.
   l_formula_entry_rec           ozf_formula_entry_rec_type := p_formula_entry_rec;
   l_return_status               VARCHAR2(1);


BEGIN

   -- Initialize return status to success.
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   --FORMULA_ENTRY_TYPE

   IF l_formula_entry_rec.formula_entry_type <> FND_API.G_MISS_CHAR THEN


      IF ozf_utility_pvt.check_lookup_exists(p_lookup_type => 'OZF_FORMULA_ENT_TYPE',
                                             p_lookup_code => l_formula_entry_rec.formula_entry_type) = FND_API.g_false THEN

          IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
                 FND_MESSAGE.set_name('OZF', 'OZF_FML_ENT_INVALID_TYPE');
                 FND_MSG_PUB.add;
          END IF;

          x_return_status := FND_API.g_ret_sts_error;
          RETURN;
       END IF;
   END IF;

   --OZF_FORMULA_OPERATORS

   IF l_formula_entry_rec.formula_entry_operator IS NOT NULL AND l_formula_entry_rec.formula_entry_operator <> FND_API.G_MISS_CHAR THEN


      IF ozf_utility_pvt.check_lookup_exists(p_lookup_type => 'OZF_FORMULA_OPERATOR',
                                             p_lookup_code => l_formula_entry_rec.formula_entry_operator) = FND_API.g_false THEN

          IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
                 FND_MESSAGE.set_name('OZF', 'OZF_FML_ENT_INVALID_OP');
                 FND_MSG_PUB.add;
          END IF;

          x_return_status := FND_API.g_ret_sts_error;
          RETURN;
       END IF;
   END IF;

EXCEPTION
   WHEN OTHERS THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Check_Formula_Entry_Items;



--
-- Start of comments.
--
-- NAME
--    Validate_Formula_Rec
--
-- PURPOSE
--    Perform Record Level and Other business validations for activity metric formula table.
--
-- NOTES
--
-- HISTORY
-- 31-May-2000 tdonohoe Created.
--
-- End of comments.

PROCEDURE Validate_Formula_rec(
   p_formula_rec           IN  ozf_formula_rec_type,
   p_complete_formula_rec  IN  ozf_formula_rec_type,
   x_return_status         OUT NOCOPY VARCHAR2
)
IS

   l_formula_rec                 ozf_formula_rec_type := p_formula_rec;
   l_return_status 				 VARCHAR2(1);


BEGIN

   x_return_status := FND_API.g_ret_sts_success;

   IF (l_formula_rec.activity_metric_id <> FND_API.G_MISS_NUM) THEN

      IF ozf_utility_pvt.Check_FK_Exists (
             p_table_name                   => 'OZF_ACT_METRICS_ALL'
            ,p_pk_name                      => 'ACTIVITY_METRIC_ID'
            ,p_pk_value                     => l_formula_rec.activity_metric_id
            ,p_pk_data_type                 => NULL
            ,p_additional_where_clause      => NULL
         ) = FND_API.G_FALSE
      THEN
            IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
            FND_MESSAGE.Set_Name ('OZF', 'OZF_FML_INVALID_ACT_METRIC');
            FND_MSG_PUB.Add;
            END IF;

            x_return_status := FND_API.G_RET_STS_ERROR;
            RETURN;
      END IF;
    END IF;

EXCEPTION
   WHEN OTHERS THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Validate_Formula_rec;


--
-- Start of comments.
--
-- NAME
--    Validate_Form_ent_rec
--
-- PURPOSE
--    Perform Record Level and Other business validations for activity metric formula table.
--
-- NOTES
--
-- HISTORY
-- 01-Jun-2000 tdonohoe Created.
--
-- End of comments.

PROCEDURE Validate_Form_ent_rec(
   p_formula_entry_rec           IN  ozf_formula_entry_rec_type,
   p_complete_formula_entry_rec  IN  ozf_formula_entry_rec_type,
   x_return_status               OUT NOCOPY VARCHAR2
)
IS

   l_formula_entry_rec           ozf_formula_entry_rec_type := p_formula_entry_rec;
   l_return_status 		 VARCHAR2(1);


BEGIN

   x_return_status := FND_API.g_ret_sts_success;

   IF (l_formula_entry_rec.formula_id <> FND_API.G_MISS_NUM) THEN

      IF ozf_utility_pvt.Check_FK_Exists (
             p_table_name                   => 'OZF_ACT_METRIC_FORMULAS'
            ,p_pk_name                      => 'FORMULA_ID'
            ,p_pk_value                     => l_formula_entry_rec.formula_id
            ,p_pk_data_type                 => NULL
            ,p_additional_where_clause      => NULL
         ) = FND_API.G_FALSE
      THEN
            IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
            FND_MESSAGE.Set_Name ('OZF', 'OZF_FML_INVALID_FORMULA_ID');
            FND_MSG_PUB.Add;
            END IF;

            x_return_status := FND_API.G_RET_STS_ERROR;
            RETURN;
      END IF;
    END IF;

EXCEPTION
   WHEN OTHERS THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Validate_Form_ent_rec;


--
-- Start of comments.
--
-- NAME
--    Validate_Formula_Items
--
-- PURPOSE
--    Perform All Item level validation for Activity metric formulas.
--
-- NOTES
--
-- HISTORY
-- 31-May-2000 tdonohoe  Created.
--
-- End of comments.

PROCEDURE Validate_Formula_Items (
   p_formula_rec            IN  ozf_formula_rec_type,
   p_validation_mode        IN  VARCHAR2 := JTF_PLSQL_API.g_create,
   x_return_status          OUT NOCOPY VARCHAR2
)
IS
BEGIN



   Check_Req_Formula_Items(
      p_formula_rec      => p_formula_rec,
      x_return_status    => x_return_status
   );
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;


   Check_Formula_Uk_Items(
      p_formula_rec            => p_formula_rec,
      p_validation_mode        => p_validation_mode,
      x_return_status          => x_return_status
   );

   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;


   Check_Formula_Items(
      p_formula_rec           => p_formula_rec,
      x_return_status         => x_return_status
   );

   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

END Validate_Formula_Items;


--
-- Start of comments.
--
-- NAME
--    Validate_Form_Ent_Items
--
-- PURPOSE
--    Perform All Item level validation for Activity metric formula entries.
--
-- NOTES
--
-- HISTORY
-- 01-Jun-2000 tdonohoe  Created.
--
-- End of comments.

PROCEDURE Validate_Form_Ent_Items (
   p_formula_entry_rec      IN  ozf_formula_entry_rec_type,
   p_validation_mode        IN  VARCHAR2 := JTF_PLSQL_API.g_create,
   x_return_status          OUT NOCOPY VARCHAR2
)
IS
BEGIN



   Check_Req_Formula_Entry_Items(
      p_formula_entry_rec => p_formula_entry_rec,
      x_return_status     => x_return_status
   );
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;


   Check_Formula_Entry_Uk_Items(
      p_formula_entry_rec      => p_formula_entry_rec,
      p_validation_mode        => p_validation_mode,
      x_return_status          => x_return_status
   );

   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;


   Check_Formula_Entry_Items(
      p_formula_entry_rec     => p_formula_entry_rec,
      x_return_status         => x_return_status
   );

   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

END Validate_Form_Ent_Items;


-- Start of comments
-- NAME
--   Validate_Formula
--
-- PURPOSE
--   Validation API for Activity metric formula table.
--

-- NOTES
--
-- HISTORY
-- 31-May-2000 tdonohoe  Created.

--
-- End of comments
PROCEDURE Validate_Formula (
   p_api_version                IN  NUMBER,
   p_init_msg_list              IN  VARCHAR2 := FND_API.G_FALSE,
   p_validation_level           IN  NUMBER   := FND_API.G_Valid_Level_Full,

   x_return_status              OUT NOCOPY VARCHAR2,
   x_msg_count                  OUT NOCOPY NUMBER,
   x_msg_data                   OUT NOCOPY VARCHAR2,

   p_formula_rec                IN  ozf_formula_rec_type
)
IS
   L_API_VERSION               CONSTANT NUMBER := 1.0;
   L_API_NAME                  CONSTANT VARCHAR2(30) := 'VALIDATE_FORMULA';
   L_FULL_NAME   	       CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;


   l_return_status             VARCHAR2(1);

BEGIN
   --
   -- Output debug message.
   --
   IF G_DEBUG THEN
      ozf_utility_pvt.debug_message(l_full_name||': start');
   END IF;

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

   IF G_DEBUG THEN
      ozf_utility_pvt.debug_message(l_full_name||': Validate items');
   END IF;

   -- Validate required items in the record.
   IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN

       Validate_Formula_Items(
         p_formula_rec             => p_formula_rec,
         p_validation_mode 	   => JTF_PLSQL_API.g_create,
         x_return_status   	   => l_return_status
      );

	  -- If any errors happen abort API.
	  IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	  ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
		  RAISE FND_API.G_EXC_ERROR;
	  END IF;
   END IF;

  IF G_DEBUG THEN
     ozf_utility_pvt.debug_message(l_full_name||': check record');
  END IF;

  IF p_validation_level >= JTF_PLSQL_API.g_valid_level_record THEN
      Validate_Formula_Rec(
         p_formula_rec           => p_formula_rec,
         p_complete_formula_rec  => NULL,
         x_return_status  	 => l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
             IF G_DEBUG THEN
                ozf_utility_pvt.debug_message(l_full_name||': error in  check record');
             END IF;
         RAISE FND_API.g_exc_unexpected_error;
      ELSIF l_return_status = FND_API.g_ret_sts_error THEN
          IF G_DEBUG THEN
             ozf_utility_pvt.debug_message(l_full_name||': error in  check record');
          END IF;
         RAISE FND_API.g_exc_error;
      END IF;
   END IF;

   IF G_DEBUG THEN
      ozf_utility_pvt.debug_message(l_full_name||': after check record');
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

   IF G_DEBUG THEN
      ozf_utility_pvt.debug_message(l_full_name ||': end');
   END IF;


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
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data
      );
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, L_API_NAME);
      END IF;
      FND_MSG_PUB.Count_And_Get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data
      );
END Validate_Formula;

-- Start of comments
-- NAME
--   Validate_Formula_Entry
--
-- PURPOSE
--   Validation API for Activity metric formula entry table.
--

-- NOTES
--
-- HISTORY
-- 01-Jun-2000 tdonohoe  Created.

--
-- End of comments
PROCEDURE Validate_Formula_Entry (
   p_api_version                IN  NUMBER,
   p_init_msg_list              IN  VARCHAR2 := FND_API.G_FALSE,
   p_validation_level           IN  NUMBER   := FND_API.G_Valid_Level_Full,

   x_return_status              OUT NOCOPY VARCHAR2,
   x_msg_count                  OUT NOCOPY NUMBER,
   x_msg_data                   OUT NOCOPY VARCHAR2,

   p_formula_entry_rec          IN  ozf_formula_entry_rec_type
)
IS
   L_API_VERSION               CONSTANT NUMBER := 1.0;
   L_API_NAME                  CONSTANT VARCHAR2(30) := 'VALIDATE_FORMULA_ENTRY';
   L_FULL_NAME   	       CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;


   l_return_status             VARCHAR2(1);

BEGIN
   --
   -- Output debug message.
   --
   IF G_DEBUG THEN
      ozf_utility_pvt.debug_message(l_full_name||': start');
   END IF;

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

   IF G_DEBUG THEN
      ozf_utility_pvt.debug_message(l_full_name||': Validate items');
   END IF;

   -- Validate required items in the record.
   IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN

       Validate_Form_Ent_Items(
         p_formula_entry_rec       => p_formula_entry_rec,
         p_validation_mode 	   => JTF_PLSQL_API.g_create,
         x_return_status   	   => l_return_status
      );

	  -- If any errors happen abort API.
	  IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	  ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
	     RAISE FND_API.G_EXC_ERROR;
	  END IF;
   END IF;

  IF G_DEBUG THEN
     ozf_utility_pvt.debug_message(l_full_name||': check record');
  END IF;

  IF p_validation_level >= JTF_PLSQL_API.g_valid_level_record THEN
      Validate_Form_Ent_Rec(
         p_formula_entry_rec           => p_formula_entry_rec,
         p_complete_formula_entry_rec  => NULL,
         x_return_status  	       => l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
             IF G_DEBUG THEN
                ozf_utility_pvt.debug_message(l_full_name||': error in  check record');
             END IF;
         RAISE FND_API.g_exc_unexpected_error;
      ELSIF l_return_status = FND_API.g_ret_sts_error THEN
          IF G_DEBUG THEN
             ozf_utility_pvt.debug_message(l_full_name||': error in  check record');
          END IF;
         RAISE FND_API.g_exc_error;
      END IF;
   END IF;

   IF G_DEBUG THEN
      ozf_utility_pvt.debug_message(l_full_name||': after check record');
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

   IF G_DEBUG THEN
      ozf_utility_pvt.debug_message(l_full_name ||': end');
   END IF;


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
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data
      );
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, L_API_NAME);
      END IF;
      FND_MSG_PUB.Count_And_Get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data
      );
END Validate_Formula_Entry;



-------------------------------------------------------------------------------
-- Start of comments
-- NAME
--    Create_Formula
--
--
-- PURPOSE
--    Creates an Activity Metric Formula.

--
-- NOTES
--
-- HISTORY
-- 31-May-2000  tdonohoe@us    Created.
--
-- End of comments
-------------------------------------------------------------------------------
PROCEDURE Create_Formula (
   p_api_version                IN 	NUMBER,
   p_init_msg_list              IN  VARCHAR2 := FND_API.G_FALSE,
   p_commit                     IN  VARCHAR2 := FND_API.G_FALSE,
   p_validation_level           IN  NUMBER   := FND_API.G_Valid_Level_Full,

   x_return_status              OUT NOCOPY VARCHAR2,
   x_msg_count                  OUT NOCOPY NUMBER,
   x_msg_data                   OUT NOCOPY VARCHAR2,

   p_formula_rec                IN  ozf_formula_rec_type,
   x_formula_id                 OUT NOCOPY NUMBER
) IS

   --
   -- Standard API information constants.
   --
   L_API_VERSION                  CONSTANT NUMBER := 1.0;
   L_API_NAME                     CONSTANT VARCHAR2(30) := 'CREATE_FORMULA';
   L_FULL_NAME   	          CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| L_API_NAME;


   l_return_status                VARCHAR2(1); -- Return value from procedures.
   l_formula_rec                  ozf_formula_rec_type := p_formula_rec;
   l_formula_count                NUMBER ;

   CURSOR c_formula_count(l_formula_id IN NUMBER) IS
   SELECT count(*)
   FROM   ozf_act_metric_formulas
   WHERE  formula_id = l_formula_id;

   CURSOR c_formula_id IS
   SELECT ozf_act_metric_formulas_s.NEXTVAL
   FROM   dual;

BEGIN

   --
   -- Initialize savepoint.
   --

   SAVEPOINT Create_Formula_Pvt;

   IF G_DEBUG THEN
      ozf_utility_pvt.Debug_Message(l_full_name||': start');
   END IF;

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

   Default_Formula
       ( p_init_msg_list        => p_init_msg_list,
   	 p_formula_rec          => p_formula_rec,
   	 p_validation_mode      => JTF_PLSQL_API.g_create,
   	 x_complete_rec         => l_formula_rec,
   	 x_return_status        => l_return_status,
   	 x_msg_count            => x_msg_count,
   	 x_msg_data             => x_msg_data  ) ;



   -- If any errors happen abort API.
   IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
   ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;



   --
   -- Validate the record before inserting.
   --


   IF l_formula_rec.formula_id IS NULL THEN
   	  LOOP
   	  --
   	  -- Set the value for the PK.
   	  	 OPEN c_formula_id;
   		 FETCH c_formula_id INTO l_formula_rec.formula_id;
   		 CLOSE c_formula_id;

		 OPEN  c_formula_count(l_formula_rec.formula_id);
		 FETCH c_formula_count INTO l_formula_count ;
		 CLOSE c_formula_count ;

		 EXIT WHEN l_formula_count = 0 ;
	  END LOOP ;
   END IF;



   Validate_Formula (
      p_api_version               => l_api_version,
      p_init_msg_list             => p_init_msg_list,
      p_validation_level          => p_validation_level,
      x_msg_count                 => x_msg_count,
      x_msg_data                  => x_msg_data,
      x_return_status             => l_return_status,
      p_formula_rec               => l_formula_rec
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
   IF G_DEBUG THEN
      ozf_utility_pvt.debug_message(l_full_name ||': insert');
   END IF;



   --
   -- Insert into the base table.
   --
   INSERT INTO OZF_ACT_METRIC_FORMULAS
   ( formula_id
    ,activity_metric_id
    ,level_depth
    ,parent_formula_id
    ,last_update_date
    ,last_updated_by
    ,creation_date
    ,created_by
    ,last_update_login
    ,object_version_number
    ,formula_type
    )
    VALUES
    (l_formula_rec.formula_id
    ,l_formula_rec.activity_metric_id
    ,l_formula_rec.level_depth
    ,l_formula_rec.parent_formula_id
    ,SYSDATE
    ,FND_GLOBAL.User_ID
    ,SYSDATE
    ,FND_GLOBAL.User_ID
    ,FND_GLOBAL.Conc_Login_ID
    ,1--object version number
    ,l_formula_rec.formula_type
    );


   -- If any errors happen abort API.
   IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
   ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;


   -- finish

   --
   -- Set OUT value.
   --
   x_formula_id := l_formula_rec.formula_id;

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

   IF G_DEBUG THEN
      ozf_utility_pvt.debug_message(l_full_name ||': end Success');
   END IF;




EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN


      ROLLBACK TO Create_Formula_Pvt;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data
      );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN



      ROLLBACK TO Create_Formula_Pvt;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data
      );
   WHEN OTHERS THEN


      ROLLBACK TO Create_Formula_Pvt;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, L_API_NAME);
      END IF;
      FND_MSG_PUB.Count_And_Get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data
      );


END Create_Formula;


-------------------------------------------------------------------------------
-- Start of comments
-- NAME
--    Create_Formula_Entry
--
--
-- PURPOSE
--    Creates an Activity Metric Formula Entry.

--
-- NOTES
--
-- HISTORY
-- 31-May-2000  tdonohoe@us    Created.
--
-- End of comments
-------------------------------------------------------------------------------
PROCEDURE Create_Formula_Entry (
   p_api_version                IN 	NUMBER,
   p_init_msg_list              IN  VARCHAR2 := FND_API.G_FALSE,
   p_commit                     IN  VARCHAR2 := FND_API.G_FALSE,
   p_validation_level           IN  NUMBER   := FND_API.G_Valid_Level_Full,

   x_return_status              OUT NOCOPY VARCHAR2,
   x_msg_count                  OUT NOCOPY NUMBER,
   x_msg_data                   OUT NOCOPY VARCHAR2,

   p_formula_entry_rec          IN  ozf_formula_entry_rec_type,
   x_formula_entry_id           OUT NOCOPY NUMBER
) IS

   --
   -- Standard API information constants.
   --
   L_API_VERSION                  CONSTANT NUMBER := 1.0;
   L_API_NAME                     CONSTANT VARCHAR2(30) := 'CREATE_FORMULA_ENTRY';
   L_FULL_NAME   	          CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| L_API_NAME;


   l_return_status                VARCHAR2(1); -- Return value from procedures.
   l_formula_entry_rec            ozf_formula_entry_rec_type := p_formula_entry_rec;
   l_formula_entry_count          NUMBER ;

   CURSOR c_formula_entry_count(l_formula_entry_id IN NUMBER) IS
   SELECT count(*)
   FROM   ozf_act_metric_form_ent
   WHERE  formula_entry_id = l_formula_entry_id;

   CURSOR c_formula_entry_id IS
   SELECT ozf_act_metric_formula_ent_s.NEXTVAL
   FROM   dual;

BEGIN

   --
   -- Initialize savepoint.
   --

   SAVEPOINT Create_Formula_Entry_Pvt;

   IF G_DEBUG THEN
      ozf_utility_pvt.Debug_Message(l_full_name||': start');
   END IF;

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

   Default_Formula_Entry
       ( p_init_msg_list        => p_init_msg_list,
   	 p_formula_entry_rec    => p_formula_entry_rec,
   	 p_validation_mode      => JTF_PLSQL_API.g_create,
   	 x_complete_entry_rec   => l_formula_entry_rec,
   	 x_return_status        => l_return_status,
   	 x_msg_count            => x_msg_count,
   	 x_msg_data             => x_msg_data  ) ;



   -- If any errors happen abort API.
   IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
   ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;



   --
   -- Validate the record before inserting.
   --


   IF l_formula_entry_rec.formula_entry_id IS NULL THEN
   	  LOOP
   	  --
   	  -- Set the value for the PK.
   	  	 OPEN  c_formula_entry_id;
   		 FETCH c_formula_entry_id INTO l_formula_entry_rec.formula_entry_id;
   		 CLOSE c_formula_entry_id;

		 OPEN  c_formula_entry_count(l_formula_entry_rec.formula_entry_id);
		 FETCH c_formula_entry_count INTO l_formula_entry_count ;
		 CLOSE c_formula_entry_count ;

		 EXIT WHEN l_formula_entry_count = 0 ;
	  END LOOP ;
   END IF;



   Validate_Formula_Entry (
      p_api_version               => l_api_version,
      p_init_msg_list             => p_init_msg_list,
      p_validation_level          => p_validation_level,
      x_msg_count                 => x_msg_count,
      x_msg_data                  => x_msg_data,
      x_return_status             => l_return_status,
      p_formula_entry_rec         => l_formula_entry_rec
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
   IF G_DEBUG THEN
      ozf_utility_pvt.debug_message(l_full_name ||': insert');
   END IF;



   --
   -- Insert into the base table.
   --
   INSERT INTO OZF_ACT_METRIC_FORM_ENT
   ( formula_entry_id
    ,formula_id
    ,order_number
    ,formula_entry_type
    ,formula_entry_value
    ,metric_column_value
    ,formula_entry_operator
    ,last_update_date
    ,last_updated_by
    ,creation_date
    ,created_by
    ,last_update_login
    ,object_version_number
   )
   VALUES
   ( l_formula_entry_rec.formula_entry_id
    ,l_formula_entry_rec.formula_id
    ,l_formula_entry_rec.order_number
    ,l_formula_entry_rec.formula_entry_type
    ,l_formula_entry_rec.formula_entry_value
    ,l_formula_entry_rec.metric_column_value
    ,l_formula_entry_rec.formula_entry_operator
    ,SYSDATE
    ,FND_GLOBAL.User_ID
    ,SYSDATE
    ,FND_GLOBAL.User_ID
    ,FND_GLOBAL.User_ID
    ,1--OBJECT_VERSION_NUMBER
   );


   -- If any errors happen abort API.
   IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
   ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;


   -- finish

   --
   -- Set OUT value.
   --
   x_formula_entry_id := l_formula_entry_rec.formula_entry_id;

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

   IF G_DEBUG THEN
      ozf_utility_pvt.debug_message(l_full_name ||': end Success');
   END IF;




EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN


      ROLLBACK TO Create_Formula_Entry_Pvt;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data
      );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN



      ROLLBACK TO Create_Formula_Entry_Pvt;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data
      );
   WHEN OTHERS THEN


      ROLLBACK TO Create_Formula_Entry_Pvt;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, L_API_NAME);
      END IF;
      FND_MSG_PUB.Count_And_Get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data
      );


END Create_Formula_Entry;


-- Start of comments
-- NAME
--    Delete_Formula
--
-- PURPOSE
--    Deletes an entry in the ozf_act_metrics_formulas table.
--
-- NOTES
--
-- HISTORY
-- 24-Apr-2000 tdonohoe  Created.
--
-- End of comments

PROCEDURE Delete_Formula (
   p_api_version              IN  NUMBER,
   p_init_msg_list            IN  VARCHAR2 := FND_API.G_FALSE,
   p_commit                   IN  VARCHAR2 := FND_API.G_FALSE,

   x_return_status            OUT NOCOPY VARCHAR2,
   x_msg_count                OUT NOCOPY NUMBER,
   x_msg_data                 OUT NOCOPY VARCHAR2,

   p_formula_id              IN  NUMBER,
   p_object_version_number    IN  NUMBER
)
IS
   L_API_VERSION              CONSTANT NUMBER := 1.0;
   L_API_NAME                 CONSTANT VARCHAR2(30) := 'DELETE_FORMULA';
   L_FULL_NAME   	      CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

   l_return_status            VARCHAR2(1);

BEGIN
   --
   -- Initialize savepoint.
   --
   SAVEPOINT Delete_Formula_pvt;

   --
   -- Output debug message.
   --
   IF G_DEBUG THEN
      ozf_utility_pvt.debug_message(l_full_name||': start');
   END IF;

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

      -- Debug message.
   	  IF G_DEBUG THEN
   	     ozf_utility_pvt.debug_message(l_full_name ||': delete with Validation');

            ozf_utility_pvt.debug_message('formula id '||to_char(p_formula_id));

	    ozf_utility_pvt.debug_message('object version number '||to_char(p_object_version_number));
	 END IF;

         DELETE
	 FROM  ozf_act_metric_formulas
         WHERE formula_id = p_formula_id
	 AND   object_version_number = p_object_version_number;

         IF (SQL%NOTFOUND) THEN
	 IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN

		FND_MESSAGE.set_name('OZF', 'OZF_API_RECORD_NOT_FOUND');
         	FND_MSG_PUB.add;
      	 RAISE FND_API.g_exc_error;
      	 END IF;
	 END IF;

         DELETE
	 FROM  ozf_act_metric_form_ent
         WHERE formula_id = p_formula_id;

   --
   -- End API Body.
   --

   IF FND_API.To_Boolean (p_commit) THEN
      COMMIT WORK;
   END IF;

   --
   -- Debug message.
   --
   	  IF G_DEBUG THEN
   	     ozf_utility_pvt.debug_message(l_full_name ||': End');
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

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Delete_Formula_pvt;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data
      );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Delete_Formula_pvt;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data
      );
   WHEN OTHERS THEN
      ROLLBACK TO Delete_Formula_pvt;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, L_API_NAME);
      END IF;
      FND_MSG_PUB.Count_And_Get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data
      );
END Delete_Formula;

END Ozf_Actmetricfact_Pvt;

/
