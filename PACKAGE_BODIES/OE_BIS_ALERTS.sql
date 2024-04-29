--------------------------------------------------------
--  DDL for Package Body OE_BIS_ALERTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_BIS_ALERTS" AS
--$Header: OEXALRTB.pls 115.1 99/07/27 19:10:28 porting shi $

/* The Calculate_Actual function calculates the actual on-time shipment percentage or the return percentage
   depending upon the target level that is being calculated for. There are four target levels seeded in
   Release 11i for the Customer Satisfaction report ie. SHIPVALUE_TOP, SHIPVALUE_ALL, RETVALUE_TOP and RETVALUE_ALL.
   The code supports the calculation of only these four target levels. If additional target levels are added - we
   would need to add code in the calculate_actual function to handle the same */

/* Seeded Target Levels Definition
   SHIPVALUE_ALL :- On Time Shipment percentage for the following combination
   (Set of Books id * Year * All Sales Channel's * All Product Categories * All Geographical Area's)
   SHIPVALUE_TOP :- On Time Shipment percentage for the following combination
   (Set of Books id * Year * Sales Channel * Product Category * Geographical Area)
   RETVALUE_ALL :- Return percentage for the following combination
   (Set of Books id * Year * All Sales Channel's * All Product Categories * All Geographical Area's)
   RETVALUE_TOP :- Return percentage for the following combination
   (Set of Books id * Year * Sales Channel * Product Category * Geographical Area) */


FUNCTION Calculate_Actual
(
  p_set_of_books_id         VARCHAR2,
  p_sales_channel           VARCHAR2,
  p_prod_catg               VARCHAR2,
  p_area                    VARCHAR2,
  p_period_set_Name         VARCHAR2,
  p_time_period             VARCHAR2,
  p_target_level_short_name VARCHAR2
)
RETURN NUMBER

IS
l_actual_value NUMBER;
l_time_period VARCHAR2(80);

BEGIN
   l_actual_value := 0;

   if p_target_level_short_name = 'SHIPVALUE_TOP' then
      begin
        select year_period, decode(sum(net_sales),0,0,sum(del_sales)/sum(net_sales) * 100)
        into l_time_period, l_actual_value
        from oe_bis_cust_sat_v
        where set_of_books_id = p_set_of_books_id
        and sales_channel_code = p_sales_channel
        and category_id = p_prod_catg
        and area = p_area
        and   period_set_name || '+' || year_period = p_period_set_name
        group by year_period;
      exception
      when no_data_found then
        l_actual_value := -1;
      when others then
        l_actual_value := -2;
      end;
   elsif p_target_level_short_name = 'RETVALUE_TOP' then
      begin
        select year_period, decode(sum(net_sales),0,0,sum(ret_sales)/sum(net_sales) * 100)
	   into l_time_period, l_actual_value
        from oe_bis_cust_sat_v
        where set_of_books_id = p_set_of_books_id
        and sales_channel_code = p_sales_channel
        and category_id = P_prod_catg
        and area = p_area
        and   period_set_name || '+' || year_period = p_period_set_name
        group by year_period;
      exception
      when others then
        l_actual_value := 0;
      end;
   elsif p_target_level_short_name = 'SHIPVALUE_ALL' then
      begin
        select year_period, decode(sum(net_sales),0,0,sum(del_sales)/sum(net_sales) * 100)
        into l_time_period, l_actual_value
        from oe_bis_cust_sat_v
        where set_of_books_id = p_set_of_books_id
        and   period_set_name || '+' || year_period = p_period_set_name
        group by year_period;
      exception
      when others then
        l_actual_value := 0;
      end;
   elsif p_target_level_short_name = 'RETVALUE_ALL' then
      begin
        select year_period, decode(sum(net_sales),0,0,sum(ret_sales)/sum(net_sales) * 100)
        into l_time_period, l_actual_value
        from oe_bis_cust_sat_v
        where set_of_books_id = p_set_of_books_id
        and   period_set_name || '+' || year_period = p_period_set_name
        group by year_period;
      exception
      when others then
        l_actual_value := 0;
      end;
   end if;

   RETURN l_actual_value;

EXCEPTION
  WHEN OTHERS THEN
    l_actual_value := -1;

END Calculate_Actual;

/* Procedure process_alerts is called from the alert run by the alert manager responsibility. The two parameters
   that are passed are the target level short name for eg. SHIPVALUE_ALL and the time period is the accounting year
   for eg. Accounting+FY-99 */

/* User selected KPI's from the BIS home page are also updated with the actual values. BIS provided API's are used
   to retreive user selections and to post the actuals on the home page */

PROCEDURE process_alerts
( p_target_level_short_name    VARCHAR2,
  p_time_period                VARCHAR2
)
IS
l_period_set_name          VARCHAR2(30);
l_period_name              VARCHAR2(30);
l_target_short_name        VARCHAR2(30);
l_target_level_rec         BIS_TARGET_LEVEL_PUB.target_Level_Rec_Type;
l_error_tbl                BIS_UTILITIES_PUB.Error_Tbl_Type;
l_actual                   VARCHAR2(240);
l_period                   VARCHAR2(240);
actual                     NUMBER;
l_target                   VARCHAR2(240);
target                     NUMBER;
l_Target_Rec               BIS_TARGET_PUB.Target_Rec_Type;
l_Actual_Tbl               BIS_ACTUAL_PUB.Actual_Tbl_Type;
l_user_selection_tbl       BIS_INDICATOR_REGION_PUB.Indicator_Region_Tbl_Type;
l_workflow_process         VARCHAR2(30);
l_notify_resp              VARCHAR2(100);
l_responsibility_ID        NUMBER;
l_message                  VARCHAR2(1000);
l_param                    VARCHAR2(1000);
l_set_of_books_id          VARCHAR2(250);
l_organization_id          VARCHAR2(250);
l_sales_channel            VARCHAR2(80);
l_prod_catg                VARCHAR2(250);
l_area                     VARCHAR2(80);
l_msg_data                 VARCHAR2(250);
l_subject                  VARCHAR2(250);
l_return_status            VARCHAR2(1);
l_msg_count                NUMBER;
l_report_name              VARCHAR2(250);
l_exception_message        VARCHAR2(250);
l_org_name                 VARCHAR2(250);
l_catg_name                VARCHAR2(250);
l_start_date               VARCHAR2(15);
l_end_date                 VARCHAR2(15);
status                     VARCHAR2(30);
dim1_name                  VARCHAR2(80);
dim2_name                  VARCHAR2(80);
dim3_name                  VARCHAR2(80);
i                          NUMBER := 0;

CURSOR cr_set_of_books IS
  SELECT distinct set_of_books_id
  FROM   oe_bis_cust_sat_v;

CURSOR cr_target IS
  SELECT  tv.target_level_short_name
        , tv.target_level_name
        , tv.target_level_id
        , tv.plan_name
        , tv.org_level_value_id
        , tv.time_level_value_id
        , tv.dim1_level_value_id
        , tv.dim2_level_value_id
        , tv.dim3_level_value_id
        , tv.target
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
  FROM BISFV_TARGETS tv
  WHERE tv.target_level_short_name = p_target_level_short_name
  AND tv.time_level_value_id = p_time_period;

BEGIN

  l_target_level_rec.target_Level_Short_Name
    := p_target_Level_Short_Name;

  SELECT workflow_process_short_name
  INTO l_workflow_process
  FROM bisfv_target_levels
  WHERE target_level_short_name = p_target_Level_Short_Name;


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

  -- Calculate Actual for Set of Books
  FOR cr in cr_set_of_books LOOP

    l_organization_id := cr.set_of_books_id;

    -- Post actual value for only those KPIs users have selected.
    -- These user selected KPI's are picked up from the bis_user_ind_selections table

    FOR i IN 1..l_user_selection_Tbl.COUNT LOOP
      IF l_user_selection_tbl(i).org_level_value_id = l_organization_id THEN
        l_Actual_Tbl(i).target_Level_Short_Name
          := l_user_selection_tbl(i).target_level_short_name;
        l_Actual_Tbl(i).Org_Level_value_ID := l_organization_id;
        l_Actual_Tbl(i).time_Level_value_ID := p_time_period;
        l_Actual_Tbl(i).dim1_Level_value_ID := l_user_selection_tbl(i).dim1_Level_value_ID;
        l_Actual_Tbl(i).dim2_Level_value_ID := l_user_selection_tbl(i).dim2_Level_value_ID;
        l_Actual_Tbl(i).dim3_Level_value_ID := l_user_selection_tbl(i).dim3_level_value_ID;

        actual := Calculate_Actual
              ( p_set_of_books_id  => l_organization_id,
                p_sales_channel    => l_user_selection_tbl(i).dim1_level_value_ID,
                p_prod_catg        => l_user_selection_tbl(i).dim2_level_value_ID,
                p_area             => l_user_selection_tbl(i).dim3_level_value_ID,
                p_period_set_Name  => p_time_period,
                p_time_period      => p_time_period,
                p_target_level_short_name => p_target_level_short_name
              );

        l_Actual_Tbl(i).Actual := actual;

        BIS_ACTUAL_PUB.POST_ACTUAL
        ( p_api_version       => 1.0
         ,p_Actual_Rec        => l_actual_Tbl(i)
         ,x_return_status     => l_return_status
         ,x_msg_count         => l_msg_count
         ,x_msg_data          => l_msg_data
         ,x_error_tbl         => l_error_tbl
        );

      END IF;
    END LOOP;

  END LOOP;

  for cr in cr_target
   loop

      target := cr.target;

      actual := Calculate_Actual
              ( p_set_of_books_id  => cr.org_level_value_id,
                p_sales_channel    => cr.dim1_level_value_id,
                p_prod_catg        => cr.dim2_level_value_id,
                p_area             => cr.dim3_level_value_id,
                p_period_set_Name  => p_time_period,
                p_time_period      => p_time_period,
                p_target_level_short_name => p_target_level_short_name
              );


      postactual( cr.target_level_id,
                  cr.org_level_value_id,
                  p_time_period,
                  cr.dim1_level_value_id,
                  cr.dim2_level_value_id,
                  cr.dim3_level_value_id,
                  actual,
                  p_time_period);

      l_report_name := 'OEXCUSSA';


      begin
        select name into l_org_name
        from   gl_sets_of_books
        where  set_of_books_id = cr.org_level_value_id ;
      exception
	 when others then
	   l_org_name := null;
      end;

      begin
        select distinct category_desc into l_catg_name
        from   oe_bis_cust_sat_v
        where  category_id =  cr.dim2_level_value_id ;
      exception
	 when others then
	   l_catg_name := null;
      end;


      begin
        select to_char(start_date, 'DD-MON-YYYY'), to_char(end_date + 1,'DD-MON-YYYY')
               into l_start_date , l_end_date
        from   bis_years_v
        where period_set_name = substr(p_time_period, 1, instr(p_time_period,'+')-1) and
		    period_name = substr(p_time_period,instr(p_time_period,'+')+1, length(p_time_period)) and
              rownum = 1;
      exception
	 when others then
	   l_start_date := null;
	   l_end_date := null;
      end;

      -- This is for the description to appear in the notifications that are sent.

      if cr.dim1_level_value_id = '-1' then
         dim1_name := 'All Sales Channels';
      else
         dim1_name := cr.dim1_level_value_id;
      end if;

      if cr.dim2_level_value_id = '-1' then
         dim2_name := 'All Product Categories';
      else
         dim2_name := cr.dim2_level_value_id;
      end if;

      if cr.dim3_level_value_id = '-1' then
         dim3_name := 'All Areas';
      else
         dim3_name := cr.dim3_level_value_id;
      end if;

      -- Messages are seeded using Oracle Apps screens - so that customer can change the heading on the messages
      -- as per requirements

      l_subject := fnd_message.get_string('OE', 'OE_BIS_SUBJECT') || ' - ' || cr.target_level_name;
      l_set_of_books_id := fnd_message.get_string('OE', 'OE_BIS_SET_OF_BOOKS') || ': ' || cr.org_level_value_id ||
					  ' -  ' || l_org_name;
      l_area := fnd_message.get_string('OE', 'OE_BIS_AREA') || ': ' || dim3_name;
      l_prod_catg := fnd_message.get_string('OE', 'OE_BIS_PROD_CATEGORY') || ': ' || dim2_name;
      l_sales_channel := fnd_message.get_string('OE', 'OE_BIS_SALES_CHANNEL') || ': ' || dim1_name;
      l_period := fnd_message.get_string('OE', 'OE_BIS_PERIOD')|| ': ' || p_time_period;
      l_actual := fnd_message.get_string('OE', 'OE_BIS_ACTUAL')|| ': ' || round(actual, 2);
      l_target := fnd_message.get_string('OE', 'OE_BIS_TARGET')|| ': ' || round(target, 2);

      -- Reverting back because the report needs to be called with the right parameters.

      if cr.dim1_level_value_id = '-1' then
         dim1_name := '0';
      else
         dim1_name := cr.dim1_level_value_id;
      end if;

      if cr.dim2_level_value_id = '-1' then
         dim2_name := '0';
      else
         dim2_name := cr.dim2_level_value_id;
      end if;

      if cr.dim3_level_value_id = '-1' then
         dim3_name := '0';
      else
         dim3_name := cr.dim3_level_value_id;
      end if;

      -- setting up the parameter list for the url formulation

      l_param := 'P_PARAM_DATE_FROM=' || l_start_date ||
                '*P_PARAM_DATE_TO=' || l_end_date ||
                '*P_PARAM_ORG_LEVEL=1'||
                '*P_PARAM_ORGANIZATION=' || cr.org_level_value_id ||
                '*P_PARAM_CUST_LEVEL=1' ||
                '*P_PARAM_CUSTOMER=' || dim1_name ||
                '*P_PARAM_GEO_LEVEL=1' ||
                '*P_PARAM_GEOGRAPHY=' || dim3_name ||
                '*P_PARAM_PROD_LEVEL=1' ||
                '*P_PARAM_PRODUCT=' || dim2_name ||
                '*P_PARAM_VIEW_BY=1' ||
                '*paramform=NO' ||
                '*paramform=NO*';

      -- Actuals are compared to the targets that are set and depending upon the ranges that they fall in
      -- respective responsibities are contacted.

      IF actual < target THEN

        -- Check if actual is Within the first range
        IF actual < target - cr.range1_low
        THEN
           l_notify_resp := cr.Notify_Resp1_short_name;
           l_responsibility_id := cr.Notify_Resp1_ID;
		 if cr.target_level_short_name in ('SHIPVALUE_TOP','SHIPVALUE_ALL') then
              l_exception_message := 'A PMF target has been set to monitor Customer Satisfaction Percentages.' ||
						    ' This target has fallen short for the following :';
           else
              l_exception_message := 'A PMF target has been set to monitor Customer Satisfaction Percentages.' ||
						    ' We have exceeded the returns target for the following :';
		 end if;

           oe_strt_wf_process(
		 p_exception_message => l_exception_message,
           p_subject => l_subject,
           p_sob => l_set_of_books_id,
           p_area => l_area,
           p_prod_cat => l_prod_catg,
           p_sales_channel => l_sales_channel,
           p_period => l_period,
           p_target => l_target,
           p_actual => l_actual,
           p_wf_process => l_workflow_process,
           p_role => l_notify_resp,
           p_resp_id => l_responsibility_id,
           p_report_name => l_report_name,
           p_report_param => l_param,
           x_return_status => status);

        -- Check if actual is within the second range
        ELSIF actual < target - cr.range2_low
        THEN
           l_notify_resp := cr.Notify_Resp2_short_name;
           l_responsibility_id := cr.Notify_Resp2_ID;
		 if cr.target_level_short_name in ('SHIPVALUE_TOP','SHIPVALUE_ALL') then
              l_exception_message := 'A PMF target has been set to monitor Customer Satisfaction Percentages.' ||
						    ' This target has fallen short for the following :';
           else
              l_exception_message := 'A PMF target has been set to monitor Customer Satisfaction Percentages.' ||
						    ' We have exceeded the returns target for the following :';
		 end if;

           oe_strt_wf_process(
		 p_exception_message => l_exception_message,
           p_subject => l_subject,
           p_sob => l_set_of_books_id,
           p_area => l_area,
           p_prod_cat => l_prod_catg,
           p_sales_channel => l_sales_channel,
           p_period => l_period,
           p_target => l_target,
           p_actual => l_actual,
           p_wf_process => l_workflow_process,
           p_role => l_notify_resp,
           p_resp_id => l_responsibility_id,
           p_report_name => l_report_name,
           p_report_param => l_param,
           x_return_status => status);

           l_notify_resp := cr.Notify_Resp1_short_name;
           l_responsibility_id := cr.Notify_Resp1_ID;

           oe_strt_wf_process(
		 p_exception_message => l_exception_message,
           p_subject => l_subject,
           p_sob => l_set_of_books_id,
           p_area => l_area,
           p_prod_cat => l_prod_catg,
           p_sales_channel => l_sales_channel,
           p_period => l_period,
           p_target => l_target,
           p_actual => l_actual,
           p_wf_process => l_workflow_process,
           p_role => l_notify_resp,
           p_resp_id => l_responsibility_id,
           p_report_name => l_report_name,
           p_report_param => l_param,
           x_return_status => status);

        -- Check if actual is within the third range
        ELSIF actual < target - cr.range3_low
        THEN
           l_notify_resp := cr.Notify_Resp3_short_name;
           l_responsibility_id := cr.Notify_Resp3_ID;
		 if cr.target_level_short_name in ('SHIPVALUE_TOP','SHIPVALUE_ALL') then
              l_exception_message := 'A PMF target has been set to monitor Customer Satisfaction Percentages.' ||
						    ' This target has fallen short for the following :';
           else
              l_exception_message := 'A PMF target has been set to monitor Customer Satisfaction Percentages.' ||
						    ' We have exceeded the returns target for the following :';
		 end if;

           oe_strt_wf_process(
		 p_exception_message => l_exception_message,
           p_subject => l_subject,
           p_sob => l_set_of_books_id,
           p_area => l_area,
           p_prod_cat => l_prod_catg,
           p_sales_channel => l_sales_channel,
           p_period => l_period,
           p_target => l_target,
           p_actual => l_actual,
           p_wf_process => l_workflow_process,
           p_role => l_notify_resp,
           p_resp_id => l_responsibility_id,
           p_report_name => l_report_name,
           p_report_param => l_param,
           x_return_status => status);

           l_notify_resp := cr.Notify_Resp2_short_name;
           l_responsibility_id := cr.Notify_Resp2_ID;

           oe_strt_wf_process(
		 p_exception_message => l_exception_message,
           p_subject => l_subject,
           p_sob => l_set_of_books_id,
           p_area => l_area,
           p_prod_cat => l_prod_catg,
           p_sales_channel => l_sales_channel,
           p_period => l_period,
           p_target => l_target,
           p_actual => l_actual,
           p_wf_process => l_workflow_process,
           p_role => l_notify_resp,
           p_resp_id => l_responsibility_id,
           p_report_name => l_report_name,
           p_report_param => l_param,
           x_return_status => status);

           l_notify_resp := cr.Notify_Resp1_short_name;
           l_responsibility_id := cr.Notify_Resp1_ID;

           oe_strt_wf_process(
		 p_exception_message => l_exception_message,
           p_subject => l_subject,
           p_sob => l_set_of_books_id,
           p_area => l_area,
           p_prod_cat => l_prod_catg,
           p_sales_channel => l_sales_channel,
           p_period => l_period,
           p_target => l_target,
           p_actual => l_actual,
           p_wf_process => l_workflow_process,
           p_role => l_notify_resp,
           p_resp_id => l_responsibility_id,
           p_report_name => l_report_name,
           p_report_param => l_param,
           x_return_status => status);

        ELSE
        -- if targets have not been set by the user then resp1 is notified
           l_notify_resp := cr.Notify_Resp1_short_name;
           l_responsibility_id := cr.Notify_Resp1_ID;
		 if cr.target_level_short_name in ('SHIPVALUE_TOP','SHIPVALUE_ALL') then
              l_exception_message := 'A PMF target has been set to monitor Customer Satisfaction Percentages.' ||
						    ' This target has fallen short for the following :';
           else
              l_exception_message := 'A PMF target has been set to monitor Customer Satisfaction Percentages.' ||
						    ' We have exceeded the returns target for the following :';
		 end if;

           oe_strt_wf_process(
		 p_exception_message => l_exception_message,
           p_subject => l_subject,
           p_sob => l_set_of_books_id,
           p_area => l_area,
           p_prod_cat => l_prod_catg,
           p_sales_channel => l_sales_channel,
           p_period => l_period,
           p_target => l_target,
           p_actual => l_actual,
           p_wf_process => l_workflow_process,
           p_role => l_notify_resp,
           p_resp_id => l_responsibility_id,
           p_report_name => l_report_name,
           p_report_param => l_param,
           x_return_status => status);

        END IF;

      -- We're more on target....
      ELSIF actual > target THEN

        -- Check if actual is within the first range
        IF actual > target + cr.range1_high
        THEN
           l_notify_resp := cr.Notify_Resp1_short_name;
           l_responsibility_id := cr.Notify_Resp1_ID;
		 if cr.target_level_short_name in ('SHIPVALUE_TOP','SHIPVALUE_ALL') then
              l_exception_message := 'A PMF target has been set to monitor Customer Satisfaction Percentages.' ||
						    ' This target has been exceeded for the following :';
           else
              l_exception_message := 'A PMF target has been set to monitor Customer Satisfaction Percentages.' ||
						    ' We have done well to fall short of the allowed returns for the following :';
		 end if;
           oe_strt_wf_process(
		 p_exception_message => l_exception_message,
           p_subject => l_subject,
           p_sob => l_set_of_books_id,
           p_area => l_area,
           p_prod_cat => l_prod_catg,
           p_sales_channel => l_sales_channel,
           p_period => l_period,
           p_target => l_target,
           p_actual => l_actual,
           p_wf_process => l_workflow_process,
           p_role => l_notify_resp,
           p_resp_id => l_responsibility_id,
           p_report_name => l_report_name,
           p_report_param => l_param,
           x_return_status => status);

        -- Check if actual is within the second range
        ELSIF actual > target + cr.range2_high
        THEN
           l_notify_resp := cr.Notify_Resp2_short_name;
           l_responsibility_id := cr.Notify_Resp2_ID;
		 if cr.target_level_short_name in ('SHIPVALUE_TOP','SHIPVALUE_ALL') then
              l_exception_message := 'A PMF target has been set to monitor Customer Satisfaction Percentages.' ||
						    ' This target has been exceeded for the following :';
           else
              l_exception_message := 'A PMF target has been set to monitor Customer Satisfaction Percentages.' ||
						    ' We have done well to fall short of the allowed returns for the following :';
		 end if;

           oe_strt_wf_process(
		 p_exception_message => l_exception_message,
           p_subject => l_subject,
           p_sob => l_set_of_books_id,
           p_area => l_area,
           p_prod_cat => l_prod_catg,
           p_sales_channel => l_sales_channel,
           p_period => l_period,
           p_target => l_target,
           p_actual => l_actual,
           p_wf_process => l_workflow_process,
           p_role => l_notify_resp,
           p_resp_id => l_responsibility_id,
           p_report_name => l_report_name,
           p_report_param => l_param,
           x_return_status => status);

           l_notify_resp := cr.Notify_Resp1_short_name;
           l_responsibility_id := cr.Notify_Resp1_ID;


           oe_strt_wf_process(
		 p_exception_message => l_exception_message,
           p_subject => l_subject,
           p_sob => l_set_of_books_id,
           p_area => l_area,
           p_prod_cat => l_prod_catg,
           p_sales_channel => l_sales_channel,
           p_period => l_period,
           p_target => l_target,
           p_actual => l_actual,
           p_wf_process => l_workflow_process,
           p_role => l_notify_resp,
           p_resp_id => l_responsibility_id,
           p_report_name => l_report_name,
           p_report_param => l_param,
           x_return_status => status);

        -- Check if actual is within the third range
        ELSIF actual > target + cr.range3_high
        THEN
           l_notify_resp := cr.Notify_Resp3_short_name;
           l_responsibility_id := cr.Notify_Resp3_ID;
		 if cr.target_level_short_name in ('SHIPVALUE_TOP','SHIPVALUE_ALL') then
              l_exception_message := 'A PMF target has been set to monitor Customer Satisfaction Percentages.' ||
						    ' This target has been exceeded for the following :';
           else
              l_exception_message := 'A PMF target has been set to monitor Customer Satisfaction Percentages.' ||
						    ' We have done well to fall short of the allowed returns for the following :';
		 end if;

           oe_strt_wf_process(
		 p_exception_message => l_exception_message,
           p_subject => l_subject,
           p_sob => l_set_of_books_id,
           p_area => l_area,
           p_prod_cat => l_prod_catg,
           p_sales_channel => l_sales_channel,
           p_period => l_period,
           p_target => l_target,
           p_actual => l_actual,
           p_wf_process => l_workflow_process,
           p_role => l_notify_resp,
           p_resp_id => l_responsibility_id,
           p_report_name => l_report_name,
           p_report_param => l_param,
           x_return_status => status);


           l_notify_resp := cr.Notify_Resp2_short_name;
           l_responsibility_id := cr.Notify_Resp2_ID;

           oe_strt_wf_process(
		 p_exception_message => l_exception_message,
           p_subject => l_subject,
           p_sob => l_set_of_books_id,
           p_area => l_area,
           p_prod_cat => l_prod_catg,
           p_sales_channel => l_sales_channel,
           p_period => l_period,
           p_target => l_target,
           p_actual => l_actual,
           p_wf_process => l_workflow_process,
           p_role => l_notify_resp,
           p_resp_id => l_responsibility_id,
           p_report_name => l_report_name,
           p_report_param => l_param,
           x_return_status => status);


           l_notify_resp := cr.Notify_Resp1_short_name;
           l_responsibility_id := cr.Notify_Resp1_ID;

           oe_strt_wf_process(
		 p_exception_message => l_exception_message,
           p_subject => l_subject,
           p_sob => l_set_of_books_id,
           p_area => l_area,
           p_prod_cat => l_prod_catg,
           p_sales_channel => l_sales_channel,
           p_period => l_period,
           p_target => l_target,
           p_actual => l_actual,
           p_wf_process => l_workflow_process,
           p_role => l_notify_resp,
           p_resp_id => l_responsibility_id,
           p_report_name => l_report_name,
           p_report_param => l_param,
           x_return_status => status);


        ELSE
        -- if targets have not been set by the user then resp1 is notified
           l_notify_resp := cr.Notify_Resp1_short_name;
           l_responsibility_id := cr.Notify_Resp1_ID;
		 if cr.target_level_short_name in ('SHIPVALUE_TOP','SHIPVALUE_ALL') then
              l_exception_message := 'A PMF target has been set to monitor Customer Satisfaction Percentages.' ||
						    ' This target has been exceeded for the following :';
           else
              l_exception_message := 'A PMF target has been set to monitor Customer Satisfaction Percentages.' ||
						    ' We have done well to fall short of the allowed returns for the following :';
		 end if;

           oe_strt_wf_process(
		 p_exception_message => l_exception_message,
           p_subject => l_subject,
           p_sob => l_set_of_books_id,
           p_area => l_area,
           p_prod_cat => l_prod_catg,
           p_sales_channel => l_sales_channel,
           p_period => l_period,
           p_target => l_target,
           p_actual => l_actual,
           p_wf_process => l_workflow_process,
           p_role => l_notify_resp,
           p_resp_id => l_responsibility_id,
           p_report_name => l_report_name,
           p_report_param => l_param,
           x_return_status => status);

        END IF;
      END IF;

    END LOOP;  -- ends loop to check targets

EXCEPTION
  WHEN OTHERS THEN
  l_message := 'Exception in Alert Procedure.';

END PROCESS_ALERTS;

-- Calls the BIS post_actual API

PROCEDURE postactual( target_level_id        in number,
                      org_level_value        in varchar2,
                      time_level_value       in varchar2,
                      dimension1_level_value In varchar2,
                      dimension2_level_value in varchar2,
                      dimension3_level_value in varchar2,
                      actual                 in number,
                      period_set_name        in varchar2) IS

  actual_rec BIS_ACTUAL_PUB.Actual_Rec_Type;
  x_return_status VARCHAR2(30);
  x_msg_count     NUMBER;
  x_msg_data      VARCHAR2(30);
  x_error_Tbl     BIS_UTILITIES_PUB.Error_Tbl_Type;

BEGIN
  actual_rec.Target_Level_ID := target_level_id;
  actual_rec.Time_Level_Value_ID := time_level_value;
  actual_rec.Org_Level_value_ID := org_level_value;
  actual_rec.Dim1_Level_Value_ID := dimension1_level_value;
  actual_rec.Dim2_Level_Value_ID := dimension2_level_value;
  actual_rec.Dim3_Level_Value_ID := dimension3_level_value;
  actual_rec.Actual := actual;

  BIS_ACTUAL_PUB.Post_Actual( p_api_version => 1,
                              p_commit => FND_API.G_TRUE,
                              p_Actual_Rec => actual_rec,
                              x_return_status => x_return_status,
                              x_msg_count => x_msg_count,
                              x_msg_data => x_msg_data,
                              x_error_Tbl => x_error_Tbl);


END PostActual;

-- starting the Oracle Workflow Builder process to initiate the workflow notification process.

PROCEDURE oe_strt_wf_process(
       p_exception_message IN varchar2,
       p_subject          IN varchar2,
       p_sob              IN varchar2,
       p_area             IN varchar2,
       p_prod_cat         IN varchar2,
       p_sales_channel    IN varchar2,
       p_period           IN varchar2,
       p_target           IN varchar2,
       p_actual           IN varchar2,
       p_wf_process       IN varchar2,
       p_role             IN varchar2,
       p_resp_id          IN number,
       p_report_name      IN varchar2,
       p_report_param     IN varchar2,
       x_return_status    OUT varchar2
) IS
l_wf_item_key       Number;
l_item_type         Varchar2(30) := 'OEBISWF';
l_report_link       Varchar2(500);
l_role_name         Varchar2(80);
l_url1              Varchar2(2000);

cursor c_role_name is
   select name from wf_roles
   where name = p_role;

BEGIN


   x_return_status := FND_API.G_RET_STS_SUCCESS;
   if p_wf_process is null
      or p_role is null then
      x_return_status := FND_API.G_RET_STS_ERROR;
      return;
   end if;

   open c_role_name;
   fetch c_role_name into l_role_name;
   if c_role_name%NOTFOUND then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      return;
   end if;

   select bis_excpt_wf_s.nextval
   into l_wf_item_key
   from dual;

   l_report_link  := FND_PROFILE.value('ICX_REPORT_LINK');

   if p_report_name is not null then
      l_url1 := l_report_link ||  'OracleOASIS.RunReport?report='|| p_report_name|| '&parameters='
                              || p_report_param || '&responsibility_id=' || p_resp_id;
   end if;


   -- create a new workflow process
   wf_engine.CreateProcess(itemtype=>l_item_type
                           ,itemkey =>l_wf_item_key
                           ,process =>p_wf_process);

   -- set the workflow attributes
   wf_engine.SetItemAttrText(itemtype=>l_item_type
                             ,itemkey =>l_wf_item_key
                             ,aname=>'L_ROLE_NAME'
                             ,avalue=>L_ROLE_NAME);
   wf_engine.SetItemAttrText(itemtype=>l_item_type
                             ,itemkey =>l_wf_item_key
                             ,aname=>'L_EXCEPTION_MESSAGE'
                             ,avalue=>p_exception_message);
   wf_engine.SetItemAttrText(itemtype=>l_item_type
                             ,itemkey =>l_wf_item_key
                             ,aname=>'L_SUBJECT'
                             ,avalue=>p_subject);
   wf_engine.SetItemAttrText(itemtype=>l_item_type
                             ,itemkey =>l_wf_item_key
                             ,aname=>'L_SOB'
                             ,avalue=>p_sob);
   wf_engine.SetItemAttrText(itemtype=>l_item_type
                             ,itemkey =>l_wf_item_key
                             ,aname=>'L_AREA'
                             ,avalue=>p_area);
   wf_engine.SetItemAttrText(itemtype=>l_item_type
                             ,itemkey =>l_wf_item_key
                             ,aname=>'L_PROD_CAT'
                             ,avalue=>p_prod_cat);
   wf_engine.SetItemAttrText(itemtype=>l_item_type
                             ,itemkey =>l_wf_item_key
                             ,aname=>'L_SALES_CHANNEL'
                             ,avalue=>p_sales_channel);
   wf_engine.SetItemAttrText(itemtype=>l_item_type
                             ,itemkey =>l_wf_item_key
                             ,aname=>'L_PERIOD'
                             ,avalue=>p_period);
   wf_engine.SetItemAttrText(itemtype=>l_item_type
                             ,itemkey =>l_wf_item_key
                             ,aname=>'L_TARGET'
                             ,avalue=>p_target);
   wf_engine.SetItemAttrText(itemtype=>l_item_type
                             ,itemkey =>l_wf_item_key
                             ,aname=>'L_ACTUAL'
                             ,avalue=>p_actual);
   if l_url1 is not null then
       wf_engine.SetItemAttrText(itemtype=>l_item_type
                                 ,itemkey =>l_wf_item_key
                                 ,aname=>'L_URL1'
                                 ,avalue=>l_url1);
   end if;

   -- start the process
   wf_engine.StartProcess(itemtype=>l_item_type
                          ,itemkey => l_wf_item_key);

END oe_strt_wf_process;


END OE_BIS_ALERTS;

/
