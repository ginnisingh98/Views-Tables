--------------------------------------------------------
--  DDL for Package CZ_MODELOPERATIONS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CZ_MODELOPERATIONS_PUB" AUTHID CURRENT_USER AS
/*  $Header: czmodops.pls 120.4.12010000.3 2008/09/12 09:59:10 jonatara ship $    */
/*#
 * This is the public interface to operations on configuration models and configuration UIs.
 * @rep:scope public
 * @rep:product CZ
 * @rep:displayname Model Operations API
 * @rep:lifecycle active
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY CZ_CONFIG_MODEL
 * @rep:category BUSINESS_ENTITY CZ_RP_FOLDER
 * @rep:category BUSINESS_ENTITY CZ_USER_INTERFACE
 */

------------------------------------------------------------------------------------------
--    CONSTANTS
--integer constant for object_id of the ROOT folder in Repository
RP_ROOT_FOLDER      CONSTANT PLS_INTEGER:=0;

------------------------------------------------------------------------------------------
-- Start of comments
--    API name    : Generate_Logic
--    Type        : Public.
--    Function    : Generates logic for a model
--    Pre-reqs    : None.
--    Parameters  :
--    IN          :     p_api_version           IN NUMBER         Required
--                      p_devl_project_id       IN NUMBER         Required
--                            Devl_project_id of the model
--    OUT NOCOPY         :     x_run_id                OUT NOCOPY NUMBER        Required
--                            CZ_DB_LOGS.run_id if there are warnings and/or errors, 0 if not
--                      x_status                OUT NOCOPY NUMBER        Required
--                            G_ERROR, G_WARNING or G_SUCCESS (constants from this package)
--    Version     : Current version       1.0
--                  Initial version       1.0
--    Notes       :
--
-- End of comments
/*#
 * Generate Logic
 * @param p_api_version api version
 * @param p_devl_project_id devl_project_id of the model
 * @param x_run_id CZ_DB_LOGS.run_id if there are warnings and/or errors, 0 if not
 * @param x_status G_ERROR, G_WARNING or G_SUCCESS (constants from this package)
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Generate Logic
 * @rep:category BUSINESS_ENTITY CZ_CONFIG_MODEL
 */
PROCEDURE generate_logic(p_api_version     IN  NUMBER,
                         p_devl_project_id IN  NUMBER,
                         x_run_id          OUT NOCOPY NUMBER,
                         x_status          OUT NOCOPY NUMBER);

--------------------------------------------------------------------------------------------

-- Start of comments
--    API name    : Generate_Logic
--    Type        : Public.
--    Function    : Generates logic for a model
--    Pre-reqs    : None.
--    Parameters  :
--    IN          :     p_api_version           IN NUMBER         Required
--                      p_devl_project_id       IN NUMBER         Required
--                            devl_project_id of the model
--                      p_user_id               IN NUMBER         Required
--                            user id
--                      p_resp_id               IN NUMBER         Required
--                            responsibility id
--                      p_appl_id               IN NUMBER         Required
--                            application id
--    OUT NOCOPY         :     x_run_id                OUT NOCOPY NUMBER        Required
--                            CZ_DB_LOGS.run_id if there are warnings and/or errors, 0 if not
--                      x_status                OUT NOCOPY NUMBER        Required
--                            G_ERROR, G_WARNING or G_SUCCESS (constants from this package)
--    Version     : Current version       1.0
--                  Initial version       1.0
--    Notes       :
--
-- End of comments
/*#
 * Generate Logic
 * @param p_api_version api version
 * @param p_devl_project_id devl_project_id of the model
 * @param p_user_id user id
 * @param p_resp_id responsibility id
 * @param p_appl_id application id
 * @param x_run_id CZ_DB_LOGS.run_id if there are warnings and/or errors, 0 if not
 * @param x_status G_ERROR, G_WARNING or G_SUCCESS (constants from this package)
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Generate Logic
 * @rep:category BUSINESS_ENTITY CZ_CONFIG_MODEL
 */
PROCEDURE generate_logic(p_api_version     IN  NUMBER,
                         p_devl_project_id IN  NUMBER,
                         p_user_id         IN NUMBER,
                         p_resp_id         IN NUMBER,
                         p_appl_id         IN NUMBER,
                         x_run_id          OUT NOCOPY NUMBER,
                         x_status          OUT NOCOPY NUMBER);

-----------------------------------------
-- Start of comments
--    API name    : Create_UI
--    Type        : Public.
--    Function    : Generates a new user interface for a model
--    Pre-reqs    : None.
--    Parameters  :
--    IN          :     p_api_version           IN NUMBER         Required
--                      p_devl_project_id       IN NUMBER         Optional
--                            Devl_project_id of the model
--                      p_ui_style              IN  VARCHAR2      Optional
--                            DEFAULT 'COMPONENTS'
--                            '0' or 'COMPONENTS' for DHTML UI, '3' or 'APPLET' for Applet UI.  Default is 'COMPONENTS'.
--                      p_frame_allocation      IN  NUMBER        Optional
--                            DEFAULT 30
--                            left frame allocation in %
--                      p_width                 IN  NUMBER        Optional
--                            DEFAULT 640
--                            width in pixels of UI screens
--                      p_height                IN  NUMBER        Optional
--                           DEFAULT 480
--                            height in pixels of UI screens.
--                      p_show_all_nodes        IN  VARCHAR2      Optional
--                            DEFAULT '0'
--                            If '1' then UI will be created for all nodes including do not display in UI' nodes,
--                            if '0' then display in UI flag is respected.
--                      p_look_and_feel         IN  VARCHAR2      Optional
--                            DEFAULT 'BLAF'
--                            Other possibilities are: 'APPLET' and 'FORMS'
--                      p_wizard_style          IN  VARCHAR2      Optional
--                            DEFAULT '0'
--                            wizard style navigation, default is '0' (means 'No'), another option is '1' (means 'Yes')
--                      p_max_bom_per_page      IN  NUMBER        Optional
--                            DEFAULT 10
--                            maximum number of BOM option class children per screen
--                      p_use_labels            IN  VARCHAR2      Optional
--                            DEFAULT '1'
--                            Generate caption from (Description, Name or Description,name)
--    OUT NOCOPY         :     x_ui_def_id             OUT NOCOPY NUMBER        Optional
--                         ui_def_id of new UI
--                      x_run_id                OUT NOCOPY NUMBER        Optional
--                            CZ_DB_LOGS.run_id if there are errors, 0 if not
--                      x_status                OUT NOCOPY NUMBER        Optional
--                            G_ERROR or G_SUCCESS (constants from this package)
--    Version     : Current version       1.0
--                  Initial version       1.0
--    Notes       : If referenced models are present, the behavior is the following:
--                  1. If a referenced model has one or more user interfaces of the input style (DHTML or Applet),
--                     the root UI will refer to the last created UI with this style.
--                  2. If a referenced model has no user interface, the procedure will generate a new UI for that model.
--
-- End of comments
/*#
 * Create new UI
 * @param p_api_version api version
 * @param p_devl_project_id devl_project_id of the model.
 * @param x_ui_def_id  ui_def_id of generated UI.
 * @param x_run_id CZ_DB_LOGS.run_id if there are warnings and/or errors, 0 if not
 * @param x_status G_ERROR, G_WARNING or G_SUCCESS (constants from this package)
 * @param p_ui_style '0' or 'COMPONENTS' for DHTML UI, '3' or 'APPLET' for Applet UI.  Default is 'COMPONENTS'.
 * @param p_frame_allocation left frame allocation in %.
 * @param p_width width in pixels of UI screens.
 * @param p_height height in pixels of UI screens.
 * @param p_show_all_nodes If '1' then UI will be created for all nodes including do not display in UI' nodes,if '0' then display in UI flag is respected.
 * @param p_look_and_feel Other possibilities are: 'APPLET' and 'FORMS'
 * @param p_wizard_style wizard style navigation, default is '0' (means 'No'), another option is '1' (means 'Yes')
 * @param p_max_bom_per_page maximum number of BOM option class children per screen
 * @param p_use_labels Generate caption from (Description, Name or Description,name)
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create new UI
 * @rep:category BUSINESS_ENTITY CZ_USER_INTERFACE
 */
PROCEDURE create_ui(p_api_version      IN  NUMBER,
                    p_devl_project_id  IN  NUMBER,
                    x_ui_def_id        OUT NOCOPY NUMBER,
                    x_run_id           OUT NOCOPY NUMBER,
                    x_status           OUT NOCOPY NUMBER,
                    p_ui_style         IN  VARCHAR2 ,
                    p_frame_allocation IN  NUMBER   ,
                    p_width            IN  NUMBER   ,
                    p_height           IN  NUMBER   ,
                    p_show_all_nodes   IN  VARCHAR2 ,
                    p_look_and_feel    IN  VARCHAR2 ,
                    p_wizard_style     IN  VARCHAR2 ,
                    p_max_bom_per_page IN  NUMBER   ,
                    p_use_labels       IN  VARCHAR2);

-- Start of comments
--    API name    : Create_UI
--    Type        : Public.
--    Function    : Generates a new user interface for a model
--    Pre-reqs    : None.
--    Parameters  :
--    IN          :     p_api_version           IN NUMBER         Required
--                      p_devl_project_id       IN NUMBER         Required
--                            Devl_project_id of the model
--                      p_user_id               IN NUMBER         Required
--                        user is
--                      p_resp_id               IN NUMBER         Required
--                        responsibility id
--                      p_appl_id               IN NUMBER         Required
--                        application id
--                      x_ui_def_id             OUT NOCOPY  NUMBER Required
--                        id of newly generated UI
--                      p_ui_style              IN  VARCHAR2      Optional
--                            DEFAULT 'COMPONENTS'
--                            '0' or 'COMPONENTS' for DHTML UI, '3' or 'APPLET' for Applet UI.  Default is 'COMPONENTS'.
--                      p_frame_allocation      IN  NUMBER        Optional
--                            DEFAULT 30
--                            left frame allocation in %
--                      p_width                 IN  NUMBER        Optional
--                            DEFAULT 640
--                            width in pixels of UI screens
--                      p_height                IN  NUMBER        Optional
--                           DEFAULT 480
--                            height in pixels of UI screens.
--                      p_show_all_nodes        IN  VARCHAR2      Optional
--                            DEFAULT '0'
--                            If '1' then UI will be created for all nodes including do not display in UI' nodes,
--                            if '0' then display in UI flag is respected.
--                      p_look_and_feel         IN  VARCHAR2      Optional
--                            DEFAULT 'BLAF'
--                            Other possibilities are: 'APPLET' and 'FORMS'
--                      p_wizard_style          IN  VARCHAR2      Optional
--                            DEFAULT '0'
--                            wizard style navigation, default is '0' (means 'No'), another option is '1' (means 'Yes')
--                      p_max_bom_per_page      IN  NUMBER        Optional
--                            DEFAULT 10
--                            maximum number of BOM option class children per screen
--                      p_use_labels            IN  VARCHAR2      Optional
--                            DEFAULT '1'
--                            Generate caption from (Description, Name or Description,name)
--    OUT NOCOPY         :     x_ui_def_id             OUT NOCOPY NUMBER        Optional
--                         ui_def_id of new UI
--                      x_run_id                OUT NOCOPY NUMBER        Optional
--                            CZ_DB_LOGS.run_id if there are errors, 0 if not
--                      x_status                OUT NOCOPY NUMBER        Optional
--                            G_ERROR or G_SUCCESS (constants from this package)
--    Version     : Current version       1.0
--                  Initial version       1.0
--    Notes       : If referenced models are present, the behavior is the following:
--                  1. If a referenced model has one or more user interfaces of the input style (DHTML or Applet),
--                     the root UI will refer to the last created UI with this style.
--                  2. If a referenced model has no user interface, the procedure will generate a new UI for that model.
--
-- End of comments
/*#
 * Create new UI
 * @param p_api_version api version
 * @param p_devl_project_id devl_project_id of the model.
 * @param p_user_id user id
 * @param p_resp_id responsibility id
 * @param p_appl_id application id
 * @param x_ui_def_id  ui_def_id of generated UI.
 * @param x_run_id CZ_DB_LOGS.run_id if there are warnings and/or errors, 0 if not
 * @param x_status G_ERROR, G_WARNING or G_SUCCESS (constants from this package)
 * @param p_ui_style '0' or 'COMPONENTS' for DHTML UI, '3' or 'APPLET' for Applet UI.  Default is 'COMPONENTS'.
 * @param p_frame_allocation left frame allocation in %.
 * @param p_width width in pixels of UI screens.
 * @param p_height height in pixels of UI screens.
 * @param p_show_all_nodes If '1' then UI will be created for all nodes including do not display in UI' nodes,if '0' then display in UI flag is respected.
 * @param p_look_and_feel Other possibilities are: 'APPLET' and 'FORMS'
 * @param p_wizard_style wizard style navigation, default is '0' (means 'No'), another option is '1' (means 'Yes')
 * @param p_max_bom_per_page maximum number of BOM option class children per screen
 * @param p_use_labels Generate caption from (Description, Name or Description,name)
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create new UI
 * @rep:category BUSINESS_ENTITY CZ_USER_INTERFACE
 */
PROCEDURE create_ui(p_api_version      IN  NUMBER,
                    p_devl_project_id  IN  NUMBER,
                    p_user_id          IN NUMBER,
                    p_resp_id          IN NUMBER,
                    p_appl_id          IN NUMBER,
                    x_ui_def_id        OUT NOCOPY NUMBER,
                    x_run_id           OUT NOCOPY NUMBER,
                    x_status           OUT NOCOPY NUMBER,
                    p_ui_style         IN  VARCHAR2 ,
                    p_frame_allocation IN  NUMBER   ,
                    p_width            IN  NUMBER   ,
                    p_height           IN  NUMBER   ,
                    p_show_all_nodes   IN  VARCHAR2 ,
                    p_look_and_feel    IN  VARCHAR2 ,
                    p_wizard_style     IN  VARCHAR2 ,
                    p_max_bom_per_page IN  NUMBER   ,
                    p_use_labels       IN  VARCHAR2 );



--------------------------------------------------------------------------------------------
-- Start of comments
--    API name    : create_JRAD_UI
--    Type        : Public.
--    Function    : Generates a new JRAD style user interface for a model
--    Pre-reqs    : None.
--    Parameters  :
--    IN          :
--      p_api_version         -- identifies version of API
--      p_devl_project_id     -- identifies Model for which UI will be generated
--      p_show_all_nodes      -- '1' - ignore ps node property "DO NOT SHOW IN UI"
--      p_master_template_id  -- identifies UI Master Template
--      p_create_empty_ui     -- '1' - create empty UI ( which contains only one record in CZ_UI_DEFS )
--      x_ui_def_id           -- ui_def_id of UI that has been generated
--    OUT         :
--      x_return_status       -- status string
--      x_msg_count           -- number of error messages
--      x_msg_data            -- string which contains error messages
--
--    Version     : Current version       1.0
--                  Initial version       1.0
--    Notes       :
--
-- End of comments
--
/*#
 * Create new JRAD style UI
 * @param p_api_version api version
 * @param p_devl_project_id devl_project_id of the model.
 * @param p_show_all_nodes '1' - ignore ps node property "DO NOT SHOW IN UI"
 * @param p_master_template_id identifies UI Master Template
 * @param p_create_empty_ui '1' - create empty UI ( which contains only one record in CZ_UI_DEFS )
 * @param x_ui_def_id  ui_def_id of generated UI.
 * @param x_return_status status string
 * @param x_msg_count number of error messages
 * @param x_msg_data string which contains error messages
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create new JRAD style UI
 * @rep:category BUSINESS_ENTITY CZ_USER_INTERFACE
 */
PROCEDURE create_jrad_ui(p_api_version        IN  NUMBER,
                         p_devl_project_id    IN  NUMBER,
                         p_show_all_nodes     IN  VARCHAR2,
                         p_master_template_id IN  NUMBER,
                         p_create_empty_ui    IN  VARCHAR2,
                         x_ui_def_id          OUT NOCOPY NUMBER,
                         x_return_status      OUT NOCOPY VARCHAR2,
                         x_msg_count          OUT NOCOPY NUMBER,
                         x_msg_data           OUT NOCOPY VARCHAR2);

/*#
 * Create new JRAD style UI
 * @param p_api_version api version
 * @param p_user_id user id
 * @param p_resp_id responsibility id
 * @param p_appl_id application id
 * @param p_devl_project_id devl_project_id of the model.
 * @param p_show_all_nodes '1' - ignore ps node property "DO NOT SHOW IN UI"
 * @param p_master_template_id identifies UI Master Template
 * @param p_create_empty_ui '1' - create empty UI ( which contains only one record in CZ_UI_DEFS )
 * @param x_ui_def_id  ui_def_id of generated UI.
 * @param x_return_status status string
 * @param x_msg_count number of error messages
 * @param x_msg_data string which contains error messages
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create new JRAD style UI
 * @rep:category BUSINESS_ENTITY CZ_USER_INTERFACE
 */
PROCEDURE create_jrad_ui(p_api_version        IN  NUMBER,
                         p_user_id            IN  NUMBER,
                         p_resp_id            IN  NUMBER,
                         p_appl_id            IN  NUMBER,
                         p_devl_project_id    IN  NUMBER,
                         p_show_all_nodes     IN  VARCHAR2,
                         p_master_template_id IN  NUMBER,
                         p_create_empty_ui    IN  VARCHAR2,
                         x_ui_def_id          OUT NOCOPY NUMBER,
                         x_return_status      OUT NOCOPY VARCHAR2,
                         x_msg_count          OUT NOCOPY NUMBER,
                         x_msg_data           OUT NOCOPY VARCHAR2);


--------------------------------------------------------------------------------------------
-- Start of comments
--    API name    : Refresh_UI
--    Type        : Public.
--    Function    : Refresh an existing user interface based on the current model data.
--    Pre-reqs    : None.
--    Parameters  :
--    IN          :     p_api_version           IN  NUMBER         Required
--    IN OUT NOCOPY      :     p_ui_def_id             IN OUT NOCOPY NUMBER     Optional
--                            ID of user interface to be refreshed.
--                            If user interface is Applet style, a new ui_def_id is returned through this parameter.
--    OUT NOCOPY         :     x_run_id                OUT NOCOPY NUMBER        Optional
--                            CZ_DB_LOGS.run_id if there are warnings or errors, 0 if not
--                      x_status                OUT NOCOPY NUMBER        Optional
--                            G_ERROR, G_WARNING or G_SUCCESS (constants from this package)
--    Version     : Current version       1.0
--                  Initial version       1.0
--    Notes       : It does not refresh referenced user interfaces
--
-- End of comments
/*#
 * refresh UI
 * @param p_api_version api version
 * @param p_ui_def_id ui_def_id of UI
 * @param x_run_id CZ_DB_LOGS.run_id if there are warnings and/or errors, 0 if not
 * @param x_status G_ERROR, G_WARNING or G_SUCCESS (constants from this package)
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Refresh UI
 * @rep:category BUSINESS_ENTITY CZ_USER_INTERFACE
 */
PROCEDURE refresh_ui(p_api_version IN     NUMBER,
                     p_ui_def_id   IN OUT NOCOPY NUMBER,
                     x_run_id      OUT NOCOPY    NUMBER,
                     x_status      OUT NOCOPY    NUMBER);

-- Start of comments
--    API name    : Refresh_UI
--    Type        : Public.
--    Function    : Refresh an existing user interface based on the current model data.
--    Pre-reqs    : None.
--    Parameters  :
--    IN          :     p_api_version           IN  NUMBER         Required
--    IN OUT NOCOPY      :     p_ui_def_id             IN OUT NOCOPY NUMBER     Required
--                            ID of user interface to be refreshed.
--                            If user interface is Applet style, a new ui_def_id is returned through this parameter.
--                      p_user_id               IN NUMBER         Required
--                        user is
--                      p_resp_id               IN NUMBER         Required
--                        responsibility id
--                      p_appl_id               IN NUMBER         Required
--                        application id
--
--    OUT NOCOPY         :     x_run_id                OUT NOCOPY NUMBER        Required
--                            CZ_DB_LOGS.run_id if there are warnings or errors, 0 if not
--                      x_status                OUT NOCOPY NUMBER        Required
--                            G_ERROR, G_WARNING or G_SUCCESS (constants from this package)
--    Version     : Current version       1.0
--                  Initial version       1.0
--    Notes       : It does not refresh referenced user interfaces
--
-- End of comments
/*#
 * refresh UI
 * @param p_api_version api version
 * @param p_ui_def_id ui_def_id of UI
 * @param p_user_id user id
 * @param p_resp_id responsibility id
 * @param p_appl_id application id
 * @param x_run_id CZ_DB_LOGS.run_id if there are warnings and/or errors, 0 if not
 * @param x_status G_ERROR, G_WARNING or G_SUCCESS (constants from this package)
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Refresh UI
 * @rep:category BUSINESS_ENTITY CZ_USER_INTERFACE
 */
PROCEDURE refresh_ui(p_api_version IN     NUMBER,
                     p_ui_def_id   IN OUT NOCOPY NUMBER,
                     p_user_id     IN NUMBER,
                     p_resp_id     IN NUMBER,
                     p_appl_id     IN NUMBER,
                     x_run_id      OUT NOCOPY    NUMBER,
                     x_status      OUT NOCOPY    NUMBER);

--------------------------------------------------------------------------------------------
-- Start of comments
--    API name    : refresh_Jrad_UI
--    Type        : Public.
--    Function    : Refresh an existing JRAD style user interface based on the current model data.
--    Pre-reqs    : None.
--    Parameters  :
--    IN          : p_api_version           - identifies version of API
--                  p_ui_def_id             - identifies UI to refresh
--    OUT         :
--      x_return_status       -- status string
--      x_msg_count           -- number of error messages
--      x_msg_data            -- string which contains error messages
--
--    Version     : Current version       1.0
--                  Initial version       1.0
--    Notes       :
--
-- End of comments
--
/*#
 * refresh JRAD style UI
 * @param p_api_version api version
 * @param p_ui_def_id ui_def_id of UI - identifies UI to refresh
 * @param x_return_status status string
 * @param x_msg_count number of error messages
 * @param x_msg_data string which contains error messages
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Refresh JRAD style UI
 * @rep:category BUSINESS_ENTITY CZ_USER_INTERFACE
 */
PROCEDURE refresh_jrad_ui(p_api_version     IN     NUMBER,
                          p_ui_def_id       IN OUT NOCOPY NUMBER,
                          x_return_status   OUT NOCOPY VARCHAR2,
                          x_msg_count       OUT NOCOPY NUMBER,
                          x_msg_data        OUT NOCOPY VARCHAR2);

/*#
 * refresh JRAD style UI
 * @param p_api_version api version
 * @param p_user_id user id
 * @param p_resp_id responsibility id
 * @param p_appl_id application id
 * @param p_ui_def_id ui_def_id of UI - identifies UI to refresh
 * @param x_return_status status string
 * @param x_msg_count number of error messages
 * @param x_msg_data string which contains error messages
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Refresh JRAD style UI
 * @rep:category BUSINESS_ENTITY CZ_USER_INTERFACE
 */
PROCEDURE refresh_jrad_ui(p_api_version     IN NUMBER,
                          p_user_id         IN NUMBER,
                          p_resp_id         IN NUMBER,
                          p_appl_id         IN NUMBER,
                          p_ui_def_id       IN OUT NOCOPY NUMBER,
                          x_return_status   OUT NOCOPY VARCHAR2,
                          x_msg_count       OUT NOCOPY NUMBER,
                          x_msg_data        OUT NOCOPY VARCHAR2);

--------------------------------------------------------------------------------------------
-- Start of comments
--    API name    : Import_Single_Bill
--    Type        : Public.
--    Function    : Import a Bill
--    Pre-reqs    : None.
--    Parameters  :
--    IN          :     p_api_version           IN  NUMBER         Required
--                      p_org_id                IN  NUMBER         Required
--                            organization ID of the bill to be imported
--                      p_top_inv_item_id       IN  NUMBER         Required
--                             inventory item ID of the top item to be imported
--
--    OUT NOCOPY  :     x_run_id                OUT NOCOPY NUMBER        Required
--                            CZ_DB_LOGS.run_id if there are warnings or errors
--                      x_status                OUT NOCOPY NUMBER        Required
--                            G_ERROR or G_SUCCESS (constants from this package)
--    Version     : Current version       1.0
--                  Initial version       1.0
--    Notes       :
--
-- End of comments
/*#
 * import Single Bill
 * @param p_api_version api version
 * @param p_org_id organization ID of the bill to be imported
 * @param p_top_inv_item_id inventory item ID of the top item to be imported
 * @param x_run_id CZ_DB_LOGS.run_id if there are warnings and/or errors, 0 if not
 * @param x_status G_ERROR, G_WARNING or G_SUCCESS (constants from this package)
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Import Single Bill
 * @rep:category BUSINESS_ENTITY CZ_CONFIG_MODEL
 */
PROCEDURE import_single_bill(p_api_version      IN  NUMBER,
                             p_org_id           IN  NUMBER,
                             p_top_inv_item_id  IN  NUMBER,
                             x_run_id           OUT NOCOPY NUMBER,
                             x_status           OUT NOCOPY NUMBER);

/*#
 * import Single Bill
 * @param p_api_version api version
 * @param p_org_id organization ID of the bill to be imported
 * @param p_top_inv_item_id inventory item ID of the top item to be imported
 * @param p_user_id user id
 * @param p_resp_id responsibility id
 * @param p_appl_id application id
 * @param x_run_id CZ_DB_LOGS.run_id if there are warnings and/or errors, 0 if not
 * @param x_status G_ERROR, G_WARNING or G_SUCCESS (constants from this package)
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Import Single Bill
 * @rep:category BUSINESS_ENTITY CZ_CONFIG_MODEL
 */
PROCEDURE import_single_bill(p_api_version      IN  NUMBER,
                             p_org_id           IN  NUMBER,
                             p_top_inv_item_id  IN  NUMBER,
                             p_user_id          IN NUMBER,
                             p_resp_id          IN NUMBER,
                             p_appl_id          IN NUMBER,
                             x_run_id           OUT NOCOPY NUMBER,
                             x_status           OUT NOCOPY NUMBER);

--------------------------------------------------------------------------------------------
-- Start of comments
--    API name    : Refresh_Single_Model
--    Type        : Public.
--    Function    : Import Refresh of a Model
--    Pre-reqs    : None.
--    Parameters  :
--    IN          :     p_api_version           IN  NUMBER         Required
--                      p_devl_project_id       IN  NUMBER         Required
--                            Devl_project_id of the model
--    OUT NOCOPY  :     x_run_id                OUT NOCOPY NUMBER        Required
--                            CZ_DB_LOGS.run_id if there are warnings or errors
--                      x_status                OUT NOCOPY NUMBER        Required
--                            G_ERROR or G_SUCCESS (constants from this package)
--    Version     : Current version       1.0
--                  Initial version       1.0
--    Notes       :
--
-- End of comments
/*#
 * refresh Single Bill
 * @param p_api_version api version
 * @param p_devl_project_id devl_project_id of the model
 * @param x_run_id CZ_DB_LOGS.run_id if there are warnings and/or errors, 0 if not
 * @param x_status G_ERROR, G_WARNING or G_SUCCESS (constants from this package)
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Refresh Single Bill
 * @rep:category BUSINESS_ENTITY CZ_CONFIG_MODEL
 */
PROCEDURE refresh_single_model(p_api_version      IN  NUMBER,
                               p_devl_project_id  IN  VARCHAR2,
                               x_run_id           OUT NOCOPY NUMBER,
                               x_status           OUT NOCOPY NUMBER);

/*#
 * refresh Single Bill
 * @param p_api_version api version
 * @param p_devl_project_id devl_project_id of the model
 * @param p_user_id user id
 * @param p_resp_id responsibility id
 * @param p_appl_id application id
 * @param x_run_id CZ_DB_LOGS.run_id if there are warnings and/or errors, 0 if not
 * @param x_status G_ERROR, G_WARNING or G_SUCCESS (constants from this package)
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Refresh Single Bill
 * @rep:category BUSINESS_ENTITY CZ_CONFIG_MODEL
 */
PROCEDURE refresh_single_model(p_api_version     IN  NUMBER,
                               p_devl_project_id IN  VARCHAR2,
                               p_user_id           IN NUMBER,
                               p_resp_id         IN NUMBER,
                               p_appl_id         IN NUMBER,
                               x_run_id          OUT NOCOPY NUMBER,
                               x_status          OUT NOCOPY NUMBER) ;


--------------------------------------------------------------------------------------------
-- Start of comments
--    API name    : Publish_Model
--    Type        : Public.
--    Function    : Publish a model
--    Pre-reqs    : None.
--    Parameters  :
--    IN          :     p_api_version           IN  NUMBER         Required
--                      p_publication_id        IN  NUMBER         Optional
--                            Model publication Id
--    OUT NOCOPY         :     x_run_id                OUT NOCOPY NUMBER        Optional
--                            CZ_DB_LOGS.run_id
--                      x_status                OUT NOCOPY NUMBER        Optional
--                            G_ERROR or G_SUCCESS (constants from this package)
--    Version     : Current version       1.0
--                  Initial version       1.0
--    Notes       : It should only be run on publications with a status of 'Pending'
--
-- End of comments
/*#
 * publish model
 * @param p_api_version api version
 * @param p_publication_id Model publication Id
 * @param x_run_id CZ_DB_LOGS.run_id if there are warnings and/or errors, 0 if not
 * @param x_status G_ERROR, G_WARNING or G_SUCCESS (constants from this package)
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Publish Model
 * @rep:category BUSINESS_ENTITY CZ_CONFIG_MODEL
 */
PROCEDURE publish_model(p_api_version    IN  NUMBER,
                        p_publication_id IN  NUMBER,
                        x_run_id         OUT NOCOPY NUMBER,
                        x_status         OUT NOCOPY NUMBER);

/*#
 * publish model
 * @param p_api_version api version
 * @param p_publication_id Model publication Id
 * @param p_user_id user id
 * @param p_resp_id responsibility id
 * @param p_appl_id application id
 * @param x_run_id CZ_DB_LOGS.run_id if there are warnings and/or errors, 0 if not
 * @param x_status G_ERROR, G_WARNING or G_SUCCESS (constants from this package)
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Publish Model
 * @rep:category BUSINESS_ENTITY CZ_CONFIG_MODEL
 */
PROCEDURE publish_model(p_api_version    IN  NUMBER,
                        p_publication_id IN  NUMBER,
                        p_user_id        IN NUMBER,
                        p_resp_id        IN NUMBER,
                        p_appl_id        IN NUMBER,
                        x_run_id         OUT NOCOPY NUMBER,
                        x_status         OUT NOCOPY NUMBER);

--------------------------------------------------------------------------------------------
-- Start of comments
--    API name    : Deep_Model_Copy
--    Type        : Public.
--    Function    : deep model copy
--    Pre-reqs    : None.
--    Parameters  :
--    IN          :     p_api_version           IN  NUMBER         Required
--                      p_devl_project_id       IN  NUMBER         Optional
--                            Devl_project_id of the model
--                      p_folder                IN  NUMBER        Optional
--                            Folder to which the copy is made
--                      p_copy_rules            IN  NUMBER        Optional
--                            flag 1 implies copy rules, else 0
--                      p_copy_uis              IN  NUMBER        Optional
--                            flag 1 implies copy uis, else 0
--                      p_copy_root             IN  NUMBER        Optional
--                            flag 1 implies that only root model would be copied, else 0
--    OUT NOCOPY         :     x_devl_project_id       OUT NOCOPY NUMBER        Optional
--                            Devl_project_id of the copy
--                      x_run_id                OUT NOCOPY NUMBER        Optional
--                            CZ_DB_LOGS.run_id
--                      x_status                OUT NOCOPY NUMBER        Optional
--                            G_ERROR or G_SUCCESS (constants from this package)
--    Version     : Current version       1.0
--                  Initial version       1.0
--    Notes       : The referenced models are also copied
--
-- End of comments
/*#
 * deep model copy
 * @param p_api_version api version
 * @param p_devl_project_id devl_project_id of the model
 * @param p_folder Folder to which the copy is made
 * @param p_copy_rules flag 1 implies copy rules, else 0
 * @param p_copy_uis flag 1 implies copy uis, else 0
 * @param p_copy_root flag 1 implies that only root model would be copied, else 0
 * @param x_devl_project_id devl_project_id of the copy
 * @param x_run_id CZ_DB_LOGS.run_id if there are warnings and/or errors, 0 if not
 * @param x_status G_ERROR, G_WARNING or G_SUCCESS (constants from this package)
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Deep Model Copy
 * @rep:category BUSINESS_ENTITY CZ_CONFIG_MODEL
 */
PROCEDURE deep_model_copy(p_api_version     IN  NUMBER,
                          p_devl_project_id IN  NUMBER,
                          p_folder          IN  NUMBER,
                          p_copy_rules      IN  NUMBER,
                          p_copy_uis        IN  NUMBER,
                          p_copy_root       IN  NUMBER,
                          x_devl_project_id OUT NOCOPY NUMBER,
                          x_run_id          OUT NOCOPY NUMBER,
                          x_status          OUT NOCOPY NUMBER);

/*#
 * deep model copy
 * @param p_api_version api version
 * @param p_user_id user id
 * @param p_resp_id responsibility id
 * @param p_appl_id application id
 * @param p_devl_project_id devl_project_id of the model
 * @param p_folder Folder to which the copy is made
 * @param p_copy_rules flag 1 implies copy rules, else 0
 * @param p_copy_uis flag 1 implies copy uis, else 0
 * @param p_copy_root flag 1 implies that only root model would be copied, else 0
 * @param x_devl_project_id devl_project_id of the copy
 * @param x_run_id CZ_DB_LOGS.run_id if there are warnings and/or errors, 0 if not
 * @param x_status G_ERROR, G_WARNING or G_SUCCESS (constants from this package)
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Deep Model Copy
 * @rep:category BUSINESS_ENTITY CZ_CONFIG_MODEL
 */
PROCEDURE deep_model_copy(p_api_version IN  NUMBER,
                          p_user_id     IN NUMBER,
                          p_resp_id     IN NUMBER,
                          p_appl_id     IN NUMBER,
                          p_devl_project_id IN  NUMBER,
                          p_folder          IN  NUMBER,
                          p_copy_rules      IN  NUMBER,
                          p_copy_uis        IN  NUMBER,
                          p_copy_root       IN  NUMBER,
                          x_devl_project_id OUT NOCOPY NUMBER,
                          x_run_id          OUT NOCOPY NUMBER,
                          x_status          OUT NOCOPY NUMBER);

--------------------------------------------------------------------------------------------
-- Start of comments
--    API name    : Execute_Populator
--    Type        : Public.
--    Function    : Refresh CZ_PS_NODES by executing a populator
--    Pre-reqs    : None.
--    Parameters  :
--    IN          :     p_api_version           IN  NUMBER         Required
--                      p_populator_id          IN  NUMBER         Optional
--                            CZ_POPULATORS.populator_id of populator to be executed
--    IN OUT NOCOPY      :     p_imp_run_id            IN OUT NOCOPY VARCHAR2   Optional
--                            CZ_IMP_PS_NODES.run_id
--    OUT NOCOPY         :     x_run_id                OUT NOCOPY NUMBER        Optional
--                            CZ_DB_LOGS.run_id
--                      x_status                OUT NOCOPY NUMBER        Optional
--                            G_ERROR or G_SUCCESS (constants from this package)
--    Version     : Current version       1.0
--                  Initial version       1.0
--    Notes       :
--
-- End of comments
/*#
 * execute populator
 * @param p_api_version api version
 * @param p_populator_id CZ_POPULATORS.populator_id of populator to be executed
 * @param p_imp_run_id IN OUT value - CZ_IMP_PS_NODES.run_id
 * @param x_run_id CZ_DB_LOGS.run_id if there are warnings and/or errors, 0 if not
 * @param x_status G_ERROR, G_WARNING or G_SUCCESS (constants from this package)
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Execute Populator
 * @rep:category BUSINESS_ENTITY CZ_CONFIG_MODEL
 */
PROCEDURE execute_populator(p_api_version  IN     NUMBER,
                            p_populator_id IN     NUMBER,
                            p_imp_run_id   IN OUT NOCOPY VARCHAR2,
                            x_run_id       OUT NOCOPY    NUMBER,
                            x_status       OUT NOCOPY    NUMBER);

/*#
 * execute populator
 * @param p_api_version api version
 * @param p_user_id user id
 * @param p_resp_id responsibility id
 * @param p_appl_id application id
 * @param p_populator_id CZ_POPULATORS.populator_id of populator to be executed
 * @param p_imp_run_id IN OUT value - CZ_IMP_PS_NODES.run_id
 * @param x_run_id CZ_DB_LOGS.run_id if there are warnings and/or errors, 0 if not
 * @param x_status G_ERROR, G_WARNING or G_SUCCESS (constants from this package)
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Execute Populator
 * @rep:category BUSINESS_ENTITY CZ_CONFIG_MODEL
 */
PROCEDURE execute_populator(p_api_version  IN NUMBER,
                            p_user_id      IN NUMBER,
                            p_resp_id      IN NUMBER,
                            p_appl_id      IN NUMBER,
                            p_populator_id IN NUMBER,
                            p_imp_run_id   IN OUT NOCOPY VARCHAR2,
                            x_run_id       OUT NOCOPY    NUMBER,
                            x_status       OUT NOCOPY    NUMBER);

--------------------------------------------------------------------------------------------
-- Start of comments
--    API name    : Repopulate
--    Type        : Public.
--    Function    : Generates logic for a model
--    Pre-reqs    : None.
--    Parameters  :
--    IN          :     p_api_version           IN  NUMBER         Required
--                      p_devl_project_id       IN  NUMBER         Optional
--                            Devl_project_id of the model
--                      p_regenerate_all        IN  VARCHAR2       Optional
--                            DEFAULT '1'
--                            '0' if all populators should be regenerated unconditionally before execution,
--                            '1'  only modified ones
--                      p_handle_invalid        IN  VARCHAR2       Optional
--                            DEFAULT '1'
--                            Allows caller to specify how to handle invalid populators
--                            skip('0')  or regenerate ('1')
--                      p_handle_broken         IN  VARCHAR2       Optional
--                            DEFAULT '1'
--                            Allows caller to specify whether to continue ('1') or not ('0')
--                            when a populator cannot be regenerated successfully
--    OUT NOCOPY         :     x_run_id                OUT NOCOPY NUMBER        Optional
--                            CZ_DB_LOGS.run_id
--                      x_status                OUT NOCOPY NUMBER        Optional
--                            G_ERROR or G_SUCCESS (constants from this package)
--    Version     : Current version       1.0
--                  Initial version       1.0
--    Notes       :
--
-- End of comments
/*#
 * repopulate populators
 * @param p_api_version api version
 * @param p_devl_project_id devl_project_id of the model
 * @param p_regenerate_all 0' if all populators should be regenerated unconditionally before execution,'1'  only modified ones.
 * @param p_handle_invalid Allows caller to specify how to handle invalid populators skip('0')  or regenerate ('1').
 * @param p_handle_broken Allows caller to specify whether to continue ('1') or not ('0') when a populator cannot be regenerated successfully.
 * @param x_run_id CZ_DB_LOGS.run_id if there are warnings and/or errors, 0 if not
 * @param x_status G_ERROR, G_WARNING or G_SUCCESS (constants from this package)
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Repopulate Populators
 * @rep:category BUSINESS_ENTITY CZ_CONFIG_MODEL
 */
PROCEDURE repopulate(p_api_version     IN  NUMBER,
                     p_devl_project_id IN  NUMBER,
                     p_regenerate_all  IN  VARCHAR2 , -- DEFAULT '1',
                     p_handle_invalid  IN  VARCHAR2 , -- DEFAULT '1',
                     p_handle_broken   IN  VARCHAR2 , -- DEFAULT '1',
                     x_run_id          OUT NOCOPY NUMBER,
                     x_status          OUT NOCOPY NUMBER);

/*#
 * repopulate populators
 * @param p_api_version api version
 * @param p_devl_project_id devl_project_id of the model
 * @param p_user_id user id
 * @param p_resp_id responsibility id
 * @param p_appl_id application id
 * @param p_regenerate_all 0' if all populators should be regenerated unconditionally before execution,'1'  only modified ones.
 * @param p_handle_invalid Allows caller to specify how to handle invalid populators skip('0')  or regenerate ('1').
 * @param p_handle_broken Allows caller to specify whether to continue ('1') or not ('0') when a populator cannot be regenerated successfully.
 * @param x_run_id CZ_DB_LOGS.run_id if there are warnings and/or errors, 0 if not
 * @param x_status G_ERROR, G_WARNING or G_SUCCESS (constants from this package)
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Repopulate Populators
 * @rep:category BUSINESS_ENTITY CZ_CONFIG_MODEL
 */
PROCEDURE repopulate(p_api_version    IN  NUMBER,
                    p_devl_project_id IN  NUMBER,
                    p_user_id         IN NUMBER,
                    p_resp_id         IN NUMBER,
                    p_appl_id         IN NUMBER,
                    p_regenerate_all  IN  VARCHAR2 , -- DEFAULT '1',
                    p_handle_invalid  IN  VARCHAR2 , -- DEFAULT '1',
                    p_handle_broken   IN  VARCHAR2 , -- DEFAULT '1',
                    x_run_id          OUT NOCOPY NUMBER,
                    x_status          OUT NOCOPY NUMBER);

-----------------------------------------------------
-- Start of comments
--    API name    : Republish_Model
--    Type        : Public.
--    Function    : Republishes an existing publication
--    Pre-reqs    : None.
--    Parameters  :
--    IN          :     p_api_version           IN  NUMBER         Required
--                      p_publication_id        IN  NUMBER         Required
--                            Model publication Id
--    IN          :     p_start_date            IN DATE           Optional
--              Default applicable_from
--    IN          :     p_end_date              IN DATE           Optional
--                            Default value applicable_until
--    OUT NOCOPY         :     x_run_id                OUT NOCOPY NUMBER        Optional
--                            CZ_DB_LOGS.run_id
--                      x_status                OUT NOCOPY NUMBER        Optional
--                            G_ERROR or G_SUCCESS (constants from this package)
--    Version     : Current version       1.0
--                  Initial version       1.0
--    Notes       : It should only be run on publications with a status of 'Complete'
--
-- End of comments
/*#
 * republish model
 * @param p_api_version api version
 * @param p_publication_id Model publication Id
 * @param p_start_date Default applicable_from
 * @param p_end_date Default value applicable_until
 * @param x_run_id CZ_DB_LOGS.run_id if there are warnings and/or errors, 0 if not
 * @param x_status G_ERROR, G_WARNING or G_SUCCESS (constants from this package)
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Republish Model
 * @rep:category BUSINESS_ENTITY CZ_CONFIG_MODEL
 */
PROCEDURE republish_model(p_api_version    IN  NUMBER,
                          p_publication_id IN  NUMBER,
                          p_start_date     IN  DATE ,
                          p_end_date       IN  DATE ,
                          x_run_id         OUT NOCOPY NUMBER,
                          x_status         OUT NOCOPY NUMBER);

/*#
 * republish model
 * @param p_api_version api version
 * @param p_publication_id Model publication Id
 * @param p_user_id user id
 * @param p_resp_id responsibility id
 * @param p_appl_id application id
 * @param p_start_date Default applicable_from
 * @param p_end_date Default value applicable_until
 * @param x_run_id CZ_DB_LOGS.run_id if there are warnings and/or errors, 0 if not
 * @param x_status G_ERROR, G_WARNING or G_SUCCESS (constants from this package)
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Republish Model
 * @rep:category BUSINESS_ENTITY CZ_CONFIG_MODEL
 */
PROCEDURE republish_model(p_api_version    IN  NUMBER,
                          p_publication_id IN  NUMBER,
                          p_user_id         IN NUMBER,
                          p_resp_id         IN NUMBER,
                          p_appl_id         IN NUMBER,
                          p_start_date     IN  DATE,
                          p_end_date       IN  DATE,
                          x_run_id         OUT NOCOPY NUMBER,
                          x_status         OUT NOCOPY NUMBER);
-----------------------------------------------------
-- Start of comments
--    API name    : rp_folder_exists
--    Type        : Public.
--    Function    : check if a repository folder exists
--    Pre-reqs    : None.
--    Parameters  :
--    IN          :     p_api_version           IN  NUMBER         Required
--                :     p_rp_folder_id          IN  NUMBER         Required
--                                              the folder id (object_id) of the RP folder to check
--                :     p_encl_folder_id        IN NUMBER          Required
--                                              The parent folder in which the p_rp_folder_id
--                                              will be checked for existance
--                                              Use RP_ROOT_FOLDER for folder id of the root folder
--                                              Pass NULL to check the folder anywhere in the repository
--    RETURNS     :     Boolean
--                                              TRUE when encl folder is null and
--                                                   p_rp_folder exists anywhere in repository
--                                              TRUE when encl folder is not null and
--                                                   it exists anywhere in repository and
--                                                   p_rp_folder exists in it
--                                              FALSE when encl folder is null and
--                                                    p_rp_folder doesn't exists anywhere in repository
--                                              FALSE when encl folder is not null and
--                                                    it doesn't exists anywhere in repository
--                                              FALSE when encl folder is not null and
--                                                    p_rp_folder is not in it
--    Version     : Current version       1.0
--                  Initial version       1.0
--    Notes       :
--
-- End of comments
/*#
 * check if a repository folder exists
 * @param p_api_version api version
 * @param p_encl_folder_id The folder id (object_id) of the RP folder to check.
 * @param p_rp_folder_id The parent folder in which the p_rp_folder_id will be checked for existance
 * @return TRUE when encl folder is null and p_rp_folder exists anywhere in repository
 *         TRUE when encl folder is not null and it exists anywhere in repository and p_rp_folder exists in it
 *         FALSE when encl folder is null and p_rp_folder doesn't exists anywhere in repository
 *         FALSE when encl folder is not null and it doesn't exists anywhere in repository
 *         FALSE when encl folder is not null and p_rp_folder is not in it
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname check if a Repository folder exists
 * @rep:category BUSINESS_ENTITY CZ_RP_FOLDER
 */
FUNCTION rp_folder_exists (p_api_version    IN NUMBER
                          ,p_encl_folder_id IN NUMBER
                          ,p_rp_folder_id   IN NUMBER) RETURN BOOLEAN;

-----------------------------------------------------
-- Start of comments
--    API name    : rp_folder_exists
--    Type        : Public.
--    Function    : check if a repository folder exists
--    Pre-reqs    : None.
--    Parameters  :
--    IN          :     p_api_version           IN  NUMBER         Required
--                :     p_rp_folder_id          IN  NUMBER         Required
--                                              the folder id (object_id) of the RP folder to check
--                :     p_encl_folder_id        IN NUMBER          Required
--                                              The parent folder in which the p_rp_folder_id
--                                              will be checked for existance
--                                              Use RP_ROOT_FOLDER for folder id of the root folder
--                                              Pass NULL to check the folder anywhere in the repository
--                      p_user_id               IN NUMBER         Required
--                            user id
--                      p_resp_id               IN NUMBER         Required
--                            responsibility id
--                      p_appl_id               IN NUMBER         Required
--                            application id
--    RETURNS     :     Boolean
--                                              TRUE when encl folder is null and
--                                                   p_rp_folder exists anywhere in repository
--                                              TRUE when encl folder is not null and
--                                                   it exists anywhere in repository and
--                                                   p_rp_folder exists in it
--                                              FALSE when encl folder is null and
--                                                    p_rp_folder doesn't exists anywhere in repository
--                                              FALSE when encl folder is not null and
--                                                    it doesn't exists anywhere in repository
--                                              FALSE when encl folder is not null and
--                                                    p_rp_folder is not in it
--    Version     : Current version       1.0
--                  Initial version       1.0
--    Notes       :
--
-- End of comments
/*#
 * check if a repository folder exists
 * @param p_api_version api version
 * @param p_encl_folder_id The folder id (object_id) of the RP folder to check.
 * @param p_rp_folder_id The parent folder in which the p_rp_folder_id will be checked for existance
 * @param p_user_id user id
 * @param p_resp_id responsibility id
 * @param p_appl_id application id
 * @return TRUE when encl folder is null and p_rp_folder exists anywhere in repository
 *         TRUE when encl folder is not null and it exists anywhere in repository and p_rp_folder exists in it
 *         FALSE when encl folder is null and p_rp_folder doesn't exists anywhere in repository
 *         FALSE when encl folder is not null and it doesn't exists anywhere in repository
 *         FALSE when encl folder is not null and p_rp_folder is not in it
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname check if a Repository folder exists
 * @rep:category BUSINESS_ENTITY CZ_RP_FOLDER
 */
FUNCTION rp_folder_exists (
  p_api_version    IN NUMBER,
  p_encl_folder_id IN NUMBER,
  p_rp_folder_id   IN NUMBER,
  p_user_id        IN NUMBER,
  p_resp_id        IN NUMBER,
  p_appl_id        IN NUMBER
) RETURN BOOLEAN;

-----------------------------------------------------
-- Start of comments
--    API name    : create_rp_folder
--    Type        : Public.
--
--    Function    : Creates a Repository folder in the specified enclosing folder.
--                  If a folder with the same name exists in the enclosing folder
--                  then its id is returned in x_new_folder_id OUT paramater
--
--    Pre-reqs    : None.
--    Parameters  :
--    IN          :     p_api_version           IN NUMBER         Required
--                      p_encl_folder_id        IN NUMBER         Required
--                                        The parent folder to create new folder
--                                        use RP_ROOT_FOLDER constant for root folder
--                      p_new_folder_name       IN VARCHAR2       Required
--                                                  The new folder name
--                      p_folder_desc          IN VARCHAR2        DEFAULT NULL
--                      p_folder_notes         IN VARCHAR2        DEFAULT NULL
--    OUT         :
--                      x_new_folder_id       OUT NOCOPY NUMBER   Required
--                                            the new folder id created, or the
--                                            folder id of the folder with the same name
--                                            in the same enclosing folder
--                      x_return_status       OUT NOCOPY VARCHAR2 Required
--                      x_msg_count           OUT NOCOPY NUMBER   Required
--                      x_msg_data            OUT NOCOPY VARCHAR2 Required
--
--    Version     : Current version       1.0
--                  Initial version       1.0
--    Notes       : if a folder with the same name exists in the enclosing folder
--                  then its id is returned in x_new_folder_id OUT paramater
--
-- End of comments
-----------------------------------------------------
/*#
 * create repository folder
 * @param p_api_version api version
 * @param p_encl_folder_id The parent folder to create new folder use RP_ROOT_FOLDER constant for root folder.
 * @param p_new_folder_name The new folder name
 * @param p_folder_desc The new folder description
 * @param p_folder_notes The new folder notes
 * @param x_new_folder_id The new folder id created, or the folder id of the folder with the same name in the same enclosing folder
 * @param x_return_status status string
 * @param x_msg_count number of error messages
 * @param x_msg_data string which contains error messages
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname create Repository Folder
 * @rep:category BUSINESS_ENTITY CZ_RP_FOLDER
 */
PROCEDURE create_rp_folder(p_api_version          IN  NUMBER
                          ,p_encl_folder_id       IN  CZ_RP_ENTRIES.OBJECT_ID%TYPE
                          ,p_new_folder_name      IN  CZ_RP_ENTRIES.NAME%TYPE
                          ,p_folder_desc          IN  CZ_RP_ENTRIES.DESCRIPTION%TYPE
                          ,p_folder_notes         IN  CZ_RP_ENTRIES.NOTES%TYPE
                          ,x_new_folder_id        OUT NOCOPY CZ_RP_ENTRIES.OBJECT_ID%TYPE
                          ,x_return_status        OUT NOCOPY  VARCHAR2
                          ,x_msg_count            OUT NOCOPY  NUMBER
                          ,x_msg_data             OUT NOCOPY  VARCHAR2
                          );
-----------------------------------------------------
-- Start of comments
--    API name    : create_rp_folder
--    Type        : Public.
--
--    Function    : Creates a Repository folder in the specified enclosing folder.
--                  If a folder with the same name exists in the enclosing folder
--                  then its id is returned in x_new_folder_id OUT paramater
--
--    Pre-reqs    : None.
--    Parameters  :
--    IN          :     p_api_version           IN NUMBER         Required
--                      p_encl_folder_id        IN NUMBER         Required
--                                        The parent folder to create new folder
--                                        use RP_ROOT_FOLDER constant for root folder
--                      p_new_folder_name       IN VARCHAR2       Required
--                                                  The new folder name
--                      p_folder_desc          IN VARCHAR2        DEFAULT NULL
--                      p_folder_notes         IN VARCHAR2        DEFAULT NULL
--                      p_user_id               IN NUMBER         Required
--                            user id
--                      p_resp_id               IN NUMBER         Required
--                            responsibility id
--                      p_appl_id               IN NUMBER         Required
--                            application id
--    OUT         :
--                      x_new_folder_id       OUT NOCOPY NUMBER   Required
--                                            the new folder id created, or the
--                                            folder id of the folder with the same name
--                                            in the same enclosing folder
--                      x_return_status       OUT NOCOPY VARCHAR2 Required
--                      x_msg_count           OUT NOCOPY NUMBER   Required
--                      x_msg_data            OUT NOCOPY VARCHAR2 Required
--
--    Version     : Current version       1.0
--                  Initial version       1.0
--    Notes       : if a folder with the same name exists in the enclosing folder
--                  then its id is returned in x_new_folder_id OUT paramater
--
-- End of comments
-----------------------------------------------------
/*#
 * create repository folder
 * @param p_api_version api version
 * @param p_encl_folder_id The parent folder to create new folder use RP_ROOT_FOLDER constant for root folder.
 * @param p_new_folder_name The new folder name
 * @param p_folder_desc The new folder description
 * @param p_folder_notes The new folder notes
 * @param p_user_id user id
 * @param p_resp_id responsibility id
 * @param p_appl_id application id
 * @param x_new_folder_id The new folder id created, or the folder id of the folder with the same name in the same enclosing folder
 * @param x_return_status status string
 * @param x_msg_count number of error messages
 * @param x_msg_data string which contains error messages
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname create Repository Folder
 * @rep:category BUSINESS_ENTITY CZ_RP_FOLDER
 */
PROCEDURE create_rp_folder(p_api_version          IN  NUMBER
                          ,p_encl_folder_id       IN  CZ_RP_ENTRIES.OBJECT_ID%TYPE
                          ,p_new_folder_name      IN  CZ_RP_ENTRIES.NAME%TYPE
                          ,p_folder_desc          IN  CZ_RP_ENTRIES.DESCRIPTION%TYPE
                          ,p_folder_notes         IN  CZ_RP_ENTRIES.NOTES%TYPE
                          ,p_user_id              IN NUMBER
                          ,p_resp_id              IN NUMBER
                          ,p_appl_id              IN NUMBER
                          ,x_new_folder_id        OUT NOCOPY CZ_RP_ENTRIES.OBJECT_ID%TYPE
                          ,x_return_status        OUT NOCOPY  VARCHAR2
                          ,x_msg_count            OUT NOCOPY  NUMBER
                          ,x_msg_data             OUT NOCOPY  VARCHAR2
                          );
-----------------------------------------------------
-- Start of comments
--    API name    : import_generic
--    Type        : Public.
--    Function    : process and import data in CZ interface tables
--    Pre-reqs    : None.
--    Parameters  :
--    IN          :     p_api_version           IN  NUMBER         Required
--    IN          :     p_run_id                IN  NUMBER         Required
--                             Specify the run_id to process. If NULL, all records
--                             in interface tables where run_id is NULL will be processed.
--    IN          :     p_rp_folder_id          IN  NUMBER         Required
--                             The repository folder to import the model into,
--                             use RP_ROOT_FOLDER constant for the root folder id
--    OUT         :     x_run_id                OUT NOCOPY NUMBER        Required
--                            Used to get results from cz_xfr_run_infos and cz_xfr_run_results
--                            Also CZ_DB_LOGS.run_id, if there are warnings or errors
--    OUT         :     x_status                OUT NOCOPY NUMBER        Required
--                            G_ERROR or G_SUCCESS (constants from this package)
--    Version     : Current version       1.0
--                  Initial version       1.0
--    Notes       :
--
-- End of comments
/*#
 * generic Import
 * @param p_api_version api version
 * @param p_run_id Specify the run_id to process. If NULL, all records in interface tables where run_id is NULL will be processed.
 * @param p_rp_folder_id The repository folder to import the model into, use RP_ROOT_FOLDER constant for the root folder id.
 * @param x_run_id CZ_DB_LOGS.run_id if there are warnings and/or errors, 0 if not.
 * @param x_status G_ERROR, G_WARNING or G_SUCCESS (constants from this package).
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Generic Import
 * @rep:category BUSINESS_ENTITY CZ_CONFIG_MODEL
 */
PROCEDURE import_generic(p_api_version      IN  NUMBER
                        ,p_run_id           IN  NUMBER
                        ,p_rp_folder_id     IN  NUMBER
                        ,x_run_id           OUT NOCOPY NUMBER
                        ,x_status           OUT NOCOPY NUMBER);

-----------------------------------------------------
-- Start of comments
--    API name    : import_generic
--    Type        : Public.
--    Function    : process and import data in CZ interface tables
--    Pre-reqs    : None.
--    Parameters  :
--    IN          :     p_api_version           IN  NUMBER         Required
--    IN          :     p_run_id                IN  NUMBER         Required
--                             Specify the run_id to process. If NULL, all records
--                             in interface tables where run_id is NULL will be processed.
--    IN          :     p_rp_folder_id          IN  NUMBER         Required
--                             The repository folder to import the model into,
--                             use RP_ROOT_FOLDER constant for the root folder id
--                      p_user_id               IN NUMBER         Required
--                            user id
--                      p_resp_id               IN NUMBER         Required
--                            responsibility id
--                      p_appl_id               IN NUMBER         Required
--                            application id
--    OUT         :     x_run_id                OUT NOCOPY NUMBER        Required
--                            Used to get results from cz_xfr_run_infos and cz_xfr_run_results
--                            Also CZ_DB_LOGS.run_id, if there are warnings or errors
--    OUT         :     x_status                OUT NOCOPY NUMBER        Required
--                            G_ERROR or G_SUCCESS (constants from this package)
--    Version     : Current version       1.0
--                  Initial version       1.0
--    Notes       :
--
-- End of comments
/*#
 * generic Import
 * @param p_api_version api version
 * @param p_run_id Specify the run_id to process. If NULL, all records in interface tables where run_id is NULL will be processed.
 * @param p_rp_folder_id The repository folder to import the model into, use RP_ROOT_FOLDER constant for the root folder id.
 * @param p_user_id user id
 * @param p_resp_id responsibility id
 * @param p_appl_id application id
 * @param x_run_id CZ_DB_LOGS.run_id if there are warnings and/or errors, 0 if not.
 * @param x_status G_ERROR, G_WARNING or G_SUCCESS (constants from this package).
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Generic Import
 * @rep:category BUSINESS_ENTITY CZ_CONFIG_MODEL
 */
PROCEDURE import_generic(p_api_version      IN  NUMBER
                        ,p_run_id           IN  NUMBER
                        ,p_rp_folder_id     IN  NUMBER
                        ,p_user_id          IN  NUMBER
                        ,p_resp_id          IN  NUMBER
                        ,p_appl_id          IN  NUMBER
                        ,x_run_id           OUT NOCOPY NUMBER
                        ,x_status           OUT NOCOPY NUMBER);

-----------------------------------------
/*#
 * This is the public interface for force unlock operations on a model in Oracle Configurator
 * @param p_api_version   Current version of the API is 1.0
 * @param p_model_id      devl_project_id of the model from cz_devl_projects table
 * @param p_unlock_references   A value of FND_API.G_TRUE indicates that the child models if any should be
 *                              force unlocked. A value of FND_API.G_FALSE indicates that only the root model
 *                              will be unlocked
 * @param p_init_msg_list FND_API.G_TRUE if the API should initialize the FND stack, FND_API.G_FALSE if not.
 * @param x_return_status standard FND status. (ex:FND_API.G_RET_STS_SUCCESS )
 * @param x_msg_count     number of messages on the stack.
 * @param x_msg_data      standard FND OUT parameter for message.  Messages are written to the FND error stack
 * @rep:scope public
 * @rep:displayname API for working with force unlock operations on a model
 * @rep:lifecycle active
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY CZ_CONFIG_MODEL
 */

PROCEDURE force_unlock_model (p_api_version        IN NUMBER,
                              p_model_id           IN NUMBER,
                              p_unlock_references  IN VARCHAR2,
                              p_init_msg_list      IN VARCHAR2,
                              x_return_status     OUT NOCOPY VARCHAR2,
                              x_msg_count         OUT NOCOPY NUMBER,
                              x_msg_data          OUT NOCOPY VARCHAR2);

-----------------------------------------
/*#
 * This is the public interface for force unlock operations on a model in Oracle Configurator
 * @param p_api_version   Current version of the API is 1.0
 * @param p_model_id      devl_project_id of the model from cz_devl_projects table
 * @param p_unlock_references   A value of FND_API.G_TRUE indicates that the child models if any should be
 *                              force unlocked. A value of FND_API.G_FALSE indicates that only the root model
 *                              will be unlocked
 * @param p_init_msg_list FND_API.G_TRUE if the API should initialize the FND stack, FND_API.G_FALSE if not.
 * @param p_user_id user id
 * @param p_resp_id responsibility id
 * @param p_appl_id application id
 * @param x_return_status standard FND status. (ex:FND_API.G_RET_STS_SUCCESS )
 * @param x_msg_count     number of messages on the stack.
 * @param x_msg_data      standard FND OUT parameter for message.  Messages are written to the FND error stack
 * @rep:scope public
 * @rep:displayname API for working with force unlock operations on a model
 * @rep:lifecycle active
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY CZ_CONFIG_MODEL
 */

PROCEDURE force_unlock_model (p_api_version        IN NUMBER,
                              p_model_id           IN NUMBER,
                              p_unlock_references  IN VARCHAR2,
                              p_init_msg_list      IN VARCHAR2,
                              p_user_id            IN NUMBER,
                              p_resp_id            IN NUMBER,
                              p_appl_id            IN NUMBER,
                              x_return_status      OUT NOCOPY VARCHAR2,
                              x_msg_count          OUT NOCOPY NUMBER,
                              x_msg_data           OUT NOCOPY VARCHAR2);

---------------------------------------------------
/*#
 * This is the public interface for force unlock operations on a UI content template in Oracle Configurator
 * @param p_api_version   Current version of the API is 1.0
 * @param p_template_id   Template_id of the template from cz_ui_templates table
 * @param p_init_msg_list FND_API.G_TRUE if the API should initialize the FND stack, FND_API.G_FALSE if not.
 * @param x_return_status standard FND status. (ex:FND_API.G_RET_STS_SUCCESS )
 * @param x_msg_count     number of messages on the stack.
 * @param x_msg_data      standard FND OUT parameter for message.  Messages are written to the FND error stack
 * @rep:scope public
 * @rep:displayname API for working with force unlock operations on a UI content template
 * @rep:lifecycle active
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY CZ_USER_INTERFACE
 */

PROCEDURE force_unlock_template (p_api_version    IN NUMBER,
                                 p_template_id    IN NUMBER,
                                 p_init_msg_list  IN VARCHAR2,
                                 x_return_status OUT NOCOPY VARCHAR2,
                                 x_msg_count     OUT NOCOPY NUMBER,
                                 x_msg_data      OUT NOCOPY VARCHAR2);

---------------------------------------------------
/*#
 * This is the public interface for force unlock operations on a UI content template in Oracle Configurator
 * @param p_api_version   Current version of the API is 1.0
 * @param p_template_id   Template_id of the template from cz_ui_templates table
 * @param p_init_msg_list FND_API.G_TRUE if the API should initialize the FND stack, FND_API.G_FALSE if not.
 * @param p_user_id user id
 * @param p_resp_id responsibility id
 * @param p_appl_id application id
 * @param x_return_status standard FND status. (ex:FND_API.G_RET_STS_SUCCESS )
 * @param x_msg_count     number of messages on the stack.
 * @param x_msg_data      standard FND OUT parameter for message.  Messages are written to the FND error stack
 * @rep:scope public
 * @rep:displayname API for working with force unlock operations on a UI content template
 * @rep:lifecycle active
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY CZ_USER_INTERFACE
 */

PROCEDURE force_unlock_template (p_api_version    IN NUMBER,
                                 p_template_id    IN NUMBER,
                                 p_init_msg_list  IN VARCHAR2,
                                 p_user_id        IN NUMBER,
                                 p_resp_id        IN NUMBER,
                                 p_appl_id        IN NUMBER,
                                 x_return_status  OUT NOCOPY VARCHAR2,
                                 x_msg_count      OUT NOCOPY NUMBER,
                                 x_msg_data       OUT NOCOPY VARCHAR2);

-----------------------------------------------------
-- Start of comments
--    API name    : usage_id_from_usage_name
--    Type        : Public.
--
--    Function    :  Returns the MODEL_USAGE_ID for a given NAME(usage name).
--
--    Pre-reqs    : None.
--    Parameters  :
--    IN          :     p_api_version           IN NUMBER         Required
--                      p_usage_name            IN VARCHAR2         Required
--                                              CZ_MODEL_USAGES.NAME
--    OUT         :
--                      x_return_status       OUT NOCOPY VARCHAR2 Required
--                      x_msg_count           OUT NOCOPY NUMBER   Required
--                      x_msg_data            OUT NOCOPY VARCHAR2 Required
--    RETURNS     :     NUMBER
--                                              MODEL_USAGE_ID is there exists a matching usage for the given p_usage_name.
--                                              NULL, if either there is no match for the given p_usage_name
--						or if p_usage_name is null;
--
--    Version     : Current version       1.0
--                  Initial version       1.0
--
-- End of comments
-----------------------------------------------------
/*#
 * This API retrieves the model_usage_id for a specified usage name
 * @param p_api_version Current version of the API is 1.0
 * @param p_usage_name usage for which model_usage_id is to retrieved.
 * @param x_return_status status string
 * @param x_msg_count number of error messages
 * @param x_msg_data string which contains error messages
 * @return MODEL_USAGE_ID if there exists a matching usage for the given p_usage_name.
 *         NULL  if either there is no match for the given p_usage_name or if p_usage_name is null
 * @rep:scope public
 * @rep:compatibility S
 * @rep:lifecycle active
 * @rep:displayname Get model_usage_id from usage name
 * @rep:category BUSINESS_ENTITY CZ_CONFIG_MODEL
 */

FUNCTION usage_id_from_usage_name (p_api_version IN  NUMBER
                          ,p_usage_name IN VARCHAR2
                          ,x_return_status        OUT NOCOPY  VARCHAR2
                          ,x_msg_count            OUT NOCOPY  NUMBER
                          ,x_msg_data             OUT NOCOPY  VARCHAR2)
RETURN NUMBER;

-----------------------------------------------------
-- Start of comments
--    API name    : usage_id_from_usage_name
--    Type        : Public.
--
--    Function    :  Returns the MODEL_USAGE_ID for a given NAME(usage name).
--
--    Pre-reqs    : None.
--    Parameters  :
--    IN          :     p_api_version           IN NUMBER         Required
--                      p_usage_name            IN VARCHAR2         Required
--                                              CZ_MODEL_USAGES.NAME
--                      p_user_id               IN NUMBER         Required
--                            user id
--                      p_resp_id               IN NUMBER         Required
--                            responsibility id
--                      p_appl_id               IN NUMBER         Required
--                            application id
--    OUT         :
--                      x_return_status       OUT NOCOPY VARCHAR2 Required
--                      x_msg_count           OUT NOCOPY NUMBER   Required
--                      x_msg_data            OUT NOCOPY VARCHAR2 Required
--    RETURNS     :     NUMBER
--                                              MODEL_USAGE_ID is there exists a matching usage for the given p_usage_name.
--                                              NULL, if either there is no match for the given p_usage_name
--						or if p_usage_name is null;
--
--    Version     : Current version       1.0
--                  Initial version       1.0
--
-- End of comments
-----------------------------------------------------
/*#
 * This API retrieves the model_usage_id for a specified usage name
 * @param p_api_version Current version of the API is 1.0
 * @param p_usage_name usage for which model_usage_id is to retrieved
 * @param x_return_status status string
 * @param x_msg_count number of error messages
 * @param x_msg_data string which contains error messages
 * @param p_user_id user id
 * @param p_resp_id responsibility id
 * @param p_appl_id application id
 * @return MODEL_USAGE_ID if there exists a matching usage for the given p_usage_name.
 *         NULL  if either there is no match for the given p_usage_name or if p_usage_name is null
 * @rep:scope public
 * @rep:compatibility S
 * @rep:lifecycle active
 * @rep:displayname Get model_usage_id from usage name
 * @rep:category BUSINESS_ENTITY CZ_CONFIG_MODEL
 */

Function usage_id_from_usage_name (
  p_api_version          IN  NUMBER,
  p_user_id              IN  NUMBER,
  p_resp_id              IN  NUMBER,
  p_appl_id              IN  NUMBER,
  p_usage_name           IN VARCHAR2,
  x_return_status        OUT NOCOPY VARCHAR2,
  x_msg_count            OUT NOCOPY NUMBER,
  x_msg_data             OUT NOCOPY VARCHAR2
)
RETURN NUMBER;

-----------------------------------------------------
/*
 * Public API for Model Migration.
 * @param p_request_id This is the CZ_MODEL_PUBLICATIONS, MIGRATION_GROUP_ID of the migration request.
 *                     Migration request is created by Developer and contains the list of all models selected
 *                     for Migration from the source's Configurator Repository, target Instance name and
 *                     target Repository Folder.
 * @param p_userid     Standard parameters required for locking. Represent calling user.
 * @param p_respid     Standard parameters required for locking. Represent calling responsibility.
 * @param p_applid     Standard parameters required for locking. Represent calling application.
 * @param p_run_id     Number identifying the session. If left NULL, the API will generate the number and
 *                     return it in x_run_id.
 * @param x_run_id     Output parameter containing internally generated session identifier if p_run_id
 *                     was NULL, otherwise equal to p_run_id.
 */

PROCEDURE migrate_models(p_api_version IN  NUMBER,
                         p_request_id  IN  NUMBER,
                         p_user_id     IN  NUMBER,
                         p_resp_id     IN  NUMBER,
                         p_appl_id     IN  NUMBER,
                         p_run_id      IN  NUMBER,
                         x_run_id      OUT NOCOPY NUMBER,
                         x_status      OUT NOCOPY VARCHAR2
                        );
--------------------------API status return codes-----------------------------------------

G_STATUS_SUCCESS                constant NUMBER :=0;
G_STATUS_ERROR                  constant NUMBER :=1;
G_STATUS_WARNING                constant NUMBER :=2;

------------------------------------------------------------------------------------------
-- added by jonatara:bug6375827
-- Start of comments
 --    API name    : create_publication_request
 --    Type        : Public
 --    Function    : Create model publication request
 --    Pre-reqs    : None.
 --    Parameters  :
 --    IN          : p_api_version      NUMBER
 --                  p_model_id         NUMBER
 --                  p_ui_def_id        NUMBER
 --                  p_publication_mode VARCHAR2  Default 'P'
 --                  p_server_id        NUMBER
 --                  p_appl_id_tbl      CZ_PB_MGR.t_ref
 --                  p_usg_id_tbl       CZ_PB_MGR.t_ref - Default -1 ('Any Usage')
 --                  p_lang_tbl         CZ_PB_MGR.t_lang_code - Default 'US'
 --                  p_start_date       DATE - Default cz_utils.epoch_begin
 --                  p_end_date         DATE - Default cz_utils.epoch_end
 --    OUT NOCOPY  : x_publication_id   NUMBER
 --                  x_return_status    VARCHAR2
 --                  x_msg_count        NUMBER
 --                  x_msg_data         VARCHAR2
 --    Version     : Current version    1.0
 --                  Initial version    1.0
 --    Notes       :
 --
 -- End of comments
 /*#
  * Create model publication request
  * @param p_api_version      api version
  * @param p_model_id         devl_project_id of model
  * @param p_ui_def_id        ui_def_id of the UI
  * @param p_publication_mode publication mode ( 't' or 'p' )  DEFAULT 'P'
  * @param p_server_id        publication target server id
  * @param p_appl_id_tbl      Table of application ids
  * @param p_usg_id_tbl       Table of usage ids               DEFAULT -1 (ie., 'Any Usage')
  * @param p_lang_tbl         Table of language codes          DEFAULT 'US'
  * @param p_start_date       Effective start date             Default cz_utils.epoch_begin
  * @param p_end_date         Effective end date               DEFAULT CZ_UTILS.CZ_UTILS.epoch_end
  * @param x_publication_id   Publication Id created
  * @param x_return_status    Return status
  * @param x_msg_count        Message count
  * @param x_msg_data         (Error) Message
  * @rep:scope public
  * @rep:lifecycle active
  * @rep:displayname Create model publication request
  * @rep:category BUSINESS_ENTITY CZ_CONFIG_MODEL
  */
 PROCEDURE create_publication_request (
   p_api_version       IN NUMBER,
   p_model_id          IN NUMBER,
   p_ui_def_id         IN NUMBER,
   p_publication_mode  IN VARCHAR2,              -- DEFAULT 'P'
   p_server_id         IN NUMBER,
   p_appl_id_tbl       IN CZ_PB_MGR.t_ref,
   p_usg_id_tbl        IN CZ_PB_MGR.t_ref,       -- DEFAULT -1 (ie., 'Any Usage')
   p_lang_tbl          IN CZ_PB_MGR.t_lang_code, -- DEFAULT 'US'
   p_start_date        IN DATE,                  -- DEFAULT CZ_UTILS.epoch_begin
   p_end_date          IN DATE,                  -- DEFAULT CZ_UTILS.CZ_UTILS.epoch_end
   x_publication_id    OUT NOCOPY NUMBER,
   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2
 );

 -----------------------------------------------------------------------------
 -- Start of comments
 --    API name    : create_publication_request
 --    Type        : Public
 --    Function    : Create model publication request
 --    Pre-reqs    : None.
 --    Parameters  :
 --    IN          : p_api_version      NUMBER
 --                  p_model_id         NUMBER
 --                  p_ui_def_id        NUMBER
 --                  p_publication_mode VARCHAR2  DEFAULT 'P'
 --                  p_server_id        NUMBER
 --                  p_appl_id_tbl      CZ_PB_MGR.t_ref
 --                  p_usg_id_tbl       CZ_PB_MGR.t_ref - Default -1 ( "Any Usage" )
 --                  p_lang_tbl         CZ_PB_MGR.t_lang_code - Default 'US'
 --                  p_start_date       DATE - Default cz_utils.epoch_begin
 --                  p_end_date         DATE - Default cz_utils.epoch_end
 --                  p_user_id          NUMBER
 --                  p_resp_id          NUMBER
 --                  p_appl_id          NUMBER
 --    OUT NOCOPY  : x_publication_id   NUMBER
 --                  x_return_status    VARCHAR2
 --                  x_msg_count        NUMBER
 --                  x_msg_data         VARCHAR2
 --    Version     : Current version    1.0
 --                  Initial version    1.0
 --    Notes       :
 --
 -- End of comments
 /*#
  * Create model publication request
  * @param p_api_version      api version
  * @param p_model_id         devl_project_id of model
  * @param p_ui_def_id        ui_def_id of the UI
  * @param p_publication_mode publication mode ( 't' or 'p' )  DEFAULT 'P'
  * @param p_server_id        publication target server id
  * @param p_appl_id_tbl      Table of application ids
  * @param p_usg_id_tbl       Table of usage ids               DEFAULT -1 (ie., 'Any Usage')
  * @param p_lang_tbl         Table of language codes          DEFAULT 'US'
  * @param p_start_date       Effective start date             Default cz_utils.epoch_begin
  * @param p_end_date         Effective end date               DEFAULT CZ_UTILS.CZ_UTILS.epoch_end
  * @param p_user_id          Application user id
  * @param p_resp_id          Responsibility id
  * @param p_appl_id          Application id
  * @param x_publication_id   Publication Id created
  * @param x_return_status    Return status
  * @param x_msg_count        Message count
  * @param x_msg_data         (Error) Message
  * @rep:scope public
  * @rep:lifecycle active
  * @rep:displayname Create model publication request
  * @rep:category BUSINESS_ENTITY CZ_CONFIG_MODEL
  */
 PROCEDURE create_publication_request (
   p_api_version       IN NUMBER,
   p_model_id          IN NUMBER,
   p_ui_def_id         IN NUMBER,
   p_publication_mode  IN VARCHAR2,              -- DEFAULT 'P'
   p_server_id         IN NUMBER,
   p_appl_id_tbl       IN CZ_PB_MGR.t_ref,
   p_usg_id_tbl        IN CZ_PB_MGR.t_ref,       -- DEFAULT -1 (ie., 'Any Usage')
   p_lang_tbl          IN CZ_PB_MGR.t_lang_code, -- DEFAULT 'US'
   p_start_date        IN DATE,                  -- DEFAULT CZ_UTILS.epoch_begin
   p_end_date          IN DATE,                  -- DEFAULT CZ_UTILS.CZ_UTILS.epoch_end
   p_user_id           IN NUMBER,
   p_resp_id           IN NUMBER,
   p_appl_id           IN NUMBER,
   x_publication_id    OUT NOCOPY NUMBER,
   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2
 );
 -----------------------------------------------------------------------------
END CZ_modelOperations_pub;

/
