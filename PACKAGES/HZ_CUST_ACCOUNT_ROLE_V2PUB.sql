--------------------------------------------------------
--  DDL for Package HZ_CUST_ACCOUNT_ROLE_V2PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_CUST_ACCOUNT_ROLE_V2PUB" AUTHID CURRENT_USER AS
/*$Header: ARH2CRSS.pls 120.9 2006/08/17 10:17:41 idali ship $ */
/*#
 * This package contains the public APIs for customer account roles and role
 * responsibilities.
 * @rep:scope public
 * @rep:product HZ
 * @rep:displayname Customer Account Role
 * @rep:category BUSINESS_ENTITY HZ_ACCOUNT_CONTACT
 * @rep:lifecycle active
 * @rep:doccd 120hztig.pdf Customer Account Role APIs,  Oracle Trading Community Architecture Technical Implementation Guide
 */

--------------------------------------
-- declaration of record type
--------------------------------------

TYPE cust_account_role_rec_type IS RECORD (
    cust_account_role_id                    NUMBER,
    party_id                                NUMBER,
    cust_account_id                         NUMBER,
    cust_acct_site_id                       NUMBER,
    primary_flag                            VARCHAR2(1),
    role_type                               VARCHAR2(30),
    source_code                             VARCHAR2(150),
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
    attribute21                             VARCHAR2(150),
    attribute22                             VARCHAR2(150),
    attribute23                             VARCHAR2(150),
    attribute24                             VARCHAR2(150),
    orig_system_reference                   VARCHAR2(240),
    orig_system                             VARCHAR2(30),
    attribute25                             VARCHAR2(150),
    status                                  VARCHAR2(1),
    created_by_module                       VARCHAR2(150),
    application_id                          NUMBER
);

TYPE role_responsibility_rec_type IS RECORD (
    responsibility_id                       NUMBER,
    cust_account_role_id                    NUMBER,
    responsibility_type                     VARCHAR2(30),
    primary_flag                            VARCHAR2(1),
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
    orig_system_reference                   VARCHAR2(240),
    created_by_module                       VARCHAR2(150),
    application_id                          NUMBER
);

--------------------------------------
-- declaration of public procedures and functions
--------------------------------------

/**
 * PROCEDURE create_cust_account_role
 *
 * DESCRIPTION
 *     Creates customer account role.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
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

/*#
 * Use this routine to create an account role. The API creates records in
 * the HZ_CUST_ACCOUNT_ROLES table. You must create a customer account and an organization contact
 * for the party that owns the customer account before you can create a customer account
 * role. If an orig_system_reference is passed in, then the API creates a record in the
 * HZ_ORIG_SYS_REFERENCES table to store the mapping between the source system reference
 * and the TCA primary key. If orig_system_reference is not passed in, then the default is
 * UNKNOWN.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Customer Account Role
 * @rep:businessevent oracle.apps.ar.hz.CustAccountRole.create
 * @rep:doccd 120hztig.pdf Customer Account Role APIs,  Oracle Trading Community Architecture Technical Implementation Guide
 */
PROCEDURE create_cust_account_role (
    p_init_msg_list                         IN     VARCHAR2 := FND_API.G_FALSE,
    p_cust_account_role_rec                 IN     CUST_ACCOUNT_ROLE_REC_TYPE,
    x_cust_account_role_id                  OUT NOCOPY    NUMBER,
    x_return_status                         OUT NOCOPY    VARCHAR2,
    x_msg_count                             OUT NOCOPY    NUMBER,
    x_msg_data                              OUT NOCOPY    VARCHAR2
);

/**
 * PROCEDURE update_cust_account_role
 *
 * DESCRIPTION
 *     Updates customer account role.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
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

/*#
 * Use this routine to update an account role. This API updates records in
 * the HZ_CUST_ACCOUNT_ROLES table. If the primary key is not passed in, then get the
 * primary key from the HZ_ORIG_SYS_REFERENCES table using orig_system and
 * orig_system_reference. Note: orig_system and orig_system_reference must be unique and
 * not null and unique.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update Customer Account Role
 * @rep:businessevent oracle.apps.ar.hz.CustAccountRole.update
 * @rep:doccd 120hztig.pdf Customer Account Role APIs,  Oracle Trading Community Architecture Technical Implementation Guide
 */
PROCEDURE update_cust_account_role (
    p_init_msg_list                         IN     VARCHAR2 := FND_API.G_FALSE,
    p_cust_account_role_rec                 IN     CUST_ACCOUNT_ROLE_REC_TYPE,
    p_object_version_number                 IN OUT NOCOPY NUMBER,
    x_return_status                         OUT NOCOPY    VARCHAR2,
    x_msg_count                             OUT NOCOPY    NUMBER,
    x_msg_data                              OUT NOCOPY    VARCHAR2
);

/**
 * PROCEDURE get_cust_account_role_rec
 *
 * DESCRIPTION
 *      Gets customer account role record
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
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
);

/**
 * PROCEDURE create_role_responsibility
 *
 * DESCRIPTION
 *     Creates customer account role responsibility.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
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

/*#
 * Use this routine to create a role responsibility. This API creates records in the
 * HZ_ROLE_RESPONSIBILITY table.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Role Responsibility
 * @rep:businessevent oracle.apps.ar.hz.RoleResponsibility.create
 * @rep:doccd 120hztig.pdf Customer Account Role APIs,  Oracle Trading Community Architecture Technical Implementation Guide
 */
PROCEDURE create_role_responsibility (
    p_init_msg_list                         IN     VARCHAR2 := FND_API.G_FALSE,
    p_role_responsibility_rec               IN     ROLE_RESPONSIBILITY_REC_TYPE,
    x_responsibility_id                     OUT NOCOPY    NUMBER,
    x_return_status                         OUT NOCOPY    VARCHAR2,
    x_msg_count                             OUT NOCOPY    NUMBER,
    x_msg_data                              OUT NOCOPY    VARCHAR2
);

/**
 * PROCEDURE update_role_responsibility
 *
 * DESCRIPTION
 *     Updates customer account role responsibility.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
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

/*#
 * Use this routine to update a role responsibility. The API updates a record in the
 * HZ_ROLE_RESPONSIBILITY table.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update Role Responsibility
 * @rep:businessevent oracle.apps.ar.hz.RoleResponsibility.update
 * @rep:doccd 120hztig.pdf Customer Account Role APIs,  Oracle Trading Community Architecture Technical Implementation Guide
 */
PROCEDURE update_role_responsibility (
    p_init_msg_list                         IN     VARCHAR2 := FND_API.G_FALSE,
    p_role_responsibility_rec               IN     ROLE_RESPONSIBILITY_REC_TYPE,
    p_object_version_number                 IN OUT NOCOPY NUMBER,
    x_return_status                         OUT NOCOPY    VARCHAR2,
    x_msg_count                             OUT NOCOPY    NUMBER,
    x_msg_data                              OUT NOCOPY    VARCHAR2
);

/**
 * PROCEDURE get_role_responsibility_rec
 *
 * DESCRIPTION
 *      Gets customer account role responsibility record
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
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
);

END HZ_CUST_ACCOUNT_ROLE_V2PUB;

 

/
