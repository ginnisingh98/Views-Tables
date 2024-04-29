--------------------------------------------------------
--  DDL for Package Body BIM_I_SRC_CODE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIM_I_SRC_CODE_PKG" AS
/*$Header: bimiscdb.pls 120.6 2006/01/23 02:08:06 arvikuma noship $*/

 g_pkg_name  CONSTANT  VARCHAR2(20) := 'BIM_I_SRC_CODE_PKG';
 g_file_name CONSTANT  VARCHAR2(20) := 'bimiscdb.pls';
 g_start_date CONSTANT  DATE := to_date(fnd_profile.value('BIS_GLOBAL_START_DATE'),'MM/DD/YYYY');

------------------------------------------------------------------------------------------------
----
----This procedure finds out if the user is trying to run first_load or subsequent load
----and calls the load_data procedure with the specific parameters to each type of load
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
    ,p_truncate_flg	       IN  VARCHAR2
    --,p_mode                  IN  VARCHAR2
    ) IS

    l_object_name             CONSTANT VARCHAR2(80) := 'BIM_SOURCE_CODE';
    l_conc_start_date         DATE;
    l_conc_end_date           DATE;
    l_start_date              DATE;
    l_end_date                DATE;
    l_user_id                 NUMBER := FND_GLOBAL.USER_ID();
    l_api_version_number      CONSTANT NUMBER       := 1.0;
    l_api_name                CONSTANT VARCHAR2(30) := 'BIM_I_SRC_CODE_PKG';
    l_mesg_text		      VARCHAR2(100);
    l_load_type	              VARCHAR2(100);
    l_global_date             CONSTANT DATE  :=  bis_common_parameters.get_global_start_date;
    l_missing_date            BOOLEAN := FALSE;
    l_sysdate		      DATE;

BEGIN


     IF NOT bis_collection_utilities.setup(l_object_name)  THEN
        bis_collection_utilities.log('Object BIM_SOURCE_CODE Not Setup Properly');
        RAISE FND_API.G_EXC_ERROR;
     END IF;
     bis_collection_utilities.log('Start of the Source Code Population Program');

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

        bis_collection_utilities.get_last_refresh_dates(l_object_name,
                                                        l_conc_start_date,
                                                        l_conc_end_date,
                                                        l_start_date,
                                                        l_end_date);
        IF (l_end_date IS NULL) THEN


                l_load_type  := 'FIRST_LOAD';

                FIRST_LOAD(p_start_date => greatest(trunc(l_global_date),trunc(p_start_date))
                     ,p_end_date =>  sysdate
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
	                l_load_type  := 'SUBSEQUENT_LOAD';

	                INCREMENTAL_LOAD(p_start_date => trunc(l_end_date)
		             ,p_end_date =>  sysdate
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
-- This procedure will populates all the data required into facts table for the first load.
--
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
    l_user_id                     NUMBER := FND_GLOBAL.USER_ID();
    l_api_version_number   	  CONSTANT NUMBER       := 1.0;
    l_api_name             	  CONSTANT VARCHAR2(30) := 'FIRST_LOAD';
    l_table_name		  VARCHAR2(100);


    l_status       VARCHAR2(5);
    l_industry     VARCHAR2(5);
    l_schema       VARCHAR2(30);
    l_return       BOOLEAN;

   TYPE  generic_number_table IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

   TYPE  generic_char_table IS TABLE OF VARCHAR2(100) INDEX BY BINARY_INTEGER;

   i			NUMBER;
   l_min_start_date     DATE;

   l_org_id 			number;



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



   /* Dropping INdexes */
--      BIM_UTL_PKG.DROP_INDEX('BIM_I_SOURCE_CODES');

      --EXECUTE IMMEDIATE 'TRUNCATE TABLE bim.bim_i_source_codes ';


      l_table_name := 'BIM_I_SOURCE_CODES';
      bis_collection_utilities.log('Running Initial Load of Source Codes');

    EXECUTE IMMEDIATE 'TRUNCATE TABLE '||l_schema||'.BIM_I_SOURCE_CODES';

    BIS_COLLECTION_UTILITIES.deleteLogForObject('BIM_SOURCE_CODE');

    INSERT /*+ append parallel */
    INTO BIM_I_SOURCE_CODES SRC
        (
        creation_date,
        last_update_date,
        created_by,
        last_updated_by,
        last_update_login,
        source_code_id,
	parent_source_code_id,
        source_code,
	rollup_type,
        object_id,
        object_type,
        object_status,
        object_purpose,
        object_country,
        object_region,
        business_unit_id,
        owner_user_id,
        start_date,
        end_date,
        child_object_id,
        child_object_type,
        child_object_status,
        child_object_purpose,
        child_object_country,
        child_object_region,
        child_object_usage,
        activity_id,
        activity_type,
	adj_start_date,
	adj_end_date,
        obj_last_update_date
        )
      SELECT
        sysdate,
        sysdate,
        -1,
        -1,
        -1,
	inner.source_code_id,
	inner.parent_source_code_id,
	inner.source_code,
	inner.rollup_type,
	inner.object_id,
	inner.object_type,
	inner.object_status,
	inner.object_purpose,
	inner.object_country,
	inner.object_region,
	inner.business_unit_id,
	inner.owner_user_id,
	trunc(inner.start_date),
	trunc(inner.end_date),
	inner.child_object_id,
	inner.child_object_type,
	inner.child_object_status,
	inner.child_object_purpose,
	inner.child_object_country,
	inner.child_object_region,
	inner.child_object_usage,
	inner.activity_id,
	inner.activity_type,
	trunc(inner.adj_start_date),
	trunc(inner.adj_end_date),
        inner.obj_last_update_date
      FROM
	(
      SELECT
	a.source_code_id           source_code_id,
	b.parent_campaign_id*(-1)  parent_source_code_id,
	a.source_code              source_code,
	'CAMP'                     rollup_type,
	b.campaign_id              object_id,
	--b.rollup_type            object_type,
	a.arc_source_code_for      object_type,
	b.status_code              object_status,
	b.campaign_type            object_purpose,
	d.country_code             object_country,
	t.parent_territory_code    object_region,
	b.business_unit_id         business_unit_id,
	b.owner_user_id            owner_user_id,
	b.actual_exec_start_date   start_date,
	b.actual_exec_end_date     end_date,
	0                          child_object_id,
	--b.rollup_type              child_object_type,
	a.arc_source_code_for      child_object_type,
	''                         child_object_status,
	''                         child_object_purpose,
	''                         child_object_country,
	''                         child_object_region,
	''                         child_object_usage,
	0                          activity_id,
	''                         activity_type,
	case
	when b.actual_exec_end_date < g_start_date then null
	else greatest(b.actual_exec_start_date,g_start_date) end adj_start_date,
	case
	when b.actual_exec_end_date < g_start_date then null
	else b.actual_exec_end_date end adj_end_date,
        b.last_update_date  obj_last_update_date
      FROM
	ams_source_codes a,
	ams_campaigns_all_b b,
	jtf_loc_hierarchies_b d,
	bis_territory_hierarchies t
      WHERE
	 a.source_code = b.source_code
        AND a.source_code_for_id = b.campaign_id
	AND b.city_id = d.location_hierarchy_id
        AND t.parent_territory_type(+) = 'AREA'
        AND t.child_territory_type(+) = 'COUNTRY'
        AND t.child_territory_code(+) = d.country_code
	AND a.arc_source_code_for = 'CAMP'
	AND b.rollup_type not in ('RCAM')
	AND b.status_code IN ('COMPLETED', 'CANCELLED', 'CLOSED', 'ACTIVE', 'ON_HOLD')
	AND b.actual_exec_start_date <= p_end_date
      ----------------------------------------------+
      UNION ALL
      ----------------------------------------------+
      SELECT
	a.source_code_id           source_code_id,
	s.source_code_id           parent_source_code_id,
	a.source_code              source_code,
	'CSCH'                     rollup_type,
	b.campaign_id              object_id,
	--b.rollup_type            object_type,
	'CAMP'                     object_type,
	b.status_code              object_status,
	b.campaign_type            object_purpose,
	d.country_code             object_country,
	t.parent_territory_code    object_region,
	b.business_unit_id         business_unit_id,
	c.owner_user_id            owner_user_id,
	c.start_date_time          start_date,
	TO_DATE(DECODE(c.end_date_time,null,
		       DECODE(c.start_date_time,null,null,b.actual_exec_end_date),
		       c.end_date_time),'DD/MM/RRRR') end_date,
	c.schedule_id              child_object_id,
	a.arc_source_code_for      child_object_type,
	c.status_code              child_object_status,
	c.purpose		   child_object_purpose,
	d2.country_code            child_object_country,
	d2.area2_code              child_object_region,
	c.usage                    child_object_region,
	c.activity_id              activity_id,
	c.activity_type_code       activity_type,
	case
	when nvl(c.end_date_time,b.actual_exec_end_date) < g_start_date then null
	else greatest(c.start_date_time,g_start_date) end adj_start_date,
	case
	when nvl(c.end_date_time,b.actual_exec_end_date) < g_start_date then null
	else
	TO_DATE(DECODE(c.end_date_time,null,
		       DECODE(c.start_date_time,null,null,b.actual_exec_end_date),
		       c.end_date_time),'DD/MM/RRRR') end adj_end_date,
        c.last_update_date         obj_last_update_date
      FROM
	ams_source_codes a,
	ams_campaigns_all_b b,
	ams_campaign_schedules_b c,
	jtf_loc_hierarchies_b d,
	jtf_loc_hierarchies_b d2,
	bis_territory_hierarchies t,
	ams_source_codes s
      WHERE
	    a.source_code = c.source_code
        AND a.source_code_for_id = c.schedule_id
	AND a.arc_source_code_for = 'CSCH'
	AND b.rollup_type not in ('RCAM')
	AND b.campaign_id = c.campaign_id
	AND b.city_id = d.location_hierarchy_id
	AND c.country_id = d2.location_hierarchy_id
        AND t.parent_territory_type(+) = 'AREA'
        AND t.child_territory_type(+) = 'COUNTRY'
        AND t.child_territory_code(+) = d.country_code
	AND b.status_code IN ('COMPLETED', 'CANCELLED', 'CLOSED', 'ACTIVE', 'ON_HOLD')
	AND c.status_code IN ('COMPLETED', 'CANCELLED', 'CLOSED', 'ACTIVE', 'ON_HOLD')
	AND s.source_code_for_id = b.campaign_id
	AND s.arc_source_code_for = 'CAMP'
	AND a.active_flag = 'Y'  -- do we need this condition ?
	AND s.active_flag = 'Y' -- do we need this condition ?
	AND c.start_date_time <= p_end_date
      ----------------------------------------------+
      UNION ALL
      ----------------------------------------------+
      SELECT
	a.source_code_id           source_code_id,
	b.program_id*(-1)          parent_source_code_id,
	a.source_code              source_code,
	'EVEH'                     rollup_type,
	b.event_header_id          object_id,
	a.arc_source_code_for      object_type,
	b.system_status_code       object_status,
	b.event_purpose_code       object_purpose_2,
	d.country_code             object_country,
	t.parent_territory_code    object_region,
	b.business_unit_id         business_unit_id,
	b.owner_user_id            owner_user_id,
	b.active_from_date         start_date,
	b.active_to_date           end_date,
	0                          child_object_id,
	a.arc_source_code_for      child_object_type,
	''                         child_object_status,
	''                         child_object_purpose,
	''                         child_object_country,
	''                         child_object_region,
	''                         child_object_usage,
	0                          activity_id,
	''                         activity_type,
	case
	when b.active_to_date < g_start_date then null
	else greatest(b.active_from_date,g_start_date) end adj_start_date,
	case
	when b.active_to_date < g_start_date then null
	else b.active_to_date end adj_end_date,
	b.last_update_date         obj_last_update_date
      FROM
	ams_source_codes a,
	ams_event_headers_all_b b,
	jtf_loc_hierarchies_b d,
	bis_territory_hierarchies t
      WHERE
	    a.source_code = b.source_code
        AND a.source_code_for_id = b.event_header_id
	AND b.country_code = d.location_hierarchy_id
        AND t.parent_territory_type(+) = 'AREA'
        AND t.child_territory_type(+) = 'COUNTRY'
        AND t.child_territory_code(+) = d.country_code
	AND a.arc_source_code_for = 'EVEH'
	AND b.system_status_code IN ('COMPLETED', 'CANCELLED', 'CLOSED', 'ACTIVE', 'ON_HOLD')
        AND b.active_from_date <= p_end_date
      ----------------------------------------------+
      UNION ALL
      ----------------------------------------------+
      SELECT
	a.source_code_id           source_code_id,
	s.source_code_id           parent_source_code_id,
	a.source_code              source_code,
	'EVEO'                     rollup_type,
	b.event_header_id          object_id,
	'EVEH'                     object_type,
	b.system_status_code       object_status,
	b.event_purpose_code       object_purpose_2,
	d.country_code             object_country,
	t.parent_territory_code    object_region,
	b.business_unit_id         business_unit_id,
	c.owner_user_id            owner_user_id,
	c.event_start_date         start_date,
	TO_DATE(DECODE(c.event_end_date,null,
		       DECODE(c.event_start_date,null,null,b.active_to_date),
		       c.event_end_date),'DD/MM/RRRR') end_date,
	c.event_offer_id           child_object_id,
	a.arc_source_code_for      child_object_type,
	c.system_status_code       child_object_status,
	c.event_purpose_code       child_object_purpose_2,
	d2.country_code            child_object_country,
	d2.area2_code              child_object_region,
	''                         child_object_usage,
	0                          activity_id,
	''                         activity_type,
   case
    when nvl(c.event_end_date,b.active_to_date) < g_start_date then null
    else greatest(c.event_start_date,g_start_date) end adj_start_date,
   case
    when nvl(c.event_end_date,b.active_to_date) < g_start_date then null
    else
    TO_DATE(DECODE(c.event_end_date,null,
		       DECODE(c.event_start_date,null,null,b.active_to_date),
		       c.event_end_date),'DD/MM/RRRR') end adj_end_date,
    c.last_update_date         obj_last_update_date
      FROM
	ams_source_codes a,
	ams_event_headers_all_b b,
	ams_event_offers_all_b c,
	jtf_loc_hierarchies_b d,
	jtf_loc_hierarchies_b d2,
	bis_territory_hierarchies t ,
	ams_source_codes s
      WHERE
	    a.source_code = c.source_code
        AND a.source_code_for_id = c.event_offer_id
	AND a.arc_source_code_for= 'EVEO'
	AND b.event_header_id = c.event_header_id
	AND b.country_code = d.location_hierarchy_id
	AND c.country_code = d2.location_hierarchy_id
        AND t.parent_territory_type(+) = 'AREA'
        AND t.child_territory_type(+) = 'COUNTRY'
        AND t.child_territory_code(+) = d.country_code
	AND b.system_status_code IN ('COMPLETED', 'CANCELLED', 'CLOSED', 'ACTIVE', 'ON_HOLD')
	AND c.system_status_code IN ('COMPLETED', 'CANCELLED', 'CLOSED', 'ACTIVE', 'ON_HOLD')
	AND s.source_code_for_id = b.event_header_id
	AND s.arc_source_code_for = 'EVEH'
	AND a.active_flag = 'Y'  -- do we need this condition ?
	AND s.active_flag = 'Y' -- do we need this condition ?
AND c.event_start_date <= p_end_date
      ----------------------------------------------+
      UNION ALL
      SELECT
        a.source_code_id           source_code_id,
	c.parent_id*(-1)           parent_source_code_id,
        a.source_code              source_code,
	'EONE'                     rollup_type,
        c.event_offer_id           object_id,
        'EONE'                     object_type,
        c.system_status_code       object_status,
        c.event_purpose_code       object_purpose_2,
        d.country_code             object_country,
	t.parent_territory_code    object_region,
        c.business_unit_id         business_unit_id,
        c.owner_user_id            owner_user_id,
        c.event_start_date         start_date,
        c.event_end_date           end_date,
        0                          child_object_id,
        ''                         child_object_type,
        ''                         child_object_status,
        ''                         child_object_purpose_2,
        ''                         child_object_country,
        ''                         child_object_region,
        ''                         child_object_usage,
        0                          activity_id,
        ''                         activity_type,
       	case
	when c.event_end_date < g_start_date then null
	else greatest(c.event_start_date,g_start_date) end adj_start_date,
	case
	when c.event_end_date < g_start_date then null
	else c.event_end_date end adj_end_date,
        c.last_update_date         obj_last_update_date
      FROM  ams_source_codes a,
	    ams_event_offers_all_b c,
	    jtf_loc_hierarchies_b d,
	    bis_territory_hierarchies t
       WHERE   a.source_code = c.source_code
       AND     a.source_code_for_id = c.event_offer_id
       AND     a.arc_source_code_for ='EONE'
       AND     nvl(c.parent_type,'N') <> 'CAMP'
       AND     c.country_code = d.location_hierarchy_id
       AND     t.parent_territory_type(+) = 'AREA'
       AND     t.child_territory_type(+) = 'COUNTRY'
       AND     t.child_territory_code(+) = d.country_code
       AND     c.system_status_code IN ('COMPLETED', 'CANCELLED', 'CLOSED', 'ACTIVE', 'ON_HOLD')
       AND     c.event_start_date <= p_end_date
      ----------------------------------------------
      UNION ALL
      ----------------------------------------------
      SELECT
	b.campaign_id*(-1)         source_code_id,
	b.parent_campaign_id*(-1)           parent_source_code_id,
	b.source_code              source_code,
	'CAMP'                     rollup_type,
	b.campaign_id              object_id,
	b.rollup_type              object_type,
	b.status_code              object_status,
	b.campaign_type            object_purpose,
	d.country_code             object_country,
	t.parent_territory_code    object_region,
	b.business_unit_id         business_unit_id,
	b.owner_user_id            owner_user_id,
	b.actual_exec_start_date   start_date,
	b.actual_exec_end_date     end_date,
	0                          child_object_id,
	b.rollup_type              child_object_type,
	''                         child_object_status,
	''                         child_object_purpose,
	''                         child_object_country,
	''                         child_object_region,
	''                         child_object_usage,
	0                          activity_id,
	''                         activity_type,
	case
	when b.actual_exec_end_date < g_start_date then null
	else greatest(b.actual_exec_start_date,g_start_date) end adj_start_date,
	case
	when b.actual_exec_end_date < g_start_date then null
	else b.actual_exec_end_date end adj_end_date,
        b.last_update_date         obj_last_update_date
      FROM
	ams_campaigns_all_b b,
	jtf_loc_hierarchies_b d,
	bis_territory_hierarchies t
      WHERE
         b.actual_exec_start_date <= p_end_date
	AND    b.city_id = d.location_hierarchy_id
        AND t.parent_territory_type(+) = 'AREA'
        AND t.child_territory_type(+) = 'COUNTRY'
        AND t.child_territory_code(+) = d.country_code
	AND b.rollup_type = 'RCAM'
	AND b.status_code IN ('COMPLETED', 'CANCELLED', 'CLOSED', 'ACTIVE', 'ON_HOLD')
      ----------------------------------------------+
      ) inner
      ;

     COMMIT;

--handle categories belong to Reporting category set

     UPDATE BIM_I_SOURCE_CODES code
        SET code.category_id
                 = (SELECT nvl(prod.category_id,-1) category_id
                      FROM
                        ams_act_products prod
                      WHERE
                          prod.act_product_used_by_id = object_id
                      AND prod.arc_act_product_used_by = object_type
                      AND prod.primary_product_flag = 'Y'
                   )
     WHERE
           EXISTS (SELECT 1
                      FROM
                        ams_act_products prod
                      WHERE
                          prod.act_product_used_by_id = object_id
                      AND prod.arc_act_product_used_by = object_type
                      AND prod.primary_product_flag = 'Y'
                   );

     UPDATE BIM_I_SOURCE_CODES code
        SET code.category_id
                 = (SELECT nvl(prod.category_id,-1) category_id
                      FROM
                        ams_act_products prod
                      WHERE
                          prod.act_product_used_by_id = child_object_id
                      AND prod.arc_act_product_used_by = child_object_type
                      AND prod.primary_product_flag = 'Y'
                   )
     WHERE
           EXISTS (SELECT 1
                      FROM
                        ams_act_products prod
                      WHERE
                          prod.act_product_used_by_id = child_object_id
                      AND prod.arc_act_product_used_by = child_object_type
                      AND prod.primary_product_flag = 'Y'
                   );

   COMMIT;



     bis_collection_utilities.wrapup(p_status => TRUE
                        ,p_count => sql%rowcount
                        ,p_period_from =>p_start_date
                        ,p_period_to  => sysdate
                        );

     /***************************************************************/

     --l_table_name := 'BIM_I_SOURCE_CODES';
     --fnd_message.set_name('BIM','BIM_R_ANALYZE_TABLE');
     --fnd_message.set_token('TABLE_NAME',l_table_name,FALSE);
     --fnd_file.put_line(fnd_file.log,fnd_message.get);
     bis_collection_utilities.log('Before Analyze of the table BIM_I_SOURCE_CODES');

   --Analyze the facts table
     DBMS_STATS.gather_table_stats('BIM','BIM_I_SOURCE_CODES', estimate_percent => 5,
                                  degree => 8, granularity => 'GLOBAL', cascade =>TRUE);

    --EXECUTE IMMEDIATE ('TRUNCATE TABLE '||l_schema||'.MLOG$_BIM_I_SOURCE_CODES');

   /* Recreating Indexes */
--      BIM_UTL_PKG.CREATE_INDEX('BIM_I_SOURCE_CODES');

      /************--Start--********To get Resource ids of Active Employees***************************/

/*


 bis_collection_utilities.log('Start of  Initial Load of Resource_ids');

execute immediate 'truncate table bim.bim_i_resource';

 insert into bim.bim_i_resource
   (resource_id)
   select res.resource_id from jtf_Rs_resource_extns res, fnd_user fn
where fn.user_id = res.user_id and
nvl(fn.end_date,sysdate+1) > sysdate and
nvl(res.end_date_active,sysdate+1)>sysdate and
category = 'EMPLOYEE'
and exists (
SELECT  1
FROM    per_all_people_f            per
,       per_all_assignments_f       asg
,       per_assignment_status_types ast
WHERE   asg.person_id = per.person_id
AND     asg.assignment_status_type_id = ast.assignment_status_type_id
AND     asg.assignment_type = 'E'  -- give me only employee assignments
AND     asg.primary_flag = 'Y'     -- give me only primary assignments
AND     TRUNC(SYSDATE) BETWEEN per.effective_start_date AND per.effective_end_date
AND     TRUNC(SYSDATE) BETWEEN asg.effective_start_date AND asg.effective_end_date
AND     ast.assignment_status_type_id = asg.assignment_status_type_id

AND     ast.per_system_status IN ('ACTIVE_ASSIGN','SUSP_ASSIGN')
and per.person_id = res.source_id);




DBMS_STATS.gather_table_stats('BIM','bim_i_resource', estimate_percent => 5,
                                  degree => 8, granularity => 'GLOBAL', cascade =>TRUE);

 bis_collection_utilities.log('End  Initial Load of Resource_ids');

commit;

*/


/************--End--********To get Resource ids of Active Employees***************************/



     bis_collection_utilities.log('Successful Completion of Source Codes Population Program');


EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_msg_PUB.Count_And_Get (
          --  p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

    ams_utility_pvt.write_conc_log('BIM_I_SRC_CODE_PKG:FIRST_LOAD:IN EXPECTED EXCEPTION '||sqlerrm(sqlcode));

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     -- Standard call to get message count and if count=1, get the message
     FND_msg_PUB.Count_And_Get (
            --p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

    ams_utility_pvt.write_conc_log('BIM_I_SRC_CODE_PKG:FIRST_LOAD:IN UNEXPECTED EXCEPTION '||sqlerrm(sqlcode));

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

    ams_utility_pvt.write_conc_log('BIM_I_SRC_CODE_PKG:FIRST_LOAD:IN OTHERS EXCEPTION '||sqlerrm(sqlcode));


END FIRST_LOAD;

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
    l_user_id                     NUMBER := FND_GLOBAL.USER_ID();
    l_api_version_number   	  CONSTANT NUMBER       := 1.0;
    l_api_name             	  CONSTANT VARCHAR2(30) := 'INCREMENTAL_LOAD';
    l_table_name		  VARCHAR2(100);


   TYPE  generic_number_table IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

   TYPE  generic_char_table IS TABLE OF VARCHAR2(100) INDEX BY BINARY_INTEGER;

   i			NUMBER;
   l_min_start_date     DATE;

   l_org_id 			number;

   CURSOR   get_org_id IS
   SELECT   (TO_NUMBER(SUBSTRB(USERENV('CLIENT_INFO'), 1, 10)))
   FROM     dual;


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
   IF FND_API.to_Boolean( p_init_msg_list )
   THEN
      FND_msg_PUB.initialize;
   END IF;

   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;


   DELETE FROM bim_i_source_codes WHERE trunc(obj_last_update_date) = p_start_date;


      l_table_name := 'BIM_I_SOURCE_CODES';
      bis_collection_utilities.log('Running Incremental Load of Source Codes');

 MERGE INTO bim_i_source_codes facts
 USING  (
     SELECT
        sysdate    creation_date
        ,sysdate   last_update_date
        ,-1        created_by
        ,-1        last_updated_by
        ,-1        last_update_login,
	inner.source_code_id source_code_id,
	inner.parent_source_code_id parent_source_code_id,
	inner.source_code source_code,
	inner.rollup_type rollup_type,
	inner.object_id object_id,
	inner.object_type object_type,
	inner.object_status object_status,
	inner.object_purpose object_purpose,
	inner.object_country object_country,
	inner.object_region object_region,
	inner.business_unit_id business_unit_id,
	inner.owner_user_id owner_user_id,
	trunc(inner.start_date) start_date,
	trunc(inner.end_date) end_date,
	inner.child_object_id child_object_id,
	inner.child_object_type child_object_type,
	inner.child_object_status child_object_status,
	inner.child_object_purpose child_object_purpose,
	inner.child_object_country child_object_country,
	inner.child_object_region child_object_region,
	inner.child_object_usage child_object_usage,
	inner.activity_id activity_id,
	inner.activity_type activity_type,
	trunc(inner.adj_start_date) adj_start_date,
	trunc(inner.adj_end_date) adj_end_date,
        inner.obj_last_update_date obj_last_update_date
      FROM
	(
      SELECT
	a.source_code_id           source_code_id,
	b.parent_campaign_id*(-1)  parent_source_code_id,
	a.source_code              source_code,
	'CAMP'                     rollup_type,
	b.campaign_id              object_id,
	--b.rollup_type              object_type,
	a.arc_source_code_for      object_type,
	b.status_code              object_status,
	b.campaign_type            object_purpose,
	d.country_code             object_country,
	t.parent_territory_code    object_region,
	b.business_unit_id         business_unit_id,
	b.owner_user_id            owner_user_id,
	b.actual_exec_start_date   start_date,
	b.actual_exec_end_date     end_date,
	0                          child_object_id,
	--b.rollup_type              child_object_type,
	a.arc_source_code_for      child_object_type,
	''                         child_object_status,
	''                         child_object_purpose,
	''                         child_object_country,
	''                         child_object_region,
	''                         child_object_usage,
	0                          activity_id,
	''                         activity_type,
	case
	when b.actual_exec_end_date < g_start_date then null
	else greatest(b.actual_exec_start_date,g_start_date) end adj_start_date,
	case
	when b.actual_exec_end_date < g_start_date then null
	else b.actual_exec_end_date end adj_end_date,
        b.last_update_date         obj_last_update_date
      FROM
	ams_source_codes a,
	ams_campaigns_all_b b,
	jtf_loc_hierarchies_b d,
	bis_territory_hierarchies t
      WHERE
       ((b.last_update_date between p_start_date and p_end_date and b.actual_exec_start_date <= p_start_date) or ( b.actual_exec_start_date between p_start_date and p_end_date))
	AND a.source_code = b.source_code
        AND a.source_code_for_id = b.campaign_id
	AND b.city_id = d.location_hierarchy_id
        AND t.parent_territory_type(+) = 'AREA'
        AND t.child_territory_type(+) = 'COUNTRY'
        AND t.child_territory_code(+) = d.country_code
	AND a.arc_source_code_for = 'CAMP'
	AND b.rollup_type not in ('RCAM')
	AND b.status_code IN ('COMPLETED', 'CANCELLED', 'CLOSED', 'ACTIVE', 'ON_HOLD')
      ----------------------------------------------+
      UNION ALL
      ----------------------------------------------+
      SELECT
	a.source_code_id           source_code_id,
	s.source_code_id           parent_source_code_id,
	a.source_code              source_code,
	'CSCH'                     rollup_type,
	b.campaign_id              object_id,
	--b.rollup_type              object_type,
	'CAMP'                     object_type,
	b.status_code              object_status,
	b.campaign_type            object_purpose,
	d.country_code             object_country,
	t.parent_territory_code    object_region,
	b.business_unit_id         business_unit_id,
	c.owner_user_id            owner_user_id,
	c.start_date_time          start_date,
	TO_DATE(DECODE(c.end_date_time,null,
		       DECODE(c.start_date_time,null,null,b.actual_exec_end_date),
		       c.end_date_time),'DD/MM/RRRR') end_date,
	c.schedule_id              child_object_id,
	a.arc_source_code_for      child_object_type,
	c.status_code              child_object_status,
	c.purpose	           child_object_purpose,
	d2.country_code            child_object_country,
	d2.area2_code              child_object_region,
	c.usage                    child_object_usage,
	c.activity_id              activity_id,
	c.activity_type_code       activity_type,
	case
	when nvl(c.end_date_time,b.actual_exec_end_date) < g_start_date then null
	else greatest(c.start_date_time,g_start_date) end adj_start_date,
	case
	when nvl(c.end_date_time,b.actual_exec_end_date) < g_start_date then null
	else
	TO_DATE(DECODE(c.end_date_time,null,
		       DECODE(c.start_date_time,null,null,b.actual_exec_end_date),
		       c.end_date_time),'DD/MM/RRRR') end adj_end_date,
        c.last_update_date         obj_last_update_date
      FROM
	ams_source_codes a,
	ams_campaigns_all_b b,
	ams_campaign_schedules_b c,
	jtf_loc_hierarchies_b d,
	jtf_loc_hierarchies_b d2,
	bis_territory_hierarchies t,
	ams_source_codes s
      WHERE
       ((c.last_update_date between p_start_date and p_end_date and c.start_date_time <= p_start_date) or (c.start_date_time between p_start_date and p_end_date))
	AND a.source_code = c.source_code
        AND a.source_code_for_id = c.schedule_id
	AND a.arc_source_code_for = 'CSCH'
	AND b.rollup_type not in ('RCAM')
	AND b.campaign_id = c.campaign_id
	AND b.city_id = d.location_hierarchy_id
	AND c.country_id = d2.location_hierarchy_id
        AND t.parent_territory_type(+) = 'AREA'
        AND t.child_territory_type(+) = 'COUNTRY'
        AND t.child_territory_code(+) = d.country_code
	AND b.status_code IN ('COMPLETED', 'CANCELLED', 'CLOSED', 'ACTIVE', 'ON_HOLD')
	AND c.status_code IN ('COMPLETED', 'CANCELLED', 'CLOSED', 'ACTIVE', 'ON_HOLD')
	AND s.source_code_for_id = b.campaign_id
	AND s.arc_source_code_for = 'CAMP'
	AND a.active_flag = 'Y'  -- do we need this condition ?
	AND s.active_flag = 'Y' -- do we need this condition ?
      ----------------------------------------------+
      UNION ALL
      ----------------------------------------------+
      SELECT
	a.source_code_id           source_code_id,
	b.program_id*(-1)          parent_source_code_id,
	a.source_code              source_code,
	'EVEH'                     rollup_type,
	b.event_header_id          object_id,
	a.arc_source_code_for      object_type,
	b.system_status_code       object_status,
	b.event_purpose_code       object_purpose_2,
	d.country_code             object_country,
	t.parent_territory_code    object_region,
	b.business_unit_id         business_unit_id,
	b.owner_user_id            owner_user_id,
	b.active_from_date         start_date,
	b.active_to_date           end_date,
	0                          child_object_id,
	a.arc_source_code_for      child_object_type,
	''                         child_object_status,
	''                         child_object_purpose,
	''                         child_object_country,
	''                         child_object_region,
	''                         child_object_usage,
	0                          activity_id,
	''                         activity_type,
	case
	when b.active_to_date < g_start_date then null
	else greatest(b.active_from_date,g_start_date) end adj_start_date,
	case
	when b.active_to_date < g_start_date then null
	else b.active_to_date end adj_end_date,
        b.last_update_date         obj_last_update_date
      FROM
	ams_source_codes a,
	ams_event_headers_all_b b,
	jtf_loc_hierarchies_b d,
	bis_territory_hierarchies t
      WHERE
        ((b.last_update_date between p_start_date and p_end_date and b.active_from_date  <= p_start_date) or (b.active_from_date  between p_start_date and p_end_date))
	AND a.source_code = b.source_code
        AND a.source_code_for_id = b.event_header_id
	AND b.country_code = d.location_hierarchy_id
        AND t.parent_territory_type(+) = 'AREA'
        AND t.child_territory_type(+) = 'COUNTRY'
        AND t.child_territory_code(+) = d.country_code
	AND a.arc_source_code_for = 'EVEH'
	AND b.system_status_code IN ('COMPLETED', 'CANCELLED', 'CLOSED', 'ACTIVE', 'ON_HOLD')
      ----------------------------------------------+
      UNION ALL
      ----------------------------------------------+
      SELECT
	a.source_code_id           source_code_id,
	s.source_code_id           parent_source_code_id,
	a.source_code              source_code,
	'EVEO'                     rollup_type,
	b.event_header_id          object_id,
	'EVEH'                     object_type,
	b.system_status_code       object_status,
	b.event_purpose_code       object_purpose_2,
	d.country_code             object_country,
	t.parent_territory_code    object_region,
	b.business_unit_id         business_unit_id,
	c.owner_user_id            owner_user_id,
	c.event_start_date         start_date,
	TO_DATE(DECODE(c.event_end_date,null,
		       DECODE(c.event_start_date,null,null,b.active_to_date),
		       c.event_end_date),'DD/MM/RRRR') end_date,
	c.event_offer_id           child_object_id,
	a.arc_source_code_for      child_object_type,
	c.system_status_code       child_object_status,
	c.event_purpose_code       child_object_purpose_2,
	d2.country_code            child_object_country,
	d2.area2_code              child_object_region,
	''                         child_object_usage,
	0                          activity_id,
	''                         activity_type,
	case
	when nvl(c.event_end_date,b.active_to_date) < g_start_date then null
        else greatest(c.event_start_date,g_start_date) end adj_start_date,
        case
        when nvl(c.event_end_date,b.active_to_date) < g_start_date then null
        else
        TO_DATE(DECODE(c.event_end_date,null,
		       DECODE(c.event_start_date,null,null,b.active_to_date),
		       c.event_end_date),'DD/MM/RRRR') end adj_end_date,
        c.last_update_date         obj_last_update_date
      FROM
	ams_source_codes a,
	ams_event_headers_all_b b,
	ams_event_offers_all_b c,
	jtf_loc_hierarchies_b d,
	jtf_loc_hierarchies_b d2,
	bis_territory_hierarchies t,
	ams_source_codes s
      WHERE
        ((c.last_update_date between p_start_date and p_end_date and c.event_start_date  <= p_start_date) OR (c.event_start_date between p_start_date and p_end_date))
	AND a.source_code = c.source_code
        AND a.source_code_for_id = c.event_offer_id
	AND a.arc_source_code_for= 'EVEO'
	AND b.event_header_id = c.event_header_id
	AND b.country_code = d.location_hierarchy_id
	AND c.country_code = d2.location_hierarchy_id
        AND t.parent_territory_type(+) = 'AREA'
        AND t.child_territory_type(+) = 'COUNTRY'
        AND t.child_territory_code(+) = d.country_code
	AND b.system_status_code IN ('COMPLETED', 'CANCELLED', 'CLOSED', 'ACTIVE', 'ON_HOLD')
	AND c.system_status_code IN ('COMPLETED', 'CANCELLED', 'CLOSED', 'ACTIVE', 'ON_HOLD')
	AND s.source_code_for_id = b.event_header_id
	AND s.arc_source_code_for = 'EVEH'
	AND a.active_flag = 'Y'  -- do we need this condition ?
	AND s.active_flag = 'Y' -- do we need this condition ?
      ----------------------------------------------+
      UNION ALL
      SELECT
        a.source_code_id           source_code_id,
	c.parent_id*(-1)           parent_source_code_id,
        a.source_code              source_code,
	'EONE'                     rollup_type,
        c.event_offer_id           object_id,
        'EONE'                     object_type,
        c.system_status_code       object_status,
        c.event_purpose_code       object_purpose_2,
        d.country_code             object_country,
	t.parent_territory_code    object_region,
        c.business_unit_id         business_unit_id,
        c.owner_user_id            owner_user_id,
        c.event_start_date         start_date,
        c.event_end_date           end_date,
        0                          child_object_id,
        ''                         child_object_type,
        ''                         child_object_status,
        ''                         child_object_purpose_2,
        ''                         child_object_country,
        ''                         child_object_region,
        ''                         child_object_usage,
        0                          activity_id,
        ''                         activity_type,
        case
	when c.event_end_date < g_start_date then null
	else greatest(c.event_start_date,g_start_date) end adj_start_date,
	case
	when c.event_end_date < g_start_date then null
	else c.event_end_date end adj_end_date,
        c.last_update_date         obj_last_update_date
      FROM  ams_source_codes a,
	    ams_event_offers_all_b c,
	    jtf_loc_hierarchies_b d,
	    bis_territory_hierarchies t
       WHERE
      ((c.last_update_date between p_start_date and p_end_date and c.event_start_date  <= p_start_date) or (c.event_start_date between p_start_date and p_end_date))
       AND     a.source_code = c.source_code
       AND     a.source_code_for_id = c.event_offer_id
       AND     a.arc_source_code_for ='EONE'
       AND     nvl(c.parent_type,'N') <> 'CAMP'
       AND     c.country_code = d.location_hierarchy_id
       AND     t.parent_territory_type(+) = 'AREA'
       AND     t.child_territory_type(+) = 'COUNTRY'
       AND     t.child_territory_code(+) = d.country_code
       AND     c.system_status_code IN ('COMPLETED', 'CANCELLED', 'CLOSED', 'ACTIVE', 'ON_HOLD')
      ----------------------------------------------
      UNION ALL
      ----------------------------------------------
      SELECT
	b.campaign_id*(-1)              source_code_id,
	b.parent_campaign_id*(-1)           parent_source_code_id,
	b.source_code              source_code,
	'CAMP'                     rollup_type,
	b.campaign_id              object_id,
	b.rollup_type              object_type,
	b.status_code              object_status,
	b.campaign_type            object_purpose,
	d.country_code             object_country,
	t.parent_territory_code    object_region,
	b.business_unit_id         business_unit_id,
	b.owner_user_id            owner_user_id,
	b.actual_exec_start_date   start_date,
	b.actual_exec_end_date     end_date,
	0                          child_object_id,
	b.rollup_type              child_object_type,
	''                         child_object_status,
	''                         child_object_purpose,
	''                         child_object_country,
	''                         child_object_region,
	''                         child_object_usage,
	0                          activity_id,
	''                         activity_type,
	case
	when b.actual_exec_end_date < g_start_date then null
	else greatest(b.actual_exec_start_date,g_start_date) end adj_start_date,
	case
	when b.actual_exec_end_date < g_start_date then null
	else b.actual_exec_end_date end adj_end_date,
        b.last_update_date         obj_last_update_date
      FROM
	ams_campaigns_all_b b,
	jtf_loc_hierarchies_b d,
	bis_territory_hierarchies t
      WHERE
      ((b.last_update_date between p_start_date and p_end_date and b.actual_exec_start_date  <= p_start_date) or (b.actual_exec_start_date between p_start_date and p_end_date))
	AND b.city_id = d.location_hierarchy_id
        AND t.parent_territory_type(+) = 'AREA'
        AND t.child_territory_type(+) = 'COUNTRY'
        AND t.child_territory_code(+) = d.country_code
	AND b.rollup_type = 'RCAM'
	AND b.status_code IN ('COMPLETED', 'CANCELLED', 'CLOSED', 'ACTIVE', 'ON_HOLD')
      ----------------------------------------------+
      ) inner
) changes
	  ON (
	     facts.source_code_id = changes.source_code_id
         )
	  WHEN MATCHED THEN UPDATE  SET
	     facts.parent_source_code_id = changes.parent_source_code_id
	     ,facts.rollup_type = changes.rollup_type
	     ,facts.object_id = changes.object_id
	    ,facts.object_type = changes.object_type
	    ,facts.object_status = changes.object_status
	    ,facts.object_purpose = changes.object_purpose
            ,facts.object_country = changes.object_country
            ,facts.object_region = changes.object_region
            ,facts.business_unit_id = changes.business_unit_id
            ,facts.owner_user_id = changes.owner_user_id
            ,facts.start_date = changes.start_date
            ,facts.end_date = changes.end_date
            ,facts.child_object_id = changes.child_object_id
            ,facts.child_object_type = changes.child_object_type
	    ,facts.child_object_status = changes.child_object_status
	    ,facts.child_object_purpose = changes.child_object_purpose
	    ,facts.child_object_country = changes.child_object_country
            ,facts.child_object_region = changes.child_object_region
            ,facts.child_object_usage = changes.child_object_usage
            ,facts.activity_id = changes.activity_id
            ,facts.activity_type = changes.activity_type
            --,facts.adj_start_date = greatest(changes.start_date,g_start_date)
            --,facts.adj_end_date = greatest(changes.end_date,g_start_date)
	    ,facts.adj_start_date = changes.adj_start_date
            ,facts.adj_end_date = changes.adj_end_date
            ,facts.obj_last_update_date = changes.obj_last_update_date
            ,facts.last_update_date = changes.last_update_date
	   WHEN NOT MATCHED THEN INSERT
		(
	       facts.creation_date
           ,facts.last_update_date
           ,facts.created_by
           ,facts.last_updated_by
           ,facts.last_update_login
           ,facts.source_code_id
	   ,facts.parent_source_code_id
           ,facts.source_code
	   ,facts.rollup_type
 	   ,facts.object_id
	   ,facts.object_type
	   ,facts.object_status
	   ,facts.object_purpose
           ,facts.object_country
           ,facts.object_region
           ,facts.business_unit_id
           ,facts.owner_user_id
           ,facts.start_date
           ,facts.end_date
           ,facts.child_object_id
           ,facts.child_object_type
	   ,facts.child_object_status
	   ,facts.child_object_purpose
	   ,facts.child_object_country
           ,facts.child_object_region
           ,facts.child_object_usage
           ,facts.activity_id
           ,facts.activity_type
           ,facts.adj_start_date
           ,facts.adj_end_date
           ,facts.obj_last_update_date
		 )
	   VALUES
		 (
	    changes.creation_date
           ,changes.last_update_date
           ,changes.created_by
           ,changes.last_updated_by
           ,changes.last_update_login
           ,changes.source_code_id
	   ,changes.parent_source_code_id
           ,changes.source_code
	   ,changes.rollup_type
 	   ,changes.object_id
	   ,changes.object_type
	   ,changes.object_status
	   ,changes.object_purpose
           ,changes.object_country
           ,changes.object_region
           ,changes.business_unit_id
           ,changes.owner_user_id
           ,changes.start_date
           ,changes.end_date
           ,changes.child_object_id
           ,changes.child_object_type
	   ,changes.child_object_status
	   ,changes.child_object_purpose
	   ,changes.child_object_country
           ,changes.child_object_region
           ,changes.child_object_usage
           ,changes.activity_id
           ,changes.activity_type
           --,greatest(changes.start_date,g_start_date)
          -- ,greatest(changes.end_date,g_start_date)
	    ,changes.adj_start_date
           ,changes.adj_end_date
           ,changes.obj_last_update_date
);

     COMMIT;

--handle categories belong to Reporting category set

     UPDATE BIM_I_SOURCE_CODES code
        SET code.category_id
                 = (SELECT nvl(prod.category_id,-1) category_id
                      FROM
                        ams_act_products prod
                      WHERE
                          prod.act_product_used_by_id = object_id
                      AND prod.arc_act_product_used_by = object_type
                      AND prod.primary_product_flag = 'Y'
                      AND (prod.last_update_date between p_start_date and p_end_date
                           OR code.obj_last_update_date between p_start_date and p_end_date)
                   )
     WHERE ((code.child_object_id = 0)
            OR
            (NOT EXISTS (
             SELECT 1
             FROM ams_act_products prod
             WHERE prod.act_product_used_by_id = code.child_object_id
             AND prod.arc_act_product_used_by = code.child_object_type
             AND prod.primary_product_flag = 'Y'
             ))
             )
     AND
           EXISTS (SELECT 1
                      FROM
                        ams_act_products prod
                      WHERE
                          prod.act_product_used_by_id = object_id
                      AND prod.arc_act_product_used_by = object_type
                      AND prod.primary_product_flag = 'Y'
                      AND (prod.last_update_date between p_start_date and p_end_date
                           OR code.obj_last_update_date between p_start_date and p_end_date)
                   );

     UPDATE BIM_I_SOURCE_CODES code
        SET code.category_id
                 = (SELECT nvl(prod.category_id,-1) category_id
                      FROM
                        ams_act_products prod
                      WHERE
                          prod.act_product_used_by_id = child_object_id
                      AND prod.arc_act_product_used_by = child_object_type
                      AND prod.primary_product_flag = 'Y'
                      AND (prod.last_update_date between p_start_date and p_end_date
                           OR code.obj_last_update_date between p_start_date and p_end_date)
                   )
     WHERE
           EXISTS (SELECT 1
                      FROM
                        ams_act_products prod
                      WHERE
                          prod.act_product_used_by_id = child_object_id
                      AND prod.arc_act_product_used_by = child_object_type
                      AND prod.primary_product_flag = 'Y'
                      AND (prod.last_update_date between p_start_date and p_end_date
                           OR code.obj_last_update_date between p_start_date and p_end_date)
                   );

	UPDATE BIM_I_SOURCE_CODES code
		SET code.category_id = -1
	WHERE NOT EXISTS (select 1
			      FROM
				ams_act_products prod
			      WHERE
				  act_product_used_by_id = code.object_id
			       AND prod.arc_act_product_used_by in ('CAMP','EVEH','EONE')
			   )
	AND ( (child_object_id = 0)
	    OR
	    (NOT EXISTS (select 1
			      FROM
				ams_act_products prod
			      WHERE
				  act_product_used_by_id = code.child_object_id
			       AND prod.arc_act_product_used_by in ('CSCH', 'EVEO')
			       ))
	     )
	AND code.category_id <> -1;


       COMMIT;



     bis_collection_utilities.wrapup(p_status => TRUE
                        ,p_count => sql%rowcount
                        ,p_period_from => p_start_date
                        ,p_period_to  => sysdate
                        );

     /***************************************************************/


     bis_collection_utilities.log('Before Analyze of the table BIM_I_SOURCE_CODES');

   --Analyze the facts table
     DBMS_STATS.gather_table_stats('BIM','BIM_I_SOURCE_CODES', estimate_percent => 5,
                                  degree => 8, granularity => 'GLOBAL', cascade =>TRUE);

    /************--Start--********To get Resource ids of Active Employees***************************/

/*
 bis_collection_utilities.log('Start of  INCREMENTAL Load of Resource_ids');

execute immediate 'truncate table bim_i_resource_stg';

 insert into bim.bim_i_resource_stg
   (resource_id)
   select res.resource_id from jtf_Rs_resource_extns res, fnd_user fn
where fn.user_id = res.user_id and
nvl(fn.end_date,sysdate+1) > sysdate and
nvl(res.end_date_active,sysdate+1)>sysdate and
category = 'EMPLOYEE'
and exists (
SELECT  1
FROM    per_all_people_f            per
,       per_all_assignments_f       asg
,       per_assignment_status_types ast
WHERE   asg.person_id = per.person_id
AND     asg.assignment_status_type_id = ast.assignment_status_type_id
AND     asg.assignment_type = 'E'  -- give me only employee assignments
AND     asg.primary_flag = 'Y'     -- give me only primary assignments
AND     TRUNC(SYSDATE) BETWEEN per.effective_start_date AND per.effective_end_date
AND     TRUNC(SYSDATE) BETWEEN asg.effective_start_date AND asg.effective_end_date
AND     ast.assignment_status_type_id = asg.assignment_status_type_id

AND     ast.per_system_status IN ('ACTIVE_ASSIGN','SUSP_ASSIGN')
and per.person_id = res.source_id);


insert into bim.bim_i_resource
 (resource_id)
 select resource_id  from bim.bim_i_resource_stg a
 where not exists
 (select 'Y' from bim.bim_i_resource b
 where a.resource_id=b.resource_id);



  delete from  bim.bim_i_resource
 where resource_id in (
 select resource_id  from bim.bim_i_resource a
 where not exists
 (select 'Y' from bim.bim_i_resource_stg b
 where a.resource_id=b.resource_id));

commit;




DBMS_STATS.gather_table_stats('BIM','bim_i_resource', estimate_percent => 5,
                                  degree => 8, granularity => 'GLOBAL', cascade =>TRUE);

 bis_collection_utilities.log('End  Initial Load of Resource_ids');

commit;

*/

/************--End--********To get Resource ids of Active Employees***************************/

     bis_collection_utilities.log('Successful Completion of Source Codes Population Program');


EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_msg_PUB.Count_And_Get (
          --  p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

    ams_utility_pvt.write_conc_log('BIM_I_SRC_CODE_PKG:INCREMENTAL_LOAD:IN EXPECTED EXCEPTION '||sqlerrm(sqlcode));

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     -- Standard call to get message count and if count=1, get the message
     FND_msg_PUB.Count_And_Get (
            --p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

    ams_utility_pvt.write_conc_log('BIM_I_SRC_CODE_PKG:INCREMENTAL_LOAD:IN UNEXPECTED EXCEPTION '||sqlerrm(sqlcode));

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

    ams_utility_pvt.write_conc_log('BIM_I_SRC_CODE_PKG:INCREMENTAL_LOAD:IN OTHERS EXCEPTION '||sqlerrm(sqlcode));


END INCREMENTAL_LOAD;


END BIM_I_SRC_CODE_PKG;


/
