--------------------------------------------------------
--  DDL for Package HZ_CUST_ACCOUNT_SITE_V2PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_CUST_ACCOUNT_SITE_V2PUB" AUTHID CURRENT_USER AS
/*$Header: ARH2CSSS.pls 120.10 2006/08/17 10:16:59 idali ship $ */
/*#
 * This package contains the public APIs for customer account sites and site uses.
 * @rep:scope public
 * @rep:product HZ
 * @rep:displayname Customer Account Site
 * @rep:category BUSINESS_ENTITY HZ_ADDRESS
 * @rep:lifecycle active
 * @rep:doccd 120hztig.pdf Customer Account Site APIs,  Oracle Trading Community Architecture Technical Implementation Guide
 */


--------------------------------------
-- declaration of record type
--------------------------------------

TYPE cust_acct_site_rec_type IS RECORD (
    cust_acct_site_id                       NUMBER,
    cust_account_id                         NUMBER,
    party_site_id                           NUMBER,
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
    customer_category_code                  VARCHAR2(30),
    language                                VARCHAR2(4),
    key_account_flag                        VARCHAR2(1),
    tp_header_id                            NUMBER,
    ece_tp_location_code                    VARCHAR2(40),
    primary_specialist_id                   NUMBER,
    secondary_specialist_id                 NUMBER,
    territory_id                            NUMBER,
    territory                               VARCHAR2(30),
    translated_customer_name                VARCHAR2(50),
    created_by_module                       VARCHAR2(150),
    application_id                          NUMBER,
    org_id                                  NUMBER /* Bug 3456489 */
);

TYPE cust_site_use_rec_type IS RECORD (
    site_use_id                             NUMBER,
    cust_acct_site_id                       NUMBER,
    site_use_code                           VARCHAR2(30),
    primary_flag                            VARCHAR2(1),
    status                                  VARCHAR2(1),
    location                                VARCHAR2(40),
    contact_id                              NUMBER,
    bill_to_site_use_id                     NUMBER,
    orig_system_reference                   VARCHAR2(240),
    orig_system                             VARCHAR2(30),
    sic_code                                VARCHAR2(30),
    payment_term_id                         NUMBER,
    gsa_indicator                           VARCHAR2(1),
    ship_partial                            VARCHAR2(1),
    ship_via                                VARCHAR2(30),
    fob_point                               VARCHAR2(30),
    order_type_id                           NUMBER,
    price_list_id                           NUMBER,
    freight_term                            VARCHAR2(30),
    warehouse_id                            NUMBER,
    territory_id                            NUMBER,
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
    tax_reference                           VARCHAR2(50),
    sort_priority                           NUMBER,
    tax_code                                VARCHAR2(50),
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
    attribute21                             VARCHAR2(150),
    attribute22                             VARCHAR2(150),
    attribute23                             VARCHAR2(150),
    attribute24                             VARCHAR2(150),
    attribute25                             VARCHAR2(150),
    demand_class_code                       VARCHAR2(30),
    tax_header_level_flag                   VARCHAR2(1),
    tax_rounding_rule                       VARCHAR2(30),
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
    global_attribute_category               VARCHAR2(30),
    primary_salesrep_id                     NUMBER,
    finchrg_receivables_trx_id              NUMBER,
    dates_negative_tolerance                NUMBER,
    dates_positive_tolerance                NUMBER,
    date_type_preference                    VARCHAR2(20),
    over_shipment_tolerance                 NUMBER,
    under_shipment_tolerance                NUMBER,
    item_cross_ref_pref                     VARCHAR2(30),
    over_return_tolerance                   NUMBER,
    under_return_tolerance                  NUMBER,
    ship_sets_include_lines_flag            VARCHAR2(1),
    arrivalsets_include_lines_flag          VARCHAR2(1),
    sched_date_push_flag                    VARCHAR2(1),
    invoice_quantity_rule                   VARCHAR2(30),
    pricing_event                           VARCHAR2(30),
    gl_id_rec                               NUMBER,
    gl_id_rev                               NUMBER,
    gl_id_tax                               NUMBER,
    gl_id_freight                           NUMBER,
    gl_id_clearing                          NUMBER,
    gl_id_unbilled                          NUMBER,
    gl_id_unearned                          NUMBER,
    gl_id_unpaid_rec                        NUMBER,
    gl_id_remittance                        NUMBER,
    gl_id_factor                            NUMBER,
    tax_classification                      VARCHAR2(30),
    created_by_module                       VARCHAR2(150),
    application_id                          NUMBER,
    org_id                                  NUMBER   /* Bug 3456489 */
);

--------------------------------------
-- declaration of public procedures and functions
--------------------------------------

/**
 * PROCEDURE create_cust_acct_site
 *
 * DESCRIPTION
 *     Creates customer account site.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
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

/*#
 * Use this routine to create a customer account site. This API creates records in the
 * HZ_CUST_ACCT_SITES table. The API creates the customer account site using an existing
 * customer account and an existing party site. If an orig_system_reference is passed in,
 * then the API creates a record in the HZ_ORIG_SYS_REFERENCES table to store the mapping
 * between the source system reference and the TCA primary key. If orig_system_reference
 * is not passed in, then the default is UNKNOWN.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Customer Account Site
 * @rep:businessevent oracle.apps.ar.hz.CustAcctSite.create
 * @rep:doccd 120hztig.pdf Customer Account Site APIs, Oracle Trading Community Architecture Technical Implementation Guide
 */
 PROCEDURE create_cust_acct_site (
    p_init_msg_list                         IN     VARCHAR2 := FND_API.G_FALSE,
    p_cust_acct_site_rec                    IN     CUST_ACCT_SITE_REC_TYPE,
    x_cust_acct_site_id                     OUT NOCOPY    NUMBER,
    x_return_status                         OUT NOCOPY    VARCHAR2,
    x_msg_count                             OUT NOCOPY    NUMBER,
    x_msg_data                              OUT NOCOPY    VARCHAR2
);

/**
 * PROCEDURE update_cust_acct_site
 *
 * DESCRIPTION
 *     Updates customer account site.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
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

/*#
 * Use this routine to update a customer account site. This API updates records in the
 * HZ_CUST_ACCT_SITES table. If the primary key is not passed in, then get the primary key
 * from the HZ_ORIG_SYS_REFERENCES table based on orig_system and orig_system_reference.
 * Note: the orig_system and orig_system_reference must be unique and not null.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update Customer Account Site
 * @rep:businessevent oracle.apps.ar.hz.CustAcctSite.update
 * @rep:doccd 120hztig.pdf Customer Account Site APIs, Oracle Trading Community Architecture Technical Implementation Guide
 */
PROCEDURE update_cust_acct_site (
    p_init_msg_list                         IN     VARCHAR2 := FND_API.G_FALSE,
    p_cust_acct_site_rec                    IN     CUST_ACCT_SITE_REC_TYPE,
    p_object_version_number                 IN OUT NOCOPY NUMBER,
    x_return_status                         OUT NOCOPY    VARCHAR2,
    x_msg_count                             OUT NOCOPY    NUMBER,
    x_msg_data                              OUT NOCOPY    VARCHAR2
);

/**
 * PROCEDURE get_cust_acct_site_rec
 *
 * DESCRIPTION
 *      Gets customer account site record
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
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
);

/**
 * PROCEDURE create_cust_site_use
 *
 * DESCRIPTION
 *     Creates customer account site use.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
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

/*#
 * Use this routine to create a customer account site use. This API creates records in the
 * HZ_CUST_SITE_USES table. Additionally, you can use this routine to create profile
 * information at site level by passing the proper value in p_create_profile. If an
 * orig_system_reference is passed in, then the API creates a record in the
 * HZ_ORIG_SYS_REFERENCES table to store the mapping between the source system reference
 * and the TCA primary key. If orig_system_reference is not passed in, then the default is
 * UNKNOWN.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Customer Account Site Use
 * @rep:businessevent oracle.apps.ar.hz.CustAcctSiteUse.create
 * @rep:doccd 120hztig.pdf Customer Account Site APIs, Oracle Trading Community Architecture Technical Implementation Guide
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
);

/**
 * PROCEDURE update_cust_site_use
 *
 * DESCRIPTION
 *     Updates customer account site use.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
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

/*#
 * Use this routine to update a customer account site use. This API updates records in the
 * HZ_CUST_SITE_USES table. If the primary key is not passed in, then get the primary key
 * from the HZ_ORIG_SYS_REFERENCES table based on orig_system and orig_system_reference.
 * Note: orig_system and orig_system_reference must be unique and not null.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update Customer Account Site Use
 * @rep:businessevent oracle.apps.ar.hz.CustAcctSiteUse.update
 * @rep:doccd 120hztig.pdf Customer Account Site APIs, Oracle Trading Community Architecture Technical Implementation Guide
 */
PROCEDURE update_cust_site_use (
    p_init_msg_list                         IN     VARCHAR2 := FND_API.G_FALSE,
    p_cust_site_use_rec                     IN     CUST_SITE_USE_REC_TYPE,
    p_object_version_number                 IN OUT NOCOPY NUMBER,
    x_return_status                         OUT NOCOPY    VARCHAR2,
    x_msg_count                             OUT NOCOPY    NUMBER,
    x_msg_data                              OUT NOCOPY    VARCHAR2
);

/**
 * PROCEDURE get_cust_site_use_rec
 *
 * DESCRIPTION
 *      Gets customer account site use record
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
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
);

END HZ_CUST_ACCOUNT_SITE_V2PUB;

 

/
