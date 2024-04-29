--------------------------------------------------------
--  DDL for Package Body HZ_CUST_ACCOUNT_V2PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_CUST_ACCOUNT_V2PUB" AS
/*$Header: ARH2CASB.pls 120.38.12010000.2 2009/08/21 01:28:13 awu ship $ */

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


PROCEDURE do_create_cust_account (
    p_entity_type                           IN     VARCHAR2,
    p_cust_account_rec                      IN OUT NOCOPY CUST_ACCOUNT_REC_TYPE,
    p_person_rec                            IN OUT NOCOPY HZ_PARTY_V2PUB.PERSON_REC_TYPE,
    p_organization_rec                      IN OUT NOCOPY HZ_PARTY_V2PUB.ORGANIZATION_REC_TYPE,
    p_customer_profile_rec                  IN OUT NOCOPY HZ_CUSTOMER_PROFILE_V2PUB.CUSTOMER_PROFILE_REC_TYPE,
    p_create_profile_amt                    IN     VARCHAR2 := FND_API.G_TRUE,
    x_cust_account_id                       OUT NOCOPY    NUMBER,
    x_account_number                        OUT NOCOPY    VARCHAR2,
    x_party_id                              OUT NOCOPY    NUMBER,
    x_party_number                          OUT NOCOPY    VARCHAR2,
    x_profile_id                            OUT NOCOPY    NUMBER,
    x_return_status                         IN OUT NOCOPY VARCHAR2
);

PROCEDURE do_update_cust_account (
    p_cust_account_rec                      IN OUT NOCOPY CUST_ACCOUNT_REC_TYPE,
    p_object_version_number                 IN OUT NOCOPY NUMBER,
    x_return_status                         IN OUT NOCOPY VARCHAR2
);

PROCEDURE do_create_cust_acct_relate (
    p_cust_acct_relate_rec                  IN OUT NOCOPY CUST_ACCT_RELATE_REC_TYPE,
    x_return_status                         IN OUT NOCOPY VARCHAR2
);

PROCEDURE do_update_cust_acct_relate (
    p_cust_acct_relate_rec                  IN OUT NOCOPY CUST_ACCT_RELATE_REC_TYPE,
    p_object_version_number                 IN OUT NOCOPY NUMBER,
    p_rowid                                 IN            ROWID,  -- Bug3449118
    x_return_status                         IN OUT NOCOPY VARCHAR2
);

PROCEDURE check_obsolete_columns (
    p_create_update_flag          IN     VARCHAR2,
    p_cust_account_rec            IN     cust_account_rec_type,
    p_old_cust_account_rec        IN     cust_account_rec_type DEFAULT NULL,
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
 * PRIVATE PROCEDURE do_create_cust_account
 *
 * DESCRIPTION
 *     Private procedure to create customer account.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *     HZ_ACCOUNT_VALIDATE_V2PUB.validate_cust_account
 *     HZ_CUST_ACCOUNTS_PKG.Insert_Row
 *     HZ_PARTY_V2PUB.create_person
 *     HZ_PARTY_V2PUB.create_organization
 *     HZ_CUSTOMER_PROFILE_V2PUB.create_customer_profile
 *
 * ARGUMENTS
 *   IN:
 *     p_entity_type                  Either 'PERSON' or 'ORGANIZATION'.
 *     p_create_profile_amt           If it is set to FND_API.G_TRUE, API create customer
 *                                    profile amounts by copying corresponding data
 *                                    from customer profile class amounts.
 *   IN/OUT:
 *     p_cust_account_rec             Customer account record.
 *     p_person_rec                   Person party record which being created account
 *                                    belongs to. If party_id in person record is not
 *                                    passed in or party_id does not exist in hz_parties,
 *                                    API ceates a person party based on this record.
 *     p_organization_rec             Organization party record which being created account
 *                                    belongs to. If party_id in organization record is not
 *                                    passed in or party_id does not exist in hz_parties,
 *                                    API ceates a organization party based on this record.
 *     p_customer_profile_rec         Customer profile record. One customer account
 *                                    must have a customer profile.
 *     x_return_status                Return status after the call. The status can
 *                                    be FND_API.G_RET_STS_SUCCESS (success),
 *                                    FND_API.G_RET_STS_ERROR (error),
 *   OUT:
 *     x_cust_account_id              Customer account ID.
 *     x_account_number               Customer account number.
 *     x_party_id                     Party ID of the party which this account belongs to.
 *     x_party_number                 Party number of the party which this account belongs
 *                                    to.
 *     x_profile_id                   Person or organization profile ID.
 *
 * NOTES
 *     This package is shared between create_cust_account (person) and create_cust_account
 *     (organization). It should always raise exception to main API.
 *
 * MODIFICATION HISTORY
 *
 *   07-23-2001    Jianying Huang      o Created.
 *   02-01-2002    P.Suresh            o Bug 2196137. Assigned the party number to
 *                                       l_party_number in do_create_cust_account
 *                                       procedure.
 *   02-15-2005    Rajib Ranjan Borah  o Bug 4048104. Retrieve party_id from
 *                                       orig_system and orig_system_reference if null is
 *                                       passed for party id.
 *
 */

PROCEDURE do_create_cust_account (
    p_entity_type                           IN     VARCHAR2,
    p_cust_account_rec                      IN OUT NOCOPY CUST_ACCOUNT_REC_TYPE,
    p_person_rec                            IN OUT NOCOPY HZ_PARTY_V2PUB.PERSON_REC_TYPE,
    p_organization_rec                      IN OUT NOCOPY HZ_PARTY_V2PUB.ORGANIZATION_REC_TYPE,
    p_customer_profile_rec                  IN OUT NOCOPY HZ_CUSTOMER_PROFILE_V2PUB.CUSTOMER_PROFILE_REC_TYPE,
    p_create_profile_amt                    IN     VARCHAR2,
    x_cust_account_id                       OUT NOCOPY    NUMBER,
    x_account_number                        OUT NOCOPY    VARCHAR2,
    x_party_id                              OUT NOCOPY    NUMBER,
    x_party_number                          OUT NOCOPY    VARCHAR2,
    x_profile_id                            OUT NOCOPY    NUMBER,
    x_return_status                         IN OUT NOCOPY VARCHAR2
) IS

    l_debug_prefix                          VARCHAR2(30) := ''; --'do_create_cust_account';

    l_msg_count                             NUMBER;
    l_msg_data                              VARCHAR2(2000);
    l_create_party                          BOOLEAN := FALSE;

    l_party_id                              NUMBER;
    l_party_number                          HZ_PARTIES.party_number%TYPE;
    l_party_type                            HZ_PARTIES.party_type%TYPE;
    l_profile_id                            NUMBER;
    l_cust_account_profile_id               NUMBER;
    l_orig_system_ref_rec                   HZ_ORIG_SYSTEM_REF_PUB.ORIG_SYS_REFERENCE_REC_TYPE;

    CURSOR check_orig_sys_ref IS
     select 'Y' from hz_cust_accounts
      where ORIG_SYSTEM_REFERENCE = p_cust_account_rec.orig_system_reference;
l_orig_system_reference varchar2(255) :=p_cust_account_rec.orig_system_reference;
l_tmp varchar2(1);

    l_party_usg_assignment_rec              HZ_PARTY_USG_ASSIGNMENT_PVT.party_usg_assignment_rec_type;
    l_dummy                                 VARCHAR2(1);
    l_party_usg_validation_level            NUMBER;

    CURSOR c_has_active_account (
      p_party_id                            NUMBER,
      p_cust_account_id                     NUMBER
    ) IS
    SELECT null
    FROM   hz_cust_accounts
    WHERE  party_id = p_party_id
    AND    status = 'A'
    AND    cust_account_id <> p_cust_account_id
    AND    rownum = 1;

BEGIN

    -- Debug info.

    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'do_create_cust_account (+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

   if (p_cust_account_rec.orig_system is null OR p_cust_account_rec.orig_system = fnd_api.g_miss_char)
      and (p_cust_account_rec.orig_system_reference is not null and
           p_cust_account_rec.orig_system_reference <> fnd_api.g_miss_char)
   then
      p_cust_account_rec.orig_system := 'UNKNOWN';
   end if;

   open check_orig_sys_ref;
   fetch check_orig_sys_ref into l_tmp;
   -- for mosr logic, if more than one OSR found, we append sysdate for account
   --  table, but insert original orig_system_reference to mosr table
   if check_orig_sys_ref%FOUND then
        p_cust_account_rec.orig_system_reference := l_orig_system_reference||'#@'||to_char(sysdate,'DD-MON-YYYY HH24:MI:SS');
   end if ;
   close check_orig_sys_ref;

    -- Validate cust account record
    HZ_ACCOUNT_VALIDATE_V2PUB.validate_cust_account (
        p_create_update_flag                    => 'C',
        p_cust_account_rec                      => p_cust_account_rec,
        p_rowid                                 => NULL,
        x_return_status                         => x_return_status );

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Check if account is being create for an existing party.
    -- Otherwise, create a new party and an account for this party.

    IF p_entity_type = 'PERSON' THEN
        l_party_id := p_person_rec.party_rec.party_id;
    ELSIF p_entity_type = 'ORGANIZATION' THEN
        l_party_id := p_organization_rec.party_rec.party_id;
    END IF;

    IF l_party_id IS NOT NULL AND
       l_party_id <> FND_API.G_MISS_NUM
    THEN
        BEGIN
            SELECT party_type INTO l_party_type
            FROM HZ_PARTIES
            WHERE PARTY_ID = l_party_id;

            IF l_party_type <> p_entity_type THEN
                FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_INVALID_PARTY_TYPE' );
                FND_MESSAGE.SET_TOKEN( 'PARTY_ID', l_party_id);
                FND_MESSAGE.SET_TOKEN( 'TYPE', p_entity_type);
                FND_MSG_PUB.ADD;
                RAISE FND_API.G_EXC_ERROR;
            END IF;

            -- can go ahead and create an account for this existing party.

        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                -- create new party
                l_create_party := TRUE;
        END;
    ELSE

        /* Bug 4048104. Try to retrieve party_id from orig_system and orig_system_reference
         *              if party_id is not passed.
         */

        IF p_entity_type = 'PERSON' THEN
            IF p_person_rec.party_rec.orig_system_reference IS NOT NULL AND
               p_person_rec.party_rec.orig_system_reference <> FND_API.G_MISS_CHAR AND
               p_person_rec.party_rec.orig_system IS NOT NULL AND
               p_person_rec.party_rec.orig_system <> FND_API.G_MISS_CHAR THEN

                BEGIN
                    SELECT owner_table_id /* party_id would also do */
                    INTO   l_party_id
                    FROM   HZ_ORIG_SYS_REFERENCES
                    WHERE  orig_system           = p_person_rec.party_rec.orig_system
                      AND  orig_system_reference = p_person_rec.party_rec.orig_system_reference
                      AND  owner_table_name      = 'HZ_PARTIES'
                      AND  status = 'A';
                EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                        l_create_party := TRUE;
                END;
                BEGIN
                     SELECT party_type INTO l_party_type
                     FROM HZ_PARTIES
                     WHERE PARTY_ID = l_party_id;

                     IF l_party_type <> p_entity_type THEN
                        FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_INVALID_PARTY_TYPE' );
                        FND_MESSAGE.SET_TOKEN( 'PARTY_ID', l_party_id);
                        FND_MESSAGE.SET_TOKEN( 'TYPE', p_entity_type);
                        FND_MSG_PUB.ADD;
                        RAISE FND_API.G_EXC_ERROR;
                    END IF;
                EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                        l_create_party := TRUE;
                END;
            ELSE
                l_create_party := TRUE;
            END IF;

        ELSE -- i.e. p_entity_type = 'ORGANIZATION'
            IF p_organization_rec.party_rec.orig_system_reference IS NOT NULL AND
               p_organization_rec.party_rec.orig_system_reference <> FND_API.G_MISS_CHAR AND
               p_organization_rec.party_rec.orig_system IS NOT NULL AND
               p_organization_rec.party_rec.orig_system <> FND_API.G_MISS_CHAR THEN

                BEGIN
                    SELECT owner_table_id /* party_id would also do */
                    INTO   l_party_id
                    FROM   HZ_ORIG_SYS_REFERENCES
                    WHERE  orig_system           = p_organization_rec.party_rec.orig_system
                      AND  orig_system_reference = p_organization_rec.party_rec.orig_system_reference
                      AND  owner_table_name      = 'HZ_PARTIES'
                      AND  status = 'A';
                EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                        l_create_party := TRUE;
                END;
                BEGIN
                     SELECT party_type INTO l_party_type
                     FROM HZ_PARTIES
                     WHERE PARTY_ID = l_party_id;

                     IF l_party_type <> p_entity_type THEN
                        FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_INVALID_PARTY_TYPE' );
                        FND_MESSAGE.SET_TOKEN( 'PARTY_ID', l_party_id);
                        FND_MESSAGE.SET_TOKEN( 'TYPE', p_entity_type);
                        FND_MSG_PUB.ADD;
                        RAISE FND_API.G_EXC_ERROR;
                    END IF;
                EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                        l_create_party := TRUE;
                END;
            ELSE
                l_create_party := TRUE;
            END IF;
        END IF;

    END IF;

    -- Debug info.
    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
        IF l_create_party THEN
           hz_utility_v2pub.debug(p_message=>'We need to create party. ',
                                  p_prefix =>l_debug_prefix,
                                  p_msg_level=>fnd_log.level_statement);
        ELSE
           hz_utility_v2pub.debug(p_message=>'We donot need to create party. ',
                                  p_prefix =>l_debug_prefix,
                                  p_msg_level=>fnd_log.level_statement);

        END IF;
    END IF;


    IF l_create_party THEN

        IF p_entity_type = 'PERSON' THEN

            p_person_rec.created_by_module := p_cust_account_rec.created_by_module;
            p_person_rec.application_id := p_cust_account_rec.application_id;

            HZ_PARTY_V2PUB.create_person (
                p_person_rec                 => p_person_rec,
                x_party_id                   => l_party_id,
                x_party_number               => l_party_number,
                x_profile_id                 => l_profile_id,
                x_return_status              => x_return_status,
                x_msg_count                  => l_msg_count,
                x_msg_data                   => l_msg_data );
        ELSIF p_entity_type = 'ORGANIZATION' THEN

            p_organization_rec.created_by_module := p_cust_account_rec.created_by_module;
            p_organization_rec.application_id := p_cust_account_rec.application_id;

            HZ_PARTY_V2PUB.create_organization (
                p_organization_rec           => p_organization_rec,
                x_party_id                   => l_party_id,
                x_party_number               => l_party_number,
                x_profile_id                 => l_profile_id,
                x_return_status              => x_return_status,
                x_msg_count                  => l_msg_count,
                x_msg_data                   => l_msg_data );
        END IF;

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
            ELSE
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
        END IF;

        l_party_usg_validation_level := HZ_PARTY_USG_ASSIGNMENT_PVT.G_VALID_LEVEL_NONE;

    ELSE
      l_party_usg_validation_level := HZ_PARTY_USG_ASSIGNMENT_PVT.G_VALID_LEVEL_LOW;
    END IF;



    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'HZ_CUST_ACCOUNTS_PKG.Insert_Row (+) ',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Call table-handler.
    HZ_CUST_ACCOUNTS_PKG.Insert_Row (
        X_CUST_ACCOUNT_ID                       => p_cust_account_rec.cust_account_id,
        X_PARTY_ID                              => l_party_id,
        X_ACCOUNT_NUMBER                        => p_cust_account_rec.account_number,
        X_ATTRIBUTE_CATEGORY                    => p_cust_account_rec.attribute_category,
        X_ATTRIBUTE1                            => p_cust_account_rec.attribute1,
        X_ATTRIBUTE2                            => p_cust_account_rec.attribute2,
        X_ATTRIBUTE3                            => p_cust_account_rec.attribute3,
        X_ATTRIBUTE4                            => p_cust_account_rec.attribute4,
        X_ATTRIBUTE5                            => p_cust_account_rec.attribute5,
        X_ATTRIBUTE6                            => p_cust_account_rec.attribute6,
        X_ATTRIBUTE7                            => p_cust_account_rec.attribute7,
        X_ATTRIBUTE8                            => p_cust_account_rec.attribute8,
        X_ATTRIBUTE9                            => p_cust_account_rec.attribute9,
        X_ATTRIBUTE10                           => p_cust_account_rec.attribute10,
        X_ATTRIBUTE11                           => p_cust_account_rec.attribute11,
        X_ATTRIBUTE12                           => p_cust_account_rec.attribute12,
        X_ATTRIBUTE13                           => p_cust_account_rec.attribute13,
        X_ATTRIBUTE14                           => p_cust_account_rec.attribute14,
        X_ATTRIBUTE15                           => p_cust_account_rec.attribute15,
        X_ATTRIBUTE16                           => p_cust_account_rec.attribute16,
        X_ATTRIBUTE17                           => p_cust_account_rec.attribute17,
        X_ATTRIBUTE18                           => p_cust_account_rec.attribute18,
        X_ATTRIBUTE19                           => p_cust_account_rec.attribute19,
        X_ATTRIBUTE20                           => p_cust_account_rec.attribute20,
        X_GLOBAL_ATTRIBUTE_CATEGORY             => p_cust_account_rec.global_attribute_category,
        X_GLOBAL_ATTRIBUTE1                     => p_cust_account_rec.global_attribute1,
        X_GLOBAL_ATTRIBUTE2                     => p_cust_account_rec.global_attribute2,
        X_GLOBAL_ATTRIBUTE3                     => p_cust_account_rec.global_attribute3,
        X_GLOBAL_ATTRIBUTE4                     => p_cust_account_rec.global_attribute4,
        X_GLOBAL_ATTRIBUTE5                     => p_cust_account_rec.global_attribute5,
        X_GLOBAL_ATTRIBUTE6                     => p_cust_account_rec.global_attribute6,
        X_GLOBAL_ATTRIBUTE7                     => p_cust_account_rec.global_attribute7,
        X_GLOBAL_ATTRIBUTE8                     => p_cust_account_rec.global_attribute8,
        X_GLOBAL_ATTRIBUTE9                     => p_cust_account_rec.global_attribute9,
        X_GLOBAL_ATTRIBUTE10                    => p_cust_account_rec.global_attribute10,
        X_GLOBAL_ATTRIBUTE11                    => p_cust_account_rec.global_attribute11,
        X_GLOBAL_ATTRIBUTE12                    => p_cust_account_rec.global_attribute12,
        X_GLOBAL_ATTRIBUTE13                    => p_cust_account_rec.global_attribute13,
        X_GLOBAL_ATTRIBUTE14                    => p_cust_account_rec.global_attribute14,
        X_GLOBAL_ATTRIBUTE15                    => p_cust_account_rec.global_attribute15,
        X_GLOBAL_ATTRIBUTE16                    => p_cust_account_rec.global_attribute16,
        X_GLOBAL_ATTRIBUTE17                    => p_cust_account_rec.global_attribute17,
        X_GLOBAL_ATTRIBUTE18                    => p_cust_account_rec.global_attribute18,
        X_GLOBAL_ATTRIBUTE19                    => p_cust_account_rec.global_attribute19,
        X_GLOBAL_ATTRIBUTE20                    => p_cust_account_rec.global_attribute20,
        X_ORIG_SYSTEM_REFERENCE                 => p_cust_account_rec.orig_system_reference,
        X_STATUS                                => p_cust_account_rec.status,
        X_CUSTOMER_TYPE                         => p_cust_account_rec.customer_type,
        X_CUSTOMER_CLASS_CODE                   => p_cust_account_rec.customer_class_code,
        X_PRIMARY_SALESREP_ID                   => p_cust_account_rec.primary_salesrep_id,
        X_SALES_CHANNEL_CODE                    => p_cust_account_rec.sales_channel_code,
        X_ORDER_TYPE_ID                         => p_cust_account_rec.order_type_id,
        X_PRICE_LIST_ID                         => p_cust_account_rec.price_list_id,
        X_TAX_CODE                              => p_cust_account_rec.tax_code,
        X_FOB_POINT                             => p_cust_account_rec.fob_point,
        X_FREIGHT_TERM                          => p_cust_account_rec.freight_term,
        X_SHIP_PARTIAL                          => p_cust_account_rec.ship_partial,
        X_SHIP_VIA                              => p_cust_account_rec.ship_via,
        X_WAREHOUSE_ID                          => p_cust_account_rec.warehouse_id,
        X_TAX_HEADER_LEVEL_FLAG                 => p_cust_account_rec.tax_header_level_flag,
        X_TAX_ROUNDING_RULE                     => p_cust_account_rec.tax_rounding_rule,
        X_COTERMINATE_DAY_MONTH                 => p_cust_account_rec.coterminate_day_month,
        X_PRIMARY_SPECIALIST_ID                 => p_cust_account_rec.primary_specialist_id,
        X_SECONDARY_SPECIALIST_ID               => p_cust_account_rec.secondary_specialist_id,
        X_ACCOUNT_LIABLE_FLAG                   => p_cust_account_rec.account_liable_flag,
        X_CURRENT_BALANCE                       => p_cust_account_rec.current_balance,
        X_ACCOUNT_ESTABLISHED_DATE              => p_cust_account_rec.account_established_date,
        X_ACCOUNT_TERMINATION_DATE              => p_cust_account_rec.account_termination_date,
        X_ACCOUNT_ACTIVATION_DATE               => p_cust_account_rec.account_activation_date,
        X_DEPARTMENT                            => p_cust_account_rec.department,
        X_HELD_BILL_EXPIRATION_DATE             => p_cust_account_rec.held_bill_expiration_date,
        X_HOLD_BILL_FLAG                        => p_cust_account_rec.hold_bill_flag,
        X_REALTIME_RATE_FLAG                    => p_cust_account_rec.realtime_rate_flag,
        X_ACCT_LIFE_CYCLE_STATUS                => p_cust_account_rec.acct_life_cycle_status,
        X_ACCOUNT_NAME                          => p_cust_account_rec.account_name,
        X_DEPOSIT_REFUND_METHOD                 => p_cust_account_rec.deposit_refund_method,
        X_DORMANT_ACCOUNT_FLAG                  => p_cust_account_rec.dormant_account_flag,
        X_NPA_NUMBER                            => p_cust_account_rec.npa_number,
        X_SUSPENSION_DATE                       => p_cust_account_rec.suspension_date,
        X_SOURCE_CODE                           => p_cust_account_rec.source_code,
        X_COMMENTS                              => p_cust_account_rec.comments,
        X_DATES_NEGATIVE_TOLERANCE              => p_cust_account_rec.dates_negative_tolerance,
        X_DATES_POSITIVE_TOLERANCE              => p_cust_account_rec.dates_positive_tolerance,
        X_DATE_TYPE_PREFERENCE                  => p_cust_account_rec.date_type_preference,
        X_OVER_SHIPMENT_TOLERANCE               => p_cust_account_rec.over_shipment_tolerance,
        X_UNDER_SHIPMENT_TOLERANCE              => p_cust_account_rec.under_shipment_tolerance,
        X_OVER_RETURN_TOLERANCE                 => p_cust_account_rec.over_return_tolerance,
        X_UNDER_RETURN_TOLERANCE                => p_cust_account_rec.under_return_tolerance,
        X_ITEM_CROSS_REF_PREF                   => p_cust_account_rec.item_cross_ref_pref,
        X_SHIP_SETS_INCLUDE_LINES_FLAG          => p_cust_account_rec.ship_sets_include_lines_flag,
        X_ARRIVALSETS_INCL_LINES_FLAG           => p_cust_account_rec.arrivalsets_include_lines_flag,
        X_SCHED_DATE_PUSH_FLAG                  => p_cust_account_rec.sched_date_push_flag,
        X_INVOICE_QUANTITY_RULE                 => p_cust_account_rec.invoice_quantity_rule,
        X_PRICING_EVENT                         => p_cust_account_rec.pricing_event,
        X_STATUS_UPDATE_DATE                    => p_cust_account_rec.status_update_date,
        X_AUTOPAY_FLAG                          => p_cust_account_rec.autopay_flag,
        X_NOTIFY_FLAG                           => p_cust_account_rec.notify_flag,
        X_LAST_BATCH_ID                         => p_cust_account_rec.last_batch_id,
        X_SELLING_PARTY_ID                      => p_cust_account_rec.selling_party_id,
        X_OBJECT_VERSION_NUMBER                 => 1,
        X_CREATED_BY_MODULE                     => p_cust_account_rec.created_by_module,
        X_APPLICATION_ID                        => p_cust_account_rec.application_id
    );

      -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'HZ_CUST_ACCOUNTS_PKG.Insert_Row (-) ' ||
                                        'x_cust_account_id = ' || p_cust_account_rec.cust_account_id || ' ' ||
                                        'x_account_number = ' || p_cust_account_rec.account_number,
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

  if (p_cust_account_rec.orig_system is not null and p_cust_account_rec.orig_system <>fnd_api.g_miss_char)
  then
        l_orig_system_ref_rec.orig_system := p_cust_account_rec.orig_system;
        l_orig_system_ref_rec.orig_system_reference := l_orig_system_reference;
        l_orig_system_ref_rec.owner_table_name := 'HZ_CUST_ACCOUNTS';
        l_orig_system_ref_rec.owner_table_id := p_cust_account_rec.cust_account_id;
        l_orig_system_ref_rec.created_by_module := p_cust_account_rec.created_by_module;

        hz_orig_system_ref_pub.create_orig_system_reference(
                FND_API.G_FALSE,
                l_orig_system_ref_rec,
                x_return_status,
                l_msg_count,
                l_msg_data);
        IF x_return_status <> fnd_api.g_ret_sts_success THEN
        RAISE FND_API.G_EXC_ERROR;
  END IF;

end if;


    -- Bug Fix : 2196137
    IF l_party_number IS NULL AND
       l_party_id     IS NOT NULL
    THEN
            SELECT party_number INTO l_party_number
            FROM HZ_PARTIES
            WHERE PARTY_ID = l_party_id;
    END IF;

    -- create customer profile. Customer profile is mandatory for account. One
    -- account can only have one customer profile.

    p_customer_profile_rec.cust_account_id := p_cust_account_rec.cust_account_id;

    --bug 2310474: add party_id for Cust Account Profile
    p_customer_profile_rec.party_id := l_party_id;

    IF p_customer_profile_rec.site_use_id IS NOT NULL AND
       p_customer_profile_rec.site_use_id <> FND_API.G_MISS_NUM
    THEN
        FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_COLUMN_SHOULD_BE_NULL' );
        FND_MESSAGE.SET_TOKEN( 'COLUMN', 'site_use_id' );
        FND_MESSAGE.SET_TOKEN( 'TABLE', 'hz_customer_profiles' );
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    p_customer_profile_rec.created_by_module := p_cust_account_rec.created_by_module;
    p_customer_profile_rec.application_id := p_cust_account_rec.application_id;

    HZ_CUSTOMER_PROFILE_V2PUB.create_customer_profile (
        p_customer_profile_rec       => p_customer_profile_rec,
        p_create_profile_amt         => p_create_profile_amt,
        x_cust_account_profile_id    => l_cust_account_profile_id,
        x_return_status              => x_return_status,
        x_msg_count                  => l_msg_count,
        x_msg_data                   => l_msg_data );

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        IF x_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
        ELSE
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
    END IF;

    --
    -- R12 party usage project
    --
    OPEN c_has_active_account(
      l_party_id, p_cust_account_rec.cust_account_id);
    FETCH c_has_active_account INTO l_dummy;
    IF c_has_active_account%NOTFOUND THEN
      IF p_cust_account_rec.status = 'I' THEN
         l_party_usg_assignment_rec.effective_start_date := trunc(sysdate);
         l_party_usg_assignment_rec.effective_end_date := trunc(sysdate);
      END IF;

      l_party_usg_assignment_rec.party_id := l_party_id;
      l_party_usg_assignment_rec.party_usage_code := 'CUSTOMER';
      l_party_usg_assignment_rec.created_by_module := 'TCA_V2_API';

      HZ_PARTY_USG_ASSIGNMENT_PVT.assign_party_usage (
        p_validation_level          => l_party_usg_validation_level,
        p_party_usg_assignment_rec  => l_party_usg_assignment_rec,
        x_return_status             => x_return_status,
        x_msg_count                 => l_msg_count,
        x_msg_data                  => l_msg_data
      );
    END IF;
    CLOSE c_has_active_account;

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
      ELSE
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
    END IF;

    x_cust_account_id := p_cust_account_rec.cust_account_id;
    x_account_number := p_cust_account_rec.account_number;
    x_party_id := l_party_id;
    x_party_number := l_party_number;
    x_profile_id := l_profile_id;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'do_create_cust_account (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

END do_create_cust_account;

/**
 * PRIVATE PROCEDURE do_update_cust_account
 *
 * DESCRIPTION
 *     Private procedure to update customer account.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *     HZ_ACCOUNT_VALIDATE_V2PUB.validate_cust_account
 *     HZ_CUST_ACCOUNTS_PKG.Update_Row
 *
 * ARGUMENTS
 *   IN/OUT:
 *     p_cust_account_rec             Customer account record.
 *     p_object_version_number        Used for locking the being updated record.
 *     x_return_status                Return status after the call. The status can
 *                                    be FND_API.G_RET_STS_SUCCESS (success),
 *                                    FND_API.G_RET_STS_ERROR (error),
 *                                    FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
 *
 * NOTES
 *     This procedure should always raise exception to main API.
 *
 * MODIFICATION HISTORY
 *
 *   07-23-2001    Jianying Huang      o Created.
 *
 */

PROCEDURE do_update_cust_account (
    p_cust_account_rec                      IN OUT NOCOPY CUST_ACCOUNT_REC_TYPE,
    p_object_version_number                 IN OUT NOCOPY NUMBER,
    x_return_status                         IN OUT NOCOPY VARCHAR2
) IS

    l_debug_prefix                          VARCHAR2(30) := ''; --'do_update_cust_account';

    l_rowid                                 ROWID := NULL;
    l_object_version_number                 NUMBER;
    l_orig_system_ref_rec HZ_ORIG_SYSTEM_REF_PUB.ORIG_SYS_REFERENCE_REC_TYPE;

    CURSOR check_orig_sys_ref IS
     select 'Y' from hz_cust_accounts
      where ORIG_SYSTEM_REFERENCE = p_cust_account_rec.orig_system_reference;

l_orig_system_reference varchar2(255) :=p_cust_account_rec.orig_system_reference;
l_tmp varchar2(1);

    l_party_id                    NUMBER(15);
    l_status                      VARCHAR2(1);
    l_dummy                       VARCHAR2(1);
    l_msg_count                   NUMBER;
    l_msg_data                    VARCHAR2(2000);
    l_party_usg_assignment_rec    HZ_PARTY_USG_ASSIGNMENT_PVT.party_usg_assignment_rec_type;

    CURSOR c_has_active_account (
      p_party_id                  NUMBER,
      p_cust_account_id           NUMBER
    ) IS
    SELECT null
    FROM   hz_cust_accounts
    WHERE  party_id = p_party_id
    AND    status = 'A'
    AND    cust_account_id <> p_cust_account_id
    AND    rownum = 1;

BEGIN

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'do_update_cust_account (+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;


    -- Lock record.
    BEGIN
        SELECT ROWID, OBJECT_VERSION_NUMBER, party_id, status
        INTO l_rowid, l_object_version_number, l_party_id, l_status
        FROM HZ_CUST_ACCOUNTS
        WHERE CUST_ACCOUNT_ID = p_cust_account_rec.cust_account_id
        FOR UPDATE NOWAIT;

        IF NOT (
            ( p_object_version_number IS NULL AND l_object_version_number IS NULL ) OR
            ( p_object_version_number IS NOT NULL AND
              l_object_version_number IS NOT NULL AND
              p_object_version_number = l_object_version_number ) )
        THEN
            FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_RECORD_CHANGED' );
            FND_MESSAGE.SET_TOKEN( 'TABLE', 'hz_cust_accounts' );
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        END IF;

        p_object_version_number := NVL( l_object_version_number, 1 ) + 1;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_NO_RECORD' );
            FND_MESSAGE.SET_TOKEN( 'RECORD', 'customer account' );
            FND_MESSAGE.SET_TOKEN( 'VALUE',
                NVL( TO_CHAR( p_cust_account_rec.cust_account_id ), 'null' ) );
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
    END;


    -- Validate cust account record
    HZ_ACCOUNT_VALIDATE_V2PUB.validate_cust_account (
        p_create_update_flag                    => 'U',
        p_cust_account_rec                      => p_cust_account_rec,
        p_rowid                                 => l_rowid,
        x_return_status                         => x_return_status );

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    if (p_cust_account_rec.orig_system is not null
         and p_cust_account_rec.orig_system <>fnd_api.g_miss_char)
        and (p_cust_account_rec.orig_system_reference is not null
         and p_cust_account_rec.orig_system_reference <>fnd_api.g_miss_char)
    then
                p_cust_account_rec.orig_system_reference := null;
                -- In mosr, we have bypassed osr nonupdateable validation
                -- but we should not update existing osr, set it to null
    end if;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'HZ_CUST_ACCOUNTS_PKG.Update_Row (+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Call table-handler.
    HZ_CUST_ACCOUNTS_PKG.Update_Row (
        X_Rowid                                 => l_rowid,
        X_CUST_ACCOUNT_ID                       => p_cust_account_rec.cust_account_id,
        X_PARTY_ID                              => NULL,  -- no need to update
        X_ACCOUNT_NUMBER                        => p_cust_account_rec.account_number,
        X_ATTRIBUTE_CATEGORY                    => p_cust_account_rec.attribute_category,
        X_ATTRIBUTE1                            => p_cust_account_rec.attribute1,
        X_ATTRIBUTE2                            => p_cust_account_rec.attribute2,
        X_ATTRIBUTE3                            => p_cust_account_rec.attribute3,
        X_ATTRIBUTE4                            => p_cust_account_rec.attribute4,
        X_ATTRIBUTE5                            => p_cust_account_rec.attribute5,
        X_ATTRIBUTE6                            => p_cust_account_rec.attribute6,
        X_ATTRIBUTE7                            => p_cust_account_rec.attribute7,
        X_ATTRIBUTE8                            => p_cust_account_rec.attribute8,
        X_ATTRIBUTE9                            => p_cust_account_rec.attribute9,
        X_ATTRIBUTE10                           => p_cust_account_rec.attribute10,
        X_ATTRIBUTE11                           => p_cust_account_rec.attribute11,
        X_ATTRIBUTE12                           => p_cust_account_rec.attribute12,
        X_ATTRIBUTE13                           => p_cust_account_rec.attribute13,
        X_ATTRIBUTE14                           => p_cust_account_rec.attribute14,
        X_ATTRIBUTE15                           => p_cust_account_rec.attribute15,
        X_ATTRIBUTE16                           => p_cust_account_rec.attribute16,
        X_ATTRIBUTE17                           => p_cust_account_rec.attribute17,
        X_ATTRIBUTE18                           => p_cust_account_rec.attribute18,
        X_ATTRIBUTE19                           => p_cust_account_rec.attribute19,
        X_ATTRIBUTE20                           => p_cust_account_rec.attribute20,
        X_GLOBAL_ATTRIBUTE_CATEGORY             => p_cust_account_rec.global_attribute_category,
        X_GLOBAL_ATTRIBUTE1                     => p_cust_account_rec.global_attribute1,
        X_GLOBAL_ATTRIBUTE2                     => p_cust_account_rec.global_attribute2,
        X_GLOBAL_ATTRIBUTE3                     => p_cust_account_rec.global_attribute3,
        X_GLOBAL_ATTRIBUTE4                     => p_cust_account_rec.global_attribute4,
        X_GLOBAL_ATTRIBUTE5                     => p_cust_account_rec.global_attribute5,
        X_GLOBAL_ATTRIBUTE6                     => p_cust_account_rec.global_attribute6,
        X_GLOBAL_ATTRIBUTE7                     => p_cust_account_rec.global_attribute7,
        X_GLOBAL_ATTRIBUTE8                     => p_cust_account_rec.global_attribute8,
        X_GLOBAL_ATTRIBUTE9                     => p_cust_account_rec.global_attribute9,
        X_GLOBAL_ATTRIBUTE10                    => p_cust_account_rec.global_attribute10,
        X_GLOBAL_ATTRIBUTE11                    => p_cust_account_rec.global_attribute11,
        X_GLOBAL_ATTRIBUTE12                    => p_cust_account_rec.global_attribute12,
        X_GLOBAL_ATTRIBUTE13                    => p_cust_account_rec.global_attribute13,
        X_GLOBAL_ATTRIBUTE14                    => p_cust_account_rec.global_attribute14,
        X_GLOBAL_ATTRIBUTE15                    => p_cust_account_rec.global_attribute15,
        X_GLOBAL_ATTRIBUTE16                    => p_cust_account_rec.global_attribute16,
        X_GLOBAL_ATTRIBUTE17                    => p_cust_account_rec.global_attribute17,
        X_GLOBAL_ATTRIBUTE18                    => p_cust_account_rec.global_attribute18,
        X_GLOBAL_ATTRIBUTE19                    => p_cust_account_rec.global_attribute19,
        X_GLOBAL_ATTRIBUTE20                    => p_cust_account_rec.global_attribute20,
        X_ORIG_SYSTEM_REFERENCE                 => p_cust_account_rec.orig_system_reference,
        X_STATUS                                => p_cust_account_rec.status,
        X_CUSTOMER_TYPE                         => p_cust_account_rec.customer_type,
        X_CUSTOMER_CLASS_CODE                   => p_cust_account_rec.customer_class_code,
        X_PRIMARY_SALESREP_ID                   => p_cust_account_rec.primary_salesrep_id,
        X_SALES_CHANNEL_CODE                    => p_cust_account_rec.sales_channel_code,
        X_ORDER_TYPE_ID                         => p_cust_account_rec.order_type_id,
        X_PRICE_LIST_ID                         => p_cust_account_rec.price_list_id,
        X_TAX_CODE                              => p_cust_account_rec.tax_code,
        X_FOB_POINT                             => p_cust_account_rec.fob_point,
        X_FREIGHT_TERM                          => p_cust_account_rec.freight_term,
        X_SHIP_PARTIAL                          => p_cust_account_rec.ship_partial,
        X_SHIP_VIA                              => p_cust_account_rec.ship_via,
        X_WAREHOUSE_ID                          => p_cust_account_rec.warehouse_id,
        X_TAX_HEADER_LEVEL_FLAG                 => p_cust_account_rec.tax_header_level_flag,
        X_TAX_ROUNDING_RULE                     => p_cust_account_rec.tax_rounding_rule,
        X_COTERMINATE_DAY_MONTH                 => p_cust_account_rec.coterminate_day_month,
        X_PRIMARY_SPECIALIST_ID                 => p_cust_account_rec.primary_specialist_id,
        X_SECONDARY_SPECIALIST_ID               => p_cust_account_rec.secondary_specialist_id,
        X_ACCOUNT_LIABLE_FLAG                   => p_cust_account_rec.account_liable_flag,
        X_CURRENT_BALANCE                       => p_cust_account_rec.current_balance,
        X_ACCOUNT_ESTABLISHED_DATE              => p_cust_account_rec.account_established_date,
        X_ACCOUNT_TERMINATION_DATE              => p_cust_account_rec.account_termination_date,
        X_ACCOUNT_ACTIVATION_DATE               => p_cust_account_rec.account_activation_date,
        X_DEPARTMENT                            => p_cust_account_rec.department,
        X_HELD_BILL_EXPIRATION_DATE             => p_cust_account_rec.held_bill_expiration_date,
        X_HOLD_BILL_FLAG                        => p_cust_account_rec.hold_bill_flag,
        X_REALTIME_RATE_FLAG                    => p_cust_account_rec.realtime_rate_flag,
        X_ACCT_LIFE_CYCLE_STATUS                => p_cust_account_rec.acct_life_cycle_status,
        X_ACCOUNT_NAME                          => p_cust_account_rec.account_name,
        X_DEPOSIT_REFUND_METHOD                 => p_cust_account_rec.deposit_refund_method,
        X_DORMANT_ACCOUNT_FLAG                  => p_cust_account_rec.dormant_account_flag,
        X_NPA_NUMBER                            => p_cust_account_rec.npa_number,
        X_SUSPENSION_DATE                       => p_cust_account_rec.suspension_date,
        X_SOURCE_CODE                           => p_cust_account_rec.source_code,
        X_COMMENTS                              => p_cust_account_rec.comments,
        X_DATES_NEGATIVE_TOLERANCE              => p_cust_account_rec.dates_negative_tolerance,
        X_DATES_POSITIVE_TOLERANCE              => p_cust_account_rec.dates_positive_tolerance,
        X_DATE_TYPE_PREFERENCE                  => p_cust_account_rec.date_type_preference,
        X_OVER_SHIPMENT_TOLERANCE               => p_cust_account_rec.over_shipment_tolerance,
        X_UNDER_SHIPMENT_TOLERANCE              => p_cust_account_rec.under_shipment_tolerance,
        X_OVER_RETURN_TOLERANCE                 => p_cust_account_rec.over_return_tolerance,
        X_UNDER_RETURN_TOLERANCE                => p_cust_account_rec.under_return_tolerance,
        X_ITEM_CROSS_REF_PREF                   => p_cust_account_rec.item_cross_ref_pref,
        X_SHIP_SETS_INCLUDE_LINES_FLAG          => p_cust_account_rec.ship_sets_include_lines_flag,
        X_ARRIVALSETS_INCL_LINES_FLAG           => p_cust_account_rec.arrivalsets_include_lines_flag,
        X_SCHED_DATE_PUSH_FLAG                  => p_cust_account_rec.sched_date_push_flag,
        X_INVOICE_QUANTITY_RULE                 => p_cust_account_rec.invoice_quantity_rule,
        X_PRICING_EVENT                         => p_cust_account_rec.pricing_event,
        X_STATUS_UPDATE_DATE                    => p_cust_account_rec.status_update_date,
        X_AUTOPAY_FLAG                          => p_cust_account_rec.autopay_flag,
        X_NOTIFY_FLAG                           => p_cust_account_rec.notify_flag,
        X_LAST_BATCH_ID                         => p_cust_account_rec.last_batch_id,
        X_SELLING_PARTY_ID                      => p_cust_account_rec.selling_party_id,
        X_OBJECT_VERSION_NUMBER                 => p_object_version_number,
        X_CREATED_BY_MODULE                     => p_cust_account_rec.created_by_module,
        X_APPLICATION_ID                        => p_cust_account_rec.application_id
    );

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'HZ_CUST_ACCOUNTS_PKG.Update_Row (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    --
    -- R12 party usage project
    --
    IF p_cust_account_rec.status = 'I' AND l_status = 'A' OR
       p_cust_account_rec.status = 'A' AND l_status = 'I'
    THEN
      OPEN c_has_active_account (
        l_party_id, p_cust_account_rec.cust_account_id);
      FETCH c_has_active_account INTO l_dummy;

      IF c_has_active_account%NOTFOUND THEN
        --
        -- inactivate the CUSTOMER usage if we are inactivating last
        -- active account
        --
        IF p_cust_account_rec.status = 'I' THEN
          HZ_PARTY_USG_ASSIGNMENT_PVT.inactivate_usg_assignment (
            p_validation_level          => HZ_PARTY_USG_ASSIGNMENT_PVT.G_VALID_LEVEL_NONE,
            p_party_id                  => l_party_id,
            p_party_usage_code          => 'CUSTOMER',
            x_return_status             => x_return_status,
            x_msg_count                 => l_msg_count,
            x_msg_data                  => l_msg_data
          );
        ELSIF p_cust_account_rec.status = 'A' THEN
          l_party_usg_assignment_rec.party_id := l_party_id;
          l_party_usg_assignment_rec.party_usage_code := 'CUSTOMER';
          l_party_usg_assignment_rec.created_by_module := 'TCA_V2_API';

          HZ_PARTY_USG_ASSIGNMENT_PVT.assign_party_usage (
            p_validation_level          => HZ_PARTY_USG_ASSIGNMENT_PVT.G_VALID_LEVEL_NONE,
            p_party_usg_assignment_rec  => l_party_usg_assignment_rec,
            x_return_status             => x_return_status,
            x_msg_count                 => l_msg_count,
            x_msg_data                  => l_msg_data
          );
        END IF;
      END IF;
      CLOSE c_has_active_account;

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        IF x_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
        ELSE
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
      END IF;
    END IF;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'do_update_cust_account (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

END do_update_cust_account;

/**
 * PRIVATE PROCEDURE do_create_cust_acct_relate
 *
 * DESCRIPTION
 *     Private procedure to create relationship between two customer accounts.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *     HZ_ACCOUNT_VALIDATE_V2PUB.validate_cust_acct_relate
 *     HZ_CUST_ACCT_RELATE_PKG.Insert_Row
 *
 * ARGUMENTS
 *   IN/OUT:
 *     p_cust_acct_relate_rec         Customer account relate record.
 *     x_return_status                Return status after the call. The status can
 *                                    be FND_API.G_RET_STS_SUCCESS (success),
 *                                    FND_API.G_RET_STS_ERROR (error),
 *                                    FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
 *
 * NOTES
 *     This procedure should always raise exception to main API.
 *
 * MODIFICATION HISTORY
 *
 *   07-23-2001    Jianying Huang      o Created.
 *   10-04-2003    Rajib Ranjan Borah  o Bug 2985448.Only active relationships will be checked if
 *                                       reciprocal flag is set.
 *   04-21-2004    Rajib Ranjan Borah  o Bug 3449118. The reciprocal flag of the reverse relationship
 *                                       will be set only if the present relationship is active.
 *   12-MAY-2005   Rajib Ranjan Borah  o TCA SSA Uptake (Bug 3456489)
 *   12-AUG-2005   Idris Ali           o Bug 4529413:Added logic in do_create_cust_acct_relate to use
 *                                       'cust_acct_relate_id' instead of rowid.
 */

PROCEDURE do_create_cust_acct_relate (
    p_cust_acct_relate_rec                  IN OUT NOCOPY CUST_ACCT_RELATE_REC_TYPE,
    x_return_status                         IN OUT NOCOPY VARCHAR2
) IS

    l_debug_prefix                          VARCHAR2(30) := ''; --'do_create_cust_acct_relate';

    -- l_rowid                                 ROWID := NULL;
    l_cust_acct_relate_id                   NUMBER;             -- Bug 4529413
    l_msg_count                             NUMBER;
    l_msg_data                              VARCHAR2(2000);
    l_return_status                         VARCHAR2(1);

    l_cust_acct_relate_rec                  CUST_ACCT_RELATE_REC_TYPE;
    l_customer_reciprocal_flag              HZ_CUST_ACCT_RELATE.customer_reciprocal_flag%TYPE;
BEGIN

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'do_create_cust_acct_relate (+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- No sequence number is used for cust_acct_relate

    /*  Bug 3456489 - Added following if. */
    BEGIN
    MO_GLOBAL.validate_orgid_pub_api(p_cust_acct_relate_rec.org_id,'N',l_return_status);
    EXCEPTION
    WHEN OTHERS
    THEN
      RAISE FND_API.G_EXC_ERROR;
    END;


    -- Validate cust acct relate record
    HZ_ACCOUNT_VALIDATE_V2PUB.validate_cust_acct_relate (
        p_create_update_flag                    => 'C',
        p_cust_acct_relate_rec                  => p_cust_acct_relate_rec,
        p_cust_acct_relate_id                   => NULL,                -- Bug 4529413
        x_return_status                         => x_return_status );

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'HZ_CUST_ACCT_RELATE_PKG.Insert_Row (+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Call table-handler.
    HZ_CUST_ACCT_RELATE_PKG.Insert_Row (
        X_CUST_ACCOUNT_ID                       => p_cust_acct_relate_rec.cust_account_id,
        X_RELATED_CUST_ACCOUNT_ID               => p_cust_acct_relate_rec.related_cust_account_id,
        X_RELATIONSHIP_TYPE                     => p_cust_acct_relate_rec.relationship_type,
        X_COMMENTS                              => p_cust_acct_relate_rec.comments,
        X_ATTRIBUTE_CATEGORY                    => p_cust_acct_relate_rec.attribute_category,
        X_ATTRIBUTE1                            => p_cust_acct_relate_rec.attribute1,
        X_ATTRIBUTE2                            => p_cust_acct_relate_rec.attribute2,
        X_ATTRIBUTE3                            => p_cust_acct_relate_rec.attribute3,
        X_ATTRIBUTE4                            => p_cust_acct_relate_rec.attribute4,
        X_ATTRIBUTE5                            => p_cust_acct_relate_rec.attribute5,
        X_ATTRIBUTE6                            => p_cust_acct_relate_rec.attribute6,
        X_ATTRIBUTE7                            => p_cust_acct_relate_rec.attribute7,
        X_ATTRIBUTE8                            => p_cust_acct_relate_rec.attribute8,
        X_ATTRIBUTE9                            => p_cust_acct_relate_rec.attribute9,
        X_ATTRIBUTE10                           => p_cust_acct_relate_rec.attribute10,
        X_CUSTOMER_RECIPROCAL_FLAG              => p_cust_acct_relate_rec.customer_reciprocal_flag,
        X_STATUS                                => p_cust_acct_relate_rec.status,
        X_ATTRIBUTE11                           => p_cust_acct_relate_rec.attribute11,
        X_ATTRIBUTE12                           => p_cust_acct_relate_rec.attribute12,
        X_ATTRIBUTE13                           => p_cust_acct_relate_rec.attribute13,
        X_ATTRIBUTE14                           => p_cust_acct_relate_rec.attribute14,
        X_ATTRIBUTE15                           => p_cust_acct_relate_rec.attribute15,
        X_BILL_TO_FLAG                          => p_cust_acct_relate_rec.bill_to_flag,
        X_SHIP_TO_FLAG                          => p_cust_acct_relate_rec.ship_to_flag,
        X_OBJECT_VERSION_NUMBER                 => 1,
        X_CREATED_BY_MODULE                     => p_cust_acct_relate_rec.created_by_module,
        X_APPLICATION_ID                        => p_cust_acct_relate_rec.application_id,
        X_ORG_ID                                => p_cust_acct_relate_rec.org_id,
        X_CUST_ACCT_RELATE_ID                   => p_cust_acct_relate_rec.cust_acct_relate_id    -- Bug 4529413
    );

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'HZ_CUST_ACCT_RELATE_PKG.Insert_Row (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    --  check customer_reciprocal_flag, if 'Y', need to create
    --  a relationship record for related customer account or update
    --  an existing one for related customer account.

    IF p_cust_acct_relate_rec.customer_reciprocal_flag = 'Y' AND
       (NVL(p_cust_acct_relate_rec.status,'A') ='A' -- Bug 3449118
        OR
        p_cust_acct_relate_rec.status = FND_API.G_MISS_CHAR  -- Bug 3702516
       )
    THEN
    BEGIN

        -- Debug info.
        IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_message=>'customer_reciprocal_flag = Y ',
                                  p_prefix =>l_debug_prefix,
                                  p_msg_level=>fnd_log.level_statement);
        END IF;

        SELECT CUST_ACCT_RELATE_ID, CUSTOMER_RECIPROCAL_FLAG        -- Bug 4529413
        INTO l_cust_acct_relate_id, l_customer_reciprocal_flag
        FROM HZ_CUST_ACCT_RELATE_ALL  -- Bug 3456489
        WHERE CUST_ACCOUNT_ID = p_cust_acct_relate_rec.related_cust_account_id
        AND RELATED_CUST_ACCOUNT_ID = p_cust_acct_relate_rec.cust_account_id
        --Bug 2985448.
        AND STATUS='A'
        AND ORG_ID = p_cust_acct_relate_rec.org_id; -- Bug 3456489

        -- reciprocal relationship exist, update its reciprocal flag.
        -- customer_reciprocal_flag is NOT NULL column.

        IF l_customer_reciprocal_flag <> 'Y' THEN
            UPDATE HZ_CUST_ACCT_RELATE_ALL
            SET CUSTOMER_RECIPROCAL_FLAG = 'Y'
            WHERE CUST_ACCT_RELATE_ID = l_cust_acct_relate_id;  -- Bug 4529413
        END IF;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            -- reciprocal relationship doesnot exist, create it.

            l_cust_acct_relate_rec := p_cust_acct_relate_rec;
            l_cust_acct_relate_rec.cust_account_id := p_cust_acct_relate_rec.related_cust_account_id;
            l_cust_acct_relate_rec.related_cust_account_id := p_cust_acct_relate_rec.cust_account_id;
            l_cust_acct_relate_rec.cust_acct_relate_id := NULL;
            -- Call API.
            create_cust_acct_relate (
                p_cust_acct_relate_rec                  => l_cust_acct_relate_rec,
                x_return_status                         => x_return_status,
                x_msg_count                             => l_msg_count,
                x_msg_data                              => l_msg_data );

            IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                    RAISE FND_API.G_EXC_ERROR;
                ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;
            END IF;
    END;
    END IF;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'do_create_cust_acct_relate (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

END do_create_cust_acct_relate;

/**
 * PRIVATE PROCEDURE do_update_cust_acct_relate
 *
 * DESCRIPTION
 *     Private procedure to update relationship between two customer accounts.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *     HZ_ACCOUNT_VALIDATE_V2PUB.validate_cust_acct_relate
 *     HZ_CUST_ACCT_RELATE_PKG.Update_Row
 *
 * ARGUMENTS
 *   IN/OUT:
 *     p_cust_acct_relate_rec         Customer account relate record.
 *     p_object_version_number        Used for locking the being updated record.
 *     x_return_status                Return status after the call. The status can
 *                                    be FND_API.G_RET_STS_SUCCESS (success),
 *                                    FND_API.G_RET_STS_ERROR (error),
 *                                    FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
 *
 * NOTES
 *     This procedure should always raise exception to main API.
 *
 * MODIFICATION HISTORY
 *
 *   07-23-2001    Jianying Huang      o Created.
 *   10-04-2003    Rajib Ranjan Borah  o Bug 2985448.Consider only active relationships to get
 *                                       correct record for locking.
 *   04-21-2004    Rajib Ranjan Borah  o Bug 3449118. Added parameter p_rowid.
 *                                       IF p_rowid is passed, then that record will be
 *                                       modified. Else the only active relationship will
 *                                       be modified.
 *   12-MAY-2005   Rajib Ranjan Borah  o TCA SSA Uptake (Bug 3456489)
 *   12-AUG-2005   Idris Ali           o Bug 4529413:Added logic in do_update_cust_acct_relate
 *                                       to allow update using newly added primary key 'cust_acct_relate_id'.
 */

PROCEDURE do_update_cust_acct_relate (
    p_cust_acct_relate_rec                  IN OUT NOCOPY CUST_ACCT_RELATE_REC_TYPE,
    p_object_version_number                 IN OUT NOCOPY NUMBER,
    p_rowid                                 IN            ROWID,
    x_return_status                         IN OUT NOCOPY VARCHAR2
) IS

    l_debug_prefix                          VARCHAR2(30) := ''; --'do_update_cust_acct_relate';

    l_rowid                                 ROWID  := NULL;
    l_object_version_number                 NUMBER;

    -- Bug 3449118
    l_cust_account_id                       HZ_CUST_ACCT_RELATE.cust_account_id%TYPE;
    l_related_cust_account_id               HZ_CUST_ACCT_RELATE.related_cust_account_id%TYPE;
    l_status                                HZ_CUST_ACCT_RELATE.status%TYPE;
    l_cust_acct_relate_id                   HZ_CUST_ACCT_RELATE.cust_acct_relate_id%TYPE;     -- Bug 4529413
    l_count                                 NUMBER;

BEGIN

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'do_update_cust_acct_relate (+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Lock record.

    IF p_rowid is NULL AND p_cust_acct_relate_rec.cust_acct_relate_id is NULL THEN  -- Bug 4529413

        BEGIN
            SELECT CUST_ACCT_RELATE_ID,
                   OBJECT_VERSION_NUMBER,
                   ORG_ID
            INTO   l_cust_acct_relate_id,
                   l_object_version_number,
                   p_cust_acct_relate_rec.org_id  -- Bug 3456489
            FROM   HZ_CUST_ACCT_RELATE
            WHERE  CUST_ACCOUNT_ID = p_cust_acct_relate_rec.cust_account_id AND
                   RELATED_CUST_ACCOUNT_ID = p_cust_acct_relate_rec.related_cust_account_id AND
            --Bug 2985448.
                   STATUS='A'  AND
                   ORG_ID = NVL(p_cust_acct_relate_rec.org_id, ORG_ID)
            FOR UPDATE NOWAIT;

        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                FND_MESSAGE.SET_NAME('AR','HZ_API_NO_ACTIVE_RECORD');
                FND_MESSAGE.SET_TOKEN( 'ACCOUNT1',p_cust_acct_relate_rec.cust_account_id);
                FND_MESSAGE.SET_TOKEN( 'ACCOUNT2',p_cust_acct_relate_rec.related_cust_account_id);
                FND_MSG_PUB.ADD;
                x_return_status := FND_API.G_RET_STS_ERROR;
                RAISE FND_API.G_EXC_ERROR;
        END;
    ELSE   --- Bug 3449118.

      IF p_cust_acct_relate_rec.cust_acct_relate_id IS NULL THEN    -- Bug 4529413

        BEGIN
            SELECT CUST_ACCT_RELATE_ID
            INTO   l_cust_acct_relate_id
            FROM   HZ_CUST_ACCT_RELATE
            WHERE  ROWID = p_rowid;

        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_NO_RECORD' );
                FND_MESSAGE.SET_TOKEN( 'RECORD', 'customer account relate' );
                FND_MESSAGE.SET_TOKEN( 'VALUE',p_rowid);
                FND_MSG_PUB.ADD;
                x_return_status := FND_API.G_RET_STS_ERROR;
                RAISE FND_API.G_EXC_ERROR;
        END;
      ELSE
           l_cust_acct_relate_id := p_cust_acct_relate_rec.cust_acct_relate_id;

      END IF;

      BEGIN
            SELECT OBJECT_VERSION_NUMBER,
                   CUST_ACCOUNT_ID,
                   RELATED_CUST_ACCOUNT_ID,
                   STATUS,
                   ORG_ID
            INTO   l_object_version_number,
                   l_cust_account_id,
                   l_related_cust_account_id,
                   l_status,
                   p_cust_acct_relate_rec.org_id  -- Bug 3456489
            FROM   HZ_CUST_ACCT_RELATE_ALL
            WHERE  CUST_ACCT_RELATE_ID = l_cust_acct_relate_id
            FOR UPDATE NOWAIT;

            -- cust_account_id is not updateable.
            IF p_cust_acct_relate_rec.cust_account_id IS NOT NULL AND
                 (p_cust_acct_relate_rec.cust_account_id = FND_API.G_MISS_NUM OR
                  l_cust_account_id <> p_cust_acct_relate_rec.cust_account_id)
            THEN
                FND_MESSAGE.SET_NAME ('AR','HZ_API_NONUPDATEABLE_COLUMN');
                FND_MESSAGE.SET_TOKEN('COLUMN','CUST_ACCOUNT_ID');
                FND_MSG_PUB.ADD;
                x_return_status := FND_API.G_RET_STS_ERROR;
            END IF;

            -- related_cust_account_id is not updateable.
            IF p_cust_acct_relate_rec.related_cust_account_id IS NOT NULL AND
                 (p_cust_acct_relate_rec.related_cust_account_id = FND_API.G_MISS_NUM OR
                  l_related_cust_account_id <> p_cust_acct_relate_rec.related_cust_account_id)
            THEN
                FND_MESSAGE.SET_NAME ('AR','HZ_API_NONUPDATEABLE_COLUMN');
                FND_MESSAGE.SET_TOKEN('COLUMN','RELATED_CUST_ACCOUNT_ID');
                FND_MSG_PUB.ADD;
                x_return_status := FND_API.G_RET_STS_ERROR;
            END IF;

            -- If status is updated to Active
            IF p_cust_acct_relate_rec.status = 'A'
               AND
               l_status = 'I'
            THEN
                SELECT COUNT(*)
                INTO   l_count
                FROM   HZ_CUST_ACCT_RELATE_ALL  -- Bug 3456489
                WHERE  CUST_ACCOUNT_ID = l_cust_account_id AND
                       RELATED_CUST_ACCOUNT_ID = l_related_cust_account_id AND
                       STATUS = 'A' AND
                       ORG_ID = p_cust_acct_relate_rec.org_id; -- Bug 3456489

                IF l_count <> 0 THEN
                    FND_MESSAGE.SET_NAME ('AR','HZ_ACTIVE_CUST_ACCT_RELATE');
                    FND_MESSAGE.SET_TOKEN('ACCOUNT1',l_cust_account_id);
                    FND_MESSAGE.SET_TOKEN('ACCOUNT2',l_related_cust_account_id);
                    FND_MSG_PUB.ADD;
                    x_return_status := FND_API.G_RET_STS_ERROR;
                END IF;

            END IF;

        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_NO_RECORD' );
                FND_MESSAGE.SET_TOKEN( 'RECORD', 'customer account relate' );
                FND_MESSAGE.SET_TOKEN( 'VALUE', l_cust_acct_relate_id);
                FND_MSG_PUB.ADD;
                x_return_status := FND_API.G_RET_STS_ERROR;
                RAISE FND_API.G_EXC_ERROR;
        END;
    END IF;

    IF NOT (
       ( p_object_version_number IS NULL AND l_object_version_number IS NULL ) OR
         ( p_object_version_number IS NOT NULL AND
         l_object_version_number IS NOT NULL AND
         p_object_version_number = l_object_version_number ) )
    THEN
        FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_RECORD_CHANGED' );
        FND_MESSAGE.SET_TOKEN( 'TABLE', 'hz_cust_acct_relate' );
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

        p_object_version_number := NVL( l_object_version_number, 1 ) + 1;


    -- Validate cust acct relate record
    HZ_ACCOUNT_VALIDATE_V2PUB.validate_cust_acct_relate (
        p_create_update_flag                    => 'U',
        p_cust_acct_relate_rec                  => p_cust_acct_relate_rec,
        p_cust_acct_relate_id                   => l_cust_acct_relate_id,  -- Bug 4529413
        x_return_status                         => x_return_status );


    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'HZ_CUST_ACCT_RELATE_PKG.Update_Row (+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Call table-handler.
    HZ_CUST_ACCT_RELATE_PKG.Update_Row (
        X_CUST_ACCT_RELATE_ID                   => l_cust_acct_relate_id,
        X_CUST_ACCOUNT_ID                       => p_cust_acct_relate_rec.cust_account_id,
        X_RELATED_CUST_ACCOUNT_ID               => p_cust_acct_relate_rec.related_cust_account_id,
        X_RELATIONSHIP_TYPE                     => p_cust_acct_relate_rec.relationship_type,
        X_COMMENTS                              => p_cust_acct_relate_rec.comments,
        X_ATTRIBUTE_CATEGORY                    => p_cust_acct_relate_rec.attribute_category,
        X_ATTRIBUTE1                            => p_cust_acct_relate_rec.attribute1,
        X_ATTRIBUTE2                            => p_cust_acct_relate_rec.attribute2,
        X_ATTRIBUTE3                            => p_cust_acct_relate_rec.attribute3,
        X_ATTRIBUTE4                            => p_cust_acct_relate_rec.attribute4,
        X_ATTRIBUTE5                            => p_cust_acct_relate_rec.attribute5,
        X_ATTRIBUTE6                            => p_cust_acct_relate_rec.attribute6,
        X_ATTRIBUTE7                            => p_cust_acct_relate_rec.attribute7,
        X_ATTRIBUTE8                            => p_cust_acct_relate_rec.attribute8,
        X_ATTRIBUTE9                            => p_cust_acct_relate_rec.attribute9,
        X_ATTRIBUTE10                           => p_cust_acct_relate_rec.attribute10,
        X_CUSTOMER_RECIPROCAL_FLAG              => p_cust_acct_relate_rec.customer_reciprocal_flag,
        X_STATUS                                => p_cust_acct_relate_rec.status,
        X_ATTRIBUTE11                           => p_cust_acct_relate_rec.attribute11,
        X_ATTRIBUTE12                           => p_cust_acct_relate_rec.attribute12,
        X_ATTRIBUTE13                           => p_cust_acct_relate_rec.attribute13,
        X_ATTRIBUTE14                           => p_cust_acct_relate_rec.attribute14,
        X_ATTRIBUTE15                           => p_cust_acct_relate_rec.attribute15,
        X_BILL_TO_FLAG                          => p_cust_acct_relate_rec.bill_to_flag,
        X_SHIP_TO_FLAG                          => p_cust_acct_relate_rec.ship_to_flag,
        X_OBJECT_VERSION_NUMBER                 => p_object_version_number,
        X_CREATED_BY_MODULE                     => p_cust_acct_relate_rec.created_by_module,
        X_APPLICATION_ID                        => p_cust_acct_relate_rec.application_id
    );

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'HZ_CUST_ACCT_RELATE_PKG.Update_Row (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- customer_reciprocal_flag is non-updateable. We do not need to implement the
    -- same logic in insert mode during update.

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'do_update_cust_acct_relate (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

END do_update_cust_acct_relate;

--------------------------------------
-- public procedures and functions
--------------------------------------

/**
 * PROCEDURE create_cust_account
 *
 * DESCRIPTION
 *     Creates customer account for person party.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *     HZ_PARTY_V2PUB.create_person
 *     HZ_CUSTOMER_PROFIE_V2PUB.create_customer_profile
 *     HZ_BUSINESS_EVENT_V2PVT.create_cust_account_event
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_cust_account_rec             Customer account record.
 *     p_person_rec                   Person party record which being created account
 *                                    belongs to. If party_id in person record is not
 *                                    passed in or party_id does not exist in hz_parties,
 *                                    API ceates a person party based on this record.
 *     p_customer_profile_rec         Customer profile record. One customer account
 *                                    must have a customer profile.
 *     p_create_profile_amt           If it is set to FND_API.G_TRUE, API create customer
 *                                    profile amounts by copying corresponding data
 *                                    from customer profile class amounts.
 *   IN/OUT:
 *   OUT:
 *     x_cust_account_id              Customer account ID.
 *     x_account_number               Customer account number.
 *     x_party_id                     Party ID of the person party which this account
 *                                    belongs to.
 *     x_party_number                 Party number of the person party which this account
 *                                    belongs to.
 *     x_profile_id                   Person profile ID.
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

PROCEDURE create_cust_account (
    p_init_msg_list                         IN     VARCHAR2 := FND_API.G_FALSE,
    p_cust_account_rec                      IN     CUST_ACCOUNT_REC_TYPE,
    p_person_rec                            IN     HZ_PARTY_V2PUB.PERSON_REC_TYPE,
    p_customer_profile_rec                  IN     HZ_CUSTOMER_PROFILE_V2PUB.CUSTOMER_PROFILE_REC_TYPE,
    p_create_profile_amt                    IN     VARCHAR2 := FND_API.G_TRUE,
    x_cust_account_id                       OUT NOCOPY    NUMBER,
    x_account_number                        OUT NOCOPY    VARCHAR2,
    x_party_id                              OUT NOCOPY    NUMBER,
    x_party_number                          OUT NOCOPY    VARCHAR2,
    x_profile_id                            OUT NOCOPY    NUMBER,
    x_return_status                         OUT NOCOPY    VARCHAR2,
    x_msg_count                             OUT NOCOPY    NUMBER,
    x_msg_data                              OUT NOCOPY    VARCHAR2
) IS

    l_cust_account_rec                      CUST_ACCOUNT_REC_TYPE := p_cust_account_rec;
    l_person_rec                            HZ_PARTY_V2PUB.PERSON_REC_TYPE := p_person_rec;
    l_customer_profile_rec                  HZ_CUSTOMER_PROFILE_V2PUB.CUSTOMER_PROFILE_REC_TYPE := p_customer_profile_rec;
    l_debug_prefix                          VARCHAR2(30) := '';
BEGIN

    -- Standard start of API savepoint
    SAVEPOINT create_cust_account;

    -- Check if API is called in debug mode. If yes, enable debug.
    --enable_debug;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'create_cust_account (+) : for person',
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
        p_cust_account_rec           => l_cust_account_rec,
        x_return_status              => x_return_status
      );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;

    -- Call to business logic.
    do_create_cust_account (
        'PERSON',
        l_cust_account_rec,
        l_person_rec,
        HZ_PARTY_V2PUB.G_MISS_ORGANIZATION_REC,
        l_customer_profile_rec,
        p_create_profile_amt,
        x_cust_account_id,
        x_account_number,
        x_party_id,
        x_party_number,
        x_profile_id,
        x_return_status );


   IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
     IF(HZ_UTILITY_V2PUB.G_EXECUTE_API_CALLOUTS in ('Y', 'EVENTS_ENABLED')) THEN
       -- Invoke business event system.
       HZ_BUSINESS_EVENT_V2PVT.create_cust_account_event (
         l_cust_account_rec,
         l_person_rec,
         l_customer_profile_rec,
         p_create_profile_amt );
     END IF;

     IF(HZ_UTILITY_V2PUB.G_EXECUTE_API_CALLOUTS in ('EVENTS_ENABLED', 'BO_EVENTS_ENABLED')) THEN
       -- populate function for integration service
       HZ_POPULATE_BOT_PKG.pop_hz_cust_accounts(
         p_operation         => 'I',
         p_cust_account_id => x_cust_account_id );
     END IF;
   END IF;

    -- Call to indicate account creation to DQM
    HZ_DQM_SYNC.sync_cust_account(l_cust_account_rec.CUST_ACCOUNT_ID,'C');

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
        hz_utility_v2pub.debug(p_message=>'create_cust_account (-) : for person',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Check if API is called in debug mode. If yes, disable debug.
    --disable_debug;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO create_cust_account;
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
                hz_utility_v2pub.debug(p_message=>'create_cust_account (-) : for person',
                                       p_prefix=>l_debug_prefix,
                                       p_msg_level=>fnd_log.level_procedure);
        END IF;

        -- Check if API is called in debug mode. If yes, disable debug.
        --disable_debug;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO create_cust_account;
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
            hz_utility_v2pub.debug(p_message=>'create_cust_account (-) : for person',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
        END IF;

        -- Check if API is called in debug mode. If yes, disable debug.
        --disable_debug;

    WHEN OTHERS THEN
        ROLLBACK TO create_cust_account;
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
            hz_utility_v2pub.debug(p_message=>'create_cust_account (-) : for person',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
        END IF;

        -- Check if API is called in debug mode. If yes, disable debug.
        --disable_debug;

END create_cust_account;

/**
 * PROCEDURE create_cust_account
 *
 * DESCRIPTION
 *     Creates customer account for organization party.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *     HZ_PARTY_V2PUB.create_organization
 *     HZ_CUSTOMER_PROFILE_V2PUB.create_customer_profile
 *     HZ_BUSINESS_EVENT_V2PVT.create_cust_account_event
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_cust_account_rec             Customer account record.
 *     p_organization_rec             Organization party record which being created account
 *                                    belongs to. If party_id in organization record is not
 *                                    passed in or party_id does not exist in hz_parties,
 *                                    API ceates a organization party based on this record.
 *     p_customer_profile_rec         Customer profile record. One customer account
 *                                    must have a customer profile.
 *     p_create_profile_amt           If it is set to FND_API.G_TRUE, API create customer
 *                                    profile amounts by copying corresponding data
 *                                    from customer profile class amounts.
 *   IN/OUT:
 *   OUT:
 *     x_cust_account_id              Customer account ID.
 *     x_account_number               Customer account number.
 *     x_party_id                     Party ID of the organization party which this account
 *                                    belongs to.
 *     x_party_number                 Party number of the organization party which this
 *                                    account belongs to.
 *     x_profile_id                   Organization profile ID.
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

PROCEDURE create_cust_account (
    p_init_msg_list                         IN     VARCHAR2 := FND_API.G_FALSE,
    p_cust_account_rec                      IN     CUST_ACCOUNT_REC_TYPE,
    p_organization_rec                      IN     HZ_PARTY_V2PUB.ORGANIZATION_REC_TYPE,
    p_customer_profile_rec                  IN     HZ_CUSTOMER_PROFILE_V2PUB.CUSTOMER_PROFILE_REC_TYPE,
    p_create_profile_amt                    IN     VARCHAR2 := FND_API.G_TRUE,
    x_cust_account_id                       OUT NOCOPY    NUMBER,
    x_account_number                        OUT NOCOPY    VARCHAR2,
    x_party_id                              OUT NOCOPY    NUMBER,
    x_party_number                          OUT NOCOPY    VARCHAR2,
    x_profile_id                            OUT NOCOPY    NUMBER,
    x_return_status                         OUT NOCOPY    VARCHAR2,
    x_msg_count                             OUT NOCOPY    NUMBER,
    x_msg_data                              OUT NOCOPY    VARCHAR2
) IS

    l_cust_account_rec                      CUST_ACCOUNT_REC_TYPE := p_cust_account_rec;
    l_organization_rec                      HZ_PARTY_V2PUB.ORGANIZATION_REC_TYPE := p_organization_rec;
    l_customer_profile_rec                  HZ_CUSTOMER_PROFILE_V2PUB.CUSTOMER_PROFILE_REC_TYPE := p_customer_profile_rec;
    l_debug_prefix                          VARCHAR2(30) := '';
BEGIN

    -- Standard start of API savepoint
    SAVEPOINT create_cust_account;

    -- Check if API is called in debug mode. If yes, enable debug.
    --enable_debug;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'create_cust_account (+) : for organization',
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
        p_cust_account_rec           => l_cust_account_rec,
        x_return_status              => x_return_status
      );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;

    -- Call to business logic.
    do_create_cust_account (
        'ORGANIZATION',
        l_cust_account_rec,
        HZ_PARTY_V2PUB.G_MISS_PERSON_REC,
        l_organization_rec,
        l_customer_profile_rec,
        p_create_profile_amt,
        x_cust_account_id,
        x_account_number,
        x_party_id,
        x_party_number,
        x_profile_id,
        x_return_status );

   IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
     IF(HZ_UTILITY_V2PUB.G_EXECUTE_API_CALLOUTS in ('Y', 'EVENTS_ENABLED')) THEN
       -- Invoke business event system.
       HZ_BUSINESS_EVENT_V2PVT.create_cust_account_event (
         l_cust_account_rec,
         l_organization_rec,
         l_customer_profile_rec,
         p_create_profile_amt );
     END IF;

     IF(HZ_UTILITY_V2PUB.G_EXECUTE_API_CALLOUTS in ('EVENTS_ENABLED', 'BO_EVENTS_ENABLED')) THEN
       -- populate function for integration service
       HZ_POPULATE_BOT_PKG.pop_hz_cust_accounts(
         p_operation         => 'I',
         p_cust_account_id => x_cust_account_id );
     END IF;
   END IF;

    -- Call to indicate account creation to DQM
    HZ_DQM_SYNC.sync_cust_account(l_cust_account_rec.CUST_ACCOUNT_ID,'C');

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
                 hz_utility_v2pub.debug(p_message=>'create_cust_account (-) : for organization',
                                        p_prefix=>l_debug_prefix,
                                        p_msg_level=>fnd_log.level_procedure);
    END IF;


    -- Check if API is called in debug mode. If yes, disable debug.
    --disable_debug;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO create_cust_account;
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
            hz_utility_v2pub.debug(p_message=>'create_cust_account (-) : for organization',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
        END IF;

        -- Check if API is called in debug mode. If yes, disable debug.
        --disable_debug;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO create_cust_account;
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
            hz_utility_v2pub.debug(p_message=>'create_cust_account (-) : for organization',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
        END IF;

        -- Check if API is called in debug mode. If yes, disable debug.
        --disable_debug;

    WHEN OTHERS THEN
        ROLLBACK TO create_cust_account;
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
            hz_utility_v2pub.debug(p_message=>'create_cust_account (-) : for organization',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
        END IF;


        -- Check if API is called in debug mode. If yes, disable debug.
        --disable_debug;

END create_cust_account;

/**
 * PROCEDURE update_cust_account
 *
 * DESCRIPTION
 *     Updates customer account.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *     HZ_BUSINESS_EVENT_V2PVT.update_cust_account_event
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_cust_account_rec             Customer account record.
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

PROCEDURE update_cust_account (
    p_init_msg_list                         IN     VARCHAR2 := FND_API.G_FALSE,
    p_cust_account_rec                      IN     CUST_ACCOUNT_REC_TYPE,
    p_object_version_number                 IN OUT NOCOPY NUMBER,
    x_return_status                         OUT NOCOPY    VARCHAR2,
    x_msg_count                             OUT NOCOPY    NUMBER,
    x_msg_data                              OUT NOCOPY    VARCHAR2
) IS

    l_cust_account_rec                      CUST_ACCOUNT_REC_TYPE := p_cust_account_rec;
    l_old_cust_account_rec                  CUST_ACCOUNT_REC_TYPE;
    l_old_customer_profile_rec              HZ_CUSTOMER_PROFILE_V2PUB.CUSTOMER_PROFILE_REC_TYPE;
    l_debug_prefix                          VARCHAR2(30) := '';
BEGIN

    -- Standard start of API savepoint
    SAVEPOINT update_cust_account;

    -- Check if API is called in debug mode. If yes, enable debug.
    --enable_debug;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'update_cust_account (+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF (p_cust_account_rec.orig_system is not null and p_cust_account_rec.orig_system <>fnd_api.g_miss_char)
    and (p_cust_account_rec.orig_system_reference is not null and p_cust_account_rec.orig_system_reference <>fnd_api.g_miss_char)
    and (p_cust_account_rec.cust_account_id = FND_API.G_MISS_NUM or p_cust_account_rec.cust_account_id is null) THEN
    hz_orig_system_ref_pub.get_owner_table_id
   (p_orig_system => p_cust_account_rec.orig_system,
   p_orig_system_reference => p_cust_account_rec.orig_system_reference,
   p_owner_table_name => 'HZ_CUST_ACCOUNTS',
   x_owner_table_id => l_cust_account_rec.cust_account_id,
   x_return_status => x_return_status);
     IF x_return_status <> fnd_api.g_ret_sts_success THEN
    RAISE FND_API.G_EXC_ERROR;
     END IF;

      END IF;

   get_cust_account_rec (
      p_cust_account_id        => l_cust_account_rec.cust_account_id,
      x_cust_account_rec       => l_old_cust_account_rec,
      x_customer_profile_rec   => l_old_customer_profile_rec,
      x_return_status          => x_return_status,
      x_msg_count              => x_msg_count,
      x_msg_data               => x_msg_data);

    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- report error on obsolete columns based on profile
    IF NVL(FND_PROFILE.VALUE('HZ_API_ERR_ON_OBSOLETE_COLUMN'), 'Y') = 'Y' THEN
      check_obsolete_columns (
        p_create_update_flag         => 'U',
        p_cust_account_rec           => l_cust_account_rec,
        p_old_cust_account_rec       => l_old_cust_account_rec,
        x_return_status              => x_return_status
      );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;

    -- Call to business logic.
    do_update_cust_account (
        l_cust_account_rec,
        p_object_version_number,
        x_return_status );

   IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
     -- Invoke business event system.
     l_old_cust_account_rec.orig_system := l_cust_account_rec.orig_system;
     IF(HZ_UTILITY_V2PUB.G_EXECUTE_API_CALLOUTS in ('Y', 'EVENTS_ENABLED')) THEN
       HZ_BUSINESS_EVENT_V2PVT.update_cust_account_event (
         l_cust_account_rec , l_old_cust_account_rec);
     END IF;

     IF(HZ_UTILITY_V2PUB.G_EXECUTE_API_CALLOUTS in ('EVENTS_ENABLED', 'BO_EVENTS_ENABLED')) THEN
       -- populate function for integration service
       HZ_POPULATE_BOT_PKG.pop_hz_cust_accounts(
         p_operation         => 'U',
         p_cust_account_id => l_cust_account_rec.cust_account_id );
     END IF;
   END IF;

    -- Call to indicate account update to DQM
    HZ_DQM_SYNC.sync_cust_account(l_cust_account_rec.CUST_ACCOUNT_ID,'U');

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
                 hz_utility_v2pub.debug(p_message=>'update_cust_account (-)',
                                        p_prefix=>l_debug_prefix,
                                        p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Check if API is called in debug mode. If yes, disable debug.
    --disable_debug;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO update_cust_account;
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
            hz_utility_v2pub.debug(p_message=>'update_cust_account (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
        END IF;

        -- Check if API is called in debug mode. If yes, disable debug.
        --disable_debug;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO update_cust_account;
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
            hz_utility_v2pub.debug(p_message=>'update_cust_account (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
        END IF;

        -- Check if API is called in debug mode. If yes, disable debug.
        --disable_debug;

    WHEN OTHERS THEN
        ROLLBACK TO update_cust_account;
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
            hz_utility_v2pub.debug(p_message=>'update_cust_account (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
        END IF;

        -- Check if API is called in debug mode. If yes, disable debug.
        --disable_debug;

END update_cust_account;

/**
 * PROCEDURE get_cust_account_rec
 *
 * DESCRIPTION
 *      Gets customer account record
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *     HZ_CUST_ACCOUNTS_PKG.Select_Row
 *     HZ_CUSTOMER_PROFILE_V2PUB.get_customer_profile_rec
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_cust_account_id              Customer account id.
 *   IN/OUT:
 *   OUT:
 *     x_cust_account_rec             Returned customer account record.
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

PROCEDURE get_cust_account_rec (
    p_init_msg_list                         IN     VARCHAR2 := FND_API.G_FALSE,
    p_cust_account_id                       IN     NUMBER,
    x_cust_account_rec                      OUT    NOCOPY CUST_ACCOUNT_REC_TYPE,
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
        hz_utility_v2pub.debug(p_message=>'get_cust_account_rec (+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Check whether primary key has been passed in.
    IF p_cust_account_id IS NULL OR
       p_cust_account_id = FND_API.G_MISS_NUM THEN
        FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_MISSING_COLUMN' );
        FND_MESSAGE.SET_TOKEN( 'COLUMN', 'cust_account_id' );
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    x_cust_account_rec.cust_account_id := p_cust_account_id;

    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'HZ_CUST_ACCOUNTS_PKG.Select_Row (+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Call table-handler.
    HZ_CUST_ACCOUNTS_PKG.Select_Row (
        X_CUST_ACCOUNT_ID                       => x_cust_account_rec.cust_account_id,
        X_ACCOUNT_NUMBER                        => x_cust_account_rec.account_number,
        X_ATTRIBUTE_CATEGORY                    => x_cust_account_rec.attribute_category,
        X_ATTRIBUTE1                            => x_cust_account_rec.attribute1,
        X_ATTRIBUTE2                            => x_cust_account_rec.attribute2,
        X_ATTRIBUTE3                            => x_cust_account_rec.attribute3,
        X_ATTRIBUTE4                            => x_cust_account_rec.attribute4,
        X_ATTRIBUTE5                            => x_cust_account_rec.attribute5,
        X_ATTRIBUTE6                            => x_cust_account_rec.attribute6,
        X_ATTRIBUTE7                            => x_cust_account_rec.attribute7,
        X_ATTRIBUTE8                            => x_cust_account_rec.attribute8,
        X_ATTRIBUTE9                            => x_cust_account_rec.attribute9,
        X_ATTRIBUTE10                           => x_cust_account_rec.attribute10,
        X_ATTRIBUTE11                           => x_cust_account_rec.attribute11,
        X_ATTRIBUTE12                           => x_cust_account_rec.attribute12,
        X_ATTRIBUTE13                           => x_cust_account_rec.attribute13,
        X_ATTRIBUTE14                           => x_cust_account_rec.attribute14,
        X_ATTRIBUTE15                           => x_cust_account_rec.attribute15,
        X_ATTRIBUTE16                           => x_cust_account_rec.attribute16,
        X_ATTRIBUTE17                           => x_cust_account_rec.attribute17,
        X_ATTRIBUTE18                           => x_cust_account_rec.attribute18,
        X_ATTRIBUTE19                           => x_cust_account_rec.attribute19,
        X_ATTRIBUTE20                           => x_cust_account_rec.attribute20,
        X_GLOBAL_ATTRIBUTE_CATEGORY             => x_cust_account_rec.global_attribute_category,
        X_GLOBAL_ATTRIBUTE1                     => x_cust_account_rec.global_attribute1,
        X_GLOBAL_ATTRIBUTE2                     => x_cust_account_rec.global_attribute2,
        X_GLOBAL_ATTRIBUTE3                     => x_cust_account_rec.global_attribute3,
        X_GLOBAL_ATTRIBUTE4                     => x_cust_account_rec.global_attribute4,
        X_GLOBAL_ATTRIBUTE5                     => x_cust_account_rec.global_attribute5,
        X_GLOBAL_ATTRIBUTE6                     => x_cust_account_rec.global_attribute6,
        X_GLOBAL_ATTRIBUTE7                     => x_cust_account_rec.global_attribute7,
        X_GLOBAL_ATTRIBUTE8                     => x_cust_account_rec.global_attribute8,
        X_GLOBAL_ATTRIBUTE9                     => x_cust_account_rec.global_attribute9,
        X_GLOBAL_ATTRIBUTE10                    => x_cust_account_rec.global_attribute10,
        X_GLOBAL_ATTRIBUTE11                    => x_cust_account_rec.global_attribute11,
        X_GLOBAL_ATTRIBUTE12                    => x_cust_account_rec.global_attribute12,
        X_GLOBAL_ATTRIBUTE13                    => x_cust_account_rec.global_attribute13,
        X_GLOBAL_ATTRIBUTE14                    => x_cust_account_rec.global_attribute14,
        X_GLOBAL_ATTRIBUTE15                    => x_cust_account_rec.global_attribute15,
        X_GLOBAL_ATTRIBUTE16                    => x_cust_account_rec.global_attribute16,
        X_GLOBAL_ATTRIBUTE17                    => x_cust_account_rec.global_attribute17,
        X_GLOBAL_ATTRIBUTE18                    => x_cust_account_rec.global_attribute18,
        X_GLOBAL_ATTRIBUTE19                    => x_cust_account_rec.global_attribute19,
        X_GLOBAL_ATTRIBUTE20                    => x_cust_account_rec.global_attribute20,
        X_ORIG_SYSTEM_REFERENCE                 => x_cust_account_rec.orig_system_reference,
        X_STATUS                                => x_cust_account_rec.status,
        X_CUSTOMER_TYPE                         => x_cust_account_rec.customer_type,
        X_CUSTOMER_CLASS_CODE                   => x_cust_account_rec.customer_class_code,
        X_PRIMARY_SALESREP_ID                   => x_cust_account_rec.primary_salesrep_id,
        X_SALES_CHANNEL_CODE                    => x_cust_account_rec.sales_channel_code,
        X_ORDER_TYPE_ID                         => x_cust_account_rec.order_type_id,
        X_PRICE_LIST_ID                         => x_cust_account_rec.price_list_id,
        X_TAX_CODE                              => x_cust_account_rec.tax_code,
        X_FOB_POINT                             => x_cust_account_rec.fob_point,
        X_FREIGHT_TERM                          => x_cust_account_rec.freight_term,
        X_SHIP_PARTIAL                          => x_cust_account_rec.ship_partial,
        X_SHIP_VIA                              => x_cust_account_rec.ship_via,
        X_WAREHOUSE_ID                          => x_cust_account_rec.warehouse_id,
        X_TAX_HEADER_LEVEL_FLAG                 => x_cust_account_rec.tax_header_level_flag,
        X_TAX_ROUNDING_RULE                     => x_cust_account_rec.tax_rounding_rule,
        X_COTERMINATE_DAY_MONTH                 => x_cust_account_rec.coterminate_day_month,
        X_PRIMARY_SPECIALIST_ID                 => x_cust_account_rec.primary_specialist_id,
        X_SECONDARY_SPECIALIST_ID               => x_cust_account_rec.secondary_specialist_id,
        X_ACCOUNT_LIABLE_FLAG                   => x_cust_account_rec.account_liable_flag,
        X_CURRENT_BALANCE                       => x_cust_account_rec.current_balance,
        X_ACCOUNT_ESTABLISHED_DATE              => x_cust_account_rec.account_established_date,
        X_ACCOUNT_TERMINATION_DATE              => x_cust_account_rec.account_termination_date,
        X_ACCOUNT_ACTIVATION_DATE               => x_cust_account_rec.account_activation_date,
        X_DEPARTMENT                            => x_cust_account_rec.department,
        X_HELD_BILL_EXPIRATION_DATE             => x_cust_account_rec.held_bill_expiration_date,
        X_HOLD_BILL_FLAG                        => x_cust_account_rec.hold_bill_flag,
        X_REALTIME_RATE_FLAG                    => x_cust_account_rec.realtime_rate_flag,
        X_ACCT_LIFE_CYCLE_STATUS                => x_cust_account_rec.acct_life_cycle_status,
        X_ACCOUNT_NAME                          => x_cust_account_rec.account_name,
        X_DEPOSIT_REFUND_METHOD                 => x_cust_account_rec.deposit_refund_method,
        X_DORMANT_ACCOUNT_FLAG                  => x_cust_account_rec.dormant_account_flag,
        X_NPA_NUMBER                            => x_cust_account_rec.npa_number,
        X_SUSPENSION_DATE                       => x_cust_account_rec.suspension_date,
        X_SOURCE_CODE                           => x_cust_account_rec.source_code,
        X_COMMENTS                              => x_cust_account_rec.comments,
        X_DATES_NEGATIVE_TOLERANCE              => x_cust_account_rec.dates_negative_tolerance,
        X_DATES_POSITIVE_TOLERANCE              => x_cust_account_rec.dates_positive_tolerance,
        X_DATE_TYPE_PREFERENCE                  => x_cust_account_rec.date_type_preference,
        X_OVER_SHIPMENT_TOLERANCE               => x_cust_account_rec.over_shipment_tolerance,
        X_UNDER_SHIPMENT_TOLERANCE              => x_cust_account_rec.under_shipment_tolerance,
        X_OVER_RETURN_TOLERANCE                 => x_cust_account_rec.over_return_tolerance,
        X_UNDER_RETURN_TOLERANCE                => x_cust_account_rec.under_return_tolerance,
        X_ITEM_CROSS_REF_PREF                   => x_cust_account_rec.item_cross_ref_pref,
        X_SHIP_SETS_INCLUDE_LINES_FLAG          => x_cust_account_rec.ship_sets_include_lines_flag,
        X_ARRIVALSETS_INCL_LINES_FLAG           => x_cust_account_rec.arrivalsets_include_lines_flag,
        X_SCHED_DATE_PUSH_FLAG                  => x_cust_account_rec.sched_date_push_flag,
        X_INVOICE_QUANTITY_RULE                 => x_cust_account_rec.invoice_quantity_rule,
        X_PRICING_EVENT                         => x_cust_account_rec.pricing_event,
        X_STATUS_UPDATE_DATE                    => x_cust_account_rec.status_update_date,
        X_AUTOPAY_FLAG                          => x_cust_account_rec.autopay_flag,
        X_NOTIFY_FLAG                           => x_cust_account_rec.notify_flag,
        X_LAST_BATCH_ID                         => x_cust_account_rec.last_batch_id,
        X_SELLING_PARTY_ID                      => x_cust_account_rec.selling_party_id,
        X_CREATED_BY_MODULE                     => x_cust_account_rec.created_by_module,
        X_APPLICATION_ID                        => x_cust_account_rec.application_id
    );

    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'HZ_CUST_ACCOUNTS_PKG.Select_Row (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Fetch customer profile id.
    SELECT CUST_ACCOUNT_PROFILE_ID INTO l_cust_account_profile_id
    FROM HZ_CUSTOMER_PROFILES
    WHERE CUST_ACCOUNT_ID = p_cust_account_id
    AND SITE_USE_ID IS NULL;

    HZ_CUSTOMER_PROFILE_V2PUB.get_customer_profile_rec (
        p_cust_account_profile_id               => l_cust_account_profile_id,
        x_customer_profile_rec                  => x_customer_profile_rec,
        x_return_status                         => x_return_status,
        x_msg_count                             => x_msg_count,
        x_msg_data                              => x_msg_data );

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        IF x_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
        ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
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
                 hz_utility_v2pub.debug(p_message=>'get_cust_account_rec (-)',
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
            hz_utility_v2pub.debug(p_message=>'get_cust_account_rec (-)',
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
            hz_utility_v2pub.debug(p_message=>'get_cust_account_rec (-)',
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
            hz_utility_v2pub.debug(p_message=>'get_cust_account_rec (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
        END IF;

        -- Check if API is called in debug mode. If yes, disable debug.
        --disable_debug;

END get_cust_account_rec;

/**
 * PROCEDURE create_cust_acct_relate
 *
 * DESCRIPTION
 *     Creates relationship between two customer accounts.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *     HZ_BUSINESS_EVENT_V2PVT.create_cust_acct_relate_event
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_cust_acct_relate_rec         Customer account relate record.
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
 *   07-23-2001    Jianying Huang      o Created.
 *   08-23-2005    Idris Ali           o Replace the code with a call to overloaded procedure
 *                                       with x_cust_acct_relate_id parameter.
 */

PROCEDURE  create_cust_acct_relate (
    p_init_msg_list                         IN     VARCHAR2 := FND_API.G_FALSE,
    p_cust_acct_relate_rec                  IN     CUST_ACCT_RELATE_REC_TYPE,
    x_return_status                         OUT NOCOPY    VARCHAR2,
    x_msg_count                             OUT NOCOPY    NUMBER,
    x_msg_data                              OUT NOCOPY    VARCHAR2
) IS
  l_cust_acct_relate_id    NUMBER;

BEGIN

    create_cust_acct_relate(p_init_msg_list,p_cust_acct_relate_rec,l_cust_acct_relate_id,x_return_status,x_msg_count,x_msg_data);
END;


/**
 * PROCEDURE create_cust_acct_relate
 *
 * DESCRIPTION
 *     Creates relationship between two customer accounts. Overloaded with
 *     x_cust_acct_relate_id parameter.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *     HZ_BUSINESS_EVENT_V2PVT.create_cust_acct_relate_event
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_cust_acct_relate_rec         Customer account relate record.
 *   IN/OUT:
 *   OUT:
 *     x_cust_acct_relate_id          Return the created records primary key.
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
 *   08-23-2005    Idris Ali       o Created.
 *
 */

PROCEDURE  create_cust_acct_relate (
    p_init_msg_list                         IN     VARCHAR2 := FND_API.G_FALSE,
    p_cust_acct_relate_rec                  IN     CUST_ACCT_RELATE_REC_TYPE,
    x_cust_acct_relate_id                   OUT NOCOPY    NUMBER,
    x_return_status                         OUT NOCOPY    VARCHAR2,
    x_msg_count                             OUT NOCOPY    NUMBER,
    x_msg_data                              OUT NOCOPY    VARCHAR2
) IS

    l_cust_acct_relate_rec                  CUST_ACCT_RELATE_REC_TYPE := p_cust_acct_relate_rec;
    l_debug_prefix                          VARCHAR2(30) := '';
BEGIN

    -- Standard start of API savepoint
    SAVEPOINT create_cust_acct_relate;

    -- Check if API is called in debug mode. If yes, enable debug.
    --enable_debug;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=> 'create_cust_acct_relate (+)',
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
    do_create_cust_acct_relate (
        l_cust_acct_relate_rec,
        x_return_status );

   x_cust_acct_relate_id := l_cust_acct_relate_rec.cust_acct_relate_id;

   IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
     IF(HZ_UTILITY_V2PUB.G_EXECUTE_API_CALLOUTS in ('Y', 'EVENTS_ENABLED')) THEN
       -- Invoke business event system.
       HZ_BUSINESS_EVENT_V2PVT.create_cust_acct_relate_event (
         l_cust_acct_relate_rec );
     END IF;

     IF(HZ_UTILITY_V2PUB.G_EXECUTE_API_CALLOUTS in ('EVENTS_ENABLED', 'BO_EVENTS_ENABLED')) THEN
       -- populate function for integration service
       HZ_POPULATE_BOT_PKG.pop_hz_cust_acct_relate_all(
         p_operation           => 'I',
         p_cust_acct_relate_id => l_cust_acct_relate_rec.cust_acct_relate_id);
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
                 hz_utility_v2pub.debug(p_message=>'create_cust_acct_relate (-)',
                                        p_prefix=>l_debug_prefix,
                                        p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Check if API is called in debug mode. If yes, disable debug.
    --disable_debug;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO create_cust_acct_relate;
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
            hz_utility_v2pub.debug(p_message=>'create_cust_acct_relate (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
        END IF;

        -- Check if API is called in debug mode. If yes, disable debug.
        --disable_debug;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO create_cust_acct_relate;
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
            hz_utility_v2pub.debug(p_message=>'create_cust_acct_relate (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
        END IF;

        -- Check if API is called in debug mode. If yes, disable debug.
        --disable_debug;

    WHEN OTHERS THEN
        ROLLBACK TO create_cust_acct_relate;
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
            hz_utility_v2pub.debug(p_message=> 'create_cust_acct_relate (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
        END IF;

        -- Check if API is called in debug mode. If yes, disable debug.
        --disable_debug;

END create_cust_acct_relate;

/**
 * PROCEDURE update_cust_acct_relate
 *
 * DESCRIPTION
 *     Updates relationship between two customer accounts.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *     HZ_BUSINESS_EVENT_V2PVT.update_cust_acct_relate_event
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_cust_acct_relate_rec         Customer account relate record.
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
 *   04-21-2004    Rajib Ranjan Borah  o Bug 3449118. Passed NULL for parameter p_rowid
 *                                       of get_cust_acct_relate_rec,do_update_cust_acct_relate.
 *   12-MAY-2005   Rajib Ranjan Borah  o TCA SSA Uptake (Bug 3456489)
 *   12-AUG-2005   Idris Ali           o Bug 4529413:modified the call to get_cust_acct_relate_rec
 *
 */

PROCEDURE update_cust_acct_relate (
    p_init_msg_list                         IN     VARCHAR2 := FND_API.G_FALSE,
    p_cust_acct_relate_rec                  IN     CUST_ACCT_RELATE_REC_TYPE,
    p_object_version_number                 IN OUT NOCOPY NUMBER,
    x_return_status                         OUT NOCOPY    VARCHAR2,
    x_msg_count                             OUT NOCOPY    NUMBER,
    x_msg_data                              OUT NOCOPY    VARCHAR2
) IS

    l_cust_acct_relate_rec                  CUST_ACCT_RELATE_REC_TYPE := p_cust_acct_relate_rec;
    l_old_cust_acct_relate_rec              CUST_ACCT_RELATE_REC_TYPE;
    l_debug_prefix                          VARCHAR2(30) := '';
BEGIN

    -- Standard start of API savepoint
    SAVEPOINT update_cust_acct_relate;

    -- Check if API is called in debug mode. If yes, enable debug.
    --enable_debug;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'update_cust_acct_relate (+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Bug 3456489 (Org id is required for identifying correct account relationship record.)
    l_old_cust_acct_relate_rec.org_id := p_cust_acct_relate_rec.org_id;

    --2290537
    get_cust_acct_relate_rec (
       p_cust_account_id          => p_cust_acct_relate_rec.cust_account_id,
       p_related_cust_account_id  => p_cust_acct_relate_rec.related_cust_account_id,
       p_cust_acct_relate_id      => p_cust_acct_relate_rec.cust_acct_relate_id,  -- Bug 4529413
       p_rowid                    => NULL,  -- Bug 3449118
       x_cust_acct_relate_rec     => l_old_cust_acct_relate_rec,
       x_return_status            => x_return_status,
       x_msg_count                => x_msg_count,
       x_msg_data                 => x_msg_data);


    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Call to business logic.
    do_update_cust_acct_relate (
        l_cust_acct_relate_rec,
        p_object_version_number,
        NULL,   /* Bug 3449118 pass NULL for rowid */
        x_return_status );

   IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
     IF(HZ_UTILITY_V2PUB.G_EXECUTE_API_CALLOUTS in ('Y', 'EVENTS_ENABLED')) THEN
       -- Invoke business event system.
       HZ_BUSINESS_EVENT_V2PVT.update_cust_acct_relate_event (
         l_cust_acct_relate_rec , l_old_cust_acct_relate_rec);
     END IF;

     IF(HZ_UTILITY_V2PUB.G_EXECUTE_API_CALLOUTS in ('EVENTS_ENABLED', 'BO_EVENTS_ENABLED')) THEN
       -- populate function for integration service
       HZ_POPULATE_BOT_PKG.pop_hz_cust_acct_relate_all(
         p_operation           => 'U',
         p_cust_acct_relate_id => l_old_cust_acct_relate_rec.cust_acct_relate_id); --bug 8654754. cust_acct_relate_id has no value in relate rec. Old rec got the value from the get API.

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
                 hz_utility_v2pub.debug(p_message=>'update_cust_acct_relate (-)',
                                        p_prefix=>l_debug_prefix,
                                        p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Check if API is called in debug mode. If yes, disable debug.
    --disable_debug;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO update_cust_acct_relate;
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
            hz_utility_v2pub.debug(p_message=>'update_cust_acct_relate (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
        END IF;

        -- Check if API is called in debug mode. If yes, disable debug.
        --disable_debug;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO update_cust_acct_relate;
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
            hz_utility_v2pub.debug(p_message=>'update_cust_acct_relate (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
        END IF;

        -- Check if API is called in debug mode. If yes, disable debug.
        --disable_debug;

    WHEN OTHERS THEN
        ROLLBACK TO update_cust_acct_relate;
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
            hz_utility_v2pub.debug(p_message=>'update_cust_acct_relate (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
        END IF;

        -- Check if API is called in debug mode. If yes, disable debug.
        --disable_debug;

END update_cust_acct_relate;




/**
 * PROCEDURE update_cust_acct_relate
 *
 * DESCRIPTION
 *     Updates relationship between two customer accounts. This is aoverloaded version
 *     of the above procedure and has an extra parameter - p_rowid.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *     HZ_BUSINESS_EVENT_V2PVT.update_cust_acct_relate_event
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_cust_acct_relate_rec         Customer account relate record.
 *     p_rowid                        Rowid of record that the user is trying to update.
 *
 *   IN/OUT:
 *     p_object_version_number        Used for locking the being updated record.
 *
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
 *   04-20-2004   Rajib Ranjan Borah  o Bug 3449118.Created.
 *
 *   12-MAY-2005  Rajib Ranjan Borah  o TCA SSA Uptake (Bug 3456489)
 *   12-AUG-2005  Idris Ali           o Bug 4529413:modified the call to get_cust_acct_relate_rec
 */

PROCEDURE update_cust_acct_relate (
    p_init_msg_list                         IN            VARCHAR2 := FND_API.G_FALSE,
    p_cust_acct_relate_rec                  IN            CUST_ACCT_RELATE_REC_TYPE,
    p_rowid                                 IN            ROWID,
    p_object_version_number                 IN OUT NOCOPY NUMBER,
    x_return_status                         OUT NOCOPY    VARCHAR2,
    x_msg_count                             OUT NOCOPY    NUMBER,
    x_msg_data                              OUT NOCOPY    VARCHAR2
) IS

    l_cust_acct_relate_rec                  CUST_ACCT_RELATE_REC_TYPE := p_cust_acct_relate_rec;
    l_old_cust_acct_relate_rec              CUST_ACCT_RELATE_REC_TYPE;
    l_debug_prefix                          VARCHAR2(30) := '';
BEGIN

    -- Standard start of API savepoint
    SAVEPOINT update_cust_acct_relate;

    -- Check if API is called in debug mode. If yes, enable debug.
    --enable_debug;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'update_cust_acct_relate (+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Bug 3456489. If API is called with NULL for rowid, then we need org_id to identify the record.
    l_old_cust_acct_relate_rec.org_id := p_cust_acct_relate_rec.org_id;

    --2290537
    get_cust_acct_relate_rec (
       p_cust_account_id          => p_cust_acct_relate_rec.cust_account_id,
       p_related_cust_account_id  => p_cust_acct_relate_rec.related_cust_account_id,
       p_cust_acct_relate_id      => p_cust_acct_relate_rec.cust_acct_relate_id,  --Bug 4529413
       p_rowid                    => p_rowid,
       x_cust_acct_relate_rec     => l_old_cust_acct_relate_rec,
       x_return_status            => x_return_status,
       x_msg_count                => x_msg_count,
       x_msg_data                 => x_msg_data);

    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Call to business logic.
    do_update_cust_acct_relate (
        l_cust_acct_relate_rec,
        p_object_version_number,
        p_rowid,
        x_return_status );

   IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
     IF(HZ_UTILITY_V2PUB.G_EXECUTE_API_CALLOUTS in ('Y', 'EVENTS_ENABLED')) THEN
       -- Invoke business event system.
       HZ_BUSINESS_EVENT_V2PVT.update_cust_acct_relate_event (
         l_cust_acct_relate_rec , l_old_cust_acct_relate_rec);
     END IF;

     IF(HZ_UTILITY_V2PUB.G_EXECUTE_API_CALLOUTS in ('EVENTS_ENABLED', 'BO_EVENTS_ENABLED')) THEN
       -- populate function for integration service
       HZ_POPULATE_BOT_PKG.pop_hz_cust_acct_relate_all(
         p_operation           => 'U',
         p_cust_acct_relate_id => l_old_cust_acct_relate_rec.cust_acct_relate_id); --bug 8654754. cust_acct_relate_id has no value in relate rec. Old rec got the value from the get API.

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
                 hz_utility_v2pub.debug(p_message=>'update_cust_acct_relate (-)',
                                        p_prefix=>l_debug_prefix,
                                        p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Check if API is called in debug mode. If yes, disable debug.
    --disable_debug;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO update_cust_acct_relate;
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
            hz_utility_v2pub.debug(p_message=>'update_cust_acct_relate (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
        END IF;

        -- Check if API is called in debug mode. If yes, disable debug.
        --disable_debug;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO update_cust_acct_relate;
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
            hz_utility_v2pub.debug(p_message=>'update_cust_acct_relate (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
        END IF;

        -- Check if API is called in debug mode. If yes, disable debug.
        --disable_debug;

    WHEN OTHERS THEN
        ROLLBACK TO update_cust_acct_relate;
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
            hz_utility_v2pub.debug(p_message=>'update_cust_acct_relate (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
        END IF;

        -- Check if API is called in debug mode. If yes, disable debug.
        --disable_debug;

END update_cust_acct_relate;


/**
 * PROCEDURE get_cust_acct_relate_rec
 *
 * DESCRIPTION
 *      Gets customer account relationship record
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *     HZ_CUST_ACCT_RELATE_PKG.Select_Row
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_cust_account_id              Customer account id.
 *     p_related_cust_account_id      Related customer account id.
 *   IN/OUT:
 *   OUT:
 *     x_cust_acct_relate_rec         Returned customer account relate record.
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
 *   04-21-2004    Rajib Ranjan Borah  o Bug 3449118. Added the parameter p_rowid.
 *                                       Called the overloaded procedure hz_cust_acct_relate_pkg.
 *                                       select_row with rowid as parameter in case rowid
 *                                       is passed to this procedure.
 *   12-MAY-2005   Rajib Ranjan Borah  o TCA SSA Uptake (Bug 3456489)
 *   12-AUG-2005   Idris Ali           o Bug 4529413:Added parameter cust_acct_relate_id to get_cust_acct_relate
 */

PROCEDURE get_cust_acct_relate_rec (
    p_init_msg_list                         IN     VARCHAR2 := FND_API.G_FALSE,
    p_cust_account_id                       IN     NUMBER,
    p_related_cust_account_id               IN     NUMBER,
    p_cust_acct_relate_id                   IN     NUMBER,  -- Bug 4529413
    p_rowid                                 IN     ROWID, -- Bug 3449118
    x_cust_acct_relate_rec                  OUT    NOCOPY CUST_ACCT_RELATE_REC_TYPE,
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
        hz_utility_v2pub.debug(p_message=>'get_cust_acct_relate_rec (+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF p_cust_acct_relate_id IS NULL THEN

     -- Check whether primary key has been passed in.
     IF p_cust_account_id IS NULL OR
        p_cust_account_id = FND_API.G_MISS_NUM THEN
         FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_MISSING_COLUMN' );
         FND_MESSAGE.SET_TOKEN( 'COLUMN', 'cust_account_id' );
         FND_MSG_PUB.ADD;
         RAISE FND_API.G_EXC_ERROR;
     END IF;

     IF p_related_cust_account_id IS NULL OR
        p_related_cust_account_id = FND_API.G_MISS_NUM THEN
         FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_MISSING_COLUMN' );
         FND_MESSAGE.SET_TOKEN( 'COLUMN', 'related_cust_account_id' );
         FND_MSG_PUB.ADD;
         RAISE FND_API.G_EXC_ERROR;
     END IF;
    END IF;

    x_cust_acct_relate_rec.cust_account_id := p_cust_account_id;
    x_cust_acct_relate_rec.related_cust_account_id := p_related_cust_account_id;
    x_cust_acct_relate_rec.cust_acct_relate_id := p_cust_acct_relate_id;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'HZ_CUST_ACCT_RELATE_PKG.Select_Row (+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Call table-handler.
    IF p_rowid IS NULL  /* Bug 3449118 */
    THEN
        HZ_CUST_ACCT_RELATE_PKG.Select_Row (
            X_CUST_ACCOUNT_ID                       => x_cust_acct_relate_rec.cust_account_id,
            X_RELATED_CUST_ACCOUNT_ID               => x_cust_acct_relate_rec.related_cust_account_id,
            X_RELATIONSHIP_TYPE                     => x_cust_acct_relate_rec.relationship_type,
            X_COMMENTS                              => x_cust_acct_relate_rec.comments,
            X_ATTRIBUTE_CATEGORY                    => x_cust_acct_relate_rec.attribute_category,
            X_ATTRIBUTE1                            => x_cust_acct_relate_rec.attribute1,
            X_ATTRIBUTE2                            => x_cust_acct_relate_rec.attribute2,
            X_ATTRIBUTE3                            => x_cust_acct_relate_rec.attribute3,
            X_ATTRIBUTE4                            => x_cust_acct_relate_rec.attribute4,
            X_ATTRIBUTE5                            => x_cust_acct_relate_rec.attribute5,
            X_ATTRIBUTE6                            => x_cust_acct_relate_rec.attribute6,
            X_ATTRIBUTE7                            => x_cust_acct_relate_rec.attribute7,
            X_ATTRIBUTE8                            => x_cust_acct_relate_rec.attribute8,
            X_ATTRIBUTE9                            => x_cust_acct_relate_rec.attribute9,
            X_ATTRIBUTE10                           => x_cust_acct_relate_rec.attribute10,
            X_CUSTOMER_RECIPROCAL_FLAG              => x_cust_acct_relate_rec.customer_reciprocal_flag,
            X_STATUS                                => x_cust_acct_relate_rec.status,
            X_ATTRIBUTE11                           => x_cust_acct_relate_rec.attribute11,
            X_ATTRIBUTE12                           => x_cust_acct_relate_rec.attribute12,
            X_ATTRIBUTE13                           => x_cust_acct_relate_rec.attribute13,
            X_ATTRIBUTE14                           => x_cust_acct_relate_rec.attribute14,
            X_ATTRIBUTE15                           => x_cust_acct_relate_rec.attribute15,
            X_BILL_TO_FLAG                          => x_cust_acct_relate_rec.bill_to_flag,
            X_SHIP_TO_FLAG                          => x_cust_acct_relate_rec.ship_to_flag,
            X_CREATED_BY_MODULE                     => x_cust_acct_relate_rec.created_by_module,
            X_APPLICATION_ID                        => x_cust_acct_relate_rec.application_id,
            X_ORG_ID                                => x_cust_acct_relate_rec.org_id,  -- Bug 3456489
            X_CUST_ACCT_RELATE_ID                   => x_cust_acct_relate_rec.cust_acct_relate_id -- Bug 4529413
        );

    ELSE

        HZ_CUST_ACCT_RELATE_PKG.Select_Row (
            X_CUST_ACCOUNT_ID                       => x_cust_acct_relate_rec.cust_account_id,
            X_RELATED_CUST_ACCOUNT_ID               => x_cust_acct_relate_rec.related_cust_account_id,
            X_RELATIONSHIP_TYPE                     => x_cust_acct_relate_rec.relationship_type,
            X_COMMENTS                              => x_cust_acct_relate_rec.comments,
            X_ATTRIBUTE_CATEGORY                    => x_cust_acct_relate_rec.attribute_category,
            X_ATTRIBUTE1                            => x_cust_acct_relate_rec.attribute1,
            X_ATTRIBUTE2                            => x_cust_acct_relate_rec.attribute2,
            X_ATTRIBUTE3                            => x_cust_acct_relate_rec.attribute3,
            X_ATTRIBUTE4                            => x_cust_acct_relate_rec.attribute4,
            X_ATTRIBUTE5                            => x_cust_acct_relate_rec.attribute5,
            X_ATTRIBUTE6                            => x_cust_acct_relate_rec.attribute6,
            X_ATTRIBUTE7                            => x_cust_acct_relate_rec.attribute7,
            X_ATTRIBUTE8                            => x_cust_acct_relate_rec.attribute8,
            X_ATTRIBUTE9                            => x_cust_acct_relate_rec.attribute9,
            X_ATTRIBUTE10                           => x_cust_acct_relate_rec.attribute10,
            X_CUSTOMER_RECIPROCAL_FLAG              => x_cust_acct_relate_rec.customer_reciprocal_flag,
            X_STATUS                                => x_cust_acct_relate_rec.status,
            X_ATTRIBUTE11                           => x_cust_acct_relate_rec.attribute11,
            X_ATTRIBUTE12                           => x_cust_acct_relate_rec.attribute12,
            X_ATTRIBUTE13                           => x_cust_acct_relate_rec.attribute13,
            X_ATTRIBUTE14                           => x_cust_acct_relate_rec.attribute14,
            X_ATTRIBUTE15                           => x_cust_acct_relate_rec.attribute15,
            X_BILL_TO_FLAG                          => x_cust_acct_relate_rec.bill_to_flag,
            X_SHIP_TO_FLAG                          => x_cust_acct_relate_rec.ship_to_flag,
            X_CREATED_BY_MODULE                     => x_cust_acct_relate_rec.created_by_module,
            X_APPLICATION_ID                        => x_cust_acct_relate_rec.application_id,
            X_ORG_ID                                => x_cust_acct_relate_rec.org_id,  -- Bug 3456489
            X_CUST_ACCT_RELATE_ID                   => x_cust_acct_relate_rec.cust_acct_relate_id, -- Bug 4529413
            X_ROWID                                 => p_rowid
        );
    END IF;


    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'HZ_CUST_ACCT_RELATE_PKG.Select_Row (-)',
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
                 hz_utility_v2pub.debug(p_message=>'get_cust_acct_relate_rec (-)',
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
            hz_utility_v2pub.debug(p_message=>'get_cust_acct_relate_rec (-)',
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
            hz_utility_v2pub.debug(p_message=>'get_cust_acct_relate_rec (-)',
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
            hz_utility_v2pub.debug(p_message=>'get_cust_acct_relate_rec (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
        END IF;

        -- Check if API is called in debug mode. If yes, disable debug.
        --disable_debug;

END get_cust_acct_relate_rec;

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
 *   06-DEC-2005   Sagar Vemuri        o Bug 4713150: Removed tax_code from
 *                                       obsolete columns list.
 *
 */

PROCEDURE check_obsolete_columns (
    p_create_update_flag          IN     VARCHAR2,
    p_cust_account_rec            IN     cust_account_rec_type,
    p_old_cust_account_rec        IN     cust_account_rec_type DEFAULT NULL,
    x_return_status               IN OUT NOCOPY VARCHAR2
) IS

BEGIN

    -- check account_activation_date
    IF (p_create_update_flag = 'C' AND
        p_cust_account_rec.account_activation_date IS NOT NULL AND
        p_cust_account_rec.account_activation_date <> FND_API.G_MISS_DATE) OR
       (p_create_update_flag = 'U' AND
        p_cust_account_rec.account_activation_date IS NOT NULL AND
        p_cust_account_rec.account_activation_date <> p_old_cust_account_rec.account_activation_date)
    THEN
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_OBSOLETE_COLUMN');
        FND_MESSAGE.SET_TOKEN('COLUMN', 'account_activation_date');
        FND_MSG_PUB.ADD;
        x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

    -- check account_liable_flag
    IF (p_create_update_flag = 'C' AND
        p_cust_account_rec.account_liable_flag IS NOT NULL AND
        p_cust_account_rec.account_liable_flag <> FND_API.G_MISS_CHAR) OR
       (p_create_update_flag = 'U' AND
        p_cust_account_rec.account_liable_flag IS NOT NULL AND
        p_cust_account_rec.account_liable_flag <> p_old_cust_account_rec.account_liable_flag)
    THEN
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_OBSOLETE_COLUMN');
        FND_MESSAGE.SET_TOKEN('COLUMN', 'account_liable_flag');
        FND_MSG_PUB.ADD;
        x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

    -- check account_termination_date
    IF (p_create_update_flag = 'C' AND
        p_cust_account_rec.account_termination_date IS NOT NULL AND
        p_cust_account_rec.account_termination_date <> FND_API.G_MISS_DATE) OR
       (p_create_update_flag = 'U' AND
        p_cust_account_rec.account_termination_date IS NOT NULL AND
        p_cust_account_rec.account_termination_date <> p_old_cust_account_rec.account_termination_date)
    THEN
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_OBSOLETE_COLUMN');
        FND_MESSAGE.SET_TOKEN('COLUMN', 'account_termination_date');
        FND_MSG_PUB.ADD;
        x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

    -- check acct_life_cycle_status
    IF (p_create_update_flag = 'C' AND
        p_cust_account_rec.acct_life_cycle_status IS NOT NULL AND
        p_cust_account_rec.acct_life_cycle_status <> FND_API.G_MISS_CHAR) OR
       (p_create_update_flag = 'U' AND
        p_cust_account_rec.acct_life_cycle_status IS NOT NULL AND
        p_cust_account_rec.acct_life_cycle_status <> p_old_cust_account_rec.acct_life_cycle_status)
    THEN
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_OBSOLETE_COLUMN');
        FND_MESSAGE.SET_TOKEN('COLUMN', 'acct_life_cycle_status');
        FND_MSG_PUB.ADD;
        x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

    -- check current_balance
    IF (p_create_update_flag = 'C' AND
        p_cust_account_rec.current_balance IS NOT NULL AND
        p_cust_account_rec.current_balance <> FND_API.G_MISS_NUM) OR
       (p_create_update_flag = 'U' AND
        p_cust_account_rec.current_balance IS NOT NULL AND
        p_cust_account_rec.current_balance <> p_old_cust_account_rec.current_balance)
    THEN
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_OBSOLETE_COLUMN');
        FND_MESSAGE.SET_TOKEN('COLUMN', 'current_balance');
        FND_MSG_PUB.ADD;
        x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

    -- check department
    IF (p_create_update_flag = 'C' AND
        p_cust_account_rec.department IS NOT NULL AND
        p_cust_account_rec.department <> FND_API.G_MISS_CHAR) OR
       (p_create_update_flag = 'U' AND
        p_cust_account_rec.department IS NOT NULL AND
        p_cust_account_rec.department <> p_old_cust_account_rec.department)
    THEN
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_OBSOLETE_COLUMN');
        FND_MESSAGE.SET_TOKEN('COLUMN', 'department');
        FND_MSG_PUB.ADD;
        x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

    -- check dormant_account_flag
    IF (p_create_update_flag = 'C' AND
        p_cust_account_rec.dormant_account_flag IS NOT NULL AND
        p_cust_account_rec.dormant_account_flag <> FND_API.G_MISS_CHAR) OR
       (p_create_update_flag = 'U' AND
        p_cust_account_rec.dormant_account_flag IS NOT NULL AND
        p_cust_account_rec.dormant_account_flag <> p_old_cust_account_rec.dormant_account_flag)
    THEN
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_OBSOLETE_COLUMN');
        FND_MESSAGE.SET_TOKEN('COLUMN', 'dormant_account_flag');
        FND_MSG_PUB.ADD;
        x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

    -- check notify_flag
    IF (p_create_update_flag = 'C' AND
        p_cust_account_rec.notify_flag IS NOT NULL AND
        p_cust_account_rec.notify_flag <> FND_API.G_MISS_CHAR) OR
       (p_create_update_flag = 'U' AND
        p_cust_account_rec.notify_flag IS NOT NULL AND
        p_cust_account_rec.notify_flag <> p_old_cust_account_rec.notify_flag)
    THEN
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_OBSOLETE_COLUMN');
        FND_MESSAGE.SET_TOKEN('COLUMN', 'notify_flag');
        FND_MSG_PUB.ADD;
        x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

    -- check order_type_id
    IF (p_create_update_flag = 'C' AND
        p_cust_account_rec.order_type_id IS NOT NULL AND
        p_cust_account_rec.order_type_id <> FND_API.G_MISS_NUM) OR
       (p_create_update_flag = 'U' AND
        p_cust_account_rec.order_type_id IS NOT NULL AND
        p_cust_account_rec.order_type_id <> p_old_cust_account_rec.order_type_id)
    THEN
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_OBSOLETE_COLUMN');
        FND_MESSAGE.SET_TOKEN('COLUMN', 'order_type_id');
        FND_MSG_PUB.ADD;
        x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

    -- check primary_salesrep_id
    IF (p_create_update_flag = 'C' AND
        p_cust_account_rec.primary_salesrep_id IS NOT NULL AND
        p_cust_account_rec.primary_salesrep_id <> FND_API.G_MISS_NUM) OR
       (p_create_update_flag = 'U' AND
        p_cust_account_rec.primary_salesrep_id IS NOT NULL AND
        p_cust_account_rec.primary_salesrep_id <> p_old_cust_account_rec.primary_salesrep_id)
    THEN
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_OBSOLETE_COLUMN');
        FND_MESSAGE.SET_TOKEN('COLUMN', 'primary_salesrep_id');
        FND_MSG_PUB.ADD;
        x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

    -- check realtime_rate_flag
    IF (p_create_update_flag = 'C' AND
        p_cust_account_rec.realtime_rate_flag IS NOT NULL AND
        p_cust_account_rec.realtime_rate_flag <> FND_API.G_MISS_CHAR) OR
       (p_create_update_flag = 'U' AND
        p_cust_account_rec.realtime_rate_flag IS NOT NULL AND
        p_cust_account_rec.realtime_rate_flag <> p_old_cust_account_rec.realtime_rate_flag)
    THEN
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_OBSOLETE_COLUMN');
        FND_MESSAGE.SET_TOKEN('COLUMN', 'realtime_rate_flag');
        FND_MSG_PUB.ADD;
        x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

    -- check suspension_date
    IF (p_create_update_flag = 'C' AND
        p_cust_account_rec.suspension_date IS NOT NULL AND
        p_cust_account_rec.suspension_date <> FND_API.G_MISS_DATE) OR
       (p_create_update_flag = 'U' AND
        p_cust_account_rec.suspension_date IS NOT NULL AND
        p_cust_account_rec.suspension_date <> p_old_cust_account_rec.suspension_date)
    THEN
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_OBSOLETE_COLUMN');
        FND_MESSAGE.SET_TOKEN('COLUMN', 'suspension_date');
        FND_MSG_PUB.ADD;
        x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

    -- check tax_code
    -- Bug 4713150
/*    IF (p_create_update_flag = 'C' AND
        p_cust_account_rec.tax_code IS NOT NULL AND
        p_cust_account_rec.tax_code <> FND_API.G_MISS_CHAR) OR
       (p_create_update_flag = 'U' AND
        p_cust_account_rec.tax_code IS NOT NULL AND
        p_cust_account_rec.tax_code <> p_old_cust_account_rec.tax_code)
    THEN
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_OBSOLETE_COLUMN');
        FND_MESSAGE.SET_TOKEN('COLUMN', 'tax_code');
        FND_MSG_PUB.ADD;
        x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;
*/
END check_obsolete_columns;

END HZ_CUST_ACCOUNT_V2PUB;

/
