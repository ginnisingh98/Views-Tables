--------------------------------------------------------
--  DDL for Package GMI_TO_FORM_TROLIN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMI_TO_FORM_TROLIN" AUTHID CURRENT_USER AS
/*  $Header: GMIFTRLS.pls 115.5 2002/10/29 15:19:09 jdiiorio ship $  */
/*
 +=========================================================================+
 |                Copyright (c) 2000 Oracle Corporation                    |
 |                        TVP, Reading, England                            |
 |                         All rights reserved                             |
 +=========================================================================+
 | FILENAME                                                                |
 |    GMIFTRLS.pls                                                         |
 |                                                                         |
 | DESCRIPTION                                                             |
 |     This package contains private utilities interface procedures        |
 |     to forms ICTOTRX.fmb                                                |
 |                                                                         |
 | - Need to be cleaned                                                    |
 |                                                                         |
 | HISTORY                                                                 |
 |     07-MAR-2000  odaboval        Created                                |
 |     29-OCT-2002  jdiiorio        Update - Bug#2643440 11.5.1J           |
 |                                  Added nocopy.                          |
 +=========================================================================+
*/


/*  Procedure : Default_Attributes
*/
/* odab
PROCEDURE Default_Attributes
(   x_return_status                 OUT NOCOPY VARCHAR2
,   x_msg_count                     OUT NOCOPY NUMBER
,   x_msg_data                      OUT NOCOPY VARCHAR2
,   p_header_id                     IN  NUMBER
,   x_attribute1                    OUT NOCOPY VARCHAR2
,   x_attribute10                   OUT NOCOPY VARCHAR2
,   x_attribute11                   OUT NOCOPY VARCHAR2
,   x_attribute12                   OUT NOCOPY VARCHAR2
,   x_attribute13                   OUT NOCOPY VARCHAR2
,   x_attribute14                   OUT NOCOPY VARCHAR2
,   x_attribute15                   OUT NOCOPY VARCHAR2
,   x_attribute2                    OUT NOCOPY VARCHAR2
,   x_attribute3                    OUT NOCOPY VARCHAR2
,   x_attribute4                    OUT NOCOPY VARCHAR2
,   x_attribute5                    OUT NOCOPY VARCHAR2
,   x_attribute6                    OUT NOCOPY VARCHAR2
,   x_attribute7                    OUT NOCOPY VARCHAR2
,   x_attribute8                    OUT NOCOPY VARCHAR2
,   x_attribute9                    OUT NOCOPY VARCHAR2
,   x_attribute_category            OUT NOCOPY VARCHAR2
,   x_date_required                 OUT NOCOPY DATE
,   x_from_locator_id               OUT NOCOPY NUMBER
,   x_from_subinventory_code        OUT NOCOPY VARCHAR2
,   x_from_subinventory_id          OUT NOCOPY NUMBER
,   x_header_id                     OUT NOCOPY NUMBER
,   x_inventory_item_id             OUT NOCOPY NUMBER
,   x_line_id                       OUT NOCOPY NUMBER
,   x_line_number                   OUT NOCOPY NUMBER
,   x_line_status                   OUT NOCOPY NUMBER
,   x_lot_number                    OUT NOCOPY VARCHAR2
,   x_organization_id               OUT NOCOPY NUMBER
,   x_project_id                    OUT NOCOPY NUMBER
,   x_quantity                      OUT NOCOPY NUMBER
,   x_quantity_delivered            OUT NOCOPY NUMBER
,   x_quantity_detailed             OUT NOCOPY NUMBER
,   x_reason_id                     OUT NOCOPY NUMBER
,   x_reference                     OUT NOCOPY VARCHAR2
,   x_reference_id                  OUT NOCOPY NUMBER
,   x_reference_type_code           OUT NOCOPY NUMBER
,   x_revision                      OUT NOCOPY VARCHAR2
,   x_serial_number_end             OUT NOCOPY VARCHAR2
,   x_serial_number_start           OUT NOCOPY VARCHAR2
,   x_status_date                   OUT NOCOPY DATE
,   x_task_id                       OUT NOCOPY NUMBER
,   x_to_account_id                 OUT NOCOPY NUMBER
,   x_to_locator_id                 OUT NOCOPY NUMBER
,   x_to_subinventory_code          OUT NOCOPY VARCHAR2
,   x_to_subinventory_id            OUT NOCOPY NUMBER
,   x_transaction_header_id         OUT NOCOPY NUMBER
,   x_uom_code                      OUT NOCOPY VARCHAR2
,   x_from_locator                  OUT NOCOPY VARCHAR2
,   x_inventory_item                OUT NOCOPY VARCHAR2
,   x_project                       OUT NOCOPY VARCHAR2
,   x_reason                        OUT NOCOPY VARCHAR2
,   x_reference_type                OUT NOCOPY VARCHAR2
,   x_task                          OUT NOCOPY VARCHAR2
,   x_to_account                    OUT NOCOPY VARCHAR2
,   x_to_locator                    OUT NOCOPY VARCHAR2
,   x_transaction_type_id	    OUT NOCOPY NUMBER
,   x_transaction_source_type_id    OUT NOCOPY NUMBER
,   x_txn_source_id		    OUT NOCOPY NUMBER
,   x_txn_source_line_id	    OUT NOCOPY NUMBER
,   x_txn_source_line_detail_id	    OUT NOCOPY NUMBER
,   x_primary_quantity		    OUT NOCOPY NUMBER
,   x_to_organization_id	    OUT NOCOPY NUMBER
,   x_pick_strategy_id		    OUT NOCOPY NUMBER
,   x_put_away_strategy_id	    OUT NOCOPY NUMBER
,   x_unit_number	            OUT NOCOPY VARCHAR2
*/
/* ,   x_ship_to_location_id           OUT NOCOPY NUMBER   NL MERGE */
/*
,   x_transaction_type		    OUT NOCOPY VARCHAR2
);
*/
/*  Procedure   :   Validate_Record
*/
/*
PROCEDURE Validate_Record
(   x_return_status                 OUT NOCOPY VARCHAR2
,   x_msg_count                     OUT NOCOPY NUMBER
,   x_msg_data                      OUT NOCOPY VARCHAR2
,   p_attribute1                    IN  VARCHAR2
,   p_attribute10                   IN  VARCHAR2
,   p_attribute11                   IN  VARCHAR2
,   p_attribute12                   IN  VARCHAR2
,   p_attribute13                   IN  VARCHAR2
,   p_attribute14                   IN  VARCHAR2
,   p_attribute15                   IN  VARCHAR2
,   p_attribute2                    IN  VARCHAR2
,   p_attribute3                    IN  VARCHAR2
,   p_attribute4                    IN  VARCHAR2
,   p_attribute5                    IN  VARCHAR2
,   p_attribute6                    IN  VARCHAR2
,   p_attribute7                    IN  VARCHAR2
,   p_attribute8                    IN  VARCHAR2
,   p_attribute9                    IN  VARCHAR2
,   p_attribute_category            IN  VARCHAR2
,   p_date_required                 IN  DATE
,   p_from_locator_id               IN  NUMBER
,   p_from_subinventory_code        IN  VARCHAR2
,   p_from_subinventory_id          IN  NUMBER
,   p_header_id                     IN  NUMBER
,   p_inventory_item_id             IN  NUMBER
,   p_line_id                       IN  NUMBER
,   p_line_number                   IN  NUMBER
,   p_line_status                   IN  NUMBER
,   p_lot_number                    IN  VARCHAR2
,   p_organization_id               IN  NUMBER
,   p_project_id                    IN  NUMBER
,   p_quantity                      IN  NUMBER
,   p_quantity_delivered            IN  NUMBER
,   p_quantity_detailed             IN  NUMBER
,   p_reason_id                     IN  NUMBER
,   p_reference                     IN  VARCHAR2
,   p_reference_id                  IN  NUMBER
,   p_reference_type_code           IN  NUMBER
,   p_revision                      IN  VARCHAR2
,   p_serial_number_end             IN  VARCHAR2
,   p_serial_number_start           IN  VARCHAR2
,   p_status_date                   IN  DATE
,   p_task_id                       IN  NUMBER
,   p_to_account_id                 IN  NUMBER
,   p_to_locator_id                 IN  NUMBER
,   p_to_subinventory_code          IN  VARCHAR2
,   p_to_subinventory_id            IN  NUMBER
,   p_transaction_header_id         IN  NUMBER
,   p_uom_code                      IN  VARCHAR2
,   p_transaction_type_id	    IN  NUMBER
,   p_transaction_source_type_id    IN  NUMBER
,   p_txn_source_id		    IN  NUMBER
,   p_txn_source_line_id	    IN  NUMBER
,   p_txn_source_line_detail_id     IN  NUMBER
,   p_primary_quantity		    IN  NUMBER
,   p_to_organization_id	    IN  NUMBER
,   p_pick_strategy_id		    IN  NUMBER
,   p_put_away_strategy_id	    IN  NUMBER
,   p_unit_number	    	    IN  VARCHAR2
,   p_ship_to_location_id           IN  NUMBER   DEFAULT NULL
,   p_db_flag                       IN  VARCHAR2
);
odab */
/*  Procedure       Validate_And_Write
*/

PROCEDURE Validate_And_Write
(   p_mo_line_rec                   IN  GMI_Move_Order_Global.mo_line_rec
,   x_return_status                 OUT NOCOPY VARCHAR2
,   x_msg_count                     OUT NOCOPY NUMBER
,   x_msg_data                      OUT NOCOPY VARCHAR2
);

/*  Procedure       Delete_Row
*/
/* odab

PROCEDURE Delete_Row
(   x_return_status                 OUT NOCOPY VARCHAR2
,   x_msg_count                     OUT NOCOPY NUMBER
,   x_msg_data                      OUT NOCOPY VARCHAR2
,   p_line_id                       IN  NUMBER
);
*/
/*  Procedure       Process_Entity
*/
/*
PROCEDURE Process_Entity
(   x_return_status                 OUT NOCOPY VARCHAR2
,   x_msg_count                     OUT NOCOPY NUMBER
,   x_msg_data                      OUT NOCOPY VARCHAR2
);
*/
/*  Procedure       lock_Row
*/
/* odab */
PROCEDURE Lock_Row
(   p_mo_line_rec                   IN  GMI_Move_Order_Global.mo_line_rec
,   p_init_msg_list                 IN  NUMBER
,   x_return_status                 OUT NOCOPY VARCHAR2
,   x_msg_count                     OUT NOCOPY NUMBER
,   x_msg_data                      OUT NOCOPY VARCHAR2
);

END GMI_TO_Form_Trolin;

 

/
