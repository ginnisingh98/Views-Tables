--------------------------------------------------------
--  DDL for Package CZ_CONTRACTS_API_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CZ_CONTRACTS_API_GRP" AUTHID CURRENT_USER AS
/*	$Header: czgconas.pls 120.0 2005/05/25 06:37:11 appldev noship $		*/
/*#
 * This is the public interface for some operations in Oracle Configurator.
 * @rep:scope internal
 * @rep:product CZ
 * @rep:displayname Contracts API
 * @rep:lifecycle active
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY CZ_CONFIG_MODEL
 * @rep:category BUSINESS_ENTITY CZ_RP_FOLDER
 */

------------------------------------------------------------------------------------------
--
--    CONSTANTS
--
--integer constant for object_id of the ROOT folder in Repository
 RP_ROOT_FOLDER      CONSTANT PLS_INTEGER:=0;

 -- Caption rule constants.  OKC supplies caption rule IDs in generic import.
 G_CAPTION_RULE_DESC CONSTANT PLS_INTEGER := 802;
 G_CAPTION_RULE_NAME CONSTANT PLS_INTEGER := 801;

 G_CZ_EPOCH_BEGIN    CONSTANT DATE        := CZ_UTILS.EPOCH_BEGIN_;
 G_CZ_EPOCH_END      CONSTANT DATE        := CZ_UTILS.EPOCH_END_;

--
--     TYPES
--

 TYPE	t_ref        IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
 TYPE   t_lang_code  IS TABLE OF fnd_languages.language_code%TYPE INDEX BY BINARY_INTEGER;

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
 * check if repository folder exists
 * @param p_api_version api verion
 * @param p_encl_folder_id the folder id (object_id) of the RP folder to check
 * @param p_rp_folder_id The parent folder in which the p_rp_folder_id
 *                       will be checked for existance
 *                       Use RP_ROOT_FOLDER for folder id of the root folder
 *                       Pass NULL to check the folder anywhere in the repository
 * @return TRUE when encl folder is null and
 *         p_rp_folder exists anywhere in repository TRUE when encl folder is not null and it exists anywhere in repository and
 *         p_rp_folder exists in it FALSE when encl folder is null and p_rp_folder doesn't exists anywhere in repository
 *         FALSE when encl folder is not null and it doesn't exists anywhere in repository FALSE when encl folder is not null and
 *         p_rp_folder is not in it
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Check if Repository folder exists
 * @rep:category BUSINESS_ENTITY CZ_RP_FOLDER
 */
FUNCTION rp_folder_exists (p_api_version    IN NUMBER
                          ,p_encl_folder_id IN NUMBER
                          ,p_rp_folder_id   IN NUMBER) RETURN BOOLEAN;
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
/*#
 * Create new Repostitory folder
 * @param p_api_version api verion
 * @param p_encl_folder_id The parent folder to create new folder use RP_ROOT_FOLDER constant for root folder
 * @param p_new_folder_name The new folder name
 * @param p_folder_desc folder description
 * @param p_folder_notes folder notes
 * @param x_new_folder_id  the new folder id created, or the folder id of the folder with the same name in the same enclosing folder
 * @param x_return_status status string
 * @param x_msg_count number of error messages
 * @param x_msg_data string which contains error messages
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create new Repostitory folder
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
 * Generic Import
 * @param p_api_version api verion
 * @param p_run_id Specify the run_id to process. If NULL, all records in interface tables where run_id is NULL will be processed.
 * @param p_rp_folder_id The repository folder to import the model into, use RP_ROOT_FOLDER constant for the root folder id
 * @param x_run_id CZ_DB_LOGS.run_id if there are warnings and/or errors, 0 if not
 * @param x_status G_ERROR, G_WARNING or G_SUCCESS (constants from this package)
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
--    API name    : delete_model
--    Type        : Public.
--    Function    : Deletes a model in cz_devl_projects table (imported models only)
--    Pre-reqs    : None.
--    Parameters  :
--    IN          :     p_api_version    IN  NUMBER         Required
--    IN          :     p_model_id       IN  NUMBER         Required
--                           the devl_project_id in cz_devl_projects table
--    IN          :     p_orig_sys_ref          IN  VARCHAR2         Required
--                           the orig_sys_ref in cz_devl_projects table - cannot be null
--
--    OUT         :
--                      x_return_status       OUT NOCOPY VARCHAR2 Required
--                      x_msg_count           OUT NOCOPY NUMBER   Required
--                      x_msg_data            OUT NOCOPY VARCHAR2 Required
--
--    Version     : Current version       1.0
--                  Initial version       1.0
--
--    Notes       :
--                 1. Both p_model_id and p_orig_sys_ref must match for deleting a model in cz_devl_projects
--                 2. It will not delete and return error if any of the following is true
--                              a) If the devl project is referened by any other devl_project(s)
--                                  To delete the devl project, first remove all the references to this devl project
--                              b) If the model is in the process of being published (any export status except 'OK')
--                                  To delete the model first delete all pending publications of this model and/or wait
--                                  for processing publications of this model to complete.
--                              c) If the model structure (including any referenced models),
--                                 any of its user interfaces (including any child UIs)
--                                 or any of the rule folders (including any subfolders) are locked
--                                 at the time the delete_model is called.
--                                 To delete, unlock any locked components and re-run the delete_model
-- End of comments
/*#
 * delete model
 * @param p_api_version api verion
 * @param p_model_id the devl_project_id in cz_devl_projects table
 * @param p_orig_sys_ref the orig_sys_ref in cz_devl_projects table - cannot be null
 * @param x_return_status status string
 * @param x_msg_count number of error messages
 * @param x_msg_data string which contains error messages
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Delete Model
 * @rep:category BUSINESS_ENTITY CZ_CONFIG_MODEL
 */
PROCEDURE delete_model(p_api_version          IN  NUMBER
                      ,p_model_id             IN  NUMBER
                      ,p_orig_sys_ref         IN  VARCHAR2
                      ,x_return_status        OUT NOCOPY  VARCHAR2
                      ,x_msg_count            OUT NOCOPY  NUMBER
          ,x_msg_data             OUT NOCOPY  VARCHAR2);




----start of comments
---- create publication request
---- Parameters
---- IN:	 p_api_version 		IN NUMBER 		 Required
----	       p_model_id   		IN NUMBER,		 Required
---          p_ui_def_id  		IN NUMBER,		 Required
----         p_publication_mode 	IN NUMBER,
----         p_server_id   		IN NUMBER,
----  	 p_appl_id_tbl 		IN number_type_tbl,
----         p_usg_id_tbl  		IN number_type_tbl,
----		 p_lang_tbl    		IN varchar_type_tbl,
----		 p_start_date  		IN DATE,
----		 p_end_date   		IN DATE,
----
---- OUT
----	       x_publication_id OUT 	NOCOPY 	NUMBER,
----	       x_return_status 	OUT 	NOCOPY 	VARCHAR2,
----	       x_msg_count    	OUT 	NOCOPY 	NUMBER,
----	       x_msg_data       OUT	NOCOPY	VARCHAR2
----
----Parameter Description
----	IN
----  	 p_api_version  Version: Current version :1.0
----     	 p_model_id:   	devl_project_id of the model being published
----		 p_ui_def_id :  	ui_def_id of the model being published
----
----		 p_publication_mode: Publication mode.
----			If no publication mode is passed, production mode ('P') is defaulted
----			Valid values are 'P' (production mode), 'T' (Test mode).
----
----		p_appl_id_tbl: application that would access the published model
----			 This is an array that contains the application id(s).  For contracts we
----			 Can default this to the application id of 'OKC' and not allow any other
----			 Values.
----
----		p_usg_id_tbl: publication usage.
----			This is an array containing usage id(s).
----			For contracts, we can default this   to "Any Usage" (-1).
----
----		p_lang_tbl: an array containing the languages.
----
----		p_start_date: date from which the publication would be applicable
----		p_end_date:  date until which the publication would be applicable
----		  	If none of the above dates are passed, the start date would have a
----			Default value of epoch begin and end date would be defaulted to
----			Epoch end.
----		P_server_id: would be defaulted to 0 for contracts
----
----	OUT
----          x_publication_id : the id of the publication request
----		 (I don't think OKC should care about this, but it is good for debugging purposes.)
----
----	          x_return_status : FND_API.G_RET_STS_SUCCESS
----					    FND_API.G_RET_STS_ERROR
----					    FND_API.G_RET_STS_UNEXPECTED
----	          x_msg_count      Count of error messages.
----	          x_msg_data       error message


PROCEDURE create_publication_request (p_api_version  IN NUMBER,
				  p_model_id         IN NUMBER,
				  p_ui_def_id        IN NUMBER,
				  p_publication_mode IN VARCHAR2,
				  p_server_id        IN NUMBER,
				  p_appl_id_tbl      IN t_ref,
				  p_usg_id_tbl       IN t_ref,
				  p_lang_tbl         IN t_lang_code,
				  p_start_date       IN DATE,
				  p_end_date         IN DATE,
				  x_publication_id   OUT NOCOPY NUMBER,
				  x_return_status    OUT NOCOPY VARCHAR2,
				  x_msg_count        OUT NOCOPY NUMBER,
				  x_msg_data         OUT NOCOPY VARCHAR2);



----start of comments
---- edit_publication
---- Parameters
---- IN:	 p_api_version 		IN NUMBER 		 Required
----	         p_publicationId   	IN NUMBER,		 Required
---              p_applicationId   	IN NUMBER,		 Required
----             p_publication_mode 	IN VARCHAR2,
----             p_languageId		IN NUMBER,
----  	         p_usageId         	IN NUMBER,
----		 p_startdate  		IN DATE,
----		 p_disabledate   		IN DATE,
----
---- OUT:
----	       x_return_status 	OUT 	NOCOPY 	VARCHAR2,
----	       x_msg_count    	OUT 	NOCOPY 	NUMBER,
----	       x_msg_data       OUT	NOCOPY	VARCHAR2
-----
PROCEDURE EDIT_PUBLICATION(p_api_version     IN NUMBER,
                           p_publicationId   IN NUMBER,
                           p_applicationId   IN  OUT  NOCOPY t_ref,
                           p_languageId	   IN  OUT  NOCOPY t_lang_code,
                           p_usageId         IN  OUT  NOCOPY t_ref,
                           p_startDate	   IN	      DATE,
                           p_disableDate     IN	      DATE,
                           p_publicationMode IN       VARCHAR2,
                           x_return_status OUT NOCOPY VARCHAR2,
                           x_msg_count     OUT NOCOPY NUMBER,
                           x_msg_data      OUT NOCOPY VARCHAR2);


PROCEDURE EDIT_PUBLICATION(p_api_version     IN NUMBER,
                           p_publicationId   IN NUMBER,
                           p_applicationId   IN  OUT  NOCOPY VARCHAR2,
                           p_languageId	   IN  OUT  NOCOPY VARCHAR2,
                           p_usageId         IN  OUT  NOCOPY VARCHAR2,
                           p_startDate	   IN	      DATE,
                           p_disableDate     IN	      DATE,
                           p_publicationMode IN       VARCHAR2,
                           x_return_status OUT NOCOPY VARCHAR2,
                           x_msg_count     OUT NOCOPY NUMBER,
                           x_msg_data      OUT NOCOPY VARCHAR2);



----start of comments
---- delete_publication
---- Parameters
---- IN:	 p_api_version 		IN NUMBER 		 Required
----	       publicationId   	      IN NUMBER,		 Required
----
---- OUT:
----	       x_return_status 	OUT 	NOCOPY 	VARCHAR2,
----	       x_msg_count    	OUT 	NOCOPY 	NUMBER,
----	       x_msg_data       OUT	NOCOPY	VARCHAR2
-----
PROCEDURE DELETE_PUBLICATION(p_api_version     IN         NUMBER,
			     publicationId     IN         NUMBER,
			     x_return_status   OUT NOCOPY VARCHAR2,
			     x_msg_count       OUT NOCOPY NUMBER,
			     x_msg_data        OUT NOCOPY VARCHAR2
                            );


----start of comments
---- delete_ui_def
---- Parameters
---- IN:       p_api_version 		IN NUMBER 		 Required =  1.0
----	       p_ui_def_id   	        IN NUMBER,		 Required
----
---- OUT:
----	       x_return_status 	OUT 	NOCOPY 	VARCHAR2,
----	       x_msg_count    	OUT 	NOCOPY 	NUMBER,
----	       x_msg_data       OUT	NOCOPY	VARCHAR2
-----
PROCEDURE delete_ui_def(p_api_version              IN   NUMBER,
                        p_ui_def_id                IN   NUMBER,
                        x_return_status            OUT  NOCOPY   VARCHAR2,
                        x_msg_count                OUT  NOCOPY   NUMBER,
                        x_msg_data                 OUT  NOCOPY   VARCHAR2
                        );

----start of comments
---- generate_logic
---- Parameters
---- IN:       p_api_version 		IN NUMBER 		 Required =  1.0
----	       p_devl_project_id        IN NUMBER,		 Required
----
---- OUT:
----           x_run_id         OUT     NOCOPY  NUMBER,
----	       x_return_status 	OUT 	NOCOPY 	VARCHAR2,
----	       x_msg_count    	OUT 	NOCOPY 	NUMBER,
----	       x_msg_data       OUT	NOCOPY	VARCHAR2
----
-- End of comments
PROCEDURE generate_logic(p_api_version      IN            NUMBER,
                         p_devl_project_id  IN            NUMBER,
                         x_run_id           OUT  NOCOPY   NUMBER,
                         x_return_status    OUT  NOCOPY   VARCHAR2,
                         x_msg_count        OUT  NOCOPY   NUMBER,
                         x_msg_data         OUT  NOCOPY   VARCHAR2);

-- Start of comments
--    API name    : Publish_Model
--    Type        : Public.
--    Function    : Publish a model
--    Pre-reqs    : None.
--    Parameters  :
--    IN          :     p_api_version           IN  NUMBER         Required = 1.0
--                      p_publication_id        IN  NUMBER         Required
--   OUT:
--                      x_run_id                OUT     NOCOPY  NUMBER,
--                      x_return_status 	OUT 	NOCOPY 	VARCHAR2,
--                      x_msg_count    	        OUT 	NOCOPY 	NUMBER,
--                      x_msg_data              OUT	NOCOPY	VARCHAR2
--
--    Version     : Current version       1.0
--                  Initial version       1.0
--    Notes       : It should only be run on publications with a status of 'Pending'
--
-- End of comments
PROCEDURE publish_model(p_api_version      IN            NUMBER,
                        p_publication_id   IN            NUMBER,
                        x_run_id           OUT  NOCOPY   NUMBER,
                        x_return_status    OUT  NOCOPY   VARCHAR2,
                        x_msg_count        OUT  NOCOPY   NUMBER,
                        x_msg_data         OUT  NOCOPY   VARCHAR2);
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

PROCEDURE create_jrad_ui(p_api_version        IN  NUMBER,
                         p_devl_project_id    IN  NUMBER,
                         p_show_all_nodes     IN  VARCHAR2,
                         p_master_template_id IN  NUMBER,
                         p_create_empty_ui    IN  VARCHAR2,
                         x_ui_def_id          OUT NOCOPY NUMBER,
                         x_return_status      OUT NOCOPY VARCHAR2,
                         x_msg_count          OUT NOCOPY NUMBER,
                         x_msg_data           OUT NOCOPY VARCHAR2);

--------------------------API status return codes-----------------------------------------
G_STATUS_SUCCESS                constant NUMBER :=0;
G_STATUS_ERROR                  constant NUMBER :=1;
G_STATUS_WARNING                constant NUMBER :=2;

------------------------------------------------------------------------------------------

END CZ_contracts_api_grp;

 

/
