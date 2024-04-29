--------------------------------------------------------
--  DDL for Package ENG_IMPL_ITEM_CHANGES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ENG_IMPL_ITEM_CHANGES_PKG" AUTHID CURRENT_USER AS
/* $Header: ENGITMIS.pls 120.3 2005/10/23 14:07:20 mkimizuk ship $ */


---------------------------------------
-- Package Name
---------------------------------------
G_PKG_NAME  CONSTANT VARCHAR2(30):='ENG_IMPL_ITEM_CHANGES_PKG';


PROCEDURE impl_item_changes
(   p_api_version       IN  NUMBER
 ,  p_init_msg_list     IN  VARCHAR2 := NULL -- FND_API.G_FALSE
 ,  p_commit            IN  VARCHAR2 := NULL -- FND_API.G_FALSE
 ,  p_validation_level  IN  NUMBER   := NULL -- FND_API.G_VALID_LEVEL_FULL
 ,  x_return_status     OUT NOCOPY VARCHAR2
 ,  x_msg_count         OUT NOCOPY NUMBER
 ,  x_msg_data          OUT NOCOPY VARCHAR2
 ,  p_api_caller        IN  VARCHAR2  := NULL
 ,  p_debug             IN  VARCHAR2  := NULL -- FND_API.G_FALSE
 ,  p_output_dir        IN  VARCHAR2  := NULL
 ,  p_debug_filename    IN  VARCHAR2  := NULL
 ,  p_change_id         IN  NUMBER    := NULL
 ,  p_change_line_id    IN  NUMBER
);


PROCEDURE impl_rev_item_attr_changes
(   p_api_version       IN  NUMBER
 ,  p_init_msg_list     IN  VARCHAR2 := NULL -- FND_API.G_FALSE
 ,  p_commit            IN  VARCHAR2 := NULL -- FND_API.G_FALSE
 ,  p_validation_level  IN  NUMBER   := NULL -- FND_API.G_VALID_LEVEL_FULL
 ,  x_return_status     OUT NOCOPY VARCHAR2
 ,  x_msg_count         OUT NOCOPY NUMBER
 ,  x_msg_data          OUT NOCOPY VARCHAR2
 ,  p_api_caller        IN  VARCHAR2  := NULL
 ,  p_debug             IN  VARCHAR2  := NULL -- FND_API.G_FALSE
 ,  p_output_dir        IN  VARCHAR2  := NULL
 ,  p_debug_filename    IN  VARCHAR2  := NULL
 ,  p_change_id         IN  NUMBER    := NULL
 ,  p_change_line_id    IN  NUMBER
);

PROCEDURE impl_rev_item_gdsn_attr_chgs
(   p_api_version       IN  NUMBER
 ,  p_init_msg_list     IN  VARCHAR2 := NULL -- FND_API.G_FALSE
 ,  p_commit            IN  VARCHAR2 := NULL -- FND_API.G_FALSE
 ,  p_validation_level  IN  NUMBER   := NULL -- FND_API.G_VALID_LEVEL_FULL
 ,  x_return_status     OUT NOCOPY VARCHAR2
 ,  x_msg_count         OUT NOCOPY NUMBER
 ,  x_msg_data          OUT NOCOPY VARCHAR2
 ,  p_api_caller        IN  VARCHAR2  := NULL
 ,  p_debug             IN  VARCHAR2  := NULL -- FND_API.G_FALSE
 ,  p_output_dir        IN  VARCHAR2  := NULL
 ,  p_debug_filename    IN  VARCHAR2  := NULL
 ,  p_change_id         IN  NUMBER    := NULL
 ,  p_change_line_id    IN  NUMBER
);


PROCEDURE impl_rev_item_user_attr_chgs
(   p_api_version       IN  NUMBER
 ,  p_init_msg_list     IN  VARCHAR2 := NULL -- FND_API.G_FALSE
 ,  p_commit            IN  VARCHAR2 := NULL -- FND_API.G_FALSE
 ,  p_validation_level  IN  NUMBER   := NULL -- FND_API.G_VALID_LEVEL_FULL
 ,  x_return_status     OUT NOCOPY VARCHAR2
 ,  x_msg_count         OUT NOCOPY NUMBER
 ,  x_msg_data          OUT NOCOPY VARCHAR2
 ,  p_api_caller        IN  VARCHAR2  := NULL
 ,  p_debug             IN  VARCHAR2  := NULL -- FND_API.G_FALSE
 ,  p_output_dir        IN  VARCHAR2  := NULL
 ,  p_debug_filename    IN  VARCHAR2  := NULL
 ,  p_change_id         IN  NUMBER    := NULL
 ,  p_change_line_id    IN  NUMBER
);


PROCEDURE impl_rev_item_aml_changes
(   p_api_version       IN  NUMBER
 ,  p_init_msg_list     IN  VARCHAR2 := NULL -- FND_API.G_FALSE
 ,  p_commit            IN  VARCHAR2 := NULL -- FND_API.G_FALSE
 ,  p_validation_level  IN  NUMBER   := NULL -- FND_API.G_VALID_LEVEL_FULL
 ,  x_return_status     OUT NOCOPY VARCHAR2
 ,  x_msg_count         OUT NOCOPY NUMBER
 ,  x_msg_data          OUT NOCOPY VARCHAR2
 ,  p_api_caller        IN  VARCHAR2  := NULL
 ,  p_debug             IN  VARCHAR2  := NULL -- FND_API.G_FALSE
 ,  p_output_dir        IN  VARCHAR2  := NULL
 ,  p_debug_filename    IN  VARCHAR2  := NULL
 ,  p_change_id         IN  NUMBER    := NULL
 ,  p_change_line_id    IN  NUMBER
);



END ENG_IMPL_ITEM_CHANGES_PKG;

 

/
