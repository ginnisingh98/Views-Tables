--------------------------------------------------------
--  DDL for Package EGO_COM_ATTR_VALIDATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EGO_COM_ATTR_VALIDATION" AUTHID CURRENT_USER AS
/* $Header: EGOCOMVS.pls 120.0.12010000.3 2009/04/10 23:23:54 mshirkol noship $ */

PROCEDURE Validate_Attributes(
	p_attr_group_type             IN VARCHAR2
       ,p_attr_group_name             IN VARCHAR2
       ,p_attr_group_id               IN NUMBER
       ,p_attr_name_value_pairs       IN ego_user_attr_data_table
       ,p_pk_column_name_value_pairs  IN ego_col_name_value_pair_array DEFAULT NULL
       ,x_return_status               OUT NOCOPY VARCHAR2
       ,x_error_messages              OUT NOCOPY ego_col_name_value_pair_array
       );

FUNCTION Get_Attr_Value_From_db(
        p_attr_grp_id   IN NUMBER
       ,p_attr_grp_type IN VARCHAR2
       ,p_attr_grp_name IN VARCHAR2
       ,p_attr_name     IN VARCHAR2
       ,p_attr_name_value_pairs       IN ego_user_attr_data_table
       ,p_pk_column_name_value_pairs  IN ego_col_name_value_pair_array
       ) RETURN VARCHAR2;

FUNCTION Is_Attribute_Group_Telco(
        p_attr_grp_name IN VARCHAR2
       ,p_attr_grp_type IN VARCHAR2
        ) RETURN BOOLEAN;

PROCEDURE Validate_Default_CompAttr(
        p_pk_column_name_value_pairs  IN ego_col_name_value_pair_array DEFAULT NULL
       ,x_return_status               OUT NOCOPY VARCHAR2
       ,x_error_messages              OUT NOCOPY ego_col_name_value_pair_array
       );

END EGO_COM_ATTR_VALIDATION;

/
