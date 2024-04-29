--------------------------------------------------------
--  DDL for Package HRDU_DO_API_TRANSLATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRDU_DO_API_TRANSLATE" AUTHID CURRENT_USER AS
/* $Header: perduapi.pkh 120.0 2005/05/31 17:20:07 appldev noship $ */

-- ---------------------------- hrdu_copy_api -------------------------------
-- Description:
--   This procedure creates a new comma seperated text file for use with the
--  HR data uploader.  The procedure is passed an API name which it uses to
--  create a comma seperated file to be loaded into into the hrdu spreadsheet,
--  also the associated database table entries are entered into hr_du_column_mappings
--
--  Input Parameters
--   p_api_name   - Database name of the API to find columns for
--   p_title_name - Entry to go in the spreadsheet by Title Name
--   p_user_key   - Entry to go in the spreadsheet by user key
--   p_file_name  - Name of the file to output to
--
-- --------------------------------------------------------------------------
  PROCEDURE hrdu_copy_api( p_api_name IN Varchar2,
                           p_title_name IN VarChar2,
                           p_user_key IN VarChar2,
                           p_file_name IN VarChar2 );

-- ------------------------ hrdu_insert_mapping ---------------------------
-- Description:
--   This procedure inserts a record into the hr_du_column_mappings table.
--  Most entries are defaulted, and the procedure automatically uses the
--  associated sequence.  This procedure will be used in a package created
--  by hrdu_copy_api.
--
--  Input Parameters:
--    p_api_module           - API module mapping references to
--    p_column_name          - Column name in spreadsheet
--    p_mapped_to_name       - Column mapped to
--    p_mapping_type         - Type of mapping                   - Default 'D'
--    p_parent_api_module    - Parent API module                 - Default Null
--    p_parent_table         - Parent table                      - Default Null
--    p_last_update_date     - Last updated date                 - Default SysDate
--    p_last_updated_by      - Last updated by                   - Default 1
--    p_last_update_login    - Last update login                 - Default 1
--    p_created_by           - Created by                        - Default 1
--    p_creation_date        - Creation date                     - Default SysDate
--
-- -------------------------------------------------------------------------
  PROCEDURE hrdu_insert_mapping( p_api_module           IN VarChar2,
                                 p_column_name          IN VarChar2,
                                 p_mapped_to_name       IN VarChar2,
                                 p_mapping_type         IN VarChar2   DEFAULT 'D',
                                 p_parent_api_module    IN VarChar2   DEFAULT NULL,
                                 p_parent_table         IN VarChar2   DEFAULT NULL,
                                 p_last_update_date     IN Date       DEFAULT SYSDATE,
                                 p_last_updated_by      IN Number     DEFAULT 1,
                                 p_last_update_login    IN Number     DEFAULT 1,
                                 p_created_by           IN Number     DEFAULT 1,
                                 p_creation_date        IN Date       DEFAULT SYSDATE);

END HRDU_DO_API_TRANSLATE;

 

/
