--------------------------------------------------------
--  DDL for Package HZ_CUST_ACCOUNT_V2PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_CUST_ACCOUNT_V2PUB" AUTHID CURRENT_USER AS
/*$Header: ARH2CASS.pls 120.12 2006/08/17 10:16:40 idali ship $ */
/*#
 * This package contains the public APIs for customer accounts and related entities.
 * @rep:scope public
 * @rep:product HZ
 * @rep:displayname  Customer Account
 * @rep:category BUSINESS_ENTITY HZ_CUSTOMER_ACCOUNT
 * @rep:category BUSINESS_ENTITY HZ_ORGANIZATION
 * @rep:category BUSINESS_ENTITY HZ_PERSON
 * @rep:lifecycle active
 * @rep:doccd 120hztig.pdf Customer Account APIs,  Oracle Trading Community Architecture Technical Implementation Guide
 */

--------------------------------------
-- declaration of record type
--------------------------------------

TYPE cust_account_rec_type IS RECORD (
    cust_account_id                         NUMBER,
    account_number                          VARCHAR2(30),
    attribute_category                      VARCHAR2(30),
    attribute1                              VARCHAR2(150),
    attribute2                              VARCHAR2(150),
    attribute3                              VARCHAR2(150),
    attribute4                              VARCHAR2(150),
    attribute5                              VARCHAR2(150),
    attribute6                              VARCHAR2(150),
    attribute7                              VARCHAR2(150),
    attribute8                              VARCHAR2(150),
    attribute9                              VARCHAR2(150),
    attribute10                             VARCHAR2(150),
    attribute11                             VARCHAR2(150),
    attribute12                             VARCHAR2(150),
    attribute13                             VARCHAR2(150),
    attribute14                             VARCHAR2(150),
    attribute15                             VARCHAR2(150),
    attribute16                             VARCHAR2(150),
    attribute17                             VARCHAR2(150),
    attribute18                             VARCHAR2(150),
    attribute19                             VARCHAR2(150),
    attribute20                             VARCHAR2(150),
    global_attribute_category               VARCHAR2(30),
    global_attribute1                       VARCHAR2(150),
    global_attribute2                       VARCHAR2(150),
    global_attribute3                       VARCHAR2(150),
    global_attribute4                       VARCHAR2(150),
    global_attribute5                       VARCHAR2(150),
    global_attribute6                       VARCHAR2(150),
    global_attribute7                       VARCHAR2(150),
    global_attribute8                       VARCHAR2(150),
    global_attribute9                       VARCHAR2(150),
    global_attribute10                      VARCHAR2(150),
    global_attribute11                      VARCHAR2(150),
    global_attribute12                      VARCHAR2(150),
    global_attribute13                      VARCHAR2(150),
    global_attribute14                      VARCHAR2(150),
    global_attribute15                      VARCHAR2(150),
    global_attribute16                      VARCHAR2(150),
    global_attribute17                      VARCHAR2(150),
    global_attribute18                      VARCHAR2(150),
    global_attribute19                      VARCHAR2(150),
    global_attribute20                      VARCHAR2(150),
    orig_system_reference                   VARCHAR2(240),
    orig_system                             VARCHAR2(30),
    status                                  VARCHAR2(1),
    customer_type                           VARCHAR2(30),
    customer_class_code                     VARCHAR2(30),
    primary_salesrep_id                     NUMBER,
    sales_channel_code                      VARCHAR2(30),
    order_type_id                           NUMBER,
    price_list_id                           NUMBER,
    tax_code                                VARCHAR2(50),
    fob_point                               VARCHAR2(30),
    freight_term                            VARCHAR2(30),
    ship_partial                            VARCHAR2(1),
    ship_via                                VARCHAR2(30),
    warehouse_id                            NUMBER,
    tax_header_level_flag                   VARCHAR2(1),
    tax_rounding_rule                       VARCHAR2(30),
    coterminate_day_month                   VARCHAR2(6),
    primary_specialist_id                   NUMBER,
    secondary_specialist_id                 NUMBER,
    account_liable_flag                     VARCHAR2(1),
    current_balance                         NUMBER,
    account_established_date                DATE,
    account_termination_date                DATE,
    account_activation_date                 DATE,
    department                              VARCHAR2(30),
    held_bill_expiration_date               DATE,
    hold_bill_flag                          VARCHAR2(1),
    realtime_rate_flag                      VARCHAR2(1),
    acct_life_cycle_status                  VARCHAR2(30),
    account_name                            VARCHAR2(240),
    deposit_refund_method                   VARCHAR2(20),
    dormant_account_flag                    VARCHAR2(1),
    npa_number                              VARCHAR2(60),
    suspension_date                         DATE,
    source_code                             VARCHAR2(150),
    comments                                VARCHAR2(240),
    dates_negative_tolerance                NUMBER,
    dates_positive_tolerance                NUMBER,
    date_type_preference                    VARCHAR2(20),
    over_shipment_tolerance                 NUMBER,
    under_shipment_tolerance                NUMBER,
    over_return_tolerance                   NUMBER,
    under_return_tolerance                  NUMBER,
    item_cross_ref_pref                     VARCHAR2(30),
    ship_sets_include_lines_flag            VARCHAR2(1),
    arrivalsets_include_lines_flag          VARCHAR2(1),
    sched_date_push_flag                    VARCHAR2(1),
    invoice_quantity_rule                   VARCHAR2(30),
    pricing_event                           VARCHAR2(30),
    status_update_date                      DATE,
    autopay_flag                            VARCHAR2(1),
    notify_flag                             VARCHAR2(1),
    last_batch_id                           NUMBER,
    selling_party_id                        NUMBER,
    created_by_module                       VARCHAR2(150),
    application_id                          NUMBER
);

TYPE cust_acct_relate_rec_type IS RECORD (
    cust_account_id                         NUMBER,
    related_cust_account_id                 NUMBER,
    relationship_type                       VARCHAR2(30),
    comments                                VARCHAR2(240),
    attribute_category                      VARCHAR2(30),
    attribute1                              VARCHAR2(150),
    attribute2                              VARCHAR2(150),
    attribute3                              VARCHAR2(150),
    attribute4                              VARCHAR2(150),
    attribute5                              VARCHAR2(150),
    attribute6                              VARCHAR2(150),
    attribute7                              VARCHAR2(150),
    attribute8                              VARCHAR2(150),
    attribute9                              VARCHAR2(150),
    attribute10                             VARCHAR2(150),
    customer_reciprocal_flag                VARCHAR2(1),
    status                                  VARCHAR2(1),
    attribute11                             VARCHAR2(150),
    attribute12                             VARCHAR2(150),
    attribute13                             VARCHAR2(150),
    attribute14                             VARCHAR2(150),
    attribute15                             VARCHAR2(150),
    bill_to_flag                            VARCHAR2(1),
    ship_to_flag                            VARCHAR2(1),
    created_by_module                       VARCHAR2(150),
    application_id                          NUMBER,
    org_id                                  NUMBER,  /* Bug 3456489 */
    cust_acct_relate_id                     NUMBER   -- Bug 4529413
);

--------------------------------------
-- declaration of public procedures and functions
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
/*#
 * Use this routine to create a customer account. The API creates records in the
 * HZ_CUST_ACCOUNTS table for the Person party type. You can create a customer account for
 * an existing party by passing the party_id value of the party. Alternatively, this
 * routine creates a new party and an account for that party. You can also create a
 * customer profile record in the HZ_CUSTOMER_PROFILES table, while calling this routine
 * based on value passed in p_customer_profile_rec. This routine is overloaded for Person
 * and Organization. If an orig_system_reference is passed in, then the API creates a
 * record in the HZ_ORIG_SYS_REFERENCES table to store the mapping between the source
 * system reference and the TCA primary key. If orig_system_reference is not passed in,
 * then the default is UNKNOWN.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Customer Account  (For Person party)
 * @rep:businessevent oracle.apps.ar.hz.CustAccount.create
 * @rep:doccd 120hztig.pdf Customer Account APIs,  Oracle Trading Community Architecture Technical Implementation Guide
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
);

/**
 * PROCEDURE create_cust_account
 *
 * DESCRIPTION
 *     Creates customer account for organization party.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *     HZ_PARTY_V2PUB.create_organization
 *     HZ_CUSTOMER_PROFILE_V2PUB.create_customer_profile
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
/*#
 * Use this routine to create a customer account. This API creates records in the
 * HZ_CUST_ACCOUNTS table for the Organization party type. You can create an account for
 * an existing party by passing party_id of the party. Alternatively, you can use this
 * routine to create a new party and an account for that party. You can also create a
 * customer profile record in the HZ_CUSTOMER_PROFILES table, while calling this routine
 * based on the value passed in p_customer_profile_rec. This routine is overloaded for
 * Person and Organization. If an orig_system_reference is passed in, then the API creates
 * a record in the HZ_ORIG_SYS_REFERENCES table to store the mapping between the source
 * system reference and the TCA primary key. If orig_system_reference is not passed in,
 * then the default is UNKNOWN.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Customer Account  (For Organization party)
 * @rep:businessevent oracle.apps.ar.hz.CustAccount.create
 * @rep:doccd 120hztig.pdf Customer Account APIs,  Oracle Trading Community Architecture Technical Implementation Guide
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
);

/**
 * PROCEDURE update_cust_account
 *
 * DESCRIPTION
 *     Updates customer account.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
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
/*#
 * Use this routine to update a customer account. This API updates records in the
 * HZ_CUST_ACCOUNTS table. The customer account can belong to a party of type
 * Person or Organization. The same routine updates all types of accounts,
 * whether the account belongs to a person or an organization. If the primary key is not
 * passed in, then get the primary key from the HZ_ORIG_SYS_REFERENCES table, based on
 * orig_system and orig_system_reference. Note: orig_system and orig_system_reference must
 * be unique and not null and unique.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update Customer Account
 * @rep:businessevent oracle.apps.ar.hz.CustAccount.update
 * @rep:doccd 120hztig.pdf Customer Account APIs,  Oracle Trading Community Architecture Technical Implementation Guide
 */
PROCEDURE update_cust_account (
    p_init_msg_list                         IN     VARCHAR2 := FND_API.G_FALSE,
    p_cust_account_rec                      IN     CUST_ACCOUNT_REC_TYPE,
    p_object_version_number                 IN OUT NOCOPY NUMBER,
    x_return_status                         OUT NOCOPY    VARCHAR2,
    x_msg_count                             OUT NOCOPY    NUMBER,
    x_msg_data                              OUT NOCOPY    VARCHAR2
);

/**
 * PROCEDURE get_cust_account_rec
 *
 * DESCRIPTION
 *      Gets customer account record
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
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
);

/**
 * PROCEDURE create_cust_acct_relate ( signature 1)
 *
 * DESCRIPTION
 *     Creates relationship between two customer accounts.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
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
 *
 */
/*#
 * Use this routine to create a customer account relationship. This API creates records in
 * the HZ_CUST_ACCT_RELATE table. You can use this process to relate two different
 * customer accounts. Use the Relationship APIs to create relationships between parties.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Customer Account Relationship
 * @rep:businessevent oracle.apps.ar.hz.CustAcctRelate.create
 * @rep:doccd 120hztig.pdf Customer Account APIs,  Oracle Trading Community Architecture Technical Implementation Guide
 */
PROCEDURE create_cust_acct_relate (
    p_init_msg_list                         IN     VARCHAR2 := FND_API.G_FALSE,
    p_cust_acct_relate_rec                  IN     CUST_ACCT_RELATE_REC_TYPE,
    x_return_status                         OUT NOCOPY    VARCHAR2,
    x_msg_count                             OUT NOCOPY    NUMBER,
    x_msg_data                              OUT NOCOPY    VARCHAR2
);



/**
 * PROCEDURE create_cust_acct_relate ( signature 2)
 *
 * DESCRIPTION
 *     Creates relationship between two customer accounts.Overloaded with
 *     x_cust_acct_relate_id parameter.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_cust_acct_relate_rec         Customer account relate record.
 *   IN/OUT:
 *   OUT:
 *     x_cust_acct_relate_id          Return primary key after creation of record.
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
 *   08-23-2005    Idris Ali        o Created.
 *
 */
/*#
 * Use this routine to create a customer account relationship. This API creates records in
 * the HZ_CUST_ACCT_RELATE table. You can use this process to relate two different
 * customer accounts. Use the Relationship APIs to create relationships between parties.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Customer Account Relationship
 * @rep:businessevent oracle.apps.ar.hz.CustAcctRelate.create
 * @rep:doccd 120hztig.pdf Customer Account APIs,  Oracle Trading Community Architecture Technical Implementation Guide
 */
PROCEDURE create_cust_acct_relate (
    p_init_msg_list                         IN     VARCHAR2 := FND_API.G_FALSE,
    p_cust_acct_relate_rec                  IN     CUST_ACCT_RELATE_REC_TYPE,
    x_cust_acct_relate_id                   OUT NOCOPY    NUMBER,
    x_return_status                         OUT NOCOPY    VARCHAR2,
    x_msg_count                             OUT NOCOPY    NUMBER,
    x_msg_data                              OUT NOCOPY    VARCHAR2
);


/**
 * PROCEDURE update_cust_acct_relate (signature 1.)
 *
 * DESCRIPTION
 *     Updates relationship between two customer accounts.This will update the active
 *  record between the two customer accounts specified. To update an  inactive record
 *  use the overloaded procedure update_cust_acct_relate which accepts rowid as
 *  parameter.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
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
 *
 */
/*#
 * Use this routine to update a customer account relationship. This API updates records
 * in the HZ_CUST_ACCT_RELATE table.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update Customer Account Relationship
 * @rep:businessevent oracle.apps.ar.hz.CustAcctRelate.update
 * @rep:doccd 120hztig.pdf Customer Account APIs,  Oracle Trading Community Architecture Technical Implementation Guide
 */
PROCEDURE update_cust_acct_relate (
    p_init_msg_list                         IN     VARCHAR2 := FND_API.G_FALSE,
    p_cust_acct_relate_rec                  IN     CUST_ACCT_RELATE_REC_TYPE,
    p_object_version_number                 IN OUT NOCOPY NUMBER,
    x_return_status                         OUT NOCOPY    VARCHAR2,
    x_msg_count                             OUT NOCOPY    NUMBER,
    x_msg_data                              OUT NOCOPY    VARCHAR2
);



/**
 * PROCEDURE update_cust_acct_relate (signature 2.)
 *
 * DESCRIPTION
 *     Updates relationship between two customer accounts. This is the overloaded procedure
 *  which accepts the rowid of the record in HZ_CUST_ACCT_RELATE as a parameter.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *
 *      p_init_msg_list                Initialize message stack if it is set to
 *                                     FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *
 *      p_cust_acct_relate_rec         Customer account relate record.
 *
 *      p_rowid                        Rowid of record in HZ_CUST_ACCT_RELATE.
 *
 *   IN/OUT:
 *
 *      p_object_version_number        Used for locking the being updated record.
 *
 *   OUT:
 *
 *      x_return_status                Return status after the call. The status can
 *                                     be FND_API.G_RET_STS_SUCCESS (success),
 *                                     FND_API.G_RET_STS_ERROR (error),
 *                                     FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
 *
 *      x_msg_count                    Number of messages in message stack.
 *
 *      x_msg_data                     Message text if x_msg_count is 1.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   04-21-2004    Rajib Ranjan Borah      o Bug 3449118. Created.
 */

PROCEDURE update_cust_acct_relate (
    p_init_msg_list                         IN            VARCHAR2 := FND_API.G_FALSE,
    p_cust_acct_relate_rec                  IN            CUST_ACCT_RELATE_REC_TYPE,
    p_rowid                                 IN            ROWID,
    p_object_version_number                 IN OUT NOCOPY NUMBER,
    x_return_status                         OUT NOCOPY    VARCHAR2,
    x_msg_count                             OUT NOCOPY    NUMBER,
    x_msg_data                              OUT NOCOPY    VARCHAR2
);


/**
 * PROCEDURE get_cust_acct_relate_rec
 *
 * DESCRIPTION
 *      Gets customer account relationship record
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_cust_account_id              Customer account id.
 *     p_related_cust_account_id      Related customer account id.
 *     p_cust_acct_relate_id          Customer account relate id.
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
 *   04-20-2004    Rajib Ranjan Borah  o Bug 3449118. Added rowid as parameter.
 *   08-12-2004    Idris Ali           o Bug 4529413. Added p_cust_acct_relate_id parameter
 */

PROCEDURE get_cust_acct_relate_rec (
    p_init_msg_list                         IN     VARCHAR2 := FND_API.G_FALSE,
    p_cust_account_id                       IN     NUMBER,
    p_related_cust_account_id               IN     NUMBER,
    p_cust_acct_relate_id                   IN     NUMBER,   -- Bug 4529413
    p_rowid                                 IN     ROWID,
    x_cust_acct_relate_rec                  OUT    NOCOPY CUST_ACCT_RELATE_REC_TYPE,
    x_return_status                         OUT NOCOPY    VARCHAR2,
    x_msg_count                             OUT NOCOPY    NUMBER,
    x_msg_data                              OUT NOCOPY    VARCHAR2
);

END HZ_CUST_ACCOUNT_V2PUB;

 

/
