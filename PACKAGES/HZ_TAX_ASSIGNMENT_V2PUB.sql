--------------------------------------------------------
--  DDL for Package HZ_TAX_ASSIGNMENT_V2PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_TAX_ASSIGNMENT_V2PUB" AUTHID CURRENT_USER as
/*$Header: ARH2TASS.pls 120.9 2006/08/17 10:20:04 idali noship $ */

--------------------------------------
-- declaration of public procedures and functions
--------------------------------------

/**
 * PROCEDURE create_loc_assignment
 *
 * DESCRIPTION
 *     Creates location assignment.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_location_id                  Location ID.
 *     p_lock_flag                    Lock record or not. Default is FND_API.G_FALSE.
 *     p_created_by_module            Module name which creates this record.
 *     p_application_id               Application ID which creates this record.
 *   IN/OUT:
 *   OUT:
 *     x_return_status                Return status after the call. The status can
 *                                    be FND_API.G_RET_STS_SUCCESS (success),
 *                                    FND_API.G_RET_STS_ERROR (error),
 *                                    FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
 *     x_msg_count                    Number of messages in message stack.
 *     x_msg_data                     Message text if x_msg_count is 1.
 *     x_loc_id                       Location assignment ID.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   07-23-2001    Indrajit Sen        o Created.
 *
 */

PROCEDURE create_loc_assignment(
        p_init_msg_list                IN      VARCHAR2 := FND_API.G_FALSE,
        p_location_id                  IN      NUMBER,
        p_lock_flag                    IN      VARCHAR2 := FND_API.G_FALSE,
        p_created_by_module            IN      VARCHAR2,
        p_application_id               IN      NUMBER,
        x_return_status                IN OUT NOCOPY  VARCHAR2,
        x_msg_count                    OUT NOCOPY     NUMBER,
        x_msg_data                     OUT NOCOPY     VARCHAR2,
        x_loc_id                       OUT NOCOPY     NUMBER
);

/**
 * PROCEDURE update_loc_assignment
 *
 * DESCRIPTION
 *     Updates location assignment.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_location_id                  Location ID.
 *     p_lock_flag                    Lock record or not. Default is FND_API.G_TRUE.
 *     p_created_by_module            Module name which creates this record.
 *     p_application_id               Application ID which creates this record.
 *   IN/OUT:
 *   OUT:
 *     x_return_status                Return status after the call. The status can
 *                                    be FND_API.G_RET_STS_SUCCESS (success),
 *                                    FND_API.G_RET_STS_ERROR (error),
 *                                    FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
 *     x_msg_count                    Number of messages in message stack.
 *     x_msg_data                     Message text if x_msg_count is 1.
 *     x_loc_id                       Location assignment ID.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   07-23-2001    Indrajit Sen        o Created.
 *   06-17-2002    Rajeshwari P        o Bug 2413694.Changed the default value
 *                                       of p_lock_flag from FND_API.G_TRUE to
 *                                       FND_API.G_FALSE.
 *   06-17-2002    Rajeshwari P        o Bug 2413694.Reverted the previous change
 *
 */

PROCEDURE update_loc_assignment(
        p_init_msg_list                IN      VARCHAR2 := FND_API.G_FALSE,
        p_location_id                  IN      NUMBER,
        p_lock_flag                    IN      VARCHAR2 := FND_API.G_TRUE,
        p_created_by_module            IN      VARCHAR2,
        p_application_id               IN      NUMBER,
        x_return_status                IN OUT NOCOPY  VARCHAR2,
        x_msg_count                    OUT NOCOPY     NUMBER,
        x_msg_data                     OUT NOCOPY     VARCHAR2,
        x_loc_id                       OUT NOCOPY     NUMBER,
        x_org_id                       OUT NOCOPY     VARCHAR2
);


PROCEDURE update_loc_assignment(
        p_init_msg_list                IN      VARCHAR2 := FND_API.G_FALSE,
        p_location_id                  IN      NUMBER,
        p_lock_flag                    IN      VARCHAR2 := FND_API.G_TRUE,
        p_created_by_module            IN      VARCHAR2,
        p_application_id               IN      NUMBER,
        x_return_status                IN OUT NOCOPY  VARCHAR2,
        x_msg_count                    OUT NOCOPY     NUMBER,
        x_msg_data                     OUT NOCOPY     VARCHAR2,
        x_loc_id                       OUT NOCOPY     NUMBER
);


/*
 * overloaded procedure with address validation.
 */

PROCEDURE update_loc_assignment(
        p_init_msg_list                IN      VARCHAR2 := FND_API.G_FALSE,
        p_location_id                  IN      NUMBER,
        p_lock_flag                    IN      VARCHAR2 :=FND_API.G_TRUE,
        p_do_addr_val                  IN      VARCHAR2,
        x_addr_val_status              OUT NOCOPY     VARCHAR2,
        x_addr_warn_msg                OUT NOCOPY     VARCHAR2,
        x_return_status                IN OUT NOCOPY  VARCHAR2,
        x_msg_count                    OUT NOCOPY     NUMBER,
        x_msg_data                     OUT NOCOPY     VARCHAR2
);


END HZ_TAX_ASSIGNMENT_V2PUB;


 

/
