--------------------------------------------------------
--  DDL for Package GL_JOURNAL_IMPORT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_JOURNAL_IMPORT_PKG" AUTHID CURRENT_USER as
/* $Header: glujimns.pls 120.6.12010000.2 2011/09/28 10:01:11 sommukhe ship $ */
/*#
 * Provides functions to use with Journal Import.
 * @rep:scope public
 * @rep:product GL
 * @rep:lifecycle active
 * @rep:displayname Journal Import Functions
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY GL_JOURNAL
 */

--
-- Package
--   GL_JOURNAL_IMPORT_PKG
-- Purpose
--   Various utilities for working directly with Journal Import
-- History
--   09-OCT-2000  D J Ogg          Created.
--

  -- This exception is raised when we fail to get the applsys schema
  -- information in the create_table and drop_table routines
  CANNOT_GET_APPLSYS_SCHEMA EXCEPTION;

  -- This exception is raised when the populate_interface_control routine
  -- is passed an invalid journal entry source name
  INVALID_JE_SOURCE EXCEPTION;

  -- This exception is raised when the populate_interface_control routine
  -- is passed an invalid processed_data_action
  INVALID_PROCESSED_ACTION EXCEPTION;

  -- This exception is raised when the populate_interface_control routine
  -- is passed parameters that would imply that gl_interface should be
  -- dropped.
  CANNOT_DROP_GL_INTERFACE EXCEPTION;


  -- Constants for use with the processed_data_action parameter of
  -- the populate_interface_control procedure.
  SAVE_DATA		CONSTANT	VARCHAR2(1) := 'S';
  DELETE_DATA		CONSTANT	VARCHAR2(1) := 'D';
  DROP_INTERFACE_TABLE	CONSTANT	VARCHAR2(1) := 'R';

  --
  -- Procedure
  --   create_table
  -- Purpose
  --   Creates a copy of the gl_interface table with the given
  --   name and storage parameters.  The table will be created
  --   in the gl schema.
  -- History
  --   09-OCT-2000  D. J. Ogg    Created
  -- Arguments
  --   table_name       	The name of the new table
  --   tablespace		The tablespace the table should be created in
  --   physical_attributes	The physical attributes clause for the
  --                            creation of the table
  --   create_n1_index          Indicates whether or not the n1 index should
  --                            be created
  --   n1_tablespace            The tablespace the n1 index should be created
  --                            in
  --   n1_physical_attributes   The physical attributes clause for the
  --                            creation of the n1 index
  --   create_n2_index          Indicates whether or not the n2 index should
  --                            be created
  --   n2_tablespace            The tablespace the n2 index should be created
  --                            in
  --   n2_physical_attributes   The physical attributes clause for the
  --                            creation of the n2 index
  -- Example
  --   gl_journal_import_pkg.create_table(
  --      'GL_CUSTOM_INTERFACE',
  --      'TAB1',
  --      'PCTFREE 10 STORAGE (INITIAL 500K NEXT 1M)',
  --      FALSE,
  --      NULL,
  --      NULL,
  --      TRUE,
  --      'IND1',
  --      'STORAGE (INITIAL 10K NEXT 20K)');
  -- Notes
  --
/*#
 * Creates a copy of the GL_INTERFACE table. The newly created copy is created in
 * the GL schema and has the name and storage parameters provided by the user.
 * Journal Import can pull data from the newly created interface table to
 * create journals.
 * @param table_name Name of new table.
 * @param tablespace Tablespace that will contain the new table.
 * @param physical_attributes Physical attributes clause to be used in the creation of the new table.
 * @param create_n1_index Indicates whether a copy of the GL_INTERFACE_N1 index is created for this table.
 * @param n1_tablespace Tablespace that will contain a copy of the GL_INTERFACE_N1 index.
 * @param n1_physical_attributes Physical attributes clause to be used in the creation of a copy of the GL_INTERFACE_N1 index.
 * @param create_n2_index Indicates whether a copy of the GL_INTERFACE_N2 index is created for this table.
 * @param n2_tablespace Tablespace that will contain a copy of the GL_INTERFACE_N2 index.
 * @param n2_physical_attributes Physical attributes clause to be used in the creation of a copy of the GL_INTERFACE_N2 index.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Journal Interface Table
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY GL_JOURNAL
 */
  PROCEDURE create_table(table_name 			VARCHAR2,
                         tablespace 			VARCHAR2 DEFAULT NULL,
                         physical_attributes 		VARCHAR2 DEFAULT NULL,
			 create_n1_index		BOOLEAN DEFAULT TRUE,
			 n1_tablespace			VARCHAR2 DEFAULT NULL,
			 n1_physical_attributes		VARCHAR2 DEFAULT NULL,
			 create_n2_index		BOOLEAN DEFAULT TRUE,
			 n2_tablespace			VARCHAR2 DEFAULT NULL,
			 n2_physical_attributes		VARCHAR2 DEFAULT NULL,
                         create_n3_index		BOOLEAN DEFAULT FALSE,
			 n3_tablespace			VARCHAR2 DEFAULT NULL,
			 n3_physical_attributes		VARCHAR2 DEFAULT NULL
                        );

  --
  -- Procedure
  --   drop_table
  -- Purpose
  --   Drops a copy of the gl_interface table from the gl schema
  -- History
  --   09-OCT-2000  D. J. Ogg    Created
  -- Arguments
  --   table_name       	The name of the new table
  -- Example
  --   gl_journal_import_pkg.drop_table(
  --      'GL_CUSTOM_INTERFACE');
  -- Notes
  --
/*#
 * Drops a copy of the GL_INTERFACE table, which must be in the GL schema.
 * @param table_name Name of the table to drop.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Drop Journal Interface Table
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY GL_JOURNAL
 */
  PROCEDURE drop_table(table_name 			VARCHAR2);

  --
  -- Procedure
  --   populate_interface_control
  -- Purpose
  --   Populates the gl_interface_control table.  This routine does not
  --   do a commit.  Returns the interface run id.
  -- History
  --   09-OCT-2000  D. J. Ogg    Created
  -- Arguments
  --   user_je_source_name      User friendly version of the source name
  --   group_id                 Group id to be processed.  If none is
  --                            provided, one will be automatically generated
  --                            and passed back through this parameter.
  --   set_of_books_id          Ledger Id to be used
  --   interface_run_id		Interface run id to be used.  If none is
  --                            provided, one will be automatically generated
  --                            and passed back through this parameter.
  --   table_name       	The name of the new table
  --   processed_data_action    Indicates what to do with the data and table
  --                            if it is successfully imported.
  --                            Valid options are SAVE_DATA, DELETE_DATA,
  --                            and DROP_INTERFACE_TABLE
  -- Example
  --   gl_journal_import_pkg.populate_interface_control(
  --      'Custom',
  --      5001,
  --      1,
  --      'GL_CUSTOM_INTERFACE');
  -- Notes
  --
/*#
 * Communicates to Journal Import the source and GROUP_ID of transaction data
 * to be processed, its location, and the action to take when it is
 * imported successfully. This information is stored in the GL_INTERFACE_CONTROL
 * table under the specified value of INTERFACE_RUN_ID. When Journal Import
 * is run for that INTERFACE_RUN_ID, the specified data is processed.
 *
 * The TABLE_NAME parameter specifies the table in which the data is stored.
 * If no value is specified for this parameter, then the table is assumed to be
 * GL_INTERFACE. If the data is stored in a table other than GL_INTERFACE, then
 * information about the location of the data is saved in GL_INTERFACE_CONTROL
 * until the data is imported successfully. Any Journal Import run that processes
 * that source and GROUP_ID will retrieve data from the specified table,
 * even if run for a different INTERFACE_RUN_ID. Once the data is imported
 * successfully, the row is deleted from GL_INTERFACE_CONTROL. Any
 * additional runs of Journal Import for that source and GROUP_ID will retrieve
 * data from the GL_INTERFACE table.
 *
 * The PROCESSED_DATA_ACTION parameter specifies the method to use in handling
 * the data once it is successfully processed. Valid values are
 * gl_journal_import_pkg.SAVE_DATA, gl_journal_import_pkg.DELETE_DATA,
 * and gl_journal_import_pkg.DROP_INTERFACE_TABLE. The value,
 * gl_journal_import_pkg.SAVE_DATA, leaves the data in
 * the interface table, but does not allow it to be reimported. The value,
 * gl_journal_import_pkg.DELETE_DATA, indicates the data should be deleted from
 * the interface table, and the value, gl_journal_import_pkg.DROP_INTERFACE_TABLE,
 * indicates the interface table should be dropped if all of its data has been
 * processed successfully by the Journal Import run. If the table cannot be
 * dropped or if all of the data in the table has not been processed, the data is
 * deleted. Note, however, that the GL_INTERFACE table is never
 * dropped, regardless of the setting of the PROCESSED_DATA_ACTION parameter.
 *
 * If no value is specified for the PROCESSED_DATA_ACTION parameter, then the
 * data is deleted once it has been successfully processed. If a value is
 * specified other than gl_journal_import_pkg.DELETE_DATA, then the action to
 * take for this data is saved in
 * GL_INTERFACE_CONTROL until the data is imported successfully. Any Journal
 * Import run that processes that source and GROUP_ID will execute this action
 * upon importing the data successfully, even if run for a different
 * INTERFACE_RUN_ID. Once the data is imported successfully, the row is
 * deleted from GL_INTERFACE_CONTROL. Any additional runs of Journal Import
 * for that source and GROUP_ID will execute the default action of deleting
 * any successfully imported data.
 *
 * If a null value of INTERFACE_RUN_ID is passed to this routine, then the routine
 * automatically generates and returns a unique INTERFACE_RUN_ID.  If a null value
 * of GROUP_ID is passed to this routine, then the routine automatically
 * generates and returns a unique GROUP_ID.
 * @param user_je_source_name User-friendly journal source name of the data to be processed.
 * @param group_id Group id of the data to be processed.
 * @param set_of_books_id Ledger id of the data to be processed.
 * @param interface_run_id Identifier of a specific Journal Import run.
 * @param table_name Table that contains the data to be processed.
 * @param processed_data_action Action to take once the data has been successfully processed.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Populate Interface Control
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY GL_JOURNAL
 */

  PROCEDURE populate_interface_control(
              user_je_source_name	VARCHAR2,
	      group_id			IN OUT NOCOPY	NUMBER,
              set_of_books_id           NUMBER,
              interface_run_id 		IN OUT NOCOPY  NUMBER,
	      table_name 	       	VARCHAR2 DEFAULT NULL,
              processed_data_action   	VARCHAR2 DEFAULT NULL);

  --
  -- Procedure
  --   get_last_sql
  -- Purpose
  --   Returns the last attempted sql*statement executed by the
  --   create_table and drop_table routines
  -- History
  --   09-OCT-2000  D. J. Ogg    Created
  -- Arguments
  --   * NONE *
  -- Example
  --   last_sql := gl_journal_import_pkg.get_last_sql;
  -- Notes
  --
/*#
 * Returns the last sql* statement executed by the CREATE_TABLE and DROP_TABLE
 * routines.
 * @return Last sql*statement executed by the CREATE_TABLE and DROP_TABLE routines.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Get Last Create/Drop SQL Statement
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY GL_JOURNAL
 */
  FUNCTION get_last_sql RETURN VARCHAR2;

  --
  -- Procedure
  --   get_error_msg
  -- Purpose
  --   Returns the last error message, if any, for the create_table
  --   and drop_table routines
  -- History
  --   09-OCT-2000  D. J. Ogg    Created
  -- Arguments
  --   * NONE *
  -- Example
  --   errmsg := gl_journal_import_pkg.get_error_msg;
  -- Notes
  --
/*#
 * Returns the last error message, if any, produced by the CREATE_TABLE and DROP_TABLE
 * routines.
 * @return Last error message produced by the CREATE_TABLE and DROP_TABLE routines.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Get Last Create/Drop Error Message
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY GL_JOURNAL
 */
  FUNCTION get_error_msg RETURN VARCHAR2;


END GL_JOURNAL_IMPORT_PKG;

/
