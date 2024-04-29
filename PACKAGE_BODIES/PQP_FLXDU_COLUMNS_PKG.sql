--------------------------------------------------------
--  DDL for Package Body PQP_FLXDU_COLUMNS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_FLXDU_COLUMNS_PKG" AS
/* $Header: pqpflxcol.pkb 120.0 2006/04/26 23:52:10 pbhure noship $ */

-- ===========================================================================
-- This procedure loads data into pqp_flxdu_columns table
-- If data is already there then update else insert
-- ===========================================================================
PROCEDURE load_row
          (x_flxdu_column_id          IN NUMBER
          ,x_flxdu_column_name        IN VARCHAR2
          ,x_flxdu_column_xml_tag     IN VARCHAR2
          ,x_flxdu_column_data_type   IN VARCHAR2
          ,x_flxdu_column_data_length IN VARCHAR2
          ,x_flxdu_seq_num            IN NUMBER
          ,x_flxdu_group_name         IN VARCHAR2
          ,x_entity_type              IN VARCHAR2
          ,x_required_flag            IN VARCHAR2
          ,x_display_flag             IN VARCHAR2
          ,x_description              IN VARCHAR2
          ,x_flxdu_column_xml_data    IN VARCHAR2
          ,x_object_version_number    IN NUMBER) IS
BEGIN
       BEGIN
            -- update row
            pqp_flxdu_columns_pkg.update_row
                  (x_flxdu_column_id            => x_flxdu_column_id
                  ,x_flxdu_column_name          => x_flxdu_column_name
                  ,x_flxdu_column_xml_tag       => x_flxdu_column_xml_tag
                  ,x_flxdu_column_data_type     => x_flxdu_column_data_type
                  ,x_flxdu_column_data_length   => x_flxdu_column_data_length
                  ,x_flxdu_seq_num              => x_flxdu_seq_num
                  ,x_flxdu_group_name           => x_flxdu_group_name
                  ,x_entity_type                => x_entity_type
                  ,x_required_flag              => x_required_flag
                  ,x_display_flag               => x_display_flag
                  ,x_description                => x_description
                  ,x_flxdu_column_xml_data      => x_flxdu_column_xml_data
                  ,x_object_version_number      => x_object_version_number
                  ,x_created_by                 => 1
                  ,x_creation_date              => sysdate
                  ,x_last_update_date           => sysdate
                  ,x_last_updated_by            => 1
                  ,x_last_update_login          => 0 );
       EXCEPTION
            -- when no data found then insert
            WHEN NO_DATA_FOUND THEN
                pqp_flxdu_columns_pkg.insert_row
                   (x_flxdu_column_id            => x_flxdu_column_id
                   ,x_flxdu_column_name          => x_flxdu_column_name
                   ,x_flxdu_column_xml_tag       => x_flxdu_column_xml_tag
                   ,x_flxdu_column_data_type     => x_flxdu_column_data_type
                   ,x_flxdu_column_data_length   => x_flxdu_column_data_length
                   ,x_flxdu_seq_num              => x_flxdu_seq_num
                   ,x_flxdu_group_name           => x_flxdu_group_name
                   ,x_entity_type                => x_entity_type
                   ,x_required_flag              => x_required_flag
                   ,x_display_flag               => x_display_flag
                   ,x_description                => x_description
                   ,x_flxdu_column_xml_data      => x_flxdu_column_xml_data
                   ,x_object_version_number      => x_object_version_number
                   ,x_created_by                 => 1
                   ,x_creation_date              => sysdate
                   ,x_last_update_date           => sysdate
                   ,x_last_updated_by            => 1
                   ,x_last_update_login          => 0 );
       END;
END load_row;


-- =============================================================================
-- This procedure inserts data into pqp_flxdu_columns table
-- =============================================================================
PROCEDURE insert_row
          (x_flxdu_column_id          IN NUMBER
          ,x_flxdu_column_name        IN VARCHAR2
          ,x_flxdu_column_xml_tag     IN VARCHAR2
          ,x_flxdu_column_data_type   IN VARCHAR2
          ,x_flxdu_column_data_length IN VARCHAR2
          ,x_flxdu_seq_num            IN NUMBER
          ,x_flxdu_group_name         IN VARCHAR2
          ,x_entity_type              IN VARCHAR2
          ,x_required_flag            IN VARCHAR2
          ,x_display_flag             IN VARCHAR2
          ,x_description              IN VARCHAR2
          ,x_flxdu_column_xml_data    IN VARCHAR2
          ,x_object_version_number    IN NUMBER
          ,x_created_by               IN NUMBER
          ,x_creation_date            IN DATE
          ,x_last_update_date         IN DATE
          ,x_last_updated_by          IN NUMBER
          ,x_last_update_login        IN NUMBER) is

           -- cursor to find no of rows being inserted
           CURSOR cur_flxdu_columns IS
           SELECT rowid
           FROM   pqp_flxdu_columns;

           x_rowid     rowid;

BEGIN
             -- insert into table pqp_flxdu_columns
             INSERT INTO pqp_flxdu_columns
                     (flxdu_column_id
                     ,flxdu_column_name
                     ,flxdu_column_xml_tag
                     ,flxdu_column_data_type
                     ,flxdu_column_data_length
                     ,flxdu_seq_num
                     ,flxdu_group_name
                     ,entity_type
                     ,required_flag
                     ,display_flag
                     ,description
                     ,flxdu_column_xml_data
                     ,object_version_number
                     ,created_by
                     ,creation_date
                     ,last_update_date
                     ,last_updated_by
                     ,last_update_login)
                VALUES
                     (x_flxdu_column_id
                     ,x_flxdu_column_name
                     ,x_flxdu_column_xml_tag
                     ,x_flxdu_column_data_type
                     ,x_flxdu_column_data_length
                     ,x_flxdu_seq_num
                     ,x_flxdu_group_name
                     ,x_entity_type
                     ,x_required_flag
                     ,x_display_flag
                     ,x_description
                     ,x_flxdu_column_xml_data
                     ,x_object_version_number
                     ,x_created_by
                     ,x_creation_date
                     ,x_last_update_date
                     ,x_last_updated_by
                     ,x_last_update_login);

             -- if no rows are inserted raise error
             OPEN cur_flxdu_columns;
             FETCH cur_flxdu_columns INTO x_rowid;
             IF (cur_flxdu_columns%notfound) THEN
               CLOSE cur_flxdu_columns;
               RAISE NO_DATA_FOUND;
             END IF;
             CLOSE cur_flxdu_columns;
END insert_row;


-- =============================================================================
-- This procedure updates data in pqp_flxdu_columns table
-- =============================================================================
PROCEDURE update_row
               (x_flxdu_column_id          IN NUMBER
               ,x_flxdu_column_name        IN VARCHAR2
               ,x_flxdu_column_xml_tag     IN VARCHAR2
               ,x_flxdu_column_data_type   IN VARCHAR2
               ,x_flxdu_column_data_length IN VARCHAR2
               ,x_flxdu_seq_num            IN NUMBER
               ,x_flxdu_group_name         IN VARCHAR2
               ,x_entity_type              IN VARCHAR2
               ,x_required_flag            IN VARCHAR2
               ,x_display_flag             IN VARCHAR2
               ,x_description              IN VARCHAR2
               ,x_flxdu_column_xml_data    IN VARCHAR2
               ,x_object_version_number    IN NUMBER
               ,x_created_by               IN NUMBER
               ,x_creation_date            IN DATE
               ,x_last_update_date         IN DATE
               ,x_last_updated_by          IN NUMBER
               ,x_last_update_login        IN NUMBER) IS
BEGIN
      -- update table pqp_flxdu_columns
      UPDATE pqp_flxdu_columns
      SET    flxdu_column_id             = x_flxdu_column_id
            ,flxdu_column_name           = x_flxdu_column_name
            ,flxdu_column_xml_tag        = x_flxdu_column_xml_tag
            ,flxdu_column_data_type      = x_flxdu_column_data_type
            ,flxdu_column_data_length    = x_flxdu_column_data_length
            ,flxdu_seq_num               = x_flxdu_seq_num
            ,flxdu_group_name            = x_flxdu_group_name
            ,entity_type                 = x_entity_type
            ,required_flag               = x_required_flag
            ,display_flag                = x_display_flag
            ,description                 = x_description
            ,flxdu_column_xml_data       = x_flxdu_column_xml_data
            ,object_version_number       = x_object_version_number
            ,created_by                  = x_created_by
            ,creation_date               = x_creation_date
            ,last_update_date            = x_last_update_date
            ,last_updated_by             = x_last_updated_by
            ,last_update_login           = x_last_update_login
      WHERE  flxdu_column_id = x_flxdu_column_id;

       IF (SQL%NOTFOUND) THEN
             RAISE no_data_found;
       END IF;
END update_row;

END pqp_flxdu_columns_pkg;

/
