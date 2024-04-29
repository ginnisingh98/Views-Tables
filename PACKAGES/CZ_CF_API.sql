--------------------------------------------------------
--  DDL for Package CZ_CF_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CZ_CF_API" AUTHID CURRENT_USER AS
/*      $Header: czcfapis.pls 120.3.12010000.4 2010/04/14 00:18:19 smanna ship $  */
/*#
 * This package provides procedures and functions to perform various operations on configurations.
 * @rep:scope public
 * @rep:product CZ
 * @rep:displayname Configuration API
 * @rep:lifecycle active
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY CZ_MODEL_PUB
 * @rep:category BUSINESS_ENTITY CZ_CONFIG
 */

-- batch validation operation code
BV_OPERATION_UPDATE  CONSTANT  NUMBER := 1;
BV_OPERATION_DELETE  CONSTANT  NUMBER := 2;
BV_OPERATION_INSERT  CONSTANT  NUMBER := 3;
BV_OPERATION_REVERT  CONSTANT  NUMBER := 4;

-- seeded ui def
NATIVEBOM_UI_DEF     CONSTANT  NUMBER := 101;

TYPE config_item_rec_type IS RECORD
  (config_item_id cz_config_items.config_item_id%TYPE
  ,component_code cz_config_items.node_identifier%TYPE
  ,sequence_nbr   cz_config_items.sequence_nbr%TYPE
  ,operation      number
  ,quantity       cz_config_items.item_num_val%TYPE
  ,instance_name  cz_config_items.name%TYPE
  ,location_id    cz_config_items.location_id%TYPE
  ,location_type_code  cz_config_items.location_type_code%TYPE
  );

TYPE config_ext_attr_rec_type IS RECORD
  (config_item_id  cz_config_ext_attributes.config_item_id%TYPE
  ,component_code  VARCHAR2(1200)
  ,sequence_nbr    NUMBER
  ,attribute_name  cz_config_ext_attributes.attribute_name%TYPE
  ,attribute_group cz_config_ext_attributes.attribute_group%TYPE
  ,attribute_value cz_config_ext_attributes.attribute_value%TYPE
  );

TYPE config_item_tbl_type IS TABLE OF config_item_rec_type
       INDEX BY BINARY_INTEGER;

TYPE config_ext_attr_tbl_type IS TABLE OF config_ext_attr_rec_type
       INDEX BY BINARY_INTEGER;

TYPE INPUT_SELECTION IS RECORD(component_code  varchar2(1200),
                               quantity   number,
                               input_seq  number,
                               config_item_id number default NULL);

TYPE CFG_INPUT_LIST IS table of INPUT_SELECTION index by binary_integer;

SUBTYPE CFG_OUTPUT_PIECES IS UTL_HTTP.HTML_PIECES;

TYPE NUMBER_TBL_TYPE IS table of NUMBER;
TYPE DATE_TBL_TYPE IS table of DATE;
TYPE VARCHAR2_TBL_TYPE IS table of VARCHAR2(255);

TYPE NUMBER_TBL_INDEXBY_TYPE IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
TYPE DATE_TBL_INDEXBY_TYPE IS TABLE OF DATE INDEX BY BINARY_INTEGER;
TYPE NUMBER_TBL_INDEXBY_CHAR_TYPE IS TABLE OF NUMBER INDEX BY VARCHAR2(15);
--------------------------------------------------------------------------------------------

INIT_MESSAGE_LIMIT            constant NUMBER := 8096;

--------------------------Validation status return codes----------------------------------
CONFIG_PROCESSED              constant NUMBER :=0;
CONFIG_PROCESSED_NO_TERMINATE constant NUMBER :=1;
INIT_TOO_LONG                 constant NUMBER :=2;
INVALID_OPTION_REQUEST        constant NUMBER :=3;
CONFIG_EXCEPTION              constant NUMBER :=4;
DATABASE_ERROR                constant NUMBER :=5;
UTL_HTTP_INIT_FAILED          constant NUMBER :=6;
UTL_HTTP_REQUEST_FAILED       constant NUMBER :=7;
--vsingava 14th Jul '09 bug7674190
-- CZ_CF_API would never use this. status code '8' is thrown by
-- CZ_BATCH_VALIDATE package if the hosting applications still calls the older version
-- INVALID_VALIDATION_TYPE       constant NUMBER :=8;

INVALID_ALTBATCHVALIDATE_URL  constant NUMBER :=9;
------------------------------------------------------------------------------------------

/*#
 * This procedure copies a configuration in the database. It cannot be used to copy networked configuration models.
 * If the NEW_CONFIG_FLAG is 1, then a new CONFIG_HDR_ID value is generated for the new configuration and it has a
 * CONFIG_REV_NBR of 1. If NEW_CONFIG_FLAG is 0, the copy keeps the CONFIG_HDR_ID and has a CONFIG_REV_NBR
 * incremented to be greater than the original.
 * @param config_hdr_id Configuration header ID
 * @param config_rev_nbr Configuration revision number
 * @param new_config_flag A value of '1' indicates that the copied configuration should have a new CONFIG_HDR_ID.
 *                        A value of '0' creates a new revision of the existing configuration.  This new revision
 *                        will have the same CONFIG_HDR_ID as the original and a unique CONFIG_REV_NBR.
 * @param out_config_hdr_id Configuration header ID of the new copy of the configuration.
 * @param out_config_rev_nbr Configuration revision number of the new copy of the configuration.
 * @param error_message If there is an error in the procedure execution, this field contains a message describing the error.
 * @param return_value If the return value is 1, then the configuration was successfully copied. If the return value is 0,
 *                     then the copy of the configuration failed.
 * @param handle_deleted_flag When '0', it will undelete the copied configuration if the original configuration is deleted.
 * @param new_name Applies a new name for the configuration.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Copy Configuration
 * @rep:category BUSINESS_ENTITY CZ_CONFIG
 */
PROCEDURE copy_configuration(config_hdr_id       IN  NUMBER,
                             config_rev_nbr      IN  NUMBER,
                             new_config_flag     IN  VARCHAR2,
                             out_config_hdr_id   IN OUT NOCOPY NUMBER,
                             out_config_rev_nbr  IN OUT NOCOPY NUMBER,
                             error_message       IN OUT NOCOPY VARCHAR2,
                             return_value        IN OUT NOCOPY NUMBER,
                             handle_deleted_flag IN  VARCHAR2 DEFAULT NULL,
                             new_name            IN  VARCHAR2 DEFAULT NULL);
------------------------------------------------------------------------------------------

/*#
 * This procedure runs COPY_CONFIGURATION within an autonomous transaction.
 * If the copy is successful, new data will be committed to the database without affecting the caller's transaction.
 * See COPY_CONFIGURATION documentation for more details.
 * @param config_hdr_id Configuration header ID
 * @param config_rev_nbr Configuration revision number
 * @param new_config_flag A value of '1' indicates that the copied configuration should have a new CONFIG_HDR_ID.
 *                        A value of '0' creates a new revision of the existing configuration.  This new revision
 *                        will have the same CONFIG_HDR_ID as the original and a unique CONFIG_REV_NBR.
 * @param out_config_hdr_id Configuration header ID of the new copy of the configuration.
 * @param out_config_rev_nbr Configuration revision number of the new copy of the configuration.
 * @param error_message If there is an error in the procedure execution, this field contains a message describing the error.
 * @param return_value If the return value is 1, then the configuration was successfully copied. If the return value is 0,
 *                     then the copy of the configuration failed.
 * @param handle_deleted_flag When '0', it will undelete the copied configuration if the original configuration is deleted.
 * @param new_name Applies a new name for the configuration.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Copy Configuration
 * @rep:category BUSINESS_ENTITY CZ_CONFIG
 */
PROCEDURE copy_configuration_auto(config_hdr_id  IN  NUMBER,
                             config_rev_nbr      IN  NUMBER,
                             new_config_flag     IN  VARCHAR2,
                             out_config_hdr_id   IN OUT NOCOPY NUMBER,
                             out_config_rev_nbr  IN OUT NOCOPY NUMBER,
                             Error_message       IN OUT NOCOPY VARCHAR2,
                             Return_value        IN OUT NOCOPY NUMBER,
                             handle_deleted_flag IN  VARCHAR2 DEFAULT NULL,
                             new_name            IN  VARCHAR2 DEFAULT NULL);
---------------------------------------------------------------------------------------

/*#
 * This procedure removes a configuration from the database.
 * @param config_hdr_id Specifies the header ID of the configuration to be deleted.
 * @param config_rev_nbr Specifies the revision number of the configuration to be deleted.
 * @param usage_exists This returns 1 if a configuration usage record exists and the configuration is not deleted.
 *                     Note that configuration usages are obsolete.
 * @param error_message If there is an error, this field contains a message describing the error.
 * @param return_value If the return value is 1, then the configuration was successfully deleted.
 *                     If the return value is 0, then the deletion of the configuration failed.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Delete Configuration
 * @rep:category BUSINESS_ENTITY CZ_CONFIG
 */
PROCEDURE delete_configuration(config_hdr_id  IN  NUMBER,
                               config_rev_nbr IN  NUMBER,
                               usage_exists   IN OUT NOCOPY NUMBER,
                               Error_message  IN OUT NOCOPY VARCHAR2,
                               Return_value   IN OUT NOCOPY NUMBER);
------------------------------------------------------------------------------------------

/*#
 * Deletes a configuration usage.  Note that configuration usages are only created by custom code.
 * @param calling_application_id Application ID
 * @param calling_application_ref_key Application reference key
 * @param error_message If there is an error, this field contains a message describing the error.
 * @param return_value If the return value is 1, then the configuration usage was successfully deleted.
 *                     If the return value is 0, then the deletion of the configuration usage failed.
 * @rep:scope public
 * @rep:lifecycle obsolete
 * @rep:displayname Delete Configuration Usage
 * @rep:category BUSINESS_ENTITY CZ_CONFIG
 */
PROCEDURE delete_configuration_usage(calling_application_id      IN  NUMBER,
                                     calling_application_ref_key IN  NUMBER,
                                     Error_message               IN OUT NOCOPY VARCHAR2,
                                     Return_value                IN OUT NOCOPY NUMBER);
------------------------------------------------------------------------------------------

/*#
 * This procedure updates a configuration usage.
 * @param calling_application_id Application ID
 * @param calling_application_ref_key Application reference key
 * @param config_hdr_id Config header id
 * @param config_rev_nbr Config revision number
 * @param config_item_id Config item id
 * @param uom_code UOM code
 * @param list_price List price
 * @param discounted_price Discounted price
 * @param auto_discount_id Auto discount id
 * @param auto_discount_line_id Auto discount line id
 * @param auto_discount_pct Auto discount pct
 * @param manual_discount_id Manual discount id
 * @param manual_discount_line_id Manual discount line id
 * @param manual_discount_pct Manual discount percentage
 * @param error_message If there is an error, this field contains a message describing the error.
 * @param return_value If the return value is 1, then the configuration usage was successfully updated.
 *                     If the return value is 0, then the update of the configuration usage failed.
 * @rep:scope public
 * @rep:lifecycle obsolete
 * @rep:displayname Update Configuration Usage
 * @rep:category BUSINESS_ENTITY CZ_CONFIG
 */
PROCEDURE update_configuration_usage(calling_application_id      IN  NUMBER,
                                     calling_application_ref_key IN  NUMBER,
                                     config_hdr_id               IN  NUMBER,
                                     config_rev_nbr              IN  NUMBER,
                                     config_item_id              IN  NUMBER,
                                     uom_code                    IN  VARCHAR2,
                                     list_price                  IN  NUMBER,
                                     discounted_price            IN  NUMBER,
                                     auto_discount_id            IN  NUMBER,
                                     auto_discount_line_id       IN  NUMBER,
                                     auto_discount_pct           IN  NUMBER,
                                     manual_discount_id          IN  NUMBER,
                                     manual_discount_line_id     IN  NUMBER,
                                     manual_discount_pct         IN  NUMBER,
                                     Error_message               IN OUT NOCOPY VARCHAR2,
                                     Return_value                IN OUT NOCOPY NUMBER);

--------------------------------------------------------------------------------
-- API name:      validate
-- Package Name:  cz_cf_api
-- Type:          Public
-- Pre-reqs:      None
-- Function:      Validates a configuration
-- Version:       Current version 1.0
--                Initial version 1.0

procedure validate(p_api_version         IN  NUMBER
                  ,p_config_item_tbl     IN  config_item_tbl_type
                  ,p_config_ext_attr_tbl IN  config_ext_attr_tbl_type
                  ,p_url                 IN  VARCHAR2
                  ,p_init_msg            IN  VARCHAR2
                  ,p_validation_type     IN  VARCHAR2
                  ,x_config_xml_msg  OUT NOCOPY CFG_OUTPUT_PIECES
                  ,x_return_status   OUT NOCOPY VARCHAR2
                  ,x_msg_count       OUT NOCOPY NUMBER
                  ,x_msg_data        OUT NOCOPY VARCHAR2
                  );
--------------------------------------------------------------------------------
/*#
 * This procedure validates a configuration. You can use this procedure to check whether a configuration is still valid after an event
 * that may cause it to become invalid. Such events might include the following:
 *      A change in the configuration rules.
 *      The importing of the configuration from another system.
 *      A change to the configuration inputs by another program.
 * @param config_input_list This is a list of input selections.
 * @param init_message XML initialization message
 * @param config_messages This is a table of the output XML messages produced by validating the configuration.
 * @param validation_status The status code returned by validating the configuration: CONFIG_PROCESSED (0),
 *                          CONFIG_PROCESSED_NO_TERMINATE (1), INIT_TOO_LONG (2), INVALID_OPTION_REQUEST (3),
 *                          CONFIG_EXCEPTION (4), DATABASE_ERROR (5), UTL_HTTP_INIT_FAILED (6), UTL_HTTP_REQUEST_FAILED (7)
 * @param URL The URL for the Oracle Configurator Servlet. Default will interrogate the current profile for this URL,
 *                        using FND_PROFILE.Value('CZ_UIMGR_URL').
 * @param p_validation_type The possible values are CZ_API_PUB.VALIDATE_ORDER, CZ_API_PUB.VALIDATE_FULFILLMENT,
                            and CZ_API_PUB.INTERACTIVE. The default is CZ_API_PUB.VALIDATE_ORDER.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Validate
 * @rep:category BUSINESS_ENTITY CZ_CONFIG
 */
PROCEDURE VALIDATE (
-- single-call validation function uses tables to exchange multi-valued data
    config_input_list IN  CFG_INPUT_LIST,    -- input selections
    init_message      IN  VARCHAR2,          -- additional XML
    config_messages   IN OUT NOCOPY CFG_OUTPUT_PIECES, -- table of output XML messages
    validation_status IN OUT NOCOPY NUMBER,            -- status return
    URL               IN  VARCHAR2 DEFAULT FND_PROFILE.Value('CZ_UIMGR_URL'),
    p_validation_type IN  VARCHAR2 DEFAULT CZ_API_PUB.VALIDATE_ORDER);

--------------------------------------------------------------------------------
-- API name:      validate. For Qouting ER#9348864
-- Package Name:  cz_cf_api
-- Type:          Public
-- Pre-reqs:      None
-- Function:      Validates a configuration
-- Version:       Current version 1.0
--                Initial version 1.0
-- One new IN and OUT param added for Quoting requirement to check any configuration has changed or not.
----------------------------------------------------------------------------------
PROCEDURE VALIDATE (
    config_input_list IN  CFG_INPUT_LIST,    -- input selections
    init_message      IN  VARCHAR2,          -- additional XML
    config_messages   IN OUT NOCOPY CFG_OUTPUT_PIECES, -- table of output XML messages
    validation_status IN OUT NOCOPY NUMBER,            -- status return
    URL               IN  VARCHAR2 DEFAULT FND_PROFILE.Value('CZ_UIMGR_URL'),
    p_validation_type IN  VARCHAR2 DEFAULT CZ_API_PUB.VALIDATE_ORDER,
    p_check_config_flag IN  VARCHAR2 DEFAULT 'N', -- Flag to indicate if caller wants to know the config change status
    x_return_config_changed  OUT NOCOPY VARCHAR2); -- Return the config_changed_status

--------------------------------------------------------------------------------

/*#
 * This function returns a published Model based on the input inventory item ID, organization ID, and applicability.
 * @param inventory_item_id If the Model was imported from Oracle BOM,
 *                          this is the Inventory Item ID of the item on which the configuration model is based.
 * @param organization_id If the Model was imported from Oracle BOM, this is the organization ID of the item
 *                        on which the configuration model is based.
 * @param config_creation_date This is the lookup date for the publication.
 * @param user_id This is the ID of the Oracle Applications user that is logged in.
 * @param responsibility_id This is the responsibility of the Oracle Applications user in the host application.
 * @param calling_application_id The registered ID of an application for which the Model is published.
 * @return Devl_project_id of the configuration model published for this combination of inputs. NULL is returned if there is no matching publication.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Model For Item
 * @rep:category BUSINESS_ENTITY CZ_MODEL_PUB
 */
FUNCTION model_for_item(inventory_item_id  	NUMBER,
				organization_id		NUMBER,
				config_creation_date	DATE,
				user_id			NUMBER,
				responsibility_id 	NUMBER,
				calling_application_id  NUMBER
			)

RETURN NUMBER;
--------------------------------------------------------------------------------------------

/*#
 * This function finds a published configuration model for an item based on applicability parameters.
 * The function returns NULL if the Model cannot be found.
 * @param inventory_item_id If the Model was imported from Oracle BOM,
 *                          this is the Inventory Item ID of the item on which the published configuration model is based.
 * @param organization_id If the Model was imported from Oracle BOM, this is the organization ID of the item
 *                        on which the published configuration model is based.
 * @param config_lookup_date Date to search for inside the applicable range for the publication.
 * @param calling_application_id The registered ID of an application for which the Model is published.
 * @param usage_name Usage name to search for in the publication.
 * @param publication_mode Publication mode to search for in the publication.
 * @param language Language code to search for in the publication.
 * @return Devl_project_id of the configuration model published for this combination of inputs. NULL is returned if there is no matching publication.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Config Model For Item
 * @rep:category BUSINESS_ENTITY CZ_MODEL_PUB
 */
FUNCTION config_model_for_item (inventory_item_id  IN	NUMBER,
				organization_id		   IN	NUMBER,
				config_lookup_date	   IN	DATE,
				calling_application_id     IN	NUMBER,
				usage_name			   IN	VARCHAR2,
 				publication_mode		   IN	VARCHAR2 DEFAULT NULL,
				language			   IN	VARCHAR2 DEFAULT NULL
				)
RETURN NUMBER;
--------------------------------------------------------------------------------------------

/*#
 * This function finds the Models that are associated with each entry in a list of Inventory Items
 * that are published with the matching applicability parameters. The function returns the list of Model IDs (devl_project_id values)
 * that meet the specified parameters.
 * @param inventory_item_id If the Model was imported from Oracle BOM,
 *                          this is the Inventory Item ID of the item on which the published configuration model is based.
 * @param organization_id If the Model was imported from Oracle BOM, this is the organization ID of the item
 *                        on which the configuration model is based.
 * @param config_lookup_date Date to search for inside the applicable range for the publication.
 * @param calling_application_id The registered ID of an application for which the Model is published.
 * @param usage_name Usage name to search for in the publication.
 * @param publication_mode Publication mode to search for in the publication.
 * @param language Language code to search for in the publication.
 * @return An array in which each element is a devl_project_id value for the associated item. NULL is returned if there is no matching publication.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Config Models For Items
 * @rep:category BUSINESS_ENTITY CZ_MODEL_PUB
 */
FUNCTION config_models_for_items (inventory_item_id   IN	NUMBER_TBL_TYPE,
				organization_id			IN	NUMBER_TBL_TYPE,
				config_lookup_date		IN	DATE_TBL_TYPE,
				calling_application_id  	IN	NUMBER_TBL_TYPE,
				usage_name			      IN	VARCHAR2_TBL_TYPE,
 				publication_mode	      	IN	VARCHAR2_TBL_TYPE,
				language			      IN	VARCHAR2_TBL_TYPE
				)
RETURN NUMBER_TBL_TYPE;
--------------------------------------------------------------------------------------------

/*#
 * This function returns a UI definition (ui_def_id) for a given inventory item identified by inventory_item_id and
 * organization_id based on publication applicability parameters.
 * @param inventory_item_id If the Model was imported from Oracle BOM,
 *                          this is the Inventory Item ID of the item on which the configuration model is based.
 * @param organization_id If the Model was imported from Oracle BOM, this is the organization ID of the item
 *                        on which the configuration model is based.
 * @param config_creation_date This is the date the configuration was or will be created.
 * @param ui_type This is the type of UI sought and found for each product. Values are 'APPLET', 'DHTML', or 'JRAD'.
 *                If either DHTML or JRAD is passed, then the publication UI type must be either DHTML or JRAD.
 *                Otherwise NULL is returned.
 *                If APPLET is passed, then the publication UI type can be either APPLET, DHTML, or JRAD.
 *                If DHTML or JRAD is passed and there is no publication available for the item, then the API returns
 *                the user interface ID of the Generic Configurator UI.
 * @param user_id This is the ID for the Oracle Applications user that is logged in.
 * @param responsibility_id This is the responsibility that the Oracle Applications user has in the host application.
 * @param calling_application_id The registered ID of an application for which the model is published.
 * @return UI definition (ui_def_id) for a given inventory item identified by inventory_item_id and
 *         organization_id based on publication applicability parameters.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname UI For Item
 * @rep:category BUSINESS_ENTITY CZ_MODEL_PUB
 */
FUNCTION ui_for_item(inventory_item_id     NUMBER,
		     organization_id		 NUMBER,
		     config_creation_date	 DATE,
		     ui_type			 VARCHAR2,
		     user_id			 NUMBER,
		     responsibility_id		 NUMBER,
		     calling_application_id	 NUMBER
		    )
RETURN NUMBER;
--------------------------------------------------------------------------------------------

/*#
 * This function returns the user interface ID associated with the publication found for the input item,
 * organization ID, and applicability.
 * @param inventory_item_id If the Model was imported from Oracle BOM,
 *                          this is the Inventory Item ID of the item on which the configuration model is based.
 * @param organization_id If the Model was imported from Oracle BOM, this is the organization ID of the item
 *                        on which configuration model is based.
 * @param config_lookup_date Date to search for inside the applicable range for the publication.
 * @param ui_type This is the type of UI sought and found for each product. Values are 'APPLET', 'DHTML', or 'JRAD'.
 *                If either DHTML or JRAD is passed, then the publication UI type must be either DHTML or JRAD.
 *                Otherwise NULL is returned.  If APPLET is passed, then the publication UI type can be APPLET,
 *                DHTML, or JRAD.  If DHTML or JRAD is passed and there is no publication available for the item,
 *                then the API returns the user interface ID of the Generic Configurator UI.
 * @param calling_application_id The registered ID of an application for which the model is published.
 * @param usage_name Usage name to search for in the publication.
 * @param publication_mode Publication mode to search for in the publication.
 * @param language Language code to search for in the publication.
 * @return User interface ID associated with the selected publication.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Config UI For Item
 * @rep:category BUSINESS_ENTITY CZ_MODEL_PUB
 */
FUNCTION config_ui_for_item (inventory_item_id		IN	NUMBER,
		             organization_id			IN	NUMBER,
		             config_lookup_date		IN	DATE,
		             ui_type				IN OUT NOCOPY  VARCHAR2,
		             calling_application_id  	IN	NUMBER,
		             usage_name				IN	VARCHAR2,
  		             publication_mode			IN	VARCHAR2 DEFAULT NULL,
		             language				IN	VARCHAR2 DEFAULT NULL
		            )
RETURN NUMBER;

---------------------------------------------------------------------------

/*#
 * This function does the same work as CONFIG_UI_FOR_ITEM, but also returns the "look and feel" of the UI ('APPLET', 'BLAF', or 'FORMS').
 * @param inventory_item_id If the Model was imported from Oracle BOM,
 *                          this is the Inventory Item ID of the item on which the published configuration model is based.
 * @param organization_id If the Model was imported from Oracle BOM, this is the organization ID of the item
 *                        on which the published configuration model is based.
 * @param config_lookup_date Date to search for inside the applicable range for the publication.
 * @param ui_type Type of UI sought and found for each product. Values are 'APPLET', 'DHTML', or 'JRAD'.
 *                If either DHTML or JRAD is passed, then the publication UI type must be either DHTML or
 *                JRAD. Otherwise NULL is returned.  If APPLET is passed, then the publication UI type can be
 *                APPLET, DHTML, or JRAD.  If DHTML or JRAD is passed and there is no publication available for
 *                the item, then the API returns the user interface ID of the Generic Configurator UI.
 * @param calling_application_id The registered ID of an application for which the model is published.
 * @param usage_name Usage name to search for in the publication.
 * @param look_and_feel This is a tag that overrides the default look and feel for component-style UIs (when UI_STYLE=0) in the CZ_UI_DEFS table.
 * @param publication_mode Publication mode to search for in the publication.
 * @param language Language code to search for in the publication.
 * @return User interface ID associated with the selected publication.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Config UI For Item
 * @rep:category BUSINESS_ENTITY CZ_MODEL_PUB
 */
FUNCTION config_ui_for_item_lf (inventory_item_id	IN	NUMBER,
		             organization_id			IN	NUMBER,
		             config_lookup_date		IN	DATE,
		             ui_type				IN OUT NOCOPY  VARCHAR2,
		             calling_application_id  	IN	NUMBER,
		             usage_name				IN	VARCHAR2,
		             look_and_feel			OUT NOCOPY	VARCHAR2,
  		             publication_mode			IN	VARCHAR2 DEFAULT NULL,
		             language				IN	VARCHAR2 DEFAULT NULL
		            )
RETURN NUMBER;

---------------------------------------------------------------------------

/*#
 * This function returns a list of user interfaces that are associated with each entry in the list of Inventory Items
 * that are published with matching applicability parameters.
 * @param inventory_item_id If the Model was imported from Oracle BOM,
 *                          this is the Inventory Item ID of the item on which the published configuration model is based.
 * @param organization_id If the Model was imported from Oracle BOM, this is the organization ID of the item on which
 *                        the published configuration model is based.
 * @param config_lookup_date Date to search for inside the applicable range for the publication.
 * @param ui_type This is the type of UI sought and found for each product. Values are 'APPLET' or 'DHTML'.
 * @param calling_application_id The registered ID of an application for which the model is published.
 * @param usage_name Usage name to search for in the publication.
 * @param publication_mode Publication mode to search for in the publication.
 * @param language Language code to search for in the publication.
 * @return List of user interfaces that are associated with each entry in the list of Inventory Items that are published with matching applicability parameters.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Config UIs For Items
 * @rep:category BUSINESS_ENTITY CZ_MODEL_PUB
 */
FUNCTION config_uis_for_items (inventory_item_id	IN	NUMBER_TBL_TYPE,
		             organization_id			IN	NUMBER_TBL_TYPE,
		             config_lookup_date		IN	DATE_TBL_TYPE,
		             ui_type				IN OUT NOCOPY  VARCHAR2_TBL_TYPE,
		             calling_application_id  	IN	NUMBER_TBL_TYPE,
		             usage_name				IN	VARCHAR2_TBL_TYPE,
 		             publication_mode			IN	VARCHAR2_TBL_TYPE,
		             language				IN	VARCHAR2_TBL_TYPE
		            )
RETURN NUMBER_TBL_TYPE;

---------------------------------------------------------------------------

/*#
 * This function returns the Model ID (devl_project_id) for a specified publication.
 * @param publication_id This is the specified publication ID in the CZ_MODEL_PUBLICATIONS table.
 * @return Model ID for a specified publication.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Model For Publication ID
 * @rep:category BUSINESS_ENTITY CZ_MODEL_PUB
 */
FUNCTION model_for_publication_id (publication_id NUMBER)
RETURN NUMBER;

--------------------------------------------------------------------------------

/*#
 * This function returns a UI definition (ui_def_id) for a specified publication ID.
 * @param publication_id This is the specified publication id in the CZ_MODEL_PUBLICATIONS table.
 * @return UI definition (ui_def_id) for a specified publication ID.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname UI For Publication ID
 * @rep:category BUSINESS_ENTITY CZ_MODEL_PUB
 */
FUNCTION ui_for_publication_id (publication_id NUMBER)
RETURN NUMBER;

------------------------------------------------------------------------------
FUNCTION config_model_for_product ( product_key			IN	VARCHAR2,
				    config_lookup_date	 	IN	DATE,
				    calling_application_id  	IN	NUMBER,
				    usage_name			IN	VARCHAR2,
  				    publication_mode		IN	VARCHAR2 DEFAULT NULL,
				    language			IN	VARCHAR2 DEFAULT NULL
				  )
RETURN NUMBER;

-----------------------------------------------------------------------------------

FUNCTION config_models_for_products ( product_key			IN	VARCHAR2_TBL_TYPE,
				    config_lookup_date	 	IN	DATE_TBL_TYPE,
				    calling_application_id  	IN	NUMBER_TBL_TYPE,
				    usage_name			IN	VARCHAR2_TBL_TYPE,
 				    publication_mode		IN	VARCHAR2_TBL_TYPE,
				    language			IN	VARCHAR2_TBL_TYPE
				  )
RETURN NUMBER_TBL_TYPE;

-----------------------------------------------------------------------------------

FUNCTION config_ui_for_product (product_key			IN	VARCHAR2,
		                config_lookup_date		IN	DATE,
		                ui_type				IN OUT NOCOPY  VARCHAR2,
		                calling_application_id  	IN	NUMBER,
		                usage_name			IN	VARCHAR2,
 		                publication_mode		IN	VARCHAR2 DEFAULT NULL,
		                language			IN	VARCHAR2 DEFAULT NULL
		               )
RETURN NUMBER;

-----------------------------------------------------------------------------------

FUNCTION config_uis_for_products (product_key		IN	VARCHAR2_TBL_TYPE,
		                config_lookup_date		IN	DATE_TBL_TYPE,
		                ui_type				IN OUT NOCOPY  VARCHAR2_TBL_TYPE,
		                calling_application_id  	IN	NUMBER_TBL_TYPE,
		                usage_name			IN	VARCHAR2_TBL_TYPE,
 		                publication_mode		IN	VARCHAR2_TBL_TYPE,
		                language			IN	VARCHAR2_TBL_TYPE
		               )
RETURN NUMBER_TBL_TYPE;

-----------------------------------------------------------------------------------

FUNCTION publication_for_item   (inventory_item_id		IN	NUMBER,
		               	 organization_id		IN	NUMBER,
		      		 config_lookup_date		IN	DATE,
		      		 calling_application_id  	IN	NUMBER,
		     		 	 usage_name			IN	VARCHAR2,
 		      		 publication_mode		IN	VARCHAR2 DEFAULT NULL,
		      		 language			IN	VARCHAR2 DEFAULT NULL
		      		)
RETURN NUMBER;

-----------------------------------------------------------------------------------
FUNCTION publication_for_saved_config   (config_hdr_id		IN	NUMBER,
		               	 config_rev_nbr		IN	NUMBER,
		      		 config_lookup_date		IN	DATE,
		      		 calling_application_id  	IN	NUMBER,
		     		 	 usage_name			IN	VARCHAR2,
 		      		 publication_mode		IN	VARCHAR2 DEFAULT NULL,
		      		 language			IN	VARCHAR2 DEFAULT NULL
		      		)
RETURN NUMBER;

-----------------------------------------------------------------------------------
/*#
 * This function returns the publication ID for a specified product key and applicability parameters.
 * @param product_key Product key to search for in the publication.
 * @param config_lookup_date Date to search for inside the applicable range for the publication.
 * @param calling_application_id The registered ID of an application for which the Model is published.
 * @param usage_name Usage name to search for in the publication.
 * @param publication_mode Publication mode to search for in the publication.
 * @param language Language code to search for in the publication.
 * @return Publication ID for a product key.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Publication For Product
 * @rep:category BUSINESS_ENTITY CZ_MODEL_PUB
 */
FUNCTION publication_for_product(product_key 		IN	VARCHAR2,
		      		 config_lookup_date	IN	DATE,
		      		 calling_application_id IN	NUMBER,
		     		 	 usage_name			IN	VARCHAR2,
 		      		 publication_mode		IN	VARCHAR2 DEFAULT NULL,
		     		 	 language			IN	VARCHAR2 DEFAULT NULL
		      		)
RETURN NUMBER;

-------------------------------------------------------

-- Utility procedure for providing default date values for a
-- new configuration to the UI server.  The UI server will
-- pass all available dates, the procedure will return a value
-- for any dates not passed in.
/*#
 * This utility procedure provides default date values used by Oracle Configurator for a new configuration.
 * The caller should pass in dates that will be included in the initialization message for the runtime Oracle Configurator.
 * The procedure will return the value that will be used by the runtime Oracle Configurator for any date not passed in.
 * @param p_creation_date This specifies the creation date for the new configuration.
 * @param p_lookup_date This specifies the lookup date for the new configuration.
 * @param p_effective_date This specifies the effective date for the new configuration.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Default New Config Dates
 * @rep:category BUSINESS_ENTITY CZ_CONFIG
 */
PROCEDURE DEFAULT_NEW_CFG_DATES(p_creation_date  IN OUT NOCOPY DATE,
                                p_lookup_date    IN OUT NOCOPY DATE,
                                p_effective_date IN OUT NOCOPY DATE);

-------------------------------------------------------

-- Utility procedure for providing default date values for
-- a restored configuration to the UI server.  The UI server
-- will pass all available dates, the procedure will return a
-- value for any dates not passed in.  Config header ID and
-- config revision number must be supplied.
/*#
 * This utility procedure provides default date values used by Oracle Configurator for a restored configuration.
 * The caller should pass in dates that will be included in the initialization message for the runtime Oracle Configurator.
 * The procedure will return the value that will be used by the runtime Oracle Configurator for any dates not passed in.
 * The CONFIG_HEADER_ID and CONFIG_REV_NBR of the configuration to be restored must be supplied.
 * Default date values are determined differently for a restored configuration that for a new configuration.
 * @param p_config_hdr_id Specifies which configuration to use.
 * @param p_config_rev_nbr Specifies which configuration to use.
 * @param p_creation_date If this is not null, it will be returned as is. Otherwise, the existing setting for this configuration is returned.
 * @param p_lookup_date If this is not null, it will be returned as is. Otherwise, the existing setting for this configuration is returned.
 * @param p_effective_date If this is not null, it will be returned as is. Otherwise, the existing setting for this configuration is returned.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Default Restored Config Dates
 * @rep:category BUSINESS_ENTITY CZ_CONFIG
 */
PROCEDURE DEFAULT_RESTORED_CFG_DATES(p_config_hdr_id  IN NUMBER,
                                     p_config_rev_nbr IN NUMBER,
                                     p_creation_date  IN OUT NOCOPY DATE,
				     p_lookup_date    IN OUT NOCOPY DATE,
                                     p_effective_date IN OUT NOCOPY DATE);

-------------------------------------------------------

-- Returns session ticket that Applications should pass as
-- "icx_session_ticket" to the configurator.  This ticket
-- allows the configurator maintain the Apps session identity.
--
-- Returns NULL if user_id, resp_id, or appl_id are not defined
-- within Apps session, or if the icx calls fail.
/*#
 * This function returns a value for the session ticket that Oracle Applications should pass as "icx_session_ticket"
 * when calling Oracle Configurator. This ticket allows the runtime Oracle Configurator to maintain the Oracle
 * Applications session identity. A null value is returned if user_id, resp_id, or appl_id are not defined within
 * the Oracle Applications session or if the ICX calls to generate the ticket fail.
 * @return ICX ticket that represents the Oracle Applications session.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname ICX Session Ticket
 * @rep:category BUSINESS_ENTITY CZ_CONFIG
 */
 FUNCTION icx_session_ticket RETURN VARCHAR2;
 FUNCTION icx_session_ticket (p_session_id IN NUMBER) RETURN VARCHAR2;

------------------------------------------------------------------------------------------
-- Procedure to retrieve the inventory item and organization for the common bill by item,
-- for the organization and inventory_item passed in
-- This procedure is used by publication_for_item to retrieve the common bill's details
-- if the model has not been published
/*#
 * This procedure retrieves the common bill item, if any, for the organization ID and inventory item
 * ID that are passed in as parameters.
 * @param in_inventory_item_id Inventory Item ID of item for which a common bill may be defined.
 * @param in_organization_id Organization ID of item for which a common bill may be defined.
 * @param common_inventory_item_id Inventory Item ID of the common bill item. NULL if no common bill is defined.
 * @param common_organization_id Organization ID of the common bill Item. NULL if no common bill is defined.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Common Bill For Item
 * @rep:category BUSINESS_ENTITY CZ_MODEL_PUB
 */
PROCEDURE common_bill_for_item ( in_inventory_item_id		IN	NUMBER,
				         in_organization_id		IN	NUMBER,
					   common_inventory_item_id	OUT NOCOPY 	NUMBER,
				         common_organization_id	OUT NOCOPY	NUMBER
		      		 );

------------------------------------------------------------------------------------------

-- Procedure to retrieve the inventory item and organization for the common bill by product key,
-- for the product_key passed in
-- This procedure is used by publication_for_product to retrieve the common bill's details
-- if the model with the given product key has has not been published
PROCEDURE common_bill_for_product(v_product_key IN	VARCHAR2, c_product_key OUT NOCOPY VARCHAR2);

--------------------------------------------------------------------------------
-- Mobile application publication lookup
-- Returns publications which meet the following criteria for the input item
--   1. publication_mode is production
--   2. DHMTL UI
--   3. effectivity range overlapps with the input date range
--   4. fnd_application_id is the same as input p_calling_application_id
--   5. language is session language
-- Returns null arrays if no pub found
-- Note: if no pub found with the input usage, lookup for ANY_USAGE
--       if no pub found for the input org, lookup for common bill
PROCEDURE publication_for_item_mobile
             (p_inventory_item_id  IN  NUMBER
             ,p_organization_id    IN  NUMBER
             ,p_calling_application_id IN  NUMBER
             ,p_usage_name             IN  VARCHAR2
             ,p_pub_start_date         IN  DATE
             ,p_pub_end_date           IN  DATE
             ,x_publication_id_tbl    OUT NOCOPY number_tbl_indexby_type
             ,x_model_id_tbl          OUT NOCOPY number_tbl_indexby_type
             ,x_ui_def_id_tbl         OUT NOCOPY number_tbl_indexby_type
             ,x_start_date_tbl        OUT NOCOPY date_tbl_indexby_type
             ,x_last_update_date_tbl  OUT NOCOPY date_tbl_indexby_type
             ,x_model_type            OUT NOCOPY VARCHAR2
             );
--------------------------------------------------------------------------------
/*#
 * This function returns the product_key for a saved configuration.
 * @param p_config_hdr_id Specifies which configuration to use
 * @param p_config_rev_nbr Specifies which configuration to use
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Product Key For Saved Configuration
 * @rep:category BUSINESS_ENTITY CZ_MODEL_PUB
 */
FUNCTION product_key_for_saved_config(p_config_hdr_id       IN  NUMBER,
                                      p_config_rev_nbr      IN  NUMBER
		      		      )
RETURN VARCHAR2;
--------------------------------------------------------------------------------
/*#
 * This function returns the defined pool for a given Product Key.
 * @param p_product_key Product Key of a model for which the pool information is required.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Pool Token For a Product Key
 * @rep:category BUSINESS_ENTITY CZ_MODEL_PUB
 */
FUNCTION pool_token_for_product_key(p_product_key  IN VARCHAR2)
RETURN VARCHAR2;
--------------------------------------------------------------------------------
/*#
 * This procedure registers a given model to a given pool. If there doesn't exist any other models for this pool,
 * it would implicitly register Pool too to the application, with an autonomous transaction.
 * @param p_pool_identifier The pool to which the given model is to be registered
 * @param p_model_product_key Product Key of the model which is to be registered
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Register a model to Pool
 * @rep:category BUSINESS_ENTITY CZ_MODEL_PUB
 */
PROCEDURE register_model_to_pool(p_pool_identifier IN VARCHAR2,
                                p_model_product_key IN VARCHAR2);
--------------------------------------------------------------------------------
/*#
 * This procedure unregisters a given model from a given pool with an autonomous transaction.
 * @param p_pool_identifier The pool from which the given model is to be unregistered
 * @param p_model_product_key Product Key of the model which is to be unregistered
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Unregister a model from Pool
 * @rep:category BUSINESS_ENTITY CZ_MODEL_PUB
 */
PROCEDURE unregister_model_from_pool(p_pool_identifier IN VARCHAR2,
                                     p_model_product_key IN VARCHAR2);
--------------------------------------------------------------------------------
/*#
 * This procedure unregisters a given pool and all it's registered models with an autonomous transaction.
 * @param p_pool_identifier The pool which is to be unregistered
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Unregister a given Pool
 * @rep:category BUSINESS_ENTITY CZ_MODEL_PUB
 */
PROCEDURE unregister_pool(p_pool_identifier IN VARCHAR2);
--------------------------------------------------------------------------------

END CZ_CF_API;

/
