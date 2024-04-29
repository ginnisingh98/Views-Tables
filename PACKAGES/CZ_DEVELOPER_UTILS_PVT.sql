--------------------------------------------------------
--  DDL for Package CZ_DEVELOPER_UTILS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CZ_DEVELOPER_UTILS_PVT" AUTHID CURRENT_USER AS
/*	$Header: czdevus.pls 120.9.12010000.4 2009/01/19 03:36:40 vkamath ship $		*/

--
-- update node names in rule text
-- Parameters : p_rule_id - identifies rule
-- Returns    : rule text with updated node names
--
COMPONENT_TYPE               CONSTANT INTEGER := 259;
REFERENCE_TYPE               CONSTANT INTEGER := 263;
FEATURE_TYPE                 CONSTANT INTEGER := 261;
CONNECTOR_TYPE               CONSTANT INTEGER := 264;
BOM_MODEL_TYPE               CONSTANT INTEGER := 436;
OPTION_FEATURE_TYPE          CONSTANT INTEGER := 0;

PROFILE_OPTION_LABEL_BOM     CONSTANT VARCHAR2(80)  := 'CZ_DEV_ASSOC_OBJECT_BOM_NODES';
PROFILE_OPTION_LABEL_NONBOM  CONSTANT VARCHAR2(80)  := 'CZ_DEV_ASSOC_OBJ_NON_BOM_NODES';
OPTION_VALUE_LABEL_NAME      CONSTANT VARCHAR2(240) := '2';
OPTION_VALUE_LABEL_DESC      CONSTANT VARCHAR2(240) := '1';

PROFILE_OPTION_EFF_FILTER    CONSTANT VARCHAR2(80)  := 'CZEFFECTIVITYFILTER';
OPTION_VALUE_FILTER_ALL      CONSTANT VARCHAR2(240) := 'ALL';
OPTION_VALUE_FILTER_CURRENT  CONSTANT VARCHAR2(240) := 'CURRENT';
OPTION_VALUE_FILTER_FUTURE   CONSTANT VARCHAR2(240) := 'FUTUREANDCURRENT';
LCE_ENGINE_TYPE              CONSTANT VARCHAR2(1)   := 'L';
NlsNumericCharacters         CONSTANT VARCHAR2(16) := '.,';

RULE_TYPE_LOGIC              CONSTANT PLS_INTEGER := 21;
RULE_TYPE_NUMERIC            CONSTANT PLS_INTEGER := 22;
RULE_TYPE_COMPAT             CONSTANT PLS_INTEGER := 23;
RULE_TYPE_COMPAT_TABLE       CONSTANT PLS_INTEGER := 24;
RULE_TYPE_COMPARISON         CONSTANT PLS_INTEGER := 27;
RULE_TYPE_FUNC_COMP          CONSTANT PLS_INTEGER := 29;
RULE_TYPE_DESIGNCHART        CONSTANT PLS_INTEGER := 30;
RULE_TYPE_DISPLAY_CONDITION  CONSTANT PLS_INTEGER := 33;
RULE_TYPE_ENABLED_CONDITION  CONSTANT PLS_INTEGER := 34;
RULE_TYPE_RULE_FOLDER        CONSTANT PLS_INTEGER := 39;
RULE_TYPE_TEMPLATE           CONSTANT PLS_INTEGER := 100;
RULE_TYPE_EXPRESSION         CONSTANT PLS_INTEGER := 200;
RULE_TYPE_JAVA_METHOD        CONSTANT PLS_INTEGER := 300;
RULE_TYPE_BINDING            CONSTANT PLS_INTEGER := 400;
RULE_TYPE_RULE_SYS_PROP      CONSTANT PLS_INTEGER := 500;
RULE_TYPE_JAVA_SYS_PROP      CONSTANT PLS_INTEGER := 501;
RULE_TYPE_POPULATOR          CONSTANT PLS_INTEGER := 502;
RULE_TYPE_CAPTION            CONSTANT PLS_INTEGER := 700;

G_PKG_NAME varchar2(255):='CZ_DEVELOPER_UTILS_PVT';

FUNCTION replace_Rule_Text(p_rule_id     IN NUMBER,
                           p_use_profile IN NUMBER DEFAULT 0) RETURN CLOB;

FUNCTION parse_to_statement (p_rule_id IN NUMBER) RETURN VARCHAR2;
--vsingava bug6638552 23 Nov '08
--performance fix for model report
PROCEDURE start_model_report(p_devl_project_id IN NUMBER);
PROCEDURE end_model_report;


--
-- copy subtree of Model tree
-- Parameters :
--   p_node_id       - identifies root node of subtree
--   p_new_parent_id - identifies new parent node
--   p_copy_mode     - specifies mode of copying
--   xrun_id         - OUT parameter : if =0 => no errors
--                   - else =CZ_DB_LOGS.run_id
--   x_return_status - status string
--   x_msg_count     - number of error messages
--   x_msg_data      - string which contains error messages
--
PROCEDURE copy_PS_Subtree
(
p_node_id            IN  NUMBER,
p_new_parent_id      IN  NUMBER,
p_copy_mode          IN  VARCHAR2,
x_run_id             OUT NOCOPY NUMBER,
x_return_status      OUT NOCOPY VARCHAR2,
x_msg_count          OUT NOCOPY NUMBER,
x_msg_data           OUT NOCOPY VARCHAR2
);

--
-- copy Rule
-- Parameters :
--   p_rule_id              - identifies rule to copy
--   p_rule_folder_id       - identifies rule folder in which rule will be copied
--   x_out_new_rule_id      - OUT variable - id of new rule
--   x_run_id               - OUT parameter : if =0 => no errors
--                          - else =CZ_DB_LOGS.run_id
--   x_return_status        - status string
--   x_msg_count            - number of error messages
--   x_msg_data             - string which contains error messages
--
PROCEDURE copy_Rule
(p_rule_id                  IN   NUMBER,
 p_rule_folder_id           IN   NUMBER DEFAULT NULL,
 x_out_new_rule_id          OUT  NOCOPY INTEGER,
 x_run_id                   OUT  NOCOPY NUMBER,
 x_return_status            OUT  NOCOPY VARCHAR2,
 x_msg_count                OUT  NOCOPY NUMBER,
 x_msg_data                 OUT  NOCOPY VARCHAR2);

PROCEDURE copy_Rule
(p_rule_id                  IN   NUMBER,
 p_rule_folder_id           IN   NUMBER DEFAULT NULL,
 p_init_msg_list            IN   VARCHAR2,
 x_out_new_rule_id          OUT  NOCOPY INTEGER,
 x_run_id                   OUT  NOCOPY NUMBER,
 x_return_status            OUT  NOCOPY VARCHAR2,
 x_msg_count                OUT  NOCOPY NUMBER,
 x_msg_data                 OUT  NOCOPY VARCHAR2);

PROCEDURE copy_Rule
(p_rule_id                  IN   NUMBER,
 p_rule_folder_id           IN   NUMBER DEFAULT NULL,
 p_init_msg_list            IN   VARCHAR2,
 p_ui_def_id                IN   NUMBER,
 p_ui_page_id               IN   NUMBER,
 p_ui_page_element_id       IN   VARCHAR2,
 x_out_new_rule_id          OUT  NOCOPY NUMBER,
 x_run_id                   OUT  NOCOPY NUMBER,
 x_return_status            OUT  NOCOPY VARCHAR2,
 x_msg_count                OUT  NOCOPY NUMBER,
 x_msg_data                 OUT  NOCOPY VARCHAR2);

--
-- copy Rule Folder
-- Parameters :
--   p_rule_folder_id       -
--   p_new_parent_folder_id -
--   x_out_new_rule_id      -
--   x_run_id               - OUT parameter : if =0 => no errors
--                          - else =CZ_DB_LOGS.run_id
--   x_return_status        - status string
--   x_msg_count            - number of error messages
--   x_msg_data             - string which contains error messages
--
PROCEDURE copy_Rule_Folder
(p_rule_folder_id           IN   NUMBER,
 p_new_parent_folder_id     IN   NUMBER,
 x_out_rule_folder_id       OUT  NOCOPY   INTEGER,
 x_run_id                   OUT  NOCOPY   NUMBER,
 x_return_status            OUT  NOCOPY   VARCHAR2,
 x_msg_count                OUT  NOCOPY   NUMBER,
 x_msg_data                 OUT  NOCOPY   VARCHAR2);

--
--   copy Repository folder
--   p_folder_id            - identifies folder to copy
--   p_encl_folder_id       - enclosing folder to copy to
--   x_folder_id            - new copied folder
--   x_run_id               - OUT parameter : if =0 => no errors
--                          - else =CZ_DB_LOGS.run_id
--   x_return_status        - status string
--   x_msg_count            - number of error messages
--   x_msg_data             - string which contains error messages
--
PROCEDURE copy_Repository_Folder
(
p_folder_id        IN   NUMBER,
p_encl_folder_id   IN   NUMBER,
x_folder_id        OUT  NOCOPY   NUMBER,
x_run_id           OUT  NOCOPY   NUMBER,
x_return_status    OUT  NOCOPY   VARCHAR2,
x_msg_count        OUT  NOCOPY   NUMBER,
x_msg_data         OUT  NOCOPY   VARCHAR2,
p_init_msg_list    IN   VARCHAR2 DEFAULT FND_API.G_TRUE
);

--
-- get absolute model path ( <=> path from root node )
-- Parameters :
--   p_ps_node_id  - identifies model tree node
--   px_model_path - OUT parameter - absolute model path
--
PROCEDURE get_Absolute_Model_Path
(
 p_ps_node_id  IN NUMBER,
 px_model_path OUT NOCOPY VARCHAR2
);

FUNCTION is_val_number (p_str IN VARCHAR2) RETURN VARCHAR2;

--
-- get absolute model path ( <=> path from root node )
-- Parameters :
--   p_ps_node_id  - identifies model tree node
--
FUNCTION get_Absolute_Model_Path
(
 p_ps_node_id  IN NUMBER
) RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES (get_Absolute_Model_Path, WNDS, WNPS);

--
-- get full model path ( <=> path from root node )
-- Parameters :
--   p_ps_node_id        - identifies model tree node
--   p_model_ref_expl_id - identifies model_ref_expl_id of model tree node
--   p_model_id          - identifies current model
--   px_model_path       - OUT parameter - full model path
--
PROCEDURE get_Full_Model_Path
(
 p_ps_node_id          IN  NUMBER,
 p_model_ref_expl_id   IN  NUMBER,
 p_model_id            IN  NUMBER,
 px_model_path         OUT NOCOPY VARCHAR2
);

--
-- get full model path ( <=> path from root node )
-- Parameters :
--   p_ps_node_id        - identifies model tree node
--   p_model_ref_expl_id - identifies model_ref_expl_id of model tree node
--   p_model_id          - identifies current model
--  RETURN : full model path
--
FUNCTION get_Full_Model_Path
(
 p_ps_node_id          IN  NUMBER,
 p_model_ref_expl_id   IN  NUMBER,
 p_model_id            IN  NUMBER)  RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES (get_Full_Model_Path, WNDS, WNPS);


--
-- get relative model path ( <=> path from root node )
-- Parameters :
--   p_ps_node_id  - identifies model tree node
--   px_model_path - OUT parameter - absolute model path
--
PROCEDURE get_Relative_Model_Path
(
 p_ps_node_id  IN NUMBER,
 px_model_path OUT NOCOPY VARCHAR2
);

--
-- get relative model path ( <=> path from root node )
-- Parameters :
--   p_ps_node_id  - identifies model tree node
--
FUNCTION get_Relative_Model_Path
(
 p_ps_node_id  IN NUMBER
) RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES (get_Relative_Model_Path, WNDS, WNPS);

FUNCTION get_absolute_label_path(p_ps_node_id   IN NUMBER,
                                 p_label_bom    IN VARCHAR2,
                                 p_label_nonbom IN VARCHAR2) RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES (get_absolute_label_path, WNDS, WNPS);

FUNCTION get_node_label(p_ps_node_type  IN NUMBER,
                        p_name          IN VARCHAR2,
                        p_description   IN VARCHAR2) RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES (get_node_label, WNDS, WNPS);

FUNCTION get_node_label(p_ps_node_id IN NUMBER) RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES (get_node_label, WNDS, WNPS);

PROCEDURE get_full_label_path(p_ps_node_id        IN  NUMBER,
                              p_model_ref_expl_id IN  NUMBER,
                              p_model_id          IN  NUMBER,
                              px_model_path       OUT NOCOPY VARCHAR2);

FUNCTION get_full_label_path(p_ps_node_id        IN  NUMBER,
                             p_model_ref_expl_id IN  NUMBER,
                             p_model_id          IN  NUMBER) RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES (get_full_label_path, WNDS, WNPS);

--
-- get path in Repository
-- Parameters :
--   p_object_id   - identifies object
--   p_object_type - identifies object type
--
FUNCTION get_Repository_Path
(
 p_object_id   IN NUMBER,
 p_object_type IN VARCHAR2
) RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES (get_Repository_Path, WNDS, WNPS);

--
-- get path in Rule Folders
-- Parameters :
--   p_rule_folder_id   - identifies object
--   p_object_type      - identifies object type
--
FUNCTION get_Rule_Folder_Path
(
 p_rule_folder_id   IN NUMBER,
 p_object_type      IN VARCHAR2
) RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES (get_Rule_Folder_Path, WNDS, WNPS);

--
-- delete_model_node
-- Parameters :
--   p_ps_node_id           - cz_ps_nodes.ps_node_id
--   x_return_status        - status string
--   x_msg_count            - number of error messages
--   x_msg_data             - string which contains error messages
--

PROCEDURE delete_model_node
(p_ps_node_id               IN   NUMBER,
 x_return_status            OUT  NOCOPY   VARCHAR2,
 x_msg_count                OUT  NOCOPY   NUMBER,
 x_msg_data                 OUT  NOCOPY   VARCHAR2);

--
-- delete_ui_def
-- Parameters :
--   p_ui_def_id            - cz_ui_defs.ui_def_id
--   x_return_status        - status string
--   x_msg_count            - number of error messages
--   x_msg_data             - string which contains error messages
--

PROCEDURE delete_ui_def
(p_ui_def_id                IN   NUMBER,
 x_return_status            OUT  NOCOPY   VARCHAR2,
 x_msg_count                OUT  NOCOPY   NUMBER,
 x_msg_data                 OUT  NOCOPY   VARCHAR2);


--
-- delete_rule_folder
-- Parameters :
--   p_rule_folder_id       - cz_rule_folders.rule_folder_id where object_type = 'RFD'
--   x_return_status        - status string
--   x_msg_count            - number of error messages
--   x_msg_data             - string which contains error messages
--

PROCEDURE delete_rule_folder
(p_rule_folder_id           IN   NUMBER,
 x_return_status            OUT  NOCOPY   VARCHAR2,
 x_msg_count                OUT  NOCOPY   NUMBER,
 x_msg_data                 OUT  NOCOPY   VARCHAR2);



--
-- delete_rule_sequence
-- Parameters :
--   p_rule_sequence_id     - cz_rule_folders.rule_folder_id where object_type = 'RSQ'
--   x_return_status        - status string
--   x_msg_count            - number of error messages
--   x_msg_data             - string which contains error messages
--

PROCEDURE delete_rule_sequence
(p_rule_sequence_id         IN   NUMBER,
 x_return_status            OUT  NOCOPY   VARCHAR2,
 x_msg_count                OUT  NOCOPY   NUMBER,
 x_msg_data                 OUT  NOCOPY   VARCHAR2);


--
-- delete_repository_folder
-- Parameters :
--   p_rp_folder_id         - cz_rp_entries.object_id where object_type = 'FLD'
--   x_return_status        - status string
--   x_msg_count            - number of error messages
--   x_msg_data             - string which contains error messages
--

PROCEDURE delete_repository_folder
(p_rp_folder_id             IN   NUMBER,
 x_return_status            OUT  NOCOPY   VARCHAR2,
 x_msg_count                OUT  NOCOPY   NUMBER,
 x_msg_data                 OUT  NOCOPY   VARCHAR2);

--
-- delete_item_type
-- Parameters :
--   p_item_type_id         - cz_item_types.item_type_id
--   x_return_status        - status string
--   x_msg_count            - number of error messages
--   x_msg_data             - string which contains error messages
--

PROCEDURE delete_item_type
(p_item_type_id             IN   NUMBER,
 x_return_status            OUT  NOCOPY   VARCHAR2,
 x_msg_count                OUT  NOCOPY   NUMBER,
 x_msg_data                 OUT  NOCOPY   VARCHAR2);

--
-- is_model_deleteable
-- Parameters :
--   p_model_id         IN NUMBER:            - object_id in cz_rp_entries where object_type = 'PRJ'
--
--   x_return_status    OUT VARCHAR2(1):      - return string:
--
--                           'S': model is deleteable by this user
--                           'E': model is not deleteable by this user, see x_msg_data for reasons:
--                              : invalid p_model_id, user privs, locks, existing refs/pubs, seeded_model
--                           'U': Unexpected error, see l_msg_data
--
--   x_msg_count        OUT NUMBER            - number of error messages in stack
--   x_msg_data         OUT VARCHAR2(2000)    - string which contains error message
--
PROCEDURE is_model_deleteable (p_model_id IN NUMBER,
				    x_return_status OUT NOCOPY VARCHAR2,
				    x_msg_count  OUT NOCOPY NUMBER,
				    x_msg_data   OUT NOCOPY VARCHAR2);

-----------------------------------------------------
--
-- delete_model
-- Parameters :
--   p_model_id         IN NUMBER:            - object_id in cz_rp_entries where object_type = 'PRJ'
--
--   x_return_status    OUT VARCHAR2(1):      - return string:
--
--                           'S': model is deleted
--                           'E': model is not deleted, see x_msg_data for reasons:
--                              : invalid p_model_id, user privs, locks, existing refs/pubs, seeded_model
--                           'U': Unexpected error, see l_msg_data
--
--   x_msg_count        OUT NUMBER            - number of error messages in stack
--   x_msg_data         OUT VARCHAR2(2000)    - string which contains error message
PROCEDURE delete_model(p_model_id             IN  NUMBER
                      ,x_return_status        OUT NOCOPY  VARCHAR2
                      ,x_msg_count            OUT NOCOPY  NUMBER
                      ,x_msg_data             OUT NOCOPY  VARCHAR2);
-------------------------------------------------------
--
--   copy_model_usage
--   p_model_usage_id            - identifies folder to copy
--   p_encl_folder_id       - enclosing folder to copy to
--   x_folder_id            - new copied folder
--   x_run_id               - OUT parameter : if =0 => no errors
--                          - else =CZ_DB_LOGS.run_id
--   x_return_status        - status string
--   x_msg_count            - number of error messages
--   x_msg_data             - string which contains error messages

PROCEDURE copy_model_usage
(
p_model_usage_id        IN   NUMBER,
p_encl_folder_id   IN   NUMBER,
x_new_model_usage_id        OUT  NOCOPY   NUMBER,
x_return_status    OUT  NOCOPY   VARCHAR2,
x_msg_count        OUT  NOCOPY   NUMBER,
x_msg_data         OUT  NOCOPY   VARCHAR2
);


PROCEDURE copy_property
(
p_property_id        IN   NUMBER,
p_encl_folder_id   IN   NUMBER,
x_new_property_id        OUT  NOCOPY   NUMBER,
x_return_status    OUT  NOCOPY   VARCHAR2,
x_msg_count        OUT  NOCOPY   NUMBER,
x_msg_data         OUT  NOCOPY   VARCHAR2
);

PROCEDURE copy_effectivity_set
(
p_effectivity_set_id        IN   NUMBER,
p_encl_folder_id   IN   NUMBER,
x_new_effectivity_set_id        OUT  NOCOPY   NUMBER,
x_return_status    OUT  NOCOPY   VARCHAR2,
x_msg_count        OUT  NOCOPY   NUMBER,
x_msg_data         OUT  NOCOPY   VARCHAR2
);

PROCEDURE copy_archive
(
p_archive_id        IN   NUMBER,
p_encl_folder_id   IN   NUMBER,
x_new_archive_id        OUT  NOCOPY   NUMBER,
x_return_status    OUT  NOCOPY   VARCHAR2,
x_msg_count        OUT  NOCOPY   NUMBER,
x_msg_data         OUT  NOCOPY   VARCHAR2
);

PROCEDURE copy_ui_template
(
p_template_id        IN   NUMBER,
p_encl_folder_id   IN   NUMBER,
x_new_template_id        OUT  NOCOPY   NUMBER,
x_return_status    OUT  NOCOPY   VARCHAR2,
x_msg_count        OUT  NOCOPY   NUMBER,
x_msg_data         OUT  NOCOPY   VARCHAR2
);

PROCEDURE copy_ui_master_template
(
p_ui_def_id        IN   NUMBER,
p_encl_folder_id   IN   NUMBER,
x_new_ui_def_id  	    OUT  NOCOPY   NUMBER,
x_return_status    OUT  NOCOPY   VARCHAR2,
x_msg_count        OUT  NOCOPY   NUMBER,
x_msg_data         OUT  NOCOPY   VARCHAR2
);


-----------------delete API(s)
--------is effset deletable
 PROCEDURE is_eff_set_deleteable(p_eff_set_id    IN  NUMBER,
  	       x_return_status OUT NOCOPY VARCHAR2,
	       x_msg_count     OUT NOCOPY NUMBER,
	       x_msg_data      OUT NOCOPY VARCHAR2);

---- delete effectivity sets
PROCEDURE delete_eff_set(p_eff_set_id    IN  NUMBER,
	       x_return_status OUT NOCOPY VARCHAR2,
	       x_msg_count     OUT NOCOPY NUMBER,
	       x_msg_data      OUT NOCOPY VARCHAR2);

-------can delete archive
PROCEDURE is_archive_deleteable(p_archive_id IN NUMBER,
	     x_return_status OUT NOCOPY VARCHAR2,
	     x_msg_count     OUT NOCOPY NUMBER,
	     x_msg_data      OUT NOCOPY VARCHAR2);

--------delete archive
PROCEDURE delete_archive(p_archive_id  IN NUMBER,
	     x_return_status OUT NOCOPY VARCHAR2,
	     x_msg_count     OUT NOCOPY NUMBER,
	     x_msg_data      OUT NOCOPY VARCHAR2);

-----can delete property
PROCEDURE is_property_deleteable (p_property_id IN NUMBER,
	     x_return_status OUT NOCOPY VARCHAR2,
	     x_msg_count     OUT NOCOPY NUMBER,
	     x_msg_data      OUT NOCOPY VARCHAR2);

------------------delete property
PROCEDURE delete_property(p_property_id IN NUMBER,
	     x_return_status OUT NOCOPY VARCHAR2,
	     x_msg_count     OUT NOCOPY NUMBER,
	     x_msg_data      OUT NOCOPY VARCHAR2);

----can delete umt
PROCEDURE is_umt_deleteable (p_umt_id IN NUMBER,
	     x_return_status OUT NOCOPY VARCHAR2,
	     x_msg_count     OUT NOCOPY NUMBER,
	     x_msg_data      OUT NOCOPY VARCHAR2);

------------delete umt
PROCEDURE delete_umt(p_umt_id   IN NUMBER,
	   x_return_status OUT NOCOPY VARCHAR2,
	   x_msg_count     OUT NOCOPY NUMBER,
	   x_msg_data      OUT NOCOPY VARCHAR2);


-----can delete uct
PROCEDURE is_uct_deleteable(p_uct_id IN NUMBER,
	   x_return_status OUT NOCOPY VARCHAR2,
	   x_msg_count     OUT NOCOPY NUMBER,
	   x_msg_data      OUT NOCOPY VARCHAR2);

------delete uct
PROCEDURE delete_uct(p_uct_id IN NUMBER,
	   x_return_status OUT NOCOPY VARCHAR2,
	   x_msg_count     OUT NOCOPY NUMBER,
	   x_msg_data      OUT NOCOPY VARCHAR2);


PROCEDURE is_repos_fld_deleteable (p_rp_folder_id IN NUMBER,
				    x_return_status OUT NOCOPY VARCHAR2,
				    x_msg_count     OUT NOCOPY NUMBER,
				    x_msg_data      OUT NOCOPY VARCHAR2);

PROCEDURE is_usage_deleteable(p_usage_id IN NUMBER,
				    x_return_status OUT NOCOPY VARCHAR2,
				    x_msg_count     OUT NOCOPY NUMBER,
				    x_msg_data      OUT NOCOPY VARCHAR2);

PROCEDURE delete_usage(p_usage_id  IN NUMBER,
			     x_return_status OUT NOCOPY VARCHAR2,
			     x_msg_count     OUT NOCOPY NUMBER,
			     x_msg_data      OUT NOCOPY VARCHAR2);

PROCEDURE NEW_USAGE (enclosingFolderId IN NUMBER,
                     usageId IN OUT NOCOPY NUMBER);

FUNCTION append_name(p_object_id IN NUMBER, p_object_type IN VARCHAR2, p_object_name IN VARCHAR2) RETURN VARCHAR2;

FUNCTION copy_name(p_object_id   IN NUMBER,p_object_type IN VARCHAR2) RETURN VARCHAR2 ;

--
-- The procedure identifies whether two explosion nodes are within the same virtual boundary.
-- The parameters are two model_ref_expl_id values and the output parameter.
-- The procedure returns 1 if the nodes are in the same virtual boundary, 0 otherwise.
--
PROCEDURE in_boundary (p_base_expl_id            IN NUMBER,
                       p_node_expl_id            IN NUMBER,
                       p_node_persistent_node_id IN NUMBER,
                       x_output                  OUT NOCOPY PLS_INTEGER);

--
-- The function identifies whether two explosion nodes are within the same virtual boundary.
-- The parameters are two model_ref_expl_id values.
-- The function returns 1 if the nodes are in the same virtual boundary, 0 otherwise.
--
FUNCTION in_boundary (p_base_expl_id            IN NUMBER,
                      p_node_expl_id            IN NUMBER,
                      p_node_persistent_node_id IN NUMBER)
  RETURN PLS_INTEGER;
PRAGMA RESTRICT_REFERENCES (in_boundary, WNDS, WNPS);

PROCEDURE verify_special_rule(p_rule_id IN NUMBER,
                              p_name    IN VARCHAR,
                              x_run_id  IN OUT NOCOPY NUMBER);

FUNCTION runtime_relative_path(p_base_expl_id IN NUMBER,
                               p_base_pers_id IN NUMBER,
                               p_node_expl_id IN NUMBER,
                               p_node_pers_id IN NUMBER)
  RETURN VARCHAR2;

---- this functions does validations required during the time of
---- moving a rule or rule folder to a different folder
PROCEDURE is_rule_movable(p_src_rule_id    IN cz_rule_folders.rule_folder_id%TYPE,
		    p_src_rule_type   IN cz_rule_folders.object_type%TYPE,
		    p_tgt_rule_fld_id IN cz_rule_folders.rule_folder_id%TYPE,
		    x_return_status OUT NOCOPY VARCHAR2,
		    x_msg_count      OUT NOCOPY NUMBER,
		    x_msg_data       OUT NOCOPY VARCHAR2);

/*
 * This function is used for effectivity filtering in CZ_EXPLNODES_IMAGE_EFF_V. When called
 * on a node and given the node's parent identity and node's effectivity parameters it
 * returns 1 if the node is visible with the current effectivity filtering settings,
 * 0 otherwise.
 *
 * @param p_parent_psnode_id   correspond to cz_explmodel_nodes_v.effective_parent_id
 * @param p_parent_expl_id     correspond to cz_explmodel_nodes_v.parent_psnode_expl_id
 * p_model_id                  correspond to cz_explmodel_nodes_v.model_id
 * p_self_eff_from             correspond to cz_explmodel_nodes_v.effective_from
 * p_self_eff_until            correspond to cz_explmodel_nodes_v.effective_until
 * p_self_eff_set_id           correspond to cz_explmodel_nodes_v.effectivity_set_id
 *
 * @rep:scope public
 * @rep:product CZ
 * @rep:displayname Auxiliary function for using in CZ_EXPLNODES_IMAGE_EFF_V
 * @rep:lifecycle active
 * @rep:compatibility S
 * @rep:category Effectivity Filtering
 */

FUNCTION is_node_visible(p_parent_psnode_id IN NUMBER,
                        p_parent_expl_id    IN NUMBER,
                        p_model_id          IN NUMBER,
                        p_self_eff_from     IN DATE,
                        p_self_eff_until    IN DATE,
                        p_self_eff_set_id   IN NUMBER) RETURN PLS_INTEGER;
PRAGMA RESTRICT_REFERENCES (is_node_visible, WNDS, WNPS);

/*
 * This function is used for effectivity filtering. It takes a node identity and arrays of effectivity
 * parameters for the children of this node. It returns an array with 0 or 1 for every child of this
 * node, 1 if the child node is visible with the current effectivity filtering settings, 0 otherwise.
 *
 * @param p_parent_psnode_id   ps_node_id of the node
 * @param p_parent_expl_id     model_ref_expl_id of the node
 * p_self_eff_from             array of effective_from values for children of the node
 * p_self_eff_until            array of effective_until values for children of the node
 * p_self_eff_set_id           array of effectivity_set_id values for children of the node
 *
 * @rep:scope public
 * @rep:product CZ
 * @rep:displayname Auxiliary function for effectivity filtering
 * @rep:lifecycle active
 * @rep:compatibility S
 * @rep:category
 */

FUNCTION get_visibility(p_parent_psnode_id  IN NUMBER,
                        p_parent_expl_id    IN NUMBER,
                        p_self_eff_from     IN system.cz_date_tbl_type,
                        p_self_eff_until    IN system.cz_date_tbl_type,
                        p_self_eff_set_id   IN system.cz_number_tbl_type)
  RETURN system.cz_number_tbl_type;
PRAGMA RESTRICT_REFERENCES (get_visibility, WNDS, WNPS);

/*
 * This procedure is a wrapper over the function to be called by the Developer.
 *
 * @rep:scope public
 * @rep:product CZ
 * @rep:displayname Wrapper over the function for Developer
 * @rep:lifecycle active
 * @rep:compatibility S
 * @rep:category
 */

PROCEDURE get_visibility(p_parent_psnode_id  IN NUMBER,
                         p_parent_expl_id    IN NUMBER,
                         p_self_eff_from     IN system.cz_date_tbl_type,
                         p_self_eff_until    IN system.cz_date_tbl_type,
                         p_self_eff_set_id   IN system.cz_number_tbl_type,
                         x_is_visible        IN OUT NOCOPY system.cz_number_tbl_type);

FUNCTION annotated_node_path(p_model_id           IN NUMBER,
                             p_model_ref_expl_id  IN NUMBER,
                             p_ps_node_id         IN NUMBER) RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES (annotated_node_path, WNDS, WNPS);

/*
 * This function is used for getting translated description for a given object id and object type.
 * It takes object_id and object_type as an input and returns the translated description.
 *
 * @param object_id               object_id of the repository object
 * @param object_type             object_type of the repository object
 * @rep:scope public
 * @rep:product CZ
 * @rep:displayname Function for getting translated usage description.
 * @rep:lifecycle active
 * @rep:compatibility S
 * @rep:category
 */
FUNCTION get_trans_desc(object_id  IN NUMBER,object_type  IN varchar2) RETURN VARCHAR2;

/*
 * This function returns the date when the logic generation occured
 * It uses the model id to determine engine type for switching between
 * cz_lce_headers (LCE) and cz_fce_files (FCE)
 *
 * @param p_model_id              model id
 */
FUNCTION get_last_logic_gen_date(p_model_id in NUMBER)
  RETURN cz_fce_files.creation_date%TYPE;

/*
 * This procedure is a wrapper for calling copy_repository_folder.
 * It loops over all of the folders calling a procedure to check for
 * locked Models or Templates and logs them before continuing to do the actual
 *  copy operation.
 *
 *   p_folder_ids           - identifies folders to copy
 *   p_encl_folder_id       - enclosing folder to copy to
 *   x_folder_id            - folder_id
 *   x_return_status        - status string
 *   x_msg_count            - number of error messages
 *   x_msg_data             - string which contains error messages
 */

PROCEDURE copy_repository_folders
(
  p_folder_ids       IN   system.cz_number_tbl_type,
  p_encl_folder_id   IN   NUMBER,
  x_folder_id        OUT  NOCOPY   NUMBER,
  x_run_id           OUT  NOCOPY   NUMBER,
  x_return_status    OUT  NOCOPY   VARCHAR2,
  x_msg_count        OUT  NOCOPY   NUMBER,
  x_msg_data         OUT  NOCOPY   VARCHAR2
);

/*
 * This procedure converts CX's in a fce model that still link CIO classes.
 *
 *   p_model_id           - identifies model to convert
 *   x_return_status        - status string
 *   x_msg_count            - number of error messages
 *   x_msg_data             - string which contains error messages
 */

PROCEDURE ConvertModelCXs
(
p_model_id      IN NUMBER,
x_return_status OUT  NOCOPY VARCHAR2,
x_msg_count     OUT  NOCOPY NUMBER,
x_msg_data      OUT  NOCOPY VARCHAR2
);

END;

/
