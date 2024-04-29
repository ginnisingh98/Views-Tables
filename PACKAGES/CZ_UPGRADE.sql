--------------------------------------------------------
--  DDL for Package CZ_UPGRADE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CZ_UPGRADE" AUTHID CURRENT_USER AS
/*	$Header: czupgrds.pls 120.0 2005/05/25 06:14:49 appldev noship $	*/
---------------------------------------------------------------------------------------
NEVER_EXISTS_ID              CONSTANT PLS_INTEGER := -9999;
PATH_DELIMITER               CONSTANT CHAR(1) := '^';
---------------------------------------------------------------------------------------
ps_node_type_product         CONSTANT NUMBER := 258;
ps_node_type_component       CONSTANT NUMBER := 259;
ps_node_type_reference       CONSTANT NUMBER := 263;
ps_node_type_connector       CONSTANT NUMBER := 264;
ps_node_type_feature         CONSTANT NUMBER := 261;
ps_node_type_option          CONSTANT NUMBER := 262;
ps_node_type_total           CONSTANT NUMBER := 272;
ps_node_type_resource        CONSTANT NUMBER := 273;
ps_node_type_bom_model       CONSTANT NUMBER := 436;
ps_node_type_bom_optionclass CONSTANT NUMBER := 437;
ps_node_type_bom_standard    CONSTANT NUMBER := 438;
---------------------------------------------------------------------------------------
EXPL_NODE_TYPE_UNDEFINED     CONSTANT PLS_INTEGER := 0;
EXPL_NODE_TYPE_OPTIONAL      CONSTANT PLS_INTEGER := 1;  --A
EXPL_NODE_TYPE_MANDATORY     CONSTANT PLS_INTEGER := 2;  --B
EXPL_NODE_TYPE_CONNECTOR     CONSTANT PLS_INTEGER := 3;  --C
EXPL_NODE_TYPE_INSTANTIABLE  CONSTANT PLS_INTEGER := 4;  --D
---------------------------------------------------------------------------------------
ps_node_feature_type_option  CONSTANT NUMBER := 0;
ps_node_feature_type_integer CONSTANT NUMBER := 1;
ps_node_feature_type_float   CONSTANT NUMBER := 2;
ps_node_feature_type_boolean CONSTANT NUMBER := 3;
ps_node_feature_type_string  CONSTANT NUMBER := 4;
---------------------------------------------------------------------------------------
expr_node_type_node          CONSTANT PLS_INTEGER := 205;
expr_node_type_featprop      CONSTANT PLS_INTEGER := 204;
expr_node_type_operator      CONSTANT PLS_INTEGER := 200;
expr_node_type_punct         CONSTANT PLS_INTEGER := 208;
expr_node_type_literal       CONSTANT PLS_INTEGER := 201;
expr_node_type_sysprop       CONSTANT PLS_INTEGER := 210;
expr_node_type_prop          CONSTANT PLS_INTEGER := 207;
expr_node_type_count         CONSTANT PLS_INTEGER := 209;
EXPR_NODE_TYPE_CONSTANT      CONSTANT PLS_INTEGER := 211;
---------------------------------------------------------------------------------------
operator_dot                 CONSTANT PLS_INTEGER := 326;
---------------------------------------------------------------------------------------
SYS_PROP_NAME                CONSTANT PLS_INTEGER := 1;
SYS_PROP_SELECTION           CONSTANT PLS_INTEGER := 2;
SYS_PROP_COUNT               CONSTANT PLS_INTEGER := 3;
sys_prop_min                 CONSTANT PLS_INTEGER := 4;
sys_prop_max                 CONSTANT PLS_INTEGER := 5;
---------------------------------------------------------------------------------------
flag_not_deleted        CONSTANT CHAR(1) := '0';
flag_not_disabled       CONSTANT CHAR(1) := '0';
flag_non_virtual        CONSTANT CHAR(1) := '0';
flag_not_consequent     CONSTANT CHAR(1) := '0';
flag_virtual            CONSTANT CHAR(1) := '1';
flag_bom_required       CONSTANT CHAR(1) := '1';
flag_is_consequent      CONSTANT CHAR(1) := '1';
---------------------------------------------------------------------------------------
fatal_illegal_option_feature  EXCEPTION;
fatal_unable_to_set_virtual   EXCEPTION;
fatal_unable_to_create_header EXCEPTION;
fatal_invalid_rule            EXCEPTION;
CZ_G_UNABLE_TO_REPORT_ERROR   EXCEPTION;
CZ_S_MODEL_IGNORED            EXCEPTION;
CZ_R_RULE_IGNORED             EXCEPTION;
CZ_R_RULE_REPORTED            EXCEPTION;
---------------------------------------------------------------------------------------
RULE_TYPE_LOGIC_RULE         CONSTANT PLS_INTEGER := 21;
RULE_TYPE_NUMERIC_RULE       CONSTANT PLS_INTEGER := 22;
RULE_TYPE_COMPAT_RULE        CONSTANT PLS_INTEGER := 23;
RULE_TYPE_COMPAT_TABLE       CONSTANT PLS_INTEGER := 24;
RULE_TYPE_COMPARISON_RULE    CONSTANT PLS_INTEGER := 27;
RULE_TYPE_FUNC_COMP          CONSTANT PLS_INTEGER := 29;
RULE_TYPE_DESIGNCHART_RULE   CONSTANT PLS_INTEGER := 30;
RULE_TYPE_RULE_FOLDER        CONSTANT PLS_INTEGER := 39;
---------------------------------------------------------------------------------------
-- Use fixed sort width for all pre21 (Note starting with 21 sort width is defined by
-- Bom_Common_Definitions.G_Bom_SortCode_Width)
-- Note czsort.sql has hard coded '0001' and substr(bom_sort_order, 5)
SORT_WIDTH_PRE21  CONSTANT NUMBER := 4;
---------------------------------------------------------------------------------------

-------used for logic upgrade from 14,15,16,17 to 18 or more
TYPE	t_ref	IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

MAJOR_SCHEMA_VERSION CONSTANT VARCHAR2(40) := 'MAJOR_VERSION';
v_lce_hdr  NUMBER := 0;      /* to trap lce header id that errored OUT NOCOPY */
v_schema_version cz_db_settings.value%TYPE;

---------------------------------------------------------------------------------------
PROCEDURE VERIFY_RULES(inDevlProjectId IN NUMBER,
                       thisRunId       IN OUT NOCOPY NUMBER);
---------------------------------------------------------------------------------------

PROCEDURE AUTO_PUBLISH (p_server_id IN NUMBER);

PROCEDURE CZBOMSORT(p_model_id   IN INTEGER,
                    p_sort_width IN INTEGER,
                    p_batch_size IN INTEGER);

PROCEDURE CZNATIVEBOMSORT(p_sort_width IN INTEGER,
                          p_batch_size IN INTEGER);


PROCEDURE generate_model_tree(indevlprojectid IN NUMBER);

PROCEDURE generate_component_tree(incomponentid       IN NUMBER,
                                  inlogicnetlevel     IN NUMBER,
                                  inparentexplid      IN NUMBER,
                                  inparentcomponentid IN NUMBER,
                                  inreferringnodeid   IN NUMBER);

PROCEDURE generate_explosion;

-----------procedures used by logic upgrade

PROCEDURE cz_populate_lce_load_specs(p_lce_header_id IN NUMBER,
				      	 x_populate_error_flag IN OUT NOCOPY VARCHAR2,
		                         x_populate_error_msg  IN OUT NOCOPY VARCHAR2);

PROCEDURE upgrade_logic_files_to_18;

PROCEDURE verify_logic (x_logic_status IN OUT NOCOPY VARCHAR2);

PROCEDURE publish_vision_models;

----------------------
END CZ_UPGRADE;

 

/
