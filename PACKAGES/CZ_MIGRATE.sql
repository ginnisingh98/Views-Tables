--------------------------------------------------------
--  DDL for Package CZ_MIGRATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CZ_MIGRATE" AUTHID CURRENT_USER AS
/*	$Header: czmigrs.pls 120.1 2006/03/06 13:39:41 srangar ship $		*/

EXPLORETREE_ERROR EXCEPTION;
PRAGMA EXCEPTION_INIT(EXPLORETREE_ERROR, -20001);


------------------------------------------------------------------------------------------------------------
type ColumnNameArray is table of user_tab_columns.column_name%type index by binary_integer;
type PkColumnNameArray is table of user_cons_columns.column_name%type index by binary_integer;
type TriggerNameArray is table of user_triggers.trigger_name%type index by binary_integer;
TYPE jraddoc_type_tbl IS TABLE OF cz_ui_pages.jrad_doc%TYPE index by BINARY_INTEGER;
------------------------------------------------------------------------------------------------------------

  FATAL_ERROR                 CONSTANT PLS_INTEGER := -1;
  SKIPPABLE_ERROR             CONSTANT PLS_INTEGER :=  1;
  NO_ERROR                    CONSTANT PLS_INTEGER :=  0;

  URGENCY_ERROR               CONSTANT PLS_INTEGER := 0;
  URGENCY_WARNING             CONSTANT PLS_INTEGER := 1;
  URGENCY_MESSAGE             CONSTANT PLS_INTEGER := 2;
  URGENCY_DEBUG               CONSTANT PLS_INTEGER := 3;

  MESSAGE_START_ID            CONSTANT PLS_INTEGER :=  1000;
  GENERIC_RUN_ID              CONSTANT PLS_INTEGER := -1001;

  CONCURRENT_SUCCESS          CONSTANT PLS_INTEGER := 0;
  CONCURRENT_ERROR            CONSTANT PLS_INTEGER := 2;

  APPLICATIONS_SCHEMA         CONSTANT VARCHAR2(4) := 'APPS';
  CONFIGURATOR_SCHEMA         CONSTANT VARCHAR2(4) := 'CZ';

  SETUP_STATUS_CODE           CONSTANT PLS_INTEGER := 11778;
  MIGRATE_STATUS_CODE         CONSTANT PLS_INTEGER := 11777;

  CZ_MIGR_FATAL_EXCEPTION     EXCEPTION;
  CZ_MIGR_SKIPPABLE_EXCEPTION EXCEPTION;
  CZ_MIGR_UNABLE_TO_REPORT    EXCEPTION;

------------------------------------------------------------------------------------------------------------
FUNCTION migrate_setup(x_run_id     IN OUT NOCOPY PLS_INTEGER,
                       p_local_name IN VARCHAR2,
                       p_force_run  IN VARCHAR2)
RETURN INTEGER;
------------------------------------------------------------------------------------------------------------
FUNCTION migrate(x_run_id               IN OUT NOCOPY PLS_INTEGER,
                 p_force_run            IN VARCHAR2,
                 CommitSize             in pls_integer,
                 StopOnSkippable        in number,
                 ForceSlowMode          in number,
                 AllowDifferentVersions in number,
                 AllowRefresh           in number,
                 ForceProcess           in number,
                 DeleteDbLink           in number)
RETURN INTEGER;
------------------------------------------------------------------------------------------------------------
function compare_versions return integer;
------------------------------------------------------------------------------------------------------------
function compare_columns(inTableName in varchar2) return integer;
------------------------------------------------------------------------------------------------------------
function get_table_columns(inTableName in varchar2,outNamesArray OUT NOCOPY ColumnNameArray) return integer;
------------------------------------------------------------------------------------------------------------
function compare_pk_columns(inTableName in varchar2) return integer;
------------------------------------------------------------------------------------------------------------
function get_table_pk_columns(inTableName in varchar2, outNamesArray OUT NOCOPY PkColumnNameArray) return integer;
------------------------------------------------------------------------------------------------------------
function copy_table(inTableName       in varchar2,
                    inCommitSize      in pls_integer,
                    inStopOnSkippable in number,
                    inRefreshable     in number,
                    inForceSlowMode   in number,
                    inForceProcess    in number)
return integer;
------------------------------------------------------------------------------------------------------------
FUNCTION copy_table_override(inTableName       IN VARCHAR2,
                             inStopOnSkippable IN NUMBER)
RETURN INTEGER;
------------------------------------------------------------------------------------------------------------
function copy_all_tables(inCommitSize      in pls_integer,
                         inStopOnSkippable in number,
                         inRefreshable     in number,
                         inForceSlowMode   in number,
                         inForceProcess    in number)
return integer;
------------------------------------------------------------------------------------------------------------
function copy_table_slowmode(inTableName       in varchar2,
                             inCommitSize      in pls_integer,
                             inStopOnSkippable in number,
                             inRefreshable     in number) return integer;
------------------------------------------------------------------------------------------------------------
function copy_table_fastmode(inTableName       in varchar2,
                             inStopOnSkippable in number)
return integer;
------------------------------------------------------------------------------------------------------------
function copy_table_fastnorefresh(inTableName       in varchar2,
                                  inStopOnSkippable in number)
return integer;
------------------------------------------------------------------------------------------------------------
function copy_table_fastrefresh(inTableName       in varchar2,
                                inStopOnSkippable in number)
return integer;
------------------------------------------------------------------------------------------------------------
function disable_triggers(inStopOnSkippable in number) return integer;
------------------------------------------------------------------------------------------------------------
function enable_triggers(inStopOnSkippable in number) return integer;
------------------------------------------------------------------------------------------------------------
FUNCTION adjust_sequence(sequenceName IN VARCHAR2, tableName IN VARCHAR2, inPkName IN VARCHAR2, p_increment IN NUMBER)
RETURN INTEGER;
------------------------------------------------------------------------------------------------------------
FUNCTION adjust_all_sequences(inStopOnSkippable IN NUMBER)
RETURN INTEGER;
------------------------------------------------------------------------------------------------------------
PROCEDURE report(inMessage IN VARCHAR2, inUrgency IN PLS_INTEGER);
------------------------------------------------------------------------------------------------------------
PROCEDURE setup_migration_cp(errbuf        OUT NOCOPY VARCHAR2,
                             retcode       OUT NOCOPY NUMBER,
                             p_source_name IN  VARCHAR2,
                             p_force_run   IN  VARCHAR2 DEFAULT 'NO');
------------------------------------------------------------------------------------------------------------
PROCEDURE run_migration_cp(errbuf      OUT NOCOPY VARCHAR2,
                           retcode     OUT NOCOPY NUMBER,
                           p_force_run IN  VARCHAR2 DEFAULT 'NO');
------------------------------------------------------------------------------------------------------------
PROCEDURE get_xml_chunks (p_ui_def_id  IN NUMBER,p_template_id IN NUMBER);

------------------------------------------------------------------------------------------------------------
PROCEDURE import_jrad_docs (p_ui_def_id IN NUMBER,
			          p_link_name IN VARCHAR2,
			          x_return_status OUT NOCOPY VARCHAR2,
			          x_msg_count  OUT NOCOPY NUMBER,
			          x_msg_data   OUT NOCOPY VARCHAR2);
--------------------------------------------------------------------------------------------------------------
PROCEDURE import_template_jrad_docs (p_link_name IN VARCHAR2,
				    x_return_status OUT NOCOPY VARCHAR2,
				    x_msg_count  OUT NOCOPY NUMBER,
				    x_msg_data   OUT NOCOPY VARCHAR2);
---------------------------------------------------------------------------------------------------------------
END cz_migrate;

 

/
