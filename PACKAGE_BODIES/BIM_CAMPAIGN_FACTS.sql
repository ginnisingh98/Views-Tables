--------------------------------------------------------
--  DDL for Package Body BIM_CAMPAIGN_FACTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIM_CAMPAIGN_FACTS" AS
/*$Header: bimcmpfb.pls 120.1 2005/12/05 06:50:19 arvikuma noship $*/

g_pkg_name  CONSTANT  VARCHAR2(20) := 'BIM_CAMPAIGN_FACTS';
g_file_name CONSTANT  VARCHAR2(20) := 'bimcmpfb.pls';

FUNCTION  convert_currency(
   p_from_currency          VARCHAR2
  ,p_from_amount            NUMBER) return NUMBER
IS
   l_conversion_type_profile    CONSTANT VARCHAR2(30) := 'AMS_CURR_CONVERSION_TYPE';
   l_user_rate                  CONSTANT NUMBER       := 1;
   l_max_roll_days              CONSTANT NUMBER       := -1;
   l_denominator      		NUMBER;   		-- Not used in Marketing.
   l_numerator        		NUMBER;   		-- Not used in Marketing.
   l_conversion_type  		VARCHAR2(30); 		-- Curr conversion type; see API doc for details.
   l_to_amount    		NUMBER;
   l_rate         		NUMBER;
   l_to_currency    		VARCHAR2(100) ;
   x_return_status		varchar2(1);
BEGIN

    l_to_currency := fnd_profile.value('AMS_DEFAULT_CURR_CODE');

    -- condition added to pass conversion types
    l_conversion_type := fnd_profile.VALUE(l_conversion_type_profile);

    -- Conversion type cannot be null in profile
    IF l_conversion_type IS NULL THEN
       IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
         fnd_message.set_name('OZF', 'OZF_NO_EXCHANGE_TYPE');
         fnd_msg_pub.add;
       END IF;
       RETURN 0;
    END IF;

   -- Call the proper AMS_UTILITY_API API to convert the amount.

      ams_utility_pvt.Convert_Currency (
         x_return_status ,
         p_from_currency,
         l_to_currency,
         sysdate,
         p_from_amount,
         l_to_amount);

  /* gl_currency_api.convert_closest_amount(
      x_from_currency => p_from_currency
     ,x_to_currency => l_to_currency
     ,x_conversion_date =>sysdate
     ,x_conversion_type => l_conversion_type
     ,x_user_rate => l_user_rate
     ,x_amount => p_from_amount
     ,x_max_roll_days => l_max_roll_days
     ,x_converted_amount => l_to_amount
     ,x_denominator => l_denominator
     ,x_numerator => l_numerator
     ,x_rate => l_rate); */

   RETURN (l_to_amount);

EXCEPTION
   WHEN gl_currency_api.no_rate THEN
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
         fnd_message.set_name('OZF', 'OZF_NO_RATE');
         fnd_msg_pub.add;
      END IF;
   WHEN gl_currency_api.invalid_currency THEN
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
         fnd_message.set_name('OZF', 'OZF_INVALID_CURR');
         fnd_msg_pub.add;
      END IF;
   WHEN OTHERS THEN
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
         fnd_msg_pub.add_exc_msg('OZF_UTLITY_PVT', 'Convert_curency');
      END IF;
END convert_currency;

-------------------------------------------------------------------------------

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

----------------------------------------------------------------------------------------------------
        /* This procedure will conditionally call the FIRST_LOAD or the DAILY_LOAD */
----------------------------------------------------------------------------------------------------

PROCEDURE POPULATE
   (
     p_api_version_number      IN  NUMBER
    ,p_init_msg_list           IN  VARCHAR2     := FND_API.G_FALSE
    ,p_validation_level        IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL
    ,p_commit                  IN  VARCHAR2     := FND_API.G_FALSE
    ,x_msg_count               OUT NOCOPY NUMBER
    ,x_msg_data                OUT NOCOPY VARCHAR2
    ,x_return_status           OUT NOCOPY VARCHAR2
    ,p_object                  IN  VARCHAR2
    ,p_start_date              IN  DATE
    ,p_end_date                IN  DATE
    ,p_para_num                IN  NUMBER
    --,p_mode                    IN  VARCHAR2
    ) IS

    l_profile                 NUMBER;
    v_error_code              NUMBER;
    v_error_text              VARCHAR2(1500);
    l_last_update_date        DATE;
    l_start_date              DATE;
    l_end_date                DATE;
    l_user_id                 NUMBER := FND_GLOBAL.USER_ID();
    l_sysdate                 DATE   := SYSDATE;
    l_api_version_number      CONSTANT NUMBER       := 1.0;
    l_api_name                CONSTANT VARCHAR2(30) := 'AMS_CAMPAIGN_FACTS';
    l_success                 VARCHAR2(3);
    s_date                    DATE :=  to_date('01/01/1950 01:01:01', 'DD/MM/YYYY HH:MI:SS') ;
    l_temp 	              DATE;
    l_mesg_text		      VARCHAR2(100);
    l_load_type	              VARCHAR2(100);
    l_period_error	      VARCHAR2(5000);
    l_currency_error	      VARCHAR2(5000);
    l_err_code	              NUMBER;
    l_temp_start_date              DATE;
    l_temp_end_date                DATE;
    l_temp_p_end_date                DATE;

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

      /* Find if the data will be loaded for the first time or not.*/
          DECLARE
          CURSOR chk_history_data IS
              SELECT  MAX(end_date)
              FROM    bim_rep_history
              WHERE   object = 'CAMPAIGN';

          BEGIN
              OPEN  chk_history_data;
              FETCH chk_history_data INTO l_end_date;
              CLOSE chk_history_data;
             EXCEPTION
          WHEN OTHERS THEN
               FND_MSG_PUB.Count_And_Get (
                    --  p_encoded => FND_API.G_FALSE,
                      p_count   => x_msg_count,
                      p_data    => x_msg_data
               );
          END;

        /* End of the code for checking the data will be loaded for the first time or not. */

        IF(trunc(p_end_date) = trunc(sysdate)) THEN
           l_temp_p_end_date := trunc(p_end_date) - 1;
        ELSE
           l_temp_p_end_date := trunc(p_end_date);
        END IF;

        IF (l_end_date IS NOT NULL AND p_start_date IS NOT NULL)
        THEN
                ams_utility_pvt.write_conc_log('First Time Load is already run. Subsequent Load should be run .');
                ams_utility_pvt.write_conc_log('Concurrent Program Exits Now');
                RAISE FND_API.G_EXC_ERROR;
        END IF;


          IF p_start_date IS NOT NULL THEN

                  IF (p_start_date >= l_temp_p_end_date) THEN
                    ams_utility_pvt.write_conc_log('The start date cannot be greater than or equal to the current end date');
                    ams_utility_pvt.write_conc_log('Concurrent Program Exits Now ');
                    RAISE FND_API.G_EXC_ERROR;
                  END IF;

                  l_temp_start_date := trunc(p_start_date);
                  l_temp_end_date   := trunc(l_temp_p_end_date);
                  l_load_type  := 'FIRST_LOAD';

          ELSE
                IF l_end_date IS NOT NULL THEN

                   IF (l_temp_p_end_date <= l_end_date) THEN
                      ams_utility_pvt.write_conc_log('This program is already run upto: ' || trunc(l_end_date));
                      ams_utility_pvt.write_conc_log('Concurrent Program Exits Now ');
                      RAISE FND_API.g_exc_error;
                   END IF;

                   l_temp_start_date := trunc(l_end_date) + 1;
                   l_temp_end_date   := trunc(l_temp_p_end_date);
                   l_load_type  := 'SUBSEQUENT_LOAD';

                END IF;

          END IF;

          -- Validate the Periods and Currencies before processing any further
          --l_err_code := BIM_VALIDITY_CHECK.validate_campaigns(l_temp_start_date,
          --                                            l_temp_end_date, l_period_error, l_currency_error);
          --COMMENT out before checking into arcs
          l_err_code := 0;

          IF (l_err_code = 0) THEN  -- Validation Succesful

                 CAMPAIGN_SUBSEQUENT_LOAD(p_start_date => l_temp_start_date
                     ,p_end_date =>  l_temp_end_date
                     ,p_api_version_number => l_api_version_number
                     ,p_init_msg_list => FND_API.G_FALSE
                     ,p_load_type => l_load_type
                     ,x_msg_count => x_msg_count
                     ,x_msg_data   => x_msg_data
                     ,x_return_status => x_return_status
                 );

                 IF    x_return_status = FND_API.g_ret_sts_error
                 THEN
                       RAISE FND_API.g_exc_error;
                 ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
                       RAISE FND_API.g_exc_unexpected_error;
                 END IF;
          ELSE
                 ams_utility_pvt.write_conc_log('----Period Validation----');
                 ams_utility_pvt.write_conc_log(l_period_error);
                 ams_utility_pvt.write_conc_log('----Currency Validation----');
                 ams_utility_pvt.write_conc_log(l_currency_error);

          END IF;

    --Standard check of commit

       IF FND_API.To_Boolean ( p_commit ) THEN
          COMMIT WORK;
       END IF;

    COMMIT;
                 ams_utility_pvt.write_conc_log('Campaigns Concurrent Program Succesfully Completed ');

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
/* This procedure will insert a HISTORY record whenever daily or first load is run */
--------------------------------------------------------------------------------------------------

PROCEDURE LOG_HISTORY
    (--p_api_version_number    IN   NUMBER
    --,p_init_msg_list         IN   VARCHAR2     := FND_API.G_FALSE
    --,x_msg_count             OUT  NOCOPY NUMBER
    --,x_msg_data              OUT  NOCOPY VARCHAR2
    --,x_return_status         OUT  NOCOPY VARCHAR2
    p_object                   IN   VARCHAR2,
    p_start_date               IN  DATE         DEFAULT NULL,
    p_end_date                 IN  DATE         DEFAULT NULL
    )
    IS
    l_user_id            	NUMBER := FND_GLOBAL.USER_ID();
    l_sysdate            	DATE   := SYSDATE;
    l_api_version_number        CONSTANT NUMBER       := 1.0;
    l_api_name                  CONSTANT VARCHAR2(30) := 'AMS_CAMPAIGN_FACTS';
    l_success                   VARCHAR2(3);

BEGIN

      -- Debug Message
      --AMS_UTILITY_PVT.debug_message('Private API: ' || 'Running the LOG_HISTORY procedure ');

/*     -- Standard call to check for call compatibility.
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
*/

    INSERT INTO bim_rep_history
     (CREATION_DATE,
      LAST_UPDATE_DATE,
      CREATED_BY,
      LAST_UPDATED_BY,
      OBJECT,
      OBJECT_LAST_UPDATED_DATE,
      START_DATE,
      END_DATE)
    VALUES
     (sysdate,
      sysdate,
      l_user_id,
      l_user_id,
      p_object,
      sysdate,
      p_start_date,
      p_end_date);

/*      -- Standard call to get message count and if count is 1, get message info.
      FND_msg_PUB.Count_And_Get
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
*/
--COMMIT;

END LOG_HISTORY;

--------------------------------------------------------------------------------------------------
-- This procedure will excute when data is loaded for the first time, and run the program incrementally.

--                      PROCEDURE  CAMPAIGN_FIRST_LOAD
--------------------------------------------------------------------------------------------------

PROCEDURE CAMPAIGN_FIRST_LOAD
( p_start_date            IN  DATE
 ,p_end_date              IN  DATE
 ,p_api_version_number    IN  NUMBER
 ,p_init_msg_list         IN  VARCHAR2     := FND_API.G_FALSE
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
    l_wkdt			  DATE;
    l_noleads		          NUMBER;
    l_nooppor		          NUMBER;
    l_orders		       	  NUMBER;
    l_noposresp		          NUMBER;
    l_revenue		          NUMBER;
    l_forecasted_cost	   	  NUMBER;
    l_actual_cost		  NUMBER;
    l_targeted_customer	   	  NUMBER;
    l_noofnew_customer	   	  NUMBER;
    l_temp                 	  NUMBER;
    l_tempo                	  NUMBER;
    l_seq                  	  NUMBER;
    l_seqw                 	  NUMBER;
    l_api_version_number   	  CONSTANT NUMBER       := 1.0;
    l_api_name             	  CONSTANT VARCHAR2(30) := 'CAMPAIGN_FIRST_LOAD';
    l_seq_name             	  VARCHAR(100);
    l_def_tablespace        	  VARCHAR2(100);
    l_index_tablespace      	  VARCHAR2(100);
    l_oracle_username       	  VARCHAR2(100);
    l_table_name		  VARCHAR2(100);
    l_temp_msg		          VARCHAR2(100);

   TYPE  generic_number_table IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

   TYPE  generic_char_table IS TABLE OF VARCHAR2(100) INDEX BY BINARY_INTEGER;

   l_pct_free	        generic_number_table;
   l_ini_trans  	generic_number_table;
   l_max_trans  	generic_number_table;
   l_initial_extent     generic_number_table;
   l_next_extent  	generic_number_table;
   l_min_extents 	generic_number_table;
   l_max_extents 	generic_number_table;
   l_pct_increase 	generic_number_table;


   l_owner 		generic_char_table;
   l_index_name 	generic_char_table;
   l_ind_column_name    generic_char_table;
   l_index_table_name   generic_char_table;
   i			NUMBER;
   l_junk 			NUMBER;

   l_status      VARCHAR2(30);
   l_industry    VARCHAR2(30);
   l_orcl_schema VARCHAR2(30);
   l_bol         BOOLEAN := fnd_installation.get_app_info ('BIM',l_status,l_industry,l_orcl_schema);


   CURSOR    get_ts_name IS
   SELECT    i.tablespace, i.index_tablespace, u.oracle_username
   FROM      fnd_product_installations i, fnd_application a, fnd_oracle_userid u
   WHERE     a.application_short_name = 'BIM'
   AND 	     a.application_id = i.application_id
   AND 	     u.oracle_id = i.oracle_id;

   CURSOR    get_index_params (l_schema VARCHAR2) IS
   SELECT    a.owner,a.index_name,b.table_name,b.column_name,pct_free,ini_trans,max_trans
             ,initial_extent,next_extent,min_extents,
	     max_extents, pct_increase
   FROM      all_indexes a, all_ind_columns b
   WHERE     a.index_name = b.index_name
   AND       a.owner = l_schema
   AND       a.owner = b.index_owner
   AND 	     a.index_name like 'BIM_R_CAMP_%FACTS%';


   l_min_date			date;

   l_org_id 			number;

   CURSOR   get_org_id IS
   SELECT   (TO_NUMBER(SUBSTRB(USERENV('CLIENT_INFO'), 1, 10)))
   FROM     dual;
l_status1                      VARCHAR2(5);
l_industry1                    VARCHAR2(5);
l_schema                      VARCHAR2(30);
l_return                       BOOLEAN;
BEGIN
l_return  := fnd_installation.get_app_info('BIM', l_status1, l_industry1, l_schema);
    ams_utility_pvt.write_conc_log(p_start_date || ' '|| p_end_date);
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

   ams_utility_pvt.write_conc_log('BIM_CAMPAIGN_FACTS: Running the First Load '||sqlerrm(sqlcode));

   -- The below four commands are necessary for the purpose of the parallel insertion */

   EXECUTE IMMEDIATE 'ALTER SESSION ENABLE PARALLEL dml ';

    EXECUTE IMMEDIATE 'ALTER TABLE '||l_schema||'.bim_r_camp_daily_facts nologging ';

   EXECUTE IMMEDIATE 'ALTER TABLE '||l_schema||'.bim_r_camp_weekly_facts nologging ';

   EXECUTE IMMEDIATE 'ALTER SEQUENCE '||l_schema||'.bim_r_camp_daily_facts_s CACHE 1000 ';

   EXECUTE IMMEDIATE 'ALTER SEQUENCE '||l_schema||'.bim_r_camp_weekly_facts_s CACHE 1000 ';

   /*Get the tablespace name for the purpose of creating the index on that tablespace. */


      OPEN  get_ts_name;
      FETCH get_ts_name INTO	l_def_tablespace, l_index_tablespace, l_oracle_username;
      CLOSE get_ts_name;

      OPEN  get_org_id;
      FETCH get_org_id INTO	l_org_id;
      CLOSE get_org_id;


      /* Piece of Code for retrieving,storing storage parameters and Dropping the indexes */
      i := 1;
      FOR x in get_index_params (l_orcl_schema) LOOP

	  l_pct_free(i) :=  x.pct_free;
	  l_ini_trans(i) := x.ini_trans;
	  l_max_trans(i) := x.max_trans;
   	  l_initial_extent(i) := x.initial_extent;
   	  l_next_extent(i) 	  := x.next_extent;
   	  l_min_extents(i) := x.min_extents;
   	  l_max_extents(i) := x.max_extents;
   	  l_pct_increase(i) := x.pct_increase;

	  l_owner(i) 		:= x.owner;
	  l_index_name(i) := x.index_name;
	  l_index_table_name(i) := x.table_name;
	  l_ind_column_name(i) := x.column_name;


   -- Drop the index before the mass upload

      EXECUTE IMMEDIATE 'DROP INDEX  '|| l_owner(i) || '.'|| l_index_name(i) ;
      i := i + 1;
      END LOOP;

      /* End of Code for dropping the existing indexes */


    -- dbms_output.put_Line('JUST BEFORE THE MAIN INSERT STATMENT');

    l_org_id := 0;

    l_temp_msg := to_char( sysdate, 'dd/mm/yyyy:hh:mi:ss');
    ams_utility_pvt.write_conc_log('BIM_CAMPAIGN_FACTS:FIRST_LOAD: BEFORE FIRST INSERT ' || l_temp_msg);

      INSERT /*+ append parallel(CDF,1) */
      INTO bim_r_camp_daily_facts CDF
      (
               campaign_daily_transaction_id
              ,creation_date
              ,last_update_date
              ,created_by
              ,last_updated_by
              ,last_update_login
              ,campaign_id
              ,schedule_id
              ,transaction_create_date
              ,schedule_source_code
              ,campaign_source_code
              ,schedule_activity_type
	      ,schedule_activity_id
              ,campaign_purpose
              ,campaign_type
              ,start_date
              ,end_date
              ,schedule_purpose
              ,business_unit_id
              ,org_id
	      ,campaign_status
              ,schedule_status
              ,campaign_country
              ,campaign_region
              ,schedule_region
              ,schedule_country
              ,campaign_budget_fc
              ,schedule_budget_fc
              ,load_date
	      ,year
	      ,qtr
              ,month
              ,leads_open
              ,leads_closed
              ,leads_open_amt
              ,leads_closed_amt
	      ,leads_new
	      ,leads_new_amt
	      ,leads_hot
	      ,leads_converted
	      ,metric1 -- leads_dead
              ,opportunities
	      ,opportunity_amt
              ,orders_booked
              ,orders_booked_amt
              ,forecasted_revenue
              ,actual_revenue
              ,forecasted_cost
              ,actual_cost
              ,forecasted_responses
              ,positive_responses
              ,targeted_customers
              ,budget_requested
              ,budget_approved
      )
      SELECT  /*+ parallel(OUTER,1) */
		bim_r_camp_daily_facts_s.nextval
              ,sysdate
              ,sysdate
              ,-1
              ,-1
              ,-1
              ,campaign_id
              ,schedule_id
              ,transaction_create_date
              ,schedule_source_code
              ,campaign_source_code
              ,schedule_activity_type
	      ,schedule_activity_id
              ,campaign_purpose
              ,campaign_type
              ,start_date
              ,end_date
              ,schedule_purpose
              ,business_unit_id
              ,org_id
	      ,campaign_status
              ,schedule_status
              ,campaign_country
              ,campaign_region
              ,schedule_region
              ,schedule_country
              ,0 schedule_budget_fc
              ,0 campaign_budget_fc
              ,weekend_date
	      ,year
	      ,qtr
              ,month
              ,leads_open
              ,leads_closed
              ,leads_open_amt
              ,leads_closed_amt
	      ,leads_new
	      ,leads_new_amt
	      ,leads_hot
	      ,leads_converted
	      ,leads_dead
              ,opportunities
	      ,opportunity_amt
              ,orders_booked
              ,orders_booked_amt
              ,forecasted_revenue
              ,actual_revenue
              ,forecasted_cost
              ,actual_cost
              ,forecasted_responses
              ,positive_responses
              ,0 targeted_customers
              ,0 request_amount
	      ,0 approved_amount
      FROM
      (
SELECT
	      a.campaign_id		campaign_id
              ,0			schedule_id
      	      ,inner.creation_date	transaction_create_date
              ,0		        schedule_source_code
      	      ,c.source_code_id	        campaign_source_code_id
      	      ,0	                schedule_source_code_id
	      ,a.source_code		campaign_source_code
              ,0		        schedule_activity_type
	      ,0		        schedule_activity_id
	      ,a.campaign_type		campaign_purpose
              ,a.rollup_type		campaign_type
              ,a.actual_exec_start_date	start_date
              ,a.actual_exec_end_date	end_date
              ,0		        schedule_purpose
              ,a.business_unit_id	business_unit_id
              ,0			org_id
	      ,a.status_code		campaign_status
              ,0			schedule_status
              ,a.city_id		campaign_country
              ,d.area2_code		campaign_region
              ,0		        schedule_region
              ,0		        schedule_country
              ,(decode(decode( to_char(inner.creation_date,'MM') , to_char(next_day(inner.creation_date,TO_NUMBER(to_char(to_date('07/09/2004', 'DD/MM/RRRR'), 'DD'))),'MM') ,'TRUE','FALSE' )
      	        ,'TRUE'
      	        ,decode(decode(inner.creation_date , (next_day(inner.creation_date, TO_NUMBER(to_char(to_date('07/09/2004', 'DD/MM/RRRR'), 'DD'))) - 7) , 'TRUE' ,'FALSE')
       	        ,'TRUE'
      	        ,inner.creation_date
      	        ,'FALSE'
      	        ,next_day(inner.creation_date, TO_NUMBER(to_char(to_date('07/09/2004', 'DD/MM/RRRR'), 'DD'))))
      	        ,'FALSE'
      	        ,decode(decode(to_char(inner.creation_date,'MM'),to_char(next_day(inner.creation_date,TO_NUMBER(to_char(to_date('07/09/2004', 'DD/MM/RRRR'), 'DD'))),'MM'),'TRUE','FALSE')
      	        ,'FALSE'
      	        ,last_day(inner.creation_date))))         weekend_date
              ,bim_set_of_books.get_fiscal_year(inner.creation_date,0) year
              ,bim_set_of_books.get_fiscal_qtr(inner.creation_date,0)  qtr
              ,bim_set_of_books.get_fiscal_month(inner.creation_date,0) month
              ,inner.leads_open  	  leads_open
              ,inner.leads_closed 	  leads_closed
              ,inner.leads_open_amt    	  leads_open_amt
              ,inner.leads_closed_amt      leads_closed_amt
	      ,inner.leads_new		  leads_new
	      ,inner.leads_new_amt	  leads_new_amt
	      ,inner.leads_hot		  leads_hot
	      ,inner.leads_converted	  leads_converted
	      ,inner.leads_dead		  leads_dead
              ,inner.opportunities         opportunities
	      ,inner.opportunity_amt	  opportunity_amt
              ,inner.orders_booked	  orders_booked
              ,inner.orders_booked_amt	  orders_booked_amt
              ,inner.forecasted_revenue 	  forecasted_revenue
              ,inner.actual_revenue        actual_revenue
              ,inner.forecasted_cost       forecasted_cost
              ,inner.actual_cost           actual_cost
              ,inner.forecasted_responses  forecasted_responses
              ,inner.positive_responses    positive_responses
              ,inner.targeted_customers	  targeted_customers
FROM  (
SELECT
               metric.campaign_id campaign_id
              ,metric.creation_date creation_date
              ,sum(nvl(metric.leads_open,0))  	       leads_open
              ,sum(nvl(metric.leads_closed,0))	       leads_closed
              ,sum(nvl(metric.leads_open_amt,0))       leads_open_amt
              ,sum(nvl(metric.leads_closed_amt,0))     leads_closed_amt
	      ,sum(nvl(metric.leads_new,0))	       leads_new
	      ,sum(nvl(metric.leads_new_amt,0))	       leads_new_amt
	      ,sum(nvl(metric.leads_hot,0))	       leads_hot
	      ,sum(nvl(metric.leads_converted,0))      leads_converted
	      ,sum(nvl(metric.leads_dead,0))	       leads_dead
              ,sum(nvl(metric.opportunities,0))        opportunities
	      ,sum(nvl(metric.opportunity_amt,0))      opportunity_amt
              ,sum(nvl(metric.orders_booked,0))	       orders_booked
              ,sum(nvl(metric.orders_booked_amt,0))    orders_booked_amt
              ,sum(nvl(metric.forecasted_revenue,0))   forecasted_revenue
              ,sum(nvl(metric.actual_revenue,0))       actual_revenue
              ,sum(nvl(metric.forecasted_cost,0))      forecasted_cost
              ,sum(nvl(metric.actual_cost,0))          actual_cost
              ,sum(nvl(metric.forecasted_responses,0)) forecasted_responses
              ,sum(nvl(metric.positive_responses,0))   positive_responses
              ,0				       targeted_customers
FROM (
SELECT
              A.campaign_id campaign_id
              ,trunc(decode(Y.opp_open_status_flag,'Y',X.creation_date,X.last_update_date))creation_date
              ,sum(decode(Y.opp_open_status_flag,'Y',1,0)) leads_open
              ,sum(decode(Y.opp_open_status_flag,'Y',0,1)) leads_closed
              ,sum(decode(Y.opp_open_status_flag,'Y',convert_currency(nvl(X.currency_code,'USD'),nvl(X.budget_amount,0)),0)) leads_open_amt
              ,sum(decode(Y.opp_open_status_flag,'Y',0,decode(X.status_code,'DEAD_LEAD',convert_currency(nvl(X.currency_code,'USD'),nvl(X.budget_amount,0)),0))) leads_closed_amt
              ,sum(decode(Y.opp_open_status_flag,'Y',decode(X.status_code,'NEW',1,0),0))       leads_new
              ,sum(decode(Y.opp_open_status_flag,'Y',decode(X.status_code,'NEW',convert_currency(nvl(X.currency_code,'USD'),nvl(X.budget_amount,0)),0),0)) leads_new_amt
              ,sum(decode(Y.opp_open_status_flag,'Y',decode(X.lead_rank_id,10000,1,0),0))      leads_hot
              ,sum(decode(Y.opp_open_status_flag,'N',decode(X.status_code,'CONVERTED_TO_OPPORTUNITY',1,0),0)) leads_converted
              ,sum(decode(Y.opp_open_status_flag,'Y',0,decode(X.status_code,'DEAD_LEAD',1,0))) leads_dead
              ,0 opportunities
              ,0 opportunity_amt
              ,0 orders_booked
              ,0 orders_booked_amt
              ,0 forecasted_revenue
              ,0 actual_revenue
              ,0 forecasted_cost
              ,0 actual_cost
              ,0 forecasted_responses
              ,0 positive_responses
              ,0 targeted_customers
FROM
              ams_campaigns_all_b A
              ,ams_source_codes  C
              ,as_sales_leads X
              ,as_statuses_b  Y
WHERE
              X.status_code = Y.status_code
              AND   A.campaign_id = C.source_code_for_id
              AND   C.arc_source_code_for = 'CAMP'
              AND   A.source_code = C.source_code
              AND   C.source_code_id = X.source_promotion_id
              AND   Y.lead_flag = 'Y'
              AND   Y.enabled_flag = 'Y'
              AND   NVL(X.DELETED_FLAG,'N') <> 'Y'
              AND   trunc(decode(Y.opp_open_status_flag,'Y',X.creation_date,X.last_update_date)) between                    p_start_date and p_end_date+0.99999
GROUP BY
              a.campaign_id
              ,trunc(decode(Y.opp_open_status_flag,'Y',X.creation_date,X.last_update_date))
UNION ALL
SELECT
              A.campaign_id campaign_id
              ,trunc(X.creation_date) creation_date
              ,0 leads_open
              ,0 leads_closed
              ,0 leads_open_amt
              ,0 leads_closed_amt
              ,0 leads_new
              ,0 leads_new_amt
              ,0 leads_hot
              ,0 leads_converted
              ,0 leads_dead
              ,count(distinct X.lead_id) opportunities
              ,sum(convert_currency(nvl(X.currency_code,'USD'),nvl(X.total_amount,0))) opportunity_amt
              ,0 orders_booked
              ,0 orders_booked_amt
              ,0 forecasted_revenue
              ,0 actual_revenue
              ,0 forecasted_cost
              ,0 actual_cost
              ,0 forecasted_responses
              ,0 positive_responses
              ,0 targeted_customers
FROM
              ams_campaigns_all_b A
              ,ams_source_codes  C
              ,as_leads_all 	X
WHERE
                  A.campaign_id = C.source_code_for_id
              AND C.arc_source_code_for = 'CAMP'
              AND A.source_code = C.source_code
              AND C.source_code_id = X.source_promotion_id
              AND trunc(X.creation_date) between p_start_date and p_end_date+0.99999
GROUP BY
              A.campaign_id,trunc(X.creation_date)
UNION ALL
SELECT
              A.campaign_id campaign_id
              ,trunc(H.creation_date) 	creation_date
              ,0 leads_open
              ,0 leads_closed
              ,0 leads_open_amt
              ,0 leads_closed_amt
              ,0 leads_new
              ,0 leads_new_amt
              ,0 leads_hot
              ,0 leads_converted
              ,0 leads_dead
              ,0 opportunities
              ,0 opportunity_amt
              ,count(distinct(h.header_id)) orders_booked
              ,sum(decode(h.flow_status_code,'BOOKED',convert_currency(nvl(H.transactional_curr_code,'USD')
              ,nvl(I.unit_selling_price * I.ordered_quantity,0)),0)) orders_booked_amt
,0 forecasted_revenue
              ,0 actual_revenue
              ,0 forecasted_cost
              ,0 actual_cost
              ,0 forecasted_responses
              ,0 positive_responses
              ,0 targeted_customers
FROM
              ams_campaigns_all_b A
              ,ams_source_codes  	C
              ,as_sales_leads      	D
              ,as_sales_lead_opportunity      	D1
              ,as_leads_all              E
              ,aso_quote_related_objects F
              ,aso_quote_headers_all     G
              ,oe_order_headers_all     H
              ,oe_order_lines_all	I
WHERE
                  A.campaign_id = C.source_code_for_id
              AND C.arc_source_code_for = 'CAMP'
              AND A.source_code = C.source_code
              AND C.source_code_id =  D.source_promotion_id
              AND D.sales_lead_id = D1.sales_lead_id
              AND D1.opportunity_id   = E.lead_id
              AND E.lead_id           = F.object_id
              AND F.relationship_type_code = 'OPP_QUOTE'
              AND F.quote_object_type_code = 'HEADER'
              AND F.quote_object_id  = G.quote_header_id
              AND G.order_id = H.header_id
              AND H.flow_status_code    = 'BOOKED'
              AND NVL(D.deleted_flag,'N') <> 'Y'
              AND I.header_id = H.header_id
              AND trunc(H.creation_date) between p_start_date and p_end_date+0.99999
GROUP BY
              A.campaign_id,trunc(H.creation_date)
UNION ALL
SELECT
              f3.act_metric_used_by_id campaign_id
              ,trunc(f3.creation_date)    creation_date
              ,0 leads_open
              ,0 leads_closed
              ,0 leads_open_amt
              ,0 leads_closed_amt
              ,0 leads_new
              ,0 leads_new_amt
              ,0 leads_hot
              ,0 leads_converted
              ,0 leads_dead
              ,0 opportunities
              ,0 opportunity_amt
              ,0 orders_booked
              ,0 orders_booked_amt
              ,sum(convert_currency(nvl(f3.functional_currency_code,'USD'),nvl(f3.func_forecasted_delta,0)))
        forecasted_revenue
              ,sum(convert_currency(nvl(f3.functional_currency_code,'USD'),nvl(f3.func_actual_delta,0)))
        actual_revenue
              ,0 forecasted_cost
              ,0 actual_cost
              ,0 forecasted_responses
              ,0 positive_responses
              ,0 targeted_customers
FROM
              ams_act_metric_hst                f3
              ,ams_metrics_all_b                 g3
WHERE
                     f3.arc_act_metric_used_by       = 'CAMP'
              AND    g3.metric_calculation_type         IN ('MANUAL','FUNCTION')
              AND    g3.metric_category             = 902
              AND    g3.metric_id                    = f3.metric_id
              AND    trunc(f3.creation_date) between p_start_date and p_end_date+0.99999
GROUP BY
              f3.act_metric_used_by_id,trunc(f3.creation_date)
HAVING
              sum(convert_currency(nvl(f3.functional_currency_code,'USD'),nvl(f3.func_forecasted_delta,0))) <> 0
              OR
              sum(convert_currency(nvl(f3.functional_currency_code,'USD'),nvl(f3.func_actual_delta,0))) <> 0
UNION ALL
SELECT
              f1.act_metric_used_by_id campaign_id
              ,trunc(f1.creation_date) creation_date
              ,0 leads_open
              ,0 leads_closed
              ,0 leads_open_amt
              ,0 leads_closed_amt
              ,0 leads_new
              ,0 leads_new_amt
              ,0 leads_hot
              ,0 leads_converted
              ,0 leads_dead
              ,0 opportunities
              ,0 opportunity_amt
              ,0 orders_booked
              ,0 orders_booked_amt
              ,0 forecasted_revenue
              ,0 actual_revenue
              ,sum(convert_currency(nvl(f1.functional_currency_code,'USD'),nvl(f1.func_forecasted_delta,0)))
                 forecasted_cost
              ,sum(convert_currency(nvl(f1.functional_currency_code,'USD'),nvl(f1.func_actual_delta,0)))
                 actual_cost
              ,0 forecasted_responses
              ,0 positive_responses
              ,0 targeted_customers
FROM
              ams_act_metric_hst            f1
              ,ams_metrics_all_b            g1
WHERE
               f1.arc_act_metric_used_by       = 'CAMP'
        AND    g1.metric_category              = 901
        AND    g1.metric_id                    = f1.metric_id
        AND    g1.metric_calculation_type         IN ('MANUAL','FUNCTION')
        AND    trunc(f1.creation_date) between p_start_date and p_end_date+0.99999
GROUP BY
               f1.act_metric_used_by_id,trunc(f1.creation_date)
HAVING
              sum(convert_currency(nvl(f1.functional_currency_code,'USD'),nvl(f1.func_forecasted_delta,0))) <> 0
              OR
              sum(convert_currency(nvl(f1.functional_currency_code,'USD'),nvl(f1.func_actual_delta,0))) <> 0
UNION ALL
SELECT
               f3.act_metric_used_by_id campaign_id
               ,trunc(f3.creation_date) creation_date
               ,0 leads_open
               ,0 leads_closed
               ,0 leads_open_amt
               ,0 leads_closed_amt
               ,0 leads_new
               ,0 leads_new_amt
               ,0 leads_hot
               ,0 leads_converted
               ,0 leads_dead
               ,0 opportunities
               ,0 opportunity_amt
               ,0 orders_booked
               ,0 orders_booked_amt
               ,0 forecasted_revenue
               ,0 actual_revenue
               ,0 forecasted_cost
               ,0 actual_cost
               ,sum(nvl(f3.func_forecasted_delta,0)) forecasted_responses
               ,0 positive_responses
               ,0 targeted_customers
FROM
               ams_act_metric_hst               f3
               ,ams_metrics_all_b                g3
WHERE
               f3.arc_act_metric_used_by       = 'CAMP'
        AND    g3.metric_calculation_type         IN ('MANUAL','FUNCTION')
        AND    g3.metric_category              = 903
        AND    g3.metric_id                    = f3.metric_id
        AND    trunc(f3.creation_date) between p_start_date and p_end_date+0.99999
GROUP BY
               f3.act_metric_used_by_id,trunc(f3.creation_date)
HAVING
               sum(nvl(f3.func_forecasted_delta,0)) <> 0
UNION ALL
SELECT
               A.campaign_id campaign_id
               ,trunc(X.creation_date) creation_date
               ,0 leads_open
               ,0 leads_closed
               ,0 leads_open_amt
               ,0 leads_closed_amt
               ,0 leads_new
               ,0 leads_new_amt
               ,0 leads_hot
               ,0 leads_converted
               ,0 leads_dead
               ,0 opportunities
               ,0 opportunity_amt
               ,0 orders_booked
               ,0 orders_booked_amt
               ,0 forecasted_revenue
               ,0 actual_revenue
               ,0 forecasted_cost
               ,0 actual_cost
               ,0 forecasted_responses
               ,count(Y.result_id)  positive_responses
               ,0 targeted_customers
               FROM    ams_campaigns_all_b A
                       ,jtf_ih_interactions X
                       ,jtf_ih_results_b Y
WHERE
               A.source_code = X.source_code
           AND X.result_id = Y.result_id
           AND Y.positive_response_flag = 'Y'
           AND trunc(X.creation_date) between p_start_date and p_end_date+0.99999
GROUP BY
           A.campaign_id,trunc(X.creation_date)
) metric
GROUP BY
           metric.campaign_id
           ,metric.creation_date
) inner
           ,ams_campaigns_all_b    A
           ,ams_source_codes       C
           ,jtf_loc_hierarchies_b  D
WHERE
                  a.campaign_id        =  inner.campaign_id
           AND    A.campaign_id        = C.source_code_for_id
           AND    C.arc_source_code_for = 'CAMP'
           AND    A.source_code        = C.source_code
           AND    a.city_id            =  d.location_hierarchy_id
           AND    a.status_code        IN ('ACTIVE', 'CANCELLED', 'COMPLETED','CLOSED')
           AND    a.rollup_type        <> 'RCAM'
           AND    trunc(a.actual_exec_start_date)    >= trunc(p_start_date)
)Outer;

     COMMIT;

      l_temp_msg := to_char( sysdate, 'dd/mm/yyyy:hh:mi:ss');
      ams_utility_pvt.write_conc_log('BIM_CAMPAIGN_FACTS:FIRST_LOAD: AFTER FIRST INSERT ' || l_temp_msg);

      l_temp_msg := to_char( sysdate, 'dd/mm/yyyy:hh:mi:ss');
      ams_utility_pvt.write_conc_log('BIM_CAMPAIGN_FACTS:FIRST_LOAD: BEFORE SECOND INSERT ' || l_temp_msg);

      INSERT /*+ append parallel(CDF,1) */
      INTO bim_r_camp_daily_facts CDF
      (
               campaign_daily_transaction_id
              ,creation_date
              ,last_update_date
              ,created_by
              ,last_updated_by
              ,last_update_login
              ,campaign_id
              ,schedule_id
              ,transaction_create_date
              ,schedule_source_code
              ,campaign_source_code
              ,schedule_activity_type
	      ,schedule_activity_id
              ,campaign_purpose
              ,campaign_type
              ,start_date
              ,end_date
              ,schedule_purpose
              ,business_unit_id
              ,org_id
	      ,campaign_status
              ,schedule_status
              ,campaign_country
              ,campaign_region
              ,schedule_region
              ,schedule_country
              ,campaign_budget_fc
              ,schedule_budget_fc
              ,load_date
	      ,year
	      ,qtr
              ,month
              ,leads_open
              ,leads_closed
              ,leads_open_amt
              ,leads_closed_amt
	      ,leads_new
	      ,leads_new_amt
	      ,leads_hot
	      ,leads_converted
	      ,metric1 -- leads_dead
              ,opportunities
	      ,opportunity_amt
              ,orders_booked
              ,orders_booked_amt
              ,forecasted_revenue
              ,actual_revenue
              ,forecasted_cost
              ,actual_cost
              ,forecasted_responses
              ,positive_responses
              ,targeted_customers
              ,budget_requested
              ,budget_approved
      )
      SELECT  /*+ parallel(INNER,1) */
		bim_r_camp_daily_facts_s.nextval
              ,sysdate
              ,sysdate
              ,-1
              ,-1
              ,-1
              ,campaign_id
              ,schedule_id
              ,transaction_create_date
              ,schedule_source_code
              ,campaign_source_code
              ,schedule_activity_type
	      ,schedule_activity_id
              ,campaign_purpose
              ,campaign_type
              ,start_date
              ,end_date
              ,schedule_purpose
              ,business_unit_id
              ,org_id
	      ,campaign_status
              ,schedule_status
              ,campaign_country
              ,campaign_region
              ,schedule_region
              ,schedule_country
              ,0 schedule_budget_fc
              ,0 campaign_budget_fc
              ,weekend_date
	      ,year
	      ,qtr
              ,month
              ,leads_open
              ,leads_closed
              ,leads_open_amt
              ,leads_closed_amt
	      ,leads_new
	      ,leads_new_amt
	      ,leads_hot
	      ,leads_converted
	      ,leads_dead
              ,opportunities
	      ,opportunity_amt
              ,orders_booked
              ,orders_booked_amt
              ,0 forecasted_revenue
              ,0 actual_revenue
              ,0 forecasted_cost
              ,0 actual_cost
              ,0 forecasted_responses
              ,positive_responses
              ,targeted_customers
              ,0 request_amount
	      ,0 approved_amount
      FROM
      (
SELECT
	      a.campaign_id		campaign_id
              ,e.schedule_id		schedule_id
      	      ,inner.creation_date	transaction_create_date
              ,e.source_code		schedule_source_code
      	      ,b2.source_code_id	campaign_source_code_id
      	      ,b1.source_code_id	schedule_source_code_id
	      ,a.source_code		campaign_source_code
              ,e.activity_type_code	schedule_activity_type
	      ,decode(e.activity_type_code,'EVENTS',-9999, e.activity_id) schedule_activity_id
	      ,a.campaign_type		campaign_purpose
              ,a.rollup_type		campaign_type
              ,e.start_date_time	start_date
              ,nvl(e.end_date_time, a.actual_exec_end_date)	        end_date
              ,e.objective_code		schedule_purpose
              ,a.business_unit_id	business_unit_id
              ,e.org_id			org_id
	      ,a.status_code		campaign_status
              ,e.status_code		schedule_status
              ,a.city_id		campaign_country
              ,d2.area2_code		campaign_region
              ,d1.area2_code		schedule_region
              ,e.country_id		schedule_country
              ,(decode(decode( to_char(inner.creation_date,'MM') , to_char(next_day(inner.creation_date,TO_NUMBER(to_char(to_date('07/09/2004', 'DD/MM/RRRR'), 'DD'))),'MM') ,'TRUE','FALSE' )
      	        ,'TRUE'
      	        ,decode(decode(inner.creation_date , (next_day(inner.creation_date, TO_NUMBER(to_char(to_date('07/09/2004', 'DD/MM/RRRR'), 'DD'))) - 7) , 'TRUE' ,'FALSE')
       	        ,'TRUE'
      	        ,inner.creation_date
      	        ,'FALSE'
      	        ,next_day(inner.creation_date, TO_NUMBER(to_char(to_date('07/09/2004', 'DD/MM/RRRR'), 'DD'))))
      	        ,'FALSE'
      	        ,decode(decode(to_char(inner.creation_date,'MM'),to_char(next_day(inner.creation_date,TO_NUMBER(to_char(to_date('07/09/2004', 'DD/MM/RRRR'), 'DD'))),'MM'),'TRUE','FALSE')
      	        ,'FALSE'
      	        ,last_day(inner.creation_date))))         weekend_date
              ,bim_set_of_books.get_fiscal_year(inner.creation_date,0) year
              ,bim_set_of_books.get_fiscal_qtr(inner.creation_date,0)  qtr
              ,bim_set_of_books.get_fiscal_month(inner.creation_date,0) month
              ,inner.leads_open            leads_open
              ,inner.leads_closed          leads_closed
              ,inner.leads_open_amt    	  leads_open_amt
              ,inner.leads_closed_amt      leads_closed_amt
	      ,inner.leads_new		  leads_new
	      ,inner.leads_new_amt	  leads_new_amt
	      ,inner.leads_hot		  leads_hot
	      ,inner.leads_converted	  leads_converted
	      ,inner.leads_dead		  leads_dead
              ,inner.opportunities         opportunities
	      ,inner.opportunity_amt	  opportunity_amt
              ,inner.orders_booked	  orders_booked
              ,inner.orders_booked_amt	  orders_booked_amt
              ,inner.forecasted_revenue 	  forecasted_revenue
              ,inner.actual_revenue        actual_revenue
              ,inner.forecasted_cost       forecasted_cost
              ,inner.actual_cost           actual_cost
              ,inner.forecasted_responses  forecasted_responses
              ,inner.positive_responses    positive_responses
              ,inner.targeted_customers	  targeted_customers
FROM  (
SELECT
               metric.schedule_id schedule_id
              ,metric.creation_date creation_date
              ,sum(nvl(metric.leads_open,0))  	       leads_open
              ,sum(nvl(metric.leads_closed,0))	       leads_closed
              ,sum(nvl(metric.leads_open_amt,0))       leads_open_amt
              ,sum(nvl(metric.leads_closed_amt,0))     leads_closed_amt
	      ,sum(nvl(metric.leads_new,0))	       leads_new
	      ,sum(nvl(metric.leads_new_amt,0))	       leads_new_amt
	      ,sum(nvl(metric.leads_hot,0))	       leads_hot
	      ,sum(nvl(metric.leads_converted,0))      leads_converted
	      ,sum(nvl(metric.leads_dead,0))	       leads_dead
              ,sum(nvl(metric.opportunities,0))        opportunities
	      ,sum(nvl(metric.opportunity_amt,0))      opportunity_amt
              ,sum(nvl(metric.orders_booked,0))	       orders_booked
              ,sum(nvl(metric.orders_booked_amt,0))    orders_booked_amt
              ,0   forecasted_revenue
              ,0       actual_revenue
              ,0      forecasted_cost
              ,0          actual_cost
              ,0 forecasted_responses
              ,sum(nvl(metric.positive_responses,0))   positive_responses
              ,sum(nvl(metric.targeted_customers,0))   targeted_customers
FROM (
SELECT
              A.schedule_id schedule_id
              ,trunc(decode(Y.opp_open_status_flag,'Y',X.creation_date,X.last_update_date))creation_date
              ,sum(decode(Y.opp_open_status_flag,'Y',1,0)) leads_open
              ,sum(decode(Y.opp_open_status_flag,'Y',0,1)) leads_closed
              ,sum(decode(Y.opp_open_status_flag,'Y',convert_currency(nvl(X.currency_code,'USD'),nvl(X.budget_amount,0)),0)) leads_open_amt
              ,sum(decode(Y.opp_open_status_flag,'Y',0,decode(X.status_code,'DEAD_LEAD',convert_currency(nvl(X.currency_code,'USD'),nvl(X.budget_amount,0)),0))) leads_closed_amt
              ,sum(decode(Y.opp_open_status_flag,'Y',decode(X.status_code,'NEW',1,0),0))       leads_new
              ,sum(decode(Y.opp_open_status_flag,'Y',decode(X.status_code,'NEW',convert_currency(nvl(X.currency_code,'USD'),nvl(X.budget_amount,0)),0),0)) leads_new_amt
              ,sum(decode(Y.opp_open_status_flag,'Y',decode(X.lead_rank_id,10000,1,0),0))      leads_hot
              ,sum(decode(Y.opp_open_status_flag,'N',decode(X.status_code,'CONVERTED_TO_OPPORTUNITY',1,0),0)) leads_converted
              ,sum(decode(Y.opp_open_status_flag,'Y',0,decode(X.status_code,'DEAD_LEAD',1,0))) leads_dead
              ,0 opportunities
              ,0 opportunity_amt
              ,0 orders_booked
              ,0 orders_booked_amt
              ,0 forecasted_revenue
              ,0 actual_revenue
              ,0 forecasted_cost
              ,0 actual_cost
              ,0 forecasted_responses
              ,0 positive_responses
              ,0 targeted_customers
FROM
              ams_campaign_schedules_b A
              ,ams_source_codes  C
              ,as_sales_leads X
              ,as_statuses_b  Y
WHERE
                    A.schedule_id = C.source_code_for_id
              AND   C.arc_source_code_for = 'CSCH'
              AND   A.source_code = C.source_code
              AND   C.source_code_id = X.source_promotion_id
              AND   X.status_code = Y.status_code
              AND   Y.lead_flag = 'Y'
              AND   Y.enabled_flag = 'Y'
              AND   NVL(X.DELETED_FLAG,'N') <> 'Y'
              AND   trunc(decode(Y.opp_open_status_flag,'Y',X.creation_date,X.last_update_date)) between p_start_date and p_end_date+0.99999
GROUP BY
              a.schedule_id
              ,trunc(decode(Y.opp_open_status_flag,'Y',X.creation_date,X.last_update_date))
UNION ALL
SELECT
              A.schedule_id schedule_id
              ,trunc(X.creation_date) creation_date
              ,0 leads_open
              ,0 leads_closed
              ,0 leads_open_amt
              ,0 leads_closed_amt
              ,0 leads_new
              ,0 leads_new_amt
              ,0 leads_hot
              ,0 leads_converted
              ,0 leads_dead
              ,count(distinct X.lead_id) opportunities
              ,sum(convert_currency(nvl(X.currency_code,'USD'),nvl(X.total_amount,0))) opportunity_amt
              ,0 orders_booked
              ,0 orders_booked_amt
              ,0 forecasted_revenue
              ,0 actual_revenue
              ,0 forecasted_cost
              ,0 actual_cost
              ,0 forecasted_responses
              ,0 positive_responses
              ,0 targeted_customers
FROM
              ams_campaign_schedules_b A
              ,ams_source_codes  C
              ,as_leads_all 	X
WHERE
                  A.schedule_id = C.source_code_for_id
              AND C.arc_source_code_for = 'CSCH'
              AND A.source_code = C.source_code
              AND C.source_code_id = X.source_promotion_id
              AND trunc(X.creation_date) between p_start_date and p_end_date+0.99999
GROUP BY
              A.schedule_id,trunc(X.creation_date)
UNION ALL
SELECT
              A.schedule_id schedule_id
              ,trunc(H.creation_date) 	creation_date
              ,0 leads_open
              ,0 leads_closed
              ,0 leads_open_amt
              ,0 leads_closed_amt
              ,0 leads_new
              ,0 leads_new_amt
              ,0 leads_hot
              ,0 leads_converted
              ,0 leads_dead
              ,0 opportunities
              ,0 opportunity_amt
              ,count(distinct(h.header_id)) orders_booked
              ,sum(decode(h.flow_status_code,'BOOKED',convert_currency(nvl(H.transactional_curr_code,'USD')
              ,nvl(I.unit_selling_price * I.ordered_quantity,0)),0)) orders_booked_amt
              ,0 forecasted_revenue
              ,0 actual_revenue
              ,0 forecasted_cost
              ,0 actual_cost
              ,0 forecasted_responses
              ,0 positive_responses
              ,0 targeted_customers
FROM
              ams_campaign_schedules_b A
              ,ams_source_codes  	C
              ,as_sales_leads      	D
              ,as_sales_lead_opportunity      	D1
              ,as_leads_all              E
              ,aso_quote_related_objects F
              ,aso_quote_headers_all     G
              ,oe_order_headers_all     H
              ,oe_order_lines_all	I
WHERE
               A.schedule_id = C.source_code_for_id
              AND C.arc_source_code_for = 'CSCH'
              AND A.source_code = C.source_code
              AND C.source_code_id =  D.source_promotion_id
              AND D.sales_lead_id = D1.sales_lead_id
              AND D1.opportunity_id     = E.lead_id
              AND E.lead_id           = F.object_id
              AND F.relationship_type_code = 'OPP_QUOTE'
              AND F.quote_object_type_code = 'HEADER'
              AND F.quote_object_id  = G.quote_header_id
              AND G.order_id = H.header_id
              AND H.flow_status_code    = 'BOOKED'
              AND NVL(D.deleted_flag,'N') <> 'Y'
              AND I.header_id = H.header_id
              AND trunc(H.creation_date) between p_start_date and p_end_date+0.99999
GROUP BY
              A.schedule_id,trunc(H.creation_date)
UNION ALL
SELECT
              f3.act_metric_used_by_id schedule_id
              ,trunc(f3.creation_date)    creation_date
              ,0 leads_open
              ,0 leads_closed
              ,0 leads_open_amt
              ,0 leads_closed_amt
              ,0 leads_new
              ,0 leads_new_amt
              ,0 leads_hot
              ,0 leads_converted
              ,0 leads_dead
              ,0 opportunities
              ,0 opportunity_amt
              ,0 orders_booked
              ,0 orders_booked_amt
              ,sum(convert_currency(nvl(f3.functional_currency_code,'USD'),nvl(f3.func_forecasted_delta,0)))
        forecasted_revenue
              ,sum(convert_currency(nvl(f3.functional_currency_code,'USD'),nvl(f3.func_actual_delta,0)))
        actual_revenue
              ,0 forecasted_cost
              ,0 actual_cost
              ,0 forecasted_responses
              ,0 positive_responses
              ,0 targeted_customers
FROM
              ams_act_metric_hst                f3
              ,ams_metrics_all_b                 g3
WHERE
                     f3.arc_act_metric_used_by       = 'CSCH'
              AND    g3.metric_calculation_type         IN ('MANUAL','FUNCTION')
              AND    g3.metric_category             = 902
              AND    g3.metric_id                    = f3.metric_id
              AND    trunc(f3.creation_date) between p_start_date and p_end_date+0.99999
GROUP BY
              f3.act_metric_used_by_id,trunc(f3.creation_date)
HAVING
              sum(convert_currency(nvl(f3.functional_currency_code,'USD'),nvl(f3.func_forecasted_delta,0))) <> 0
              OR
              sum(convert_currency(nvl(f3.functional_currency_code,'USD'),nvl(f3.func_actual_delta,0))) <> 0
UNION ALL
SELECT
              f1.act_metric_used_by_id schedule_id
              ,trunc(f1.creation_date) creation_date
              ,0 leads_open
              ,0 leads_closed
              ,0 leads_open_amt
              ,0 leads_closed_amt
              ,0 leads_new
              ,0 leads_new_amt
              ,0 leads_hot
              ,0 leads_converted
              ,0 leads_dead
              ,0 opportunities
              ,0 opportunity_amt
              ,0 orders_booked
              ,0 orders_booked_amt
              ,0 forecasted_revenue
              ,0 actual_revenue
              ,sum(convert_currency(nvl(f1.functional_currency_code,'USD'),nvl(f1.func_forecasted_delta,0)))
                 forecasted_cost
              ,sum(convert_currency(nvl(f1.functional_currency_code,'USD'),nvl(f1.func_actual_delta,0)))
                 actual_cost
              ,0 forecasted_responses
              ,0 positive_responses
              ,0 targeted_customers
FROM
              ams_act_metric_hst            f1
              ,ams_metrics_all_b            g1
WHERE
               f1.arc_act_metric_used_by       = 'CSCH'
        AND    g1.metric_category              = 901
        AND    g1.metric_id                    = f1.metric_id
        AND    g1.metric_calculation_type         IN ('MANUAL','FUNCTION')
        AND    trunc(f1.creation_date) between p_start_date and p_end_date+0.99999
GROUP BY
               f1.act_metric_used_by_id,trunc(f1.creation_date)
HAVING
              sum(convert_currency(nvl(f1.functional_currency_code,'USD'),nvl(f1.func_forecasted_delta,0))) <> 0
              OR
              sum(convert_currency(nvl(f1.functional_currency_code,'USD'),nvl(f1.func_actual_delta,0))) <> 0
UNION ALL
SELECT
               f3.act_metric_used_by_id schedule_id
               ,trunc(f3.creation_date) creation_date
               ,0 leads_open
               ,0 leads_closed
               ,0 leads_open_amt
               ,0 leads_closed_amt
               ,0 leads_new
               ,0 leads_new_amt
               ,0 leads_hot
               ,0 leads_converted
               ,0 leads_dead
               ,0 opportunities
               ,0 opportunity_amt
               ,0 orders_booked
               ,0 orders_booked_amt
               ,0 forecasted_revenue
               ,0 actual_revenue
               ,0 forecasted_cost
               ,0 actual_cost
               ,sum(nvl(f3.func_forecasted_delta,0)) forecasted_responses
               ,0 positive_responses
               ,0 targeted_customers
FROM
               ams_act_metric_hst               f3
               ,ams_metrics_all_b                g3
WHERE
               f3.arc_act_metric_used_by       = 'CSCH'
        AND    g3.metric_calculation_type         IN ('MANUAL','FUNCTION')
        AND    g3.metric_category              = 903
        AND    g3.metric_id                    = f3.metric_id
        AND    trunc(f3.creation_date) between p_start_date and p_end_date+0.99999
GROUP BY
               f3.act_metric_used_by_id,trunc(f3.creation_date)
HAVING
               sum(nvl(f3.func_forecasted_delta,0)) <> 0
UNION ALL
SELECT
               A.schedule_id schedule_id
               ,trunc(X.creation_date) creation_date
               ,0 leads_open
               ,0 leads_closed
               ,0 leads_open_amt
               ,0 leads_closed_amt
               ,0 leads_new
               ,0 leads_new_amt
               ,0 leads_hot
               ,0 leads_converted
               ,0 leads_dead
               ,0 opportunities
               ,0 opportunity_amt
               ,0 orders_booked
               ,0 orders_booked_amt
               ,0 forecasted_revenue
               ,0 actual_revenue
               ,0 forecasted_cost
               ,0 actual_cost
               ,0 forecasted_responses
               ,sum(decode(A.use_parent_code_flag,'Y',0,1))  positive_responses
               ,0 targeted_customers
               FROM    ams_campaign_schedules_b A
                       ,jtf_ih_interactions X
                       ,jtf_ih_results_b Y
WHERE
               A.source_code = X.source_code
           AND X.result_id = Y.result_id
           AND Y.positive_response_flag = 'Y'
           AND trunc(X.creation_date) between p_start_date and p_end_date+0.99999
GROUP BY
           A.schedule_id,trunc(X.creation_date)
UNION ALL
SELECT
              A.schedule_id schedule_id
              ,trunc(p.creation_date)     creation_date
              ,0 leads_open
              ,0 leads_closed
              ,0 leads_open_amt
              ,0 leads_closed_amt
              ,0 leads_new
              ,0 leads_new_amt
              ,0 leads_hot
              ,0 leads_converted
              ,0 leads_dead
              ,0 opportunities
              ,0 opportunity_amt
              ,0 orders_booked
              ,0 orders_booked_amt
              ,0 forecasted_revenue
              ,0 actual_revenue
              ,0 forecasted_cost
              ,0 actual_cost
              ,0 forecasted_responses
              ,0 positive_responses
              ,count(p.list_entry_id) targeted_customers
FROM
               ams_list_entries p
               ,ams_act_lists q
               ,ams_campaign_schedules_b A
WHERE
                 p.list_header_id   = q.list_header_id
         AND     q.list_used_by     = 'CSCH'
         AND     q.list_act_type = 'TARGET'
         AND     trunc(p.creation_date) between p_start_date and p_end_date+0.99999
         AND     q.list_used_by_id     = A.schedule_id
		 AND      p.enabled_flag='Y'
GROUP   BY
                 A.schedule_id, trunc(p.creation_date)
UNION ALL
SELECT
              A.schedule_id schedule_id
              ,trunc(p.creation_date)     creation_date
              ,0 leads_open
              ,0 leads_closed
              ,0 leads_open_amt
              ,0 leads_closed_amt
              ,0 leads_new
              ,0 leads_new_amt
              ,0 leads_hot
              ,0 leads_converted
              ,0 leads_dead
              ,0 opportunities
              ,0 opportunity_amt
              ,0 orders_booked
              ,0 orders_booked_amt
              ,0 forecasted_revenue
              ,0 actual_revenue
              ,0 forecasted_cost
              ,0 actual_cost
              ,0 forecasted_responses
              ,0 positive_responses
              ,count(p.list_entry_id) targeted_customers
FROM
               ams_list_entries p
               ,ams_act_lists q
               ,ams_campaign_schedules_b A
WHERE
                 trunc(p.creation_date) between p_start_date and p_end_date+0.99999
         AND     p.list_header_id   = q.list_header_id
         AND     q.list_used_by     = 'EONE'
         AND     q.list_act_type    = 'TARGET'
	 AND     A.activity_type_code = 'EVENTS'
         AND     q.list_used_by_id    = A.related_event_id
		 AND      p.enabled_flag='Y'
GROUP   BY
                 A.schedule_id, trunc(p.creation_date)
) metric
GROUP BY
           metric.schedule_id
           ,metric.creation_date
) inner
           ,ams_campaign_schedules_b    E
           ,ams_campaigns_all_b 	    A
           ,ams_source_codes           B1
           ,ams_source_codes           B2
           ,jtf_loc_hierarchies_b  D1
           ,jtf_loc_hierarchies_b  D2
WHERE
                  e.schedule_id             =  inner.schedule_id
           AND    e.campaign_id             =  a.campaign_id
           AND    e.country_id              =  d1.location_hierarchy_id
           AND    a.city_id                 =  d2.location_hierarchy_id
           AND    a.status_code             IN ('ACTIVE', 'CANCELLED', 'COMPLETED','CLOSED')
           AND    e.status_code             IN ('ACTIVE', 'CANCELLED', 'COMPLETED','CLOSED')
           AND    a.rollup_type             <> 'RCAM'
           AND    b1.source_code_for_id     =  decode(e.source_code,a.source_code,a.campaign_id,e.schedule_id)
           AND    b1.arc_source_code_for    =  decode(e.source_code,a.source_code,'CAMP','CSCH')
           AND    b1.source_code            =  e.source_code
           AND    b2.source_code_for_id     =  a.campaign_id
           AND    b2.arc_source_code_for    =  'CAMP'
           AND    b2.source_code            =  a.source_code
           AND    trunc(a.actual_exec_start_date)  >= trunc(p_start_date)
)Outer;

      l_temp_msg := to_char( sysdate, 'dd/mm/yyyy:hh:mi:ss');
      ams_utility_pvt.write_conc_log('BIM_CAMPAIGN_FACTS:FIRST_LOAD: AFTER SECOND INSERT ' || l_temp_msg);

    COMMIT;
    EXECUTE IMMEDIATE 'ALTER SEQUENCE '||l_schema||'.bim_r_camp_daily_facts_s CACHE 20';

/* This insert deals with the budgets for campaigns */

      l_temp_msg := to_char( sysdate, 'dd/mm/yyyy:hh:mi:ss');
      ams_utility_pvt.write_conc_log('BIM_CAMPAIGN_FACTS:FIRST_LOAD: BEFORE THIRD INSERT ' || l_temp_msg);

      INSERT /*+ append parallel(CDF,1) */
      INTO bim_r_camp_daily_facts CDF
      (
               campaign_daily_transaction_id
              ,creation_date
              ,last_update_date
              ,created_by
              ,last_updated_by
              ,last_update_login
              ,campaign_id
              ,schedule_id
              ,transaction_create_date
              ,schedule_source_code
              ,campaign_source_code
              ,schedule_activity_type
	      ,schedule_activity_id
              ,campaign_purpose
              ,campaign_type
              ,start_date
              ,end_date
              ,schedule_purpose
              ,business_unit_id
              ,org_id
	      ,campaign_status
              ,schedule_status
              ,campaign_country
              ,campaign_region
              ,schedule_region
              ,schedule_country
              ,campaign_budget_fc
              ,schedule_budget_fc
              ,load_date
	      ,year
	      ,qtr
              ,month
              ,leads_open
              ,leads_closed
              ,leads_open_amt
              ,leads_closed_amt
	      ,leads_new
	      ,leads_new_amt
	      ,leads_hot
	      ,leads_converted
	      ,metric1 --leads_dead
              ,opportunities
	      ,opportunity_amt
              ,orders_booked
              ,orders_booked_amt
              ,forecasted_revenue
              ,actual_revenue
              ,forecasted_cost
              ,actual_cost
              ,forecasted_responses
              ,positive_responses
              ,targeted_customers
              ,budget_requested
              ,budget_approved
      )
      SELECT  /*+ parallel(INNER,1) */
	      bim_r_camp_daily_facts_s.nextval
              ,sysdate
              ,sysdate
              ,-1
              ,-1
              ,-1
              ,inner.act_budget_used_by_id campaign_id
              ,0 schedule_id
              ,inner.creation_date transaction_create_date
              ,0 schedule_source_code
              ,inner.campaign_source_code campaign_source_code
              ,0 schedule_activity_type
	      ,0 schedule_activity_id
              ,inner.campaign_purpose campaign_purpose
              ,inner.campaign_type campaign_type
              ,inner.start_date start_date
              ,inner.end_date end_date
              ,0 schedule_purpose
              ,inner.business_unit_id business_unit_id
              ,0 org_id
	      ,inner.campaign_status campaign_status
              ,0 schedule_status
              ,inner.campaign_country_code campaign_country
              ,inner.campaign_region_code campaign_region
              ,0 schedule_region
              ,0 schedule_country
              ,inner.campaign_budget_amount campaign_budget_fc
              ,0 schedule_budget_fc
              ,(decode(decode( to_char(inner.creation_date,'MM') , to_char(next_day(inner.creation_date,TO_NUMBER(to_char(to_date('07/09/2004', 'DD/MM/RRRR'), 'DD'))),'MM') ,'TRUE','FALSE' )
      	        ,'TRUE'
      	        ,decode(decode(Inner.creation_date , (next_day(inner.creation_date, TO_NUMBER(to_char(to_date('07/09/2004', 'DD/MM/RRRR'), 'DD'))) - 7) , 'TRUE' ,'FALSE')
       	        ,'TRUE'
      	        ,inner.creation_date
      	        ,'FALSE'
      	        ,next_day(inner.creation_date, TO_NUMBER(to_char(to_date('07/09/2004', 'DD/MM/RRRR'), 'DD'))))
      	        ,'FALSE'
      	        ,decode(decode(to_char(inner.creation_date,'MM'),to_char(next_day(inner.creation_date,TO_NUMBER(to_char(to_date('07/09/2004', 'DD/MM/RRRR'), 'DD'))),'MM'),'TRUE','FALSE')
      	        ,'FALSE'
      	        ,last_day(Inner.creation_date))))         weekend_date
	      ,bim_set_of_books.get_fiscal_year(inner.creation_date,0) year
              ,bim_set_of_books.get_fiscal_qtr(inner.creation_date,0)  qtr
              ,bim_set_of_books.get_fiscal_month(inner.creation_date,0) month
              ,0 leads_open
              ,0 leads_closed
              ,0 leads_open_amt
              ,0 leads_closed_amt
	      ,0 leads_new
	      ,0 leads_new_amt
	      ,0 leads_hot
	      ,0 leads_converted
	      ,0 leads_dead
              ,0 opportunities
	      ,0 opportunity_amt
              ,0 orders_booked
              ,0 orders_booked_amt
              ,0 forecasted_revenue
              ,0 actual_revenue
              ,0 forecasted_cost
              ,0 actual_cost
              ,0 forecasted_responses
              ,0 positive_responses
              ,0 targeted_customers
              ,inner.request_amount request_amount
	      ,inner.approved_amount approved_amount
FROM
      (
        SELECT
                s.act_budget_used_by_id   act_budget_used_by_id
                ,decode(s.status_code
		   ,'PENDING'
		   ,trunc(nvl(s.request_date,s.creation_date))
		   ,'APPROVED'
                   ,trunc(nvl(s.approval_date,s.last_update_date))
		   ) creation_date
                ,sum(decode(s.status_code
                   ,'PENDING'
                   ,convert_currency(nvl(request_currency,'USD'),nvl(s.request_amount,0))
                   ,'APPROVED'
                   ,convert_currency(nvl(request_currency,'USD'),nvl(s.request_amount,0))
                   ))  request_amount
                ,sum(decode(s.status_code
                   ,'PENDING'
                   ,0
                   ,'APPROVED'
                   ,convert_currency(nvl(approved_in_currency,'USD'),nvl(s.approved_original_amount,0))
                   ))    approved_amount
                ,b2.source_code_id      	  campaign_source_code_id
                ,a.source_code          	  campaign_source_code
                ,a.campaign_type        	  campaign_purpose
                ,a.status_code   		  campaign_status
                ,a.rollup_type          	  campaign_type
                ,a.actual_exec_start_date   start_date
                ,a.actual_exec_end_date     end_date
                ,a.business_unit_id     	  business_unit_id
                ,a.city_id              	  campaign_country_code
                ,d.area2_code           	  campaign_region_code
                ,a.budget_amount_fc     	  campaign_budget_amount
        FROM    ams_act_budgets    	    S
                ,ams_campaigns_all_b     A
                ,ams_source_codes        B2
                ,jtf_loc_hierarchies_b   D
        WHERE   s.arc_act_budget_used_by         = 'CAMP'
                AND    s.budget_source_type      = 'FUND'
                --AND    s.transfer_type         = 'REQUEST'
                AND    s.act_budget_used_by_id 	 = a.campaign_id
                AND    a.city_id                 =  d.location_hierarchy_id
                AND    a.status_code             IN ('ACTIVE', 'CANCELLED', 'COMPLETED','CLOSED')
                AND    a.rollup_type           <> 'RCAM'
                AND    b2.source_code            =  a.source_code
                AND    a.actual_exec_start_date  >= p_start_date
                AND    a.actual_exec_start_date  <= p_end_date
                AND    decode(s.status_code,'PENDING',trunc(nvl(s.request_date,s.creation_date)),'APPROVED',trunc(nvl(s.approval_date,s.last_update_date)) )           <= p_end_date
                AND    exists (select distinct campaign_id
                               from ams_campaign_schedules_b x
                               where x.campaign_id = a.campaign_id)
        GROUP BY s.act_budget_used_by_id
                 ,decode(s.status_code,'PENDING',trunc(nvl(s.request_date,s.creation_date)),'APPROVED',trunc(nvl(s.approval_date,s.last_update_date)) )
                 ,b2.source_code_id
                 ,a.source_code
                 ,a.campaign_type
                 ,a.status_code
                 ,a.rollup_type
                 ,a.actual_exec_start_date
                 ,a.actual_exec_end_date
                 ,a.business_unit_id
                 ,a.city_id
                 ,d.area2_code
                 ,a.budget_amount_fc
        HAVING   sum(decode(s.status_code
                   ,'PENDING'
                   ,convert_currency(nvl(request_currency,'USD'),nvl(s.request_amount,0))
                   ,'APPROVED'
                   ,convert_currency(nvl(request_currency,'USD'),nvl(s.request_amount,0))
                   )) > 0
        OR
                 sum(decode(s.status_code
                   ,'PENDING'
                   ,0
                   ,'APPROVED'
                   ,convert_currency(nvl(approved_in_currency,'USD'),nvl(s.approved_original_amount,0))
                   ))    > 0
	UNION ALL
        SELECT
                 s.budget_source_id   		  act_budget_used_by_id
                ,trunc(nvl(s.approval_date,s.last_update_date)) creation_date
                ,-sum(convert_currency(nvl(approved_in_currency,'USD'),nvl(s.approved_original_amount,0))) request_amount
                , -sum(convert_currency(nvl(approved_in_currency,'USD'),nvl(s.approved_original_amount,0))) approved_amount
                ,b2.source_code_id      	  campaign_source_code_id
                ,a.source_code          	  campaign_source_code
                ,a.campaign_type        	  campaign_purpose
                ,a.status_code   		  campaign_status
                ,a.rollup_type          	  campaign_type
                ,a.actual_exec_start_date   	  start_date
                ,a.actual_exec_end_date     	  end_date
                ,a.business_unit_id     	  business_unit_id
                ,a.city_id              	  campaign_country_code
                ,d.area2_code           	  campaign_region_code
                ,a.budget_amount_fc     	  campaign_budget_amount
        FROM    ams_act_budgets    	    S
                ,ams_campaigns_all_b     A
                ,ams_source_codes        B2
                ,jtf_loc_hierarchies_b   D
        WHERE   s.arc_act_budget_used_by         = 'FUND'
                AND    s.budget_source_type      = 'CAMP'
                --AND    s.transfer_type         = 'REQUEST'
                AND    s.budget_source_id 	 = a.campaign_id
                AND    a.city_id                 =  d.location_hierarchy_id
                AND    a.status_code             IN ('ACTIVE', 'CANCELLED', 'COMPLETED','CLOSED')
                AND    a.rollup_type           <> 'RCAM'
                AND    b2.source_code            =  a.source_code
                AND    a.actual_exec_start_date  >= trunc(p_start_date)
                AND    a.actual_exec_start_date  <= trunc(p_end_date)
                AND    s.approval_date           <= trunc(p_end_date)
                AND    exists (select distinct campaign_id
                               from ams_campaign_schedules_b x
                               where x.campaign_id = a.campaign_id)
        GROUP BY s.budget_source_id
                ,trunc(nvl(s.approval_date,s.last_update_date))
                 ,b2.source_code_id
                 ,a.source_code
                 ,a.campaign_type
                 ,a.status_code
                 ,a.rollup_type
                 ,a.actual_exec_start_date
                 ,a.actual_exec_end_date
                 ,a.business_unit_id
                 ,a.city_id
                 ,d.area2_code
                 ,a.budget_amount_fc
        HAVING  sum(decode(s.status_code
                   ,'PENDING'
                   ,0
                   ,'APPROVED'
                   ,convert_currency(nvl(approved_in_currency,'USD'),nvl(s.approved_original_amount,0))
                   ))    > 0
    )INNER;




 COMMIT;


   l_temp_msg := to_char( sysdate, 'dd/mm/yyyy:hh:mi:ss');
   ams_utility_pvt.write_conc_log('BIM_CAMPAIGN_FACTS:FIRST_LOAD: AFTER THIRD INSERT ' || l_temp_msg);


/***************************************************************/
/* This insert deals with schdule budgets */

      l_temp_msg := to_char( sysdate, 'dd/mm/yyyy:hh:mi:ss');
      ams_utility_pvt.write_conc_log('BIM_CAMPAIGN_FACTS:FIRST_LOAD: BEFORE FOURTH INSERT ' || l_temp_msg);

      INSERT /*+ append parallel(CDF,1) */
      INTO bim_r_camp_daily_facts CDF
      (
               campaign_daily_transaction_id
              ,creation_date
              ,last_update_date
              ,created_by
              ,last_updated_by
              ,last_update_login
              ,campaign_id
              ,schedule_id
              ,transaction_create_date
              ,schedule_source_code
              ,campaign_source_code
              ,schedule_activity_type
	      ,schedule_activity_id
              ,campaign_purpose
              ,campaign_type
              ,start_date
              ,end_date
              ,schedule_purpose
              ,business_unit_id
              ,org_id
	      ,campaign_status
              ,schedule_status
              ,campaign_country
              ,campaign_region
              ,schedule_region
              ,schedule_country
              ,campaign_budget_fc
              ,schedule_budget_fc
              ,load_date
	      ,year
	      ,qtr
              ,month
              ,leads_open
              ,leads_closed
              ,leads_open_amt
              ,leads_closed_amt
	      ,leads_new
	      ,leads_new_amt
	      ,leads_hot
	      ,leads_converted
	      ,metric1 --leads_dead
              ,opportunities
	      ,opportunity_amt
              ,orders_booked
              ,orders_booked_amt
              ,forecasted_revenue
              ,actual_revenue
              ,forecasted_cost
              ,actual_cost
              ,forecasted_responses
              ,positive_responses
              ,targeted_customers
              ,budget_requested
              ,budget_approved
      )
      SELECT  /*+ parallel(INNER,1) */
	      bim_r_camp_daily_facts_s.nextval
              ,sysdate
              ,sysdate
              ,-1
              ,-1
              ,-1
              ,inner.campaign_id campaign_id
              ,inner.schedule_id schedule_id
              ,inner.creation_date transaction_create_date
              ,inner.schedule_source_code schedule_source_code
              ,inner.campaign_source_code campaign_source_code
              ,inner.schedule_activity_type schedule_activity_type
	      ,inner.schedule_activity_id schedule_activity_id
              ,inner.campaign_purpose campaign_purpose
              ,inner.campaign_type campaign_type
              ,inner.start_date start_date
              ,inner.end_date end_date
              ,inner.schedule_purpose schedule_purpose
              ,inner.business_unit_id business_unit_id
              ,inner.org_id org_id
	      ,inner.campaign_status campaign_status
              ,inner.status_code schedule_status
              ,inner.campaign_country_code campaign_country
              ,inner.campaign_region_code campaign_region
              ,inner.schedule_region_code schedule_region
              ,inner.schedule_country_code schedule_country
              ,0 campaign_budget_fc
              ,inner.schedule_budget_amount schedule_budget_fc
              ,(decode(decode( to_char(inner.creation_date,'MM') , to_char(next_day(inner.creation_date,TO_NUMBER(to_char(to_date('07/09/2004', 'DD/MM/RRRR'), 'DD'))),'MM') ,'TRUE','FALSE' )
      	        ,'TRUE'
      	        ,decode(decode(Inner.creation_date , (next_day(inner.creation_date, TO_NUMBER(to_char(to_date('07/09/2004', 'DD/MM/RRRR'), 'DD'))) - 7) , 'TRUE' ,'FALSE')
       	        ,'TRUE'
      	        ,inner.creation_date
      	        ,'FALSE'
      	        ,next_day(inner.creation_date, TO_NUMBER(to_char(to_date('07/09/2004', 'DD/MM/RRRR'), 'DD'))))
      	        ,'FALSE'
      	        ,decode(decode(to_char(inner.creation_date,'MM'),to_char(next_day(inner.creation_date,TO_NUMBER(to_char(to_date('07/09/2004', 'DD/MM/RRRR'), 'DD'))),'MM'),'TRUE','FALSE')
      	        ,'FALSE'
      	        ,last_day(Inner.creation_date))))         weekend_date
	      ,bim_set_of_books.get_fiscal_year(inner.creation_date,0) year
              ,bim_set_of_books.get_fiscal_qtr(inner.creation_date,0)  qtr
              ,bim_set_of_books.get_fiscal_month(inner.creation_date,0) month
              ,0 leads_open
              ,0 leads_closed
              ,0 leads_open_amt
              ,0 leads_closed_amt
	      ,0 leads_new
	      ,0 leads_new_amt
	      ,0 leads_hot
	      ,0 leads_converted
	      ,0 leads_dead
              ,0 opportunities
	      ,0 opportunity_amt
              ,0 orders_booked
              ,0 orders_booked_amt
              ,0 forecasted_revenue
              ,0 actual_revenue
              ,0 forecasted_cost
              ,0 actual_cost
              ,0 forecasted_responses
              ,0 positive_responses
              ,0 targeted_customers
              ,inner.request_amount request_amount
	      ,inner.approved_amount approved_amount
FROM
      (
        SELECT
                s.act_budget_used_by_id   act_budget_used_by_id
                ,decode(s.status_code
		   ,'PENDING'
		   ,trunc(nvl(s.request_date,s.creation_date))
		   ,'APPROVED'
                   ,trunc(nvl(s.approval_date,s.last_update_date))
		   ) creation_date
                ,sum(decode(s.status_code
                   ,'PENDING'
                   ,convert_currency(nvl(request_currency,'USD'),nvl(s.request_amount,0))
                   ,'APPROVED'
                   ,convert_currency(nvl(request_currency,'USD'),nvl(s.request_amount,0))
                   ))  request_amount
                ,sum(decode(s.status_code
                   ,'PENDING'
                   ,0
                   ,'APPROVED'
                   ,convert_currency(nvl(approved_in_currency,'USD'),nvl(s.approved_original_amount,0))
                   ))    approved_amount
              ,a.campaign_id      	  campaign_id
              ,b2.source_code_id      	  campaign_source_code_id
              ,a.source_code          	  campaign_source_code
              ,a.campaign_type        	  campaign_purpose
              ,a.status_code   		  campaign_status
              ,a.rollup_type          	  campaign_type
              ,e.schedule_id        	  schedule_id
              ,e.source_code        	  schedule_source_code
              ,b1.source_code_id          schedule_source_code_id
              ,e.activity_type_code 	  schedule_activity_type
	      ,decode(e.activity_type_code,'EVENTS',-9999, e.activity_id) schedule_activity_id
              ,d1.area2_code         	  schedule_region_code
              ,e.country_id         	  schedule_country_code
              ,e.org_id             	  org_id
              ,e.status_code        	  status_code
              ,e.start_date_time          start_date
              ,nvl(e.end_date_time, a.actual_exec_end_date) end_date
              ,e.objective_code     	  schedule_purpose
              ,a.business_unit_id     	  business_unit_id
              ,a.city_id              	  campaign_country_code
              ,e.budget_amount_fc     	  schedule_budget_amount
	      ,d2.area2_code		campaign_region_code
        FROM    ams_act_budgets    	    S
                ,ams_campaigns_all_b 	    A
                ,ams_source_codes           B1
                ,ams_source_codes           B2
                ,jtf_loc_hierarchies_b 	    D1
                ,jtf_loc_hierarchies_b 	    D2
                ,ams_campaign_schedules_b   E
        WHERE   s.arc_act_budget_used_by         = 'CSCH'
                AND    s.budget_source_type      = 'FUND'
                --AND    s.transfer_type         = 'REQUEST'
                AND    s.act_budget_used_by_id 	 = e.schedule_id
                AND    e.campaign_id             =  a.campaign_id
                AND    e.country_id              =  d1.location_hierarchy_id
                AND    a.city_id                 =  d2.location_hierarchy_id
                AND    a.status_code             IN ('ACTIVE', 'CANCELLED', 'COMPLETED','CLOSED')
                --AND    e.status_code           IN ('ACTIVE', 'CANCELLED', 'COMPLETED','CLOSED')
                AND    a.rollup_type           <> 'RCAM'
                AND    b1.source_code            =  e.source_code
                AND    b2.source_code            =  a.source_code
                AND    a.actual_exec_start_date  >= trunc(p_start_date)
                AND    a.actual_exec_start_date  <= trunc(p_end_date)
                AND    decode(s.status_code,'PENDING',trunc(nvl(s.request_date,s.creation_date)),'APPROVED',trunc(nvl(s.approval_date,s.last_update_date)) )           <= trunc(p_end_date)
        GROUP BY s.act_budget_used_by_id
                 ,decode(s.status_code,'PENDING',trunc(nvl(s.request_date,s.creation_date)),'APPROVED',trunc(nvl(s.approval_date,s.last_update_date)) )
                 ,a.campaign_id
                 ,b2.source_code_id
                 ,a.source_code
                 ,a.campaign_type
                 ,a.status_code
                 ,a.rollup_type
                 ,e.schedule_id
                 ,e.source_code
                 ,b1.source_code_id
                 ,e.activity_type_code
	         ,decode(e.activity_type_code,'EVENTS',-9999, e.activity_id)
                 ,d1.area2_code
                 ,e.country_id
                 ,e.org_id
                 ,e.status_code
                 ,e.start_date_time
                 ,nvl(e.end_date_time, a.actual_exec_end_date)
                 ,e.objective_code
                 ,a.business_unit_id
                 ,a.city_id
                 ,e.budget_amount_fc
		 ,d2.area2_code
        HAVING   sum(decode(s.status_code
                   ,'PENDING'
                   ,convert_currency(nvl(request_currency,'USD'),nvl(s.request_amount,0))
                   ,'APPROVED'
                   , convert_currency(nvl(request_currency,'USD'),nvl(s.request_amount,0))
                   )) > 0
        OR
                 sum(decode(s.status_code
                   ,'PENDING'
                   ,0
                   ,'APPROVED'
                   ,convert_currency(nvl(approved_in_currency,'USD'),nvl(s.approved_original_amount,0))
                   ))    > 0
  	UNION ALL
        SELECT
                 s.budget_source_id   act_budget_used_by_id
                ,trunc(nvl(s.approval_date,s.last_update_date)) creation_date
              --  ,0 request_amount
			  ,  - sum(convert_currency(nvl(approved_in_currency,'USD'),nvl(s.approved_original_amount,0))) request_amount
                , -sum(convert_currency(nvl(approved_in_currency,'USD'),nvl(s.approved_original_amount,0))) approved_amount
              ,a.campaign_id      	  campaign_id
              ,b2.source_code_id      	  campaign_source_code_id
              ,a.source_code          	  campaign_source_code
              ,a.campaign_type        	  campaign_purpose
              ,a.status_code   		  campaign_status
              ,a.rollup_type          	  campaign_type
              ,e.schedule_id        	  schedule_id
              ,e.source_code        	  schedule_source_code
              ,b1.source_code_id          schedule_source_code_id
              ,e.activity_type_code 	  schedule_activity_type
	      ,decode(e.activity_type_code,'EVENTS',-9999, e.activity_id) schedule_activity_id
              ,d1.area2_code         	  schedule_region_code
              ,e.country_id         	  schedule_country_code
              ,e.org_id             	  org_id
              ,e.status_code        	  status_code
              ,e.start_date_time          start_date
              ,nvl(e.end_date_time, a.actual_exec_end_date) end_date
              ,e.objective_code     	  schedule_purpose
              ,a.business_unit_id     	  business_unit_id
              ,a.city_id              	  campaign_country_code
              ,e.budget_amount_fc     	  schedule_budget_amount
	      ,d2.area2_code		campaign_region_code
        FROM    ams_act_budgets    	    S
                ,ams_campaigns_all_b 	    A
                ,ams_source_codes           B1
                ,ams_source_codes           B2
                ,jtf_loc_hierarchies_b 	    D1
                ,jtf_loc_hierarchies_b 	    D2
                ,ams_campaign_schedules_b   E
        WHERE   s.arc_act_budget_used_by         = 'FUND'
                AND    s.budget_source_type      = 'CSCH'
                --AND    s.transfer_type         = 'REQUEST'
                AND    s.budget_source_id 	 = e.schedule_id
                AND    e.campaign_id             =  a.campaign_id
                AND    e.country_id              =  d1.location_hierarchy_id
                AND    a.city_id                 =  d2.location_hierarchy_id
                AND    a.status_code             IN ('ACTIVE', 'CANCELLED', 'COMPLETED','CLOSED')
                --AND    e.status_code           IN ('ACTIVE', 'CANCELLED', 'COMPLETED','CLOSED')
                AND    a.rollup_type           <> 'RCAM'
                AND    b1.source_code            =  e.source_code
                AND    b2.source_code            =  a.source_code
                AND    a.actual_exec_start_date  >= trunc(p_start_date)
                AND    a.actual_exec_start_date  <= trunc(p_end_date)
                AND    s.approval_date           <= trunc(p_end_date)
        GROUP BY s.budget_source_id
                ,trunc(nvl(s.approval_date,s.last_update_date))
                 ,a.campaign_id
                 ,b2.source_code_id
                 ,a.source_code
                 ,a.campaign_type
                 ,a.status_code
                 ,a.rollup_type
                 ,e.schedule_id
                 ,e.source_code
                 ,b1.source_code_id
                 ,e.activity_type_code
	         ,decode(e.activity_type_code,'EVENTS',-9999, e.activity_id)
                 ,d1.area2_code
                 ,e.country_id
                 ,e.org_id
                 ,e.status_code
                 ,e.start_date_time
                 ,nvl(e.end_date_time, a.actual_exec_end_date)
                 ,e.objective_code
                 ,a.business_unit_id
                 ,a.city_id
                 ,e.budget_amount_fc
		 ,d2.area2_code
        HAVING   sum(decode(s.status_code
                   ,'PENDING'
                   ,0
                   ,'APPROVED'
                   ,convert_currency(nvl(approved_in_currency,'USD'),nvl(s.approved_original_amount,0))
                   ))    > 0
    )INNER;


 COMMIT;


   l_temp_msg := to_char( sysdate, 'dd/mm/yyyy:hh:mi:ss');
   ams_utility_pvt.write_conc_log('BIM_CAMPAIGN_FACTS:FIRST_LOAD: AFTER FOURTH INSERT ' || l_temp_msg);



   l_temp_msg := to_char( sysdate, 'dd/mm/yyyy:hh:mi:ss');
   ams_utility_pvt.write_conc_log('BIM_CAMPAIGN_FACTS:FIRST_LOAD: BEFORE ANALYZING DAILY FACTS ' || l_temp_msg);

   -- Analyze the daily facts table
   DBMS_STATS.gather_table_stats('BIM','BIM_R_CAMP_DAILY_FACTS', estimate_percent => 5,
                                  degree => 8, granularity => 'GLOBAL', cascade =>TRUE);

   l_temp_msg := to_char( sysdate, 'dd/mm/yyyy:hh:mi:ss');
   ams_utility_pvt.write_conc_log('BIM_CAMPAIGN_FACTS:FIRST_LOAD: AFTER ANALYZING DAILY FACTS ' || l_temp_msg);

/***************************************************************/

   /*  INSERT INTO WEEKLY SUMMARY TABLE */

   /* Here we are inserting the summarized data into the weekly facts by taking it from the daily facts.
     For every week we have a record since we group by that weekend date which is nothing but the Load date. */

   l_temp_msg := to_char( sysdate, 'dd/mm/yyyy:hh:mi:ss');
   ams_utility_pvt.write_conc_log('BIM_CAMPAIGN_FACTS:FIRST_LOAD: BEFORE WEEKLY TABLE INSERT ' || l_temp_msg);

   EXECUTE IMMEDIATE 'TRUNCATE TABLE '||l_schema||'.bim_r_camp_weekly_facts';

   /*BEGIN BLOCK FOR THE WEEKLY INSERT */

      l_table_name :=    'bim_r_camp_weekly_facts';
      l_seq_name      := 'bim_r_camp_weekly_facts_s';

      INSERT /*+ append parallel(CWF,1) */
      INTO bim_r_camp_weekly_facts CWF
        (
             campaign_weekly_transaction_id
            ,creation_date
            ,last_update_date
            ,created_by
            ,last_updated_by
            ,campaign_id
            ,schedule_id
            ,campaign_source_code
            ,schedule_source_code
            ,campaign_type
            ,start_date
            ,end_date
            ,campaign_region
            ,schedule_region
            ,campaign_country
            ,schedule_country
            ,business_unit_id
            ,schedule_activity_type
	    ,schedule_activity_id
            ,campaign_purpose
            ,campaign_status
	    ,schedule_status
            ,transaction_create_date
            ,org_id
            ,load_date
	    ,year
	    ,qtr
	    ,month
            ,leads_open
            ,leads_closed
            ,leads_open_amt
            ,leads_closed_amt
	    ,leads_new
	    ,leads_new_amt
	    ,leads_hot
	    ,leads_converted
	    ,metric1 -- leads_dead
            ,opportunities
	    ,opportunity_amt
	    ,orders_booked
	    ,orders_booked_amt
            ,forecasted_revenue
            ,actual_revenue
            ,forecasted_cost
            ,actual_cost
            ,forecasted_responses
            ,positive_responses
            ,targeted_customers
            ,budget_requested
            ,budget_approved
        )
      SELECT /*+ parallel(INNER,8) */
		bim_r_camp_weekly_facts_s.nextval
            ,sysdate
            ,sysdate
            ,l_user_id
            ,l_user_id
            ,campaign_id
            ,schedule_id
            ,campaign_source_code
            ,schedule_source_code
            ,campaign_type
            ,start_date
            ,end_date
            ,campaign_region
            ,schedule_region
            ,campaign_country
            ,schedule_country
            ,business_unit_id
            ,schedule_activity_type
	    ,schedule_activity_id
            ,campaign_purpose
            ,campaign_status
	    ,schedule_status
            ,transaction_create_date
            ,org_id
            ,load_date
	    ,year
	    ,qtr
	    ,month
            ,leads_open
            ,leads_closed
            ,leads_open_amt
            ,leads_closed_amt
	    ,leads_new
	    ,leads_new_amt
	    ,leads_hot
	    ,leads_converted
	    ,leads_dead
            ,opportunities
	    ,opportunity_amt
	    ,orders_booked
	    ,orders_booked_amt
            ,forecasted_revenue
            ,actual_revenue
            ,forecasted_cost
            ,actual_cost
            ,forecasted_responses
            ,positive_responses
            ,targeted_customers
            ,budget_requested
            ,budget_approved
      FROM
      (
         SELECT
             campaign_id                        campaign_id
            ,schedule_id                        schedule_id
            ,campaign_source_code               campaign_source_code
            ,schedule_source_code               schedule_source_code
            ,campaign_type                      campaign_type
            ,start_date                         start_date
            ,end_date                           end_date
            ,campaign_region                    campaign_region
            ,schedule_region                    schedule_region
            ,campaign_country                   campaign_country
            ,schedule_country                   schedule_country
            ,nvl(business_unit_id,0)            business_unit_id
            ,schedule_activity_type             schedule_activity_type
	    ,schedule_activity_id		schedule_activity_id
            ,campaign_purpose                   campaign_purpose
            ,campaign_status                    campaign_status
	    ,schedule_status			schedule_status
            ,load_date                          transaction_create_date
            ,org_id                             org_id
            ,load_date                          load_date
	    ,year				year
	    ,qtr				qtr
	    ,month				month
            ,sum(leads_open)   			leads_open
            ,sum(leads_closed) 			leads_closed
            ,sum(leads_open_amt)    		leads_open_amt
            ,sum(leads_closed_amt)    		leads_closed_amt
	    ,sum(leads_new)			leads_new
	    ,sum(leads_new_amt)			leads_new_amt
	    ,sum(leads_hot)			leads_hot
	    ,sum(leads_converted)		leads_converted
	    ,sum(metric1)			leads_dead
            ,sum(opportunities)                 opportunities
	    ,sum(opportunity_amt)		opportunity_amt
	    ,sum(orders_booked)			orders_booked
	    ,sum(orders_booked_amt)		orders_booked_amt
            ,sum(forecasted_revenue) 		forecasted_revenue
            ,sum(actual_revenue)     		actual_revenue
            ,sum(forecasted_cost)               forecasted_cost
            ,sum(actual_cost)                   actual_cost
            ,sum(forecasted_responses)  	forecasted_responses
            ,sum(positive_responses)     	positive_responses
            ,sum(targeted_customers)		targeted_customers
            ,sum(budget_requested)              budget_requested
            ,sum(budget_approved)               budget_approved
         FROM    bim_r_camp_daily_facts
--	 WHERE   transaction_create_date between trunc(p_start_date) and trunc(p_end_date) + 0.99999
 	 GROUP BY   campaign_id
            ,schedule_id
            ,load_date
	    ,year
	    ,qtr
	    ,month
            ,campaign_source_code
            ,schedule_source_code
            ,campaign_type
            ,start_date
            ,end_date
            ,campaign_region
            ,schedule_region
            ,campaign_country
            ,schedule_country
            ,nvl(business_unit_id,0)
            ,schedule_activity_type
	    ,schedule_activity_id
            ,campaign_purpose
            ,campaign_status
	    ,schedule_status
            ,org_id
         )INNER;



    COMMIT;


   l_temp_msg := to_char( sysdate, 'dd/mm/yyyy:hh:mi:ss');
   ams_utility_pvt.write_conc_log('BIM_CAMPAIGN_FACTS:FIRST_LOAD: AFTER WEEKLY TABLE INSERT ' || l_temp_msg);

   l_temp_msg := to_char( sysdate, 'dd/mm/yyyy:hh:mi:ss');
   ams_utility_pvt.write_conc_log('BIM_CAMPAIGN_FACTS:FIRST_LOAD: BEFORE ANALYZING WEEKLY FACTS ' || l_temp_msg);

   -- Analyze the daily facts table
   DBMS_STATS.gather_table_stats('BIM','BIM_R_CAMP_WEEKLY_FACTS', estimate_percent => 5,
                                  degree => 8, granularity => 'GLOBAL', cascade =>TRUE);

   l_temp_msg := to_char( sysdate, 'dd/mm/yyyy:hh:mi:ss');
   ams_utility_pvt.write_conc_log('BIM_CAMPAIGN_FACTS:FIRST_LOAD: AFTER ANALYZING WEEKLY FACTS ' || l_temp_msg);


   l_temp_msg := to_char( sysdate, 'dd/mm/yyyy:hh:mi:ss');
   ams_utility_pvt.write_conc_log('BIM_CAMPAIGN_FACTS:FIRST_LOAD: BEFORE COST UPDATE ' || l_temp_msg);


   -- Make entry in the history table

   LOG_HISTORY('CAMPAIGN', p_start_date, p_end_date);


       /* Piece of Code for Recreating the index on the same tablespace with the same storage parameters */

   l_temp_msg := to_char( sysdate, 'dd/mm/yyyy:hh:mi:ss');
   ams_utility_pvt.write_conc_log('BIM_CAMPAIGN_FACTS:FIRST_LOAD: BEFORE CREATE INDEX ' || l_temp_msg);

 	i := i - 1;
	WHILE(i>=1) LOOP
	EXECUTE IMMEDIATE 'CREATE INDEX '
	    || l_owner(i)
	    || '.'
	    || l_index_name(i)
	    ||' ON '
	    || l_owner(i)
	    ||'.'
	    || l_index_table_name(i)
	    || ' ('
	    || l_ind_column_name(i)
	    || ' )'
            || ' tablespace '  || l_index_tablespace
            || ' pctfree     ' || l_pct_free(i)
            || ' initrans '    || l_ini_trans(i)
            || ' maxtrans  '   || l_max_trans(i)
            || ' storage ( '
            || ' initial '     || l_initial_extent(i)
            || ' next '        || l_next_extent(i)
            || ' minextents '  || l_min_extents(i)
            || ' maxextents '  || l_max_extents(i)
            || ' pctincrease ' || l_pct_increase(i)
            || ')' ;

            i := i - 1;
	 END LOOP;

   l_temp_msg := to_char( sysdate, 'dd/mm/yyyy:hh:mi:ss');
   ams_utility_pvt.write_conc_log('BIM_CAMPAIGN_FACTS:FIRST_LOAD: AFTER CREATE INDEX ' || l_temp_msg);

       /* End of Code for Recreating the index on the same tablespace with the same storage parameters */


   EXECUTE IMMEDIATE 'ALTER SEQUENCE '||l_schema||'.bim_r_camp_weekly_facts_s CACHE 20';


EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_msg_PUB.Count_And_Get (
          --  p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

    ams_utility_pvt.write_conc_log('BIM_CAMPAIGN_FACTS:FIRST_LOAD:IN EXPECTED EXCEPTION '||sqlerrm(sqlcode));

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     -- Standard call to get message count and if count=1, get the message
     FND_msg_PUB.Count_And_Get (
            --p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

    ams_utility_pvt.write_conc_log('BIM_CAMPAIGN_FACTS:FIRST_LOAD:IN UNEXPECTED EXCEPTION '||sqlerrm(sqlcode));

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

    ams_utility_pvt.write_conc_log('BIM_CAMPAIGN_FACTS:FIRST_LOAD:IN OTHERS EXCEPTION '||sqlerrm(sqlcode));

END CAMPAIGN_FIRST_LOAD;


--------------------------------------------------------------------------------------------------
-- This procedure will excute when data is loaded for the first time, and run the program incrementally.

--                      PROCEDURE  CAMPAIGN_SUBSEQUENT_LOAD
--------------------------------------------------------------------------------------------------

PROCEDURE CAMPAIGN_SUBSEQUENT_LOAD
( p_start_date            IN  DATE
 ,p_end_date              IN  DATE
 ,p_api_version_number    IN  NUMBER
 ,p_init_msg_list         IN  VARCHAR2     := FND_API.G_FALSE
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
    l_wkdt			  DATE;
    l_noleads		          NUMBER;
    l_nooppor		          NUMBER;
    l_orders		       	  NUMBER;
    l_noposresp		          NUMBER;
    l_revenue		          NUMBER;
    l_forecasted_cost	   	  NUMBER;
    l_actual_cost		  NUMBER;
    l_targeted_customer	   	  NUMBER;
    l_noofnew_customer	   	  NUMBER;
    l_temp                 	  NUMBER;
    l_tempo                	  NUMBER;
    l_seq                  	  NUMBER;
    l_seqw                 	  NUMBER;
    l_api_version_number   	  CONSTANT NUMBER       := 1.0;
    l_api_name             	  CONSTANT VARCHAR2(30) := 'CAMPAIGN_SUBSEQUENT_LOAD';
    l_seq_name             	  VARCHAR(100);
    l_def_tablespace        	  VARCHAR2(100);
    l_index_tablespace      	  VARCHAR2(100);
    l_oracle_username       	  VARCHAR2(100);
    l_table_name		  VARCHAR2(100);
    l_temp_msg		          VARCHAR2(100);

   TYPE  generic_number_table IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

   TYPE  generic_char_table IS TABLE OF VARCHAR2(100) INDEX BY BINARY_INTEGER;

   l_pct_free	        generic_number_table;
   l_ini_trans  	generic_number_table;
   l_max_trans  	generic_number_table;
   l_initial_extent     generic_number_table;
   l_next_extent  	generic_number_table;
   l_min_extents 	generic_number_table;
   l_max_extents 	generic_number_table;
   l_pct_increase 	generic_number_table;


   l_owner 		generic_char_table;
   l_index_name 	generic_char_table;
   l_ind_column_name    generic_char_table;
   l_index_table_name   generic_char_table;
   i			NUMBER;
   l_min_start_date     DATE;

   l_status      VARCHAR2(30);
   l_industry    VARCHAR2(30);
   l_orcl_schema VARCHAR2(30);
   l_bol         BOOLEAN := fnd_installation.get_app_info ('BIM',l_status,l_industry,l_orcl_schema);

   CURSOR    get_ts_name IS
   SELECT    i.tablespace, i.index_tablespace, u.oracle_username
   FROM      fnd_product_installations i, fnd_application a, fnd_oracle_userid u
   WHERE     a.application_short_name = 'BIM'
   AND 	     a.application_id = i.application_id
   AND 	     u.oracle_id = i.oracle_id;

   CURSOR    get_index_params (l_schema VARCHAR2) IS
   SELECT    a.owner,a.index_name,b.table_name,b.column_name,pct_free,ini_trans,max_trans
             ,initial_extent,next_extent,min_extents,
	     max_extents, pct_increase
   FROM      all_indexes a, all_ind_columns b
   WHERE     a.index_name = b.index_name
   AND       a.owner = l_schema
   AND       a.owner = b.index_owner
   AND 	     a.index_name like 'BIM_R_CAMP_%FACTS%';

   CURSOR chk_history_data IS
   SELECT  MIN(start_date)
   FROM    bim_rep_history
   WHERE   object = 'CAMPAIGN';

   l_min_date			date;

   l_org_id 			number;

   CURSOR   get_org_id IS
   SELECT   (TO_NUMBER(SUBSTRB(USERENV('CLIENT_INFO'), 1, 10)))
   FROM     dual;

l_camp 	number;
l_schema                      VARCHAR2(30);
l_status1                      VARCHAR2(5);
l_industry1                    VARCHAR2(5);
l_return			boolean;
BEGIN
l_return  := fnd_installation.get_app_info('BIM', l_status1, l_industry1, l_schema);
    ams_utility_pvt.write_conc_log(p_start_date || ' '|| p_end_date);
    l_camp := 0;

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


   -- The below four commands are necessary for the purpose of the parallel insertion */

   EXECUTE IMMEDIATE 'ALTER SESSION ENABLE PARALLEL dml ';

   EXECUTE IMMEDIATE 'ALTER TABLE   '||l_schema||'.bim_r_camp_daily_facts nologging ';

   EXECUTE IMMEDIATE 'ALTER TABLE   '||l_schema||'.bim_r_camp_weekly_facts nologging ';

   EXECUTE IMMEDIATE 'ALTER SEQUENCE '||l_schema||'.bim_r_camp_daily_facts_s CACHE 1000 ';

   EXECUTE IMMEDIATE 'ALTER SEQUENCE '||l_schema||'.bim_r_camp_weekly_facts_s CACHE 1000 ';

   /*Get the tablespace name for the purpose of creating the index on that tablespace. */


      OPEN  get_ts_name;
      FETCH get_ts_name INTO	l_def_tablespace, l_index_tablespace, l_oracle_username;
      CLOSE get_ts_name;

      OPEN  get_org_id;
      FETCH get_org_id INTO	l_org_id;
      CLOSE get_org_id;

      IF p_load_type  = 'FIRST_LOAD' THEN
          l_min_start_date := p_start_date;
      ELSE
          OPEN  chk_history_data;
          FETCH chk_history_data INTO   l_min_start_date;
          CLOSE chk_history_data;
      END IF;


      /* Piece of Code for retrieving,storing storage parameters and Dropping the indexes */
      i := 1;
      FOR x in get_index_params(l_orcl_schema) LOOP

	  l_pct_free(i) :=  x.pct_free;
	  l_ini_trans(i) := x.ini_trans;
	  l_max_trans(i) := x.max_trans;
   	  l_initial_extent(i) := x.initial_extent;
   	  l_next_extent(i) 	  := x.next_extent;
   	  l_min_extents(i) := x.min_extents;
   	  l_max_extents(i) := x.max_extents;
   	  l_pct_increase(i) := x.pct_increase;

	  l_owner(i) 		:= x.owner;
	  l_index_name(i) := x.index_name;
	  l_index_table_name(i) := x.table_name;
	  l_ind_column_name(i) := x.column_name;


   -- Drop the index before the mass upload

      EXECUTE IMMEDIATE 'DROP INDEX  '|| l_owner(i) || '.'|| l_index_name(i) ;
      i := i + 1;
      END LOOP;

      /* End of Code for dropping the existing indexes */


    -- dbms_output.put_Line('JUST BEFORE THE MAIN INSERT STATMENT');

    l_org_id := 0;

    l_temp_msg := to_char( sysdate, 'dd/mm/yyyy:hh:mi:ss');
    ams_utility_pvt.write_conc_log('BIM_CAMPAIGN_FACTS:LOAD: BEFORE FIRST INSERT ' || l_temp_msg);

      INSERT /*+ append parallel(CDF,1) */
      INTO bim_r_camp_daily_facts CDF
      (
               campaign_daily_transaction_id
              ,creation_date
              ,last_update_date
              ,created_by
              ,last_updated_by
              ,last_update_login
              ,campaign_id
              ,schedule_id
              ,transaction_create_date
              ,schedule_source_code
              ,campaign_source_code
              ,schedule_activity_type
	      ,schedule_activity_id
              ,campaign_purpose
              ,campaign_type
              ,start_date
              ,end_date
              ,schedule_purpose
              ,business_unit_id
              ,org_id
	      ,campaign_status
              ,schedule_status
              ,campaign_country
              ,campaign_region
              ,schedule_region
              ,schedule_country
              ,campaign_budget_fc
              ,schedule_budget_fc
              ,load_date
	      ,year
	      ,qtr
              ,month
              ,leads_open
              ,leads_closed
              ,leads_open_amt
              ,leads_closed_amt
	      ,leads_new
	      ,leads_new_amt
	      ,leads_hot
	      ,leads_converted
	      ,metric1 -- leads_dead
              ,opportunities
	      ,opportunity_amt
              ,orders_booked
              ,orders_booked_amt
              ,forecasted_revenue
              ,actual_revenue
              ,forecasted_cost
              ,actual_cost
              ,forecasted_responses
              ,positive_responses
              ,targeted_customers
              ,budget_requested
              ,budget_approved
      )
      SELECT  /*+ parallel(OUTER,1) */
		bim_r_camp_daily_facts_s.nextval
              ,sysdate
              ,sysdate
              ,-1
              ,-1
              ,-1
              ,campaign_id
              ,schedule_id
              ,transaction_create_date
              ,schedule_source_code
              ,campaign_source_code
              ,schedule_activity_type
	      ,schedule_activity_id
              ,campaign_purpose
              ,campaign_type
              ,start_date
              ,end_date
              ,schedule_purpose
              ,business_unit_id
              ,org_id
	      ,campaign_status
              ,schedule_status
              ,campaign_country
              ,campaign_region
              ,schedule_region
              ,schedule_country
              ,0 schedule_budget_fc
              ,0 campaign_budget_fc
              ,weekend_date
	      ,year
	      ,qtr
              ,month
              ,leads_open
              ,leads_closed
              ,leads_open_amt
              ,leads_closed_amt
	      ,leads_new
	      ,leads_new_amt
	      ,leads_hot
	      ,leads_converted
	      ,leads_dead
              ,opportunities
	      ,opportunity_amt
              ,orders_booked
              ,orders_booked_amt
              ,forecasted_revenue
              ,actual_revenue
              ,forecasted_cost
              ,actual_cost
              ,forecasted_responses
              ,positive_responses
              ,0 targeted_customers
              ,0 request_amount
	      ,0 approved_amount
      FROM
      (
SELECT
	      a.campaign_id		campaign_id
              ,0			schedule_id
      	      ,inner.creation_date	transaction_create_date
              ,0		        schedule_source_code
      	      ,c.source_code_id	        campaign_source_code_id
      	      ,0	                schedule_source_code_id
	      ,a.source_code		campaign_source_code
              ,0		        schedule_activity_type
	      ,0		        schedule_activity_id
	      ,a.campaign_type		campaign_purpose
              ,a.rollup_type		campaign_type
              ,a.actual_exec_start_date	start_date
              ,a.actual_exec_end_date	end_date
              ,0		        schedule_purpose
              ,a.business_unit_id	business_unit_id
              ,0			org_id
	      ,a.status_code		campaign_status
              ,0			schedule_status
              ,a.city_id		campaign_country
              ,d.area2_code		campaign_region
              ,0		        schedule_region
              ,0		        schedule_country
              ,(decode(decode( to_char(inner.creation_date,'MM') , to_char(next_day(inner.creation_date,TO_NUMBER(to_char(to_date('07/09/2004', 'DD/MM/RRRR'), 'DD'))),'MM') ,'TRUE','FALSE' )
      	        ,'TRUE'
      	        ,decode(decode(inner.creation_date , (next_day(inner.creation_date, TO_NUMBER(to_char(to_date('07/09/2004', 'DD/MM/RRRR'), 'DD'))) - 7) , 'TRUE' ,'FALSE')
       	        ,'TRUE'
      	        ,inner.creation_date
      	        ,'FALSE'
      	        ,next_day(inner.creation_date, TO_NUMBER(to_char(to_date('07/09/2004', 'DD/MM/RRRR'), 'DD'))))
      	        ,'FALSE'
      	        ,decode(decode(to_char(inner.creation_date,'MM'),to_char(next_day(inner.creation_date,TO_NUMBER(to_char(to_date('07/09/2004', 'DD/MM/RRRR'), 'DD'))),'MM'),'TRUE','FALSE')
      	        ,'FALSE'
      	        ,last_day(inner.creation_date))))         weekend_date
              ,bim_set_of_books.get_fiscal_year(inner.creation_date,0) year
              ,bim_set_of_books.get_fiscal_qtr(inner.creation_date,0)  qtr
              ,bim_set_of_books.get_fiscal_month(inner.creation_date,0) month
              ,inner.leads_open  	  leads_open
              ,inner.leads_closed 	  leads_closed
              ,inner.leads_open_amt    	  leads_open_amt
              ,inner.leads_closed_amt      leads_closed_amt
	      ,inner.leads_new		  leads_new
	      ,inner.leads_new_amt	  leads_new_amt
	      ,inner.leads_hot		  leads_hot
	      ,inner.leads_converted	  leads_converted
	      ,inner.leads_dead		  leads_dead
              ,inner.opportunities         opportunities
	      ,inner.opportunity_amt	  opportunity_amt
              ,inner.orders_booked	  orders_booked
              ,inner.orders_booked_amt	  orders_booked_amt
              ,inner.forecasted_revenue 	  forecasted_revenue
              ,inner.actual_revenue        actual_revenue
              ,inner.forecasted_cost       forecasted_cost
              ,inner.actual_cost           actual_cost
              ,inner.forecasted_responses  forecasted_responses
              ,inner.positive_responses    positive_responses
              ,inner.targeted_customers	  targeted_customers
FROM  (
SELECT
               metric.campaign_id campaign_id
              ,metric.creation_date creation_date
              ,sum(nvl(metric.leads_open,0))  	       leads_open
              ,sum(nvl(metric.leads_closed,0))	       leads_closed
              ,sum(nvl(metric.leads_open_amt,0))       leads_open_amt
              ,sum(nvl(metric.leads_closed_amt,0))     leads_closed_amt
	      ,sum(nvl(metric.leads_new,0))	       leads_new
	      ,sum(nvl(metric.leads_new_amt,0))	       leads_new_amt
	      ,sum(nvl(metric.leads_hot,0))	       leads_hot
	      ,sum(nvl(metric.leads_converted,0))      leads_converted
	      ,sum(nvl(metric.leads_dead,0))	       leads_dead
              ,sum(nvl(metric.opportunities,0))        opportunities
	      ,sum(nvl(metric.opportunity_amt,0))      opportunity_amt
              ,sum(nvl(metric.orders_booked,0))	       orders_booked
              ,sum(nvl(metric.orders_booked_amt,0))    orders_booked_amt
              ,sum(nvl(metric.forecasted_revenue,0))   forecasted_revenue
              ,sum(nvl(metric.actual_revenue,0))       actual_revenue
              ,sum(nvl(metric.forecasted_cost,0))      forecasted_cost
              ,sum(nvl(metric.actual_cost,0))          actual_cost
              ,sum(nvl(metric.forecasted_responses,0)) forecasted_responses
              ,sum(nvl(metric.positive_responses,0))   positive_responses
              ,0				       targeted_customers
FROM (
SELECT
              A.campaign_id campaign_id
              ,trunc(decode(Y.opp_open_status_flag,'Y',X.creation_date,X.last_update_date))creation_date
              ,sum(decode(Y.opp_open_status_flag,'Y',1,0)) leads_open
              ,sum(decode(Y.opp_open_status_flag,'Y',0,1)) leads_closed
              ,sum(decode(Y.opp_open_status_flag,'Y',convert_currency(nvl(X.currency_code,'USD'),nvl(X.budget_amount,0)),0)) leads_open_amt
              ,sum(decode(Y.opp_open_status_flag,'Y',0,decode(X.status_code,'DEAD_LEAD',convert_currency(nvl(X.currency_code,'USD'),nvl(X.budget_amount,0)),0))) leads_closed_amt
              ,sum(decode(Y.opp_open_status_flag,'Y',decode(X.status_code,'NEW',1,0),0))       leads_new
              ,sum(decode(Y.opp_open_status_flag,'Y',decode(X.status_code,'NEW',convert_currency(nvl(X.currency_code,'USD'),nvl(X.budget_amount,0)),0),0)) leads_new_amt
              ,sum(decode(Y.opp_open_status_flag,'Y',decode(X.lead_rank_id,10000,1,0),0))      leads_hot
              ,sum(decode(Y.opp_open_status_flag,'N',decode(X.status_code,'CONVERTED_TO_OPPORTUNITY',1,0),0)) leads_converted
              ,sum(decode(Y.opp_open_status_flag,'Y',0,decode(X.status_code,'DEAD_LEAD',1,0))) leads_dead
              ,0 opportunities
              ,0 opportunity_amt
              ,0 orders_booked
              ,0 orders_booked_amt
              ,0 forecasted_revenue
              ,0 actual_revenue
              ,0 forecasted_cost
              ,0 actual_cost
              ,0 forecasted_responses
              ,0 positive_responses
              ,0 targeted_customers
FROM
              ams_campaigns_all_b A
              ,ams_source_codes  C
              ,as_sales_leads X
              ,as_statuses_b  Y
WHERE
              X.status_code = Y.status_code
              AND   A.campaign_id = C.source_code_for_id
              AND   C.arc_source_code_for = 'CAMP'
              AND   A.source_code = C.source_code
              AND   C.source_code_id = X.source_promotion_id
              AND   Y.lead_flag = 'Y'
              AND   Y.enabled_flag = 'Y'
              AND   NVL(X.DELETED_FLAG,'N') <> 'Y'
              AND   trunc(decode(Y.opp_open_status_flag,'Y',X.creation_date,X.last_update_date)) between                    p_start_date and p_end_date+0.99999
GROUP BY
              a.campaign_id
              ,trunc(decode(Y.opp_open_status_flag,'Y',X.creation_date,X.last_update_date))
UNION ALL
SELECT
              A.campaign_id campaign_id
              ,trunc(X.creation_date) creation_date
              ,0 leads_open
              ,0 leads_closed
              ,0 leads_open_amt
              ,0 leads_closed_amt
              ,0 leads_new
              ,0 leads_new_amt
              ,0 leads_hot
              ,0 leads_converted
              ,0 leads_dead
              ,count(distinct X.lead_id) opportunities
              ,sum(convert_currency(nvl(X.currency_code,'USD'),nvl(X.total_amount,0))) opportunity_amt
              ,0 orders_booked
              ,0 orders_booked_amt
              ,0 forecasted_revenue
              ,0 actual_revenue
              ,0 forecasted_cost
              ,0 actual_cost
              ,0 forecasted_responses
              ,0 positive_responses
              ,0 targeted_customers
FROM
              ams_campaigns_all_b A
              ,ams_source_codes  C
              ,as_leads_all 	X
WHERE
                  A.campaign_id = C.source_code_for_id
              AND C.arc_source_code_for = 'CAMP'
              AND A.source_code = C.source_code
              AND C.source_code_id = X.source_promotion_id
              AND trunc(X.creation_date) between p_start_date and p_end_date+0.99999
GROUP BY
              A.campaign_id,trunc(X.creation_date)
UNION ALL
SELECT
              A.campaign_id campaign_id
              ,trunc(H.creation_date) 	creation_date
              ,0 leads_open
              ,0 leads_closed
              ,0 leads_open_amt
              ,0 leads_closed_amt
              ,0 leads_new
              ,0 leads_new_amt
              ,0 leads_hot
              ,0 leads_converted
              ,0 leads_dead
              ,0 opportunities
              ,0 opportunity_amt
              ,count(distinct(h.header_id)) orders_booked
              ,sum(decode(h.flow_status_code,'BOOKED',convert_currency(nvl(H.transactional_curr_code,'USD')
              ,nvl(I.unit_selling_price * I.ordered_quantity,0)),0)) orders_booked_amt
,0 forecasted_revenue
              ,0 actual_revenue
              ,0 forecasted_cost
              ,0 actual_cost
              ,0 forecasted_responses
              ,0 positive_responses
              ,0 targeted_customers
FROM
              ams_campaigns_all_b A
              ,ams_source_codes  	C
              ,as_sales_leads      	D
              ,as_sales_lead_opportunity      	D1
              ,as_leads_all              E
              ,aso_quote_related_objects F
              ,aso_quote_headers_all     G
              ,oe_order_headers_all     H
              ,oe_order_lines_all	I
WHERE
                  A.campaign_id = C.source_code_for_id
              AND C.arc_source_code_for = 'CAMP'
              AND A.source_code = C.source_code
              AND C.source_code_id =  D.source_promotion_id
              AND D.sales_lead_id = D1.sales_lead_id
              AND D1.opportunity_id   = E.lead_id
              AND E.lead_id           = F.object_id
              AND F.relationship_type_code = 'OPP_QUOTE'
              AND F.quote_object_type_code = 'HEADER'
              AND F.quote_object_id  = G.quote_header_id
              AND G.order_id = H.header_id
              AND H.flow_status_code    = 'BOOKED'
              AND NVL(D.deleted_flag,'N') <> 'Y'
              AND I.header_id = H.header_id
              AND trunc(H.creation_date) between p_start_date and p_end_date+0.99999
GROUP BY
              A.campaign_id,trunc(H.creation_date)
UNION ALL
SELECT
              f3.act_metric_used_by_id campaign_id
              ,trunc(f3.creation_date)    creation_date
              ,0 leads_open
              ,0 leads_closed
              ,0 leads_open_amt
              ,0 leads_closed_amt
              ,0 leads_new
              ,0 leads_new_amt
              ,0 leads_hot
              ,0 leads_converted
              ,0 leads_dead
              ,0 opportunities
              ,0 opportunity_amt
              ,0 orders_booked
              ,0 orders_booked_amt
              ,sum(convert_currency(nvl(f3.functional_currency_code,'USD'),nvl(f3.func_forecasted_delta,0)))
        forecasted_revenue
              ,sum(convert_currency(nvl(f3.functional_currency_code,'USD'),nvl(f3.func_actual_delta,0)))
        actual_revenue
              ,0 forecasted_cost
              ,0 actual_cost
              ,0 forecasted_responses
              ,0 positive_responses
              ,0 targeted_customers
FROM
              ams_act_metric_hst                f3
              ,ams_metrics_all_b                 g3
WHERE
                     f3.arc_act_metric_used_by       = 'CAMP'
              AND    g3.metric_calculation_type         IN ('MANUAL','FUNCTION')
              AND    g3.metric_category             = 902
              AND    g3.metric_id                    = f3.metric_id
              AND    trunc(f3.creation_date) between p_start_date and p_end_date+0.99999
GROUP BY
              f3.act_metric_used_by_id,trunc(f3.creation_date)
HAVING
              sum(convert_currency(nvl(f3.functional_currency_code,'USD'),nvl(f3.func_forecasted_delta,0))) <> 0
              OR
              sum(convert_currency(nvl(f3.functional_currency_code,'USD'),nvl(f3.func_actual_delta,0))) <> 0
UNION ALL
SELECT
              f1.act_metric_used_by_id campaign_id
              ,trunc(f1.creation_date) creation_date
              ,0 leads_open
              ,0 leads_closed
              ,0 leads_open_amt
              ,0 leads_closed_amt
              ,0 leads_new
              ,0 leads_new_amt
              ,0 leads_hot
              ,0 leads_converted
              ,0 leads_dead
              ,0 opportunities
              ,0 opportunity_amt
              ,0 orders_booked
              ,0 orders_booked_amt
              ,0 forecasted_revenue
              ,0 actual_revenue
              ,sum(convert_currency(nvl(f1.functional_currency_code,'USD'),nvl(f1.func_forecasted_delta,0)))
                 forecasted_cost
              ,sum(convert_currency(nvl(f1.functional_currency_code,'USD'),nvl(f1.func_actual_delta,0)))
                 actual_cost
              ,0 forecasted_responses
              ,0 positive_responses
              ,0 targeted_customers
FROM
              ams_act_metric_hst            f1
              ,ams_metrics_all_b            g1
WHERE
               f1.arc_act_metric_used_by       = 'CAMP'
        AND    g1.metric_category              = 901
        AND    g1.metric_id                    = f1.metric_id
        AND    g1.metric_calculation_type         IN ('MANUAL','FUNCTION')
        AND    trunc(f1.creation_date) between p_start_date and p_end_date+0.99999
GROUP BY
               f1.act_metric_used_by_id,trunc(f1.creation_date)
HAVING
              sum(convert_currency(nvl(f1.functional_currency_code,'USD'),nvl(f1.func_forecasted_delta,0))) <> 0
              OR
              sum(convert_currency(nvl(f1.functional_currency_code,'USD'),nvl(f1.func_actual_delta,0))) <> 0
UNION ALL
SELECT
               f3.act_metric_used_by_id campaign_id
               ,trunc(f3.creation_date) creation_date
               ,0 leads_open
               ,0 leads_closed
               ,0 leads_open_amt
               ,0 leads_closed_amt
               ,0 leads_new
               ,0 leads_new_amt
               ,0 leads_hot
               ,0 leads_converted
               ,0 leads_dead
               ,0 opportunities
               ,0 opportunity_amt
               ,0 orders_booked
               ,0 orders_booked_amt
               ,0 forecasted_revenue
               ,0 actual_revenue
               ,0 forecasted_cost
               ,0 actual_cost
               ,sum(nvl(f3.func_forecasted_delta,0)) forecasted_responses
               ,0 positive_responses
               ,0 targeted_customers
FROM
               ams_act_metric_hst               f3
               ,ams_metrics_all_b                g3
WHERE
               f3.arc_act_metric_used_by       = 'CAMP'
        AND    g3.metric_calculation_type         IN ('MANUAL','FUNCTION')
        AND    g3.metric_category              = 903
        AND    g3.metric_id                    = f3.metric_id
        AND    trunc(f3.creation_date) between p_start_date and p_end_date+0.99999
GROUP BY
               f3.act_metric_used_by_id,trunc(f3.creation_date)
HAVING
               sum(nvl(f3.func_forecasted_delta,0)) <> 0
UNION ALL
SELECT
               A.campaign_id campaign_id
               ,trunc(X.creation_date) creation_date
               ,0 leads_open
               ,0 leads_closed
               ,0 leads_open_amt
               ,0 leads_closed_amt
               ,0 leads_new
               ,0 leads_new_amt
               ,0 leads_hot
               ,0 leads_converted
               ,0 leads_dead
               ,0 opportunities
               ,0 opportunity_amt
               ,0 orders_booked
               ,0 orders_booked_amt
               ,0 forecasted_revenue
               ,0 actual_revenue
               ,0 forecasted_cost
               ,0 actual_cost
               ,0 forecasted_responses
               ,count(Y.result_id)  positive_responses
               ,0 targeted_customers
               FROM    ams_campaigns_all_b A
                       ,jtf_ih_interactions X
                       ,jtf_ih_results_b Y
WHERE
               A.source_code = X.source_code
           AND X.result_id = Y.result_id
           AND Y.positive_response_flag = 'Y'
           AND trunc(X.creation_date) between p_start_date and p_end_date+0.99999
GROUP BY
           A.campaign_id,trunc(X.creation_date)
) metric
GROUP BY
           metric.campaign_id
           ,metric.creation_date
) inner
           ,ams_campaigns_all_b    A
           ,ams_source_codes       C
           ,jtf_loc_hierarchies_b  D
WHERE
                  a.campaign_id        =  inner.campaign_id
           AND    A.campaign_id        = C.source_code_for_id
           AND    C.arc_source_code_for = 'CAMP'
           AND    A.source_code        = C.source_code
           AND    a.city_id            =  d.location_hierarchy_id
           AND    a.status_code        IN ('ACTIVE', 'CANCELLED', 'COMPLETED','CLOSED')
           AND    a.rollup_type        <> 'RCAM'
           AND    trunc(a.actual_exec_start_date)    >= trunc(l_min_start_date)
)Outer;

     COMMIT;

      l_temp_msg := to_char( sysdate, 'dd/mm/yyyy:hh:mi:ss');
      ams_utility_pvt.write_conc_log('BIM_CAMPAIGN_FACTS:LOAD: AFTER FIRST INSERT ' || l_temp_msg);


      l_temp_msg := to_char( sysdate, 'dd/mm/yyyy:hh:mi:ss');
      ams_utility_pvt.write_conc_log('BIM_CAMPAIGN_FACTS:LOAD: BEFORE SECOND INSERT ' || l_temp_msg);

      INSERT /*+ append parallel(CDF,1) */
      INTO bim_r_camp_daily_facts CDF
      (
               campaign_daily_transaction_id
              ,creation_date
              ,last_update_date
              ,created_by
              ,last_updated_by
              ,last_update_login
              ,campaign_id
              ,schedule_id
              ,transaction_create_date
              ,schedule_source_code
              ,campaign_source_code
              ,schedule_activity_type
	      ,schedule_activity_id
              ,campaign_purpose
              ,campaign_type
              ,start_date
              ,end_date
              ,schedule_purpose
              ,business_unit_id
              ,org_id
	      ,campaign_status
              ,schedule_status
              ,campaign_country
              ,campaign_region
              ,schedule_region
              ,schedule_country
              ,campaign_budget_fc
              ,schedule_budget_fc
              ,load_date
	      ,year
	      ,qtr
              ,month
              ,leads_open
              ,leads_closed
              ,leads_open_amt
              ,leads_closed_amt
	      ,leads_new
	      ,leads_new_amt
	      ,leads_hot
	      ,leads_converted
	      ,metric1 -- leads_dead
              ,opportunities
	      ,opportunity_amt
              ,orders_booked
              ,orders_booked_amt
              ,forecasted_revenue
              ,actual_revenue
              ,forecasted_cost
              ,actual_cost
              ,forecasted_responses
              ,positive_responses
              ,targeted_customers
              ,budget_requested
              ,budget_approved
      )
      SELECT  /*+ parallel(INNER,1) */
		bim_r_camp_daily_facts_s.nextval
              ,sysdate
              ,sysdate
              ,-1
              ,-1
              ,-1
              ,campaign_id
              ,schedule_id
              ,transaction_create_date
              ,schedule_source_code
              ,campaign_source_code
              ,schedule_activity_type
	      ,schedule_activity_id
              ,campaign_purpose
              ,campaign_type
              ,start_date
              ,end_date
              ,schedule_purpose
              ,business_unit_id
              ,org_id
	      ,campaign_status
              ,schedule_status
              ,campaign_country
              ,campaign_region
              ,schedule_region
              ,schedule_country
              ,0 schedule_budget_fc
              ,0 campaign_budget_fc
              ,weekend_date
	      ,year
	      ,qtr
              ,month
              ,leads_open
              ,leads_closed
              ,leads_open_amt
              ,leads_closed_amt
	      ,leads_new
	      ,leads_new_amt
	      ,leads_hot
	      ,leads_converted
	      ,leads_dead
              ,opportunities
	      ,opportunity_amt
              ,orders_booked
              ,orders_booked_amt
              ,forecasted_revenue
              ,actual_revenue
              ,forecasted_cost
              ,actual_cost
              ,forecasted_responses
              ,positive_responses
              ,targeted_customers
              ,0 request_amount
	      ,0 approved_amount
      FROM
      (
SELECT
	      a.campaign_id		campaign_id
              ,e.schedule_id		schedule_id
      	      ,inner.creation_date	transaction_create_date
              ,e.source_code		schedule_source_code
      	      ,b2.source_code_id	campaign_source_code_id
      	      ,b1.source_code_id	schedule_source_code_id
	      ,a.source_code		campaign_source_code
              ,e.activity_type_code	schedule_activity_type
	      ,decode(e.activity_type_code,'EVENTS',-9999, e.activity_id) schedule_activity_id
	      ,a.campaign_type		campaign_purpose
              ,a.rollup_type		campaign_type
              ,e.start_date_time	start_date
              ,nvl(e.end_date_time, a.actual_exec_end_date)	        end_date
              ,e.objective_code		schedule_purpose
              ,a.business_unit_id	business_unit_id
              ,e.org_id			org_id
	      ,a.status_code		campaign_status
              ,e.status_code		schedule_status
              ,a.city_id		campaign_country
              ,d2.area2_code		campaign_region
              ,d1.area2_code		schedule_region
              ,e.country_id		schedule_country
              ,(decode(decode( to_char(inner.creation_date,'MM') , to_char(next_day(inner.creation_date,TO_NUMBER(to_char(to_date('07/09/2004', 'DD/MM/RRRR'), 'DD'))),'MM') ,'TRUE','FALSE' )
      	        ,'TRUE'
      	        ,decode(decode(inner.creation_date , (next_day(inner.creation_date, TO_NUMBER(to_char(to_date('07/09/2004', 'DD/MM/RRRR'), 'DD'))) - 7) , 'TRUE' ,'FALSE')
       	        ,'TRUE'
      	        ,inner.creation_date
      	        ,'FALSE'
      	        ,next_day(inner.creation_date, TO_NUMBER(to_char(to_date('07/09/2004', 'DD/MM/RRRR'), 'DD'))))
      	        ,'FALSE'
      	        ,decode(decode(to_char(inner.creation_date,'MM'),to_char(next_day(inner.creation_date,TO_NUMBER(to_char(to_date('07/09/2004', 'DD/MM/RRRR'), 'DD'))),'MM'),'TRUE','FALSE')
      	        ,'FALSE'
      	        ,last_day(inner.creation_date))))         weekend_date
              ,bim_set_of_books.get_fiscal_year(inner.creation_date,0) year
              ,bim_set_of_books.get_fiscal_qtr(inner.creation_date,0)  qtr
              ,bim_set_of_books.get_fiscal_month(inner.creation_date,0) month
              ,inner.leads_open            leads_open
              ,inner.leads_closed          leads_closed
              ,inner.leads_open_amt    	  leads_open_amt
              ,inner.leads_closed_amt      leads_closed_amt
	      ,inner.leads_new		  leads_new
	      ,inner.leads_new_amt	  leads_new_amt
	      ,inner.leads_hot		  leads_hot
	      ,inner.leads_converted	  leads_converted
	      ,inner.leads_dead		  leads_dead
              ,inner.opportunities         opportunities
	      ,inner.opportunity_amt	  opportunity_amt
              ,inner.orders_booked	  orders_booked
              ,inner.orders_booked_amt	  orders_booked_amt
              ,inner.forecasted_revenue 	  forecasted_revenue
              ,inner.actual_revenue        actual_revenue
              ,inner.forecasted_cost       forecasted_cost
              ,inner.actual_cost           actual_cost
              ,inner.forecasted_responses  forecasted_responses
              ,inner.positive_responses    positive_responses
              ,inner.targeted_customers	  targeted_customers
FROM  (
SELECT
               metric.schedule_id schedule_id
              ,metric.creation_date creation_date
              ,sum(nvl(metric.leads_open,0))  	       leads_open
              ,sum(nvl(metric.leads_closed,0))	       leads_closed
              ,sum(nvl(metric.leads_open_amt,0))       leads_open_amt
              ,sum(nvl(metric.leads_closed_amt,0))     leads_closed_amt
	      ,sum(nvl(metric.leads_new,0))	       leads_new
	      ,sum(nvl(metric.leads_new_amt,0))	       leads_new_amt
	      ,sum(nvl(metric.leads_hot,0))	       leads_hot
	      ,sum(nvl(metric.leads_converted,0))      leads_converted
	      ,sum(nvl(metric.leads_dead,0))	       leads_dead
              ,sum(nvl(metric.opportunities,0))        opportunities
	      ,sum(nvl(metric.opportunity_amt,0))      opportunity_amt
              ,sum(nvl(metric.orders_booked,0))	       orders_booked
              ,sum(nvl(metric.orders_booked_amt,0))    orders_booked_amt
              ,sum(nvl(metric.forecasted_revenue,0))   forecasted_revenue
              ,sum(nvl(metric.actual_revenue,0))       actual_revenue
              ,sum(nvl(metric.forecasted_cost,0))      forecasted_cost
              ,sum(nvl(metric.actual_cost,0))          actual_cost
              ,sum(nvl(metric.forecasted_responses,0)) forecasted_responses
              ,sum(nvl(metric.positive_responses,0))   positive_responses
              ,sum(nvl(metric.targeted_customers,0))   targeted_customers
FROM (
SELECT
              A.schedule_id schedule_id
              ,trunc(decode(Y.opp_open_status_flag,'Y',X.creation_date,X.last_update_date))creation_date
              ,sum(decode(Y.opp_open_status_flag,'Y',1,0)) leads_open
              ,sum(decode(Y.opp_open_status_flag,'Y',0,1)) leads_closed
              ,sum(decode(Y.opp_open_status_flag,'Y',convert_currency(nvl(X.currency_code,'USD'),nvl(X.budget_amount,0)),0)) leads_open_amt
              ,sum(decode(Y.opp_open_status_flag,'Y',0,decode(X.status_code,'DEAD_LEAD',convert_currency(nvl(X.currency_code,'USD'),nvl(X.budget_amount,0)),0))) leads_closed_amt
              ,sum(decode(Y.opp_open_status_flag,'Y',decode(X.status_code,'NEW',1,0),0))       leads_new
              ,sum(decode(Y.opp_open_status_flag,'Y',decode(X.status_code,'NEW',convert_currency(nvl(X.currency_code,'USD'),nvl(X.budget_amount,0)),0),0)) leads_new_amt
              ,sum(decode(Y.opp_open_status_flag,'Y',decode(X.lead_rank_id,10000,1,0),0))      leads_hot
              ,sum(decode(Y.opp_open_status_flag,'N',decode(X.status_code,'CONVERTED_TO_OPPORTUNITY',1,0),0)) leads_converted
              ,sum(decode(Y.opp_open_status_flag,'Y',0,decode(X.status_code,'DEAD_LEAD',1,0))) leads_dead
              ,0 opportunities
              ,0 opportunity_amt
              ,0 orders_booked
              ,0 orders_booked_amt
              ,0 forecasted_revenue
              ,0 actual_revenue
              ,0 forecasted_cost
              ,0 actual_cost
              ,0 forecasted_responses
              ,0 positive_responses
              ,0 targeted_customers
FROM
              ams_campaign_schedules_b A
              ,ams_source_codes  C
              ,as_sales_leads X
              ,as_statuses_b  Y
WHERE
                    A.schedule_id = C.source_code_for_id
              AND   C.arc_source_code_for = 'CSCH'
              AND   A.source_code = C.source_code
              AND   C.source_code_id = X.source_promotion_id
              AND   X.status_code = Y.status_code
              AND   Y.lead_flag = 'Y'
              AND   Y.enabled_flag = 'Y'
              AND   NVL(X.DELETED_FLAG,'N') <> 'Y'
              AND   trunc(decode(Y.opp_open_status_flag,'Y',X.creation_date,X.last_update_date)) between p_start_date and p_end_date+0.99999
GROUP BY
              a.schedule_id
              ,trunc(decode(Y.opp_open_status_flag,'Y',X.creation_date,X.last_update_date))
UNION ALL
SELECT
              A.schedule_id schedule_id
              ,trunc(X.creation_date) creation_date
              ,0 leads_open
              ,0 leads_closed
              ,0 leads_open_amt
              ,0 leads_closed_amt
              ,0 leads_new
              ,0 leads_new_amt
              ,0 leads_hot
              ,0 leads_converted
              ,0 leads_dead
              ,count(distinct X.lead_id) opportunities
              ,sum(convert_currency(nvl(X.currency_code,'USD'),nvl(X.total_amount,0))) opportunity_amt
              ,0 orders_booked
              ,0 orders_booked_amt
              ,0 forecasted_revenue
              ,0 actual_revenue
              ,0 forecasted_cost
              ,0 actual_cost
              ,0 forecasted_responses
              ,0 positive_responses
              ,0 targeted_customers
FROM
              ams_campaign_schedules_b A
              ,ams_source_codes  C
              ,as_leads_all 	X
WHERE
                  A.schedule_id = C.source_code_for_id
              AND C.arc_source_code_for = 'CSCH'
              AND A.source_code = C.source_code
              AND C.source_code_id = X.source_promotion_id
              AND trunc(X.creation_date) between p_start_date and p_end_date+0.99999
GROUP BY
              A.schedule_id,trunc(X.creation_date)
UNION ALL
SELECT
              A.schedule_id schedule_id
              ,trunc(H.creation_date) 	creation_date
              ,0 leads_open
              ,0 leads_closed
              ,0 leads_open_amt
              ,0 leads_closed_amt
              ,0 leads_new
              ,0 leads_new_amt
              ,0 leads_hot
              ,0 leads_converted
              ,0 leads_dead
              ,0 opportunities
              ,0 opportunity_amt
              ,count(distinct(h.header_id)) orders_booked
              ,sum(decode(h.flow_status_code,'BOOKED',convert_currency(nvl(H.transactional_curr_code,'USD')
              ,nvl(I.unit_selling_price * I.ordered_quantity,0)),0)) orders_booked_amt
              ,0 forecasted_revenue
              ,0 actual_revenue
              ,0 forecasted_cost
              ,0 actual_cost
              ,0 forecasted_responses
              ,0 positive_responses
              ,0 targeted_customers
FROM
              ams_campaign_schedules_b A
              ,ams_source_codes  	C
              ,as_sales_leads      	D
              ,as_sales_lead_opportunity      	D1
              ,as_leads_all              E
              ,aso_quote_related_objects F
              ,aso_quote_headers_all     G
              ,oe_order_headers_all     H
              ,oe_order_lines_all	I
WHERE
               A.schedule_id = C.source_code_for_id
              AND C.arc_source_code_for = 'CSCH'
              AND A.source_code = C.source_code
              AND C.source_code_id =  D.source_promotion_id
              AND D.sales_lead_id = D1.sales_lead_id
              AND D1.opportunity_id     = E.lead_id
              AND E.lead_id           = F.object_id
              AND F.relationship_type_code = 'OPP_QUOTE'
              AND F.quote_object_type_code = 'HEADER'
              AND F.quote_object_id  = G.quote_header_id
              AND G.order_id = H.header_id
              AND H.flow_status_code    = 'BOOKED'
              AND NVL(D.deleted_flag,'N') <> 'Y'
              AND I.header_id = H.header_id
              AND trunc(H.creation_date) between p_start_date and p_end_date+0.99999
GROUP BY
              A.schedule_id,trunc(H.creation_date)
UNION ALL
SELECT
              f3.act_metric_used_by_id schedule_id
              ,trunc(f3.creation_date)    creation_date
              ,0 leads_open
              ,0 leads_closed
              ,0 leads_open_amt
              ,0 leads_closed_amt
              ,0 leads_new
              ,0 leads_new_amt
              ,0 leads_hot
              ,0 leads_converted
              ,0 leads_dead
              ,0 opportunities
              ,0 opportunity_amt
              ,0 orders_booked
              ,0 orders_booked_amt
              ,sum(convert_currency(nvl(f3.functional_currency_code,'USD'),nvl(f3.func_forecasted_delta,0)))
        forecasted_revenue
              ,sum(convert_currency(nvl(f3.functional_currency_code,'USD'),nvl(f3.func_actual_delta,0)))
        actual_revenue
              ,0 forecasted_cost
              ,0 actual_cost
              ,0 forecasted_responses
              ,0 positive_responses
              ,0 targeted_customers
FROM
              ams_act_metric_hst                f3
              ,ams_metrics_all_b                 g3
WHERE
                     f3.arc_act_metric_used_by       = 'CSCH'
              AND    g3.metric_calculation_type         IN ('MANUAL','FUNCTION')
              AND    g3.metric_category             = 902
              AND    g3.metric_id                    = f3.metric_id
              AND    trunc(f3.creation_date) between p_start_date and p_end_date+0.99999
GROUP BY
              f3.act_metric_used_by_id,trunc(f3.creation_date)
HAVING
              sum(convert_currency(nvl(f3.functional_currency_code,'USD'),nvl(f3.func_forecasted_delta,0))) <> 0
              OR
              sum(convert_currency(nvl(f3.functional_currency_code,'USD'),nvl(f3.func_actual_delta,0))) <> 0
UNION ALL
SELECT
              f1.act_metric_used_by_id schedule_id
              ,trunc(f1.creation_date) creation_date
              ,0 leads_open
              ,0 leads_closed
              ,0 leads_open_amt
              ,0 leads_closed_amt
              ,0 leads_new
              ,0 leads_new_amt
              ,0 leads_hot
              ,0 leads_converted
              ,0 leads_dead
              ,0 opportunities
              ,0 opportunity_amt
              ,0 orders_booked
              ,0 orders_booked_amt
              ,0 forecasted_revenue
              ,0 actual_revenue
              ,sum(convert_currency(nvl(f1.functional_currency_code,'USD'),nvl(f1.func_forecasted_delta,0)))
                 forecasted_cost
              ,sum(convert_currency(nvl(f1.functional_currency_code,'USD'),nvl(f1.func_actual_delta,0)))
                 actual_cost
              ,0 forecasted_responses
              ,0 positive_responses
              ,0 targeted_customers
FROM
              ams_act_metric_hst            f1
              ,ams_metrics_all_b            g1
WHERE
               f1.arc_act_metric_used_by       = 'CSCH'
        AND    g1.metric_category              = 901
        AND    g1.metric_id                    = f1.metric_id
        AND    g1.metric_calculation_type         IN ('MANUAL','FUNCTION')
        AND    trunc(f1.creation_date) between p_start_date and p_end_date+0.99999
GROUP BY
               f1.act_metric_used_by_id,trunc(f1.creation_date)
HAVING
              sum(convert_currency(nvl(f1.functional_currency_code,'USD'),nvl(f1.func_forecasted_delta,0))) <> 0
              OR
              sum(convert_currency(nvl(f1.functional_currency_code,'USD'),nvl(f1.func_actual_delta,0))) <> 0
UNION ALL
SELECT
               f3.act_metric_used_by_id schedule_id
               ,trunc(f3.creation_date) creation_date
               ,0 leads_open
               ,0 leads_closed
               ,0 leads_open_amt
               ,0 leads_closed_amt
               ,0 leads_new
               ,0 leads_new_amt
               ,0 leads_hot
               ,0 leads_converted
               ,0 leads_dead
               ,0 opportunities
               ,0 opportunity_amt
               ,0 orders_booked
               ,0 orders_booked_amt
               ,0 forecasted_revenue
               ,0 actual_revenue
               ,0 forecasted_cost
               ,0 actual_cost
               ,sum(nvl(f3.func_forecasted_delta,0)) forecasted_responses
               ,0 positive_responses
               ,0 targeted_customers
FROM
               ams_act_metric_hst               f3
               ,ams_metrics_all_b                g3
WHERE
               f3.arc_act_metric_used_by       = 'CSCH'
        AND    g3.metric_calculation_type         IN ('MANUAL','FUNCTION')
        AND    g3.metric_category              = 903
        AND    g3.metric_id                    = f3.metric_id
        AND    trunc(f3.creation_date) between p_start_date and p_end_date+0.99999
GROUP BY
               f3.act_metric_used_by_id,trunc(f3.creation_date)
HAVING
               sum(nvl(f3.func_forecasted_delta,0)) <> 0
UNION ALL
SELECT
               A.schedule_id schedule_id
               ,trunc(X.creation_date) creation_date
               ,0 leads_open
               ,0 leads_closed
               ,0 leads_open_amt
               ,0 leads_closed_amt
               ,0 leads_new
               ,0 leads_new_amt
               ,0 leads_hot
               ,0 leads_converted
               ,0 leads_dead
               ,0 opportunities
               ,0 opportunity_amt
               ,0 orders_booked
               ,0 orders_booked_amt
               ,0 forecasted_revenue
               ,0 actual_revenue
               ,0 forecasted_cost
               ,0 actual_cost
               ,0 forecasted_responses
               ,sum(decode(A.use_parent_code_flag,'Y',0,1))  positive_responses
               ,0 targeted_customers
               FROM    ams_campaign_schedules_b A
                       ,jtf_ih_interactions X
                       ,jtf_ih_results_b Y
WHERE
               A.source_code = X.source_code
           AND X.result_id = Y.result_id
           AND Y.positive_response_flag = 'Y'
           AND trunc(X.creation_date) between p_start_date and p_end_date+0.99999
GROUP BY
           A.schedule_id,trunc(X.creation_date)
UNION ALL
SELECT
              A.schedule_id schedule_id
              ,trunc(p.creation_date)     creation_date
              ,0 leads_open
              ,0 leads_closed
              ,0 leads_open_amt
              ,0 leads_closed_amt
              ,0 leads_new
              ,0 leads_new_amt
              ,0 leads_hot
              ,0 leads_converted
              ,0 leads_dead
              ,0 opportunities
              ,0 opportunity_amt
              ,0 orders_booked
              ,0 orders_booked_amt
              ,0 forecasted_revenue
              ,0 actual_revenue
              ,0 forecasted_cost
              ,0 actual_cost
              ,0 forecasted_responses
              ,0 positive_responses
              ,count(p.list_entry_id) targeted_customers
FROM
               ams_list_entries p
               ,ams_act_lists q
               ,ams_campaign_schedules_b A
WHERE
                 p.list_header_id   = q.list_header_id
         AND     q.list_used_by     = 'CSCH'
         AND     q.list_act_type = 'TARGET'
         AND     trunc(p.creation_date) between p_start_date and p_end_date+0.99999
         AND     q.list_used_by_id     = A.schedule_id
		 AND      p.enabled_flag='Y'
GROUP   BY
                 A.schedule_id, trunc(p.creation_date)
UNION ALL
SELECT
              A.schedule_id schedule_id
              ,trunc(p.creation_date)     creation_date
              ,0 leads_open
              ,0 leads_closed
              ,0 leads_open_amt
              ,0 leads_closed_amt
              ,0 leads_new
              ,0 leads_new_amt
              ,0 leads_hot
              ,0 leads_converted
              ,0 leads_dead
              ,0 opportunities
              ,0 opportunity_amt
              ,0 orders_booked
              ,0 orders_booked_amt
              ,0 forecasted_revenue
              ,0 actual_revenue
              ,0 forecasted_cost
              ,0 actual_cost
              ,0 forecasted_responses
              ,0 positive_responses
              ,count(p.list_entry_id) targeted_customers
FROM
               ams_list_entries p
               ,ams_act_lists q
               ,ams_campaign_schedules_b A
WHERE
                 trunc(p.creation_date) between p_start_date and p_end_date+0.99999
         AND     p.list_header_id   = q.list_header_id
         AND     q.list_used_by     = 'EONE'
         AND     q.list_act_type    = 'TARGET'
	 AND     A.activity_type_code = 'EVENTS'
         AND     q.list_used_by_id    = A.related_event_id
		 AND     p.enabled_flag='Y'
GROUP   BY
                 A.schedule_id, trunc(p.creation_date)
) metric
GROUP BY
           metric.schedule_id
           ,metric.creation_date
) inner
           ,ams_campaign_schedules_b    E
           ,ams_campaigns_all_b 	    A
           ,ams_source_codes           B1
           ,ams_source_codes           B2
           ,jtf_loc_hierarchies_b  D1
           ,jtf_loc_hierarchies_b  D2
WHERE
                  e.schedule_id             =  inner.schedule_id
           AND    e.campaign_id             =  a.campaign_id
           AND    e.country_id              =  d1.location_hierarchy_id
           AND    a.city_id                 =  d2.location_hierarchy_id
           AND    a.status_code             IN ('ACTIVE', 'CANCELLED', 'COMPLETED','CLOSED')
           AND    e.status_code             IN ('ACTIVE', 'CANCELLED', 'COMPLETED','CLOSED')
           AND    a.rollup_type             <> 'RCAM'
           AND    b1.source_code_for_id     =  decode(e.source_code,a.source_code,a.campaign_id,e.schedule_id)
           AND    b1.arc_source_code_for    =  decode(e.source_code,a.source_code,'CAMP','CSCH')
           AND    b1.source_code            =  e.source_code
           AND    b2.source_code_for_id     =  a.campaign_id
           AND    b2.arc_source_code_for    =  'CAMP'
           AND    b2.source_code            =  a.source_code
           AND    trunc(a.actual_exec_start_date)  >= trunc(l_min_start_date)
)Outer;

     COMMIT;
      l_temp_msg := to_char( sysdate, 'dd/mm/yyyy:hh:mi:ss');
      ams_utility_pvt.write_conc_log('BIM_CAMPAIGN_FACTS:LOAD: AFTER SECOND INSERT ' || l_temp_msg);

     EXECUTE IMMEDIATE 'ALTER SESSION DISABLE PARALLEL dml ';
     EXECUTE IMMEDIATE 'ALTER SESSION ENABLE PARALLEL dml ';

    EXECUTE IMMEDIATE 'ALTER SEQUENCE '||l_schema||'.bim_r_camp_daily_facts_s CACHE 20';

/* The above main INSERT statement handles the amounts associated with the SCHEDULEs. Here with this stmt we
are dealing with the CAMPAIGNs of the campaigns table */

      l_temp_msg := to_char( sysdate, 'dd/mm/yyyy:hh:mi:ss');
      ams_utility_pvt.write_conc_log('BIM_CAMPAIGN_FACTS:LOAD: BEFORE THIRD INSERT ' || l_temp_msg);
      INSERT /*+ append parallel(CDF,1) */
      INTO bim_r_camp_daily_facts CDF
      (
               campaign_daily_transaction_id
              ,creation_date
              ,last_update_date
              ,created_by
              ,last_updated_by
              ,last_update_login
              ,campaign_id
              ,schedule_id
              ,transaction_create_date
              ,schedule_source_code
              ,campaign_source_code
              ,schedule_activity_type
	      ,schedule_activity_id
              ,campaign_purpose
              ,campaign_type
              ,start_date
              ,end_date
              ,schedule_purpose
              ,business_unit_id
              ,org_id
	      ,campaign_status
              ,schedule_status
              ,campaign_country
              ,campaign_region
              ,schedule_region
              ,schedule_country
              ,campaign_budget_fc
              ,schedule_budget_fc
              ,load_date
	      ,year
	      ,qtr
              ,month
              ,leads_open
              ,leads_closed
              ,leads_open_amt
              ,leads_closed_amt
	      ,leads_new
	      ,leads_new_amt
	      ,leads_hot
	      ,leads_converted
	      ,metric1 --leads_dead
              ,opportunities
	      ,opportunity_amt
              ,orders_booked
              ,orders_booked_amt
              ,forecasted_revenue
              ,actual_revenue
              ,forecasted_cost
              ,actual_cost
              ,forecasted_responses
              ,positive_responses
              ,targeted_customers
              ,budget_requested
              ,budget_approved
      )
      SELECT  /*+ parallel(INNER,1) */
	      bim_r_camp_daily_facts_s.nextval
              ,sysdate
              ,sysdate
              ,-1
              ,-1
              ,-1
              ,inner.act_budget_used_by_id campaign_id
              ,0 schedule_id
              ,inner.creation_date transaction_create_date
              ,0 schedule_source_code
              ,inner.campaign_source_code campaign_source_code
              ,0 schedule_activity_type
	      ,0 schedule_activity_id
              ,inner.campaign_purpose campaign_purpose
              ,inner.campaign_type campaign_type
              ,inner.start_date start_date
              ,inner.end_date end_date
              ,0 schedule_purpose
              ,inner.business_unit_id business_unit_id
              ,0 org_id
	      ,inner.campaign_status campaign_status
              ,0 schedule_status
              ,inner.campaign_country_code campaign_country
              ,inner.campaign_region_code campaign_region
              ,0 schedule_region
              ,0 schedule_country
              ,inner.campaign_budget_amount campaign_budget_fc
              ,0 schedule_budget_fc
              ,(decode(decode( to_char(inner.creation_date,'MM') , to_char(next_day(inner.creation_date,TO_NUMBER(to_char(to_date('07/09/2004', 'DD/MM/RRRR'), 'DD'))),'MM') ,'TRUE','FALSE' )
      	        ,'TRUE'
      	        ,decode(decode(Inner.creation_date , (next_day(inner.creation_date, TO_NUMBER(to_char(to_date('07/09/2004', 'DD/MM/RRRR'), 'DD'))) - 7) , 'TRUE' ,'FALSE')
       	        ,'TRUE'
      	        ,inner.creation_date
      	        ,'FALSE'
      	        ,next_day(inner.creation_date, TO_NUMBER(to_char(to_date('07/09/2004', 'DD/MM/RRRR'), 'DD'))))
      	        ,'FALSE'
      	        ,decode(decode(to_char(inner.creation_date,'MM'),to_char(next_day(inner.creation_date,TO_NUMBER(to_char(to_date('07/09/2004', 'DD/MM/RRRR'), 'DD'))),'MM'),'TRUE','FALSE')
      	        ,'FALSE'
      	        ,last_day(Inner.creation_date))))         weekend_date
	      ,bim_set_of_books.get_fiscal_year(inner.creation_date,0) year
              ,bim_set_of_books.get_fiscal_qtr(inner.creation_date,0)  qtr
              ,bim_set_of_books.get_fiscal_month(inner.creation_date,0) month
              ,0 leads_open
              ,0 leads_closed
              ,0 leads_open_amt
              ,0 leads_closed_amt
	      ,0 leads_new
	      ,0 leads_new_amt
	      ,0 leads_hot
	      ,0 leads_converted
	      ,0 leads_dead
              ,0 opportunities
	      ,0 opportunity_amt
              ,0 orders_booked
              ,0 orders_booked_amt
              ,0 forecasted_revenue
              ,0 actual_revenue
              ,0 forecasted_cost
              ,0 actual_cost
              ,0 forecasted_responses
              ,0 positive_responses
              ,0 targeted_customers
              ,inner.request_amount request_amount
	      ,inner.approved_amount approved_amount
FROM
      (
        SELECT
                s.act_budget_used_by_id   act_budget_used_by_id
                ,decode(s.status_code
		   ,'PENDING'
		   ,trunc(nvl(s.request_date,s.creation_date))
		   ,'APPROVED'
                   ,trunc(nvl(s.approval_date,s.last_update_date))
		   ) creation_date
                ,sum(decode(s.status_code
                   ,'PENDING'
                   ,convert_currency(nvl(request_currency,'USD'),nvl(s.request_amount,0))
                   ,'APPROVED'
                   , convert_currency(nvl(approved_in_currency,'USD'),nvl(s.approved_original_amount,0))
                   ))  request_amount
                ,sum(decode(s.status_code
                   ,'PENDING'
                   ,0
                   ,'APPROVED'
                   ,convert_currency(nvl(approved_in_currency,'USD'),nvl(s.approved_original_amount,0))
                   ))    approved_amount
                ,b2.source_code_id      	  campaign_source_code_id
                ,a.source_code          	  campaign_source_code
                ,a.campaign_type        	  campaign_purpose
                ,a.status_code   		  campaign_status
                ,a.rollup_type          	  campaign_type
                ,a.actual_exec_start_date   start_date
                ,a.actual_exec_end_date     end_date
                ,a.business_unit_id     	  business_unit_id
                ,a.city_id              	  campaign_country_code
                ,d.area2_code           	  campaign_region_code
                ,a.budget_amount_fc     	  campaign_budget_amount
        FROM    ozf_act_budgets    	    S
                ,ams_campaigns_all_b     A
                ,ams_source_codes        B2
                ,jtf_loc_hierarchies_b   D
        WHERE   s.arc_act_budget_used_by         = 'CAMP'
                AND    s.budget_source_type      = 'FUND'
                --AND    s.transfer_type         = 'REQUEST'
                AND    s.act_budget_used_by_id 	 = a.campaign_id
                AND    a.city_id                 =  d.location_hierarchy_id
                AND    a.status_code             IN ('ACTIVE', 'CANCELLED', 'COMPLETED','CLOSED')
                AND    a.rollup_type             <> 'RCAM'
                AND    b2.source_code            =  a.source_code
                AND    trunc(a.actual_exec_start_date)  >= trunc(l_min_start_date)
                AND    a.actual_exec_start_date  <= p_end_date
                AND    decode(s.status_code,'PENDING',trunc(nvl(s.request_date,s.creation_date)),'APPROVED',trunc(nvl(s.approval_date,s.last_update_date)) ) between p_start_date and p_end_date+0.99999
                AND    exists (select distinct campaign_id
                               from ams_campaign_schedules_b x
                               where x.campaign_id = a.campaign_id)
        GROUP BY s.act_budget_used_by_id
                 ,decode(s.status_code,'PENDING',trunc(nvl(s.request_date,s.creation_date)),'APPROVED',trunc(nvl(s.approval_date,s.last_update_date)) )
                 ,b2.source_code_id
                 ,a.source_code
                 ,a.campaign_type
                 ,a.status_code
                 ,a.rollup_type
                 ,a.actual_exec_start_date
                 ,a.actual_exec_end_date
                 ,a.business_unit_id
                 ,a.city_id
                 ,d.area2_code
                 ,a.budget_amount_fc
        HAVING   sum(decode(s.status_code
                   ,'PENDING'
                   ,convert_currency(nvl(request_currency,'USD'),nvl(s.request_amount,0))
                   ,'APPROVED'
                   , convert_currency(nvl(request_currency,'USD'),nvl(s.request_amount,0))
                   )) > 0
        OR
                 sum(decode(s.status_code
                   ,'PENDING'
                   ,0
                   ,'APPROVED'
                   ,convert_currency(nvl(approved_in_currency,'USD'),nvl(s.approved_original_amount,0))
                   ))    > 0
	UNION ALL
        SELECT
                 s.budget_source_id   act_budget_used_by_id
                ,trunc(nvl(s.approval_date,s.last_update_date)) creation_date
                ,0 request_amount
                ,- sum(convert_currency(nvl(approved_in_currency,'USD'),nvl(s.approved_original_amount,0))) approved_amount
                ,b2.source_code_id      	  campaign_source_code_id
                ,a.source_code          	  campaign_source_code
                ,a.campaign_type        	  campaign_purpose
                ,a.status_code   		  campaign_status
                ,a.rollup_type          	  campaign_type
                ,a.actual_exec_start_date   start_date
                ,a.actual_exec_end_date     end_date
                ,a.business_unit_id     	  business_unit_id
                ,a.city_id              	  campaign_country_code
                ,d.area2_code           	  campaign_region_code
                ,a.budget_amount_fc     	  campaign_budget_amount
        FROM    ozf_act_budgets    	    S
                ,ams_campaigns_all_b     A
                ,ams_source_codes        B2
                ,jtf_loc_hierarchies_b   D
        WHERE   s.arc_act_budget_used_by         = 'FUND'
                AND    s.budget_source_type      = 'CAMP'
                --AND    s.transfer_type         = 'REQUEST'
                AND    s.budget_source_id 	 = a.campaign_id
                AND    a.city_id                 =  d.location_hierarchy_id
                AND    a.status_code             IN ('ACTIVE', 'CANCELLED', 'COMPLETED','CLOSED')
                AND    a.rollup_type           <> 'RCAM'
                AND    b2.source_code            =  a.source_code
                --AND    a.actual_exec_start_date  >= trunc(p_start_date)
                AND    trunc(a.actual_exec_start_date)  >= trunc(l_min_start_date)
                AND    a.actual_exec_start_date  <= trunc(p_end_date)
                --AND    s.approval_date           <= trunc(p_end_date)
                AND    s.approval_date between p_start_date and p_end_date+0.99999
                AND    exists (select distinct campaign_id
                               from ams_campaign_schedules_b x
                               where x.campaign_id = a.campaign_id)
        GROUP BY s.budget_source_id
                ,trunc(nvl(s.approval_date,s.last_update_date))
                 ,b2.source_code_id
                 ,a.source_code
                 ,a.campaign_type
                 ,a.status_code
                 ,a.rollup_type
                 ,a.actual_exec_start_date
                 ,a.actual_exec_end_date
                 ,a.business_unit_id
                 ,a.city_id
                 ,d.area2_code
                 ,a.budget_amount_fc
        HAVING   sum(decode(s.status_code
                   ,'PENDING'
                   ,0
                   ,'APPROVED'
                   ,convert_currency(nvl(approved_in_currency,'USD'),nvl(s.approved_original_amount,0))
                   ))    > 0
    )INNER;


 COMMIT;


   l_temp_msg := to_char( sysdate, 'dd/mm/yyyy:hh:mi:ss');
   ams_utility_pvt.write_conc_log('BIM_CAMPAIGN_FACTS:LOAD: THIRD SECOND INSERT ' || l_temp_msg);


/***************************************************************/
/* This insert deals with schdule budgets */

      l_temp_msg := to_char( sysdate, 'dd/mm/yyyy:hh:mi:ss');
      ams_utility_pvt.write_conc_log('BIM_CAMPAIGN_FACTS:LOAD: BEFORE FOURTH INSERT ' || l_temp_msg);

      INSERT /*+ append parallel(CDF,1) */
      INTO bim_r_camp_daily_facts CDF
      (
               campaign_daily_transaction_id
              ,creation_date
              ,last_update_date
              ,created_by
              ,last_updated_by
              ,last_update_login
              ,campaign_id
              ,schedule_id
              ,transaction_create_date
              ,schedule_source_code
              ,campaign_source_code
              ,schedule_activity_type
	      ,schedule_activity_id
              ,campaign_purpose
              ,campaign_type
              ,start_date
              ,end_date
              ,schedule_purpose
              ,business_unit_id
              ,org_id
	      ,campaign_status
              ,schedule_status
              ,campaign_country
              ,campaign_region
              ,schedule_region
              ,schedule_country
              ,campaign_budget_fc
              ,schedule_budget_fc
              ,load_date
	      ,year
	      ,qtr
              ,month
              ,leads_open
              ,leads_closed
              ,leads_open_amt
              ,leads_closed_amt
	      ,leads_new
	      ,leads_new_amt
	      ,leads_hot
	      ,leads_converted
	      ,metric1 --leads_dead
              ,opportunities
	      ,opportunity_amt
              ,orders_booked
              ,orders_booked_amt
              ,forecasted_revenue
              ,actual_revenue
              ,forecasted_cost
              ,actual_cost
              ,forecasted_responses
              ,positive_responses
              ,targeted_customers
              ,budget_requested
              ,budget_approved
      )
      SELECT  /*+ parallel(INNER,1) */
	      bim_r_camp_daily_facts_s.nextval
              ,sysdate
              ,sysdate
              ,-1
              ,-1
              ,-1
              ,inner.campaign_id campaign_id
              ,inner.schedule_id schedule_id
              ,inner.creation_date transaction_create_date
              ,inner.schedule_source_code schedule_source_code
              ,inner.campaign_source_code campaign_source_code
              ,inner.schedule_activity_type schedule_activity_type
	      ,inner.schedule_activity_id schedule_activity_id
              ,inner.campaign_purpose campaign_purpose
              ,inner.campaign_type campaign_type
              ,inner.start_date start_date
              ,inner.end_date end_date
              ,inner.schedule_purpose schedule_purpose
              ,inner.business_unit_id business_unit_id
              ,inner.org_id org_id
	      ,inner.campaign_status campaign_status
              ,inner.status_code schedule_status
              ,inner.campaign_country_code campaign_country
              ,inner.campaign_region_code campaign_region
              ,inner.schedule_region_code schedule_region
              ,inner.schedule_country_code schedule_country
              ,0 campaign_budget_fc
              ,inner.schedule_budget_amount schedule_budget_fc
              ,(decode(decode( to_char(inner.creation_date,'MM') , to_char(next_day(inner.creation_date,TO_NUMBER(to_char(to_date('07/09/2004', 'DD/MM/RRRR'), 'DD'))),'MM') ,'TRUE','FALSE' )
      	        ,'TRUE'
      	        ,decode(decode(Inner.creation_date , (next_day(inner.creation_date, TO_NUMBER(to_char(to_date('07/09/2004', 'DD/MM/RRRR'), 'DD'))) - 7) , 'TRUE' ,'FALSE')
       	        ,'TRUE'
      	        ,inner.creation_date
      	        ,'FALSE'
      	        ,next_day(inner.creation_date, TO_NUMBER(to_char(to_date('07/09/2004', 'DD/MM/RRRR'), 'DD'))))
      	        ,'FALSE'
      	        ,decode(decode(to_char(inner.creation_date,'MM'),to_char(next_day(inner.creation_date,TO_NUMBER(to_char(to_date('07/09/2004', 'DD/MM/RRRR'), 'DD'))),'MM'),'TRUE','FALSE')
      	        ,'FALSE'
      	        ,last_day(Inner.creation_date))))         weekend_date
	      ,bim_set_of_books.get_fiscal_year(inner.creation_date,0) year
              ,bim_set_of_books.get_fiscal_qtr(inner.creation_date,0)  qtr
              ,bim_set_of_books.get_fiscal_month(inner.creation_date,0) month
              ,0 leads_open
              ,0 leads_closed
              ,0 leads_open_amt
              ,0 leads_closed_amt
	      ,0 leads_new
	      ,0 leads_new_amt
	      ,0 leads_hot
	      ,0 leads_converted
	      ,0 leads_dead
              ,0 opportunities
	      ,0 opportunity_amt
              ,0 orders_booked
              ,0 orders_booked_amt
              ,0 forecasted_revenue
              ,0 actual_revenue
              ,0 forecasted_cost
              ,0 actual_cost
              ,0 forecasted_responses
              ,0 positive_responses
              ,0 targeted_customers
              ,inner.request_amount request_amount
	      ,inner.approved_amount approved_amount
FROM
      (
        SELECT
                s.act_budget_used_by_id   act_budget_used_by_id
                ,decode(s.status_code
		   ,'PENDING'
		   ,trunc(nvl(s.request_date,s.creation_date))
		   ,'APPROVED'
                   ,trunc(nvl(s.approval_date,s.last_update_date))
		   ) creation_date
                ,sum(decode(s.status_code
                   ,'PENDING'
                   ,convert_currency(nvl(request_currency,'USD'),nvl(s.request_amount,0))
                   ,'APPROVED'
                   , convert_currency(nvl(request_currency,'USD'),nvl(s.request_amount,0))
                   ))  request_amount
                ,sum(decode(s.status_code
                   ,'PENDING'
                   ,0
                   ,'APPROVED'
                   ,convert_currency(nvl(approved_in_currency,'USD'),nvl(s.approved_original_amount,0))
                   ))    approved_amount
              ,a.campaign_id      	  campaign_id
              ,b2.source_code_id      	  campaign_source_code_id
              ,a.source_code          	  campaign_source_code
              ,a.campaign_type        	  campaign_purpose
              ,a.status_code   		  campaign_status
              ,a.rollup_type          	  campaign_type
              ,e.schedule_id        	  schedule_id
              ,e.source_code        	  schedule_source_code
              ,b1.source_code_id          schedule_source_code_id
              ,e.activity_type_code 	  schedule_activity_type
	      ,decode(e.activity_type_code,'EVENTS',-9999, e.activity_id) schedule_activity_id
              ,d1.area2_code         	  schedule_region_code
              ,e.country_id         	  schedule_country_code
              ,e.org_id             	  org_id
              ,e.status_code        	  status_code
              ,e.start_date_time          start_date
              ,nvl(e.end_date_time, a.actual_exec_end_date) end_date
              ,e.objective_code     	  schedule_purpose
              ,a.business_unit_id     	  business_unit_id
              ,a.city_id              	  campaign_country_code
              ,e.budget_amount_fc     	  schedule_budget_amount
                  ,d2.area2_code campaign_region_code
        FROM    ozf_act_budgets    	    S
                ,ams_campaigns_all_b 	    A
                ,ams_source_codes           B1
                ,ams_source_codes           B2
                ,jtf_loc_hierarchies_b 	    D1
                ,jtf_loc_hierarchies_b 	    D2
                ,ams_campaign_schedules_b   E
        WHERE   s.arc_act_budget_used_by         = 'CSCH'
                AND    s.budget_source_type      = 'FUND'
                --AND    s.transfer_type         = 'REQUEST'
                AND    s.act_budget_used_by_id 	 = e.schedule_id
                AND    e.campaign_id             =  a.campaign_id
                AND    e.country_id              =  d1.location_hierarchy_id
                AND    a.city_id                 =  d2.location_hierarchy_id
                AND    a.status_code             IN ('ACTIVE', 'CANCELLED', 'COMPLETED','CLOSED')
                --AND    e.status_code           IN ('ACTIVE', 'CANCELLED', 'COMPLETED','CLOSED')
                AND    a.rollup_type           <> 'RCAM'
                AND    b1.source_code            =  e.source_code
                AND    b2.source_code            =  a.source_code
                --AND    a.actual_exec_start_date  >= p_start_date
                AND    trunc(a.actual_exec_start_date)  >= trunc(l_min_start_date)
                AND    a.actual_exec_start_date  <= p_end_date
                --AND    s.approval_date           <= p_end_date
                AND    decode(s.status_code,'PENDING',trunc(nvl(s.request_date,s.creation_date)),'APPROVED',trunc(nvl(s.approval_date,s.last_update_date)) ) between p_start_date and p_end_date+0.99999
        GROUP BY s.act_budget_used_by_id
                 ,decode(s.status_code,'PENDING',trunc(nvl(s.request_date,s.creation_date)),'APPROVED',trunc(nvl(s.approval_date,s.last_update_date)) )
                 ,a.campaign_id
                 ,b2.source_code_id
                 ,a.source_code
                 ,a.campaign_type
                 ,a.status_code
                 ,a.rollup_type
                 ,e.schedule_id
                 ,e.source_code
                 ,b1.source_code_id
                 ,e.activity_type_code
	         ,decode(e.activity_type_code,'EVENTS',-9999, e.activity_id)
                 ,d1.area2_code
                 ,e.country_id
                 ,e.org_id
                 ,e.status_code
                 ,e.start_date_time
                 ,nvl(e.end_date_time, a.actual_exec_end_date)
                 ,e.objective_code
                 ,a.business_unit_id
                 ,a.city_id
                 ,e.budget_amount_fc
		 ,d2.area2_code
        HAVING   sum(decode(s.status_code
                   ,'PENDING'
                   ,convert_currency(nvl(request_currency,'USD'),nvl(s.request_amount,0))
                   ,'APPROVED'
                   ,convert_currency(nvl(request_currency,'USD'),nvl(s.request_amount,0))
                   )) > 0
        OR
                 sum(decode(s.status_code
                   ,'PENDING'
                   ,0
                   ,'APPROVED'
                   ,convert_currency(nvl(approved_in_currency,'USD'),nvl(s.approved_original_amount,0))
                   ))    > 0
	UNION ALL

        SELECT
                s.budget_source_id   act_budget_used_by_id
                ,trunc(nvl(s.approval_date,s.last_update_date)) creation_date
                ,0  request_amount
		,- sum(convert_currency(nvl(approved_in_currency,'USD'),nvl(s.approved_original_amount,0))) approved_amount
              ,a.campaign_id      	  campaign_id
              ,b2.source_code_id      	  campaign_source_code_id
              ,a.source_code          	  campaign_source_code
              ,a.campaign_type        	  campaign_purpose
              ,a.status_code   		  campaign_status
              ,a.rollup_type          	  campaign_type
              ,e.schedule_id        	  schedule_id
              ,e.source_code        	  schedule_source_code
              ,b1.source_code_id          schedule_source_code_id
              ,e.activity_type_code 	  schedule_activity_type
	      ,decode(e.activity_type_code,'EVENTS',-9999, e.activity_id) schedule_activity_id
              ,d1.area2_code         	  schedule_region_code
              ,e.country_id         	  schedule_country_code
              ,e.org_id             	  org_id
              ,e.status_code        	  status_code
              ,e.start_date_time          start_date
              ,nvl(e.end_date_time, a.actual_exec_end_date)	        end_date
              ,e.objective_code     	  schedule_purpose
              ,a.business_unit_id     	  business_unit_id
              ,a.city_id              	  campaign_country_code
              ,e.budget_amount_fc     	  schedule_budget_amount
                   ,d2.area2_code              campaign_region_code
        FROM    ozf_act_budgets    	    S
                ,ams_campaigns_all_b 	    A
                ,ams_source_codes           B1
                ,ams_source_codes           B2
                ,jtf_loc_hierarchies_b 	    D1
                ,jtf_loc_hierarchies_b 	    D2
                ,ams_campaign_schedules_b   E
        WHERE   s.arc_act_budget_used_by         = 'FUND'
                AND    s.budget_source_type      = 'CSCH'
                --AND    s.transfer_type         = 'REQUEST'
                AND    s.budget_source_id 	 = e.schedule_id
                AND    e.campaign_id             =  a.campaign_id
                AND    e.country_id              =  d1.location_hierarchy_id
                AND    a.city_id                 =  d2.location_hierarchy_id
                AND    a.status_code             IN ('ACTIVE', 'CANCELLED', 'COMPLETED','CLOSED')
                --AND    e.status_code           IN ('ACTIVE', 'CANCELLED', 'COMPLETED','CLOSED')
                AND    a.rollup_type           <> 'RCAM'
                AND    b1.source_code            =  e.source_code
                AND    b2.source_code            =  a.source_code
                --AND    a.actual_exec_start_date  >= trunc(p_start_date)
                AND    trunc(a.actual_exec_start_date)  >= trunc(l_min_start_date)
                AND    a.actual_exec_start_date  <= trunc(p_end_date)
                --AND    s.approval_date           <= trunc(p_end_date)
                AND    s.approval_date between p_start_date and p_end_date+0.99999
        GROUP BY s.budget_source_id
                ,trunc(nvl(s.approval_date,s.last_update_date))
                 ,a.campaign_id
                 ,b2.source_code_id
                 ,a.source_code
                 ,a.campaign_type
                 ,a.status_code
                 ,a.rollup_type
                 ,e.schedule_id
                 ,e.source_code
                 ,b1.source_code_id
                 ,e.activity_type_code
	         ,decode(e.activity_type_code,'EVENTS',-9999, e.activity_id)
                 ,d1.area2_code
                 ,e.country_id
                 ,e.org_id
                 ,e.status_code
                 ,e.start_date_time
                 ,nvl(e.end_date_time, a.actual_exec_end_date)
                 ,e.objective_code
                 ,a.business_unit_id
                 ,a.city_id
                 ,e.budget_amount_fc
		 ,d2.area2_code
        HAVING   sum(decode(s.status_code
                   ,'PENDING'
                   ,0
                   ,'APPROVED'
                   ,convert_currency(nvl(approved_in_currency,'USD'),nvl(s.approved_original_amount,0))
                   ))    > 0

    )INNER;


 COMMIT;


   l_temp_msg := to_char( sysdate, 'dd/mm/yyyy:hh:mi:ss');
   ams_utility_pvt.write_conc_log('BIM_CAMPAIGN_FACTS:LOAD: AFTER FOURTH INSERT ' || l_temp_msg);


/***************************************************************/


   l_temp_msg := to_char( sysdate, 'dd/mm/yyyy:hh:mi:ss');
   ams_utility_pvt.write_conc_log('BIM_CAMPAIGN_FACTS:LOAD: BEFORE ANALYZING DAILY FACTS ' || l_temp_msg);

   -- Analyze the daily facts table
   DBMS_STATS.gather_table_stats('BIM','BIM_R_CAMP_DAILY_FACTS', estimate_percent => 5,
                                  degree => 8, granularity => 'GLOBAL', cascade =>TRUE);

   l_temp_msg := to_char( sysdate, 'dd/mm/yyyy:hh:mi:ss');
   ams_utility_pvt.write_conc_log('BIM_CAMPAIGN_FACTS:LOAD: AFTER ANALYZING DAILY FACTS ' || l_temp_msg);

/***************************************************************/

   /*  INSERT INTO WEEKLY SUMMARY TABLE */

   /* Here we are inserting the summarized data into the weekly facts by taking it from the daily facts.
     For every week we have a record since we group by that weekend date which is nothing but the Load date. */

   l_temp_msg := to_char( sysdate, 'dd/mm/yyyy:hh:mi:ss');
   ams_utility_pvt.write_conc_log('BIM_CAMPAIGN_FACTS:LOAD: BEFORE WEEKLY TABLE INSERT ' || l_temp_msg);

   EXECUTE IMMEDIATE 'TRUNCATE TABLE '||l_schema||'.bim_r_camp_weekly_facts';

   /*BEGIN BLOCK FOR THE WEEKLY INSERT */

      l_table_name :=    'bim_r_camp_weekly_facts';
      l_seq_name      := 'bim_r_camp_weekly_facts_s';

      INSERT /*+ append parallel(CWF,1) */
      INTO bim_r_camp_weekly_facts CWF
        (
             campaign_weekly_transaction_id
            ,creation_date
            ,last_update_date
            ,created_by
            ,last_updated_by
            ,campaign_id
            ,schedule_id
            ,campaign_source_code
            ,schedule_source_code
            ,campaign_type
            ,start_date
            ,end_date
            ,campaign_region
            ,schedule_region
            ,campaign_country
            ,schedule_country
            ,business_unit_id
            ,schedule_activity_type
	    ,schedule_activity_id
            ,campaign_purpose
            ,campaign_status
	    ,schedule_status
            ,transaction_create_date
            ,org_id
            ,load_date
	    ,year
	    ,qtr
	    ,month
            ,leads_open
            ,leads_closed
            ,leads_open_amt
            ,leads_closed_amt
	    ,leads_new
	    ,leads_new_amt
	    ,leads_hot
	    ,leads_converted
	    ,metric1 -- leads_dead
            ,opportunities
	    ,opportunity_amt
	    ,orders_booked
	    ,orders_booked_amt
            ,forecasted_revenue
            ,actual_revenue
            ,forecasted_cost
            ,actual_cost
            ,forecasted_responses
            ,positive_responses
            ,targeted_customers
            ,budget_requested
            ,budget_approved
        )
      SELECT /*+ parallel(INNER,8) */
		bim_r_camp_weekly_facts_s.nextval
            ,sysdate
            ,sysdate
            ,l_user_id
            ,l_user_id
            ,campaign_id
            ,schedule_id
            ,campaign_source_code
            ,schedule_source_code
            ,campaign_type
            ,start_date
            ,end_date
            ,campaign_region
            ,schedule_region
            ,campaign_country
            ,schedule_country
            ,business_unit_id
            ,schedule_activity_type
	    ,schedule_activity_id
            ,campaign_purpose
            ,campaign_status
	    ,schedule_status
            ,transaction_create_date
            ,org_id
            ,load_date
	    ,year
	    ,qtr
	    ,month
            ,leads_open
            ,leads_closed
            ,leads_open_amt
            ,leads_closed_amt
	    ,leads_new
	    ,leads_new_amt
	    ,leads_hot
	    ,leads_converted
	    ,leads_dead
            ,opportunities
	    ,opportunity_amt
	    ,orders_booked
	    ,orders_booked_amt
            ,forecasted_revenue
            ,actual_revenue
            ,forecasted_cost
            ,actual_cost
            ,forecasted_responses
            ,positive_responses
            ,targeted_customers
            ,budget_requested
            ,budget_approved
      FROM
      (
         SELECT
             campaign_id                        campaign_id
            ,schedule_id                        schedule_id
            ,campaign_source_code               campaign_source_code
            ,schedule_source_code               schedule_source_code
            ,campaign_type                      campaign_type
            ,start_date                         start_date
            ,end_date                           end_date
            ,campaign_region                    campaign_region
            ,schedule_region                    schedule_region
            ,campaign_country                   campaign_country
            ,schedule_country                   schedule_country
            ,nvl(business_unit_id,0)            business_unit_id
            ,schedule_activity_type             schedule_activity_type
	    ,schedule_activity_id		schedule_activity_id
            ,campaign_purpose                   campaign_purpose
            ,campaign_status                    campaign_status
	    ,schedule_status			schedule_status
            ,load_date                          transaction_create_date
            ,org_id                             org_id
            ,load_date                          load_date
	    ,year				year
	    ,qtr				qtr
	    ,month				month
            ,sum(leads_open)   			leads_open
            ,sum(leads_closed) 			leads_closed
            ,sum(leads_open_amt)    		leads_open_amt
            ,sum(leads_closed_amt)    		leads_closed_amt
	    ,sum(leads_new)			leads_new
	    ,sum(leads_new_amt)			leads_new_amt
	    ,sum(leads_hot)			leads_hot
	    ,sum(leads_converted)		leads_converted
	    ,sum(metric1)			leads_dead
            ,sum(opportunities)                 opportunities
	    ,sum(opportunity_amt)		opportunity_amt
	    ,sum(orders_booked)			orders_booked
	    ,sum(orders_booked_amt)		orders_booked_amt
            ,sum(forecasted_revenue) 		forecasted_revenue
            ,sum(actual_revenue)     		actual_revenue
            ,sum(forecasted_cost)               forecasted_cost
            ,sum(actual_cost)                   actual_cost
            ,sum(forecasted_responses)  	forecasted_responses
            ,sum(positive_responses)     	positive_responses
            ,sum(targeted_customers)		targeted_customers
            ,sum(budget_requested)              budget_requested
            ,sum(budget_approved)               budget_approved
         FROM    bim_r_camp_daily_facts
--	 WHERE   transaction_create_date between trunc(p_start_date) and trunc(p_end_date) + 0.99999
 	 GROUP BY   campaign_id
            ,schedule_id
            ,load_date
	    ,year
	    ,qtr
	    ,month
            ,campaign_source_code
            ,schedule_source_code
            ,campaign_type
            ,start_date
            ,end_date
            ,campaign_region
            ,schedule_region
            ,campaign_country
            ,schedule_country
            ,nvl(business_unit_id,0)
            ,schedule_activity_type
	    ,schedule_activity_id
            ,campaign_purpose
            ,campaign_status
	    ,schedule_status
            ,org_id
         )INNER;

        LOG_HISTORY('CAMPAIGN', p_start_date, p_end_date);


    COMMIT;


   l_temp_msg := to_char( sysdate, 'dd/mm/yyyy:hh:mi:ss');
   ams_utility_pvt.write_conc_log('BIM_CAMPAIGN_FACTS:LOAD: AFTER WEEKLY TABLE INSERT ' || l_temp_msg);

   l_temp_msg := to_char( sysdate, 'dd/mm/yyyy:hh:mi:ss');
   ams_utility_pvt.write_conc_log('BIM_CAMPAIGN_FACTS:LOAD: BEFORE ANALYZING WEEKLY FACTS ' || l_temp_msg);

   -- Analyze the daily facts table
   DBMS_STATS.gather_table_stats('BIM','BIM_R_CAMP_WEEKLY_FACTS', estimate_percent => 5,
                                  degree => 8, granularity => 'GLOBAL', cascade =>TRUE);

   l_temp_msg := to_char( sysdate, 'dd/mm/yyyy:hh:mi:ss');
   ams_utility_pvt.write_conc_log('BIM_CAMPAIGN_FACTS:LOAD: AFTER ANALYZING WEEKLY FACTS ' || l_temp_msg);


       /* Piece of Code for Recreating the index on the same tablespace with the same storage parameters */

   l_temp_msg := to_char( sysdate, 'dd/mm/yyyy:hh:mi:ss');
   ams_utility_pvt.write_conc_log('BIM_CAMPAIGN_FACTS:LOAD: BEFORE CREATE INDEX ' || l_temp_msg);

 	i := i - 1;
	WHILE(i>=1) LOOP
	EXECUTE IMMEDIATE 'CREATE INDEX '
	    || l_owner(i)
	    || '.'
	    || l_index_name(i)
	    ||' ON '
	    || l_owner(i)
	    ||'.'
	    || l_index_table_name(i)
	    || ' ('
	    || l_ind_column_name(i)
	    || ' )'
            || ' tablespace '  || l_index_tablespace
            || ' pctfree     ' || l_pct_free(i)
            || ' initrans '    || l_ini_trans(i)
            || ' maxtrans  '   || l_max_trans(i)
            || ' storage ( '
            || ' initial '     || l_initial_extent(i)
            || ' next '        || l_next_extent(i)
            || ' minextents '  || l_min_extents(i)
            || ' maxextents '  || l_max_extents(i)
            || ' pctincrease ' || l_pct_increase(i)
            || ')' ;

            i := i - 1;
	 END LOOP;

   l_temp_msg := to_char( sysdate, 'dd/mm/yyyy:hh:mi:ss');
   ams_utility_pvt.write_conc_log('BIM_CAMPAIGN_FACTS:LOAD: AFTER CREATE INDEX ' || l_temp_msg);

       /* End of Code for Recreating the index on the same tablespace with the same storage parameters */


   EXECUTE IMMEDIATE 'ALTER SEQUENCE '||l_schema||'.bim_r_camp_weekly_facts_s CACHE 20';



EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_msg_PUB.Count_And_Get (
          --  p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

    ams_utility_pvt.write_conc_log('BIM_CAMPAIGN_FACTS:LOAD:IN EXPECTED EXCEPTION '||sqlerrm(sqlcode));

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     -- Standard call to get message count and if count=1, get the message
     FND_msg_PUB.Count_And_Get (
            --p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

    ams_utility_pvt.write_conc_log('BIM_CAMPAIGN_FACTS:LOAD:IN UNEXPECTED EXCEPTION '||sqlerrm(sqlcode));

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

    ams_utility_pvt.write_conc_log('BIM_CAMPAIGN_FACTS:LOAD:IN OTHERS EXCEPTION '||sqlerrm(sqlcode));


END CAMPAIGN_SUBSEQUENT_LOAD;


--------------------------------------------------------------------------------------------------
-- this procedure will excute when data is loaded DAILY , and run the program incrementally.

--                      PROCEDURE  CAMPAIGN_DAILY_LOAD

--------------------------------------------------------------------------------------------------


PROCEDURE CAMPAIGN_DAILY_LOAD
    ( p_api_version_number   IN  NUMBER
     ,p_init_msg_list        IN  VARCHAR2     := FND_API.G_FALSE
     ,x_msg_count            OUT NOCOPY NUMBER
     ,x_msg_data             OUT NOCOPY VARCHAR2
     ,x_return_status        OUT NOCOPY VARCHAR2
     ,p_date		     IN  DATE
     ) IS
   l_weekend_date  	    DATE;
   l_user_id                NUMBER := FND_GLOBAL.USER_ID();
   l_seq                    NUMBER;
   l_seqw                   NUMBER;
   l_api_version_number     CONSTANT NUMBER       := 1.0;
   l_api_name               CONSTANT VARCHAR2(30) := 'CAMPAIGN_DAILY_LOAD';
   l_table_name             VARCHAR2(100);
   l_seq_name               VARCHAR2(100);
   l_grace_period                NUMBER;

   l_min_date               DATE;


BEGIN
      l_min_date := sysdate;

END CAMPAIGN_DAILY_LOAD;

END BIM_CAMPAIGN_FACTS;

/
