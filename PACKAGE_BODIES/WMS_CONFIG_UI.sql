--------------------------------------------------------
--  DDL for Package Body WMS_CONFIG_UI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMS_CONFIG_UI" AS
/* $Header: WMSCFGUIB.pls 115.2 2004/01/22 21:42:02 kkandiku noship $ */


   g_version_printed       BOOLEAN                   := FALSE;
   g_pkg_name              VARCHAR2 (30)             := 'WMS_CONFIG_UI';

   PROCEDURE DEBUG (p_message IN VARCHAR2, p_module IN VARCHAR2, p_level NUMBER)
   IS
      l_debug   NUMBER := NVL (fnd_profile.VALUE ('INV_DEBUG_TRACE'), 0);
   BEGIN
      IF NOT g_version_printed
      THEN
         inv_log_util.TRACE ('$Header: WMSCFGUIB.pls 115.2 2004/01/22 21:42:02 kkandiku noship $',
                             g_pkg_name,
                             9
                            );
         g_version_printed := TRUE;
      END IF;

      IF (l_debug = 1)
      THEN
         inv_log_util.TRACE (p_message,
                             g_pkg_name || '.' || p_module,
                             p_level
                            );
      END IF;
   END;

/**
  *   This procedure returns the fields' metadata + config values for
  *   the given page, template as a ref cursor.
  *   If the given tenplate is null or does not exist, the
  *   fields' metadata + config values for the default template are returned.
  *   If the default tenplate does not exist, the fields' metadata + config values
  *   for the default template are returned.

  *  @param   p_page_id              The page for which the fields are required
  *  @param   p_template_name        The template name for which the fields are required
  *  @param   p_organization_id      Organization ID
  *  @param   x_page_template_fields Cursor containg the fields list
  **/
  PROCEDURE   get_fields(
		            p_page_id               IN NUMBER   DEFAULT NULL,
		            p_template_name         IN VARCHAR2 DEFAULT NULL,
                p_organization_id       IN NUMBER   DEFAULT NULL,
		            p_get_page_level_props  IN VARCHAR2 DEFAULT 'N',
                x_page_template_fields  OUT NOCOPY t_fields_list, -- Page Template fields. Does not contain page level properties
                x_page_level_props      OUT NOCOPY t_page_level_props, -- Page level properties
		            x_return_template       OUT NOCOPY VARCHAR2,
                x_msg_count		          OUT NOCOPY NUMBER,
                x_msg_data		          OUT NOCOPY VARCHAR2,
                x_return_status		      OUT NOCOPY VARCHAR2)
  IS
    l_module_name  CONSTANT VARCHAR2 (30) := 'GET_FIELDS';
    l_template_id  NUMBER;
    l_temp_template_id  NUMBER;
  BEGIN
    DEBUG ('  p_page_id             ==> ' || p_page_id, l_module_name, 9);
    DEBUG ('  p_template_name       ==> ' || p_template_name, l_module_name, 9);
    DEBUG ('  p_organization_id     ==> ' || p_organization_id, l_module_name, 9);
    DEBUG ('  p_get_page_level_props==> ' || p_get_page_level_props, l_module_name, 9);
    x_return_status := FND_API.G_RET_STS_SUCCESS;
	IF (p_page_id IS NULL) OR (p_organization_id IS NULL) THEN
      DEBUG ('  Not Enough Inputs: pageId or OrgId is NULL', l_module_name, 9);
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
    -- Get the template Id for the given page, template name and Org
    get_template(
           	 p_page_id          => p_page_id,
  		       p_template_name    => p_template_name,
             p_organization_id  => p_organization_id,
             x_template_id      => l_template_id,
             x_return_template  => x_return_template,
             x_msg_count		    => x_msg_count,
             x_msg_data		      => x_msg_data,
             x_return_status	  => x_return_status);
    IF x_return_status <> 'S' THEN
      DEBUG(' Error in getting the Template id ', l_module_name, 9);
      l_template_id := -1;
      DEBUG(' Defaulting Temaplte ID : ' || l_template_id, l_module_name, 9);
    ELSE
      DEBUG(' Found Temaplte ID : ' || l_template_id, l_module_name, 9);
    END IF;

    IF(p_page_id = 2) THEN
      l_temp_template_id := -1;
    ELSE
      l_temp_template_id := l_template_id;
    END IF;
    DEBUG (' Fetching  the page fields', l_module_name, 9);
    OPEN x_page_template_fields FOR
		SELECT  PAGE_ID
		      , FIELD_ID
		      , FIELD_DISP_SEQUENCE_NUMBER
		      , FIELD_NAME
		      , FIELD_TYPE
		      , FIELD_CONSTRUCTOR_PARAM
		      , FIELD_PROMPT
		      , FIELD_IS_CONFIGURABLE
		      , FIELD_CATEGORY
		      , FIELD_PROPERTY1_DEFAULT_VALUE
		      , FIELD_PROPERTY2_DEFAULT_VALUE
		      , FIELD_IS_VISIBLE
		      , TEMPLATE_ID
		      , TEMPLATE_NAME
		      , USER_TEMPLATE_NAME
		      , TEMPLATE_DESCRIPTION
		      , CREATING_ORGANIZATION_ID
		      , CREATING_ORGANIZATION_CODE
		      , COMMON_TO_ALL_ORGS
		      , ENABLED
        	, FIELD_PROPERTY1_VALUE
		      , FIELD_PROPERTY2_VALUE
		FROM WMS_PAGE_CONFIG_UI_V
		WHERE PAGE_ID  =  p_page_id
		  AND TEMPLATE_ID =  -1
		  AND FIELD_IS_CONFIGURABLE <> 'Y'
		  AND FIELD_CATEGORY <> 'PAGE'
      UNION ALL
		SELECT  PAGE_ID
		      , FIELD_ID
		      , FIELD_DISP_SEQUENCE_NUMBER
		      , FIELD_NAME
		      , FIELD_TYPE
		      , FIELD_CONSTRUCTOR_PARAM
		      , FIELD_PROMPT
		      , FIELD_IS_CONFIGURABLE
		      , FIELD_CATEGORY
		      , FIELD_PROPERTY1_DEFAULT_VALUE
		      , FIELD_PROPERTY2_DEFAULT_VALUE
		      , FIELD_IS_VISIBLE
		      , TEMPLATE_ID
		      , TEMPLATE_NAME
		      , USER_TEMPLATE_NAME
		      , TEMPLATE_DESCRIPTION
		      , CREATING_ORGANIZATION_ID
		      , CREATING_ORGANIZATION_CODE
		      , COMMON_TO_ALL_ORGS
		      , ENABLED
         	, FIELD_PROPERTY1_VALUE
		      , FIELD_PROPERTY2_VALUE
		FROM WMS_PAGE_CONFIG_UI_V
		WHERE PAGE_ID  =  p_page_id
		  AND TEMPLATE_ID =  l_temp_template_id
		  AND FIELD_IS_CONFIGURABLE = 'Y'
		  AND FIELD_CATEGORY <> 'PAGE'
    ORDER BY FIELD_DISP_SEQUENCE_NUMBER;

    -- Get page level properties
    IF(p_get_page_level_props = 'Y') THEN
      DEBUG (' Fetching  the page level properties', l_module_name, 9);
      IF l_template_id <> -1 THEN
        OPEN x_page_level_props FOR
          SELECT WPF.FIELD_NAME, WPF.FIELD_CATEGORY, WTF.FIELD_PROPERTY1_VALUE, WTF.FIELD_PROPERTY2_VALUE, WPF.FIELD_PROPERTY1_DEFAULT_VALUE, WPF.FIELD_PROPERTY2_DEFAULT_VALUE
          FROM WMS_PAGE_FIELDS_VL WPF, WMS_PAGE_TEMPLATE_FIELDS WTF
          WHERE WPF.PAGE_ID = WTF.PAGE_ID
            AND WPF.FIELD_ID = WTF.FIELD_ID
            AND WPF.PAGE_ID = p_page_id
            AND WTF.TEMPLATE_ID = l_template_id
            AND WPF.FIELD_CATEGORY = 'PAGE';
      ELSE
        OPEN x_page_level_props FOR
          SELECT FIELD_NAME, FIELD_CATEGORY, -1, -1, FIELD_PROPERTY1_DEFAULT_VALUE, FIELD_PROPERTY2_DEFAULT_VALUE
          FROM WMS_PAGE_FIELDS_VL
          WHERE PAGE_ID = p_page_id
            AND FIELD_CATEGORY = 'PAGE';
      END IF;
    END IF;
  EXCEPTION
   	WHEN OTHERS THEN
		x_return_status := FND_API.G_RET_STS_ERROR;
   		DEBUG (' Error in getting the fields ',l_module_name, 9);
   		DEBUG (' ERROR CODE = ' || SQLCODE, l_module_name, 9);
   		DEBUG (' ERROR MESSAGE = ' || SQLERRM, l_module_name, 9);
  END get_fields;


/**
  *   This procedure returns the template id for the the given page, template name
  *   and organization
  *   If the given tenplate is null or does not exist, the default template id is returned
  *   If the default tenplate does not exist, -1 is returned

  *  @param   p_page_id          The page for which the fields are required
  *  @param   p_template_name    The template name for which the fields are required
  *  @param   p_organization_id  Organization ID
  *  @param   x_template_id      Template ID
  **/
  PROCEDURE   get_template(
                 p_page_id                  IN  NUMBER   DEFAULT NULL,
                 p_template_name            IN  VARCHAR2 DEFAULT NULL,
                 p_organization_id          IN  NUMBER   DEFAULT NULL,
                 x_template_id              OUT NOCOPY NUMBER,
                 x_return_template          OUT NOCOPY VARCHAR2,
                 x_msg_count		            OUT NOCOPY NUMBER,
                 x_msg_data		              OUT NOCOPY VARCHAR2,
                 x_return_status	          OUT NOCOPY VARCHAR2)
  IS
    l_module_name  CONSTANT VARCHAR2 (30) := 'GET_TEMPLATE';
    l_parent_page_id  NUMBER;
  BEGIN
    DEBUG ('  p_page_id         ==> ' || p_page_id, l_module_name, 9);
    DEBUG ('  p_template_name   ==> ' || p_template_name, l_module_name, 9);
    DEBUG ('  p_organization_id ==> ' || p_organization_id, l_module_name, 9);
    x_return_status := FND_API.G_RET_STS_SUCCESS;
	IF (p_page_id IS NULL) OR (p_organization_id IS NULL) THEN
      DEBUG ('  Not Enough Inputs, pageId or OrgId is NULL', l_module_name, 9);
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

   IF p_page_id = 2 THEN
    l_parent_page_id := 1;
   END IF;

   IF(p_template_name IS NOT NULL) THEN
    BEGIN
     select template_id, template_name
     into x_template_id, x_return_template
     from WMS_PAGE_TEMPLATES_VL
     where page_id in (p_page_id, nvl(l_parent_page_id, p_page_id ))
	   and template_name = p_template_name
 	   and enabled = 'Y'
	   and decode(common_to_all_orgs,
                'Y', -99,
                'N', creating_organization_id,
                creating_organization_id) = decode (common_to_all_orgs, 'Y', -99,
                                                    'N', p_organization_id,
                                                    p_organization_id);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        DEBUG (' INVALID TEMAPLTE : The given template does not exist ',l_module_name, 9);
      WHEN OTHERS THEN
        DEBUG (' Error in getting the Template id ',l_module_name, 9);
        DEBUG (' ERROR CODE = ' || SQLCODE, l_module_name, 9);
        DEBUG (' ERROR MESSAGE = ' || SQLERRM, l_module_name, 9);
      END;
   END IF;
   DEBUG ('  x_template_id     ==> ' || x_template_id, l_module_name, 9);
   DEBUG ('  x_return_template ==> ' || x_return_template, l_module_name, 9);

  -- If template Name is null or the given tenplate name does not exist
  -- get the default template for the given Page
  IF(p_template_name IS NULL) OR (x_template_id IS NULL)THEN
    DEBUG ('  Getting the Default Template for the Page' || x_template_id, l_module_name, 9);
   BEGIN
    select template_id, template_name
    into x_template_id, x_return_template
    from WMS_PAGE_TEMPLATES_VL
    where page_id in (p_page_id, nvl(l_parent_page_id, p_page_id ))
	  and enabled = 'Y'
	  and default_flag = 'Y';
   DEBUG ('  x_template_id ==> ' || x_template_id, l_module_name, 9);
   DEBUG ('  x_return_template ==> ' || x_return_template, l_module_name, 9);
   EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DEBUG (' Default Template Does Not Exist ',l_module_name, 9);
        x_template_id := -1;
	WHEN OTHERS THEN
		x_return_status := FND_API.G_RET_STS_ERROR;
        x_template_id := -1;
   		DEBUG (' Error in getting the Template id ',l_module_name, 9);
   		DEBUG (' ERROR CODE = ' || SQLCODE, l_module_name, 9);
   		DEBUG (' ERROR MESSAGE = ' || SQLERRM, l_module_name, 9);
   END;
  END IF;
  END get_template;

/**
  *   This procedure returns the fields' metadata + config values for
  *   the given page, template as a ref cursor.
  *   If the given tenplate is null or does not exist, the
  *   fields' metadata + config values for the default template are returned.
  *   If the default tenplate does not exist, the fields' metadata + config values
  *   for the default template are returned.

  *  @param   p_page_id              The page for which the fields are required
  *  @param   p_template_name        The template name for which the fields are required
  *  @param   p_organization_id      Organization ID
  *  @param   x_page_template_fields Cursor containg the fields list
  **/
  PROCEDURE   get_field_properties(
		            p_page_id               IN NUMBER   DEFAULT NULL,
		            p_template_name         IN VARCHAR2 DEFAULT NULL,
                p_organization_id       IN NUMBER   DEFAULT NULL,
		            p_field_name            IN VARCHAR2 DEFAULT NULL,
                x_field_properties      OUT NOCOPY t_fields_list, -- Does not contain page level properties
                x_msg_count		          OUT NOCOPY NUMBER,
                x_msg_data		          OUT NOCOPY VARCHAR2,
                x_return_status		      OUT NOCOPY VARCHAR2)
  IS
    l_module_name  CONSTANT VARCHAR2 (30) := 'GET_FIELD_PROPERTIES';
    l_template_id  NUMBER;
    l_return_template VARCHAR2 (128);
  BEGIN
    DEBUG ('  p_page_id         ==> ' || p_page_id, l_module_name, 9);
    DEBUG ('  p_template_name   ==> ' || p_template_name, l_module_name, 9);
    DEBUG ('  p_field_name      ==> ' || p_field_name, l_module_name, 9);
    DEBUG ('  p_organization_id ==> ' || p_organization_id, l_module_name, 9);
    x_return_status := FND_API.G_RET_STS_SUCCESS;
	IF (p_page_id IS NULL) OR (p_organization_id IS NULL) THEN
      DEBUG ('  Not Enough Inputs, pageId or OrgId is NULL', l_module_name, 9);
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
    -- Get the template Id for the given page, template name and Org
    get_template(
           	 p_page_id          => p_page_id,
  		       p_template_name    => p_template_name,
             p_organization_id  => p_organization_id,
             x_template_id      => l_template_id,
             x_return_template  => l_return_template,
             x_msg_count		    => x_msg_count,
             x_msg_data		      => x_msg_data,
             x_return_status	  => x_return_status);
    IF x_return_status <> 'S' THEN
      DEBUG(' Error in getting the Template id ', l_module_name, 9);
      l_template_id := -1;
      DEBUG(' Defaulting Temaplte ID : ' || l_template_id, l_module_name, 9);
    ELSE
      DEBUG(' Found Temaplte ID : ' || l_template_id, l_module_name, 9);
    END IF;

    -- Fetch the field info for the given page_id and template_id
    -- Selecting all the columns to re-use the config field object constructor
    OPEN x_field_properties FOR
     SELECT WPF.PAGE_ID
		      , WPF.FIELD_ID
		      , WPF.FIELD_DISP_SEQUENCE_NUMBER
		      , WPF.FIELD_NAME
		      , WPF.FIELD_TYPE
		      , WPF.FIELD_CONSTRUCTOR_PARAM
		      , WPF.FIELD_PROMPT
		      , WPF.FIELD_IS_CONFIGURABLE
		      , WPF.FIELD_CATEGORY
		      , WPF.FIELD_PROPERTY1_DEFAULT_VALUE
		      , WPF.FIELD_PROPERTY2_DEFAULT_VALUE
		      , WPF.FIELD_IS_VISIBLE
		      , WTF.TEMPLATE_ID
		      , null
		      , null
		      , null
		      , -1
		      , null
		      , null
		      , null
         	, WTF.FIELD_PROPERTY1_VALUE
		      , WTF.FIELD_PROPERTY2_VALUE
      FROM WMS_PAGE_FIELDS_VL WPF , WMS_PAGE_TEMPLATE_FIELDS WTF
      WHERE WPF.PAGE_ID = WTF.PAGE_ID
        AND WPF.FIELD_ID = WTF.FIELD_ID
        AND WPF.PAGE_ID = p_page_id
        AND WTF.TEMPLATE_ID = l_template_id
        AND WPF.FIELD_NAME = p_field_name;

  EXCEPTION
   	WHEN OTHERS THEN
		x_return_status := FND_API.G_RET_STS_ERROR;
   		DEBUG (' Error in getting the field properties for field : '||p_field_name,l_module_name, 9);
   		DEBUG (' ERROR CODE = ' || SQLCODE, l_module_name, 9);
   		DEBUG (' ERROR MESSAGE = ' || SQLERRM, l_module_name, 9);
  END get_field_properties;

END WMS_CONFIG_UI;

/
