--------------------------------------------------------
--  DDL for Package Body BIM_EVENT_FACTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIM_EVENT_FACTS" BIM_EVENT_FACTS	AS
/* $Header: bimevtfb.pls 120.0 2005/05/31 12:55:18 appldev noship $ */

G_PKG_NAME  CONSTANT  VARCHAR2(20) :='BIM_EVENT_FACTS';
G_FILE_NAME CONSTANT  VARCHAR2(20) :='bimevtfb.pls';

---------------------------------------------------------------------
-- FUNCTION
--    Convert_Currency
-- NOTE
-- PARAMETER
--   p_from_currency      IN  VARCHAR2,
--   p_to_currency        IN  VARCHAR2,
--   p_from_amount        IN  NUMBER,
-- RETURN   NUMBER
---------------------------------------------------------------------
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

-----------------------------------------------------------------------
-- PROCEDURE
--    POPULATE
--
-- Note
--    Main procedure called outside of the pacakge, it calls different
--    procedures depending on the parameters passed FROM concurrent
--    program.
-----------------------------------------------------------------------
PROCEDURE POPULATE
   (
    p_api_version_number  IN   NUMBER	 ,
    p_init_msg_list	      IN   VARCHAR2	:= FND_API.G_FALSE,
    p_validation_level	  IN   NUMBER	:= FND_API.G_VALID_LEVEL_FULL,
    p_commit		      IN   VARCHAR2	:= FND_API.G_FALSE,
    x_msg_count		      OUT  NOCOPY NUMBER	,
    x_msg_data		      OUT  NOCOPY VARCHAR2	,
    x_return_status	      OUT  NOCOPY VARCHAR2	,
    p_object		      IN   VARCHAR2	,
    p_start_date	      IN   DATE		,
    p_end_date		      IN   DATE		,
    p_para_num            IN   NUMBER
    ) IS
    l_profile		      NUMBER;
    v_error_code	      NUMBER;
    v_error_text	      VARCHAR2(1500);
    l_max_end_date	      DATE;
    l_start_date	      DATE;
    l_end_date		      DATE;
    l_user_id		      NUMBER := FND_GLOBAL.USER_ID();
    l_api_version_number  CONSTANT NUMBER	    := 1.0;
    l_api_name		      CONSTANT VARCHAR2(30) := 'populate';
    l_date                DATE;
    l_sdate               DATE :=to_date('01/01/1950 12:34:56', 'DD/MM/YYYY HH:MI:SS') ;
    l_err_code            NUMBER;
	l_period_error	      VARCHAR2(5000);
    l_currency_error	  VARCHAR2(5000);

    CURSOR chk_history_data IS
    SELECT  MAX(end_date)
    FROM    bim_rep_history
    WHERE   object = 'EVENT';

BEGIN

  -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
					p_api_version_number,
					l_api_name,
					G_PKG_NAME)
   THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list IF p_init_msg_list IS set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list )
   THEN
   FND_MSG_PUB.initialize;
   END IF;

   -- Debug Message
   AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');

   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   /* Find if the data will be loaded for the first time or not.*/

   OPEN chk_history_data;
   FETCH chk_history_data INTO l_max_end_date;
   CLOSE chk_history_data;

   IF p_end_date = trunc(sysdate) then
      l_end_date := p_end_date -1;
   else
      l_end_date := p_end_date;
   end if;

	--check the validation
      --l_err_code := BIM_VALIDITY_CHECK.validate_events(p_start_date,
                                                    --  l_end_date, l_period_error, l_currency_error);
l_err_code :=0;
  IF (l_err_code = 0) THEN  -- Validation Succesful
	IF (l_max_end_date IS NOT NULL AND p_start_date IS NOT NULL)
	THEN
          	ams_utility_pvt.write_conc_log('First Time Load is already run. Subsequent Load should be run.');
          	ams_utility_pvt.write_conc_log('Concurrent Program Exits Now');
		RAISE FND_API.G_EXC_ERROR;
	END IF;


       IF p_start_date IS NOT NULL THEN

	   	  IF (p_start_date > p_end_date) THEN
                    ams_utility_pvt.write_conc_log('The start date cannot be greater than current end date');
                    ams_utility_pvt.write_conc_log('Concurrent Program Exits Now ');
	            RAISE FND_API.G_EXC_ERROR;
	   	  END IF;

               		EVENT_SUBSEQUENT_LOAD(p_start_datel => p_start_date
                                    ,p_end_datel =>  l_end_date
			       	    ,p_api_version_number => 1
	     			    ,x_msg_count=>x_msg_count
	     			    ,x_msg_data=>x_msg_data
	     			    ,x_return_status=>x_return_status
                                    );

                  IF    x_return_status = FND_API.g_ret_sts_error
                  THEN
                     RAISE FND_API.g_exc_error;
                  ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
                     RAISE FND_API.g_exc_unexpected_error;
                  END IF;
	  ELSE

	     	IF l_max_end_date IS NOT NULL THEN

	   	       IF (p_end_date <= l_max_end_date) THEN
                  ams_utility_pvt.write_conc_log('The current end date cannot be less than the last end date ');
                  ams_utility_pvt.write_conc_log('Concurrent Program Exits Now ');
        	      RAISE FND_API.g_exc_error;
	   	       END IF;

                	EVENT_SUBSEQUENT_LOAD(p_start_datel => l_max_end_date + 1
                                    ,p_end_datel =>  l_end_date
				    ,p_api_version_number => 2
	     			    ,x_msg_count=>x_msg_count
	     			    ,x_msg_data=>x_msg_data
	     			    ,x_return_status=>x_return_status
                                    );
	        END IF;

                  IF    x_return_status = FND_API.g_ret_sts_error
                  THEN
                     RAISE FND_API.g_exc_error;
                  ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
                     RAISE FND_API.g_exc_unexpected_error;
                  END IF;
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
   --add this
   commit;

   -- Standard call to get message count and IF count IS 1, get message info.
   FND_msg_PUB.Count_And_Get
     (p_count	       =>   x_msg_count,
      p_data	       =>   x_msg_data
      );
EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and IF count=1, get the message
     FND_msg_PUB.Count_And_Get (
	  --  p_encoded => FND_API.G_FALSE,
	    p_count   => x_msg_count,
	    p_data    => x_msg_data
     );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and IF count=1, get the message
     FND_msg_PUB.Count_And_Get (
	    --p_encoded => FND_API.G_FALSE,
	    p_count => x_msg_count,
	    p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_msg_PUB.Check_msg_Level ( FND_msg_PUB.G_msg_LVL_UNEXP_ERROR)
     THEN
	FND_msg_PUB.Add_Exc_msg( G_PKG_NAME,l_api_name);
     END IF;
     -- Standard call to get message count and IF count=1, get the message
     FND_msg_PUB.Count_And_Get (
	   -- p_encoded => FND_API.G_FALSE,
	    p_count => x_msg_count,
	    p_data  => x_msg_data
     );

END POPULATE;
 -----------------------------------------------------------------------
   -- PROCEDURE
   --	 LOG_HISTORY
   --
   --Note:  This procedure will insert a HISTORY record into bim_rep_history
   --table whenever first and subsequent load has run successfully
 -----------------------------------------------------------------------
PROCEDURE LOG_HISTORY(
    p_object		      VARCHAR2,
	p_start_date        DATE,
	p_end_date          DATE,
    x_msg_count		    OUT	 NOCOPY NUMBER	      ,
    x_msg_data		    OUT	 NOCOPY VARCHAR2     ,
    x_return_status	    OUT NOCOPY VARCHAR2
 )
IS
    l_user_id		 NUMBER := FND_GLOBAL.USER_ID();
    l_table_name	 VARCHAR2(100):='BIM_REP_HISTORY';
BEGIN
    INSERT INTO
    bim_rep_history
       (creation_date,
	last_update_date,
	created_by,
	last_updated_by,
	object,
	object_last_updated_date,
	start_date,
	end_date)
    VALUES
       (sysdate,
	sysdate,
	l_user_id,
	l_user_id,
	p_object,
	sysdate,
	p_start_date,
	p_end_date);

END LOG_HISTORY;


 -----------------------------------------------------------------------
   -- PROCEDURE
   --	 LOG_HISTORY
   --
   --Note:  This procedure will excute when data is loaded for the first time, and run the program incrementally.
 -----------------------------------------------------------------------

PROCEDURE EVENT_FIRST_LOAD
(p_start_datel		        DATE,
 p_end_dateL		        DATE,
 p_api_version_number       NUMBER,
 p_para_num                 NUMBER,
 x_msg_count		        OUT NOCOPY  NUMBER	   ,
 x_msg_data		            OUT  NOCOPY VARCHAR2	   ,
 x_return_status	        OUT NOCOPY VARCHAR2
)
IS
l_user_id   NUMBER := FND_GLOBAL.USER_ID();
l_success   VARCHAR2(1) := 'F';
l_api_version_number	  CONSTANT NUMBER	:= 1.0;
l_api_name		  CONSTANT VARCHAR2(30) := 'EVENT_FIRST_LOAD';
l_profile NUMBER;
l_table_name VARCHAR2(100);
l_temp_msg		          VARCHAR2(100);
l_def_tablespace        VARCHAR2(100);
l_index_tablespace      VARCHAR2(100);
l_oracle_username       VARCHAR2(100);
l_actual_cost                  NUMBER;
l_forecasted_cost              NUMBER;
l_actual_revenue               NUMBER;
l_forecasted_revenue           NUMBER;
l_actual_costh                  NUMBER;
l_forecasted_costh             NUMBER;
l_actual_revenueh               NUMBER;
l_forecasted_revenueh           NUMBER;

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

   l_status      VARCHAR2(30);
   l_industry    VARCHAR2(30);
   l_orcl_schema VARCHAR2(30);
   l_bol         BOOLEAN := fnd_installation.get_app_info ('BIM',l_status,l_industry,l_orcl_schema);

   CURSOR    get_ts_name IS
   SELECT    i.tablespace, i.index_tablespace, u.oracle_username
   FROM      fnd_product_installations I, fnd_application A, fnd_oracle_userid U
   WHERE     a.application_short_name = 'BIM'
   AND 	     a.application_id = i.application_id
   AND 	     u.oracle_id = i.oracle_id;

   CURSOR    get_index_params (l_schema VARCHAR2) IS
   SELECT    a.owner,a.index_name,b.table_name,b.column_name, a.pct_free, a.ini_trans,a.max_trans
	     ,a.initial_extent,a.next_extent,a.min_extents,a.max_extents, a.pct_increase
   FROM      all_indexes A, all_ind_columns B
   WHERE     a.index_name = b.index_name
   AND       a.owner = l_schema
   AND       a.owner = b.index_owner
   AND 	     a.index_name like 'BIM_R_EVEN%_FACTS%';

    CURSOR get_event (c_start_date date) is
    SELECT distinct a.event_header_id event_header_id,
	       a.event_offer_id event_offer_id,
	       a.parent_id parent_id,
	       a.source_code source_code,
               b.event_type_code event_type,
               b.source_code hdr_source_code,
	       a.event_start_date event_start_date,
	       a.event_end_date event_end_date,
	       a.business_unit_id business_unit_id,
	       a.org_id org_id,
               a.country_code country_code,
	       a.event_type_code event_type_code,
	       a.system_status_code system_status_code,
	       a.event_venue_id event_venue_id,
	       a.currency_code_fc currency_code_fc,
	       a.fund_amount_fc fund_amount_fc,
	       e.source_code_id offer_source_code_id
     FROM      ams_event_offers_all_b A,
               ams_event_headers_all_b B,
	       ams_source_codes E
     WHERE     e.source_code = a.source_code
     AND       a.event_header_id = b.event_header_id
     AND       a.system_status_code in ('ACTIVE', 'CANCELLED','COMPLETED','CLOSED')
     AND       B.active_from_date > c_start_date;

    CURSOR get_one_off_events(c_start_date date) is
    SELECT distinct a.event_header_id event_header_id,
	       a.event_offer_id event_offer_id,
	       a.parent_id parent_id,
	       a.source_code source_code,
               a.event_type_code event_type,
               NULL hdr_source_code,
	       a.event_start_date event_start_date,
	       a.event_end_date event_end_date,
	       a.business_unit_id business_unit_id,
	       a.org_id org_id,
               a.country_code country_code,
	       a.event_type_code event_type_code,
	       a.system_status_code system_status_code,
	       a.event_venue_id event_venue_id,
	       a.currency_code_fc currency_code_fc,
	       a.fund_amount_fc fund_amount_fc,
	       e.source_code_id offer_source_code_id
     FROM      ams_event_offers_all_b A,
	       ams_source_codes E
     WHERE     e.source_code = a.source_code
     AND       a.event_standalone_flag = 'Y'
     AND       (a.parent_type is NULL  or a.parent_type = 'RCAM')
     AND       a.system_status_code in ('ACTIVE', 'CANCELLED','COMPLETED','CLOSED')
     AND       a.event_start_date > c_start_date;

      l_event_offer number;
      l_min_date    date;
l_schema                      VARCHAR2(30);
l_status1                      VARCHAR2(5);
l_industry1                    VARCHAR2(5);
l_return			BOOLEAN;
BEGIN
l_return  := fnd_installation.get_app_info('BIM', l_status1, l_industry1, l_schema);
          --dbms_output.put_line('in first insert ');

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
					   l_api_version_number,
					   l_api_name,
					   G_PKG_NAME)
      THEN
	  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
      -- Debug Message
      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      ams_utility_pvt.write_conc_log('EVENT:FIRST_LOAD: Running the First Load '||sqlerrm(sqlcode));
      l_profile := FND_PROFILE.VALUE('AMS Budget Adjustment Grace Period in Days')+0; --for grace period
      if l_profile is null then
       l_profile :=0;
      end if;

      l_table_name :='bim_r_even_daily_facts';

          --dbms_output.put_line(' l_profile'||l_profile);
          --dbms_output.put_line(' start_time'||p_start_datel);
          --dbms_output.put_line(' end time'||p_end_datel);

      /*Get the tablespace name for the purpose of creating the index on that tablespace. */


      OPEN  get_ts_name;
      FETCH get_ts_name INTO	l_def_tablespace, l_index_tablespace, l_oracle_username;
      CLOSE get_ts_name;

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

          --dbms_output.put_line('Dropping :'||l_owner(i) || '.'|| l_index_name(i));

      EXECUTE IMMEDIATE 'DROP INDEX  '|| l_owner(i) || '.'|| l_index_name(i) ;
      i := i + 1;
      END LOOP;

 BEGIN

      EXECUTE IMMEDIATE 'ALTER TABLE '||l_schema||'.bim_r_even_daily_facts nologging';
      EXECUTE IMMEDIATE 'ALTER TABLE '||l_schema||'.bim_r_even_weekly_facts nologging';

      EXECUTE IMMEDIATE 'ALTER SEQUENCE '||l_schema||'.bim_r_even_daily_facts_s CACHE 1000';

/*This insert statement is getting transactions book of order, leads happen and event header level between p_start_date and p_end_date */
   ams_utility_pvt.write_conc_log(p_start_datel || ' '|| p_end_datel);

   l_temp_msg := to_char( sysdate, 'dd/mm/yyyy:hh:mi:ss');
   ams_utility_pvt.write_conc_log('EVENT:FIRST_LOAD: BEFORE FIRST INSERT BEGIN.' || l_temp_msg);
   INSERT  /*+ append parallel(EDF,1) */ INTO
          bim_r_even_daily_facts EDF(
	      event_daily_transaction_id
	     ,creation_date
	     ,last_update_date
	     ,created_by
	     ,last_updated_by
	     ,last_update_login
	     ,event_header_id
	     ,event_offer_iD
	     ,parent_id
	     ,source_code
	     ,start_date
	     ,end_date
	     ,country
	     ,business_unit_id
	     ,org_id
	     ,event_type
	     ,event_offer_type
	     ,status
	     ,event_venue_id
	     ,registrations
	     ,cancellations
	     ,leads_open
             ,leads_closed
             ,leads_open_amt
             ,leads_closed_amt
	     ,leads_new
	     ,leads_new_amt
	     ,leads_converted
	     ,leads_hot
         ,metric1  --leads_dead
	     ,opportunities
         ,opportunity_amt
	     ,attendance
	     ,forecasted_cost
	     ,actual_cost
	     ,forecasted_revenue
	     ,actual_revenue
	     ,customer
	     ,currency_code
	     ,transaction_create_date
         ,hdr_source_code
         ,order_amt
	     ,budget_requested
	     ,budget_approved
	     ,load_date
	     ,delete_flag
         ,month
         ,qtr
         ,year
		 ,booked_orders
		 ,booked_orders_amt
	     )
 SELECT
     /*+ parallel(INNER, 4) */
       bim_r_even_daily_facts_s.nextval,
       sysdate,
       sysdate,
       l_user_id,
       l_user_id,
       l_user_id,
       inner.header_id,
       0, --inner.offer_id,
       0, --inner.parent_id,
       inner.source_code,
       inner.start_date,
       inner.end_date,
       inner.country_code,
       inner.business_unit_id,
       inner.org_id,
       inner.event_type,
       inner.event_offer_type,
       inner.status,
       inner.venue_id,
       0,--(inner.registered - inner.cancelled) registered,
       0,--inner.cancelled,
       inner.leads_open,
       inner.leads_closed,
       inner.leads_open_amt,
       inner.leads_closed_amt,
       inner.leads_new,
       inner.leads_new_amt,
       inner.leads_converted,
       inner.leads_hot,
       inner.leads_dead,
       inner.nooppor,
       inner.opportunity_amt,
       0,--inner.attended,
       0,--forecast_cost
       0,--actual_cost
       0,--forecast_revenue
	   0,--actual_revenue
       0,--inner.customer,
       inner.currency_code,
       inner.transaction_create_date,
       inner.hdr_source_code,
       0,--inner.order_amt,
       0,--inner.budget_requested,
       0,--inner.budget_approved,
       trunc(inner.weekend_date),
       'N',
       BIM_SET_OF_BOOKS.GET_FISCAL_MONTH(inner.transaction_create_date, 204),
       BIM_SET_OF_BOOKS.GET_FISCAL_QTR(inner.transaction_create_date, 204),
       BIM_SET_OF_BOOKS.GET_FISCAL_YEAR(inner.transaction_create_date, 204),
	   inner.booked_orders,
	   inner.booked_orders_amt
 from(SELECT /*+ full(BUDGET1.A) */
       ad.event_header_id header_id,
	   ad.event_offer_id  event_offer_id,
       ad.tr_date transaction_create_date,
       trunc((decode(decode( to_char(ad.tr_date,'MM') ,
	   to_char(next_day(ad.tr_date,TO_NUMBER(to_char(to_date('07/09/2004', 'DD/MM/RRRR'), 'DD'))),'MM') ,'TRUE','FALSE' )
	   ,'TRUE'
	   ,decode(decode( ad.tr_date , (next_day(ad.tr_date, TO_NUMBER(to_char(to_date('07/09/2004', 'DD/MM/RRRR'), 'DD'))) - 7)
	   , 'TRUE' ,'FALSE')
	   ,'TRUE'
	   ,ad.tr_date
	   ,'FALSE'
	   ,next_day(ad.tr_date, TO_NUMBER(to_char(to_date('07/09/2004', 'DD/MM/RRRR'), 'DD'))))
	   ,'FALSE'
	   ,decode(decode(to_char(ad.tr_date,'MM'),to_char(next_day(ad.tr_date,TO_NUMBER(to_char(to_date('07/09/2004', 'DD/MM/RRRR'), 'DD'))),'MM'),'TRUE','FALSE')
	   ,'FALSE'
	   ,last_day(ad.tr_date))))) weekend_date, --weekend date
       ad.parent_id parent_id,
       ad.source_code source_code,
       ad.event_start_date start_date,
       ad.event_end_date end_date,
       ad.country_code country_code,
       ad.business_unit_id,
       ad.org_id org_id,
       ad.event_type_code event_type,
       ad.source_code hdr_source_code,
       ad.event_type_code event_offer_type,
       ad.system_status_code status,
       ad.event_venue_id venue_id,
       ad.currency_code_fc currency_code,
       nvl(f.leads_open,0) leads_open,
       nvl(f.leads_closed,0) leads_closed,
       nvl(f.leads_open_amt,0) leads_open_amt,
       nvl(f.leads_closed_amt,0) leads_closed_amt,
	   nvl(f.leads_new,0) leads_new,
	   nvl(f.leads_new_amt,0) leads_new_amt,
	   nvl(f.leads_converted,0) leads_converted,
	   nvl(f.leads_hot,0) leads_hot,
	   nvl(f.leads_dead,0) leads_dead,
	   nvl(g.nooppor,0) nooppor,
       nvl(g.opportunity_amt,0) opportunity_amt,
       0,-- budget_requested,
       0,-- budget_approved,
       nvl(orders.booked_orders,0) booked_orders,
       nvl(orders.booked_orders_amt,0) booked_orders_amt
       FROM   (SELECT /*+ parallel(A,4) parallel(E,4) ordered use_nl(DAT) */
              a.event_header_id event_header_id,
	       0 event_offer_id,
	       0 parent_id,
	       a.source_code source_code,
           a.event_type_code event_type,
           a.source_code hdr_source_code,
	       a.active_from_date event_start_date,
	       a.active_to_date event_end_date,
	       a.business_unit_id business_unit_id,
	       a.org_id org_id,
           a.country_code country_code,
	       a.event_type_code event_type_code,
	       a.system_status_code system_status_code,
	       0 event_venue_id,
	       a.currency_code_fc currency_code_fc,
	       a.fund_amount_fc fund_amount_fc,
	       e.source_code_id offer_source_code_id,
	       trunc(dat.trdate) tr_date
               FROM
                 ams_event_headers_all_b a,
	             ams_source_codes E,
	             bim_intl_dates DAT
               WHERE dat.trdate between a.active_from_date and
                     decode(greatest(a.active_to_date,p_end_datel),a.active_to_date,p_end_datel,NULL,p_end_datel,a.active_to_date)  + 0.99999
               AND   a.active_from_date+0 >= p_start_datel
               AND   a.active_from_date+0 <= p_end_datel
               and   e.source_code = a.source_code
               AND   a.system_status_code in ('ACTIVE', 'CANCELLED','COMPLETED','CLOSED')
               GROUP BY dat.trdate,
                    a.event_header_id,
        	        a.source_code,
                    a.event_type_code,
                    a.source_code,
        	        a.active_from_date,
        	        a.active_to_date,
        	        a.business_unit_id,
        	        a.org_id ,
                    a.country_code ,
	                a.event_type_code ,
        	        a.system_status_code ,
        	        a.currency_code_fc ,
        	        a.fund_amount_fc ,
        	        e.source_code_id) AD,
	   (SELECT
	       c.EVENT_HEADER_ID event_header_id
               ,e.source_code_id offer_source_code_id
               ,trunc(decode(b.OPP_OPEN_STATUS_FLAG,'Y',a.creation_date,a.last_update_date)) creation_date
               ,sum(decode(b.OPP_OPEN_STATUS_FLAG,'Y',1,0)) leads_open
	       ,sum(decode(b.OPP_OPEN_STATUS_FLAG,'Y',0,1)) leads_closed
               ,sum(decode(b.OPP_OPEN_STATUS_FLAG,'Y',0,decode(a.status_code,'DEAD_LEAD',1,0))) leads_dead
               ,sum(decode(b.OPP_OPEN_STATUS_FLAG,'Y',convert_currency(nvl(a.currency_code,'USD'),nvl(a.budget_amount,0)),0)) leads_open_amt
	       ,sum(decode(b.OPP_OPEN_STATUS_FLAG,'Y',0,convert_currency(nvl(a.currency_code,'USD'),nvl(a.budget_amount,0)))) leads_closed_amt
	       ,sum(decode(b.OPP_OPEN_STATUS_FLAG,'Y',decode(a.status_code,'NEW',1,0),0)) leads_new
               ,sum(decode(b.OPP_OPEN_STATUS_FLAG,'N',decode(a.status_code,'CONVERTED_TO_OPPORTUNITY',1,0),0)) leads_converted
               ,sum(decode(b.OPP_OPEN_STATUS_FLAG,'Y',decode(a.lead_rank_id,10000,1,0),0)) leads_hot
               ,sum(decode(b.OPP_OPEN_STATUS_FLAG,'Y',decode(a.status_code,'NEW',convert_currency(nvl(a.currency_code,'USD'),nvl(a.budget_amount,0)),0),0)) leads_new_amt
       FROM    as_sales_leads A,
	       as_statuses_b B,
               ams_event_headers_all_b C,
	       ams_source_codes E
       WHERE   a.status_code = b.status_code
       AND     e.source_code = c.source_code
	   AND     b.lead_flag = 'Y'
	   AND     b.enabled_flag = 'Y'
	   AND     NVL(a.DELETED_FLAG,'N') <> 'Y'
       and     e.source_code_id = a.source_promotion_id
       GROUP BY c.EVENT_HEADER_ID,
                trunc(decode(b.OPP_OPEN_STATUS_FLAG,'Y',a.creation_date,a.last_update_date)),
                e.source_code_id) F,
	   (select
	           b.event_header_id,
               count(distinct(decode(h.flow_status_code,'BOOKED',h.header_id,0))) -1  booked_orders,
               sum(decode(h.flow_status_code,'BOOKED',convert_currency(nvl(H.transactional_curr_code,'USD'),
			       nvl(I.unit_selling_price * I.ordered_quantity,0)),0)) booked_orders_amt,
			   i.creation_date creation_date
       from    ams_event_headers_all_b B,
               ams_source_codes C ,
               as_sales_leads D,
               as_sales_lead_opportunity A,
               as_leads_all E,
               aso_quote_related_objects F,
               aso_quote_headers_all G,
               oe_order_headers_all H,
               oe_order_lines_all I
      where    c.source_code_id = d.source_promotion_id
      and      b.source_code = c.source_code
      and      a.sales_lead_id = d.sales_lead_id
      and      a.opportunity_id = e.lead_id
      and      f.object_id = e.lead_id
      and      f.object_type_code = 'OPP_QUOTE'
      and      f.quote_object_type_code = 'HEADER'
      and      f.quote_object_id = g.quote_header_id
      and      g.order_id = h.order_number
      and      h.flow_status_code = 'BOOKED'
      AND      H.header_id = I.header_id
      group by b.event_header_id
	           ,i.creation_date) orders,
      (SELECT
	           d.event_header_id event_header_id,
               trunc(a.creation_date) creation_date,
               COUNT(A.lead_id) nooppor,
               SUM(convert_currency(nvl(currency_code, 'USD'), nvl(A.total_amount, 0))) opportunity_amt
       FROM    as_leads_all A,
               ams_event_headers_all_b D,
	           ams_source_codes E
       where   e.source_code = d.source_code
       and     e.source_code_id = a.source_promotion_id
       GROUP BY d.event_header_id, trunc(a.creation_date)) G
WHERE  f.event_header_id(+) = ad.event_header_id
and    g.event_header_id(+) = ad.event_header_id
AND    orders.event_header_id(+) = ad.event_header_id
AND    f.creation_date(+) between trunc(ad.tr_date) and trunc(ad.tr_date)+0.99999
and    g.creation_date(+) between trunc(ad.tr_date) and trunc(ad.tr_date)+0.99999
AND    orders.creation_date(+) between trunc(ad.tr_date) and trunc(ad.tr_date)+0.99999
GROUP BY ad.event_header_id,
       ad.tr_date,
       ad.parent_id,
       ad.source_code,
       ad.event_start_date,
       ad.event_end_date,
       ad.country_code,
       ad.business_unit_id,
       ad.org_id,
       ad.event_type_code,
       ad.source_code,
       ad.event_type_code,
       ad.system_status_code,
       ad.event_venue_id,
       ad.currency_code_fc,
       f.leads_dead,
       f.leads_hot,
       f.leads_converted,
       f.leads_new,
       f.leads_closed_amt,
       f.leads_open_amt,
       f.leads_closed,
       f.leads_open,
       f.leads_new_amt,
	   g.nooppor,
	   g.opportunity_amt,
       orders.booked_orders_amt,
       orders.booked_orders
HAVING f.leads_open >0
       or  f.leads_closed >0
       or  f.leads_open_amt >0
       or  f.leads_closed_amt >0
	   or  f.leads_new >0
	   or  f.leads_new_amt >0
	   or  f.leads_converted >0
	   or  f.leads_hot >0
	   or  f.leads_dead >0
	   or  g.nooppor >0
	   or  g.opportunity_amt >0
       or  orders.booked_orders >0
       or  orders.booked_orders_amt >0)inner;
    commit;
	   EXECUTE IMMEDIATE 'ALTER SEQUENCE '||l_schema||'.bim_r_even_daily_facts_s CACHE 20';
       EXECUTE IMMEDIATE 'ALTER TABLE '||l_schema||'.bim_r_even_daily_facts nologging';

    l_temp_msg := to_char( sysdate, 'dd/mm/yyyy:hh:mi:ss');
    ams_utility_pvt.write_conc_log('EVENT:FIRST_LOAD: AFTER FIRST INSERT.' || l_temp_msg);

EXCEPTION
   WHEN OTHERS THEN
       EXECUTE IMMEDIATE 'ALTER SEQUENCE '||l_schema||'.bim_r_even_daily_facts_s CACHE 20';
		   x_return_status := FND_API.G_RET_STS_ERROR;
		  FND_MESSAGE.Set_Name ('AMS', 'AMS_REP_INSERT_ERROR');
		  FND_MESSAGE.Set_token('table_name', l_table_name, FALSE);
		  FND_MSG_PUB.Add;
   ams_utility_pvt.write_conc_log('EVENT:FIRST_LOAD: EXCEPTION FOR FIRST INSERT. '||sqlerrm(sqlcode));
   RAISE FND_API.G_EXC_ERROR;
end;

begin

/*This insert statement is getting transactions book of order, leads happen and event offer level between
  p_start_date and p_end_date parameter*/

   l_temp_msg := to_char( sysdate, 'dd/mm/yyyy:hh:mi:ss');
   ams_utility_pvt.write_conc_log('EVENT:FIRST_LOAD: BEFORE SECOND INSERT BEGIN.' || l_temp_msg);
INSERT  /*+ append parallel(EDF,1) */ INTO
          bim_r_even_daily_facts EDF(
	      event_daily_transaction_id
	     ,creation_date
	     ,last_update_date
	     ,created_by
	     ,last_updated_by
	     ,last_update_login
	     ,event_header_id
	     ,event_offer_iD
	     ,parent_id
	     ,source_code
	     ,start_date
	     ,end_date
	     ,country
	     ,business_unit_id
	     ,org_id
	     ,event_type
	     ,event_offer_type
	     ,status
	     ,event_venue_id
	     ,registrations
	     ,cancellations
	     ,leads_open
         ,leads_closed
         ,leads_open_amt
         ,leads_closed_amt
	     ,leads_new
	     ,leads_new_amt
	     ,leads_converted
	     ,leads_hot
	     ,metric1 --leads_dead
	     ,opportunities
         ,opportunity_amt
	     ,attendance
	     ,forecasted_cost
	     ,actual_cost
	     ,forecasted_revenue
		 ,actual_revenue
	     ,customer
	     ,currency_code
	     ,transaction_create_date
         ,hdr_source_code
         ,order_amt
	     ,budget_requested
	     ,budget_approved
	     ,load_date
	     ,delete_flag
         ,month
         ,qtr
         ,year
		 ,booked_orders
		 ,booked_orders_amt
	     )
    SELECT
     /*+ parallel(INNER, 4) */
       bim_r_even_daily_facts_s.nextval,
       sysdate,
       sysdate,
       l_user_id,
       l_user_id,
       l_user_id,
       inner.header_id,
       inner.offer_id,
       inner.parent_id,
       inner.source_code,
       inner.start_date,
       inner.end_date,
       inner.country_code,
       inner.business_unit_id,
       inner.org_id,
       inner.event_type,
       inner.event_offer_type,
       inner.status,
       inner.venue_id,
       --(inner.registered - inner.cancelled) registered,
       inner.registered registered,
       inner.cancelled,
       inner.leads_open,
       inner.leads_closed,
       inner.leads_open_amt,
       inner.leads_closed_amt,
       inner.leads_new,
       inner.leads_new_amt,
       inner.leads_converted,
       inner.leads_hot,
       inner.leads_dead,
       inner.nooppor,
       inner.opportunity_amt,
       inner.attended,
       0,--forecast_cost
       0,--actual_cost
       0,--forecast_revenue
	   0,--actual_revenue
       inner.customer,
       inner.currency_code,
       inner.transaction_create_date,
       inner.hdr_source_code,
       0, --inner.order_amt,
       0,--inner.budget_requested,
       0,--inner.budget_approved,
       trunc(inner.weekend_date),
       'N',
       BIM_SET_OF_BOOKS.GET_FISCAL_MONTH(inner.transaction_create_date, 204),
       BIM_SET_OF_BOOKS.GET_FISCAL_QTR(inner.transaction_create_date, 204),
       BIM_SET_OF_BOOKS.GET_FISCAL_YEAR(inner.transaction_create_date, 204),
	   0, --booked_orders
	   0 --booked_orders_amt
from (SELECT /*+ full(BUDGET1.A) */
       ad.event_header_id header_id,
       ad.event_offer_id offer_id,
       ad.tr_date transaction_create_date,
       trunc((decode(decode( to_char(ad.tr_date,'MM') ,
	   to_char(next_day(ad.tr_date,TO_NUMBER(to_char(to_date('07/09/2004', 'DD/MM/RRRR'), 'DD'))),'MM') ,'TRUE','FALSE' )
	   ,'TRUE'
	   ,decode(decode( ad.tr_date , (next_day(ad.tr_date, TO_NUMBER(to_char(to_date('07/09/2004', 'DD/MM/RRRR'), 'DD'))) - 7)
	   , 'TRUE' ,'FALSE')
	   ,'TRUE'
	   ,ad.tr_date
	   ,'FALSE'
	   ,next_day(ad.tr_date, TO_NUMBER(to_char(to_date('07/09/2004', 'DD/MM/RRRR'), 'DD'))))
	   ,'FALSE'
	   ,decode(decode(to_char(ad.tr_date,'MM'),to_char(next_day(ad.tr_date,TO_NUMBER(to_char(to_date('07/09/2004', 'DD/MM/RRRR'), 'DD'))),'MM'),'TRUE','FALSE')
	   ,'FALSE'
	   ,last_day(ad.tr_date))))) weekend_date, --weekend date
       ad.parent_id parent_id,
       ad.source_code source_code,
       ad.event_start_date start_date,
       ad.event_end_date end_date,
       ad.country_code country_code,
       ad.business_unit_id,
       ad.org_id org_id,
       ad.event_type_code event_type,
       ad.source_code hdr_source_code,
       ad.event_type_code event_offer_type,
       ad.system_status_code status,
       ad.event_venue_id venue_id,
	   ad.currency_code_fc currency_code,
       nvl(oh.registered,0) registered,
       nvl(oh.cancelled,0) cancelled,
       nvl(oh.attended,0) attended,
       nvl(f.leads_open,0) leads_open,
       nvl(f.leads_closed,0) leads_closed,
       nvl(f.leads_open_amt,0) leads_open_amt,
       nvl(f.leads_closed_amt,0) leads_closed_amt,
	   nvl(f.leads_new,0) leads_new,
	   nvl(f.leads_new_amt,0) leads_new_amt,
	   nvl(f.leads_converted,0) leads_converted,
	   nvl(f.leads_hot,0) leads_hot,
	   nvl(f.leads_dead,0) leads_dead,
       nvl(g.opportunities,0) nooppor,
       nvl(g.opportunity_amt,0) opportunity_amt,
       0,--nvl(budget1.budget_requested,0) budget_requested,
       0,--nvl(budget1.budget_approved,0) budget_approved,
       COUNT(n.party_id) customer
       FROM   (SELECT /*+ parallel(A,4) parallel(E,4) ordered use(E) use_nl(DAT) */
              a.event_header_id event_header_id,
	       a.event_offer_id event_offer_id,
	       a.parent_id parent_id,
	       a.source_code source_code,
           b.event_type_code event_type,
           b.source_code hdr_source_code,
	       a.event_start_date event_start_date,
	       a.event_end_date event_end_date,
	       a.business_unit_id business_unit_id,
	       a.org_id org_id,
           a.country_code country_code,
	       a.event_type_code event_type_code,
	       a.system_status_code system_status_code,
	       a.event_venue_id event_venue_id,
	       a.currency_code_fc currency_code_fc,
	       a.fund_amount_fc fund_amount_fc,
	       e.source_code_id offer_source_code_id,
	       trunc(dat.trdate) tr_date
               FROM  ams_event_offers_all_b A,
                 ams_event_headers_all_b B,
	             ams_source_codes E,
	             bim_intl_dates DAT
               WHERE dat.trdate between a.event_start_date and
                     decode(greatest(a.event_end_date,p_end_datel),a.event_end_date,p_end_datel,NULL,p_end_datel,a.event_end_date) + 0.99999
               AND   a.event_start_date+0 >= p_start_datel
               AND   a.event_start_date+0 <= p_end_datel
	           and   e.source_code = a.source_code
               AND   a.event_header_id = b.event_header_id
               AND   a.system_status_code in ('ACTIVE', 'CANCELLED','COMPLETED','CLOSED')
               GROUP BY A.event_offer_id,
                        dat.trdate,
                        a.event_header_id,
        	        a.event_offer_id,
        	        a.parent_id,
        	        a.source_code,
                    b.event_type_code,
                    b.source_code,
        	        a.event_start_date,
        	        a.event_end_date,
        	        a.business_unit_id,
        	        a.org_id ,
                    a.country_code ,
	                a.event_type_code ,
        	        a.system_status_code ,
        	        a.event_venue_id ,
        	        a.currency_code_fc ,
        	        a.fund_amount_fc ,
        	        e.source_code_id) AD,
               (SELECT    /*+ parallel(A,4) */
                                 A.event_offer_id event_offer_id,
	                             trunc(A.last_reg_status_date)  creation_date,
		                         SUM(decode(A.system_status_code,'REGISTERED',1,'CANCELLED',1,0)) registered,
		                         SUM(decode(A.system_status_code,'CANCELLED',1,0)) cancelled,
        		                 SUM(decode(A.system_status_code,'REGISTERED',decode(attended_flag,'Y',1,0),0)) attended
        	           FROM	     ams_event_registrations A
        	           GROUP BY	 A.event_offer_id,
        			             TRUNC(A.last_reg_status_date)
								 )OH,
	  ( SELECT
               c.event_offer_id,
	       e.source_code_id offer_source_code_id
               ,trunc(decode(b.OPP_OPEN_STATUS_FLAG,'Y',a.creation_date,a.last_update_date)) creation_date
               ,sum(decode(b.OPP_OPEN_STATUS_FLAG,'Y',1,0)) leads_open
	       ,sum(decode(b.OPP_OPEN_STATUS_FLAG,'Y',0,1)) leads_closed
               ,sum(decode(b.OPP_OPEN_STATUS_FLAG,'Y',0,decode(a.status_code,'DEAD_LEAD',1,0))) leads_dead
               ,sum(decode(b.OPP_OPEN_STATUS_FLAG,'Y',convert_currency(nvl(a.currency_code,'USD'),nvl(a.budget_amount,0)),0)) leads_open_amt
		       ,sum(decode(b.OPP_OPEN_STATUS_FLAG,'Y',0,convert_currency(nvl(a.currency_code,'USD'),nvl(a.budget_amount,0)))) leads_closed_amt
			   ,sum(decode(b.OPP_OPEN_STATUS_FLAG,'Y',decode(a.status_code,'NEW',1,0),0)) leads_new
               ,sum(decode(b.OPP_OPEN_STATUS_FLAG,'N',decode(a.status_code,'CONVERTED_TO_OPPORTUNITY',1,0),0)) leads_converted
               ,sum(decode(b.OPP_OPEN_STATUS_FLAG,'Y',decode(a.lead_rank_id,10000,1,0),0)) leads_hot
               ,sum(decode(b.OPP_OPEN_STATUS_FLAG,'Y',decode(a.status_code,'NEW',convert_currency(nvl(a.currency_code,'USD'),nvl(a.budget_amount,0)),0),0)) leads_new_amt
       FROM    as_sales_leads A,
	           as_statuses_b B,
               ams_event_offers_all_b C,
	           ams_source_codes E
       WHERE   a.status_code = b.status_code
       AND     e.source_code = c.source_code
	   AND     b.lead_flag = 'Y'
       AND     b.enabled_flag = 'Y'
	   AND     NVL(a.DELETED_FLAG,'N') <> 'Y'
       and     e.source_code_id = a.source_promotion_id
       GROUP BY c.event_offer_id,
                trunc(decode(b.OPP_OPEN_STATUS_FLAG,'Y',a.creation_date,a.last_update_date)),
                e.source_code_id) F,
       (SELECT
               e.source_code_id offer_source_code_id,
               trunc(a.creation_date) creation_date,
               COUNT(A.lead_id) opportunities,
               SUM(convert_currency(nvl(currency_code, 'USD'), nvl(A.total_amount, 0))) opportunity_amt
       FROM    as_leads_all A,
               ams_event_offers_all_b C,
               ams_event_headers_all_b D,
	           ams_source_codes E
       where   e.source_code = c.source_code
       AND     c.event_header_id = d.event_header_id
       and     e.source_code_id = a.source_promotion_id
       GROUP BY trunc(a.creation_date),
       e.source_code_id) G,
    hz_cust_accounts N
WHERE  oh.event_offer_id(+) = ad.event_offer_id
AND    ad.offer_source_code_id = f.offer_source_code_id(+)
AND    ad.offer_source_code_id = g.offer_source_code_id(+)
AND    ad.source_code = n.source_code(+)
AND    n.creation_date(+) between trunc(ad.tr_date) and trunc(ad.tr_date)+0.99999
AND    f.creation_date(+) between trunc(ad.tr_date) and trunc(ad.tr_date) + 0.99999
AND    g.creation_date(+) between trunc(ad.tr_date) and trunc(ad.tr_date) + 0.99999
AND    oh.creation_date(+) between trunc(ad.tr_date) and trunc(ad.tr_date) +0.99999
GROUP BY
       ad.event_header_id ,
       ad.event_offer_id ,
       ad.tr_date,
       ad.parent_id,
       ad.source_code,
       ad.event_start_date ,
       ad.event_end_date ,
       ad.country_code ,
       ad.business_unit_id,
       ad.org_id ,
       ad.event_type_code,
       ad.system_status_code ,
       ad.event_venue_id ,
       ad.currency_code_fc,
       oh.registered,
       oh.cancelled,
       oh.attended,
       f.leads_open ,
       f.leads_closed ,
       f.leads_open_amt ,
       f.leads_closed_amt,
	   f.leads_new,
	   f.leads_new_amt,
	   f.leads_converted,
	   f.leads_hot,
	   f.leads_dead,
       g.opportunities ,
       g.opportunity_amt
HAVING oh.registered >0
       or  oh.cancelled>0
       or  oh.attended>0
       or  f.leads_open >0
       or  f.leads_closed >0
       or  f.leads_open_amt >0
       or  f.leads_closed_amt >0
	   or  f.leads_new >0
	   or  f.leads_new_amt >0
	   or  f.leads_converted >0
	   or  f.leads_hot >0
	   or  f.leads_dead >0
       or  g.opportunities >0
       or  g.opportunity_amt >0) inner;

   l_temp_msg := to_char( sysdate, 'dd/mm/yyyy:hh:mi:ss');
   ams_utility_pvt.write_conc_log('EVENT:FIRST_LOAD: AFTER SECOND INSERT.' || l_temp_msg);

  commit;
       --dbms_output.put_line('after insert row count:'||SQL%ROWCOUNT);
       EXECUTE IMMEDIATE 'ALTER SEQUENCE '||l_schema||'.bim_r_even_daily_facts_s CACHE 20';
       EXECUTE IMMEDIATE 'ALTER TABLE '||l_schema||'.bim_r_even_daily_facts nologging';
	EXCEPTION
	   WHEN OTHERS THEN
       EXECUTE IMMEDIATE 'ALTER SEQUENCE '||l_schema||'.bim_r_even_daily_facts_s CACHE 20';
                  --dbms_output.put_line('even_daily:'||sqlerrm(sqlcode));
		   x_return_status := FND_API.G_RET_STS_ERROR;
		  FND_MESSAGE.Set_Name ('AMS', 'AMS_REP_INSERT_ERROR');
		  FND_MESSAGE.Set_token('table_name', l_table_name, FALSE);
		  FND_MSG_PUB.Add;
       ams_utility_pvt.write_conc_log('EVENT:FIRST_LOAD: EXCEPTION FOR SECOND INSERT. '||sqlerrm(sqlcode));
	   RAISE FND_API.G_EXC_ERROR;
	END;

       --dbms_output.put_line('before second insert row count:');

    BEGIN
/*This insert statement is getting transactions for budget on event header and offer level between
  p_start_date and p_end_date parameter*/
   l_temp_msg := to_char( sysdate, 'dd/mm/yyyy:hh:mi:ss');
   ams_utility_pvt.write_conc_log('EVENT:FIRST_LOAD: BEFORE THIRD INSERT BEGIN.' || l_temp_msg);
    INSERT INTO /*+ append parallel(EDF,1) */
          bim_r_even_daily_facts EDF(
	      event_daily_transaction_id
	     ,creation_date
	     ,last_update_date
	     ,created_by
	     ,last_updated_by
	     ,last_update_login
	     ,event_header_id
	     ,event_offer_id
	     ,parent_id
	     ,source_code
		 ,hdr_source_code
	     ,start_date
	     ,end_date
	     ,country
	     ,business_unit_id
	     ,org_id
	     ,event_type
	     ,event_offer_type
	     ,status
	     ,event_venue_id
		 ,currency_code
	     ,transaction_create_date
		 ,load_date
	     ,delete_flag
         ,month
         ,qtr
         ,year
	     ,registrations
	     ,cancellations
		 ,attendance
	     ,leads_open
         ,leads_closed
         ,leads_open_amt
         ,leads_closed_amt
	     ,leads_new
	     ,leads_new_amt
	     ,leads_converted
	     ,leads_hot
	     ,metric1 --leads_dead
	     ,opportunities
         ,opportunity_amt
	     ,forecasted_cost
	     ,actual_cost
	     ,forecasted_revenue
		 ,actual_revenue
	     ,customer
	     ,budget_requested
	     ,budget_approved
		 ,booked_orders
		 ,booked_orders_amt
	     )
   SELECT /*+ parallel(INNER, 4) */
           bim_r_even_daily_facts_s.nextval,
	       sysdate,
	       sysdate,
	       l_user_id,
	       l_user_id,
	       l_user_id,
		   INNER.event_header_id,
	       INNER.event_offer_id,
	       INNER.parent_id,
	       INNER.source_code,
           INNER.hdr_source_code,
           INNER.event_start_date,
	       INNER.event_end_date,
           INNER.country_code,
	       INNER.business_unit_id,
	       INNER.org_id org_id,
           INNER.event_type,
	       INNER.event_type_code,
           INNER.system_status_code,
	       INNER.event_venue_id,
	       INNER.currency_code_fc,
           INNER.transaction_creation_date,
           INNER.weekend_date,
           'N',
		   BIM_SET_OF_BOOKS.GET_FISCAL_MONTH(INNER.transaction_creation_date, 204),
           BIM_SET_OF_BOOKS.GET_FISCAL_QTR(INNER.transaction_creation_date, 204),
           BIM_SET_OF_BOOKS.GET_FISCAL_YEAR(INNER.transaction_creation_date, 204),
           0, --ad.registered,
		   0, --ad.cancelled,
           0, --ad.attended,
       	   0, --ad.leads_open,
	       0, --ad.leads_closed,
       	   0, --ad.leads_open_amt,
       	   0, --ad.leads_closed_amt,
	   	   0, --ad.leads_new,
	   	   0, --ad.leads_new_amt,
	   	   0, --ad.leads_converted,
	   	   0, --ad.leads_hot,
	   	   0, --ad.leads_dead,
       	   0, --ad.nooppor,
       	   0, --ad.opportunity_amt,
           0, --ad.forecasted_cost,
           0, --ad.actual_cost,
           0, --ad.forecasted_revenue,
           0, --ad.actual_revenue,
           0, --ad.customer,
           INNER.budget_requested,
       	   INNER.budget_approved,
           0, --ad.booked_orders,
	       0 --ad.booked_orders_amt
FROM (SELECT
           a.event_header_id event_header_id,
	       a.event_offer_id event_offer_id,
	       a.parent_id parent_id,
	       a.source_code source_code,
           b.source_code hdr_source_code,
           a.event_start_date event_start_date,
	       a.event_end_date event_end_date,
           a.country_code country_code,
	       a.business_unit_id business_unit_id,
	       a.org_id org_id,
           b.event_type_code event_type,
	       a.event_type_code event_type_code,
           a.system_status_code system_status_code,
	       a.event_venue_id event_venue_id,
	       a.currency_code_fc currency_code_fc,
           ad.creation_date transaction_creation_date,
           (decode(decode(to_char(ad.creation_date,'MM') , to_char(next_day(ad.creation_date,TO_NUMBER(to_char(to_date('07/09/2004', 'DD/MM/RRRR'), 'DD'))),'MM') ,'TRUE','FALSE' )
                ,'TRUE'
                ,decode(decode(ad.creation_date , (next_day(ad.creation_date, TO_NUMBER(to_char(to_date('07/09/2004', 'DD/MM/RRRR'), 'DD'))) - 7) , 'TRUE' ,'FALSE')
                ,'TRUE'
                ,ad.creation_date
                ,'FALSE'
                ,next_day(ad.creation_date, TO_NUMBER(to_char(to_date('07/09/2004', 'DD/MM/RRRR'), 'DD'))))
                ,'FALSE'
                ,decode(decode(to_char(ad.creation_date,'MM'),to_char(next_day(ad.creation_date,TO_NUMBER(to_char(to_date('07/09/2004', 'DD/MM/RRRR'), 'DD'))),'MM'),'TRUE','FALSE')
                ,'FALSE'
                ,last_day(ad.creation_date)))) weekend_date,
           ad.budget_requested,
       	   ad.budget_approved
from(SELECT
			   a.event_offer_id event_offer_id
               ,decode(b.status_code
				    ,'PENDING'
			             ,trunc(nvl(b.request_date,b.creation_date))
				    ,'APPROVED'
                         ,trunc(nvl(b.approval_date,b.last_update_date))
				    ) creation_date
               ,sum(decode(b.status_code
				    ,'PENDING'
                          ,convert_currency(nvl(b.request_currency,'USD'),nvl(b.request_amount,0))
				    ,'APPROVED'
                         ,0
			        ))  budget_requested
               ,sum(decode(b.status_code
				    ,'PENDING'
                         ,0
				    ,'APPROVED'
                         ,convert_currency(nvl(b.approved_in_currency,'USD'),nvl(b.approved_original_amount,0))
                           ))    budget_approved
       FROM   ams_event_offers_all_b A,
              ozf_act_budgets  B
       WHERE  b.arc_act_budget_used_by in ('EVEO', 'EONE')
       AND    b.transfer_type = 'REQUEST'
	   AND    b.budget_source_type ='FUND'
       AND    b.act_budget_used_by_id = a.event_offer_id
       GROUP BY a.event_offer_id, decode(b.status_code
				    ,'PENDING'
			             ,trunc(nvl(b.request_date,b.creation_date))
				    ,'APPROVED'
                         ,trunc(nvl(b.approval_date,b.last_update_date)))
	   UNION ALL
	   SELECT
			    a.event_offer_id event_offer_id,
                trunc(nvl(b.approval_date,b.last_update_date))  creation_date,
				0, --budget_requested
                0-SUM(convert_currency(b.approved_in_currency,nvl(b.approved_original_amount,0))) budget_approved
       FROM     ams_event_offers_all_b A,
                ozf_act_budgets  B
       WHERE    b.arc_act_budget_used_by ='FUND'
       AND      transfer_type in ('TRANSFER','REQUEST')
       AND      status_code ='APPROVED'
	   AND      b.budget_source_type in ('EVEO', 'EONE')
       AND      b.act_budget_used_by_id = a.event_offer_id
       GROUP BY a.event_offer_id, trunc(nvl(b.approval_date,b.last_update_date))) AD,
   ams_event_offers_all_b A,
   ams_event_headers_all_b B
   where a.event_header_id = b.event_header_id
   and   a.event_start_date >= p_start_datel
   and   a.event_start_date <= p_end_datel
   and   ad.creation_date >= p_start_datel
   and   ad.creation_date <= p_end_datel
   AND   a.system_status_code in ('ACTIVE', 'CANCELLED','COMPLETED','CLOSED')
   AND   ad.creation_date is not null
   and   ad.event_offer_id = a.event_offer_id
UNION ALL
   SELECT
           b.event_header_id event_header_id,
	       0,-- event_offer_id,
	       0,--a.parent_id parent_id,
	       b.source_code source_code,
           b.source_code hdr_source_code,
           b.active_from_date event_start_date,
	       b.active_to_date event_end_date,
           b.country_code country_code,
	       b.business_unit_id business_unit_id,
	       b.org_id org_id,
           b.event_type_code event_type,
	       b.event_type_code event_type_code,
           b.system_status_code system_status_code,
	       0,--b.event_venue_id event_venue_id,
	       b.currency_code_fc currency_code_fc,
           ad.creation_date transaction_creation_date,
           (decode(decode(to_char(ad.creation_date,'MM') , to_char(next_day(ad.creation_date,TO_NUMBER(to_char(to_date('07/09/2004', 'DD/MM/RRRR'), 'DD'))),'MM') ,'TRUE','FALSE' )
                ,'TRUE'
                ,decode(decode(ad.creation_date , (next_day(ad.creation_date, TO_NUMBER(to_char(to_date('07/09/2004', 'DD/MM/RRRR'), 'DD'))) - 7) , 'TRUE' ,'FALSE')
                ,'TRUE'
                ,ad.creation_date
                ,'FALSE'
                ,next_day(ad.creation_date, TO_NUMBER(to_char(to_date('07/09/2004', 'DD/MM/RRRR'), 'DD'))))
                ,'FALSE'
                ,decode(decode(to_char(ad.creation_date,'MM'),to_char(next_day(ad.creation_date,TO_NUMBER(to_char(to_date('07/09/2004', 'DD/MM/RRRR'), 'DD'))),'MM'),'TRUE','FALSE')
                ,'FALSE'
                ,last_day(ad.creation_date)))) weekend_date,
           ad.budget_requested,
       	   ad.budget_approved
from(SELECT
			   a.event_header_id event_header_id
               ,decode(b.status_code
				    ,'PENDING'
			             ,trunc(nvl(b.request_date,b.creation_date))
				    ,'APPROVED'
                         ,trunc(nvl(b.approval_date,b.last_update_date))
				    ) creation_date
               ,sum(decode(b.status_code
				    ,'PENDING'
                          ,convert_currency(nvl(b.request_currency,'USD'),nvl(b.request_amount,0))
				    ,'APPROVED'
                         ,0
			        ))  budget_requested
               ,sum(decode(b.status_code
				    ,'PENDING'
                         ,0
				    ,'APPROVED'
                         ,convert_currency(nvl(b.approved_in_currency,'USD'),nvl(b.approved_original_amount,0))
                           ))    budget_approved
       FROM   ams_event_headers_all_b A,
              ozf_act_budgets  B
       WHERE  b.arc_act_budget_used_by = 'EVEH'
       AND    b.transfer_type = 'REQUEST'
	   AND    b.budget_source_type ='FUND'
       AND    b.act_budget_used_by_id = a.event_header_id
       GROUP BY a.event_header_id, decode(b.status_code
				    ,'PENDING'
			             ,trunc(nvl(b.request_date,b.creation_date))
				    ,'APPROVED'
                         ,trunc(nvl(b.approval_date,b.last_update_date)))
	   UNION ALL
	   SELECT
			    a.event_header_id event_header_id,
                trunc(nvl(b.approval_date,b.last_update_date))  creation_date,
				0, --budget_requested
                0-SUM(convert_currency(b.approved_in_currency,nvl(b.approved_original_amount,0))) budget_approved
       FROM     ams_event_headers_all_b A,
                ozf_act_budgets  B
       WHERE    b.arc_act_budget_used_by ='FUND'
       AND      transfer_type in ('TRANSFER','REQUEST')
       AND      status_code ='APPROVED'
	   AND      b.budget_source_type = 'EVEH'
       AND      b.budget_source_id = a.event_header_id
       GROUP BY a.event_header_id, trunc(nvl(b.approval_date,b.last_update_date))) AD,
   ams_event_headers_all_b B
   where
   b.system_status_code in ('ACTIVE', 'CANCELLED','COMPLETED','CLOSED')
   and   ad.event_header_id = b.event_header_id
   AND   b.active_from_date >= p_start_datel
   and   b.active_from_date <= p_end_datel
   and   ad.creation_date >= p_start_datel
   and   ad.creation_date <= p_end_datel
   AND   ad.creation_date is not null)INNER;

   l_temp_msg := to_char( sysdate, 'dd/mm/yyyy:hh:mi:ss');
   ams_utility_pvt.write_conc_log('EVENT:FIRST_LOAD: AFTER THIRD INSERT.' || l_temp_msg);

commit;

       EXECUTE IMMEDIATE 'ALTER SEQUENCE '||l_schema||'.bim_r_even_daily_facts_s CACHE 20';
       EXECUTE IMMEDIATE 'ALTER TABLE '||l_schema||'.bim_r_even_daily_facts nologging';
	EXCEPTION
	   WHEN OTHERS THEN
       EXECUTE IMMEDIATE 'ALTER SEQUENCE '||l_schema||'.bim_r_even_daily_facts_s CACHE 20';
		   x_return_status := FND_API.G_RET_STS_ERROR;
		  FND_MESSAGE.Set_Name ('AMS', 'AMS_REP_INSERT_ERROR');
		  FND_MESSAGE.Set_token('table_name', l_table_name, FALSE);
		  FND_MSG_PUB.Add;
      ams_utility_pvt.write_conc_log('EVENT:FIRST_LOAD: EXCEPTION FOR THIRD INSERT. '||sqlerrm(sqlcode));
	  RAISE FND_API.G_EXC_ERROR;
	END;



---------------------------------------------------------------------------------
/* This piece of code picks up the leads,opportunities,budget amounts,attended,registered,cancelled
for the one-off event offers */

     l_temp_msg := to_char( sysdate, 'dd/mm/yyyy:hh:mi:ss');
     ams_utility_pvt.write_conc_log('EVENT:FIRST_LOAD: BEFORE SECOND INSERT.' || l_temp_msg);
     --Insert into bim_r_even_daily_facts for one-off event offer level

     INSERT INTO
          bim_r_even_daily_facts ewf(
	      event_daily_transaction_id
	     ,creation_date
	     ,last_update_date
	     ,created_by
	     ,last_updated_by
	     ,last_update_login
	     ,event_header_id
	     ,event_offer_id
	     ,parent_id
	     ,source_code
             ,hdr_source_code
	     ,start_date
	     ,end_date
	     ,country
	     ,business_unit_id
	     ,org_id
	     ,event_type
	     ,event_offer_type
	     ,status
	     ,event_venue_id
	     ,currency_code
	     ,transaction_create_date
	     ,load_date
	     ,delete_flag
             ,month
             ,qtr
             ,year
	     ,registrations
	     ,cancellations
	     ,attendance
	     ,leads_open
             ,leads_closed
             ,leads_open_amt
             ,leads_closed_amt
	     ,leads_new
	     ,leads_new_amt
	     ,leads_converted
	     ,leads_hot
	     ,metric1 --leads_dead
	     ,opportunities
             ,opportunity_amt
	     ,forecasted_cost
	     ,actual_cost
	     ,forecasted_revenue
	     ,actual_revenue
	     ,customer
	     ,budget_requested
	     ,budget_approved
	     ,booked_orders
	     ,booked_orders_amt
	     )
     SELECT
             bim_r_even_daily_facts_s.nextval,
	     sysdate,
	     sysdate,
	     l_user_id,
	     l_user_id,
	     l_user_id,
             -999  event_header_id,
	     a.event_offer_id event_offer_id,
	     a.parent_id parent_id,
	     a.source_code source_code,
             NULL hdr_source_code,
             a.event_start_date event_start_date,
	     a.event_end_date event_end_date,
             a.country_code country_code,
	     a.business_unit_id business_unit_id,
	     a.org_id org_id,
             a.event_type_code event_type,
	     a.event_type_code event_type_code,
             a.system_status_code system_status_code,
	     a.event_venue_id event_venue_id,
	     a.currency_code_fc currency_code_fc,
             ad.creation_date transaction_creation_date,
           	(decode(decode(to_char(ad.creation_date,'MM') , to_char(next_day(ad.creation_date,TO_NUMBER(to_char(to_date('07/09/2004', 'DD/MM/RRRR'), 'DD'))),'MM') ,'TRUE','FALSE' )
                ,'TRUE'
                ,decode(decode(ad.creation_date , (next_day(ad.creation_date, TO_NUMBER(to_char(to_date('07/09/2004', 'DD/MM/RRRR'), 'DD'))) - 7) , 'TRUE' ,'FALSE')
                ,'TRUE'
                ,ad.creation_date
                ,'FALSE'
                ,next_day(ad.creation_date, TO_NUMBER(to_char(to_date('07/09/2004', 'DD/MM/RRRR'), 'DD'))))
                ,'FALSE'
                ,decode(decode(to_char(ad.creation_date,'MM'),to_char(next_day(ad.creation_date,TO_NUMBER(to_char(to_date('07/09/2004', 'DD/MM/RRRR'), 'DD'))),'MM'),'TRUE','FALSE')
                ,'FALSE'
                ,last_day(ad.creation_date)))) weekend_date,
             'N',
	     bim_set_of_books.get_fiscal_month(ad.creation_date, 204),
             bim_set_of_books.get_fiscal_qtr(ad.creation_date, 204),
             bim_set_of_books.get_fiscal_year(ad.creation_date, 204),
             ad.registered,
	     ad.cancelled,
             ad.attended,
       	     ad.leads_open,
	     ad.leads_closed,
       	     ad.leads_open_amt,
       	     ad.leads_closed_amt,
	     ad.leads_new,
	     ad.leads_new_amt,
	     ad.leads_converted,
	     ad.leads_hot,
	     ad.leads_dead,
       	     ad.nooppor,
       	     ad.opportunity_amt,
             ad.forecasted_cost,
             ad.actual_cost,
             ad.forecasted_revenue,
             ad.actual_revenue,
             ad.customer,
             ad.budget_requested,
       	     ad.budget_approved,
             ad.booked_orders,
	     ad.booked_orders_amt
     FROM (SELECT
             event_offer_id
            ,creation_date
            ,sum(registered) registered
	    ,sum(cancelled) cancelled
            ,sum(attended) attended
       	    ,sum(leads_open) leads_open
	    ,sum(leads_closed) leads_closed
       	    ,sum(leads_open_amt) leads_open_amt
       	    ,sum(leads_closed_amt) leads_closed_amt
	    ,sum(leads_new) leads_new
	    ,sum(leads_new_amt) leads_new_amt
	    ,sum(leads_converted) leads_converted
	    ,sum(leads_hot) leads_hot
	    ,sum(leads_dead) leads_dead
       	    ,sum(nooppor) nooppor
       	    ,sum(opportunity_amt) opportunity_amt
            ,sum(budget_requested) budget_requested
       	    ,sum(budget_approved) budget_approved
       	    ,0 customer
            ,sum(actual_cost) actual_cost
            ,sum(forecasted_cost) forecasted_cost
            ,sum(actual_revenue) actual_revenue
            ,sum(forecasted_revenue) forecasted_revenue
            ,sum(booked_orders) booked_orders
	    ,sum(booked_orders_amt) booked_orders_amt
     FROM ((
	SELECT
	     event_offer_id		event_offer_id
            ,creation_date		creation_date
	    ,0  			registered
	    ,0  			cancelled
            ,0  			attended
       	    ,0  			leads_open
	    ,0  			leads_closed
       	    ,0   			leads_open_amt
       	    ,0 				leads_closed_amt
	    ,0 				leads_new
	    ,0 				leads_new_amt
	    ,0 				leads_converted
	    ,0 				leads_hot
	    ,0 				leads_dead
       	    ,0 				nooppor
       	    ,0 				opportunity_amt
       	    ,sum(budget_requested) 	budget_requested
       	    ,sum(budget_approved) 	budget_approved
       	    ,0 				customer
            ,0 				actual_cost
            ,0 				forecasted_cost
            ,0 				actual_revenue
            ,0 				forecasted_revenue
            ,0 				booked_orders
	    ,0 				booked_orders_amt
     FROM
 	(SELECT
             b.act_budget_used_by_id 	event_offer_id
            ,decode(b.status_code
			    ,'PENDING'
		            ,trunc(nvl(b.request_date,b.creation_date))
			    ,'APPROVED'
                            ,trunc(nvl(b.approval_date,b.last_update_date))
			    ) 		creation_date
            ,sum(decode(b.status_code
			    ,'PENDING'
                            ,convert_currency(nvl(b.request_currency,'USD'),nvl(b.request_amount,0))
			    ,'APPROVED'
                            ,- convert_currency(nvl(b.request_currency,'USD'),nvl(b.request_amount,0))
			    ))  	budget_requested
            ,sum(decode(b.status_code
			    ,'PENDING'
                            ,0
			    ,'APPROVED'
                            ,convert_currency(nvl(b.approved_in_currency,'USD'),nvl(b.approved_original_amount,0))
                            ))    	budget_approved
         FROM   ozf_act_budgets  b
		,ams_event_offers_all_b a
         WHERE  b.arc_act_budget_used_by in ('EONE')
	 AND    b.budget_source_type ='FUND'
	 AND 	a.event_offer_id = b.act_budget_used_by_id
	 AND    a.event_header_id  is null
	 AND   (parent_type is null or parent_type = 'RCAM')
         GROUP BY b.act_budget_used_by_id,decode(b.status_code
			    ,'PENDING'
			    ,trunc(nvl(b.request_date,b.creation_date))
			    ,'APPROVED'
                            ,trunc(nvl(b.approval_date,b.last_update_date)))
	 UNION ALL
	 SELECT
                b.budget_source_id 	event_offer_id,
                trunc(nvl(b.approval_date,b.last_update_date))  creation_date,
		0, --budget_requested
                0-SUM(convert_currency(b.approved_in_currency,nvl(b.approved_original_amount,0))) budget_approved
       	 FROM    ozf_act_budgets  B
		,ams_event_offers_all_b a
         WHERE b.arc_act_budget_used_by ='FUND'
         AND   status_code ='APPROVED'
	 AND   b.budget_source_type in ('EONE')
         AND   a.event_offer_id = b.act_budget_used_by_id
         AND   a.event_header_id  is null
         AND   (parent_type is null or parent_type = 'RCAM')
         GROUP BY b.budget_source_id, trunc(nvl(b.approval_date,b.last_update_date))
	)
        WHERE creation_date between p_start_datel and p_end_datel + 0.9999
        GROUP BY event_offer_id ,creation_date)
     UNION ALL
 	(SELECT
             c.event_offer_id		event_offer_id
            ,trunc(a.creation_date)  	creation_date
            ,0 				registered
	    ,0 				cancelled
            ,0 				attended
       	    ,0 				leads_open
	    ,0 				leads_closed
       	    ,0  			leads_open_amt
       	    ,0 				leads_closed_amt
	    ,0 				leads_new
	    ,0 				leads_new_amt
	    ,0 				leads_converted
	    ,0 				leads_hot
	    ,0 				leads_dead
            ,count(A.lead_id) 		opportunities
            ,sum(convert_currency(nvl(currency_code, 'USD'), nvl(A.total_amount, 0))) opportunity_amt
       	    ,0				budget_requested
       	    ,0				budget_approved
       	    ,0			        customer
            ,0				actual_cost
            ,0 				forecasted_cost
            ,0 				actual_revenue
            ,0 				forecasted_revenue
            ,0 				booked_orders
	    ,0 				booked_orders_amt
       FROM    as_leads_all A,
               ams_event_offers_all_b C,
	       ams_source_codes E
       WHERE   e.source_code_for_id = c.event_offer_id
       AND     c.event_standalone_flag = 'Y'
       AND     (c.parent_type is null or c.parent_type ='RCAM')
       AND     e.source_code_id = a.source_promotion_id
       AND     e.arc_source_code_for in ('EONE')
       AND     trunc(a.creation_date) between p_start_datel and p_end_datel + 0.9999
       GROUP BY c.event_offer_id,trunc(a.creation_date),e.source_code_id)
     UNION ALL
       (SELECT
	           c.event_offer_id
            ,trunc(decode(b.OPP_OPEN_STATUS_FLAG,'Y',a.creation_date,a.last_update_date)) creation_date
            ,0				 registered
	    ,0				 cancelled
            ,0				 attended
            ,sum(decode(b.OPP_OPEN_STATUS_FLAG,'Y',1,0)) leads_open
	    ,sum(decode(b.OPP_OPEN_STATUS_FLAG,'Y',0,1)) leads_closed
            ,sum(decode(b.OPP_OPEN_STATUS_FLAG,'Y',convert_currency(nvl(a.currency_code,'USD'),nvl(a.budget_amount,0)),0)) leads_open_amt
	    ,sum(decode(b.OPP_OPEN_STATUS_FLAG,'Y',0,convert_currency(nvl(a.currency_code,'USD'),nvl(a.budget_amount,0)))) leads_closed_amt
	    ,sum(decode(b.OPP_OPEN_STATUS_FLAG,'Y',decode(a.status_code,'NEW',1,0),0)) leads_new
            ,sum(decode(b.OPP_OPEN_STATUS_FLAG,'Y',decode(a.status_code,'NEW',convert_currency(nvl(a.currency_code,'USD'),nvl(a.budget_amount,0)),0),0)) leads_new_amt
            ,sum(decode(b.OPP_OPEN_STATUS_FLAG,'N',decode(a.status_code,'CONVERTED_TO_OPPORTUNITY',1,0),0)) leads_converted
            ,sum(decode(b.OPP_OPEN_STATUS_FLAG,'Y',decode(a.lead_rank_id,10000,1,0),0)) leads_hot
            ,sum(decode(b.OPP_OPEN_STATUS_FLAG,'Y',0,decode(a.status_code,'DEAD_LEAD',1,0))) leads_dead
            ,0                          opportunities
            ,0                          opportunity_amt
            ,0                          budget_requested
            ,0                          budget_approved
            ,0                          customer
            ,0                          actual_cost
            ,0                          forecasted_cost
            ,0                          actual_revenue
            ,0                          forecasted_revenue
            ,0                          booked_orders
            ,0                          booked_orders_amt
       FROM    as_sales_leads A,
	       as_statuses_b B,
               ams_event_offers_all_b C,
	       ams_source_codes E
       WHERE   e.source_code_for_id = c.event_offer_id
       AND     c.event_standalone_flag = 'Y'
       AND     (c.parent_type is null or c.parent_type ='RCAM')
       AND     e.source_code_id = a.source_promotion_id
       AND     a.status_code = b.status_code
       AND     e.arc_source_code_for in ('EONE')
       AND     b.lead_flag = 'Y'
       AND     b.enabled_flag = 'Y'
       AND     NVL(a.DELETED_FLAG,'N') <> 'Y'
       AND     trunc(decode(b.OPP_OPEN_STATUS_FLAG,'Y',a.creation_date,a.last_update_date))
		between p_start_datel and p_end_datel + 0.9999
       GROUP BY c.event_offer_id,
                trunc(decode(b.OPP_OPEN_STATUS_FLAG,'Y',a.creation_date,a.last_update_date)),
                e.source_code_id)
     UNION ALL
        (SELECT
	     A.event_offer_id 		event_offer_id
	    ,trunc(A.last_reg_status_date) creation_date
	    ,sum(decode(A.system_status_code,'REGISTERED',1,'CANCELLED',1,0)) registered
	    ,sum(decode(A.system_status_code,'CANCELLED',1,0)) 	cancelled
            ,sum(decode(A.system_status_code,'REGISTERED',decode(attended_flag,'Y',1,0),0)) attended
            ,0                          leads_open
            ,0                          leads_closed
            ,0                          leads_open_amt
            ,0                          leads_closed_amt
            ,0                          leads_new
            ,0                          leads_new_amt
            ,0                          leads_converted
            ,0                          leads_hot
            ,0                          leads_dead
       	    ,0				opportunities
       	    ,0				opportunity_amt
            ,0                          budget_requested
            ,0                          budget_approved
            ,0                          customer
            ,0                          actual_cost
            ,0                          forecasted_cost
            ,0                          actual_revenue
            ,0                          forecasted_revenue
            ,0                          booked_orders
            ,0                          booked_orders_amt
      FROM   ams_event_registrations A
      WHERE  trunc(A.last_reg_status_date) between p_start_datel and p_end_datel + 0.9999
      GROUP BY	 A.event_offer_id,trunc(A.last_reg_status_date))
    UNION ALL
     (SELECT
	     b.event_offer_id		event_offer_id
            ,trunc(i.creation_date) 	creation_date
            ,0  			registered
	    ,0  			cancelled
            ,0  			attended
       	    ,0  			leads_open
	    ,0  			leads_closed
       	    ,0  			leads_open_amt
       	    ,0 				leads_closed_amt
	    ,0 				leads_new
	    ,0 				leads_new_amt
	    ,0 				leads_converted
	    ,0 				leads_hot
	    ,0 				leads_dead
       	    ,0 				nooppor
       	    ,0 				opportunity_amt
       	    ,0 				budget_requested
       	    ,0 				budget_approved
       	    ,0 				customer
            ,0 				actual_cost
            ,0 				forecasted_cost
            ,0 				actual_revenue
            ,0 				forecasted_revenue
            ,count(distinct(decode(h.flow_status_code,'BOOKED',h.header_id,0))) -1  booked_orders
            ,sum(decode(h.flow_status_code,'BOOKED',convert_currency(nvl(H.transactional_curr_code,'USD'),
		       nvl(I.unit_selling_price * I.ordered_quantity,0)),0)) booked_orders_amt
       FROM    ams_event_offers_all_b B,
               ams_source_codes C ,
               as_sales_leads D,
               as_sales_lead_opportunity A,
               as_leads_all E,
               aso_quote_related_objects F,
               aso_quote_headers_all G,
               oe_order_headers_all H,
               oe_order_lines_all I
       WHERE    c.source_code_id = d.source_promotion_id
       AND     b.event_standalone_flag = 'Y'
       AND     (b.parent_type is null or b.parent_type ='RCAM')
       AND      b.source_code = c.source_code
       AND      a.sales_lead_id = d.sales_lead_id
       AND      a.opportunity_id = e.lead_id
       AND      f.object_id = e.lead_id
       AND      f.object_type_code = 'OPP_QUOTE'
       AND      f.quote_object_type_code = 'HEADER'
       AND      f.quote_object_id = g.quote_header_id
       AND      g.order_id = h.order_number
       AND      h.flow_status_code = 'BOOKED'
       AND      H.header_id = I.header_id
       AND      trunc(i.creation_date) between p_start_datel and p_end_datel + 0.9999
       GROUP BY b.event_offer_id
	           ,trunc(i.creation_date)) --orders
    )
   GROUP BY event_offer_id ,creation_date
   )   AD,
       ams_event_offers_all_b A,
       ams_source_codes E
   WHERE ad.event_offer_id = a.event_offer_id
   AND   a.event_standalone_flag = 'Y'
   AND   (a.parent_type is null or a.parent_type = 'RCAM')
   AND   e.source_code_for_id = a.event_offer_id
   AND   e.source_code 	= a.source_code
   AND   a.system_status_code in ('ACTIVE','CANCELLED','CLOSED','COMPLETED')
   AND   e.arc_source_code_for = 'EONE'
   AND   a.event_start_date >= p_start_datel
   AND   a.event_start_date <= p_end_datel;



/*********************************************************************************************/

/* This insert statement is getting the registration,cancellations,attended that happened before the ONE-OFF event offer started */

BEGIN
        l_temp_msg := to_char( sysdate, 'dd/mm/yyyy:hh:mi:ss');
   	ams_utility_pvt.write_conc_log('EVENT:FIRST_LOAD: BEFORE registration INSERT BEGIN.' || l_temp_msg);

	FOR y IN get_one_off_events(p_start_datel)
	LOOP

	BEGIN
		SELECT 	min(last_reg_status_date)
		INTO	l_min_date
		FROM 	ams_event_registrations
		WHERE	event_offer_id =  y.event_offer_id;
		EXCEPTION
		WHEN OTHERS THEN
			NULL;
		ams_utility_pvt.write_conc_log('EVENT:FIRST_LOAD: Exception for finding the min of creation date for cost and revenue. '||sqlerrm(sqlcode));
	   	RAISE FND_API.G_EXC_ERROR;
	END;

     IF l_min_date IS NOT NULL THEN

      BEGIN

      INSERT  INTO
          bim_r_even_daily_facts EDF(
	      event_daily_transaction_id
	     ,creation_date
	     ,last_update_date
	     ,created_by
	     ,last_updated_by
	     ,last_update_login
	     ,event_header_id
	     ,event_offer_id
	     ,parent_id
	     ,source_code
	     ,start_date
	     ,end_date
	     ,country
	     ,business_unit_id
	     ,org_id
	     ,event_type
	     ,event_offer_type
	     ,status
	     ,event_venue_id
	     ,registrations
	     ,cancellations
	     ,leads_open
             ,leads_closed
             ,leads_open_amt
             ,leads_closed_amt
	     ,leads_new
	     ,leads_new_amt
	     ,leads_converted
	     ,leads_hot
	     ,metric1 --leads_dead
	     ,opportunities
             ,opportunity_amt
	     ,attendance
	     ,forecasted_cost
	     ,actual_cost
	     ,forecasted_revenue
	     ,actual_revenue
	     ,customer
	     ,currency_code
	     ,transaction_create_date
             ,hdr_source_code
             ,order_amt
	     ,budget_requested
	     ,budget_approved
	     ,load_date
	     ,delete_flag
             ,month
             ,qtr
             ,year
	     ,booked_orders
	     ,booked_orders_amt
	     )
      SELECT
       	      bim_r_even_daily_facts_s.nextval
       	     ,sysdate
             ,sysdate
       	     ,l_user_id
       	     ,l_user_id
       	     ,l_user_id
       	     ,y.event_header_id
       	     ,y.event_offer_id
       	     ,y.parent_id
       	     ,y.source_code
       	     ,y.event_start_date
       	     ,y.event_end_date
       	     ,y.country_code
       	     ,y.business_unit_id
       	     ,y.org_id
       	     ,y.event_type
       	     ,y.event_type_code
       	     ,y.system_status_code
       	     ,y.event_venue_id
       	     ,inner.registered registered
       	     ,inner.cancelled cancelled
       	     ,0  --inner.leads_open
       	     ,0  --inner.leads_closed
       	     ,0  --inner.leads_open_amt
       	     ,0  --inner.leads_closed_amt
       	     ,0  --inner.leads_new
       	     ,0  --inner.leads_new_amt
       	     ,0  --inner.leads_converted
       	     ,0  --inner.leads_hot
       	     ,0  --inner.leads_dead
       	     ,0  --inner.nooppor
       	     ,0  --inner.opportunity_amt
       	     ,inner.attended attended
       	     ,0  --forecast_cost
       	     ,0  --actual_cost
       	     ,0  --forecast_revenue
	     ,0  --actual_revenue
             ,0  --inner.customer
             ,0  --inner.currency_code
             ,inner.transaction_create_date
             ,0  --inner.hdr_source_code
             ,0  --inner.order_amt
             ,0  --inner.budget_requested
             ,0  --inner.budget_approved
             ,trunc(decode(decode(to_char(inner.transaction_create_date,'MM') , to_char(next_day(inner.transaction_create_date,TO_NUMBER(to_char(to_date('07/09/2004', 'DD/MM/RRRR'), 'DD'))),'MM') ,'TRUE','FALSE' )
                ,'TRUE'
                ,decode(decode(inner.transaction_create_date , (next_day(inner.transaction_create_date, TO_NUMBER(to_char(to_date('07/09/2004', 'DD/MM/RRRR'), 'DD'))) - 7) , 'TRUE' ,'FALSE')
                ,'TRUE'
                ,inner.transaction_create_date
                ,'FALSE'
                ,next_day(inner.transaction_create_date, TO_NUMBER(to_char(to_date('07/09/2004', 'DD/MM/RRRR'), 'DD'))))
                ,'FALSE'
                ,decode(decode(to_char(inner.transaction_create_date,'MM'),to_char(next_day(inner.transaction_create_date,TO_NUMBER(to_char(to_date('07/09/2004', 'DD/MM/RRRR'), 'DD'))),'MM'),'TRUE','FALSE')
                ,'FALSE'
                ,last_day(inner.transaction_create_date)))) --weekend date
             ,'N'
             ,BIM_SET_OF_BOOKS.GET_FISCAL_MONTH(inner.transaction_create_date, 204)
             ,BIM_SET_OF_BOOKS.GET_FISCAL_QTR(inner.transaction_create_date, 204)
             ,BIM_SET_OF_BOOKS.GET_FISCAL_YEAR(inner.transaction_create_date, 204)
	     ,0 --booked_orders
	     ,0 --booked_orders_amt
   FROM(
        SELECT
		      trunc(a.last_reg_status_date) transaction_create_date,
		        SUM(decode(A.system_status_code,'REGISTERED',1,'CANCELLED',1,0)) registered,
		        SUM(decode(A.system_status_code,'CANCELLED',1,0)) cancelled,
        		SUM(decode(A.system_status_code,'REGISTERED',decode(attended_flag,'Y',1,0),0)) attended
        FROM ams_event_registrations A
        WHERE a.last_reg_status_date between trunc(l_min_date) and trunc(y.event_start_date)-1 +0.9999
	AND   y.event_start_date >= p_start_datel
	AND   y.event_start_date <= p_end_datel
	AND   a.event_offer_id = y.event_offer_id
        GROUP BY trunc(a.last_reg_status_date)
	HAVING SUM(decode(A.system_status_code,'REGISTERED',1,'CANCELLED',1,0)) >0
            OR SUM(decode(A.system_status_code,'CANCELLED',1,0)) >0
            OR SUM(decode(A.system_status_code,'REGISTERED',decode(attended_flag,'Y',1,0),0)) >0)inner ;

	EXCEPTION
	WHEN NO_DATA_FOUND THEN
		NULL;
		ams_utility_pvt.write_conc_log('Exception for registered no data found. '||sqlerrm(sqlcode));
	RAISE FND_API.G_EXC_ERROR;
    END;

 END IF;

END LOOP;

   l_temp_msg := to_char( sysdate, 'dd/mm/yyyy:hh:mi:ss');
   ams_utility_pvt.write_conc_log('EVENT:FIRST_LOAD: AFTER registration INSERT.' || l_temp_msg);
COMMIT;
       EXECUTE IMMEDIATE 'ALTER SEQUENCE '||l_schema||'.bim_r_even_daily_facts_s CACHE 20';
       EXECUTE IMMEDIATE 'ALTER TABLE '||l_schema||'.bim_r_even_daily_facts nologging';
EXCEPTION
   WHEN OTHERS THEN
       EXECUTE IMMEDIATE 'ALTER SEQUENCE '||l_schema||'.bim_r_even_daily_facts_s CACHE 20';
                  --dbms_output.put_line('even_update:'||sqlerrm(sqlcode));
		   x_return_status := FND_API.G_RET_STS_ERROR;
		  FND_MESSAGE.Set_Name ('AMS', 'AMS_REP_INSERT_ERROR');
		  FND_MESSAGE.Set_token('table_name', l_table_name, FALSE);
		  FND_MSG_PUB.Add;
		  ams_utility_pvt.write_conc_log('EVENT:FIRST_LOAD: EXCEPTION registration insert statement. '||sqlerrm(sqlcode));
RAISE FND_API.G_EXC_ERROR;
END;


/*********************************************************************************************/

/* This insert statement is getting the registration that happened before the event offer started */

BEGIN
	     l_temp_msg := to_char( sysdate, 'dd/mm/yyyy:hh:mi:ss');
   ams_utility_pvt.write_conc_log('EVENT:FIRST_LOAD: BEFORE registration INSERT BEGIN.' || l_temp_msg);
	FOR x IN get_event(p_start_datel)
	LOOP

	BEGIN
		SELECT 	min(last_reg_status_date)
		INTO	l_min_date
		FROM 	ams_event_registrations
		WHERE	event_offer_id =  x.event_offer_id;
		EXCEPTION
		WHEN OTHERS THEN
			NULL;
		    ams_utility_pvt.write_conc_log('EVENT:FIRST_LOAD: Exception for finding the min of creation date for cost and revenue. '||sqlerrm(sqlcode));
	   	 RAISE FND_API.G_EXC_ERROR;
	END;

     IF l_min_date IS NOT NULL THEN

	/*This insert statement is getting transactions for registration, cancellation, and attended happened on
	event offer level between p_start_date and p_end_date parameter*/

      BEGIN

      INSERT  INTO
          bim_r_even_daily_facts EDF(
	      event_daily_transaction_id
	     ,creation_date
	     ,last_update_date
	     ,created_by
	     ,last_updated_by
	     ,last_update_login
	     ,event_header_id
	     ,event_offer_id
	     ,parent_id
	     ,source_code
	     ,start_date
	     ,end_date
	     ,country
	     ,business_unit_id
	     ,org_id
	     ,event_type
	     ,event_offer_type
	     ,status
	     ,event_venue_id
	     ,registrations
	     ,cancellations
	     ,leads_open
         ,leads_closed
         ,leads_open_amt
         ,leads_closed_amt
	     ,leads_new
	     ,leads_new_amt
	     ,leads_converted
	     ,leads_hot
	     ,metric1 --leads_dead
	     ,opportunities
         ,opportunity_amt
	     ,attendance
	     ,forecasted_cost
	     ,actual_cost
	     ,forecasted_revenue
		 ,actual_revenue
	     ,customer
	     ,currency_code
	     ,transaction_create_date
         ,hdr_source_code
         ,order_amt
	     ,budget_requested
	     ,budget_approved
	     ,load_date
	     ,delete_flag
         ,month
         ,qtr
         ,year
		 ,booked_orders
		 ,booked_orders_amt
	     )
    SELECT
       bim_r_even_daily_facts_s.nextval,
       sysdate,
       sysdate,
       l_user_id,
       l_user_id,
       l_user_id,
       x.event_header_id,
       x.event_offer_id,
       x.parent_id,
       x.source_code,
       x.event_start_date,
       x.event_end_date,
       x.country_code,
       x.business_unit_id,
       x.org_id,
       x.event_type,
       x.event_type_code,
       x.system_status_code,
       x.event_venue_id,
       --(inner.registered - inner.cancelled) registered,
       inner.registered registered,
       inner.cancelled cancelled,
       0,--inner.leads_open,
       0,--inner.leads_closed,
       0,--inner.leads_open_amt,
       0,--inner.leads_closed_amt,
       0,--inner.leads_new,
       0,--inner.leads_new_amt,
       0,--inner.leads_converted,
       0,--inner.leads_hot,
       0,--inner.leads_dead,
       0,--inner.nooppor,
       0,--inner.opportunity_amt,
       inner.attended attended,
       0,--forecast_cost
       0,--actual_cost
       0,--forecast_revenue
	   0,--actual_revenue
       0,--inner.customer,
       0,--inner.currency_code,
       inner.transaction_create_date,
       0,--inner.hdr_source_code,
       0, --inner.order_amt,
       0,--inner.budget_requested,
       0,--inner.budget_approved,
       trunc(decode(decode(to_char(inner.transaction_create_date,'MM') , to_char(next_day(inner.transaction_create_date,TO_NUMBER(to_char(to_date('07/09/2004', 'DD/MM/RRRR'), 'DD'))),'MM') ,'TRUE','FALSE' )
                ,'TRUE'
                ,decode(decode(inner.transaction_create_date , (next_day(inner.transaction_create_date, TO_NUMBER(to_char(to_date('07/09/2004', 'DD/MM/RRRR'), 'DD'))) - 7) , 'TRUE' ,'FALSE')
                ,'TRUE'
                ,inner.transaction_create_date
                ,'FALSE'
                ,next_day(inner.transaction_create_date, TO_NUMBER(to_char(to_date('07/09/2004', 'DD/MM/RRRR'), 'DD'))))
                ,'FALSE'
                ,decode(decode(to_char(inner.transaction_create_date,'MM'),to_char(next_day(inner.transaction_create_date,TO_NUMBER(to_char(to_date('07/09/2004', 'DD/MM/RRRR'), 'DD'))),'MM'),'TRUE','FALSE')
                ,'FALSE'
                ,last_day(inner.transaction_create_date)))), --weekend date
       'N',
       BIM_SET_OF_BOOKS.GET_FISCAL_MONTH(inner.transaction_create_date, 204),
       BIM_SET_OF_BOOKS.GET_FISCAL_QTR(inner.transaction_create_date, 204),
       BIM_SET_OF_BOOKS.GET_FISCAL_YEAR(inner.transaction_create_date, 204),
	   0, --booked_orders
	   0 --booked_orders_amt
   from(
        SELECT
		      trunc(a.last_reg_status_date) transaction_create_date,
		        SUM(decode(A.system_status_code,'REGISTERED',1,'CANCELLED',1,0)) registered,
		        SUM(decode(A.system_status_code,'CANCELLED',1,0)) cancelled,
        		SUM(decode(A.system_status_code,'REGISTERED',decode(attended_flag,'Y',1,0),0)) attended
         FROM
        ams_event_registrations A
        where a.last_reg_status_date between trunc(l_min_date) and trunc(x.event_start_date)-1 +0.9999
		and   x.event_start_date >= p_start_datel
		and   x.event_start_date <= p_end_datel
		and   a.event_offer_id = x.event_offer_id
        group by trunc(a.last_reg_status_date)
		having SUM(decode(A.system_status_code,'REGISTERED',1,'CANCELLED',1,0)) >0
            or SUM(decode(A.system_status_code,'CANCELLED',1,0)) >0
            or SUM(decode(A.system_status_code,'REGISTERED',decode(attended_flag,'Y',1,0),0)) >0)inner
		;

	EXCEPTION
	WHEN NO_DATA_FOUND THEN
	NULL;
	ams_utility_pvt.write_conc_log('Exception for registered no data found. '||sqlerrm(sqlcode));
	RAISE FND_API.G_EXC_ERROR;
    END;

 END IF;

--END IF;

END LOOP;

   l_temp_msg := to_char( sysdate, 'dd/mm/yyyy:hh:mi:ss');
   ams_utility_pvt.write_conc_log('EVENT:FIRST_LOAD: AFTER registration INSERT.' || l_temp_msg);
COMMIT;
       EXECUTE IMMEDIATE 'ALTER SEQUENCE '||l_schema||'.bim_r_even_daily_facts_s CACHE 20';
       EXECUTE IMMEDIATE 'ALTER TABLE '||l_schema||'.bim_r_even_daily_facts nologging';
EXCEPTION
   WHEN OTHERS THEN
       EXECUTE IMMEDIATE 'ALTER SEQUENCE '||l_schema||'.bim_r_even_daily_facts_s CACHE 20';
                  --dbms_output.put_line('even_update:'||sqlerrm(sqlcode));
		   x_return_status := FND_API.G_RET_STS_ERROR;
		  FND_MESSAGE.Set_Name ('AMS', 'AMS_REP_INSERT_ERROR');
		  FND_MESSAGE.Set_token('table_name', l_table_name, FALSE);
		  FND_MSG_PUB.Add;
		  ams_utility_pvt.write_conc_log('EVENT:FIRST_LOAD: EXCEPTION registration insert statement. '||sqlerrm(sqlcode));
RAISE FND_API.G_EXC_ERROR;
END;

-- analyze the bim_r_event_daily_facts with dbms_stats
BEGIN
   DBMS_STATS.gather_table_stats('BIM','BIM_R_EVEN_DAILY_FACTS', estimate_percent => 5,
                                  degree => 8, granularity => 'GLOBAL', cascade =>TRUE);
END;

/*This update statement is to updating forecasted_cost, actual_cost, forecasted_revenue, and actual_revenue that event header happened between p_start_date and p_end_date parameter*/

      DECLARE

         l_oneoff_actual_cost            NUMBER;
         l_oneoff_forecasted_cost        NUMBER;
         l_oneoff_actual_revenue         NUMBER;
         l_oneoff_forecasted_revenue     NUMBER;

         CURSOR  event_dates IS
         SELECT  event_header_id,event_offer_id, max(transaction_create_date) max_date
         FROM    bim_r_even_daily_facts
         GROUP   BY event_header_id,event_offer_id;

         CURSOR  one_off_cost_revenue IS
         SELECT  event_header_id,event_offer_id, max(transaction_create_date) max_date
         FROM    bim_r_even_daily_facts
         WHERE   event_header_id = -999
         GROUP   BY event_header_id,event_offer_id;

      BEGIN
     	l_temp_msg := to_char( sysdate, 'dd/mm/yyyy:hh:mi:ss');
        ams_utility_pvt.write_conc_log('EVENT:FIRST_LOAD: BEGIN UPDATE FOR COST AND REVENUE.' || l_temp_msg);

       FOR   x  IN event_dates LOOP

	BEGIN
          SELECT   sum(convert_currency(nvl(a.FUNCTIONAL_CURRENCY_CODE,'USD'),nvl(a.trans_actual_value,0)))
           	 ,sum(convert_currency(nvl(a.FUNCTIONAL_CURRENCY_CODE,'USD'),nvl(a.trans_forecasted_value,0)))
          INTO    l_actual_costh,l_forecasted_costh
          FROM    ams_act_metrics_all a,
                  ams_metrics_all_b  b
          WHERE   a.act_metric_used_by_id         = x.event_header_id
          AND     a.arc_act_metric_used_by        ='EVEH'
          AND     a.metric_id                     = b.metric_id
          AND     b.metric_calculation_type       IN ('MANUAL','FUNCTION','ROLLUP')
          AND     b.metric_category               = 901 ;
	EXCEPTION
	WHEN NO_DATA_FOUND THEN
		NULL;
        WHEN OTHERS THEN
        	ams_utility_pvt.write_conc_log('FROM COST SELECT SQL ' || sqlerrm(sqlcode));
		RAISE FND_API.G_EXC_ERROR;
        END;

	BEGIN
          SELECT  sum(convert_currency(nvl(a.FUNCTIONAL_CURRENCY_CODE,'USD'),nvl(a.trans_actual_value,0)))
           	 ,sum(convert_currency(nvl(a.FUNCTIONAL_CURRENCY_CODE,'USD'),nvl(a.trans_forecasted_value,0)))
          INTO    l_actual_revenueh
          	 ,l_forecasted_revenueh
          FROM    ams_act_metrics_all a,
                  ams_metrics_all_b  b
          WHERE   a.act_metric_used_by_id             = x.event_header_id
          AND     a.arc_act_metric_used_by            ='EVEH'
          AND     a.metric_id                         = b.metric_id
          AND     b.metric_calculation_type           IN ('MANUAL','FUNCTION','ROLLUP')
          AND     b.metric_category                   = 902 ;
	EXCEPTION
	WHEN NO_DATA_FOUND THEN
		NULL;
          WHEN OTHERS THEN
         	ams_utility_pvt.write_conc_log('FROM REVENUE SELECT SQL ' || sqlerrm(sqlcode));
		RAISE FND_API.G_EXC_ERROR;
    	END;

        BEGIN

         UPDATE bim_r_even_daily_facts
         SET   actual_cost         = l_actual_costh
              ,forecasted_cost     = l_forecasted_costh
              ,actual_revenue      = l_actual_revenueh
              ,forecasted_revenue  = l_forecasted_revenueh
         WHERE event_header_id 	   = x.event_header_id
         AND   event_offer_id      = 0
         AND  transaction_create_date  = x.max_date;
	EXCEPTION
	WHEN NO_DATA_FOUND THEN
		NULL;
        WHEN OTHERS THEN
         	ams_utility_pvt.write_conc_log('EVENT:FIRST_LOAD: EXCEPTION FOR UPDATE FOR COST AND REVENUE' || sqlerrm(sqlcode));
		RAISE FND_API.G_EXC_ERROR;
        END;
       END LOOP;
    END;

 /********************** FOR UPDATING THE ONE-OFF EVENT OFFERS ***************************/


     DECLARE

         l_oneoff_actual_cost            NUMBER;
         l_oneoff_forecasted_cost        NUMBER;
         l_oneoff_actual_revenue         NUMBER;
         l_oneoff_forecasted_revenue     NUMBER;

         CURSOR  one_off_cost_revenue IS
         SELECT  event_header_id,event_offer_id, max(transaction_create_date) max_date
         FROM    bim_r_even_daily_facts
         WHERE   event_header_id = -999
         GROUP   BY event_header_id,event_offer_id;

     BEGIN

     FOR  y in one_off_cost_revenue LOOP

     BEGIN
         SELECT   sum(convert_currency(nvl(a.FUNCTIONAL_CURRENCY_CODE,'USD'),nvl(a.trans_actual_value,0)))
          	 ,sum(convert_currency(nvl(a.FUNCTIONAL_CURRENCY_CODE,'USD'),nvl(a.trans_forecasted_value,0)))
         INTO    l_oneoff_actual_cost,l_oneoff_forecasted_cost
         FROM    ams_act_metrics_all a,
                 ams_metrics_all_b  b
         WHERE   a.act_metric_used_by_id         = y.event_offer_id
         AND     a.arc_act_metric_used_by        ='EONE'
         AND     a.metric_id                     = b.metric_id
         AND     b.metric_calculation_type       IN ('MANUAL','FUNCTION','ROLLUP')
         AND     b.metric_category               = 901 ;
    EXCEPTION
	WHEN NO_DATA_FOUND THEN
		NULL;
    WHEN OTHERS THEN
        ams_utility_pvt.write_conc_log('FROM COST SELECT SQL ' || sqlerrm(sqlcode));
	RAISE FND_API.G_EXC_ERROR;
    END;

    BEGIN
         SELECT  sum(convert_currency(nvl(a.FUNCTIONAL_CURRENCY_CODE,'USD'),nvl(a.trans_actual_value,0)))
          	 ,sum(convert_currency(nvl(a.FUNCTIONAL_CURRENCY_CODE,'USD'),nvl(a.trans_forecasted_value,0)))
         INTO    l_oneoff_actual_revenue ,l_oneoff_forecasted_revenue
         FROM    ams_act_metrics_all a,
                 ams_metrics_all_b  b
         WHERE   a.act_metric_used_by_id             = y.event_offer_id
         AND     a.arc_act_metric_used_by            ='EONE'
         AND     a.metric_id                         = b.metric_id
         AND     b.metric_calculation_type           IN ('MANUAL','FUNCTION','ROLLUP')
         AND     b.metric_category                   = 902 ;
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
		NULL;
    WHEN OTHERS THEN
         	ams_utility_pvt.write_conc_log('FROM REVENUE SELECT SQL ' || sqlerrm(sqlcode));
		RAISE FND_API.G_EXC_ERROR;
    END;


    BEGIN
         UPDATE bim_r_even_daily_facts
         SET   actual_cost         = l_oneoff_actual_cost
              ,forecasted_cost     = l_oneoff_forecasted_cost
              ,actual_revenue      = l_oneoff_actual_revenue
              ,forecasted_revenue  = l_oneoff_forecasted_revenue
         WHERE event_header_id 	   = y.event_header_id
         AND   event_offer_id      = y.event_offer_id
         AND  transaction_create_date  = y.max_date;
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
		NULL;
    WHEN OTHERS THEN
         	ams_utility_pvt.write_conc_log('EVENT:FIRST_LOAD: EXCEPTION FOR UPDATE FOR COST AND REVENUE' || sqlerrm(sqlcode));
		RAISE FND_API.G_EXC_ERROR;
    END;

   END LOOP;

   END;


 /********************** END OF UPDATING THE ONE-OFF EVENT OFFERS ***************************/



	l_temp_msg := to_char( sysdate, 'dd/mm/yyyy:hh:mi:ss');
    ams_utility_pvt.write_conc_log('EVENT:FIRST_LOAD: END UPDATE FOR COST AND REVENUE.' || l_temp_msg);
commit;

   --insert into bim_r_even_weekly_facts table
  BEGIN
   l_table_name :='bim_r_even_weekly_facts';

   EXECUTE IMMEDIATE 'ALTER SEQUENCE '||l_schema||'.bim_r_even_weekly_facts_s CACHE 1000';

	l_temp_msg := to_char( sysdate, 'dd/mm/yyyy:hh:mi:ss');
    ams_utility_pvt.write_conc_log('EVENT:FIRST_LOAD: BEFORE INSERT INTO WEEKLY FACTS TABLE.' || l_temp_msg);

   INSERT /*+ append */ INTO
      bim_r_even_weekly_facts ewf(
             event_weekly_transaction_id
	     ,creation_date
	     ,last_update_date
	     ,created_by
	     ,last_updated_by
	     ,last_update_login
	     ,event_header_id
	     ,event_offer_id
	     ,parent_id
	     ,source_code
	     ,start_date
	     ,end_date
	     ,country
	     ,business_unit_id
	     ,org_id
         ,event_type
	     ,event_offer_type
	     ,status
	     ,event_venue_id
	     ,registrations
	     ,cancellations
	     ,leads_open
         ,leads_closed
         ,leads_open_amt
         ,leads_closed_amt
		 ,leads_new
	     ,leads_new_amt
	     ,leads_converted
	     ,leads_hot
	     ,metric1 --leads_dead
	     ,opportunities
         ,opportunity_amt
	     ,attendance
	     ,forecasted_cost
	     ,actual_cost
	     ,forecasted_revenue
		 ,actual_revenue
	     ,customer
	     ,currency_code
	     ,transaction_create_date
         ,hdr_source_code
         ,order_amt
	     ,budget_requested
	     ,budget_approved
	     ,delete_flag
		 ,month
		 ,qtr
		 ,year
		 ,booked_orders
		 ,booked_orders_amt
	     )
     SELECT
     /*+ parallel(INNER, 4) */
            bim_r_even_weekly_facts_s.nextval
	     ,sysdate
	     ,sysdate
	     ,l_user_id
	     ,l_user_id
	     ,l_user_id
	     ,inner.event_header_id
	     ,inner.event_offer_id
	     ,inner.parent_id
	     ,inner.source_code
	     ,inner.start_date
	     ,inner.end_date
	     ,inner.country
	     ,inner.business_unit_id
	     ,inner.org_id
         ,inner.event_type
	     ,inner.event_offer_type
	     ,inner.status
	     ,inner.event_venue_id
	     ,inner.registrations
	     ,inner.cancellations
	     ,inner.leads_open
         ,inner.leads_closed
         ,inner.leads_open_amt
         ,inner.leads_closed_amt
		 ,inner.leads_new
	     ,inner.leads_new_amt
	     ,inner.leads_converted
	     ,inner.leads_hot
	     ,inner.leads_dead
	     ,inner.opportunities
         ,inner.opportunity_amt
	     ,inner.attendance
         ,inner.forecasted_cost
		 ,inner.actual_cost
		 ,inner.forecasted_revenue
		 ,inner.actual_revenue
	     ,inner.customer
	     ,inner.currency_code
	     ,inner.load_date
         ,inner.hdr_source_code
         ,inner.order_amt
         ,inner.budget_requested
         ,inner.budget_approved
	     ,inner.delete_flag
		 ,inner.month
		 ,inner.qtr
		 ,inner.year
		 ,inner.booked_orders
		 ,inner.booked_orders_amt
     FROM (SELECT event_header_id event_header_id
	     ,event_offer_id event_offer_id
	     ,parent_id parent_id
	     ,source_code source_code
	     ,start_date start_date
	     ,end_date end_date
	     ,country country
	     ,business_unit_id business_unit_id
	     ,org_id org_id
         ,event_type event_type
	     ,event_offer_type event_offer_type
	     ,status status
	     ,event_venue_id event_venue_id
		 ,currency_code currency_code
	     ,load_date load_date
		 ,hdr_source_code hdr_source_code
	     ,SUM(registrations) registrations
	     ,SUM(cancellations) cancellations
	     ,SUM(leads_open) leads_open
         ,SUM(leads_closed) leads_closed
         ,SUM(leads_open_amt) leads_open_amt
         ,SUM(leads_closed_amt) leads_closed_amt
		 ,SUM(leads_new) leads_new
	     ,SUM(leads_new_amt) leads_new_amt
	     ,SUM(leads_converted) leads_converted
	     ,SUM(leads_hot) leads_hot
	     ,SUM(metric1) leads_dead
	     ,SUM(opportunities) opportunities
         ,SUM(opportunity_amt) opportunity_amt
	     ,SUM(attendance) attendance
	     ,SUM(customer) customer
		 ,sum(forecasted_cost) forecasted_cost
		 ,sum(actual_cost) actual_cost
		 ,sum(forecasted_revenue) forecasted_revenue
		 ,sum(actual_revenue) actual_revenue
         ,SUM(order_amt) order_amt
         ,SUM(budget_requested) budget_requested
         ,SUM(budget_approved) budget_approved
	     ,delete_flag delete_flag
		 ,month
		 ,qtr
		 ,year
		 ,sum(booked_orders) booked_orders
		 ,sum(booked_orders_amt) booked_orders_amt
     FROM bim_r_even_daily_facts
     GROUP BY event_offer_id
	     ,load_date
	     ,event_header_id
	     ,parent_id
	     ,source_code
	     ,start_date
	     ,end_date
	     ,country
	     ,business_unit_id
	     ,org_id
         ,event_type
	     ,event_offer_type
	     ,status
	     ,event_venue_id
	     ,currency_code
	     ,delete_flag
         ,hdr_source_code
		 ,month
		 ,qtr
	     ,year
		 ,booked_orders
		 ,booked_orders_amt) inner;
    l_temp_msg := to_char( sysdate, 'dd/mm/yyyy:hh:mi:ss');
    ams_utility_pvt.write_conc_log('EVENT:FIRST_LOAD: AFTER INSERT INTO WEEKLY FACTS.' || l_temp_msg);
COMMIT;

/* If there are some data insert into bim_r_even_daily_facts and bim_r_even_weekly_facts, then insert a record into bim_rep_history*/

  --IF SQL%ROWCOUNT >0 THEN

  LOG_HISTORY(
	    'EVENT',
		p_start_datel,
		p_end_datel,
	    x_msg_count ,
	    x_msg_data ,
	    x_return_status

        );
   --END IF;

       EXECUTE IMMEDIATE 'ALTER SEQUENCE '||l_schema||'.bim_r_even_daily_facts_s CACHE 20';
       EXECUTE IMMEDIATE 'ALTER TABLE '||l_schema||'.bim_r_even_daily_facts nologging';

   ams_utility_pvt.write_conc_log('End of Events Facts Program -- First Load');

    EXCEPTION
    WHEN NO_DATA_FOUND THEN
    null;
	ams_utility_pvt.write_conc_log('When no data found in weekly insert in first load. '||sqlerrm(sqlcode));

	RAISE FND_API.G_EXC_ERROR;
     WHEN OTHERS THEN

   EXECUTE IMMEDIATE 'ALTER SEQUENCE '||l_schema||'.bim_r_even_weekly_facts_s CACHE 20';

     x_return_status := FND_API.G_RET_STS_ERROR;
	FND_MESSAGE.Set_Name ('AMS', 'AMS_REP_INSERT_ERROR');
	FND_MESSAGE.Set_token('table_name', l_table_name, FALSE);
	FND_MSG_PUB.Add;
	ams_utility_pvt.write_conc_log('EVENT:FIRST_LOAD: EXCEPTION FOR INSERT INTO WEEKLY FACTS. '||sqlerrm(sqlcode));
	RAISE FND_API.G_EXC_ERROR;
    END;

-- analyze the BIM_R_EVEN_WEEKLY_FACTS with dbms_stats
BEGIN
   DBMS_STATS.gather_table_stats('BIM','BIM_R_EVEN_WEEKLY_FACTS', estimate_percent => 5,
                                  degree => 8, granularity => 'GLOBAL', cascade =>TRUE);
END;

    /* Piece of Code for Recreating the index on the same tablespace with the same storage parameters */
	BEGIN
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
	EXCEPTION
	WHEN OTHERS THEN
		-- DBMS_OUTPUT.PUT_LINE(sqlerrm(sqlcode));
		ams_utility_pvt.write_conc_log('Exception for creating index for first load. '||sqlerrm(sqlcode));
		RAISE FND_API.G_EXC_ERROR;
		NULL;
	END;

	EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_msg_PUB.Count_And_Get (
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

    ams_utility_pvt.write_conc_log('EXPECTED EXCEPTION '||sqlerrm(sqlcode));
	RAISE FND_API.G_EXC_ERROR;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     -- Standard call to get message count and if count=1, get the message
     FND_msg_PUB.Count_And_Get (
            --p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

    ams_utility_pvt.write_conc_log('UNEXPECTED EXCEPTION '||sqlerrm(sqlcode));
	RAISE FND_API.G_EXC_ERROR;

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

    ams_utility_pvt.write_conc_log('OTHERS EXCEPTION '||sqlerrm(sqlcode));
    ams_utility_pvt.write_conc_log('Before end of event_first_load for first load. ');
	RAISE FND_API.G_EXC_ERROR;
END EVENT_FIRST_LOAD;


PROCEDURE EVENT_SUBSEQUENT_LOAD
    (p_start_datel        IN   DATE,
	 p_end_datel          IN   DATE,
	 p_api_version_number IN   NUMBER,
     x_msg_count          OUT  NOCOPY NUMBER       ,
     x_msg_data		      OUT  NOCOPY VARCHAR2     ,
     x_return_status	  OUT NOCOPY VARCHAR2
     )IS
l_weekndt                 DATE;
l_start_weekndt           DATE;
l_end_weekndt             DATE;
l_user_id		  NUMBER := FND_GLOBAL.USER_ID();
l_api_version_number	  CONSTANT NUMBER	:= 1.0;
l_api_name		  CONSTANT VARCHAR2(30) := 'EVENT_SUBSEQUENT_LOAD';
l_table_name		  VARCHAR2(100);
l_success   VARCHAR2(1) := 'F';
l_start_date     DATE;

CURSOR MIN_START_DATE IS
SELECT MIN(START_DATE)
FROM BIM_REP_HISTORY
WHERE OBJECT = 'EVENT';

      l_event_offer number;
      l_min_date    date;
      l_min_start_date    date;
      l_temp_msg		          VARCHAR2(100);

l_schema                      VARCHAR2(30);
l_status1                      VARCHAR2(5);
l_industry1                    VARCHAR2(5);
l_return			BOOLEAN;
BEGIN

l_return  := fnd_installation.get_app_info('BIM', l_status1, l_industry1, l_schema);

      -- Standard call to check for call compatibility.
     IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
					  l_api_version_number,
					  l_api_name,
					  G_PKG_NAME)
      THEN
	  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Debug Message
      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');

      BEGIN
      l_table_name :='bim_r_even_daily_facts';

      IF p_api_version_number = 1 THEN
            l_min_start_date := trunc(p_start_datel);
      ELSE
            OPEN  MIN_START_DATE;
            FETCH MIN_START_DATE INTO       l_min_start_date;
            CLOSE MIN_START_DATE;
      END IF;

	 l_temp_msg := to_char( sysdate, 'dd/mm/yyyy:hh:mi:ss');
     ams_utility_pvt.write_conc_log('EVENT:LOAD: BEFORE FIRST INSERT.' || l_temp_msg);
	 --Insert into bim_r_even_daily_facts on event offer level
     INSERT INTO
          bim_r_even_daily_facts ewf(
	      event_daily_transaction_id
	     ,creation_date
	     ,last_update_date
	     ,created_by
	     ,last_updated_by
	     ,last_update_login
	     ,event_header_id
	     ,event_offer_id
	     ,parent_id
	     ,source_code
		 ,hdr_source_code
	     ,start_date
	     ,end_date
	     ,country
	     ,business_unit_id
	     ,org_id
	     ,event_type
	     ,event_offer_type
	     ,status
	     ,event_venue_id
		 ,currency_code
	     ,transaction_create_date
		 ,load_date
	     ,delete_flag
         ,month
         ,qtr
         ,year
	     ,registrations
	     ,cancellations
		 ,attendance
	     ,leads_open
         ,leads_closed
         ,leads_open_amt
         ,leads_closed_amt
	     ,leads_new
	     ,leads_new_amt
	     ,leads_converted
	     ,leads_hot
	     ,metric1 --leads_dead
	     ,opportunities
         ,opportunity_amt
	     ,forecasted_cost
	     ,actual_cost
	     ,forecasted_revenue
		 ,actual_revenue
	     ,customer
	     ,budget_requested
	     ,budget_approved
		 ,booked_orders
		 ,booked_orders_amt
	     )
select
           bim_r_even_daily_facts_s.nextval,
	       sysdate,
	       sysdate,
	       l_user_id,
	       l_user_id,
	       l_user_id,
           a.event_header_id event_header_id,
	       a.event_offer_id event_offer_id,
	       a.parent_id parent_id,
	       a.source_code source_code,
           b.source_code hdr_source_code,
           a.event_start_date event_start_date,
	       a.event_end_date event_end_date,
           b.country_code country_code,
	       b.business_unit_id business_unit_id,
	       a.org_id org_id,
           b.event_type_code event_type,
	       a.event_type_code event_type_code,
           a.system_status_code system_status_code,
	       a.event_venue_id event_venue_id,
	       a.currency_code_fc currency_code_fc,
           ad.creation_date transaction_creation_date,
           (decode(decode(to_char(ad.creation_date,'MM') , to_char(next_day(ad.creation_date,TO_NUMBER(to_char(to_date('07/09/2004', 'DD/MM/RRRR'), 'DD'))),'MM') ,'TRUE','FALSE' )
                ,'TRUE'
                ,decode(decode(ad.creation_date , (next_day(ad.creation_date, TO_NUMBER(to_char(to_date('07/09/2004', 'DD/MM/RRRR'), 'DD'))) - 7) , 'TRUE' ,'FALSE')
                ,'TRUE'
                ,ad.creation_date
                ,'FALSE'
                ,next_day(ad.creation_date, TO_NUMBER(to_char(to_date('07/09/2004', 'DD/MM/RRRR'), 'DD'))))
                ,'FALSE'
                ,decode(decode(to_char(ad.creation_date,'MM'),to_char(next_day(ad.creation_date,TO_NUMBER(to_char(to_date('07/09/2004', 'DD/MM/RRRR'), 'DD'))),'MM'),'TRUE','FALSE')
                ,'FALSE'
                ,last_day(ad.creation_date)))) weekend_date,
           'N',
		   BIM_SET_OF_BOOKS.GET_FISCAL_MONTH(ad.creation_date, 204),
           BIM_SET_OF_BOOKS.GET_FISCAL_QTR(ad.creation_date, 204),
           BIM_SET_OF_BOOKS.GET_FISCAL_YEAR(ad.creation_date, 204),
           ad.registered,
		   ad.cancelled,
           ad.attended,
       	   ad.leads_open,
	       ad.leads_closed,
       	   ad.leads_open_amt,
       	   ad.leads_closed_amt,
	   	   ad.leads_new,
	   	   ad.leads_new_amt,
	   	   ad.leads_converted,
	   	   ad.leads_hot,
	   	   ad.leads_dead,
       	   ad.nooppor,
       	   ad.opportunity_amt,
           ad.forecasted_cost,
           ad.actual_cost,
           ad.forecasted_revenue,
           ad.actual_revenue,
           ad.customer,
           ad.budget_requested,
       	   ad.budget_approved,
           ad.booked_orders,
	       ad.booked_orders_amt
from (select
            event_offer_id
            ,creation_date
            ,sum(registered) registered
		    ,sum(cancelled) cancelled
        	,sum(attended) attended
       		,sum(leads_open) leads_open
	        ,sum(leads_closed) leads_closed
       		,sum(leads_open_amt) leads_open_amt
       		,sum(leads_closed_amt) leads_closed_amt
	   		,sum(leads_new) leads_new
	   		,sum(leads_new_amt) leads_new_amt
	   		,sum(leads_converted) leads_converted
	   		,sum(leads_hot) leads_hot
	   		,sum(leads_dead) leads_dead
       		,sum(nooppor) nooppor
       		,sum(opportunity_amt) opportunity_amt
       		,sum(budget_requested) budget_requested
       		,sum(budget_approved) budget_approved
       		,0 customer
            ,sum(actual_cost) actual_cost
            ,sum(forecasted_cost) forecasted_cost
            ,sum(actual_revenue) actual_revenue
            ,sum(forecasted_revenue) forecasted_revenue
            ,sum(booked_orders) booked_orders
	        ,sum(booked_orders_amt) booked_orders_amt
from ((select      event_offer_id
            ,creation_date
	        ,0  registered
		    ,0  cancelled
        	,0  attended
       		,0  leads_open
	        ,0  leads_closed
       		,0   leads_open_amt
       		,0 leads_closed_amt
	   		,0 leads_new
	   		,0 leads_new_amt
	   		,0 leads_converted
	   		,0 leads_hot
	   		,0 leads_dead
       		,0 nooppor
       		,0 opportunity_amt
       		,sum(budget_requested) budget_requested
       		,sum(budget_approved) budget_approved
       		,0 customer
            ,0 actual_cost
            ,0 forecasted_cost
            ,0 actual_revenue
            ,0 forecasted_revenue
            ,0 booked_orders
	        ,0 booked_orders_amt
from
(SELECT
               b.act_budget_used_by_id event_offer_id
               ,decode(b.status_code
				    ,'PENDING'
			             ,trunc(nvl(b.request_date,b.creation_date))
				    ,'APPROVED'
                         ,trunc(nvl(b.approval_date,b.last_update_date))
				    ) creation_date
               ,sum(decode(b.status_code
				    ,'PENDING'
                          ,convert_currency(nvl(b.request_currency,'USD'),nvl(b.request_amount,0))
				    ,'APPROVED'
                         ,- convert_currency(nvl(b.request_currency,'USD'),nvl(b.request_amount,0))
			        ))  budget_requested
               ,sum(decode(b.status_code
				    ,'PENDING'
                         ,0
				    ,'APPROVED'
                         ,convert_currency(nvl(b.approved_in_currency,'USD'),nvl(b.approved_original_amount,0))
                           ))    budget_approved
       FROM   ozf_act_budgets  B
       WHERE  b.arc_act_budget_used_by in ('EVEO', 'EONE')
      -- AND    b.transfer_type = 'REQUEST'
	   AND    b.budget_source_type ='FUND'
       GROUP BY b.act_budget_used_by_id,
	                decode(b.status_code
				    ,'PENDING'
			             ,trunc(nvl(b.request_date,b.creation_date))
				    ,'APPROVED'
                         ,trunc(nvl(b.approval_date,b.last_update_date)))
	   UNION ALL
	   SELECT
                b.budget_source_id event_offer_id,
                trunc(nvl(b.approval_date,b.last_update_date))  creation_date,
				0, --budget_requested
                0-SUM(convert_currency(b.approved_in_currency,nvl(b.approved_original_amount,0))) budget_approved
       FROM     ozf_act_budgets  B
       WHERE    b.arc_act_budget_used_by ='FUND'
       --AND      transfer_type in ('TRANSFER','REQUEST')
       AND      status_code ='APPROVED'
	   AND      b.budget_source_type in ('EVEO', 'EONE')
       GROUP BY b.budget_source_id, trunc(nvl(b.approval_date,b.last_update_date)))
       where creation_date between p_start_datel and p_end_datel + 0.9999
       group by event_offer_id
            ,creation_date) --BUDGET
UNION ALL --Added by amy, for event offer cost and revenue
	(SELECT f1.act_metric_used_by_id event_offer_id
	    ,trunc(f1.last_update_date)  creation_date
            ,0 				registered
	    ,0 				cancelled
            ,0 				attended
       	    ,0 				leads_open
	    ,0 				leads_closed
       	    ,0  			leads_open_amt
       	    ,0 				leads_closed_amt
	    ,0 				leads_new
	    ,0 				leads_new_amt
	    ,0 				leads_converted
	    ,0 				leads_hot
	    ,0 				leads_dead
            ,0                          opportunities
            ,0                          opportunity_amt
       	    ,0				budget_requested
       	    ,0				budget_approved
       	    ,0			        customer
            ,0				actual_cost
            ,0 				forecasted_cost
	    ,sum(convert_currency(nvl(f1.functional_currency_code,'USD'),nvl(f1.func_actual_delta,0)))  	actual_revenue
            ,sum(convert_currency(nvl(f1.functional_currency_code,'USD'),nvl(f1.func_forecasted_delta,0))) 	forecasted_revenue
            ,0 				booked_orders
	    ,0 				booked_orders_amt
	FROM 	 ams_act_metric_hst            f1
                ,ams_metrics_all_b		g1
        WHERE  f1.arc_act_metric_used_by      = 'EVEO'
        AND    g1.metric_category              = 902
        AND    g1.metric_id                   = f1.metric_id
        and    trunc(f1.last_update_date) between p_start_datel and p_end_datel + 0.9999
        AND    g1.metric_calculation_type       IN ('MANUAL','FUNCTION','ROLLUP')
	group by f1.act_metric_used_by_id
		  ,trunc(f1.last_update_date)
        having sum(convert_currency(nvl(f1.functional_currency_code,'USD'),nvl(f1.func_actual_delta,0)))<>0
	or sum(convert_currency(nvl(f1.functional_currency_code,'USD'),nvl(f1.func_forecasted_delta,0)))<>0  )
     UNION ALL
     (SELECT f1.act_metric_used_by_id event_offer_id
	    ,trunc(f1.last_update_date)  creation_date
            ,0 				registered
	    ,0 				cancelled
            ,0 				attended
       	    ,0 				leads_open
	    ,0 				leads_closed
       	    ,0  			leads_open_amt
       	    ,0 				leads_closed_amt
	    ,0 				leads_new
	    ,0 				leads_new_amt
	    ,0 				leads_converted
	    ,0 				leads_hot
	    ,0 				leads_dead
            ,0                          opportunities
            ,0                          opportunity_amt
       	    ,0				budget_requested
       	    ,0				budget_approved
       	    ,0			        customer
            ,sum(convert_currency(nvl(f1.functional_currency_code,'USD'),nvl(f1.func_actual_delta,0)))  	actual_cost
            ,sum(convert_currency(nvl(f1.functional_currency_code,'USD'),nvl(f1.func_forecasted_delta,0))) 	forecasted_cost
	    ,0                          actual_revenue
            ,0                          forecasted_revenue
            ,0 				booked_orders
	    ,0 				booked_orders_amt
	FROM 	 ams_act_metric_hst            f1
                ,ams_metrics_all_b		g1
        WHERE  f1.arc_act_metric_used_by      = 'EVEO'
        AND    g1.metric_category              = 901
        AND    g1.metric_id                   = f1.metric_id
        and    trunc(f1.last_update_date) between p_start_datel and p_end_datel + 0.9999
        AND    g1.metric_calculation_type       IN ('MANUAL','FUNCTION','ROLLUP')
	group by f1.act_metric_used_by_id
		  ,trunc(f1.last_update_date)
	having sum(convert_currency(nvl(f1.functional_currency_code,'USD'),nvl(f1.func_actual_delta,0)))<>0
	or sum(convert_currency(nvl(f1.functional_currency_code,'USD'),nvl(f1.func_forecasted_delta,0)))<>0 )
UNION ALL
 (SELECT
            c.event_offer_id
            ,trunc(a.creation_date) creation_date
            ,0 registered
		    ,0 cancelled
        	,0 attended
       		,0 leads_open
	        ,0 leads_closed
       		,0  leads_open_amt
       		,0 leads_closed_amt
	   		,0 leads_new
	   		,0 leads_new_amt
	   		,0 leads_converted
	   		,0 leads_hot
	   		,0 leads_dead
            ,COUNT(A.lead_id) opportunities
            ,SUM(convert_currency(nvl(currency_code, 'USD'), nvl(A.total_amount, 0))) opportunity_amt
       		,0--budget_requested
       		,0--budget_approved
       		,0-- customer
            ,0--actual_cost
            ,0 --forecasted_cost
            ,0 --actual_revenue
            ,0 --forecasted_revenue
            ,0 booked_orders
	        ,0 booked_orders_amt
       FROM    as_leads_all A,
               ams_event_offers_all_b C,
	           ams_source_codes E
       where   e.source_code_for_id = c.event_offer_id
       and     e.source_code_id = a.source_promotion_id
       and     e.arc_source_code_for in ('EONE','EVEO')
       and     trunc(a.creation_date) between p_start_datel and p_end_datel + 0.9999
       GROUP BY c.event_offer_id,trunc(a.creation_date),
       e.source_code_id) --OPPORTUNITY
UNION ALL
       (SELECT
	           c.event_offer_id
               ,trunc(decode(b.OPP_OPEN_STATUS_FLAG,'Y',a.creation_date,a.last_update_date)) creation_date
               ,0-- registered
		       ,0-- cancelled
        	   ,0-- attended
               ,sum(decode(b.OPP_OPEN_STATUS_FLAG,'Y',1,0)) leads_open
	           ,sum(decode(b.OPP_OPEN_STATUS_FLAG,'Y',0,1)) leads_closed
               ,sum(decode(b.OPP_OPEN_STATUS_FLAG,'Y',convert_currency(nvl(a.currency_code,'USD'),nvl(a.budget_amount,0)),0)) leads_open_amt
	       ,sum(decode(b.OPP_OPEN_STATUS_FLAG,'Y',0,convert_currency(nvl(a.currency_code,'USD'),nvl(a.budget_amount,0)))) leads_closed_amt
			   ,sum(decode(b.OPP_OPEN_STATUS_FLAG,'Y',decode(a.status_code,'NEW',1,0),0)) leads_new
               ,sum(decode(b.OPP_OPEN_STATUS_FLAG,'Y',decode(a.status_code,'NEW',convert_currency(nvl(a.currency_code,'USD'),nvl(a.budget_amount,0)),0),0)) leads_new_amt
               ,sum(decode(b.OPP_OPEN_STATUS_FLAG,'N',decode(a.status_code,'CONVERTED_TO_OPPORTUNITY',1,0),0)) leads_converted
               ,sum(decode(b.OPP_OPEN_STATUS_FLAG,'Y',decode(a.lead_rank_id,10000,1,0),0)) leads_hot
               ,sum(decode(b.OPP_OPEN_STATUS_FLAG,'Y',0,decode(a.status_code,'DEAD_LEAD',1,0))) leads_dead
               ,0-- nooppor,
       		   ,0-- opportunity_amt,
       		   ,0 --budget_requested
       		   ,0 --budget_approved
       		   ,0-- customer
               ,0--actual_cost
               ,0 --forecasted_cost
               ,0 --actual_revenue
               ,0 --forecasted_revenue
               ,0 booked_orders
	           ,0 booked_orders_amt
       FROM    as_sales_leads A,
	           as_statuses_b B,
               ams_event_offers_all_b C,
	           ams_source_codes E
       WHERE   e.source_code_for_id = c.event_offer_id
       and     e.source_code_id = a.source_promotion_id
       and     a.status_code = b.status_code
       and     e.arc_source_code_for in ('EONE','EVEO')
	   AND     b.lead_flag = 'Y'
	   AND     b.enabled_flag = 'Y'
	   AND     NVL(a.DELETED_FLAG,'N') <> 'Y'
       and     trunc(decode(b.OPP_OPEN_STATUS_FLAG,'Y',a.creation_date,a.last_update_date)) between p_start_datel and p_end_datel + 0.9999
       GROUP BY c.event_offer_id,
                trunc(decode(b.OPP_OPEN_STATUS_FLAG,'Y',a.creation_date,a.last_update_date)),
                e.source_code_id) --LEADS
UNION ALL
     (SELECT
		     A.event_offer_id event_offer_id
	        ,trunc(A.last_reg_status_date)  creation_date
		    ,SUM(decode(A.system_status_code,'REGISTERED',1,'CANCELLED',1,0)) registered
		    ,SUM(decode(A.system_status_code,'CANCELLED',1,0)) cancelled
        	,SUM(decode(A.system_status_code,'REGISTERED',decode(attended_flag,'Y',1,0),0)) attended
       		,0-- leads_open,
	        ,0-- leads_closed,
       		,0--  leads_open_amt,
       		,0-- leads_closed_amt,
	   		,0-- leads_new,
	   		,0-- leads_new_amt,
	   		,0-- leads_converted,
	   		,0-- leads_hot,
	   		,0-- leads_dead,
       		,0-- nooppor,
       		,0-- opportunity_amt,
       		,0-- budget_requested,
       		,0-- budget_approved,
       		,0-- customer
            ,0--actual_cost
            ,0 --forecasted_cost
            ,0 --actual_revenue
            ,0 --forecasted_revenue
            ,0 booked_orders
	        ,0 booked_orders_amt
      FROM	 ams_event_registrations A
      where  trunc(A.last_reg_status_date) between p_start_datel and p_end_datel + 0.9999
      GROUP BY	 A.event_offer_id,
        	 trunc(A.last_reg_status_date)) --REGISTRATION
   union all
     (select
	           b.event_offer_id,
               trunc(i.creation_date) creation_date
               ,0  registered
		    ,0  cancelled
        	,0  attended
       		,0  leads_open
	        ,0  leads_closed
       		,0  leads_open_amt
       		,0 leads_closed_amt
	   		,0 leads_new
	   		,0 leads_new_amt
	   		,0 leads_converted
	   		,0 leads_hot
	   		,0 leads_dead
       		,0 nooppor
       		,0 opportunity_amt
       		,0 budget_requested
       		,0 budget_approved
       		,0 customer
            ,0 actual_cost
            ,0 forecasted_cost
            ,0 actual_revenue
            ,0 forecasted_revenue
               ,count(distinct(h.header_id))  booked_orders
               ,sum(decode(h.flow_status_code,'BOOKED',convert_currency(nvl(H.transactional_curr_code,'USD'),
			       nvl(I.unit_selling_price * I.ordered_quantity,0)),0)) booked_orders_amt
       from    ams_event_offers_all_b B,
               ams_source_codes C ,
               as_sales_leads D,
               as_sales_lead_opportunity A,
               as_leads_all E,
               aso_quote_related_objects F,
               aso_quote_headers_all G,
               oe_order_headers_all H,
               oe_order_lines_all I
      where    c.source_code_id = d.source_promotion_id
      and      c.source_code_for_id = b.event_offer_id
      and      c.arc_source_code_for in ('EONE','EVEO')
      and      a.sales_lead_id = d.sales_lead_id
      and      a.opportunity_id = e.lead_id
      and      f.object_id = e.lead_id
      and      f.relationship_type_code = 'OPP_QUOTE'
      and      f.quote_object_type_code = 'HEADER'
      and      f.quote_object_id = g.quote_header_id
      and      g.order_id = h.header_id
      and      NVL(D.deleted_flag,'N') <> 'Y'
      and      h.flow_status_code = 'BOOKED'
      AND      H.header_id = I.header_id
          and      trunc(i.creation_date) between p_start_datel and p_end_datel + 0.9999
      group by b.event_offer_id
                   ,trunc(i.creation_date)) --orders
    )
   group by event_offer_id ,
            creation_date) AD,
   ams_event_offers_all_b A,
   ams_event_headers_all_b B,
   ams_source_codes E
   where
   e.source_code = a.source_code
   AND   a.event_header_id = b.event_header_id
   --AND   trunc(b.active_from_date)  >= trunc(l_min_start_date)
   AND   a.system_status_code in ('ACTIVE', 'CANCELLED','COMPLETED','CLOSED')
   and   ad.event_offer_id = a.event_offer_id
   --and   ad.creation_date is not null
   ;
	 l_temp_msg := to_char( sysdate, 'dd/mm/yyyy:hh:mi:ss');
     ams_utility_pvt.write_conc_log('EVENT:LOAD: AFTER FIRST INSERT.' || l_temp_msg);
commit;

---------------------------------------------------------------------------------
/* This piece of code picks up the leads,opportunities,budget amounts,attended,registered,cancelled
for the one-off event offers */

     l_temp_msg := to_char( sysdate, 'dd/mm/yyyy:hh:mi:ss');
     ams_utility_pvt.write_conc_log('EVENT:LOAD: BEFORE SECOND INSERT.' || l_temp_msg);
     --Insert into bim_r_even_daily_facts for one-off event offer level

     INSERT INTO
          bim_r_even_daily_facts ewf(
	      event_daily_transaction_id
	     ,creation_date
	     ,last_update_date
	     ,created_by
	     ,last_updated_by
	     ,last_update_login
	     ,event_header_id
	     ,event_offer_id
	     ,parent_id
	     ,source_code
             ,hdr_source_code
	     ,start_date
	     ,end_date
	     ,country
	     ,business_unit_id
	     ,org_id
	     ,event_type
	     ,event_offer_type
	     ,status
	     ,event_venue_id
	     ,currency_code
	     ,transaction_create_date
	     ,load_date
	     ,delete_flag
             ,month
             ,qtr
             ,year
	     ,registrations
	     ,cancellations
	     ,attendance
	     ,leads_open
             ,leads_closed
             ,leads_open_amt
             ,leads_closed_amt
	     ,leads_new
	     ,leads_new_amt
	     ,leads_converted
	     ,leads_hot
	     ,metric1 --leads_dead
	     ,opportunities
             ,opportunity_amt
	     ,forecasted_cost
	     ,actual_cost
	     ,forecasted_revenue
	     ,actual_revenue
	     ,customer
	     ,budget_requested
	     ,budget_approved
	     ,booked_orders
	     ,booked_orders_amt
	     )
     SELECT
             bim_r_even_daily_facts_s.nextval,
	     sysdate,
	     sysdate,
	     l_user_id,
	     l_user_id,
	     l_user_id,
             -999  event_header_id,
	     a.event_offer_id event_offer_id,
	     a.parent_id parent_id,
	     a.source_code source_code,
             NULL hdr_source_code,
             a.event_start_date event_start_date,
	     a.event_end_date event_end_date,
             a.country_code country_code,
	     a.business_unit_id business_unit_id,
	     a.org_id org_id,
             a.event_type_code event_type,
	     a.event_type_code event_type_code,
             a.system_status_code system_status_code,
	     a.event_venue_id event_venue_id,
	     a.currency_code_fc currency_code_fc,
             ad.creation_date transaction_creation_date,
           	(decode(decode(to_char(ad.creation_date,'MM') , to_char(next_day(ad.creation_date,TO_NUMBER(to_char(to_date('07/09/2004', 'DD/MM/RRRR'), 'DD'))),'MM') ,'TRUE','FALSE' )
                ,'TRUE'
                ,decode(decode(ad.creation_date , (next_day(ad.creation_date, TO_NUMBER(to_char(to_date('07/09/2004', 'DD/MM/RRRR'), 'DD'))) - 7) , 'TRUE' ,'FALSE')
                ,'TRUE'
                ,ad.creation_date
                ,'FALSE'
                ,next_day(ad.creation_date, TO_NUMBER(to_char(to_date('07/09/2004', 'DD/MM/RRRR'), 'DD'))))
                ,'FALSE'
                ,decode(decode(to_char(ad.creation_date,'MM'),to_char(next_day(ad.creation_date,TO_NUMBER(to_char(to_date('07/09/2004', 'DD/MM/RRRR'), 'DD'))),'MM'),'TRUE','FALSE')
                ,'FALSE'
                ,last_day(ad.creation_date)))) weekend_date,
             'N',
	     bim_set_of_books.get_fiscal_month(ad.creation_date, 204),
             bim_set_of_books.get_fiscal_qtr(ad.creation_date, 204),
             bim_set_of_books.get_fiscal_year(ad.creation_date, 204),
             ad.registered,
	     ad.cancelled,
             ad.attended,
       	     ad.leads_open,
	     ad.leads_closed,
       	     ad.leads_open_amt,
       	     ad.leads_closed_amt,
	     ad.leads_new,
	     ad.leads_new_amt,
	     ad.leads_converted,
	     ad.leads_hot,
	     ad.leads_dead,
       	     ad.nooppor,
       	     ad.opportunity_amt,
             ad.forecasted_cost,
             ad.actual_cost,
             ad.forecasted_revenue,
             ad.actual_revenue,
             ad.customer,
             ad.budget_requested,
       	     ad.budget_approved,
             ad.booked_orders,
	     ad.booked_orders_amt
     FROM (SELECT
             event_offer_id
            ,creation_date
            ,sum(registered) registered
	    ,sum(cancelled) cancelled
            ,sum(attended) attended
       	    ,sum(leads_open) leads_open
	    ,sum(leads_closed) leads_closed
       	    ,sum(leads_open_amt) leads_open_amt
       	    ,sum(leads_closed_amt) leads_closed_amt
	    ,sum(leads_new) leads_new
	    ,sum(leads_new_amt) leads_new_amt
	    ,sum(leads_converted) leads_converted
	    ,sum(leads_hot) leads_hot
	    ,sum(leads_dead) leads_dead
       	    ,sum(nooppor) nooppor
       	    ,sum(opportunity_amt) opportunity_amt
            ,sum(budget_requested) budget_requested
       	    ,sum(budget_approved) budget_approved
       	    ,0 customer
            ,sum(actual_cost) actual_cost
            ,sum(forecasted_cost) forecasted_cost
            ,sum(actual_revenue) actual_revenue
            ,sum(forecasted_revenue) forecasted_revenue
            ,sum(booked_orders) booked_orders
	    ,sum(booked_orders_amt) booked_orders_amt
     FROM ((
	SELECT
	     event_offer_id		event_offer_id
            ,creation_date		creation_date
	    ,0  			registered
	    ,0  			cancelled
            ,0  			attended
       	    ,0  			leads_open
	    ,0  			leads_closed
       	    ,0   			leads_open_amt
       	    ,0 				leads_closed_amt
	    ,0 				leads_new
	    ,0 				leads_new_amt
	    ,0 				leads_converted
	    ,0 				leads_hot
	    ,0 				leads_dead
       	    ,0 				nooppor
       	    ,0 				opportunity_amt
       	    ,sum(budget_requested) 	budget_requested
       	    ,sum(budget_approved) 	budget_approved
       	    ,0 				customer
            ,0 				actual_cost
            ,0 				forecasted_cost
            ,0 				actual_revenue
            ,0 				forecasted_revenue
            ,0 				booked_orders
	    ,0 				booked_orders_amt
     FROM
 	(SELECT
             b.act_budget_used_by_id 	event_offer_id
            ,decode(b.status_code
			    ,'PENDING'
		            ,trunc(nvl(b.request_date,b.creation_date))
			    ,'APPROVED'
                            ,trunc(nvl(b.approval_date,b.last_update_date))
			    ) 		creation_date
            ,sum(decode(b.status_code
				    ,'PENDING'
                          ,convert_currency(nvl(b.request_currency,'USD'),nvl(b.request_amount,0))
				    ,'APPROVED'
                         ,- convert_currency(nvl(b.request_currency,'USD'),nvl(b.request_amount,0))
			        ))  	budget_requested
            ,sum(decode(b.status_code
				    ,'PENDING'
                         ,0
				    ,'APPROVED'
                         ,convert_currency(nvl(b.approved_in_currency,'USD'),nvl(b.approved_original_amount,0))
                           ))    	budget_approved
         FROM   ozf_act_budgets  b
		,ams_event_offers_all_b a
         WHERE  b.arc_act_budget_used_by in ('EONE')
	 AND    b.budget_source_type ='FUND'
	 AND 	a.event_offer_id = b.act_budget_used_by_id
	 AND    a.event_header_id  is null
	 AND   (parent_type is null or parent_type = 'RCAM')
         GROUP BY b.act_budget_used_by_id,
	                decode(b.status_code
				    ,'PENDING'
			             ,trunc(nvl(b.request_date,b.creation_date))
				    ,'APPROVED'
                         ,trunc(nvl(b.approval_date,b.last_update_date)))
	 UNION ALL
	 SELECT
                b.budget_source_id 	event_offer_id,
                trunc(nvl(b.approval_date,b.last_update_date))  creation_date,
		0, --budget_requested
                0-SUM(convert_currency(b.approved_in_currency,nvl(b.approved_original_amount,0))) budget_approved
       	 FROM     ozf_act_budgets  B
		,ams_event_offers_all_b a
         WHERE    b.arc_act_budget_used_by ='FUND'
         AND      status_code ='APPROVED'
	 AND      b.budget_source_type in ('EONE')
         AND    a.event_offer_id = b.act_budget_used_by_id
         AND    a.event_header_id  is null
         AND   (parent_type is null or parent_type = 'RCAM')
         GROUP BY b.budget_source_id, trunc(nvl(b.approval_date,b.last_update_date))
	)
        WHERE creation_date between p_start_datel and p_end_datel + 0.9999
        GROUP BY event_offer_id ,creation_date)
	UNION ALL --Added by amy, for EONE cost and revenue
	(SELECT f1.act_metric_used_by_id event_offer_id
	    ,trunc(f1.last_update_date)  creation_date
            ,0 				registered
	    ,0 				cancelled
            ,0 				attended
       	    ,0 				leads_open
	    ,0 				leads_closed
       	    ,0  			leads_open_amt
       	    ,0 				leads_closed_amt
	    ,0 				leads_new
	    ,0 				leads_new_amt
	    ,0 				leads_converted
	    ,0 				leads_hot
	    ,0 				leads_dead
            ,0                          opportunities
            ,0                          opportunity_amt
       	    ,0				budget_requested
       	    ,0				budget_approved
       	    ,0			        customer
            ,0				actual_cost
            ,0 				forecasted_cost
	    ,sum(convert_currency(nvl(f1.functional_currency_code,'USD'),nvl(f1.func_actual_delta,0)))  	actual_revenue
            ,sum(convert_currency(nvl(f1.functional_currency_code,'USD'),nvl(f1.func_forecasted_delta,0))) 	forecasted_revenue
            ,0 				booked_orders
	    ,0 				booked_orders_amt
	FROM 	 ams_act_metric_hst            f1
                ,ams_metrics_all_b		g1
        WHERE  f1.arc_act_metric_used_by      = 'EONE'
        AND    g1.metric_category              = 902
        AND    g1.metric_id                   = f1.metric_id
        and    trunc(f1.last_update_date) between p_start_datel and p_end_datel + 0.9999
        AND    g1.metric_calculation_type       IN ('MANUAL','FUNCTION','ROLLUP')
	group by f1.act_metric_used_by_id
		  ,trunc(f1.last_update_date)
        having sum(convert_currency(nvl(f1.functional_currency_code,'USD'),nvl(f1.func_actual_delta,0)))<>0
	or sum(convert_currency(nvl(f1.functional_currency_code,'USD'),nvl(f1.func_forecasted_delta,0)))<>0  )
     UNION ALL
     (SELECT f1.act_metric_used_by_id event_offer_id
	    ,trunc(f1.last_update_date)  creation_date
            ,0 				registered
	    ,0 				cancelled
            ,0 				attended
       	    ,0 				leads_open
	    ,0 				leads_closed
       	    ,0  			leads_open_amt
       	    ,0 				leads_closed_amt
	    ,0 				leads_new
	    ,0 				leads_new_amt
	    ,0 				leads_converted
	    ,0 				leads_hot
	    ,0 				leads_dead
            ,0                          opportunities
            ,0                          opportunity_amt
       	    ,0				budget_requested
       	    ,0				budget_approved
       	    ,0			        customer
            ,sum(convert_currency(nvl(f1.functional_currency_code,'USD'),nvl(f1.func_actual_delta,0)))  	actual_cost
            ,sum(convert_currency(nvl(f1.functional_currency_code,'USD'),nvl(f1.func_forecasted_delta,0))) 	forecasted_cost
	    ,0                          actual_revenue
            ,0                          forecasted_revenue
            ,0 				booked_orders
	    ,0 				booked_orders_amt
	FROM 	 ams_act_metric_hst            f1
                ,ams_metrics_all_b		g1
        WHERE  f1.arc_act_metric_used_by      = 'EONE'
        AND    g1.metric_category              = 901
        AND    g1.metric_id                   = f1.metric_id
        and    trunc(f1.last_update_date) between p_start_datel and p_end_datel + 0.9999
        AND    g1.metric_calculation_type       IN ('MANUAL','FUNCTION','ROLLUP')
	group by f1.act_metric_used_by_id
		  ,trunc(f1.last_update_date)
	having sum(convert_currency(nvl(f1.functional_currency_code,'USD'),nvl(f1.func_actual_delta,0)))<>0
	or sum(convert_currency(nvl(f1.functional_currency_code,'USD'),nvl(f1.func_forecasted_delta,0)))<>0 )
     UNION ALL
 	(SELECT
             c.event_offer_id		event_offer_id
            ,trunc(a.creation_date)  	creation_date
            ,0 				registered
	    ,0 				cancelled
            ,0 				attended
       	    ,0 				leads_open
	    ,0 				leads_closed
       	    ,0  			leads_open_amt
       	    ,0 				leads_closed_amt
	    ,0 				leads_new
	    ,0 				leads_new_amt
	    ,0 				leads_converted
	    ,0 				leads_hot
	    ,0 				leads_dead
            ,count(A.lead_id) 		opportunities
            ,sum(convert_currency(nvl(currency_code, 'USD'), nvl(A.total_amount, 0))) opportunity_amt
       	    ,0				budget_requested
       	    ,0				budget_approved
       	    ,0			        customer
            ,0				actual_cost
            ,0 				forecasted_cost
            ,0 				actual_revenue
            ,0 				forecasted_revenue
            ,0 				booked_orders
	    ,0 				booked_orders_amt
       FROM    as_leads_all A,
               ams_event_offers_all_b C,
	       ams_source_codes E
       WHERE   e.source_code_for_id = c.event_offer_id
       AND     c.event_standalone_flag = 'Y'
       AND     (c.parent_type is null or c.parent_type ='RCAM')
       AND     e.source_code_id = a.source_promotion_id
       AND     e.arc_source_code_for in ('EONE')
       AND     trunc(a.creation_date) between p_start_datel and p_end_datel + 0.9999
       GROUP BY c.event_offer_id,trunc(a.creation_date),e.source_code_id)
     UNION ALL
       (SELECT
	           c.event_offer_id
            ,trunc(decode(b.OPP_OPEN_STATUS_FLAG,'Y',a.creation_date,a.last_update_date)) creation_date
            ,0				 registered
	    ,0				 cancelled
            ,0				 attended
            ,sum(decode(b.OPP_OPEN_STATUS_FLAG,'Y',1,0)) leads_open
	    ,sum(decode(b.OPP_OPEN_STATUS_FLAG,'Y',0,1)) leads_closed
            ,sum(decode(b.OPP_OPEN_STATUS_FLAG,'Y',convert_currency(nvl(a.currency_code,'USD'),nvl(a.budget_amount,0)),0)) leads_open_amt
	    ,sum(decode(b.OPP_OPEN_STATUS_FLAG,'Y',0,convert_currency(nvl(a.currency_code,'USD'),nvl(a.budget_amount,0)))) leads_closed_amt
	    ,sum(decode(b.OPP_OPEN_STATUS_FLAG,'Y',decode(a.status_code,'NEW',1,0),0)) leads_new
            ,sum(decode(b.OPP_OPEN_STATUS_FLAG,'Y',decode(a.status_code,'NEW',convert_currency(nvl(a.currency_code,'USD'),nvl(a.budget_amount,0)),0),0)) leads_new_amt
            ,sum(decode(b.OPP_OPEN_STATUS_FLAG,'N',decode(a.status_code,'CONVERTED_TO_OPPORTUNITY',1,0),0)) leads_converted
            ,sum(decode(b.OPP_OPEN_STATUS_FLAG,'Y',decode(a.lead_rank_id,10000,1,0),0)) leads_hot
            ,sum(decode(b.OPP_OPEN_STATUS_FLAG,'Y',0,decode(a.status_code,'DEAD_LEAD',1,0))) leads_dead
            ,0                          opportunities
            ,0                          opportunity_amt
            ,0                          budget_requested
            ,0                          budget_approved
            ,0                          customer
            ,0                          actual_cost
            ,0                          forecasted_cost
            ,0                          actual_revenue
            ,0                          forecasted_revenue
            ,0                          booked_orders
            ,0                          booked_orders_amt
       FROM    as_sales_leads A,
	       as_statuses_b B,
               ams_event_offers_all_b C,
	       ams_source_codes E
       WHERE   e.source_code_for_id = c.event_offer_id
       AND     c.event_standalone_flag = 'Y'
       AND     (c.parent_type is null or c.parent_type ='RCAM')
       AND     e.source_code_id = a.source_promotion_id
       AND     a.status_code = b.status_code
       AND     e.arc_source_code_for in ('EONE')
       AND     b.lead_flag = 'Y'
       AND     b.enabled_flag = 'Y'
       AND     NVL(a.DELETED_FLAG,'N') <> 'Y'
       AND     trunc(decode(b.OPP_OPEN_STATUS_FLAG,'Y',a.creation_date,a.last_update_date))
		between p_start_datel and p_end_datel + 0.9999
       GROUP BY c.event_offer_id,
                trunc(decode(b.OPP_OPEN_STATUS_FLAG,'Y',a.creation_date,a.last_update_date)),
                e.source_code_id)
     UNION ALL
        (SELECT
	     A.event_offer_id 		event_offer_id
	    ,trunc(A.last_reg_status_date) creation_date
	    ,sum(decode(A.system_status_code,'REGISTERED',1,'CANCELLED',1,0)) registered
	    ,sum(decode(A.system_status_code,'CANCELLED',1,0)) 	cancelled
            ,sum(decode(A.system_status_code,'REGISTERED',decode(attended_flag,'Y',1,0),0)) attended
            ,0                          leads_open
            ,0                          leads_closed
            ,0                          leads_open_amt
            ,0                          leads_closed_amt
            ,0                          leads_new
            ,0                          leads_new_amt
            ,0                          leads_converted
            ,0                          leads_hot
            ,0                          leads_dead
       	    ,0				opportunities
       	    ,0				opportunity_amt
            ,0                          budget_requested
            ,0                          budget_approved
            ,0                          customer
            ,0                          actual_cost
            ,0                          forecasted_cost
            ,0                          actual_revenue
            ,0                          forecasted_revenue
            ,0                          booked_orders
            ,0                          booked_orders_amt
      FROM   ams_event_registrations A
      WHERE  trunc(A.last_reg_status_date) between p_start_datel and p_end_datel + 0.9999
      GROUP BY	 A.event_offer_id,trunc(A.last_reg_status_date))
    UNION ALL
     (SELECT
	     b.event_offer_id		event_offer_id
            ,trunc(i.creation_date) 	creation_date
            ,0  			registered
	    ,0  			cancelled
            ,0  			attended
       	    ,0  			leads_open
	    ,0  			leads_closed
       	    ,0  			leads_open_amt
       	    ,0 				leads_closed_amt
	    ,0 				leads_new
	    ,0 				leads_new_amt
	    ,0 				leads_converted
	    ,0 				leads_hot
	    ,0 				leads_dead
       	    ,0 				nooppor
       	    ,0 				opportunity_amt
       	    ,0 				budget_requested
       	    ,0 				budget_approved
       	    ,0 				customer
            ,0 				actual_cost
            ,0 				forecasted_cost
            ,0 				actual_revenue
            ,0 				forecasted_revenue
            ,count(distinct(h.header_id))  booked_orders
            ,sum(decode(h.flow_status_code,'BOOKED',convert_currency(nvl(H.transactional_curr_code,'USD'),
		       nvl(I.unit_selling_price * I.ordered_quantity,0)),0)) booked_orders_amt
       FROM    ams_event_offers_all_b B,
               ams_source_codes C ,
               as_sales_leads D,
               as_sales_lead_opportunity A,
               as_leads_all E,
               aso_quote_related_objects F,
               aso_quote_headers_all G,
               oe_order_headers_all H,
               oe_order_lines_all I
      where    c.source_code_id = d.source_promotion_id
      and      c.source_code_for_id = b.event_offer_id
      and      c.arc_source_code_for in ('EONE')
      and      b.event_standalone_flag = 'Y'
      and      (b.parent_type is null or b.parent_type ='RCAM')
      and      a.sales_lead_id = d.sales_lead_id
      and      a.opportunity_id = e.lead_id
      and      f.object_id = e.lead_id
      and      f.relationship_type_code = 'OPP_QUOTE'
      and      f.quote_object_type_code = 'HEADER'
      and      f.quote_object_id = g.quote_header_id
      and      g.order_id = h.header_id
      and      NVL(D.deleted_flag,'N') <> 'Y'
      and      h.flow_status_code = 'BOOKED'
      AND      H.header_id = I.header_id
          and      trunc(i.creation_date) between p_start_datel and p_end_datel + 0.9999
      group by b.event_offer_id
                   ,trunc(i.creation_date)) --orders
    )
   GROUP BY event_offer_id ,creation_date
   )   AD,
       ams_event_offers_all_b A,
       ams_source_codes E
   WHERE ad.event_offer_id = a.event_offer_id
   AND   a.event_standalone_flag = 'Y'
   AND   (a.parent_type is null or a.parent_type = 'RCAM')
   AND   e.source_code_for_id = a.event_offer_id
   AND   e.source_code 	= a.source_code
   AND   a.system_status_code in ('ACTIVE','CANCELLED','CLOSED','COMPLETED')
   AND   e.arc_source_code_for = 'EONE';
   --AND   a.event_start_date >= trunc(l_min_start_date);


-----------------------------------------------------------------------

       --dbms_output.put_line('after insert row count:'||SQL%ROWCOUNT);
       EXECUTE IMMEDIATE 'ALTER SEQUENCE '||l_schema||'.bim_r_even_daily_facts_s CACHE 20';
	   EXECUTE IMMEDIATE 'ALTER TABLE '||l_schema||'.bim_r_even_daily_facts nologging';
	EXCEPTION
	   WHEN OTHERS THEN
       EXECUTE IMMEDIATE 'ALTER SEQUENCE '||l_schema||'.bim_r_even_daily_facts_s CACHE 20';
                  --dbms_output.put_line('even_daily:'||sqlerrm(sqlcode));
		   x_return_status := FND_API.G_RET_STS_ERROR;
		  FND_MESSAGE.Set_Name ('AMS', 'AMS_REP_INSERT_ERROR');
		  FND_MESSAGE.Set_token('table_name', l_table_name, FALSE);
		  FND_MSG_PUB.Add;
          ams_utility_pvt.write_conc_log('EVENT:LOAD: EXCEPTION FOR FIRST INSERT. '||sqlerrm(sqlcode));
	      RAISE FND_API.G_EXC_ERROR;
	END;


    BEGIN

      EXECUTE IMMEDIATE 'ALTER TABLE '||l_schema||'.bim_r_even_daily_facts nologging';
      EXECUTE IMMEDIATE 'ALTER TABLE '||l_schema||'.bim_r_even_weekly_facts nologging';

      EXECUTE IMMEDIATE 'ALTER SEQUENCE '||l_schema||'.bim_r_even_daily_facts_s CACHE 1000';

	  --insert into bim_r_even_daily_facts on event header level

	 l_temp_msg := to_char( sysdate, 'dd/mm/yyyy:hh:mi:ss');
     ams_utility_pvt.write_conc_log('EVENT:LOAD: BEFORE SECOND INSERT.' || l_temp_msg);

INSERT  INTO
          bim_r_even_daily_facts ewf(
	      event_daily_transaction_id
	     ,creation_date
	     ,last_update_date
	     ,created_by
	     ,last_updated_by
	     ,last_update_login
	     ,event_header_id
	     ,event_offer_id
	     ,parent_id
	     ,source_code
		 ,hdr_source_code
	     ,start_date
	     ,end_date
	     ,country
	     ,business_unit_id
	     ,org_id
	     ,event_type
	     ,event_offer_type
	     ,status
	     ,event_venue_id
		 ,currency_code
	     ,transaction_create_date
		 ,load_date
	     ,delete_flag
         ,month
         ,qtr
         ,year
	     ,registrations
	     ,cancellations
		 ,attendance
	     ,leads_open
         ,leads_closed
         ,leads_open_amt
         ,leads_closed_amt
	     ,leads_new
	     ,leads_new_amt
	     ,leads_converted
	     ,leads_hot
	     ,metric1 --leads_dead
	     ,opportunities
         ,opportunity_amt
	     ,forecasted_cost
	     ,actual_cost
	     ,forecasted_revenue
		 ,actual_revenue
	     ,customer
	     ,budget_requested
	     ,budget_approved
		 ,booked_orders
		 ,booked_orders_amt
	     )
     SELECT
           bim_r_even_daily_facts_s.nextval,
	       sysdate,
	       sysdate,
	       l_user_id,
	       l_user_id,
	       l_user_id,
	       a.event_header_id,
	       0 event_offer_id,
	       0 parent_id,
	       a.source_code,
		   a.source_code hdr_source_code,
		   a.active_from_date,
	       a.active_to_date,
           a.country_code,
	       a.business_unit_id,
	       a.org_id,
           a.event_type_code,
	       0 event_offer_code,
	       a.system_status_code,
	       0 event_venue_id,
	       a.currency_code_fc,
		   ad.creation_date,
	       (decode(decode(to_char(ad.creation_date,'MM') , to_char(next_day(ad.creation_date,TO_NUMBER(to_char(to_date('07/09/2004', 'DD/MM/RRRR'), 'DD'))),'MM') ,'TRUE','FALSE' )
                ,'TRUE'
                ,decode(decode(ad.creation_date , (next_day(ad.creation_date, TO_NUMBER(to_char(to_date('07/09/2004', 'DD/MM/RRRR'), 'DD'))) - 7) , 'TRUE' ,'FALSE')
                ,'TRUE'
                ,ad.creation_date
                ,'FALSE'
                ,next_day(ad.creation_date, TO_NUMBER(to_char(to_date('07/09/2004', 'DD/MM/RRRR'), 'DD'))))
                ,'FALSE'
                ,decode(decode(to_char(ad.creation_date,'MM'),to_char(next_day(ad.creation_date,TO_NUMBER(to_char(to_date('07/09/2004', 'DD/MM/RRRR'), 'DD'))),'MM'),'TRUE','FALSE')
                ,'FALSE'
                ,last_day(ad.creation_date)))) weekend_date,
           'N',
		   BIM_SET_OF_BOOKS.GET_FISCAL_MONTH(ad.creation_date, 204),
           BIM_SET_OF_BOOKS.GET_FISCAL_QTR(ad.creation_date, 204),
           BIM_SET_OF_BOOKS.GET_FISCAL_YEAR(ad.creation_date, 204),
		   ad.registered,
		   ad.cancelled,
           ad.attended,
       	   ad.leads_open,
	       ad.leads_closed,
       	   ad.leads_open_amt,
       	   ad.leads_closed_amt,
	   	   ad.leads_new,
	   	   ad.leads_new_amt,
	   	   ad.leads_converted,
	   	   ad.leads_hot,
	   	   ad.leads_dead,
       	   ad.nooppor,
       	   ad.opportunity_amt,
           ad.forecasted_cost,
		   ad.actual_cost,
           ad.forecasted_revenue,
           ad.actual_revenue,
		   ad.customer,
           ad.budget_requested,
       	   ad.budget_approved,
           ad.booked_orders,
	       ad.booked_orders_amt
from (select
            event_header_id
            ,creation_date
            ,sum(registered) registered
		    ,sum(cancelled) cancelled
        	,sum(attended) attended
       		,sum(leads_open) leads_open
	        ,sum(leads_closed) leads_closed
       		,sum(leads_open_amt) leads_open_amt
       		,sum(leads_closed_amt) leads_closed_amt
	   		,sum(leads_new) leads_new
	   		,sum(leads_new_amt) leads_new_amt
	   		,sum(leads_converted) leads_converted
	   		,sum(leads_hot) leads_hot
	   		,sum(leads_dead) leads_dead
       		,sum(nooppor) nooppor
       		,sum(opportunity_amt) opportunity_amt
       		,sum(budget_requested) budget_requested
       		,sum(budget_approved) budget_approved
       		,0 customer
            ,sum(actual_cost) actual_cost
            ,sum(forecasted_cost) forecasted_cost
            ,sum(actual_revenue) actual_revenue
            ,sum(forecasted_revenue) forecasted_revenue
            ,sum(booked_orders) booked_orders
	        ,sum(booked_orders_amt) booked_orders_amt
from ((select      event_header_id
            ,creation_date
	        ,0  registered
		    ,0  cancelled
        	,0  attended
       		,0  leads_open
	        ,0  leads_closed
       		,0   leads_open_amt
       		,0 leads_closed_amt
	   		,0 leads_new
	   		,0 leads_new_amt
	   		,0 leads_converted
	   		,0 leads_hot
	   		,0 leads_dead
       		,0 nooppor
       		,0 opportunity_amt
       		,sum(budget_requested) budget_requested
       		,sum(budget_approved) budget_approved
       		,0 customer
            ,0 actual_cost
            ,0 forecasted_cost
            ,0 actual_revenue
            ,0 forecasted_revenue
            ,0 booked_orders
	        ,0 booked_orders_amt
from
(SELECT
               b.act_budget_used_by_id event_header_id
               ,decode(b.status_code
				    ,'PENDING'
			             ,trunc(nvl(b.request_date,b.creation_date))
				    ,'APPROVED'
                         ,trunc(nvl(b.approval_date,b.last_update_date))
				    ) creation_date
               ,sum(decode(b.status_code
				    ,'PENDING'
                          ,convert_currency(nvl(b.request_currency,'USD'),nvl(b.request_amount,0))
				    ,'APPROVED'
                         ,- convert_currency(nvl(b.request_currency,'USD'),nvl(b.request_amount,0))
			        ))  budget_requested
               ,sum(decode(b.status_code
				    ,'PENDING'
                         ,0
				    ,'APPROVED'
                         ,convert_currency(nvl(b.approved_in_currency,'USD'),nvl(b.approved_original_amount,0))
                           ))    budget_approved
       FROM   ozf_act_budgets  B
       WHERE  b.arc_act_budget_used_by = 'EVEH'
       --AND    b.transfer_type = 'REQUEST'
	   AND    b.budget_source_type ='FUND'
       GROUP BY b.act_budget_used_by_id,
	                decode(b.status_code
				    ,'PENDING'
			             ,trunc(nvl(b.request_date,b.creation_date))
				    ,'APPROVED'
                         ,trunc(nvl(b.approval_date,b.last_update_date)))
	   UNION ALL
	   SELECT
                b.budget_source_id event_header_id,
                trunc(nvl(b.approval_date,b.last_update_date))  creation_date,
				0, --budget_requested
                0-SUM(convert_currency(b.approved_in_currency,nvl(b.approved_original_amount,0))) budget_approved
       FROM     ozf_act_budgets  B
       WHERE    b.arc_act_budget_used_by ='FUND'
       --AND      transfer_type in ('TRANSFER','REQUEST')
       AND      status_code ='APPROVED'
	   AND      b.budget_source_type = 'EVEH'
       GROUP BY b.budget_source_id, trunc(nvl(b.approval_date,b.last_update_date)))
     where creation_date between p_start_datel and p_end_datel + 0.9999
     group by event_header_id
            ,creation_date) --BUDGET
UNION ALL
 (SELECT
            c.event_header_id
            ,trunc(a.creation_date) creation_date
            ,0 registered
		    ,0 cancelled
        	,0 attended
       		,0 leads_open
	        ,0 leads_closed
       		,0  leads_open_amt
       		,0 leads_closed_amt
	   		,0 leads_new
	   		,0 leads_new_amt
	   		,0 leads_converted
	   		,0 leads_hot
	   		,0 leads_dead
            ,COUNT(A.lead_id) opportunities
            ,SUM(convert_currency(nvl(currency_code, 'USD'), nvl(A.total_amount, 0))) opportunity_amt
       		,0--budget_requested
       		,0--budget_approved
       		,0-- customer
            ,0--actual_cost
            ,0 --forecasted_cost
            ,0 --actual_revenue
            ,0 --forecasted_revenue
            ,0 booked_orders
	        ,0 booked_orders_amt
       FROM    as_leads_all A,
               ams_event_headers_all_b C,
	           ams_source_codes E
       where   e.source_code_for_id = c.event_header_id
       and     e.source_code_id = a.source_promotion_id
       and     e.arc_source_code_for = 'EVEH'
       and     trunc(a.creation_date) between p_start_datel and p_end_datel + 0.9999
       GROUP BY c.event_header_id,trunc(a.creation_date),
       e.source_code_id) --OPPORTUNITY
UNION ALL
       (SELECT
	           c.event_header_id
               ,trunc(decode(b.OPP_OPEN_STATUS_FLAG,'Y',a.creation_date,a.last_update_date)) creation_date
               ,0-- registered
		       ,0-- cancelled
        	   ,0-- attended
               ,sum(decode(b.OPP_OPEN_STATUS_FLAG,'Y',1,0)) leads_open
	           ,sum(decode(b.OPP_OPEN_STATUS_FLAG,'Y',0,1)) leads_closed
               ,sum(decode(b.OPP_OPEN_STATUS_FLAG,'Y',convert_currency(nvl(a.currency_code,'USD'),nvl(a.budget_amount,0)),0)) leads_open_amt
		       ,sum(decode(b.OPP_OPEN_STATUS_FLAG,'Y',0,convert_currency(nvl(a.currency_code,'USD'),nvl(a.budget_amount,0)))) leads_closed_amt
			   ,sum(decode(b.OPP_OPEN_STATUS_FLAG,'Y',decode(a.status_code,'NEW',1,0),0)) leads_new
               ,sum(decode(b.OPP_OPEN_STATUS_FLAG,'Y',decode(a.status_code,'NEW',convert_currency(nvl(a.currency_code,'USD'),nvl(a.budget_amount,0)),0),0)) leads_new_amt
               ,sum(decode(b.OPP_OPEN_STATUS_FLAG,'N',decode(a.status_code,'CONVERTED_TO_OPPORTUNITY',1,0),0)) leads_converted
               ,sum(decode(b.OPP_OPEN_STATUS_FLAG,'Y',decode(a.lead_rank_id,10000,1,0),0)) leads_hot
               ,sum(decode(b.OPP_OPEN_STATUS_FLAG,'Y',0,decode(a.status_code,'DEAD_LEAD',1,0))) leads_dead
               ,0-- nooppor,
       		   ,0-- opportunity_amt,
       		   ,0 --budget_requested
       		   ,0 --budget_approved
       		   ,0-- customer
               ,0--actual_cost
               ,0 --forecasted_cost
               ,0 --actual_revenue
               ,0 --forecasted_revenue
               ,0 booked_orders
	           ,0 booked_orders_amt
       FROM    as_sales_leads A,
	           as_statuses_b B,
               ams_event_headers_all_b C,
	           ams_source_codes E
       WHERE   e.source_code_for_id = c.event_header_id
       and     e.source_code_id = a.source_promotion_id
       and     a.status_code = b.status_code
       and     e.arc_source_code_for = 'EVEH'
       and     trunc(decode(b.OPP_OPEN_STATUS_FLAG,'Y',a.creation_date,a.last_update_date)) between p_start_datel and p_end_datel + 0.9999
	   AND     b.lead_flag = 'Y'
	   AND     b.enabled_flag = 'Y'
	   AND     NVL(a.DELETED_FLAG,'N') <> 'Y'
       GROUP BY c.event_header_id,
                trunc(decode(b.OPP_OPEN_STATUS_FLAG,'Y',a.creation_date,a.last_update_date)),
                e.source_code_id) --LEADS
UNION ALL
       (SELECT event_header_id
		    ,creation_date
            ,0-- registered
		    ,0-- cancelled
        	,0-- attended
       		,0-- leads_open,
	        ,0-- leads_closed,
       		,0--  leads_open_amt,
       		,0-- leads_closed_amt,
	   		,0-- leads_new,
	   		,0-- leads_new_amt,
	   		,0-- leads_converted,
	   		,0-- leads_hot,
	   		,0-- leads_dead,
            ,0-- opportunities
            ,0-- opportunity_amt
       		,0--budget_requested
       		,0--budget_approved
       		,0-- customer
            ,0--actual_cost
            ,0--forecasted_cost
            ,actual_revenue
            ,forecasted_revenue
	    ,0 booked_orders
	        ,0 booked_orders_amt
	    from (SELECT f1.act_metric_used_by_id event_header_id
		    ,trunc(f1.last_update_date)  creation_date
            ,sum(convert_currency(nvl(f1.functional_currency_code,'USD'),nvl(f1.func_actual_delta,0)))  	actual_revenue
            ,sum(convert_currency(nvl(f1.functional_currency_code,'USD'),nvl(f1.func_forecasted_delta,0))) 	forecasted_revenue
        FROM 	 ams_act_metric_hst            f1
                ,ams_metrics_all_b		g1
        WHERE  f1.arc_act_metric_used_by      = 'EVEH'
        AND    g1.metric_category              = 902
        AND    g1.metric_id                   = f1.metric_id
        and    trunc(f1.last_update_date) between p_start_datel and p_end_datel + 0.9999
        AND    g1.metric_calculation_type       IN ('MANUAL','FUNCTION','ROLLUP')
		group by f1.act_metric_used_by_id
		    ,trunc(f1.last_update_date))
	GROUP BY event_header_id,
	         creation_date,
	         actual_revenue,
             forecasted_revenue
	having   actual_revenue >0
        or   forecasted_revenue >0) --REVENUE
UNION ALL
    (SELECT  event_header_id
		    ,creation_date
            ,0-- registered
		    ,0-- cancelled
        	,0-- attended
       		,0-- leads_open,
	        ,0-- leads_closed,
       		,0--  leads_open_amt,
       		,0-- leads_closed_amt,
	   		,0-- leads_new,
	   		,0-- leads_new_amt,
	   		,0-- leads_converted,
	   		,0-- leads_hot,
	   		,0-- leads_dead,
            ,0-- opportunities
            ,0-- opportunity_amt
       		,0--budget_requested
       		,0--budget_approved
       		,0-- customer
            ,actual_cost
            ,forecasted_cost
            ,0 --actual_revenue
            ,0 --forecasted_revenue
            ,0 booked_orders
	        ,0 booked_orders_amt
	from (SELECT      f1.act_metric_used_by_id event_header_id
		    ,trunc(f1.last_update_date)  creation_date
            ,sum(convert_currency(nvl(f1.functional_currency_code,'USD'),nvl(f1.func_actual_delta,0)))  	actual_cost
            ,sum(convert_currency(nvl(f1.functional_currency_code,'USD'),nvl(f1.func_forecasted_delta,0))) 	forecasted_cost
        FROM 	 ams_act_metric_hst            f1
                ,ams_metrics_all_b		g1
        WHERE  f1.arc_act_metric_used_by      = 'EVEH'
        and    trunc(f1.last_update_date) between p_start_datel and p_end_datel + 0.9999
        AND    g1.metric_category              = 901
        AND    g1.metric_id                   = f1.metric_id
        AND    g1.metric_calculation_type       IN ('MANUAL','FUNCTION','ROLLUP')
	GROUP BY f1.act_metric_used_by_id,trunc(f1.last_update_date))
	GROUP BY event_header_id,
	         creation_date,
	         actual_cost,
             forecasted_cost
	having   actual_cost >0
        or   forecasted_cost >0)--COST
   union all
     (select
	           b.event_header_id,
               trunc(i.creation_date) creation_date
               ,0  registered
		    ,0  cancelled
        	,0  attended
       		,0  leads_open
	        ,0  leads_closed
       		,0  leads_open_amt
       		,0 leads_closed_amt
	   		,0 leads_new
	   		,0 leads_new_amt
	   		,0 leads_converted
	   		,0 leads_hot
	   		,0 leads_dead
       		,0 nooppor
       		,0 opportunity_amt
       		,0 budget_requested
       		,0 budget_approved
       		,0 customer
            ,0 actual_cost
            ,0 forecasted_cost
            ,0 actual_revenue
            ,0 forecasted_revenue
               ,count(distinct(h.header_id))  booked_orders
               ,sum(decode(h.flow_status_code,'BOOKED',convert_currency(nvl(H.transactional_curr_code,'USD'),
			       nvl(I.unit_selling_price * I.ordered_quantity,0)),0)) booked_orders_amt
       from    ams_event_headers_all_b B,
               ams_source_codes C ,
               as_sales_leads D,
               as_sales_lead_opportunity A,
               as_leads_all E,
               aso_quote_related_objects F,
               aso_quote_headers_all G,
               oe_order_headers_all H,
               oe_order_lines_all I
      where    c.source_code_id = d.source_promotion_id
      and      c.source_code_for_id = b.event_header_id
      and      c.arc_source_code_for = 'EVEH'
      and      a.sales_lead_id = d.sales_lead_id
      and      a.opportunity_id = e.lead_id
      and      f.object_id = e.lead_id
      and      f.relationship_type_code = 'OPP_QUOTE'
      and      f.quote_object_type_code = 'HEADER'
      and      f.quote_object_id = g.quote_header_id
      and      NVL(D.deleted_flag,'N') <> 'Y'
      and      g.order_id = h.header_id
      and      h.flow_status_code = 'BOOKED'
      AND      H.header_id = I.header_id
          and      trunc(i.creation_date) between p_start_datel and p_end_datel + 0.9999
      group by b.event_header_id
                   ,trunc(i.creation_date)) --orders
    )
   group by event_header_id ,
            creation_date) AD,
   ams_event_headers_all_b A,
   ams_source_codes E
   where
   e.source_code = a.source_code
   --AND   trunc(a.active_from_date)  >= trunc(l_min_start_date)
   AND   a.system_status_code in ('ACTIVE', 'CANCELLED','COMPLETED','CLOSED')
   and   ad.event_header_id = a.event_header_id
   --AND ad.creation_date IS NOT NULL
   ;
	 l_temp_msg := to_char( sysdate, 'dd/mm/yyyy:hh:mi:ss');
     ams_utility_pvt.write_conc_log('EVENT:LOAD: AFTER SECOND INSERT.' || l_temp_msg);
commit;

EXCEPTION
   WHEN OTHERS THEN
       EXECUTE IMMEDIATE 'ALTER SEQUENCE '||l_schema||'.bim_r_even_daily_facts_s CACHE 20';
                  --dbms_output.put_line('even_update:'||sqlerrm(sqlcode));
		   x_return_status := FND_API.G_RET_STS_ERROR;
		  FND_MESSAGE.Set_Name ('AMS', 'AMS_REP_INSERT_ERROR');
		  FND_MESSAGE.Set_token('table_name', l_table_name, FALSE);
		  FND_MSG_PUB.Add;

		  ams_utility_pvt.write_conc_log('EVENT:LOAD: EXCEPTION FOR SECOND INSERT. '||sqlerrm(sqlcode));
		  RAISE FND_API.G_EXC_ERROR;
END;

-- analyze the BIM_R_EVEN_daily_facts with dbms_stats
BEGIN
   DBMS_STATS.gather_table_stats('BIM','BIM_R_EVEN_DAILY_FACTS', estimate_percent => 5,
                                  degree => 8, granularity => 'GLOBAL', cascade =>TRUE);
END;


EXECUTE IMMEDIATE 'TRUNCATE TABLE '||l_schema||'.bim_r_even_weekly_facts';

BEGIN
/* insert into bim_r_even_weekly_facts */
l_table_name :='bim_r_even_weekly_facts';

     l_temp_msg := to_char( sysdate, 'dd/mm/yyyy:hh:mi:ss');
     ams_utility_pvt.write_conc_log('EVENT:LOAD: BEFORE INSERT INTO WEEKLY FACTS TABLE.' || l_temp_msg);

INSERT /*+ append */ INTO
      bim_r_even_weekly_facts ewf(
             event_weekly_transaction_id
	     ,creation_date
	     ,last_update_date
	     ,created_by
	     ,last_updated_by
	     ,last_update_login
	     ,event_header_id
	     ,event_offer_id
	     ,parent_id
	     ,source_code
	     ,start_date
	     ,end_date
	     ,country
	     ,business_unit_id
	     ,org_id
             ,event_type
	     ,event_offer_type
	     ,status
	     ,event_venue_id
	     ,registrations
	     ,cancellations
	     ,leads_open
         ,leads_closed
         ,leads_open_amt
         ,leads_closed_amt
		 ,leads_new
	     ,leads_new_amt
	     ,leads_converted
	     ,leads_hot
	     ,metric1 --leads_dead
	     ,opportunities
         ,opportunity_amt
	     ,attendance
	     ,forecasted_cost
	     ,actual_cost
	     ,forecasted_revenue
		 ,actual_revenue
	     ,customer
	     ,currency_code
	     ,transaction_create_date
         ,hdr_source_code
         ,order_amt
	     ,budget_requested
	     ,budget_approved
	     ,delete_flag
		 ,month
		 ,qtr
		 ,year
		 ,booked_orders
		 ,booked_orders_amt
	     )
     SELECT
     /*+ parallel(INNER, 4) */
             bim_r_even_weekly_facts_s.nextval
	     ,sysdate
	     ,sysdate
	     ,l_user_id
	     ,l_user_id
	     ,l_user_id
	     ,inner.event_header_id
	     ,inner.event_offer_id
	     ,inner.parent_id
	     ,inner.source_code
	     ,inner.start_date
	     ,inner.end_date
	     ,inner.country
	     ,inner.business_unit_id
	     ,inner.org_id
         ,inner.event_type
	     ,inner.event_offer_type
	     ,inner.status
	     ,inner.event_venue_id
	     ,inner.registrations
	     ,inner.cancellations
	     ,inner.leads_open
         ,inner.leads_closed
         ,inner.leads_open_amt
         ,inner.leads_closed_amt
		 ,inner.leads_new
	     ,inner.leads_new_amt
	     ,inner.leads_converted
	     ,inner.leads_hot
	     ,inner.leads_dead
	     ,inner.opportunities
         ,inner.opportunity_amt
	     ,inner.attendance
         ,inner.forecasted_cost
		 ,inner.actual_cost
		 ,inner.forecasted_revenue
		 ,inner.actual_revenue
	     ,inner.customer
	     ,inner.currency_code
	     ,inner.load_date
         ,inner.hdr_source_code
         ,inner.order_amt
         ,inner.budget_requested
         ,inner.budget_approved
	     ,inner.delete_flag
		 ,inner.month
		 ,inner.qtr
		 ,inner.year
		 ,inner.booked_orders
		 ,inner.booked_orders_amt
     FROM (SELECT event_header_id event_header_id
	     ,event_offer_id event_offer_id
	     ,parent_id parent_id
	     ,source_code source_code
	     ,start_date start_date
	     ,end_date end_date
	     ,country country
	     ,business_unit_id business_unit_id
	     ,org_id org_id
         ,event_type event_type
	     ,event_offer_type event_offer_type
	     ,status status
	     ,event_venue_id event_venue_id
		 ,currency_code currency_code
	     ,load_date load_date
		 ,hdr_source_code hdr_source_code
	     ,SUM(registrations) registrations
	     ,SUM(cancellations) cancellations
	     ,SUM(leads_open) leads_open
         ,SUM(leads_closed) leads_closed
         ,SUM(leads_open_amt) leads_open_amt
         ,SUM(leads_closed_amt) leads_closed_amt
		 ,SUM(leads_new) leads_new
	     ,SUM(leads_new_amt) leads_new_amt
	     ,SUM(leads_converted) leads_converted
	     ,SUM(leads_hot) leads_hot
	     ,SUM(metric1) leads_dead
	     ,SUM(opportunities) opportunities
         ,SUM(opportunity_amt) opportunity_amt
	     ,SUM(attendance) attendance
	     ,SUM(customer) customer
		 ,sum(forecasted_cost) forecasted_cost
		 ,sum(actual_cost) actual_cost
		 ,sum(forecasted_revenue) forecasted_revenue
		 ,sum(actual_revenue) actual_revenue
         ,SUM(order_amt) order_amt
         ,SUM(budget_requested) budget_requested
         ,SUM(budget_approved) budget_approved
	     ,delete_flag delete_flag
		 ,month
		 ,qtr
		 ,year
		 ,sum(booked_orders) booked_orders
		 ,sum(booked_orders_amt) booked_orders_amt
     FROM bim_r_even_daily_facts
--	 where load_date between p_start_datel and p_end_datel + 0.9999
     GROUP BY event_offer_id
	     ,load_date
	     ,event_header_id
	     ,parent_id
	     ,source_code
	     ,start_date
	     ,end_date
	     ,country
	     ,business_unit_id
	     ,org_id
         ,event_type
	     ,event_offer_type
	     ,status
	     ,event_venue_id
	     ,currency_code
	     ,delete_flag
         ,hdr_source_code
		 ,month
		 ,qtr
	     ,year
		 ,booked_orders
		 ,booked_orders_amt) inner;
		 l_temp_msg := to_char( sysdate, 'dd/mm/yyyy:hh:mi:ss');
         ams_utility_pvt.write_conc_log('EVENT:LOAD: AFTER INSERT INTO WEEKLY TABLE.' || l_temp_msg);
commit;

  --IF SQL%ROWCOUNT >0 THEN
  LOG_HISTORY(
	    'EVENT',
		p_start_datel,
		p_end_datel,
	    x_msg_count ,
	    x_msg_data ,
	    x_return_status

        );
   --END IF;

   ams_utility_pvt.write_conc_log('End of Events Facts Program -- Subsequent Load');

EXCEPTION
 WHEN OTHERS THEN
	x_return_status := FND_API.G_RET_STS_ERROR;
	FND_MESSAGE.Set_Name ('AMS', 'AMS_REP_INSERT_ERROR');
	FND_MESSAGE.Set_token('table_name', l_table_name, FALSE);
	FND_MSG_PUB.Add;
		ams_utility_pvt.write_conc_log('EVENT:LOAD: EXCEPTION FOR INSERT INTO WEEKLY TABLE. '||sqlerrm(sqlcode));
		RAISE FND_API.G_EXC_ERROR;
 END ;
--END IF;
	EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_msg_PUB.Count_And_Get (
          --  p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

    ams_utility_pvt.write_conc_log('EVENT:LOAD:EXPECTED EXCEPTION '||sqlerrm(sqlcode));
RAISE FND_API.G_EXC_ERROR;
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     -- Standard call to get message count and if count=1, get the message
     FND_msg_PUB.Count_And_Get (
            --p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

    ams_utility_pvt.write_conc_log('EVENT:LOAD: UNEXPECTED EXCEPTION '||sqlerrm(sqlcode));
     RAISE FND_API.G_EXC_ERROR;
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

    ams_utility_pvt.write_conc_log('EVENT:LOAD: OTHERS EXCEPTION '||sqlerrm(sqlcode));
END EVENT_SUBSEQUENT_LOAD;
END ;

/
