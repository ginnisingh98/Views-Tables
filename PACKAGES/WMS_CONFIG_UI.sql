--------------------------------------------------------
--  DDL for Package WMS_CONFIG_UI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WMS_CONFIG_UI" AUTHID CURRENT_USER AS
  /* $Header: WMSCFGUIS.pls 115.1 2004/01/22 21:39:32 kkandiku noship $ */


  TYPE t_fields_list IS REF CURSOR;
  TYPE t_page_level_props IS REF CURSOR;

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
                x_return_status		      OUT NOCOPY VARCHAR2);

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
                 x_return_status	          OUT NOCOPY VARCHAR2);


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
                x_return_status		      OUT NOCOPY VARCHAR2);

END WMS_CONFIG_UI;

 

/
