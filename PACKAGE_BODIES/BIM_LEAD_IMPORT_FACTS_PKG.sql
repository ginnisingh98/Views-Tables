--------------------------------------------------------
--  DDL for Package Body BIM_LEAD_IMPORT_FACTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIM_LEAD_IMPORT_FACTS_PKG" AS
/* $Header: bimlisfb.pls 120.2 2005/11/11 05:09:14 arvikuma noship $ */

G_PKG_NAME  CONSTANT  VARCHAR2(200) :='BIM_LEAD_IMPORT_FACTS_PKG';
G_FILE_NAME CONSTANT  VARCHAR2(20)  :='bimldsfb.pls';
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
   (p_api_version_number      IN   NUMBER,
    p_init_msg_list	      IN   VARCHAR2	:= FND_API.G_FALSE,
    p_validation_level        IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    p_commit                  IN   VARCHAR2     := FND_API.G_FALSE,
    x_msg_count		      OUT  NOCOPY NUMBER,
    x_msg_data		      OUT  NOCOPY VARCHAR2,
    x_return_status	      OUT  NOCOPY VARCHAR2,
    p_object		      IN   VARCHAR2,
    p_start_date	      IN   DATE,
    p_end_date		      IN   DATE,
    p_para_num                IN   NUMBER
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
    WHERE   object = 'LEAD_IMPORT';

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
	IF (l_max_end_date IS NOT NULL AND p_start_date IS NOT NULL)
	THEN
    fnd_message.set_name('BIM','BIM_R_FIRST_LOAD');
    fnd_message.set_token('END_DATE', l_max_end_date, FALSE);
    ams_utility_pvt.write_conc_log(fnd_message.get);
		RAISE FND_API.G_EXC_ERROR;
  elsif (l_max_end_date IS NULL AND p_start_date IS NULL) THEN
        fnd_message.set_name('BIM','BIM_R_FIRST_SUBSEQUENT');
        ams_utility_pvt.write_conc_log(fnd_message.get);
  	RAISE FND_API.G_EXC_ERROR;
	END IF;


IF p_start_date IS NOT NULL THEN

	    IF (p_start_date > p_end_date) THEN
        fnd_message.set_name('BIM','BIM_R_DATE_VALIDATION');
        ams_utility_pvt.write_conc_log(fnd_message.get);
     RAISE FND_API.G_EXC_ERROR;
	    END IF;
               		LOAD_DATA(p_start_datel => p_start_date
                                    ,p_end_datel =>  l_end_date
									,p_api_version_number => l_api_version_number
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
                 fnd_message.set_name('BIM','BIM_R_SUBSEQUENT_LOAD');
                 fnd_message.set_token('END_DATE', l_max_end_date, FALSE);
                 ams_utility_pvt.write_conc_log(fnd_message.get);
        	      RAISE FND_API.g_exc_error;
	   	       END IF;

                	LOAD_DATA(p_start_datel => l_max_end_date + 1
                                    ,p_end_datel =>  l_end_date
									,p_api_version_number => l_api_version_number
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

        IF FND_API.To_Boolean ( p_commit ) THEN
          COMMIT WORK;
        END IF;
   commit;

        fnd_message.set_name('BIM','BIM_R_END_FACTS');
        fnd_message.set_token('OBJECT_NAME', 'LEAD IMPORT', FALSE);
        fnd_file.put_line(fnd_file.log,fnd_message.get);

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
	p_end_date          DATE )
IS
    l_user_id		 NUMBER := FND_GLOBAL.USER_ID();
    p_table_name	 VARCHAR2(100):='BIM_REP_HISTORY';
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

PROCEDURE LOAD_DATA
(p_start_datel		        DATE,
 p_end_dateL		        DATE,
 p_api_version_number           NUMBER,
 x_msg_count		        OUT NOCOPY NUMBER,
 x_msg_data		        OUT NOCOPY VARCHAR2,
 x_return_status	        OUT NOCOPY VARCHAR2
)
IS
l_user_id                NUMBER := FND_GLOBAL.USER_ID();
l_success                VARCHAR2(1) := 'F';
l_api_version_number	 CONSTANT NUMBER	:= 1.0;
l_api_name		         CONSTANT VARCHAR2(30) := 'LEAD_IMPORT_LOAD_DATA';
l_profile                NUMBER;
p_table_name             VARCHAR2(100);
l_temp_msg		             VARCHAR2(100);
l_def_tablespace         VARCHAR2(100);
l_index_tablespace       VARCHAR2(100);
l_oracle_username        VARCHAR2(100);
l_max_end_date	         DATE;

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
   l_uniqueness 	         generic_char_table;
   temp_column_string       VARCHAR2(2000);
   temp_column_position     NUMBER;
   temp_index_name          VARCHAR2(30);
   is_unique                VARCHAR2(30);
   l_column_position        generic_number_table;


   l_event_offer number;
   l_min_date    date;
   l_object      varchar(100);
l_status                      VARCHAR2(5);
    l_industry                    VARCHAR2(5);
    l_schema                      VARCHAR2(30);
    l_return                       BOOLEAN;
BEGIN
      l_return  := fnd_installation.get_app_info('BIM', l_status, l_industry, l_schema);

l_object := 'LEAD IMPORT';
fnd_message.set_name('BIM','BIM_R_START_FACTS');
fnd_message.set_token('P_OBJECT', l_object, FALSE);
ams_utility_pvt.write_conc_log(fnd_message.get);

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
					   l_api_version_number,
					   l_api_name,
					   G_PKG_NAME)
      THEN
	  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      EXECUTE IMMEDIATE 'ALTER SESSION ENABLE PARALLEL dml ';
      EXECUTE IMMEDIATE 'ALTER TABLE '||l_schema||'. bim_r_limp_daily_facts nologging';
      EXECUTE IMMEDIATE 'ALTER TABLE '||l_schema||'. bim_r_limp_weekly_facts nologging';
      EXECUTE IMMEDIATE 'ALTER sequence '||l_schema||'. bim_r_limp_daily_facts_s CACHE 1000';

    p_table_name := 'BIM_R_LIMP_DAILY_FACTS';

    fnd_message.set_name('BIM','BIM_R_DROP_INDEXES');
    ams_utility_pvt.write_conc_log(fnd_message.get);

    BIM_UTL_PKG.DROP_INDEX(p_table_name);
    BIM_UTL_PKG.DROP_INDEX('BIM_R_LIMP_WEEKLY_FACTS');


    fnd_message.set_name('BIM','BIM_R_POPULATE_TABLE');
    fnd_message.set_token('TABLE_NAME', 'BIM_R_LIMP_DAILY_FACTS', FALSE);
    ams_utility_pvt.write_conc_log(fnd_message.get);

 BEGIN
   INSERT INTO /*+ append parallel(EDF,1) */
          BIM_R_LIMP_DAILY_FACTS EDF(
	      Daily_transaction_id,
          Creation_date,
          Last_update_date,
          Created_by,
          Last_updated_by,
          Last_update_login,
          parent_object_id,
          Object_id,
          parent_object_type,
          object_type,
          lead_region,
          lead_country,
          object_business_unit_id,
          lead_import_status,
          Failure_reason,
          month,
          qtr,
          year,
          leads_valid,
          leads_invalid,
          leads_new,
          Transaction_create_date,
          weekend_date)
   select /*+ parallel(OUTER,1) */
        BIM_R_LIMP_DAILY_FACTS_S.nextval,
        sysdate,
        sysdate,
        l_user_id,
        l_user_id,
        l_user_id,
        parent_object_id,
        Object_id,
        parent_object_type,
        object_type,
        lead_region,
        lead_country,
        object_business_unit_id,
        lead_import_status,
        Failure_reason,
        month,
        qtr,
        year,
        leads_valid,
        leads_invalid,
        leads_new,
        creation_date,
        trunc((decode(decode( to_char(creation_date,'MM') , to_char(next_day(creation_date,TO_NUMBER(to_char(to_date('07/09/2004', 'DD/MM/RRRR'), 'DD'))),'MM') ,'TRUE','FALSE' )
      	        ,'TRUE'
      	        ,decode(decode(creation_date , (next_day(creation_date, TO_NUMBER(to_char(to_date('07/09/2004', 'DD/MM/RRRR'), 'DD'))) - 7) , 'TRUE' ,'FALSE')
       	        ,'TRUE'
      	        ,creation_date
      	        ,'FALSE'
      	        ,next_day(creation_date, TO_NUMBER(to_char(to_date('07/09/2004', 'DD/MM/RRRR'), 'DD'))))
      	        ,'FALSE'
      	        ,decode(decode(to_char(creation_date,'MM'),to_char(next_day(creation_date,TO_NUMBER(to_char(to_date('07/09/2004', 'DD/MM/RRRR'), 'DD'))),'MM'),'TRUE','FALSE')
      	        ,'FALSE'
      	        ,last_day(creation_date)))))    weekend_date
from(
SELECT  b.parent_object_type parent_object_type,
        b.object_type object_type,
        b.parent_object_id parent_object_id,
        b.object_id object_id,
        b.business_unit_id object_business_unit_id,
        a.last_update_date creation_date,
        c.country lead_country,
        c.region lead_region,
        a.load_status lead_import_status,
        d.fiscal_month month,
        d.fiscal_qtr qtr,
        d.fiscal_year year,
        a.Failure_reason Failure_reason,
        sum(a.leads_valid) leads_valid,
        SUM(a.leads_new) leads_new,
        SUM(a.leads_Invalid) leads_Invalid
FROM(
SELECT  a.promotion_code,
        a.country,
        TRUNC(a.last_update_date) last_update_date,
        a.Import_interface_id,
        a.load_status,
        NULL failure_reason,
        decode(A.Load_Status, 'SUCCESS', 1, 0) leads_valid,
        decode(A.Load_Status, 'NEW', 1, 0) leads_new,
        0 leads_invalid
from    AS_IMPORT_INTERFACE A
where   a.last_update_date between p_start_datel and p_end_datel+0.9999
AND     a.load_status IN ('SUCCESS', 'NEW')
group by a.promotion_code,
        a.country,
        TRUNC(a.last_update_date),
        a.Import_interface_id,
        a.load_status
UNION ALL
SELECT  a.promotion_code,
        a.country,
        MAX(TRUNC(B.last_update_date)) last_update_date,
        a.Import_interface_id,
        a.load_status,
        max(b.error_text) FAILURE_REASON,
        0 leads_valid,
        0 leads_new,
        decode(A.Load_Status, 'ERROR', 1,'UNEXP_ERROR', 1, 0) leads_Invalid
from    AS_IMPORT_INTERFACE a,
        AS_LEAD_IMPORT_ERRORS B
where   a.last_update_date between p_start_datel and p_end_datel +0.9999
and     a.Import_interface_id = B.import_interface_id(+)
AND     a.load_status IN ('ERROR', 'UNEXP_ERROR')
group by a.promotion_code,
        a.country,
        TRUNC(a.last_update_date),
        a.Import_interface_id,
        a.load_status) A,
      bim_r_source_codes b,
      bim_r_locations c,
      bim_intl_dates d
where   a.promotion_code = b.source_code(+)
and     a.country = c.country
and     a.last_update_date = d.trdate
group by b.parent_object_type,
        b.object_type,
        b.parent_object_id,
        b.object_id,
        b.business_unit_id,
        a.last_update_date,
        c.country,
        c.region,
        a.load_status,
        b.business_unit_id,
        d.fiscal_month,
        d.fiscal_qtr,
        d.fiscal_year,
        a.failure_reason) OUTER;

    commit;
  --  dbms_output.put_line('after daily insert ');

 -- analyze the bim_r_limp_daily_facts with dbms_stats
    fnd_message.set_name('BIM','BIM_R_ANALYZE_TABLE');
    fnd_message.set_token('table_name', p_table_name, FALSE);
    ams_utility_pvt.write_conc_log(fnd_message.get);


BEGIN
   DBMS_STATS.gather_table_stats('BIM','bim_r_limp_daily_facts', estimate_percent => 5,
                                  degree => 8, granularity => 'GLOBAL', cascade =>TRUE);
END;


EXCEPTION
   WHEN OTHERS THEN
       EXECUTE IMMEDIATE 'ALTER sequence '||l_schema||'. bim_r_limp_daily_facts_s CACHE 20';
		   x_return_status := FND_API.G_RET_STS_ERROR;
		  FND_MESSAGE.Set_Name ('AMS', 'AMS_REP_INSERT_ERROR');
		  FND_MESSAGE.Set_token('table_name', p_table_name, FALSE);
		  FND_MSG_PUB.Add;
   ams_utility_pvt.write_conc_log('LEAD IMPORT: EXCEPTION FOR FIRST INSERT. '||sqlerrm(sqlcode));
   RAISE FND_API.G_EXC_ERROR;
end;

   p_table_name :='BIM_R_LIMP_WEEKLY_FACTS';

    fnd_message.set_name('BIM','BIM_R_TRUNCATE_TABLE');
    fnd_message.set_token('table_name', p_table_name, FALSE);
    ams_utility_pvt.write_conc_log(fnd_message.get);

EXECUTE IMMEDIATE 'truncate table '||l_schema||'. bim_r_limp_weekly_facts';
   --insert into BIM_R_LIMP_WEEKLY_FACTS table
  BEGIN

    fnd_message.set_name('BIM','BIM_R_POPULATE_TABLE');
    fnd_message.set_token('TABLE_NAME', 'BIM_R_LIMP_WEEKLY_FACTS', FALSE);
    ams_utility_pvt.write_conc_log(fnd_message.get);

   INSERT INTO
          BIM_R_LIMP_WEEKLY_FACTS EDF(
	      weekly_transaction_id,
          Creation_date,
          Last_update_date,
          Created_by,
          Last_updated_by,
          Last_update_login,
          Lead_Region,
          Lead_Country,
          Object_Business_unit_id,
          Lead_Import_Status,
          Object_id,
          Object_type,
          Parent_object_id,
          Parent_object_type,
          FAILURE_REASON,
          Month,
          Qtr,
          Year,
          leads_valid,
          leads_invalid,
          leads_new,
          Weekend_date
	     )
     SELECT
          BIM_R_LIMP_WEEKLY_FACTS_S.nextval,
          sysdate,
          sysdate,
          l_user_id,
          l_user_id,
          l_user_id,
          Lead_Region,
          Lead_Country,
          Object_Business_unit_id,
          Lead_Import_Status,
          Object_id,
          Object_type,
          Parent_object_id,
          Parent_object_type,
          FAILURE_REASON,
          Month,
          Qtr,
          Year,
          leads_valid,
          leads_invalid,
          leads_new,
          Weekend_date
  from( select Lead_Region,
          Lead_Country,
          Object_Business_unit_id,
          Lead_Import_Status,
          Object_id,
          Object_type,
          Parent_object_id,
          Parent_object_type,
          FAILURE_REASON,
          Month,
          Qtr,
          Year,
          sum(Leads_valid) leads_valid,
          sum(Leads_invalid) leads_invalid,
          sum(Leads_new) leads_new,
          Weekend_date
     FROM BIM_R_LIMP_DAILY_FACTS
     group by
          Lead_Region,
          Lead_Country,
          Object_Business_unit_id,
          Lead_Import_Status,
          Object_id,
          Object_type,
          Parent_object_id,
          Parent_object_type,
          FAILURE_REASON,
          Month,
          Qtr,
          Year,
          Weekend_date);


  LOG_HISTORY(
	    'LEAD_IMPORT',
		p_start_datel,
		p_end_datel
        );

COMMIT;

 -- analyze the bim_r_limp_daily_facts with dbms_stats
    fnd_message.set_name('BIM','BIM_R_ANALYZE_TABLE');
    fnd_message.set_token('table_name', p_table_name, FALSE);
    ams_utility_pvt.write_conc_log(fnd_message.get);

BEGIN
   DBMS_STATS.gather_table_stats('BIM','bim_r_limp_weekly_facts', estimate_percent => 5,
                                  degree => 8, granularity => 'GLOBAL', cascade =>TRUE);
END;

    fnd_message.set_name('BIM','BIM_R_RECREATE_INDEXES');
    ams_utility_pvt.write_conc_log(fnd_message.get);

    BIM_UTL_PKG.CREATE_INDEX('BIM_R_LIMP_DAILY_FACTS');
    BIM_UTL_PKG.CREATE_INDEX('BIM_R_LIMP_WEEKLY_FACTS');

 EXECUTE IMMEDIATE 'ALTER sequence '||l_schema||'. bim_r_limp_weekly_facts_s CACHE 20';


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

    ams_utility_pvt.write_conc_log('BIM_LEAD_IMPORT_FACTS_PKG:LOAD_DATA:IN OTHERS EXCEPTION '||sqlerrm(sqlcode));
END;
END LOAD_DATA;

END BIM_LEAD_IMPORT_FACTS_PKG;

/
