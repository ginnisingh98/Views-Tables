--------------------------------------------------------
--  DDL for Package Body BIM_PROGRAMS_DENORM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIM_PROGRAMS_DENORM_PKG" AS
/*$Header: bimprgdb.pls 120.7 2005/12/21 02:37:42 sbassi ship $*/

g_pkg_name  CONSTANT  VARCHAR2(20) := 'BIM_PROGRAMS_DENORM';
g_file_name CONSTANT  VARCHAR2(20) := 'bimprgdb2.pls';


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
		IF NOT bis_collection_utilities.setup('BIM_SOURCE_DENORM')  THEN
			bis_collection_utilities.log('Object Not Setup Properly ');
		END IF;

	bis_collection_utilities.get_last_refresh_dates('BIM_SOURCE_DENORM'
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
l_init_msg_list           VARCHAR2(10);
l_date                 DATE;
l_start_date		DATE;
l_end_date		DATE;
l_period_from		DATE;
l_period_to		DATE;
l_temp_start_date       DATE;

BEGIN

l_date:= bis_common_parameters.get_global_start_date;
   -- Standard call to check for call compatibility.
     IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                          p_api_version_number,
                                          l_api_name,
                                          g_pkg_name)
     THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    POPULATE_SOURCE_DENORM
    (p_api_version_number => 1.0
    ,p_init_msg_list      => FND_API.G_FALSE
    ,p_validation_level   => FND_API.G_VALID_LEVEL_FULL
    ,p_commit             => FND_API.G_FALSE
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

    LOAD_ADMIN_RECORDS
    (p_api_version_number => 1.0
    ,p_init_msg_list      => FND_API.G_FALSE
    ,p_validation_level   => FND_API.G_VALID_LEVEL_FULL
    ,p_commit             => FND_API.G_FALSE
    ,x_msg_Count          => x_msg_count
    ,x_msg_Data           => x_msg_data
    ,x_return_status      => x_return_status
    );

   IF    x_return_status = FND_API.g_ret_sts_error
   THEN
          RAISE FND_API.g_exc_error;
   ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
          RAISE FND_API.g_exc_unexpected_error;
   END IF;

    LOAD_TOP_LEVEL_OBJECTS
    (p_api_version_number => 1.0
    ,p_init_msg_list      => FND_API.G_FALSE
    ,p_validation_level   => FND_API.G_VALID_LEVEL_FULL
    ,p_commit             => FND_API.G_FALSE
    ,x_msg_Count          => x_msg_count
    ,x_msg_Data           => x_msg_data
    ,x_return_status      => x_return_status
    );

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


PROCEDURE POPULATE_SOURCE_DENORM
    (p_api_version_number    IN  NUMBER
    ,p_init_msg_list         IN  VARCHAR2
    ,p_validation_level      IN  NUMBER
    ,p_commit                IN  VARCHAR2
    ,x_msg_Count             OUT NOCOPY NUMBER
    ,x_msg_Data              OUT NOCOPY VARCHAR2
    ,x_return_status         OUT NOCOPY VARCHAR2
    ,p_proc_num              IN  NUMBER
    ,p_load_type	     IN  VARCHAR2
     ) IS

 --l_date               DATE  :=  bis_common_parameters.get_global_start_date;
 l_date                 DATE;
 l_temp_start_date      DATE;
 l_temp_end_date        DATE;
 l_api_version_number   CONSTANT NUMBER       := 1.0;
 l_api_name             CONSTANT VARCHAR2(30) := 'POPULATE_DENORM';
 l_init_msg_list        VARCHAR2(10);
 l_start_date		DATE;
 l_end_date		DATE;
 l_period_from		DATE;
 l_period_to		DATE;

    l_status       VARCHAR2(5);
    l_industry     VARCHAR2(5);
    l_schema       VARCHAR2(30);
    l_return       BOOLEAN;


 BEGIN

	l_init_msg_list:= FND_API.G_FALSE;

	IF p_load_type = 'F' THEN

		--it is a call for First/Inital load, then truncate the denorm table first
		bis_collection_utilities.log('Truncating the Source Denorm Table ');

		l_return  := fnd_installation.get_app_info('BIM', l_status, l_industry, l_schema);

		Execute Immediate 'Truncate Table '||l_schema||'.bim_i_source_denorm';

		BIS_COLLECTION_UTILITIES.deleteLogForObject('BIM_SOURCE_DENORM');

	ELSE
		/* This piece of code is for the objects that had an update somewhere in their hierarachy chain. */

		DELETE  bim_i_source_denorm
		WHERE   source_code_id IN
					(SELECT  source_code_id
					FROM     bim_i_source_codes a
					WHERE    obj_last_update_date > l_temp_start_date
					);

		/* This piece of code is for the campaigns that have changed from one program to another. */
		/*DELETE  bim_i_source_denorm
		WHERE   source_code_id IN
		(
				SELECT source_code_id
				FROM bim_i_source_denorm
				WHERE parent_source_code_id IN
				(
						SELECT  b.source_code_id
						FROM    ams_campaigns_all_b a,
                                bim_i_source_codes b
						WHERE    a.rollup_type in ('RCAM')
						and      b.source_code_id = (-1)*b.object_id
						AND         obj_last_update_date > l_temp_start_date
				)

		);*/
		--Modified the query as per performance bug 4901135
		DELETE  bim_i_source_denorm
		WHERE   source_code_id IN
		(
				SELECT source_code_id
				FROM bim_i_source_denorm
				WHERE parent_source_code_id IN
				(
						SELECT  b.source_code_id
						FROM    bim_i_source_codes b
						WHERE   b.source_code_id = (-1)*b.object_id
						AND     obj_last_update_date > l_temp_start_date
				)

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

 IF l_period_to IS NOT NULL THEN

      BIS_COLLECTION_UTILITIES.log('Updating leaf node flags for incremental load ');
      --add update logic here
      UPDATE bim_i_source_denorm SET leaf_node_flag = 'N'
      WHERE source_code_id
      IN
            (
		SELECT parent_source_code_id
		FROM bim_i_source_codes a
		WHERE rollup_type in ('CSCH', 'EVE0')
			AND NOT EXISTS (
					      SELECT 1
					      FROM bim_i_source_denorm b
				              WHERE b.source_code_id = a.source_code_id
					)
					AND object_level = 1
            );


     /*************FOR CAMPAIGNS AND EVENTS OBJECTS ******************************/

INSERT INTO  bim_i_source_denorm
      (source_code_id
      ,parent_source_code_id
      ,immediate_parent_flag
      ,immediate_parent_id
      ,prior_id
      ,object_level
      ,rollup_type
      ,parent_source_code_type
      ,top_node_flag
      ,leaf_node_flag
      ,creation_date
      ,last_update_date
      ,created_by
      ,last_updated_by
      ,last_update_login
      )

       SELECT
       x.source_code_id
      ,x.parent_source_code_id
      ,x.immediate_parent_flag
      ,x.immediate_parent_id
      ,s.parent_source_code_id
      ,x.object_level
      ,x.object_type
      ,x.parent_source_code_type
      ,decode(s.parent_source_code_id, NULL, 'Y', 'N')
      ,(CASE
        WHEN (x.leaf_node_flag = 'Y' AND x.object_level = 1)
	THEN 'Y'
	ELSE 'N'
	END)
      --,decode(x.object_level,1,'Y','N')
      ,sysdate
      ,sysdate
      ,-1
      ,-1
      ,-1
      FROM
      (
       SELECT
       source_code_id source_code_id
       ,TO_NUMBER(NVL(SUBSTR(SYS_CONNECT_BY_PATH(source_code_id,'/'),2,
                INSTR(SYS_CONNECT_BY_PATH(source_code_id,'/'),'/',2) -2),source_code_id)) AS parent_source_code_id
      ,decode(parent_source_code_id,NULL,'Y',decode(level,2,'Y','N')) immediate_parent_flag
      ,parent_source_code_id immediate_parent_id
      ,LEVEL object_level
      ,rollup_type object_type
      ,NVL(PRIOR(object_type),object_type) parent_source_code_type
      ,decode(parent_source_code_id, NULL, 'Y', 'N') top_node_flag
      ,(CASE
        WHEN rollup_type in ('CSCH','EVEO','EONE') THEN 'Y'
        WHEN source_code_id < 0 THEN 'N'
        WHEN (select 'Y' from bim_i_source_codes b
            where a.object_id = b.object_id
            and a.object_type = b.object_type
	    and b.object_type in ('CAMP','EVEH')
            and b.child_object_id > 0
            and rownum = 1) is NULL THEN 'Y'
        ELSE 'N'
        END
       )                               leaf_node_flag

       FROM   bim_i_source_codes a
      WHERE
       NOT EXISTS
              (SELECT 1
                 FROM BIM_I_SOURCE_DENORM b
                WHERE b.source_code_id = a.source_code_id
                 -- AND nvl(b.parent_object_id,1) = nvl(a.parent_campaign_id,1)
              )
      CONNECT BY PRIOR source_code_id = parent_source_code_id  ) x,
      BIM_I_SOURCE_CODES s
      WHERE s.source_code_id = x.parent_source_code_id;

      null;

ELSE
-- for initial load
-- No not exist condition for the for intial load
--additional union all for unassigned values
bis_collection_utilities.log('Initial Load of Source Denorm Concurrent Program');

  /*************FOR CAMPAIGNS AND EVENTS OBJECTS ******************************/

INSERT INTO  bim_i_source_denorm
      (source_code_id
      ,parent_source_code_id
      ,immediate_parent_flag
      ,immediate_parent_id
      ,prior_id
      ,object_level
      ,rollup_type
      ,parent_source_code_type
      ,top_node_flag
      ,leaf_node_flag
      ,creation_date
      ,last_update_date
      ,created_by
      ,last_updated_by
      ,last_update_login
      )

      SELECT
       x.source_code_id source_code_id
      ,x.parent_source_code_id parent_source_code_id
      ,x.immediate_parent_flag immediate_parent_flag
      ,x.immediate_parent_id immediate_parent_id
      ,s.parent_source_code_id prior_id
      ,x.object_level object_level
      ,x.object_type object_type
      ,x.parent_source_code_type
      ,decode(s.parent_source_code_id, NULL, 'Y', 'N') top_node_flag
       ,(CASE
        WHEN (x.leaf_node_flag = 'Y' AND x.object_level = 1)
	THEN 'Y'
	ELSE 'N'
	END) leaf_node_flag
      --,decode(x.object_level,1,'Y','N') leaf_node_flag
      ,sysdate
      ,sysdate
      ,-1
      ,-1
      ,-1
      FROM
      (
       SELECT
       source_code_id source_code_id
       ,TO_NUMBER(NVL(SUBSTR(SYS_CONNECT_BY_PATH(source_code_id,'/'),2,
                INSTR(SYS_CONNECT_BY_PATH(source_code_id,'/'),'/',2) -2),source_code_id)) AS parent_source_code_id
      ,decode(parent_source_code_id,NULL,'Y',decode(level,2,'Y','N')) immediate_parent_flag
      ,parent_source_code_id immediate_parent_id
      ,LEVEL object_level
      ,rollup_type object_type
      ,NVL(PRIOR(object_type),object_type) parent_source_code_type
      ,decode(parent_source_code_id, NULL, 'Y', 'N') top_node_flag
       ,(CASE
        WHEN rollup_type in ('CSCH','EVEO','EONE') THEN 'Y'
        WHEN source_code_id < 0 THEN 'N'
        WHEN (select 'Y' from bim_i_source_codes b
            where a.object_id = b.object_id
            and a.object_type = b.object_type
	    and b.object_type in ('CAMP','EVEH')
            and b.child_object_id > 0
            and rownum = 1) is NULL THEN 'Y'
        ELSE 'N'
        END
       )                               leaf_node_flag

       FROM   bim_i_source_codes a
       CONNECT BY PRIOR source_code_id = parent_source_code_id ) x,
       BIM_I_SOURCE_CODES s
      WHERE s.source_code_id = x.parent_source_code_id
UNION ALL
 SELECT
       -1 source_code_id
      ,-1 parent_source_code_id
      ,'Y' immediate_parent_flag
      ,null immediate_parent_id
      ,null prior_id
      ,1 object_level
      ,null object_type
      ,null parent_source_code_type
      ,'Y' top_node_flag
      ,'Y' leaf_node_flag
      ,sysdate
      ,sysdate
      ,-1
      ,-1
      ,-1
      FROM dual ;

END IF;

commit;
bis_collection_utilities.log('Source Denorm Concurrent Program Completed Succesfully ');

/********* commented becuase same package is being use to load  programs denorm table also so only one wrapup is required*/
	bis_collection_utilities.wrapup(p_status => TRUE
			,p_count => sql%rowcount
			,p_period_from => l_temp_start_date
			,p_period_to  => sysdate
			);

EXCEPTION
WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
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

END POPULATE_SOURCE_DENORM;

PROCEDURE LOAD_ADMIN_RECORDS(
    p_api_version_number                 IN    NUMBER       := 1.0,
    p_init_msg_list                      IN    VARCHAR2,
    p_commit                             IN    VARCHAR2,
    p_validation_level                   IN    NUMBER,
    x_return_status                      OUT   NOCOPY VARCHAR2,
    x_msg_count                          OUT   NOCOPY NUMBER,
    x_msg_data                           OUT   NOCOPY VARCHAR2
    )
  IS

    l_api_version CONSTANT NUMBER       := 1.0;
    l_api_name    CONSTANT VARCHAR2(30) := 'LOAD_ADMIN_RECORDS';
    l_admin_id                     Number := null;
    l_resource_id                  Number := null;
    l_response_country             Varchar2(30);

    l_status       VARCHAR2(5);
    l_industry     VARCHAR2(5);
    l_schema       VARCHAR2(30);
    l_return       BOOLEAN;

  BEGIN

        l_return  := fnd_installation.get_app_info('BIM', l_status, l_industry, l_schema);
        EXECUTE IMMEDIATE 'TRUNCATE TABLE '||l_schema||'.bim_i_admin_group';


        INSERT INTO bim_i_admin_group
	(
	Resource_Id
	)
        SELECT resource_id
        FROM   jtf_rs_group_members
        WHERE  group_id = fnd_profile.value('AMS_ADMIN_GROUP')
	AND    delete_flag ='N';

       COMMIT;

EXCEPTION
WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
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

END LOAD_ADMIN_RECORDS;


PROCEDURE LOAD_TOP_LEVEL_OBJECTS(
    p_api_version_number                 IN    NUMBER       := 1.0,
    p_init_msg_list                      IN    VARCHAR2,
    p_commit                             IN    VARCHAR2,
    p_validation_level                   IN    NUMBER,
    x_return_status                      OUT   NOCOPY VARCHAR2,
    x_msg_count                          OUT   NOCOPY NUMBER,
    x_msg_data                           OUT   NOCOPY VARCHAR2
    )
  IS

    l_api_version CONSTANT NUMBER       := 1.0;
    l_api_name    CONSTANT VARCHAR2(30) := 'LOAD_TOP_LEVEL_OBJECTS';
    l_admin_id                     Number := null;
    l_resource_id                  Number := null;
    l_response_country             Varchar2(30);

    l_status       VARCHAR2(5);
    l_industry     VARCHAR2(5);
    l_schema       VARCHAR2(30);
    l_return       BOOLEAN;


  BEGIN

        l_return  := fnd_installation.get_app_info('BIM', l_status, l_industry, l_schema);
        EXECUTE IMMEDIATE 'TRUNCATE TABLE '||l_schema||'.bim_i_top_objects';

INSERT INTO bim_i_top_objects
	(
	resource_id,
	source_code_id ,
        object_id,
        object_type,
        creation_date,
	last_update_date,
	created_by,
	last_updated_by,
	last_update_login)
SELECT      c.resource_id,
            b.parent_source_code_id,
	    null,
	    null,
	    sysdate,
	    sysdate,
	    -1,
	    -1,
	    -1
        FROM bim_i_source_denorm b,
        (
           SELECT
                 a.resource_id,code1.source_code_id,
		         max(b.object_level) object_level ,
				 a.object_type object_type
              FROM ams_act_access_denorm a,
                   bim_i_source_denorm b,
		           bim_i_source_codes code1,
                   ams_act_access_denorm c,
		           bim_i_source_codes code2
              WHERE a.object_id = code1.object_id
              AND a.object_type = code1.object_type
	      AND b.source_code_id=code1.source_code_id
              AND code1.object_type in ('RCAM', 'CAMP', 'EVEH', 'EONE')
              AND code1.child_object_id=0
	      AND a.edit_metrics_yn = 'Y'
              AND NOT EXISTS
                  (SELECT resource_id FROM bim_i_admin_group WHERE resource_id = a.resource_id)
              AND c.resource_id = a.resource_id
              AND c.object_id =   code2.object_id
              AND c.object_type = code2.object_type
     	      AND code2.source_code_id=b.parent_source_code_id
	      AND c.edit_metrics_yn = 'Y'
              GROUP BY a.resource_id, code1.source_code_id, a.object_type) c
           WHERE   c.object_level = b.object_level
        AND b.source_code_id = c.source_code_id
        GROUP BY c.resource_id,b.parent_source_code_id;
COMMIT;

EXCEPTION
WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
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

END LOAD_TOP_LEVEL_OBJECTS;

END bim_programs_denorm_pkg;

/
