--------------------------------------------------------
--  DDL for Package Body BIM_PERIODIC_FACTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIM_PERIODIC_FACTS" AS
/* $Header: bimrlfab.pls 120.0 2005/06/01 13:01:20 appldev noship $*/

--g_pkg_name  CONSTANT  VARCHAR2(20) :='BIM_PERIODIC_FACTS';
--G_FILE_NAME CONSTANT  VARCHAR2(20) :='bimrlfab.pls';

PROCEDURE invoke_object
   (ERRBUF                  OUT  NOCOPY VARCHAR2,
    RETCODE		    OUT  NOCOPY NUMBER,
    p_api_version_number    IN   NUMBER	,
    p_object                IN   VARCHAR2  DEFAULT NULL,
    p_end_dt                IN   VARCHAR2  DEFAULT NULL,
    p_proc_num              IN   NUMBER    DEFAULT 8,
    p_full_refresh          IN   VARCHAR2  DEFAULT 'N'
    ) IS
CURSOR min_log_date IS
SELECT  TRUNC(MIN(start_date))
FROM    bim_rep_history ;

cursor max_log_date IS
select TRUNC(max(object_last_updated_date))
from bim_rep_history
where object='DATES';
    v_error_code              NUMBER;
    v_error_text              VARCHAR2(1500);
    l_start_date              DATE;
    l_end_date                DATE;
    l_user_id                 NUMBER := FND_GLOBAL.USER_ID();
    l_api_version_number      CONSTANT NUMBER       := 1.0;
    l_api_name                CONSTANT VARCHAR2(30) := 'invoke_object';
    x_msg_count	              NUMBER;
    x_msg_data		      VARCHAR2(240);
    x_return_status	      VARCHAR2(1) ;
    l_init_msg_list           VARCHAR2(10)  := FND_API.G_FALSE;
    l_min_date                DATE;
    l_max_date                DATE;
    p_end_date                DATE := FND_DATE.CANONICAL_TO_DATE(p_end_dt);

/* ==================== Truncation ==================*/
PROCEDURE truncate_facts (p_object VARCHAR2 , p_confirm VARCHAR2 ) IS

CURSOR 	trunc_camp_tables(p_owner varchar2) IS
SELECT 	'TRUNCATE TABLE '|| owner ||'.' || table_name  sqlstmt
FROM	all_tables
WHERE	table_name like  'BIM_R_CAMP_%LY%_FACTS'
AND	owner = p_owner
AND	table_name not like '%_MV%';

CURSOR 	trunc_even_tables(p_owner varchar2) IS
SELECT 	'TRUNCATE TABLE '|| owner ||'.' || table_name  sqlstmt
FROM	all_tables
WHERE	table_name like  'BIM_R_EVEN_%LY%_FACTS'
AND	owner = p_owner
AND	table_name not like '%_MV%';

CURSOR 	trunc_fund_tables(p_owner varchar2) IS
SELECT 	'TRUNCATE TABLE '|| owner ||'.' || table_name  sqlstmt
FROM	all_tables
WHERE   (table_name like  'BIM_R_FUND_%LY%_FACTS' or table_name like 'BIM_R_FDSP_%LY%_FACTS')
AND	owner = p_owner
AND	table_name not like '%_MV%';

CURSOR trunc_lead_tables(p_owner varchar2) IS
SELECT 'TRUNCATE TABLE ' || owner ||'.'||table_name sqlstmt
FROM   all_tables
WHERE  table_name like 'BIM_R_LEAD_%_FACTS'
AND    owner = p_owner
AND    table_name not like '%_MV%';

CURSOR trunc_limp_tables(p_owner varchar2) IS
SELECT 'TRUNCATE TABLE ' || owner ||'.'||table_name sqlstmt
FROM   all_tables
WHERE  table_name like 'BIM_R_LIMP_%LY%_FACTS'
AND    owner = p_owner
AND    table_name not like '%_MV%';

CURSOR trunc_resp_tables(p_owner varchar2) IS
SELECT 'TRUNCATE TABLE ' || owner ||'.'||table_name sqlstmt
FROM    all_tables
WHERE   (table_name like 'BIM_R_RRSN_%LY%_FACTS' OR table_name like 'BIM_R_RGRD_%LY%_FACTS')
AND     owner = p_owner
AND     table_name not like '%_MV%';

ddl_curs integer;

 l_status                      VARCHAR2(5);
 l_industry                    VARCHAR2(5);
 l_schema                      VARCHAR2(30);
 l_return                       BOOLEAN;

BEGIN

l_return  := fnd_installation.get_app_info('BIM', l_status, l_industry, l_schema);

------------------------------------------

IF p_confirm = 'Y' THEN

IF p_object = 'CAMPAIGN' THEN

ddl_curs := dbms_sql.open_cursor;

FOR rec in trunc_camp_tables(l_schema) LOOP

   /* Parse implicitly executes the DDL statements */

   dbms_sql.parse(ddl_curs, rec.sqlstmt,dbms_sql.native) ;

END LOOP;

dbms_sql.close_cursor(ddl_curs);

DELETE bim_rep_history
WHERE  object = 'CAMPAIGN';

END IF;

------------------------------------------

IF p_object = 'EVENT' THEN

ddl_curs := dbms_sql.open_cursor;

FOR rec in trunc_even_tables(l_schema) LOOP

   /* Parse implicitly executes the DDL statements */

   dbms_sql.parse(ddl_curs, rec.sqlstmt,dbms_sql.native) ;

END LOOP;

dbms_sql.close_cursor(ddl_curs);

DELETE bim_rep_history
WHERE  object = 'EVENT';

END IF;

------------------------------------------

IF p_object = 'BUDGET' THEN

ddl_curs := dbms_sql.open_cursor;

FOR rec in trunc_fund_tables(l_schema) LOOP

   /* Parse implicitly executes the DDL statements */

   dbms_sql.parse(ddl_curs, rec.sqlstmt,dbms_sql.native) ;

END LOOP;

dbms_sql.close_cursor(ddl_curs);

DELETE BIM_REP_HISTORY
WHERE  object = 'FUND';

END IF;

------------------------------------------

IF p_object = 'LEADS' THEN

ddl_curs := dbms_sql.open_cursor;

FOR rec in trunc_lead_tables(l_schema) LOOP

  /* Parse implicitly executes the DDL statements */

  dbms_sql.parse (ddl_curs, rec.sqlstmt, dbms_sql.native);

END LOOP;

dbms_sql.close_cursor (ddl_curs);

DELETE BIM_REP_HISTORY
WHERE object = 'LEADS';

END IF;

------------------------------------------

IF p_object = 'LEAD_IMPORT' THEN

ddl_curs := dbms_sql.open_cursor;

FOR rec in trunc_limp_tables(l_schema) LOOP

  /* Parse implicitly executes the DDL statements */

  dbms_sql.parse (ddl_curs, rec.sqlstmt, dbms_sql.native);

END LOOP;

dbms_sql.close_cursor (ddl_curs);

DELETE BIM_REP_HISTORY
WHERE object = 'LEAD_IMPORT';

END IF;

------------------------------------------

IF p_object = 'RESPONSE' THEN

ddl_curs := dbms_sql.open_cursor;

FOR rec in trunc_resp_tables(l_schema) LOOP

  /* Parse implicitly executes the DDL statements */

  dbms_sql.parse (ddl_curs, rec.sqlstmt, dbms_sql.native);

END LOOP;

dbms_sql.close_cursor (ddl_curs);

DELETE BIM_REP_HISTORY
WHERE object = 'RESPONSE';

END IF;

------------------------------------------

IF p_object = 'ALL' THEN

ddl_curs := dbms_sql.open_cursor;

   FOR rec in trunc_camp_tables(l_schema) LOOP

   /* Parse implicitly executes the DDL statements */

   dbms_sql.parse(ddl_curs, rec.sqlstmt,dbms_sql.native) ;

   END LOOP;

   DELETE bim_rep_history
   WHERE  object = 'CAMPAIGN';

   FOR rec in trunc_even_tables(l_schema) LOOP

   /* Parse implicitly executes the DDL statements */

   dbms_sql.parse(ddl_curs, rec.sqlstmt,dbms_sql.native) ;

   END LOOP;

   DELETE bim_rep_history
   WHERE  object = 'EVENT';

   FOR rec in trunc_fund_tables(l_schema) LOOP

   /* Parse implicitly executes the DDL statements */

   dbms_sql.parse(ddl_curs, rec.sqlstmt,dbms_sql.native) ;

   END LOOP;

   DELETE bim_rep_history
   WHERE  object = 'FUND';


   FOR rec in trunc_lead_tables(l_schema) LOOP

   /* Parse implicitly executes the DDL statements */

   dbms_sql.parse (ddl_curs, rec.sqlstmt, dbms_sql.native);

   END LOOP;

   DELETE BIM_REP_HISTORY
   WHERE object = 'LEADS';

   FOR rec in trunc_limp_tables(l_schema) LOOP

   /* Parse implicitly executes the DDL statements */

   dbms_sql.parse (ddl_curs, rec.sqlstmt, dbms_sql.native);

   END LOOP;

   DELETE BIM_REP_HISTORY
   WHERE object = 'LEAD_IMPORT';

   FOR rec in trunc_resp_tables(l_schema) LOOP

   /* Parse implicitly executes the DDL statements */

   dbms_sql.parse (ddl_curs, rec.sqlstmt, dbms_sql.native);

   END LOOP;

   DELETE BIM_REP_HISTORY
   WHERE object = 'RESPONSE';

dbms_sql.close_cursor(ddl_curs);

END IF;

DELETE bim_rep_history
WHERE  object = 'DATES';

END IF;

------------------------------------------

EXCEPTION
WHEN OTHERS THEN
	NULL;
END;
/* ==================== Truncation ==================*/
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


      -- Debug Message
      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      OPEN min_log_date;
      FETCH min_log_date into l_min_date;
      CLOSE min_log_date;

 IF p_full_refresh = 'Y' AND l_min_date is NOT NULL THEN
	BEGIN
	  truncate_facts (p_object ,'Y');
	  BEGIN
           bim_first_load_facts.invoke_object (ERRBUF,
	                                       RETCODE,
					       1,
					       p_object,
					       TO_CHAR(l_min_date,'YYYY/MM/DD HH24:MI:SS'),
					       TO_CHAR(p_end_date,'YYYY/MM/DD HH24:MI:SS'),
					       p_proc_num);
	  END;
	END;
  ELSIF  p_full_refresh = 'Y' AND l_min_date is NULL THEN
                ams_utility_pvt.write_conc_log('First Time Load is not run. Please run the Initial Load.');
                ams_utility_pvt.write_conc_log('Concurrent Program Exits Now');
                RAISE FND_API.G_EXC_ERROR;
  ELSE
    BEGIN
      OPEN max_log_date;
      FETCH max_log_date into l_max_date;
      CLOSE max_log_date;
      IF (l_max_date is null) or (l_max_date < TRUNC(sysdate)) THEN
      BIM_POPDATES_PKG.pop_intl_dates(l_min_date);
      END IF;


              BIM_SOURCE_CODE_PKG.LOAD_DATA(p_api_version_number=>1
                                     ,x_msg_count     => x_msg_count
                                     ,x_msg_data      => x_msg_data
                                     ,x_return_status => x_return_status);


	 IF p_object = 'CAMPAIGN' THEN

		  bim_campaign_facts.populate
                                     (p_api_version_number => 1.0
                                     ,p_init_msg_list => FND_API.G_FALSE
                                     ,x_msg_count     => x_msg_count
                                     ,x_msg_data      => x_msg_data
                                     ,x_return_status => x_return_status
                                     ,p_object        => p_object
                                     ,p_start_date    => NULL
                                     ,p_end_date      => p_end_date
                                     ,p_para_num      => p_proc_num
                                     );
                  IF    x_return_status = FND_API.g_ret_sts_error
                  THEN
                     RAISE FND_API.g_exc_error;
                  ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
                     RAISE FND_API.g_exc_unexpected_error;
                  END IF;


	   ELSIF
 	   	   p_object = 'EVENT' THEN


		   bim_event_facts.POPULATE (
                                      p_api_version_number => 1.0,
                                      p_init_msg_list      => FND_API.G_FALSE,
                                      x_msg_count          => x_msg_count         ,
                                      x_msg_data           => x_msg_data        ,
                                      x_return_status      => x_return_status   ,
                                      p_object             => 'EVENT',
                                      p_start_date         => NULL,
                                      p_end_date           => p_end_date,
				                      p_para_num           => p_proc_num
                                      );
                  IF    x_return_status = FND_API.g_ret_sts_error
                  THEN
                     RAISE FND_API.g_exc_error;
                  ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
                     RAISE FND_API.g_exc_unexpected_error;
                  END IF;

           ELSIF
                   p_object = 'RESPONSE' THEN

                   bim_response_facts_pkg.populate (
                                      p_api_version_number => 1.0,
                                      p_init_msg_list      => FND_API.G_FALSE,
                                      x_msg_count          => x_msg_count         ,
                                      x_msg_data           => x_msg_data        ,
                                      x_return_status      => x_return_status   ,
                                      p_start_date         => NULL,
                                      p_end_date           => p_end_date,
                                      p_para_num           => p_proc_num
                                      );
                  IF    x_return_status = FND_API.g_ret_sts_error
                  THEN
                     RAISE FND_API.g_exc_error;
                  ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
                     RAISE FND_API.g_exc_unexpected_error;
                  END IF;
         ELSIF
           p_object = 'LEAD_IMPORT' THEN

		   bim_lead_import_facts_pkg.POPULATE (
                                      p_api_version_number => 1.0,
                                      p_init_msg_list      => FND_API.G_FALSE,
                                      x_msg_count          => x_msg_count         ,
                                      x_msg_data           => x_msg_data        ,
                                      x_return_status      => x_return_status   ,
                                      p_object             => 'EVENT',
                                      p_start_date         => NULL,
                                      p_end_date           => p_end_date,
				                      p_para_num           => p_proc_num
                                      );
                  IF    x_return_status = FND_API.g_ret_sts_error
                  THEN
                     RAISE FND_API.g_exc_error;
                  ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
                     RAISE FND_API.g_exc_unexpected_error;
                  END IF;
           ELSIF
                   p_object = 'LEADS' THEN

                   bim_lead_facts_pkg.POPULATE (
                                      p_api_version_number => 1.0,
                                      p_init_msg_list      => FND_API.G_FALSE,
                                      x_msg_count          => x_msg_count         ,
                                      x_msg_data           => x_msg_data        ,
                                      x_return_status      => x_return_status   ,
                                      p_object             => p_object,
                                      p_start_date         => NULL,
                                      p_end_date           => p_end_date,
                                      p_para_num           => p_proc_num
                                      );
                  IF    x_return_status = FND_API.g_ret_sts_error
                  THEN
                     RAISE FND_API.g_exc_error;
                  ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
                     RAISE FND_API.g_exc_unexpected_error;
                  END IF;


	   ELSIF
   		 p_object = 'BUDGET'THEN

	         bim_fund_facts.populate (
                          	      p_api_version_number => 1.0,
                                      p_init_msg_list      => FND_API.G_FALSE,
                                      x_msg_count          => x_msg_count      ,
                                      x_msg_data           => x_msg_data    ,
                                      x_return_status      => x_return_status    ,
                                      P_OBJECT             => 'FUND',
                                      p_start_date    => NULL,
                                      P_END_DATE           => p_end_date,
				      p_para_num           => p_proc_num
			              );
                  IF    x_return_status = FND_API.g_ret_sts_error
                  THEN
                     RAISE FND_API.g_exc_error;
                  ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
                     RAISE FND_API.g_exc_unexpected_error;
                  END IF;

	   ELSIF
		  p_object = 'ALL' THEN

		  bim_campaign_facts.populate
                                     (p_api_version_number => 1.0
                                     ,p_init_msg_list => FND_API.G_FALSE
                                     ,x_msg_count     => x_msg_count
                                     ,x_msg_data      => x_msg_data
                                     ,x_return_status => x_return_status
                                     ,p_object        => 'CAMPAIGN'
                                     ,p_start_date    => NULL
                                     ,p_end_date      => p_end_date
                                     ,p_para_num      => p_proc_num
                                     );

                  IF    x_return_status = FND_API.g_ret_sts_error
                  THEN
                     RAISE FND_API.g_exc_error;
                  ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
                     RAISE FND_API.g_exc_unexpected_error;
                  END IF;

  		  bim_event_facts.populate (
                                      p_api_version_number => 1.0,
                                      p_init_msg_list      => FND_API.G_FALSE,
                                      x_msg_count          => x_msg_count         ,
                                      x_msg_data           => x_msg_data        ,
                                      x_return_status      => x_return_status   ,
                                      p_object             => 'EVENT',
                                      p_start_date         => NULL,
                                      p_end_date           => p_end_date,
			                          p_para_num           => p_proc_num
				      );
                  IF    x_return_status = FND_API.g_ret_sts_error
                  THEN
                     RAISE FND_API.g_exc_error;
                  ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
                     RAISE FND_API.g_exc_unexpected_error;
                  END IF;

                  bim_response_facts_pkg.populate (
                                      p_api_version_number => 1.0,
                                      p_init_msg_list      => FND_API.G_FALSE,
                                      x_msg_count          => x_msg_count         ,
                                      x_msg_data           => x_msg_data        ,
                                      x_return_status      => x_return_status   ,
                                      p_start_date         => NULL,
                                      p_end_date           => p_end_date,
                                      p_para_num           => p_proc_num
                                      );
                  IF    x_return_status = FND_API.g_ret_sts_error
                  THEN
                     RAISE FND_API.g_exc_error;
                  ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
                     RAISE FND_API.g_exc_unexpected_error;
                  END IF;

                  bim_lead_facts_pkg.POPULATE (
                                      p_api_version_number => 1.0,
                                      p_init_msg_list      => FND_API.G_FALSE,
                                      x_msg_count          => x_msg_count         ,
                                      x_msg_data           => x_msg_data        ,
                                      x_return_status      => x_return_status   ,
                                      p_object             => p_object,
                                      p_start_date         => NULL,
                                      p_end_date           => p_end_date,
                                      p_para_num           => p_proc_num
                                      );
                  IF    x_return_status = FND_API.g_ret_sts_error
                  THEN
                     RAISE FND_API.g_exc_error;
                  ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
                     RAISE FND_API.g_exc_unexpected_error;
                  END IF;

              bim_lead_import_facts_pkg.POPULATE (
                                      p_api_version_number => 1.0,
                                      p_init_msg_list      => FND_API.G_FALSE,
                                      x_msg_count          => x_msg_count         ,
                                      x_msg_data           => x_msg_data        ,
                                      x_return_status      => x_return_status   ,
                                      p_object             => 'EVENT',
                                      p_start_date         => NULL,
                                      p_end_date           => p_end_date,
				                      p_para_num           => p_proc_num
                                      );
                  IF    x_return_status = FND_API.g_ret_sts_error
                  THEN
                     RAISE FND_API.g_exc_error;
                  ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
                     RAISE FND_API.g_exc_unexpected_error;
                  END IF;

	          bim_fund_facts.populate (
                          	      p_api_version_number  => 1.0,
                                      p_init_msg_list       => FND_API.G_FALSE,
                                      x_msg_count           => x_msg_count      ,
                                      x_msg_data            => x_msg_data    ,
                                      x_return_status       => x_return_status    ,
                                      p_object              => 'FUND',
                                      p_start_date          => NULL,
                                      p_end_date            => p_end_date,
				      p_para_num            => p_proc_num
				      );

                  IF    x_return_status = FND_API.g_ret_sts_error
                  THEN
                     RAISE FND_API.g_exc_error;
                  ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
                     RAISE FND_API.g_exc_unexpected_error;
                  END IF;

	      END IF;

	  	  AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'End');

   EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
	 x_return_status := FND_API.g_ret_sts_error ;
	 FND_MSG_PUB.count_and_get (p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count,
                                p_data    => x_msg_data);
     ERRBUF := x_msg_data;
     RETCODE := 2;
     ams_utility_pvt.write_conc_log(sqlerrm(sqlcode));
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    	x_return_status := FND_API.g_ret_sts_unexp_error ;
    FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,
            				   p_count => x_msg_count,
                               p_data  => x_msg_data);
     ERRBUF := x_msg_data;
     RETCODE := 2;
     ams_utility_pvt.write_conc_log(sqlerrm(sqlcode));
   WHEN OTHERS THEN
        	x_return_status := FND_API.g_ret_sts_unexp_error ;
     FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,
             				    p_count => x_msg_count,
                                p_data  => x_msg_data);
     ERRBUF  := sqlerrm(sqlcode);
     RETCODE := sqlcode;
     ams_utility_pvt.write_conc_log(sqlerrm(sqlcode));
   END;
 END IF;
END invoke_object;
END bim_periodic_facts;

/
