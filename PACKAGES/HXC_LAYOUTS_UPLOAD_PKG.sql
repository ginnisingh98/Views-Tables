--------------------------------------------------------
--  DDL for Package HXC_LAYOUTS_UPLOAD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_LAYOUTS_UPLOAD_PKG" AUTHID CURRENT_USER AS
/* $Header: hxculaupl.pkh 115.6 2004/05/13 03:00:24 dragarwa noship $ */

-- global variable
   g_force_ok   BOOLEAN;

   PROCEDURE load_layout_row(
      p_layout_name              IN   VARCHAR2,
      p_application_short_name   IN   VARCHAR2,
      p_owner                    IN   VARCHAR2,
      p_display_layout_name      IN   VARCHAR2,
      p_layout_type              IN   VARCHAR2,
      p_modifier_level           IN   VARCHAR2 DEFAULT NULL,
      p_modifier_value           IN   VARCHAR2 DEFAULT NULL,
      p_top_level_region_code    IN   VARCHAR2 DEFAULT NULL,
      p_custom_mode              IN   VARCHAR2 DEFAULT NULL,
      p_last_update_date         IN   VARCHAR2
   );

   PROCEDURE translate_layout_row(
      p_application_short_name   IN   VARCHAR2,
      p_layout_name              IN   VARCHAR2,
      p_owner                    IN   VARCHAR2,
      p_display_layout_name      IN   VARCHAR2,
      p_custom_mode              IN   VARCHAR2 DEFAULT NULL,
      p_last_update_date         IN   VARCHAR2
   );

   PROCEDURE load_definition_row(
      p_component_type     IN   VARCHAR2,
      p_owner              IN   VARCHAR2,
      p_component_class    IN   VARCHAR2,
      p_render_type        IN   VARCHAR2,
      p_custom_mode        IN   VARCHAR2 DEFAULT NULL,
      p_last_update_date   IN   VARCHAR2
   );

   PROCEDURE load_component_row(
      p_layout_name                  IN   VARCHAR2,
      p_component_name               IN   VARCHAR2,
      p_owner                        IN   VARCHAR2,
      p_component_value              IN   VARCHAR2,
      p_region_code                  IN   VARCHAR2,
      p_region_code_app_short_name   IN   VARCHAR2,
      p_attribute_code               IN   VARCHAR2,
      p_attribute_code_app_short_n   IN   VARCHAR2,
      p_name_value_string            IN   VARCHAR2,
      p_sequence                     IN   NUMBER,
      p_component_definition         IN   VARCHAR2,
      p_render_type                  IN   VARCHAR2,
      p_parent_component             IN   VARCHAR2,
      p_component_alias              IN   VARCHAR2,
      p_parent_bean                  IN   VARCHAR2,
      p_attribute1                   IN   VARCHAR2,
      p_attribute2                   IN   VARCHAR2,
      p_attribute3                   IN   VARCHAR2,
      p_attribute4                   IN   VARCHAR2,
      p_attribute5                   IN   VARCHAR2,
      p_custom_mode                  IN   VARCHAR2 DEFAULT NULL,
      p_last_update_date             IN   VARCHAR2
   );

   PROCEDURE load_prompt_row(
      p_component_name             IN   VARCHAR2,
      p_prompt_alias               IN   VARCHAR2,
      p_prompt_type                IN   VARCHAR2,
      p_owner                      IN   VARCHAR2,
      p_region_code                IN   VARCHAR2,
      p_region_app_short_name      IN   VARCHAR2,
      p_attribute_code             IN   VARCHAR2,
      p_attribute_app_short_name   IN   VARCHAR2,
      p_layout_name                IN   VARCHAR2,
      p_custom_mode                IN   VARCHAR2 DEFAULT NULL,
      p_last_update_date           IN   VARCHAR2
   );

   PROCEDURE load_qualifier_row(
      p_component_name                 IN   VARCHAR2,
      p_qualifier_name                 IN   VARCHAR2,
      p_owner                          IN   VARCHAR2,
      p_qualifier_attribute_category   IN   VARCHAR2,
      p_qualifier_attribute1           IN   VARCHAR2,
      p_qualifier_attribute2           IN   VARCHAR2,
      p_qualifier_attribute3           IN   VARCHAR2,
      p_qualifier_attribute4           IN   VARCHAR2,
      p_qualifier_attribute5           IN   VARCHAR2,
      p_qualifier_attribute6           IN   VARCHAR2,
      p_qualifier_attribute7           IN   VARCHAR2,
      p_qualifier_attribute8           IN   VARCHAR2,
      p_qualifier_attribute9           IN   VARCHAR2,
      p_qualifier_attribute10          IN   VARCHAR2,
      p_qualifier_attribute11          IN   VARCHAR2,
      p_qualifier_attribute12          IN   VARCHAR2,
      p_qualifier_attribute13          IN   VARCHAR2,
      p_qualifier_attribute14          IN   VARCHAR2,
      p_qualifier_attribute15          IN   VARCHAR2,
      p_qualifier_attribute16          IN   VARCHAR2,
      p_qualifier_attribute17          IN   VARCHAR2,
      p_qualifier_attribute18          IN   VARCHAR2,
      p_qualifier_attribute19          IN   VARCHAR2,
      p_qualifier_attribute20          IN   VARCHAR2,
      p_qualifier_attribute21          IN   VARCHAR2,
      p_qualifier_attribute22          IN   VARCHAR2,
      p_qualifier_attribute23          IN   VARCHAR2,
      p_qualifier_attribute24          IN   VARCHAR2,
      p_qualifier_attribute25          IN   VARCHAR2,
      p_qualifier_attribute26          IN   VARCHAR2,
      p_qualifier_attribute27          IN   VARCHAR2,
      p_qualifier_attribute28          IN   VARCHAR2,
      p_qualifier_attribute29          IN   VARCHAR2,
      p_qualifier_attribute30          IN   VARCHAR2,
      p_layout_name                    IN   VARCHAR2,
      p_custom_mode                    IN   VARCHAR2 DEFAULT NULL,
      p_last_update_date               IN   VARCHAR2
   );

   PROCEDURE LOAD_LAYOUT_ROW
   (P_LAYOUT_NAME             IN VARCHAR2
   ,P_APPLICATION_SHORT_NAME  IN VARCHAR2
   ,P_OWNER                   IN VARCHAR2
   ,P_DISPLAY_LAYOUT_NAME     IN VARCHAR2
   ,P_LAYOUT_TYPE             IN VARCHAR2
   ,P_MODIFIER_LEVEL          IN VARCHAR2 DEFAULT NULL
   ,P_MODIFIER_VALUE          IN VARCHAR2 DEFAULT NULL
   ,P_TOP_LEVEL_REGION_CODE   IN VARCHAR2 DEFAULT NULL
   ,P_CUSTOM_MODE             IN VARCHAR2 DEFAULT NULL
   );

PROCEDURE TRANSLATE_LAYOUT_ROW
   (P_APPLICATION_SHORT_NAME  IN VARCHAR2
   ,P_LAYOUT_NAME             IN VARCHAR2
   ,P_OWNER                   IN VARCHAR2
   ,P_DISPLAY_LAYOUT_NAME     IN VARCHAR2
   ,P_CUSTOM_MODE             IN VARCHAR2 DEFAULT NULL
   );

PROCEDURE LOAD_DEFINITION_ROW
   (P_COMPONENT_TYPE    IN VARCHAR2
   ,P_OWNER             IN VARCHAR2
   ,P_COMPONENT_CLASS   IN VARCHAR2
   ,P_RENDER_TYPE       IN VARCHAR2
   ,P_CUSTOM_MODE       IN VARCHAR2 DEFAULT NULL
   );

PROCEDURE LOAD_COMPONENT_ROW
   (P_LAYOUT_NAME                    IN VARCHAR2
   ,P_COMPONENT_NAME                 IN VARCHAR2
   ,P_OWNER                          IN VARCHAR2
   ,P_COMPONENT_VALUE                IN VARCHAR2
   ,P_REGION_CODE                    IN VARCHAR2
   ,P_REGION_CODE_APP_SHORT_NAME     IN VARCHAR2
   ,P_ATTRIBUTE_CODE                 IN VARCHAR2
   ,P_ATTRIBUTE_CODE_APP_SHORT_N     IN VARCHAR2
   ,P_NAME_VALUE_STRING              IN VARCHAR2
   ,P_SEQUENCE                       IN NUMBER
   ,P_COMPONENT_DEFINITION           IN VARCHAR2
   ,P_RENDER_TYPE                    IN VARCHAR2
   ,P_PARENT_COMPONENT               IN VARCHAR2
   ,P_COMPONENT_ALIAS                IN VARCHAR2
   ,P_PARENT_BEAN                    IN VARCHAR2
   ,P_ATTRIBUTE1                     IN VARCHAR2
   ,P_ATTRIBUTE2                     IN VARCHAR2
   ,P_ATTRIBUTE3                     IN VARCHAR2
   ,P_ATTRIBUTE4                     IN VARCHAR2
   ,P_ATTRIBUTE5                     IN VARCHAR2
   ,P_CUSTOM_MODE                    IN VARCHAR2 DEFAULT NULL
   );

PROCEDURE LOAD_PROMPT_ROW
   (P_COMPONENT_NAME               IN VARCHAR2
   ,P_PROMPT_ALIAS                 IN VARCHAR2
   ,P_PROMPT_TYPE                  IN VARCHAR2
   ,P_OWNER                        IN VARCHAR2
   ,P_REGION_CODE                  IN VARCHAR2
   ,P_REGION_APP_SHORT_NAME        IN VARCHAR2
   ,P_ATTRIBUTE_CODE               IN VARCHAR2
   ,P_ATTRIBUTE_APP_SHORT_NAME     IN VARCHAR2
   ,p_layout_name                  IN VARCHAR2
   ,P_CUSTOM_MODE                  IN VARCHAR2 DEFAULT NULL
   );

PROCEDURE LOAD_QUALIFIER_ROW
   (P_COMPONENT_NAME               IN VARCHAR2
   ,P_QUALIFIER_NAME               IN VARCHAR2
   ,P_OWNER                        IN VARCHAR2
   ,P_QUALIFIER_ATTRIBUTE_CATEGORY IN VARCHAR2
   ,P_QUALIFIER_ATTRIBUTE1         IN VARCHAR2
   ,P_QUALIFIER_ATTRIBUTE2         IN VARCHAR2
   ,P_QUALIFIER_ATTRIBUTE3         IN VARCHAR2
   ,P_QUALIFIER_ATTRIBUTE4         IN VARCHAR2
   ,P_QUALIFIER_ATTRIBUTE5         IN VARCHAR2
   ,P_QUALIFIER_ATTRIBUTE6         IN VARCHAR2
   ,P_QUALIFIER_ATTRIBUTE7         IN VARCHAR2
   ,P_QUALIFIER_ATTRIBUTE8         IN VARCHAR2
   ,P_QUALIFIER_ATTRIBUTE9         IN VARCHAR2
   ,P_QUALIFIER_ATTRIBUTE10        IN VARCHAR2
   ,P_QUALIFIER_ATTRIBUTE11        IN VARCHAR2
   ,P_QUALIFIER_ATTRIBUTE12        IN VARCHAR2
   ,P_QUALIFIER_ATTRIBUTE13        IN VARCHAR2
   ,P_QUALIFIER_ATTRIBUTE14        IN VARCHAR2
   ,P_QUALIFIER_ATTRIBUTE15        IN VARCHAR2
   ,P_QUALIFIER_ATTRIBUTE16        IN VARCHAR2
   ,P_QUALIFIER_ATTRIBUTE17        IN VARCHAR2
   ,P_QUALIFIER_ATTRIBUTE18        IN VARCHAR2
   ,P_QUALIFIER_ATTRIBUTE19        IN VARCHAR2
   ,P_QUALIFIER_ATTRIBUTE20        IN VARCHAR2
   ,P_QUALIFIER_ATTRIBUTE21        IN VARCHAR2
   ,P_QUALIFIER_ATTRIBUTE22        IN VARCHAR2
   ,P_QUALIFIER_ATTRIBUTE23        IN VARCHAR2
   ,P_QUALIFIER_ATTRIBUTE24        IN VARCHAR2
   ,P_QUALIFIER_ATTRIBUTE25        IN VARCHAR2
   ,P_QUALIFIER_ATTRIBUTE26        IN VARCHAR2
   ,P_QUALIFIER_ATTRIBUTE27        IN VARCHAR2
   ,P_QUALIFIER_ATTRIBUTE28        IN VARCHAR2
   ,P_QUALIFIER_ATTRIBUTE29        IN VARCHAR2
   ,P_QUALIFIER_ATTRIBUTE30        IN VARCHAR2
   ,p_layout_name                  IN VARCHAR2
   ,P_CUSTOM_MODE                  IN VARCHAR2 DEFAULT NULL
   );
/*
PROCEDURE LOAD_RULE_ROW
   (P_QUALIFIER_NAME IN VARCHAR2
   ,P_RULE_NAME      IN VARCHAR2
   ,P_OWNER          IN VARCHAR2
   ,P_RULE_TYPE      IN VARCHAR2
   ,P_RULE_DETAIL    IN VARCHAR2
   ,P_RULE_VALUE     IN VARCHAR2
   ,P_CUSTOM_MODE    IN VARCHAR2 DEFAULT NULL
   );
*/
END hxc_layouts_upload_pkg;

 

/
