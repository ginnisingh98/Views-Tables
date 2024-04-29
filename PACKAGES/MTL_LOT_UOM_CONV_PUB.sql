--------------------------------------------------------
--  DDL for Package MTL_LOT_UOM_CONV_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MTL_LOT_UOM_CONV_PUB" AUTHID CURRENT_USER AS
/* $Header: INVPLUCS.pls 120.0 2005/05/25 05:26:27 appldev noship $
/* Record Type Declarations */


G_TRUE      CONSTANT NUMBER := 1;
G_FALSE     CONSTANT NUMBER := 0;

TYPE quantity_update_rec_type IS TABLE OF mtl_lot_conv_audit_details%ROWTYPE
                              INDEX BY BINARY_INTEGER;

lot_uom_conv_rec      mtl_lot_uom_class_conversions%ROWTYPE;


TYPE lotconv_aud_typ IS RECORD
(
 conv_audit_id      mtl_lot_conv_audit.conv_audit_id%TYPE,
 conversion_id      mtl_lot_conv_audit.conversion_id%TYPE,
 conversion_date    mtl_lot_conv_audit.conversion_date%TYPE,
 update_type_indicator   mtl_lot_conv_audit.update_type_indicator%TYPE,
 batch_id           mtl_lot_conv_audit.batch_id%TYPE,
 reason_id          mtl_lot_conv_audit.reason_id%TYPE,
 old_conversion_rate     mtl_lot_conv_audit.old_conversion_rate%TYPE,
 new_conversion_rate     mtl_lot_conv_audit.new_conversion_rate%TYPE,
 event_spec_disp_id      mtl_lot_conv_audit.event_spec_disp_id%TYPE,
 created_by         mtl_lot_conv_audit.created_by%TYPE,
 creation_date      mtl_lot_conv_audit.creation_date%TYPE,
 last_updated_by    mtl_lot_conv_audit.last_updated_by%TYPE,
 last_update_date   mtl_lot_conv_audit.last_update_date%TYPE,
 last_update_login  mtl_lot_conv_audit.last_update_login%TYPE
);


TYPE lotconv_aud_det IS RECORD
(
 conv_audit_detail_id mtl_lot_conv_audit_details.conv_audit_detail_id%TYPE,
 conv_audit_id         mtl_lot_conv_audit_details.conv_audit_id%TYPE,
 revision              mtl_lot_conv_audit_details.revision%TYPE,
 organization_id       mtl_lot_conv_audit_details.organization_id%TYPE,
 subinventory_code     mtl_lot_conv_audit_details.subinventory_code%TYPE,
 lpn_id                mtl_lot_conv_audit_details.lpn_id%TYPE,
 locator_id            mtl_lot_conv_audit_details.locator_id%TYPE,
 old_primary_qty       mtl_lot_conv_audit_details.old_primary_qty%TYPE,
 old_secondary_qty     mtl_lot_conv_audit_details.old_secondary_qty%TYPE,
 new_primary_qty       mtl_lot_conv_audit_details.new_primary_qty%TYPE,
 new_secondary_qty     mtl_lot_conv_audit_details.new_secondary_qty%TYPE,
 transaction_primary_qty mtl_lot_conv_audit_details.transaction_primary_qty%TYPE,
 transaction_secondary_qty mtl_lot_conv_audit_details.transaction_secondary_qty%TYPE,
 transaction_update_flag mtl_lot_conv_audit_details.transaction_update_flag%TYPE,
 created_by           mtl_lot_conv_audit_details.created_by%TYPE,
 creation_date        mtl_lot_conv_audit_details.creation_date%TYPE,
 last_updated_by      mtl_lot_conv_audit_details.last_updated_by%TYPE,
 last_update_date     mtl_lot_conv_audit_details.last_update_date%TYPE,
 last_update_login    mtl_lot_conv_audit_details.last_update_login%TYPE
);


PROCEDURE create_lot_uom_conversion
( p_api_version           IN              NUMBER
, p_init_msg_list         IN              VARCHAR2 DEFAULT FND_API.G_FALSE
, p_commit                IN              VARCHAR2 DEFAULT FND_API.G_FALSE
, p_validation_level      IN              NUMBER   DEFAULT FND_API.G_VALID_LEVEL_FULL
, p_action_type           IN              VARCHAR2
, p_update_type_indicator IN              NUMBER DEFAULT 5
, p_reason_id             IN              NUMBER
, p_batch_id              IN              NUMBER
, p_process_data          IN              VARCHAR2 DEFAULT FND_API.G_TRUE
, p_lot_uom_conv_rec      IN OUT NOCOPY   mtl_lot_uom_class_conversions%ROWTYPE
, p_qty_update_tbl        IN OUT NOCOPY   MTL_LOT_UOM_CONV_PUB.quantity_update_rec_type
, x_return_status         OUT NOCOPY      VARCHAR2
, x_msg_count             OUT NOCOPY      NUMBER
, x_msg_data              OUT NOCOPY      VARCHAR2
, x_sequence              IN OUT NOCOPY   NUMBER
);



END MTL_LOT_UOM_CONV_PUB;

 

/
