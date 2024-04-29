--------------------------------------------------------
--  DDL for Package Body HZ_CLASSIFICATION_V2PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_CLASSIFICATION_V2PUB" AS
/*$Header: ARH2CLSB.pls 120.48.12010000.3 2010/03/19 08:25:03 rgokavar ship $ */

----------------------------------
-- declaration of global variables
----------------------------------

G_DEBUG             BOOLEAN := FALSE;

------------------------------------
-- declaration of private procedures
------------------------------------

PROCEDURE enable_debug;

PROCEDURE disable_debug;

PROCEDURE do_create_class_category(
    p_class_cat_rec        IN OUT    NOCOPY CLASS_CATEGORY_REC_TYPE,
    x_return_status        IN OUT NOCOPY    VARCHAR2
);

PROCEDURE do_update_class_category(
    p_class_cat_rec         IN OUT   NOCOPY CLASS_CATEGORY_REC_TYPE,
    p_object_version_number IN OUT NOCOPY   NUMBER,
    x_return_status         IN OUT NOCOPY   VARCHAR2
);

PROCEDURE do_create_class_code_relation(
    p_class_code_rel_rec    IN OUT  NOCOPY CLASS_CODE_RELATION_REC_TYPE,
    x_return_status         IN OUT NOCOPY  VARCHAR2
);

PROCEDURE do_update_class_code_relation(
    p_class_code_rel_rec    IN OUT  NOCOPY CLASS_CODE_RELATION_REC_TYPE,
    p_object_version_number IN OUT NOCOPY  NUMBER,
    x_return_status         IN OUT NOCOPY  VARCHAR2
);

PROCEDURE do_create_code_assignment(
    p_code_assignment_rec   IN OUT  NOCOPY CODE_ASSIGNMENT_REC_TYPE,
    x_return_status         IN OUT NOCOPY  VARCHAR2
);

PROCEDURE do_update_code_assignment(
    p_code_assignment_rec   IN OUT  NOCOPY CODE_ASSIGNMENT_REC_TYPE,
    p_object_version_number IN OUT NOCOPY  NUMBER,
    x_return_status         IN OUT NOCOPY  VARCHAR2
);

PROCEDURE do_create_class_category_use(
    p_class_category_use_rec  IN OUT  NOCOPY CLASS_CATEGORY_USE_REC_TYPE,
    x_return_status           IN OUT NOCOPY  VARCHAR2
);

PROCEDURE do_update_class_category_use(
    p_class_category_use_rec  IN OUT  NOCOPY CLASS_CATEGORY_USE_REC_TYPE,
    p_object_version_number   IN OUT NOCOPY  NUMBER,
    x_return_status           IN OUT NOCOPY  VARCHAR2
);

PROCEDURE get_current_class_category(
        p_class_category        IN      VARCHAR2,
        x_class_cat_rec         OUT     NOCOPY CLASS_CATEGORY_REC_TYPE
);

PROCEDURE get_curr_class_code_rel(
        p_class_code_rel_rec    IN      CLASS_CODE_RELATION_REC_TYPE,
        x_class_code_rel_rec    OUT     NOCOPY CLASS_CODE_RELATION_REC_TYPE
);

PROCEDURE get_current_code_assignment(
        p_code_assignment_id    IN      NUMBER,
        x_code_assignment_rec   OUT     NOCOPY CODE_ASSIGNMENT_REC_TYPE
);

FUNCTION is_industrial_class(
        p_class_category        IN      VARCHAR2
) RETURN VARCHAR2;
--------------------------------------
-- private procedures and functions
--------------------------------------
/**
 * PRIVATE FUNCTION is_industrial_class
 * RETURN Value : 'Y' (if industrial classification)
 *                'N' (if non-industrial classification)
 *
 * DESCRIPTION
 *     Check if it is industrial classification or not
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * MODIFICATION HISTORY
 *
 *   07-25-2007   Nishant Singhai     o Created (for Bug 6059383)
 *
 */
FUNCTION is_industrial_class(
        p_class_category        IN      VARCHAR2
) RETURN VARCHAR2 IS

  l_yes_no       VARCHAR2(10);

  CURSOR c_check_industrial_group (l_class_category VARCHAR2) IS
    SELECT 'Y'
    FROM   hz_code_assignments
    WHERE  owner_table_name = 'HZ_CLASS_CATEGORIES'
    AND    class_category   = 'CLASS_CATEGORY_GROUP'
    AND    class_code       = 'INDUSTRIAL_GROUP'
    AND    SYSDATE BETWEEN start_date_active AND NVL(end_date_active, SYSDATE+1)
    AND    NVL(status,'A') = 'A'
    AND    owner_table_key_1 = l_class_category;

BEGIN
   l_yes_no := 'N';

   OPEN  c_check_industrial_group (p_class_category);
   FETCH c_check_industrial_group INTO l_yes_no;
   CLOSE c_check_industrial_group;

   RETURN  l_yes_no;

END is_industrial_class;

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
 *   07-23-2001    Jianying Huang      o Created.
 *
 */

PROCEDURE enable_debug IS

BEGIN

    IF FND_PROFILE.value( 'HZ_API_FILE_DEBUG_ON' ) = 'Y' OR
       FND_PROFILE.value( 'HZ_API_DBMS_DEBUG_ON' ) = 'Y'
    THEN
        HZ_UTILITY_V2PUB.enable_debug;
        G_DEBUG := TRUE;
    END IF;

END enable_debug;

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
 *   07-23-2001    Jianying Huang      o Created.
 *
 */

PROCEDURE disable_debug IS

BEGIN

    IF G_DEBUG THEN
        HZ_UTILITY_V2PUB.disable_debug;
        G_DEBUG := FALSE;
    END IF;

END disable_debug;

/*
This flag is used internaly.Indicates that if the data in the HZ_CLASS_CODE_DENORM table for this class
category is valid. Y for valid data. N for stale data. As long as anything
changed in class category tables, we need to set this flag to 'N'.
Data can berefreshed by running the Refresh of Classification Denormalization concurrent
program.
*/
PROCEDURE set_frozen_flag(p_class_category in varchar2) is
begin

        update hz_class_categories
        set frozen_flag = 'N'
        where class_category = p_class_category
        and (frozen_flag = 'Y' or frozen_flag is null);

end set_frozen_flag;

/*===========================================================================+
 | PROCEDURE
 |              do_create_class_category
 |
 | DESCRIPTION
 |              Creates class category
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |              OUT:
 |          IN/ OUT:
 |                    p_class_cat_rec
 |                    x_return_status
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 +===========================================================================*/

PROCEDURE do_create_class_category(
    p_class_cat_rec        IN OUT    NOCOPY CLASS_CATEGORY_REC_TYPE,
    x_return_status        IN OUT NOCOPY    VARCHAR2
) IS

    l_rowid                          ROWID := NULL;

BEGIN

    HZ_CLASS_VALIDATE_V2PUB.validate_class_category(
                                                       p_class_cat_rec,
                                                       'C',
                                                       x_return_status);

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    If HZ_CLASS_VALIDATE_V2PUB.is_valid_delimiter(p_class_cat_rec.class_category,p_class_cat_rec.delimiter)='N'
    then
            FND_MESSAGE.SET_NAME('AR', 'HZ_INVALID_DELIMITER');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
    end if;

    HZ_CLASS_CATEGORIES_PKG.Insert_Row (
        X_CLASS_CATEGORY                        => p_class_cat_rec.class_category,
        X_ALLOW_MULTI_PARENT_FLAG               => p_class_cat_rec.allow_multi_parent_flag,
        X_ALLOW_MULTI_ASSIGN_FLAG               => p_class_cat_rec.allow_multi_assign_flag,
        X_ALLOW_LEAF_NODE_ONLY_FLAG             => p_class_cat_rec.allow_leaf_node_only_flag,
        X_OBJECT_VERSION_NUMBER                 => 1,
        X_CREATED_BY_MODULE                     => p_class_cat_rec.created_by_module,
        X_APPLICATION_ID                        => p_class_cat_rec.application_id,
        X_DELIMITER                             => p_class_cat_rec.delimiter
    );

    set_frozen_flag(p_class_cat_rec.class_category);

END;

/*===========================================================================+
 | PROCEDURE
 |              do_update_class_category
 |
 | DESCRIPTION
 |              Updates class category
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |              OUT:
 |          IN/ OUT:
 |                    p_class_cat_rec
 |                    p_last_update_date
 |                    x_return_status
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |
 +===========================================================================*/

PROCEDURE do_update_class_category(
    p_class_cat_rec             IN OUT  NOCOPY CLASS_CATEGORY_REC_TYPE,
    p_object_version_number     IN OUT NOCOPY  NUMBER,
    x_return_status             IN OUT NOCOPY  VARCHAR2
) IS

    l_object_version_number             NUMBER;
    l_rowid                             ROWID;
    l_allow_leaf_node_only_flag         VARCHAR2(1);
    l_delimiter                         VARCHAR2(1);
    l_allow_multi_parent_flag           VARCHAR2(1);
BEGIN

    -- check whether record has been updated by another user. If not, lock it.
    BEGIN
        SELECT OBJECT_VERSION_NUMBER,
               ROWID, allow_leaf_node_only_flag,delimiter,allow_multi_parent_flag
        INTO   l_object_version_number,
               l_rowid,l_allow_leaf_node_only_flag,l_delimiter,l_allow_multi_parent_flag
        FROM   HZ_CLASS_CATEGORIES
        WHERE  CLASS_CATEGORY = p_class_cat_rec.class_category
        FOR UPDATE OF CLASS_CATEGORY NOWAIT;

        IF NOT ((p_object_version_number is null and l_object_version_number is null)
                OR (p_object_version_number = l_object_version_number))
        THEN
            FND_MESSAGE.SET_NAME('AR', 'HZ_API_RECORD_CHANGED');
            FND_MESSAGE.SET_TOKEN('TABLE', 'HZ_CLASS_CATEGORIES');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        END IF;

        p_object_version_number := nvl(l_object_version_number, 1) + 1;

    EXCEPTION WHEN NO_DATA_FOUND THEN
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_NO_RECORD');
        FND_MESSAGE.SET_TOKEN('RECORD', 'HZ_CLASS_CATEGORIES');
        FND_MESSAGE.SET_TOKEN('VALUE', 'p_class_cat_rec.class_category');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END;

    -- call for validations.
    HZ_CLASS_VALIDATE_V2PUB.validate_class_category(p_class_cat_rec, 'U', x_return_status);

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    if p_class_cat_rec.delimiter is not null
         and (nvl(l_delimiter,fnd_api.g_miss_char) <> p_class_cat_rec.delimiter)
    then
        If HZ_CLASS_VALIDATE_V2PUB.is_valid_delimiter(p_class_cat_rec.class_category,p_class_cat_rec.delimiter)='N'
        then
            FND_MESSAGE.SET_NAME('AR', 'HZ_INVALID_DELIMITER');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        end if;
    end if;

    if  (p_class_cat_rec.allow_leaf_node_only_flag is not null
         and (nvl(l_allow_leaf_node_only_flag,fnd_api.g_miss_char) <> p_class_cat_rec.allow_leaf_node_only_flag))
        or (p_class_cat_rec.delimiter is not null
         and (nvl(l_delimiter,fnd_api.g_miss_char) <> p_class_cat_rec.delimiter))
        or (p_class_cat_rec.allow_multi_parent_flag is not null
         and (nvl(l_allow_multi_parent_flag,fnd_api.g_miss_char) <> p_class_cat_rec.allow_multi_parent_flag))
    then
        set_frozen_flag(p_class_cat_rec.class_category);
    end if;


    -- call to table-handler.
    HZ_CLASS_CATEGORIES_PKG.Update_Row (
        X_CLASS_CATEGORY                        => p_class_cat_rec.class_category,
        X_ALLOW_MULTI_PARENT_FLAG               => p_class_cat_rec.allow_multi_parent_flag,
        X_ALLOW_MULTI_ASSIGN_FLAG               => p_class_cat_rec.allow_multi_assign_flag,
        X_ALLOW_LEAF_NODE_ONLY_FLAG             => p_class_cat_rec.allow_leaf_node_only_flag,
        X_OBJECT_VERSION_NUMBER                 => p_object_version_number,
        X_CREATED_BY_MODULE                     => p_class_cat_rec.created_by_module,
        X_APPLICATION_ID                        => p_class_cat_rec.application_id,
        X_DELIMITER                             => p_class_cat_rec.delimiter
    );

END;


/*===========================================================================+
 | PROCEDURE
 |              do_create_class_code_relation
 |
 | DESCRIPTION
 |              Creates class code relation
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |              OUT:
 |          IN/ OUT:
 |                    p_class_code_rel_rec
 |                    x_return_status
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |
 +===========================================================================*/

PROCEDURE do_create_class_code_relation(
    p_class_code_rel_rec       IN OUT    NOCOPY CLASS_CODE_RELATION_REC_TYPE,
    x_return_status            IN OUT NOCOPY    VARCHAR2
) IS

    l_rowid                              ROWID := NULL;

BEGIN

   -- Bug 3816590. Default start_date_active to sysdate if user has not passed any value.

    If p_class_code_rel_rec.start_date_active is null
      OR p_class_code_rel_rec.start_date_active = fnd_api.g_miss_date
    then
         p_class_code_rel_rec.start_date_active := sysdate;
   end if;

    HZ_CLASS_VALIDATE_V2PUB.validate_class_code_relation(
                                                             p_class_code_rel_rec,
                                                             'C',
                                                             x_return_status);

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    HZ_CLASS_CODE_RELATIONS_PKG.Insert_Row (
        X_CLASS_CATEGORY                        => p_class_code_rel_rec.class_category,
        X_CLASS_CODE                            => p_class_code_rel_rec.class_code,
        X_SUB_CLASS_CODE                        => p_class_code_rel_rec.sub_class_code,
        X_START_DATE_ACTIVE                     => p_class_code_rel_rec.start_date_active,
        X_END_DATE_ACTIVE                       => p_class_code_rel_rec.end_date_active,
        X_OBJECT_VERSION_NUMBER                 => 1,
        X_CREATED_BY_MODULE                     => p_class_code_rel_rec.created_by_module,
        X_APPLICATION_ID                        => p_class_code_rel_rec.application_id
    );

    set_frozen_flag(p_class_code_rel_rec.class_category);
END;

/*===========================================================================+
 | PROCEDURE
 |              do_update_class_code_relation
 |
 | DESCRIPTION
 |              Updates class code relation
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |              OUT:
 |          IN/ OUT:
 |                    p_class_code_rel_rec
 |                    p_last_update_date
 |                    x_return_status
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |
 +===========================================================================*/

PROCEDURE do_update_class_code_relation(
    p_class_code_rel_rec    IN OUT    NOCOPY CLASS_CODE_RELATION_REC_TYPE,
    p_object_version_number IN OUT NOCOPY    NUMBER,
    x_return_status         IN OUT NOCOPY    VARCHAR2
) IS

    l_object_version_number           NUMBER;
    l_rowid                           ROWID;
    l_end_date_active                 DATE;
BEGIN

    -- check whether record has been updated by another user. If not, lock it.
    BEGIN
        SELECT OBJECT_VERSION_NUMBER,
               ROWID,END_DATE_ACTIVE
        INTO   l_object_version_number,
               l_rowid,l_end_date_active
        FROM   HZ_CLASS_CODE_RELATIONS
        WHERE  CLASS_CATEGORY     = p_class_code_rel_rec.class_category
        AND    CLASS_CODE         = p_class_code_rel_rec.class_code
        AND    SUB_CLASS_CODE     = p_class_code_rel_rec.sub_class_code
        AND    START_DATE_ACTIVE  = p_class_code_rel_rec.START_DATE_ACTIVE
        FOR UPDATE OF CLASS_CATEGORY, CLASS_CODE, SUB_CLASS_CODE NOWAIT;

        IF NOT ((p_object_version_number is null and l_object_version_number is null)
                OR (p_object_version_number = l_object_version_number))
        THEN
            FND_MESSAGE.SET_NAME('AR', 'HZ_API_RECORD_CHANGED');
            FND_MESSAGE.SET_TOKEN('TABLE', 'HZ_CLASS_CODE_RELATIONS');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        END IF;

        p_object_version_number := nvl(l_object_version_number, 1) + 1;

    EXCEPTION WHEN NO_DATA_FOUND THEN
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_NO_RECORD');
        FND_MESSAGE.SET_TOKEN('RECORD', 'HZ_CLASS_CODE_RELATIONS');
        FND_MESSAGE.SET_TOKEN('VALUE', 'p_class_code_rel_rec.class_category');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END;

    -- call for validations.
    HZ_CLASS_VALIDATE_V2PUB.validate_class_code_relation(
                                                             p_class_code_rel_rec,
                                                             'U',
                                                             x_return_status);

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    if  p_class_code_rel_rec.end_date_active is not null
         and (nvl(l_end_date_active,fnd_api.g_miss_date) <> p_class_code_rel_rec.end_date_active)
    then
        set_frozen_flag(p_class_code_rel_rec.class_category);
    end if;

    -- call to table-handler.
    HZ_CLASS_CODE_RELATIONS_PKG.Update_Row (
        X_CLASS_CATEGORY                        => p_class_code_rel_rec.class_category,
        X_CLASS_CODE                            => p_class_code_rel_rec.class_code,
        X_SUB_CLASS_CODE                        => p_class_code_rel_rec.sub_class_code,
        X_START_DATE_ACTIVE                     => p_class_code_rel_rec.start_date_active,
        X_END_DATE_ACTIVE                       => p_class_code_rel_rec.end_date_active,
        X_OBJECT_VERSION_NUMBER                 => p_object_version_number,
        X_CREATED_BY_MODULE                     => p_class_code_rel_rec.created_by_module,
        X_APPLICATION_ID                        => p_class_code_rel_rec.application_id
    );

END;


/*===========================================================================+
 | PROCEDURE
 |              do_create_code_assignment
 |
 | DESCRIPTION
 |              Creates code assignment
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |              OUT:
 |          IN/ OUT:
 |                    p_code_assignment_rec
 |                    x_return_status
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |   May-29-2003 The API needs to be protected by Data security Bug 2963010
 |   Sep-09-2003  Rajib Ranjan Borah    o The API defaults the value of content_source_type
 |                                        to 'USER_ENTERED'.Bug Number -2824772.
 |   20-Nov-2003  Ramesh Ch          Bug No: 3216842. Denormalized SIC_CODE and SIC_CODE_TYPE columns into
 |                                   HZ_PARTIES and HZ_ORGANIZATION_PROFILES tables for ORGANIZATION party
 |                                   primary code assignments of 1972 SIC,1977 SIC,1987 SIC and NAICS_1997
 |                                   class category type.
 |   05-Jan-2005  Rajib Ranjan Borah   o SSM SST Integration and Extension.
 |                                       Passed the value of actual_content_source to
 |                                       table_handler.
 +===========================================================================*/

PROCEDURE do_create_code_assignment(
    p_code_assignment_rec     IN OUT   NOCOPY CODE_ASSIGNMENT_REC_TYPE,
    x_return_status           IN OUT NOCOPY   VARCHAR2
) IS

    l_rowid                   ROWID := NULL;

    dss_return_status VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
    dss_msg_count     NUMBER := 0;
    dss_msg_data      VARCHAR2(2000):= null;
    l_test_security   VARCHAR2(1):= 'F';

 l_object_version_number NUMBER;
    l_organization_name VARCHAR2(360);
    x_profile_id NUMBER;
    l_organization_rec hz_party_v2pub.organization_rec_type;
    l_party_rec hz_party_v2pub.party_rec_type;

    --Bug No: 3216842

    CURSOR c_party_type(c_party_id NUMBER) IS
    SELECT party_type,object_version_number,
    sic_code_type,sic_code /* Bug 4156312 */
    FROM HZ_PARTIES
    WHERE party_id=c_party_id;

    l_party_type   HZ_PARTIES.party_type%TYPE :=NULL;

   -- End Of 3216842.

    -- Bug 4156312
    l_sic_code_type   HZ_PARTIES.sic_code_type%TYPE;
    l_sic_code   HZ_PARTIES.sic_code%TYPE;


BEGIN

-- Bug 3070461. Default start_date_active to sysdate if user has not passed any value.
    If p_code_assignment_rec.start_date_active is null OR p_code_assignment_rec.start_date_active = fnd_api.g_miss_date then
        p_code_assignment_rec.start_date_active := sysdate;
   end if;


    --Bug Number 2824772 . API should default the 'content_source_type' column value to'USER_ENTERED'

    IF p_code_assignment_rec.content_source_type IS NULL
                          OR
       p_code_assignment_rec.content_source_type = FND_API.G_MISS_CHAR
    THEN
       p_code_assignment_rec.content_source_type :='USER_ENTERED';
    END IF;



    HZ_CLASS_VALIDATE_V2PUB.validate_code_assignment(
                                                         p_code_assignment_rec,
                                                         'C',
                                                         x_return_status);

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    --Bug 2830772: For 'NACE' lookup type, if the content_source_type is not
    --'USER_ENTERED', even if the lookup_code is passed incorrectly with respect
    --to decimal point, the value that needs to be stored in the column is the value
    --that is present in the lookup.
    IF( p_code_assignment_rec.actual_content_source <> 'USER_ENTERED'
        AND
        p_code_assignment_rec.class_category = 'NACE'
      )
    THEN
      SELECT lookup_code
      INTO   p_code_assignment_rec.class_code
      FROM   fnd_lookup_values
      WHERE  replace(lookup_code, '.', '') = replace(p_code_assignment_rec.class_code, '.', '')
      AND    lookup_type='NACE'
      AND    rownum = 1;
    END IF;



    HZ_CODE_ASSIGNMENTS_PKG.Insert_Row (
        X_CODE_ASSIGNMENT_ID                    => p_code_assignment_rec.code_assignment_id,
        X_OWNER_TABLE_NAME                      => p_code_assignment_rec.owner_table_name,
        X_OWNER_TABLE_ID                        => p_code_assignment_rec.owner_table_id,
        X_OWNER_TABLE_KEY_1                     => p_code_assignment_rec.owner_table_key_1,
        X_OWNER_TABLE_KEY_2                     => p_code_assignment_rec.owner_table_key_2,
        X_OWNER_TABLE_KEY_3                     => p_code_assignment_rec.owner_table_key_3,
        X_OWNER_TABLE_KEY_4                     => p_code_assignment_rec.owner_table_key_4,
        X_OWNER_TABLE_KEY_5                     => p_code_assignment_rec.owner_table_key_5,
        X_CLASS_CATEGORY                        => p_code_assignment_rec.class_category,
        X_CLASS_CODE                            => p_code_assignment_rec.class_code,
        X_PRIMARY_FLAG                          => p_code_assignment_rec.primary_flag,
        X_CONTENT_SOURCE_TYPE                   => p_code_assignment_rec.content_source_type,
        X_START_DATE_ACTIVE                     => p_code_assignment_rec.start_date_active,
        X_END_DATE_ACTIVE                       => p_code_assignment_rec.end_date_active,
        X_STATUS                                => p_code_assignment_rec.status,
        X_OBJECT_VERSION_NUMBER                 => 1,
        X_CREATED_BY_MODULE                     => p_code_assignment_rec.created_by_module,
        X_RANK                                  => p_code_assignment_rec.rank,
        X_APPLICATION_ID                        => p_code_assignment_rec.application_id,
        -- SSM SST Integration and Extension
        X_ACTUAL_CONTENT_SOURCE                 => p_code_assignment_rec.actual_content_source
    );

    -- VJN INTRODUCED CHANGE
    -- THE CALL OUT TO DSS SHOULD HAPPEN ONLY IF THE CODE ASSIGNMENT
    -- IS FOR HZ_PARTIES. IN OTHER WORDS, THE CODE ASSIGNMENT IS
    -- SECURED ONLY AT THE PARTY LEVEL AND NOT THE DETAILS.
    --
    -- Bug 3818648: do dss check in party context only. check dss
    -- profile before call test_instance.
    --
    IF NVL(fnd_profile.value('HZ_DSS_ENABLED'), 'N') = 'Y' AND
       p_code_assignment_rec.owner_table_name = 'HZ_PARTIES'
    THEN
      ---Bug 2963010 make table HZ_CODE_ASSIGNMENTS protected by Data Security
      ---Check if the DSS security is granted to the user
      l_test_security :=
        hz_dss_util_pub.test_instance(
               p_operation_code     => 'INSERT',
               p_db_object_name     => 'HZ_CODE_ASSIGNMENTS',
               p_instance_pk1_value => p_code_assignment_rec.code_assignment_id,
               p_user_name          => fnd_global.user_name,
               x_return_status      => dss_return_status,
               x_msg_count          => dss_msg_count,
               x_msg_data           => dss_msg_data);

      if dss_return_status <> fnd_api.g_ret_sts_success THEN
        RAISE FND_API.G_EXC_ERROR;
      end if;

      if (l_test_security <> 'T' OR l_test_security <> FND_API.G_TRUE) then
        --
        -- Bug 3835601: replaced the dss message with a more user friendly message
        --
        FND_MESSAGE.SET_NAME('AR', 'HZ_DSS_NO_INSERT_PRIVILEGE');
        FND_MESSAGE.SET_TOKEN('ENTITY_NAME',
                              hz_dss_util_pub.get_display_name('HZ_CODE_ASSIGNMENTS', null));
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
      end if;
    END IF;


   -- Bug No: 4091181. Modified logic to denormalize SIC_CODE and SIC_CODE_TYPE to
    --  HZ_PARTIES and HZ_ORGANIZATION_PROFILES tables for ORGANIZATION party
    --  Primary code assignments of 1972 SIC,1977 SIC,1987 SIC and NAICS_1997
    --  class category type.
     IF UPPER(p_code_assignment_rec.owner_table_name) = 'HZ_PARTIES'
        AND
     -- Bug 6059383 : Denormalize for all industrial class and not only the hard coded values
     --   p_code_assignment_rec.class_category in ('1972 SIC' , '1977 SIC' , '1987 SIC' , 'NAICS_1997')
        is_industrial_class(p_code_assignment_rec.class_category) = 'Y'
     THEN
       IF
         p_code_assignment_rec.primary_flag='Y'
         AND
         p_code_assignment_rec.start_date_active<=sysdate
         AND
         (
          p_code_assignment_rec.end_date_active is NULL
          OR p_code_assignment_rec.end_date_active=fnd_api.g_miss_date
          OR p_code_assignment_rec.end_date_active>sysdate
         )
       THEN
         OPEN c_party_type(p_code_assignment_rec.owner_table_id);
         FETCH c_party_type INTO l_party_type,l_object_version_number,l_sic_code_type,l_sic_code;
         CLOSE c_party_type;

          IF (l_party_type='ORGANIZATION'
             /* Bug 4156312 */
             AND (
             (l_sic_code_type is null and l_sic_code is null)
             OR
             (l_sic_code_type is NOT NULL
              AND l_sic_code is NOT NULL
              AND (p_code_assignment_rec.class_category<>l_sic_code_type
                   OR p_code_assignment_rec.class_code<>l_sic_code)
             )))
         THEN

             l_party_rec.party_id                 := p_code_assignment_rec.owner_table_id;
             l_organization_rec.SIC_CODE_TYPE     := p_code_assignment_rec.class_category;
             l_organization_rec.SIC_CODE          := p_code_assignment_rec.class_code;
             l_organization_rec.party_rec         := l_party_rec;

             l_organization_rec.actual_content_source:=p_code_assignment_rec.actual_content_source;

             --Call to Update organization to update both HZ_PARTIES AND HZ_ORGANIZATION_PROFILES

             HZ_PARTY_V2PUB.update_organization(
             'T',
             l_organization_rec,
             l_object_version_number,
             x_profile_id,
             x_return_status,
             dss_msg_count,
             dss_msg_data);
             IF x_return_status <> fnd_api.g_ret_sts_success THEN
                 RAISE FND_API.G_EXC_ERROR;
             END IF;
          END IF;
       END IF;
     END IF;

-- Bug 4091181. Modified logic to denormalize class code for 'CUSTOMER_CATEGORY'
-- class category to HZ_PARTIES

  IF UPPER(p_code_assignment_rec.owner_table_name) = 'HZ_PARTIES'
        AND
        p_code_assignment_rec.class_category='CUSTOMER_CATEGORY'
  THEN
       IF
         p_code_assignment_rec.primary_flag='Y'
         AND
         p_code_assignment_rec.start_date_active<=sysdate
         AND
         (
          p_code_assignment_rec.end_date_active is NULL
          OR p_code_assignment_rec.end_date_active=fnd_api.g_miss_date
          OR p_code_assignment_rec.end_date_active>sysdate
         )
       THEN
         update hz_parties
         set category_code        = p_code_assignment_rec.class_code,
             last_update_date     = hz_utility_v2pub.last_update_date,
             last_updated_by      = hz_utility_v2pub.last_updated_by,
             last_update_login    = hz_utility_v2pub.last_update_login
             where party_id = p_code_assignment_rec.owner_table_id;

             --Bug9058492
             OPEN c_party_type(p_code_assignment_rec.owner_table_id);
 	         FETCH c_party_type INTO l_party_type,l_object_version_number,l_sic_code_type,l_sic_code;
 	         CLOSE c_party_type;

 	              IF l_party_type = 'PERSON' THEN
 	                 HZ_DQM_SYNC.sync_person(p_code_assignment_rec.owner_table_id, 'C');
 	              ELSIF l_party_type = 'ORGANIZATION' THEN
 	                 HZ_DQM_SYNC.sync_org(p_code_assignment_rec.owner_table_id, 'C');
 	              END IF;

       END IF;
  END IF;




END;

/*===========================================================================+
 | PROCEDURE
 |              do_update_code_assignment
 |
 | DESCRIPTION
 |              Updates code assignment
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |              OUT:
 |          IN/ OUT:
 |                    p_code_assignment_rec
 |                    p_last_update_date
 |                    x_return_status
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |
 |   20-Nov-2003  Ramesh Ch          Bug No: 3216842. Denormalized SIC_CODE and SIC_CODE_TYPE columns into
 |                                   HZ_PARTIES and HZ_ORGANIZATION_PROFILES tables for ORGANIZATION party
 |                                   primary code assignments of 1972 SIC,1977 SIC,1987 SIC and NAICS_1997
 |                                   class category type.
 |   05-Jan-2005  Rajib Ranjan Borah   o SSM SST Integration and Extension.
 |                                       Passed the value of actual_content_source to
 |                                       table_handler.
 +===========================================================================*/

PROCEDURE do_update_code_assignment(
    p_code_assignment_rec        IN OUT  NOCOPY CODE_ASSIGNMENT_REC_TYPE,
    p_object_version_number      IN OUT NOCOPY  NUMBER,
    x_return_status              IN OUT NOCOPY  VARCHAR2
) IS

    l_object_version_number              NUMBER;
    l_rowid                              ROWID;

 l_owner_table_name VARCHAR2(30);
    l_owner_table_id NUMBER;
    l_class_category VARCHAR2(30);
    l_class_code VARCHAR2(30);
    l_organization_name VARCHAR2(360);
    x_profile_id NUMBER;
dss_msg_count     NUMBER := 0;
dss_msg_data      VARCHAR2(2000):= null;

    l_organization_rec hz_party_v2pub.organization_rec_type;
    l_party_rec hz_party_v2pub.party_rec_type;

    --Commented code for Bug No. 4091181.
    --Bug No: 3216842
    /*
    CURSOR c_old_code_values(c_code_assignment_id NUMBER) IS
    SELECT owner_table_id,owner_table_name,class_category,
           class_code,primary_flag, start_date_active, end_date_active
    FROM hz_code_assignments
    WHERE code_assignment_id = c_code_assignment_id;
    */

    CURSOR c_party_type(c_party_id NUMBER) IS
    SELECT party_type,object_version_number,
    sic_code_type,sic_code /* Bug 4156312 */
    FROM HZ_PARTIES
    WHERE party_id=c_party_id;


    -- Bug 4059298.
    CURSOR c_new_denorm(p_party_id NUMBER,p_code_id NUMBER) Is
    SELECT class_category,class_code
    from (
          select code_assignment_id,class_category,class_code
          from hz_code_assignments a
          --where class_category in ('1972 SIC','1977 SIC','1987 SIC','NAICS_1997') -- Bug 6059383
          WHERE owner_table_id = p_party_id
          and sysdate between start_date_active and nvl(end_date_active,sysdate+1)
          and primary_flag='Y'
          and code_assignment_id < p_code_id
          -- Added for Bug 6059383 (remove hard coding for industrial classification)
          AND EXISTS (SELECT NULL FROM hz_code_assignments b
                      WHERE  a.class_category = b.owner_table_key_1
                      AND    b.owner_table_name = 'HZ_CLASS_CATEGORIES'
                      AND    b.class_category   = 'CLASS_CATEGORY_GROUP'
                      AND    b.class_code       = 'INDUSTRIAL_GROUP'
                      AND    SYSDATE BETWEEN b.start_date_active AND NVL(b.end_date_active,SYSDATE+1)
                      AND    NVL(b.status,'A') = 'A'
                      )
          order by code_assignment_id desc
          )
    where rownum=1;

    l_party_type   HZ_PARTIES.party_type%TYPE;
    l_primary_flag HZ_CODE_ASSIGNMENTS.PRIMARY_FLAG%TYPE;
    l_denorm_flag  BOOLEAN :=FALSE;
   -- End Of 3216842.

    l_category_code VARCHAR2(30);
    l_start_date DATE;
    l_end_date DATE;

    -- Bug 4091181
    l_actual_content_src HZ_CODE_ASSIGNMENTS.actual_content_source%TYPE;

    -- Bug 4156312
    l_sic_code_type   HZ_PARTIES.sic_code_type%TYPE;
    l_sic_code   HZ_PARTIES.sic_code%TYPE;

    --  Bug 4693719 : Added for local assignment
    l_acs HZ_CODE_ASSIGNMENTS.actual_content_source%TYPE;

BEGIN

    -- check whether record has been updated by another user. If not, lock it.
    BEGIN
        -- Bug 4091181. Modified the statement to remove use of cursor
        -- c_old_code_values.
        SELECT OBJECT_VERSION_NUMBER,owner_table_id, owner_table_name,
               class_category, class_code,primary_flag, start_date_active,
               end_date_active,ROWID,actual_content_source
        INTO   l_object_version_number,l_owner_table_id,l_owner_table_name,
               l_class_category,l_class_code,l_primary_flag, l_start_date,
               l_end_date,l_rowid,l_actual_content_src
        FROM   HZ_CODE_ASSIGNMENTS
        WHERE  CODE_ASSIGNMENT_ID = p_code_assignment_rec.code_assignment_id
        FOR UPDATE OF CODE_ASSIGNMENT_ID NOWAIT;

        IF NOT ((p_object_version_number is null and l_object_version_number is null)
                --Bug 4260943
                OR (p_object_version_number is not null and
                    l_object_version_number is not null and
                    p_object_version_number = l_object_version_number))
        THEN
            FND_MESSAGE.SET_NAME('AR', 'HZ_API_RECORD_CHANGED');
            FND_MESSAGE.SET_TOKEN('TABLE', 'HZ_CODE_ASSIGNMENTS');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        END IF;

        p_object_version_number := nvl(l_object_version_number, 1) + 1;

    EXCEPTION WHEN NO_DATA_FOUND THEN
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_NO_RECORD');
        FND_MESSAGE.SET_TOKEN('RECORD', 'HZ_CODE_ASSIGNMENTS');
        FND_MESSAGE.SET_TOKEN('VALUE', 'p_code_assignment_rec.code_assignment_id');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END;

    -- call for validations.
    HZ_CLASS_VALIDATE_V2PUB.validate_code_assignment(
                                                         p_code_assignment_rec,
                                                         'U',
                                                         x_return_status);

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    --Bug 2830772: For 'NACE' lookup type, if the content_source_type is not
    --'USER_ENTERED', even if the lookup_code is passed incorrectly with respect
    --to decimal point, the value that needs to be stored in the column is the value
    --that is present in the lookup.
    IF( p_code_assignment_rec.actual_content_source <> 'USER_ENTERED'
        AND
        p_code_assignment_rec.class_category = 'NACE'
      )
    THEN
      SELECT lookup_code
      INTO   p_code_assignment_rec.class_code
      FROM   fnd_lookup_values
      WHERE  replace(lookup_code, '.', '') = replace(nvl(p_code_assignment_rec.class_code,l_class_code), '.', '')
      AND    lookup_type='NACE'
      AND    rownum = 1;
    END IF;

    --Commented code for Bug No. 4091181.

    /*
    ---Bug no :3216842

    OPEN c_old_code_values(p_code_assignment_rec.code_assignment_id);
    FETCH c_old_code_values INTO l_owner_table_id,l_owner_table_name,l_class_category,
          l_class_code,l_primary_flag, l_start_date, l_end_date;
    CLOSE c_old_code_values;

    --End of :3216842
    */
    --  Bug 4693719 : pass NULL if secure data is not updated
    IF HZ_UTILITY_V2PUB.G_UPDATE_ACS = 'Y' THEN
       l_acs := nvl(p_code_assignment_rec.actual_content_source, 'USER_ENTERED');
    ELSE
       l_acs := NULL;
    END IF;

    -- call to table-handler.
    HZ_CODE_ASSIGNMENTS_PKG.Update_Row (
        X_Rowid                                 => l_rowid,
        X_CODE_ASSIGNMENT_ID                    => p_code_assignment_rec.code_assignment_id,
        X_OWNER_TABLE_NAME                      => p_code_assignment_rec.owner_table_name,
        X_OWNER_TABLE_ID                        => p_code_assignment_rec.owner_table_id,
        X_OWNER_TABLE_KEY_1                     => p_code_assignment_rec.owner_table_key_1,
        X_OWNER_TABLE_KEY_2                     => p_code_assignment_rec.owner_table_key_2,
        X_OWNER_TABLE_KEY_3                     => p_code_assignment_rec.owner_table_key_3,
        X_OWNER_TABLE_KEY_4                     => p_code_assignment_rec.owner_table_key_4,
        X_OWNER_TABLE_KEY_5                     => p_code_assignment_rec.owner_table_key_5,
        X_CLASS_CATEGORY                        => p_code_assignment_rec.class_category,
        X_CLASS_CODE                            => p_code_assignment_rec.class_code,
        X_PRIMARY_FLAG                          => p_code_assignment_rec.primary_flag,
        X_CONTENT_SOURCE_TYPE                   => p_code_assignment_rec.content_source_type,
        X_START_DATE_ACTIVE                     => p_code_assignment_rec.start_date_active,
        X_END_DATE_ACTIVE                       => p_code_assignment_rec.end_date_active,
        X_STATUS                                => p_code_assignment_rec.status,
        X_OBJECT_VERSION_NUMBER                 => p_object_version_number,
        X_CREATED_BY_MODULE                     => p_code_assignment_rec.created_by_module,
        X_RANK                                  => p_code_assignment_rec.rank,
        X_APPLICATION_ID                        => p_code_assignment_rec.application_id,
        -- SSM SST Integration and Extension
        --  Bug 4693719 : Pass correct value for ACS
        X_ACTUAL_CONTENT_SOURCE                 => l_acs
    );

    -- Bug No: 4091181. Modified logic to denormalize SIC_CODE and SIC_CODE_TYPE to
    --  HZ_PARTIES and HZ_ORGANIZATION_PROFILES tables for ORGANIZATION party
    --  Primary code assignments of 1972 SIC,1977 SIC,1987 SIC and NAICS_1997
    --  class category type.


 IF UPPER(nvl(p_code_assignment_rec.owner_table_name,l_owner_table_name)) = 'HZ_PARTIES'
        AND
        -- Bug 6059383 : Denormalize for all industrial class and not only the hard coded values
        --  nvl(p_code_assignment_rec.class_category,l_class_category)
        --  in ('1972 SIC' , '1977 SIC' , '1987 SIC' , 'NAICS_1997')
        is_industrial_class(NVL(p_code_assignment_rec.class_category,l_class_category)) = 'Y'
     THEN
       IF
          (
            nvl(p_code_assignment_rec.primary_flag,l_primary_flag)='Y'
            AND
             (
               ( nvl(p_code_assignment_rec.end_date_active,l_end_date)<= SYSDATE
                 AND nvl(p_code_assignment_rec.end_date_active,l_end_date)<> fnd_api.g_miss_date
               )
               OR
                 nvl(p_code_assignment_rec.start_date_active,l_start_date)> SYSDATE

             )
           )
          OR (p_code_assignment_rec.primary_flag='N' AND l_primary_flag='Y')
       THEN

             -- Bug 4059298.
             OPEN c_party_type(nvl(p_code_assignment_rec.owner_table_id,l_owner_table_id));
             FETCH c_party_type INTO l_party_type,l_object_version_number,l_sic_code_type,l_sic_code;
             CLOSE c_party_type;

             IF l_party_type='ORGANIZATION'
             THEN
               OPEN c_new_denorm(l_owner_table_id,p_code_assignment_rec.code_assignment_id);
               FETCH c_new_denorm into l_organization_rec.SIC_CODE_TYPE ,l_organization_rec.SIC_CODE ;
               IF c_new_denorm%NOTFOUND
               THEN
                 l_organization_rec.SIC_CODE_TYPE     := fnd_api.g_miss_char;
                 l_organization_rec.SIC_CODE          := fnd_api.g_miss_char;
               END IF;
               CLOSE c_new_denorm;

               l_party_rec.party_id                 := l_owner_table_id;
               l_organization_rec.party_rec         := l_party_rec;

               l_organization_rec.actual_content_source:=l_actual_content_src;

               --Call to Update organization to update both HZ_PARTIES AND HZ_ORGANIZATION_PROFILES

               HZ_PARTY_V2PUB.update_organization(
               'T',
               l_organization_rec,
               l_object_version_number,
               x_profile_id,
               x_return_status,
               dss_msg_count,
               dss_msg_data);

               IF x_return_status <> fnd_api.g_ret_sts_success THEN
                 RAISE FND_API.G_EXC_ERROR;
               END IF;
             END IF;
       ELSIF
         nvl(p_code_assignment_rec.primary_flag,l_primary_flag)='Y'
         AND
         nvl(p_code_assignment_rec.start_date_active,l_start_date)<=sysdate
         AND
         (
          nvl(p_code_assignment_rec.end_date_active,l_end_date) is NULL
          OR nvl(p_code_assignment_rec.end_date_active,l_end_date)=fnd_api.g_miss_date
          OR nvl(p_code_assignment_rec.end_date_active,l_end_date)>sysdate
         )
       THEN
         OPEN c_party_type(nvl(p_code_assignment_rec.owner_table_id,l_owner_table_id));
         FETCH c_party_type INTO l_party_type,l_object_version_number,l_sic_code_type,l_sic_code;
         CLOSE c_party_type;


         IF (l_party_type='ORGANIZATION'
             /* Bug 4156312 */
             AND (
             (l_sic_code_type is null and l_sic_code is null)
             OR
             (l_sic_code_type is NOT NULL
              AND l_sic_code is NOT NULL
              AND (nvl(p_code_assignment_rec.class_category,l_class_category)<>l_sic_code_type
                   OR nvl(p_code_assignment_rec.class_code,l_class_code)<>l_sic_code)
             )))
         THEN

             l_party_rec.party_id                 := l_owner_table_id;
             l_organization_rec.SIC_CODE_TYPE     := nvl(p_code_assignment_rec.class_category,l_class_category);
             l_organization_rec.SIC_CODE          := nvl(p_code_assignment_rec.class_code,l_class_code);
             l_organization_rec.party_rec         := l_party_rec;

             l_organization_rec.actual_content_source:=l_actual_content_src;

             --Call to Update organization to update both HZ_PARTIES AND HZ_ORGANIZATION_PROFILES

             HZ_PARTY_V2PUB.update_organization(
             'T',
             l_organization_rec,
             l_object_version_number,
             x_profile_id,
             x_return_status,
             dss_msg_count,
             dss_msg_data);
             IF x_return_status <> fnd_api.g_ret_sts_success THEN
                 RAISE FND_API.G_EXC_ERROR;
             END IF;
          END IF;
       END IF;
  END IF;


-- Bug 4091181. Modified logic to denormalize class code for 'CUSTOMER_CATEGORY'
-- class category to HZ_PARTIES

    IF UPPER(nvl(p_code_assignment_rec.owner_table_name,l_owner_table_name)) = 'HZ_PARTIES'
        AND
        nvl(p_code_assignment_rec.class_category,l_class_category)='CUSTOMER_CATEGORY'
     THEN
       IF
          (
            nvl(p_code_assignment_rec.primary_flag,l_primary_flag)='Y'
            AND
             (
               ( nvl(p_code_assignment_rec.end_date_active,l_end_date)<= SYSDATE
                 AND nvl(p_code_assignment_rec.end_date_active,l_end_date)<> fnd_api.g_miss_date
               )
               OR
                 nvl(p_code_assignment_rec.start_date_active,l_start_date)> SYSDATE

             )
           )
          OR (p_code_assignment_rec.primary_flag='N' AND l_primary_flag='Y')
       THEN
        -- terminating
           UPDATE HZ_PARTIES
           SET    CATEGORY_CODE        = NULL,
                  last_update_date     = hz_utility_v2pub.last_update_date,
                  last_updated_by      = hz_utility_v2pub.last_updated_by,
                  last_update_login    = hz_utility_v2pub.last_update_login
           WHERE  PARTY_ID = nvl(p_code_assignment_rec.owner_table_id,l_owner_table_id)
           AND    CATEGORY_CODE = nvl(p_code_assignment_rec.class_code,l_class_code);
       ELSIF
         nvl(p_code_assignment_rec.primary_flag,l_primary_flag)='Y'
         AND
         nvl(p_code_assignment_rec.start_date_active,l_start_date)<=sysdate
         AND
         (
          nvl(p_code_assignment_rec.end_date_active,l_end_date) is NULL
          OR nvl(p_code_assignment_rec.end_date_active,l_end_date)=fnd_api.g_miss_date
          OR nvl(p_code_assignment_rec.end_date_active,l_end_date)>sysdate
         )
       THEN
         update hz_parties
         set category_code        = nvl(p_code_assignment_rec.class_code,l_class_code),
             last_update_date     = hz_utility_v2pub.last_update_date,
             last_updated_by      = hz_utility_v2pub.last_updated_by,
             last_update_login    = hz_utility_v2pub.last_update_login
             where party_id = l_owner_table_id;

                 --Bug9058492
 	              OPEN c_party_type(nvl(p_code_assignment_rec.owner_table_id,l_owner_table_id));
 	              FETCH c_party_type INTO l_party_type,l_object_version_number,l_sic_code_type,l_sic_code;
 	              CLOSE c_party_type;


 	              IF l_party_type = 'PERSON' THEN
 	                 HZ_DQM_SYNC.sync_person(p_code_assignment_rec.owner_table_id, 'U');
 	              ELSIF l_party_type = 'ORGANIZATION' THEN
 	                 HZ_DQM_SYNC.sync_org(p_code_assignment_rec.owner_table_id, 'U');
 	              END IF;


       END IF;
  END IF;



END;


/*===========================================================================+
 | PROCEDURE
 |              do_create_class_category_use
 |
 | DESCRIPTION
 |              Create class category use
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |              OUT:
 |          IN/ OUT:
 |                    p_class_category_use_rec
 |                    p_last_update_date
 |                    x_return_status
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |
 +===========================================================================*/

PROCEDURE do_create_class_category_use(
    p_class_category_use_rec  IN OUT  NOCOPY CLASS_CATEGORY_USE_REC_TYPE,
    x_return_status           IN OUT NOCOPY  VARCHAR2
) IS

 l_rowid                              ROWID := NULL;

BEGIN

    HZ_CLASS_VALIDATE_V2PUB.validate_class_category_use(
                                                            p_class_category_use_rec,
                                                            'C',
                                                            x_return_status);

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    HZ_CLASS_CATEGORY_USES_PKG.Insert_Row (
        X_CLASS_CATEGORY                        => p_class_category_use_rec.class_category,
        X_OWNER_TABLE                           => p_class_category_use_rec.owner_table,
        X_COLUMN_NAME                           => p_class_category_use_rec.column_name,
        X_ADDITIONAL_WHERE_CLAUSE               => p_class_category_use_rec.additional_where_clause,
        X_OBJECT_VERSION_NUMBER                 => 1,
        X_CREATED_BY_MODULE                     => p_class_category_use_rec.created_by_module,
        X_APPLICATION_ID                        => p_class_category_use_rec.application_id
    );

END do_create_class_category_use;


/*===========================================================================+
 | PROCEDURE
 |              do_update_class_category_use
 |
 | DESCRIPTION
 |              Updates class category use
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |              OUT:
 |          IN/ OUT:
 |                    p_class_category_use_rec
 |                    p_last_update_date
 |                    x_return_status
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |
 +===========================================================================*/

PROCEDURE do_update_class_category_use(
    p_class_category_use_rec  IN OUT  NOCOPY CLASS_CATEGORY_USE_REC_TYPE,
    p_object_version_number   IN OUT NOCOPY  NUMBER,
    x_return_status           IN OUT NOCOPY  VARCHAR2)
IS

    l_object_version_number           NUMBER;
    l_rowid                           ROWID;

BEGIN

    -- check whether record has been updated by another user. If not, lock it.
    BEGIN
        SELECT OBJECT_VERSION_NUMBER,
               ROWID
        INTO   l_object_version_number,
               l_rowid
        FROM   HZ_CLASS_CATEGORY_USES
        WHERE  CLASS_CATEGORY = p_class_category_use_rec.class_category
        AND    OWNER_TABLE    = p_class_category_use_rec.owner_table
        FOR UPDATE OF CLASS_CATEGORY, OWNER_TABLE, COLUMN_NAME, ADDITIONAL_WHERE_CLAUSE NOWAIT;

        IF NOT ((p_object_version_number is null and l_object_version_number is null)
                OR (p_object_version_number = l_object_version_number))
        THEN
            FND_MESSAGE.SET_NAME('AR', 'HZ_API_RECORD_CHANGED');
            FND_MESSAGE.SET_TOKEN('TABLE', 'HZ_CLASS_CATEGORY_USES');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        END IF;

        p_object_version_number := nvl(l_object_version_number, 1) + 1;

    EXCEPTION WHEN NO_DATA_FOUND THEN
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_NO_RECORD');
        FND_MESSAGE.SET_TOKEN('RECORD', 'HZ_CLASS_CATEGORY_USES');
        FND_MESSAGE.SET_TOKEN('VALUE', 'p_class_category_use_rec.class_category');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END;

    -- call for validations.
    HZ_CLASS_VALIDATE_V2PUB.validate_class_category_use(
                                                            p_class_category_use_rec,
                                                            'U',
                                                            x_return_status);

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- call to table-handler.
    HZ_CLASS_CATEGORY_USES_PKG.Update_Row (
        X_CLASS_CATEGORY                        => p_class_category_use_rec.class_category,
        X_OWNER_TABLE                           => p_class_category_use_rec.owner_table,
        X_COLUMN_NAME                           => p_class_category_use_rec.column_name,
        X_ADDITIONAL_WHERE_CLAUSE               => p_class_category_use_rec.additional_where_clause,
        X_OBJECT_VERSION_NUMBER                 => p_object_version_number,
        X_CREATED_BY_MODULE                     => p_class_category_use_rec.created_by_module,
        X_APPLICATION_ID                        => p_class_category_use_rec.application_id
    );

END do_update_class_category_use;

--------------------------------------
-- public procedures and functions
--------------------------------------

/**
 * PROCEDURE create_class_category
 *
 * DESCRIPTION
 *     Creates class category.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *     HZ_BUSINESS_EVENT_V2PVT.create_class_category_event
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_class_category_rec           Class category record.
 *   IN/OUT:
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
 *   07-23-2001    Indrajit Sen        o Created.
 *
 */

PROCEDURE create_class_category(
    p_init_msg_list           IN        VARCHAR2 := FND_API.G_FALSE,
    p_class_category_rec      IN        CLASS_CATEGORY_REC_TYPE,
    x_return_status           OUT NOCOPY       VARCHAR2,
    x_msg_count               OUT NOCOPY       NUMBER,
    x_msg_data                OUT NOCOPY       VARCHAR2
) IS

    l_class_cat_rec                     CLASS_CATEGORY_REC_TYPE:= p_class_category_rec;

BEGIN

    -- standard start of API savepoint
    SAVEPOINT create_class_category;

    -- initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- call to business logic.
    do_create_class_category(
                             l_class_cat_rec,
                             x_return_status);

   IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN

    -- Invoke business event system.
--Bug 4743141.
     IF(HZ_UTILITY_V2PUB.G_EXECUTE_API_CALLOUTS in ('Y', 'EVENTS_ENABLED')) THEN
        HZ_BUSINESS_EVENT_V2PVT.create_class_category_event (
        l_class_cat_rec );
     END IF;

   END IF;

    -- standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO create_class_category;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO create_class_category;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

    WHEN OTHERS THEN
        ROLLBACK TO create_class_category;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);
END create_class_category;

/**
 * PROCEDURE update_class_category
 *
 * DESCRIPTION
 *     Updates class category.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *     HZ_BUSINESS_EVENT_V2PVT.update_class_category_event
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_class_category_rec           Class category record.
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
 *   07-23-2001    Indrajit Sen        o Created.
 *
 */

PROCEDURE update_class_category (
    p_init_msg_list             IN     VARCHAR2 := FND_API.G_FALSE,
    p_class_category_rec        IN     CLASS_CATEGORY_REC_TYPE,
    p_object_version_number     IN OUT NOCOPY NUMBER,
    x_return_status             OUT NOCOPY    VARCHAR2,
    x_msg_count                 OUT NOCOPY    NUMBER,
    x_msg_data                  OUT NOCOPY    VARCHAR2
) IS

    l_class_cat_rec                    CLASS_CATEGORY_REC_TYPE := p_class_category_rec;
    l_old_class_cat_rec                CLASS_CATEGORY_REC_TYPE;

BEGIN

    -- standard start of API savepoint
    SAVEPOINT update_class_category;

    -- initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Get old records. Will be used by business event system.
    get_class_category_rec (
        p_class_category                     => l_class_cat_rec.class_category,
        x_class_category_rec                 => l_old_class_cat_rec,
        x_return_status                      => x_return_status,
        x_msg_count                          => x_msg_count,
        x_msg_data                           => x_msg_data );

    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- call to business logic.
    do_update_class_category(
                             l_class_cat_rec,
                             p_object_version_number,
                             x_return_status);

   IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN

    -- Invoke business event system.
     --Bug 4743141.
     IF(HZ_UTILITY_V2PUB.G_EXECUTE_API_CALLOUTS in ('Y', 'EVENTS_ENABLED')) THEN
        HZ_BUSINESS_EVENT_V2PVT.update_class_category_event (
        l_class_cat_rec,
        l_old_class_cat_rec );
     END IF;

   END IF;

    -- standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO update_class_category;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO update_class_category;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

    WHEN OTHERS THEN
        ROLLBACK TO update_class_category;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

END update_class_category;

/**
 * PROCEDURE create_class_code_relation
 *
 * DESCRIPTION
 *     Creates class code relationship.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *     HZ_BUSINESS_EVENT_V2PVT.create_class_code_rel_event
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_class_code_relation_rec      Class code relation record.
 *   IN/OUT:
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
 *   07-23-2001    Indrajit Sen        o Created.
 *
 */

PROCEDURE create_class_code_relation(
    p_init_msg_list           IN       VARCHAR2 := FND_API.G_FALSE,
    p_class_code_relation_rec IN       CLASS_CODE_RELATION_REC_TYPE,
    x_return_status           OUT NOCOPY      VARCHAR2,
    x_msg_count               OUT NOCOPY      NUMBER,
    x_msg_data                OUT NOCOPY      VARCHAR2
) IS

    l_class_code_rel_rec      CLASS_CODE_RELATION_REC_TYPE := p_class_code_relation_rec;

BEGIN

    -- standard start of API savepoint
    SAVEPOINT create_class_code_relation;

    -- initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    -- call to business logic.
    do_create_class_code_relation(
                                  l_class_code_rel_rec,
                                  x_return_status);

   IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN

    -- Invoke business event system.
     --Bug 4743141.
     IF(HZ_UTILITY_V2PUB.G_EXECUTE_API_CALLOUTS in ('Y', 'EVENTS_ENABLED')) THEN
        HZ_BUSINESS_EVENT_V2PVT.create_class_code_rel_event (
        l_class_code_rel_rec );
     END IF;

   END IF;

    -- standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO create_class_code_relation;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO create_class_code_relation;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

    WHEN OTHERS THEN
        ROLLBACK TO create_class_code_relation;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);
END create_class_code_relation;

/**
 * PROCEDURE update_class_code_relation
 *
 * DESCRIPTION
 *     Updates class code relation.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *     HZ_BUSINESS_EVENT_V2PVT.update_class_code_rel_event
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_class_code_relation_rec      Class code relation record.
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
 *   07-23-2001    Indrajit Sen        o Created.
 *
 */

PROCEDURE update_class_code_relation(
    p_init_msg_list           IN      VARCHAR2 := FND_API.G_FALSE,
    p_class_code_relation_rec IN      CLASS_CODE_RELATION_REC_TYPE,
    p_object_version_number   IN OUT NOCOPY  NUMBER,
    x_return_status           OUT NOCOPY     VARCHAR2,
    x_msg_count               OUT NOCOPY     NUMBER,
    x_msg_data                OUT NOCOPY     VARCHAR2
) IS

    l_class_code_rel_rec              CLASS_CODE_RELATION_REC_TYPE:= p_class_code_relation_rec;
    l_old_class_code_rel_rec          CLASS_CODE_RELATION_REC_TYPE;

BEGIN

    -- standard start of API savepoint
    SAVEPOINT update_class_code_relation;

    -- initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Get old records. Will be used by business event system.
    get_class_code_relation_rec (
        p_class_category                     => l_class_code_rel_rec.class_category,
        p_class_code                         => l_class_code_rel_rec.class_code,
        p_sub_class_code                     => l_class_code_rel_rec.sub_class_code,
        p_start_date_active                  => l_class_code_rel_rec.start_date_active,
        x_class_code_relation_rec            => l_old_class_code_rel_rec,
        x_return_status                      => x_return_status,
        x_msg_count                          => x_msg_count,
        x_msg_data                           => x_msg_data );

    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- call to business logic.
    do_update_class_code_relation(
                                  l_class_code_rel_rec,
                                  p_object_version_number,
                                  x_return_status);

   IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN

    -- Invoke business event system.
     --Bug 4743141.
     IF(HZ_UTILITY_V2PUB.G_EXECUTE_API_CALLOUTS in ('Y', 'EVENTS_ENABLED')) THEN
        HZ_BUSINESS_EVENT_V2PVT.update_class_code_rel_event (
        l_class_code_rel_rec,
        l_old_class_code_rel_rec );
     END IF;

   END IF;

    -- standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO update_class_code_relation;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO update_class_code_relation;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

    WHEN OTHERS THEN
        ROLLBACK TO update_class_code_relation;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(
                               p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);

END update_class_code_relation;

/**
 * PROCEDURE create_code_assignment
 *
 * DESCRIPTION
 *     Creates code assignment.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *     HZ_BUSINESS_EVENT_V2PVT.create_code_assignment_event
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_code_assignement_rec         Code assignment record.
 *   IN/OUT:
 *   OUT:
 *     x_return_status                Return status after the call. The status can
 *                                    be FND_API.G_RET_STS_SUCCESS (success),
 *                                    FND_API.G_RET_STS_ERROR (error),
 *                                    FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
 *     x_msg_count                    Number of messages in message stack.
 *     x_msg_data                     Message text if x_msg_count is 1.
 *     x_code_assignment_id           Code assignment ID.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   07-23-2001    Indrajit Sen        o Created.
 *   01-05-2005    Rajib Ranjan Borah  o SSM SST Integration and Extension.
 *                                       New column ACTUAL_CONTENT_SOURCE is
 *                                       added in HZ_CODE_ASSIGNMENTS.
 *                                       Called HZ_MIXNM_UTILITY.AssignDataSourceDuringCreation
 *                                       to check for user creation privilege and
 *                                       to ensure that proper values are set to
 *                                       content_source_type / actual_content_source.


 */

PROCEDURE create_code_assignment(
    p_init_msg_list             IN      VARCHAR2 := FND_API.G_FALSE,
    p_code_assignment_rec       IN      CODE_ASSIGNMENT_REC_TYPE,
    x_return_status             OUT NOCOPY     VARCHAR2,
    x_msg_count                 OUT NOCOPY     NUMBER,
    x_msg_data                  OUT NOCOPY     VARCHAR2,
    x_code_assignment_id        OUT NOCOPY     NUMBER
)
IS

    l_code_assignment_rec               CODE_ASSIGNMENT_REC_TYPE:= p_code_assignment_rec;
    l_entity_attr_id                    NUMBER;
    l_is_datasource_selected            VARCHAR2(1);

BEGIN

    -- standard start of API savepoint
    SAVEPOINT create_code_assignment;

    -- initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- SSM SST Integration and Extension
    HZ_MIXNM_UTILITY.AssignDataSourceDuringCreation (
        p_entity_name             => 'HZ_CODE_ASSIGNMENTS',
        p_entity_attr_id          => l_entity_attr_id ,
        p_mixnmatch_enabled       => NULL,
        p_selected_datasources    => NULL,
        p_content_source_type     => l_code_assignment_rec.content_source_type,
        p_actual_content_source   => l_code_assignment_rec.actual_content_source,
        x_is_datasource_selected  => l_is_datasource_selected,
        x_return_status           => x_return_status,
        p_api_version             => 'V2'
    );

    -- call to business logic.
    do_create_code_assignment(
                              l_code_assignment_rec,
                              x_return_status);

    -- assign out NOCOPY param
    x_code_assignment_id := l_code_assignment_rec.code_assignment_id;

   IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
     IF(HZ_UTILITY_V2PUB.G_EXECUTE_API_CALLOUTS in ('Y', 'EVENTS_ENABLED')) THEN
       -- Invoke business event system.
       HZ_BUSINESS_EVENT_V2PVT.create_code_assignment_event (
         l_code_assignment_rec );
     END IF;

     IF(HZ_UTILITY_V2PUB.G_EXECUTE_API_CALLOUTS in ('EVENTS_ENABLED', 'BO_EVENTS_ENABLED')) THEN
       HZ_POPULATE_BOT_PKG.pop_hz_code_assignments(
         p_operation          => 'I',
         p_code_assignment_id => x_code_assignment_id);
     END IF;
   END IF;

    -- standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO create_code_assignment;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO create_code_assignment;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

    WHEN OTHERS THEN
        ROLLBACK TO create_code_assignment;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);
END create_code_assignment;

/**
 * PROCEDURE update_code_assignment
 *
 * DESCRIPTION
 *     Updates code assignment.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *     HZ_BUSINESS_EVENT_V2PVT.update_code_assignment_event
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_code_assignment_rec          Code assignment record.
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
 *   07-23-2001    Indrajit Sen        o Created.
 *   29-MAY-2003   Jyoti Pandey        o Make the API protected by Data security Bug 2963010
 */

PROCEDURE update_code_assignment (
    p_init_msg_list                IN    VARCHAR2:=FND_API.G_FALSE,
    p_code_assignment_rec          IN    CODE_ASSIGNMENT_REC_TYPE,
    p_object_version_number    IN OUT NOCOPY    NUMBER,
    x_return_status               OUT NOCOPY    VARCHAR2,
    x_msg_count                   OUT NOCOPY    NUMBER,
    x_msg_data                    OUT NOCOPY    VARCHAR2
) IS

    l_code_assignment_rec                CODE_ASSIGNMENT_REC_TYPE := p_code_assignment_rec;
    l_old_code_assignment_rec            CODE_ASSIGNMENT_REC_TYPE;

    dss_return_status VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
    dss_msg_count     NUMBER := 0;
    dss_msg_data      VARCHAR2(2000):= null;
    l_test_security   VARCHAR2(1):= 'F';

BEGIN

    -- standard start of API savepoint
    SAVEPOINT update_code_assignment;

    -- initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Get old records. Will be used by business event system.
    get_code_assignment_rec (
        p_code_assignment_id                 => l_code_assignment_rec.code_assignment_id,
        x_code_assignment_rec                => l_old_code_assignment_rec,
        x_return_status                      => x_return_status,
        x_msg_count                          => x_msg_count,
        x_msg_data                           => x_msg_data );

    -- Bug:2154581
    IF  x_return_status = FND_API.G_RET_STS_SUCCESS THEN
        IF l_code_assignment_rec.start_date_active IS NULL OR
           l_code_assignment_rec.start_date_active =  FND_API.G_MISS_DATE THEN
                l_code_assignment_rec.start_date_active := l_old_code_assignment_rec.start_date_active;
        END IF;
    END IF;
    --
    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    ---Bug 2963010 make table HZ_CODE_ASSIGNMENTS protected by Data Security
    ---Check if the DSS security is granted to the user
    --
    -- Bug 3818648: do dss check in party context only. check dss
    -- profile before call test_instance.
    --
    IF NVL(fnd_profile.value('HZ_DSS_ENABLED'), 'N') = 'Y' AND
       l_old_code_assignment_rec.owner_table_name = 'HZ_PARTIES'
    THEN
      l_test_security :=
        hz_dss_util_pub.test_instance(
               p_operation_code     => 'UPDATE',
               p_db_object_name     => 'HZ_CODE_ASSIGNMENTS',
               p_instance_pk1_value => l_code_assignment_rec.code_assignment_id,
               p_user_name          => fnd_global.user_name,
               x_return_status      => dss_return_status,
               x_msg_count          => dss_msg_count,
               x_msg_data           => dss_msg_data);

      if dss_return_status <> fnd_api.g_ret_sts_success THEN
        RAISE FND_API.G_EXC_ERROR;
      end if;

      if (l_test_security <> 'T' OR l_test_security <> FND_API.G_TRUE) then
        --
        -- Bug 3835601: replaced the dss message with a more user friendly message
        --
        FND_MESSAGE.SET_NAME('AR', 'HZ_DSS_NO_UPDATE_PRIVILEGE');
        FND_MESSAGE.SET_TOKEN('ENTITY_NAME',
                              hz_dss_util_pub.get_display_name('HZ_CODE_ASSIGNMENTS', null));        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
      end if;
    END IF;

    --Call to business logic.
    do_update_code_assignment(
                              l_code_assignment_rec,
                              p_object_version_number,
                              x_return_status);

   IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
     IF(HZ_UTILITY_V2PUB.G_EXECUTE_API_CALLOUTS in ('Y', 'EVENTS_ENABLED')) THEN
       -- Invoke business event system.
       HZ_BUSINESS_EVENT_V2PVT.update_code_assignment_event (
         l_code_assignment_rec,
         l_old_code_assignment_rec );
     END IF;

     IF(HZ_UTILITY_V2PUB.G_EXECUTE_API_CALLOUTS in ('EVENTS_ENABLED', 'BO_EVENTS_ENABLED')) THEN
       HZ_POPULATE_BOT_PKG.pop_hz_code_assignments(
         p_operation          => 'U',
         p_code_assignment_id => l_code_assignment_rec.code_assignment_id);
     END IF;
   END IF;

   HZ_UTILITY_V2PUB.G_UPDATE_ACS := NULL;
    -- standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO update_code_assignment;
        HZ_UTILITY_V2PUB.G_UPDATE_ACS := NULL;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO update_code_assignment;
        HZ_UTILITY_V2PUB.G_UPDATE_ACS := NULL;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

    WHEN OTHERS THEN
        ROLLBACK TO update_code_assignment;
        HZ_UTILITY_V2PUB.G_UPDATE_ACS := NULL;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

END update_code_assignment;

/**
 * PROCEDURE set_primary_code_assignment
 *
 * DESCRIPTION
 *     Sets primary code assignment.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_owner_table_name             Owner table name.
 *     p_owner_table_id               Owner table ID.
 *     p_class_category               Class category.
 *     p_class_code                   Class code.
 *     p_content_source_type          Contact source type.
 *     p_created_by_module            Created_by_module
 *   IN/OUT:
 *   OUT:
 *     x_code_assignment_id           Code assignment ID.
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
 *   07-23-2001    Indrajit Sen        o Created.
 *   12-Sep-2008   Sudhir Gokavarapu   o Modified Bug 6982657.
 *
 */

PROCEDURE set_primary_code_assignment(
    p_init_msg_list        IN      VARCHAR2 := FND_API.G_FALSE,
    p_owner_table_name     IN      VARCHAR2,
    p_owner_table_id       IN      NUMBER,
    p_class_category       IN      VARCHAR2,
    p_class_code           IN      VARCHAR2,
    p_content_source_type  IN      VARCHAR2,
    p_created_by_module    IN      VARCHAR2, /* Bug 3856348 */
    x_code_assignment_id   OUT NOCOPY     NUMBER,
    x_return_status        OUT NOCOPY     VARCHAR2,
    x_msg_count            OUT NOCOPY     NUMBER,
    x_msg_data             OUT NOCOPY     VARCHAR2
) IS

    l_count                        NUMBER;
    l_rec                          HZ_CODE_ASSIGNMENTS%ROWTYPE;
    l_code_assign_rec              CODE_ASSIGNMENT_REC_TYPE;

    CURSOR c_code_assign(
          p_owner_table_name     IN    VARCHAR2
        , p_owner_table_id       IN    NUMBER
        , p_class_category       IN    VARCHAR2
        , p_content_source_type  IN    VARCHAR2
        )
    IS SELECT * FROM HZ_CODE_ASSIGNMENTS
    WHERE
        owner_table_name = p_owner_table_name AND
        owner_table_id = p_owner_table_id AND
        class_category = p_class_category AND
        actual_content_source = NVL(p_content_source_type, HZ_PARTY_V2PUB.G_MISS_CONTENT_SOURCE_TYPE) AND
        (end_date_active is null
         OR sysdate between start_date_active and end_date_active);

    --FOR UPDATE OF end_date_active;

BEGIN
    --Standard start of API savepoint
    SAVEPOINT set_primary_code_assign;

    --Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    --Initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- the assignment exists?
    l_count := 0;
    OPEN c_code_assign(
          p_owner_table_name
        , p_owner_table_id
        , p_class_category
        , p_content_source_type
        );
    LOOP
        FETCH c_code_assign INTO l_rec;
        EXIT WHEN c_code_assign%NOTFOUND;
        IF (l_rec.PRIMARY_FLAG = 'Y') AND
            (l_rec.class_code = p_class_code)
            AND
            (
                (l_rec.end_date_active IS NULL) OR
                (l_rec.end_date_active > SYSDATE)
            )
        THEN
            -- AN ACTIVE ONE EXISTS
            l_count := l_count + 1;
            x_code_assignment_id := l_rec.code_assignment_id;
            EXIT;
        END IF;

        IF (l_rec.PRIMARY_FLAG = 'Y' AND
            l_rec.class_code <> p_class_code)
        THEN
            -- terminate original primary assignment
            UPDATE HZ_CODE_ASSIGNMENTS SET
                --end_date_active = l_rec.start_date_active

-- Bug 3614582 : end date with sysdate - (1 second)
                end_date_active = SYSDATE - 1/(24*60*60)
            WHERE code_assignment_id = l_rec.code_assignment_id;
            --WHERE CURRENT OF c_code_assign;

            -- Bug 3876180
            IF(p_class_code=fnd_api.g_miss_char)
            THEN
            l_count := l_count + 1;
            x_code_assignment_id := l_rec.code_assignment_id;
            END IF;
        END IF;

        IF (l_rec.PRIMARY_FLAG = 'N' AND
            l_rec.class_code = p_class_code)
        THEN
            -- terminate original non-primary assignment
            UPDATE HZ_CODE_ASSIGNMENTS SET
                --end_date_active = l_rec.start_date_active
-- Bug 3614582 : end date with sysdate - (1 second)
                end_date_active = SYSDATE - 1/(24*60*60)
            WHERE code_assignment_id = l_rec.code_assignment_id;
            --WHERE CURRENT OF c_code_assign;
        END IF;
    END LOOP;
    CLOSE c_code_assign;
-- Bug 6982657
    IF (l_count = 0) AND (NVL(p_class_code,fnd_api.g_miss_char) <> fnd_api.g_miss_char)
    THEN
        l_code_assign_rec.owner_table_name := p_owner_table_name;
        l_code_assign_rec.owner_table_id := p_owner_table_id;
        l_code_assign_rec.class_category := p_class_category;
        l_code_assign_rec.class_code := p_class_code;
        l_code_assign_rec.primary_flag := 'Y';
        l_code_assign_rec.actual_content_source := p_content_source_type;
        l_code_assign_rec.start_date_active := SYSDATE;
        l_code_assign_rec.end_date_active := NULL;
        -- Bug 3856348
        l_code_assign_rec.created_by_module := p_created_by_module;

        do_create_code_assignment(
            l_code_assign_rec,
            x_return_status);
        -- assign out NOCOPY param
        x_code_assignment_id := l_code_assign_rec.code_assignment_id;
    ELSE
        -- already created, skip the call
        NULL;
    END IF;

    --Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO set_primary_code_assign;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO set_primary_code_assign;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

    WHEN OTHERS THEN
        ROLLBACK TO set_primary_code_assign;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);
END;

/**
 * PROCEDURE create_class_category_use
 *
 * DESCRIPTION
 *     Creates class category use.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *     HZ_BUSINESS_EVENT_V2PVT.create_class_cat_use_event
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_class_category_use_rec       Class category use record.
 *   IN/OUT:
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
 *   07-23-2001    Indrajit Sen        o Created.
 *
 */

PROCEDURE create_class_category_use(
    p_init_msg_list           IN      VARCHAR2 := FND_API.G_FALSE,
    p_class_category_use_rec  IN      CLASS_CATEGORY_USE_REC_TYPE,
    x_return_status           OUT NOCOPY     VARCHAR2,
    x_msg_count               OUT NOCOPY     NUMBER,
    x_msg_data                OUT NOCOPY     VARCHAR2
) IS

    l_class_category_use_rec          CLASS_CATEGORY_USE_REC_TYPE := p_class_category_use_rec;

BEGIN

    -- standard save point
    SAVEPOINT create_class_category_use;

    -- initialize message list if p_init_msg_list is TRUE
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.INITIALIZE;
    END IF;

    -- initialize API return status to SUCCESS
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- call to business logic
    do_create_class_category_use(
                                 l_class_category_use_rec,
                                 x_return_status);

   IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN

    -- Invoke business event system.
     --Bug 4743141.
     IF(HZ_UTILITY_V2PUB.G_EXECUTE_API_CALLOUTS in ('Y', 'EVENTS_ENABLED')) THEN
        HZ_BUSINESS_EVENT_V2PVT.create_class_cat_use_event (
        l_class_category_use_rec );
     END IF;

   END IF;

    -- standard Call to get message count and if count is 1 get message info.
    FND_MSG_PUB.count_and_get(
                              p_encoded => fnd_api.g_false,
                              p_count   => x_msg_count,
                              p_data    => x_msg_data );

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO create_class_category_use;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                  p_encoded => FND_API.G_FALSE,
                                  p_count   => x_msg_count,
                                  p_data    => x_msg_data );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO create_class_category_use;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                  p_encoded => FND_API.G_FALSE,
                                  p_count   => x_msg_count,
                                  p_data    => x_msg_data );

    WHEN OTHERS THEN
        ROLLBACK TO create_class_category_use;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MESSAGE.Set_Name('AR','HZ_API_OTHERS_EXCEP');
        FND_MESSAGE.Set_Token('ERROR',SQLERRM);
        FND_MSG_PUB.Count_And_Get(
                                  p_encoded => FND_API.G_FALSE,
                                  p_count   => x_msg_count,
                                  p_data    => x_msg_data );

END create_class_category_use;

/**
 * PROCEDURE update_class_category_use
 *
 * DESCRIPTION
 *     Updates class category use.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *     HZ_BUSINESS_EVENT_V2PVT.update_class_cat_use_event
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_class_category_use_rec       Class category use record.
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
 *   07-23-2001    Indrajit Sen        o Created.
 *
 */

PROCEDURE update_class_category_use(
    p_init_msg_list          IN      VARCHAR2:=FND_API.G_FALSE,
    p_class_category_use_rec IN      CLASS_CATEGORY_USE_REC_TYPE,
    p_object_version_number  IN OUT NOCOPY  NUMBER,
    x_return_status          OUT NOCOPY     VARCHAR2,
    x_msg_count              OUT NOCOPY     NUMBER,
    x_msg_data               OUT NOCOPY     VARCHAR2
) IS

    l_class_cat_use_rec              CLASS_CATEGORY_USE_REC_TYPE := p_class_category_use_rec;
    l_old_class_cat_use_rec          CLASS_CATEGORY_USE_REC_TYPE;

BEGIN

    -- standard start of API savepoint
    SAVEPOINT update_class_category_use;

    -- initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Get old records. Will be used by business event system.
    get_class_category_use_rec (
        p_class_category                     => l_class_cat_use_rec.class_category,
        p_owner_table                        => l_class_cat_use_rec.owner_table,
        x_class_category_use_rec             => l_old_class_cat_use_rec,
        x_return_status                      => x_return_status,
        x_msg_count                          => x_msg_count,
        x_msg_data                           => x_msg_data );

    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- call to business logic.
    do_update_class_category_use(
                                 l_class_cat_use_rec,
                                 p_object_version_number,
                                 x_return_status);

   IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN

    -- Invoke business event system.
     --Bug 4743141.
     IF(HZ_UTILITY_V2PUB.G_EXECUTE_API_CALLOUTS in ('Y', 'EVENTS_ENABLED')) THEN
        HZ_BUSINESS_EVENT_V2PVT.update_class_cat_use_event (
        l_class_cat_use_rec,
        l_old_class_cat_use_rec );
     END IF;

   END IF;

    -- standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO update_class_category_use;
        x_return_status := FND_API.G_RET_STS_ERROR;

        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO update_class_category_use;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data );

    WHEN OTHERS THEN
        ROLLBACK TO update_class_category_use;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_OTHERS_EXCEP' );
        FND_MESSAGE.SET_TOKEN( 'ERROR' ,SQLERRM );
        FND_MSG_PUB.ADD;

        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data );

END update_class_category_use;

/*===========================================================================+
 | PROCEDURE
 |              get_current_class_category
 |
 | DESCRIPTION
 |              Gets class category of current record.
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    p_class_category
 |              OUT:
 |                    x_class_cat_rec
 |          IN/ OUT:
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |
 +===========================================================================*/

PROCEDURE get_current_class_category(
        p_class_category        IN      VARCHAR2,
        x_class_cat_rec         OUT     NOCOPY CLASS_CATEGORY_REC_TYPE
) IS
BEGIN
   SELECT
     class_category,
     allow_multi_assign_flag,
     allow_multi_parent_flag,
     allow_leaf_node_only_flag
   INTO
     x_class_cat_rec.class_category,
     x_class_cat_rec.allow_multi_assign_flag,
     x_class_cat_rec.allow_multi_parent_flag,
     x_class_cat_rec.allow_leaf_node_only_flag
   FROM hz_class_categories
   WHERE class_category = p_class_category;
END;


/*===========================================================================+
 | PROCEDURE
 |              get_curr_class_code_rel
 |
 | DESCRIPTION
 |              Gets class code relation of current record.
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    p_class_code_rel_rec
 |              OUT:
 |                    x_class_code_rel_rec
 |          IN/ OUT:
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |
 +===========================================================================*/

PROCEDURE get_curr_class_code_rel(
        p_class_code_rel_rec         IN     CLASS_CODE_RELATION_REC_TYPE,
        x_class_code_rel_rec         OUT     NOCOPY CLASS_CODE_RELATION_REC_TYPE
) IS
BEGIN
    SELECT
        class_category,
        class_code,
        sub_class_code,
        start_date_active,
        end_date_active
    INTO
        x_class_code_rel_rec.class_category,
        x_class_code_rel_rec.class_code,
        x_class_code_rel_rec.sub_class_code,
        x_class_code_rel_rec.start_date_active,
        x_class_code_rel_rec.end_date_active
     FROM hz_class_code_relations
    WHERE
        class_category = p_class_code_rel_rec.class_category AND
        class_code = p_class_code_rel_rec.class_code AND
        sub_class_code = p_class_code_rel_rec.sub_class_code AND
        start_date_active = p_class_code_rel_rec.start_date_active;
END;




--HYU

/*===========================================================================+
 | PROCEDURE
 |              get_curr_class_category_use
 | DESCRIPTION
 |              Gets class category uses of current record.
 | SCOPE - PRIVATE
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 | ARGUMENTS  : IN:
 |                    p_class_category_use_rec
 |              OUT:
 |                    x_class_category_use_rec
 |          IN/ OUT:
 | RETURNS    : NONE
 | NOTES
 | MODIFICATION HISTORY
 |    Herve Yu 19-JAN-2001 Created
 +===========================================================================*/

PROCEDURE get_curr_class_category_use
(p_class_category_use_rec    IN     CLASS_CATEGORY_USE_REC_TYPE,
 x_class_category_use_rec    OUT    NOCOPY CLASS_CATEGORY_USE_REC_TYPE)
IS
BEGIN
    SELECT class_category,
           owner_table,
           additional_where_clause
    INTO x_class_category_use_rec.class_category,
           x_class_category_use_rec.owner_table,
           x_class_category_use_rec.additional_where_clause
     FROM hz_class_category_uses
     WHERE class_category = p_class_category_use_rec.class_category
       AND owner_table    = p_class_category_use_rec.owner_table;
END get_curr_class_category_use;


/*===========================================================================+
 | PROCEDURE
 |              get_current_code_assignmen
 | DESCRIPTION
 |              Gets code assignment of current record.
 | SCOPE - PRIVATE
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 | ARGUMENTS  : IN:
 |                    p_code_assignment_id
 |              OUT:
 |                    x_code_assignment_rec
 |          IN/ OUT:
 | RETURNS    : NONE
 | NOTES
 | MODIFICATION HISTORY
 +===========================================================================*/

PROCEDURE get_current_code_assignment(
        p_code_assignment_id        IN      NUMBER,
        x_code_assignment_rec         OUT     NOCOPY CODE_ASSIGNMENT_REC_TYPE
) IS
BEGIN
    SELECT
  code_assignment_id,
  owner_table_name,
  owner_table_id,
  class_category,
  class_code,
  primary_flag,
  content_source_type,
  start_date_active,
  end_date_active,
  rank

    INTO
  x_code_assignment_rec.code_assignment_id ,
  x_code_assignment_rec.owner_table_name,
  x_code_assignment_rec.owner_table_id,
  x_code_assignment_rec.class_category,
  x_code_assignment_rec.class_code,
  x_code_assignment_rec.primary_flag,
  x_code_assignment_rec.content_source_type,
  x_code_assignment_rec.start_date_active,
  x_code_assignment_rec.end_date_active,
  x_code_assignment_rec.rank
     FROM hz_code_assignments
    WHERE code_assignment_id = p_code_assignment_id;
END;

/**
 * PROCEDURE get_class_category_rec
 *
 * DESCRIPTION
 *     Gets class category record.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *     HZ_CLASS_CATEGORIES_PKG.Select_Row
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_class_category               Class category name.
 *   IN/OUT:
 *   OUT:
 *     x_class_category_rec           Returned class category record.
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
 *   07-23-2001    Indrajit Sen        o Created.
 *
 */

PROCEDURE get_class_category_rec (
    p_init_msg_list                         IN     VARCHAR2 := FND_API.G_FALSE,
    p_class_category                        IN     VARCHAR2,
    x_class_category_rec                    OUT    NOCOPY CLASS_CATEGORY_REC_TYPE,
    x_return_status                         OUT NOCOPY    VARCHAR2,
    x_msg_count                             OUT NOCOPY    NUMBER,
    x_msg_data                              OUT NOCOPY    VARCHAR2
) IS

BEGIN

    --Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    --Initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --Check whether primary key has been passed in.
    IF p_class_category IS NULL OR
       p_class_category = FND_API.G_MISS_CHAR THEN
        FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_MISSING_COLUMN' );
        FND_MESSAGE.SET_TOKEN( 'COLUMN', 'class_category' );
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    x_class_category_rec.class_category := p_class_category;

    HZ_CLASS_CATEGORIES_PKG.Select_Row (
        X_CLASS_CATEGORY                        => x_class_category_rec.class_category,
        X_ALLOW_MULTI_PARENT_FLAG               => x_class_category_rec.allow_multi_parent_flag,
        X_ALLOW_MULTI_ASSIGN_FLAG               => x_class_category_rec.allow_multi_assign_flag,
        X_ALLOW_LEAF_NODE_ONLY_FLAG             => x_class_category_rec.allow_leaf_node_only_flag,
        X_CREATED_BY_MODULE                     => x_class_category_rec.created_by_module,
        X_APPLICATION_ID                        => x_class_category_rec.application_id,
        X_DELIMITER                             => x_class_category_rec.delimiter
    );

    --Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data );

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;

        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data );

    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_OTHERS_EXCEP' );
        FND_MESSAGE.SET_TOKEN( 'ERROR' ,SQLERRM );
        FND_MSG_PUB.ADD;

        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data );

END get_class_category_rec;

/**
 * PROCEDURE get_class_category_use_rec
 *
 * DESCRIPTION
 *     Gets class category use record.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *     HZ_CLASS_CATEGORY_USES_PKG.Select_Row
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_class_category               Class category name.
 *     p_owner_table                  Owner table name.
 *   IN/OUT:
 *   OUT:
 *     x_class_category_use_rec       Returned class category use record.
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
 *   07-23-2001    Indrajit Sen        o Created.
 *
 */

PROCEDURE get_class_category_use_rec(
    p_init_msg_list                         IN     VARCHAR2 := FND_API.G_FALSE,
    p_class_category                        IN     VARCHAR2,
    p_owner_table                           IN     VARCHAR2,
    x_class_category_use_rec                OUT    NOCOPY CLASS_CATEGORY_USE_REC_TYPE,
    x_return_status                         OUT NOCOPY    VARCHAR2,
    x_msg_count                             OUT NOCOPY    NUMBER,
    x_msg_data                              OUT NOCOPY    VARCHAR2
) IS

BEGIN

    --Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    --Initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --Check whether primary key has been passed in.
    IF p_class_category IS NULL OR
       p_class_category = FND_API.G_MISS_CHAR THEN
        FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_MISSING_COLUMN' );
        FND_MESSAGE.SET_TOKEN( 'COLUMN', 'class_category' );
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF p_owner_table IS NULL OR
       p_owner_table = FND_API.G_MISS_CHAR THEN
        FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_MISSING_COLUMN' );
        FND_MESSAGE.SET_TOKEN( 'COLUMN', 'owner_table' );
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    x_class_category_use_rec.class_category := p_class_category;
    x_class_category_use_rec.owner_table := p_owner_table;

    HZ_CLASS_CATEGORY_USES_PKG.Select_Row (
        X_CLASS_CATEGORY                        => x_class_category_use_rec.class_category,
        X_OWNER_TABLE                           => x_class_category_use_rec.owner_table,
        X_COLUMN_NAME                           => x_class_category_use_rec.column_name,
        X_ADDITIONAL_WHERE_CLAUSE               => x_class_category_use_rec.additional_where_clause,
        X_CREATED_BY_MODULE                     => x_class_category_use_rec.created_by_module,
        X_APPLICATION_ID                        => x_class_category_use_rec.application_id
    );

    --Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data );

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;

        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data );

    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_OTHERS_EXCEP' );
        FND_MESSAGE.SET_TOKEN( 'ERROR' ,SQLERRM );
        FND_MSG_PUB.ADD;

        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data );

END get_class_category_use_rec;

/**
 * PROCEDURE get_class_code_relation_rec
 *
 * DESCRIPTION
 *     Gets class code relation record.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *     HZ_CLASS_CODE_RELATIONS_PKG.Select_Row
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_class_category               Class category name.
 *     p_class_code                   Class code.
 *     p_sub_class_code               Sub class code.
 *     p_start_date_active            Start date active.
 *   IN/OUT:
 *   OUT:
 *     x_class_code_relation_rec      Returned class code relation record.
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
 *   07-23-2001    Indrajit Sen        o Created.
 *
 */

PROCEDURE get_class_code_relation_rec(
    p_init_msg_list                         IN     VARCHAR2 := FND_API.G_FALSE,
    p_class_category                        IN     VARCHAR2,
    p_class_code                            IN     VARCHAR2,
    p_sub_class_code                        IN     VARCHAR2,
    p_start_date_active                     IN     DATE,
    x_class_code_relation_rec               OUT    NOCOPY CLASS_CODE_RELATION_REC_TYPE,
    x_return_status                         OUT NOCOPY    VARCHAR2,
    x_msg_count                             OUT NOCOPY    NUMBER,
    x_msg_data                              OUT NOCOPY    VARCHAR2
) IS

BEGIN

    --Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    --Initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --Check whether primary key has been passed in.
    IF p_class_category IS NULL OR
       p_class_category = FND_API.G_MISS_CHAR THEN
        FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_MISSING_COLUMN' );
        FND_MESSAGE.SET_TOKEN( 'COLUMN', 'class_category' );
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF p_class_code IS NULL OR
       p_class_code = FND_API.G_MISS_CHAR THEN
        FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_MISSING_COLUMN' );
        FND_MESSAGE.SET_TOKEN( 'COLUMN', 'class_code' );
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF p_sub_class_code IS NULL OR
       p_sub_class_code = FND_API.G_MISS_CHAR THEN
        FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_MISSING_COLUMN' );
        FND_MESSAGE.SET_TOKEN( 'COLUMN', 'sub_class_code' );
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF p_start_date_active IS NULL OR
       p_start_date_active = FND_API.G_MISS_DATE THEN
        FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_MISSING_COLUMN' );
        FND_MESSAGE.SET_TOKEN( 'COLUMN', 'start_date_active' );
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    x_class_code_relation_rec.class_category := p_class_category;
    x_class_code_relation_rec.class_code := p_class_code;
    x_class_code_relation_rec.sub_class_code := p_sub_class_code;
    x_class_code_relation_rec.start_date_active := p_start_date_active;

    HZ_CLASS_CODE_RELATIONS_PKG.Select_Row (
        X_CLASS_CATEGORY                        => x_class_code_relation_rec.class_category,
        X_CLASS_CODE                            => x_class_code_relation_rec.class_code,
        X_SUB_CLASS_CODE                        => x_class_code_relation_rec.sub_class_code,
        X_START_DATE_ACTIVE                     => x_class_code_relation_rec.start_date_active,
        X_END_DATE_ACTIVE                       => x_class_code_relation_rec.end_date_active,
        X_CREATED_BY_MODULE                     => x_class_code_relation_rec.created_by_module,
        X_APPLICATION_ID                        => x_class_code_relation_rec.application_id
    );

    --Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data );

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;

        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data );

    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_OTHERS_EXCEP' );
        FND_MESSAGE.SET_TOKEN( 'ERROR' ,SQLERRM );
        FND_MSG_PUB.ADD;

        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data );

END get_class_code_relation_rec;

/**
 * PROCEDURE get_code_assignment_rec
 *
 * DESCRIPTION
 *     Gets code assignment record.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *     HZ_CODE_ASSIGNMENTS_PKG.Select_Row
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_code_assignment_id           Code assignment ID.
 *   IN/OUT:
 *   OUT:
 *     x_code_assignment_rec          Returned code assignment record.
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
 *   07-23-2001    Indrajit Sen         o Created.
 *   01-05-2005    Rajib Ranjan Borah   o SSM SST Integration and Extension.
 *                                        Added actual_content_source in call to select_row
 *
 *
 */

PROCEDURE get_code_assignment_rec (
    p_init_msg_list                         IN     VARCHAR2 := FND_API.G_FALSE,
    p_code_assignment_id                    IN     NUMBER,
    x_code_assignment_rec                   OUT    NOCOPY CODE_ASSIGNMENT_REC_TYPE,
    x_return_status                         OUT NOCOPY    VARCHAR2,
    x_msg_count                             OUT NOCOPY    NUMBER,
    x_msg_data                              OUT NOCOPY    VARCHAR2
) IS

BEGIN

    --Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    --Initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --Check whether primary key has been passed in.
    IF p_code_assignment_id IS NULL OR
       p_code_assignment_id = FND_API.G_MISS_NUM THEN
        FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_MISSING_COLUMN' );
        FND_MESSAGE.SET_TOKEN( 'COLUMN', 'code_assignment_id' );
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    x_code_assignment_rec.code_assignment_id := p_code_assignment_id;

    HZ_CODE_ASSIGNMENTS_PKG.Select_Row (
        X_CODE_ASSIGNMENT_ID                    => x_code_assignment_rec.code_assignment_id,
        X_OWNER_TABLE_NAME                      => x_code_assignment_rec.owner_table_name,
        X_OWNER_TABLE_ID                        => x_code_assignment_rec.owner_table_id,
        X_OWNER_TABLE_KEY_1                     => x_code_assignment_rec.owner_table_key_1,
        X_OWNER_TABLE_KEY_2                     => x_code_assignment_rec.owner_table_key_2,
        X_OWNER_TABLE_KEY_3                     => x_code_assignment_rec.owner_table_key_3,
        X_OWNER_TABLE_KEY_4                     => x_code_assignment_rec.owner_table_key_4,
        X_OWNER_TABLE_KEY_5                     => x_code_assignment_rec.owner_table_key_5,
        X_CLASS_CATEGORY                        => x_code_assignment_rec.class_category,
        X_CLASS_CODE                            => x_code_assignment_rec.class_code,
        X_PRIMARY_FLAG                          => x_code_assignment_rec.primary_flag,
        X_CONTENT_SOURCE_TYPE                   => x_code_assignment_rec.content_source_type,
        X_START_DATE_ACTIVE                     => x_code_assignment_rec.start_date_active,
        X_END_DATE_ACTIVE                       => x_code_assignment_rec.end_date_active,
        X_STATUS                                => x_code_assignment_rec.status,
        X_CREATED_BY_MODULE                     => x_code_assignment_rec.created_by_module,
        X_RANK                                  => X_code_assignment_rec.rank,
        X_APPLICATION_ID                        => x_code_assignment_rec.application_id,
        -- SSM SST Integration and Extension
        X_ACTUAL_CONTENT_SOURCE                 => x_code_assignment_rec.actual_content_source

    );

    --Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data );

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;

        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data );

    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_OTHERS_EXCEP' );
        FND_MESSAGE.SET_TOKEN( 'ERROR' ,SQLERRM );
        FND_MSG_PUB.ADD;

        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data );

END get_code_assignment_rec;


/**
 * FUNCTION is_valid_category
 *
 * DESCRIPTION
 *     ERS No: 2074686.  The fucntion checks if a given id can be assigned to a class_category and
 *     owner_table.  It returns 'T' if party_id can be assigned or 'F' else.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_owner_table                  Owner table name.
 *     p_class_category               Name of class category
 *     p_id                           id (party_id or a party_relationship_id)
 *   IN/OUT:
 *   OUT:
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   02-14-2002    Anupam Bordia        o Created.
 *   02-18-2002    Anupam Bordia        o Altered signature to remove OUT NOCOPY parameters so that the
 *                                        function can be used within a SQL.
 *   03-27-2002    Anupam Bordia        o Bug#2284235 Parses additional_where_clause conditionally.
 *   02-03-2003    Sreedhar Mohan       o Rewritten the function as part of new HZ.K changes.
 *   03-17-2003    Sreedhar Mohan       o Bug 2829644: Changed the cursor query to compare upper
 *                                        on both sides of the comparison.
 */

FUNCTION IS_VALID_CATEGORY(
   p_owner_table      VARCHAR2,
   p_class_category   VARCHAR2,
   p_id               NUMBER   := FND_API.G_MISS_NUM,
   p_key_1            VARCHAR2 := FND_API.G_MISS_CHAR,
   p_key_2            VARCHAR2 := FND_API.G_MISS_CHAR,
   p_key_3            VARCHAR2 := FND_API.G_MISS_CHAR,
   p_key_4            VARCHAR2 := FND_API.G_MISS_CHAR,
   p_key_5            VARCHAR2 := FND_API.G_MISS_CHAR
)
RETURN VARCHAR2
IS
   --Bug 2824942: Modified the cursor to verify additional_where_clause from hz_class_category uses
   CURSOR get_category_uses_info is
       SELECT h.owner_table,
              upper(trim(h.additional_where_clause)),
              f.pk1_column_name,
              f.pk2_column_name,
              f.pk3_column_name,
              f.pk4_column_name,
              f.pk5_column_name
       FROM   hz_class_category_uses h,
              fnd_objects f
       WHERE  upper(f.database_object_name) = upper(h.owner_table)
       AND    class_category = p_class_category
       AND    owner_table = p_owner_table;

   bool VARCHAR2(1)        := 'F';
   l_database_object_name  VARCHAR2(30):= FND_API.G_MISS_CHAR;
   l_pk1_column_name       VARCHAR2(30):= FND_API.G_MISS_CHAR;
   l_pk2_column_name       VARCHAR2(30):= FND_API.G_MISS_CHAR;
   l_pk3_column_name       VARCHAR2(30):= FND_API.G_MISS_CHAR;
   l_pk4_column_name       VARCHAR2(30):= FND_API.G_MISS_CHAR;
   l_pk5_column_name       VARCHAR2(30):= FND_API.G_MISS_CHAR;
   l_owner_table           VARCHAR2(30);

   p_key                   VARCHAR2(30);
   l_sql                   VARCHAR2(4000);
   l_where_clause          VARCHAR2(4000);
   check_for_where         VARCHAR2(10) ;
   l_additional_where_clause  VARCHAR2(4000) := null;

BEGIN

    OPEN get_category_uses_info;
    FETCH get_category_uses_info INTO l_owner_table, l_additional_where_clause,
          l_pk1_column_name, l_pk2_column_name, l_pk3_column_name,
          l_pk4_column_name, l_pk5_column_name;
        IF (get_category_uses_info%NOTFOUND)THEN
            RETURN bool;
        END IF;

        check_for_where := substrb(l_additional_where_clause,1, 6);
        IF (check_for_where = 'WHERE ') THEN
            l_additional_where_clause := substrb(l_additional_where_clause,6);
        END IF;

    CLOSE get_category_uses_info;

    --p_id and p_key_1 are mutually exclusive
    IF (p_id IS NULL OR p_id = FND_API.G_MISS_NUM) THEN
      p_key := p_key_1;
    ELSE
      p_key := TO_CHAR(p_id);
    END IF;

    BEGIN

    IF l_pk5_column_name IS NOT NULL AND l_pk5_column_name <> FND_API.G_MISS_CHAR
    THEN
      IF l_additional_where_clause is not null THEN
        l_sql := 'SELECT ''T'' ' ||
                 ' FROM ' || p_owner_table ||
                 ' WHERE ' || l_additional_where_clause ||
                 ' AND ' ||   l_pk1_column_name || '=:1 ' ||
                 ' AND ' ||   l_pk2_column_name || '=:2 ' ||
                 ' AND ' ||   l_pk3_column_name || '=:3 ' ||
                 ' AND ' ||   l_pk4_column_name || '=:4 ' ||
                 ' AND ' ||   l_pk5_column_name || '=:5 ' ||
                 ' AND ROWNUM = 1';
      ELSE
        l_sql := 'SELECT ''T'' ' ||
                 ' FROM ' || p_owner_table ||
                 ' WHERE ' || l_pk1_column_name || '=:1 ' ||
                 ' AND ' ||   l_pk2_column_name || '=:2 ' ||
                 ' AND ' ||   l_pk3_column_name || '=:3 ' ||
                 ' AND ' ||   l_pk4_column_name || '=:4 ' ||
                 ' AND ' ||   l_pk5_column_name || '=:5 ' ||
                 ' AND ROWNUM = 1';
      END IF;
      EXECUTE IMMEDIATE l_sql into bool using p_key,
                                                nvl(p_key_2,FND_API.G_MISS_CHAR),
                                                nvl(p_key_3,FND_API.G_MISS_CHAR),
                                                nvl(p_key_4,FND_API.G_MISS_CHAR),
                                                nvl(p_key_5,FND_API.G_MISS_CHAR);
    ELSIF l_pk4_column_name IS NOT NULL AND l_pk4_column_name <> FND_API.G_MISS_CHAR
    THEN
      IF l_additional_where_clause is not null THEN
         l_sql := 'SELECT ''T'' ' ||
                 ' FROM ' || p_owner_table ||
                 ' WHERE ' || l_additional_where_clause ||
                 ' AND ' ||   l_pk1_column_name || '=:1 ' ||
                 ' AND ' ||   l_pk2_column_name || '=:2 ' ||
                 ' AND ' ||   l_pk3_column_name || '=:3 ' ||
                 ' AND ' ||   l_pk4_column_name || '=:4 ' ||
                 ' AND ROWNUM = 1';
      ELSE
        l_sql := 'SELECT ''T'' ' ||
                 ' FROM ' || p_owner_table ||
                 ' WHERE ' || l_pk1_column_name || '=:1 ' ||
                 ' AND ' ||   l_pk2_column_name || '=:2 ' ||
                 ' AND ' ||   l_pk3_column_name || '=:3 ' ||
                 ' AND ' ||   l_pk4_column_name || '=:4 ' ||
                 ' AND ROWNUM = 1';
      END IF;
      EXECUTE IMMEDIATE l_sql into bool using p_key,
                                                nvl(p_key_2,FND_API.G_MISS_CHAR),
                                                nvl(p_key_3,FND_API.G_MISS_CHAR),
                                                nvl(p_key_4,FND_API.G_MISS_CHAR);
    ELSIF l_pk3_column_name IS NOT NULL AND l_pk3_column_name <> FND_API.G_MISS_CHAR
    THEN
      IF l_additional_where_clause is not null THEN
        l_sql := 'SELECT ''T'' ' ||
                 ' FROM ' || p_owner_table ||
                 ' WHERE ' || l_additional_where_clause ||
                 ' AND ' ||   l_pk1_column_name || '=:1 ' ||
                 ' AND ' ||   l_pk2_column_name || '=:2 ' ||
                 ' AND ' ||   l_pk3_column_name || '=:3 ' ||
                 ' AND ROWNUM = 1';
      ELSE
        l_sql := 'SELECT ''T'' ' ||
                 ' FROM ' || p_owner_table ||
                 ' WHERE ' || l_pk1_column_name || '=:1 ' ||
                 ' AND ' ||   l_pk2_column_name || '=:2 ' ||
                 ' AND ' ||   l_pk3_column_name || '=:3 ' ||
                 ' AND ROWNUM = 1';
      END IF;
      EXECUTE IMMEDIATE l_sql into bool using p_key,
                                                nvl(p_key_2,FND_API.G_MISS_CHAR),
                                                nvl(p_key_3,FND_API.G_MISS_CHAR);
    ELSIF l_pk2_column_name IS NOT NULL AND l_pk2_column_name <> FND_API.G_MISS_CHAR
    THEN
      IF l_additional_where_clause is not null THEN
        l_sql := 'SELECT ''T'' ' ||
                 ' FROM ' || p_owner_table ||
                 ' WHERE ' || l_additional_where_clause ||
                 ' AND ' ||   l_pk1_column_name || '=:1 ' ||
                 ' AND ' ||   l_pk2_column_name || '=:2 ' ||
                 ' AND ROWNUM = 1';
      ELSE
        l_sql := 'SELECT ''T'' ' ||
                 ' FROM ' || p_owner_table ||
                 ' WHERE ' || l_pk1_column_name || '=:1 ' ||
                 ' AND ' ||   l_pk2_column_name || '=:2 ' ||
                 ' AND ROWNUM = 1';
      END IF;
      EXECUTE IMMEDIATE l_sql into bool using p_key,
                                                nvl(p_key_2,FND_API.G_MISS_CHAR);
    ELSIF (l_pk1_column_name IS NOT NULL AND l_pk1_column_name <> FND_API.G_MISS_CHAR)
    THEN
      IF l_additional_where_clause is not null THEN
        l_sql := 'SELECT ''T'' ' ||
                 ' FROM ' || p_owner_table ||
                 ' WHERE ' || l_additional_where_clause ||
                 ' AND ' ||   l_pk1_column_name || '=:1 ' ||
                 ' AND ROWNUM = 1';
      ELSE
        l_sql := 'SELECT ''T'' ' ||
                 ' FROM ' || p_owner_table ||
                 ' WHERE ' || l_pk1_column_name || '=:1 ' ||
                 ' AND ROWNUM = 1';

      END IF;
      EXECUTE IMMEDIATE l_sql into bool using p_key;
    END IF;
    EXCEPTION WHEN OTHERS THEN
        bool := 'F';
    END;

RETURN bool;

END IS_VALID_CATEGORY;

/*
FUNCTION IS_VALID_CATEGORY(p_owner_table VARCHAR2,
   p_class_category VARCHAR2,
   p_id NUMBER
)
RETURN VARCHAR2
IS
   CURSOR get_query_info is
       SELECT upper(trim(additional_where_clause)), column_name
       FROM hz_class_category_uses
       WHERE class_category = p_class_category
       AND owner_table = p_owner_table;

   bool VARCHAR2(1) := 'F';
   l_additional_where_clause  VARCHAR2(4000) := null;
   l_column_name VARCHAR2(240) := null;
   l_sql VARCHAR2(4000);
   check_for_where VARCHAR2(10) ;

BEGIN
    OPEN get_query_info;
    FETCH get_query_info INTO l_additional_where_clause, l_column_name;
        IF (get_query_info%NOTFOUND)THEN
            RETURN bool;
        END IF;

        check_for_where := substrb(l_additional_where_clause,1, 6);
        IF (check_for_where = 'WHERE ') THEN
            l_additional_where_clause := substrb(l_additional_where_clause,6);
        END IF;

    CLOSE get_query_info;
        IF l_additional_where_clause is not null THEN
            l_sql := 'SELECT ''T'' ' ||
                ' FROM '|| p_owner_table ||
                ' WHERE '||l_column_name||' = :1 and '||
                l_additional_where_clause||' and rownum = 1';
        ELSE
            l_sql := 'SELECT ''T'' ' ||
               'FROM '|| p_owner_table || ' ' ||
               'WHERE '||l_column_name||'= :1  and rownum = 1';
        END IF;
    BEGIN
        EXECUTE IMMEDIATE l_sql into bool using p_id;
    EXCEPTION WHEN OTHERS THEN
        bool := 'F';
    END;

   RETURN bool;
END IS_VALID_CATEGORY;
*/
/**
 * PROCEDURE create_class_code
 *
 * DESCRIPTION
 *     This is a wrapper on top of FND_LOOKUP_VALUES_PKG.insert_row. It also
 * updates frozen flag and validate class code meaning.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_class_code_rec               Lookup value related columns
 *   IN/OUT:
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
 *   05-28-2002    Amy Wu       o Created.
 *   07-01-2003    Dhaval Mehta  Bug 2960224 : Added validation to TYPE against active
 *                               class categories.
 *   20-Sep-2007   Manivannan J  Bug 6158794 : Added validation to TYPE against
 *                               classification code and classification meaning.
 */

PROCEDURE create_class_code(
    p_init_msg_list           IN      VARCHAR2 := FND_API.G_FALSE,
    p_class_code_rec          IN      CLASS_CODE_REC_TYPE,
    x_return_status           OUT NOCOPY     VARCHAR2,
    x_msg_count               OUT NOCOPY     NUMBER,
    x_msg_data                OUT NOCOPY     VARCHAR2
) is
row_id varchar2(64);
l_class_code_rec CLASS_CODE_REC_TYPE := p_class_code_rec;
begin
         savepoint create_class_code;

          -- initialize message list if p_init_msg_list is set to TRUE.
        IF FND_API.to_Boolean(p_init_msg_list) THEN
                FND_MSG_PUB.initialize;
        END IF;

        -- Initialize return status to SUCCESS
        x_return_status := FND_API.G_RET_STS_SUCCESS;

          If HZ_CLASS_VALIDATE_V2PUB.is_valid_class_code_meaning(l_class_code_rec.type,l_class_code_rec.meaning)='N'
          then
                FND_MESSAGE.SET_NAME('AR', 'HZ_MODIFY_CLASS_CODE_MEANING');
                FND_MSG_PUB.ADD;
                RAISE FND_API.G_EXC_ERROR;
          end if;

--Bug fix 2783498
IF ( l_class_code_rec.start_date_active IS NULL OR
    l_class_code_rec.start_date_active = FND_API.G_MISS_DATE ) THEN
   l_class_code_rec.start_date_active := SYSDATE;
END IF;

IF l_class_code_rec.end_date_active =  FND_API.G_MISS_DATE THEN
   l_class_code_rec.end_date_active := TO_DATE(NULL);
END IF;

-- Bug 2960224 :Added validation to TYPE against active class categories.

        HZ_CLASS_VALIDATE_V2PUB.check_existence_class_category(l_class_code_rec.type, x_return_status);

        if(x_return_status = fnd_api.g_ret_sts_error) then
                RAISE FND_API.G_EXC_ERROR;

-- Bug 6158794: Added validation to TYPE against classification code and classification meaning.
        end if;

        HZ_CLASS_VALIDATE_V2PUB.chk_exist_cls_catgry_type_code(l_class_code_rec.type,l_class_code_rec.code,0,222,x_return_status);
        if(x_return_status = fnd_api.g_ret_sts_error) then
                RAISE FND_API.G_EXC_ERROR;
        end if;

        HZ_CLASS_VALIDATE_V2PUB.chk_exist_clas_catgry_typ_mng(l_class_code_rec.type,l_class_code_rec.meaning,0,222,x_return_status);
        if(x_return_status = fnd_api.g_ret_sts_error) then
                RAISE FND_API.G_EXC_ERROR;

        end if;

         Fnd_Lookup_Values_Pkg.Insert_Row(
          X_ROWID               => row_id,
          X_LOOKUP_TYPE         => l_class_code_rec.type,
          X_SECURITY_GROUP_ID   => 0,
          X_VIEW_APPLICATION_ID => 222,
          X_LOOKUP_CODE         => l_class_code_rec.code,
          X_TAG                 => null,
          X_ATTRIBUTE_CATEGORY  => l_class_code_rec.attribute_category,
          X_ATTRIBUTE1          => l_class_code_rec.attribute1,
          X_ATTRIBUTE2          => l_class_code_rec.attribute2,
          X_ATTRIBUTE3          => l_class_code_rec.attribute3,
          X_ATTRIBUTE4          => l_class_code_rec.attribute4,
          X_ENABLED_FLAG        => l_class_code_rec.enabled_flag,
          X_START_DATE_ACTIVE   => l_class_code_rec.start_date_active,
          X_END_DATE_ACTIVE     => l_class_code_rec.end_date_active,
          X_TERRITORY_CODE      => null,
          X_ATTRIBUTE5          => l_class_code_rec.attribute5,
          X_ATTRIBUTE6          => l_class_code_rec.attribute6,
          X_ATTRIBUTE7          => l_class_code_rec.attribute7,
          X_ATTRIBUTE8          => l_class_code_rec.attribute8,
          X_ATTRIBUTE9          => l_class_code_rec.attribute9,
          X_ATTRIBUTE10         => l_class_code_rec.attribute10,
          X_ATTRIBUTE11         => l_class_code_rec.attribute11,
          X_ATTRIBUTE12         => l_class_code_rec.attribute12,
          X_ATTRIBUTE13         => l_class_code_rec.attribute13,
          X_ATTRIBUTE14         => l_class_code_rec.attribute14,
          X_ATTRIBUTE15         => l_class_code_rec.attribute15,
          X_MEANING             => l_class_code_rec.meaning,
          X_DESCRIPTION         => l_class_code_rec.description,
          X_CREATION_DATE       => HZ_UTILITY_V2PUB.CREATION_DATE,
          X_CREATED_BY          => HZ_UTILITY_V2PUB.CREATED_BY,
          X_LAST_UPDATE_DATE    => HZ_UTILITY_V2PUB.LAST_UPDATE_DATE,
          X_LAST_UPDATED_BY     => HZ_UTILITY_V2PUB.LAST_UPDATED_BY,
          X_LAST_UPDATE_LOGIN   => HZ_UTILITY_V2PUB.LAST_UPDATE_LOGIN);

          set_frozen_flag(l_class_code_rec.type);

   -- Bug 5053099: Raise business events.
   IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
    -- Invoke business event system.
     IF(HZ_UTILITY_V2PUB.G_EXECUTE_API_CALLOUTS in ('Y', 'EVENTS_ENABLED')) THEN
        HZ_BUSINESS_EVENT_V2PVT.create_class_code_event (
        l_class_code_rec );
     END IF;
   END IF;

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO create_class_code;
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO create_class_code ;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);

   WHEN OTHERS THEN
     ROLLBACK TO create_class_code;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
     FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
     FND_MSG_PUB.ADD;
     FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);




end create_class_code;

/**
 * PROCEDURE update_class_code
 *
 * DESCRIPTION
 *     This is a wrapper on top of FND_LOOKUP_VALUES_PKG.update_row. It also
 * updates frozen flag and validate class code meaning.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_class_code_rec               Lookup value related columns
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
 *   05-28-2002    Amy Wu       o Created.
 *
 */

PROCEDURE update_class_code(
    p_init_msg_list           IN      VARCHAR2:= FND_API.G_FALSE,
    p_class_code_rec          IN      CLASS_CODE_REC_TYPE,
    p_object_version_number   IN OUT NOCOPY  NUMBER,
    x_return_status           OUT NOCOPY     VARCHAR2,
    x_msg_count               OUT NOCOPY     NUMBER,
    x_msg_data                OUT NOCOPY     VARCHAR2
) is

l_class_code_rec CLASS_CODE_REC_TYPE := p_class_code_rec;
l_end_date_active DATE;
l_start_date_active DATE;
begin
         savepoint update_class_code;

          -- initialize message list if p_init_msg_list is set to TRUE.
        IF FND_API.to_Boolean(p_init_msg_list) THEN
                FND_MSG_PUB.initialize;
        END IF;

--Bug fix 2783498
SELECT start_date_active,end_date_active into l_start_date_active,l_end_date_active
FROM fnd_lookup_values_vl val
WHERE val.lookup_type = l_class_code_rec.type
AND val.lookup_code = l_class_code_rec.code
AND rownum = 1
FOR UPDATE OF LOOKUP_CODE NOWAIT;

IF l_class_code_rec.start_date_active IS NULL THEN
   l_class_code_rec.start_date_active := l_start_date_active;
ELSIF l_class_code_rec.start_date_active = FND_API.G_MISS_DATE THEN
   l_class_code_rec.start_date_active := SYSDATE;
END IF;

IF l_class_code_rec.end_date_active IS NULL THEN
   l_class_code_rec.end_date_active := l_end_date_active;
elsif l_class_code_rec.end_date_active = FND_API.G_MISS_DATE THEN
   l_class_code_rec.end_date_active := TO_DATE(NULL);
END IF;


        -- Initialize return status to SUCCESS
        x_return_status := FND_API.G_RET_STS_SUCCESS;

         if (l_class_code_rec.meaning is not null and l_class_code_rec.meaning <> fnd_api.g_miss_char)
         then
                If HZ_CLASS_VALIDATE_V2PUB.is_valid_class_code_meaning(l_class_code_rec.type,l_class_code_rec.meaning)='N'
                then
                        FND_MESSAGE.SET_NAME('AR', 'HZ_MODIFY_CLASS_CODE_MEANING');
                        FND_MSG_PUB.ADD;
                        RAISE FND_API.G_EXC_ERROR;
                end if;
        end if;

         Fnd_Lookup_Values_Pkg.Update_Row(
          X_LOOKUP_TYPE         => l_class_code_rec.type,
          X_SECURITY_GROUP_ID   => 0,
          X_VIEW_APPLICATION_ID => 222,
          X_LOOKUP_CODE         => l_class_code_rec.code,
          X_TAG                 => null,
          X_ATTRIBUTE_CATEGORY  => l_class_code_rec.attribute_category,
          X_ATTRIBUTE1          => l_class_code_rec.attribute1,
          X_ATTRIBUTE2          => l_class_code_rec.attribute2,
          X_ATTRIBUTE3          => l_class_code_rec.attribute3,
          X_ATTRIBUTE4          => l_class_code_rec.attribute4,
          X_ENABLED_FLAG        => l_class_code_rec.enabled_flag,
          X_START_DATE_ACTIVE   => l_class_code_rec.start_date_active,
          X_END_DATE_ACTIVE     => l_class_code_rec.end_date_active,
          X_TERRITORY_CODE      => null,
          X_ATTRIBUTE5          => l_class_code_rec.attribute5,
          X_ATTRIBUTE6          => l_class_code_rec.attribute6,
          X_ATTRIBUTE7          => l_class_code_rec.attribute7,
          X_ATTRIBUTE8          => l_class_code_rec.attribute8,
          X_ATTRIBUTE9          => l_class_code_rec.attribute9,
          X_ATTRIBUTE10         => l_class_code_rec.attribute10,
          X_ATTRIBUTE11         => l_class_code_rec.attribute11,
          X_ATTRIBUTE12         => l_class_code_rec.attribute12,
          X_ATTRIBUTE13         => l_class_code_rec.attribute13,
          X_ATTRIBUTE14         => l_class_code_rec.attribute14,
          X_ATTRIBUTE15         => l_class_code_rec.attribute15,
          X_MEANING             => l_class_code_rec.meaning,
          X_DESCRIPTION         => l_class_code_rec.description,
          X_LAST_UPDATE_DATE    => HZ_UTILITY_V2PUB.LAST_UPDATE_DATE,
          X_LAST_UPDATED_BY     => HZ_UTILITY_V2PUB.LAST_UPDATED_BY,
          X_LAST_UPDATE_LOGIN   => HZ_UTILITY_V2PUB.LAST_UPDATE_LOGIN);

          set_frozen_flag(l_class_code_rec.type);

   -- Bug 5053099: Raise businss events.
   IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
    -- Invoke business event system.
     IF(HZ_UTILITY_V2PUB.G_EXECUTE_API_CALLOUTS in ('Y', 'EVENTS_ENABLED')) THEN
        HZ_BUSINESS_EVENT_V2PVT.update_class_code_event (
            p_class_code_rec     => l_class_code_rec,
            p_old_class_code_rec => NULL );
     END IF;
   END IF;

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO update_class_code;
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO update_class_code ;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);

   WHEN OTHERS THEN
     ROLLBACK TO update_class_code;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
     FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
     FND_MSG_PUB.ADD;
     FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);


end update_class_code;

-- This procedure v2_copy_class_category is used only for the HTML Admin UI
-- This is used to "copy" class category, class codes, and their relations
-- onto a new class category.

PROCEDURE v2_copy_class_category (
    p_class_category              IN     VARCHAR2,
    p_copy_class_category         IN     VARCHAR2,
    x_return_status               IN OUT NOCOPY VARCHAR2
) IS

  x_class_category_rec
HZ_CLASSIFICATION_V2PUB.CLASS_CATEGORY_REC_TYPE;
  x_class_code_rec               HZ_CLASSIFICATION_V2PUB.CLASS_CODE_REC_TYPE;
  x_class_code_relation_rec
HZ_CLASSIFICATION_V2PUB.CLASS_CODE_RELATION_REC_TYPE;

  l_lookup_type                  VARCHAR2(30);
  l_lookup_code                  VARCHAR2(30);
  l_meaning                      VARCHAR2(80);
  l_description                  VARCHAR2(240);
  l_start_date_active            DATE;
  l_end_date_active              DATE;
  l_enabled_flag                 VARCHAR2(1);

  x_msg_count                    NUMBER;
  x_msg_data                     VARCHAR2(2000);

  --Create cursor for class code
  CURSOR C_codes_cursor
  IS
  SELECT    LOOKUP_CODE,
            MEANING,
            DESCRIPTION,
            START_DATE_ACTIVE,
            END_DATE_ACTIVE,
            ENABLED_FLAG
  FROM      FND_LOOKUP_VALUES
  WHERE     LOOKUP_TYPE = p_class_category;

  --Create cursor for class code relations
  CURSOR C_codes_rel_cursor
  IS
  SELECT    CLASS_CODE,
            SUB_CLASS_CODE,
            START_DATE_ACTIVE,
            END_DATE_ACTIVE
  FROM      HZ_CLASS_CODE_RELATIONS
  WHERE     CLASS_CATEGORY = p_class_category;


  BEGIN

  --Copying of Class codes
  FOR codeInfo IN C_codes_cursor LOOP
    x_class_code_rec.TYPE              := p_copy_class_category;
    x_class_code_rec.CODE              := codeInfo.LOOKUP_CODE;
    x_class_code_rec.MEANING           := codeInfo.MEANING;
    x_class_code_rec.DESCRIPTION       := codeInfo.DESCRIPTION;
    x_class_code_rec.START_DATE_ACTIVE := codeInfo.START_DATE_ACTIVE;
    x_class_code_rec.END_DATE_ACTIVE   := codeInfo.END_DATE_ACTIVE;
    x_class_code_rec.ENABLED_FLAG      := codeInfo.ENABLED_FLAG;

    --Now call the API to create class code
    HZ_CLASSIFICATION_V2PUB.Create_Class_Code(
                            'T',
                            x_class_code_rec,
                            x_return_status,
                            x_msg_count,
                            x_msg_data);
     --Output the results
  END LOOP;

  --Copying of Class code relations
  FOR relInfo IN C_codes_rel_cursor LOOP
    x_class_code_relation_rec.CLASS_CATEGORY    := p_copy_class_category;
    x_class_code_relation_rec.CLASS_CODE        := relInfo.CLASS_CODE;
    x_class_code_relation_rec.SUB_CLASS_CODE    := relInfo.SUB_CLASS_CODE;
    x_class_code_relation_rec.START_DATE_ACTIVE := relInfo.START_DATE_ACTIVE;
    x_class_code_relation_rec.END_DATE_ACTIVE   := relInfo.END_DATE_ACTIVE;
    x_class_code_relation_rec.APPLICATION_ID    := 222;
    x_class_code_relation_rec.CREATED_BY_MODULE := 'HTML_ADMIN_UI';

  --Now call the API to create class code relation
    HZ_CLASSIFICATION_V2PUB.Create_Class_Code_Relation(
                            'T',
                            x_class_code_relation_rec,
                            x_return_status,
                            x_msg_count,
                            x_msg_data);
  --Output the results
  END LOOP;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

END v2_copy_class_category;

END HZ_CLASSIFICATION_V2PUB;

/
