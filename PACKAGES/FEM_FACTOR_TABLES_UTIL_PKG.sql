--------------------------------------------------------
--  DDL for Package FEM_FACTOR_TABLES_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FEM_FACTOR_TABLES_UTIL_PKG" AUTHID CURRENT_USER AS
/* $Header: FEMFACTTABS.pls 120.1 2008/02/20 06:46:25 jcliving noship $ */

   g_log_level_1     CONSTANT  NUMBER      := fnd_log.level_statement;
   g_log_level_2     CONSTANT  NUMBER      := fnd_log.level_procedure;
   g_log_level_3     CONSTANT  NUMBER      := fnd_log.level_event;
   g_log_level_4     CONSTANT  NUMBER      := fnd_log.level_exception;
   g_log_level_5     CONSTANT  NUMBER      := fnd_log.level_error;
   g_log_level_6     CONSTANT  NUMBER      := fnd_log.level_unexpected;
   g_block         CONSTANT VARCHAR2(30) := 'FEM_FACTOR_TABLE_UTIL_PKG';

   c_false           CONSTANT  VARCHAR2(1) := FND_API.G_FALSE;
   c_true            CONSTANT  VARCHAR2(1) := FND_API.G_TRUE;
   c_success         CONSTANT  VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
   c_error           CONSTANT  VARCHAR2(1) := FND_API.G_RET_STS_ERROR;
   c_unexp           CONSTANT  VARCHAR2(1) := FND_API.G_RET_STS_UNEXP_ERROR;
   c_api_version     CONSTANT  NUMBER      := 1.0;



   FUNCTION is_matching_dimension_leaf (p_object_definition_id IN NUMBER,
                                        p_level_num IN NUMBER) RETURN VARCHAR2;

   PROCEDURE delete_member (p_object_definition_id IN NUMBER,
                            p_row_num IN NUMBER);

   PROCEDURE CopyObjectDefinition (p_source_obj_def_id  IN NUMBER,
                                   p_target_obj_def_id  IN NUMBER,
                                   p_created_by         IN NUMBER,
                                   p_creation_date      IN DATE );


   PROCEDURE DeleteObjectDefinition ( p_obj_def_id  IN NUMBER );

   PROCEDURE VALIDATE_HIERARCHY (x_valid_flag OUT NOCOPY VARCHAR2,p_hier_obj_id IN NUMBER,p_dimension_id IN NUMBER);

   PROCEDURE VALIDATE_GROUP (x_valid_flag OUT NOCOPY VARCHAR2,p_hier_obj_id IN NUMBER,p_group_id IN NUMBER);

   PROCEDURE VALIDATE_DIM_MEMBER(x_valid_flag OUT NOCOPY VARCHAR2,p_hier_object_id IN NUMBER,p_group_id IN NUMBER,p_dimension_id IN NUMBER,p_member_id IN NUMBER);

   PROCEDURE GET_HIER_OBJ_DEF_ID(x_hier_obj_def_id OUT NOCOPY VARCHAR2,p_hier_obj_id IN VARCHAR2,p_hier_name IN VARCHAR2);

END fem_factor_tables_util_pkg;

/
