--------------------------------------------------------
--  DDL for Package GL_CI_WORKFLOW_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_CI_WORKFLOW_PKG" AUTHID CURRENT_USER AS
/* $Header: gluciwfs.pls 120.3 2005/05/05 01:37:26 kvora noship $ */
-- Start of DDL Script for Package APPS.GL_CI_WORKFLOW_PKG
-- Generated 1-Jun-2004 16:04:41 from APPS@findv115
--+    Public variables
diagn_msg_flag       BOOLEAN := TRUE;    --+ Determines if diagnostic messages are displayed
  --+ Procedure
  --+ SEND_CIT_NTF
  --+ Purpose
  --+    Called from  GL_CI_DATA_TRANSFER_PKG
  --+    Create work flow process and Start work notification process if
  --+  Transaction amount is greater then Threshold amount
  --+ Arguments
  --+  IN PARAMETERS
  --+  1. concurrent request id
  --+  2. Action on transaction
  --+ OUT NOCOPY Parameter
  --+ p_Return_Code
  --+ NOTIFICATION_PROCESS_STARTED  Number :=  0;
  --+ FATAL_EXCEPTION               Number := -1;
  --+ INVALID_ACTION                Number := -3;
  --+ CONTACT_INFO_NOT_FOUND        Number := -4;
  --+ Example
  --+    GL_CI_WORKFLOW_PKG.SEND_CIT_NTF
  --+ Notes
  --+
PROCEDURE SEND_CIT_WF_NTF
(  p_cons_request_id                IN  number,  --+consolidation request id
   p_Action                    IN  VARCHAR2,
   p_dblink                    IN  varchar2,
   p_batch_name                IN  varchar2,  --+100 CHARS
   p_source_database_name      IN  varchar2,
   p_target_ledger_name        IN  varchar2,
   p_interface_table_name      IN  varchar2,
   p_interface_run_id          IN  number,
   p_posting_run_id            IN  number,
   p_request_id                IN  number,
   p_group_id                  IN  number,
   p_send_to                   IN  varchar2,
   p_sender_name               IN  varchar2,
   p_message_name              IN  varchar2,
   p_send_from                 IN  varchar2,
   p_source_ledger_id          IN  number,
   p_import_message_body       IN  varchar2,
   p_post_request_id           IN  varchar2,
   p_Return_Code               OUT NOCOPY NUMBER);
  --+ Procedure
  --+ Get_Action_Type
  --+ Purpose
  --+    Called from  GLCITNTF Worlflow process
  --+   Determine what what message to be sent with notification
  --+ Example
  --+    GL_CI_WORKFLOW_PKG.Get_Action_Type
  --+ Notes
  --+
Procedure Get_Action_Type
               ( p_item_type      IN VARCHAR2,
                 p_item_key       IN VARCHAR2,
                 p_actid          IN NUMBER,
                 p_funcmode       IN VARCHAR2,
                 p_result         OUT NOCOPY VARCHAR2 );
  --+ Procedure
  --+ set_wf_variables
  --+ Purpose
  --+    Called from  SEND_cit_NTF
  --+   Sets workflow variables
  --+ Example
  --+    GL_CI_WORKFLOW_PKG.set_wf_variables
  --+ Notes
  --+
Procedure set_wf_variables (
   l_item_type                  IN VARCHAR2,
   l_item_key                   IN NUMBER,
   l_application_name           IN VARCHAR2,
   l_responsibility_name        IN VARCHAR2,
   l_user_name                  IN VARCHAR2,
   l_mapping_rule_name          IN VARCHAR2,
   l_batch_name                 IN VARChar2,  --+100 CHARS
   l_source_database_name       IN VARCHAR2,
   l_target_database_name       IN VARCHAR2,
   l_source_ledger_name         IN VARCHAR2,
   l_target_ledger_name         IN VARCHAR2,
   l_period_name                IN VARCHAR2,  --+15 CHARS
   l_journal_source_name        IN VARCHAR2,  --+25 chars
   l_interface_table_name       IN VARCHAR2,
   l_interface_run_id           IN number,
   l_posting_run_id             IN number,
   l_request_id                 IN number,
   l_group_id                   IN number,
   l_send_to                    IN VARCHAR2,
   l_sender_name                IN VARCHAR2,
   l_message_name               IN varchar2,
   l_send_from                  IN VARCHAR2,
   l_import_message_body        IN VARCHAR2,
   l_post_request_id            IN varchar2);
 --+ Function
  --+ set_wf_variables
  --+ Purpose
  --+    Called from  SEND_CIT_NTF
  --+   Sets workflow item key
  --+ Example
  --+    GL_CI_WORKFLOW_PKG.get_unique_id
  --+ Notes
  --+
FUNCTION get_unique_id RETURN NUMBER;
End GL_CI_WORKFLOW_PKG;

 

/
