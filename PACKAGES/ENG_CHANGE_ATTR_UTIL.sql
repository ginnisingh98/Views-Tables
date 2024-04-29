--------------------------------------------------------
--  DDL for Package ENG_CHANGE_ATTR_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ENG_CHANGE_ATTR_UTIL" AUTHID CURRENT_USER AS
/* $Header: ENGVCAUS.pls 120.13 2007/05/10 16:38:43 asjohal ship $ */


   G_ATTR_NULL_CHAR          CONSTANT  VARCHAR2(1)  := '!';
   G_ATTR_NULL_NUM           CONSTANT  NUMBER       := -999;
   G_ATTR_NULL_DATE          CONSTANT  DATE         := FND_API.G_MISS_DATE ;
   G_EXEC_MODE_IMPORT        CONSTANT  VARCHAR2(10) := 'IMPORT';


PROCEDURE INSERT_ITEM_ATTRS
(
   p_api_version                IN NUMBER
  ,p_object_name                IN VARCHAR2
  ,p_application_id             IN NUMBER
  ,p_attr_group_type            IN VARCHAR2
  ,p_base_attr_names_values     IN EGO_USER_ATTR_DATA_TABLE
  ,p_tl_attr_names_values       IN EGO_USER_ATTR_DATA_TABLE
  ,x_return_status              OUT NOCOPY VARCHAR2
  ,x_errorcode                  OUT NOCOPY NUMBER
  ,x_msg_count                  OUT NOCOPY NUMBER
  ,x_msg_data                   OUT NOCOPY VARCHAR2
  ,p_exec_mode                  IN VARCHAR2
);

PROCEDURE UPDATE_ITEM_ATTRS
(  p_api_version               IN NUMBER
  ,p_object_name               IN VARCHAR2
  ,p_application_id            IN NUMBER
  ,p_attr_group_type           IN VARCHAR2
  ,p_base_attr_names_values    IN EGO_USER_ATTR_DATA_TABLE
  ,p_tl_attr_names_values      IN EGO_USER_ATTR_DATA_TABLE
  ,p_pk_attr_names_values      IN EGO_USER_ATTR_DATA_TABLE
  ,x_return_status             OUT NOCOPY  VARCHAR2
  ,x_errorcode                 OUT NOCOPY  NUMBER
  ,x_msg_count                 OUT NOCOPY  NUMBER
  ,x_msg_data                  OUT NOCOPY  VARCHAR2
  ,p_exec_mode                  IN VARCHAR2
);

PROCEDURE DELETE_ITEM_ATTRS
(  p_api_version               IN NUMBER
  ,p_object_name               IN VARCHAR2
  ,p_application_id            IN NUMBER
  ,p_attr_group_type           IN VARCHAR2
  ,p_pk_attr_names_values      IN EGO_USER_ATTR_DATA_TABLE
  ,x_return_status             OUT NOCOPY  VARCHAR2
  ,x_errorcode                 OUT NOCOPY  NUMBER
  ,x_msg_count                 OUT NOCOPY  NUMBER
  ,x_msg_data                  OUT NOCOPY  VARCHAR2
);


PROCEDURE INSERT_ITEM_USER_ATTRS
(
   p_api_version                       IN NUMBER
  ,p_object_name                       IN VARCHAR2
  ,p_attr_group_id                     IN NUMBER
  ,p_application_id                    IN NUMBER
  ,p_attr_group_type                   IN VARCHAR2
  ,p_attr_group_name                   IN VARCHAR2
  ,p_pk_column_name_value_pairs        IN EGO_COL_NAME_VALUE_PAIR_ARRAY
  ,p_class_code_name_value_pairs       IN EGO_COL_NAME_VALUE_PAIR_ARRAY
  ,P_DATA_LEVEL_NAME                   IN VARCHAR2
  ,p_data_level_name_value_pairs       IN EGO_COL_NAME_VALUE_PAIR_ARRAY :=null
  ,p_attr_name_value_pairs             IN EGO_USER_ATTR_DATA_TABLE
  ,p_mode                              IN VARCHAR2
  ,p_extra_pk_col_name_val_pairs       IN EGO_COL_NAME_VALUE_PAIR_ARRAY
  ,p_extension_id                      IN NUMBER
  ,p_pending_b_table_name              IN VARCHAR2
  ,p_pending_tl_table_name             IN VARCHAR2
  ,p_pending_vl_name                   IN VARCHAR2
  ,p_acd_type                          IN VARCHAR2
  ,p_dml_attr_name_value_pairs         IN EGO_USER_ATTR_DATA_TABLE
  ,p_api_caller                        IN VARCHAR2
  ,p_key_attr_upd                      IN VARCHAR2
  ,x_return_status                     OUT NOCOPY VARCHAR2
  ,x_errorcode                         OUT NOCOPY NUMBER
  ,x_msg_count                         OUT NOCOPY NUMBER
  ,x_msg_data                          OUT NOCOPY VARCHAR2
);

PROCEDURE VALIDATE_USER_ATTRS
(
   p_api_version                   IN  NUMBER
  ,p_object_name                   IN  VARCHAR2
  ,p_attr_group_id                 IN  NUMBER
  ,p_attr_group_type               IN  VARCHAR2
  ,p_application_id                IN  NUMBER
  ,p_attr_group_name               IN  VARCHAR2
  ,p_attributes_data_table         IN  EGO_USER_ATTR_DATA_TABLE
  ,p_extension_id                  IN NUMBER
  ,p_pk_column_name_value_pairs    IN  EGO_COL_NAME_VALUE_PAIR_ARRAY
  ,p_class_code_name_value_pairs   IN  EGO_COL_NAME_VALUE_PAIR_ARRAY
  ,p_extra_pk_col_name_val_pairs   IN  EGO_COL_NAME_VALUE_PAIR_ARRAY DEFAULT NULL
  ,p_extra_attr_name_value_pairs   IN  EGO_COL_NAME_VALUE_PAIR_ARRAY DEFAULT NULL
  ,p_alternate_ext_b_table_name    IN  VARCHAR2   DEFAULT NULL
  ,p_alternate_ext_tl_table_name   IN  VARCHAR2   DEFAULT NULL
  ,p_alternate_ext_vl_name         IN  VARCHAR2   DEFAULT NULL
  ,p_user_privileges_on_object     IN  EGO_VARCHAR_TBL_TYPE DEFAULT NULL
  ,p_row_identifier                IN  NUMBER DEFAULT NULL
  ,p_validate_only                 IN  VARCHAR2
  ,p_mode                          IN VARCHAR2
  ,p_acd_type                      IN VARCHAR2
  ,p_init_fnd_msg_list             IN VARCHAR2
  ,p_add_errors_to_fnd_stack       IN VARCHAR2
  ,x_return_status                 OUT NOCOPY VARCHAR2
  ,x_errorcode                     OUT NOCOPY NUMBER
  ,x_msg_count                     OUT NOCOPY NUMBER
  ,x_msg_data                      OUT NOCOPY VARCHAR2
  ,p_key_attr_upd                  IN VARCHAR2
  ,p_data_level_name               IN  VARCHAR2
  ,p_data_level_name_value_pairs   IN  EGO_COL_NAME_VALUE_PAIR_ARRAY DEFAULT NULL
);

PROCEDURE SETUP_IMPL_ATTR_DATA_ROW
(
   p_api_version                       IN NUMBER
  ,p_object_name                       IN VARCHAR2
  ,p_attr_group_id                     IN NUMBER
  ,p_application_id                    IN NUMBER
  ,p_attr_group_type                   IN VARCHAR2
  ,p_attr_group_name                   IN VARCHAR2
  ,p_pk_column_name_value_pairs        IN EGO_COL_NAME_VALUE_PAIR_ARRAY
  ,p_class_code_name_value_pairs       IN EGO_COL_NAME_VALUE_PAIR_ARRAY
  ,p_data_level_name                   IN VARCHAR2
  ,p_data_level_name_value_pairs       IN EGO_COL_NAME_VALUE_PAIR_ARRAY
  ,p_attr_name_value_pairs             IN EGO_USER_ATTR_DATA_TABLE DEFAULT NULL
  ,x_setup_attr_data                   OUT NOCOPY EGO_USER_ATTR_DATA_TABLE
  ,x_return_status                     OUT NOCOPY VARCHAR2
  ,x_errorcode                         OUT NOCOPY NUMBER
  ,x_msg_count                         OUT NOCOPY NUMBER
  ,x_msg_data                          OUT NOCOPY VARCHAR2
);

PROCEDURE VALIDATE_GDSN_RECORDS(p_inventory_item_id IN NUMBER
                                ,p_organization_id IN NUMBER
                                ,p_attr_group_type  IN VARCHAR2
                                ,p_attr_name_value_pairs IN EGO_USER_ATTR_DATA_TABLE
                                ,p_tl_attr_names_values  IN EGO_USER_ATTR_DATA_TABLE
                                ,x_return_status              OUT NOCOPY  VARCHAR2
                                ,x_msg_count                  OUT NOCOPY  NUMBER
                                ,x_msg_data                   OUT NOCOPY  VARCHAR2

);

PROCEDURE UPDATE_DATA_LEVEL(P_PK_ATTR_NAME_VALUE_PAIRS      EGO_COL_NAME_VALUE_PAIR_ARRAY
                            ,P_NEW_DL_NAME_VALUE_PAIRS      EGO_COL_NAME_VALUE_PAIR_ARRAY
                            ,P_OLD_DL_NAME_VALUE_PAIRS      EGO_COL_NAME_VALUE_PAIR_ARRAY
                            ,P_OBJECT_NAME                  VARCHAR2
                            ,P_APPLICATION_ID               NUMBER);


PROCEDURE getValue(p_attrs_data_tbl IN EGO_USER_ATTR_DATA_TABLE
                   ,x_rec_column     OUT NOCOPY VARCHAR2
                   ,p_attr_name      IN VARCHAR2);

PROCEDURE getValue(p_attrs_data_tbl IN EGO_USER_ATTR_DATA_TABLE
                   ,x_rec_column     OUT NOCOPY NUMBER
                   ,p_attr_name      IN VARCHAR2);

PROCEDURE getValue(p_attrs_data_tbl IN EGO_USER_ATTR_DATA_TABLE
                   ,x_rec_column     OUT NOCOPY DATE
                   ,p_attr_name      IN VARCHAR2);


PROCEDURE GET_ATTR_GRP_VO_DEF
(
   p_change_attr_group_type             IN      VARCHAR2
  ,p_object_name                        IN      VARCHAR2
  ,p_application_short_name             IN      VARCHAR2
  ,x_vo_def                             OUT NOCOPY      VARCHAR2
);

PROCEDURE GET_ATTR_GRP_VO_INSTANCE
(
 p_change_attr_group_type               IN      VARCHAR2
,p_object_name                          IN      VARCHAR2
,p_application_short_name               IN      VARCHAR2
,x_vo_instance                          OUT NOCOPY      VARCHAR2
);

PROCEDURE GET_ATTR_GRP_VO_ROW_CLASS
(
 p_change_attr_group_type               IN      VARCHAR2
,p_object_name                          IN      VARCHAR2
,p_application_short_name               IN      VARCHAR2
,x_vo_row_class                         OUT NOCOPY      VARCHAR2
);

PROCEDURE GET_ATTR_GRP_EO_DEF
(
 p_change_attr_group_type               IN      VARCHAR2
,p_object_name                          IN      VARCHAR2
,p_application_short_name               IN      VARCHAR2
,x_eo_def                               OUT NOCOPY      VARCHAR2
);

PROCEDURE GET_ATTR_GRP_BASE_TABLE
(
 p_change_attr_group_type               IN      VARCHAR2
,p_object_name                          IN      VARCHAR2
,p_application_short_name               IN      VARCHAR2
,x_base_table                           OUT NOCOPY      VARCHAR2
);

PROCEDURE GET_ATTR_GRP_TL_TABLE
(
 p_change_attr_group_type               IN      VARCHAR2
,p_object_name                          IN      VARCHAR2
,p_application_short_name               IN      VARCHAR2
,x_tl_table                             OUT NOCOPY      VARCHAR2
);

PROCEDURE GET_ATTR_GRP_VL_NAME
(
 p_change_attr_group_type               IN      VARCHAR2
,p_object_name                          IN      VARCHAR2
,p_application_short_name               IN      VARCHAR2
,x_vl_name                              OUT NOCOPY      VARCHAR2
);

PROCEDURE GET_CONTEXT_VALUE
(
 p_change_attr_group_type               IN      VARCHAR2
,p_object_name                          IN      VARCHAR2
,p_application_short_name               IN      VARCHAR2
,p_context_type                         IN      VARCHAR2
,x_context_value                        OUT NOCOPY      VARCHAR2
);

PROCEDURE DEL_PEND_ATTR_CHGS
(
 P_MODE IN VARCHAR2
,P_CHANGE_ID IN NUMBER
,P_CHANGE_LINE_ID IN NUMBER
,P_ORG_ID IN NUMBER
,P_DATA_LEVEL_NAME IN VARCHAR2
,P_DATA_LEVEL_NAME_VALUE_PAIRS IN  EGO_COL_NAME_VALUE_PAIR_ARRAY DEFAULT NULL
);

PROCEDURE SAVE_ITEM_NUM_DESC( p_change_id        IN   NUMBER
, p_change_line_id   IN   number
, p_organization_id  IN   NUMBER
, p_item_id          IN   NUMBER
, p_item_num         IN   VARCHAR2 DEFAULT NULL
, p_item_desc        IN   VARCHAR2 DEFAULT NULL
,p_transaction_mode IN    VARCHAR2
, x_return_status   OUT  NOCOPY VARCHAR2
);

END ENG_CHANGE_ATTR_UTIL;

/
