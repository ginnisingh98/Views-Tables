--------------------------------------------------------
--  DDL for Package HZ_ACCOUNT_VALIDATE_V2PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_ACCOUNT_VALIDATE_V2PUB" AUTHID CURRENT_USER AS
/*$Header: ARH2ACVS.pls 120.2 2005/08/12 07:17:02 idali ship $ */

--------------------------------------
-- declaration of public procedures and functions
--------------------------------------

/**
 * PROCEDURE validate_cust_account
 *
 * DESCRIPTION
 *     Validates customer account record. Checks for
 *         uniqueness
 *         lookup types
 *         mandatory columns
 *         non-updateable fields
 *         foreign key validations
 *         other validations
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_create_update_flag           Create update flag. 'C' = create. 'U' = update.
 *     p_cust_account_rec             Customer account record.
 *     p_rowid                        Rowid of the record (used only in update mode).
 *   IN/OUT:
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

PROCEDURE validate_cust_account (
    p_create_update_flag                    IN     VARCHAR2,
    p_cust_account_rec                      IN     HZ_CUST_ACCOUNT_V2PUB.CUST_ACCOUNT_REC_TYPE,
    p_rowid                                 IN     ROWID,
    x_return_status                         IN OUT NOCOPY VARCHAR2
);

/**
 * PROCEDURE validate_cust_acct_relate
 *
 * DESCRIPTION
 *     Validates customer account relate record. Checks for
 *         uniqueness
 *         lookup types
 *         mandatory columns
 *         non-updateable fields
 *         foreign key validations
 *         other validations
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_create_update_flag           Create update flag. 'C' = create. 'U' = update.
 *     p_cust_account_rec             Customer account relate record.
 *     p_rowid                        Rowid of the record (used only in update mode).
 *   IN/OUT:
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
 *   08-12-2005    Idris Ali           o Bug 4529413:Replaced parameter rowid with cust_acct_relate_id.
 *
 */

PROCEDURE validate_cust_acct_relate (
    p_create_update_flag                    IN     VARCHAR2,
    p_cust_acct_relate_rec                  IN     HZ_CUST_ACCOUNT_V2PUB.CUST_ACCT_RELATE_REC_TYPE,
    p_cust_acct_relate_id                   IN     NUMBER,       -- Bug 4529413
    x_return_status                         IN OUT NOCOPY VARCHAR2
);

/**
 * PROCEDURE validate_customer_profile
 *
 * DESCRIPTION
 *     Validates customer profile record. Checks for
 *         uniqueness
 *         lookup types
 *         mandatory columns
 *         non-updateable fields
 *         foreign key validations
 *         other validations
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_create_update_flag           Create update flag. 'C' = create. 'U' = update.
 *     p_customer_profile_rec         Customer profile record.
 *     p_rowid                        Rowid of the record (used only in update mode).
 *   IN/OUT:
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

PROCEDURE validate_customer_profile (
    p_create_update_flag                    IN     VARCHAR2,
    p_customer_profile_rec                  IN     HZ_CUSTOMER_PROFILE_V2PUB.CUSTOMER_PROFILE_REC_TYPE,
    p_rowid                                 IN     ROWID,
    x_return_status                         IN OUT NOCOPY VARCHAR2
);

/**
 * PROCEDURE validate_cust_profile_amt
 *
 * DESCRIPTION
 *     Validates customer profile amount record. Checks for
 *         uniqueness
 *         lookup types
 *         mandatory columns
 *         non-updateable fields
 *         foreign key validations
 *         other validations
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_create_update_flag           Create update flag. 'C' = create. 'U' = update.
 *     p_check_foreign_key            If do foreign key checking on cust_account_id
 *                                    and cust_account_profile_id or not.
 *     p_cust_profile_amt_rec         Customer profile amount record.
 *     p_rowid                        Rowid of the record (used only in update mode).
 *   IN/OUT:
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

PROCEDURE validate_cust_profile_amt (
    p_create_update_flag                    IN     VARCHAR2,
    p_check_foreign_key                     IN     VARCHAR2,
    p_cust_profile_amt_rec                  IN     HZ_CUSTOMER_PROFILE_V2PUB.CUST_PROFILE_AMT_REC_TYPE,
    p_rowid                                 IN     ROWID,
    x_return_status                         IN OUT NOCOPY VARCHAR2
);

/**
 * PROCEDURE validate_cust_acct_site
 *
 * DESCRIPTION
 *     Validates customer account site record. Checks for
 *         uniqueness
 *         lookup types
 *         mandatory columns
 *         non-updateable fields
 *         foreign key validations
 *         other validations
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_create_update_flag           Create update flag. 'C' = create. 'U' = update.
 *     p_cust_acct_site_rec           Customer account site record.
 *     p_rowid                        Rowid of the record (used only in update mode).
 *   IN/OUT:
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

PROCEDURE validate_cust_acct_site (
    p_create_update_flag                    IN     VARCHAR2,
    p_cust_acct_site_rec                    IN     HZ_CUST_ACCOUNT_SITE_V2PUB.CUST_ACCT_SITE_REC_TYPE,
    p_rowid                                 IN     ROWID,
    x_return_status                         IN OUT NOCOPY VARCHAR2
);

/**
 * PROCEDURE validate_cust_site_use
 *
 * DESCRIPTION
 *     Validates customer account site use record. Checks for
 *         uniqueness
 *         lookup types
 *         mandatory columns
 *         non-updateable fields
 *         foreign key validations
 *         other validations
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_create_update_flag           Create update flag. 'C' = create. 'U' = update.
 *     p_cust_site_use_rec            Customer account site use record.
 *     p_rowid                        Rowid of the record (used only in update mode).
 *   IN/OUT:
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

PROCEDURE validate_cust_site_use (
    p_create_update_flag                    IN     VARCHAR2,
    p_cust_site_use_rec                     IN     HZ_CUST_ACCOUNT_SITE_V2PUB.CUST_SITE_USE_REC_TYPE,
    p_rowid                                 IN     ROWID,
    x_return_status                         IN OUT NOCOPY VARCHAR2
);

/**
 * PROCEDURE validate_cust_account_role
 *
 * DESCRIPTION
 *     Validates customer account role record. Checks for
 *         uniqueness
 *         lookup types
 *         mandatory columns
 *         non-updateable fields
 *         foreign key validations
 *         other validations
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_create_update_flag           Create update flag. 'C' = create. 'U' = update.
 *     p_cust_account_role_rec        Customer account role record.
 *     p_rowid                        Rowid of the record (used only in update mode).
 *   IN/OUT:
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

PROCEDURE validate_cust_account_role (
    p_create_update_flag                    IN     VARCHAR2,
    p_cust_account_role_rec                 IN     HZ_CUST_ACCOUNT_ROLE_V2PUB.CUST_ACCOUNT_ROLE_REC_TYPE,
    p_rowid                                 IN     ROWID,
    x_return_status                         IN OUT NOCOPY VARCHAR2
);

/**
 * PROCEDURE validate_role_responsibility
 *
 * DESCRIPTION
 *     Validates customer account role responsibility record. Checks for
 *         uniqueness
 *         lookup types
 *         mandatory columns
 *         non-updateable fields
 *         foreign key validations
 *         other validations
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_create_update_flag           Create update flag. 'C' = create. 'U' = update.
 *     p_role_responsibility_rec      Customer account role responsibility record.
 *     p_rowid                        Rowid of the record (used only in update mode).
 *   IN/OUT:
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

PROCEDURE validate_role_responsibility (
    p_create_update_flag                    IN     VARCHAR2,
    p_role_responsibility_rec               IN     HZ_CUST_ACCOUNT_ROLE_V2PUB.ROLE_RESPONSIBILITY_REC_TYPE,
    p_rowid                                 IN     ROWID,
    x_return_status                         IN OUT NOCOPY VARCHAR2
);

END HZ_ACCOUNT_VALIDATE_V2PUB;

 

/
