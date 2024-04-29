--------------------------------------------------------
--  DDL for Package WMS_CONTAINER_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WMS_CONTAINER_GRP" AUTHID CURRENT_USER AS
  /* $Header: WMSGCNTS.pls 120.3 2005/12/16 02:26:27 amohamme noship $ */

/* Automatic generate LPNs */
PROCEDURE Auto_Create_LPNs (
  p_api_version   IN         NUMBER
, p_init_msg_list IN         VARCHAR2
, p_commit        IN         VARCHAR2
, x_return_status OUT NOCOPY VARCHAR2
, x_msg_count     OUT NOCOPY NUMBER
, x_msg_data      OUT NOCOPY VARCHAR2
, p_caller        IN         VARCHAR2
, p_gen_lpn_rec   IN         WMS_Data_Type_Definitions_PUB.AutoCreateLPNRecordType
, p_lpn_table     OUT NOCOPY WMS_Data_Type_Definitions_PUB.LPNTableType
);

/* Create new LPNs as given in the p_lpn_table */
PROCEDURE Create_LPNs (
  p_api_version   IN            NUMBER
, p_init_msg_list IN            VARCHAR2
, p_commit        IN            VARCHAR2
, x_return_status OUT    NOCOPY VARCHAR2
, x_msg_count     OUT    NOCOPY NUMBER
, x_msg_data      OUT    NOCOPY VARCHAR2
, p_caller        IN            VARCHAR2
, p_lpn_table     IN OUT NOCOPY WMS_Data_Type_Definitions_PUB.LPNTableType
);

/* Modify LPNs as given in the p_lpn_table
   Columns that can be modified are
    , organization_id
    , license_plate_number
    , parent_lpn_id
    , outermost_lpn_id
    , inventory_item_id
    , subinventory_code
    , locator_id
    , tare_weight
    , tare_weight_uom_code
    , gross_weight_uom_code
    , gross_weight
    , container_volume
    , container_volume_uom
    , content_volume_uom_code
    , content_volume
    , lpn_context
    , attribute_category
    , attribute1
    , attribute2
    , attribute3
    , attribute4
    , attribute5
    , attribute6
    , attribute7
    , attribute8
    , attribute9
    , attribute10
    , attribute11
    , attribute12
    , attribute13
    , attribute14
    , attribute15
    , source_type_id
    , source_header_id
    , source_line_id
    , source_line_detail_id
    , source_name
*/
PROCEDURE Modify_LPNs (
  p_api_version   IN         NUMBER
, p_init_msg_list IN         VARCHAR2
, p_commit        IN         VARCHAR2
, x_return_status OUT NOCOPY VARCHAR2
, x_msg_count     OUT NOCOPY NUMBER
, x_msg_data      OUT NOCOPY VARCHAR2
, p_caller        IN         VARCHAR2
, p_lpn_table     IN         WMS_Data_Type_Definitions_PUB.LPNTableType
);

G_LPN_PURGE_ACTION_VALIDATE CONSTANT VARCHAR2(50) := 'VALIDATE';
G_LPN_PURGE_ACTION_DELETE   CONSTANT VARCHAR2(50) := 'VALIDATE_AND_DELETE';

PROCEDURE LPN_Purge_Actions (
  p_api_version   IN            NUMBER
, p_init_msg_list IN            VARCHAR2
, p_commit        IN            VARCHAR2
, x_return_status OUT    NOCOPY VARCHAR2
, x_msg_count     OUT    NOCOPY NUMBER
, x_msg_data      OUT    NOCOPY VARCHAR2
, p_caller        IN            VARCHAR2
, p_action        IN            VARCHAR2
, p_lpn_purge_rec IN OUT NOCOPY WMS_Data_Type_Definitions_PUB.LPNPurgeRecordType
);

END WMS_Container_GRP;

 

/
