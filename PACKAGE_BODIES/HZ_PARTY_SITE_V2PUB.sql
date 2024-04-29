--------------------------------------------------------
--  DDL for Package Body HZ_PARTY_SITE_V2PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_PARTY_SITE_V2PUB" AS
/*$Header: ARH2PSSB.pls 120.43 2006/07/31 23:39:52 baianand noship $ */

--------------------------------------------
-- declaration of global variables and types
--------------------------------------------

G_DEBUG_COUNT                       NUMBER := 0;
--G_DEBUG                             BOOLEAN := FALSE;

G_PKG_NAME                          CONSTANT VARCHAR2(30) := 'HZ_PARTY_SITE_V2PUB';

-- Bug 2197181: added for mix-n-match project.

g_pst_mixnmatch_enabled             VARCHAR2(1);
g_pst_selected_datasources          VARCHAR2(255);
g_pst_is_datasource_selected        VARCHAR2(1) := 'N';
g_pst_entity_attr_id                NUMBER;

G_MISS_CONTENT_SOURCE_TYPE               CONSTANT VARCHAR2(30) := 'USER_ENTERED';


-- Code added for BUG 3714636

g_message_name                     VARCHAR2(1) :=NULL;
--------------------------------------------------
-- declaration of private procedures and functions
--------------------------------------------------

/*PROCEDURE enable_debug;

PROCEDURE disable_debug;
*/

PROCEDURE do_create_party_site (
    p_party_site_rec                IN OUT NOCOPY PARTY_SITE_REC_TYPE,
    x_party_site_id                 OUT NOCOPY    NUMBER,
    x_party_site_number             OUT NOCOPY    VARCHAR2,
    x_return_status                 IN OUT NOCOPY VARCHAR2
);

PROCEDURE do_update_party_site(
    p_party_site_rec                IN OUT NOCOPY PARTY_SITE_REC_TYPE,
    p_object_version_number         IN OUT NOCOPY NUMBER,
    x_return_status                 IN OUT NOCOPY VARCHAR2
);

PROCEDURE do_create_party_site_use(
    p_party_site_use_rec            IN OUT NOCOPY PARTY_SITE_USE_REC_TYPE,
    x_party_site_use_id             OUT NOCOPY    NUMBER,
    x_return_status                 IN OUT NOCOPY VARCHAR2
);

PROCEDURE do_update_party_site_use(
    p_party_site_use_rec            IN OUT NOCOPY PARTY_SITE_USE_REC_TYPE,
    p_object_version_number         IN OUT NOCOPY NUMBER,
    x_return_status                 IN OUT NOCOPY VARCHAR2
);

PROCEDURE do_unmark_primary_per_type(
    p_party_id                      IN     NUMBER,
    p_party_site_id                 IN     NUMBER,
    p_site_use_type                 IN     VARCHAR2,
    p_mode                	    IN     VARCHAR2 := NULL
);

PROCEDURE do_update_address(
    p_party_id                      IN     NUMBER,
    p_location_id                   IN     NUMBER
);

PROCEDURE do_unmark_address_flag(
    p_party_id                      IN     NUMBER,
    p_party_site_id                 IN     NUMBER := NULL,
    p_mode                          IN     VARCHAR2 := NULL
);
--
--- Following procedures are added in Party Site and Account Site status sync.
--
PROCEDURE update_acct_sites_status(
    p_party_site_id          IN     NUMBER,
    p_new_status                 IN     VARCHAR2,
    x_return_status                 IN OUT NOCOPY VARCHAR2
);
PROCEDURE inactivate_party_site_uses(
    p_party_site_id          IN     NUMBER,
    p_new_status                 IN     VARCHAR2,
    x_return_status                 IN OUT NOCOPY VARCHAR2
);
PROCEDURE inactivate_account_site_uses(
    p_party_site_id          IN     NUMBER,
    p_new_status                 IN     VARCHAR2,
    x_return_status                 IN OUT NOCOPY VARCHAR2
);
PROCEDURE cascade_site_status_changes(
    p_party_site_id          IN     NUMBER,
    p_new_status                 IN     VARCHAR2,
    x_return_status                 IN OUT NOCOPY VARCHAR2
);

PROCEDURE check_obsolete_columns (
    p_create_update_flag          IN     VARCHAR2,
    p_party_site_rec              IN     party_site_rec_type,
    p_old_party_site_rec          IN     party_site_rec_type DEFAULT NULL,
    x_return_status               IN OUT NOCOPY VARCHAR2
);

-----------------------------
-- body of private procedures
-----------------------------

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
 *   07-23-2001    Jianying Huang      o Created.
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

/*===========================================================================+
 | PROCEDURE
 |              do_create_party_site
 |
 | DESCRIPTION
 |              Creates party_site.
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |
 |              OUT:
 |                    x_party_site_id
 |                    x_party_site_number
 |          IN/ OUT:
 |                    p_party_site_rec
 |                    x_return_status
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |
 |  19-APR-2004    Rajib Ranjan Borah      o Bug 3175816. Added GLOBAL_LOCATION_NUMBER
 |                                           to HZ_PARTY_SITES.
 |  04-JAN-2005    Rajib Ranjan Borah      o SSM SST Integration and Extension.
 |                                           For non-profile entities, the concept of
 |                                           select/de-select data-sources is obsoleted.
 +===========================================================================*/

PROCEDURE do_create_party_site(
    p_party_site_rec                IN OUT NOCOPY PARTY_SITE_REC_TYPE,
    x_party_site_id                 OUT NOCOPY    NUMBER,
    x_party_site_number             OUT NOCOPY    VARCHAR2,
    x_return_status                 IN OUT NOCOPY VARCHAR2
) IS

    l_party_site_id                 NUMBER := p_party_site_rec.party_site_id;
    l_party_site_number             VARCHAR2(30) := p_party_site_rec.party_site_number;
    l_gen_party_site_number         VARCHAR2(1);
    l_rowid                         ROWID := NULL;
    l_dummy                         VARCHAR2(1);
    l_debug_prefix                  VARCHAR2(30) := '';

    -- Bug 2197181: Added l_loc_actual_content_source to denormalize actual_content_source into
    -- hz_party_sites from hz_locations.

   l_loc_actual_content_source      hz_locations.actual_content_source%TYPE;
   l_orig_sys_reference_rec HZ_ORIG_SYSTEM_REF_PUB.ORIG_SYS_REFERENCE_REC_TYPE;
   l_msg_count                        NUMBER;
   l_msg_data                         VARCHAR2(2000);
   l_country_code                     hz_parties.country%type;--4742586

BEGIN

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'do_create_party_site (+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- if primary key value is passed, check for uniqueness.
    IF l_party_site_id IS NOT NULL AND
        l_party_site_id <> FND_API.G_MISS_NUM
    THEN
        BEGIN
            SELECT 'Y'
            INTO   l_dummy
            FROM   HZ_PARTY_SITES
            WHERE  PARTY_SITE_ID = l_party_site_id;

            FND_MESSAGE.SET_NAME('AR', 'HZ_API_DUPLICATE_COLUMN');
            FND_MESSAGE.SET_TOKEN('COLUMN', 'party_site_id');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;

        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                NULL;
        END;
    END IF;

    -- if GENERATE_PARTY_SITE_NUMBER is 'N', then if party_site_number is
    -- not passed or is a duplicate raise error.
    -- if GENERATE_PARTY_SITE_NUMBER is NULL or 'Y', generate party_site_number
    -- from sequence till a unique value is obtained.

    l_gen_party_site_number := fnd_profile.value('HZ_GENERATE_PARTY_SITE_NUMBER');

    IF l_gen_party_site_number = 'N' THEN
        IF l_party_site_number = FND_API.G_MISS_CHAR
           OR
           l_party_site_number IS NULL
        THEN
            FND_MESSAGE.SET_NAME('AR', 'HZ_API_MISSING_COLUMN');
            FND_MESSAGE.SET_TOKEN('COLUMN', 'party_site_number');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        END IF;

        BEGIN
            SELECT 'Y'
            INTO   l_dummy
            FROM   HZ_PARTY_SITES
            WHERE  PARTY_SITE_NUMBER = l_party_site_number;

            FND_MESSAGE.SET_NAME('AR', 'HZ_API_DUPLICATE_COLUMN');
            FND_MESSAGE.SET_TOKEN('COLUMN', 'party_site_number');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;

        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                NULL;
        END;

    ELSIF l_gen_party_site_number = 'Y'
          OR
          l_gen_party_site_number IS NULL
    THEN

        IF l_party_site_number <> FND_API.G_MISS_CHAR
           AND
           l_party_site_number IS NOT NULL
        THEN
            FND_MESSAGE.SET_NAME('AR', 'HZ_API_PARTY_SITE_NUM_AUTO_ON');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        END IF;

    END IF;

    x_party_site_number := l_party_site_number;

    -- Bug 2197181: Added l_loc_actual_content_source to denormalize
    -- actual_content_source into hz_party_sites from hz_locations.

    HZ_REGISTRY_VALIDATE_V2PUB.validate_party_site(
                                           'C',
                                           p_party_site_rec,
                                           l_rowid,
                                           x_return_status,
                                           l_loc_actual_content_source);

    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Bug 2197181: added for mix-n-match project. first check if user
    -- has privilege to create user-entered data if mix-n-match is enabled.

    -- SSM SST Integration and Extension
    -- For non-profile entities, the concept of select/de-select data-sources is obsoleted.

    IF /*NVL(g_pst_mixnmatch_enabled, 'N') = 'Y' AND*/
       l_loc_actual_content_source = G_MISS_CONTENT_SOURCE_TYPE
    THEN
      HZ_MIXNM_UTILITY.CheckUserCreationPrivilege (
        p_entity_name                  => 'HZ_LOCATIONS',
        p_entity_attr_id               => g_pst_entity_attr_id,
        p_mixnmatch_enabled            => g_pst_mixnmatch_enabled,
        p_actual_content_source        => l_loc_actual_content_source,
        x_return_status                => x_return_status );
    END IF;

    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Bug 2197181: added for mix-n-match project.
    -- check if the data source is seleted.
/* SSM SST Integration and Extension
 * For non-profile entities, the concept of select/de-select data-sources is obsoleted.
 * There is no need to check if the data-source is selected.

    g_pst_is_datasource_selected :=
      HZ_MIXNM_UTILITY.isDataSourceSelected (
        p_selected_datasources           => g_pst_selected_datasources,
        p_actual_content_source          => l_loc_actual_content_source );
*/
    -- if this is the first active, visible party site,
    -- we need to  mark it with identifying flag = 'Y'.

    BEGIN
        -- Bug 2197181: Added the checking if the party site is visible
        -- or not. The identifying address should be visible.

        -- SSM SST Integration and Extension
        -- For non-profile entities, the concept of select/de-select data-sources is obsoleted.
        -- There is no need to check if the data-source is selected.

        SELECT 'Y' INTO l_dummy
        FROM HZ_PARTY_SITES
        WHERE PARTY_ID = p_party_site_rec.party_id
        AND STATUS = 'A'
     /*   AND HZ_MIXNM_UTILITY.isDataSourceSelected (
              g_pst_selected_datasources, actual_content_source ) = 'Y'*/
        AND ROWNUM = 1;

        -- no exception raise, means 'a primary party site exist'

        -- if the current party site is to be identifying, then unmark
        -- the previous party sites with identifying flag = 'Y'.

        -- Bug 2197181: added for mix-n-match project: the identifying_flag
        -- can be set to 'Y' only if the party site will be visible. If it
        -- is not visible, the flag must be reset to 'N'.

        -- SSM SST Integration and Extension
        -- For non-profile entities, the concept of select/de-select data-sources is obsoleted.
        -- There is no need to check if the data-source is selected.

        IF p_party_site_rec.identifying_address_flag = 'Y' /*AND
           g_pst_is_datasource_selected = 'Y'*/
        THEN
          -- Cahnged the below call to use the actual parameter name
          -- to fix the bug # 5436273
          do_unmark_address_flag(p_party_id => p_party_site_rec.party_id, p_mode => 'I');
        ELSE
          p_party_site_rec.identifying_address_flag := 'N';
        END IF;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            -- this is the first visible, active address, so this will be
            -- set as identifying address.

            -- Bug 2197181: added for mix-n-match project: the identifying_flag
            -- can be set to 'Y' only if the party site will be visible. If it is
            -- not visible, the flag must be reset to 'N'.

            -- SSM SST Integration and Extension
            -- For non-profile entities, the concept of select/de-select data-sources is obsoleted.
            -- There is no need to check if the data-source is selected.

            IF (NVL(p_party_site_rec.status, 'A') = 'A' OR
                p_party_site_rec.status = FND_API.G_MISS_CHAR) /*AND
               g_pst_is_datasource_selected = 'Y'*/
            THEN
              p_party_site_rec.identifying_address_flag := 'Y';
            ELSE
              p_party_site_rec.identifying_address_flag := 'N';
            END IF;
    END;

    --denormalize primary address
    IF p_party_site_rec.identifying_address_flag = 'Y' THEN
        IF p_party_site_rec.party_id <> -1 THEN
            do_update_address(
              p_party_site_rec.party_id,
              p_party_site_rec.location_id);
        END IF;
    END IF;

    p_party_site_rec.party_site_id := l_party_site_id;
    p_party_site_rec.party_site_number := l_party_site_number;

    -- this is for orig_system_defaulting
    IF p_party_site_rec.party_site_id = FND_API.G_MISS_NUM THEN
        p_party_site_rec.party_site_id := NULL;
    END IF;


    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'HZ_PARTY_SITES_PKG.Insert_Row (+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- call table-handler.
    HZ_PARTY_SITES_PKG.Insert_Row (
        X_PARTY_SITE_ID                         => p_party_site_rec.party_site_id,
        X_PARTY_ID                              => p_party_site_rec.party_id,
        X_LOCATION_ID                           => p_party_site_rec.location_id,
        X_PARTY_SITE_NUMBER                     => p_party_site_rec.party_site_number,
        X_ATTRIBUTE_CATEGORY                    => p_party_site_rec.attribute_category,
        X_ATTRIBUTE1                            => p_party_site_rec.attribute1,
        X_ATTRIBUTE2                            => p_party_site_rec.attribute2,
        X_ATTRIBUTE3                            => p_party_site_rec.attribute3,
        X_ATTRIBUTE4                            => p_party_site_rec.attribute4,
        X_ATTRIBUTE5                            => p_party_site_rec.attribute5,
        X_ATTRIBUTE6                            => p_party_site_rec.attribute6,
        X_ATTRIBUTE7                            => p_party_site_rec.attribute7,
        X_ATTRIBUTE8                            => p_party_site_rec.attribute8,
        X_ATTRIBUTE9                            => p_party_site_rec.attribute9,
        X_ATTRIBUTE10                           => p_party_site_rec.attribute10,
        X_ATTRIBUTE11                           => p_party_site_rec.attribute11,
        X_ATTRIBUTE12                           => p_party_site_rec.attribute12,
        X_ATTRIBUTE13                           => p_party_site_rec.attribute13,
        X_ATTRIBUTE14                           => p_party_site_rec.attribute14,
        X_ATTRIBUTE15                           => p_party_site_rec.attribute15,
        X_ATTRIBUTE16                           => p_party_site_rec.attribute16,
        X_ATTRIBUTE17                           => p_party_site_rec.attribute17,
        X_ATTRIBUTE18                           => p_party_site_rec.attribute18,
        X_ATTRIBUTE19                           => p_party_site_rec.attribute19,
        X_ATTRIBUTE20                           => p_party_site_rec.attribute20,
        X_ORIG_SYSTEM_REFERENCE                 => p_party_site_rec.orig_system_reference,
        X_LANGUAGE                              => p_party_site_rec.language,
        X_MAILSTOP                              => p_party_site_rec.mailstop,
        X_IDENTIFYING_ADDRESS_FLAG              => p_party_site_rec.identifying_address_flag,
        X_STATUS                                => p_party_site_rec.status,
        X_PARTY_SITE_NAME                       => p_party_site_rec.party_site_name,
        X_ADDRESSEE                             => p_party_site_rec.addressee,
        X_OBJECT_VERSION_NUMBER                 => 1,
        X_CREATED_BY_MODULE                     => p_party_site_rec.created_by_module,
        X_APPLICATION_ID                        => p_party_site_rec.application_id,
        X_ACTUAL_CONTENT_SOURCE                 => l_loc_actual_content_source,
        -- Bug 3175816.
        X_GLOBAL_LOCATION_NUMBER                => p_party_site_rec.global_location_number,
        X_DUNS_NUMBER_C                         => p_party_site_rec.duns_number_c
    );


    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'HZ_PARTY_SITES_PKG.Insert_Row (-) ' ||
                                        'x_party_site_id = ' || p_party_site_rec.party_site_id,
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

      if p_party_site_rec.orig_system is not null
         and p_party_site_rec.orig_system <>fnd_api.g_miss_char
      then
                l_orig_sys_reference_rec.orig_system := p_party_site_rec.orig_system;
                l_orig_sys_reference_rec.orig_system_reference := p_party_site_rec.orig_system_reference;
                l_orig_sys_reference_rec.owner_table_name := 'HZ_PARTY_SITES';
                l_orig_sys_reference_rec.owner_table_id := p_party_site_rec.party_site_id;
                l_orig_sys_reference_rec.created_by_module := p_party_site_rec.created_by_module;

                hz_orig_system_ref_pub.create_orig_system_reference(
                        FND_API.G_FALSE,
                        l_orig_sys_reference_rec,
                        x_return_status,
                        l_msg_count,
                        l_msg_data);
                 IF x_return_status <> fnd_api.g_ret_sts_success THEN
                        RAISE FND_API.G_EXC_ERROR;
                END IF;
      end if;

    x_party_site_id := p_party_site_rec.party_site_id;
    x_party_site_number := p_party_site_rec.party_site_number;
--Bug No. 4742586
BEGIN
Select country into l_country_code from hz_locations
where location_id = p_party_site_rec.location_id;

EXCEPTION
WHEN OTHERS THEN l_country_code := null;
END;
--Bug No. 4742586
-- Bug 4490715 : call eTax procedure to populate ZX_PARTY_TAX_PROFILE
    ZX_PARTY_TAX_PROFILE_PKG.insert_row (
         P_COLLECTING_AUTHORITY_FLAG => null,
         P_PROVIDER_TYPE_CODE => null,
         P_CREATE_AWT_DISTS_TYPE_CODE => null,
         P_CREATE_AWT_INVOICES_TYPE_COD => null,
         P_TAX_CLASSIFICATION_CODE => null,
         P_SELF_ASSESS_FLAG => null,
         P_ALLOW_OFFSET_TAX_FLAG => null,
         P_REP_REGISTRATION_NUMBER => null,
         P_EFFECTIVE_FROM_USE_LE => null,
         P_RECORD_TYPE_CODE => null,
         P_REQUEST_ID => null,
         P_ATTRIBUTE1 => null,
         P_ATTRIBUTE2 => null,
         P_ATTRIBUTE3 => null,
         P_ATTRIBUTE4 => null,
         P_ATTRIBUTE5 => null,
         P_ATTRIBUTE6 => null,
         P_ATTRIBUTE7 => null,
         P_ATTRIBUTE8 => null,
         P_ATTRIBUTE9 => null,
         P_ATTRIBUTE10 => null,
         P_ATTRIBUTE11 => null,
         P_ATTRIBUTE12 => null,
         P_ATTRIBUTE13 => null,
         P_ATTRIBUTE14 => null,
         P_ATTRIBUTE15 => null,
         P_ATTRIBUTE_CATEGORY => null,
         P_PARTY_ID => x_party_site_id,
         P_PROGRAM_LOGIN_ID => null,
         P_PARTY_TYPE_CODE => 'THIRD_PARTY_SITE',
         P_SUPPLIER_FLAG => null,
         P_CUSTOMER_FLAG => null,
         P_SITE_FLAG => null,
         P_PROCESS_FOR_APPLICABILITY_FL => null,
         P_ROUNDING_LEVEL_CODE => null,
         P_ROUNDING_RULE_CODE => null,
         P_WITHHOLDING_START_DATE => null,
         P_INCLUSIVE_TAX_FLAG => null,
         P_ALLOW_AWT_FLAG => null,
         P_USE_LE_AS_SUBSCRIBER_FLAG => null,
         P_LEGAL_ESTABLISHMENT_FLAG => null,
         P_FIRST_PARTY_LE_FLAG => null,
         P_REPORTING_AUTHORITY_FLAG => null,
         X_RETURN_STATUS => x_return_status,
         P_REGISTRATION_TYPE_CODE => null,--4742586
         P_COUNTRY_CODE => l_country_code --4742586
         );
        IF x_return_status <> fnd_api.g_ret_sts_success THEN
          RAISE FND_API.G_EXC_ERROR;
        END IF;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'do_create_party_site (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

END do_create_party_site;


/*===========================================================================+
 | PROCEDURE
 |              do_update_party_site
 |
 | DESCRIPTION
 |              Updates party_site.
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |              OUT:
 |          IN/ OUT:
 |                    p_party_site_rec
 |                    x_return_statue
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |
 |   04-Dec-2001      Rajeshwari P   Added the code to make an identifying address
 |                                   as inactive Only if any other active sites are
 |                                   are present else raise an error.
 |   05-APR-2001     Rajeshwari P    Bug 2306201.Partially reverting the fix
 |                                   made in Bug 1882511.No error is raised if
 |                                   the only site present is made inactive.
 |   28-OCT-2003     Ramesh Ch       Bug#2914238. Updated who columns.
 |
 |   19-APR-2004    Rajib Ranjan Borah      o Bug 3175816. Added GLOBAL_LOCATION_NUMBER
 |                                            to HZ_PARTY_SITES.
 |   04-JAN-2005    Rajib Ranjan Borah      o SSM SST Integration and Extension.
 |                                            For non-profile entities, the concept of
 |                                            select/de-select data-sources is obsoleted.
 |
 +===========================================================================*/

PROCEDURE do_update_party_site(
    p_party_site_rec                IN OUT  NOCOPY PARTY_SITE_REC_TYPE,
    p_object_version_number         IN OUT NOCOPY  NUMBER,
    x_return_status                 IN OUT NOCOPY  VARCHAR2
) IS

    l_object_version_number         NUMBER;
    l_rowid                         ROWID;
    ldup_rowid                      ROWID;
    db_identifying_address_flag     VARCHAR2(1);
    db_actual_content_source        hz_party_sites.actual_content_source%TYPE;
    db_party_id                     NUMBER;
    db_location_id                  NUMBER;
    db_status                       VARCHAR2(1);
    l_identifying_location_id       NUMBER;
    l_loc_actual_content_source     hz_locations.actual_content_source%TYPE;
    l_dummy                         VARCHAR2(1);
    l_debug_prefix                  VARCHAR2(30) := '';

BEGIN

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'do_update_party_site (+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;


    -- check whether record has been updated by another user. If not, lock it.
    BEGIN
        SELECT OBJECT_VERSION_NUMBER,
               PARTY_ID,
               LOCATION_ID,
               IDENTIFYING_ADDRESS_FLAG,
               STATUS,
               ROWID,
               ACTUAL_CONTENT_SOURCE
        INTO   l_object_version_number,
               db_party_id,
               db_location_id,
               db_identifying_address_flag,
               db_status,
               l_rowid,
               db_actual_content_source
        FROM   HZ_PARTY_SITES
        WHERE  PARTY_SITE_ID = p_party_site_rec.party_site_id
        FOR UPDATE OF PARTY_SITE_ID NOWAIT;

        IF NOT
            (
             (p_object_version_number IS NULL AND l_object_version_number IS NULL)
             OR
             (p_object_version_number IS NOT NULL AND
              l_object_version_number IS NOT NULL AND
              p_object_version_number = l_object_version_number
             )
            )
        THEN
            FND_MESSAGE.SET_NAME('AR', 'HZ_API_RECORD_CHANGED');
            FND_MESSAGE.SET_TOKEN('TABLE', 'hz_party_sites');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        END IF;

        p_object_version_number := nvl(l_object_version_number, 1) + 1;

    EXCEPTION WHEN NO_DATA_FOUND THEN
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_NO_RECORD');
        FND_MESSAGE.SET_TOKEN('RECORD', 'party site');
        FND_MESSAGE.SET_TOKEN('VALUE', NVL(TO_CHAR(p_party_site_rec.party_site_id), 'null'));
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END;

    -- Bug 2197181: added for mix-n-match project.
    -- check if the data source is seleted.
/* SSM SST Integration and Extension
 * For non-profile entities, the concept of select/de-select data-sources is obsoleted.
 * There is no need to check if the data-source is selected.

    g_pst_is_datasource_selected :=
      HZ_MIXNM_UTILITY.isDataSourceSelected (
        p_selected_datasources           => g_pst_selected_datasources,
        p_actual_content_source          => db_actual_content_source );
*/
    -- call for validations.
    HZ_REGISTRY_VALIDATE_V2PUB.validate_party_site(
                                           'U',
                                           p_party_site_rec,
                                           l_rowid,
                                           x_return_status,
                                           l_loc_actual_content_source);

    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- if the current site is updated to be identifying one, then
    -- unmark the previous party sites with identifying flag = 'Y'.


    IF p_party_site_rec.identifying_address_flag = 'Y'  AND
       db_identifying_address_flag <> 'Y' /* AND
       -- Bug 2197181: added for mix-n-match project: the identifying_flag
       -- can be set to 'Y' only if the party site will be visible. If it
       -- is not visible, the flag must be reset to 'N'.

       -- SSM SST Integration and Extension
       -- For non-profile entities, the concept of select/de-select data-sources is obsoleted.
       -- There is no need to check if the data-source is selected.

       g_pst_is_datasource_selected = 'Y' */
    THEN
      do_unmark_address_flag(db_party_id, p_party_site_rec.party_site_id, 'U');
      l_identifying_location_id := db_location_id;
    ELSE
      -- ignore the value of primary address flag if the flag
      -- has been set to 'N' or NULL or FND_API.G_MISS_CHAR.
      -- user can not unset a primary address flag by passing
      -- value 'N' or NULL. to unset a primary flag, he/she
      -- needs to select another address as primary. this
      -- address will be unmarked automatically.

      p_party_site_rec.identifying_address_flag := NULL;

      -- If the current site is an identifying address site and
      -- is being marked as inactive then set it as non-primary
      -- and mark the next active site as identifying address.

      IF (db_status = 'A' AND
          p_party_site_rec.status = 'I' AND
          db_identifying_address_flag = 'Y') OR
         (db_status = 'I' AND
          p_party_site_rec.status = 'A'  /* AND
          -- Bug 2197181: added for mix-n-match project: the
          -- identifying_flag can be set to 'Y' only if the party site will be visible.

          -- SSM SST Integration and Extension
          -- For non-profile entities, the concept of select/de-select data-sources is obsoleted.
          -- There is no need to check if the data-source is selected.

          g_pst_is_datasource_selected = 'Y' */)
      THEN
      BEGIN
         -- Check if any other active, visible, party site is present.

          SELECT ROWID, location_id
          INTO ldup_rowid, l_identifying_location_id
          FROM HZ_PARTY_SITES
          WHERE party_site_id = (
            SELECT min(party_site_id)
            FROM hz_party_sites
            WHERE party_id = db_party_id
            AND status = 'A'
            AND party_site_id <> p_party_site_rec.party_site_id
            -- Bug 2197181: added for mix-n-match project: the identifying_flag
            -- can be set to 'Y' only if the party site will be visible.

            -- SSM SST Integration and Extension
            -- For non-profile entities, the concept of select/de-select data-sources is obsoleted.
            -- There is no need to check if the data-source is selected.
       /*     AND HZ_MIXNM_UTILITY.isDataSourceSelected (
                  g_pst_selected_datasources,
                  actual_content_source) = 'Y'*/);

          -- no exception means an active, visible party site was found.

          -- set the new party site as identifying address and
          -- set the current record as non identifying address.

          IF p_party_site_rec.status = 'I' THEN
            UPDATE HZ_PARTY_SITES
            SET IDENTIFYING_ADDRESS_FLAG = 'Y',
                last_update_date     = hz_utility_v2pub.last_update_date,
                last_updated_by      = hz_utility_v2pub.last_updated_by,
                last_update_login    = hz_utility_v2pub.last_update_login,
                request_id           = hz_utility_v2pub.request_id,
                program_id           = hz_utility_v2pub.program_id,
                program_application_id = hz_utility_v2pub.program_application_id,
                program_update_date  = hz_utility_v2pub.program_update_date
            WHERE ROWID = ldup_rowid;

            p_party_site_rec.identifying_address_flag := 'N';
          END IF;
      EXCEPTION
          WHEN NO_DATA_FOUND THEN
            -- no active sites present.

            -- Make the current site as Inactive.
            -- Bug 2306201: reset primary flag to 'N'
            -- and null out NOCOPY address components in hz_parties

            IF p_party_site_rec.status = 'I' THEN
              l_identifying_location_id := null;
              p_party_site_rec.identifying_address_flag := 'N';
            ELSIF p_party_site_rec.status = 'A' THEN
              -- if user is making the current location as active
              -- and the current location is the only active,
              -- visible location, make it as identifying address.

              l_identifying_location_id := db_location_id;
              p_party_site_rec.identifying_address_flag := 'Y';
            END IF;
      END;
      END IF;
    END IF;

    --denormalize primary address
    IF p_party_site_rec.identifying_address_flag IS NOT NULL THEN
      IF db_party_id <> -1 THEN
        do_update_address(
          db_party_id,
          l_identifying_location_id);
      END IF;
    END IF;

    if (p_party_site_rec.orig_system is not null
         and p_party_site_rec.orig_system <>fnd_api.g_miss_char)
        and (p_party_site_rec.orig_system_reference is not null
         and p_party_site_rec.orig_system_reference <>fnd_api.g_miss_char)
    then
                p_party_site_rec.orig_system_reference := null;
                -- In mosr, we have bypassed osr nonupdateable validation
                -- but we should not update existing osr, set it to null
      end if;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'HZ_PARTY_SITES_PKG.Update_Row (+) ',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    --Call to table-handler
    HZ_PARTY_SITES_PKG.Update_Row (
        X_Rowid                                 => l_rowid,
        X_PARTY_SITE_ID                         => p_party_site_rec.party_site_id,
        X_PARTY_ID                              => p_party_site_rec.party_id,
        X_LOCATION_ID                           => p_party_site_rec.location_id,
        X_PARTY_SITE_NUMBER                     => p_party_site_rec.party_site_number,
        X_ATTRIBUTE_CATEGORY                    => p_party_site_rec.attribute_category,
        X_ATTRIBUTE1                            => p_party_site_rec.attribute1,
        X_ATTRIBUTE2                            => p_party_site_rec.attribute2,
        X_ATTRIBUTE3                            => p_party_site_rec.attribute3,
        X_ATTRIBUTE4                            => p_party_site_rec.attribute4,
        X_ATTRIBUTE5                            => p_party_site_rec.attribute5,
        X_ATTRIBUTE6                            => p_party_site_rec.attribute6,
        X_ATTRIBUTE7                            => p_party_site_rec.attribute7,
        X_ATTRIBUTE8                            => p_party_site_rec.attribute8,
        X_ATTRIBUTE9                            => p_party_site_rec.attribute9,
        X_ATTRIBUTE10                           => p_party_site_rec.attribute10,
        X_ATTRIBUTE11                           => p_party_site_rec.attribute11,
        X_ATTRIBUTE12                           => p_party_site_rec.attribute12,
        X_ATTRIBUTE13                           => p_party_site_rec.attribute13,
        X_ATTRIBUTE14                           => p_party_site_rec.attribute14,
        X_ATTRIBUTE15                           => p_party_site_rec.attribute15,
        X_ATTRIBUTE16                           => p_party_site_rec.attribute16,
        X_ATTRIBUTE17                           => p_party_site_rec.attribute17,
        X_ATTRIBUTE18                           => p_party_site_rec.attribute18,
        X_ATTRIBUTE19                           => p_party_site_rec.attribute19,
        X_ATTRIBUTE20                           => p_party_site_rec.attribute20,
        X_ORIG_SYSTEM_REFERENCE                 => p_party_site_rec.orig_system_reference,
        X_LANGUAGE                              => p_party_site_rec.language,
        X_MAILSTOP                              => p_party_site_rec.mailstop,
        X_IDENTIFYING_ADDRESS_FLAG              => p_party_site_rec.identifying_address_flag,
        X_STATUS                                => p_party_site_rec.status,
        X_PARTY_SITE_NAME                       => p_party_site_rec.party_site_name,
        X_ADDRESSEE                             => p_party_site_rec.addressee,
        X_OBJECT_VERSION_NUMBER                 => p_object_version_number,
        X_CREATED_BY_MODULE                     => p_party_site_rec.created_by_module,
        X_APPLICATION_ID                        => p_party_site_rec.application_id,
        -- Bug 2197181 : actual_content_source is non-updateable.
        X_ACTUAL_CONTENT_SOURCE                 => NULL,
        -- Bug 3175816
        X_GLOBAL_LOCATION_NUMBER                => p_party_site_rec.global_location_number,
        X_DUNS_NUMBER_C                         => p_party_site_rec.duns_number_c
    );

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'HZ_PARTY_SITES_PKG.Update_Row (-) ',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;
    --
    --- If old and new statuses are different, then call
    --- the cascade_site_status_changes procedure to synch
    --- the party site and account status.
    --
        IF  p_party_site_rec.status <> db_status THEN
    -- Code modified for Bug 3714636 starts here
          IF(g_message_name is null) THEN
          BEGIN
            SELECT 'X' into g_message_name FROM FND_NEW_MESSAGES
            WHERE  message_name  = 'HZ_INACTIVATE_ACCOUNT_SITE_UI'
            AND language_code = userenv('LANG')
            AND application_id = 222
            AND    rownum =1;
          EXCEPTION
                WHEN NO_DATA_FOUND THEN
                FND_MESSAGE.SET_NAME('AR', 'HZ_API_NO_RECORD');
                FND_MESSAGE.SET_TOKEN('RECORD', 'Message Name');
                --FND_MESSAGE.SET_TOKEN('VALUE', NVL(TO_CHAR(p_party_site_use_rec.party_site_id), 'null'));
                FND_MSG_PUB.ADD;
                RAISE FND_API.G_EXC_ERROR;
          END;
          END IF;
          IF g_message_name IS NOT NULL THEN
    -- Code modified for Bug 3714636 ends here
                cascade_site_status_changes(p_party_site_rec.party_site_id,
                                                                   p_party_site_rec.status,
                                                                   x_return_status);
           END IF;
        END IF;

    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=> 'do_update_party_site (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

END do_update_party_site;


/*===========================================================================+
 | PROCEDURE
 |              do_create_party_site_use
 |
 | DESCRIPTION
 |              Creates party_site_use.
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |              OUT:
 |                    x_party_site_use_id
 |          IN/ OUT:
 |                    p_party_site_use_rec
 |                    x_return_status
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |  10-NOV-2003  Rajib Ranjan Borah   o Bug 2065191.While creation,set record to primary
 |                                      only if this is the first active record for the
 |                                      site_use_type of given party.
 |                                      Commented out unused variables and redundant code.
 +===========================================================================*/

PROCEDURE do_create_party_site_use(
    p_party_site_use_rec    IN OUT  NOCOPY PARTY_SITE_USE_REC_TYPE,
    x_party_site_use_id     OUT NOCOPY     NUMBER,
    x_return_status         IN OUT NOCOPY  VARCHAR2
) IS

    l_party_site_use_id             NUMBER := p_party_site_use_rec.party_site_use_id;
    l_rowid                         ROWID := NULL;
-- Bug 2065191
--    l_count                         NUMBER;
    l_exist                         VARCHAR2(1) := 'N';
    l_party_id                      NUMBER;
-- Bug 2065191
--    l_primary_per_type              VARCHAR2(1) := p_party_site_use_rec.primary_per_type;
--    l_msg_count                     NUMBER;
--    l_msg_data                      VARCHAR2(2000);
    l_dummy                         VARCHAR2(1);
    l_debug_prefix                  VARCHAR2(30) := '';

BEGIN

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'do_create_party_site_use (+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- if primary key value is passed, check for uniqueness.
    IF l_party_site_use_id IS NOT NULL AND
        l_party_site_use_id <> FND_API.G_MISS_NUM
    THEN
        BEGIN
            SELECT 'Y'
            INTO   l_dummy
            FROM   HZ_PARTY_SITE_USES
            WHERE  PARTY_SITE_USE_ID = l_party_site_use_id;

            FND_MESSAGE.SET_NAME('AR', 'HZ_API_DUPLICATE_COLUMN');
            FND_MESSAGE.SET_TOKEN('COLUMN', 'party_site_use_id');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;

        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                NULL;
        END;
    END IF;

    HZ_REGISTRY_VALIDATE_V2PUB.validate_party_site_use(
                                               'C',
                                               p_party_site_use_rec,
                                               l_rowid,
                                               x_return_status);

    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;


-- Bug 2065191
    IF p_party_site_use_rec.status = 'A'
    OR p_party_site_use_rec.status IS NULL
    OR p_party_site_use_rec.status = FND_API.G_MISS_CHAR
    THEN
    -- if this is the first active party site use per type,,
    -- we need to  mark it with primary_per_type = 'Y'.
    SELECT PARTY_ID
    INTO   l_party_id
    FROM   HZ_PARTY_SITES
    WHERE  PARTY_SITE_ID = p_party_site_use_rec.party_site_id;


    BEGIN
        SELECT 'Y'
        INTO   l_exist
        FROM   HZ_PARTY_SITE_USES SU
        WHERE  PARTY_SITE_ID IN (
                                 SELECT PARTY_SITE_ID
                                 FROM   HZ_PARTY_SITES PS
                                 WHERE  PS.PARTY_ID = l_party_id )
        AND    SU.SITE_USE_TYPE = p_party_site_use_rec.site_use_type
        AND STATUS = 'A' -- Bug 2065191
        AND ROWNUM = 1;

        IF p_party_site_use_rec.primary_per_type = 'Y' THEN
            -- unmark the previous site uses whose primary_per_type = 'Y'.
            do_unmark_primary_per_type(
                                       l_party_id,
                                       p_party_site_use_rec.party_site_id,
                                       p_party_site_use_rec.site_use_type, 'I' );

        END IF;
    EXCEPTION
        --this is a new site use type
        WHEN NO_DATA_FOUND THEN
          --  l_primary_per_type := 'Y';-- Bug 2065191
          p_party_site_use_rec.primary_per_type:='Y';
    END;
--    p_party_site_use_rec.primary_per_type := l_primary_per_type;--Bug 2065191.
    END IF;-- end if corresponding to if added for bug 2065191.

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'HZ_PARTY_SITE_USES_PKG.Insert_Row (+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- call table-handler.
    HZ_PARTY_SITE_USES_PKG.Insert_Row (
        X_PARTY_SITE_USE_ID                     => p_party_site_use_rec.party_site_use_id,
        X_COMMENTS                              => p_party_site_use_rec.comments,
        X_PARTY_SITE_ID                         => p_party_site_use_rec.party_site_id,
        X_SITE_USE_TYPE                         => p_party_site_use_rec.site_use_type,
        X_PRIMARY_PER_TYPE                      => p_party_site_use_rec.primary_per_type,
        X_STATUS                                => p_party_site_use_rec.status,
        X_OBJECT_VERSION_NUMBER                 => 1,
        X_CREATED_BY_MODULE                     => p_party_site_use_rec.created_by_module,
        X_APPLICATION_ID                        => p_party_site_use_rec.application_id
    );

    x_party_site_use_id := p_party_site_use_rec.party_site_use_id;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'HZ_PARTY_SITE_USES_PKG.Insert_Row (-) ' ||
                                           'x_party_site_use_id = ' || x_party_site_use_id,
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'do_create_party_site_use (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

END do_create_party_site_use;


/*===========================================================================+
 | PROCEDURE
 |              do_update_party_site_use
 |
 | DESCRIPTION
 |              Updates party_site_use.
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |              OUT:
 |          IN/ OUT:
 |                    p_party_site_use_rec
 |                    x_return_status
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 +===========================================================================*/

PROCEDURE do_update_party_site_use(
    p_party_site_use_rec             IN OUT  NOCOPY PARTY_SITE_USE_REC_TYPE,
    p_object_version_number          IN OUT NOCOPY  NUMBER,
    x_return_status                  IN OUT NOCOPY  VARCHAR2
) IS

    l_object_version_number                  NUMBER;
    l_rowid                                  ROWID;
    l_party_id                               NUMBER;
    l_party_site_id                          NUMBER;
    -- Bug Fix: 3651716
    l_dup_rowid                              ROWID;
    l_status                                 HZ_PARTY_SITE_USES.STATUS%TYPE;
    l_site_use_type                          HZ_PARTY_SITE_USES.SITE_USE_TYPE%TYPE;
    l_primary_per_type                       HZ_PARTY_SITE_USES.PRIMARY_PER_TYPE%TYPE;
    l_msg_count                              NUMBER;
    l_msg_data                               VARCHAR2(2000);
    l_debug_prefix                           VARCHAR2(30) := '';

BEGIN

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'do_update_party_site_use (+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- check whether record has been updated by another user. If not, lock it.
    BEGIN
        SELECT OBJECT_VERSION_NUMBER,
               PARTY_SITE_ID,
               SITE_USE_TYPE,
               PRIMARY_PER_TYPE,
               STATUS,
               ROWID
        INTO   l_object_version_number,
               l_party_site_id,
               l_site_use_type,
               l_primary_per_type,
               l_status,
               l_rowid
        FROM   HZ_PARTY_SITE_USES
        WHERE  PARTY_SITE_USE_ID = p_party_site_use_rec.party_site_use_id
        FOR UPDATE OF PARTY_SITE_USE_ID NOWAIT;

        IF NOT
            (
             (p_object_version_number IS NULL AND l_object_version_number IS NULL)
             OR
             (p_object_version_number IS NOT NULL AND
              l_object_version_number IS NOT NULL AND
              p_object_version_number = l_object_version_number
             )
            )
        THEN
            FND_MESSAGE.SET_NAME('AR', 'HZ_API_RECORD_CHANGED');
            FND_MESSAGE.SET_TOKEN('TABLE', 'HZ_PARTY_SITE_USES');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        END IF;

        p_object_version_number := nvl(l_object_version_number, 1) + 1;

    EXCEPTION WHEN NO_DATA_FOUND THEN
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_NO_RECORD');
        FND_MESSAGE.SET_TOKEN('RECORD', 'party site use');
        FND_MESSAGE.SET_TOKEN('VALUE', NVL(TO_CHAR(p_party_site_use_rec.party_site_use_id), 'null'));
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END;

    -- unmark the previous site uses whose primary_per_type = 'Y'.
    BEGIN
    -- Modified for Bug Fix: 3651716
        SELECT PARTY_ID
        INTO   l_party_id
        FROM   HZ_PARTY_SITES
        WHERE  PARTY_SITE_ID = l_party_site_id;

        IF      p_party_site_use_rec.primary_per_type = 'Y' AND
                p_party_site_use_rec.status = 'I' AND
                /* Bug Fix: 4203495 */
                l_primary_per_type <> 'Y'
                THEN
                        NULL;
        ELSIF   p_party_site_use_rec.primary_per_type = 'Y' AND
                l_primary_per_type <> 'Y'
                THEN
                        do_unmark_primary_per_type(
                                                l_party_id,
                                                l_party_site_id,
                                                l_site_use_type, 'U' );

        ELSE
            -- ignore the value of primary per type flag if the flag has been
            -- set to 'N' or NULL by passing FND_API.G_MISS_CHAR.
            -- user can not unset a primary per type flag by passing value 'N' or NULL.
            -- to unset a primary flag, he/she needs to select another site use as primary.
            -- This site use will be unmarked automatically.
                p_party_site_use_rec.primary_per_type := NULL;

            -- Bug Fix: 3651716
                IF (l_status = 'A' AND
                    p_party_site_use_rec.status = 'I' AND
                    l_primary_per_type = 'Y' ) OR
                   (l_status = 'I' AND
                    p_party_site_use_rec.status = 'A')
                THEN
                BEGIN
                -- Check if any other active party site use exists
                        SELECT  ROWID
                        INTO    l_dup_rowid
                        FROM    HZ_PARTY_SITE_USES
                        WHERE   PARTY_SITE_USE_ID = (
                                SELECT  min(PARTY_SITE_USE_ID)
                                FROM    HZ_PARTY_SITE_USES
                                WHERE   PARTY_SITE_ID IN (
                                                         SELECT PARTY_SITE_ID
                                                         FROM   HZ_PARTY_SITES
                                                         WHERE  PARTY_ID = l_party_id )
                                AND     STATUS = 'A'
                                AND     SITE_USE_TYPE = l_site_use_type
                                AND     PARTY_SITE_USE_ID <> p_party_site_use_rec.party_site_use_id);

                        IF      p_party_site_use_rec.status = 'I' THEN
                        UPDATE  HZ_PARTY_SITE_USES
                        SET     PRIMARY_PER_TYPE = 'Y',
                                last_update_date = hz_utility_v2pub.last_update_date,
                                last_updated_by  = hz_utility_v2pub.last_updated_by,
                                last_update_login= hz_utility_v2pub.last_update_login,
                                request_id       = hz_utility_v2pub.request_id,
                                program_id       = hz_utility_v2pub.program_id,
                                program_application_id = hz_utility_v2pub.program_application_id,
                                program_update_date    = hz_utility_v2pub.program_update_date
                        WHERE   ROWID = l_dup_rowid;
                                p_party_site_use_rec.primary_per_type := 'N';
                        END IF;
                EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                                IF      p_party_site_use_rec.status = 'I' THEN
                                        p_party_site_use_rec.primary_per_type := 'N';
                                ELSIF   p_party_site_use_rec.status = 'A' THEN
                                        p_party_site_use_rec.primary_per_type := 'Y';
                                END IF;
                END;
                END IF;
        END IF;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            FND_MESSAGE.SET_NAME('AR', 'HZ_API_INVALID_FK');
            FND_MESSAGE.SET_TOKEN('FK', 'party site id');
            FND_MESSAGE.SET_TOKEN('COLUMN', 'party site id');
            FND_MESSAGE.SET_TOKEN('TABLE', 'hz_party_sites');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
    END;

    -- call for validations.
    -- Moved the validation for Bug Fix: 3651716
    HZ_REGISTRY_VALIDATE_V2PUB.validate_party_site_use(
                                               'U',
                                               p_party_site_use_rec,
                                               l_rowid,
                                               x_return_status);

    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'HZ_PARTY_SITE_USES_PKG.Update_Row (+) ',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;



    -- call to table-handler
    HZ_PARTY_SITE_USES_PKG.Update_Row (
        X_Rowid                                 => l_rowid,
        X_PARTY_SITE_USE_ID                     => p_party_site_use_rec.party_site_use_id,
        X_COMMENTS                              => p_party_site_use_rec.comments,
        X_PARTY_SITE_ID                         => p_party_site_use_rec.party_site_id,
        X_SITE_USE_TYPE                         => p_party_site_use_rec.site_use_type,
        X_PRIMARY_PER_TYPE                      => p_party_site_use_rec.primary_per_type,
        X_STATUS                                => p_party_site_use_rec.status,
        X_OBJECT_VERSION_NUMBER                 => p_object_version_number,
        X_CREATED_BY_MODULE                     => p_party_site_use_rec.created_by_module,
        X_APPLICATION_ID                        => p_party_site_use_rec.application_id
    );

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'HZ_PARTY_SITE_USES_PKG.Update_Row (-) ',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'do_update_party_site_use (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

END do_update_party_site_use;


/*===========================================================================+
 | PROCEDURE
 |              do_update_address
 |
 | DESCRIPTION
 |              Denormalize identifying address to hz_parties
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    p_party_id
 |                    p_location_id
 |              OUT:
 |          IN/ OUT:
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | 13-APR-2003  P.Suresh           o Bug No 2820991. Populated the who columns when
 |                                   denormalizing address into hz_parties.
 +===========================================================================*/

PROCEDURE do_update_address(
    p_party_id                      IN    NUMBER,
    p_location_id                   IN    NUMBER
) IS

    CURSOR c_loc IS
      SELECT * FROM hz_locations
      WHERE location_id = p_location_id;

    CURSOR c_party IS
      SELECT 'Y'
      FROM hz_parties
      WHERE party_id = p_party_id
      FOR UPDATE NOWAIT;

    l_location_rec                  c_loc%ROWTYPE;
    l_exists                        VARCHAR2(1);

BEGIN

    --check if party record is locked by any one else.
    BEGIN
      OPEN c_party;
      FETCH c_party INTO l_exists;
      CLOSE c_party;
    EXCEPTION
      WHEN OTHERS THEN
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_RECORD_CHANGED');
        FND_MESSAGE.SET_TOKEN('TABLE', 'HZ_PARTIES');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END;

    -- if location_id is null, we will null out NOCOPY the location
    -- components in hz_parties.

    IF p_location_id IS NULL THEN
      l_location_rec.country     := NULL;
      l_location_rec.address1    := NULL;
      l_location_rec.address2    := NULL;
      l_location_rec.address3    := NULL;
      l_location_rec.address4    := NULL;
      l_location_rec.city        := NULL;
      l_location_rec.postal_code := NULL;
      l_location_rec.state       := NULL;
      l_location_rec.province    := NULL;
      l_location_rec.county      := NULL;

      -- Bug 2197181: After Mix-n-Match project, the de-normalized address can be a non-USER_ENTERED
      -- address. Therefore, commenting out NOCOPY the below statement.

      -- l_location_rec.content_source_type := 'USER_ENTERED';
    ELSE
      --Open the cursor and fetch location components and
      --content_source_type.

      OPEN c_loc;
      FETCH c_loc INTO l_location_rec;
      CLOSE c_loc;
    END IF;

    -- Bug 2197181: After Mix-n-Match project, the de-normalized address can be a non-USER_ENTERED
    -- address. Therefore, commenting out NOCOPY the below 'IF' condition.

    -- IF l_location_rec.content_source_type = 'USER_ENTERED' THEN

    UPDATE hz_parties
    SET    country              = l_location_rec.country,
           address1             = l_location_rec.address1,
           address2             = l_location_rec.address2,
           address3             = l_location_rec.address3,
           address4             = l_location_rec.address4,
           city                 = l_location_rec.city,
           postal_code          = l_location_rec.postal_code,
           state                = l_location_rec.state,
           province             = l_location_rec.province,
           county               = l_location_rec.county,
           last_update_date     = hz_utility_v2pub.last_update_date,
           last_updated_by      = hz_utility_v2pub.last_updated_by,
           last_update_login    = hz_utility_v2pub.last_update_login,
           request_id           = hz_utility_v2pub.request_id,
           program_id           = hz_utility_v2pub.program_id,
           program_application_id = hz_utility_v2pub.program_application_id,
           program_update_date  = hz_utility_v2pub.program_update_date
    WHERE party_id = p_party_id;

END do_update_address;

/*===========================================================================+
 | PROCEDURE
 |              do_unmark_address_flag
 |
 | DESCRIPTION
 |              unmark the identifying_address_flag in hz_party_sites
 |              for those party sites that are not identifying for
 |              each party.
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    p_party_id
 |                    p_party_site_id
 |                    p_mode
 |              OUT:
 |          IN/ OUT:
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |    Jianying Huang   28-SEP-00  Created. See bug 1403010.
 |    Jianying Huang   28-FEB-01  Modified the update statement to use rowid
 |                                to do updating.
 |    Rajib R Borah    16-SEP-03  Updated the who columns.
 |    Ramesh Ch        28-OCT-03  Removed  created_by and creation_date
 |                                columns during update.
 |    avjha  	     11-JUL-06  Bug 5203798: Populate BOT incase of direct update.
 +===========================================================================*/

PROCEDURE do_unmark_address_flag(
    p_party_id                      IN     NUMBER,
    p_party_site_id                 IN     NUMBER := NULL,
    p_mode                	      IN     VARCHAR2 := NULL
) IS

    CURSOR c_party_sites IS
      SELECT rowid, party_site_id
      FROM hz_party_sites
      WHERE party_id = p_party_id
      AND party_site_id <> nvl(p_party_site_id,-999)
      AND identifying_address_flag = 'Y'
      AND rownum = 1
      FOR UPDATE NOWAIT;

    l_rowid                    VARCHAR2(100);
    l_party_site_id	       NUMBER;
BEGIN


    --check if party record is locked by any one else.
    BEGIN
      OPEN c_party_sites;
      FETCH c_party_sites INTO l_rowid, l_party_site_id;
      CLOSE c_party_sites;
    EXCEPTION
      WHEN OTHERS THEN
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_RECORD_CHANGED');
        FND_MESSAGE.SET_TOKEN('TABLE', 'HZ_PARTY_SITES');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END;

    IF l_rowid IS NOT NULL THEN
      UPDATE hz_party_sites
      SET  identifying_address_flag= 'N',
      --Bug number 2914238 .Updated the who columns.
           last_update_date        = hz_utility_v2pub.last_update_date,
           last_updated_by         = hz_utility_v2pub.last_updated_by,
           last_update_login       = hz_utility_v2pub.last_update_login,
           request_id              = hz_utility_v2pub.request_id,
           program_id              = hz_utility_v2pub.program_id,
           program_application_id  = hz_utility_v2pub.program_application_id,
           program_update_date     = hz_utility_v2pub.program_update_date
      WHERE rowid = l_rowid;

--bug #5203798
      IF(HZ_UTILITY_V2PUB.G_EXECUTE_API_CALLOUTS in ('EVENTS_ENABLED', 'BO_EVENTS_ENABLED')) THEN
        -- populate function for integration service
        HZ_POPULATE_BOT_PKG.pop_hz_party_sites(
          p_operation     => p_mode,
          p_party_site_id => l_party_site_id);
      END IF;

    END IF;

END do_unmark_address_flag;

/*===========================================================================+
 | PROCEDURE
 |              do_unmark_primary_per_type
 |
 | DESCRIPTION
 |              unmark the primary_per_type in hz_party_site_uses
 |              for those site uses that are not primary for
 |              each party.
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    p_party_id
 |                    p_party_site_id
 |                    p_site_use_type
 |                    p_mode
 |              OUT:
 |          IN/ OUT:
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |   28-OCT-2003     Ramesh Ch       Bug#2914238. Updated who columns.
 |   11-JUL-06  	   avjha		 Bug 5203798: Populate BOT incase of direct update.
 |
 +===========================================================================*/

PROCEDURE do_unmark_primary_per_type(
    p_party_id                      IN     NUMBER,
    p_party_site_id                 IN     NUMBER,
    p_site_use_type                 IN     VARCHAR2,
    p_mode                          IN     VARCHAR2 := NULL
) IS

    CURSOR c_party_site_uses IS
      SELECT ROWID, PARTY_SITE_USE_ID
      FROM   HZ_PARTY_SITE_USES SU
      WHERE  SU.PARTY_SITE_ID IN (
               SELECT PS.PARTY_SITE_ID
               FROM   HZ_PARTY_SITES PS
               WHERE  PARTY_ID = p_party_id )
      AND    SU.PARTY_SITE_ID <> p_party_site_id
      AND    SU.SITE_USE_TYPE = p_site_use_type
      AND    SU.PRIMARY_PER_TYPE = 'Y'
      AND    ROWNUM = 1
      FOR UPDATE NOWAIT;

    l_rowid               VARCHAR2(100);
    l_party_site_use_id	  NUMBER;
BEGIN

    -- check if party site use record is locked by any one else.
    -- notice the combination of party_site_id and site_use_type
    -- is unique.

    BEGIN
      OPEN c_party_site_uses;
      FETCH c_party_site_uses INTO l_rowid, l_party_site_use_id;
      CLOSE c_party_site_uses;
    EXCEPTION
      WHEN OTHERS THEN
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_RECORD_CHANGED');
        FND_MESSAGE.SET_TOKEN('TABLE', 'HZ_PARTY_SITE_USES');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END;

    IF l_rowid IS NOT NULL THEN
      UPDATE HZ_PARTY_SITE_USES
      SET    PRIMARY_PER_TYPE = 'N',
             last_update_date     = hz_utility_v2pub.last_update_date,
             last_updated_by      = hz_utility_v2pub.last_updated_by,
             last_update_login    = hz_utility_v2pub.last_update_login,
             request_id           = hz_utility_v2pub.request_id,
             program_id           = hz_utility_v2pub.program_id,
             program_application_id = hz_utility_v2pub.program_application_id,
             program_update_date  = hz_utility_v2pub.program_update_date
      WHERE  ROWID = l_rowid;

--bug #5203798
      IF(HZ_UTILITY_V2PUB.G_EXECUTE_API_CALLOUTS in ('EVENTS_ENABLED', 'BO_EVENTS_ENABLED')) THEN
        -- populate function for integration service
        HZ_POPULATE_BOT_PKG.pop_hz_party_site_uses(
          p_operation     => p_mode,
          p_party_site_use_id => l_party_site_use_id);
      END IF;
    END IF;

END do_unmark_primary_per_type;


----------------------------
-- body of public procedures
----------------------------

/*===========================================================================+
 | PROCEDURE
 |              create_party_site
 |
 | DESCRIPTION
 |              Creates party_site.
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    p_init_msg_list
 |                    p_party_site_rec
 |              OUT:
 |                    x_return_status
 |                    x_msg_count
 |                    x_msg_data
 |                    x_party_site_id
 |                    x_party_site_number
 |          IN/ OUT:
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |
 |   04-JAN-2005    Rajib Ranjan Borah      o SSM SST Integration and Extension.
 |                                            For non-profile entities, the concept of
 |                                            select/de-select data-sources is obsoleted.
 |
 +===========================================================================*/

PROCEDURE create_party_site (
    p_init_msg_list         IN      VARCHAR2 := FND_API.G_FALSE,
    p_party_site_rec        IN      PARTY_SITE_REC_TYPE,
    x_party_site_id         OUT NOCOPY     NUMBER,
    x_party_site_number     OUT NOCOPY     VARCHAR2,
    x_return_status         OUT NOCOPY     VARCHAR2,
    x_msg_count             OUT NOCOPY     NUMBER,
    x_msg_data              OUT NOCOPY     VARCHAR2
) IS

    l_api_name             CONSTANT VARCHAR2(30) := 'create_party_site';
    l_party_site_rec                PARTY_SITE_REC_TYPE := p_party_site_rec;


    dss_return_status VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
    dss_msg_count     NUMBER := 0;
    dss_msg_data      VARCHAR2(2000):= null;
    l_test_security   VARCHAR2(1):= 'F';
    l_debug_prefix    VARCHAR2(30) := '';

BEGIN
    -- standard start of API savepoint
    SAVEPOINT create_party_site;

    -- Check if API is called in debug mode. If yes, enable debug.
    --enable_debug;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'create_party_site (+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Bug 2197181: added for mix-n-match project. first load data
    -- sources for this entity.

    -- Bug 2444678: Removed caching.

    -- IF g_pst_mixnmatch_enabled IS NULL THEN
/* SSM SST Integration and Extension
 * For non-profile entities, the concept of select/de-select data-sources is obsoleted.

    HZ_MIXNM_UTILITY.LoadDataSources(
      p_entity_name                    => 'HZ_LOCATIONS',
      p_entity_attr_id                 => g_pst_entity_attr_id,
      p_mixnmatch_enabled              => g_pst_mixnmatch_enabled,
      p_selected_datasources           => g_pst_selected_datasources );
*/
    -- END IF;

    -- report error on obsolete columns based on profile
    IF NVL(FND_PROFILE.VALUE('HZ_API_ERR_ON_OBSOLETE_COLUMN'), 'Y') = 'Y' THEN
      check_obsolete_columns (
        p_create_update_flag         => 'C',
        p_party_site_rec             => l_party_site_rec,
        x_return_status              => x_return_status
      );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;

    -- call to business logic.
    do_create_party_site(
                         l_party_site_rec,
                         x_party_site_id,
                         x_party_site_number,
                         x_return_status
                        );

    -- Bug 2486394 -Check if the DSS security is granted to the user
    -- Bug 3818648: check dss profile before call 3.
    --
    IF NVL(fnd_profile.value('HZ_DSS_ENABLED'), 'N') = 'Y' THEN
      l_test_security :=
           hz_dss_util_pub.test_instance(
                  p_operation_code     => 'INSERT',
                  p_db_object_name     => 'HZ_PARTY_SITES',
                  p_instance_pk1_value => x_party_site_id,
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
                              fnd_message.get_string('AR', 'HZ_DSS_PARTY_ADDRESSES'));
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
      end if;
    END IF;

    -- Invoke business event system.

    -- SSM SST Integration and Extension
    -- For non-profile entities, the concept of select/de-select data-sources is obsoleted.
    -- There is no need to check if the data-source is selected.

    IF x_return_status =  FND_API.G_RET_STS_SUCCESS /* AND
       -- Bug 2197181: Added below condition for Mix-n-Match
       g_pst_is_datasource_selected = 'Y'*/
    THEN
      IF(HZ_UTILITY_V2PUB.G_EXECUTE_API_CALLOUTS in ('EVENTS_ENABLED', 'Y')) THEN
        HZ_BUSINESS_EVENT_V2PVT.create_party_site_event (
          l_party_site_rec );
      END IF;

      IF(HZ_UTILITY_V2PUB.G_EXECUTE_API_CALLOUTS in ('EVENTS_ENABLED', 'BO_EVENTS_ENABLED')) THEN
        -- populate function for integration service
        HZ_POPULATE_BOT_PKG.pop_hz_party_sites(
          p_operation     => 'I',
          p_party_site_id => x_party_site_id);
      END IF;

      -- Call to indicate Party Site creation to DQM
      --Bug 4866187
      --Bug 5370799
      IF (p_party_site_rec.orig_system IS NULL OR  p_party_site_rec.orig_system=FND_API.G_MISS_CHAR ) THEN
        HZ_DQM_SYNC.sync_party_site(l_party_site_rec.party_site_id,'C');
      END IF;
    END IF;

    -- standard call to get message count and if count is 1, get message info.
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
        hz_utility_v2pub.debug(p_message=>'create_party_site (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Check if API is called in debug mode. If yes, disable debug.
    --disable_debug;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO create_party_site;
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
            hz_utility_v2pub.debug(p_message=>'create_party_site (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
        END IF;

        -- Check if API is called in debug mode. If yes, disable debug.
        --disable_debug;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO create_party_site;
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
           hz_utility_v2pub.debug(p_message=>'create_party_site (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
        END IF;

        -- Check if API is called in debug mode. If yes, disable debug.
        --disable_debug;

    WHEN OTHERS THEN
        ROLLBACK TO create_party_site;
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
            hz_utility_v2pub.debug(p_message=>'create_party_site (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
        END IF;

        -- Check if API is called in debug mode. If yes, disable debug.
        --disable_debug;

END create_party_site;


/*===========================================================================+
 | PROCEDURE
 |              update_party_site
 |
 | DESCRIPTION
 |              Updates party_site.
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    p_init_msg_list
 |                    p_party_site_rec
 |              OUT:
 |                    x_return_status
 |                    x_msg_count
 |                    x_msg_data
 |          IN/ OUT:
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |
 |   04-JAN-2005    Rajib Ranjan Borah      o SSM SST Integration and Extension.
 |                                            For non-profile entities, the concept of
 |                                            select/de-select data-sources is obsoleted.
 +===========================================================================*/

PROCEDURE update_party_site (
    p_init_msg_list               IN      VARCHAR2 :=  FND_API.G_FALSE,
    p_party_site_rec              IN      PARTY_SITE_REC_TYPE,
    p_object_version_number       IN OUT NOCOPY  NUMBER,
    x_return_status               OUT NOCOPY     VARCHAR2,
    x_msg_count                   OUT NOCOPY     NUMBER,
    x_msg_data                    OUT NOCOPY     VARCHAR2
) IS

    l_api_name            CONSTANT VARCHAR2(30) := 'update_party_site';
    l_party_site_rec               PARTY_SITE_REC_TYPE := p_party_site_rec;
    l_old_party_site_rec           PARTY_SITE_REC_TYPE;

    dss_return_status VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
    dss_msg_count     NUMBER := 0;
    dss_msg_data      VARCHAR2(2000):= null;
    l_test_security   VARCHAR2(1):= 'F';
    l_release_name        VARCHAR2(50);
    l_dummy           VARCHAR2(1);
    l_debug_prefix    VARCHAR2(30) := '';
BEGIN

    -- standard start of API savepoint
    SAVEPOINT update_party_site;

    -- Check if API is called in debug mode. If yes, enable debug.
    --enable_debug;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'update_party_site (+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

        -- if party_site_id is not passed in, but orig system parameters are passed in
    -- get party_id

      IF (p_party_site_rec.orig_system is not null
         and p_party_site_rec.orig_system <>fnd_api.g_miss_char)
       and (p_party_site_rec.orig_system_reference is not null
         and p_party_site_rec.orig_system_reference <>fnd_api.g_miss_char)
       and (p_party_site_rec.party_site_id = FND_API.G_MISS_NUM or p_party_site_rec.party_site_id is null) THEN
           hz_orig_system_ref_pub.get_owner_table_id
                        (p_orig_system => p_party_site_rec.orig_system,
                        p_orig_system_reference => p_party_site_rec.orig_system_reference,
                        p_owner_table_name => 'HZ_PARTY_SITES',
                        x_owner_table_id => l_party_site_rec.party_site_id,
                        x_return_status => x_return_status);
            IF x_return_status <> fnd_api.g_ret_sts_success THEN
                RAISE FND_API.G_EXC_ERROR;
            END IF;
      END IF;


    -- Get old records. Will be used by business event system.
    get_party_site_rec (
        p_party_site_id                      => l_party_site_rec.party_site_id,
        x_party_site_rec                     => l_old_party_site_rec,
        x_return_status                      => x_return_status,
        x_msg_count                          => x_msg_count,
        x_msg_data                           => x_msg_data );

    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --- Bug 2486394 Check if the DSS security is granted to the user
    -- Bug 3818648: check dss profile before call test_instance.
    --
    IF NVL(fnd_profile.value('HZ_DSS_ENABLED'), 'N') = 'Y' THEN
      l_test_security :=
           hz_dss_util_pub.test_instance(
                  p_operation_code     => 'UPDATE',
                  p_db_object_name     => 'HZ_PARTY_SITES',
                  p_instance_pk1_value => l_party_site_rec.party_site_id,
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
                              fnd_message.get_string('AR', 'HZ_DSS_PARTY_ADDRESSES'));
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
      end if;
    END IF;

    -- Bug 2197181: added for mix-n-match project. first load data
    -- sources for this entity.

    -- Bug 2444678: Removed caching.

    -- IF g_pst_mixnmatch_enabled IS NULL THEN
/* SSM SST Integration and Extension
 * For non-profile entities, the concept of select/de-select data-sources is obsoleted.

    HZ_MIXNM_UTILITY.LoadDataSources(
      p_entity_name                    => 'HZ_LOCATIONS',
      p_entity_attr_id                 => g_pst_entity_attr_id,
      p_mixnmatch_enabled              => g_pst_mixnmatch_enabled,
      p_selected_datasources           => g_pst_selected_datasources );
*/
    -- END IF;

    -- report error on obsolete columns based on profile
    IF NVL(FND_PROFILE.VALUE('HZ_API_ERR_ON_OBSOLETE_COLUMN'), 'Y') = 'Y' THEN
      check_obsolete_columns (
        p_create_update_flag         => 'U',
        p_party_site_rec             => l_party_site_rec,
        p_old_party_site_rec         => l_old_party_site_rec,
        x_return_status              => x_return_status
      );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;

    -- call to business logic.
    do_update_party_site(
                         l_party_site_rec,
                         p_object_version_number,
                         x_return_status
                        );

    -- Invoke business event system.
    -- SSM SST Integration and Extension
    -- For non-profile entities, the concept of select/de-select data-sources is obsoleted.
    -- There is no need to check if the data-source is selected.

    IF x_return_status =  FND_API.G_RET_STS_SUCCESS /*AND
       -- Bug 2197181: added for mix-n-match project.
       g_pst_is_datasource_selected = 'Y'*/
    THEN
      l_old_party_site_rec.orig_system := l_party_site_rec.orig_system;
      IF(HZ_UTILITY_V2PUB.G_EXECUTE_API_CALLOUTS in ('EVENTS_ENABLED', 'Y')) THEN
        HZ_BUSINESS_EVENT_V2PVT.update_party_site_event (
          l_party_site_rec,
          l_old_party_site_rec );
      END IF;

      IF(HZ_UTILITY_V2PUB.G_EXECUTE_API_CALLOUTS in ('EVENTS_ENABLED', 'BO_EVENTS_ENABLED')) THEN
        -- populate function for integration service
        HZ_POPULATE_BOT_PKG.pop_hz_party_sites(
          p_operation     => 'U',
          p_party_site_id => l_party_site_rec.party_site_id);
      END IF;

      -- Call to indicate Party Site update to DQM
      HZ_DQM_SYNC.sync_party_site(l_party_site_rec.party_site_id,'U');
    END IF;

        --
        --- Check if 11.5.10 is installed in the system;if yes,then check for
        --- party site status in old and new record type.If changed then call
        --- update_acct_sites_status to update account site,site uses status
        --
        IF  l_party_site_rec.status <> l_old_party_site_rec.status THEN
    -- Code modified for Bug 3714636 starts here
          IF(g_message_name is null) THEN
          BEGIN
           SELECT 'X' into g_message_name FROM FND_NEW_MESSAGES
            WHERE  message_name  = 'HZ_INACTIVATE_ACCOUNT_SITE_UI'
            AND language_code = userenv('LANG')
            AND application_id = 222
            AND    rownum =1;
          EXCEPTION
                WHEN NO_DATA_FOUND THEN
                FND_MESSAGE.SET_NAME('AR', 'HZ_API_NO_RECORD');
                FND_MESSAGE.SET_TOKEN('RECORD', 'Message Name');
                --FND_MESSAGE.SET_TOKEN('VALUE', NVL(TO_CHAR(p_party_site_use_rec.party_site_id), 'null'));
                FND_MSG_PUB.ADD;
                RAISE FND_API.G_EXC_ERROR;
          END;
          END IF;
          --IF  l_release_name not in ( '11.5.1','11.5.2','11.5.3','11.5.4','11.5.5','11.5.6','11.5.7','11.5.8','11.5.9') THEN
            IF g_message_name IS NOT NULL THEN
    -- Code modified for Bug 3714636 ends here
                update_acct_sites_status(l_party_site_rec.party_site_id,
                                        l_party_site_rec.status,
                                        x_return_status);
--              IF x_return_status <> fnd_api.g_ret_sts_success THEN
--                      RAISE FND_API.G_EXC_ERROR;
--      END IF;

          END IF;
        END IF;

    -- standard call to get message count and if count is 1, get message info.
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
        hz_utility_v2pub.debug(p_message=>'update_party_site (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Check if API is called in debug mode. If yes, disable debug.
    --disable_debug;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO update_party_site;
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
            hz_utility_v2pub.debug(p_message=>'update_party_site (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
        END IF;


        -- Check if API is called in debug mode. If yes, disable debug.
        --disable_debug;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO update_party_site;
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
           hz_utility_v2pub.debug(p_message=>'update_party_site (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
        END IF;

        -- Check if API is called in debug mode. If yes, disable debug.
        --disable_debug;

    WHEN OTHERS THEN
        ROLLBACK TO update_party_site;
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
            hz_utility_v2pub.debug(p_message=>'update_party_site (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
        END IF;

        -- Check if API is called in debug mode. If yes, disable debug.
        --disable_debug;

END update_party_site;


/*===========================================================================+
 | PROCEDURE
 |              create_party_site_use
 |
 | DESCRIPTION
 |              Creates party_site_use.
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    p_init_msg_list
 |                    p_party_site_use_rec
 |              OUT:
 |                    x_return_status
 |                    x_msg_count
 |                    x_msg_data
 |                    x_party_site_use_id
 |          IN/ OUT:
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |    Rashmi Goyal   31-AUG-99  Created
 |
 +===========================================================================*/

PROCEDURE create_party_site_use (
    p_init_msg_list         IN     VARCHAR2 := FND_API.G_FALSE,
    p_party_site_use_rec    IN     PARTY_SITE_USE_REC_TYPE,
    x_party_site_use_id     OUT NOCOPY    NUMBER,
    x_return_status         OUT NOCOPY    VARCHAR2,
    x_msg_count             OUT NOCOPY    NUMBER,
    x_msg_data              OUT NOCOPY    VARCHAR2
) IS

    l_api_name            CONSTANT VARCHAR2(30) := 'create_party_site_use';
    l_party_site_use_rec           PARTY_SITE_USE_REC_TYPE := p_party_site_use_rec;
    l_debug_prefix                 VARCHAR2(30) := '';

BEGIN

    -- standard start of API savepoint
    SAVEPOINT create_party_site_use;

    -- Check if API is called in debug mode. If yes, enable debug.
    --enable_debug;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'create_party_site_use (+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;


    -- initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- call to business logic.
    do_create_party_site_use(
                             l_party_site_use_rec,
                             x_party_site_use_id,
                             x_return_status
                            );

   IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
     IF(HZ_UTILITY_V2PUB.G_EXECUTE_API_CALLOUTS in ('EVENTS_ENABLED', 'Y')) THEN
       -- Invoke business event system.
       HZ_BUSINESS_EVENT_V2PVT.create_party_site_use_event (
         l_party_site_use_rec );
     END IF;

     IF(HZ_UTILITY_V2PUB.G_EXECUTE_API_CALLOUTS in ('EVENTS_ENABLED', 'BO_EVENTS_ENABLED')) THEN
       -- populate function for integration service
       HZ_POPULATE_BOT_PKG.pop_hz_party_site_uses(
         p_operation         => 'I',
         p_party_site_use_id => x_party_site_use_id);
     END IF;
   END IF;

    -- standard call to get message count and if count is 1, get message info.
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
        hz_utility_v2pub.debug(p_message=>'create_party_site_use (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Check if API is called in debug mode. If yes, disable debug.
    --disable_debug;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO create_party_site_use;
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
            hz_utility_v2pub.debug(p_message=>'create_party_site_use (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
        END IF;

        -- Check if API is called in debug mode. If yes, disable debug.
        --disable_debug;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO create_party_site_use;
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
           hz_utility_v2pub.debug(p_message=>'create_party_site_use (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
        END IF;

        -- Check if API is called in debug mode. If yes, disable debug.
        --disable_debug;

    WHEN OTHERS THEN
        ROLLBACK TO create_party_site_use;
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
            hz_utility_v2pub.debug(p_message=>'create_party_site_use (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
        END IF;

        -- Check if API is called in debug mode. If yes, disable debug.
        --disable_debug;

END create_party_site_use;


/*===========================================================================+
 | PROCEDURE
 |              update_party_site_use
 |
 | DESCRIPTION
 |              Updates party_site_use.
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    p_init_msg_list
 |                    p_party_site_use_rec
 |              OUT:
 |                    x_return_status
 |                    x_msg_count
 |                    x_msg_data
 |          IN/ OUT:
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |
 +===========================================================================*/

PROCEDURE update_party_site_use (
    p_init_msg_list               IN     VARCHAR2 := FND_API.G_FALSE,
    p_party_site_use_rec          IN     PARTY_SITE_USE_REC_TYPE,
    p_object_version_number       IN OUT NOCOPY NUMBER,
    x_return_status               OUT NOCOPY    VARCHAR2,
    x_msg_count                   OUT NOCOPY    NUMBER,
    x_msg_data                    OUT NOCOPY    VARCHAR2
) IS

    l_api_name              CONSTANT    VARCHAR2(30) := 'update_party_site_use';
    l_party_site_use_rec                PARTY_SITE_USE_REC_TYPE := p_party_site_use_rec;
    l_old_party_site_use_rec            PARTY_SITE_USE_REC_TYPE;
    l_debug_prefix                      VARCHAR2(30) := '';

BEGIN

    -- standard start of API savepoint
    SAVEPOINT update_party_site_use;

    -- Check if API is called in debug mode. If yes, enable debug.
    --enable_debug;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'update_party_site_use (+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --2290537
    get_party_site_use_rec (
      p_party_site_use_id  => p_party_site_use_rec.party_site_use_id,
      x_party_site_use_rec => l_old_party_site_use_rec,
      x_return_status      => x_return_status,
      x_msg_count          => x_msg_count,
      x_msg_data           => x_msg_data);

    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- call to business logic.
    do_update_party_site_use(
                             l_party_site_use_rec,
                             p_object_version_number,
                             x_return_status
                            );

   IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
     IF(HZ_UTILITY_V2PUB.G_EXECUTE_API_CALLOUTS in ('EVENTS_ENABLED', 'Y')) THEN
       -- Invoke business event system.
       HZ_BUSINESS_EVENT_V2PVT.update_party_site_use_event (
         l_party_site_use_rec , l_old_party_site_use_rec );
     END IF;

     IF(HZ_UTILITY_V2PUB.G_EXECUTE_API_CALLOUTS in ('EVENTS_ENABLED', 'BO_EVENTS_ENABLED')) THEN
       -- populate function for integration service
       HZ_POPULATE_BOT_PKG.pop_hz_party_site_uses(
         p_operation         => 'U',
         p_party_site_use_id => l_party_site_use_rec.party_site_use_id);
     END IF;
   END IF;

    -- standard call to get message count and if count is 1, get message info.
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
        hz_utility_v2pub.debug(p_message=> 'update_party_site_use (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Check if API is called in debug mode. If yes, disable debug.
    --disable_debug;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO update_party_site_use;
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
            hz_utility_v2pub.debug(p_message=>'update_party_site_use (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
        END IF;

        -- Check if API is called in debug mode. If yes, disable debug.
        --disable_debug;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO update_party_site_use;
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
           hz_utility_v2pub.debug(p_message=>'update_party_site_use (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
        END IF;

        -- Check if API is called in debug mode. If yes, disable debug.
        --disable_debug;

    WHEN OTHERS THEN
        ROLLBACK TO update_party_site_use;
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
            hz_utility_v2pub.debug(p_message=>'update_party_site_use (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
        END IF;

        -- Check if API is called in debug mode. If yes, disable debug.
        --disable_debug;

END update_party_site_use;


/*===========================================================================+
 | PROCEDURE
 |              get_party_site_rec
 |
 | DESCRIPTION
 |              Gets current record.
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    p_init_msg_list
 |                    p_party_site_id
 |              OUT:
 |                    x_party_site_rec
 |                    x_return_status
 |                    x_msg_count
 |                    x_msg_data
 |          IN/ OUT:
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |
 |  20-APR-2004     Rajib Ranjan Borah    o Bug 3175816. Added global_location_number
 |                                          to HZ_PARTY_SITES.
 +===========================================================================*/

PROCEDURE get_party_site_rec (
    p_init_msg_list                         IN     VARCHAR2 := FND_API.G_FALSE,
    p_party_site_id                         IN     NUMBER,
    x_party_site_rec                        OUT    NOCOPY PARTY_SITE_REC_TYPE,
    x_return_status                         OUT NOCOPY    VARCHAR2,
    x_msg_count                             OUT NOCOPY    NUMBER,
    x_msg_data                              OUT NOCOPY    VARCHAR2
) IS

    l_api_name                              CONSTANT VARCHAR2(30) := 'get_party_site_rec';
    l_actual_content_source                 VARCHAR2(30);

BEGIN

    --Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    --Initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --Check whether primary key has been passed in.
    IF p_party_site_id IS NULL OR
       p_party_site_id = FND_API.G_MISS_NUM THEN
        FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_MISSING_COLUMN' );
        FND_MESSAGE.SET_TOKEN( 'COLUMN', 'party_site_id' );
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    x_party_site_rec.party_site_id := p_party_site_id;

    HZ_PARTY_SITES_PKG.Select_Row (
        X_PARTY_SITE_ID                         => x_party_site_rec.party_site_id,
        X_PARTY_ID                              => x_party_site_rec.party_id,
        X_LOCATION_ID                           => x_party_site_rec.location_id,
        X_PARTY_SITE_NUMBER                     => x_party_site_rec.party_site_number,
        X_ATTRIBUTE_CATEGORY                    => x_party_site_rec.attribute_category,
        X_ATTRIBUTE1                            => x_party_site_rec.attribute1,
        X_ATTRIBUTE2                            => x_party_site_rec.attribute2,
        X_ATTRIBUTE3                            => x_party_site_rec.attribute3,
        X_ATTRIBUTE4                            => x_party_site_rec.attribute4,
        X_ATTRIBUTE5                            => x_party_site_rec.attribute5,
        X_ATTRIBUTE6                            => x_party_site_rec.attribute6,
        X_ATTRIBUTE7                            => x_party_site_rec.attribute7,
        X_ATTRIBUTE8                            => x_party_site_rec.attribute8,
        X_ATTRIBUTE9                            => x_party_site_rec.attribute9,
        X_ATTRIBUTE10                           => x_party_site_rec.attribute10,
        X_ATTRIBUTE11                           => x_party_site_rec.attribute11,
        X_ATTRIBUTE12                           => x_party_site_rec.attribute12,
        X_ATTRIBUTE13                           => x_party_site_rec.attribute13,
        X_ATTRIBUTE14                           => x_party_site_rec.attribute14,
        X_ATTRIBUTE15                           => x_party_site_rec.attribute15,
        X_ATTRIBUTE16                           => x_party_site_rec.attribute16,
        X_ATTRIBUTE17                           => x_party_site_rec.attribute17,
        X_ATTRIBUTE18                           => x_party_site_rec.attribute18,
        X_ATTRIBUTE19                           => x_party_site_rec.attribute19,
        X_ATTRIBUTE20                           => x_party_site_rec.attribute20,
        X_ORIG_SYSTEM_REFERENCE                 => x_party_site_rec.orig_system_reference,
        X_LANGUAGE                              => x_party_site_rec.language,
        X_MAILSTOP                              => x_party_site_rec.mailstop,
        X_IDENTIFYING_ADDRESS_FLAG              => x_party_site_rec.identifying_address_flag,
        X_STATUS                                => x_party_site_rec.status,
        X_PARTY_SITE_NAME                       => x_party_site_rec.party_site_name,
        X_ADDRESSEE                             => x_party_site_rec.addressee,
        X_CREATED_BY_MODULE                     => x_party_site_rec.created_by_module,
        X_APPLICATION_ID                        => x_party_site_rec.application_id,
        X_ACTUAL_CONTENT_SOURCE                 => l_actual_content_source,
        X_GLOBAL_LOCATION_NUMBER                => x_party_site_rec.global_location_number /* Bug 3175816 */,
        X_DUNS_NUMBER_C                         => x_party_site_rec.duns_number_c
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

END get_party_site_rec;



/*===========================================================================+
 | PROCEDURE
 |              get_party_site_use_rec
 |
 | DESCRIPTION
 |              Gets current record.
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    p_init_msg_list
 |                    p_party_site_id
 |              OUT:
 |                    x_party_site_rec
 |                    x_return_status
 |                    x_msg_count
 |                    x_msg_data
 |          IN/ OUT:
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |
 +===========================================================================*/

PROCEDURE get_party_site_use_rec (
    p_init_msg_list                 IN          VARCHAR2 := FND_API.G_FALSE,
    p_party_site_use_id             IN          NUMBER,
    x_party_site_use_rec            OUT         NOCOPY PARTY_SITE_USE_REC_TYPE,
    x_return_status                 OUT NOCOPY         VARCHAR2,
    x_msg_count                     OUT NOCOPY         NUMBER,
    x_msg_data                      OUT NOCOPY         VARCHAR2
) IS

    l_api_name                              CONSTANT VARCHAR2(30) := 'get_party_site_rec';

BEGIN

    --Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    --Initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --Check whether primary key has been passed in.
    IF p_party_site_use_id IS NULL OR
       p_party_site_use_id = FND_API.G_MISS_NUM THEN
        FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_MISSING_COLUMN' );
        FND_MESSAGE.SET_TOKEN( 'COLUMN', 'p_party_site_use_id' );
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    x_party_site_use_rec.party_site_use_id := p_party_site_use_id;

    HZ_PARTY_SITE_USES_PKG.Select_Row (
        X_PARTY_SITE_USE_ID                     => x_party_site_use_rec.party_site_use_id,
        X_COMMENTS                              => x_party_site_use_rec.comments,
        X_PARTY_SITE_ID                         => x_party_site_use_rec.party_site_id,
        X_SITE_USE_TYPE                         => x_party_site_use_rec.site_use_type,
        X_PRIMARY_PER_TYPE                      => x_party_site_use_rec.primary_per_type,
        X_STATUS                                => x_party_site_use_rec.status,
        X_CREATED_BY_MODULE                     => x_party_site_use_rec.created_by_module,
        X_APPLICATION_ID                        => x_party_site_use_rec.application_id
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

END get_party_site_use_rec;

--
--- Following procedures are introduced in account and party site sync
--
/*===========================================================================+
 | PROCEDURE
 |              update_acct_sites_status
 |
 | DESCRIPTION
 |              Updates acct site status.
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |              OUT:
 |          IN/ OUT:
 |                    p_party_site_use_rec
 |                    x_return_status
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 +===========================================================================*/

PROCEDURE update_acct_sites_status(
    p_party_site_id                          IN NUMBER,
    p_new_status                                 IN VARCHAR2,
    x_return_status                  IN OUT NOCOPY  VARCHAR2
) IS

    l_object_version_number                  NUMBER;
    l_rowid                                  ROWID;
    l_party_id                               NUMBER;
    l_party_site_id                          NUMBER;
    l_site_use_type                          HZ_PARTY_SITE_USES.SITE_USE_TYPE%TYPE;
    l_primary_per_type                       HZ_PARTY_SITE_USES.PRIMARY_PER_TYPE%TYPE;
    l_debug_prefix                           VARCHAR2(30) := '';

BEGIN

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=> 'update_acct_sites_status (+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- check whether record has been updated by another user. If not, lock it.
    BEGIN
        UPDATE HZ_CUST_ACCT_SITES_ALL
        SET STATUS = p_new_status,
            bill_to_flag           = NULL,
            ship_to_flag           = NULL,
            market_flag            = NULL,
            last_update_date       = hz_utility_v2pub.last_update_date,
            last_updated_by        = hz_utility_v2pub.last_updated_by,
            last_update_login      = hz_utility_v2pub.last_update_login,
            request_id             = hz_utility_v2pub.request_id,
            program_id             = hz_utility_v2pub.program_id,
            program_application_id = hz_utility_v2pub.program_application_id,
            program_update_date    = hz_utility_v2pub.program_update_date
        WHERE  PARTY_SITE_ID = p_party_site_id;

    EXCEPTION WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_NO_RECORD');
        FND_MESSAGE.SET_TOKEN('RECORD', 'Account sites');
        FND_MESSAGE.SET_TOKEN('VALUE', NVL(TO_CHAR(p_party_site_id), 'null'));
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'update_acct_sites_status (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

END update_acct_sites_status;

/*===========================================================================+
 | PROCEDURE
 |              inactivate_party_site_uses
 |
 | DESCRIPTION
 |              Updates party site uses status.
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |              OUT:
 |          IN/ OUT:
 |                    x_return_status
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 +===========================================================================*/

PROCEDURE inactivate_party_site_uses(
    p_party_site_id                          IN NUMBER,
    p_new_status                                 IN VARCHAR2,
    x_return_status                  IN OUT NOCOPY  VARCHAR2
) IS

    l_object_version_number                  NUMBER;
    l_party_site_id                          NUMBER;
    l_site_use_type                          HZ_PARTY_SITE_USES.SITE_USE_TYPE%TYPE;
    l_primary_per_type                       HZ_PARTY_SITE_USES.PRIMARY_PER_TYPE%TYPE;
    l_debug_prefix                           VARCHAR2(30) := '';
  /* Bug Fix: 4515314 */
    l_party_site_use_rec                     HZ_PARTY_SITE_V2PUB.party_site_use_rec_type;
    l_party_site_use_id                      HZ_PARTY_SITE_USES.party_site_use_id%type;
    l_msg_count                              number;
    l_msg_data                               varchar2(2000);

    cursor c_active_use is
    select party_site_use_id , object_version_number
    from   hz_party_site_uses
    where  status = 'A'
    and    party_site_id = p_party_site_id;
BEGIN

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'inactivate_party_site_uses (+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- check whether record has been updated by another user. If not, lock it.
    BEGIN

          open c_active_use;
          loop
          fetch c_active_use into l_party_site_use_id,l_object_version_number;
                exit when c_active_use%notfound;
                    l_party_site_use_rec.party_site_use_id := l_party_site_use_id;
                    l_party_site_use_rec.status := 'I';
                    HZ_PARTY_SITE_V2PUB.update_party_site_use
                    (p_init_msg_list => FND_API.G_TRUE,
                     p_party_site_use_rec => l_party_site_use_rec,
                     p_object_version_number => l_object_version_number,
                     x_return_status => x_return_status,
                     x_msg_count => l_msg_count,
                     x_msg_data =>  l_msg_data);

                     IF  x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                         RAISE FND_API.G_EXC_ERROR;
                     END IF;
          end loop;
          close c_active_use;

       /* UPDATE HZ_PARTY_SITE_USES
        SET STATUS                 = p_new_status,
            PRIMARY_PER_TYPE       = null,
            last_update_date       = hz_utility_v2pub.last_update_date,
            last_updated_by        = hz_utility_v2pub.last_updated_by,
            last_update_login      = hz_utility_v2pub.last_update_login,
            request_id             = hz_utility_v2pub.request_id,
            program_id             = hz_utility_v2pub.program_id,
            program_application_id = hz_utility_v2pub.program_application_id,
            program_update_date    = hz_utility_v2pub.program_update_date
        WHERE  PARTY_SITE_ID = p_party_site_id;*/

    EXCEPTION WHEN NO_DATA_FOUND THEN
                 x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_NO_RECORD');
        FND_MESSAGE.SET_TOKEN('RECORD', 'party site use');
        FND_MESSAGE.SET_TOKEN('VALUE', NVL(TO_CHAR(p_party_site_id), 'null'));
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END;

   -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'inactivate_party_site_uses (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

END inactivate_party_site_uses;

/*===========================================================================+
 | PROCEDURE
 |         update_denorm_prim_flag
 |
 | DESCRIPTION
 |         Updates primary flag in the acct site uses and denormalize in  the
 |         related cust acct site.
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:   p_site_use_id , p_site_use_code
 |              OUT:
 |          IN/ OUT:
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 ===========================================================================+*/

PROCEDURE update_denorm_prim_flag (
       p_site_use_id                     IN     NUMBER,
      p_site_use_code                    IN     VARCHAR2

   ) IS

       l_debug_prefix                          VARCHAR2(30) := ''; --'denormalize_site_use_flag'
       l_cust_acct_site_id                     HZ_CUST_ACCT_SITES_ALL.cust_acct_site_id%TYPE;

   BEGIN

       -- Debug info.
       IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
   	hz_utility_v2pub.debug(p_message=>'denormalize_site_use_flag (+)',
   	                       p_prefix=>l_debug_prefix,
   			       p_msg_level=>fnd_log.level_procedure);
       END IF;

           UPDATE HZ_CUST_SITE_USES_ALL
           SET    PRIMARY_FLAG = 'Y',
                  last_update_date       = hz_utility_v2pub.last_update_date,
                  last_updated_by        = hz_utility_v2pub.last_updated_by,
                  last_update_login      = hz_utility_v2pub.last_update_login,
                  request_id             = hz_utility_v2pub.request_id,
                  program_id             = hz_utility_v2pub.program_id,
                  program_application_id = hz_utility_v2pub.program_application_id,
                  program_update_date    = hz_utility_v2pub.program_update_date
           WHERE  SITE_USE_ID            = p_site_use_id
           RETURNING CUST_ACCT_SITE_ID INTO l_cust_acct_site_id;

       IF p_site_use_code = 'BILL_TO' THEN

           UPDATE HZ_CUST_ACCT_SITES_ALL
           SET    BILL_TO_FLAG = 'P',
                  last_update_date       = hz_utility_v2pub.last_update_date,
                  last_updated_by        = hz_utility_v2pub.last_updated_by,
                  last_update_login      = hz_utility_v2pub.last_update_login,
                  request_id             = hz_utility_v2pub.request_id,
                  program_id             = hz_utility_v2pub.program_id,
                  program_application_id = hz_utility_v2pub.program_application_id,
                  program_update_date    = hz_utility_v2pub.program_update_date
           WHERE  CUST_ACCT_SITE_ID      = l_cust_acct_site_id;

       ELSIF p_site_use_code = 'SHIP_TO' THEN

           UPDATE HZ_CUST_ACCT_SITES_ALL
           SET    SHIP_TO_FLAG = 'P',
                  last_update_date       = hz_utility_v2pub.last_update_date,
                  last_updated_by        = hz_utility_v2pub.last_updated_by,
                  last_update_login      = hz_utility_v2pub.last_update_login,
                  request_id             = hz_utility_v2pub.request_id,
                  program_id             = hz_utility_v2pub.program_id,
                  program_application_id = hz_utility_v2pub.program_application_id,
                  program_update_date    = hz_utility_v2pub.program_update_date
           WHERE  CUST_ACCT_SITE_ID      = l_cust_acct_site_id;

       ELSIF p_site_use_code = 'MARKET' THEN

           UPDATE HZ_CUST_ACCT_SITES_ALL
           SET    MARKET_FLAG = 'P',
                  last_update_date       = hz_utility_v2pub.last_update_date,
                  last_updated_by        = hz_utility_v2pub.last_updated_by,
                  last_update_login      = hz_utility_v2pub.last_update_login,
                  request_id             = hz_utility_v2pub.request_id,
                  program_id             = hz_utility_v2pub.program_id,
                  program_application_id = hz_utility_v2pub.program_application_id,
                  program_update_date    = hz_utility_v2pub.program_update_date
           WHERE  CUST_ACCT_SITE_ID      = l_cust_acct_site_id;

       END IF;

       -- Debug info.
       IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
   	hz_utility_v2pub.debug(p_message=>'denormalize_site_use_flag (-)',
   	                       p_prefix=>l_debug_prefix,
   			       p_msg_level=>fnd_log.level_procedure);
       END IF;

  END update_denorm_prim_flag;


/*===========================================================================+
 | PROCEDURE
 |              inactivate_account_site_uses
 |
 | DESCRIPTION
 |              Updates account site uses status.
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |              OUT:
 |          IN/ OUT:
 |                    p_party_site_use_rec
 |                    x_return_status
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 +===========================================================================*/

PROCEDURE inactivate_account_site_uses(
    p_party_site_id                          IN NUMBER,
    p_new_status                                 IN VARCHAR2,
    x_return_status                  IN OUT NOCOPY  VARCHAR2
) IS

    l_object_version_number                  NUMBER;
    l_rowid                                  ROWID;
    l_party_id                               NUMBER;
    l_party_site_id                          NUMBER;
    l_site_use_type                          HZ_PARTY_SITE_USES.SITE_USE_TYPE%TYPE;
    l_primary_per_type                       HZ_PARTY_SITE_USES.PRIMARY_PER_TYPE%TYPE;
    l_msg_count                              NUMBER;
    l_msg_data                               VARCHAR2(2000);
    l_debug_prefix                          VARCHAR2(30) := '';
/* Bug 4515314 */
    l_site_use_id                            HZ_CUST_SITE_USES.SITE_USE_ID%TYPE;
    l_site_use_code                          HZ_CUST_SITE_USES.SITE_USE_CODE%TYPE;
    /* c_prim will pick the candidate acct site uses to be marked as primary
       once the acct sites sharing the p_party_site_id are made inactive
       even for multiple accounts sharing p_party_site_id  */
    cursor c_prim is
    SELECT MIN(b.site_use_id) ,  site_use_code
    FROM   hz_cust_acct_sites_all a , hz_cust_site_uses_all b
    WHERE  a.cust_account_id   in (select cust_account_id
                                   from   hz_cust_acct_sites_all cas
                                   where  cas.party_site_id = p_party_site_id)
    AND    a.cust_acct_site_id = b.cust_acct_site_id
    AND    b.status = 'A'
    AND    a.status = 'A'
    GROUP BY a.cust_Account_id,b.org_id,b.site_use_code
    HAVING MAX(nvl(primary_flag,'N')) = 'N';


BEGIN

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=> 'inactivate_account_site_uses (+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- check whether record has been updated by another user. If not, lock it.
    BEGIN
        UPDATE HZ_CUST_SITE_USES_ALL
        SET STATUS                 = p_new_status,
            primary_flag           = 'N',  --Bug 3370874
            last_update_date       = hz_utility_v2pub.last_update_date,
            last_updated_by        = hz_utility_v2pub.last_updated_by,
            last_update_login      = hz_utility_v2pub.last_update_login,
            request_id             = hz_utility_v2pub.request_id,
            program_id             = hz_utility_v2pub.program_id,
            program_application_id = hz_utility_v2pub.program_application_id,
            program_update_date    = hz_utility_v2pub.program_update_date
        WHERE  CUST_ACCT_SITE_ID IN (
                        SELECT CUST_ACCT_SITE_ID
                        FROM   HZ_CUST_ACCT_SITES_ALL
                        WHERE  PARTY_SITE_ID = p_party_site_id);
/*Bug Fix: 4515314*/
        OPEN  c_prim;
        LOOP
        FETCH c_prim into l_site_use_id , l_site_use_code;
             EXIT WHEN c_prim%NOTFOUND;
                update_denorm_prim_flag (l_site_use_id , l_site_use_code);
        END LOOP;
        CLOSE c_prim;

    EXCEPTION WHEN NO_DATA_FOUND THEN
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_NO_RECORD');
        FND_MESSAGE.SET_TOKEN('RECORD', 'Party site use');
        FND_MESSAGE.SET_TOKEN('VALUE', NVL(TO_CHAR(p_party_site_id), 'null'));
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END;

     -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'inactivate_account_site_uses (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

END inactivate_account_site_uses;

/*===========================================================================+
 | PROCEDURE
 |              cascade_site_status_changes
 |
 | DESCRIPTION
 |              It cascades activation of activation to Account Sites and
 |                              Inactivation of to Party Site Uses,Account Sites and
 |                              Account Site Uses.
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |              OUT:
 |          IN/ OUT:
 |                    x_return_status
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 +===========================================================================*/

PROCEDURE cascade_site_status_changes(
    p_party_site_id                          IN NUMBER,
    p_new_status                                 IN VARCHAR2,
    x_return_status                  IN OUT NOCOPY  VARCHAR2
) IS

    l_object_version_number                  NUMBER;
    l_rowid                                  ROWID;
    l_party_id                               NUMBER;
    l_party_site_id                          NUMBER;
    l_site_use_type                          HZ_PARTY_SITE_USES.SITE_USE_TYPE%TYPE;
    l_primary_per_type                       HZ_PARTY_SITE_USES.PRIMARY_PER_TYPE%TYPE;
    l_msg_count                              NUMBER;
    l_msg_data                               VARCHAR2(2000);
    l_debug_prefix                          VARCHAR2(30) := '';

BEGIN

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'cascade_site_status_changes (+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    --
    --- Call update_acct_sites_status procedure
    --
        update_acct_sites_status(p_party_site_id,p_new_status,x_return_status);

    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    --
    --- If Inactivating Party Site Uses
    --
    IF x_return_status = FND_API.G_RET_STS_SUCCESS and p_new_status = 'I' THEN
       inactivate_party_site_uses(p_party_site_id,p_new_status,x_return_status);
        --
    --- Inactivate account site uses
    --
    IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
       inactivate_account_site_uses(p_party_site_id,p_new_status,x_return_status);
    END IF;
    END IF;
    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'cascade_site_status_changes (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;

--        FND_MSG_PUB.Count_And_Get(
--            p_encoded => FND_API.G_FALSE,
--            p_count => x_msg_count,
--            p_data  => x_msg_data );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

--        FND_MSG_PUB.Count_And_Get(
--            p_encoded => FND_API.G_FALSE,
--            p_count => x_msg_count,
--            p_data  => x_msg_data );

    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
--        FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_OTHERS_EXCEP' );
--        FND_MESSAGE.SET_TOKEN( 'ERROR' ,SQLERRM );
--        FND_MSG_PUB.ADD;
--        FND_MSG_PUB.Count_And_Get(
--            p_encoded => FND_API.G_FALSE,
--            p_count => x_msg_count,
--            p_data  => x_msg_data );

END cascade_site_status_changes;

/**
 * PRIVATE PROCEDURE check_obsolete_columns
 *
 * DESCRIPTION
 *     Check if user is using obsolete columns.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * MODIFICATION HISTORY
 *
 *   07-25-2005    Jianying Huang      o Created.
 *
 */

PROCEDURE check_obsolete_columns (
    p_create_update_flag          IN     VARCHAR2,
    p_party_site_rec              IN     party_site_rec_type,
    p_old_party_site_rec          IN     party_site_rec_type DEFAULT NULL,
    x_return_status               IN OUT NOCOPY VARCHAR2
) IS

BEGIN

    -- check language
    IF (p_create_update_flag = 'C' AND
        p_party_site_rec.language IS NOT NULL AND
        p_party_site_rec.language <> FND_API.G_MISS_CHAR) OR
       (p_create_update_flag = 'U' AND
        p_party_site_rec.language IS NOT NULL AND
        p_party_site_rec.language <> p_old_party_site_rec.language)
    THEN
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_OBSOLETE_COLUMN');
        FND_MESSAGE.SET_TOKEN('COLUMN', 'language');
        FND_MSG_PUB.ADD;
        x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

END check_obsolete_columns;

END HZ_PARTY_SITE_V2PUB;

/
