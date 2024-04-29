--------------------------------------------------------
--  DDL for Package Body BIM_I_SGMT_CUST_FACTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIM_I_SGMT_CUST_FACTS_PKG" AS
/*$Header: bimiscfb.pls 120.16.12010000.1 2008/07/29 21:04:43 appldev ship $*/

g_pkg_name  CONSTANT  VARCHAR2(30) := 'BIM_I_SGMT_CUST_FACTS_PKG';
g_file_name CONSTANT  VARCHAR2(20) := 'bimispfb.pls';
g_initial_start_date	DATE ;


------------------------------------------------------------------------------------------------
----
----This procedure finds out if the user is trying to run first_load or subsequent load
----and calls the Inital Load or Incremental Load accordingly
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
	,p_truncate_flg			   IN  VARCHAR2
    ) IS

	l_object_name				CONSTANT VARCHAR2(80) := 'BIM_SGMT_CUST';
	l_conc_start_date			DATE;
	l_conc_end_date				DATE;
	l_start_date				DATE;
	l_end_date					DATE;
	l_user_id					NUMBER := FND_GLOBAL.USER_ID();
	l_api_version_number		CONSTANT NUMBER       := 1.0;
	l_api_name					CONSTANT VARCHAR2(30) := 'BIM_I_SGMT_CUST_FACTS_PKG';
	l_mesg_text					VARCHAR2(100);
	l_load_type					VARCHAR2(100);
	l_year_start_date			DATE;
	l_global_date				DATE;
	l_missing_date				BOOLEAN := FALSE;
	l_sysdate					DATE;

	l_attribute_table			DBMS_SQL.VARCHAR2_TABLE;
	l_attribute_count			NUMBER;

BEGIN

	IF NOT bis_collection_utilities.setup(l_object_name)  THEN
		bis_collection_utilities.log('Object BIM_CUST_SGMT Not Setup Properly');
		RAISE FND_API.G_EXC_ERROR;
	END IF;

	bis_collection_utilities.log('Start of the Segment Customer Facts Program');

	-- Standard call to check for call compatibility.
	IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
							 p_api_version_number,
							 l_api_name,
							 g_pkg_name)	THEN

		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

	END IF;

	-- Initialize message list if p_init_msg_list is set to TRUE.

	l_global_date:=  bis_common_parameters.get_global_start_date;

	IF FND_API.to_Boolean( p_init_msg_list )
	THEN
		FND_MSG_PUB.initialize;
	END IF;

    -- Initialize API return status to SUCCESS

	x_return_status := FND_API.G_RET_STS_SUCCESS;

	--Get last Refresh dates of the program

    bis_collection_utilities.get_last_refresh_dates(l_object_name,
													l_conc_start_date,
													l_conc_end_date,
													l_start_date,
													l_end_date);

	bis_collection_utilities.get_last_user_attributes(l_object_name,
													l_attribute_table,
													l_attribute_count);

	IF l_attribute_count > 0 THEN

		IF l_attribute_table(1) = 'INITIAL_LOAD_START_DATE' THEN

			g_initial_start_date := l_attribute_table(2);

		END IF;

	END IF;

	IF (l_end_date IS NULL) THEN
		--i.e the First Time Base Summary is not executed. so execute First_load
		--before executing make sure the user called the correct program i.e inital load

		IF (p_start_date  IS NULL) THEN
			--i.e the user initiated incremental program request. raise exception and exit
			bis_collection_utilities.log('Please run the Update Segment Customer Base Summary - Initial Load Concurrent Program before running this');
			RAISE FND_API.G_EXC_ERROR;
		END IF;

		--- Validate Time Dimension Tables
		fii_time_api.check_missing_date (GREATEST(l_global_date,p_start_date), SYSDATE, l_missing_date);

		IF (l_missing_date) THEN
			bis_collection_utilities.log('Time Dimension has atleast one missing date between ' || greatest(l_global_date,p_start_date) || ' and ' || sysdate);
			RAISE FND_API.G_EXC_ERROR;
		END IF;

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

				--Check it from the year start Date of the Year Passed as used in Active Customer Count
				bis_collection_utilities.log('Time Dimension has atleast one missing date between ' || l_end_date || ' and ' || sysdate);
				RAISE FND_API.G_EXC_ERROR;

			END IF;

			l_load_type  := 'SUBSEQUENT_LOAD';

			l_sysdate := sysdate;


			INCREMENTAL_LOAD(p_start_date => l_end_date +1/86400 -- add one second
							,p_end_date =>  l_sysdate
							,p_api_version_number => l_api_version_number
							,p_init_msg_list => FND_API.G_FALSE
							,x_msg_count => x_msg_count
							,x_msg_data   => x_msg_data
							,x_return_status => x_return_status
						);
		END IF;

	END IF;

	---If Incremental/Inital Load Executes Sucessfully, then call the Load_Schedule_Data Procedure

	IF    x_return_status = FND_API.g_ret_sts_error		THEN

		RAISE FND_API.g_exc_error;

	ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN

		RAISE FND_API.g_exc_unexpected_error;

	END IF;

	--Standard check of commit

	IF FND_API.To_Boolean ( p_commit ) THEN

		COMMIT WORK;

	END IF;

	bis_collection_utilities.log('Successful Completion of Segment Customer Facts Program');

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
		p_count   => x_msg_count,
		p_data    => x_msg_data
		);


	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		-- Standard call to get message count and if count=1, get the message
		FND_msg_PUB.Count_And_Get (
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
			p_count => x_msg_count,
			p_data  => x_msg_data
		);

END populate;


--------------------------------------------------------------------------------------------------
-- This procedure will populates all the data required into Party Segment facts
-- table for the first load.
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

	l_api_version_number	CONSTANT NUMBER       := 1.0;
	l_api_name				CONSTANT VARCHAR2(30) := 'FIRST_LOAD';
	l_table_name			VARCHAR2(100);
	l_check_missing_rate	NUMBER;
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

	Execute Immediate 'CREATE TABLE ' || ' source_query_scfb ' || '( sql_id NUMBER(32), source_name VARCHAR2(80) )';

	Execute Immediate 'TRUNCATE TABLE source_query_scfb';

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
			Execute Immediate 'INSERT INTO source_query_scfb(sql_id, source_name) VALUES('||l_sql_id||', '''||l_source||''')';
			l_source := NULL;
			l_query_string := NULL;
			l_sql_id := NULL;
	END LOOP;
	CLOSE c_query_source;


	-- Standard call to check for call compatibility.
	IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
									   p_api_version_number,
									   l_api_name,
									   g_pkg_name)
	THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	-- Initialize message list if p_init_msg_list is set to TRUE.
	IF fnd_api.to_boolean( p_init_msg_list ) THEN

		FND_msg_PUB.initialize;

	END IF;

	-- Initialize API return status to SUCCESS
	x_return_status := FND_API.G_RET_STS_SUCCESS;

	bis_collection_utilities.log('Running Initial Load of Segment Customer Facts');

	l_return  := fnd_installation.get_app_info('BIM', l_status, l_industry, l_schema);

	bis_collection_utilities.log('Truncating Facts Table');

	EXECUTE IMMEDIATE 'TRUNCATE TABLE '||l_schema||'.bim_i_party_sgmt_facts' ;

	BIS_COLLECTION_UTILITIES.deleteLogForObject('BIM_SGMT_CUST');

	---populating Segment Size
	bis_collection_utilities.log('Inserting Segment Customer Details');

	Execute Immediate 'INSERT/*+ append parallel*/ INTO bim_i_party_sgmt_facts ' ||
'		(segment_id ' ||
'		,party_id ' ||
'		,start_date_active ' ||
'		,end_date_active ' ||
'		,status,account_close_date ' ||
'		,creation_date ' ||
'		,last_update_date ' ||
'		,created_by ' ||
'		,last_updated_by ' ||
'		,last_update_login ' ||
'		) ' ||
'	SELECT segment_id ' ||
'		   ,inner.party_id ' ||
'		   ,TRUNC(start_date_active) ' ||
'		   ,TRUNC(end_date_active) ' ||
'		   ,party.status status ' ||
'		   ,CASE WHEN party.status=''I'' AND party.last_update_date BETWEEN start_date_active and end_date_active THEN  ' ||
'				party.last_update_date  ' ||
'			ELSE  ' ||
'				NULL  ' ||
'			END account_close_date ' ||
'			,sysdate ' ||
'			,sysdate ' ||
'			,-1 ' ||
'			,-1 ' ||
'			,-1 ' ||
'	FROM  ' ||
'	(SELECT market_segment_id segment_id ' ||
'			,nvl(reln.subject_id,a.party_id) party_id ' ||
'			,min(start_date_active) start_date_active ' ||
'			,max(nvl(end_date_active,TO_DATE(''31/12/2199'',''DD/MM/YYYY''))) end_date_active ' ||
'	FROM	ams_party_market_segments a ' ||
'			,(SELECT a.cell_id  cell_id  ' ||
'			 FROM ams_cells_all_b a, ams_list_queries_all b, ams_list_src_types c, source_query_scfb d ' ||
'			 WHERE b.act_list_query_used_by_id = a.cell_id ' ||
'			 AND b.arc_act_list_query_used_by =''CELL'' ' ||
'			 AND b.list_query_id = d.sql_id ' ||
'			 AND d.source_name = c.source_type_code ' ||
'			 AND c.based_on_tca_flag = ''Y''  ' ||
'			 AND a.sel_type =''SQL'' ' ||
'			 AND a.creation_date >= '''||p_start_date||''''||
'			 AND a.status_code IN (''AVAILABLE'',''CANCELLED'') ' ||
'			 UNION ALL         ' ||
'			 SELECT a.cell_id  ' ||
'			 FROM ams_cells_all_b a,ams_list_src_types b,ams_act_discoverer_all c,ams_discoverer_sql d ' ||
'			 WHERE c.act_discoverer_used_by_id = a.cell_id ' ||
'			 AND c.arc_act_discoverer_used_by =''CELL'' ' ||
'			 AND c.discoverer_sql_id = d.discoverer_sql_id ' ||
'			 AND d.source_type_code = b.source_object_name ' ||
'			 AND b.based_on_tca_flag = ''Y''  ' ||
'			 AND a.sel_type=''DIWB'' ' ||
'			 AND a.creation_date >= '''||p_start_date||''''||
'			 AND a.status_code IN (''AVAILABLE'',''CANCELLED'') ' ||
'			 ) b  ' ||
'			 , hz_relationships reln ' ||
'	WHERE a.market_segment_id = b.cell_id ' ||
'	AND	 trunc(a.creation_date) BETWEEN '''||p_start_date||''' AND '''||p_end_date||''''||
'	AND  a.party_id = reln.party_id(+) ' ||
'	AND reln.subject_type(+) =''ORGANIZATION'' ' ||
'	AND object_type(+)=''PERSON'' ' ||
'	GROUP BY nvl(reln.subject_id,a.party_id),a.market_segment_id) inner,hz_parties party ' ||
'	WHERE inner.party_id=party.party_id';

Execute Immediate ' DROP TABLE source_query_scfb ';

	COMMIT;

	UPDATE bim_i_party_sgmt_facts a
	SET account_open_date=(SELECT GREATEST(min(TRUNC(creation_date)),trunc(a.start_date_active))
							   FROM  hz_cust_accounts b
								WHERE a.party_id=b.party_id)
	WHERE EXISTS
	( SELECT 1
	  FROM hz_cust_accounts b
	  WHERE a.party_id=b.party_id);


	commit;
     bis_collection_utilities.wrapup(p_status => TRUE
                        ,p_count => sql%rowcount
                        ,p_period_from => p_start_date
                        ,p_period_to  => p_end_date
						,p_attribute1 => 'INITIAL_LOAD_START_DATE'
						,p_attribute2 => p_start_date
                        );

     /***************************************************************/

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
Execute Immediate 'DROP TABLE source_query_scfb';
     -- Standard call to get message count and if count=1, get the message
     FND_msg_PUB.Count_And_Get (
          --  p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

    bis_collection_utilities.log('BIM_I_SGMT_CUST_FACTS_PKG : FIRST_LOAD:IN EXPECTED EXCEPTION '||sqlerrm(sqlcode));

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
Execute Immediate 'DROP TABLE source_query_scfb';

     -- Standard call to get message count and if count=1, get the message
     FND_msg_PUB.Count_And_Get (
            --p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

    bis_collection_utilities.log('BIM_I_SGMT_CUST_FACTS_PKG : FIRST_LOAD:IN UNEXPECTED EXCEPTION '||sqlerrm(sqlcode));

   WHEN OTHERS THEN

     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
Execute Immediate 'DROP TABLE source_query_scfb';

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

    bis_collection_utilities.log('BIM_I_SGMT_CUST_FACTS_PKG : FIRST_LOAD:IN OTHERS EXCEPTION '||sqlerrm(sqlcode));

END first_load;

--------------------------------------------------------------------------------------------------
-- This procedure will populates all the data required into facts table for incremental load.
--
--                      PROCEDURE  INCREMENTAL_LOAD
--------------------------------------------------------------------------------------------------

PROCEDURE INCREMENTAL_LOAD
( p_start_date            IN  DATE
 ,p_end_date              IN  DATE
 ,p_api_version_number    IN  NUMBER
 ,p_init_msg_list         IN  VARCHAR2
 ,x_msg_count             OUT NOCOPY NUMBER
 ,x_msg_data              OUT NOCOPY VARCHAR2
 ,x_return_status         OUT NOCOPY VARCHAR2
)
IS
	l_user_id					NUMBER := FND_GLOBAL.USER_ID();
	l_api_version_number		CONSTANT NUMBER       := 1.0;
	l_api_name					CONSTANT VARCHAR2(30) := 'INCREMENTAL_LOAD';
	l_table_name				VARCHAR2(100);
	l_conv_opp_status			VARCHAR2(30);
	l_dead_status				VARCHAR2(30);
	l_check_missing_rate		NUMBER;
	l_stmt						VARCHAR2(50);
	l_cert_level				VARCHAR2(3);

	l_return					BOOLEAN;
	l_status					VARCHAR2(5);
	l_industry					VARCHAR2(5);
	l_schema					VARCHAR2(30);

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

	Execute Immediate 'CREATE TABLE ' || ' source_query_scfb ' || '( sql_id NUMBER(32), source_name VARCHAR2(80) )';

	Execute Immediate 'TRUNCATE TABLE source_query_scfb';

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
			Execute Immediate 'INSERT INTO source_query_scfb(sql_id, source_name) VALUES('||l_sql_id||', '''||l_source||''')';
			l_source := NULL;
			l_query_string := NULL;
			l_sql_id := NULL;
	END LOOP;
	CLOSE c_query_source;


   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                        p_api_version_number,
                                        l_api_name,
                                        g_pkg_name)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

	-- Initialize message list if p_init_msg_list is set to TRUE.
	IF FND_API.to_Boolean( p_init_msg_list )	THEN

		FND_msg_PUB.initialize;

	END IF;

	-- Initialize API return status to SUCCESS
	x_return_status := FND_API.G_RET_STS_SUCCESS;


	bis_collection_utilities.log('Running Incremental Load of Segment Customer Facts');

	bis_collection_utilities.log('Inserting Segment Customer Details');

	l_return  := fnd_installation.get_app_info('BIM', l_status, l_industry, l_schema);

	EXECUTE IMMEDIATE 'TRUNCATE TABLE '||l_schema||'.bim_i_party_sgmt_stg';

	--SQL TO COLLECT PARTIES AND SEGMENT COMBINATION WHICH IS PRESENT IN FACT
	--TABLE AND POPULATE THIS DATA IN STAGING TABLE

	Execute Immediate 'INSERT /*+Append parallel*/ INTO bim_i_party_sgmt_stg ' ||
'		( ' ||
'		segment_id  ' ||
'		,party_id 	 ' ||
'		,end_date_active  ' ||
'		,status  ' ||
'		,account_close_date		 ' ||
'		) ' ||
'	SELECT  ' ||
'		stg.segment_id segment_id ' ||
'		,stg.party_id party_id ' ||
'		,TRUNC(max(segs_party.end_date_active)) end_date_active ' ||
'		,parties.status status ' ||
'		,(CASE WHEN parties.status IN (''I'',''A'') THEN TRUNC(parties.last_update_date) ELSE NULL END) account_closure_date ' ||
'	FROM   ams_party_market_segments a ' ||
'			,(SELECT a.cell_id    ' ||
'			 FROM ams_cells_all_b a, ams_list_queries_all b, ams_list_src_types c, source_query_scfb d ' ||
'			 WHERE b.act_list_query_used_by_id = a.cell_id ' ||
'			 AND b.arc_act_list_query_used_by =''CELL''  ' ||
'			 AND b.list_query_id = d.sql_id ' ||
'			 AND d.source_name = c.source_type_code ' ||
'			 AND c.based_on_tca_flag = ''Y''  ' ||
'			 AND a.sel_type =''SQL'' ' ||
'			 AND a.creation_date >= '''||g_initial_start_date||''''||
'			 AND a.status_code IN (''AVAILABLE'',''CANCELLED'') ' ||
'			 UNION ALL         ' ||
'			 SELECT a.cell_id  ' ||
'			 FROM ams_cells_all_b a,ams_list_src_types b,ams_act_discoverer_all c,ams_discoverer_sql d ' ||
'			 WHERE c.act_discoverer_used_by_id = a.cell_id ' ||
'			 AND c.arc_act_discoverer_used_by =''CELL'' ' ||
'			 AND c.discoverer_sql_id = d.discoverer_sql_id ' ||
'			 AND d.source_type_code = b.source_object_name ' ||
'			 AND b.based_on_tca_flag = ''Y''  ' ||
'			 AND a.sel_type=''DIWB'' ' ||
'			 AND a.creation_date >= '''||g_initial_start_date||''''||
'			 AND a.status_code IN (''AVAILABLE'',''CANCELLED'') ' ||
'			 ) b ' ||
'			,hz_relationships reln ' ||
'			,bim_i_party_sgmt_facts stg ' ||
'			,hz_relationships reln2 ' ||
'			,ams_party_market_segments segs_party ' ||
'			,hz_parties parties ' ||
'	WHERE a.market_segment_id=b.cell_id	 ' ||
'	AND  stg.party_id=nvl(reln.subject_id,a.party_id) ' ||
'	AND  stg.segment_id=a.market_segment_id	 ' ||
'	AND  a.party_id=reln.party_id(+) ' ||
'	AND  reln.subject_type(+) =''ORGANIZATION'' ' ||
'	AND  reln.object_type(+)=''PERSON'' ' ||
'	AND  reln.relationship_code(+)=''CONTACT'' ' ||
'	AND  a.party_id=reln.party_id(+) ' ||
'	AND  reln2.subject_type(+) =''PERSON'' ' ||
'	AND  reln2.object_type(+)=''ORGANIZATION'' ' ||
'	AND  reln2.relationship_code(+)=''CONTACT_OF'' ' ||
'	AND  reln2.object_id(+)=stg.party_id ' ||
'	AND ((segs_party.party_id=reln2.party_id) or (segs_party.party_id=stg.party_id)) ' ||
'	AND segs_party.market_segment_id=stg.segment_id ' ||
'	AND stg.party_id=parties.party_id ' ||
'	AND trunc(a.last_update_date) BETWEEN '''||p_start_date||''' AND '''||p_end_date||''''||
'	GROUP BY stg.segment_id,stg.party_id,parties.status,parties.last_update_date' ;



	COMMIT;

	--UPDATE STATEMENT FOR END_DATE_ACTIVE IF END_DATE_ACTIVE IS DIFFRENT FROM LAST RUN

	UPDATE	bim_i_party_sgmt_facts facts
	SET		end_date_Active = ( SELECT TRUNC(end_date_active)
								FROM	bim_i_party_sgmt_stg stg
								WHERE	facts.segment_id=stg.segment_id
								AND     facts.party_id = stg.party_id
							  )
	WHERE	EXISTS (SELECT 1
					FROM	bim_i_party_sgmt_stg stg
					WHERE	facts.segment_id=stg.segment_id
					AND     facts.party_id = stg.party_id
					AND		facts.end_date_active<>stg.end_date_active
					) ;

	--UPDATE STATEMENT FOR ACCOUNT_CLOSURE_DATE IF ACCOUNT_CLOSURE_DATE IS DIFFRENT FROM LAST RUN

	UPDATE	bim_i_party_sgmt_facts facts
	SET		account_close_date = ( SELECT	TRUNC(account_close_date)
									 FROM	bim_i_party_sgmt_stg stg
									 WHERE	facts.segment_id=stg.segment_id
									 AND     facts.party_id = stg.party_id
									)
	WHERE	EXISTS (SELECT 1
					FROM	bim_i_party_sgmt_stg stg
					WHERE	facts.segment_id=stg.segment_id
					AND     facts.party_id = stg.party_id
					AND		facts.account_close_date <> stg.account_close_date
					);

	--Insert rows for newly created segment and party combination

	Execute Immediate ' INSERT /*+ append parallel */INTO bim_i_party_sgmt_facts ' ||
'		(segment_id ' ||
'		,party_id ' ||
'		,start_date_active ' ||
'		,end_date_active ' ||
'		,status ' ||
'		,account_close_date ' ||
'		,creation_date ' ||
'		,last_update_date ' ||
'		,created_by ' ||
'		,last_updated_by ' ||
'		,last_update_login) ' ||
'	SELECT ' ||
'		market_segment_id segment_id ' ||
'		,nvl(reln.subject_id,a.party_id) party_id ' ||
'		,trunc(min(start_date_active)) start_date_active ' ||
'		,trunc(max(nvl(end_date_active,TO_DATE(''31/12/2199'',''DD/MM/YYYY'')))) end_date_active ' ||
'		,parties.status status ' ||
'		,CASE WHEN parties.status=''I'' then parties.last_update_date ELSE NULL END ' ||
'		,sysdate ' ||
'		,sysdate ' ||
'		,-1 ' ||
'		,-1 ' ||
'		,-1 ' ||
'	FROM	ams_party_market_segments a ' ||
'			,(SELECT a.cell_id   ' ||
'			 FROM ams_cells_all_b a, ams_list_queries_all b, ams_list_src_types c, source_query_scfb d ' ||
'			 WHERE b.act_list_query_used_by_id = a.cell_id ' ||
'			 AND b.arc_act_list_query_used_by =''CELL'' ' ||
'			 AND b.list_query_id = d.sql_id ' ||
'			 AND d.source_name = c.source_type_code ' ||
'			 AND c.based_on_tca_flag = ''Y''  ' ||
'			 AND a.sel_type =''SQL'' ' ||
'			 AND a.creation_date >= '''||g_initial_start_date||''''||
'			 AND a.status_code IN (''AVAILABLE'',''CANCELLED'') ' ||
'			 UNION ALL         ' ||
'			 SELECT a.cell_id  ' ||
'			 FROM ams_cells_all_b a,ams_list_src_types b,ams_act_discoverer_all c,ams_discoverer_sql d ' ||
'			 WHERE c.act_discoverer_used_by_id = a.cell_id ' ||
'			 AND c.arc_act_discoverer_used_by =''CELL'' ' ||
'			 AND c.discoverer_sql_id = d.discoverer_sql_id ' ||
'			 AND d.source_type_code = b.source_object_name ' ||
'			 AND b.based_on_tca_flag = ''Y''  ' ||
'			 AND a.sel_type=''DIWB'' ' ||
'			 AND a.creation_date >= '''||g_initial_start_date||''''||
'			 AND a.status_code IN (''AVAILABLE'',''CANCELLED'') ' ||
'			 ) b ' ||
'			 ,hz_relationships reln ' ||
'			 ,hz_parties parties ' ||
'	WHERE	a.market_segment_id=b.cell_id ' ||
'	AND	a.party_id=reln.party_id(+) ' ||
'	AND	reln.subject_type(+) =''ORGANIZATION''  ' ||
'	AND	OBJECT_TYPE(+)=''PERSON'' ' ||
'	AND	nvl(reln.subject_id,a.party_id)=parties.party_id ' ||
'	AND trunc(a.last_update_date) BETWEEN '''||p_start_date||''' AND '''||p_end_date||''''||
'	AND	NOT EXISTS ( SELECT 1  ' ||
'					FROM bim_i_party_sgmt_stg stg ' ||
'					WHERE stg.segment_id=a.market_segment_id ' ||
'					AND nvl(reln.subject_id,a.party_id)=stg.party_id ' ||
'					) ' ||
'	GROUP BY nvl(reln.subject_id,a.party_id),a.market_segment_id,parties.status,parties.last_update_date ' ;

	Execute Immediate ' DROP TABLE source_query_scfb ';

	COMMIT;

	--update account creation date for those parties which does not have acoounts(in case  of prospect)

	UPDATE bim_i_party_sgmt_facts a
	SET account_open_date=(SELECT GREATEST(min(TRUNC(creation_date)),trunc(a.start_date_active))
								FROM  hz_cust_accounts b
								WHERE a.party_id=b.party_id
								AND  b.creation_date >= g_initial_start_date)
	WHERE EXISTS( SELECT 1
				  FROM   hz_cust_accounts b
				  WHERE  a.party_id=b.party_id
				  AND    b.creation_date >= g_initial_start_date)
	AND    account_open_date IS NULL;


	EXECUTE IMMEDIATE 'TRUNCATE TABLE '||l_schema||'.bim_i_party_sgmt_stg';

     bis_collection_utilities.wrapup(p_status => TRUE
                        ,p_count => sql%rowcount
                        ,p_period_from => p_start_date
                        ,p_period_to  => p_end_date
						,p_attribute1 => 'INITIAL_LOAD_START_DATE'
						,p_attribute2 =>g_initial_start_date
                        );

	COMMIT;

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
Execute Immediate 'DROP TABLE source_query_scfb';
     -- Standard call to get message count and if count=1, get the message
     FND_msg_PUB.Count_And_Get (
          --  p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

    bis_collection_utilities.log('BIM_I_SGMT_CUST_FACTS_PKG:INCREMENTAL_LOAD:IN EXPECTED EXCEPTION '||sqlerrm(sqlcode));

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
Execute Immediate 'DROP TABLE source_query_scfb';

     -- Standard call to get message count and if count=1, get the message
     FND_msg_PUB.Count_And_Get (
            --p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

    bis_collection_utilities.log('BIM_I_SGMT_CUST_FACTS_PKG:INCREMENTAL_LOAD:IN UNEXPECTED EXCEPTION '||sqlerrm(sqlcode));

   WHEN OTHERS THEN

     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
Execute immediate 'DROP TABLE source_query_scfb';

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

    bis_collection_utilities.log('BIM_I_SGMT_CUST_FACTS_PKG:INCREMENTAL_LOAD:IN OTHERS EXCEPTION '||sqlerrm(sqlcode));


END incremental_load;


END BIM_I_SGMT_CUST_FACTS_PKG;


/
