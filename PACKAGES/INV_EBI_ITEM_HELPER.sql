--------------------------------------------------------
--  DDL for Package INV_EBI_ITEM_HELPER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_EBI_ITEM_HELPER" AUTHID CURRENT_USER AS
/* $Header: INVEIHITS.pls 120.17.12010000.4 2009/02/13 09:41:18 prepatel ship $ */

G_TEMPLATE                 CONSTANT  NUMBER := 1;
G_INVENTORY_ITEM           CONSTANT  NUMBER := 2;
G_ORGANIZATION             CONSTANT  NUMBER := 3;
G_ITEM_CATALOG_GROUP       CONSTANT  NUMBER := 4;
G_LIFECYCLE                CONSTANT  NUMBER := 5;
G_CURRENT_PHASE            CONSTANT  NUMBER := 6;
G_REVISION                 CONSTANT  NUMBER := 7;
G_HAZARD_CLASS             CONSTANT  NUMBER := 8;
G_ASSET_CATEGORY           CONSTANT  NUMBER := 9;
G_BASE_ITEM                CONSTANT  NUMBER := 10;
G_MANUFACTURER             CONSTANT  NUMBER := 11;
G_CATEGORY_SET             CONSTANT  NUMBER := 12;
G_CATEGORY                 CONSTANT  NUMBER := 13;
G_ASSET_MGMT_ATTRS         CONSTANT  VARCHAR2(20) := 'ASSET_ATTRS';
G_BOM_ATTRS                CONSTANT  VARCHAR2(20) := 'BOM_ATTRS';
G_COSTING_ATTRS            CONSTANT  VARCHAR2(20) := 'COSTING_ATTRS';
G_GPLAN_ATTRS              CONSTANT  VARCHAR2(20) := 'GPLAN_ATTRS';
G_INVENTORY_ATTRS          CONSTANT  VARCHAR2(20) := 'INVENTORY_ATTRS';
G_INVOICE_ATTRS            CONSTANT  VARCHAR2(20) := 'INVOICE_ATTRS';
G_LEAD_TIME_ATTRS          CONSTANT  VARCHAR2(20) := 'LEAD_TIME_ATTRS';
G_MPSMRP_ATTRS             CONSTANT  VARCHAR2(20) := 'MPSMRP_ATTRS';
G_ORDER_ATTRS              CONSTANT  VARCHAR2(20) := 'ORDER_ATTRS';
G_PHYSICAL_ATTRS           CONSTANT  VARCHAR2(20) := 'PHYSICAL_ATTRS';
G_PROCESS_ATTRS            CONSTANT  VARCHAR2(20) := 'PROCESS_ATTRS';
G_PURCHASING_ATTRS         CONSTANT  VARCHAR2(20) := 'PURCHASING_ATTRS';
G_RECEVING_ATTRS           CONSTANT  VARCHAR2(20) := 'RECEIVING_ATTRS';
G_SERVICE_ATTRS            CONSTANT  VARCHAR2(20) := 'SERVICE_ATTRS';
G_WEB_OPTION_ATTRS         CONSTANT  VARCHAR2(20) := 'WEB_OPTION_ATTRS';
G_WIP_ATTRS                CONSTANT  VARCHAR2(20) := 'WIP_ATTRS';
G_ITEM_ATTRS               CONSTANT  VARCHAR2(20) := 'ITEM_ATTRS';
G_DEFAULT_COST_GROUP_ID    CONSTANT  VARCHAR2(25) := 'DEFAULT_ITEM_COST_GROUP';
G_DEFAULT_COST_TYPE_ID     CONSTANT  VARCHAR2(25) := 'DEFAULT_ITEM_COST_TYPE';
G_TIME_ZONE_OFFSET                   VARCHAR2(25) ;

TYPE inv_ebi_name_value_pair_rec IS RECORD(
  Name                  VARCHAR2(75)
 ,Value                 VARCHAR2(150)
);

TYPE inv_ebi_name_value_pair_tbl IS TABLE OF inv_ebi_name_value_pair_rec;

FUNCTION id_col_value(
    p_col_name                   IN     VARCHAR2
   ,p_pk_col_name_val_pairs      IN      INV_EBI_ITEM_HELPER.inv_ebi_name_value_pair_tbl
) RETURN VARCHAR2;

FUNCTION value_to_id(
    p_pk_col_name_val_pairs  IN   INV_EBI_ITEM_HELPER.inv_ebi_name_value_pair_tbl
   ,p_entity_name            IN   VARCHAR2
 ) RETURN NUMBER;

FUNCTION id_to_value(
     p_pk_col_name_val_pairs  IN   INV_EBI_ITEM_HELPER.inv_ebi_name_value_pair_tbl
    ,p_entity_name            IN   VARCHAR2
 ) RETURN VARCHAR2;

PROCEDURE initialize_item(
 x_item                 IN OUT NOCOPY inv_ebi_item_obj
);


Procedure sync_item (
  p_commit           IN  VARCHAR2 := fnd_api.g_false
 ,p_operation        IN  VARCHAR2
 ,p_item             IN  inv_ebi_item_obj
 ,x_out              OUT NOCOPY inv_ebi_item_output_obj
) ;

PROCEDURE process_item_pvt(
   p_commit              IN  VARCHAR2 := fnd_api.g_false
  ,p_operation           IN  VARCHAR2
  ,p_item                IN  inv_ebi_item_obj
  ,x_out                 OUT NOCOPY inv_ebi_item_output_obj
 ) ;

PROCEDURE process_item_uda (
   p_api_version            IN      NUMBER DEFAULT 1.0
  ,p_inventory_item_id      IN      NUMBER
  ,p_organization_id        IN      NUMBER
  ,p_item_catalog_group_id  IN      NUMBER   DEFAULT NULL
  ,p_revision_id            IN      NUMBER   DEFAULT NULL
  ,p_revision_code          IN      VARCHAR2 DEFAULT NULL
  ,p_uda_input_obj          IN      inv_ebi_uda_input_obj
  ,p_commit                 IN      VARCHAR2  := fnd_api.g_false
  ,x_uda_output_obj         OUT     NOCOPY  inv_ebi_item_output_obj
);

PROCEDURE process_org_id_assignments(
   p_init_msg_list      IN          VARCHAR2
  ,p_commit             IN          VARCHAR2 := fnd_api.g_false
  ,p_inventory_item_id  IN          NUMBER
  ,p_item_number        IN          VARCHAR2
  ,p_org_id_tbl         IN          inv_ebi_org_tbl
  ,x_out                OUT NOCOPY  inv_ebi_item_output_obj
);

PROCEDURE process_category_assignments(
   p_api_version         IN           NUMBER  DEFAULT 1.0
  ,p_init_msg_list       IN           VARCHAR2
  ,p_commit              IN           VARCHAR2 := fnd_api.g_false
  ,p_inventory_item_id   IN           NUMBER
  ,p_organization_id     IN           NUMBER
  ,p_category_id_tbl     IN           inv_ebi_category_obj_tbl_type
  ,x_out                 OUT NOCOPY   inv_ebi_item_output_obj
);

PROCEDURE process_part_num_association(
    p_commit                 IN   VARCHAR2 := fnd_api.g_false
   ,p_organization_id        IN   NUMBER
   ,p_inventory_item_id      IN   NUMBER
   ,p_mfg_part_obj           IN   inv_ebi_manufacturer_part_obj
   ,x_out                    OUT  NOCOPY inv_ebi_item_output_obj
);

PROCEDURE get_item_balance(
  p_item_balance_input        IN              inv_ebi_item_bal_input_list
 ,x_item_balance_output       OUT NOCOPY      inv_ebi_item_bal_output_list
 ,x_return_status             OUT NOCOPY      VARCHAR2
 ,x_msg_count                 OUT NOCOPY      NUMBER
 ,x_msg_data                  OUT NOCOPY      VARCHAR2
 );

PROCEDURE get_item_attributes(
  p_get_item_inp_obj       IN         inv_ebi_get_item_input
 ,x_item_tbl_obj           OUT NOCOPY inv_ebi_item_attr_tbl_obj
 ,x_return_status          OUT NOCOPY VARCHAR2
 ,x_msg_count              OUT NOCOPY NUMBER
 ,x_msg_data               OUT NOCOPY VARCHAR2
 );

PROCEDURE validate_get_item_request(
  p_get_opr_attrs_rec  IN         inv_ebi_get_operational_attrs
 ,x_status             OUT NOCOPY VARCHAR2
 ,x_msg_count          OUT NOCOPY NUMBER
 ,x_msg_data           OUT NOCOPY VARCHAR2
);

FUNCTION is_engineering_item (
  p_organization_id   IN  NUMBER
 ,p_item_number       IN  VARCHAR2
) RETURN VARCHAR;

FUNCTION is_item_exists (
   p_organization_id IN  NUMBER
  ,p_item_number     IN  VARCHAR2
) RETURN VARCHAR;

FUNCTION is_new_item_request_reqd(
   p_item_catalog_group_id  IN   NUMBER
 ) RETURN VARCHAR;

FUNCTION get_inventory_item_id(
    p_organization_id   IN   NUMBER
   ,p_item_number       IN   VARCHAR2
 ) RETURN NUMBER;

FUNCTION get_item_num(
   p_segment1  IN VARCHAR2
  ,p_segment2  IN VARCHAR2
  ,p_segment3  IN VARCHAR2
  ,p_segment4  IN VARCHAR2
  ,p_segment5  IN VARCHAR2
  ,p_segment6  IN VARCHAR2
  ,p_segment7  IN VARCHAR2
  ,p_segment8  IN VARCHAR2
  ,p_segment9  IN VARCHAR2
  ,p_segment10 IN VARCHAR2
  ,p_segment11 IN VARCHAR2
  ,p_segment12 IN VARCHAR2
  ,p_segment13 IN VARCHAR2
  ,p_segment14 IN VARCHAR2
  ,p_segment15 IN VARCHAR2
  ,p_segment16 IN VARCHAR2
  ,p_segment17 IN VARCHAR2
  ,p_segment18 IN VARCHAR2
  ,p_segment19 IN VARCHAR2
  ,p_segment20 IN VARCHAR2
 ) RETURN VARCHAR2;

FUNCTION get_organization_id ( p_organization_code  IN  VARCHAR2 ) RETURN NUMBER;

PROCEDURE get_item_attributes_list(
  p_name_value_list         IN             inv_ebi_name_value_tbl
 ,p_prog_id                 IN             NUMBER
 ,p_appl_id                 IN             NUMBER
 ,p_cross_reference_type    IN             VARCHAR2
 ,x_items                  OUT NOCOPY      inv_ebi_get_opr_attrs_tbl
 ,x_return_status          OUT NOCOPY      VARCHAR2
 ,x_msg_count              OUT NOCOPY      NUMBER
 ,x_msg_data               OUT NOCOPY      VARCHAR2
);

FUNCTION get_default_master_org(
  p_config  IN inv_ebi_name_value_tbl
) RETURN NUMBER;

FUNCTION get_last_run_date(
  p_conc_prog_id  IN   NUMBER
 ,p_appl_id       IN   NUMBER
) RETURN DATE;

FUNCTION parse_input_string(
  p_input_string  IN  VARCHAR2
) RETURN  FND_TABLE_OF_VARCHAR2_255;

PROCEDURE get_item_balance_list(
  p_name_value_list         IN             inv_ebi_name_value_tbl
 ,p_prog_id                 IN             NUMBER
 ,p_appl_id                 IN             NUMBER
 ,p_cross_reference_type    IN             VARCHAR2
 ,x_items                  OUT NOCOPY      inv_ebi_get_opr_attrs_tbl
 ,x_return_status          OUT NOCOPY      VARCHAR2
 ,x_msg_count              OUT NOCOPY      NUMBER
 ,x_msg_data               OUT NOCOPY      VARCHAR2
);

PROCEDURE populate_item_ids(
  p_item  IN  inv_ebi_item_obj
 ,x_out   OUT NOCOPY inv_ebi_item_output_obj
 ,x_item  OUT NOCOPY inv_ebi_item_obj
);

 PROCEDURE get_uda_attributes(
   p_classification_id  IN     NUMBER,
   p_attr_group_type    IN     VARCHAR2,
   p_application_id     IN     NUMBER,
   p_attr_grp_id_tbl    IN     FND_TABLE_OF_NUMBER,
   p_data_level         IN     VARCHAR2,
   p_revision_id        IN     NUMBER,
   p_object_name        IN     VARCHAR2,
   p_pk_data            IN     EGO_COL_NAME_VALUE_PAIR_ARRAY,
   x_uda_obj            OUT    NOCOPY inv_ebi_uda_input_obj,
   x_uda_output_obj     OUT    NOCOPY inv_ebi_eco_output_obj
 ) ;


PROCEDURE get_Operating_unit
   (p_oranization_id IN NUMBER
   ,x_operating_unit  OUT NOCOPY VARCHAR2
   ,x_ouid             OUT NOCOPY NUMBER
   );

PROCEDURE set_server_time_zone;

FUNCTION convert_date_str(p_datetime IN DATE)
RETURN VARCHAR2;

END INV_EBI_ITEM_HELPER;

/
