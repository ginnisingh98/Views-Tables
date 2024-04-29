--------------------------------------------------------
--  DDL for Package Body HZ_CUST_ACCOUNT_SITE_V2PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_CUST_ACCOUNT_SITE_V2PUB" AS
/*$Header: ARH2CSSB.pls 120.41.12010000.5 2010/03/08 12:34:20 rgokavar ship $ */

--------------------------------------
-- declaration of private global varibles
--------------------------------------

G_DEBUG_COUNT             NUMBER := 0;
--G_DEBUG                   BOOLEAN := FALSE;


-- Code added for BUG 3714636
g_message_name                     VARCHAR2(1) :=NULL;

--------------------------------------
-- declaration of private procedures and functions
--------------------------------------

/*PROCEDURE enable_debug;

PROCEDURE disable_debug;
*/


PROCEDURE do_create_cust_acct_site (
    p_cust_acct_site_rec                    IN OUT NOCOPY CUST_ACCT_SITE_REC_TYPE,
    x_cust_acct_site_id                     OUT NOCOPY    NUMBER,
    x_return_status                         IN OUT NOCOPY VARCHAR2
);

PROCEDURE do_update_cust_acct_site (
    p_cust_acct_site_rec                    IN OUT NOCOPY CUST_ACCT_SITE_REC_TYPE,
    p_object_version_number                 IN OUT NOCOPY NUMBER,
    x_return_status                         IN OUT NOCOPY VARCHAR2
);

PROCEDURE do_create_cust_site_use (
    p_cust_site_use_rec                     IN OUT NOCOPY CUST_SITE_USE_REC_TYPE,
    p_customer_profile_rec                  IN OUT NOCOPY HZ_CUSTOMER_PROFILE_V2PUB.CUSTOMER_PROFILE_REC_TYPE,
    p_create_profile                        IN     VARCHAR2 := FND_API.G_TRUE,
    p_create_profile_amt                    IN     VARCHAR2 := FND_API.G_TRUE,
    x_site_use_id                           OUT NOCOPY    NUMBER,
    x_return_status                         IN OUT NOCOPY VARCHAR2
);

PROCEDURE do_update_cust_site_use (
    p_cust_site_use_rec                     IN OUT NOCOPY CUST_SITE_USE_REC_TYPE,
    p_object_version_number                 IN OUT NOCOPY NUMBER,
    x_return_status                         IN OUT NOCOPY VARCHAR2
);

PROCEDURE denormalize_site_use_flag (
    p_cust_acct_site_id                     IN     NUMBER,
    p_site_use_code                         IN     VARCHAR2,
    p_flag                                  IN     VARCHAR2
);

PROCEDURE do_unset_prim_cust_site_use(
        p_site_use_code         IN      varchar2,
        p_cust_acct_site_id     IN      number,
        p_org_id                IN      number  -- TCA SSA Uptake (Bug 3456489)
);

PROCEDURE check_obsolete_columns (
    p_create_update_flag          IN     VARCHAR2,
    p_account_site_rec            IN     cust_acct_site_rec_type,
    p_old_account_site_rec        IN     cust_acct_site_rec_type DEFAULT NULL,
    x_return_status               IN OUT NOCOPY VARCHAR2
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
 * PRIVATE PROCEDURE do_create_cust_acct_site
 *
 * DESCRIPTION
 *     Private procedure to create customer account site.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *     HZ_ACCOUNT_VALIDATE_V2PUB.validate_cust_acct_site
 *     HZ_CUST_ACCT_SITES_PKG.Insert_Row
 *
 * ARGUMENTS
 *   IN/OUT:
 *     p_cust_acct_site_rec           Customer account site record.
 *     x_return_status                Return status after the call. The status can
 *                                    be FND_API.G_RET_STS_SUCCESS (success),
 *                                    FND_API.G_RET_STS_ERROR (error),
 *                                    FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
 *   OUT:
 *     x_cust_acct_site_id            Customer account site ID.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   07-23-2001    Jianying Huang      o Created.
 *
 *  24-JUN-2004  V.Ravichandran         o Bug 3714636.Modified do_create_cust_acct_site() and
 *                                       to reduce cost of query
 *                                       which checks whether the message name in
 *                                       FND_NEW_MESSAGES is 'HZ_INACTIVATE_ACCOUNT_SITE_UI'.
 *  02-AUG-2004  Rajib Ranjan Borah    o Bug 3805019. If status is NULL and the corresponding
 *                                       status is 'A', then warning HZ_ACCT_SITE_INHERIT_STATUS
 *                                       will not be displayed.
 *                                     o Rowid and object_version_number in
 *                                       HZ_PARTY_SITES need not be read for synchronizing
 *                                       statuses.
 *                                       Removed unnecessary variables l_ps_rowid,
 *                                       l_ps_object_version_number and l_dummy.
 *  12-MAY-2005   Rajib Ranjan Borah   o TCA SSA Uptake (Bug 3456489)
 */

PROCEDURE do_create_cust_acct_site (
    p_cust_acct_site_rec                    IN OUT NOCOPY CUST_ACCT_SITE_REC_TYPE,
    x_cust_acct_site_id                     OUT NOCOPY    NUMBER,
    x_return_status                         IN OUT NOCOPY VARCHAR2
) IS

    l_debug_prefix                          VARCHAR2(30) := ''; --'do_create_cust_acct_site';

    l_return_status                         VARCHAR2(1);
    l_msg_count                             NUMBER;
    l_msg_data                              VARCHAR2(2000);

    l_location_id                           NUMBER;
    l_loc_id                                NUMBER;
    l_orig_sys_reference_rec                HZ_ORIG_SYSTEM_REF_PUB.ORIG_SYS_REFERENCE_REC_TYPE;
    l_cust_acct_site_orig_sys               VARCHAR2(255);

    /* 3456489 Added org_id for Shared Service Uptake */
    CURSOR check_orig_sys_ref IS
    select 'Y' from hz_cust_acct_sites_all
    where orig_system_reference =
    p_cust_acct_site_rec.orig_system_reference
    and org_id = p_cust_acct_site_rec.org_id;


    l_orig_system_reference varchar2(255) :=p_cust_acct_site_rec.orig_system_reference;
    l_tmp varchar2(1);
/*    l_ps_object_version_number                number;
    l_ps_rowid                          rowid := null; */
    l_status                            varchar2(1);
--    l_dummy                             varchar2(1);

    CURSOR c_check_first_site (
      p_cust_account_id          NUMBER,
      p_org_id                   NUMBER
    ) IS
    SELECT null
    FROM   hz_cust_acct_sites_all
    WHERE  cust_account_id = p_cust_account_id
    AND    org_id = p_org_id
    AND    status NOT IN ('M', 'D')
    AND    ROWNUM = 1;

    CURSOR c_check_profile (
      p_cust_account_id          NUMBER
    ) IS
    SELECT credit_hold
    FROM   hz_customer_profiles
    WHERE  cust_account_id = p_cust_account_id;

BEGIN

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'do_create_cust_acct_site (+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    --
    --- Before creating account site, inherit status from party site(bug 3299622)
    --
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
                FND_MESSAGE.SET_TOKEN('RECORD', 'Release Name');
                FND_MESSAGE.SET_TOKEN('VALUE', 'HZ_INACTIVATE_ACCOUNT_SITE_UI');
                FND_MSG_PUB.ADD;
                RAISE FND_API.G_EXC_ERROR;
          END;
          END IF;
    IF g_message_name IS NOT NULL THEN
     -- Code modified for Bug 3714636 ends here
    BEGIN
        SELECT /*ROWID, OBJECT_VERSION_NUMBER,*/status
        INTO  /*l_ps_rowid, l_ps_object_version_number,*/l_status
        FROM  HZ_PARTY_SITES
        WHERE PARTY_SITE_ID = p_cust_acct_site_rec.party_site_id
        FOR UPDATE NOWAIT;

        --p_object_version_number := NVL( l_object_version_number, 1 ) + 1;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_NO_RECORD' );
            FND_MESSAGE.SET_TOKEN( 'RECORD', 'party site' );
            FND_MESSAGE.SET_TOKEN( 'VALUE',
                NVL( TO_CHAR( p_cust_acct_site_rec.party_site_id ), 'null' ) );
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
    END;

    /*IF p_cust_acct_site_rec.status is NULL OR p_cust_acct_site_rec.status <> l_status THEN  --Bug 3370870 */
    IF  NVL(p_cust_acct_site_rec.status,'A') <> l_status THEN  -- Bug 3805019
        FND_MESSAGE.SET_NAME( 'AR', 'HZ_ACCT_SITE_INHERIT_STATUS' );
        FND_MSG_PUB.ADD;
        p_cust_acct_site_rec.status := l_status;
    END IF;
    END IF;
    --end of party site account site status synch

    /* 4578854 Added for Shared Service Uptake */
    BEGIN
    MO_GLOBAL.validate_orgid_pub_api(p_cust_acct_site_rec.org_id,'N',l_return_status);
    EXCEPTION
    WHEN OTHERS
    THEN
     RAISE FND_API.G_EXC_ERROR;
    END;

    if (p_cust_acct_site_rec.orig_system is null or p_cust_acct_site_rec.orig_system = fnd_api.g_miss_char)
      and (p_cust_acct_site_rec.orig_system_reference is not null and
           p_cust_acct_site_rec.orig_system_reference <> fnd_api.g_miss_char) then
        p_cust_acct_site_rec.orig_system := 'UNKNOWN';
    end if;

    open check_orig_sys_ref;
    fetch check_orig_sys_ref into l_tmp;
     if check_orig_sys_ref%FOUND then
        p_cust_acct_site_rec.orig_system_reference:=l_orig_system_reference||'#@'||to_char(sysdate,'DD-MON-YYYY HH24:MI:SS');
      end if ;
    close check_orig_sys_ref;

    -- Validate cust acct site record
    HZ_ACCOUNT_VALIDATE_V2PUB.validate_cust_acct_site (
        p_create_update_flag                    => 'C',
        p_cust_acct_site_rec                    => p_cust_acct_site_rec,
        p_rowid                                 => NULL,
        x_return_status                         => x_return_status );

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Add for global holds
    --

    OPEN c_check_first_site(
      p_cust_acct_site_rec.cust_account_id, p_cust_acct_site_rec.org_id);
    FETCH c_check_first_site INTO l_tmp;
    IF c_check_first_site%NOTFOUND THEN
      -- Debug info.
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
          hz_utility_v2pub.debug(p_message=>'First site created in this org... '||
                                 'cust_account_id = '||p_cust_acct_site_rec.cust_account_id||' '||
                                 'org_id = '||p_cust_acct_site_rec.org_id,
                                 p_prefix=>l_debug_prefix,
                                 p_msg_level=>fnd_log.level_statement);
      END IF;

      OPEN c_check_profile(p_cust_acct_site_rec.cust_account_id);
      FETCH c_check_profile INTO l_tmp;
      CLOSE c_check_profile;

      IF l_tmp = 'Y' THEN
        -- Debug info.
        IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug(p_message=>'Before call OE_HOLDS... '||
                                              'cust_account_id = '||p_cust_acct_site_rec.cust_account_id,
                                   p_prefix=>l_debug_prefix,
                                   p_msg_level=>fnd_log.level_statement);
        END IF;

        BEGIN
          l_return_status := FND_API.G_RET_STS_SUCCESS;
          OE_Holds_PUB.Process_Holds (
            p_api_version         => 1.0,
            p_init_msg_list       => FND_API.G_FALSE,
            p_hold_entity_code    => 'C',
            p_hold_entity_id      => p_cust_acct_site_rec.cust_account_id,
            p_hold_id             => 1,
            p_release_reason_code => 'AR_AUTOMATIC',
            p_action              => 'APPLY',
            x_return_status       => l_return_status,
            x_msg_count           => l_msg_count,
            x_msg_data            => l_msg_data);

            -- Debug info.
            IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
              hz_utility_v2pub.debug(p_message=>'After call OE_HOLDS... '||
                                                'l_return_status = '||l_return_status||' '||
                                                'l_msg_count = '||l_msg_count||' '||
                                                'l_msg_data = '||l_msg_data,
                                     p_prefix=>l_debug_prefix,
                                     p_msg_level=>fnd_log.level_statement);
            END IF;
        EXCEPTION
          WHEN OTHERS THEN
            -- Debug info.
            IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
              hz_utility_v2pub.debug(p_message=>'Exception raised from OE_HOLDS... '||SQLERRM,
                                     p_prefix=>l_debug_prefix,
                                     p_msg_level=>fnd_log.level_statement);
            END IF;

            l_return_status := 'S';
        END;

        --
        -- only raise unexpected error
        --
        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
      END IF;
    END IF;
    CLOSE c_check_first_site;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'HZ_CUST_ACCT_SITES_PKG.Insert_Row (+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Call table-handler.
    HZ_CUST_ACCT_SITES_PKG.Insert_Row (
        X_CUST_ACCT_SITE_ID                     => p_cust_acct_site_rec.cust_acct_site_id,
        X_CUST_ACCOUNT_ID                       => p_cust_acct_site_rec.cust_account_id,
        X_PARTY_SITE_ID                         => p_cust_acct_site_rec.party_site_id,
        X_ATTRIBUTE_CATEGORY                    => p_cust_acct_site_rec.attribute_category,
        X_ATTRIBUTE1                            => p_cust_acct_site_rec.attribute1,
        X_ATTRIBUTE2                            => p_cust_acct_site_rec.attribute2,
        X_ATTRIBUTE3                            => p_cust_acct_site_rec.attribute3,
        X_ATTRIBUTE4                            => p_cust_acct_site_rec.attribute4,
        X_ATTRIBUTE5                            => p_cust_acct_site_rec.attribute5,
        X_ATTRIBUTE6                            => p_cust_acct_site_rec.attribute6,
        X_ATTRIBUTE7                            => p_cust_acct_site_rec.attribute7,
        X_ATTRIBUTE8                            => p_cust_acct_site_rec.attribute8,
        X_ATTRIBUTE9                            => p_cust_acct_site_rec.attribute9,
        X_ATTRIBUTE10                           => p_cust_acct_site_rec.attribute10,
        X_ATTRIBUTE11                           => p_cust_acct_site_rec.attribute11,
        X_ATTRIBUTE12                           => p_cust_acct_site_rec.attribute12,
        X_ATTRIBUTE13                           => p_cust_acct_site_rec.attribute13,
        X_ATTRIBUTE14                           => p_cust_acct_site_rec.attribute14,
        X_ATTRIBUTE15                           => p_cust_acct_site_rec.attribute15,
        X_ATTRIBUTE16                           => p_cust_acct_site_rec.attribute16,
        X_ATTRIBUTE17                           => p_cust_acct_site_rec.attribute17,
        X_ATTRIBUTE18                           => p_cust_acct_site_rec.attribute18,
        X_ATTRIBUTE19                           => p_cust_acct_site_rec.attribute19,
        X_ATTRIBUTE20                           => p_cust_acct_site_rec.attribute20,
        X_GLOBAL_ATTRIBUTE_CATEGORY             => p_cust_acct_site_rec.global_attribute_category,
        X_GLOBAL_ATTRIBUTE1                     => p_cust_acct_site_rec.global_attribute1,
        X_GLOBAL_ATTRIBUTE2                     => p_cust_acct_site_rec.global_attribute2,
        X_GLOBAL_ATTRIBUTE3                     => p_cust_acct_site_rec.global_attribute3,
        X_GLOBAL_ATTRIBUTE4                     => p_cust_acct_site_rec.global_attribute4,
        X_GLOBAL_ATTRIBUTE5                     => p_cust_acct_site_rec.global_attribute5,
        X_GLOBAL_ATTRIBUTE6                     => p_cust_acct_site_rec.global_attribute6,
        X_GLOBAL_ATTRIBUTE7                     => p_cust_acct_site_rec.global_attribute7,
        X_GLOBAL_ATTRIBUTE8                     => p_cust_acct_site_rec.global_attribute8,
        X_GLOBAL_ATTRIBUTE9                     => p_cust_acct_site_rec.global_attribute9,
        X_GLOBAL_ATTRIBUTE10                    => p_cust_acct_site_rec.global_attribute10,
        X_GLOBAL_ATTRIBUTE11                    => p_cust_acct_site_rec.global_attribute11,
        X_GLOBAL_ATTRIBUTE12                    => p_cust_acct_site_rec.global_attribute12,
        X_GLOBAL_ATTRIBUTE13                    => p_cust_acct_site_rec.global_attribute13,
        X_GLOBAL_ATTRIBUTE14                    => p_cust_acct_site_rec.global_attribute14,
        X_GLOBAL_ATTRIBUTE15                    => p_cust_acct_site_rec.global_attribute15,
        X_GLOBAL_ATTRIBUTE16                    => p_cust_acct_site_rec.global_attribute16,
        X_GLOBAL_ATTRIBUTE17                    => p_cust_acct_site_rec.global_attribute17,
        X_GLOBAL_ATTRIBUTE18                    => p_cust_acct_site_rec.global_attribute18,
        X_GLOBAL_ATTRIBUTE19                    => p_cust_acct_site_rec.global_attribute19,
        X_GLOBAL_ATTRIBUTE20                    => p_cust_acct_site_rec.global_attribute20,
        X_ORIG_SYSTEM_REFERENCE                 => p_cust_acct_site_rec.orig_system_reference,
        X_STATUS                                => p_cust_acct_site_rec.status,
        X_CUSTOMER_CATEGORY_CODE                => p_cust_acct_site_rec.customer_category_code,
        X_LANGUAGE                              => p_cust_acct_site_rec.language,
        X_KEY_ACCOUNT_FLAG                      => p_cust_acct_site_rec.key_account_flag,
        X_TP_HEADER_ID                          => p_cust_acct_site_rec.tp_header_id,
        X_ECE_TP_LOCATION_CODE                  => p_cust_acct_site_rec.ece_tp_location_code,
        X_PRIMARY_SPECIALIST_ID                 => p_cust_acct_site_rec.primary_specialist_id,
        X_SECONDARY_SPECIALIST_ID               => p_cust_acct_site_rec.secondary_specialist_id,
        X_TERRITORY_ID                          => p_cust_acct_site_rec.territory_id,
        X_TERRITORY                             => p_cust_acct_site_rec.territory,
        X_TRANSLATED_CUSTOMER_NAME              => p_cust_acct_site_rec.translated_customer_name,
        X_OBJECT_VERSION_NUMBER                 => 1,
        X_CREATED_BY_MODULE                     => p_cust_acct_site_rec.created_by_module,
        X_APPLICATION_ID                        => p_cust_acct_site_rec.application_id,
        X_ORG_ID                                => p_cust_acct_site_rec.org_id  -- Bug 3456489
    );



    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'HZ_CUST_ACCT_SITES_PKG.Insert_Row (-) ' ||
                                          'x_cust_acct_site_id = ' || p_cust_acct_site_rec.cust_acct_site_id,
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;


--if (p_cust_acct_site_rec.orig_system_reference is not null and l_party_rec.orig_system_reference<>fnd_api.g_miss_char )-for two tables has null osr.
 if (p_cust_acct_site_rec.orig_system is not null and p_cust_acct_site_rec.orig_system <>fnd_api.g_miss_char)
  then
  l_orig_sys_reference_rec.orig_system := p_cust_acct_site_rec.orig_system;
  l_orig_sys_reference_rec.orig_system_reference := l_orig_system_reference;
  l_orig_sys_reference_rec.owner_table_name := 'HZ_CUST_ACCT_SITES_ALL';
  l_orig_sys_reference_rec.owner_table_id := p_cust_acct_site_rec.cust_acct_site_id;
  l_orig_sys_reference_rec.created_by_module := p_cust_acct_site_rec.created_by_module;

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

x_cust_acct_site_id := p_cust_acct_site_rec.cust_acct_site_id;

    -- Populate data into tax assignment table.

    SELECT LOC.LOCATION_ID INTO l_location_id
    FROM HZ_LOCATIONS LOC,
         HZ_PARTY_SITES PARTY_SITE,
         HZ_CUST_ACCT_SITES_ALL ACCT_SITE     -- Bug 3456489
    WHERE ACCT_SITE.CUST_ACCT_SITE_ID = p_cust_acct_site_rec.cust_acct_site_id
    AND ACCT_SITE.PARTY_SITE_ID = PARTY_SITE.PARTY_SITE_ID
    AND PARTY_SITE.LOCATION_ID = LOC.LOCATION_ID;

    HZ_TAX_ASSIGNMENT_V2PUB.create_loc_assignment (
        p_location_id                  => l_location_id,
        p_created_by_module            => p_cust_acct_site_rec.created_by_module,
        p_application_id               => p_cust_acct_site_rec.application_id,
        x_return_status                => x_return_status,
        x_msg_count                    => l_msg_count,
        x_msg_data                     => l_msg_data,
        x_loc_id                       => l_loc_id
    );

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        IF x_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
        ELSE
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
    END IF;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'do_create_cust_acct_site (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

END do_create_cust_acct_site;

PROCEDURE do_unset_prim_cust_site_use(
        p_site_use_code         IN      varchar2,
        p_cust_acct_site_id     IN      number,
        p_org_id                IN      number    -- TCA SSA Uptake (Bug 3456489)
) IS
  l_cust_acct_id                      number;
  l_site_use_id                       number;
  l_cust_acct_site_id                 number;

  CURSOR c_site (l_cust_acct_id VARCHAR2) IS
    SELECT su.site_use_id,su.cust_acct_site_id
    FROM hz_cust_accounts a,
         hz_cust_acct_sites_all cas,
         hz_cust_site_uses_all su
    WHERE a.cust_account_id = l_cust_acct_id
    AND  l_cust_acct_id = cas.cust_account_id
    AND  cas.cust_acct_site_id = su.cust_acct_site_id
    AND  su.site_use_code = p_site_use_code
    AND  su.status = 'A'
    AND  su.primary_flag = 'Y'
    AND  cas.org_id = p_org_id
    AND  su.org_id  = p_org_id;

   r_site c_site%ROWTYPE;
   l_cnt   NUMBER;
   l_debug_prefix                          VARCHAR2(30) := '';

  BEGIN

   BEGIN
    SELECT cust_account_id into l_cust_acct_id
    FROM   hz_cust_acct_sites_all  -- Bug 3456489
    WHERE  cust_acct_site_id = p_cust_acct_site_id;
   END;


   BEGIN
    -- Modified for fix 3294182.
    SELECT su.site_use_id,su.cust_acct_site_id
    INTO l_site_use_id,l_cust_acct_site_id
    FROM hz_cust_accounts a,
         hz_cust_acct_sites_all cas,  -- Bug 3456489
         hz_cust_site_uses_all su     -- Bug 3456489
    WHERE a.cust_account_id = l_cust_acct_id
    AND  l_cust_acct_id = cas.cust_account_id
    AND  cas.cust_acct_site_id = su.cust_acct_site_id
    AND  su.site_use_code = p_site_use_code
    AND  su.status = 'A'
    AND  su.primary_flag = 'Y'
    AND  cas.org_id = p_org_id   -- TCA SSA Uptake (Bug 3456489)
    AND  su.org_id  = p_org_id;  -- TCA SSA Uptake (Bug 3456489)

    UPDATE hz_cust_site_uses_all -- Bug 3456489
    SET primary_flag = 'N',
        last_updated_by  = hz_utility_pub.LAST_UPDATED_BY,
 	  last_update_date = hz_utility_pub.LAST_UPDATE_DATE
    WHERE site_use_id =l_site_use_id;

    denormalize_site_use_flag(l_cust_acct_site_id,p_site_use_code,'Y');

  EXCEPTION
    WHEN no_data_found THEN
      NULL;
    --Bug9218025
    --Functionally there will be only Active Primary record
    --In exceptional case bad data (multiple) records might created by system
    --To handle such scenario making all existing Primary records to non-primary
    WHEN TOO_MANY_ROWS THEN
        -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'do_unset_prim_cust_site_use - TOO_MANY_ROWS Exception',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'Mulitiple rows found for Cust Acct Id '||l_cust_acct_id||' and Site Use Code '||p_site_use_code,
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;



      OPEN c_site(l_cust_acct_id);
      LOOP
        FETCH c_site INTO r_site;

           IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
               hz_utility_v2pub.debug(p_message=>'TOO_MANY_ROWS Excp Site Use Id '||r_site.site_use_id,
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
           END IF;


        UPDATE hz_cust_site_uses_all -- Bug 3456489
        SET primary_flag = 'N',
            last_updated_by  = hz_utility_pub.LAST_UPDATED_BY,
 	        last_update_date = hz_utility_pub.LAST_UPDATE_DATE
        WHERE site_use_id =r_site.site_use_id;

        denormalize_site_use_flag(r_site.cust_acct_site_id,p_site_use_code,'Y');
           IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
               hz_utility_v2pub.debug(p_message=>'TOO_MANY_ROWS Excp Denormalization done for Acct Site Id '||r_site.cust_acct_site_id||' and Site use Code '||p_site_use_code,
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
           END IF;
        EXIT WHEN c_site%NOTFOUND;
      END LOOP;
      CLOSE c_site;


  END;
  END do_unset_prim_cust_site_use;


/**
 * PRIVATE PROCEDURE do_update_cust_acct_site
 *
 * DESCRIPTION
 *     Private procedure to update customer account site.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *     HZ_ACCOUNT_VALIDATE_V2PUB.validate_cust_acct_site
 *     HZ_CUST_ACCT_SITES_PKG.Update_Row
 *
 * ARGUMENTS
 *   IN/OUT:
 *     p_cust_acct_site_rec           Customer account site record.
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
 *   07-23-2001    Jianying Huang       o Created.
 *
 *  24-JUN-2004  V.Ravichandran         o Bug 3714636.Modified do_update_cust_acct_site()
 *                                        to reduce cost of query
 *                                        which checks whether the message name in
 *                                        FND_NEW_MESSAGES is 'HZ_INACTIVATE_ACCOUNT_SITE_UI'.
 *  02-AUG-2004  Rajib Ranjan Borah     o Bug 3805019.party_site_id can be null during update.
 *                                        Therefore read the value of party_site_id from the
 *                                        database instead of using p_cust_acct_site_rec.party_site_id
 *                                        for synchronizing the status in HZ_PARTY_SITES.
 *                                      o Moreover the cursor does not pick rowid.
 *                                      o Removed redundant local variables l_dummy, l_ps_rowid.
 *  12-MAY-2005   Rajib Ranjan Borah    o TCA SSA Uptake (Bug 3456489)
 */

PROCEDURE do_update_cust_acct_site (
    p_cust_acct_site_rec                    IN OUT NOCOPY CUST_ACCT_SITE_REC_TYPE,
    p_object_version_number                 IN OUT NOCOPY NUMBER,
    x_return_status                         IN OUT NOCOPY VARCHAR2
) IS

    l_debug_prefix                          VARCHAR2(30) := ''; --'do_update_cust_acct_site';
    l_msg_count                             NUMBER;
    l_msg_data                              VARCHAR2(2000);
    l_rowid                                 ROWID := NULL;
    l_object_version_number                 NUMBER;
    l_location_id                           NUMBER;
    l_loc_id                                NUMBER;
    l_orig_sys_reference_rec                HZ_ORIG_SYSTEM_REF_PUB.ORIG_SYS_REFERENCE_REC_TYPE;


   /* 3456489 Added org_id for Shared Service Uptake */

    CURSOR check_orig_sys_ref IS
    select 'Y' from hz_cust_acct_sites_all
    where orig_system_reference =
    p_cust_acct_site_rec.orig_system_reference
    and org_id = p_cust_acct_site_rec.org_id;

    l_orig_system_reference varchar2(255) :=p_cust_acct_site_rec.orig_system_reference;
    l_tmp varchar2(1);
    l_status            varchar2(1);
    l_party_site_rec                        HZ_PARTY_SITE_V2PUB.PARTY_SITE_REC_TYPE;
    l_party_site_id                         HZ_CUST_ACCT_SITES.party_site_id%TYPE;
--  l_ps_rowid                              ROWID := NULL;
    l_ps_object_version_number              NUMBER;
--  l_dummy                                 VARCHAR2(1);

  BEGIN

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'do_update_cust_acct_site (+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Lock record.

    /* 3456489 Added org_id for Shared Services Uptake. */

    BEGIN
        SELECT ROWID, OBJECT_VERSION_NUMBER,status, PARTY_SITE_ID, org_id
        INTO l_rowid, l_object_version_number,l_status, l_party_site_id,
             p_cust_acct_site_rec.org_id
        FROM HZ_CUST_ACCT_SITES
        WHERE CUST_ACCT_SITE_ID = p_cust_acct_site_rec.cust_acct_site_id
        FOR UPDATE NOWAIT;

        IF NOT (
            ( p_object_version_number IS NULL AND l_object_version_number IS NULL ) OR
            ( p_object_version_number IS NOT NULL AND
              l_object_version_number IS NOT NULL AND
              p_object_version_number = l_object_version_number ) )
        THEN
            FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_RECORD_CHANGED' );
            FND_MESSAGE.SET_TOKEN( 'TABLE', 'hz_cust_acct_sites' );
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        END IF;

        p_object_version_number := NVL( l_object_version_number, 1 ) + 1;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_NO_RECORD' );
            FND_MESSAGE.SET_TOKEN( 'RECORD', 'customer account site' );
            FND_MESSAGE.SET_TOKEN( 'VALUE',
                NVL( TO_CHAR( p_cust_acct_site_rec.cust_acct_site_id ), 'null' ) );
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
    END;



    -- Validate cust acct site record
    HZ_ACCOUNT_VALIDATE_V2PUB.validate_cust_acct_site (
        p_create_update_flag                    => 'U',
        p_cust_acct_site_rec                    => p_cust_acct_site_rec,
        p_rowid                                 => l_rowid,
        x_return_status                         => x_return_status );

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    if (p_cust_acct_site_rec.orig_system is not null
         and p_cust_acct_site_rec.orig_system <>fnd_api.g_miss_char)
        and (p_cust_acct_site_rec.orig_system_reference is not null
         and p_cust_acct_site_rec.orig_system_reference <>fnd_api.g_miss_char)
    then
                p_cust_acct_site_rec.orig_system_reference := null;
                -- In mosr, we have bypassed osr nonupdateable validation
                -- but we should not update existing osr, set it to null
    end if;


    --
    --- Check if account site status is changed(Bug 3299622)
    --
    IF p_cust_acct_site_rec.status <> l_status THEN
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
                FND_MESSAGE.SET_TOKEN('VALUE', 'HZ_INACTIVATE_ACCOUNT_SITE_UI');
                FND_MSG_PUB.ADD;
                RAISE FND_API.G_EXC_ERROR;
          END;
          END IF;
    IF g_message_name IS NOT NULL THEN
     -- Code modified for Bug 3714636 ends here
    BEGIN
        SELECT /*ROWID,*/ OBJECT_VERSION_NUMBER
        INTO  /*l_ps_rowid,*/ l_ps_object_version_number
        FROM  HZ_PARTY_SITES
        WHERE PARTY_SITE_ID = l_party_site_id /* Bug 3805019: p_cust_acct_site_rec.party_site_id */
        FOR UPDATE NOWAIT;

        --p_object_version_number := NVL( l_object_version_number, 1 ) + 1;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_NO_RECORD' );
            FND_MESSAGE.SET_TOKEN( 'RECORD', 'party site' );
            FND_MESSAGE.SET_TOKEN( 'VALUE',
                NVL( TO_CHAR( p_cust_acct_site_rec.party_site_id ), 'null' ) );
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
    END;
    l_party_site_rec.party_site_id := l_party_site_id;
    l_party_site_rec.status := p_cust_acct_site_rec.status;

        -- Call party site api to synch status with account site status
    HZ_PARTY_SITE_V2PUB.update_party_site(
                p_party_site_rec                =>  l_party_site_rec,
                p_object_version_number         =>  l_ps_object_version_number,
                x_return_status                 =>  x_return_status,
                x_msg_count                     =>  l_msg_count,
                x_msg_data                      =>  l_msg_data) ;

            IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                RAISE FND_API.G_EXC_ERROR;
            END IF;

    END IF; -- End of account site status check
    END IF;
    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'HZ_CUST_ACCT_SITES_PKG.Update_Row (+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Call table-handler.
    HZ_CUST_ACCT_SITES_PKG.Update_Row (
        X_Rowid                                 => l_rowid,
        X_CUST_ACCT_SITE_ID                     => p_cust_acct_site_rec.cust_acct_site_id,
        X_CUST_ACCOUNT_ID                       => p_cust_acct_site_rec.cust_account_id,
        X_PARTY_SITE_ID                         => p_cust_acct_site_rec.party_site_id,
        X_ATTRIBUTE_CATEGORY                    => p_cust_acct_site_rec.attribute_category,
        X_ATTRIBUTE1                            => p_cust_acct_site_rec.attribute1,
        X_ATTRIBUTE2                            => p_cust_acct_site_rec.attribute2,
        X_ATTRIBUTE3                            => p_cust_acct_site_rec.attribute3,
        X_ATTRIBUTE4                            => p_cust_acct_site_rec.attribute4,
        X_ATTRIBUTE5                            => p_cust_acct_site_rec.attribute5,
        X_ATTRIBUTE6                            => p_cust_acct_site_rec.attribute6,
        X_ATTRIBUTE7                            => p_cust_acct_site_rec.attribute7,
        X_ATTRIBUTE8                            => p_cust_acct_site_rec.attribute8,
        X_ATTRIBUTE9                            => p_cust_acct_site_rec.attribute9,
        X_ATTRIBUTE10                           => p_cust_acct_site_rec.attribute10,
        X_ATTRIBUTE11                           => p_cust_acct_site_rec.attribute11,
        X_ATTRIBUTE12                           => p_cust_acct_site_rec.attribute12,
        X_ATTRIBUTE13                           => p_cust_acct_site_rec.attribute13,
        X_ATTRIBUTE14                           => p_cust_acct_site_rec.attribute14,
        X_ATTRIBUTE15                           => p_cust_acct_site_rec.attribute15,
        X_ATTRIBUTE16                           => p_cust_acct_site_rec.attribute16,
        X_ATTRIBUTE17                           => p_cust_acct_site_rec.attribute17,
        X_ATTRIBUTE18                           => p_cust_acct_site_rec.attribute18,
        X_ATTRIBUTE19                           => p_cust_acct_site_rec.attribute19,
        X_ATTRIBUTE20                           => p_cust_acct_site_rec.attribute20,
        X_GLOBAL_ATTRIBUTE_CATEGORY             => p_cust_acct_site_rec.global_attribute_category,
        X_GLOBAL_ATTRIBUTE1                     => p_cust_acct_site_rec.global_attribute1,
        X_GLOBAL_ATTRIBUTE2                     => p_cust_acct_site_rec.global_attribute2,
        X_GLOBAL_ATTRIBUTE3                     => p_cust_acct_site_rec.global_attribute3,
        X_GLOBAL_ATTRIBUTE4                     => p_cust_acct_site_rec.global_attribute4,
        X_GLOBAL_ATTRIBUTE5                     => p_cust_acct_site_rec.global_attribute5,
        X_GLOBAL_ATTRIBUTE6                     => p_cust_acct_site_rec.global_attribute6,
        X_GLOBAL_ATTRIBUTE7                     => p_cust_acct_site_rec.global_attribute7,
        X_GLOBAL_ATTRIBUTE8                     => p_cust_acct_site_rec.global_attribute8,
        X_GLOBAL_ATTRIBUTE9                     => p_cust_acct_site_rec.global_attribute9,
        X_GLOBAL_ATTRIBUTE10                    => p_cust_acct_site_rec.global_attribute10,
        X_GLOBAL_ATTRIBUTE11                    => p_cust_acct_site_rec.global_attribute11,
        X_GLOBAL_ATTRIBUTE12                    => p_cust_acct_site_rec.global_attribute12,
        X_GLOBAL_ATTRIBUTE13                    => p_cust_acct_site_rec.global_attribute13,
        X_GLOBAL_ATTRIBUTE14                    => p_cust_acct_site_rec.global_attribute14,
        X_GLOBAL_ATTRIBUTE15                    => p_cust_acct_site_rec.global_attribute15,
        X_GLOBAL_ATTRIBUTE16                    => p_cust_acct_site_rec.global_attribute16,
        X_GLOBAL_ATTRIBUTE17                    => p_cust_acct_site_rec.global_attribute17,
        X_GLOBAL_ATTRIBUTE18                    => p_cust_acct_site_rec.global_attribute18,
        X_GLOBAL_ATTRIBUTE19                    => p_cust_acct_site_rec.global_attribute19,
        X_GLOBAL_ATTRIBUTE20                    => p_cust_acct_site_rec.global_attribute20,
        X_ORIG_SYSTEM_REFERENCE                 => p_cust_acct_site_rec.orig_system_reference,
        X_STATUS                                => null, /*p_cust_acct_site_rec.status (bug 3299622)*/
        X_CUSTOMER_CATEGORY_CODE                => p_cust_acct_site_rec.customer_category_code,
        X_LANGUAGE                              => p_cust_acct_site_rec.language,
        X_KEY_ACCOUNT_FLAG                      => p_cust_acct_site_rec.key_account_flag,
        X_TP_HEADER_ID                          => p_cust_acct_site_rec.tp_header_id,
        X_ECE_TP_LOCATION_CODE                  => p_cust_acct_site_rec.ece_tp_location_code,
        X_PRIMARY_SPECIALIST_ID                 => p_cust_acct_site_rec.primary_specialist_id,
        X_SECONDARY_SPECIALIST_ID               => p_cust_acct_site_rec.secondary_specialist_id,
        X_TERRITORY_ID                          => p_cust_acct_site_rec.territory_id,
        X_TERRITORY                             => p_cust_acct_site_rec.territory,
        X_TRANSLATED_CUSTOMER_NAME              => p_cust_acct_site_rec.translated_customer_name,
        X_OBJECT_VERSION_NUMBER                 => p_object_version_number,
        X_CREATED_BY_MODULE                     => p_cust_acct_site_rec.created_by_module,
        X_APPLICATION_ID                        => p_cust_acct_site_rec.application_id
    );

    -- Update location should populate the change to tax assignment.
    -- Bug Fix : 2230802.
   SELECT LOC.LOCATION_ID INTO l_location_id
    FROM HZ_LOCATIONS LOC,
         HZ_PARTY_SITES PARTY_SITE,
         HZ_CUST_ACCT_SITES_ALL ACCT_SITE  -- Bug 3456489
    WHERE ACCT_SITE.CUST_ACCT_SITE_ID = p_cust_acct_site_rec.cust_acct_site_id
    AND ACCT_SITE.PARTY_SITE_ID = PARTY_SITE.PARTY_SITE_ID
    AND PARTY_SITE.LOCATION_ID = LOC.LOCATION_ID;

    HZ_TAX_ASSIGNMENT_V2PUB.update_loc_assignment (
        p_location_id                  => l_location_id,
        p_created_by_module            => p_cust_acct_site_rec.created_by_module,
        p_application_id               => p_cust_acct_site_rec.application_id,
        x_return_status                => x_return_status,
        x_msg_count                    => l_msg_count,
        x_msg_data                     => l_msg_data,
        x_loc_id                       => l_loc_id
    );

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        IF x_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
        ELSE
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
    END IF;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'HZ_CUST_ACCT_SITES_PKG.Update_Row (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'do_update_cust_acct_site (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

END do_update_cust_acct_site;

/**
 * PRIVATE PROCEDURE do_create_cust_site_use
 *
 * DESCRIPTION
 *     Private procedure to create customer account site use.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *     HZ_ACCOUNT_VALIDATE_V2PUB.validate_cust_site_use
 *     HZ_CUST_SITE_USES_PKG.Insert_Row
 *
 * ARGUMENTS
 *   IN:
 *     p_create_profile               If it is set to FND_API.G_TRUE, API create customer
 *                                    profile based on the customer profile record passed
 *                                    in.
 *     p_create_profile_amt           If it is set to FND_API.G_TRUE, API create customer
 *                                    profile amounts by copying corresponding data
 *                                    from customer profile class amounts.
 *   IN/OUT:
 *     p_cust_site_use_rec            Customer account site use record.
 *     p_customer_profile_rec         Customer profile record. One customer account
 *                                    must have a customer profile.
 *     x_return_status                Return status after the call. The status can
 *                                    be FND_API.G_RET_STS_SUCCESS (success),
 *                                    FND_API.G_RET_STS_ERROR (error),
 *                                    FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
 *   OUT:
 *     x_site_use_id                  Customer account site use ID.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   07-23-2001    Jianying Huang      o Created.
 *   12-22-2003    Rajib Ranjan Borah  o Bug 3322154.The status field was not considered in the
 *                                       check to find out if a party site use record is also to
 *                                       be created.
 *   12-MAY-2005   Rajib Ranjan Borah  o TCA SSA Uptake (Bug 3456489)
 *   26-Sep-2007   Sudhir Gokavarapu   o Bug 6315081  [FORWARD PORT BUG 6132727] Modified primary site
 *                                       use existance check query for performance issues
 */

PROCEDURE do_create_cust_site_use (
    p_cust_site_use_rec                     IN OUT NOCOPY CUST_SITE_USE_REC_TYPE,
    p_customer_profile_rec                  IN OUT NOCOPY HZ_CUSTOMER_PROFILE_V2PUB.CUSTOMER_PROFILE_REC_TYPE,
    p_create_profile                        IN     VARCHAR2 := FND_API.G_TRUE,
    p_create_profile_amt                    IN     VARCHAR2 := FND_API.G_TRUE,
    x_site_use_id                           OUT NOCOPY    NUMBER,
    x_return_status                         IN OUT NOCOPY VARCHAR2
) IS

    l_debug_prefix                          VARCHAR2(30) := ''; --'do_create_cust_site_use'

    l_dummy                                 VARCHAR2(1);
    l_message_count                         NUMBER;
    l_msg_count                             NUMBER;
    l_msg_data                              VARCHAR2(2000);
    l_flag                                  VARCHAR2(1);
    l_return_status                         VARCHAR2(1);

    l_party_site_use_rec                    HZ_PARTY_SITE_V2PUB.PARTY_SITE_USE_REC_TYPE;
    l_party_site_id                         NUMBER;
    l_party_site_use_id                     NUMBER;
    l_cust_account_profile_id               NUMBER;
    l_bill_to_flag                          HZ_CUST_ACCT_SITES.bill_to_flag%TYPE;
    l_ship_to_flag                          HZ_CUST_ACCT_SITES.ship_to_flag%TYPE;
    l_market_flag                           HZ_CUST_ACCT_SITES.market_flag%TYPE;
    l_orig_sys_reference_rec                HZ_ORIG_SYSTEM_REF_PUB.ORIG_SYS_REFERENCE_REC_TYPE;

    l_cnt               number := 1;
    l_cust_acct_id      number;
     --    Bug 8970479 : Cursor to get cust_account_profile_id from table hz_customer_profiles
 	 --    if record already exists for this site with 'DUNNING' or 'STATEMENTS' site_use_id
 	     CURSOR c_check_site_use_id IS
 	     SELECT hcp.cust_account_profile_id
 	     FROM   hz_customer_profiles hcp,
 	            hz_cust_site_uses_all hcsu
 	     WHERE  hcsu.cust_acct_site_id = p_cust_site_use_rec.cust_acct_site_id
 	     AND    hcp.site_use_id = hcsu.site_use_id
 	     AND    hcsu.site_use_code IN ('DUN','STMTS');

 	     l_cust_acct_prof_id HZ_CUSTOMER_PROFILES.CUST_ACCOUNT_PROFILE_ID%TYPE ;
BEGIN

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'do_create_cust_site_use (+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    /* 3456489 Added for Shared Service Uptake */
    IF (p_cust_site_use_rec.org_id is NULL or
        p_cust_site_use_rec.org_id = fnd_api.g_miss_num) then
          BEGIN
                SELECT  org_id
                INTO    p_cust_site_use_rec.org_id
                FROM    HZ_CUST_ACCT_SITES_ALL
                WHERE   cust_acct_site_id
                        = p_cust_site_use_rec.cust_acct_site_id;
          EXCEPTION
             WHEN NO_DATA_FOUND THEN
                FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_NO_RECORD' );
                FND_MESSAGE.SET_TOKEN( 'RECORD', 'customer account site' );
                FND_MESSAGE.SET_TOKEN( 'VALUE',
                    NVL( TO_CHAR(
                        p_cust_site_use_rec.cust_acct_site_id ), 'null' ) );
                FND_MSG_PUB.ADD;
                RAISE FND_API.G_EXC_ERROR;
          END;
    END IF;

    BEGIN
    MO_GLOBAL.validate_orgid_pub_api(p_cust_site_use_rec.org_id,'N',l_return_status);
    EXCEPTION
    WHEN OTHERS
    THEN
      RAISE FND_API.G_EXC_ERROR;
    END;


    -- Validate site use record.
    HZ_ACCOUNT_VALIDATE_V2PUB.validate_cust_site_use (
        p_create_update_flag                    => 'C',
        p_cust_site_use_rec                     => p_cust_site_use_rec,
        p_rowid                                 => NULL,
        x_return_status                         => x_return_status );

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

   -- Create party site use of same type if one does not exist.

    l_message_count := FND_MSG_PUB.Count_Msg();

    HZ_UTILITY_V2PUB.validate_lookup (
        p_column                                => 'site_use_code',
        p_lookup_type                           => 'PARTY_SITE_USE_CODE',
        p_column_value                          => p_cust_site_use_rec.site_use_code,
        x_return_status                         => x_return_status );

    -- Debug info.
    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_message=>'check if site_use_code is a valid site_use_code in party level. ' ||
            'x_return_status = ' || x_return_status,
                                  p_prefix =>l_debug_prefix,
                                  p_msg_level=>fnd_log.level_statement);
    END IF;

    -- site_use_code is not in a valid site_use_code in party level.
    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        FND_MSG_PUB.DELETE_MSG( l_message_count + 1 );
        x_return_status := FND_API.G_RET_STS_SUCCESS;
    ELSE
        -- Create party site use
        SELECT PARTY_SITE_ID INTO l_party_site_id
        FROM HZ_CUST_ACCT_SITES_ALL  -- Bug 3456489
        WHERE CUST_ACCT_SITE_ID = p_cust_site_use_rec.cust_acct_site_id;

        BEGIN
            SELECT 'Y' INTO l_dummy
            FROM HZ_PARTY_SITE_USES
            WHERE PARTY_SITE_ID = l_party_site_id
            AND   SITE_USE_TYPE = p_cust_site_use_rec.site_use_code
            AND   STATUS        = 'A';  --Bug 3322154
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                l_party_site_use_rec.party_site_id := l_party_site_id;
                l_party_site_use_rec.site_use_type := p_cust_site_use_rec.site_use_code;
                l_party_site_use_rec.created_by_module := p_cust_site_use_rec.created_by_module;
                l_party_site_use_rec.application_id := p_cust_site_use_rec.application_id;

                HZ_PARTY_SITE_V2PUB.create_party_site_use (
                    p_party_site_use_rec         => l_party_site_use_rec,
                    x_return_status              => x_return_status,
                    x_msg_count                  => l_msg_count,
                    x_msg_data                   => l_msg_data,
                    x_party_site_use_id          => l_party_site_use_id );

                IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                        RAISE FND_API.G_EXC_ERROR;
                    ELSE
                        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                    END IF;
                END IF;
        END;
    END IF;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'HZ_CUST_SITE_USES_PKG.Insert_Row (+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Bug 2643624.
    -- The first active site usage for a combination of particular site and org
    -- combination is to be set to primary, and when a new record is entered with
    -- this combination with the primary flag set, then the first one must be unset.

    IF p_cust_site_use_rec.status IS NULL OR
       p_cust_site_use_rec.status = fnd_api.g_miss_char OR
       p_cust_site_use_rec.status = 'A'
    THEN
      IF p_cust_site_use_rec.primary_flag = 'Y' THEN
        --we must unset the previous set primary_flag.
        do_unset_prim_cust_site_use(p_cust_site_use_rec.site_use_code,
                                    p_cust_site_use_rec.cust_acct_site_id,
                                    p_cust_site_use_rec.org_id);
      ELSE

        BEGIN
          SELECT cust_account_id into l_cust_acct_id
            FROM hz_cust_acct_sites_all  -- Bug 3456489
           WHERE cust_acct_site_id = p_cust_site_use_rec.cust_acct_site_id;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            l_cnt := 0;
        END;

        IF l_cnt <> 0 THEN
                BEGIN
                  /*
                  -- Bug 6315081 : FORWARD PORT BUG 6132727
                  -- New Query Below
                  SELECT count(*) into l_cnt
                    FROM hz_cust_accounts a,
                         hz_cust_acct_sites_all cas,
                         hz_cust_site_uses_all su
                   WHERE
                         a.cust_account_id = l_cust_acct_id
                    and  a.cust_account_id = cas.cust_account_id
                    and  cas.cust_acct_site_id = su.cust_acct_site_id
                    and  su.site_use_code = p_cust_site_use_rec.site_use_code
                    and  su.status = 'A'
                    and su.primary_flag = 'Y'
                    and  cas.org_id = p_cust_site_use_rec.org_id  -- TCA SSA Uptake (Bug 3456489)
                    and  su.org_id = p_cust_site_use_rec.org_id;  -- TCA SSA Uptake (Bug 3456489) */

                    SELECT count(*) into l_cnt
                    FROM hz_cust_acct_sites_all cas,
                         hz_cust_site_uses_all su
                   WHERE
                         cas.cust_account_id = l_cust_acct_id
                    and  cas.status = 'A'
                    and  cas.cust_acct_site_id = su.cust_acct_site_id
                    and  su.site_use_code = p_cust_site_use_rec.site_use_code
                    and  su.status = 'A'
                    and su.primary_flag = 'Y'
                    and  cas.org_id = p_cust_site_use_rec.org_id  -- TCA SSA Uptake (Bug 3456489)
                    and  su.org_id = p_cust_site_use_rec.org_id  -- TCA SSA Uptake (Bug 3456489)
                    and  rownum <=1 ;
                END;
        END IF;

        IF l_cnt <= 0 THEN
          p_cust_site_use_rec.primary_flag := 'Y';
        ELSE
          p_cust_site_use_rec.primary_flag := 'N';
        END IF;

      END IF;
    END IF;

    -- Call table-handler.
    HZ_CUST_SITE_USES_PKG.Insert_Row (
        X_SITE_USE_ID                           => p_cust_site_use_rec.site_use_id,
        X_CUST_ACCT_SITE_ID                     => p_cust_site_use_rec.cust_acct_site_id,
        X_SITE_USE_CODE                         => p_cust_site_use_rec.site_use_code,
        X_PRIMARY_FLAG                          => p_cust_site_use_rec.primary_flag,
        X_STATUS                                => p_cust_site_use_rec.status,
        X_LOCATION                              => p_cust_site_use_rec.location,
        X_CONTACT_ID                            => p_cust_site_use_rec.contact_id,
        X_BILL_TO_SITE_USE_ID                   => p_cust_site_use_rec.bill_to_site_use_id,
        X_ORIG_SYSTEM_REFERENCE                 => p_cust_site_use_rec.orig_system_reference,
        X_SIC_CODE                              => p_cust_site_use_rec.sic_code,
        X_PAYMENT_TERM_ID                       => p_cust_site_use_rec.payment_term_id,
        X_GSA_INDICATOR                         => p_cust_site_use_rec.gsa_indicator,
        X_SHIP_PARTIAL                          => p_cust_site_use_rec.ship_partial,
        X_SHIP_VIA                              => p_cust_site_use_rec.ship_via,
        X_FOB_POINT                             => p_cust_site_use_rec.fob_point,
        X_ORDER_TYPE_ID                         => p_cust_site_use_rec.order_type_id,
        X_PRICE_LIST_ID                         => p_cust_site_use_rec.price_list_id,
        X_FREIGHT_TERM                          => p_cust_site_use_rec.freight_term,
        X_WAREHOUSE_ID                          => p_cust_site_use_rec.warehouse_id,
        X_TERRITORY_ID                          => p_cust_site_use_rec.territory_id,
        X_ATTRIBUTE_CATEGORY                    => p_cust_site_use_rec.attribute_category,
        X_ATTRIBUTE1                            => p_cust_site_use_rec.attribute1,
        X_ATTRIBUTE2                            => p_cust_site_use_rec.attribute2,
        X_ATTRIBUTE3                            => p_cust_site_use_rec.attribute3,
        X_ATTRIBUTE4                            => p_cust_site_use_rec.attribute4,
        X_ATTRIBUTE5                            => p_cust_site_use_rec.attribute5,
        X_ATTRIBUTE6                            => p_cust_site_use_rec.attribute6,
        X_ATTRIBUTE7                            => p_cust_site_use_rec.attribute7,
        X_ATTRIBUTE8                            => p_cust_site_use_rec.attribute8,
        X_ATTRIBUTE9                            => p_cust_site_use_rec.attribute9,
        X_ATTRIBUTE10                           => p_cust_site_use_rec.attribute10,
        X_TAX_REFERENCE                         => p_cust_site_use_rec.tax_reference,
        X_SORT_PRIORITY                         => p_cust_site_use_rec.sort_priority,
        X_TAX_CODE                              => p_cust_site_use_rec.tax_code,
        X_ATTRIBUTE11                           => p_cust_site_use_rec.attribute11,
        X_ATTRIBUTE12                           => p_cust_site_use_rec.attribute12,
        X_ATTRIBUTE13                           => p_cust_site_use_rec.attribute13,
        X_ATTRIBUTE14                           => p_cust_site_use_rec.attribute14,
        X_ATTRIBUTE15                           => p_cust_site_use_rec.attribute15,
        X_ATTRIBUTE16                           => p_cust_site_use_rec.attribute16,
        X_ATTRIBUTE17                           => p_cust_site_use_rec.attribute17,
        X_ATTRIBUTE18                           => p_cust_site_use_rec.attribute18,
        X_ATTRIBUTE19                           => p_cust_site_use_rec.attribute19,
        X_ATTRIBUTE20                           => p_cust_site_use_rec.attribute20,
        X_ATTRIBUTE21                           => p_cust_site_use_rec.attribute21,
        X_ATTRIBUTE22                           => p_cust_site_use_rec.attribute22,
        X_ATTRIBUTE23                           => p_cust_site_use_rec.attribute23,
        X_ATTRIBUTE24                           => p_cust_site_use_rec.attribute24,
        X_ATTRIBUTE25                           => p_cust_site_use_rec.attribute25,
        X_DEMAND_CLASS_CODE                     => p_cust_site_use_rec.demand_class_code,
        X_TAX_HEADER_LEVEL_FLAG                 => p_cust_site_use_rec.tax_header_level_flag,
        X_TAX_ROUNDING_RULE                     => p_cust_site_use_rec.tax_rounding_rule,
        X_GLOBAL_ATTRIBUTE1                     => p_cust_site_use_rec.global_attribute1,
        X_GLOBAL_ATTRIBUTE2                     => p_cust_site_use_rec.global_attribute2,
        X_GLOBAL_ATTRIBUTE3                     => p_cust_site_use_rec.global_attribute3,
        X_GLOBAL_ATTRIBUTE4                     => p_cust_site_use_rec.global_attribute4,
        X_GLOBAL_ATTRIBUTE5                     => p_cust_site_use_rec.global_attribute5,
        X_GLOBAL_ATTRIBUTE6                     => p_cust_site_use_rec.global_attribute6,
        X_GLOBAL_ATTRIBUTE7                     => p_cust_site_use_rec.global_attribute7,
        X_GLOBAL_ATTRIBUTE8                     => p_cust_site_use_rec.global_attribute8,
        X_GLOBAL_ATTRIBUTE9                     => p_cust_site_use_rec.global_attribute9,
        X_GLOBAL_ATTRIBUTE10                    => p_cust_site_use_rec.global_attribute10,
        X_GLOBAL_ATTRIBUTE11                    => p_cust_site_use_rec.global_attribute11,
        X_GLOBAL_ATTRIBUTE12                    => p_cust_site_use_rec.global_attribute12,
        X_GLOBAL_ATTRIBUTE13                    => p_cust_site_use_rec.global_attribute13,
        X_GLOBAL_ATTRIBUTE14                    => p_cust_site_use_rec.global_attribute14,
        X_GLOBAL_ATTRIBUTE15                    => p_cust_site_use_rec.global_attribute15,
        X_GLOBAL_ATTRIBUTE16                    => p_cust_site_use_rec.global_attribute16,
        X_GLOBAL_ATTRIBUTE17                    => p_cust_site_use_rec.global_attribute17,
        X_GLOBAL_ATTRIBUTE18                    => p_cust_site_use_rec.global_attribute18,
        X_GLOBAL_ATTRIBUTE19                    => p_cust_site_use_rec.global_attribute19,
        X_GLOBAL_ATTRIBUTE20                    => p_cust_site_use_rec.global_attribute20,
        X_GLOBAL_ATTRIBUTE_CATEGORY             => p_cust_site_use_rec.global_attribute_category,
        X_PRIMARY_SALESREP_ID                   => p_cust_site_use_rec.primary_salesrep_id,
        X_FINCHRG_RECEIVABLES_TRX_ID            => p_cust_site_use_rec.finchrg_receivables_trx_id,
        X_DATES_NEGATIVE_TOLERANCE              => p_cust_site_use_rec.dates_negative_tolerance,
        X_DATES_POSITIVE_TOLERANCE              => p_cust_site_use_rec.dates_positive_tolerance,
        X_DATE_TYPE_PREFERENCE                  => p_cust_site_use_rec.date_type_preference,
        X_OVER_SHIPMENT_TOLERANCE               => p_cust_site_use_rec.over_shipment_tolerance,
        X_UNDER_SHIPMENT_TOLERANCE              => p_cust_site_use_rec.under_shipment_tolerance,
        X_ITEM_CROSS_REF_PREF                   => p_cust_site_use_rec.item_cross_ref_pref,
        X_OVER_RETURN_TOLERANCE                 => p_cust_site_use_rec.over_return_tolerance,
        X_UNDER_RETURN_TOLERANCE                => p_cust_site_use_rec.under_return_tolerance,
        X_SHIP_SETS_INCLUDE_LINES_FLAG          => p_cust_site_use_rec.ship_sets_include_lines_flag,
        X_ARRIVALSETS_INCLUDE_LINES_FG          => p_cust_site_use_rec.arrivalsets_include_lines_flag,
        X_SCHED_DATE_PUSH_FLAG                  => p_cust_site_use_rec.sched_date_push_flag,
        X_INVOICE_QUANTITY_RULE                 => p_cust_site_use_rec.invoice_quantity_rule,
        X_PRICING_EVENT                         => p_cust_site_use_rec.pricing_event,
        X_GL_ID_REC                             => p_cust_site_use_rec.gl_id_rec,
        X_GL_ID_REV                             => p_cust_site_use_rec.gl_id_rev,
        X_GL_ID_TAX                             => p_cust_site_use_rec.gl_id_tax,
        X_GL_ID_FREIGHT                         => p_cust_site_use_rec.gl_id_freight,
        X_GL_ID_CLEARING                        => p_cust_site_use_rec.gl_id_clearing,
        X_GL_ID_UNBILLED                        => p_cust_site_use_rec.gl_id_unbilled,
        X_GL_ID_UNEARNED                        => p_cust_site_use_rec.gl_id_unearned,
        X_GL_ID_UNPAID_REC                      => p_cust_site_use_rec.gl_id_unpaid_rec,
        X_GL_ID_REMITTANCE                      => p_cust_site_use_rec.gl_id_remittance,
        X_GL_ID_FACTOR                          => p_cust_site_use_rec.gl_id_factor,
        X_TAX_CLASSIFICATION                    => p_cust_site_use_rec.tax_classification,
        X_OBJECT_VERSION_NUMBER                 => 1,
        X_CREATED_BY_MODULE                     => p_cust_site_use_rec.created_by_module,
        X_APPLICATION_ID                        => p_cust_site_use_rec.application_id,
        X_ORG_ID                                => p_cust_site_use_rec.org_id  -- Bug 3456489
    );

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'HZ_CUST_SITE_USES_PKG.Insert_Row (-) ' ||
            'x_site_use_id = ' || p_cust_site_use_rec.site_use_id,
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

      /*Bug 8970479 :
 	     Updating tables hz_customer_profiles and hz_cust_profile_amts if bill-to business
 	     purpose is created and if these 2 tables contains site_use_id of 'DUNNING' or 'STATEMENTS'
 	     business purposes for current site*/

 	     IF (p_cust_site_use_rec.site_use_code = 'BILL_TO') THEN

 	         OPEN c_check_site_use_id ;
 	         FETCH c_check_site_use_id INTO l_cust_account_profile_id ;

 	         IF (c_check_site_use_id%FOUND) THEN

 	             UPDATE hz_customer_profiles
 	             SET    site_use_id = p_cust_site_use_rec.site_use_id
 	             WHERE  cust_account_profile_id = l_cust_account_profile_id ;

 	             UPDATE hz_cust_profile_amts
 	             SET    site_use_id = p_cust_site_use_rec.site_use_id
 	             WHERE  cust_account_profile_id = l_cust_account_profile_id ;

 	     -- Debug info.
 	     IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
 	         hz_utility_v2pub.debug(p_message=>'Updated hz_customer_profiles and hz_cust_profiles/amts with site_use_id of DUNNING or STATEMENTS'             ,
 	                       p_prefix =>l_debug_prefix,
 	                      p_msg_level=>fnd_log.level_statement);
 	     END IF;
 	     -- Debug info.
 	     IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
 	         hz_utility_v2pub.debug(p_message=>'Updated Site Use Id '||p_cust_site_use_rec.site_use_id ||' at Profile Id '||l_cust_account_profile_id,
 	                       p_prefix =>l_debug_prefix,
 	                      p_msg_level=>fnd_log.level_statement);
 	     END IF;

 	         END IF;
 	         CLOSE c_check_site_use_id ;

 	     END IF;

 	     /*Bug 8970479 : END */

if (p_cust_site_use_rec.orig_system_reference is not null and p_cust_site_use_rec.orig_system_reference <>fnd_api.g_miss_char ) then
    if (p_cust_site_use_rec.orig_system is null OR p_cust_site_use_rec.orig_system =fnd_api.g_miss_char) then
      p_cust_site_use_rec.orig_system := 'UNKNOWN';
    end if;
end if;


if (p_cust_site_use_rec.orig_system is not null and p_cust_site_use_rec.orig_system<>fnd_api.g_miss_char ) then

  l_orig_sys_reference_rec.orig_system := p_cust_site_use_rec.orig_system;
  l_orig_sys_reference_rec.orig_system_reference := p_cust_site_use_rec.orig_system_reference;
  l_orig_sys_reference_rec.owner_table_name := 'HZ_CUST_SITE_USES_ALL';
  l_orig_sys_reference_rec.owner_table_id := p_cust_site_use_rec.site_use_id;
  l_orig_sys_reference_rec.created_by_module := p_cust_site_use_rec.created_by_module;
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

    -- If this is a active bill_to or ship_to or market,
    -- set the appropriate denormalized flag in hz_cust_acct_sites.

    IF p_cust_site_use_rec.site_use_code IN ('BILL_TO', 'SHIP_TO', 'MARKET' ) THEN
       IF p_cust_site_use_rec.status = 'A' OR
          p_cust_site_use_rec.status IS NULL OR
          p_cust_site_use_rec.status = FND_API.G_MISS_CHAR
       THEN
          IF p_cust_site_use_rec.primary_flag = 'Y' THEN
              l_flag := 'P';
          ELSE
              l_flag := 'Y';
          END IF;
       ELSE
          l_flag := NULL;
       END IF;

       denormalize_site_use_flag (
           p_cust_site_use_rec.cust_acct_site_id,
           p_cust_site_use_rec.site_use_code,
           l_flag );

    END IF;

    IF p_create_profile = FND_API.G_TRUE THEN

        -- Create the profile for the site use

        p_customer_profile_rec.site_use_id := p_cust_site_use_rec.site_use_id;
        p_customer_profile_rec.created_by_module := p_cust_site_use_rec.created_by_module;
        p_customer_profile_rec.application_id := p_cust_site_use_rec.application_id;

        SELECT CUST_ACCOUNT_ID INTO p_customer_profile_rec.cust_account_id
        FROM HZ_CUST_ACCT_SITES_ALL  -- Bug 3456489
        WHERE CUST_ACCT_SITE_ID = p_cust_site_use_rec.cust_acct_site_id;

        HZ_CUSTOMER_PROFILE_V2PUB.create_customer_profile (
            p_customer_profile_rec       => p_customer_profile_rec,
            p_create_profile_amt         => p_create_profile_amt,
            x_return_status              => x_return_status,
            x_msg_count                  => l_msg_count,
            x_msg_data                   => l_msg_data,
            x_cust_account_profile_id    => l_cust_account_profile_id );

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
            ELSE
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
        END IF;

    END IF;

    x_site_use_id := p_cust_site_use_rec.site_use_id;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'do_create_cust_site_use (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;


END do_create_cust_site_use;

/**
 * PRIVATE PROCEDURE do_update_cust_site_use
 *
 * DESCRIPTION
 *     Private procedure to update customer account site use.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *     HZ_ACCOUNT_VALIDATE_V2PUB.validate_cust_site_use
 *     HZ_CUST_SITE_USES_PKG.Update_Row
 *
 * ARGUMENTS
 *   IN/OUT:
 *     p_cust_site_use_rec            Customer account site use record.
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
 *   09-08-2003    Rajib Ranjan Borah  o Bug 3085557.Site Use flag was earlier not updated
 *                                       if the user had modified the STATUS flag.
 *   12-08-2003    Rajib Ranjan Borah  o Bug 3294182.Site use flags are now updated for scenarios
 *                                       introduced by fix 2643624.
 *   12-MAY-2005   Rajib Ranjan Borah  o TCA SSA Uptake (Bug 3456489)
 *  26-Sep-2007  Sudhir Gokavarapu     o Bug 6315081  [FORWARD PORT BUG6132727]  Changed do_create_cust_site_use
 *                                       and do_update_cust_site_use api.
 */

PROCEDURE do_update_cust_site_use (
    p_cust_site_use_rec                     IN OUT NOCOPY CUST_SITE_USE_REC_TYPE,
    p_object_version_number                 IN OUT NOCOPY NUMBER,
    x_return_status                         IN OUT NOCOPY VARCHAR2
) IS

    l_debug_prefix                          VARCHAR2(30) := ''; --'do_update_cust_site_use'

    l_rowid                                 ROWID := NULL;
    l_object_version_number                 NUMBER;
    l_flag                                  VARCHAR2(1);
    l_denormalize                           BOOLEAN := FALSE;

    l_site_use_code                         HZ_CUST_SITE_USES.site_use_code%TYPE;
    l_cust_acct_site_id                     NUMBER;
    l_primary_flag                          HZ_CUST_SITE_USES.primary_flag%TYPE;
    l_status                                HZ_CUST_SITE_USES.status%TYPE;
    l_orig_sys_reference_rec                HZ_ORIG_SYSTEM_REF_PUB.ORIG_SYS_REFERENCE_REC_TYPE;

/* Bug Fix:5036975 */
    l_party_site_use_id                     HZ_PARTY_SITE_USES.party_site_use_id%TYPE;
    l_party_site_use_rec                    HZ_PARTY_SITE_V2PUB.PARTY_SITE_USE_REC_TYPE;
    l_created_by_module                     HZ_CUST_SITE_USES.created_by_module%TYPE;
    l_application_id                        HZ_CUST_SITE_USES.application_id%TYPE;
    l_message_count                         NUMBER;
    l_party_site_id                         NUMBER;
    l_dummy                                 VARCHAR2(1);
    l_msg_count                             NUMBER;
    l_msg_data                              VARCHAR2(2000);
/* Bug Fix : 5036975 */

    l_cnt               number := 1;
    l_cust_acct_id      number;
    l_minrowid          rowid;
    --Bug 3294182
    l_casid             number;


BEGIN

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=> 'do_update_cust_site_use (+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;


   /* Bug 3456489 Modified for Shared Services Uptake. */

    -- Lock record.
    BEGIN
        SELECT ROWID, OBJECT_VERSION_NUMBER, CUST_ACCT_SITE_ID,
               SITE_USE_CODE, PRIMARY_FLAG, STATUS, ORG_ID,CREATED_BY_MODULE,APPLICATION_ID
        INTO l_rowid, l_object_version_number,
             l_cust_acct_site_id, l_site_use_code, l_primary_flag, l_status,
                p_cust_site_use_rec.org_id,l_created_by_module,l_application_id
        FROM HZ_CUST_SITE_USES
        WHERE SITE_USE_ID = p_cust_site_use_rec.site_use_id
        FOR UPDATE NOWAIT;

        IF NOT (
            ( p_object_version_number IS NULL AND
                l_object_version_number IS NULL ) OR
            ( p_object_version_number IS NOT NULL AND
              l_object_version_number IS NOT NULL AND
              p_object_version_number = l_object_version_number ) )
        THEN
            FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_RECORD_CHANGED' );
            FND_MESSAGE.SET_TOKEN( 'TABLE', 'hz_cust_site_uses' );
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        END IF;

        p_object_version_number := NVL( l_object_version_number, 1 ) + 1;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_NO_RECORD' );
            FND_MESSAGE.SET_TOKEN( 'RECORD', 'customer site use' );
            FND_MESSAGE.SET_TOKEN( 'VALUE',
                NVL( TO_CHAR( p_cust_site_use_rec.site_use_id ), 'null' ) );
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
    END;

    -- Validate cust site use record
    HZ_ACCOUNT_VALIDATE_V2PUB.validate_cust_site_use (
        p_create_update_flag                    => 'U',
        p_cust_site_use_rec                     => p_cust_site_use_rec,
        p_rowid                                 => l_rowid,
        x_return_status                         => x_return_status );

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

---Create party site use of same type if one does not exist.
--Bug No. 5036975
IF p_cust_site_use_rec.status = 'A' THEN
       l_message_count := FND_MSG_PUB.Count_Msg();
          HZ_UTILITY_V2PUB.validate_lookup (
        p_column                                => 'site_use_code',
        p_lookup_type                           => 'PARTY_SITE_USE_CODE',
        p_column_value                          => p_cust_site_use_rec.site_use_code,
        x_return_status                         => x_return_status );

       -- Debug info.
       IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
                  hz_utility_v2pub.debug(p_message=>'check if site_use_code is a valid site_use_code in party level. ' ||
            'x_return_status = ' || x_return_status,
                                  p_prefix =>l_debug_prefix,
                                  p_msg_level=>fnd_log.level_statement);
       END IF;

       -- site_use_code is not in a valid site_use_code in party level.
       IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                 FND_MSG_PUB.DELETE_MSG( l_message_count + 1 );
          x_return_status := FND_API.G_RET_STS_SUCCESS;
       ELSE
       -- Create party site use

          SELECT PARTY_SITE_ID INTO l_party_site_id
          FROM HZ_CUST_ACCT_SITES_ALL
          WHERE CUST_ACCT_SITE_ID = l_cust_acct_site_id;
                    BEGIN
            SELECT 'Y' INTO l_dummy
            FROM HZ_PARTY_SITE_USES
            WHERE PARTY_SITE_ID = l_party_site_id
            AND   SITE_USE_TYPE = l_site_use_code
            AND   STATUS        = 'A';
          EXCEPTION
            WHEN NO_DATA_FOUND THEN

                l_party_site_use_rec.party_site_id := l_party_site_id;
                l_party_site_use_rec.site_use_type := l_site_use_code;
                l_party_site_use_rec.created_by_module := l_created_by_module;
                l_party_site_use_rec.application_id := l_application_id;


                HZ_PARTY_SITE_V2PUB.create_party_site_use (
                    p_party_site_use_rec         => l_party_site_use_rec,
                    x_return_status              => x_return_status,
                    x_msg_count                  => l_msg_count,
                    x_msg_data                   => l_msg_data,
                    x_party_site_use_id          => l_party_site_use_id );

                IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                        RAISE FND_API.G_EXC_ERROR;
                    ELSE
                        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                    END IF;
                END IF;
           END;
         END IF;
    END IF;

    -- Debug info.
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'HZ_CUST_SITE_USES_PKG.Insert_Row (+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;
--Bug Fix:5036975

    if (p_cust_site_use_rec.orig_system is not null
         and p_cust_site_use_rec.orig_system <>fnd_api.g_miss_char)
        and (p_cust_site_use_rec.orig_system_reference is not null
         and p_cust_site_use_rec.orig_system_reference <>fnd_api.g_miss_char)
    then
                p_cust_site_use_rec.orig_system_reference := null;
                -- In mosr, we have bypassed osr nonupdateable validation
                -- but we should not update existing osr, set it to null
    end if;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'HZ_CUST_SITE_USES_PKG.Update_Row (+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;


    -- Bug 2643624.
    -- During modification of the primary_flag, if we are setting the primary flag
    -- of a particular combination of org and cust_account as primary then the already
    -- existing such combination would be unset if already primary.
    IF p_cust_site_use_rec.primary_flag = 'N' OR
       p_cust_site_use_rec.primary_flag = fnd_api.g_miss_char
    THEN
      p_cust_site_use_rec.primary_flag := NULL;
    END IF;



    IF (p_cust_site_use_rec.status IS NULL AND
        l_status = 'A') OR
        p_cust_site_use_rec.status = 'A'
    THEN
      IF p_cust_site_use_rec.primary_flag = 'Y' AND
         l_primary_flag <> 'Y'
      THEN

        do_unset_prim_cust_site_use(l_site_use_code,
                                    l_cust_acct_site_id,
                                    p_cust_site_use_rec.org_id);

      ELSIF l_primary_flag <> 'Y' THEN


        BEGIN
          SELECT cust_account_id into l_cust_acct_id
            FROM hz_cust_acct_sites_all   -- Bug 3456489
           WHERE cust_acct_site_id = l_cust_acct_site_id;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            l_cnt := 0;
        END;

        IF l_cnt <> 0 THEN
                BEGIN
                  /*
                  -- Bug 6315081 : FORWARD PORT BUG 6132727
                  -- New Query Below
                  SELECT count(*) into l_cnt
                    FROM hz_cust_accounts a,
                         hz_cust_acct_sites_all cas,
                         hz_cust_site_uses_all su
                   WHERE
                         a.cust_account_id = l_cust_acct_id
                    and  a.cust_account_id = cas.cust_account_id
                    and  cas.cust_acct_site_id = su.cust_acct_site_id
                    and  su.site_use_code = l_site_use_code
                    and su.site_use_id <> p_cust_site_use_rec.site_use_id
                    and  su.status = 'A'
                    and su.primary_flag = 'Y'
                    and cas.org_id = p_cust_site_use_rec.org_id  -- TCA SSA Uptake (Bug 3456489)
                    and su.org_id = p_cust_site_use_rec.org_id;  -- TCA SSA Uptake (Bug 3456489) */

                  SELECT count(*) into l_cnt
                    FROM hz_cust_acct_sites_all cas,
                         hz_cust_site_uses_all su
                   WHERE
                         cas.cust_account_id = l_cust_acct_id
                    and  cas.status = 'A'
                    and  cas.cust_acct_site_id = su.cust_acct_site_id
                    and  su.site_use_code = l_site_use_code
                    and su.site_use_id <> p_cust_site_use_rec.site_use_id
                    and  su.status = 'A'
                    and su.primary_flag = 'Y'
                    and cas.org_id = p_cust_site_use_rec.org_id  -- TCA SSA Uptake (Bug 3456489)
                    and su.org_id = p_cust_site_use_rec.org_id  -- TCA SSA Uptake (Bug 3456489)
                    and rownum <= 1;
                END;
        END IF;

        IF l_cnt <= 0 THEN
          p_cust_site_use_rec.primary_flag := 'Y';
        ELSE
          p_cust_site_use_rec.primary_flag := 'N';
        END IF;
      END IF;
    ELSE
      IF l_status = 'A' AND
         p_cust_site_use_rec.status = 'I' AND
         l_primary_flag = 'Y'
      THEN
        p_cust_site_use_rec.primary_flag := 'N';

        BEGIN
          SELECT cust_account_id into l_cust_acct_id
            FROM hz_cust_acct_sites_all -- Bug 3456489
           WHERE cust_acct_site_id = l_cust_acct_site_id;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            l_cnt := 0;
        END;

        IF l_cnt > 0 THEN
                BEGIN
                  SELECT min(su.rowid),count(*) into l_minrowid,l_cnt
                    FROM hz_cust_accounts a,
                         hz_cust_acct_sites_all cas,   -- Bug 3456489
                         hz_cust_site_uses_all su    -- Bug 3456489
                   WHERE
                         a.cust_account_id = l_cust_acct_id
                    and  a.cust_account_id = cas.cust_account_id
                    and  cas.cust_acct_site_id = su.cust_acct_site_id
                    and  su.site_use_code = l_site_use_code
                    and su.site_use_id <> p_cust_site_use_rec.site_use_id
                    and  su.status = 'A'
                    and su.primary_flag = 'N'
                    and  cas.org_id = p_cust_site_use_rec.org_id  -- TCA SSA Uptake (Bug 3456489)
                    and  su.org_id  = p_cust_site_use_rec.org_id; -- TCA SSA Uptake (Bug 3456489)
                END;

                IF l_cnt > 0 THEN
                BEGIN
                  UPDATE hz_cust_site_uses_all  -- Bug 3456489
                  SET primary_flag = 'Y',
                      last_updated_by  = hz_utility_pub.LAST_UPDATED_BY,
 	                last_update_date = hz_utility_pub.LAST_UPDATE_DATE
                  WHERE rowid = l_minrowid;
                  -- Bug 3294182.
                  select cust_acct_site_id
                  into l_casid
                  from hz_cust_site_uses_all    -- Bug 3456489
                  where rowid=l_minrowid;
                  denormalize_site_use_flag(
                                 l_casid,
                                 nvl(p_cust_site_use_rec.site_use_code,l_site_use_code),
                                 'P');
                END;
                END IF;

        END IF;
      END IF;
    END IF;

    -- Call table-handler.
    HZ_CUST_SITE_USES_PKG.Update_Row (
        X_Rowid                                 => l_rowid,
        X_SITE_USE_ID                           => p_cust_site_use_rec.site_use_id,
        X_CUST_ACCT_SITE_ID                     => p_cust_site_use_rec.cust_acct_site_id,
        X_SITE_USE_CODE                         => p_cust_site_use_rec.site_use_code,
        X_PRIMARY_FLAG                          => p_cust_site_use_rec.primary_flag,
        X_STATUS                                => p_cust_site_use_rec.status,
        X_LOCATION                              => p_cust_site_use_rec.location,
        X_CONTACT_ID                            => p_cust_site_use_rec.contact_id,
        X_BILL_TO_SITE_USE_ID                   => p_cust_site_use_rec.bill_to_site_use_id,
        X_ORIG_SYSTEM_REFERENCE                 => p_cust_site_use_rec.orig_system_reference,
        X_SIC_CODE                              => p_cust_site_use_rec.sic_code,
        X_PAYMENT_TERM_ID                       => p_cust_site_use_rec.payment_term_id,
        X_GSA_INDICATOR                         => p_cust_site_use_rec.gsa_indicator,
        X_SHIP_PARTIAL                          => p_cust_site_use_rec.ship_partial,
        X_SHIP_VIA                              => p_cust_site_use_rec.ship_via,
        X_FOB_POINT                             => p_cust_site_use_rec.fob_point,
        X_ORDER_TYPE_ID                         => p_cust_site_use_rec.order_type_id,
        X_PRICE_LIST_ID                         => p_cust_site_use_rec.price_list_id,
        X_FREIGHT_TERM                          => p_cust_site_use_rec.freight_term,
        X_WAREHOUSE_ID                          => p_cust_site_use_rec.warehouse_id,
        X_TERRITORY_ID                          => p_cust_site_use_rec.territory_id,
        X_ATTRIBUTE_CATEGORY                    => p_cust_site_use_rec.attribute_category,
        X_ATTRIBUTE1                            => p_cust_site_use_rec.attribute1,
        X_ATTRIBUTE2                            => p_cust_site_use_rec.attribute2,
        X_ATTRIBUTE3                            => p_cust_site_use_rec.attribute3,
        X_ATTRIBUTE4                            => p_cust_site_use_rec.attribute4,
        X_ATTRIBUTE5                            => p_cust_site_use_rec.attribute5,
        X_ATTRIBUTE6                            => p_cust_site_use_rec.attribute6,
        X_ATTRIBUTE7                            => p_cust_site_use_rec.attribute7,
        X_ATTRIBUTE8                            => p_cust_site_use_rec.attribute8,
        X_ATTRIBUTE9                            => p_cust_site_use_rec.attribute9,
        X_ATTRIBUTE10                           => p_cust_site_use_rec.attribute10,
        X_TAX_REFERENCE                         => p_cust_site_use_rec.tax_reference,
        X_SORT_PRIORITY                         => p_cust_site_use_rec.sort_priority,
        X_TAX_CODE                              => p_cust_site_use_rec.tax_code,
        X_ATTRIBUTE11                           => p_cust_site_use_rec.attribute11,
        X_ATTRIBUTE12                           => p_cust_site_use_rec.attribute12,
        X_ATTRIBUTE13                           => p_cust_site_use_rec.attribute13,
        X_ATTRIBUTE14                           => p_cust_site_use_rec.attribute14,
        X_ATTRIBUTE15                           => p_cust_site_use_rec.attribute15,
        X_ATTRIBUTE16                           => p_cust_site_use_rec.attribute16,
        X_ATTRIBUTE17                           => p_cust_site_use_rec.attribute17,
        X_ATTRIBUTE18                           => p_cust_site_use_rec.attribute18,
        X_ATTRIBUTE19                           => p_cust_site_use_rec.attribute19,
        X_ATTRIBUTE20                           => p_cust_site_use_rec.attribute20,
        X_ATTRIBUTE21                           => p_cust_site_use_rec.attribute21,
        X_ATTRIBUTE22                           => p_cust_site_use_rec.attribute22,
        X_ATTRIBUTE23                           => p_cust_site_use_rec.attribute23,
        X_ATTRIBUTE24                           => p_cust_site_use_rec.attribute24,
        X_ATTRIBUTE25                           => p_cust_site_use_rec.attribute25,
        X_DEMAND_CLASS_CODE                     => p_cust_site_use_rec.demand_class_code,
        X_TAX_HEADER_LEVEL_FLAG                 => p_cust_site_use_rec.tax_header_level_flag,
        X_TAX_ROUNDING_RULE                     => p_cust_site_use_rec.tax_rounding_rule,
        X_GLOBAL_ATTRIBUTE1                     => p_cust_site_use_rec.global_attribute1,
        X_GLOBAL_ATTRIBUTE2                     => p_cust_site_use_rec.global_attribute2,
        X_GLOBAL_ATTRIBUTE3                     => p_cust_site_use_rec.global_attribute3,
        X_GLOBAL_ATTRIBUTE4                     => p_cust_site_use_rec.global_attribute4,
        X_GLOBAL_ATTRIBUTE5                     => p_cust_site_use_rec.global_attribute5,
        X_GLOBAL_ATTRIBUTE6                     => p_cust_site_use_rec.global_attribute6,
        X_GLOBAL_ATTRIBUTE7                     => p_cust_site_use_rec.global_attribute7,
        X_GLOBAL_ATTRIBUTE8                     => p_cust_site_use_rec.global_attribute8,
        X_GLOBAL_ATTRIBUTE9                     => p_cust_site_use_rec.global_attribute9,
        X_GLOBAL_ATTRIBUTE10                    => p_cust_site_use_rec.global_attribute10,
        X_GLOBAL_ATTRIBUTE11                    => p_cust_site_use_rec.global_attribute11,
        X_GLOBAL_ATTRIBUTE12                    => p_cust_site_use_rec.global_attribute12,
        X_GLOBAL_ATTRIBUTE13                    => p_cust_site_use_rec.global_attribute13,
        X_GLOBAL_ATTRIBUTE14                    => p_cust_site_use_rec.global_attribute14,
        X_GLOBAL_ATTRIBUTE15                    => p_cust_site_use_rec.global_attribute15,
        X_GLOBAL_ATTRIBUTE16                    => p_cust_site_use_rec.global_attribute16,
        X_GLOBAL_ATTRIBUTE17                    => p_cust_site_use_rec.global_attribute17,
        X_GLOBAL_ATTRIBUTE18                    => p_cust_site_use_rec.global_attribute18,
        X_GLOBAL_ATTRIBUTE19                    => p_cust_site_use_rec.global_attribute19,
        X_GLOBAL_ATTRIBUTE20                    => p_cust_site_use_rec.global_attribute20,
        X_GLOBAL_ATTRIBUTE_CATEGORY             => p_cust_site_use_rec.global_attribute_category,
        X_PRIMARY_SALESREP_ID                   => p_cust_site_use_rec.primary_salesrep_id,
        X_FINCHRG_RECEIVABLES_TRX_ID            => p_cust_site_use_rec.finchrg_receivables_trx_id,
        X_DATES_NEGATIVE_TOLERANCE              => p_cust_site_use_rec.dates_negative_tolerance,
        X_DATES_POSITIVE_TOLERANCE              => p_cust_site_use_rec.dates_positive_tolerance,
        X_DATE_TYPE_PREFERENCE                  => p_cust_site_use_rec.date_type_preference,
        X_OVER_SHIPMENT_TOLERANCE               => p_cust_site_use_rec.over_shipment_tolerance,
        X_UNDER_SHIPMENT_TOLERANCE              => p_cust_site_use_rec.under_shipment_tolerance,
        X_ITEM_CROSS_REF_PREF                   => p_cust_site_use_rec.item_cross_ref_pref,
        X_OVER_RETURN_TOLERANCE                 => p_cust_site_use_rec.over_return_tolerance,
        X_UNDER_RETURN_TOLERANCE                => p_cust_site_use_rec.under_return_tolerance,
        X_SHIP_SETS_INCLUDE_LINES_FLAG          => p_cust_site_use_rec.ship_sets_include_lines_flag,
        X_ARRIVALSETS_INCLUDE_LINES_FG          => p_cust_site_use_rec.arrivalsets_include_lines_flag,
        X_SCHED_DATE_PUSH_FLAG                  => p_cust_site_use_rec.sched_date_push_flag,
        X_INVOICE_QUANTITY_RULE                 => p_cust_site_use_rec.invoice_quantity_rule,
        X_PRICING_EVENT                         => p_cust_site_use_rec.pricing_event,
        X_GL_ID_REC                             => p_cust_site_use_rec.gl_id_rec,
        X_GL_ID_REV                             => p_cust_site_use_rec.gl_id_rev,
        X_GL_ID_TAX                             => p_cust_site_use_rec.gl_id_tax,
        X_GL_ID_FREIGHT                         => p_cust_site_use_rec.gl_id_freight,
        X_GL_ID_CLEARING                        => p_cust_site_use_rec.gl_id_clearing,
        X_GL_ID_UNBILLED                        => p_cust_site_use_rec.gl_id_unbilled,
        X_GL_ID_UNEARNED                        => p_cust_site_use_rec.gl_id_unearned,
        X_GL_ID_UNPAID_REC                      => p_cust_site_use_rec.gl_id_unpaid_rec,
        X_GL_ID_REMITTANCE                      => p_cust_site_use_rec.gl_id_remittance,
        X_GL_ID_FACTOR                          => p_cust_site_use_rec.gl_id_factor,
        X_TAX_CLASSIFICATION                    => p_cust_site_use_rec.tax_classification,
        X_OBJECT_VERSION_NUMBER                 => p_object_version_number,
        X_CREATED_BY_MODULE                     => p_cust_site_use_rec.created_by_module,
        X_APPLICATION_ID                        => p_cust_site_use_rec.application_id
    );

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'HZ_CUST_SITE_USES_PKG.Update_Row (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- If this is a active bill_to or ship_to or market,
    -- set the appropriate denormalized flag in hz_cust_acct_sites.
    -- Please note, primary_flag cannot be updated to NULL.

    IF l_site_use_code IN ('BILL_TO', 'SHIP_TO', 'MARKET' )
    THEN
       IF p_cust_site_use_rec.status = 'A' OR
          p_cust_site_use_rec.status IS NULL AND
          l_status = 'A'
       THEN
          IF
             (
                 (
                 l_primary_flag <> 'Y'
                 AND
                 p_cust_site_use_rec.primary_flag = 'Y'
                 )
             OR
                --Bug no 3085557
                 (
                 nvl(p_cust_site_use_rec.primary_flag,l_primary_flag) = 'Y'
                 AND
                 l_status<>'A'
                 )
             )
          THEN
              l_flag := 'P';
              l_denormalize := TRUE;
          ELSIF
             (
                  (
                  l_primary_flag = 'Y'
                  AND
                  p_cust_site_use_rec.primary_flag = 'N'
                  )
             OR
             --Bug no 3085557
                  (
                  nvl(p_cust_site_use_rec.primary_flag,l_primary_flag) = 'N'
                  AND
                  l_status<>'A'
                  )
             )
          THEN
              l_flag := 'Y';
              l_denormalize := TRUE;
          END IF;
       ELSIF p_cust_site_use_rec.status IS NOT NULL THEN
          l_flag := NULL;
          l_denormalize := TRUE;
       END IF;

       IF l_denormalize THEN
           denormalize_site_use_flag (
--Bugfix 2792589    p_cust_site_use_rec.cust_acct_site_id,
                 l_cust_acct_site_id,
--Bugfix 2792589    p_cust_site_use_rec.site_use_code,
               l_site_use_code,
               l_flag );
       END IF;
    END IF;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'do_update_cust_site_use (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

END do_update_cust_site_use;

/**
 * PRIVATE PROCEDURE denormalize_site_use_flag
 *
 * DESCRIPTION
 *     Private procedure to denormalize bill_to_flag, ship_to_flag, market_flag
 *     in hz_cust_acct_sites.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN/OUT:
 *     p_cust_acct_site_id            Customer account site id.
 *     p_site_use_code                Site use code. Can only in (BILL_TO, SHIP_TO, MARKET)
 *     p_flag                         Flag used to update account site.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   07-23-2001    Jianying Huang      o Created.
 *   12-MAY-2005   Rajib Ranjan Borah  o TCA SSA Uptake (Bug 3456489)
 *
 */

PROCEDURE denormalize_site_use_flag (
    p_cust_acct_site_id                     IN     NUMBER,
    p_site_use_code                         IN     VARCHAR2,
    p_flag                                  IN     VARCHAR2
) IS

    l_debug_prefix                          VARCHAR2(30) := ''; --'denormalize_site_use_flag'

BEGIN

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'denormalize_site_use_flag (+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;


    IF p_site_use_code = 'BILL_TO' THEN
        UPDATE HZ_CUST_ACCT_SITES_ALL  -- Bug 3456489
        SET BILL_TO_FLAG = p_flag,
            last_updated_by  = hz_utility_pub.LAST_UPDATED_BY,
            last_update_date = hz_utility_pub.LAST_UPDATE_DATE
        WHERE CUST_ACCT_SITE_ID = p_cust_acct_site_id;
    ELSIF p_site_use_code = 'SHIP_TO' THEN
        UPDATE HZ_CUST_ACCT_SITES_ALL  -- Bug 3456489
        SET SHIP_TO_FLAG = p_flag,
            last_updated_by  = hz_utility_pub.LAST_UPDATED_BY,
            last_update_date = hz_utility_pub.LAST_UPDATE_DATE
        WHERE CUST_ACCT_SITE_ID = p_cust_acct_site_id;
    ELSIF p_site_use_code = 'MARKET' THEN
        UPDATE HZ_CUST_ACCT_SITES_ALL  -- Bug 3456489
        SET MARKET_FLAG = p_flag,
            last_updated_by  = hz_utility_pub.LAST_UPDATED_BY,
            last_update_date = hz_utility_pub.LAST_UPDATE_DATE
        WHERE CUST_ACCT_SITE_ID = p_cust_acct_site_id;
    END IF;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'denormalize_site_use_flag (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

END denormalize_site_use_flag;

--------------------------------------
-- public procedures and functions
--------------------------------------

/**
 * PROCEDURE create_cust_acct_site
 *
 * DESCRIPTION
 *     Creates customer account site.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *     HZ_BUSINESS_EVENT_V2PVT.create_cust_acct_site_event
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_cust_acct_site_rec           Customer account site record.
 *   IN/OUT:
 *   OUT:
 *     x_cust_acct_site_id            Customer account site ID.
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

PROCEDURE create_cust_acct_site (
    p_init_msg_list                         IN     VARCHAR2 := FND_API.G_FALSE,
    p_cust_acct_site_rec                    IN     CUST_ACCT_SITE_REC_TYPE,
    x_cust_acct_site_id                     OUT NOCOPY    NUMBER,
    x_return_status                         OUT NOCOPY    VARCHAR2,
    x_msg_count                             OUT NOCOPY    NUMBER,
    x_msg_data                              OUT NOCOPY    VARCHAR2
) IS

    l_cust_acct_site_rec                    CUST_ACCT_SITE_REC_TYPE := p_cust_acct_site_rec;
    l_debug_prefix                          VARCHAR2(30) := '';

BEGIN

    -- Standard start of API savepoint
    SAVEPOINT create_cust_acct_site;

    -- Check if API is called in debug mode. If yes, enable debug.
    --enable_debug;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'create_cust_acct_site (+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- report error on obsolete columns based on profile
    IF NVL(FND_PROFILE.VALUE('HZ_API_ERR_ON_OBSOLETE_COLUMN'), 'Y') = 'Y' THEN
      check_obsolete_columns (
        p_create_update_flag         => 'C',
        p_account_site_rec           => l_cust_acct_site_rec,
        x_return_status              => x_return_status
      );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;

    -- Call to business logic.
    do_create_cust_acct_site (
        l_cust_acct_site_rec,
        x_cust_acct_site_id,
        x_return_status );

   IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
     IF(HZ_UTILITY_V2PUB.G_EXECUTE_API_CALLOUTS in ('EVENTS_ENABLED', 'Y')) THEN
       -- Invoke business event system.
       HZ_BUSINESS_EVENT_V2PVT.create_cust_acct_site_event (
         l_cust_acct_site_rec );
     END IF;

     IF(HZ_UTILITY_V2PUB.G_EXECUTE_API_CALLOUTS in ('EVENTS_ENABLED', 'BO_EVENTS_ENABLED')) THEN
       -- populate function for integration service
       HZ_POPULATE_BOT_PKG.pop_hz_cust_acct_sites_all(
         p_operation         => 'I',
         p_cust_acct_site_id => x_cust_acct_site_id );
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
        hz_utility_v2pub.debug(p_message=>'create_cust_acct_site (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Check if API is called in debug mode. If yes, disable debug.
    --disable_debug;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO create_cust_acct_site;
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
            hz_utility_v2pub.debug(p_message=>'create_cust_acct_site (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
        END IF;

        -- Check if API is called in debug mode. If yes, disable debug.
        --disable_debug;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO create_cust_acct_site;
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
           hz_utility_v2pub.debug(p_message=>'create_cust_acct_site (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
        END IF;

        -- Check if API is called in debug mode. If yes, disable debug.
        --disable_debug;

    WHEN OTHERS THEN
        ROLLBACK TO create_cust_acct_site;
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
            hz_utility_v2pub.debug(p_message=> 'create_cust_acct_site (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
        END IF;

        -- Check if API is called in debug mode. If yes, disable debug.
        --disable_debug;

END create_cust_acct_site;

/**
 * PROCEDURE update_cust_acct_site
 *
 * DESCRIPTION
 *     Updates customer account site.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *     HZ_BUSINESS_EVENT_V2PVT.update_cust_acct_site_event
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_cust_acct_site_rec           Customer account site record.
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

PROCEDURE update_cust_acct_site (
    p_init_msg_list                         IN     VARCHAR2 := FND_API.G_FALSE,
    p_cust_acct_site_rec                    IN     CUST_ACCT_SITE_REC_TYPE,
    p_object_version_number                 IN OUT NOCOPY NUMBER,
    x_return_status                         OUT NOCOPY    VARCHAR2,
    x_msg_count                             OUT NOCOPY    NUMBER,
    x_msg_data                              OUT NOCOPY    VARCHAR2
) IS

    l_cust_acct_site_rec                    CUST_ACCT_SITE_REC_TYPE := p_cust_acct_site_rec;
    l_old_cust_acct_site_rec                CUST_ACCT_SITE_REC_TYPE;
    l_debug_prefix                          VARCHAR2(30) := '';

BEGIN

    -- Standard start of API savepoint
    SAVEPOINT update_cust_acct_site;

    -- Check if API is called in debug mode. If yes, enable debug.
    --enable_debug;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'update_cust_acct_site (+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF (p_cust_acct_site_rec.orig_system is not null and p_cust_acct_site_rec.orig_system <>fnd_api.g_miss_char)
      and (p_cust_acct_site_rec.orig_system_reference is not null and p_cust_acct_site_rec.orig_system_reference <>fnd_api.g_miss_char)
      and (p_cust_acct_site_rec.cust_acct_site_id = FND_API.G_MISS_NUM or p_cust_acct_site_rec.cust_acct_site_id is null) THEN

              hz_orig_system_ref_pub.get_owner_table_id
                 (p_orig_system => p_cust_acct_site_rec.orig_system,
                  p_orig_system_reference => p_cust_acct_site_rec.orig_system_reference,
                  p_owner_table_name => 'HZ_CUST_ACCT_SITES_ALL',
                  x_owner_table_id => l_cust_acct_site_rec.cust_acct_site_id,
                  x_return_status => x_return_status);
       IF x_return_status <> fnd_api.g_ret_sts_success THEN
        RAISE FND_API.G_EXC_ERROR;
       END IF;

      END IF;


   --2290537
    get_cust_acct_site_rec (
       p_cust_acct_site_id    => l_cust_acct_site_rec.cust_acct_site_id,
       x_cust_acct_site_rec   => l_old_cust_acct_site_rec,
       x_return_status        => x_return_status,
       x_msg_count            => x_msg_count,
       x_msg_data             => x_msg_data);

    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- report error on obsolete columns based on profile
    IF NVL(FND_PROFILE.VALUE('HZ_API_ERR_ON_OBSOLETE_COLUMN'), 'Y') = 'Y' THEN
      check_obsolete_columns (
        p_create_update_flag         => 'U',
        p_account_site_rec           => l_cust_acct_site_rec,
        p_old_account_site_rec       => l_old_cust_acct_site_rec,
        x_return_status              => x_return_status
      );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;

    -- Call to business logic.
    do_update_cust_acct_site (
        l_cust_acct_site_rec,
        p_object_version_number,
        x_return_status );

   IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
     l_old_cust_acct_site_rec.orig_system := l_cust_acct_site_rec.orig_system;
     IF(HZ_UTILITY_V2PUB.G_EXECUTE_API_CALLOUTS in ('EVENTS_ENABLED', 'Y')) THEN
       -- Invoke business event system.
       HZ_BUSINESS_EVENT_V2PVT.update_cust_acct_site_event (
         l_cust_acct_site_rec , l_old_cust_acct_site_rec );
     END IF;

     IF(HZ_UTILITY_V2PUB.G_EXECUTE_API_CALLOUTS in ('EVENTS_ENABLED', 'BO_EVENTS_ENABLED')) THEN
       -- populate function for integration service
       HZ_POPULATE_BOT_PKG.pop_hz_cust_acct_sites_all(
         p_operation         => 'U',
         p_cust_acct_site_id => l_cust_acct_site_rec.cust_acct_site_id );
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
        hz_utility_v2pub.debug(p_message=>'update_cust_acct_site (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Check if API is called in debug mode. If yes, disable debug.
    --disable_debug;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO update_cust_acct_site;
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
            hz_utility_v2pub.debug(p_message=>'update_cust_acct_site (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
        END IF;

        -- Check if API is called in debug mode. If yes, disable debug.
        --disable_debug;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO update_cust_acct_site;
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
           hz_utility_v2pub.debug(p_message=>'update_cust_acct_site (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
        END IF;

        -- Check if API is called in debug mode. If yes, disable debug.
        --disable_debug;

    WHEN OTHERS THEN
        ROLLBACK TO update_cust_acct_site;
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
            hz_utility_v2pub.debug(p_message=>'update_cust_acct_site (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
        END IF;

        -- Check if API is called in debug mode. If yes, disable debug.
        --disable_debug;

END update_cust_acct_site;

/**
 * PROCEDURE get_cust_acct_site_rec
 *
 * DESCRIPTION
 *      Gets customer account site record
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *     HZ_CUST_ACCT_SITES_PKG.Select_Row
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_cust_acct_site_id            Customer account site id.
 *   IN/OUT:
 *   OUT:
 *     x_cust_acct_site_rec           Returned customer account site record.
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

PROCEDURE get_cust_acct_site_rec (
    p_init_msg_list                         IN     VARCHAR2 := FND_API.G_FALSE,
    p_cust_acct_site_id                     IN     NUMBER,
    x_cust_acct_site_rec                    OUT    NOCOPY CUST_ACCT_SITE_REC_TYPE,
    x_return_status                         OUT NOCOPY    VARCHAR2,
    x_msg_count                             OUT NOCOPY    NUMBER,
    x_msg_data                              OUT NOCOPY    VARCHAR2
) IS
l_debug_prefix                      VARCHAR2(30) := '';
BEGIN

    -- Check if API is called in debug mode. If yes, enable debug.
    --enable_debug;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'get_cust_acct_site_rec (+)',
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
    IF p_cust_acct_site_id IS NULL OR
       p_cust_acct_site_id = FND_API.G_MISS_NUM THEN
        FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_MISSING_COLUMN' );
        FND_MESSAGE.SET_TOKEN( 'COLUMN', 'cust_acct_site_id' );
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    x_cust_acct_site_rec.cust_acct_site_id := p_cust_acct_site_id;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'HZ_CUST_ACCT_SITES_PKG.Select_Row (+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Call table-handler.
    HZ_CUST_ACCT_SITES_PKG.Select_Row (
        X_CUST_ACCT_SITE_ID                     => x_cust_acct_site_rec.cust_acct_site_id,
        X_CUST_ACCOUNT_ID                       => x_cust_acct_site_rec.cust_account_id,
        X_PARTY_SITE_ID                         => x_cust_acct_site_rec.party_site_id,
        X_ATTRIBUTE_CATEGORY                    => x_cust_acct_site_rec.attribute_category,
        X_ATTRIBUTE1                            => x_cust_acct_site_rec.attribute1,
        X_ATTRIBUTE2                            => x_cust_acct_site_rec.attribute2,
        X_ATTRIBUTE3                            => x_cust_acct_site_rec.attribute3,
        X_ATTRIBUTE4                            => x_cust_acct_site_rec.attribute4,
        X_ATTRIBUTE5                            => x_cust_acct_site_rec.attribute5,
        X_ATTRIBUTE6                            => x_cust_acct_site_rec.attribute6,
        X_ATTRIBUTE7                            => x_cust_acct_site_rec.attribute7,
        X_ATTRIBUTE8                            => x_cust_acct_site_rec.attribute8,
        X_ATTRIBUTE9                            => x_cust_acct_site_rec.attribute9,
        X_ATTRIBUTE10                           => x_cust_acct_site_rec.attribute10,
        X_ATTRIBUTE11                           => x_cust_acct_site_rec.attribute11,
        X_ATTRIBUTE12                           => x_cust_acct_site_rec.attribute12,
        X_ATTRIBUTE13                           => x_cust_acct_site_rec.attribute13,
        X_ATTRIBUTE14                           => x_cust_acct_site_rec.attribute14,
        X_ATTRIBUTE15                           => x_cust_acct_site_rec.attribute15,
        X_ATTRIBUTE16                           => x_cust_acct_site_rec.attribute16,
        X_ATTRIBUTE17                           => x_cust_acct_site_rec.attribute17,
        X_ATTRIBUTE18                           => x_cust_acct_site_rec.attribute18,
        X_ATTRIBUTE19                           => x_cust_acct_site_rec.attribute19,
        X_ATTRIBUTE20                           => x_cust_acct_site_rec.attribute20,
        X_GLOBAL_ATTRIBUTE_CATEGORY             => x_cust_acct_site_rec.global_attribute_category,
        X_GLOBAL_ATTRIBUTE1                     => x_cust_acct_site_rec.global_attribute1,
        X_GLOBAL_ATTRIBUTE2                     => x_cust_acct_site_rec.global_attribute2,
        X_GLOBAL_ATTRIBUTE3                     => x_cust_acct_site_rec.global_attribute3,
        X_GLOBAL_ATTRIBUTE4                     => x_cust_acct_site_rec.global_attribute4,
        X_GLOBAL_ATTRIBUTE5                     => x_cust_acct_site_rec.global_attribute5,
        X_GLOBAL_ATTRIBUTE6                     => x_cust_acct_site_rec.global_attribute6,
        X_GLOBAL_ATTRIBUTE7                     => x_cust_acct_site_rec.global_attribute7,
        X_GLOBAL_ATTRIBUTE8                     => x_cust_acct_site_rec.global_attribute8,
        X_GLOBAL_ATTRIBUTE9                     => x_cust_acct_site_rec.global_attribute9,
        X_GLOBAL_ATTRIBUTE10                    => x_cust_acct_site_rec.global_attribute10,
        X_GLOBAL_ATTRIBUTE11                    => x_cust_acct_site_rec.global_attribute11,
        X_GLOBAL_ATTRIBUTE12                    => x_cust_acct_site_rec.global_attribute12,
        X_GLOBAL_ATTRIBUTE13                    => x_cust_acct_site_rec.global_attribute13,
        X_GLOBAL_ATTRIBUTE14                    => x_cust_acct_site_rec.global_attribute14,
        X_GLOBAL_ATTRIBUTE15                    => x_cust_acct_site_rec.global_attribute15,
        X_GLOBAL_ATTRIBUTE16                    => x_cust_acct_site_rec.global_attribute16,
        X_GLOBAL_ATTRIBUTE17                    => x_cust_acct_site_rec.global_attribute17,
        X_GLOBAL_ATTRIBUTE18                    => x_cust_acct_site_rec.global_attribute18,
        X_GLOBAL_ATTRIBUTE19                    => x_cust_acct_site_rec.global_attribute19,
        X_GLOBAL_ATTRIBUTE20                    => x_cust_acct_site_rec.global_attribute20,
        X_ORIG_SYSTEM_REFERENCE                 => x_cust_acct_site_rec.orig_system_reference,
        X_STATUS                                => x_cust_acct_site_rec.status,
        X_CUSTOMER_CATEGORY_CODE                => x_cust_acct_site_rec.customer_category_code,
        X_LANGUAGE                              => x_cust_acct_site_rec.language,
        X_KEY_ACCOUNT_FLAG                      => x_cust_acct_site_rec.key_account_flag,
        X_TP_HEADER_ID                          => x_cust_acct_site_rec.tp_header_id,
        X_ECE_TP_LOCATION_CODE                  => x_cust_acct_site_rec.ece_tp_location_code,
        X_PRIMARY_SPECIALIST_ID                 => x_cust_acct_site_rec.primary_specialist_id,
        X_SECONDARY_SPECIALIST_ID               => x_cust_acct_site_rec.secondary_specialist_id,
        X_TERRITORY_ID                          => x_cust_acct_site_rec.territory_id,
        X_TERRITORY                             => x_cust_acct_site_rec.territory,
        X_TRANSLATED_CUSTOMER_NAME              => x_cust_acct_site_rec.translated_customer_name,
        X_CREATED_BY_MODULE                     => x_cust_acct_site_rec.created_by_module,
        X_APPLICATION_ID                        => x_cust_acct_site_rec.application_id,
        X_ORG_ID                                => x_cust_acct_site_rec.org_id   -- Bug 3456489
    );

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=> 'HZ_CUST_ACCT_SITES_PKG.Select_Row (-)',
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
        hz_utility_v2pub.debug(p_message=>'get_cust_acct_site_rec (-)',
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
            hz_utility_v2pub.debug(p_message=>'get_cust_acct_site_rec (-)',
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
           hz_utility_v2pub.debug(p_message=>'get_cust_acct_site_rec (-)',
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
            hz_utility_v2pub.debug(p_message=>'get_cust_acct_site_rec (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
        END IF;

        -- Check if API is called in debug mode. If yes, disable debug.
        --disable_debug;

END get_cust_acct_site_rec;

/**
 * PROCEDURE create_cust_site_use
 *
 * DESCRIPTION
 *     Creates customer account site use.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *     HZ_BUSINESS_EVENT_V2PVT.create_cust_site_use_event
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_cust_site_use_rec            Customer account site use record.
 *     p_customer_profile_rec         Customer profile record. One customer account
 *                                    must have a customer profile.
 *     p_create_profile               If it is set to FND_API.G_TRUE, API create customer
 *                                    profile based on the customer profile record passed
 *                                    in.
 *     p_create_profile_amt           If it is set to FND_API.G_TRUE, API create customer
 *                                    profile amounts by copying corresponding data
 *                                    from customer profile class amounts.
 *   IN/OUT:
 *   OUT:
 *     x_site_use_id                  Customer account site use ID.
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

PROCEDURE create_cust_site_use (
    p_init_msg_list                         IN     VARCHAR2 := FND_API.G_FALSE,
    p_cust_site_use_rec                     IN     CUST_SITE_USE_REC_TYPE,
    p_customer_profile_rec                  IN     HZ_CUSTOMER_PROFILE_V2PUB.CUSTOMER_PROFILE_REC_TYPE,
    p_create_profile                        IN     VARCHAR2 := FND_API.G_TRUE,
    p_create_profile_amt                    IN     VARCHAR2 := FND_API.G_TRUE,
    x_site_use_id                           OUT NOCOPY    NUMBER,
    x_return_status                         OUT NOCOPY    VARCHAR2,
    x_msg_count                             OUT NOCOPY    NUMBER,
    x_msg_data                              OUT NOCOPY    VARCHAR2
) IS

    l_cust_site_use_rec                     CUST_SITE_USE_REC_TYPE := p_cust_site_use_rec;
    l_customer_profile_rec                  HZ_CUSTOMER_PROFILE_V2PUB.CUSTOMER_PROFILE_REC_TYPE := p_customer_profile_rec;
    l_debug_prefix                          VARCHAR2(30) := '';

BEGIN

    -- Standard start of API savepoint
    SAVEPOINT create_cust_site_use;

    -- Check if API is called in debug mode. If yes, enable debug.
    --enable_debug;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'create_cust_site_use (+)',
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
    do_create_cust_site_use (
        l_cust_site_use_rec,
        l_customer_profile_rec,
        p_create_profile,
        p_create_profile_amt,
        x_site_use_id,
        x_return_status );

   IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
     IF(HZ_UTILITY_V2PUB.G_EXECUTE_API_CALLOUTS in ('EVENTS_ENABLED', 'Y')) THEN
       -- Invoke business event system.
       HZ_BUSINESS_EVENT_V2PVT.create_cust_site_use_event (
         l_cust_site_use_rec,
         l_customer_profile_rec,
         p_create_profile,
         p_create_profile_amt );
     END IF;

     IF(HZ_UTILITY_V2PUB.G_EXECUTE_API_CALLOUTS in ('EVENTS_ENABLED', 'BO_EVENTS_ENABLED')) THEN
       -- populate function for integration service
       HZ_POPULATE_BOT_PKG.pop_hz_cust_site_uses_all(
         p_operation   => 'I',
         p_site_use_id => x_site_use_id );
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
        hz_utility_v2pub.debug(p_message=>'create_cust_site_use (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;
    -- Check if API is called in debug mode. If yes, disable debug.
    --disable_debug;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO create_cust_site_use;
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
            hz_utility_v2pub.debug(p_message=>'create_cust_site_use (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
        END IF;

        -- Check if API is called in debug mode. If yes, disable debug.
        --disable_debug;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO create_cust_site_use;
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
           hz_utility_v2pub.debug(p_message=>'create_cust_site_use (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
        END IF;

        -- Check if API is called in debug mode. If yes, disable debug.
        --disable_debug;

    WHEN OTHERS THEN
        ROLLBACK TO create_cust_site_use;
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
            hz_utility_v2pub.debug(p_message=>'create_cust_site_use (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
        END IF;

        -- Check if API is called in debug mode. If yes, disable debug.
        --disable_debug;

END create_cust_site_use;

/**
 * PROCEDURE update_cust_site_use
 *
 * DESCRIPTION
 *     Updates customer account site use.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *     HZ_BUSINESS_EVENT_V2PVT.update_cust_site_use_event
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_cust_site_use_rec            Customer account site use record.
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

PROCEDURE update_cust_site_use (
    p_init_msg_list                         IN     VARCHAR2 := FND_API.G_FALSE,
    p_cust_site_use_rec                     IN     CUST_SITE_USE_REC_TYPE,
    p_object_version_number                 IN OUT NOCOPY NUMBER,
    x_return_status                         OUT NOCOPY    VARCHAR2,
    x_msg_count                             OUT NOCOPY    NUMBER,
    x_msg_data                              OUT NOCOPY    VARCHAR2
) IS

    l_cust_site_use_rec                     CUST_SITE_USE_REC_TYPE := p_cust_site_use_rec;
    l_old_cust_site_use_rec                 CUST_SITE_USE_REC_TYPE ;
    l_old_customer_profile_rec              HZ_CUSTOMER_PROFILE_V2PUB.CUSTOMER_PROFILE_REC_TYPE;
    l_debug_prefix                          VARCHAR2(30) := '';

BEGIN

    -- Standard start of API savepoint
    SAVEPOINT update_cust_site_use;

    -- Check if API is called in debug mode. If yes, enable debug.
    --enable_debug;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'update_cust_site_use (+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF (p_cust_site_use_rec.orig_system is not null and p_cust_site_use_rec.orig_system <>fnd_api.g_miss_char)
       and (p_cust_site_use_rec.orig_system_reference is not null and p_cust_site_use_rec.orig_system_reference <>fnd_api.g_miss_char)
       and (p_cust_site_use_rec.site_use_id  = FND_API.G_MISS_NUM or p_cust_site_use_rec.site_use_id is null) THEN
    hz_orig_system_ref_pub.get_owner_table_id
   (p_orig_system => p_cust_site_use_rec.orig_system,
   p_orig_system_reference => p_cust_site_use_rec.orig_system_reference,
   p_owner_table_name => 'HZ_CUST_SITE_USES_ALL',
   x_owner_table_id => l_cust_site_use_rec.site_use_id ,
   x_return_status => x_return_status);
     IF x_return_status <> fnd_api.g_ret_sts_success THEN
       RAISE FND_API.G_EXC_ERROR;
     END IF;

      END IF;

    --2290537
    get_cust_site_use_rec (
      p_site_use_id            => l_cust_site_use_rec.site_use_id,
      x_cust_site_use_rec      => l_old_cust_site_use_rec,
      x_customer_profile_rec   => l_old_customer_profile_rec,
      x_return_status          => x_return_status,
      x_msg_count              => x_msg_count,
      x_msg_data               => x_msg_data);

    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Call to business logic.
    do_update_cust_site_use (
        l_cust_site_use_rec,
        p_object_version_number,
        x_return_status );

   IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
     l_old_cust_site_use_rec.orig_system := l_cust_site_use_rec.orig_system;
     IF(HZ_UTILITY_V2PUB.G_EXECUTE_API_CALLOUTS in ('EVENTS_ENABLED', 'Y')) THEN
       -- Invoke business event system.
       HZ_BUSINESS_EVENT_V2PVT.update_cust_site_use_event (
         l_cust_site_use_rec , l_old_cust_site_use_rec);
     END IF;

     IF(HZ_UTILITY_V2PUB.G_EXECUTE_API_CALLOUTS in ('EVENTS_ENABLED', 'BO_EVENTS_ENABLED')) THEN
       -- populate function for integration service
       HZ_POPULATE_BOT_PKG.pop_hz_cust_site_uses_all(
         p_operation   => 'U',
         p_site_use_id => l_cust_site_use_rec.site_use_id );
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
        hz_utility_v2pub.debug(p_message=>'update_cust_site_use (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Check if API is called in debug mode. If yes, disable debug.
    --disable_debug;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO update_cust_site_use;
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
            hz_utility_v2pub.debug(p_message=>'update_cust_site_use (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
        END IF;

        -- Check if API is called in debug mode. If yes, disable debug.
        --disable_debug;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO update_cust_site_use;
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
           hz_utility_v2pub.debug(p_message=>'update_cust_site_use (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
        END IF;

        -- Check if API is called in debug mode. If yes, disable debug.
        --disable_debug;

    WHEN OTHERS THEN
        ROLLBACK TO update_cust_site_use;
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
            hz_utility_v2pub.debug(p_message=> 'update_cust_site_use (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
        END IF;

        -- Check if API is called in debug mode. If yes, disable debug.
        --disable_debug;

END update_cust_site_use;

/**
 * PROCEDURE get_cust_site_use_rec
 *
 * DESCRIPTION
 *      Gets customer account site use record
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *     HZ_CUST_SITE_USES_PKG.Select_Row
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_cust_site_use_id             Customer account site use id.
 *   IN/OUT:
 *   OUT:
 *     x_cust_site_use_rec            Returned customer account site use record.
 *     x_customer_profile_rec         Returned customer profile record.
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

PROCEDURE get_cust_site_use_rec (
    p_init_msg_list                         IN     VARCHAR2 := FND_API.G_FALSE,
    p_site_use_id                           IN     NUMBER,
    x_cust_site_use_rec                     OUT    NOCOPY CUST_SITE_USE_REC_TYPE,
    x_customer_profile_rec                  OUT    NOCOPY HZ_CUSTOMER_PROFILE_V2PUB.CUSTOMER_PROFILE_REC_TYPE,
    x_return_status                         OUT NOCOPY    VARCHAR2,
    x_msg_count                             OUT NOCOPY    NUMBER,
    x_msg_data                              OUT NOCOPY    VARCHAR2
) IS

    l_cust_account_profile_id               NUMBER;
    l_debug_prefix                          VARCHAR2(30) := '';

BEGIN

    -- Check if API is called in debug mode. If yes, enable debug.
    --enable_debug;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'get_cust_site_use_rec (+)',
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
    IF p_site_use_id IS NULL OR
       p_site_use_id = FND_API.G_MISS_NUM THEN
        FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_MISSING_COLUMN' );
        FND_MESSAGE.SET_TOKEN( 'COLUMN', 'site_use_id' );
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    x_cust_site_use_rec.site_use_id := p_site_use_id;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'HZ_CUST_SITE_USES_PKG.Select_Row (+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Call table-handler.
    HZ_CUST_SITE_USES_PKG.Select_Row (
        X_SITE_USE_ID                           => x_cust_site_use_rec.site_use_id,
        X_CUST_ACCT_SITE_ID                     => x_cust_site_use_rec.cust_acct_site_id,
        X_SITE_USE_CODE                         => x_cust_site_use_rec.site_use_code,
        X_PRIMARY_FLAG                          => x_cust_site_use_rec.primary_flag,
        X_STATUS                                => x_cust_site_use_rec.status,
        X_LOCATION                              => x_cust_site_use_rec.location,
        X_BILL_TO_SITE_USE_ID                   => x_cust_site_use_rec.bill_to_site_use_id,
        X_ORIG_SYSTEM_REFERENCE                 => x_cust_site_use_rec.orig_system_reference,
        X_SIC_CODE                              => x_cust_site_use_rec.sic_code,
        X_PAYMENT_TERM_ID                       => x_cust_site_use_rec.payment_term_id,
        X_GSA_INDICATOR                         => x_cust_site_use_rec.gsa_indicator,
        X_SHIP_PARTIAL                          => x_cust_site_use_rec.ship_partial,
        X_SHIP_VIA                              => x_cust_site_use_rec.ship_via,
        X_FOB_POINT                             => x_cust_site_use_rec.fob_point,
        X_ORDER_TYPE_ID                         => x_cust_site_use_rec.order_type_id,
        X_PRICE_LIST_ID                         => x_cust_site_use_rec.price_list_id,
        X_FREIGHT_TERM                          => x_cust_site_use_rec.freight_term,
        X_WAREHOUSE_ID                          => x_cust_site_use_rec.warehouse_id,
        X_TERRITORY_ID                          => x_cust_site_use_rec.territory_id,
        X_ATTRIBUTE_CATEGORY                    => x_cust_site_use_rec.attribute_category,
        X_ATTRIBUTE1                            => x_cust_site_use_rec.attribute1,
        X_ATTRIBUTE2                            => x_cust_site_use_rec.attribute2,
        X_ATTRIBUTE3                            => x_cust_site_use_rec.attribute3,
        X_ATTRIBUTE4                            => x_cust_site_use_rec.attribute4,
        X_ATTRIBUTE5                            => x_cust_site_use_rec.attribute5,
        X_ATTRIBUTE6                            => x_cust_site_use_rec.attribute6,
        X_ATTRIBUTE7                            => x_cust_site_use_rec.attribute7,
        X_ATTRIBUTE8                            => x_cust_site_use_rec.attribute8,
        X_ATTRIBUTE9                            => x_cust_site_use_rec.attribute9,
        X_ATTRIBUTE10                           => x_cust_site_use_rec.attribute10,
        X_TAX_REFERENCE                         => x_cust_site_use_rec.tax_reference,
        X_SORT_PRIORITY                         => x_cust_site_use_rec.sort_priority,
        X_TAX_CODE                              => x_cust_site_use_rec.tax_code,
        X_ATTRIBUTE11                           => x_cust_site_use_rec.attribute11,
        X_ATTRIBUTE12                           => x_cust_site_use_rec.attribute12,
        X_ATTRIBUTE13                           => x_cust_site_use_rec.attribute13,
        X_ATTRIBUTE14                           => x_cust_site_use_rec.attribute14,
        X_ATTRIBUTE15                           => x_cust_site_use_rec.attribute15,
        X_ATTRIBUTE16                           => x_cust_site_use_rec.attribute16,
        X_ATTRIBUTE17                           => x_cust_site_use_rec.attribute17,
        X_ATTRIBUTE18                           => x_cust_site_use_rec.attribute18,
        X_ATTRIBUTE19                           => x_cust_site_use_rec.attribute19,
        X_ATTRIBUTE20                           => x_cust_site_use_rec.attribute20,
        X_ATTRIBUTE21                           => x_cust_site_use_rec.attribute21,
        X_ATTRIBUTE22                           => x_cust_site_use_rec.attribute22,
        X_ATTRIBUTE23                           => x_cust_site_use_rec.attribute23,
        X_ATTRIBUTE24                           => x_cust_site_use_rec.attribute24,
        X_ATTRIBUTE25                           => x_cust_site_use_rec.attribute25,
        X_DEMAND_CLASS_CODE                     => x_cust_site_use_rec.demand_class_code,
        X_TAX_HEADER_LEVEL_FLAG                 => x_cust_site_use_rec.tax_header_level_flag,
        X_TAX_ROUNDING_RULE                     => x_cust_site_use_rec.tax_rounding_rule,
        X_GLOBAL_ATTRIBUTE1                     => x_cust_site_use_rec.global_attribute1,
        X_GLOBAL_ATTRIBUTE2                     => x_cust_site_use_rec.global_attribute2,
        X_GLOBAL_ATTRIBUTE3                     => x_cust_site_use_rec.global_attribute3,
        X_GLOBAL_ATTRIBUTE4                     => x_cust_site_use_rec.global_attribute4,
        X_GLOBAL_ATTRIBUTE5                     => x_cust_site_use_rec.global_attribute5,
        X_GLOBAL_ATTRIBUTE6                     => x_cust_site_use_rec.global_attribute6,
        X_GLOBAL_ATTRIBUTE7                     => x_cust_site_use_rec.global_attribute7,
        X_GLOBAL_ATTRIBUTE8                     => x_cust_site_use_rec.global_attribute8,
        X_GLOBAL_ATTRIBUTE9                     => x_cust_site_use_rec.global_attribute9,
        X_GLOBAL_ATTRIBUTE10                    => x_cust_site_use_rec.global_attribute10,
        X_GLOBAL_ATTRIBUTE11                    => x_cust_site_use_rec.global_attribute11,
        X_GLOBAL_ATTRIBUTE12                    => x_cust_site_use_rec.global_attribute12,
        X_GLOBAL_ATTRIBUTE13                    => x_cust_site_use_rec.global_attribute13,
        X_GLOBAL_ATTRIBUTE14                    => x_cust_site_use_rec.global_attribute14,
        X_GLOBAL_ATTRIBUTE15                    => x_cust_site_use_rec.global_attribute15,
        X_GLOBAL_ATTRIBUTE16                    => x_cust_site_use_rec.global_attribute16,
        X_GLOBAL_ATTRIBUTE17                    => x_cust_site_use_rec.global_attribute17,
        X_GLOBAL_ATTRIBUTE18                    => x_cust_site_use_rec.global_attribute18,
        X_GLOBAL_ATTRIBUTE19                    => x_cust_site_use_rec.global_attribute19,
        X_GLOBAL_ATTRIBUTE20                    => x_cust_site_use_rec.global_attribute20,
        X_GLOBAL_ATTRIBUTE_CATEGORY             => x_cust_site_use_rec.global_attribute_category,
        X_PRIMARY_SALESREP_ID                   => x_cust_site_use_rec.primary_salesrep_id,
        X_FINCHRG_RECEIVABLES_TRX_ID            => x_cust_site_use_rec.finchrg_receivables_trx_id,
        X_DATES_NEGATIVE_TOLERANCE              => x_cust_site_use_rec.dates_negative_tolerance,
        X_DATES_POSITIVE_TOLERANCE              => x_cust_site_use_rec.dates_positive_tolerance,
        X_DATE_TYPE_PREFERENCE                  => x_cust_site_use_rec.date_type_preference,
        X_OVER_SHIPMENT_TOLERANCE               => x_cust_site_use_rec.over_shipment_tolerance,
        X_UNDER_SHIPMENT_TOLERANCE              => x_cust_site_use_rec.under_shipment_tolerance,
        X_ITEM_CROSS_REF_PREF                   => x_cust_site_use_rec.item_cross_ref_pref,
        X_OVER_RETURN_TOLERANCE                 => x_cust_site_use_rec.over_return_tolerance,
        X_UNDER_RETURN_TOLERANCE                => x_cust_site_use_rec.under_return_tolerance,
        X_SHIP_SETS_INCLUDE_LINES_FLAG          => x_cust_site_use_rec.ship_sets_include_lines_flag,
        X_ARRIVALSETS_INCLUDE_LINES_FG          => x_cust_site_use_rec.arrivalsets_include_lines_flag,
        X_SCHED_DATE_PUSH_FLAG                  => x_cust_site_use_rec.sched_date_push_flag,
        X_INVOICE_QUANTITY_RULE                 => x_cust_site_use_rec.invoice_quantity_rule,
        X_PRICING_EVENT                         => x_cust_site_use_rec.pricing_event,
        X_GL_ID_REC                             => x_cust_site_use_rec.gl_id_rec,
        X_GL_ID_REV                             => x_cust_site_use_rec.gl_id_rev,
        X_GL_ID_TAX                             => x_cust_site_use_rec.gl_id_tax,
        X_GL_ID_FREIGHT                         => x_cust_site_use_rec.gl_id_freight,
        X_GL_ID_CLEARING                        => x_cust_site_use_rec.gl_id_clearing,
        X_GL_ID_UNBILLED                        => x_cust_site_use_rec.gl_id_unbilled,
        X_GL_ID_UNEARNED                        => x_cust_site_use_rec.gl_id_unearned,
        X_GL_ID_UNPAID_REC                      => x_cust_site_use_rec.gl_id_unpaid_rec,
        X_GL_ID_REMITTANCE                      => x_cust_site_use_rec.gl_id_remittance,
        X_GL_ID_FACTOR                          => x_cust_site_use_rec.gl_id_factor,
        X_TAX_CLASSIFICATION                    => x_cust_site_use_rec.tax_classification,
        X_CREATED_BY_MODULE                     => x_cust_site_use_rec.created_by_module,
        X_APPLICATION_ID                        => x_cust_site_use_rec.application_id,
        X_ORG_ID                                => x_cust_site_use_rec.org_id  -- Bug 3456489
    );

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=> 'HZ_CUST_SITE_USES_PKG.Select_Row (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    BEGIN
        -- Fetch customer profile id.
        SELECT CUST_ACCOUNT_PROFILE_ID INTO l_cust_account_profile_id
        FROM HZ_CUSTOMER_PROFILES
        WHERE SITE_USE_ID = p_site_use_id;

        HZ_CUSTOMER_PROFILE_V2PUB.get_customer_profile_rec (
            p_cust_account_profile_id               => l_cust_account_profile_id,
            x_customer_profile_rec                  => x_customer_profile_rec,
            x_return_status                         => x_return_status,
            x_msg_count                             => x_msg_count,
            x_msg_data                              => x_msg_data );

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
            ELSE
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            NULL;
    END;

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
        hz_utility_v2pub.debug(p_message=>'get_cust_site_use_rec (-)',
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
            hz_utility_v2pub.debug(p_message=>'get_cust_site_use_rec (-)',
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
           hz_utility_v2pub.debug(p_message=>'get_cust_site_use_rec (-)',
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
            hz_utility_v2pub.debug(p_message=> 'get_cust_site_use_rec (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
        END IF;

        -- Check if API is called in debug mode. If yes, disable debug.
        --disable_debug;

END get_cust_site_use_rec;

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
    p_account_site_rec            IN     cust_acct_site_rec_type,
    p_old_account_site_rec        IN     cust_acct_site_rec_type DEFAULT NULL,
    x_return_status               IN OUT NOCOPY VARCHAR2
) IS

BEGIN

    -- check language
    IF (p_create_update_flag = 'C' AND
        p_account_site_rec.language IS NOT NULL AND
        p_account_site_rec.language <> FND_API.G_MISS_CHAR) OR
       (p_create_update_flag = 'U' AND
        p_account_site_rec.language IS NOT NULL AND
        p_account_site_rec.language <> p_old_account_site_rec.language)
    THEN
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_OBSOLETE_COLUMN');
        FND_MESSAGE.SET_TOKEN('COLUMN', 'language');
        FND_MSG_PUB.ADD;
        x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

END check_obsolete_columns;

END HZ_CUST_ACCOUNT_SITE_V2PUB;

/
