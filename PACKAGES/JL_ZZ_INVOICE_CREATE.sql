--------------------------------------------------------
--  DDL for Package JL_ZZ_INVOICE_CREATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JL_ZZ_INVOICE_CREATE" AUTHID CURRENT_USER as
/* $Header: jlzzrics.pls 120.0 2004/01/31 01:57:42 appradha ship $ */

/*----------------------------------------------------------------------------*
 |   PUBLIC FUNCTIONS/PROCEDURES  					      |
 *----------------------------------------------------------------------------*/

/*----------------------------------------------------------------------------*
 | FUNCTION                                                                   |
 |    validate_gdf_inv_api                                                    |
 |                                                                            |
 | DESCRIPTION                                                                |
 |                                                                            |
 | PARAMETERS                                                                 |
 |   INPUT                                                                    |
 |      p_request_id            Number   -- Concurrent Request id             |
 |                                                                            |
 |   RETURNS                                                                  |
 |      0                       Number   -- Validations Failed                |
 |      1                       Number   -- Validation Succeeded              |
 |                                                                            |
 | HISTORY                                                                    |
 |    30-JAN-2004 Amit Pradhan     Made a new package valdiate_inv_create_api |
 |                                                                            |
 *----------------------------------------------------------------------------*/

  TYPE varchar2_150_tbl_type is Table of Varchar2(150) index by binary_integer;
  TYPE varchar2_50_tbl_type is Table of Varchar2(50) index by binary_integer;
  TYPE varchar2_20_tbl_type is Table of Varchar2(50) index by binary_integer;
  TYPE number_tbl_type  is Table of Number index by binary_integer;
  TYPE date_tbl_type is Table of Date index by binary_integer;

  Type R_interface_line is RECORD
  (
   interface_line_id      Number_tbl_type,
   cust_trx_type_id       Number_tbl_type,
   trx_date               date_tbl_type,
   orig_system_address_id Number_tbl_type,
   line_type              Varchar2_150_tbl_type,
   memo_line_id           Number_tbl_type,
   Inventory_item_id      Number_tbl_type,
   header_gdf_attribute1  Varchar2_150_tbl_type,
   header_gdf_attribute2  Varchar2_150_tbl_type,
   header_gdf_attribute3  Varchar2_150_tbl_type,
   header_gdf_attribute4  Varchar2_150_tbl_type,
   header_gdf_attribute5  Varchar2_150_tbl_type,
   header_gdf_attribute6  Varchar2_150_tbl_type,
   header_gdf_attribute7  Varchar2_150_tbl_type,
   header_gdf_attribute8  Varchar2_150_tbl_type,
   header_gdf_attribute9  Varchar2_150_tbl_type,
   header_gdf_attribute10 Varchar2_150_tbl_type,
   header_gdf_attribute11 Varchar2_150_tbl_type,
   header_gdf_attribute12 Varchar2_150_tbl_type,
   header_gdf_attribute13 Varchar2_150_tbl_type,
   header_gdf_attribute14 Varchar2_150_tbl_type,
   header_gdf_attribute15 Varchar2_150_tbl_type,
   header_gdf_attribute16 Varchar2_150_tbl_type,
   header_gdf_attribute17 Varchar2_150_tbl_type,
   line_gdf_attribute1    Varchar2_150_tbl_type,
   line_gdf_attribute2    Varchar2_150_tbl_type,
   line_gdf_attribute3    Varchar2_150_tbl_type,
   line_gdf_attribute4    Varchar2_150_tbl_type,
   line_gdf_attribute5    Varchar2_150_tbl_type,
   line_gdf_attribute6    Varchar2_150_tbl_type,
   line_gdf_attribute7    Varchar2_150_tbl_type,
   line_gdf_attribute8    Varchar2_150_tbl_type,
   line_gdf_attribute9    Varchar2_150_tbl_type,
   line_gdf_attribute10   Varchar2_150_tbl_type,
   line_gdf_attribute11   Varchar2_150_tbl_type,
   line_gdf_attribute12   Varchar2_150_tbl_type,
   warehouse_id           Number_tbl_type,
   batch_source_name      Varchar2_50_tbl_type,
   trx_number             Varchar2_20_tbl_type
   );

  FUNCTION validate_gdf_inv_api (p_request_id  IN NUMBER) RETURN NUMBER;

END JL_ZZ_INVOICE_CREATE;

 

/
