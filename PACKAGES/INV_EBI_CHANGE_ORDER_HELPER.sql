--------------------------------------------------------
--  DDL for Package INV_EBI_CHANGE_ORDER_HELPER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_EBI_CHANGE_ORDER_HELPER" AUTHID CURRENT_USER AS
/* $Header: INVEIHCOS.pls 120.16.12010000.6 2009/07/24 13:20:43 smukka ship $ */

 G_INCLUDE_REV_ITEMS             CONSTANT  VARCHAR2(50) := 'INCLUDE_REVISED_ITEMS';
 G_INCLUDE_COMP_ITEMS            CONSTANT  VARCHAR2(50) := 'INCLUDE_COMPONENT_ITEMS';
 G_INCLUDE_SUB_COMP              CONSTANT  VARCHAR2(50) := 'INCLUDE_SUBSTITUTE_COMPONENTS';
 G_INCLUDE_REF_DESIGNATORS       CONSTANT  VARCHAR2(50) := 'INCLUDE_REFERENCE_DESIGNATORS';
 G_VIEW_SCOPE_ALL                CONSTANT  VARCHAR2(3)  := 'ALL';
 G_VIEW_SCOPE_CURRENT            CONSTANT  VARCHAR2(50) := 'CURRENT';
 G_VIEW_SCOPE_CURR_FUTURE        CONSTANT  VARCHAR2(50) := 'CURRENT_AND_FUTURE';
 G_IMPLEMENT_SCOPE_IMPLEMENT     CONSTANT  VARCHAR2(50) := 'IMPLEMENTED';
 G_IMPLEMENT_SCOPE_UNIMPLEMENT   CONSTANT  VARCHAR2(50) := 'UNIMPLEMENTED';
 G_ASSIGN_ITEM_TO_CHILD_ORG      CONSTANT  VARCHAR2(50) := 'ASSIGN_ITEM_TO_CHILD_ORG';
 G_DEFAULT_STRUCTURE_TYPE        CONSTANT  VARCHAR2(50) := 'DEFAULT_STRUCTURE_TYPE';
 G_PLM_OR_ERP_CHANGE             CONSTANT  VARCHAR2(50) := 'CREATE_ERP_CHANGE_ORDER';
 G_ASSIGN_ITEM                   VARCHAR2(1) := fnd_api.g_false;
 G_BOM_UPDATES_ALLOWED           CONSTANT  VARCHAR2(50) := 'STANDALONE_BOM_UPDATES_ALLOWED';

 PROCEDURE process_eco(
   p_commit                   IN  VARCHAR2 := FND_API.G_FALSE
  ,p_change_order             IN  inv_ebi_change_order_obj
  ,p_revision_type_tbl        IN  inv_ebi_eco_revision_tbl
  ,p_revised_item_type_tbl    IN  inv_ebi_revised_item_tbl
  ,p_name_val_list            IN  inv_ebi_name_value_list
  ,x_out                      OUT NOCOPY   inv_ebi_eco_output_obj
 ) ;

 PROCEDURE process_structure_header(
    p_commit                   IN  VARCHAR2 := FND_API.G_FALSE
   ,p_organization_code        IN  VARCHAR2
   ,p_assembly_item_name       IN  VARCHAR2
   ,p_alternate_bom_code       IN  VARCHAR2
   ,p_structure_header         IN  inv_ebi_structure_header_obj
   ,p_component_item_tbl       IN  inv_ebi_rev_comp_tbl
   ,p_name_val_list            IN  inv_ebi_name_value_list
   ,x_out                      OUT NOCOPY   inv_ebi_eco_output_obj
 ) ;

 PROCEDURE process_uda (
   p_commit                      IN     VARCHAR2 := FND_API.g_false
  ,p_api_version                 IN     NUMBER DEFAULT 1.0
  ,p_uda_input_obj               IN     inv_ebi_uda_input_obj
  ,p_object_name                 IN     VARCHAR2
  ,p_data_level                  IN     VARCHAR2
  ,p_pk_column_name_value_pairs  IN     EGO_COL_NAME_VALUE_PAIR_ARRAY
  ,p_class_code_name_value_pairs IN     EGO_COL_NAME_VALUE_PAIR_ARRAY
  ,x_uda_output_obj              OUT    NOCOPY inv_ebi_eco_output_obj
 );

 PROCEDURE process_change_order_uda(
    p_commit                  IN  VARCHAR2
   ,p_organization_code       IN  VARCHAR2
   ,p_eco_name                IN  VARCHAR2
   ,p_alternate_bom_code      IN  VARCHAR2
   ,p_revised_item_name       IN  VARCHAR2
   ,p_component_tbl           IN  inv_ebi_rev_comp_tbl
   ,p_structure_header        IN  inv_ebi_structure_header_obj
   ,x_out                     OUT NOCOPY inv_ebi_eco_output_obj
 );

 PROCEDURE get_eco (
   p_change_id                 IN              NUMBER
  ,p_last_update_status        IN              VARCHAR2
  ,p_revised_item_sequence_id  IN              NUMBER
  ,p_name_val_list             IN              inv_ebi_name_value_list
  ,x_eco_obj                   OUT NOCOPY      inv_ebi_eco_obj
  ,x_return_status             OUT NOCOPY      VARCHAR2
  ,x_msg_count                 OUT NOCOPY      NUMBER
  ,x_msg_data                  OUT NOCOPY      VARCHAR2
);

PROCEDURE process_replicate_bom(
   p_organization_code   IN  VARCHAR2
  ,p_revised_item_obj    IN  inv_ebi_revised_item_obj
  ,p_name_value_tbl      IN  inv_ebi_name_value_tbl
  ,x_revised_item_obj    OUT NOCOPY  inv_ebi_revised_item_obj
  ,x_out                 OUT NOCOPY  inv_ebi_eco_output_obj
 ) ;

 PROCEDURE get_eco_list(
  p_name_value_list         IN             inv_ebi_name_value_tbl
 ,p_prog_id                 IN             NUMBER
 ,p_appl_id                 IN             NUMBER
 ,x_eco                    OUT NOCOPY      inv_ebi_change_id_obj_tbl
 ,x_return_status          OUT NOCOPY      VARCHAR2
 ,x_msg_count              OUT NOCOPY      NUMBER
 ,x_msg_data               OUT NOCOPY      VARCHAR2
);

 FUNCTION Check_Workflow_Process(
   p_change_order_type_id       IN NUMBER
  ,p_priority_code              IN VARCHAR2
) RETURN BOOLEAN;

PROCEDURE set_assign_item(
   p_assign_item IN VARCHAR2
 ) ;

FUNCTION get_current_item_revision(
  p_inventory_item_id  IN NUMBER,
  p_organization_id    IN NUMBER,
  p_date               IN DATE
 ) RETURN VARCHAR2;


FUNCTION is_child_org (
  p_organization_id  IN NUMBER
) RETURN VARCHAR2;

FUNCTION is_task_template_set(
   p_change_order_type_id  IN NUMBER
  ,p_organization_id       IN NUMBER
  ,p_status_code           IN NUMBER
)  RETURN BOOLEAN;

FUNCTION get_eco_status_name(p_status_code IN NUMBER)
RETURN VARCHAR2;

FUNCTION get_change_type_code(p_change_type_id   IN  NUMBER )
RETURN VARCHAR2;

PROCEDURE transform_replicate_bom_info(
     p_eco_obj_list      IN  inv_ebi_eco_obj_tbl
    ,p_revised_item_obj  IN  inv_ebi_revised_item_obj
    ,x_revised_item_obj  OUT NOCOPY inv_ebi_revised_item_obj
    ,x_out               OUT NOCOPY inv_ebi_eco_output_obj
    ) ;

FUNCTION is_bom_exists(
    p_item_number         IN  VARCHAR2
   ,p_organization_code   IN  VARCHAR2
   ,p_alternate_bom_code  IN  VARCHAR2
  ) RETURN VARCHAR2;

END INV_EBI_CHANGE_ORDER_HELPER;

/
