--------------------------------------------------------
--  DDL for Package Body BIM_I_LEAD_FACTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIM_I_LEAD_FACTS_PKG" AS
/*$Header: bimildfb.pls 120.1 2005/10/11 05:38:48 sbassi noship $*/

g_pkg_name  CONSTANT  VARCHAR2(20) := 'BIM_I_LEAD_FACTS_PKG';
g_file_name CONSTANT  VARCHAR2(20) := 'bimildfb.pls';
l_global_currency_code varchar2(20);


-- Checks for any missing currency from Lead facts table

FUNCTION Check_Missing_Rates (p_start_date IN Date)
Return NUMBER
AS
 l_global_rate   Varchar2(30);
 l_cnt_miss_rate Number := 0;
 l_msg_name      Varchar2(40);

 CURSOR C_missing_rates
 IS
   SELECT from_currency from_currency,
          decode(conversion_rate,-3,to_date('01/01/1999','MM/DD/RRRR'),lead_creation_date) lead_creation_date
   FROM bim_i_lead_facts_stg
   WHERE (conversion_rate < 0
   OR conversion_rate IS NULL)
   AND from_currency is not null
   AND lead_creation_date >= p_start_date
   ORDER BY from_currency;
BEGIN
 l_msg_name := 'BIS_DBI_CURR_NO_LOAD';
 SELECT COUNT(*) INTO l_cnt_miss_rate FROM bim_i_lead_facts_stg
 WHERE
 (conversion_rate < 0
 OR conversion_rate IS NULL)
 AND from_currency is not null
 AND lead_creation_date >= p_start_date;

 l_global_rate := BIS_COMMON_PARAMETERS.Get_Rate_Type;

 If(l_cnt_miss_rate > 0 )
 Then
   FND_MESSAGE.Set_Name('FII',l_msg_name);
   BIS_COLLECTION_UTILITIES.debug(l_msg_name||': '||FND_MESSAGE.get);
   BIS_COLLECTION_UTILITIES.log('Conversion rate could not be found for the given currency. Please check output file for more details' );
   BIS_COLLECTION_UTILITIES.writeMissingRateHeader;


   l_global_currency_code := bis_common_parameters.get_currency_code;
   FOR rate_record in C_missing_rates
   LOOP
		BIS_COLLECTION_UTILITIES.writeMissingRate(
		p_rate_type => l_global_rate,
        	p_from_currency => rate_record.from_currency,
        	p_to_currency => l_global_currency_code,
        	p_date => rate_record.lead_creation_date);
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

------------------------------------------------------------------------------------------------
----
----This procedure finds out if the user is trying to run first_load or subsequent load
----and calls the load_data procedure with the specific parameters to each type of load
----
------------------------------------------------------------------------------------------------

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
    --,p_mode                  IN  VARCHAR2
    ) IS

    l_object_name             CONSTANT VARCHAR2(80) := 'BIM_LEADS';
    l_conc_start_date         DATE;
    l_conc_end_date           DATE;
    l_start_date              DATE;
    l_end_date                DATE;
    l_user_id                 NUMBER := FND_GLOBAL.USER_ID();
    l_api_version_number      CONSTANT NUMBER       := 1.0;
    l_api_name                CONSTANT VARCHAR2(30) := 'BIM_I_LEAD_FACTS_PKG';
    l_mesg_text		      VARCHAR2(100);
    l_load_type	              VARCHAR2(100);
    l_global_date             DATE;
    l_missing_date            BOOLEAN := FALSE;
    l_sysdate		      DATE;


BEGIN

    l_global_date:=  bis_common_parameters.get_global_start_date;

     IF NOT bis_collection_utilities.setup(l_object_name)  THEN
        bis_collection_utilities.log('Object BIM_LEADS Not Setup Properly');
        RAISE FND_API.G_EXC_ERROR;
     END IF;
     bis_collection_utilities.log('Start of the Lead Facts Program');

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

        bis_collection_utilities.get_last_refresh_dates(l_object_name,
                                                        l_conc_start_date,
                                                        l_conc_end_date,
                                                        l_start_date,
                                                        l_end_date);
        IF (l_end_date IS NULL) THEN

                IF (p_start_date  IS NULL) THEN
                  bis_collection_utilities.log('Please run the Upadate Leads First Time Base Summary concurrent program before running this');
                  RAISE FND_API.G_EXC_ERROR;
                END IF;

                --- Validate Time Dimension Tables
                fii_time_api.check_missing_date (greatest(l_global_date,p_start_date), sysdate, l_missing_date);
                IF (l_missing_date) THEN
                   bis_collection_utilities.log('Time dimension has atleast one missing date between ' || greatest(l_global_date,p_start_date) || ' and ' || sysdate);
                   RAISE FND_API.G_EXC_ERROR;
                END IF;


                l_load_type  := 'FIRST_LOAD';

                FIRST_LOAD(p_start_date => greatest(l_global_date,p_start_date)
                     ,p_end_date =>  sysdate
                     ,p_api_version_number => l_api_version_number
                     ,p_init_msg_list => FND_API.G_FALSE
                     ,x_msg_count => x_msg_count
                     ,x_msg_data   => x_msg_data
                     ,x_return_status => x_return_status
                );

        ELSE
                --i.e Incremental has to be executed.
		IF p_truncate_flg = 'Y' THEN

			l_load_type  := 'FIRST_LOAD';
			l_sysdate := sysdate;

			FIRST_LOAD(p_start_date => greatest(l_global_date,p_start_date)
					,p_end_date =>  l_sysdate
					,p_api_version_number => l_api_version_number
					,p_init_msg_list => FND_API.G_FALSE
					,x_msg_count => x_msg_count
					,x_msg_data   => x_msg_data
					,x_return_status => x_return_status
					);
		ELSE
			--- Validate Time Dimension Tables
		        fii_time_api.check_missing_date (l_end_date, sysdate, l_missing_date);
			IF (l_missing_date) THEN
	                   bis_collection_utilities.log('Time dimension has atleast one missing date between ' || l_end_date || ' and ' || sysdate);
		           RAISE FND_API.G_EXC_ERROR;
			END IF;

			l_load_type  := 'SUBSEQUENT_LOAD';

			INCREMENTAL_LOAD(p_start_date => l_end_date +1/86400 -- add one second
			,p_end_date =>  sysdate
			,p_global_date =>l_global_date
			,p_api_version_number => l_api_version_number
			,p_init_msg_list => FND_API.G_FALSE
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
     FND_msg_PUB.Count_And_Get (
           -- p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

END POPULATE;


--------------------------------------------------------------------------------------------------
-- This procedure will populates all the data required into facts table for the first load.
--
--                      PROCEDURE  FIRST_LOAD
--------------------------------------------------------------------------------------------------

PROCEDURE FIRST_LOAD
( p_start_date            IN  DATE
 ,p_end_date              IN  DATE
 ,p_api_version_number    IN  NUMBER
 ,p_init_msg_list         IN  VARCHAR2
 ,x_msg_count             OUT NOCOPY NUMBER
 ,x_msg_data              OUT NOCOPY VARCHAR2
 ,x_return_status         OUT NOCOPY VARCHAR2
)
IS
    l_user_id                     NUMBER := FND_GLOBAL.USER_ID();
    l_api_version_number   	  CONSTANT NUMBER       := 1.0;
    l_api_name             	  CONSTANT VARCHAR2(30) := 'FIRST_LOAD';
    l_table_name		  VARCHAR2(100);
    l_conv_opp_status             VARCHAR2(30);
    l_dead_status                 VARCHAR2(30);
    l_check_missing_rate          NUMBER;
    l_stmt                        VARCHAR2(50);
    l_cert_level                  VARCHAR2(3);

    l_status       VARCHAR2(5);
    l_industry     VARCHAR2(5);
    l_schema       VARCHAR2(30);
    l_return       BOOLEAN;

   TYPE  generic_number_table IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

   TYPE  generic_char_table IS TABLE OF VARCHAR2(100) INDEX BY BINARY_INTEGER;

   i			NUMBER;
   l_min_start_date     DATE;

   l_org_id 			number;

   CURSOR   get_org_id IS
   SELECT   (TO_NUMBER(SUBSTRB(USERENV('CLIENT_INFO'), 1, 10)))
   FROM     dual;
   l_sysdate date;

BEGIN

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

   --Get status codes for 'opportunity created' and 'dead lead'
   l_conv_opp_status := nvl(FND_PROFILE.Value('AS_LEAD_LINK_STATUS'),'CONVERTED_TO_OPPORTUNITY');
   l_dead_status     := nvl(FND_PROFILE.Value('AS_DEAD_LEAD_STATUS'),'DEAD_LEAD');

   --Find if the certification level is implemented or not
   l_cert_level := nvl(FND_PROFILE.Value('HZ_DISPLAY_CERT_STATUS'),'NO');



   /* Dropping INdexes */
      BIM_UTL_PKG.DROP_INDEX('BIM_I_LEAD_FACTS');

   /* Truncate Staging table */
     EXECUTE IMMEDIATE 'TRUNCATE TABLE '||l_schema||'.bim_i_lead_facts_stg';


      l_table_name := 'BIM_I_LEAD_FACTS';
      bis_collection_utilities.log('Running Initial Load of Lead Facts');

      l_sysdate :=sysdate;

      INSERT /*+ append parallel */
      INTO bim_i_lead_facts_stg LDF
      (
              lead_id
	      ,lead_line_id
              ,group_id
              ,resource_id
              ,lead_rank_id
              ,lead_source
              ,lead_status
              ,lead_country
              ,source_code_id
	      ,interest_type_id
	      ,primary_interest_code_id
	      ,secondary_interest_code_id
	      ,item_id
	      ,organization_id
              ,lead_creation_date
              ,lead_touched_date
              ,lead_dead_date
	     ,channel_code
--	     ,lead_amount
--	     ,currency_code
	     ,close_reason
	     ,accept_flag
	     ,qualified_flag
	     ,source_primary_reference
	     ,source_secondary_reference
	     ,customer_id
	     ,cust_category
	     ,status_open_flag
	     ,lead_rank_score
	     ,expiration_date
--	     ,conversion_rate
--	     ,from_currency
	     ,product_category_id
	     ,CUSTOMER_FLAG
	     ,lead_name
      )
SELECT
              x.sales_lead_id lead_id
	      ,y.sales_lead_line_id lead_line_id
              ,x.assign_sales_group_id group_id
              ,x.assign_to_salesforce_id resource_id
              ,x.lead_rank_id lead_rank_id
              ,x.source_system lead_source
              ,x.status_code lead_status
              ,x.country lead_country
	      ,x.source_promotion_id source_code_id
	      ,y.interest_type_id interest_type_id
	      ,y.primary_interest_code_id primary_interest_code_id
	      ,y.secondary_interest_code_id secondary_interest_code_id
	      ,nvl(y.inventory_item_id,-1) item_id
	      ,decode(y.inventory_item_id,null,-1,nvl(y.organization_id,-1)) organization_id
              ,trunc(x.creation_date) lead_creation_date
              ,(CASE
                   WHEN (x.last_update_date > (x.creation_date+1/1440)) THEN trunc(x.last_update_date)
                   ELSE null
                END
              ) lead_touched_date
              ,decode(x.status_code,l_dead_status,trunc(x.last_update_date),null) lead_dead_date
	     ,x.channel_code channel_code
--	     ,fii_currency.convert_global_amt_primary(nvl(x.currency_code,'USD'),nvl(x.total_amount,0),X.creation_date) lead_amount
--	     ,x.currency_code currency_code
	     ,x.close_reason close_reason
	     ,x.accept_flag accept_flag
	     ,x.qualified_flag qualified_flag
	     ,x.source_primary_reference source_primary_reference
	     ,x.source_secondary_reference source_secondary_reference
	     ,x.customer_id customer_id
	     ,NULL  cust_category
	     ,x.status_open_flag status_open_flag
	     ,x.lead_rank_score lead_rank_score
	     ,x.expiration_date expiration_date
--	     ,fii_currency.get_global_rate_primary(nvl(x.currency_code,'USD'),x.creation_date) conversion_rate
--             ,nvl(x.currency_code,'USD') from_currency
	     ,y.category_id product_category_id
	     ,'N' CUSTOMER_FLAG
	      ,x.DESCRIPTION
FROM
               as_sales_leads X
              ,as_sales_lead_lines Y
WHERE
              X.creation_date between p_start_date and l_sysdate
              AND   X.sales_lead_id = Y.sales_lead_id(+)      ;




COMMIT;

/*l_check_missing_rate := Check_Missing_Rates (p_start_date);
if (l_check_missing_rate = -1) then
 BIS_COLLECTION_UTILITIES.debug('before truncating first time load' );
      l_stmt := 'TRUNCATE table '||l_schema||'.bim_i_lead_facts_stg';
      EXECUTE IMMEDIATE l_stmt;
      commit;

x_return_status := FND_API.G_RET_STS_ERROR;
RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
end if;
*/

--update to get customer category

/*update bim.bim_i_lead_facts_stg stg
			set stg.cust_category
			= (select b.class_code from  hz_code_assignments  b
			  where
			     stg.customer_id=b.OWNER_TABLE_ID
			     and b.OWNER_TABLE_NAME='HZ_PARTIES'
			     and b.Primary_flag = 'Y'
                 and nvl(b.end_date_active,trunc(sysdate)) > = trunc(sysdate)
                 and b.CLASS_CATEGORY='CUSTOMER_CATEGORY'
		 and b.status='A')
where
      exists
       (select b.class_code from  hz_code_assignments  b
			  where
			     stg.customer_id=b.OWNER_TABLE_ID
			     and b.OWNER_TABLE_NAME='HZ_PARTIES'
			     and b.Primary_flag = 'Y'
                 and nvl(b.end_date_active,trunc(sysdate)) > = trunc(sysdate)
                 and b.CLASS_CATEGORY='CUSTOMER_CATEGORY'
		 and b.status='A');
*/

update bim_i_lead_facts_stg stg
                        set stg.cust_category
                        = (select b.class_code from  hz_code_assignments  b
                          where
                             stg.customer_id=b.OWNER_TABLE_ID
                             and b.OWNER_TABLE_NAME='HZ_PARTIES'
                             and b.Primary_flag = 'Y'
                 and nvl(b.end_date_active,trunc(l_sysdate)) > = trunc(l_sysdate)
                 and b.CLASS_CATEGORY='CUSTOMER_CATEGORY'
                 and b.status='A'--Active
                 and b.START_DATE_ACTIVE =
                      ( select max(START_DATE_ACTIVE) from hz_code_assignments  c
                         where
                            c.OWNER_TABLE_NAME='HZ_PARTIES'
                            and c.CLASS_CATEGORY='CUSTOMER_CATEGORY'
                            and c.Primary_flag = 'Y'
                            and nvl(c.end_date_active,trunc(l_sysdate)) > = trunc(l_sysdate)
                            and c.status='A'
                            and b.OWNER_TABLE_ID=c.OWNER_TABLE_ID)
                                                        )
where
      exists
       (select b.class_code from  hz_code_assignments  b
                          where
                             stg.customer_id=b.OWNER_TABLE_ID
                             and b.OWNER_TABLE_NAME='HZ_PARTIES'
                             and b.Primary_flag = 'Y'
                 and nvl(b.end_date_active,trunc(l_sysdate)) > = trunc(l_sysdate)
                 and b.CLASS_CATEGORY='CUSTOMER_CATEGORY'
                 and b.status='A'--Active
                 and b.START_DATE_ACTIVE =
                      ( select max(START_DATE_ACTIVE) from hz_code_assignments  c
                         where
                            c.OWNER_TABLE_NAME='HZ_PARTIES'
                            and c.CLASS_CATEGORY='CUSTOMER_CATEGORY'
                            and c.Primary_flag = 'Y'
                            and nvl(c.end_date_active,trunc(l_sysdate)) > = trunc(l_sysdate)
                            and c.status='A'
                            and b.OWNER_TABLE_ID=c.OWNER_TABLE_ID) );

--update customer flag


    IF l_cert_level = 'YES' THEN

          UPDATE bim_i_lead_facts_stg stg SET CUSTOMER_FLAG='Y'
          WHERE
          EXISTS
          (SELECT 1 from HZ_CUST_ACCOUNTS a,hz_parties b
          WHERE a.party_id=stg.customer_id
          AND   stg.lead_creation_date >= trunc(a.creation_date)
          AND   a.party_id=b.party_id
          AND   b.certification_level is not null);

   ELSE

           UPDATE bim_i_lead_facts_stg stg set CUSTOMER_FLAG='Y'
           WHERE
           EXISTS
           (SELECT 1 from HZ_CUST_ACCOUNTS a
           WHERE a.party_id=stg.customer_id
           AND   stg.lead_creation_date >= trunc(a.creation_date)
           );

   END IF;

      BIS_COLLECTION_UTILITIES.log('Truncating Facts Table');

      EXECUTE IMMEDIATE 'TRUNCATE TABLE '||l_schema||'.bim_i_lead_facts';

      BIS_COLLECTION_UTILITIES.deleteLogForObject('BIM_LEADS');

      INSERT /*+ append parallel */
      INTO bim_i_lead_facts LDF
      (
              creation_date
              ,last_update_date
              ,created_by
              ,last_updated_by
              ,last_update_login
              ,lead_id
	      ,lead_line_id
              ,group_id
              ,resource_id
              ,lead_rank_id
              ,lead_source
              ,lead_status
              ,lead_region
              ,lead_country
              ,source_code_id
              ,object_type
	      ,object_id
              ,child_object_type
	      ,child_object_id
              ,object_region
              ,object_country
              ,object_status
              ,object_purpose
              ,child_object_region
              ,child_object_country
              ,child_object_status
              ,child_object_purpose
              ,object_category_id
              ,business_unit_id
              ,lead_creation_date
              ,lead_touched_date
              ,lead_dead_date
              ,item_id
	      ,organization_id
	      ,channel_code
	     ,lead_amount
	     ,close_reason
	     ,accept_flag
	     ,qualified_flag
	     ,source_primary_reference
	     ,source_secondary_reference
	     ,customer_id
	     ,cust_category
	     ,status_open_flag
	     ,lead_rank_score
	     ,expiration_date
             ,product_category_id
	     ,CUSTOMER_FLAG
	     ,lead_name
      )
SELECT
               sysdate                          creation_date
	      ,sysdate                          last_update_date
	      ,-1                               created_by
	      ,-1                               last_updated_by
	      ,-1                               last_update_login
              ,x.lead_id                        lead_id
	      ,x.lead_line_id                   lead_line_id
              ,x.group_id                       group_id
              ,x.resource_id                    resource_id
              ,x.lead_rank_id                   lead_rank_id
              ,x.lead_source                    lead_source
              ,x.lead_status                    lead_status
	      ,t.parent_territory_code          lead_region
              ,x.lead_country                   lead_country
              ,a.source_code_id                 source_code_id
              ,a.object_type                    object_type
              ,a.object_id                      object_id
              ,a.child_object_type              child_object_type
              ,a.child_object_id                child_object_id
              ,a.object_region                  object_region
              ,a.object_country                 object_country
              ,a.object_status                  object_status
              ,a.object_purpose                 object_purpose
              ,a.child_object_region            child_object_region
              ,a.child_object_country           child_object_country
              ,a.child_object_status            child_object_status
              ,a.child_object_purpose           child_object_purpose
              ,a.category_id                    object_category_id
              ,a.business_unit_id               business_unit_id
              ,x.lead_creation_date             lead_creation_date
              ,x.lead_touched_date              lead_touched_date
              ,x.lead_dead_date                 lead_dead_date
	      ,x.item_id                        item_id
	      ,x.organization_id                organization_id
	      ,x.channel_code			channel_code
	     ,x.lead_amount			lead_amount
	     ,x.close_reason			close_reason
	     ,x.accept_flag			accept_flag
	     ,x.qualified_flag			qualified_flag
	     ,x.source_primary_reference	source_primary_reference
	     ,x.source_secondary_reference	source_secondary_reference
	     ,x.customer_id			customer_id
	     ,x.cust_category			cust_category
	     ,x.status_open_flag		status_open_flag
	     ,x.lead_rank_score			lead_rank_score
	     ,x.expiration_date			expiration_date
	     ,nvl(x.product_category_id,-1)    product_category_id
	     ,x.customer_flag			customer_flag
	     ,x.lead_name                       Lead_name
FROM
              bim_i_lead_facts_stg X
              ,bim_i_source_codes A
              ,bis_territory_hierarchies T
WHERE
           X.source_code_id = A.source_code_id(+)
          AND T.parent_territory_type(+) = 'AREA'
          AND T.child_territory_type(+) = 'COUNTRY'
          AND T.child_territory_code(+) = X.lead_country
;

COMMIT;




     --update date for converted leads
     UPDATE bim_i_lead_facts facts
        SET  (facts.lead_converted_date, facts.lead_touched_date)
                   = (SELECT TRUNC(MIN(slo.creation_date)), TRUNC(MIN(slo.creation_date))
                        FROM
                          as_sales_lead_opportunity slo
                        WHERE
                          slo.creation_date between p_start_date and l_sysdate
                          AND slo.sales_lead_id = facts.lead_id
                          AND facts.lead_dead_date is null
                      )
        WHERE
           EXISTS (SELECT 1
                      FROM
                        as_sales_lead_opportunity slo
                      WHERE
                            slo.creation_date between p_start_date and l_sysdate
                        AND slo.sales_lead_id = facts.lead_id
                        AND facts.lead_dead_date is null
                   );
       COMMIT;



     --update lead_closed_date for closed leads other than dead and converted
     UPDATE bim_i_lead_facts facts
        SET  (facts.lead_closed_date, facts.lead_touched_date)
                   = (SELECT TRUNC(MIN(hist.creation_date)), TRUNC(MIN(hist.creation_date))
			FROM
                          as_sales_leads_log hist
                          ,as_statuses_b st
			WHERE
			      hist.last_update_date between p_start_date and l_sysdate
                          AND hist.status_code not in (l_conv_opp_status, l_dead_status)
                          AND hist.status_code = st.status_code
                          AND st.opp_open_status_flag = 'N'
			  AND hist.sales_lead_id = facts.lead_id
			  AND hist.status_code = facts.lead_status
                          AND facts.lead_converted_date is null
                          AND facts.lead_dead_date is null
                     )
        WHERE
           EXISTS (SELECT 1
		      FROM
                        as_sales_leads_log hist
                        ,as_statuses_b st
		      WHERE
			    hist.last_update_date between p_start_date and l_sysdate
                        AND hist.status_code not in (l_conv_opp_status, l_dead_status)
                        AND hist.status_code = st.status_code
                        AND st.opp_open_status_flag = 'N'
			AND hist.sales_lead_id = facts.lead_id
			AND hist.status_code = facts.lead_status
                        AND facts.lead_converted_date is null
                        AND facts.lead_dead_date is null
                       );
COMMIT;



     --update touched_date for leads that does not have history
     UPDATE bim_i_lead_facts facts
        SET  facts.lead_touched_date
            =(CASE
                WHEN lead_dead_date is not null THEN lead_dead_date
                WHEN lead_converted_date is not null THEN lead_converted_date
                WHEN lead_closed_date is not null THEN lead_closed_date
                ELSE null
              END
             )
     where lead_touched_date is  null;

     COMMIT;




     EXECUTE IMMEDIATE 'TRUNCATE TABLE '||l_schema||'.bim_i_lead_facts_stg';

     --EXECUTE IMMEDIATE 'TRUNCATE TABLE '||l_schema||'.mlog$_bim_i_lead_facts';

     --dbms_output.put_line(p_start_date);

     --dbms_output.put_line(p_start_date);
     --dbms_output.put_line(p_end_date);
     bis_collection_utilities.wrapup(p_status => TRUE
                        ,p_count => sql%rowcount
                        ,p_period_from => p_start_date
                        ,p_period_to  => l_sysdate
                        );

     /***************************************************************/


     bis_collection_utilities.log('Before Analyze of the table BIM_I_LEAD_FACTS');

   --Analyze the facts table
     DBMS_STATS.gather_table_stats('BIM','BIM_I_LEAD_FACTS', estimate_percent => 5,
                                  degree => 8, granularity => 'GLOBAL', cascade =>TRUE);

   /* Recreating Indexes */
      BIM_UTL_PKG.CREATE_INDEX('BIM_I_LEAD_FACTS');

     bis_collection_utilities.log('Successful Completion of Leads Facts Program');


EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_msg_PUB.Count_And_Get (
          --  p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

    ams_utility_pvt.write_conc_log('BIM_I_LEAD_FACTS_PKG:FIRST_LOAD:IN EXPECTED EXCEPTION '||sqlerrm(sqlcode));

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     -- Standard call to get message count and if count=1, get the message
     FND_msg_PUB.Count_And_Get (
            --p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

    ams_utility_pvt.write_conc_log('BIM_I_LEAD_FACTS_PKG:FIRST_LOAD:IN UNEXPECTED EXCEPTION '||sqlerrm(sqlcode));

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

    ams_utility_pvt.write_conc_log('BIM_I_LEAD_FACTS_PKG:FIRST_LOAD:IN OTHERS EXCEPTION '||sqlerrm(sqlcode));


END FIRST_LOAD;

--------------------------------------------------------------------------------------------------
-- This procedure will populates all the data required into facts table for incremental load.
--
--                      PROCEDURE  INCREMENTAL_LOAD
--------------------------------------------------------------------------------------------------

PROCEDURE INCREMENTAL_LOAD
( p_start_date            IN  DATE
 ,p_end_date              IN  DATE
 ,p_global_date           IN  DATE
 ,p_api_version_number    IN  NUMBER
 ,p_init_msg_list         IN  VARCHAR2
 ,x_msg_count             OUT NOCOPY NUMBER
 ,x_msg_data              OUT NOCOPY VARCHAR2
 ,x_return_status         OUT NOCOPY VARCHAR2
)
IS
    l_user_id                     NUMBER := FND_GLOBAL.USER_ID();
    l_api_version_number   	  CONSTANT NUMBER       := 1.0;
    l_api_name             	  CONSTANT VARCHAR2(30) := 'INCREMENTAL_LOAD';
    l_table_name		  VARCHAR2(100);
    l_conv_opp_status             VARCHAR2(30);
    l_dead_status                 VARCHAR2(30);
    l_check_missing_rate          NUMBER;
    l_stmt                        VARCHAR2(50);
    l_cert_level                  VARCHAR2(3);

   TYPE  generic_number_table IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

   TYPE  generic_char_table IS TABLE OF VARCHAR2(100) INDEX BY BINARY_INTEGER;

   i			NUMBER;
   l_min_start_date     DATE;

   l_org_id 			number;

   CURSOR   get_org_id IS
   SELECT   (TO_NUMBER(SUBSTRB(USERENV('CLIENT_INFO'), 1, 10)))
   FROM     dual;

    l_status       VARCHAR2(5);
    l_industry     VARCHAR2(5);
    l_schema       VARCHAR2(30);
    l_return       BOOLEAN;
    l_sysdate      date;
BEGIN
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

   --Get status codes for 'opportunity created' and 'dead lead'
   l_conv_opp_status := nvl(FND_PROFILE.Value('AS_LEAD_LINK_STATUS'),'CONVERTED_TO_OPPORTUNITY');
   l_dead_status     := nvl(FND_PROFILE.Value('AS_DEAD_LEAD_STATUS'),'DEAD_LEAD');


   --Find if the certification level is implemented or not
   l_cert_level := nvl(FND_PROFILE.Value('HZ_DISPLAY_CERT_STATUS'),'NO');


      l_table_name := 'BIM_I_LEAD_FACTS';
     bis_collection_utilities.log('Running Incremental Load of Lead Facts');

   /* Truncate Staging table */
     EXECUTE IMMEDIATE 'TRUNCATE TABLE '||l_schema||'.bim_i_lead_facts_stg';

     l_sysdate:=sysdate;

      INSERT /*+ append parallel */
      INTO bim_i_lead_facts_stg LDF
      (
              lead_id
              ,group_id
              ,resource_id
              ,lead_rank_id
              ,lead_source
              ,lead_status
              ,lead_country
              ,source_code_id
              ,lead_creation_date
              ,lead_touched_date
	      ,channel_code--
--	     ,lead_amount
--	     ,currency_code
	     ,close_reason
	     ,accept_flag
	     ,qualified_flag
	     ,source_primary_reference
	     ,source_secondary_reference
	     ,customer_id
	     ,cust_category
	     ,status_open_flag
	     ,lead_rank_score
	     ,expiration_date
--	     ,conversion_rate
--	     ,from_currency
	     ,CUSTOMER_FLAG
	     ,lead_name
      )
SELECT
              x.sales_lead_id lead_id
              ,x.assign_sales_group_id group_id
              ,x.assign_to_salesforce_id resource_id
              ,x.lead_rank_id lead_rank_id
              ,x.source_system lead_source
              ,x.status_code lead_status
              ,x.country lead_country
	      ,x.source_promotion_id source_code_id
              ,trunc(x.creation_date) lead_creation_date
              ,(CASE
                   WHEN (x.last_update_date > (x.creation_date+1/1440)) THEN trunc(x.last_update_date)
                   ELSE null
                END
              ) lead_touched_date
	      ,x.channel_code channel_code
--	     ,fii_currency.convert_global_amt_primary(nvl(x.currency_code,'USD'),nvl(x.total_amount,0),X.creation_date) lead_amount
--	     ,x.currency_code currency_code
	     ,x.close_reason close_reason
	     ,x.accept_flag accept_flag
	     ,x.qualified_flag qualified_flag
	     ,x.source_primary_reference source_primary_reference
	     ,x.source_secondary_reference source_secondary_reference
	     ,x.customer_id customer_id
	     ,NULL  cust_category
	     ,x.status_open_flag status_open_flag
	     ,x.lead_rank_score lead_rank_score
	     ,x.expiration_date expiration_date
 --	     ,fii_currency.get_global_rate_primary(nvl(x.currency_code,'USD'),x.creation_date) conversion_rate
 --            ,nvl(x.currency_code,'USD') from_currency
	     ,'N' CUSTOMER_FLAG
	     ,x.DESCRIPTION
FROM
              as_sales_leads X
WHERE
              X.last_update_date between p_start_date and l_sysdate
AND           X.creation_date >=p_global_date	;

COMMIT;

      INSERT /*+ append parallel */
      INTO bim_i_lead_facts_stg LDF
      (
              lead_id
	      ,lead_line_id
              ,group_id
              ,resource_id
              ,lead_rank_id
              ,lead_source
              ,lead_status
              ,lead_country
              ,source_code_id
	      ,interest_type_id
	      ,primary_interest_code_id
	      ,secondary_interest_code_id
	      ,item_id
	      ,organization_id
              ,lead_creation_date
              ,lead_touched_date
	      ,channel_code
--	     ,lead_amount
--	     ,currency_code
	     ,close_reason
	     ,accept_flag
	     ,qualified_flag
	     ,source_primary_reference
	     ,source_secondary_reference
	     ,customer_id
	     ,cust_category
	     ,status_open_flag
	     ,lead_rank_score
	     ,expiration_date
--	     ,conversion_rate
--	     ,from_currency
	     ,product_category_id
	     ,CUSTOMER_FLAG
	     ,lead_name
      )
SELECT
               x.sales_lead_id lead_id
	      ,y.sales_lead_line_id lead_line_id
              ,x.assign_sales_group_id group_id
              ,x.assign_to_salesforce_id resource_id
              ,x.lead_rank_id lead_rank_id
              ,x.source_system lead_source
              ,x.status_code lead_status
              ,x.country lead_country
	      ,x.source_promotion_id source_code_id
	      ,y.interest_type_id interest_type_id
	      ,y.primary_interest_code_id primary_interest_code_id
	      ,y.secondary_interest_code_id secondary_interest_code_id
	      ,nvl(y.inventory_item_id,-1) item_id
	      ,decode(y.inventory_item_id,null,-1,nvl(y.organization_id,-1)) organization_id
              ,trunc(x.creation_date) lead_creation_date
              ,(CASE
                   WHEN (x.last_update_date > (x.creation_date+1/1440)) THEN trunc(x.last_update_date)
                   ELSE null
                END
              ) lead_touched_date
	      ,x.channel_code channel_code
--	     ,fii_currency.convert_global_amt_primary(nvl(x.currency_code,'USD'),nvl(x.total_amount,0),X.creation_date) lead_amount
--	     ,x.currency_code currency_code
	     ,x.close_reason close_reason
	     ,x.accept_flag accept_flag
	     ,x.qualified_flag qualified_flag
	     ,x.source_primary_reference source_primary_reference
	     ,x.source_secondary_reference source_secondary_reference
	     ,x.customer_id customer_id
	     ,NULL  cust_category
	     ,x.status_open_flag status_open_flag
	     ,x.lead_rank_score lead_rank_score
	     ,x.expiration_date expiration_date
--	     ,fii_currency.get_global_rate_primary(nvl(x.currency_code,'USD'),x.creation_date) conversion_rate
 --            ,nvl(x.currency_code,'USD') from_currency
	     ,y.category_id product_category_id
	     ,'N' CUSTOMER_FLAG
	     ,x.DESCRIPTION
FROM
              as_sales_leads X
              ,as_sales_lead_lines Y
WHERE
              (X.last_update_date between p_start_date and l_sysdate OR Y.last_update_date between p_start_date and l_sysdate)
              AND   X.sales_lead_id = Y.sales_lead_id
	      AND   X.creation_date >=p_global_date ;


COMMIT;

/*l_check_missing_rate := Check_Missing_Rates (p_start_date);
if (l_check_missing_rate = -1) then
 BIS_COLLECTION_UTILITIES.debug('before truncating first time load' );
      l_stmt := 'TRUNCATE table '||l_schema||'.bim_i_lead_facts_stg';
      EXECUTE IMMEDIATE l_stmt;
      commit;
x_return_status := FND_API.G_RET_STS_ERROR;
RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
end if;
*/

 --update to get customer category

update bim_i_lead_facts_stg stg
                        set stg.cust_category
                        = (select b.class_code from  hz_code_assignments  b
                          where
                             stg.customer_id=b.OWNER_TABLE_ID
                             and b.OWNER_TABLE_NAME='HZ_PARTIES'
                             and b.Primary_flag = 'Y'
                 and nvl(b.end_date_active,trunc(l_sysdate)) > = trunc(l_sysdate)
                 and b.CLASS_CATEGORY='CUSTOMER_CATEGORY'
                 and b.status='A'--Active
                 and b.START_DATE_ACTIVE =
                      ( select max(START_DATE_ACTIVE) from hz_code_assignments  c
                         where
                            c.OWNER_TABLE_NAME='HZ_PARTIES'
                            and c.CLASS_CATEGORY='CUSTOMER_CATEGORY'
                            and c.Primary_flag = 'Y'
                            and nvl(c.end_date_active,trunc(l_sysdate)) > = trunc(l_sysdate)
                            and c.status='A'
                            and b.OWNER_TABLE_ID=c.OWNER_TABLE_ID)
                                                        )
where
      exists
       (select b.class_code from  hz_code_assignments  b
                          where
                             stg.customer_id=b.OWNER_TABLE_ID
                             and b.OWNER_TABLE_NAME='HZ_PARTIES'
                             and b.Primary_flag = 'Y'
                 and nvl(b.end_date_active,trunc(l_sysdate)) > = trunc(l_sysdate)
                 and b.CLASS_CATEGORY='CUSTOMER_CATEGORY'
                 and b.status='A'--Active
                 and b.START_DATE_ACTIVE =
                      ( select max(START_DATE_ACTIVE) from hz_code_assignments  c
                         where
                            c.OWNER_TABLE_NAME='HZ_PARTIES'
                            and c.CLASS_CATEGORY='CUSTOMER_CATEGORY'
                            and c.Primary_flag = 'Y'
                            and nvl(c.end_date_active,trunc(l_sysdate)) > = trunc(l_sysdate)
                            and c.status='A'
                            and b.OWNER_TABLE_ID=c.OWNER_TABLE_ID) );

 --update customer flag

    IF l_cert_level = 'YES' THEN

          update bim_i_lead_facts_stg stg set CUSTOMER_FLAG='Y'
          where
          exists
          (select 1 from HZ_CUST_ACCOUNTS a,hz_parties b
          where a.party_id=stg.customer_id
          and   stg.lead_creation_date >= trunc(a.creation_date)
          and   a.party_id=b.party_id
          and   b.certification_level is not null);

   else

           update bim_i_lead_facts_stg stg set CUSTOMER_FLAG='Y'
           where
           exists
           (select 1 from HZ_CUST_ACCOUNTS a
           where a.party_id=stg.customer_id
           and   stg.lead_creation_date >= trunc(a.creation_date));

   end if;

   COMMIT;

	   MERGE INTO bim_i_lead_facts facts
	   USING  (
           SELECT
               sysdate                          creation_date
	      ,sysdate                          last_update_date
	      ,-1                               created_by
	      ,-1                               last_updated_by
	      ,-1                               last_update_login
              ,x.lead_id                        lead_id
	      ,x.lead_line_id                   lead_line_id
              ,x.group_id                       group_id
              ,x.resource_id                    resource_id
              ,x.lead_rank_id                   lead_rank_id
              ,x.lead_source                    lead_source
              ,x.lead_status                    lead_status
              --,x.status_open_flag open_flag
	      ,t.parent_territory_code          lead_region
              ,x.lead_country                   lead_country
              ,a.source_code_id                 source_code_id
              ,a.object_type                    object_type
              ,a.object_id                      object_id
              ,a.child_object_type              child_object_type
              ,a.child_object_id                child_object_id
              ,a.object_region                  object_region
              ,a.object_country                 object_country
              ,a.object_status                  object_status
              ,a.object_purpose                 object_purpose
              ,a.child_object_region            child_object_region
              ,a.child_object_country           child_object_country
              ,a.child_object_status            child_object_status
              ,a.child_object_purpose           child_object_purpose
              ,a.category_id                    object_category_id
              ,a.business_unit_id               business_unit_id
              ,x.lead_creation_date             lead_creation_date
              ,x.lead_touched_date              lead_touched_date
	      ,nvl(x.item_id,-1)                item_id
	      ,nvl(x.organization_id,-1)        organization_id
	      ,x.channel_code			channel_code
	     ,x.lead_amount			lead_amount
	     ,x.close_reason			close_reason
	     ,x.accept_flag			accept_flag
	     ,x.qualified_flag			qualified_flag
	     ,x.source_primary_reference	source_primary_reference
	     ,x.source_secondary_reference	source_secondary_reference
	     ,x.customer_id			customer_id
	     ,x.cust_category			cust_category
	     ,x.status_open_flag		status_open_flag
	     ,x.lead_rank_score			lead_rank_score
	     ,x.expiration_date			expiration_date
	     ,nvl(x.product_category_id,-1)    product_category_id
	     ,x.customer_flag			customer_flag
	     ,x.lead_name                        lead_name
FROM
              bim_i_lead_facts_stg X
              ,bim_i_source_codes A
              ,bis_territory_hierarchies T
WHERE
              X.source_code_id = A.source_code_id(+)
              AND T.parent_territory_type(+) = 'AREA'
              AND T.child_territory_type(+) = 'COUNTRY'
              AND T.child_territory_code(+) = X.lead_country
) changes
	  ON (facts.lead_id = changes.lead_id
              AND nvl(facts.lead_line_id,-1) = nvl(changes.lead_line_id,-1)
            )
	  WHEN MATCHED THEN UPDATE  SET
	     facts.last_update_date		= changes.last_update_date
	    ,facts.group_id			= changes.group_id
	    ,facts.resource_id			= changes.resource_id
	    ,facts.lead_rank_id			= changes.lead_rank_id
            ,facts.lead_source			= changes.lead_source
            ,facts.lead_status			= changes.lead_status
            --,facts.open_flag			= changes.open_flag
            ,facts.lead_region			= changes.lead_region
            ,facts.lead_country			= changes.lead_country
            ,facts.source_code_id		= changes.source_code_id
            ,facts.object_type			= changes.object_type
            ,facts.object_id			= changes.object_id
            ,facts.child_object_type		= changes.child_object_type
            ,facts.child_object_id		= changes.child_object_id
            ,facts.object_region		= changes.object_region
            ,facts.object_country		= changes.object_country
            ,facts.object_status		= changes.object_status
            ,facts.object_purpose		= changes.object_purpose
            ,facts.child_object_region		= changes.child_object_region
            ,facts.child_object_country		= changes.child_object_country
            ,facts.child_object_status		= changes.child_object_status
            ,facts.child_object_purpose		= changes.child_object_purpose
            ,facts.business_unit_id		= changes.business_unit_id
            ,facts.object_category_id		= changes.object_category_id
            ,facts.lead_touched_date		= decode(facts.lead_touched_date, null, decode(changes.lead_touched_date,null,null,changes.lead_touched_date),facts.lead_touched_date)
            ,facts.item_id                      = changes.item_id
            ,facts.organization_id              = changes.organization_id
            ,facts.channel_code	                = changes.channel_code
            ,facts.lead_amount	                = changes.lead_amount
            ,facts.close_reason	                = changes.close_reason
            ,facts.accept_flag	                = changes.accept_flag
            ,facts.qualified_flag	        = changes.qualified_flag
            ,facts.source_primary_reference	= changes.source_primary_reference
            ,facts.source_secondary_reference	= changes.source_secondary_reference
            ,facts.customer_id	                = changes.customer_id
            ,facts.cust_category	        = changes.cust_category
            ,facts.status_open_flag	        = changes.status_open_flag
            ,facts.lead_rank_score	        = changes.lead_rank_score
            ,facts.expiration_date	        = changes.expiration_date
            ,facts.product_category_id		= changes.product_category_id
	    ,facts.CUSTOMER_FLAG		= changes.CUSTOMER_FLAG
	    ,facts.lead_name                    = changes.lead_name
	   WHEN NOT MATCHED THEN INSERT
		(
	       facts.creation_date
              ,facts.last_update_date
              ,facts.created_by
              ,facts.last_updated_by
              ,facts.last_update_login
              ,facts.lead_id
              ,facts.lead_line_id
              ,facts.group_id
              ,facts.resource_id
              ,facts.lead_rank_id
              ,facts.lead_source
              ,facts.lead_status
              --,facts.open_flag
              ,facts.lead_region
              ,facts.lead_country
              ,facts.source_code_id
              ,facts.object_type
	      ,facts.object_id
              ,facts.child_object_type
	      ,facts.child_object_id
              ,facts.object_region
              ,facts.object_country
              ,facts.object_status
              ,facts.object_purpose
              ,facts.child_object_region
              ,facts.child_object_country
              ,facts.child_object_status
              ,facts.child_object_purpose
              ,facts.business_unit_id
              ,facts.object_category_id
              ,facts.lead_creation_date
              ,facts.lead_touched_date
              ,facts.item_id
              ,facts.organization_id
             ,facts.channel_code
	     ,facts.lead_amount
	     ,facts.close_reason
	     ,facts.accept_flag
	     ,facts.qualified_flag
	     ,facts.source_primary_reference
	     ,facts.source_secondary_reference
	     ,facts.customer_id
	     ,facts.cust_category
	     ,facts.status_open_flag
	     ,facts.lead_rank_score
	     ,facts.expiration_date
	     ,facts.product_category_id
	     ,facts.customer_flag
	     ,facts.lead_name
		 )
	   VALUES
		 (
	       changes.creation_date
              ,changes.last_update_date
              ,changes.created_by
              ,changes.last_updated_by
              ,changes.last_update_login
              ,changes.lead_id
              ,changes.lead_line_id
              ,changes.group_id
              ,changes.resource_id
              ,changes.lead_rank_id
              ,changes.lead_source
              ,changes.lead_status
              --,changes.open_flag
              ,changes.lead_region
              ,changes.lead_country
              ,changes.source_code_id
              ,changes.object_type
	      ,changes.object_id
              ,changes.child_object_type
	      ,changes.child_object_id
              ,changes.object_region
              ,changes.object_country
              ,changes.object_status
              ,changes.object_purpose
              ,changes.child_object_region
              ,changes.child_object_country
              ,changes.child_object_status
              ,changes.child_object_purpose
              ,changes.business_unit_id
              ,changes.object_category_id
              ,changes.lead_creation_date
              ,changes.lead_touched_date
              ,changes.item_id
              ,changes.organization_id
	     ,changes.channel_code
	     ,changes.lead_amount
	    ,changes.close_reason
	    ,changes.accept_flag
	    ,changes.qualified_flag
	    ,changes.source_primary_reference
	    ,changes.source_secondary_reference
	    ,changes.customer_id
	    ,changes.cust_category
	    ,changes.status_open_flag
	    ,changes.lead_rank_score
	    ,changes.expiration_date
            ,changes.product_category_id
	    ,changes.customer_flag
	    ,changes.lead_name
);


     --update date for dead leads
     UPDATE bim_i_lead_facts facts
        SET  facts.lead_dead_date
                   = (SELECT TRUNC(MIN(hist.creation_date))
			FROM
                          as_sales_leads_log hist
			WHERE
			      hist.last_update_date between p_start_date and l_sysdate
			  AND hist.status_code = l_dead_status
			  AND hist.sales_lead_id = facts.lead_id
			  AND hist.status_code = facts.lead_status
                          AND facts.lead_dead_date is null
                          AND facts.lead_converted_date is null
                          AND facts.lead_closed_date is null
                     )
        WHERE
           EXISTS (SELECT 1
		      FROM
                        as_sales_leads_log hist
	              WHERE
		            hist.last_update_date between p_start_date and l_sysdate
			AND hist.status_code = l_dead_status
			AND hist.sales_lead_id = facts.lead_id
			AND hist.status_code = facts.lead_status
                        AND facts.lead_dead_date is null
                        AND facts.lead_converted_date is null
                        AND facts.lead_closed_date is null
                   );


     --update date for converted leads
     UPDATE bim_i_lead_facts facts
        SET  facts.lead_converted_date
                   = (SELECT TRUNC(MIN(slo.creation_date))
                        FROM
                          as_sales_lead_opportunity slo
                        WHERE
                          slo.creation_date between p_start_date and l_sysdate
                          AND slo.sales_lead_id = facts.lead_id
                          AND facts.lead_dead_date is null
                          AND facts.lead_converted_date is null
                          AND facts.lead_closed_date is null
                      )
        WHERE
           EXISTS (SELECT 1
                      FROM
                        as_sales_lead_opportunity slo
                      WHERE
                            slo.creation_date between p_start_date and l_sysdate
                        AND slo.sales_lead_id = facts.lead_id
                        AND facts.lead_dead_date is null
                        AND facts.lead_converted_date is null
                        AND facts.lead_closed_date is null
                   );


     --update date for closed leads other than dead and converted
     UPDATE bim_i_lead_facts facts
        SET  facts.lead_closed_date
                   = (SELECT TRUNC(MIN(hist.creation_date))
			FROM
                          as_sales_leads_log hist
                          ,as_statuses_b st
			WHERE
			      hist.last_update_date between p_start_date and l_sysdate
                          AND hist.status_code not in (l_conv_opp_status, l_dead_status)
                          AND hist.status_code = st.status_code
                          AND st.opp_open_status_flag = 'N'
			  AND hist.sales_lead_id = facts.lead_id
			  AND hist.status_code = facts.lead_status
                          AND facts.lead_dead_date is null
                          AND facts.lead_converted_date is null
                          AND facts.lead_closed_date is null
                     )
        WHERE
           EXISTS (SELECT 1
		      FROM
                        as_sales_leads_log hist
                        ,as_statuses_b st
		      WHERE
			    hist.last_update_date between p_start_date and l_sysdate
                        AND hist.status_code not in (l_conv_opp_status, l_dead_status)
                        AND hist.status_code = st.status_code
                        AND st.opp_open_status_flag = 'N'
			AND hist.sales_lead_id = facts.lead_id
			AND hist.status_code = facts.lead_status
                        AND facts.lead_dead_date is null
                        AND facts.lead_converted_date is null
                        AND facts.lead_closed_date is null
                       );

     --update touched_date for leads that comes in dead, conveted or closed
     UPDATE bim_i_lead_facts facts
             SET  facts.lead_touched_date
                 =(CASE
                     WHEN lead_dead_date is not null THEN lead_dead_date
                     WHEN lead_converted_date is not null THEN lead_converted_date
                     WHEN lead_closed_date is not null THEN lead_closed_date
                     ELSE null
                   END
                  )
     where lead_touched_date is  null
     and last_update_date between p_start_date and l_sysdate;


     DELETE
     FROM bim_i_lead_facts
     WHERE lead_line_id IS NULL
     AND lead_id in (SELECT
                     lead_id
                     FROM bim_i_lead_facts_stg
                     WHERE lead_line_id is NOT NULL);

     COMMIT;

     EXECUTE IMMEDIATE 'TRUNCATE TABLE '||l_schema||'.bim_i_lead_facts_stg';


     --dbms_output.put_line(p_start_date);
     --dbms_output.put_line(p_end_date);
     bis_collection_utilities.wrapup(p_status => TRUE
                        ,p_count => sql%rowcount
                        ,p_period_from => p_start_date
                        ,p_period_to  => l_sysdate
                        );

     /***************************************************************/


     bis_collection_utilities.log('Before Analyze of the table BIM_I_LEAD_FACTS');

   --Analyze the facts table
     DBMS_STATS.gather_table_stats('BIM','BIM_I_LEAD_FACTS', estimate_percent => 5,
                                  degree => 8, granularity => 'GLOBAL', cascade =>TRUE);


     bis_collection_utilities.log('Successful Completion of Leads Facts Program');


EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_msg_PUB.Count_And_Get (
          --  p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

    ams_utility_pvt.write_conc_log('BIM_I_LEAD_FACTS_PKG:INCREMENTAL_LOAD:IN EXPECTED EXCEPTION '||sqlerrm(sqlcode));

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     -- Standard call to get message count and if count=1, get the message
     FND_msg_PUB.Count_And_Get (
            --p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

    ams_utility_pvt.write_conc_log('BIM_I_LEAD_FACTS_PKG:INCREMENTAL_LOAD:IN UNEXPECTED EXCEPTION '||sqlerrm(sqlcode));

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

    ams_utility_pvt.write_conc_log('BIM_I_LEAD_FACTS_PKG:INCREMENTAL_LOAD:IN OTHERS EXCEPTION '||sqlerrm(sqlcode));


END INCREMENTAL_LOAD;


END BIM_I_LEAD_FACTS_PKG;


/
