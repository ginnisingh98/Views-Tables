--------------------------------------------------------
--  DDL for Package Body PQH_GSP_PROCESS_LOG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_GSP_PROCESS_LOG" as
/* $Header: pqgsplog.pkb 115.7 2004/01/28 07:22 vevenkat noship $ */

Procedure Start_log
(P_Txn_ID            IN    NUMBER
,P_Txn_Name          IN    VARCHAR2
,P_Module_Cd         IN    VARCHAR2) Is

Begin

/* This will Start the Process Log for the Given Module Code
   the module can be AI => Approval UI
                     BP => Batch Process and
                     AI => Assignment API */

PQH_PROCESS_BATCH_LOG.START_LOG(p_batch_id             => P_Txn_ID
                               ,p_module_cd            => P_Module_Cd
                               ,p_log_context          => P_Txn_Name
                               ,p_information_category => 'POST_PROCESS');

End Start_log;

Procedure Insert_Log
(p_module_cd             IN      Varchar2
,p_txn_id                IN      Number
,p_log_context           IN      Varchar2
,p_master_process_log_id IN      Number
,p_message_text          IN      Varchar2
,p_message_type_cd       IN      Varchar2
,P_Information1          IN      Varchar2
,P_Information2          IN      Varchar2
,P_Information3          IN      Varchar2) IS

L_Ovn                 Pqh_Process_Log.Object_Version_Number%TYPE;
L_process_log_Id      Pqh_Process_log.Process_log_id%TYPE;
PRAGMA                AUTONOMOUS_TRANSACTION;

Begin

pqh_process_log_api.create_process_log
                   (p_process_log_id        => L_Process_Log_Id
                   ,p_module_cd             => P_Module_Cd
                   ,p_txn_id                => P_Txn_id
                   ,p_log_context           => P_Log_Context
                   ,p_master_process_log_id => P_Master_Process_log_id
                   ,p_message_text          => NVL(p_message_text,Hr_general.Decode_Lookup('PQH_GSP_GEN_PROMPTS','CMPSUC'))
                   ,p_message_type_cd       => P_Message_Type_Cd
                   ,p_information_category  => 'GSP'
                   ,p_object_version_number => l_ovn
                   ,P_Information1	    => P_Information1
                   ,P_Information2          => P_Information2
                   ,P_Information3          => P_information3
                   ,p_effective_date        => sysdate);

Commit;

End Insert_Log;

PROCEDURE Log_process_Dtls(P_Master_txn_Id    IN NUMBER
 			  ,P_Txn_Id           IN Number
                          ,p_module_cd        IN Varchar2
                          ,p_Context          IN varchar2 Default NULL
                          ,p_message_type_cd  IN varchar2
                          ,p_message_text     IN varchar2
                          ,P_Effective_Date   IN Date) Is
Cursor Elctbl_Dtls Is
Select GRADE_LADDER_NAME,
       GRADE_NAME,
       STEP_NAME,
       FULL_NAME
  From PQH_GSP_ELECTABLE_CHOICE_V
 Where Elig_Per_Elctbl_Chc_id = P_Txn_Id;

 Cursor Person_Dtls is
 Select Decode(Assgt.Grade_ladder_Pgm_id, NULL, NULL, Ben_Batch_Utils.GET_PGM_NAME(Assgt.Grade_ladder_Pgm_id,
                                     Assgt.BUSINESS_GROUP_ID,
	                             P_Effective_Date)),
	Hr_general.Decode_Grade(Grade_Id),
        pqh_gsp_utility.Get_Step_Dtls(Assgt.Assignment_id,
                                      P_Effective_Date,
                                      'N',
                                      'CURR'),
        Person.Full_name
   From Per_All_Assignments_F Assgt,
        Per_All_People_F Person
  Where Assignment_id = P_Txn_id
    and P_Effective_Date
Between Assgt.Effective_Start_Date
    and Assgt.Effective_End_Date
    and Assgt.Person_Id = Person.Person_id
    and P_Effective_Date
Between Person.Effective_Start_Date
    and Person.Effective_End_Date;

 Cursor Grdldr Is
 Select information5
   From ben_copy_entity_results
  Where copy_entity_txn_id = P_Txn_id
    and table_alias ='PGM';

Cursor Master_Log is
Select Process_Log_Id
  From Pqh_Process_Log
 Where Txn_id    = P_Master_txn_Id
   and MODULE_CD = P_Module_Cd;

L_Grade_Ladder_Name   Ben_Pgm_F.Name%TYPE;
l_Grade_name          Per_Grades.Name%TYPE;
l_Step_name           Per_Spinal_Points.Spinal_POint%TYPE;
l_Person_Name         Per_All_People_F.Full_name%TYPE;
L_LOG_ID              Pqh_Process_Log.Process_Log_Id%TYPE;
L_MASTER_LOG_ID       Pqh_Process_Log.MASTER_PROCESS_LOG_ID%TYPE;
l_Message_Type        Varchar2(25);
L_Log_Context         Pqh_Process_log.Log_Context%TYPE;

Begin

If p_module_cd = 'PQH_GSP_APPROVAL_UI' Then

   Open Elctbl_Dtls;
   Fetch Elctbl_Dtls Into L_Grade_Ladder_Name, l_Grade_name, l_Step_name, L_Log_Context;
   Close Elctbl_Dtls;

Elsif p_module_cd in ('PQH_GSP_ASSIGN_ENTL','PQH_GSP_BATCH_ENRL','PQH_GSP_DFLT_ENRL') then
   Open  Person_Dtls;
   Fetch Person_Dtls Into L_Grade_Ladder_Name, l_Grade_name, l_Step_name, l_Log_Context;
   Close Person_Dtls;

ElsIf P_Module_Cd in ('PQH_GSP_STGBEN','PQH_GSP_BENSTG') Then
   if p_context is null then
      Open Grdldr;
      Fetch Grdldr into L_Log_Context;
      Close Grdldr;
   else
      l_log_context := p_context ;
   end If;
End If;

If P_Module_Cd = 'PQH_GSP_DFLT_ENRL' Then
   Fnd_File.New_Line(WHICH => fnd_file.log);
   Ben_batch_utils.write(Hr_general.Decode_Lookup('PQH_GSP_GEN_PROMPTS','EMPDTLS'));
   Ben_batch_utils.write(Hr_general.Decode_Lookup('PQH_GSP_GEN_PROMPTS','NAME') || l_Log_Context);
   Ben_batch_utils.write(Hr_general.Decode_Lookup('PQH_GSP_GEN_PROMPTS','GRDLDR') || L_Grade_Ladder_Name);

   If l_Grade_name is NOT NULL Then
      Ben_batch_utils.write(Hr_general.Decode_Lookup('PQH_GSP_GEN_PROMPTS','GRADE') || l_Grade_name);
      Ben_batch_utils.write(Hr_general.Decode_Lookup('PQH_GSP_GEN_PROMPTS','STEP') || l_Step_name);
   End If;
   Ben_batch_utils.write(Hr_general.Decode_Lookup('PQH_GSP_GEN_PROMPTS','ERRMSG') || p_message_text);
   Return;
End If;

Open Master_Log;
Fetch Master_Log into l_Master_log_id;
Close Master_Log;

If P_message_type_cd  = 'E' Then
   l_Message_Type := 'ERROR';
Elsif P_message_type_cd = 'C' Then
   l_Message_Type := 'COMPLETE';
End If;

Insert_log(p_module_cd             => P_Module_Cd
          ,p_txn_id                => P_Txn_id
          ,p_log_context           => l_Log_Context
          ,p_master_process_log_id => l_Master_log_id
          ,p_message_text          => NVL(p_message_text,Hr_general.Decode_Lookup('PQH_GSP_GEN_PROMPTS','CMPSUC'))
          ,p_message_type_cd       => l_Message_Type
          ,P_Information1	   => L_Grade_Ladder_name
          ,P_Information2          => L_Grade_name
          ,P_Information3          => L_Step_Name);

End;

End Pqh_Gsp_process_Log;

/
