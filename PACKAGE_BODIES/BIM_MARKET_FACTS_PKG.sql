--------------------------------------------------------
--  DDL for Package Body BIM_MARKET_FACTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIM_MARKET_FACTS_PKG" AS
/*$Header: bimmktfb.pls 120.8 2005/12/20 02:09:32 arvikuma noship $*/

g_pkg_name  CONSTANT  VARCHAR2(20) := 'BIM_MARKET_FACTS_PKG';
g_file_name CONSTANT  VARCHAR2(20) := 'bimmktfb.pls';
l_global_currency_code CONSTANT varchar2(20) := bis_common_parameters.get_currency_code;
l_secondary_currency_code CONSTANT VARCHAR2(20) :=bis_common_parameters.get_secondary_currency_code;
l_pgc_rate_type CONSTANT VARCHAR2(20) :=bis_common_parameters.Get_Rate_Type;
l_sgc_rate_type CONSTANT VARCHAR2(20) :=bis_common_parameters.Get_secondary_Rate_Type;
FUNCTION ret_max_date(p_sales_lead_id in number) return date is
  CURSOR get_max_date IS
  SELECT max(b.creation_date)
  FROM as_sales_leads a, as_sales_leads_log b
  WHERE a.sales_lead_id = b.sales_lead_id
  AND  b.sales_lead_id =  p_sales_lead_id ;

  l_date date;

BEGIN
  OPEN get_max_date;
  FETCH get_max_date into l_date;
  CLOSE get_max_date;

  RETURN l_date;
END;

-- Checks for any missing currency from marketing facts table

FUNCTION Check_Missing_Rates (p_start_date IN Date)
Return NUMBER
AS
 l_cnt_miss_rate1 Number := 0;
 l_cnt_miss_rate2 Number := 0;
 l_msg_name      Varchar2(40);

 CURSOR C_missing_rates1
 IS
   SELECT tc_code from_currency,
          decode(prim_conversion_rate,-3,to_date('01/01/1999','MM/DD/RRRR'),trx_date) transaction_create_date
   FROM BIM_I_MKT_RATES
   WHERE prim_conversion_rate < 0
   AND tc_code is not null
   AND trx_date >= p_start_date
   ORDER BY tc_code,
            trx_date ;

 CURSOR C_missing_rates2
 IS
    SELECT tc_code from_currency,
          decode(sec_conversion_rate,-3,to_date('01/01/1999','MM/DD/RRRR'),trx_date) transaction_create_date
   FROM BIM_I_MKT_RATES
   WHERE sec_conversion_rate < 0
   AND tc_code is not null
   AND trx_date >= p_start_date
   ORDER BY tc_code,
            trx_date ;
BEGIN
 l_msg_name := 'BIS_DBI_CURR_NO_LOAD';
 SELECT COUNT(*) INTO l_cnt_miss_rate1 FROM BIM_I_MKT_RATES
 WHERE
 prim_conversion_rate < 0
 AND tc_code is not null
 AND trx_date >= p_start_date;

 SELECT COUNT(*) INTO l_cnt_miss_rate2 FROM BIM_I_MKT_RATES
 WHERE
 sec_conversion_rate <0
 AND tc_code is not null
 AND trx_date >= p_start_date;

 If(l_cnt_miss_rate1 > 0 )
 Then
   FND_MESSAGE.Set_Name('FII',l_msg_name);
   BIS_COLLECTION_UTILITIES.debug(l_msg_name||': '||FND_MESSAGE.get);
   BIS_COLLECTION_UTILITIES.log('Primary Conversion rate could not be found for the given currency. Please check output file for more details' );
   BIS_COLLECTION_UTILITIES.writeMissingRateHeader;

   FOR rate_record in C_missing_rates1
   LOOP
		BIS_COLLECTION_UTILITIES.writeMissingRate(
		p_rate_type => l_pgc_rate_type,
        	p_from_currency => rate_record.from_currency,
        	p_to_currency => l_global_currency_code,
        	p_date => rate_record.transaction_create_date);
   END LOOP;
   BIS_COLLECTION_UTILITIES.debug('before returning -1' );
   RETURN -1;
  ELSE
 Return 1;
 End If;
 If(l_cnt_miss_rate2 > 0 and l_secondary_currency_code is not null )
 Then
   FND_MESSAGE.Set_Name('FII',l_msg_name);
   BIS_COLLECTION_UTILITIES.debug(l_msg_name||': '||FND_MESSAGE.get);
   BIS_COLLECTION_UTILITIES.log('Secondary Conversion rate could not be found for the given currency. Please check output file for more details' );
   BIS_COLLECTION_UTILITIES.writeMissingRateHeader;

   FOR rate_record in C_missing_rates2
   LOOP
		BIS_COLLECTION_UTILITIES.writeMissingRate(
		p_rate_type => l_sgc_rate_type,
        	p_from_currency => rate_record.from_currency,
        	p_to_currency => l_secondary_currency_code,
        	p_date => rate_record.transaction_create_date);
   END LOOP;
    BIS_COLLECTION_UTILITIES.debug('before returning -1' );
   RETURN -1;
 ELSE
 Return 1;
 End If;
EXCEPTION
 WHEN OTHERS THEN
   BIS_COLLECTION_UTILITIES.Debug('Error in Check_missing_rates:'||sqlerrm);
   RAISE;
END Check_Missing_Rates;

---------------------------------------------------------------------------------------------------
/* This procedure will conditionally call the FIRST_LOAD or the SUB_LOAD */
---------------------------------------------------------------------------------------------------

PROCEDURE POPULATE
   (
     p_api_version_number      IN  NUMBER
    ,p_init_msg_list           IN  VARCHAR2
    ,p_validation_level        IN  NUMBER
    ,p_commit                  IN  VARCHAR2
    ,x_msg_count               OUT NOCOPY NUMBER
    ,x_msg_data                OUT NOCOPY VARCHAR2
    ,x_return_status           OUT NOCOPY VARCHAR2
    ,p_start_date              IN  DATE
    ,p_end_date                IN  DATE
    ,p_para_num                IN  NUMBER
    ,p_truncate_flg	       IN  VARCHAR2
    ) IS

    l_profile                 NUMBER;
    v_error_code              NUMBER;
    v_error_text              VARCHAR2(1500);
    l_last_update_date        DATE;
    l_user_id                 NUMBER := FND_GLOBAL.USER_ID();
    l_api_version_number      CONSTANT NUMBER       := 1.0;
    l_api_name                CONSTANT VARCHAR2(30) := 'POPULATE';
    l_success                 VARCHAR2(3);
    l_mesg_text		      VARCHAR2(100);
    l_load_type	              VARCHAR2(100);
    l_period_error	      VARCHAR2(5000);
    l_currency_error	      VARCHAR2(5000);
    l_err_code	              NUMBER;
    l_count number := 0;
    l_global_start_date       DATE;
    l_missing_date            BOOLEAN := FALSE;

    l_conc_start_date         DATE;
    l_conc_end_date           DATE;
    l_start_date              DATE;
    l_end_date                DATE;
    l_sysdate		      DATE;
    l_global_date	      DATE;

BEGIN

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                     p_api_version_number,
                                     l_api_name,
                                     g_pkg_name)
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list )
    THEN
      FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API return status to SUCCESS
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Debug Message
    -- AMS_UTILITY_PVT.debug_message('Private API: ' ||  'Running the populate procedure');
   BIS_COLLECTION_UTILITIES.log('BIM_I_MARKETING_FACTS: Facts load starts at:'||sysdate);

  l_global_start_date :=BIS_COMMON_PARAMETERS.GET_GLOBAL_START_DATE();

     /* THIS CODE REPLACES THE GET_LAST_REFRESH_PERIOD TO GET_LAST_REFRESH_DATES */

        bis_collection_utilities.get_last_refresh_dates('MARKETING_FACTS'
                        ,l_conc_start_date,l_conc_end_date,l_start_date,l_end_date);


        IF (l_end_date IS NULL) THEN

                IF (p_start_date  IS NULL) THEN
                  bis_collection_utilities.log('Please run the Upadate Marketing Facts First Time Base Summary concurrent program before running this');
                  RAISE FND_API.G_EXC_ERROR;
                END IF;

                IF (p_start_date >= p_end_date) THEN
                  bis_collection_utilities.log('Start Date Can not be greater than End Date');
                  RAISE FND_API.G_EXC_ERROR;
                END IF;
                --Validate time dimension tables
                fii_time_api.check_missing_date (greatest(l_global_start_date,p_start_date), sysdate, l_missing_date);
                IF (l_missing_date) THEN
                   bis_collection_utilities.log('Time dimension has at least one missing date between ' || greatest(l_global_start_date,p_start_date) || ' and ' || sysdate);
                   RAISE FND_API.G_EXC_ERROR;
                END IF;

                l_load_type  := 'FIRST_LOAD';
                BIS_COLLECTION_UTILITIES.log('BIM_I_MARKETING_FACTS: First Load');
                FIRST_LOAD(p_start_date => greatest(l_global_start_date,p_start_date)
                     ,p_end_date =>  sysdate
                     ,p_api_version_number => l_api_version_number
                     ,p_init_msg_list => FND_API.G_FALSE
                     ,p_load_type => l_load_type
                     ,x_msg_count => x_msg_count
                     ,x_msg_data   => x_msg_data
                     ,x_return_status => x_return_status
                 );

        ELSE
                --i.e Incremental has to be executed.
		IF p_truncate_flg = 'Y' THEN

			l_load_type  := 'FIRST_LOAD';
			l_sysdate := sysdate;

			FIRST_LOAD(p_start_date => greatest(l_global_start_date,p_start_date)
				,p_end_date =>  l_sysdate
				,p_api_version_number => l_api_version_number
				,p_init_msg_list => FND_API.G_FALSE
               			,p_load_type => l_load_type
				,x_msg_count => x_msg_count
				,x_msg_data   => x_msg_data
				,x_return_status => x_return_status
			);
		ELSE

			IF (l_end_date >=  sysdate) THEN
	                  bis_collection_utilities.log('Load Progarm already run upto ' || l_end_date);
		          RAISE FND_API.g_exc_error;
			END IF;
	                 --Validate time dimension tables
		          fii_time_api.check_missing_date (l_end_date, sysdate, l_missing_date);
			IF (l_missing_date) THEN
	                   bis_collection_utilities.log('Time dimension has atleast one missing date between ' || l_end_date || ' and ' || sysdate);
		           RAISE FND_API.G_EXC_ERROR;
			END IF;

	                l_load_type  := 'SUBSEQUENT_LOAD';
		        /*BIS_COLLECTION_UTILITIES.log('BIM_I_MARKETING_FACTS: Incremental Load');
			 SUB_LOAD(p_start_date => l_end_date +1/86400
	                     ,p_end_date =>  sysdate
		             ,p_api_version_number => l_api_version_number
			     ,p_init_msg_list => FND_API.G_FALSE
	                     ,p_load_type => l_load_type
		             ,x_msg_count => x_msg_count
			     ,x_msg_data   => x_msg_data
	                     ,x_return_status => x_return_status
		         );*/

			BIS_COLLECTION_UTILITIES.log('BIM_I_MARKETING_FACTS: Incremental Load');
	                 SUB_LOAD(p_start_date => trunc(l_end_date)
		             ,p_end_date =>  sysdate
			     ,p_api_version_number => l_api_version_number
	                     ,p_init_msg_list => FND_API.G_FALSE
		             ,p_load_type => l_load_type
			     ,x_msg_count => x_msg_count
	                     ,x_msg_data   => x_msg_data
		             ,x_return_status => x_return_status
			 );
		END IF;
	END IF;

                 IF    x_return_status = FND_API.g_ret_sts_error
                 THEN
                       RAISE FND_API.g_exc_error;
                 ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
                       RAISE FND_API.g_exc_unexpected_error;
                 END IF;
    --Standard check of commit

       IF FND_API.To_Boolean ( p_commit ) THEN
       COMMIT WORK;
       END IF;

    COMMIT;
    BIS_COLLECTION_UTILITIES.log('BIM_I_MARKETING_FACTS: Facts Concurrent Program Succesfully Completed');

    -- Standard call to get message count and if count is 1, get message info.
     FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_msg_PUB.Count_And_Get (
          --  p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );


   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

     /* FOR l_counter IN 1 .. x_msg_count
     LOOP
      l_mesg_text := fnd_msg_pub.get (p_encoded => fnd_api.g_false);
	fnd_msg_pub.dump_msg(l_counter);
     end loop;   */

     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_msg_PUB.Count_And_Get (
            --p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_msg_PUB.Check_msg_Level ( FND_msg_PUB.G_msg_LVL_UNEXP_ERROR)
     THEN
        FND_msg_PUB.Add_Exc_msg( g_pkg_name,l_api_name);
     END IF;
     -- Standard call to get message count and if count=1, get the message
/*     FND_msg_PUB.Count_And_Get (
           -- p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );*/

END POPULATE;


--------------------------------------------------------------------------------------------------
-- This procedure will excute when data is loaded for the first time

--  PROCEDURE  FIRST_LOAD
--------------------------------------------------------------------------------------------------

PROCEDURE FIRST_LOAD
( p_start_date            IN  DATE
 ,p_end_date              IN  DATE
 ,p_api_version_number    IN  NUMBER
 ,p_init_msg_list         IN  VARCHAR2
 ,p_load_type             IN  VARCHAR2
 ,x_msg_count             OUT NOCOPY NUMBER
 ,x_msg_data              OUT NOCOPY VARCHAR2
 ,x_return_status         OUT NOCOPY VARCHAR2
)
IS
    l_user_id              	  NUMBER := FND_GLOBAL.USER_ID();
    l_start_date   		  DATE;
    l_end_date     		  DATE;
    l_last_update_date     	  DATE;
    l_success              	  VARCHAR2(3);
    l_api_version_number   	  CONSTANT NUMBER       := 1.0;
    l_api_name             	  CONSTANT VARCHAR2(30) := 'FIRST_LOAD';
    l_seq_name             	  VARCHAR(100);
    l_table_name		  VARCHAR2(100);
    l_temp_msg		          VARCHAR2(100);
    l_global_currency_code        VARCHAR2(50);
    l_check_missing_rate          NUMBER;
    l_stmt                        VARCHAR2(50);
    l_min_date			  date;

    l_status                      VARCHAR2(5);
    l_industry                    VARCHAR2(5);
    l_schema                      VARCHAR2(30);
    l_return                       BOOLEAN;

BEGIN

    l_return  := fnd_installation.get_app_info('BIM', l_status, l_industry, l_schema);

   --dbms_output.put_line('inside first load:'|| p_start_date || ' '|| p_end_date);
   l_global_currency_code := bis_common_parameters.get_currency_code;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           g_pkg_name)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list )
   THEN
      FND_msg_PUB.initialize;
   END IF;

   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   --dbms_output.put_line('BIM_I_MARKETING_FACTS: Running the First Load '||sqlerrm(sqlcode));

   -- The below four commands are necessary for the purpose of the parallel insertion */
   BEGIN
   EXECUTE IMMEDIATE 'ALTER SESSION ENABLE PARALLEL dml ';
   --EXECUTE IMMEDIATE 'ALTER SESSION SET SORT_AREA_SIZE=100000000 ';
   --EXECUTE IMMEDIATE 'ALTER SESSION SET HASH_AREA_SIZE=100000000 ';
   --EXECUTE IMMEDIATE 'ALTER TABLE   bim_i_marketing_facts nologging ';
   -- EXECUTE IMMEDIATE 'ALTER SEQUENCE BIM_I_MARKETING_FACTS_s CACHE 1000 ';


   /* Piece of Code for retrieving,storing storage parameters and Dropping the indexes */
   /*fnd_message.set_name('BIM','BIM_R_DROP_INDEXES');
      fnd_file.put_line(fnd_file.log,fnd_message.get);*/
      BIS_COLLECTION_UTILITIES.log('BIM_I_MARKETING_FACTS:Drop index before inserting.');
      BIM_UTL_PKG.drop_index('BIM_I_MARKETING_FACTS');
   /* End of Code for dropping the existing indexes */
   EXCEPTION when others then
   BIS_COLLECTION_UTILITIES.log('BIM_I_MARKETING_FACTS: error:'||sqlerrm(sqlcode));
   --dbms_output.put_line('error first:'||sqlerrm(sqlcode));
   END;
   EXECUTE IMMEDIATE 'TRUNCATE table '||l_schema||'.BIM_I_MARKETING_FACTS_STG';
   EXECUTE IMMEDIATE 'TRUNCATE table '||l_schema||'.BIM_I_MKT_RATES';
   l_table_name :='bim_i_marketing_facts';
      BIS_COLLECTION_UTILITIES.log('BIM_I_MARKETING_FACTS:Inserting table bim_i_marketing_facts_stg');
   /*fnd_message.set_name('BIM','BIM_R_POPULATE_TABLE');
   fnd_message.set_token('TABLE_NAME',l_table_name, FALSE);
   fnd_file.put_line(fnd_file.log,fnd_message.get);*/
  -- dbms_output.put_Line('JUST BEFORE THE MAIN INSERT STATMENT');
      INSERT /*+ append parallel */
      INTO BIM_I_MARKETING_FACTS_STG CDF      (
              --MKT_DAILY_TRANSACTION_ID  ,
              CREATION_DATE             ,
              LAST_UPDATE_DATE          ,
              CREATED_BY                ,
              LAST_UPDATED_BY           ,
              LAST_UPDATE_LOGIN         ,
	      TRANSACTION_CREATE_DATE   ,
	      LEAD_ID                   ,
	      METRIC_TYPE               ,
              SOURCE_CODE_ID            ,
              OBJECT_TYPE               ,
              OBJECT_ID                 ,
              CHILD_OBJECT_TYPE         ,
              CHILD_OBJECT_ID           ,
              LEAD_RANK_ID              ,
              OBJECT_COUNTRY            ,
              OBJECT_REGION             ,
              CHILD_OBJECT_COUNTRY      ,
              CHILD_OBJECT_REGION       ,
              CATEGORY_ID               ,
	      BUSINESS_UNIT_ID          ,
              START_DATE                ,
              END_DATE                  ,
              OBJECT_STATUS             ,
              CHILD_OBJECT_STATUS       ,
              OBJECT_PURPOSE            ,
              CHILD_OBJECT_PURPOSE      ,
              ACTIVITY_TYPE             ,
              ACTIVITY_ID               ,
	      CONVERSION_RATE           ,
	      FROM_CURRENCY             ,
              LEADS                     ,
              OPPORTUNITIES             ,
              OPPORTUNITY_AMT           ,
              OPPORTUNITIES_OPEN        ,
              ORDERS_BOOKED             ,
              ORDERS_BOOKED_AMT         ,
              REVENUE_FORECASTED        ,
              REVENUE_ACTUAL            ,
              COST_FORECASTED           ,
              COST_ACTUAL               ,
              BUDGET_APPROVED           ,
              BUDGET_REQUESTED          ,
              RESPONSES_FORECASTED      ,
              RESPONSES_POSITIVE        ,
              CUSTOMERS_TARGETED        ,
              CUSTOMERS_NEW             ,
              REGISTRATIONS             ,
              CANCELLATIONS             ,
              ATTENDANCE                ,
              OPPORTUNITY_AMT_S         ,
              ORDERS_BOOKED_AMT_S       ,
              REVENUE_FORECASTED_S      ,
              REVENUE_ACTUAL_S          ,
              COST_FORECASTED_S         ,
              COST_ACTUAL_S             ,
              BUDGET_REQUESTED_S        ,
              BUDGET_APPROVED_S         ,
              CONVERSION_RATE_S         ,
			  metric1		,
			  metric2
	      )
SELECT  /*+ parallel */
	     --  BIM_I_MARKETING_FACTS_s.nextval ,
              sysdate
              ,sysdate
              ,-1
              ,-1
              ,-1
              ,transaction_create_date
	      ,lead_id
	      ,metric_type
              ,source_code_id
              ,object_type
              ,object_id
              ,child_object_type
              ,child_object_id
              ,lead_rank_id
              ,object_country
              ,object_region
              ,child_object_country
              ,child_object_region
	      ,nvl(category_id,-1)
              ,business_unit_id
              ,start_date
              ,end_date
              ,object_status
              ,child_object_status
              ,object_purpose
              ,child_object_purpose
              ,activity_type
              ,activity_id
	      ,conversion_rate
              ,from_currency
              ,leads
              ,opportunities
              ,opportunity_amt
              ,opportunities_open
              ,orders_booked
              ,orders_booked_amt
              ,revenue_forecasted
              ,revenue_actual
              ,cost_forecasted
              ,cost_actual
              ,budget_approved
              ,budget_requested
              ,responses_forecasted
              ,responses_positive
              ,customers_targeted
              ,customers_new
              ,registrations
              ,cancellations
              ,attendance
              ,OPPORTUNITY_AMT_S
              ,ORDERS_BOOKED_AMT_S
              ,REVENUE_FORECASTED_S
              ,REVENUE_ACTUAL_S
              ,COST_FORECASTED_S
              ,COST_ACTUAL_S
              ,BUDGET_REQUESTED_S
              ,BUDGET_APPROVED_S
              ,CONVERSION_RATE_S
		  	  ,metric1
			  ,metric2
FROM (
      SELECT  transaction_create_date transaction_create_date
              ,lead_id lead_id
	      ,metric_type metric_type
              ,source_code_id source_code_id
              ,object_type object_type
              ,object_id object_id
              ,child_object_type child_object_type
              ,child_object_id child_object_id
              ,lead_rank_id lead_rank_id
              ,object_country object_country
              ,object_region object_region
              ,child_object_country child_object_country
              ,child_object_region child_object_region
	      ,category_id category_id
              ,business_unit_id business_unit_id
              ,start_date start_date
              ,end_date end_date
              ,object_status object_status
              ,child_object_status child_object_status
              ,object_purpose object_purpose
              ,child_object_purpose child_object_purpose
              ,activity_type activity_type
              ,activity_id activity_id
	      ,conversion_rate
	      ,from_currency
              ,sum(leads) leads
              ,sum(opportunities) opportunities
              ,sum(opportunity_amt) opportunity_amt
              ,sum(opportunities_open) opportunities_open
              ,sum(orders_booked) orders_booked
              ,sum(orders_booked_amt) orders_booked_amt
              ,sum(budget_requested) budget_requested
              ,sum(budget_approved) budget_approved
              ,sum(revenue_forecasted) revenue_forecasted
              ,sum(revenue_actual) revenue_actual
              ,sum(cost_forecasted) cost_forecasted
              ,sum(cost_actual) cost_actual
              ,sum(responses_forecasted) responses_forecasted
              ,sum(responses_positive) responses_positive
              ,sum(customers_targeted) customers_targeted
              ,sum(customers_new) customers_new
              ,sum(registrations) registrations
              ,sum(cancellations) cancellations
              ,sum(attendance) attendance
              ,sum(OPPORTUNITY_AMT_S) OPPORTUNITY_AMT_S
              ,sum(ORDERS_BOOKED_AMT_S) ORDERS_BOOKED_AMT_S
              ,sum(REVENUE_FORECASTED_S)  REVENUE_FORECASTED_S
              ,sum(REVENUE_ACTUAL_S )      REVENUE_ACTUAL_S
              ,sum(COST_FORECASTED_S )     COST_FORECASTED_S
              ,sum(COST_ACTUAL_S      )     COST_ACTUAL_S
              ,sum(BUDGET_REQUESTED_S  )    BUDGET_REQUESTED_S
              ,sum(BUDGET_APPROVED_S)       BUDGET_APPROVED_S
              ,CONVERSION_RATE_S            CONVERSION_RATE_S
			  ,sum(metric1)     metric1
			  ,sum(metric2)   metric2
  FROM       (
--actual revenue
SELECT      trunc(f3.last_update_date) transaction_create_date
            ,0 lead_id
            ,'OTHER' metric_type
	    ,a.source_code_id source_code_id
	    ,a.object_type object_type
            ,a.object_id object_id
            ,a.child_object_type child_object_type
            ,a.child_object_id child_object_id
            ,0 lead_rank_id
            ,a.object_country
            ,a.object_region
            ,a.child_object_country
            ,a.child_object_region
	    ,a.category_id
            ,a.business_unit_id business_unit_id
            ,a.start_date
            ,a.end_date
            ,a.object_status object_status
            ,a.child_object_status child_object_status
            ,a.object_purpose object_purpose
            ,a.child_object_purpose child_object_purpose
            ,a.activity_type activity_type
            ,a.activity_id activity_id
	    ,0 conversion_rate
	    ,nvl(f3.functional_currency_code,'USD') from_currency
	    ,0 leads
            ,0 opportunities
            ,0 opportunity_amt
            ,0 opportunities_open
            ,0 quotes
            ,0 quotes_open
            ,0 orders_booked
            ,0 orders_booked_amt
            ,0 budget_requested
            ,0 budget_approved
            ,0  revenue_forecasted
          ,sum(nvl(f3.func_actual_delta,0)) revenue_actual
          ,0 cost_forecasted
          ,0 cost_actual
          ,0 responses_forecasted
          ,0 responses_positive
          ,0 customers_targeted
          ,0 customers_new
          ,0 registrations
          ,0 cancellations
          ,0 attendance
          ,0 OPPORTUNITY_AMT_S
          ,0 ORDERS_BOOKED_AMT_S
          ,0 REVENUE_FORECASTED_S
          ,0  REVENUE_ACTUAL_S
          ,0 COST_FORECASTED_S
          ,0 COST_ACTUAL_S
          ,0 BUDGET_REQUESTED_S
          ,0 BUDGET_APPROVED_S
          ,0 conversion_rate_s
		  ,0 metric1
		  ,0 metric2
FROM          ams_act_metric_hst                f3
              ,ams_metrics_all_b                 g3
              ,bim_i_source_codes                a
WHERE         f3.last_update_date between p_start_date and p_end_date
AND           f3.arc_act_metric_used_by  = a.object_type
AND           f3.act_metric_used_by_id = a.object_id
AND           a.child_object_id =0
AND           a.object_type NOT IN ('RCAM')
AND           g3.metric_calculation_type     IN ('MANUAL','FUNCTION')
AND           g3.metric_category             = 902
--AND           g3.metric_parent_id             IS NULL
AND           g3.metric_id                    = f3.metric_id
GROUP BY      trunc(f3.last_update_date)
            ,a.source_code_id
             ,a.object_type
             ,a.object_id
             ,a.child_object_type
             ,a.child_object_id
             ,a.object_country
             ,a.object_region
             ,a.child_object_country
             ,a.child_object_region
	     ,a.category_id
             ,a.object_status
             ,a.child_object_status
             ,a.object_purpose
             ,a.child_object_purpose
             ,a.activity_type
             ,a.activity_id
             ,a.start_date
             ,a.end_date
             ,a.business_unit_id
	     ,fii_currency.get_global_rate_primary(nvl(f3.functional_currency_code,'USD'),f3.last_update_date)
	     ,fii_currency.get_global_rate_secondary(nvl(f3.functional_currency_code,'USD'),f3.last_update_date)
	    ,nvl(f3.functional_currency_code,'USD')
HAVING              sum(nvl(f3.func_actual_delta,0)) <> 0
union all --actual revenue at schedule level
SELECT      trunc(f3.last_update_date) transaction_create_date
            ,0 lead_id
            ,'REVENUE' metric_type
	    ,a.source_code_id source_code_id
	    ,a.object_type object_type
            ,a.object_id object_id
            ,a.child_object_type child_object_type
            ,a.child_object_id child_object_id
            ,0 lead_rank_id
            ,a.object_country
            ,a.object_region
            ,a.child_object_country
            ,a.child_object_region
	    ,a.category_id
            ,a.business_unit_id business_unit_id
            ,a.start_date
            ,a.end_date
            ,a.object_status object_status
            ,a.child_object_status child_object_status
            ,a.object_purpose object_purpose
            ,a.child_object_purpose child_object_purpose
            ,a.activity_type activity_type
            ,a.activity_id activity_id
	    ,0 conversion_rate
	    ,nvl(f3.functional_currency_code,'USD') from_currency
	    ,0 leads
            ,0 opportunities
            ,0 opportunity_amt
            ,0 opportunities_open
            ,0 quotes
            ,0 quotes_open
            ,0 orders_booked
            ,0 orders_booked_amt
            ,0 budget_requested
            ,0 budget_approved
          ,0  revenue_forecasted
          ,sum(nvl(f3.func_actual_delta,0))  REVENUE_ACTUAL
          ,0 cost_forecasted
          ,0 cost_actual
          ,0 responses_forecasted
          ,0 responses_positive
          ,0 customers_targeted
          ,0 customers_new
          ,0 registrations
          ,0 cancellations
          ,0 attendance
          ,0 OPPORTUNITY_AMT_S
          ,0 ORDERS_BOOKED_AMT_S
          ,0 REVENUE_FORECASTED_S
          ,0  REVENUE_ACTUAL_S
          ,0 COST_FORECASTED_S
          ,0 COST_ACTUAL_S
          ,0 BUDGET_REQUESTED_S
          ,0 BUDGET_APPROVED_S
          ,0 conversion_rate_s
		  ,0 metric1
  		  ,0 metric2
FROM          ams_act_metric_hst                f3
              ,ams_metrics_all_b                 g3
              ,bim_i_source_codes                a
WHERE         f3.last_update_date between p_start_date and p_end_date
AND           f3.arc_act_metric_used_by  IN ('CSCH','EVEO')
AND           f3.act_metric_used_by_id = a.child_object_id
AND           f3.ARC_ACT_METRIC_USED_BY = a.child_object_type
--AND           a.child_object_id =0
AND           a.object_type NOT IN ('RCAM')
AND           g3.metric_calculation_type     IN ('MANUAL','FUNCTION')
AND           g3.metric_category             = 902
--AND           g3.metric_parent_id             IS NULL
AND           g3.metric_id                    = f3.metric_id
GROUP BY      trunc(f3.last_update_date)
            ,a.source_code_id
             ,a.object_type
             ,a.object_id
             ,a.child_object_type
             ,a.child_object_id
             ,a.object_country
             ,a.object_region
             ,a.child_object_country
             ,a.child_object_region
	     ,a.category_id
             ,a.object_status
             ,a.child_object_status
             ,a.object_purpose
             ,a.child_object_purpose
             ,a.activity_type
             ,a.activity_id
             ,a.start_date
             ,a.end_date
             ,a.business_unit_id
	     ,fii_currency.get_global_rate_primary(nvl(f3.functional_currency_code,'USD'),f3.last_update_date)
	     ,fii_currency.get_global_rate_secondary(nvl(f3.functional_currency_code,'USD'),f3.last_update_date)
	     ,nvl(f3.functional_currency_code,'USD')
HAVING        sum(nvl(f3.func_actual_delta,0)) <>0
union all --cost
SELECT
	case
		when trunc(f3.last_update_date) < p_start_date then p_start_date
		else trunc(f3.last_update_date)
	end transaction_create_date
            ,0 lead_id
            ,'COST' metric_type
	    ,a.source_code_id source_code_id
	    ,a.object_type object_type
            ,a.object_id object_id
            ,a.child_object_type child_object_type
            ,a.child_object_id child_object_id
            ,0 lead_rank_id
            ,a.object_country
            ,a.object_region
            ,a.child_object_country
            ,a.child_object_region
	    ,a.category_id
            ,a.business_unit_id business_unit_id
            ,a.start_date
            ,a.end_date
            ,a.object_status object_status
            ,a.child_object_status child_object_status
            ,a.object_purpose object_purpose
            ,a.child_object_purpose child_object_purpose
            ,a.activity_type activity_type
            ,a.activity_id activity_id
       	    ,0 conversion_rate
	    ,nvl(f3.functional_currency_code,'USD') from_currency
	    ,0 leads
	    ,0 opportunities
            ,0 opportunity_amt
            ,0 opportunities_open
            ,0 quotes
            ,0 quotes_open
            ,0 orders_booked
            ,0 orders_booked_amt
            ,0 budget_requested
            ,0 budget_approved
	    ,0 revenue_forecasted
	    ,0 revenue_actual
          ,0 cost_forecasted
          ,sum(nvl(f3.func_actual_delta,0)) cost_actual
          ,0 responses_forecasted
          ,0 responses_positive
          ,0 customers_targeted
          ,0 customers_new
          ,0 registrations
          ,0 cancellations
          ,0 attendance
          ,0 OPPORTUNITY_AMT_S
          ,0 ORDERS_BOOKED_AMT_S
          ,0 REVENUE_FORECASTED_S
          ,0 REVENUE_ACTUAL_S
          ,0 COST_FORECASTED_S
          ,0 COST_ACTUAL_S
          ,0 BUDGET_REQUESTED_S
          ,0 BUDGET_APPROVED_S
          ,0 conversion_rate_s
		  ,0 metric1
  		  ,0 metric2
FROM          ams_act_metric_hst                f3
              ,ams_metrics_all_b                 g3
              ,bim_i_source_codes                a
WHERE         f3.last_update_date <= p_end_date
AND           f3.arc_act_metric_used_by  = a.object_type
AND           f3.act_metric_used_by_id = a.object_id
AND           a.child_object_id =0
AND           a.object_type NOT IN ('RCAM')
AND           g3.metric_calculation_type     IN ('MANUAL','FUNCTION')
AND           g3.metric_category             = 901
--AND           g3.metric_parent_id             IS NULL
AND           g3.metric_id                    = f3.metric_id
GROUP BY     case
		when trunc(f3.last_update_date) < p_start_date then p_start_date
		else trunc(f3.last_update_date)
	     end
            ,a.source_code_id
             ,a.object_type
             ,a.object_id
             ,a.child_object_type
             ,a.child_object_id
             ,a.object_country
             ,a.object_region
             ,a.child_object_country
             ,a.child_object_region
	     ,a.category_id
             ,a.object_status
             ,a.child_object_status
             ,a.object_purpose
             ,a.child_object_purpose
             ,a.activity_type
             ,a.activity_id
             ,a.start_date
             ,a.end_date
             ,a.business_unit_id
	     ,fii_currency.get_global_rate_primary(nvl(f3.functional_currency_code,'USD'),f3.last_update_date)
	     ,fii_currency.get_global_rate_secondary(nvl(f3.functional_currency_code,'USD'),f3.last_update_date)
	     ,nvl(f3.functional_currency_code,'USD')
HAVING       sum(nvl(f3.func_actual_delta,0)) <> 0
union all --cost at schedule level
SELECT      	case
			when trunc(f3.last_update_date) < p_start_date then p_start_date
			else trunc(f3.last_update_date)
		end transaction_create_date
            ,0 lead_id
            ,'OTHER' metric_type
	    ,a.source_code_id source_code_id
	    ,a.object_type object_type
            ,a.object_id object_id
            ,a.child_object_type child_object_type
            ,a.child_object_id child_object_id
            ,0 lead_rank_id
            ,a.object_country
            ,a.object_region
            ,a.child_object_country
            ,a.child_object_region
	    ,a.category_id
            ,a.business_unit_id business_unit_id
            ,a.start_date
            ,a.end_date
            ,a.object_status object_status
            ,a.child_object_status child_object_status
            ,a.object_purpose object_purpose
            ,a.child_object_purpose child_object_purpose
            ,a.activity_type activity_type
            ,a.activity_id activity_id
	    ,0 conversion_rate
	    ,nvl(f3.functional_currency_code,'USD') from_currency
	    ,0 leads
            ,0 opportunities
            ,0 opportunity_amt
            ,0 opportunities_open
            ,0 quotes
            ,0 quotes_open
            ,0 orders_booked
            ,0 orders_booked_amt
            ,0 budget_requested
            ,0 budget_approved
	    ,0 revenue_forecasted
	    ,0 revenue_actual
          ,0 cost_forecasted
          ,sum(nvl(f3.func_actual_delta,0)) cost_actual
          ,0 responses_forecasted
          ,0 responses_positive
          ,0 customers_targeted
          ,0 customers_new
          ,0 registrations
          ,0 cancellations
          ,0 attendance
          ,0 OPPORTUNITY_AMT_S
          ,0 ORDERS_BOOKED_AMT_S
          ,0 REVENUE_FORECASTED_S
          ,0 REVENUE_ACTUAL_S
          ,0 COST_FORECASTED_S
          ,0 COST_ACTUAL_S
          ,0 BUDGET_REQUESTED_S
          ,0 BUDGET_APPROVED_S
          ,0 conversion_rate_s
		  ,0 metric1
  		  ,0 metric2
FROM          ams_act_metric_hst                f3
              ,ams_metrics_all_b                 g3
              ,bim_i_source_codes                a
WHERE         f3.last_update_date <= p_end_date
AND           f3.arc_act_metric_used_by  IN ('CSCH','EVEO')
AND           f3.act_metric_used_by_id = a.child_object_id
AND           f3.ARC_ACT_METRIC_USED_BY = a.child_object_type
--AND           a.child_object_id =0
AND           a.object_type NOT IN ('RCAM')
AND           g3.metric_calculation_type     IN ('MANUAL','FUNCTION')
AND           g3.metric_category             = 901
--AND           g3.metric_parent_id             IS NULL
AND           g3.metric_id                    = f3.metric_id
GROUP BY     case
            	when trunc(f3.last_update_date) < p_start_date then p_start_date
		else trunc(f3.last_update_date)
	     end
            ,a.source_code_id
             ,a.object_type
             ,a.object_id
             ,a.child_object_type
             ,a.child_object_id
             ,a.object_country
             ,a.object_region
             ,a.child_object_country
             ,a.child_object_region
	     ,a.category_id
             ,a.object_status
             ,a.child_object_status
             ,a.object_purpose
             ,a.child_object_purpose
             ,a.activity_type
             ,a.activity_id
             ,a.start_date
             ,a.end_date
             ,a.business_unit_id
    	     ,fii_currency.get_global_rate_primary(nvl(f3.functional_currency_code,'USD'),f3.last_update_date)
             ,fii_currency.get_global_rate_secondary(nvl(f3.functional_currency_code,'USD'),f3.last_update_date)
	     ,nvl(f3.functional_currency_code,'USD')
HAVING       sum(nvl(f3.func_actual_delta,0)) <> 0
--sbehera 15 jan 2004
--for campaign forecasted response
union all --forecasted response
SELECT      trunc(f3.last_update_date) transaction_create_date
            ,0 lead_id
            ,'OTHER' metric_type
            ,a.source_code_id source_code_id
            ,a.object_type object_type
            ,a.object_id object_id
            ,a.child_object_type child_object_type
            ,a.child_object_id child_object_id
            ,0 lead_rank_id
            ,a.object_country
            ,a.object_region
            ,a.child_object_country
            ,a.child_object_region
            ,a.category_id
            ,a.business_unit_id business_unit_id
            ,a.start_date
            ,a.end_date
            ,a.object_status object_status
            ,a.child_object_status child_object_status
            ,a.object_purpose object_purpose
            ,a.child_object_purpose child_object_purpose
            ,a.activity_type activity_type
            ,a.activity_id activity_id
            ,0 conversion_rate
            ,null from_currency
            ,0 leads
            ,0 opportunities
            ,0 opportunity_amt
            ,0 opportunities_open
            ,0 quotes
            ,0 quotes_open
            ,0 orders_booked
            ,0 orders_booked_amt
            ,0 budget_requested
            ,0 budget_approved
            ,0 revenue_forecasted
            ,0 revenue_actual
           ,0 cost_forecasted
           ,0 cost_actual
          ,sum(nvl(f3.func_forecasted_delta,0)) responses_forecasted
          ,0 responses_positive
          ,0 customers_targeted
          ,0 customers_new
          ,0 registrations
          ,0 cancellations
          ,0 attendance
          ,0 OPPORTUNITY_AMT_S
          ,0 ORDERS_BOOKED_AMT_S
          ,0 REVENUE_FORECASTED_S
          ,0 REVENUE_ACTUAL_S
          ,0 COST_FORECASTED_S
          ,0 COST_ACTUAL_S
          ,0 BUDGET_REQUESTED_S
          ,0 BUDGET_APPROVED_S
          ,0 conversion_rate_S
		  ,0 metric1
 		  ,0 metric2
FROM  ams_act_metric_hst               f3
     ,ams_metrics_all_b                g3
     ,bim_i_source_codes                a
           WHERE         f3.last_update_date between p_start_date and p_end_date
           AND           f3.arc_act_metric_used_by  = a.object_type
           AND           f3.act_metric_used_by_id = a.object_id
           AND           a.child_object_id =0
       --AND           a.object_type NOT IN ('RCAM')
--       AND           a.object_type='CAMP' commented for camp,event and one off
           AND           g3.metric_calculation_type     IN ('MANUAL','FUNCTION')
           AND           g3.metric_category             = 903
           AND           g3.metric_id                    = f3.metric_id
GROUP BY      trunc(f3.last_update_date)
            ,a.source_code_id
             ,a.object_type
             ,a.object_id
             ,a.child_object_type
             ,a.child_object_id
             ,a.object_country
             ,a.object_region
             ,a.child_object_country
             ,a.child_object_region
             ,a.category_id
             ,a.object_status
             ,a.child_object_status
             ,a.object_purpose
             ,a.child_object_purpose
             ,a.activity_type
             ,a.activity_id
             ,a.start_date
             ,a.end_date
             ,a.business_unit_id
HAVING       sum(nvl(f3.func_forecasted_delta,0)) <> 0
--for campaign schedule forecasted response
union all --forecasted campaign schedule response
SELECT      trunc(f3.last_update_date) transaction_create_date
            ,0 lead_id
            ,'OTHER' metric_type
            ,a.source_code_id source_code_id
            ,a.object_type object_type
            ,a.object_id object_id
            ,a.child_object_type child_object_type
            ,a.child_object_id child_object_id
            ,0 lead_rank_id
            ,a.object_country
            ,a.object_region
            ,a.child_object_country
            ,a.child_object_region
            ,a.category_id
            ,a.business_unit_id business_unit_id
            ,a.start_date
            ,a.end_date
            ,a.object_status object_status
            ,a.child_object_status child_object_status
            ,a.object_purpose object_purpose
            ,a.child_object_purpose child_object_purpose
            ,a.activity_type activity_type
            ,a.activity_id activity_id
            ,0 conversion_rate
            ,null from_currency
            ,0 leads
            ,0 opportunities
            ,0 opportunity_amt
            ,0 opportunities_open
            ,0 quotes
            ,0 quotes_open
            ,0 orders_booked
            ,0 orders_booked_amt
            ,0 budget_requested
            ,0 budget_approved
            ,0 revenue_forecasted
            ,0 revenue_actual
           ,0 cost_forecasted
           ,0 cost_actual
          ,sum(nvl(f3.func_forecasted_delta,0)) responses_forecasted
          ,0 responses_positive
          ,0 customers_targeted
          ,0 customers_new
          ,0 registrations
          ,0 cancellations
          ,0 attendance
          ,0 OPPORTUNITY_AMT_S
          ,0 ORDERS_BOOKED_AMT_S
          ,0 REVENUE_FORECASTED_S
          ,0 REVENUE_ACTUAL_S
          ,0 COST_FORECASTED_S
          ,0 COST_ACTUAL_S
          ,0 BUDGET_REQUESTED_S
          ,0 BUDGET_APPROVED_S
          ,0 conversion_rate_S
		  ,0 metric1
  		  ,0 metric2
FROM  ams_act_metric_hst               f3
     ,ams_metrics_all_b                g3
     ,bim_i_source_codes                a
           WHERE         f3.last_update_date between p_start_date and p_end_date
            AND           f3.act_metric_used_by_id = a.child_object_id
           AND           f3.ARC_ACT_METRIC_USED_BY = a.child_object_type
       --AND           a.object_type NOT IN ('RCAM')
       AND           a.child_object_type in('CSCH','EVEO')
           AND           g3.metric_calculation_type     IN ('MANUAL','FUNCTION')
           AND           g3.metric_category             = 903
           AND           g3.metric_id                    = f3.metric_id
GROUP BY      trunc(f3.last_update_date)
            ,a.source_code_id
             ,a.object_type
             ,a.object_id
             ,a.child_object_type
             ,a.child_object_id
             ,a.object_country
             ,a.object_region
             ,a.child_object_country
             ,a.child_object_region
             ,a.category_id
             ,a.object_status
             ,a.child_object_status
             ,a.object_purpose
             ,a.child_object_purpose
             ,a.activity_type
             ,a.activity_id
             ,a.start_date
             ,a.end_date
             ,a.business_unit_id
HAVING       sum(nvl(f3.func_forecasted_delta,0)) <> 0
union all --targeted audience
SELECT      trunc(p.creation_date) transaction_create_date
            ,0 lead_id
            ,'OTHER' metric_type
	    ,a.source_code_id source_code_id
	    ,a.object_type object_type
            ,a.object_id object_id
            ,a.child_object_type child_object_type
            ,a.child_object_id child_object_id
            ,0 lead_rank_id
            ,a.object_country
            ,a.object_region
            ,a.child_object_country
            ,a.child_object_region
	    ,a.category_id
            ,a.business_unit_id business_unit_id
            ,a.start_date
            ,a.end_date
            ,a.object_status object_status
            ,a.child_object_status child_object_status
            ,a.object_purpose object_purpose
            ,a.child_object_purpose child_object_purpose
            ,a.activity_type activity_type
            ,a.activity_id activity_id
	    ,0 conversion_rate
	    ,null from_currency
	    ,0 leads
            ,0 opportunities
            ,0 opportunity_amt
            ,0 opportunities_open
            ,0 quotes
            ,0 quotes_open
            ,0 orders_booked
            ,0 orders_booked_amt
            ,0 budget_requested
            ,0 budget_approved
	    ,0 revenue_forecasted
	    ,0 revenue_actual
           ,0 cost_forecasted
           ,0 cost_actual
          ,0 responses_forecasted
          ,0 responses_positive
          ,count(p.list_entry_id) customers_targeted
          ,0 customers_new
          ,0 registrations
          ,0 cancellations
          ,0 attendance
          ,0 OPPORTUNITY_AMT_S
          ,0 ORDERS_BOOKED_AMT_S
          ,0 REVENUE_FORECASTED_S
          ,0 REVENUE_ACTUAL_S
          ,0 COST_FORECASTED_S
          ,0 COST_ACTUAL_S
          ,0 BUDGET_REQUESTED_S
          ,0 BUDGET_APPROVED_S
          ,0 conversion_rate_S
		  ,0 metric1
  		  ,0 metric2
FROM          ams_list_entries                p
              ,ams_act_lists                q
              ,bim_i_source_codes                a
WHERE         p.creation_date between p_start_date and p_end_date
AND           p.list_header_id = q.list_header_id
AND           q.list_used_by = a.child_object_type
AND           q.list_used_by_id = a.child_object_id
AND           a.object_type NOT IN ('RCAM')
AND           q.list_used_by in ('CSCH','EVEO')
AND           q.list_act_type = 'TARGET'
AND           p.enabled_flag='Y'
GROUP BY      trunc(p.creation_date)
            ,a.source_code_id
             ,a.object_type
             ,a.object_id
             ,a.child_object_type
             ,a.child_object_id
             ,a.object_country
             ,a.object_region
             ,a.child_object_country
             ,a.child_object_region
	     ,a.category_id
             ,a.object_status
             ,a.child_object_status
             ,a.object_purpose
             ,a.child_object_purpose
             ,a.activity_type
             ,a.activity_id
             ,a.start_date
             ,a.end_date
             ,a.business_unit_id
union all --targeted audience for schedules of type event
SELECT      trunc(p.creation_date) transaction_create_date
            ,0 lead_id
            ,'OTHER' metric_type
	    ,a.source_code_id source_code_id
	    ,a.object_type object_type
            ,a.object_id object_id
            ,a.child_object_type child_object_type
            ,a.child_object_id child_object_id
            ,0 lead_rank_id
            ,a.object_country
            ,a.object_region
            ,a.child_object_country
            ,a.child_object_region
	    ,a.category_id
            ,a.business_unit_id business_unit_id
            ,a.start_date
            ,a.end_date
            ,a.object_status object_status
            ,a.child_object_status child_object_status
            ,a.object_purpose object_purpose
            ,a.child_object_purpose child_object_purpose
            ,a.activity_type activity_type
            ,a.activity_id activity_id
	    ,0 conversion_rate
	    ,null from_currency
	    ,0 leads
            ,0 opportunities
            ,0 opportunity_amt
            ,0 opportunities_open
            ,0 quotes
            ,0 quotes_open
            ,0 orders_booked
            ,0 orders_booked_amt
            ,0 budget_requested
            ,0 budget_approved
	    ,0 revenue_forecasted
	    ,0 revenue_actual
           ,0 cost_forecasted
           ,0 cost_actual
          ,0 responses_forecasted
          ,0 responses_positive
          ,count(p.list_entry_id) customers_targeted
          ,0 customers_new
          ,0 registrations
          ,0 cancellations
          ,0 attendance
          ,0 OPPORTUNITY_AMT_S
          ,0 ORDERS_BOOKED_AMT_S
          ,0 REVENUE_FORECASTED_S
          ,0 REVENUE_ACTUAL_S
          ,0 COST_FORECASTED_S
          ,0 COST_ACTUAL_S
          ,0 BUDGET_REQUESTED_S
          ,0 BUDGET_APPROVED_S
          ,0 conversion_rate_S
		  ,0 metric1
  		  ,0 metric2
FROM          ams_list_entries              p
              ,ams_act_lists                q
              ,bim_i_source_codes           a
	      ,ams_campaign_schedules_b sch
WHERE         p.creation_date between p_start_date and p_end_date
AND           p.list_header_id = q.list_header_id
AND           q.list_used_by     = 'EONE'
AND           q.list_act_type = 'TARGET'
AND           sch.schedule_id = a.child_object_id
AND           a.child_object_type = 'CSCH'
AND           sch.activity_type_code = 'EVENTS'
AND           q.list_used_by_id = sch.related_event_id
AND           a.object_type NOT IN ('RCAM')
AND           p.enabled_flag='Y'
GROUP BY      trunc(p.creation_date)
            ,a.source_code_id
             ,a.object_type
             ,a.object_id
             ,a.child_object_type
             ,a.child_object_id
             ,a.object_country
             ,a.object_region
             ,a.child_object_country
             ,a.child_object_region
	     ,a.category_id
             ,a.object_status
             ,a.child_object_status
             ,a.object_purpose
             ,a.child_object_purpose
             ,a.activity_type
             ,a.activity_id
             ,a.start_date
             ,a.end_date
             ,a.business_unit_id
union all
   --budget1
	 SELECT  /*+ USE_HASH(S A B) */
            case
		when trunc(nvl(s.approval_date,s.last_update_date)) < p_start_date then p_start_date
		else trunc(nvl(s.approval_date,s.last_update_date))
	    end transaction_create_date
            ,0 lead_id
            ,'OTHER' metric_type
	    ,a.source_code_id source_code_id
	    ,a.object_type object_type
            ,a.object_id object_id
            ,a.child_object_type child_object_type
            ,a.child_object_id child_object_id
            ,0 lead_rank_id
            ,a.object_country
            ,a.object_region
            ,a.child_object_country
            ,a.child_object_region
	    ,a.category_id
            ,a.business_unit_id business_unit_id
            ,a.start_date
            ,a.end_date
            ,a.object_status object_status
            ,a.child_object_status child_object_status
            ,a.object_purpose object_purpose
            ,a.child_object_purpose child_object_purpose
            ,a.activity_type activity_type
            ,a.activity_id activity_id
	    ,0 conversion_rate_s
	    ,nvl(s.request_currency,'USD') from_currency
	    ,0 leads
            ,0 opportunities
            ,0 opportunity_amt
            ,0 opportunities_open
            ,0 quotes
            ,0 quotes_open
            ,0 orders_booked
            ,0 orders_booked_amt
            ,0 budget_requested
            ,sum(nvl(s.approved_amount,0))  budget_approved
           ,0 revenue_forecasted
           ,0 revenue_actual
           ,0 cost_actual
           ,0 cost_forecasted
           ,0 responses_forecasted
           ,0 responses_positive
           ,0 customers_targeted
           ,0 customers_new
           ,0 registrations
           ,0 cancellations
           ,0 attendance
           ,0 OPPORTUNITY_AMT_S
          ,0 ORDERS_BOOKED_AMT_S
          ,0 REVENUE_FORECASTED_S
          ,0 REVENUE_ACTUAL_S
          ,0 COST_FORECASTED_S
          ,0 COST_ACTUAL_S
          ,0 BUDGET_REQUESTED_S
          ,0 BUDGET_APPROVED_S
          ,0 conversion_rate_s
		  ,0 metric1
  		  ,0 metric2
FROM        ozf_act_budgets             S
           ,bim_i_source_codes      A
           ,ams_source_codes            B
WHERE      s.act_budget_used_by_id  = b.source_code_for_id
AND        s.arc_act_budget_used_by = b.arc_source_code_for
AND        b.source_code_id = a.source_code_id
AND        a.object_type NOT IN ('RCAM')
AND        s.budget_source_type      = 'FUND'
AND		   s.parent_act_budget_id IS NULL
AND        a.start_date <= p_end_date
AND        trunc(nvl(s.approval_date,s.last_update_date)) <= p_end_date
AND        s.status_code = 'APPROVED'
GROUP BY
            case
		when trunc(nvl(s.approval_date,s.last_update_date)) < p_start_date then p_start_date
		else trunc(nvl(s.approval_date,s.last_update_date))
	    end
           ,a.source_code_id
           ,a.object_id
           ,a.object_type
           ,a.child_object_type
           ,a.child_object_id
           ,a.object_country
           ,a.child_object_country
           ,a.object_region
           ,a.child_object_region
	   ,a.category_id
           ,a.object_status
           ,a.child_object_status
           ,a.object_purpose
           ,a.child_object_purpose
           ,a.activity_type
           ,a.activity_id
           ,a.business_unit_id
           ,a.start_date
           ,a.end_date
	    ,fii_currency.get_global_rate_primary(nvl(s.request_currency,'USD'),nvl(s.approval_date,s.last_update_date))
	    ,fii_currency.get_global_rate_secondary(nvl(s.request_currency,'USD'),nvl(s.approval_date,s.last_update_date))
	    ,nvl(s.request_currency,'USD')
HAVING sum(nvl(s.approved_amount,0)) > 0
--budget2
union all
SELECT  /*+ USE_HASH(S A B) */
            case
		when trunc(a.start_date) < p_start_date then p_start_date
		else trunc(a.start_date)
	    end transaction_create_date
            ,0 lead_id
            ,'OTHER' metric_type
	    ,a.source_code_id source_code_id
	   ,a.object_type object_type
           ,a.object_id object_id
           ,a.child_object_type child_object_type
           ,a.child_object_id child_object_id
           ,0 lead_rank_id
           ,a.object_country
           ,a.object_region
           ,a.child_object_country
           ,a.child_object_region
	   ,a.category_id
           ,a.business_unit_id business_unit_id
           ,a.start_date
           ,a.end_date
           ,a.object_status object_status
           ,a.child_object_status child_object_status
           ,a.object_purpose object_purpose
           ,a.child_object_purpose child_object_purpose
           ,a.activity_type activity_type
           ,a.activity_id activity_id
	   ,0 conversion_rate
	   ,nvl(request_currency,'USD') from_currency
	   ,0 leads
           ,0 opportunities
           ,0 opportunity_amt
           ,0 opportunities_open
           ,0 quotes
           ,0 quotes_open
           ,0 orders_booked
           ,0 orders_booked_amt
           ,0  budget_requested
  ,0-sum(nvl(s.approved_amount,0)) budget_approved
          ,0 revenue_forecasted
          ,0 revenue_actual
          ,0 cost_actual
          ,0 cost_forecasted
          ,0 responses_forecasted
          ,0 responses_positive
          ,0 customers_targeted
          ,0 customers_new
          ,0 registrations
          ,0 cancellations
          ,0 attendance
          ,0 OPPORTUNITY_AMT_S
          ,0 ORDERS_BOOKED_AMT_S
          ,0 REVENUE_FORECASTED_S
          ,0 REVENUE_ACTUAL_S
          ,0 COST_FORECASTED_S
          ,0 COST_ACTUAL_S
          ,0 BUDGET_REQUESTED_S
          ,0 BUDGET_APPROVED_S
          ,0 conversion_rate_s
		  ,0 metric1
  		  ,0 metric2
FROM      ozf_act_budgets             S
          ,bim_i_source_codes      A
          ,ams_source_codes            B
WHERE     s.arc_act_budget_used_by = 'FUND'
AND		   s.parent_act_budget_id IS NULL
AND       s.budget_source_type = b.arc_source_code_for
AND       s.budget_source_id = b.source_code_for_id
AND       b.source_code_id = a.source_code_id
AND       a.object_type NOT IN ('RCAM')
AND       a.start_date <= p_end_date
AND       s.approval_date <= p_end_date
GROUP BY
	    case
		when trunc(a.start_date) < p_start_date then p_start_date
		else trunc(a.start_date)
	    end
            ,a.source_code_id
          ,a.object_id
          ,a.object_type
          ,a.child_object_type
          ,a.child_object_id
          ,a.object_country
          ,a.child_object_country
          ,a.object_region
          ,a.child_object_region
	  ,a.category_id
          ,a.object_status
          ,a.child_object_status
          ,a.object_purpose
          ,a.child_object_purpose
          ,a.activity_type
          ,a.activity_id
          ,a.business_unit_id
          ,a.start_date
          ,a.end_date
	   ,fii_currency.get_global_rate_primary(nvl(request_currency,'USD'),nvl(s.approval_date,s.last_update_date))
	   ,fii_currency.get_global_rate_secondary(nvl(request_currency,'USD'),nvl(s.approval_date,s.last_update_date))
	  ,nvl(request_currency,'USD')
union all
   --budget1 for Camp Schedules and Event Schedules
	 SELECT  /*+ USE_HASH(S A B) */
            trunc(nvl(s.approval_date,s.last_update_date)) transaction_create_date
            ,0 lead_id
            ,'OTHER' metric_type
	    ,a.source_code_id source_code_id
	    ,a.object_type object_type
            ,a.object_id object_id
            ,a.child_object_type child_object_type
            ,a.child_object_id child_object_id
            ,0 lead_rank_id
            ,a.object_country
            ,a.object_region
            ,a.child_object_country
            ,a.child_object_region
	    ,a.category_id
            ,a.business_unit_id business_unit_id
            ,a.start_date
            ,a.end_date
            ,a.object_status object_status
            ,a.child_object_status child_object_status
            ,a.object_purpose object_purpose
            ,a.child_object_purpose child_object_purpose
            ,a.activity_type activity_type
            ,a.activity_id activity_id
	    ,0 conversion_rate_s
	    ,nvl(s.request_currency,'USD') from_currency
	    ,0 leads
            ,0 opportunities
            ,0 opportunity_amt
            ,0 opportunities_open
            ,0 quotes
            ,0 quotes_open
            ,0 orders_booked
            ,0 orders_booked_amt
            ,0 budget_requested
            ,0 budget_approved
           ,0 revenue_forecasted
           ,0 revenue_actual
           ,0 cost_actual
           ,0 cost_forecasted
           ,0 responses_forecasted
           ,0 responses_positive
           ,0 customers_targeted
           ,0 customers_new
           ,0 registrations
           ,0 cancellations
           ,0 attendance
           ,0 OPPORTUNITY_AMT_S
          ,0 ORDERS_BOOKED_AMT_S
          ,0 REVENUE_FORECASTED_S
          ,0 REVENUE_ACTUAL_S
          ,0 COST_FORECASTED_S
          ,0 COST_ACTUAL_S
          ,0 BUDGET_REQUESTED_S
          ,0 BUDGET_APPROVED_S
          ,0 conversion_rate_s
		  ,sum(nvl(s.approved_amount,0))  metric1
 		  ,0 metric2
FROM        ozf_act_budgets             S
           ,bim_i_source_codes      A
           ,ams_source_codes            B
WHERE      s.act_budget_used_by_id  = b.source_code_for_id
AND        s.arc_act_budget_used_by = b.arc_source_code_for
AND        b.source_code_id = a.source_code_id
AND        a.child_object_type IN ('CSCH','EVEO')
AND        s.budget_source_type      = 'FUND'
AND        a.start_date >= p_start_date
AND        a.start_date <= p_end_date
AND        trunc(nvl(s.approval_date,s.last_update_date)) <= p_end_date
AND        s.status_code = 'APPROVED'
GROUP BY
            trunc(nvl(s.approval_date,s.last_update_date))
           ,a.source_code_id
           ,a.object_id
           ,a.object_type
           ,a.child_object_type
           ,a.child_object_id
           ,a.object_country
           ,a.child_object_country
           ,a.object_region
           ,a.child_object_region
	   ,a.category_id
           ,a.object_status
           ,a.child_object_status
           ,a.object_purpose
           ,a.child_object_purpose
           ,a.activity_type
           ,a.activity_id
           ,a.business_unit_id
           ,a.start_date
           ,a.end_date
	    ,fii_currency.get_global_rate_primary(nvl(s.request_currency,'USD'),nvl(s.approval_date,s.last_update_date))
	    ,fii_currency.get_global_rate_secondary(nvl(s.request_currency,'USD'),nvl(s.approval_date,s.last_update_date))
	    ,nvl(s.request_currency,'USD')
HAVING sum(nvl(s.approved_amount,0)) > 0
union all
--budget2 for Camp Schedules and Event Schedules
SELECT  /*+ USE_HASH(S A B) */
           trunc(a.start_date)   transaction_create_date
            ,0 lead_id
            ,'OTHER' metric_type
	    ,a.source_code_id source_code_id
	   ,a.object_type object_type
           ,a.object_id object_id
           ,a.child_object_type child_object_type
           ,a.child_object_id child_object_id
           ,0 lead_rank_id
           ,a.object_country
           ,a.object_region
           ,a.child_object_country
           ,a.child_object_region
	   ,a.category_id
           ,a.business_unit_id business_unit_id
           ,a.start_date
           ,a.end_date
           ,a.object_status object_status
           ,a.child_object_status child_object_status
           ,a.object_purpose object_purpose
           ,a.child_object_purpose child_object_purpose
           ,a.activity_type activity_type
           ,a.activity_id activity_id
	   ,0 conversion_rate
	   ,nvl(request_currency,'USD') from_currency
	   ,0 leads
           ,0 opportunities
           ,0 opportunity_amt
           ,0 opportunities_open
           ,0 quotes
           ,0 quotes_open
           ,0 orders_booked
           ,0 orders_booked_amt
           ,0  budget_requested
           ,0 budget_approved
          ,0 revenue_forecasted
          ,0 revenue_actual
          ,0 cost_actual
          ,0 cost_forecasted
          ,0 responses_forecasted
          ,0 responses_positive
          ,0 customers_targeted
          ,0 customers_new
          ,0 registrations
          ,0 cancellations
          ,0 attendance
          ,0 OPPORTUNITY_AMT_S
          ,0 ORDERS_BOOKED_AMT_S
          ,0 REVENUE_FORECASTED_S
          ,0 REVENUE_ACTUAL_S
          ,0 COST_FORECASTED_S
          ,0 COST_ACTUAL_S
          ,0 BUDGET_REQUESTED_S
          ,0 BUDGET_APPROVED_S
          ,0 conversion_rate_s
		  ,0-sum(nvl(s.approved_amount,0)) metric1
  		  ,0 metric2
FROM      ozf_act_budgets             S
          ,bim_i_source_codes      A
          ,ams_source_codes            B
WHERE     s.arc_act_budget_used_by = 'FUND'
AND       s.budget_source_type = b.arc_source_code_for
AND       s.budget_source_id = b.source_code_for_id
AND       b.source_code_id = a.source_code_id
AND       a.child_object_type IN ('CSCH','EVEO')
AND       a.start_date >= p_start_date
AND       a.start_date <= p_end_date
AND       s.approval_date <= p_end_date
GROUP BY
trunc(nvl(s.approval_date,s.last_update_date))
            ,a.source_code_id
          ,a.object_id
          ,a.object_type
          ,a.child_object_type
          ,a.child_object_id
          ,a.object_country
          ,a.child_object_country
          ,a.object_region
          ,a.child_object_region
	  ,a.category_id
          ,a.object_status
          ,a.child_object_status
          ,a.object_purpose
          ,a.child_object_purpose
          ,a.activity_type
          ,a.activity_id
          ,a.business_unit_id
          ,a.start_date
          ,a.end_date
	   ,fii_currency.get_global_rate_primary(nvl(request_currency,'USD'),nvl(s.approval_date,s.last_update_date))
	   ,fii_currency.get_global_rate_secondary(nvl(request_currency,'USD'),nvl(s.approval_date,s.last_update_date))
	  ,nvl(request_currency,'USD')
union all   --registration1
SELECT  /*+ USE_HASH(S A B) */
           trunc(X.last_reg_status_date)   transaction_create_date
            ,0 lead_id
            ,'OTHER' metric_type
	    ,a.source_code_id source_code_id
	   ,a.object_type object_type
           ,a.object_id object_id
           ,a.child_object_type child_object_type
           ,a.child_object_id child_object_id
           ,0 lead_rank_id
           ,a.object_country
           ,a.object_region
           ,a.child_object_country
           ,a.child_object_region
	   ,a.category_id
           ,a.business_unit_id business_unit_id
           ,a.start_date
           ,a.end_date
           ,a.object_status object_status
           ,a.child_object_status child_object_status
           ,a.object_purpose object_purpose
           ,a.child_object_purpose child_object_purpose
           ,a.activity_type activity_type
           ,a.activity_id activity_id
	   ,0 conversion_rate
	   ,null from_currency
	   ,0 leads
           ,0 opportunities
           ,0 opportunity_amt
           ,0 opportunities_open
           ,0 quotes
           ,0 quotes_open
           ,0 orders_booked
           ,0 orders_booked_amt
           ,0  budget_requested
           ,0 budget_approved
           ,0 revenue_forecasted
           ,0 revenue_actual
           ,0 cost_actual
           ,0 cost_forecasted
           ,0 responses_forecasted
           ,0 responses_positive
           ,0 customers_targeted
           ,0 customers_new
           ,SUM(decode(X.system_status_code,'REGISTERED',1,0)) registrations
           ,SUM(decode(X.system_status_code,'CANCELLED',1,0)) cancellations
           ,SUM(decode(X.system_status_code,'REGISTERED',decode(attended_flag,'Y',1,0),0)) attendance
           ,0 OPPORTUNITY_AMT_S
          ,0 ORDERS_BOOKED_AMT_S
          ,0 REVENUE_FORECASTED_S
          ,0 REVENUE_ACTUAL_S
          ,0 COST_FORECASTED_S
          ,0 COST_ACTUAL_S
          ,0 BUDGET_REQUESTED_S
          ,0 BUDGET_APPROVED_S
          ,0 conversion_rate_S
		  ,0 metric1
  		  ,0 metric2
FROM       ams_event_registrations X
          ,bim_i_source_codes      A
WHERE     trunc(X.last_reg_status_date) between p_start_date and p_end_date+0.99999
AND       X.event_offer_id     = A.child_object_id
AND       A.child_object_type ='EVEO'
AND           a.object_type NOT IN ('RCAM')
AND       a.start_date >= p_start_date
AND       a.start_date <= p_end_date
GROUP BY
trunc(X.last_reg_status_date)
            ,a.source_code_id
          ,a.object_id
          ,a.object_type
          ,a.child_object_type
          ,a.child_object_id
          ,a.object_country
          ,a.child_object_country
          ,a.object_region
          ,a.child_object_region
	  ,a.category_id
          ,a.object_status
          ,a.child_object_status
          ,a.object_purpose
          ,a.child_object_purpose
          ,a.activity_type
          ,a.activity_id
          ,a.business_unit_id
          ,a.start_date
          ,a.end_date
union all   --registration2
SELECT  /*+ USE_HASH(S A B) */
           trunc(X.last_reg_status_date)   transaction_create_date
            ,0 lead_id
            ,'OTHER' metric_type
	    ,a.source_code_id source_code_id
	   ,a.object_type object_type
           ,a.object_id object_id
           ,a.child_object_type child_object_type
           ,a.child_object_id child_object_id
           ,0 lead_rank_id
           ,a.object_country
           ,a.object_region
           ,a.child_object_country
           ,a.child_object_region
	   ,a.category_id
           ,a.business_unit_id business_unit_id
           ,a.start_date
           ,a.end_date
           ,a.object_status object_status
           ,a.child_object_status child_object_status
           ,a.object_purpose object_purpose
           ,a.child_object_purpose child_object_purpose
           ,a.activity_type activity_type
           ,a.activity_id activity_id
           ,0 conversion_rate
	   ,null from_currency
	   ,0 leads
           ,0 opportunities
           ,0 opportunity_amt
           ,0 opportunities_open
           ,0 quotes
           ,0 quotes_open
           ,0 orders_booked
           ,0 orders_booked_amt
           ,0  budget_requested
           ,0 budget_approved
           ,0 revenue_forecasted
           ,0 revenue_actual
           ,0 cost_actual
           ,0 cost_forecasted
           ,0 responses_forecasted
           ,0 responses_positive
           ,0 customers_targeted
           ,0 customers_new
           ,SUM(decode(X.system_status_code,'REGISTERED',1,0)) registrations
           ,SUM(decode(X.system_status_code,'CANCELLED',1,0)) cancellations
           ,SUM(decode(X.system_status_code,'REGISTERED',decode(attended_flag,'Y',1,0),0)) attendance
           ,0 OPPORTUNITY_AMT_S
          ,0 ORDERS_BOOKED_AMT_S
          ,0 REVENUE_FORECASTED_S
          ,0 REVENUE_ACTUAL_S
          ,0 COST_FORECASTED_S
          ,0 COST_ACTUAL_S
          ,0 BUDGET_REQUESTED_S
          ,0 BUDGET_APPROVED_S
          ,0 conversion_rate_S
  		  ,0 metric1
		  ,0 metric2
FROM       ams_event_registrations X
          ,bim_i_source_codes      A
WHERE     trunc(X.last_reg_status_date) between p_start_date and p_end_date+0.99999
AND       X.event_offer_id     = A.object_id
AND       A.object_type ='EONE'
AND           a.object_type NOT IN ('RCAM')
AND       a.start_date >= p_start_date
AND       a.start_date <= p_end_date
GROUP BY
trunc(X.last_reg_status_date)
            ,a.source_code_id
          ,a.object_id
          ,a.object_type
          ,a.child_object_type
          ,a.child_object_id
          ,a.object_country
          ,a.child_object_country
          ,a.object_region
          ,a.child_object_region
	  ,a.category_id
          ,a.object_status
          ,a.child_object_status
          ,a.object_purpose
          ,a.child_object_purpose
          ,a.activity_type
          ,a.activity_id
          ,a.business_unit_id
          ,a.start_date
          ,a.end_date
 )
GROUP BY   transaction_create_date
           ,lead_id
	   ,metric_type
           ,source_code_id
           ,object_type
           ,object_id
           ,child_object_type
           ,child_object_id
           ,lead_rank_id
           ,object_country
           ,object_region
           ,child_object_country
           ,child_object_region
	   ,category_id
           ,business_unit_id
           ,start_date
           ,end_date
           ,object_status
           ,child_object_status
           ,object_purpose
           ,child_object_purpose
           ,activity_type
           ,activity_id
	   ,conversion_rate
	   ,from_currency
           ,conversion_rate_s) inner ;

      commit;

BIS_COLLECTION_UTILITIES.log('BIM_I_MARKETING_FACTS:Second insert into bim_i_marketing_facts_stg');
           -------------------------NEW CODE --------------
                 INSERT /*+ append parallel */
	         INTO BIM_I_MARKETING_FACTS_STG CDF      (
	                --MKT_DAILY_TRANSACTION_ID  ,
	                 CREATION_DATE             ,
	                 LAST_UPDATE_DATE          ,
	                 CREATED_BY                ,
	                 LAST_UPDATED_BY           ,
	                 LAST_UPDATE_LOGIN         ,
	   	         TRANSACTION_CREATE_DATE   ,
	   	         LEAD_ID                   ,
	   	         METRIC_TYPE               ,
                         SOURCE_CODE_ID            ,
	                 OBJECT_TYPE               ,
	                 OBJECT_ID                 ,
	                 CHILD_OBJECT_TYPE         ,
	                 CHILD_OBJECT_ID           ,
	                 LEAD_RANK_ID              ,
	                 OBJECT_COUNTRY            ,
	                 OBJECT_REGION             ,
	                 CHILD_OBJECT_COUNTRY      ,
	                 CHILD_OBJECT_REGION       ,
			 CATEGORY_ID               ,
	                 BUSINESS_UNIT_ID          ,
	                 START_DATE                ,
	                 END_DATE                  ,
	                 OBJECT_STATUS             ,
	                 CHILD_OBJECT_STATUS       ,
	                 OBJECT_PURPOSE            ,
	                 CHILD_OBJECT_PURPOSE      ,
	                 ACTIVITY_TYPE             ,
	                 ACTIVITY_ID               ,
			 CONVERSION_RATE           ,
			 FROM_CURRENCY             ,
			 LEADS                     ,
	                 OPPORTUNITIES             ,
	                 OPPORTUNITY_AMT           ,
	                 OPPORTUNITIES_OPEN        ,
	                 ORDERS_BOOKED             ,
	                 ORDERS_BOOKED_AMT         ,
	                 REVENUE_FORECASTED        ,
	                 REVENUE_ACTUAL            ,
	                 COST_FORECASTED           ,
	                 COST_ACTUAL               ,
	                 BUDGET_APPROVED           ,
	                 BUDGET_REQUESTED          ,
	                 RESPONSES_FORECASTED      ,
	                 RESPONSES_POSITIVE        ,
	                 CUSTOMERS_NEW             ,
	                 REGISTRATIONS             ,
	                 CANCELLATIONS             ,
	                 ATTENDANCE                ,
                         OPPORTUNITY_AMT_S         ,
                         ORDERS_BOOKED_AMT_S       ,
                         REVENUE_FORECASTED_S      ,
                         REVENUE_ACTUAL_S          ,
                         COST_FORECASTED_S         ,
                         COST_ACTUAL_S             ,
                         BUDGET_REQUESTED_S        ,
                         BUDGET_APPROVED_S         ,
                         CONVERSION_RATE_S			,
						 metric1					,
						 metric2)
	   SELECT  /*+ parallel */
	   	       --BIM_I_MARKETING_FACTS_s.nextval ,
	                 sysdate
	                 ,sysdate
	                 ,-1
	                 ,-1
	                 ,-1
	                 ,transaction_create_date
	   	      ,lead_id
	   	      ,metric_type
                         ,source_code_id
	                 ,object_type
	                 ,object_id
	                 ,child_object_type
	                 ,child_object_id
	                 ,lead_rank_id
	                 ,object_country
	                 ,object_region
	                 ,child_object_country
	                 ,child_object_region
			 ,nvl(category_id,-1)
	                 ,business_unit_id
	                 ,start_date
	                 ,end_date
	                 ,object_status
	                 ,child_object_status
	                 ,object_purpose
	                 ,child_object_purpose
	                 ,activity_type
	                 ,activity_id
			 ,conversion_rate
			 ,from_currency
			 ,leads
	                 ,opportunities
	                 ,opportunity_amt
	                 ,opportunities_open
	                 ,orders_booked
	                 ,orders_booked_amt
	                 ,revenue_forecasted
	                 ,revenue_actual
	                 ,cost_forecasted
	                 ,cost_actual
	                 ,budget_approved
	                 ,budget_requested
	                 ,responses_forecasted
	                 ,responses_positive
	                 ,customers_new
	                 ,registrations
	                 ,cancellations
	                 ,attendance
                         ,OPPORTUNITY_AMT_S
                         ,ORDERS_BOOKED_AMT_S
                         ,REVENUE_FORECASTED_S
                         ,REVENUE_ACTUAL_S
                         ,COST_FORECASTED_S
                         ,COST_ACTUAL_S
                         ,BUDGET_REQUESTED_S
                         ,BUDGET_APPROVED_S
                         ,CONVERSION_RATE_S
						 ,METRIC1
						 ,METRIC2
	   FROM (
	         SELECT  transaction_create_date transaction_create_date
	                 ,lead_id lead_id
	   	         ,metric_type metric_type
	                 ,source_code_id source_code_id
	                 ,object_type object_type
	                 ,object_id object_id
	                 ,child_object_type child_object_type
	                 ,child_object_id child_object_id
	                 ,lead_rank_id lead_rank_id
	                 ,object_country object_country
	                 ,object_region object_region
	                 ,child_object_country child_object_country
	                 ,child_object_region child_object_region
			 ,category_id category_id
	                 ,business_unit_id business_unit_id
	                 ,start_date start_date
	                 ,end_date end_date
	                 ,object_status object_status
	                 ,child_object_status child_object_status
	                 ,object_purpose object_purpose
	                 ,child_object_purpose child_object_purpose
	                 ,activity_type activity_type
	                 ,activity_id activity_id
			 ,conversion_rate
			 ,from_currency
	                 ,sum(leads) leads
	                 ,sum(opportunities) opportunities
	                 ,sum(opportunity_amt) opportunity_amt
	                 ,sum(opportunities_open) opportunities_open
	                 ,sum(orders_booked) orders_booked
	                 ,sum(orders_booked_amt) orders_booked_amt
	                 ,sum(budget_requested) budget_requested
	                 ,sum(budget_approved) budget_approved
	                 ,sum(revenue_forecasted) revenue_forecasted
	                 ,sum(revenue_actual) revenue_actual
	                 ,sum(cost_forecasted) cost_forecasted
	                 ,sum(cost_actual) cost_actual
	                 ,sum(responses_forecasted) responses_forecasted
	                 ,sum(responses_positive) responses_positive
	                 ,sum(customers_new) customers_new
	                 ,sum(registrations) registrations
	                 ,sum(cancellations) cancellations
	                 ,sum(attendance) attendance
                         ,sum(OPPORTUNITY_AMT_S) OPPORTUNITY_AMT_S
                          ,sum(ORDERS_BOOKED_AMT_S) ORDERS_BOOKED_AMT_S
                          ,sum(REVENUE_FORECASTED_S)  REVENUE_FORECASTED_S
                          ,sum(REVENUE_ACTUAL_S )      REVENUE_ACTUAL_S
                          ,sum(COST_FORECASTED_S )     COST_FORECASTED_S
                          ,sum(COST_ACTUAL_S      )     COST_ACTUAL_S
                          ,sum(BUDGET_REQUESTED_S  )    BUDGET_REQUESTED_S
                          ,sum(BUDGET_APPROVED_S)       BUDGET_APPROVED_S
                          ,CONVERSION_RATE_S            CONVERSION_RATE_S
						  ,sum(metric1)					metric1
						  ,sum(metric2)					metric2
	     FROM       (
	   SELECT      trunc(a.start_date) transaction_create_date
	               ,0 lead_id
	               ,'FREV' metric_type
	                 ,a.source_code_id source_code_id
	   	    ,a.object_type object_type
	               ,a.object_id object_id
	               ,a.child_object_type child_object_type
	               ,a.child_object_id child_object_id
	               ,0 lead_rank_id
	               ,a.object_country
	               ,a.object_region
	               ,a.child_object_country
	               ,a.child_object_region
		       ,a.category_id category_id
	               ,a.business_unit_id business_unit_id
	               ,a.start_date
	               ,a.end_date
	               ,a.object_status object_status
	               ,a.child_object_status child_object_status
	               ,a.object_purpose object_purpose
	               ,a.child_object_purpose child_object_purpose
	               ,a.activity_type activity_type
	               ,a.activity_id activity_id
		       ,0 conversion_rate
	               ,nvl(f3.functional_currency_code,'USD') from_currency
	               ,0 leads
	               ,0 opportunities
	               ,0 opportunity_amt
	               ,0 opportunities_open
	               ,0 quotes
	               ,0 quotes_open
	               ,0 orders_booked
	               ,0 orders_booked_amt
	               ,0 budget_requested
	               ,0 budget_approved
	             ,sum(nvl(f3.func_forecasted_delta,0))  revenue_forecasted
	             ,0 revenue_actual
	             ,0 cost_forecasted
	             ,0 cost_actual
	             ,0 responses_forecasted
	             ,0 responses_positive
	             ,0 customers_targeted
	             ,0 customers_new
	             ,0 registrations
	             ,0 cancellations
	             ,0 attendance
                     ,0 OPPORTUNITY_AMT_S
                     ,0 ORDERS_BOOKED_AMT_S
                     ,0  REVENUE_FORECASTED_S
                     ,0 REVENUE_ACTUAL_S
                     ,0 COST_FORECASTED_S
                     ,0 COST_ACTUAL_S
                     ,0 BUDGET_REQUESTED_S
                     ,0 BUDGET_APPROVED_S
                     ,0 conversion_rate_s
					 ,0	metric1
					 ,0	metric2
	   FROM          ams_act_metric_hst                f3
	                 ,ams_metrics_all_b                 g3
	                 ,bim_i_source_codes                a
	   WHERE         f3.last_update_date between p_start_date and p_end_date
	   AND           f3.arc_act_metric_used_by  = a.object_type
	   AND           f3.act_metric_used_by_id = a.object_id
	   AND           a.child_object_id =0
           AND           a.object_type NOT IN ('RCAM')
	   AND           g3.metric_calculation_type     IN ('MANUAL','FUNCTION')
	   AND           g3.metric_category             = 902
	   --AND           g3.metric_parent_id             IS NULL
	   AND           g3.metric_id                    = f3.metric_id
	   GROUP BY      a.source_code_id
	                ,a.object_type
	                ,a.object_id
	                ,a.child_object_type
	                ,a.child_object_id
	                ,a.object_country
	                ,a.object_region
	                ,a.child_object_country
	                ,a.child_object_region
			,a.category_id
	                ,a.object_status
	                ,a.child_object_status
	                ,a.object_purpose
	                ,a.child_object_purpose
	                ,a.activity_type
	                ,a.activity_id
	                ,a.start_date
	                ,a.end_date
	                ,a.business_unit_id
			,nvl(f3.functional_currency_code,'USD')
	   HAVING       sum(nvl(f3.func_forecasted_delta,0)) <> 0
   UNION ALL
           SELECT      trunc(a.start_date) transaction_create_date
	               ,0 lead_id
	               ,'FREV' metric_type
	               ,a.source_code_id source_code_id
	   	       ,a.object_type object_type
	               ,a.object_id object_id
	               ,a.child_object_type child_object_type
	               ,a.child_object_id child_object_id
	               ,0 lead_rank_id
	               ,a.object_country
	               ,a.object_region
	               ,a.child_object_country
	               ,a.child_object_region
		       ,a.category_id category_id
	               ,a.business_unit_id business_unit_id
	               ,a.start_date
	               ,a.end_date
	               ,a.object_status object_status
	               ,a.child_object_status child_object_status
	               ,a.object_purpose object_purpose
	               ,a.child_object_purpose child_object_purpose
	               ,a.activity_type activity_type
	               ,a.activity_id activity_id
		       ,0 conversion_rate
	               ,nvl(f3.functional_currency_code,'USD') from_currency
	               ,0 leads
	               ,0 opportunities
	               ,0 opportunity_amt
	               ,0 opportunities_open
	               ,0 quotes
	               ,0 quotes_open
	               ,0 orders_booked
	               ,0 orders_booked_amt
	               ,0 budget_requested
	               ,0 budget_approved
	             ,sum(nvl(f3.func_forecasted_delta,0))  revenue_forecasted
	             ,0 revenue_actual
	             ,0 cost_forecasted
	             ,0 cost_actual
	             ,0 responses_forecasted
	             ,0 responses_positive
	             ,0 customers_targeted
	             ,0 customers_new
	             ,0 registrations
	             ,0 cancellations
	             ,0 attendance
                     ,0 OPPORTUNITY_AMT_S
                     ,0 ORDERS_BOOKED_AMT_S
                     ,0  REVENUE_FORECASTED_S
                     ,0 REVENUE_ACTUAL_S
                     ,0 COST_FORECASTED_S
                     ,0 COST_ACTUAL_S
                     ,0 BUDGET_REQUESTED_S
                     ,0 BUDGET_APPROVED_S
                     ,0 conversion_rate_s
					 ,0	metric1
					 ,0	metric2
	   FROM          ams_act_metric_hst                f3
	                 ,ams_metrics_all_b                 g3
	                 ,bim_i_source_codes                a
	   WHERE         f3.last_update_date between p_start_date and p_end_date
	   AND           f3.arc_act_metric_used_by  IN ('CSCH','EVEO')
	   AND           f3.act_metric_used_by_id = a.child_object_id
	   AND           f3.ARC_ACT_METRIC_USED_BY = a.child_object_type
	 --  AND           a.child_object_id =0
           AND           a.object_type NOT IN ('RCAM')
	   AND           g3.metric_calculation_type     IN ('MANUAL','FUNCTION')
	   AND           g3.metric_category             = 902
	   --AND           g3.metric_parent_id             IS NULL
	   AND           g3.metric_id                    = f3.metric_id
	   GROUP BY      a.source_code_id
	                ,a.object_type
	                ,a.object_id
	                ,a.child_object_type
	                ,a.child_object_id
	                ,a.object_country
	                ,a.object_region
	                ,a.child_object_country
	                ,a.child_object_region
			,a.category_id
	                ,a.object_status
	                ,a.child_object_status
	                ,a.object_purpose
	                ,a.child_object_purpose
	                ,a.activity_type
	                ,a.activity_id
	                ,a.start_date
	                ,a.end_date
	                ,a.business_unit_id
	                ,nvl(f3.functional_currency_code,'USD')
	   HAVING      sum(nvl(f3.func_forecasted_delta,0)) <> 0
	   union all --cost and revenue
	   SELECT      trunc(a.start_date) transaction_create_date
	               ,0 lead_id
	               ,'FCOST' metric_type
	               ,a.source_code_id source_code_id
	   	    ,a.object_type object_type
	               ,a.object_id object_id
	               ,a.child_object_type child_object_type
	               ,a.child_object_id child_object_id
	               ,0 lead_rank_id
	               ,a.object_country
	               ,a.object_region
	               ,a.child_object_country
	               ,a.child_object_region
		       ,a.category_id
	               ,a.business_unit_id business_unit_id
	               ,a.start_date
	               ,a.end_date
	               ,a.object_status object_status
	               ,a.child_object_status child_object_status
	               ,a.object_purpose object_purpose
	               ,a.child_object_purpose child_object_purpose
	               ,a.activity_type activity_type
	               ,a.activity_id activity_id
		       ,0 conversion_rate
	               ,nvl(f3.functional_currency_code,'USD') from_currency
	               ,0 leads
	               ,0 opportunities
	               ,0 opportunity_amt
	               ,0 opportunities_open
	               ,0 quotes
	               ,0 quotes_open
	               ,0 orders_booked
	               ,0 orders_booked_amt
	               ,0 budget_requested
	               ,0 budget_approved
	   	    ,0 revenue_forecasted
	   	    ,0 revenue_actual
	             ,sum(nvl(f3.func_forecasted_delta,0))  cost_forecasted
	             ,0 cost_actual
	             ,0 responses_forecasted
	             ,0 responses_positive
	             ,0 customers_targeted
	             ,0 customers_new
	             ,0 registrations
	             ,0 cancellations
	             ,0 attendance
                     ,0 OPPORTUNITY_AMT_S
                     ,0 ORDERS_BOOKED_AMT_S
                     ,0 REVENUE_FORECASTED_S
                     ,0 REVENUE_ACTUAL_S
                     ,0  COST_FORECASTED_S
                     ,0 COST_ACTUAL_S
                     ,0 BUDGET_REQUESTED_S
                     ,0 BUDGET_APPROVED_S
                     ,0 conversion_rate_s
					 ,0	metric1
					 ,0	metric2
	   FROM          ams_act_metric_hst                f3
	                 ,ams_metrics_all_b                 g3
	                 ,bim_i_source_codes                a
	   WHERE         f3.last_update_date between p_start_date and p_end_date
	   AND           f3.arc_act_metric_used_by  = a.object_type
	   AND           f3.act_metric_used_by_id = a.object_id
	   AND           a.child_object_id =0
           AND           a.object_type NOT IN ('RCAM')
	   AND           g3.metric_calculation_type     IN ('MANUAL','FUNCTION')
	   AND           g3.metric_category             = 901
	   --AND           g3.metric_parent_id             IS NULL
	   AND           g3.metric_id                    = f3.metric_id
	   GROUP BY      a.source_code_id
	                ,a.object_type
	                ,a.object_id
	                ,a.child_object_type
	                ,a.child_object_id
	                ,a.object_country
	                ,a.object_region
	                ,a.child_object_country
	                ,a.child_object_region
			,a.category_id
	                ,a.object_status
	                ,a.child_object_status
	                ,a.object_purpose
	                ,a.child_object_purpose
	                ,a.activity_type
	                ,a.activity_id
	                ,a.start_date
	                ,a.end_date
	                ,a.business_unit_id
	               ,nvl(f3.functional_currency_code,'USD')
	   HAVING      sum(nvl(f3.func_forecasted_delta,0)) <> 0
	  union all --cost and revenue at schedule level
	   SELECT      trunc(a.start_date) transaction_create_date
	               ,0 lead_id
	               ,'FCOST' metric_type
	               ,a.source_code_id source_code_id
	   	      ,a.object_type object_type
	               ,a.object_id object_id
	               ,a.child_object_type child_object_type
	               ,a.child_object_id child_object_id
	               ,0 lead_rank_id
	               ,a.object_country
	               ,a.object_region
	               ,a.child_object_country
	               ,a.child_object_region
		       ,a.category_id
	               ,a.business_unit_id business_unit_id
	               ,a.start_date
	               ,a.end_date
	               ,a.object_status object_status
	               ,a.child_object_status child_object_status
	               ,a.object_purpose object_purpose
	               ,a.child_object_purpose child_object_purpose
	               ,a.activity_type activity_type
	               ,a.activity_id activity_id
		       ,0 conversion_rate
	               ,nvl(f3.functional_currency_code,'USD') from_currency
	               ,0 leads
	               ,0 opportunities
	               ,0 opportunity_amt
	               ,0 opportunities_open
	               ,0 quotes
	               ,0 quotes_open
	               ,0 orders_booked
	               ,0 orders_booked_amt
	               ,0 budget_requested
	               ,0 budget_approved
	   	    ,0 revenue_forecasted
	   	    ,0 revenue_actual
	             ,sum(nvl(f3.func_forecasted_delta,0))  cost_forecasted
	             ,0 cost_actual
	             ,0 responses_forecasted
	             ,0 responses_positive
	             ,0 customers_targeted
	             ,0 customers_new
	             ,0 registrations
	             ,0 cancellations
	             ,0 attendance
                     ,0 OPPORTUNITY_AMT_S
                     ,0 ORDERS_BOOKED_AMT_S
                     ,0 REVENUE_FORECASTED_S
                     ,0 REVENUE_ACTUAL_S
                     ,0 COST_FORECASTED_S
                     ,0 COST_ACTUAL_S
                     ,0 BUDGET_REQUESTED_S
                     ,0 BUDGET_APPROVED_S
                     ,0 conversion_rate_s
					 ,0	metric1
					 ,0	metric2
	   FROM          ams_act_metric_hst                f3
	                 ,ams_metrics_all_b                 g3
	                 ,bim_i_source_codes                a
	   WHERE         f3.last_update_date between p_start_date and p_end_date
	   AND           f3.arc_act_metric_used_by  In ('CSCH','EVEO')
	   AND           f3.act_metric_used_by_id = a.child_object_id
	   AND           f3.ARC_ACT_METRIC_USED_BY = a.child_object_type
	   AND           g3.metric_calculation_type     IN ('MANUAL','FUNCTION')
	   AND           g3.metric_category             = 901
	   --AND           g3.metric_parent_id             IS NULL
	   AND           g3.metric_id                    = f3.metric_id
AND           a.object_type NOT IN ('RCAM')
	   GROUP BY      a.source_code_id
	                ,a.object_type
	                ,a.object_id
	                ,a.child_object_type
	                ,a.child_object_id
	                ,a.object_country
	                ,a.object_region
	                ,a.child_object_country
	                ,a.child_object_region
			,a.category_id
	                ,a.object_status
	                ,a.child_object_status
	                ,a.object_purpose
	                ,a.child_object_purpose
	                ,a.activity_type
	                ,a.activity_id
	                ,a.start_date
	                ,a.end_date
	                ,a.business_unit_id
	               ,nvl(f3.functional_currency_code,'USD')
	   HAVING     sum(nvl(f3.func_forecasted_delta,0)) <> 0
	    )
	   GROUP BY   transaction_create_date
	              ,lead_id
	   	      ,metric_type
                      ,source_code_id
	              ,object_type
	              ,object_id
	              ,child_object_type
	              ,child_object_id
	              ,lead_rank_id
	              ,object_country
	              ,object_region
	              ,child_object_country
	              ,child_object_region
		      ,category_id
	              ,business_unit_id
	              ,start_date
	              ,end_date
	              ,object_status
	              ,child_object_status
	              ,object_purpose
	              ,child_object_purpose
	              ,activity_type
                      ,activity_id
		      ,conversion_rate
		      ,from_currency
                      ,conversion_rate_s
	   ) inner ;
           ---------------------END NEW CODE------------------------
commit;
   BIS_COLLECTION_UTILITIES.log('BIM_I_MARKETING_FACTS:Third insert into bim_i_marketing_facts_stg');
   INSERT /*+ append parallel */
      INTO BIM_I_MARKETING_FACTS_STG CDF      (
              --MKT_DAILY_TRANSACTION_ID  ,
              CREATION_DATE             ,
              LAST_UPDATE_DATE          ,
              CREATED_BY                ,
              LAST_UPDATED_BY           ,
              LAST_UPDATE_LOGIN         ,
              TRANSACTION_CREATE_DATE   ,
              SOURCE_CODE_ID            ,
              OBJECT_TYPE               ,
              OBJECT_ID                 ,
              CHILD_OBJECT_TYPE         ,
              CHILD_OBJECT_ID           ,
              LEAD_RANK_ID              ,
              OBJECT_COUNTRY            ,
              OBJECT_REGION             ,
              CHILD_OBJECT_COUNTRY      ,
              CHILD_OBJECT_REGION       ,
	      CATEGORY_ID               ,
              BUSINESS_UNIT_ID          ,
              START_DATE                ,
              END_DATE                  ,
              OBJECT_STATUS             ,
              CHILD_OBJECT_STATUS       ,
              OBJECT_PURPOSE            ,
              CHILD_OBJECT_PURPOSE      ,
              ACTIVITY_TYPE             ,
              ACTIVITY_ID               ,
	      CONVERSION_RATE           ,
	      FROM_CURRENCY             ,
              LEADS,
              OPPORTUNITIES             ,
              OPPORTUNITY_AMT           ,
              OPPORTUNITIES_OPEN        ,
              ORDERS_BOOKED             ,
              ORDERS_BOOKED_AMT         ,
              REVENUE_FORECASTED        ,
              REVENUE_ACTUAL            ,
              COST_FORECASTED           ,
              COST_ACTUAL               ,
              BUDGET_APPROVED           ,
              BUDGET_REQUESTED          ,
              RESPONSES_FORECASTED      ,
              RESPONSES_POSITIVE        ,
              CUSTOMERS_NEW             ,
              REGISTRATIONS             ,
              CANCELLATIONS             ,
              ATTENDANCE                ,
              OPPORTUNITY_AMT_S         ,
              ORDERS_BOOKED_AMT_S       ,
              REVENUE_FORECASTED_S      ,
              REVENUE_ACTUAL_S          ,
              COST_FORECASTED_S         ,
              COST_ACTUAL_S             ,
              BUDGET_REQUESTED_S        ,
              BUDGET_APPROVED_S         ,
              CONVERSION_RATE_S			,
			  METRIC1					,
			  METRIC2
                )
SELECT  /*+ parallel */
              sysdate
              ,sysdate
              ,-1
              ,-1
              ,-1
              ,trunc(s.start_date)
              ,s.source_code_id
              ,s.object_type
              ,s.object_id
              ,s.child_object_type
              ,s.child_object_id
              ,0
              ,s.object_country
              ,s.object_region
              ,s.child_object_country
              ,s.child_object_region
	      ,nvl(s.category_id,-1)
              ,s.business_unit_id
              ,s.start_date
              ,s.end_date
              ,s.object_status
              ,s.child_object_status
              ,s.object_purpose
              ,s.child_object_purpose
              ,s.activity_type
              ,s.activity_id
	      ,0
	      ,null
              ,0
              ,0
              ,0
              ,0
              ,0
              ,0
              ,0
              ,0
              ,0
              ,0
              ,0
              ,0
              ,0
              ,0
              ,0
              ,0
              ,0
              ,0
              ,0
              ,0
              ,0
              ,0
              ,0
              ,0
              ,0
              ,0
              ,0
			  ,0
			  ,0
FROM  bim_i_source_codes s,
      bim_i_marketing_facts f
where s.child_object_id = 0
and   f.child_object_id(+) = 0
and   s.object_id = f.object_id (+)
and   s.object_type = f.object_type (+)
AND           s.object_type NOT IN ('RCAM')
and   f.object_id IS NULL;
commit;

bis_collection_utilities.log('Truncating Facts Table');

Execute Immediate 'Truncate Table '||l_schema||'.bim_i_marketing_facts';
BIS_COLLECTION_UTILITIES.deleteLogForObject('MARKETING_FACTS');


--insert schedules
   INSERT /*+ append parallel */
      INTO BIM_I_MARKETING_FACTS CDF      (
              --MKT_DAILY_TRANSACTION_ID  ,
              CREATION_DATE             ,
              LAST_UPDATE_DATE          ,
              CREATED_BY                ,
              LAST_UPDATED_BY           ,
              LAST_UPDATE_LOGIN         ,
              TRANSACTION_CREATE_DATE   ,
              SOURCE_CODE_ID            ,
              OBJECT_TYPE               ,
              OBJECT_ID                 ,
              CHILD_OBJECT_TYPE         ,
              CHILD_OBJECT_ID           ,
              LEAD_RANK_ID              ,
              OBJECT_COUNTRY            ,
              OBJECT_REGION             ,
              CHILD_OBJECT_COUNTRY      ,
              CHILD_OBJECT_REGION       ,
	      CATEGORY_ID               ,
              BUSINESS_UNIT_ID          ,
              START_DATE                ,
              END_DATE                  ,
              OBJECT_STATUS             ,
              CHILD_OBJECT_STATUS       ,
              OBJECT_PURPOSE            ,
              CHILD_OBJECT_PURPOSE      ,
              ACTIVITY_TYPE             ,
              ACTIVITY_ID               ,
	      CONVERSION_RATE           ,
	      FROM_CURRENCY             ,
              LEADS,
              OPPORTUNITIES             ,
              OPPORTUNITY_AMT           ,
              OPPORTUNITIES_OPEN        ,
              ORDERS_BOOKED             ,
              ORDERS_BOOKED_AMT         ,
              REVENUE_FORECASTED        ,
              REVENUE_ACTUAL            ,
              COST_FORECASTED           ,
              COST_ACTUAL               ,
              BUDGET_APPROVED           ,
              BUDGET_REQUESTED          ,
              RESPONSES_FORECASTED      ,
              RESPONSES_POSITIVE        ,
              CUSTOMERS_NEW             ,
              REGISTRATIONS             ,
              CANCELLATIONS             ,
              ATTENDANCE                ,
              OPPORTUNITY_AMT_S         ,
              ORDERS_BOOKED_AMT_S       ,
              REVENUE_FORECASTED_S      ,
              REVENUE_ACTUAL_S          ,
              COST_FORECASTED_S         ,
              COST_ACTUAL_S             ,
              BUDGET_REQUESTED_S        ,
              BUDGET_APPROVED_S         ,
              CONVERSION_RATE_S			,
			  metric1					,
			  metric2
                )
SELECT  /*+ parallel */
              sysdate
              ,sysdate
              ,-1
              ,-1
              ,-1
              ,trunc(s.start_date)
              ,s.source_code_id
              ,s.object_type
              ,s.object_id
              ,s.child_object_type
              ,s.child_object_id
              ,0
              ,s.object_country
              ,s.object_region
              ,s.child_object_country
              ,s.child_object_region
	      ,nvl(s.category_id,-1)
              ,s.business_unit_id
              ,s.start_date
              ,s.end_date
              ,s.object_status
              ,s.child_object_status
              ,s.object_purpose
              ,s.child_object_purpose
              ,s.activity_type
              ,s.activity_id
	      ,0
	      ,0
              ,0
              ,0
              ,0
              ,0
              ,0
              ,0
              ,0
              ,0
              ,0
              ,0
              ,0
              ,0
              ,0
              ,0
              ,0
              ,0
              ,0
              ,0
              ,0
              ,0
              ,0
              ,0
              ,0
              ,0
              ,0
              ,0
              ,null
			  ,0
			  ,0
FROM  bim_i_source_codes s,
      bim_i_marketing_facts f
where s.child_object_id > 0
and   f.child_object_id(+) > 0
and   s.child_object_id = f.child_object_id (+)
and   s.child_object_type = f.child_object_type (+)
and f.child_object_id is null;
commit;

BIS_COLLECTION_UTILITIES.log('BIM_I_MARKETING_FACTS:Insert into bim_i_mkt_rates.');
--Insert rates_temp table
INSERT /*+ append parallel */
INTO BIM_I_MKT_RATES MRT(tc_code,
                         trx_date,
			 prim_conversion_rate,
			 sec_conversion_rate)
SELECT from_currency,
       transaction_create_date,
       FII_CURRENCY.get_rate(from_currency,l_global_currency_code,transaction_create_date,l_pgc_rate_type),
       FII_CURRENCY.get_rate(from_currency,l_secondary_currency_code,transaction_create_date,l_sgc_rate_type)
FROM (select distinct from_currency from_currency,
                      transaction_create_date transaction_create_date
       from bim_i_marketing_facts_stg);
commit;
BIS_COLLECTION_UTILITIES.log('BIM_I_MARKETING_FACTS:After Insert into bim_i_mkt_rates.');
l_check_missing_rate := Check_Missing_Rates (p_start_date);
if (l_check_missing_rate = -1) then
 BIS_COLLECTION_UTILITIES.debug('before truncating first time load' );
      l_stmt := 'TRUNCATE table '||L_SCHEMA||'.BIM_I_MARKETING_FACTS_STG';
      EXECUTE IMMEDIATE l_stmt;
      commit;
x_return_status := FND_API.G_RET_STS_ERROR;
RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
end if;
BIS_COLLECTION_UTILITIES.log('BIM_I_MARKETING_FACTS:After check missing rates');
BIS_COLLECTION_UTILITIES.log('BIM_I_MARKETING_FACTS:Final Insert into bim_i_marketing_facts.');
 INSERT /*+ append parallel */
      INTO BIM_I_MARKETING_FACTS CDF      (
              --MKT_DAILY_TRANSACTION_ID  ,
              CREATION_DATE             ,
              LAST_UPDATE_DATE          ,
              CREATED_BY                ,
              LAST_UPDATED_BY           ,
              LAST_UPDATE_LOGIN         ,
	      TRANSACTION_CREATE_DATE   ,
	      LEAD_ID                   ,
	      METRIC_TYPE               ,
              SOURCE_CODE_ID            ,
              OBJECT_TYPE               ,
              OBJECT_ID                 ,
              CHILD_OBJECT_TYPE         ,
              CHILD_OBJECT_ID           ,
              LEAD_RANK_ID              ,
              OBJECT_COUNTRY            ,
              OBJECT_REGION             ,
              CHILD_OBJECT_COUNTRY      ,
              CHILD_OBJECT_REGION       ,
              CATEGORY_ID               ,
	      BUSINESS_UNIT_ID          ,
              START_DATE                ,
              END_DATE                  ,
              OBJECT_STATUS             ,
              CHILD_OBJECT_STATUS       ,
              OBJECT_PURPOSE            ,
              CHILD_OBJECT_PURPOSE      ,
              ACTIVITY_TYPE             ,
              ACTIVITY_ID               ,
	      CONVERSION_RATE           ,
	      FROM_CURRENCY             ,
              LEADS                     ,
              OPPORTUNITIES             ,
              OPPORTUNITY_AMT           ,
              OPPORTUNITIES_OPEN        ,
              ORDERS_BOOKED             ,
              ORDERS_BOOKED_AMT         ,
              REVENUE_FORECASTED        ,
              REVENUE_ACTUAL            ,
              COST_FORECASTED           ,
              COST_ACTUAL               ,
              BUDGET_APPROVED           ,
              BUDGET_REQUESTED          ,
              RESPONSES_FORECASTED      ,
              RESPONSES_POSITIVE        ,
              CUSTOMERS_TARGETED        ,
              CUSTOMERS_NEW             ,
              REGISTRATIONS             ,
              CANCELLATIONS             ,
              ATTENDANCE                ,
              OPPORTUNITY_AMT_S         ,
              ORDERS_BOOKED_AMT_S       ,
              REVENUE_FORECASTED_S      ,
              REVENUE_ACTUAL_S          ,
              COST_FORECASTED_S         ,
              COST_ACTUAL_S             ,
              BUDGET_REQUESTED_S        ,
              BUDGET_APPROVED_S         ,
              CONVERSION_RATE_S			,
			  metric1		,
	  		  metric2
	      )
SELECT  /*+ parallel */
	     --  BIM_I_MARKETING_FACTS_s.nextval ,
              sysdate
              ,sysdate
              ,-1
              ,-1
              ,-1
              ,transaction_create_date
	      ,lead_id
	      ,metric_type
              ,source_code_id
              ,object_type
              ,object_id
              ,child_object_type
              ,child_object_id
              ,lead_rank_id
              ,object_country
              ,object_region
              ,child_object_country
              ,child_object_region
	      ,nvl(category_id,-1)
              ,business_unit_id
              ,start_date
              ,end_date
              ,object_status
              ,child_object_status
              ,object_purpose
              ,child_object_purpose
              ,activity_type
              ,activity_id
	      ,conversion_rate
              ,from_currency
              ,leads
              ,opportunities
              ,opportunity_amt*rt.prim_conversion_rate
              ,opportunities_open
              ,orders_booked
              ,orders_booked_amt*rt.prim_conversion_rate
              ,revenue_forecasted*rt.prim_conversion_rate
              ,revenue_actual*rt.prim_conversion_rate
              ,cost_forecasted*rt.prim_conversion_rate
              ,cost_actual*rt.prim_conversion_rate
              ,budget_approved*rt.prim_conversion_rate
              ,budget_requested*rt.prim_conversion_rate
              ,responses_forecasted
              ,responses_positive
              ,customers_targeted
              ,customers_new
              ,registrations
              ,cancellations
              ,attendance
              ,OPPORTUNITY_AMT*sec_conversion_rate
              ,ORDERS_BOOKED_AMT*sec_conversion_rate
              ,REVENUE_FORECASTED*sec_conversion_rate
              ,REVENUE_ACTUAL*sec_conversion_rate
              ,COST_FORECASTED*sec_conversion_rate
              ,COST_ACTUAL*sec_conversion_rate
              ,BUDGET_REQUESTED*sec_conversion_rate
              ,BUDGET_APPROVED*sec_conversion_rate
              ,CONVERSION_RATE_S
			  ,metric1*rt.prim_conversion_rate
			  ,metric1*sec_conversion_rate
FROM bim_i_marketing_facts_stg a, bim_i_mkt_rates rt
where a.from_currency = rt.tc_code(+)
and a.transaction_create_date= rt.trx_date(+);
commit;

  --BIS_COLLECTION_UTILITIES.log('BIM_I_MARKETING_FACTS:Inserted '||SQL%COUNT);
      EXECUTE IMMEDIATE 'COMMIT';
      -- EXECUTE IMMEDIATE 'ALTER SEQUENCE bim_i_marketing_facts_s CACHE 20';

 -- Analyze the daily facts table
   DBMS_STATS.gather_table_stats('BIM','BIM_I_MARKETING_FACTS', estimate_percent => 5,
                                  degree => 8, granularity => 'GLOBAL', cascade =>TRUE);
--dbms_output.put_line('b4 put into history');

   -- EXECUTE IMMEDIATE 'TRUNCATE TABLE '||l_schema||'.MLOG$_BIM_I_MARKETING_FACT';

     -- Make entry in the history table
    BIS_COLLECTION_UTILITIES.log('BIM_I_MARKETING_FACTS: Wrapup');
    BEGIN
    IF (Not BIS_COLLECTION_UTILITIES.setup('MARKETING_FACTS')) THEN
    RAISE FND_API.G_EXC_ERROR;
    return;
    END IF;

    BIS_COLLECTION_UTILITIES.WRAPUP(
                  p_status =>TRUE ,
                  p_period_from =>p_start_date,
                  p_period_to => sysdate--p_end_date
                  );
   Exception when others then
     Rollback;
     BIS_COLLECTION_UTILITIES.WRAPUP(
                  p_status => FALSE,
                  p_period_from =>p_start_date,
                  p_period_to => sysdate--p_end_date
                  );
     RAISE FND_API.G_EXC_ERROR;
     END;

   BIS_COLLECTION_UTILITIES.log('BIM_I_MARKETING_FACTS:Before create index');

   BIM_UTL_PKG.CREATE_INDEX('BIM_I_MARKETING_FACTS');
   l_temp_msg := to_char( sysdate, 'dd/mm/yyyy:hh:mi:ss');
   --ams_utility_pvt.write_conc_log('BIM_I_MARKETING_FACTS:FIRST_LOAD: AFTER CREATE INDEX ' || l_temp_msg);
   BIS_COLLECTION_UTILITIES.log('BIM_I_MARKETING_FACTS:After create index');
   /*fnd_message.set_name('BIM','BIM_R_PROG_COMPLETION');
   fnd_message.set_token('program_name', 'Marketing first load', FALSE);
   fnd_file.put_line(fnd_file.log,fnd_message.get);*/
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_msg_PUB.Count_And_Get (
          --  p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

 ams_utility_pvt.write_conc_log('BIM_I_MARKETING_FACTS:FIRST_LOAD:IN EXPECTED EXCEPTION '||sqlerrm(sqlcode));
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_msg_PUB.Count_And_Get (
            --p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );
    BIS_COLLECTION_UTILITIES.log('BIM_I_MARKETING_FACTS:Unexpected'||sqlerrm(sqlcode));

   WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_msg_PUB.Check_msg_Level (FND_msg_PUB.G_msg_LVL_UNEXP_ERROR)
     THEN
        FND_msg_PUB.Add_Exc_msg( g_pkg_name,l_api_name);
     END IF;

     -- Standard call to get message count and if count=1, get the message
     FND_msg_PUB.Count_And_Get (
           -- p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );
     BIS_COLLECTION_UTILITIES.log('BIM_I_MARKETING_FACTS:IN OTHERS EXCEPTION'||sqlerrm(sqlcode));
--end;
END FIRST_LOAD;
--------------------------------------------------------------------------------------------------
-- This procedure will execute when data is loaded for subsequent time.

-- PROCEDURE  SUB_LOAD
--------------------------------------------------------------------------------------------------
PROCEDURE SUB_LOAD
( p_start_date            IN  DATE
 ,p_end_date              IN  DATE
 ,p_api_version_number    IN  NUMBER
 ,p_init_msg_list         IN  VARCHAR2
 ,p_load_type             IN  VARCHAR2
 ,x_msg_count             OUT NOCOPY NUMBER
 ,x_msg_data              OUT NOCOPY VARCHAR2
 ,x_return_status         OUT NOCOPY VARCHAR2
)
IS
    l_user_id              	  NUMBER := FND_GLOBAL.USER_ID();
    l_start_date   		  DATE;
    l_end_date     		  DATE;
    l_last_update_date     	  DATE;
    l_conc_start_date             DATE;
    l_conc_end_date               DATE;
    l_sc_s_date                   DATE;
    l_sc_e_date                   DATE;
    l_success              	  VARCHAR2(3);
    l_api_version_number   	  CONSTANT NUMBER       := 1.0;
    l_api_name             	  CONSTANT VARCHAR2(30) := 'SUB_LOAD';
    l_table_name		  VARCHAR2(100);
    l_temp_msg		          VARCHAR2(100);
    l_check_missing_rate          NUMBER;
    l_min_start_date              DATE;
    l_min_date			  date;
    l_stmt                        VARCHAR2(100);
    l_status       VARCHAR2(5);
    l_industry     VARCHAR2(5);
    l_schema       VARCHAR2(30);
    l_return       BOOLEAN;

BEGIN
    --dbms_output.put_line('inside sub load:'||p_start_date || ' '|| p_end_date);
   l_return  := fnd_installation.get_app_info('BIM', l_status, l_industry, l_schema);
   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           g_pkg_name)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list )
   THEN
      FND_msg_PUB.initialize;
   END IF;

   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   --dbms_output.put_line('inside sub load 2:');

   -- The below four commands are necessary for the purpose of the parallel insertion */
   BEGIN
   EXECUTE IMMEDIATE 'ALTER SESSION ENABLE PARALLEL dml ';
   --EXECUTE IMMEDIATE 'ALTER SESSION SET SORT_AREA_SIZE=100000000 ';
   --EXECUTE IMMEDIATE 'ALTER SESSION SET HASH_AREA_SIZE=100000000 ';
   --EXECUTE IMMEDIATE 'ALTER TABLE   BIM_I_MARKETING_FACTS nologging ';
   -- EXECUTE IMMEDIATE 'ALTER SEQUENCE BIM_I_MARKETING_FACTS_s CACHE 1000 ';
   EXCEPTION
    when others then
    --dbms_output.put_line('inside sub load:'||sqlerrm(sqlcode));
    l_temp_msg := to_char( sysdate, 'dd/mm/yyyy:hh:mi:ss');
   END;
    --dbms_output.put_line('right b4 inserting');
    BIS_COLLECTION_UTILITIES.log('BIM_I_MARKETING_FACTS:SUBSEQUENT_LOAD start');
    --ams_utility_pvt.write_conc_log('BIM_I_MARKETING_FACTS:SUBSEQUENT_LOAD: BEFORE FIRST INSERT ' || l_temp_msg);
    BEGIN
       DELETE from bim_i_marketing_facts  where transaction_create_date>= p_start_date and metric_type is not null;
     COMMIT;
     EXCEPTION
     when others then
     BIS_COLLECTION_UTILITIES.log('BIM_I_MARKETING_FACTS: Error in first insert:'||sqlerrm(sqlcode));
     --dbms_output.put_line('error inserting:'||sqlerrm(sqlcode));
     END;
     EXECUTE IMMEDIATE 'TRUNCATE table '||l_schema||'.BIM_I_MARKETING_FACTS_STG';
     EXECUTE IMMEDIATE 'TRUNCATE table '||l_schema||'.BIM_I_MKT_RATES';

    BIS_COLLECTION_UTILITIES.log('BIM_I_MARKETING_FACTS:First insert BIM_I_MARKETING_FACTS_STG');
    --BEGIN
    --dbms_output.put_line('right b4 inserting'||sqlerrm(sqlcode));
      INSERT
      INTO  BIM_I_MARKETING_FACTS_STG CDF
      (       -- MKT_DAILY_TRANSACTION_ID  ,
              CREATION_DATE             ,
              LAST_UPDATE_DATE          ,
              CREATED_BY                ,
              LAST_UPDATED_BY           ,
              LAST_UPDATE_LOGIN         ,
              LEAD_ID                   ,
	      METRIC_TYPE               ,
	      TRANSACTION_CREATE_DATE   ,
              SOURCE_CODE_ID            ,
              OBJECT_TYPE               ,
              OBJECT_ID                 ,
              CHILD_OBJECT_TYPE         ,
              CHILD_OBJECT_ID           ,
              LEAD_RANK_ID              ,
              OBJECT_COUNTRY            ,
              OBJECT_REGION             ,
              CHILD_OBJECT_COUNTRY      ,
              CHILD_OBJECT_REGION       ,
	      CATEGORY_ID               ,
              BUSINESS_UNIT_ID          ,
              START_DATE                ,
              END_DATE                  ,
              OBJECT_STATUS             ,
              CHILD_OBJECT_STATUS       ,
              OBJECT_PURPOSE            ,
              CHILD_OBJECT_PURPOSE      ,
              ACTIVITY_TYPE             ,
              ACTIVITY_ID               ,
	      CONVERSION_RATE           ,
	      FROM_CURRENCY             ,
	      LEADS,
              OPPORTUNITIES             ,
              OPPORTUNITY_AMT           ,
              OPPORTUNITIES_OPEN        ,
              ORDERS_BOOKED             ,
              ORDERS_BOOKED_AMT         ,
              REVENUE_FORECASTED        ,
              REVENUE_ACTUAL            ,
              COST_FORECASTED           ,
              COST_ACTUAL               ,
              BUDGET_APPROVED           ,
              BUDGET_REQUESTED          ,
              RESPONSES_FORECASTED      ,
              RESPONSES_POSITIVE        ,
              CUSTOMERS_TARGETED        ,
              CUSTOMERS_NEW             ,
              REGISTRATIONS             ,
              CANCELLATIONS             ,
              ATTENDANCE                ,
              OPPORTUNITY_AMT_S         ,
              ORDERS_BOOKED_AMT_S       ,
              REVENUE_FORECASTED_S      ,
              REVENUE_ACTUAL_S          ,
              COST_FORECASTED_S         ,
              COST_ACTUAL_S             ,
              BUDGET_REQUESTED_S        ,
              BUDGET_APPROVED_S         ,
              CONVERSION_RATE_S			,
			  metric1		,
			  metric2
      )
      SELECT
	       --BIM_I_MARKETING_FACTS_s.nextval,
              sysdate
              ,sysdate
              ,-1
              ,-1
              ,-1
	      ,0
              ,'OTHER'
              ,transaction_create_date
              ,source_code_id
              ,object_type
              ,object_id
              ,child_object_type
              ,child_object_id
              ,lead_rank_id
              ,object_country
              ,object_region
              ,child_object_country
              ,child_object_region
	      ,nvl(category_id,-1)
              ,business_unit_id
              ,start_date
              ,end_date
              ,object_status
              ,child_object_status
              ,object_purpose
              ,child_object_purpose
              ,activity_type
              ,activity_id
	      ,conversion_rate
	      ,from_currency
	      ,leads
              ,opportunities
              ,opportunity_amt
              ,opportunities_open
              ,orders_booked
              ,orders_booked_amt
              ,revenue_forecasted
              ,revenue_actual
              ,cost_forecasted
              ,cost_actual
              ,budget_approved
              ,budget_requested
              ,responses_forecasted
              ,responses_positive
              ,customers_targeted
              ,customers_new
              ,registrations
              ,cancellations
              ,attendance
              ,OPPORTUNITY_AMT_S
              ,ORDERS_BOOKED_AMT_S
              ,REVENUE_FORECASTED_S
              ,REVENUE_ACTUAL_S
              ,COST_FORECASTED_S
              ,COST_ACTUAL_S
              ,BUDGET_REQUESTED_S
              ,BUDGET_APPROVED_S
              ,CONVERSION_RATE_S
			  ,metric1
			  ,metric2
FROM (
      SELECT  transaction_create_date transaction_create_date
              ,source_code_id source_code_id
              ,object_type object_type
              ,object_id object_id
              ,child_object_type child_object_type
              ,child_object_id child_object_id
              ,lead_rank_id lead_rank_id
              ,object_country object_country
              ,object_region object_region
              ,child_object_country child_object_country
              ,child_object_region child_object_region
	      ,category_id category_id
              ,business_unit_id business_unit_id
              ,start_date start_date
              ,end_date end_date
              ,object_status object_status
              ,child_object_status child_object_status
              ,object_purpose object_purpose
              ,child_object_purpose child_object_purpose
              ,activity_type activity_type
              ,activity_id activity_id
	      ,conversion_rate
	      ,from_currency
              ,sum(leads) leads
              ,sum(opportunities) opportunities
              ,sum(opportunity_amt) opportunity_amt
              ,sum(opportunities_open) opportunities_open
              ,sum(orders_booked) orders_booked
              ,sum(orders_booked_amt) orders_booked_amt
              ,sum(budget_requested) budget_requested
              ,sum(budget_approved) budget_approved
              ,sum(revenue_forecasted) revenue_forecasted
              ,sum(revenue_actual) revenue_actual
              ,sum(cost_forecasted) cost_forecasted
              ,sum(cost_actual) cost_actual
              ,sum(responses_forecasted) responses_forecasted
              ,sum(responses_positive) responses_positive
              ,sum(customers_targeted) customers_targeted
              ,sum(customers_new) customers_new
              ,sum(registrations) registrations
              ,sum(cancellations) cancellations
              ,sum(attendance) attendance
              ,sum(OPPORTUNITY_AMT_S) OPPORTUNITY_AMT_S
              ,sum(ORDERS_BOOKED_AMT_S) ORDERS_BOOKED_AMT_S
              ,sum(REVENUE_FORECASTED_S)  REVENUE_FORECASTED_S
              ,sum(REVENUE_ACTUAL_S )      REVENUE_ACTUAL_S
              ,sum(COST_FORECASTED_S )     COST_FORECASTED_S
              ,sum(COST_ACTUAL_S      )     COST_ACTUAL_S
              ,sum(BUDGET_REQUESTED_S  )    BUDGET_REQUESTED_S
              ,sum(BUDGET_APPROVED_S)       BUDGET_APPROVED_S
              ,CONVERSION_RATE_S            CONVERSION_RATE_S
			  ,sum(metric1)       metric1
			  ,sum(metric2)       metric2
  FROM       (
--cost and revenue
SELECT  /*+ USE_NL(F3 A G3) ordered */ trunc(f3.last_update_date) transaction_create_date
          ,a.source_code_id source_code_id
            ,a.object_type object_type
            ,a.object_id object_id
            ,a.child_object_type child_object_type
            ,a.child_object_id child_object_id
            ,0 lead_rank_id
            ,a.object_country
            ,a.object_region
            ,a.child_object_country
            ,a.child_object_region
	    ,a.category_id
            ,a.business_unit_id business_unit_id
            ,a.start_date
            ,a.end_date
            ,a.object_status object_status
            ,a.child_object_status child_object_status
            ,a.object_purpose object_purpose
            ,a.child_object_purpose child_object_purpose
            ,a.activity_type activity_type
            ,a.activity_id activity_id
	    ,0 conversion_rate
            ,nvl(f3.functional_currency_code,'USD') from_currency
            ,0 leads
            ,0 opportunities
            ,0 opportunity_amt
            ,0 opportunities_open
            ,0 quotes
            ,0 quotes_open
            ,0 orders_booked
            ,0 orders_booked_amt
            ,0 budget_requested
            ,0 budget_approved
          ,0 revenue_forecasted
          ,sum(nvl(f3.func_actual_delta,0))  REVENUE_ACTUAL
          ,0 cost_forecasted
          ,0 cost_actual
          ,0 responses_forecasted
          ,0 responses_positive
          ,0 customers_targeted
          ,0 customers_new
          ,0 registrations
          ,0 cancellations
          ,0 attendance
          ,0 OPPORTUNITY_AMT_S
          ,0 ORDERS_BOOKED_AMT_S
          ,0 REVENUE_FORECASTED_S
          ,0  REVENUE_ACTUAL_S
          ,0 COST_FORECASTED_S
          ,0 COST_ACTUAL_S
          ,0 BUDGET_REQUESTED_S
          ,0 BUDGET_APPROVED_S
          ,0 conversion_rate_s
		  ,0 metric1
		  ,0 metric2
FROM
               ams_act_metric_hst                f3
              ,ams_metrics_all_b                 g3
              ,bim_i_source_codes                a
WHERE         f3.last_update_date between p_start_date and p_end_date
AND           f3.arc_act_metric_used_by  = a.object_type
AND           f3.act_metric_used_by_id = a.object_id
AND           a.child_object_id =0
AND         a.object_type NOT IN ('RCAM')
AND           g3.metric_calculation_type     IN ('MANUAL','FUNCTION')
AND           g3.metric_category             = 902
--AND           g3.metric_parent_id             IS NULL
AND           g3.metric_id                    = f3.metric_id
GROUP BY      trunc(f3.last_update_date)
           ,a.source_code_id
              ,a.object_type
             ,a.object_id
             ,a.child_object_type
             ,a.child_object_id
             ,a.object_country
             ,a.object_region
             ,a.child_object_country
             ,a.child_object_region
	     ,a.category_id
             ,a.object_status
             ,a.child_object_status
             ,a.object_purpose
             ,a.child_object_purpose
             ,a.activity_type
             ,a.activity_id
             ,a.start_date
             ,a.end_date
             ,a.business_unit_id
	     ,nvl(f3.functional_currency_code,'USD')
HAVING   sum(nvl(f3.func_actual_delta,0)) <> 0
union all --cost and revenue
SELECT  /*+ USE_NL(F3 A G3) ordered */ trunc(f3.last_update_date) transaction_create_date
          ,a.source_code_id source_code_id
            ,a.object_type object_type
            ,a.object_id object_id
            ,a.child_object_type child_object_type
            ,a.child_object_id child_object_id
            ,0 lead_rank_id
            ,a.object_country
            ,a.object_region
            ,a.child_object_country
            ,a.child_object_region
	    ,a.category_id
            ,a.business_unit_id business_unit_id
            ,a.start_date
            ,a.end_date
            ,a.object_status object_status
            ,a.child_object_status child_object_status
            ,a.object_purpose object_purpose
            ,a.child_object_purpose child_object_purpose
            ,a.activity_type activity_type
            ,a.activity_id activity_id
	    ,0 conversion_rate
            ,nvl(f3.functional_currency_code,'USD') from_currency
            ,0 leads
            ,0 opportunities
            ,0 opportunity_amt
            ,0 opportunities_open
            ,0 quotes
            ,0 quotes_open
            ,0 orders_booked
            ,0 orders_booked_amt
            ,0 budget_requested
            ,0 budget_approved
          ,0 revenue_forecasted
          ,sum(nvl(f3.func_actual_delta,0))  REVENUE_ACTUAL
          ,0 cost_forecasted
          ,0 cost_actual
          ,0 responses_forecasted
          ,0 responses_positive
          ,0 customers_targeted
          ,0 customers_new
          ,0 registrations
          ,0 cancellations
          ,0 attendance
          ,0 OPPORTUNITY_AMT_S
          ,0 ORDERS_BOOKED_AMT_S
          ,0 REVENUE_FORECASTED_S
          ,0  REVENUE_ACTUAL_S
          ,0 COST_FORECASTED_S
          ,0 COST_ACTUAL_S
          ,0 BUDGET_REQUESTED_S
          ,0 BUDGET_APPROVED_S
          ,0 conversion_rate_s
 		  ,0 metric1
		  ,0 metric2
FROM
               ams_act_metric_hst                f3
              ,ams_metrics_all_b                 g3
              ,bim_i_source_codes                a
WHERE         f3.last_update_date between p_start_date and p_end_date
AND           f3.arc_act_metric_used_by  in ('CSCH','EVEO')
AND           f3.act_metric_used_by_id = a.child_object_id
AND           f3.ARC_ACT_METRIC_USED_BY = a.child_object_type
AND         a.object_type NOT IN ('RCAM')
AND           g3.metric_calculation_type     IN ('MANUAL','FUNCTION')
AND           g3.metric_category             = 902
--AND           g3.metric_parent_id             IS NULL
AND           g3.metric_id                    = f3.metric_id
GROUP BY     trunc(f3.last_update_date)
             ,a.source_code_id
             ,a.object_type
             ,a.object_id
             ,a.child_object_type
             ,a.child_object_id
             ,a.object_country
             ,a.object_region
             ,a.child_object_country
             ,a.child_object_region
	     ,a.category_id
             ,a.object_status
             ,a.child_object_status
             ,a.object_purpose
             ,a.child_object_purpose
             ,a.activity_type
             ,a.activity_id
             ,a.start_date
             ,a.end_date
             ,a.business_unit_id
             ,nvl(f3.functional_currency_code,'USD')
HAVING       sum(nvl(f3.func_actual_delta,0)) <> 0
UNION ALL
SELECT  /*+ USE_NL(F1 G1 A) ordered */
            trunc(f1.last_update_date) creation_date
          ,a.source_code_id source_code_id
            ,a.object_type object_type
            ,a.object_id object_id
            ,a.child_object_type child_object_type
            ,a.child_object_id child_object_id
            ,0 lead_rank_id
            ,a.object_country
            ,a.object_region
            ,a.child_object_country
            ,a.child_object_region
	    ,a.category_id
            ,a.business_unit_id business_unit_id
            ,a.start_date
            ,a.end_date
            ,a.object_status object_status
            ,a.child_object_status child_object_status
            ,a.object_purpose object_purpose
            ,a.child_object_purpose child_object_purpose
            ,a.activity_type activity_type
            ,a.activity_id activity_id
	    ,0 conversion_rate
            ,nvl(f1.functional_currency_code,'USD') from_currency
            ,0 leads
            ,0 opportunities
            ,0 opportunity_amt
            ,0 opportunities_open
            ,0 quotes
            ,0 quotes_open
            ,0 orders_booked
            ,0 orders_booked_amt
            ,0 budget_requested
            ,0 budget_approved
          ,0  revenue_forecasted
          ,0 revenue_actual
          ,0 cost_forecasted
          ,sum(nvl(f1.func_actual_delta,0)) cost_actual
          ,0 responses_forecasted
          ,0 responses_positive
          ,0 customers_targeted
          ,0 customers_new
          ,0 registrations
          ,0 cancellations
          ,0 attendance
          ,0 OPPORTUNITY_AMT_S
          ,0 ORDERS_BOOKED_AMT_S
          ,0 REVENUE_FORECASTED_S
          ,0 REVENUE_ACTUAL_S
          ,0 COST_FORECASTED_S
          ,0 COST_ACTUAL_S
          ,0 BUDGET_REQUESTED_S
          ,0 BUDGET_APPROVED_S
          ,0 CONVERSION_RATE_S
		  ,0 metric1
		  ,0 metric2
FROM          bim_i_source_codes         a
              ,ams_act_metric_hst            f1
              ,ams_metrics_all_b            g1
WHERE      f1.last_update_date between p_start_date and p_end_date
AND        f1.arc_act_metric_used_by       = a.object_type
AND        f1.act_metric_used_by_id =a.object_id
AND        a.child_object_id =0
AND         a.object_type NOT IN ('RCAM')
AND        g1.metric_category              = 901
AND        g1.metric_id                    = f1.metric_id
AND        g1.metric_calculation_type         IN ('MANUAL','FUNCTION')
GROUP BY     trunc(f1.last_update_date)
           ,a.source_code_id
             ,a.object_type
             ,a.object_id
             ,a.child_object_type
             ,a.child_object_id
             ,a.object_country
             ,a.object_region
             ,a.child_object_country
             ,a.child_object_region
	     ,a.category_id
             ,a.object_status
             ,a.child_object_status
             ,a.object_purpose
             ,a.child_object_purpose
             ,a.activity_type
             ,a.activity_id
             ,a.start_date
             ,a.end_date
             ,a.business_unit_id
	     ,nvl(f1.functional_currency_code,'USD')
HAVING      sum(nvl(f1.func_actual_delta,0)) <> 0
UNION ALL
SELECT  /*+ USE_NL(F1 G1 A) ordered */
            trunc(f1.last_update_date) creation_date
          ,a.source_code_id source_code_id
            ,a.object_type object_type
            ,a.object_id object_id
            ,a.child_object_type child_object_type
            ,a.child_object_id child_object_id
            ,0 lead_rank_id
            ,a.object_country
            ,a.object_region
            ,a.child_object_country
            ,a.child_object_region
	    ,a.category_id
            ,a.business_unit_id business_unit_id
            ,a.start_date
            ,a.end_date
            ,a.object_status object_status
            ,a.child_object_status child_object_status
            ,a.object_purpose object_purpose
            ,a.child_object_purpose child_object_purpose
            ,a.activity_type activity_type
            ,a.activity_id activity_id
	    ,0 conversion_rate
            ,nvl(f1.functional_currency_code,'USD') from_currency
            ,0 leads
            ,0 opportunities
            ,0 opportunity_amt
            ,0 opportunities_open
            ,0 quotes
            ,0 quotes_open
            ,0 orders_booked
            ,0 orders_booked_amt
            ,0 budget_requested
            ,0 budget_approved
          ,0  revenue_forecasted
          ,0 revenue_actual
          ,0 cost_forecasted
          ,sum(nvl(f1.func_actual_delta,0)) cost_actual
          ,0 responses_forecasted
          ,0 responses_positive
          ,0 customers_new
          ,0 customers_targeted
          ,0 registrations
          ,0 cancellations
          ,0 attendance
          ,0 OPPORTUNITY_AMT_S
          ,0 ORDERS_BOOKED_AMT_S
          ,0 REVENUE_FORECASTED_S
          ,0 REVENUE_ACTUAL_S
          ,0 COST_FORECASTED_S
          ,0 COST_ACTUAL_S
          ,0 BUDGET_REQUESTED_S
          ,0 BUDGET_APPROVED_S
          ,0 CONVERSION_RATE_S
  		  ,0 metric1
		  ,0 metric2
FROM          bim_i_source_codes         a
              ,ams_act_metric_hst            f1
              ,ams_metrics_all_b            g1
WHERE      f1.last_update_date between p_start_date and p_end_date
AND        f1.arc_act_metric_used_by   in ('CSCH','EVEO')
AND        f1.act_metric_used_by_id =a.child_object_id
AND        f1.ARC_ACT_METRIC_USED_BY = a.child_object_type
AND         a.object_type NOT IN ('RCAM')
AND        g1.metric_category              = 901
AND        g1.metric_id                    = f1.metric_id
AND        g1.metric_calculation_type         IN ('MANUAL','FUNCTION')
GROUP BY     trunc(f1.last_update_date)
           ,a.source_code_id
             ,a.object_type
             ,a.object_id
             ,a.child_object_type
             ,a.child_object_id
             ,a.object_country
             ,a.object_region
             ,a.child_object_country
             ,a.child_object_region
	     ,a.category_id
             ,a.object_status
             ,a.child_object_status
             ,a.object_purpose
             ,a.child_object_purpose
             ,a.activity_type
             ,a.activity_id
             ,a.start_date
             ,a.end_date
             ,a.business_unit_id
	     ,nvl(f1.functional_currency_code,'USD')
HAVING        sum(nvl(f1.func_actual_delta,0)) <> 0
--sbehera 15 jan 2004
--for campaign forecasted response
union all --forecasted response
SELECT      trunc(f3.last_update_date) transaction_create_date
            ,a.source_code_id source_code_id
            ,a.object_type object_type
            ,a.object_id object_id
            ,a.child_object_type child_object_type
            ,a.child_object_id child_object_id
            ,0 lead_rank_id
            ,a.object_country
            ,a.object_region
            ,a.child_object_country
            ,a.child_object_region
            ,a.category_id
            ,a.business_unit_id business_unit_id
            ,a.start_date
            ,a.end_date
            ,a.object_status object_status
            ,a.child_object_status child_object_status
            ,a.object_purpose object_purpose
            ,a.child_object_purpose child_object_purpose
            ,a.activity_type activity_type
            ,a.activity_id activity_id
            ,0 conversion_rate
            ,null from_currency
            ,0 leads
            ,0 opportunities
            ,0 opportunity_amt
            ,0 opportunities_open
            ,0 quotes
            ,0 quotes_open
            ,0 orders_booked
            ,0 orders_booked_amt
            ,0 budget_requested
            ,0 budget_approved
            ,0 revenue_forecasted
            ,0 revenue_actual
           ,0 cost_forecasted
           ,0 cost_actual
          ,sum(nvl(f3.func_forecasted_delta,0)) responses_forecasted
          ,0 responses_positive
          ,0 customers_targeted
          ,0 customers_new
          ,0 registrations
          ,0 cancellations
          ,0 attendance
          ,0 OPPORTUNITY_AMT_S
          ,0 ORDERS_BOOKED_AMT_S
          ,0 REVENUE_FORECASTED_S
          ,0 REVENUE_ACTUAL_S
          ,0 COST_FORECASTED_S
          ,0 COST_ACTUAL_S
          ,0 BUDGET_REQUESTED_S
          ,0 BUDGET_APPROVED_S
          ,0 conversion_rate_S
 		  ,0 metric1
		  ,0 metric2
FROM  ams_act_metric_hst               f3
     ,ams_metrics_all_b                g3
     ,bim_i_source_codes                a
           WHERE         f3.last_update_date between p_start_date and p_end_date
           AND           f3.arc_act_metric_used_by  = a.object_type
           AND           f3.act_metric_used_by_id = a.object_id
           AND           a.child_object_id =0
       --AND           a.object_type NOT IN ('RCAM')
  --     AND           a.object_type='CAMP' commented for camp.,event,one off
           AND           g3.metric_calculation_type     IN ('MANUAL','FUNCTION')
           AND           g3.metric_category             = 903
           AND           g3.metric_id                    = f3.metric_id
GROUP BY      trunc(f3.last_update_date)
            ,a.source_code_id
             ,a.object_type
             ,a.object_id
             ,a.child_object_type
             ,a.child_object_id
             ,a.object_country
             ,a.object_region
             ,a.child_object_country
             ,a.child_object_region
             ,a.category_id
             ,a.object_status
             ,a.child_object_status
             ,a.object_purpose
             ,a.child_object_purpose
             ,a.activity_type
             ,a.activity_id
             ,a.start_date
             ,a.end_date
             ,a.business_unit_id
HAVING       sum(nvl(f3.func_forecasted_delta,0)) <> 0
--for campaign schedule forecasted response
union all --forecasted campaign schedule response
SELECT      trunc(f3.last_update_date) transaction_create_date
            ,a.source_code_id source_code_id
            ,a.object_type object_type
            ,a.object_id object_id
            ,a.child_object_type child_object_type
            ,a.child_object_id child_object_id
            ,0 lead_rank_id
            ,a.object_country
            ,a.object_region
            ,a.child_object_country
            ,a.child_object_region
            ,a.category_id
            ,a.business_unit_id business_unit_id
            ,a.start_date
            ,a.end_date
            ,a.object_status object_status
            ,a.child_object_status child_object_status
            ,a.object_purpose object_purpose
            ,a.child_object_purpose child_object_purpose
            ,a.activity_type activity_type
            ,a.activity_id activity_id
            ,0 conversion_rate
            ,null from_currency
            ,0 leads
            ,0 opportunities
            ,0 opportunity_amt
            ,0 opportunities_open
            ,0 quotes
            ,0 quotes_open
            ,0 orders_booked
            ,0 orders_booked_amt
            ,0 budget_requested
            ,0 budget_approved
            ,0 revenue_forecasted
            ,0 revenue_actual
           ,0 cost_forecasted
           ,0 cost_actual
          ,sum(nvl(f3.func_forecasted_delta,0)) responses_forecasted
          ,0 responses_positive
          ,0 customers_targeted
          ,0 customers_new
          ,0 registrations
          ,0 cancellations
          ,0 attendance
          ,0 OPPORTUNITY_AMT_S
          ,0 ORDERS_BOOKED_AMT_S
          ,0 REVENUE_FORECASTED_S
          ,0 REVENUE_ACTUAL_S
          ,0 COST_FORECASTED_S
          ,0 COST_ACTUAL_S
          ,0 BUDGET_REQUESTED_S
          ,0 BUDGET_APPROVED_S
          ,0 conversion_rate_S
		  ,0 metric1
		  ,0 metric2
FROM  ams_act_metric_hst               f3
     ,ams_metrics_all_b                g3
     ,bim_i_source_codes                a
           WHERE         f3.last_update_date between p_start_date and p_end_date
            AND           f3.act_metric_used_by_id = a.child_object_id
           AND           f3.ARC_ACT_METRIC_USED_BY = a.child_object_type
       --AND           a.object_type NOT IN ('RCAM')
       AND           a.child_object_type in ('CSCH','EVEO')
           AND           g3.metric_calculation_type     IN ('MANUAL','FUNCTION')
           AND           g3.metric_category             = 903
           AND           g3.metric_id                    = f3.metric_id
GROUP BY      trunc(f3.last_update_date)
            ,a.source_code_id
             ,a.object_type
             ,a.object_id
             ,a.child_object_type
             ,a.child_object_id
             ,a.object_country
             ,a.object_region
             ,a.child_object_country
             ,a.child_object_region
             ,a.category_id
             ,a.object_status
             ,a.child_object_status
             ,a.object_purpose
             ,a.child_object_purpose
             ,a.activity_type
             ,a.activity_id
             ,a.start_date
             ,a.end_date
             ,a.business_unit_id
HAVING       sum(nvl(f3.func_forecasted_delta,0)) <> 0
union all --targeted audience
SELECT      trunc(p.creation_date) transaction_create_date
          ,a.source_code_id source_code_id
	    ,a.object_type object_type
            ,a.object_id object_id
            ,a.child_object_type child_object_type
            ,a.child_object_id child_object_id
            ,0 lead_rank_id
            ,a.object_country
            ,a.object_region
            ,a.child_object_country
            ,a.child_object_region
	    ,a.category_id
            ,a.business_unit_id business_unit_id
            ,a.start_date
            ,a.end_date
            ,a.object_status object_status
            ,a.child_object_status child_object_status
            ,a.object_purpose object_purpose
            ,a.child_object_purpose child_object_purpose
            ,a.activity_type activity_type
            ,a.activity_id activity_id
	    ,0 conversion_rate
	    ,null from_currency
            ,0 leads
            ,0 opportunities
            ,0 opportunity_amt
            ,0 opportunities_open
            ,0 quotes
            ,0 quotes_open
            ,0 orders_booked
            ,0 orders_booked_amt
            ,0 budget_requested
            ,0 budget_approved
	    ,0 revenue_forecasted
	    ,0 revenue_actual
            ,0 cost_forecasted
            ,0 cost_actual
            ,0 responses_forecasted
            ,0 responses_positive
            ,count(p.list_entry_id) customers_targeted
            ,0 customers_new
           ,0 registrations
           ,0 cancellations
          ,0 attendance
            ,0 OPPORTUNITY_AMT_S
          ,0 ORDERS_BOOKED_AMT_S
          ,0 REVENUE_FORECASTED_S
          ,0 REVENUE_ACTUAL_S
          ,0 COST_FORECASTED_S
          ,0 COST_ACTUAL_S
          ,0 BUDGET_REQUESTED_S
          ,0 BUDGET_APPROVED_S
          ,0 conversion_rate_S
		  ,0 metric1
		  ,0 metric2
FROM          ams_list_entries                p
              ,ams_act_lists                q
              ,bim_i_source_codes                a
WHERE         p.creation_date between p_start_date and p_end_date
AND           p.list_header_id = q.list_header_id
AND           q.list_used_by = a.child_object_type
AND           q.list_used_by_id = a.child_object_id
AND         a.object_type NOT IN ('RCAM')
AND           q.list_used_by in ('CSCH','EVEO')
AND           q.list_act_type = 'TARGET'
AND           p.enabled_flag='Y'
GROUP BY      trunc(p.creation_date)
           ,a.source_code_id
             ,a.object_type
             ,a.object_id
             ,a.child_object_type
             ,a.child_object_id
             ,a.object_country
             ,a.object_region
             ,a.child_object_country
             ,a.child_object_region
	     ,a.category_id
             ,a.object_status
             ,a.child_object_status
             ,a.object_purpose
             ,a.child_object_purpose
             ,a.activity_type
             ,a.activity_id
             ,a.start_date
             ,a.end_date
             ,a.business_unit_id
union all --targeted audience for schedules of type event
SELECT      trunc(p.creation_date) transaction_create_date
          ,a.source_code_id source_code_id
	    ,a.object_type object_type
            ,a.object_id object_id
            ,a.child_object_type child_object_type
            ,a.child_object_id child_object_id
            ,0 lead_rank_id
            ,a.object_country
            ,a.object_region
            ,a.child_object_country
            ,a.child_object_region
	    ,a.category_id
            ,a.business_unit_id business_unit_id
            ,a.start_date
            ,a.end_date
            ,a.object_status object_status
            ,a.child_object_status child_object_status
            ,a.object_purpose object_purpose
            ,a.child_object_purpose child_object_purpose
            ,a.activity_type activity_type
            ,a.activity_id activity_id
	    ,0 conversion_rate
	    ,null from_currency
            ,0 leads
            ,0 opportunities
            ,0 opportunity_amt
            ,0 opportunities_open
            ,0 quotes
            ,0 quotes_open
            ,0 orders_booked
            ,0 orders_booked_amt
            ,0 budget_requested
            ,0 budget_approved
	    ,0 revenue_forecasted
	    ,0 revenue_actual
            ,0 cost_forecasted
            ,0 cost_actual
            ,0 responses_forecasted
            ,0 responses_positive
            ,count(p.list_entry_id) customers_targeted
            ,0 customers_new
           ,0 registrations
           ,0 cancellations
          ,0 attendance
          ,0 OPPORTUNITY_AMT_S
          ,0 ORDERS_BOOKED_AMT_S
          ,0 REVENUE_FORECASTED_S
          ,0 REVENUE_ACTUAL_S
          ,0 COST_FORECASTED_S
          ,0 COST_ACTUAL_S
          ,0 BUDGET_REQUESTED_S
          ,0 BUDGET_APPROVED_S
          ,0 conversion_rate_S
		  ,0 metric1
		  ,0 metric2
FROM          ams_list_entries              p
              ,ams_act_lists                q
              ,bim_i_source_codes           a
	      ,ams_campaign_schedules_b sch
WHERE         p.creation_date between p_start_date and p_end_date
AND           p.list_header_id = q.list_header_id
AND           q.list_used_by     = 'EONE'
AND           q.list_act_type = 'TARGET'
AND           sch.schedule_id = a.child_object_id
AND           a.child_object_type = 'CSCH'
AND           sch.activity_type_code = 'EVENTS'
AND           q.list_used_by_id = sch.related_event_id
AND           a.object_type NOT IN ('RCAM')
AND           p.enabled_flag='Y'
GROUP BY      trunc(p.creation_date)
           ,a.source_code_id
             ,a.object_type
             ,a.object_id
             ,a.child_object_type
             ,a.child_object_id
             ,a.object_country
             ,a.object_region
             ,a.child_object_country
             ,a.child_object_region
	     ,a.category_id
             ,a.object_status
             ,a.child_object_status
             ,a.object_purpose
             ,a.child_object_purpose
             ,a.activity_type
             ,a.activity_id
             ,a.start_date
             ,a.end_date
             ,a.business_unit_id
union all   --budgets
 SELECT  /*+ USE_NL(A B S) */
           trunc(nvl(s.approval_date,s.last_update_date)) transaction_create_date
          ,a.source_code_id source_code_id
          ,a.object_type object_type
          ,a.object_id object_id
          ,a.child_object_type child_object_type
          ,a.child_object_id child_object_id
          ,0 lead_rank_id
          ,a.object_country
          ,a.object_region
          ,a.child_object_country
          ,a.child_object_region
	  ,a.category_id
          ,a.business_unit_id business_unit_id
          ,a.start_date
          ,a.end_date
          ,a.object_status object_status
          ,a.child_object_status child_object_status
          ,a.object_purpose object_purpose
          ,a.child_object_purpose child_object_purpose
          ,a.activity_type activity_type
          ,a.activity_id activity_id
	  ,0 conversion_rate_s
	  ,nvl(s.request_currency,'USD') from_currency
          ,0 leads
          ,0 opportunities
          ,0 opportunity_amt
          ,0 opportunities_open
          ,0 quotes
          ,0 quotes_open
          ,0 orders_booked
          ,0 orders_booked_amt
          ,0  budget_requested
          ,sum(nvl(s.approved_amount,0)) budget_approved
         ,0 revenue_forecasted
         ,0 revenue_actual
         ,0 cost_actual
         ,0 cost_forecasted
         ,0 responses_forecasted
         ,0 responses_positive
         ,0 customers_targeted
         ,0 customers_new
         ,0 registrations
         ,0 cancellations
         ,0 attendance
         ,0 OPPORTUNITY_AMT_S
          ,0 ORDERS_BOOKED_AMT_S
          ,0 REVENUE_FORECASTED_S
          ,0 REVENUE_ACTUAL_S
          ,0 COST_FORECASTED_S
          ,0 COST_ACTUAL_S
          ,0 BUDGET_REQUESTED_S
          ,0 BUDGET_APPROVED_S
          ,0 conversion_rate_s
		  ,0 metric1
		  ,0 metric2
        FROM    ozf_act_budgets             S
               ,bim_i_source_codes      A
               ,ams_source_codes            B
        WHERE  s.act_budget_used_by_id  = b.source_code_for_id
        AND    s.arc_act_budget_used_by = b.arc_source_code_for
        AND    b.source_code_id = a.source_code_id
		AND    a.object_type NOT IN ('RCAM')
        AND    s.budget_source_type      = 'FUND'
		AND	   s.parent_act_budget_id IS NULL
        AND s.status_code = 'APPROVED'
        AND    trunc(nvl(s.approval_date,s.last_update_date)) between p_start_date and p_end_date
        GROUP BY
           trunc(nvl(s.approval_date,s.last_update_date))
           ,a.source_code_id
           ,a.object_id
           ,a.object_type
           ,a.child_object_type
           ,a.child_object_id
           ,a.object_country
           ,a.child_object_country
           ,a.object_region
           ,a.child_object_region
	   ,a.category_id
           ,a.object_status
           ,a.child_object_status
           ,a.object_purpose
           ,a.child_object_purpose
           ,a.activity_type
           ,a.activity_id
           ,a.business_unit_id
           ,a.start_date
           ,a.end_date
	  ,nvl(s.request_currency,'USD')
HAVING      sum(nvl(s.approved_amount,0)) > 0
union all --budget2
SELECT  /*+ USE_NL(A B S) */
           trunc(a.start_date)   transaction_create_date
          ,a.source_code_id source_code_id
           ,a.object_type object_type
           ,a.object_id object_id
           ,a.child_object_type child_object_type
           ,a.child_object_id child_object_id
           ,0 lead_rank_id
           ,a.object_country
           ,a.object_region
           ,a.child_object_country
           ,a.child_object_region
	   ,a.category_id
           ,a.business_unit_id business_unit_id
           ,a.start_date
           ,a.end_date
           ,a.object_status object_status
           ,a.child_object_status child_object_status
           ,a.object_purpose object_purpose
           ,a.child_object_purpose child_object_purpose
           ,a.activity_type activity_type
           ,a.activity_id activity_id
	   ,0 conversion_rate
	   ,nvl(request_currency,'USD') from_currency
           ,0 leads
           ,0 opportunities
           ,0 opportunity_amt
           ,0 opportunities_open
           ,0 quotes
           ,0 quotes_open
           ,0 orders_booked
           ,0 orders_booked_amt
           ,0  budget_requested
           ,0-sum(nvl(s.approved_amount,0)) budget_approved
          ,0 revenue_forecasted
          ,0 revenue_actual
          ,0 cost_actual
          ,0 cost_forecasted
          ,0 responses_forecasted
          ,0 responses_positive
          ,0 customers_targeted
          ,0 customers_new
          ,0 registrations
          ,0 cancellations
          ,0 attendance
          ,0 OPPORTUNITY_AMT_S
          ,0 ORDERS_BOOKED_AMT_S
          ,0 REVENUE_FORECASTED_S
          ,0 REVENUE_ACTUAL_S
          ,0 COST_FORECASTED_S
          ,0 COST_ACTUAL_S
          ,0 BUDGET_REQUESTED_S
          ,0 BUDGET_APPROVED_S
          ,0 conversion_rate_s
		  ,0 metric1
		  ,0 metric2
FROM      ozf_act_budgets             S
          ,bim_i_source_codes      A
          ,ams_source_codes            B
WHERE     s.arc_act_budget_used_by = 'FUND'
AND		   s.parent_act_budget_id IS NULL
AND       s.budget_source_type = b.arc_source_code_for
AND       s.budget_source_id = b.source_code_for_id
AND       b.source_code_id = a.source_code_id
AND       a.object_type NOT IN ('RCAM')
AND       nvl(s.approval_date,s.last_update_date) between p_start_date and p_end_date
GROUP BY
trunc(nvl(s.approval_date,s.last_update_date))
           ,a.source_code_id
          ,a.object_id
          ,a.object_type
          ,a.child_object_type
          ,a.child_object_id
          ,a.object_country
          ,a.child_object_country
          ,a.object_region
          ,a.child_object_region
	  ,a.category_id
          ,a.object_status
          ,a.child_object_status
          ,a.object_purpose
          ,a.child_object_purpose
          ,a.activity_type
          ,a.activity_id
          ,a.business_unit_id
          ,a.start_date
          ,a.end_date
	  ,nvl(request_currency,'USD')
union all   --budget1 for campaign schedules and event schedules
 SELECT  /*+ USE_NL(A B S) */
           trunc(nvl(s.approval_date,s.last_update_date)) transaction_create_date
          ,a.source_code_id source_code_id
          ,a.object_type object_type
          ,a.object_id object_id
          ,a.child_object_type child_object_type
          ,a.child_object_id child_object_id
          ,0 lead_rank_id
          ,a.object_country
          ,a.object_region
          ,a.child_object_country
          ,a.child_object_region
	  ,a.category_id
          ,a.business_unit_id business_unit_id
          ,a.start_date
          ,a.end_date
          ,a.object_status object_status
          ,a.child_object_status child_object_status
          ,a.object_purpose object_purpose
          ,a.child_object_purpose child_object_purpose
          ,a.activity_type activity_type
          ,a.activity_id activity_id
	  ,0 conversion_rate_s
	  ,nvl(s.request_currency,'USD') from_currency
          ,0 leads
          ,0 opportunities
          ,0 opportunity_amt
          ,0 opportunities_open
          ,0 quotes
          ,0 quotes_open
          ,0 orders_booked
          ,0 orders_booked_amt
          ,0  budget_requested
          ,0 budget_approved
         ,0 revenue_forecasted
         ,0 revenue_actual
         ,0 cost_actual
         ,0 cost_forecasted
         ,0 responses_forecasted
         ,0 responses_positive
         ,0 customers_targeted
         ,0 customers_new
         ,0 registrations
         ,0 cancellations
         ,0 attendance
         ,0 OPPORTUNITY_AMT_S
          ,0 ORDERS_BOOKED_AMT_S
          ,0 REVENUE_FORECASTED_S
          ,0 REVENUE_ACTUAL_S
          ,0 COST_FORECASTED_S
          ,0 COST_ACTUAL_S
          ,0 BUDGET_REQUESTED_S
          ,0 BUDGET_APPROVED_S
          ,0 conversion_rate_s
		  ,sum(nvl(s.approved_amount,0)) metric1
		  ,0 metric2
        FROM    ozf_act_budgets             S
               ,bim_i_source_codes      A
               ,ams_source_codes            B
        WHERE  s.act_budget_used_by_id  = b.source_code_for_id
        AND    s.arc_act_budget_used_by = b.arc_source_code_for
        AND    b.source_code_id = a.source_code_id
		AND    a.child_object_type IN ('CSCH','EVEO')
        AND    s.budget_source_type      = 'FUND'
        AND s.status_code = 'APPROVED'
        AND    trunc(nvl(s.approval_date,s.last_update_date)) between p_start_date and p_end_date
        GROUP BY
           trunc(nvl(s.approval_date,s.last_update_date))
           ,a.source_code_id
           ,a.object_id
           ,a.object_type
           ,a.child_object_type
           ,a.child_object_id
           ,a.object_country
           ,a.child_object_country
           ,a.object_region
           ,a.child_object_region
	   ,a.category_id
           ,a.object_status
           ,a.child_object_status
           ,a.object_purpose
           ,a.child_object_purpose
           ,a.activity_type
           ,a.activity_id
           ,a.business_unit_id
           ,a.start_date
           ,a.end_date
	  ,nvl(s.request_currency,'USD')
HAVING      sum(nvl(s.approved_amount,0)) > 0
union all --budget2 for campaign schedules and Events
SELECT  /*+ USE_NL(A B S) */
           trunc(a.start_date)   transaction_create_date
          ,a.source_code_id source_code_id
           ,a.object_type object_type
           ,a.object_id object_id
           ,a.child_object_type child_object_type
           ,a.child_object_id child_object_id
           ,0 lead_rank_id
           ,a.object_country
           ,a.object_region
           ,a.child_object_country
           ,a.child_object_region
	   ,a.category_id
           ,a.business_unit_id business_unit_id
           ,a.start_date
           ,a.end_date
           ,a.object_status object_status
           ,a.child_object_status child_object_status
           ,a.object_purpose object_purpose
           ,a.child_object_purpose child_object_purpose
           ,a.activity_type activity_type
           ,a.activity_id activity_id
	   ,0 conversion_rate
	   ,nvl(request_currency,'USD') from_currency
           ,0 leads
           ,0 opportunities
           ,0 opportunity_amt
           ,0 opportunities_open
           ,0 quotes
           ,0 quotes_open
           ,0 orders_booked
           ,0 orders_booked_amt
           ,0  budget_requested
           ,0 budget_approved
          ,0 revenue_forecasted
          ,0 revenue_actual
          ,0 cost_actual
          ,0 cost_forecasted
          ,0 responses_forecasted
          ,0 responses_positive
          ,0 customers_targeted
          ,0 customers_new
          ,0 registrations
          ,0 cancellations
          ,0 attendance
          ,0 OPPORTUNITY_AMT_S
          ,0 ORDERS_BOOKED_AMT_S
          ,0 REVENUE_FORECASTED_S
          ,0 REVENUE_ACTUAL_S
          ,0 COST_FORECASTED_S
          ,0 COST_ACTUAL_S
          ,0 BUDGET_REQUESTED_S
          ,0 BUDGET_APPROVED_S
          ,0 conversion_rate_s
		  ,0-sum(nvl(s.approved_amount,0)) metric1
		  ,0 metric2
FROM      ozf_act_budgets             S
          ,bim_i_source_codes      A
          ,ams_source_codes            B
WHERE     s.arc_act_budget_used_by = 'FUND'
AND       s.budget_source_type = b.arc_source_code_for
AND       s.budget_source_id = b.source_code_for_id
AND       b.source_code_id = a.source_code_id
AND       a.child_object_type IN ('CSCH','EVEO')
AND       nvl(s.approval_date,s.last_update_date) between p_start_date and p_end_date
GROUP BY
trunc(nvl(s.approval_date,s.last_update_date))
           ,a.source_code_id
          ,a.object_id
          ,a.object_type
          ,a.child_object_type
          ,a.child_object_id
          ,a.object_country
          ,a.child_object_country
          ,a.object_region
          ,a.child_object_region
	  ,a.category_id
          ,a.object_status
          ,a.child_object_status
          ,a.object_purpose
          ,a.child_object_purpose
          ,a.activity_type
          ,a.activity_id
          ,a.business_unit_id
          ,a.start_date
          ,a.end_date
	  ,nvl(request_currency,'USD')
union all   --registration1
SELECT  /*+ USE_NL(X A) */
           trunc(X.last_reg_status_date)   transaction_create_date
          ,a.source_code_id source_code_id
           ,a.object_type object_type
           ,a.object_id object_id
           ,a.child_object_type child_object_type
           ,a.child_object_id child_object_id
           ,0 lead_rank_id
           ,a.object_country
           ,a.object_region
           ,a.child_object_country
           ,a.child_object_region
	   ,a.category_id
           ,a.business_unit_id business_unit_id
           ,a.start_date
           ,a.end_date
           ,a.object_status object_status
           ,a.child_object_status child_object_status
           ,a.object_purpose object_purpose
           ,a.child_object_purpose child_object_purpose
           ,a.activity_type activity_type
           ,a.activity_id activity_id
	   ,0 conversion_rate
	   ,null from_currency
           ,0 leads
           ,0 opportunities
           ,0 opportunity_amt
           ,0 opportunities_open
           ,0 quotes
           ,0 quotes_open
           ,0 orders_booked
           ,0 orders_booked_amt
           ,0  budget_requested
           ,0 budget_approved
           ,0 revenue_forecasted
           ,0 revenue_actual
           ,0 cost_actual
           ,0 cost_forecasted
           ,0 responses_forecasted
           ,0 responses_positive
           ,0 customers_targeted
           ,0 customers_new
           ,SUM(decode(X.system_status_code,'REGISTERED',1,0)) registrations
           ,SUM(decode(X.system_status_code,'CANCELLED',1,0)) cancellations
           ,SUM(decode(X.system_status_code,'REGISTERED',decode(attended_flag,'Y',1,0),0)) attendance
           ,0 OPPORTUNITY_AMT_S
          ,0 ORDERS_BOOKED_AMT_S
          ,0 REVENUE_FORECASTED_S
          ,0 REVENUE_ACTUAL_S
          ,0 COST_FORECASTED_S
          ,0 COST_ACTUAL_S
          ,0 BUDGET_REQUESTED_S
          ,0 BUDGET_APPROVED_S
          ,0 conversion_rate_S
		  ,0 metric1
		  ,0 metric2
FROM       ams_event_registrations X
          ,bim_i_source_codes      A
WHERE     trunc(X.last_reg_status_date) between p_start_date and p_end_date+0.99999
AND       X.event_offer_id     = A.child_object_id
AND       A.child_object_type ='EVEO'
AND         a.object_type NOT IN ('RCAM')
GROUP BY
trunc(X.last_reg_status_date)
           ,a.source_code_id
          ,a.object_id
          ,a.object_type
          ,a.child_object_type
          ,a.child_object_id
          ,a.object_country
          ,a.child_object_country
          ,a.object_region
          ,a.child_object_region
	  ,a.category_id
          ,a.object_status
          ,a.child_object_status
          ,a.object_purpose
          ,a.child_object_purpose
          ,a.activity_type
          ,a.activity_id
          ,a.business_unit_id
          ,a.start_date
          ,a.end_date
union all   --registration2
SELECT  /*+ USE_NL(X A) */
           trunc(X.last_reg_status_date)   transaction_create_date
          ,a.source_code_id source_code_id
           ,a.object_type object_type
           ,a.object_id object_id
           ,a.child_object_type child_object_type
           ,a.child_object_id child_object_id
           ,0 lead_rank_id
           ,a.object_country
           ,a.object_region
           ,a.child_object_country
           ,a.child_object_region
	   ,a.category_id
           ,a.business_unit_id business_unit_id
           ,a.start_date
           ,a.end_date
           ,a.object_status object_status
           ,a.child_object_status child_object_status
           ,a.object_purpose object_purpose
           ,a.child_object_purpose child_object_purpose
           ,a.activity_type activity_type
           ,a.activity_id activity_id
	   ,0 conversion_rate
	   ,null from_currency
           ,0 leads
           ,0 opportunities
           ,0 opportunity_amt
           ,0 opportunities_open
           ,0 quotes
           ,0 quotes_open
           ,0 orders_booked
           ,0 orders_booked_amt
           ,0  budget_requested
           ,0 budget_approved
           ,0 revenue_forecasted
           ,0 revenue_actual
           ,0 cost_actual
           ,0 cost_forecasted
           ,0 responses_forecasted
           ,0 responses_positive
           ,0 customers_targeted
           ,0 customers_new
           ,SUM(decode(X.system_status_code,'REGISTERED',1,0)) registrations
           ,SUM(decode(X.system_status_code,'CANCELLED',1,0)) cancellations
           ,SUM(decode(X.system_status_code,'REGISTERED',decode(attended_flag,'Y',1,0),0)) attendance
           ,0 OPPORTUNITY_AMT_S
          ,0 ORDERS_BOOKED_AMT_S
          ,0 REVENUE_FORECASTED_S
          ,0 REVENUE_ACTUAL_S
          ,0 COST_FORECASTED_S
          ,0 COST_ACTUAL_S
          ,0 BUDGET_REQUESTED_S
          ,0 BUDGET_APPROVED_S
          ,0 conversion_rate_S
		  ,0 metric1
		  ,0 metric2
FROM       ams_event_registrations X
          ,bim_i_source_codes      A
WHERE     trunc(X.last_reg_status_date) between p_start_date and p_end_date+0.99999
AND       X.event_offer_id     = A.object_id
AND       A.object_type ='EONE'
AND         a.object_type NOT IN ('RCAM')
GROUP BY
trunc(X.last_reg_status_date)
           ,a.source_code_id
          ,a.object_id
          ,a.object_type
          ,a.child_object_type
          ,a.child_object_id
          ,a.object_country
          ,a.child_object_country
          ,a.object_region
          ,a.child_object_region
	  ,a.category_id
          ,a.object_status
          ,a.child_object_status
          ,a.object_purpose
          ,a.child_object_purpose
          ,a.activity_type
          ,a.activity_id
          ,a.business_unit_id
          ,a.start_date
          ,a.end_date
   )
GROUP BY   transaction_create_date
           ,source_code_id
           ,object_type
           ,object_id
           ,child_object_type
           ,child_object_id
           ,lead_rank_id
           ,object_country
           ,object_region
           ,child_object_country
           ,child_object_region
	   ,category_id
           ,business_unit_id
           ,start_date
           ,end_date
           ,object_status
           ,child_object_status
           ,object_purpose
           ,child_object_purpose
           ,activity_type
           ,activity_id
	   ,conversion_rate
	   ,from_currency
           ,conversion_rate_s) inner;

     BIS_COLLECTION_UTILITIES.log('BIM_I_MARKETING_FACTS:Second insert BIM_I_MARKETING_FACTS_STG');
     ------------------------------NEW CODE----------------------
     INSERT INTO  bim_i_marketing_facts_STG
        (               --MKT_DAILY_TRANSACTION_ID  ,
	                 CREATION_DATE             ,
	                 LAST_UPDATE_DATE          ,
	                 CREATED_BY                ,
	                 LAST_UPDATED_BY           ,
	                 LAST_UPDATE_LOGIN         ,
	   	         TRANSACTION_CREATE_DATE   ,
	   	         LEAD_ID                   ,
	   	         METRIC_TYPE               ,
                         SOURCE_CODE_ID            ,
	                 OBJECT_TYPE               ,
	                 OBJECT_ID                 ,
	                 CHILD_OBJECT_TYPE         ,
	                 CHILD_OBJECT_ID           ,
	                 LEAD_RANK_ID              ,
	                 OBJECT_COUNTRY            ,
	                 OBJECT_REGION             ,
	                 CHILD_OBJECT_COUNTRY      ,
	                 CHILD_OBJECT_REGION       ,
			 CATEGORY_ID               ,
	                 BUSINESS_UNIT_ID          ,
	                 START_DATE                ,
	                 END_DATE                  ,
	                 OBJECT_STATUS             ,
	                 CHILD_OBJECT_STATUS       ,
	                 OBJECT_PURPOSE            ,
	                 CHILD_OBJECT_PURPOSE      ,
	                 ACTIVITY_TYPE             ,
	                 ACTIVITY_ID               ,
			 CONVERSION_RATE           ,
			 FROM_CURRENCY             ,
			 LEADS                     ,
	                 OPPORTUNITIES             ,
	                 OPPORTUNITY_AMT           ,
	                 OPPORTUNITIES_OPEN        ,
	                 ORDERS_BOOKED             ,
	                 ORDERS_BOOKED_AMT         ,
	                 REVENUE_FORECASTED        ,
	                 REVENUE_ACTUAL            ,
	                 COST_FORECASTED           ,
	                 COST_ACTUAL               ,
	                 BUDGET_APPROVED           ,
	                 BUDGET_REQUESTED          ,
	                 RESPONSES_FORECASTED      ,
	                 RESPONSES_POSITIVE        ,
	                 CUSTOMERS_NEW             ,
	                 REGISTRATIONS             ,
	                 CANCELLATIONS             ,
	                 ATTENDANCE                ,
                         OPPORTUNITY_AMT_S         ,
                         ORDERS_BOOKED_AMT_S       ,
                         REVENUE_FORECASTED_S      ,
                         REVENUE_ACTUAL_S          ,
                         COST_FORECASTED_S         ,
                         COST_ACTUAL_S             ,
                         BUDGET_REQUESTED_S        ,
                         BUDGET_APPROVED_S         ,
                         CONVERSION_RATE_S			,
						 metric1					,
						 metric2)
     	  (
     	   SELECT   /*+ use_hash(INNER) */
     	            sysdate                          creation_date
     	           ,sysdate                          last_update_date
     	           ,-1                               created_by
     	           ,-1                               last_updated_by
     	           ,-1                               last_update_login
	           ,inner.transaction_create_date  transaction_create_date
                   ,0                              lead_id
           	  ,inner.metric_type              metric_type
                   ,inner.source_code_id             source_code_id
                   ,inner.object_type                object_type
                   ,inner.object_id                  object_id
                   ,inner.child_object_type          child_object_type
                   ,inner.child_object_id            child_object_id
                   ,inner.lead_rank_id               lead_rank_id
     	           ,inner.object_country             object_country
                   ,inner.object_region              object_region
                   ,inner.child_object_country       child_object_country
                   ,inner.child_object_region        child_object_region
		   ,inner.category_id                category_id
                   ,inner.business_unit_id           business_unit_id
                   ,inner.start_date                 start_date
     	           ,inner.end_date                   end_date
     	           ,inner.object_status              object_status
                   ,inner.child_object_status        child_object_status
                   ,inner.object_purpose             object_purpose
                   ,inner.child_object_purpose       child_object_purpose
           	   ,inner.activity_type              activity_type
                   ,inner.activity_id                activity_id
		   ,inner.conversion_rate            conversion_rate
		   ,inner.from_currency              from_currency
                   ,inner.leads                      leads
                   ,inner.opportunities              opportunities
     	           ,inner.opportunity_amt            opportunity_amt
     	           ,inner.opportunities_open	     opportunities_open
     	           ,inner.orders_booked	             orders_booked
                   ,inner.orders_booked_amt	      orders_booked_amt
                   ,inner.revenue_forecasted         revenue_forecasted
                   ,inner.revenue_actual             revenue_actual
                   ,inner.cost_forecasted            cost_forecasted
                   ,inner.cost_actual                cost_actual
                   ,inner.budget_approved            budget_approved
                   ,inner.budget_requested           budget_requested
                   ,inner.responses_forecasted       responses_forecasted
                   ,inner.responses_positive         responses_positive
                   ,inner.customers_new              customers_new
                   ,inner.registrations              registrations
                   ,inner.cancellations              cancellations
                   ,inner.attendance                 attendance
                   ,inner.OPPORTUNITY_AMT_S          OPPORTUNITY_AMT_S
                   ,inner.ORDERS_BOOKED_AMT_S        ORDERS_BOOKED_AMT_S
                   ,inner.REVENUE_FORECASTED_S       REVENUE_FORECASTED_S
                   ,inner.REVENUE_ACTUAL_S           REVENUE_ACTUAL_S
                   ,inner.COST_FORECASTED_S          COST_FORECASTED_S
                   ,inner.COST_ACTUAL_S              COST_ACTUAL_S
                   ,inner.BUDGET_REQUESTED_S         BUDGET_REQUESTED_S
                   ,inner.BUDGET_APPROVED_S          BUDGET_APPROVED_S
                   ,inner.CONVERSION_RATE_S          CONVERSION_RATE_S
				   ,inner.metric1					metric1
				   ,inner.metric2					metric2
     FROM  (
     SELECT  /*+ USE_NL(F1 G1 A) ordered */
                 trunc(a.start_date) transaction_create_date
                 ,'FCOST' metric_type
                 ,a.source_code_id source_code_id
                 ,a.object_type object_type
                 ,a.object_id object_id
                 ,a.child_object_type child_object_type
                 ,a.child_object_id child_object_id
                 ,0 lead_rank_id
                 ,a.object_country
                 ,a.object_region
                 ,a.child_object_country
                 ,a.child_object_region
		 ,a.category_id category_id
                 ,a.business_unit_id business_unit_id
                 ,a.start_date
                 ,a.end_date
                 ,a.object_status object_status
                 ,a.child_object_status child_object_status
                 ,a.object_purpose object_purpose
                 ,a.child_object_purpose child_object_purpose
                 ,a.activity_type activity_type
                 ,a.activity_id activity_id
		 ,0 conversion_rate
                 ,nvl(f1.functional_currency_code,'USD') from_currency
                 ,0 leads
                 ,0 opportunities
                 ,0 opportunity_amt
                 ,0 opportunities_open
                 ,0 quotes
                 ,0 quotes_open
                 ,0 orders_booked
                 ,0 orders_booked_amt
                 ,0 budget_requested
                 ,0 budget_approved
               ,0  revenue_forecasted
               ,0 revenue_actual
               ,sum(nvl(f1.func_forecasted_delta,0)) cost_forecasted
               ,0 cost_actual
               ,0 responses_forecasted
               ,0 responses_positive
               ,0 customers_targeted
               ,0 customers_new
               ,0 registrations
               ,0 cancellations
               ,0 attendance
               ,0 OPPORTUNITY_AMT_S
               ,0 ORDERS_BOOKED_AMT_S
              ,0 REVENUE_FORECASTED_S
             ,0 REVENUE_ACTUAL_S
             ,0  COST_FORECASTED_S
            ,0 COST_ACTUAL_S
             ,0 BUDGET_REQUESTED_S
             ,0 BUDGET_APPROVED_S
             ,0 conversion_rate_s
			 ,0 metric1
			 ,0 metric2
     FROM          bim_i_source_codes            a
                   ,ams_act_metric_hst           f1
                   ,ams_metrics_all_b            g1
     WHERE
                f1.arc_act_metric_used_by       = a.object_type
     AND        f1.act_metric_used_by_id        = a.object_id
AND         a.object_type NOT IN ('RCAM')
     AND        a.child_object_id               = 0
     AND        g1.metric_category              = 901
     AND        g1.metric_id                    = f1.metric_id
     AND        g1.metric_calculation_type      IN ('MANUAL','FUNCTION')
     GROUP BY
                   a.source_code_id
                  ,a.object_type
                  ,a.object_id
                  ,a.child_object_type
                  ,a.child_object_id
                  ,a.object_country
                  ,a.object_region
                  ,a.child_object_country
                  ,a.child_object_region
		  ,a.category_id
                  ,a.object_status
                  ,a.child_object_status
                  ,a.object_purpose
                  ,a.child_object_purpose
                  ,a.activity_type
                  ,a.activity_id
                  ,a.start_date
                  ,a.end_date
                  ,a.business_unit_id
		  ,nvl(f1.functional_currency_code,'USD')
     HAVING        sum(nvl(f1.func_forecasted_delta,0)) <> 0
     UNION ALL
SELECT  /*+ USE_NL(F1 G1 A) ordered */
                   trunc(a.start_date) transaction_create_date
		   ,'FCOST' metric_type
                 ,a.source_code_id source_code_id
                 ,a.object_type object_type
                 ,a.object_id object_id
                 ,a.child_object_type child_object_type
                 ,a.child_object_id child_object_id
                 ,0 lead_rank_id
                 ,a.object_country
                 ,a.object_region
                 ,a.child_object_country
                 ,a.child_object_region
		 ,category_id category_id
                 ,a.business_unit_id business_unit_id
                 ,a.start_date
                 ,a.end_date
                 ,a.object_status object_status
                 ,a.child_object_status child_object_status
                 ,a.object_purpose object_purpose
                 ,a.child_object_purpose child_object_purpose
                 ,a.activity_type activity_type
                 ,a.activity_id activity_id
		 ,0 conversion_rate
                 ,nvl(f1.functional_currency_code,'USD') from_currency
                 ,0 leads
                 ,0 opportunities
                 ,0 opportunity_amt
                 ,0 opportunities_open
                 ,0 quotes
                 ,0 quotes_open
                 ,0 orders_booked
                 ,0 orders_booked_amt
                 ,0 budget_requested
                 ,0 budget_approved
               ,0  revenue_forecasted
               ,0 revenue_actual
               ,sum(nvl(f1.func_forecasted_delta,0)) cost_forecasted
               ,0 cost_actual
               ,0 responses_forecasted
               ,0 responses_positive
               ,0 customers_targeted
               ,0 customers_new
               ,0 registrations
               ,0 cancellations
               ,0 attendance
                ,0 OPPORTUNITY_AMT_S
               ,0 ORDERS_BOOKED_AMT_S
              ,0 REVENUE_FORECASTED_S
             ,0 REVENUE_ACTUAL_S
             ,0  COST_FORECASTED_S
            ,0 COST_ACTUAL_S
             ,0 BUDGET_REQUESTED_S
             ,0 BUDGET_APPROVED_S
             ,0 conversion_rate_s
			 ,0 metric1
			 ,0 metric2
     FROM          bim_i_source_codes            a
                   ,ams_act_metric_hst           f1
                   ,ams_metrics_all_b            g1
     WHERE
                f1.arc_act_metric_used_by     in ('CSCH','EVEO')
     AND        f1.act_metric_used_by_id        = a.child_object_id
AND         a.object_type NOT IN ('RCAM')
     AND        f1.ARC_ACT_METRIC_USED_BY = a.child_object_type
     AND        g1.metric_category              = 901
     AND        g1.metric_id                    = f1.metric_id
     AND        g1.metric_calculation_type      IN ('MANUAL','FUNCTION')
     GROUP BY
                   a.source_code_id
                  ,a.object_type
                  ,a.object_id
                  ,a.child_object_type
                  ,a.child_object_id
                  ,a.object_country
                  ,a.object_region
                  ,a.child_object_country
                  ,a.child_object_region
		  ,a.category_id
                  ,a.object_status
                  ,a.child_object_status
                  ,a.object_purpose
                  ,a.child_object_purpose
                  ,a.activity_type
                  ,a.activity_id
                  ,a.start_date
                  ,a.end_date
                  ,a.business_unit_id
		  ,nvl(f1.functional_currency_code,'USD')
     HAVING       sum(nvl(f1.func_forecasted_delta,0)) <> 0
UNION ALL
     SELECT  /*+ USE_NL(F1 G1 A) ordered */
                 trunc(a.start_date) transaction_create_date
		  ,'FREV' metric_type
                 ,a.source_code_id source_code_id
                 ,a.object_type object_type
                 ,a.object_id object_id
                 ,a.child_object_type child_object_type
                 ,a.child_object_id child_object_id
                 ,0 lead_rank_id
                 ,a.object_country
                 ,a.object_region
                 ,a.child_object_country
                 ,a.child_object_region
		 ,a.category_id
                 ,a.business_unit_id business_unit_id
                 ,a.start_date
                 ,a.end_date
                 ,a.object_status object_status
                 ,a.child_object_status child_object_status
                 ,a.object_purpose object_purpose
                 ,a.child_object_purpose child_object_purpose
                 ,a.activity_type activity_type
                 ,a.activity_id activity_id
		 ,0 conversion_rate
                 ,nvl(f1.functional_currency_code,'USD') from_currency
                 ,0 leads
                 ,0 opportunities
                 ,0 opportunity_amt
                 ,0 opportunities_open
                 ,0 quotes
                 ,0 quotes_open
                 ,0 orders_booked
                 ,0 orders_booked_amt
                 ,0 budget_requested
                 ,0 budget_approved
               ,sum(nvl(f1.func_forecasted_delta,0))  revenue_forecasted
               ,0 revenue_actual
               ,0 cost_forecasted
               ,0 cost_actual
               ,0 responses_forecasted
               ,0 responses_positive
               ,0 customers_targeted
               ,0 customers_new
               ,0 registrations
               ,0 cancellations
               ,0 attendance
               ,0 OPPORTUNITY_AMT_S
               ,0 ORDERS_BOOKED_AMT_S
               ,0 REVENUE_FORECASTED_S
               ,0 REVENUE_ACTUAL_S
               ,0 COST_FORECASTED_S
               ,0 COST_ACTUAL_S
               ,0 BUDGET_REQUESTED_S
               ,0 BUDGET_APPROVED_S
               ,0 conversion_rate_s
			   ,0 metric1
			   ,0 metric2
     FROM          bim_i_source_codes            a
                   ,ams_act_metric_hst           f1
                   ,ams_metrics_all_b            g1
     WHERE      f1.arc_act_metric_used_by       = a.object_type
     AND        f1.act_metric_used_by_id        = a.object_id
     AND         a.object_type NOT IN ('RCAM')
     AND        a.child_object_id               = 0
     AND        g1.metric_category              = 902
     AND        g1.metric_id                    = f1.metric_id
     AND        g1.metric_calculation_type      IN ('MANUAL','FUNCTION')
     GROUP BY
                   a.source_code_id
                  ,a.object_type
                  ,a.object_id
                  ,a.child_object_type
                  ,a.child_object_id
                  ,a.object_country
                  ,a.object_region
                  ,a.child_object_country
                  ,a.child_object_region
		  ,a.category_id
                  ,a.object_status
                  ,a.child_object_status
                  ,a.object_purpose
                  ,a.child_object_purpose
                  ,a.activity_type
                  ,a.activity_id
                  ,a.start_date
                  ,a.end_date
                  ,a.business_unit_id
	          ,nvl(f1.functional_currency_code,'USD')
     HAVING        sum(nvl(f1.func_forecasted_delta,0)) <> 0
     UNION ALL
     SELECT  /*+ USE_NL(F1 G1 A) ordered */
                 trunc(a.start_date) transaction_create_date
		  ,'FREV' metric_type
                 ,a.source_code_id source_code_id
                 ,a.object_type object_type
                 ,a.object_id object_id
                 ,a.child_object_type child_object_type
                 ,a.child_object_id child_object_id
                 ,0 lead_rank_id
                 ,a.object_country
                 ,a.object_region
                 ,a.child_object_country
                 ,a.child_object_region
		 ,a.category_id
                 ,a.business_unit_id business_unit_id
                 ,a.start_date
                 ,a.end_date
                 ,a.object_status object_status
                 ,a.child_object_status child_object_status
                 ,a.object_purpose object_purpose
                 ,a.child_object_purpose child_object_purpose
                 ,a.activity_type activity_type
                 ,a.activity_id activity_id
		 ,0 conversion_rate
                 ,nvl(f1.functional_currency_code,'USD') from_currency
                 ,0 leads
                 ,0 opportunities
                 ,0 opportunity_amt
                 ,0 opportunities_open
                 ,0 quotes
                 ,0 quotes_open
                 ,0 orders_booked
                 ,0 orders_booked_amt
                 ,0 budget_requested
                 ,0 budget_approved
               ,sum(nvl(f1.func_forecasted_delta,0))  revenue_forecasted
               ,0 revenue_actual
               ,0 cost_forecasted
               ,0 cost_actual
               ,0 responses_forecasted
               ,0 responses_positive
               ,0 customers_targeted
               ,0 customers_new
               ,0 registrations
               ,0 cancellations
               ,0 attendance
               ,0 OPPORTUNITY_AMT_S
               ,0 ORDERS_BOOKED_AMT_S
              ,0 REVENUE_FORECASTED_S
             ,0 REVENUE_ACTUAL_S
             ,0 COST_FORECASTED_S
            ,0 COST_ACTUAL_S
             ,0 BUDGET_REQUESTED_S
             ,0 BUDGET_APPROVED_S
             ,0 conversion_rate_s
			 ,0 metric1
			 ,0 metric2
     FROM          bim_i_source_codes            a
                   ,ams_act_metric_hst           f1
                   ,ams_metrics_all_b            g1
     WHERE
                f1.arc_act_metric_used_by     in ('CSCH','EVEO')
     AND        f1.act_metric_used_by_id        = a.child_object_id
     AND        f1.ARC_ACT_METRIC_USED_BY = a.child_object_type
AND         a.object_type NOT IN ('RCAM')
     AND        g1.metric_category              = 902
     AND        g1.metric_id                    = f1.metric_id
     AND        g1.metric_calculation_type      IN ('MANUAL','FUNCTION')
     GROUP BY
                   a.source_code_id
                  ,a.object_type
                  ,a.object_id
                  ,a.child_object_type
                  ,a.child_object_id
                  ,a.object_country
                  ,a.object_region
                  ,a.child_object_country
                  ,a.child_object_region
		  ,a.category_id
                  ,a.object_status
                  ,a.child_object_status
                  ,a.object_purpose
                  ,a.child_object_purpose
                  ,a.activity_type
                  ,a.activity_id
                  ,a.start_date
                  ,a.end_date
                  ,a.business_unit_id
                  ,nvl(f1.functional_currency_code,'USD')
     HAVING        sum(nvl(f1.func_forecasted_delta,0)) <> 0
                   ) inner
WHERE NOT EXISTS
(SELECT source_code_id from bim_i_marketing_facts facts
WHERE facts.object_id = inner.object_id
AND facts.object_type = inner.object_type
AND facts.source_code_id = inner.source_code_id
AND facts.metric_type = inner.metric_type
AND facts.child_object_type = inner.child_object_type
AND facts.child_object_id = inner.child_object_id)
);
     	 /* WHEN MATCHED THEN UPDATE  SET
     	     facts.last_update_date = changes.last_update_date
     	  WHEN NOT MATCHED THEN INSERT
     		(
     	       facts.creation_date
                   ,facts.last_update_date
                   ,facts.created_by
                   ,facts.last_updated_by
                   ,facts.last_update_login
                   ,facts.metric_type
                   ,facts.lead_id
           	   ,facts.transaction_create_date
                   ,facts.source_code_id
                   ,facts.object_type
                   ,facts.object_id
                   ,facts.child_object_type
                   ,facts.child_object_id
                   ,facts.lead_rank_id
     	          ,facts.object_country
                   ,facts.object_region
                   ,facts.child_object_country
                   ,facts.child_object_region
		   ,facts.category_id
                   ,facts.business_unit_id
                   ,facts.start_date
     	           ,facts.end_date
     	           ,facts.object_status
                   ,facts.child_object_status
                   ,facts.object_purpose
                   ,facts.child_object_purpose
           	   ,facts.activity_type
                   ,facts.activity_id
		   ,facts.conversion_rate
		   ,facts.from_currency
                   ,facts.leads
                   ,facts.opportunities
     	           ,facts.opportunity_amt
     	           ,facts.opportunities_open
     	           ,facts.orders_booked
                   ,facts.orders_booked_amt
                   ,facts.revenue_forecasted
                   ,facts.revenue_actual
                   ,facts.cost_forecasted
                   ,facts.cost_actual
                   ,facts.budget_approved
                   ,facts.budget_requested
                   ,facts.responses_forecasted
                   ,facts.responses_positive
                   ,facts.customers_new
                   ,facts.registrations
                   ,facts.cancellations
                   ,facts.attendance
                   ,facts.OPPORTUNITY_AMT_S          OPPORTUNITY_AMT_S
                   ,facts.ORDERS_BOOKED_AMT_S        ORDERS_BOOKED_AMT_S
                   ,facts.REVENUE_FORECASTED_S       REVENUE_FORECASTED_S
                   ,facts.REVENUE_ACTUAL_S           REVENUE_ACTUAL_S
                   ,facts.COST_FORECASTED_S          COST_FORECASTED_S
                   ,facts.COST_ACTUAL_S              COST_ACTUAL_S
                   ,facts.BUDGET_REQUESTED_S         BUDGET_REQUESTED_S
                   ,facts.BUDGET_APPROVED_S          BUDGET_APPROVED_S
                   ,facts.CONVERSION_RATE_S          CONVERSION_RATE_S
     		 )
     	   VALUES
     		 (
     	       changes.creation_date
                   ,changes.last_update_date
                   ,changes.created_by
                   ,changes.last_updated_by
                   ,changes.last_update_login
                   ,changes.metric_type
                   ,changes.lead_id
           	   ,changes.transaction_create_date
                   ,changes.source_code_id
                   ,changes.object_type
                   ,changes.object_id
                   ,changes.child_object_type
                   ,changes.child_object_id
                   ,changes.lead_rank_id
     	            ,changes.object_country
                   ,changes.object_region
                   ,changes.child_object_country
                   ,changes.child_object_region
		   ,nvl(changes.category_id,-1)
                   ,changes.business_unit_id
                   ,changes.start_date
     	           ,changes.end_date
     	           ,changes.object_status
                   ,changes.child_object_status
                   ,changes.object_purpose
                   ,changes.child_object_purpose
           	   ,changes.activity_type
                   ,changes.activity_id
		   ,changes.conversion_rate
		   ,changes.from_currency
                   ,changes.leads
                   ,changes.opportunities
     	           ,changes.opportunity_amt
     	           ,changes.opportunities_open
     	           ,changes.orders_booked
                   ,changes.orders_booked_amt
                   ,changes.revenue_forecasted
                   ,changes.revenue_actual
                   ,changes.cost_forecasted
                   ,changes.cost_actual
                   ,changes.budget_approved
                   ,changes.budget_requested
                   ,changes.responses_forecasted
                   ,changes.responses_positive
                   ,changes.customers_new
                   ,changes.registrations
                   ,changes.cancellations
                   ,changes.attendance
                   ,changes.OPPORTUNITY_AMT_S          OPPORTUNITY_AMT_S
                   ,changes.ORDERS_BOOKED_AMT_S        ORDERS_BOOKED_AMT_S
                   ,changes.REVENUE_FORECASTED_S       REVENUE_FORECASTED_S
                   ,changes.REVENUE_ACTUAL_S           REVENUE_ACTUAL_S
                   ,changes.COST_FORECASTED_S          COST_FORECASTED_S
                   ,changes.COST_ACTUAL_S              COST_ACTUAL_S
                   ,changes.BUDGET_REQUESTED_S         BUDGET_REQUESTED_S
                   ,changes.BUDGET_APPROVED_S          BUDGET_APPROVED_S
                   ,changes.CONVERSION_RATE_S          CONVERSION_RATE_S
		  ); */

	-----------------------NEW CODE------------------------------

           --dbms_output.put_line('inserted :'||SQL%ROWCOUNT);
     COMMIT;

 BIS_COLLECTION_UTILITIES.log('BIM_I_MARKETING_FACTS:Third insert BIM_I_MARKETING_FACTS_STG');
 bis_collection_utilities.get_last_refresh_dates('BIM_SOURCE_CODE' ,l_conc_start_date,l_conc_end_date,l_sc_s_date,l_sc_e_date);

 INSERT INTO BIM_I_MARKETING_FACTS_STG CDF      (
              --MKT_DAILY_TRANSACTION_ID  ,
              CREATION_DATE             ,
              LAST_UPDATE_DATE          ,
              CREATED_BY                ,
              LAST_UPDATED_BY           ,
              LAST_UPDATE_LOGIN         ,
              TRANSACTION_CREATE_DATE   ,
              SOURCE_CODE_ID            ,
              OBJECT_TYPE               ,
              OBJECT_ID                 ,
              CHILD_OBJECT_TYPE         ,
              CHILD_OBJECT_ID           ,
              LEAD_RANK_ID              ,
              OBJECT_COUNTRY            ,
              OBJECT_REGION             ,
              CHILD_OBJECT_COUNTRY      ,
              CHILD_OBJECT_REGION       ,
	      CATEGORY_ID               ,
              BUSINESS_UNIT_ID          ,
              START_DATE                ,
              END_DATE                  ,
              OBJECT_STATUS             ,
              CHILD_OBJECT_STATUS       ,
              OBJECT_PURPOSE            ,
              CHILD_OBJECT_PURPOSE      ,
              ACTIVITY_TYPE             ,
              ACTIVITY_ID               ,
              from_currency             ,
	      LEADS,
              OPPORTUNITIES             ,
              OPPORTUNITY_AMT           ,
              OPPORTUNITIES_OPEN        ,
              ORDERS_BOOKED             ,
              ORDERS_BOOKED_AMT         ,
              REVENUE_FORECASTED        ,
              REVENUE_ACTUAL            ,
              COST_FORECASTED           ,
              COST_ACTUAL               ,
              BUDGET_APPROVED           ,
              BUDGET_REQUESTED          ,
              RESPONSES_FORECASTED      ,
              RESPONSES_POSITIVE        ,
              CUSTOMERS_NEW             ,
              REGISTRATIONS             ,
              CANCELLATIONS             ,
              ATTENDANCE                ,
              OPPORTUNITY_AMT_S         ,
              ORDERS_BOOKED_AMT_S       ,
              REVENUE_FORECASTED_S      ,
              REVENUE_ACTUAL_S          ,
              COST_FORECASTED_S         ,
              COST_ACTUAL_S             ,
              BUDGET_REQUESTED_S        ,
              BUDGET_APPROVED_S         ,
              CONVERSION_RATE_S			,
			  METRIC1					,
			  METRIC2
)
SELECT        sysdate
              ,sysdate
              ,-1
              ,-1
              ,-1
              ,TRUNC(a.start_date)
              ,a.source_code_id
              ,a.object_type
              ,a.object_id
              ,a.child_object_type
              ,a.child_object_id
              ,0
              ,a.object_country
              ,a.object_region
              ,a.child_object_country
              ,a.child_object_region
	      ,nvl(a.category_id,-1)
              ,a.business_unit_id
              ,a.start_date
              ,a.end_date
              ,a.object_status
              ,a.child_object_status
              ,a.object_purpose
              ,a.child_object_purpose
              ,a.activity_type
              ,a.activity_id
	      ,null
              ,0
              ,0
              ,0
              ,0
              ,0
              ,0
              ,0
              ,0
              ,0
              ,0
              ,0
              ,0
              ,0
              ,0
              ,0
              ,0
              ,0
              ,0
              ,0
              ,0
              ,0
              ,0
              ,0
              ,0
              ,0
              ,0
              ,0
			  ,0
			  ,0
FROM  bim_i_source_codes a
where a.child_object_id =0
and a.obj_last_update_date >l_sc_s_date
and  not exists (
select  b.object_id,b.object_type from
bim_i_marketing_facts b
where b.child_object_id =0
and a.object_id = b.object_id
AND         a.object_type NOT IN ('RCAM')
and a.object_type = b.object_type);

 BIS_COLLECTION_UTILITIES.log('BIM_I_MARKETING_FACTS:Inserting into BIM_I_MKT_RATES');
 --insert into bim_i_mkt_rates
INSERT
INTO BIM_I_MKT_RATES MRT(tc_code,
                         trx_date,
			 prim_conversion_rate,
			 sec_conversion_rate)
SELECT from_currency,
       transaction_create_date,
       FII_CURRENCY.get_rate(from_currency,l_global_currency_code,transaction_create_date,l_pgc_rate_type),
       FII_CURRENCY.get_rate(from_currency,l_secondary_currency_code,transaction_create_date,l_sgc_rate_type)
FROM (select distinct from_currency from_currency,
                      transaction_create_date transaction_create_date
       from bim_i_marketing_facts_stg);

     l_check_missing_rate := Check_Missing_Rates (p_start_date);
     if (l_check_missing_rate = -1) then
     DELETE from bim_i_marketing_facts_stg  where transaction_create_date>= p_start_date;
	 commit;
         x_return_status := FND_API.G_RET_STS_ERROR;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    end if;
     BIS_COLLECTION_UTILITIES.log('BIM_I_MARKETING_FACTS:Sub Load:after calling checking_missing_rates');
 BIS_COLLECTION_UTILITIES.log('BIM_I_MARKETING_FACTS:Final insert into bim_i_marketing_facts');
 INSERT
      INTO BIM_I_MARKETING_FACTS CDF      (
              --MKT_DAILY_TRANSACTION_ID  ,
              CREATION_DATE             ,
              LAST_UPDATE_DATE          ,
              CREATED_BY                ,
              LAST_UPDATED_BY           ,
              LAST_UPDATE_LOGIN         ,
	      TRANSACTION_CREATE_DATE   ,
	      LEAD_ID                   ,
	      METRIC_TYPE               ,
              SOURCE_CODE_ID            ,
              OBJECT_TYPE               ,
              OBJECT_ID                 ,
              CHILD_OBJECT_TYPE         ,
              CHILD_OBJECT_ID           ,
              LEAD_RANK_ID              ,
              OBJECT_COUNTRY            ,
              OBJECT_REGION             ,
              CHILD_OBJECT_COUNTRY      ,
              CHILD_OBJECT_REGION       ,
              CATEGORY_ID               ,
	      BUSINESS_UNIT_ID          ,
              START_DATE                ,
              END_DATE                  ,
              OBJECT_STATUS             ,
              CHILD_OBJECT_STATUS       ,
              OBJECT_PURPOSE            ,
              CHILD_OBJECT_PURPOSE      ,
              ACTIVITY_TYPE             ,
              ACTIVITY_ID               ,
	      CONVERSION_RATE           ,
	      FROM_CURRENCY             ,
              LEADS                     ,
              OPPORTUNITIES             ,
              OPPORTUNITY_AMT           ,
              OPPORTUNITIES_OPEN        ,
              ORDERS_BOOKED             ,
              ORDERS_BOOKED_AMT         ,
              REVENUE_FORECASTED        ,
              REVENUE_ACTUAL            ,
              COST_FORECASTED           ,
              COST_ACTUAL               ,
              BUDGET_APPROVED           ,
              BUDGET_REQUESTED          ,
              RESPONSES_FORECASTED      ,
              RESPONSES_POSITIVE        ,
              CUSTOMERS_TARGETED        ,
              CUSTOMERS_NEW             ,
              REGISTRATIONS             ,
              CANCELLATIONS             ,
              ATTENDANCE                ,
              OPPORTUNITY_AMT_S         ,
              ORDERS_BOOKED_AMT_S       ,
              REVENUE_FORECASTED_S      ,
              REVENUE_ACTUAL_S          ,
              COST_FORECASTED_S         ,
              COST_ACTUAL_S             ,
              BUDGET_REQUESTED_S        ,
              BUDGET_APPROVED_S         ,
              CONVERSION_RATE_S         ,
			  metric1		,
			  metric2
	      )
SELECT  /*+ parallel */
	     --  BIM_I_MARKETING_FACTS_s.nextval ,
              sysdate
              ,sysdate
              ,-1
              ,-1
              ,-1
              ,transaction_create_date
	      ,lead_id
	      ,metric_type
              ,source_code_id
              ,object_type
              ,object_id
              ,child_object_type
              ,child_object_id
              ,lead_rank_id
              ,object_country
              ,object_region
              ,child_object_country
              ,child_object_region
	      ,nvl(category_id,-1)
              ,business_unit_id
              ,start_date
              ,end_date
              ,object_status
              ,child_object_status
              ,object_purpose
              ,child_object_purpose
              ,activity_type
              ,activity_id
	      ,conversion_rate
              ,from_currency
              ,leads
              ,opportunities
              ,opportunity_amt*rt.prim_conversion_rate
              ,opportunities_open
              ,orders_booked
              ,orders_booked_amt*rt.prim_conversion_rate
              ,revenue_forecasted*rt.prim_conversion_rate
              ,revenue_actual*rt.prim_conversion_rate
              ,cost_forecasted*rt.prim_conversion_rate
              ,cost_actual*rt.prim_conversion_rate
              ,budget_approved*rt.prim_conversion_rate
              ,budget_requested*rt.prim_conversion_rate
              ,responses_forecasted
              ,responses_positive
              ,customers_targeted
              ,customers_new
              ,registrations
              ,cancellations
              ,attendance
              ,OPPORTUNITY_AMT*sec_conversion_rate
              ,ORDERS_BOOKED_AMT*sec_conversion_rate
              ,REVENUE_FORECASTED*sec_conversion_rate
              ,REVENUE_ACTUAL*sec_conversion_rate
              ,COST_FORECASTED*sec_conversion_rate
              ,COST_ACTUAL*sec_conversion_rate
              ,BUDGET_REQUESTED*sec_conversion_rate
              ,BUDGET_APPROVED*sec_conversion_rate
              ,CONVERSION_RATE_S
			  ,metric1*rt.prim_conversion_rate
			  ,metric1*sec_conversion_rate
 FROM bim_i_marketing_facts_stg a, bim_i_mkt_rates rt
where a.from_currency = rt.tc_code(+)
and a.transaction_create_date= rt.trx_date(+);

--Insert schedules
 INSERT INTO BIM_I_MARKETING_FACTS CDF      (
              --MKT_DAILY_TRANSACTION_ID  ,
              CREATION_DATE             ,
              LAST_UPDATE_DATE          ,
              CREATED_BY                ,
              LAST_UPDATED_BY           ,
              LAST_UPDATE_LOGIN         ,
              TRANSACTION_CREATE_DATE   ,
              SOURCE_CODE_ID            ,
              OBJECT_TYPE               ,
              OBJECT_ID                 ,
              CHILD_OBJECT_TYPE         ,
              CHILD_OBJECT_ID           ,
              LEAD_RANK_ID              ,
              OBJECT_COUNTRY            ,
              OBJECT_REGION             ,
              CHILD_OBJECT_COUNTRY      ,
              CHILD_OBJECT_REGION       ,
	      CATEGORY_ID               ,
              BUSINESS_UNIT_ID          ,
              START_DATE                ,
              END_DATE                  ,
              OBJECT_STATUS             ,
              CHILD_OBJECT_STATUS       ,
              OBJECT_PURPOSE            ,
              CHILD_OBJECT_PURPOSE      ,
              ACTIVITY_TYPE             ,
              ACTIVITY_ID               ,
              LEADS,
              OPPORTUNITIES             ,
              OPPORTUNITY_AMT           ,
              OPPORTUNITIES_OPEN        ,
              ORDERS_BOOKED             ,
              ORDERS_BOOKED_AMT         ,
              REVENUE_FORECASTED        ,
              REVENUE_ACTUAL            ,
              COST_FORECASTED           ,
              COST_ACTUAL               ,
              BUDGET_APPROVED           ,
              BUDGET_REQUESTED          ,
              RESPONSES_FORECASTED      ,
              RESPONSES_POSITIVE        ,
              CUSTOMERS_NEW             ,
              REGISTRATIONS             ,
              CANCELLATIONS             ,
              ATTENDANCE                ,
              OPPORTUNITY_AMT_S         ,
              ORDERS_BOOKED_AMT_S       ,
              REVENUE_FORECASTED_S      ,
              REVENUE_ACTUAL_S          ,
              COST_FORECASTED_S         ,
              COST_ACTUAL_S             ,
              BUDGET_REQUESTED_S        ,
              BUDGET_APPROVED_S         ,
              CONVERSION_RATE_S			,
			  metric1		,
			  metric2)
SELECT        sysdate
              ,sysdate
              ,-1
              ,-1
              ,-1
              ,TRUNC(a.start_date)
              ,a.source_code_id
              ,a.object_type
              ,a.object_id
              ,a.child_object_type
              ,a.child_object_id
              ,0
              ,a.object_country
              ,a.object_region
              ,a.child_object_country
              ,a.child_object_region
	      ,nvl(a.category_id,-1)
              ,a.business_unit_id
              ,a.start_date
              ,a.end_date
              ,a.object_status
              ,a.child_object_status
              ,a.object_purpose
              ,a.child_object_purpose
              ,a.activity_type
              ,a.activity_id
              ,0
              ,0
              ,0
              ,0
              ,0
              ,0
              ,0
              ,0
              ,0
              ,0
              ,0
              ,0
              ,0
              ,0
              ,0
              ,0
              ,0
              ,0
              ,0
              ,0
              ,0
              ,0
              ,0
              ,0
              ,0
              ,0
              ,null
			  ,0
			  ,0
FROM  bim_i_source_codes a
where a.child_object_id >0
and a.obj_last_update_date >l_sc_s_date
and  not exists (
select  b.child_object_id,b.child_object_type from
bim_i_marketing_facts b
where b.child_object_id >0
and a.child_object_id = b.child_object_id
AND  a.object_type NOT IN ('RCAM')
and a.child_object_type = b.child_object_type);

   -- Analyze the daily facts table
   DBMS_STATS.gather_table_stats('BIM','BIM_I_MARKETING_FACTS', estimate_percent => 5,
                                  degree => 8, granularity => 'GLOBAL', cascade =>TRUE);

   --dbms_output.put_line('after analyze log'||sqlerrm(sqlcode));
/***************************************************************/
 --dbms_output.put_line('b4 inserting log');
 BIS_COLLECTION_UTILITIES.log('Before Insert into log.');
    BEGIN
    IF (Not BIS_COLLECTION_UTILITIES.setup('MARKETING_FACTS')) THEN
    RAISE FND_API.G_EXC_ERROR;
    return;
    END IF;
    BIS_COLLECTION_UTILITIES.WRAPUP(
                  p_status => TRUE ,
                  p_period_from =>p_start_date,
                  p_period_to => sysdate--p_end_date
                  );
   Exception when others then
     Rollback;
     BIS_COLLECTION_UTILITIES.WRAPUP(
                  p_status => FALSE,
                   p_period_from =>p_start_date,
                  p_period_to =>sysdate-- p_end_date
                  );
     RAISE FND_API.G_EXC_ERROR;
     END;
     BIS_COLLECTION_UTILITIES.log('After Insert into log.');
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_msg_PUB.Count_And_Get (
          --  p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

    ams_utility_pvt.write_conc_log('SUBSEQUENT_LOAD:IN EXPECTED EXCEPTION '||sqlerrm(sqlcode));
    BIS_COLLECTION_UTILITIES.log('SUBSEQUENT_LOAD:IN EXPECTED EXCEPTION '||sqlerrm(sqlcode));
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     -- Standard call to get message count and if count=1, get the message
     FND_msg_PUB.Count_And_Get (
            --p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

    ams_utility_pvt.write_conc_log('BIM_I_MARKETING_FACTS:SUBSEQUENT_LOAD:IN UNEXPECTED EXCEPTION '||sqlerrm(sqlcode));
    BIS_COLLECTION_UTILITIES.log('SUBSEQUENT_LOAD:IN UNEXPECTED EXCEPTION '||sqlerrm(sqlcode));
   WHEN OTHERS THEN

     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     IF FND_msg_PUB.Check_msg_Level (FND_msg_PUB.G_msg_LVL_UNEXP_ERROR)
     THEN
        FND_msg_PUB.Add_Exc_msg( g_pkg_name,l_api_name);
     END IF;

     -- Standard call to get message count and if count=1, get the message
     FND_msg_PUB.Count_And_Get (
           -- p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );
    ams_utility_pvt.write_conc_log('BIM_I_MARKETING_FACTS:SUBSEQUENT_LOAD:IN OTHERS EXCEPTION '||sqlerrm(sqlcode));
    BIS_COLLECTION_UTILITIES.log('SUBSEQUENT_LOAD:IN other EXCEPTION '||sqlerrm(sqlcode));
END SUB_LOAD;
END BIM_MARKET_FACTS_PKG;

/
