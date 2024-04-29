--------------------------------------------------------
--  DDL for Package Body BIM_SOURCE_CODE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIM_SOURCE_CODE_PKG" AS
/*$Header: bimsrcdb.pls 120.3 2005/11/11 01:55:04 arvikuma noship $*/

 g_pkg_name  CONSTANT  VARCHAR2(20) := 'BIM_SOURCE_CODE_PKG';
 g_file_name CONSTANT  VARCHAR2(20) := 'bimsrcdb.pls';

/* ----------------------------------------------------------------------
    This procedure will insert a record for object = 'SOURCE' in
    BIM_REP_HISTORY table, whenever the LOAD_DATA procedure is called
    for the first time in the day.
 ----------------------------------------------------------------------*/
 PROCEDURE LOG_HISTORY
    (
    p_object                   IN  VARCHAR2     DEFAULT 'SOURCE',
    p_start_date               IN  DATE         DEFAULT NULL,
    p_end_date                 IN  DATE         DEFAULT NULL
    )
    IS
    l_user_id          	   	   NUMBER := FND_GLOBAL.USER_ID();
    l_sysdate          	  	   DATE   := SYSDATE;
    l_api_version_number       	   CONSTANT NUMBER       := 1.0;
    l_api_name                 	   CONSTANT VARCHAR2(30) := 'LOG_HISTORY';
 BEGIN

    INSERT INTO BIM_REP_HISTORY
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

 /*----------------------------------------------------------------------------
    This procedure will Populate BIM_R_SOURCE_CODES and BIM_R_LOCATIONS tables
 ----------------------------------------------------------------------------*/

 PROCEDURE LOAD_DATA
    (p_api_version_number    IN  NUMBER
    ,p_init_msg_list         IN  VARCHAR2     := FND_API.G_FALSE
    ,p_validation_level      IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL
    ,x_msg_count             OUT NOCOPY NUMBER
    ,x_msg_data              OUT NOCOPY VARCHAR2
    ,x_return_status         OUT NOCOPY VARCHAR2
    ) IS
    l_api_version_number     CONSTANT NUMBER       := 1.0;
    l_api_name               CONSTANT VARCHAR2(30) := 'LOAD_DATA';
    l_user_id          	     NUMBER := FND_GLOBAL.USER_ID();
    l_success                VARCHAR2(3);
    l_seq_name               VARCHAR(100);
    l_def_tablespace         VARCHAR2(100);
    l_index_tablespace       VARCHAR2(100);
    l_oracle_username        VARCHAR2(100);
    l_table_name	     VARCHAR2(100);
    l_temp_msg		     VARCHAR2(100);

    /* Following tables are declared for storing information about the indexes */

    TYPE  generic_number_table IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
    TYPE  generic_char_table IS TABLE OF VARCHAR2(100) INDEX BY BINARY_INTEGER;

    i			     NUMBER;
    l_creation_date	     DATE;

    CURSOR    chk_history_data
    IS
    SELECT  trunc(max(creation_date))
    FROM    BIM_REP_HISTORY
    WHERE   object = 'SOURCE';
    l_status                      VARCHAR2(5);
    l_industry                    VARCHAR2(5);
    l_schema                      VARCHAR2(30);
    l_return                       BOOLEAN;


    BEGIN /* Standard API call to check for call compatibility */
      l_return  := fnd_installation.get_app_info('BIM', l_status, l_industry, l_schema);


    IF NOT FND_API.Compatible_API_Call (l_api_version_number, p_api_version_number, l_api_name, g_pkg_name)
       THEN RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    /* Initialize message list if p_init_msg_list is set to TRUE */
    IF FND_API.to_Boolean( p_init_msg_list )
    THEN
      FND_MSG_PUB.initialize;
    END IF;

    /* Initialize API return status to SUCCESS */
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    /* Find if the data will be loaded for the first time in the day or not */
    OPEN  chk_history_data;
    FETCH chk_history_data INTO l_creation_date;
    CLOSE chk_history_data;

    --dbms_output.put_line('Just before checking last_creation_date from history table : '||l_creation_date);



    /* Begin of the code for checking whether first-time or subsequent run */
    IF ((l_creation_date) = trunc(sysdate)) THEN
       /* Return control back to the caller before the normal end of procedure is reached */
       /* No messages in the LOG file */
       --ams_utility_pvt.write_conc_log('TABLES BIM_R_SOURCE_CODES and BIM_R_LOCATIONS are already POPULATED Today');
       return;
    END IF;

    l_table_name := 'BIM_R_LOCATIONS';
    fnd_message.set_name('BIM','BIM_R_TRUNCATE_TABLE');
    fnd_message.set_token('TABLE_NAME',l_table_name,FALSE);
    fnd_file.put_line(fnd_file.log,fnd_message.get);

    EXECUTE IMMEDIATE 'TRUNCATE TABLE ' ||l_schema||'.BIM_R_LOCATIONS';

      l_table_name := 'BIM_R_LOCATIONS';
      fnd_message.set_name('BIM','BIM_R_POPULATE_TABLE');
      fnd_message.set_token('TABLE_NAME',l_table_name,FALSE);
      fnd_file.put_line(fnd_file.log,fnd_message.get);

    /* The INSERT statement to populate BIM_R_LOCATIONS table begins here */

    INSERT
    INTO BIM_R_LOCATIONS
        (
        country,
        region)
    SELECT
     country_code, area2_code
    FROM jtf_loc_hierarchies_b
    WHERE location_type_code = 'COUNTRY'
    AND country_code is not null;


      l_table_name := 'BIM_R_LOCATIONS';
      fnd_message.set_name('BIM','BIM_R_ANALYZE_TABLE');
      fnd_message.set_token('TABLE_NAME',l_table_name,FALSE);
      fnd_file.put_line(fnd_file.log,fnd_message.get);

    -- Analyze the bim_r_locations table
    DBMS_STATS.gather_table_stats('BIM','BIM_R_LOCATIONS', estimate_percent => 5,
                                  degree => 8, granularity => 'GLOBAL', cascade =>TRUE);


   /* Dropping INdexes */
      BIM_UTL_PKG.DROP_INDEX('BIM_R_SOURCE_CODES');


    l_table_name := 'BIM_R_SOURCE_CODES';
    fnd_message.set_name('BIM','BIM_R_TRUNCATE_TABLE');
    fnd_message.set_token('TABLE_NAME',l_table_name,FALSE);
    fnd_file.put_line(fnd_file.log,fnd_message.get);

    EXECUTE IMMEDIATE 'TRUNCATE TABLE ' ||l_schema||'.BIM_R_SOURCE_CODES';


      l_table_name := 'BIM_R_SOURCE_CODES';
      fnd_message.set_name('BIM','BIM_R_POPULATE_TABLE');
      fnd_message.set_token('TABLE_NAME',l_table_name,FALSE);
      fnd_file.put_line(fnd_file.log,fnd_message.get);

    /* The INSERT statement to populate BIM_R_SOURCE_CODES table begins here */

    INSERT /*+ append parallel(SRC,1) */
    INTO BIM_R_SOURCE_CODES SRC
	(
	source_code_id,
	source_code,
	parent_object_type,
	object_type,
	parent_object_id,
	object_id,
	business_unit_id,
	status,
	country_code,
	start_date,
	end_date
	)
    SELECT  /*+ parallel(INNER,1) */
	inner.source_code_id,
	inner.source_code,
	inner.parent_object_type,
	inner.object_type,
	inner.parent_object_id,
	inner.object_id,
	inner.business_unit_id,
	inner.status,
	inner.country_code,
	inner.start_date,
	inner.end_date
    FROM
    (
    SELECT
    a.source_code_id source_code_id,
    a.source_code source_code,
    'CAMP' parent_object_type,
    'CAMP' object_type,
    b.campaign_id parent_object_id,
    0 object_id,
    b.business_unit_id,
    b.status_code status,
    c.country_code country_code,
    b.actual_exec_start_date start_date,
    b.actual_exec_end_date end_date
    FROM
    ams_source_codes a,
    ams_campaigns_all_b b,
    jtf_loc_hierarchies_b c
    WHERE
    a.source_code = b.source_code
    AND a.source_code_for_id = b.campaign_id
    AND b.city_id = c.location_hierarchy_id
    AND a.arc_source_code_for = 'CAMP'
    AND b.status_code IN ('COMPLETED', 'CANCELLED', 'CLOSED', 'ACTIVE')
    UNION ALL
    SELECT
    a.source_code_id source_code_id,
    a.source_code source_code,
    'CAMP' parent_object_type,
    'CSCH' object_type,
    b.campaign_id parent_object_id,
    c.schedule_id object_id,
    b.business_unit_id,
    b.status_code status,
    d.country_code country_code,
    c.start_date_time start_date,
    c.end_date_time end_date
    FROM
    ams_source_codes a,
    ams_campaigns_all_b b,
    ams_campaign_schedules_b c,
    jtf_loc_hierarchies_b d
    WHERE
    a.source_code = c.source_code
    AND a.source_code_for_id = c.schedule_id
    AND a.arc_source_code_for = 'CSCH'
    AND b.campaign_id = c.campaign_id
    AND b.city_id = d.location_hierarchy_id
    AND b.status_code IN ('COMPLETED', 'CANCELLED', 'CLOSED', 'ACTIVE')
    UNION ALL
    SELECT
    a.source_code_id source_code_id,
    a.source_code source_code,
    'EVEH' parent_object_type,
    'EVEH' object_type,
    b.event_header_id parent_object_id,
    0 object_id,
    b.business_unit_id,
    b.system_status_code status,
    c.country_code country_code,
    b.active_from_date start_date,
    b.active_to_date end_date
    FROM
    ams_source_codes a,
    ams_event_headers_all_b b,
    jtf_loc_hierarchies_b c
    WHERE
    a.source_code = b.source_code
    AND a.source_code_for_id = b.event_header_id
    AND b.country_code = c.location_hierarchy_id
    AND a.arc_source_code_for = 'EVEH'
    AND b.system_status_code IN ('COMPLETED', 'CANCELLED', 'CLOSED', 'ACTIVE')
    UNION ALL
    SELECT
    a.source_code_id source_code_id,
    a.source_code source_code,
    'EVEH' parent_object_type,
    a.arc_source_code_for object_type,
    b.event_header_id parent_object_id,
    c.event_offer_id object_id,
    b.business_unit_id,
    b.system_status_code status,
    d.country_code country_code,
    c.event_start_date start_date,
    c.event_end_date end_date
    FROM
    ams_source_codes a,
    ams_event_headers_all_b b,
    ams_event_offers_all_b c,
    jtf_loc_hierarchies_b d
    WHERE
    a.source_code = c.source_code
    AND a.source_code_for_id = c.event_offer_id
    AND a.arc_source_code_for in ('EONE', 'EVEO')
    AND b.event_header_id = c.event_header_id
    AND b.country_code = d.location_hierarchy_id
    AND b.system_status_code IN ('COMPLETED', 'CANCELLED', 'CLOSED', 'ACTIVE')
    ) "INNER";


    /* Make entry in the history table */
    IF SQL%ROWCOUNT > 0 THEN
       LOG_HISTORY(P_OBJECT => 'SOURCE');
    END IF;

    COMMIT;

    --dbms_output.put_Line('JUST  A F T E R  THE MAIN INSERT STATMENT for bim_r_source_codes');

      l_table_name := 'BIM_R_SOURCE_CODES';
      fnd_message.set_name('BIM','BIM_R_ANALYZE_TABLE');
      fnd_message.set_token('TABLE_NAME',l_table_name,FALSE);
      fnd_file.put_line(fnd_file.log,fnd_message.get);

    /* Analyze the bim_r_source_codes table */
    DBMS_STATS.gather_table_stats('BIM','BIM_R_SOURCE_CODES', estimate_percent => 5,
                                  degree => 8, granularity => 'GLOBAL', cascade =>TRUE);

    /* Recreating Indexes */
    BIM_UTL_PKG.CREATE_INDEX('BIM_R_SOURCE_CODES');

      fnd_message.set_name('BIM','BIM_R_PROG_COMPLETION');
      fnd_message.set_token('PROGRAM_NAME','Populating Source Codes',FALSE);
      fnd_file.put_line(fnd_file.log,fnd_message.get);



    /* Standard call to get message count and if count is 1, get message info */
    FND_MSG_PUB.Count_And_Get
        ( p_count          =>   x_msg_count,
          p_data           =>   x_msg_data
    );
    COMMIT;

    --dbms_output.put_line('S u c c e s s f u l l y   e x i t i n g ......');
 EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
	 /* Standard call to get message count and if count=1, get the message */
	 FND_MSG_PUB.Count_And_Get
 	     ( p_count   => x_msg_count,
               p_data    => x_msg_data
	 );
     ams_utility_pvt.write_conc_log('BIM_R_SOURCE_CODES:IN EXPECTED EXCEPTION '||sqlerrm(sqlcode));

     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	 /* Standard call to get message count and if count=1, get the message */
	 FND_MSG_PUB.Count_And_Get
	     ( p_count => x_msg_count,
	       p_data  => x_msg_data
	 );
     ams_utility_pvt.write_conc_log('BIM_R_SOURCE_CODES:IN UNEXPECTED EXCEPTION '||sqlerrm(sqlcode));

     WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	IF FND_MSG_PUB.Check_msg_Level ( FND_msg_PUB.G_msg_LVL_UNEXP_ERROR) THEN
           FND_msg_PUB.Add_Exc_msg( g_pkg_name,l_api_name);
	END IF;
     	/* Standard call to get message count and if count=1, get the message */
	FND_MSG_PUB.Count_And_Get
	     ( p_count => x_msg_count,
               p_data  => x_msg_data
	);
    ams_utility_pvt.write_conc_log('BIM_R_SOURCE_CODES:IN OTHERS EXCEPTION '||sqlerrm(sqlcode));

    --dbms_output.put_Line('EXCEPTIONS: OTHERS  in bim_r_source_codes -- '||SQLERRM(SQLCODE));

 /* End of Procedure */
 END LOAD_DATA;

/* End of Package */
END BIM_SOURCE_CODE_PKG;

/
