--------------------------------------------------------
--  DDL for Package Body FEM_GENDEFAULTS_ENG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FEM_GENDEFAULTS_ENG_PKG" AS
-- $Header: fem_gendflt_eng.plb 120.0 2006/07/11 18:00:13 rflippo ship $

/***************************************************************************
                    Copyright (c) 2003 Oracle Corporation
                           Redwood Shores, CA, USA
                             All rights reserved.
 ***************************************************************************
  FILENAME
    fem_gendflt_eng.plb

  DESCRIPTION
    See fem_gendefaults_eng.pls for details

  HISTORY
    Rob Flippo   07-JUL-2006   Created

 **************************************************************************/

-------------------------------
-- Declare package variables --
-------------------------------
   f_set_status  BOOLEAN;

   c_log_level_1  CONSTANT  NUMBER  := fnd_log.level_statement;
   c_log_level_2  CONSTANT  NUMBER  := fnd_log.level_procedure;
   c_log_level_3  CONSTANT  NUMBER  := fnd_log.level_event;
   c_log_level_4  CONSTANT  NUMBER  := fnd_log.level_exception;
   c_log_level_5  CONSTANT  NUMBER  := fnd_log.level_error;
   c_log_level_6  CONSTANT  NUMBER  := fnd_log.level_unexpected;

   v_log_level    NUMBER;

   gv_prg_msg      VARCHAR2(2000);
   gv_callstack    VARCHAR2(2000);
   g_log_current_level NUMBER;


-- Private Internal Procedures
   procedure report_errors;

-----------------------------------------------------------------------------
--  Package bodies for functions/procedures
-----------------------------------------------------------------------------
/*===========================================================================+
 | PROCEDURE
 |              Report_Errors
 |
 | DESCRIPTION
 |    Retrieves messages from the stack and reports them to the appropriate
 |    log
 | SCOPE - PRIVATE
 |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |              OUT:
 |
 |
 | NOTES
 |
 |
 | MODIFICATION HISTORY
 |    Rob Flippo   02-MAY-05  Created
 |
 +===========================================================================*/
PROCEDURE Report_errors IS

   v_msg_count NUMBER;  -- this is the return count from FND of # messages
   v_msg_data VARCHAR2(1000); -- this is the message value when only 1 msg
                              -- from FND
   v_message          VARCHAR2(4000);
   v_msg_index_out    NUMBER;
   v_block  CONSTANT  VARCHAR2(80) :=
      'fem.plsql.fem_refresh_eng_pkg.report_errors';


BEGIN

   IF c_log_level_2 >= g_log_current_level THEN
      FEM_ENGINES_PKG.Tech_Message
        (p_severity => c_log_level_2,
         p_module   => c_block||'.'||'Report_errors',
         p_msg_text => 'BEGIN');
   END IF;

   -- Count the number of messages on the stack
   FND_MSG_PUB.count_and_get(p_encoded => c_false
                            ,p_count => v_msg_count
                            ,p_data => v_msg_data);


   IF (v_msg_count = 1) THEN
      FND_MESSAGE.Set_Encoded(v_msg_data);
      v_message := FND_MESSAGE.Get;

      FEM_ENGINES_PKG.User_Message(
        p_msg_text => v_message);


   IF c_log_level_1 >= g_log_current_level THEN
      FEM_ENGINES_PKG.TECH_MESSAGE
       (p_severity => c_log_level_1,
        p_module => v_block||'.msg_data',
        p_msg_text => v_message);
   END IF;

   ELSIF (v_msg_count > 1) THEN
      FOR i IN 1..v_msg_count LOOP
         FND_MSG_PUB.Get(
         p_msg_index => i,
         p_encoded => c_false,
         p_data => v_message,
         p_msg_index_out => v_msg_index_out);

         FEM_ENGINES_PKG.User_Message(
           p_msg_text => v_message);

         IF c_log_level_1 >= g_log_current_level THEN
            FEM_ENGINES_PKG.TECH_MESSAGE
             (p_severity => c_log_level_1,
              p_module => v_block||'.msg_data',
              p_msg_text => v_message);
        END IF;

      END LOOP;
   END IF;

   FND_MSG_PUB.Initialize;

   FEM_ENGINES_PKG.Tech_Message
     (p_severity => c_log_level_2,
      p_module   => c_block||'.'||'Report_errors',
      p_msg_text => 'END');


END Report_errors;




/*===========================================================================+
 | PROCEDURE
 |                 Main
 |
 | DESCRIPTION
 |
 |
 |
 | SCOPE - PUBLIC
 |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |
 |              OUT:
 |
 |              IN/ OUT:
 |
 | RETURNS    : NONE
 |
 | NOTES
 |      The purpose of this package is to create rapid prototype data for EPF.
 |      The engine creates the following:
 |        1)  A starter Cal Period member and Cal Period hierarchy
 |        2)  A starter Ledger
 |        3)  A "Default" member for every empty dimension in the database
 | HISTORY
 |    10-JUL-06 Rob Flippo   initial creation
 |
 ===========================================================================*/
PROCEDURE Main (
   errbuf                       OUT NOCOPY     VARCHAR2
  ,retcode                      OUT NOCOPY     VARCHAR2
)

IS

   c_proc_name CONSTANT VARCHAR2(30) := 'Main';



   v_concurrent_status BOOLEAN;
   v_execution_status VARCHAR2(30);

   v_proc_return_status VARCHAR2(4000);
   v_msg_count     NUMBER;
   v_msg_data      VARCHAR2(4000);

   v_appltop VARCHAR2(1000);
   v_release VARCHAR2(100);
   -- Nested Procedure declarations

---------------------------------------------------------------------------
--  Main body of the "Main" procedure
---------------------------------------------------------------------------
BEGIN

   g_log_current_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;


   IF c_log_level_2 >= g_log_current_level THEN
      FEM_ENGINES_PKG.TECH_MESSAGE
       (p_severity => c_log_level_2
       ,p_module => c_block||'.'||c_proc_name
       ,p_msg_text => 'begin');
   END IF;

   -- initialize the message stack
   FND_MSG_PUB.Initialize;

   v_execution_status := 'SUCCESS';
   gv_request_id := fnd_global.conc_request_id;

   fem_defcalp_util_pkg.main(v_proc_return_status);

   IF c_log_level_1 >= g_log_current_level THEN
      FEM_ENGINES_PKG.TECH_MESSAGE
       (p_severity => c_log_level_1
       ,p_module => c_block||'.'||c_proc_name||'.v_proc_return_status'
       ,p_msg_text => v_proc_return_status);
   END IF;

   IF v_proc_return_status <> 'SUCCESS' THEN
      v_execution_status := 'ERROR_RERUN';
   END IF;

   FEM_Dimension_Util_Pkg.Generate_Default_Load_Member (
     x_return_status => v_proc_return_status,
     x_msg_count => v_msg_count,
     x_msg_data => v_msg_data
   );

   IF c_log_level_1 >= g_log_current_level THEN
      FEM_ENGINES_PKG.TECH_MESSAGE
       (p_severity => c_log_level_1
       ,p_module => c_block||'.'||c_proc_name||'.v_proc_return_status'
       ,p_msg_text => v_proc_return_status);
   END IF;

   IF v_proc_return_status <> 'S' THEN
      v_execution_status := 'ERROR_RERUN';
   END IF;

   Report_errors;



   IF v_execution_status = 'ERROR_RERUN' THEN
     retcode := 2;
     FEM_ENGINES_PKG.USER_MESSAGE
     (P_APP_NAME => c_fem
     ,P_MSG_NAME => 'FEM_EXEC_RERUN');
   ELSE
      FEM_ENGINES_PKG.USER_MESSAGE
       (P_APP_NAME => c_fem
       ,P_MSG_NAME => 'FEM_GDFT_COMPLETION');

   END IF;


EXCEPTION

   WHEN OTHERS THEN
      retcode := 2;
      gv_prg_msg := sqlerrm;
      gv_callstack := dbms_utility.format_call_stack;

      IF c_log_level_6 >= g_log_current_level THEN
         FEM_ENGINES_PKG.TECH_MESSAGE
          (p_severity => c_log_level_6
          ,p_module => c_block||'.'||c_proc_name||'.Unexpected Exception'
          ,p_msg_text => gv_prg_msg);

         FEM_ENGINES_PKG.TECH_MESSAGE
          (p_severity => c_log_level_6
          ,p_module => c_block||'.'||c_proc_name||'.Unexpected Exception'
          ,p_msg_text => gv_callstack);
      END IF;

      FEM_ENGINES_PKG.USER_MESSAGE
       (p_app_name => c_fem
       ,p_msg_name => 'FEM_UNEXPECTED_ERROR'
       ,P_TOKEN1 => 'ERR_MSG'
       ,P_VALUE1 => gv_prg_msg);


END Main;

/***************************************************************************/

END FEM_GENDEFAULTS_ENG_PKG;

/
