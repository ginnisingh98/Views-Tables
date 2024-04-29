--------------------------------------------------------
--  DDL for Package HZ_CUSTOMER_PROFILE_V2PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_CUSTOMER_PROFILE_V2PUB" AUTHID CURRENT_USER AS
/*$Header: ARH2CFSS.pls 120.10.12010000.2 2009/02/27 12:42:38 rgokavar ship $ */
/*#
 * This package contains the public APIs for customer profiles and customer profile
 * amounts.
 * @rep:scope public
 * @rep:product HZ
 * @rep:displayname Customer Profile
 * @rep:category BUSINESS_ENTITY HZ_CUSTOMER_ACCOUNT
 * @rep:lifecycle active
 * @rep:doccd 120hztig.pdf Customer Profile APIs, Oracle Trading Community Architecture Technical Implementation Guide
 */

--------------------------------------
-- declaration of record type
--------------------------------------

TYPE customer_profile_rec_type IS RECORD (
    cust_account_profile_id                 NUMBER,
    cust_account_id                         NUMBER,
    status                                  VARCHAR2(1),
    collector_id                            NUMBER,
    credit_analyst_id                       NUMBER,
    credit_checking                         VARCHAR2(1),
    next_credit_review_date                 DATE,
    tolerance                               NUMBER,
    discount_terms                          VARCHAR2(1),
    dunning_letters                         VARCHAR2(1),
    interest_charges                        VARCHAR2(1),
    send_statements                         VARCHAR2(1),
    credit_balance_statements               VARCHAR2(1),
    credit_hold                             VARCHAR2(1),
    profile_class_id                        NUMBER,
    site_use_id                             NUMBER,
    credit_rating                           VARCHAR2(30),
    risk_code                               VARCHAR2(30),
    standard_terms                          NUMBER,
    override_terms                          VARCHAR2(1),
    dunning_letter_set_id                   NUMBER,
    interest_period_days                    NUMBER,
    payment_grace_days                      NUMBER,
    discount_grace_days                     NUMBER,
    statement_cycle_id                      NUMBER,
    account_status                          VARCHAR2(30),
    percent_collectable                     NUMBER,
    autocash_hierarchy_id                   NUMBER,
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
    auto_rec_incl_disputed_flag             VARCHAR2(1),
    tax_printing_option                     VARCHAR2(30),
    charge_on_finance_charge_flag           VARCHAR2(1),
    grouping_rule_id                        NUMBER,
    clearing_days                           NUMBER,
    jgzz_attribute_category                 VARCHAR2(30),
    jgzz_attribute1                         VARCHAR2(150),
    jgzz_attribute2                         VARCHAR2(150),
    jgzz_attribute3                         VARCHAR2(150),
    jgzz_attribute4                         VARCHAR2(150),
    jgzz_attribute5                         VARCHAR2(150),
    jgzz_attribute6                         VARCHAR2(150),
    jgzz_attribute7                         VARCHAR2(150),
    jgzz_attribute8                         VARCHAR2(150),
    jgzz_attribute9                         VARCHAR2(150),
    jgzz_attribute10                        VARCHAR2(150),
    jgzz_attribute11                        VARCHAR2(150),
    jgzz_attribute12                        VARCHAR2(150),
    jgzz_attribute13                        VARCHAR2(150),
    jgzz_attribute14                        VARCHAR2(150),
    jgzz_attribute15                        VARCHAR2(150),
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
    cons_inv_flag                           VARCHAR2(1),
    cons_inv_type                           VARCHAR2(30),
    autocash_hierarchy_id_for_adr           NUMBER,
    lockbox_matching_option                 VARCHAR2(30),
    created_by_module                       VARCHAR2(150),
    application_id                          NUMBER,
    review_cycle                            VARCHAR2(30),
    last_credit_review_date                 DATE,
    party_id                                NUMBER,
    credit_classification                   VARCHAR2(30),
    cons_bill_level                         VARCHAR2(30),
    late_charge_calculation_trx             VARCHAR2(30),
    credit_items_flag                       VARCHAR2(1),
    disputed_transactions_flag              VARCHAR2(1),
    late_charge_type                        VARCHAR2(30),
    late_charge_term_id                     NUMBER,
    interest_calculation_period             VARCHAR2(30),
    hold_charged_invoices_flag              VARCHAR2(1),
    message_text_id                         NUMBER,
    multiple_interest_rates_flag            VARCHAR2(1),
    charge_begin_date                       DATE,
    automatch_set_id                        NUMBER
);

TYPE cust_profile_amt_rec_type IS RECORD (
    cust_acct_profile_amt_id                NUMBER,
    cust_account_profile_id                 NUMBER,
    currency_code                           VARCHAR2(15),
    trx_credit_limit                        NUMBER,
    overall_credit_limit                    NUMBER,
    min_dunning_amount                      NUMBER,
    min_dunning_invoice_amount              NUMBER,
    max_interest_charge                     NUMBER,
    min_statement_amount                    NUMBER,
    auto_rec_min_receipt_amount             NUMBER,
    interest_rate                           NUMBER,
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
    min_fc_balance_amount                   NUMBER,
    min_fc_invoice_amount                   NUMBER,
    cust_account_id                         NUMBER,
    site_use_id                             NUMBER,
    expiration_date                         DATE,
    jgzz_attribute_category                 VARCHAR2(30),
    jgzz_attribute1                         VARCHAR2(150),
    jgzz_attribute2                         VARCHAR2(150),
    jgzz_attribute3                         VARCHAR2(150),
    jgzz_attribute4                         VARCHAR2(150),
    jgzz_attribute5                         VARCHAR2(150),
    jgzz_attribute6                         VARCHAR2(150),
    jgzz_attribute7                         VARCHAR2(150),
    jgzz_attribute8                         VARCHAR2(150),
    jgzz_attribute9                         VARCHAR2(150),
    jgzz_attribute10                        VARCHAR2(150),
    jgzz_attribute11                        VARCHAR2(150),
    jgzz_attribute12                        VARCHAR2(150),
    jgzz_attribute13                        VARCHAR2(150),
    jgzz_attribute14                        VARCHAR2(150),
    jgzz_attribute15                        VARCHAR2(150),
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
    created_by_module                       VARCHAR2(150),
    application_id                          NUMBER,
    exchange_rate_type                      VARCHAR2(30),
    min_fc_invoice_overdue_type             VARCHAR2(30),
    min_fc_invoice_percent                  NUMBER,
    min_fc_balance_overdue_type             VARCHAR2(30),
    min_fc_balance_percent                  NUMBER,
    interest_type                           VARCHAR2(30),
    interest_fixed_amount                   NUMBER,
    interest_schedule_id                    NUMBER,
    penalty_type                            VARCHAR2(30),
    penalty_rate                            NUMBER,
    min_interest_charge                     NUMBER,
    penalty_fixed_amount                    NUMBER,
    penalty_schedule_id                     NUMBER
);

--------------------------------------
-- declaration of public procedures and functions
--------------------------------------
/**
 * Function next_review_date_compute
 *
 * Description
 * Return the next_review_date
 *
 * MODIFICATION HISTORY
 * 04-19-2002  Herve Yu    o Created
 *
 * Parameters : Review_Cycle
 *              Last_review_date
 *              Next_Review_Date
 */
FUNCTION next_review_date_compute
 ( p_review_cycle     IN VARCHAR2  DEFAULT NULL,
   p_last_review_date IN DATE      DEFAULT NULL,
   p_next_review_date IN DATE      DEFAULT NULL)
RETURN DATE;


/**
 * Function last_review_date_default
 *
 * Description
 * Return the last_review_date
 *
 * MODIFICATION HISTORY
 * 04-19-2002  Herve Yu    o Created
 *
 * In parameter : Review_Cycle
 *                Last_review_Date
 *                p_create_update_flag
 */
FUNCTION last_review_date_default
 ( p_review_cycle          IN VARCHAR2 DEFAULT NULL,
   p_last_review_date      IN DATE     DEFAULT NULL,
   p_create_update_flag    IN VARCHAR2)
RETURN DATE;


/**
 * PROCEDURE create_customer_profile
 *
 * DESCRIPTION
 *     Creates customer profile.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_customer_profile_rec         Customer profile record. One customer account
 *                                    must have a customer profile. One account site
 *                                    use can optionally have one customer profile.
 *     p_create_profile_amt           If it is set to FND_API.G_TRUE, API create customer
 *                                    profile amounts by copying corresponding data
 *                                    from customer profile class amounts.
 *   IN/OUT:
 *   OUT:
 *     x_cust_account_profile_id      Customer account profile ID.
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
 * Use this routine to create a customer profile. This API creates records
 * in the HZ_CUSTOMER_PROFILES table. With this API you can create customer profiles at the
 * party, customer, or customer site levels. This API also creates profile amounts,
 * based on the value passed for p_create_profile_amt.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Customer Profile
 * @rep:businessevent oracle.apps.ar.hz.CustomerProfile.create
 * @rep:doccd 120hztig.pdf Customer Profile APIs, Oracle Trading Community Architecture Technical Implementation Guide
 */
PROCEDURE create_customer_profile (
    p_init_msg_list                         IN     VARCHAR2 := FND_API.G_FALSE,
    p_customer_profile_rec                  IN     CUSTOMER_PROFILE_REC_TYPE,
    p_create_profile_amt                    IN     VARCHAR2 := FND_API.G_TRUE,
    x_cust_account_profile_id               OUT NOCOPY    NUMBER,
    x_return_status                         OUT NOCOPY    VARCHAR2,
    x_msg_count                             OUT NOCOPY    NUMBER,
    x_msg_data                              OUT NOCOPY    VARCHAR2
);

/**
 * PROCEDURE update_customer_profile
 *
 * DESCRIPTION
 *     Updates customer profile.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_customer_profile_rec         Customer profile record. One customer account
 *                                    must have a customer profile. One account site
 *                                    use can optionally have one customer profile.
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
 * Use this routine to update a customer profile. This API updates records
 * in the HZ_CUSTOMER_PROFILES table. The profile can exist at the party, customer, or
 * customer site levels.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update Customer Profile
 * @rep:businessevent oracle.apps.ar.hz.CustomerProfile.update
 * @rep:doccd 120hztig.pdf Customer Profile APIs, Oracle Trading Community Architecture Technical Implementation Guide
 */
PROCEDURE update_customer_profile (
    p_init_msg_list                         IN     VARCHAR2 := FND_API.G_FALSE,
    p_customer_profile_rec                  IN     CUSTOMER_PROFILE_REC_TYPE,
    p_object_version_number                 IN OUT NOCOPY NUMBER,
    x_return_status                         OUT NOCOPY    VARCHAR2,
    x_msg_count                             OUT NOCOPY    NUMBER,
    x_msg_data                              OUT NOCOPY    VARCHAR2
);

/**
 * PROCEDURE get_customer_profile_rec
 *
 * DESCRIPTION
 *      Gets customer profile record
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_cust_account_profile_id      Customer account profile id.
 *   IN/OUT:
 *   OUT:
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

PROCEDURE get_customer_profile_rec (
    p_init_msg_list                         IN     VARCHAR2 := FND_API.G_FALSE,
    p_cust_account_profile_id               IN     NUMBER,
    x_customer_profile_rec                  OUT    NOCOPY CUSTOMER_PROFILE_REC_TYPE,
    x_return_status                         OUT NOCOPY    VARCHAR2,
    x_msg_count                             OUT NOCOPY    NUMBER,
    x_msg_data                              OUT NOCOPY    VARCHAR2
);

/**
 * PROCEDURE create_cust_profile_amt
 *
 * DESCRIPTION
 *     Creates customer profile amounts.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_check_foreign_key            If do foreign key checking on cust_account_id
 *                                    and cust_account_profile_id or not. Defaut value
 *                                    is FND_API.G_TRUE, which means API will do foreign
 *                                    key checking on these 2 columns.
 *     p_cust_profile_amt_rec         Customer profile amount record.
 *   IN/OUT:
 *   OUT:
 *     x_cust_acct_profile_amt_id     Customer account profile amount ID.
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
 * Use this routine to create a customer profile amount. You can use this API to create
 * records in the HZ_CUST_PROFILE_AMTS table for a profile. Before you can create a profile
 * amount record, you must create a customer profile.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Customer Profile Amount
 * @rep:businessevent oracle.apps.ar.hz.CustProfileAmt.create
 * @rep:doccd 120hztig.pdf Customer Profile APIs, Oracle Trading Community Architecture Technical Implementation Guide
 */
PROCEDURE create_cust_profile_amt (
    p_init_msg_list                         IN     VARCHAR2 := FND_API.G_FALSE,
    p_check_foreign_key                     IN     VARCHAR2 := FND_API.G_TRUE,
    p_cust_profile_amt_rec                  IN     CUST_PROFILE_AMT_REC_TYPE,
    x_cust_acct_profile_amt_id              OUT NOCOPY    NUMBER,
    x_return_status                         OUT NOCOPY    VARCHAR2,
    x_msg_count                             OUT NOCOPY    NUMBER,
    x_msg_data                              OUT NOCOPY    VARCHAR2
);

/**
 * PROCEDURE update_cust_profile_amt
 *
 * DESCRIPTION
 *     Updates customer profile amounts.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_cust_profile_amt_rec         Customer profile amount record.
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
 * Use this routine to update a customer profile amount. The API updates a
 * record in the HZ_CUST_PROFILE_AMTS table.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update Customer Profile Amount
 * @rep:businessevent oracle.apps.ar.hz.CustProfileAmt.update
 * @rep:doccd 120hztig.pdf Customer Profile APIs, Oracle Trading Community Architecture Technical Implementation Guide
 */
PROCEDURE update_cust_profile_amt (
    p_init_msg_list                         IN     VARCHAR2 := FND_API.G_FALSE,
    p_cust_profile_amt_rec                  IN     CUST_PROFILE_AMT_REC_TYPE,
    p_object_version_number                 IN OUT NOCOPY NUMBER,
    x_return_status                         OUT NOCOPY    VARCHAR2,
    x_msg_count                             OUT NOCOPY    NUMBER,
    x_msg_data                              OUT NOCOPY    VARCHAR2
);

/**
 * PROCEDURE get_cust_profile_amt_rec
 *
 * DESCRIPTION
 *      Gets customer profile amount record
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_cust_acct_profile_amt_id     Customer account profile amount id.
 *   IN/OUT:
 *   OUT:
 *     x_cust_profile_amt_rec         Returned customer profile amount record.
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

PROCEDURE get_cust_profile_amt_rec (
    p_init_msg_list                         IN     VARCHAR2 := FND_API.G_FALSE,
    p_cust_acct_profile_amt_id              IN     NUMBER,
    x_cust_profile_amt_rec                  OUT    NOCOPY CUST_PROFILE_AMT_REC_TYPE,
    x_return_status                         OUT NOCOPY    VARCHAR2,
    x_msg_count                             OUT NOCOPY    NUMBER,
    x_msg_data                              OUT NOCOPY    VARCHAR2
);

END HZ_CUSTOMER_PROFILE_V2PUB;

/
