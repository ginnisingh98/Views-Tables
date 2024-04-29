--------------------------------------------------------
--  DDL for Package Body HZ_HIERARCHY_V2PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_HIERARCHY_V2PUB" AS
/*$Header: ARH2HISB.pls 120.3 2005/10/28 13:45:36 vravicha noship $ */

-----------------------------------------
-----------------------------------------
-- declaration of private global varibles
-----------------------------------------
-----------------------------------------

--G_DEBUG             BOOLEAN := FALSE;

--------------------------------------------------
--------------------------------------------------
-- declaration of private procedures and functions
--------------------------------------------------
--------------------------------------------------

/*PROCEDURE enable_debug;

PROCEDURE disable_debug;
*/

PROCEDURE validate_input(
    p_hierarchy_type            IN       VARCHAR2,
    p_parent_id                 IN       NUMBER := NULL,
    p_parent_table_name         IN       VARCHAR2 := NULL,
    p_parent_object_type        IN       VARCHAR2 := NULL,
    p_child_id                  IN       NUMBER := NULL,
    p_child_table_name          IN       VARCHAR2 := NULL,
    p_child_object_type         IN       VARCHAR2 := NULL,
    p_no_of_records             IN       NUMBER := NULL,
    x_return_status             IN OUT NOCOPY   VARCHAR2
);

-----------------------------------
-----------------------------------
-- private procedures and functions
-----------------------------------
-----------------------------------

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
 *   31-Oct-2001    Anupam Bordia       o Created.
 *
 */

/*PROCEDURE enable_debug IS

BEGIN

    IF FND_PROFILE.value( 'HZ_API_FILE_DEBUG_ON' ) = 'Y' OR
       FND_PROFILE.value( 'HZ_API_DBMS_DEBUG_ON' ) = 'Y'
    THEN
        HZ_UTILITY_V2PUB.enable_debug;
        G_DEBUG := TRUE;
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
 *     HZ_UTILITY_V2PUB.disable_debug
 *
 * MODIFICATION HISTORY
 *
 *   31-Oct-2001    Anupam Bordia       o Created.
 *
 */

/*PROCEDURE disable_debug IS

BEGIN

    IF G_DEBUG THEN
        HZ_UTILITY_V2PUB.disable_debug;
        G_DEBUG := FALSE;
    END IF;

END disable_debug;
*/

/**
 * PRIVATE PROCEDURE validate_input
 *
 * DESCRIPTION
 *     Validates the input to different procedures in this API.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 *
 * MODIFICATION HISTORY
 *
 *   31-Oct-2001    Anupam Bordia       o Created.
 *
 */

PROCEDURE validate_input(
    p_hierarchy_type            IN       VARCHAR2,
    p_parent_id                 IN       NUMBER := NULL,
    p_parent_table_name         IN       VARCHAR2 := NULL,
    p_parent_object_type        IN       VARCHAR2 := NULL,
    p_child_id                  IN       NUMBER := NULL,
    p_child_table_name          IN       VARCHAR2 := NULL,
    p_child_object_type         IN       VARCHAR2 := NULL,
    p_no_of_records             IN       NUMBER := NULL,
    x_return_status             IN OUT NOCOPY   VARCHAR2
) IS

    l_dummy                           VARCHAR2(30);
    l_debug_prefix                    VARCHAR2(30) := '';

BEGIN

    --------------------------
    -- validate hierarchy type
    --------------------------

    BEGIN
        SELECT HIERARCHICAL_FLAG INTO l_dummy
        FROM   HZ_RELATIONSHIP_TYPES
        WHERE  RELATIONSHIP_TYPE = p_hierarchy_type
        AND    ROWNUM = 1;

        IF l_dummy <> 'Y' THEN
            -- relationship type is not hierarchical, give error
            FND_MESSAGE.SET_NAME('AR', 'HZ_NON_HIER_REL_TYPE');
            FND_MSG_PUB.ADD;
            x_return_status :=  fnd_api.g_ret_sts_error;
        END IF;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            -- no relationship type record found, so error out NOCOPY
            FND_MESSAGE.SET_NAME('AR', 'HZ_API_INVALID_FK');
            FND_MESSAGE.SET_TOKEN('FK', 'hierarchy_type');
            FND_MESSAGE.SET_TOKEN('COLUMN', 'relationship_type');
            FND_MESSAGE.SET_TOKEN('TABLE', 'hz_relationship_types');
            FND_MSG_PUB.ADD;
            x_return_status :=  fnd_api.g_ret_sts_error;
    END;

    -----------------------------
    -- validate parent_table_name
    -----------------------------
    -- subject_table_name has foreign key fnd_objects.obj_name
    IF p_parent_table_name IS NOT NULL THEN
        BEGIN
            SELECT 'Y'
            INTO   l_dummy
            FROM   fnd_objects fo
            WHERE  fo.obj_name = p_parent_table_name;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
              fnd_message.set_name('AR', 'HZ_API_INVALID_FK');
              fnd_message.set_token('FK', 'parent_table_name');
              fnd_message.set_token('COLUMN', 'obj_name');
              fnd_message.set_token('TABLE', 'fnd_objects');
              fnd_msg_pub.add;
              x_return_status := fnd_api.g_ret_sts_error;
        END;
	IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'parent_table_name has foreign key fnd_objects.obj_name. ' ||
						'x_return_status = ' || x_return_status,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
	END IF;
    END IF;

    ------------------------------
    -- validate parent_object_type
    ------------------------------

    -- parent_object_type has foreign key fnd_object_instance_sets.instance_set_name
    IF p_parent_object_type IS NOT NULL
    THEN
        BEGIN
            SELECT 'Y'
            INTO   l_dummy
            FROM   FND_OBJECT_INSTANCE_SETS
            WHERE  INSTANCE_SET_NAME = p_parent_object_type;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                fnd_message.set_name('AR', 'HZ_API_INVALID_FK');
                fnd_message.set_token('FK', 'parent_object_type');
                fnd_message.set_token('COLUMN', 'instance_set_name');
                fnd_message.set_token('TABLE', 'fnd_object_instance_sets');
                fnd_msg_pub.add;
                x_return_status := fnd_api.g_ret_sts_error;
        END;

	IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'parent_object_type has foreign key fnd_object_instance_sets.instance_set_name. ' ||
						'x_return_status = ' || x_return_status,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
	END IF;

    END IF;

    -----------------------------
    -- validate child_table_name
    -----------------------------
    -- subject_table_name has foreign key fnd_objects.obj_name
    IF p_child_table_name IS NOT NULL THEN
        BEGIN
            SELECT 'Y'
            INTO   l_dummy
            FROM   fnd_objects fo
            WHERE  fo.obj_name = p_child_table_name;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
              fnd_message.set_name('AR', 'HZ_API_INVALID_FK');
              fnd_message.set_token('FK', 'child_table_name');
              fnd_message.set_token('COLUMN', 'obj_name');
              fnd_message.set_token('TABLE', 'fnd_objects');
              fnd_msg_pub.add;
              x_return_status := fnd_api.g_ret_sts_error;
        END;

	IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'child_table_name has foreign key fnd_objects.obj_name. ' ||
					     'x_return_status = ' || x_return_status,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
	END IF;
    END IF;

    ------------------------------
    -- validate child_object_type
    ------------------------------

    -- child_object_type has foreign key fnd_object_instance_sets.instance_set_name
    IF p_child_object_type IS NOT NULL
    THEN
        BEGIN
            SELECT 'Y'
            INTO   l_dummy
            FROM   FND_OBJECT_INSTANCE_SETS
            WHERE  INSTANCE_SET_NAME = p_child_object_type;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                fnd_message.set_name('AR', 'HZ_API_INVALID_FK');
                fnd_message.set_token('FK', 'child_object_type');
                fnd_message.set_token('COLUMN', 'instance_set_name');
                fnd_message.set_token('TABLE', 'fnd_object_instance_sets');
                fnd_msg_pub.add;
                x_return_status := fnd_api.g_ret_sts_error;
        END;
	IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'child_object_type has foreign key fnd_object_instance_sets.instance_set_name. ' ||
					     'x_return_status = ' || x_return_status,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
	END IF;

    END IF;

    ---------------------------
    -- validate p_no_of_records
    ---------------------------

    IF p_no_of_records > 100 OR
       p_no_of_records < 1 OR
       p_no_of_records IS NULL
    THEN
        FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_VALUE_BETWEEN' );
        FND_MESSAGE.SET_TOKEN( 'COLUMN','p_no_of_records');
        FND_MESSAGE.SET_TOKEN( 'VALUE1', '1' );
        FND_MESSAGE.SET_TOKEN( 'VALUE2', '100' );
        FND_MSG_PUB.ADD;
        x_return_status := FND_API.G_RET_STS_ERROR;

	IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'p_no_of_records should be between 1 and 100 .' ||
                  'x_return_status = ' || x_return_status,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
	END IF;
    END IF;



END validate_input;

----------------------------------
----------------------------------
-- Public procedures and functions
----------------------------------
----------------------------------

PROCEDURE is_top_parent(
    p_init_msg_list                         IN      VARCHAR2 := FND_API.G_FALSE,
    p_hierarchy_type                        IN      VARCHAR2,
    p_parent_id                             IN      NUMBER,
    p_parent_table_name                     IN      VARCHAR2 := 'HZ_PARTIES',
    p_parent_object_type                    IN      VARCHAR2 := 'ORGANIZATION',
    p_effective_date                        IN      DATE := SYSDATE,
    x_result                                OUT NOCOPY     VARCHAR2,
    x_return_status                         OUT NOCOPY     VARCHAR2,
    x_msg_count                             OUT NOCOPY     NUMBER,
    x_msg_data                              OUT NOCOPY     VARCHAR2
)
IS

    l_result                                        VARCHAR2(1) := 'N';
    l_incl_unrelated                                VARCHAR2(1);
    l_debug_prefix				    VARCHAR2(30) := '';

    CURSOR c_top_in_hierarchy IS
    SELECT TOP_PARENT_FLAG
    FROM   HZ_HIERARCHY_NODES
    WHERE  PARENT_ID = p_parent_id
    AND    PARENT_TABLE_NAME = p_parent_table_name
    AND    PARENT_OBJECT_TYPE = p_parent_object_type
    AND    HIERARCHY_TYPE = p_hierarchy_type
    AND    p_effective_date BETWEEN EFFECTIVE_START_DATE AND EFFECTIVE_END_DATE
    AND    LEVEL_NUMBER = 0;


BEGIN

    -- Check if API is called in debug mode. If yes, enable debug.
    --enable_debug;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'is_top_parent (+)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
    END IF;

    --Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    --Initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    validate_input (
        p_hierarchy_type         => p_hierarchy_type,
        p_parent_table_name      => p_parent_table_name,
        p_parent_object_type     => p_parent_object_type,
        p_no_of_records          => 1,
        x_return_status          => x_return_status
    );

    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- check whether it is a top parent in the given hierarchy
    OPEN c_top_in_hierarchy;
    FETCH c_top_in_hierarchy INTO l_result;
    CLOSE c_top_in_hierarchy;

    -- if the parent is not a top parent in hierarchy, it can still be returned
    -- provided hierarchy_type is set up with incl_unrelated_entities = 'Y' and
    -- the parent is a valid entity of the subject type

    IF l_result = 'N' THEN
        l_incl_unrelated := HZ_UTILITY_V2PUB.incl_unrelated_entities(p_hierarchy_type);
        IF l_incl_unrelated = 'Y' THEN
            -- include the entity if it is valid
            l_result := HZ_RELATIONSHIP_TYPE_V2PUB.in_instance_sets
                            (p_parent_object_type,
                             p_parent_id);
        END IF;
    END IF;

    -- return the result
    x_result := l_result;

    --Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data );

    -- Debug info.
    IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
	 hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
	                       p_msg_data=>x_msg_data,
			       p_msg_type=>'WARNING',
			       p_msg_level=>fnd_log.level_exception);
    END IF;
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'is_top_parent (-)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Check if API is called in debug mode. If yes, disable debug.
    --disable_debug;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        x_result := 'N';

        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data );

        -- Debug info.
	IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
		 hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
	                       p_msg_data=>x_msg_data,
			       p_msg_type=>'ERROR',
			       p_msg_level=>fnd_log.level_error);
        END IF;
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	    hz_utility_v2pub.debug(p_message=>'is_top_parent (-)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
        END IF;

        -- Check if API is called in debug mode. If yes, disable debug.
        --disable_debug;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_result := 'N';

        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data );

        -- Debug info.
	IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
	                       p_msg_data=>x_msg_data,
			       p_msg_type=>'UNEXPECTED ERROR',
			       p_msg_level=>fnd_log.level_error);
        END IF;
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'is_top_parent (-)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
        END IF;

        -- Check if API is called in debug mode. If yes, disable debug.
        --disable_debug;

    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_result := 'N';

        FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_OTHERS_EXCEP' );
        FND_MESSAGE.SET_TOKEN( 'ERROR' ,SQLERRM );
        FND_MSG_PUB.ADD;

        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data );

        -- Debug info.
	IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
             hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
	                       p_msg_data=>x_msg_data,
			       p_msg_type=>'SQL ERROR',
			       p_msg_level=>fnd_log.level_error);
        END IF;
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	    hz_utility_v2pub.debug(p_message=>'is_top_parent (-)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
        END IF;

        -- Check if API is called in debug mode. If yes, disable debug.
        --disable_debug;

END is_top_parent;


PROCEDURE check_parent_child(
    p_init_msg_list                         IN      VARCHAR2 := FND_API.G_FALSE,
    p_hierarchy_type                        IN      VARCHAR2,
    p_parent_id                             IN      NUMBER,
    p_parent_table_name                     IN      VARCHAR2 := 'HZ_PARTIES',
    p_parent_object_type                    IN      VARCHAR2 := 'ORGANIZATION',
    p_child_id                              IN      NUMBER,
    p_child_table_name                      IN      VARCHAR2 := 'HZ_PARTIES',
    p_child_object_type                     IN      VARCHAR2 := 'ORGANIZATION',
    p_effective_date                        IN      DATE := SYSDATE,
    x_result                                OUT NOCOPY     VARCHAR2,
    x_level_number                          OUT NOCOPY     NUMBER,
    x_return_status                         OUT NOCOPY     VARCHAR2,
    x_msg_count                             OUT NOCOPY     NUMBER,
    x_msg_data                              OUT NOCOPY     VARCHAR2
) IS

    l_result                                        VARCHAR2(1) := 'N';
    l_level_number                                  NUMBER := -1;
    l_debug_prefix				    VARCHAR2(30) := '';

BEGIN

    -- Check if API is called in debug mode. If yes, enable debug.
    --enable_debug;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'check_parent_child (+)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
    END IF;

    --Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    --Initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    validate_input (
        p_hierarchy_type         => p_hierarchy_type,
        p_parent_table_name      => p_parent_table_name,
        p_parent_object_type     => p_parent_object_type,
        p_child_table_name       => p_child_table_name,
        p_child_object_type      => p_child_object_type,
        p_no_of_records          => 1,
        x_return_status          => x_return_status
    );

    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    BEGIN
        SELECT 'Y', LEVEL_NUMBER
        INTO   l_result, l_level_number
        FROM   HZ_HIERARCHY_NODES
        WHERE  PARENT_ID = p_parent_id
        AND    PARENT_TABLE_NAME = p_parent_table_name
        AND    PARENT_OBJECT_TYPE = p_parent_object_type
        AND    HIERARCHY_TYPE = p_hierarchy_type
        AND    CHILD_ID = p_child_id
        AND    CHILD_TABLE_NAME = p_child_table_name
        AND    CHILD_OBJECT_TYPE = p_child_object_type
        AND    p_effective_date BETWEEN EFFECTIVE_START_DATE AND EFFECTIVE_END_DATE
        AND    LEVEL_NUMBER > 0
        AND    ROWNUM = 1;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            x_result := 'N';
            x_level_number := -1;
    END;

    IF l_result = 'Y' THEN
        x_result := 'Y';
        x_level_number := l_level_number;
    ELSE
        x_result := 'N';
        x_level_number := -1;
    END IF;

    --Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data );

    -- Debug info.
    IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
	 hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
	                       p_msg_data=>x_msg_data,
			       p_msg_type=>'WARNING',
			       p_msg_level=>fnd_log.level_exception);
    END IF;
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'check_parent_child (-)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Check if API is called in debug mode. If yes, disable debug.
    --disable_debug;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        x_result := 'N';
        x_level_number := -1;

        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data );

        -- Debug info.
	IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
		 hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
	                       p_msg_data=>x_msg_data,
			       p_msg_type=>'ERROR',
			       p_msg_level=>fnd_log.level_error);
        END IF;
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	    hz_utility_v2pub.debug(p_message=>'check_parent_child (-)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
        END IF;

        -- Check if API is called in debug mode. If yes, disable debug.
        --disable_debug;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_result := 'N';
        x_level_number := -1;

        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data );

        -- Debug info.
	IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
	                       p_msg_data=>x_msg_data,
			       p_msg_type=>'UNEXPECTED ERROR',
			       p_msg_level=>fnd_log.level_error);
        END IF;
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'check_parent_child (-)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
        END IF;

        -- Check if API is called in debug mode. If yes, disable debug.
        --disable_debug;

    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_result := 'N';
        x_level_number := -1;

        FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_OTHERS_EXCEP' );
        FND_MESSAGE.SET_TOKEN( 'ERROR' ,SQLERRM );
        FND_MSG_PUB.ADD;

        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data );

        -- Debug info.
	IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
             hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
	                       p_msg_data=>x_msg_data,
			       p_msg_type=>'SQL ERROR',
			       p_msg_level=>fnd_log.level_error);
        END IF;
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	    hz_utility_v2pub.debug(p_message=>'check_parent_child (-)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
        END IF;

        -- Check if API is called in debug mode. If yes, disable debug.
        --disable_debug;

END check_parent_child;

PROCEDURE get_parent_nodes(
    p_init_msg_list                         IN      VARCHAR2 := FND_API.G_FALSE,
    p_hierarchy_type                        IN      VARCHAR2,
    p_child_id                              IN      NUMBER,
    p_child_table_name                      IN      VARCHAR2,
    p_child_object_type                     IN      VARCHAR2,
    p_parent_table_name                     IN      VARCHAR2,
    p_parent_object_type                    IN      VARCHAR2,
    p_include_node                          IN      VARCHAR2 := 'Y',
    p_effective_date                        IN      DATE := SYSDATE,
    p_no_of_records                         IN      NUMBER := 100,
    x_related_nodes_list                    OUT NOCOPY    RELATED_NODES_LIST_TYPE,
    x_return_status                         OUT NOCOPY     VARCHAR2,
    x_msg_count                             OUT NOCOPY     NUMBER,
    x_msg_data                              OUT NOCOPY     VARCHAR2
) IS

    TYPE parent_id_type                     IS TABLE OF hz_hierarchy_nodes.parent_id%TYPE;
    TYPE parent_table_name_type             IS TABLE OF hz_hierarchy_nodes.parent_table_name%TYPE;
    TYPE parent_object_type_type            IS TABLE OF hz_hierarchy_nodes.parent_object_type%TYPE;
    TYPE level_number_type                  IS TABLE OF hz_hierarchy_nodes.level_number%TYPE;
    TYPE top_parent_flag_type               IS TABLE OF hz_hierarchy_nodes.top_parent_flag%TYPE;
    TYPE leaf_child_flag_type               IS TABLE OF hz_hierarchy_nodes.leaf_child_flag%TYPE;
    TYPE effective_start_date_type          IS TABLE OF hz_hierarchy_nodes.effective_start_date%TYPE;
    TYPE effective_end_date_type            IS TABLE OF hz_hierarchy_nodes.effective_end_date%TYPE;
    TYPE relationship_id_type               IS TABLE OF hz_hierarchy_nodes.relationship_id%TYPE;

    parent_id_list                          parent_id_type;
    parent_table_name_list                  parent_table_name_type;
    parent_object_type_list                 parent_object_type_type;
    level_number_list                       level_number_type;
    top_parent_flag_list                    top_parent_flag_type;
    leaf_child_flag_list                    leaf_child_flag_type;
    effective_start_date_list               effective_start_date_type;
    effective_end_date_list                 effective_end_date_type;
    relationship_id_list                    relationship_id_type;
    l_debug_prefix			    VARCHAR2(30) := '';

    -- cursor to get all the parent nodes (optionally including
    -- the self node as well) for the given hierarchy
    CURSOR c1 is
    SELECT PARENT_ID,
           PARENT_TABLE_NAME,
           PARENT_OBJECT_TYPE,
           LEVEL_NUMBER,
           TOP_PARENT_FLAG,
           LEAF_CHILD_FLAG,
           EFFECTIVE_START_DATE,
           EFFECTIVE_END_DATE,
           RELATIONSHIP_ID
    FROM   HZ_HIERARCHY_NODES
    WHERE  CHILD_ID = p_child_id
    AND    CHILD_TABLE_NAME = p_child_table_name
    AND    CHILD_OBJECT_TYPE = p_child_object_type
    AND    PARENT_TABLE_NAME LIKE p_parent_table_name||'%'
    AND    PARENT_OBJECT_TYPE LIKE p_parent_object_type||'%'
    AND    HIERARCHY_TYPE = p_hierarchy_type
    AND    p_effective_date BETWEEN EFFECTIVE_START_DATE AND EFFECTIVE_END_DATE
    AND    LEVEL_NUMBER <> DECODE(p_include_node, 'N', 0, 'Y', -1, NULL, -1);

BEGIN

    -- Check if API is called in debug mode. If yes, enable debug.
    --enable_debug;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'get_parent_nodes (+)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
    END IF;

    --Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    --Initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    HZ_UTILITY_V2PUB.validate_mandatory (
        p_create_update_flag     => 'C',
        p_column                 => 'p_child_id',
        p_column_value           => p_child_id,
        x_return_status          => x_return_status);

    HZ_UTILITY_V2PUB.validate_mandatory (
        p_create_update_flag     => 'C',
        p_column                 => 'p_child_table_name',
        p_column_value           => p_child_table_name,
        x_return_status          => x_return_status);

    HZ_UTILITY_V2PUB.validate_mandatory (
        p_create_update_flag     => 'C',
        p_column                 => 'p_child_object_type',
        p_column_value           => p_child_object_type,
        x_return_status          => x_return_status);

    validate_input (
        p_hierarchy_type         => p_hierarchy_type,
        p_child_table_name       => p_child_table_name,
        p_child_object_type      => p_child_object_type,
        p_parent_table_name      => p_parent_table_name,
        p_parent_object_type     => p_parent_object_type,
        p_no_of_records          => p_no_of_records,
        x_return_status          => x_return_status
    );

    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    OPEN c1;

    -- do a bulk fetch of the parent records
    FETCH c1 BULK COLLECT INTO
        parent_id_list,
        parent_table_name_list,
        parent_object_type_list,
        level_number_list,
        top_parent_flag_list,
        leaf_child_flag_list,
        effective_start_date_list,
        effective_end_date_list,
        relationship_id_list LIMIT p_no_of_records;

    FOR i IN 1..parent_id_list.COUNT LOOP
        x_related_nodes_list(i).related_node_id := parent_id_list(i);
        x_related_nodes_list(i).related_node_table_name := parent_table_name_list(i);
        x_related_nodes_list(i).related_node_object_type := parent_object_type_list(i);
        x_related_nodes_list(i).level_number := level_number_list(i);
        x_related_nodes_list(i).top_parent_flag := top_parent_flag_list(i);
        x_related_nodes_list(i).leaf_child_flag := leaf_child_flag_list(i);
        x_related_nodes_list(i).effective_start_date := effective_start_date_list(i);
        x_related_nodes_list(i).effective_end_date := effective_end_date_list(i);
        x_related_nodes_list(i).relationship_id := relationship_id_list(i);
    END LOOP;

    CLOSE c1;

    --Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data );

    -- Debug info.
    IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
	 hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
	                       p_msg_data=>x_msg_data,
			       p_msg_type=>'WARNING',
			       p_msg_level=>fnd_log.level_exception);
    END IF;
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'get_parent_nodes (-)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Check if API is called in debug mode. If yes, disable debug.
    --disable_debug;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;

        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data );

        -- Debug info.
	IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
		 hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
	                       p_msg_data=>x_msg_data,
			       p_msg_type=>'ERROR',
			       p_msg_level=>fnd_log.level_error);
        END IF;
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	    hz_utility_v2pub.debug(p_message=>'get_parent_nodes (-)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
        END IF;

        -- Check if API is called in debug mode. If yes, disable debug.
        --disable_debug;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data );

        -- Debug info.
	IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
	                       p_msg_data=>x_msg_data,
			       p_msg_type=>'UNEXPECTED ERROR',
			       p_msg_level=>fnd_log.level_error);
        END IF;
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=> 'get_parent_nodes (-)' ,
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
        END IF;

        -- Check if API is called in debug mode. If yes, disable debug.
        --disable_debug;

    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_OTHERS_EXCEP' );
        FND_MESSAGE.SET_TOKEN( 'ERROR' ,SQLERRM );
        FND_MSG_PUB.ADD;

        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data );

        -- Debug info.
	IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
             hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
	                       p_msg_data=>x_msg_data,
			       p_msg_type=>'SQL ERROR',
			       p_msg_level=>fnd_log.level_error);
        END IF;
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	    hz_utility_v2pub.debug(p_message=>'get_parent_nodes (-)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
        END IF;

        -- Check if API is called in debug mode. If yes, disable debug.
        --disable_debug;

END get_parent_nodes;


PROCEDURE get_child_nodes(
    p_init_msg_list                         IN      VARCHAR2 := FND_API.G_FALSE,
    p_hierarchy_type                        IN      VARCHAR2,
    p_parent_id                             IN      NUMBER,
    p_parent_table_name                     IN      VARCHAR2,
    p_parent_object_type                    IN      VARCHAR2,
    p_child_table_name                      IN      VARCHAR2,
    p_child_object_type                     IN      VARCHAR2,
    p_include_node                          IN      VARCHAR2 := 'Y',
    p_effective_date                        IN      DATE := SYSDATE,
    p_no_of_records                         IN      NUMBER := 100,
    x_related_nodes_list                    OUT NOCOPY    RELATED_NODES_LIST_TYPE,
    x_return_status                         OUT NOCOPY     VARCHAR2,
    x_msg_count                             OUT NOCOPY     NUMBER,
    x_msg_data                              OUT NOCOPY     VARCHAR2
) IS


    TYPE child_id_type                      IS TABLE OF hz_hierarchy_nodes.child_id%TYPE;
    TYPE child_table_name_type              IS TABLE OF hz_hierarchy_nodes.child_table_name%TYPE;
    TYPE child_object_type_type             IS TABLE OF hz_hierarchy_nodes.child_object_type%TYPE;
    TYPE level_number_type                  IS TABLE OF hz_hierarchy_nodes.level_number%TYPE;
    TYPE top_parent_flag_type               IS TABLE OF hz_hierarchy_nodes.top_parent_flag%TYPE;
    TYPE leaf_child_flag_type               IS TABLE OF hz_hierarchy_nodes.leaf_child_flag%TYPE;
    TYPE effective_start_date_type          IS TABLE OF hz_hierarchy_nodes.effective_start_date%TYPE;
    TYPE effective_end_date_type            IS TABLE OF hz_hierarchy_nodes.effective_end_date%TYPE;
    TYPE relationship_id_type               IS TABLE OF hz_hierarchy_nodes.relationship_id%TYPE;

    child_id_list                           child_id_type;
    child_table_name_list                   child_table_name_type;
    child_object_type_list                  child_object_type_type;
    level_number_list                       level_number_type;
    top_parent_flag_list                    top_parent_flag_type;
    leaf_child_flag_list                    leaf_child_flag_type;
    effective_start_date_list               effective_start_date_type;
    effective_end_date_list                 effective_end_date_type;
    relationship_id_list                    relationship_id_type;
    l_debug_prefix			    VARCHAR2(30) := '';

    CURSOR c1 IS
    SELECT CHILD_ID,
           CHILD_TABLE_NAME,
           CHILD_OBJECT_TYPE,
           LEVEL_NUMBER,
           TOP_PARENT_FLAG,
           LEAF_CHILD_FLAG,
           EFFECTIVE_START_DATE,
           EFFECTIVE_END_DATE,
           RELATIONSHIP_ID
    FROM   HZ_HIERARCHY_NODES
    WHERE  PARENT_ID = p_parent_id
    AND    PARENT_TABLE_NAME = p_parent_table_name
    AND    PARENT_OBJECT_TYPE = p_parent_object_type
    AND    CHILD_TABLE_NAME LIKE p_child_table_name||'%'
    AND    CHILD_OBJECT_TYPE LIKE p_child_object_type||'%'
    AND    HIERARCHY_TYPE = p_hierarchy_type
    AND    p_effective_date BETWEEN EFFECTIVE_START_DATE AND EFFECTIVE_END_DATE
    AND    LEVEL_NUMBER <> DECODE(p_include_node, 'N', 0, 'Y', -1, NULL, -1);

BEGIN

    -- Check if API is called in debug mode. If yes, enable debug.
    --enable_debug;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'get_child_nodes (+)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
    END IF;

    --Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    --Initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    HZ_UTILITY_V2PUB.validate_mandatory (
        p_create_update_flag     => 'C',
        p_column                 => 'p_parent_id',
        p_column_value           => p_parent_id,
        x_return_status          => x_return_status);

    HZ_UTILITY_V2PUB.validate_mandatory (
        p_create_update_flag     => 'C',
        p_column                 => 'p_parent_table_name',
        p_column_value           => p_parent_table_name,
        x_return_status          => x_return_status);

    HZ_UTILITY_V2PUB.validate_mandatory (
        p_create_update_flag     => 'C',
        p_column                 => 'p_parent_object_type',
        p_column_value           => p_parent_object_type,
        x_return_status          => x_return_status);

    validate_input (
        p_hierarchy_type         => p_hierarchy_type,
        p_child_table_name       => p_child_table_name,
        p_child_object_type      => p_child_object_type,
        p_parent_table_name      => p_parent_table_name,
        p_parent_object_type     => p_parent_object_type,
        p_no_of_records          => p_no_of_records,
        x_return_status          => x_return_status
    );

    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    OPEN c1;

    -- do a bulk fetch of the parent records
    FETCH c1 BULK COLLECT INTO
        child_id_list,
        child_table_name_list,
        child_object_type_list,
        level_number_list,
        top_parent_flag_list,
        leaf_child_flag_list,
        effective_start_date_list,
        effective_end_date_list,
        relationship_id_list LIMIT p_no_of_records;

    FOR i IN 1..child_id_list.COUNT LOOP
        x_related_nodes_list(i).related_node_id := child_id_list(i);
        x_related_nodes_list(i).related_node_table_name := child_table_name_list(i);
        x_related_nodes_list(i).related_node_object_type := child_object_type_list(i);
        x_related_nodes_list(i).level_number := level_number_list(i);
        x_related_nodes_list(i).top_parent_flag := top_parent_flag_list(i);
        x_related_nodes_list(i).leaf_child_flag := leaf_child_flag_list(i);
        x_related_nodes_list(i).effective_start_date := effective_start_date_list(i);
        x_related_nodes_list(i).effective_end_date := effective_end_date_list(i);
        x_related_nodes_list(i).relationship_id := relationship_id_list(i);
    END LOOP;

    CLOSE c1;

    --Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data );

    -- Debug info.
    IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
	 hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
	                       p_msg_data=>x_msg_data,
			       p_msg_type=>'WARNING',
			       p_msg_level=>fnd_log.level_exception);
    END IF;
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'get_child_nodes (-)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Check if API is called in debug mode. If yes, disable debug.
    --disable_debug;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;

        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data );

        -- Debug info.
	IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
		 hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
	                       p_msg_data=>x_msg_data,
			       p_msg_type=>'ERROR',
			       p_msg_level=>fnd_log.level_error);
        END IF;
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	    hz_utility_v2pub.debug(p_message=>'get_child_nodes (-)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
        END IF;

        -- Check if API is called in debug mode. If yes, disable debug.
        --disable_debug;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data );

        -- Debug info.
	IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
	                       p_msg_data=>x_msg_data,
			       p_msg_type=>'UNEXPECTED ERROR',
			       p_msg_level=>fnd_log.level_error);
        END IF;
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'get_child_nodes (-)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
        END IF;

        -- Check if API is called in debug mode. If yes, disable debug.
        --disable_debug;

    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_OTHERS_EXCEP' );
        FND_MESSAGE.SET_TOKEN( 'ERROR' ,SQLERRM );
        FND_MSG_PUB.ADD;

        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data );

        -- Debug info.
	IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
             hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
	                       p_msg_data=>x_msg_data,
			       p_msg_type=>'SQL ERROR',
			       p_msg_level=>fnd_log.level_error);
        END IF;
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	    hz_utility_v2pub.debug(p_message=>'get_child_nodes (-)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
        END IF;

        -- Check if API is called in debug mode. If yes, disable debug.
        --disable_debug;

END get_child_nodes;

PROCEDURE get_top_parent_nodes(
    p_init_msg_list                         IN      VARCHAR2 := FND_API.G_FALSE,
    p_hierarchy_type                        IN      VARCHAR2,
    p_parent_table_name                     IN      VARCHAR2 := 'HZ_PARTIES',
    p_parent_object_type                    IN      VARCHAR2 := 'ALL',
    p_effective_date                        IN      DATE := SYSDATE,
    p_no_of_records                         IN      NUMBER := 100,
    x_top_parent_list                       OUT NOCOPY    RELATED_NODES_LIST_TYPE,
    x_return_status                         OUT NOCOPY     VARCHAR2,
    x_msg_count                             OUT NOCOPY     NUMBER,
    x_msg_data                              OUT NOCOPY     VARCHAR2
) IS

    TYPE parent_id_type                     IS TABLE OF hz_hierarchy_nodes.parent_id%TYPE;
    TYPE parent_table_name_type             IS TABLE OF hz_hierarchy_nodes.parent_table_name%TYPE;
    TYPE parent_object_type_type            IS TABLE OF hz_hierarchy_nodes.parent_object_type%TYPE;
    TYPE level_number_type                  IS TABLE OF hz_hierarchy_nodes.level_number%TYPE;
    TYPE top_parent_flag_type               IS TABLE OF hz_hierarchy_nodes.top_parent_flag%TYPE;
    TYPE leaf_child_flag_type               IS TABLE OF hz_hierarchy_nodes.leaf_child_flag%TYPE;
    TYPE effective_start_date_type          IS TABLE OF hz_hierarchy_nodes.effective_start_date%TYPE;
    TYPE effective_end_date_type            IS TABLE OF hz_hierarchy_nodes.effective_end_date%TYPE;
    TYPE relationship_id_type               IS TABLE OF hz_hierarchy_nodes.relationship_id%TYPE;
    TYPE entity_id_type                     IS TABLE OF NUMBER;

    parent_id_list                          parent_id_type;
    parent_table_name_list                  parent_table_name_type;
    parent_object_type_list                 parent_object_type_type;
    level_number_list                       level_number_type;
    top_parent_flag_list                    top_parent_flag_type;
    leaf_child_flag_list                    leaf_child_flag_type;
    effective_start_date_list               effective_start_date_type;
    effective_end_date_list                 effective_end_date_type;
    relationship_id_list                    relationship_id_type;
    entity_id_list                          entity_id_type;

    l_incl_unrelated_entities               VARCHAR2(1);
    l_count                                 NUMBER := 0;
    l_ret                                   VARCHAR2(1) := 'N';
    l_object_name                           VARCHAR2(80);
    l_column_name                           VARCHAR2(80);
    l_predicate                             VARCHAR2(80);
    l_str                                   VARCHAR2(2000);
    l_limit                                 NUMBER := p_no_of_records;

    -- cursor to get all the parent nodes from given hierarchy
    CURSOR c2 IS
    SELECT PARENT_ID,
           PARENT_TABLE_NAME,
           PARENT_OBJECT_TYPE,
           LEVEL_NUMBER,
           TOP_PARENT_FLAG,
           LEAF_CHILD_FLAG,
           EFFECTIVE_START_DATE,
           EFFECTIVE_END_DATE,
           RELATIONSHIP_ID
    FROM   HZ_HIERARCHY_NODES
    WHERE  HIERARCHY_TYPE = p_hierarchy_type
    AND    PARENT_TABLE_NAME LIKE p_parent_table_name||'%'
    AND    PARENT_OBJECT_TYPE LIKE p_parent_object_type||'%'
    AND    TOP_PARENT_FLAG = 'Y'
    AND    p_effective_date BETWEEN EFFECTIVE_START_DATE AND EFFECTIVE_END_DATE
    AND    LEVEL_NUMBER = 0;

    -- cursor to read object type setup
    CURSOR c_obj_inst IS
    SELECT OBJ_NAME,
           PK1_COLUMN_NAME,
           PREDICATE
    FROM   FND_OBJECTS FO,
           FND_OBJECT_INSTANCE_SETS FOIS
    WHERE  FOIS.INSTANCE_SET_NAME = p_parent_object_type
    AND    FOIS.OBJECT_ID = FO.OBJECT_ID;

    TYPE ref_cur_type IS REF CURSOR;
    ref_cur          ref_cur_type;
    l_debug_prefix   VARCHAR2(30) := '';

BEGIN

    -- Check if API is called in debug mode. If yes, enable debug.
    --enable_debug;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'get_top_parent_nodes (+)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
    END IF;

    --Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    --Initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    validate_input (
        p_hierarchy_type         => p_hierarchy_type,
        p_parent_table_name      => p_parent_table_name,
        p_parent_object_type     => p_parent_object_type,
        p_no_of_records          => p_no_of_records,
        x_return_status          => x_return_status
    );

    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    OPEN c2;

    FETCH c2 BULK COLLECT INTO
        parent_id_list,
        parent_table_name_list,
        parent_object_type_list,
        level_number_list,
        top_parent_flag_list,
        leaf_child_flag_list,
        effective_start_date_list,
        effective_end_date_list,
        relationship_id_list LIMIT l_limit;

    CLOSE c2;

    FOR i IN 1..parent_id_list.COUNT LOOP
        x_top_parent_list(i).related_node_id := parent_id_list(i);
        x_top_parent_list(i).related_node_table_name := parent_table_name_list(i);
        x_top_parent_list(i).related_node_object_type := parent_object_type_list(i);
        x_top_parent_list(i).level_number := level_number_list(i);
        x_top_parent_list(i).top_parent_flag := top_parent_flag_list(i);
        x_top_parent_list(i).leaf_child_flag := leaf_child_flag_list(i);
        x_top_parent_list(i).effective_start_date := effective_start_date_list(i);
        x_top_parent_list(i).effective_end_date := effective_end_date_list(i);
        x_top_parent_list(i).relationship_id := relationship_id_list(i);
        l_count := i;
    END LOOP;

    -- now check if the relationship type tells to include unrelated entities
    l_incl_unrelated_entities := HZ_UTILITY_V2PUB.incl_unrelated_entities(p_hierarchy_type);

    IF l_incl_unrelated_entities = 'Y' THEN
        IF l_count < 100 THEN
            l_limit := l_limit - l_count;
        END IF;
        -- build the string
        OPEN c_obj_inst;
        FETCH c_obj_inst INTO l_object_name, l_column_name, l_predicate;
        CLOSE c_obj_inst;

        -- Bug 4673713.
        IF l_predicate IS NOT NULL THEN
            l_str := 'select '||l_column_name||' from '||l_object_name||' where '||l_predicate||' and rownum <= :1';
        l_count := l_count + 1;
        OPEN ref_cur FOR l_str using l_limit;
        LOOP
            FETCH ref_cur INTO x_top_parent_list(l_count).related_node_id;
            EXIT WHEN ref_cur%NOTFOUND;
            l_count := l_count + 1;
        END LOOP;

        ELSE
            l_str := 'select '||l_column_name||' from '||l_object_name||' where rownum <= :1';

        l_count := l_count + 1;
        OPEN ref_cur FOR l_str using l_limit;
        LOOP
            FETCH ref_cur INTO x_top_parent_list(l_count).related_node_id;
            EXIT WHEN ref_cur%NOTFOUND;
            l_count := l_count + 1;
        END LOOP;
        END IF;


    END IF;

    --Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data );

    -- Debug info.
    IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
	 hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
	                       p_msg_data=>x_msg_data,
			       p_msg_type=>'WARNING',
			       p_msg_level=>fnd_log.level_exception);
    END IF;
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'get_top_parent_nodes (-)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Check if API is called in debug mode. If yes, disable debug.
    --disable_debug;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;

        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data );

        -- Debug info.
	IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
		 hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
	                       p_msg_data=>x_msg_data,
			       p_msg_type=>'ERROR',
			       p_msg_level=>fnd_log.level_error);
        END IF;
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	    hz_utility_v2pub.debug(p_message=>'get_top_parent_nodes (-)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
        END IF;

        -- Check if API is called in debug mode. If yes, disable debug.
        --disable_debug;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data );

        -- Debug info.
	IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
	                       p_msg_data=>x_msg_data,
			       p_msg_type=>'UNEXPECTED ERROR',
			       p_msg_level=>fnd_log.level_error);
        END IF;
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'get_top_parent_nodes (-)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
        END IF;

        -- Check if API is called in debug mode. If yes, disable debug.
        --disable_debug;

    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_OTHERS_EXCEP' );
        FND_MESSAGE.SET_TOKEN( 'ERROR' ,SQLERRM );
        FND_MSG_PUB.ADD;

        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data );

        -- Debug info.
	IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
             hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
	                       p_msg_data=>x_msg_data,
			       p_msg_type=>'SQL ERROR',
			       p_msg_level=>fnd_log.level_error);
        END IF;
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	    hz_utility_v2pub.debug(p_message=>'get_top_parent_nodes (-)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
        END IF;
        -- Check if API is called in debug mode. If yes, disable debug.
        --disable_debug;

END get_top_parent_nodes;

END HZ_HIERARCHY_V2PUB;

/
