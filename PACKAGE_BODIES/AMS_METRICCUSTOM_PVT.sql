--------------------------------------------------------
--  DDL for Package Body AMS_METRICCUSTOM_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_METRICCUSTOM_PVT" AS
/*$Header: amsvrcsb.pls 115.7 2002/11/14 22:05:59 jieli noship $*/
--
-- NAME
--   AMS_METRICCUSTOM_PVT
-- PURPOSE
--   To get the metric rollup values for events and campaigns
-- FUNCTION
-- get_rollup_value
-- HISTORY
--   Date              Owner            Changes
--   09/29/2000        MUSMAN           CREATED
---------------------------------------------------------------------


---------------------------------------------------------------------
-- FUNCTION
--     get_rollup_value
--
-- PURPOSE
--    Get the rollup values for the events and campaigns
--
-- PARAMETERS
--    p_act_met_id: the new record to be inserted
-- RETURNS
--   l_actual_tot_value :  sum of the roolup metrics value
--
-- NOTES
--    1. Checks whether metrics is used by campaigns.
--    2. Checks for the child campaign if exists and select the functional actual value, functional
--       forecasted value  used by it (passing the category id and sub_category_id) and sum it up.
--    3. Checks whether the metrics is used by events.
--    4. Find out the sub events associated to it and get the functional actual value,functional
--       forcasted value and it adds it up.
--    5. Calls  update API and passes the functional actual value .
--    6. Returns the total sum
---------------------------------------------------------------------
AMS_DEBUG_HIGH_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

FUNCTION get_rollup_value(p_act_met_id NUMBER)
RETURN NUMBER is

  CURSOR c_act_metric_row(p_act_metric_id number) IS
  SELECT a.arc_act_metric_used_by,
         a.act_metric_used_by_id,
         a.metric_id,
         b.metric_category,
         b.metric_sub_category,
         a.object_version_number,
         a.transaction_currency_code
  FROM ams_act_metrics_all a, ams_metrics_all_b b
  WHERE a.metric_id = b.metric_id
  and activity_metric_id = p_act_met_id;

  l_act_metric_row c_act_metric_row%ROWTYPE;
  l_child_camp_id     NUMBER;
  l_child_event_id    NUMBER;
  l_actual_ret_value  NUMBER := 0;
  l_actual_tot_value  NUMBER := 0;
  l_forecas_ret_value NUMBER := 0;
  l_forecas_tot_value NUMBER := 0;
  l_metric_rec        AMS_actmetric_pvt.act_metric_rec_type;
  l_return_status     VARCHAR2(1);
  l_msg_count         NUMBER;
  l_msg_data          VARCHAR2(2000);
  l_object_version_number    NUMBER;


  CURSOR c_camp(p_current_campaign_id NUMBER) IS
  SELECT campaign_id
  FROM   ams_campaigns_all_b
  WHERE  parent_campaign_id = p_current_campaign_id ;

  CURSOR c_even(p_current_event_id NUMBER) IS
  SELECT event_offer_id
  FROM ams_event_offers_all_b
  WHERE event_header_id = p_current_event_id;

  CURSOR c_obj_assocs(p_obj_id NUMBER,
                        p_obj_cd VARCHAR2) IS
  SELECT using_object_type, using_object_id
  FROM  ams_object_associations
  WHERE master_object_type = p_obj_cd
        AND master_object_id = p_obj_id
        AND usage_type= 'CREATED';

  l_obj_assocs c_obj_assocs%ROWTYPE;

  CURSOR c_get_value (
    p_arc             VARCHAR2,
    p_id              NUMBER,
    p_category_id     NUMBER,
    p_sub_category_id NUMBER) IS
  SELECT max(func_actual_value),
         max(func_forecasted_value)
  FROM   ams_act_metrics_all a
  WHERE  arc_act_metric_used_by  = p_arc
  AND    act_metric_used_by_id   = p_id
  AND EXISTS (select 'x' from ams_metrics_all_b b
     where b.metric_id = a.metric_id
  AND    metric_category      = p_category_id
  AND    metric_sub_category  = p_sub_category_id);

BEGIN

  OPEN c_act_metric_row(p_act_met_id);
  FETCH c_act_metric_row INTO l_act_metric_row;
  IF c_act_metric_row%FOUND THEN
    IF l_act_metric_row.arc_act_metric_used_by='CAMP' THEN

      OPEN c_camp(l_act_metric_row.act_metric_used_by_id);
      LOOP
        FETCH c_camp INTO l_child_camp_id;
        EXIT WHEN c_camp%NOTFOUND;
        OPEN c_get_value(
          l_act_metric_row.arc_act_metric_used_by,
          l_child_camp_id,
          l_act_metric_row.metric_category,
          l_act_metric_row.metric_sub_category);
        FETCH c_get_value INTO l_actual_ret_value,l_forecas_ret_value;
        IF c_get_value%FOUND THEN
            l_actual_tot_value := l_actual_tot_value + l_actual_ret_value;
            l_forecas_tot_value := l_forecas_tot_value + l_forecas_ret_value;
        END IF;
          l_actual_ret_value  := 0;
          l_forecas_ret_value := 0;
        CLOSE c_get_value;
       END LOOP;
       CLOSE c_camp;
    ELSIF l_act_metric_row.arc_act_metric_used_by ='EVEH' THEN

      OPEN c_even(l_act_metric_row.act_metric_used_by_id);
      LOOP
        FETCH c_even INTO l_child_event_id;
        EXIT WHEN c_even%NOTFOUND;
        OPEN c_get_value(
          'EVEO',
          l_child_event_id,
          l_act_metric_row.metric_category,
          l_act_metric_row.metric_sub_category);
        FETCH c_get_value INTO l_actual_ret_value, l_forecas_ret_value;
        IF c_get_value%FOUND THEN
            l_actual_tot_value := l_actual_tot_value + l_actual_ret_value;
            l_forecas_tot_value := l_forecas_tot_value + l_forecas_ret_value;
         END IF;
          l_actual_ret_value := 0;
          l_forecas_ret_value := 0;
        CLOSE c_get_value;
      END LOOP;
      CLOSE c_even;

    END IF;

    /*Look for associated objects with CREATED_FOR*/
    OPEN c_obj_assocs(l_act_metric_row.act_metric_used_by_id,
                      l_act_metric_row.arc_act_metric_used_by);
    LOOP
        FETCH c_obj_assocs INTO l_obj_assocs;
        EXIT WHEN c_obj_assocs%NOTFOUND;
        OPEN c_get_value(
          l_obj_assocs.using_object_type,
          l_obj_assocs.using_object_id,
          l_act_metric_row.metric_category,
          l_act_metric_row.metric_sub_category);
        FETCH c_get_value INTO l_actual_ret_value, l_forecas_ret_value;
        IF c_get_value%FOUND THEN
            l_actual_tot_value := l_actual_tot_value + l_actual_ret_value;
            l_forecas_tot_value := l_forecas_tot_value + l_forecas_ret_value;
        END IF;
          l_actual_ret_value := 0;
          l_forecas_ret_value := 0;
        CLOSE c_get_value;
      END LOOP;
    CLOSE c_obj_assocs;

    l_object_version_number := l_act_metric_row.object_version_number;
  END IF;
  CLOSE c_act_metric_row;

  AMS_ACTMETRIC_PVT.Init_ActMetric_Rec(x_act_metric_rec => l_metric_rec );
  l_metric_rec.act_metric_used_by_id := l_act_metric_row.act_metric_used_by_id;
  l_metric_rec.arc_act_metric_used_by := l_act_metric_row.arc_act_metric_used_by;
  l_metric_rec.metric_id := l_act_metric_row.metric_id;
  l_metric_rec.object_version_number := l_object_version_number;
  l_metric_rec.activity_metric_id := p_act_met_id;
  l_metric_rec.func_forecasted_value := l_forecas_tot_value;
  l_metric_rec.transaction_currency_code := l_act_metric_row.transaction_currency_code;
  l_metric_rec.sensitive_data_flag:='N';
  l_metric_rec.application_id:=530;

  Ams_ActMetric_pvt.Update_ActMetric (
    p_api_version => '1.0',
    p_commit=>FND_API.G_TRUE,
    x_return_status => l_return_status,
    x_msg_count => l_msg_count,
    x_msg_data => l_msg_data,
    p_act_metric_rec => l_metric_rec);

 RETURN l_actual_tot_value;

END get_rollup_value;

-----------------------------------------------------------------------

END ams_metriccustom_pvt;

/
