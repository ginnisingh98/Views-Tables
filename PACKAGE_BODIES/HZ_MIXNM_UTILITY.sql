--------------------------------------------------------
--  DDL for Package Body HZ_MIXNM_UTILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_MIXNM_UTILITY" AS
/*$Header: ARHXUTLB.pls 120.24.12010000.3 2010/03/02 06:22:42 rgokavar ship $ */

--------------------------------------------------------------------------
-- declaration of private types
--------------------------------------------------------------------------
--Bug9043912
--INDEXVARCHAR400List Type changed from VARCHAR2(400) to VARCHAR2(2500)
--Didn't change the name to avoid code changes at multiple places.
TYPE INDEXVARCHAR400List IS TABLE OF VARCHAR2(2500) INDEX BY BINARY_INTEGER;
TYPE INDEXIDList IS TABLE OF NUMBER(15) INDEX BY BINARY_INTEGER;

--------------------------------------------------------------------------
-- declaration of private global varibles
--------------------------------------------------------------------------

-- for debug purpose
g_debug_count                       NUMBER := 0;
--g_debug                             BOOLEAN := FALSE;

-- default value of content source type
G_MISS_CONTENT_SOURCE_TYPE          CONSTANT VARCHAR2(30) := 'USER_ENTERED';
G_MISS_ACTUAL_CONTENT_SOURCE        CONSTANT VARCHAR2(30) := 'SST';

-- entity id for person and organization profiles
G_PERSON_PROFILE_ID                 CONSTANT NUMBER := -1;
G_ORGANIZATION_PROFILE_ID           CONSTANT NUMBER := -2;

-- schema name
G_AR_SCHEMA_NAME                    VARCHAR2(30);
G_APPS_SCHEMA_NAME                  VARCHAR2(30);

-- flag to indicate if perticular setup has been loaded into memory
-- G_ORG_SETUP_LAST_UPDATE_DATE        DATE;
-- G_PER_SETUP_LAST_UPDATE_DATE        DATE;
-- G_DATASOURCE_LAST_UPDATE_DATE       DATE;
G_ORG_SETUP_LOADED                  VARCHAR2(1) := 'N';
G_PER_SETUP_LOADED                  VARCHAR2(1) := 'N';
G_DATASOURCE_LOADED                 VARCHAR2(1) := 'N';

-- cached party id
--G_PARTY_ID                          NUMBER;

-- cached overwrite third party rule id
G_OVERWRITE_THIRD_PARTY_RULE        NUMBER;

-- cache user creation rule id
G_CREATE_USER_ENTERED_RULE          NUMBER;

-- attribute name and id list for party profiles
G_ORG_ATTRIBUTE_NAME                INDEXVARCHAR30List;
G_ORG_ATTRIBUTE_ID                  INDEXIDList;
G_PER_ATTRIBUTE_NAME                INDEXVARCHAR30List;
G_PER_ATTRIBUTE_ID                  INDEXIDList;

-- attribute available data sources
G_ATTRIBUTE_DATA_SOURCE             INDEXVARCHAR400List;

-- real data source
G_REAL_DATA_SOURCE                  INDEXVARCHAR30List;

-- exception ist
G_EXCEPTION_TYPE                    INDEXVARCHAR30List;

-- entity name and id list
G_ENTITY_NAME                       INDEXVARCHAR30List;
G_ENTITY_ID                         INDEXIDList;

-- entity available data source
G_ENTITY_DATA_SOURCE                INDEXVARCHAR400List;

-- overwrite third party rule setup
G_OVERWRITE_THIRD_PARTY             INDEXVARCHAR400List;

-- overwrite user rule setup
G_OVERWRITE_USER_RULE               INDEXVARCHAR400List;

-- user creation rule setup
G_CREATE_USER_ENTERED               INDEXVARCHAR1List;

-- a list to cache if mix-n-match is enabled
G_MIXNM_ENABLED_FLAG                INDEXVARCHAR1List;

-- SSM SST Integration and Extension
-- List of valid Content Sources.
G_ORIG_SYSTEM_LIST                  INDEXVARCHAR30List;
G_ORIG_SYSTEM_LIST_LOADED           VARCHAR2(1) := 'N';

-- Overwrite third party data by user(for other entities)
G_OTHER_ENT_USER_OVERWRITE          INDEXVARCHAR400List;

--------------------------------------------------------------------------
-- declaration of private procedures and functions
--------------------------------------------------------------------------

FUNCTION get_max (
    p_value1                        IN     NUMBER,
    p_value2                        IN     NUMBER,
    p_value3                        IN     NUMBER := NULL,
    p_value4                        IN     NUMBER := NULL,
    p_value5                        IN     NUMBER := NULL
) RETURN NUMBER;

PROCEDURE cacheSetupForPartyProfiles (
    p_party_id                      IN     NUMBER := NULL,
    p_entity_name                   IN     VARCHAR2 := NULL
);

PROCEDURE cacheSetupForOtherEntities (
    p_load_rule                     IN     BOOLEAN := FALSE
);

FUNCTION isThirdPartyDataOverwriteable (
    p_entity_attr_id                IN     NUMBER,
    p_orig_system                   IN     VARCHAR2
) RETURN VARCHAR2;

FUNCTION isUserDataOverwriteable (
    p_entity_attr_id                IN     NUMBER,
    p_orig_system                   IN     VARCHAR2
) RETURN VARCHAR2;

FUNCTION getDataSourceRanking (
    p_entity_attr_id                IN     NUMBER,
    p_data_source_type              IN     VARCHAR2
) RETURN NUMBER;

FUNCTION getIndex (
    p_list                          IN     INDEXVARCHAR30List,
    p_name                          IN     VARCHAR2
) RETURN NUMBER;

FUNCTION getEntityAttrId (
    p_entity_name                   IN     VARCHAR2,
    p_attribute_name                IN     VARCHAR2 := NULL
) RETURN NUMBER;

FUNCTION isSSTColumnUpdatable (
    p_party_id                      IN     NUMBER,
    p_entity_name                   IN     VARCHAR2,
    p_attribute_name                IN     VARCHAR2,
    p_entity_attr_id                IN     NUMBER,
    p_value_is_null                 IN     VARCHAR2,
    p_data_source_type              IN     VARCHAR2,
    x_exception_type                OUT    NOCOPY VARCHAR2,
    p_is_null			    IN     VARCHAR2
) RETURN VARCHAR2;

FUNCTION isSSTColumnUpdatable (
    p_party_id                      IN     NUMBER,
    p_entity_attr_id                IN     NUMBER,
    p_real_data_source_type         IN     VARCHAR2,
    p_real_data_source_ranking      IN     NUMBER,
    p_new_data_source_type          IN     VARCHAR2,
    p_new_data_source_ranking       IN     NUMBER,
    p_exception_type                IN OUT NOCOPY VARCHAR2
) RETURN VARCHAR2;

PROCEDURE areSSTColumnsUpdeable (
    p_party_id                      IN     NUMBER,
    p_entity_name                   IN     VARCHAR2,
    p_attribute_name_list           IN     INDEXVARCHAR30List,
    p_value_is_null_list            IN     INDEXVARCHAR1List,
    p_data_source_type              IN     VARCHAR2 := G_MISS_ACTUAL_CONTENT_SOURCE,
    x_updatable_flag_list           OUT    NOCOPY INDEXVARCHAR1List,
    x_exception_type_list           OUT    NOCOPY INDEXVARCHAR30List,
    x_return_status                 IN OUT NOCOPY VARCHAR2,
    p_raise_error_flag              IN     VARCHAR2 DEFAULT 'N',
    p_known_dict_id                 IN     VARCHAR2 DEFAULT 'N',
    p_new_value_is_null_list        IN     HZ_MIXNM_UTILITY.INDEXVARCHAR1List
);

PROCEDURE updateExceptions (
    p_create_update_sst_flag        IN     VARCHAR2,
    p_party_id                      IN     NUMBER,
    p_data_source_type              IN     VARCHAR2,
    p_name_list                     IN     INDEXVARCHAR30List,
    p_updatable_flag_list           IN     INDEXVARCHAR1List,
    p_exception_type_list           IN     INDEXVARCHAR30List,
    p_sst_value_is_not_null_list    IN     INDEXVARCHAR1List,
    p_data_source_list              IN     INDEXVARCHAR30List
);

PROCEDURE generate_mixnm_dynm_pkg  ;
--------------------------------------------------------------------------
-- debug procedures
--------------------------------------------------------------------------

/**
 * PRIVATE PROCEDURE enable_debug
 *
 * DESCRIPTION
 *     Turn on debug mode.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *     HZ_UTILITY_V2PUB.enable_debug
 *
 * MODIFICATION HISTORY
 *
 *   07-23-2001    Jianying Huang   o Created.
 *
 */

/*PROCEDURE enable_debug IS
BEGIN
    g_debug_count := g_debug_count + 1;

    IF g_debug_count = 1 THEN
      IF fnd_profile.value('HZ_API_FILE_DEBUG_ON') = 'Y' OR
         fnd_profile.value('HZ_API_DBMS_DEBUG_ON') = 'Y'
      THEN
        hz_utility_v2pub.enable_debug;
        g_debug := TRUE;
      END IF;
    END IF;
END enable_debug;
*/

/**
 * PRIVATE PROCEDURE disable_debug
 *
 * DESCRIPTION
 *     Turn off debug mode.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *     hz_utility_v2pub.disable_debug
 *
 * MODIFICATION HISTORY
 *
 *   07-23-2001    Jianying Huang   o Created.
 *
 */

/*PROCEDURE disable_debug IS
BEGIN
    g_debug_count := g_debug_count - 1;

    IF g_debug THEN
      IF g_debug_count = 0 THEN
        hz_utility_v2pub.disable_debug;
        g_debug := FALSE;
      END IF;
    END IF;
END disable_debug;
*/

--------------------------------------------------------------------------
-- private procedures and functions
--------------------------------------------------------------------------

/**
 * PRIVATE FUNCTION get_max
 *
 * DESCRIPTION
 *     Return max value.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * IN:
 *   p_value1                       Value 1.
 *   p_value2                       Value 2.
 *   p_value3                       Value 3.
 *   p_value4                       Value 4.
 *   p_value5                       Value 5.
 *
 * MODIFICATION HISTORY
 *
 *   06-23-2002    Jianying Huang   o Created.
 *
 */

FUNCTION get_max (
    p_value1                        IN     NUMBER,
    p_value2                        IN     NUMBER,
    p_value3                        IN     NUMBER := NULL,
    p_value4                        IN     NUMBER := NULL,
    p_value5                        IN     NUMBER := NULL
) RETURN NUMBER IS

    l_max                           NUMBER := 0;

BEGIN

    IF p_value1 IS NOT NULL AND p_value1 > l_max THEN l_max := p_value1; END IF;
    IF p_value2 IS NOT NULL AND p_value2 > l_max THEN l_max := p_value2; END IF;
    IF p_value3 IS NOT NULL AND p_value3 > l_max THEN l_max := p_value3; END IF;
    IF p_value4 IS NOT NULL AND p_value4 > l_max THEN l_max := p_value4; END IF;
    IF p_value5 IS NOT NULL AND p_value5 > l_max THEN l_max := p_value5; END IF;

    RETURN l_max;

END get_max;

/**
 * PRIVATE PROCEDURE cacheSetupForPartyProfiles
 *
 * DESCRIPTION
 *   cache mix-n-match setup for performance reason.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * IN:
 *   p_party_id                     Party id.
 *   p_entity_name                  Entity name.
 *
 * MODIFICATION HISTORY
 *
 *   04-30-2002    Jianying Huang       o Created.
 *   12-27-2004    Rajib Ranjan Borah   o SSM SST Integration and Extension.
 *                                        Changed caching logic for G_OVERWRITE_THIRD_PARTY and
 *                                        G_OVERWRITE_USER_RULE.
 *                                      o Cached content sources in G_ORIG_SYSTEM_LIST.
 *                                      o Cursors c_overwrite_third_party_rule and
 *                                        c_overwrite_user_rule are modified as now these
 *                                        rules are orig system specific.
 *                                      o Cursors c_data_source, c_party_data_sources1,
 *                                        c_party_data_sources2 are modified as rank = -1
 *                                        is possible for selected data sources(Ranking method = date).
 *   02-28-2005    Rajib Ranjan Borah   o Bug 4156090. Changed the caching logic for
 *                                        G_ATTRIBUTE_DATA_SOURCE.
 *                                        Order by is removed from cursor c_data_source.
 */

PROCEDURE cacheSetupForPartyProfiles (
    p_party_id                      IN     NUMBER := NULL,
    p_entity_name                   IN     VARCHAR2 := NULL
) IS

/*
    -- load last update date for party profiles' setup

    CURSOR c_profile_last_update_date (
      p_entity_name                 VARCHAR2
    ) IS
      SELECT max(last_update_date) last_update_date
      FROM hz_entity_attributes
      WHERE entity_name = p_entity_name;
*/

    -- load attribute names in setup table for party profiles

    CURSOR c_entity_dict (
      p_entity_name                 VARCHAR2
    ) IS
      SELECT e.entity_attr_id, e.attribute_name
      FROM hz_entity_attributes e
      WHERE e.entity_name = p_entity_name
      ORDER BY e.attribute_name;

    -- load data source ranking in setup table for party profiles

    CURSOR c_data_source (
      p_entity_name                 VARCHAR2
    ) IS
      SELECT s.entity_attr_id,
             s.content_source_type,
	     s.ranking
      FROM hz_entity_attributes e,
           hz_select_data_sources s
      WHERE e.entity_name = p_entity_name
      AND s.entity_attr_id = e.entity_attr_id
      AND s.ranking <> 0;
-- Bug 4156090. Order by is no longer required.
--      ORDER BY s.entity_attr_id, s.ranking;

    -- check if there is a sst profile for the given org party

    CURSOR c_exist_org_sst_profile (
      p_party_id                    NUMBER
    ) IS
      SELECT 'Y'
      FROM hz_organization_profiles
      WHERE party_id = p_party_id
      AND actual_content_source = G_MISS_CONTENT_SOURCE_TYPE
      AND effective_end_date is NULL;

    -- check if there is a sst profile for the given person party

    CURSOR c_exist_per_sst_profile (
      p_party_id                    NUMBER
    ) IS
      SELECT 'Y'
      FROM hz_person_profiles
      WHERE party_id = p_party_id
      AND actual_content_source = G_MISS_CONTENT_SOURCE_TYPE
      AND effective_end_date is NULL;

    -- find out the real data source of each column for the given party

    CURSOR c_party_data_sources1 (
      p_entity_name                 VARCHAR2,
      p_party_id                    NUMBER
    ) IS
      SELECT e.entity_attr_id,
             NVL(exp.content_source_type, s1.content_source_type),
             exp.exception_type
      FROM hz_entity_attributes e,
           hz_select_data_sources s1,
           (SELECT entity_attr_id,
                   content_source_type,
                   exception_type
            FROM hz_win_source_exceps
            WHERE party_id = p_party_id ) exp
      WHERE e.entity_name = p_entity_name
      AND e.entity_attr_id = s1.entity_attr_id
      AND (s1.ranking = 1 or (s1.ranking = -1 and exp.content_source_type = s1.content_source_type))
      AND exp.entity_attr_id (+) = e.entity_attr_id;

    -- find out the real data source of each column for the given party
    -- which does not have a sst profile.

    CURSOR c_party_data_sources2 (
      p_entity_name                 VARCHAR2,
      p_party_id                    NUMBER
    ) IS
      SELECT e.entity_attr_id,
       NVL(exp.content_source_type, 'USER_ENTERED'),
       exp.exception_type
	FROM hz_entity_attributes e,
		(SELECT entity_attr_id,
    			content_source_type,
			exception_type
		FROM hz_win_source_exceps
		WHERE party_id = p_party_id ) exp
	WHERE e.entity_name = p_entity_name
	AND exp.entity_attr_id (+) = e.entity_attr_id
	and exists (select 'Y' from hz_select_data_sources s1
      		where s1.entity_attr_id = e.entity_attr_id
      		and s1.ranking <> 0);

    -- find out the attributes which can be overwrited by user
    -- when they store third party data.

    -- SSM SST Integration and Extension
    -- Now hz_user_overwrite_rules will store orig_system for overwrite_flag = 'Y'.
    -- Select orig_system instead of overwrite_flag in cursor query.
    CURSOR c_overwrite_third_party_rule (
      p_rule_id                     NUMBER
    ) IS
      SELECT   entity_attr_id,/* overwrite_flag*/
               orig_system
      FROM     hz_user_overwrite_rules
      WHERE    rule_id        = p_rule_id
        AND    overwrite_flag = 'Y'
      ORDER BY entity_attr_id;

    -- find out the attributes which can be overwrited by third
    -- party when they store user entered data.

    -- SSM SST Integration and Extension
    -- hz_thirdparty_rule will now be orig_system specific.
    -- Retrieve orig_system in the cursor.
    CURSOR c_overwrite_user_rule (
      p_party_id                    NUMBER
    ) IS
      SELECT   rule.entity_attr_id,
               rule.orig_system
      FROM     hz_thirdparty_rule rule
      WHERE    rule.overwrite_flag = 'Y'
      AND      NOT EXISTS
               (SELECT '1'
                FROM   hz_thirdparty_exceps exceps
                WHERE  exceps.party_id = p_party_id
	        AND    exceps.entity_attr_id = rule.entity_attr_id)
      ORDER BY rule.entity_attr_id;

    -- SSM SST Integration and Extension
    -- All valid content source types will be stored in PL/SQL tables for faster access.
    CURSOR c_orig_systems
    IS
        SELECT  orig_system
	FROM    hz_orig_systems_b
	WHERE   sst_flag = 'Y'
--	  AND   status = 'A'
	ORDER BY orig_system;

    i_entity_attr_id                INDEXIDList;
    i_attribute_name                INDEXVARCHAR30List;
    i_content_source_type           INDEXVARCHAR30List;
    i_exception_type                INDEXVARCHAR30List;
    i_orig_system                   INDEXVARCHAR30List;
    i_creation_flag                 INDEXVARCHAR30List;
    i_ranking			    INDEXIDList;

    l_entity_id                     NUMBER;
    l_entity_name                   VARCHAR2(30);
--  l_last_update_date              DATE;
--  l_reload                        BOOLEAN := FALSE;
    l_rule_id                       NUMBER;
    l_dummy                         VARCHAR2(1);
-- Bug 4171892
    l_str                           VARCHAR2(1000);
    l_len                           NUMBER;
    l_start                         NUMBER;
    i                               NUMBER;
    j                               NUMBER;
    l_debug_prefix                  VARCHAR2(30) := '';

BEGIN

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'cacheSetupForPartyProfiles (+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;



    -- SSM SST Integration and Extension
    -- Load table G_ORIG_SYSTEM_LIST.
    IF G_ORIG_SYSTEM_LIST_LOADED = 'N' THEN
        OPEN  c_orig_systems;
	FETCH c_orig_systems BULK COLLECT INTO
	      G_ORIG_SYSTEM_LIST;
	CLOSE c_orig_systems;
        G_ORIG_SYSTEM_LIST_LOADED := 'Y';
    END IF;

    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
        -- Log count of content_source_types
        hz_utility_v2pub.debug(
	    p_message   => 'G_ORIG_SYSTEM_LIST.COUNT = '
	                   || G_ORIG_SYSTEM_LIST.COUNT,
            p_prefix    => l_debug_prefix,
            p_msg_level => fnd_log.level_statement);

        -- Log orig_system_list.
        FOR i in 1..G_ORIG_SYSTEM_LIST.COUNT LOOP
            hz_utility_v2pub.debug(
    	        p_message   => 'G_ORIG_SYSTEM_LIST(' || i || ') = '
	                       || G_ORIG_SYSTEM_LIST(i),
                p_prefix    => l_debug_prefix,
                p_msg_level => fnd_log.level_statement);
        END LOOP;

    END IF;



    -- loading attribute dictionary

    -- Debug info.
    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_message=>'entity_name = '||p_entity_name||
                                             ', G_ORG_SETUP_LOADED = '||G_ORG_SETUP_LOADED||
                                             ', G_PER_SETUP_LOADED = '||G_PER_SETUP_LOADED,
                                  p_prefix =>l_debug_prefix,
                                  p_msg_level=>fnd_log.level_statement);
    END IF;

/*
    -- IF p_entity_name IN ('HZ_ORGANIZATION_PROFILES','HZ_PERSON_PROFILES') THEN

    OPEN c_profile_last_update_date(p_entity_name);
    FETCH c_profile_last_update_date INTO l_last_update_date;
    CLOSE c_profile_last_update_date;

    IF l_last_update_date IS NULL THEN
      RETURN;
    END IF;

    -- IF l_last_update_date IS NOT NULL THEN

    IF p_entity_name = 'HZ_ORGANIZATION_PROFILES' THEN
      IF G_ORG_SETUP_LAST_UPDATE_DATE IS NULL OR
         G_ORG_SETUP_LAST_UPDATE_DATE <> l_last_update_date
      THEN
        G_ORG_SETUP_LAST_UPDATE_DATE := l_last_update_date;
        l_reload := TRUE;
      END IF;
    ELSE
      IF G_PER_SETUP_LAST_UPDATE_DATE IS NULL OR
         G_PER_SETUP_LAST_UPDATE_DATE <> l_last_update_date
      THEN
        G_PER_SETUP_LAST_UPDATE_DATE := l_last_update_date;
        l_reload := TRUE;
      END IF;
    END IF;
    --  END IF;

    IF l_reload THEN
*/

    IF p_entity_name = 'HZ_ORGANIZATION_PROFILES' AND
       G_ORG_SETUP_LOADED = 'N' OR
       p_entity_name = 'HZ_PERSON_PROFILES' AND
       G_PER_SETUP_LOADED = 'N'
    THEN

      -- load attribute names

      OPEN c_entity_dict(p_entity_name);
      IF p_entity_name = 'HZ_ORGANIZATION_PROFILES' THEN
        FETCH c_entity_dict BULK COLLECT INTO
          G_ORG_ATTRIBUTE_ID, G_ORG_ATTRIBUTE_NAME;
      ELSE
        FETCH c_entity_dict BULK COLLECT INTO
          G_PER_ATTRIBUTE_ID, G_PER_ATTRIBUTE_NAME;
      END IF;
      CLOSE c_entity_dict;

      -- load attributes data source and ranking

      OPEN c_data_source(p_entity_name);
      FETCH c_data_source BULK COLLECT INTO
        i_entity_attr_id, i_content_source_type, i_ranking;
      CLOSE c_data_source;

      /*
      l_str := '';  l_ranking := 1;
      FOR i IN 1..i_entity_attr_id.COUNT+1 LOOP
        IF i = i_entity_attr_id.COUNT+1 OR
           (i > 1 AND
           i_entity_attr_id(i-1) <> i_entity_attr_id(i))
        THEN
          G_ATTRIBUTE_DATA_SOURCE(i_entity_attr_id(i-1)) := l_str;

          IF i = i_entity_attr_id.COUNT+1 THEN
            EXIT;
          END IF;
          l_str := ''; l_ranking := 1;
        END IF;
        l_str := l_str||i_content_source_type(i)||','||i_ranking(i)||',';
        l_ranking := l_ranking+1;
      END LOOP;
      */


      -- Bug 4156090.
      -- Changed the caching logic for G_ATTRIBUTE_DATA_SOURCE.

      FOR i IN 1..i_entity_attr_id.COUNT LOOP
	-- Bug 4244112 : Added debug log
/*	IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'Loading attribute - '||i_entity_attr_id(i),
				  p_prefix =>l_debug_prefix,
				  p_msg_level=>fnd_log.level_statement);
	END IF;
*/

          IF G_ATTRIBUTE_DATA_SOURCE.EXISTS(i_entity_attr_id(i)) THEN
	      G_ATTRIBUTE_DATA_SOURCE(i_entity_attr_id(i)) :=
	          G_ATTRIBUTE_DATA_SOURCE(i_entity_attr_id(i))
		  || getIndex(p_list => G_ORIG_SYSTEM_LIST,
		              p_name => i_content_source_type(i))
	          || ':'
		  ||i_ranking(i)
	          ||',';
          ELSE
	          G_ATTRIBUTE_DATA_SOURCE(i_entity_attr_id(i)) :=
		  ','
		  || getIndex(p_list => G_ORIG_SYSTEM_LIST,
		              p_name => i_content_source_type(i))
	          || ':'
		  ||i_ranking(i)
	          ||',';
	  END IF;

      END LOOP;
-- Bug 4228765 : Set the global varialbe for
-- person and organization profile entity
-- setup seperately
--      G_ORG_SETUP_LOADED := 'Y';

      IF p_entity_name = 'HZ_ORGANIZATION_PROFILES' THEN
        G_ORG_SETUP_LOADED := 'Y';
	-- Bug 4244112 : Added debug log
	IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'Loaded Organization Profiles',
				  p_prefix =>l_debug_prefix,
				  p_msg_level=>fnd_log.level_statement);
	END IF;
      END IF;

      IF p_entity_name = 'HZ_PERSON_PROFILES' THEN
        G_PER_SETUP_LOADED := 'Y';
	-- Bug 4244112 : Added debug log
	IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'Loaded Person Profiles',
				  p_prefix =>l_debug_prefix,
				  p_msg_level=>fnd_log.level_statement);
	END IF;
      END IF;

    END IF; -- if G_ORG_SETUP_LOADED = 'N'

    -- END IF; -- if p_entity_name in (..)


        -- Loading overwrite third party data rule

    l_rule_id := fnd_profile.value('HZ_USER_OVERWRITE_RULE');

    -- Debug info.
    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_message=>'Loading overwrite third party data rule. '||
        'HZ_USER_OVERWRITE_RULE = '||l_rule_id||
        ', G_OVERWRITE_THIRD_PARTY_RULE = '||G_OVERWRITE_THIRD_PARTY_RULE,
                                  p_prefix =>l_debug_prefix,
                                  p_msg_level=>fnd_log.level_statement);
    END IF;


    -- SSM SST Integration and Extension
    -- G_OVERWRITE_THIRD_PARTY will have entries of the form:
    -- ,1,2,3,4, where 1, 2, 3, 4, are a mapping for 1st,2nd,3rd,4th orig_system in G_ORIG_SYSTEM_LIST
    -- note that each id will be surrounded by commas(,) on either sides.

    IF NVL(l_rule_id, -999) <> NVL(G_OVERWRITE_THIRD_PARTY_RULE, -999) THEN
      G_OVERWRITE_THIRD_PARTY.DELETE;

      IF l_rule_id IS NOT NULL THEN
        OPEN c_overwrite_third_party_rule(l_rule_id);
        FETCH c_overwrite_third_party_rule BULK COLLECT INTO
          i_entity_attr_id, i_orig_system;
	CLOSE c_overwrite_third_party_rule;


        FOR i IN 1..i_entity_attr_id.COUNT LOOP
          --G_OVERWRITE_THIRD_PARTY(i_entity_attr_id(i)) := i_overwrite_flag(i);
	  IF G_OVERWRITE_THIRD_PARTY.EXISTS(i_entity_attr_id(i))  THEN
	      G_OVERWRITE_THIRD_PARTY(i_entity_attr_id(i)) :=
	         G_OVERWRITE_THIRD_PARTY(i_entity_attr_id(i))
	         || getIndex( p_list => G_ORIG_SYSTEM_LIST,
		              p_name => i_orig_system(i))
                 || ',';
          ELSE
	      G_OVERWRITE_THIRD_PARTY(i_entity_attr_id(i)) :=
	         ','
	         || getIndex( p_list => G_ORIG_SYSTEM_LIST,
		              p_name => i_orig_system(i))
	         || ',';
	  END IF;
	 /*
          IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
              hz_utility_v2pub.debug(
	          p_message   => 'i = ' || i
	                         || ', i_entity_attr_id(i) = '|| i_entity_attr_id(i)
		                 || ', G_OVERWRITE_THIRD_PARTY('||i_entity_attr_id(i)||') = '||G_OVERWRITE_THIRD_PARTY(i_entity_attr_id(i)),
                  p_prefix    => l_debug_prefix,
                  p_msg_level => fnd_log.level_statement);
           END IF;
*/
        END LOOP;

      END IF;

      G_OVERWRITE_THIRD_PARTY_RULE := l_rule_id;

    END IF;

    -- Loading attributes' real data source for a given party

    -- Debug info.
    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_message=>'Loading attributes real data source for a given party. '||
                                               'party_id = '||p_party_id,
                                  p_prefix =>l_debug_prefix,
                                  p_msg_level=>fnd_log.level_statement);
    END IF;

    -- can not cache real data source and exception type because
    -- they are transactional data and should be cleared when
    -- rollback.

    IF p_entity_name = 'HZ_ORGANIZATION_PROFILES' THEN
      OPEN c_exist_org_sst_profile(p_party_id);
      FETCH c_exist_org_sst_profile INTO l_dummy;
      IF c_exist_org_sst_profile%NOTFOUND THEN
        l_dummy := 'N';
      END IF;
      CLOSE c_exist_org_sst_profile;
    ELSE
      OPEN c_exist_per_sst_profile(p_party_id);
      FETCH c_exist_per_sst_profile INTO l_dummy;
      IF c_exist_per_sst_profile%NOTFOUND THEN
        l_dummy := 'N';
      END IF;
      CLOSE c_exist_per_sst_profile;
    END IF;

    -- Debug info.
    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_message=>'SST profile exists. Exists ? '||l_dummy,
                                  p_prefix =>l_debug_prefix,
                                  p_msg_level=>fnd_log.level_statement);
    END IF;

    -- SST profile exists.

    IF l_dummy = 'Y' THEN
      OPEN c_party_data_sources1(p_entity_name, p_party_id);
      FETCH c_party_data_sources1 BULK COLLECT INTO
        i_entity_attr_id, i_content_source_type, i_exception_type;
      CLOSE c_party_data_sources1;
    ELSE
      OPEN c_party_data_sources2(p_entity_name, p_party_id);
      FETCH c_party_data_sources2 BULK COLLECT INTO
        i_entity_attr_id, i_content_source_type, i_exception_type;
      CLOSE c_party_data_sources2;
    END IF;

    G_REAL_DATA_SOURCE.DELETE;
    G_EXCEPTION_TYPE.DELETE;

    FOR i IN 1..i_entity_attr_id.COUNT LOOP
      G_REAL_DATA_SOURCE(i_entity_attr_id(i)) := i_content_source_type(i);
      G_EXCEPTION_TYPE(i_entity_attr_id(i)) := NVL(i_exception_type(i),'Migration');
    END LOOP;

    -- Loading overwrite user data rule

    -- Debug info.
    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_message=>'Loading overwrite user data rule. '||
                                                'party_id = '||p_party_id,
                                  p_prefix =>l_debug_prefix,
                                  p_msg_level=>fnd_log.level_statement);
    END IF;

    G_OVERWRITE_USER_RULE.DELETE;

    -- SSM SST Integration and Extension
    -- Now G_OVERWRITE_USER_RULE will contain the list of orig_systems instead of 'Y'.
    OPEN c_overwrite_user_rule(p_party_id);
    FETCH c_overwrite_user_rule BULK COLLECT INTO
      i_entity_attr_id,i_orig_system;
    CLOSE c_overwrite_user_rule;

    FOR i IN 1..i_entity_attr_id.COUNT LOOP
      IF G_OVERWRITE_USER_RULE.EXISTS(i_entity_attr_id(i))  THEN
          G_OVERWRITE_USER_RULE(i_entity_attr_id(i)) :=
             G_OVERWRITE_USER_RULE(i_entity_attr_id(i))
             || getIndex( p_list => G_ORIG_SYSTEM_LIST,
	 	          p_name => i_orig_system(i))
             || ',';
      ELSE
          G_OVERWRITE_USER_RULE(i_entity_attr_id(i)) :=
             ','
	     || getIndex( p_list => G_ORIG_SYSTEM_LIST,
		          p_name => i_orig_system(i))
	     || ',';
      END IF;
/*
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
          hz_utility_v2pub.debug(
              p_message   => 'i = ' || i
                             || ', i_entity_attr_id(i) = '|| i_entity_attr_id(i)
                             || ', G_OVERWRITE_USER_RULE('||i_entity_attr_id(i)||') = '||G_OVERWRITE_USER_RULE(i_entity_attr_id(i)),
              p_prefix    => l_debug_prefix,
              p_msg_level => fnd_log.level_statement);
       END IF;
*/
    END LOOP;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'cacheSetupForPartyProfiles (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

END cacheSetupForPartyProfiles;

/**
 * PRIVATE PROCEDURE cacheSetupForOtherEntities
 *
 * DESCRIPTION
 *   cache mix-n-match setup for performance reason.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * IN:
 *   p_load_rule                    If we need to load the creation rule.
 *
 * MODIFICATION HISTORY
 *
 *   04-30-2002    Jianying Huang       o Created.
 *   01-03-2005    Rajib Ranjan Borah   o SSM SST Integration and Extension.
 *                                        Populated G_OTHER_ENT_USER_OVERWRITE and
 *                                        G_ORIG_SYSTEM_LIST.
 *                                      o Added cursors c_overwrite_rule_other
 *                                        and c_orig_systems.
 *                                      o G_ENTITY_DATA_SOURCE will not be populated
 *                                        for non-profile entities.
 *   07-07-2005    Dhaval Mehta         o Bug 4376604. Changed caching logic for
 *                                        G_ENTITY_DATA_SOURCE to improve scalability.
 */

PROCEDURE cacheSetupForOtherEntities (
    p_load_rule                     IN     BOOLEAN := FALSE
) IS

/*
    -- load last update date for data source' setup

    CURSOR c_datasource_last_update_date IS
      SELECT max(last_update_date) last_update_date
      FROM hz_entity_attributes;
*/

    -- load entity names in setup table for other entities

    CURSOR c_entity_dict_other IS
      SELECT e.entity_attr_id, e.entity_name
      FROM hz_entity_attributes e
      WHERE e.entity_name NOT IN ('HZ_ORGANIZATION_PROFILES','HZ_PERSON_PROFILES')
      ORDER BY e.entity_name;

/* SSM SST Integration and Extension
   The concept of selected data sources for other entities is obsoleted.

    -- load data source in setup table for other entities.

    CURSOR c_data_source_other IS
      SELECT s.entity_attr_id,
             s.content_source_type
      FROM hz_entity_attributes e,
           hz_select_data_sources s
      WHERE e.entity_name NOT IN ('HZ_ORGANIZATION_PROFILES','HZ_PERSON_PROFILES')
      AND s.entity_attr_id = e.entity_attr_id
      AND s.ranking > 0
      ORDER BY s.entity_attr_id;
*/
    -- load data source in setup table for party profiles.

    CURSOR c_data_source_profile (
      p_entity_name                  VARCHAR2
    ) IS
      SELECT UNIQUE s.content_source_type
      FROM hz_entity_attributes e,
           hz_select_data_sources s
      WHERE e.entity_name = p_entity_name
      AND s.entity_attr_id = e.entity_attr_id
      AND s.ranking <> 0; -- SSM SST Integration and Extension -->> ranking of -1 denotes MRR

    -- find out if user can create user-entered data

    CURSOR c_user_create_rule (
      p_rule_id                     NUMBER
    ) IS
      SELECT entity_attr_id, creation_flag
      FROM hz_user_create_rules
      WHERE rule_id = p_rule_id;


    -- SSM SST Integration and Extension
    -- Other entities can now be overwriteable if the rules are setup for this.

    CURSOR c_user_overwrite_rule_other (
      p_rule_id                     NUMBER
    ) IS
      SELECT entity_attr_id,
             orig_system
      FROM   hz_user_overwrite_rules
      WHERE  overwrite_flag = 'Y'
        AND  rule_id = p_rule_id;

    -- SSM SST Integration and Extension
    -- All valid content source types will be stored in PL/SQL tables for faster access.
    CURSOR c_orig_systems
    IS
        SELECT  orig_system
	FROM    hz_orig_systems_b
	WHERE   sst_flag = 'Y'
--	  AND   status = 'A'
	ORDER BY orig_system;

    i_entity_attr_id                INDEXIDList;
    i_content_source_type           INDEXVARCHAR30List;
    i_creation_flag                 INDEXVARCHAR30List;

    l_entity_id                     NUMBER;
    l_entity_name                   VARCHAR2(30);
--  l_last_update_date              DATE;
    l_rule_id                       NUMBER;
-- Bug 4171892
    l_str                           VARCHAR2(1000);
    l_len                           NUMBER;
    l_start                         NUMBER;
    i                               NUMBER;
    j                               NUMBER;
    l_debug_prefix                  VARCHAR2(30) := '';
    i_orig_system                   INDEXVARCHAR30List;
BEGIN

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'cacheSetupForOtherEntities (+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- loading dictionary for other entities

    -- Debug info.
    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_message=>'G_DATASOURCE_LOADED = '||G_DATASOURCE_LOADED,
                                  p_prefix =>l_debug_prefix,
                                  p_msg_level=>fnd_log.level_statement);
    END IF;

/*
    OPEN c_datasource_last_update_date;
    FETCH c_datasource_last_update_date INTO l_last_update_date;
    CLOSE c_datasource_last_update_date;

    IF l_last_update_date IS NULL THEN
      RETURN;
    END IF;

    IF G_DATASOURCE_LAST_UPDATE_DATE IS NULL OR
       G_DATASOURCE_LAST_UPDATE_DATE <> l_last_update_date
    THEN
*/

    IF G_DATASOURCE_LOADED = 'N' THEN

      -- load entity names

      OPEN c_entity_dict_other;
      FETCH c_entity_dict_other BULK COLLECT INTO
        G_ENTITY_ID, G_ENTITY_NAME;
      CLOSE c_entity_dict_other;


  /*******************************
   ^  SSM SST Integration and Extension
   |  The concept of selected data sources for other entities is obsoleted.
   |  Comment out the code below while handling other entities.


      -- G_MIXNM_ENABLED_FLAG.DELETE;
      -- G_ENTITY_DATA_SOURCE.DELETE;

      -- load entities' data source

      OPEN c_data_source_other;
      FETCH c_data_source_other BULK COLLECT INTO
        i_entity_attr_id, i_content_source_type;
      CLOSE c_data_source_other;

      IF i_entity_attr_id.COUNT > 0 THEN
        l_str := '';
        FOR i IN 1..i_entity_attr_id.COUNT+1 LOOP
          IF i = i_entity_attr_id.COUNT+1 OR
             (i > 1 AND
             i_entity_attr_id(i-1) <> i_entity_attr_id(i))
          THEN
            IF l_str IS NOT NULL THEN
              l_len := LENGTHB(l_str);
              IF l_len > 1 THEN
                l_str := SUBSTRB(l_str,1,l_len-1);
              END IF;
            END IF;

            -- Debug info.
            IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
                 hz_utility_v2pub.debug(p_message=>'l_str = '||l_str,
                                  p_prefix =>l_debug_prefix,
                                  p_msg_level=>fnd_log.level_statement);
            END IF;

            G_ENTITY_DATA_SOURCE(i_entity_attr_id(i-1)) := l_str;

            IF i = i_entity_attr_id.COUNT+1 THEN
              EXIT;
            END IF;
            l_str := '';
          END IF;
          l_str := l_str||''''||i_content_source_type(i)||''',';
        END LOOP;
      END IF;

      l_start := G_ENTITY_ID.COUNT;

      -- Debug info.
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_message=>'l_start = '||l_start,
  |                                p_prefix =>l_debug_prefix,
  |                                p_msg_level=>fnd_log.level_statement);
  V    END IF;
  *************************/

  -- Bug 4376604.
  -- Moved caching of orig system list out of the rules block as this caching will be used for
  -- G_ENTITY_DATA_SOURCE also.

  -- SSM SST Integration and Extension
  -- Load table G_ORIG_SYSTEM_LIST.

    IF G_ORIG_SYSTEM_LIST_LOADED = 'N' THEN
        OPEN  c_orig_systems;
        FETCH c_orig_systems BULK COLLECT INTO
              G_ORIG_SYSTEM_LIST;
        CLOSE c_orig_systems;
        G_ORIG_SYSTEM_LIST_LOADED := 'Y';
    END IF;

    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
        -- Log count of content_source_types
        hz_utility_v2pub.debug(
	        p_message   => 'G_ORIG_SYSTEM_LIST.COUNT = '
	                       || G_ORIG_SYSTEM_LIST.COUNT,
            p_prefix    => l_debug_prefix,
            p_msg_level => fnd_log.level_statement);

        -- Log orig_system_list.
        FOR i in 1..G_ORIG_SYSTEM_LIST.COUNT LOOP
            hz_utility_v2pub.debug(
                p_message   => 'G_ORIG_SYSTEM_LIST(' || i || ') = '
	                           || G_ORIG_SYSTEM_LIST(i),
                p_prefix    => l_debug_prefix,
                p_msg_level => fnd_log.level_statement);
        END LOOP;

    END IF;

    FOR i IN 1..2 LOOP
        i_content_source_type.DELETE;

        -- Debug info.
        IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_message=>'i = '||i,
                                  p_prefix =>l_debug_prefix,
                                  p_msg_level=>fnd_log.level_statement);
        END IF;

        IF i = 1 THEN
          l_entity_name := 'HZ_PERSON_PROFILES';
          l_entity_id := G_PERSON_PROFILE_ID;
        ELSE
          l_entity_name := 'HZ_ORGANIZATION_PROFILES';
          l_entity_id := G_ORGANIZATION_PROFILE_ID;
        END IF;

        -- Debug info.
        IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_message=>'l_entity_name = '''||l_entity_name||'''',
                                  p_prefix =>l_debug_prefix,
                                  p_msg_level=>fnd_log.level_statement);
           hz_utility_v2pub.debug(p_message=>'l_entity_id = '||l_entity_id,
                                  p_prefix =>l_debug_prefix,
                                  p_msg_level=>fnd_log.level_statement);

        END IF;

        OPEN c_data_source_profile(l_entity_name);
        FETCH c_data_source_profile BULK COLLECT INTO
          i_content_source_type;
        CLOSE c_data_source_profile;

        -- Debug info.
        IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_message=>'i_content_source_type.COUNT = '||i_content_source_type.COUNT,
                                  p_prefix =>l_debug_prefix,
                                  p_msg_level=>fnd_log.level_statement);
        END IF;

/*
        l_str := '';
        FOR j IN 1..i_content_source_type.COUNT LOOP
          l_str := l_str||''''||i_content_source_type(j)||''',';
        END LOOP;
        IF l_str IS NOT NULL THEN
          l_len := LENGTHB(l_str);
          IF l_len > 1 THEN
            l_str := SUBSTRB(l_str,1,l_len-1);
          END IF;
        END IF;
*/

        -- New caching logic for G_ENTITY_DATA_SOURCE
        FOR j IN 1..i_content_source_type.COUNT LOOP
            IF G_ENTITY_DATA_SOURCE.EXISTS(l_entity_id) THEN
                G_ENTITY_DATA_SOURCE(l_entity_id) := G_ENTITY_DATA_SOURCE(l_entity_id)
                                                     || getIndex( p_list => G_ORIG_SYSTEM_LIST,
                                                                  p_name => i_content_source_type(j))
                                                     || ',';
            ELSE
                 G_ENTITY_DATA_SOURCE(l_entity_id) := ','
                                                     || getIndex( p_list => G_ORIG_SYSTEM_LIST,
                                                                  p_name => i_content_source_type(j))
                                                     || ',';
            END IF;
        END LOOP;
        -- Debug info.
        IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_message=>'l_str = '||l_str,
                                  p_prefix =>l_debug_prefix,
                                  p_msg_level=>fnd_log.level_statement);
        END IF;

--        G_ENTITY_DATA_SOURCE(l_entity_id) := l_str;
      END LOOP;

      -- Debug info.
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_message=>'total = '||G_ENTITY_DATA_SOURCE.COUNT,
                                  p_prefix =>l_debug_prefix,
                                  p_msg_level=>fnd_log.level_statement);
           WHILE j <= G_ENTITY_DATA_SOURCE.COUNT LOOP
             IF G_ENTITY_DATA_SOURCE.EXISTS(i) THEN
               hz_utility_v2pub.debug(p_message=>'G_ENTITY_DATA_SOURCE('||i||')='||
                                                G_ENTITY_DATA_SOURCE(i),
                                  p_prefix =>l_debug_prefix,
                                  p_msg_level=>fnd_log.level_statement);
             ELSE
                hz_utility_v2pub.debug(p_message=>'G_ENTITY_DATA_SOURCE('||i||')=null',
                                  p_prefix =>l_debug_prefix,
                                  p_msg_level=>fnd_log.level_statement);
             END IF;
             i := G_ENTITY_DATA_SOURCE.NEXT(i);
             hz_utility_v2pub.debug(p_message=>'i = '||i,
                                  p_prefix =>l_debug_prefix,
                                  p_msg_level=>fnd_log.level_statement);
             j := j + 1;
           END LOOP;
      END IF;

--    G_DATASOURCE_LAST_UPDATE_DATE := l_last_update_date;
      G_DATASOURCE_LOADED := 'Y';

    END IF;

    IF p_load_rule THEN

      -- Loading creation user-entered data rule

      l_rule_id := fnd_profile.value('HZ_USER_DATA_CREATION_RULE');

      -- Debug info.
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_message=>'Loading creation user-entered data rule.' ||
                                          'HZ_USER_DATA_CREATION_RULE = '||l_rule_id||
                                          ', G_CREATE_USER_ENTERED_RULE = '||G_CREATE_USER_ENTERED_RULE,
                                  p_prefix =>l_debug_prefix,
                                  p_msg_level=>fnd_log.level_statement);
     END IF;

      IF NVL(l_rule_id, -999) <> NVL(G_CREATE_USER_ENTERED_RULE, -999) THEN

        G_CREATE_USER_ENTERED.DELETE;
        G_OTHER_ENT_USER_OVERWRITE.DELETE;

        IF l_rule_id IS NOT NULL THEN
          OPEN c_user_create_rule(l_rule_id);
          FETCH c_user_create_rule BULK COLLECT INTO
            i_entity_attr_id, i_creation_flag;
          CLOSE c_user_create_rule;

          FOR i IN 1..i_entity_attr_id.COUNT LOOP
            G_CREATE_USER_ENTERED(i_entity_attr_id(i)) := i_creation_flag(i);
          END LOOP;

	  OPEN c_user_overwrite_rule_other(l_rule_id);
	  FETCH c_user_overwrite_rule_other BULK COLLECT INTO
	     i_entity_attr_id, i_orig_system;
	  CLOSE c_user_overwrite_rule_other;

	  FOR i IN 1..i_entity_attr_id.COUNT LOOP
	      IF G_OTHER_ENT_USER_OVERWRITE.EXISTS(i_entity_attr_id(i)) THEN
 	          G_OTHER_ENT_USER_OVERWRITE(i_entity_attr_id(i)) :=
		      G_OTHER_ENT_USER_OVERWRITE(i_entity_attr_id(i))
		      || getIndex( p_list => G_ORIG_SYSTEM_LIST,
		                   p_name => i_orig_system(i))
		      || ',';
              ELSE
                  G_OTHER_ENT_USER_OVERWRITE(i_entity_attr_id(i)) :=
		      ','
		      || getIndex( p_list => G_ORIG_SYSTEM_LIST,
		                   p_name => i_orig_system(i))
		      || ',';
      	      END IF;
	  END LOOP;

        END IF;

        G_CREATE_USER_ENTERED_RULE := l_rule_id;

      END IF;

    END IF;

      -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'cacheSetupForOtherEntities (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

END cacheSetupForOtherEntities;

/**
 * PRIVATE PROCEDURE isThirdPartyDataOverwriteable
 *
 * DESCRIPTION
 *   Return 'Y' if third party data is overwritable.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * IN:
 *   p_entity_attr_id               Attribute Id.
 *
 * MODIFICATION HISTORY
 *
 *   04-30-2002    Jianying Huang       o Created.
 *   12-30-2004    Rajib Ranjan Borah   o SSM SST Integration and Extension.
 *                                        Added parameter p_orig_system and related logic.
 *
 */

FUNCTION isThirdPartyDataOverwriteable (
    p_entity_attr_id                IN     NUMBER,
    p_orig_system                   IN     VARCHAR2
) RETURN VARCHAR2 IS
l_debug_prefix              VARCHAR2(30) := '';
BEGIN

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'isThirdPartyDataOverwriteable (+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;
    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(
            p_message   => ' p_orig_system = '||p_orig_system
			   || ', p_entity_attr_id = '||p_entity_attr_id,
            p_prefix    => l_debug_prefix,
            p_msg_level => fnd_log.level_statement);
    END IF;

-- Bug 4201309 : By default, user can overwrite any attribute
-- if there is no rule restricting the update
    IF G_OVERWRITE_THIRD_PARTY_RULE IS NULL THEN
	RETURN 'Y';
    END IF;

    IF G_OVERWRITE_THIRD_PARTY.EXISTS(p_entity_attr_id) THEN
        --RETURN G_OVERWRITE_THIRD_PARTY(p_entity_attr_id);
	IF instrb ( G_OVERWRITE_THIRD_PARTY(p_entity_attr_id),
	            ',' || getIndex ( p_list => G_ORIG_SYSTEM_LIST,
		                      p_name => p_orig_system ) || ',',
		    1,
		    1
		  ) <> 0
        THEN

            IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
                hz_utility_v2pub.debug(
                    p_message   => 'G_OVERWRITE_THIRD_PARTY('||p_entity_attr_id||') = '
                                   || G_OVERWRITE_THIRD_PARTY(p_entity_attr_id)
				   || '. Case 1-Y',
                    p_prefix    => l_debug_prefix,
                    p_msg_level => fnd_log.level_statement);
            END IF;
            IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
                 hz_utility_v2pub.debug(
		     p_message   => 'isThirdPartyDataOverwriteable (-)',
                     p_prefix    => l_debug_prefix,
                     p_msg_level => fnd_log.level_procedure);
            END IF;

            RETURN 'Y';
        ELSE

            IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
                hz_utility_v2pub.debug(
                    p_message   => 'G_OVERWRITE_THIRD_PARTY('||p_entity_attr_id||') = '
                                   || G_OVERWRITE_THIRD_PARTY(p_entity_attr_id)
				   || '. Case 2-N',
                    p_prefix    => l_debug_prefix,
                    p_msg_level => fnd_log.level_statement);
            END IF;
            IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
                 hz_utility_v2pub.debug(
		     p_message   => 'isThirdPartyDataOverwriteable (-)',
                     p_prefix    => l_debug_prefix,
                     p_msg_level => fnd_log.level_procedure);
            END IF;

            RETURN 'N';
        END IF;
    ELSE

        IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug(
                p_message   => 'G_OVERWRITE_THIRD_PARTY('||p_entity_attr_id||') does not exist '
			       || '. Case 3-N',
                p_prefix    => l_debug_prefix,
                p_msg_level => fnd_log.level_statement);
        END IF;
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
             hz_utility_v2pub.debug(
	         p_message   => 'isThirdPartyDataOverwriteable (-)',
                 p_prefix    => l_debug_prefix,
                 p_msg_level => fnd_log.level_procedure);
        END IF;

        RETURN 'N';
    END IF;

END isThirdPartyDataOverwriteable;

/**
 * PRIVATE PROCEDURE isUserDataOverwriteable
 *
 * DESCRIPTION
 *   Return 'Y' if user data is overwritable.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * IN:
 *   p_entity_attr_id               Attribute Id.
 *
 * MODIFICATION HISTORY
 *
 *   04-30-2002    Jianying Huang   o Created.
 *   12-30-2004    Rajib Ranjan Borah   o SSM SST Integration and Extension.
 *                                        Added parameter p_orig_system and related logic.
 */

FUNCTION isUserDataOverwriteable (
    p_entity_attr_id                IN     NUMBER,
    p_orig_system                   IN     VARCHAR2
) RETURN VARCHAR2 IS
l_debug_prefix              VARCHAR2(30) := '';
BEGIN

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'isUserDataOverwriteable (+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;
    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(
            p_message   => 'p_orig_system = '||p_orig_system
			   || ', p_entity_attr_id = '||p_entity_attr_id,
            p_prefix    => l_debug_prefix,
            p_msg_level => fnd_log.level_statement);
    END IF;

    IF G_OVERWRITE_USER_RULE.EXISTS(p_entity_attr_id)
    THEN
        IF instrb ( G_OVERWRITE_USER_RULE(p_entity_attr_id),
                  ',' || getIndex ( p_list => G_ORIG_SYSTEM_LIST,
		                    p_name => p_orig_system ) || ',',
                  1,
		  1
                ) <> 0
        THEN
            IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
                hz_utility_v2pub.debug(
                    p_message   => 'G_OVERWRITE_USER_RULE('||p_entity_attr_id||') = '
                                   || G_OVERWRITE_USER_RULE(p_entity_attr_id)
				   || '. Case 1-Y',
                    p_prefix    => l_debug_prefix,
                    p_msg_level => fnd_log.level_statement);
            END IF;
            IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
                 hz_utility_v2pub.debug(
		     p_message   => 'isThirdPartyDataOverwriteable (-)',
                     p_prefix    => l_debug_prefix,
                     p_msg_level => fnd_log.level_procedure);
            END IF;

            RETURN 'Y';
        ELSE
            IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
                hz_utility_v2pub.debug(
                    p_message   => 'G_OVERWRITE_THIRD_PARTY('||p_entity_attr_id||') = '
                                   || G_OVERWRITE_THIRD_PARTY(p_entity_attr_id)
				   || '. Case 2-N',
                    p_prefix    => l_debug_prefix,
                    p_msg_level => fnd_log.level_statement);
            END IF;
            IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
                 hz_utility_v2pub.debug(
		     p_message   => 'isThirdPartyDataOverwriteable (-)',
                     p_prefix    => l_debug_prefix,
                     p_msg_level => fnd_log.level_procedure);
            END IF;

            RETURN 'N';
        END IF;
    ELSE
       IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug(
                p_message   => 'G_OVERWRITE_THIRD_PARTY('||p_entity_attr_id||') does not exist '
			       || '. Case 3-N',
                p_prefix    => l_debug_prefix,
                p_msg_level => fnd_log.level_statement);
        END IF;
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
             hz_utility_v2pub.debug(
	         p_message   => 'isThirdPartyDataOverwriteable (-)',
                 p_prefix    => l_debug_prefix,
                 p_msg_level => fnd_log.level_procedure);
        END IF;

        RETURN 'N';
    END IF;

END isUserDataOverwriteable;

/**
 * PRIVATE PROCEDURE getDataSourceRanking
 *
 * DESCRIPTION
 *   Return data source ranking for a given attribute id and
 *   data source type.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * IN:
 *   p_entity_attr_id               Attribute Id.
 *   p_data_source_type             Data source type.
 *
 * MODIFICATION HISTORY
 *
 *   04-30-2002    Jianying Huang        o Created.
 *   02-28-2005    Rajib Ranjan Borah    o Bug 4156090. Caching logic is changed for
 *                                         G_ATTRIBUTE_DATA_SOURCE
 */

FUNCTION getDataSourceRanking (
    p_entity_attr_id                IN     NUMBER,
    p_data_source_type              IN     VARCHAR2
) RETURN NUMBER IS

    l_pos                           NUMBER;
    l_pos1                          NUMBER;
    l_pos2                          NUMBER;
    l_str                           VARCHAR2(400);
    l_debug_prefix                  VARCHAR2(30) := '';

BEGIN

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'getDataSourceRanking (+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;


    -- the element in the pl/sql table has the format
    -- <data source1>,1,<data source2>,2,...
    -- for instance, USER_ENTERED,1,DNB,2,...
    -- So we only need to find the number right after
    -- the data source.
    /*
   IF G_ATTRIBUTE_DATA_SOURCE.EXISTS(p_entity_attr_id) THEN
      l_str := G_ATTRIBUTE_DATA_SOURCE(p_entity_attr_id);
      l_pos := INSTRB(l_str, p_data_source_type||',');
      IF l_pos = 0 THEN
        RETURN 0;
      ELSE
        l_pos1 := l_pos+LENGTHB(p_data_source_type)+1;
        l_pos2 := INSTRB(l_str, ',', l_pos, 2);
        RETURN TO_NUMBER(SUBSTRB(l_str, l_pos1, l_pos2-l_pos1));
      END IF;
    ELSE
      RETURN 0;
    END IF;
     */

    -- Bug 4156090.
    -- Changed the caching logic in G_ATTRIBUTE_DATA_SOURCE.

    IF G_ATTRIBUTE_DATA_SOURCE.EXISTS(p_entity_attr_id) THEN
      l_str := G_ATTRIBUTE_DATA_SOURCE(p_entity_attr_id);
      l_pos := INSTRB(l_str, ','||getIndex(p_list => G_ORIG_SYSTEM_LIST, p_name => p_data_source_type)||':');
      IF l_pos = 0 THEN
        RETURN 0;
      ELSE
        l_pos1 := INSTRB(l_str, ':', l_pos) + 1;

        l_pos2 := INSTRB(l_str, ',', l_pos1);
        RETURN TO_NUMBER(SUBSTRB(l_str, l_pos1, l_pos2-l_pos1));
      END IF;
    ELSE
      RETURN 0;
    END IF;

END getDataSourceRanking;

/**
 * PRIVATE PROCEDURE getIndex
 *
 * DESCRIPTION
 *   Return the index of a name in a name list.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * IN:
 *   p_list                         Name list.
 *   p_name                         Name of the entity / attribute.
 *
 * MODIFICATION HISTORY
 *
 *   04-30-2002    Jianying Huang   o Created.
 */

FUNCTION getIndex (
    p_list                          IN     INDEXVARCHAR30List,
    p_name                          IN     VARCHAR2
) RETURN NUMBER IS

    l_start                         NUMBER;
    l_end                           NUMBER;
    l_middle                        NUMBER;
    l_debug_prefix                  VARCHAR2(30) := '';

BEGIN
/* Bug 4244112 : comment debug log
    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'getIndex (+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;
*/

    -- binary search

    l_start := 1;  l_end := p_list.COUNT;
/* Bug 4244112 : comment debug log
    -- Debug info.
    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_message=>'l_end = '||l_end,
                                  p_prefix =>l_debug_prefix,
                                  p_msg_level=>fnd_log.level_statement);
    END IF;
*/
    WHILE l_start <= l_end LOOP
      l_middle := ROUND((l_end+l_start)/2);
/*
      -- Debug info.
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_message=>'p_list('||l_middle||') = '||p_list(l_middle),
                                  p_prefix =>l_debug_prefix,
                                  p_msg_level=>fnd_log.level_statement);
      END IF;
*/
      IF p_name = p_list(l_middle) THEN
/* Bug 4244112 : comment debug log
    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'getIndex (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;
*/
        RETURN l_middle;
      ELSIF p_name > p_list(l_middle) THEN
        l_start := l_middle+1;
      ELSE
        l_end := l_middle-1;
      END IF;
    END LOOP;

    RETURN 0;

END getIndex;

/**
 * PRIVATE PROCEDURE getEntityAttrId
 *
 * DESCRIPTION
 *   Return the id of a given entity / attribute.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * IN:
 *   p_entity_name                  Entity name.
 *   p_attribute_name               Attribute name.
 *
 * MODIFICATION HISTORY
 *
 *   04-30-2002    Jianying Huang   o Created.
 */

FUNCTION getEntityAttrId (
    p_entity_name                   IN     VARCHAR2,
    p_attribute_name                IN     VARCHAR2 := NULL
) RETURN NUMBER IS

    l_index                         NUMBER;
    l_debug_prefix                  VARCHAR2(30) := '';

BEGIN

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'getEntityAttrId (+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    IF p_attribute_name IS NOT NULL THEN
--    IF G_ORG_SETUP_LAST_UPDATE_DATE IS NOT NULL AND
      IF G_ORG_SETUP_LOADED = 'Y' AND
         p_entity_name = 'HZ_ORGANIZATION_PROFILES'
      THEN
        l_index := getIndex(G_ORG_ATTRIBUTE_NAME, UPPER(p_attribute_name));

        -- Debug info.
        IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_message=>'index = '||l_index||', attribute = ' || p_attribute_name,
                                  p_prefix =>l_debug_prefix,
                                  p_msg_level=>fnd_log.level_statement);
        END IF;
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
                hz_utility_v2pub.debug(p_message=>'getEntityAttrId (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
        END IF;

        IF l_index > 0 THEN
          RETURN G_ORG_ATTRIBUTE_ID(l_index);
        ELSE
          RETURN 0;
        END IF;
--    ELSIF G_PER_SETUP_LAST_UPDATE_DATE IS NOT NULL AND
      ELSIF G_PER_SETUP_LOADED = 'Y' AND
            p_entity_name = 'HZ_PERSON_PROFILES'
      THEN
        l_index := getIndex(G_PER_ATTRIBUTE_NAME, UPPER(p_attribute_name));

        -- Debug info.
        IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_message=>'index = '||l_index||', attribute = ' || p_attribute_name,
                                  p_prefix =>l_debug_prefix,
                                  p_msg_level=>fnd_log.level_statement);
        END IF;
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
                hz_utility_v2pub.debug(p_message=>'getEntityAttrId (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
        END IF;

        IF l_index > 0 THEN
          RETURN G_PER_ATTRIBUTE_ID(l_index);
        ELSE
          RETURN 0;
        END IF;
      END IF;
--  ELSIF G_DATASOURCE_LAST_UPDATE_DATE IS NOT NULL THEN
    ELSIF G_DATASOURCE_LOADED = 'Y' THEN
      IF p_entity_name = 'HZ_PERSON_PROFILES' THEN
        RETURN G_PERSON_PROFILE_ID;
      ELSIF p_entity_name = 'HZ_ORGANIZATION_PROFILES' THEN
        RETURN G_ORGANIZATION_PROFILE_ID;
      ELSE
        l_index := getIndex(G_ENTITY_NAME, p_entity_name);

        -- Debug info.
        IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_message=>'index = '||l_index||', attribute = ' || p_attribute_name,
                                  p_prefix =>l_debug_prefix,
                                  p_msg_level=>fnd_log.level_statement);
        END IF;
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
                hz_utility_v2pub.debug(p_message=>'getEntityAttrId (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
        END IF;


        IF l_index > 0 THEN
          RETURN G_ENTITY_ID(l_index);
        ELSE
          RETURN 0;
        END IF;
      END IF;
    END IF;

    RETURN 0;

END getEntityAttrId;

/**
 * PRIVATE PROCEDURE isSSTColumnUpdatable
 *
 * DESCRIPTION
 *   Return 'Y' if the sst column is updatable.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * IN:
 *   p_party_id                     Party id.
 *   p_entity_attr_id               Entity / attribute id.
 *   p_entity_name                  Entity name.
 *   p_attribute_name               Attribute name.
 *   p_value_is_null                'Y' if the attribute is NULL.
 *   p_data_source_type             Data source type.
 * OUT:
 *   x_exception_type               Exception type.
 *
 * MODIFICATION HISTORY
 *
 *   04-30-2002    Jianying Huang   o Created.
 */

FUNCTION isSSTColumnUpdatable (
    p_party_id                      IN     NUMBER,
    p_entity_name                   IN     VARCHAR2,
    p_attribute_name                IN     VARCHAR2,
    p_entity_attr_id                IN     NUMBER,
    p_value_is_null                 IN     VARCHAR2,
    p_data_source_type              IN     VARCHAR2,
    x_exception_type                OUT    NOCOPY VARCHAR2,
    p_is_null			    IN     VARCHAR2
) RETURN VARCHAR2 IS

    l_entity_attr_id                NUMBER;
    l_real_data_source_type         VARCHAR2(30);
    l_real_data_source_ranking      NUMBER;
    l_new_data_source_ranking       NUMBER;
    l_data_source_type              VARCHAR2(30) := p_data_source_type;
    l_debug_prefix                  VARCHAR2(30) := '';

BEGIN
    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'isSSTColumnUpdatable (+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    IF p_data_source_type = G_MISS_ACTUAL_CONTENT_SOURCE THEN
      l_data_source_type := G_MISS_CONTENT_SOURCE_TYPE;
    END IF;

    -- get entity / attribute id.

    IF p_entity_attr_id IS NULL THEN
      l_entity_attr_id := getEntityAttrId(p_entity_name, p_attribute_name);
    ELSE
      l_entity_attr_id := p_entity_attr_id;
    END IF;
    x_exception_type := 'Migration';

      -- find out the ranking of the comming data source.
      l_new_data_source_ranking :=
        getDataSourceRanking(
          p_entity_attr_id               => l_entity_attr_id,
          p_data_source_type             => l_data_source_type);

      -- Debug info.
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_message=>'new_data_source = '||l_data_source_type||', '||
          'new_data_source_ranking = '||l_new_data_source_ranking,
                                  p_prefix =>l_debug_prefix,
                                  p_msg_level=>fnd_log.level_statement);
      END IF;

      IF l_new_data_source_ranking = 0 THEN
        -- Debug info.
        IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_message=>'return N: new data source ranking is 0',
                                  p_prefix =>l_debug_prefix,
                                  p_msg_level=>fnd_log.level_statement);
        END IF;

        RETURN 'N';
      END IF;

      IF l_new_data_source_ranking = -1 THEN
        -- Debug info.
        IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_message=>'return Y (MRR): both data source ranking is -1',
                                  p_prefix =>l_debug_prefix,
                                  p_msg_level=>fnd_log.level_statement);
        END IF;
        IF p_is_null = 'N' THEN
  	  x_exception_type := 'MRR';
	ELSE
	  x_exception_type := 'MRN';
	END IF;

        RETURN 'Y';
      END IF;

    -- if the value is null, the column is updatable.

    IF p_value_is_null = 'Y' THEN
      -- Debug info.
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_message=>'return Y: value is null',
                                  p_prefix =>l_debug_prefix,
                                  p_msg_level=>fnd_log.level_statement);
      END IF;

      RETURN 'Y';
    END IF;


    -- Debug info.
    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_message=>'entity_attr_id = '||l_entity_attr_id||', entity_name = '||
        p_entity_name||', attribute_name = '||p_attribute_name,
                                  p_prefix =>l_debug_prefix,
                                  p_msg_level=>fnd_log.level_statement);
    END IF;

    -- if the attribute is not in setup table, the attribute is updatable.

    IF l_entity_attr_id = 0 THEN
      -- Debug info.
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_message=>'return Y: entity_attr_id is 0 (non-restricted column)',
                                  p_prefix =>l_debug_prefix,
                                  p_msg_level=>fnd_log.level_statement);
      END IF;

      RETURN 'Y';
    END IF;

    -- find out the real data source and the ranking of the data source.

    IF G_REAL_DATA_SOURCE.EXISTS(l_entity_attr_id) THEN
      l_real_data_source_type := G_REAL_DATA_SOURCE(l_entity_attr_id);

      l_real_data_source_ranking :=
        getDataSourceRanking(
          p_entity_attr_id               => l_entity_attr_id,
          p_data_source_type             => l_real_data_source_type);

      -- Debug info.
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_message=>'real_data_source = '||l_real_data_source_type||', '||
          'real_data_source_ranking = '||l_real_data_source_ranking,
                                  p_prefix =>l_debug_prefix,
                                  p_msg_level=>fnd_log.level_statement);
      END IF;

      -- if real data source ranking is 0, the attribute is updatable.

      IF l_real_data_source_ranking = 0 THEN
        -- Debug info.
        IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_message=>'return Y (Migration): real data source ranking is 0',
                                  p_prefix =>l_debug_prefix,
                                  p_msg_level=>fnd_log.level_statement);
        END IF;

        RETURN 'Y';
      END IF;


      -- find out the exception type.

      IF NOT G_EXCEPTION_TYPE.EXISTS(l_entity_attr_id) OR
         G_EXCEPTION_TYPE(l_entity_attr_id) IS NULL
      THEN
        x_exception_type := 'Migration';
      ELSE
        x_exception_type := G_EXCEPTION_TYPE(l_entity_attr_id);
      END IF;

      -- Debug info.
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_message=>'exp_type = '||x_exception_type,
                                  p_prefix =>l_debug_prefix,
                                  p_msg_level=>fnd_log.level_statement);
      END IF;
    ELSE
      -- Debug info.
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_message=>'return Y (Migration): real data source does not exist',
                                  p_prefix =>l_debug_prefix,
                                  p_msg_level=>fnd_log.level_statement);
      END IF;

      RETURN 'Y';
    END IF;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'isSSTColumnUpdatable (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- call real function for updatable checking.

    RETURN
      isSSTColumnUpdatable (
        p_party_id                      => p_party_id,
        p_entity_attr_id                => l_entity_attr_id,
        p_real_data_source_type         => l_real_data_source_type,
        p_real_data_source_ranking      => l_real_data_source_ranking,
        p_new_data_source_type          => p_data_source_type,
        p_new_data_source_ranking       => l_new_data_source_ranking,
        p_exception_type                => x_exception_type );

END isSSTColumnUpdatable;

/**
 * PRIVATE PROCEDURE isSSTColumnUpdatable
 *
 * DESCRIPTION
 *   Return 'Y' if the sst column is updatable.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * IN:
 *   p_party_id                     Party id.
 *   p_entity_attr_id               Entity / attribute id.
 *   p_real_data_source_type        Real data source type.
 *   p_real_data_source_ranking     Real data source ranking.
 *   p_new_data_source_type         New data source type.
 *   p_new_data_source_ranking      New data source ranking.
 *   p_exception_type               Exception type.
 * OUT:
 *   x_exception_type               Exception type.
 *
 * MODIFICATION HISTORY
 *
 *   04-30-2002    Jianying Huang       o Created.
 *   12-30-2004    Rajib Ranjan Borah   o SSM SST Integration and Extension.
 *                                        Pass relevant orig_systems to isThirdPartyDataOverwriteable
 *                                        and isUserDataOverwriteable.
 *                                        Exception type will be 'Migration' after
 *                                        third party overwrites user data because of third party rule.
 */

FUNCTION isSSTColumnUpdatable (
    p_party_id                      IN     NUMBER,
    p_entity_attr_id                IN     NUMBER,
    p_real_data_source_type         IN     VARCHAR2,
    p_real_data_source_ranking      IN     NUMBER,
    p_new_data_source_type          IN     VARCHAR2,
    p_new_data_source_ranking       IN     NUMBER,
    p_exception_type                IN OUT NOCOPY VARCHAR2
) RETURN VARCHAR2 IS

    l_update                        VARCHAR2(1) := 'N';
    l_debug_prefix                  VARCHAR2(30) := '';
    l_tmp_d VARCHAR2(1);
    p_entity VARCHAR2(30);

BEGIN

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'isSSTColumnUpdatable (+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    IF p_real_data_source_ranking = p_new_data_source_ranking THEN
      l_update := 'Y';
    ELSIF p_real_data_source_ranking < p_new_data_source_ranking THEN
      IF p_new_data_source_type = G_MISS_ACTUAL_CONTENT_SOURCE /*G_MISS_CONTENT_SOURCE_TYPE*/ THEN
        IF isThirdPartyDataOverwriteable(p_entity_attr_id,p_real_data_source_type) = 'Y'
        THEN
          l_update := 'Y'; p_exception_type := 'Exception';

    -- Debug info.
          IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
                hz_utility_v2pub.debug(p_message=>'case 1',
                                  p_prefix =>l_debug_prefix,
                                  p_msg_level=>fnd_log.level_statement);
          END IF;

        END IF;
      ELSE

          select entity_name into p_entity from hz_entity_attributes
          where entity_attr_id = p_entity_attr_id;
	-- Bug 4244112 : Added to populate exceptions for case -
	-- DNB = 1, no DNB profile exists
	-- SBL = 3, creating SBL profile with value for this attribute

        if p_entity = 'HZ_ORGANIZATION_PROFILES' THEN
	BEGIN
	  select '1' into l_tmp_d from hz_organization_profiles where party_id = p_party_id
	  and actual_content_source = p_real_data_source_type
          --  Bug 4482630 : query only active profiles
          and EFFECTIVE_END_DATE is NULL;
	  exception
		when no_data_found then
			 l_update := 'Y'; p_exception_type := 'Migration';
          IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
                hz_utility_v2pub.debug(p_message=>'case 1 - for two third parties',
                                  p_prefix =>l_debug_prefix,
                                  p_msg_level=>fnd_log.level_statement);
          END IF;
	END;
        elsif p_entity = 'HZ_PERSON_PROFILES' THEN
	BEGIN
	  select '1' into l_tmp_d from hz_person_profiles where party_id = p_party_id
	  and actual_content_source = p_real_data_source_type
          and EFFECTIVE_END_DATE is NULL;
	  exception
		when no_data_found then
			 l_update := 'Y'; p_exception_type := 'Migration';
          IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
                hz_utility_v2pub.debug(p_message=>'case 1 - for two third parties',
                                  p_prefix =>l_debug_prefix,
                                  p_msg_level=>fnd_log.level_statement);
          END IF;
	END;
        end if;

      END IF;
    ELSE
      IF p_real_data_source_type <> G_MISS_CONTENT_SOURCE_TYPE AND
         p_new_data_source_type NOT IN (G_MISS_ACTUAL_CONTENT_SOURCE, G_MISS_CONTENT_SOURCE_TYPE)
      THEN
        l_update := 'Y'; --x_exception_type := 'Migration';

        -- Debug info.
        IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
                hz_utility_v2pub.debug(p_message=>'case 2',
                                  p_prefix =>l_debug_prefix,
                                  p_msg_level=>fnd_log.level_statement);
        END IF;


      ELSIF p_exception_type = 'Migration' THEN
        l_update := 'Y';

        -- Debug info.
        IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
                hz_utility_v2pub.debug(p_message=>'case 3',
                                  p_prefix =>l_debug_prefix,
                                  p_msg_level=>fnd_log.level_statement);
        END IF;
      ELSIF p_real_data_source_type = G_MISS_CONTENT_SOURCE_TYPE THEN
        IF isUserDataOverwriteable(p_entity_attr_id,p_new_data_source_type) = 'Y' THEN
           l_update := 'Y';
           p_exception_type := 'Migration';

          -- Debug info.
          IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
                hz_utility_v2pub.debug(p_message=>'case 4',
                                  p_prefix =>l_debug_prefix,
                                  p_msg_level=>fnd_log.level_statement);
          END IF;
        END IF;
      END IF;
    END IF;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'isSSTColumnUpdatable (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;
    RETURN l_update;

END isSSTColumnUpdatable;

/**
 * PROCEDURE areSSTColumnsUpdeable
 *
 * DESCRIPTION
 *    Return a list to indicate which SST attributes are updatable and which are not.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_party_id                   Party Id.
 *     p_entity_name                Entity name.
 *     p_attribute_name_list        Attribute name list.
 *     p_value_is_null_list         'Y' if the corresponding SST column is null.
 *     p_data_source_type           Comming data source.
 *     p_raise_error_flag           Raise error flag.
 *     p_known_dict_id              'Y' if use knew entity id.
 *   IN/OUT:
 *     x_return_status              Return status.
 *   OUT:
 *     x_updatable_flag_list        Updatable list.
 *     x_exception_type_list        Exception type list.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *   The procedure should only be called if the mix-n-match is enable for
 *   the entity.
 *
 *   05-01-2002    Jianying Huang   o Created
 */

PROCEDURE areSSTColumnsUpdeable (
    p_party_id                      IN     NUMBER,
    p_entity_name                   IN     VARCHAR2,
    p_attribute_name_list           IN     INDEXVARCHAR30List,
    p_value_is_null_list            IN     INDEXVARCHAR1List,
    p_data_source_type              IN     VARCHAR2 := G_MISS_ACTUAL_CONTENT_SOURCE,
    x_updatable_flag_list           OUT    NOCOPY INDEXVARCHAR1List,
    x_exception_type_list           OUT    NOCOPY INDEXVARCHAR30List,
    x_return_status                 IN OUT NOCOPY VARCHAR2,
    p_raise_error_flag              IN     VARCHAR2 DEFAULT 'N',
    p_known_dict_id                 IN     VARCHAR2 DEFAULT 'N',
    p_new_value_is_null_list        IN     HZ_MIXNM_UTILITY.INDEXVARCHAR1List
) IS

    i                               NUMBER;
    l_entity_attr_id                NUMBER;
    l_names                         VARCHAR2(255);
    l_message_name                  VARCHAR2(30);
    l_count                         NUMBER;
    l_debug_prefix                  VARCHAR2(30) := '';

BEGIN

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'areSSTColumnsUpdeable (+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;
    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_message=>'raise_error = '||p_raise_error_flag||', '||
                                             'known_dict = '||p_known_dict_id,
                                  p_prefix =>l_debug_prefix,
                                  p_msg_level=>fnd_log.level_statement);
    END IF;

    -- return if the attribute name list is empty.
    IF p_attribute_name_list IS NULL OR
       p_attribute_name_list.COUNT = 0
    THEN
      -- Debug info.
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'areSSTColumnsUpdeable (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
     END IF;

      RETURN;
    END IF;

    -- load all of related setups and cache them.
    cacheSetupForPartyProfiles(p_party_id, p_entity_name);

    -- start to process each attribute.

    i := p_attribute_name_list.FIRST;
    WHILE i <= p_attribute_name_list.LAST LOOP

      -- find out the attribute id if user knew the attribute id.

      IF p_known_dict_id = 'Y' THEN
        l_entity_attr_id := i;
      ELSE
        l_entity_attr_id := NULL;
      END IF;

      -- Debug info.
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_message=>'i = '||i||', attribute_name = '||p_attribute_name_list(i),
                                  p_prefix =>l_debug_prefix,
                                  p_msg_level=>fnd_log.level_statement);
      END IF;

      -- find out if the attribute is updatable.
      x_updatable_flag_list(i) :=
        isSSTColumnupdatable(
          p_party_id              => p_party_id,
          p_entity_name           => p_entity_name,
          p_attribute_name        => p_attribute_name_list(i),
          p_entity_attr_id        => l_entity_attr_id,
          p_value_is_null         => p_value_is_null_list(i),
          p_data_source_type      => p_data_source_type,
          x_exception_type        => x_exception_type_list(i),
          p_is_null		  => p_new_value_is_null_list(i));
      -- Debug info.
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_message=>'updatable = '||x_updatable_flag_list(i)||
                                             ', exp_type = '||x_exception_type_list(i),
                                  p_prefix =>l_debug_prefix,
                                  p_msg_level=>fnd_log.level_statement);
     END IF;

      i := p_attribute_name_list.NEXT(i);
    END LOOP;

    -- raise error for those non-updatable attributes.

    IF p_raise_error_flag = 'Y' THEN
      l_names := '';  l_count := 0;

      i := p_attribute_name_list.FIRST;
      WHILE i <= p_attribute_name_list.LAST LOOP
        IF x_updatable_flag_list(i) = 'N' THEN
          IF l_names IS NULL OR
             LENGTHB(l_names) <= 220
          THEN
            l_count := l_count + 1;
            l_names := l_names||p_attribute_name_list(i)||', ';
          END IF;
        END IF;
        i := p_attribute_name_list.NEXT(i);
      END LOOP;

      IF l_count > 0 THEN
        IF l_count = 1 THEN
          l_message_name := 'HZ_API_SST_NONUPDATEABLE_COL';
        ELSE
          l_message_name := 'HZ_API_SST_NONUPDATEABLE_COLS';
        END IF;

        l_names := SUBSTRB(l_names, 1, LENGTHB(l_names)-2);

        fnd_message.set_name('AR', l_message_name);
        fnd_message.set_token('COLUMN',l_names);
        fnd_msg_pub.add;
        x_return_status := FND_API.G_RET_STS_ERROR;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'areSSTColumnsUpdeable (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

END areSSTColumnsUpdeable;

/**
 * PRIVATE PROCEDURE updateExceptions
 *
 * DESCRIPTION
 *   Update exception table which is used to trace data source
 *   for each restricted attribute.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * IN:
 *   p_create_update_sst_flag       Create / update SST profile flag.
 *   p_party_id                     Party id.
 *   p_data_source_type             Data source type.
 *   p_updatable_flag_list          A list of updatable property.
 *   p_exception_type_list          A list of exception type.
 *   p_sst_value_is_not_null_list   A 'Y'/'N' list to indicate if the attribute
 *                                  in the SST record is NULL.
 *   p_data_source_list             Data source list.
 *
 * MODIFICATION HISTORY
 *
 *   04-30-2002    Jianying Huang        o Created.
 *   02-28-2005    Rajib Ranjan Borah    o Bug 4156090. Caching logic for G_ATTRIBUTE_DATA_SOURCE
 *                                         is changed.
 */

PROCEDURE updateExceptions (
    p_create_update_sst_flag        IN     VARCHAR2,
    p_party_id                      IN     NUMBER,
    p_data_source_type              IN     VARCHAR2,
    p_name_list                     IN     INDEXVARCHAR30List,
    p_updatable_flag_list           IN     INDEXVARCHAR1List,
    p_exception_type_list           IN     INDEXVARCHAR30List,
    p_sst_value_is_not_null_list    IN     INDEXVARCHAR1List,
    p_data_source_list              IN     INDEXVARCHAR30List
) IS

    i_entity_attr_id                INDEXIDList;
    i_entity_attr_id1                INDEXIDList;
    i_exception_type                INDEXVARCHAR30List;
    i_real_data_source              INDEXVARCHAR30List;
    i_winner                        INDEXVARCHAR30List;
    l_winner                        VARCHAR2(30);
    l_real_data_source              VARCHAR2(30);
    i                               NUMBER;
    j                               NUMBER;
    k                               NUMBER;
    l_data_source_type              VARCHAR2(30) := p_data_source_type;
    l_max                           NUMBER := 0;
    l_debug_prefix                  VARCHAR2(30) := '';
    l_pos2                          NUMBER;
    l_pos1                          NUMBER;

BEGIN

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'updateExceptions (+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;
    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_message=>'p_create_update_sst_flag = '||p_create_update_sst_flag,
                                  p_prefix =>l_debug_prefix,
                                  p_msg_level=>fnd_log.level_statement);
    END IF;

    IF p_data_source_type = G_MISS_ACTUAL_CONTENT_SOURCE THEN
      l_data_source_type := G_MISS_CONTENT_SOURCE_TYPE;
    END IF;

    -- we always do insert into the exception table if we are creating
    -- a SST profile.

    IF p_create_update_sst_flag = 'C' THEN

      l_max := get_max(
                 p_sst_value_is_not_null_list.LAST,
                 p_name_list.LAST,
                 p_updatable_flag_list.LAST);

      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
          hz_utility_v2pub.debug( p_message   => 'L_MAX = '|| to_char(l_max),
                                  p_prefix    => l_debug_prefix,
                                  p_msg_level => fnd_log.level_statement);
      END IF;
      i := 1;  j := 0; k :=0;
      WHILE i <= l_max LOOP

        IF G_ATTRIBUTE_DATA_SOURCE.EXISTS(i) THEN
	  l_winner := 'SST';

          -- l_winner :=
           -- SUBSTRB(G_ATTRIBUTE_DATA_SOURCE(i),1,INSTRB(G_ATTRIBUTE_DATA_SOURCE(i),',')-1);

	  -- Bug 4156090.
	  -- Caching logic of G_ATTRIBUTE_DATA_SOURCE is changed.

         IF p_updatable_flag_list.EXISTS(i) AND
             p_updatable_flag_list(i) = 'Y'
         THEN
           IF  p_exception_type_list.EXISTS(i) AND p_exception_type_list(i) = 'MRR' THEN
              l_winner := l_data_source_type;
	   ELSE
              l_pos2 := instrb(G_ATTRIBUTE_DATA_SOURCE(i),':1,');
	      l_pos1 := instrb(G_ATTRIBUTE_DATA_SOURCE(i),',',-(lengthb(G_ATTRIBUTE_DATA_SOURCE(i))-l_pos2),1);
	      l_winner := G_ORIG_SYSTEM_LIST(substrb(G_ATTRIBUTE_DATA_SOURCE(i),l_pos1+1,l_pos2-l_pos1-1));
	   END IF;
           l_real_data_source := l_data_source_type;

	   IF p_exception_type_list.EXISTS(i) AND p_exception_type_list(i) = 'MRR' THEN

		k := k+1;
		i_entity_attr_id1(k) := i;
              G_EXCEPTION_TYPE(i) := 'MRR';
              G_REAL_DATA_SOURCE(i) := l_real_data_source;
	      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	         hz_utility_v2pub.debug(p_message=>'attribute_id = ' || i || ', L_WINNER = '||
                                  l_winner||', ex = '||G_EXCEPTION_TYPE(i),
                                  p_prefix =>l_debug_prefix,
                                  p_msg_level=>fnd_log.level_statement);
              END IF;
           ELSIF l_winner <>  l_real_data_source THEN
              j := j+1;
              i_entity_attr_id(j) := i;
              IF p_exception_type_list.EXISTS(i) AND
                 p_exception_type_list(i) IS NOT NULL
              THEN
                i_exception_type(j) := p_exception_type_list(i);
              ELSE
                i_exception_type(j) := 'Migration';
              END IF;
              i_real_data_source(j) := l_real_data_source;
              G_EXCEPTION_TYPE(j) := i_exception_type(j);
              G_REAL_DATA_SOURCE(j) := l_real_data_source;
	      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	         hz_utility_v2pub.debug(p_message=>'attribute_id = ' || i || ', L_WINNER = '||
                                  l_winner||', ex = '||G_EXCEPTION_TYPE(j),
                                  p_prefix =>l_debug_prefix,
                                  p_msg_level=>fnd_log.level_statement);
              END IF;
           END IF;
         ELSIF ((p_sst_value_is_not_null_list.EXISTS(i) AND
                  p_sst_value_is_not_null_list(i) = 'Y') OR
                 p_name_list.EXISTS(i)) AND
                (NOT p_updatable_flag_list.EXISTS(i) OR
                 p_updatable_flag_list(i) = 'N')
         THEN
            l_real_data_source := G_MISS_CONTENT_SOURCE_TYPE;
	    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	       hz_utility_v2pub.debug(p_message=>'attribute_id = ' || i || ', L_WINNER = '||
                                  l_winner||', ex = migration',
                                  p_prefix =>l_debug_prefix,
                                  p_msg_level=>fnd_log.level_statement);
            END IF;
            IF l_winner <> l_real_data_source THEN
              j := j+1;
              i_entity_attr_id(j) := i;
              i_exception_type(j) := 'Migration';
              i_real_data_source(j) := l_real_data_source;
              G_EXCEPTION_TYPE(i) := 'Migration';
              G_REAL_DATA_SOURCE(i) := l_real_data_source;
          END IF;
        END IF;
        END IF;

        i := i+1;
      END LOOP;

 FORALL i IN 1..k
        UPDATE hz_win_source_exceps
        SET content_source_type = l_data_source_type,
--            exception_type = i_exception_type(i),
            last_updated_by = hz_utility_v2pub.last_updated_by,
            last_update_login = hz_utility_v2pub.last_update_login,
            last_update_date = SYSDATE
        WHERE party_id = p_party_id
        AND entity_attr_id = i_entity_attr_id1(i);
--        AND content_source_type <> i_real_data_source(i)
--        AND i_real_data_source(i) <> i_winner(i);

      FORALL i IN 1..j
        INSERT INTO hz_win_source_exceps (
          party_id,
          entity_attr_id,
          content_source_type,
          exception_type,
          created_by,
          creation_date,
          last_update_login,
          last_update_date,
          last_updated_by
        ) --VALUES (
-- Bug 4244112 : insert only if it is Rank attribute
	SELECT
          p_party_id,
          i_entity_attr_id(i),
          i_real_data_source(i),
          i_exception_type(i),
          hz_utility_v2pub.created_by,
          SYSDATE,
          hz_utility_v2pub.last_update_login,
          SYSDATE,
          hz_utility_v2pub.last_updated_by
	FROM hz_select_data_sources
	WHERE ranking > 0
	and content_source_type = 'USER_ENTERED'
	and entity_attr_id = i_entity_attr_id(i)
	and i_exception_type(i) <> 'MRN';

    ELSE -- p_create_update_sst_flag = 'U'
	l_real_data_source := l_data_source_type;
      i := p_updatable_flag_list.FIRST; j := 0;
      WHILE i <= p_updatable_flag_list.LAST LOOP
        IF p_updatable_flag_list(i) = 'Y' THEN
          j := j + 1;

          i_entity_attr_id(j) := i;
          IF p_exception_type_list.EXISTS(i) AND
             p_exception_type_list(i) IS NOT NULL
          THEN
            i_exception_type(j) := p_exception_type_list(i);
          ELSE
            i_exception_type(j) := 'Migration';
          END IF;
          IF p_data_source_list.EXISTS(i) AND
             p_data_source_list(i) IS NOT NULL
          THEN
            i_real_data_source(j) := p_data_source_list(i);
          ELSE
            i_real_data_source(j) := l_data_source_type;
          END IF;
          G_EXCEPTION_TYPE(i) := i_exception_type(j);
          G_REAL_DATA_SOURCE(i) := i_real_data_source(j);

          -- Bug 4156090.
	  -- Caching logic for G_ATTRIBUTE_DATA_SOURCE is changed.

          --i_winner(j) :=
            --SUBSTRB(G_ATTRIBUTE_DATA_SOURCE(i),1,INSTRB(G_ATTRIBUTE_DATA_SOURCE(i),',')-1);
          -- Bug 4156090 : for Date attributes, winner data source is same as
	  --               the passed in actual_content_source.
           IF  p_exception_type_list.EXISTS(i) AND (p_exception_type_list(i) = 'MRR'  OR p_exception_type_list(i) = 'MRN')THEN
		i_winner(j) := l_data_source_type;
	   ELSE
                l_pos2 := instrb(G_ATTRIBUTE_DATA_SOURCE(i),':1,');
    	        l_pos1 := instrb(G_ATTRIBUTE_DATA_SOURCE(i),',',-(lengthb(G_ATTRIBUTE_DATA_SOURCE(i))-l_pos2),1);
     	        i_winner(j) := G_ORIG_SYSTEM_LIST(substrb(G_ATTRIBUTE_DATA_SOURCE(i),l_pos1+1,l_pos2-l_pos1-1));
	   END IF;

        END IF;
        i := p_updatable_flag_list.NEXT(i);
      END LOOP;
      -- Debug info.
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
          FOR i IN 1..j LOOP
            hz_utility_v2pub.debug(p_message=>i_entity_attr_id(i)||' : exp_type = '||i_exception_type(i)||
                                                ', winner = '||i_winner(i),
                                  p_prefix =>l_debug_prefix,
                                  p_msg_level=>fnd_log.level_statement);
           END LOOP;
      END IF;

      FORALL i IN 1..j
        DELETE hz_win_source_exceps
        WHERE party_id = p_party_id
        AND entity_attr_id = i_entity_attr_id(i)
        AND i_real_data_source(i) = i_winner(i)
	AND exception_type <> 'MRR';

      IF j > 0 THEN
        -- Debug info.
        IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_message=>'Delete '||SQL%ROWCOUNT||' records',
                                  p_prefix =>l_debug_prefix,
                                  p_msg_level=>fnd_log.level_statement);
        END IF;
      END IF;

      FOR i IN 1..j LOOP
	IF i_exception_type(i) = 'MRR' THEN

        UPDATE hz_win_source_exceps
        SET content_source_type = l_real_data_source,
            exception_type = i_exception_type(i),
            last_updated_by = hz_utility_v2pub.last_updated_by,
            last_update_login = hz_utility_v2pub.last_update_login,
            last_update_date = SYSDATE
        WHERE party_id = p_party_id
        AND entity_attr_id = i_entity_attr_id(i);

	ELSE
        UPDATE hz_win_source_exceps
        SET content_source_type = l_real_data_source,
            exception_type = i_exception_type(i),
            last_updated_by = hz_utility_v2pub.last_updated_by,
            last_update_login = hz_utility_v2pub.last_update_login,
            last_update_date = SYSDATE
        WHERE party_id = p_party_id
        AND entity_attr_id = i_entity_attr_id(i)
        AND content_source_type <> i_real_data_source(i)
        AND i_real_data_source(i) <> i_winner(i)
	AND i_exception_type(i) <> 'MRN';
	END IF;
      END LOOP;

      IF j > 0 THEN
        -- Debug info.
        IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_message=>'Update '||SQL%ROWCOUNT||' records',
                                  p_prefix =>l_debug_prefix,
                                  p_msg_level=>fnd_log.level_statement);
        END IF;
      END IF;

      FOR i IN 1..j LOOP
        IF i_real_data_source(i) <> i_winner(i) THEN
          INSERT INTO hz_win_source_exceps (
            party_id,
            entity_attr_id,
            content_source_type,
            exception_type,
            created_by,
            creation_date,
            last_update_login,
            last_update_date,
            last_updated_by
          ) SELECT
            p_party_id,
            i_entity_attr_id(i),
            i_real_data_source(i),
            i_exception_type(i),
            hz_utility_v2pub.created_by,
            SYSDATE,
            hz_utility_v2pub.last_update_login,
            SYSDATE,
            hz_utility_v2pub.last_updated_by
          FROM dual
          WHERE NOT EXISTS (
            SELECT 'Y'
            FROM hz_win_source_exceps
            WHERE party_id = p_party_id
            AND entity_attr_id = i_entity_attr_id(i)
	    AND i_exception_type(i) <> 'MRN');

          IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
             hz_utility_v2pub.debug(p_message=>'Insert '||SQL%ROWCOUNT||' records',
                                  p_prefix =>l_debug_prefix,
                                  p_msg_level=>fnd_log.level_statement);
          END IF;
        END IF;
      END LOOP;

    END IF;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'updateExceptions (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

END updateExceptions;

/**
 * PROCEDURE
 *     create_exception.
 *
 * DESCRIPTION
 *     Creates records in HZ_WIN_SOURCE_EXCEPTIONS when a party (organization/ person)
 *     is created from non-user_entered source systems and no prior user-entered profile
 *     exist for that party.
 *
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *     HZ_MIXNM_API_DYNAMIC_PKG.initAttributeList
 *     HZ_MIXNM_UTILITY.cacheSetupForPartyProfiles
 *     HZ_MIXNM_UTILITY.getEntityAttrId
 *     HZ_MIXNM_UTILITY.getDataSourceRanking
 *
 * ARGUMENTS
 *   IN:
 *     p_party_type                Either 'ORGANIZATION' or 'PERSON'
 *     p_organization_rec
 *     p_person_rec
 *     p_third_party_content_source
 *
 *   OUT:
 *
 * NOTES
 *     This will be called only from HZ_PARTY_V2PUB.do_create_party.
 *     And only when a new party is created by a non-user_entered source system.
 *
 * MODIFICATION HISTORY
 *
 *   12-30-2004    Rajib Ranjan Borah  o SSM SST Integration and Extension. Created.
 */

PROCEDURE create_exceptions (
  p_party_type                   IN      VARCHAR2,
  p_organization_rec             IN      HZ_PARTY_V2PUB.ORGANIZATION_REC_TYPE
                           DEFAULT       HZ_PARTY_V2PUB.G_MISS_ORGANIZATION_REC,
  p_person_rec                   IN      HZ_PARTY_V2PUB.PERSON_REC_TYPE
                           DEFAULT       HZ_PARTY_V2PUB.G_MISS_PERSON_REC,
  p_third_party_content_source   IN      VARCHAR2,
  p_party_id                     IN      NUMBER
)
IS
    l_name_list                  INDEXVARCHAR30List;
    l_null_list                  INDEXVARCHAR1List;
    i                            NUMBER;
    third_party_rank             NUMBER;
    user_entered_rank            NUMBER;
    l_entity_name                VARCHAR2(30);
    l_entity_attr_id             NUMBER;
    l_party_id                   NUMBER;
    l_debug_prefix               VARCHAR2(30);
BEGIN

    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'HZ_MIXNM_UTILITY.create_exceptions (+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    IF p_party_type = 'ORGANIZATION' THEN

        HZ_MIXNM_API_DYNAMIC_PKG.initAttributeList
	    (p_create_update_flag     => 'C',
	     p_new_rec                => p_organization_rec,
	     p_old_rec                => HZ_PARTY_V2PUB.G_MISS_ORGANIZATION_REC,
	     x_name_list              => l_name_list,
	     x_new_value_is_null_list => l_null_list);

	 l_entity_name := 'HZ_ORGANIZATION_PROFILES';

    ELSE  -- 'PERSON'

         HZ_MIXNM_API_DYNAMIC_PKG.initAttributeList
	    (p_create_update_flag     => 'C',
	     p_new_rec                => p_person_rec,
	     p_old_rec                => HZ_PARTY_V2PUB.G_MISS_PERSON_REC,
	     x_name_list              => l_name_list,
	     x_new_value_is_null_list => l_null_list);


     	l_entity_name := 'HZ_PERSON_PROFILES';

    END IF;

    cacheSetupForPartyProfiles
        (p_party_id               => p_party_id ,
         p_entity_name            => l_entity_name);

    i := l_name_list.FIRST;
    WHILE i <= l_name_list.LAST LOOP

        l_entity_attr_id := getEntityAttrId
	                        ( p_entity_name    => l_entity_name,
				  p_attribute_name => l_name_list(i));

        third_party_rank :=
	    getDataSourceRanking
	         (p_entity_attr_id        => l_entity_attr_id,
	          p_data_source_type      => p_third_party_content_source );

        IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug(
	        p_message   => 'i= '||i
		               ||' ;l_name_list('||i||')= '||l_name_list(i)
			       ||' ;l_entity_attr_id= '||l_entity_attr_id
			       ||' ;third_party_rank = '||third_party_rank,
                p_prefix    => l_debug_prefix,
                p_msg_level => fnd_log.level_statement);
        END IF;

        IF third_party_rank = -1 THEN
	    -- Ranking type = Most Recent Record (MRR)
	    NULL;
	ELSIF third_party_rank = 1 THEN
	    -- this third party is already the highest ranked.
	    NULL;
	ELSIF third_party_rank = 0 THEN
            INSERT INTO hz_win_source_exceps (
                          party_id,
                          entity_attr_id,
                          content_source_type,
                          exception_type,
                          created_by,
                          creation_date,
                          last_update_login,
                          last_update_date,
                          last_updated_by
                       ) --VALUES (
		-- Bug 4244112 : populate only for rank attributes
			SELECT
                          p_party_id,
                          l_entity_attr_id,
                          G_MISS_CONTENT_SOURCE_TYPE,
                          'Migration',
                          hz_utility_v2pub.created_by,
                          SYSDATE,
                          hz_utility_v2pub.last_update_login,
                          SYSDATE,
                          hz_utility_v2pub.last_updated_by
			FROM hz_select_data_sources
			WHERE ranking > 1
			and content_source_type = 'USER_ENTERED'
			and entity_attr_id = l_entity_attr_id;
	ELSE
	    -- this third party is a selected data source but is not the highest rank.
            INSERT INTO hz_win_source_exceps (
                          party_id,
                          entity_attr_id,
                          content_source_type,
                          exception_type,
                          created_by,
                          creation_date,
                          last_update_login,
                          last_update_date,
                          last_updated_by
                       ) VALUES (
                          p_party_id,
                          l_entity_attr_id,
                          p_third_party_content_source,
                          'Migration',
                          hz_utility_v2pub.created_by,
                          SYSDATE,
                          hz_utility_v2pub.last_update_login,
                          SYSDATE,
                          hz_utility_v2pub.last_updated_by );

	END IF;
	i := l_name_list.NEXT(i);
    END LOOP;

    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'HZ_MIXNM_UTILITY.create_exceptions (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

END create_exceptions;

--------------------------------------------------------------------------
-- public procedures and functions
--------------------------------------------------------------------------

/**
 * FUNCTION FindDataSource
 *
 * DESCRIPTION
 *    Finds real data source based on content_source_type
 *    and actual_content_source. This is for backward
 *    compatibility because even the content_source_type is
 *    obsolete, we can not assume user will not pass the
 *    value into this column anymore.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_content_source_type        Value of obsolete column content_source_type
 *     p_def_content_source_type    Default value of obsolete column content_source_type
 *     p_actual_content_source      Value of new column actual_content_source
 *     p_def_actual_content_source  Default value of new column actual_content_source
 *   OUT:
 *     x_data_source_from           Column name of where real data source is from.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   03-01-2002    Jianying Huang       o Created.
 *   12-31-2004    Rajib Ranjan Borah   o SSM SST Integration and Extension.
 *                                        content_source_type is foreign key to orig_system
 *                                        in hz_orig_systems_b with sst_flag = 'Y'.
 */

FUNCTION FindDataSource (
    p_content_source_type           IN     VARCHAR2,
    p_actual_content_source         IN     VARCHAR2,
    p_def_actual_content_source     IN     VARCHAR2,
    x_data_source_from              OUT    NOCOPY VARCHAR2
) RETURN VARCHAR2 IS

    l_content_source_type           VARCHAR2(30);
    l_actual_content_source         VARCHAR2(30);
    l_final_data_source             VARCHAR2(30);
    l_return_status                 VARCHAR2(1);

    -- SSM SST Integration and Extension
    CURSOR c_valid_content_source_type (p_content_source_type IN VARCHAR2) IS
        SELECT '1'
	FROM   hz_orig_systems_b
	WHERE  orig_system = p_content_source_type
	  AND  sst_flag = 'Y'
	  AND  status = 'A';
   l_exists    VARCHAR2(1)   := 'N';

BEGIN

    IF p_content_source_type = FND_API.G_MISS_CHAR THEN
       l_content_source_type := G_MISS_CONTENT_SOURCE_TYPE;
    ELSE
       l_content_source_type := NVL(p_content_source_type,
                                    G_MISS_CONTENT_SOURCE_TYPE);
    END IF;

    IF p_actual_content_source = FND_API.G_MISS_CHAR THEN
       l_actual_content_source := p_def_actual_content_source;
    ELSE
       l_actual_content_source := NVL(p_actual_content_source,
                                      p_def_actual_content_source);
    END IF;

    -- by default, we use the value of actual_content_source as
    -- the real data source.

    l_final_data_source := l_actual_content_source;
    x_data_source_from := 'actual_content_source';

    -- if user populates content_source_type which is not as the same
    -- as actual_content_source and user does not populates the
    -- actual_content_source, we returns the value of content_source_type
    -- as the real data source.

    IF l_content_source_type <> l_actual_content_source AND
       l_content_source_type <>  G_MISS_CONTENT_SOURCE_TYPE AND
       l_actual_content_source = p_def_actual_content_source
    THEN
      l_final_data_source := l_content_source_type;
      x_data_source_from := 'content_source_type';
    END IF;

    -- real data source much be a valid lookup code of CONTENT_SOURCE_TYPE.

    IF l_final_data_source <> p_def_actual_content_source THEN

    /* SSM SST Integration and Extension
     * Lookup content_source_type is obsoleted.
     * Instead, all content_source_types should be valid orig_systems in HZ_ORIG_SYSTEMS_B
     * with sst_flag = 'Y'.

      HZ_UTILITY_V2PUB.validate_lookup (
        p_column                 => x_data_source_from,
        p_lookup_type            => 'CONTENT_SOURCE_TYPE',
        p_column_value           => l_final_data_source,
        x_return_status          => l_return_status);

      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      */
      OPEN  c_valid_content_source_type(l_final_data_source);
      FETCH c_valid_content_source_type INTO l_exists;
      IF    c_valid_content_source_type%NOTFOUND THEN
          FND_MESSAGE.SET_NAME ('AR','HZ_API_INVALID_CONTENT_SOURCE');
	  FND_MESSAGE.SET_TOKEN('CONTENT_SOURCE',l_final_data_source);
	  FND_MSG_PUB.ADD;
      END IF;
      CLOSE c_valid_content_source_type;

      IF l_exists = 'N' THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

    END IF;

    RETURN l_final_data_source;

END FindDataSource;

/**
 * FUNCTION CheckUserCreationPrivilege
 *
 * DESCRIPTION
 *   Check if user has privilege to create user entered data when
 *   after mix-n-match is enabled.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_entity_name                Entity name. Can not be party profiles.
 *     p_entity_attr_id             Entity id. Entity id is used only for
 *                                  performance consideration. It can speed
 *                                  the query if it is passed.
 *     p_mixnmatch_enabled          'Y'/'N' flag to indicate if mix-n-match
 *                                  if enabled for this entity. You can get
 *                                  the info. via HZ_MIXNM_UTILITY.
 *     p_actual_content_source      Actual content source.
 *   OUT:
 *     x_return_status              Return FND_API.G_RET_STS_ERROR if the
 *                                  user under this site/application/
 *                                  responsibility is not allowed to create
 *                                  user-entered data for this entity.
 *
 * NOTES
 *   The procedure can only be called for other entities like HZ_CONTACT_POINTS,
 *   HZ_LOCATIONS etc. It can not be called on party profiles HZ_ORGANIZATION_PROFILES,
 *   HZ_PERSON_PROFILES.
 *
 * MODIFICATION HISTORY
 *
 *   03-01-2002    Jianying Huang       o Created.
 *   12-31-2004    Rajib Ranjan Borah   o SSM SST Integration and Extension.
 *                                        p_mixnmatch_enabled will not be considered in
 *                                        the IF check as mixnmatch concept is obsoleted
 *                                        for other entities.
 */

PROCEDURE CheckUserCreationPrivilege (
    p_entity_name                   IN     VARCHAR2,
    p_entity_attr_id                IN OUT NOCOPY NUMBER,
    p_mixnmatch_enabled             IN     VARCHAR2,
    p_actual_content_source         IN     VARCHAR2,
    x_return_status                 IN OUT NOCOPY VARCHAR2
) IS
BEGIN

    IF/* NVL(p_mixnmatch_enabled, 'N') = 'Y' AND*/
       p_actual_content_source = G_MISS_CONTENT_SOURCE_TYPE AND
       isEntityUserCreatable(p_entity_name, p_entity_attr_id) = 'N'
    THEN
      /* new message */
      FND_MESSAGE.SET_NAME('AR', 'HZ_DISALLOW_USER_CREATION');
      FND_MESSAGE.SET_TOKEN('ENTITY',
        hz_utility_v2pub.Get_LookupMeaning(
          'AR_LOOKUPS','ENTITY_NAME', p_entity_name));
      FND_MSG_PUB.ADD;
      x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

END CheckUserCreationPrivilege;

/**
 * FUNCTION CheckUserUpdatePrivilege
 *
 * DESCRIPTION
 *   Check if user has privilege to update a third party record.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_actual_content_source      Actual content source.
 *   OUT:
 *     x_return_status              Return FND_API.G_RET_STS_ERROR if the
 *                                  user under this site/application/
 *                                  responsibility is not allowed to create
 *                                  user-entered data for this entity.
 *
 * NOTES
 *   The procedure can only be called for other entities like HZ_CONTACT_POINTS,
 *   HZ_LOCATIONS etc.
 *
 * MODIFICATION HISTORY
 *
 *   03-01-2002    Jianying Huang       o Created.
 *   12-31-2004    Rajib Ranjan Borah   o SSM SST Integration and Extension.
 *                                        Added parameters p_entity_name and p_new_actual_content_source.
 *                                        User overwrite rules will be checked now
 *                                        instead of profile option 'HZ_UPDATE_THIRD_PARTY_DATA'.
 *                                      o If this is a purchased source system throw error straightaway.
 *                                      o Call cacheSetupForOtherEntities first to
 *                                        load the other entities related setup.
 */

PROCEDURE CheckUserUpdatePrivilege (
    p_actual_content_source         IN     VARCHAR2,
    p_new_actual_content_source     IN     VARCHAR2,
    p_entity_name                   IN     VARCHAR2,
    x_return_status                 IN OUT NOCOPY VARCHAR2
) IS
  l_entity_attr_id                  NUMBER;
  l_entity_name                     VARCHAR2(30);
BEGIN
--  Bug 4226199 : initialize x_return_status
--x_return_status := FND_API.G_RET_STS_SUCCESS;

 /* SSM SST Integration and Extension
  *
    IF p_actual_content_source <> G_MISS_CONTENT_SOURCE_TYPE AND
       NVL(FND_PROFILE.value('HZ_UPDATE_THIRD_PARTY_DATA'), 'N') = 'N'
    THEN
  */
      /* new message */
 /*   FND_MESSAGE.SET_NAME('AR', 'HZ_NOTALLOW_UPDATE_THIRD_PARTY');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  */

    -- SSM SST Integration and Extension
    -- If the actual_content_sources match or if the existing record is 'USER_ENTERED' then return.
    IF (NVL(p_new_actual_content_source,G_MISS_CONTENT_SOURCE_TYPE) = p_actual_content_source OR
        p_actual_content_source = G_MISS_CONTENT_SOURCE_TYPE)
    THEN
        RETURN;
    END IF;

    IF HZ_UTILITY_V2PUB.is_purchased_content_source(p_actual_content_source) = 'N' THEN
        -- Spoke source system can be updated by other source systems.
	-- However users can update spoke source systems only if rules allow it to.
        IF (p_new_actual_content_source <> G_MISS_CONTENT_SOURCE_TYPE
	    AND p_new_actual_content_source IS NOT NULL)
	THEN
	    RETURN;
	END IF;

        IF p_entity_name = 'HZ_FINANCIAL_NUMBERS' THEN
            l_entity_name := 'HZ_FINANCIAL_REPORTS';
        ELSIF p_entity_name = 'HZ_PARTY_SITES' THEN
            l_entity_name := 'HZ_LOCATIONS';
	ELSE
	    l_entity_name := p_entity_name;
        END IF;

        cacheSetupForOtherEntities(TRUE);

        l_entity_attr_id := G_ENTITY_ID( getIndex( p_list => G_ENTITY_NAME,
	    			                   p_name => l_entity_name));

        IF G_OTHER_ENT_USER_OVERWRITE.EXISTS(l_entity_attr_id) THEN
            IF INSTRB(G_OTHER_ENT_USER_OVERWRITE(l_entity_attr_id),
	              ','||getIndex( p_list => G_ORIG_SYSTEM_LIST,
		                 p_name => p_actual_content_source)||',',
                      1,
		      1
		      ) <> 0
            THEN
	        RETURN;
	    END IF;
        END IF;
    END IF;

    FND_MESSAGE.SET_NAME('AR', 'HZ_NOTALLOW_UPDATE_THIRD_PARTY');
    FND_MSG_PUB.ADD;
    x_return_status := FND_API.G_RET_STS_ERROR;
    RAISE FND_API.G_EXC_ERROR;

END CheckUserUpdatePrivilege;

/**
 * FUNCTION isDataSourceSelected
 *
 * DESCRIPTION
 *   Internal use only!!!
 *   Return 'Y' if the data source has been selected.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_selected_datasources       A list of selected data sources. You can
 *                                  get it via HZ_MIXNM_UTILITY.
 *     p_actual_content_source      Actual content source.
 *
 * NOTES
 *
 *   *** SSM SST Integration and Extension ***
 *   This function will only be called for profiles as for other entities, the
 *   concept of selected/ deselected data sources is obsoleted.
 *   ***                                   ***
 *
 * MODIFICATION HISTORY
 *
 *   03-01-2002    Jianying Huang      o Created.
 *   07-07-2005    Dhaval Mehta        o Bug 4376604. Changed the signature to p_entity_name
 *                                       instead of p_selected_datasources
 */

FUNCTION isDataSourceSelected(
--  p_selected_datasources          IN     VARCHAR2,
    p_entity_name                   IN     VARCHAR2,
    p_actual_content_source         IN     VARCHAR2
) RETURN VARCHAR2 IS

    l_ret                           VARCHAR2(1) := 'N';
    l_actual_content_source         VARCHAR2(30) := p_actual_content_source;
    l_entity_id                     NUMBER := 0;
BEGIN

    IF p_actual_content_source = G_MISS_ACTUAL_CONTENT_SOURCE THEN
      l_actual_content_source := G_MISS_CONTENT_SOURCE_TYPE;
    END IF;

    IF p_entity_name = 'PERSON' THEN
        l_entity_id := G_PERSON_PROFILE_ID;
    ELSIF p_entity_name = 'ORGANIZATION' THEN
       l_entity_id := G_ORGANIZATION_PROFILE_ID;
    END IF;

   /* IF INSTRB(p_selected_datasources, ''''||l_actual_content_source||'''') > 0 THEN
      l_ret := 'Y';
    END IF;*/
    IF INSTRB(G_ENTITY_DATA_SOURCE(l_entity_id), ','
                                                 ||getIndex(p_list => G_ORIG_SYSTEM_LIST,
                                                            p_name => l_actual_content_source)
                                                 ||',') > 0 THEN
        l_ret := 'Y';
    END IF;
    RETURN l_ret;

END isDataSourceSelected;

/**
 * FUNCTION ValidateContentSource
 *
 * DESCRIPTION
 *   Validate content source type.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_api_version                API version. 'V1' is for V1 API. 'V2' is for V2 API.
 *     p_create_update_flag         Create or update flag. 'C' is for create. 'U' is for
 *                                  update.
 *     p_check_update_privilege     Check if user has privilege to update third party data.
 *     p_content_source_type        Content source type.
 *     p_old_content_source_type    Old content source type.
 *     p_actual_content_source      Actual content source.
 *     p_old_actual_content_source  Old actual content source.
 *   IN/OUT:
 *     x_return_status              Return FND_API.G_RET_STS_ERROR if the
 *                                  user under this site/application/
 *                                  responsibility is not allowed to create
 *                                  user-entered data for this entity.
 *
 * NOTES
 *   The procedure can only be called for other entities like HZ_CONTACT_POINTS,
 *   HZ_LOCATIONS etc. It can not be called on party profiles HZ_ORGANIZATION_PROFILES,
 *   HZ_PERSON_PROFILES.
 *
 * MODIFICATION HISTORY
 *
 *   03-01-2002    Jianying Huang       o Created.
 *   12-31-2004    Rajib Ranjan Borah   o SSM SST Integration and Extension.
 *                                        Added parameter p_entity_name as user update privileges
 *                                        vary for different entities with different content sources.
 *                                      o validate_nonupdateable for actual_content_source is commented out.
 *                                      o Call CheckUserUpdatePrivilege only if user_entered is trying to
 *                                        update and not if any other content source is trying to.
 */

PROCEDURE ValidateContentSource (
    p_api_version                   IN     VARCHAR2,
    p_create_update_flag            IN     VARCHAR2,
    p_check_update_privilege        IN     VARCHAR2,
    p_content_source_type           IN     VARCHAR2,
    p_old_content_source_type       IN     VARCHAR2,
    p_actual_content_source         IN     VARCHAR2,
    p_old_actual_content_source     IN     VARCHAR2,
    p_entity_name                   IN     VARCHAR2,
    x_return_status                 IN OUT NOCOPY VARCHAR2
) IS

    l_data_source_from              VARCHAR2(30);
    l_content_source_type           VARCHAR2(30) := p_content_source_type;
    l_actual_content_source         VARCHAR2(30) := p_actual_content_source;
    l_debug_prefix                  VARCHAR2(30) := '';

BEGIN

    --enable_debug;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'ValidateContentSource (+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;
    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_message=>'p_api_version = '||p_api_version||', '||
                                        'p_create_update_flag = '||p_create_update_flag||', '||
                                        'p_content_source_type = '||p_content_source_type||','||
                                        'p_old_content_source_type = '||p_old_content_source_type||','||
                                        'p_actual_content_source = '||p_actual_content_source||','||
                                        'p_old_actual_content_source = '||p_old_actual_content_source||','||
                                        'x_return_status = '||x_return_status,
                                  p_prefix =>l_debug_prefix,
                                  p_msg_level=>fnd_log.level_statement);
    END IF;


    -- check if the user has privilege to update third party data
    -- we can trust old_actual_content_source here because the
    -- column is not updatable.

    IF p_create_update_flag = 'U' AND
       p_check_update_privilege = 'Y' AND
       p_old_actual_content_source <> G_MISS_CONTENT_SOURCE_TYPE
    THEN
      CheckUserUpdatePrivilege (
        p_actual_content_source          => p_old_actual_content_source,
	p_new_actual_content_source      => p_actual_content_source,
	p_entity_name                    => p_entity_name,
        x_return_status                  => x_return_status );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;

    -- obsolete content_source_type. Raise error in development site
    -- if user tries to populate value into this column.

    IF NVL(FND_PROFILE.value('HZ_API_ERR_ON_OBSOLETE_COLUMN'), 'N') = 'Y'
    THEN
      HZ_UTILITY_V2PUB.Check_ObsoleteColumn (
        p_api_version                  => p_api_version,
        p_create_update_flag           => p_create_update_flag,
        p_column                       => 'content_source_type',
        p_column_value                 => p_content_source_type,
        p_default_value                => G_MISS_CONTENT_SOURCE_TYPE,
        p_old_column_value             => p_old_content_source_type,
        x_return_status                => x_return_status);

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;

    -- actual_content_source is mandatory. Since it has default value, we
    -- do not need to check mandatory in validation phase.

    -- content_source_type is non-updatable. Since it is obsolete,
    -- we do not need to check it. Instead, we pass NULL to
    -- table handler to make sure it will not be updated.

    -- actual_content_source is non-updatable.

    IF p_create_update_flag = 'U' THEN

      -- Find real data source via comparing content_source_type
      -- and actual_content_source.

      IF (p_api_version = 'V1' AND
          l_actual_content_source = FND_API.G_MISS_CHAR) OR
         (p_api_version = 'V2' AND
          l_actual_content_source IS NULL)
      THEN
        l_actual_content_source :=
          FindDataSource (
            p_content_source_type            => l_content_source_type,
            p_actual_content_source          => NVL(l_actual_content_source,FND_API.G_MISS_CHAR),
            p_def_actual_content_source      => FND_API.G_MISS_CHAR,
            x_data_source_from               => l_data_source_from );

        -- actual_content_source and content_source_type can not be 'SST'.
        -- actual_content_source is lookup code in lookup type CONTENT_SOURCE_TYPE.
        -- Since actual_content_source and content_source_type are non-updatable,
        -- we only need to do checking in creation mode.

        IF l_actual_content_source = G_MISS_ACTUAL_CONTENT_SOURCE THEN
          /* new message */
          FND_MESSAGE.SET_NAME('AR', 'HZ_SST_INVALID_SOURCE');
          FND_MESSAGE.SET_TOKEN('COLUMN', l_data_source_from);
          FND_MSG_PUB.ADD;
          x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

        IF l_data_source_from = 'actual_content_source' THEN
          l_actual_content_source := p_actual_content_source;
        END IF;

        -- Debug info.
        IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_message=>'l_data_source_from = '||l_data_source_from||', '||
                                             'l_actual_content_source = '||l_actual_content_source,
                                  p_prefix =>l_debug_prefix,
                                  p_msg_level=>fnd_log.level_statement);
        END IF;

      END IF;

      -- Debug info.
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_message=>'l_actual_content_source = '||l_actual_content_source||', '||
                                          'p_old_actual_content_source = '||p_old_actual_content_source||', '||
                                          'l_data_source_from = '||l_data_source_from,
                                  p_prefix =>l_debug_prefix,
                                  p_msg_level=>fnd_log.level_statement);
      END IF;


      IF (p_api_version = 'V1' AND
          l_actual_content_source IS NULL) OR
         (p_api_version = 'V2' AND
          l_actual_content_source = FND_API.G_MISS_CHAR)
      THEN
        FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_NONUPDATEABLE_TO_NULL' );
        FND_MESSAGE.SET_TOKEN( 'COLUMN', 'actual_content_source' );
        FND_MSG_PUB.ADD;
        x_return_status := FND_API.G_RET_STS_ERROR;

    -- SSM SST Integration and Extension
    -- Actual content source is updateable for SSM enabled entities like 'HZ_CONTACT_POINTS'
    -- ,'HZ_LOCATIONS' and 'HZ_PARTY_SITES'.
    -- For other entities, use the new value of actual content source to check privilege.
    -- The table handlers will not update the actual_content_source for such entities.

    /*  ELSIF (p_api_version = 'V1' AND
          l_actual_content_source IS NOT NULL AND
          l_actual_content_source <> FND_API.G_MISS_CHAR) OR
         (p_api_version = 'V2' AND
          l_actual_content_source IS NOT NULL)
      THEN
        HZ_UTILITY_V2PUB.validate_nonupdateable (
          p_column                 => 'actual_content_source',
          p_column_value           => l_actual_content_source,
          p_old_column_value       => p_old_actual_content_source,
          x_return_status          => x_return_status);
    */
      END IF;
    END IF;

    -- Debug info.
    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_message=>'x_return_status = '||x_return_status,
                                  p_prefix =>l_debug_prefix,
                                  p_msg_level=>fnd_log.level_statement);
    END IF;
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'ValidateContentSource (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;


    --disable_debug;

END ValidateContentSource;

/**
 * FUNCTION AssignDataSourceDuringCreation
 *
 * DESCRIPTION
 *   Assign data source during entity creation. Check validity of the data
 *   source and check if user has privilege to create user-entered data.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_entity_name                Entity name. Can not be party profiles.
 *     p_entity_attr_id             Entity id. Entity id is used only for
 *                                  performance consideration. It can speed
 *                                  the query if it is passed.
 *     p_mixnmatch_enabled          'Y'/'N' flag to indicate if mix-n-match
 *                                  if enabled for this entity. You can get
 *                                  the info. via HZ_MIXNM_UTILITY.
 *     p_selected_datasources       A list of selected data sources. You can
 *                                  get it via HZ_MIXNM_UTILITY.
 *     p_content_source_type        Content source type.
 *     p_actual_content_source      Actual content source.
 *   OUT:
 *     x_is_datasource_selected     Return 'Y'/'N' to indicate if the data
 *                                  source is visible.
 *     x_return_status              Return FND_API.G_RET_STS_ERROR if any
 *                                  validation fails.
 *
 * NOTES
 *   The procedure can only be called for other entities like HZ_CONTACT_POINTS,
 *   HZ_LOCATIONS etc. It can not be called on party profiles HZ_ORGANIZATION_PROFILES,
 *   HZ_PERSON_PROFILES.
 *
 * MODIFICATION HISTORY
 *
 *   03-01-2002    Jianying Huang       o Created.
 *   01-03-2005    Rajib Ranjan Borah   o SSM SST Integration and Extension.
 *                                        x_is_datasource_selected will be set to 'Y'
 *                                        always.
 *                                        Actually parameters p_mixnmatch_enabled,
 *                                        p_selected_data_sources and x_is_datasource_selected
 *                                        are redundant and are retained for back-ward compatibility.
 */

PROCEDURE AssignDataSourceDuringCreation (
    p_entity_name                   IN     VARCHAR2,
    p_entity_attr_id                IN OUT NOCOPY NUMBER,
    p_mixnmatch_enabled             IN     VARCHAR2,
    p_selected_datasources          IN     VARCHAR2,
    p_content_source_type           IN OUT NOCOPY VARCHAR2,
    p_actual_content_source         IN OUT NOCOPY VARCHAR2,
    x_is_datasource_selected        OUT    NOCOPY VARCHAR2,
    x_return_status                 IN OUT NOCOPY VARCHAR2,
    p_api_version                   IN     VARCHAR2
) IS

    l_data_source_from              VARCHAR2(30);
    l_debug_prefix                  VARCHAR2(30) := '';

BEGIN

    -- obsolete content_source_type. Raise error in development site
    -- if user tries to populate value into this column.

    IF NVL(FND_PROFILE.value('HZ_API_ERR_ON_OBSOLETE_COLUMN'), 'N') = 'Y'
    THEN
      HZ_UTILITY_V2PUB.Check_ObsoleteColumn (
        p_api_version                  => p_api_version,
        p_create_update_flag           => 'C',
        p_column                       => 'content_source_type',
        p_column_value                 => p_content_source_type,
        p_default_value                => G_MISS_CONTENT_SOURCE_TYPE,
        p_old_column_value             => null,
        x_return_status                => x_return_status);

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- Debug info.
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_message=>'p_api_version = '||p_api_version||', '||
                                          'p_content_source_type = '||p_content_source_type||','||
                                          'x_return_status = '||x_return_status,
                                  p_prefix =>l_debug_prefix,
                                  p_msg_level=>fnd_log.level_statement);
      END IF;
    END IF;

    -- Find real data source via comparing content_source_type
    -- and actual_content_source.

    p_actual_content_source :=
      FindDataSource (
        p_content_source_type                   => p_content_source_type,
        p_actual_content_source                 => NVL(p_actual_content_source,FND_API.G_MISS_CHAR),
        p_def_actual_content_source             => FND_API.G_MISS_CHAR,
        x_data_source_from                      => l_data_source_from );

    IF p_actual_content_source = FND_API.G_MISS_CHAR THEN
      p_actual_content_source := G_MISS_CONTENT_SOURCE_TYPE;
    END IF;

    -- actual_content_source and content_source_type can not be 'SST'.
    -- actual_content_source is lookup code in lookup type CONTENT_SOURCE_TYPE.
    -- Since actual_content_source and content_source_type are non-updatable,
    -- we only need to do checking in creation mode.

    IF p_actual_content_source = G_MISS_ACTUAL_CONTENT_SOURCE THEN
      /* new message */
      FND_MESSAGE.SET_NAME('AR', 'HZ_SST_INVALID_SOURCE');
      FND_MESSAGE.SET_TOKEN('COLUMN', l_data_source_from);
      FND_MSG_PUB.ADD;
      x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

    -- Check if user has privilege to create user entered data.

    IF/* NVL(p_mixnmatch_enabled, 'N') = 'Y' AND*/
       p_actual_content_source = G_MISS_CONTENT_SOURCE_TYPE
    THEN
      CheckUserCreationPrivilege (
        p_entity_name                  => p_entity_name,
        p_entity_attr_id               => p_entity_attr_id,
        p_mixnmatch_enabled            => p_mixnmatch_enabled,
        p_actual_content_source        => p_actual_content_source,
        x_return_status                => x_return_status );
    END IF;

    -- reset the content_source_type to 'USER_ENTERED' to take care
    -- of extra where clause 'content_source_type = 'USER_ENTERED''
    -- in the existing code.

-- SSM SST Integration and Extension
-- The concept of selected/de-selected data sources is obsoleted for other entities.
-- Therefore return 'Y' always.
    x_is_datasource_selected :='Y';
/*      isDataSourceSelected(
        p_selected_datasources         => p_selected_datasources,
        p_actual_content_source        => p_actual_content_source );
 */

    p_content_source_type := G_MISS_CONTENT_SOURCE_TYPE;

END AssignDataSourceDuringCreation;

/**
 * FUNCTION isMixNMatchEnabled
 *
 * DESCRIPTION
 *    Is mix-n-match is enabled in the given entity.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_entity_name                 Entity name.
 *     p_called_from_policy_function A flag to indicate if the procedure is called
 *                                   from policy function.
 *   IN/OUT:
 *     p_entity_attr_id              Entity Id.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   05-01-2002    Jianying Huang       o Created
 *   01-03-2005    Rajib Ranjan Borah   o SSM SST Integration and Extension.
 *                                        This should not be called for other entities.
 *                                        Nevertheless return 'Y' always for backward compatibility.
 */

FUNCTION isMixNMatchEnabled (
    p_entity_name                   IN     VARCHAR2,
    p_entity_attr_id                IN OUT NOCOPY NUMBER,
    p_called_from_policy_function   IN     VARCHAR2
) RETURN VARCHAR2 IS

    l_entity_name                   VARCHAR2(30) := p_entity_name;
    l_return                        VARCHAR2(1);
    l_src_selected                  VARCHAR2(1) := 'N';

BEGIN
     -- SSM SST Integration and Extension
     IF p_entity_name NOT IN ('HZ_ORGANIZATION_PROFILES','HZ_PERSON_PROFILES')
     THEN
         RETURN 'Y';
     END IF;

    -- load all entities related setups and cache them.
    cacheSetupForOtherEntities;

    IF p_entity_attr_id IS NULL OR
       p_entity_attr_id = 0
    THEN
      IF p_entity_name = 'HZ_ORGANIZATION_PROFILES' THEN
        p_entity_attr_id := G_ORGANIZATION_PROFILE_ID;
      ELSIF p_entity_name = 'HZ_PERSON_PROFILES' THEN
        p_entity_attr_id := G_PERSON_PROFILE_ID;
    /*ELSE
        IF p_entity_name = 'HZ_PARTY_SITES' THEN
          l_entity_name := 'HZ_LOCATIONS';
        ELSIF p_entity_name = 'HZ_FINANCIAL_NUMBERS' THEN
          l_entity_name := 'HZ_FINANCIAL_REPORTS';
        END IF;
        p_entity_attr_id := getEntityAttrId(l_entity_name);

       */
      END IF;
    END IF;

    IF p_entity_attr_id = 0 THEN
      RETURN 'N';
    END IF;

    -- first find out if the value is cached. If it is not,
    -- check if the SST policy exists on this entity.

    IF G_MIXNM_ENABLED_FLAG.EXISTS(p_entity_attr_id) AND
       G_MIXNM_ENABLED_FLAG(p_entity_attr_id) IS NOT NULL
    THEN
       -- return cached value.
       RETURN G_MIXNM_ENABLED_FLAG(p_entity_attr_id);
    ELSE

      IF p_entity_name = 'HZ_ORGANIZATION_PROFILES' THEN
        l_return := NVL(fnd_profile.value('HZ_ORG_PROF_MIXNMATCH_ENABLED'), 'N');
      ELSIF p_entity_name = 'HZ_PERSON_PROFILES' THEN
        l_return := NVL(fnd_profile.value('HZ_PER_PROF_MIXNMATCH_ENABLED'), 'N');
      ELSE
        IF p_called_from_policy_function = 'Y' THEN
          l_return := 'Y';
        ELSE
          -- get AR schema name.
          IF G_AR_SCHEMA_NAME IS NULL THEN
            G_AR_SCHEMA_NAME := hz_utility_v2pub.Get_SchemaName('AR');
          END IF;

          -- check if policy exists.
          -- bug fix 2731008
          BEGIN
            select 'Y' into l_src_selected
            from hz_select_data_sources d, hz_entity_attributes e
            where e.entity_attr_id = d.entity_attr_id
              and UPPER(e.entity_name) = UPPER(p_entity_name)
              and d.content_source_type <> G_MISS_CONTENT_SOURCE_TYPE
              and d.ranking > 0
              and rownum =1;
          EXCEPTION
              WHEN NO_DATA_FOUND THEN
              null;
          END;

          l_return := l_src_selected;

/*
          IF fnd_access_control_util.Policy_Exists (
               G_AR_SCHEMA_NAME, p_entity_name, 'content_source_type_sec' ) = 'FALSE'
          THEN
            l_return := 'N';
          ELSE
            l_return := 'Y';
          END IF;
*/
        END IF;
      END IF;

      -- cache the value.
      G_MIXNM_ENABLED_FLAG(p_entity_attr_id) := l_return;
    END IF;

    RETURN l_return;

END isMixNMatchEnabled;

/**
 * PROCEDURE updateSSTProfile
 *
 * DESCRIPTION
 *    Return new SST record to create / update SST profile.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_create_update_flag         Create update flag.
 *     p_create_update_sst_flag     Create update SST profile flag.
 *     p_raise_error_flag           Raise error flag.
 *     p_party_type                 Party type.
 *     p_party_id                   Party Id.
 *     p_new_person_rec             New person record.
 *     p_old_person_rec             New person record.
 *     p_sst_person_rec             Current SST person record.
 *     p_new_organization_rec       New organization record.
 *     p_old_organization_rec       New organization record.
 *     p_sst_organization_rec       Current SST organization record.
 *     p_data_source_type           Comming data source type.
 *  IN/OUT:
 *     p_new_sst_person_rec         New SST person record.
 *     p_new_sst_organization_rec   New SST organization record.
 *     x_return_status              Return status.
 *
 * NOTES
 *   The procedure should only be called if the mix-n-match is enable for
 *   the entity.
 *
 * MODIFICATION HISTORY
 *
 *   05-01-2002    Jianying Huang   o Created
 */

PROCEDURE updateSSTProfile (
    p_create_update_flag            IN     VARCHAR2,
    p_create_update_sst_flag        IN     VARCHAR2,
    p_raise_error_flag              IN     VARCHAR2,
    p_party_type                    IN     VARCHAR2,
    p_party_id                      IN     NUMBER,
    p_new_person_rec                IN     HZ_PARTY_V2PUB.PERSON_REC_TYPE,
    p_old_person_rec                IN     HZ_PARTY_V2PUB.PERSON_REC_TYPE,
    p_sst_person_rec                IN     HZ_PARTY_V2PUB.PERSON_REC_TYPE,
    p_new_sst_person_rec            IN OUT NOCOPY HZ_PARTY_V2PUB.PERSON_REC_TYPE,
    p_new_organization_rec          IN     HZ_PARTY_V2PUB.ORGANIZATION_REC_TYPE,
    p_old_organization_rec          IN     HZ_PARTY_V2PUB.ORGANIZATION_REC_TYPE,
    p_sst_organization_rec          IN     HZ_PARTY_V2PUB.ORGANIZATION_REC_TYPE,
    p_new_sst_organization_rec      IN OUT NOCOPY HZ_PARTY_V2PUB.ORGANIZATION_REC_TYPE,
    p_data_source_type              IN     VARCHAR2,
    x_return_status                 IN OUT NOCOPY VARCHAR2
) IS
BEGIN

    IF p_party_type = 'PERSON' THEN
      updatePerSSTProfile (
        p_create_update_flag               => p_create_update_flag,
        p_create_update_sst_flag           => p_create_update_sst_flag,
        p_raise_error_flag                 => p_raise_error_flag,
        p_party_id                         => p_party_id,
        p_new_person_rec                   => p_new_person_rec,
        p_old_person_rec                   => p_old_person_rec,
        p_sst_person_rec                   => p_sst_person_rec,
        p_new_sst_person_rec               => p_new_sst_person_rec,
        p_data_source_type                 => p_data_source_type,
        x_return_status                    => x_return_status );
    ELSIF p_party_type = 'ORGANIZATION' THEN
      updateOrgSSTProfile (
        p_create_update_flag               => p_create_update_flag,
        p_create_update_sst_flag           => p_create_update_sst_flag,
        p_raise_error_flag                 => p_raise_error_flag,
        p_party_id                         => p_party_id,
        p_new_organization_rec             => p_new_organization_rec,
        p_old_organization_rec             => p_old_organization_rec,
        p_sst_organization_rec             => p_sst_organization_rec,
        p_new_sst_organization_rec         => p_new_sst_organization_rec,
        p_data_source_type                 => p_data_source_type,
        x_return_status                    => x_return_status );
    END IF;

END updateSSTProfile;

/**
 * PROCEDURE updateSSTPerProfile
 *
 * DESCRIPTION
 *    Return new SST record to create / update person SST profile.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_create_update_flag         Create update flag.
 *     p_create_update_sst_flag     Create update SST profile flag.
 *     p_raise_error_flag           Raise error flag.
 *     p_party_type                 Party type.
 *     p_party_id                   Party Id.
 *     p_new_person_rec             New person record.
 *     p_old_person_rec             New person record.
 *     p_sst_person_rec             Current SST person record.
 *     p_data_source_type           Comming data source type.
 *   IN/OUT:
 *     p_new_sst_person_rec         New SST person record.
 *     x_return_status              Return status.
 *
 * NOTES
 *   The procedure should only be called if the mix-n-match is enable for
 *   the entity.
 *
 * MODIFICATION HISTORY
 *
 *   05-01-2002    Jianying Huang   o Created
 */

PROCEDURE updatePerSSTProfile (
    p_create_update_flag            IN     VARCHAR2,
    p_create_update_sst_flag        IN     VARCHAR2,
    p_raise_error_flag              IN     VARCHAR2,
    p_party_id                      IN     NUMBER,
    p_new_person_rec                IN     HZ_PARTY_V2PUB.PERSON_REC_TYPE,
    p_old_person_rec                IN     HZ_PARTY_V2PUB.PERSON_REC_TYPE,
    p_sst_person_rec                IN     HZ_PARTY_V2PUB.PERSON_REC_TYPE,
    p_new_sst_person_rec            IN OUT NOCOPY HZ_PARTY_V2PUB.PERSON_REC_TYPE,
    p_data_source_type              IN     VARCHAR2,
    x_return_status                 IN OUT NOCOPY VARCHAR2
) IS

    l_new_value_is_null_list        INDEXVARCHAR1List;
    l_sst_value_is_null_list        INDEXVARCHAR1List;
    l_sst_value_is_not_null_list    INDEXVARCHAR1List;
    l_updatable_flag_list           INDEXVARCHAR1List;
    l_exception_type_list           INDEXVARCHAR30List;
    l_name_list                     INDEXVARCHAR30List;
    l_data_source_list              INDEXVARCHAR30List;
    l_debug_prefix                  VARCHAR2(30) := '';

BEGIN

    -- Check if API is called in debug mode. If yes, enable debug.
    --enable_debug;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'updatePerSSTProfile (+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- find out those attributes we need to check.

    hz_mixnm_api_dynamic_pkg.initAttributeList(
      p_create_update_flag          => p_create_update_flag,
      p_new_rec                     => p_new_person_rec,
      p_old_rec                     => p_old_person_rec,
      x_name_list                   => l_name_list,
      x_new_value_is_null_list      => l_new_value_is_null_list);

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'initAttributeList (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- if there no attributes have been passed in in the record, we do not
    -- need to do further check.

    IF l_name_list IS NULL OR
       l_name_list.COUNT = 0
    THEN
      -- Debug info.
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_message=>'name list is null. No need to do further check',
                                  p_prefix =>l_debug_prefix,
                                  p_msg_level=>fnd_log.level_statement);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'updatePerSSTColumn (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

      RETURN;
    END IF;

    -- get column Null property.

    hz_mixnm_api_dynamic_pkg.getColumnNullProperty(
      p_sst_rec                       => p_sst_person_rec,
      x_value_is_null_list            => l_sst_value_is_null_list,
      x_value_is_not_null_list        => l_sst_value_is_not_null_list);

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'getColumnNullProperty (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- return a updatable of all of attributes we passed in.

    areSSTColumnsUpdeable (
      p_party_id                      => p_party_id,
      p_entity_name                   => 'HZ_PERSON_PROFILES',
      p_attribute_name_list           => l_name_list,
      p_value_is_null_list            => l_sst_value_is_null_list,
      p_data_source_type              => p_data_source_type,
      x_updatable_flag_list           => l_updatable_flag_list,
      x_exception_type_list           => l_exception_type_list,
      x_return_status                 => x_return_status,
      p_raise_error_flag              => p_raise_error_flag,
      p_known_dict_id                 => 'Y',
      p_new_value_is_null_list      => l_new_value_is_null_list );

    -- set final SST record. API can use this record to create / update
    -- SST record.

    IF p_create_update_sst_flag = 'C' THEN
      hz_mixnm_api_dynamic_pkg.createSSTRecord(
        p_new_data_source             => p_data_source_type,
        p_new_rec                     => p_new_person_rec,
        p_sst_rec                     => p_new_sst_person_rec,
        p_updateable_flag_list        => l_updatable_flag_list,
        p_exception_type_list         => l_exception_type_list);
    ELSE
      hz_mixnm_api_dynamic_pkg.updateSSTRecord(
        p_create_update_flag          => p_create_update_flag,
        p_new_data_source             => p_data_source_type,
        p_new_rec                     => p_new_person_rec,
        p_sst_rec                     => p_new_sst_person_rec,
        p_updateable_flag_list        => l_updatable_flag_list,
        p_exception_type_list         => l_exception_type_list,
        p_new_value_is_null_list      => l_new_value_is_null_list,
        x_data_source_list            => l_data_source_list);
    END IF;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'setSSTRecord (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- update exception table to trace data source for each attribute.

    updateExceptions (
      p_create_update_sst_flag        => p_create_update_sst_flag,
      p_party_id                      => p_party_id,
      p_data_source_type              => p_data_source_type,
      p_name_list                     => l_name_list,
      p_updatable_flag_list           => l_updatable_flag_list,
      p_exception_type_list           => l_exception_type_list,
      p_sst_value_is_not_null_list    => l_sst_value_is_not_null_list,
      p_data_source_list              => l_data_source_list);

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'updatePerSSTProfile (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Check if API is called in debug mode. If yes, disable debug.
    --disable_debug;

END updatePerSSTProfile;

/**
 * PROCEDURE updateSSTOrgProfile
 *
 * DESCRIPTION
 *    Return new SST record to create / update organization SST profile.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_create_update_flag         Create update flag.
 *     p_create_update_sst_flag     Create update SST profile flag.
 *     p_raise_error_flag           Raise error flag.
 *     p_party_type                 Party type.
 *     p_party_id                   Party Id.
 *     p_new_organization_rec       New organization record.
 *     p_old_organization_rec       New organization record.
 *     p_sst_organization_rec       Current SST organization record.
 *     p_data_source_type           Comming data source type.
 *   IN/OUT:
 *     p_new_sst_organization_rec   New SST organization record.
 *     x_return_status              Return status.
 *
 * NOTES
 *   The procedure should only be called if the mix-n-match is enable for
 *   the entity.
 *
 * MODIFICATION HISTORY
 *
 *   05-01-2002    Jianying Huang   o Created
 */

PROCEDURE updateOrgSSTProfile (
    p_create_update_flag            IN     VARCHAR2,
    p_create_update_sst_flag        IN     VARCHAR2,
    p_raise_error_flag              IN     VARCHAR2,
    p_party_id                      IN     NUMBER,
    p_new_organization_rec          IN     HZ_PARTY_V2PUB.ORGANIZATION_REC_TYPE,
    p_old_organization_rec          IN     HZ_PARTY_V2PUB.ORGANIZATION_REC_TYPE,
    p_sst_organization_rec          IN     HZ_PARTY_V2PUB.ORGANIZATION_REC_TYPE,
    p_new_sst_organization_rec      IN OUT NOCOPY HZ_PARTY_V2PUB.ORGANIZATION_REC_TYPE,
    p_data_source_type              IN     VARCHAR2,
    x_return_status                 IN OUT NOCOPY VARCHAR2
) IS

    l_new_organization_rec          HZ_PARTY_V2PUB.ORGANIZATION_REC_TYPE := p_new_organization_rec;
    l_new_value_is_null_list        INDEXVARCHAR1List;
    l_sst_value_is_null_list        INDEXVARCHAR1List;
    l_sst_value_is_not_null_list    INDEXVARCHAR1List;
    l_updatable_flag_list           INDEXVARCHAR1List;
    l_exception_type_list           INDEXVARCHAR30List;
    l_name_list                     INDEXVARCHAR30List;
    l_data_source_list              INDEXVARCHAR30List;
    i                               NUMBER;
    l_debug_prefix                  VARCHAR2(30) := '';

BEGIN

    -- Check if API is called in debug mode. If yes, enable debug.
    --enable_debug;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'updateOrgSSTProfile (+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;
    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_message=>'p_create_update_sst_flag = '||p_create_update_sst_flag,
                                  p_prefix =>l_debug_prefix,
                                  p_msg_level=>fnd_log.level_statement);
    END IF;

    -- find out those attributes we need to check.

    hz_mixnm_api_dynamic_pkg.initAttributeList(
      p_create_update_flag            => p_create_update_flag,
      p_new_rec                       => p_new_organization_rec,
      p_old_rec                       => p_old_organization_rec,
      x_name_list                     => l_name_list,
      x_new_value_is_null_list        => l_new_value_is_null_list);

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'initAttributeList (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- if there no attributes have been passed in in the record, we do not
    -- need to do further check.

    IF l_name_list IS NULL OR
       l_name_list.COUNT = 0
    THEN
      -- Debug info.
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_message=>'name list is null. No need to do further check',
                                  p_prefix =>l_debug_prefix,
                                  p_msg_level=>fnd_log.level_statement);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'updatePerSSTColumn (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

      RETURN;
    END IF;

    -- get column Null property.

    hz_mixnm_api_dynamic_pkg.getColumnNullProperty(
      p_sst_rec                       => p_sst_organization_rec,
      x_value_is_null_list            => l_sst_value_is_null_list,
      x_value_is_not_null_list        => l_sst_value_is_not_null_list);

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'getColumnNullProperty (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- return a updatable of all of attributes we passed in.

    areSSTColumnsUpdeable (
      p_party_id                      => p_party_id,
      p_entity_name                   => 'HZ_ORGANIZATION_PROFILES',
      p_attribute_name_list           => l_name_list,
      p_value_is_null_list            => l_sst_value_is_null_list,
      p_data_source_type              => p_data_source_type,
      x_updatable_flag_list           => l_updatable_flag_list,
      x_exception_type_list           => l_exception_type_list,
      x_return_status                 => x_return_status,
      p_raise_error_flag              => p_raise_error_flag,
      p_known_dict_id                 => 'Y',
      p_new_value_is_null_list      => l_new_value_is_null_list );

    -- set final SST record. API can use this record to create / update
    -- SST record.

    IF p_create_update_sst_flag = 'C' THEN
      hz_mixnm_api_dynamic_pkg.createSSTRecord(
        p_new_data_source             => p_data_source_type,
        p_new_rec                     => p_new_organization_rec,
        p_sst_rec                     => p_new_sst_organization_rec,
        p_updateable_flag_list        => l_updatable_flag_list,
        p_exception_type_list         => l_exception_type_list);
    ELSE
      -- sync data source for sic_code and sic_code_type.

      l_new_organization_rec.sic_code :=
        nvl(l_new_organization_rec.sic_code, p_old_organization_rec.sic_code);
      l_new_organization_rec.sic_code_type :=
        nvl(l_new_organization_rec.sic_code_type, p_old_organization_rec.sic_code_type);

      hz_mixnm_api_dynamic_pkg.updateSSTRecord(
        p_create_update_flag          => p_create_update_flag,
        p_new_data_source             => p_data_source_type,
        p_new_rec                     => l_new_organization_rec,
        p_sst_rec                     => p_new_sst_organization_rec,
        p_updateable_flag_list        => l_updatable_flag_list,
        p_exception_type_list         => l_exception_type_list,
        p_new_value_is_null_list      => l_new_value_is_null_list,
        x_data_source_list            => l_data_source_list);
    END IF;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'setSSTRecord (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- update exception table to trace data source for each attribute.

    updateExceptions (
      p_create_update_sst_flag        => p_create_update_sst_flag,
      p_party_id                      => p_party_id,
      p_data_source_type              => p_data_source_type,
      p_name_list                     => l_name_list,
      p_updatable_flag_list           => l_updatable_flag_list,
      p_exception_type_list           => l_exception_type_list,
      p_sst_value_is_not_null_list    => l_sst_value_is_not_null_list,
      p_data_source_list              => l_data_source_list);

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'updateOrgSSTProfile (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Check if API is called in debug mode. If yes, disable debug.
    --disable_debug;

END updateOrgSSTProfile;

/**
 * PROCEDURE getDictIndexedNameList
 *
 * DESCRIPTION
 *    Split a new list into non-restricted attributes list and restricted
 *    attributes list.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_entity_name                Entity name.
 *     p_name_list                  Attribute name list.
 *   OUT:
 *     x_restricted_name_list       Restricted attributes' name list.
 *     x_nonrestricted_name_list    Non-Restricted attributes' name list.
 *
 * NOTES
 *   The procedure should only be called if the mix-n-match is enable for
 *   the entity.
 *
 * MODIFICATION HISTORY
 *
 *   05-01-2002    Jianying Huang   o Created
 */

PROCEDURE getDictIndexedNameList (
    p_entity_name                   IN     VARCHAR2,
    p_name_list                     IN     INDEXVARCHAR30List,
    x_restricted_name_list          OUT    NOCOPY INDEXVARCHAR30List,
    x_nonrestricted_name_list       OUT    NOCOPY INDEXVARCHAR30List
) IS

    l_entity_attr_id                NUMBER;
    i                               NUMBER;
    j                               NUMBER := 1;
    l_debug_prefix                  VARCHAR2(30) := '';

BEGIN

    -- Check if API is called in debug mode. If yes, enable debug.
    --enable_debug;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'getDictIndexedNameList (+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- load all of related setups and cache them.
    cacheSetupForPartyProfiles(null, p_entity_name);

    -- for each attribute in the list, check if it is in the setup table.
    -- if it is, put it in the restricted_name_list.

    i := p_name_list.FIRST;
    WHILE i <= p_name_list.LAST LOOP
      l_entity_attr_id := getEntityAttrId(p_entity_name, p_name_list(i));

      IF l_entity_attr_id = 0 THEN
        x_nonrestricted_name_list(i) := p_name_list(i);
        j := j + 1;
      ELSE
        x_restricted_name_list(l_entity_attr_id) := p_name_list(i);
      END IF;

      i := p_name_list.NEXT(i);
    END LOOP;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'getDictIndexedNameList (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Check if API is called in debug mode. If yes, disable debug.
    --disable_debug;

END getDictIndexedNameList;

/**
 * PROCEDURE areSSTColumnsUpdeable
 *
 * DESCRIPTION
 *    Return a list to indicate which SST attributes are updatable and which are not.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_party_id                   Party Id.
 *     p_entity_name                Entity name.
 *     p_attribute_name_list        Attribute name list.
 *     p_value_is_null_list         'Y' if the corresponding SST column is null.
 *     p_data_source_type           Comming data source.
 *     p_raise_error_flag           Raise error flag.
 *     p_known_dict_id              'Y' if use knew entity id.
 *   IN/OUT:
 *     x_return_status              Return status.
 *   OUT:
 *     x_updatable_flag_list        Updatable list.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *   The procedure should only be called if the mix-n-match is enable for
 *   the entity.
 *
 *   05-01-2002    Jianying Huang   o Created
 */

PROCEDURE areSSTColumnsUpdeable (
    p_party_id                      IN     NUMBER,
    p_entity_name                   IN     VARCHAR2,
    p_attribute_name_list           IN     INDEXVARCHAR30List,
    p_value_is_null_list            IN     INDEXVARCHAR1List,
    p_data_source_type              IN     VARCHAR2,
    x_updatable_flag_list           OUT    NOCOPY INDEXVARCHAR1List,
    x_return_status                 IN OUT NOCOPY VARCHAR2,
    p_raise_error_flag              IN     VARCHAR2,
    p_known_dict_id                 IN     VARCHAR2
) IS

    l_exception_type_list           INDEXVARCHAR30List;
    l_new_value_is_null_list        INDEXVARCHAR1List;


BEGIN

    -- Check if API is called in debug mode. If yes, enable debug.
    --enable_debug;

    -- return if the attribute name list is empty.

    IF p_attribute_name_list IS NULL OR
       p_attribute_name_list.COUNT = 0
    THEN
      RETURN;
    END IF;

    areSSTColumnsUpdeable (
      p_party_id                    => p_party_id,
      p_entity_name                 => p_entity_name,
      p_attribute_name_list         => p_attribute_name_list,
      p_value_is_null_list          => p_value_is_null_list,
      p_data_source_type            => p_data_source_type,
      x_updatable_flag_list         => x_updatable_flag_list,
      x_exception_type_list         => l_exception_type_list,
      x_return_status               => x_return_status,
      p_raise_error_flag            => p_raise_error_flag,
      p_known_dict_id               => p_known_dict_id,
      p_new_value_is_null_list	    => l_new_value_is_null_list
    );

    -- Check if API is called in debug mode. If yes, disable debug.
    --disable_debug;

END areSSTColumnsUpdeable;

/**
 * PROCEDURE LoadDataSources
 *
 * DESCRIPTION
 *    Load data sources for a given entity.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_entity_name                 Entity name.
 *     p_called_from_policy_function A flag to indicate if the procedure is called
 *                                   from policy function.
 *   IN/OUT:
 *     p_entity_attr_id              Entity Id.
 *     p_mixnmatch_enabled           If the mix-n-match is enabled for this entity.
 *     p_selected_datasources        Select data sources for this entity.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   05-01-2002    Jianying Huang      o Created
 *   07-07-2005    Dhaval Mehta        o Bug 4376604. p_selected_data_sources has been made
 *                                       redundant and has been retained for backward compatibility.
 */

PROCEDURE LoadDataSources (
    p_entity_name                   IN     VARCHAR2,
    p_entity_attr_id                IN OUT NOCOPY NUMBER,
    p_mixnmatch_enabled             IN OUT NOCOPY VARCHAR2,
    p_selected_datasources          IN OUT NOCOPY VARCHAR2,
    p_called_from_policy_function   IN     VARCHAR2
) IS
l_debug_prefix              VARCHAR2(30) := '';
BEGIN

   --enable_debug;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'LoadDataSources (+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    --IF p_mixnmatch_enabled IS NULL THEN
    p_mixnmatch_enabled :=
      isMixNMatchEnabled(p_entity_name, p_entity_attr_id, p_called_from_policy_function);
    --END IF;
    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_message=>'p_mixnmatch_enabled = '||p_mixnmatch_enabled,
                                  p_prefix =>l_debug_prefix,
                                  p_msg_level=>fnd_log.level_statement);
    END IF;

/*
    IF p_mixnmatch_enabled = 'Y' AND
       p_entity_attr_id <> 0 AND
       G_ENTITY_DATA_SOURCE.EXISTS(p_entity_attr_id) AND
       G_ENTITY_DATA_SOURCE(p_entity_attr_id) IS NOT NULL
    THEN
      -- p_entity_attr_id := l_entity_attr_id;
      p_selected_datasources := G_ENTITY_DATA_SOURCE(p_entity_attr_id);
    ELSE
      p_selected_datasources := ''''||G_MISS_CONTENT_SOURCE_TYPE||'''';
    END IF;
*/
    -- Bug 4376604. This parameter has been retained for backward compatibility only.
    p_selected_datasources := NULL;

    -- Debug info.
    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_message=>'p_selected_datasources = '||p_selected_datasources,
                                  p_prefix =>l_debug_prefix,
                                  p_msg_level=>fnd_log.level_statement);
    END IF;
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'LoadDataSources (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

   --disable_debug;

END LoadDataSources;

/**
 * FUNCTION getSelectedDataSources
 *
 * DESCRIPTION
 *    Return selected data sources for a given entity.
 *    Return selected data sources for a given entity. The
 *    function is created for policy function. For anywhere
 *    else, you should call LoadDataSources.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_entity_name                Entity name.
 *   IN/OUT:
 *     p_entity_attr_id             Entity Id.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   05-01-2002    Jianying Huang   o Created
 */

FUNCTION getSelectedDataSources (
    p_entity_name                   IN     VARCHAR2,
    p_entity_attr_id                IN OUT NOCOPY NUMBER
) RETURN VARCHAR2 IS

-- Bug 4171892
    l_selected_datasources          VARCHAR2(1000);
    l_mixnmatch_enabled             VARCHAR2(1);

BEGIN

    LoadDataSources(
      p_entity_name,
      p_entity_attr_id,
      l_mixnmatch_enabled,
      l_selected_datasources,
      'Y');

    RETURN l_selected_datasources;

END getSelectedDataSources;

/**
 * FUNCTION isEntityUserCreatable
 *
 * DESCRIPTION
 *    Return if user can create user-entered data.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_entity_name                Entity name.
 *   IN/OUT:
 *     p_entity_attr_id             Entity Id.
 *
 * NOTES
 *   The procedure should only be called if the mix-n-match is enable for
 *   the entity.
 *
 * MODIFICATION HISTORY
 *
 *   05-01-2002    Jianying Huang       o Created
 *   01-05-2005    Rajib Ranjan Borah   o SSM SST Integration and Extension.
 *                                        Default value will be 'N' instead of 'Y'.
 */

FUNCTION isEntityUserCreatable (
    p_entity_name                   IN     VARCHAR2,
    p_entity_attr_id                IN OUT NOCOPY NUMBER
) RETURN VARCHAR2 IS
BEGIN

    -- load all of other entity related setups and cache them.
    cacheSetupForOtherEntities(TRUE);

    IF p_entity_attr_id IS NULL OR
       p_entity_attr_id = 0
    THEN
      p_entity_attr_id := getEntityAttrId(p_entity_name);
    END IF;

    IF p_entity_attr_id > 0 AND
       G_CREATE_USER_ENTERED.EXISTS(p_entity_attr_id)
    THEN
       RETURN G_CREATE_USER_ENTERED(p_entity_attr_id);
    ELSE
       -- SSM SST Integration and Extension
       -- default value will be 'N'
       RETURN 'Y';
    END IF;

END isEntityUserCreatable;

--------------------------------------------------------------------------
-- the following procedures are called by mix-n-match concurrent program.
--------------------------------------------------------------------------

/**
 * PRIVATE PROCEDURE Write_Log
 *
 * DESCRIPTION
 *   Write message into log file.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * IN:
 *   p_str                          Message.
 *
 * MODIFICATION HISTORY
 *
 *   04-30-2002    Jianying Huang   o Created.
 */

PROCEDURE Write_Log (
    p_str                           IN     VARCHAR2
) IS
BEGIN
    FND_FILE.PUT_LINE(FND_FILE.LOG,TO_CHAR(SYSDATE, 'YYYY/MM/DD HH:MI:SS')||' -- '||p_str);
END Write_Log;

/**
 * PRIVATE PROCEDURE ResetUpdatedFlag
 *
 * DESCRIPTION
 *   Reset updated flag in hz_entity_attributes.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * MODIFICATION HISTORY
 *
 *   04-30-2002    Jianying Huang   o Created.
 */

PROCEDURE ResetUpdatedFlag IS
BEGIN
    UPDATE hz_entity_attributes
    SET updated_flag = 'N',
        last_updated_by = hz_utility_v2pub.last_updated_by,
        last_update_login = hz_utility_v2pub.last_update_login,
        last_update_date = SYSDATE,
        request_id = hz_utility_v2pub.request_id,
        program_application_id = hz_utility_v2pub.program_application_id,
        program_id = hz_utility_v2pub.program_id,
        program_update_date = SYSDATE;
    COMMIT;
END ResetUpdatedFlag;

/**
 * PRIVATE PROCEDURE ProcessPartyProfiles
 *
 * DESCRIPTION
 *   Return information like how many records need to be processed etc.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * OUT:
 *   x_process_org                  Flag to indicate if we need to
 *                                  process data in organization profiles.
 *   x_process_org_mode             C/U flag for create / update.
 *   x_org_total                    Total records need to be processed.
 *   x_org_id_count                 PL/SQL table to store organization profile id.
 *   x_org_id_start                 PL/SQL table to store the start position.
 *   x_org_id_end                   PL/SQL table to store the end position.
 *   x_process_person               Flag to indicate if we need to
 *                                  process data in person profiles.
 *   x_process_person_mode          C/U flag for create / update.
 *   x_per_total                    Total records need to be processed.
 *   x_per_id_count                 PL/SQL table to store organization profile id.
 *   x_per_id_start                 PL/SQL table to store the start position.
 *   x_per_id_end                   PL/SQL table to store the end position.
 *
 * MODIFICATION HISTORY
 *
 *   04-30-2002    Jianying Huang   o Created.
 */

PROCEDURE ProcessPartyProfiles (
    x_process_org                   OUT    NOCOPY BOOLEAN,
    x_process_org_mode              OUT    NOCOPY VARCHAR2,
    x_org_total                     OUT    NOCOPY NUMBER,
    x_org_id_count                  OUT    NOCOPY INDEXIDList,
    x_org_id_start                  OUT    NOCOPY INDEXIDList,
    x_org_id_end                    OUT    NOCOPY INDEXIDList,
    x_process_person                OUT    NOCOPY BOOLEAN,
    x_process_person_mode           OUT    NOCOPY VARCHAR2,
    x_per_total                     OUT    NOCOPY NUMBER,
    x_per_id_count                  OUT    NOCOPY INDEXIDList,
    x_per_id_start                  OUT    NOCOPY INDEXIDList,
    x_per_id_end                    OUT    NOCOPY INDEXIDList
) IS

    CURSOR c_prof_setup (
      p_entity_name                 VARCHAR2
    ) IS
      SELECT 'Y'
      FROM hz_entity_attributes e
      WHERE e.updated_flag = 'Y'
      AND e.entity_name = p_entity_name
      AND rownum = 1;

    CURSOR c_org_parties IS
      SELECT distinct party_id
      FROM hz_organization_profiles
      WHERE effective_end_date IS NULL
      AND actual_content_source <> G_MISS_ACTUAL_CONTENT_SOURCE
      ORDER BY party_id;

    CURSOR c_person_parties IS
      SELECT distinct party_id
      FROM hz_person_profiles
      WHERE effective_end_date IS NULL
      AND actual_content_source <> G_MISS_ACTUAL_CONTENT_SOURCE
      ORDER BY party_id;

    i_org_parties                   INDEXIDList;
    i_person_parties                INDEXIDList;
    l_result                        BOOLEAN;
    l_rows                          NUMBER := 1000;
    j                               NUMBER := 0;
    l_total                         NUMBER := 0;
    l_subtotal                      NUMBER := 0;
    l_dummy                         VARCHAR2(1);
    l_last_fetch                    BOOLEAN := false;

BEGIN

    -- generate packages which are called to create/update sst record
    -- in concurrent program and in API.
    hz_mixnm_dynamic_pkg_generator.Gen_PackageForAPI('HZ_MIXNM_API_DYNAMIC_PKG');

    hz_mixnm_dynamic_pkg_generator.Gen_PackageForConc('HZ_MIXNM_CONC_DYNAMIC_PKG');

    x_process_org := true;  x_org_total := 0;

    OPEN c_prof_setup('HZ_ORGANIZATION_PROFILES');
    FETCH c_prof_setup INTO l_dummy;
    IF c_prof_setup%NOTFOUND THEN
      x_process_org := false;
    END IF;
    CLOSE c_prof_setup;

    IF x_process_org THEN
      Write_Log('process org profiles ...');

      IF NVL(fnd_profile.value('HZ_ORG_PROF_MIXNMATCH_ENABLED'), 'N') = 'N'
      THEN
        x_process_org_mode := 'C';

        l_result := fnd_profile.save('HZ_ORG_PROF_MIXNMATCH_ENABLED', 'Y', 'SITE');

        IF NOT l_result THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
      ELSE
        x_process_org_mode := 'U';
      END IF;

      Write_Log('x_process_org_mode = '||x_process_org_mode);

      j := 0;
      OPEN c_org_parties;
      LOOP
        FETCH c_org_parties BULK COLLECT INTO i_org_parties LIMIT l_rows;
        IF c_org_parties%NOTFOUND THEN
          l_last_fetch := true;
        END IF;

        l_subtotal := i_org_parties.COUNT;
        Write_Log('l_subtotal = '||l_subtotal);

        IF l_subtotal = 0 AND l_last_fetch THEN
          EXIT;
        END IF;

        j := j + 1;
        x_org_id_count(j) := l_subtotal;
        x_org_id_start(j) := i_org_parties(1);
        x_org_id_end(j) := i_org_parties(l_subtotal);
        x_org_total := x_org_total + l_subtotal;

        IF l_last_fetch THEN
          EXIT;
        END IF;
      END LOOP;
      CLOSE c_org_parties;

      Write_Log('COUNT('||x_org_total||')   --   START   --   END');
      FOR i IN 1..x_org_id_count.COUNT LOOP
        Write_Log(RPAD(x_org_id_count(i),10)||RPAD(x_org_id_start(i),10)||RPAD(x_org_id_end(i),10));
      END LOOP;
    END IF;

    x_process_person := true;  x_per_total := 0;

    OPEN c_prof_setup('HZ_PERSON_PROFILES');
    FETCH c_prof_setup INTO l_dummy;
    IF c_prof_setup%NOTFOUND THEN
      x_process_person := false;
    END IF;
    CLOSE c_prof_setup;

    IF x_process_person THEN
      Write_Log('process person profiles ...');

      IF NVL(fnd_profile.value('HZ_PER_PROF_MIXNMATCH_ENABLED'), 'N') = 'N'
      THEN
        x_process_person_mode := 'C';

        l_result := fnd_profile.save('HZ_PER_PROF_MIXNMATCH_ENABLED', 'Y', 'SITE');

        IF NOT l_result THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
      ELSE
        x_process_person_mode := 'U';
      END IF;

      Write_Log('x_process_person_mode = '||x_process_person_mode);
      Write_Log(fnd_profile.value('HZ_PER_PROF_MIXNMATCH_ENABLED'));

      j := 0;   l_last_fetch := false;
      OPEN c_person_parties;
      LOOP
        FETCH c_person_parties BULK COLLECT INTO i_person_parties LIMIT l_rows;
        IF c_person_parties%NOTFOUND THEN
          l_last_fetch := true;
        END IF;

        l_subtotal := i_person_parties.COUNT;
        Write_Log('l_subtotal = '||l_subtotal);

        IF l_subtotal = 0 AND l_last_fetch THEN
          EXIT;
        END IF;

        j := j + 1;
        x_per_id_count(j) := l_subtotal;
        x_per_id_start(j) := i_person_parties(1);
        x_per_id_end(j) := i_person_parties(l_subtotal);
        x_per_total := x_per_total + l_subtotal;

        IF l_last_fetch THEN
          EXIT;
        END IF;
      END LOOP;
      CLOSE c_person_parties;

      Write_Log('COUNT('||x_per_total||')   --   START   --   END');
      FOR i IN 1..x_per_id_count.COUNT LOOP
        Write_Log(RPAD(x_per_id_count(i),10)||RPAD(x_per_id_start(i),10)||RPAD(x_per_id_end(i),10));
      END LOOP;
    END IF;

END ProcessPartyProfiles;

/**
 * PRIVATE PROCEDURE CreateUpdatePartyProfiles
 *
 * DESCRIPTION
 *   Submit sub-requests to process records in party profile.s
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * IN:
 *   p_entity_name                  Entity name.
 *   p_create_update_flag           C/U flag for create / update.
 *   p_commit_size                  Commit size.
 *   p_party_per_worker             Number of records per worker.
 *   p_id_count                     Number of records.
 *   p_id_start                     Start position.
 *   p_id_end                       End position.
 *
 * MODIFICATION HISTORY
 *
 *   04-30-2002    Jianying Huang   o Created.
 */

PROCEDURE CreateUpdatePartyProfiles (
    p_entity_name                   IN     VARCHAR2,
    p_create_update_flag            IN     VARCHAR2,
    p_commit_size                   IN     NUMBER,
    p_party_per_worker              IN     NUMBER,
    p_id_count                      IN     INDEXIDList,
    p_id_start                      IN     INDEXIDList,
    p_id_end                        IN     INDEXIDList
) IS

    l_subtotal                      NUMBER := 0;
    l_start                         NUMBER := 0;
    l_end                           NUMBER := 0;
    l_request_id                    NUMBER := 0;
    errbuf                          VARCHAR2(100);
    retcode                         VARCHAR2(100);

BEGIN

    FOR i IN 1..p_id_count.COUNT LOOP
      IF l_start = 0 THEN
        l_start := p_id_start(i);
      END IF;
      l_subtotal := l_subtotal + p_id_count(i);
      l_end := p_id_end(i);

      IF l_subtotal >= p_party_per_worker OR
         i = p_id_count.COUNT
      THEN
--        conc_sub(errbuf, retcode,p_create_update_flag||','||p_entity_name,l_start,l_end,p_commit_size);

        l_request_id :=
            FND_REQUEST.SUBMIT_REQUEST(
              'AR', 'HZ_THIRD_PARTY_UPDATE_SUB', '',
              SYSDATE, FALSE,
              p_create_update_flag||','||p_entity_name,
              TO_CHAR(l_start), TO_CHAR(l_end),
              TO_CHAR(p_commit_size));

        l_start := 0;  l_subtotal := 0;
      END IF;
    END LOOP;

END CreateUpdatePartyProfiles;

/**
 * PRIVATE PROCEDURE ProcessOtherEntities
 *
 * DESCRIPTION
 *   Return flags to indicate is we need to process data in other entities.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * OUT:
 *   x_process_loc                  Flag to indicate if we need to process
 *                                  records in hz_locations.
 *   x_process_cp                   Flag to indicate if we need to process
 *                                  records in hz_contact_points.
 *
 * MODIFICATION HISTORY
 *
 *   04-30-2002    Jianying Huang   o Created.
 */

PROCEDURE ProcessOtherEntities (
    x_process_loc                   OUT    NOCOPY BOOLEAN,
    x_process_cp                    OUT    NOCOPY BOOLEAN
) IS

    CURSOR c_other_setup (
      p_entity_name                 VARCHAR2
    ) IS
      SELECT 'Y'
      FROM hz_entity_attributes e
      WHERE e.updated_flag = 'Y'
      AND e.entity_name = p_entity_name;

    l_dummy                         VARCHAR2(1);

BEGIN

    OPEN c_other_setup('HZ_LOCATIONS');
    FETCH c_other_setup INTO l_dummy;
    IF c_other_setup%NOTFOUND THEN
      x_process_loc := false;
    END IF;
    CLOSE c_other_setup;

    OPEN c_other_setup('HZ_CONTACT_POINTS');
    FETCH c_other_setup INTO l_dummy;
    IF c_other_setup%NOTFOUND THEN
      x_process_cp := false;
    END IF;
    CLOSE c_other_setup;

END ProcessOtherEntities;

/**
 * PRIVATE PROCEDURE AddPolicy
 *
 * DESCRIPTION
 *   Add policy functions.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * IN:
 *   p_entities                     Entity list.
 *
 * MODIFICATION HISTORY
 *
 *   04-30-2002    Jianying Huang       o Created.
 *   01-13-2005    Rajib Ranjan Borah   o SSM SST Integration and Extension.
 *                                        Policy function will not be called for
 *                                        non-profile entities.
 */

PROCEDURE AddPolicy (
    p_entities                      IN     INDEXVARCHAR30List
) IS

    l_policy_name                   CONSTANT VARCHAR2(30):= 'content_source_type_sec';
    l_policy_function               CONSTANT VARCHAR2(80) := 'hz_common_pub.content_source_type_security';

BEGIN

    -- get AR schema name.
    IF G_AR_SCHEMA_NAME IS NULL THEN
      G_AR_SCHEMA_NAME := hz_utility_v2pub.Get_SchemaName('AR');
    END IF;

    -- get APPS schema name.
    IF G_APPS_SCHEMA_NAME IS NULL THEN
      G_APPS_SCHEMA_NAME := hz_utility_v2pub.Get_AppsSchemaName;
    END IF;

    -- add third party policy.
    FOR i IN 1..p_entities.COUNT LOOP
      IF fnd_access_control_util.Policy_Exists(
           G_AR_SCHEMA_NAME, p_entities(i), l_policy_name ) = 'FALSE'
      THEN
        fnd_access_control_util.Add_Policy(
          G_AR_SCHEMA_NAME, p_entities(i), l_policy_name,
          G_APPS_SCHEMA_NAME, l_policy_function);
      END IF;

/*
      IF p_entities(i) = 'HZ_LOCATIONS' AND
         fnd_access_control_util.Policy_Exists(
           G_AR_SCHEMA_NAME, 'HZ_PARTY_SITES', l_policy_name ) = 'FALSE'
      THEN
        fnd_access_control_util.Add_Policy(
          G_AR_SCHEMA_NAME, 'HZ_PARTY_SITES', l_policy_name,
          G_APPS_SCHEMA_NAME, l_policy_function);
      ELSIF p_entities(i) = 'HZ_FINANCIAL_REPORTS' AND
            fnd_access_control_util.Policy_Exists(
              G_AR_SCHEMA_NAME, 'HZ_FINANCIAL_NUMBERS', l_policy_name ) = 'FALSE'
      THEN
        fnd_access_control_util.Add_Policy(
          G_AR_SCHEMA_NAME, 'HZ_FINANCIAL_NUMBERS', l_policy_name,
          G_APPS_SCHEMA_NAME, l_policy_function);
      END IF;
*/
    END LOOP;

END AddPolicy;

/**
 * PROCEDURE conc_main
 *
 * DESCRIPTION
 *   Main concurrent program for mix-n-match.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * IN:
 *   p_commit_size                  Commit size.
 *   p_num_of_worker                Number of workers.
 * OUT:
 *   errbuf                         Buffer for error message.
 *   retcode                        Return code.
 *
 * MODIFICATION HISTORY
 *
 *   04-30-2002    Jianying Huang       o Created.
 *   01-13-2005    Rajib Ranjan Borah   o SSM SST Integration and Extension.
 *                                        Policy function will not be called for
 *                                        non-profile entities.
 *   12-08-2009    Sudhir Gokavarapu    o Bug8651628
 *                                        Added p_run_mode parameter to conc_main procedure.
 *
 */

PROCEDURE conc_main (
    errbuf                          OUT NOCOPY   VARCHAR2,
    retcode                         OUT NOCOPY   VARCHAR2,
    p_commit_size                   IN           VARCHAR2,
    p_num_of_worker                 IN           VARCHAR2,
    p_run_mode                      IN           VARCHAR2 DEFAULT 'REGENERATE_SST'
) IS

    CURSOR c_setup IS
      SELECT 'Y'
      FROM hz_entity_attributes e
      WHERE e.updated_flag = 'Y'
      AND rownum = 1;

    CURSOR c_prof_setup IS
      SELECT 'Y'
      FROM hz_entity_attributes e
      WHERE e.updated_flag = 'Y'
      AND e.entity_name IN ('HZ_ORGANIZATION_PROFILES','HZ_PERSON_PROFILES')
      AND rownum = 1;

    l_process_profile               BOOLEAN := true;

    CURSOR c_other_setup IS
      SELECT 'Y'
      FROM hz_entity_attributes e,
           hz_select_data_sources s
      WHERE e.updated_flag = 'Y'
      AND e.entity_name NOT IN ('HZ_ORGANIZATION_PROFILES','HZ_PERSON_PROFILES')
      AND rownum = 1;

    l_process_other_entities        BOOLEAN := true;

    CURSOR c_entities IS
      SELECT UNIQUE e.entity_name
      FROM hz_entity_attributes e
      WHERE e.updated_flag = 'Y'
            -- SSM SST Integration and Extension
	    -- Only profile entities will be passed for policy function.
        AND e.attribute_name is not null;

    i_entities                      INDEXVARCHAR30List;
    l_process_org                   BOOLEAN;
    l_process_org_mode              VARCHAR2(1);
    l_process_person                BOOLEAN;
    l_process_person_mode           VARCHAR2(1);
    l_org_id_count                  INDEXIDList;
    l_org_id_start                  INDEXIDList;
    l_org_id_end                    INDEXIDList;
    l_per_id_count                  INDEXIDList;
    l_per_id_start                  INDEXIDList;
    l_per_id_end                    INDEXIDList;
    l_org_total                     NUMBER;
    l_per_total                     NUMBER;
    l_num_of_worker                 NUMBER := NVL(TO_NUMBER(p_num_of_worker),1);
    l_commit_size                   NUMBER := NVL(TO_NUMBER(p_commit_size),500);
    l_party_per_worker              NUMBER;
    l_org_party_per_worker          NUMBER;
    l_per_party_per_worker          NUMBER;
    l_org_num_of_worker             NUMBER;
    l_person_num_of_worker          NUMBER;
    l_process_loc                   BOOLEAN;
    l_process_cp                    BOOLEAN;
    l_dummy                         VARCHAR2(1);
    l_debug_prefix                  VARCHAR2(30) := '';

BEGIN
    -- standard start of API savepoint
    SAVEPOINT conc_main;

     -- Debug info.
 	     IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
 	            hz_utility_v2pub.debug(p_message=>'Running mode is '||p_run_mode,
 	                                   p_prefix =>l_debug_prefix,
 	                                   p_msg_level=>fnd_log.level_statement);
 	     END IF;

 	 --Bug7657959
 	 --Add p_run_mode value is to Genereate Package only then
 	 --call Generate_mixnm_dynm_pkg procedure to generate packages
 	 --and skip other logic of concurrent program
  IF NVL(p_run_mode,'REGENERATE_SST') = 'GEN_PKG_ONLY' THEN -- Running Mode

 	           Generate_mixnm_dynm_pkg;
  ELSE

    -- We will return to the caller if no change, i.e. the selection
    -- of data sources, the ranking, has been done in setup.
    OPEN c_setup;
    FETCH c_setup INTO l_dummy;
    IF c_setup%NOTFOUND THEN
      Write_Log('No setup for any entity / attribute has been updated.');
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT,
        'You did not change or your change to the setup does not have impact to existing data.');
      CLOSE c_setup;
      RETURN;
    END IF;
    CLOSE c_setup;

    -- if setup has been changed for party profiles.

    OPEN c_prof_setup;
    FETCH c_prof_setup INTO l_dummy;
    IF c_prof_setup%NOTFOUND THEN
      l_process_profile := false;
    END IF;
    CLOSE c_prof_setup;

    hz_common_pub.disable_cont_source_security;

    -- process party profiles.
    IF l_process_profile THEN
      ProcessPartyProfiles(
        l_process_org,
        l_process_org_mode,
        l_org_total,
        l_org_id_count,
        l_org_id_start,
        l_org_id_end,
        l_process_person,
        l_process_person_mode,
        l_per_total,
        l_per_id_count,
        l_per_id_start,
        l_per_id_end);
      IF l_commit_size < 500 THEN
        l_commit_size := 500;
      END IF;
      IF l_num_of_worker < 1 THEN
        l_num_of_worker := 1;
      END IF;
-- Bug 4227865 : Delete exceptions type = MRR when an
-- attribute is setup as rank
      IF l_process_org AND l_org_total <> 0 THEN
	DELETE hz_win_source_exceps
	WHERE entity_attr_id IN
 	(SELECT e.entity_attr_id
	  FROM hz_entity_attributes e, hz_select_data_sources s
	  WHERE e.entity_name = 'HZ_ORGANIZATION_PROFILES'
	  AND s.ranking > 0
	  AND s.content_source_type = 'USER_ENTERED'
	  AND e.entity_attr_id = s.entity_attr_id
	 )
	and exception_type='MRR';
      END IF;
      IF l_process_person AND l_per_total <> 0 THEN
	DELETE hz_win_source_exceps
	WHERE entity_attr_id IN
 	(SELECT e.entity_attr_id
	  FROM hz_entity_attributes e, hz_select_data_sources s
	  WHERE e.entity_name = 'HZ_PERSON_PROFILES'
	  AND s.ranking > 0
	  AND s.content_source_type = 'USER_ENTERED'
	  AND e.entity_attr_id = s.entity_attr_id
	 )
	and exception_type='MRR';
      END IF;
      IF l_num_of_worker > 1 THEN
        l_party_per_worker := ROUND((l_org_total+l_per_total)/l_num_of_worker);
        Write_Log('l_party_per_worker = '||l_party_per_worker);

        IF l_org_total <> 0 THEN
          l_org_num_of_worker := FLOOR(l_org_total/l_party_per_worker);
          IF l_org_num_of_worker = 0 THEN
            l_org_num_of_worker := 1;
          END IF;
          l_org_party_per_worker := ROUND(l_org_total/l_org_num_of_worker);
        END IF;

        IF l_per_total <> 0 THEN
          l_person_num_of_worker := FLOOR(l_per_total/l_party_per_worker);
          IF l_person_num_of_worker = 0 THEN
            l_person_num_of_worker := 1;
          END IF;
          l_per_party_per_worker := ROUND(l_per_total/l_person_num_of_worker);
        END IF;

        Write_Log('l_org_num_of_worker = '||l_org_num_of_worker);
        Write_Log('l_person_num_of_worker = '||l_person_num_of_worker);
        Write_Log('l_org_party_per_worker = '||l_org_party_per_worker);
        Write_Log('l_per_party_per_worker = '||l_per_party_per_worker);

        IF l_process_org AND l_org_total <> 0 THEN
          CreateUpdatePartyProfiles (
            'HZ_ORGANIZATION_PROFILES',
            l_process_org_mode,
            l_commit_size,
            l_org_party_per_worker,
            l_org_id_count,
            l_org_id_start,
            l_org_id_end);
        END IF;

        IF l_process_person AND l_per_total <> 0 THEN
          CreateUpdatePartyProfiles (
            'HZ_PERSON_PROFILES',
            l_process_person_mode,
            l_commit_size,
            l_per_party_per_worker,
            l_per_id_count,
            l_per_id_start,
            l_per_id_end);
        END IF;
      ELSE
        IF l_process_org AND l_org_total <> 0 THEN
          conc_sub (
            errbuf, retcode,
            l_process_org_mode||',HZ_ORGANIZATION_PROFILES',
            l_org_id_start(1),
            l_org_id_end(l_org_id_end.COUNT),
            l_commit_size);
        END IF;

        IF l_process_person AND l_per_total <> 0 THEN
          conc_sub (
            errbuf, retcode,
            l_process_org_mode||',HZ_PERSON_PROFILES',
            l_per_id_start(1),
            l_per_id_end(l_per_id_end.COUNT),
            l_commit_size);
        END IF;
      END IF;
    END IF;

    -- if setup has been changed for other entities.

    OPEN c_other_setup;
    FETCH c_other_setup INTO l_dummy;
    IF c_other_setup%NOTFOUND THEN
      l_process_other_entities := false;
    END IF;
    CLOSE c_other_setup;

    IF l_process_other_entities THEN
      Write_Log('process other entities ...');

      ProcessOtherEntities(
        l_process_loc, l_process_cp);
    END IF;

    -- add policy functions.

    IF NVL(fnd_profile.value('HZ_DNB_POLICY_EXISTS'), 'N') = 'N' THEN
      OPEN c_entities;
      FETCH c_entities BULK COLLECT INTO i_entities;
      CLOSE c_entities;

      AddPolicy(i_entities);
    END IF;

    -- reset updated flag in hz_entity_attributes.
    ResetUpdatedFlag;
  END IF; -- Running Mode

EXCEPTION
    WHEN OTHERS THEN
       ROLLBACK to conc_main;
       retcode := 2;
       errbuf := SQLERRM;

END conc_main;

/**
 * PROCEDURE conc_sub
 *
 * DESCRIPTION
 *   Sub concurrent program for mix-n-match.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * IN:
 *   p_entity_type                  Entity type.
 *   p_from_id                      From id.
 *   p_to_id                        To id.
 *   p_commit_size                  Commit size.
 * OUT:
 *   errbuf                         Buffer for error message.
 *   retcode                        Return code.
 *
 * MODIFICATION HISTORY
 *
 *   04-30-2002    Jianying Huang   o Created.
 */

PROCEDURE conc_sub (
    errbuf                          OUT NOCOPY   VARCHAR2,
    retcode                         OUT NOCOPY   VARCHAR2,
    p_entity_type                   IN           VARCHAR2,
    p_from_id                       IN           VARCHAR2,
    p_to_id                         IN           VARCHAR2,
    p_commit_size                   IN           VARCHAR2
) IS

    l_from_id                       NUMBER := TO_NUMBER(p_from_id);
    l_to_id                         NUMBER := TO_NUMBER(p_to_id);
    l_commit_size                   NUMBER := TO_NUMBER(p_commit_size);
    l_process_mode                  VARCHAR2(30);
    l_entity_name                   VARCHAR2(30);
    l_pos1                          NUMBER;

BEGIN

    --standard start of API savepoint
    SAVEPOINT conc_sub;

    FND_FILE.PUT_LINE(FND_FILE.LOG,
        'p_entity_type = '||p_entity_type||
        ', p_from_id = '||p_from_id||
        ', p_to_id = '||p_to_id||
        ', p_commit_size = '||p_commit_size);

    IF INSTRB(p_entity_type, '_PROFILES') > 0 THEN
      l_pos1 := INSTRB(p_entity_type, ',');
      l_process_mode := SUBSTRB(p_entity_type, 1, l_pos1-1);
      l_entity_name := SUBSTRB(p_entity_type, l_pos1+1, LENGTHB(p_entity_type)-l_pos1);

      IF l_process_mode = 'C' THEN
        IF l_entity_name = 'HZ_ORGANIZATION_PROFILES' THEN
          Write_Log('HZ_MIXNM_CONC_DYNAMIC_PKG.BulkCreateOrgSST('||l_from_id||', '||l_to_id||', '||l_commit_size||');');
          HZ_MIXNM_CONC_DYNAMIC_PKG.BulkCreateOrgSST(l_from_id, l_to_id, l_commit_size);
        ELSE
          Write_Log('HZ_MIXNM_CONC_DYNAMIC_PKG.BulkCreatePerSST('||l_from_id||', '||l_to_id||', '||l_commit_size||');');
          HZ_MIXNM_CONC_DYNAMIC_PKG.BulkCreatePersonSST(l_from_id, l_to_id, l_commit_size);
        END IF;
      ELSE
        IF l_entity_name = 'HZ_ORGANIZATION_PROFILES' THEN
          Write_Log('HZ_MIXNM_CONC_DYNAMIC_PKG.BulkUpdateOrgSST('||l_from_id||', '||l_to_id||', '||l_commit_size||');');
          HZ_MIXNM_CONC_DYNAMIC_PKG.BulkUpdateOrgSST(l_from_id, l_to_id, l_commit_size);
        ELSE
          Write_Log('HZ_MIXNM_CONC_DYNAMIC_PKG.BulkUpdatePerSST('||l_from_id||', '||l_to_id||', '||l_commit_size||');');
          HZ_MIXNM_CONC_DYNAMIC_PKG.BulkUpdatePersonSST(l_from_id, l_to_id, l_commit_size);
        END IF;
      END IF;
    END IF;

    retcode := 0;

EXCEPTION
    WHEN OTHERS THEN
       ROLLBACK to conc_sub;
       retcode := 2;
       errbuf := SQLERRM;

END conc_sub;

--  SSM SST Integration and Extension

Procedure populateMRRExc(
	p_entity_name                   IN     VARCHAR2,
	p_data_source_type              IN     VARCHAR2,
	p_party_id			IN	NUMBER
)IS

	cursor mmr_attributes IS
        select e.entity_attr_id, s.content_source_type
        from hz_entity_attributes e, hz_select_data_sources s
        where s.ranking = -1
        AND e.entity_name = p_entity_name
        AND e.entity_attr_id = s.entity_attr_id
        AND (s.content_source_type= p_data_source_type or
       	 (s.content_source_type='USER_ENTERED' AND
       	  NOT EXISTS(select 'Y' from hz_select_data_sources s1
     	  	     where s1.ranking = -1 and s1.content_source_type = p_data_source_type
     	  	     and s1.entity_attr_id = e.entity_attr_id)))
-- Bug 4244112 : populate only if does not exist
	AND NOT EXISTS(select 'Y' from hz_win_source_exceps
			where party_id = p_party_id
			and entity_attr_id = e.entity_attr_id);

	TYPE ATTR_IDList IS TABLE OF hz_entity_attributes.entity_attr_id%TYPE;
	TYPE SOURCE_List IS TABLE OF hz_select_data_sources.content_source_type%TYPE;
	I_ATTR_ID ATTR_IDList;
	I_SOURCE SOURCE_List;

	i NUMBER;
Begin
	OPEN mmr_attributes;
	FETCH mmr_attributes BULK COLLECT INTO
		I_ATTR_ID, I_SOURCE;
	CLOSE mmr_attributes;

	FORALL i IN 1..I_ATTR_ID.COUNT
		INSERT INTO hz_win_source_exceps (
		  party_id,
		  entity_attr_id,
		  content_source_type,
		  exception_type,
		  created_by,
		  creation_date,
		  last_update_login,
		  last_update_date,
		  last_updated_by
		) VALUES (
		  p_party_id,
		  I_ATTR_ID(i),
		  I_SOURCE(i),
		  'MRR',
		  hz_utility_v2pub.created_by,
		  SYSDATE,
		  hz_utility_v2pub.last_update_login,
		  SYSDATE,
		  hz_utility_v2pub.last_updated_by );
End populateMRRExc;

Function getUserRestriction(
	p_entity_attr_id IN NUMBER
) Return VARCHAR2 IS

	cursor update_allowed is
	select v.orig_system_name
	from hz_thirdparty_rule t, hz_orig_systems_vl v
	where t.entity_attr_id = p_entity_attr_id
	and t.orig_system = v.orig_system
	and t.overwrite_flag = 'Y';

-- Bug 4171892
	l_str VARCHAR2(355);
	l_len NUMBER;
begin
	l_str := '';
	for content_source in update_allowed loop
                IF LENGTHB(l_str) > 225 THEN
                        l_str := l_str || '....';
                        EXIT;
                ELSE
			l_str := l_str || content_source.orig_system_name;
			l_str := l_str || ', ';
		END IF;
	end loop;

	l_len := LENGTHB(l_str);
        IF l_len > 1 THEN
                l_str := SUBSTRB(l_str,1,l_len-2);
        END IF;
	return l_str;
end;


Function getUserOverwrite(
	p_entity_attr_id IN NUMBER,
	p_rule_id	 IN NUMBER
) Return VARCHAR2 IS

	cursor overwrite_allowed is
	select v.orig_system_name
	from hz_user_overwrite_rules u, hz_orig_systems_vl v
	where u.entity_attr_id = p_entity_attr_id
	and u.orig_system = v.orig_system
	and u.overwrite_flag = 'Y'
	and u.rule_id = p_rule_id;

	l_str VARCHAR2(350);
	l_len NUMBER;
begin
	l_str := '';
	for content_source in overwrite_allowed loop
		IF LENGTHB(l_str) > 225 THEN
			l_str := l_str || '....';
			EXIT;
		ELSE
			l_str := l_str || content_source.orig_system_name;
			l_str := l_str || ', ';
		END IF;
	end loop;
	l_len := LENGTHB(l_str);
        IF l_len > 1 THEN
                l_str := SUBSTRB(l_str,1,l_len-2);
        END IF;
	return l_str;
end;

Function getGroupMeaningList(
	p_entity IN VARCHAR2,
	p_group IN VARCHAR2
) Return VARCHAR2 IS

	cursor meaning is
	select attribute_name
	from hz_entity_attributes
	where attribute_group_name = p_group
	and entity_name = p_entity;

	l_str VARCHAR2(1000);
	l_len NUMBER;
begin
	l_str := '';
	for attributes in meaning loop
		l_str := l_str || hz_utility_v2pub.Get_LookupMeaning('AR_LOOKUPS',p_entity, attributes.attribute_name);
		l_str := l_str || ' / ';
	end loop;
	l_len := LENGTHB(l_str);
        IF l_len > 1 THEN
                l_str := SUBSTRB(l_str,1,l_len-3);
        END IF;
	return l_str;
end;

/**
 	  * PROCEDURE generate_mixnm_dynm_pkg
 	  *
 	  * DESCRIPTION
 	  *   When Running Mode is GEN_PKG_ONLY then
 	  *   Generate underlying infrastructure packages only.
 	  *
 	  *
 	  *
 	  * MODIFICATION HISTORY
 	  *
 	  *   12-08-2009    Sudhir Gokavarapu   o Created for Bug8651628
 	  */
 	 PROCEDURE generate_mixnm_dynm_pkg IS

 	      CURSOR c_attributes IS
 	        SELECT 'Y'
 	        FROM   hz_entity_attributes
 	        WHERE  updated_flag = 'Y'
 	        AND    ROWNUM = 1;

 	     l_dummy                VARCHAR2(1);
 	     l_debug_prefix         VARCHAR2(30) := '';
 	 BEGIN

 	     -- Debug info.
 	     IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
 	         hz_utility_v2pub.debug(p_message=>'generate_mixnm_dynm_pkg (+)',
 	                                p_prefix=>l_debug_prefix,
 	                                p_msg_level=>fnd_log.level_procedure);
 	     END IF;

 	     OPEN c_attributes;
 	       FETCH c_attributes INTO l_dummy;

 	       IF c_attributes%NOTFOUND THEN
 	         UPDATE hz_entity_attributes
 	         SET    updated_flag = 'Y';

 	     -- Debug info.
 	     IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
 	         hz_utility_v2pub.debug(p_message=>'No Attributes were change. Setting updated_flag =''Y'' for all',
 	                                p_prefix=>l_debug_prefix,
 	                                p_msg_level=>fnd_log.level_procedure);
 	     END IF;
 	     END IF;

 	     hz_mixnm_dynamic_pkg_generator.Gen_PackageForAPI('HZ_MIXNM_API_DYNAMIC_PKG');

 	     -- Debug info.
 	     IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
 	         hz_utility_v2pub.debug(p_message=>'Generated HZ_MIXNM_API_DYNAMIC_PKG Package',
 	                                p_prefix=>l_debug_prefix,
 	                                p_msg_level=>fnd_log.level_procedure);
 	     END IF;

 	     hz_mixnm_dynamic_pkg_generator.Gen_PackageForConc('HZ_MIXNM_CONC_DYNAMIC_PKG');

 	     -- Debug info.
 	     IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
 	         hz_utility_v2pub.debug(p_message=>'Generated HZ_MIXNM_CONC_DYNAMIC_PKG Package',
 	                                p_prefix=>l_debug_prefix,
 	                                p_msg_level=>fnd_log.level_procedure);
 	     END IF;

 	     IF c_attributes%NOTFOUND THEN
 	        UPDATE hz_entity_attributes
 	        SET    updated_flag = 'N';

 	     -- Debug info.
 	     IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
 	         hz_utility_v2pub.debug(p_message=>'Re-setting updated_flag =''N'' for all',
 	                                p_prefix=>l_debug_prefix,
 	                                p_msg_level=>fnd_log.level_procedure);
 	     END IF;
 	     COMMIT;
 	     END IF;

 	     CLOSE c_attributes;
 	    -- Debug info.
 	     IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
 	         hz_utility_v2pub.debug(p_message=>'generate_mixnm_dynm_pkg (-)',
 	                                p_prefix=>l_debug_prefix,
 	                                p_msg_level=>fnd_log.level_procedure);
 	     END IF;
 	 EXCEPTION
 	     WHEN NO_DATA_FOUND THEN
 	      NULL;
 	     WHEN OTHERS THEN
 	       RAISE;
 	 END generate_mixnm_dynm_pkg;

END HZ_MIXNM_UTILITY;

/
