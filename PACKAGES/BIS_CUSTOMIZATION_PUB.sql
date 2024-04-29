--------------------------------------------------------
--  DDL for Package BIS_CUSTOMIZATION_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_CUSTOMIZATION_PUB" AUTHID CURRENT_USER AS
/* $Header: BISPCSTS.pls 120.1 2006/02/14 13:25:57 hengliu noship $ */
-- dbdrv: sql ~PROD ~PATH ~FILE none none none package &phase=pls \
-- dbdrv: checkfile(115.1=120.1):~PROD:~PATH:~FILE

/*
REM +=======================================================================+
REM |    Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA     |
REM |                         All rights reserved.                          |
REM +=======================================================================+
REM | FILENAME                                                              |
REM |     BISPCSTS.pls                                                      |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |     Public API for shipping ak customizations at function level       |
REM |                                                                       |
REM | NOTES                                                                 |
REM |                                                                       |
REM | HISTORY                                                               |
REM | 27-Apr-2005 kyadamak Creation                                         |
REM | 14-Feb-2006 hengliu  Added Delete_Custom_Region_Items                 |
REM +=======================================================================+
*/
--

TYPE custom_region_items_type IS RECORD
( customization_application_id  ak_custom_region_items.customization_application_id%TYPE
, customization_code            ak_custom_region_items.customization_code%TYPE
, region_application_id         ak_custom_region_items.region_application_id%TYPE
, region_code                   ak_custom_region_items.region_code%TYPE
, attribute_application_id      ak_custom_region_items.attribute_application_id%TYPE
, attribute_code                ak_custom_region_items.attribute_code%TYPE
, property_name                 ak_custom_region_items.property_name%TYPE
, property_varchar2_value       ak_custom_region_items.property_varchar2_value%TYPE
, property_number_value         ak_custom_region_items.property_number_value%TYPE
, property_date_value           ak_custom_region_items.property_date_value%TYPE
, language                      ak_custom_region_items_tl.language%TYPE
, source_lang                   ak_custom_region_items_tl.source_lang%TYPE
, created_by                    ak_custom_region_items_tl.created_by%TYPE
, creation_date                 ak_custom_region_items_tl.creation_date%TYPE
, last_updated_by               ak_custom_region_items_tl.last_updated_by%TYPE
, last_update_date              ak_custom_region_items_tl.last_update_date%TYPE
, last_update_login             ak_custom_region_items_tl.last_update_login%TYPE
);

TYPE customizations_type IS RECORD
( customization_application_id  ak_customizations.customization_application_id%TYPE
, customization_code            ak_customizations.customization_code%TYPE
, region_application_id         ak_customizations.region_application_id%TYPE
, region_code                   ak_customizations.region_code%TYPE
, verticalization_id            ak_customizations.verticalization_id%TYPE
, localization_code             ak_customizations.localization_code%TYPE
, org_id                        ak_customizations.org_id%TYPE
, site_id                       ak_customizations.site_id%TYPE
, responsibility_id             ak_customizations.responsibility_id%TYPE
, web_user_id                   ak_customizations.web_user_id%TYPE
, default_customization_flag    ak_customizations.default_customization_flag%TYPE
, customization_level_id        ak_customizations.customization_level_id%TYPE
, start_date_active             ak_customizations.start_date_active%TYPE
, end_date_active               ak_customizations.end_date_active%TYPE
, reference_path                ak_customizations.reference_path%TYPE
, function_name                 ak_customizations.function_name%TYPE
, developer_mode                ak_customizations.developer_mode%TYPE
, name                          ak_customizations_tl.name%TYPE
, description                   ak_customizations_tl.description%TYPE
, language                      ak_custom_region_items_tl.language%TYPE
, source_lang                   ak_custom_region_items_tl.source_lang%TYPE
, created_by                    ak_custom_region_items_tl.created_by%TYPE
, creation_date                 ak_custom_region_items_tl.creation_date%TYPE
, last_updated_by               ak_custom_region_items_tl.last_updated_by%TYPE
, last_update_date              ak_custom_region_items_tl.last_update_date%TYPE
, last_update_login             ak_custom_region_items_tl.last_update_login%TYPE
);


-- PROCEDUREs
--
-- creates rows into ak_custom_region_items and tl tables
--
PROCEDURE Create_Custom_Region_Items
( p_api_version              IN  NUMBER
, p_commit                   IN  VARCHAR2  := FND_API.G_FALSE
, p_Custom_region_items_Rec  IN  BIS_CUSTOMIZATION_PUB.custom_region_items_type
, x_return_status            OUT NOCOPY  VARCHAR2
, x_msg_count                OUT NOCOPY  NUMBER
, x_msg_data                 OUT NOCOPY  VARCHAR2
);
--
--
-- updates rows into ak_custom_region_items and tl tables
--
PROCEDURE Update_Custom_Region_Items
( p_api_version              IN  NUMBER
, p_commit                   IN  VARCHAR2  := FND_API.G_FALSE
, p_Custom_region_items_Rec  IN  BIS_CUSTOMIZATION_PUB.custom_region_items_type
, x_return_status            OUT NOCOPY  VARCHAR2
, x_msg_count                OUT NOCOPY  NUMBER
, x_msg_data                 OUT NOCOPY  VARCHAR2
);
--
--
-- delete row in ak_custom_region_items and tl tables
--
PROCEDURE Delete_Custom_Region_Items
( p_api_version              IN   NUMBER
, p_commit                   IN   VARCHAR2 := FND_API.G_FALSE
, p_Custom_region_items_Rec  IN   BIS_CUSTOMIZATION_PUB.custom_region_items_type
, x_return_status           OUT NOCOPY VARCHAR2
, x_msg_count               OUT NOCOPY NUMBER
, x_msg_data                OUT NOCOPY VARCHAR2
);
--
--
PROCEDURE Update_Customizations
( p_api_version         IN  NUMBER
, p_commit              IN  VARCHAR2   := FND_API.G_FALSE
, p_Customizations_Rec  IN  BIS_CUSTOMIZATION_PUB.customizations_type
, x_return_status       OUT NOCOPY  VARCHAR2
, x_msg_count           OUT NOCOPY  NUMBER
, x_msg_data            OUT NOCOPY  VARCHAR2
);
--
--
-- creates rows into ak_custom_regions and tl tables
--
PROCEDURE Create_Customizations
( p_api_version         IN  NUMBER
, p_commit              IN  VARCHAR2   := FND_API.G_FALSE
, p_Customizations_Rec  IN  BIS_CUSTOMIZATION_PUB.customizations_type
, x_return_status       OUT NOCOPY  VARCHAR2
, x_msg_count           OUT NOCOPY  NUMBER
, x_msg_data            OUT NOCOPY  VARCHAR2
);

PROCEDURE Create_Customizations_UI
( p_api_version                   IN  NUMBER
, p_commit                        IN  VARCHAR2  := FND_API.G_FALSE
, p_customization_application_id  IN  NUMBER
, p_customization_code            IN  VARCHAR2
, p_region_application_id         IN  NUMBER
, p_region_code                   IN  VARCHAR2
, p_verticalization_id            IN  VARCHAR2
, p_localization_code             IN  VARCHAR2
, p_org_id                        IN  NUMBER
, p_site_id                       IN  NUMBER
, p_responsibility_id             IN  NUMBER
, p_web_user_id                   IN  NUMBER
, p_default_customization_flag    IN  VARCHAR2
, p_customization_level_id        IN  NUMBER
, p_start_date_active             IN  DATE
, p_end_date_active               IN  DATE
, p_reference_path                IN  VARCHAR2
, p_function_name                 IN  VARCHAR2
, p_developer_mode                IN  VARCHAR2
, p_name                          IN  VARCHAR2
, p_description                   IN  VARCHAR2
, x_return_status                 OUT NOCOPY VARCHAR2
, x_msg_count                     OUT NOCOPY NUMBER
, x_msg_data                      OUT NOCOPY VARCHAR2
);

PROCEDURE Update_Customizations_UI
( p_api_version                   IN  NUMBER
, p_commit                        IN  VARCHAR2  := FND_API.G_FALSE
, p_customization_application_id  IN  NUMBER
, p_customization_code            IN  VARCHAR2
, p_region_application_id         IN  NUMBER
, p_region_code                   IN  VARCHAR2
, p_verticalization_id            IN  VARCHAR2
, p_localization_code             IN  VARCHAR2
, p_org_id                        IN  NUMBER
, p_site_id                       IN  NUMBER
, p_responsibility_id             IN  NUMBER
, p_web_user_id                   IN  NUMBER
, p_default_customization_flag    IN  VARCHAR2
, p_customization_level_id        IN  NUMBER
, p_start_date_active             IN  DATE
, p_end_date_active               IN  DATE
, p_reference_path                IN  VARCHAR2
, p_function_name                 IN  VARCHAR2
, p_developer_mode                IN  VARCHAR2
, p_name                          IN  VARCHAR2
, p_description                   IN  VARCHAR2
, x_return_status                 OUT NOCOPY VARCHAR2
, x_msg_count                     OUT NOCOPY NUMBER
, x_msg_data                      OUT NOCOPY VARCHAR2
);


PROCEDURE Create_Custom_Region_Items_UI
( p_api_version                   IN  NUMBER
, p_commit                        IN  VARCHAR2   := FND_API.G_FALSE
, p_customization_application_id  IN  NUMBER
, p_customization_code            IN  VARCHAR2
, p_region_application_id         IN  NUMBER
, p_region_code                   IN  VARCHAR2
, p_attribute_application_id      IN  NUMBER
, p_attribute_code                IN  VARCHAR2
, p_property_name                 IN  VARCHAR2
, p_property_varchar2_value       IN  VARCHAR2
, p_property_number_value         IN  NUMBER
, p_property_date_value           IN  DATE
, x_return_status                 OUT NOCOPY VARCHAR2
, x_msg_count                     OUT NOCOPY NUMBER
, x_msg_data                      OUT NOCOPY VARCHAR2
);
--
--
-- updates rows into ak_custom_region_items and tl tables
--
PROCEDURE Update_Custom_Region_Items_UI
( p_api_version                   IN  NUMBER
, p_commit                        IN  VARCHAR2   := FND_API.G_FALSE
, p_customization_application_id  IN  NUMBER
, p_customization_code            IN  VARCHAR2
, p_region_application_id         IN  NUMBER
, p_region_code                   IN  VARCHAR2
, p_attribute_application_id      IN  NUMBER
, p_attribute_code                IN  VARCHAR2
, p_property_name                 IN  VARCHAR2
, p_property_varchar2_value       IN  VARCHAR2
, p_property_number_value         IN  NUMBER
, p_property_date_value           IN  DATE
, x_return_status                 OUT NOCOPY VARCHAR2
, x_msg_count                     OUT NOCOPY NUMBER
, x_msg_data                      OUT NOCOPY VARCHAR2
);
--
-- delete rows from ak_custom_region_items and tl tables
--
PROCEDURE Delete_Custom_Region_Items_UI
( p_api_version                   IN  NUMBER
, p_commit                        IN  VARCHAR2   := FND_API.G_FALSE
, p_customization_application_id  IN  NUMBER
, p_customization_code            IN  VARCHAR2
, p_region_application_id         IN  NUMBER
, p_region_code                   IN  VARCHAR2
, p_attribute_application_id      IN  NUMBER
, p_attribute_code                IN  VARCHAR2
, p_property_name                 IN  VARCHAR2
, x_return_status                 OUT NOCOPY VARCHAR2
, x_msg_count                     OUT NOCOPY NUMBER
, x_msg_data                      OUT NOCOPY VARCHAR2
);

END BIS_CUSTOMIZATION_PUB;

 

/
