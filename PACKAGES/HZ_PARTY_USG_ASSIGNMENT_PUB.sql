--------------------------------------------------------
--  DDL for Package HZ_PARTY_USG_ASSIGNMENT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_PARTY_USG_ASSIGNMENT_PUB" AUTHID CURRENT_USER AS
/*$Header: ARHPUASS.pls 120.0 2005/05/23 22:22:00 jhuang noship $ */


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
    p_party_usg_assignment_rec    IN     HZ_PARTY_USG_ASSIGNMENT_PVT.party_usg_assignment_rec_type,
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
    p_party_usg_assignment_id     IN     NUMBER DEFAULT NULL,
    p_party_usg_assignment_rec    IN     HZ_PARTY_USG_ASSIGNMENT_PVT.party_usg_assignment_rec_type,
    x_return_status               OUT    NOCOPY VARCHAR2,
    x_msg_count                   OUT    NOCOPY NUMBER,
    x_msg_data                    OUT    NOCOPY VARCHAR2
);


END HZ_PARTY_USG_ASSIGNMENT_PUB;

 

/
