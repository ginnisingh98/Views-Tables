--------------------------------------------------------
--  DDL for Package Body XLA_CMP_TAB_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLA_CMP_TAB_PKG" AS
/* $Header: xlacptab.pkb 120.15.12000000.2 2007/10/09 08:10:24 vkasina ship $ */
/*======================================================================+
|             Copyright (c) 1995-2002 Oracle Corporation                |
|                       Redwood Shores, CA, USA                         |
|                         All rights reserved.                          |
+=======================================================================+
| PACKAGE NAME                                                          |
|    xla_cmp_tab_pkg                                                    |
|                                                                       |
| DESCRIPTION                                                           |
|    Transaction Account Builder API Compiler                           |
|                                                                       |
| HISTORY                                                               |
|    26-JAN-04 A.Quaglia      Created                                   |
|    04-JUN-04 A.Quaglia      Changed hash_id to NUMBER                 |
|                             ,row_id to base_rowid                     |
|                             ,ccid, target_ccid to NUMBER(15)          |
|    07-JUN-04 A.Quaglia      Fixed NOCOPY in one forward declaration   |
|    17-JUN-04 A.Quaglia      compile_api_srs: added messaging for conc |
|                             request.                                  |
|                             Some params were still IN OUT instd of OUT|
|    18-JUN-04 A.Quaglia      Added concatenated_segments to the API    |
|    21-JUN-04 A.Quaglia      get_ccid_additional_info:                 |
|                                removed x_concatenated_values          |
|    21-JUN-04 A.Quaglia      build_declarations:                       |
|                                removed condition on compile status    |
|                                when selecting the TAT sources:        |
|                                Introduced local variables so that OUT |
|                                params are assigned at the end.        |
|                             build_implementations:                    |
|                                removed condition on compile status    |
|                                when selecting the TAT sources:        |
|                             build_global_temp_table                   |
|                                removed condition on compile status    |
|                               when selecting the TAT sources:         |
|    30-JUL-04 A.Quaglia      changed message tokens                    |
|    18-MAI-05 K.Boussema     added the column dummy_rowid in GT tables |
|                                to fix bug 4344773                     |
|    10-MAR-2006 Jorge Larre  Bug 5088359                               |
|       Add ORDER BY xsb.source_code to the selects that retrieve the   |
|       sources to build the interface table to be in sync with the     |
|       select that retrieves the source to build the compiled package. |
|    11-AUG-2006 Jorge Larre  Bug 5318196                               |
|       a)In procedure write_online_tab (C_TMPL_TAB_WRITE_PROC_IMPL)    |
|         the determination of the new index for inserting a new row in |
|         g_array_xla_tab must be done with COUNT + 1 instead of COUNT. |
|         The loop that uses l_watermark must be begin with FIRST       |
|         instead of 0.                                                 |
|       b)In procedure read_online_tab (C_TMPL_TAB_READ_PROC_IMPL)      |
|         the loop that uses l_watermark must be begin with FIRST       |
|         instead of 0.                                                 |
|    15-AUG-2006 Jorge Larre  Bug 5318196                               |
|       a)In procedure write_online_tab (C_TMPL_TAB_WRITE_PROC_IMPL)    |
|         the array may be empty, so we must use a variable to store    |
|         the value of FIRST and nullify it with 1. New variable:       |
|         l_start.                                                      |
|       b)In procedure read_online_tab (C_TMPL_TAB_READ_PROC_IMPL)      |
|         the array may be empty, so we must use a variable to store    |
|         the value of FIRST and nullify it with 1. New variable:       |
|         l_start.                                                      |
+======================================================================*/

   --
   -- Private exceptions
   --

   le_fatal_error                   EXCEPTION;

   --
   -- Private types
   --
   --
   -- Private constants
   --

   g_chr_newline      CONSTANT VARCHAR2(1) := xla_environment_pkg.g_chr_newline;

   G_STANDARD_MESSAGE CONSTANT VARCHAR2(1) := xla_exceptions_pkg.C_STANDARD_MESSAGE;
   G_OA_MESSAGE       CONSTANT VARCHAR2(1) := xla_exceptions_pkg.C_OA_MESSAGE;

   --Set the message mode to use the message stack instead of raising an exception
   g_msg_mode                CONSTANT VARCHAR2(1) := G_OA_MESSAGE;


--+==========================================================================+
--|            package specification template                                |
--+==========================================================================+

--
C_TMPL_TAB_PACKAGE_SPEC  CONSTANT  CLOB :=
'CREATE OR REPLACE PACKAGE $TAB_API_PACKAGE_NAME_1$ AS' ||
g_chr_newline||
'/'||'* $Header: xlacptab.pkb 120.15.12000000.2 2007/10/09 08:10:24 vkasina ship $   */' ||
g_chr_newline||
'/'|| '*======================================================================+
|                Copyright (c) 2004 Oracle Corporation                  |
|                       Redwood Shores, CA, USA                         |
|                         All rights reserved.                          |
+=======================================================================+
| PACKAGE NAME                                                          |
|     $TAB_API_PACKAGE_NAME_2$
|                                                                       |
| DESCRIPTION                                                           |
|                                                                       |
|     Transaction Account Builder API.                                  |
|                                                                       |
|     Package generated by Oracle Subledger Accounting for              |
|                                                                       |
|     $APPLICATION_NAME$
|     (application_id: $APPLICATION_ID$
|                                                                       |
|     ATTENTION:                                                        |
|     This package has been automatically generated by the              |
|     Oracle Subledger Accounting Compiler. You should not modify its   |
|     content manually.                                                 |
|     This package has been generated according to the Transaction      |
|     Account Types setup for this application.                         |
|     In case of issues independent of the setup (e.g. GSCC errors)     |
|     please log a bug against Oracle Subledger Accounting.             |
|                                                                       |
|                                                                       |
| HISTORY                                                               |
|     $HISTORY$
|                                                                       |
+=======================================================================*'
||'/'
||
'

--Public constants
   C_RET_STS_SUCCESS      CONSTANT VARCHAR2(1)  := FND_API.G_RET_STS_SUCCESS;
   C_RET_STS_ERROR        CONSTANT VARCHAR2(1)  := FND_API.G_RET_STS_ERROR;
   C_RET_STS_UNEXP_ERROR  CONSTANT VARCHAR2(1)  := FND_API.G_RET_STS_UNEXP_ERROR;
   C_FALSE                CONSTANT VARCHAR2(1)  := FND_API.G_FALSE;
   C_TRUE                 CONSTANT VARCHAR2(1)  := FND_API.G_TRUE;

--Public record types
$TAB_REC_TYPE_DECLARATIONS$


--Public table types
$TAB_TABLE_TYPE_DECLARATIONS$


--Public variables
$TAB_TABLE_VAR_DECLARATIONS$


--Public procedures
   PROCEDURE run
   (
     p_api_version                      IN NUMBER
    ,p_account_definition_type_code     IN VARCHAR2
    ,p_account_definition_code          IN VARCHAR2
    ,p_transaction_coa_id               IN NUMBER
    ,p_mode                             IN VARCHAR2
    ,x_return_status                    OUT NOCOPY VARCHAR2
    ,x_msg_count                        OUT NOCOPY NUMBER
    ,x_msg_data                         OUT NOCOPY VARCHAR2
   );

   PROCEDURE reset_online_interface
   (
     p_api_version                      IN  NUMBER
    ,x_return_status                    OUT NOCOPY VARCHAR2
    ,x_msg_count                        OUT NOCOPY NUMBER
    ,x_msg_data                         OUT NOCOPY VARCHAR2
   );

$TAB_WRITE_PROC_DECLARATIONS$

$TAB_READ_PROC_DECLARATIONS$

END $TAB_API_PACKAGE_NAME_1$;
';

--+==========================================================================+
--|            end of package specification template                         |
--+==========================================================================+

--+==========================================================================+
--|            global temporary table declaration template                   |
--+==========================================================================+
C_TMPL_TAB_GLOBAL_TEMP_TABLE  CONSTANT  CLOB :=
'CREATE GLOBAL TEMPORARY TABLE $ORACLE_USER_NAME$.$GLOBAL_TABLE_NAME$
( SOURCE_DISTRIBUTION_ID_CHAR_1      VARCHAR2(240)          --INPUT
 ,SOURCE_DISTRIBUTION_ID_CHAR_2      VARCHAR2(240)          --INPUT
 ,SOURCE_DISTRIBUTION_ID_CHAR_3      VARCHAR2(240)          --INPUT
 ,SOURCE_DISTRIBUTION_ID_CHAR_4      VARCHAR2(240)          --INPUT
 ,SOURCE_DISTRIBUTION_ID_CHAR_5      VARCHAR2(240)          --INPUT
 ,SOURCE_DISTRIBUTION_ID_NUM_1       NUMBER                 --INPUT
 ,SOURCE_DISTRIBUTION_ID_NUM_2       NUMBER                 --INPUT
 ,SOURCE_DISTRIBUTION_ID_NUM_3       NUMBER                 --INPUT
 ,SOURCE_DISTRIBUTION_ID_NUM_4       NUMBER                 --INPUT
 ,SOURCE_DISTRIBUTION_ID_NUM_5       NUMBER                 --INPUT
 ,ACCOUNT_TYPE_CODE                  VARCHAR2(30) NOT NULL  --INPUT
$SOURCE_TABLE_FIELD_DECLARATIONS$
 ,PROCESSED_FLAG                     VARCHAR2(1)            --INTERNAL
 ,SEGMENT1                           VARCHAR2(30)           --INTERNAL
 ,SEGMENT2                           VARCHAR2(30)           --INTERNAL
 ,SEGMENT3                           VARCHAR2(30)           --INTERNAL
 ,SEGMENT4                           VARCHAR2(30)           --INTERNAL
 ,SEGMENT5                           VARCHAR2(30)           --INTERNAL
 ,SEGMENT6                           VARCHAR2(30)           --INTERNAL
 ,SEGMENT7                           VARCHAR2(30)           --INTERNAL
 ,SEGMENT8                           VARCHAR2(30)           --INTERNAL
 ,SEGMENT9                           VARCHAR2(30)           --INTERNAL
 ,SEGMENT10                          VARCHAR2(30)           --INTERNAL
 ,SEGMENT11                          VARCHAR2(30)           --INTERNAL
 ,SEGMENT12                          VARCHAR2(30)           --INTERNAL
 ,SEGMENT13                          VARCHAR2(30)           --INTERNAL
 ,SEGMENT14                          VARCHAR2(30)           --INTERNAL
 ,SEGMENT15                          VARCHAR2(30)           --INTERNAL
 ,SEGMENT16                          VARCHAR2(30)           --INTERNAL
 ,SEGMENT17                          VARCHAR2(30)           --INTERNAL
 ,SEGMENT18                          VARCHAR2(30)           --INTERNAL
 ,SEGMENT19                          VARCHAR2(30)           --INTERNAL
 ,SEGMENT20                          VARCHAR2(30)           --INTERNAL
 ,SEGMENT21                          VARCHAR2(30)           --INTERNAL
 ,SEGMENT22                          VARCHAR2(30)           --INTERNAL
 ,SEGMENT23                          VARCHAR2(30)           --INTERNAL
 ,SEGMENT24                          VARCHAR2(30)           --INTERNAL
 ,SEGMENT25                          VARCHAR2(30)           --INTERNAL
 ,SEGMENT26                          VARCHAR2(30)           --INTERNAL
 ,SEGMENT27                          VARCHAR2(30)           --INTERNAL
 ,SEGMENT28                          VARCHAR2(30)           --INTERNAL
 ,SEGMENT29                          VARCHAR2(30)           --INTERNAL
 ,SEGMENT30                          VARCHAR2(30)           --INTERNAL
 ,TARGET_CCID                        NUMBER(15)             --OUTPUT
 ,CONCATENATED_SEGMENTS              VARCHAR2(2000)         --OUTPUT
 ,MSG_COUNT                          NUMBER                 --OUTPUT
 ,MSG_DATA                           VARCHAR2(2000)         --OUTPUT
 ,DUMMY_ROWID                        UROWID                 --INTERNAL
)
ON COMMIT DELETE ROWS';

   C_TMPL_SOURCE_TABLE_FIELD_DECL  CONSTANT CLOB :=
'    ,$SOURCE_CODE$     $SOURCE_SPECIFIC_DATATYPE$ --INPUT';


   C_TMPL_TAB_GLOBAL_TABLE_NAME    CONSTANT CLOB :=
'$PRODUCT_ABBR$_XLA_TAB$OBJECT_NAME_AFFIX$GT';

--N.B.: the following constant is not used in the templates
   C_TMPL_TAB_PLSQL_TABLE_NAME    CONSTANT CLOB :=
'g_array_xla_tab$OBJECT_NAME_AFFIX$';


--+==========================================================================+
--|            package body template                                         |
--+==========================================================================+

--
C_TMPL_TAB_PACKAGE_BODY  CONSTANT  CLOB :=
'CREATE OR REPLACE PACKAGE BODY $TAB_API_PACKAGE_NAME_1$ AS' ||
g_chr_newline||
'/'||'* $Header: xlacptab.pkb 120.15.12000000.2 2007/10/09 08:10:24 vkasina ship $   */' ||
g_chr_newline||
'/'|| '*======================================================================+
|                Copyright (c) 2004 Oracle Corporation                  |
|                       Redwood Shores, CA, USA                         |
|                         All rights reserved.                          |
+=======================================================================+
| PACKAGE NAME                                                          |
|     $TAB_API_PACKAGE_NAME_2$
|                                                                       |
| DESCRIPTION                                                           |
|                                                                       |
|     Transaction Account Builder API.                                  |
|                                                                       |
|     Package generated by Oracle Subledger Accounting for              |
|                                                                       |
|     $APPLICATION_NAME$
|     (application_id: $APPLICATION_ID$
|                                                                       |
|     ATTENTION:                                                        |
|     This package has been automatically generated by the              |
|     Oracle Subledger Accounting Compiler. You should not modify its   |
|     content manually.                                                 |
|     This package has been generated according to the Transaction      |
|     Account Types setup for this application.                         |
|     In case of issues independent of the setup (e.g. GSCC errors)     |
|     please log a bug against Oracle Subledger Accounting.             |
|                                                                       |
|                                                                       |
| HISTORY                                                               |
|     $HISTORY$
|                                                                       |
+=======================================================================*'
||'/'
||
'
--Private exceptions
   le_fatal_error  EXCEPTION;
--Private constants
   C_API_VERSION          CONSTANT NUMBER(1)    := 1;
   C_PACKAGE_NAME         CONSTANT VARCHAR2(30) := ''$TAB_API_PACKAGE_NAME_1$'';


--=============================================================================
--               *********** Local Trace Routine **********
--=============================================================================
C_LEVEL_STATEMENT     CONSTANT NUMBER := FND_LOG.LEVEL_STATEMENT;
C_LEVEL_PROCEDURE     CONSTANT NUMBER := FND_LOG.LEVEL_PROCEDURE;
C_LEVEL_EVENT         CONSTANT NUMBER := FND_LOG.LEVEL_EVENT;
C_LEVEL_EXCEPTION     CONSTANT NUMBER := FND_LOG.LEVEL_EXCEPTION;
C_LEVEL_ERROR         CONSTANT NUMBER := FND_LOG.LEVEL_ERROR;
C_LEVEL_UNEXPECTED    CONSTANT NUMBER := FND_LOG.LEVEL_UNEXPECTED;

C_LEVEL_LOG_DISABLED  CONSTANT NUMBER := 99;
C_DEFAULT_MODULE      CONSTANT VARCHAR2(240) := ''$oracle_user_name$.plsql.$TAB_API_PACKAGE_NAME_3$'';

g_log_level           NUMBER;
g_log_enabled         BOOLEAN;

PROCEDURE trace
       ( p_module                     IN VARCHAR2 DEFAULT C_DEFAULT_MODULE
        ,p_msg                        IN VARCHAR2
        ,p_level                      IN NUMBER
        )
IS
BEGIN
   IF (p_msg IS NULL AND p_level >= g_log_level) THEN
      fnd_log.message(p_level, p_module);
   ELSIF p_level >= g_log_level THEN
      fnd_log.string(p_level, p_module, p_msg);
   END IF;

EXCEPTION
WHEN app_exceptions.application_exception THEN
   RAISE;
WHEN OTHERS THEN
   fnd_message.set_name(''XLA'', ''XLA_TAB_UNHANDLED_EXCEPTION'');
   fnd_message.set_token( ''PROCEDURE''
                         ,''$TAB_API_PACKAGE_NAME_3$.trace'');
   RAISE;
END trace;

--Private procedure
   PROCEDURE reset_online_interface
   IS
      l_log_module           VARCHAR2 (2000);
   BEGIN
      IF g_log_enabled THEN
         l_log_module := C_DEFAULT_MODULE||''.reset_online_interface'';
      END IF;

      IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
         trace
           ( p_module   => l_log_module
            ,p_msg      => ''BEGIN '' || l_log_module
            ,p_level    => C_LEVEL_PROCEDURE);
      END IF;

      --Remove all the elements from the PLSQL tables
$RESET_ONLINE_INTERFACES_STMTS$

      IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
         trace
           (p_msg      => ''END '' || l_log_module
            ,p_level    => C_LEVEL_PROCEDURE);
      END IF;

   EXCEPTION
   WHEN OTHERS THEN
      RAISE;
   END reset_online_interface;



--Public procedures
   PROCEDURE run
   (
     p_api_version                      IN NUMBER
    ,p_account_definition_type_code     IN VARCHAR2
    ,p_account_definition_code          IN VARCHAR2
    ,p_transaction_coa_id               IN NUMBER
    ,p_mode                             IN VARCHAR2
    ,x_return_status                    OUT NOCOPY VARCHAR2
    ,x_msg_count                        OUT NOCOPY NUMBER
    ,x_msg_data                         OUT NOCOPY VARCHAR2
   )
   IS
      l_return_status     VARCHAR2(1);
      l_return_msg_name   VARCHAR2(30);
      l_msg_count         NUMBER;
      l_msg_data          VARCHAR2(2000);
      l_log_module           VARCHAR2 (2000);
   BEGIN
      IF g_log_enabled THEN
         l_log_module := C_DEFAULT_MODULE||''.run'';
      END IF;

      IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
         trace
           ( p_module   => l_log_module
            ,p_msg      => ''BEGIN '' || l_log_module
            ,p_level    => C_LEVEL_PROCEDURE);
      END IF;

      --Initialize the global message table
      FND_MSG_PUB.Initialize;

      xla_tab_pub_pkg.run
         (
           p_api_version                  => p_api_version
          ,p_application_id               => $APPLICATION_ID_2$
          ,p_account_definition_type_code => p_account_definition_type_code
          ,p_account_definition_code      => p_account_definition_code
          ,p_transaction_coa_id           => p_transaction_coa_id
          ,p_mode                         => p_mode
          ,x_return_status                => l_return_status
          ,x_msg_count                    => l_msg_count
          ,x_msg_data                     => l_msg_data
         );

      IF l_return_status <> C_RET_STS_SUCCESS
      THEN
         --Push the error message again so that it does not get lost
         IF l_msg_data IS NOT NULL
         THEN
            fnd_msg_pub.initialize;

            fnd_message.set_encoded
            (
              encoded_message => l_msg_data
            );

            --Add it to the message table
            fnd_msg_pub.add;

            --Reset single message variables
            l_msg_count := NULL;
            l_msg_data  := NULL;
         END IF;
         RAISE le_fatal_error;
      END IF;

      --Assign out parameters
      x_msg_count     := NVL(l_msg_count, 0);
      x_msg_data      := l_msg_data;
      x_return_status := C_RET_STS_SUCCESS;

      IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
         trace
           ( p_module   => l_log_module
            ,p_msg      => ''END '' || l_log_module
            ,p_level    => C_LEVEL_PROCEDURE);
      END IF;

   EXCEPTION
   WHEN le_fatal_error THEN
      --Remove all the elements from the PLSQL table
      reset_online_interface;
      --If there is a no token message to log
      --Set the failure message on the stack
      fnd_message.set_name
            (
              application => ''XLA''
             ,name        => ''XLA_TAB_RUN_FAILED''
         );
      fnd_message.set_token( ''FUNCTION_NAME''
                            ,''$TAB_API_PACKAGE_NAME_3$.run'');

      --Add it to the message table
      fnd_msg_pub.add;

      --If there is only one message retrieve it
      fnd_msg_pub.Count_And_Get
         (
           p_count => l_msg_count
          ,p_data  => l_msg_data
         );
      --Put the message on the stack to ensure old Forms detect the error
      fnd_message.set_encoded
         (
           encoded_message => l_msg_data
         );
      --Assign out parameters
      x_msg_count     := l_msg_count;
      x_msg_data      := l_msg_data;
      IF l_return_status IS NOT NULL
      THEN
         x_return_status := l_return_status;
      ELSE
         x_return_status := C_RET_STS_UNEXP_ERROR;
      END IF;
   WHEN OTHERS THEN
      --Remove all the elements from the PLSQL table
      reset_online_interface;
      --Add the standard unexpected error message
      fnd_msg_pub.Add_Exc_Msg
         ( p_pkg_name       => C_PACKAGE_NAME
          ,p_procedure_name => ''run''
         );
      --If there is only one message retrieve it
      fnd_msg_pub.Count_And_Get
         (
           p_count => l_msg_count
          ,p_data  => l_msg_data
         );
      --Put the message on the stack to ensure all Forms detect the error
      fnd_message.set_encoded
         (
           encoded_message => l_msg_data
         );
      --Assign out parameters
      x_msg_count     := l_msg_count;
      x_msg_data      := l_msg_data;
      x_return_status := C_RET_STS_UNEXP_ERROR;
   END run;


   PROCEDURE reset_online_interface
    (
      p_api_version                      IN  NUMBER
     ,x_return_status                    OUT NOCOPY VARCHAR2
     ,x_msg_count                        OUT NOCOPY NUMBER
     ,x_msg_data                         OUT NOCOPY VARCHAR2
    )
   IS
      l_return_status         VARCHAR2(1);
      l_return_msg_name       VARCHAR2(30);

      l_msg_count             NUMBER;
      l_msg_data              VARCHAR2(2000);

      l_log_module           VARCHAR2 (2000);

   BEGIN
      IF g_log_enabled THEN
         l_log_module := C_DEFAULT_MODULE||''.reset_online_interface'';
      END IF;

      IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
         trace
           ( p_module   => l_log_module
            ,p_msg      => ''BEGIN '' || l_log_module
            ,p_level    => C_LEVEL_PROCEDURE);
      END IF;

      --Initialize the global message table
      FND_MSG_PUB.Initialize;

      --Initialize return status and message local variables
      l_return_msg_name:= NULL;
      l_return_status  := NULL;

      IF NOT FND_API.Compatible_API_Call
         (
           p_current_version_number => C_API_VERSION
          ,p_caller_version_number  => p_api_version
          ,p_api_name               => ''reset_online_interface''
          ,p_pkg_name               => C_PACKAGE_NAME
         )
      THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      --Remove all the elements from the PLSQL tables
      reset_online_interface;

      --Assign out parameters
      x_msg_count     := l_msg_count;
      x_msg_data      := l_msg_data;

      IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
         trace
           ( p_module   => l_log_module
            ,p_msg      => ''END '' || l_log_module
            ,p_level    => C_LEVEL_PROCEDURE);
      END IF;

   EXCEPTION
   WHEN le_fatal_error THEN
      --If there is a no token message to log
      IF l_return_msg_name IS NOT NULL
      THEN
         --Set it on the stack
         fnd_message.set_name
            (
              application => ''XLA''
             ,name        => l_return_msg_name
         );
         --Add it to the message table
         fnd_msg_pub.add;
      END IF;
      --If there is only one message retrieve it
      fnd_msg_pub.Count_And_Get
         (
           p_count => l_msg_count
          ,p_data  => l_msg_data
         );
      --Put the message on the stack to ensure old Forms detect the error
      fnd_message.set_encoded
         (
           encoded_message => l_msg_data
         );
      --Assign out parameters
      x_msg_count     := l_msg_count;
      x_msg_data      := l_msg_data;
      IF l_return_status IS NOT NULL
      THEN
         x_return_status := l_return_status;
      ELSE
         x_return_status := C_RET_STS_UNEXP_ERROR;
      END IF;
   WHEN OTHERS THEN
      --Add the standard unexpected error message
      fnd_msg_pub.Add_Exc_Msg
         ( p_pkg_name       => C_PACKAGE_NAME
          ,p_procedure_name => ''reset_online_interface''
         );
      --If there is only one message retrieve it
      fnd_msg_pub.Count_And_Get
         (
           p_count => l_msg_count
          ,p_data  => l_msg_data
         );
      --Put the message on the stack to ensure all Forms detect the error
      fnd_message.set_encoded
         (
           encoded_message => l_msg_data
         );
      --Assign out parameters
      x_msg_count     := l_msg_count;
      x_msg_data      := l_msg_data;
      x_return_status := C_RET_STS_UNEXP_ERROR;
   END reset_online_interface;


$TAB_WRITE_PROC_IMPLS$

$TAB_READ_PROC_IMPLS$


--Trace initialization
BEGIN
   g_log_level      := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
   g_log_enabled    := fnd_log.test
                          (log_level  => g_log_level
                          ,module     => C_DEFAULT_MODULE);

   IF NOT g_log_enabled  THEN
      g_log_level := C_LEVEL_LOG_DISABLED;
   END IF;


END $TAB_API_PACKAGE_NAME_1$;
';

--+==========================================================================+
--|            end of package body template                                  |
--+==========================================================================+



C_TMPL_TAB_RESET_ONLINE_INT_ST CONSTANT VARCHAR2(100) :=
'      g_array_xla_tab$OBJECT_NAME_AFFIX$.DELETE;
';



   C_TMPL_TAB_REC_TYPE_DECLAR  CONSTANT  CLOB :=
'   TYPE t_rec_xla_tab$OBJECT_NAME_AFFIX$ IS RECORD
   ( base_rowid                         UROWID                    --INTERNAL
    ,source_distribution_id_num_1       NUMBER                    --INPUT
    ,source_distribution_id_num_2       NUMBER                    --INPUT
    ,source_distribution_id_num_3       NUMBER                    --INPUT
    ,source_distribution_id_num_4       NUMBER                    --INPUT
    ,source_distribution_id_num_5       NUMBER                    --INPUT
    ,account_type_code                  VARCHAR2(30) --NOT NULL   --INPUT
    --START of source list
$SOURCE_REC_FIELD_DECLARATIONS$
    --END of source list
    ,target_ccid                        NUMBER(15)                --OUTPUT
    ,concatenated_segments              VARCHAR2(2000)            --OUTPUT
    ,msg_count                          NUMBER                    --OUTPUT
    ,msg_data                           VARCHAR2(2000)            --OUTPUT
   );
   ';

   C_TMPL_SOURCE_REC_FIELD_DECLAR  CONSTANT CLOB :=
'    ,$SOURCE_CODE$ $SOURCE_SPECIFIC_DATATYPE$ --INPUT';

   C_CHAR_SOURCE_SIZE              CONSTANT INTEGER         := 80;

   C_TMPL_TAB_TABLE_TYPE_DECLAR    CONSTANT CLOB :=
'   TYPE t_array_xla_tab$OBJECT_NAME_AFFIX$
      IS TABLE OF t_rec_xla_tab$OBJECT_NAME_AFFIX$ INDEX BY BINARY_INTEGER;';

   C_TMPL_TAB_TABLE_VAR_DECLAR     CONSTANT CLOB :=
'   g_array_xla_tab$OBJECT_NAME_AFFIX$   t_array_xla_tab$OBJECT_NAME_AFFIX$;';


   C_TMPL_SOURCE_REC_FIELD_ASSGN   CONSTANT CLOB :=
'      g_array_xla_tab$OBJECT_NAME_AFFIX$(l_new_idx).$SOURCE_CODE_LEFT$ := $SOURCE_CODE_RIGHT$;';

   C_TMPL_TAB_WRITE_PROC_NAME      CONSTANT VARCHAR2(100) :=
      'write_online_tab$OBJECT_NAME_AFFIX$';

   C_TMPL_TAB_WRITE_PROC_DECLAR    CONSTANT CLOB :=
'   PROCEDURE ' || C_TMPL_TAB_WRITE_PROC_NAME || '
   (
     p_api_version                      IN NUMBER           --INPUT NOT NULL
    ,p_source_distrib_id_num_1          IN NUMBER           --INPUT
    ,p_source_distrib_id_num_2          IN NUMBER           --INPUT
    ,p_source_distrib_id_num_3          IN NUMBER           --INPUT
    ,p_source_distrib_id_num_4          IN NUMBER           --INPUT
    ,p_source_distrib_id_num_5          IN NUMBER           --INPUT
    ,p_account_type_code                IN VARCHAR2         --INPUT NOT NULL
    --START of source list
$SOURCE_PROC_PARAM_DECLARATIONS$
    --END of source list
    ,x_return_status                    OUT NOCOPY VARCHAR2 --OUTPUT
    ,x_msg_count                        OUT NOCOPY NUMBER   --OUTPUT
    ,x_msg_data                         OUT NOCOPY VARCHAR2 --OUTPUT
   );';


   C_TMPL_TAB_WRITE_PROC_IMPL    CONSTANT CLOB :=
'   PROCEDURE '|| C_TMPL_TAB_WRITE_PROC_NAME || '
   (
     p_api_version                      IN NUMBER           --INPUT NOT NULL
    ,p_source_distrib_id_num_1          IN NUMBER           --INPUT
    ,p_source_distrib_id_num_2          IN NUMBER           --INPUT
    ,p_source_distrib_id_num_3          IN NUMBER           --INPUT
    ,p_source_distrib_id_num_4          IN NUMBER           --INPUT
    ,p_source_distrib_id_num_5          IN NUMBER           --INPUT
    ,p_account_type_code                IN VARCHAR2         --INPUT NOT NULL
    --START of source list
$SOURCE_PROC_PARAM_DECLARATIONS$
    --END of source list
    ,x_return_status                    OUT NOCOPY VARCHAR2 --OUTPUT
    ,x_msg_count                        OUT NOCOPY NUMBER   --OUTPUT
    ,x_msg_data                         OUT NOCOPY VARCHAR2 --OUTPUT
   )
   IS
      l_return_status     VARCHAR2(1);
      l_return_msg_name   VARCHAR2(30);
      l_msg_count         NUMBER;
      l_msg_data          VARCHAR2(2000);
      l_watermark         NUMBER;
      l_start          	  NUMBER;
      l_new_idx           NUMBER;

      l_log_module           VARCHAR2 (2000);
   BEGIN
      IF g_log_enabled THEN
         l_log_module := C_DEFAULT_MODULE||''write_online_tab$OBJECT_NAME_AFFIX$'';
      END IF;

      IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
         trace
           ( p_module   => l_log_module
            ,p_msg      => ''BEGIN '' || l_log_module
            ,p_level    => C_LEVEL_PROCEDURE);
      END IF;

      --Initialize the global message table
      FND_MSG_PUB.Initialize;

      --Initialize return status and message local variables
      l_return_msg_name  := NULL;
      l_return_status    := NULL;

      IF NOT FND_API.Compatible_API_Call
         (
           p_current_version_number => C_API_VERSION
          ,p_caller_version_number  => p_api_version
          ,p_api_name               => ''write_online_tab$OBJECT_NAME_AFFIX$''
          ,p_pkg_name               => C_PACKAGE_NAME
         )
      THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      --p_account_type_code cannot be NULL
      IF p_account_type_code IS NULL
      THEN
         --Assign an error message and a return code of FAILURE
         l_return_msg_name  := ''XLA_TAB_WR_ROW_ACCT_TYPE_NULL'';
         RAISE le_fatal_error;
      END IF;

      --Get the highest index of the PL/SQL table
      --Cannot use COUNT since some elements might have been
      --collected and deleted
      l_watermark := NVL(g_array_xla_tab$OBJECT_NAME_AFFIX$.LAST, 1);
      l_start     := NVL(g_array_xla_tab$OBJECT_NAME_AFFIX$.FIRST, 1);

      --Loop on all the rows of the PL/SQL table
      FOR i IN l_start..l_watermark
      LOOP
         --If the current row has the same key of the new row
         IF  g_array_xla_tab$OBJECT_NAME_AFFIX$.EXISTS(i)
         AND (   g_array_xla_tab$OBJECT_NAME_AFFIX$(i).source_distribution_id_num_1 = p_source_distrib_id_num_1
              OR g_array_xla_tab$OBJECT_NAME_AFFIX$(i).source_distribution_id_num_1 IS NULL AND p_source_distrib_id_num_1 IS NULL
             )
         AND (   g_array_xla_tab$OBJECT_NAME_AFFIX$(i).source_distribution_id_num_2 = p_source_distrib_id_num_2
              OR g_array_xla_tab$OBJECT_NAME_AFFIX$(i).source_distribution_id_num_2 IS NULL AND p_source_distrib_id_num_2 IS NULL
             )
         AND (   g_array_xla_tab$OBJECT_NAME_AFFIX$(i).source_distribution_id_num_3 = p_source_distrib_id_num_3
              OR g_array_xla_tab$OBJECT_NAME_AFFIX$(i).source_distribution_id_num_3 IS NULL AND p_source_distrib_id_num_3 IS NULL
             )
         AND (   g_array_xla_tab$OBJECT_NAME_AFFIX$(i).source_distribution_id_num_4 = p_source_distrib_id_num_4
              OR g_array_xla_tab$OBJECT_NAME_AFFIX$(i).source_distribution_id_num_4 IS NULL AND p_source_distrib_id_num_4 IS NULL
             )
         AND (   g_array_xla_tab$OBJECT_NAME_AFFIX$(i).source_distribution_id_num_5 = p_source_distrib_id_num_5
              OR g_array_xla_tab$OBJECT_NAME_AFFIX$(i).source_distribution_id_num_5 IS NULL AND p_source_distrib_id_num_5 IS NULL
             )
         AND g_array_xla_tab$OBJECT_NAME_AFFIX$(i).account_type_code            = p_account_type_code
         THEN
            --Assign a return code of FAILURE
            l_return_status    := C_RET_STS_UNEXP_ERROR;
            --Set the TAB message onto the message stack
            FND_MESSAGE.SET_NAME
            (
              application => ''XLA''
             ,name        => ''XLA_TAB_WR_ROW_DUPLICATE''
            );

            --Replace the token for the flex message retrieved above
            FND_MESSAGE.SET_TOKEN
            (
              token => ''TRX_ACCT_TYPE_CODE''
             ,value => g_array_xla_tab$OBJECT_NAME_AFFIX$(i).account_type_code
            );
            --Replace the token for the flex message retrieved above
            FND_MESSAGE.SET_TOKEN
            (
              token => ''SOURCE_DIST_ID_NUM1''
             ,value => g_array_xla_tab$OBJECT_NAME_AFFIX$(i).source_distribution_id_num_1
            );
            --Replace the token for the flex message retrieved above
            FND_MESSAGE.SET_TOKEN
            (
              token => ''SOURCE_DIST_ID_NUM2''
             ,value => g_array_xla_tab$OBJECT_NAME_AFFIX$(i).source_distribution_id_num_2
            );
            --Replace the token for the flex message retrieved above
            FND_MESSAGE.SET_TOKEN
            (
              token => ''SOURCE_DIST_ID_NUM3''
             ,value => g_array_xla_tab$OBJECT_NAME_AFFIX$(i).source_distribution_id_num_3
            );
            --Replace the token for the flex message retrieved above
            FND_MESSAGE.SET_TOKEN
            (
              token => ''SOURCE_DIST_ID_NUM4''
             ,value => g_array_xla_tab$OBJECT_NAME_AFFIX$(i).source_distribution_id_num_4
            );
            --Replace the token for the flex message retrieved above
            FND_MESSAGE.SET_TOKEN
            (
              token => ''SOURCE_DIST_ID_NUM5''
             ,value => g_array_xla_tab$OBJECT_NAME_AFFIX$(i).source_distribution_id_num_5
            );

            fnd_msg_pub.add;

            --Raise a local exception
            RAISE le_fatal_error;
         --Elsif the current row has already been processed
         ELSIF g_array_xla_tab$OBJECT_NAME_AFFIX$.EXISTS(i)
           AND g_array_xla_tab$OBJECT_NAME_AFFIX$(i).target_ccid   IS NOT NULL
           AND g_array_xla_tab$OBJECT_NAME_AFFIX$(i).msg_data IS NOT NULL
         THEN
            --It means the caller has previously uploaded the interface and run
            --the processing but has not collected all the results.
            --Assign an error message and a return code of FAILURE
            l_return_msg_name  := ''XLA_TAB_WR_ROW_PROCESSED'';
            l_return_status    := C_RET_STS_UNEXP_ERROR;
            --Raise a local exception
            RAISE le_fatal_error;
         END IF;
      END LOOP;

      --Get the index of the new row
      l_new_idx := g_array_xla_tab$OBJECT_NAME_AFFIX$.COUNT + 1;
      --Assign the values to the new row
      g_array_xla_tab$OBJECT_NAME_AFFIX$(l_new_idx).source_distribution_id_num_1   := p_source_distrib_id_num_1;
      g_array_xla_tab$OBJECT_NAME_AFFIX$(l_new_idx).source_distribution_id_num_2   := p_source_distrib_id_num_2;
      g_array_xla_tab$OBJECT_NAME_AFFIX$(l_new_idx).source_distribution_id_num_3   := p_source_distrib_id_num_3;
      g_array_xla_tab$OBJECT_NAME_AFFIX$(l_new_idx).source_distribution_id_num_4   := p_source_distrib_id_num_4;
      g_array_xla_tab$OBJECT_NAME_AFFIX$(l_new_idx).source_distribution_id_num_5   := p_source_distrib_id_num_5;
      g_array_xla_tab$OBJECT_NAME_AFFIX$(l_new_idx).account_type_code              := p_account_type_code;
    --START of source list
$SOURCE_REC_FIELD_ASSIGNMENTS$
    --END of source list
      g_array_xla_tab$OBJECT_NAME_AFFIX$(l_new_idx).target_ccid                    := NULL;
      g_array_xla_tab$OBJECT_NAME_AFFIX$(l_new_idx).msg_data                       := NULL;

      --Assign out parameters
      x_return_status    := C_RET_STS_SUCCESS;
      x_msg_data         := NULL;
      x_msg_count        := 0;


      IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
         trace
           ( p_module   => l_log_module
            ,p_msg      => ''END '' || l_log_module
            ,p_level    => C_LEVEL_PROCEDURE);
      END IF;

   EXCEPTION
   WHEN le_fatal_error THEN
      --Remove all the elements from the PLSQL table
      g_array_xla_tab$OBJECT_NAME_AFFIX$.DELETE;
      --If there is a no token message to log
      IF l_return_msg_name IS NOT NULL
      THEN
         --Set it on the stack
         fnd_message.set_name
            (
              application => ''XLA''
             ,name        => l_return_msg_name
         );
         --Add it to the message table
         fnd_msg_pub.add;
      END IF;
      --If there is only one message retrieve it
      fnd_msg_pub.Count_And_Get
         (
           p_count => l_msg_count
          ,p_data  => l_msg_data
         );
      --Put the message on the stack to ensure old Forms detect the error
      fnd_message.set_encoded
         (
           encoded_message => l_msg_data
         );
      --Assign out parameters
      x_msg_count     := l_msg_count;
      x_msg_data      := l_msg_data;
      IF l_return_status IS NOT NULL
      THEN
         x_return_status := l_return_status;
      ELSE
         x_return_status := C_RET_STS_UNEXP_ERROR;
      END IF;
   WHEN OTHERS THEN
      --Remove all the elements from the PLSQL table
      g_array_xla_tab$OBJECT_NAME_AFFIX$.DELETE;
      --Add the standard unexpected error message
      fnd_msg_pub.Add_Exc_Msg
         ( p_pkg_name       => C_PACKAGE_NAME
          ,p_procedure_name => ''write_online_tab$OBJECT_NAME_AFFIX$''
         );
      --If there is only one message retrieve it
      fnd_msg_pub.Count_And_Get
         (
           p_count => l_msg_count
          ,p_data  => l_msg_data
         );
      --Put the message on the stack to ensure all Forms detect the error
      fnd_message.set_encoded
         (
           encoded_message => l_msg_data
         );
      --Assign out parameters
      x_msg_count     := l_msg_count;
      x_msg_data      := l_msg_data;
      x_return_status := C_RET_STS_UNEXP_ERROR;
   END write_online_tab$OBJECT_NAME_AFFIX$;
   ';


   C_TMPL_SOURCE_PROC_PARAM_DECLA  CONSTANT CLOB :=
'    ,$SOURCE_CODE$ IN $SOURCE_GENERIC_DATATYPE$ --INPUT';

   C_TMPL_TAB_READ_PROC_NAME       CONSTANT VARCHAR2(100) :=
      'read_online_tab$OBJECT_NAME_AFFIX$';

   C_TMPL_TAB_READ_PROC_DECLAR  CONSTANT  CLOB :=
'   PROCEDURE '|| C_TMPL_TAB_READ_PROC_NAME || '
    (
      p_api_version                      IN  NUMBER
     ,p_source_distrib_id_num_1          IN  NUMBER
     ,p_source_distrib_id_num_2          IN  NUMBER
     ,p_source_distrib_id_num_3          IN  NUMBER
     ,p_source_distrib_id_num_4          IN  NUMBER
     ,p_source_distrib_id_num_5          IN  NUMBER
     ,p_account_type_code                IN  VARCHAR2
     ,x_target_ccid                      OUT NOCOPY NUMBER
     ,x_concatenated_segments            OUT NOCOPY VARCHAR2
     ,x_return_status                    OUT NOCOPY VARCHAR2
     ,x_msg_count                        OUT NOCOPY NUMBER
     ,x_msg_data                         OUT NOCOPY VARCHAR2
    );';

   C_TMPL_TAB_READ_PROC_IMPL  CONSTANT  CLOB :=
'   PROCEDURE '|| C_TMPL_TAB_READ_PROC_NAME || '
    (
      p_api_version                      IN  NUMBER
     ,p_source_distrib_id_num_1          IN  NUMBER
     ,p_source_distrib_id_num_2          IN  NUMBER
     ,p_source_distrib_id_num_3          IN  NUMBER
     ,p_source_distrib_id_num_4          IN  NUMBER
     ,p_source_distrib_id_num_5          IN  NUMBER
     ,p_account_type_code                IN  VARCHAR2
     ,x_target_ccid                      OUT NOCOPY NUMBER
     ,x_concatenated_segments            OUT NOCOPY VARCHAR2
     ,x_return_status                    OUT NOCOPY VARCHAR2
     ,x_msg_count                        OUT NOCOPY NUMBER
     ,x_msg_data                         OUT NOCOPY VARCHAR2
    )
   IS
      TYPE lt_table_V2000         IS TABLE OF VARCHAR2(2000);

      l_return_status             VARCHAR2(1);
      l_return_msg_name           VARCHAR2(30);

      l_msg_count                 NUMBER;
      l_msg_data                  VARCHAR2(2000);

      l_found                     BOOLEAN;
      l_watermark                 NUMBER;
      l_start                     NUMBER;
      l_row_base_rowid            UROWID;
      l_row_target_ccid           NUMBER;
      l_row_concatenated_segments VARCHAR2(2000);
      l_row_msg_count             NUMBER;
      l_row_msg_data              VARCHAR2(2000);
      l_table_of_row_errors       lt_table_V2000;

      l_log_module                VARCHAR2 (2000);
   BEGIN
      IF g_log_enabled THEN
         l_log_module := C_DEFAULT_MODULE||''read_online_tab$OBJECT_NAME_AFFIX$'';
      END IF;

      IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
         trace
           ( p_module   => l_log_module
            ,p_msg      => ''BEGIN '' || l_log_module
            ,p_level    => C_LEVEL_PROCEDURE);
      END IF;

      --Initialize the global message table
      FND_MSG_PUB.Initialize;

      --Initialize return status and message local variables
      l_return_msg_name:= NULL;
      l_return_status  := NULL;

      IF NOT FND_API.Compatible_API_Call
         (
           p_current_version_number => C_API_VERSION
          ,p_caller_version_number  => p_api_version
          ,p_api_name               => ''read_online_tab$OBJECT_NAME_AFFIX$''
          ,p_pkg_name               => C_PACKAGE_NAME
         )
      THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      --Start the actual logic

      --p_account_type_code cannot be NULL
      IF p_account_type_code IS NULL
      THEN
         --Assign an error message and a return code of FAILURE
         l_return_msg_name  := ''XLA_TAB_RD_ROW_ACCT_TYPE_NULL'';
         RAISE le_fatal_error;
      END IF;

      l_found     := FALSE;

      --Get the highest index of the PL/SQL table
      --Cannot use COUNT since some elements might have been
      --collected and deleted
      l_watermark := NVL(g_array_xla_tab$OBJECT_NAME_AFFIX$.LAST, 1);
      l_start     := NVL(g_array_xla_tab$OBJECT_NAME_AFFIX$.FIRST, 1);

      --Loop on all the rows of the PL/SQL table
      FOR i IN l_start..l_watermark
      LOOP
         --If the current row identifiers correspond to the IN parameters
         IF  g_array_xla_tab$OBJECT_NAME_AFFIX$.EXISTS(i)
         AND (   g_array_xla_tab$OBJECT_NAME_AFFIX$(i).source_distribution_id_num_1 = p_source_distrib_id_num_1
              OR g_array_xla_tab$OBJECT_NAME_AFFIX$(i).source_distribution_id_num_1 IS NULL AND p_source_distrib_id_num_1 IS NULL
             )
         AND (   g_array_xla_tab$OBJECT_NAME_AFFIX$(i).source_distribution_id_num_2 = p_source_distrib_id_num_2
              OR g_array_xla_tab$OBJECT_NAME_AFFIX$(i).source_distribution_id_num_2 IS NULL AND p_source_distrib_id_num_2 IS NULL
             )
         AND (   g_array_xla_tab$OBJECT_NAME_AFFIX$(i).source_distribution_id_num_3 = p_source_distrib_id_num_3
              OR g_array_xla_tab$OBJECT_NAME_AFFIX$(i).source_distribution_id_num_3 IS NULL AND p_source_distrib_id_num_3 IS NULL
             )
         AND (   g_array_xla_tab$OBJECT_NAME_AFFIX$(i).source_distribution_id_num_4 = p_source_distrib_id_num_4
              OR g_array_xla_tab$OBJECT_NAME_AFFIX$(i).source_distribution_id_num_4 IS NULL AND p_source_distrib_id_num_4 IS NULL
             )
         AND (   g_array_xla_tab$OBJECT_NAME_AFFIX$(i).source_distribution_id_num_5 = p_source_distrib_id_num_5
              OR g_array_xla_tab$OBJECT_NAME_AFFIX$(i).source_distribution_id_num_5 IS NULL AND p_source_distrib_id_num_5 IS NULL
             )
         AND g_array_xla_tab$OBJECT_NAME_AFFIX$(i).account_type_code                = p_account_type_code
         THEN
            --Set the element found flag
            l_found := TRUE;

            --Assign the target ccid and encoded message to local variables
            l_row_base_rowid            :=
                      g_array_xla_tab$OBJECT_NAME_AFFIX$(i).base_rowid;

            l_row_target_ccid           :=
                      g_array_xla_tab$OBJECT_NAME_AFFIX$(i).target_ccid;

            l_row_concatenated_segments :=
                      g_array_xla_tab$OBJECT_NAME_AFFIX$(i).concatenated_segments;

            l_row_msg_count             :=
                      NVL(g_array_xla_tab$OBJECT_NAME_AFFIX$(i).msg_count, 0);

            l_row_msg_data              :=
                      g_array_xla_tab$OBJECT_NAME_AFFIX$(i).msg_data;

            IF (C_LEVEL_STATEMENT >= g_log_level) THEN
               trace
                  (p_module => l_log_module
                  ,p_msg      => ''l_row_base_rowid = '' || l_row_base_rowid
                  ,p_level    => C_LEVEL_STATEMENT);
               trace
                  (p_module => l_log_module
                  ,p_msg      => ''l_row_target_ccid = '' || l_row_target_ccid
                  ,p_level    => C_LEVEL_STATEMENT);
               trace
                  (p_module => l_log_module
                  ,p_msg      => ''l_row_msg_count = '' || l_row_msg_count
                  ,p_level    => C_LEVEL_STATEMENT);
               trace
                  (p_module => l_log_module
                  ,p_msg      => ''l_row_msg_data = '' || l_row_msg_data
                  ,p_level    => C_LEVEL_STATEMENT);
            END IF;

            --If the line has not been processed raise an error
            IF  l_row_target_ccid IS NULL
            AND l_row_msg_count   = 0
            THEN
               l_return_msg_name := ''XLA_TBA_RD_ROW_UNPROCESSED'';
               --Raise a local exception
               RAISE le_fatal_error;
            END IF;

            --remove the element
            g_array_xla_tab$OBJECT_NAME_AFFIX$.DELETE(i);

            --exit the loop
            EXIT;
         END IF;
      END LOOP;

      --If no match found raise an error
      IF NOT l_found
      THEN
         l_return_msg_name := ''XLA_TBA_RD_ROW_NOT_FOUND'';
         RAISE le_fatal_error;
      END IF;

      --If the row has only one error push it on the stack
      IF l_row_msg_count = 1
      THEN
         --push it on the message stack
         fnd_message.set_encoded
            (
              encoded_message => l_row_msg_data
            );
         --Add it to the message table
         fnd_msg_pub.add;
         --If there is only one message retrieve it
         fnd_msg_pub.count_and_get
            (
              p_count => l_msg_count
             ,p_data  => l_msg_data
            );
         --Put the message on the stack to ensure old Forms detect the error
         fnd_message.set_encoded
            (
              encoded_message => l_msg_data
            );
         --Set the return values
         l_msg_count     := l_msg_count;
         l_msg_data      := l_msg_data;
         --Set return status
         l_return_status := C_RET_STS_ERROR;
      --If the row has more than one error fetch them from the error table
      ELSIF l_row_msg_count > 1
      THEN
         --Read the errors from XLA_TAB_ERRORS_GT and push them on the stack
         SELECT xte.msg_data
           BULK COLLECT
           INTO l_table_of_row_errors
           FROM xla_tab_errors_gt xte
          WHERE xte.base_rowid = l_row_base_rowid;
         --Loop on the errors and push them on the stack
         FOR i IN l_table_of_row_errors.FIRST .. l_table_of_row_errors.LAST
         LOOP
            --Push the current message on the stack
            fnd_message.set_encoded
            (
              encoded_message => l_table_of_row_errors(i)
            );
            --Add the stacked message to the table
            fnd_msg_pub.add;
         END LOOP;
         --Set the return values
         l_msg_count     := l_row_msg_count;
         l_msg_data      := NULL;
         l_return_status := C_RET_STS_ERROR;
      ELSE
         --The row has been found and has no errors
         l_msg_count     := 0;
         l_msg_data      := NULL;
         l_return_status := C_RET_STS_SUCCESS;
      END IF;

      --Assign out parameters
      x_target_ccid           := l_row_target_ccid;
      x_concatenated_segments := l_row_concatenated_segments;
      x_msg_count             := l_msg_count;
      x_msg_data              := l_msg_data;

      IF l_return_status IS NOT NULL
      THEN
         x_return_status := l_return_status;
      ELSE
         x_return_status := C_RET_STS_UNEXP_ERROR;
      END IF;

      IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
         trace
           ( p_module   => l_log_module
            ,p_msg      => ''END '' || l_log_module
            ,p_level    => C_LEVEL_PROCEDURE);
      END IF;

   EXCEPTION
   WHEN le_fatal_error THEN
      --Remove all the elements from the PLSQL table
      g_array_xla_tab$OBJECT_NAME_AFFIX$.DELETE;
      --If there is a no token message to log
      IF l_return_msg_name IS NOT NULL
      THEN
         --Set it on the stack
         fnd_message.set_name
            (
              application => ''XLA''
             ,name        => l_return_msg_name
         );
         --Add it to the message table
         fnd_msg_pub.add;
      END IF;
      --If there is only one message retrieve it
      fnd_msg_pub.Count_And_Get
         (
           p_count => l_msg_count
          ,p_data  => l_msg_data
         );
      --Put the message on the stack to ensure old Forms detect the error
      fnd_message.set_encoded
         (
           encoded_message => l_msg_data
         );
      --Assign out parameters
      x_msg_count     := l_msg_count;
      x_msg_data      := l_msg_data;
      IF l_return_status IS NOT NULL
      THEN
         x_return_status := l_return_status;
      ELSE
         x_return_status := C_RET_STS_UNEXP_ERROR;
      END IF;
   WHEN OTHERS THEN
      --Remove all the elements from the PLSQL table
      g_array_xla_tab$OBJECT_NAME_AFFIX$.DELETE;
      --Add the standard unexpected error message
      fnd_msg_pub.Add_Exc_Msg
         ( p_pkg_name       => C_PACKAGE_NAME
          ,p_procedure_name => ''read_online_tab$OBJECT_NAME_AFFIX$''
         );
      --If there is only one message retrieve it
      fnd_msg_pub.Count_And_Get
         (
           p_count => l_msg_count
          ,p_data  => l_msg_data
         );
      --Put the message on the stack to ensure all Forms detect the error
      fnd_message.set_encoded
         (
           encoded_message => l_msg_data
         );
      --Assign out parameters
      x_msg_count     := l_msg_count;
      x_msg_data      := l_msg_data;
      x_return_status := C_RET_STS_UNEXP_ERROR;
   END read_online_tab$OBJECT_NAME_AFFIX$;
   ';


   --
   -- Global variables
   --
   g_user_id                 CONSTANT INTEGER := xla_environment_pkg.g_usr_id;
   g_login_id                CONSTANT INTEGER := xla_environment_pkg.g_login_id;
   g_prog_appl_id            CONSTANT INTEGER := xla_environment_pkg.g_prog_appl_id;
   g_prog_id                 CONSTANT INTEGER := xla_environment_pkg.g_prog_id;
   g_req_id                  CONSTANT INTEGER := NVL(xla_environment_pkg.g_req_id, -1);



   g_application_info        xla_cmp_common_pkg.lt_application_info;
   g_user_name               VARCHAR2(2000); --100 in the table
   g_tab_api_package_name    VARCHAR2(30); --length validation is important
   --

   -- Cursor declarations
   --



--=============================================================================
--               *********** Local Trace Routine **********
--=============================================================================
C_LEVEL_STATEMENT     CONSTANT NUMBER := FND_LOG.LEVEL_STATEMENT;
C_LEVEL_PROCEDURE     CONSTANT NUMBER := FND_LOG.LEVEL_PROCEDURE;
C_LEVEL_EVENT         CONSTANT NUMBER := FND_LOG.LEVEL_EVENT;
C_LEVEL_EXCEPTION     CONSTANT NUMBER := FND_LOG.LEVEL_EXCEPTION;
C_LEVEL_ERROR         CONSTANT NUMBER := FND_LOG.LEVEL_ERROR;
C_LEVEL_UNEXPECTED    CONSTANT NUMBER := FND_LOG.LEVEL_UNEXPECTED;

C_LEVEL_LOG_DISABLED  CONSTANT NUMBER := 99;
C_DEFAULT_MODULE      CONSTANT VARCHAR2(240) := 'xla.plsql.xla_cmp_tab_pkg';

g_log_level           NUMBER;
g_log_enabled         BOOLEAN;

--1-STATEMENT, 2-PROCEDURE, 3-EVENT, 4-EXCEPTION, 5-ERROR, 6-UNEXPECTED

PROCEDURE trace
       ( p_module                     IN VARCHAR2 DEFAULT C_DEFAULT_MODULE
        ,p_msg                        IN VARCHAR2
        ,p_level                      IN NUMBER
        ) IS
BEGIN
   IF (p_msg IS NULL AND p_level >= g_log_level) THEN
      fnd_log.message(p_level, p_module);
   ELSIF p_level >= g_log_level THEN
      fnd_log.string(p_level, p_module, p_msg);
   END IF;

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;
   WHEN OTHERS THEN
      xla_exceptions_pkg.raise_message
         (p_location   => 'xla_cmp_tab_pkg.trace');
END trace;


--Forward declarations of private functions

FUNCTION init_global_variables
                   ( p_application_id       IN         NUMBER
                   )
RETURN BOOLEAN;
FUNCTION get_tab_api_package_name
                   (
                      p_tab_api_package_name OUT NOCOPY VARCHAR2
                   )
RETURN BOOLEAN;


FUNCTION create_package_spec
RETURN BOOLEAN;

FUNCTION create_package_body
RETURN BOOLEAN;

FUNCTION create_temp_tables
RETURN BOOLEAN;

FUNCTION build_package_spec
            (
              p_package_spec_text OUT NOCOPY CLOB
            )
RETURN BOOLEAN;

FUNCTION build_package_body
                (
                  p_package_body_text OUT NOCOPY CLOB
                )
RETURN BOOLEAN;

FUNCTION build_package_history
            (
              p_package_history OUT NOCOPY CLOB
            )
RETURN BOOLEAN;

FUNCTION build_declarations
            (
              p_record_type_declarations OUT NOCOPY CLOB
             ,p_table_type_declarations  OUT NOCOPY CLOB
             ,p_table_var_declarations   OUT NOCOPY CLOB
             ,p_write_proc_declarations  OUT NOCOPY CLOB
             ,p_read_proc_declarations   OUT NOCOPY CLOB
            )
RETURN BOOLEAN;

FUNCTION build_implementations
            (
              x_write_proc_implementations OUT NOCOPY CLOB
             ,x_read_proc_implementations  OUT NOCOPY CLOB
             ,x_reset_interface_proc_stmts OUT NOCOPY CLOB
            )
RETURN BOOLEAN;

FUNCTION build_global_temp_table
            (
              p_object_name_affix        IN  VARCHAR2
             ,x_global_table_name        OUT NOCOPY VARCHAR2
             ,x_table_creation_text      OUT NOCOPY CLOB
            )
RETURN BOOLEAN;


PROCEDURE compile_api_srs
                           ( p_errbuf               OUT NOCOPY VARCHAR2
                            ,p_retcode              OUT NOCOPY NUMBER
                            ,p_application_id       IN         NUMBER
                           )
IS
l_msg_count        NUMBER;
l_msg_data         VARCHAR2 (2000);
l_log_module       VARCHAR2 (2000);
BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.compile_api_srs';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module   => l_log_module
         ,p_msg      => 'BEGIN ' || C_DEFAULT_MODULE||'.compile_api_srs'
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   IF xla_cmp_tab_pkg.compile_api(
                                   p_application_id => p_application_id
                                 )
   THEN
      IF (C_LEVEL_EVENT >= g_log_level) THEN
         trace
            (p_module   => l_log_module
            ,p_msg      => 'TAB API built successfully'
            ,p_level    => C_LEVEL_EVENT);
      END IF;
      --Report the "successfully compiled" message in the output
      fnd_file.put_line
             (
               fnd_file.output
              ,xla_messages_pkg.get_message
                (
                  'XLA'
                 ,'XLA_TAB_CMP_TAB_API_SUCCEEDED'
                 ,'APPLICATION_NAME'
                 ,g_application_info.application_name
                )
              );
      p_retcode := 0;
   ELSE
      IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
         trace
            (p_module   => l_log_module
            ,p_msg      => 'Unable to build TAB API'
            ,p_level    => C_LEVEL_EXCEPTION);
      END IF;
      --Report the "unsuccessfully compiled" message in the output
      fnd_file.put_line
             (
               fnd_file.output
              ,xla_messages_pkg.get_message
                  (
                    'XLA'
                   ,'XLA_TAB_CMP_TAB_API_FAILED'
                   ,'APPLICATION_NAME'
                   ,g_application_info.application_name
                  )
             );
      --Report the errors
      fnd_msg_pub.Count_And_Get
      (
           p_count => l_msg_count
          ,p_data  => l_msg_data
      );
      --If msg_count 0 it might be the message is on the old stack
      IF l_msg_count = 0
      THEN
         fnd_file.put_line
               (
                 fnd_file.log
                ,fnd_message.get()
               );
      ELSIF l_msg_count = 1
      THEN
         fnd_message.set_encoded
            (
              encoded_message => l_msg_data
            );
            fnd_file.put_line
               (
                 fnd_file.log
                ,fnd_message.get()
               );
      ELSIF l_msg_count > 1
      THEN
         FOR i IN 1..l_msg_count
         LOOP
            fnd_file.put_line
               (
                 fnd_file.log
                ,fnd_msg_pub.get(p_encoded => 'F')
               );
         END LOOP;
      END IF;
      p_retcode := 2;
   END IF;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'p_retcode = ' || p_retcode
         ,p_level    => C_LEVEL_STATEMENT);
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'RETURN ' || C_DEFAULT_MODULE||'.compile_api_srs'
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception
THEN
   RAISE;
WHEN OTHERS
THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_cmp_tab_pkg.compile_api_srs');

END compile_api_srs;


FUNCTION compile_api
                     (
                       p_application_id       IN         NUMBER
                     )
RETURN BOOLEAN
IS
   l_return_value         BOOLEAN;

   l_user_name            VARCHAR2(30);
   lr_application_info    xla_cmp_common_pkg.lt_application_info;
   l_log_module           VARCHAR2 (2000);

BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.compile_api';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'BEGIN ' || C_DEFAULT_MODULE||'.compile_api'
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   l_return_value := TRUE;

   --Lock TATs setup data for the application
   IF NOT xla_cmp_lock_pkg.lock_tats_and_sources
                         (
                           p_application_id => p_application_id
                         )
   THEN
      l_return_value := FALSE;
   END IF;

   --Remove Transaction Account Definitions deleted in the UI
   --for this application
   IF NOT remove_deleted_tats
             (
                p_application_id => p_application_id
             )
   THEN
      IF (C_LEVEL_ERROR >= g_log_level) THEN
         trace
         (p_module => l_log_module
         ,p_msg      => 'remove_deleted_tats failed, aborting...'
         ,p_level    => C_LEVEL_ERROR);
      END IF;
      l_return_value := FALSE;
      RAISE le_fatal_error;
   END IF;

   --Initialize global variables
   IF NOT init_global_variables
                         (
                           p_application_id => p_application_id
                         )
   THEN
      --If global vars cannot be set we cannot continue
      IF (C_LEVEL_ERROR >= g_log_level) THEN
         trace
         (p_module   => l_log_module
         ,p_msg      => 'init_global_variables failed'
         ,p_level    => C_LEVEL_ERROR);
      END IF;
      l_return_value := FALSE;
      RAISE le_fatal_error;
   END IF;

   --Create Package Header
   IF NOT create_package_spec
   THEN
      --If global vars cannot be set we cannot continue
      IF (C_LEVEL_ERROR >= g_log_level) THEN
         trace
         (p_module => l_log_module
         ,p_msg      => 'create_package_spec failed'
         ,p_level    => C_LEVEL_ERROR);
      END IF;
      l_return_value := FALSE;
   END IF;

   --Create Package Body
   IF NOT create_package_body
   THEN
      --If global vars cannot be set we cannot continue
      IF (C_LEVEL_ERROR >= g_log_level) THEN
         trace
         (p_module   => l_log_module
         ,p_msg      => 'create_package_body failed'
         ,p_level    => C_LEVEL_ERROR);
      END IF;
      l_return_value := FALSE;
   END IF;

   --Create Global Temporary Tables
   IF NOT create_temp_tables
   THEN
      --If global vars cannot be set we cannot continue
      IF (C_LEVEL_ERROR >= g_log_level) THEN
         trace
         (p_module   => l_log_module
         ,p_msg      => 'create_package_body failed'
         ,p_level    => C_LEVEL_ERROR);
      END IF;
      l_return_value := FALSE;
   END IF;

   --Assign the new compile_status_code to the TATs
   UPDATE xla_tab_acct_types_b xtat
      SET xtat.compile_status_code =
             xla_cmp_common_pkg.G_COMPILE_STATUS_CODE_COMPILED
    WHERE xtat.application_id      = p_application_id
      AND xtat.enabled_flag        =  'Y'
      AND xtat.compile_status_code IS NOT NULL;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'value returned= '
                        || CASE l_return_value
                              WHEN TRUE THEN 'TRUE'
                              WHEN FALSE THEN 'FALSE'
                              ELSE 'NULL'
                           END
         ,p_level    => C_LEVEL_STATEMENT );
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'END ' || C_DEFAULT_MODULE||'.compile_api'
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   --If success in all phases return TRUE Else FALSE
   RETURN l_return_value;

EXCEPTION
WHEN le_fatal_error
THEN
   IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
         trace
            (p_module   => l_log_module
            ,p_msg      => 'EXCEPTION:' ||
                           ' Cannot initialize global variables, aborting...'
            ,p_level    => C_LEVEL_EXCEPTION);
   END IF;
   --Push a message in the message stack
   --without raising an exception
   xla_exceptions_pkg.raise_message
      ( p_appli_s_name    => 'XLA'
       ,p_msg_name        => 'XLA_TAB_CMP_TAB_API_FAILED'
       ,p_token_1         => 'APPLICATION_NAME'
       ,p_value_1         => g_application_info.application_name
       ,p_msg_mode        => g_msg_mode
      );

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'END ' || C_DEFAULT_MODULE||'.compile_api'
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;
   RETURN FALSE;
WHEN xla_exceptions_pkg.application_exception
THEN
   RAISE;
WHEN OTHERS
THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_cmp_tab_pkg.compile_api');
END compile_api;



/*======================================================================+
|                                                                       |
| Private Function                                                      |
|                                                                       |
| init_global_variables                                                 |
|                                                                       |
|       This program initializes the global variables required by the   |
|       package. It retrieves the user name, builds the package and     |
|       table names of the Transaction Account Builder API being        |
|       compiled, etc., and sets the global variables.                  |
|                                                                       |
|                                                                       |
+======================================================================*/
FUNCTION init_global_variables
                           ( p_application_id       IN         NUMBER
                           )
RETURN BOOLEAN
IS
   l_return_value BOOLEAN;
l_log_module                 VARCHAR2 (2000);
BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.init_global_variables';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'BEGIN ' || C_DEFAULT_MODULE||'.init_global_variables'
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   l_return_value := TRUE;
/*
   --Retrieve and set the User Name (xla_cmp_common_pkg.get_user_name)
   --Set the application id
   --Retrieve and set the Application Information (xla_cmp_common_pkg.get_application_info)
   --Build and set the Transaction Account Builder package name (get_tab_api_package_name)
   --Retrieve and set the object name affixes (read_distinct_affixes)
*/
   --Retrieve current user name
   IF NOT xla_cmp_common_pkg.get_user_name
                  (
                    p_user_id          => g_user_id
                   ,p_user_name        => g_user_name
                  )
   THEN
      IF (C_LEVEL_ERROR >= g_log_level) THEN
         trace
            (p_module   => l_log_module
            ,p_msg      => 'ERROR:' ||
                           ' Cannot determine user name.'
            ,p_level    => C_LEVEL_ERROR);
      END IF;
   END IF;

   --Retrieve and set the application info
   IF NOT xla_cmp_common_pkg.get_application_info
                  (
                    p_application_id   => p_application_id
                   ,p_application_info => g_application_info
                  )
   THEN
      IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
         trace
            (p_module   => l_log_module
            ,p_msg      => 'EXCEPTION:' ||
                           ' Cannot read application info, aborting...'
            ,p_level    => C_LEVEL_EXCEPTION);
      END IF;
      RAISE le_fatal_error;
   END IF;

   --Build the api package name
   IF NOT get_tab_api_package_name
                (
                  p_tab_api_package_name  => g_tab_api_package_name
                )
   THEN
      IF (C_LEVEL_ERROR >= g_log_level) THEN
         trace
            (p_module   => l_log_module
            ,p_msg      => 'ERROR:' ||
                           ' Cannot determine the TAB API package name.'
            ,p_level    => C_LEVEL_ERROR);
      END IF;
   END IF;

   --Build distinct object_name
   IF NOT read_distinct_affixes( p_application_id => p_application_id)
   THEN
      l_return_value := FALSE;
      IF (C_LEVEL_ERROR >= g_log_level) THEN
         trace
            (p_module   => l_log_module
            ,p_msg      => 'ERROR:' ||
                           ' Cannot determine the TAB API affixes. ' ||
                           'Check if at least one enabled Transaction ' ||
                           'Account Type exists for this application.'
            ,p_level    => C_LEVEL_ERROR);
      END IF;

      RAISE le_fatal_error;

   END IF;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'value returned= '
                        || CASE l_return_value
                              WHEN TRUE THEN 'TRUE'
                              WHEN FALSE THEN 'FALSE'
                              ELSE 'NULL'
                           END
         ,p_level    => C_LEVEL_STATEMENT );
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'END ' || C_DEFAULT_MODULE||'.init_global_variables'
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   RETURN l_return_value;

EXCEPTION
WHEN le_fatal_error
THEN
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'END ' || C_DEFAULT_MODULE||'.init_global_variables'
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;
   RETURN FALSE;
WHEN xla_exceptions_pkg.application_exception
THEN
   RAISE;
WHEN OTHERS
THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_cmp_tab_pkg.init_global_variables');

END init_global_variables;


/*======================================================================+
|                                                                       |
| Private Function                                                      |
|                                                                       |
| create_package_spec                                                   |
|                                                                       |
|                                                                       |
|                                                                       |
|                                                                       |
+======================================================================*/
FUNCTION create_package_spec
RETURN BOOLEAN
IS
   l_return_value      BOOLEAN;
   l_package_spec_text CLOB;
l_log_module                 VARCHAR2 (2000);

BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.create_package_spec';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'BEGIN ' || C_DEFAULT_MODULE||'.create_package_spec'
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   l_return_value := TRUE;

   --build the package specification
   IF NOT build_package_spec
                          (
                            p_package_spec_text => l_package_spec_text
                          )
   THEN
      l_return_value := FALSE;
      IF (C_LEVEL_ERROR >= g_log_level) THEN
         trace
         (p_module => l_log_module
         ,p_msg      => 'build_package_spec failed'
         ,p_level    => C_LEVEL_ERROR);
      END IF;
   END IF;

   IF NOT xla_cmp_create_pkg.push_database_object
          (
            p_object_name          => g_tab_api_package_name
           ,p_object_type          => 'PACKAGE'
           ,p_object_owner         => NULL --current user
           ,p_apps_account         => g_application_info.apps_account
           ,p_msg_mode             => G_OA_MESSAGE
           ,p_ddl_text             => l_package_spec_text
          )
   THEN
      l_return_value := FALSE;
      IF (C_LEVEL_ERROR >= g_log_level) THEN
         trace
         (p_module => l_log_module
         ,p_msg      => 'push_database_object failed'
         ,p_level    => C_LEVEL_ERROR);
      END IF;
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         ( p_module   => l_log_module
          ,p_msg      => 'END ' || C_DEFAULT_MODULE||'.create_package_spec'
          ,p_level    => C_LEVEL_PROCEDURE
         );
   END IF;

   RETURN l_return_value;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception
THEN
   RAISE;
WHEN OTHERS
THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_cmp_tab_pkg.create_package_spec');

END create_package_spec;




/*======================================================================+
|                                                                       |
| Private Function                                                      |
|                                                                       |
| build_package_spec                                                    |
|                                                                       |
|                                                                       |
|                                                                       |
|                                                                       |
+======================================================================*/
FUNCTION build_package_spec
                (
                  p_package_spec_text OUT NOCOPY CLOB
                )
RETURN BOOLEAN
IS
   l_history                        CLOB;
   l_tab_rec_type_declarations      CLOB;
   l_table_type_declarations        CLOB;
   l_table_var_declarations         CLOB;
   l_write_proc_declarations        CLOB;
   l_read_proc_declarations         CLOB;

   l_return_value                   BOOLEAN;
   l_log_module                     VARCHAR2 (2000);
BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.build_package_spec';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'BEGIN ' || C_DEFAULT_MODULE||'.build_package_spec'
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   --take the package specification template
   --replace the package name tokens
   p_package_spec_text := xla_cmp_string_pkg.replace_token
                    (
                       C_TMPL_TAB_PACKAGE_SPEC
                      ,'$TAB_API_PACKAGE_NAME_1$'
                      ,g_tab_api_package_name
                    );

   p_package_spec_text := xla_cmp_string_pkg.replace_token
                    (
                       p_package_spec_text
                      ,'$TAB_API_PACKAGE_NAME_2$'
                      ,RPAD( g_tab_api_package_name
                            , 66
                            , ' '
                           )
                       || '|'
                    );

   --replace the application name token
   p_package_spec_text := xla_cmp_string_pkg.replace_token
                     (
                       p_package_spec_text
                      ,'$APPLICATION_NAME$'
                      ,RPAD( g_application_info.application_name
                            , 66
                            , ' '
                           ) || '|'
                     );

   --replace the application id token
   p_package_spec_text := xla_cmp_string_pkg.replace_token
                      (
                        p_package_spec_text
                       ,'$APPLICATION_ID$'
                       ,RPAD( TO_CHAR(g_application_info.application_id) || ')'
                             , 49
                             , ' '
                            ) || '|'
                      );

   --build the package history
   IF NOT build_package_history (l_history )
   THEN
      --not a fatal error
      IF (C_LEVEL_ERROR >= g_log_level) THEN
         trace
         (p_module => l_log_module
         ,p_msg      => 'cannot build package history'
         ,p_level    => C_LEVEL_ERROR);
      END IF;
      l_return_value := FALSE;
   END IF;

   --replace the history token
   p_package_spec_text := xla_cmp_string_pkg.replace_token
                      (
                        p_package_spec_text
                       ,'$HISTORY$'
                       ,RPAD( l_history
                             , 66
                             , ' '
                            ) || '|'
                      );

   --build the type and function declarations
   IF NOT build_declarations
             (
               p_record_type_declarations => l_tab_rec_type_declarations
              ,p_table_type_declarations  => l_table_type_declarations
              ,p_table_var_declarations   => l_table_var_declarations
              ,p_write_proc_declarations  => l_write_proc_declarations
              ,p_read_proc_declarations   => l_read_proc_declarations
             )
   THEN
      --not a fatal error
      IF (C_LEVEL_ERROR >= g_log_level) THEN
         trace
         (p_module => l_log_module
         ,p_msg      => 'cannot build declarations'
         ,p_level    => C_LEVEL_ERROR);
      END IF;
      l_return_value := FALSE;
   END IF;

   --replace the record type declarations token
   p_package_spec_text := xla_cmp_string_pkg.replace_token(
                                   p_package_spec_text
                                  ,'$TAB_REC_TYPE_DECLARATIONS$'
                                  ,l_tab_rec_type_declarations
                                 );

   --replace the table type declarations token
   p_package_spec_text := xla_cmp_string_pkg.replace_token(
                                   p_package_spec_text
                                  ,'$TAB_TABLE_TYPE_DECLARATIONS$'
                                  ,l_table_type_declarations
                                 );

   --replace the table variable declarations token
   p_package_spec_text := xla_cmp_string_pkg.replace_token(
                                   p_package_spec_text
                                  ,'$TAB_TABLE_VAR_DECLARATIONS$'
                                  ,l_table_var_declarations
                                 );

   --replace the write procedure declarations token
   p_package_spec_text := xla_cmp_string_pkg.replace_token(
                                   p_package_spec_text
                                  ,'$TAB_WRITE_PROC_DECLARATIONS$'
                                  ,l_write_proc_declarations
                                 );

   --replace the read procedure declarations token
   p_package_spec_text := xla_cmp_string_pkg.replace_token(
                                   p_package_spec_text
                                  ,'$TAB_READ_PROC_DECLARATIONS$'
                                  ,l_read_proc_declarations
                                 );

   l_return_value := TRUE;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'END ' || C_DEFAULT_MODULE||'.build_package_spec'
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   RETURN l_return_value;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception
THEN
   RAISE;
WHEN OTHERS
THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_cmp_tab_pkg.build_package_spec');

END build_package_spec;



/*======================================================================+
|                                                                       |
| Private Function                                                      |
|                                                                       |
| build_package_history                                                 |
|                                                                       |
|                                                                       |
|                                                                       |
|                                                                       |
+======================================================================*/
FUNCTION build_package_history (p_package_history OUT NOCOPY CLOB)
RETURN BOOLEAN
IS
   l_return_value BOOLEAN;
l_log_module                 VARCHAR2 (2000);
BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.build_package_history';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'BEGIN ' || C_DEFAULT_MODULE||'.build_package_history'
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   p_package_history := TO_CHAR(SYSDATE, 'DD-MON-RR')
                        || ' XLA '
                        || 'Generated by Oracle Subledger Accounting Compiler';

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'END ' || C_DEFAULT_MODULE||'.build_package_history'
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   RETURN l_return_value;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception
THEN
   RAISE;
WHEN OTHERS
THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_cmp_tab_pkg.build_package_history');

END build_package_history;



/*======================================================================+
|                                                                       |
| Private Function                                                      |
|                                                                       |
| build_record_type_declarations                                        |
|                                                                       |
|                                                                       |
|                                                                       |
|                                                                       |
+======================================================================*/
FUNCTION build_declarations
            (
              p_record_type_declarations OUT NOCOPY CLOB
             ,p_table_type_declarations  OUT NOCOPY CLOB
             ,p_table_var_declarations   OUT NOCOPY CLOB
             ,p_write_proc_declarations  OUT NOCOPY CLOB
             ,p_read_proc_declarations   OUT NOCOPY CLOB
            )
RETURN BOOLEAN
IS
   l_return_value              BOOLEAN;
   l_record_type_declar        CLOB;
   l_table_type_declar         CLOB;
   l_table_var_declar          CLOB;
   l_write_proc_declar         CLOB;
   l_read_proc_declar          CLOB;

   l_source_rec_field_declars  CLOB;
   l_source_rec_field_declar   CLOB;

   l_source_proc_param_declars CLOB;
   l_source_proc_param_declar  CLOB;

   l_record_type_declarations  CLOB;
   l_table_type_declarations   CLOB;
   l_table_var_declarations    CLOB;
   l_write_proc_declarations   CLOB;
   l_read_proc_declarations    CLOB;


   l_datatype_specific_declar  VARCHAR2(30);
   l_datatype_generic_declar   VARCHAR2(30);

   l_log_module                VARCHAR2 (2000);

BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.build_declarations';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'BEGIN ' || C_DEFAULT_MODULE||'.build_declarations'
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   l_record_type_declarations := NULL;
   l_table_type_declarations  := NULL;
   l_table_var_declarations   := NULL;
   l_write_proc_declarations  := NULL;
   l_read_proc_declarations   := NULL;


   --For each distinct object name affix
   FOR affix_index IN 1..g_all_object_name_affixes.COUNT
   LOOP
      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace
            (p_msg      => 'current affix: ' ||
                           NVL(g_all_object_name_affixes(affix_index), 'NULL')
            ,p_level    => C_LEVEL_STATEMENT);
      END IF;

      --get the various templates
      l_record_type_declar := C_TMPL_TAB_REC_TYPE_DECLAR;
      l_table_type_declar  := C_TMPL_TAB_TABLE_TYPE_DECLAR;
      l_table_var_declar   := C_TMPL_TAB_TABLE_VAR_DECLAR;
      l_write_proc_declar  := C_TMPL_TAB_WRITE_PROC_DECLAR;
      l_read_proc_declar   := C_TMPL_TAB_READ_PROC_DECLAR;

      --replace the object_name_affix
      l_record_type_declar := xla_cmp_string_pkg.replace_token
                        (
                          l_record_type_declar
                         ,'$OBJECT_NAME_AFFIX$'
                         ,CASE
                          WHEN g_all_object_name_affixes(affix_index) IS NULL THEN ' '
                          ELSE '_' || g_all_object_name_affixes(affix_index)
                          END
                        );
      l_table_type_declar := xla_cmp_string_pkg.replace_token
                        (
                          l_table_type_declar
                         ,'$OBJECT_NAME_AFFIX$'
                         ,CASE
                          WHEN g_all_object_name_affixes(affix_index) IS NULL THEN ' '
                          ELSE '_' || g_all_object_name_affixes(affix_index)
                          END
                        );
      l_table_var_declar := xla_cmp_string_pkg.replace_token
                        (
                          l_table_var_declar
                         ,'$OBJECT_NAME_AFFIX$'
                         ,CASE
                          WHEN g_all_object_name_affixes(affix_index) IS NULL
                          THEN RPAD( ' '
                                     ,21
                                     ,' '
                                   )
                          ELSE '_' ||
                               RPAD( g_all_object_name_affixes(affix_index)
                                    ,20
                                    ,' '
                                   )
                          END
                        );
      l_write_proc_declar := xla_cmp_string_pkg.replace_token
                        (
                          l_write_proc_declar
                         ,'$OBJECT_NAME_AFFIX$'
                         ,CASE
                          WHEN g_all_object_name_affixes(affix_index) IS NULL THEN ' '
                          ELSE '_' || g_all_object_name_affixes(affix_index)
                          END
                        );
      l_read_proc_declar  := xla_cmp_string_pkg.replace_token
                        (
                          l_read_proc_declar
                         ,'$OBJECT_NAME_AFFIX$'
                         ,CASE
                          WHEN g_all_object_name_affixes(affix_index) IS NULL THEN ' '
                          ELSE '_' || g_all_object_name_affixes(affix_index)
                          END
                        );

      l_source_rec_field_declars  := NULL;
      l_source_proc_param_declars := NULL;

      --For each distinct source
      FOR source_rec IN
         (
           SELECT DISTINCT  xsb.source_code
                           ,xsb.source_type_code
                           ,xsb.enabled_flag
                           ,xsb.datatype_code
             FROM xla_tab_acct_types_b   xtat
                 ,xla_tab_acct_type_srcs xtsrc
                 ,xla_sources_b          xsb
            WHERE xtat.application_id      = g_application_info.application_id
              AND NVL( xtat.object_name_affix
                      ,LPAD('A',32, 'A')
                     )
                  = NVL( g_all_object_name_affixes(affix_index)
                        ,LPAD('A',32, 'A')
                       )
              AND xtat.enabled_flag        =  'Y'
              AND xtsrc.account_type_code  = xtat.account_type_code
              AND xsb.application_id       = xtsrc.source_application_id
              AND xsb.source_code          = xtsrc.source_code
              AND xsb.source_type_code     = xtsrc.source_type_code
	      ORDER BY xsb.source_code
         )
      LOOP
         IF (C_LEVEL_STATEMENT >= g_log_level) THEN
            trace
               ( p_module   => l_log_module
                ,p_msg      => 'Source code: ' || source_rec.source_code
                ,p_level    => C_LEVEL_STATEMENT);
         END IF;

         --If not a seeded source log an error and go to the next source
         IF source_rec.source_type_code <> 'S'
         THEN
            l_return_value := FALSE;
            IF (C_LEVEL_ERROR >= g_log_level) THEN
               trace
               ( p_module   => l_log_module
                ,p_msg      => 'Source ' || source_rec.source_code ||
                              ' is not a seeded source.' ||
                              'It will not be considered.'
                ,p_level    => C_LEVEL_ERROR);
            END IF;
         --If source is not enabled log an error and go to the next source
         ELSIF source_rec.enabled_flag <> 'Y'
         THEN
            l_return_value := FALSE;
            IF (C_LEVEL_ERROR >= g_log_level) THEN
               trace
               (p_module   => l_log_module
               ,p_msg      => 'Source ' || source_rec.source_code ||
                              ' is not enabled.' ||
                              'It will not be considered.'
               ,p_level    => C_LEVEL_ERROR);
            END IF;
         ELSE
            l_return_value := TRUE;

            --get the template for the source record field declaration
            l_source_rec_field_declar   := C_TMPL_SOURCE_REC_FIELD_DECLAR;
            l_source_proc_param_declar  := C_TMPL_SOURCE_PROC_PARAM_DECLA;

            --replace the source code
            l_source_rec_field_declar  := xla_cmp_string_pkg.replace_token
                                 (
                                   l_source_rec_field_declar
                                  ,'$SOURCE_CODE$'
                                  ,RPAD( LOWER(source_rec.source_code)
                                        ,34
                                        ,' '
                                       )
                                 );
            --replace the source code
            l_source_proc_param_declar := xla_cmp_string_pkg.replace_token
                                 (
                                   l_source_proc_param_declar
                                  ,'$SOURCE_CODE$'
                                  ,RPAD( LOWER(source_rec.source_code)
                                        ,34
                                        ,' '
                                       )
                                 );


            --replace the datatype
            CASE
            WHEN source_rec.datatype_code = 'I'
            THEN l_datatype_specific_declar := 'INTEGER';
                 l_datatype_generic_declar  := 'INTEGER';
            WHEN source_rec.datatype_code = 'N'
            THEN l_datatype_specific_declar := 'NUMBER';
                 l_datatype_generic_declar  := 'NUMBER';
            WHEN source_rec.datatype_code = 'C'
            THEN l_datatype_specific_declar := 'VARCHAR2('|| C_CHAR_SOURCE_SIZE ||')';
                 l_datatype_generic_declar  := 'VARCHAR2';
            WHEN source_rec.datatype_code = 'D'
            THEN l_datatype_specific_declar := 'DATE';
                 l_datatype_generic_declar  := 'DATE';
            WHEN source_rec.datatype_code = 'F'
            THEN l_datatype_specific_declar := 'INTEGER';
                 l_datatype_generic_declar  := 'INTEGER';
            ELSE
               l_return_value := FALSE;
               IF (C_LEVEL_ERROR >= g_log_level) THEN
                  trace
                     (p_module   => l_log_module
                     ,p_msg      => 'Source ' || source_rec.source_code ||
                                    ' has an unknown datatype: ' ||
                                    source_rec.datatype_code ||'. ' ||
                                    'It will not be considered.'
                     ,p_level    => C_LEVEL_ERROR);
               END IF;

            END CASE;

            l_source_rec_field_declar  := xla_cmp_string_pkg.replace_token
                                 (
                                   l_source_rec_field_declar
                                  ,'$SOURCE_SPECIFIC_DATATYPE$'
                                  ,RPAD( l_datatype_specific_declar
                                        ,25
                                        ,' '
                                       )
                                 );

            l_source_proc_param_declar := xla_cmp_string_pkg.replace_token
                                 (
                                   l_source_proc_param_declar
                                  ,'$SOURCE_GENERIC_DATATYPE$'
                                  ,RPAD( l_datatype_generic_declar
                                        ,25
                                        ,' '
                                       )
                                 );


            IF l_source_rec_field_declars  IS NOT NULL
            THEN
               l_source_rec_field_declars  := l_source_rec_field_declars ||
                                              g_chr_newline;
            END IF;

            IF l_source_proc_param_declars IS NOT NULL
            THEN
               l_source_proc_param_declars := l_source_proc_param_declars ||
                                              g_chr_newline;
            END IF;

            l_source_rec_field_declars  := l_source_rec_field_declars ||
                                           l_source_rec_field_declar;

            l_source_proc_param_declars := l_source_proc_param_declars ||
                                           l_source_proc_param_declar;
         END IF;
      END LOOP;

      --replace the source field declarations
      l_record_type_declar := xla_cmp_string_pkg.replace_token
                                 (
                                   l_record_type_declar
                                  ,'$SOURCE_REC_FIELD_DECLARATIONS$'
                                  ,NVL(l_source_rec_field_declars, ' ')
                                 );

      --replace the source parameter declarations
      l_write_proc_declar  := xla_cmp_string_pkg.replace_token
                                 (
                                   l_write_proc_declar
                                  ,'$SOURCE_PROC_PARAM_DECLARATIONS$'
                                  ,NVL(l_source_proc_param_declars, ' ')
                                 );

      --Concatenate the partial results into the OUT params
      IF l_record_type_declarations  IS NOT NULL
      THEN
         l_record_type_declarations  := l_record_type_declarations ||
                                        g_chr_newline;
      END IF;
      IF l_table_type_declarations   IS NOT NULL
      THEN
         l_table_type_declarations   := l_table_type_declarations ||
                                        g_chr_newline;
      END IF;
      IF l_table_var_declarations    IS NOT NULL
      THEN
         l_table_var_declarations    := l_table_var_declarations ||
                                        g_chr_newline;
      END IF;
      IF l_write_proc_declarations   IS NOT NULL
      THEN
         l_write_proc_declarations   := l_write_proc_declarations ||
                                        g_chr_newline;
      END IF;
      IF l_read_proc_declarations    IS NOT NULL
      THEN
         l_read_proc_declarations    := l_read_proc_declarations ||
                                        g_chr_newline;
      END IF;

      l_record_type_declarations := l_record_type_declarations ||
                                    l_record_type_declar;

      l_table_type_declarations  := l_table_type_declarations  ||
                                    l_table_type_declar;

      l_table_var_declarations   := l_table_var_declarations   ||
                                    l_table_var_declar;

      l_write_proc_declarations  := l_write_proc_declarations  ||
                                    l_write_proc_declar;

      l_read_proc_declarations   := l_read_proc_declarations   ||
                                    l_read_proc_declar;

   END LOOP;

   --Assign return variables
   p_record_type_declarations := l_record_type_declarations;
   p_table_type_declarations  := l_table_type_declarations;
   p_table_var_declarations   := l_table_var_declarations;
   p_write_proc_declarations  := l_write_proc_declarations;
   p_read_proc_declarations   := l_read_proc_declarations;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'END ' || C_DEFAULT_MODULE||'.build_declarations'
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   RETURN l_return_value;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception
THEN
   RAISE;
WHEN OTHERS
THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_cmp_tab_pkg.build_declarations');

END build_declarations;




/*======================================================================+
|                                                                       |
| Private Function                                                      |
|                                                                       |
| create_package_body                                                   |
|                                                                       |
|                                                                       |
|                                                                       |
|                                                                       |
+======================================================================*/
FUNCTION create_package_body
RETURN BOOLEAN
IS
   l_return_value      BOOLEAN;
   l_package_body_text CLOB;

l_log_module                 VARCHAR2 (2000);

BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.create_package_body';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'BEGIN ' || C_DEFAULT_MODULE||'.create_package_body'
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   --build the package body
   IF NOT build_package_body
                          (
                            p_package_body_text => l_package_body_text
                          )
   THEN
      l_return_value := FALSE;
      IF (C_LEVEL_ERROR >= g_log_level) THEN
         trace
         (p_module => l_log_module
         ,p_msg      => 'build_package_body failed'
         ,p_level    => C_LEVEL_ERROR);
      END IF;
   END IF;

   IF NOT xla_cmp_create_pkg.push_database_object
                    (
                      p_object_name         => g_tab_api_package_name
                     ,p_object_type         => 'PACKAGE BODY'
                     ,p_object_owner        => NULL --current user
                     ,p_apps_account        => g_application_info.apps_account
                     ,p_msg_mode             => G_OA_MESSAGE
                     ,p_ddl_text            => l_package_body_text
                    )
   THEN
      l_return_value := FALSE;
      IF (C_LEVEL_ERROR >= g_log_level) THEN
         trace
         (p_module => l_log_module
         ,p_msg      => 'push_database_object failed'
         ,p_level    => C_LEVEL_ERROR);
      END IF;
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'END ' || C_DEFAULT_MODULE||'.create_package_body'
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   RETURN l_return_value;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception
THEN
   RAISE;
WHEN OTHERS
THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_cmp_tab_pkg.create_package_body');

END create_package_body;


/*======================================================================+
|                                                                       |
| Private Function                                                      |
|                                                                       |
| build_package_spec                                                    |
|                                                                       |
|                                                                       |
|                                                                       |
|                                                                       |
+======================================================================*/
FUNCTION build_package_body
                (
                  p_package_body_text OUT NOCOPY CLOB
                )
RETURN BOOLEAN
IS
   l_history                    CLOB;
   l_write_proc_impls           CLOB;
   l_read_proc_impls            CLOB;
   l_reset_interface_proc_stmts CLOB;

   l_package_body_text          CLOB;

   l_return_value               BOOLEAN;

   l_index                      INTEGER;

   l_log_module                 VARCHAR2 (2000);
BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.build_package_body';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'BEGIN ' || C_DEFAULT_MODULE||'.build_package_body'
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   l_return_value := TRUE;

   --take the package body template
   l_package_body_text := C_TMPL_TAB_PACKAGE_BODY;

   --replace the package name tokens
   l_package_body_text := xla_cmp_string_pkg.replace_token
                    (
                       l_package_body_text
                      ,'$TAB_API_PACKAGE_NAME_1$'
                      ,g_tab_api_package_name
                    );

   l_package_body_text := xla_cmp_string_pkg.replace_token
                    (
                       l_package_body_text
                      ,'$TAB_API_PACKAGE_NAME_2$'
                      ,RPAD( g_tab_api_package_name
                            , 66
                            , ' '
                           )
                       || '|'
                    );

   l_package_body_text := xla_cmp_string_pkg.replace_token
                    (
                       l_package_body_text
                      ,'$TAB_API_PACKAGE_NAME_3$'
                      ,LOWER(g_tab_api_package_name)
                    );

   l_package_body_text := xla_cmp_string_pkg.replace_token
                        (
                          l_package_body_text
                         ,'$oracle_user_name$'
                         ,LOWER(g_application_info.oracle_username)
                        );

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'Replaced package name tokens'
         ,p_level    => C_LEVEL_STATEMENT);
   END IF;

   --replace the application name token
   l_package_body_text := xla_cmp_string_pkg.replace_token
                     (
                       l_package_body_text
                      ,'$APPLICATION_NAME$'
                      ,RPAD( g_application_info.application_name
                            , 66
                            , ' '
                           ) || '|'
                     );

   --replace the application id token
   l_package_body_text := xla_cmp_string_pkg.replace_token
                      (
                        l_package_body_text
                       ,'$APPLICATION_ID$'
                       ,RPAD( TO_CHAR(g_application_info.application_id) || ')'
                             , 49
                             , ' '
                            ) || '|'
                      );
   l_package_body_text := xla_cmp_string_pkg.replace_token
                      (
                        l_package_body_text
                       ,'$APPLICATION_ID_2$'
                       ,TO_CHAR(g_application_info.application_id)
                      );

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'Replaced application tokens'
         ,p_level    => C_LEVEL_STATEMENT);
   END IF;


   --build the package history
   IF NOT build_package_history (l_history )
   THEN
      --not a fatal error
      IF (C_LEVEL_ERROR >= g_log_level) THEN
         trace
         (p_module => l_log_module
         ,p_msg      => 'cannot build package history'
         ,p_level    => C_LEVEL_ERROR);
      END IF;
      l_return_value := FALSE;
   END IF;

   --replace the history token
   l_package_body_text := xla_cmp_string_pkg.replace_token
                      (
                        l_package_body_text
                       ,'$HISTORY$'
                       ,RPAD( l_history
                             , 66
                             , ' '
                            ) || '|'
                      );

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'Replaced history token'
         ,p_level    => C_LEVEL_STATEMENT);
   END IF;

   --build the type and function implementations
   IF NOT build_implementations
             (
               x_write_proc_implementations  => l_write_proc_impls
              ,x_read_proc_implementations   => l_read_proc_impls
              ,x_reset_interface_proc_stmts  => l_reset_interface_proc_stmts
             )
   THEN
      --not a fatal error
      IF (C_LEVEL_ERROR >= g_log_level) THEN
         trace
         (p_module => l_log_module
         ,p_msg      => 'cannot build implementations'
         ,p_level    => C_LEVEL_ERROR);
      END IF;
      l_return_value := FALSE;
   END IF;

   --replace the write procedure implementations token
   l_package_body_text := xla_cmp_common_pkg.replace_token
                     (
                       p_original_text    => l_package_body_text
                      ,p_token            => '$TAB_WRITE_PROC_IMPLS$'
                      ,p_replacement_text => l_write_proc_impls
                     );

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'Replaced write proc impls tokens'
         ,p_level    => C_LEVEL_STATEMENT);
   END IF;

   --replace the read procedure implementations token
   l_package_body_text := xla_cmp_common_pkg.replace_token
                    (
                      p_original_text    => l_package_body_text
                     ,p_token            => '$TAB_READ_PROC_IMPLS$'
                     ,p_replacement_text => l_read_proc_impls
                    );

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'Replaced read proc impls tokens'
         ,p_level    => C_LEVEL_STATEMENT);
   END IF;

   --replace the reset online interface statements token
   l_package_body_text := xla_cmp_common_pkg.replace_token
                    (
                      p_original_text    => l_package_body_text
                     ,p_token            => '$RESET_ONLINE_INTERFACES_STMTS$'
                     ,p_replacement_text => l_reset_interface_proc_stmts
                    );

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'Replaced read proc impls tokens'
         ,p_level    => C_LEVEL_STATEMENT);
   END IF;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'p_package_body_text length: ' ||
                        LENGTH(l_package_body_text)
         ,p_level    => C_LEVEL_STATEMENT);
   END IF;

   --Assign return variables
   p_package_body_text := l_package_body_text;

   l_return_value := TRUE;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'END ' || C_DEFAULT_MODULE||'.build_package_body'
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   RETURN l_return_value;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception
THEN
   RAISE;
WHEN OTHERS
THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_cmp_tab_pkg.build_package_body');

END build_package_body;


/*======================================================================+
|                                                                       |
| Private Function                                                      |
|                                                                       |
| build_proc_implementations                                            |
|                                                                       |
|                                                                       |
|                                                                       |
|                                                                       |
+======================================================================*/
FUNCTION build_implementations
            (
              x_write_proc_implementations  OUT NOCOPY CLOB
             ,x_read_proc_implementations   OUT NOCOPY CLOB
             ,x_reset_interface_proc_stmts  OUT NOCOPY CLOB
            )
RETURN BOOLEAN
IS
   l_return_value               BOOLEAN;
   l_write_proc_impl            CLOB;
   l_read_proc_impl             CLOB;
   l_reset_interface_proc_stmt  CLOB;

   l_write_proc_implementations CLOB;
   l_read_proc_implementations  CLOB;
   l_reset_interface_proc_stmts CLOB;

   l_source_proc_param_declars  CLOB;
   l_source_proc_param_declar   CLOB;

   l_source_rec_field_assgn     CLOB;
   l_source_rec_field_assgns    CLOB;

   l_datatype_specific_declar   VARCHAR2(30);
   l_datatype_generic_declar    VARCHAR2(30);
   l_log_module                 VARCHAR2 (2000);

BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.build_implementations';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'BEGIN ' || C_DEFAULT_MODULE||'.build_implementations'
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   --For each distinct object name affix
   FOR affix_index IN 1..g_all_object_name_affixes.COUNT
   LOOP
      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace
            (p_module   => l_log_module
            ,p_msg      => 'current affix: ' ||
                           NVL(g_all_object_name_affixes(affix_index), 'NULL')
            ,p_level    => C_LEVEL_STATEMENT);
      END IF;

      --get the various templates
      l_write_proc_impl           := C_TMPL_TAB_WRITE_PROC_IMPL;
      l_read_proc_impl            := C_TMPL_TAB_READ_PROC_IMPL;
      l_reset_interface_proc_stmt := C_TMPL_TAB_RESET_ONLINE_INT_ST;

      --replace package name tokens
      l_write_proc_impl  := xla_cmp_string_pkg.replace_token
                    (
                       l_write_proc_impl
                      ,'$TAB_API_PACKAGE_NAME_3$'
                      ,LOWER(g_tab_api_package_name)
                    );

      l_read_proc_impl  := xla_cmp_string_pkg.replace_token
                    (
                       l_read_proc_impl
                      ,'$TAB_API_PACKAGE_NAME_3$'
                      ,LOWER(g_tab_api_package_name)
                    );


      --replace object name affix tokens
      l_write_proc_impl := xla_cmp_string_pkg.replace_token
                        (
                          l_write_proc_impl
                         ,'$OBJECT_NAME_AFFIX$'
                         ,CASE
                          WHEN g_all_object_name_affixes(affix_index) IS NULL THEN ' '
                          ELSE '_' || g_all_object_name_affixes(affix_index)
                          END
                        );
      l_read_proc_impl  := xla_cmp_string_pkg.replace_token
                        (
                          l_read_proc_impl
                         ,'$OBJECT_NAME_AFFIX$'
                         ,CASE
                          WHEN g_all_object_name_affixes(affix_index) IS NULL THEN ' '
                          ELSE '_' || g_all_object_name_affixes(affix_index)
                          END
                        );

      l_reset_interface_proc_stmt := xla_cmp_string_pkg.replace_token
                        (
                          l_reset_interface_proc_stmt
                         ,'$OBJECT_NAME_AFFIX$.'
                         ,CASE
                          WHEN g_all_object_name_affixes(affix_index) IS NULL THEN '.'
                          ELSE '_' || g_all_object_name_affixes(affix_index) || '.'
                          END
                        );

      l_source_proc_param_declars := NULL;
      l_source_rec_field_assgns   := NULL;

      --For each distinct source
      FOR source_rec IN
         (
           SELECT DISTINCT  xsb.source_code
                           ,xsb.source_type_code
                           ,xsb.enabled_flag
                           ,xsb.datatype_code
             FROM xla_tab_acct_types_b   xtat
                 ,xla_tab_acct_type_srcs xtsrc
                 ,xla_sources_b          xsb
            WHERE xtat.application_id      = g_application_info.application_id
              AND NVL( xtat.object_name_affix
                      ,LPAD('A',32, 'A')
                     )
                  = NVL( g_all_object_name_affixes(affix_index)
                        ,LPAD('A',32, 'A')
                       )
              AND xtat.enabled_flag        = 'Y'
              AND xtsrc.account_type_code  = xtat.account_type_code
              AND xsb.application_id       = xtsrc.source_application_id
              AND xsb.source_code          = xtsrc.source_code
              AND xsb.source_type_code     = xtsrc.source_type_code
	      ORDER BY xsb.source_code
         )
      LOOP
         IF (C_LEVEL_STATEMENT >= g_log_level) THEN
            trace
               ( p_module   => l_log_module
                ,p_msg      => 'Source code: ' || source_rec.source_code
                ,p_level    => C_LEVEL_STATEMENT);
         END IF;

         --If not a seeded source log an error and go to the next source
         IF source_rec.source_type_code <> 'S'
         THEN
            l_return_value := FALSE;
            IF (C_LEVEL_ERROR >= g_log_level) THEN
               trace
               (p_module   => l_log_module
               ,p_msg      => 'Source ' || source_rec.source_code ||
                              ' is not a seeded source.' ||
                              'It will not be considered.'
               ,p_level    => C_LEVEL_ERROR);
            END IF;
         --If source is not enabled log an error and go to the next source
         ELSIF source_rec.enabled_flag <> 'Y'
         THEN
            l_return_value := FALSE;
            IF (C_LEVEL_ERROR >= g_log_level) THEN
               trace
               (p_module   => l_log_module
               ,p_msg      => 'Source ' || source_rec.source_code ||
                              ' is not enabled.' ||
                              'It will not be considered.'
               ,p_level    => C_LEVEL_ERROR);
            END IF;
         ELSE
            l_return_value := TRUE;

            --get the template for the source record field declaration
            l_source_proc_param_declar  := C_TMPL_SOURCE_PROC_PARAM_DECLA;
            l_source_rec_field_assgn    := C_TMPL_SOURCE_REC_FIELD_ASSGN;

            --replace the source code tokens
            l_source_proc_param_declar := xla_cmp_string_pkg.replace_token
                                 (
                                   l_source_proc_param_declar
                                  ,'$SOURCE_CODE$'
                                  ,RPAD( LOWER(source_rec.source_code)
                                        ,34
                                        ,' '
                                       )
                                 );
            l_source_rec_field_assgn   := xla_cmp_string_pkg.replace_token
                                 (
                                   l_source_rec_field_assgn
                                  ,'$SOURCE_CODE_LEFT$'
                                  ,RPAD( LOWER(source_rec.source_code)
                                        ,30
                                        ,' '
                                       )
                                 );
            l_source_rec_field_assgn   := xla_cmp_string_pkg.replace_token
                                 (
                                   l_source_rec_field_assgn
                                  ,'$SOURCE_CODE_RIGHT$'
                                  ,LOWER(source_rec.source_code)
                                 );

            --replace the datatype
            CASE
            WHEN source_rec.datatype_code = 'I'
            THEN l_datatype_specific_declar := 'INTEGER';
                 l_datatype_generic_declar  := 'INTEGER';
            WHEN source_rec.datatype_code = 'N'
            THEN l_datatype_specific_declar := 'NUMBER';
                 l_datatype_generic_declar  := 'NUMBER';
            WHEN source_rec.datatype_code = 'C'
            THEN l_datatype_specific_declar := 'VARCHAR2('|| C_CHAR_SOURCE_SIZE ||')';
                 l_datatype_generic_declar  := 'VARCHAR2';
            WHEN source_rec.datatype_code = 'D'
            THEN l_datatype_specific_declar := 'DATE';
                 l_datatype_generic_declar  := 'DATE';
            WHEN source_rec.datatype_code = 'F'
            THEN l_datatype_specific_declar := 'INTEGER';
                 l_datatype_generic_declar  := 'INTEGER';
            ELSE
               l_return_value := FALSE;
               IF (C_LEVEL_ERROR >= g_log_level) THEN
                  trace
                     (p_module   => l_log_module
                     ,p_msg      => 'Source ' || source_rec.source_code ||
                                    ' has an unknown datatype: ' ||
                                    source_rec.datatype_code ||'. ' ||
                                    'It will not be considered.'
                     ,p_level    => C_LEVEL_ERROR);
               END IF;

            END CASE;

            l_source_proc_param_declar := xla_cmp_string_pkg.replace_token
                                 (
                                   l_source_proc_param_declar
                                  ,'$SOURCE_GENERIC_DATATYPE$'
                                  ,RPAD( l_datatype_generic_declar
                                        ,25
                                        ,' '
                                       )
                                 );


            IF l_source_proc_param_declars IS NOT NULL
            THEN
               l_source_proc_param_declars := l_source_proc_param_declars ||
                                              g_chr_newline;
            END IF;

            IF l_source_rec_field_assgns   IS NOT NULL
            THEN
               l_source_rec_field_assgns   := l_source_rec_field_assgns ||
                                              g_chr_newline;
            END IF;

            l_source_proc_param_declars := l_source_proc_param_declars ||
                                           l_source_proc_param_declar;

            l_source_rec_field_assgns   := l_source_rec_field_assgns   ||
                                           l_source_rec_field_assgn;

         END IF;
      END LOOP;

      --replace the source parameter declarations
      l_write_proc_impl  := xla_cmp_string_pkg.replace_token
                                 (
                                   l_write_proc_impl
                                  ,'$SOURCE_PROC_PARAM_DECLARATIONS$'
                                  ,NVL(l_source_proc_param_declars, ' ')
                                 );

      --replace the source field assignments
      l_write_proc_impl  := xla_cmp_string_pkg.replace_token
                                 (
                                   l_write_proc_impl
                                  ,'$SOURCE_REC_FIELD_ASSIGNMENTS$'
                                  ,NVL(l_source_rec_field_assgns, ' ')
                                 );
      --replace the affixes
      l_write_proc_impl := xla_cmp_string_pkg.replace_token
                        (
                          l_write_proc_impl
                         ,'$OBJECT_NAME_AFFIX$'
                         ,CASE
                          WHEN g_all_object_name_affixes(affix_index) IS NULL THEN ' '
                          ELSE '_' || g_all_object_name_affixes(affix_index)
                          END
                        );

      --Concatenate the partial results
      IF l_write_proc_implementations   IS NOT NULL
      THEN
         l_write_proc_implementations := l_write_proc_implementations ||
                                        g_chr_newline;
      END IF;
      IF l_read_proc_implementations    IS NOT NULL
      THEN
         l_read_proc_implementations  := l_read_proc_implementations ||
                                        g_chr_newline;
      END IF;

      l_write_proc_implementations  := l_write_proc_implementations  ||
                                       l_write_proc_impl;

      l_read_proc_implementations   := l_read_proc_implementations   ||
                                       l_read_proc_impl;

      l_reset_interface_proc_stmts  := l_reset_interface_proc_stmts  ||
                                       l_reset_interface_proc_stmt;

   END LOOP;

   --Assign the OUT params
   x_write_proc_implementations := l_write_proc_implementations;
   x_read_proc_implementations  := l_read_proc_implementations;
   x_reset_interface_proc_stmts := l_reset_interface_proc_stmts;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'END ' || C_DEFAULT_MODULE||'.build_implementations'
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   RETURN l_return_value;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception
THEN
   RAISE;
WHEN OTHERS
THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_cmp_tab_pkg.build_implementations');

END build_implementations;



/*======================================================================+
|                                                                       |
| Private Function                                                      |
|                                                                       |
| create_temp_tables                                                    |
|                                                                       |
|                                                                       |
|                                                                       |
|                                                                       |
+======================================================================*/
FUNCTION create_temp_tables
RETURN BOOLEAN
IS
   l_return_value             BOOLEAN;
   l_global_table_name        VARCHAR2(50); --must contain the template
   l_table_creation_text      CLOB;
   l_log_module               VARCHAR2 (2000);

BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.create_temp_tables';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'BEGIN ' || C_DEFAULT_MODULE||'.create_temp_tables'
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   l_return_value := TRUE;

   --build the temp tables one at a time
   --For each distinct object name affix
   FOR affix_index IN 1..g_all_object_name_affixes.COUNT
   LOOP
      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace
            (p_module   => l_log_module
            ,p_msg      => 'current affix: ' ||
                           NVL(g_all_object_name_affixes(affix_index), 'NULL')
            ,p_level    => C_LEVEL_STATEMENT);
      END IF;

      IF NOT build_global_temp_table
              (
                p_object_name_affix   => g_all_object_name_affixes(affix_index)
               ,x_global_table_name   => l_global_table_name
               ,x_table_creation_text => l_table_creation_text
              )
      THEN
         l_return_value := FALSE;
         IF (C_LEVEL_ERROR >= g_log_level) THEN
             trace
             (p_module   => l_log_module
             ,p_msg      => 'build_global_temp_table failed'
            ,p_level    => C_LEVEL_ERROR);
         END IF;
      END IF;

      IF NOT xla_cmp_create_pkg.push_database_object
                (
                  p_object_name          => l_global_table_name
                 ,p_object_type          => 'TABLE'
                 ,p_ddl_text             => l_table_creation_text
                 ,p_apps_account         => g_application_info.apps_account
                 ,p_msg_mode             => G_OA_MESSAGE
                 ,p_object_owner         => g_application_info.oracle_username
                )
      THEN
         l_return_value := FALSE;
         IF (C_LEVEL_ERROR >= g_log_level) THEN
            trace
            (p_module   => l_log_module
            ,p_msg      => 'push_database_object failed'
            ,p_level    => C_LEVEL_ERROR);
         END IF;
      END IF;

   END LOOP;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'END ' || C_DEFAULT_MODULE||'.create_temp_tables'
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   RETURN l_return_value;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception
THEN
   RAISE;
WHEN OTHERS
THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_cmp_tab_pkg.create_temp_tables');

END create_temp_tables;


/*======================================================================+
|                                                                       |
| Private Function                                                      |
|                                                                       |
| get_interface_object_names                                            |
|                                                                       |
|                                                                       |
|                                                                       |
|                                                                       |
+======================================================================*/
FUNCTION get_interface_object_names
            (
              p_object_name_affix        IN         VARCHAR2
             ,x_global_table_name        OUT NOCOPY VARCHAR2
             ,x_plsql_table_name         OUT NOCOPY VARCHAR2
            )
RETURN BOOLEAN
IS
   l_return_value                BOOLEAN;

   l_global_table_name           VARCHAR2(100);
   l_plsql_table_name            VARCHAR2(100);
   l_log_module                  VARCHAR2 (2000);

BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.get_interface_object_names';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'BEGIN ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   --build the global temporary table name
   --get the template for the table name
   l_global_table_name    := C_TMPL_TAB_GLOBAL_TABLE_NAME;
   --replace the product abbreviation
   l_global_table_name := xla_cmp_string_pkg.replace_token
                        (
                          l_global_table_name
                         ,'$PRODUCT_ABBR$'
                         ,g_application_info.product_abbreviation
                        );
   --replace the object_name_affix
   l_global_table_name := xla_cmp_string_pkg.replace_token
                        (
                          l_global_table_name
                         ,'$OBJECT_NAME_AFFIX$'
                         ,CASE
                          WHEN p_object_name_affix IS NULL THEN '_'
                          ELSE '_' || p_object_name_affix || '_'
                          END
                        );

   --build the plsql table name
   --get the template for the table name
   l_plsql_table_name    := C_TMPL_TAB_PLSQL_TABLE_NAME;
   --replace the product abbreviation
   l_plsql_table_name := xla_cmp_string_pkg.replace_token
                        (
                          l_plsql_table_name
                         ,'$PRODUCT_ABBR$'
                         ,g_application_info.product_abbreviation
                        );
   --replace the object_name_affix
   l_plsql_table_name := xla_cmp_string_pkg.replace_token
                        (
                          l_plsql_table_name
                         ,'$OBJECT_NAME_AFFIX$'
                         ,CASE
                          WHEN p_object_name_affix IS NULL THEN ' '
                          ELSE '_' || p_object_name_affix
                          END
                        );

   --Assign the out parameters
   x_global_table_name := l_global_table_name;
   x_plsql_table_name  := l_plsql_table_name;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'END ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   RETURN l_return_value;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception
THEN
   RAISE;
WHEN OTHERS
THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_cmp_tab_pkg.get_interface_object_names');

END get_interface_object_names;



/*======================================================================+
|                                                                       |
| Private Function                                                      |
|                                                                       |
| get_interface_object_names                                            |
|                                                                       |
|                                                                       |
|                                                                       |
|                                                                       |
+======================================================================*/
FUNCTION get_interface_object_names
            (
              p_application_id           IN         VARCHAR2
             ,p_object_name_affix        IN         VARCHAR2
             ,x_global_table_name        OUT NOCOPY VARCHAR2
             ,x_plsql_table_name         OUT NOCOPY VARCHAR2
            )
RETURN BOOLEAN
IS
   l_return_value                BOOLEAN;

   l_global_table_name           VARCHAR2(30);
   l_plsql_table_name            VARCHAR2(30);
   l_log_module                  VARCHAR2(2000);

BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.get_interface_object_names';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'BEGIN ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   --If the function is called from an external procedure
   IF g_application_info.application_id IS NULL
   OR g_application_info.application_id <> p_application_id
   THEN
      --Initialize global variables
      IF NOT init_global_variables
                         (
                           p_application_id => p_application_id
                         )
      THEN
         --If global vars cannot be set we cannot continue
         IF (C_LEVEL_ERROR >= g_log_level) THEN
            trace
            (p_module => l_log_module
            ,p_msg      => 'init_global_variables failed'
            ,p_level    => C_LEVEL_ERROR);
          END IF;
          l_return_value := FALSE;
         RAISE le_fatal_error;
      END IF;
   END IF;

   IF NOT get_interface_object_names
            (
              p_object_name_affix        => p_object_name_affix
             ,x_global_table_name        => l_global_table_name
             ,x_plsql_table_name         => l_plsql_table_name
            )
   THEN
      --If global vars cannot be set we cannot continue
      IF (C_LEVEL_ERROR >= g_log_level) THEN
         trace
            ( p_module => l_log_module
             ,p_msg    => 'get_interface_object_names'
             ,p_level  => C_LEVEL_ERROR
            );
       END IF;
       l_return_value := FALSE;
       RAISE le_fatal_error;
   END IF;

   --Assign the out parameters
   x_global_table_name := l_global_table_name;
   x_plsql_table_name  := l_plsql_table_name;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'END ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   RETURN l_return_value;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception
THEN
   RAISE;
WHEN OTHERS
THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_cmp_tab_pkg.get_interface_object_names');

END get_interface_object_names;





/*======================================================================+
|                                                                       |
| Private Function                                                      |
|                                                                       |
| get_interface_sources                                                 |
|                                                                       |
|                                                                       |
|                                                                       |
|                                                                       |
+======================================================================*/
FUNCTION get_interface_sources
            (
              p_application_id            IN         VARCHAR2
             ,p_object_name_affix         IN         VARCHAR2
             ,x_table_of_sources          OUT NOCOPY gt_table_of_varchar2_30
             ,x_table_of_source_datatypes OUT NOCOPY gt_table_of_varchar2_1
            )
RETURN BOOLEAN
IS
   l_return_value                BOOLEAN;

   l_table_of_sources            gt_table_of_varchar2_30;
   l_table_of_source_datatypes   gt_table_of_varchar2_1;

   l_log_module                  VARCHAR2(2000);

BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.get_interface_sources';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'BEGIN ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   --If the function is called from an external procedure
   IF g_application_info.application_id IS NULL
   OR g_application_info.application_id <> p_application_id
   THEN
      --Initialize global variables
      IF NOT init_global_variables
                         (
                           p_application_id => p_application_id
                         )
      THEN
         --If global vars cannot be set we cannot continue
         IF (C_LEVEL_ERROR >= g_log_level) THEN
            trace
            (p_module => l_log_module
            ,p_msg      => 'init_global_variables failed'
            ,p_level    => C_LEVEL_ERROR);
          END IF;
          l_return_value := FALSE;
         RAISE le_fatal_error;
      END IF;
   END IF;

   --For each distinct source
   SELECT DISTINCT xsb.source_code
                  ,xsb.datatype_code
   BULK COLLECT
     INTO l_table_of_sources
         ,l_table_of_source_datatypes
     FROM xla_tab_acct_types_b   xtat
         ,xla_tab_acct_type_srcs xtsrc
         ,xla_sources_b          xsb
    WHERE xtat.application_id      = g_application_info.application_id
      AND NVL( xtat.object_name_affix
              ,LPAD('A',32, 'A')
             )
          = NVL( p_object_name_affix
                ,LPAD('A',32, 'A')
               )
      AND xtat.enabled_flag        =  'Y'
      AND xtat.compile_status_code =
             xla_cmp_common_pkg.G_COMPILE_STATUS_CODE_COMPILED
      AND xtsrc.account_type_code  = xtat.account_type_code
      AND xsb.application_id       = xtsrc.source_application_id
      AND xsb.source_code          = xtsrc.source_code
      AND xsb.source_type_code     = xtsrc.source_type_code
      AND xsb.source_type_code     = 'S' --only seeded sources
   ORDER BY xsb.source_code;

   IF l_table_of_sources IS NULL
   THEN
      RAISE le_fatal_error;

   END IF;

   --Assign the out parameters
   x_table_of_sources          := l_table_of_sources;
   x_table_of_source_datatypes := l_table_of_source_datatypes;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'END ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   RETURN l_return_value;
EXCEPTION
WHEN le_fatal_error
THEN
   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
            trace
            (p_module => l_log_module
            ,p_msg      => 'Fatal error'
            ,p_level    => C_LEVEL_ERROR);
   END IF;
   RETURN FALSE;
WHEN xla_exceptions_pkg.application_exception
THEN
   RAISE;
WHEN OTHERS
THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_cmp_tab_pkg.get_interface_sources');

END get_interface_sources;





/*======================================================================+
|                                                                       |
| Private Function                                                      |
|                                                                       |
| build_global_temp_table                                               |
|                                                                       |
|                                                                       |
|                                                                       |
|                                                                       |
+======================================================================*/
FUNCTION build_global_temp_table
            (
              p_object_name_affix        IN  VARCHAR2
             ,x_global_table_name        OUT NOCOPY VARCHAR2
             ,x_table_creation_text      OUT NOCOPY CLOB
            )
RETURN BOOLEAN
IS
   l_return_value                BOOLEAN;

   l_source_table_field_declars  CLOB;
   l_source_table_field_declar   CLOB;

   l_global_table_name           VARCHAR2(30);
   l_plsql_table_name            VARCHAR2(30);
   l_table_creation_text         CLOB;

   l_datatype_specific_declar    VARCHAR2(30);

   l_fatal_error_message         VARCHAR2(50);
   l_log_module                  VARCHAR2 (2000);

BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.build_global_temp_table';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'BEGIN ' || C_DEFAULT_MODULE||'.build_global_temp_table'
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   --build the table name
   IF NOT get_interface_object_names
            (
              p_object_name_affix        => p_object_name_affix
             ,x_global_table_name        => l_global_table_name
             ,x_plsql_table_name         => l_plsql_table_name
            )
   THEN
      l_fatal_error_message := 'No enabled Transaction Account Type found';
      RAISE le_fatal_error;
   END IF;

   --get the table creation template
   l_table_creation_text  := C_TMPL_TAB_GLOBAL_TEMP_TABLE;
   --replace the oracle user name
   l_table_creation_text := xla_cmp_string_pkg.replace_token
                        (
                          l_table_creation_text
                         ,'$ORACLE_USER_NAME$'
                         ,g_application_info.oracle_username
                        );
   --replace the global table name
   l_table_creation_text := xla_cmp_string_pkg.replace_token
                        (
                          l_table_creation_text
                         ,'$GLOBAL_TABLE_NAME$'
                         ,l_global_table_name
                        );

   --build the dynamic field declarations
   l_source_table_field_declars  := NULL;
   --For each distinct source
   FOR source_rec IN
      (
        SELECT DISTINCT xsb.source_code
                       ,xsb.source_type_code
                       ,xsb.enabled_flag
                       ,xsb.datatype_code
          FROM xla_tab_acct_types_b   xtat
              ,xla_tab_acct_type_srcs xtsrc
              ,xla_sources_b          xsb
         WHERE xtat.application_id      = g_application_info.application_id
           AND NVL( xtat.object_name_affix
                   ,LPAD('A',32, 'A')
                  )
               = NVL( p_object_name_affix
                     ,LPAD('A',32, 'A')
                    )
           AND xtat.enabled_flag        = 'Y'
           AND xtsrc.account_type_code  = xtat.account_type_code
           AND xsb.application_id       = xtsrc.source_application_id
           AND xsb.source_code          = xtsrc.source_code
           AND xsb.source_type_code     = xtsrc.source_type_code
	   ORDER BY xsb.source_code
      )
   LOOP
      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace
            ( p_module   => l_log_module
             ,p_msg      => 'Source code: ' || source_rec.source_code
             ,p_level    => C_LEVEL_STATEMENT);
      END IF;

      --If not a seeded source log an error and go to the next source
      IF source_rec.source_type_code <> 'S'
      THEN
         l_return_value := FALSE;
         IF (C_LEVEL_ERROR >= g_log_level) THEN
            trace
            ( p_module   => l_log_module
             ,p_msg      => 'Source ' || source_rec.source_code ||
                           ' is not a seeded source.' ||
                           'It will not be considered.'
             ,p_level    => C_LEVEL_ERROR);
         END IF;
      --If source is not enabled log an error and go to the next source
      ELSIF source_rec.enabled_flag <> 'Y'
      THEN
         l_return_value := FALSE;
         IF (C_LEVEL_ERROR >= g_log_level) THEN
            trace
            (p_module   => l_log_module
            ,p_msg      => 'Source ' || source_rec.source_code ||
                           ' is not enabled.' ||
                           'It will not be considered.'
            ,p_level    => C_LEVEL_ERROR);
         END IF;
      ELSE
         l_return_value := TRUE;

         --get the template for the source record field declaration
         l_source_table_field_declar   := C_TMPL_SOURCE_TABLE_FIELD_DECL;

         --replace the source code
         l_source_table_field_declar  := xla_cmp_string_pkg.replace_token
                              (
                                l_source_table_field_declar
                               ,'$SOURCE_CODE$'
                               ,RPAD( source_rec.source_code
                                     ,30
                                     ,' '
                                    )
                              );

         --replace the datatype
         CASE
         WHEN source_rec.datatype_code = 'I'
         THEN l_datatype_specific_declar := 'INTEGER';
         WHEN source_rec.datatype_code = 'N'
         THEN l_datatype_specific_declar := 'NUMBER';
         WHEN source_rec.datatype_code = 'C'
         THEN l_datatype_specific_declar := 'VARCHAR2('|| C_CHAR_SOURCE_SIZE ||')';
         WHEN source_rec.datatype_code = 'D'
         THEN l_datatype_specific_declar := 'DATE';
         WHEN source_rec.datatype_code = 'F'
         THEN l_datatype_specific_declar := 'INTEGER';
         ELSE
            l_return_value := FALSE;
            IF (C_LEVEL_ERROR >= g_log_level) THEN
               trace
                  (p_module   => l_log_module
                  ,p_msg      => 'Source ' || source_rec.source_code ||
                                 ' has an unknown datatype: ' ||
                                 source_rec.datatype_code ||'. ' ||
                                 'It will not be considered.'
                  ,p_level    => C_LEVEL_ERROR);
            END IF;

         END CASE;

         l_source_table_field_declar  := xla_cmp_string_pkg.replace_token
                                 (
                                   l_source_table_field_declar
                                  ,'$SOURCE_SPECIFIC_DATATYPE$'
                                  ,RPAD( l_datatype_specific_declar
                                        ,25
                                        ,' '
                                       )
                                 );


         IF l_source_table_field_declar  IS NOT NULL
         THEN
           l_source_table_field_declar  := l_source_table_field_declar ||
                                           g_chr_newline;
         END IF;

         l_source_table_field_declars  := l_source_table_field_declars ||
                                          l_source_table_field_declar;

      END IF;
   END LOOP;

   --replace the source field declarations token
   l_table_creation_text := xla_cmp_string_pkg.replace_token
                                 (
                                   l_table_creation_text
                                  ,'$SOURCE_TABLE_FIELD_DECLARATIONS$'
                                  ,NVL(l_source_table_field_declars, ' ')
                                 );

   --Assign the out parameters
   x_global_table_name   := l_global_table_name;
   x_table_creation_text := l_table_creation_text;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'END ' || C_DEFAULT_MODULE||'.build_global_temp_table'
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   RETURN l_return_value;
EXCEPTION
WHEN le_fatal_error
THEN
   IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
      trace
            ( p_module   => l_log_module
             ,p_msg      => 'EXCEPTION:'
             ,p_level    => C_LEVEL_EXCEPTION
            );
      trace
            ( p_module   => l_log_module
             ,p_msg      => l_fatal_error_message
             ,p_level    => C_LEVEL_EXCEPTION
            );
   END IF;
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'END ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;
   RETURN FALSE;
WHEN xla_exceptions_pkg.application_exception
THEN
   RAISE;
WHEN OTHERS
THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_cmp_tab_pkg.build_global_temp_table');

END build_global_temp_table;



/*======================================================================+
|                                                                       |
| Private Function                                                      |
|                                                                       |
| It builds the TAB API package name                                    |
| <PROD_ABBR>_XLA_TAB_PKG                                               |
|                                                                       |
|                                                                       |
|                                                                       |
+======================================================================*/
FUNCTION get_tab_api_package_name
                   (
                      p_tab_api_package_name OUT NOCOPY VARCHAR2
                   )
RETURN BOOLEAN
IS
   l_return_value            BOOLEAN;
   C_TAB_API_PKG_NAME_SUFFIX CONSTANT VARCHAR2(26) := '_XLA_TAB_PKG';
   l_log_module              VARCHAR2 (2000);
BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.get_tab_api_package_name';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'BEGIN ' || C_DEFAULT_MODULE||'.get_tab_api_package_name'
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   p_tab_api_package_name := g_application_info.product_abbreviation
                            || C_TAB_API_PKG_NAME_SUFFIX;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'l_return_value: ' || p_tab_api_package_name
         ,p_level    => C_LEVEL_STATEMENT);
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'END ' || C_DEFAULT_MODULE||'.get_tab_api_package_name'
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   RETURN TRUE;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception
THEN
   RAISE;
WHEN OTHERS
THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_cmp_tab_pkg.get_tab_api_package_name');

END get_tab_api_package_name;



FUNCTION get_tab_api_package_name
            (
              p_application_id           IN         VARCHAR2
             ,x_tab_api_package_name     OUT NOCOPY VARCHAR2
            )
RETURN BOOLEAN
IS
   l_return_value                BOOLEAN;
   l_tab_api_package_name        VARCHAR2(30);
   l_log_module                  VARCHAR2(2000);

BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.get_tab_api_package_name';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'BEGIN ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   l_return_value := TRUE;

   --If the function is called from an external procedure
   IF g_application_info.application_id IS NULL
   OR g_application_info.application_id <> p_application_id
   THEN
      --Initialize global variables
      IF NOT init_global_variables
                         (
                           p_application_id => p_application_id
                         )
      THEN
         --If global vars cannot be set we cannot continue
         IF (C_LEVEL_ERROR >= g_log_level) THEN
            trace
            (p_module => l_log_module
            ,p_msg      => 'init_global_variables failed'
            ,p_level    => C_LEVEL_ERROR);
          END IF;
          l_return_value := FALSE;
         RAISE le_fatal_error;
      END IF;
   END IF;

   IF NOT get_tab_api_package_name
            (
              p_tab_api_package_name => l_tab_api_package_name
            )
   THEN
      --If global vars cannot be set we cannot continue
      IF (C_LEVEL_ERROR >= g_log_level) THEN
         trace
            ( p_module => l_log_module
             ,p_msg    => 'get_tab_api_package_name'
             ,p_level  => C_LEVEL_ERROR
            );
       END IF;
       l_return_value := FALSE;
       RAISE le_fatal_error;
   END IF;

   --Assign the out parameters
   x_tab_api_package_name := l_tab_api_package_name;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'END ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   RETURN l_return_value;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception
THEN
   RAISE;
WHEN OTHERS
THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_cmp_tab_pkg.get_tab_api_package_name');

END get_tab_api_package_name;

/*======================================================================+
|                                                                       |
| Private Function                                                      |
|                                                                       |
| read_distinct_affixes                                                 |
|                                                                       |
|                                                                       |
| Returns false if no affixes are found                                 |
|                                                                       |
+======================================================================*/
FUNCTION read_distinct_affixes
                           ( p_application_id        IN NUMBER
                           )
RETURN BOOLEAN
IS
   l_return_value BOOLEAN;
   l_log_module   VARCHAR2 (2000);
BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.read_distinct_affixes';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'BEGIN ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   --If the function is called from an external procedure
   IF g_application_info.application_id IS NULL
   OR g_application_info.application_id <> p_application_id
   THEN
      --Initialize global variables
      IF NOT init_global_variables
                         (
                           p_application_id => p_application_id
                         )
      THEN
         --If global vars cannot be set we cannot continue
         IF (C_LEVEL_ERROR >= g_log_level) THEN
            trace
            (p_module => l_log_module
            ,p_msg      => 'init_global_variables failed'
            ,p_level    => C_LEVEL_ERROR);
          END IF;
          l_return_value := FALSE;
      RAISE le_fatal_error;
      END IF;
   END IF;

   l_return_value := TRUE;

   --retrieve all the distinct object name affixes for enabled TATs
   SELECT DISTINCT xtat.object_name_affix
     BULK COLLECT
     INTO g_all_object_name_affixes
     FROM xla_tab_acct_types_b xtat
    WHERE xtat.application_id      =  g_application_info.application_id
      AND xtat.enabled_flag        =  'Y'
   ORDER BY NVL(xtat.object_name_affix, ' ');

   --If there are no distinct affixes we must return a failure
   IF SQL%ROWCOUNT = 0
   THEN
      IF (C_LEVEL_ERROR >= g_log_level) THEN
         trace
            ( p_module   => l_log_module
             ,p_msg      => 'ERROR: No enabled Transaction Account Type found'
             ,p_level    => C_LEVEL_ERROR
            );
      END IF;
      RAISE le_fatal_error;
   END IF;

   --Dump the affixes that have been retrieved
   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'Object name affixes retrieved: '
                        || g_all_object_name_affixes.COUNT
         ,p_level    => C_LEVEL_STATEMENT);
      FOR i IN 1..g_all_object_name_affixes.COUNT
      LOOP
         trace
         (p_module => l_log_module
         ,p_msg      => i || ': ' || NVL(g_all_object_name_affixes(i), 'NULL')
         ,p_level    => C_LEVEL_STATEMENT);
      END LOOP;
   END IF;

   --Retrieve the compiled distinct object name affixes for enabled TATs
   SELECT DISTINCT xtat.object_name_affix
     BULK COLLECT
     INTO g_compiled_object_name_affixes
     FROM xla_tab_acct_types_b xtat
    WHERE xtat.application_id      =  g_application_info.application_id
      AND xtat.compile_status_code
             = xla_cmp_common_pkg.G_COMPILE_STATUS_CODE_COMPILED
   ORDER BY NVL(xtat.object_name_affix, ' ');

   --Dump the affixes that have been retrieved
   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'Compiled object name affixes retrieved: '
                        || g_all_object_name_affixes.COUNT
         ,p_level    => C_LEVEL_STATEMENT);
      FOR i IN 1..g_compiled_object_name_affixes.COUNT
      LOOP
         trace
         (p_module => l_log_module
         ,p_msg      => i || ': ' || NVL(g_compiled_object_name_affixes(i), 'NULL')
         ,p_level    => C_LEVEL_STATEMENT);
      END LOOP;
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'END ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   RETURN l_return_value;

EXCEPTION
WHEN le_fatal_error
THEN
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'END ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;
   RETURN FALSE;
WHEN xla_exceptions_pkg.application_exception
THEN
   RAISE;
WHEN OTHERS
THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_cmp_tab_pkg.read_distinct_affixes');

END read_distinct_affixes;


FUNCTION remove_deleted_tats
             (
                p_application_id IN NUMBER
             )
RETURN BOOLEAN
IS

l_return_value               BOOLEAN;
l_log_module                 VARCHAR2 (2000);
BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.remove_deleted_tats';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'BEGIN ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   --Remove Transaction Account Definitions deleted in the UI
   --for this application
   DELETE
     FROM xla_tab_acct_types_b xtat
    WHERE xtat.application_id      = p_application_id
      AND xtat.compile_status_code =
             xla_cmp_common_pkg.G_COMPILE_STATUS_CODE_DELETE;


   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_module   => l_log_module
         ,p_msg      => SQL%ROWCOUNT
                        || ' row(s) deleted from xla_tab_acct_types_b'
         ,p_level    => C_LEVEL_STATEMENT);
   END IF;

   l_return_value := TRUE;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'END ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   RETURN l_return_value;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception
THEN
   RAISE;
WHEN OTHERS
THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_cmp_tab_pkg.remove_deleted_tats');

END remove_deleted_tats;

FUNCTION get_tab_api_info_for_tat
            (
              p_application_id            IN         VARCHAR2
             ,p_account_type_code         IN         VARCHAR2
             ,x_object_name_affix         OUT NOCOPY VARCHAR2
             ,x_tab_api_package_name      OUT NOCOPY VARCHAR2
             ,x_global_table_name         OUT NOCOPY VARCHAR2
             ,x_plsql_table_name          OUT NOCOPY VARCHAR2
             ,x_write_proc_name           OUT NOCOPY VARCHAR2
             ,x_read_proc_name            OUT NOCOPY VARCHAR2
             ,x_table_of_sources          OUT NOCOPY FND_TABLE_OF_VARCHAR2_30
             ,x_table_of_source_datatypes OUT NOCOPY FND_TABLE_OF_VARCHAR2_1
            )
RETURN BOOLEAN
IS
l_return_value              BOOLEAN;

l_object_name_affix         VARCHAR2(50);
l_tab_api_package_name      VARCHAR2(50);
l_global_table_name         VARCHAR2(50);
l_plsql_table_name          VARCHAR2(50);
l_write_proc_name           VARCHAR2(50);
l_read_proc_name            VARCHAR2(50);
l_table_of_sources          gt_table_of_varchar2_30;
l_table_of_source_datatypes gt_table_of_varchar2_1;
l_fatal_error_message       VARCHAR2(255);
l_log_module                VARCHAR2 (2000);
BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.get_tab_api_info_for_tat';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'BEGIN ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   --If the function is called from an external procedure
   IF g_application_info.application_id IS NULL
   OR g_application_info.application_id <> p_application_id
   THEN
      --Initialize global variables
      IF NOT init_global_variables
                         (
                           p_application_id => p_application_id
                         )
      THEN
         --If global vars cannot be set we cannot continue
         IF (C_LEVEL_ERROR >= g_log_level) THEN
            trace
            (p_module => l_log_module
            ,p_msg      => 'init_global_variables failed'
            ,p_level    => C_LEVEL_ERROR);
          END IF;
          l_return_value := FALSE;
         RAISE le_fatal_error;
      END IF;
   END IF;

   --Get the object name affix for the specified TAT
   SELECT xtat.object_name_affix
     INTO l_object_name_affix
     FROM xla_tab_acct_types_b xtat
    WHERE xtat.application_id      =  g_application_info.application_id
      AND xtat.account_type_code   =  p_account_type_code
      AND xtat.enabled_flag        =  'Y'
   ORDER BY NVL(xtat.object_name_affix, ' ');

   --Get the name of the interface tables
   IF NOT get_interface_object_names
            (
              p_application_id      => p_application_id
             ,p_object_name_affix   => l_object_name_affix
             ,x_global_table_name   => l_global_table_name
             ,x_plsql_table_name    => l_plsql_table_name
            )
   THEN
      l_fatal_error_message := 'get_interface_object_names failed';
      RAISE le_fatal_error;
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'END ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   --Get the TAB API package name
   IF NOT get_tab_api_package_name
                   (
                      p_tab_api_package_name => l_tab_api_package_name
                   )
   THEN
      l_fatal_error_message := 'get_tab_api_package_name failed';
      RAISE le_fatal_error;
   END IF;

   --Build the proc names
   l_write_proc_name := xla_cmp_string_pkg.replace_token
                        (
                          C_TMPL_TAB_WRITE_PROC_NAME
                         ,'$OBJECT_NAME_AFFIX$'
                         ,CASE
                          WHEN l_object_name_affix IS NULL THEN ' '
                          ELSE '_' || l_object_name_affix
                          END
                        );

   l_read_proc_name := xla_cmp_string_pkg.replace_token
                        (
                          C_TMPL_TAB_READ_PROC_NAME
                         ,'$OBJECT_NAME_AFFIX$'
                         ,CASE
                          WHEN l_object_name_affix IS NULL THEN ' '
                          ELSE '_' || l_object_name_affix
                          END
                        );


   --Get the ordered list of sources of the write and read procedures
   IF NOT get_interface_sources
            (
              p_application_id            => p_application_id
             ,p_object_name_affix         => l_object_name_affix
             ,x_table_of_sources          => l_table_of_sources
             ,x_table_of_source_datatypes => l_table_of_source_datatypes
            )
   THEN
      l_fatal_error_message := 'get_interface_sources failed';
      RAISE le_fatal_error;
   END IF;

   --Assign OUT parameters
   x_table_of_sources          := FND_TABLE_OF_VARCHAR2_30();
   x_table_of_source_datatypes := FND_TABLE_OF_VARCHAR2_1();
   IF  l_table_of_sources IS NOT NULL
   AND l_table_of_sources.COUNT > 0
   THEN
      x_table_of_sources.EXTEND(l_table_of_sources.COUNT);
      x_table_of_source_datatypes.EXTEND(l_table_of_sources.COUNT);
      FOR i IN 1..l_table_of_sources.COUNT
      LOOP
         x_table_of_sources(i)          := l_table_of_sources(i);
         x_table_of_source_datatypes(i) := l_table_of_source_datatypes(i);
      END LOOP;
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'END ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;
   x_object_name_affix     := l_object_name_affix;
   x_tab_api_package_name  := l_tab_api_package_name;
   x_global_table_name     := l_global_table_name;
   x_plsql_table_name      := l_plsql_table_name;
   x_write_proc_name       := l_write_proc_name;
   x_read_proc_name        := l_read_proc_name;

   l_return_value := TRUE;
   RETURN l_return_value;

EXCEPTION
WHEN le_fatal_error
THEN
   IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
      trace
         (p_module   => l_log_module
         ,p_msg      => l_fatal_error_message
         ,p_level    => C_LEVEL_EXCEPTION);
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'END ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;
   RETURN FALSE;
WHEN xla_exceptions_pkg.application_exception
THEN
   RAISE;
WHEN OTHERS
THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_cmp_tab_pkg.get_tab_api_info_for_tat');
END;

FUNCTION get_ccid_additional_info
            (
              p_chart_of_accounts_id      IN         NUMBER
             ,p_ccid                      IN         NUMBER
             ,x_concatenated_descriptions OUT NOCOPY VARCHAR2
            )
RETURN BOOLEAN
IS
l_return_value              BOOLEAN;

l_fatal_error_message       VARCHAR2(255);
l_log_module                VARCHAR2(2000);
BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.get_ccid_additional_info';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'BEGIN ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   IF NOT FND_FLEX_KEYVAL.validate_ccid
      (
        appl_short_name 	=> 'SQLGL'
       ,key_flex_code	  	=> 'GL#'
       ,structure_number	=> p_chart_of_accounts_id
       ,combination_id	  	=> p_ccid
       ,displayable		=> 'ALL'
       ,data_set		=> NULL
       ,vrule			=> NULL
       ,security		=> 'IGNORE'
       ,get_columns		=> NULL
       ,resp_appl_id 		=> NULL
       ,resp_id			=> NULL
       ,user_id			=> NULL
       ,select_comb_from_view   => NULL
       )
   THEN
      l_fatal_error_message := 'FND_FLEX_KEYVAL.validate_ccid failed';
      RAISE le_fatal_error;
   END IF;

   x_concatenated_descriptions := FND_FLEX_KEYVAL.concatenated_descriptions;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
       trace
         (p_module => l_log_module
         ,p_msg      => 'END ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   l_return_value := TRUE;
   RETURN l_return_value;

EXCEPTION
WHEN le_fatal_error
THEN
   IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
      trace
         (p_module   => l_log_module
         ,p_msg      => l_fatal_error_message
         ,p_level    => C_LEVEL_EXCEPTION);
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'END ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;
   RETURN FALSE;
WHEN xla_exceptions_pkg.application_exception
THEN
   RAISE;
WHEN OTHERS
THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_cmp_tab_pkg.get_ccid_additional_info');
END;




--Trace initialization
BEGIN
   g_log_level      := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
   g_log_enabled    := fnd_log.test
                          (log_level  => g_log_level
                          ,module     => C_DEFAULT_MODULE);

   IF NOT g_log_enabled  THEN
      g_log_level := C_LEVEL_LOG_DISABLED;
   END IF;

END xla_cmp_tab_pkg;

/
