--------------------------------------------------------
--  DDL for Package FEM_COL_TMPLT_DEFN_API_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FEM_COL_TMPLT_DEFN_API_PUB" AUTHID CURRENT_USER AS
/* $Header: FEMCOLTMPLTS.pls 120.2 2006/06/01 13:40:27 ssthiaga noship $ */

    -------------------------------
    -- Declare package constants --
    -------------------------------

     g_object_version_number      CONSTANT NUMBER 	   := 1;
     g_block                      CONSTANT VARCHAR2(30) := 'FEM_COL_TMPLT_DEFN_API_PUB';
     g_pkg_name		          CONSTANT VARCHAR2(30) := 'FEM_COL_TMPLT_DEFN_API_PUB';
     g_object_type_code           CONSTANT VARCHAR2(30) := 'PPROF_COL_POP_TMPLT';

     g_log_level_1                CONSTANT  NUMBER      := fnd_log.level_statement;
     g_log_level_2                CONSTANT  NUMBER      := fnd_log.level_procedure;
     g_log_level_3                CONSTANT  NUMBER      := fnd_log.level_event;
     g_log_level_4                CONSTANT  NUMBER      := fnd_log.level_exception;
     g_log_level_5                CONSTANT  NUMBER      := fnd_log.level_error;
     g_log_level_6                CONSTANT  NUMBER      := fnd_log.level_unexpected;


     c_false                      CONSTANT  VARCHAR2(1)  := FND_API.G_FALSE;
     c_true                       CONSTANT  VARCHAR2(1)  := FND_API.G_TRUE;
     c_success                    CONSTANT  VARCHAR2(1)  := FND_API.G_RET_STS_SUCCESS;
     c_error                      CONSTANT  VARCHAR2(1)  := FND_API.G_RET_STS_ERROR;
     c_unexp                      CONSTANT  VARCHAR2(1)  := FND_API.G_RET_STS_UNEXP_ERROR;
     c_api_version                CONSTANT  NUMBER       := 1.0;

     G_CONDITION_PREDICATE_ERR    CONSTANT  VARCHAR2(30) := 'FEM_COL_POP_COND_PRED_ERR';
     G_DS_WHERE_PREDICATE_ERR     CONSTANT  VARCHAR2(30) := 'FEM_COL_POP_DS_WHERE_CLAS_ERR';
     G_NO_ATTR_VALUE_ERR          CONSTANT  VARCHAR2(30) := 'FEM_COL_POP_ENG_NO_ATT_VAL_ERR';
     G_NO_ATTR_VER_ERR            CONSTANT  VARCHAR2(30) := 'FEM_COL_POP_ENG_NO_ATT_VER_ERR';
     G_GENERATE_PREDICATES_ERR    CONSTANT  VARCHAR2(30) := 'FEM_COL_POP_GEN_PRED_ERR';
     G_GENERATE_WHERE_CLAUSE_ERR  CONSTANT  VARCHAR2(30) := 'FEM_COL_POP_GEN_WHERE_CLAS_ERR';
     G_INVALID_DATASET_GRP_ERR    CONSTANT  VARCHAR2(30) := 'FEM_COL_POP_INV_DSG_ERR';
     G_INVALID_ACCT_OWNER_ID_ERR  CONSTANT  VARCHAR2(30) := 'FEM_COL_POP_NO_ACCT_OWNER_ID';
     G_NO_EXCHG_RATE_ERR          CONSTANT  VARCHAR2(30) := 'FEM_COL_POP_NO_EXCHG_RATE';
     G_INV_EXCHG_RATE_TYPE_ERR    CONSTANT  VARCHAR2(30) := 'FEM_COL_POP_NO_EXCHG_RATE_TYPE';
     G_NO_FUNCTIONAL_CURR_ERR     CONSTANT  VARCHAR2(30) := 'FEM_COL_POP_NO_FUNC_CURR';

     g_src_tab_name               VARCHAR2(30);
     g_src_alias                  VARCHAR2(10);

     g_tgt_tab_name               VARCHAR2(30);
     g_tgt_alias                  VARCHAR2(10);

     g_sec_alias                  VARCHAR2(10);

     g_table_id                   NUMBER;

     g_curr_conv_type             VARCHAR2(30);
     g_func_curr_code             VARCHAR2(30);
     g_exch_rate_date             DATE;

     -- Object def ID

     g_object_id                  NUMBER;
     g_obj_def_id                 NUMBER;
     g_effective_date             DATE;

     g_col_pop_seed_del           BOOLEAN := FALSE;


    TYPE attr_list_rec IS RECORD
    (
      attribute_tab_name   VARCHAR2(30),
      attribute_tab_count  NUMBER
    );

    TYPE attr_list_arr IS TABLE OF attr_list_rec INDEX BY BINARY_INTEGER;

    -- attr_detail_rec  attr_list_arr;

    FUNCTION get_alias(p_tab_name IN VARCHAR2, p_alias IN VARCHAR2) RETURN VARCHAR2;

    PROCEDURE get_alias(p_attr_detail_rec IN  OUT NOCOPY attr_list_arr,
                        p_tab_name        IN  VARCHAR2,
                        p_alias           OUT NOCOPY VARCHAR2);

    FUNCTION get_param_value(p_column_name IN VARCHAR2,
                             p_param_val IN VARCHAR2) RETURN VARCHAR2 ;

    PROCEDURE get_from_where_clause(p_api_version     	 IN NUMBER,
                                    p_init_msg_list          IN VARCHAR2,
                                    p_commit                 IN VARCHAR2,
                                    p_encoded                IN VARCHAR2,
                                    p_object_def_id          IN NUMBER,
                                    p_load_sec_relns         IN BOOLEAN,
                                    p_dataset_grp_obj_def_id IN NUMBER,
                                    p_cal_period_id          IN NUMBER,
                                    p_ledger_id              IN NUMBER,
                                    p_source_system_code     IN NUMBER,
                                    p_created_by_object_id   IN NUMBER,
                                    p_created_by_request_id  IN NUMBER,
                                    p_insert_list            OUT NOCOPY LONG,
                                    p_select_list            OUT NOCOPY LONG,
                                    p_from_clause            OUT NOCOPY LONG,
                                    p_where_clause           OUT NOCOPY LONG,
                                    x_msg_count              OUT NOCOPY NUMBER,
                                    x_msg_data               OUT NOCOPY VARCHAR2,
                                    x_return_status          OUT NOCOPY VARCHAR2);

    FUNCTION is_aggregation_Present(p_object_def_id IN NUMBER) RETURN BOOLEAN;

    PROCEDURE generate_predicates(p_api_version            IN NUMBER,
                                  p_init_msg_list          IN VARCHAR2,
                                  p_commit                 IN VARCHAR2,
                                  p_encoded                IN VARCHAR2,
                                  p_object_def_id          IN NUMBER,
                                  p_selection_param        IN NUMBER,
                                  p_effective_date         IN VARCHAR2,
                                  p_condition_obj_id       IN NUMBER,
                                  p_condition_sel_param    IN VARCHAR2,
                                  p_load_sec_relns         IN VARCHAR2,
                                  p_dataset_grp_obj_def_id IN NUMBER,
                                  p_cal_period_id          IN NUMBER,
                                  p_ledger_id              IN NUMBER,
                                  p_source_system_code     IN NUMBER,
                                  p_created_by_object_id   IN NUMBER,
                                  p_created_by_request_id  IN NUMBER,
                                  p_insert_list            OUT NOCOPY LONG,
                                  p_select_list            OUT NOCOPY LONG,
                                  p_from_clause            OUT NOCOPY LONG,
                                  p_where_clause           OUT NOCOPY LONG,
                                  p_con_where_clause       OUT NOCOPY LONG,
                                  x_msg_count              OUT NOCOPY NUMBER,
                                  x_msg_data               OUT NOCOPY VARCHAR2,
                                  x_return_status          OUT NOCOPY VARCHAR2);


END Fem_Col_Tmplt_Defn_Api_Pub;
 

/
