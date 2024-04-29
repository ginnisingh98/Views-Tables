--------------------------------------------------------
--  DDL for Package Body HXC_LAYOUTS_UPLOAD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_LAYOUTS_UPLOAD_PKG" AS
/* $Header: hxculaupl.pkb 120.2 2005/09/23 09:47:53 rchennur noship $ */

glb_debug           VARCHAR2(32000) := NULL;
l_modifier_level  hxc_layouts.modifier_level%TYPE;
g_debug boolean :=hr_utility.debug_enabled;

-- =================================================================
-- == find_application_id
-- =================================================================
FUNCTION find_application_id
   (p_application_short_name IN VARCHAR2
   )
RETURN fnd_application.application_id%TYPE
IS
--
l_appl_id fnd_application.application_id%TYPE;
--
BEGIN
   --
   IF p_application_short_name IS NULL THEN
      l_appl_id := NULL;
   ELSE
      SELECT application_id
        INTO l_appl_id
        FROM fnd_application
       WHERE application_short_name = P_APPLICATION_SHORT_NAME;
   END IF;
   --
   RETURN l_appl_id;
   --
EXCEPTION
  WHEN NO_DATA_FOUND then
    FND_MESSAGE.SET_NAME('HXC','HXC_xxxxx_INVALID_APPL_NAME');
    FND_MESSAGE.RAISE_ERROR;
END find_application_id;

-- =================================================================
-- == find_layout_id
-- =================================================================
FUNCTION find_layout_id
   (p_layout_name IN VARCHAR2
   )
RETURN hxc_layouts.layout_id%TYPE
IS
--
l_layout_id HXC_LAYOUTS.LAYOUT_ID%TYPE;
--
BEGIN
   SELECT layout_id
     INTO l_layout_id
     FROM hxc_layouts
    WHERE layout_name = p_layout_name;
   --
   RETURN l_layout_id;
   --
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    FND_MESSAGE.SET_NAME('HXC','HXC_xxxxx_INVALID_LAYOUT');
    FND_MESSAGE.RAISE_ERROR;
END find_layout_id;

-- =================================================================
-- == find_component_definition_id
-- =================================================================
FUNCTION find_component_definition_id
   (p_component_type IN VARCHAR2
   ,p_render_type    IN VARCHAR2
   )
RETURN hxc_layout_comp_definitions.layout_comp_definition_id%TYPE
IS
--
l_layout_comp_definition_id   hxc_layout_comp_definitions.layout_comp_definition_id%TYPE;
--
BEGIN
   --
   SELECT layout_comp_definition_id
     INTO l_layout_comp_definition_id
     FROM hxc_layout_comp_definitions
    WHERE component_type = p_component_type
      AND render_type = p_render_type;
   --
   RETURN l_layout_comp_definition_id;
   --
EXCEPTION
  WHEN NO_DATA_FOUND then
    FND_MESSAGE.SET_NAME('HXC','HXC_xxxxx_INVALID_DEFINITION');
    FND_MESSAGE.RAISE_ERROR;
END find_component_definition_id;

-- =================================================================
-- == find_component_id
-- =================================================================
FUNCTION find_component_id
   (p_component_name    IN VARCHAR2
   ,p_layout_name       IN VARCHAR2
   )
RETURN hxc_layout_components.layout_component_id%TYPE
IS
--
l_layout_component_id   hxc_layout_components.layout_component_id%TYPE;
--
BEGIN
   --
   IF p_component_name IS NULL THEN
      l_layout_component_id := NULL;
   ELSE
      SELECT layout_component_id
        INTO l_layout_component_id
        FROM hxc_layout_components comp
            ,hxc_layouts lay
       WHERE component_name = p_component_name
         AND comp.layout_id = lay.layout_id
         AND lay.layout_name = p_layout_name;
   END IF;
   --
   RETURN l_layout_component_id;
   --
EXCEPTION
  WHEN NO_DATA_FOUND then
    FND_MESSAGE.SET_NAME('HXC','HXC_xxxxx_INVALID_COMPONENT');
    FND_MESSAGE.SET_TOKEN('COMPONENT_NAME',glb_debug);
    FND_MESSAGE.RAISE_ERROR;
END find_component_id;

-- =================================================================
-- == find_comp_qualifier_id
-- =================================================================
FUNCTION find_comp_qualifier_id
   (p_comp_qualifier_name IN VARCHAR2
   ,p_layout_component_id IN hxc_layout_comp_qualifiers.layout_component_id%TYPE
   )
RETURN hxc_layout_comp_qualifiers.layout_comp_qualifier_id%TYPE
IS
--
l_layout_comp_qualifier_id    hxc_layout_comp_qualifiers.layout_comp_qualifier_id%TYPE;
--
BEGIN
   --
   SELECT layout_comp_qualifier_id
     INTO l_layout_comp_qualifier_id
     FROM hxc_layout_comp_qualifiers
    WHERE qualifier_name = p_comp_qualifier_name
      AND layout_component_id = p_layout_component_id;
   --
   RETURN l_layout_comp_qualifier_id;
   --
EXCEPTION
  WHEN NO_DATA_FOUND then
    FND_MESSAGE.SET_NAME('HXC','HXC_xxxxx_INVALID_QUALIFIER');
    FND_MESSAGE.RAISE_ERROR;
END find_comp_qualifier_id;

-- =================================================================
-- == load_layout_row
-- =================================================================
PROCEDURE load_layout_row
   (p_layout_name             IN VARCHAR2
   ,p_application_short_name  IN VARCHAR2
   ,p_owner                   IN VARCHAR2
   ,p_display_layout_name     IN VARCHAR2
   ,p_layout_type             IN VARCHAR2
   ,p_modifier_level          IN VARCHAR2 DEFAULT NULL
   ,p_modifier_value          IN VARCHAR2 DEFAULT NULL
   ,p_top_level_region_code   IN VARCHAR2 DEFAULT NULL
   ,p_custom_mode             IN VARCHAR2 DEFAULT NULL
   )
IS
--
l_layout_id                HXC_LAYOUTS.LAYOUT_ID%TYPE;
l_object_version_number    HXC_LAYOUTS.OBJECT_VERSION_NUMBER%TYPE;
l_application_id           FND_APPLICATION.APPLICATION_ID%TYPE;
l_dummy varchar2(3);

CURSOR C_DISPLAY_NAME(p_layout_id IN NUMBER)
	IS

       SELECT 'yes'
              FROM dual
             WHERE EXISTS (SELECT 'x'
                             FROM hxc_layouts_tl
                            WHERE layout_id   = p_layout_id
                            and DISPLAY_LAYOUT_NAME <> P_DISPLAY_LAYOUT_NAME  --added
                              AND userenv('LANG') in ( language, source_lang )
                     );

BEGIN
   --
   g_debug :=hr_utility.debug_enabled;
   if g_debug then
   	hr_utility.set_location('Entering Load Layout Row ', 10);
   end if;
   --
   -- Find the application id
   --
   l_application_id :=
      find_application_id
         (P_APPLICATION_SHORT_NAME => P_APPLICATION_SHORT_NAME
         );
   --
   BEGIN
      if g_debug then
      	    hr_utility.set_location('In Load Layout Row ', 20);
      end if;
      --
      -- check to see row exists
      --
      SELECT modifier_level
            ,layout_id
            ,object_version_number
        INTO l_modifier_level
            ,l_layout_id
            ,l_object_version_number
        FROM hxc_layouts
       WHERE layout_name = p_layout_name
         AND application_id = l_application_id;
      --
      -- Remove all components for the layout if it already exists
      --
      -- delete rows from HXC_LAYOUT_COMP_PROMPTS
      DELETE FROM hxc_layout_comp_prompts
       WHERE layout_component_id IN
               (SELECT comp.layout_component_id
                  FROM hxc_layout_components comp
                 WHERE comp.layout_id = l_layout_id);
      --
      -- delete rows from HXC_LAYOUT_COMP_QUALIFIERS
      DELETE FROM hxc_layout_comp_qualifiers cq
       WHERE EXISTS
               (SELECT comp.layout_component_id
                  FROM hxc_layout_components comp
                 WHERE comp.layout_id = l_layout_id
                   AND cq.layout_component_id = comp.layout_component_id);
      --
      -- delete rows from HXC_LAYOUT_COMPONENTS
      DELETE FROM hxc_layout_components
       WHERE layout_id = l_layout_id;
      --
      IF ( NVL(l_modifier_level, 'ZZZ') = NVL(p_modifier_level, 'ZZZ') ) THEN
         hxc_layouts_upload_pkg.g_force_ok   := TRUE;
      ELSE
         hxc_layouts_upload_pkg.g_force_ok   := FALSE;
      END IF;
      ---
      l_dummy :=NULL;

             OPEN  C_DISPLAY_NAME(l_layout_id);--,language, source_lang )
             FETCH C_DISPLAY_NAME INTO l_dummy;
       CLOSE C_DISPLAY_NAME;
      --
      IF ( p_custom_mode = 'FORCE' ) THEN
         HXC_ULA_UPD.UPD
            (P_LAYOUT_NAME => P_LAYOUT_NAME
            ,P_APPLICATION_ID => l_application_id
            ,P_LAYOUT_TYPE => P_LAYOUT_TYPE
            ,P_MODIFIER_LEVEL => P_MODIFIER_LEVEL
            ,P_MODIFIER_VALUE => P_MODIFIER_VALUE
            ,P_TOP_LEVEL_REGION_CODE => P_TOP_LEVEL_REGION_CODE
            ,P_LAYOUT_ID => l_layout_id
            ,P_OBJECT_VERSION_NUMBER => l_object_version_number
            );
            IF ( l_dummy = 'yes') THEN

		    HXC_ULT_UPD.UPD_TL --added1
				(P_LANGUAGE_CODE => userenv('LANG')
				,P_LAYOUT_ID => l_layout_id
				,P_DISPLAY_LAYOUT_NAME => P_DISPLAY_LAYOUT_NAME
				);
            END IF;
      ELSE
         IF hxc_layouts_upload_pkg.g_force_ok THEN
            HXC_ULA_UPD.UPD
               (P_LAYOUT_NAME => P_LAYOUT_NAME
               ,P_APPLICATION_ID => l_application_id
               ,P_LAYOUT_TYPE => P_LAYOUT_TYPE
               ,P_MODIFIER_LEVEL => P_MODIFIER_LEVEL
               ,P_MODIFIER_VALUE => P_MODIFIER_VALUE
               ,P_TOP_LEVEL_REGION_CODE => P_TOP_LEVEL_REGION_CODE
               ,P_LAYOUT_ID => l_layout_id
               ,P_OBJECT_VERSION_NUMBER => l_object_version_number
               );
               IF ( l_dummy = 'yes') THEN

		    HXC_ULT_UPD.UPD_TL --added1
			(P_LANGUAGE_CODE => userenv('LANG')
			,P_LAYOUT_ID => l_layout_id
			,P_DISPLAY_LAYOUT_NAME => P_DISPLAY_LAYOUT_NAME
			);
            END IF;
         END IF; -- ( l_modifier_level = p_modifier_level )
      END IF; -- ( p_custom_mode = 'FORCE' )
   EXCEPTION WHEN NO_DATA_FOUND THEN
      HXC_ULA_INS.INS
         (P_LAYOUT_NAME => P_LAYOUT_NAME
         ,P_APPLICATION_ID => l_application_id
         ,P_LAYOUT_TYPE => P_LAYOUT_TYPE
         ,P_MODIFIER_LEVEL => P_MODIFIER_LEVEL
         ,P_MODIFIER_VALUE => P_MODIFIER_VALUE
         ,P_TOP_LEVEL_REGION_CODE => P_TOP_LEVEL_REGION_CODE
         ,P_LAYOUT_ID => l_layout_id
         ,P_OBJECT_VERSION_NUMBER => l_object_version_number
         ,P_DISPLAY_LAYOUT_NAME => p_display_layout_name
         );
   END;
END LOAD_LAYOUT_ROW;

-- =================================================================
-- == translate_layout_row
-- =================================================================
PROCEDURE TRANSLATE_LAYOUT_ROW
   (P_APPLICATION_SHORT_NAME IN VARCHAR2
   ,P_LAYOUT_NAME in VARCHAR2
   ,P_OWNER in VARCHAR2
   ,P_DISPLAY_LAYOUT_NAME in VARCHAR2
   ,P_CUSTOM_MODE IN VARCHAR2
   )
IS
--
l_layout_id HXC_LAYOUTS.LAYOUT_ID%TYPE;
l_dummy varchar2(3);
--
BEGIN
   --
   -- Find the Layout id
   --
   l_layout_id :=
      find_layout_id
         (P_LAYOUT_NAME => P_LAYOUT_NAME
         );
   --
   BEGIN
      -- see if there is a TL row to update
      SELECT 'yes'
        INTO l_dummy
        FROM dual
       WHERE EXISTS (SELECT 'x'
                       FROM hxc_layouts_tl
                      WHERE layout_id   = l_layout_id
                      and DISPLAY_LAYOUT_NAME <> P_DISPLAY_LAYOUT_NAME  --added
                        AND userenv('LANG') in ( language, source_lang )
                     );
      --
      IF (( p_custom_mode = 'FORCE' ) or (l_dummy ='yes')) THEN
         HXC_ULT_UPD.UPD_TL
            (P_LANGUAGE_CODE => userenv('LANG')
            ,P_LAYOUT_ID => l_layout_id
            ,P_DISPLAY_LAYOUT_NAME => P_DISPLAY_LAYOUT_NAME
            );
      END IF;
   EXCEPTION WHEN NO_DATA_FOUND THEN
      --
      -- Call the _TL row handler to insert the record
      --
      HXC_ULT_INS.INS_TL
         (P_LANGUAGE_CODE => userenv('LANG')
         ,P_LAYOUT_ID => l_layout_id
         ,P_DISPLAY_LAYOUT_NAME => P_DISPLAY_LAYOUT_NAME
         );
   END;
END TRANSLATE_LAYOUT_ROW;

-- =================================================================
-- == load_definition_row
-- =================================================================
PROCEDURE LOAD_DEFINITION_ROW
   (P_COMPONENT_TYPE    IN VARCHAR2
   ,P_OWNER             IN VARCHAR2
   ,P_COMPONENT_CLASS   IN VARCHAR2
   ,P_RENDER_TYPE       IN VARCHAR2
   ,P_CUSTOM_MODE       IN VARCHAR2
   )
IS
--
CURSOR C_COMP_DEF IS
SELECT layout_comp_definition_id
       ,object_version_number
FROM hxc_layout_comp_definitions
WHERE component_type = p_component_type
  AND render_type = p_render_type;


CURSOR C_FORCE_OK (p_layout_comp_definition_id HXC_LAYOUT_COMP_DEFINITIONS.LAYOUT_COMP_DEFINITION_ID%TYPE)
IS
SELECT 'N'
FROM  hxc_layout_components lc
WHERE lc.layout_comp_definition_id =  p_layout_comp_definition_id;


l_layout_comp_definition_id HXC_LAYOUT_COMP_DEFINITIONS.LAYOUT_COMP_DEFINITION_ID%TYPE := NULL;
l_object_version_number HXC_LAYOUT_COMP_DEFINITIONS.OBJECT_VERSION_NUMBER%TYPE;
l_force_ok VARCHAR2(1) := 'Y';
--
BEGIN
   --

OPEN c_comp_def;
FETCH c_comp_def INTO l_layout_comp_definition_id,l_object_version_number;
IF c_comp_def%NOTFOUND
THEN
  raise no_data_found;
END IF;
CLOSE c_comp_def;


OPEN C_FORCE_OK(l_layout_comp_definition_id);
FETCH C_FORCE_OK INTO l_force_ok;
IF C_FORCE_OK%NOTFOUND
THEN
  raise no_data_found;
END IF;
CLOSE C_FORCE_OK;

   --
   IF (p_custom_mode = 'FORCE') THEN
      --
      -- Call the row handler to update the row
      --
      HXC_ULD_UPD.UPD
         (P_COMPONENT_CLASS=>P_COMPONENT_CLASS
         ,P_COMPONENT_TYPE => P_COMPONENT_TYPE
         ,P_LAYOUT_COMP_DEFINITION_ID => l_layout_comp_definition_id
         ,p_RENDER_TYPE => p_render_type
         ,P_OBJECT_VERSION_NUMBER  => l_object_version_number
         );
   END IF; -- p_custom_mode = 'FORCE'
EXCEPTION WHEN NO_DATA_FOUND THEN
   IF (l_layout_comp_definition_id IS NULL) THEN
      --
      -- Call the row handler to insert the row
      --
      HXC_ULD_INS.INS
         (P_COMPONENT_CLASS=>P_COMPONENT_CLASS
         ,P_COMPONENT_TYPE => P_COMPONENT_TYPE
         ,P_LAYOUT_COMP_DEFINITION_ID => l_layout_comp_definition_id
         ,p_RENDER_TYPE => p_render_type
         ,P_OBJECT_VERSION_NUMBER  => l_object_version_number
         );
   ELSE
      --
      -- Call the row handler to update the row
      --
      HXC_ULD_UPD.UPD
         (P_COMPONENT_CLASS=>P_COMPONENT_CLASS
         ,P_COMPONENT_TYPE => P_COMPONENT_TYPE
         ,P_LAYOUT_COMP_DEFINITION_ID => l_layout_comp_definition_id
         ,p_RENDER_TYPE => p_render_type
         ,P_OBJECT_VERSION_NUMBER  => l_object_version_number
         );
   END IF;
END LOAD_DEFINITION_ROW;

-- =================================================================
-- == load_component_row
-- =================================================================
PROCEDURE LOAD_COMPONENT_ROW
   (P_LAYOUT_NAME                IN VARCHAR2
   ,P_COMPONENT_NAME             IN VARCHAR2
   ,P_OWNER                      IN VARCHAR2
   ,P_COMPONENT_VALUE            IN VARCHAR2
   ,P_REGION_CODE                IN VARCHAR2
   ,P_REGION_CODE_APP_SHORT_NAME IN VARCHAR2
   ,P_ATTRIBUTE_CODE             IN VARCHAR2
   ,P_ATTRIBUTE_CODE_APP_SHORT_N IN VARCHAR2
   ,P_NAME_VALUE_STRING          IN VARCHAR2
   ,P_SEQUENCE                   IN NUMBER
   ,P_COMPONENT_DEFINITION       IN VARCHAR2
   ,P_RENDER_TYPE                IN VARCHAR2
   ,P_PARENT_COMPONENT           IN VARCHAR2
   ,P_COMPONENT_ALIAS            IN VARCHAR2
   ,P_PARENT_BEAN                IN VARCHAR2
   ,P_ATTRIBUTE1                 IN VARCHAR2
   ,P_ATTRIBUTE2                 IN VARCHAR2
   ,P_ATTRIBUTE3                 IN VARCHAR2
   ,P_ATTRIBUTE4                 IN VARCHAR2
   ,P_ATTRIBUTE5                 IN VARCHAR2
   ,P_CUSTOM_MODE                IN VARCHAR2
   )
IS
--
l_layout_id                   HXC_LAYOUTS.LAYOUT_ID%TYPE;
l_layout_comp_definition_id   HXC_LAYOUT_COMP_DEFINITIONS.LAYOUT_COMP_DEFINITION_ID%TYPE;
l_parent_comp_id              HXC_LAYOUT_COMPONENTS.PARENT_COMPONENT_ID%TYPE;
l_application_id              FND_APPLICATION.APPLICATION_ID%TYPE;
l_attr_application_id         FND_APPLICATION.APPLICATION_ID%TYPE;
l_layout_component_id         HXC_LAYOUT_COMPONENTS.LAYOUT_COMPONENT_ID%TYPE;
l_object_version_number       HXC_LAYOUT_COMPONENTS.OBJECT_VERSION_NUMBER%TYPE;
--
BEGIN
   --
   glb_debug := glb_debug || ' ' || P_COMPONENT_NAME;
   --
   -- Find the parent, layout and the component
   --
   l_layout_id :=
      find_layout_id
         (P_LAYOUT_NAME => P_LAYOUT_NAME
         );
   --
   l_layout_comp_definition_id :=
      find_component_definition_id
         (P_COMPONENT_TYPE => P_COMPONENT_DEFINITION
         ,p_render_type => p_render_type
         );
   --
   l_application_id :=
      find_application_id
         (P_APPLICATION_SHORT_NAME => P_REGION_CODE_APP_SHORT_NAME
         );
   --
   l_attr_application_id :=
      find_application_id
         (p_application_short_name => p_attribute_code_app_short_n
         );
   --
   IF P_PARENT_COMPONENT is NULL then
      --
      l_parent_comp_id := NULL;
      --
   else
      l_parent_comp_id :=
         find_component_id
            (P_COMPONENT_NAME => P_PARENT_COMPONENT
            ,p_layout_name => p_layout_name
            );
   end if;
   --
   BEGIN
      -- check to see row exists
      SELECT layout_component_id
            ,comp.object_version_number
        INTO l_layout_component_id
            ,l_object_version_number
        FROM hxc_layout_components comp
            ,hxc_layouts lay
       WHERE component_name = P_COMPONENT_NAME
         AND comp.layout_id = lay.layout_id
         AND layout_name = p_layout_name;
      --
      IF (p_custom_mode = 'FORCE') THEN
         HXC_ULC_UPD.UPD
            (P_LAYOUT_ID  => l_layout_id
            ,P_PARENT_COMPONENT_ID => l_parent_comp_id
            ,P_SEQUENCE  => P_SEQUENCE
            ,P_COMPONENT_NAME => P_COMPONENT_NAME
            ,P_COMPONENT_VALUE => P_COMPONENT_VALUE
            ,P_NAME_VALUE_STRING => P_NAME_VALUE_STRING
            ,P_REGION_CODE => P_REGION_CODE
            ,P_REGION_CODE_APP_ID => l_application_id
            ,P_ATTRIBUTE_CODE => P_ATTRIBUTE_CODE
            ,P_ATTRIBUTE_CODE_APP_ID => l_attr_application_id
            ,P_LAYOUT_COMPONENT_ID => l_layout_component_id
            ,P_OBJECT_VERSION_NUMBER => l_object_version_number
            ,P_LAYOUT_COMP_DEFINITION_ID => l_layout_comp_definition_id
            ,P_COMPONENT_ALIAS => P_COMPONENT_ALIAS
            ,P_PARENT_BEAN => P_PARENT_BEAN
            ,P_ATTRIBUTE1 => P_ATTRIBUTE1
            ,P_ATTRIBUTE2 => P_ATTRIBUTE2
            ,P_ATTRIBUTE3 => P_ATTRIBUTE3
            ,P_ATTRIBUTE4 => P_ATTRIBUTE4
            ,P_ATTRIBUTE5 => P_ATTRIBUTE5
            );
      ELSE
         IF hxc_layouts_upload_pkg.g_force_ok THEN
            HXC_ULC_UPD.UPD
               (P_LAYOUT_ID  => l_layout_id
               ,P_PARENT_COMPONENT_ID => l_parent_comp_id
               ,P_SEQUENCE  => P_SEQUENCE
               ,P_COMPONENT_NAME => P_COMPONENT_NAME
               ,P_COMPONENT_VALUE => P_COMPONENT_VALUE
               ,P_NAME_VALUE_STRING => P_NAME_VALUE_STRING
               ,P_REGION_CODE => P_REGION_CODE
               ,P_REGION_CODE_APP_ID => l_application_id
               ,P_ATTRIBUTE_CODE => P_ATTRIBUTE_CODE
               ,P_ATTRIBUTE_CODE_APP_ID => l_attr_application_id
               ,P_LAYOUT_COMPONENT_ID => l_layout_component_id
               ,P_OBJECT_VERSION_NUMBER => l_object_version_number
               ,P_LAYOUT_COMP_DEFINITION_ID => l_layout_comp_definition_id
               ,P_COMPONENT_ALIAS => P_COMPONENT_ALIAS
               ,P_PARENT_BEAN => P_PARENT_BEAN
               ,P_ATTRIBUTE1 => P_ATTRIBUTE1
               ,P_ATTRIBUTE2 => P_ATTRIBUTE2
               ,P_ATTRIBUTE3 => P_ATTRIBUTE3
               ,P_ATTRIBUTE4 => P_ATTRIBUTE4
               ,P_ATTRIBUTE5 => P_ATTRIBUTE5
               );
         END IF; -- hxc_layouts_upload_pkg.g_force_ok
      END IF; -- ( p_custom_mode = 'FORCE' )
   EXCEPTION WHEN NO_DATA_FOUND THEN
      HXC_ULC_INS.INS
         (P_LAYOUT_ID  => l_layout_id
         ,P_PARENT_COMPONENT_ID => l_parent_comp_id
         ,P_SEQUENCE  => P_SEQUENCE
         ,P_COMPONENT_NAME => P_COMPONENT_NAME
         ,P_COMPONENT_VALUE => P_COMPONENT_VALUE
         ,P_NAME_VALUE_STRING => P_NAME_VALUE_STRING
         ,P_REGION_CODE => P_REGION_CODE
         ,P_REGION_CODE_APP_ID => l_application_id
         ,P_ATTRIBUTE_CODE => P_ATTRIBUTE_CODE
         ,P_ATTRIBUTE_CODE_APP_ID => l_attr_application_id
         ,P_LAYOUT_COMPONENT_ID => l_layout_component_id
         ,P_OBJECT_VERSION_NUMBER => l_object_version_number
         ,P_LAYOUT_COMP_DEFINITION_ID => l_layout_comp_definition_id
         ,P_COMPONENT_ALIAS => P_COMPONENT_ALIAS
         ,P_PARENT_BEAN => P_PARENT_BEAN
         ,P_ATTRIBUTE1 => P_ATTRIBUTE1
         ,P_ATTRIBUTE2 => P_ATTRIBUTE2
         ,P_ATTRIBUTE3 => P_ATTRIBUTE3
         ,P_ATTRIBUTE4 => P_ATTRIBUTE4
         ,P_ATTRIBUTE5 => P_ATTRIBUTE5
         );
   END;
END LOAD_COMPONENT_ROW;

-- =================================================================
-- == load_prompt_row
-- =================================================================
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
   )
IS
--
l_layout_component_id      HXC_LAYOUT_COMPONENTS.LAYOUT_COMPONENT_ID%TYPE;
l_layout_comp_prompt_id    HXC_LAYOUT_COMP_PROMPTS.LAYOUT_COMP_PROMPT_ID%TYPE;
l_object_version_number    HXC_LAYOUT_COMP_PROMPTS.OBJECT_VERSION_NUMBER%TYPE;
l_region_app_id            hxc_layout_comp_prompts.region_application_id%TYPE;
l_attribute_app_id         hxc_layout_comp_prompts.attribute_application_id%TYPE;
--
BEGIN
   --
   -- Find the component ID
   --
   l_layout_component_id :=
      find_component_id
         (P_COMPONENT_NAME => P_COMPONENT_NAME
         ,p_layout_name => p_layout_name
         );
   --
   l_region_app_id :=
      find_application_id
         (P_APPLICATION_SHORT_NAME => P_REGION_APP_SHORT_NAME
         );
   --
   l_attribute_app_id :=
      find_application_id
         (P_APPLICATION_SHORT_NAME => P_ATTRIBUTE_APP_SHORT_NAME
         );
   --
   BEGIN
      -- check to see if the row exists
      SELECT lcp.layout_comp_prompt_id
            ,lcp.object_version_number
      INTO  l_layout_comp_prompt_id
            ,l_object_version_number
      FROM  HXC_LAYOUT_COMP_PROMPTS lcp
      WHERE lcp.prompt_alias = p_prompt_alias
        AND lcp.prompt_type = p_prompt_type
        AND lcp.layout_component_id = l_layout_component_id;

      IF ( p_custom_mode = 'FORCE' )
      THEN
         --
         -- Use the Row handler to update the row
         --
         HXC_ULP_UPD.UPD
            (P_LAYOUT_COMPONENT_ID        => l_layout_component_id
            ,P_PROMPT_ALIAS               => P_PROMPT_ALIAS
            ,P_PROMPT_TYPE                => P_PROMPT_TYPE
            ,p_region_code                => p_region_code
            ,p_region_application_id      => l_region_app_id
            ,p_attribute_code             => p_attribute_code
            ,p_attribute_application_id   => l_attribute_app_id
            ,P_LAYOUT_COMP_PROMPT_ID      => l_layout_comp_prompt_id
            ,P_OBJECT_VERSION_NUMBER      => l_object_version_number
            );
      ELSE
         IF HXC_layouts_upload_pkg.g_force_ok THEN
            HXC_ULP_UPD.UPD
               (P_LAYOUT_COMPONENT_ID        => l_layout_component_id
               ,P_PROMPT_ALIAS               => P_PROMPT_ALIAS
               ,P_PROMPT_TYPE                => P_PROMPT_TYPE
               ,p_region_code                => p_region_code
               ,p_region_application_id      => l_region_app_id
               ,p_attribute_code             => p_attribute_code
               ,p_attribute_application_id   => l_attribute_app_id
               ,P_LAYOUT_COMP_PROMPT_ID      => l_layout_comp_prompt_id
               ,P_OBJECT_VERSION_NUMBER      => l_object_version_number
               );
         END IF; -- HXC_layouts_upload_pkg.g_force_ok
      END IF; -- p_custom_mode = 'FORCE'
   EXCEPTION WHEN NO_DATA_FOUND THEN
      --
      -- Use the Row handler to insert the row
      --

      HXC_ULP_INS.INS
         (P_LAYOUT_COMPONENT_ID        => l_layout_component_id
         ,P_PROMPT_ALIAS               => P_PROMPT_ALIAS
         ,P_PROMPT_TYPE                => P_PROMPT_TYPE
         ,p_region_code                => p_region_code
         ,p_region_application_id      => l_region_app_id
         ,p_attribute_code             => p_attribute_code
         ,p_attribute_application_id   => l_attribute_app_id
         ,P_LAYOUT_COMP_PROMPT_ID      => l_layout_comp_prompt_id
         ,P_OBJECT_VERSION_NUMBER      => l_object_version_number);
   END;
END LOAD_PROMPT_ROW;

-- =================================================================
-- == load_qualifier_row
-- =================================================================
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
   ,P_CUSTOM_MODE IN VARCHAR2 DEFAULT NULL
   )
IS
--
l_layout_component_id HXC_LAYOUT_COMPONENTS.LAYOUT_COMPONENT_ID%TYPE;
l_layout_comp_qualifier_id HXC_LAYOUT_COMP_QUALIFIERS.LAYOUT_COMP_QUALIFIER_ID%TYPE;
l_object_version_number HXC_LAYOUT_COMP_QUALIFIERS.OBJECT_VERSION_NUMBER%TYPE;
--
BEGIN
   --
   -- Find the component ID
   --
   l_layout_component_id :=
      find_component_id
         (P_COMPONENT_NAME => P_COMPONENT_NAME
         ,p_layout_name => p_layout_name
         );
   BEGIN
      -- check to see the row exists
      SELECT layout_comp_qualifier_id
            ,object_version_number
        INTO l_layout_comp_qualifier_id
            ,l_object_version_number
        FROM HXC_LAYOUT_COMP_QUALIFIERS
       WHERE qualifier_name = p_qualifier_name
         and layout_component_id = l_layout_component_id;

      IF (p_custom_mode = 'FORCE') THEN
         --
         -- Use the Row handler to update the row
         --
         HXC_ULQ_UPD.UPD
            (P_LAYOUT_COMPONENT_ID          => l_layout_component_id
            ,P_QUALIFIER_NAME               => P_QUALIFIER_NAME
            ,P_QUALIFIER_ATTRIBUTE_CATEGORY => P_QUALIFIER_ATTRIBUTE_CATEGORY
            ,P_QUALIFIER_ATTRIBUTE1         => P_QUALIFIER_ATTRIBUTE1
            ,P_QUALIFIER_ATTRIBUTE2         => P_QUALIFIER_ATTRIBUTE2
            ,P_QUALIFIER_ATTRIBUTE3         => P_QUALIFIER_ATTRIBUTE3
            ,P_QUALIFIER_ATTRIBUTE4         => P_QUALIFIER_ATTRIBUTE4
            ,P_QUALIFIER_ATTRIBUTE5         => P_QUALIFIER_ATTRIBUTE5
            ,P_QUALIFIER_ATTRIBUTE6         => P_QUALIFIER_ATTRIBUTE6
            ,P_QUALIFIER_ATTRIBUTE7         => P_QUALIFIER_ATTRIBUTE7
            ,P_QUALIFIER_ATTRIBUTE8         => P_QUALIFIER_ATTRIBUTE8
            ,P_QUALIFIER_ATTRIBUTE9         => P_QUALIFIER_ATTRIBUTE9
            ,P_QUALIFIER_ATTRIBUTE10        => P_QUALIFIER_ATTRIBUTE10
            ,P_QUALIFIER_ATTRIBUTE11        => P_QUALIFIER_ATTRIBUTE11
            ,P_QUALIFIER_ATTRIBUTE12        => P_QUALIFIER_ATTRIBUTE12
            ,P_QUALIFIER_ATTRIBUTE13        => P_QUALIFIER_ATTRIBUTE13
            ,P_QUALIFIER_ATTRIBUTE14        => P_QUALIFIER_ATTRIBUTE14
            ,P_QUALIFIER_ATTRIBUTE15        => P_QUALIFIER_ATTRIBUTE15
            ,P_QUALIFIER_ATTRIBUTE16        => P_QUALIFIER_ATTRIBUTE16
            ,P_QUALIFIER_ATTRIBUTE17        => P_QUALIFIER_ATTRIBUTE17
            ,P_QUALIFIER_ATTRIBUTE18        => P_QUALIFIER_ATTRIBUTE18
            ,P_QUALIFIER_ATTRIBUTE19        => P_QUALIFIER_ATTRIBUTE19
            ,P_QUALIFIER_ATTRIBUTE20        => P_QUALIFIER_ATTRIBUTE20
            ,P_QUALIFIER_ATTRIBUTE21        => P_QUALIFIER_ATTRIBUTE21
            ,P_QUALIFIER_ATTRIBUTE22        => P_QUALIFIER_ATTRIBUTE22
            ,P_QUALIFIER_ATTRIBUTE23        => P_QUALIFIER_ATTRIBUTE23
            ,P_QUALIFIER_ATTRIBUTE24        => P_QUALIFIER_ATTRIBUTE24
            ,P_QUALIFIER_ATTRIBUTE25        => P_QUALIFIER_ATTRIBUTE25
            ,P_QUALIFIER_ATTRIBUTE26        => P_QUALIFIER_ATTRIBUTE26
            ,P_QUALIFIER_ATTRIBUTE27        => P_QUALIFIER_ATTRIBUTE27
            ,P_QUALIFIER_ATTRIBUTE28        => P_QUALIFIER_ATTRIBUTE28
            ,P_QUALIFIER_ATTRIBUTE29        => P_QUALIFIER_ATTRIBUTE29
            ,P_QUALIFIER_ATTRIBUTE30        => P_QUALIFIER_ATTRIBUTE30
            ,P_LAYOUT_COMP_QUALIFIER_ID     => l_layout_comp_qualifier_id
            ,P_OBJECT_VERSION_NUMBER        => l_object_version_number
            );
      ELSE
         IF HXC_layouts_upload_pkg.g_force_ok THEN
            HXC_ULQ_UPD.UPD
               (P_LAYOUT_COMPONENT_ID          => l_layout_component_id
               ,P_QUALIFIER_NAME               => P_QUALIFIER_NAME
               ,P_QUALIFIER_ATTRIBUTE_CATEGORY => P_QUALIFIER_ATTRIBUTE_CATEGORY
               ,P_QUALIFIER_ATTRIBUTE1         => P_QUALIFIER_ATTRIBUTE1
               ,P_QUALIFIER_ATTRIBUTE2         => P_QUALIFIER_ATTRIBUTE2
               ,P_QUALIFIER_ATTRIBUTE3         => P_QUALIFIER_ATTRIBUTE3
               ,P_QUALIFIER_ATTRIBUTE4         => P_QUALIFIER_ATTRIBUTE4
               ,P_QUALIFIER_ATTRIBUTE5         => P_QUALIFIER_ATTRIBUTE5
               ,P_QUALIFIER_ATTRIBUTE6         => P_QUALIFIER_ATTRIBUTE6
               ,P_QUALIFIER_ATTRIBUTE7         => P_QUALIFIER_ATTRIBUTE7
               ,P_QUALIFIER_ATTRIBUTE8         => P_QUALIFIER_ATTRIBUTE8
               ,P_QUALIFIER_ATTRIBUTE9         => P_QUALIFIER_ATTRIBUTE9
               ,P_QUALIFIER_ATTRIBUTE10        => P_QUALIFIER_ATTRIBUTE10
               ,P_QUALIFIER_ATTRIBUTE11        => P_QUALIFIER_ATTRIBUTE11
               ,P_QUALIFIER_ATTRIBUTE12        => P_QUALIFIER_ATTRIBUTE12
               ,P_QUALIFIER_ATTRIBUTE13        => P_QUALIFIER_ATTRIBUTE13
               ,P_QUALIFIER_ATTRIBUTE14        => P_QUALIFIER_ATTRIBUTE14
               ,P_QUALIFIER_ATTRIBUTE15        => P_QUALIFIER_ATTRIBUTE15
               ,P_QUALIFIER_ATTRIBUTE16        => P_QUALIFIER_ATTRIBUTE16
               ,P_QUALIFIER_ATTRIBUTE17        => P_QUALIFIER_ATTRIBUTE17
               ,P_QUALIFIER_ATTRIBUTE18        => P_QUALIFIER_ATTRIBUTE18
               ,P_QUALIFIER_ATTRIBUTE19        => P_QUALIFIER_ATTRIBUTE19
               ,P_QUALIFIER_ATTRIBUTE20        => P_QUALIFIER_ATTRIBUTE20
               ,P_QUALIFIER_ATTRIBUTE21        => P_QUALIFIER_ATTRIBUTE21
               ,P_QUALIFIER_ATTRIBUTE22        => P_QUALIFIER_ATTRIBUTE22
               ,P_QUALIFIER_ATTRIBUTE23        => P_QUALIFIER_ATTRIBUTE23
               ,P_QUALIFIER_ATTRIBUTE24        => P_QUALIFIER_ATTRIBUTE24
               ,P_QUALIFIER_ATTRIBUTE25        => P_QUALIFIER_ATTRIBUTE25
               ,P_QUALIFIER_ATTRIBUTE26        => P_QUALIFIER_ATTRIBUTE26
               ,P_QUALIFIER_ATTRIBUTE27        => P_QUALIFIER_ATTRIBUTE27
               ,P_QUALIFIER_ATTRIBUTE28        => P_QUALIFIER_ATTRIBUTE28
               ,P_QUALIFIER_ATTRIBUTE29        => P_QUALIFIER_ATTRIBUTE29
               ,P_QUALIFIER_ATTRIBUTE30        => P_QUALIFIER_ATTRIBUTE30
               ,P_LAYOUT_COMP_QUALIFIER_ID     => l_layout_comp_qualifier_id
               ,P_OBJECT_VERSION_NUMBER        => l_object_version_number
               );
         END IF; -- HXC_layouts_upload_pkg.g_force_ok
      END IF; -- p_custom_mode = 'FORCE'
   EXCEPTION WHEN NO_DATA_FOUND THEN
      --
      -- Use the Row handler to insert the row
      --
      HXC_ULQ_INS.INS
         (P_LAYOUT_COMPONENT_ID          => l_layout_component_id
         ,P_QUALIFIER_NAME               => P_QUALIFIER_NAME
         ,P_QUALIFIER_ATTRIBUTE_CATEGORY => P_QUALIFIER_ATTRIBUTE_CATEGORY
         ,P_QUALIFIER_ATTRIBUTE1         => P_QUALIFIER_ATTRIBUTE1
         ,P_QUALIFIER_ATTRIBUTE2         => P_QUALIFIER_ATTRIBUTE2
         ,P_QUALIFIER_ATTRIBUTE3         => P_QUALIFIER_ATTRIBUTE3
         ,P_QUALIFIER_ATTRIBUTE4         => P_QUALIFIER_ATTRIBUTE4
         ,P_QUALIFIER_ATTRIBUTE5         => P_QUALIFIER_ATTRIBUTE5
         ,P_QUALIFIER_ATTRIBUTE6         => P_QUALIFIER_ATTRIBUTE6
         ,P_QUALIFIER_ATTRIBUTE7         => P_QUALIFIER_ATTRIBUTE7
         ,P_QUALIFIER_ATTRIBUTE8         => P_QUALIFIER_ATTRIBUTE8
         ,P_QUALIFIER_ATTRIBUTE9         => P_QUALIFIER_ATTRIBUTE9
         ,P_QUALIFIER_ATTRIBUTE10        => P_QUALIFIER_ATTRIBUTE10
         ,P_QUALIFIER_ATTRIBUTE11        => P_QUALIFIER_ATTRIBUTE11
         ,P_QUALIFIER_ATTRIBUTE12        => P_QUALIFIER_ATTRIBUTE12
         ,P_QUALIFIER_ATTRIBUTE13        => P_QUALIFIER_ATTRIBUTE13
         ,P_QUALIFIER_ATTRIBUTE14        => P_QUALIFIER_ATTRIBUTE14
         ,P_QUALIFIER_ATTRIBUTE15        => P_QUALIFIER_ATTRIBUTE15
         ,P_QUALIFIER_ATTRIBUTE16        => P_QUALIFIER_ATTRIBUTE16
         ,P_QUALIFIER_ATTRIBUTE17        => P_QUALIFIER_ATTRIBUTE17
         ,P_QUALIFIER_ATTRIBUTE18        => P_QUALIFIER_ATTRIBUTE18
         ,P_QUALIFIER_ATTRIBUTE19        => P_QUALIFIER_ATTRIBUTE19
         ,P_QUALIFIER_ATTRIBUTE20        => P_QUALIFIER_ATTRIBUTE20
         ,P_QUALIFIER_ATTRIBUTE21        => P_QUALIFIER_ATTRIBUTE21
         ,P_QUALIFIER_ATTRIBUTE22        => P_QUALIFIER_ATTRIBUTE22
         ,P_QUALIFIER_ATTRIBUTE23        => P_QUALIFIER_ATTRIBUTE23
         ,P_QUALIFIER_ATTRIBUTE24        => P_QUALIFIER_ATTRIBUTE24
         ,P_QUALIFIER_ATTRIBUTE25        => P_QUALIFIER_ATTRIBUTE25
         ,P_QUALIFIER_ATTRIBUTE26        => P_QUALIFIER_ATTRIBUTE26
         ,P_QUALIFIER_ATTRIBUTE27        => P_QUALIFIER_ATTRIBUTE27
         ,P_QUALIFIER_ATTRIBUTE28        => P_QUALIFIER_ATTRIBUTE28
         ,P_QUALIFIER_ATTRIBUTE29        => P_QUALIFIER_ATTRIBUTE29
         ,P_QUALIFIER_ATTRIBUTE30        => P_QUALIFIER_ATTRIBUTE30
         ,P_LAYOUT_COMP_QUALIFIER_ID     => l_layout_comp_qualifier_id
         ,P_OBJECT_VERSION_NUMBER        => l_object_version_number
         );
   END;
END LOAD_QUALIFIER_ROW;

-- =================================================================
-- == load_rule_row
-- =================================================================
/*
PROCEDURE LOAD_RULE_ROW
   (P_QUALIFIER_NAME IN VARCHAR2
   ,P_RULE_NAME IN VARCHAR2
   ,P_OWNER IN VARCHAR2
   ,P_RULE_TYPE IN VARCHAR2
   ,P_RULE_DETAIL IN VARCHAR2
   ,P_RULE_VALUE IN VARCHAR2
   ,P_CUSTOM_MODE IN VARCHAR2
   )
IS
--
l_layout_comp_qualifier_id    HXC_LAYOUT_COMP_QUALIFIERS.LAYOUT_COMP_QUALIFIER_ID%TYPE;
l_layout_comp_qual_rule_id HXC_LAYOUT_COMP_QUAL_RULES.LAYOUT_COMP_QUAL_RULE_ID%TYPE;
l_object_version_number HXC_LAYOUT_COMP_QUAL_RULES.OBJECT_VERSION_NUMBER%TYPE;
--
BEGIN
   --
   -- Obtain the qualifier id
   --
   l_layout_comp_qualifier_id :=
      find_comp_qualifier_id
         (P_COMP_QUALIFIER_NAME => P_QUALIFIER_NAME
         );
   --
   BEGIN
      SELECT layout_comp_qual_rule_id
            ,object_version_number
        INTO l_layout_comp_qual_rule_id
            ,l_object_version_number
        FROM HXC_LAYOUT_COMP_QUAL_RULES
       WHERE rule_name = p_rule_name;

      IF (p_custom_mode = 'FORCE') THEN
         --
         -- Use the row handler to update the rule data
         --
         HXC_ULR_UPD.UPD
            (P_RULE_NAME                    => P_RULE_NAME
            ,P_RULE_TYPE                    => P_RULE_TYPE
            ,P_LAYOUT_COMP_QUALIFIER_ID     => l_layout_comp_qualifier_id
            ,P_RULE_DETAIL                  => P_RULE_DETAIL
            ,P_RULE_VALUE                   => P_RULE_VALUE
            ,P_LAYOUT_COMP_QUAL_RULE_ID     => l_layout_comp_qual_rule_id
            ,P_OBJECT_VERSION_NUMBER        => l_object_version_number
            );
      ELSE
         IF  HXC_layouts_upload_pkg.g_force_ok THEN
            --
            -- Use the row handler to update the rule data
            --
            HXC_ULR_UPD.UPD
               (P_RULE_NAME                    => P_RULE_NAME
               ,P_RULE_TYPE                    => P_RULE_TYPE
               ,P_LAYOUT_COMP_QUALIFIER_ID     => l_layout_comp_qualifier_id
               ,P_RULE_DETAIL                  => P_RULE_DETAIL
               ,P_RULE_VALUE                   => P_RULE_VALUE
               ,P_LAYOUT_COMP_QUAL_RULE_ID     => l_layout_comp_qual_rule_id
               ,P_OBJECT_VERSION_NUMBER        => l_object_version_number
               );
         END IF; -- HXC_layouts_upload_pkg.g_force_ok
      END IF; -- p_custom_mode = 'FORCE'
   EXCEPTION WHEN NO_DATA_FOUND THEN
      --
      -- Use the row handler to insert the rule data
      --
      HXC_ULR_INS.INS
         (P_RULE_NAME                    => P_RULE_NAME
         ,P_RULE_TYPE                    => P_RULE_TYPE
         ,P_LAYOUT_COMP_QUALIFIER_ID     => l_layout_comp_qualifier_id
         ,P_RULE_DETAIL                  => P_RULE_DETAIL
         ,P_RULE_VALUE                   => P_RULE_VALUE
         ,P_LAYOUT_COMP_QUAL_RULE_ID     => l_layout_comp_qual_rule_id
         ,P_OBJECT_VERSION_NUMBER        => l_object_version_number
         );
   END;
END LOAD_RULE_ROW;
*/
-- =================================================================
-- == load_layout_row
-- =================================================================
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
   )
   IS

--
      l_layout_id               hxc_layouts.layout_id%TYPE;
      l_object_version_number   hxc_layouts.object_version_number%TYPE;
      l_application_id          fnd_application.application_id%TYPE;
      l_dummy                   VARCHAR2(3);
      l_last_update_date_db     DATE;
      l_last_updated_by_db      NUMBER(15);
      l_last_updated_by_f       NUMBER(15);
      l_last_update_date_f      DATE;

      CURSOR c_display_name(p_layout_id IN NUMBER)
      IS
         SELECT 'yes'
           FROM dual
          WHERE EXISTS( SELECT 'x'
                          FROM hxc_layouts_tl
                         WHERE layout_id = p_layout_id
                           AND display_layout_name <>
                                                 p_display_layout_name --added
                           AND userenv('LANG') IN (LANGUAGE, source_lang));
   BEGIN
      --
      g_debug :=hr_utility.debug_enabled;
      l_last_updated_by_f := fnd_load_util.owner_id(p_owner);
      l_last_update_date_f :=
                       nvl(TO_DATE(p_last_update_date, 'YYYY/MM/DD'), sysdate);
      if g_debug then
            hr_utility.set_location('Entering Load Layout Row ', 10);
      end if;
      --
      -- Find the application id
      --
      l_application_id :=
            find_application_id(
               p_application_short_name=> p_application_short_name
            );

      --
      BEGIN
         if g_debug then
         	hr_utility.set_location('In Load Layout Row ', 20);
         end if;

         --
         -- check to see row exists
         --
         SELECT modifier_level,
                layout_id,
                object_version_number,
                last_update_date,
                last_updated_by
           INTO l_modifier_level,
                l_layout_id,
                l_object_version_number,
                l_last_update_date_db,
                l_last_updated_by_db
           FROM hxc_layouts
          WHERE layout_name = p_layout_name
            AND application_id = l_application_id;

         --
         -- Remove all components for the layout if it already exists
         --
         -- delete rows from HXC_LAYOUT_COMP_PROMPTS
         DELETE FROM hxc_layout_comp_prompts
               WHERE layout_component_id IN (SELECT comp.layout_component_id
                                               FROM hxc_layout_components comp
                                              WHERE comp.layout_id =
                                                                  l_layout_id);

         --
         -- delete rows from HXC_LAYOUT_COMP_QUALIFIERS
         DELETE FROM hxc_layout_comp_qualifiers cq
               WHERE EXISTS( SELECT comp.layout_component_id
                               FROM hxc_layout_components comp
                              WHERE comp.layout_id = l_layout_id
                                AND cq.layout_component_id =
                                                     comp.layout_component_id);

         --
         -- delete rows from HXC_LAYOUT_COMPONENTS
         DELETE FROM hxc_layout_components
               WHERE layout_id = l_layout_id;

         --
         IF (nvl(l_modifier_level, 'ZZZ') = nvl(p_modifier_level, 'ZZZ'))
         THEN
            hxc_layouts_upload_pkg.g_force_ok := TRUE;
         ELSE
            hxc_layouts_upload_pkg.g_force_ok := FALSE;
         END IF;

         ---
         l_dummy := NULL;
         OPEN c_display_name(l_layout_id); --,language, source_lang )
         FETCH c_display_name INTO l_dummy;
         CLOSE c_display_name;

         --
         IF (fnd_load_util.upload_test(
                l_last_updated_by_f,
                l_last_update_date_f,
                l_last_updated_by_db,
                l_last_update_date_db,
                p_custom_mode
             )
            )
         THEN
            hxc_ula_upd.upd(
               p_layout_name=> p_layout_name,
               p_application_id=> l_application_id,
               p_layout_type=> p_layout_type,
               p_modifier_level=> p_modifier_level,
               p_modifier_value=> p_modifier_value,
               p_top_level_region_code=> p_top_level_region_code,
               p_layout_id=> l_layout_id,
               p_object_version_number=> l_object_version_number
            );

            IF (l_dummy = 'yes')
            THEN
               hxc_ult_upd.upd_tl --added1
                                 (
                  p_language_code=> userenv('LANG'),
                  p_layout_id=> l_layout_id,
                  p_display_layout_name=> p_display_layout_name
               );
            END IF;
         ELSE
            IF hxc_layouts_upload_pkg.g_force_ok
            THEN
               hxc_ula_upd.upd(
                  p_layout_name=> p_layout_name,
                  p_application_id=> l_application_id,
                  p_layout_type=> p_layout_type,
                  p_modifier_level=> p_modifier_level,
                  p_modifier_value=> p_modifier_value,
                  p_top_level_region_code=> p_top_level_region_code,
                  p_layout_id=> l_layout_id,
                  p_object_version_number=> l_object_version_number
               );

               IF (l_dummy = 'yes')
               THEN
                  hxc_ult_upd.upd_tl --added1
                                    (
                     p_language_code=> userenv('LANG'),
                     p_layout_id=> l_layout_id,
                     p_display_layout_name=> p_display_layout_name
                  );
               END IF;
            END IF; -- ( l_modifier_level = p_modifier_level )
         END IF; -- ( p_custom_mode = 'FORCE' )
      EXCEPTION
         WHEN no_data_found
         THEN
            hxc_ula_ins.ins(
               p_layout_name=> p_layout_name,
               p_application_id=> l_application_id,
               p_layout_type=> p_layout_type,
               p_modifier_level=> p_modifier_level,
               p_modifier_value=> p_modifier_value,
               p_top_level_region_code=> p_top_level_region_code,
               p_layout_id=> l_layout_id,
               p_object_version_number=> l_object_version_number,
               p_display_layout_name=> p_display_layout_name
            );
      END;
   END load_layout_row;


-- =================================================================
-- == translate_layout_row
-- =================================================================
   PROCEDURE translate_layout_row(
      p_application_short_name   IN   VARCHAR2,
      p_layout_name              IN   VARCHAR2,
      p_owner                    IN   VARCHAR2,
      p_display_layout_name      IN   VARCHAR2,
      p_custom_mode              IN   VARCHAR2,
      p_last_update_date         IN   VARCHAR2
   )
   IS

--
      l_layout_id             hxc_layouts.layout_id%TYPE;
      l_dummy                 VARCHAR2(3);
      l_last_update_date_db   DATE;
      l_last_updated_by_db    NUMBER(15);
      l_last_updated_by_f     NUMBER(15);
      l_last_update_date_f    DATE;

--
   BEGIN
      --
      -- Find the Layout id
      --
      l_last_updated_by_f := fnd_load_util.owner_id(p_owner);
      l_last_update_date_f :=
                       nvl(TO_DATE(p_last_update_date, 'YYYY/MM/DD'), sysdate);
      l_layout_id := find_layout_id(p_layout_name => p_layout_name);

      --
      BEGIN
         -- see if there is a TL row to update
         SELECT 'yes'
           INTO l_dummy
           FROM dual
          WHERE EXISTS( SELECT 'x'
                          FROM hxc_layouts_tl
                         WHERE layout_id = l_layout_id
                           AND display_layout_name <>
                                                 p_display_layout_name --added
                           AND userenv('LANG') IN (LANGUAGE, source_lang));

         --
	 SELECT last_update_date,
                last_updated_by
           INTO l_last_update_date_db,
                l_last_updated_by_db
           FROM hxc_layouts_tl
          WHERE layout_id = l_layout_id
            AND display_layout_name <> p_display_layout_name --added
            AND userenv('LANG') = LANGUAGE;

          IF (   fnd_load_util.upload_test(
                   l_last_updated_by_f,
                   l_last_update_date_f,
                   l_last_updated_by_db,
                   l_last_update_date_db,
                   p_custom_mode
                )
             OR (l_dummy = 'yes')
            )
         THEN
            hxc_ult_upd.upd_tl(
               p_language_code=> userenv('LANG'),
               p_layout_id=> l_layout_id,
               p_display_layout_name=> p_display_layout_name
            );
         END IF;
      EXCEPTION
         WHEN no_data_found
         THEN
            --
            -- Call the _TL row handler to insert the record
            --
            hxc_ult_ins.ins_tl(
               p_language_code=> userenv('LANG'),
               p_layout_id=> l_layout_id,
               p_display_layout_name=> p_display_layout_name
            );
      END;
   END translate_layout_row;


-- =================================================================
-- == load_definition_row
-- =================================================================
   PROCEDURE load_definition_row(
      p_component_type     IN   VARCHAR2,
      p_owner              IN   VARCHAR2,
      p_component_class    IN   VARCHAR2,
      p_render_type        IN   VARCHAR2,
      p_custom_mode        IN   VARCHAR2,
      p_last_update_date   IN   VARCHAR2
   )
   IS

--
      l_last_update_date_db         DATE;
      l_last_updated_by_db          NUMBER(15);
      l_last_updated_by_f           NUMBER(15);
      l_last_update_date_f          DATE;

      CURSOR c_comp_def
      IS
         SELECT layout_comp_definition_id,
                object_version_number,
                last_update_date,
                last_updated_by
           FROM hxc_layout_comp_definitions
          WHERE component_type = p_component_type
            AND render_type = p_render_type;

      CURSOR c_force_ok(
         p_layout_comp_definition_id   hxc_layout_comp_definitions.layout_comp_definition_id%TYPE
      )
      IS
         SELECT 'N'
           FROM hxc_layout_components lc
          WHERE lc.layout_comp_definition_id = p_layout_comp_definition_id;

      l_layout_comp_definition_id   hxc_layout_comp_definitions.layout_comp_definition_id%TYPE
                                                                      := NULL;
      l_object_version_number       hxc_layout_comp_definitions.object_version_number%TYPE;
      l_force_ok                    VARCHAR2(1)                               := 'Y';

--
   BEGIN
      --
      l_last_updated_by_f := fnd_load_util.owner_id(p_owner);
      l_last_update_date_f :=
                       nvl(TO_DATE(p_last_update_date, 'YYYY/MM/DD'), sysdate);
      OPEN c_comp_def;
      FETCH c_comp_def INTO l_layout_comp_definition_id,
                            l_object_version_number,
                            l_last_update_date_db,
                            l_last_updated_by_db;

      IF c_comp_def%NOTFOUND
      THEN
         RAISE no_data_found;
      END IF;

      CLOSE c_comp_def;
      OPEN c_force_ok(l_layout_comp_definition_id);
      FETCH c_force_ok INTO l_force_ok;

      IF c_force_ok%NOTFOUND
      THEN
         RAISE no_data_found;
      END IF;

      CLOSE c_force_ok;

      --
      IF (fnd_load_util.upload_test(
             l_last_updated_by_f,
             l_last_update_date_f,
             l_last_updated_by_db,
             l_last_update_date_db,
             p_custom_mode
          )
         )
      THEN
         --
         -- Call the row handler to update the row
         --
         hxc_uld_upd.upd(
            p_component_class=> p_component_class,
            p_component_type=> p_component_type,
            p_layout_comp_definition_id=> l_layout_comp_definition_id,
            p_render_type=> p_render_type,
            p_object_version_number=> l_object_version_number
         );
      END IF; -- p_custom_mode = 'FORCE'
   EXCEPTION
      WHEN no_data_found
      THEN
         IF (l_layout_comp_definition_id IS NULL)
         THEN
            --
            -- Call the row handler to insert the row
            --
            hxc_uld_ins.ins(
               p_component_class=> p_component_class,
               p_component_type=> p_component_type,
               p_layout_comp_definition_id=> l_layout_comp_definition_id,
               p_render_type=> p_render_type,
               p_object_version_number=> l_object_version_number
            );
         ELSE
            --
            -- Call the row handler to update the row
            --
            hxc_uld_upd.upd(
               p_component_class=> p_component_class,
               p_component_type=> p_component_type,
               p_layout_comp_definition_id=> l_layout_comp_definition_id,
               p_render_type=> p_render_type,
               p_object_version_number=> l_object_version_number
            );
         END IF;
   END load_definition_row;


-- =================================================================
-- == load_component_row
-- =================================================================
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
      p_custom_mode                  IN   VARCHAR2,
      p_last_update_date             IN   VARCHAR2
   )
   IS

--
      l_layout_id                   hxc_layouts.layout_id%TYPE;
      l_layout_comp_definition_id   hxc_layout_comp_definitions.layout_comp_definition_id%TYPE;
      l_parent_comp_id              hxc_layout_components.parent_component_id%TYPE;
      l_application_id              fnd_application.application_id%TYPE;
      l_attr_application_id         fnd_application.application_id%TYPE;
      l_layout_component_id         hxc_layout_components.layout_component_id%TYPE;
      l_object_version_number       hxc_layout_components.object_version_number%TYPE;

--
      l_last_update_date_db         DATE;
      l_last_updated_by_db          NUMBER(15);
      l_last_updated_by_f           NUMBER(15);
      l_last_update_date_f          DATE;
   BEGIN
      --
      l_last_updated_by_f := fnd_load_util.owner_id(p_owner);
      l_last_update_date_f :=
                       nvl(TO_DATE(p_last_update_date, 'YYYY/MM/DD'), sysdate);
      glb_debug := glb_debug || ' ' || p_component_name;
      --
      -- Find the parent, layout and the component
      --
      l_layout_id := find_layout_id(p_layout_name => p_layout_name);
      --
      l_layout_comp_definition_id :=
            find_component_definition_id(
               p_component_type=> p_component_definition,
               p_render_type=> p_render_type
            );
      --
      l_application_id :=
            find_application_id(
               p_application_short_name=> p_region_code_app_short_name
            );
      --
      l_attr_application_id :=
            find_application_id(
               p_application_short_name=> p_attribute_code_app_short_n
            );

      --
      IF p_parent_component IS NULL
      THEN
         --
         l_parent_comp_id := NULL;
      --
      ELSE
         l_parent_comp_id :=
               find_component_id(
                  p_component_name=> p_parent_component,
                  p_layout_name=> p_layout_name
               );
      END IF;

      --
      BEGIN
         -- check to see row exists
         SELECT layout_component_id,
                comp.object_version_number,
                comp.last_update_date,
                comp.last_updated_by
           INTO l_layout_component_id,
                l_object_version_number,
                l_last_update_date_db,
                l_last_updated_by_db
           FROM hxc_layout_components comp,
                hxc_layouts lay
          WHERE component_name = p_component_name
            AND comp.layout_id = lay.layout_id
            AND layout_name = p_layout_name;

         --
         IF (fnd_load_util.upload_test(
                l_last_updated_by_f,
                l_last_update_date_f,
                l_last_updated_by_db,
                l_last_update_date_db,
                p_custom_mode
             )
            )
         THEN
            hxc_ulc_upd.upd(
               p_layout_id=> l_layout_id,
               p_parent_component_id=> l_parent_comp_id,
               p_sequence=> p_sequence,
               p_component_name=> p_component_name,
               p_component_value=> p_component_value,
               p_name_value_string=> p_name_value_string,
               p_region_code=> p_region_code,
               p_region_code_app_id=> l_application_id,
               p_attribute_code=> p_attribute_code,
               p_attribute_code_app_id=> l_attr_application_id,
               p_layout_component_id=> l_layout_component_id,
               p_object_version_number=> l_object_version_number,
               p_layout_comp_definition_id=> l_layout_comp_definition_id,
               p_component_alias=> p_component_alias,
               p_parent_bean=> p_parent_bean,
               p_attribute1=> p_attribute1,
               p_attribute2=> p_attribute2,
               p_attribute3=> p_attribute3,
               p_attribute4=> p_attribute4,
               p_attribute5=> p_attribute5
            );
         ELSE
            IF hxc_layouts_upload_pkg.g_force_ok
            THEN
               hxc_ulc_upd.upd(
                  p_layout_id=> l_layout_id,
                  p_parent_component_id=> l_parent_comp_id,
                  p_sequence=> p_sequence,
                  p_component_name=> p_component_name,
                  p_component_value=> p_component_value,
                  p_name_value_string=> p_name_value_string,
                  p_region_code=> p_region_code,
                  p_region_code_app_id=> l_application_id,
                  p_attribute_code=> p_attribute_code,
                  p_attribute_code_app_id=> l_attr_application_id,
                  p_layout_component_id=> l_layout_component_id,
                  p_object_version_number=> l_object_version_number,
                  p_layout_comp_definition_id=> l_layout_comp_definition_id,
                  p_component_alias=> p_component_alias,
                  p_parent_bean=> p_parent_bean,
                  p_attribute1=> p_attribute1,
                  p_attribute2=> p_attribute2,
                  p_attribute3=> p_attribute3,
                  p_attribute4=> p_attribute4,
                  p_attribute5=> p_attribute5
               );
            END IF; -- hxc_layouts_upload_pkg.g_force_ok
         END IF; -- ( p_custom_mode = 'FORCE' )
      EXCEPTION
         WHEN no_data_found
         THEN
            hxc_ulc_ins.ins(
               p_layout_id=> l_layout_id,
               p_parent_component_id=> l_parent_comp_id,
               p_sequence=> p_sequence,
               p_component_name=> p_component_name,
               p_component_value=> p_component_value,
               p_name_value_string=> p_name_value_string,
               p_region_code=> p_region_code,
               p_region_code_app_id=> l_application_id,
               p_attribute_code=> p_attribute_code,
               p_attribute_code_app_id=> l_attr_application_id,
               p_layout_component_id=> l_layout_component_id,
               p_object_version_number=> l_object_version_number,
               p_layout_comp_definition_id=> l_layout_comp_definition_id,
               p_component_alias=> p_component_alias,
               p_parent_bean=> p_parent_bean,
               p_attribute1=> p_attribute1,
               p_attribute2=> p_attribute2,
               p_attribute3=> p_attribute3,
               p_attribute4=> p_attribute4,
               p_attribute5=> p_attribute5
            );
      END;
   END load_component_row;


-- =================================================================
-- == load_prompt_row
-- =================================================================
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
   )
   IS

--
      l_layout_component_id     hxc_layout_components.layout_component_id%TYPE;
      l_layout_comp_prompt_id   hxc_layout_comp_prompts.layout_comp_prompt_id%TYPE;
      l_object_version_number   hxc_layout_comp_prompts.object_version_number%TYPE;
      l_region_app_id           hxc_layout_comp_prompts.region_application_id%TYPE;
      l_attribute_app_id        hxc_layout_comp_prompts.attribute_application_id%TYPE;

--
      l_last_update_date_db     DATE;
      l_last_updated_by_db      NUMBER(15);
      l_last_updated_by_f       NUMBER(15);
      l_last_update_date_f      DATE;
   BEGIN
      --
      -- Find the component ID
      --
      l_last_updated_by_f := fnd_load_util.owner_id(p_owner);
      l_last_update_date_f :=
                       nvl(TO_DATE(p_last_update_date, 'YYYY/MM/DD'), sysdate);
      l_layout_component_id :=
            find_component_id(
               p_component_name=> p_component_name,
               p_layout_name=> p_layout_name
            );
      --
      l_region_app_id :=
            find_application_id(
               p_application_short_name=> p_region_app_short_name
            );
      --
      l_attribute_app_id :=
            find_application_id(
               p_application_short_name=> p_attribute_app_short_name
            );

      --
      BEGIN
         -- check to see if the row exists
         SELECT lcp.layout_comp_prompt_id,
                lcp.object_version_number,
                last_update_date,
                last_updated_by
           INTO l_layout_comp_prompt_id,
                l_object_version_number,
                l_last_update_date_db,
                l_last_updated_by_db
           FROM hxc_layout_comp_prompts lcp
          WHERE lcp.prompt_alias = p_prompt_alias
            AND lcp.prompt_type = p_prompt_type
            AND lcp.layout_component_id = l_layout_component_id;

         IF (fnd_load_util.upload_test(
                l_last_updated_by_f,
                l_last_update_date_f,
                l_last_updated_by_db,
                l_last_update_date_db,
                p_custom_mode
             )
            )
         THEN
            --
            -- Use the Row handler to update the row
            --
            hxc_ulp_upd.upd(
               p_layout_component_id=> l_layout_component_id,
               p_prompt_alias=> p_prompt_alias,
               p_prompt_type=> p_prompt_type,
               p_region_code=> p_region_code,
               p_region_application_id=> l_region_app_id,
               p_attribute_code=> p_attribute_code,
               p_attribute_application_id=> l_attribute_app_id,
               p_layout_comp_prompt_id=> l_layout_comp_prompt_id,
               p_object_version_number=> l_object_version_number
            );
         ELSE
            IF hxc_layouts_upload_pkg.g_force_ok
            THEN
               hxc_ulp_upd.upd(
                  p_layout_component_id=> l_layout_component_id,
                  p_prompt_alias=> p_prompt_alias,
                  p_prompt_type=> p_prompt_type,
                  p_region_code=> p_region_code,
                  p_region_application_id=> l_region_app_id,
                  p_attribute_code=> p_attribute_code,
                  p_attribute_application_id=> l_attribute_app_id,
                  p_layout_comp_prompt_id=> l_layout_comp_prompt_id,
                  p_object_version_number=> l_object_version_number
               );
            END IF; -- HXC_layouts_upload_pkg.g_force_ok
         END IF; -- p_custom_mode = 'FORCE'
      EXCEPTION
         WHEN no_data_found
         THEN
            --
            -- Use the Row handler to insert the row
            --

            hxc_ulp_ins.ins(
               p_layout_component_id=> l_layout_component_id,
               p_prompt_alias=> p_prompt_alias,
               p_prompt_type=> p_prompt_type,
               p_region_code=> p_region_code,
               p_region_application_id=> l_region_app_id,
               p_attribute_code=> p_attribute_code,
               p_attribute_application_id=> l_attribute_app_id,
               p_layout_comp_prompt_id=> l_layout_comp_prompt_id,
               p_object_version_number=> l_object_version_number
            );
      END;
   END load_prompt_row;


-- =================================================================
-- == load_qualifier_row
-- =================================================================
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
   )
   IS

--
      l_layout_component_id        hxc_layout_components.layout_component_id%TYPE;
      l_layout_comp_qualifier_id   hxc_layout_comp_qualifiers.layout_comp_qualifier_id%TYPE;
      l_object_version_number      hxc_layout_comp_qualifiers.object_version_number%TYPE;

--
      l_last_update_date_db        DATE;
      l_last_updated_by_db         NUMBER(15);
      l_last_updated_by_f          NUMBER(15);
      l_last_update_date_f         DATE;
   BEGIN
      --
      l_last_updated_by_f := fnd_load_util.owner_id(p_owner);
      l_last_update_date_f :=
                       nvl(TO_DATE(p_last_update_date, 'YYYY/MM/DD'), sysdate);
      -- Find the component ID
      --
      l_layout_component_id :=
            find_component_id(
               p_component_name=> p_component_name,
               p_layout_name=> p_layout_name
            );

      BEGIN
         -- check to see the row exists
         SELECT layout_comp_qualifier_id,
                object_version_number,
                last_update_date,
                last_updated_by
           INTO l_layout_comp_qualifier_id,
                l_object_version_number,
                l_last_update_date_db,
                l_last_updated_by_db
           FROM hxc_layout_comp_qualifiers
          WHERE qualifier_name = p_qualifier_name
            AND layout_component_id = l_layout_component_id;

         IF (fnd_load_util.upload_test(
                l_last_updated_by_f,
                l_last_update_date_f,
                l_last_updated_by_db,
                l_last_update_date_db,
                p_custom_mode
             )
            )
         THEN
            --
            -- Use the Row handler to update the row
            --
            hxc_ulq_upd.upd(
               p_layout_component_id=> l_layout_component_id,
               p_qualifier_name=> p_qualifier_name,
               p_qualifier_attribute_category=> p_qualifier_attribute_category,
               p_qualifier_attribute1=> p_qualifier_attribute1,
               p_qualifier_attribute2=> p_qualifier_attribute2,
               p_qualifier_attribute3=> p_qualifier_attribute3,
               p_qualifier_attribute4=> p_qualifier_attribute4,
               p_qualifier_attribute5=> p_qualifier_attribute5,
               p_qualifier_attribute6=> p_qualifier_attribute6,
               p_qualifier_attribute7=> p_qualifier_attribute7,
               p_qualifier_attribute8=> p_qualifier_attribute8,
               p_qualifier_attribute9=> p_qualifier_attribute9,
               p_qualifier_attribute10=> p_qualifier_attribute10,
               p_qualifier_attribute11=> p_qualifier_attribute11,
               p_qualifier_attribute12=> p_qualifier_attribute12,
               p_qualifier_attribute13=> p_qualifier_attribute13,
               p_qualifier_attribute14=> p_qualifier_attribute14,
               p_qualifier_attribute15=> p_qualifier_attribute15,
               p_qualifier_attribute16=> p_qualifier_attribute16,
               p_qualifier_attribute17=> p_qualifier_attribute17,
               p_qualifier_attribute18=> p_qualifier_attribute18,
               p_qualifier_attribute19=> p_qualifier_attribute19,
               p_qualifier_attribute20=> p_qualifier_attribute20,
               p_qualifier_attribute21=> p_qualifier_attribute21,
               p_qualifier_attribute22=> p_qualifier_attribute22,
               p_qualifier_attribute23=> p_qualifier_attribute23,
               p_qualifier_attribute24=> p_qualifier_attribute24,
               p_qualifier_attribute25=> p_qualifier_attribute25,
               p_qualifier_attribute26=> p_qualifier_attribute26,
               p_qualifier_attribute27=> p_qualifier_attribute27,
               p_qualifier_attribute28=> p_qualifier_attribute28,
               p_qualifier_attribute29=> p_qualifier_attribute29,
               p_qualifier_attribute30=> p_qualifier_attribute30,
               p_layout_comp_qualifier_id=> l_layout_comp_qualifier_id,
               p_object_version_number=> l_object_version_number
            );
         ELSE
            IF hxc_layouts_upload_pkg.g_force_ok
            THEN
               hxc_ulq_upd.upd(
                  p_layout_component_id=> l_layout_component_id,
                  p_qualifier_name=> p_qualifier_name,
                  p_qualifier_attribute_category=> p_qualifier_attribute_category,
                  p_qualifier_attribute1=> p_qualifier_attribute1,
                  p_qualifier_attribute2=> p_qualifier_attribute2,
                  p_qualifier_attribute3=> p_qualifier_attribute3,
                  p_qualifier_attribute4=> p_qualifier_attribute4,
                  p_qualifier_attribute5=> p_qualifier_attribute5,
                  p_qualifier_attribute6=> p_qualifier_attribute6,
                  p_qualifier_attribute7=> p_qualifier_attribute7,
                  p_qualifier_attribute8=> p_qualifier_attribute8,
                  p_qualifier_attribute9=> p_qualifier_attribute9,
                  p_qualifier_attribute10=> p_qualifier_attribute10,
                  p_qualifier_attribute11=> p_qualifier_attribute11,
                  p_qualifier_attribute12=> p_qualifier_attribute12,
                  p_qualifier_attribute13=> p_qualifier_attribute13,
                  p_qualifier_attribute14=> p_qualifier_attribute14,
                  p_qualifier_attribute15=> p_qualifier_attribute15,
                  p_qualifier_attribute16=> p_qualifier_attribute16,
                  p_qualifier_attribute17=> p_qualifier_attribute17,
                  p_qualifier_attribute18=> p_qualifier_attribute18,
                  p_qualifier_attribute19=> p_qualifier_attribute19,
                  p_qualifier_attribute20=> p_qualifier_attribute20,
                  p_qualifier_attribute21=> p_qualifier_attribute21,
                  p_qualifier_attribute22=> p_qualifier_attribute22,
                  p_qualifier_attribute23=> p_qualifier_attribute23,
                  p_qualifier_attribute24=> p_qualifier_attribute24,
                  p_qualifier_attribute25=> p_qualifier_attribute25,
                  p_qualifier_attribute26=> p_qualifier_attribute26,
                  p_qualifier_attribute27=> p_qualifier_attribute27,
                  p_qualifier_attribute28=> p_qualifier_attribute28,
                  p_qualifier_attribute29=> p_qualifier_attribute29,
                  p_qualifier_attribute30=> p_qualifier_attribute30,
                  p_layout_comp_qualifier_id=> l_layout_comp_qualifier_id,
                  p_object_version_number=> l_object_version_number
               );
            END IF; -- HXC_layouts_upload_pkg.g_force_ok
         END IF; -- p_custom_mode = 'FORCE'
      EXCEPTION
         WHEN no_data_found
         THEN
            --
            -- Use the Row handler to insert the row
            --
            hxc_ulq_ins.ins(
               p_layout_component_id=> l_layout_component_id,
               p_qualifier_name=> p_qualifier_name,
               p_qualifier_attribute_category=> p_qualifier_attribute_category,
               p_qualifier_attribute1=> p_qualifier_attribute1,
               p_qualifier_attribute2=> p_qualifier_attribute2,
               p_qualifier_attribute3=> p_qualifier_attribute3,
               p_qualifier_attribute4=> p_qualifier_attribute4,
               p_qualifier_attribute5=> p_qualifier_attribute5,
               p_qualifier_attribute6=> p_qualifier_attribute6,
               p_qualifier_attribute7=> p_qualifier_attribute7,
               p_qualifier_attribute8=> p_qualifier_attribute8,
               p_qualifier_attribute9=> p_qualifier_attribute9,
               p_qualifier_attribute10=> p_qualifier_attribute10,
               p_qualifier_attribute11=> p_qualifier_attribute11,
               p_qualifier_attribute12=> p_qualifier_attribute12,
               p_qualifier_attribute13=> p_qualifier_attribute13,
               p_qualifier_attribute14=> p_qualifier_attribute14,
               p_qualifier_attribute15=> p_qualifier_attribute15,
               p_qualifier_attribute16=> p_qualifier_attribute16,
               p_qualifier_attribute17=> p_qualifier_attribute17,
               p_qualifier_attribute18=> p_qualifier_attribute18,
               p_qualifier_attribute19=> p_qualifier_attribute19,
               p_qualifier_attribute20=> p_qualifier_attribute20,
               p_qualifier_attribute21=> p_qualifier_attribute21,
               p_qualifier_attribute22=> p_qualifier_attribute22,
               p_qualifier_attribute23=> p_qualifier_attribute23,
               p_qualifier_attribute24=> p_qualifier_attribute24,
               p_qualifier_attribute25=> p_qualifier_attribute25,
               p_qualifier_attribute26=> p_qualifier_attribute26,
               p_qualifier_attribute27=> p_qualifier_attribute27,
               p_qualifier_attribute28=> p_qualifier_attribute28,
               p_qualifier_attribute29=> p_qualifier_attribute29,
               p_qualifier_attribute30=> p_qualifier_attribute30,
               p_layout_comp_qualifier_id=> l_layout_comp_qualifier_id,
               p_object_version_number=> l_object_version_number
            );
      END;
   END load_qualifier_row;
-- =================================================================
-- == load_rule_row
-- =================================================================
/*
PROCEDURE LOAD_RULE_ROW
   (P_QUALIFIER_NAME IN VARCHAR2
   ,P_RULE_NAME IN VARCHAR2
   ,P_OWNER IN VARCHAR2
   ,P_RULE_TYPE IN VARCHAR2
   ,P_RULE_DETAIL IN VARCHAR2
   ,P_RULE_VALUE IN VARCHAR2
   ,P_CUSTOM_MODE IN VARCHAR2
   )
IS
--
l_layout_comp_qualifier_id    HXC_LAYOUT_COMP_QUALIFIERS.LAYOUT_COMP_QUALIFIER_ID%TYPE;
l_layout_comp_qual_rule_id HXC_LAYOUT_COMP_QUAL_RULES.LAYOUT_COMP_QUAL_RULE_ID%TYPE;
l_object_version_number HXC_LAYOUT_COMP_QUAL_RULES.OBJECT_VERSION_NUMBER%TYPE;
--
BEGIN
   --
   -- Obtain the qualifier id
   --
   l_layout_comp_qualifier_id :=
      find_comp_qualifier_id
         (P_COMP_QUALIFIER_NAME => P_QUALIFIER_NAME
         );
   --
   BEGIN
      SELECT layout_comp_qual_rule_id
            ,object_version_number
        INTO l_layout_comp_qual_rule_id
            ,l_object_version_number
        FROM HXC_LAYOUT_COMP_QUAL_RULES
       WHERE rule_name = p_rule_name;

      IF (p_custom_mode = 'FORCE') THEN
         --
         -- Use the row handler to update the rule data
         --
         HXC_ULR_UPD.UPD
            (P_RULE_NAME                    => P_RULE_NAME
            ,P_RULE_TYPE                    => P_RULE_TYPE
            ,P_LAYOUT_COMP_QUALIFIER_ID     => l_layout_comp_qualifier_id
            ,P_RULE_DETAIL                  => P_RULE_DETAIL
            ,P_RULE_VALUE                   => P_RULE_VALUE
            ,P_LAYOUT_COMP_QUAL_RULE_ID     => l_layout_comp_qual_rule_id
            ,P_OBJECT_VERSION_NUMBER        => l_object_version_number
            );
      ELSE
         IF  HXC_layouts_upload_pkg.g_force_ok THEN
            --
            -- Use the row handler to update the rule data
            --
            HXC_ULR_UPD.UPD
               (P_RULE_NAME                    => P_RULE_NAME
               ,P_RULE_TYPE                    => P_RULE_TYPE
               ,P_LAYOUT_COMP_QUALIFIER_ID     => l_layout_comp_qualifier_id
               ,P_RULE_DETAIL                  => P_RULE_DETAIL
               ,P_RULE_VALUE                   => P_RULE_VALUE
               ,P_LAYOUT_COMP_QUAL_RULE_ID     => l_layout_comp_qual_rule_id
               ,P_OBJECT_VERSION_NUMBER        => l_object_version_number
               );
         END IF; -- HXC_layouts_upload_pkg.g_force_ok
      END IF; -- p_custom_mode = 'FORCE'
   EXCEPTION WHEN NO_DATA_FOUND THEN
      --
      -- Use the row handler to insert the rule data
      --
      HXC_ULR_INS.INS
         (P_RULE_NAME                    => P_RULE_NAME
         ,P_RULE_TYPE                    => P_RULE_TYPE
         ,P_LAYOUT_COMP_QUALIFIER_ID     => l_layout_comp_qualifier_id
         ,P_RULE_DETAIL                  => P_RULE_DETAIL
         ,P_RULE_VALUE                   => P_RULE_VALUE
         ,P_LAYOUT_COMP_QUAL_RULE_ID     => l_layout_comp_qual_rule_id
         ,P_OBJECT_VERSION_NUMBER        => l_object_version_number
         );
   END;
END LOAD_RULE_ROW;
*/

END hxc_layouts_upload_pkg;

/
