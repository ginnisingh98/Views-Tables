--------------------------------------------------------
--  DDL for Package HZ_STYLE_V2PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_STYLE_V2PUB" AUTHID CURRENT_USER AS
/*$Header: ARH2STSS.pls 115.2 2002/11/21 06:09:32 sponnamb noship $ */

--------------------------------------
-- declaration of record type
--------------------------------------

  TYPE style_rec_type IS RECORD(
    style_code                 VARCHAR2(30),
    database_object_name       VARCHAR2(30),
    style_name                 VARCHAR2(240),
    description                VARCHAR2(2000)
    );

--------------------------------------
-- declaration of public procedures and functions
--------------------------------------

/**
 * PROCEDURE create_style
 *
 * DESCRIPTION
 *     Creates style.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_style_rec                    Style record.
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
 *   17-Jul-2002    Kate Shan        o Created.
 *
 */

PROCEDURE create_style (
    p_init_msg_list                    IN      VARCHAR2 := FND_API.G_FALSE,
    p_style_rec                        IN      STYLE_REC_TYPE,
    x_return_status                    OUT NOCOPY     VARCHAR2,
    x_msg_count                        OUT NOCOPY     NUMBER,
    x_msg_data                         OUT NOCOPY     VARCHAR2
);

/**
 * PROCEDURE update_style
 *
 * DESCRIPTION
 *     Updates style.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_style_rec                 Style record.
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
 *   17-Jul-2002    Kate Shan        o Created.
 *
 */

PROCEDURE update_style (
    p_init_msg_list         IN         VARCHAR2 :=FND_API.G_FALSE,
    p_style_rec             IN         STYLE_REC_TYPE,
    p_object_version_number IN OUT NOCOPY     NUMBER,
    x_return_status         OUT NOCOPY        VARCHAR2,
    x_msg_count             OUT NOCOPY        NUMBER,
    x_msg_data              OUT NOCOPY        VARCHAR2
);

/**
 * PROCEDURE get_style_rec
 *
 * DESCRIPTION
 *     Gets style record.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_style_code                   Style Code.
 *   IN/OUT:
 *   OUT:
 *     x_style_rec                 Style record.
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
 *   17-Jul-2002    Kate Shan        o Created.
 *
 */

 PROCEDURE get_style_rec (
    p_init_msg_list      IN          VARCHAR2 := FND_API.G_FALSE,
    p_style_code         IN          VARCHAR2,
    x_style_rec          OUT  NOCOPY STYLE_REC_TYPE,
    x_return_status      OUT NOCOPY         VARCHAR2,
    x_msg_count          OUT NOCOPY         NUMBER,
    x_msg_data           OUT NOCOPY         VARCHAR2
);

END HZ_STYLE_V2PUB;

 

/