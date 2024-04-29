--------------------------------------------------------
--  DDL for Package CSE_DEPLOYMENT_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSE_DEPLOYMENT_GRP" AUTHID CURRENT_USER AS
/* $Header: CSEDPLGS.pls 120.4.12010000.2 2009/07/09 08:26:24 aradhakr ship $ */

 TYPE txn_instance_rec is RECORD (
   instance_id                     NUMBER         :=  FND_API.G_MISS_NUM,
   serial_number                   VARCHAR2(30)   :=  FND_API.G_MISS_CHAR,
   lot_number                      VARCHAR2(80)   :=  FND_API.G_MISS_CHAR,
   inventory_revision              VARCHAR2(3)    :=  FND_API.G_MISS_CHAR,
   last_pa_project_id              NUMBER         :=  FND_API.G_MISS_NUM,
   last_pa_project_task_id         NUMBER         :=  FND_API.G_MISS_NUM,
   inventory_item_id               NUMBER         :=  FND_API.G_MISS_NUM,
   unit_of_measure                 VARCHAR2(3)    :=  FND_API.G_MISS_CHAR,
   active_start_date               DATE           :=  FND_API.G_MISS_DATE,
   active_end_date                 DATE           :=  FND_API.G_MISS_DATE,
   instance_status_id              NUMBER         :=  FND_API.G_MISS_NUM ,
   operational_status_code         VARCHAR2(30)   := fnd_api.g_miss_char,
   asset_id                        number         := fnd_api.g_miss_num);

 TYPE txn_instances_tbl  IS TABLE OF txn_instance_rec INDEX BY BINARY_INTEGER ;

  TYPE dest_location_rec IS RECORD (
    parent_tbl_index                NUMBER         := fnd_api.g_miss_num,
    location_type_code              VARCHAR2(30)   := FND_API.G_MISS_CHAR,
    location_id                     NUMBER         := FND_API.G_MISS_NUM,
    instance_usage_code             VARCHAR2(30)   := FND_API.G_MISS_CHAR,
    last_pa_project_id              NUMBER         := fnd_api.g_miss_num,
    last_pa_project_task_id         NUMBER         := fnd_api.g_miss_num,
    external_reference              VARCHAR2(30)   := fnd_api.g_miss_char,
    operational_status_code         VARCHAR2(30)   := fnd_api.g_miss_char,
    pa_project_id                   number         := fnd_api.g_miss_num,
    pa_project_task_id              number         := fnd_api.g_miss_num);

  TYPE dest_location_tbl IS TABLE OF dest_location_rec INDEX BY BINARY_INTEGER ;


  TYPE txn_ext_attrib_value_rec IS RECORD (
    attribute_value_id      NUMBER         :=  FND_API.G_MISS_NUM,
    parent_tbl_index        NUMBER         :=  FND_API.G_MISS_NUM,
    instance_id             NUMBER         :=  FND_API.G_MISS_NUM,
    attribute_id            NUMBER         :=  FND_API.G_MISS_NUM,
    attribute_code          VARCHAR2(30)   :=  fnd_api.g_miss_char ,
    attribute_value         VARCHAR2(240)  :=  FND_API.G_MISS_CHAR,
    active_start_date       DATE           :=  FND_API.G_MISS_DATE,
    active_end_date         DATE           :=  FND_API.G_MISS_DATE,
    object_version_number   NUMBER         :=  FND_API.G_MISS_NUM);

  TYPE txn_ext_attrib_values_tbl IS table of txn_ext_attrib_value_rec INDEX BY BINARY_INTEGER;

  TYPE transaction_rec IS RECORD (
    transaction_id                  NUMBER        := FND_API.G_MISS_NUM ,
    transaction_date                DATE          := FND_API.G_MISS_DATE,
    source_transaction_date         DATE          := FND_API.G_MISS_DATE,
    transaction_type_id             NUMBER        := FND_API.G_MISS_NUM ,
    txn_sub_type_id                 NUMBER        := FND_API.G_MISS_NUM ,
    source_group_ref_id             NUMBER        := FND_API.G_MISS_NUM ,
    source_group_ref                VARCHAR2(50)  := FND_API.G_MISS_CHAR,
    source_header_ref_id            NUMBER	  := FND_API.G_MISS_NUM ,
    source_header_ref               VARCHAR2(50)  := FND_API.G_MISS_CHAR,
    transacted_by                   NUMBER        := FND_API.G_MISS_NUM,
    transaction_quantity            NUMBER        := FND_API.G_MISS_NUM,
    proceeds_of_sale                number        := fnd_api.g_miss_num,
    cost_of_removal                 number        := fnd_api.g_miss_num,
    operational_flag                varchar2(1)   := fnd_api.g_miss_char,
    financial_flag                  varchar2(1)   := fnd_api.g_miss_char);

  TYPE transaction_tbl IS TABLE OF transaction_rec INDEX BY BINARY_INTEGER ;

  -- Added for bug 8670632
  PROCEDURE interface_nl_to_pa(
    p_trf_pa_attr_rec IN cse_datastructures_pub.Proj_Itm_Insv_PA_ATTR_REC_TYPE,
    p_conc_request_id    IN NUMBER ,
    x_return_status      OUT NOCOPY VARCHAR2,
    x_error_message      OUT NOCOPY VARCHAR2);

  PROCEDURE process_transaction (
    p_instance_tbl            IN            txn_instances_tbl,
    p_dest_location_tbl       IN            dest_location_tbl,
    p_ext_attrib_values_tbl   IN OUT NOCOPY txn_ext_attrib_values_tbl,
    p_txn_tbl                 IN OUT NOCOPY transaction_tbl,
    x_return_status              OUT NOCOPY varchar2,
    x_error_msg                  OUT NOCOPY varchar2);

END cse_deployment_grp;

/
