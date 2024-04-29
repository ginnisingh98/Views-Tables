--------------------------------------------------------
--  DDL for Package Body FEM_GLOBAL_VS_COMBO_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FEM_GLOBAL_VS_COMBO_UTIL_PKG" AS
--$Header: fem_globvs_utl.plb 120.1 2008/02/20 06:56:56 jcliving ship $
/*==========================================================================+
 |    Copyright (c) 1997 Oracle Corporation, Redwood Shores, CA, USA        |
 |                         All rights reserved.                             |
 +==========================================================================+
 | FILENAME
 |
 |    fem_globvs_utl.plb
 |
 | NAME FEM_GLOBAL_VS_COMBO_UTIL_PKG
 |
 | DESCRIPTION
 |
 |   Package Body for the FEM Global Value Set Combo Utility Package
 |
 | HISTORY
 |
 |    16-MAY-07  RFlippo   initial creation
 |    08-JUN-07  nmartine  Update for bug 6052152 to only update ledgers with
 |                         the given Global Value Set Combo ID.  Also handles
 |                         the added GLOBAL_VS_COMBO_ID column.
 +=========================================================================*/

-----------------------
-- Package Constants --
-----------------------
c_resp_app_id CONSTANT NUMBER := FND_GLOBAL.RESP_APPL_ID;

c_user_id CONSTANT NUMBER := FND_GLOBAL.USER_ID;
c_login_id    NUMBER := FND_GLOBAL.Login_Id;

c_module_pkg   CONSTANT  VARCHAR2(80) := 'fem.plsql.fem_global_vs_combo_util_pkg';
G_PKG_NAME     CONSTANT  VARCHAR2(30) := 'FEM_GLOBAL_VS_COMBO_UTIL_PKG';

f_set_status  BOOLEAN;

c_log_level_1  CONSTANT  NUMBER  := fnd_log.level_statement;
c_log_level_2  CONSTANT  NUMBER  := fnd_log.level_procedure;
c_log_level_3  CONSTANT  NUMBER  := fnd_log.level_event;
c_log_level_4  CONSTANT  NUMBER  := fnd_log.level_exception;
c_log_level_5  CONSTANT  NUMBER  := fnd_log.level_error;
c_log_level_6  CONSTANT  NUMBER  := fnd_log.level_unexpected;

c_object_version CONSTANT NUMBER := 1;



-----------------------
-- Package Variables --
-----------------------
v_module_log   VARCHAR2(255);


v_token_value  VARCHAR2(150);
v_token_trans  VARCHAR2(1);

v_msg_text     VARCHAR2(4000);

gv_prg_msg      VARCHAR2(2000);
gv_callstack    VARCHAR2(2000);


-----------------------
-- Private Procedures --
-----------------------
PROCEDURE Validate_OA_Params (
   p_api_version     IN NUMBER,
   p_init_msg_list   IN VARCHAR2,
   p_commit          IN VARCHAR2,
   p_encoded         IN VARCHAR2,
   x_return_status   OUT NOCOPY VARCHAR2
);



/*************************************************************************

                       Create_snapshot

PURPOSE:  Creates a new empty snapshot object (Mapping helper rule) and object definition,
and registers the association to the true mapping rule in FEM_OBJDEF_HELPER_RULES.

*************************************************************************/

PROCEDURE refresh_ledger_vs_maps (
   p_global_vs_combo_id IN NUMBER,
   p_api_version         IN NUMBER     DEFAULT c_api_version,
   p_init_msg_list       IN VARCHAR2   DEFAULT c_false,
   p_commit              IN VARCHAR2   DEFAULT c_false,
   p_encoded             IN VARCHAR2   DEFAULT c_true,
   x_return_status       OUT NOCOPY VARCHAR2,
   x_msg_count           OUT NOCOPY NUMBER,
   x_msg_data            OUT NOCOPY VARCHAR2) IS

  C_MODULE            CONSTANT FND_LOG_MESSAGES.module%TYPE :=
     'fem.plsql.fem_global_vs_combo_util_pkg.refresh_ledger_vs_maps';
  C_API_NAME          CONSTANT VARCHAR2(30)  := 'Refresh Ledger Value Set Maps';

  e_unexp       EXCEPTION;
  e_error       EXCEPTION;
  e_attribute EXCEPTION;
  e_version       EXCEPTION;
  e_global  EXCEPTION;



  v_count number;
  v_attribute_id FEM_DIM_ATTRIBUTES_B.attribute_id%TYPE;
  v_version_id FEM_DIM_ATTR_VERSIONS_B.version_id%TYPE;


v_channel_vs_id fem_ledger_dim_vs_maps.CHANNEL_VS_ID%type;
v_cctr_org_vs_id fem_ledger_dim_vs_maps.COMPANY_COST_CENTER_ORG_VS_ID%type;
v_company_vs_id fem_ledger_dim_vs_maps.COMPANY_VS_ID%type;
v_cost_ctr_vs_id fem_ledger_dim_vs_maps.COST_CENTER_VS_ID%type;
v_customer_vs_id fem_ledger_dim_vs_maps.CUSTOMER_VS_ID%type;
v_entity_vs_id fem_ledger_dim_vs_maps.ENTITY_VS_ID%type;
v_fin_elem_vs_id fem_ledger_dim_vs_maps.FINANCIAL_ELEM_VS_ID%type;
v_geography_vs_id fem_ledger_dim_vs_maps.GEOGRAPHY_VS_ID%type;
v_line_item_vs_id fem_ledger_dim_vs_maps.LINE_ITEM_VS_ID%type;
v_natural_account_vs_id fem_ledger_dim_vs_maps.NATURAL_ACCOUNT_VS_ID%type;
v_product_vs_id fem_ledger_dim_vs_maps.PRODUCT_VS_ID%type;
v_project_vs_id fem_ledger_dim_vs_maps.PROJECT_VS_ID%type;
v_task_vs_id fem_ledger_dim_vs_maps.TASK_VS_ID%type;
v_user_dim1_vs_id fem_ledger_dim_vs_maps.USER_DIM1_VS_ID%type;
v_user_dim2_vs_id fem_ledger_dim_vs_maps.USER_DIM2_VS_ID%type;
v_user_dim3_vs_id fem_ledger_dim_vs_maps.USER_DIM3_VS_ID%type;
v_user_dim4_vs_id fem_ledger_dim_vs_maps.USER_DIM4_VS_ID%type;
v_user_dim5_vs_id fem_ledger_dim_vs_maps.USER_DIM5_VS_ID%type;
v_user_dim6_vs_id fem_ledger_dim_vs_maps.USER_DIM6_VS_ID%type;
v_user_dim7_vs_id fem_ledger_dim_vs_maps.USER_DIM7_VS_ID%type;
v_user_dim8_vs_id fem_ledger_dim_vs_maps.USER_DIM8_VS_ID%type;
v_user_dim9_vs_id fem_ledger_dim_vs_maps.USER_DIM9_VS_ID%type;
v_user_dim10_vs_id fem_ledger_dim_vs_maps.USER_DIM10_VS_ID%type;


  cursor c1 (p_global_vs_combo_id IN NUMBER) is
   SELECT D.dimension_varchar_label, G.value_set_id
   FROM fem_dimensions_b D, fem_global_vs_combo_defs G
   WHERE G.dimension_id = D.dimension_id
   AND G.global_vs_combo_id = p_global_vs_combo_id;

  cursor c2 (
    p_attribute_id IN NUMBER,
    p_version_id IN NUMBER,
    p_global_vs_combo_id IN NUMBER
  ) is
  select ledger_id
  from fem_ledgers_attr
  where attribute_id = p_attribute_id
  and version_id = p_version_id
  and dim_attribute_numeric_member = p_global_vs_combo_id;




BEGIN

  -- Standard Start of API savepoint
  SAVEPOINT  refresh_ledger_maps_pub;


  IF FND_LOG.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_procedure,
      p_module   => C_MODULE,
      p_msg_text => 'Begin Procedure');
  END IF;


  -- Initialize return status to unexpected error
  x_return_status := c_unexp;

  -- Check for call compatibility.
  IF NOT FND_API.Compatible_API_Call (c_api_version,
                p_api_version,
                C_API_NAME,
                G_PKG_NAME)
  THEN
    IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => FND_LOG.level_statement,
        p_module   => C_MODULE,
        p_msg_text => 'API Version ('||C_API_VERSION||') not compatible with '
                    ||'passed in version ('||p_api_version||')');
    END IF;
    RAISE e_unexp;
  END IF;


  Validate_OA_Params (
    p_api_version => p_api_version,
    p_init_msg_list => p_init_msg_list,
    p_commit => p_commit,
    p_encoded => p_encoded,
    x_return_status => x_return_status);

  IF (x_return_status <> c_success) THEN
    RAISE e_error;
  END IF;

/* Verify the global combo is valid*/
BEGIN

   SELECT 1
   INTO v_count
   FROM fem_global_vs_combos_vl
   WHERE global_vs_combo_id = p_global_vs_combo_id;

EXCEPTION
   WHEN no_data_found THEN
      RAISE e_global;

END;


/*  get the attribute_id for GLOBAL_VS_COMBO */
BEGIN
   SELECT attribute_id
   INTO v_attribute_id
   FROM fem_dim_attributes_b A, fem_dimensions_b D
   WHERE D.dimension_varchar_label = 'LEDGER'
   AND D.dimension_id = A.dimension_id
   AND A.attribute_varchar_label = 'GLOBAL_VS_COMBO';

EXCEPTION
   WHEN OTHERS THEN
      RAISE e_attribute;

END;

/*  get the default version_id for GLOBAL_VS_COMBO */
BEGIN
   SELECT version_id
   INTO v_version_id
   FROM fem_dim_attr_versions_b
   WHERE attribute_id = v_attribute_id
   AND default_version_flag = 'Y';

EXCEPTION
   WHEN OTHERS THEN
      RAISE e_version;

END;

/* Get all of the value set ids for each dimension for the global combo*/
   FOR dim IN c1 (p_global_vs_combo_id) LOOP
      CASE dim.dimension_varchar_label
         WHEN 'CHANNEL' THEN v_channel_vs_id := dim.value_set_id;
         WHEN 'COMPANY_COST_CENTER_ORG' THEN v_cctr_org_vs_id := dim.value_set_id;
         WHEN 'COMPANY' THEN v_company_vs_id := dim.value_set_id;
         WHEN 'COST_CENTER' THEN v_cost_ctr_vs_id := dim.value_set_id;
         WHEN 'CUSTOMER' THEN v_customer_vs_id := dim.value_set_id;
         WHEN 'ENTITY' THEN v_entity_vs_id := dim.value_set_id;
         WHEN 'FINANCIAL_ELEMENT' THEN v_fin_elem_vs_id := dim.value_set_id;
         WHEN 'GEOGRAPHY' THEN v_geography_vs_id := dim.value_set_id;
         WHEN 'LINE_ITEM' THEN v_line_item_vs_id := dim.value_set_id;
         WHEN 'NATURAL_ACCOUNT' THEN v_natural_account_vs_id := dim.value_set_id;
         WHEN 'PRODUCT' THEN v_product_vs_id := dim.value_set_id;
         WHEN 'PROJECT' THEN v_project_vs_id := dim.value_set_id;
         WHEN 'TASK' THEN v_task_vs_id := dim.value_set_id;
         WHEN 'USER_DIM1' THEN v_user_dim1_vs_id := dim.value_set_id;
         WHEN 'USER_DIM10' THEN v_user_dim10_vs_id := dim.value_set_id;
         WHEN 'USER_DIM2' THEN v_user_dim2_vs_id := dim.value_set_id;
         WHEN 'USER_DIM3' THEN v_user_dim3_vs_id := dim.value_set_id;
         WHEN 'USER_DIM4' THEN v_user_dim4_vs_id := dim.value_set_id;
         WHEN 'USER_DIM5' THEN v_user_dim5_vs_id := dim.value_set_id;
         WHEN 'USER_DIM6' THEN v_user_dim6_vs_id := dim.value_set_id;
         WHEN 'USER_DIM7' THEN v_user_dim7_vs_id := dim.value_set_id;
         WHEN 'USER_DIM8' THEN v_user_dim8_vs_id := dim.value_set_id;
         WHEN 'USER_DIM9' THEN v_user_dim9_vs_id := dim.value_set_id;
      END CASE;

   END LOOP;


/* for each ledger with the given global value set combo id, merge the
   value set ids into the fem_ledger_dim_vs_maps table*/
FOR ledger IN c2 (v_attribute_id, v_version_id, p_global_vs_combo_id) LOOP

      MERGE INTO fem_ledger_dim_vs_maps L
      USING (SELECT
        ledger.ledger_id as ledger_id
	             ,p_global_vs_combo_id as global_vs_combo
	             ,v_channel_vs_id as channel
	             ,v_cctr_org_vs_id as cctr
	             ,v_company_vs_id as company
	             ,v_cost_ctr_vs_id as cost_ctr
	             ,v_customer_vs_id as customer
	             ,v_entity_vs_id as entity
	             ,v_fin_elem_vs_id as fin_elem
	             ,v_geography_vs_id as geography
	             ,v_line_item_vs_id as line_item
	             ,v_natural_account_vs_id as natural_acct
	             ,v_product_vs_id as product
	             ,v_project_vs_id as project
	             ,v_task_vs_id as task
	             ,v_user_dim1_vs_id as user_dim1
	             ,v_user_dim2_vs_id as user_dim2
	             ,v_user_dim3_vs_id as user_dim3
	             ,v_user_dim4_vs_id as user_dim4
	             ,v_user_dim5_vs_id as user_dim5
	             ,v_user_dim6_vs_id as user_dim6
	             ,v_user_dim7_vs_id as user_dim7
	             ,v_user_dim8_vs_id as user_dim8
	             ,v_user_dim9_vs_id as user_dim9
	             ,v_user_dim10_vs_id as user_dim10
        FROM dual) A
       ON (A.ledger_id = L.ledger_id)
       WHEN MATCHED THEN UPDATE SET
               L.GLOBAL_VS_COMBO_ID = p_global_vs_combo_id,
               L.CHANNEL_VS_ID = v_channel_vs_id,
               L.COMPANY_COST_CENTER_ORG_VS_ID = v_cctr_org_vs_id,
	           L.COMPANY_VS_ID = v_company_vs_id,
	           L.COST_CENTER_VS_ID = v_cost_ctr_vs_id,
	           L.CUSTOMER_VS_ID = v_customer_vs_id,
	           L.ENTITY_VS_ID = v_entity_vs_id,
	           L.FINANCIAL_ELEM_VS_ID = v_fin_elem_vs_id,
	           L.GEOGRAPHY_VS_ID = v_geography_vs_id,
	           L.LINE_ITEM_VS_ID = v_line_item_vs_id,
	           L.NATURAL_ACCOUNT_VS_ID = v_natural_account_vs_id,
	           L.PRODUCT_VS_ID  = v_product_vs_id,
	           L.PROJECT_VS_ID  = v_project_vs_id,
	           L.TASK_VS_ID  = v_task_vs_id,
	           L.USER_DIM1_VS_ID = v_user_dim1_vs_id,
	           L.USER_DIM2_VS_ID = v_user_dim2_vs_id,
	           L.USER_DIM3_VS_ID = v_user_dim3_vs_id,
	           L.USER_DIM4_VS_ID = v_user_dim4_vs_id,
	           L.USER_DIM5_VS_ID = v_user_dim5_vs_id,
	           L.USER_DIM6_VS_ID = v_user_dim6_vs_id,
	           L.USER_DIM7_VS_ID = v_user_dim7_vs_id,
	           L.USER_DIM8_VS_ID = v_user_dim8_vs_id,
	           L.USER_DIM9_VS_ID = v_user_dim9_vs_id,
	           L.USER_DIM10_VS_ID= v_user_dim10_vs_id
      WHEN NOT MATCHED THEN INSERT (
      L.LEDGER_ID,
      L.GLOBAL_VS_COMBO_ID,
      L.CHANNEL_VS_ID,
      L.COMPANY_COST_CENTER_ORG_VS_ID,
      L.COMPANY_VS_ID,
      L.COST_CENTER_VS_ID,
      L.CUSTOMER_VS_ID,
      L.ENTITY_VS_ID,
      L.FINANCIAL_ELEM_VS_ID,
      L.GEOGRAPHY_VS_ID,
      L.LINE_ITEM_VS_ID,
      L.NATURAL_ACCOUNT_VS_ID,
      L.PRODUCT_VS_ID,
      L.PROJECT_VS_ID,
      L.TASK_VS_ID,
      L.USER_DIM1_VS_ID,
      L.USER_DIM2_VS_ID,
      L.USER_DIM3_VS_ID,
      L.USER_DIM4_VS_ID,
      L.USER_DIM5_VS_ID,
      L.USER_DIM6_VS_ID,
      L.USER_DIM7_VS_ID,
      L.USER_DIM8_VS_ID,
      L.USER_DIM9_VS_ID,
      L.USER_DIM10_VS_ID
      )
      VALUES    (ledger.ledger_id
                 ,p_global_vs_combo_id
                 ,v_channel_vs_id
                 ,v_cctr_org_vs_id
                 ,v_company_vs_id
                 ,v_cost_ctr_vs_id
                 ,v_customer_vs_id
                 ,v_entity_vs_id
                 ,v_fin_elem_vs_id
                 ,v_geography_vs_id
                 ,v_line_item_vs_id
                 ,v_natural_account_vs_id
                 ,v_product_vs_id
                 ,v_project_vs_id
                 ,v_task_vs_id
                 ,v_user_dim1_vs_id
                 ,v_user_dim2_vs_id
                 ,v_user_dim3_vs_id
                 ,v_user_dim4_vs_id
                 ,v_user_dim5_vs_id
                 ,v_user_dim6_vs_id
                 ,v_user_dim7_vs_id
                 ,v_user_dim8_vs_id
                 ,v_user_dim9_vs_id
                 ,v_user_dim10_vs_id
 );




END LOOP;


x_return_status := c_success;

  IF FND_LOG.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_procedure,
      p_module   => C_MODULE,
      p_msg_text => 'End Procedure');
  END IF;

IF FND_API.To_Boolean( p_commit ) THEN
   COMMIT WORK;
END IF;


EXCEPTION
 WHEN e_global THEN
    IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => FND_LOG.level_statement,
        p_module   => C_MODULE,
        p_msg_text => 'Global Value Set Combo ID does not exist '||p_global_vs_combo_id);
    END IF;
    FND_MSG_PUB.Count_And_Get(p_encoded => p_encoded,
                              p_count => x_msg_count,
                              p_data => x_msg_data);
    ROLLBACK TO refresh_ledger_maps_pub;
    x_return_status := c_error;

 WHEN e_attribute THEN
    IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => FND_LOG.level_statement,
        p_module   => C_MODULE,
        p_msg_text => 'GLOBAL_VS_COMBO attribute metadata does not exist or is not valid');
    END IF;
    FND_MSG_PUB.Count_And_Get(p_encoded => p_encoded,
                              p_count => x_msg_count,
                              p_data => x_msg_data);
    ROLLBACK TO refresh_ledger_maps_pub;
    x_return_status := c_error;

 WHEN e_version THEN
    IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => FND_LOG.level_statement,
        p_module   => C_MODULE,
        p_msg_text => 'GLOBAL_VS_COMBO attribute version metadata does not exist or is not valid');
    END IF;
    FND_MSG_PUB.Count_And_Get(p_encoded => p_encoded,
                              p_count => x_msg_count,
                              p_data => x_msg_data);
    ROLLBACK TO refresh_ledger_maps_pub;
    x_return_status := c_error;


 WHEN others THEN
    IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => FND_LOG.level_statement,
        p_module   => C_MODULE,
        p_msg_text => 'Unexpected error.');
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => FND_LOG.level_statement,
        p_module   => C_MODULE,
        p_msg_text => SQLERRM);
    END IF;
    FND_MSG_PUB.Count_And_Get(p_encoded => p_encoded,
                              p_count => x_msg_count,
                              p_data => x_msg_data);
    ROLLBACK TO refresh_ledger_maps_pub;
    x_return_status := c_unexp;


END refresh_ledger_vs_maps;


/*************************************************************************

                         OA Exception Handler

*************************************************************************/

PROCEDURE Validate_OA_Params (
   p_api_version     IN NUMBER,
   p_init_msg_list   IN VARCHAR2,
   p_commit          IN VARCHAR2,
   p_encoded         IN VARCHAR2,
   x_return_status   OUT NOCOPY VARCHAR2
)
IS
   e_bad_p_api_ver         EXCEPTION;
   e_bad_p_init_msg_list   EXCEPTION;
   e_bad_p_commit          EXCEPTION;
   e_bad_p_encoded         EXCEPTION;
BEGIN

x_return_status := c_success;

CASE p_api_version
   WHEN c_api_version THEN NULL;
   ELSE RAISE e_bad_p_api_ver;
END CASE;

CASE p_init_msg_list
   WHEN c_false THEN NULL;
   WHEN c_true THEN
      FND_MSG_PUB.Initialize;
   ELSE RAISE e_bad_p_init_msg_list;
END CASE;

CASE p_encoded
   WHEN c_false THEN NULL;
   WHEN c_true THEN NULL;
   ELSE RAISE e_bad_p_encoded;
END CASE;

CASE p_commit
   WHEN c_false THEN NULL;
   WHEN c_true THEN NULL;
   ELSE RAISE e_bad_p_commit;
END CASE;

EXCEPTION
   WHEN e_bad_p_api_ver THEN
      FEM_ENGINES_PKG.Put_Message(
         p_app_name => 'FEM',
         p_msg_name => 'FEM_BAD_P_API_VER_ERR',
         p_token1 => 'VALUE',
         p_value1 => p_api_version);
      x_return_status := c_error;

   WHEN e_bad_p_init_msg_list THEN
      FEM_ENGINES_PKG.Put_Message(
         p_app_name => 'FEM',
         p_msg_name => 'FEM_BAD_P_INIT_MSG_LIST_ERR');
      x_return_status := c_error;

   WHEN e_bad_p_encoded THEN
      FEM_ENGINES_PKG.Put_Message(
         p_app_name => 'FEM',
         p_msg_name => 'FEM_BAD_P_ENCODED_ERR');
      x_return_status := c_error;

   WHEN e_bad_p_commit THEN
      FEM_ENGINES_PKG.Put_Message(
         p_app_name => 'FEM',
         p_msg_name => 'FEM_BAD_P_COMMIT_ERR');
      x_return_status := c_error;

END Validate_OA_Params;



END FEM_GLOBAL_VS_COMBO_UTIL_PKG;

/
