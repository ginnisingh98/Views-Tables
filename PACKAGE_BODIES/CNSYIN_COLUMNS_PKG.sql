--------------------------------------------------------
--  DDL for Package Body CNSYIN_COLUMNS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CNSYIN_COLUMNS_PKG" as
-- $Header: cnsyinbb.pls 115.1 99/07/16 07:17:41 porting ship $


  --
  -- Procedure Name
  --   select_columns
  -- History
  --   01/26/94		Tony Lower		Created
  --
  PROCEDURE select_columns(	X_data_type		IN OUT	varchar2,
				X_column_type		IN OUT	varchar2,
				X_dimension_id		IN OUT	number,
				X_data_type_name	IN OUT	varchar2,
				X_type_name		IN OUT	varchar2,
				X_dimension_name	IN OUT	varchar2) IS

  BEGIN

    IF X_column_type is NULL THEN
      X_column_type := 'CN';
    END IF;

    IF X_data_type is NULL THEN
      X_data_type := 'NUMBER';
    END IF;

    SELECT lookup1.meaning, lookup2.meaning
      INTO X_type_name, X_data_type_name
      FROM cn_lookups lookup1, cn_lookups lookup2
     WHERE lookup1.lookup_type = 'COLUMN_TYPE'
       AND lookup1.lookup_code = X_column_type
       AND lookup2.lookup_type = 'DATA_TYPE'
       AND lookup2.lookup_code = X_data_type;

    IF X_dimension_id is NOT null THEN
      SELECT name
        INTO X_dimension_name
        FROM cn_dimensions
       WHERE dimension_id = X_dimension_id;

    ELSE
      X_dimension_id := NULL;
    END IF;

  END select_columns;


  --
  -- Procedure Name
  --   default_row
  -- History
  --   01/26/94		Tony Lower		Created
  --
  PROCEDURE default_row (	X_table_id		IN OUT	number,
				X_position		IN OUT	number,
				X_column_id		IN OUT	number) IS

  BEGIN

    IF X_column_id is NULL THEN

      SELECT cn_objects_s.nextval
        INTO X_column_id FROM dual;

    END IF;

    IF X_position is NULL THEN

      SELECT max(position)+1
	INTO X_position
	FROM cn_obj_columns_v
       WHERE table_id = X_table_id;

    END IF;

  END default_row;


END CNSYIN_Columns_PKG;

/
