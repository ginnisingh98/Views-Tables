--------------------------------------------------------
--  DDL for Package HZ_BES_BO_DEFINITION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_BES_BO_DEFINITION_PVT" AUTHID CURRENT_USER AS
/* $Header: ARHBODVS.pls 120.0 2005/08/16 23:00:33 acng noship $ */

--------------------------------------
-- declaration of procedures and functions
--------------------------------------
/**
 * PROCEDURE update_bod
 *
 * DESCRIPTION
 *   Update Business Object Definition
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_business_object_code         Business Object Code.
 *     p_child_bo_code                Child BO Code.
 *     p_entity_name                  Entity Name.
 *     p_user_mandated_flag           User Mandated Flag.
 *   IN/OUT:
 *     p_object_version_number        Object version number.
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
 *   12-AUG-2005    Arnold Ng         o Created.
 *
 */

PROCEDURE update_bod (
    p_init_msg_list             IN  VARCHAR2 := FND_API.G_FALSE,
    p_business_object_code      IN  VARCHAR2,
    p_child_bo_code             IN  VARCHAR2,
    p_entity_name               IN  VARCHAR2,
    p_user_mandated_flag        IN  VARCHAR2,
    p_object_version_number     IN OUT NOCOPY  NUMBER,
    x_return_status             OUT NOCOPY     VARCHAR2,
    x_msg_count                 OUT NOCOPY     NUMBER,
    x_msg_data                  OUT NOCOPY     VARCHAR2
);

END HZ_BES_BO_DEFINITION_PVT;

 

/
