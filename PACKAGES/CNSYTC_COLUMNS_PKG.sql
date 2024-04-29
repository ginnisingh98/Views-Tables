--------------------------------------------------------
--  DDL for Package CNSYTC_COLUMNS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CNSYTC_COLUMNS_PKG" AUTHID CURRENT_USER AS
  -- $Header: cnsytccs.pls 115.1 99/07/16 07:18:59 porting ship $


--
-- Procedure Name
--   Populate_Fields
-- History
-- 08-06-95     Amy Erickson            Created

PROCEDURE Populate_fields (x_column_id              number,
                           x_dimension_id           number,
                           x_dimension_name IN OUT  varchar2) ;

--
-- Procedure Name
--   Default_Row  (used by BOTH Tables and Columns)
-- History
-- 08-06-95     Amy Erickson            Created

PROCEDURE Default_Row (x_object_id   IN OUT  number) ;


--
-- Procedure Name
--   Check_Table_Name
-- History
-- 08-06-95     Amy Erickson            Created

FUNCTION Check_Table_Name (x_name    varchar2,
                           x_schema  varchar2) RETURN number ;


--
-- Procedure Name
--   Check_Column_Name
-- History
-- 08-06-95     Amy Erickson            Created

FUNCTION Check_Column_Name (x_name      varchar2,
                            x_table_id  number  ) RETURN number ;


END cnsytc_columns_pkg;

 

/
