--------------------------------------------------------
--  DDL for Package Body HZ_PARTY_USG_ASSIGNMENT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_PARTY_USG_ASSIGNMENT_PUB" AS
/*$Header: ARHPUASB.pls 120.0 2005/05/23 22:22:04 jhuang noship $ */

--------------------------------------
-- private global variable
--------------------------------------

G_PACKAGE_NAME                    CONSTANT VARCHAR2(30) := 'HZ_PARTY_USG_ASSIGNMENT_PUB';

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
    p_init_msg_list               IN     VARCHAR2,
    p_party_usg_assignment_rec    IN     HZ_PARTY_USG_ASSIGNMENT_PVT.party_usg_assignment_rec_type,
    x_return_status               OUT    NOCOPY VARCHAR2,
    x_msg_count                   OUT    NOCOPY NUMBER,
    x_msg_data                    OUT    NOCOPY VARCHAR2
) IS

BEGIN

    HZ_PARTY_USG_ASSIGNMENT_PVT.set_calling_api(G_PACKAGE_NAME);

    HZ_PARTY_USG_ASSIGNMENT_PVT.assign_party_usage (
      p_init_msg_list             => p_init_msg_list,
      p_validation_level          => HZ_PARTY_USG_ASSIGNMENT_PVT.G_VALID_LEVEL_FULL,
      p_party_usg_assignment_rec  => p_party_usg_assignment_rec,
      x_return_status             => x_return_status,
      x_msg_count                 => x_msg_count,
      x_msg_data                  => x_msg_data
    );

END assign_party_usage;


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
    p_init_msg_list               IN     VARCHAR2,
    p_party_usg_assignment_id     IN     NUMBER,
    p_party_id                    IN     NUMBER,
    p_party_usage_code            IN     VARCHAR2,
    x_return_status               OUT    NOCOPY VARCHAR2,
    x_msg_count                   OUT    NOCOPY NUMBER,
    x_msg_data                    OUT    NOCOPY VARCHAR2
) IS

BEGIN

    HZ_PARTY_USG_ASSIGNMENT_PVT.set_calling_api(G_PACKAGE_NAME);

    HZ_PARTY_USG_ASSIGNMENT_PVT.inactivate_usg_assignment (
      p_init_msg_list             => p_init_msg_list,
      p_validation_level          => HZ_PARTY_USG_ASSIGNMENT_PVT.G_VALID_LEVEL_FULL,
      p_party_id                  => p_party_id,
      p_party_usage_code          => p_party_usage_code,
      x_return_status             => x_return_status,
      x_msg_count                 => x_msg_count,
      x_msg_data                  => x_msg_data
    );

END inactivate_usg_assignment;


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
    p_init_msg_list               IN     VARCHAR2,
    p_party_usg_assignment_id     IN     NUMBER,
    p_party_usg_assignment_rec    IN     HZ_PARTY_USG_ASSIGNMENT_PVT.party_usg_assignment_rec_type,
    x_return_status               OUT    NOCOPY VARCHAR2,
    x_msg_count                   OUT    NOCOPY NUMBER,
    x_msg_data                    OUT    NOCOPY VARCHAR2
) IS

BEGIN

    HZ_PARTY_USG_ASSIGNMENT_PVT.set_calling_api(G_PACKAGE_NAME);

    HZ_PARTY_USG_ASSIGNMENT_PVT.update_usg_assignment (
      p_init_msg_list             => p_init_msg_list,
      p_validation_level          => HZ_PARTY_USG_ASSIGNMENT_PVT.G_VALID_LEVEL_FULL,
      p_party_usg_assignment_id   => p_party_usg_assignment_id,
      p_party_usg_assignment_rec  => p_party_usg_assignment_rec,
      x_return_status             => x_return_status,
      x_msg_count                 => x_msg_count,
      x_msg_data                  => x_msg_data
    );

END update_usg_assignment;


END HZ_PARTY_USG_ASSIGNMENT_PUB;

/
