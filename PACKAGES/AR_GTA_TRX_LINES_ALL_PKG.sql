--------------------------------------------------------
--  DDL for Package AR_GTA_TRX_LINES_ALL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_GTA_TRX_LINES_ALL_PKG" AUTHID CURRENT_USER AS
--$Header: ARGUGLAS.pls 120.0.12010000.3 2010/01/19 09:16:22 choli noship $
--+=======================================================================+
--|               Copyright (c) 2005 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|     ARUGLAS.pls                                                      |
--|                                                                       |
--| DESCRIPTION                                                           |
--|      This package provides table handers for                          |
--|      table AR_GTA_TRX_LINES_ALL,these handlers                     |
--|      will be called by 'Golden Tax Workbench' form and 'Golden Tax    |
--|      invoie import' program to operate data in table                  |
--|      AR_GTA_TRX_LINES_ALL                                          |
--|                                                                       |
--| HISTORY                                                               |
--|     05/17/05 Donghai Wang       Created                               |
--|     06/18/07 Donghai Wang       Update G_MODULE_PREFIX to follow      |
--|                                 FND log standard
--|     16/Jun/2009 Yao Zhang  Modified for bug#8605196. Add new parameter|
--|                            for procedure insert_row to support discount line|
--|     20/Jun/2009 Yao Zhang Add procedure Query_Row to query trx lines|
--+======================================================================*/

--Declare global variable for package name
G_MODULE_PREFIX VARCHAR2(50) :='ar.plsql.AR_GTA_TRX_LINES_ALL_PKG';

--==========================================================================
--  PROCEDURE NAME:
--
--    Insert_Row                        Public
--
--  DESCRIPTION:
--
--    This procedure is to insert data that are passed in by parameters into
--    table AR_GTA_TRX_LINES_ALL to create a new record
--
--  PARAMETERS:
--      In:  p_org_id                   Identifier of operating unit
--           p_gta_trx_header_id        Identifier of GTA invoice header
--           p_gta_trx_line_id          Identifier of GTA invoice line
--           p_matched_flag             A flag to identify if a GT line
--                                      can match GTA line
--           p_line_number              Line number
--           p_ar_trx_line_id	          Identifier of AR transaction lines
--           p_inventory_item_id        Identifier of Item
--           p_item_number              Item number
--           p_item_description	        Item description
--           p_item_model               Item Model
--           p_item_tax_denomination    Tax denomination for a item
--           p_tax_rate                 Tax rate
--           p_uom                      Unit of measure
--           p_uom_name                 Name for unit of measure
--           p_quantity                 Quantity
--           p_price_flag               Flag to identify if unit procie with tax
--           p_unit_price               Unit price without tax
--           p_unit_tax_price           Unit price with tax
--           p_amount                   Amount without tax
--           p_original_currency_amount Amount without tax in original
--                                      curency code of invoice
--           p_tax_amount               Amount with tax
--           p_discount_flag            A flag to identify amount of
--                                      invoice line with discount or not
--           p_enabled_flag             A flag to indicate if the line should
--                                      be imported to GT system
--           p_request_id               Conc request id
--           p_program_application_id   Program application id
--           p_program_id               Program id
--           p_program_update_date      Program update date
--           p_attribute_category       Attribute category of
--                                      descriptive flexfield
--           p_attribute1               Attribute1
--           p_attribute2               Attribute2
--           p_attribute3               Attribute3
--           p_attribute4               Attribute4
--           p_attribute5               Attribute5
--           p_attribute6               Attribute6
--           p_attribute7               Attribute7
--           p_attribute8               Attribute8
--           p_attribute9               Attribute9
--           p_attribute10              Attribute10
--           p_attribute11              Attribute11
--           p_attribute12              Attribute12
--           p_attribute13              Attribute13
--           p_attribute14              Attribute14
--           p_attribute15              Attribute15
--           p_creation_date            Creation date
--           p_created_by               Identifier of user that creates
--                                      the record
--           p_last_update_date         Last update date of the record
--           p_last_updated_by          Last update by
--           p_last_update_login        Last update login
--           p_discount_amount          discount amount
--           p_discount_tax_amount      discount tax amount
--           p_discount_rate            discount rate
--
--   In Out: p_row_id                   Row id of a table record
--
--
--  DESIGN REFERENCES:
--    GTA_Workbench_Form_TD.doc
--
--  CHANGE HISTORY:
--
--           17-MAY-2005	Donghai Wang created
--           16-Jun-2009 Yao Zhang    Modified for bug#8605196 to support discount line
--                                    Add new parameter to procedure Insert_Row
--===========================================================================
PROCEDURE Insert_Row
(p_rowid                         IN  OUT NOCOPY VARCHAR2
,p_org_id                        IN  NUMBER
,p_gta_trx_header_id             IN  NUMBER
,p_gta_trx_line_id               IN  NUMBER
,p_matched_flag                  IN  VARCHAR2
,p_line_number                   IN  VARCHAR2
,p_ar_trx_line_id                IN  NUMBER
,p_inventory_item_id             IN  NUMBER
,p_item_number                   IN  VARCHAR2
,p_item_description              IN  VARCHAR2
,p_item_model                    IN  VARCHAR2
,p_item_tax_denomination         IN  VARCHAR2
,p_tax_rate                      IN  NUMBER
,p_uom                           IN  VARCHAR2
,p_uom_name                      IN  VARCHAR2
,p_quantity                      IN  NUMBER
,p_price_flag                    IN  VARCHAR2
,p_unit_price                    IN  NUMBER
,p_unit_tax_price                IN  NUMBER
,p_amount                        IN  NUMBER
,p_original_currency_amount      IN  NUMBER
,p_tax_amount                    IN  NUMBER
,p_discount_flag                 IN  VARCHAR2
,p_enabled_flag                  IN  VARCHAR2
,p_request_id                    IN  NUMBER
,p_program_application_id        IN  NUMBER
,p_program_id                    IN  NUMBER
,p_program_update_date           IN  DATE
,p_attribute_category            IN  VARCHAR2
,p_attribute1                    IN  VARCHAR2
,p_attribute2                    IN  VARCHAR2
,p_attribute3                    IN  VARCHAR2
,p_attribute4                    IN  VARCHAR2
,p_attribute5                    IN  VARCHAR2
,p_attribute6                    IN  VARCHAR2
,p_attribute7                    IN  VARCHAR2
,p_attribute8                    IN  VARCHAR2
,p_attribute9                    IN  VARCHAR2
,p_attribute10                   IN  VARCHAR2
,p_attribute11                   IN  VARCHAR2
,p_attribute12                   IN  VARCHAR2
,p_attribute13                   IN  VARCHAR2
,p_attribute14                   IN  VARCHAR2
,p_attribute15                   IN  VARCHAR2
,p_creation_date                 IN  DATE
,p_created_by                    IN  NUMBER
,p_last_update_date              IN  DATE
,p_last_updated_by               IN  NUMBER
,p_last_update_login             IN  NUMBER
--Yao Zhang add for bug#8605196 to support discount line
,p_discount_amount               IN  NUMBER
,p_discount_tax_amount           IN  NUMBER
,p_discount_rate                 IN  NUMBER
);

--==========================================================================
--  PROCEDURE NAME:
--
--    Update_Row                        Public
--
--  DESCRIPTION:
--
--    This procedure is used to update data in table AR_GTA_TRX_LINES_ALL
--    according to parameters passed in
--
--  PARAMETERS:
--      In:  p_org_id                   Identifier of operating unit
--           p_gta_trx_header_id        Identifier of GTA invoice header
--           p_gta_trx_line_id          Identifier of GTA invoice line
--           p_line_number              Line number
--           p_item_number              Item number
--           p_item_description	        Item description
--           p_item_model               Item Model
--           p_item_tax_denomination    Tax denomination for a item
--           p_tax_rate                 Tax rate
--           p_uom_name                 Name for unit of measure
--           p_quantity                 Quantity
--           p_unit_price               Unit price without tax
--           p_amount                   Amount without tax
--           p_original_currency_amount Amount without tax in original
--                                      curency code of invoice
--           p_enabled_flag             A flag to indicate if the line should
--                                      be imported to GT system
--           p_request_id               Conc request id
--           p_program_application_id   Program application id
--           p_program_id               Program id
--           p_program_update_date      Program update date
--           p_attribute_category       Attribute category of
--                                      descriptive flexfield
--           p_attribute1               Attribute1
--           p_attribute2               Attribute2
--           p_attribute3               Attribute3
--           p_attribute4               Attribute4
--           p_attribute5               Attribute5
--           p_attribute6               Attribute6
--           p_attribute7               Attribute7
--           p_attribute8               Attribute8
--           p_attribute9               Attribute9
--           p_attribute10              Attribute10
--           p_attribute11              Attribute11
--           p_attribute12              Attribute12
--           p_attribute13              Attribute13
--           p_attribute14              Attribute14
--           p_attribute15              Attribute15
--           p_creation_date            Creation date
--           p_created_by               Identifier of user that creates
--                                      the record
--           p_last_update_date         Last update date of the record
--           p_last_updated_by          Last update by
--           p_last_update_login        Last update login
--
--   In Out: p_row_id                   Row id of a table record
--
--
--  DESIGN REFERENCES:
--    GTA_Workbench_Form_TD.doc
--
--  CHANGE HISTORY:
--
--           17-MAY-2005	Donghai Wang created
--
--===========================================================================
PROCEDURE Update_Row
(p_rowid                         IN  OUT NOCOPY VARCHAR2
,p_org_id       	         IN  NUMBER
,p_gta_trx_header_id	         IN  NUMBER
,p_gta_trx_line_id	         IN  NUMBER
,p_line_number  	         IN  VARCHAR2
,p_item_number                   IN  VARCHAR2
,p_item_description	         IN  VARCHAR2
,p_item_model                    IN  VARCHAR2
,p_item_tax_denomination	 IN  VARCHAR2
,p_tax_rate     	         IN  NUMBER
,p_uom_name     	         IN  VARCHAR2
,p_quantity     	         IN  NUMBER
,p_unit_price   	         IN  NUMBER
,p_amount       	         IN  NUMBER
,p_original_currency_amount	 IN  NUMBER
,p_enabled_flag 	         IN  VARCHAR2
,p_request_id   	         IN  NUMBER
,p_program_application_id	 IN  NUMBER
,p_program_id   	         IN  NUMBER
,p_program_update_date	         IN  DATE
,p_attribute_category	         IN  VARCHAR2
,p_attribute1   	         IN  VARCHAR2
,p_attribute2   	         IN  VARCHAR2
,p_attribute3   	         IN  VARCHAR2
,p_attribute4   	         IN  VARCHAR2
,p_attribute5   	         IN  VARCHAR2
,p_attribute6   	         IN  VARCHAR2
,p_attribute7   	         IN  VARCHAR2
,p_attribute8   	         IN  VARCHAR2
,p_attribute9   	         IN  VARCHAR2
,p_attribute10  	         IN  VARCHAR2
,p_attribute11  	         IN  VARCHAR2
,p_attribute12  	         IN  VARCHAR2
,p_attribute13  	         IN  VARCHAR2
,p_attribute14  	         IN  VARCHAR2
,p_attribute15  	         IN  VARCHAR2
,p_creation_date                 IN  DATE
,p_created_by                    IN  NUMBER
,p_last_update_date              IN  DATE
,p_last_updated_by               IN  NUMBER
,p_last_update_login             IN  NUMBER
);


--==========================================================================
--  PROCEDURE NAME:
--
--    Lock_Row                        Public
--
--  DESCRIPTION:
--
--    This procedure is used to update implement lock on row level on table
--    AR_GTA_TRX_LINES_ALL
--
--  PARAMETERS:
--      In:  p_org_id                   Identifier of operating unit
--           p_gta_trx_header_id        Identifier of GTA invoice header
--           p_gta_trx_line_id          Identifier of GTA invoice line
--           p_line_number              Line number
--           p_item_number              Item number
--           p_item_description	        Item description
--           p_item_model               Item Model
--           p_item_tax_denomination    Tax denomination for a item
--           p_tax_rate                 Tax rate
--           p_uom_name                 Name for unit of measure
--           p_quantity                 Quantity
--           p_unit_price               Unit price without tax
--           p_amount                   Amount without tax
--           p_original_currency_amount Amount without tax in original
--                                      curency code of invoice
--           p_enabled_flag             A flag to indicate if the line should
--                                      be imported to GT system
--           p_request_id               Conc request id
--           p_program_application_id   Program application id
--           p_program_id               Program id
--           p_program_update_date      Program update date
--           p_attribute_category       Attribute category of
--                                      descriptive flexfield
--           p_attribute1               Attribute1
--           p_attribute2               Attribute2
--           p_attribute3               Attribute3
--           p_attribute4               Attribute4
--           p_attribute5               Attribute5
--           p_attribute6               Attribute6
--           p_attribute7               Attribute7
--           p_attribute8               Attribute8
--           p_attribute9               Attribute9
--           p_attribute10              Attribute10
--           p_attribute11              Attribute11
--           p_attribute12              Attribute12
--           p_attribute13              Attribute13
--           p_attribute14              Attribute14
--           p_attribute15              Attribute15
--           p_creation_date            Creation date
--           p_created_by               Identifier of user that creates
--                                      the record
--           p_last_update_date         Last update date of the record
--           p_last_updated_by          Last update by
--           p_last_update_login        Last update login
--
--   In Out: p_row_id                   Row id of a table record
--
--
--  DESIGN REFERENCES:
--    GTA_Workbench_Form_TD.doc
--
--  CHANGE HISTORY:
--
--           17-MAY-2005	Donghai Wang created
--
--=========================================================================
PROCEDURE Lock_Row
(p_rowid                         IN  OUT NOCOPY VARCHAR2
,p_org_id       	         IN  NUMBER
,p_gta_trx_header_id	         IN  NUMBER
,p_gta_trx_line_id	         IN  NUMBER
,p_line_number  	         IN  VARCHAR2
,p_item_number                   IN  VARCHAR2
,p_item_description	         IN  VARCHAR2
,p_item_model                    IN  VARCHAR2
,p_item_tax_denomination	 IN  VARCHAR2
,p_tax_rate     	         IN  NUMBER
,p_uom_name     	         IN  VARCHAR2
,p_quantity     	         IN  NUMBER
,p_unit_price   	         IN  NUMBER
,p_amount       	         IN  NUMBER
,p_original_currency_amount	 IN  NUMBER
,p_enabled_flag 	         IN  VARCHAR2
,p_request_id   	         IN  NUMBER
,p_program_application_id	 IN  NUMBER
,p_program_id   	         IN  NUMBER
,p_program_update_date	         IN  DATE
,p_attribute_category	         IN  VARCHAR2
,p_attribute1   	         IN  VARCHAR2
,p_attribute2   	         IN  VARCHAR2
,p_attribute3   	         IN  VARCHAR2
,p_attribute4   	         IN  VARCHAR2
,p_attribute5   	         IN  VARCHAR2
,p_attribute6   	         IN  VARCHAR2
,p_attribute7   	         IN  VARCHAR2
,p_attribute8   	         IN  VARCHAR2
,p_attribute9   	         IN  VARCHAR2
,p_attribute10  	         IN  VARCHAR2
,p_attribute11  	         IN  VARCHAR2
,p_attribute12  	         IN  VARCHAR2
,p_attribute13  	         IN  VARCHAR2
,p_attribute14  	         IN  VARCHAR2
,p_attribute15  	         IN  VARCHAR2
,p_creation_date                 IN  DATE
,p_created_by                    IN  NUMBER
,p_last_update_date              IN  DATE
,p_last_updated_by               IN  NUMBER
,p_last_update_login             IN  NUMBER
);

--==========================================================================
--  PROCEDURE NAME:
--
--    Delete_Row                        Public
--
--  DESCRIPTION:
--
--    This procedure is used to delete record from table
--    AR_GTA_TRX_LINES_ALL
--
--  PARAMETERS:
--
--      In Out:  p_row_id                   Row id of a table record
--
--
--  DESIGN REFERENCES:
--    GTA_Workbench_Form_TD.doc
--
--  CHANGE HISTORY:
--
--           17-MAY-2005	Donghai Wang created
--
--===========================================================================
PROCEDURE Delete_Row
(p_rowid                         IN OUT NOCOPY VARCHAR2
);
--==========================================================================
--  PROCEDURE NAME:
--
--      Query_Row                       Public
--
--  DESCRIPTION:
--
--    This procedure is used to retrieve record by parameter p_header
--    from table AR_GTA_TRX_LINES_ALL
--
--  PARAMETERS:
--      In:   p_trx_line_id                Identifier of GTA invoice header
--
--      Out:  x_trx_line_rec         trx_line_rec_type  record to store a row fetched from
--                                   table AR_GTA_TRX_HEADERS_ALL
--  DESIGN REFERENCES:
--    GTA_12.1.2_Technical_Design.doc
--
--  CHANGE HISTORY:
--
--           30-Jun-2009	Yao Zhang created
--===========================================================================
PROCEDURE Query_Row
(p_trx_line_id  IN NUMBER
,x_trx_line_rec OUT NOCOPY AR_GTA_TRX_UTIL.Trx_Line_Rec_Type
);
END AR_GTA_TRX_LINES_ALL_PKG;


/
