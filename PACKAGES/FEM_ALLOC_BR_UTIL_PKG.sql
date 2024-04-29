--------------------------------------------------------
--  DDL for Package FEM_ALLOC_BR_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FEM_ALLOC_BR_UTIL_PKG" AUTHID CURRENT_USER as
--$Header: fem_alloc_br_utl.pls 120.7 2008/02/20 06:53:51 jcliving noship $

c_false            CONSTANT  VARCHAR2(1)  := FND_API.G_FALSE;
c_true             CONSTANT  VARCHAR2(1)  := FND_API.G_TRUE;
c_success          CONSTANT  VARCHAR2(1)  := FND_API.G_RET_STS_SUCCESS;
c_error            CONSTANT  VARCHAR2(1)  := FND_API.G_RET_STS_ERROR;
c_unexp            CONSTANT  VARCHAR2(1)  := FND_API.G_RET_STS_UNEXP_ERROR;
c_api_version      CONSTANT  NUMBER       := 1.0;


PROCEDURE create_snapshot (
   p_map_rule_obj_def_id IN NUMBER,
   p_snapshot_obj_type_code IN VARCHAR2 DEFAULT 'MAPPING_EDIT_SNAPSHOT',
   p_api_version         IN NUMBER     DEFAULT c_api_version,
   p_init_msg_list       IN VARCHAR2   DEFAULT c_false,
   p_commit              IN VARCHAR2   DEFAULT c_false,
   p_encoded             IN VARCHAR2   DEFAULT c_true,
   x_snapshot_object_id  OUT NOCOPY NUMBER,
   x_snapshot_objdef_id  OUT NOCOPY NUMBER,
   x_return_status       OUT NOCOPY VARCHAR2,
   x_msg_count           OUT NOCOPY NUMBER,
   x_msg_data            OUT NOCOPY VARCHAR2);

PROCEDURE refresh_maprule_from_snapshot (
   p_map_rule_obj_def_id IN NUMBER,
   p_api_version         IN NUMBER     DEFAULT c_api_version,
   p_init_msg_list       IN VARCHAR2   DEFAULT c_false,
   p_commit              IN VARCHAR2   DEFAULT c_false,
   p_encoded             IN VARCHAR2   DEFAULT c_true,
   x_snapshot_objdef_id  OUT NOCOPY NUMBER,
   x_return_status       OUT NOCOPY VARCHAR2,
   x_msg_count           OUT NOCOPY NUMBER,
   x_msg_data            OUT NOCOPY VARCHAR2);

PROCEDURE refresh_snapshot_from_maprule (
   p_map_rule_obj_def_id IN NUMBER,
   p_api_version         IN NUMBER     DEFAULT c_api_version,
   p_init_msg_list       IN VARCHAR2   DEFAULT c_false,
   p_commit              IN VARCHAR2   DEFAULT c_false,
   p_encoded             IN VARCHAR2   DEFAULT c_true,
   x_snapshot_objdef_id  OUT NOCOPY NUMBER,
   x_return_status       OUT NOCOPY VARCHAR2,
   x_msg_count           OUT NOCOPY NUMBER,
   x_msg_data            OUT NOCOPY VARCHAR2);

PROCEDURE refresh_snapshot_from_defaults (
   p_map_rule_obj_def_id IN NUMBER,
   p_api_version         IN NUMBER     DEFAULT c_api_version,
   p_init_msg_list       IN VARCHAR2   DEFAULT c_false,
   p_commit              IN VARCHAR2   DEFAULT c_false,
   p_encoded             IN VARCHAR2   DEFAULT c_true,
   x_snapshot_objdef_id  OUT NOCOPY NUMBER,
   x_return_status       OUT NOCOPY VARCHAR2,
   x_msg_count           OUT NOCOPY NUMBER,
   x_msg_data            OUT NOCOPY VARCHAR2);

PROCEDURE create_new_ver_from_defaults (
   p_map_rule_obj_id	 IN NUMBER,
   p_api_version         IN NUMBER     DEFAULT c_api_version,
   p_init_msg_list       IN VARCHAR2   DEFAULT c_false,
   p_commit              IN VARCHAR2   DEFAULT c_false,
   p_encoded             IN VARCHAR2   DEFAULT c_true,
   x_map_rule_objdef_id	 OUT NOCOPY NUMBER,
   x_snapshot_objdef_id  OUT NOCOPY NUMBER,
   x_return_status       OUT NOCOPY VARCHAR2,
   x_msg_count           OUT NOCOPY NUMBER,
   x_msg_data            OUT NOCOPY VARCHAR2);

PROCEDURE generate_condition_summary (
   p_condition_object_id IN NUMBER,
   p_api_version         IN NUMBER     DEFAULT c_api_version,
   p_init_msg_list       IN VARCHAR2   DEFAULT c_false,
   p_commit              IN VARCHAR2   DEFAULT c_false,
   p_encoded             IN VARCHAR2   DEFAULT c_true,
   x_return_status       OUT NOCOPY VARCHAR2,
   x_msg_count           OUT NOCOPY NUMBER,
   x_msg_data            OUT NOCOPY VARCHAR2);

PROCEDURE get_default_definition (
   p_map_rule_type_code  IN VARCHAR2,
   p_target_folder_id    IN VARCHAR2   DEFAULT NULL,
   p_api_version         IN NUMBER     DEFAULT c_api_version,
   p_init_msg_list       IN VARCHAR2   DEFAULT c_false,
   p_commit              IN VARCHAR2   DEFAULT c_false,
   p_encoded             IN VARCHAR2   DEFAULT c_true,
   x_dflt_objdef_id      OUT NOCOPY NUMBER,
   x_return_status       OUT NOCOPY VARCHAR2,
   x_msg_count           OUT NOCOPY NUMBER,
   x_msg_data            OUT NOCOPY VARCHAR2);

PROCEDURE generate_fctr_summary (
    p_fctr_object_id IN NUMBER,
    p_api_version         IN NUMBER     DEFAULT c_api_version,
    p_init_msg_list       IN VARCHAR2   DEFAULT c_false,
    p_commit              IN VARCHAR2   DEFAULT c_false,
    p_encoded             IN VARCHAR2   DEFAULT c_true,
    x_return_status       OUT NOCOPY VARCHAR2,
    x_msg_count           OUT NOCOPY NUMBER,
    x_msg_data            OUT NOCOPY VARCHAR2);

FUNCTION get_rule_dirty_flag (p_map_rule_obj_def_id IN NUMBER) RETURN VARCHAR2;

FUNCTION defaults_exist(p_map_rule_type_code IN VARCHAR2) RETURN VARCHAR2;



END fem_alloc_br_util_pkg;

/
