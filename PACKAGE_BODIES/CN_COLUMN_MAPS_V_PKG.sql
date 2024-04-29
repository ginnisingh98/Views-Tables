--------------------------------------------------------
--  DDL for Package Body CN_COLUMN_MAPS_V_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_COLUMN_MAPS_V_PKG" AS
-- $Header: cncocmvb.pls 120.1 2005/06/27 19:26:42 appldev ship $


--
-- Public Procedures
--

  --+
  -- Procedure Name
  --   insert_row
  -- History
  --                    Tony Lower              Created
  -- 11-28-95           Amy Erickson            Updated

  PROCEDURE insert_row (
        x_column_map_id            Number,
        x_source_column_id         Number,
        x_dest_column_id           Number,
        x_table_map_id             Number,
        x_foreign_key_mapping_id   Number,
        x_expression               varchar2,
        x_creation_date            date,
        x_created_by               number) IS

  BEGIN

    INSERT INTO cn_column_maps(
        column_map_id,
        source_column_id,
        destination_column_id,
        table_map_id,
        driving_column_id,
        expression,
        creation_date,
        created_by)
    VALUES(
        x_column_map_id,
        x_source_column_id,
        x_dest_column_id,
        x_table_map_id,
        x_foreign_key_mapping_id,
        x_expression,
        x_creation_date,
        x_created_by);

  END insert_row;


  --+
  -- Procedure Name
  --   update_row
  -- History
  --                    Tony Lower              Created
  -- 11-28-95           Amy Erickson            Updated

  PROCEDURE update_row(
        x_column_map_id                 Number,
        x_source_column_id              Number,
        x_dest_column_id                Number,
        x_table_map_id                  Number,
        x_foreign_key_mapping_id        Number,
        x_expression                    varchar2,
        x_last_update_date              date,
        x_last_update_login             number,
        x_last_updated_by               number) IS

  BEGIN

    UPDATE cn_column_maps SET
        source_column_id = x_source_column_id,
        destination_column_id = x_dest_column_id,
        table_map_id = x_table_map_id,
        driving_column_id = x_foreign_key_mapping_id,
        expression = x_expression,
        last_update_date  = x_last_update_date,
        last_update_login = x_last_update_login,
        last_updated_by   = x_last_updated_by
    WHERE column_map_id = X_column_map_id;

  END update_row;

  --+
  -- Procedure Name
  --   lock_row
  -- History
  --                    Tony Lower              Created
  -- 07-16-95           Amy Erickson            Updated

  PROCEDURE lock_row (x_column_map_id  IN   NUMBER) IS
        temp Number;
  BEGIN
    temp := NULL;

        SELECT column_map_id
          INTO temp
          FROM cn_column_maps
         WHERE column_map_id = x_column_map_id
           FOR UPDATE ;

  END lock_row;

  --+
  -- Procedure Name
  --   delete_row
  -- History
  -- 07-16-95           Amy Erickson            Created

  PROCEDURE delete_row (x_column_map_id  IN   NUMBER) IS
  BEGIN

        DELETE cn_column_maps
         WHERE column_map_id = x_column_map_id ;

  END delete_row;

  --+
  -- Procedure Name
  --   Default_Row
  -- History
  -- 07-16-95           Amy Erickson            Created

  PROCEDURE Default_Row (x_column_map_id  IN OUT NOCOPY number) IS
    BEGIN

      IF x_column_map_id IS NULL THEN
        SELECT cn_column_maps_s.nextval
          INTO x_column_map_id
          FROM sys.dual ;
      END IF;

    END Default_Row;

END cn_column_maps_v_pkg;

/
