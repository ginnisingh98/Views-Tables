--------------------------------------------------------
--  DDL for Package Body HRDU_DO_API_TRANSLATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRDU_DO_API_TRANSLATE" AS
/* $Header: perduapi.pkb 120.0 2005/05/31 17:19:43 appldev noship $ */

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
                                 p_creation_date        IN Date       DEFAULT SYSDATE)
  IS
    cursor api_id_csr is
      select api_module_id
      from   hr_api_modules
      where  module_name = upper(p_api_module);

    cursor parent_api_id_csr is
      select api_module_id
      from   hr_api_modules
      where  module_name = upper(p_parent_api_module);

    l_api_id        Number(15);
    l_parent_api_id Number(15) := null;

  BEGIN
    -- Get the API id for the module
    open  api_id_csr;
    fetch api_id_csr into l_api_id;
    close api_id_csr;

    -- Get the API id for the Parent API
    IF p_parent_api_module is not null THEN
      open  parent_api_id_csr;
      fetch parent_api_id_csr into l_parent_api_id;
      close parent_api_id_csr;
    END IF;

    INSERT INTO hr_du_column_mappings( column_mapping_id, api_module_id,    column_name,
                                       mapped_to_name,    mapping_type,     parent_api_module_id,
                                       parent_table,      last_update_date, last_updated_by,
                                       last_update_login, created_by,       creation_date )
    SELECT hr_du_column_mappings_s.NEXTVAL,
             l_api_id,
             p_column_name,
             p_mapped_to_name,
             p_mapping_type,
             l_parent_api_id,
             p_parent_table,
             p_last_update_date,
             p_last_updated_by,
             p_last_update_login,
             p_created_by,
             p_creation_date
    FROM dual
    WHERE NOT EXISTS
      (SELECT NULL FROM hr_du_column_mappings
         WHERE api_module_id = l_api_id
           AND column_name = p_column_name
           AND NVL(mapped_to_name,'<null>') = NVL(p_mapped_to_name,'<null>')
           AND mapping_type = p_mapping_type
           AND NVL(parent_api_module_id,-24926578) = NVL(l_parent_api_id,-24926578)
           AND NVL(parent_table,'<null>') = NVL(p_parent_table,'<null>'));

  EXCEPTION

    WHEN OTHERS THEN
      raise_application_error( -20000, 'Failed to insert item - ' || p_column_name ||
                              ' : ' || sqlerrm(sqlcode));

  END;


-- ------------------------ hrdu_get_api_columns ---------------------------
-- Description:
--   This procedure goes through each column that needs to be added to the
--  table, and outputs it to file, then enter's the associated reference
--  into the hrdu_column_mappings table
--
--  Input Parameters
--   p_filehandle - File handle to the file script where the list of columns
--                  should be outputted to
--   p_api_name   - Database name of the API to find columns for
--
-- -------------------------------------------------------------------------
  PROCEDURE hrdu_get_api_columns( p_filehandle IN UTL_FILE.FILE_TYPE, p_api_name IN Varchar2 )
  IS

    cursor columns_csr is
      select distinct column_id, lower( substr(column_name, 3, length(column_name) - 2) ) column_headings
      from   user_tab_columns
      where  table_name = substr( upper( 'HRDPV_' || p_api_name ), 1, 30 )
      and    column_name like 'P_%'
      order by column_headings;

    columns_rec     columns_csr%rowtype;
    l_scripthandle  UTL_FILE.FILE_TYPE;
    l_location      VARCHAR2(2000);

  BEGIN
      -- Fill in first column of the csv file
      utl_file.put(p_filehandle, 'ID' );

      -- Open the new script file for writing
      fnd_profile.get('PER_DATA_EXCHANGE_DIR', l_location);
      l_scripthandle := utl_file.fopen(l_location, 'hrdu_' || LOWER(p_api_name) || '.sql', 'w', 32767);

      -- First create the header for the new script file
      utl_file.put_line(l_scripthandle, 'REM /* $Header: perduapi.pkb 120.0 2005/05/31 17:19:43 appldev noship $ */' );
      utl_file.put_line(l_scripthandle, 'REM +======================================================================+' );
      utl_file.put_line(l_scripthandle, 'REM |              Copyright (c) 2000 Oracle Corporation UK Ltd            | ' );
      utl_file.put_line(l_scripthandle, 'REM |                        Reading, Berkshire, England                   | ' );
      utl_file.put_line(l_scripthandle, 'REM |                           All rights reserved.                       | ' );
      utl_file.put_line(l_scripthandle, 'REM +======================================================================+' );
      utl_file.put_line(l_scripthandle, 'REM API for translation : ' || upper(p_api_name) );
      utl_file.put_line(l_scripthandle, 'REM Data pump view name : ' || substr( upper( 'HRDPV_' || p_api_name ), 1, 30 ) );
      utl_file.put_line(l_scripthandle, 'REM ' );
      utl_file.put_line(l_scripthandle, 'REM Description: Script created to load the API: ' || p_api_name);
      utl_file.put_line(l_scripthandle, 'REM              into the HRMS Data Uploader. Edit the script then run it to' );
      utl_file.put_line(l_scripthandle, 'REM              populate the data uploader tables.' );
      utl_file.put_line(l_scripthandle, 'REM ' );
      utl_file.put_line(l_scripthandle, 'REM Change List: ' );
      utl_file.put_line(l_scripthandle, 'REM ============ ' );
      utl_file.put_line(l_scripthandle, 'REM Name           Date        Version Bug     Text ' );
      utl_file.put_line(l_scripthandle, 'REM -------------- ----------- ------- ------- -----------------------------' );
      utl_file.put_line(l_scripthandle, 'REM <auto>         ' || to_char(sysdate, 'DD-Mon-RRRR') || '    1    -       Auto generated code' );
      utl_file.put_line(l_scripthandle, 'REM' );
      utl_file.put_line(l_scripthandle, 'REM ========================================================================' );
      utl_file.new_line(l_scripthandle, 1 );

      -- Create list of columns that are probably going to need to be changed
      utl_file.put_line(l_scripthandle, 'REM ------------------------------------------------------------------------' );
      utl_file.put_line(l_scripthandle, 'REM  Columns which are most likely to need editing to include references to' );
      utl_file.put_line(l_scripthandle, 'REM other API''s are shown below :-' );
      utl_file.put_line(l_scripthandle, 'REM ' );

      -- Get a list of most common columns that need changing
      for columns_rec in columns_csr loop
        IF ( ( substr( columns_rec.column_headings, length(columns_rec.column_headings) - 2, 3 ) = '_id' ) OR
             ( columns_rec.column_headings like '%user%key%' ) ) THEN
          utl_file.put_line(l_scripthandle, 'REM   * ' || columns_rec.column_headings );
        END IF;
      end loop;

      utl_file.put_line(l_scripthandle, 'REM ' );
      utl_file.put_line(l_scripthandle, 'REM ------------------------------------------------------------------------' );
      utl_file.put_line(l_scripthandle, 'REM Example of a modified column entry:' );
      utl_file.put_line(l_scripthandle, 'REM ' );
      utl_file.put_line(l_scripthandle, 'REM  HRDU_DO_API_TRANSLATE.hrdu_insert_mapping(' );
      utl_file.put_line(l_scripthandle, 'REM          p_api_module        => ''' || p_api_name || ''',' );
      utl_file.put_line(l_scripthandle, 'REM          p_column_name       => ''person_id'',' );
      utl_file.put_line(l_scripthandle, 'REM          p_mapped_to_name    => ''p_person_id'',');
      utl_file.put_line(l_scripthandle, 'REM          p_mapping_type      => ''R'',' );
      utl_file.put_line(l_scripthandle, 'REM          p_parent_api_module => ''create_us_employee'',' );
      utl_file.put_line(l_scripthandle, 'REM          p_parent_table      => null);' );
      utl_file.put_line(l_scripthandle, 'REM ' );
      utl_file.put_line(l_scripthandle, 'REM ------------------------------------------------------------------------' );
      utl_file.new_line(l_scripthandle, 1 );
      utl_file.put_line(l_scripthandle, 'WHENEVER OSERROR EXIT FAILURE ROLLBACK; ' );
      utl_file.put_line(l_scripthandle, 'WHENEVER SQLERROR EXIT FAILURE ROLLBACK; ' );
      utl_file.new_line(l_scripthandle, 1 );

      utl_file.put_line(l_scripthandle, 'DECLARE' );
      utl_file.new_line(l_scripthandle, 1 );
      utl_file.put_line(l_scripthandle, 'BEGIN' );
      utl_file.new_line(l_scripthandle, 1 );

      for columns_rec in columns_csr loop
        -- Fill in csv file
        IF lower(columns_rec.column_headings) not like '%user%key%' THEN
          utl_file.put(p_filehandle, ',' || lower(columns_rec.column_headings) );
        END IF;

        -- Fill in sql file
        utl_file.put_line(l_scripthandle, '  HRDU_DO_API_TRANSLATE.hrdu_insert_mapping(' );
        utl_file.put_line(l_scripthandle, '          p_api_module        => ''' || p_api_name || ''',' );
        IF lower(columns_rec.column_headings) like '%user%key%' THEN
           utl_file.put_line(l_scripthandle, '          p_mapping_type      => ''U'',' );
        END IF;
        utl_file.put_line(l_scripthandle, '          p_column_name       => ''' || columns_rec.column_headings || ''',' );
        utl_file.put_line(l_scripthandle, '          p_mapped_to_name    => ''' || 'p_' || columns_rec.column_headings || ''');' );
        utl_file.new_line(l_scripthandle, 1 );
      end loop;

      utl_file.new_line(l_scripthandle, 1 );
      utl_file.put_line(l_scripthandle, 'END;' );
      utl_file.put_line(l_scripthandle, '/' );
      utl_file.new_line(l_scripthandle, 1 );
      utl_file.put_line(l_scripthandle, 'COMMIT;' );
      utl_file.put_line(l_scripthandle, 'EXIT;' );

      -- Close Script file
      utl_file.fclose(l_scripthandle);

      utl_file.new_line(p_filehandle, 1 );
  EXCEPTION

    WHEN OTHERS THEN
      raise_application_error( -20000, 'Exception occurred in hrdu_get_api_columns - ' || substr(SQLERRM,1,200));

  END;

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
                           p_file_name IN VarChar2 )
  IS

    cursor api_id_csr is
      select api_module_id
      from   hr_api_modules
      where  module_name = upper(p_api_name);

    l_api_id        Number(15);
    l_filehandle    UTL_FILE.FILE_TYPE;
    l_location      VARCHAR2(2000);

  BEGIN
    -- Get the API id for the module
    open  api_id_csr;
    fetch api_id_csr into l_api_id;
    close api_id_csr;

    IF l_api_id is not null THEN

      fnd_profile.get('PER_DATA_EXCHANGE_DIR', l_location);

      l_filehandle := utl_file.fopen(l_location, p_file_name, 'w', 32767);

      utl_file.put_line(l_filehandle, 'Descriptor,Start');
      utl_file.put_line(l_filehandle, 'API,'      || p_api_name);
      utl_file.put_line(l_filehandle, 'Title,'    || p_title_name);
      utl_file.put_line(l_filehandle, 'Process Order,<User_enter>');
      utl_file.put_line(l_filehandle, 'User Key,' || p_user_key);
      utl_file.put_line(l_filehandle, 'Descriptor,End');

      utl_file.new_line(l_filehandle);

      utl_file.put_line(l_filehandle, 'Data,Start');
      hrdu_get_api_columns( l_filehandle, p_api_name );
      utl_file.put_line(l_filehandle, 'Data,End');

      -- close file
      utl_file.fclose(l_filehandle);

    ELSE

      raise_application_error( -20000, 'API: ' || p_api_name || ' does not exist!' );

    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error( -20000, 'Exception occurred in hrdu_copy_api - ' || substr(SQLERRM,1,200));
  END ;

END HRDU_DO_API_TRANSLATE;


/
