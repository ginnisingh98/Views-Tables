--------------------------------------------------------
--  DDL for Package Body BIM_BUDGETS_DENORM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIM_BUDGETS_DENORM_PKG" AS
/*$Header: bimbgtdb.pls 120.4 2005/10/17 07:40:48 sbassi noship $*/

g_pkg_name  CONSTANT  VARCHAR2(20) := 'BIM_BUDGETS_DENORM';
g_file_name CONSTANT  VARCHAR2(20) := 'bimbgtdb.pls';

PROCEDURE COMMON_UTILITIES
   ( l_global_start_date OUT NOCOPY DATE
    ,l_period_from OUT NOCOPY DATE
    ,l_period_to OUT NOCOPY DATE
    ,l_temp_start_date OUT NOCOPY DATE
    ,l_start_date OUT NOCOPY DATE
    ,l_end_date OUT NOCOPY DATE
    ) IS
    l_global_date CONSTANT DATE := bis_common_parameters.get_global_start_date;

 BEGIN
 l_global_start_date := l_global_date;

  BEGIN
	/* Set up the Object */
		IF NOT bis_collection_utilities.setup('BIM_BUDGET_DENORM')  THEN
			bis_collection_utilities.log('Object Not Setup Properly ');
		END IF;

	bis_collection_utilities.get_last_refresh_dates('BIM_BUDGET_DENORM'
			,l_start_date,l_end_date,l_period_from,l_period_to);

	EXCEPTION
	WHEN NO_DATA_FOUND THEN
		l_end_date := NULL;
		bis_collection_utilities.log('First time running the concurrent program  ');
	WHEN OTHERS THEN
		bis_collection_utilities.log('program  '|| sqlerrm(sqlcode));
  END;

       /* End of the code for checking the data will be loaded for the first time or not. */

       IF l_period_to IS NULL THEN
                l_temp_start_date := sysdate-5000;
       ELSE
	    	l_temp_start_date := l_period_to;
       END IF;

END COMMON_UTILITIES;

PROCEDURE POPULATE
   (ERRBUF                  OUT NOCOPY VARCHAR2
    ,RETCODE                OUT NOCOPY NUMBER
    ,p_api_version_number   IN  NUMBER
    ,p_proc_num             IN  NUMBER
    ,p_load_type	    IN  VARCHAR2
    ) IS

l_api_version_number      CONSTANT NUMBER       := 1.0;
l_api_name                CONSTANT VARCHAR2(30) := 'POPULATE';
x_msg_count               NUMBER;
x_msg_data                VARCHAR2(240);
x_return_status           VARCHAR2(1) ;
l_init_msg_list           VARCHAR2(10)  := FND_API.G_FALSE;

BEGIN

   -- Standard call to check for call compatibility.
     IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                          p_api_version_number,
                                          l_api_name,
                                          g_pkg_name)
     THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

    POPULATE_DENORM
    (p_api_version_number => 1.0
    ,x_msg_Count          => x_msg_count
    ,x_msg_Data           => x_msg_data
    ,x_return_status      => x_return_status
    ,p_proc_num           => p_proc_num
    ,p_load_type	  => p_load_type
    );

   IF    x_return_status = FND_API.g_ret_sts_error
   THEN
          RAISE FND_API.g_exc_error;
   ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
          RAISE FND_API.g_exc_unexpected_error;
   END IF;

   IF    x_return_status = FND_API.g_ret_sts_error
   THEN
          RAISE FND_API.g_exc_error;
   ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
          RAISE FND_API.g_exc_unexpected_error;
   END IF;

 EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
         x_return_status := FND_API.g_ret_sts_error ;
         FND_MSG_PUB.count_and_get (p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count,
                                p_data    => x_msg_data);
     ERRBUF := x_msg_data;
     RETCODE := 2;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.g_ret_sts_unexp_error ;
    FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,
                                           p_count => x_msg_count,
                               p_data  => x_msg_data);
     ERRBUF := x_msg_data;
     RETCODE := 2;

   WHEN OTHERS THEN
                x_return_status := FND_API.g_ret_sts_unexp_error ;
     FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,
                                            p_count => x_msg_count,
                                p_data  => x_msg_data);
     ERRBUF  := sqlerrm(sqlcode);
     RETCODE := sqlcode;

END POPULATE;

PROCEDURE POPULATE_DENORM
    (p_api_version_number    IN  NUMBER
    ,p_init_msg_list         IN  VARCHAR2     := FND_API.G_FALSE
    ,p_validation_level      IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL
    ,p_commit                IN  VARCHAR2     := FND_API.G_FALSE
    ,x_msg_Count             OUT NOCOPY NUMBER
    ,x_msg_Data              OUT NOCOPY VARCHAR2
    ,x_return_status         OUT NOCOPY VARCHAR2
    ,p_proc_num              IN  NUMBER
    ,p_load_type	     IN  VARCHAR2
    ) IS

 --l_date               DATE  :=  bis_common_parameters.get_global_start_date;
 l_date			DATE;
 l_temp_start_date      DATE;
 l_temp_end_date        DATE;
 l_api_version_number   CONSTANT NUMBER       := 1.0;
 l_api_name             CONSTANT VARCHAR2(30) := 'POPULATE_DENORM';
 l_init_msg_list        VARCHAR2(10)  := FND_API.G_FALSE;

 l_start_date		DATE;
 l_end_date		DATE;
 l_period_from		DATE;
 l_period_to		DATE;

 l_status       VARCHAR2(5);
 l_industry     VARCHAR2(5);
 l_schema       VARCHAR2(30);
 l_return       BOOLEAN;

 BEGIN


	IF p_load_type = 'F' THEN

		--it is a call for First/Inital load, then truncate the denorm table first
		bis_collection_utilities.log('Truncating the Budget Denorm Table ');

		l_return  := fnd_installation.get_app_info('BIM', l_status, l_industry, l_schema);

		Execute Immediate 'Truncate Table '||l_schema||'.bim_i_budgets_denorm';

		BIS_COLLECTION_UTILITIES.deleteLogForObject('BIM_BUDGET_DENORM');

	ELSE
		/* This piece of code is for the budgets that have changed from one parent to another. */
  	          DELETE  bim_i_budgets_denorm
      		  WHERE	  object_id IN
                              	(SELECT  fund_id
                              	FROM	 ozf_funds_all_b a
                              	WHERE    last_update_date > l_temp_start_date
		                AND NOT EXISTS
                                (SELECT	1
                                 FROM	bim_i_budgets_denorm b
                                 WHERE	b.object_id = a.fund_id
				 AND    b.object_type='BUDGET'
                                 AND    b.parent_object_id = a.parent_fund_id)
			         );

  	          DELETE  bim_i_budgets_denorm
      		  WHERE	  object_id IN
                              	(SELECT  category_id
                              	FROM	 ams_categories_b a
                              	WHERE   arc_category_created_for='FUND'
                                AND     last_update_date > l_temp_start_date
		                AND NOT EXISTS
                                (SELECT	1
                                 FROM	bim_i_budgets_denorm b
                                 WHERE  b.object_id = a.category_id
				 AND    b.object_type='CATEGORY'
                                 AND    b.parent_object_id = a.parent_category_id)
			         );
	END IF;


   COMMON_UTILITIES
   ( l_date
    ,l_period_from
    ,l_period_to
    ,l_temp_start_date
    ,l_start_date
    ,l_end_date
    );

      INSERT INTO  bim_i_budgets_denorm
      (object_id
      ,child_denorm_id
      ,object_type
      ,child_denorm_type
      ,object_level
      ,immediate_child_flag
      ,parent_object_id
      ,creation_date
      ,last_update_date
      ,created_by
      ,last_updated_by
      ,last_update_login
      ,object_sub_type
      ,object_sub_cat
      ,leaf_node_flag)
       SELECT
       fund_id object_id
       ,TO_NUMBER(NVL(SUBSTR(SYS_CONNECT_BY_PATH(fund_id,'/'),2,
		INSTR(SYS_CONNECT_BY_PATH(fund_id,'/'),'/',2) -2),fund_id)) AS child_denorm_id
      ,'BUDGET'
      ,'BUDGET'
      ,LEVEL
      ,decode(level,2,'Y',decode(parent_fund_id,NULL,'N','Y')) immediate_child_flag
      ,parent_fund_id
      ,sysdate
      ,sysdate
      ,-1
      ,-1
      ,-1
      ,fund_type
      ,category_id
      ,'N'
       FROM   ozf_funds_all_b a
       WHERE
       NOT EXISTS
              (SELECT 1
                 FROM bim_i_budgets_denorm b
                WHERE b.object_id = a.fund_id
                  AND b.object_type ='BUDGET'
                  AND nvl(b.parent_object_id,1) = nvl(a.parent_fund_id,1))
      CONNECT BY PRIOR parent_fund_id = fund_id
      UNION ALL
      SELECT   category_id
      	,TO_NUMBER(NVL(SUBSTR(SYS_CONNECT_BY_PATH(category_id,'/'),2,
		INSTR(SYS_CONNECT_BY_PATH(category_id,'/'),'/',2) -2),category_id)) AS child_denorm_id
      ,'CATEGORY'
      ,'CATEGORY'
      ,LEVEL
      ,decode(level,2,'Y',decode(parent_category_id,NULL,'N','Y')) immediate_child_flag
      ,parent_category_id
      	,sysdate
      	,sysdate
      	,-1
      	,-1
      	,-1
	,'CATEGORY'
	,0
      ,'N'
       FROM   ams_categories_b a
       WHERE  arc_category_created_for='FUND'
       AND    NOT EXISTS
             (SELECT 1
               FROM bim_i_budgets_denorm b
               WHERE b.object_id = a.category_id
                 AND b.object_type ='CATEGORY'
                 AND nvl(b.parent_object_id,1) = nvl(a.parent_category_id,1))
      connect by prior parent_category_id = category_id ;
commit;
 update bim_i_budgets_denorm bd
 set leaf_node_flag='Y'
 where (object_id,object_type) in(
 select object_id, object_type from bim_i_budgets_denorm a
 where   child_denorm_id =object_id
 and not exists (select 1
 from bim_i_budgets_denorm b
  where a.object_id = b.parent_object_id
  and a.object_type=b.object_type
  ));
      COMMIT;
     bis_collection_utilities.log('Budget Denorm Concurrent Program Completed Succesfully ');
     bis_collection_utilities.wrapup(p_status => TRUE
			,p_count => sql%rowcount
			,p_period_from => l_temp_start_date
			,p_period_to  => sysdate
			);
EXCEPTION
WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO LOAD_ADMIN_RECORDS;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );
     WHEN FND_API.g_exc_error THEN
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );
END POPULATE_DENORM;
END BIM_BUDGETS_DENORM_PKG;

/
