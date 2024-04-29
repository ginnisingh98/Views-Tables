--------------------------------------------------------
--  DDL for Package HZ_PARTY_USG_ASSIGNMENT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_PARTY_USG_ASSIGNMENT_PVT" AUTHID CURRENT_USER AS
/*$Header: ARHPUAPS.pls 120.2 2005/10/04 16:19:57 ansingha noship $ */


--------------------------------------
-- declaration of type
--------------------------------------

TYPE party_usg_assignment_rec_type IS RECORD (
    party_id                      NUMBER(15),
    party_usage_code              VARCHAR2(30),
    effective_start_date          DATE,
    effective_end_date            DATE,
    comments                      VARCHAR2(240),
    owner_table_name              VARCHAR2(30),
    owner_table_id                NUMBER(15),
    created_by_module             VARCHAR2(150),
    attribute_category            VARCHAR2(30),
    attribute1                    VARCHAR2(150),
    attribute2                    VARCHAR2(150),
    attribute3                    VARCHAR2(150),
    attribute4                    VARCHAR2(150),
    attribute5                    VARCHAR2(150),
    attribute6                    VARCHAR2(150),
    attribute7                    VARCHAR2(150),
    attribute8                    VARCHAR2(150),
    attribute9                    VARCHAR2(150),
    attribute10                   VARCHAR2(150),
    attribute11                   VARCHAR2(150),
    attribute12                   VARCHAR2(150),
    attribute13                   VARCHAR2(150),
    attribute14                   VARCHAR2(150),
    attribute15                   VARCHAR2(150),
    attribute16                   VARCHAR2(150),
    attribute17                   VARCHAR2(150),
    attribute18                   VARCHAR2(150),
    attribute19                   VARCHAR2(150),
    attribute20                   VARCHAR2(150)
);

--------------------------------------
-- public variables
--------------------------------------


G_VALID_LEVEL_FULL           CONSTANT NUMBER := 100;
G_VALID_LEVEL_HIGH           CONSTANT NUMBER := 75;
G_VALID_LEVEL_THIRD_MEDIUM   CONSTANT NUMBER := 74;
G_VALID_LEVEL_MEDIUM         CONSTANT NUMBER := 50;
G_VALID_LEVEL_LOW            CONSTANT NUMBER := 25;
G_VALID_LEVEL_NONE           CONSTANT NUMBER := 0;

--------------------------------------
-- public procedures and functions
--------------------------------------

/**
 * PROCEDURE assign_party_usage
 *
 * DESCRIPTION
 *     Creates party usage assignment.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list            Initialize message stack if it is set to
 *                                FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_validation_level         Validation level. Default is full validation.
 *     p_party_usg_assignment_rec Party usage assignment record.
 *   IN/OUT:
 *   OUT:
 *     x_return_status            Return status after the call. The status can
 *                                be FND_API.G_RET_STS_SUCCESS (success),
 *                                FND_API.G_RET_STS_ERROR (error),
 *                                FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
 *     x_msg_count                Number of messages in message stack.
 *     x_msg_data                 Message text if x_msg_count is 1.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   05/01/05      Jianying Huang     o Created.
 *
 */

PROCEDURE assign_party_usage (
    p_init_msg_list               IN     VARCHAR2 DEFAULT NULL,
    p_validation_level            IN     NUMBER DEFAULT NULL,
    p_party_usg_assignment_rec    IN     party_usg_assignment_rec_type,
    x_return_status               OUT    NOCOPY VARCHAR2,
    x_msg_count                   OUT    NOCOPY NUMBER,
    x_msg_data                    OUT    NOCOPY VARCHAR2
);


/**
 * PROCEDURE inactivate_usg_assignment
 *
 * DESCRIPTION
 *     Inactivates party usage assignment.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list            Initialize message stack if it is set to
 *                                FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_validation_level         Validation level. Default is full validation.
 *     p_party_usg_assignment_id  Party usage assignment Id.
 *     p_party_id                 Party Id
 *     p_party_usage_code         Party usage code
 *   IN/OUT:
 *   OUT:
 *     x_return_status            Return status after the call. The status can
 *                                be FND_API.G_RET_STS_SUCCESS (success),
 *                                FND_API.G_RET_STS_ERROR (error),
 *                                FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
 *     x_msg_count                Number of messages in message stack.
 *     x_msg_data                 Message text if x_msg_count is 1.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   05/01/05      Jianying Huang     o Created.
 *
 */

PROCEDURE inactivate_usg_assignment (
    p_init_msg_list               IN     VARCHAR2 DEFAULT NULL,
    p_validation_level            IN     NUMBER DEFAULT NULL,
    p_party_usg_assignment_id     IN     NUMBER DEFAULT NULL,
    p_party_id                    IN     NUMBER DEFAULT NULL,
    p_party_usage_code            IN     VARCHAR2 DEFAULT NULL,
    x_return_status               OUT    NOCOPY VARCHAR2,
    x_msg_count                   OUT    NOCOPY NUMBER,
    x_msg_data                    OUT    NOCOPY VARCHAR2
);


/**
 * PROCEDURE update_usg_assignment
 *
 * DESCRIPTION
 *     Update party usage assignment.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list            Initialize message stack if it is set to
 *                                FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_validation_level         Validation level. Default is full validation.
 *     p_party_usg_assignment_id  Party usage assignment Id.
 *     p_party_usg_assignment_rec Party usage assignment record.
 *   IN/OUT:
 *   OUT:
 *     x_return_status            Return status after the call. The status can
 *                                be FND_API.G_RET_STS_SUCCESS (success),
 *                                FND_API.G_RET_STS_ERROR (error),
 *                                FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
 *     x_msg_count                Number of messages in message stack.
 *     x_msg_data                 Message text if x_msg_count is 1.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   05/01/05      Jianying Huang     o Created.
 *
 */

PROCEDURE update_usg_assignment (
    p_init_msg_list               IN     VARCHAR2 DEFAULT NULL,
    p_validation_level            IN     NUMBER DEFAULT NULL,
    p_party_usg_assignment_id     IN     NUMBER DEFAULT NULL,
    p_party_usg_assignment_rec    IN     party_usg_assignment_rec_type,
    x_return_status               OUT    NOCOPY VARCHAR2,
    x_msg_count                   OUT    NOCOPY NUMBER,
    x_msg_data                    OUT    NOCOPY VARCHAR2
);


/**
 * PROCEDURE refresh
 *
 * DESCRIPTION
 *     Refresh the cached setup. Need to be called when the party usage setup
 *     is changed via admin UI.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   05/01/05      Jianying Huang     o Created.
 *
 */

PROCEDURE refresh;


/**
 * PROCEDURE set_calling_api
 *
 * DESCRIPTION
 *     Set calling api. Internal use only.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   05/01/05      Jianying Huang     o Created.
 *
 */

PROCEDURE set_calling_api (
    p_calling_api                 IN     VARCHAR2
);


/**
 * FUNCTION allow_party_merge
 *
 * DESCRIPTION
 *     Created for party merge. Check party usage
 *     rules to determine if merge is allowed.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   07/19/05      Jianying Huang     o Created.
 *
 */

FUNCTION allow_party_merge (
    p_init_msg_list               IN     VARCHAR2 DEFAULT NULL,
    p_from_party_id               IN     NUMBER,
    p_to_party_id                 IN     NUMBER,
    x_msg_count                   OUT    NOCOPY NUMBER,
    x_msg_data                    OUT    NOCOPY VARCHAR2
) RETURN VARCHAR2;


/**
 * FUNCTION find_duplicates
 *
 * DESCRIPTION
 *     Created for party merge. Find duplicate assignment.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   07/19/05      Jianying Huang     o Created.
 *
 */

PROCEDURE find_duplicates (
    p_from_assignment_id          IN     NUMBER,
    p_to_party_id                 IN     NUMBER,
    x_to_assignment_id            OUT    NOCOPY NUMBER
);

--------------------------------Bug 4586451
/**
 * PROCEDURE validate_supplier_name
 *
 * DESCRIPTION
 *     Validate supplier name.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *     IN:
 *       p_party_id              party id
 *       p_party_name            party name
 *       x_return_status         return status
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 */

PROCEDURE validate_supplier_name (
    p_party_id                    IN     NUMBER,
    p_party_name                  IN     VARCHAR2,
    x_return_status               IN OUT NOCOPY VARCHAR2
);
----------------------------Bug 4586451


END HZ_PARTY_USG_ASSIGNMENT_PVT;

 

/
