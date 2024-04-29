--------------------------------------------------------
--  DDL for Package XLA_CMP_TAD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLA_CMP_TAD_PKG" AUTHID CURRENT_USER AS
/* $Header: xlacptad.pkh 120.2.12010000.2 2008/09/05 22:06:33 vkasina ship $ */
/*======================================================================+
|             Copyright (c) 1995-2002 Oracle Corporation                |
|                       Redwood Shores, CA, USA                         |
|                         All rights reserved.                          |
+=======================================================================+
| PACKAGE NAME                                                          |
|    xla_cmp_tad_pkg                                                    |
|                                                                       |
| DESCRIPTION                                                           |
|    Transaction Account Builder Engine Compiler                        |
|                                                                       |
| HISTORY                                                               |
|    09-MAR-04 A.Quaglia      Created                                   |
|    04-JUN-04 A.Quaglia      Removed amb_context param from            |
|                             compile_application_tads_srs              |
|                                                                       |
|                                                                       |
|                                                                       |
|                                                                       |
|                                                                       |
+======================================================================*/
--Public constants
   C_RET_STS_SUCCESS      CONSTANT VARCHAR2(1)  := FND_API.G_RET_STS_SUCCESS;
   C_RET_STS_ERROR        CONSTANT VARCHAR2(1)  := FND_API.G_RET_STS_ERROR;
   C_RET_STS_UNEXP_ERROR  CONSTANT VARCHAR2(1)  :=
FND_API.G_RET_STS_UNEXP_ERROR;
   C_FALSE                CONSTANT VARCHAR2(1)  := FND_API.G_FALSE;
   C_TRUE                 CONSTANT VARCHAR2(1)  := FND_API.G_TRUE;
--Public types
   TYPE gt_table_V30       IS TABLE OF VARCHAR2(30);
   TYPE gt_table_V30_V30   IS TABLE OF VARCHAR2(30)   INDEX BY VARCHAR2(30);

--Dynamic Package Body variables
G_OA_MESSAGE       CONSTANT VARCHAR2(1) := xla_exceptions_pkg.C_OA_MESSAGE;

C_LEVEL_STATEMENT     CONSTANT NUMBER := FND_LOG.LEVEL_STATEMENT;
C_LEVEL_PROCEDURE     CONSTANT NUMBER := FND_LOG.LEVEL_PROCEDURE;
C_LEVEL_EVENT         CONSTANT NUMBER := FND_LOG.LEVEL_EVENT;
C_LEVEL_EXCEPTION     CONSTANT NUMBER := FND_LOG.LEVEL_EXCEPTION;
C_LEVEL_ERROR         CONSTANT NUMBER := FND_LOG.LEVEL_ERROR;
C_LEVEL_UNEXPECTED    CONSTANT NUMBER := FND_LOG.LEVEL_UNEXPECTED;

--1-STATEMENT, 2-PROCEDURE, 3-EVENT, 4-EXCEPTION, 5-ERROR, 6-UNEXPECTED

C_LEVEL_LOG_DISABLED  CONSTANT NUMBER := 99;

g_log_level           NUMBER;
g_log_enabled         BOOLEAN;


C_TMPL_BATCH_BUILD_CCID_STMTS CONSTANT  CLOB :=
'
--target_ccid not null and no segment value given
--we go straight to ccid validation
   UPDATE $TABLE_NAME$ gt
      SET gt.target_ccid = NVL( (SELECT gcc.code_combination_id
                                   FROM gl_code_combinations gcc
                                  WHERE gcc.chart_of_accounts_id = p_chart_of_accounts_id
                                    AND gcc.template_id          IS NULL
                                    AND gcc.enabled_flag         = ''Y''
                                    AND gcc.code_combination_id  = gt.target_ccid
                                )
                               ,-gt.target_ccid
                              )
          ,gt.processed_flag = ''Y''
          ,(
$C_TMPL_UPD_SET_SEGMENT_COMMAS$
           )
           = ( SELECT
$C_TMPL_SEL_NVL_SEGMENT_COMMAS$
              FROM gl_code_combinations gcc
             WHERE gcc.chart_of_accounts_id = p_chart_of_accounts_id
               AND gcc.template_id          IS NULL
               AND gcc.enabled_flag         = ''Y''
               AND gcc.code_combination_id  = gt.target_ccid
             )
    WHERE gt.target_ccid > 0
      AND 0 = (
               SELECT count(*)
                 FROM xla_tab_errors_gt xterr
                WHERE xterr.base_rowid = gt.ROWID
              )
$C_TMPL_WHERE_SEGMENT_NULL_ANDS$
;

--log errors for non existent or disabled ccids
   UPDATE $TABLE_NAME$ gt
      SET gt.target_ccid = $TAD_PACKAGE_NAME_1$.log_ccid_not_found_error
          (
            ''BATCH''                --p_mode
           ,gt.ROWID                 --p_rowid
           ,NULL                     --p_line_index
           ,p_chart_of_accounts_name --p_chart_of_accounts_name
           ,-gt.target_ccid          --p_ccid
           ,''$TAD_PACKAGE_NAME_1$.trans_account_def_batch'' --p_calling_function_name
           ,gt.account_type_code     --p_account_type_code
          )
    WHERE gt.target_ccid < 0
      AND 0 = (
               SELECT count(*)
                 FROM xla_tab_errors_gt xterr
                WHERE xterr.base_rowid = gt.ROWID
              )
      AND gt.processed_flag = ''Y''
;


   --target_ccid not null and some segment value given
   --Lookup ccid for missing segment values
   UPDATE $TABLE_NAME$ gt
      SET (
$C_TMPL_UPD_SET_SEGMENT_COMMAS$
          )
        = ( SELECT
$C_TMPL_SEL_NVL_SEGMENT_COMMAS$
              FROM gl_code_combinations gcc
             WHERE gcc.chart_of_accounts_id = p_chart_of_accounts_id
               AND gcc.template_id          IS NULL
               AND gcc.enabled_flag         = ''Y''
               AND gcc.code_combination_id  = gt.target_ccid
          )
    WHERE gt.target_ccid > 0
      AND gt.processed_flag IS NULL
      AND 0 = (
               SELECT count(*)
                 FROM xla_tab_errors_gt xterr
                WHERE xterr.base_rowid = gt.ROWID
              )
      AND 1 = (
               SELECT count(*)
                 FROM gl_code_combinations gcc
                WHERE gcc.chart_of_accounts_id = p_chart_of_accounts_id
                  AND gcc.template_id          IS NULL
                  AND gcc.enabled_flag         = ''Y''
                  AND gcc.code_combination_id  = gt.target_ccid
              )
;


   --Here we consider also the lines where target_ccid is null
   --If some rows still have missing segment values log an error
   UPDATE $TABLE_NAME$ gt
      SET gt.target_ccid = $TAD_PACKAGE_NAME_1$.log_null_segments_error
          (
            ''BATCH''                                      --p_mode
           ,gt.ROWID                                       --p_rowid
           ,NULL                                           --p_line_index
           ,p_chart_of_accounts_name                       --p_chart_of_accounts_name
           ,gt.target_ccid                                 --p_ccid
           ,''$TAD_PACKAGE_NAME_1$.trans_account_def_batch'' --p_calling_function_name
           ,gt.account_type_code                           --p_account_type_code
          )
    WHERE gt.processed_flag IS NULL
      AND ($C_TMPL_WHERE_SEGMENT_NULL_ORS$
          )
      AND 0 = (
               SELECT count(*)
                 FROM xla_tab_errors_gt xterr
                WHERE xterr.base_rowid = gt.ROWID
              )
 ;



   --All valid rows now have the segment values
   --Need to lookup for existing ccids from seg vals
   --for all lines
   UPDATE $TABLE_NAME$ gt
      SET gt.target_ccid = (SELECT CASE gcc.enabled_flag
                                   WHEN ''Y'' THEN gcc.code_combination_id
                                   ELSE -gcc.code_combination_id
                                   END
                              FROM gl_code_combinations gcc
                             WHERE gcc.chart_of_accounts_id = p_chart_of_accounts_id
                               AND gcc.template_id          IS NULL
$C_TMPL_WHERE_SEGMENTS_EQUALS$
                           )
    WHERE gt.processed_flag IS NULL
      AND 0 = (
               SELECT count(*)
                 FROM xla_tab_errors_gt xterr
                WHERE xterr.base_rowid = gt.ROWID
              )
;


   --Log errors for disabled ccids
   UPDATE $TABLE_NAME$ gt
      SET gt.target_ccid = $TAD_PACKAGE_NAME_1$.log_ccid_disabled_error
          (
            ''BATCH''                                        --p_mode
           ,gt.ROWID                                       --p_rowid
           ,NULL                                           --p_line_index
           ,p_chart_of_accounts_name                       --p_chart_of_accounts_name
           ,-gt.target_ccid                                --p_ccid
           ,''$TAD_PACKAGE_NAME_1$.trans_account_def_batch'' --p_calling_function_name
           ,gt.account_type_code                           --p_account_type_code
          )
    WHERE gt.target_ccid < 0
      AND gt.processed_flag IS NULL
      AND 0 = (
               SELECT count(*)
                 FROM xla_tab_errors_gt xterr
                WHERE xterr.base_rowid = gt.ROWID
              )
 ;


   --Build the concatenated segments string for all the valid rows
   UPDATE $TABLE_NAME$ gt
      SET gt.concatenated_segments =
$C_TMPL_CONCAT_SEGMENTS$
   WHERE 0 = (
               SELECT count(*)
                 FROM xla_tab_errors_gt xterr
                WHERE xterr.base_rowid = gt.ROWID
             );


   --Create missing ccids
   UPDATE $TABLE_NAME$ gt
      SET gt.target_ccid = $TAD_PACKAGE_NAME_1$.create_ccid --AFFIX
          (
            ''BATCH''                                        --p_mode
           ,gt.ROWID                                       --p_rowid
           ,NULL                                           --p_line_index
           ,p_chart_of_accounts_id                         --p_chart_of_accounts_id
           ,p_chart_of_accounts_name                       --p_chart_of_accounts_name
           ,''$TAD_PACKAGE_NAME_1$.trans_account_def_batch'' --p_calling_function_name
           ,l_current_date                                 --p_validation_date
           ,gt.concatenated_segments                       --p_concatenated_segments
          )
   WHERE gt.ROWID IN
   (
      SELECT MIN(gtint.ROWID)
        FROM $TABLE_NAME$ gtint
       WHERE gtint.target_ccid IS NULL
         AND gtint.processed_flag IS NULL
         AND 0 = (
                  SELECT count(*)
                    FROM xla_tab_errors_gt xterr
                   WHERE xterr.base_rowid = gtint.ROWID
                 )
      GROUP BY gtint.concatenated_segments
   )
;


   --Propagate the errors to all the other rows with the same segments
   UPDATE $TABLE_NAME$ gt
      SET gt.target_ccid =
             ( SELECT $TAD_PACKAGE_NAME_1$.log_error
                (
                  ''BATCH''         -- p_mode
                 ,gt.rowid          -- p_rowid
                 ,NULL              -- p_line_index
                 ,xtnc.msg_data     -- p_encoded_message
                )
                 FROM xla_tab_new_ccids_gt xtnc
                WHERE xtnc.code_combination_id IS NULL
                  AND xtnc.concatenated_segments = gt.concatenated_segments
               )
    WHERE gt.target_ccid IS NULL
      AND gt.processed_flag IS NULL
      AND 0 = (
            SELECT count(*)
              FROM xla_tab_errors_gt xterr
             WHERE xterr.base_rowid = gt.ROWID
           )
      AND gt.ROWID IN
       ( SELECT gt.ROWID
           FROM xla_tab_new_ccids_gt xtnc
          WHERE xtnc.code_combination_id IS NULL
            AND xtnc.concatenated_segments = gt.concatenated_segments
        );


   --Propagate the good ccids to all the other rows with the same segments
   UPDATE $TABLE_NAME$ gt
      SET gt.target_ccid = ( SELECT xtnc.code_combination_id
                               FROM xla_tab_new_ccids_gt xtnc
                              WHERE xtnc.code_combination_id IS NOT NULL
                                AND xtnc.concatenated_segments = gt.concatenated_segments
                           )
    WHERE gt.target_ccid IS NULL
      AND gt.processed_flag IS NULL
      AND 0 = (
               SELECT count(*)
                 FROM xla_tab_errors_gt xterr
                WHERE xterr.base_rowid = gt.ROWID
              )
      AND gt.ROWID NOT IN (SELECT xtnc.base_rowid
                             FROM xla_tab_new_ccids_gt xtnc
                          );

   --For lines having at least one error update the message count field
   UPDATE $TABLE_NAME$ gt
      SET gt.msg_count = (SELECT count(*)
                            FROM xla_tab_errors_gt xterr
                           WHERE xterr.base_rowid = gt.ROWID
                        )
     WHERE 0 < (
                  SELECT count(*)
                    FROM xla_tab_errors_gt xterr
                   WHERE xterr.base_rowid = gt.ROWID
               );

   --For lines having exactly one error pull the message into the main table
   UPDATE $TABLE_NAME$ gt
      SET gt.msg_data = (SELECT xterr.msg_data
                           FROM xla_tab_errors_gt xterr
                          WHERE xterr.base_rowid = gt.ROWID
                        )
     WHERE 1 = (
                  SELECT count(*)
                    FROM xla_tab_errors_gt xterr
                   WHERE xterr.base_rowid = gt.ROWID
                 );
';


/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
| compile_application_tads_srs                                          |
|                                                                       |
| SRS wrapper for compile_api                                           |
|	p_retcode := 0 means that the compilation was successful.       |
|	p_retcode := 2 means that errors were encountered and that the  |
|                      generation of the API was unsuccessful.          |
+======================================================================*/
PROCEDURE compile_application_tads_srs
                           ( p_errbuf               OUT NOCOPY VARCHAR2
                            ,p_retcode              OUT NOCOPY NUMBER
                            ,p_application_id       IN         NUMBER
                           );


/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| compile_application_tads                                              |
|                                                                       |
| It generates the Transaction Account Builder Engine for the specified |
| application and AMB Context Code.                                     |
| It generates one package header and one package body in the <APPS>    |
| schema for each enabled Transaction Account Definition.               |
|                                                                       |
| It returns a BOOLEAN value.                                           |
|     TRUE  means that the compilation was successful.                  |
|     FALSE means that errors were encountered and that the generation  |
|                 of the API was unsuccessful.                          |
+======================================================================*/
FUNCTION compile_application_tads
                           ( p_application_id       IN    NUMBER
                           )
RETURN BOOLEAN
;

/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| compile_tad                                                           |
|                                                                       |
| It generates the Transaction Account Builder Engine for the specified |
| Transaction Account Definition.                                       |
| It generates one package header and one package body in the <APPS>    |
| schema.                                                               |
|                                                                       |
| It returns a BOOLEAN value.                                           |
|     TRUE  means that the compilation was successful.                  |
|     FALSE means that errors were encountered and that the generation  |
|                 of the API was unsuccessful.                          |
+======================================================================*/
FUNCTION compile_tad
                           ( p_application_id               IN    NUMBER
                            ,p_account_definition_code      IN    VARCHAR2
                            ,p_account_definition_type_code IN    VARCHAR2
                            ,p_amb_context_code             IN    VARCHAR2
                           )
RETURN BOOLEAN;

/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| compile_tad_AUTONOMUS                                                 |
|                                                                       |
| Same as compile_tad but peforms the actions in an autonomous          |
| transaction in order not to delete the content of the global          |
| temporary tables.                                                     |
|                                                                       |
|                                                                       |
| It returns a BOOLEAN value.                                           |
|     TRUE  means that the compilation was successful.                  |
|     FALSE means that errors were encountered and that the generation  |
|                 of the API was unsuccessful.                          |
+======================================================================*/
FUNCTION compile_tad_AUTONOMOUS
                           ( p_application_id               IN    NUMBER
                            ,p_account_definition_code      IN    VARCHAR2
                            ,p_account_definition_type_code IN    VARCHAR2
                            ,p_amb_context_code             IN    VARCHAR2
                           )
RETURN BOOLEAN;

/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| get_tad_package_name                                                  |
|                                                                       |
| Builds the package name for the specified Transaction Account         |
| Definitions.                                                          |
|                                                                       |
| It assigns the hash_id if it is null.                                 |
|                                                                       |
| It returns a BOOLEAN value.                                           |
|     TRUE  means that the function was successful.                     |
|     FALSE means that errors were encountered
|                                                                       |
+======================================================================*/

FUNCTION get_tad_package_name
                   (
                      p_application_id               IN  NUMBER
                     ,p_account_definition_code      IN  VARCHAR2
                     ,p_account_definition_type_code IN  VARCHAR2
                     ,p_amb_context_code             IN  VARCHAR2
                     ,p_tad_package_name             OUT NOCOPY VARCHAR2
                   )
RETURN BOOLEAN;




END xla_cmp_tad_pkg;

/
