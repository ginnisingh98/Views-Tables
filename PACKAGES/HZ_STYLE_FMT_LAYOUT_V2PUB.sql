--------------------------------------------------------
--  DDL for Package HZ_STYLE_FMT_LAYOUT_V2PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_STYLE_FMT_LAYOUT_V2PUB" AUTHID CURRENT_USER AS
/*$Header: ARH2FLSS.pls 115.3 2002/11/21 06:05:10 sponnamb noship $ */

--------------------------------------
-- declaration of record type
--------------------------------------

  TYPE style_fmt_layout_rec_type IS RECORD (
    style_fmt_layout_id          NUMBER,
    style_format_code            VARCHAR2(30),
    variation_number             NUMBER,
    attribute_code	 	 VARCHAR2(30),
    attribute_application_id     NUMBER,
    line_number                  NUMBER,
    position                     NUMBER,
    mandatory_flag		 VARCHAR2(1),
    use_initial_flag		 VARCHAR2(1),
    uppercase_flag		 VARCHAR2(1),
    transform_function		 VARCHAR2(100),
    delimiter_before		 VARCHAR2(20),
    delimiter_after		 VARCHAR2(20),
    blank_lines_before		 NUMBER,
    blank_lines_after		 NUMBER,
    prompt                       VARCHAR2(30),
    start_date_active	         DATE,
    end_date_active	         DATE
    );

--------------------------------------
-- declaration of public procedures and functions
--------------------------------------

/**
 * PROCEDURE create_style_fmt_layout
 *
 * DESCRIPTION
 *     Creates style_fmt_layout.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_style_fmt_layout_rec                    Style record.
 *   IN/OUT:
 *   OUT:
 *     p_style_fmt_layout_id          style_fmt_layout id
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

PROCEDURE create_style_fmt_layout (
    p_init_msg_list              IN      VARCHAR2 := FND_API.G_FALSE,
    p_style_fmt_layout_rec       IN      STYLE_FMT_LAYOUT_REC_TYPE,
    x_style_fmt_layout_id        OUT NOCOPY     NUMBER,
    x_return_status              OUT NOCOPY     VARCHAR2,
    x_msg_count                  OUT NOCOPY     NUMBER,
    x_msg_data                   OUT NOCOPY     VARCHAR2
);

/**
 * PROCEDURE update_style_fmt_layout
 *
 * DESCRIPTION
 *     Updates style_fmt_layout.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_style_fmt_layout_rec                 Style record.
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

PROCEDURE update_style_fmt_layout  (
    p_init_msg_list              IN      VARCHAR2 :=FND_API.G_FALSE,
    p_style_fmt_layout_rec       IN      STYLE_FMT_LAYOUT_REC_TYPE,
    p_object_version_number      IN OUT NOCOPY  NUMBER,
    x_return_status              OUT NOCOPY     VARCHAR2,
    x_msg_count                  OUT NOCOPY     NUMBER,
    x_msg_data                   OUT NOCOPY     VARCHAR2
);


/**
 * PROCEDURE get_style_fmt_layout_rec
 *
 * DESCRIPTION
 *     Gets style_fmt_layout record.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_style_fmt_layout_code                   Style Code.
 *   IN/OUT:
 *   OUT:
 *     x_style_fmt_layout_rec                 Style record.
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

PROCEDURE get_style_fmt_layout_rec (
    p_init_msg_list            IN         VARCHAR2 := FND_API.G_FALSE,
    p_style_fmt_layout_id      IN         NUMBER,
    x_style_fmt_layout_rec     OUT NOCOPY STYLE_FMT_LAYOUT_REC_TYPE,
    x_return_status            OUT NOCOPY        VARCHAR2,
    x_msg_count                OUT NOCOPY        NUMBER,
    x_msg_data                 OUT NOCOPY        VARCHAR2
);

END HZ_STYLE_FMT_LAYOUT_V2PUB;

 

/
