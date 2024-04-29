--------------------------------------------------------
--  DDL for Package Body BIX_ALERT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIX_ALERT" AS
/* $Header: BIXPALRB.pls 115.9 2003/01/10 00:31:22 achanda ship $ */

FUNCTION Calculate_Actual
( p_Organization_ID   NUMBER
, p_period_set_Name   VARCHAR2
, p_time_period       VARCHAR2
)
RETURN NUMBER

IS
l_actual_value NUMBER;

BEGIN

  l_actual_value := 0;
  RETURN l_actual_value;

EXCEPTION
  WHEN OTHERS THEN
  l_actual_value := -1;

END Calculate_Actual;


FUNCTION Get_Target
( p_computed_target_short_name VARCHAR2
)
RETURN NUMBER
IS
l_target NUMBER;
BEGIN
NULL;

EXCEPTION
  WHEN OTHERS THEN
  l_target := -99999;

END Get_Target;

PROCEDURE Start_Corrective_Action
( p_wf_process        VARCHAR2
, p_wf_item_type      VARCHAR2
, p_message           VARCHAR2
, p_notify_resp       VARCHAR2
, p_report_name1      VARCHAR2
, p_report_param1     VARCHAR2
, p_responsibility_id NUMBER
, p_msg_subject       VARCHAR2
)
IS
l_message       VARCHAR2(250);
l_subject       VARCHAR2(250) ;
l_report_name1  VARCHAR2(250) DEFAULT NULL;
l_report_param1 VARCHAR2(250) DEFAULT NULL;
l_ret_status    VARCHAR2(1);
BEGIN

   -- DBMS_OUTPUT.PUT_LINE('message' || p_report_name1);
    l_report_name1 := p_report_name1;
  l_subject := p_msg_subject;
  BIS_UTIL.STRT_WF_PROCESS
  ( p_exception_message => p_message
  , p_msg_subject       => l_subject
  , p_exception_date    => SYSDATE
  , p_wf_process        => p_wf_process
  , p_item_type        => p_wf_item_type
  , p_report_name1      => l_report_name1
  , p_report_name2    => l_report_name1
  , p_report_name3    => l_report_name1
  , p_report_name4    => l_report_name1
  , p_report_param1     => p_report_param1
  , p_notify_resp_name  => p_notify_resp
  , p_report_resp1_id => p_responsibility_id
  , x_return_status     =>l_ret_status );
    --DBMS_OUTPUT.PUT_LINE('util proc tostart workflow called');
  IF l_ret_status = FND_API.G_RET_STS_SUCCESS then
 /*
   DBMS_OUTPUT.PUT_LINE('Corrective Action Started.  '||
                         p_notify_resp||' is notified.');
					*/
					null;
  ELSE
--  DBMS_OUTPUT.PUT_LINE('Failed to Start Corrective Action: '||l_ret_status);
    NULL;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
 --   DBMS_OUTPUT.PUT_LINE('Exception when Starting Corrective Action.');
  NULL;

END Start_Corrective_Action;
/* Alert for Abandon Calls */
PROCEDURE BIX_ABANDON_ALERT
( p_target_Level_Short_Name VARCHAR2
)
IS
l_period_set_name          VARCHAR2(15);
l_period_name              VARCHAR2(15);
l_target_level_rec      BIS_TARGET_LEVEL_PUB.Target_Level_Rec_Type;
l_user_selection_tbl       BIS_INDICATOR_REGION_PUB.Indicator_Region_Tbl_Type;
l_error_tbl                BIS_UTILITIES_PUB.Error_Tbl_Type;
l_actual                   NUMBER;
l_target                   NUMBER;
l_Target_Rec               BIS_TARGET_PUB.Target_Rec_Type;
l_Actual_Tbl               BIS_ACTUAL_PUB.Actual_Tbl_Type;
l_workflow_item_type       VARCHAR2(8);
l_workflow_process         VARCHAR2(30);
l_notify_resp              VARCHAR2(100);
l_responsibility_ID        NUMBER;
l_message                  VARCHAR2(250);
l_report                  VARCHAR2(250);
l_organization_ID          NUMBER;
l_organization_tbl         BIS_POSTACTUAL.t_orgTable;
l_msg_data                 VARCHAR2(250);
l_msg_count                NUMBER;
l_msg_subject              VARCHAR2(300);
l_return_status            VARCHAR2(1);
i                          NUMBER := 0;
l_center                   VARCHAR2(200);
CURSOR cr_actual IS
Select round(sum(abandoned_count)/sum(number_of_interactions)*100, 2) abandoned_level,
       to_char(hour,'MON-YYYY') month,
       interaction_center_id center_id
from   bix_sum_grp_cls
group by to_char(hour,'MON-YYYY'), interaction_center_id;
CURSOR cr_center(p_center_id NUMBER) IS
SELECT call_center_name center_name
FROM   bix_call_center_v
WHERE  call_center_id = p_center_id;

CURSOR cr_target(p_organization_id VARCHAR2,
                 p_center_id VARCHAR2, p_time VARCHAR2)
IS
  SELECT  tv.target_level_short_name
        , tv.target_level_name
	   , tv.target_level_id
        , tv.plan_name
        , tv.org_level_value_id
        , tv.time_level_value_id
        , tv.target
--        , tv.computed_target_short_name
        , tv.range1_low
        , tv.range1_high
        , tv.range2_low
        , tv.range2_high
        , tv.range3_low
        , tv.range3_high
        , tv.notify_resp1_id
        , tv.notify_resp1_short_name
        , tv.notify_resp2_id
        , tv.notify_resp2_short_name
        , tv.notify_resp3_id
        , tv.notify_resp3_short_name
        , tv.dim1_level_value_id
  FROM BISFV_TARGETS tv
  WHERE tv.target_level_short_name = p_target_level_short_name
  AND tv.time_level_value_id like '%' || p_time || '%'
  AND tv.org_level_value_id = p_organization_id
  AND tv.dim1_level_value_name = p_center_id;

BEGIN

      --dbms_output.put_line('In Abandon Call Rate Alert ');
  l_target_level_rec.target_Level_Short_Name
    := p_target_Level_Short_Name;
--  l_period_set_name := p_time_period;
--  l_period_name     := p_time_period;
  l_report     := 'BIXACAB0';
  FND_MESSAGE.SET_NAME('BIX', 'BIX_ABANDON_CALL_RATE');
  l_msg_subject := FND_MESSAGE.GET;
  IF l_msg_subject is NULL then
     l_msg_subject := 'Abandon Call Rate PMF Notification';
  END IF;
  l_organization_id := -1;
  -- Get the workflow process
  SELECT workflow_item_type, workflow_process_short_name
  INTO l_workflow_item_type, l_workflow_process
  FROM bisbv_target_levels
  WHERE target_level_short_name = p_target_level_short_name;

  -- Get the KPIs users have selected to monitor on their homepage
  BIS_ACTUAL_PUB.Retrieve_User_Selections
  ( p_api_version                  => 1.0
   ,p_Target_Level_Rec             => l_Target_Level_Rec
   ,x_Indicator_Region_Tbl         => l_user_selection_Tbl
   ,x_return_status                => l_return_status
   ,x_msg_count                    => l_msg_count
   ,x_msg_data                     => l_msg_data
   ,x_error_Tbl                    => l_error_tbl
  );

  -- Calculate Actual for all Months for All Call Centers
  FOR cr_a in cr_actual LOOP

    l_actual := cr_a.abandoned_level;
    for cr_c in cr_center(cr_a.center_id) LOOP
    l_center := cr_c.center_name;
    end loop;
    -- Post actual value for only those KPIs users have selected.
--    FOR i IN 1..l_user_selection_Tbl.COUNT LOOP
--      IF l_user_selection_tbl(i).Org_Level_Value_ID = l_organization_id THEN
/*
        l_Actual_Tbl(i).target_Level_Short_Name
          := p_target_level_short_name;
        l_Actual_Tbl(i).Org_Level_value_ID := l_organization_id;
        l_Actual_Tbl(i).time_Level_value_ID := cr_a.month;
        l_Actual_Tbl(i).Target_Level_ID := cr_a.month;
        l_Actual_Tbl(i).Actual := l_actual;

        BIS_ACTUAL_PUB.POST_ACTUAL
        ( p_api_version       => 1.0
         ,p_Actual_Rec        => l_actual_Tbl(i)
         ,x_return_status     => l_return_status
         ,x_msg_count         => l_msg_count
         ,x_msg_data          => l_msg_data
         ,x_error_tbl         => l_error_tbl
        );
	   */
--      END IF;
--    END LOOP;

    -- Check for exceptions and start corrective action

    FOR cr_t IN cr_target(l_organization_id, to_char(cr_a.center_id), cr_a.month
) LOOP

      IF cr_t.target IS NULL THEN
--        l_target := Get_Target(cr.computed_target_short_name);
        NULL;
      ELSE
        l_target := cr_t.target;
      END IF;
       l_Actual_Tbl(1).target_Level_Short_Name
			  := p_target_level_short_name;
       l_Actual_Tbl(1).Org_Level_value_ID := l_organization_id;
	  l_Actual_Tbl(1).time_Level_value_ID := cr_t.time_level_value_id;
	  l_Actual_Tbl(1).target_Level_ID := cr_t.target_level_id;
	  l_Actual_Tbl(1).Actual := l_actual;
          l_Actual_Tbl(1).dim1_Level_value_ID := cr_t.dim1_level_value_id;
          L_Actual_Tbl(1).target_level_name := cr_t.target_level_name;
BIS_ACTUAL_PUB.POST_ACTUAL
	   ( p_api_version       => 1.0
     	  ,p_Actual_Rec        => l_actual_Tbl(1)
		 ,x_return_status     => l_return_status
		,x_msg_count         => l_msg_count
	    ,x_msg_data          => l_msg_data
	   ,x_error_tbl         => l_error_tbl
);


      -- We're not on target....
      IF l_actual <> l_target THEN
         -- Check if actual is within the first range
        IF l_actual NOT BETWEEN
           cr_t.range2_low AND cr_t.range2_High
           AND l_actual BETWEEN
           cr_t.range1_low AND cr_t.range1_High
        THEN
           FND_MESSAGE.SET_NAME('BIX', 'BIX_PMF_RANGE1');
           FND_MESSAGE.SET_TOKEN('BIX_TARGET_NAME', cr_t.target_level_name);
           FND_MESSAGE.SET_TOKEN('BIX_CENTER', l_center);
           FND_MESSAGE.SET_TOKEN('BIX_TARGET', l_target);
           FND_MESSAGE.SET_TOKEN('BIX_ACTUAL', l_actual);
           FND_MESSAGE.SET_TOKEN('BIX_PLAN', cr_t.plan_name);
           FND_MESSAGE.SET_TOKEN('BIX_TIME', cr_a.month);
           l_message := FND_MESSAGE.GET;
           l_notify_resp := cr_t.Notify_Resp1_short_name;
           l_responsibility_id := cr_t.Notify_Resp1_ID;
          --dbms_output.put_line('In First Range');
        -- Check if actual is within the second range
        ELSIF l_actual NOT BETWEEN
           cr_t.range1_low AND cr_t.range1_High
           AND l_actual BETWEEN
           cr_t.range2_low AND cr_t.range2_High
        THEN
           FND_MESSAGE.SET_NAME('BIX', 'BIX_PMF_RANGE2');
           FND_MESSAGE.SET_TOKEN('BIX_TARGET_NAME', cr_t.target_level_name);
           FND_MESSAGE.SET_TOKEN('BIX_CENTER', l_center);
           FND_MESSAGE.SET_TOKEN('BIX_TARGET', l_target);
           FND_MESSAGE.SET_TOKEN('BIX_ACTUAL', l_actual);
           FND_MESSAGE.SET_TOKEN('BIX_PLAN', cr_t.plan_name);
           FND_MESSAGE.SET_TOKEN('BIX_TIME', cr_a.month);
           l_message := FND_MESSAGE.GET;
           l_notify_resp := cr_t.Notify_Resp1_short_name;
           l_responsibility_id := cr_t.Notify_Resp1_ID;
           --dbms_output.put_line('In Second Range');
        -- Check if actual is within the third range
        ELSIF l_actual NOT BETWEEN

           cr_t.range2_low AND cr_t.range2_High
           AND l_actual BETWEEN
           cr_t.range3_low AND cr_t.range3_High
        THEN
           FND_MESSAGE.SET_NAME('BIX', 'BIX_PMF_RANGE3');
           FND_MESSAGE.SET_TOKEN('BIX_TARGET_NAME', cr_t.target_level_name);
           FND_MESSAGE.SET_TOKEN('BIX_CENTER', l_center);
           FND_MESSAGE.SET_TOKEN('BIX_TARGET', l_target);
           FND_MESSAGE.SET_TOKEN('BIX_ACTUAL', l_actual);
           FND_MESSAGE.SET_TOKEN('BIX_PLAN', cr_t.plan_name);
           FND_MESSAGE.SET_TOKEN('BIX_TIME', cr_a.month);
           l_message := FND_MESSAGE.GET;
           l_notify_resp := cr_t.Notify_Resp2_short_name;
           l_responsibility_id := cr_t.Notify_Resp2_ID;
            --dbms_output.put_line('In Third Range');
        -- Check if actual is outside the third range
        ELSIF l_actual NOT BETWEEN
           cr_t.range3_low AND cr_t.range3_High
           AND l_actual > l_target
        THEN
           FND_MESSAGE.SET_NAME('BIX', 'BIX_PMF_OFFRANGE');
           FND_MESSAGE.SET_TOKEN('BIX_TARGET_NAME', cr_t.target_level_name);
           FND_MESSAGE.SET_TOKEN('BIX_CENTER', l_center);
           FND_MESSAGE.SET_TOKEN('BIX_TARGET', l_target);
           FND_MESSAGE.SET_TOKEN('BIX_ACTUAL', l_actual);
           FND_MESSAGE.SET_TOKEN('BIX_PLAN', cr_t.plan_name);
           FND_MESSAGE.SET_TOKEN('BIX_TIME', cr_a.month);
           l_message := FND_MESSAGE.GET;
           l_notify_resp := cr_t.Notify_Resp3_short_name;
           l_responsibility_id := cr_t.Notify_Resp3_ID;
          --dbms_output.put_line('Out of Third Range');
        ELSIF l_actual < l_target
        THEN
           FND_MESSAGE.SET_NAME('BIX', 'BIX_PMF_EXRANGE');
           FND_MESSAGE.SET_TOKEN('BIX_TARGET_NAME', cr_t.target_level_name);
           FND_MESSAGE.SET_TOKEN('BIX_CENTER', l_center);
           FND_MESSAGE.SET_TOKEN('BIX_TARGET', l_target);
           FND_MESSAGE.SET_TOKEN('BIX_ACTUAL', l_actual);
           FND_MESSAGE.SET_TOKEN('BIX_PLAN', cr_t.plan_name);
           FND_MESSAGE.SET_TOKEN('BIX_TIME', cr_a.month);
           l_message := FND_MESSAGE.GET;
           l_notify_resp := cr_t.Notify_Resp3_short_name;
           l_responsibility_id := cr_t.Notify_Resp3_ID;
          --dbms_output.put_line('less than First Range');
        END IF;

      -- We're on target!!
      ELSE
           FND_MESSAGE.SET_NAME('BIX', 'BIX_PMF_INRANGE');
           FND_MESSAGE.SET_TOKEN('BIX_TARGET_NAME', cr_t.target_level_name);
           FND_MESSAGE.SET_TOKEN('BIX_CENTER', l_center);
           FND_MESSAGE.SET_TOKEN('BIX_TARGET', l_target);
           FND_MESSAGE.SET_TOKEN('BIX_ACTUAL', l_actual);
           FND_MESSAGE.SET_TOKEN('BIX_PLAN', cr_t.plan_name);
           FND_MESSAGE.SET_TOKEN('BIX_TIME', cr_a.month);
           l_message := FND_MESSAGE.GET;
        l_notify_resp := cr_t.Notify_Resp1_short_name;
        l_responsibility_id := cr_t.Notify_Resp1_ID;
      END IF;
/*
     dbms_output.put_line('Calling Corrective Action' || cr_a.month ||
          l_responsibility_id || l_notify_resp || l_workflow_process ||
          l_workflow_item_type || l_message );
*/
      Start_Corrective_Action
      ( p_wf_process        => l_workflow_process
      , p_wf_item_type => l_workflow_item_type
      , p_message           => l_message
      , p_notify_resp       => l_notify_resp
      , p_report_name1      => l_report
      , p_report_param1     => NULL
      , p_responsibility_id => l_responsibility_id
      , p_msg_subject       => l_msg_subject
      );
    END LOOP;  -- ends loop to check targets
  END LOOP;    -- ends loop to calculate actual

EXCEPTION
  WHEN OTHERS THEN
  l_message := 'Exception in Abandon Alert Procedure.';
  --dbms_output.put_line(l_message);

END BIX_ABANDON_ALERT;

/* Alert for Service Level PMF */
PROCEDURE BIX_SERLVL_ALERT
( p_target_Level_Short_Name VARCHAR2
)
IS
l_period_set_name          VARCHAR2(15);
l_period_name              VARCHAR2(15);
l_target_level_rec      BIS_TARGET_LEVEL_PUB.Target_Level_Rec_Type;
l_user_selection_tbl       BIS_INDICATOR_REGION_PUB.Indicator_Region_Tbl_Type;
l_error_tbl                BIS_UTILITIES_PUB.Error_Tbl_Type;
l_actual                   NUMBER;
l_target                   NUMBER;
l_Target_Rec               BIS_TARGET_PUB.Target_Rec_Type;
l_Actual_Tbl               BIS_ACTUAL_PUB.Actual_Tbl_Type;
l_workflow_item_type       VARCHAR2(8);
l_workflow_process         VARCHAR2(30);
l_notify_resp              VARCHAR2(100);
l_responsibility_ID        NUMBER;
l_message                  VARCHAR2(250);
l_report                  VARCHAR2(250);
l_organization_ID          NUMBER;
l_organization_tbl         BIS_POSTACTUAL.t_orgTable;
l_msg_data                 VARCHAR2(250);
l_return_status            VARCHAR2(1);
l_msg_count                NUMBER;
l_msg_subject              VARCHAR2(300);
i                          NUMBER := 0;
l_center                   VARCHAR2(32);
CURSOR cr_actual IS
Select round(sum(interactions_answered_live)/sum(number_of_interactions)*100, 2) service_level,
       to_char(hour,'MON-YYYY') month,
       interaction_center_id center_id
from   bix_sum_grp_cls
group by to_char(hour,'MON-YYYY'), interaction_center_id;

CURSOR cr_center(p_center_id NUMBER) IS
SELECT call_center_name center_name
FROM   bix_call_center_v
WHERE  call_center_id = p_center_id;

CURSOR cr_target(p_organization_id VARCHAR2, p_center_id VARCHAR2,p_time VARCHAR2) IS
  SELECT  tv.target_level_short_name
        , tv.target_level_name
        , tv.target_level_id
        , tv.plan_name
        , tv.org_level_value_id
        , tv.time_level_value_id
        , tv.target
--        , tv.computed_target_short_name
        , tv.range1_low
        , tv.range1_high
        , tv.range2_low
        , tv.range2_high
        , tv.range3_low
        , tv.range3_high
        , tv.notify_resp1_id
        , tv.notify_resp1_short_name
        , tv.notify_resp2_id
        , tv.notify_resp2_short_name
        , tv.notify_resp3_id
        , tv.notify_resp3_short_name
        , tv.dim1_level_value_id
  FROM BISFV_TARGETS tv
  WHERE tv.target_level_short_name = p_target_level_short_name
  AND tv.time_level_value_id like '%' || p_time || '%'
  AND tv.org_level_value_id = p_organization_id
  AND tv.dim1_level_value_name = p_center_id;

BEGIN

  l_target_level_rec.target_Level_Short_Name
    := p_target_Level_Short_Name;
--  l_period_set_name := p_time_period;
--  l_period_name     := p_time_period;
  l_report     := 'BIXSLVL0';
-- Get translated subject for notification
  FND_MESSAGE.SET_NAME('BIX', 'BIX_SERVICE_LEVEL');
  l_msg_subject := FND_MESSAGE.GET;
  IF l_msg_subject is NULL then
     l_msg_subject := 'Service Level PMF Notification';
  END IF;
  l_organization_id := -1;
  -- Get the workflow process
  SELECT workflow_item_type, workflow_process_short_name
  INTO l_workflow_item_type, l_workflow_process
  FROM bisbv_target_levels
  WHERE target_level_short_name = p_target_level_short_name;

  -- Get the KPIs users have selected to monitor on their homepage
  BIS_ACTUAL_PUB.Retrieve_User_Selections
  ( p_api_version                  => 1.0
   ,p_Target_Level_Rec             => l_Target_Level_Rec
   ,x_Indicator_Region_Tbl         => l_user_selection_Tbl
   ,x_return_status                => l_return_status
   ,x_msg_count                    => l_msg_count
   ,x_msg_data                     => l_msg_data
   ,x_error_Tbl                    => l_error_tbl
  );
 -- Calculate Actual for all Months for All Call Centers
  FOR cr_a in cr_actual LOOP

    l_actual := cr_a.service_level;
    for cr_c in cr_center(cr_a.center_id) LOOP
    l_center := cr_c.center_name;
    end loop;
    -- Post actual value for only those KPIs users have selected.
--    FOR i IN 1..l_user_selection_Tbl.COUNT LOOP
--      IF l_user_selection_tbl(i).organization_id = l_organization_id THEN
--      END IF;
--    END LOOP;

    -- Check for exceptions and start corrective action
    FOR cr_t IN cr_target(l_organization_id,to_char(cr_a.center_id), cr_a.month) LOOP

      IF cr_t.target IS NULL THEN
--        l_target := Get_Target(cr.computed_target_short_name);
        NULL;
      ELSE
        l_target := cr_t.target;
      END IF;
      l_Actual_Tbl(1).target_Level_Short_Name
                     := p_target_level_short_name;
      l_Actual_Tbl(1).Org_Level_value_ID := l_organization_id;
      l_Actual_Tbl(1).time_Level_value_ID := cr_t.time_level_value_id;
      l_Actual_Tbl(1).target_Level_ID := cr_t.target_level_id;
      l_Actual_Tbl(1).Actual := l_actual;
      l_Actual_Tbl(1).dim1_Level_value_ID := cr_t.dim1_level_value_id;
      l_Actual_Tbl(1).target_level_name := cr_t.target_level_name;
      BIS_ACTUAL_PUB.POST_ACTUAL
           ( p_api_version       => 1.0
             ,p_Actual_Rec        => l_actual_Tbl(1)
             ,x_return_status     => l_return_status
             ,x_msg_count         => l_msg_count
             ,x_msg_data          => l_msg_data
             ,x_error_tbl         => l_error_tbl
            );
      -- We're not on target....
      IF l_actual <> l_target THEN
         -- Check if actual is within the first range
        IF l_actual NOT BETWEEN
           cr_t.range2_low AND cr_t.range2_High
           AND l_actual BETWEEN
           cr_t.range1_low AND cr_t.range1_High
        THEN
           FND_MESSAGE.SET_NAME('BIX', 'BIX_PMF_RANGE1');
           FND_MESSAGE.SET_TOKEN('BIX_TARGET_NAME', cr_t.target_level_name);
           FND_MESSAGE.SET_TOKEN('BIX_CENTER', l_center);
           FND_MESSAGE.SET_TOKEN('BIX_TARGET', l_target);
           FND_MESSAGE.SET_TOKEN('BIX_ACTUAL', l_actual);
           FND_MESSAGE.SET_TOKEN('BIX_PLAN', cr_t.plan_name);
           FND_MESSAGE.SET_TOKEN('BIX_TIME', cr_a.month);
           l_message := FND_MESSAGE.GET;
           l_notify_resp := cr_t.Notify_Resp1_short_name;
           l_responsibility_id := cr_t.Notify_Resp1_ID;
         --  dbms_output.put_line('In First Range' || l_message);
        -- Check if actual is within the second range
        ELSIF l_actual NOT BETWEEN
           cr_t.range1_low AND cr_t.range1_High
           AND l_actual BETWEEN
           cr_t.range2_low AND cr_t.range2_High
        THEN
           FND_MESSAGE.SET_NAME('BIX', 'BIX_PMF_RANGE2');
           FND_MESSAGE.SET_TOKEN('BIX_TARGET_NAME', cr_t.target_level_name);
           FND_MESSAGE.SET_TOKEN('BIX_CENTER', l_center);
           FND_MESSAGE.SET_TOKEN('BIX_TARGET', l_target);
           FND_MESSAGE.SET_TOKEN('BIX_ACTUAL', l_actual);
           FND_MESSAGE.SET_TOKEN('BIX_PLAN', cr_t.plan_name);
           FND_MESSAGE.SET_TOKEN('BIX_TIME', cr_a.month);
           l_message := FND_MESSAGE.GET;
           l_notify_resp := cr_t.Notify_Resp1_short_name;
           l_responsibility_id := cr_t.Notify_Resp1_ID;
           --dbms_output.put_line('In Second Range');
        -- Check if actual is within the third range
        ELSIF l_actual NOT BETWEEN
           cr_t.range2_low AND cr_t.range2_High
           AND l_actual BETWEEN
           cr_t.range3_low AND cr_t.range3_High
        THEN
           FND_MESSAGE.SET_NAME('BIX', 'BIX_PMF_RANGE3');
           FND_MESSAGE.SET_TOKEN('BIX_TARGET_NAME', cr_t.target_level_name);
           FND_MESSAGE.SET_TOKEN('BIX_CENTER', l_center);
           FND_MESSAGE.SET_TOKEN('BIX_TARGET', l_target);
           FND_MESSAGE.SET_TOKEN('BIX_ACTUAL', l_actual);
           FND_MESSAGE.SET_TOKEN('BIX_PLAN', cr_t.plan_name);
           FND_MESSAGE.SET_TOKEN('BIX_TIME', cr_a.month);
           l_message := FND_MESSAGE.GET;
           l_notify_resp := cr_t.Notify_Resp2_short_name;
           l_responsibility_id := cr_t.Notify_Resp2_ID;
            --dbms_output.put_line('In Third Range');
        -- Check if actual is outside the third range
        ELSIF l_actual NOT BETWEEN
           cr_t.range3_low AND cr_t.range3_High
           AND l_actual < l_target
        THEN
           FND_MESSAGE.SET_NAME('BIX', 'BIX_PMF_OFFRANGE');
           FND_MESSAGE.SET_TOKEN('BIX_TARGET_NAME', cr_t.target_level_name);
           FND_MESSAGE.SET_TOKEN('BIX_CENTER', l_center);
           FND_MESSAGE.SET_TOKEN('BIX_TARGET', l_target);
           FND_MESSAGE.SET_TOKEN('BIX_ACTUAL', l_actual);
           FND_MESSAGE.SET_TOKEN('BIX_PLAN', cr_t.plan_name);
           FND_MESSAGE.SET_TOKEN('BIX_TIME', cr_a.month);
           l_message := FND_MESSAGE.GET;
           l_notify_resp := cr_t.Notify_Resp3_short_name;
           l_responsibility_id := cr_t.Notify_Resp3_ID;
          --dbms_output.put_line('Out of Third Range');
        ELSIF l_actual > l_target
        THEN
           FND_MESSAGE.SET_NAME('BIX', 'BIX_PMF_EXRANGE');
           FND_MESSAGE.SET_TOKEN('BIX_TARGET_NAME', cr_t.target_level_name);
           FND_MESSAGE.SET_TOKEN('BIX_CENTER', l_center);
           FND_MESSAGE.SET_TOKEN('BIX_TARGET', l_target);
           FND_MESSAGE.SET_TOKEN('BIX_ACTUAL', l_actual);
           FND_MESSAGE.SET_TOKEN('BIX_PLAN', cr_t.plan_name);
           FND_MESSAGE.SET_TOKEN('BIX_TIME', cr_a.month);
           l_message := FND_MESSAGE.GET;
           l_notify_resp := cr_t.Notify_Resp3_short_name;
           l_responsibility_id := cr_t.Notify_Resp3_ID;
          --dbms_output.put_line('less than First Range');
        END IF;

      -- We're on target!!
      ELSE
           FND_MESSAGE.SET_NAME('BIX', 'BIX_PMF_INRANGE');
           FND_MESSAGE.SET_TOKEN('BIX_TARGET_NAME', cr_t.target_level_name);
           FND_MESSAGE.SET_TOKEN('BIX_CENTER', l_center);
           FND_MESSAGE.SET_TOKEN('BIX_TARGET', l_target);
           FND_MESSAGE.SET_TOKEN('BIX_ACTUAL', l_actual);
           FND_MESSAGE.SET_TOKEN('BIX_PLAN', cr_t.plan_name);
           FND_MESSAGE.SET_TOKEN('BIX_TIME', cr_a.month);
           l_message := FND_MESSAGE.GET;
        l_notify_resp := cr_t.Notify_Resp1_short_name;
        l_responsibility_id := cr_t.Notify_Resp1_ID;
      END IF;
--dbms_output.put_line('Calling Corrective Action');

--dbms_output.put_line( l_msg_subject);

      Start_Corrective_Action
      ( p_wf_process        => l_workflow_process
      , p_wf_item_type => l_workflow_item_type
      , p_message           => l_message
      , p_notify_resp       => l_notify_resp
      , p_report_name1      => l_report
      , p_report_param1     => NULL
      , p_responsibility_id => l_responsibility_id
      , p_msg_subject => l_msg_subject
      );

    END LOOP;  -- ends loop to check targets
  END LOOP;    -- ends loop to calculate actual

EXCEPTION
  WHEN OTHERS THEN
  l_message := 'Exception in Alert Procedure.';
  --dbms_output.put_line(l_message);

END BIX_SERLVL_ALERT;


PROCEDURE BIX_AVGANS_ALERT
( p_target_Level_Short_Name VARCHAR2
)
IS
l_period_set_name          VARCHAR2(15);
l_period_name              VARCHAR2(15);
l_target_level_rec      BIS_TARGET_LEVEL_PUB.Target_Level_Rec_Type;
l_user_selection_tbl       BIS_INDICATOR_REGION_PUB.Indicator_Region_Tbl_Type;
l_error_tbl                BIS_UTILITIES_PUB.Error_Tbl_Type;
l_actual                   NUMBER;
l_target                   NUMBER;
l_Target_Rec               BIS_TARGET_PUB.Target_Rec_Type;
l_Actual_Tbl               BIS_ACTUAL_PUB.Actual_Tbl_Type;
l_workflow_item_type       VARCHAR2(8);
l_workflow_process         VARCHAR2(30);
l_notify_resp              VARCHAR2(100);
l_responsibility_ID        NUMBER;
l_message                  VARCHAR2(250);
l_report                  VARCHAR2(250);
l_organization_ID          NUMBER;
l_organization_tbl         BIS_POSTACTUAL.t_orgTable;
l_msg_data                 VARCHAR2(250);
l_msg_subject              VARCHAR2(300);
l_return_status            VARCHAR2(1);
l_msg_count                NUMBER;
i                          NUMBER := 0;
l_center                   VARCHAR2(200);
CURSOR cr_actual IS
Select round(sum(speed_to_answer)/sum(number_of_interactions), 2) avg_speed_to_answer,
       to_char(hour,'MON-YYYY') month,
       interaction_center_id center_id
from   bix_sum_grp_cls
group by to_char(hour,'MON-YYYY'), interaction_center_id;
CURSOR cr_center(p_center_id NUMBER) IS
SELECT call_center_name center_name
FROM   bix_call_center_v
WHERE  call_center_id = p_center_id;

CURSOR cr_target(p_organization_id VARCHAR2, p_center_id VARCHAR2, p_time VARCHAR2) IS
  SELECT  tv.target_level_short_name
        , tv.target_level_name
        , tv.target_level_id
        , tv.plan_name
        , tv.org_level_value_id
        , tv.time_level_value_id
        , tv.target
--        , tv.computed_target_short_name
        , tv.range1_low
        , tv.range1_high
        , tv.range2_low
        , tv.range2_high
        , tv.range3_low
        , tv.range3_high
        , tv.notify_resp1_id
        , tv.notify_resp1_short_name
        , tv.notify_resp2_id
        , tv.notify_resp2_short_name
        , tv.notify_resp3_id
        , tv.notify_resp3_short_name
        , tv.dim1_level_value_id
  FROM BISFV_TARGETS tv
  WHERE tv.target_level_short_name = p_target_level_short_name
  AND tv.time_level_value_id like '%' || p_time || '%'
  AND tv.org_level_value_id = p_organization_id
  AND tv.dim1_level_value_name = p_center_id;

BEGIN

  l_target_level_rec.target_Level_Short_Name
    := p_target_Level_Short_Name;
--  l_period_set_name := p_time_period;
--  l_period_name     := p_time_period;
  l_report     := 'BIXASPB0';
-- Get translated subject from fnd message dictionary
  FND_MESSAGE.SET_NAME('BIX','BIX_AVG_SPEED_ANSWER');
--  l_msg_subject := 'Average Speed to Answer PMF Notification';
  l_msg_subject := FND_MESSAGE.GET;
  l_organization_id := -1;
  -- Get the workflow process
  SELECT workflow_item_type, workflow_process_short_name
  INTO l_workflow_item_type, l_workflow_process
  FROM bisbv_target_levels
  WHERE target_level_short_name = p_target_level_short_name;

  -- Get the KPIs users have selected to monitor on their homepage
  BIS_ACTUAL_PUB.Retrieve_User_Selections
  ( p_api_version                  => 1.0
   ,p_Target_Level_Rec             => l_Target_Level_Rec
   ,x_Indicator_Region_Tbl         => l_user_selection_Tbl
   ,x_return_status                => l_return_status
   ,x_msg_count                    => l_msg_count
   ,x_msg_data                     => l_msg_data
   ,x_error_Tbl                    => l_error_tbl
  );

  -- Calculate Actual for all Months for All Call Centers
  FOR cr_a in cr_actual LOOP

    l_actual := cr_a.avg_speed_to_answer;
    for cr_c in cr_center(cr_a.center_id) LOOP
    l_center := cr_c.center_name;
    end loop;
    -- Post actual value for only those KPIs users have selected.
--    FOR i IN 1..l_user_selection_Tbl.COUNT LOOP
--      IF l_user_selection_tbl(i).organization_id = l_organization_id THEN
--      END IF;
--    END LOOP;

    -- Check for exceptions and start corrective action
    FOR cr_t IN cr_target(l_organization_id, to_char(cr_a.center_id), cr_a.month) LOOP

      IF cr_t.target IS NULL THEN
--        l_target := Get_Target(cr.computed_target_short_name);
        NULL;
      ELSE
        l_target := cr_t.target;
      END IF;
      l_Actual_Tbl(1).target_Level_Short_Name
                     := p_target_level_short_name;
      l_Actual_Tbl(1).Org_Level_value_ID := l_organization_id;
      l_Actual_Tbl(1).time_Level_value_ID := cr_t.time_level_value_id;
      l_Actual_Tbl(1).target_Level_ID := cr_t.target_level_id;
      l_Actual_Tbl(1).Actual := l_actual;
      l_Actual_Tbl(1).dim1_Level_value_ID := cr_t.dim1_level_value_id;
      l_Actual_Tbl(1).target_level_name := cr_t.target_level_name;
      BIS_ACTUAL_PUB.POST_ACTUAL
           ( p_api_version       => 1.0
             ,p_Actual_Rec        => l_actual_Tbl(1)
             ,x_return_status     => l_return_status
             ,x_msg_count         => l_msg_count
             ,x_msg_data          => l_msg_data
             ,x_error_tbl         => l_error_tbl
            );
      -- We're not on target....
      IF l_actual <> l_target THEN
         -- Check if actual is within the first range
        IF l_actual NOT BETWEEN
           cr_t.range2_low AND cr_t.range2_High
           AND l_actual BETWEEN
           cr_t.range1_low AND cr_t.range1_High
        THEN
           FND_MESSAGE.SET_NAME('BIX', 'BIX_PMF_RANGE1');
           FND_MESSAGE.SET_TOKEN('BIX_TARGET_NAME', cr_t.target_level_name);
           FND_MESSAGE.SET_TOKEN('BIX_CENTER', l_center);
           FND_MESSAGE.SET_TOKEN('BIX_TARGET', l_target);
           FND_MESSAGE.SET_TOKEN('BIX_ACTUAL', l_actual);
           FND_MESSAGE.SET_TOKEN('BIX_PLAN', cr_t.plan_name);
           FND_MESSAGE.SET_TOKEN('BIX_TIME', cr_a.month);
           l_message := FND_MESSAGE.GET;
/*
           l_message := 'Hey! Something is wrong!'||' '||
                        'Target Level: '||cr_t.target_level_name||' '||
                        'Business Plan: '||cr_t.plan_name||' '|| ' for '||
                         l_center || ' for ' || cr_a.month || ' ' ||
                        'Target is: '||l_target||' '||
                        'Actual is: '||l_actual;
*/
           l_notify_resp := cr_t.Notify_Resp1_short_name;
           l_responsibility_id := cr_t.Notify_Resp1_ID;
         --  dbms_output.put_line('In First Range' || l_message);
        -- Check if actual is within the second range
        ELSIF l_actual NOT BETWEEN
           cr_t.range1_low AND cr_t.range1_High
           AND l_actual BETWEEN
           cr_t.range2_low AND cr_t.range2_High
        THEN
           FND_MESSAGE.SET_NAME('BIX', 'BIX_PMF_RANGE2');
           FND_MESSAGE.SET_TOKEN('BIX_TARGET_NAME', cr_t.target_level_name);
           FND_MESSAGE.SET_TOKEN('BIX_CENTER', l_center);
           FND_MESSAGE.SET_TOKEN('BIX_TARGET', l_target);
           FND_MESSAGE.SET_TOKEN('BIX_ACTUAL', l_actual);
           FND_MESSAGE.SET_TOKEN('BIX_PLAN', cr_t.plan_name);
           FND_MESSAGE.SET_TOKEN('BIX_TIME', cr_a.month);
           l_message := FND_MESSAGE.GET;
/*
           l_message := 'Hey! Something is wrong!'||' '||
                        'Target Level: '||cr_t.target_level_name||' '||
                        'Business Plan: '||cr_t.plan_name||' '||  ' for '||
                         l_center || ' for ' || cr_a.month || ' '||
                        'Target is: '||l_target||' '||
                        'Actual is: '||l_actual;
*/
           l_notify_resp := cr_t.Notify_Resp1_short_name;
           l_responsibility_id := cr_t.Notify_Resp1_ID;
           --dbms_output.put_line('In Second Range');
        -- Check if actual is within the third range
        ELSIF l_actual NOT BETWEEN
           cr_t.range2_low AND cr_t.range2_High
           AND l_actual BETWEEN
           cr_t.range3_low AND cr_t.range3_High
        THEN
           FND_MESSAGE.SET_NAME('BIX', 'BIX_PMF_RANGE3');
           FND_MESSAGE.SET_TOKEN('BIX_TARGET_NAME', cr_t.target_level_name);
           FND_MESSAGE.SET_TOKEN('BIX_CENTER', l_center);
           FND_MESSAGE.SET_TOKEN('BIX_TARGET', l_target);
           FND_MESSAGE.SET_TOKEN('BIX_ACTUAL', l_actual);
           FND_MESSAGE.SET_TOKEN('BIX_PLAN', cr_t.plan_name);
           FND_MESSAGE.SET_TOKEN('BIX_TIME', cr_a.month);
           l_message := FND_MESSAGE.GET;
/*
           l_message := 'Hey! Something is VERY wrong!'||' '||
                        'Target Level: '||cr_t.target_level_name||' '||
                        'Business Plan: '||cr_t.plan_name||' '|| ' for '||
                          l_center || ' for ' || cr_a.month || ' '||
                        'Target is: '||l_target||' '||
                        'Actual is: '||l_actual;
*/
           l_notify_resp := cr_t.Notify_Resp2_short_name;
           l_responsibility_id := cr_t.Notify_Resp2_ID;
            --dbms_output.put_line('In Third Range');
        -- Check if actual is outside the third range
        ELSIF l_actual NOT BETWEEN
           cr_t.range3_low AND cr_t.range3_High
           AND  l_actual > l_target
        THEN
           FND_MESSAGE.SET_NAME('BIX', 'BIX_PMF_OFFRANGE');
           FND_MESSAGE.SET_TOKEN('BIX_TARGET_NAME', cr_t.target_level_name);
           FND_MESSAGE.SET_TOKEN('BIX_CENTER', l_center);
           FND_MESSAGE.SET_TOKEN('BIX_TARGET', l_target);
           FND_MESSAGE.SET_TOKEN('BIX_ACTUAL', l_actual);
           FND_MESSAGE.SET_TOKEN('BIX_PLAN', cr_t.plan_name);
           FND_MESSAGE.SET_TOKEN('BIX_TIME', cr_a.month);
           l_message := FND_MESSAGE.GET;
/*
           l_message := 'Hey! Something is VERY VERY wrong!'||' '||
                        'Target Level: '||cr_t.target_level_name||' '||
                        'Business Plan: '||cr_t.plan_name||' '|| ' for '||
                          l_center || ' for ' || cr_a.month || ' ' ||
                        'Target is: '||l_target||' '||
                        'Actual is: '||l_actual;
*/
           l_notify_resp := cr_t.Notify_Resp3_short_name;
           l_responsibility_id := cr_t.Notify_Resp3_ID;
          --dbms_output.put_line('Out of Third Range');
        ELSIF l_actual < l_target
        THEN
           FND_MESSAGE.SET_NAME('BIX', 'BIX_PMF_EXRANGE');
           FND_MESSAGE.SET_TOKEN('BIX_TARGET_NAME', cr_t.target_level_name);
           FND_MESSAGE.SET_TOKEN('BIX_CENTER', l_center);
           FND_MESSAGE.SET_TOKEN('BIX_TARGET', l_target);
           FND_MESSAGE.SET_TOKEN('BIX_ACTUAL', l_actual);
           FND_MESSAGE.SET_TOKEN('BIX_PLAN', cr_t.plan_name);
           FND_MESSAGE.SET_TOKEN('BIX_TIME', cr_a.month);
           l_message := FND_MESSAGE.GET;
/*
           l_message := 'Excellent '||' '||
                        'Target Level: '||cr_t.target_level_name||' '||
                        'Business Plan: '||cr_t.plan_name||' '|| ' for '||
                        l_center || ' for ' || cr_a.month || ' ' ||
                        'Target is: '||l_target||' '||
                        'Actual is: '||l_actual;
*/
           l_notify_resp := cr_t.Notify_Resp3_short_name;
           l_responsibility_id := cr_t.Notify_Resp3_ID;
          --dbms_output.put_line('less than First Range');
        END IF;

      -- We're on target!!
      ELSE
           FND_MESSAGE.SET_NAME('BIX', 'BIX_PMF_INRANGE');
           FND_MESSAGE.SET_TOKEN('BIX_TARGET_NAME', cr_t.target_level_name);
           FND_MESSAGE.SET_TOKEN('BIX_CENTER', l_center);
           FND_MESSAGE.SET_TOKEN('BIX_TARGET', l_target);
           FND_MESSAGE.SET_TOKEN('BIX_ACTUAL', l_actual);
           FND_MESSAGE.SET_TOKEN('BIX_PLAN', cr_t.plan_name);
           FND_MESSAGE.SET_TOKEN('BIX_TIME', cr_a.month);
           l_message := FND_MESSAGE.GET;
/*
        l_message := 'Good job!!'||' '||
                        'Target Level: '||cr_t.target_level_name||' '||
                        'Business Plan: '||cr_t.plan_name||' '|| ' for '||
                         l_center || ' for ' || cr_a.month || ' ' ||
                        'Target is: '||l_target||' '||
                        'Actual is: '||l_actual;
*/
        l_notify_resp := cr_t.Notify_Resp1_short_name;
        l_responsibility_id := cr_t.Notify_Resp1_ID;
      END IF;

--dbms_output.put_line( l_report);
/*
dbms_output.put_line('Calling Corrective Action' || cr_a.month ||l_responsibility_id || l_notify_resp || l_workflow_process || l_workflow_item_type || l_message);
 */
      Start_Corrective_Action
      ( p_wf_process        => l_workflow_process
      , p_wf_item_type => l_workflow_item_type
      , p_message           => l_message
      , p_notify_resp       => l_notify_resp
      , p_report_name1      => l_report
      , p_report_param1     => NULL
      , p_responsibility_id => l_responsibility_id
      , p_msg_subject       => l_msg_subject
      );

    END LOOP;  -- ends loop to check targets
  END LOOP;    -- ends loop to calculate actual

EXCEPTION
  WHEN OTHERS THEN
  l_message := 'Exception in Average Speed to Answer Alert Procedure.';
  --dbms_output.put_line(l_message);

END BIX_AVGANS_ALERT;
/* Alert for Occupancy Rate */
PROCEDURE BIX_OCCRATE_ALERT
( p_target_Level_Short_Name VARCHAR2
)
IS
l_period_set_name          VARCHAR2(15);
l_period_name              VARCHAR2(15);
l_target_level_rec      BIS_TARGET_LEVEL_PUB.Target_Level_Rec_Type;
l_user_selection_tbl       BIS_INDICATOR_REGION_PUB.Indicator_Region_Tbl_Type;
l_error_tbl                BIS_UTILITIES_PUB.Error_Tbl_Type;
l_actual                   NUMBER;
l_target                   NUMBER;
l_Target_Rec               BIS_TARGET_PUB.Target_Rec_Type;
l_Actual_Tbl               BIS_ACTUAL_PUB.Actual_Tbl_Type;
l_workflow_item_type       VARCHAR2(8);
l_workflow_process         VARCHAR2(30);
l_notify_resp              VARCHAR2(100);
l_responsibility_ID        NUMBER;
l_message                  VARCHAR2(250);
l_report                  VARCHAR2(250);
l_organization_ID          NUMBER;
l_organization_tbl         BIS_POSTACTUAL.t_orgTable;
l_msg_data                 VARCHAR2(250);
l_msg_count                NUMBER;
l_msg_subject              VARCHAR2(300);
l_return_status            VARCHAR2(1);
i                          NUMBER := 0;
l_center                   VARCHAR2(200);
CURSOR cr_actual IS
Select round(sum(talk_time)/sum(talk_time + idle_time)*100, 2) occupancy_rate,
       to_char(hour,'MON-YYYY') month,
       interaction_center_id center_id
from   bix_sum_grp_cls
group by to_char(hour,'MON-YYYY'), interaction_center_id;
CURSOR cr_center(p_center_id NUMBER) IS
SELECT call_center_name center_name
FROM   bix_call_center_v
WHERE  call_center_id = p_center_id;

CURSOR cr_target(p_organization_id VARCHAR2,
                 p_center_id VARCHAR2, p_time VARCHAR2)
IS
  SELECT  tv.target_level_short_name
        , tv.target_level_name
        , tv.target_level_id
        , tv.plan_name
        , tv.org_level_value_id
        , tv.time_level_value_id
        , tv.target
--        , tv.computed_target_short_name
        , tv.range1_low
        , tv.range1_high
        , tv.range2_low
        , tv.range2_high
        , tv.range3_low
        , tv.range3_high
        , tv.notify_resp1_id
        , tv.notify_resp1_short_name
        , tv.notify_resp2_id
        , tv.notify_resp2_short_name
        , tv.notify_resp3_id
        , tv.notify_resp3_short_name
        , tv.dim1_level_value_id
  FROM BISFV_TARGETS tv
  WHERE tv.target_level_short_name = p_target_level_short_name
  AND tv.time_level_value_id like '%' || p_time || '%'
  AND tv.org_level_value_id = p_organization_id
  AND tv.dim1_level_value_name = p_center_id;

BEGIN

  l_target_level_rec.target_Level_Short_Name
    := p_target_Level_Short_Name;
--  l_period_set_name := p_time_period;
--  l_period_name     := p_time_period;
  l_report     := 'BIXOCCM0';
/* get translated subject for notification */
  FND_MESSAGE.SET_NAME('BIX','BIX_OCCUPANCY_RATE');
  l_msg_subject := FND_MESSAGE.GET;
  if l_msg_subject is NULL THEN
      l_msg_subject := 'Occupancy Rate PMF Notification';
  end if;
  l_organization_id := -1;
  -- Get the workflow process
  SELECT workflow_item_type, workflow_process_short_name
  INTO l_workflow_item_type, l_workflow_process
  FROM bisbv_target_levels
  WHERE target_level_short_name = p_target_level_short_name;
  -- Get the KPIs users have selected to monitor on their homepage
  BIS_ACTUAL_PUB.Retrieve_User_Selections
  ( p_api_version                  => 1.0
   ,p_Target_Level_Rec             => l_Target_Level_Rec
   ,x_Indicator_Region_Tbl         => l_user_selection_Tbl
   ,x_return_status                => l_return_status
   ,x_msg_count                    => l_msg_count
   ,x_msg_data                     => l_msg_data
   ,x_error_Tbl                    => l_error_tbl
  );

  -- Calculate Actual for all Months for All Call Centers
  FOR cr_a in cr_actual LOOP

    l_actual := cr_a.occupancy_rate;
    for cr_c in cr_center(cr_a.center_id) LOOP
    l_center := cr_c.center_name;
    end loop;
    -- Post actual value for only those KPIs users have selected.
--    FOR i IN 1..l_user_selection_Tbl.COUNT LOOP
--      IF l_user_selection_tbl(i).organization_id = l_organization_id THEN
--      END IF;
--    END LOOP;

    -- Check for exceptions and start corrective action
   FOR cr_t IN cr_target(l_organization_id, to_char(cr_a.center_id), cr_a.month
) LOOP

      IF cr_t.target IS NULL THEN
--        l_target := Get_Target(cr.computed_target_short_name);
        NULL;
      ELSE
        l_target := cr_t.target;
      END IF;
      l_Actual_Tbl(1).target_Level_Short_Name
                     := p_target_level_short_name;
      l_Actual_Tbl(1).Org_Level_value_ID := l_organization_id;
      l_Actual_Tbl(1).time_Level_value_ID := cr_t.time_level_value_id;
      l_Actual_Tbl(1).target_Level_ID := cr_t.target_level_id;
      l_Actual_Tbl(1).Actual := l_actual;
      l_Actual_Tbl(1).dim1_Level_value_ID := cr_t.dim1_level_value_id;
      l_Actual_Tbl(1).target_level_name := cr_t.target_level_name;
      BIS_ACTUAL_PUB.POST_ACTUAL
           ( p_api_version       => 1.0
             ,p_Actual_Rec        => l_actual_Tbl(1)
             ,x_return_status     => l_return_status
             ,x_msg_count         => l_msg_count
             ,x_msg_data          => l_msg_data
             ,x_error_tbl         => l_error_tbl
            );
      -- We're not on target....
      IF l_actual <> l_target THEN
         -- Check if actual is within the first range
        IF l_actual NOT BETWEEN
           cr_t.range2_low AND cr_t.range2_High
           AND l_actual BETWEEN
           cr_t.range1_low AND cr_t.range1_High
        THEN
           FND_MESSAGE.SET_NAME('BIX', 'BIX_PMF_RANGE1');
           FND_MESSAGE.SET_TOKEN('BIX_TARGET_NAME', cr_t.target_level_name);
           FND_MESSAGE.SET_TOKEN('BIX_CENTER', l_center);
           FND_MESSAGE.SET_TOKEN('BIX_TARGET', l_target);
           FND_MESSAGE.SET_TOKEN('BIX_ACTUAL', l_actual);
           FND_MESSAGE.SET_TOKEN('BIX_PLAN', cr_t.plan_name);
           FND_MESSAGE.SET_TOKEN('BIX_TIME', cr_a.month);
           l_message := FND_MESSAGE.GET;
/*
           l_message := 'Hey! Something is wrong!'||' '||
                        'Target Level: '||cr_t.target_level_name||' '||
                        'Business Plan: '||cr_t.plan_name||' '|| ' for '||
                         l_center || ' for ' || cr_a.month || ' ' ||
                        'Target is: '||l_target||' '||
                        'Actual is: '||l_actual;
*/
           l_notify_resp := cr_t.Notify_Resp1_short_name;
           l_responsibility_id := cr_t.Notify_Resp1_ID;
         --  dbms_output.put_line('In First Range' || l_message);
        -- Check if actual is within the second range
        ELSIF l_actual NOT BETWEEN
           cr_t.range1_low AND cr_t.range1_High
           AND l_actual BETWEEN
           cr_t.range2_low AND cr_t.range2_High
        THEN
           FND_MESSAGE.SET_NAME('BIX', 'BIX_PMF_RANGE2');
           FND_MESSAGE.SET_TOKEN('BIX_TARGET_NAME', cr_t.target_level_name);
           FND_MESSAGE.SET_TOKEN('BIX_CENTER', l_center);
           FND_MESSAGE.SET_TOKEN('BIX_TARGET', l_target);
           FND_MESSAGE.SET_TOKEN('BIX_ACTUAL', l_actual);
           FND_MESSAGE.SET_TOKEN('BIX_PLAN', cr_t.plan_name);
           FND_MESSAGE.SET_TOKEN('BIX_TIME', cr_a.month);
           l_message := FND_MESSAGE.GET;
/*
           l_message := 'Hey! Something is wrong!'||' '||
                        'Target Level: '||cr_t.target_level_name||' '||
                        'Business Plan: '||cr_t.plan_name||' '||  ' for '||
                         l_center || ' for ' || cr_a.month || ' '||
                        'Target is: '||l_target||' '||
                        'Actual is: '||l_actual;
*/
           l_notify_resp := cr_t.Notify_Resp1_short_name;
           l_responsibility_id := cr_t.Notify_Resp1_ID;
           --dbms_output.put_line('In Second Range');
        -- Check if actual is within the third range
        ELSIF l_actual NOT BETWEEN

           cr_t.range2_low AND cr_t.range2_High
           AND l_actual BETWEEN
           cr_t.range3_low AND cr_t.range3_High
        THEN
           FND_MESSAGE.SET_NAME('BIX', 'BIX_PMF_RANGE3');
           FND_MESSAGE.SET_TOKEN('BIX_TARGET_NAME', cr_t.target_level_name);
           FND_MESSAGE.SET_TOKEN('BIX_CENTER', l_center);
           FND_MESSAGE.SET_TOKEN('BIX_TARGET', l_target);
           FND_MESSAGE.SET_TOKEN('BIX_ACTUAL', l_actual);
           FND_MESSAGE.SET_TOKEN('BIX_PLAN', cr_t.plan_name);
           FND_MESSAGE.SET_TOKEN('BIX_TIME', cr_a.month);
           l_message := FND_MESSAGE.GET;
/*
           l_message := 'Hey! Something is VERY wrong!'||' '||
                        'Target Level: '||cr_t.target_level_name||' '||
                        'Business Plan: '||cr_t.plan_name||' '|| ' for '||
                          l_center || ' for ' || cr_a.month || ' '||
                        'Target is: '||l_target||' '||
                        'Actual is: '||l_actual;
*/
           l_notify_resp := cr_t.Notify_Resp2_short_name;
           l_responsibility_id := cr_t.Notify_Resp2_ID;
            --dbms_output.put_line('In Third Range');
        -- Check if actual is outside the third range
        ELSIF l_actual NOT BETWEEN
           cr_t.range3_low AND cr_t.range3_High
           AND l_actual < l_target
        THEN
           FND_MESSAGE.SET_NAME('BIX', 'BIX_PMF_OFFRANGE');
           FND_MESSAGE.SET_TOKEN('BIX_TARGET_NAME', cr_t.target_level_name);
           FND_MESSAGE.SET_TOKEN('BIX_CENTER', l_center);
           FND_MESSAGE.SET_TOKEN('BIX_TARGET', l_target);
           FND_MESSAGE.SET_TOKEN('BIX_ACTUAL', l_actual);
           FND_MESSAGE.SET_TOKEN('BIX_PLAN', cr_t.plan_name);
           FND_MESSAGE.SET_TOKEN('BIX_TIME', cr_a.month);
           l_message := FND_MESSAGE.GET;
/*
           l_message := 'Hey! Something is VERY VERY wrong!'||' '||
                        'Target Level: '||cr_t.target_level_name||' '||
                        'Business Plan: '||cr_t.plan_name||' '|| ' for '||
                          l_center || ' for ' || cr_a.month || ' ' ||
                        'Target is: '||l_target||' '||
                       'Actual is: '||l_actual;
*/
           l_notify_resp := cr_t.Notify_Resp3_short_name;
           l_responsibility_id := cr_t.Notify_Resp3_ID;
          --dbms_output.put_line('Out of Third Range');
        ELSIF l_actual > l_target
        THEN
           FND_MESSAGE.SET_NAME('BIX', 'BIX_PMF_EXRANGE');
           FND_MESSAGE.SET_TOKEN('BIX_TARGET_NAME', cr_t.target_level_name);
           FND_MESSAGE.SET_TOKEN('BIX_CENTER', l_center);
           FND_MESSAGE.SET_TOKEN('BIX_TARGET', l_target);
           FND_MESSAGE.SET_TOKEN('BIX_ACTUAL', l_actual);
           FND_MESSAGE.SET_TOKEN('BIX_PLAN', cr_t.plan_name);
           FND_MESSAGE.SET_TOKEN('BIX_TIME', cr_a.month);
           l_message := FND_MESSAGE.GET;
/*
           l_message := 'Excellent '||' '||
                        'Target Level: '||cr_t.target_level_name||' '||
                        'Business Plan: '||cr_t.plan_name||' '|| ' for '||
                        l_center || ' for ' || cr_a.month || ' ' ||
                        'Target is: '||l_target||' '||
                        'Actual is: '||l_actual;
*/
           l_notify_resp := cr_t.Notify_Resp3_short_name;
           l_responsibility_id := cr_t.Notify_Resp3_ID;
          --dbms_output.put_line('less than First Range');
        END IF;

      -- We're on target!!
      ELSE
           FND_MESSAGE.SET_NAME('BIX', 'BIX_PMF_INRANGE');
           FND_MESSAGE.SET_TOKEN('BIX_TARGET_NAME', cr_t.target_level_name);
           FND_MESSAGE.SET_TOKEN('BIX_CENTER', l_center);
           FND_MESSAGE.SET_TOKEN('BIX_TARGET', l_target);
           FND_MESSAGE.SET_TOKEN('BIX_ACTUAL', l_actual);
           FND_MESSAGE.SET_TOKEN('BIX_PLAN', cr_t.plan_name);
           FND_MESSAGE.SET_TOKEN('BIX_TIME', cr_a.month);
           l_message := FND_MESSAGE.GET;
/*
        l_message := 'Good job!!'||' '||
                        'Target Level: '||cr_t.target_level_name||' '||
                        'Business Plan: '||cr_t.plan_name||' '|| ' for '||
                         l_center || ' for ' || cr_a.month || ' ' ||
                        'Target is: '||l_target||' '||
                        'Actual is: '||l_actual;
*/
        l_notify_resp := cr_t.Notify_Resp1_short_name;
        l_responsibility_id := cr_t.Notify_Resp1_ID;
      END IF;
/*
     dbms_output.put_line('Calling Corrective Action' || cr_a.month ||
          l_responsibility_id || l_notify_resp || l_workflow_process ||
          l_workflow_item_type || l_message );
*/
      Start_Corrective_Action
      ( p_wf_process        => l_workflow_process
      , p_wf_item_type => l_workflow_item_type
      , p_message           => l_message
      , p_notify_resp       => l_notify_resp
      , p_report_name1      => l_report
      , p_report_param1     => NULL
      , p_responsibility_id => l_responsibility_id
      , p_msg_subject       => l_msg_subject
      );
    END LOOP;  -- ends loop to check targets
  END LOOP;    -- ends loop to calculate actual

EXCEPTION
  WHEN OTHERS THEN
  l_message := 'Exception in Occupancy Rate Alert Procedure.';
  --dbms_output.put_line(l_message);

END BIX_OCCRATE_ALERT;
/* Alert Procedure for Average Talk Time */
PROCEDURE BIX_AVGTALK_ALERT
( p_target_Level_Short_Name VARCHAR2
)
IS
l_period_set_name          VARCHAR2(15);
l_period_name              VARCHAR2(15);
l_target_level_rec      BIS_TARGET_LEVEL_PUB.Target_Level_Rec_Type;
l_user_selection_tbl       BIS_INDICATOR_REGION_PUB.Indicator_Region_Tbl_Type;
l_error_tbl                BIS_UTILITIES_PUB.Error_Tbl_Type;
l_actual                   NUMBER;
l_target                   NUMBER;
l_Target_Rec               BIS_TARGET_PUB.Target_Rec_Type;
l_Actual_Tbl               BIS_ACTUAL_PUB.Actual_Tbl_Type;
l_workflow_item_type       VARCHAR2(8);
l_workflow_process         VARCHAR2(30);
l_notify_resp              VARCHAR2(100);
l_responsibility_ID        NUMBER;
l_message                  VARCHAR2(250);
l_report                  VARCHAR2(250);
l_organization_ID          NUMBER;
l_organization_tbl         BIS_POSTACTUAL.t_orgTable;
l_msg_data                 VARCHAR2(250);
l_msg_subject              VARCHAR2(300);
l_return_status            VARCHAR2(1);
l_msg_count                NUMBER;
i                          NUMBER := 0;
l_center                   VARCHAR2(200);
CURSOR cr_actual IS
Select round(sum(talk_time)/sum(interactions_answered_live)/60,2) avg_talk_time,
       to_char(hour,'MON-YYYY') month,
       interaction_center_id center_id
from   bix_sum_grp_cls
group by to_char(hour,'MON-YYYY'), interaction_center_id;
CURSOR cr_center(p_center_id NUMBER) IS
SELECT call_center_name center_name
FROM   bix_call_center_v
WHERE  call_center_id = p_center_id;

CURSOR cr_target(p_organization_id VARCHAR2, p_center_id VARCHAR2, p_time VARCHAR2) IS
  SELECT  tv.target_level_short_name
        , tv.target_level_name
        , tv.target_level_id
        , tv.plan_name
        , tv.org_level_value_id
        , tv.time_level_value_id
        , tv.target
--        , tv.computed_target_short_name
        , tv.range1_low
        , tv.range1_high
        , tv.range2_low
        , tv.range2_high
        , tv.range3_low
        , tv.range3_high
        , tv.notify_resp1_id
        , tv.notify_resp1_short_name
        , tv.notify_resp2_id
        , tv.notify_resp2_short_name
        , tv.notify_resp3_id
        , tv.notify_resp3_short_name
        , tv.dim1_level_value_id
  FROM BISFV_TARGETS tv
  WHERE tv.target_level_short_name = p_target_level_short_name
  AND tv.time_level_value_id like '%' || p_time || '%'
  AND tv.org_level_value_id = p_organization_id
  AND tv.dim1_level_value_name = p_center_id;

BEGIN

  l_target_level_rec.target_Level_Short_Name
    := p_target_Level_Short_Name;
--  l_period_set_name := p_time_period;
--  l_period_name     := p_time_period;
  l_report     := 'BIXATLK0';
  FND_MESSAGE.SET_NAME('BIX', 'BIX_AVG_TALK_TIME');
  l_msg_subject := FND_MESSAGE.GET;
  IF l_msg_subject is NULL then
     l_msg_subject := 'Average Talk Time PMF Notification';
  END IF;
  l_organization_id := -1;
  -- Get the workflow process
  SELECT workflow_item_type, workflow_process_short_name
  INTO l_workflow_item_type, l_workflow_process
  FROM bisbv_target_levels
  WHERE target_level_short_name = p_target_level_short_name;

  -- Get the KPIs users have selected to monitor on their homepage
  BIS_ACTUAL_PUB.Retrieve_User_Selections
  ( p_api_version                  => 1.0
   ,p_Target_Level_Rec             => l_Target_Level_Rec
   ,x_Indicator_Region_Tbl         => l_user_selection_Tbl
   ,x_return_status                => l_return_status
   ,x_msg_count                    => l_msg_count
   ,x_msg_data                     => l_msg_data
   ,x_error_Tbl                    => l_error_tbl
  );

  -- Calculate Actual for all Months for All Call Centers
  FOR cr_a in cr_actual LOOP

    l_actual := cr_a.avg_talk_time;
    for cr_c in cr_center(cr_a.center_id) LOOP
    l_center := cr_c.center_name;
    end loop;
    -- Post actual value for only those KPIs users have selected.
--    FOR i IN 1..l_user_selection_Tbl.COUNT LOOP
--      IF l_user_selection_tbl(i).organization_id = l_organization_id THEN
--      END IF;
--    END LOOP;

    -- Check for exceptions and start corrective action
    FOR cr_t IN cr_target(l_organization_id, to_char(cr_a.center_id), cr_a.month) LOOP

      IF cr_t.target IS NULL THEN
--        l_target := Get_Target(cr.computed_target_short_name);
        NULL;
      ELSE
        l_target := cr_t.target;
      END IF;
      l_Actual_Tbl(1).target_Level_Short_Name
                     := p_target_level_short_name;
      l_Actual_Tbl(1).Org_Level_value_ID := l_organization_id;
      l_Actual_Tbl(1).time_Level_value_ID := cr_t.time_level_value_id;
      l_Actual_Tbl(1).target_Level_ID := cr_t.target_level_id;
      l_Actual_Tbl(1).Actual := l_actual;
      l_Actual_Tbl(1).dim1_Level_value_ID := cr_t.dim1_level_value_id;
      l_Actual_Tbl(1).target_level_name := cr_t.target_level_name;
      BIS_ACTUAL_PUB.POST_ACTUAL
           ( p_api_version       => 1.0
             ,p_Actual_Rec        => l_actual_Tbl(1)
             ,x_return_status     => l_return_status
             ,x_msg_count         => l_msg_count
             ,x_msg_data          => l_msg_data
             ,x_error_tbl         => l_error_tbl
            );
      -- We're not on target....
      IF l_actual <> l_target THEN
         -- Check if actual is within the first range
        IF l_actual NOT BETWEEN
           cr_t.range2_low AND cr_t.range2_High
           AND l_actual BETWEEN
           cr_t.range1_low AND cr_t.range1_High
        THEN
           FND_MESSAGE.SET_NAME('BIX', 'BIX_PMF_RANGE1');
           FND_MESSAGE.SET_TOKEN('BIX_TARGET_NAME', cr_t.target_level_name);
           FND_MESSAGE.SET_TOKEN('BIX_CENTER', l_center);
           FND_MESSAGE.SET_TOKEN('BIX_TARGET', l_target);
           FND_MESSAGE.SET_TOKEN('BIX_ACTUAL', l_actual);
           FND_MESSAGE.SET_TOKEN('BIX_PLAN', cr_t.plan_name);
           FND_MESSAGE.SET_TOKEN('BIX_TIME', cr_a.month);
           l_message := FND_MESSAGE.GET;
           l_notify_resp := cr_t.Notify_Resp1_short_name;
           l_responsibility_id := cr_t.Notify_Resp1_ID;
         --  dbms_output.put_line('In First Range' || l_message);
        -- Check if actual is within the second range
        ELSIF l_actual NOT BETWEEN
           cr_t.range1_low AND cr_t.range1_High
           AND l_actual BETWEEN
           cr_t.range2_low AND cr_t.range2_High
        THEN
           FND_MESSAGE.SET_NAME('BIX', 'BIX_PMF_RANGE2');
           FND_MESSAGE.SET_TOKEN('BIX_TARGET_NAME', cr_t.target_level_name);
           FND_MESSAGE.SET_TOKEN('BIX_CENTER', l_center);
           FND_MESSAGE.SET_TOKEN('BIX_TARGET', l_target);
           FND_MESSAGE.SET_TOKEN('BIX_ACTUAL', l_actual);
           FND_MESSAGE.SET_TOKEN('BIX_PLAN', cr_t.plan_name);
           FND_MESSAGE.SET_TOKEN('BIX_TIME', cr_a.month);
           l_message := FND_MESSAGE.GET;
           l_notify_resp := cr_t.Notify_Resp1_short_name;
           l_responsibility_id := cr_t.Notify_Resp1_ID;
           --dbms_output.put_line('In Second Range');
        -- Check if actual is within the third range
        ELSIF l_actual NOT BETWEEN
           cr_t.range2_low AND cr_t.range2_High
           AND l_actual BETWEEN
           cr_t.range3_low AND cr_t.range3_High
        THEN
           FND_MESSAGE.SET_NAME('BIX', 'BIX_PMF_RANGE3');
           FND_MESSAGE.SET_TOKEN('BIX_TARGET_NAME', cr_t.target_level_name);
           FND_MESSAGE.SET_TOKEN('BIX_CENTER', l_center);
           FND_MESSAGE.SET_TOKEN('BIX_TARGET', l_target);
           FND_MESSAGE.SET_TOKEN('BIX_ACTUAL', l_actual);
           FND_MESSAGE.SET_TOKEN('BIX_PLAN', cr_t.plan_name);
           FND_MESSAGE.SET_TOKEN('BIX_TIME', cr_a.month);
           l_message := FND_MESSAGE.GET;
           l_notify_resp := cr_t.Notify_Resp2_short_name;
           l_responsibility_id := cr_t.Notify_Resp2_ID;
            --dbms_output.put_line('In Third Range');
        -- Check if actual is outside the third range
        ELSIF l_actual NOT BETWEEN
           cr_t.range3_low AND cr_t.range3_High
           AND l_actual > l_target
        THEN
           FND_MESSAGE.SET_NAME('BIX', 'BIX_PMF_OFFRANGE');
           FND_MESSAGE.SET_TOKEN('BIX_TARGET_NAME', cr_t.target_level_name);
           FND_MESSAGE.SET_TOKEN('BIX_CENTER', l_center);
           FND_MESSAGE.SET_TOKEN('BIX_TARGET', l_target);
           FND_MESSAGE.SET_TOKEN('BIX_ACTUAL', l_actual);
           FND_MESSAGE.SET_TOKEN('BIX_PLAN', cr_t.plan_name);
           FND_MESSAGE.SET_TOKEN('BIX_TIME', cr_a.month);
           l_message := FND_MESSAGE.GET;
           l_notify_resp := cr_t.Notify_Resp3_short_name;
           l_responsibility_id := cr_t.Notify_Resp3_ID;
          --dbms_output.put_line('Out of Third Range');
        ELSIF l_actual < l_target
        THEN
           FND_MESSAGE.SET_NAME('BIX', 'BIX_PMF_EXRANGE');
           FND_MESSAGE.SET_TOKEN('BIX_TARGET_NAME', cr_t.target_level_name);
           FND_MESSAGE.SET_TOKEN('BIX_CENTER', l_center);
           FND_MESSAGE.SET_TOKEN('BIX_TARGET', l_target);
           FND_MESSAGE.SET_TOKEN('BIX_ACTUAL', l_actual);
           FND_MESSAGE.SET_TOKEN('BIX_PLAN', cr_t.plan_name);
           FND_MESSAGE.SET_TOKEN('BIX_TIME', cr_a.month);
           l_message := FND_MESSAGE.GET;
           l_notify_resp := cr_t.Notify_Resp3_short_name;
           l_responsibility_id := cr_t.Notify_Resp3_ID;
          --dbms_output.put_line('less than First Range');
        END IF;

      -- We're on target!!
      ELSE
           FND_MESSAGE.SET_NAME('BIX', 'BIX_PMF_INRANGE');
           FND_MESSAGE.SET_TOKEN('BIX_TARGET_NAME', cr_t.target_level_name);
           FND_MESSAGE.SET_TOKEN('BIX_CENTER', l_center);
           FND_MESSAGE.SET_TOKEN('BIX_TARGET', l_target);
           FND_MESSAGE.SET_TOKEN('BIX_ACTUAL', l_actual);
           FND_MESSAGE.SET_TOKEN('BIX_PLAN', cr_t.plan_name);
           FND_MESSAGE.SET_TOKEN('BIX_TIME', cr_a.month);
           l_message := FND_MESSAGE.GET;
        l_notify_resp := cr_t.Notify_Resp1_short_name;
        l_responsibility_id := cr_t.Notify_Resp1_ID;
      END IF;
/*
     dbms_output.put_line('Calling Corrective Action' || cr_a.month ||
          l_responsibility_id || l_notify_resp || l_workflow_process
          || l_workflow_item_type || l_message);
*/
      Start_Corrective_Action
      ( p_wf_process        => l_workflow_process
      , p_wf_item_type => l_workflow_item_type
      , p_message           => l_message
      , p_notify_resp       => l_notify_resp
      , p_report_name1      => l_report
      , p_report_param1     => NULL
      , p_responsibility_id => l_responsibility_id
      , p_msg_subject       => l_msg_subject
      );

    END LOOP;  -- ends loop to check targets
  END LOOP;    -- ends loop to calculate actual

EXCEPTION
  WHEN OTHERS THEN
  l_message := 'Exception in Average Talk Time Alert Procedure.';
  --dbms_output.put_line(l_message);

END BIX_AVGTALK_ALERT;
/* Alert for Average Wait to Abandon  */
PROCEDURE BIX_AVGWAIT_ALERT
( p_target_Level_Short_Name VARCHAR2
)
IS
l_period_set_name          VARCHAR2(15);
l_period_name              VARCHAR2(15);
l_target_level_rec      BIS_TARGET_LEVEL_PUB.Target_Level_Rec_Type;
l_user_selection_tbl       BIS_INDICATOR_REGION_PUB.Indicator_Region_Tbl_Type;
l_error_tbl                BIS_UTILITIES_PUB.Error_Tbl_Type;
l_actual                   NUMBER;
l_target                   NUMBER;
l_Target_Rec               BIS_TARGET_PUB.Target_Rec_Type;
l_Actual_Tbl               BIS_ACTUAL_PUB.Actual_Tbl_Type;
l_workflow_item_type       VARCHAR2(8);
l_workflow_process         VARCHAR2(30);
l_notify_resp              VARCHAR2(100);
l_responsibility_ID        NUMBER;
l_message                  VARCHAR2(250);
l_report                  VARCHAR2(250);
l_organization_ID          NUMBER;
l_organization_tbl         BIS_POSTACTUAL.t_orgTable;
l_msg_data                 VARCHAR2(250);
l_msg_count                NUMBER;
l_msg_subject              VARCHAR2(300);
l_return_status            VARCHAR2(1);
i                          NUMBER := 0;
l_center                   VARCHAR2(200);
CURSOR cr_actual IS
Select round(sum(wait_time_to_abandon)/sum(number_of_interactions), 2) avg_wait_time_to_abandon,
       to_char(hour,'MON-YYYY') month,
       interaction_center_id center_id
from   bix_sum_grp_cls
group by to_char(hour,'MON-YYYY'), interaction_center_id;
CURSOR cr_center(p_center_id NUMBER) IS
SELECT call_center_name center_name
FROM   bix_call_center_v
WHERE  call_center_id = p_center_id;

CURSOR cr_target(p_organization_id VARCHAR2,
                 p_center_id VARCHAR2, p_time VARCHAR2)
IS
  SELECT  tv.target_level_short_name
        , tv.target_level_name
        , tv.target_level_id
        , tv.plan_name
        , tv.org_level_value_id
        , tv.time_level_value_id
        , tv.target
--        , tv.computed_target_short_name
        , tv.range1_low
        , tv.range1_high
        , tv.range2_low
        , tv.range2_high
        , tv.range3_low
        , tv.range3_high
        , tv.notify_resp1_id
        , tv.notify_resp1_short_name
        , tv.notify_resp2_id
        , tv.notify_resp2_short_name
        , tv.notify_resp3_id
        , tv.notify_resp3_short_name
        , tv.dim1_level_value_id
  FROM BISFV_TARGETS tv
  WHERE tv.target_level_short_name = p_target_level_short_name
  AND tv.time_level_value_id like '%' || p_time || '%'
  AND tv.org_level_value_id = p_organization_id
  AND tv.dim1_level_value_name = p_center_id;

BEGIN

  l_target_level_rec.target_Level_Short_Name
    := p_target_Level_Short_Name;
--  l_period_set_name := p_time_period;
--  l_period_name     := p_time_period;
  l_report     := 'BIXWABC0';
  FND_MESSAGE.SET_NAME('BIX', 'BIX_AVG_WAIT_TO_ABANDON');
  l_msg_subject := FND_MESSAGE.GET;
  IF l_msg_subject is NULL then
     l_msg_subject := 'Average Wait Time to Abandon PMF Notification';
  END IF;
  l_organization_id := -1;
  -- Get the workflow process
  SELECT workflow_item_type, workflow_process_short_name
  INTO l_workflow_item_type, l_workflow_process
  FROM bisbv_target_levels
  WHERE target_level_short_name = p_target_level_short_name;

 -- Get the KPIs users have selected to monitor on their homepage
  BIS_ACTUAL_PUB.Retrieve_User_Selections
  ( p_api_version                  => 1.0
   ,p_Target_Level_Rec             => l_Target_Level_Rec
   ,x_Indicator_Region_Tbl         => l_user_selection_Tbl
   ,x_return_status                => l_return_status
   ,x_msg_count                    => l_msg_count
   ,x_msg_data                     => l_msg_data
   ,x_error_Tbl                    => l_error_tbl
  );

  -- Calculate Actual for all Months for All Call Centers
  FOR cr_a in cr_actual LOOP

    l_actual := cr_a.avg_wait_time_to_abandon;
    for cr_c in cr_center(cr_a.center_id) LOOP
    l_center := cr_c.center_name;
    end loop;
    -- Post actual value for only those KPIs users have selected.
--    FOR i IN 1..l_user_selection_Tbl.COUNT LOOP
--      IF l_user_selection_tbl(i).organization_id = l_organization_id THEN
--      END IF;
--    END LOOP;

    -- Check for exceptions and start corrective action
    FOR cr_t IN cr_target(l_organization_id, to_char(cr_a.center_id), cr_a.month
) LOOP

      IF cr_t.target IS NULL THEN
--        l_target := Get_Target(cr.computed_target_short_name);
        NULL;
      ELSE
        l_target := cr_t.target;
      END IF;
      l_Actual_Tbl(1).target_Level_Short_Name
                     := p_target_level_short_name;
      l_Actual_Tbl(1).Org_Level_value_ID := l_organization_id;
      l_Actual_Tbl(1).time_Level_value_ID := cr_t.time_level_value_id;
      l_Actual_Tbl(1).target_Level_ID := cr_t.target_level_id;
      l_Actual_Tbl(1).Actual := l_actual;
      l_Actual_Tbl(1).dim1_Level_value_ID := cr_t.dim1_level_value_id;
      l_Actual_Tbl(1).target_level_name := cr_t.target_level_name;
      BIS_ACTUAL_PUB.POST_ACTUAL
           ( p_api_version       => 1.0
             ,p_Actual_Rec        => l_actual_Tbl(1)
             ,x_return_status     => l_return_status
             ,x_msg_count         => l_msg_count
             ,x_msg_data          => l_msg_data
             ,x_error_tbl         => l_error_tbl
            );

      -- We're not on target....
      IF l_actual <> l_target THEN
         -- Check if actual is within the first range
        IF l_actual NOT BETWEEN
           cr_t.range2_low AND cr_t.range2_High
           AND l_actual BETWEEN
           cr_t.range1_low AND cr_t.range1_High
        THEN
           FND_MESSAGE.SET_NAME('BIX', 'BIX_PMF_RANGE1');
           FND_MESSAGE.SET_TOKEN('BIX_TARGET_NAME', cr_t.target_level_name);
           FND_MESSAGE.SET_TOKEN('BIX_CENTER', l_center);
           FND_MESSAGE.SET_TOKEN('BIX_TARGET', l_target);
           FND_MESSAGE.SET_TOKEN('BIX_ACTUAL', l_actual);
           FND_MESSAGE.SET_TOKEN('BIX_PLAN', cr_t.plan_name);
           FND_MESSAGE.SET_TOKEN('BIX_TIME', cr_a.month);
           l_message := FND_MESSAGE.GET;
           l_notify_resp := cr_t.Notify_Resp1_short_name;
           l_responsibility_id := cr_t.Notify_Resp1_ID;
         --  dbms_output.put_line('In First Range' || l_message);
        -- Check if actual is within the second range
        ELSIF l_actual NOT BETWEEN
           cr_t.range1_low AND cr_t.range1_High
           AND l_actual BETWEEN
           cr_t.range2_low AND cr_t.range2_High
        THEN
           FND_MESSAGE.SET_NAME('BIX', 'BIX_PMF_RANGE2');
           FND_MESSAGE.SET_TOKEN('BIX_TARGET_NAME', cr_t.target_level_name);
           FND_MESSAGE.SET_TOKEN('BIX_CENTER', l_center);
           FND_MESSAGE.SET_TOKEN('BIX_TARGET', l_target);
           FND_MESSAGE.SET_TOKEN('BIX_ACTUAL', l_actual);
           FND_MESSAGE.SET_TOKEN('BIX_PLAN', cr_t.plan_name);
           FND_MESSAGE.SET_TOKEN('BIX_TIME', cr_a.month);
           l_message := FND_MESSAGE.GET;
           l_notify_resp := cr_t.Notify_Resp1_short_name;
           l_responsibility_id := cr_t.Notify_Resp1_ID;
          --dbms_output.put_line('In Second Range');
        -- Check if actual is within the third range
        ELSIF l_actual NOT BETWEEN

           cr_t.range2_low AND cr_t.range2_High
           AND l_actual BETWEEN
           cr_t.range3_low AND cr_t.range3_High
        THEN
           FND_MESSAGE.SET_NAME('BIX', 'BIX_PMF_RANGE3');
           FND_MESSAGE.SET_TOKEN('BIX_TARGET_NAME', cr_t.target_level_name);
           FND_MESSAGE.SET_TOKEN('BIX_CENTER', l_center);
           FND_MESSAGE.SET_TOKEN('BIX_TARGET', l_target);
           FND_MESSAGE.SET_TOKEN('BIX_ACTUAL', l_actual);
           FND_MESSAGE.SET_TOKEN('BIX_PLAN', cr_t.plan_name);
           FND_MESSAGE.SET_TOKEN('BIX_TIME', cr_a.month);
           l_message := FND_MESSAGE.GET;
           l_notify_resp := cr_t.Notify_Resp2_short_name;
           l_responsibility_id := cr_t.Notify_Resp2_ID;
            --dbms_output.put_line('In Third Range');
        -- Check if actual is outside the third range
        ELSIF l_actual NOT BETWEEN
           cr_t.range3_low AND cr_t.range3_High
           AND l_actual > l_target
        THEN
           FND_MESSAGE.SET_NAME('BIX', 'BIX_PMF_OFFRANGE');
           FND_MESSAGE.SET_TOKEN('BIX_TARGET_NAME', cr_t.target_level_name);
           FND_MESSAGE.SET_TOKEN('BIX_CENTER', l_center);
           FND_MESSAGE.SET_TOKEN('BIX_TARGET', l_target);
           FND_MESSAGE.SET_TOKEN('BIX_ACTUAL', l_actual);
           FND_MESSAGE.SET_TOKEN('BIX_PLAN', cr_t.plan_name);
           FND_MESSAGE.SET_TOKEN('BIX_TIME', cr_a.month);
           l_message := FND_MESSAGE.GET;
           l_notify_resp := cr_t.Notify_Resp3_short_name;
           l_responsibility_id := cr_t.Notify_Resp3_ID;
          --dbms_output.put_line('Out of Third Range');
        ELSIF l_actual < l_target
        THEN
           FND_MESSAGE.SET_NAME('BIX', 'BIX_PMF_EXRANGE');
           FND_MESSAGE.SET_TOKEN('BIX_TARGET_NAME', cr_t.target_level_name);
           FND_MESSAGE.SET_TOKEN('BIX_CENTER', l_center);
           FND_MESSAGE.SET_TOKEN('BIX_TARGET', l_target);
           FND_MESSAGE.SET_TOKEN('BIX_ACTUAL', l_actual);
           FND_MESSAGE.SET_TOKEN('BIX_PLAN', cr_t.plan_name);
           FND_MESSAGE.SET_TOKEN('BIX_TIME', cr_a.month);
           l_message := FND_MESSAGE.GET;
           l_notify_resp := cr_t.Notify_Resp3_short_name;
           l_responsibility_id := cr_t.Notify_Resp3_ID;

         --dbms_output.put_line('less than First Range');
        END IF;

      -- We're on target!!
      ELSE
           FND_MESSAGE.SET_NAME('BIX', 'BIX_PMF_INRANGE');
           FND_MESSAGE.SET_TOKEN('BIX_TARGET_NAME', cr_t.target_level_name);
           FND_MESSAGE.SET_TOKEN('BIX_CENTER', l_center);
           FND_MESSAGE.SET_TOKEN('BIX_TARGET', l_target);
           FND_MESSAGE.SET_TOKEN('BIX_ACTUAL', l_actual);
           FND_MESSAGE.SET_TOKEN('BIX_PLAN', cr_t.plan_name);
           FND_MESSAGE.SET_TOKEN('BIX_TIME', cr_a.month);
           l_message := FND_MESSAGE.GET;
        l_notify_resp := cr_t.Notify_Resp1_short_name;
        l_responsibility_id := cr_t.Notify_Resp1_ID;
      END IF;
/*
     dbms_output.put_line('Calling Corrective Action' || cr_a.month ||
          l_responsibility_id || l_notify_resp || l_workflow_process ||
          l_workflow_item_type || l_message );
		*/

      Start_Corrective_Action
      ( p_wf_process        => l_workflow_process
      , p_wf_item_type => l_workflow_item_type
      , p_message           => l_message
      , p_notify_resp       => l_notify_resp
      , p_report_name1      => l_report
      , p_report_param1     => NULL
      , p_responsibility_id => l_responsibility_id
      , p_msg_subject       => l_msg_subject
      );
    END LOOP;  -- ends loop to check targets
  END LOOP;    -- ends loop to calculate actual

EXCEPTION
  WHEN OTHERS THEN
  l_message := 'Exception in Abandon Alert Procedure.';
  --dbms_output.put_line(l_message);

END BIX_AVGWAIT_ALERT;
/* Alert for Abandon Calls */
PROCEDURE BIX_UTLRATE_ALERT
( p_target_Level_Short_Name VARCHAR2
)
IS
l_period_set_name          VARCHAR2(15);
l_period_name              VARCHAR2(15);
l_target_level_rec      BIS_TARGET_LEVEL_PUB.Target_Level_Rec_Type;
l_user_selection_tbl       BIS_INDICATOR_REGION_PUB.Indicator_Region_Tbl_Type;
l_error_tbl                BIS_UTILITIES_PUB.Error_Tbl_Type;
l_actual                   NUMBER;
l_target                   NUMBER;
l_Target_Rec               BIS_TARGET_PUB.Target_Rec_Type;
l_Actual_Tbl               BIS_ACTUAL_PUB.Actual_Tbl_Type;
l_workflow_item_type       VARCHAR2(8);
l_workflow_process         VARCHAR2(30);
l_notify_resp              VARCHAR2(100);
l_responsibility_ID        NUMBER;
l_message                  VARCHAR2(250);
l_report                  VARCHAR2(250);
l_organization_ID          NUMBER;
l_organization_tbl         BIS_POSTACTUAL.t_orgTable;
l_msg_data                 VARCHAR2(250);
l_msg_count                NUMBER;
l_msg_subject              VARCHAR2(300);
l_return_status            VARCHAR2(1);
i                          NUMBER := 0;
l_center                   VARCHAR2(200);
CURSOR cr_actual IS
Select round(sum(talk_time)/sum(talk_time + idle_time) * 100, 2) utilization_rate,
       to_char(hour,'MON-YYYY') month,
       interaction_center_id center_id
from   bix_sum_grp_cls
group by to_char(hour,'MON-YYYY'), interaction_center_id;
CURSOR cr_center(p_center_id NUMBER) IS
SELECT call_center_name center_name
FROM   bix_call_center_v
WHERE  call_center_id = p_center_id;

CURSOR cr_target(p_organization_id VARCHAR2,
                 p_center_id VARCHAR2, p_time VARCHAR2)
IS
  SELECT  tv.target_level_short_name
        , tv.target_level_name
        , tv.target_level_id
        , tv.plan_name
        , tv.org_level_value_id
        , tv.time_level_value_id
        , tv.target
--        , tv.computed_target_short_name
        , tv.range1_low
        , tv.range1_high
        , tv.range2_low
        , tv.range2_high
        , tv.range3_low
        , tv.range3_high
        , tv.notify_resp1_id
        , tv.notify_resp1_short_name
        , tv.notify_resp2_id
        , tv.notify_resp2_short_name
        , tv.notify_resp3_id
        , tv.notify_resp3_short_name
        , tv.dim1_level_value_id
  FROM BISFV_TARGETS tv
  WHERE tv.target_level_short_name = p_target_level_short_name
  AND tv.time_level_value_id like '%' || p_time || '%'
  AND tv.org_level_value_id = p_organization_id
  AND tv.dim1_level_value_name = p_center_id;

BEGIN

  l_target_level_rec.target_Level_Short_Name
    := p_target_Level_Short_Name;
--  l_period_set_name := p_time_period;
--  l_period_name     := p_time_period;
  l_report     := 'BIXUTLM0';
  FND_MESSAGE.SET_NAME('BIX', 'BIX_UTIL_RATE');
  l_msg_subject := FND_MESSAGE.GET;
  IF l_msg_subject is NULL then
     l_msg_subject := 'Utilization Rate PMF Notification';
  END IF;
           --dbms_output.put_line('In First Range' || l_message);
  l_organization_id := -1;
  -- Get the workflow process
  SELECT workflow_item_type, workflow_process_short_name
  INTO l_workflow_item_type, l_workflow_process
  FROM bisbv_target_levels
  WHERE target_level_short_name = p_target_level_short_name;

  -- Get the KPIs users have selected to monitor on their homepage
  BIS_ACTUAL_PUB.Retrieve_User_Selections
  ( p_api_version                  => 1.0
   ,p_Target_Level_Rec             => l_Target_Level_Rec
   ,x_Indicator_Region_Tbl         => l_user_selection_Tbl
   ,x_return_status                => l_return_status
   ,x_msg_count                    => l_msg_count
   ,x_msg_data                     => l_msg_data
   ,x_error_Tbl                    => l_error_tbl
  );

  -- Calculate Actual for all Months for All Call Centers
  FOR cr_a in cr_actual LOOP

    l_actual := cr_a.utilization_rate;
    for cr_c in cr_center(cr_a.center_id) LOOP
    l_center := cr_c.center_name;
    end loop;
    -- Post actual value for only those KPIs users have selected.
--    FOR i IN 1..l_user_selection_Tbl.COUNT LOOP
--      IF l_user_selection_tbl(i).organization_id = l_organization_id THEN
--      END IF;
--    END LOOP;

    -- Check for exceptions and start corrective action

    FOR cr_t IN cr_target(l_organization_id, to_char(cr_a.center_id), cr_a.month
) LOOP

      IF cr_t.target IS NULL THEN
--        l_target := Get_Target(cr.computed_target_short_name);
        NULL;
      ELSE
        l_target := cr_t.target;
      END IF;
      l_Actual_Tbl(1).target_Level_Short_Name
                     := p_target_level_short_name;
      l_Actual_Tbl(1).Org_Level_value_ID := l_organization_id;
      l_Actual_Tbl(1).time_Level_value_ID := cr_t.time_level_value_id;
      l_Actual_Tbl(1).target_Level_ID := cr_t.target_level_id;
      l_Actual_Tbl(1).Actual := l_actual;
      l_Actual_Tbl(1).dim1_Level_value_ID := cr_t.dim1_level_value_id;
      l_Actual_Tbl(1).target_level_name := cr_t.target_level_name;
      BIS_ACTUAL_PUB.POST_ACTUAL
           ( p_api_version       => 1.0
             ,p_Actual_Rec        => l_actual_Tbl(1)
             ,x_return_status     => l_return_status
             ,x_msg_count         => l_msg_count
             ,x_msg_data          => l_msg_data
             ,x_error_tbl         => l_error_tbl
            );
      -- We're not on target....
      IF l_actual <> l_target THEN
         -- Check if actual is within the first range
        IF l_actual NOT BETWEEN
           cr_t.range2_low AND cr_t.range2_High
           AND l_actual BETWEEN
           cr_t.range1_low AND cr_t.range1_High
        THEN
           FND_MESSAGE.SET_NAME('BIX', 'BIX_PMF_RANGE1');
           FND_MESSAGE.SET_TOKEN('BIX_TARGET_NAME', cr_t.target_level_name);
           FND_MESSAGE.SET_TOKEN('BIX_CENTER', l_center);
           FND_MESSAGE.SET_TOKEN('BIX_TARGET', l_target);
           FND_MESSAGE.SET_TOKEN('BIX_ACTUAL', l_actual);
           FND_MESSAGE.SET_TOKEN('BIX_PLAN', cr_t.plan_name);
           FND_MESSAGE.SET_TOKEN('BIX_TIME', cr_a.month);
           l_message := FND_MESSAGE.GET;
           l_notify_resp := cr_t.Notify_Resp1_short_name;
           l_responsibility_id := cr_t.Notify_Resp1_ID;
         --  dbms_output.put_line('In First Range' || l_message);
        -- Check if actual is within the second range
        ELSIF l_actual NOT BETWEEN
           cr_t.range1_low AND cr_t.range1_High
           AND l_actual BETWEEN
           cr_t.range2_low AND cr_t.range2_High
        THEN
           FND_MESSAGE.SET_NAME('BIX', 'BIX_PMF_RANGE2');
           FND_MESSAGE.SET_TOKEN('BIX_TARGET_NAME', cr_t.target_level_name);
           FND_MESSAGE.SET_TOKEN('BIX_CENTER', l_center);
           FND_MESSAGE.SET_TOKEN('BIX_TARGET', l_target);
           FND_MESSAGE.SET_TOKEN('BIX_ACTUAL', l_actual);
           FND_MESSAGE.SET_TOKEN('BIX_PLAN', cr_t.plan_name);
           FND_MESSAGE.SET_TOKEN('BIX_TIME', cr_a.month);
           l_message := FND_MESSAGE.GET;
           l_notify_resp := cr_t.Notify_Resp1_short_name;
           l_responsibility_id := cr_t.Notify_Resp1_ID;
           --dbms_output.put_line('In Second Range');
        -- Check if actual is within the third range
        ELSIF l_actual NOT BETWEEN

           cr_t.range2_low AND cr_t.range2_High
           AND l_actual BETWEEN
           cr_t.range3_low AND cr_t.range3_High
        THEN
           FND_MESSAGE.SET_NAME('BIX', 'BIX_PMF_RANGE3');
           FND_MESSAGE.SET_TOKEN('BIX_TARGET_NAME', cr_t.target_level_name);
           FND_MESSAGE.SET_TOKEN('BIX_CENTER', l_center);
           FND_MESSAGE.SET_TOKEN('BIX_TARGET', l_target);
           FND_MESSAGE.SET_TOKEN('BIX_ACTUAL', l_actual);
           FND_MESSAGE.SET_TOKEN('BIX_PLAN', cr_t.plan_name);
           FND_MESSAGE.SET_TOKEN('BIX_TIME', cr_a.month);
           l_message := FND_MESSAGE.GET;
           l_notify_resp := cr_t.Notify_Resp2_short_name;
           l_responsibility_id := cr_t.Notify_Resp2_ID;
            --dbms_output.put_line('In Third Range');
        -- Check if actual is outside the third range
        ELSIF l_actual NOT BETWEEN
           cr_t.range3_low AND cr_t.range3_High
           AND l_actual < l_target
        THEN
           FND_MESSAGE.SET_NAME('BIX', 'BIX_PMF_OFFRANGE');
           FND_MESSAGE.SET_TOKEN('BIX_TARGET_NAME', cr_t.target_level_name);
           FND_MESSAGE.SET_TOKEN('BIX_CENTER', l_center);
           FND_MESSAGE.SET_TOKEN('BIX_TARGET', l_target);
           FND_MESSAGE.SET_TOKEN('BIX_ACTUAL', l_actual);
           FND_MESSAGE.SET_TOKEN('BIX_PLAN', cr_t.plan_name);
           FND_MESSAGE.SET_TOKEN('BIX_TIME', cr_a.month);
           l_message := FND_MESSAGE.GET;
           l_notify_resp := cr_t.Notify_Resp3_short_name;
           l_responsibility_id := cr_t.Notify_Resp3_ID;
          --dbms_output.put_line('Out of Third Range');
        ELSIF l_actual > l_target
        THEN
           FND_MESSAGE.SET_NAME('BIX', 'BIX_PMF_EXRANGE');
           FND_MESSAGE.SET_TOKEN('BIX_TARGET_NAME', cr_t.target_level_name);
           FND_MESSAGE.SET_TOKEN('BIX_CENTER', l_center);
           FND_MESSAGE.SET_TOKEN('BIX_TARGET', l_target);
           FND_MESSAGE.SET_TOKEN('BIX_ACTUAL', l_actual);
           FND_MESSAGE.SET_TOKEN('BIX_PLAN', cr_t.plan_name);
           FND_MESSAGE.SET_TOKEN('BIX_TIME', cr_a.month);
           l_message := FND_MESSAGE.GET;
           l_notify_resp := cr_t.Notify_Resp3_short_name;
           l_responsibility_id := cr_t.Notify_Resp3_ID;
          --dbms_output.put_line('less than First Range');
        END IF;

      -- We're on target!!
      ELSE
           FND_MESSAGE.SET_NAME('BIX', 'BIX_PMF_INRANGE');
           FND_MESSAGE.SET_TOKEN('BIX_TARGET_NAME', cr_t.target_level_name);
           FND_MESSAGE.SET_TOKEN('BIX_CENTER', l_center);
           FND_MESSAGE.SET_TOKEN('BIX_TARGET', l_target);
           FND_MESSAGE.SET_TOKEN('BIX_ACTUAL', l_actual);
           FND_MESSAGE.SET_TOKEN('BIX_PLAN', cr_t.plan_name);
           FND_MESSAGE.SET_TOKEN('BIX_TIME', cr_a.month);
           l_message := FND_MESSAGE.GET;
        l_notify_resp := cr_t.Notify_Resp1_short_name;
        l_responsibility_id := cr_t.Notify_Resp1_ID;
      END IF;

       --dbms_output.put_line('Calling Corrective Action');
/*
     dbms_output.put_line('Calling Corrective Action' || cr_a.month ||
          l_responsibility_id || l_notify_resp || l_workflow_process ||
          l_workflow_item_type || l_message );
*/
      Start_Corrective_Action
      ( p_wf_process        => l_workflow_process
      , p_wf_item_type => l_workflow_item_type
      , p_message           => l_message
      , p_notify_resp       => l_notify_resp
      , p_report_name1      => l_report
      , p_report_param1     => NULL
      , p_responsibility_id => l_responsibility_id
      , p_msg_subject       => l_msg_subject
      );
    END LOOP;  -- ends loop to check targets
  END LOOP;    -- ends loop to calculate actual

EXCEPTION
  WHEN OTHERS THEN
  l_message := 'Exception in Utilization Rate Alert Procedure.';
  --dbms_output.put_line(l_message);

END BIX_UTLRATE_ALERT;
/* Alert procedure for Calls Answered */
PROCEDURE BIX_CALLSANS_ALERT
( p_target_Level_Short_Name VARCHAR2
)
IS
l_period_set_name          VARCHAR2(15);
l_period_name              VARCHAR2(15);
l_target_level_rec      BIS_TARGET_LEVEL_PUB.Target_Level_Rec_Type;
l_user_selection_tbl       BIS_INDICATOR_REGION_PUB.Indicator_Region_Tbl_Type;
l_error_tbl                BIS_UTILITIES_PUB.Error_Tbl_Type;
l_actual                   NUMBER;
l_target                   NUMBER;
l_Target_Rec               BIS_TARGET_PUB.Target_Rec_Type;
l_Actual_Tbl               BIS_ACTUAL_PUB.Actual_Tbl_Type;
l_workflow_item_type       VARCHAR2(8);
l_workflow_process         VARCHAR2(30);
l_notify_resp              VARCHAR2(100);
l_responsibility_ID        NUMBER;
l_message                  VARCHAR2(250);
l_report                  VARCHAR2(250);
l_organization_ID          NUMBER;
l_organization_tbl         BIS_POSTACTUAL.t_orgTable;
l_msg_data                 VARCHAR2(250);
l_msg_count                NUMBER;
l_msg_subject              VARCHAR2(300);
l_return_status            VARCHAR2(1);
i                          NUMBER := 0;
l_center                   VARCHAR2(200);
CURSOR cr_actual IS
Select sum(interactions_answered_live) calls_ansd,
	  to_char(hour,'MON-YYYY') month,
       interaction_center_id center_id
	  from   bix_sum_grp_cls
	  group by to_char(hour,'MON-YYYY'), interaction_center_id;
CURSOR cr_center(p_center_id NUMBER) IS
SELECT call_center_name center_name
FROM   bix_call_center_v
WHERE  call_center_id = p_center_id;
CURSOR cr_target(p_organization_id VARCHAR2,
                 p_center_id VARCHAR2, p_time VARCHAR2)
IS
SELECT  tv.target_level_short_name
	   , tv.target_level_name
	   , tv.target_level_id
	   , tv.plan_name
	   , tv.org_level_value_id
	   , tv.time_level_value_id
	   , tv.target
--      , tv.computed_target_short_name
	   , tv.range1_low
	   , tv.range1_high
	   , tv.range2_low
	   , tv.range2_high
	   , tv.range3_low
	   , tv.range3_high
	   , tv.notify_resp1_id
	   , tv.notify_resp1_short_name
	   , tv.notify_resp2_id
	   , tv.notify_resp2_short_name
	   , tv.notify_resp3_id
	   , tv.notify_resp3_short_name
	   , tv.dim1_level_value_id
FROM BISFV_TARGETS tv
WHERE tv.target_level_short_name = p_target_level_short_name
AND tv.time_level_value_id like '%' || p_time || '%'
AND tv.org_level_value_id = p_organization_id
AND tv.dim1_level_value_name = p_center_id;

BEGIN
    --dbms_output.put_line('In Calls Answered Rate Alert ');
      l_target_level_rec.target_Level_Short_Name
             := p_target_Level_Short_Name;
  --  l_period_set_name := p_time_period;
  --  l_period_name     := p_time_period;
      l_report     := 'BIXANCT0';
	 FND_MESSAGE.SET_NAME('BIX', 'BIX_CALLS_ANSWERED');
      l_msg_subject := FND_MESSAGE.GET;
      IF l_msg_subject is NULL then
	    l_msg_subject := 'Calls Answered PMF Notification';
      END IF;
      l_organization_id := -1;
	 -- Get the workflow process
      SELECT workflow_item_type, workflow_process_short_name
      INTO l_workflow_item_type, l_workflow_process
	 FROM bisbv_target_levels
	 WHERE target_level_short_name = p_target_level_short_name;

   -- Get the KPIs users have selected to monitor on their homepage
      BIS_ACTUAL_PUB.Retrieve_User_Selections
        ( p_api_version                  => 1.0
	     ,p_Target_Level_Rec             => l_Target_Level_Rec
		,x_Indicator_Region_Tbl         => l_user_selection_Tbl
	     ,x_return_status                => l_return_status
		,x_msg_count                    => l_msg_count
		,x_msg_data                     => l_msg_data
		,x_error_Tbl                    => l_error_tbl
	    );

  -- Calculate Actual for all Months for All Call Centers
     FOR cr_a in cr_actual LOOP
	   l_actual := cr_a.calls_ansd;
	   for cr_c in cr_center(cr_a.center_id) LOOP
		  l_center := cr_c.center_name;
	   end loop;
  -- Check for exceptions and start corrective action
     FOR cr_t IN cr_target(l_organization_id, to_char(cr_a.center_id),cr_a.month) LOOP
	    IF cr_t.target IS NULL THEN
	    -- l_target := Get_Target(cr.computed_target_short_name);
		  NULL;
         ELSE
		 l_target := cr_t.target;
         END IF;
	    l_Actual_Tbl(1).target_Level_Short_Name
			    := p_target_level_short_name;
         l_Actual_Tbl(1).Org_Level_value_ID := l_organization_id;
	    l_Actual_Tbl(1).time_Level_value_ID := cr_t.time_level_value_id;
	    l_Actual_Tbl(1).target_Level_ID := cr_t.target_level_id;
	    l_Actual_Tbl(1).Actual := l_actual;
	    l_Actual_Tbl(1).dim1_Level_value_ID := cr_t.dim1_level_value_id;
	    L_Actual_Tbl(1).target_level_name := cr_t.target_level_name;
	    BIS_ACTUAL_PUB.POST_ACTUAL
	    ( p_api_version       => 1.0
	    ,p_Actual_Rec        => l_actual_Tbl(1)
	    ,x_return_status     => l_return_status
	    ,x_msg_count         => l_msg_count
	    ,x_msg_data          => l_msg_data
	    ,x_error_tbl         => l_error_tbl
	    );
         -- We're not on target....
	    IF l_actual <> l_target THEN
		 -- Check if actual is within the first range
		 IF l_actual NOT BETWEEN
		   cr_t.range2_low AND cr_t.range2_High
		   AND l_actual BETWEEN
		   cr_t.range1_low AND cr_t.range1_High
           THEN
		   FND_MESSAGE.SET_NAME('BIX', 'BIX_PMF_RANGE1');
		   FND_MESSAGE.SET_TOKEN('BIX_TARGET_NAME', cr_t.target_level_name);
		   FND_MESSAGE.SET_TOKEN('BIX_CENTER', l_center);
		   FND_MESSAGE.SET_TOKEN('BIX_TARGET', l_target);
		   FND_MESSAGE.SET_TOKEN('BIX_ACTUAL', l_actual);
		   FND_MESSAGE.SET_TOKEN('BIX_PLAN', cr_t.plan_name);
		   FND_MESSAGE.SET_TOKEN('BIX_TIME', cr_a.month);
		   l_message := FND_MESSAGE.GET;
		   l_notify_resp := cr_t.Notify_Resp1_short_name;
		   l_responsibility_id := cr_t.Notify_Resp1_ID;
		   --dbms_output.put_line('In First Range');
           -- Check if actual is within the second range
           ELSIF l_actual NOT BETWEEN
		   cr_t.range1_low AND cr_t.range1_High
		   AND l_actual BETWEEN
		   cr_t.range2_low AND cr_t.range2_High
           THEN
		    FND_MESSAGE.SET_NAME('BIX', 'BIX_PMF_RANGE2');
		    FND_MESSAGE.SET_TOKEN('BIX_TARGET_NAME', cr_t.target_level_name);
		    FND_MESSAGE.SET_TOKEN('BIX_CENTER', l_center);
		    FND_MESSAGE.SET_TOKEN('BIX_TARGET', l_target);
		    FND_MESSAGE.SET_TOKEN('BIX_ACTUAL', l_actual);
		    FND_MESSAGE.SET_TOKEN('BIX_PLAN', cr_t.plan_name);
		    FND_MESSAGE.SET_TOKEN('BIX_TIME', cr_a.month);
		    l_message := FND_MESSAGE.GET;
		    l_notify_resp := cr_t.Notify_Resp1_short_name;
		    l_responsibility_id := cr_t.Notify_Resp1_ID;
		    --dbms_output.put_line('In Second Range');
            -- Check if actual is within the third range
		  ELSIF l_actual NOT BETWEEN
			cr_t.range2_low AND cr_t.range2_High
			AND l_actual BETWEEN
			cr_t.range3_low AND cr_t.range3_High
            THEN
			FND_MESSAGE.SET_NAME('BIX', 'BIX_PMF_RANGE3');
			FND_MESSAGE.SET_TOKEN('BIX_TARGET_NAME', cr_t.target_level_name);
			FND_MESSAGE.SET_TOKEN('BIX_CENTER', l_center);
			FND_MESSAGE.SET_TOKEN('BIX_TARGET', l_target);
			FND_MESSAGE.SET_TOKEN('BIX_ACTUAL', l_actual);
			FND_MESSAGE.SET_TOKEN('BIX_PLAN', cr_t.plan_name);
			FND_MESSAGE.SET_TOKEN('BIX_TIME', cr_a.month);
			l_message := FND_MESSAGE.GET;
			l_notify_resp := cr_t.Notify_Resp2_short_name;
			l_responsibility_id := cr_t.Notify_Resp2_ID;
			--dbms_output.put_line('In Third Range');
     	   -- Check if actual is outside the third range
		   ELSIF l_actual NOT BETWEEN
      	      cr_t.range3_low AND cr_t.range3_High
			 AND l_actual > l_target
             THEN
			 FND_MESSAGE.SET_NAME('BIX', 'BIX_PMF_OFFRANGE');
			 FND_MESSAGE.SET_TOKEN('BIX_TARGET_NAME', cr_t.target_level_name);
			 FND_MESSAGE.SET_TOKEN('BIX_CENTER', l_center);
			 FND_MESSAGE.SET_TOKEN('BIX_TARGET', l_target);
			 FND_MESSAGE.SET_TOKEN('BIX_ACTUAL', l_actual);
			 FND_MESSAGE.SET_TOKEN('BIX_PLAN', cr_t.plan_name);
			 FND_MESSAGE.SET_TOKEN('BIX_TIME', cr_a.month);
			 l_message := FND_MESSAGE.GET;
			 l_notify_resp := cr_t.Notify_Resp3_short_name;
			 l_responsibility_id := cr_t.Notify_Resp3_ID;
			 --dbms_output.put_line('Out of Third Range');
             ELSIF l_actual < l_target
		   THEN
			FND_MESSAGE.SET_NAME('BIX', 'BIX_PMF_EXRANGE');
			FND_MESSAGE.SET_TOKEN('BIX_TARGET_NAME', cr_t.target_level_name);
			FND_MESSAGE.SET_TOKEN('BIX_CENTER', l_center);
			FND_MESSAGE.SET_TOKEN('BIX_TARGET', l_target);
			FND_MESSAGE.SET_TOKEN('BIX_ACTUAL', l_actual);
			FND_MESSAGE.SET_TOKEN('BIX_PLAN', cr_t.plan_name);
			FND_MESSAGE.SET_TOKEN('BIX_TIME', cr_a.month);
			l_message := FND_MESSAGE.GET;
			l_notify_resp := cr_t.Notify_Resp3_short_name;
			l_responsibility_id := cr_t.Notify_Resp3_ID;
             END IF;
		   -- We're on target!!
             ELSE
			FND_MESSAGE.SET_NAME('BIX', 'BIX_PMF_INRANGE');
			FND_MESSAGE.SET_TOKEN('BIX_TARGET_NAME', cr_t.target_level_name);
			FND_MESSAGE.SET_TOKEN('BIX_CENTER', l_center);
			FND_MESSAGE.SET_TOKEN('BIX_TARGET', l_target);
			FND_MESSAGE.SET_TOKEN('BIX_ACTUAL', l_actual);
			FND_MESSAGE.SET_TOKEN('BIX_PLAN', cr_t.plan_name);
			FND_MESSAGE.SET_TOKEN('BIX_TIME', cr_a.month);
			l_message := FND_MESSAGE.GET;
			l_notify_resp := cr_t.Notify_Resp1_short_name;
			l_responsibility_id := cr_t.Notify_Resp1_ID;
             END IF;
         Start_Corrective_Action
		  ( p_wf_process        => l_workflow_process
		    , p_wf_item_type => l_workflow_item_type
		    , p_message           => l_message
		    , p_notify_resp       => l_notify_resp
		    , p_report_name1      => l_report
		    , p_report_param1     => NULL
		    , p_responsibility_id => l_responsibility_id
		    , p_msg_subject       => l_msg_subject
		   );
    END LOOP;  -- ends loop to check targets
	 END LOOP;    -- ends loop to calculate actual
EXCEPTION
   WHEN OTHERS THEN
   l_message := 'Exception in Calls Answered Alert Procedure.';
   --dbms_output.put_line(l_message);

END BIX_CALLSANS_ALERT;
END BIX_ALERT;

/
