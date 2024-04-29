--------------------------------------------------------
--  DDL for Package PQH_GSP_PROCESS_LOG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_GSP_PROCESS_LOG" AUTHID CURRENT_USER as
/* $Header: pqgsplog.pkh 115.2 2003/10/10 03:08 vevenkat noship $ */
Procedure Start_log
(P_Txn_ID            IN    NUMBER
,P_Txn_Name          IN    VARCHAR2
,P_Module_Cd         IN    VARCHAR2) ;


PROCEDURE Log_process_Dtls
(P_Master_txn_Id    IN NUMBER
,P_Txn_Id           IN Number
,p_module_cd        IN Varchar2
,p_Context          IN varchar2 Default NULL
,p_message_type_cd  IN varchar2
,p_message_text     IN varchar2
,P_Effective_Date   IN Date);

End Pqh_Gsp_process_Log;

 

/
