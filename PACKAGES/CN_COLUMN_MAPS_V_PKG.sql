--------------------------------------------------------
--  DDL for Package CN_COLUMN_MAPS_V_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_COLUMN_MAPS_V_PKG" AUTHID CURRENT_USER AS
-- $Header: cncocmvs.pls 120.1 2005/06/27 19:26:28 appldev ship $


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
        x_created_by               number) ;

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
        x_last_updated_by               number) ;

  --+
  -- Procedure Name
  --   lock_row
  -- History
  --                    Tony Lower              Created

  PROCEDURE lock_row (x_column_map_id  IN  number);


  --+
  -- Procedure Name
  --   delete_row
  -- History
  --                    Tony Lower              Created

  PROCEDURE delete_row (x_column_map_id  IN  number);


  --+
  -- Procedure Name
  --   Default_Row
  -- History
  -- 07-16-95           Amy Erickson            Created

  PROCEDURE Default_Row (x_column_map_id  IN OUT NOCOPY number) ;


END cn_column_maps_v_pkg;
 

/
