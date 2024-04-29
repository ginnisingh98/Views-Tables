--------------------------------------------------------
--  DDL for Package FEM_CONDITIONS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FEM_CONDITIONS_API" AUTHID CURRENT_USER AS
--$Header: FEMCONDS.pls 120.2.12010000.2 2008/08/28 08:37:52 lkiran ship $

PROCEDURE DISPLAY_CONDITION_PREDICATE(
   x_err_code OUT NOCOPY NUMBER,
   x_err_msg OUT NOCOPY VARCHAR2,
   p_condition_obj_id IN NUMBER,
   p_rule_effective_date IN VARCHAR2);

/*PROCEDURE DISPLAY_CONDITION_PREDICATE(
   p_api_version          IN NUMBER,
   p_init_msg_list        IN VARCHAR2,
   p_commit               IN VARCHAR2,
   p_encoded              IN VARCHAR2,
   p_condition_obj_id     IN NUMBER,
   p_rule_effective_date  IN VARCHAR2,
   x_return_status        OUT NOCOPY VARCHAR2,
   x_msg_count            OUT NOCOPY NUMBER,
   x_msg_data             OUT NOCOPY VARCHAR2);*/


PROCEDURE GENERATE_CONDITION_PREDICATE(
   x_err_code OUT NOCOPY NUMBER,
   x_err_msg OUT NOCOPY VARCHAR2,
   p_condition_obj_id IN NUMBER,
   p_rule_effective_date IN VARCHAR2,
   p_input_fact_table_name IN VARCHAR2,
   p_table_alias IN VARCHAR2,
   p_display_predicate IN VARCHAR2,
   p_return_predicate_type IN VARCHAR2,
   p_logging_turned_on IN VARCHAR2,
   x_predicate_string OUT NOCOPY LONG);


------------------------
--  Package Constants --
------------------------

g_false            CONSTANT  VARCHAR2(1)  := FND_API.G_FALSE;
g_true             CONSTANT  VARCHAR2(1)  := FND_API.G_TRUE;
g_success          CONSTANT  VARCHAR2(1)  := FND_API.G_RET_STS_SUCCESS;
g_error            CONSTANT  VARCHAR2(1)  := FND_API.G_RET_STS_ERROR;
g_unexp            CONSTANT  VARCHAR2(1)  := FND_API.G_RET_STS_UNEXP_ERROR;
g_api_version      CONSTANT  NUMBER       := 1.0;

PROCEDURE GENERATE_CONDITION_PREDICATE(
   p_api_version     IN NUMBER     DEFAULT g_api_version,
   p_init_msg_list   IN VARCHAR2   DEFAULT g_false,
   p_commit          IN VARCHAR2   DEFAULT g_false,
   p_encoded         IN VARCHAR2   DEFAULT g_true,
   p_condition_obj_id IN NUMBER,
   p_rule_effective_date IN VARCHAR2,
   p_input_fact_table_name IN VARCHAR2,
   p_table_alias IN VARCHAR2,
   p_display_predicate IN VARCHAR2,
   p_return_predicate_type IN VARCHAR2,
   p_logging_turned_on IN VARCHAR2,
   x_return_status  OUT NOCOPY VARCHAR2,
   x_msg_count      OUT NOCOPY NUMBER,
   x_msg_data       OUT NOCOPY VARCHAR2,
   x_predicate_string OUT NOCOPY LONG);

/******Mapping By Dimension Type Support (Bug 4059078)******/
PROCEDURE GENERATE_CONDITION_PREDICATE(
   p_api_version     IN NUMBER     DEFAULT g_api_version,
   p_init_msg_list   IN VARCHAR2   DEFAULT g_false,
   p_commit          IN VARCHAR2   DEFAULT g_false,
   p_encoded         IN VARCHAR2   DEFAULT g_true,
   p_condition_obj_id IN NUMBER,
   p_rule_effective_date IN VARCHAR2,
   p_input_fact_table_name IN VARCHAR2,
   p_table_alias IN VARCHAR2,
   p_display_predicate IN VARCHAR2,
   p_return_predicate_type IN VARCHAR2,
   p_logging_turned_on IN VARCHAR2,
   p_by_dimension_column IN VARCHAR2,
   p_by_dimension_id  IN NUMBER,
   p_by_dimension_value IN VARCHAR2,
   x_return_status  OUT NOCOPY VARCHAR2,
   x_msg_count      OUT NOCOPY NUMBER,
   x_msg_data       OUT NOCOPY VARCHAR2,
   x_predicate_string OUT NOCOPY LONG);

/****** API's for use by Condition VO's (Bug 5451847) ******/
FUNCTION Get_Dim_Member_Display_Code (
  p_dimension_id                  in number
  ,p_member_id                    in varchar2
) RETURN varchar2;

FUNCTION Get_Dim_Member_Name (
  p_dimension_id                  in number
  ,p_member_id                    in varchar2
) RETURN varchar2;

/*============================================================================+
 | PROCEDURE
 |   Generate_Dim_Hier_Query
 |
 | DESCRIPTION
 |   This procedure returns a query string for finding a list of nodes in a
 |   hierarchy definition based on the passed hierarchy object id,
 |   effective date, node id (and value set id for VSR dimensions), and
 |   relation code.
 |
 |   All passed parameters are checked to ensure they are valid.
 |
 |  SCOPE - PUBLIC
 +============================================================================*/

PROCEDURE Generate_Dim_Hier_Query (
  p_api_version                   in number   default g_api_version
  ,p_init_msg_list                in varchar2 default g_false
  ,p_commit                       in varchar2 default g_false
  ,p_encoded                      in varchar2 default g_true
  ,x_return_status                out nocopy varchar2
  ,x_msg_count                    out nocopy number
  ,x_msg_data                     out nocopy varchar2
  ---------------------------------------------------
  ,p_dimension_id                 in number
  ,p_hierarchy_object_id          in number
  ,p_effective_date               in varchar2
  ,p_relation_code                in varchar2
  ,p_node_id                      in varchar2
  ,p_value_set_id                 in number default null
  ,x_query_string                 out nocopy long
);


------------------------
--  Standard Types --
------------------------
DEF_OBJECT_ID   FEM_OBJECT_CATALOG_B.OBJECT_ID%TYPE;
DEF_OBJ_DEF_ID  FEM_OBJECT_DEFINITION_B.OBJECT_DEFINITION_ID%TYPE;
DEF_OBJECT_NAME FEM_OBJECT_CATALOG_VL.OBJECT_NAME%TYPE;
DEF_FOLDER_NAME FEM_FOLDERS_VL.FOLDER_NAME%TYPE;

------------------------
--  Exceptions --
------------------------
USER_EXCEPTION EXCEPTION;
NO_CONDITION_EXCEPTION EXCEPTION;
INVALID_FACT_TABLE_EXCEPTION EXCEPTION;
NO_FACT_TABLE_EXCEPTION EXCEPTION;
HIER_FLATTENED_EXCEPTION EXCEPTION;
NO_VALID_COMPONENTS_EXCEPTION EXCEPTION;
NO_COMPONENTS_EXCEPTION EXCEPTION;
INVALID_DIM_COMP_EXCEPTION EXCEPTION;

------------------------
--  Messages --
------------------------
G_INVALID_COLUMN CONSTANT VARCHAR2(30)          := 'FEM_COND_API_INVALID_COLUMN';
G_INVALID_OPERATOR CONSTANT VARCHAR2(30)        := 'FEM_COND_API_INVALID_OPERATOR';
G_INVALID_NODE CONSTANT VARCHAR2(30)            := 'FEM_COND_API_INVALID_NODE';
G_INVALID_RELATION CONSTANT VARCHAR2(30)        := 'FEM_COND_API_INVALID_RELATION';
G_INVALID_DIMENSION CONSTANT VARCHAR2(30)       := 'FEM_COND_API_INVALID_DIM_COL';
G_NO_VERSION CONSTANT VARCHAR2(30)              := 'FEM_COND_API_NO_DEFINITION';
G_INVALID_TABLE CONSTANT VARCHAR2(30)           := 'FEM_COND_API_INVALID_TABLE';
G_NO_TABLE CONSTANT VARCHAR2(30)                := 'FEM_COND_API_NO_TABLE';
G_HIER_FLATTENED CONSTANT VARCHAR2(30)          := 'FEM_COND_API_HIER_FLATTENED';
G_NO_VALID_COMPS CONSTANT VARCHAR2(30)          := 'FEM_COND_API_NO_VALID_COMPS';
G_NO_COMPONENTS CONSTANT VARCHAR2(30)           := 'FEM_COND_API_NO_COMPS';
G_UNHANDLED_EXCEPTION CONSTANT VARCHAR2(30)     := 'FEM_COND_API_UNHANDLED_ERROR';
G_INVALID_COMP_DIMENSION CONSTANT VARCHAR2(30)  := 'FEM_COND_API_INVALID_COMP_DIM';
G_NULL_PARAM_VALUE_ERR CONSTANT VARCHAR2(30)    := 'FEM_NULL_PARAM_VALUE_ERR';
G_BAD_DIM_ID_ERR CONSTANT VARCHAR2(30)          := 'FEM_BAD_DIM_ID_ERR';
G_DIM_BAD_DIM_LABEL CONSTANT VARCHAR2(30)       := 'FEM_DIM_BAD_DIM_LABEL';
G_INVALID_DIM_COMPONENT CONSTANT VARCHAR2(30)   := 'FEM_COND_API_INVALID_DIM_COMP';

------------------------
--  Tokens --
------------------------
G_COLUMN_TOKEN CONSTANT VARCHAR2(30) := 'COLUMN_NAME';
G_TABLE_TOKEN CONSTANT VARCHAR2(30) := 'TABLE_NAME';
G_OPERATOR_TOKEN CONSTANT VARCHAR2(30) := 'OPERATOR';
G_CONDITION_TOKEN CONSTANT VARCHAR2(30) := 'CONDITION';
G_COMPONENT_TOKEN CONSTANT VARCHAR2(30) := 'COMPONENT';
G_NODE_TOKEN CONSTANT VARCHAR2(30) := 'NODE';
G_HIERARCHY_TOKEN CONSTANT VARCHAR2(30) := 'HIERARCHY';
G_RELATION_TOKEN CONSTANT VARCHAR2(30) := 'RELATION';
G_EFFECTIVE_DATE_TOKEN CONSTANT VARCHAR2(30) := 'EFFECTIVE_DATE';
G_COMP_DIM_TOKEN CONSTANT VARCHAR2(30) := 'COMP_DIM';
G_SQL_ERR_TOKEN CONSTANT VARCHAR2(30) := 'SQLERRM';
G_PARAM_TOKEN CONSTANT VARCHAR2(30) := 'PARAM';
G_DIM_ID_TOKEN CONSTANT VARCHAR2(30) := 'DIM_ID';
G_DIM_LABEL_TOKEN CONSTANT VARCHAR2(30) := 'DIM_LABEL';

------------------------
--  PL/SQL Tables --
------------------------
TYPE DATA_STEP_VALUES_REC IS RECORD(
   OPERATOR_CODE VARCHAR2(30),
   OPERATOR_VALUE VARCHAR2(30),
   VALUE VARCHAR2(255),
   MAX_RANGE_VALUE VARCHAR2(255));

TYPE DATA_STEP_VALUES_TAB IS TABLE OF DATA_STEP_VALUES_REC
   INDEX BY BINARY_INTEGER;

TYPE DATA_DIM_STEP_PREDICATE_REC IS RECORD(
   DATA_DIM_COMPONENT_DEF_ID NUMBER,
   STEP_SPECIFIC_PREDICATE LONG);

TYPE DATA_DIM_STEP_PREDICATE_TAB IS TABLE OF DATA_DIM_STEP_PREDICATE_REC
   INDEX BY BINARY_INTEGER;

TYPE INVALID_DATA_COMPONENTS_REC IS RECORD(
   COMPONENT_OBJECT_NAME DEF_OBJECT_NAME%TYPE,
   COMPONENT_FOLDER_NAME DEF_FOLDER_NAME%TYPE,
   INVALID_TABLE_NAME VARCHAR2(30),
   INVALID_FIRST_COLUMN VARCHAR2(30),
   INVALID_SECOND_COLUMN VARCHAR2(30));

TYPE INVALID_DATA_COMPONENTS_TAB IS TABLE OF INVALID_DATA_COMPONENTS_REC
   INDEX BY BINARY_INTEGER;

TYPE COMP_CUR_TYPE IS REF CURSOR;

TYPE INVALID_DIM_COMPONENTS_REC IS RECORD(
   COMPONENT_OBJECT_NAME DEF_OBJECT_NAME%TYPE,
   COMPONENT_FOLDER_NAME DEF_FOLDER_NAME%TYPE,
   INVALID_TABLE_NAME VARCHAR2(30),
   INVALID_DIMENSION_COLUMN VARCHAR2(30));

TYPE INVALID_DIM_COMPONENTS_TAB IS TABLE OF INVALID_DIM_COMPONENTS_REC
   INDEX BY BINARY_INTEGER;


------------------------
--  Constants --
------------------------
FEM_APP_ID CONSTANT NUMBER	 := 274;
FEM_APP CONSTANT VARCHAR2(5) := 'FEM';

G_OPEN CONSTANT VARCHAR2(1)   := '(';
G_CLOSE CONSTANT VARCHAR2(1)  := ')';
G_PERIOD	CONSTANT VARCHAR2(1)      := '.';
G_SPACE CONSTANT VARCHAR2(1)        := ' ';
G_2_SPACE CONSTANT VARCHAR2(2)        := '  ';

--Operands--
G_OR  	CONSTANT VARCHAR2(3)          := 'OR';
G_AND 	CONSTANT VARCHAR2(3)          := 'AND';

--Operators--
G_GREATER  CONSTANT VARCHAR2(30)     := FEM_UTILS.getLookupMeaning
				(p_Application_ID => FEM_APP_ID
   	                        ,p_Lookup_Type => 'FEM_CONDITION_OPERATOR'
			        ,p_Lookup_Code => 'GREATER');
G_LESSER   CONSTANT VARCHAR2(30)     := FEM_UTILS.getLookupMeaning
				(p_Application_ID => FEM_APP_ID
                                ,p_Lookup_Type => 'FEM_CONDITION_OPERATOR'
                                ,p_Lookup_Code => 'LESSER');
G_EQUAL	   CONSTANT VARCHAR2(30)	     := FEM_UTILS.getLookupMeaning
                                (p_Application_ID => FEM_APP_ID
                                ,p_Lookup_Type => 'FEM_CONDITION_OPERATOR'
                                ,p_Lookup_Code => 'EQUAL');
G_GREATER_EQUAL CONSTANT VARCHAR2(30) := FEM_UTILS.getLookupMeaning
                                (p_Application_ID => FEM_APP_ID
                                ,p_Lookup_Type => 'FEM_CONDITION_OPERATOR'
                                ,p_Lookup_Code => 'GREATER_EQUAL');
G_LESSER_EQUAL	CONSTANT VARCHAR2(30) := FEM_UTILS.getLookupMeaning
                                (p_Application_ID => FEM_APP_ID
                                ,p_Lookup_Type => 'FEM_CONDITION_OPERATOR'
                                ,p_Lookup_Code => 'LESSER_EQUAL');
G_NOT_EQUAL  CONSTANT VARCHAR2(30)    := FEM_UTILS.getLookupMeaning
                                (p_Application_ID => FEM_APP_ID
                                ,p_Lookup_Type => 'FEM_CONDITION_OPERATOR'
                                ,p_Lookup_Code => 'NOT_EQUAL');
G_BETWEEN    CONSTANT VARCHAR2(30)    := FEM_UTILS.getLookupMeaning
                                (p_Application_ID => FEM_APP_ID
                                ,p_Lookup_Type => 'FEM_CONDITION_RANGE_OPERATOR'
                                ,p_Lookup_Code => 'BETWEEN');
G_NOT_BETWEEN  CONSTANT VARCHAR2(30)  := FEM_UTILS.getLookupMeaning
                                (p_Application_ID => FEM_APP_ID
                                ,p_Lookup_Type => 'FEM_CONDITION_RANGE_OPERATOR'
                                ,p_Lookup_Code => 'NOT_BETWEEN');
G_NODE  CONSTANT VARCHAR2(30)       := FEM_UTILS.getLookupMeaning
                                (p_Application_ID => FEM_APP_ID
                                ,p_Lookup_Type => 'FEM_COND_DIM_HIER_RELATIONS'
                                ,p_Lookup_Code => 'NODE');
G_DESC  CONSTANT VARCHAR2(30)       := FEM_UTILS.getLookupMeaning
                                (p_Application_ID => FEM_APP_ID
                                ,p_Lookup_Type => 'FEM_COND_DIM_HIER_RELATIONS'
                                ,p_Lookup_Code => 'DESC_OF');
G_NODE_DESC  CONSTANT VARCHAR2(30)       := FEM_UTILS.getLookupMeaning
                                (p_Application_ID => FEM_APP_ID
                                ,p_Lookup_Type => 'FEM_COND_DIM_HIER_RELATIONS'
                                ,p_Lookup_Code => 'NODE_AND_DESC');
G_LAST_DESC  CONSTANT VARCHAR2(30)       := FEM_UTILS.getLookupMeaning
                                (p_Application_ID => FEM_APP_ID
                                ,p_Lookup_Type => 'FEM_COND_DIM_HIER_RELATIONS'
                                ,p_Lookup_Code => 'LAST_DESC_OF');

--Data Component Step Types--
G_DATA_ANOTHER_COL CONSTANT VARCHAR2(30) := 'DATA_ANOTHER_COL';
G_SPECIFIC_VALUE   CONSTANT VARCHAR2(30) := 'DATA_SPECIFIC';
G_RANGE_OF_VALUES  CONSTANT VARCHAR2(30) := 'DATA_RANGE';

--Data Component SQL--
G_QUERY_FOR_DATA_CMPS CONSTANT LONG :=

                    'select'
                  ||' a.cond_component_obj_id  as COMPONENT_OBJECT_ID'
                  ||',a.data_dim_flag as COMPONENT_FLAG'
                  ||',c1.object_definition_id  as COMPONENT_OBJECT_DEF_ID'
                  ||',b.object_type_code       as COMPONENT_TYPE_CODE'
	            ||',d.table_name             as FACT_TABLE_NAME'
                  ||' from'
                  ||' fem_cond_components a'
                  ||',fem_object_catalog_b b'
                  ||',fem_object_definition_b c1'
                  ||',fem_cond_data_cmp_tables d'
                  ||' where'
                  ||'    a.condition_obj_def_id = :Cond_Obj_Def_ID '
                  ||' and b.object_id = a.cond_component_obj_id'
                  ||' and b.object_id = c1.object_id'
                  ||' and a.data_dim_flag = ''T'''
                  ||' and d.cond_data_cmp_obj_def_id = c1.object_definition_id'
                  ||' and d.table_name = :Table_Name';

--(Display) Data Component SQL--
G_QUERY_FOR_DISPLAY_DATA_CMPS CONSTANT LONG :=
                    'select'
                  ||' a.cond_component_obj_id  as COMPONENT_OBJECT_ID'
                  ||',a.data_dim_flag as COMPONENT_FLAG'
                  ||',c1.object_definition_id  as COMPONENT_OBJECT_DEF_ID'
                  ||',b.object_type_code       as COMPONENT_TYPE_CODE'
	            ||',d.table_name             as FACT_TABLE_NAME'
                  ||' from'
                  ||' fem_cond_components a'
                  ||',fem_object_catalog_b b'
                  ||',fem_object_definition_b c1'
                  ||',fem_cond_data_cmp_tables d'
                  ||' where'
                  ||'    a.condition_obj_def_id = :Cond_Obj_Def_ID '
                  ||' and b.object_id = a.cond_component_obj_id'
                  ||' and b.object_id = c1.object_id'
                  ||' and a.data_dim_flag = ''T'''
                  ||' and d.cond_data_cmp_obj_def_id = c1.object_definition_id';

G_UNION CONSTANT VARCHAR2(10) := ' UNION ';

--Dimension Component SQL--
G_QUERY_FOR_DIM_CMPS CONSTANT LONG :=
                    'SELECT'
                  ||' c1.object_id as COMPONENT_OBJECT_ID,'
                  ||' a.data_dim_flag AS COMPONENT_FLAG,'
                  ||' d1.object_definition_id AS COMPONENT_OBJ_DEF_ID,'
                  ||' c1.object_type_code AS COMPONENT_TYPE_CODE,'
                  ||' NULL AS FACT_TABLE_NAME'
                  ||' FROM fem_cond_components a,'
                  ||' fem_object_catalog_b c,'
                  ||' fem_object_definition_b d,'
                  ||' fem_object_catalog_b c1,'
                  ||' fem_object_definition_b d1'
                  ||' where a.condition_obj_def_id = :condition_obj_def_id'
                  ||' and a.condition_obj_def_id = d.object_definition_id'
                  ||' and c.object_id = d.object_id'
                  ||' and a.cond_component_obj_id = c1.object_id'
                  ||' and c1.object_id = d1.object_id'
                  ||' and a.data_dim_flag IN (''D'', ''V'')';

END fem_conditions_api;

/
