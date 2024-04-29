--------------------------------------------------------
--  DDL for Package Body BIM_RESPONSE_FACTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIM_RESPONSE_FACTS_PKG" AS
/*$Header: bimrspfb.pls 120.3 2005/11/11 05:08:59 arvikuma noship $*/

g_pkg_name  CONSTANT  VARCHAR2(200) := 'BIM_RESPONSE_FACTS_PKG';
g_file_name CONSTANT  VARCHAR2(20) := 'bimrspfb.pls';

----------------------------------------------------------------------------------------------------
        /* This procedure will conditionally call RESPONSES_FACTS_LOAD  */
----------------------------------------------------------------------------------------------------

PROCEDURE POPULATE
   (
     p_api_version_number     IN  NUMBER
    ,p_init_msg_list          IN  VARCHAR2     := FND_API.G_FALSE
    ,p_validation_level       IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL
    ,p_commit                 IN  VARCHAR2     := FND_API.G_FALSE
    ,x_msg_count              OUT NOCOPY NUMBER
    ,x_msg_data               OUT NOCOPY VARCHAR2
    ,x_return_status          OUT NOCOPY VARCHAR2
    ,p_start_date             IN  DATE
    ,p_end_date               IN  DATE
    ,p_para_num               IN  NUMBER
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
    l_api_name                CONSTANT VARCHAR2(30) := 'BIM_RESPONSE_FACTS_PKG';
    l_success                 VARCHAR2(3);
    s_date                    DATE :=  to_date('01/01/1950 01:01:01', 'DD/MM/YYYY HH:MI:SS') ;
    l_temp 	              DATE;
    l_mesg_text		      VARCHAR2(100);
    l_period_error	      VARCHAR2(5000);
    l_currency_error	      VARCHAR2(5000);
    l_err_code	              NUMBER;
    l_temp_start_date         DATE;
    l_temp_end_date           DATE;
    l_temp_p_end_date         DATE;

BEGIN

     fnd_message.set_name('BIM','BIM_R_START_PROGRAM');
     fnd_message.set_token('OBJECT_NAME','Response',FALSE);
     fnd_file.put_line(fnd_file.log,fnd_message.get);

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

      /* Find if the data will be loaded for the first time or not.*/
          DECLARE
          CURSOR chk_history_data IS
              SELECT  MAX(end_date)
              FROM    bim_rep_history
              WHERE   object = 'RESPONSE';

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

        IF(trunc(p_end_date) = trunc(sysdate)) THEN
           l_temp_p_end_date := trunc(p_end_date) - 1;
        ELSE
           l_temp_p_end_date := trunc(p_end_date);
        END IF;

        IF (l_end_date IS NOT NULL AND p_start_date IS NOT NULL)
        THEN
     		fnd_message.set_name('BIM','BIM_R_FIRST_LOAD');
     		fnd_message.set_token('END_DATE',to_char(l_end_date,'DD-MON-RR'),FALSE);
     		fnd_file.put_line(fnd_file.log,fnd_message.get);
                RAISE FND_API.G_EXC_ERROR;
	ELSIF (l_end_date IS NULL AND p_start_date IS NULL)  THEN
        	fnd_message.set_name('BIM','BIM_R_FIRST_SUBSEQUENT');
     		fnd_file.put_line(fnd_file.log,fnd_message.get);
   		RAISE FND_API.G_EXC_ERROR;
 	END IF;

         IF p_start_date IS NOT NULL THEN

                 IF (p_start_date >= l_temp_p_end_date) THEN
     			fnd_message.set_name('BIM','BIM_R_DATE_VALIDATION');
     			fnd_file.put_line(fnd_file.log,fnd_message.get);
                    RAISE FND_API.G_EXC_ERROR;
                 END IF;

                 l_temp_start_date := trunc(p_start_date);
                 l_temp_end_date   := trunc(l_temp_p_end_date);

          ELSE
                IF l_end_date IS NOT NULL THEN

                   IF (l_temp_p_end_date <= l_end_date) THEN
     			fnd_message.set_name('BIM','BIM_R_SUBSEQUENT_LOAD');
     			fnd_message.set_token('END_DATE',to_char(l_end_date,'DD-MON-RR'),FALSE);
     			fnd_file.put_line(fnd_file.log,fnd_message.get);
                      RAISE FND_API.g_exc_error;
                   END IF;

                   l_temp_start_date := trunc(l_end_date) + 1;
                   l_temp_end_date   := trunc(l_temp_p_end_date);

                END IF;

          END IF;

                 RESPONSES_FACTS_LOAD(p_start_date => l_temp_start_date
                     ,p_end_date =>  l_temp_end_date
                     ,p_api_version_number => l_api_version_number
                     ,p_init_msg_list => FND_API.G_FALSE
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


                 -- ams_utility_pvt.write_conc_log('----Period Validation----');
                 -- ams_utility_pvt.write_conc_log(l_period_error);
                 -- ams_utility_pvt.write_conc_log('----Currency Validation----');
                 -- ams_utility_pvt.write_conc_log(l_currency_error);

    --Standard check of commit

       IF FND_API.To_Boolean ( p_commit ) THEN
          COMMIT WORK;
       END IF;

     	fnd_message.set_name('BIM','BIM_R_END_PROGRAM');
     	fnd_file.put_line(fnd_file.log,fnd_message.get);

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
    --,x_msg_count             OUT  NUMBER
    --,x_msg_data              OUT  VARCHAR2
    --,x_return_status         OUT  VARCHAR2
    p_object                   IN   VARCHAR2,
    p_start_date               IN  DATE         DEFAULT NULL,
    p_end_date                 IN  DATE         DEFAULT NULL
    )
    IS
    l_user_id            	NUMBER := FND_GLOBAL.USER_ID();
    l_sysdate            	DATE   := SYSDATE;
    l_api_version_number        CONSTANT NUMBER       := 1.0;
    l_api_name                  CONSTANT VARCHAR2(30) := 'BIM_RESPONSE_FACTS_PKG';
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

END LOG_HISTORY;

--------------------------------------------------------------------------------------------------
-- This procedure will excute when data is loaded for the first time, and run the program incrementally.

--                      PROCEDURE  RESPONSES_FACTS_LOAD
--------------------------------------------------------------------------------------------------

PROCEDURE RESPONSES_FACTS_LOAD
( p_start_date            IN  DATE
 ,p_end_date              IN  DATE
 ,p_api_version_number    IN  NUMBER
 ,p_init_msg_list         IN  VARCHAR2     := FND_API.G_FALSE
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
    l_api_version_number   	  CONSTANT NUMBER       := 1.0;
    l_api_name             	  CONSTANT VARCHAR2(30) := 'RESPONSES_FACTS_LOAD';
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
   l_column_position        generic_number_table;
   l_owner                  generic_char_table;
   l_uniqueness             generic_char_table;
   l_index_name             generic_char_table;
   l_ind_column_name        generic_char_table;
   l_index_table_name       generic_char_table;
   temp_column_string       VARCHAR2(2000);
   temp_column_position     NUMBER;
   temp_index_name          VARCHAR2(1000);
   is_unique                VARCHAR2(30);
   i                        NUMBER;
   l_creation_date          DATE;

   l_min_date			date;
   l_org_id 			number;
    l_status                      VARCHAR2(5);
    l_industry                    VARCHAR2(5);
    l_schema                      VARCHAR2(30);
    l_return                       BOOLEAN;


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

   -- The below four commands are necessary for the purpose of the parallel insertion */

   EXECUTE IMMEDIATE 'ALTER SESSION ENABLE PARALLEL dml ';



   EXECUTE IMMEDIATE 'ALTER TABLE '||l_schema||'.bim_r_rgrd_daily_facts nologging ';
   EXECUTE IMMEDIATE 'ALTER TABLE '||l_schema||'.bim_r_rrsn_daily_facts nologging ';

   EXECUTE IMMEDIATE 'ALTER TABLE '||l_schema||'.bim_r_rgrd_weekly_facts nologging ';
   EXECUTE IMMEDIATE 'ALTER TABLE '||l_schema||'.bim_r_rrsn_weekly_facts nologging ';

   EXECUTE IMMEDIATE 'ALTER sequence '||l_schema||'.bim_r_rgrd_daily_facts_s CACHE 1000 ';
   EXECUTE IMMEDIATE 'ALTER sequence '||l_schema||'.bim_r_rrsn_daily_facts_s CACHE 1000 ';

   EXECUTE IMMEDIATE 'ALTER sequence '||l_schema||'.bim_r_rgrd_weekly_facts_s CACHE 1000 ';
   EXECUTE IMMEDIATE 'ALTER sequence '||l_schema||'.bim_r_rrsn_weekly_facts_s CACHE 1000 ';


   /* Dropping INdexes */
      BIM_UTL_PKG.DROP_INDEX('BIM_R_RGRD_DAILY_FACTS');
      BIM_UTL_PKG.DROP_INDEX('BIM_R_RRSN_DAILY_FACTS');
      BIM_UTL_PKG.DROP_INDEX('BIM_R_RGRD_WEEKLY_FACTS');
      BIM_UTL_PKG.DROP_INDEX('BIM_R_RRSN_WEEKLY_FACTS');


      l_org_id := 204;

      l_table_name := 'BIM_R_RGRD_DAILY_FACTS';
      fnd_message.set_name('BIM','BIM_R_BEFORE_POPULATE');
      fnd_message.set_token('TABLE_NAME',l_table_name,FALSE);
      fnd_file.put_line(fnd_file.log,fnd_message.get);

      INSERT /*+ append parallel(RDF,1) */
      INTO bim_r_rgrd_daily_facts RDF
      (
       Grade_daily_transaction_id
      ,creation_date
      ,last_update_date
      ,created_by
      ,last_updated_by
      ,last_update_login
      ,Object_Id
      ,Object_type
      ,Object_status
      ,Source_Code
      ,Source_Code_Id
      ,Response_Region
      ,Response_Country
      ,Business_Unit_Id
      ,Response_Grade
      ,Response_Grade_Count
      ,landing_pad_hits
      ,survey_completed
      ,transaction_Create_Date
      ,weekend_date
      )
      SELECT
         bim_r_rgrd_daily_facts_s.nextval
        ,sysdate
        ,sysdate
        ,-1
        ,-1
        ,-1
      	,d.parent_object_id     object_id
      	,d.parent_object_type	object_type
      	,d.status		object_status
      	,a.source_code         	source_code
      	,a.source_code_id      	source_code_id
      	,a.region              	region
      	,a.country             	country
      	,d.business_unit_id	business_unit_id
      	,b.response_grade	response_grade
      	,b.response_grade_count	response_grade_count
      	,a.landing_pad_hits	Landing_pad_hits
      	,a.survey_completed	survey_completed
      	,a.response_create_date response_create_date
        ,trunc((decode(decode( to_char(response_create_date,'MM') , to_char(next_day(response_create_date,TO_NUMBER(to_char(to_date('07/09/2004', 'DD/MM/RRRR'), 'DD'))),'MM') ,'TRUE','FALSE' )
      	        ,'TRUE'
      	        ,decode(decode(response_create_date , (next_day(response_create_date, TO_NUMBER(to_char(to_date('07/09/2004', 'DD/MM/RRRR'), 'DD'))) - 7) , 'TRUE' ,'FALSE')
       	        ,'TRUE'
      	        ,response_create_date
      	        ,'FALSE'
      	        ,next_day(response_create_date, TO_NUMBER(to_char(to_date('07/09/2004', 'DD/MM/RRRR'), 'DD'))))
      	        ,'FALSE'
      	        ,decode(decode(to_char(response_create_date,'MM'),to_char(next_day(response_create_date,TO_NUMBER(to_char(to_date('07/09/2004', 'DD/MM/RRRR'), 'DD'))),'MM'),'TRUE','FALSE')
      	        ,'FALSE'
      	        ,last_day(response_create_date)))))   weekend_date
      FROM
      	   	bim_r_resp_int_header	a,
      	   	bim_r_resp_int_grades	b,
      	   	bim_r_source_codes	d
      WHERE  	a.response_create_date >=  p_start_date
      AND	a.response_create_date <=  p_end_date
      AND	a.object_id		=  decode(d.object_type,'CAMP',d.parent_object_id,'EVEH',d.parent_object_id,
						'CSCH',d.object_id,'EVEO',d.object_id)
      AND	a.object_type 		=  d.object_type
      AND	a.interface_header_id	= b.interface_header_id;

      l_table_name := 'BIM_R_RGRD_DAILY_FACTS';
      fnd_message.set_name('BIM','BIM_R_AFTER_POPULATE');
      fnd_message.set_token('TABLE_NAME',l_table_name,FALSE);
      fnd_file.put_line(fnd_file.log,fnd_message.get);
      -----------

      l_table_name := 'BIM_R_RRSN_DAILY_FACTS';
      fnd_message.set_name('BIM','BIM_R_BEFORE_POPULATE');
      fnd_message.set_token('TABLE_NAME',l_table_name,FALSE);
      fnd_file.put_line(fnd_file.log,fnd_message.get);

      INSERT /*+ append parallel(RDF,1) */
      INTO bim_r_rrsn_daily_facts RDF
      (
       Reason_daily_transaction_id
      ,creation_date
      ,last_update_date
      ,created_by
      ,last_updated_by
      ,last_update_login
      ,Object_Id
      ,Object_type
      ,Object_status
      ,Source_Code
      ,Source_Code_Id
      ,Response_Region
      ,Response_Country
      ,Business_Unit_Id
      ,Invalid_Reason
      ,Invalid_Responses
      ,landing_pad_hits
      ,survey_completed
      ,transaction_Create_Date
      ,weekend_date
      )
      SELECT
         bim_r_rrsn_daily_facts_s.nextval
        ,sysdate
        ,sysdate
        ,-1
        ,-1
        ,-1
      	,d.parent_object_id    	object_id
      	,d.parent_object_type	object_type
      	,d.status		object_status
      	,a.source_code         	source_code
      	,a.source_code_id      	source_code_id
      	,a.region              	region
      	,a.country             	country
      	,d.business_unit_id	business_unit_id
      	,b.invalid_reason	invalid_reason
      	,b.invalid_responses	invalid_responses
      	,a.landing_pad_hits	Landing_pad_hits
      	,a.survey_completed	survey_completed
      	,a.response_create_date response_create_date
        ,trunc((decode(decode( to_char(response_create_date,'MM') , to_char(next_day(response_create_date,TO_NUMBER(to_char(to_date('07/09/2004', 'DD/MM/RRRR'), 'DD'))),'MM') ,'TRUE','FALSE' )
      	        ,'TRUE'
      	        ,decode(decode(response_create_date , (next_day(response_create_date, TO_NUMBER(to_char(to_date('07/09/2004', 'DD/MM/RRRR'), 'DD'))) - 7) , 'TRUE' ,'FALSE')
       	        ,'TRUE'
      	        ,response_create_date
      	        ,'FALSE'
      	        ,next_day(response_create_date, TO_NUMBER(to_char(to_date('07/09/2004', 'DD/MM/RRRR'), 'DD'))))
      	        ,'FALSE'
      	        ,decode(decode(to_char(response_create_date,'MM'),to_char(next_day(response_create_date,TO_NUMBER(to_char(to_date('07/09/2004', 'DD/MM/RRRR'), 'DD'))),'MM'),'TRUE','FALSE')
      	        ,'FALSE'
      	        ,last_day(response_create_date)))))   weekend_date
      FROM
      	   	bim_r_resp_int_header	a,
      	   	bim_r_resp_int_reason	b,
      	   	bim_r_source_codes	d
      WHERE  	a.response_create_date >=  p_start_date
      AND	a.response_create_date <=  p_end_date
      AND	a.object_type		=  d.object_type
      AND	a.object_id		=  decode(d.object_type,'CAMP',d.parent_object_id,'EVEH',d.parent_object_id,
						'CSCH',d.object_id,'EVEO',d.object_id)
      AND	a.interface_header_id	= b.interface_header_id;

      ------------
      l_table_name := 'BIM_R_RRSN_DAILY_FACTS';
      fnd_message.set_name('BIM','BIM_R_AFTER_POPULATE');
      fnd_message.set_token('TABLE_NAME',l_table_name,FALSE);
      fnd_file.put_line(fnd_file.log,fnd_message.get);

   COMMIT;

/***************************************************************/

   l_temp_msg := to_char( sysdate, 'dd/mm/yyyy:hh:mi:ss');

      l_table_name := 'BIM_R_RGRD_DAILY_FACTS';
      fnd_message.set_name('BIM','BIM_R_ANALYZE_TABLE');
      fnd_message.set_token('TABLE_NAME',l_table_name,FALSE);
      fnd_file.put_line(fnd_file.log,fnd_message.get);

   -- Analyze the daily facts table
   DBMS_STATS.gather_table_stats('BIM','BIM_R_RGRD_DAILY_FACTS', estimate_percent => 5,
                                  degree => 8, granularity => 'GLOBAL', cascade =>TRUE);

      l_table_name := 'BIM_R_RRSN_DAILY_FACTS';
      fnd_message.set_name('BIM','BIM_R_ANALYZE_TABLE');
      fnd_message.set_token('TABLE_NAME',l_table_name,FALSE);
      fnd_file.put_line(fnd_file.log,fnd_message.get);

   -- Analyze the daily facts table
   DBMS_STATS.gather_table_stats('BIM','BIM_R_RRSN_DAILY_FACTS', estimate_percent => 5,
                                  degree => 8, granularity => 'GLOBAL', cascade =>TRUE);

/***************************************************************/

   /*  INSERT INTO WEEKLY SUMMARY TABLE */

   l_temp_msg := to_char( sysdate, 'dd/mm/yyyy:hh:mi:ss');

   EXECUTE IMMEDIATE 'truncate table '||l_schema||'.bim_r_rgrd_weekly_facts';
   EXECUTE IMMEDIATE 'truncate table '||l_schema||'.bim_r_rrsn_weekly_facts';

      l_table_name := 'BIM_R_RGRD_WEEKLY_FACTS';
      fnd_message.set_name('BIM','BIM_R_BEFORE_POPULATE');
      fnd_message.set_token('TABLE_NAME',l_table_name,FALSE);
      fnd_file.put_line(fnd_file.log,fnd_message.get);

   /*BEGIN BLOCK FOR THE WEEKLY INSERT */
     INSERT /*+ append parallel(RWF,1) */
     INTO bim_r_rgrd_weekly_facts  RWF
     (
      Grade_Weekly_transaction_id
     ,creation_date
     ,last_update_date
     ,created_by
     ,last_updated_by
     ,last_update_login
     ,Object_Id
     ,Object_type
     ,Object_status
     ,Source_Code
     ,Source_Code_Id
     ,Response_Region
     ,Response_Country
     ,Business_Unit_Id
     ,Response_Grade
     ,weekend_Date
     ,Response_Grade_Count
     ,landing_pad_hits
     ,survey_completed
     )
     SELECT
      bim_r_rgrd_weekly_facts_s.nextval
     ,sysdate
     ,sysdate
     ,-1
     ,-1
     ,-1
     ,Object_Id
     ,Object_type
     ,Object_status
     ,Source_Code
     ,Source_Code_Id
     ,Response_Region
     ,Response_Country
     ,Business_Unit_Id
     ,Response_Grade
     ,weekend_date
     ,Response_Grade_Count
     ,landing_pad_hits
     ,survey_completed
     FROM  (
     SELECT
      Object_Id
     ,Object_type
     ,Object_status
     ,Source_Code
     ,Source_Code_Id
     ,Response_Region
     ,Response_Country
     ,Business_Unit_Id
     ,Response_Grade
     ,weekend_date
     ,sum(Response_Grade_Count) Response_Grade_Count
     ,sum(landing_pad_hits)	Landing_pad_hits
     ,sum(survey_completed)	Survey_Completed
     FROM	bim_r_rgrd_daily_facts
     GROUP BY
      	Object_Id
     	,Object_type
     ,Object_status
     ,Source_Code
     ,Source_Code_Id
     ,Response_Region
     ,Response_Country
     ,Business_Unit_Id
     ,Response_Grade
     ,weekend_date
     );

      l_table_name := 'BIM_R_RGRD_WEEKLY_FACTS';
      fnd_message.set_name('BIM','BIM_R_AFTER_POPULATE');
      fnd_message.set_token('TABLE_NAME',l_table_name,FALSE);
      fnd_file.put_line(fnd_file.log,fnd_message.get);

      ---------------

      l_table_name := 'BIM_R_RRSN_WEEKLY_FACTS';
      fnd_message.set_name('BIM','BIM_R_BEFORE_POPULATE');
      fnd_message.set_token('TABLE_NAME',l_table_name,FALSE);
      fnd_file.put_line(fnd_file.log,fnd_message.get);


     INSERT /*+ append parallel(RWF,1) */
     INTO bim_r_rrsn_weekly_facts RWF
     (
      Reason_Weekly_transaction_id
     ,creation_date
     ,last_update_date
     ,created_by
     ,last_updated_by
     ,last_update_login
     ,Object_Id
     ,Object_type
     ,Object_status
     ,Source_Code
     ,Source_Code_Id
     ,Response_Region
     ,Response_Country
     ,Business_Unit_Id
     ,Invalid_Reason
     ,weekend_Date
     ,Invalid_Responses
     ,landing_pad_hits
     ,survey_completed
     )
     SELECT
      bim_r_rrsn_weekly_facts_s.nextval
     ,sysdate
     ,sysdate
     ,-1
     ,-1
     ,-1
     ,Object_Id
     ,Object_type
     ,Object_status
     ,Source_Code
     ,Source_Code_Id
     ,Response_Region
     ,Response_Country
     ,Business_Unit_Id
     ,Invalid_Reason
     ,weekend_date
     ,Invalid_Responses
     ,Landing_Pad_hits
     ,Survey_Completed
     FROM  (
     SELECT
      Object_Id
     ,Object_type
     ,Object_status
     ,Source_Code
     ,Source_Code_Id
     ,Response_Region
     ,Response_Country
     ,Business_Unit_Id
     ,Invalid_Reason
     ,weekend_date
     ,sum(Invalid_Responses) 	Invalid_Responses
     ,sum(landing_pad_hits)	Landing_Pad_hits
     ,sum(survey_completed)	Survey_Completed
     FROM	bim_r_rrsn_daily_facts
     GROUP BY
      	Object_Id
     	,Object_type
     ,Object_status
     ,Source_Code
     ,Source_Code_Id
     ,Response_Region
     ,Response_Country
     ,Business_Unit_Id
     ,Invalid_Reason
     ,weekend_date
     );

      l_table_name := 'BIM_R_RRSN_WEEKLY_FACTS';
      fnd_message.set_name('BIM','BIM_R_AFTER_POPULATE');
      fnd_message.set_token('TABLE_NAME',l_table_name,FALSE);
      fnd_file.put_line(fnd_file.log,fnd_message.get);

    LOG_HISTORY('RESPONSE', p_start_date, p_end_date);

   COMMIT;

   l_temp_msg := to_char( sysdate, 'dd/mm/yyyy:hh:mi:ss');

      l_table_name := 'BIM_R_RGRD_WEEKLY_FACTS';
      fnd_message.set_name('BIM','BIM_R_ANALYZE_TABLE');
      fnd_message.set_token('TABLE_NAME',l_table_name,FALSE);
      fnd_file.put_line(fnd_file.log,fnd_message.get);

   DBMS_STATS.gather_table_stats('BIM','BIM_R_RGRD_WEEKLY_FACTS', estimate_percent => 5,
                                  degree => 8, granularity => 'GLOBAL', cascade =>TRUE);

      l_table_name := 'BIM_R_RRSN_WEEKLY_FACTS';
      fnd_message.set_name('BIM','BIM_R_ANALYZE_TABLE');
      fnd_message.set_token('TABLE_NAME',l_table_name,FALSE);
      fnd_file.put_line(fnd_file.log,fnd_message.get);

   DBMS_STATS.gather_table_stats('BIM','BIM_R_RRSN_WEEKLY_FACTS', estimate_percent => 5,
                                  degree => 8, granularity => 'GLOBAL', cascade =>TRUE);


   l_temp_msg := to_char( sysdate, 'dd/mm/yyyy:hh:mi:ss');
      fnd_message.set_name('BIM','BIM_R_RECREATE_INDEXES');
      fnd_file.put_line(fnd_file.log,fnd_message.get);

   /* Recreating Indexes */
      BIM_UTL_PKG.CREATE_INDEX('BIM_R_RGRD_DAILY_FACTS');
      BIM_UTL_PKG.CREATE_INDEX('BIM_R_RRSN_DAILY_FACTS');
      BIM_UTL_PKG.CREATE_INDEX('BIM_R_RGRD_WEEKLY_FACTS');
      BIM_UTL_PKG.CREATE_INDEX('BIM_R_RRSN_WEEKLY_FACTS');

   EXECUTE IMMEDIATE 'ALTER sequence '||l_schema||'.bim_r_rgrd_weekly_facts_s CACHE 20';
   EXECUTE IMMEDIATE 'ALTER sequence '||l_schema||'.bim_r_rrsn_weekly_facts_s CACHE 20';

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_msg_PUB.Count_And_Get (
          --  p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

    ams_utility_pvt.write_conc_log('BIM_RESPONSE_FACTS_PKG:RESPONSES_FACTS_LOAD:IN EXPECTED EXCEPTION '||sqlerrm(sqlcode));

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     -- Standard call to get message count and if count=1, get the message
     FND_msg_PUB.Count_And_Get (
            --p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

    ams_utility_pvt.write_conc_log('BIM_RESPONSE_FACTS_PKG:RESPONSES_FACTS_LOAD:IN UNEXPECTED EXCEPTION '||sqlerrm(sqlcode));

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

    ams_utility_pvt.write_conc_log('BIM_RESPONSE_FACTS_PKG:RESPONSES_FACTS_LOAD:IN OTHERS EXCEPTION '||sqlerrm(sqlcode));


END RESPONSES_FACTS_LOAD;


END BIM_RESPONSE_FACTS_PKG;

/
