--------------------------------------------------------
--  DDL for Package Body HXC_LOV_MIGRATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_LOV_MIGRATION" AS
/* $Header: hxclovmig.pkb 115.3 2004/03/30 15:57:33 mstewart noship $ */


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
    WHEN NO_DATA_FOUND THEN
      FND_MESSAGE.SET_NAME('HXC','HXC_INVALID_APPL_NAME');
      FND_MESSAGE.RAISE_ERROR;
  END find_application_id;

  -- =================================================================
  -- == get_region_row
  -- =================================================================
  FUNCTION get_region_row
     (p_region_code            IN ak_regions_vl.region_code%TYPE
     ,p_application_id         IN fnd_application.application_id%TYPE
     )
  RETURN ak_regions_vl%ROWTYPE
  IS
    l_region_row  ak_regions_vl%ROWTYPE;
  BEGIN
    SELECT *
      INTO l_region_row
      FROM ak_regions_vl
     WHERE region_code = p_region_code
       AND region_application_id = p_application_id;

    -- check region is an LOV region
    IF l_region_row.region_style <> 'LOV' THEN
      fnd_message.set_name('HXC', 'HXC_NOT_LOV_REGION');
      fnd_message.raise_error;
    END IF;

    RETURN l_region_row;

  EXCEPTION
    WHEN NO_DATA_FOUND then
      FND_MESSAGE.SET_NAME('HXC','HXC_AK_REGION_NOT_FOUND');
      FND_MESSAGE.RAISE_ERROR;
  END get_region_row;

  PROCEDURE migrate_region
     (p_region_code            IN ak_regions_vl.region_code%TYPE
     ,p_application_id         IN fnd_application.application_id%TYPE
     )
  IS
  --
  region_row              ak_regions_vl%ROWTYPE;

  region_obj              jdr_docbuilder.DOCUMENT;
  top_level_element       jdr_docbuilder.ELEMENT;
  table_element           jdr_docbuilder.ELEMENT;
  attribute_element       jdr_docbuilder.ELEMENT;

  mapping_obj             jdr_docbuilder.DOCUMENT;
  mapping_element         jdr_docbuilder.ELEMENT;

  l_document_name         VARCHAR2(80);
  result_code             PLS_INTEGER;

  l_mapping_id            NUMBER;
  l_parent_id             NUMBER;
  l_max_sequence          NUMBER;
  --
  CURSOR csr_get_region_items(p_ak_region_code  VARCHAR2, p_ak_region_app_id  NUMBER)
  IS
  SELECT *
    FROM ak_region_items_vl
   WHERE region_code = p_ak_region_code
     AND region_application_id = p_ak_region_app_id
   ORDER BY display_sequence;
  --
  BEGIN
    -- verify the region exists, and is an LOV region and get the required attributes to set
    region_row := get_region_row(p_region_code, p_application_id);

    -- create the ak-mds mapping
    mapping_obj := jdr_docbuilder.createChildDocument('/oracle/apps/hxc/regionMap/' || p_region_code);
    mapping_element := jdr_docbuilder.createElement(jdr_docbuilder.OA_NS, 'listOfValues');
    jdr_docbuilder.setAttribute(mapping_element, 'docName', p_region_code);
    jdr_docbuilder.setAttribute(mapping_element, 'extends', '/oracle/apps/hxc/selfservice/configui/webui/' || p_region_code);
    jdr_docbuilder.setAttribute(mapping_element, 'user:akRegionStyle', 'LOV');
    jdr_docbuilder.setTopLevelElement(mapping_obj, mapping_element);

    -- save the MDS document
    result_code := jdr_docbuilder.save;

    IF result_code <> jdr_docbuilder.SUCCESS THEN
      fnd_message.set_name('HXC', 'HXC_MDS_MAP_SAVE_FAILED');
      fnd_message.raise_error;
    END IF;

    -- create the mds document object
    region_obj := jdr_docbuilder.createDocument('/oracle/apps/hxc/selfservice/configui/webui/' || p_region_code);

    -- create the top level element
    top_level_element := jdr_docbuilder.createElement(jdr_docbuilder.OA_NS, 'listOfValues');

    jdr_docbuilder.setAttribute(top_level_element, 'amDefName', region_row.applicationmodule_object_type);
    jdr_docbuilder.setAttribute(top_level_element, 'controllerClass', region_row.region_object_type);
    jdr_docbuilder.setAttribute(top_level_element, 'title', region_row.name);
    --jdr_docbuilder.setAttribute(top_level_element, 'xmlns', 'http://xmlns.oracle.com/jrad');
    --jdr_docbuilder.setAttribute(top_level_element, 'xmlns:ui', 'http://xmlns.oracle.com/uix/ui');
    --jdr_docbuilder.setAttribute(top_level_element, 'xmlns:oa', 'http://xmlns.oracle.com/oa');
    --jdr_docbuilder.setAttribute(top_level_element, 'xmlns:user', 'http://xmlns.oracle.com/jrad/user');
    jdr_docbuilder.setAttribute(top_level_element, 'file-version', '$Header: hxclovmig.pkb 115.3 2004/03/30 15:57:33 mstewart noship $');
    --jdr_docbuilder.setAttribute(top_level_element, 'version', '9.0.3.6.2_398');

    jdr_docbuilder.setTopLevelElement(region_obj, top_level_element);


    table_element := jdr_docbuilder.createElement(jdr_docbuilder.OA_NS, 'table');
    jdr_docbuilder.setAttribute(table_element, 'name', region_row.region_code);
    jdr_docbuilder.setAttribute(table_element, 'id', region_row.region_code || '_lovTable');
    jdr_docbuilder.setAttribute(table_element, 'akRegionCode', region_row.region_code);
    jdr_docbuilder.setAttribute(table_element, 'regionName', region_row.name);
    jdr_docbuilder.setAttribute(table_element, 'blockSize', region_row.num_rows_display);
    jdr_docbuilder.setAttribute(table_element, 'standalone', 'true');

    jdr_docbuilder.addChild(top_level_element, jdr_docbuilder.UI_NS, 'contents', table_element);

    -- now loop through the child elements, adding a node for each one
    FOR region_attr_row IN csr_get_region_items(p_region_code, p_application_id) LOOP
      attribute_element := jdr_docbuilder.createElement(jdr_docbuilder.OA_NS, 'messageStyledText');
      IF region_attr_row.node_query_flag = 'Y' THEN
        jdr_docbuilder.setAttribute(attribute_element, 'queryable', 'true');
      END IF;

      IF region_attr_row.node_display_flag = 'N' THEN
        jdr_docbuilder.setAttribute(attribute_element, 'rendered', 'false');
      END IF;

      jdr_docbuilder.setAttribute(attribute_element, 'vAlign', region_attr_row.vertical_alignment);
      jdr_docbuilder.setAttribute(attribute_element, 'columns', region_attr_row.display_value_length);
      jdr_docbuilder.setAttribute(attribute_element, 'prompt', region_attr_row.attribute_label_long);

      IF region_attr_row.data_type IN ('NUMBER', 'DATE') THEN
        jdr_docbuilder.setAttribute(attribute_element, 'dataType', region_attr_row.data_type);
      END IF;

      jdr_docbuilder.setAttribute(attribute_element, 'rows', region_attr_row.display_height);
      jdr_docbuilder.setAttribute(attribute_element, 'viewName', region_attr_row.view_usage_name);
      jdr_docbuilder.setAttribute(attribute_element, 'viewAttr', region_attr_row.view_attribute_name);
      jdr_docbuilder.setAttribute(attribute_element, 'maximumLength', region_attr_row.attribute_value_length);
      jdr_docbuilder.setAttribute(attribute_element, 'id', region_attr_row.item_name);
      jdr_docbuilder.setAttribute(attribute_element, 'promptTranslationExpansion', '100%');
      jdr_docbuilder.setAttribute(attribute_element, 'user:akAttributeCode', region_attr_row.attribute_code);
      jdr_docbuilder.setAttribute(attribute_element, 'user:akAttributeApplicationId', region_attr_row.attribute_application_id);

      IF region_attr_row.data_type = 'DATE' THEN
        jdr_docbuilder.setAttribute(attribute_element, 'tipType', 'dateFormat');
      END IF;

      jdr_docbuilder.addChild(table_element, jdr_docbuilder.UI_NS, 'contents', attribute_element);
    END LOOP;

    -- save the MDS document
    result_code := jdr_docbuilder.save;

    IF result_code <> jdr_docbuilder.SUCCESS THEN
      fnd_message.set_name('HXC', 'HXC_MDS_SAVE_FAILED');
      fnd_message.raise_error;
    END IF;

  END migrate_region;

  FUNCTION mds_doc_exists
    (p_region_code  IN AK_REGIONS_VL.REGION_CODE%TYPE
    )
  RETURN BOOLEAN
  IS
  BEGIN
    --
    RETURN jdr_docbuilder.documentExists('/oracle/apps/hxc/selfservice/configui/webui/' || p_region_code);
    --
  END mds_doc_exists;

  -- =================================================================
  -- == migrate_lov_region
  -- =================================================================
  PROCEDURE migrate_lov_region
    (p_region_code            IN AK_REGIONS_VL.REGION_CODE%TYPE DEFAULT NULL
    ,p_region_app_short_name  IN FND_APPLICATION.APPLICATION_SHORT_NAME%TYPE DEFAULT NULL
    ,p_force                  IN VARCHAR2 DEFAULT NULL
    )
  IS
  --
  region_app_id   fnd_application.application_id%TYPE;
  l_app_short_name    FND_APPLICATION.APPLICATION_SHORT_NAME%TYPE DEFAULT NULL;
  l_force         BOOLEAN := FALSE;
  --
  CURSOR csr_get_regions IS
    SELECT region_code
      FROM  ak_regions
     WHERE region_application_id = 809
       AND region_style = 'LOV'
       AND region_code NOT IN
            ('HXCAPPROVALPEOPLELOV'
            ,'HXC_CUI_LOV_PROJECT'
            ,'HXC_CUI_LOV_TASK'
            ,'HXC_CUI_LOV_EXPTYPE'
            ,'HXC_CUI_LOV_SYSLINKFUNC'
            ,'HXC_CUI_PROJECT_LOV'
            ,'HXC_CUI_EXPTYPE_LOV'
            ,'HXC_CUI_TASK_LOV'
            ,'HXC_CUI_LOV_EXPTYPE_ELEMENT'
            ,'HXC_CUI_OVERRIDE_APPROVER_LOV'
            ,'HXC_CUI_PROJECT_B_LOV'
            ,'HXC_CUI_TASK_B_LOV');
  --
  BEGIN
    --
    IF p_force IS NOT NULL THEN
      IF p_force = 'Y' THEN
        l_force := TRUE;
      END IF;
    END IF;

    -- default the app if not set
    IF (p_region_app_short_name IS NULL) THEN
      l_app_short_name := 'HXC';
    ELSE
      l_app_short_name := p_region_app_short_name;
    END IF;

    -- validate the app short name and get the id
    region_app_id := find_application_id(l_app_short_name);

    -- now determine if we are going to migrate multiple LOV regions
    -- or just a specific one
    IF (p_region_code IS NULL) THEN
      -- migrate all non-seeded hxc regions
      FOR mig_region_row IN csr_get_regions LOOP
        --
        IF (l_force OR (NOT l_force AND NOT mds_doc_exists(mig_region_row.region_code))) THEN
          migrate_region(mig_region_row.region_code, region_app_id);
        END IF;
        --
      END LOOP;
    ELSE
      -- migrate the single specified region
      IF (l_force OR (NOT l_force AND NOT mds_doc_exists(p_region_code))) THEN
        migrate_region(p_region_code, region_app_id);
      END IF;
    END IF;
  END migrate_lov_region;
END hxc_lov_migration;

/
