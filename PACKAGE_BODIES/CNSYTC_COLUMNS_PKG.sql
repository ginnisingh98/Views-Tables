--------------------------------------------------------
--  DDL for Package Body CNSYTC_COLUMNS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CNSYTC_COLUMNS_PKG" AS
-- $Header: cnsytccb.pls 115.1 99/07/16 07:18:56 porting ship $


--
-- Procedure Name
--   Populate_Fields
-- History
-- 08-06-95     Amy Erickson            Created

PROCEDURE Populate_fields (x_column_id              number,
                           x_dimension_id           number,
                           x_dimension_name IN OUT  varchar2) IS
  BEGIN

    if (x_dimension_id IS NOT NULL) then
      SELECT name
        INTO x_dimension_name
        FROM cn_dimensions
       WHERE dimension_id = x_dimension_id ;
    else
       x_dimension_name := NULL ;
    end if;

  END Populate_Fields;


--
-- Procedure Name
--   Default_Row  (used by BOTH Tables and Columns)
-- History
-- 08-06-95     Amy Erickson            Created

PROCEDURE Default_Row (x_object_id   IN OUT  number) IS
  BEGIN

    IF x_object_id   IS NULL THEN
      SELECT cn_objects_s.nextval
        INTO x_object_id
        FROM sys.dual ;
    END IF;

  END Default_Row;


--
-- Procedure Name
--   Check_Table_Name
-- History
-- 08-06-95     Amy Erickson            Created

FUNCTION Check_Table_Name (x_name   varchar2,
                           x_schema varchar2) RETURN number IS

  x_count  number  := 0;
  BEGIN

      SELECT count(name)
        INTO x_count
        FROM cn_obj_tables_v
       WHERE name = x_name
         AND schema = x_schema ;

  RETURN x_count;

  END Check_Table_Name;

--
-- Procedure Name
--   Check_Column_Name
-- History
-- 08-06-95     Amy Erickson            Created

FUNCTION Check_Column_Name (x_name      varchar2,
                            x_table_id  number  ) RETURN number IS


  x_count  number  := 0;
  BEGIN

      SELECT count(name)
        INTO x_count
        FROM cn_obj_columns_v
       WHERE name = x_name
         AND table_id = x_table_id ;

  RETURN x_count;

  END Check_Column_Name;


END cnsytc_columns_pkg;

/
