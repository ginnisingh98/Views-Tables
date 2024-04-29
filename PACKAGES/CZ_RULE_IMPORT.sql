--------------------------------------------------------
--  DDL for Package CZ_RULE_IMPORT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CZ_RULE_IMPORT" AUTHID CURRENT_USER AS
/*	$Header: czruleis.pls 120.0 2005/05/25 06:20:10 appldev noship $		*/
---------------------------------------------------------------------------------------
CZRI_MODULE_NAME           CONSTANT VARCHAR2(16) := 'CZRULEIMPORT';
CZRI_COMMIT_SIZE           CONSTANT NUMBER       := 10000;
CZRI_MAXIMUM_ERRORS        CONSTANT NUMBER       := 1000000;
CZRI_API_VERSION           CONSTANT NUMBER       := 1.0;

CZRI_LOCALIZED_TEXTS_INC   CONSTANT NUMBER       := 20;
CZRI_RULES_INC             CONSTANT NUMBER       := 20;

CZRI_RECSTATUS_CND         CONSTANT VARCHAR2(4)  := 'CND';
CZRI_RECSTATUS_KRS         CONSTANT VARCHAR2(4)  := 'KRS';
CZRI_RECSTATUS_XFR         CONSTANT VARCHAR2(4)  := 'XFR';
CZRI_RECSTATUS_OK          CONSTANT VARCHAR2(4)  := 'OK';

CZRI_DISPOSITION_INSERT    CONSTANT VARCHAR2(1)  := 'I';
CZRI_DISPOSITION_MODIFY    CONSTANT VARCHAR2(1)  := 'M';
CZRI_DISPOSITION_REJECT    CONSTANT VARCHAR2(1)  := 'R';
CZRI_DISPOSITION_PASSED    CONSTANT VARCHAR2(1)  := 'P';

CZRI_FLAG_NOT_DELETED      CONSTANT VARCHAR2(1)  := '0';
CZRI_FLAG_NOT_SEEDED       CONSTANT VARCHAR2(1)  := '0';
CZRI_FLAG_STATEMENT_RULE   CONSTANT VARCHAR2(1)  := '0';
CZRI_FLAG_NOT_MUTABLE      CONSTANT VARCHAR2(1)  := '0';
CZRI_FLAG_NOT_DISABLED     CONSTANT VARCHAR2(1)  := '0';
CZRI_FLAG_NOT_INVALID      CONSTANT VARCHAR2(1)  := '0';
CZRI_REPOSITORY_PROJECT    CONSTANT VARCHAR2(4)  := 'PRJ';
CZRI_TYPE_RULE_FOLDER      CONSTANT VARCHAR2(4)  := 'RFL';
CZRI_FOLDER_TYPE_RULE      CONSTANT VARCHAR2(4)  := 'RUL';
CZRI_FOLDER_TYPE_CX        CONSTANT VARCHAR2(4)  := 'CXT';
CZRI_EFFECTIVE_USAGE       CONSTANT VARCHAR2(16) := '0000000000000000';
CZRI_RULE_SEQ_NBR          CONSTANT NUMBER       := 1;
CZRI_RULE_SCOPE_INSTANCE   CONSTANT NUMBER       := 1;
CZRI_TYPE_EXPRESSION_RULE  CONSTANT NUMBER       := 200;
CZRI_TYPE_COMPANION_RULE   CONSTANT NUMBER       := 300;

CZRI_ERR_FATAL_ERROR       EXCEPTION;
CZRI_ERR_REPORT_ERROR      EXCEPTION;
CZRI_ERR_MAXIMUM_ERRORS    EXCEPTION;
CZRI_ERR_ACTIVE_SESSIONS   EXCEPTION;
CZRI_ERR_RUNID_EXISTS      EXCEPTION;
CZRI_ERR_RUNID_INCORRECT   EXCEPTION;
CZRI_ERR_DATA_INCORRECT    EXCEPTION;
---------------------------------------------------------------------------------------
PROCEDURE report(p_message    IN VARCHAR2,
                 p_run_id     IN NUMBER,
                 p_caller     IN VARCHAR2,
                 p_statuscode IN NUMBER);
---------------------------------------------------------------------------------------
PROCEDURE cnd_rules(p_api_version    IN NUMBER,
                    p_run_id         IN NUMBER,
                    p_maximum_errors IN PLS_INTEGER,
                    p_commit_size    IN PLS_INTEGER,
                    p_errors         IN OUT NOCOPY PLS_INTEGER,
                    x_return_status  IN OUT NOCOPY VARCHAR2,
                    x_msg_count      IN OUT NOCOPY NUMBER,
                    x_msg_data       IN OUT NOCOPY VARCHAR2);
---------------------------------------------------------------------------------------
PROCEDURE krs_rules(p_api_version    IN NUMBER,
                    p_run_id         IN NUMBER,
                    p_maximum_errors IN PLS_INTEGER,
                    p_commit_size    IN PLS_INTEGER,
                    p_errors         IN OUT NOCOPY PLS_INTEGER,
                    x_return_status  IN OUT NOCOPY VARCHAR2,
                    x_msg_count      IN OUT NOCOPY NUMBER,
                    x_msg_data       IN OUT NOCOPY VARCHAR2);
---------------------------------------------------------------------------------------
PROCEDURE xfr_rules(p_api_version    IN NUMBER,
                    p_run_id         IN NUMBER,
                    p_maximum_errors IN PLS_INTEGER,
                    p_commit_size    IN PLS_INTEGER,
                    p_errors         IN OUT NOCOPY PLS_INTEGER,
                    x_return_status  IN OUT NOCOPY VARCHAR2,
                    x_msg_count      IN OUT NOCOPY NUMBER,
                    x_msg_data       IN OUT NOCOPY VARCHAR2);
---------------------------------------------------------------------------------------
PROCEDURE rpt_rules(p_api_version   IN NUMBER,
                    p_run_id        IN NUMBER,
                    x_return_status IN OUT NOCOPY VARCHAR2,
                    x_msg_count     IN OUT NOCOPY NUMBER,
                    x_msg_data      IN OUT NOCOPY VARCHAR2);
---------------------------------------------------------------------------------------
PROCEDURE restat_rules(p_api_version   IN NUMBER,
                       p_run_id        IN NUMBER,
                       x_return_status IN OUT NOCOPY VARCHAR2,
                       x_msg_count     IN OUT NOCOPY NUMBER,
                       x_msg_data      IN OUT NOCOPY VARCHAR2);
---------------------------------------------------------------------------------------
PROCEDURE import_rules(p_api_version    IN NUMBER,
                       p_run_id         IN NUMBER,
                       p_maximum_errors IN PLS_INTEGER,
                       p_commit_size    IN PLS_INTEGER,
                       p_errors         IN OUT NOCOPY PLS_INTEGER,
                       x_return_status  IN OUT NOCOPY VARCHAR2,
                       x_msg_count      IN OUT NOCOPY NUMBER,
                       x_msg_data       IN OUT NOCOPY VARCHAR2);
---------------------------------------------------------------------------------------
PROCEDURE cnd_localized_texts(p_api_version    IN NUMBER,
                              p_run_id         IN NUMBER,
                              p_maximum_errors IN PLS_INTEGER,
                              p_commit_size    IN PLS_INTEGER,
                              p_errors         IN OUT NOCOPY PLS_INTEGER,
                              x_return_status  IN OUT NOCOPY VARCHAR2,
                              x_msg_count      IN OUT NOCOPY NUMBER,
                              x_msg_data       IN OUT NOCOPY VARCHAR2);
---------------------------------------------------------------------------------------
PROCEDURE krs_localized_texts(p_api_version    IN NUMBER,
                              p_run_id         IN NUMBER,
                              p_maximum_errors IN PLS_INTEGER,
                              p_commit_size    IN PLS_INTEGER,
                              p_errors         IN OUT NOCOPY PLS_INTEGER,
                              x_return_status  IN OUT NOCOPY VARCHAR2,
                              x_msg_count      IN OUT NOCOPY NUMBER,
                              x_msg_data       IN OUT NOCOPY VARCHAR2);
---------------------------------------------------------------------------------------
PROCEDURE xfr_localized_texts(p_api_version    IN NUMBER,
                              p_run_id         IN NUMBER,
                              p_maximum_errors IN PLS_INTEGER,
                              p_commit_size    IN PLS_INTEGER,
                              p_errors         IN OUT NOCOPY PLS_INTEGER,
                              x_return_status  IN OUT NOCOPY VARCHAR2,
                              x_msg_count      IN OUT NOCOPY NUMBER,
                              x_msg_data       IN OUT NOCOPY VARCHAR2);
---------------------------------------------------------------------------------------
PROCEDURE rpt_localized_texts(p_api_version   IN NUMBER,
                              p_run_id        IN NUMBER,
                              x_return_status IN OUT NOCOPY VARCHAR2,
                              x_msg_count     IN OUT NOCOPY NUMBER,
                              x_msg_data      IN OUT NOCOPY VARCHAR2);
---------------------------------------------------------------------------------------
PROCEDURE restat_localized_texts(p_api_version   IN NUMBER,
                                 p_run_id        IN NUMBER,
                                 x_return_status IN OUT NOCOPY VARCHAR2,
                                 x_msg_count     IN OUT NOCOPY NUMBER,
                                 x_msg_data      IN OUT NOCOPY VARCHAR2);
---------------------------------------------------------------------------------------
PROCEDURE import_localized_texts(p_api_version    IN NUMBER,
                                 p_run_id         IN NUMBER,
                                 p_maximum_errors IN PLS_INTEGER,
                                 p_commit_size    IN PLS_INTEGER,
                                 p_errors         IN OUT NOCOPY PLS_INTEGER,
                                 x_return_status  IN OUT NOCOPY VARCHAR2,
                                 x_msg_count      IN OUT NOCOPY NUMBER,
                                 x_msg_data       IN OUT NOCOPY VARCHAR2);
---------------------------------------------------------------------------------------
PROCEDURE refresh_statistics(p_api_version   IN NUMBER,
                             p_run_id        IN NUMBER,
                             x_return_status IN OUT NOCOPY VARCHAR2,
                             x_msg_count     IN OUT NOCOPY NUMBER,
                             x_msg_data      IN OUT NOCOPY VARCHAR2);
---------------------------------------------------------------------------------------
PROCEDURE rule_import(p_api_version    IN NUMBER,
                      p_run_id         IN OUT NOCOPY NUMBER,
                      p_maximum_errors IN PLS_INTEGER,
                      p_commit_size    IN PLS_INTEGER,
                      x_return_status  IN OUT NOCOPY VARCHAR2,
                      x_msg_count      IN OUT NOCOPY NUMBER,
                      x_msg_data       IN OUT NOCOPY VARCHAR2);

--------------------------
PROCEDURE lock_models (p_api_version    IN NUMBER,
                p_run_id         IN NUMBER,
		    p_commit_flag     IN VARCHAR2,
                x_locked_entities OUT NOCOPY SYSTEM.CZ_NUMBER_TBL_TYPE,
                x_return_status   OUT NOCOPY VARCHAR2,
                x_msg_count       OUT NOCOPY NUMBER,
                x_msg_data        OUT NOCOPY VARCHAR2);


---------------------------------------------------------------------------------------
/* Rule Import messages.

  CZRI_TXT_NULLORIGSYSREF
  Record rejected: Null value in ORIG_SYS_REF column. Please populate the column and then run the import
  program again.

  CZRI_TXT_NULLLANGUAGE
  Record rejected: Null value in LANGUAGE column. Please populate the column and then run the import
  program again.

  CZRI_TXT_NULLMODELID
  Record rejected: Null value in MODEL_ID column. Please populate the column and then run the import
  program again.

  CZRI_TXT_INVALIDMODEL
  Record rejected: The value in MODEL_ID refers to an invalid Model. Please correct the value and then run
  the import program again.

  CZRI_TXT_NULLSOURCELANG
  Record rejected: Null value in SOURCE_LANG column. Please populate the column and then run the import
  program again.

  CZRI_RLE_NULLORIGSYSREF
  Record rejected: Null value in ORIG_SYS_REF column. Please populate the column and then run the import
  program again.

  CZRI_RLE_NULLMODELID
  Record rejected: Null value in MODEL_ID column. Please populate the column and then run the import
  program again.

  CZRI_RLE_INVALIDMODEL
  Record rejected: The value in MODEL_ID column refers to an invalid Model. Please correct the value and
  then run the import program again.

  CZRI_RLE_NOSUCHFOLDER
  Record rejected: The value in RULE_FOLDER_ID column is invalid because it refers to a folder that does
  not exist. Please correct the value and then run the import program again.

  CZRI_RLE_NOROOTFOLDER
  Record rejected: Unable to find the root rule folder for the Model, specified by the value in DEVL_PROJECT_ID
  column. Please correct the value and then run the import program again.

  CZRI_RLE_NULLTEXTPOINTER
  Record rejected: Null value in FSK_LOCALIZED_TEXT_1 column. Please populate the column and then run the
  import program again.

  CZRI_RLE_NULLTYPE
  Record rejected: The value in RULE_TYPE column is null. The correct value is 300 for Configurator Extension
  and 200 for other types of rules. Please populate the column and then run the import program again.

  CZRI_RLE_INVALIDTYPE
  Record rejected: The value in RULE_TYPE column is incorrect. The correct value is 300 for Configurator
  Extension and 200 for other types of rules. Please correct the value and then run the import program again.

  CZRI_RLE_NULLCOMPONENTID
  Record rejected: Null value in COMPONENT_ID column for a Configurator Extension. Please populate the column
  and then run the import program again.

  CZRI_RLE_NULLEXPLID
  Record rejected: Null value in MODEL_REF_EXPL_ID column for a Configurator Extension. Please populate the
  column and then run the import program again.

  CZRI_RLE_NOREASONID
  Record rejected: Unable to resolve FSK_LOCALIZED_TEXT_1. No record with matching ORIG_SYS_REF exists in
  CZ_LOCALIZED_TEXTS for the specified Model.

  CZRI_RLE_NOUNSATISFIED
  Record rejected: Unable to resolve FSK_LOCALIZED_TEXT_2. No record with matching ORIG_SYS_REF exists
  in CZ_LOCALIZED_TEXTS for the specified Model.

  CZRI_RLE_NOCOMPONENTID
  Record rejected: Unable to resolve FSK_COMPONENT_ID for a Configurator Extension. No record with matching
  ORIG_SYS_REF exists in CZ_PS_NODES.

  CZRI_RLE_NOEXPLID
  Record rejected: Unable to resolve FSK_MODEL_REF_EXPL_ID for a Configurator Extension. No record with
  matching ORIG_SYS_REF exists in CZ_MODEL_REF_EXPLS.

  CZRI_RLE_PRESENTFLAG
  Record rejected: The value in PRESENTATION_FLAG column is incorrect. The correct value is '0'. Please
  correct the value and then run the import program again.

  CZRI_RLE_NULLNAME
  Record rejected: Null value in NAME column. Rule name is required. Please populate the column and then
  run the import program again.

  CZRI_TXT_DUPLICATE
  Record rejected as duplicate: A record with the same ORIG_SYS_REF and LANGUAGE values exists in Model
  with MODEL_ID = %MODELID.

  CZRI_RLE_DUPLICATE
  Record rejected as duplicate: A record with the same ORIG_SYS_REF exists in Model with DEVL_PROJECT_ID = %MODELID.

  CZRI_RLE_TRANSLATIONS
  Record rejected: Incorrect number of translations in CZ_LOCALIZED_TEXTS: %ACTUAL. Expected number of
  translations: %EXPECTED.

  CZRI_IMP_MAXIMUMERRORS
  Import session with RUN_ID = %RUNID has been terminated because the maximum number of errors has been reached.

  CZRI_IMP_ACTIVESESSION
  Import session with RUN_ID = %RUNID has been terminated because there are other import sessions running.

  CZRI_IMP_RUNID_EXISTS
  Control record with RUN_ID = %RUNID exists. Please delete the records from CZ_XFR_RUN_INFOS and
  CZ_XFR_RUN_RESULTS or run the import program again with a different RUN_ID value.

  CZRI_ERR_RUNID_INCORRECT
  No data found in the CZ_IMP_RULES table with RUN_ID = %RUNID.

  CZRI_ERR_DATA_INCORRECT
  No rules imported with RUN_ID = %RUNID. Please modify the source data and run the import program again.

  CZRI_IMP_SQLERROR
  The following error occurred: %ERRORTEXT. */
---------------------------------------------------------------------------------------
END;

 

/
