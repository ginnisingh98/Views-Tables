--------------------------------------------------------
--  DDL for Package Body HZ_CONTACT_PREFERENCE_VALIDATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_CONTACT_PREFERENCE_VALIDATE" AS
/*$Header: ARH2CTVB.pls 120.12 2006/01/16 10:02:19 vravicha noship $ */

--------------------------------------
-- declaration of private global varibles
--------------------------------------

--G_DEBUG             BOOLEAN := FALSE;

--------------------------------------
-- declaration of private procedures and functions
--------------------------------------
/*PROCEDURE enable_debug;

PROCEDURE disable_debug;
*/

PROCEDURE preference_date_nonupdateable(
    p_column                                IN     VARCHAR2,
    p_column_value                          IN     DATE,
    p_old_column_value                      IN     DATE,
    p_restricted                            IN     VARCHAR2 DEFAULT 'Y',
    x_return_status                         IN OUT NOCOPY VARCHAR2
);
--------------------------------------
-- private procedures and functions
--------------------------------------

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

/*PROCEDURE disable_debug IS

BEGIN

    IF G_DEBUG THEN
        HZ_UTILITY_V2PUB.disable_debug;
        G_DEBUG := FALSE;
    END IF;

END disable_debug;
*/


PROCEDURE preference_date_nonupdateable(
    p_column                                IN     VARCHAR2,
    p_column_value                          IN     DATE,
    p_old_column_value                      IN     DATE,
    p_restricted                            IN     VARCHAR2 DEFAULT 'Y',
    x_return_status                         IN OUT NOCOPY VARCHAR2
) IS

    l_error                                 BOOLEAN := FALSE;

BEGIN

    IF p_column_value IS NOT NULL THEN
        IF p_restricted = 'Y' THEN
            IF ( p_column_value <> FND_API.G_MISS_DATE OR
                 p_old_column_value IS NOT NULL ) AND
               ( p_old_column_value IS NULL OR
                 p_column_value <> p_old_column_value )
            THEN
               l_error := TRUE;
            END IF;
        ELSE
            IF (p_old_column_value IS NOT NULL AND       -- Bug 3439053
                p_old_column_value <> FND_API.G_MISS_DATE)
                AND
               ( p_column_value = FND_API.G_MISS_DATE OR
                 p_column_value <> p_old_column_value )
            THEN
               l_error := TRUE;
            END IF;
        END IF;
    END IF;

    IF l_error THEN
        FND_MESSAGE.SET_NAME( 'AR', 'HZ_NONUPDATEABLE_PREF_DATE' );
        FND_MESSAGE.SET_TOKEN( 'COLUMN', p_column );
        FND_MSG_PUB.ADD;
        x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

END preference_date_nonupdateable;

PROCEDURE get_updated_record (
    p_contact_preference_id   IN         NUMBER,
    p_update_field_rec        IN         HZ_CONTACT_PREFERENCE_V2PUB.CONTACT_PREFERENCE_REC_TYPE,
    x_updated_cp_rec          OUT NOCOPY        HZ_CONTACT_PREFERENCE_V2PUB.CONTACT_PREFERENCE_REC_TYPE
)
IS
BEGIN

    SELECT
        CONTACT_PREFERENCE_ID,
        CONTACT_LEVEL_TABLE,
        CONTACT_LEVEL_TABLE_ID,
        CONTACT_TYPE,
        DECODE ( p_update_field_rec.preference_code, null, PREFERENCE_CODE,  p_update_field_rec.preference_code),
        DECODE( p_update_field_rec.preference_topic_type, NULL, PREFERENCE_TOPIC_TYPE, FND_API.G_MISS_CHAR, NULL, p_update_field_rec.PREFERENCE_TOPIC_TYPE ),
        DECODE( p_update_field_rec.preference_topic_type_id, NULL, PREFERENCE_TOPIC_TYPE_ID, FND_API.G_MISS_NUM, NULL, p_update_field_rec.preference_topic_type_id ),
        DECODE( p_update_field_rec.preference_topic_type_code, NULL, PREFERENCE_TOPIC_TYPE_CODE, FND_API.G_MISS_CHAR, NULL, p_update_field_rec.preference_topic_type_code ),
        DECODE( p_update_field_rec.preference_start_date, NULL, PREFERENCE_START_DATE, FND_API.G_MISS_DATE, NULL, p_update_field_rec.preference_start_date ),
        DECODE( p_update_field_rec.preference_end_date, NULL, PREFERENCE_END_DATE, FND_API.G_MISS_DATE, NULL, p_update_field_rec.preference_end_date ),
        DECODE( p_update_field_rec.preference_start_time_hr, NULL, PREFERENCE_START_TIME_HR, FND_API.G_MISS_NUM, NULL, p_update_field_rec.preference_start_time_hr ),
        DECODE( p_update_field_rec.preference_end_time_hr, NULL, PREFERENCE_END_TIME_HR, FND_API.G_MISS_NUM, NULL, p_update_field_rec.preference_end_time_hr ),
        DECODE( p_update_field_rec.preference_start_time_mi, NULL, PREFERENCE_START_TIME_MI, FND_API.G_MISS_NUM, NULL, p_update_field_rec.preference_start_time_mi ),
        DECODE( p_update_field_rec.preference_end_time_mi, NULL, PREFERENCE_END_TIME_MI, FND_API.G_MISS_NUM, NULL, p_update_field_rec.preference_end_time_mi ),
        DECODE( p_update_field_rec.max_no_of_interactions, NULL, MAX_NO_OF_INTERACTIONS, FND_API.G_MISS_NUM, NULL, p_update_field_rec.max_no_of_interactions),
        DECODE( p_update_field_rec.max_no_of_interact_uom_code, NULL, MAX_NO_OF_INTERACT_UOM_CODE, FND_API.G_MISS_CHAR, NULL, p_update_field_rec.max_no_of_interact_uom_code ),
        DECODE( p_update_field_rec.requested_by, NULL, REQUESTED_BY, FND_API.G_MISS_CHAR, NULL, p_update_field_rec.requested_by ),
        DECODE( p_update_field_rec.reason_code, NULL, REASON_CODE, FND_API.G_MISS_CHAR, NULL, p_update_field_rec.REASON_CODE ),
        DECODE( p_update_field_rec.status, NULL, STATUS, p_update_field_rec.status )

    INTO
        x_updated_cp_rec.CONTACT_PREFERENCE_ID,
        x_updated_cp_rec.CONTACT_LEVEL_TABLE,
        x_updated_cp_rec.CONTACT_LEVEL_TABLE_ID,
        x_updated_cp_rec.CONTACT_TYPE,
        x_updated_cp_rec.PREFERENCE_CODE,
        x_updated_cp_rec.PREFERENCE_TOPIC_TYPE,
        x_updated_cp_rec.PREFERENCE_TOPIC_TYPE_ID,
        x_updated_cp_rec.PREFERENCE_TOPIC_TYPE_CODE,
        x_updated_cp_rec.PREFERENCE_START_DATE,
        x_updated_cp_rec.PREFERENCE_END_DATE,
        x_updated_cp_rec.PREFERENCE_START_TIME_HR,
        x_updated_cp_rec.PREFERENCE_END_TIME_HR,
        x_updated_cp_rec.PREFERENCE_START_TIME_MI,
        x_updated_cp_rec.PREFERENCE_END_TIME_MI,
        x_updated_cp_rec.MAX_NO_OF_INTERACTIONS,
        x_updated_cp_rec.MAX_NO_OF_INTERACT_UOM_CODE,
        x_updated_cp_rec.REQUESTED_BY,
        x_updated_cp_rec.REASON_CODE,
        x_updated_cp_rec.STATUS
    FROM HZ_CONTACT_PREFERENCES
    WHERE CONTACT_PREFERENCE_ID = p_contact_preference_id;


END get_updated_record;
--------------------------------------
-- declaration of public procedures and functions
--------------------------------------

PROCEDURE validate_contact_preference (
    p_create_update_flag                    IN     VARCHAR2,
    p_contact_preference_rec                IN     HZ_CONTACT_PREFERENCE_V2PUB.CONTACT_PREFERENCE_REC_TYPE,
    p_rowid                                 IN     ROWID,
    x_return_status                         IN OUT NOCOPY VARCHAR2

) IS
    l_debug_prefix                          VARCHAR2(100) := ''; -- 'validate_contact_preference'

    l_contact_preference_id                 NUMBER;
    l_contact_pref_dup_id                   NUMBER;
    l_contact_level_table                   HZ_CONTACT_PREFERENCES.contact_level_table%TYPE;
    l_contact_level_table_id                NUMBER;
    l_contact_type                          HZ_CONTACT_PREFERENCES.contact_type%TYPE;
    l_preference_code                       HZ_CONTACT_PREFERENCES.preference_code%TYPE;
    l_preference_start_date                 HZ_CONTACT_PREFERENCES.preference_start_date%TYPE;
    l_preference_end_date                   HZ_CONTACT_PREFERENCES.preference_end_date%TYPE;
    l_preference_start_time_hr              NUMBER;
    l_preference_end_time_hr                NUMBER;
    l_preference_start_time_mi              NUMBER;
    l_preference_end_time_mi                NUMBER;
    l_contact_point_type                    HZ_CONTACT_POINTS.contact_point_type%TYPE;
    l_created_by_module                     HZ_CONTACT_PREFERENCES.created_by_module%TYPE;
    l_application_id                        NUMBER;
    l_dummy                                 VARCHAR2(1);
    l_tag                                   FND_LOOKUP_VALUES.tag%TYPE;
    l_time_comparison                       VARCHAR2(30) := FND_API.G_TRUE;
    l_correct_contact_type                  VARCHAR2(30);
    l_contact_preference_rec                HZ_CONTACT_PREFERENCE_V2PUB.CONTACT_PREFERENCE_REC_TYPE;
    l_preference_topic_type                 HZ_CONTACT_PREFERENCES.preference_topic_type%TYPE;
    l_preference_topic_type_code            HZ_CONTACT_PREFERENCES.preference_topic_type_code%TYPE;
    l_max_no_of_interact_uom_code           HZ_CONTACT_PREFERENCES.max_no_of_interact_uom_code%TYPE;
    l_reason_code                           HZ_CONTACT_PREFERENCES.reason_code%TYPE;
    l_requested_by                          HZ_CONTACT_PREFERENCES.requested_by%TYPE;
    l_status                                HZ_CONTACT_PREFERENCES.status%TYPE;

BEGIN

    -- Check if API is called in debug mode. If yes, enable debug.
    --enable_debug;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=> 'validate_contact_preference (+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    IF p_create_update_flag = 'C' THEN
    --If primary key value is passed, check for uniqueness.
      IF p_contact_preference_rec.contact_preference_id IS NOT NULL AND
          p_contact_preference_rec.contact_preference_id <> FND_API.G_MISS_NUM
      THEN
        BEGIN
            SELECT 'Y' INTO l_dummy
            FROM   HZ_CONTACT_PREFERENCES
            WHERE  CONTACT_PREFERENCE_ID = p_contact_preference_rec.contact_preference_id;

            FND_MESSAGE.SET_NAME('AR', 'HZ_API_DUPLICATE_COLUMN');
            FND_MESSAGE.SET_TOKEN('COLUMN', 'contact_preference_id');
            FND_MSG_PUB.ADD;
            x_return_status := FND_API.G_RET_STS_ERROR;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                NULL;
        END;
      END IF;
    END IF;

    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_message=>'contact_preference_id is unique during creation if passed in. ' ||
            'x_return_status = ' || x_return_status,
                                  p_prefix =>l_debug_prefix,
                                  p_msg_level=>fnd_log.level_statement);
    END IF;

    -- Select fields for later use during update.
    IF p_create_update_flag = 'U' THEN
        SELECT  CONTACT_PREFERENCE_ID, CONTACT_LEVEL_TABLE,
                CONTACT_LEVEL_TABLE_ID, CONTACT_TYPE,
                PREFERENCE_CODE, PREFERENCE_START_DATE, PREFERENCE_END_DATE,
                PREFERENCE_TOPIC_TYPE,PREFERENCE_TOPIC_TYPE_CODE,
                PREFERENCE_START_TIME_HR,PREFERENCE_END_TIME_HR,
                PREFERENCE_START_TIME_MI,PREFERENCE_END_TIME_MI,
                MAX_NO_OF_INTERACT_UOM_CODE, REASON_CODE, REQUESTED_BY, STATUS ,
                CREATED_BY_MODULE, APPLICATION_ID
        INTO l_contact_preference_id, l_contact_level_table,
             l_contact_level_table_id, l_contact_type,
             l_preference_code, l_preference_start_date, l_preference_end_date,
             l_preference_topic_type, l_preference_topic_type_code,
             l_preference_start_time_hr, l_preference_end_time_hr,
             l_preference_start_time_mi, l_preference_end_time_mi,
             l_max_no_of_interact_uom_code, l_reason_code, l_requested_by, l_status ,
             l_created_by_module, l_application_id
        FROM HZ_CONTACT_PREFERENCES
        WHERE ROWID = p_rowid;
    END IF;

    ----------------------------------------------
    -- validate contact_level_table
    ----------------------------------------------
/****Logical APIs - validation not required if called from logical api****/
  IF(HZ_UTILITY_V2PUB.G_CALLING_API IS NULL) THEN
    -- contact_level_table is mandatory field
    -- Since contact_level_table is non-updateable, we only need to check mandatory
    -- during creation.

    IF p_create_update_flag = 'C' THEN
        HZ_UTILITY_V2PUB.validate_mandatory (
            p_create_update_flag                    => p_create_update_flag,
            p_column                                => 'contact_level_table',
            p_column_value                          => p_contact_preference_rec.contact_level_table,
            x_return_status                         => x_return_status );
    END IF;
    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_message=>'contact_level_table is mandatory field' ||
            'x_return_status = ' || x_return_status,
                                  p_prefix =>l_debug_prefix,
                                  p_msg_level=>fnd_log.level_statement);
    END IF;

    -- contact_level_table is non-updateable field
    IF p_create_update_flag = 'U' THEN
        HZ_UTILITY_V2PUB.validate_nonupdateable (
            p_column                                => 'contact_level_table',
            p_column_value                          => p_contact_preference_rec.contact_level_table,
            p_old_column_value                      => l_contact_level_table,
            x_return_status                         => x_return_status );
    END IF;

    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_message=>'contact_level_table is non-updateable.' ||
            'x_return_status = ' || x_return_status,
                                  p_prefix =>l_debug_prefix,
                                  p_msg_level=>fnd_log.level_statement);
    END IF;

    -- contact_level_table is lookup code in lookup type SUBJECT_TABLE
    -- Since contact_level_table is non-updateable, we only need to check lookup
    -- during creation.
    IF p_create_update_flag = 'C' THEN
            HZ_UTILITY_V2PUB.validate_lookup (
                p_column                                => 'contact_level_table',
                p_lookup_type                           => 'SUBJECT_TABLE',
                p_column_value                          => p_contact_preference_rec.contact_level_table,
                x_return_status                         => x_return_status );
    END IF;

    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_message=>'contact_level_table is lookup code in lookup type SUBJECT_TABLE .' ||
         'x_return_status = ' || x_return_status,
                                  p_prefix =>l_debug_prefix,
                                  p_msg_level=>fnd_log.level_statement);
    END IF;
  END IF;

    ----------------------------------------------
    -- validate contact_level_table_id
    ----------------------------------------------
/****Logical APIs - validation not required if called from logical api****/
  IF(HZ_UTILITY_V2PUB.G_CALLING_API IS NULL) THEN
    -- contact_level_table_id is mandatory field
    -- Since contact_level_table_id is non-updateable, we only need to check mandatory
    -- during creation.

    IF p_create_update_flag = 'C' THEN
        HZ_UTILITY_V2PUB.validate_mandatory (
            p_create_update_flag                    => p_create_update_flag,
            p_column                                => 'contact_level_table_id',
            p_column_value                          => p_contact_preference_rec.contact_level_table_id,
            x_return_status                         => x_return_status );
    END IF;

    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_message=>'contact_level_table_id is mandatory field' ||
            'x_return_status = ' || x_return_status,
                                  p_prefix =>l_debug_prefix,
                                  p_msg_level=>fnd_log.level_statement);
    END IF;

    -- contact_level_table_id is non-updateable field
    IF p_create_update_flag = 'U' THEN
        HZ_UTILITY_V2PUB.validate_nonupdateable (
            p_column                                => 'contact_level_table_id',
            p_column_value                          => p_contact_preference_rec.contact_level_table_id,
            p_old_column_value                      => l_contact_level_table_id,
            x_return_status                         => x_return_status );
    END IF;

    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_message=>'contact_level_table_id is non-updateable.' ||
            'x_return_status = ' || x_return_status,
                                  p_prefix =>l_debug_prefix,
                                  p_msg_level=>fnd_log.level_statement);
    END IF;

    -- contact_level_table_id is foreign key of hz_parties, hz_parties, hz_contact_points
    -- Do not need to check during update because contact_level_table_id is
    -- non-updateable.

    IF p_create_update_flag = 'C' THEN
        IF p_contact_preference_rec.contact_level_table = 'HZ_PARTIES' THEN
            BEGIN
                SELECT 'Y' INTO l_dummy
                FROM HZ_PARTIES
                WHERE PARTY_ID = p_contact_preference_rec.contact_level_table_id;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_INVALID_FK' );
                    FND_MESSAGE.SET_TOKEN( 'FK', 'party_id' );
                    FND_MESSAGE.SET_TOKEN( 'COLUMN', 'contact_level_table_id' );
                    FND_MESSAGE.SET_TOKEN( 'TABLE', 'hz_parties' );
                    FND_MSG_PUB.ADD;
                    x_return_status := FND_API.G_RET_STS_ERROR;
            END;
        ELSIF  p_contact_preference_rec.contact_level_table = 'HZ_PARTY_SITES' THEN
            BEGIN
                SELECT 'Y' INTO l_dummy
                FROM HZ_PARTY_SITES
                WHERE PARTY_SITE_ID = p_contact_preference_rec.contact_level_table_id;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_INVALID_FK' );
                    FND_MESSAGE.SET_TOKEN( 'FK', 'party_site_id' );
                    FND_MESSAGE.SET_TOKEN( 'COLUMN', 'contact_level_table_id' );
                    FND_MESSAGE.SET_TOKEN( 'TABLE', 'hz_party_sites' );
                    FND_MSG_PUB.ADD;
                    x_return_status := FND_API.G_RET_STS_ERROR;
            END;
        ELSIF  p_contact_preference_rec.contact_level_table = 'HZ_CONTACT_POINTS' THEN
            BEGIN
                SELECT 'Y' INTO l_dummy
                FROM HZ_CONTACT_POINTS
                WHERE CONTACT_POINT_ID = p_contact_preference_rec.contact_level_table_id;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_INVALID_FK' );
                    FND_MESSAGE.SET_TOKEN( 'FK', 'contact_point_id' );
                    FND_MESSAGE.SET_TOKEN( 'COLUMN', 'contact_level_table_id' );
                    FND_MESSAGE.SET_TOKEN( 'TABLE', 'hz_contact_points' );
                    FND_MSG_PUB.ADD;
                    x_return_status := FND_API.G_RET_STS_ERROR;
            END;
        END IF;
    END IF;

    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_message=>'contact_level_table_id ' || p_contact_preference_rec.contact_level_table_id ||
            ' is foreign key of ' || p_contact_preference_rec.contact_level_table || ', ' ||
            'x_return_status = ' || x_return_status,
                                  p_prefix =>l_debug_prefix,
                                  p_msg_level=>fnd_log.level_statement);
    END IF;
  END IF;

    ----------------------------------------------
    -- validate contact_type
    ----------------------------------------------

    -- contact_type is mandatory field
    -- Since contact_type is non-updateable, we only need to check mandatory
    -- during creation.

    IF p_create_update_flag = 'C' THEN
        HZ_UTILITY_V2PUB.validate_mandatory (
            p_create_update_flag                    => p_create_update_flag,
            p_column                                => 'contact_type',
            p_column_value                          => p_contact_preference_rec.contact_type,
            x_return_status                         => x_return_status );
    END IF;

    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_message=>'contact_type is mandatory field' ||
            'x_return_status = ' || x_return_status,
                                  p_prefix =>l_debug_prefix,
                                  p_msg_level=>fnd_log.level_statement);
    END IF;

    -- contact_type is non-updateable field
    IF p_create_update_flag = 'U' THEN
        HZ_UTILITY_V2PUB.validate_nonupdateable (
            p_column                                => 'contact_type',
            p_column_value                          => p_contact_preference_rec.contact_type,
            p_old_column_value                      => l_contact_type,
            x_return_status                         => x_return_status );
    END IF;

    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_message=>'contact_type is non-updateable.' ||
            'x_return_status = ' || x_return_status,
                                  p_prefix =>l_debug_prefix,
                                  p_msg_level=>fnd_log.level_statement);
    END IF;

    -- contact_type is lookup code in lookup type CONTACT_TYPE
    -- Since contact_type is non-updateable, we only need to check lookup
    -- during creation.
    IF p_create_update_flag = 'C' THEN
        HZ_UTILITY_V2PUB.validate_lookup (
            p_column                                => 'contact_type',
            p_lookup_type                           => 'CONTACT_TYPE',
            p_column_value                          => p_contact_preference_rec.contact_type,
            x_return_status                         => x_return_status );
    END IF;

    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_message=>'contact_type is lookup code in lookup type CONTACT_TYPE.' ||
            'x_return_status = ' || x_return_status,
                                  p_prefix =>l_debug_prefix,
                                  p_msg_level=>fnd_log.level_statement);
    END IF;

    -- check CONTACT_POINT_TYPE

    -- if contact_level_table  = 'HZ_CONTACT_POINTS' ,
    --  p_contact_preference_rec.contact_type should match with contact_point_type

    IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN

        IF p_contact_preference_rec.contact_level_table = 'HZ_CONTACT_POINTS' THEN
            select contact_point_type,
                   decode(contact_point_type, 'PHONE', 'CALL', 'FAX', 'FAX',
                          'SMS', 'SMS', 'EMAIL','EMAIL', 'TLX', 'TLX', 'EDI', 'EDI', contact_point_type)
            into l_contact_point_type, l_correct_contact_type
            FROM HZ_CONTACT_POINTS
            WHERE  contact_point_id =  p_contact_preference_rec.contact_level_table_id;

            IF  p_contact_preference_rec.contact_type = 'MAIL' OR
                p_contact_preference_rec.contact_type = 'VISIT'   THEN
                FND_MESSAGE.SET_NAME( 'AR', 'HZ_INVALID_CONTACT_LEVEL_TABLE' );
                FND_MESSAGE.SET_TOKEN( 'CONTACT_TYPE', 'MAIL/VISIT' );
                FND_MESSAGE.SET_TOKEN( 'CONTACT_LEVEL_TABLE', 'hz_contact_points' );
                FND_MSG_PUB.ADD;
                x_return_status := FND_API.G_RET_STS_ERROR;

            ELSIF p_contact_preference_rec.contact_type <> l_correct_contact_type AND
                  not ( p_contact_preference_rec.contact_type in ('CALL' , 'FAX') AND l_correct_contact_type in ( 'FAX', 'CALL'))  THEN
                FND_MESSAGE.SET_NAME( 'AR', 'HZ_INVALID_CONTACT_TYPE' );
                FND_MESSAGE.SET_TOKEN( 'INCORRECT_CONTACT_TYPE',  p_contact_preference_rec.contact_type );
                FND_MESSAGE.SET_TOKEN( 'CORRECT_CONTACT_TYPE',  l_correct_contact_type );
                FND_MESSAGE.SET_TOKEN( 'CONTACT_POINT_TYPE', l_contact_point_type);
                FND_MSG_PUB.ADD;
                x_return_status := FND_API.G_RET_STS_ERROR;
            END IF;
        END IF;
    END IF;

    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_message=>'if contact_level_table is HZ_CONTACT_POINTS ' ||
            'p_contact_preference_rec.contact_type should match with contact_point_type' ||
            'x_return_status = ' || x_return_status,
                                  p_prefix =>l_debug_prefix,
                                  p_msg_level=>fnd_log.level_statement);
    END IF;

    ----------------------------------------------
    -- validate preference_code
    ----------------------------------------------

    -- preference_code is mandatory field
    HZ_UTILITY_V2PUB.validate_mandatory (
        p_create_update_flag                    => p_create_update_flag,
        p_column                                => 'preference_code',
        p_column_value                          => p_contact_preference_rec.preference_code,
        x_return_status                         => x_return_status );

    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_message=>'preference_code is mandatory field' ||
            'x_return_status = ' || x_return_status,
                                  p_prefix =>l_debug_prefix,
                                  p_msg_level=>fnd_log.level_statement);
    END IF;

    -- preference_code is lookup code in lookup type PREFERENCE_CODE
    IF p_contact_preference_rec.preference_code IS NOT NULL AND
       p_contact_preference_rec.preference_code <> FND_API.G_MISS_CHAR AND
       ( p_create_update_flag = 'C' OR
         ( p_create_update_flag = 'U' AND
           p_contact_preference_rec.preference_code <> NVL (l_preference_code, FND_API.G_MISS_CHAR))) THEN

         HZ_UTILITY_V2PUB.validate_lookup (
             p_column                                => 'preference_code',
             p_lookup_type                           => 'PREFERENCE_CODE',
             p_column_value                          => p_contact_preference_rec.preference_code,
             x_return_status                         => x_return_status );
    END IF;

    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_message=>'preference_code is lookup code in lookup type PREFERENCE_CODE.' ||
            'x_return_status = ' || x_return_status,
                                  p_prefix =>l_debug_prefix,
                                  p_msg_level=>fnd_log.level_statement);
    END IF;


    ----------------------------------------------
    -- validate preference_topic_type
    ----------------------------------------------

    -- preference_topic_type is lookup code in lookup type PREFERENCE_TOPIC_TYPE
    IF p_contact_preference_rec.preference_topic_type IS NOT NULL AND
       p_contact_preference_rec.preference_topic_type <> FND_API.G_MISS_CHAR AND
       ( p_create_update_flag = 'C' OR
         ( p_create_update_flag = 'U' AND
           p_contact_preference_rec.preference_topic_type <> NVL (l_preference_topic_type, FND_API.G_MISS_CHAR))) THEN

        HZ_UTILITY_V2PUB.validate_lookup (
            p_column                                => 'preference_topic_type',
            p_lookup_type                           => 'PREFERENCE_TOPIC_TYPE',
            p_column_value                          => p_contact_preference_rec.preference_topic_type,
            x_return_status                         => x_return_status );

    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_message=>'preference_topic_type is lookup code in lookup type PREFERENCE_TOPIC_TYPE.' ||
            'x_return_status = ' || x_return_status,
                                  p_prefix =>l_debug_prefix,
                                  p_msg_level=>fnd_log.level_statement);
    END IF;

    ----------------------------------------------
    -- validate preference_topic_type_id
    ----------------------------------------------

      IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN


        SELECT TAG
        INTO l_tag
        FROM FND_LOOKUP_VALUES
        WHERE
              LANGUAGE = userenv('LANG') AND
              START_DATE_ACTIVE < sysdate AND
             (  END_DATE_ACTIVE is null OR
                END_DATE_ACTIVE = FND_API.G_MISS_DATE OR
                END_DATE_ACTIVE > sysdate) AND
              LOOKUP_TYPE = 'PREFERENCE_TOPIC_TYPE' AND
              LOOKUP_CODE = p_contact_preference_rec.preference_topic_type;

        IF UPPER(l_tag) = 'T' THEN

        -- preference_topic_type_code is mandatory if preference_topic_type is table name
            HZ_UTILITY_V2PUB.validate_mandatory (
                p_create_update_flag                    => p_create_update_flag,
                p_column                                => 'preference_topic_type_id',
                p_column_value                          => p_contact_preference_rec.preference_topic_type_id,
                x_return_status                         => x_return_status );

            IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
                hz_utility_v2pub.debug(p_message=>'preference_topic_type_code is mandatory if preference_topic_type is table name, ' ||
                    'x_return_status = ' || x_return_status,
                                  p_prefix =>l_debug_prefix,
                                  p_msg_level=>fnd_log.level_statement);
            END IF;

            IF p_contact_preference_rec.preference_topic_type = 'AMS_SOURCE_CODES' THEN
            BEGIN
                SELECT 'Y' INTO l_dummy
                FROM AMS_SOURCE_CODES
                WHERE source_code_id = p_contact_preference_rec.preference_topic_type_id;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_INVALID_FK' );
                    FND_MESSAGE.SET_TOKEN( 'FK', 'source_code_id');
                    FND_MESSAGE.SET_TOKEN( 'COLUMN', 'preference_topic_type_id' );
                    FND_MESSAGE.SET_TOKEN( 'TABLE', 'ams_source_codes' );
                    FND_MSG_PUB.ADD;
                    x_return_status := FND_API.G_RET_STS_ERROR;
            END;
            ELSIF  p_contact_preference_rec.preference_topic_type = 'AS_INTEREST_TYPES_B' THEN
            BEGIN
                SELECT 'Y' INTO l_dummy
                FROM AS_INTEREST_TYPES_B
                WHERE interest_type_id = p_contact_preference_rec.preference_topic_type_id;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_INVALID_FK' );
                    FND_MESSAGE.SET_TOKEN( 'FK', 'interest_type_id');
                    FND_MESSAGE.SET_TOKEN( 'COLUMN', 'preference_topic_type_id' );
                    FND_MESSAGE.SET_TOKEN( 'TABLE', 'as_interest_types_b' );
                    FND_MSG_PUB.ADD;
                    x_return_status := FND_API.G_RET_STS_ERROR;
            END;
            ELSIF  p_contact_preference_rec.preference_topic_type = 'AS_INTEREST_CODES_B' THEN
            BEGIN
                SELECT 'Y' INTO l_dummy
                FROM AS_INTEREST_CODES_B
                WHERE interest_code_id = p_contact_preference_rec.preference_topic_type_id;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_INVALID_FK' );
                    FND_MESSAGE.SET_TOKEN( 'FK', 'interest_code_id' );
                    FND_MESSAGE.SET_TOKEN( 'COLUMN', 'preference_topic_type_id' );
                    FND_MESSAGE.SET_TOKEN( 'TABLE', 'as_interest_codes_b' );
                    FND_MSG_PUB.ADD;
                    x_return_status := FND_API.G_RET_STS_ERROR;
            END;
            /* Bug 3301160, data privacy support */
            /* Removed the above as the design will change */
            END IF;
            IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
                hz_utility_v2pub.debug(p_message=>'preference_topic_type_id is the foreign key of table ' ||
                    p_contact_preference_rec.preference_topic_type || ', ' ||
                    'x_return_status = ' || x_return_status,
                                  p_prefix =>l_debug_prefix,
                                  p_msg_level=>fnd_log.level_statement);
             END IF;

    ----------------------------------------------
    -- validate preference_topic_type_code
    ----------------------------------------------

      -- Code modified for Bug 3534003.
      ELSIF UPPER(l_tag)='L'
        THEN
           BEGIN
            -- preference_topic_type_code is mandatory if preference_topic_type is lookup name
               HZ_UTILITY_V2PUB.validate_mandatory (
               p_create_update_flag                    => p_create_update_flag,
               p_column                                => 'preference_topic_type_code',
               p_column_value                          => p_contact_preference_rec.preference_topic_type_code,
               x_return_status                         => x_return_status );

            IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
                hz_utility_v2pub.debug(p_message=>'preference_topic_type_code is mandatory field  if preference_topic_type is lookup name' ||
                    'x_return_status = ' || x_return_status,
                                  p_prefix =>l_debug_prefix,
                                  p_msg_level=>fnd_log.level_statement);
            END IF;


            -- preference_topic_type_code is lookup code in lookup type
            IF p_contact_preference_rec.preference_topic_type_code IS NOT NULL AND
               p_contact_preference_rec.preference_topic_type_code <> FND_API.G_MISS_CHAR AND
               ( p_create_update_flag = 'C' OR
                 ( p_create_update_flag = 'U' AND
                   p_contact_preference_rec.preference_topic_type_code <> NVL (l_preference_topic_type_code, FND_API.G_MISS_CHAR))) THEN

                HZ_UTILITY_V2PUB.validate_lookup (
                p_column                                => 'preference_topic_type_code',
                p_lookup_type                           => p_contact_preference_rec.preference_topic_type,
                p_column_value                          => p_contact_preference_rec.preference_topic_type_code,
                x_return_status                         => x_return_status );
            END IF;

            IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
                 hz_utility_v2pub.debug(p_message=>'preference_topic_type_code is lookup code in lookup type' ||
                     p_contact_preference_rec.preference_topic_type  || ', ' ||
                    'x_return_status = ' || x_return_status,
                                  p_prefix =>l_debug_prefix,
                                  p_msg_level=>fnd_log.level_statement);
            END IF;

            END;
      /** Code added for Bug 3534003 to support table/varchar2 id combination for
          preference topic type.
      **/
      ELSIF UPPER(l_tag)='TV'
      THEN
          BEGIN
            -- preference_topic_type_code is mandatory if preference_topic_type is lookup name
               HZ_UTILITY_V2PUB.validate_mandatory (
               p_create_update_flag                    => p_create_update_flag,
               p_column                                => 'preference_topic_type_code',
               p_column_value                          => p_contact_preference_rec.preference_topic_type_code,
               x_return_status                         => x_return_status );

            IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
                hz_utility_v2pub.debug(p_message=>'preference_topic_type_code is mandatory field  if preference_topic_type is lookup name' ||
                    'x_return_status = ' || x_return_status,
                                  p_prefix =>l_debug_prefix,
                                  p_msg_level=>fnd_log.level_statement);
            END IF;
         END;
      END IF;  -- END OF tag if

      END IF;
    END IF;

    ----------------------------------------------
    -- validate preference_start_date and preference_end_date
    ----------------------------------------------

    -- preference_start_date is mandatory field
        HZ_UTILITY_V2PUB.validate_mandatory (
            p_create_update_flag                    => p_create_update_flag,
            p_column                                => 'preference_start_date',
            p_column_value                          => p_contact_preference_rec.preference_start_date,
            x_return_status                         => x_return_status );

    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_message=>'preference_start_date is mandatory field' ||
            'x_return_status = ' || x_return_status,
                                  p_prefix =>l_debug_prefix,
                                  p_msg_level=>fnd_log.level_statement);
    END IF;

/* Requirement change, to allow preference_end_date less than sysdate
    -- preference_end_date should not be less than sysdate when creating a new record
    IF p_create_update_flag = 'C' AND
       p_contact_preference_rec.preference_end_date is not null AND
       p_contact_preference_rec.preference_end_date <> FND_API.G_MISS_DATE AND
       trunc(p_contact_preference_rec.preference_end_date) < trunc(sysdate) THEN
          FND_MESSAGE.SET_NAME( 'AR', 'HZ_INVALID_PREFERENCE_END_DATE' );
          FND_MESSAGE.SET_TOKEN( 'PREFERENCE_END_DATE', to_char(p_contact_preference_rec.preference_end_date) );
          FND_MSG_PUB.ADD;
          x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_message=>'preference_end_date should not be less than sysdate when creating a new record' ||
            'x_return_status = ' || x_return_status,
                                  p_prefix =>l_debug_prefix,
                                  p_msg_level=>fnd_log.level_statement);
    END IF;


    -- preference_start_date is non-updateable if it's less than sysdate
    IF p_create_update_flag = 'U' AND trunc(p_contact_preference_rec.preference_start_date) < trunc(sysdate) THEN
        preference_date_nonupdateable(
            p_column                                => 'preference_start_date',
            p_column_value                          => p_contact_preference_rec.preference_start_date,
            p_old_column_value                      => l_preference_start_date,
            x_return_status                         => x_return_status );
    END IF;

    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_message=>'preference_start_date is non-updateable when the new date is less than sysdate.' ||
            'x_return_status = ' || x_return_status,
                                  p_prefix =>l_debug_prefix,
                                  p_msg_level=>fnd_log.level_statement);
    END IF;

    -- preference_end_date is non-updateable if it's less then sysdate
    IF p_create_update_flag = 'U' AND trunc(p_contact_preference_rec.preference_end_date) < trunc(sysdate) THEN
        preference_date_nonupdateable(
            p_column                                => 'preference_end_date',
            p_column_value                          => p_contact_preference_rec.preference_end_date,
            p_old_column_value                      => l_preference_end_date,
            x_return_status                         => x_return_status );
    END IF;

    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_message=>'preference_end_date is non-updateable when the new date is less than sysdate.' ||
            'x_return_status = ' || x_return_status,
                                  p_prefix =>l_debug_prefix,
                                  p_msg_level=>fnd_log.level_statement);
    END IF;
*/

    -- preference_end_date should be greater than preference_start_date
    HZ_UTILITY_V2PUB.validate_start_end_date (
        p_create_update_flag                    => p_create_update_flag,
        p_start_date_column_name                => 'preference start date',
        p_start_date                            => p_contact_preference_rec.preference_start_date,
        p_old_start_date                        => l_preference_start_date,
        p_end_date_column_name                  => 'Preference end date', -- Bug 4954622
        p_end_date                              => p_contact_preference_rec.preference_end_date,
        p_old_end_date                          => l_preference_end_date,
        x_return_status                         => x_return_status );

    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_message=>'preference_end_date should be greater than preference_start_date, ' ||
            'x_return_status = ' || x_return_status,
                                  p_prefix =>l_debug_prefix,
                                  p_msg_level=>fnd_log.level_statement);
    END IF;

    ----------------------------------------------
    -- validate preference_start_time_hr and preference_end_time_hr
    ----------------------------------------------

    -- preference_end_time_hr should be greater than preference_start_time_hr, and both should between 0-23

    IF  p_contact_preference_rec.preference_start_time_hr is not null AND
        p_contact_preference_rec.preference_start_time_hr <> FND_API.G_MISS_NUM THEN
        IF p_contact_preference_rec.preference_start_time_hr < 0 OR
           p_contact_preference_rec.preference_start_time_hr > 23 THEN
              FND_MESSAGE.SET_NAME( 'AR', 'HZ_INVALID_PREFERENCE_TIME' );
              FND_MSG_PUB.ADD;
              x_return_status := FND_API.G_RET_STS_ERROR;
              l_time_comparison := FND_API.G_FALSE;
        END IF;
    ELSE
              l_time_comparison := FND_API.G_FALSE;
    END IF;
    IF  p_contact_preference_rec.preference_end_time_hr is not null AND
        p_contact_preference_rec.preference_end_time_hr <> FND_API.G_MISS_NUM THEN
        IF p_contact_preference_rec.preference_end_time_hr < 0 OR
           p_contact_preference_rec.preference_end_time_hr > 23 THEN
              FND_MESSAGE.SET_NAME( 'AR', 'HZ_INVALID_PREFERENCE_TIME' );
              FND_MSG_PUB.ADD;
              x_return_status := FND_API.G_RET_STS_ERROR;
              l_time_comparison := FND_API.G_FALSE;
       END IF;
    ELSE
              l_time_comparison := FND_API.G_FALSE;
    END IF;

    IF  l_time_comparison = FND_API.G_TRUE THEN
       IF p_contact_preference_rec.preference_end_time_hr < p_contact_preference_rec.preference_start_time_hr THEN
              FND_MESSAGE.SET_NAME( 'AR', 'HZ_INVALID_PREFERENCE_TIME' );
              FND_MSG_PUB.ADD;
              x_return_status := FND_API.G_RET_STS_ERROR;
              l_time_comparison := FND_API.G_FALSE;
       ELSIF  p_contact_preference_rec.preference_end_time_hr > p_contact_preference_rec.preference_start_time_hr THEN
              l_time_comparison := FND_API.G_FALSE;
       END IF;
    END IF;

    ----------------------------------------------
    -- validate preference_start_time_mi and preference_end_time_mi
    ----------------------------------------------

    -- preference_end_time_mi should be greater than preference_start_time_mi, and both should between 0-59

    IF  p_contact_preference_rec.preference_start_time_mi is not null AND
        p_contact_preference_rec.preference_start_time_mi <> FND_API.G_MISS_NUM THEN
        IF p_contact_preference_rec.preference_start_time_mi < 0 OR
           p_contact_preference_rec.preference_start_time_mi > 59 THEN
              FND_MESSAGE.SET_NAME( 'AR', 'HZ_INVALID_PREFERENCE_TIME' );
              FND_MSG_PUB.ADD;
              x_return_status := FND_API.G_RET_STS_ERROR;
              l_time_comparison := FND_API.G_FALSE;
        END IF;
    ELSE
              l_time_comparison := FND_API.G_FALSE;
    END IF;
    IF  p_contact_preference_rec.preference_end_time_mi is not null AND
        p_contact_preference_rec.preference_end_time_mi <> FND_API.G_MISS_NUM THEN
        IF p_contact_preference_rec.preference_end_time_mi < 0 OR
           p_contact_preference_rec.preference_end_time_mi > 59 THEN
              FND_MESSAGE.SET_NAME( 'AR', 'HZ_INVALID_PREFERENCE_TIME' );
              FND_MSG_PUB.ADD;
              x_return_status := FND_API.G_RET_STS_ERROR;
              l_time_comparison := FND_API.G_FALSE;
       END IF;
    ELSE
              l_time_comparison := FND_API.G_FALSE;
    END IF;

    IF  l_time_comparison = FND_API.G_TRUE THEN
       IF p_contact_preference_rec.preference_end_time_mi < p_contact_preference_rec.preference_start_time_mi THEN
              FND_MESSAGE.SET_NAME( 'AR', 'HZ_INVALID_PREFERENCE_TIME' );
              FND_MSG_PUB.ADD;
              x_return_status := FND_API.G_RET_STS_ERROR;
              l_time_comparison := FND_API.G_FALSE;
       END IF;
    END IF;

    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_message=>'preference_end_time should be greater than preference_start_time, ' ||
            'x_return_status = ' || x_return_status,
                                  p_prefix =>l_debug_prefix,
                                  p_msg_level=>fnd_log.level_statement);
    END IF;

    ----------------------------------------------
    -- validate  MAX_NO_OF_INTERACT_UOM_CODE
    ----------------------------------------------

    -- max_no_of_interact_uom_code is lookup code in lookup type MAX_NO_OF_INTERACT_UOM_CODE
    IF p_contact_preference_rec.max_no_of_interact_uom_code IS NOT NULL AND
       p_contact_preference_rec.max_no_of_interact_uom_code <> FND_API.G_MISS_CHAR AND
       ( p_create_update_flag = 'C' OR
         ( p_create_update_flag = 'U' AND
           p_contact_preference_rec.max_no_of_interact_uom_code <> NVL (l_max_no_of_interact_uom_code, FND_API.G_MISS_CHAR))) THEN

        HZ_UTILITY_V2PUB.validate_lookup (
            p_column                                => 'max_no_of_interact_uom_code',
            p_lookup_type                           => 'MAX_NO_OF_INTERACT_UOM_CODE',
            p_column_value                          => p_contact_preference_rec.max_no_of_interact_uom_code,
            x_return_status                         => x_return_status );

    END IF;

    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_message=>'max_no_of_interact_uom_code is lookup code in lookup type MAX_NO_OF_INTERACT_UOM_CODE.' ||
            'x_return_status = ' || x_return_status,
                                  p_prefix =>l_debug_prefix,
                                  p_msg_level=>fnd_log.level_statement);
    END IF;

    -- if a value is passed for max_no_of_interact_uom_code then preference_start_date should have a value
    IF p_contact_preference_rec.max_no_of_interact_uom_code IS NOT NULL AND
       p_contact_preference_rec.max_no_of_interact_uom_code <> FND_API.G_MISS_CHAR
    THEN
        HZ_UTILITY_V2PUB.validate_mandatory (
            p_create_update_flag                    => p_create_update_flag,
            p_column                                => 'preference_start_date',
            p_column_value                          => p_contact_preference_rec.preference_start_date,
            x_return_status                         => x_return_status );
    END IF;

    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_message=>'if a value is passed for max_no_of_interact_uom_code then preference_start_date should have a value' ||
            'x_return_status = ' || x_return_status,
                                  p_prefix =>l_debug_prefix,
                                  p_msg_level=>fnd_log.level_statement);
    END IF;


    ----------------------------------------------
    -- validate REQUESTED_BY
    ----------------------------------------------
    -- requested_by is mandatory field
    HZ_UTILITY_V2PUB.validate_mandatory (
        p_create_update_flag                    => p_create_update_flag,
        p_column                                => 'requested_by',
        p_column_value                          => p_contact_preference_rec.requested_by,
        x_return_status                         => x_return_status );

    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_message=>'requested_by is mandatory field' ||
            'x_return_status = ' || x_return_status,
                                  p_prefix =>l_debug_prefix,
                                  p_msg_level=>fnd_log.level_statement);
    END IF;

    --  requested_by is lookup code in lookup type REQUESTED_BY
    IF p_contact_preference_rec.requested_by IS NOT NULL AND
       p_contact_preference_rec.requested_by <> FND_API.G_MISS_CHAR AND
       ( p_create_update_flag = 'C' OR
         ( p_create_update_flag = 'U' AND
           p_contact_preference_rec.requested_by <> NVL (l_requested_by, FND_API.G_MISS_CHAR))) THEN

        HZ_UTILITY_V2PUB.validate_lookup (
            p_column                                => 'requested_by',
            p_lookup_type                           => 'REQUESTED_BY',
            p_column_value                          => p_contact_preference_rec.requested_by,
            x_return_status                         => x_return_status );

    END IF;

    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_message=>'requested_by is lookup code in lookup type REQUESTED_BY.' ||
            'x_return_status = ' || x_return_status,
                                  p_prefix =>l_debug_prefix,
                                  p_msg_level=>fnd_log.level_statement);
    END IF;

    ----------------------------------------------
    -- validate reason_code
    ----------------------------------------------
    --  reason_code is lookup code in lookup type REASON_CODE
    IF p_contact_preference_rec.reason_code IS NOT NULL AND
       p_contact_preference_rec.reason_code <> FND_API.G_MISS_CHAR AND
       ( p_create_update_flag = 'C' OR
         ( p_create_update_flag = 'U' AND
           p_contact_preference_rec.reason_code <> NVL (l_reason_code, FND_API.G_MISS_CHAR))) THEN

        HZ_UTILITY_V2PUB.validate_lookup (
            p_column                                => 'reason_code',
            p_lookup_type                           => 'REASON_CODE',
            p_column_value                          => p_contact_preference_rec.reason_code,
            x_return_status                         => x_return_status );
    END IF;

    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_message=>'reason_code is lookup code in lookup type REASON_CODE.' ||
            'x_return_status = ' || x_return_status,
                                  p_prefix =>l_debug_prefix,
                                  p_msg_level=>fnd_log.level_statement);
    END IF;

    ----------------------------------------------
    -- validate status
    ----------------------------------------------
/****Logical APIs - validation not required if called from logical api****/
  IF(HZ_UTILITY_V2PUB.G_CALLING_API IS NULL) THEN
    -- status cannot be set to null during update
    IF p_create_update_flag = 'U' THEN
        HZ_UTILITY_V2PUB.validate_cannot_update_to_null (
            p_column                                => 'status',
            p_column_value                          => p_contact_preference_rec.status,
            x_return_status                         => x_return_status );
    END IF;

    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_message=>'status cannot be updated to null.' ||
            'x_return_status = ' || x_return_status,
                                  p_prefix =>l_debug_prefix,
                                  p_msg_level=>fnd_log.level_statement);
    END IF;

    -- status is lookup code in lookup type CODE_STATUS
    IF p_contact_preference_rec.status IS NOT NULL AND
       p_contact_preference_rec.status <> FND_API.G_MISS_CHAR AND
       ( p_create_update_flag = 'C' OR
         ( p_create_update_flag = 'U' AND
           p_contact_preference_rec.status <> NVL (l_status, FND_API.G_MISS_CHAR))) THEN

        HZ_UTILITY_V2PUB.validate_lookup (
            p_column                                => 'status',
            p_lookup_type                           => 'CODE_STATUS',
            p_column_value                          => p_contact_preference_rec.status,
            x_return_status                         => x_return_status );
    END IF;

    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_message=>'status is lookup code in lookup type CODE_STATUS.' ||
            'x_return_status = ' || x_return_status,
                                  p_prefix =>l_debug_prefix,
                                  p_msg_level=>fnd_log.level_statement);
    END IF;
  END IF;

    -- if status is not 'A', put sysdate on preference_end_date
    IF p_contact_preference_rec.status <> FND_API.G_MISS_CHAR AND
       p_contact_preference_rec.status is not null AND
       p_contact_preference_rec.status <> 'A' THEN
         IF p_contact_preference_rec.preference_end_date is not null  AND
            to_char(p_contact_preference_rec.preference_end_date,'DD-MON-YY') <> to_char(sysdate, 'DD-MON-YY') THEN
             FND_MESSAGE.SET_NAME( 'AR', 'HZ_CP_INVALID_END_DATE' );
             FND_MSG_PUB.ADD;
         END IF;
    END IF;

    --------------------------------------
    -- validate created_by_module
    --------------------------------------

    hz_utility_v2pub.validate_created_by_module(
      p_create_update_flag     => p_create_update_flag,
      p_created_by_module      => p_contact_preference_rec.created_by_module,
      p_old_created_by_module  => l_created_by_module,
      x_return_status          => x_return_status);

    --------------------------------------
    -- validate application_id
    --------------------------------------

    hz_utility_v2pub.validate_application_id(
      p_create_update_flag     => p_create_update_flag,
      p_application_id         => p_contact_preference_rec.application_id,
      p_old_application_id     => l_application_id,
      x_return_status          => x_return_status);

    -------------------------------------------
    -- check for record duplication
    --------------------------------------------
    IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
      IF p_create_update_flag = 'C' THEN
      BEGIN
          SELECT contact_preference_id INTO l_contact_pref_dup_id
          FROM   HZ_CONTACT_PREFERENCES
          WHERE
          --  check contact_level_table and contact_level_table_id
                 contact_level_table = p_contact_preference_rec.contact_level_table AND
                 contact_level_table_id = p_contact_preference_rec.contact_level_table_id  AND
                 status = 'A' AND
/*Bug Number 3067948.According to bug number 1919493,end_date and start_date can be <sysdate
          --  record not expired
                ( preference_end_date is null OR
                  ( preference_end_date is not null AND
                    trunc(preference_end_date) > trunc(sysdate) ))  AND
*/
          --  check other unique column
                 contact_type ||  preference_topic_type ||
                 preference_topic_type_id || preference_topic_type_code
                 =
                 p_contact_preference_rec.contact_type ||
                 p_contact_preference_rec.preference_topic_type ||
                 p_contact_preference_rec.preference_topic_type_id ||
                 p_contact_preference_rec.preference_topic_type_code  AND

          -- check preference_start_date preference_end_date overlap
                 NOT ( ( p_contact_preference_rec.preference_end_date is not null AND
                         --Bug Number 3067948.
                         p_contact_preference_rec.preference_end_date <> fnd_api.g_miss_date AND
                     p_contact_preference_rec.preference_end_date < preference_start_date ) OR
                   ( preference_end_date is not null and
                     p_contact_preference_rec.preference_start_date > preference_end_date )) AND

          -- check preference_start_time_hr/mi preference_end_time_hr/mi overlap
                 NOT ( ( decode(preference_start_time_hr, null, 0, preference_start_time_hr) * 60 +
                         decode(preference_start_time_mi, null, 0, preference_start_time_mi) >
                         decode(p_contact_preference_rec.preference_end_time_hr, null, 24, p_contact_preference_rec.preference_end_time_hr) * 60 +
                         decode (p_contact_preference_rec.preference_end_time_mi, null, 60, p_contact_preference_rec.preference_end_time_mi) ) OR
                       ( decode(preference_end_time_hr, null, 24, preference_end_time_hr ) * 60 +
                         decode(preference_end_time_mi, null, 60, preference_end_time_mi ) <
                         decode(p_contact_preference_rec.preference_start_time_hr, null, 0, p_contact_preference_rec.preference_start_time_hr) * 60 +
                         decode(p_contact_preference_rec.preference_start_time_mi, null, 0, p_contact_preference_rec.preference_start_time_mi ) ) ) AND
                 ROWNUM =1;

            -- Bug 2787484
            /*
            FND_MESSAGE.SET_NAME('AR', 'HZ_API_DUPLICATE_RECORD');
            FND_MESSAGE.SET_TOKEN( 'TABLE', 'hz_contact_preferences' );
            FND_MESSAGE.SET_TOKEN( 'COLUMN', 'contact_preference_id' );
            FND_MESSAGE.SET_TOKEN( 'ID', to_char(l_contact_pref_dup_id) );
            */
            IF p_contact_preference_rec.contact_level_table = 'HZ_PARTIES'
            THEN
               FND_MESSAGE.SET_NAME('AR','HZ_PARTY_PREFERENCE_OVERLAP');
            ELSIF p_contact_preference_rec.contact_level_table = 'HZ_PARTY_SITES'
            THEN
               FND_MESSAGE.SET_NAME('AR','HZ_PARTY_SITE_PREFER_OVERLAP');
            ELSIF p_contact_preference_rec.contact_level_table = 'HZ_CONTACT_POINTS'
            THEN
               FND_MESSAGE.SET_NAME('AR','HZ_CONTACT_POINT_PREF_OVERLAP');
            END IF;

            FND_MSG_PUB.ADD;
            x_return_status := FND_API.G_RET_STS_ERROR;
      EXCEPTION
            WHEN NO_DATA_FOUND THEN
                NULL;
      END;
      ELSIF p_create_update_flag = 'U' THEN
      BEGIN
          get_updated_record (
              p_contact_preference_id  => l_contact_preference_id,
              p_update_field_rec       => p_contact_preference_rec,
              x_updated_cp_rec         => l_contact_preference_rec
          );

          SELECT contact_preference_id INTO l_contact_pref_dup_id
          FROM   HZ_CONTACT_PREFERENCES
          WHERE
          --  check contact_level_table and contact_level_table_id
                 contact_preference_id <> l_contact_preference_id AND
                 contact_level_table = l_contact_preference_rec.contact_level_table AND
                 contact_level_table_id = l_contact_preference_rec.contact_level_table_id  AND
                 status = 'A' AND

/*Bug Number 3067948.According to bug number 1919493,end_date and start_date can be <sysdate
          --  record not expired
                ( preference_end_date is null OR
                  ( preference_end_date is not null AND
                    trunc(preference_end_date) > trunc(sysdate) ))  AND
*/
          --  check other unique column
                 contact_type ||  preference_topic_type ||
                 preference_topic_type_id || preference_topic_type_code
                 =
                 l_contact_preference_rec.contact_type ||
                 l_contact_preference_rec.preference_topic_type ||
                 l_contact_preference_rec.preference_topic_type_id ||
                 l_contact_preference_rec.preference_topic_type_code  AND

          -- check preference_start_date preference_end_date overlap
                 NOT ( ( l_contact_preference_rec.preference_end_date is not null and
                     l_contact_preference_rec.preference_end_date < preference_start_date ) OR
                   ( preference_end_date is not null and
                     l_contact_preference_rec.preference_start_date > preference_end_date )) AND

          -- check preference_start_time_hr/mi preference_end_time_hr/mi overlap
                 NOT ( ( decode(preference_start_time_hr, null, 0, preference_start_time_hr) * 60 +
                         decode(preference_start_time_mi, null, 0, preference_start_time_mi) >
                         decode(l_contact_preference_rec.preference_end_time_hr, null, 24, l_contact_preference_rec.preference_end_time_hr) * 60 +
                         decode (l_contact_preference_rec.preference_end_time_mi, null, 60, l_contact_preference_rec.preference_end_time_mi) ) OR
                       ( decode(preference_end_time_hr, null, 24, preference_end_time_hr ) * 60 +
                         decode(preference_end_time_mi, null, 60, preference_end_time_mi ) <
                         decode(l_contact_preference_rec.preference_start_time_hr, null, 0, l_contact_preference_rec.preference_start_time_hr) * 60 +
                         decode(l_contact_preference_rec.preference_start_time_mi, null, 0, l_contact_preference_rec.preference_start_time_mi ) ) ) AND
                 ROWNUM =1;


            -- Bug 2787484
            /*
            FND_MESSAGE.SET_NAME('AR', 'HZ_API_DUPLICATE_RECORD');
            FND_MESSAGE.SET_TOKEN( 'TABLE', 'hz_contact_preferences' );
            FND_MESSAGE.SET_TOKEN( 'COLUMN', 'contact_preference_id' );
            FND_MESSAGE.SET_TOKEN( 'ID', to_char(l_contact_pref_dup_id) );
            */
            IF l_contact_preference_rec.contact_level_table = 'HZ_PARTIES'
            THEN
               FND_MESSAGE.SET_NAME('AR','HZ_PARTY_PREFERENCE_OVERLAP');
            ELSIF l_contact_preference_rec.contact_level_table = 'HZ_PARTY_SITES'
            THEN
               FND_MESSAGE.SET_NAME('AR','HZ_PARTY_SITE_PREFER_OVERLAP');
            ELSIF l_contact_preference_rec.contact_level_table = 'HZ_CONTACT_POINTS'
            THEN
               FND_MESSAGE.SET_NAME('AR','HZ_CONTACT_POINT_PREF_OVERLAP');
            END IF;

            FND_MSG_PUB.ADD;
            x_return_status := FND_API.G_RET_STS_ERROR;
      EXCEPTION
            WHEN NO_DATA_FOUND THEN
                NULL;
      END;

      END IF;
    END IF;

    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_message=>'no duplicate record is allowed ' ||
            'x_return_status = ' || x_return_status,
                                  p_prefix =>l_debug_prefix,
                                  p_msg_level=>fnd_log.level_statement);
    END IF;

END validate_contact_preference;

END HZ_CONTACT_PREFERENCE_VALIDATE;

/
