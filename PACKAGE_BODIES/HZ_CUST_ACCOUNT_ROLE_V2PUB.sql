--------------------------------------------------------
--  DDL for Package Body HZ_CUST_ACCOUNT_ROLE_V2PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_CUST_ACCOUNT_ROLE_V2PUB" AS
/*$Header: ARH2CRSB.pls 120.13 2005/12/07 19:30:14 acng ship $ */

--------------------------------------
-- declaration of private global varibles
--------------------------------------

G_DEBUG_COUNT             NUMBER := 0;
--G_DEBUG                   BOOLEAN := FALSE;

--------------------------------------
-- declaration of private procedures and functions
--------------------------------------

/*PROCEDURE enable_debug;

PROCEDURE disable_debug;
*/


PROCEDURE do_create_cust_account_role (
    p_cust_account_role_rec                 IN OUT NOCOPY CUST_ACCOUNT_ROLE_REC_TYPE,
    x_cust_account_role_id                  OUT NOCOPY    NUMBER,
    x_return_status                         IN OUT NOCOPY VARCHAR2
);

PROCEDURE do_update_cust_account_role (
    p_cust_account_role_rec                 IN OUT NOCOPY CUST_ACCOUNT_ROLE_REC_TYPE,
    p_object_version_number                 IN OUT NOCOPY NUMBER,
    x_return_status                         IN OUT NOCOPY VARCHAR2
);

PROCEDURE do_create_role_responsibility (
    p_role_responsibility_rec               IN OUT NOCOPY ROLE_RESPONSIBILITY_REC_TYPE,
    x_responsibility_id                     OUT NOCOPY    NUMBER,
    x_return_status                         IN OUT NOCOPY VARCHAR2
);

PROCEDURE do_update_role_responsibility (
    p_role_responsibility_rec               IN OUT NOCOPY ROLE_RESPONSIBILITY_REC_TYPE,
    p_object_version_number                 IN OUT NOCOPY NUMBER,
    x_return_status                         IN OUT NOCOPY VARCHAR2
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
 *   07-23-2001    Jianying Huang      o Created.
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

/**
 * PRIVATE PROCEDURE do_create_cust_account_role
 *
 * DESCRIPTION
 *     Private procedure to create customer account role.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *     HZ_ACCOUNT_VALIDATE_V2PUB.validate_cust_account_role
 *     HZ_CUST_ACCOUNT_ROLES_PKG.Insert_Row
 *     HZ_PARTY_SITE_V2PUB.create_party_site
 *
 * ARGUMENTS
 *   IN/OUT:
 *     p_cust_account_role_rec        Customer account role record.
 *     x_return_status                Return status after the call. The status can
 *                                    be FND_API.G_RET_STS_SUCCESS (success),
 *                                    FND_API.G_RET_STS_ERROR (error),
 *                                    FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
 *   OUT:
 *     x_cust_account_role_id         Customer account role ID.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   07-23-2001    Jianying Huang      o Created.
 *   06-28-2002    P.Suresh            o Bug No : 2263151. Commented the logic of
 *                                       creating a party site while creating an account
 *                                       role .
 *
 */

PROCEDURE do_create_cust_account_role (
    p_cust_account_role_rec                 IN OUT NOCOPY CUST_ACCOUNT_ROLE_REC_TYPE,
    x_cust_account_role_id                  OUT NOCOPY    NUMBER,
    x_return_status                         IN OUT NOCOPY VARCHAR2
) IS

    l_debug_prefix                          VARCHAR2(30) := ''; --'do_create_cust_account_role'

    l_dummy                                 VARCHAR2(1);
    l_msg_count                             NUMBER;
    l_msg_data                              VARCHAR2(2000);
    l_profile                               VARCHAR2(1) := 'Y';

    l_party_site_rec                        HZ_PARTY_SITE_V2PUB.PARTY_SITE_REC_TYPE;
    l_location_id                           NUMBER;
    l_party_site_id                         NUMBER;
    l_party_site_number                     HZ_PARTY_SITES.party_site_number%TYPE;
    l_orig_sys_reference_rec                HZ_ORIG_SYSTEM_REF_PUB.ORIG_SYS_REFERENCE_REC_TYPE;

BEGIN

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'do_create_cust_account_role (+)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Validate cust account role record
    HZ_ACCOUNT_VALIDATE_V2PUB.validate_cust_account_role (
        p_create_update_flag                    => 'C',
        p_cust_account_role_rec                 => p_cust_account_role_rec,
        p_rowid                                 => NULL,
        x_return_status                         => x_return_status );

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;
  /* Bug No : 2263151.
    -- Removed the logic to create a party site while creating the
    -- account role.

    -- Create new party site for parties in account roles when
    -- create account role in site level.

    IF p_cust_account_role_rec.cust_acct_site_id IS NOT NULL AND
       p_cust_account_role_rec.cust_acct_site_id <> FND_API.G_MISS_NUM
    THEN
        -- select location id
        SELECT LOCATION_ID INTO l_location_id
        FROM HZ_PARTY_SITES
        WHERE PARTY_SITE_ID = (
            SELECT PARTY_SITE_ID
            FROM HZ_CUST_ACCT_SITES
            WHERE CUST_ACCT_SITE_ID = p_cust_account_role_rec.cust_acct_site_id );

        -- check if the address has been used by the party
        BEGIN
            SELECT 'Y' INTO l_dummy
            FROM HZ_PARTY_SITES
            WHERE PARTY_ID = p_cust_account_role_rec.party_id
            AND LOCATION_ID = l_location_id;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                -- create new party site for the contact if no
                -- party site has been created in the same address
                -- as customer account address.

                -- Debug info.
		IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
			 hz_utility_v2pub.debug(p_message=>'Need to create party site for account role party id ',
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
		END IF;

                l_party_site_rec.party_id := p_cust_account_role_rec.party_id;
                l_party_site_rec.location_id := l_location_id;
                l_party_site_rec.created_by_module := p_cust_account_role_rec.created_by_module;
                l_party_site_rec.application_id := p_cust_account_role_rec.application_id;

                --force profile option to 'Y' to generate party site number
                --through table sequence.

                IF FND_PROFILE.VALUE( 'HZ_GENERATE_PARTY_SITE_NUMBER' ) = 'N' THEN
                    l_profile := 'N';
                    FND_PROFILE.PUT( 'HZ_GENERATE_PARTY_SITE_NUMBER', 'Y' );
                END IF;

                HZ_PARTY_SITE_V2PUB.create_party_site (
                    p_party_site_rec              => l_party_site_rec,
                    x_party_site_id               => l_party_site_id,
                    x_party_site_number           => l_party_site_number,
                    x_return_status               => x_return_status,
                    x_msg_count                   => l_msg_count,
                    x_msg_data                    => l_msg_data );

                -- change back the profile option.
                IF l_profile = 'N' THEN
                    FND_PROFILE.PUT( 'HZ_GENERATE_PARTY_SITE_NUMBER', 'N' );
                END IF;

                IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                        RAISE FND_API.G_EXC_ERROR;
                    ELSE
                        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                    END IF;
                END IF;
        END;
    END IF;
 */
    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'HZ_CUST_ACCOUNT_ROLES_PKG.Insert_Row (+)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Call table-handler.
    HZ_CUST_ACCOUNT_ROLES_PKG.Insert_Row (
        X_CUST_ACCOUNT_ROLE_ID                  => p_cust_account_role_rec.cust_account_role_id,
        X_PARTY_ID                              => p_cust_account_role_rec.party_id,
        X_CUST_ACCOUNT_ID                       => p_cust_account_role_rec.cust_account_id,
        X_CUST_ACCT_SITE_ID                     => p_cust_account_role_rec.cust_acct_site_id,
        X_PRIMARY_FLAG                          => p_cust_account_role_rec.primary_flag,
        X_ROLE_TYPE                             => p_cust_account_role_rec.role_type,
        X_SOURCE_CODE                           => p_cust_account_role_rec.source_code,
        X_ATTRIBUTE_CATEGORY                    => p_cust_account_role_rec.attribute_category,
        X_ATTRIBUTE1                            => p_cust_account_role_rec.attribute1,
        X_ATTRIBUTE2                            => p_cust_account_role_rec.attribute2,
        X_ATTRIBUTE3                            => p_cust_account_role_rec.attribute3,
        X_ATTRIBUTE4                            => p_cust_account_role_rec.attribute4,
        X_ATTRIBUTE5                            => p_cust_account_role_rec.attribute5,
        X_ATTRIBUTE6                            => p_cust_account_role_rec.attribute6,
        X_ATTRIBUTE7                            => p_cust_account_role_rec.attribute7,
        X_ATTRIBUTE8                            => p_cust_account_role_rec.attribute8,
        X_ATTRIBUTE9                            => p_cust_account_role_rec.attribute9,
        X_ATTRIBUTE10                           => p_cust_account_role_rec.attribute10,
        X_ATTRIBUTE11                           => p_cust_account_role_rec.attribute11,
        X_ATTRIBUTE12                           => p_cust_account_role_rec.attribute12,
        X_ATTRIBUTE13                           => p_cust_account_role_rec.attribute13,
        X_ATTRIBUTE14                           => p_cust_account_role_rec.attribute14,
        X_ATTRIBUTE15                           => p_cust_account_role_rec.attribute15,
        X_ATTRIBUTE16                           => p_cust_account_role_rec.attribute16,
        X_ATTRIBUTE17                           => p_cust_account_role_rec.attribute17,
        X_ATTRIBUTE18                           => p_cust_account_role_rec.attribute18,
        X_ATTRIBUTE19                           => p_cust_account_role_rec.attribute19,
        X_ATTRIBUTE20                           => p_cust_account_role_rec.attribute20,
        X_ATTRIBUTE21                           => p_cust_account_role_rec.attribute21,
        X_ATTRIBUTE22                           => p_cust_account_role_rec.attribute22,
        X_ATTRIBUTE23                           => p_cust_account_role_rec.attribute23,
        X_ATTRIBUTE24                           => p_cust_account_role_rec.attribute24,
        X_ORIG_SYSTEM_REFERENCE                 => p_cust_account_role_rec.orig_system_reference,
        X_ATTRIBUTE25                           => p_cust_account_role_rec.attribute25,
        X_STATUS                                => p_cust_account_role_rec.status,
        X_OBJECT_VERSION_NUMBER                 => 1,
        X_CREATED_BY_MODULE                     => p_cust_account_role_rec.created_by_module,
        X_APPLICATION_ID                        => p_cust_account_role_rec.application_id
    );


    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'HZ_CUST_ACCOUNT_ROLES_PKG.Insert_Row (-) ' ||
            'x_cust_account_role_id = ' || p_cust_account_role_rec.cust_account_role_id,
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
    END IF;

if (p_cust_account_role_rec.orig_system_reference is not null and p_cust_account_role_rec.orig_system_reference<>fnd_api.g_miss_char ) then
 if (p_cust_account_role_rec.orig_system is null OR p_cust_account_role_rec.orig_system = fnd_api.g_miss_char) then
      p_cust_account_role_rec.orig_system := 'UNKNOWN';
 end if;
end if;


if (p_cust_account_role_rec.orig_system is not null and p_cust_account_role_rec.orig_system<>fnd_api.g_miss_char ) then
  l_orig_sys_reference_rec.orig_system := p_cust_account_role_rec.orig_system;
  l_orig_sys_reference_rec.orig_system_reference := p_cust_account_role_rec.orig_system_reference;
  l_orig_sys_reference_rec.owner_table_name := 'HZ_CUST_ACCOUNT_ROLES';
  l_orig_sys_reference_rec.owner_table_id := p_cust_account_role_rec.cust_account_role_id;
  l_orig_sys_reference_rec.created_by_module := p_cust_account_role_rec.created_by_module;

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
x_cust_account_role_id := p_cust_account_role_rec.cust_account_role_id;
    -- Debug info.

    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'do_create_cust_account_role (-)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
    END IF;

END do_create_cust_account_role;

/**
 * PRIVATE PROCEDURE do_update_cust_account_role
 *
 * DESCRIPTION
 *     Private procedure to update customer account role.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *     HZ_ACCOUNT_VALIDATE_V2PUB.validate_cust_account_role
 *     HZ_CUST_ACCOUNT_ROLES_PKG.Update_Row
 *
 * ARGUMENTS
 *   IN/OUT:
 *     p_cust_account_role_rec        Customer account role record.
 *     p_object_version_number        Used for locking the being updated record.
 *     x_return_status                Return status after the call. The status can
 *                                    be FND_API.G_RET_STS_SUCCESS (success),
 *                                    FND_API.G_RET_STS_ERROR (error),
 *                                    FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   07-23-2001    Jianying Huang      o Created.
 *
 */

PROCEDURE do_update_cust_account_role (
    p_cust_account_role_rec                 IN OUT NOCOPY CUST_ACCOUNT_ROLE_REC_TYPE,
    p_object_version_number                 IN OUT NOCOPY NUMBER,
    x_return_status                         IN OUT NOCOPY VARCHAR2
) IS

    l_debug_prefix                          VARCHAR2(30) := ''; --'do_update_cust_account_role'

    l_rowid                                 ROWID := NULL;
    l_object_version_number                 NUMBER;
    l_orig_sys_reference_rec                HZ_ORIG_SYSTEM_REF_PUB.ORIG_SYS_REFERENCE_REC_TYPE;


BEGIN

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'do_update_cust_account_role (+)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Lock record.
    BEGIN
        SELECT ROWID, OBJECT_VERSION_NUMBER
        INTO l_rowid, l_object_version_number
        FROM HZ_CUST_ACCOUNT_ROLES
        WHERE CUST_ACCOUNT_ROLE_ID = p_cust_account_role_rec.cust_account_role_id
        FOR UPDATE NOWAIT;

        IF NOT (
            ( p_object_version_number IS NULL AND l_object_version_number IS NULL ) OR
            ( p_object_version_number IS NOT NULL AND
              l_object_version_number IS NOT NULL AND
              p_object_version_number = l_object_version_number ) )
        THEN
            FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_RECORD_CHANGED' );
            FND_MESSAGE.SET_TOKEN( 'TABLE', 'hz_cust_account_roles' );
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        END IF;

        p_object_version_number := NVL( l_object_version_number, 1 ) + 1;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_NO_RECORD' );
            FND_MESSAGE.SET_TOKEN( 'RECORD', 'customer account role' );
            FND_MESSAGE.SET_TOKEN( 'VALUE',
                NVL( TO_CHAR( p_cust_account_role_rec.cust_account_role_id ), 'null' ) );
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
    END;

    -- Validate cust account role record
    HZ_ACCOUNT_VALIDATE_V2PUB.validate_cust_account_role (
        p_create_update_flag                    => 'U',
        p_cust_account_role_rec                 => p_cust_account_role_rec,
        p_rowid                                 => l_rowid,
        x_return_status                         => x_return_status );

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    if (p_cust_account_role_rec.orig_system is not null
	 and p_cust_account_role_rec.orig_system <>fnd_api.g_miss_char)
	and (p_cust_account_role_rec.orig_system_reference is not null
	 and p_cust_account_role_rec.orig_system_reference <>fnd_api.g_miss_char)
    then
		p_cust_account_role_rec.orig_system_reference := null;
		-- In mosr, we have bypassed osr nonupdateable validation
                -- but we should not update existing osr, set it to null
    end if;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'HZ_CUST_ACCOUNT_ROLES_PKG.Update_Row (+)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Call table-handler.
    HZ_CUST_ACCOUNT_ROLES_PKG.Update_Row (
        X_Rowid                                 => l_rowid,
        X_CUST_ACCOUNT_ROLE_ID                  => p_cust_account_role_rec.cust_account_role_id,
        X_PARTY_ID                              => p_cust_account_role_rec.party_id,
        X_CUST_ACCOUNT_ID                       => p_cust_account_role_rec.cust_account_id,
        X_CUST_ACCT_SITE_ID                     => p_cust_account_role_rec.cust_acct_site_id,
        X_PRIMARY_FLAG                          => p_cust_account_role_rec.primary_flag,
        X_ROLE_TYPE                             => p_cust_account_role_rec.role_type,
        X_SOURCE_CODE                           => p_cust_account_role_rec.source_code,
        X_ATTRIBUTE_CATEGORY                    => p_cust_account_role_rec.attribute_category,
        X_ATTRIBUTE1                            => p_cust_account_role_rec.attribute1,
        X_ATTRIBUTE2                            => p_cust_account_role_rec.attribute2,
        X_ATTRIBUTE3                            => p_cust_account_role_rec.attribute3,
        X_ATTRIBUTE4                            => p_cust_account_role_rec.attribute4,
        X_ATTRIBUTE5                            => p_cust_account_role_rec.attribute5,
        X_ATTRIBUTE6                            => p_cust_account_role_rec.attribute6,
        X_ATTRIBUTE7                            => p_cust_account_role_rec.attribute7,
        X_ATTRIBUTE8                            => p_cust_account_role_rec.attribute8,
        X_ATTRIBUTE9                            => p_cust_account_role_rec.attribute9,
        X_ATTRIBUTE10                           => p_cust_account_role_rec.attribute10,
        X_ATTRIBUTE11                           => p_cust_account_role_rec.attribute11,
        X_ATTRIBUTE12                           => p_cust_account_role_rec.attribute12,
        X_ATTRIBUTE13                           => p_cust_account_role_rec.attribute13,
        X_ATTRIBUTE14                           => p_cust_account_role_rec.attribute14,
        X_ATTRIBUTE15                           => p_cust_account_role_rec.attribute15,
        X_ATTRIBUTE16                           => p_cust_account_role_rec.attribute16,
        X_ATTRIBUTE17                           => p_cust_account_role_rec.attribute17,
        X_ATTRIBUTE18                           => p_cust_account_role_rec.attribute18,
        X_ATTRIBUTE19                           => p_cust_account_role_rec.attribute19,
        X_ATTRIBUTE20                           => p_cust_account_role_rec.attribute20,
        X_ATTRIBUTE21                           => p_cust_account_role_rec.attribute21,
        X_ATTRIBUTE22                           => p_cust_account_role_rec.attribute22,
        X_ATTRIBUTE23                           => p_cust_account_role_rec.attribute23,
        X_ATTRIBUTE24                           => p_cust_account_role_rec.attribute24,
        X_ORIG_SYSTEM_REFERENCE                 => p_cust_account_role_rec.orig_system_reference,
        X_ATTRIBUTE25                           => p_cust_account_role_rec.attribute25,
        X_STATUS                                => p_cust_account_role_rec.status,
        X_OBJECT_VERSION_NUMBER                 => p_object_version_number,
        X_CREATED_BY_MODULE                     => p_cust_account_role_rec.created_by_module,
        X_APPLICATION_ID                        => p_cust_account_role_rec.application_id
    );

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'HZ_CUST_ACCOUNT_ROLES_PKG.Update_Row (-)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
    END IF;

END do_update_cust_account_role;

/**
 * PRIVATE PROCEDURE do_create_role_responsibility
 *
 * DESCRIPTION
 *     Private procedure to create customer account role responsibility.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *     HZ_ACCOUNT_VALIDATE_V2PUB.validate_role_responsibility
 *     HZ_ROLE_RESPONSIBILITY_PKG.Insert_Row
 *
 * ARGUMENTS
 *   IN/OUT:
 *     p_role_responsibility_rec      Customer account role responsibility record.
 *     x_return_status                Return status after the call. The status can
 *                                    be FND_API.G_RET_STS_SUCCESS (success),
 *                                    FND_API.G_RET_STS_ERROR (error),
 *                                    FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
 *   OUT:
 *     x_responsibility_id            Role responsibility ID.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   07-23-2001    Jianying Huang      o Created.
 *
 */

PROCEDURE do_create_role_responsibility (
    p_role_responsibility_rec               IN OUT NOCOPY ROLE_RESPONSIBILITY_REC_TYPE,
    x_responsibility_id                     OUT NOCOPY    NUMBER,
    x_return_status                         IN OUT NOCOPY VARCHAR2
) IS

    l_debug_prefix                          VARCHAR2(30) := ''; --'do_create_role_responsibility'

BEGIN

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'do_create_role_responsibility (+)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Validate role responsibility record
    HZ_ACCOUNT_VALIDATE_V2PUB.validate_role_responsibility (
        p_create_update_flag                    => 'C',
        p_role_responsibility_rec               => p_role_responsibility_rec,
        p_rowid                                 => NULL,
        x_return_status                         => x_return_status );

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'HZ_ROLE_RESPONSIBILITY_PKG.Insert_Row (+)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Call table-handler.
    HZ_ROLE_RESPONSIBILITY_PKG.Insert_Row (
        X_RESPONSIBILITY_ID                     => p_role_responsibility_rec.responsibility_id,
        X_CUST_ACCOUNT_ROLE_ID                  => p_role_responsibility_rec.cust_account_role_id,
        X_RESPONSIBILITY_TYPE                   => p_role_responsibility_rec.responsibility_type,
        X_PRIMARY_FLAG                          => p_role_responsibility_rec.primary_flag,
        X_ATTRIBUTE_CATEGORY                    => p_role_responsibility_rec.attribute_category,
        X_ATTRIBUTE1                            => p_role_responsibility_rec.attribute1,
        X_ATTRIBUTE2                            => p_role_responsibility_rec.attribute2,
        X_ATTRIBUTE3                            => p_role_responsibility_rec.attribute3,
        X_ATTRIBUTE4                            => p_role_responsibility_rec.attribute4,
        X_ATTRIBUTE5                            => p_role_responsibility_rec.attribute5,
        X_ATTRIBUTE6                            => p_role_responsibility_rec.attribute6,
        X_ATTRIBUTE7                            => p_role_responsibility_rec.attribute7,
        X_ATTRIBUTE8                            => p_role_responsibility_rec.attribute8,
        X_ATTRIBUTE9                            => p_role_responsibility_rec.attribute9,
        X_ATTRIBUTE10                           => p_role_responsibility_rec.attribute10,
        X_ATTRIBUTE11                           => p_role_responsibility_rec.attribute11,
        X_ATTRIBUTE12                           => p_role_responsibility_rec.attribute12,
        X_ATTRIBUTE13                           => p_role_responsibility_rec.attribute13,
        X_ATTRIBUTE14                           => p_role_responsibility_rec.attribute14,
        X_ATTRIBUTE15                           => p_role_responsibility_rec.attribute15,
        X_ORIG_SYSTEM_REFERENCE                 => p_role_responsibility_rec.orig_system_reference,
        X_OBJECT_VERSION_NUMBER                 => 1,
        X_CREATED_BY_MODULE                     => p_role_responsibility_rec.created_by_module,
        X_APPLICATION_ID                        => p_role_responsibility_rec.application_id
    );

    x_responsibility_id := p_role_responsibility_rec.responsibility_id;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'HZ_ROLE_RESPONSIBILITY_PKG.Insert_Row (-) ' ||
            'x_responsibility_id = ' || x_responsibility_id,
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'do_create_role_responsibility (-)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
    END IF;

END do_create_role_responsibility;

/**
 * PRIVATE PROCEDURE do_update_role_responsibility
 *
 * DESCRIPTION
 *     Private procedure to update customer account role responsibility.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *     HZ_ACCOUNT_VALIDATE_V2PUB.validate_role_responsibility
 *     HZ_ROLE_RESPONSIBILITY_PKG.Update_Row
 *
 * ARGUMENTS
 *   IN/OUT:
 *     p_role_responsibility_rec      Customer account role responsibility record.
 *     p_object_version_number        Used for locking the being updated record.
 *     x_return_status                Return status after the call. The status can
 *                                    be FND_API.G_RET_STS_SUCCESS (success),
 *                                    FND_API.G_RET_STS_ERROR (error),
 *                                    FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   07-23-2001    Jianying Huang      o Created.
 *
 */

PROCEDURE do_update_role_responsibility (
    p_role_responsibility_rec               IN OUT NOCOPY ROLE_RESPONSIBILITY_REC_TYPE,
    p_object_version_number                 IN OUT NOCOPY NUMBER,
    x_return_status                         IN OUT NOCOPY VARCHAR2
) IS

    l_debug_prefix                          VARCHAR2(30) := ''; --'do_update_role_responsibility'

    l_rowid                                 ROWID := NULL;
    l_object_version_number                 NUMBER;

BEGIN

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'do_update_role_responsibility (+)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Lock record.
    BEGIN
        SELECT ROWID, OBJECT_VERSION_NUMBER
        INTO l_rowid, l_object_version_number
        FROM HZ_ROLE_RESPONSIBILITY
        WHERE RESPONSIBILITY_ID = p_role_responsibility_rec.responsibility_id
        FOR UPDATE NOWAIT;

        IF NOT (
            ( p_object_version_number IS NULL AND l_object_version_number IS NULL ) OR
            ( p_object_version_number IS NOT NULL AND
              l_object_version_number IS NOT NULL AND
              p_object_version_number = l_object_version_number ) )
        THEN
            FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_RECORD_CHANGED' );
            FND_MESSAGE.SET_TOKEN( 'TABLE', 'hz_role_responsibility' );
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        END IF;

        p_object_version_number := NVL( l_object_version_number, 1 ) + 1;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_NO_RECORD' );
            FND_MESSAGE.SET_TOKEN( 'RECORD', 'customer account role responsibility' );
            FND_MESSAGE.SET_TOKEN( 'VALUE',
                NVL( TO_CHAR( p_role_responsibility_rec.responsibility_id ), 'null' ) );
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
    END;

    -- Validate role responsibility record
    HZ_ACCOUNT_VALIDATE_V2PUB.validate_role_responsibility (
        p_create_update_flag                    => 'U',
        p_role_responsibility_rec                 => p_role_responsibility_rec,
        p_rowid                                 => l_rowid,
        x_return_status                         => x_return_status );

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'HZ_ROLE_RESPONSIBILITY_PKG.Update_Row (+)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Call table-handler.
    HZ_ROLE_RESPONSIBILITY_PKG.Update_Row (
        X_Rowid                                 => l_rowid,
        X_RESPONSIBILITY_ID                     => p_role_responsibility_rec.responsibility_id,
        X_CUST_ACCOUNT_ROLE_ID                  => p_role_responsibility_rec.cust_account_role_id,
        X_RESPONSIBILITY_TYPE                   => p_role_responsibility_rec.responsibility_type,
        X_PRIMARY_FLAG                          => p_role_responsibility_rec.primary_flag,
        X_ATTRIBUTE_CATEGORY                    => p_role_responsibility_rec.attribute_category,
        X_ATTRIBUTE1                            => p_role_responsibility_rec.attribute1,
        X_ATTRIBUTE2                            => p_role_responsibility_rec.attribute2,
        X_ATTRIBUTE3                            => p_role_responsibility_rec.attribute3,
        X_ATTRIBUTE4                            => p_role_responsibility_rec.attribute4,
        X_ATTRIBUTE5                            => p_role_responsibility_rec.attribute5,
        X_ATTRIBUTE6                            => p_role_responsibility_rec.attribute6,
        X_ATTRIBUTE7                            => p_role_responsibility_rec.attribute7,
        X_ATTRIBUTE8                            => p_role_responsibility_rec.attribute8,
        X_ATTRIBUTE9                            => p_role_responsibility_rec.attribute9,
        X_ATTRIBUTE10                           => p_role_responsibility_rec.attribute10,
        X_ATTRIBUTE11                           => p_role_responsibility_rec.attribute11,
        X_ATTRIBUTE12                           => p_role_responsibility_rec.attribute12,
        X_ATTRIBUTE13                           => p_role_responsibility_rec.attribute13,
        X_ATTRIBUTE14                           => p_role_responsibility_rec.attribute14,
        X_ATTRIBUTE15                           => p_role_responsibility_rec.attribute15,
        X_ORIG_SYSTEM_REFERENCE                 => p_role_responsibility_rec.orig_system_reference,
        X_OBJECT_VERSION_NUMBER                 => p_object_version_number,
        X_CREATED_BY_MODULE                     => p_role_responsibility_rec.created_by_module,
        X_APPLICATION_ID                        => p_role_responsibility_rec.application_id
    );

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'HZ_ROLE_RESPONSIBILITY_PKG.Update_Row (-)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'do_update_role_responsibility (-)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
    END IF;

END do_update_role_responsibility;

--------------------------------------
-- public procedures and functions
--------------------------------------

/**
 * PROCEDURE create_cust_account_role
 *
 * DESCRIPTION
 *     Creates customer account role.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *     HZ_BUSINESS_EVENT_V2PVT.create_cust_account_role_event
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_cust_account_role_rec        Customer account role record.
 *   IN/OUT:
 *   OUT:
 *     x_cust_account_role_id         Customer account role ID.
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
 *   07-23-2001    Jianying Huang      o Created.
 *
 */

PROCEDURE create_cust_account_role (
    p_init_msg_list                         IN     VARCHAR2 := FND_API.G_FALSE,
    p_cust_account_role_rec                 IN     CUST_ACCOUNT_ROLE_REC_TYPE,
    x_cust_account_role_id                  OUT NOCOPY    NUMBER,
    x_return_status                         OUT NOCOPY    VARCHAR2,
    x_msg_count                             OUT NOCOPY    NUMBER,
    x_msg_data                              OUT NOCOPY    VARCHAR2
) IS

    l_cust_account_role_rec                 CUST_ACCOUNT_ROLE_REC_TYPE := p_cust_account_role_rec;
    l_debug_prefix		            VARCHAR2(30) := '';


BEGIN

    -- Standard start of API savepoint
    SAVEPOINT create_cust_account_role;

    -- Check if API is called in debug mode. If yes, enable debug.
    --enable_debug;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'create_cust_account_role (+)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Call to business logic.
    do_create_cust_account_role (
        l_cust_account_role_rec,
        x_cust_account_role_id,
        x_return_status );


   IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
     IF(HZ_UTILITY_V2PUB.G_EXECUTE_API_CALLOUTS in ('Y', 'EVENTS_ENABLED')) THEN
       -- Invoke business event system.
       HZ_BUSINESS_EVENT_V2PVT.create_cust_account_role_event (
         l_cust_account_role_rec );
     END IF;

     IF(HZ_UTILITY_V2PUB.G_EXECUTE_API_CALLOUTS in ('EVENTS_ENABLED', 'BO_EVENTS_ENABLED')) THEN
       HZ_POPULATE_BOT_PKG.pop_hz_cust_account_roles(
         p_operation            => 'I',
         p_cust_account_role_id => x_cust_account_role_id);
     END IF;
   END IF;

    -- Standard call to get message count and if count is 1, get message info.
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
	hz_utility_v2pub.debug(p_message=>'create_cust_account_role (-)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Check if API is called in debug mode. If yes, disable debug.
    --disable_debug;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO create_cust_account_role;
        x_return_status := FND_API.G_RET_STS_ERROR;

        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data );
	IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
		 hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
	                       p_msg_data=>x_msg_data,
			       p_msg_type=>'ERROR',
			       p_msg_level=>fnd_log.level_error);
        END IF;
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	    hz_utility_v2pub.debug(p_message=>'create_cust_account_role (-)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
        END IF;

        -- Check if API is called in debug mode. If yes, disable debug.
        --disable_debug;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO create_cust_account_role;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data );

	IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
	                       p_msg_data=>x_msg_data,
			       p_msg_type=>'UNEXPECTED ERROR',
			       p_msg_level=>fnd_log.level_error);
        END IF;
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'create_cust_account_role (-)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
        END IF;


        -- Check if API is called in debug mode. If yes, disable debug.
        --disable_debug;

    WHEN OTHERS THEN
        ROLLBACK TO create_cust_account_role;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_OTHERS_EXCEP' );
        FND_MESSAGE.SET_TOKEN( 'ERROR' ,SQLERRM );
        FND_MSG_PUB.ADD;

        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data );
	IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
             hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
	                       p_msg_data=>x_msg_data,
			       p_msg_type=>'SQL ERROR',
			       p_msg_level=>fnd_log.level_error);
        END IF;
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	    hz_utility_v2pub.debug(p_message=>'create_cust_account_role (-)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
        END IF;

        -- Check if API is called in debug mode. If yes, disable debug.
        --disable_debug;

END create_cust_account_role;

/**
 * PROCEDURE update_cust_account_role
 *
 * DESCRIPTION
 *     Updates customer account role.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *     HZ_BUSINESS_EVENT_V2PVT.update_cust_account_role_event
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_cust_account_role_rec        Customer account role record.
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
 *   07-23-2001    Jianying Huang      o Created.
 *
 */

PROCEDURE update_cust_account_role (
    p_init_msg_list                         IN     VARCHAR2 := FND_API.G_FALSE,
    p_cust_account_role_rec                 IN     CUST_ACCOUNT_ROLE_REC_TYPE,
    p_object_version_number                 IN OUT NOCOPY NUMBER,
    x_return_status                         OUT NOCOPY    VARCHAR2,
    x_msg_count                             OUT NOCOPY    NUMBER,
    x_msg_data                              OUT NOCOPY    VARCHAR2
) IS

    l_cust_account_role_rec                 CUST_ACCOUNT_ROLE_REC_TYPE := p_cust_account_role_rec;
    l_old_cust_account_role_rec             CUST_ACCOUNT_ROLE_REC_TYPE;
    l_debug_prefix		            VARCHAR2(30) := '';

BEGIN

    -- Standard start of API savepoint
    SAVEPOINT update_cust_account_role;

    -- Check if API is called in debug mode. If yes, enable debug.
    --enable_debug;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'update_cust_account_role (+)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF (p_cust_account_role_rec.orig_system is not null and p_cust_account_role_rec.orig_system <>fnd_api.g_miss_char)
     and (p_cust_account_role_rec.orig_system_reference is not null and p_cust_account_role_rec.orig_system_reference <>fnd_api.g_miss_char)
     and (p_cust_account_role_rec.cust_account_role_id = FND_API.G_MISS_NUM or p_cust_account_role_rec.cust_account_role_id is null) THEN

    hz_orig_system_ref_pub.get_owner_table_id
   (p_orig_system => p_cust_account_role_rec.orig_system,
   p_orig_system_reference => p_cust_account_role_rec.orig_system_reference,
   p_owner_table_name => 'HZ_CUST_ACCOUNT_ROLES',
   x_owner_table_id => l_cust_account_role_rec.cust_account_role_id,
   x_return_status => x_return_status);
     IF x_return_status <> fnd_api.g_ret_sts_success THEN
  RAISE FND_API.G_EXC_ERROR;
     END IF;

      END IF;

    get_cust_account_role_rec (
      p_cust_account_role_id     => l_cust_account_role_rec.cust_account_role_id,
      x_cust_account_role_rec    => l_old_cust_account_role_rec,
      x_return_status            => x_return_status,
      x_msg_count                => x_msg_count,
      x_msg_data                 => x_msg_data);

    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Call to business logic.
    do_update_cust_account_role (
        l_cust_account_role_rec,
        p_object_version_number,
        x_return_status );

   IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
     -- Invoke business event system.
     l_old_cust_account_role_rec.orig_system := l_cust_account_role_rec.orig_system;
     IF(HZ_UTILITY_V2PUB.G_EXECUTE_API_CALLOUTS in ('Y', 'EVENTS_ENABLED')) THEN
       HZ_BUSINESS_EVENT_V2PVT.update_cust_account_role_event (
         l_cust_account_role_rec ,  l_old_cust_account_role_rec );
     END IF;

     IF(HZ_UTILITY_V2PUB.G_EXECUTE_API_CALLOUTS in ('EVENTS_ENABLED', 'BO_EVENTS_ENABLED')) THEN
       HZ_POPULATE_BOT_PKG.pop_hz_cust_account_roles(
         p_operation            => 'U',
         p_cust_account_role_id => l_cust_account_role_rec.cust_account_role_id);
     END IF;
   END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data );
    IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
	 hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
	                       p_msg_data=>x_msg_data,
			       p_msg_type=>'WARNING',
			       p_msg_level=>fnd_log.level_exception);
    END IF;
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'update_cust_account_role (-)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Check if API is called in debug mode. If yes, disable debug.
    --disable_debug;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO update_cust_account_role;
        x_return_status := FND_API.G_RET_STS_ERROR;

        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data );

	IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
		 hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
	                       p_msg_data=>x_msg_data,
			       p_msg_type=>'ERROR',
			       p_msg_level=>fnd_log.level_error);
        END IF;
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	    hz_utility_v2pub.debug(p_message=>'update_cust_account_role (-)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
        END IF;

        -- Check if API is called in debug mode. If yes, disable debug.
        --disable_debug;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO update_cust_account_role;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data );
	IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
	                       p_msg_data=>x_msg_data,
			       p_msg_type=>'UNEXPECTED ERROR',
			       p_msg_level=>fnd_log.level_error);
        END IF;
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'update_cust_account_role (-)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
        END IF;

        -- Check if API is called in debug mode. If yes, disable debug.
        --disable_debug;

    WHEN OTHERS THEN
        ROLLBACK TO update_cust_account_role;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_OTHERS_EXCEP' );
        FND_MESSAGE.SET_TOKEN( 'ERROR' ,SQLERRM );
        FND_MSG_PUB.ADD;

        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data );

	IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
             hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
	                       p_msg_data=>x_msg_data,
			       p_msg_type=>'SQL ERROR',
			       p_msg_level=>fnd_log.level_error);
        END IF;
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	    hz_utility_v2pub.debug(p_message=>'update_cust_account_role (-)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
        END IF;

        -- Check if API is called in debug mode. If yes, disable debug.
        --disable_debug;

END update_cust_account_role;

/**
 * PROCEDURE get_cust_account_role_rec
 *
 * DESCRIPTION
 *      Gets customer account role record
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *     HZ_CUST_ACCOUNT_ROLES_PKG.Select_Row
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_cust_account_role_id         Customer account role id.
 *   IN/OUT:
 *   OUT:
 *     x_cust_account_role_rec        Returned customer account role record.
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
 *   07-23-2001    Jianying Huang      o Created.
 *
 */

PROCEDURE get_cust_account_role_rec (
    p_init_msg_list                         IN     VARCHAR2 := FND_API.G_FALSE,
    p_cust_account_role_id                  IN     NUMBER,
    x_cust_account_role_rec                 OUT    NOCOPY CUST_ACCOUNT_ROLE_REC_TYPE,
    x_return_status                         OUT NOCOPY    VARCHAR2,
    x_msg_count                             OUT NOCOPY    NUMBER,
    x_msg_data                              OUT NOCOPY    VARCHAR2
) IS
 l_debug_prefix		            VARCHAR2(30) := '';
BEGIN

    -- Check if API is called in debug mode. If yes, enable debug.
    --enable_debug;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'get_cust_account_role_rec (+)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
    END IF;


    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Check whether primary key has been passed in.
    IF p_cust_account_role_id IS NULL OR
       p_cust_account_role_id = FND_API.G_MISS_NUM THEN
        FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_MISSING_COLUMN' );
        FND_MESSAGE.SET_TOKEN( 'COLUMN', 'cust_account_role_id' );
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    x_cust_account_role_rec.cust_account_role_id := p_cust_account_role_id;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'HZ_CUST_ACCOUNT_ROLES_PKG.Select_Row (+)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
    END IF;


    -- Call table-handler.
    HZ_CUST_ACCOUNT_ROLES_PKG.Select_Row (
        X_CUST_ACCOUNT_ROLE_ID                  => x_cust_account_role_rec.cust_account_role_id,
        X_PARTY_ID                              => x_cust_account_role_rec.party_id,
        X_CUST_ACCOUNT_ID                       => x_cust_account_role_rec.cust_account_id,
        X_CUST_ACCT_SITE_ID                     => x_cust_account_role_rec.cust_acct_site_id,
        X_PRIMARY_FLAG                          => x_cust_account_role_rec.primary_flag,
        X_ROLE_TYPE                             => x_cust_account_role_rec.role_type,
        X_SOURCE_CODE                           => x_cust_account_role_rec.source_code,
        X_ATTRIBUTE_CATEGORY                    => x_cust_account_role_rec.attribute_category,
        X_ATTRIBUTE1                            => x_cust_account_role_rec.attribute1,
        X_ATTRIBUTE2                            => x_cust_account_role_rec.attribute2,
        X_ATTRIBUTE3                            => x_cust_account_role_rec.attribute3,
        X_ATTRIBUTE4                            => x_cust_account_role_rec.attribute4,
        X_ATTRIBUTE5                            => x_cust_account_role_rec.attribute5,
        X_ATTRIBUTE6                            => x_cust_account_role_rec.attribute6,
        X_ATTRIBUTE7                            => x_cust_account_role_rec.attribute7,
        X_ATTRIBUTE8                            => x_cust_account_role_rec.attribute8,
        X_ATTRIBUTE9                            => x_cust_account_role_rec.attribute9,
        X_ATTRIBUTE10                           => x_cust_account_role_rec.attribute10,
        X_ATTRIBUTE11                           => x_cust_account_role_rec.attribute11,
        X_ATTRIBUTE12                           => x_cust_account_role_rec.attribute12,
        X_ATTRIBUTE13                           => x_cust_account_role_rec.attribute13,
        X_ATTRIBUTE14                           => x_cust_account_role_rec.attribute14,
        X_ATTRIBUTE15                           => x_cust_account_role_rec.attribute15,
        X_ATTRIBUTE16                           => x_cust_account_role_rec.attribute16,
        X_ATTRIBUTE17                           => x_cust_account_role_rec.attribute17,
        X_ATTRIBUTE18                           => x_cust_account_role_rec.attribute18,
        X_ATTRIBUTE19                           => x_cust_account_role_rec.attribute19,
        X_ATTRIBUTE20                           => x_cust_account_role_rec.attribute20,
        X_ATTRIBUTE21                           => x_cust_account_role_rec.attribute21,
        X_ATTRIBUTE22                           => x_cust_account_role_rec.attribute22,
        X_ATTRIBUTE23                           => x_cust_account_role_rec.attribute23,
        X_ATTRIBUTE24                           => x_cust_account_role_rec.attribute24,
        X_ORIG_SYSTEM_REFERENCE                 => x_cust_account_role_rec.orig_system_reference,
        X_ATTRIBUTE25                           => x_cust_account_role_rec.attribute25,
        X_STATUS                                => x_cust_account_role_rec.status,
        X_CREATED_BY_MODULE                     => x_cust_account_role_rec.created_by_module,
        X_APPLICATION_ID                        => x_cust_account_role_rec.application_id
    );

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'HZ_CUST_ACCOUNT_ROLES_PKG.Select_Row (-)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
    END IF;


    -- Standard call to get message count and if count is 1, get message info.
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
	hz_utility_v2pub.debug(p_message=>'get_cust_account_role_rec (-)',
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
	    hz_utility_v2pub.debug(p_message=>'get_cust_account_role_rec (-)',
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
	   hz_utility_v2pub.debug(p_message=>'get_cust_account_role_rec (-)',
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
	    hz_utility_v2pub.debug(p_message=>'get_cust_account_role_rec (-)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
        END IF;

        -- Check if API is called in debug mode. If yes, disable debug.
        --disable_debug;

END get_cust_account_role_rec;

/**
 * PROCEDURE create_role_responsibility
 *
 * DESCRIPTION
 *     Creates customer account role responsibility.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *     HZ_BUSINESS_EVENT_V2PVT.create_role_resp_event
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_role_responsibility_rec      Customer account role responsibility record.
 *   IN/OUT:
 *   OUT:
 *     x_responsibility_id            Role responsibility ID.
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
 *   07-23-2001    Jianying Huang      o Created.
 *
 */

PROCEDURE create_role_responsibility (
    p_init_msg_list                         IN     VARCHAR2 := FND_API.G_FALSE,
    p_role_responsibility_rec               IN     ROLE_RESPONSIBILITY_REC_TYPE,
    x_responsibility_id                     OUT NOCOPY    NUMBER,
    x_return_status                         OUT NOCOPY    VARCHAR2,
    x_msg_count                             OUT NOCOPY    NUMBER,
    x_msg_data                              OUT NOCOPY    VARCHAR2
) IS

    l_role_responsibility_rec               ROLE_RESPONSIBILITY_REC_TYPE := p_role_responsibility_rec;
    l_debug_prefix		            VARCHAR2(30) := '';
BEGIN

    -- Standard start of API savepoint
    SAVEPOINT create_role_responsibility;

    -- Check if API is called in debug mode. If yes, enable debug.
    --enable_debug;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'create_role_responsibility (+)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Call to business logic.
    do_create_role_responsibility (
        l_role_responsibility_rec,
        x_responsibility_id,
        x_return_status );

   IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
     IF(HZ_UTILITY_V2PUB.G_EXECUTE_API_CALLOUTS in ('Y', 'EVENTS_ENABLED')) THEN
       -- Invoke business event system.
       HZ_BUSINESS_EVENT_V2PVT.create_role_resp_event (
         l_role_responsibility_rec );
     END IF;

     IF(HZ_UTILITY_V2PUB.G_EXECUTE_API_CALLOUTS in ('EVENTS_ENABLED', 'BO_EVENTS_ENABLED')) THEN
       HZ_POPULATE_BOT_PKG.pop_hz_role_responsibility(
         p_operation         => 'I',
         p_responsibility_id => x_responsibility_id);
     END IF;
   END IF;

    -- Standard call to get message count and if count is 1, get message info.
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
	hz_utility_v2pub.debug(p_message=>'create_role_responsibility (-)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Check if API is called in debug mode. If yes, disable debug.
    --disable_debug;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO create_role_responsibility;
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
	    hz_utility_v2pub.debug(p_message=>'create_role_responsibility (-)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
        END IF;

        -- Check if API is called in debug mode. If yes, disable debug.
        --disable_debug;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO create_role_responsibility;
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
	   hz_utility_v2pub.debug(p_message=>'create_role_responsibility (-)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
        END IF;

        -- Check if API is called in debug mode. If yes, disable debug.
        --disable_debug;

    WHEN OTHERS THEN
        ROLLBACK TO create_role_responsibility;
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
	    hz_utility_v2pub.debug(p_message=>'create_role_responsibility (-)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
        END IF;

        -- Check if API is called in debug mode. If yes, disable debug.
        --disable_debug;

END create_role_responsibility;

/**
 * PROCEDURE update_role_responsibility
 *
 * DESCRIPTION
 *     Updates customer account role responsibility.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *     HZ_BUSINESS_EVENT_V2PVT.update_role_resp_event
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_role_responsibility_rec      Customer account role responsibility record.
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
 *   07-23-2001    Jianying Huang      o Created.
 *
 */

PROCEDURE update_role_responsibility (
    p_init_msg_list                         IN     VARCHAR2 := FND_API.G_FALSE,
    p_role_responsibility_rec               IN     ROLE_RESPONSIBILITY_REC_TYPE,
    p_object_version_number                 IN OUT NOCOPY NUMBER,
    x_return_status                         OUT NOCOPY    VARCHAR2,
    x_msg_count                             OUT NOCOPY    NUMBER,
    x_msg_data                              OUT NOCOPY    VARCHAR2
) IS

    l_role_responsibility_rec               ROLE_RESPONSIBILITY_REC_TYPE := p_role_responsibility_rec;
    l_old_role_responsibility_rec           ROLE_RESPONSIBILITY_REC_TYPE;
    l_debug_prefix		            VARCHAR2(30) := '';

BEGIN

    -- Standard start of API savepoint
    SAVEPOINT update_role_responsibility;

    -- Check if API is called in debug mode. If yes, enable debug.
    --enable_debug;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'update_role_responsibility (+)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --2290537
    get_role_responsibility_rec (
      p_responsibility_id          => p_role_responsibility_rec.responsibility_id,
      x_role_responsibility_rec    => l_old_role_responsibility_rec,
      x_return_status              => x_return_status,
      x_msg_count                  => x_msg_count,
      x_msg_data                   => x_msg_data);

    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Call to business logic.
    do_update_role_responsibility (
        l_role_responsibility_rec,
        p_object_version_number,
        x_return_status );

   IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
     IF(HZ_UTILITY_V2PUB.G_EXECUTE_API_CALLOUTS in ('Y', 'EVENTS_ENABLED')) THEN
       -- Invoke business event system.
       HZ_BUSINESS_EVENT_V2PVT.update_role_resp_event (
         l_role_responsibility_rec , l_old_role_responsibility_rec);
     END IF;

     IF(HZ_UTILITY_V2PUB.G_EXECUTE_API_CALLOUTS in ('EVENTS_ENABLED', 'BO_EVENTS_ENABLED')) THEN
       HZ_POPULATE_BOT_PKG.pop_hz_role_responsibility(
         p_operation         => 'U',
         p_responsibility_id => l_role_responsibility_rec.responsibility_id);
     END IF;
   END IF;

    -- Standard call to get message count and if count is 1, get message info.
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
	hz_utility_v2pub.debug(p_message=>'update_role_responsibility (-)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Check if API is called in debug mode. If yes, disable debug.
    --disable_debug;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO update_role_responsibility;
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
	    hz_utility_v2pub.debug(p_message=>'update_role_responsibility (-)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
        END IF;

        -- Check if API is called in debug mode. If yes, disable debug.
        --disable_debug;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO update_role_responsibility;
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
	   hz_utility_v2pub.debug(p_message=>'update_role_responsibility (-)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
        END IF;

        -- Check if API is called in debug mode. If yes, disable debug.
        --disable_debug;

    WHEN OTHERS THEN
        ROLLBACK TO update_role_responsibility;
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
	    hz_utility_v2pub.debug(p_message=>'update_role_responsibility (-)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
        END IF;

        -- Check if API is called in debug mode. If yes, disable debug.
        --disable_debug;

END update_role_responsibility;

/**
 * PROCEDURE get_role_responsibility_rec
 *
 * DESCRIPTION
 *      Gets customer account role responsibility record
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *     HZ_ROLE_RESPONSIBILITY_PKG.Select_Row
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_responsibility_id            Role responsibility ID.
 *   IN/OUT:
 *   OUT:
 *     x_role_responsibility_rec      Returned customer account role responsibility record.
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
 *   07-23-2001    Jianying Huang      o Created.
 *
 */

PROCEDURE get_role_responsibility_rec (
    p_init_msg_list                         IN     VARCHAR2 := FND_API.G_FALSE,
    p_responsibility_id                     IN     NUMBER,
    x_role_responsibility_rec               OUT    NOCOPY ROLE_RESPONSIBILITY_REC_TYPE,
    x_return_status                         OUT NOCOPY    VARCHAR2,
    x_msg_count                             OUT NOCOPY    NUMBER,
    x_msg_data                              OUT NOCOPY    VARCHAR2
) IS
 l_debug_prefix		            VARCHAR2(30) := '';
BEGIN

    -- Check if API is called in debug mode. If yes, enable debug.
    --enable_debug;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'get_role_responsibility_rec (+)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Check whether primary key has been passed in.
    IF p_responsibility_id IS NULL OR
       p_responsibility_id = FND_API.G_MISS_NUM THEN
        FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_MISSING_COLUMN' );
        FND_MESSAGE.SET_TOKEN( 'COLUMN', 'responsibility_id' );
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    x_role_responsibility_rec.responsibility_id := p_responsibility_id;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'HZ_ROLE_RESPONSIBILITY_PKG.Select_Row (+)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Call table-handler.
    HZ_ROLE_RESPONSIBILITY_PKG.Select_Row (
        X_RESPONSIBILITY_ID                     => x_role_responsibility_rec.responsibility_id,
        X_CUST_ACCOUNT_ROLE_ID                  => x_role_responsibility_rec.cust_account_role_id,
        X_RESPONSIBILITY_TYPE                   => x_role_responsibility_rec.responsibility_type,
        X_PRIMARY_FLAG                          => x_role_responsibility_rec.primary_flag,
        X_ATTRIBUTE_CATEGORY                    => x_role_responsibility_rec.attribute_category,
        X_ATTRIBUTE1                            => x_role_responsibility_rec.attribute1,
        X_ATTRIBUTE2                            => x_role_responsibility_rec.attribute2,
        X_ATTRIBUTE3                            => x_role_responsibility_rec.attribute3,
        X_ATTRIBUTE4                            => x_role_responsibility_rec.attribute4,
        X_ATTRIBUTE5                            => x_role_responsibility_rec.attribute5,
        X_ATTRIBUTE6                            => x_role_responsibility_rec.attribute6,
        X_ATTRIBUTE7                            => x_role_responsibility_rec.attribute7,
        X_ATTRIBUTE8                            => x_role_responsibility_rec.attribute8,
        X_ATTRIBUTE9                            => x_role_responsibility_rec.attribute9,
        X_ATTRIBUTE10                           => x_role_responsibility_rec.attribute10,
        X_ATTRIBUTE11                           => x_role_responsibility_rec.attribute11,
        X_ATTRIBUTE12                           => x_role_responsibility_rec.attribute12,
        X_ATTRIBUTE13                           => x_role_responsibility_rec.attribute13,
        X_ATTRIBUTE14                           => x_role_responsibility_rec.attribute14,
        X_ATTRIBUTE15                           => x_role_responsibility_rec.attribute15,
        X_ORIG_SYSTEM_REFERENCE                 => x_role_responsibility_rec.orig_system_reference,
        X_CREATED_BY_MODULE                     => x_role_responsibility_rec.created_by_module,
        X_APPLICATION_ID                        => x_role_responsibility_rec.application_id
    );

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'HZ_ROLE_RESPONSIBILITY_PKG.Select_Row (-)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Standard call to get message count and if count is 1, get message info.
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
	hz_utility_v2pub.debug(p_message=>'get_role_responsibility_rec (-)',
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
	    hz_utility_v2pub.debug(p_message=>'get_role_responsibility_rec (-)',
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
	   hz_utility_v2pub.debug(p_message=>'get_role_responsibility_rec (-)',
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
	    hz_utility_v2pub.debug(p_message=>'get_role_responsibility_rec (-)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
        END IF;

        -- Check if API is called in debug mode. If yes, disable debug.
        --disable_debug;

END get_role_responsibility_rec;

END HZ_CUST_ACCOUNT_ROLE_V2PUB;

/
