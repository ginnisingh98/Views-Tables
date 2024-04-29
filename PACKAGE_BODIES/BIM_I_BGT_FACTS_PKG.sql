--------------------------------------------------------
--  DDL for Package Body BIM_I_BGT_FACTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIM_I_BGT_FACTS_PKG" AS
/*$Header: bimibgfb.pls 120.3 2005/10/14 06:11:40 sbassi noship $*/

g_pkg_name  CONSTANT  VARCHAR2(20) := 'BIM_I_BGT_FACTS_PKG';
g_file_name CONSTANT  VARCHAR2(20) := 'bimibgfb.pls';
l_global_currency_code CONSTANT varchar2(20) := bis_common_parameters.get_currency_code;
l_secondary_currency_code CONSTANT VARCHAR2(20) :=bis_common_parameters.get_secondary_currency_code;
l_pgc_rate_type CONSTANT VARCHAR2(20) :=bis_common_parameters.Get_Rate_Type;
l_sgc_rate_type CONSTANT VARCHAR2(20) :=bis_common_parameters.Get_secondary_Rate_Type;
-- Checks for any missing currency from budget facts table

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
   FROM BIM_I_BGT_RATES
   WHERE prim_conversion_rate < 0
   AND tc_code is not null
   AND trx_date >= p_start_date
   ORDER BY tc_code,
            trx_date ;

 CURSOR C_missing_rates2
 IS
    SELECT tc_code from_currency,
          decode(sec_conversion_rate,-3,to_date('01/01/1999','MM/DD/RRRR'),trx_date) transaction_create_date
   FROM BIM_I_BGT_RATES
   WHERE sec_conversion_rate < 0
   AND tc_code is not null
   AND trx_date >= p_start_date
   ORDER BY tc_code,
            trx_date ;
BEGIN
 l_msg_name:= 'BIS_DBI_CURR_NO_LOAD';
 SELECT COUNT(*) INTO l_cnt_miss_rate1 FROM BIM_I_BGT_RATES
 WHERE
 prim_conversion_rate < 0
 AND tc_code is not null
 AND trx_date >= p_start_date;

 SELECT COUNT(*) INTO l_cnt_miss_rate2 FROM BIM_I_BGT_RATES
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
   FOR rate_record1 in C_missing_rates1
   LOOP
		BIS_COLLECTION_UTILITIES.writeMissingRate(
		p_rate_type => l_pgc_rate_type,
        	p_from_currency => rate_record1.from_currency,
        	p_to_currency => l_global_currency_code,
        	p_date => rate_record1.transaction_create_date);
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
   FOR rate_record2 in C_missing_rates2
   LOOP
		BIS_COLLECTION_UTILITIES.writeMissingRate(
		p_rate_type => l_sgc_rate_type,
        	p_from_currency => rate_record2.from_currency,
        	p_to_currency => l_secondary_currency_code,
        	p_date => rate_record2.transaction_create_date);
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
    ,p_truncate_flg	       IN VARCHAR2
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
    l_global_date	      DATE;
    l_sysdate		      DATE;

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
   BIS_COLLECTION_UTILITIES.log('BIM_I_BUDGET_FACTS: Facts load starts at:'||sysdate);

  l_global_start_date :=BIS_COMMON_PARAMETERS.GET_GLOBAL_START_DATE();

     /* THIS CODE REPLACES THE GET_LAST_REFRESH_PERIOD TO GET_LAST_REFRESH_DATES */

        bis_collection_utilities.get_last_refresh_dates('BUDGET_FACTS'
                        ,l_conc_start_date,l_conc_end_date,l_start_date,l_end_date);


        IF (l_end_date IS NULL) THEN

                IF (p_start_date  IS NULL) THEN
                  bis_collection_utilities.log('Please run the Upadate budget Facts First Time Base Summary concurrent program before running this');
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
                BIS_COLLECTION_UTILITIES.log('BIM_I_BUDGET_FACTS: First Load');

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
			BIS_COLLECTION_UTILITIES.log('BIM_I_BUDGET_FACTS: Incremental Load');
			/*SUB_LOAD(p_start_date => l_end_date+1/86400
			 ,p_end_date =>  sysdate
			 ,p_api_version_number => l_api_version_number
			 ,p_init_msg_list => FND_API.G_FALSE
			 ,p_load_type => l_load_type
			 ,x_msg_count => x_msg_count
			  ,x_msg_data   => x_msg_data
			  ,x_return_status => x_return_status
			 );*/
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
    BIS_COLLECTION_UTILITIES.log('BIM_I_BUDGET_FACTS: Facts Concurrent Program Succesfully Completed');

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
    l_check_missing_rate          NUMBER;
    l_stmt                        VARCHAR2(50);
    l_min_date			date;

    l_status       VARCHAR2(5);
    l_industry     VARCHAR2(5);
    l_schema       VARCHAR2(30);
    l_return       BOOLEAN;
BEGIN

   l_return  := fnd_installation.get_app_info('BIM', l_status, l_industry, l_schema);

   --dbms_output.put_line('inside first load:'|| p_start_date || ' '|| p_end_date);

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

   --dbms_output.put_line('BIM_I_BUDGET_FACTS: Running the First Load '||sqlerrm(sqlcode));

   -- The below four commands are necessary for the purpose of the parallel insertion */
   BEGIN
   EXECUTE IMMEDIATE 'ALTER SESSION ENABLE PARALLEL dml ';
   --EXECUTE IMMEDIATE 'ALTER SESSION SET SORT_AREA_SIZE=100000000 ';
   --EXECUTE IMMEDIATE 'ALTER SESSION SET HASH_AREA_SIZE=100000000 ';
   --EXECUTE IMMEDIATE 'ALTER TABLE   BIM_I_BUDGET_FACTS nologging ';
   -- EXECUTE IMMEDIATE 'ALTER SEQUENCE BIM_I_BUDGET_FACTS_s CACHE 1000 ';


   /* Piece of Code for retrieving,storing storage parameters and Dropping the indexes */
      BIS_COLLECTION_UTILITIES.log('BIM_I_BUDGET_FACTS:Drop index before inserting.');
      BIM_UTL_PKG.drop_index('BIM_I_BUDGET_FACTS');
   /* End of Code for dropping the existing indexes */
   EXCEPTION when others then
   BIS_COLLECTION_UTILITIES.log('BIM_I_BUDGET_FACTS: error:'||sqlerrm(sqlcode));
   --dbms_output.put_line('error first:'||sqlerrm(sqlcode));
   END;
   l_table_name :='BIM_I_BUDGET_FACTS';
   EXECUTE IMMEDIATE 'TRUNCATE table '||l_schema||'.BIM_I_BUDGET_FACTS_STG';
   EXECUTE IMMEDIATE 'TRUNCATE table '||l_schema||'.BIM_I_BGT_RATES';
   BIS_COLLECTION_UTILITIES.log('BIM_I_BUDGET_FACTS:First insert into table BIM_I_BUDGET_FACTS_STG');
  -- dbms_output.put_Line('JUST BEFORE THE MAIN INSERT STATMENT');
      INSERT /*+ append parallel */
      INTO BIM_I_BUDGET_FACTS_STG CDF(
        creation_date
        ,last_update_date
        ,created_by
        ,last_updated_by
        ,last_update_login
        ,fund_id
        ,parent_fund_id
        ,fund_number
        ,start_date
        ,end_date
        ,start_period
        ,end_period
        ,set_of_books_id
        ,fund_type
        --,region
        ,country
        ,org_id
        ,category_id
        ,status
        ,original_budget
        ,transfer_in
        ,transfer_out
        ,holdback_amt
        ,currency_code_fc
        ,delete_flag
        ,transaction_create_date
        ,business_unit_id
	,from_currency
	,conversion_rate
	,planned
	,committed
	,utilized
	,paid
	,metric_type
	,accrual
        ,conversion_rate_s
         ,original_budget_s
         ,transfer_in_s
         ,transfer_out_s
         ,holdback_amt_s
         ,planned_s
         ,committed_s
         ,utilized_s
         ,accrual_s
         ,paid_s)
SELECT  /*+ parallel */
       sysdate,
       sysdate,
       l_user_id,
       l_user_id,
       l_user_id,
       inner.fund_id,
       inner.parent_fund_id,
       inner.fund_number,
       inner.start_date,
       inner.end_date,
       inner.start_period,
       inner.end_period,
       inner.set_of_books_id,
       inner.fund_type,
       --inner.region,
       inner.country,
       inner.org_id,
       inner.category_id,
       inner.status,
       inner.original_budget,
       inner.transfer_in,
       inner.transfer_out,
       inner.holdback_amt,
       inner.currency_code_fc,
       'N',
       inner.transaction_create_date,
       inner.business_unit_id,
       inner.from_currency,
       inner.conversion_rate,
       inner.planned,
       inner.committed,
       inner.utilized,
       inner.paid,
       inner.metric_type,
       inner.accrual,
       inner.conversion_rate_s,
       inner.original_budget_s,
       inner.transfer_in_s,
       inner.transfer_out_s,
       inner.holdback_amt_s,
       inner.planned_s,
       inner.committed_s,
       inner.utilized_s,
       inner.accrual_s,
       inner.paid_s
FROM (
SELECT    fund_id fund_id,
          fund_number fund_number,
          start_date start_date,
          end_date end_date,
          start_period start_period,
          end_period end_period,
          category_id category_id,
          status status,
          fund_type fund_type,
          parent_fund_id parent_fund_id,
          country country,
          org_id org_id,
          business_unit_id business_unit_id,
          set_of_books_id set_of_books_id,
          currency_code_fc currency_code_fc,
          original_budget original_budget,
          transaction_create_date transaction_create_date,
          SUM(transfer_in) transfer_in,
          SUM(transfer_out) transfer_out,
          SUM(holdback_amt) holdback_amt,
	  from_currency,
	  conversion_rate,
	  SUM(planned) planned,
  	  SUM(committed) committed,
	  SUM(utilized) utilized,
	  SUM(paid) paid,
	  metric_type metric_type,
          SUM(accrual) accrual,
           conversion_rate_s,
          SUM(original_budget_s) original_budget_s,
          SUM(transfer_in_s) transfer_in_s,
          SUM(transfer_out_s) transfer_out_s,
          SUM(holdback_amt_s) holdback_amt_s,
          SUM(planned_s) planned_s,
          SUM(committed_s) committed_s,
          SUM(utilized_s) utilized_s,
          SUM(accrual_s) accrual_s,
          SUM(paid_s) paid_s
FROM      (
--original budget
SELECT    ad.fund_id fund_id,
          ad.fund_number fund_number,
          ad.start_date_active start_date,
          ad.end_date_active end_date,
          ad.start_period_name start_period,
          ad.end_period_name end_period,
          ad.category_id category_id,
          ad.status_code status,
          ad.fund_type fund_type,
          ad.parent_fund_id parent_fund_id,
          ad.country_id country,
          ad.org_id org_id,
          ad.business_unit_id business_unit_id,
          ad.set_of_books_id set_of_books_id,
          ad.currency_code_fc currency_code_fc,
          DECODE(ad.fund_type,'FIXED',ad.original_budget,'FULLY_ACCRUED',0) original_budget,
          trunc(ad.start_date_active) transaction_create_date,
          0     transfer_in,
          0     transfer_out,
          0     holdback_amt,
	  nvl(ad.currency_code_tc,'USD') from_currency,
          0 conversion_rate,
	  0     planned,
	  0     committed,
	  0     utilized,
	  0     paid,
	  'ORIGINAL_BUDGET' metric_type,
	  0     accrual,
          0 conversion_rate_s,
          0 original_budget_s,
          0 transfer_in_s,
          0 transfer_out_s,
          0 holdback_amt_s,
          0 planned_s,
          0 committed_s,
          0 utilized_s,
          0 accrual_s,
          0 paid_s
FROM      ozf_funds_all_b ad
WHERE     nvl(ad.end_date_active,sysdate) >=p_start_date
AND       ad.start_date_active <=p_end_date
AND       ad.status_code in  ('ACTIVE','CLOSED','CANCELLED')
AND       ad.parent_fund_id is null
UNION ALL --transfer_in
SELECT    ad.fund_id fund_id,
          ad.fund_number fund_number,
          ad.start_date_active start_date,
          ad.end_date_active end_date,
          ad.start_period_name start_period,
          ad.end_period_name end_period,
          ad.category_id category_id,
          ad.status_code status,
          ad.fund_type fund_type,
          ad.parent_fund_id parent_fund_id,
          ad.country_id country,
          ad.org_id org_id,
          ad.business_unit_id business_unit_id,
          ad.set_of_books_id set_of_books_id,
          ad.currency_code_fc currency_code_fc,
          0 original_budget,
          trunc(bu1.approval_date) transaction_create_date,
          SUM(nvl(bu1.approved_amount,0)) transfer_in,
          0     transfer_out,
          0     holdback_amt,
	  nvl(bu1.request_currency,'USD') from_currency,
          0 conversion_rate,
	  0     planned,
	  0     committed,
	  0     utilized,
	  0     paid,
	  'TRANSFER_IN' metric_type,
	  0     accrual,
          0 conversion_rate_s,
          0 original_budget_s,
          0 transfer_in_s,
           0 transfer_out_s,
          0 holdback_amt_s,
          0 planned_s,
          0 committed_s,
          0 utilized_s,
          0 accrual_s,
          0 paid_s
   FROM   ozf_funds_all_b ad,
          ozf_act_budgets BU1
   WHERE  nvl(ad.end_date_active,sysdate) >p_start_date
   AND    bu1.approval_date <= p_end_date
   AND    bu1.transfer_type in ('TRANSFER','REQUEST')
   AND    bu1.status_code = 'APPROVED'
   AND    bu1.arc_act_budget_used_by = 'FUND'
   AND    bu1.act_budget_used_by_id = ad.fund_id
   AND    bu1.budget_source_type ='FUND'
   GROUP BY ad.fund_id,
          trunc(bu1.approval_date) ,
          ad.fund_number,
          ad.start_date_active ,
          ad.end_date_active ,
          ad.start_period_name ,
          ad.end_period_name ,
          ad.category_id ,
          ad.status_code ,
          ad.fund_type ,
          ad.parent_fund_id,
          ad.country_id,
          ad.business_unit_id,
          ad.org_id ,
          ad.set_of_books_id ,
          ad.currency_code_fc ,
          ad.original_budget ,
	  nvl(bu1.request_currency,'USD')
UNION ALL --transfer_out
  SELECT  ad.fund_id fund_id,
          ad.fund_number fund_number,
          ad.start_date_active start_date,
          ad.end_date_active end_date,
          ad.start_period_name start_period,
          ad.end_period_name end_period,
          ad.category_id category_id,
          ad.status_code status,
          ad.fund_type fund_type,
          ad.parent_fund_id parent_fund_id,
          ad.country_id country,
          ad.org_id org_id,
          ad.business_unit_id business_unit_id,
          ad.set_of_books_id set_of_books_id,
          ad.currency_code_fc currency_code_fc,
          0 original_budget,
          trunc(bu2.approval_date) transaction_create_date,
          0   transfer_in,
          SUM(decode(bu2.transfer_type,'TRANSFER', nvl(bu2.approved_amount,0),0))+
          SUM(decode(bu2.transfer_type,'REQUEST',  nvl(bu2.approved_amount,0),0)) transfer_out,
          SUM(decode(bu2.transfer_type, 'RESERVE', nvl(bu2.approved_amount,0),0))-
          SUM(decode(bu2.transfer_type, 'RELEASE', nvl(bu2.approved_amount,0),0)) holdback_amt,
          nvl(bu2.request_currency,'USD') from_currency,
          0 conversion_rate,
	  0     planned,
	  0     committed,
	  0     utilized,
	  0     paid,
	  'TRANSFER_OUT' metric_type,
	  0     accrual,
          0 conversion_rate_s,
          0 original_budget_s,
          0   transfer_in_s,
          0 transfer_out_s,
          0 holdback_amt_s,
          0 planned_s,
          0 committed_s,
          0 utilized_s,
          0 accrual_s,
          0 paid_s
   FROM   ozf_funds_all_b ad,
          ozf_act_budgets BU2
   WHERE  nvl(ad.end_date_active,sysdate) >p_start_date
   AND    bu2.approval_date<=p_end_date
   AND    bu2.status_code = 'APPROVED'
   AND    bu2.arc_act_budget_used_by = 'FUND'
   AND    bu2.budget_source_type='FUND'
   AND    bu2.budget_source_id = ad.fund_id
   GROUP BY ad.fund_id,
          trunc(bu2.approval_date) ,
          ad.fund_number,
          ad.start_date_active ,
          ad.end_date_active ,
          ad.start_period_name ,
          ad.end_period_name ,
          ad.category_id ,
          ad.status_code ,
          ad.fund_type ,
          ad.parent_fund_id,
          ad.country_id,
          ad.org_id ,
          ad.business_unit_id,
          ad.set_of_books_id ,
          ad.currency_code_fc ,
          ad.original_budget,
          nvl(bu2.request_currency,'USD')
  UNION ALL--planned
  SELECT  ad.fund_id fund_id,
          ad.fund_number fund_number,
          ad.start_date_active start_date,
          ad.end_date_active end_date,
          ad.start_period_name start_period,
          ad.end_period_name end_period,
          ad.category_id category_id,
          ad.status_code status,
          ad.fund_type fund_type,
          ad.parent_fund_id parent_fund_id,
          ad.country_id country,
          ad.org_id org_id,
          ad.business_unit_id business_unit_id,
          ad.set_of_books_id set_of_books_id,
          ad.currency_code_fc currency_code_fc,
          0 original_budget,
          trunc(nvl(bu2.request_date,bu2.creation_date)) transaction_create_date,
          0   transfer_in,
          0 transfer_out,
          0 holdback_amt,
          nvl(bu2.request_currency,'USD') from_currency,
          0 conversion_rate,
	  SUM(nvl(bu2.request_amount,0))     planned,
	  0     committed,
	  0     utilized,
	  0     paid,
	  'PLANNED' metric_type,
	  0     accrual,
          0 conversion_rate_s,
          0 original_budget_s,
          0   transfer_in_s,
          0 transfer_out_s,
          0 holdback_amt_s,
          0 planned_s,
          0 committed_s,
          0 utilized_s,
          0 accrual_s,
          0 paid_s
   FROM   ozf_funds_all_b ad,
          ozf_act_budgets BU2
   WHERE nvl(ad.end_date_active,sysdate) >p_start_date
   AND   bu2.budget_source_type ='FUND'
   AND   bu2.ARC_ACT_BUDGET_USED_BY <> 'FUND'
   AND    nvl(bu2.request_date,bu2.creation_date) <=p_end_date
   AND    bu2.budget_source_id = ad.fund_id
   GROUP BY ad.fund_id,
          trunc(nvl(bu2.request_date,bu2.creation_date)) ,
          ad.fund_number,
          ad.start_date_active ,
          ad.end_date_active ,
          ad.start_period_name ,
          ad.end_period_name ,
          ad.category_id ,
          ad.status_code ,
          ad.fund_type ,
          ad.parent_fund_id,
          ad.country_id,
          ad.org_id ,
          ad.business_unit_id,
          ad.set_of_books_id ,
          ad.currency_code_fc ,
          ad.original_budget,
          nvl(bu2.request_currency,'USD')
   UNION ALL--PLANNED 2
   SELECT  ad.fund_id fund_id,
          ad.fund_number fund_number,
          ad.start_date_active start_date,
          ad.end_date_active end_date,
          ad.start_period_name start_period,
          ad.end_period_name end_period,
          ad.category_id category_id,
          ad.status_code status,
          ad.fund_type fund_type,
          ad.parent_fund_id parent_fund_id,
          ad.country_id country,
          ad.org_id org_id,
          ad.business_unit_id business_unit_id,
          ad.set_of_books_id set_of_books_id,
          ad.currency_code_fc currency_code_fc,
          0 original_budget,
          trunc(bu2.approval_date) transaction_create_date,
          0   transfer_in,
          0 transfer_out,
          0 holdback_amt,
          nvl(bu2.request_currency,'USD') from_currency,
          0 conversion_rate,
	  0-SUM(nvl(bu2.approved_amount,0))    planned,
	  0      committed,
	  0     utilized,
	  0     paid,
	  'PLANNED' metric_type,
	  0     accrual,
          0 conversion_rate_s,
          0 original_budget_s,
          0   transfer_in_s,
          0 transfer_out_s,
          0 holdback_amt_s,
          0 planned_s,
          0 committed_s,
          0 utilized_s,
          0 accrual_s,
          0 paid_s
   FROM   ozf_funds_all_b ad,
          ozf_act_budgets BU2
   WHERE nvl(ad.end_date_active,sysdate) >p_start_date
   AND   bu2.arc_act_budget_used_by ='FUND'
   AND   bu2.budget_source_type<>'FUND'
   AND   bu2.status_code ='APPROVED'
   AND    bu2.approval_date <=p_end_date
   AND    bu2.act_budget_used_by_id = ad.fund_id
GROUP BY ad.fund_id,
          trunc(bu2.approval_date) ,
          ad.fund_number,
          ad.start_date_active ,
          ad.end_date_active ,
          ad.start_period_name ,
          ad.end_period_name ,
          ad.category_id ,
          ad.status_code ,
          ad.fund_type ,
          ad.parent_fund_id,
          ad.country_id,
          ad.org_id ,
          ad.business_unit_id,
          ad.set_of_books_id ,
          ad.currency_code_fc ,
          ad.original_budget,
          nvl(bu2.request_currency,'USD')
  UNION ALL--committed 1
   SELECT  ad.fund_id fund_id,
          ad.fund_number fund_number,
          ad.start_date_active start_date,
          ad.end_date_active end_date,
          ad.start_period_name start_period,
          ad.end_period_name end_period,
          ad.category_id category_id,
          ad.status_code status,
          ad.fund_type fund_type,
          ad.parent_fund_id parent_fund_id,
          ad.country_id country,
          ad.org_id org_id,
          ad.business_unit_id business_unit_id,
          ad.set_of_books_id set_of_books_id,
          ad.currency_code_fc currency_code_fc,
          0 original_budget,
          trunc(bu2.approval_date) transaction_create_date,
          0   transfer_in,
          0 transfer_out,
          0 holdback_amt,
          nvl(bu2.request_currency,'USD') from_currency,
          0 conversion_rate,
	  0    planned,
	  SUM(nvl(bu2.approved_amount,0))      committed,
	  0     utilized,
	  0     paid,
	  'COMMITTED' metric_type,
	  0     accrual,
          0 conversion_rate_s,
          0 original_budget_s,
          0 transfer_in_s,
          0 transfer_out_s,
          0 holdback_amt_s,
          0 planned_s,
          0 committed_s,
          0 utilized_s,
          0 accrual_s,
          0 paid_s
   FROM   ozf_funds_all_b ad,
          ozf_act_budgets BU2
   WHERE nvl(ad.end_date_active,sysdate) >p_start_date
   AND   bu2.budget_source_type ='FUND'
   AND   bu2.ARC_ACT_BUDGET_USED_BY <> 'FUND'
   AND    bu2.approval_date <=p_end_date
   AND    bu2.budget_source_id = ad.fund_id
GROUP BY ad.fund_id,
          trunc(bu2.approval_date) ,
          ad.fund_number,
          ad.start_date_active ,
          ad.end_date_active ,
          ad.start_period_name ,
          ad.end_period_name ,
          ad.category_id ,
          ad.status_code ,
          ad.fund_type ,
          ad.parent_fund_id,
          ad.country_id,
          ad.org_id ,
          ad.business_unit_id,
          ad.set_of_books_id ,
          ad.currency_code_fc ,
          ad.original_budget,
          nvl(bu2.request_currency,'USD')
  UNION ALL--committed 2
   SELECT  ad.fund_id fund_id,
          ad.fund_number fund_number,
          ad.start_date_active start_date,
          ad.end_date_active end_date,
          ad.start_period_name start_period,
          ad.end_period_name end_period,
          ad.category_id category_id,
          ad.status_code status,
          ad.fund_type fund_type,
          ad.parent_fund_id parent_fund_id,
          ad.country_id country,
          ad.org_id org_id,
          ad.business_unit_id business_unit_id,
          ad.set_of_books_id set_of_books_id,
          ad.currency_code_fc currency_code_fc,
          0 original_budget,
          trunc(bu2.approval_date) transaction_create_date,
          0 transfer_in,
          0 transfer_out,
          0 holdback_amt,
          nvl(bu2.request_currency,'USD') from_currency,
          0 conversion_rate,
	  0 planned,
	  0-SUM(nvl(bu2.approved_amount,0))      committed,
	  0 utilized,
	  0 paid,
	  'COMMITTED' metric_type,
	  0 accrual,
          0 conversion_rate_s,
          0 original_budget_s,
          0 transfer_in_s,
          0 transfer_out_s,
          0 holdback_amt_s,
          0 planned_s,
          0 committed_s,
          0 utilized_s,
          0 accrual_s,
          0 paid_s
   FROM   ozf_funds_all_b ad,
          ozf_act_budgets BU2
   WHERE nvl(ad.end_date_active,sysdate) >p_start_date
   AND   bu2.arc_act_budget_used_by ='FUND'
   AND   bu2.budget_source_type<>'FUND'
   AND   bu2.status_code ='APPROVED'
   AND    bu2.approval_date <=p_end_date
   AND    bu2.act_budget_used_by_id = ad.fund_id
GROUP BY ad.fund_id,
          trunc(bu2.approval_date) ,
          ad.fund_number,
          ad.start_date_active ,
          ad.end_date_active ,
          ad.start_period_name ,
          ad.end_period_name ,
          ad.category_id ,
          ad.status_code ,
          ad.fund_type ,
          ad.parent_fund_id,
          ad.country_id,
          ad.org_id ,
          ad.business_unit_id,
          ad.set_of_books_id ,
          ad.currency_code_fc ,
          ad.original_budget,
          nvl(bu2.request_currency,'USD')
 UNION ALL --utilized
 SELECT  ad.fund_id fund_id,
          ad.fund_number fund_number,
          ad.start_date_active start_date,
          ad.end_date_active end_date,
          ad.start_period_name start_period,
          ad.end_period_name end_period,
          ad.category_id category_id,
          ad.status_code status,
          ad.fund_type fund_type,
          ad.parent_fund_id parent_fund_id,
          ad.country_id country,
          ad.org_id org_id,
          ad.business_unit_id business_unit_id,
          ad.set_of_books_id set_of_books_id,
          ad.currency_code_fc currency_code_fc,
          0 original_budget,
          trunc(u2.creation_date) transaction_create_date,
          0   transfer_in,
          0 transfer_out,
          0 holdback_amt,
          nvl(u2.currency_code,'USD') from_currency,
          0 conversion_rate,
	  0 planned,
	  0 committed,
	  SUM(nvl(u2.amount,0))     utilized,
	  0 paid,
	  'UTILIZED' metric_type,
	  0 accrual,
          0 conversion_rate_s,
          0 original_budget_s,
          0 transfer_in_s,
          0 transfer_out_s,
          0 holdback_amt_s,
          0 planned_s,
          0 committed_s,
          0 utilized_s,
          0 accrual_s,
          0 paid_s
   FROM   ozf_funds_all_b ad,
          ozf_funds_utilized_all_b u2
   WHERE nvl(ad.end_date_active,sysdate) >p_start_date
   AND   ad.fund_id =u2.fund_id
   AND    u2.creation_date <=p_end_date
   AND    u2.utilization_type in ('UTILIZED','ACCRUAL','ADJUSTMENT')
GROUP BY ad.fund_id,
          trunc(u2.creation_date),
          ad.fund_number,
          ad.start_date_active ,
          ad.end_date_active ,
          ad.start_period_name ,
          ad.end_period_name ,
          ad.category_id ,
          ad.status_code ,
          ad.fund_type ,
          ad.parent_fund_id,
          ad.country_id,
          ad.org_id ,
          ad.business_unit_id,
          ad.set_of_books_id ,
          ad.currency_code_fc ,
          ad.original_budget,
          nvl(u2.currency_code,'USD')
 union all --utilized 2
 SELECT  ad.fund_id fund_id,
          ad.fund_number fund_number,
          ad.start_date_active start_date,
          ad.end_date_active end_date,
          ad.start_period_name start_period,
          ad.end_period_name end_period,
          ad.category_id category_id,
          ad.status_code status,
          ad.fund_type fund_type,
          ad.parent_fund_id parent_fund_id,
          ad.country_id country,
          ad.org_id org_id,
          ad.business_unit_id business_unit_id,
          ad.set_of_books_id set_of_books_id,
          ad.currency_code_fc currency_code_fc,
          0 original_budget,
          trunc(u2.creation_date) transaction_create_date,
          0   transfer_in,
          0 transfer_out,
          0 holdback_amt,
          nvl(u2.currency_code,'USD') from_currency,
          0 conversion_rate,
	  0 planned,
	  0 committed,
	  0-SUM(nvl(u2.amount,0))  utilized,
	  0 paid,
	  'UTILIZED' metric_type,
	  0 accrual,
          0 conversion_rate_s,
          0 original_budget_s,
          0 transfer_in_s,
          0 transfer_out_s,
          0 holdback_amt_s,
          0 planned_s,
          0 committed_s,
          0 utilized_s,
          0 accrual_s,
          0 paid_s
   FROM   ozf_funds_all_b ad,
          ozf_funds_utilized_all_b u2
   WHERE nvl(ad.end_date_active,sysdate) >p_start_date
   AND   ad.fund_id =u2.fund_id
   AND   ad.fund_type='FULLY_ACCRUED'
   AND   ad.liability_flag='N'
   AND   ad.accrual_basis='CUSTOMER'
   AND   u2.creation_date <=p_end_date
   AND   ad.plan_id=u2.component_id
   AND   u2.component_type='OFFR'
   AND    u2.utilization_type  ='ACCRUAL'
GROUP BY ad.fund_id,
          trunc(u2.creation_date),
          ad.fund_number,
          ad.start_date_active ,
          ad.end_date_active ,
          ad.start_period_name ,
          ad.end_period_name ,
          ad.category_id ,
          ad.status_code ,
          ad.fund_type ,
          ad.parent_fund_id,
          ad.country_id,
          ad.org_id ,
          ad.business_unit_id,
          ad.set_of_books_id ,
          ad.currency_code_fc ,
          ad.original_budget,
          nvl(u2.currency_code,'USD')
 UNION ALL --accrual
 SELECT  ad.fund_id fund_id,
          ad.fund_number fund_number,
          ad.start_date_active start_date,
          ad.end_date_active end_date,
          ad.start_period_name start_period,
          ad.end_period_name end_period,
          ad.category_id category_id,
          ad.status_code status,
          ad.fund_type fund_type,
          ad.parent_fund_id parent_fund_id,
          ad.country_id country,
          ad.org_id org_id,
          ad.business_unit_id business_unit_id,
          ad.set_of_books_id set_of_books_id,
          ad.currency_code_fc currency_code_fc,
          0 original_budget,
          trunc(u2.creation_date) transaction_create_date,
          0   transfer_in,
          0 transfer_out,
          0 holdback_amt,
          nvl(u2.currency_code,'USD') from_currency,
          0 conversion_rate,
	  0    planned,
	  0    committed,
	  0    utilized,
	  0     paid,
	  'ACCRUAL' metric_type,
	  SUM(nvl(u2.amount,0))     accrual,
          0 conversion_rate_s,
          0 original_budget_s,
          0   transfer_in_s,
          0 transfer_out_s,
          0 holdback_amt_s,
          0 planned_s,
          0 committed_s,
          0    utilized_s,
          0 accrual_s,
          0 paid_s
   FROM   ozf_funds_all_b ad,
          ozf_funds_utilized_all_b u2
   WHERE nvl(ad.end_date_active,sysdate) >p_start_date
   AND   ad.fund_id =u2.fund_id
   AND   ad.fund_type='FULLY_ACCRUED'
   AND   ad.liability_flag='N'
   AND   ad.accrual_basis='CUSTOMER'
   AND   u2.creation_date <=p_end_date
   AND   ad.plan_id=u2.component_id
   AND   u2.component_type='OFFR'
   AND    u2.utilization_type  ='ACCRUAL'
GROUP BY ad.fund_id,
          trunc(u2.creation_date),
          ad.fund_number,
          ad.start_date_active ,
          ad.end_date_active ,
          ad.start_period_name ,
          ad.end_period_name ,
          ad.category_id ,
          ad.status_code ,
          ad.fund_type ,
          ad.parent_fund_id,
          ad.country_id,
          ad.org_id ,
          ad.business_unit_id,
          ad.set_of_books_id ,
          ad.currency_code_fc ,
          ad.original_budget,
          nvl(u2.currency_code,'USD')
 union all --accrual 2
 SELECT  ad.fund_id fund_id,
          ad.fund_number fund_number,
          ad.start_date_active start_date,
          ad.end_date_active end_date,
          ad.start_period_name start_period,
          ad.end_period_name end_period,
          ad.category_id category_id,
          ad.status_code status,
          ad.fund_type fund_type,
          ad.parent_fund_id parent_fund_id,
          ad.country_id country,
          ad.org_id org_id,
          ad.business_unit_id business_unit_id,
          ad.set_of_books_id set_of_books_id,
          ad.currency_code_fc currency_code_fc,
          0 original_budget,
          trunc(u2.creation_date) transaction_create_date,
          0   transfer_in,
          0 transfer_out,
          0 holdback_amt,
          nvl(u2.currency_code,'USD') from_currency,
          0 conversion_rate,
	  0    planned,
	  0    committed,
	  0    utilized,
	  0     paid,
	  'ACCRUAL' metric_type,
	  SUM(nvl(u2.amount,0))     accrual,
          0 conversion_rate_s,
          0 original_budget_s,
          0   transfer_in_s,
          0 transfer_out_s,
          0 holdback_amt_s,
          0 planned_s,
          0 committed_s,
          0  utilized_s,
          0 accrual_s,
          0 paid_s
   FROM   ozf_funds_all_b ad,
          ozf_funds_utilized_all_b u2
   WHERE nvl(ad.end_date_active,sysdate) >p_start_date
   AND   ad.fund_id =u2.fund_id
   AND   ad.fund_type='FULLY_ACCRUED'
   AND   ad.accrual_basis='SALES'
   AND   u2.creation_date <=p_end_date
   AND   ad.plan_id=u2.component_id
   AND   u2.component_type='OFFR'
   AND    u2.utilization_type  ='SALES_ACCRUAL'
GROUP BY ad.fund_id,
          trunc(u2.creation_date),
          ad.fund_number,
          ad.start_date_active ,
          ad.end_date_active ,
          ad.start_period_name ,
          ad.end_period_name ,
          ad.category_id ,
          ad.status_code ,
          ad.fund_type ,
          ad.parent_fund_id,
          ad.country_id,
          ad.org_id ,
          ad.business_unit_id,
          ad.set_of_books_id ,
          ad.currency_code_fc ,
          ad.original_budget,
          nvl(u2.currency_code,'USD')
UNION ALL--paid 1
 SELECT  ad.fund_id fund_id,
          ad.fund_number fund_number,
          ad.start_date_active start_date,
          ad.end_date_active end_date,
          ad.start_period_name start_period,
          ad.end_period_name end_period,
          ad.category_id category_id,
          ad.status_code status,
          ad.fund_type fund_type,
          ad.parent_fund_id parent_fund_id,
          ad.country_id country,
          ad.org_id org_id,
          ad.business_unit_id business_unit_id,
          ad.set_of_books_id set_of_books_id,
          ad.currency_code_fc currency_code_fc,
          0 original_budget,
          trunc(u2.creation_date) transaction_create_date,
          0   transfer_in,
          0 transfer_out,
          0 holdback_amt,
          nvl(u2.currency_code,'USD') from_currency,
          0 conversion_rate,
	  0 planned,
	  0 committed,
	  0 utilized,
	  SUM(nvl(u2.amount,0))     paid,
	  'PAID' metric_type,
	  0     accrual,
          0 conversion_rate_s,
          0 original_budget_s,
          0 transfer_in_s,
          0 transfer_out_s,
          0 holdback_amt_s,
          0 planned_s,
          0 committed_s,
          0  utilized_s,
          0 accrual_s,
          0 paid_s
   FROM   ozf_funds_all_b ad,
          ozf_funds_utilized_all_b u2
   WHERE nvl(ad.end_date_active,sysdate) >p_start_date
   AND   ad.fund_id =u2.fund_id
   AND    u2.creation_date <=p_end_date
   AND    u2.utilization_type ='UTILIZED'
GROUP BY ad.fund_id,
          trunc(u2.creation_date) ,
          ad.fund_number,
          ad.start_date_active ,
          ad.end_date_active ,
          ad.start_period_name ,
          ad.end_period_name ,
          ad.category_id ,
          ad.status_code ,
          ad.fund_type ,
          ad.parent_fund_id,
          ad.country_id,
          ad.org_id ,
          ad.business_unit_id,
          ad.set_of_books_id ,
          ad.currency_code_fc ,
          ad.original_budget,
          nvl(u2.currency_code,'USD')
UNION ALL--paid 2, based on 11.5.9
 SELECT   ad.fund_id fund_id,
          ad.fund_number fund_number,
          ad.start_date_active start_date,
          ad.end_date_active end_date,
          ad.start_period_name start_period,
          ad.end_period_name end_period,
          ad.category_id category_id,
          ad.status_code status,
          ad.fund_type fund_type,
          ad.parent_fund_id parent_fund_id,
          ad.country_id country,
          ad.org_id org_id,
          ad.business_unit_id business_unit_id,
          ad.set_of_books_id set_of_books_id,
          ad.currency_code_fc currency_code_fc,
          0 original_budget,
          trunc(cla.claim_date) transaction_create_date,
          0 transfer_in,
          0 transfer_out,
          0 holdback_amt,
          nvl(cuti.currency_code,'USD') from_currency,
          0 conversion_rate,
	  0 planned,
	  0 committed,
	  0 utilized,
	  SUM(nvl(cuti.amount,0))     paid,
	  'PAID' metric_type,
	  0 accrual,
          0 conversion_rate_s,
          0 original_budget_s,
          0 transfer_in_s,
          0 transfer_out_s,
          0 holdback_amt_s,
          0 planned_s,
          0 committed_s,
          0 utilized_s,
          0 accrual_s,
          0 paid_s
   FROM   ozf_funds_all_b ad,
          ozf_funds_utilized_all_b u2,
	  ozf_claim_lines_util_all cuti,
          ozf_claim_lines_all cln,
          ozf_claims_all cla
   WHERE nvl(ad.end_date_active,sysdate) >p_start_date
   AND   ad.fund_id =u2.fund_id
   AND   cla.claim_date <=p_end_date
   AND   u2.utilization_id= cuti.utilization_id
   AND   u2.utilization_type IN ('ACCRUAL','SALES_ACCRUAL','ADJUSTMENT')
   AND   cuti.claim_line_id= cln.claim_line_id
   AND   cln.claim_id = cla.claim_id
   AND   cla.status_code = 'CLOSED'
GROUP BY ad.fund_id,
          trunc(cla.claim_date) ,
          ad.fund_number,
          ad.start_date_active ,
          ad.end_date_active ,
          ad.start_period_name ,
          ad.end_period_name ,
          ad.category_id ,
          ad.status_code ,
          ad.fund_type ,
          ad.parent_fund_id,
          ad.country_id,
          ad.org_id ,
          ad.business_unit_id,
          ad.set_of_books_id ,
          ad.currency_code_fc ,
          ad.original_budget,
          nvl(cuti.currency_code,'USD')
          )
   GROUP BY
          fund_id,
          transaction_create_date,
          fund_number,
          start_date,
          end_date,
          start_period,
          end_period,
          category_id,
          status,
          fund_type,
          parent_fund_id,
          country,
          org_id,
          business_unit_id,
          set_of_books_id,
          currency_code_fc,
          original_budget,
	  from_currency,
	  conversion_rate,
	  metric_type,
          conversion_rate_s
           )inner;
commit;
 BIS_COLLECTION_UTILITIES.log('BIM_I_BUDGET_FACTS:Inserting into BIM_I_BGT_RATES');
 --insert into bim_i_mkt_rates
INSERT /*+ append parallel */
INTO BIM_I_BGT_RATES BRT(tc_code,
                         trx_date,
			 prim_conversion_rate,
			 sec_conversion_rate)
SELECT from_currency,
       transaction_create_date,
       FII_CURRENCY.get_rate(from_currency,l_global_currency_code,transaction_create_date,l_pgc_rate_type),
       FII_CURRENCY.get_rate(from_currency,l_secondary_currency_code,transaction_create_date,l_sgc_rate_type)
FROM (select distinct from_currency from_currency,
                      transaction_create_date transaction_create_date
       from bim_i_budget_facts_stg);
commit;
l_check_missing_rate := Check_Missing_Rates (p_start_date);
if (l_check_missing_rate = -1) then
 BIS_COLLECTION_UTILITIES.debug('before truncating first time load' );
      l_stmt := 'TRUNCATE table '||l_schema||'.BIM_I_BUDGET_FACTS_stg';
      EXECUTE IMMEDIATE l_stmt;
      commit;
x_return_status := FND_API.G_RET_STS_ERROR;
RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
end if;

  --BIS_COLLECTION_UTILITIES.log('BIM_I_BUDGET_FACTS:Inserted '||SQL%COUNT);
      EXECUTE IMMEDIATE 'COMMIT';
      -- EXECUTE IMMEDIATE 'ALTER SEQUENCE BIM_I_BUDGET_FACTS_s CACHE 20';

  EXECUTE IMMEDIATE 'TRUNCATE TABLE '||l_schema||'.BIM_I_BUDGET_FACTS';
  BIS_COLLECTION_UTILITIES.deleteLogForObject('BUDGET_FACTS');

  BIS_COLLECTION_UTILITIES.log('BIM_I_BUDGET_FACTS:Insert into BIM_I_BUDGET_FACTS');
  INSERT /*+ append parallel */
      INTO BIM_I_BUDGET_FACTS CDF(
        creation_date
        ,last_update_date
        ,created_by
        ,last_updated_by
        ,last_update_login
        ,fund_id
        ,parent_fund_id
        ,fund_number
        ,start_date
        ,end_date
        ,start_period
        ,end_period
        ,set_of_books_id
        ,fund_type
        --,region
        ,country
        ,org_id
        ,category_id
        ,status
        ,original_budget
        ,transfer_in
        ,transfer_out
        ,holdback_amt
        ,currency_code_fc
        ,delete_flag
        ,transaction_create_date
        ,business_unit_id
	,from_currency
	,conversion_rate
	,planned
	,committed
	,utilized
	,paid
	,metric_type
	,accrual
        ,conversion_rate_s
         ,original_budget_s
         ,transfer_in_s
         ,transfer_out_s
         ,holdback_amt_s
         ,planned_s
         ,committed_s
         ,utilized_s
         ,accrual_s
         ,paid_s)
SELECT  /*+ parallel */
       sysdate,
       sysdate,
       l_user_id,
       l_user_id,
       l_user_id,
       inner.fund_id,
       inner.parent_fund_id,
       inner.fund_number,
       inner.start_date,
       inner.end_date,
       inner.start_period,
       inner.end_period,
       inner.set_of_books_id,
       inner.fund_type,
       --inner.region,
       inner.country,
       inner.org_id,
       inner.category_id,
       inner.status,
       inner.original_budget*prim_conversion_rate,
       inner.transfer_in*prim_conversion_rate,
       inner.transfer_out*prim_conversion_rate,
       inner.holdback_amt*prim_conversion_rate,
       inner.currency_code_fc,
       'N',
       inner.transaction_create_date,
       inner.business_unit_id,
       inner.from_currency,
       inner.conversion_rate,
       inner.planned*prim_conversion_rate,
       inner.committed*prim_conversion_rate,
       inner.utilized*prim_conversion_rate,
       inner.paid*prim_conversion_rate,
       inner.metric_type,
       inner.accrual*prim_conversion_rate,
       inner.conversion_rate_s,
       inner.original_budget*sec_conversion_rate,
       inner.transfer_in*sec_conversion_rate,
       inner.transfer_out*sec_conversion_rate,
       inner.holdback_amt*sec_conversion_rate,
       inner.planned*sec_conversion_rate,
       inner.committed*sec_conversion_rate,
       inner.utilized*sec_conversion_rate,
       inner.accrual*sec_conversion_rate,
       inner.paid*sec_conversion_rate
FROM bim_i_budget_facts_stg inner, bim_i_bgt_rates rt
where inner.from_currency = rt.tc_code
and inner.transaction_create_date= rt.trx_date;
commit;
--dbms_output.put_line('b4 put into history');
 -- Analyze the daily facts table
   DBMS_STATS.gather_table_stats('BIM','BIM_I_BUDGET_FACTS', estimate_percent => 5,
                                  degree => 8, granularity => 'GLOBAL', cascade =>TRUE);

     -- Make entry in the history table
    BIS_COLLECTION_UTILITIES.log('BIM_I_BUDGET_FACTS: Wrapup');
    BEGIN
    IF (Not BIS_COLLECTION_UTILITIES.setup('BUDGET_FACTS')) THEN
    RAISE FND_API.G_EXC_ERROR;
    return;
    END IF;

    BIS_COLLECTION_UTILITIES.WRAPUP(
                  p_status =>TRUE ,
                  p_period_from =>p_start_date,
                  p_period_to => sysdate
                  );
   Exception when others then
     Rollback;
     BIS_COLLECTION_UTILITIES.WRAPUP(
                  p_status => FALSE,
                  p_period_from =>p_start_date,
                  p_period_to =>sysdate
                  );
     RAISE FND_API.G_EXC_ERROR;
     END;

   BIS_COLLECTION_UTILITIES.log('BIM_I_BUDGET_FACTS:Before create index');

   BIM_UTL_PKG.CREATE_INDEX('BIM_I_BUDGET_FACTS');
   l_temp_msg := to_char( sysdate, 'dd/mm/yyyy:hh:mi:ss');
   --ams_utility_pvt.write_conc_log('BIM_I_BUDGET_FACTS:FIRST_LOAD: AFTER CREATE INDEX ' || l_temp_msg);
   BIS_COLLECTION_UTILITIES.log('BIM_I_BUDGET_FACTS:After create index');
   /*fnd_message.set_name('BIM','BIM_R_PROG_COMPLETION');
   fnd_message.set_token('program_name', 'Budget first load', FALSE);
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

 ams_utility_pvt.write_conc_log('BIM_I_BUDGET_FACTS:FIRST_LOAD:IN EXPECTED EXCEPTION '||sqlerrm(sqlcode));
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_msg_PUB.Count_And_Get (
            --p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );
    BIS_COLLECTION_UTILITIES.log('BIM_I_BUDGET_FACTS:Unexpected'||sqlerrm(sqlcode));

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
     BIS_COLLECTION_UTILITIES.log('BIM_I_BUDGET_FACTS:IN OTHERS EXCEPTION'||sqlerrm(sqlcode));
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
   l_return  := fnd_installation.get_app_info('BIM', l_status, l_industry, l_schema);
    --dbms_output.put_line('inside sub load:'||p_start_date || ' '|| p_end_date);

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
   --EXECUTE IMMEDIATE 'ALTER TABLE   BIM_I_BUDGET_FACTS nologging ';
   -- EXECUTE IMMEDIATE 'ALTER SEQUENCE BIM_I_BUDGET_FACTS_s CACHE 1000 ';
   EXCEPTION
    when others then
    --dbms_output.put_line('inside sub load:'||sqlerrm(sqlcode));
    l_temp_msg := to_char( sysdate, 'dd/mm/yyyy:hh:mi:ss');
   END;
    BEGIN
       DELETE from bim_i_budget_facts  where transaction_create_date>= p_start_date and metric_type is not null;
     COMMIT;
     EXCEPTION
     when others then
     BIS_COLLECTION_UTILITIES.log('BIM_I_budget_facts: Error in deleting data:'|| sqlerrm(sqlcode));
     --dbms_output.put_line('error inserting:'||sqlerrm(sqlcode));
     END;
      EXECUTE IMMEDIATE 'TRUNCATE table '||l_schema||'.BIM_I_BUDGET_FACTS_STG';
      EXECUTE IMMEDIATE 'TRUNCATE table '||l_schema||'.BIM_I_BGT_RATES';
    --dbms_output.put_line('right b4 inserting');
    BIS_COLLECTION_UTILITIES.log('BIM_I_BUDGET_FACTS:Incremental load start');
      INSERT INTO BIM_I_BUDGET_FACTS_STG CDF(
        creation_date
        ,last_update_date
        ,created_by
        ,last_updated_by
        ,last_update_login
        ,fund_id
        ,parent_fund_id
        ,fund_number
        ,start_date
        ,end_date
        ,start_period
        ,end_period
        ,set_of_books_id
        ,fund_type
        --,region
        ,country
        ,org_id
        ,category_id
        ,status
        ,original_budget
        ,transfer_in
        ,transfer_out
        ,holdback_amt
        ,currency_code_fc
        ,delete_flag
        ,transaction_create_date
        ,business_unit_id
	,from_currency
	,conversion_rate
	,planned
	,committed
	,utilized
	,paid
	,metric_type
	,accrual
         ,conversion_rate_s
         ,original_budget_s
         ,transfer_in_s
         ,transfer_out_s
         ,holdback_amt_s
         ,planned_s
         ,committed_s
         ,utilized_s
         ,accrual_s
         ,paid_s)
SELECT
       sysdate,
       sysdate,
       l_user_id,
       l_user_id,
       l_user_id,
       inner.fund_id,
       inner.parent_fund_id,
       inner.fund_number,
       inner.start_date,
       inner.end_date,
       inner.start_period,
       inner.end_period,
       inner.set_of_books_id,
       inner.fund_type,
       --inner.region,
       inner.country,
       inner.org_id,
       inner.category_id,
       inner.status,
       inner.original_budget,
       inner.transfer_in,
       inner.transfer_out,
       inner.holdback_amt,
       inner.currency_code_fc,
       'N',
       inner.transaction_create_date,
       inner.business_unit_id,
       inner.from_currency,
       inner.conversion_rate,
       inner.planned,
       inner.committed,
       inner.utilized,
       inner.paid,
       inner.metric_type,
       inner.accrual,
       inner.conversion_rate_s,
       inner.original_budget_s,
       inner.transfer_in_s,
       inner.transfer_out_s,
       inner.holdback_amt_s,
       inner.planned_s,
       inner.committed_s,
       inner.utilized_s,
       inner.accrual_s,
       inner.paid_s
FROM (
SELECT    fund_id fund_id,
          fund_number fund_number,
          start_date start_date,
          end_date end_date,
          start_period start_period,
          end_period end_period,
          category_id category_id,
          status status,
          fund_type fund_type,
          parent_fund_id parent_fund_id,
          country country,
          org_id org_id,
          business_unit_id business_unit_id,
          set_of_books_id set_of_books_id,
          currency_code_fc currency_code_fc,
          original_budget original_budget,
          transaction_create_date transaction_create_date,
          SUM(transfer_in) transfer_in,
          SUM(transfer_out) transfer_out,
          SUM(holdback_amt) holdback_amt,
	  from_currency,
	  conversion_rate,
	  SUM(planned) planned,
  	  SUM(committed) committed,
	  SUM(utilized) utilized,
	  SUM(paid) paid,
	  metric_type metric_type,
          SUM(accrual) accrual,
           conversion_rate_s,
          SUM(original_budget_s) original_budget_s,
          SUM(transfer_in_s) transfer_in_s,
          SUM(transfer_out_s) transfer_out_s,
          SUM(holdback_amt_s) holdback_amt_s,
          SUM(planned_s) planned_s,
          SUM(committed_s) committed_s,
          SUM(utilized_s) utilized_s,
          SUM(accrual_s) accrual_s,
          SUM(paid_s) paid_s
FROM      (
SELECT    ad.fund_id fund_id,
          ad.fund_number fund_number,
          ad.start_date_active start_date,
          ad.end_date_active end_date,
          ad.start_period_name start_period,
          ad.end_period_name end_period,
          ad.category_id category_id,
          ad.status_code status,
          ad.fund_type fund_type,
          ad.parent_fund_id parent_fund_id,
          ad.country_id country,
          ad.org_id org_id,
          ad.business_unit_id business_unit_id,
          ad.set_of_books_id set_of_books_id,
          ad.currency_code_fc currency_code_fc,
          DECODE(ad.fund_type,'FIXED',ad.original_budget,'FULLY_ACCRUED',0) original_budget,
          trunc(ad.start_date_active) transaction_create_date,
          0     transfer_in,
          0     transfer_out,
          0     holdback_amt,
	  nvl(ad.currency_code_tc,'USD') from_currency,
          0 conversion_rate,
	  0 planned,
	  0 committed,
	  0 utilized,
	  0 paid,
	  'ORIGINAL_BUDGET' metric_type,
	  0 accrual,
          0 conversion_rate_s,
          0 original_budget_s,
          0 transfer_in_s,
          0 transfer_out_s,
          0 holdback_amt_s,
          0 planned_s,
          0 committed_s,
          0 utilized_s,
          0 accrual_s,
          0 paid_s
FROM      ozf_funds_all_b ad
WHERE  (  ( ad.status_date between p_start_date and p_end_date
AND       ad.start_date_active <=p_end_date
)
or ( ad.start_date_active between p_start_date and p_end_date
AND  ad.status_date<p_start_date))
AND       ad.parent_fund_id is null
AND       ad.status_code  in  ('ACTIVE','CLOSED','CANCELLED')
AND       not exists (select 1 from bim_i_budget_facts  a
                      where a.fund_id = ad.fund_id
                      and a.metric_type= 'ORIGINAL_BUDGET')
UNION ALL --transfer_in
SELECT    ad.fund_id fund_id,
          ad.fund_number fund_number,
          ad.start_date_active start_date,
          ad.end_date_active end_date,
          ad.start_period_name start_period,
          ad.end_period_name end_period,
          ad.category_id category_id,
          ad.status_code status,
          ad.fund_type fund_type,
          ad.parent_fund_id parent_fund_id,
          ad.country_id country,
          ad.org_id org_id,
          ad.business_unit_id business_unit_id,
          ad.set_of_books_id set_of_books_id,
          ad.currency_code_fc currency_code_fc,
          0 original_budget,
          trunc(bu1.approval_date) transaction_create_date,
          SUM(nvl(bu1.approved_amount,0)) transfer_in,
          0     transfer_out,
          0     holdback_amt,
	  nvl(bu1.request_currency,'USD') from_currency,
          0 conversion_rate,
	  0     planned,
	  0     committed,
	  0     utilized,
	  0     paid,
	  'TRANSFER_IN' metric_type,
	  0     accrual,
          0 conversion_rate_s,
          0 original_budget_s,
          0 transfer_in_s,
          0 transfer_out_s,
          0 holdback_amt_s,
          0 planned_s,
          0 committed_s,
          0 utilized_s,
          0 accrual_s,
          0 paid_s
   FROM   ozf_funds_all_b ad,
          ozf_act_budgets BU1
   WHERE  bu1.approval_date between p_start_date and p_end_date
   AND    bu1.transfer_type in ('TRANSFER','REQUEST')
   AND    bu1.status_code = 'APPROVED'
   AND    bu1.arc_act_budget_used_by = 'FUND'
   AND    bu1.act_budget_used_by_id = ad.fund_id
   AND    bu1.budget_source_type ='FUND'
   GROUP BY ad.fund_id,
          trunc(bu1.approval_date),
          ad.fund_number,
          ad.start_date_active ,
          ad.end_date_active ,
          ad.start_period_name ,
          ad.end_period_name ,
          ad.category_id ,
          ad.status_code ,
          ad.fund_type ,
          ad.parent_fund_id,
          ad.country_id,
          ad.business_unit_id,
          ad.org_id ,
          ad.set_of_books_id ,
          ad.currency_code_fc ,
          ad.original_budget ,
	  nvl(bu1.request_currency,'USD')
UNION ALL --transfer_out
  SELECT  ad.fund_id fund_id,
          ad.fund_number fund_number,
          ad.start_date_active start_date,
          ad.end_date_active end_date,
          ad.start_period_name start_period,
          ad.end_period_name end_period,
          ad.category_id category_id,
          ad.status_code status,
          ad.fund_type fund_type,
          ad.parent_fund_id parent_fund_id,
          ad.country_id country,
          ad.org_id org_id,
          ad.business_unit_id business_unit_id,
          ad.set_of_books_id set_of_books_id,
          ad.currency_code_fc currency_code_fc,
          0 original_budget,
          trunc(bu2.approval_date) transaction_create_date,
          0   transfer_in,
          SUM(decode(bu2.transfer_type,'TRANSFER', nvl(bu2.approved_amount,0),0))+
          SUM(decode(bu2.transfer_type,'REQUEST',  nvl(bu2.approved_amount,0),0)) transfer_out,
          SUM(decode(bu2.transfer_type, 'RESERVE', nvl(bu2.approved_amount,0),0))-
          SUM(decode(bu2.transfer_type, 'RELEASE', nvl(bu2.approved_amount,0),0)) holdback_amt,
          nvl(bu2.request_currency,'USD') from_currency,
          0 conversion_rate,
	  0     planned,
	  0     committed,
	  0     utilized,
	  0     paid,
	  'TRANSFER_OUT' metric_type,
	  0     accrual,
          0 conversion_rate_s,
          0 original_budget_s,
          0   transfer_in_s,
          0 transfer_out_s,
          0 holdback_amt_s,
          0 planned_s,
          0 committed_s,
          0 utilized_s,
          0 accrual_s,
          0 paid_s
   FROM   ozf_funds_all_b ad,
          ozf_act_budgets BU2
   WHERE  bu2.approval_date between p_start_date and p_end_date
   AND    bu2.status_code = 'APPROVED'
   AND    bu2.arc_act_budget_used_by = 'FUND'
   AND    bu2.budget_source_type='FUND'
   AND    bu2.budget_source_id = ad.fund_id
   GROUP BY ad.fund_id,
          trunc(bu2.approval_date) ,
          ad.fund_number,
          ad.start_date_active ,
          ad.end_date_active ,
          ad.start_period_name ,
          ad.end_period_name ,
          ad.category_id ,
          ad.status_code ,
          ad.fund_type ,
          ad.parent_fund_id,
          ad.country_id,
          ad.org_id ,
          ad.business_unit_id,
          ad.set_of_books_id ,
          ad.currency_code_fc ,
          ad.original_budget,
          nvl(bu2.request_currency,'USD')
UNION ALL--planned
  SELECT  ad.fund_id fund_id,
          ad.fund_number fund_number,
          ad.start_date_active start_date,
          ad.end_date_active end_date,
          ad.start_period_name start_period,
          ad.end_period_name end_period,
          ad.category_id category_id,
          ad.status_code status,
          ad.fund_type fund_type,
          ad.parent_fund_id parent_fund_id,
          ad.country_id country,
          ad.org_id org_id,
          ad.business_unit_id business_unit_id,
          ad.set_of_books_id set_of_books_id,
          ad.currency_code_fc currency_code_fc,
          0 original_budget,
          trunc(nvl(bu2.request_date,bu2.creation_date)) transaction_create_date,
          0   transfer_in,
          0 transfer_out,
          0 holdback_amt,
          nvl(bu2.request_currency,'USD') from_currency,
          0 conversion_rate,
	  SUM(nvl(bu2.request_amount,0))     planned,
	  0     committed,
	  0     utilized,
	  0     paid,
	  'PLANNED' metric_type,
	  0     accrual,
          0 conversion_rate_s,
          0 original_budget_s,
          0   transfer_in_s,
          0 transfer_out_s,
          0 holdback_amt_s,
          0 planned_s,
          0 committed_s,
          0 utilized_s,
          0 accrual_s,
          0 paid_s
   FROM   ozf_funds_all_b ad,
          ozf_act_budgets BU2
   WHERE bu2.request_date between p_start_date and p_end_date
   AND   bu2.budget_source_type='FUND'
   AND   bu2.ARC_ACT_BUDGET_USED_BY <> 'FUND'
   AND    nvl(bu2.request_date,bu2.creation_date) <=p_end_date
   AND    bu2.budget_source_id = ad.fund_id
   GROUP BY ad.fund_id,
          trunc(nvl(bu2.request_date,bu2.creation_date)) ,
          ad.fund_number,
          ad.start_date_active ,
          ad.end_date_active ,
          ad.start_period_name ,
          ad.end_period_name ,
          ad.category_id ,
          ad.status_code ,
          ad.fund_type ,
          ad.parent_fund_id,
          ad.country_id,
          ad.org_id ,
          ad.business_unit_id,
          ad.set_of_books_id ,
          ad.currency_code_fc ,
          ad.original_budget,
          nvl(bu2.request_currency,'USD')
UNION ALL--planned 2
   SELECT  ad.fund_id fund_id,
          ad.fund_number fund_number,
          ad.start_date_active start_date,
          ad.end_date_active end_date,
          ad.start_period_name start_period,
          ad.end_period_name end_period,
          ad.category_id category_id,
          ad.status_code status,
          ad.fund_type fund_type,
          ad.parent_fund_id parent_fund_id,
          ad.country_id country,
          ad.org_id org_id,
          ad.business_unit_id business_unit_id,
          ad.set_of_books_id set_of_books_id,
          ad.currency_code_fc currency_code_fc,
          0 original_budget,
          trunc(bu2.approval_date) transaction_create_date,
          0   transfer_in,
          0 transfer_out,
          0 holdback_amt,
          nvl(bu2.request_currency,'USD') from_currency,
          0 conversion_rate,
	  0-SUM(nvl(bu2.approved_amount,0))      planned,
          0     committed,
	  0     utilized,
	  0     paid,
	  'PLANNED' metric_type,
	  0     accrual,
          0 conversion_rate_s,
          0 original_budget_s,
          0   transfer_in_s,
          0 transfer_out_s,
          0 holdback_amt_s,
          0 planned_s,
          0 committed_s,
          0 utilized_s,
          0 accrual_s,
          0 paid_s
   FROM   ozf_funds_all_b ad,
          ozf_act_budgets BU2
   WHERE bu2.approval_date between p_start_date and p_end_date
   AND   bu2.arc_act_budget_used_by ='FUND'
   AND   bu2.budget_source_type<>'FUND'
   AND   bu2.status_code ='APPROVED'
   AND    bu2.act_budget_used_by_id = ad.fund_id
GROUP BY ad.fund_id,
          trunc(bu2.approval_date) ,
          ad.fund_number,
          ad.start_date_active ,
          ad.end_date_active ,
          ad.start_period_name ,
          ad.end_period_name ,
          ad.category_id ,
          ad.status_code ,
          ad.fund_type ,
          ad.parent_fund_id,
          ad.country_id,
          ad.org_id ,
          ad.business_unit_id,
          ad.set_of_books_id ,
          ad.currency_code_fc ,
          ad.original_budget,
          nvl(bu2.request_currency,'USD')
UNION ALL--committed 1
SELECT  ad.fund_id fund_id,
          ad.fund_number fund_number,
          ad.start_date_active start_date,
          ad.end_date_active end_date,
          ad.start_period_name start_period,
          ad.end_period_name end_period,
          ad.category_id category_id,
          ad.status_code status,
          ad.fund_type fund_type,
          ad.parent_fund_id parent_fund_id,
          ad.country_id country,
          ad.org_id org_id,
          ad.business_unit_id business_unit_id,
          ad.set_of_books_id set_of_books_id,
          ad.currency_code_fc currency_code_fc,
          0 original_budget,
          trunc(bu2.approval_date) transaction_create_date,
          0   transfer_in,
          0 transfer_out,
          0 holdback_amt,
          nvl(bu2.request_currency,'USD') from_currency,
          0 conversion_rate,
	  0    planned,
	  SUM(nvl(bu2.approved_amount,0))      committed,
	  0     utilized,
	  0     paid,
	  'COMMITTED' metric_type,
	  0     accrual,
          0 conversion_rate_s,
          0 original_budget_s,
          0   transfer_in_s,
          0 transfer_out_s,
          0 holdback_amt_s,
          0 planned_s,
          0 committed_s,
          0 utilized_s,
          0 accrual_s,
          0 paid_s
   FROM   ozf_funds_all_b ad,
          ozf_act_budgets BU2
   WHERE bu2.approval_date between p_start_date and p_end_date
   AND   bu2.budget_source_type ='FUND'
   AND   bu2.ARC_ACT_BUDGET_USED_BY <> 'FUND'
   AND    bu2.budget_source_id = ad.fund_id
GROUP BY ad.fund_id,
          trunc(bu2.approval_date) ,
          ad.fund_number,
          ad.start_date_active ,
          ad.end_date_active ,
          ad.start_period_name ,
          ad.end_period_name ,
          ad.category_id ,
          ad.status_code ,
          ad.fund_type ,
          ad.parent_fund_id,
          ad.country_id,
          ad.org_id ,
          ad.business_unit_id,
          ad.set_of_books_id ,
          ad.currency_code_fc ,
          ad.original_budget,
          nvl(bu2.request_currency,'USD')
    UNION ALL--committed 2
   SELECT  ad.fund_id fund_id,
          ad.fund_number fund_number,
          ad.start_date_active start_date,
          ad.end_date_active end_date,
          ad.start_period_name start_period,
          ad.end_period_name end_period,
          ad.category_id category_id,
          ad.status_code status,
          ad.fund_type fund_type,
          ad.parent_fund_id parent_fund_id,
          ad.country_id country,
          ad.org_id org_id,
          ad.business_unit_id business_unit_id,
          ad.set_of_books_id set_of_books_id,
          ad.currency_code_fc currency_code_fc,
          0 original_budget,
          trunc(bu2.approval_date) transaction_create_date,
          0   transfer_in,
          0 transfer_out,
          0 holdback_amt,
          nvl(bu2.request_currency,'USD') from_currency,
          0 conversion_rate,
	  0    planned,
	  0-SUM(nvl(bu2.approved_amount,0))      committed,
	  0     utilized,
	  0     paid,
	  'COMMITTED' metric_type,
	  0     accrual,
          0 conversion_rate_s,
          0 original_budget_s,
          0   transfer_in_s,
          0 transfer_out_s,
          0 holdback_amt_s,
          0 planned_s,
          0 committed_s,
          0 utilized_s,
          0 accrual_s,
          0 paid_s
   FROM   ozf_funds_all_b ad,
          ozf_act_budgets BU2
   WHERE bu2.approval_date between p_start_date and p_end_date
   AND   bu2.arc_act_budget_used_by ='FUND'
   AND   bu2.budget_source_type<>'FUND'
   AND   bu2.status_code ='APPROVED'
   AND    bu2.act_budget_used_by_id = ad.fund_id
GROUP BY ad.fund_id,
          trunc(bu2.approval_date) ,
          ad.fund_number,
          ad.start_date_active ,
          ad.end_date_active ,
          ad.start_period_name ,
          ad.end_period_name ,
          ad.category_id ,
          ad.status_code ,
          ad.fund_type ,
          ad.parent_fund_id,
          ad.country_id,
          ad.org_id ,
          ad.business_unit_id,
          ad.set_of_books_id ,
          ad.currency_code_fc ,
          ad.original_budget,
          nvl(bu2.request_currency,'USD')
 UNION ALL --utilized
 SELECT  ad.fund_id fund_id,
          ad.fund_number fund_number,
          ad.start_date_active start_date,
          ad.end_date_active end_date,
          ad.start_period_name start_period,
          ad.end_period_name end_period,
          ad.category_id category_id,
          ad.status_code status,
          ad.fund_type fund_type,
          ad.parent_fund_id parent_fund_id,
          ad.country_id country,
          ad.org_id org_id,
          ad.business_unit_id business_unit_id,
          ad.set_of_books_id set_of_books_id,
          ad.currency_code_fc currency_code_fc,
          0 original_budget,
          trunc(u2.creation_date) transaction_create_date,
          0   transfer_in,
          0 transfer_out,
          0 holdback_amt,
          nvl(u2.currency_code,'USD') from_currency,
          0 conversion_rate,
	  0    planned,
	  0    committed,
	  SUM(nvl(u2.amount,0))     utilized,
	  0     paid,
	  'UTILIZED' metric_type,
	  0     accrual,
          0 conversion_rate_s,
          0 original_budget_s,
          0 transfer_in_s,
          0 transfer_out_s,
          0 holdback_amt_s,
          0 planned_s,
          0 committed_s,
          0 utilized_s,
          0 accrual_s,
          0 paid_s
   FROM   ozf_funds_all_b ad,
          ozf_funds_utilized_all_b u2
   WHERE  u2.creation_date between p_start_date and p_end_date
   AND   ad.fund_id =u2.fund_id
  AND    u2.utilization_type in ('UTILIZED','ACCRUAL','ADJUSTMENT')
GROUP BY ad.fund_id,
          trunc(u2.creation_date) ,
          ad.fund_number,
          ad.start_date_active ,
          ad.end_date_active ,
          ad.start_period_name ,
          ad.end_period_name ,
          ad.category_id ,
          ad.status_code ,
          ad.fund_type ,
          ad.parent_fund_id,
          ad.country_id,
          ad.org_id ,
          ad.business_unit_id,
          ad.set_of_books_id ,
          ad.currency_code_fc ,
          ad.original_budget,
          nvl(u2.currency_code,'USD')
UNION ALL --utilized 2
 SELECT  ad.fund_id fund_id,
          ad.fund_number fund_number,
          ad.start_date_active start_date,
          ad.end_date_active end_date,
          ad.start_period_name start_period,
          ad.end_period_name end_period,
          ad.category_id category_id,
          ad.status_code status,
          ad.fund_type fund_type,
          ad.parent_fund_id parent_fund_id,
          ad.country_id country,
          ad.org_id org_id,
          ad.business_unit_id business_unit_id,
          ad.set_of_books_id set_of_books_id,
          ad.currency_code_fc currency_code_fc,
          0 original_budget,
          trunc(u2.creation_date) transaction_create_date,
          0   transfer_in,
          0 transfer_out,
          0 holdback_amt,
          nvl(u2.currency_code,'USD') from_currency,
          0 conversion_rate,
	  0    planned,
	  0    committed,
	  0-SUM(nvl(u2.amount,0))    utilized,
	  0     paid,
	  'UTILIZED' metric_type,
	  0  accrual,
          0 conversion_rate_s,
          0 original_budget_s,
          0   transfer_in_s,
          0 transfer_out_s,
          0 holdback_amt_s,
          0 planned_s,
          0 committed_s,
          0 utilized_s,
          0 accrual_s,
          0 paid_s
   FROM   ozf_funds_all_b ad,
          ozf_funds_utilized_all_b u2
   WHERE u2.creation_date between p_start_date and p_end_date
   AND   ad.fund_id =u2.fund_id
   AND   ad.fund_type='FULLY_ACCRUED'
   AND   ad.accrual_basis ='CUSTOMER'
   AND   ad.liability_flag='N'
   AND   ad.plan_id=u2.component_id
   AND   u2.component_type='OFFR'
   AND    u2.utilization_type='ACCRUAL'
GROUP BY ad.fund_id,
          trunc(u2.creation_date) ,
          ad.fund_number,
          ad.start_date_active ,
          ad.end_date_active ,
          ad.start_period_name ,
          ad.end_period_name ,
          ad.category_id ,
          ad.status_code ,
          ad.fund_type ,
          ad.parent_fund_id,
          ad.country_id,
          ad.org_id ,
          ad.business_unit_id,
          ad.set_of_books_id ,
          ad.currency_code_fc ,
          ad.original_budget,
          nvl(u2.currency_code,'USD')
UNION ALL --accrual 1
 SELECT  ad.fund_id fund_id,
          ad.fund_number fund_number,
          ad.start_date_active start_date,
          ad.end_date_active end_date,
          ad.start_period_name start_period,
          ad.end_period_name end_period,
          ad.category_id category_id,
          ad.status_code status,
          ad.fund_type fund_type,
          ad.parent_fund_id parent_fund_id,
          ad.country_id country,
          ad.org_id org_id,
          ad.business_unit_id business_unit_id,
          ad.set_of_books_id set_of_books_id,
          ad.currency_code_fc currency_code_fc,
          0 original_budget,
          trunc(u2.creation_date) transaction_create_date,
          0   transfer_in,
          0 transfer_out,
          0 holdback_amt,
          nvl(u2.currency_code,'USD') from_currency,
          0 conversion_rate,
	  0    planned,
	  0    committed,
	  0    utilized,
	  0     paid,
	  'ACCRUAL' metric_type,
	  SUM(nvl(u2.amount,0))  accrual,
          0 conversion_rate_s,
          0 original_budget_s,
          0   transfer_in_s,
          0 transfer_out_s,
          0 holdback_amt_s,
          0 planned_s,
          0 committed_s,
          0    utilized_s,
          0 accrual_s,
          0 paid_s
   FROM   ozf_funds_all_b ad,
          ozf_funds_utilized_all_b u2
   WHERE u2.creation_date between p_start_date and p_end_date
   AND   ad.fund_id =u2.fund_id
   AND   ad.fund_type='FULLY_ACCRUED'
   AND   ad.accrual_basis ='SALES'
   AND   ad.plan_id=u2.component_id
   AND   u2.component_type='OFFR'
   AND   u2.utilization_type='SALES_ACCRUAL'
GROUP BY ad.fund_id,
          trunc(u2.creation_date) ,
          ad.fund_number,
          ad.start_date_active ,
          ad.end_date_active ,
          ad.start_period_name ,
          ad.end_period_name ,
          ad.category_id ,
          ad.status_code ,
          ad.fund_type ,
          ad.parent_fund_id,
          ad.country_id,
          ad.org_id ,
          ad.business_unit_id,
          ad.set_of_books_id ,
          ad.currency_code_fc ,
          ad.original_budget,
          nvl(u2.currency_code,'USD')
UNION ALL --accrual 2
 SELECT  ad.fund_id fund_id,
          ad.fund_number fund_number,
          ad.start_date_active start_date,
          ad.end_date_active end_date,
          ad.start_period_name start_period,
          ad.end_period_name end_period,
          ad.category_id category_id,
          ad.status_code status,
          ad.fund_type fund_type,
          ad.parent_fund_id parent_fund_id,
          ad.country_id country,
          ad.org_id org_id,
          ad.business_unit_id business_unit_id,
          ad.set_of_books_id set_of_books_id,
          ad.currency_code_fc currency_code_fc,
          0 original_budget,
          trunc(u2.creation_date) transaction_create_date,
          0   transfer_in,
          0 transfer_out,
          0 holdback_amt,
          nvl(u2.currency_code,'USD') from_currency,
          0 conversion_rate,
	  0    planned,
	  0    committed,
	  0    utilized,
	  0     paid,
	  'ACCRUAL' metric_type,
	  SUM(nvl(u2.amount,0))     accrual,
          0 conversion_rate_s,
          0 original_budget_s,
          0   transfer_in_s,
          0 transfer_out_s,
          0 holdback_amt_s,
          0 planned_s,
          0 committed_s,
          0  utilized_s,
          0 accrual_s,
          0 paid_s
   FROM   ozf_funds_all_b ad,
          ozf_funds_utilized_all_b u2
   WHERE u2.creation_date between p_start_date and p_end_date
   AND   ad.fund_id =u2.fund_id
   AND   ad.fund_type='FULLY_ACCRUED'
   AND   ad.accrual_basis ='CUSTOMER'
   AND   ad.liability_flag='N'
   AND   ad.plan_id=u2.component_id
   AND   u2.component_type='OFFR'
   AND    u2.utilization_type ='ACCRUAL'
GROUP BY ad.fund_id,
          trunc(u2.creation_date) ,
          ad.fund_number,
          ad.start_date_active ,
          ad.end_date_active ,
          ad.start_period_name ,
          ad.end_period_name ,
          ad.category_id ,
          ad.status_code ,
          ad.fund_type ,
          ad.parent_fund_id,
          ad.country_id,
          ad.org_id ,
          ad.business_unit_id,
          ad.set_of_books_id ,
          ad.currency_code_fc ,
          ad.original_budget,
          nvl(u2.currency_code,'USD')
UNION ALL--paid 1
 SELECT  ad.fund_id fund_id,
          ad.fund_number fund_number,
          ad.start_date_active start_date,
          ad.end_date_active end_date,
          ad.start_period_name start_period,
          ad.end_period_name end_period,
          ad.category_id category_id,
          ad.status_code status,
          ad.fund_type fund_type,
          ad.parent_fund_id parent_fund_id,
          ad.country_id country,
          ad.org_id org_id,
          ad.business_unit_id business_unit_id,
          ad.set_of_books_id set_of_books_id,
          ad.currency_code_fc currency_code_fc,
          0 original_budget,
          trunc(u2.creation_date) transaction_create_date,
          0   transfer_in,
          0 transfer_out,
          0 holdback_amt,
          nvl(u2.currency_code,'USD') from_currency,
          0 conversion_rate,
	  0    planned,
	  0    committed,
	  0     utilized,
	  SUM(nvl(u2.amount,0))     paid,
	  'PAID' metric_type,
	  0     accrual,
          0 conversion_rate_s,
          0 original_budget_s,
          0   transfer_in_s,
          0 transfer_out_s,
          0 holdback_amt_s,
          0 planned_s,
          0 committed_s,
          0  utilized_s,
          0 accrual_s,
          0  paid_s
   FROM   ozf_funds_all_b ad,
          ozf_funds_utilized_all_b u2
   WHERE u2.creation_date between p_start_date and p_end_date
   AND   ad.fund_id =u2.fund_id
   AND    u2.utilization_type ='UTILIZED'
GROUP BY ad.fund_id,
          trunc(u2.creation_date) ,
          ad.fund_number,
          ad.start_date_active ,
          ad.end_date_active ,
          ad.start_period_name ,
          ad.end_period_name ,
          ad.category_id ,
          ad.status_code ,
          ad.fund_type ,
          ad.parent_fund_id,
          ad.country_id,
          ad.org_id ,
          ad.business_unit_id,
          ad.set_of_books_id ,
          ad.currency_code_fc ,
          ad.original_budget,
          nvl(u2.currency_code,'USD')
UNION ALL--paid 2, based on 11.5.9
 SELECT   ad.fund_id fund_id,
          ad.fund_number fund_number,
          ad.start_date_active start_date,
          ad.end_date_active end_date,
          ad.start_period_name start_period,
          ad.end_period_name end_period,
          ad.category_id category_id,
          ad.status_code status,
          ad.fund_type fund_type,
          ad.parent_fund_id parent_fund_id,
          ad.country_id country,
          ad.org_id org_id,
          ad.business_unit_id business_unit_id,
          ad.set_of_books_id set_of_books_id,
          ad.currency_code_fc currency_code_fc,
          0 original_budget,
          trunc(cla.claim_date) transaction_create_date,
          0   transfer_in,
          0 transfer_out,
          0 holdback_amt,
          nvl(cuti.currency_code,'USD') from_currency,
          0 conversion_rate,
	  0    planned,
	  0    committed,
	  0     utilized,
	  SUM(nvl(cuti.amount,0))     paid,
	  'PAID' metric_type,
	  0     accrual,
          0 conversion_rate_s,
          0 original_budget_s,
          0   transfer_in_s,
          0 transfer_out_s,
          0 holdback_amt_s,
          0 planned_s,
          0 committed_s,
          0  utilized_s,
          0 accrual_s,
          0 paid_s
   FROM   ozf_funds_all_b ad,
          ozf_funds_utilized_all_b u2,
	  ozf_claim_lines_util_all cuti,
          ozf_claim_lines_all cln,
          ozf_claims_all cla
   WHERE cla.claim_date between p_start_date and p_end_date
   AND   ad.fund_id =u2.fund_id
   AND   u2.utilization_id= cuti.utilization_id
   AND   u2.utilization_type IN ('ACCRUAL','SALES_ACCRUAL','ADJUSTMENT')
   AND   cuti.claim_line_id= cln.claim_line_id
   AND   cln.claim_id = cla.claim_id
   AND   cla.status_code = 'CLOSED'
GROUP BY ad.fund_id,
          trunc(cla.claim_date) ,
          ad.fund_number,
          ad.start_date_active ,
          ad.end_date_active ,
          ad.start_period_name ,
          ad.end_period_name ,
          ad.category_id ,
          ad.status_code ,
          ad.fund_type ,
          ad.parent_fund_id,
          ad.country_id,
          ad.org_id ,
          ad.business_unit_id,
          ad.set_of_books_id ,
          ad.currency_code_fc ,
          ad.original_budget,
          nvl(cuti.currency_code,'USD')
)
   GROUP BY
          fund_id,
          transaction_create_date,
          fund_number,
          start_date,
          end_date,
          start_period,
          end_period,
          category_id,
          status,
          fund_type,
          parent_fund_id,
          country,
          org_id,
          business_unit_id,
          set_of_books_id,
          currency_code_fc,
          original_budget,
	  from_currency,
	  conversion_rate,
	  metric_type,
           conversion_rate_s
           )inner;

 BIS_COLLECTION_UTILITIES.log('BIM_I_BUDGET_FACTS:Inserting into BIM_I_BGT_RATES');
 --insert into bim_i_mkt_rates
INSERT
INTO BIM_I_BGT_RATES BRT(tc_code,
                         trx_date,
			 prim_conversion_rate,
			 sec_conversion_rate)
SELECT from_currency,
       transaction_create_date,
       FII_CURRENCY.get_rate(from_currency,l_global_currency_code,transaction_create_date,l_pgc_rate_type),
       FII_CURRENCY.get_rate(from_currency,l_secondary_currency_code,transaction_create_date,l_sgc_rate_type)
FROM (select distinct from_currency from_currency,
                      transaction_create_date transaction_create_date
       from bim_i_budget_facts_stg);

     l_check_missing_rate := Check_Missing_Rates (p_start_date);
     if (l_check_missing_rate = -1) then
     DELETE from BIM_I_BUDGET_FACTS_stg  where transaction_create_date>= p_start_date;
	 commit;
         x_return_status := FND_API.G_RET_STS_ERROR;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    end if;
     BIS_COLLECTION_UTILITIES.log('BIM_I_BUDGET_FACTS:Incremental Load:after calling checking_missing_rates');

  --insert into facts table
  INSERT /*+ append parallel */
      INTO BIM_I_BUDGET_FACTS CDF(
        creation_date
        ,last_update_date
        ,created_by
        ,last_updated_by
        ,last_update_login
        ,fund_id
        ,parent_fund_id
        ,fund_number
        ,start_date
        ,end_date
        ,start_period
        ,end_period
        ,set_of_books_id
        ,fund_type
        --,region
        ,country
        ,org_id
        ,category_id
        ,status
        ,original_budget
        ,transfer_in
        ,transfer_out
        ,holdback_amt
        ,currency_code_fc
        ,delete_flag
        ,transaction_create_date
        ,business_unit_id
	,from_currency
	,conversion_rate
	,planned
	,committed
	,utilized
	,paid
	,metric_type
	,accrual
         ,conversion_rate_s
         ,original_budget_s
         ,transfer_in_s
         ,transfer_out_s
         ,holdback_amt_s
         ,planned_s
         ,committed_s
         ,utilized_s
         ,accrual_s
         ,paid_s)
SELECT  /*+ parallel */
       sysdate,
       sysdate,
       l_user_id,
       l_user_id,
       l_user_id,
       inner.fund_id,
       inner.parent_fund_id,
       inner.fund_number,
       inner.start_date,
       inner.end_date,
       inner.start_period,
       inner.end_period,
       inner.set_of_books_id,
       inner.fund_type,
       --inner.region,
       inner.country,
       inner.org_id,
       inner.category_id,
       inner.status,
       inner.original_budget*prim_conversion_rate,
       inner.transfer_in*prim_conversion_rate,
       inner.transfer_out*prim_conversion_rate,
       inner.holdback_amt*prim_conversion_rate,
       inner.currency_code_fc,
       'N',
       inner.transaction_create_date,
       inner.business_unit_id,
       inner.from_currency,
       inner.conversion_rate,
       inner.planned*prim_conversion_rate,
       inner.committed*prim_conversion_rate,
       inner.utilized*prim_conversion_rate,
       inner.paid*prim_conversion_rate,
       inner.metric_type,
       inner.accrual*prim_conversion_rate,
       inner.conversion_rate_s,
       inner.original_budget*sec_conversion_rate,
       inner.transfer_in*sec_conversion_rate,
       inner.transfer_out*sec_conversion_rate,
       inner.holdback_amt*sec_conversion_rate,
       inner.planned*sec_conversion_rate,
       inner.committed*sec_conversion_rate,
       inner.utilized*sec_conversion_rate,
       inner.accrual*sec_conversion_rate,
       inner.paid*sec_conversion_rate
FROM bim_i_budget_facts_stg inner, bim_i_bgt_rates rt
where inner.from_currency = rt.tc_code
and inner.transaction_create_date= rt.trx_date;

-- Analyze the daily facts table
   DBMS_STATS.gather_table_stats('BIM','BIM_I_BUDGET_FACTS', estimate_percent => 5,
                                  degree => 8, granularity => 'GLOBAL', cascade =>TRUE);

 --dbms_output.put_line('b4 inserting log');
 BIS_COLLECTION_UTILITIES.log('BIM_I_BUDGET_FACTS:Before Insert into log.');
    BEGIN
    IF (Not BIS_COLLECTION_UTILITIES.setup('BUDGET_FACTS')) THEN
    RAISE FND_API.G_EXC_ERROR;
    return;
    END IF;
    BIS_COLLECTION_UTILITIES.WRAPUP(
                  p_status => TRUE ,
                  p_period_from =>p_start_date,
                  p_period_to => sysdate
                  );
   Exception when others then
     Rollback;
     BIS_COLLECTION_UTILITIES.WRAPUP(
                  p_status => FALSE,
                   p_period_from =>p_start_date,
                  p_period_to =>sysdate
                  );
     RAISE FND_API.G_EXC_ERROR;
     END;
     BIS_COLLECTION_UTILITIES.log('BIM_I_BUDGET_FACTS:After Insert into log.');
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_msg_PUB.Count_And_Get (
          --  p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

    BIS_COLLECTION_UTILITIES.log('SUBSEQUENT_LOAD:IN EXPECTED EXCEPTION '||sqlerrm(sqlcode));
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     -- Standard call to get message count and if count=1, get the message
     FND_msg_PUB.Count_And_Get (
            --p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

    ams_utility_pvt.write_conc_log('BIM_I_BUDGET_FACTS:SUBSEQUENT_LOAD:IN UNEXPECTED EXCEPTION '||sqlerrm(sqlcode));
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
    BIS_COLLECTION_UTILITIES.log('SUBSEQUENT_LOAD:IN other EXCEPTION '||sqlerrm(sqlcode));
END SUB_LOAD;
END BIM_I_BGT_FACTS_PKG;

/
