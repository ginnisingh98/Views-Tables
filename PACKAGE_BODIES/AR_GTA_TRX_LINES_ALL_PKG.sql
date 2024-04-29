--------------------------------------------------------
--  DDL for Package Body AR_GTA_TRX_LINES_ALL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_GTA_TRX_LINES_ALL_PKG" AS
--$Header: ARGUGLAB.pls 120.0.12010000.3 2010/01/19 09:22:24 choli noship $
--+=======================================================================+
--|               Copyright (c) 1998 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|     ARUGLAB.pls                                                      |
--|                                                                       |
--| DESCRIPTION                                                           |
--|      This package provides table handers for                          |
--|      table AR_GTA_TRX_LINES_ALL,these handlers                       |
--|      will be called by 'Golden Tax Workbench' form and 'Golden Tax    |
--|      invoie import' program to operate data in table                  |
--|      AR_GTA_TRX_LINES_ALL                                            |
--|                                                                       |
--| PROCEDURE LIST                                                        |
--|      PROCEDURE Insert_Row                                             |
--|      PROCEDURE Update_Row                                             |
--|      PROCEDURE Lock_Row                                               |
--|      PROCEDURE Delete_Row                                             |
--|                                                                       |
--| HISTORY                                                               |
--|     05/17/05 Donghai Wang    Created                                  |
--|     10/19/05 Donghai Wang    Update the procedure Lock_Row
--|     16/Jun/2009 Yao Zhang    Modified for bug#8605196 to support discount line|
--|     20/Jul/2009 yao Zhang    Add new procedure query_row to query trx lines.
--|     21/Aug/2009 Allen Yang   Modified procedure Lock_Row for bug      |
--|                              8670529 (related 12.0.6 bug: 8663110)    |
--+======================================================================*/

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
--           16-Jun-2009   Yao Zhang Fix bug#8605196 ENHANCEMENT FOR GOLDEN TAX ADAPTER R12.1.2
--                                                          ER1 Support discount lines
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
)
IS
l_procedure_name    VARCHAR2(100)   :='Insert_Row';
l_dbg_level         NUMBER          :=FND_LOG.G_Current_Runtime_Level;
l_proc_level        NUMBER          :=FND_LOG.Level_Procedure;
CURSOR C IS
SELECT
  ROWID
FROM
  ar_gta_trx_lines_all
WHERE gta_trx_line_id=p_gta_trx_line_id;

BEGIN

 --log for debug
  IF( l_proc_level >= l_dbg_level)
  THEN

    FND_LOG.String(l_proc_level
                  ,G_MODULE_PREFIX||'.'||l_procedure_name||'.begin'
                  ,'Enter procedure'
                  );

  END IF;  --( l_proc_level >= l_dbg_level)

  --Insert data into table AR_GTA_TRX_LINES_ALL
  INSERT INTO ar_gta_trx_lines_all(
     org_id
    ,gta_trx_header_id
    ,gta_trx_line_id
    ,matched_flag
    ,line_number
    ,ar_trx_line_id
    ,inventory_item_id
    ,item_number
    ,item_description
    ,item_model
    ,item_tax_denomination
    ,tax_rate
    ,uom
    ,uom_name
    ,quantity
    ,price_flag
    ,unit_price
    ,unit_tax_price
    ,amount
    ,original_currency_amount
    ,tax_amount
    ,discount_flag
    ,enabled_flag
    ,request_id
    ,program_application_id
    ,program_id
    ,program_update_date
    ,attribute_category
    ,attribute1
    ,attribute2
    ,attribute3
    ,attribute4
    ,attribute5
    ,attribute6
    ,attribute7
    ,attribute8
    ,attribute9
    ,attribute10
    ,attribute11
    ,attribute12
    ,attribute13
    ,attribute14
    ,attribute15
    ,creation_date
    ,created_by
    ,last_update_date
    ,last_updated_by
    ,last_update_login
    --yao zhang add for bug#8605196 to support discount line
    ,discount_amount
    ,discount_tax_amount
    ,discount_rate
    )
  VALUES(
     p_org_id
    ,p_gta_trx_header_id
    ,p_gta_trx_line_id
    ,p_matched_flag
    ,p_line_number
    ,p_ar_trx_line_id
    ,p_inventory_item_id
    ,p_item_number
    ,p_item_description
    ,p_item_model
    ,p_item_tax_denomination
    ,p_tax_rate
    ,p_uom
    ,p_uom_name
    ,p_quantity
    ,p_price_flag
    ,p_unit_price
    ,p_unit_tax_price
    ,p_amount
    ,p_original_currency_amount
    ,p_tax_amount
    ,p_discount_flag
    ,p_enabled_flag
    ,p_request_id
    ,p_program_application_id
    ,p_program_id
    ,p_program_update_date
    ,p_attribute_category
    ,p_attribute1
    ,p_attribute2
    ,p_attribute3
    ,p_attribute4
    ,p_attribute5
    ,p_attribute6
    ,p_attribute7
    ,p_attribute8
    ,p_attribute9
    ,p_attribute10
    ,p_attribute11
    ,p_attribute12
    ,p_attribute13
    ,p_attribute14
    ,p_attribute15
    ,p_creation_date
    ,p_created_by
    ,p_last_update_date
    ,p_last_updated_by
    ,p_last_update_login
    --yao zhang add for bug#8605196 to support discount line
    ,p_discount_amount
    ,p_discount_tax_amount
    ,p_discount_rate
    );

  --In case of insert failed, raise error
  OPEN c;
  FETCH c INTO p_rowid;
  IF (c%NOTFOUND)
  THEN
    CLOSE c;
    RAISE NO_DATA_FOUND;
  END IF;  --(c%NOTFOUND)
  CLOSE C;
--The following code is add by Yao Zhang for exception handle
EXCEPTION
 WHEN OTHERS THEN
  fnd_file.PUT_LINE(fnd_file.LOG,'Exception from insert row'||SQLCODE || SQLERRM);
     IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.String(FND_LOG.LEVEL_UNEXPECTED,
                     G_MODULE_PREFIX || l_procedure_name ||
                     '. OTHER_EXCEPTION ',
                     'Unknown error' || SQLCODE || SQLERRM);

    END IF;
   RAISE;
 --log for debug
  IF( l_proc_level >= l_dbg_level)
  THEN

    FND_LOG.String(l_proc_level
                  ,G_MODULE_PREFIX||'.'||l_procedure_name||'.end'
                  ,'Exit procedure'
                  );

  END IF;  --( l_proc_level >= l_dbg_level)
END Insert_Row;


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
)
IS
l_procedure_name    VARCHAR2(100)   :='Update_Row';
l_dbg_level         NUMBER          :=FND_LOG.G_Current_Runtime_Level;
l_proc_level        NUMBER          :=FND_LOG.Level_Procedure;
BEGIN

 --log for debug
  IF( l_proc_level >= l_dbg_level)
  THEN

    FND_LOG.String(l_proc_level
                  ,G_MODULE_PREFIX||'.'||l_procedure_name||'.begin'
                  ,'Enter procedure'
                  );

  END IF;  --( l_proc_level >= l_dbg_level)

  --Update data on table AR_GTA_TRX_LINES_ALL
  UPDATE ar_gta_trx_lines_all
    SET
      org_id                        =    p_org_id
     ,gta_trx_header_id             =    p_gta_trx_header_id
     ,gta_trx_line_id               =    p_gta_trx_line_id
     ,line_number                   =    p_line_number
     ,item_number                   =    p_item_number
     ,item_description              =    p_item_description
     ,item_model                    =    p_item_model
     ,item_tax_denomination         =    p_item_tax_denomination
     ,tax_rate                      =    p_tax_rate
     ,uom_name                      =    p_uom_name
     ,quantity                      =    p_quantity
     ,unit_price                    =    p_unit_price
     ,amount                        =    p_amount
     ,original_currency_amount      =    p_original_currency_amount
     ,enabled_flag                  =    p_enabled_flag
     ,request_id                    =    p_request_id
     ,program_application_id        =    p_program_application_id
     ,program_id                    =    p_program_id
     ,program_update_date           =    p_program_update_date
     ,attribute_category            =    p_attribute_category
     ,attribute1                    =    p_attribute1
     ,attribute2                    =    p_attribute2
     ,attribute3                    =    p_attribute3
     ,attribute4                    =    p_attribute4
     ,attribute5                    =    p_attribute5
     ,attribute6                    =    p_attribute6
     ,attribute7                    =	 p_attribute7
     ,attribute8                    =    p_attribute8
     ,attribute9                    =    p_attribute9
     ,attribute10                   =    p_attribute10
     ,attribute11                   =    p_attribute11
     ,attribute12                   =    p_attribute12
     ,attribute13                   =    p_attribute13
     ,attribute14                   =    p_attribute14
     ,attribute15                   =    p_attribute15
     ,creation_date                 =    p_creation_date
     ,created_by                    =    p_created_by
     ,last_update_date              =    p_last_update_date
     ,last_updated_by               =    p_last_updated_by
     ,last_update_login             =    p_last_update_login
   WHERE ROWID=p_rowid;

  --In case of update failed, raise error
  IF (SQL%NOTFOUND)
  THEN
    RAISE NO_DATA_FOUND;
  END IF;  --(SQL%NOTFOUND)

 --log for debug
  IF( l_proc_level >= l_dbg_level)
  THEN

    FND_LOG.String(l_proc_level
                  ,G_MODULE_PREFIX||'.'||l_procedure_name||'.end'
                  ,'Exit procedure'
                  );

  END IF;  --( l_proc_level >= l_dbg_level)
END Update_Row;

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
--           19-OCT-2005  Donghai Wang call SQL function 'RTRIM' for columns with
--                                     Varchar2 data datatype to truncate
--                                     tail null character
--           21-Aug-2009  Allen Yang   modified for bug 8670529 (related 12.0.6
--                                     bug: 8663110)
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
)
IS
l_procedure_name    VARCHAR2(100)   :='Lock_Row';
l_dbg_level         NUMBER          :=FND_LOG.G_Current_Runtime_Level;
l_proc_level        NUMBER          :=FND_LOG.Level_Procedure;

CURSOR c IS
SELECT
  *
FROM
  ar_gta_trx_lines_all
WHERE ROWID=p_rowid
 FOR UPDATE OF gta_trx_line_id NOWAIT;

recinfo c%ROWTYPE;
BEGIN

 --log for debug
  IF( l_proc_level >= l_dbg_level)
  THEN

    FND_LOG.String(l_proc_level
                  ,G_MODULE_PREFIX||'.'||l_procedure_name||'.begin'
                  ,'Begin procedure'
                  );

  END IF;  --( l_proc_level >= l_dbg_level)

  --If a record has been deleted as form tries to excute dml operation
  --on that record,then raise error to form
  OPEN c;
  FETCH c INTO recinfo;

  IF (c%NOTFOUND)
  THEN
    CLOSE c;
    FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
    APP_EXCEPTION.Raise_Exception;
  END IF;  --(c%NOTFOUND)

  CLOSE c;


  IF (
    (recinfo.org_id=p_org_id)
       AND
       (recinfo.gta_trx_header_id=p_gta_trx_header_id)
       AND
       (recinfo.gta_trx_line_id=p_gta_trx_line_id)
       AND
       (rtrim(recinfo.line_number)=p_line_number)
       AND
       (
        (rtrim(recinfo.item_number)=p_item_number)
        OR
        (
         (rtrim(recinfo.item_number) IS NULL)
         AND
         (p_item_number IS NULL)
        )
       )
       AND
       (rtrim(recinfo.item_description)=p_item_description)
       AND
       (
        (rtrim(recinfo.item_model)=p_item_model)
        OR
        (
         (rtrim(recinfo.item_model) IS NULL)
         AND
         (p_item_model IS NULL)
        )
       )
       AND
       (rtrim(recinfo.item_tax_denomination)=p_item_tax_denomination)
       AND
       (recinfo.tax_rate=p_tax_rate)
       AND
       (
        -- Modified by Allen Yang for bug 8670529 (related 12.0.6 bug:
        -- 8670529) on 21/Aug/2009
        -------------------------------------------------------------
        --(rtrim(recinfo.uom_name)=p_uom_name)
        (rtrim(recinfo.uom)=p_uom_name)
        OR
        (
         --(rtrim(recinfo.uom_name) IS NULL)
         (rtrim(recinfo.uom) IS NULL)
         AND
         (p_uom_name IS NULL)
        )
        -------------------------------------------------------------
       )
       AND
       (recinfo.quantity=p_quantity)
       AND
       (
        (recinfo.unit_price=p_unit_price)
        OR
        (
         (recinfo.unit_price IS NULL)
         AND
         (p_unit_price IS NULL)
        )
       )
       AND
       (
        (recinfo.amount=p_amount)
        OR
        (
         (recinfo.amount IS NULL)
         AND
         (p_amount IS NULL)
        )
       )
       AND
       (
        (recinfo.original_currency_amount=p_original_currency_amount)
        OR
        (
         (recinfo.original_currency_amount IS NULL)
         AND
         (p_original_currency_amount IS NULL)
        )
       )
      AND
       (
        (rtrim(recinfo.enabled_flag)=p_enabled_flag)
        OR
        (
         (rtrim(recinfo.enabled_flag) IS NULL)
         AND
         (p_enabled_flag IS NULL)
        )
       )
       AND
       (recinfo.created_by=p_created_by)
       AND
       (recinfo.creation_date=p_creation_date)
       AND
       (recinfo.last_update_date=p_last_update_date)
       AND
       (recinfo.last_updated_by=p_last_updated_by)
       AND
       (
        (recinfo.last_update_login=p_last_update_login)
        OR
        (
         (recinfo.last_update_login IS NULL)
         AND
         (p_last_update_login IS NULL)
        )
       )
       AND
       (
        (recinfo.request_id=p_request_id)
        OR
        (
         (recinfo.request_id IS NULL)
         AND
         (p_request_id IS NULL)
        )
       )
       AND
       (
        (recinfo.program_application_id=p_program_application_id)
        OR
        (
         (recinfo.program_application_id IS NULL)
         AND
         (p_program_application_id IS NULL)
        )
       )
       AND
       (
        (recinfo.program_id=p_program_id)
        OR
        (
         (recinfo.program_id IS NULL)
         AND
         (p_program_id IS NULL)
        )
       )
       AND
       (
        (recinfo.program_update_date=p_program_update_date)
        OR
        (
         (recinfo.program_update_date IS NULL)
         AND
         (p_program_update_date IS NULL)
        )
       )
       AND
       (
        (recinfo.attribute_category=p_attribute_category)
        OR
        (
         (recinfo.attribute_category IS NULL)
         AND
         (p_attribute_category IS NULL)
        )
       )
       AND
       (
        (recinfo.attribute1=p_attribute1)
        OR
        (
         (recinfo.attribute1 IS NULL)
         AND
         (p_attribute1 IS NULL)
        )
       )
       AND
       (
        (recinfo.attribute2=p_attribute2)
        OR
        (
         (recinfo.attribute2 IS NULL)
         AND
         (p_attribute2 IS NULL)
        )
       )
       AND
       (
        (recinfo.attribute3=p_attribute3)
        OR
        (
         (recinfo.attribute3 IS NULL)
         AND
         (p_attribute3 IS NULL)
        )
       )
       AND
       (
        (recinfo.attribute4=p_attribute4)
        OR
        (
         (recinfo.attribute4 IS NULL)
         AND
         (p_attribute4 IS NULL)
        )
       )
       AND
       (
        (recinfo.attribute5=p_attribute5)
        OR
        (
         (recinfo.attribute5 IS NULL)
         AND
         (p_attribute5 IS NULL)
        )
       )
       AND
       (
        (recinfo.attribute6=p_attribute6)
        OR
        (
         (recinfo.attribute6 IS NULL)
         AND
         (p_attribute6 IS NULL)
        )
       )
       AND
       (
        (recinfo.attribute7=p_attribute7)
        OR
        (
         (recinfo.attribute7 IS NULL)
         AND
         (p_attribute7 IS NULL)
        )
       )
       AND
       (
        (recinfo.attribute8=p_attribute8)
        OR
        (
         (recinfo.attribute8 IS NULL)
         AND
         (p_attribute8 IS NULL)
        )
       )
       AND
       (
        (recinfo.attribute9=p_attribute9)
        OR
        (
         (recinfo.attribute9 IS NULL)
         AND
         (p_attribute9 IS NULL)
        )
       )
       AND
       (
        (recinfo.attribute10=p_attribute10)
        OR
        (
         (recinfo.attribute10 IS NULL)
         AND
         (p_attribute10 IS NULL)
        )
       )
       AND
       (
        (recinfo.attribute11=p_attribute11)
        OR
        (
         (recinfo.attribute11 IS NULL)
         AND
         (p_attribute11 IS NULL)
        )
       )
       AND
       (
        (recinfo.attribute12=p_attribute12)
        OR
        (
         (recinfo.attribute12 IS NULL)
         AND
         (p_attribute12 IS NULL)
        )
       )
       AND
       (
        (recinfo.attribute13=p_attribute13)
        OR
        (
         (recinfo.attribute13 IS NULL)
         AND
         (p_attribute13 IS NULL)
        )
       )
      AND
       (
        (recinfo.attribute14=p_attribute14)
        OR
        (
         (recinfo.attribute14 IS NULL)
         AND
         (p_attribute14 IS NULL)
        )
       )
       AND
       (
        (recinfo.attribute15=p_attribute15)
        OR
        (
         (recinfo.attribute15 IS NULL)
         AND
         (p_attribute15 IS NULL)
        )
       )
     )

  THEN
     RETURN;
   ELSE
     FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
     APP_EXCEPTION.Raise_Exception;
  END IF;  --((recinfo.org_id=p_org_id)...

   --log for debug
  IF( l_proc_level >= l_dbg_level)
  THEN

    FND_LOG.String(l_proc_level
                  ,G_MODULE_PREFIX||'.'||l_procedure_name||'.end'
                  ,'Exit procedure'
                  );

  END IF;  --( l_proc_level >= l_dbg_level)
END Lock_Row;


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
)
IS
l_procedure_name    VARCHAR2(100)   :='Delete_Row';
l_dbg_level         NUMBER          :=FND_LOG.G_Current_Runtime_Level;
l_proc_level        NUMBER          :=FND_LOG.Level_Procedure;
BEGIN

 --log for debug
  IF( l_proc_level >= l_dbg_level)
  THEN

    FND_LOG.String(l_proc_level
                  ,G_MODULE_PREFIX||'.'||l_procedure_name||'.begin'
                  ,'Begin procedure'
                  );

  END IF;  --( l_proc_level >= l_dbg_level)

  --Delete row from table AR_GTA_TRX_LINES_ALL
  DELETE
  FROM AR_GTA_TRX_LINES_ALL
  WHERE ROWID = p_rowid;

  --In case of delete failed,raise error
  IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;  --(SQL%NOTFOUND)

 --log for debug
  IF( l_proc_level >= l_dbg_level)
  THEN

    FND_LOG.String(l_proc_level
                  ,G_MODULE_PREFIX||'.'||l_procedure_name||'.end'
                  ,'Exit procedure'
                  );

  END IF;  --( l_proc_level >= l_dbg_level)
END Delete_Row;
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
--      In:   p_trx_line_id          Identifier of GTA invoice header
--
--      Out:  x_trx_line_rec         trx_line_rec_type  record to store a row fetched from
--                                   table AR_GTA_TRX_HEADERS_ALL
--  DESIGN REFERENCES:
--    GTA_12.1.2_Technical_Design.doc
--
--  CHANGE HISTORY:
--
--          30-Jun-2009	Yao Zhang created
--===========================================================================
PROCEDURE Query_Row
(p_trx_line_id  IN NUMBER
,x_trx_line_rec OUT NOCOPY AR_GTA_TRX_UTIL.Trx_Line_Rec_Type
)
IS
l_procedure_name    VARCHAR2(100)   :='Query_Row';
l_dbg_level         NUMBER          :=FND_LOG.G_Current_Runtime_Level;
l_proc_level        NUMBER          :=FND_LOG.Level_Procedure;
BEGIN

 --log for debug
  IF( l_proc_level >= l_dbg_level)
  THEN

    FND_LOG.String(l_proc_level
                  ,G_MODULE_PREFIX||'.'||l_procedure_name||'.begin'
                  ,'Begin procedure'
                  );

  END IF;  --( l_proc_level >= l_dbg_level)
  SELECT org_id,
         gta_trx_header_id,
         gta_trx_line_id,
         matched_flag,
         line_number,
         ar_trx_line_id,
         inventory_item_id,
         item_number,
         item_description,
         item_model,
         item_tax_denomination,
         tax_rate,
         uom,
         uom_name,
         quantity,
         price_flag,
         unit_price,
         amount,
         original_currency_amount,
         tax_amount,
         discount_flag,
         enabled_flag,
         attribute_category,
         attribute1,
         attribute2,
         attribute3,
         attribute4,
         attribute5,
         attribute6,
         attribute7,
         attribute8,
         attribute9,
         attribute10,
         attribute11,
         attribute12,
         attribute13,
         attribute14,
         attribute15,
         last_update_date,
         last_updated_by,
         creation_date,
         created_by,
         last_update_login,
         program_id,
         program_application_id,
         program_update_date,
         request_id,
         discount_amount,
         discount_tax_amount,
         discount_rate
    INTO x_trx_line_rec.org_id,
         x_trx_line_rec.gta_trx_header_id,
         x_trx_line_rec.gta_trx_line_id,
         x_trx_line_rec.matched_flag,
         x_trx_line_rec.line_number,
         x_trx_line_rec.ar_trx_line_id,
         x_trx_line_rec.inventory_item_id,
         x_trx_line_rec.item_number,
         x_trx_line_rec.item_description,
         x_trx_line_rec.item_model,
         x_trx_line_rec.item_tax_denomination,
         x_trx_line_rec.tax_rate,
         x_trx_line_rec.uom,
         x_trx_line_rec.uom_name,
         x_trx_line_rec.quantity,
         x_trx_line_rec.price_flag,
         x_trx_line_rec.unit_price,
         x_trx_line_rec.amount,
         x_trx_line_rec.original_currency_amount,
         x_trx_line_rec.tax_amount,
         x_trx_line_rec.discount_flag,
         x_trx_line_rec.enabled_flag,
         x_trx_line_rec.attribute_category,
         x_trx_line_rec.attribute1,
         x_trx_line_rec.attribute2,
         x_trx_line_rec.attribute3,
         x_trx_line_rec.attribute4,
         x_trx_line_rec.attribute5,
         x_trx_line_rec.attribute6,
         x_trx_line_rec.attribute7,
         x_trx_line_rec.attribute8,
         x_trx_line_rec.attribute9,
         x_trx_line_rec.attribute10,
         x_trx_line_rec.attribute11,
         x_trx_line_rec.attribute12,
         x_trx_line_rec.attribute13,
         x_trx_line_rec.attribute14,
         x_trx_line_rec.attribute15,
         x_trx_line_rec.last_update_date,
         x_trx_line_rec.last_updated_by,
         x_trx_line_rec.creation_date,
         x_trx_line_rec.created_by,
         x_trx_line_rec.last_update_login,
         x_trx_line_rec.program_id,
         x_trx_line_rec.program_applicaton_id,
         x_trx_line_rec.program_update_date,
         x_trx_line_rec.request_id,
         x_trx_line_rec.discount_amount,
         x_trx_line_rec.discount_tax_amount,
         x_trx_line_rec.discount_rate
    FROM ar_gta_trx_lines_all
   WHERE gta_trx_line_id = p_trx_line_id;
  --log for debug
  IF( l_proc_level >= l_dbg_level)
  THEN

    FND_LOG.String(l_proc_level
                  ,G_MODULE_PREFIX||'.'||l_procedure_name||'.end'
                  ,'Exit procedure'
                  );

  END IF;  --( l_proc_level >= l_dbg_level)
END Query_Row;

END AR_GTA_TRX_LINES_ALL_PKG;

/
