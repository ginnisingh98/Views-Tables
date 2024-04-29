--------------------------------------------------------
--  DDL for Package INV_TO_FORM_TROHDR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_TO_FORM_TROHDR" AUTHID CURRENT_USER AS
/* $Header: INVFTRHS.pls 120.1 2005/06/17 14:21:13 appldev  $ */

--  Procedure : Default_Attributes
--

PROCEDURE Default_Attributes
(   x_return_status                 OUT NOCOPY VARCHAR2
,   x_msg_count                     OUT NOCOPY NUMBER
,   x_msg_data                      OUT NOCOPY VARCHAR2
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
,   x_description                   OUT NOCOPY VARCHAR2
,   x_from_subinventory_code        OUT NOCOPY VARCHAR2
,   x_header_id                     OUT NOCOPY NUMBER
,   x_header_status                 OUT NOCOPY NUMBER
,   x_organization_id               OUT NOCOPY NUMBER
,   x_request_number                OUT NOCOPY VARCHAR2
,   x_status_date                   OUT NOCOPY DATE
,   x_to_account_id                 OUT NOCOPY NUMBER
,   x_to_subinventory_code          OUT NOCOPY VARCHAR2
,   x_move_order_type               OUT NOCOPY NUMBER
,   x_from_subinventory             OUT NOCOPY VARCHAR2
,   x_header                        OUT NOCOPY VARCHAR2
,   x_organization                  OUT NOCOPY VARCHAR2
,   x_to_account                    OUT NOCOPY VARCHAR2
,   x_to_subinventory               OUT NOCOPY VARCHAR2
,   x_move_order_type_name          OUT NOCOPY VARCHAR2
,   x_transaction_type_id	    OUT NOCOPY NUMBER
,   x_ship_to_location_id           OUT NOCOPY NUMBER
);

--  Procedure   :   Change_Attribute
--

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
,   p_description                   IN  VARCHAR2
,   p_from_subinventory_code        IN  VARCHAR2
,   p_header_id                     IN  NUMBER
,   p_header_status                 IN  NUMBER
,   p_organization_id               IN  NUMBER
,   p_request_number                IN  VARCHAR2
,   p_status_date                   IN  DATE
,   p_to_account_id                 IN  NUMBER
,   p_to_subinventory_code          IN  VARCHAR2
,   p_move_order_type               IN  NUMBER
,   p_transaction_type_id	    IN  NUMBER
,   p_ship_to_location_id           IN  NUMBER
,   p_db_flag                       IN  VARCHAR2
);

--  Procedure       Validate_And_Write
--

PROCEDURE Validate_And_Write
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
,   p_description                   IN  VARCHAR2
,   p_from_subinventory_code        IN  VARCHAR2
,   p_header_id                     IN  NUMBER
,   p_header_status                 IN  NUMBER
,   p_organization_id               IN  NUMBER
,   p_request_number                IN  VARCHAR2
,   p_status_date                   IN  DATE
,   p_to_account_id                 IN  NUMBER
,   p_to_subinventory_code          IN  VARCHAR2
,   p_move_order_type	            IN  NUMBER
,   p_transaction_type_id	    IN  NUMBER
,   p_ship_to_location_id           IN  NUMBER
,   p_db_flag                       IN  VARCHAR2
,   x_creation_date                 OUT NOCOPY DATE
,   x_created_by                    OUT NOCOPY NUMBER
,   x_last_update_date              OUT NOCOPY DATE
,   x_last_updated_by               OUT NOCOPY NUMBER
,   x_last_update_login             OUT NOCOPY NUMBER
);

--  Procedure       Delete_Row
--

PROCEDURE Delete_Row
(   x_return_status                 OUT NOCOPY VARCHAR2
,   x_msg_count                     OUT NOCOPY NUMBER
,   x_msg_data                      OUT NOCOPY VARCHAR2
,   p_header_id                     IN  NUMBER
);

--  Procedure       Process_Entity
--

PROCEDURE Process_Entity
(   x_return_status                 OUT NOCOPY VARCHAR2
,   x_msg_count                     OUT NOCOPY NUMBER
,   x_msg_data                      OUT NOCOPY VARCHAR2
);

--  Procedure       Process_Object
--

PROCEDURE Process_Object
(   x_return_status                 OUT NOCOPY VARCHAR2
,   x_msg_count                     OUT NOCOPY NUMBER
,   x_msg_data                      OUT NOCOPY VARCHAR2
);

--  Procedure       lock_Row
--

PROCEDURE Lock_Row
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
,   p_created_by                    IN  NUMBER
,   p_creation_date                 IN  DATE
,   p_date_required                 IN  DATE
,   p_description                   IN  VARCHAR2
,   p_from_subinventory_code        IN  VARCHAR2
,   p_header_id                     IN  NUMBER
,   p_header_status                 IN  NUMBER
,   p_last_updated_by               IN  NUMBER
,   p_last_update_date              IN  DATE
,   p_last_update_login             IN  NUMBER
,   p_organization_id               IN  NUMBER
,   p_program_application_id        IN  NUMBER
,   p_program_id                    IN  NUMBER
,   p_program_update_date           IN  DATE
,   p_request_id                    IN  NUMBER
,   p_request_number                IN  VARCHAR2
,   p_status_date                   IN  DATE
,   p_to_account_id                 IN  NUMBER
,   p_to_subinventory_code          IN  VARCHAR2
,   p_move_order_type	            IN  NUMBER
,   p_transaction_type_id	    IN  NUMBER
,   p_ship_to_location_id           IN  NUMBER
);

END INV_TO_Form_Trohdr;

 

/
