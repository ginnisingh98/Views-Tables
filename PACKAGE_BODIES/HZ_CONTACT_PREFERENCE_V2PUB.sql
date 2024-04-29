--------------------------------------------------------
--  DDL for Package Body HZ_CONTACT_PREFERENCE_V2PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_CONTACT_PREFERENCE_V2PUB" AS
/* $Header: ARH2CTSB.pls 120.5 2005/12/07 19:30:29 acng ship $ */

--------------------------------------
-- package global variable declaration
--------------------------------------

G_DEBUG_COUNT             NUMBER := 0;
--G_DEBUG                   BOOLEAN := FALSE;

------------------------------------
-- declaration of private procedures
------------------------------------

/*PROCEDURE enable_debug;

PROCEDURE disable_debug;
*/

PROCEDURE do_create_contact_preference(
    p_contact_preference_rec            IN OUT NOCOPY  CONTACT_PREFERENCE_REC_TYPE,
    x_contact_preference_id             OUT NOCOPY     NUMBER,
    x_return_status                     IN OUT NOCOPY  VARCHAR2
);

PROCEDURE do_update_contact_preference(
    p_contact_preference_rec            IN OUT NOCOPY  CONTACT_PREFERENCE_REC_TYPE,
    p_object_version_number             IN OUT NOCOPY  NUMBER,
    x_return_status                     IN OUT NOCOPY  VARCHAR2
);

--------------------------------------
-- private procedures and functions
--------------------------------------

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
 *   07-23-2001    Kate Shan             o Created.
 *
 */

/*PROCEDURE enable_debug IS

BEGIN

    G_DEBUG_COUNT := G_DEBUG_COUNT + 1;

    IF G_DEBUG_COUNT = 1 THEN
        IF FND_PROFILE.value( 'HZ_API_FILE_DEBUG_ON' ) = 'Y' OR
           FND_PROFILE.value( 'HZ_API_DBMS_DEBUG_ON' ) = 'Y'
        THEN
           HZ_UTILITY_V2PUB.enable_debug;
           G_DEBUG := TRUE;
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
 *     HZ_UTILITY_V2PUB.disable_debug
 *
 * MODIFICATION HISTORY
 *
 *   07-23-2001    Kate Shan                    o Created.
 *
 */

/*PROCEDURE disable_debug IS

BEGIN

    IF G_DEBUG THEN
        G_DEBUG_COUNT := G_DEBUG_COUNT - 1;

        IF G_DEBUG_COUNT = 0 THEN
            HZ_UTILITY_V2PUB.disable_debug;
            G_DEBUG := FALSE;
        END IF;
    END IF;

END disable_debug;
*/

/**
*  PROCEDURE
*              do_create_contact_preference
*
*  DESCRIPTION
*               Creates contact preference
*
*  SCOPE - PRIVATE
*
*  EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
*
*  ARGUMENTS  : IN:
*               OUT:
*                     x_contact_preference_id        Contact Preference ID
*           IN/ OUT:
*                     p_contact_preference_rec       Contact Preference Record
*                     x_return_status                Return status after the call. The status can
*                                                    be FND_API.G_RET_STS_SUCCESS (success),
*                                                    FND_API.G_RET_STS_ERROR (error),
*                                                    FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
*
* RETURNS    : NONE
*
*  NOTES
*
*  MODIFICATION HISTORY
*    07-23-2001    Kate Shan           o Created.
*
*/

PROCEDURE do_create_contact_preference(
    p_contact_preference_rec            IN OUT NOCOPY  CONTACT_PREFERENCE_REC_TYPE,
    x_contact_preference_id             OUT NOCOPY     NUMBER,
    x_return_status                     IN OUT NOCOPY  VARCHAR2
) IS
    l_debug_prefix                      VARCHAR2(30) := ''; --'do_create_contact_preference';

    l_dummy                             VARCHAR2(1);
    l_rowid                             ROWID;

BEGIN
    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'do_create_contact_preference (+)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
    END IF;

    ----------------------------------------------
    -- if preference_start_date is null, give sysdate
    ----------------------------------------------
    IF p_contact_preference_rec.preference_start_date is null or
       p_contact_preference_rec.preference_start_date = FND_API.G_MISS_DATE THEN
           p_contact_preference_rec.preference_start_date := sysdate;
    END IF;


    -- Validate contact preference  record
    HZ_CONTACT_PREFERENCE_VALIDATE.validate_contact_preference(
        'C',
        p_contact_preference_rec,
        l_rowid,
        x_return_status);

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'HZ_CONTACT_PREFERENCES_PKG.Insert_Row (+) ',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- call table handler to insert a row
    HZ_CONTACT_PREFERENCES_PKG.Insert_Row (
        X_Rowid                                 => l_rowid,
        X_CONTACT_PREFERENCE_ID                 => p_contact_preference_rec.contact_preference_id,
        X_CONTACT_LEVEL_TABLE                   => p_contact_preference_rec.contact_level_table,
        X_CONTACT_LEVEL_TABLE_ID                => p_contact_preference_rec.contact_level_table_id,
        X_CONTACT_TYPE                          => p_contact_preference_rec.contact_type,
        X_PREFERENCE_CODE                       => p_contact_preference_rec.preference_code,
        X_PREFERENCE_TOPIC_TYPE                => p_contact_preference_rec.preference_topic_type,
        X_PREFERENCE_TOPIC_TYPE_ID             => p_contact_preference_rec.preference_topic_type_id,
        X_PREFERENCE_TOPIC_TYPE_CODE           => p_contact_preference_rec.preference_topic_type_code,
        X_PREFERENCE_START_DATE                 => p_contact_preference_rec.preference_start_date,
        X_PREFERENCE_END_DATE                   => p_contact_preference_rec.preference_end_date,
        X_PREFERENCE_START_TIME_HR              => p_contact_preference_rec.preference_start_time_hr,
        X_PREFERENCE_END_TIME_HR                => p_contact_preference_rec.preference_end_time_hr,
        X_PREFERENCE_START_TIME_MI              => p_contact_preference_rec.preference_start_time_mi,
        X_PREFERENCE_END_TIME_MI                => p_contact_preference_rec.preference_end_time_mi,
        X_MAX_NO_OF_INTERACTIONS                => p_contact_preference_rec.max_no_of_interactions,
        X_MAX_NO_OF_INTERACT_UOM_CODE           => p_contact_preference_rec.max_no_of_interact_uom_code,
        X_REQUESTED_BY                          => p_contact_preference_rec.requested_by,
        X_REASON_CODE                           => p_contact_preference_rec.reason_code,
        X_STATUS                                => p_contact_preference_rec.status,
        X_OBJECT_VERSION_NUMBER                 => 1,
        X_CREATED_BY_MODULE                     => p_contact_preference_rec.created_by_module,
        X_APPLICATION_ID                        => p_contact_preference_rec.application_id
    );

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'HZ_CONTACT_PREFERENCES_PKG.Insert_Row (-) ' ||
				 'x_contact_preference_id = ' || p_contact_preference_rec.contact_preference_id,
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- assign the primary key back
    x_contact_preference_id := p_contact_preference_rec.contact_preference_id;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'do_create_contact_preference (-)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
    END IF;

END do_create_contact_preference;


/**
*  PROCEDURE
*               do_update_contact_preference_
*
*  DESCRIPTION
*               Private procedure to update contact preference
*  EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
*      HZ_REGRISTRY_VALIDATE_V2PUB.validate_contact_preference
*      HZ_CONTACT_PREFERENCES_PKG.Update_Row
*
* SCOPE - PRIVATE
*
*  EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
*
*  ARGUMENTS  : IN:
*               OUT:
*           IN/ OUT:
*                     p_contact_preference_rec   Contact preference record
*                     p_object_version_number    Used for locking the being updated record.
*                      x_return_status            Return status after the call. The status can
*                                                be FND_API.G_RET_STS_SUCCESS (success),
*                                                FND_API.G_RET_STS_ERROR (error),
*                                                FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
*
*  RETURNS    : NONE
*
*  NOTES
*
*  MODIFICATION HISTORY
*    07-23-2001    Kate Shan              o Created.
*
*
*/

PROCEDURE do_update_contact_preference(
    p_contact_preference_rec            IN OUT NOCOPY  CONTACT_PREFERENCE_REC_TYPE,
    p_object_version_number             IN OUT NOCOPY  NUMBER,
    x_return_status                     IN OUT NOCOPY  VARCHAR2
) IS
    l_debug_prefix                              VARCHAR2(30) := ''; --'do_update_contact_preference';

    l_rowid                                     ROWID  := NULL;
    l_object_version_number                     NUMBER;
    l_party_id                                  NUMBER;
    l_native_language                           VARCHAR2(1);
    l_language_name                             VARCHAR2(4);

BEGIN

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'do_update_contact_preference (+)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- check whether record has been updated by another user
    BEGIN
        -- check last update date.
        SELECT rowid, object_version_number
        INTO l_rowid, l_object_version_number
        FROM HZ_CONTACT_PREFERENCES
        WHERE contact_preference_id = p_contact_preference_rec.contact_preference_id

        FOR UPDATE NOWAIT;

	IF NOT (
            ( p_object_version_number IS NULL AND l_object_version_number IS NULL ) OR
            ( p_object_version_number IS NOT NULL AND
              l_object_version_number IS NOT NULL AND
              p_object_version_number = l_object_version_number ) )
        THEN
            FND_MESSAGE.SET_NAME('AR', 'HZ_API_RECORD_CHANGED');
            FND_MESSAGE.SET_TOKEN('TABLE', 'hz_contact_preferences');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        END IF;

        p_object_version_number := nvl(l_object_version_number, 1) + 1;

    EXCEPTION WHEN NO_DATA_FOUND THEN
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_NO_RECORD');
        FND_MESSAGE.SET_TOKEN('RECORD', 'contact_preference');
        FND_MESSAGE.SET_TOKEN('VALUE', NVL(TO_CHAR( p_contact_preference_rec.contact_preference_id), 'null'));
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END;

    ----------------------------------------------
    -- if preference_start_date is null, give sysdate
    ----------------------------------------------
    IF p_contact_preference_rec.preference_start_date = FND_API.G_MISS_DATE THEN
           p_contact_preference_rec.preference_start_date := sysdate;
    END IF;

    -- validate contact preference record
    HZ_CONTACT_PREFERENCE_VALIDATE.validate_contact_preference(
        'U',
        p_contact_preference_rec,
        l_rowid,
        x_return_status);

    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'HZ_CONTACT_PREFERENCES_PKG.Update_Row (+)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- call table handler to update a row
    HZ_CONTACT_PREFERENCES_PKG.Update_Row (
        X_Rowid                                 => l_rowid,
        X_CONTACT_PREFERENCE_ID                 => p_contact_preference_rec.contact_preference_id,
        X_CONTACT_LEVEL_TABLE                   => p_contact_preference_rec.contact_level_table,
        X_CONTACT_LEVEL_TABLE_ID                => p_contact_preference_rec.contact_level_table_id,
        X_CONTACT_TYPE                          => p_contact_preference_rec.contact_type,
        X_PREFERENCE_CODE                       => p_contact_preference_rec.preference_code,
        X_PREFERENCE_TOPIC_TYPE                => p_contact_preference_rec.preference_topic_type,
        X_PREFERENCE_TOPIC_TYPE_ID             => p_contact_preference_rec.preference_topic_type_id,
        X_PREFERENCE_TOPIC_TYPE_CODE           => p_contact_preference_rec.preference_topic_type_code,
        X_PREFERENCE_START_DATE                 => p_contact_preference_rec.preference_start_date,
        X_PREFERENCE_END_DATE                   => p_contact_preference_rec.preference_end_date,
        X_PREFERENCE_START_TIME_HR              => p_contact_preference_rec.preference_start_time_hr,
        X_PREFERENCE_END_TIME_HR                => p_contact_preference_rec.preference_end_time_hr,
        X_PREFERENCE_START_TIME_MI              => p_contact_preference_rec.preference_start_time_mi,
        X_PREFERENCE_END_TIME_MI                => p_contact_preference_rec.preference_end_time_mi,
        X_MAX_NO_OF_INTERACTIONS                => p_contact_preference_rec.max_no_of_interactions,
        X_MAX_NO_OF_INTERACT_UOM_CODE           => p_contact_preference_rec.max_no_of_interact_uom_code,
        X_REQUESTED_BY                          => p_contact_preference_rec.requested_by,
        X_REASON_CODE                           => p_contact_preference_rec.reason_code,
        X_STATUS                                => p_contact_preference_rec.status,
        X_OBJECT_VERSION_NUMBER                 => p_object_version_number,
        X_CREATED_BY_MODULE                     => p_contact_preference_rec.created_by_module,
        X_APPLICATION_ID                        => p_contact_preference_rec.application_id
    );

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'HZ_CONTACT_PREFERENCES_PKG.Update_Row (-)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'do_update_contact_preference (-)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
    END IF;

END do_update_contact_preference;


----------------------------
-- body of public procedures
----------------------------

/**
 * PROCEDURE create_contact_preference
 *
 * DESCRIPTION
 *     Creates contact preference
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_contact_preference_rec       Contact preference record.
 *   IN/OUT:
 *   OUT:
 *     x_contact_preference_id        contact preference ID.
 *     x_return_status                Return status after the call. The status can
 *                                    be FND_API.G_RET_STS_SUCCESS (success),
 *                                    FND_API.G_RET_STS_ERROR (error),
 *                                    FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
 *     x_msg_count                    Number of messages in message stack.
 *     x_msg_data                     Message text if x_msg_count is 1.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   23-JUL-2001    Kate Shan         o Created.
 *
 */

PROCEDURE create_contact_preference(
    p_init_msg_list                         IN      VARCHAR2:= FND_API.G_FALSE,
    p_contact_preference_rec                IN      CONTACT_PREFERENCE_REC_TYPE,
    x_contact_preference_id                 OUT NOCOPY     NUMBER,
    x_return_status                         OUT NOCOPY     VARCHAR2,
    x_msg_count                             OUT NOCOPY     NUMBER,
    x_msg_data                              OUT NOCOPY     VARCHAR2
) IS

    l_contact_preference_rec                        CONTACT_PREFERENCE_REC_TYPE := p_contact_preference_rec;
    l_debug_prefix		                    VARCHAR2(30) := '';

BEGIN
    --Standard start of API savepoint
    SAVEPOINT create_contact_preference_pub;

    -- Check if API is called in debug mode. If yes, enable debug.
    --enable_debug;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'create_contact_preference (+) ',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
    END IF;

    --Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    --Initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Call to business logic.
    do_create_contact_preference(
        l_contact_preference_rec,
        x_contact_preference_id,
        x_return_status);

   IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
     IF(HZ_UTILITY_V2PUB.G_EXECUTE_API_CALLOUTS in ('Y', 'EVENTS_ENABLED')) THEN
       -- Invoke business event system.
       HZ_BUSINESS_EVENT_V2PVT.create_contact_prefer_event (
         l_contact_preference_rec );
     END IF;

     IF(HZ_UTILITY_V2PUB.G_EXECUTE_API_CALLOUTS in ('EVENTS_ENABLED', 'BO_EVENTS_ENABLED')) THEN
       HZ_POPULATE_BOT_PKG.pop_hz_contact_preferences(
         p_operation             => 'I',
         p_contact_preference_id => x_contact_preference_id);
     END IF;
   END IF;

    --Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);

    -- Debug info.
    IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
	 hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
	                       p_msg_data=>x_msg_data,
			       p_msg_type=>'WARNING',
			       p_msg_level=>fnd_log.level_exception);
    END IF;
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=> 'create_contact_preference (-) ',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Check if API is called in debug mode. If yes, disable debug.
    --disable_debug;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO create_contact_preference_pub;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data);

        -- Debug info.
	IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
		 hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
	                       p_msg_data=>x_msg_data,
			       p_msg_type=>'ERROR',
			       p_msg_level=>fnd_log.level_error);
        END IF;
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	    hz_utility_v2pub.debug(p_message=>'create_contact_preference (-) ' ,
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
        END IF;

        -- Check if API is called in debug mode. If yes, disable debug.
        --disable_debug;


    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO create_contact_preference_pub;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data);

        -- Debug info.
	IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
	                       p_msg_data=>x_msg_data,
			       p_msg_type=>'UNEXPECTED ERROR',
			       p_msg_level=>fnd_log.level_error);
        END IF;
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'create_contact_preference (-)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
        END IF;

        -- Check if API is called in debug mode. If yes, disable debug.
        --disable_debug;

    WHEN OTHERS THEN
        ROLLBACK TO create_contact_preference_pub;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data);

        -- Debug info.
	IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
             hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
	                       p_msg_data=>x_msg_data,
			       p_msg_type=>'SQL ERROR',
			       p_msg_level=>fnd_log.level_error);
        END IF;
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	    hz_utility_v2pub.debug(p_message=>'create_contact_preference (-) ',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
        END IF;

        -- Check if API is called in debug mode. If yes, disable debug.
        --disable_debug;

END create_contact_preference;


/**
 * PROCEDURE update_contact_preference
 *
 * DESCRIPTION
 *     Updates contact preference
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_contact_preference_rec       Contact Preference record.
 *   IN/OUT:
 *     p_object_version_number        Used for locking the being updated record.
 *   OUT:
 *     x_return_status                Return status after the call. The status can
 *                                    be FND_API.G_RET_STS_SUCCESS (success),
 *                                    FND_API.G_RET_STS_ERROR (error),
 *                                    FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
 *     x_msg_count                    Number of messages in message stack.
 *     x_msg_data                     Message text if x_msg_count is 1.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   07-23-2001    Kate Shan        o Created.
 *
 */

PROCEDURE  update_contact_preference(
    p_init_msg_list                         IN      VARCHAR2:= FND_API.G_FALSE,
    p_contact_preference_rec                IN      CONTACT_PREFERENCE_REC_TYPE,
    p_object_version_number                 IN OUT NOCOPY  NUMBER,
    x_return_status                         OUT NOCOPY     VARCHAR2,
    x_msg_count                             OUT NOCOPY     NUMBER,
    x_msg_data                              OUT NOCOPY     VARCHAR2
) IS

    l_contact_preference_rec                        CONTACT_PREFERENCE_REC_TYPE := p_contact_preference_rec;
    l_old_contact_preference_rec                    CONTACT_PREFERENCE_REC_TYPE;
    l_debug_prefix				    VARCHAR2(30) := '';

BEGIN

    --Standard start of API savepoint
    SAVEPOINT update_contact_preference_pub;

    -- Check if API is called in debug mode. If yes, enable debug.
    --enable_debug;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'update_contact_preference (+)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
    END IF;

    --Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    --Initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --2290537
    get_contact_preference_rec (
      p_contact_preference_id    => p_contact_preference_rec.contact_preference_id,
      x_contact_preference_rec   => l_old_contact_preference_rec,
      x_return_status            => x_return_status,
      x_msg_count                => x_msg_count,
      x_msg_data                 => x_msg_data);

    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Call to business logic.
    do_update_contact_preference(
        l_contact_preference_rec,
        p_object_version_number,
        x_return_status);

   IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
     IF(HZ_UTILITY_V2PUB.G_EXECUTE_API_CALLOUTS in ('Y', 'EVENTS_ENABLED')) THEN
       -- Invoke business event system.
       HZ_BUSINESS_EVENT_V2PVT.update_contact_prefer_event (
         l_contact_preference_rec , l_old_contact_preference_rec  );
     END IF;

     IF(HZ_UTILITY_V2PUB.G_EXECUTE_API_CALLOUTS in ('EVENTS_ENABLED', 'BO_EVENTS_ENABLED')) THEN
       HZ_POPULATE_BOT_PKG.pop_hz_contact_preferences(
         p_operation             => 'U',
         p_contact_preference_id => l_contact_preference_rec.contact_preference_id);
     END IF;
   END IF;

    --Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);

    -- Debug info.
    IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
	 hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
	                       p_msg_data=>x_msg_data,
			       p_msg_type=>'WARNING',
			       p_msg_level=>fnd_log.level_exception);
    END IF;
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'update_contact_preference (-)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Check if API is called in debug mode. If yes, disable debug.
    --disable_debug;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO update_contact_preference_pub;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data);

        -- Debug info.
	IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
		 hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
	                       p_msg_data=>x_msg_data,
			       p_msg_type=>'ERROR',
			       p_msg_level=>fnd_log.level_error);
        END IF;
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	    hz_utility_v2pub.debug(p_message=>'update_contact_preference (-)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
        END IF;

        -- Check if API is called in debug mode. If yes, disable debug.
        --disable_debug;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO update_contact_preference_pub;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data);

        -- Debug info.
	IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
	                       p_msg_data=>x_msg_data,
			       p_msg_type=>'UNEXPECTED ERROR',
			       p_msg_level=>fnd_log.level_error);
        END IF;
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'update_contact_preference (-)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
        END IF;

        -- Check if API is called in debug mode. If yes, disable debug.
        --disable_debug;

    WHEN OTHERS THEN
        ROLLBACK TO update_contact_preference_pub;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data);

        -- Debug info.
	IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
             hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
	                       p_msg_data=>x_msg_data,
			       p_msg_type=>'SQL ERROR',
			       p_msg_level=>fnd_log.level_error);
        END IF;
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	    hz_utility_v2pub.debug(p_message=>'update_contact_preference (-)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
        END IF;

        -- Check if API is called in debug mode. If yes, disable debug.
        --disable_debug;

END update_contact_preference;

/**
 * PROCEDURE get_contact_preference_rec
 *
 * DESCRIPTION
 *      Gets contact preference record
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_contact_preference_id        Contact preference id.
 *   IN/OUT:
 *   OUT:
 *     x_contact_preference_rec       Returned contact preference record.
 *     x_return_status                Return status after the call. The status can
 *                                    be FND_API.G_RET_STS_SUCCESS (success),
 *                                    FND_API.G_RET_STS_ERROR (error),
 *                                    FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
 *     x_msg_count                    Number of messages in message stack.
 *     x_msg_data                     Message text if x_msg_count is 1.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   07-23-2001    Kate Shan         o Created.
 *
 */

PROCEDURE get_contact_preference_rec (
    p_init_msg_list                         IN     VARCHAR2 := FND_API.G_FALSE,
    p_contact_preference_id                 IN     NUMBER,
    x_contact_preference_rec                OUT    NOCOPY CONTACT_PREFERENCE_REC_TYPE,
    x_return_status                         OUT NOCOPY    VARCHAR2,
    x_msg_count                             OUT NOCOPY    NUMBER,
    x_msg_data                              OUT NOCOPY    VARCHAR2
) IS
l_debug_prefix				    VARCHAR2(30) := '';
BEGIN

    -- Check if API is called in debug mode. If yes, enable debug.
    --enable_debug;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'get_contact_preference_rec (+)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
    END IF;

    --Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    --Initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --Check whether primary key has been passed in.
    IF p_contact_preference_id IS NULL OR
       p_contact_preference_id = FND_API.G_MISS_NUM THEN
        FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_MISSING_COLUMN' );
        FND_MESSAGE.SET_TOKEN( 'COLUMN', 'contact_preference_id' );
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    x_contact_preference_rec.contact_preference_id := p_contact_preference_id;

    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'HZ_CONTACT_PREFERENCES_PKG.Select_Row (+)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
    END IF;

    HZ_CONTACT_PREFERENCES_PKG.Select_Row (
        X_CONTACT_PREFERENCE_ID                 => x_contact_preference_rec.contact_preference_id,
        X_CONTACT_LEVEL_TABLE                   => x_contact_preference_rec.contact_level_table,
        X_CONTACT_LEVEL_TABLE_ID                => x_contact_preference_rec.contact_level_table_id,
        X_CONTACT_TYPE                          => x_contact_preference_rec.contact_type,
        X_PREFERENCE_CODE                       => x_contact_preference_rec.preference_code,
        X_PREFERENCE_TOPIC_TYPE                => x_contact_preference_rec.preference_topic_type,
        X_PREFERENCE_TOPIC_TYPE_ID             => x_contact_preference_rec.preference_topic_type_id,
        X_PREFERENCE_TOPIC_TYPE_CODE           => x_contact_preference_rec.preference_topic_type_code,
        X_PREFERENCE_START_DATE                 => x_contact_preference_rec.preference_start_date,
        X_PREFERENCE_END_DATE                   => x_contact_preference_rec.preference_end_date,
        X_PREFERENCE_START_TIME_HR              => x_contact_preference_rec.preference_start_time_hr,
        X_PREFERENCE_END_TIME_HR                => x_contact_preference_rec.preference_end_time_hr,
        X_PREFERENCE_START_TIME_MI              => x_contact_preference_rec.preference_start_time_mi,
        X_PREFERENCE_END_TIME_MI                => x_contact_preference_rec.preference_end_time_mi,
        X_MAX_NO_OF_INTERACTIONS                => x_contact_preference_rec.max_no_of_interactions,
        X_MAX_NO_OF_INTERACT_UOM_CODE           => x_contact_preference_rec.max_no_of_interact_uom_code,
        X_REQUESTED_BY                          => x_contact_preference_rec.requested_by,
        X_REASON_CODE                           => x_contact_preference_rec.reason_code,
        X_STATUS                                => x_contact_preference_rec.status,
        X_CREATED_BY_MODULE                     => x_contact_preference_rec.created_by_module,
        X_APPLICATION_ID                        => x_contact_preference_rec.application_id
    );

    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'HZ_CONTACT_PREFERENCES_PKG.Select_Row (-)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
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
	hz_utility_v2pub.debug(p_message=>'get_contact_preference_rec (-)',
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
	    hz_utility_v2pub.debug(p_message=>'get_contact_preference_rec (-)',
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
	   hz_utility_v2pub.debug(p_message=>'get_contact_preference_rec (-)',
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
	    hz_utility_v2pub.debug(p_message=>'get_contact_preference_rec (-)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
        END IF;

        -- Check if API is called in debug mode. If yes, disable debug.
        --disable_debug;

END get_contact_preference_rec;


END HZ_CONTACT_PREFERENCE_V2PUB;

/
