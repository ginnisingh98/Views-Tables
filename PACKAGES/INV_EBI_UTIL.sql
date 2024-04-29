--------------------------------------------------------
--  DDL for Package INV_EBI_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_EBI_UTIL" AUTHID CURRENT_USER AS
/* $Header: INVEIUTLS.pls 120.7.12010000.4 2009/04/06 11:48:55 prepatel ship $ */

G_EGO_ITEMMGMT_GROUP           CONSTANT  VARCHAR2(30)   := 'EGO_ITEMMGMT_GROUP';
G_ENG_CHANGEMGMT_GROUP         CONSTANT  VARCHAR2(30)   := 'ENG_CHANGEMGMT_GROUP';
G_BOM_STRUCTUREMGMT_GROUP      CONSTANT  VARCHAR2(30)   := 'BOM_STRUCTUREMGMT_GROUP';
G_BOM_COMPONENTMGMT_GROUP      CONSTANT  VARCHAR2(30)   := 'BOM_COMPONENTMGMT_GROUP';
G_CHANGE_LEVEL                 CONSTANT  VARCHAR2(30)   := 'CHANGE_LEVEL';
G_STRUCTURES_LEVEL             CONSTANT  VARCHAR2(30)   := 'STRUCTURES_LEVEL';
G_COMPONENTS_LEVEL             CONSTANT  VARCHAR2(30)   := 'COMPONENTS_LEVEL';
G_EGO_ITEM                     CONSTANT  VARCHAR2(30)   := 'EGO_ITEM';
G_CHANGE_OBJ_NAME              CONSTANT  VARCHAR2(30)   := 'ENG_CHANGE';
G_BOM_STRUCTURE_OBJ_NAME       CONSTANT  VARCHAR2(30)   := 'BOM_STRUCTURE';
G_BOM_COMPONENTS_OBJ_NAME      CONSTANT  VARCHAR2(30)   := 'BOM_COMPONENTS';

G_DEBUG boolean default false;

FUNCTION is_pim_installed RETURN BOOLEAN ;

FUNCTION is_master_org(
   p_organization_id IN   NUMBER
 ) RETURN VARCHAR;

FUNCTION is_master_org(
   p_organization_code IN   VARCHAR2
 ) RETURN VARCHAR;
FUNCTION get_master_organization(
   p_organization_id IN NUMBER
 ) RETURN NUMBER;

PROCEDURE transform_uda (
    p_uda_input_obj          IN  inv_ebi_uda_input_obj
   ,x_attributes_row_table   OUT NOCOPY ego_user_attr_row_table
   ,x_attributes_data_table  OUT NOCOPY ego_user_attr_data_table
   ,x_return_status          OUT NOCOPY VARCHAR2 --Bug 7240247
   ,x_msg_count              OUT NOCOPY NUMBER
   ,x_msg_data               OUT NOCOPY VARCHAR2
);
PROCEDURE transform_attr_rowdata_uda(
    p_attributes_row_table    IN          ego_user_attr_row_table
    ,p_attributes_data_table  IN          ego_user_attr_data_table
    ,x_uda_input_obj          OUT NOCOPY  inv_ebi_uda_input_obj
    ,x_return_status          OUT NOCOPY VARCHAR2 --Bug 7240247
    ,x_msg_count              OUT NOCOPY NUMBER
    ,x_msg_data               OUT NOCOPY VARCHAR2
);

FUNCTION get_config_param_value(
   p_config_tbl        IN inv_ebi_name_value_tbl
  ,p_config_param_name IN VARCHAR2
) RETURN VARCHAR;

FUNCTION get_error_table RETURN inv_ebi_error_tbl_type;

FUNCTION get_error_table_msgtxt(
  p_error_table    IN  inv_ebi_error_tbl_type
) RETURN VARCHAR2;

-- Bug 7240247
FUNCTION get_application_id(
      p_application_short_name IN VARCHAR2
 ) RETURN NUMBER ;

PROCEDURE put_names(
                p_log_file              VARCHAR2,
                p_out_file              VARCHAR2,
                p_directory             VARCHAR2);

PROCEDURE debug_line(
                p_text                  VARCHAR2 );

PROCEDURE setup(
                p_filename              VARCHAR2 Default NULL
                );

PROCEDURE wrapup;

PROCEDURE set_apps_context( p_name_value_tbl IN inv_ebi_name_value_tbl);

END INV_EBI_UTIL;

/
