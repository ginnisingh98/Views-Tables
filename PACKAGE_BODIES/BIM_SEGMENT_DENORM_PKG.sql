--------------------------------------------------------
--  DDL for Package Body BIM_SEGMENT_DENORM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIM_SEGMENT_DENORM_PKG" AS
/* $Header: bimisgdb.pls 120.16.12010000.1 2008/07/29 21:04:45 appldev ship $ */

g_pkg_name  CONSTANT  VARCHAR2(22) := 'BIM_SEGMENT_DENORM_PKG';
g_file_name CONSTANT  VARCHAR2(20) := 'bimisgdb.pls';

PROCEDURE COMMON_UTILITIES
   ( l_global_start_date OUT NOCOPY DATE
    ,l_period_from	 OUT NOCOPY DATE
    ,l_period_to	 OUT NOCOPY DATE
    ,l_temp_start_date   OUT NOCOPY DATE
    ,l_start_date	 OUT NOCOPY DATE
    ,l_end_date		 OUT NOCOPY DATE
    ) IS
    l_global_date CONSTANT DATE := bis_common_parameters.get_global_start_date;

 BEGIN
 l_global_start_date := l_global_date;

 BEGIN
	/* Set up the Object */
	IF NOT bis_collection_utilities.setup('BIM_SEGMENT_DENORM_PKG')  THEN
			bis_collection_utilities.log('Object Not Setup Properly ');
	END IF;

	bis_collection_utilities.get_last_refresh_dates('BIM_SEGMENT_DENORM_PKG'
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
   ( ERRBUF                 OUT NOCOPY VARCHAR2
    ,RETCODE                OUT NOCOPY NUMBER
    ,p_api_version_number   IN  NUMBER
    ,p_proc_num             IN  NUMBER
	,p_load_type			IN	VARCHAR2
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

    POPULATE_SEGMENT_DENORM
    (p_api_version_number => 1.0
    ,p_init_msg_list      => FND_API.G_FALSE
    ,p_validation_level   => FND_API.G_VALID_LEVEL_FULL
    ,p_commit             => FND_API.G_FALSE
    ,x_msg_Count          => x_msg_count
    ,x_msg_Data           => x_msg_data
    ,x_return_status      => x_return_status
    ,p_proc_num           => p_proc_num
	,p_load_type		  => p_load_type
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


PROCEDURE POPULATE_SEGMENT_DENORM
    (p_api_version_number    IN  NUMBER
    ,p_init_msg_list         IN  VARCHAR2
    ,p_validation_level      IN  NUMBER
    ,p_commit                IN  VARCHAR2
    ,x_msg_Count             OUT NOCOPY NUMBER
    ,x_msg_Data              OUT NOCOPY VARCHAR2
    ,x_return_status         OUT NOCOPY VARCHAR2
    ,p_proc_num              IN  NUMBER
	,p_load_type			 IN	 VARCHAR2
     ) IS

    l_date                 DATE;
    l_temp_start_date      DATE /*:= TO_DATE('01-MAY-2005')*/;
    l_temp_end_date        DATE;
    l_api_version_number   CONSTANT NUMBER       := 1.0;
    l_api_name             CONSTANT VARCHAR2(30) := 'POPULATE_DENORM';
    l_init_msg_list        VARCHAR2(10);
    l_start_date	   DATE;
    l_end_date		   DATE;
    l_period_from	   DATE;
    l_period_to		   DATE;
	l_return				BOOLEAN;

	l_status				VARCHAR2(5);
	l_industry				VARCHAR2(5);
	l_schema				VARCHAR2(30);

	l_source VARCHAR2(80);
	l_sql_id NUMBER(32);
	l_query_string VARCHAR2(32767);

	cursor c_query_source is
	select list_query_id, query
	from ams_list_queries_all ;

	l_found VARCHAR2(1) := 'N';
	l_master_type               VARCHAR2(80);
	l_master_type_id            NUMBER;
	l_source_object_name        VARCHAR2(80);
	l_source_object_pk_field    VARCHAR2(80);
	l_sql_string_tbl            AMS_ListGeneration_PKG.sql_string;
	l_from_position             NUMBER;
	l_from_counter              NUMBER;
	l_end_position              NUMBER;
	l_end_counter               NUMBER;
	l_count                     NUMBER;
	l_string_copy               VARCHAR2(32767);
	l_length                    NUMBER;

BEGIN

	Execute Immediate 'CREATE TABLE ' || ' source_query_sgdb ' || '( sql_id NUMBER(32), source_name VARCHAR2(80) )';

	Execute Immediate 'TRUNCATE TABLE source_query_sgdb';

	OPEN c_query_source;
	LOOP
		FETCH c_query_source INTO l_sql_id, l_query_string;
		EXIT WHEN c_query_source%notfound;

			if ( l_query_string is NULL ) then
				l_source := 'NO_MASTER_TYPE';
			else
				l_count := 0;
				l_string_copy := l_query_string;

				l_length := length(l_string_copy);

				LOOP
					l_count := l_count + 1;
					IF l_length < 1999 THEN
						l_sql_string_tbl(l_count) := l_string_copy;
					EXIT;
					ELSE
						l_sql_string_tbl(l_count) := substr(l_string_copy, 1, 2000);
						l_string_copy := substr(l_string_copy, 2000);
					END IF;
					l_length := length(l_string_copy);
				END LOOP;

				l_found := 'N';
				AMS_ListGeneration_PKG.validate_sql_string(
					p_sql_string    => l_sql_string_tbl ,
					p_search_string => 'FROM',
					p_comma_valid   => 'N',
					x_found         => l_found,
					x_position      => l_from_position,
					x_counter       => l_from_counter) ;


				l_found := 'N';

				AMS_ListGeneration_PKG.get_master_types (
					p_sql_string => l_sql_string_tbl,
					p_start_length => 1,
					p_start_counter => 1,
					p_end_length => l_from_position,
					p_end_counter => l_from_counter,
					x_master_type_id=> l_master_type_id,
					x_master_type=> l_master_type,
					x_found=> l_found,
					x_source_object_name => l_source_object_name,
					x_source_object_pk_field  => l_source_object_pk_field);

				IF nvl(l_found,'N') = 'N' THEN
					--No master type.
					l_source_object_name := 'NO_MASTER_TYPE';
				END IF;


				l_source := l_master_type;
			END IF;
			-- bis_collection_utilities.log('running the function ---  '||l_source||l_master_type_id||l_master_type);
			Execute Immediate 'INSERT INTO source_query_sgdb(sql_id, source_name) VALUES('||l_sql_id||', '''||l_source||''')';
			l_source := NULL;
			l_query_string := NULL;
			l_sql_id := NULL;
	END LOOP;
	CLOSE c_query_source;

	l_init_msg_list:= FND_API.G_FALSE;

	/* This Delete Statement is for the records changed after last run. */


	IF p_load_type = 'F' THEN

		--it is a call for First/Inital load, then truncate the denorm table first
		bis_collection_utilities.log('Truncating the Denorm Table ');

		l_return  := fnd_installation.get_app_info('BIM', l_status, l_industry, l_schema);

		Execute Immediate 'Truncate Table '||l_schema||'.bim_i_sgmt_denorm';

		BIS_COLLECTION_UTILITIES.deleteLogForObject('BIM_SEGMENT_DENORM_PKG');

		COMMON_UTILITIES(l_date,l_period_from,l_period_to,l_temp_start_date,l_start_date,l_end_date);

	ELSE

		COMMON_UTILITIES(l_date,l_period_from,l_period_to,l_temp_start_date,l_start_date,l_end_date);

        DELETE  bim_i_sgmt_denorm
        WHERE   segment_id IN
                      (SELECT cell_id
                       FROM ams_cells_all_b a
                       WHERE last_update_date > l_temp_start_date
                       );

	/* This Delete Statement for the objects that had an update somewhere in their hierarachy chain.*/

        DELETE  bim_i_sgmt_denorm
        WHERE   segment_id IN (SELECT segment_id
                              FROM bim_i_sgmt_denorm
                              WHERE parent_segment_id in (SELECT b.segment_id
                                                          FROM ams_cells_all_b a
															   ,bim_i_sgmt_denorm b
														  WHERE b.segment_id = a.cell_id
                                                          AND a.last_update_date > l_temp_start_date
                                                          )
							);

	END IF;



	IF l_period_to IS NOT NULL THEN

		bis_collection_utilities.log('Updating leaf node flags for incremental load ');


		UPDATE bim_i_sgmt_denorm
		SET leaf_node_flag = 'N'
		WHERE segment_id  IN (SELECT parent_cell_id
							  FROM ams_cells_all_b a
							  WHERE NOT EXISTS (SELECT 1 FROM bim_i_sgmt_denorm b WHERE b.segment_id = a.cell_id)
							  AND object_level = 1
							  AND a.last_update_date > l_temp_start_date
							  );


	  /**********************FOR INCREMENT LOAD**********************/
          /**************************************************************/
          Execute Immediate ' INSERT INTO bim_i_sgmt_denorm ' ||
'          (    segment_id ' ||
 '            ,parent_segment_id ' ||
  '          ,immediate_parent_flag ' ||
   '           ,immediate_parent_id ' ||
       '       ,object_level ' ||
    '          ,top_node_flag ' ||
     '         ,leaf_node_flag ' ||
      '        ,prior_id ' ||
        '      ,creation_date ' ||
         '     ,last_update_date ' ||
          '    ,created_by ' ||
           '   ,last_updated_by ' ||
            '  ,last_update_login ' ||
'          ) ' ||
 '         SELECT ' ||
  '             x.segment_id ' ||
   '           ,x.parent_segment_id ' ||
    '          ,x.immediate_parent_flag ' ||
     '         ,x.immediate_parent_id ' ||
      '        ,x.object_level ' ||
       '       ,decode(s.parent_cell_id, NULL, ''Y'', ''N'') top_node_flag ' ||
        '      ,x.leaf_node_flag ' ||
         '     ,s.parent_cell_id prior_id ' ||
          '    ,sysdate ' ||
           '   ,sysdate ' ||
            '  ,-1 ' ||
             ' ,-1 ' ||
'              ,-1 ' ||
 '         FROM ' ||
  '            (	SELECT ' ||
'					cell_id segment_id ' ||
'					,TO_NUMBER(NVL(SUBSTR(SYS_CONNECT_BY_PATH(cell_id,''/''),2, INSTR(SYS_CONNECT_BY_PATH(cell_id,''/''),''/'',2) -2),cell_id)) AS parent_segment_id ' ||
'					,decode(parent_cell_id,NULL,''Y'',decode(level,2,''Y'',''N'')) immediate_parent_flag ' ||
'					,parent_cell_id immediate_parent_id ' ||
'					,LEVEL object_level ' ||
'					,decode(parent_cell_id, NULL,''Y'',''N'') top_node_flag ' ||
'					,DECODE((SELECT COUNT(1) FROM ams_cells_all_b c WHERE parent_cell_id = a.cell_id),0,''Y'',''N'') leaf_node_flag ' ||
'				FROM (SELECT a.cell_id , a.parent_cell_id ' ||
'					 FROM ams_cells_all_b a, ams_list_queries_all b, ams_list_src_types c, source_query_sgdb d ' ||
'					 WHERE b.act_list_query_used_by_id = a.cell_id ' ||
'					 AND b.arc_act_list_query_used_by =''CELL'' ' ||
'					 AND b.list_query_id = d.sql_id ' ||
'					 AND d.source_name = c.source_type_code ' ||
'					 AND c.based_on_tca_flag = ''Y''  ' ||
'					 AND a.sel_type =''SQL''		 ' ||
'					 AND a.status_code IN (''AVAILABLE'',''CANCELLED'') ' ||
'					 UNION ALL         ' ||
'					 SELECT a.cell_id , a.parent_cell_id ' ||
'					 FROM ams_cells_all_b a,ams_list_src_types b,ams_act_discoverer_all c,ams_discoverer_sql d ' ||
'					 WHERE c.act_discoverer_used_by_id = a.cell_id ' ||
'					 AND c.arc_act_discoverer_used_by =''CELL'' ' ||
'					 AND c.discoverer_sql_id = d.discoverer_sql_id ' ||
'					 AND d.source_type_code = b.source_object_name ' ||
'					 AND b.based_on_tca_flag = ''Y''  ' ||
'					 AND a.sel_type=''DIWB''		 ' ||
'					 AND a.status_code IN (''AVAILABLE'',''CANCELLED'') ' ||
'				    ) a                ' ||
'				WHERE NOT EXISTS ( SELECT 1 FROM bim_i_sgmt_denorm b ' ||
'									WHERE b.segment_id = a.cell_id ) ' ||
 '              CONNECT BY PRIOR cell_id = parent_cell_id ' ||
  '            )x, ams_cells_all_b s ' ||
   '       WHERE s.cell_id = x.parent_segment_id' ;

   Execute Immediate ' DROP TABLE source_query_sgdb ';

	bis_collection_utilities.log('Records Inserted for Incremental load ');

ELSE

	  /**********************FOR INITITAL LOAD**********************/
          bis_collection_utilities.log('Initial Load of Segment Denorm Program');

         Execute Immediate ' INSERT INTO bim_i_sgmt_denorm ' ||
'          (    segment_id ' ||
 '             ,parent_segment_id ' ||
  '            ,immediate_parent_flag ' ||
   '           ,immediate_parent_id ' ||
    '          ,object_level ' ||
     '         ,top_node_flag ' ||
      '        ,leaf_node_flag ' ||
       '       ,prior_id ' ||
        '      ,creation_date ' ||
         '     ,last_update_date ' ||
          '    ,created_by ' ||
           '   ,last_updated_by ' ||
            '  ,last_update_login ' ||
'          ) ' ||
 '         SELECT ' ||
  '             x.segment_id ' ||
   '           ,x.parent_segment_id ' ||
    '          ,x.immediate_parent_flag ' ||
     '         ,x.immediate_parent_id ' ||
      '        ,x.object_level ' ||
       '       ,decode(s.parent_cell_id, NULL, ''Y'', ''N'') top_node_flag ' ||
        '      ,x.leaf_node_flag ' ||
         '     ,s.parent_cell_id prior_id ' ||
          '    ,sysdate ' ||
           '   ,sysdate ' ||
            '  ,-1 ' ||
             ' ,-1 ' ||
              ',-1 ' ||
'          FROM ' ||
 '             (SELECT ' ||
  '                 cell_id segment_id ' ||
   '               ,TO_NUMBER(NVL(SUBSTR(SYS_CONNECT_BY_PATH(cell_id,''/''),2, INSTR(SYS_CONNECT_BY_PATH(cell_id,''/''),''/'',2) -2),cell_id)) AS parent_segment_id ' ||
    '              ,decode(parent_cell_id,NULL,''Y'',decode(level,2,''Y'',''N'')) immediate_parent_flag ' ||
     '             ,parent_cell_id immediate_parent_id ' ||
      '            ,LEVEL object_level ' ||
       '           ,decode(parent_cell_id, NULL,''Y'',''N'') top_node_flag ' ||
        '  	,DECODE((SELECT COUNT(1) FROM ams_cells_all_b c WHERE parent_cell_id = a.cell_id),0,''Y'',''N'') leaf_node_flag ' ||
         '      FROM (SELECT a.cell_id , a.parent_cell_id ' ||
	'				 FROM ams_cells_all_b a, ams_list_queries_all b, ams_list_src_types c, source_query_sgdb d ' ||
	'				 WHERE b.act_list_query_used_by_id = a.cell_id ' ||
	'				 AND b.arc_act_list_query_used_by =''CELL'' ' ||
	'				 AND b.list_query_id = d.sql_id ' ||
	'				 AND d.source_name = c.source_type_code ' ||
	'				 AND c.based_on_tca_flag = ''Y''  ' ||
	'				 AND a.sel_type =''SQL''		 ' ||
	'				 AND a.status_code IN (''AVAILABLE'',''CANCELLED'') ' ||
	'				 UNION ALL         ' ||
	'				 SELECT a.cell_id , a.parent_cell_id ' ||
	'				 FROM ams_cells_all_b a,ams_list_src_types b,ams_act_discoverer_all c,ams_discoverer_sql d ' ||
	'				 WHERE c.act_discoverer_used_by_id = a.cell_id ' ||
	'				 AND c.arc_act_discoverer_used_by =''CELL'' ' ||
	'				 AND c.discoverer_sql_id = d.discoverer_sql_id ' ||
	'				 AND d.source_type_code = b.source_object_name ' ||
	'				 AND b.based_on_tca_flag = ''Y''  ' ||
	'				 AND a.sel_type=''DIWB'' ' ||
	'				 AND a.status_code IN (''AVAILABLE'',''CANCELLED'') ' ||
	'			    ) a                ' ||
         '      CONNECT BY PRIOR a.cell_id = a.parent_cell_id ' ||
          '    )x, ams_cells_all_b s ' ||
'          WHERE s.cell_id = x.parent_segment_id' ;
	   /* UNION ALL
	    NOTE:-additional UNION ALL for unassigned values
	  SELECT
               -1 segment_id
              ,-1 parent_segment_id
              ,'Y' immediate_parent_flag
              ,null immediate_parent_id
              ,1 object_level
              ,'Y' top_node_flag
              ,'Y' leaf_node_flag
              ,null prior_id
              ,sysdate creation_date
              ,sysdate last_update_date
              ,-1 created_by
              ,-1 last_updated_by
              ,-1 last_update_login
          FROM dual ;*/

	  Execute Immediate ' DROP TABLE source_query_sgdb ';

	  bis_collection_utilities.log('Records Inserted for Initial load ');
END IF;

commit;

	bis_collection_utilities.log('Segment Denorm Concurrent Program Completed Succesfully ');

	bis_collection_utilities.wrapup(p_status => TRUE
									,p_count => sql%rowcount
									,p_period_from => l_temp_start_date
									,p_period_to  => sysdate
									);

EXCEPTION
     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
Execute Immediate 'DROP TABLE source_query_sgdb';
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

     WHEN FND_API.g_exc_error THEN
      x_return_status := FND_API.g_ret_sts_error;
Execute immediate 'DROP TABLE source_query_sgdb';
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
Execute Immediate 'DROP TABLE source_query_sgdb';
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

END POPULATE_SEGMENT_DENORM;

END BIM_SEGMENT_DENORM_PKG;

/
