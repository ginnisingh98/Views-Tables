--------------------------------------------------------
--  DDL for Package Body AMS_ACTMETRICFACT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_ACTMETRICFACT_PVT" AS
/* $Header: amsvamfb.pls 115.25 2002/11/16 01:09:36 mgudivak ship $ */

---------------------------------------------------------------------------------------------------
--
-- NAME
--    Ams_Actmetricfact_Pvt
--
-- HISTORY
-- 20-Jun-1999 tdonohoe Created  package.
-- 28-Jun 2000 tdonohoe Modified Check_ActMetricFact_Items to allow the same node to appear on a
--                      hierarchy combined with a unique formula_id.
-- 31-Jul-2000 tdonohoe comment out code to fix bug 1362107.
-- 03-Apr-2001 yzhao    add validate_fund_facts
--------------------------------------------------------------------------------------------------

--
-- Global variables and constants.

G_PKG_NAME           CONSTANT VARCHAR2(30) := 'Ams_Actmetricfact_Pvt'; -- Name of the current package.
G_DEBUG_FLAG          VARCHAR2(1)  := 'N';


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

AMS_DEBUG_HIGH_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

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
   x_fact_rec.activity_metric_fact_id    := fnd_api.g_miss_num;
   x_fact_rec.last_update_date           := fnd_api.g_miss_date;
   x_fact_rec.last_updated_by            := fnd_api.g_miss_num;
   x_fact_rec.creation_date              := fnd_api.g_miss_date;
   x_fact_rec.created_by                 := fnd_api.g_miss_num;
   x_fact_rec.last_update_login          := fnd_api.g_miss_num;
   x_fact_rec.object_version_number      := fnd_api.g_miss_num;
   x_fact_rec.act_metric_used_by_id      := fnd_api.g_miss_num;
   x_fact_rec.arc_act_metric_used_by     := fnd_api.g_miss_char;
   x_fact_rec.value_type                 := fnd_api.g_miss_char;
   x_fact_rec.activity_metric_id         := fnd_api.g_miss_num;
   x_fact_rec.activity_geo_area_id       := fnd_api.g_miss_num;
   x_fact_rec.activity_product_id        := fnd_api.g_miss_num;
   x_fact_rec.transaction_currency_code  := fnd_api.g_miss_char;
   x_fact_rec.trans_forecasted_value     := fnd_api.g_miss_num;
   x_fact_rec.base_quantity              := fnd_api.g_miss_num;
   x_fact_rec.functional_currency_code   := fnd_api.g_miss_char;
   x_fact_rec.func_forecasted_value      := fnd_api.g_miss_num;
   x_fact_rec.org_id                     := fnd_api.g_miss_num;
   x_fact_rec.de_metric_id               := fnd_api.g_miss_num;
   x_fact_rec.de_geographic_area_id      := fnd_api.g_miss_num;
   x_fact_rec.de_geographic_area_type    := fnd_api.g_miss_char;
   x_fact_rec.de_inventory_item_id       := fnd_api.g_miss_num;
   x_fact_rec.de_inventory_item_org_id   := fnd_api.g_miss_num;
   x_fact_rec.time_id1                   := fnd_api.g_miss_num;
   x_fact_rec.time_id2                   := fnd_api.g_miss_num;
   x_fact_rec.time_id3                   := fnd_api.g_miss_num;
   x_fact_rec.time_id4                   := fnd_api.g_miss_num;
   x_fact_rec.time_id5                   := fnd_api.g_miss_num;
   x_fact_rec.time_id6                   := fnd_api.g_miss_num;
   x_fact_rec.time_id7                   := fnd_api.g_miss_num;
   x_fact_rec.time_id8                   := fnd_api.g_miss_num;
   x_fact_rec.time_id9                   := fnd_api.g_miss_num;
   x_fact_rec.time_id10                  := fnd_api.g_miss_num;
   x_fact_rec.time_id11                  := fnd_api.g_miss_num;
   x_fact_rec.time_id12                  := fnd_api.g_miss_num;
   x_fact_rec.time_id13                  := fnd_api.g_miss_num;
   x_fact_rec.time_id14                  := fnd_api.g_miss_num;
   x_fact_rec.time_id15                  := fnd_api.g_miss_num;
   x_fact_rec.time_id16                  := fnd_api.g_miss_num;
   x_fact_rec.time_id17                  := fnd_api.g_miss_num;
   x_fact_rec.time_id18                  := fnd_api.g_miss_num;
   x_fact_rec.time_id19                  := fnd_api.g_miss_num;
   x_fact_rec.time_id20                  := fnd_api.g_miss_num;
   x_fact_rec.time_id21                  := fnd_api.g_miss_num;
   x_fact_rec.time_id22                  := fnd_api.g_miss_num;
   x_fact_rec.time_id23                  := fnd_api.g_miss_num;
   x_fact_rec.time_id24                  := fnd_api.g_miss_num;
   x_fact_rec.time_id25                  := fnd_api.g_miss_num;
   x_fact_rec.time_id26                  := fnd_api.g_miss_num;
   x_fact_rec.time_id27                  := fnd_api.g_miss_num;
   x_fact_rec.time_id28                  := fnd_api.g_miss_num;
   x_fact_rec.time_id29                  := fnd_api.g_miss_num;
   x_fact_rec.time_id30                  := fnd_api.g_miss_num;
   x_fact_rec.time_id31                  := fnd_api.g_miss_num;
   x_fact_rec.time_id32                  := fnd_api.g_miss_num;
   x_fact_rec.time_id33                  := fnd_api.g_miss_num;
   x_fact_rec.time_id34                  := fnd_api.g_miss_num;
   x_fact_rec.time_id35                  := fnd_api.g_miss_num;
   x_fact_rec.time_id36                  := fnd_api.g_miss_num;
   x_fact_rec.time_id37                  := fnd_api.g_miss_num;
   x_fact_rec.time_id38                  := fnd_api.g_miss_num;
   x_fact_rec.time_id39                  := fnd_api.g_miss_num;
   x_fact_rec.time_id40                  := fnd_api.g_miss_num;
   x_fact_rec.time_id41                  := fnd_api.g_miss_num;
   x_fact_rec.time_id42                  := fnd_api.g_miss_num;
   x_fact_rec.time_id43                  := fnd_api.g_miss_num;
   x_fact_rec.time_id44                  := fnd_api.g_miss_num;
   x_fact_rec.time_id45                  := fnd_api.g_miss_num;
   x_fact_rec.time_id46                  := fnd_api.g_miss_num;
   x_fact_rec.time_id47                  := fnd_api.g_miss_num;
   x_fact_rec.time_id48                  := fnd_api.g_miss_num;
   x_fact_rec.time_id49                  := fnd_api.g_miss_num;
   x_fact_rec.time_id50                  := fnd_api.g_miss_num;
   x_fact_rec.time_id51                  := fnd_api.g_miss_num;
   x_fact_rec.time_id52                  := fnd_api.g_miss_num;
   x_fact_rec.time_id53                  := fnd_api.g_miss_num;
   x_fact_rec.hierarchy_id               := fnd_api.g_miss_num;
   x_fact_rec.node_id                    := fnd_api.g_miss_num;
   x_fact_rec.level_depth                := fnd_api.g_miss_num;
   x_fact_rec.formula_id                 := fnd_api.g_miss_num;
   x_fact_rec.from_date                  := fnd_api.g_miss_date;
   x_fact_rec.to_date                    := fnd_api.g_miss_date;
   x_fact_rec.fact_value                 := fnd_api.g_miss_num;
   x_fact_rec.fact_percent               := fnd_api.g_miss_num;
   x_fact_rec.root_fact_id               := fnd_api.g_miss_num;
   x_fact_rec.previous_fact_id           := fnd_api.g_miss_num;
   x_fact_rec.fact_type                  := fnd_api.g_miss_char;
   x_fact_rec.fact_reference             := fnd_api.g_miss_char;
   x_fact_rec.forward_buy_quantity       := fnd_api.g_miss_num;
   x_fact_rec.status_code                := fnd_api.g_miss_char;
   x_fact_rec.hierarchy_type             := fnd_api.g_miss_char;
   x_fact_rec.approval_date              := fnd_api.g_miss_date;
   x_fact_rec.recommend_total_amount     := fnd_api.g_miss_num;
   x_fact_rec.recommend_hb_amount        := fnd_api.g_miss_num;
   x_fact_rec.request_total_amount       := fnd_api.g_miss_num;
   x_fact_rec.request_hb_amount          := fnd_api.g_miss_num;
   x_fact_rec.actual_total_amount        := fnd_api.g_miss_num;
   x_fact_rec.actual_hb_amount           := fnd_api.g_miss_num;
   x_fact_rec.base_total_pct             := fnd_api.g_miss_num;
   x_fact_rec.base_hb_pct                := fnd_api.g_miss_num;
END Init_ActMetricFact_Rec;


-- Start of comments
-- NAME
--    Validate_FUND_Facts
--
-- PURPOSE
--   Validate Activity Metric Fact for budget allocation.
--    For each node in the hierarchy:
--      Sum(child allocation amount) <= this node's allocation amount - holdback amount
--    since I'm traversing the hierarchy, it's not necessary to do the following check any more:
--      Sum(this node and its sibling's allocation amount) <= parent allocation amount - holdback amount

--      can not use ozf_fund_alloc_tree_v since the view has no data for create mode
--
-- NOTES
--
-- HISTORY
-- 26-Mar-2001  yzhao  Created.
--
-- End of comments--
PROCEDURE Validate_FUND_Facts(
   p_api_version                IN  NUMBER,
   p_init_msg_list              IN  VARCHAR2 := FND_API.G_FALSE,
   p_validation_level           IN  NUMBER   := FND_API.G_Valid_Level_Full,
   p_act_metric_id              IN  NUMBER,
   x_return_status              OUT NOCOPY VARCHAR2,
   x_msg_count                  OUT NOCOPY NUMBER,
   x_msg_data                   OUT NOCOPY VARCHAR2
)
IS
   l_avail_amount                 NUMBER := 0;
   l_allocation_amount            NUMBER :=0;
   l_holdback_amount              NUMBER :=0;
   l_child_sum_amount             NUMBER := 0;
   l_node_value                   VARCHAR2(2000) := null;
   l_hierarchy_id                 NUMBER := 0;
   l_node_id                      NUMBER := 0;
   l_level_depth                  NUMBER := 0;
   l_formula_id                   NUMBER := 0;
   l_top_level                    boolean := true;

   CURSOR c_fundfact_getfacts IS
      SELECT fact.hierarchy_id, fact.node_id, fact.level_depth, fact.fact_value
             ,formula.formula_id, formula.formula_type
      FROM   ams_act_metric_facts_all fact, ams_act_metric_formulas  formula
      WHERE  fact.activity_metric_id = p_act_metric_id
      AND    fact.formula_id = formula.formula_id
      ORDER BY fact.level_depth, fact.node_id, formula.formula_type asc;

   -- get the fund's allocation amount
   CURSOR c_fundfact_getfundamt IS
      SELECT func_actual_value
      FROM   ams_act_metrics_all
      WHERE  activity_metric_id = p_act_metric_id;

   -- get a node's node_value, parent node id
   CURSOR c_fundfact_getnodeinfo(p_hierarchy_id NUMBER, p_node_id NUMBER) IS
       SELECT node_value
       FROM   ams_terr_v
       WHERE  hierarchy_id = p_hierarchy_id
       AND    node_id = p_node_id;

    -- get allocation amount summary of this node's children
    CURSOR c_fundfact_getchildsum(p_hierarchy_id NUMBER, p_node_id NUMBER,
                                  p_level_depth NUMBER,  p_formula_id NUMBER) IS
       SELECT NVL(SUM(fact_value), 0)
       FROM   ams_act_metric_facts_all  fact
       WHERE  activity_metric_id = p_act_metric_id
       AND    hierarchy_id = p_hierarchy_id
       AND    EXISTS
              (SELECT 1 FROM ams_act_metric_formulas formula
               WHERE  formula.formula_id = fact.formula_id
               AND    formula.formula_type = 'ALLOCATION'
               AND    formula.level_depth= p_level_depth + 1
               AND    formula.parent_formula_id = p_formula_id
              )
       AND    EXISTS
              (SELECT 1 FROM ams_terr_v terr
               WHERE  terr.hierarchy_id = p_hierarchy_id
               AND    terr.parent_id = p_node_id
               AND    terr.node_id = fact.node_id);

 BEGIN
   SAVEPOINT Validate_FUND_Facts;
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message('Validate_FundFact_Fund: start');
   END IF;

   IF FND_API.To_Boolean (p_init_msg_list) THEN
      FND_MSG_PUB.Initialize;
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;
   l_top_level := true;

   FOR factrec IN c_fundfact_getfacts LOOP
       IF factrec.formula_type = 'ALLOCATION' THEN
          l_allocation_amount := factrec.fact_value;
          l_hierarchy_id               := factrec.hierarchy_id;
          l_node_id                    := factrec.node_id;
          l_level_depth                := factrec.level_depth;
          l_formula_id                 := factrec.formula_id;
          IF l_top_level = true THEN
             -- top level: check against root budget
             OPEN c_fundfact_getfundamt;
             FETCH c_fundfact_getfundamt INTO l_avail_amount;
             CLOSE c_fundfact_getfundamt;
             -- IF (AMS_DEBUG_HIGH_ON) THEN  AMS_Utility_PVT.debug_message(' Top level budget available amount: ' || l_avail_amount); END IF;
             IF l_allocation_amount > l_avail_amount THEN
                -- top level allocation amount can not exceed fund's available amount
                IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                   FND_MESSAGE.Set_Name ('AMS', 'AMS_FUND_INV_CHILD_AMT');
                   FND_MESSAGE.Set_Token('SUMAMT', l_allocation_amount);
                   FND_MESSAGE.Set_Token('NODEVALUE', 'FUND');
                   FND_MESSAGE.Set_Token('PAMT', l_avail_amount);
                   FND_MSG_PUB.Add;
                END IF;
                x_return_status := FND_API.G_RET_STS_ERROR;
                RAISE FND_API.G_EXC_ERROR;
             END IF;
             l_top_level := false;
          END IF;    -- IF l_top_level = true
       ELSE   -- formula is 'HOLDBACK'
          l_avail_amount := l_allocation_amount - factrec.fact_value;

          -- check the node's children sum. Check here so both allocation amt and holdback amt are available
          OPEN  c_fundfact_getchildsum(l_hierarchy_id, l_node_id, l_level_depth, l_formula_id);
          FETCH c_fundfact_getchildsum INTO l_child_sum_amount;
          CLOSE c_fundfact_getchildsum;

          IF l_child_sum_amount > l_avail_amount THEN
             -- sum of this node's children's allocation amount can not exceed this node's available amount
             IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                OPEN c_fundfact_getnodeinfo(factrec.hierarchy_id, factrec.node_id);
                FETCH c_fundfact_getnodeinfo INTO l_node_value;
                CLOSE c_fundfact_getnodeinfo;
                FND_MESSAGE.Set_Name ('AMS', 'AMS_FUND_INV_CHILD_AMT');
                FND_MESSAGE.Set_Token('SUMAMT', l_child_sum_amount);
                FND_MESSAGE.Set_Token('NODEVALUE', l_node_value);
                FND_MESSAGE.Set_Token('PAMT', l_avail_amount);
                FND_MSG_PUB.Add;
             END IF;
             x_return_status := FND_API.G_RET_STS_ERROR;
             RAISE FND_API.G_EXC_ERROR;
          END IF;
        END IF;
   END LOOP;

   IF (AMS_DEBUG_HIGH_ON) THEN



   AMS_Utility_PVT.debug_message('Validate_FundFact_FUND: end');

   END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      -- IF (AMS_DEBUG_HIGH_ON) THEN  AMS_Utility_PVT.debug_message('Validate_FUND_Facts: ' || substr(sqlerrm, 1, 100)); END IF;
      ROLLBACK TO Validate_FUND_Facts;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get (
         p_encoded       =>     fnd_api.g_false,
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data
      );
   WHEN OTHERS THEN
      -- IF (AMS_DEBUG_HIGH_ON) THEN  AMS_Utility_PVT.debug_message('Validate_FUND_Facts: ' || substr(sqlerrm, 1, 100)); END IF;
      ROLLBACK TO Validate_FUND_Facts;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get (
         p_encoded       =>     fnd_api.g_false,
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data
      );
END Validate_FUND_Facts;


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
      FROM   ams_act_metric_facts_all
      WHERE  activity_metric_fact_id = l_act_metric_fact_id;

   CURSOR c_act_metric_fact_id IS
      SELECT ams_act_metric_facts_all_s.NEXTVAL
      FROM   dual;

BEGIN
   --
   -- Initialize savepoint.
   --

   SAVEPOINT Create_ActMetricFact_Pvt;

   IF (AMS_DEBUG_HIGH_ON) THEN



   AMS_Utility_PVT.Debug_Message(l_full_name||': start');

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
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message(l_full_name ||': insert');
   END IF;



   --
   -- Insert into the base table.
   --


   Insert into ams_act_metric_facts_all (
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
               base_hb_pct
               /* 05/21/2002 yzhao: add ends */
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
               TO_NUMBER (SUBSTRB (USERENV ('CLIENT_INFO'), 1, 10)) , -- org_id
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
               l_act_metric_fact_rec.base_hb_pct
               /* 05/21/2002 yzhao: add ends */
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
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message(l_full_name ||': end Success');
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
--   Updates an entry in the  AMS_ACT_METRIC_FACTS_ALL table for
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
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message(l_full_name||': start');
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


   IF (AMS_DEBUG_HIGH_ON) THEN





   AMS_Utility_PVT.debug_message(l_full_name ||': validate');


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


   IF (AMS_DEBUG_HIGH_ON) THEN





   AMS_Utility_PVT.debug_message(l_full_name ||': Update Activity Metric Facts Table');


   END IF;



   Update ams_act_metric_facts_all Set
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
               base_hb_pct               =  l_act_metric_fact_rec.base_hb_pct
               /* 05/21/2002 yzhao: add ends */
    Where      activity_metric_fact_id   =  l_act_metric_fact_rec.activity_metric_fact_id;

    IF  (SQL%NOTFOUND)
    THEN
      --
      -- Add error message to API message list.
      --
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
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
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message(l_full_name ||': end');
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


-- Start of comments
-- NAME
--    Lock_ActMetricFact
--
-- PURPOSE
--    Lock the given row in AMS_ACT_METRIC_FACTS table.
--
-- NOTES
--
-- HISTORY
-- 19-Apr-2000 tdonohoe  Created.
--
-- End of comments

PROCEDURE Lock_ActMetricFact (
   p_api_version             IN  NUMBER,
   p_init_msg_list           IN  VARCHAR2 := FND_API.G_FALSE,

   x_return_status           OUT NOCOPY VARCHAR2,
   x_msg_count               OUT NOCOPY NUMBER,
   x_msg_data                OUT NOCOPY VARCHAR2,

   p_activity_metric_fact_id IN  NUMBER,
   p_object_version_number   IN  NUMBER
)
IS
   L_API_VERSION           CONSTANT NUMBER := 1.0;
   L_API_NAME              CONSTANT VARCHAR2(30) := 'LOCK_ACTMETRICFACT';
   L_FULL_NAME           CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

   l_activity_metric_fact_id    NUMBER;

   CURSOR c_act_metric_fact_info IS
   SELECT activity_metric_fact_id
   FROM ams_act_metric_facts_all
   WHERE activity_metric_fact_id = p_activity_metric_fact_id
   AND object_version_number = p_object_version_number
   FOR UPDATE OF activity_metric_fact_id NOWAIT;

BEGIN
   --
   -- Output debug message.
   --
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message(l_full_name||': start');
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
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message(l_full_name||': lock');
   END IF;

   OPEN c_act_metric_fact_info;
   FETCH c_act_metric_fact_info INTO l_activity_metric_fact_id;
   IF  (c_act_metric_fact_info%NOTFOUND)
   THEN
      CLOSE c_act_metric_fact_info;
      -- Error, check the msg level and added an error message to the
      -- API message list
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
   END IF;
   CLOSE c_act_metric_fact_info;


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
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message(l_full_name ||': end');
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
   WHEN AMS_Utility_PVT.RESOURCE_LOCKED THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;

      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
           FND_MESSAGE.set_name('AMS', 'AMS_API_RESOURCE_LOCKED');
           FND_MSG_PUB.add;
      END IF;

      FND_MSG_PUB.Count_And_Get (
         p_count         =>      x_msg_count,
         p_data          =>      x_msg_data,
         p_encoded        =>      FND_API.G_FALSE
      );
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, L_API_NAME);
      END IF;
      FND_MSG_PUB.Count_And_Get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data,
         p_encoded        =>      FND_API.G_FALSE
               );
END Lock_ActMetricFact;


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
   FROM ams_act_metric_facts_all
   WHERE activity_metric_fact_id = p_act_metric_fact_rec.activity_metric_fact_id;

   l_act_metric_fact_rec  c_act_metric_fact%ROWTYPE;
BEGIN

   x_complete_fact_rec := p_act_metric_fact_rec;

   OPEN c_act_metric_fact;
   FETCH c_act_metric_fact INTO l_act_metric_fact_rec;
   IF c_act_metric_fact%NOTFOUND THEN
      CLOSE c_act_metric_fact;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
   END IF;
   CLOSE c_act_metric_fact;


   IF p_act_metric_fact_rec.activity_metric_fact_id = FND_API.G_MISS_NUM THEN
      x_complete_fact_rec.activity_metric_fact_id  := l_act_metric_fact_rec.activity_metric_fact_id;
   END IF;

   IF p_act_metric_fact_rec.act_metric_used_by_id = FND_API.G_MISS_NUM THEN
      x_complete_fact_rec.act_metric_used_by_id  :=  l_act_metric_fact_rec.act_metric_used_by_id;
   END IF;

   IF p_act_metric_fact_rec.arc_act_metric_used_by =  FND_API.G_MISS_CHAR THEN
      x_complete_fact_rec.arc_act_metric_used_by  := l_act_metric_fact_rec.arc_act_metric_used_by;
   END IF;

   IF p_act_metric_fact_rec.value_type =  FND_API.G_MISS_CHAR THEN
      x_complete_fact_rec.value_type  := l_act_metric_fact_rec.value_type;
   END IF;

   IF p_act_metric_fact_rec.activity_metric_id = FND_API.G_MISS_NUM THEN
      x_complete_fact_rec.activity_metric_id  :=  l_act_metric_fact_rec.activity_metric_id;
   END IF;

   IF p_act_metric_fact_rec.activity_geo_area_id = FND_API.G_MISS_NUM THEN
      x_complete_fact_rec.activity_geo_area_id  :=  l_act_metric_fact_rec.activity_geo_area_id;
   END IF;

   IF p_act_metric_fact_rec.activity_product_id = FND_API.G_MISS_NUM THEN
      x_complete_fact_rec.activity_product_id  :=  l_act_metric_fact_rec.activity_product_id;
   END IF;

   IF p_act_metric_fact_rec.transaction_currency_code = FND_API.G_MISS_CHAR THEN
      x_complete_fact_rec.transaction_currency_code  :=  l_act_metric_fact_rec.transaction_currency_code;
   END IF;

   IF p_act_metric_fact_rec.trans_forecasted_value = FND_API.G_MISS_NUM THEN
      x_complete_fact_rec.trans_forecasted_value  :=  l_act_metric_fact_rec.trans_forecasted_value;
   END IF;

   IF p_act_metric_fact_rec.base_quantity = FND_API.G_MISS_NUM THEN
      x_complete_fact_rec.base_quantity  :=  l_act_metric_fact_rec.base_quantity;
   END IF;

   IF p_act_metric_fact_rec.functional_currency_code = FND_API.G_MISS_CHAR THEN
      x_complete_fact_rec.functional_currency_code  :=  l_act_metric_fact_rec.functional_currency_code;
   END IF;

   IF p_act_metric_fact_rec.func_forecasted_value = FND_API.G_MISS_NUM THEN
      x_complete_fact_rec.func_forecasted_value  :=  l_act_metric_fact_rec.func_forecasted_value;
   END IF;

   IF p_act_metric_fact_rec.org_id = FND_API.G_MISS_NUM THEN
      x_complete_fact_rec.org_id  :=  l_act_metric_fact_rec.org_id;
   END IF;

   IF p_act_metric_fact_rec.de_metric_id = FND_API.G_MISS_NUM THEN
      x_complete_fact_rec.de_metric_id  :=  l_act_metric_fact_rec.de_metric_id;
   END IF;

   IF p_act_metric_fact_rec.de_geographic_area_id = FND_API.G_MISS_NUM THEN
      x_complete_fact_rec.de_geographic_area_id  :=  l_act_metric_fact_rec.de_geographic_area_id;
   END IF;

   IF p_act_metric_fact_rec.de_geographic_area_type = FND_API.G_MISS_CHAR THEN
      x_complete_fact_rec.de_geographic_area_type :=  l_act_metric_fact_rec.de_geographic_area_type;
   END IF;

   IF p_act_metric_fact_rec.de_inventory_item_id = FND_API.G_MISS_NUM THEN
      x_complete_fact_rec.de_inventory_item_id  :=  l_act_metric_fact_rec.de_inventory_item_id;
   END IF;

   IF p_act_metric_fact_rec.de_inventory_item_org_id = FND_API.G_MISS_NUM THEN
      x_complete_fact_rec.de_inventory_item_org_id  :=  l_act_metric_fact_rec.de_inventory_item_org_id;
   END IF;

   IF p_act_metric_fact_rec.time_id1 = FND_API.G_MISS_NUM THEN
      x_complete_fact_rec.time_id1  :=  l_act_metric_fact_rec.time_id1;
   END IF;

   IF p_act_metric_fact_rec.time_id2 = FND_API.G_MISS_NUM THEN
      x_complete_fact_rec.time_id2  :=  l_act_metric_fact_rec.time_id2;
   END IF;

   IF p_act_metric_fact_rec.time_id3 = FND_API.G_MISS_NUM THEN
      x_complete_fact_rec.time_id3  :=  l_act_metric_fact_rec.time_id3;
   END IF;


   IF p_act_metric_fact_rec.time_id4 = FND_API.G_MISS_NUM THEN
      x_complete_fact_rec.time_id4  :=  l_act_metric_fact_rec.time_id4;
   END IF;

   IF p_act_metric_fact_rec.time_id5 = FND_API.G_MISS_NUM THEN
      x_complete_fact_rec.time_id5  :=  l_act_metric_fact_rec.time_id5;
   END IF;

   IF p_act_metric_fact_rec.time_id6 = FND_API.G_MISS_NUM THEN
      x_complete_fact_rec.time_id6  :=  l_act_metric_fact_rec.time_id6;
   END IF;

   IF p_act_metric_fact_rec.time_id7 = FND_API.G_MISS_NUM THEN
      x_complete_fact_rec.time_id7  :=  l_act_metric_fact_rec.time_id7;
   END IF;

   IF p_act_metric_fact_rec.time_id8 = FND_API.G_MISS_NUM THEN
      x_complete_fact_rec.time_id8  :=  l_act_metric_fact_rec.time_id8;
   END IF;

   IF p_act_metric_fact_rec.time_id9 = FND_API.G_MISS_NUM THEN
      x_complete_fact_rec.time_id9  :=  l_act_metric_fact_rec.time_id9;
   END IF;

   IF p_act_metric_fact_rec.time_id10 = FND_API.G_MISS_NUM THEN
      x_complete_fact_rec.time_id10  :=  l_act_metric_fact_rec.time_id10;
   END IF;

   IF p_act_metric_fact_rec.time_id11 = FND_API.G_MISS_NUM THEN
      x_complete_fact_rec.time_id11  :=  l_act_metric_fact_rec.time_id11;
   END IF;

   IF p_act_metric_fact_rec.time_id12 = FND_API.G_MISS_NUM THEN
      x_complete_fact_rec.time_id12  :=  l_act_metric_fact_rec.time_id12;
   END IF;

   IF p_act_metric_fact_rec.time_id13 = FND_API.G_MISS_NUM THEN
      x_complete_fact_rec.time_id13  :=  l_act_metric_fact_rec.time_id13;
   END IF;

   IF p_act_metric_fact_rec.time_id14 = FND_API.G_MISS_NUM THEN
      x_complete_fact_rec.time_id14  :=  l_act_metric_fact_rec.time_id14;
   END IF;

   IF p_act_metric_fact_rec.time_id15 = FND_API.G_MISS_NUM THEN
      x_complete_fact_rec.time_id15  :=  l_act_metric_fact_rec.time_id15;
   END IF;

   IF p_act_metric_fact_rec.time_id16 = FND_API.G_MISS_NUM THEN
      x_complete_fact_rec.time_id16  :=  l_act_metric_fact_rec.time_id16;
   END IF;

   IF p_act_metric_fact_rec.time_id17 = FND_API.G_MISS_NUM THEN
      x_complete_fact_rec.time_id17  :=  l_act_metric_fact_rec.time_id17;
   END IF;

   IF p_act_metric_fact_rec.time_id18 = FND_API.G_MISS_NUM THEN
      x_complete_fact_rec.time_id18  :=  l_act_metric_fact_rec.time_id18;
   END IF;

   IF p_act_metric_fact_rec.time_id19 = FND_API.G_MISS_NUM THEN
      x_complete_fact_rec.time_id19  :=  l_act_metric_fact_rec.time_id19;
   END IF;

   IF p_act_metric_fact_rec.time_id20 = FND_API.G_MISS_NUM THEN
      x_complete_fact_rec.time_id20  :=  l_act_metric_fact_rec.time_id20;
   END IF;

   IF p_act_metric_fact_rec.time_id21 = FND_API.G_MISS_NUM THEN
      x_complete_fact_rec.time_id21  :=  l_act_metric_fact_rec.time_id21;
   END IF;

   IF p_act_metric_fact_rec.time_id22 = FND_API.G_MISS_NUM THEN
      x_complete_fact_rec.time_id22  :=  l_act_metric_fact_rec.time_id22;
   END IF;

   IF p_act_metric_fact_rec.time_id23 = FND_API.G_MISS_NUM THEN
      x_complete_fact_rec.time_id23  :=  l_act_metric_fact_rec.time_id23;
   END IF;

   IF p_act_metric_fact_rec.time_id24 = FND_API.G_MISS_NUM THEN
      x_complete_fact_rec.time_id24  :=  l_act_metric_fact_rec.time_id24;
   END IF;

   IF p_act_metric_fact_rec.time_id25 = FND_API.G_MISS_NUM THEN
      x_complete_fact_rec.time_id25  :=  l_act_metric_fact_rec.time_id25;
   END IF;

   IF p_act_metric_fact_rec.time_id26 = FND_API.G_MISS_NUM THEN
      x_complete_fact_rec.time_id26  :=  l_act_metric_fact_rec.time_id26;
   END IF;

   IF p_act_metric_fact_rec.time_id27 = FND_API.G_MISS_NUM THEN
      x_complete_fact_rec.time_id27  :=  l_act_metric_fact_rec.time_id27;
   END IF;

   IF p_act_metric_fact_rec.time_id28 = FND_API.G_MISS_NUM THEN
      x_complete_fact_rec.time_id28  :=  l_act_metric_fact_rec.time_id28;
   END IF;

   IF p_act_metric_fact_rec.time_id29 = FND_API.G_MISS_NUM THEN
      x_complete_fact_rec.time_id29  :=  l_act_metric_fact_rec.time_id29;
   END IF;

   IF p_act_metric_fact_rec.time_id30 = FND_API.G_MISS_NUM THEN
      x_complete_fact_rec.time_id30  :=  l_act_metric_fact_rec.time_id30;
   END IF;

   IF p_act_metric_fact_rec.time_id31 = FND_API.G_MISS_NUM THEN
      x_complete_fact_rec.time_id31  :=  l_act_metric_fact_rec.time_id31;
   END IF;

   IF p_act_metric_fact_rec.time_id32 = FND_API.G_MISS_NUM THEN
      x_complete_fact_rec.time_id32  :=  l_act_metric_fact_rec.time_id32;
   END IF;

   IF p_act_metric_fact_rec.time_id33 = FND_API.G_MISS_NUM THEN
      x_complete_fact_rec.time_id33  :=  l_act_metric_fact_rec.time_id33;
   END IF;

   IF p_act_metric_fact_rec.time_id34 = FND_API.G_MISS_NUM THEN
      x_complete_fact_rec.time_id34  :=  l_act_metric_fact_rec.time_id34;
   END IF;

   IF p_act_metric_fact_rec.time_id35 = FND_API.G_MISS_NUM THEN
      x_complete_fact_rec.time_id35  :=  l_act_metric_fact_rec.time_id35;
   END IF;

   IF p_act_metric_fact_rec.time_id36 = FND_API.G_MISS_NUM THEN
      x_complete_fact_rec.time_id36  :=  l_act_metric_fact_rec.time_id36;
   END IF;

   IF p_act_metric_fact_rec.time_id37 = FND_API.G_MISS_NUM THEN
      x_complete_fact_rec.time_id37  :=  l_act_metric_fact_rec.time_id37;
   END IF;

   IF p_act_metric_fact_rec.time_id38 = FND_API.G_MISS_NUM THEN
      x_complete_fact_rec.time_id38  :=  l_act_metric_fact_rec.time_id38;
   END IF;

   IF p_act_metric_fact_rec.time_id39 = FND_API.G_MISS_NUM THEN
      x_complete_fact_rec.time_id39  :=  l_act_metric_fact_rec.time_id39;
   END IF;

   IF p_act_metric_fact_rec.time_id40 = FND_API.G_MISS_NUM THEN
      x_complete_fact_rec.time_id40  :=  l_act_metric_fact_rec.time_id40;
   END IF;

   IF p_act_metric_fact_rec.time_id41 = FND_API.G_MISS_NUM THEN
      x_complete_fact_rec.time_id41  :=  l_act_metric_fact_rec.time_id41;
   END IF;

   IF p_act_metric_fact_rec.time_id42 = FND_API.G_MISS_NUM THEN
      x_complete_fact_rec.time_id42  :=  l_act_metric_fact_rec.time_id42;
   END IF;

   IF p_act_metric_fact_rec.time_id43 = FND_API.G_MISS_NUM THEN
      x_complete_fact_rec.time_id43  :=  l_act_metric_fact_rec.time_id43;
   END IF;

   IF p_act_metric_fact_rec.time_id44 = FND_API.G_MISS_NUM THEN
      x_complete_fact_rec.time_id44  :=  l_act_metric_fact_rec.time_id44;
   END IF;

   IF p_act_metric_fact_rec.time_id45 = FND_API.G_MISS_NUM THEN
      x_complete_fact_rec.time_id45  :=  l_act_metric_fact_rec.time_id45;
   END IF;

   IF p_act_metric_fact_rec.time_id46 = FND_API.G_MISS_NUM THEN
      x_complete_fact_rec.time_id46  :=  l_act_metric_fact_rec.time_id46;
   END IF;

   IF p_act_metric_fact_rec.time_id47 = FND_API.G_MISS_NUM THEN
      x_complete_fact_rec.time_id47  :=  l_act_metric_fact_rec.time_id47;
   END IF;

   IF p_act_metric_fact_rec.time_id48 = FND_API.G_MISS_NUM THEN
      x_complete_fact_rec.time_id48  :=  l_act_metric_fact_rec.time_id48;
   END IF;

   IF p_act_metric_fact_rec.time_id49 = FND_API.G_MISS_NUM THEN
      x_complete_fact_rec.time_id49  :=  l_act_metric_fact_rec.time_id49;
   END IF;

   IF p_act_metric_fact_rec.time_id50 = FND_API.G_MISS_NUM THEN
      x_complete_fact_rec.time_id50  :=  l_act_metric_fact_rec.time_id50;
   END IF;

   IF p_act_metric_fact_rec.time_id51 = FND_API.G_MISS_NUM THEN
      x_complete_fact_rec.time_id51  :=  l_act_metric_fact_rec.time_id51;
   END IF;

   IF p_act_metric_fact_rec.time_id52 = FND_API.G_MISS_NUM THEN
      x_complete_fact_rec.time_id52  :=  l_act_metric_fact_rec.time_id52;
   END IF;

   IF p_act_metric_fact_rec.time_id53 = FND_API.G_MISS_NUM THEN
      x_complete_fact_rec.time_id53  :=  l_act_metric_fact_rec.time_id53;
   END IF;

   IF p_act_metric_fact_rec.hierarchy_id = FND_API.G_MISS_NUM THEN
      x_complete_fact_rec.hierarchy_id  :=  l_act_metric_fact_rec.hierarchy_id;
   END IF;

   IF p_act_metric_fact_rec.node_id = FND_API.G_MISS_NUM THEN
      x_complete_fact_rec.node_id  :=  l_act_metric_fact_rec.node_id;
   END IF;

   IF p_act_metric_fact_rec.level_depth = FND_API.G_MISS_NUM THEN
      x_complete_fact_rec.level_depth  :=  l_act_metric_fact_rec.level_depth;
   END IF;

   IF p_act_metric_fact_rec.formula_id = FND_API.G_MISS_NUM THEN
      x_complete_fact_rec.formula_id  :=  l_act_metric_fact_rec.formula_id;
   END IF;

   IF p_act_metric_fact_rec.from_date = FND_API.G_MISS_DATE THEN
      x_complete_fact_rec.from_date  :=  l_act_metric_fact_rec.from_date;
   END IF;

   IF p_act_metric_fact_rec.to_date = FND_API.G_MISS_DATE THEN
      x_complete_fact_rec.to_date  :=  l_act_metric_fact_rec.to_date;
   END IF;

   IF p_act_metric_fact_rec.fact_value = FND_API.G_MISS_NUM THEN
      x_complete_fact_rec.fact_value  :=  l_act_metric_fact_rec.fact_value;
   END IF;

   IF p_act_metric_fact_rec.fact_percent = FND_API.G_MISS_NUM THEN
      x_complete_fact_rec.fact_percent  :=  l_act_metric_fact_rec.fact_percent;
   END IF;

   IF p_act_metric_fact_rec.root_fact_id = FND_API.G_MISS_NUM THEN
      x_complete_fact_rec.root_fact_id  :=  l_act_metric_fact_rec.root_fact_id;
   END IF;

   IF p_act_metric_fact_rec.previous_fact_id = FND_API.G_MISS_NUM THEN
      x_complete_fact_rec.previous_fact_id  :=  l_act_metric_fact_rec.previous_fact_id;
   END IF;

   IF p_act_metric_fact_rec.fact_type = FND_API.G_MISS_CHAR THEN
      x_complete_fact_rec.fact_type  :=  l_act_metric_fact_rec.fact_type;
   END IF;

   IF p_act_metric_fact_rec.fact_reference = FND_API.G_MISS_CHAR THEN
      x_complete_fact_rec.fact_reference  :=  l_act_metric_fact_rec.fact_reference;
   END IF;

   IF p_act_metric_fact_rec.forward_buy_quantity = FND_API.G_MISS_NUM THEN
      x_complete_fact_rec.forward_buy_quantity  :=  l_act_metric_fact_rec.forward_buy_quantity;
   END IF;

   /* 05/21/2002 yzhao: add 11 new columns for top-down bottom-up budgeting */
   IF p_act_metric_fact_rec.status_code = FND_API.G_MISS_CHAR THEN
      x_complete_fact_rec.status_code  :=  l_act_metric_fact_rec.status_code;
   END IF;

   IF p_act_metric_fact_rec.hierarchy_type = FND_API.G_MISS_CHAR THEN
      x_complete_fact_rec.hierarchy_type  :=  l_act_metric_fact_rec.hierarchy_type;
   END IF;

   IF p_act_metric_fact_rec.approval_date = FND_API.G_MISS_DATE THEN
      x_complete_fact_rec.approval_date  :=  l_act_metric_fact_rec.approval_date;
   END IF;

   IF p_act_metric_fact_rec.recommend_total_amount = FND_API.G_MISS_NUM THEN
      x_complete_fact_rec.recommend_total_amount  :=  l_act_metric_fact_rec.recommend_total_amount;
   END IF;

   IF p_act_metric_fact_rec.recommend_hb_amount = FND_API.G_MISS_NUM THEN
      x_complete_fact_rec.recommend_hb_amount  :=  l_act_metric_fact_rec.recommend_hb_amount;
   END IF;

   IF p_act_metric_fact_rec.request_total_amount = FND_API.G_MISS_NUM THEN
      x_complete_fact_rec.request_total_amount  :=  l_act_metric_fact_rec.request_total_amount;
   END IF;

   IF p_act_metric_fact_rec.request_hb_amount = FND_API.G_MISS_NUM THEN
      x_complete_fact_rec.request_hb_amount  :=  l_act_metric_fact_rec.request_hb_amount;
   END IF;

   IF p_act_metric_fact_rec.actual_total_amount = FND_API.G_MISS_NUM THEN
      x_complete_fact_rec.actual_total_amount  :=  l_act_metric_fact_rec.actual_total_amount;
   END IF;

   IF p_act_metric_fact_rec.actual_hb_amount = FND_API.G_MISS_NUM THEN
      x_complete_fact_rec.actual_hb_amount  :=  l_act_metric_fact_rec.actual_hb_amount;
   END IF;

   IF p_act_metric_fact_rec.base_total_pct = FND_API.G_MISS_NUM THEN
      x_complete_fact_rec.base_total_pct  :=  l_act_metric_fact_rec.base_total_pct;
   END IF;

   IF p_act_metric_fact_rec.base_hb_pct = FND_API.G_MISS_NUM THEN
      x_complete_fact_rec.base_hb_pct  :=  l_act_metric_fact_rec.base_hb_pct;
   END IF;
   /* 05/21/2002 yzhao: add ends */

END Complete_ActMetFact_Rec ;


-- Start of comments
-- NAME
--    Delete_ActMetricFact
--
-- PURPOSE
--    Deletes an entry in the ams_act_metric_facts_all table.
--
-- NOTES
--
-- HISTORY
-- 24-Apr-2000 tdonohoe  Created.
-- 25-Apr-2000 tdonohoe  Modified, if the p_activity_metric_id is specified then
--                       all entries for this parameter are deleted.
--
-- End of comments

PROCEDURE Delete_ActMetricFact (
   p_api_version              IN  NUMBER,
   p_init_msg_list            IN  VARCHAR2 := FND_API.G_FALSE,
   p_commit                   IN  VARCHAR2 := FND_API.G_FALSE,

   x_return_status            OUT NOCOPY VARCHAR2,
   x_msg_count                OUT NOCOPY NUMBER,
   x_msg_data                 OUT NOCOPY VARCHAR2,

   p_activity_metric_fact_id  IN  NUMBER,
   p_activity_metric_id       IN  NUMBER,
   p_object_version_number    IN  NUMBER
)
IS
   L_API_VERSION              CONSTANT NUMBER := 1.0;
   L_API_NAME                 CONSTANT VARCHAR2(30) := 'DELETE_ACTMETRICFACT';
   L_FULL_NAME             CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

   l_return_status            VARCHAR2(1);

BEGIN
   --
   -- Initialize savepoint.
   --
   SAVEPOINT Delete_ActMetricFact_pvt;

   --
   -- Output debug message.
   --
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message(l_full_name||': start');
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
         IF (AMS_DEBUG_HIGH_ON) THEN

         AMS_Utility_PVT.debug_message(l_full_name ||': delete with Validation');
         END IF;

      IF(p_activity_metric_id IS NOT NULL) THEN

         DELETE FROM ams_act_metric_facts_all
         WHERE activity_metric_id = p_activity_metric_id;

      ELSIF (p_activity_metric_fact_id IS NOT NULL) THEN

         DELETE FROM ams_act_metric_facts_all
         WHERE activity_metric_fact_id = p_activity_metric_fact_id
         AND   object_version_number   = p_object_version_number;

      END IF;


      IF (SQL%NOTFOUND) THEN
     IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
             FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
             FND_MSG_PUB.add;
           END IF;
           RAISE FND_API.g_exc_error;
      END IF;


   --
   -- End API Body.
   --

   IF FND_API.To_Boolean (p_commit) THEN
      COMMIT WORK;
   END IF;

   --
   -- Debug message.
   --
         IF (AMS_DEBUG_HIGH_ON) THEN

         AMS_Utility_PVT.debug_message(l_full_name ||': End');
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

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Delete_ActMetricFact_pvt;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data
      );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Delete_ActMetricFact_pvt;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data
      );
   WHEN OTHERS THEN
      ROLLBACK TO Delete_ActMetricFact_pvt;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, L_API_NAME);
      END IF;
      FND_MSG_PUB.Count_And_Get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data
      );
END Delete_ActMetricFact;

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
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message(l_full_name||': start');
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

   IF (AMS_DEBUG_HIGH_ON) THEN



   AMS_Utility_PVT.debug_message(l_full_name||': Validate items');

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

      IF (AMS_DEBUG_HIGH_ON) THEN



      AMS_Utility_PVT.debug_message(l_full_name||': check record');

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



   IF (AMS_DEBUG_HIGH_ON) THEN







   AMS_Utility_PVT.debug_message(l_full_name ||': end');



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
         FND_MESSAGE.Set_Name('AMS', 'AMS_METR_MISSING_ARC_USED_FOR');
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
         FND_MESSAGE.Set_Name('AMS', 'AMS_METR_MISSING_ARC_USED_FOR');
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
         FND_MESSAGE.Set_Name('AMS', 'AMS_METR_MISSING_VAL_TYPE');
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
         FND_MESSAGE.Set_Name('AMS', 'AMS_METR_MISSING_ACT_METRIC_ID');
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
         FND_MESSAGE.Set_Name('AMS', 'AMS_METR_MISSING_TRAN_FCST_VAL');
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
         FND_MESSAGE.Set_Name('AMS', 'AMS_METR_MISSING_FUNC_CUR_CODE');
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
         FND_MESSAGE.Set_Name('AMS', 'AMS_METR_MISSING_FUNC_FCST_VAL');
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
         FND_MESSAGE.Set_Name('AMS', 'AMS_METR_MISSING_METRIC_ID');
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
         FND_MESSAGE.Set_Name('AMS', 'AMS_METR_MISSING_TIME_ID1');
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
             FND_MESSAGE.Set_Name('AMS', 'AMS_METR_MISSING_NODE_ID');
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
             FND_MESSAGE.Set_Name('AMS', 'AMS_METR_MISSING_FACT_VAL');
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

      IF AMS_Utility_PVT.Check_Uniqueness(
               p_table_name      => 'ams_act_metric_facts_all',
            p_where_clause    => l_where_clause
            ) = FND_API.g_false
        THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
            THEN
            FND_MESSAGE.set_name('AMS', 'AMS_METR_FACT_DUP_ID');
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
   SELECT 1 from ams_act_metric_facts_all
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
      l_table_name               := 'AMS_ACT_METRICS_ALL';
      l_pk_name                  := 'ACTIVITY_METRIC_ID';
      l_pk_value                 := l_act_metric_fact_rec.activity_metric_id;
      l_pk_data_type             := AMS_Utility_PVT.G_NUMBER;
      l_additional_where_clause  := NULL ;

      IF AMS_Utility_PVT.Check_FK_Exists (
             p_table_name            => l_table_name
            ,p_pk_name                    => l_pk_name
            ,p_pk_value                    => l_pk_value
            ,p_pk_data_type                => l_pk_data_type
            ,p_additional_where_clause  => l_additional_where_clause
         ) = FND_API.G_FALSE
      THEN
         IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
         THEN
             FND_MESSAGE.Set_Name('AMS', 'AMS_METR_INVALID_MET');
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
            FND_MESSAGE.Set_Name ('AMS', 'AMS_METR_INVALID_USED_BY');
            FND_MSG_PUB.Add;
         END IF;

     x_return_status := FND_API.G_RET_STS_ERROR;
      RETURN;
      END IF;
   END IF;

  -----------------------------------------------------------------------
  --07-31-2000 tdonohoe , commented out  to fix bug 1362107            --
  -----------------------------------------------------------------------
 /*
   IF l_act_metric_fact_rec.hierarchy_id <> FND_API.G_MISS_NUM THEN

      l_table_name               := 'AMS_HIERARCHIES_ALL_B';
      l_pk_name                  := 'HIERARCHY_ID';
      l_pk_value                 := l_act_metric_fact_rec.hierarchy_id;
      l_pk_data_type             := AMS_Utility_PVT.G_NUMBER;
      l_additional_where_clause  := NULL ;

      IF AMS_Utility_PVT.Check_FK_Exists (
             p_table_name            => l_table_name
            ,p_pk_name                    => l_pk_name
            ,p_pk_value                    => l_pk_value
            ,p_pk_data_type                => l_pk_data_type
            ,p_additional_where_clause  => l_additional_where_clause
         ) = FND_API.G_FALSE
      THEN
         IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
         THEN
             FND_MESSAGE.Set_Name('AMS', 'AMS_HIER_INVALID');
             FND_MSG_PUB.Add;
     END IF;

         x_return_status := FND_API.G_RET_STS_ERROR;
         RETURN;
      END IF;  -- Check_FK_Exists

   END IF;

 */
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
             FND_MESSAGE.set_name('AMS', 'AMS_METR_FACT_DUP_NODE_ID');
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
          l_table_name               := 'AMS_ACT_METRICS_ALL';
          l_pk_name                  := 'ACTIVITY_METRIC_ID';
          l_pk_value                 := l_act_metric_fact_rec.activity_metric_id;
          l_pk_data_type             := AMS_Utility_PVT.G_NUMBER;
          l_additional_where_clause  := ' arc_act_metric_used_by = '||''''||
                                   l_act_metric_fact_rec.arc_act_metric_used_by||'''' ;



      IF AMS_Utility_PVT.Check_FK_Exists (
             p_table_name            => l_table_name
            ,p_pk_name                    => l_pk_name
            ,p_pk_value                    => l_pk_value
            ,p_pk_data_type                => l_pk_data_type
            ,p_additional_where_clause      => l_additional_where_clause
         ) = FND_API.G_FALSE
      THEN

         IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
         THEN
             FND_MESSAGE.Set_Name('AMS', 'AMS_METR_INVALID_ACT_USAGE');
             FND_MSG_PUB.Add;
         END IF;

         x_return_status := FND_API.G_RET_STS_ERROR;

             RETURN;

      END IF;  -- Check_FK_Exists


      /*

      -- Get table_name and pk_name for the ARC qualifier.
      AMS_Utility_PVT.Get_Qual_Table_Name_And_PK (
         p_sys_qual                     => l_act_metric_fact_rec.arc_act_metric_used_by,
         x_return_status                => l_return_status,
         x_table_name                   => l_table_name,
         x_pk_name                      => l_pk_name
      );



      l_pk_value                 := l_act_metric_fact_rec.act_metric_used_by_id;
      l_pk_data_type             := AMS_Utility_PVT.G_NUMBER;
      l_additional_where_clause  := NULL;

      IF AMS_Utility_PVT.Check_FK_Exists (
             p_table_name                   => l_table_name
            ,p_pk_name                      => l_pk_name
            ,p_pk_value                     => l_pk_value
            ,p_pk_data_type                 => l_pk_data_type
            ,p_additional_where_clause      => NULL
         ) = FND_API.G_FALSE
      THEN
            IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
            FND_MESSAGE.Set_Name ('AMS', 'AMS_METR_INVALID_USED_BY');
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


END Ams_Actmetricfact_Pvt;

/
