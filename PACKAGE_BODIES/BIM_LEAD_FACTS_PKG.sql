--------------------------------------------------------
--  DDL for Package Body BIM_LEAD_FACTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIM_LEAD_FACTS_PKG" AS
/*$Header: bimldsfb.pls 120.2 2005/11/11 05:08:51 arvikuma noship $*/

g_pkg_name  CONSTANT  VARCHAR2(20) := 'BIM_LEAD_FACTS_PKG';
g_file_name CONSTANT  VARCHAR2(20) := 'bimldsfb.pls';

------------------------------------------------------------------------------------------------
----
----This procedure finds out if the user is trying to run first_load or subsequent load
----and calls the load_data procedure with the specific parameters to each type of load
----
------------------------------------------------------------------------------------------------

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
    l_api_name                CONSTANT VARCHAR2(30) := 'BIM_LEAD_FACTS_PKG';
    l_success                 VARCHAR2(3);
    l_temp 	              DATE;
    l_mesg_text		      VARCHAR2(100);
    l_load_type	              VARCHAR2(100);
    l_period_error	      VARCHAR2(5000);
    l_currency_error	      VARCHAR2(5000);
    l_err_code	              NUMBER;
    l_temp_start_date         DATE;
    l_temp_end_date           DATE;
    l_temp_p_end_date         DATE;
    l_status                      VARCHAR2(5);
    l_industry                    VARCHAR2(5);
    l_schema                      VARCHAR2(30);
    l_return                       BOOLEAN;
  BEGIN
      l_return  := fnd_installation.get_app_info('BIM', l_status, l_industry, l_schema);
     fnd_message.set_name('BIM','BIM_R_START_FACTS');
     fnd_message.set_token('P_OBJECT', 'LEADS', FALSE);
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

    -- Debug Message
    -- AMS_UTILITY_PVT.debug_message('Private API: ' ||  'Running the populate procedure');

      /* Find if the data will be loaded for the first time or not.*/
          DECLARE
          CURSOR chk_history_data IS
              SELECT  MIN(start_date),MAX(end_date)
              FROM    bim_rep_history
              WHERE   object = 'LEADS';
          BEGIN
              OPEN  chk_history_data;
              FETCH chk_history_data INTO l_start_date,l_end_date;
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
                l_load_type  := 'FIRST_LOAD';
                LOAD_DATA(p_start_date => l_temp_start_date
                     ,p_end_date =>  l_temp_end_date
                     ,p_api_version_number => l_api_version_number
                     ,p_init_msg_list => FND_API.G_FALSE
                     ,x_msg_count => x_msg_count
                     ,x_msg_data   => x_msg_data
                     ,x_return_status => x_return_status
                );

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
                l_load_type  := 'SUBSEQUENT_LOAD';

                LOAD_DATA(p_start_date => l_temp_start_date
                     ,p_end_date =>  l_temp_end_date
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

        fnd_message.set_name('BIM','BIM_R_END_FACTS');
        fnd_message.set_token('OBJECT_NAME', 'LEADS', FALSE);
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
/* This procedure will insert a HISTORY record whenever first or subsequent load is run */
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
    l_api_name                  CONSTANT VARCHAR2(30) := 'BIM_LEAD_FACTS_PKG';
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
-- This procedure will populates all the data required into daily facts and weekly facts.
--
--                      PROCEDURE  LOAD_DATA
--------------------------------------------------------------------------------------------------

PROCEDURE LOAD_DATA
( p_start_date            IN  DATE
 ,p_end_date              IN  DATE
 ,p_api_version_number    IN  NUMBER
 ,p_init_msg_list         IN  VARCHAR2     := FND_API.G_FALSE
 ,x_msg_count             OUT NOCOPY NUMBER
 ,x_msg_data              OUT NOCOPY VARCHAR2
 ,x_return_status         OUT NOCOPY VARCHAR2
)
IS
    l_user_id                     NUMBER := FND_GLOBAL.USER_ID();
    l_start_date                  DATE;
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
    l_api_name             	  CONSTANT VARCHAR2(30) := 'LOAD_DATA';
    l_seq_name             	  VARCHAR(100);
    l_def_tablespace        	  VARCHAR2(100);
    l_index_tablespace      	  VARCHAR2(100);
    l_oracle_username       	  VARCHAR2(100);
    l_table_name		  VARCHAR2(100);
    l_temp_msg		          VARCHAR2(100);

   TYPE  generic_number_table IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

   TYPE  generic_char_table IS TABLE OF VARCHAR2(100) INDEX BY BINARY_INTEGER;

   i			NUMBER;
   l_min_start_date     DATE;



   l_org_id 			number;

   CURSOR   get_org_id IS
   SELECT   (TO_NUMBER(SUBSTRB(USERENV('CLIENT_INFO'), 1, 10)))
   FROM     dual;


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

   --ams_utility_pvt.write_conc_log('BIM_LEAD_FACTS_PKG: Running the Load_data ');

   -- The below four commands are necessary for the purpose of the parallel insertion */
   --COMMIT;

   EXECUTE IMMEDIATE 'ALTER SESSION ENABLE PARALLEL dml ';

   EXECUTE IMMEDIATE 'ALTER TABLE '||l_schema||'.bim_r_lead_daily_facts nologging ';

   EXECUTE IMMEDIATE 'ALTER TABLE '||l_schema||'.bim_r_lead_weekly_facts nologging ';

   EXECUTE IMMEDIATE 'ALTER sequence '||l_schema||'.bim_r_lead_daily_facts_s CACHE 1000 ';

   EXECUTE IMMEDIATE 'ALTER sequence '||l_schema||'.bim_r_lead_weekly_facts_s CACHE 1000 ';

   /* Dropping INdexes */
      BIM_UTL_PKG.DROP_INDEX('BIM_R_LEAD_DAILY_FACTS');
      BIM_UTL_PKG.DROP_INDEX('BIM_R_LEAD_WEEKLY_FACTS');



      l_table_name := 'BIM_R_LEAD_DAILY_FACTS';
      fnd_message.set_name('BIM','BIM_R_POPULATE_TABLE');
      fnd_message.set_token('TABLE_NAME',l_table_name,FALSE);
      fnd_file.put_line(fnd_file.log,fnd_message.get);


    -- dbms_output.put_Line('JUST BEFORE THE MAIN INSERT STATMENT');



      INSERT /*+ append parallel(LDF,1) */
      INTO bim_r_lead_daily_facts LDF
      (
               lead_daily_transaction_id
              ,creation_date
              ,last_update_date
              ,created_by
              ,last_updated_by
              ,last_update_login
              ,transaction_create_date
              ,group_id
              ,lead_rank_id
              ,lead_source
              ,lead_status
              ,open_flag
              ,object_type
	      ,object_id
              ,region
              ,country
              ,business_unit_id
	      ,year
	      ,qtr
              ,month
              ,leads_open
              ,leads_closed
	      ,leads_new
	      ,leads_dead
	      ,leads_changed
	      ,leads_unchanged
	      ,leads_assigned
              ,opportunities
	      ,opportunities_open
              ,quotes
	      ,quotes_open
              ,orders
              ,weekend_date
      )
      SELECT  /*+ parallel(OUTER,1) */
	      bim_r_lead_daily_facts_s.nextval
              ,sysdate
              ,sysdate
              ,-1
              ,-1
              ,-1
              ,transaction_create_date
              ,group_id
              ,lead_rank_id
              ,lead_source
              ,lead_status
              ,open_flag
              ,object_type
              ,object_id
              ,region
              ,country
              ,business_unit_id
              ,year
              ,qtr
              ,month
              ,leads_open
              ,leads_closed
	      ,leads_new
	      ,leads_dead
	      ,leads_changed
	      ,leads_unchanged
	      ,leads_assigned
              ,opportunities
	      ,opportunities_open
              ,quotes
              ,quotes_open
              ,orders
              ,weekend_date
      FROM
      (
SELECT
	      inner.group_id                    group_id
      	      ,inner.transaction_create_date	transaction_create_date
              ,inner.lead_rank_id               lead_rank_id
              ,inner.lead_source                lead_source
              ,inner.lead_status                lead_status
              ,inner.open_flag                  open_flag
              ,inner.object_type                object_type
              ,inner.object_id                  object_id
              ,loc.region                       region
              ,inner.country                    country
      	      ,inner.business_unit_id           business_unit_id
              ,a.fiscal_year                    year
              ,a.fiscal_qtr                     qtr
              ,a.fiscal_month                   month
              ,inner.leads_open  	        leads_open
              ,inner.leads_closed 	        leads_closed
	      ,inner.leads_new		        leads_new
	      ,inner.leads_dead		        leads_dead
	      ,inner.leads_changed	        leads_changed
	      ,inner.leads_unchanged	        leads_unchanged
	      ,inner.leads_assigned	        leads_assigned
              ,inner.opportunities              opportunities
	      ,inner.opportunities_open	        opportunities_open
              ,inner.quotes                     quotes
              ,inner.quotes_open                quotes_open
              ,inner.orders	                orders
              ,(decode(decode( to_char(inner.transaction_create_date,'MM') , to_char(next_day(inner.transaction_create_date,TO_NUMBER(to_char(to_date('07/09/2004', 'DD/MM/RRRR'), 'DD'))),'MM') ,'TRUE','FALSE' )
      	        ,'TRUE'
      	        ,decode(decode(inner.transaction_create_date , (next_day(inner.transaction_create_date, TO_NUMBER(to_char(to_date('07/09/2004', 'DD/MM/RRRR'), 'DD'))) - 7) , 'TRUE' ,'FALSE')
       	        ,'TRUE'
      	        ,inner.transaction_create_date
      	        ,'FALSE'
      	        ,next_day(inner.transaction_create_date, TO_NUMBER(to_char(to_date('07/09/2004', 'DD/MM/RRRR'), 'DD'))))
      	        ,'FALSE'
      	        ,decode(decode(to_char(inner.transaction_create_date,'MM'),to_char(next_day(inner.transaction_create_date,TO_NUMBER(to_char(to_date('07/09/2004', 'DD/MM/RRRR'), 'DD'))),'MM'),'TRUE','FALSE')
      	        ,'FALSE'
      	        ,last_day(inner.transaction_create_date))))         weekend_date
FROM  (
SELECT
               metric.group_id                          group_id
              ,metric.transaction_create_date           transaction_create_date
              ,metric.lead_rank_id                      lead_rank_id
              ,metric.lead_source                       lead_source
              ,metric.lead_status                       lead_status
              ,metric.open_flag                         open_flag
              ,metric.object_type                       object_type
              ,metric.object_id                         object_id
              ,metric.country                           country
              ,metric.business_unit_id                  business_unit_id
              ,sum(nvl(metric.leads_open,0))  	        leads_open
              ,sum(nvl(metric.leads_closed,0))	        leads_closed
	      ,sum(nvl(metric.leads_new,0))	        leads_new
	      ,sum(nvl(metric.leads_dead,0))	        leads_dead
	      ,sum(nvl(metric.leads_changed,0))	        leads_changed
	      ,sum(nvl(metric.leads_unchanged,0))	leads_unchanged
	      ,sum(nvl(metric.leads_assigned,0))	leads_assigned
              ,sum(nvl(metric.opportunities,0))         opportunities
	      ,sum(nvl(metric.opportunities_open,0))    opportunities_open
              ,sum(nvl(metric.quotes,0))	        quotes
              ,sum(nvl(metric.quotes_open,0))           quotes_open
              ,sum(nvl(metric.orders,0))                orders
FROM (
SELECT
              x.assign_sales_group_id group_id
              ,trunc(decode(Y.opp_open_status_flag,'Y',X.creation_date,X.last_update_date))transaction_create_date
              ,x.lead_rank_id lead_rank_id
              ,x.source_system lead_source
              ,x.status_code lead_status
              ,decode(x.status_open_flag,'Y','Yes','No') open_flag
              ,a.parent_object_type object_type
              ,a.parent_object_id object_id
              ,x.country country
              ,a.business_unit_id business_unit_id
              ,sum(decode(Y.opp_open_status_flag,'Y',1,0)) leads_open
              ,sum(decode(Y.opp_open_status_flag,'Y',0,1)) leads_closed
              ,sum(decode(Y.opp_open_status_flag,'Y',decode(X.status_code,'NEW',1,0),0))       leads_new
              ,sum(decode(Y.opp_open_status_flag,'Y',0,decode(X.status_code,'DEAD_LEAD',1,0))) leads_dead
              ,sum(decode(X.created_by,X.last_updated_by,0,1)) leads_changed
              ,sum(decode(X.created_by,X.last_updated_by,1,0)) leads_unchanged
              ,sum(decode(Y.opp_open_status_flag,'Y',decode(X.assign_to_salesforce_id,null,0,1),0))       leads_assigned
              ,0 opportunities
              ,0 opportunities_open
              ,0 quotes
              ,0 quotes_open
              ,0 orders
FROM
              as_sales_leads X
              ,as_statuses_b  Y
              ,bim_r_source_codes A
WHERE
              trunc(X.creation_date) between p_start_date and p_end_date
              AND   X.status_code = Y.status_code
              AND   Y.lead_flag = 'Y'
              AND   Y.enabled_flag = 'Y'
              AND   NVL(X.DELETED_FLAG,'N') <> 'Y'
              AND   X.source_promotion_id = a.source_code_id(+)
GROUP BY
              x.assign_sales_group_id
              ,trunc(decode(Y.opp_open_status_flag,'Y',X.creation_date,X.last_update_date))
              ,x.lead_rank_id
              ,x.source_system
              ,x.status_code
              ,decode(x.status_open_flag,'Y','Yes','No')
              ,a.parent_object_type
              ,a.parent_object_id
              ,x.country
              ,a.business_unit_id
---------
UNION ALL
---------
SELECT
              x.assign_sales_group_id group_id
              ,trunc(decode(Y.OPP_OPEN_STATUS_FLAG,'Y',d.creation_date,d.last_update_date)) transaction_create_date
              ,x.lead_rank_id lead_rank_id
              ,x.source_system lead_source
              ,x.status_code lead_status
              ,decode(x.status_open_flag,'Y','Yes','No') open_flag
              ,a.parent_object_type object_type
              ,a.parent_object_id object_id
              ,x.country country
              ,a.business_unit_id business_unit_id
              ,0 leads_open
              ,0 leads_closed
              ,0 leads_new
              ,0 leads_dead
              ,0 leads_changed
              ,0 leads_unchanged
              ,0 leads_assigned
              ,count(e.lead_id) opportunities
              ,sum(decode(Y.opp_open_status_flag,'Y',1,0)) opportunities_open
              ,0 quotes
              ,0 quotes_open
              ,0 orders
FROM
              as_sales_leads X
              ,as_statuses_b  Y
              ,bim_r_source_codes A
              ,as_sales_lead_opportunity D
              ,as_leads_all E
WHERE
              trunc(d.creation_date) between p_start_date and p_end_date
              AND   X.sales_lead_id = D.sales_lead_id
              AND   D.opportunity_id = E.lead_id
              AND   E.status = Y.status_code
              AND   NVL(X.DELETED_FLAG,'N') <> 'Y'
              AND   X.source_promotion_id = a.source_code_id(+)
GROUP BY
              x.assign_sales_group_id
              ,trunc(decode(Y.OPP_OPEN_STATUS_FLAG,'Y',d.creation_date,d.last_update_date))
              ,x.lead_rank_id
              ,x.source_system
              ,x.status_code
              ,decode(x.status_open_flag,'Y','Yes','No')
              ,a.parent_object_type
              ,a.parent_object_id
              ,x.country
              ,a.business_unit_id
---------
UNION ALL
---------
SELECT
              x.assign_sales_group_id group_id
              ,trunc(g.creation_date) transaction_create_date
              ,x.lead_rank_id lead_rank_id
              ,x.source_system lead_source
              ,x.status_code lead_status
              ,decode(x.status_open_flag,'Y','Yes','No') open_flag
              ,a.parent_object_type object_type
              ,a.parent_object_id object_id
              ,x.country country
              ,a.business_unit_id business_unit_id
              ,0 leads_open
              ,0 leads_closed
              ,0 leads_new
              ,0 leads_dead
              ,0 leads_changed
              ,0 leads_unchanged
              ,0 leads_assigned
              ,0 opportunities
              ,0 opportunities_open
              ,count(g.quote_header_id) quotes
              ,sum(decode(g.resource_id, null,0,decode(g.order_id, null, 1,0))) quotes_open
              ,0 orders
FROM
              as_sales_leads X
              ,as_statuses_b  Y
              ,bim_r_source_codes A
              ,as_sales_lead_opportunity D
              ,as_leads_all E
              ,aso_quote_related_objects F
              ,aso_quote_headers_all G
WHERE
              trunc(f.creation_date) between p_start_date and p_end_date
              AND   X.sales_lead_id = D.sales_lead_id
              AND   D.opportunity_id = E.lead_id
              AND   F.object_id = E.lead_id
              AND   F.relationship_type_code = 'OPP_QUOTE'
              AND   F.quote_object_type_code = 'HEADER'
              AND   F.quote_object_id = G.quote_header_id
              AND   NVL(G.quote_expiration_date, p_start_date+1) > p_start_date
              AND   NVL(X.DELETED_FLAG,'N') <> 'Y'
              AND   X.source_promotion_id = a.source_code_id(+)
              AND   X.status_code = Y.status_code
              AND   Y.lead_flag = 'Y'
              AND   Y.enabled_flag = 'Y'
GROUP BY
              x.assign_sales_group_id
              ,g.creation_date
              ,x.lead_rank_id
              ,x.source_system
              ,x.status_code
              ,decode(x.status_open_flag,'Y','Yes','No')
              ,a.parent_object_type
              ,a.parent_object_id
              ,x.country
              ,a.business_unit_id
---------
UNION ALL
---------
SELECT
              x.assign_sales_group_id group_id
              ,trunc(i.creation_date) transaction_create_date
              ,x.lead_rank_id lead_rank_id
              ,x.source_system lead_source
              ,x.status_code lead_status
              ,decode(x.status_open_flag,'Y','Yes','No') open_flag
              ,a.parent_object_type object_type
              ,a.parent_object_id object_id
              ,x.country country
              ,a.business_unit_id business_unit_id
              ,0 leads_open
              ,0 leads_closed
              ,0 leads_new
              ,0 leads_dead
              ,0 leads_changed
              ,0 leads_unchanged
              ,0 leads_assigned
              ,0 opportunities
              ,0 opportunities_open
              ,0 quotes
              ,0 quotes_open
              ,count(h.header_id) orders
FROM
              as_sales_leads X
              ,as_statuses_b  Y
              ,bim_r_source_codes  A
              ,as_sales_lead_opportunity D
              ,as_leads_all E
              ,aso_quote_related_objects F
              ,aso_quote_headers_all G
              ,oe_order_headers_all H
              ,oe_order_lines_all I
WHERE
              trunc(i.creation_date) between p_start_date and p_end_date
              AND   X.sales_lead_id = D.sales_lead_id
              AND   D.opportunity_id = E.lead_id
              AND   F.object_id = E.lead_id
              AND   F.relationship_type_code = 'OPP_QUOTE'
              AND   F.quote_object_type_code = 'HEADER'
              AND   F.quote_object_id = G.quote_header_id
              AND   G.order_id = H.HEADER_ID
              AND   H.header_id = I.header_id
              AND   NVL(X.DELETED_FLAG,'N') <> 'Y'
              AND   X.source_promotion_id = a.source_code_id(+)
              AND   X.status_code = Y.status_code
              AND   Y.lead_flag = 'Y'
              AND   Y.enabled_flag = 'Y'
GROUP BY
              x.assign_sales_group_id
              ,i.creation_date
              ,x.lead_rank_id
              ,x.source_system
              ,x.status_code
              ,decode(x.status_open_flag,'Y','Yes','No')
              ,a.parent_object_type
              ,a.parent_object_id
              ,x.country
              ,a.business_unit_id
) METRIC
GROUP BY
           metric.group_id
           ,metric.transaction_create_date
           ,metric.lead_rank_id
           ,metric.lead_source
           ,metric.lead_status
           ,metric.open_flag
           ,metric.object_type
           ,metric.object_id
           ,metric.country
           ,metric.business_unit_id
) INNER
           ,bim_r_locations LOC
           ,bim_intl_dates A
WHERE
           A.trdate = INNER.transaction_create_date
           AND LOC.country (+) = INNER.country
)OUTER;

     COMMIT;


/***************************************************************/


      l_table_name := 'BIM_R_LEAD_DAILY_FACTS';
      fnd_message.set_name('BIM','BIM_R_ANALYZE_TABLE');
      fnd_message.set_token('TABLE_NAME',l_table_name,FALSE);
      fnd_file.put_line(fnd_file.log,fnd_message.get);

   -- Analyze the daily facts table
   DBMS_STATS.gather_table_stats('BIM','BIM_R_LEAD_DAILY_FACTS', estimate_percent => 5,
                                  degree => 8, granularity => 'GLOBAL', cascade =>TRUE);


   EXECUTE IMMEDIATE 'ALTER sequence '||l_schema||'.bim_r_lead_daily_facts_s CACHE 20';

/***************************************************************/

   /*  INSERT INTO WEEKLY SUMMARY TABLE */

   /* Here we are inserting the summarized data into the weekly facts by taking it from the daily facts.
     For every week we have a record since we group by that weekend date which is nothing but the Load date. */

      l_table_name := 'BIM_R_LEAD_WEEKLY_FACTS';
      fnd_message.set_name('BIM','BIM_R_POPULATE_TABLE');
      fnd_message.set_token('TABLE_NAME',l_table_name,FALSE);
      fnd_file.put_line(fnd_file.log,fnd_message.get);

   EXECUTE IMMEDIATE 'truncate table '||l_schema||'.bim_r_lead_weekly_facts';

   /*BEGIN BLOCK FOR THE WEEKLY INSERT */

      l_table_name :=    'bim_r_lead_weekly_facts';
      l_seq_name      := 'bim_r_lead_weekly_facts_s';

      INSERT /*+ append parallel(LWF,1) */
      INTO bim_r_lead_weekly_facts LWF
        (
             lead_weekly_transaction_id
            ,creation_date
            ,last_update_date
            ,created_by
            ,last_updated_by
            ,weekend_date
            ,group_id
            ,lead_rank_id
            ,lead_source
            ,lead_status
            ,open_flag
            ,object_type
            ,object_id
            ,region
            ,country
            ,business_unit_id
            ,year
            ,qtr
            ,month
            ,leads_open
            ,leads_closed
	    ,leads_new
	    ,leads_dead
	    ,leads_changed
	    ,leads_unchanged
	    ,leads_assigned
            ,opportunities
	    ,opportunities_open
	    ,quotes
	    ,quotes_open
            ,orders
        )
      SELECT /*+ parallel(INNER,1) */
	    bim_r_lead_weekly_facts_s.nextval
            ,sysdate
            ,sysdate
            ,l_user_id
            ,l_user_id
            ,weekend_date
            ,group_id
            ,lead_rank_id
            ,lead_source
            ,lead_status
            ,open_flag
            ,object_type
            ,object_id
            ,region
            ,country
            ,business_unit_id
            ,year
            ,qtr
            ,month
            ,leads_open
            ,leads_closed
	    ,leads_new
	    ,leads_dead
	    ,leads_changed
	    ,leads_unchanged
	    ,leads_assigned
            ,opportunities
	    ,opportunities_open
	    ,quotes
	    ,quotes_open
            ,orders
      FROM
      (
         SELECT
            weekend_date                        weekend_date
            ,group_id                           group_id
            ,lead_rank_id                       lead_rank_id
            ,lead_source                        lead_source
            ,lead_status                        lead_status
            ,open_flag                          open_flag
            ,object_type                        object_type
            ,object_id                          object_id
            ,region                             region
            ,country                            country
            ,business_unit_id                   business_unit_id
            ,year                               year
            ,qtr                                qtr
            ,month                              month
            ,sum(leads_open)                    leads_open
            ,sum(leads_closed)                  leads_closed
	    ,sum(leads_new)                     leads_new
	    ,sum(leads_dead)                    leads_dead
	    ,sum(leads_changed)                 leads_changed
	    ,sum(leads_unchanged)               leads_unchanged
	    ,sum(leads_assigned)                leads_assigned
            ,sum(opportunities)                 opportunities
	    ,sum(opportunities_open)            opportunities_open
	    ,sum(quotes)                        quotes
	    ,sum(quotes_open)                   quotes_open
            ,sum(orders)                        orders
         FROM    bim_r_lead_daily_facts
--	 WHERE   transaction_create_date between trunc(p_start_date) and trunc(p_end_date) + 0.99999
 	 GROUP BY
            weekend_date
	    ,year
	    ,qtr
	    ,month
            ,group_id
            ,lead_rank_id
            ,lead_source
            ,lead_status
            ,open_flag
            ,object_type
            ,object_id
            ,region
            ,country
            ,business_unit_id
         )INNER;

        LOG_HISTORY('LEADS', p_start_date, p_end_date);


    COMMIT;

      l_table_name := 'BIM_R_LEAD_WEEKLY_FACTS';
      fnd_message.set_name('BIM','BIM_R_ANALYZE_TABLE');
      fnd_message.set_token('TABLE_NAME',l_table_name,FALSE);
      fnd_file.put_line(fnd_file.log,fnd_message.get);

   -- Analyze the daily facts table
   DBMS_STATS.gather_table_stats('BIM','BIM_R_LEAD_WEEKLY_FACTS', estimate_percent => 5,
                                  degree => 8, granularity => 'GLOBAL', cascade =>TRUE);


   /* Recreating Indexes */
      BIM_UTL_PKG.CREATE_INDEX('BIM_R_LEAD_DAILY_FACTS');
      BIM_UTL_PKG.CREATE_INDEX('BIM_R_LEAD_WEEKLY_FACTS');



   EXECUTE IMMEDIATE 'ALTER sequence '||l_schema||'.bim_r_lead_weekly_facts_s CACHE 20';



EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_msg_PUB.Count_And_Get (
          --  p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

    ams_utility_pvt.write_conc_log('BIM_LEAD_FACTS_PKG:LOAD_DATA:IN EXPECTED EXCEPTION '||sqlerrm(sqlcode));

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     -- Standard call to get message count and if count=1, get the message
     FND_msg_PUB.Count_And_Get (
            --p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

    ams_utility_pvt.write_conc_log('BIM_LEAD_FACTS_PKG:LOAD_DATA:IN UNEXPECTED EXCEPTION '||sqlerrm(sqlcode));

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

    ams_utility_pvt.write_conc_log('BIM_LEAD_FACTS_PKG:LOAD_DATA:IN OTHERS EXCEPTION '||sqlerrm(sqlcode));


END LOAD_DATA;


END BIM_LEAD_FACTS_PKG;


/
