--------------------------------------------------------
--  DDL for Package Body PQH_GSP_POST_PROCESS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_GSP_POST_PROCESS" as
/* $Header: pqhgsppp.pkb 120.6.12010000.11 2009/09/25 04:43:14 ghshanka ship $ */
--

/**************************************************************************/
/**************************Call_PP_From_Assignments************************/
/**************************************************************************/

g_debug boolean := hr_utility.debug_enabled;

Function dt_del_mode
(P_EFFECTIVE_DATE        IN       DATE
,P_BASE_TABLE_NAME       IN       VARCHAR2
,P_BASE_KEY_COLUMN       IN       VARCHAR2
,P_BASE_KEY_VALUE        IN       NUMBER) Return Varchar2 is
--
l_zap                  Boolean;
l_delete               Boolean;
l_future_change        Boolean;
l_delete_next_change   Boolean;
--
Begin
  --
g_debug := hr_utility.debug_enabled;
if g_debug then
   hr_utility.set_location(' DT Mode ',10);
   hr_utility.set_location(' P_Effective_Date ' || P_Effective_Date, 20);
   hr_utility.set_location(' P_BASE_TABLE_NAME ' || P_BASE_TABLE_NAME,30);
   hr_utility.set_location(' P_BASE_KEY_COLUMN ' || P_BASE_KEY_COLUMN, 40);
   hr_utility.set_location(' P_BASE_KEY_VALUE ' || P_BASE_KEY_VALUE, 50);
End If;

dt_api.find_dt_del_modes
   (p_effective_date                => p_effective_date
   ,p_base_table_name               => P_BASE_TABLE_NAME
   ,p_base_key_column               => P_BASE_KEY_COLUMN
   ,p_base_key_value                => p_base_key_value
   ,p_zap                           => l_zap
   ,p_delete                        => l_delete
   ,p_future_change                 => l_future_change
   ,p_delete_next_change            => l_delete_next_change
   );
 --
 If l_zap then
    Return 'ZAP';
 elsif l_delete then
    Return 'DELETE';
 elsif l_future_change then
    Return 'FUTURE_CHANGE';
 elsif l_delete_next_change then
    Return 'DELETE_NEXT_CHANGE';
 End if;
 --
End;
--

Function DT_Mode
(P_EFFECTIVE_DATE        IN       DATE
,P_BASE_TABLE_NAME       IN       VARCHAR2
,P_BASE_KEY_COLUMN       IN       VARCHAR2
,P_BASE_KEY_VALUE        IN       NUMBER) Return Varchar2 is

L_CORRECTION             Boolean;
L_UPDATE                 Boolean;
L_UPDATE_OVERRIDE        Boolean;
L_UPDATE_CHANGE_INSERT   Boolean;

Begin
g_debug := hr_utility.debug_enabled;
if g_debug then
   hr_utility.set_location(' DT Mode ',10);
   hr_utility.set_location(' P_Effective_Date ' || P_Effective_Date, 20);
   hr_utility.set_location(' P_BASE_TABLE_NAME ' || P_BASE_TABLE_NAME,30);
   hr_utility.set_location(' P_BASE_KEY_COLUMN ' || P_BASE_KEY_COLUMN, 40);
   hr_utility.set_location(' P_BASE_KEY_VALUE ' || P_BASE_KEY_VALUE, 50);
End If;

Dt_Api.FIND_DT_UPD_MODES
(P_EFFECTIVE_DATE         =>  P_Effective_Date
,P_BASE_TABLE_NAME        =>  P_BASE_TABLE_NAME
,P_BASE_KEY_COLUMN        =>  P_BASE_KEY_COLUMN
,P_BASE_KEY_VALUE         =>  P_BASE_KEY_VALUE
,P_CORRECTION             =>  L_CORRECTION
,P_UPDATE                 =>  L_UPDATE
,P_UPDATE_OVERRIDE        =>  L_UPDATE_OVERRIDE
,P_UPDATE_CHANGE_INSERT   =>  L_UPDATE_CHANGE_INSERT);

If L_Update Then
   Return 'UPDATE';
Elsif L_UPDATE_CHANGE_INSERT then
   return 'UPDATE_CHANGE_INSERT';
Elsif L_Update_Override Then
      Return 'UPDATE_OVERRIDE';
Elsif L_CORRECTION Then
   Return 'CORRECTION';
End If;

End;

Procedure Call_PP_From_Assignments
(P_Effective_Date	IN  Date,
 P_Assignment_Id	IN  Number,
 P_Date_track_Mode	IN  Varchar2,
 P_Warning_Mesg         OUT NOCOPY Varchar2) Is

l_Pgm_Id                   BEN_PGM_F.Pgm_Id%TYPE;
l_Elig_Per_Elctbl_Chc_Id   Ben_Elig_Per_Elctbl_Chc.Elig_Per_Elctbl_Chc_Id%TYPE;
l_Update_Salary_cd         Ben_Pgm_F.Update_Salary_Cd%TYPE;
l_Person_name              Per_All_People_F.Full_name%TYPE;
l_Person_Id                Per_All_People_F.Person_Id%TYPE;
l_Last_Name                Per_All_People_F.Last_name%TYPE;
L_Cnt                      Number;
l_Grade_id                 Per_all_Assignments_F.Grade_Id%TYPE;
l_Dflt_Step_Cd             Ben_Pgm_F.Dflt_Step_Cd%TYPE;
l_Step_id                  Per_Spinal_POint_Steps_F.Step_Id%TYPE;
l_Mass_update_Call         Varchar2(1) := 'N';
l_Last_Per_In_ler_Id       Ben_Per_In_ler.Per_in_ler_Id%TYPE;
l_Lst_Rt_Chg_Dt            Ben_Enrt_Rt.Rt_Strt_Dt%TYPE;
l_Le_Exists                Varchar2(1);

Cursor Person_Dtls is
 Select Full_name, Last_NAME, Person.Person_Id, Asgt.Grade_id, Asgt.Grade_Ladder_Pgm_Id
   from Per_All_Assignments_F       Asgt,
        PER_ASSIGNMENT_STATUS_TYPES Pas,
        Per_All_People_F            Person
  Where Assignment_Id = P_Assignment_Id
    and P_Effective_Date
Between Asgt.Effective_Start_Date
    and Asgt.Effective_End_Date
    and Person.Person_Id = Asgt.Person_Id
    and asgt.assignment_type ='E'
    and asgt.primary_flag ='Y'
    and asgt.ASSIGNMENT_STATUS_TYPE_ID = Pas.ASSIGNMENT_STATUS_TYPE_ID
    and pas.PER_SYSTEM_STATUS = 'ACTIVE_ASSIGN'
    and P_Effective_Date
Between Person.Effective_Start_Date
    and Person.Effective_End_Date;

 Cursor Dflt_Step Is
 Select Dflt_Step_cd, Update_Salary_Cd
   from Ben_Pgm_F
  Where Pgm_id = l_Pgm_Id
    and P_Effective_Date
Between Effective_Start_Date
    and Effective_End_Date;

 Cursor Dflt_grdldr is
 Select Pgm.Pgm_Id
   From Ben_Pgm_F  Pgm,
        Ben_Plip_F Plip,
        Ben_Pl_F   Plan
  where Pgm.Dflt_Pgm_Flag = 'Y'
    and Pgm.Pgm_Typ_Cd = 'GSP'
    and P_effective_date
Between Pgm.Effective_Start_Date
    and Pgm.Effective_End_Date
    and Pgm.Business_Group_id = hr_general.get_Business_group_Id
    and Plan.Mapping_Table_name  = 'PER_GRADES'
    and Plan.Mapping_Table_Pk_id = l_grade_Id
    and P_Effective_Date
Between Plan.Effective_Start_Date
    and Plan.Effective_End_Date
    and Plan.Pl_Id = Plip.Pl_Id
    and Pgm.Pgm_Id = Plip.Pgm_id
    and P_Effective_Date
between Plip.Effective_Start_Date
    and Plip.Effective_End_Date;

 Cursor Step_Dtls Is
 Select Plcmt.Step_id
   From Per_Spinal_POint_Placements_f Plcmt,
        Per_Spinal_point_Steps_F Step
  Where Plcmt.Assignment_id = P_Assignment_Id
    and P_Effective_Date
Between Plcmt.Effective_Start_Date
    and plcmt.Effective_End_Date
    and Step.Step_id = Plcmt.Step_Id
    and P_Effective_Date
Between Step.Effective_Start_Date
    and Step.Effective_End_Date;

 ---

 Cursor csr_le is
 Select max(pil.Per_in_Ler_Id)
   From Ben_Per_in_ler PIL,
        Ben_Ler_F LER
  Where Pil.Ler_Id = LER.Ler_Id
    And Pil.LF_EVT_OCRD_DT = P_Effective_Date
    And ler.typ_Cd = 'GSP'
    And Pil.person_Id = l_person_id
    And Pil.Per_In_Ler_Stat_Cd = 'PROCD';
 ---
 Cursor csr_sal is
 Select Rate.Rt_Strt_Dt Sal_Chg_Dt
   From Ben_Elig_Per_Elctbl_Chc Elct,
        Ben_Enrt_Rt Rate
  Where Elct.DFLT_FLAG = 'Y'
    and Elct.Elctbl_Flag = 'Y'
    and Elct.Per_in_ler_id = l_Last_Per_In_ler_Id
    and Elct.Enrt_Cvg_Strt_Dt is Not NULL
    And Rate.ELIG_PER_ELCTBL_CHC_ID(+) = Elct.ELIG_PER_ELCTBL_CHC_ID;

  Cursor Strtd_Le_Exits is
  Select 'X'
    from Ben_Per_in_ler Pler,
         Ben_Ler_F      Ler
   where Person_id = l_Person_Id
     and Per_In_ler_Stat_Cd = 'STRTD'
     and Pler.Ler_Id = Ler.ler_ID
     and Ler.Typ_Cd  = 'GSP'
     and P_Effective_Date
 Between Ler.Effective_Start_Date
     and Ler.Effective_End_Date;

Begin

g_debug := hr_utility.debug_enabled;

/* Initialize the Process Log */
Savepoint Assgt_Enrolment;

if g_debug then
   hr_utility.set_location(' Inside Asgt Call ', 10);
End If;

Open  Person_Dtls;
Fetch Person_Dtls Into l_Person_Name, l_Last_Name,l_Person_Id, l_Grade_id, l_Pgm_Id;
Close Person_Dtls;

If l_Grade_id is Null then
   Return;
End If;

If L_Pgm_Id is Null then
    Open Dflt_grdldr;
   Fetch Dflt_Grdldr into L_Pgm_Id;
   Close Dflt_Grdldr;

  If L_Pgm_Id is NULL Then
     Return;
  End if;
End If;

 Open Dflt_Step;
Fetch Dflt_Step into l_Dflt_Step_Cd, L_Update_Salary_Cd;
Close Dflt_Step;

If l_Dflt_Step_Cd in  ('PQH_GSP_SP','PQH_GSP_GSP','MINSALINCR','MINSTEP','NOSTEP') Then
   Open  Step_Dtls;
   Fetch Step_Dtls Into L_Step_Id;
   Close Step_Dtls;
   If l_Step_Id is NULL Then
      Return;
   End if;
End If;

If pqh_process_batch_log.g_module_cd is NULL then
   Pqh_Gsp_process_Log.Start_log
   (P_Txn_ID            =>  P_Assignment_Id
   ,P_Txn_Name          =>  l_Last_Name
   ,P_Module_Cd         =>  'PQH_GSP_ASSIGN_ENTL');
   l_Mass_Update_Call := 'N';
Else
   l_Mass_Update_Call := 'Y';
End If;

 Open Strtd_Le_Exits;
Fetch Strtd_Le_Exits into l_Le_Exists;
if Strtd_Le_Exits%FOUND then
   /* open Life Event already exists for the person */
   if g_debug then
      hr_utility.set_location(' leaving Asgt Call ', 20);
   End If;
   Close Strtd_Le_Exits;
   If pqh_process_batch_log.g_module_cd = 'PQH_GSP_ASSIGN_ENTL' Then
      fnd_message.set_name('PQH','PQH_GSP_LE_STRT');
      fnd_message.raise_error;
   Else
      Return;
   End If;
End If;
Close Strtd_Le_Exits;


/* Get the Last Enrollment details for Determining the Previous SalaryChange Dt */
If P_DATE_TRACK_MODE = 'CORRECTION' Then

    Open csr_le;
   Fetch csr_le into l_Last_Per_In_ler_Id;
   Close Csr_Le;

   If l_Last_Per_In_ler_Id is Not NULL then
       Open csr_sal;
      Fetch csr_sal into l_Lst_Rt_Chg_Dt;
      Close csr_Sal;
   End If;

End If;

pqh_gsp_Post_Process.Override_Eligibility
(P_Effective_Date          =>  P_Effective_Date
,P_Assignment_id           =>  P_Assignment_Id
,P_Called_From             =>  'A'
,P_Date_track_Mode         =>  P_Date_Track_Mode
,P_Elig_Per_Elctbl_Chc_Id  =>  l_Elig_per_Elctbl_Chc_Id);

if g_debug then
   hr_utility.set_location(' Completed Override Eligibility ', 30);
End If;


If L_Update_Salary_Cd <> 'NO_UPDATE'  and l_Elig_per_Elctbl_Chc_Id is NOT NULL Then
   pqh_gsp_Post_Process.Update_Salary_Info
   (P_Elig_per_Elctbl_Chc_Id  =>  l_Elig_per_Elctbl_Chc_Id
   ,P_Effective_Date	      =>  P_Effective_Date
   ,P_Dt_Mode                 =>  P_DATE_TRACK_MODE
   ,P_Called_From             =>  'A'
   ,P_Prv_Sal_Chg_Dt          =>  l_Lst_Rt_Chg_Dt);
End If;

if g_debug then
   hr_utility.set_location(' Completed Salary Update ', 40);
End If;

/* Log the Entry in Process Log as Complete */

If l_Mass_Update_call = 'N' then
/* Not Called from Mass Update and hence logging the process Completion */

   Pqh_Gsp_process_Log.Log_process_Dtls
   (P_Master_txn_Id             =>  P_Assignment_Id
   ,P_Txn_Id                    =>  P_Assignment_Id
   ,p_module_cd        	        =>  'PQH_GSP_ASSIGN_ENTL'
   ,p_message_type_cd           =>  'C'
   ,p_message_text              =>  NULL
   ,P_Effective_Date            =>  P_Effective_Date);

   PQH_PROCESS_BATCH_LOG.END_LOG;

End If;

P_Warning_Mesg := NULL;

Exception
When Others Then
Rollback to Assgt_Enrolment;
P_Warning_Mesg := 'PQH_GSP_ASGMT_PP_ERR';

if l_Mass_Update_Call = 'N' Then
   Pqh_Gsp_process_Log.Log_process_Dtls
   (P_Master_txn_Id             =>  P_Assignment_Id
   ,P_Txn_Id                    =>  P_Assignment_Id
   ,p_module_cd                 =>  'PQH_GSP_ASSIGN_ENTL'
   ,p_message_type_cd           =>  'E'
   ,p_message_text              =>  Nvl(fnd_Message.Get,sqlerrm)
   ,P_Effective_Date            =>  P_Effective_Date);

   PQH_PROCESS_BATCH_LOG.END_LOG;

Else

   Pqh_Process_Batch_Log.Set_Context_Level
   (P_Txn_id             =>  P_assignment_Id
   ,P_txn_Table_Route_Id =>  NULL
   ,P_Level              =>  2
   ,P_Log_Context        =>  l_person_Name);

   Pqh_Process_Batch_log.Insert_log
   (P_Message_Type_Cd    =>  Hr_general.Decode_Lookup('PQH_GSP_GEN_PROMPTS','ERR')
   ,P_Message_text       =>  Nvl(fnd_message.get,Sqlerrm));

End if;

End Call_PP_From_Assignments;

/**************************************************************************/
/************************** Call_PP_From_Benmngle *************************/
/**************************************************************************/

Procedure Call_PP_From_Benmngle
(P_Effective_Date		IN  Date,
 P_Elig_per_Elctbl_Chc_Id       IN  Number) Is

 Cursor Pler is
 Select Pler.Per_In_Ler_Id, Pler.Object_Version_Number, Elct.Pgm_Id
   From Ben_Elig_per_Elctbl_Chc Elct,
        Ben_Per_In_Ler          Pler
  Where Elct.Elig_per_Elctbl_Chc_Id  = P_Elig_per_Elctbl_Chc_Id
    and Pler.Per_In_Ler_Id           = Elct.Per_In_Ler_Id;

 Cursor Pgm_Dtl(P_Pgm_Id In Number) Is
 Select Update_Salary_Cd
   from Ben_Pgm_F
  where Pgm_Id = P_Pgm_Id
    and P_Effective_Date
Between Effective_Start_Date
    and Effective_End_Date;

L_Per_In_Ler_id            Ben_Per_In_ler.Per_In_Ler_Id%TYPE;
L_Pil_Ovn                  Ben_Per_In_ler.Object_Version_Number%TYPE;
l_Pgm_Id                   Ben_Pgm_F.Pgm_Id%TYPE;
l_Update_Salary_Cd         Ben_Pgm_F.Update_Salary_Cd%TYPE;
l_Assignment_id            Per_All_Assignments_F.Assignment_id%TYPE;

l_PROCD_DT                 DATE;
l_STRTD_DT                 DATE;
l_VOIDD_DT                 Date;

Begin

g_debug := hr_utility.debug_enabled;
pqh_process_batch_log.g_module_cd := 'PQH_GSP_BENMNGLE';

if P_Elig_per_Elctbl_Chc_Id = NULL then
   fnd_message.set_name('PQH','PQH_GSP_DFLT_SLCT_ERR');
   fnd_message.raise_error;
End If;

Savepoint Benmngle_Call;
 Open Pler;
Fetch Pler into L_Per_In_Ler_id, l_Pil_Ovn, l_Pgm_Id;
Close Pler;

Open Pgm_Dtl(l_Pgm_Id);
Fetch Pgm_Dtl into L_UPdate_Salary_Cd;
Close Pgm_Dtl;

if g_debug then
   hr_utility.set_location(' Inside Benmngle call ', 10);
End If;

/* Update the Assignment Record with the new grade , Step */

pqh_gsp_Post_Process.Update_Assgmt_Info
(P_Elig_Per_Elctbl_Chc_Id   => P_Elig_per_Elctbl_Chc_Id
,P_Effective_Date	    => P_Effective_Date);

if g_debug then
   hr_utility.set_location(' Completed Asgt Update ', 30);
End If;

/* Update the Salary */

If Nvl(l_Update_Salary_Cd,'NO_UPDATE') <> 'NO_UPDATE' Then
   pqh_gsp_Post_Process.Update_Salary_Info
   (P_Elig_per_Elctbl_Chc_Id	=>  P_Elig_per_Elctbl_Chc_Id
   ,P_Effective_Date	        =>  P_Effective_Date);
End If;

if g_debug then
   hr_utility.set_location(' Completed Sal Update ', 40);
End If;

Ben_Person_Life_Event_api.UPDATE_PERSON_LIFE_EVENT
(P_PER_IN_LER_ID                   => l_PER_IN_LER_ID
,P_PER_IN_LER_STAT_CD              => 'PROCD'
,P_PROCD_DT                        =>  L_PROCD_DT
,P_STRTD_DT                        =>  L_STRTD_DT
,P_VOIDD_DT                        =>  L_VOIDD_DT
,P_OBJECT_VERSION_NUMBER           =>  L_Pil_Ovn
,P_EFFECTIVE_DATE                  =>  P_Effective_Date);

if g_debug then
   hr_utility.set_location(' Completed PIL Update ', 20);
End if;

pqh_process_batch_log.g_module_cd := NULL;
Exception
When Others then
Rollback to Benmngle_Call;
pqh_process_batch_log.g_module_cd := NULL;

l_Assignment_Id := pqh_gsp_default.get_asg_for_pil(L_PER_IN_LER_ID, P_Effective_Date);

Pqh_Gsp_process_Log.Log_process_Dtls
(P_Master_txn_Id    => l_Assignment_id
,P_Txn_Id           => l_Assignment_id
,p_module_cd        => 'PQH_GSP_DFLT_ENRL'
,p_message_type_cd  => 'E'
,p_message_text     => Nvl(fnd_Message.Get,sqlerrm)
,P_Effective_Date   => P_Effective_Date);

End;

/**************************************************************************/
/***************************Call_PP_For_Batch_Enrl*************************/
/**************************************************************************/

Procedure Call_PP_For_Batch_Enrl
(P_Errbuf                       OUT NOCOPY Varchar2
,P_Retcode                      OUT NOCOPY Number
,P_Effective_Date		        IN  Varchar2
,P_Grade_Ladder_Id              IN  Number Default NULL
,P_Person_Id                    IN  Number Default NULL
,p_grade_id                     IN Number Default Null
,p_person_selection_rule_id     IN Number Default Null) Is

l_Concurrent_Req_Id        Number(18);
L_Error                    Varchar2(1) := 'N';
L_Effective_Date           Date;
l_outputs       ff_exec.outputs_t;

 Cursor Asgt_Dtls
 Is
 Select Paa.Assignment_Id, Paa.Grade_ladder_Pgm_Id, Paa.Grade_Id, Paa.Person_Id,
        paa.soft_coding_keyflex_id,paa.people_group_id,paa.special_ceiling_step_id,paa.object_version_number
   from Per_All_Assignments_F Paa
  Where L_Effective_Date Between paa.Effective_Start_Date and Paa.Effective_End_Date
    and Paa.Business_group_id = hr_General.get_Business_group_id
    and Paa.Person_id = Nvl(P_Person_Id, Paa.Person_Id)
    and paa.assignment_type ='E'
    and paa.primary_flag ='Y'
    and Paa.Grade_ladder_Pgm_Id is null
    and Paa.grade_id in
    (select pl.mapping_table_pk_id
from ben_plip_f plip,ben_pl_f pl
where plip.pgm_id = p_grade_ladder_id
and plip.pl_id = pl.pl_id
and L_Effective_Date between
plip.effective_start_date and plip.effective_end_date
and l_effective_date between
pl.effective_start_date and pl.effective_end_date
and pl.mapping_table_pk_id = nvl(p_grade_id,pl.mapping_table_pk_id));


 L_Cnt  Number := 0;
 L_Error_Exists Varchar2(1) := 'N';
 l_conc_status         boolean;

l_Assignment_Ovn               Per_All_Assignments_F.Object_Version_Number%TYPE;
l_SPECIAL_CEILING_STEP_ID      Per_All_Assignments_F.SPECIAL_CEILING_STEP_ID%TYPE;
L_People_Group_Id	           Per_All_Assignments_F.People_Group_Id%TYPE;
l_Soft_Coding_Keyflex_Id       Per_All_Assignments_F.Soft_Coding_Keyflex_Id%TYPE;
L_Pgm_Id                       ben_pgm_f.pgm_id%TYPE;
L_DATE_TRACK_MODE              Varchar2(25);
l_assignment_id                Per_All_Assignments_F.assignment_id%TYPE;
l_group_name                   Varchar2(250);
l_Asg_effective_start_date     Per_All_Assignments_F.Effective_Start_Date%TYPE;
l_Asg_effective_end_date       Per_All_Assignments_F.Effective_End_Date%TYPE;
l_org_now_no_manager_warning   Boolean;
l_other_manager_warning        Boolean;
l_spp_delete_warning           Boolean;
l_entries_changed_warning      Varchar2(250);
l_tax_district_changed_warning Boolean;
l_concatenated_segments        Varchar2(250);
l_person_rule_checked          Boolean := true;
l_business_group_id            Number;

Begin

g_debug := hr_utility.debug_enabled;

L_Effective_Date := Fnd_Date.CANONICAL_TO_DATE(P_Effective_Date);
l_business_group_id := hr_General.get_Business_group_id;

hr_utility.set_location(' Entering  ', 10);
hr_utility.set_location(' L_Effective_Date'||L_Effective_Date, 20);


L_Concurrent_Req_Id := fnd_global.conc_request_id;

Pqh_Gsp_process_Log.Start_log
(P_Txn_ID            =>  l_Concurrent_Req_Id
,P_Txn_Name          =>  Hr_general.Decode_Lookup('PQH_GSP_GEN_PROMPTS','BENRL') || l_Concurrent_Req_Id
,P_Module_Cd         =>  'PQH_GSP_BATCH_ENRL');

  For Asgt_Rec in Asgt_Dtls
  Loop
  Begin

     Savepoint Batch_Enroll;


     If Asgt_Rec.Grade_Id is NULL Then
        fnd_message.set_name('PQH','PQH_GSP_GRD_NOTLNKD_ASSGT');
        fnd_message.raise_error;
     End If;


      Select Count(*) into L_Cnt
        from Ben_Per_in_ler Pler,
             Ben_Ler_F      Ler
       where Person_id = Asgt_Rec.Person_Id
         and Per_In_ler_Stat_Cd = 'STRTD'
         and Pler.Ler_Id = Ler.ler_ID
         and Ler.Typ_Cd  = 'GSP'
         and L_Effective_Date
     Between Ler.Effective_Start_Date
         and Ler.Effective_End_Date;

      If l_Cnt > 0 then
        if g_debug then
           hr_utility.set_location(' leaving Asgt Call ', 20);
        End If;
      Else

    l_assignment_id           := Asgt_Rec.assignment_id;
    L_Soft_Coding_Keyflex_Id  := Asgt_Rec.Soft_Coding_Keyflex_Id;
L_People_Group_Id         := Asgt_Rec.People_Group_Id;
L_special_ceiling_step_id := Asgt_Rec.special_ceiling_step_id;
L_Assignment_Ovn          := Asgt_Rec.Object_version_Number;

if p_person_selection_rule_id is not null then
    l_outputs:=benutils.formula(
          p_formula_id        => p_person_selection_rule_id
         ,p_effective_date    => l_effective_date
         ,p_business_group_id => l_business_group_id
         ,p_assignment_id     => l_assignment_id);
      --
      IF l_outputs(l_outputs.FIRST).VALUE = 'Y' THEN
        --
        l_person_rule_checked := true;
      --
      ELSIF l_outputs(l_outputs.FIRST).VALUE = 'N' THEN
        --
        l_person_rule_checked := false;
      --
      END IF;
End if;
if l_person_rule_checked then

    L_DATE_TRACK_MODE  := pqh_gsp_post_process.DT_Mode
                        (P_EFFECTIVE_DATE        =>  L_Effective_Date
                        ,P_BASE_TABLE_NAME       =>  'PER_ALL_ASSIGNMENTS_F'
                        ,P_BASE_KEY_COLUMN       =>  'ASSIGNMENT_ID'
                        ,P_BASE_KEY_VALUE        =>  L_Assignment_id);
hr_utility.set_location('L_date_track_mode:'||L_DATE_TRACK_MODE,90);
IF l_date_track_mode = 'CORRECTION' OR l_date_track_mode = 'UPDATE' THEN
   Hr_Assignment_Api.Update_Emp_Asg_Criteria
  (p_effective_date               =>  L_Effective_Date
  ,p_datetrack_update_mode        =>  L_Date_Track_Mode
  ,p_assignment_id                =>  L_Assignment_id
  ,p_grade_ladder_pgm_id          =>  P_Grade_Ladder_Id
  ,p_object_version_number        =>  L_Assignment_Ovn
  ,p_special_ceiling_step_id      =>  L_special_ceiling_step_id
  ,p_people_group_id              =>  L_People_Group_Id
  ,p_soft_coding_keyflex_id       =>  L_Soft_Coding_Keyflex_Id
  ,p_group_name                   =>  L_group_name
  ,p_effective_start_date         =>  L_Asg_effective_start_date
  ,p_effective_end_date           =>  L_Asg_effective_end_date
  ,p_org_now_no_manager_warning   =>  L_org_now_no_manager_warning
  ,p_other_manager_warning        =>  L_other_manager_warning
  ,p_spp_delete_warning           =>  L_spp_delete_warning
  ,p_entries_changed_warning      =>  L_entries_changed_warning
  ,p_tax_district_changed_warning =>  L_tax_district_changed_warning
  ,p_concatenated_segments        =>  L_concatenated_segments);

       Pqh_Gsp_process_Log.Log_process_Dtls
       (P_Master_txn_Id             =>  L_Concurrent_Req_Id
       ,P_TXN_ID                    =>  Asgt_Rec.Assignment_Id
       ,p_module_cd        	    =>  'PQH_GSP_BATCH_ENRL'
       ,p_message_type_cd           =>  'C'
       ,p_message_text              =>  NULL
       ,P_Effective_Date            =>  L_Effective_Date);
Else

           fnd_message.set_name('PQH','PQH_FUTURE_DATES_ASSGT_EXIST');
       Pqh_Gsp_process_Log.Log_process_Dtls
       (P_Master_txn_Id             =>  L_Concurrent_Req_Id
       ,P_TXN_ID                    =>  Asgt_Rec.Assignment_Id
       ,p_module_cd        	        =>  'PQH_GSP_BATCH_ENRL'
       ,p_message_type_cd           =>  'E'
       ,p_message_text              =>  fnd_message.get
       ,P_Effective_Date            =>  L_Effective_Date);
End if;

End if;


     End If;

  Exception
  When Others Then
     Rollback to Batch_Enroll;
     l_Error_Exists := 'Y';
     Pqh_Gsp_process_Log.Log_process_Dtls
     (P_Master_txn_Id             =>  L_Concurrent_Req_Id
     ,P_Txn_ID                    =>  Asgt_Rec.Assignment_Id
     ,p_module_cd        	  =>  'PQH_GSP_BATCH_ENRL'
     ,p_message_type_cd           =>  'E'
     ,p_message_text              =>  Nvl(fnd_Message.get,sqlerrm)
     ,P_Effective_Date            =>  L_Effective_Date);
hr_utility.set_location('Erro:'|| l_Error_Exists,120);
  End;
  End Loop;

If L_Error_Exists = 'N' Then
   fnd_message.set_name('PQH','PQH_GSP_LOG_SUC');
   fnd_Message.Set_Token('MODULE',Hr_general.Decode_lookup('PQH_PROCESS_LOG_TREE','PQH_GSP_BATCH_ENRL'));
   fnd_file.put_line(fnd_file.log,Fnd_Message.get);
Else
   fnd_message.set_name('PQH','PQH_GSP_LOG_ERR');
   fnd_Message.Set_Token('MODULE',Hr_general.Decode_lookup('PQH_PROCESS_LOG_TREE','PQH_GSP_BATCH_ENRL'));
   fnd_file.put_line(fnd_file.log,Fnd_Message.get);
   l_conc_status := fnd_concurrent.set_completion_status(status => 'ERROR'
                                                         ,message=>SQLERRM);
    hr_utility.set_location('Some Error:'|| SQLERRM,120);
End If;
hr_utility.set_location(' Leaving  ', 10);
PQH_PROCESS_BATCH_LOG.END_LOG;
Commit;
End Call_PP_For_Batch_Enrl;



/**************************************************************************/
/************************** Override Eligibility  *************************/
/**************************************************************************/

Procedure Override_Eligibility
(P_Effective_Date          IN Date
,P_Assignment_id           IN Number
,P_Called_From             In Varchar2
,P_Date_Track_Mode         IN Varchar2
,P_Elig_Per_Elctbl_Chc_Id  OUT NOCOPY Number) is

 Cursor Life_Event_type(P_Business_Group_Id IN Number) is
 Select Ler_id
   from Ben_Ler_F
  Where Typ_Cd = 'GSP'
    and LF_EVT_OPER_CD = 'PROG' --ggnanagu  4032221
    and P_Effective_Date
Between Effective_Start_Date
    and Effective_End_Date
    and Business_Group_id = P_Business_Group_id;

 Cursor Person_Info Is
 Select Asgt.Person_Id, Asgt.Business_Group_id,
        Asgt.Grade_Id , Asgt.pay_basis_id, Asgt.GRADE_LADDER_PGM_ID, Asgt.Effective_Start_Date
   from Per_All_Assignments_f Asgt
  Where Assignment_Id = P_Assignment_Id
    and P_Effective_Date
Between Asgt.Effective_Start_Date
    and Asgt.Effective_End_Date;

Cursor Ben_Grd_Dtls(P_Pgm_Id In Number, P_Grd_Id In Number) Is
 Select Pl.Pl_Id, plip.Plip_Id, Pgm.DFLT_STEP_CD,
        Pgm.UPDATE_SALARY_CD  , DFLT_ELEMENT_TYPE_ID
   from Ben_Pgm_F  Pgm,
        Ben_Pl_F   Pl,
        Ben_Plip_f Plip
  Where Pgm.Pgm_Id  = P_Pgm_Id
    and P_Effective_Date
Between Pgm.Effective_Start_Date
    and Pgm.Effective_End_Date
    and Pl.Mapping_table_Name  = 'PER_GRADES'
    and Pl.Mapping_Table_Pk_Id = P_Grd_Id
    and P_Effective_Date
Between Pl.Effective_Start_Date
    and Pl.Effective_End_Date
    and Plip.Pgm_Id = Pgm.Pgm_id
    and Plip.Pl_id  = Pl.Pl_Id
    and P_Effective_Date
Between Plip.Effective_Start_Date
    and Plip.Effective_End_Date;

 Cursor Step_Dtls Is
 Select Plcmt.Step_id, Step.Spinal_point_id, Plcmt.Effective_Start_Date
   From Per_Spinal_POint_Placements_f Plcmt,
        Per_Spinal_point_Steps_F Step
  Where Plcmt.Assignment_id = P_Assignment_Id
    and P_Effective_Date
Between Plcmt.Effective_Start_Date
    and plcmt.Effective_End_Date
    and Step.Step_id = Plcmt.Step_Id
    and P_Effective_Date
Between Step.Effective_Start_Date
    and Step.Effective_End_Date;

 Cursor Ben_Dtls(P_Pl_id In Number,
                 P_Point_id In Number) Is
 Select Oipl.Oipl_Id, Opt.Opt_Id
   From Ben_Opt_F  Opt,
        Ben_Oipl_F Oipl
  Where Opt.Mapping_table_name  = 'PER_SPINAL_POINTS'
    and Opt.mapping_table_Pk_Id = P_Point_id
    and P_Effective_Date
Between Opt.Effective_Start_Date
    and Opt.Effective_End_Date
    and Oipl.Pl_Id  = P_Pl_Id
    and Oipl.Opt_id = Opt.Opt_id
    and P_Effective_Date
Between Oipl.Effective_Start_Date
    and Oipl.Effective_End_Date;

 Cursor PlanType is
 Select Pl_typ_Id
   From Ben_Pl_Typ_F
  Where Opt_typ_Cd = 'GSP'
    and P_Effective_Date
Between Effective_Start_Date
    and Effective_End_Date;

 CURSOR Elmt_Asgmnt_link (P_Element_Type_Id IN NUMBER) IS
 select 'Y'
   from pay_element_types_f   pet
       ,pay_element_links_f   pel
       ,pay_element_entries_f pee
  where Pet.Element_type_id  = P_Element_type_Id
    and p_Effective_date
Between pet.effective_start_date
    and pet.effective_end_date
    and Pel.Element_type_Id  = Pet.Element_type_Id
    and p_Effective_date
Between pel.effective_start_date
    and pel.effective_end_date
    and pee.element_link_id = pel.element_link_id
    and pee.assignment_id   = p_assignment_id
    and p_Effective_date
between pee.effective_start_date
    and pee.effective_end_date;

 Cursor Pl_Bas_rt(l_Pl_Id IN Number) Is
 Select ACTY_BASE_RT_ID, Rt_Typ_cd, Entr_Ann_Val_Flag
   From Ben_Acty_base_Rt_f
  where Pl_id   = l_Pl_Id
    and P_effective_Date
Between Effective_Start_Date
    and Effective_End_Date;

 Cursor Opt_Bas_Rt(l_Opt_Id IN Number) Is
 Select ACTY_BASE_RT_ID, Rt_Typ_cd, Entr_Ann_Val_Flag
   From Ben_Acty_Base_rt_f
  where Opt_Id = L_Opt_id
    and P_effective_Date
Between Effective_Start_Date
    and Effective_End_Date;

 Cursor Lee_Rsn(P_Pgm_Id IN Number) is
 Select Lrsn.Lee_Rsn_Id
   From Ben_Popl_Enrt_Typ_Cycl_F Cylc,
        Ben_Lee_Rsn_f            Lrsn
  Where Cylc.ENRT_TYP_CYCL_CD = 'L'
    and Cylc.Pgm_Id = P_Pgm_Id
    and P_Effective_Date
Between Cylc.Effective_Start_Date
    and Cylc.Effective_End_Date
    and Lrsn.POPL_ENRT_TYP_CYCL_ID = Cylc.POPL_ENRT_TYP_CYCL_ID
    and P_Effective_Date
Between Lrsn.Effective_Start_Date
    and Lrsn.Effective_End_Date;
-- 6519699
 Cursor Curr_Enrollment (P_Pgm_Id in Number, P_Person_Id in Number, P_Ler_id in Number) is
 Select Pl_Id, Oipl_Id
   from Ben_Elig_per_Elctbl_Chc
  Where Pgm_Id      = P_Pgm_Id
    and Dflt_Flag   = 'Y'
    and Elctbl_Flag = 'Y'
    and Per_In_ler_Id = (Select Max(Per_In_ler_Id)
			 from Ben_per_in_Ler
			 Where Ler_id = P_Ler_Id
			 and Person_Id = P_Person_Id
			 and LF_EVT_OCRD_DT = ( SELECT max(LF_EVT_OCRD_DT) FROM Ben_per_in_Ler
						 where Ler_id = P_Ler_Id
						 and Person_Id = P_Person_Id
			    			 and PER_IN_LER_STAT_CD = 'PROCD'
						 and LF_EVT_OCRD_DT <= p_effective_date)
			 and PER_IN_LER_STAT_CD = 'PROCD'); -- Query changed for Bug 6519699

--bug 4125962
     Cursor csr_max_lf_evt_date (P_Person_Id in Number,p_ler_id in number)
        Is
        select max(LF_EVT_OCRD_DT)
    	   from Ben_per_in_Ler
    	  Where Person_Id = P_Person_Id
          and Ler_id = P_Ler_Id;

        Cursor Csr_prev_assignment(P_Person_Id in Number,p_max_lf_evt_date in date)
        IS
        select assignment_id
        from per_all_assignments_f
        where person_id = p_person_id
        and assignment_type ='E'
        and primary_flag ='Y'
        and p_max_lf_evt_date
    between effective_start_date and effective_end_date;
--bug 4125962 ends

 -- bug 8886934
   cursor csr_max_step_date (p_asgid in number)
   is
   select max(Effective_Start_Date)
   from per_spinal_point_placements_f
   where assignment_id = p_asgid;

   l_sp_max_date date;


 /*
 Cursor Yr_prd (P_Pl_Id  IN Number, P_Bg_Id IN  Number) Is
 SELECT pyp.yr_perd_id,
        pyp.popl_yr_perd_id,
        yp.start_date,
        yp.end_date
   FROM ben_popl_yr_perd pyp,
        ben_yr_perd yp
  WHERE pyp.pl_id = P_Pl_Id
    AND pyp.yr_perd_id = yp.yr_perd_id
    AND pyp.business_group_id = P_Bg_Id
    AND P_Effective_Date
BETWEEN yp.start_date AND yp.end_date
    AND yp.business_group_id = P_Bg_Id;  */

  Cursor Yr_Prd is
  Select Yr_Perd_id
    From Ben_Yr_Perd
   Where P_Effective_Date
 Between Start_Date and End_Date;

 Cursor Dflt_GrdLdr is
 Select Pgm_Id
   From Ben_PGM_F
  Where DFLT_PGM_FLAG = 'Y'
    and Pgm_Typ_Cd = 'GSP'
    and P_Effective_Date
Between Effective_Start_Date
    and Effective_End_Date
    and Business_Group_id = Hr_general.get_business_group_id;

L_person_Id                   Per_All_People_F.Person_Id%TYPE;
l_Ler_id                      Ben_ler_F.Ler_Id%TYPE;
L_PTNL_LER_FOR_PER_ID         Ben_Ptnl_Ler_For_Per.PTNL_LER_FOR_PER_ID%TYPE;
l_Ptnl_Ovn                    Ben_Ptnl_Ler_For_Per.Object_Version_Number%TYPE;
l_PER_IN_LER_ID               Ben_Per_In_Ler.Per_In_Ler_Id%TYPE;
L_Pil_Ovn                     Ben_Per_In_Ler.Object_version_Number%TYPE;
L_BG_Id                       Per_All_Assignments_F.Business_Group_id%TYPE;
l_prev_assgt_id               Per_All_Assignments_F.assignment_id%TYPE;
l_Grade_Id                    Per_Grades.Grade_Id%TYPE;
l_Pgm_Id                      Ben_Pgm_F.Pgm_Id%TYPE;
l_Step_Id                     Per_Spinal_Point_Steps_f.Step_Id%TYPE;
l_Point_id                    Per_Spinal_POints.Spinal_Point_Id%TYPE;
l_PROCD_DT                    DATE;
l_STRTD_DT                    DATE;
l_VOIDD_DT                    Date;
l_Step_Exists                 Varchar2(1) := 'N';
L_Pl_id                       Ben_Pl_F.Pl_Id%TYPE;
L_plip_Id                     Ben_PLip_F.Plip_Id%TYPE;
L_Oipl_Id                     Ben_Oipl_F.Oipl_Id%TYPE;
L_Elig_Per_Elctbl_Chc_Id      Ben_Elig_Per_Elctbl_Chc.Elig_Per_Elctbl_Chc_Id%TYPE;
L_Oipl_Elig_Per_Elctbl_Chc_Id Ben_Elig_Per_Elctbl_Chc.Elig_Per_Elctbl_Chc_Id%TYPE;
l_Pl_Typ_Id                   Ben_Pl_Typ_F.Pl_Typ_Id%TYPE;
l_Elctbl_Ovn                  Ben_Elig_Per_Elctbl_Chc.Object_version_Number%TYPE;
l_oipl_Elctbl_Ovn             Ben_Elig_Per_Elctbl_Chc.Object_version_Number%TYPE;
l_Prog_style                  Ben_Pgm_F.Enrt_Cd%TYPE;
L_Prog_opt                    Ben_Pgm_F.DFLT_STEP_CD%TYPE;
L_Elctbl_Flag                 Varchar2(1) := 'N';
L_Update_Salary_Cd            Ben_Pgm_F.Update_Salary_Cd%TYPE;
L_pay_basis_id                per_pay_bases.pay_basis_id%TYPE;
l_Dflt_Element_typ_Id         Ben_Pgm_F.DFLT_ELEMENT_TYPE_ID%TYPE;
L_Enrt_Rt_Id                  Ben_Enrt_Rt.Enrt_Rt_Id%TYPE;
l_Cur_Sal                     Ben_Enrt_Rt.Val%TYPE;
l_Rt_Typ_Cd                   Ben_Enrt_Rt.Rt_Typ_Cd%TYPE;
L_Rt_Elig_Per_Elctbl_Chc_Id   Ben_Elig_Per_Elctbl_Chc.Elig_Per_Elctbl_Chc_Id%TYPE;
L_Acty_Base_rt_Id             Ben_Acty_Base_Rt.Acty_Base_rt_Id%TYPE;
l_Enrt_Rt_Ovn                 Ben_Elig_Per_Elctbl_Chc.Object_version_Number%TYPE;
l_Opt_id                      Ben_Opt_F.Opt_Id%TYPE;
l_Entr_Ann_Val_Flag           Ben_Acty_Base_rt_F.Entr_Ann_Val_Flag%TYPE;
L_Lee_Rsn_Id                  Ben_Lee_Rsn_f.Lee_Rsn_Id%TYPE;
l_yr_perd_id                  ben_popl_yr_perd.yr_perd_id%TYPE;
L_popl_yr_perd_id             ben_popl_yr_perd.popl_yr_perd_id%TYPE;
l_start_date                  ben_yr_perd.start_date%TYPE;
l_end_date                    ben_yr_perd.end_date%TYPE;
l_Element_Link_Id             Pay_Element_Links_f.Element_Link_Id%TYPE;
l_Curr_Pl_Id                  Ben_Pl_F.Pl_Id%TYPE;
l_Curr_Oipl_Id                Ben_Oipl_F.Oipl_Id%TYPE;
l_New_Enrlmt_Dt               Date;
l_max_lf_evt_date               Date;

Begin

g_debug := hr_utility.debug_enabled;

Open  Person_Info;
Fetch Person_Info Into L_Person_Id, L_BG_Id , L_Grade_Id, L_pay_basis_id, l_Pgm_Id, l_New_Enrlmt_Dt;
Close Person_Info;

if g_debug then
   hr_utility.set_location(' Inside Override Eligibility ', 10);
End if;

If L_Grade_Id is NULL then
   /* Grade Not defined for the assignment
   fnd_message.set_name('PQH','PQH_GSP_GRDNOTLNKD_ASSGT');
   fnd_message.raise_error;
   -- sgoyal commented out so that assgt for which no grade is there don't report this warning always
   */
   P_Elig_Per_Elctbl_Chc_Id := NULL;
   return;
End If;

If l_Pgm_Id is NULL then
   Open  Dflt_grdLdr;
   Fetch Dflt_GrdLdr into l_pgm_Id;
   Close Dflt_Grdldr;
End If;

If l_Pgm_id is NULL Then
   P_Elig_Per_Elctbl_Chc_Id := NULL;
   Return;
End If;

l_Curr_Pl_Id   := NULL;
l_Curr_Oipl_Id := NULL;

Open  Life_Event_Type(L_BG_Id);
Fetch Life_Event_Type into l_Ler_Id;
Close Life_Event_Type;

 Open Curr_Enrollment(L_Pgm_Id, l_Person_Id, l_ler_id);
Fetch Curr_Enrollment into l_Curr_Pl_Id, l_Curr_Oipl_Id;
Close Curr_Enrollment;

----4125962 Begins

OPEN csr_max_lf_evt_date(l_Person_Id,l_Ler_id);
Fetch csr_max_lf_evt_date into l_max_lf_evt_date;
Close csr_max_lf_evt_date;

 Open Csr_prev_assignment(l_Person_Id,l_max_lf_evt_date);
Fetch Csr_prev_assignment into l_prev_assgt_id;
Close Csr_prev_assignment;

-- Ends

--8886934
Open csr_max_step_date (P_Assignment_id );
Fetch csr_max_step_date into l_sp_max_date;
Close csr_max_step_date;
--8886934

/* sgoyal
if grade ladder is null for assignment, we should check default grade ladder
if def GL is not set, we should return here
*/

/*
If l_Pgm_Id is NULL and P_Called_From  = 'A'  then
    Grade Ladder Not Assigned to the Assignment
   fnd_message.set_name('PQH','PQH_GSP_NO_GRDLDR');
   fnd_message.raise_error;
End If;
*/



if g_debug then
   hr_utility.set_location(' Pgm_Id : ' || l_Pgm_Id, 20);
   hr_utility.set_location(' Grade Id : ' || L_Grade_Id, 30);
End if;

Open  Ben_Grd_Dtls(l_Pgm_Id, L_Grade_Id);
Fetch Ben_Grd_Dtls into L_Pl_id, l_plip_Id  , l_Prog_style, L_Update_Salary_Cd, l_Dflt_Element_typ_Id;
Close Ben_Grd_Dtls;

If l_Pl_Id Is Null Then
   /* Plan is not not linked to the corresponding Grade */
   fnd_message.set_name('PQH','PQH_GSP_PLN_NOTLNKD_TO_GRD');
   fnd_message.raise_error;
End If;

If l_Prog_style = 'PQH_GSP_NP' Then
   P_Elig_Per_Elctbl_Chc_Id := NULL;
   Return;
elsif l_Prog_style is NULL then
   fnd_message.set_name('PQH','PQH_GSP_PRGSTYLE_NOT_SET');
   fnd_message.raise_error;
End If;

If l_Prog_style = 'PQH_GSP_GP' and l_PL_Id = Nvl(L_Curr_Pl_Id, -999) and nvl(l_prev_assgt_id,p_assignment_id) = p_assignment_id  Then --4125962
   if g_debug then
      hr_utility.set_location(' Enrollment Exists 1 .. leaving ' || l_Prog_style, 40);
   End if;
   P_Elig_Per_Elctbl_Chc_Id := NULL;
   Return;
End If;

If L_Update_Salary_Cd = 'SALARY_BASIS' and L_pay_basis_id is NULL Then
   /* Grade Ladder is defined for Salary basis and Pay Basis is not attached to the assignment */
   fnd_message.set_name('PQH','PQH_GSP_SALBSIS_NOT_LNKD');
   fnd_message.raise_error;

ElsIf L_Update_Salary_Cd = 'SALARY_ELEMENT' then

   /* Grade Ladder uses Salary Element, but Default Salary Element type is not defined */
   If l_Dflt_Element_typ_Id is NULL Then
      fnd_message.set_name('PQH','PQH_GSP_DFLT_ELMNT_NOTDFND');
      fnd_message.raise_error;
   End If;

   l_Element_Link_Id := hr_entry_api.get_link
                       (P_Assignment_id
                       ,l_Dflt_Element_typ_Id
                       ,P_Effective_Date);

   If l_Element_Link_Id is NULL Then
      fnd_message.set_name('PQH','PQH_GSP_ELMNT_NOT_LNKD');
      fnd_message.raise_error;
   End If;
End If;


If l_Prog_style in ('PQH_GSP_SP','PQH_GSP_GSP','MINSALINCR','MINSTEP','NOSTEP') Then
   Open  Step_Dtls;
   Fetch Step_Dtls Into L_Step_Id, l_Point_id, l_New_Enrlmt_Dt;
   Close Step_Dtls;
   /* Step not defined for Assignment */
   If l_Step_Id is NULL Then
      fnd_message.set_name('PQH','PQH_GSP_NO_STEP');
      fnd_message.raise_error;
   Else
      Open Ben_Dtls(L_Pl_id,
                    L_Point_Id);
      Fetch Ben_Dtls Into L_Oipl_Id, l_Opt_id;
      Close Ben_Dtls;
      If L_Oipl_Id is NULL then
         /* Oipl not linked to Step */
         fnd_message.set_name('PQH','PQH_GSP_OIPL_NOTLNKD_TO_STEP');
         fnd_message.raise_error;
      End If;
   End If;
   L_Elctbl_Flag := 'N';

   Open  Opt_Bas_rt(l_Opt_Id);
   Fetch Opt_Bas_Rt into l_ACTY_BASE_RT_ID, l_Rt_Typ_cd, l_Entr_Ann_Val_Flag;
   Close Opt_Bas_Rt;
   if g_debug then
      hr_utility.set_location(' l_Pgm_Id ' || l_Pgm_Id, 50);
      hr_utility.set_location(' L_Pl_id ' || L_Pl_id, 60);
      hr_utility.set_location(' l_Oipl_Id ' || l_Oipl_Id, 70);
      hr_utility.set_location(' L_Person_Id ' || L_Person_Id, 80);
   End if;
   If L_PL_Id = Nvl(l_Curr_PL_Id,-999) and l_Oipl_id = Nvl(l_Curr_oipl_Id,-9999) and nvl(l_prev_assgt_id,p_assignment_id) = p_assignment_id  Then --4125962

     --8886934
    hr_utility.set_location(' l_sp_max_date ' || l_sp_max_date, 81);
    hr_utility.set_location(' l_max_lf_evt_date ' || l_max_lf_evt_date, 81);

    if l_sp_max_date= l_max_lf_evt_date then
      if g_debug then
         hr_utility.set_location(' Enrollment Exists 2 .. leaving ' || l_Prog_style, 90);
      End If;
      P_Elig_Per_Elctbl_Chc_Id := NULL;
      Return;
   End If;
  end if;


Else

   L_Elctbl_Flag := 'Y';
   Open  Pl_Bas_rt(l_Pl_Id);
   Fetch Pl_Bas_rt into l_ACTY_BASE_RT_ID, l_Rt_Typ_cd, l_Entr_Ann_Val_Flag;
   Close Pl_Bas_rt;

End If;


If L_New_Enrlmt_Dt is NULL or P_Date_track_Mode <> 'CORRECTION' Then
   l_New_Enrlmt_Dt := P_Effective_Date;
End If;


Open  Plantype;
Fetch Plantype into l_Pl_Typ_Id;
Close Plantype;

Open Lee_Rsn(l_Pgm_Id);
Fetch Lee_Rsn into l_LEE_RSN_ID;
Close Lee_Rsn;

If l_LEE_RSN_ID is NULL Then
   fnd_message.set_name('PQH','PQH_GSP_LIF_RSN_NOT_DFND');
   fnd_message.raise_error;
End If;

/* Create Potential Life Events */
Ben_Ptnl_Ler_For_per_Api.CREATE_PTNL_LER_FOR_PER_PERF
(P_PTNL_LER_FOR_PER_ID          =>   L_PTNL_LER_FOR_PER_ID
,P_LF_EVT_OCRD_DT               =>   l_New_Enrlmt_Dt
,P_PTNL_LER_FOR_PER_STAT_CD     =>   'PROCD'
,P_LER_ID                       =>   l_Ler_Id
,P_PERSON_ID                    =>   L_Person_Id
,P_BUSINESS_GROUP_ID            =>   L_BG_Id
,P_OBJECT_VERSION_NUMBER        =>   l_Ptnl_Ovn
,P_EFFECTIVE_DATE               =>   l_New_Enrlmt_Dt);

if g_debug then
   hr_utility.set_location(' Created Potential Life Event records ', 100);
   hr_utility.set_location(' L_PTNL_LER_FOR_PER_ID : ' || L_PTNL_LER_FOR_PER_ID, 110);
End If;

/* Create Life Event for the Above created Potential Life Event */
Ben_Person_Life_Event_api.CREATE_PERSON_LIFE_EVENT_PERF
(P_PER_IN_LER_ID                =>  l_PER_IN_LER_ID
,P_PER_IN_LER_STAT_CD           =>  'STRTD'
,P_LF_EVT_OCRD_DT               =>  l_New_Enrlmt_Dt
,P_PTNL_LER_FOR_PER_ID          =>  L_PTNL_LER_FOR_PER_ID
,P_PROCD_DT                     =>  L_PROCD_DT
,P_STRTD_DT                     =>  L_STRTD_DT
,P_VOIDD_DT                     =>  L_VOIDD_DT
,P_LER_ID                       =>  L_Ler_Id
,P_PERSON_ID                    =>  L_Person_Id
,P_BUSINESS_GROUP_ID            =>  L_BG_Id
,P_OBJECT_VERSION_NUMBER        =>  L_Pil_Ovn
,P_EFFECTIVE_DATE               =>  l_New_Enrlmt_Dt);

if g_debug then
   hr_utility.set_location(' Created PIL ', 120);
   hr_utility.set_location(' l_PER_IN_LER_ID : ' || l_PER_IN_LER_ID, 130);
End If;

/* Create Electable Choice Records */
/* For Grade */

if g_debug then
   hr_utility.set_location(' Attempting to create Elig_per ', 140);
   hr_utility.set_location(' Business_Group_Id :' || l_Bg_Id, 150);
end if;
-- sgoyal plan year period should be in place now, please give it a try
/*
Open Yr_prd(L_Pl_Id, l_Bg_Id);
Fetch Yr_prd into l_yr_perd_id, L_popl_yr_perd_id, l_start_date, l_end_date;
Close Yr_prd; */

 Open Yr_Prd;
Fetch Yr_Prd into l_Yr_Perd_Id;
Close Yr_Prd;

Ben_Elig_Per_Elc_Chc_Api.CREATE_PERF_ELIG_PER_ELC_CHC
(P_ELIG_PER_ELCTBL_CHC_ID       =>   L_Elig_Per_Elctbl_Chc_Id
,P_ENRT_CVG_STRT_DT_CD          =>   l_New_Enrlmt_Dt
,P_DFLT_FLAG                    =>   'Y'
,P_ELCTBL_FLAG                  =>   L_Elctbl_Flag
,P_PL_ID                        =>   l_Pl_Id
,P_PGM_ID                       =>   l_Pgm_Id
,P_PLIP_ID                      =>   l_plip_Id
,P_PGM_TYP_CD                   =>   'GSP'
,P_PL_TYP_ID                    =>   l_Pl_Typ_Id
,P_PER_IN_LER_ID                =>   l_PER_IN_LER_ID
,P_YR_PERD_ID                   =>   l_yr_perd_id
,P_Enrt_Cvg_Strt_Dt             =>   l_New_Enrlmt_Dt
,P_COMP_LVL_CD                  =>   'PLAN'
,P_LEE_RSN_ID                   =>   L_LEE_RSN_ID
,P_AUTO_ENRT_FLAG               =>   'Y'
,P_BUSINESS_GROUP_ID            =>   l_Bg_Id
,P_ELIG_FLAG                    =>   'N'
,P_OBJECT_VERSION_NUMBER        =>   l_Elctbl_Ovn
,P_EFFECTIVE_DATE               =>   l_New_Enrlmt_Dt);

 L_Rt_Elig_Per_Elctbl_Chc_Id := L_Elig_Per_Elctbl_Chc_Id;

if g_debug then
   hr_utility.set_location(' Created Elig_per ', 160);
   hr_utility.set_location(' L_Elig_Per_Elctbl_Chc_Id : ' || L_Elig_Per_Elctbl_Chc_Id, 170);
End If;

If l_Prog_style in ('PQH_GSP_SP','PQH_GSP_GSP','MINSALINCR','MINSTEP','NOSTEP') Then

   Ben_Elig_Per_Elc_Chc_Api.CREATE_PERF_ELIG_PER_ELC_CHC
   (P_ELIG_PER_ELCTBL_CHC_ID       =>   L_Oipl_Elig_Per_Elctbl_Chc_Id
   ,P_ENRT_CVG_STRT_DT_CD          =>   l_New_Enrlmt_Dt
   ,P_DFLT_FLAG                    =>   'Y'
   ,P_ELCTBL_FLAG                  =>   'Y'
   ,P_PL_ID                        =>   l_Pl_Id
   ,P_PGM_ID                       =>   l_Pgm_Id
   ,P_PLIP_ID                      =>   l_plip_Id
   ,P_OIPL_ID                      =>   l_Oipl_Id
   ,P_PGM_TYP_CD                   =>   'GSP'
   ,P_PL_TYP_ID                    =>   l_Pl_Typ_Id
   ,P_Enrt_Cvg_Strt_Dt             =>   l_New_Enrlmt_Dt
   ,P_YR_PERD_ID                   =>   l_yr_perd_id
   ,P_PER_IN_LER_ID                =>   l_PER_IN_LER_ID
   ,P_COMP_LVL_CD                  =>   'OIPL'
   ,P_LEE_RSN_ID                   =>   L_LEE_RSN_ID
   ,P_AUTO_ENRT_FLAG               =>   'Y'
   ,P_BUSINESS_GROUP_ID            =>   l_Bg_Id
   ,P_ELIG_FLAG                    =>   'N'
   ,P_OBJECT_VERSION_NUMBER        =>   l_Oipl_Elctbl_Ovn
   ,P_EFFECTIVE_DATE               =>   l_New_Enrlmt_Dt);

   L_Rt_Elig_Per_Elctbl_Chc_Id := L_Oipl_Elig_Per_Elctbl_Chc_Id;
End If;
If L_Update_Salary_Cd is NULL Then
   fnd_message.set_name('PQH','PQH_GSP_POSTSTYL_NOT_SET');
   fnd_message.raise_error;
End If;
If P_Called_From <> 'BM' Then
   if g_debug then
      hr_utility.set_location('L_Update_Salary_Cd :' || L_Update_Salary_Cd, 180);
   End If;
   If L_Update_Salary_Cd in ('SALARY_BASIS','SALARY_ELEMENT') Then

      /* Not Batch Mode and Salary Update is Set for the Grade ladder */
      if g_debug then
         hr_utility.set_location(' Determine Rates ', 190);
      End If;

      ben_env_object.init(p_business_group_id  => l_Bg_Id,
                          p_effective_date     => l_New_Enrlmt_Dt,
                          p_thread_id          => 1,
                          p_chunk_size         => 1,
                          p_threads            => 1,
                          p_max_errors         => 1,
                          p_benefit_action_id  => null);

      ben_env_object.setenv(P_LF_EVT_OCRD_DT  => P_Effective_Date);
      ben_env_object.g_global_env_rec.mode_cd := 'G';
      Ben_determine_rates.Main
      (P_EFFECTIVE_DATE               => l_New_Enrlmt_Dt
      ,P_LF_EVT_OCRD_DT               => l_New_Enrlmt_Dt
      ,P_PERSON_ID                    => L_Person_Id
      ,P_PER_IN_LER_ID                => l_PER_IN_LER_ID
      ,p_elig_per_elctbl_chc_id       => L_Rt_Elig_Per_Elctbl_Chc_Id);
   End If;

   if g_debug then
      hr_utility.set_location(' Determined Rates ', 200);
   End if;

Else

   l_Cur_Sal := Pqh_gsp_utility.Get_Cur_Sal
                (P_Assignment_id   => P_Assignment_id
                ,P_Effective_Date  => P_Effective_date);

   ben_Enrollment_Rate_api.CREATE_PERF_ENROLLMENT_RATE
   (P_ENRT_RT_ID                   =>  L_Enrt_Rt_Id
   ,P_ACTY_TYP_CD                  =>  'GSPSA'
   ,P_TX_TYP_CD                    =>  'NOTAPPLICABLE'
   ,P_DFLT_FLAG                    =>  'Y'
   ,P_VAL                          =>  l_Cur_Sal
   ,P_RT_TYP_CD                    =>  l_Rt_Typ_Cd
   ,P_ELIG_PER_ELCTBL_CHC_ID       =>  L_Rt_Elig_Per_Elctbl_Chc_Id
   ,P_Entr_Ann_Val_Flag            =>  l_Entr_Ann_Val_Flag
   ,P_Business_Group_Id            =>  l_Bg_Id
   ,P_ACTY_BASE_RT_ID              =>  L_Acty_Base_rt_Id
   ,P_OBJECT_VERSION_NUMBER        =>  l_Enrt_Rt_Ovn
   ,P_Effective_Date               =>  P_Effective_Date);

End If;

/* Close the person Life Event as Processed */
   if g_debug then
      hr_utility.set_location(' Close Life Event ', 210);
   End if;

   Ben_Person_Life_Event_api.UPDATE_PERSON_LIFE_EVENT
  (P_PER_IN_LER_ID                   => l_PER_IN_LER_ID
  ,P_PER_IN_LER_STAT_CD              => 'PROCD'
  ,P_PROCD_DT                        =>  L_PROCD_DT
  ,P_STRTD_DT                        =>  L_STRTD_DT
  ,P_VOIDD_DT                        =>  L_VOIDD_DT
  ,P_OBJECT_VERSION_NUMBER           =>  L_Pil_Ovn
  ,P_EFFECTIVE_DATE                  =>  l_New_Enrlmt_Dt);

   if g_debug then
      hr_utility.set_location(' Closed Life Event ', 220);
   End If;

   P_Elig_Per_Elctbl_Chc_Id := L_Rt_Elig_Per_Elctbl_Chc_Id;
Exception
When Others Then
Raise;
End Override_Eligibility;

/**********************************************************************/
/************************** Create Enrollment *************************/
/**********************************************************************/

Procedure Create_Enrollment
(P_Elig_Per_Elctbl_Chc_Id	IN     Number
,P_Person_id			IN     Number
,P_Progression_Style		IN     Varchar2
,P_Effective_Date		IN     Date
,P_PRTT_ENRT_RSLT_ID		IN OUT NOCOPY Number
,P_Status                       OUT    NOCOPY Varchar2) is

Cursor Enrolment is
Select Elctbl.PRTT_ENRT_RSLT_ID, Elctbl.Enrt_Cvg_Strt_Dt , Elctbl.Crntly_Enrd_Flag, Rate.ENRT_RT_ID, Rate.ENRT_BNFT_ID,
       Rate.Val                , Elctbl.Business_Group_Id, Elctbl.Per_in_Ler_Id   , Rate.ANN_VAL
  From Ben_Elig_Per_Elctbl_Chc Elctbl,
       Ben_Enrt_Rt             Rate
 Where Elctbl.ELIG_PER_ELCTBL_CHC_ID = P_ELIG_PER_ELCTBL_CHC_ID
   and Rate.ELIG_PER_ELCTBL_CHC_ID   = Elctbl.ELIG_PER_ELCTBL_CHC_ID;

l_PRTT_ENRT_RSLT_ID    BEN_PRTT_ENRT_RSLT_F.PRTT_ENRT_RSLT_ID%TYPE;
l_Ovn_No	       BEN_PRTT_ENRT_RSLT_F.Object_Version_Number%TYPE;
L_PRTT_ENRT_INTERIM_ID BEN_PRTT_ENRT_RSLT_F.PRTT_ENRT_RSLT_ID%TYPE;
l_PRTT_RT_VAL_ID1      BEN_PRTT_RT_VAL.PRTT_RT_VAL_ID%TYPE;
l_PRTT_RT_VAL_ID_Cmn   BEN_PRTT_RT_VAL.PRTT_RT_VAL_ID%TYPE;
l_Datetrack_Mode       Varchar2(25);
l_suspend_flag         Varchar2(1) := 'N';
l_EFFECTIVE_START_DATE Date;
L_EFFECTIVE_END_DATE   Date;
L_DPNT_ACTN_WARNING    Boolean;
L_BNF_ACTN_WARNING     Boolean;
L_CTFN_ACTN_WARNING    Boolean;
begin
g_debug := hr_utility.debug_enabled;

For Enrl_Rec in Enrolment
Loop

l_PRTT_ENRT_RSLT_ID := Enrl_Rec.PRTT_ENRT_RSLT_ID;

If Enrl_Rec.Crntly_Enrd_Flag = 'N' Then
   l_Datetrack_Mode := hr_api.g_Insert;
Else
   l_Datetrack_Mode := hr_api.g_update;
End If;

Ben_Election_Information.ELECTION_INFORMATION
(P_ELIG_PER_ELCTBL_CHC_ID       => P_Elig_Per_Elctbl_Chc_Id
,P_PRTT_ENRT_RSLT_ID            => l_PRTT_ENRT_RSLT_ID
,P_EFFECTIVE_DATE               => P_Effective_Date
,P_ENRT_MTHD_CD                 => P_Progression_Style
,P_ENRT_BNFT_ID                 => NULL
,P_BNFT_VAL                     => NULL
,P_ENRT_CVG_STRT_DT             => Enrl_Rec.Enrt_Cvg_Strt_Dt
,P_ENRT_RT_ID1                  => Enrl_Rec.Enrt_Rt_Id
,P_PRTT_RT_VAL_ID1              => l_PRTT_RT_VAL_ID1
,P_PRTT_RT_VAL_ID2              => l_PRTT_RT_VAL_ID_Cmn
,P_PRTT_RT_VAL_ID3              => l_PRTT_RT_VAL_ID_Cmn
,P_PRTT_RT_VAL_ID4              => l_PRTT_RT_VAL_ID_Cmn
,P_PRTT_RT_VAL_ID5              => l_PRTT_RT_VAL_ID_Cmn
,P_PRTT_RT_VAL_ID6              => l_PRTT_RT_VAL_ID_Cmn
,P_PRTT_RT_VAL_ID7              => l_PRTT_RT_VAL_ID_Cmn
,P_PRTT_RT_VAL_ID8              => l_PRTT_RT_VAL_ID_Cmn
,P_PRTT_RT_VAL_ID9              => l_PRTT_RT_VAL_ID_Cmn
,P_PRTT_RT_VAL_ID10             => l_PRTT_RT_VAL_ID_Cmn
,P_RT_VAL1                      => Enrl_Rec.Val
,P_ANN_RT_VAL1                  => Enrl_Rec.ANN_VAL
,P_DATETRACK_MODE               => l_Datetrack_Mode
,P_SUSPEND_FLAG                 => l_suspend_flag
,P_EFFECTIVE_START_DATE         => l_EFFECTIVE_START_DATE
,P_EFFECTIVE_END_DATE           => L_EFFECTIVE_END_DATE
,P_OBJECT_VERSION_NUMBER        => l_OVN_No
,P_PRTT_ENRT_INTERIM_ID         => L_PRTT_ENRT_INTERIM_ID
,P_BUSINESS_GROUP_ID            => Enrl_Rec.Business_group_Id
,P_DPNT_ACTN_WARNING            => L_DPNT_ACTN_WARNING
,P_BNF_ACTN_WARNING             => L_BNF_ACTN_WARNING
,P_CTFN_ACTN_WARNING            => L_CTFN_ACTN_WARNING);

Ben_Proc_Common_Enrt_Rslt.PROCESS_POST_RESULTS
(P_PERSON_ID                    => P_Person_Id
,P_ENRT_MTHD_CD                 => P_Progression_Style
,P_EFFECTIVE_DATE               => P_Effective_Date
,P_BUSINESS_GROUP_ID            => Enrl_Rec.Business_Group_Id
,P_PER_IN_LER_ID                => Enrl_Rec.Per_In_Ler_Id);

End Loop;
End Create_Enrollment;

--
-- Procedure to end date prev salary element entry when grade ladder change.
--
Procedure end_prev_gsp_payment(
 p_assignment_id                IN      Number
,p_business_group_id            IN      NUMBER
,P_Effective_Date               IN      Date
,P_Elig_per_Elctbl_Chc_Id       IN      Number
,p_current_rate_change_dt       IN      Date) is

--
l_curr_per_in_ler_id        ben_per_in_ler.per_in_ler_id%type;
l_last_per_in_ler_id        ben_per_in_ler.per_in_ler_id%type;
l_person_id                 ben_per_in_ler.person_id%type;
l_prev_sal_change_dt        ben_enrt_rt.rt_strt_dt%type;
l_max_rt_change_dt          ben_enrt_rt.rt_strt_dt%type;
l_prev_grade_ladder_id      ben_elig_per_elctbl_chc.pgm_id%type;
l_prev_sal                  ben_enrt_rt.val%type;
L_Update_Salary_Cd          Ben_Pgm_F.Update_Salary_Cd%TYPE;
L_DFLT_INPUT_VALUE_ID       Ben_Pgm_F.DFLT_INPUT_VALUE_ID%TYPE;
L_DFLT_ELEMENT_TYPE_ID      Ben_Pgm_F.DFLT_ELEMENT_TYPE_ID%TYPE;
l_DFLT_STEP_CD              Ben_Pgm_F.DFLT_STEP_CD%TYPE;
L_Element_Entry_ID          pay_element_entries_f.Element_Entry_Id%TYPE;
L_Ele_Ovn                   pay_element_entries_f.Object_Version_Number%TYPE;
l_Del_proposal_Id           Per_Pay_proposals.Pay_proposal_Id%TYPE;
l_Del_Proposal_Ovn          per_pay_Proposals.Object_version_Number%TYPE;
l_proposal_date_to          per_pay_Proposals.date_to%type;       -- bug 6856664

 l_del_warn                  boolean;
 L_DATE_TRACK_MODE           Varchar2(25);
 l_inv_next_sal_date_warning boolean;
 l_proposed_salary_warning   boolean;
 l_approved_warning          boolean;
 l_payroll_warning           boolean;
--
Cursor Pgm_Dtl(P_Pgm_Id In Number,P_effective_Date in date) is
 Select Update_Salary_Cd, DFLT_INPUT_VALUE_ID, DFLT_ELEMENT_TYPE_ID, DFLT_STEP_CD
   From ben_Pgm_F
  Where Pgm_id = P_Pgm_Id
    and P_effective_Date
Between Effective_Start_Date
    and Effective_End_Date;

--
 CURSOR Elmt_Entry (p_assignment_id IN NUMBER, P_Business_group_Id IN Number, p_Effective_Date IN Date) IS
 select pee.Element_Entry_Id, pee.Object_version_Number
   from pay_element_types_f   pet
       ,pay_element_links_f   pel
       ,pay_element_entries_f pee
  where Pet.Element_type_id  = L_DFLT_ELEMENT_TYPE_ID
    and p_Effective_date
Between pet.effective_start_date
    and pet.effective_end_date
    and Pel.Element_type_Id  = Pet.Element_type_Id
    and p_Effective_date
Between pel.effective_start_date
    and pel.effective_end_date
    and pee.element_link_id = pel.element_link_id
    and pee.assignment_id   = p_assignment_id
    and p_Effective_date
between pee.effective_start_date
    and pee.effective_end_date;
--
-- Get current Per_in_ler
--
Cursor csr_curr_le is
 Select pil.Per_in_Ler_Id, pil.person_id
   From Ben_Per_in_ler PIL, Ben_Elig_Per_Elctbl_Chc Enrt
   Where Enrt.Elig_per_Elctbl_Chc_id = P_Elig_per_Elctbl_Chc_Id
     And Enrt.Per_In_Ler_id = Pil.Per_In_Ler_id;
     --And Pil.LF_EVT_OCRD_DT = P_Effective_Date;
    -- And Pil.Per_In_Ler_Stat_Cd = 'PROCD';
 --
 -- Get prev per_in_ler
 --
Cursor csr_prev_le is
 Select max(pil.Per_in_Ler_Id)
   From Ben_Per_in_ler PIL,
        Ben_Ler_F LER
  Where Pil.Ler_Id = LER.Ler_Id
    And ler.typ_Cd = 'GSP'
    And Pil.person_Id = l_person_id
    And Pil.Per_In_Ler_Stat_Cd = 'PROCD'
    And pil.Per_in_Ler_Id <> l_curr_per_in_ler_id;
--
--
 Cursor csr_prev_sal is
 Select Elct.Pgm_id, Rate.Rt_Strt_Dt Sal_Chg_Dt,Rate.Val Val
   From Ben_Elig_Per_Elctbl_Chc Elct,
        Ben_Enrt_Rt Rate
  Where Elct.DFLT_FLAG = 'Y'
    and Elct.Elctbl_Flag = 'Y'
    and Elct.Per_in_ler_id = l_Last_Per_In_ler_Id
   and Elct.Enrt_Cvg_Strt_Dt is Not NULL
    And Elct.ELIG_PER_ELCTBL_CHC_ID = Rate.ELIG_PER_ELCTBL_CHC_ID(+);

-- Check the last rate change date., not counting current one.
Cursor csr_max_rt_change is
Select max(Rate.Rt_Strt_Dt) Sal_Chg_Dt
   From Ben_Elig_Per_Elctbl_Chc Elct,
        Ben_Enrt_Rt Rate
  Where Elct.DFLT_FLAG = 'Y'
    and Elct.Elctbl_Flag = 'Y'
    and Elct.Per_in_ler_id in (Select pil.Per_in_Ler_Id
                                 From Ben_Per_in_ler PIL,
                                      Ben_Ler_F LER
                                Where Pil.Ler_Id = LER.Ler_Id
                                  And ler.typ_Cd = 'GSP'
                                  And Pil.person_Id = l_person_id
                                  And Pil.Per_In_Ler_Stat_Cd = 'PROCD'
                                 And pil.Per_in_Ler_Id <> l_curr_per_in_ler_id)
    and Elct.Enrt_Cvg_Strt_Dt is Not NULL
    And Elct.ELIG_PER_ELCTBL_CHC_ID = Rate.ELIG_PER_ELCTBL_CHC_ID(+);
  --
  Cursor Proposal_Dtls (P_Assignment_Id in Number,p_change_dt in date) is
  Select Pay_Proposal_Id, Object_Version_Number, nvl(date_to,to_date('31-12-4712','dd-mm-yyyy'))  -- bug 6856664
    From Per_Pay_Proposals
   Where Change_Date   = P_Change_Dt
     and Assignment_id = P_Assignment_id;
  --
  cursor csr_prev_sp_element is
    select element_entry_id
    from   pay_element_entries_f
    where  assignment_id = p_assignment_id
    and    creator_type = 'SP'
    and    l_prev_sal_change_dt between
         effective_start_date and effective_end_date;
 Begin
          --
          -- Find the  current per_in_ler and person_id.
          --
          hr_utility.set_location('Starting end dating prev payment',5);
          hr_utility.set_location('Elctbl chc = '||to_char(P_Elig_per_Elctbl_Chc_Id),5);
          hr_utility.set_location('le occrd dt = '||to_char(p_effective_date,'dd-mon-yyyy'),5);
          Open csr_curr_le;
          Fetch csr_curr_le into l_curr_per_in_ler_id, l_person_id;
          If csr_curr_le%found then
             -- Found current life event and person id.
             Close csr_curr_le;
             --
             -- Find when the salary change was made for the last GSP run.
             --
             hr_utility.set_location('Found current life event and person id = '||to_char(l_curr_per_in_ler_id),5);
             Open csr_prev_le;
             Fetch csr_prev_le into l_Last_Per_In_ler_Id;
             Close csr_prev_le;
             If l_Last_Per_In_ler_Id is not null then
                --
                --
                hr_utility.set_location('Found previous per_in_ler = '||to_char(l_Last_Per_In_ler_Id),5);
                -- Get the grade ladder, sal change date and rate value for the prev run.
                --
                Open csr_prev_sal;
                Fetch csr_prev_sal into l_prev_grade_ladder_id,l_prev_sal_change_dt,l_prev_sal;
                If csr_prev_sal%notfound then
                   --
                   hr_utility.set_location('No Previous ladder',10);
                   Close csr_prev_sal;
                Else
                   Close csr_prev_sal;
                   --
                   hr_utility.set_location('Found previous ladder',5);
                   -- Find the max rate change date. Ignore rate change date for current change.
                   --
                   Open csr_max_rt_change;
                   Fetch csr_max_rt_change into l_max_rt_change_dt;
                   Close csr_max_rt_change;
                   --
                   If (l_prev_sal_change_dt <= p_current_rate_change_dt AND
                       l_prev_sal_change_dt = l_max_rt_change_dt) then
                       --
                       hr_utility.set_location('Last sal change happened just bef current',5);
                       --
                       -- Get the grade ladder salary update details
                       --
                       OPen Pgm_Dtl(l_prev_grade_ladder_id,l_prev_sal_change_dt);
                       Fetch Pgm_Dtl into L_Update_Salary_Cd, L_DFLT_INPUT_VALUE_ID, L_DFLT_ELEMENT_TYPE_ID, l_Dflt_Step_Cd;
                       Close Pgm_Dtl;

                       If  L_Update_Salary_Cd = 'SALARY_ELEMENT'  AND
                           l_prev_sal is not null Then
                           --
                           hr_utility.set_location('Sal Element used to pay previously',5);
                           If L_DFLT_INPUT_VALUE_ID is NULL or  L_DFLT_ELEMENT_TYPE_ID is NULL Then
                               fnd_message.set_name('PQH','PQH_GSP_DFLY_ELMNT_NOT_LNKD');
                               fnd_message.raise_error;
                           End If;
                           --
                           Open  Elmt_Entry(p_Assignment_Id, p_Business_Group_Id, l_prev_sal_change_dt);
                           Fetch Elmt_Entry into L_Element_Entry_ID, L_Ele_Ovn;
                           If Elmt_Entry%Found Then
                              hr_utility.set_location('Found previous element entry',5);

                              If l_prev_sal_change_dt = p_current_rate_change_dt then
                                 --
                                 hr_utility.set_location('Zap element entry',5);
                                 --
                        	 hr_entry_api.delete_element_entry
                        	       ('ZAP'
                        	       ,p_current_rate_change_dt
                         	       ,l_element_entry_id);
    	                         --
                              Else
                                 --
                        	 hr_entry_api.delete_element_entry
                        	       ('DELETE'
                        	       ,p_current_rate_change_dt - 1
                         	       ,l_element_entry_id);
    	                         --
                               End If; --If l_prev_sal_change_dt = p_current_rate_change_dt then

                               /**
                               -- End date element entry.
                               L_DATE_TRACK_MODE  := DT_del_Mode
                              (P_EFFECTIVE_DATE        =>  p_current_rate_change_dt
                              ,P_BASE_TABLE_NAME       =>  'PAY_ELEMENT_ENTRIES_F'
                              ,P_BASE_KEY_COLUMN       =>  'ELEMENT_ENTRY_ID'
                              ,P_BASE_KEY_VALUE        =>  L_Element_Entry_ID);
                              --
                              hr_entry_api.delete_element_entry
                              (L_DATE_TRACK_MODE
                              ,p_current_rate_change_dt
                              ,l_element_entry_id);
                               --
                               **/
                           End if; --If Elmt_Entry%Found Then
                           --
                       ElsIf  L_Update_Salary_Cd = 'SALARY_BASIS'  AND
                           l_prev_sal is not null Then
                           --
                           hr_utility.set_location('Sal Basis used to pay previously',5);
                           -- End date salary proposal
                           Open Proposal_Dtls(p_assignment_Id,l_prev_sal_change_dt);
                           Fetch proposal_Dtls into l_Del_Proposal_Id, l_Del_Proposal_Ovn,l_proposal_date_to; -- bug 6856664
                           Close Proposal_Dtls;
                           --
                           if l_Del_Proposal_Id is Not NULL then
                              --
                              hr_utility.set_location('Found previous pay proposal',5);
                              Open csr_prev_sp_element;
                              Fetch csr_prev_sp_element into L_Element_Entry_ID;
                              If csr_prev_sp_element%notfound then
                                 hr_utility.set_location('Cannot find sal proposal element ! ',5);
                              end if;
                              Close csr_prev_sp_element;

                              -- Previous change happened on same date as current change.
                              --
                              If l_prev_sal_change_dt = p_current_rate_change_dt then
                                 --
                                 hr_utility.set_location('previous proposal date same as curr change date',5);
                                 Hr_Maintain_Proposal_Api.DELETE_SALARY_PROPOSAL
                                 (P_PAY_PROPOSAL_ID              =>   l_Del_proposal_Id
                                 ,P_BUSINESS_GROUP_ID           =>    p_business_Group_Id
                                 ,P_OBJECT_VERSION_NUMBER       =>    l_Del_Proposal_Ovn
                                 ,P_SALARY_WARNING              =>    l_Del_Warn);
                                 --
                                 /**
                                 hr_utility.set_location('Zap element entry',5);
                                 --
                        	 hr_entry_api.delete_element_entry
                        	       ('ZAP'
                        	       ,p_current_rate_change_dt - 1
                         	       ,l_element_entry_id);
                                **/
    	                         --
                             Elsif l_proposal_date_to > p_current_rate_change_dt then -- bug 6856664
                                 --
                                 -- End date Salary proposal
                                 --
                                 --
                                 hr_utility.set_location('previous proposal date before curr change date',5);
                                 --
                                 hr_maintain_proposal_api.update_salary_proposal(
                                  p_validate                     => false,
                                  p_pay_proposal_id              => l_Del_proposal_Id,
                                  p_date_to                      => p_current_rate_change_dt -1,
                                  p_object_version_number        => l_Del_Proposal_Ovn,
                                  p_inv_next_sal_date_warning    => l_inv_next_sal_date_warning,
                                  p_proposed_salary_warning      => l_proposed_salary_warning,
                                  p_approved_warning             => l_approved_warning,
                                  p_payroll_warning              => l_payroll_warning);
                                 --
                                 hr_utility.set_location('End dating element entry',5);
                                 --
				 /*  bug 6914468 and bug 6880958
				 commenting this part as the deleting or end dating of element entries
				 will be taken care by the Sal admin api's
                        	 hr_entry_api.delete_element_entry
                        	       ('DELETE'
                        	       ,p_current_rate_change_dt - 1
                         	       ,l_element_entry_id);
    	                         --
				 */
                             End If; --If l_prev_sal_change_dt = p_current_rate_change_dt then
                             --
                           End if; --if l_Del_Proposal_Id is Not NULL then
                           --
                       End if; -- L_Update_Salary_Cd = 'SALARY_ELEMENT'
                     Else
                         hr_utility.set_location('Do nothing',99);
                         hr_utility.set_location('Prev Salary change date ='||to_char(l_prev_sal_change_dt,'dd/mm/yyyy'),99);
                         hr_utility.set_location('Last Salary change date ='||to_char(l_max_rt_change_dt,'dd/mm/yyyy'),99);
                     End if; --If (l_prev_sal_change_dt <= p_current_rate_change_dt AND
                 End if; --If csr_prev_sal%notfound then
                 --
             Else
               -- No other salary change happened through GSP.
               -- Do nothing.
               hr_utility.set_location('No previous salary change by GSP',10);
             End if;  -- If csr_prev_le%found then
          Else
             hr_utility.set_location('Error: No Person and Per in ler',10);
             Close csr_curr_le;
          End if; --csr_curr_le%found
          --
 End; -- Change by SR



/**************************************************************************/
/************************** Update Salary Info. ***************************/
/**************************************************************************/

Procedure Update_Salary_Info
(P_Elig_per_Elctbl_Chc_Id	IN 	Number
,P_Effective_Date	        IN	Date
,P_Dt_Mode                      IN      Varchar2
,P_Called_From                  IN      Varchar2
,P_Prv_Sal_Chg_Dt               IN      Date) Is

--
/* Cursor Enroll_Info is
 Select Rate.rt_Val       , Rate.Rt_Strt_Dt, Rate.Prtt_Rt_Val_Id,
        Rate.pk_Id        , Rate.Object_Version_Number, Enrt.Pgm_Id,
        Asgt.Assignment_Id, Asgt.pay_basis_id, Enrt.Business_Group_id
   From Ben_PRTT_ENRT_RSLT_F  Enrt,
        ben_prtt_rt_val       Rate,
        Per_All_Assignments_F Asgt
  Where Enrt.PRTT_ENRT_RSLT_ID = P_PRTT_ENRT_RSLT_ID
    and P_Effective_Date
between Enrt.Effective_Start_Date
    and Enrt.Effective_End_Date
    and Enrt.Prtt_Enrt_Rslt_Id = Rate.Prtt_Enrt_Rslt_Id
    And Asgt.Person_id = Enrt.Person_id
    And Asgt.PRIMARY_FLAG =  'Y'
    And Asgt.assignment_type =  'E'
    And P_Effective_Date
Between Asgt.Effective_start_Date and Asgt.Effective_end_Date; */

l_Pay_Proposal_Id	    Per_Pay_Proposals.Pay_Proposal_Id%TYPE;
L_Pay_Proposals_Ovn	    Per_Pay_Proposals.Object_version_Number%TYPE;

l_Rt_Ovn		    Ben_Prtt_Rt_Val.Object_Version_Number%TYPE;
l_salary		    Ben_Prtt_Rt_Val.Rt_Val%TYPE;
L_INV_NEXT_SAL_DATE_WARNING Boolean;
L_PROPOSED_SALARY_WARNING   Boolean;
L_APPROVED_WARNING	    Boolean;
L_PAYROLL_WARNING	    Boolean;
l_Del_Warn                  Boolean;
L_ERROR_TEXT                Varchar2(250);
L_Update_Salary_Cd          Ben_Pgm_F.Update_Salary_Cd%TYPE;
L_DFLT_INPUT_VALUE_ID       Ben_Pgm_F.DFLT_INPUT_VALUE_ID%TYPE;
L_DFLT_ELEMENT_TYPE_ID      Ben_Pgm_F.DFLT_ELEMENT_TYPE_ID%TYPE;
l_Element_Link_Id           Pay_Element_Links_f.Element_Link_Id%TYPE;
L_Effective_Start_Date      pay_element_entries_f.Effective_Start_Date%TYPE;
L_Effective_End_Date        pay_element_entries_f.Effective_End_Date%TYPE;
L_Element_Entry_ID          pay_element_entries_f.Element_Entry_Id%TYPE;
L_Ele_Ovn                   pay_element_entries_f.Object_Version_Number%TYPE;
l_Create_Warn               Boolean;
l_DFLT_STEP_CD              Ben_Pgm_F.DFLT_STEP_CD%TYPE;
l_Change_Dt                 Per_Pay_proposals.Change_Date%TYPE;
l_Del_proposal_Id           Per_Pay_proposals.Pay_proposal_Id%TYPE;
l_Del_Proposal_Ovn          per_pay_Proposals.Object_version_Number%TYPE;

l_payroll_annualization_factor per_time_period_types.number_per_fiscal_year%TYPE;
L_Payroll_name                 pay_all_payrolls_f.Payroll_name%TYPE;

 Cursor Enroll_Info is
 Select Rate.Val       , Rate.Rt_Strt_Dt, Rate.Prtt_Rt_Val_Id,
        Rate.Object_Version_Number, Enrt.Pgm_Id, Enrt.OiPl_Id,
        Asgt.Assignment_Id, Asgt.pay_basis_id, Asgt.Grade_Id, Enrt.Business_Group_id
   From Ben_ELig_per_Elctbl_Chc  Enrt,
        ben_Enrt_Rt              Rate,
        Ben_Per_in_ler           PIL,
        Per_All_Assignments_F    Asgt
  Where Enrt.Elig_per_Elctbl_Chc_id = P_Elig_per_Elctbl_Chc_Id
    And Enrt.Per_In_Ler_id = Pil.Per_In_Ler_id
    And Asgt.Person_id = PIL.Person_id
    And P_Effective_Date
Between Asgt.Effective_start_Date and Asgt.Effective_end_Date
    and Enrt.Elig_per_Elctbl_Chc_id = Rate.Elig_per_Elctbl_Chc_id(+)
    and asgt.assignment_type ='E'
    And Asgt.PRIMARY_FLAG =  'Y';


CURSOR Element_Info(P_assignmnet_id number,P_pay_basis_id number, P_Effective_Date in DAte) IS
Select ele.element_entry_id
 from  per_pay_bases bas,
       pay_element_entries_f ele,
       pay_element_entry_values_f entval
 where bas.pay_basis_id = P_pay_basis_id
   and entval.input_value_id = bas.input_value_id
   and p_effective_date
between entval.effective_start_date
    and entval.effective_end_date
    and ele.assignment_id  = P_assignmnet_id
    and p_effective_date between ele.effective_start_date
    and ele.effective_end_date
    and ele.element_entry_id = entval.element_entry_id;

 Cursor Pgm_Dtl(P_Pgm_Id In Number,P_effective_Date in date) is
 Select Update_Salary_Cd, DFLT_INPUT_VALUE_ID, DFLT_ELEMENT_TYPE_ID, DFLT_STEP_CD
   From ben_Pgm_F
  Where Pgm_id = P_Pgm_Id
    and P_effective_Date
Between Effective_Start_Date
    and Effective_End_Date;

 CURSOR Elmt_Entry (p_assignment_id IN NUMBER, P_Business_group_Id IN Number, p_Effective_Date IN Date) IS
 select pee.Element_Entry_Id, pee.Object_version_Number
   from pay_element_types_f   pet
       ,pay_element_links_f   pel
       ,pay_element_entries_f pee
  where Pet.Element_type_id  = L_DFLT_ELEMENT_TYPE_ID
    and p_Effective_date
Between pet.effective_start_date
    and pet.effective_end_date
    and Pel.Element_type_Id  = Pet.Element_type_Id
    and p_Effective_date
Between pel.effective_start_date
    and pel.effective_end_date
    and pee.element_link_id = pel.element_link_id
    and pee.assignment_id   = p_assignment_id
    and p_Effective_date
between pee.effective_start_date
    and pee.effective_end_date;

 Cursor Proposal_Dt (P_Assignment_Id   IN Number) is
 Select Max(Change_Date)
   from Per_Pay_Proposals
  Where Assignment_Id = P_Assignment_id
  AND  p_Effective_date BETWEEN Change_Date AND
	nvl(DATE_TO,to_date('31-12-4712','dd-mm-yyyy')) ;-- added for bug 6880958
-- bug 6880958 modified the above cursor. as the when performing a date track correction
-- where there is a future dated record , Application was erroring out.


  Cursor Proposal_Dtls (P_Assignment_Id in Number) is
  Select Pay_Proposal_Id, Object_Version_Number
    From Per_Pay_Proposals
   Where Change_Date   = l_Change_Dt
     and Assignment_id = P_Assignment_id;

L_Enroll_Info		    Enroll_Info%ROWTYPE;
L_DATE_TRACK_MODE           Varchar2(25);
--
-- bug 6880958 for updateoverride mode
--
Cursor next_change_date(P_Assignment_id in number)
IS
select change_date ,Pay_Proposal_Id, Object_Version_Number
from per_pay_proposals
where assignment_id = P_Assignment_id
and  change_date > p_Effective_date;

l_change_date date;
L_entry_date date;

cursor csr_count_pay_det(P_Assignment_id in number)
is
select count(*)
from per_pay_proposals
where assignment_id = P_Assignment_id
and  change_date > p_Effective_date;
--
l_count number;
--
-- bug 6880958 for updateoverride mode
--
Begin

g_debug := hr_utility.debug_enabled;

--
-- Get enrollment details for the current change.
--
hr_utility.set_location(' p_Effective_date :' || p_Effective_date, 30);

Open  Enroll_Info;
Fetch Enroll_Info into L_Enroll_Info;
Close Enroll_Info;

if g_debug then
   hr_utility.set_location(' Inside Salary Update: Elec_id :' || P_Elig_Per_Elctbl_Chc_Id, 10);
   hr_utility.set_location(' L_Enroll_Info.Business_Group_Id :' || L_Enroll_Info.Business_Group_Id, 20);
   hr_utility.set_location(' L_Enroll_Info.OVN :' || L_Enroll_Info.Object_version_number, 30);
End If;

--
-- Get the grade ladder salary update details
--
OPen Pgm_Dtl(L_Enroll_Info.Pgm_Id,P_effective_Date);
Fetch Pgm_Dtl into L_Update_Salary_Cd, L_DFLT_INPUT_VALUE_ID, L_DFLT_ELEMENT_TYPE_ID, l_Dflt_Step_Cd;
Close Pgm_Dtl;

-- If there is no rate
If L_Enroll_Info.Val is NULL Then

If l_Dflt_Step_cd = 'NOSTEP' and L_Enroll_Info.Oipl_Id is NULL Then

   Return;

Else

   fnd_message.set_name('PQH','PQH_GSP_RAT_NOT_DFND');
   fnd_message.raise_error;

End If;
End If;
--Covert salary from program frequency to salary basis frequency
l_salary := L_Enroll_Info.Val;
l_Salary := Pqh_Gsp_Utility.PGM_TO_BASIS_CONVERSION
           (P_Pgm_Id                       => L_Enroll_Info.Pgm_Id
           ,P_EFFECTIVE_DATE               => P_Effective_Date
           ,P_AMOUNT                       => l_Salary
           ,P_ASSIGNMENT_ID                => L_Enroll_Info.Assignment_Id);
--
-- Current grade ladder uses salary basis to update salary
--
If L_Update_Salary_Cd = 'SALARY_BASIS' Then
   If L_Enroll_Info.Pay_Basis_Id is NULL Then
      fnd_message.set_name('PQH','PQH_GSP_SALBSIS_NOT_LNKD');
      fnd_message.raise_error;
   End If;
   --
   -- Find when was the last proposal change.
   --

   Open  Proposal_Dt(L_Enroll_Info.Assignment_Id);
   Fetch Proposal_Dt into l_Change_Dt;
   Close Proposal_Dt;

 --  If P_Dt_Mode = 'CORRECTION' and P_Called_From = 'A' Then
     If P_Called_From = 'A' Then
        -- If there is a salary proposal that was created either on current date
        -- or during last GSP run,
	hr_utility.set_location(' L_Change_Dt:' || L_Change_Dt, 30);

        If L_Change_Dt is NOT NULL then
          --
          -- Get the last pay proposal creation date.
          --
          Open Proposal_Dtls(L_Enroll_Info.Assignment_Id);
          Fetch proposal_Dtls into l_Del_Proposal_Id, l_Del_Proposal_Ovn;
          Close Proposal_Dtls;
          --
          -- If pay proposal already exists as of current date, then delete
          -- i.e. If Correction
          --
	   hr_utility.set_location(' P_Prv_Sal_Chg_Dt :' || P_Prv_Sal_Chg_Dt, 31);
              hr_utility.set_location(' L_Enroll_Info.RT_Strt_Dt :' || L_Enroll_Info.RT_Strt_Dt, 32);

          If ((L_Change_Dt = L_Enroll_Info.RT_Strt_Dt) or
              (L_Change_Dt = P_Prv_Sal_Chg_Dt)) Then

            -- Get the proposal details and delete it altogether

            if l_Del_Proposal_Id is Not NULL then

              Hr_Maintain_Proposal_Api.DELETE_SALARY_PROPOSAL
             (P_PAY_PROPOSAL_ID              =>   l_Del_proposal_Id
             ,P_BUSINESS_GROUP_ID           =>    L_Enroll_Info.Business_Group_Id
             ,P_OBJECT_VERSION_NUMBER       =>    l_Del_Proposal_Ovn
             ,P_SALARY_WARNING              =>    l_Del_Warn);

             End If;

           Else
             --
	     -- fix for bug 6880958 starts here .. deleting all the pay proposals as we are performing
	     -- update replace operation.
	     --
	     hr_utility.set_location(' P_Dt_Mode :' || P_Dt_Mode, 1);
             hr_utility.set_location(' L_Enroll_Info.Assignment_Id :' || L_Enroll_Info.Assignment_Id, 2);

             if P_Dt_Mode = 'UPDATE_OVERRIDE' THEN

                open csr_count_pay_det(L_Enroll_Info.Assignment_Id);
        fetch csr_count_pay_det into l_count;
        close csr_count_pay_det;

        for i in 1 .. l_count
        loop


               OPEN next_change_date(L_Enroll_Info.Assignment_Id) ;
               FETCH next_change_date INTO l_change_date,l_Del_Proposal_Id, l_Del_Proposal_Ovn;
               EXIT WHEN next_change_date%NOTFOUND;

                hr_utility.set_location(' l_change_date :' || l_change_date, 10);
                hr_utility.set_location(' l_Del_Proposal_Id :' || l_Del_Proposal_Id, 20);
                hr_utility.set_location(' l_Del_Proposal_Ovn :' || l_Del_Proposal_Ovn, 30);

                    -- NOW DELETE ALL THE PROPOSALS AS WE ARE PERFORMING A UPDATE REPLACE OPERATION

			Hr_Maintain_Proposal_Api.DELETE_SALARY_PROPOSAL
                         (P_PAY_PROPOSAL_ID              =>   l_Del_proposal_Id
                         ,P_BUSINESS_GROUP_ID           =>    L_Enroll_Info.Business_Group_Id
                         ,P_OBJECT_VERSION_NUMBER       =>    l_Del_Proposal_Ovn
                         ,P_SALARY_WARNING              =>    l_Del_Warn);
		--
            hr_utility.set_location(' after calling delete Proposal ' || l_Del_Proposal_Id, 20);


                CLOSE next_change_date;

     END LOOP;

     if next_change_date%isopen then
     close next_change_date;
     end if;

             END IF; -- update override IF ..

             --

		select max(effective_end_date) into L_entry_date
		    from pay_element_entries_f
		    where assignment_id=L_Enroll_Info.Assignment_Id
		    and creator_type='SP';

		 hr_utility.set_location(' Max Element entry date: ' ||L_entry_date,1);
	--
	-- fix for bug 6880958 ends..

             hr_utility.set_location('Calling end_prev_gsp_payment 0',99);
             end_prev_gsp_payment(
              p_assignment_id                => L_Enroll_Info.Assignment_Id
             ,p_business_group_id            => L_Enroll_Info.Business_Group_Id
             ,P_Effective_Date               => p_effective_date
             ,P_Elig_per_Elctbl_Chc_Id       => P_Elig_per_Elctbl_Chc_Id
             ,p_current_rate_change_dt       =>  L_Enroll_Info.RT_Strt_Dt);
             hr_utility.set_location('After end_prev_gsp_payment 0',99);
             --
           End if;
           --
        Else
            hr_utility.set_location('Calling end_prev_gsp_payment 1',99);
            end_prev_gsp_payment(
              p_assignment_id                => L_Enroll_Info.Assignment_Id
             ,p_business_group_id            => L_Enroll_Info.Business_Group_Id
             ,P_Effective_Date               => p_effective_date
             ,P_Elig_per_Elctbl_Chc_Id       => P_Elig_per_Elctbl_Chc_Id
             ,p_current_rate_change_dt       =>  L_Enroll_Info.RT_Strt_Dt);
            hr_utility.set_location('After end_prev_gsp_payment 1',99);

       End If;

       --
   End If;

   --
   -- Now Create a new pay proposal
   --
   Open  Element_Info(L_Enroll_Info.Assignment_Id, L_Enroll_Info.pay_basis_id, l_Enroll_Info.Rt_Strt_Dt);
   Fetch Element_Info Into L_Element_Entry_Id;
   Close Element_Info;

   Hr_Maintain_Proposal_Api.INSERT_SALARY_PROPOSAL
   (P_PAY_PROPOSAL_ID            =>  l_Pay_Proposal_Id
   ,P_ASSIGNMENT_ID              =>  L_Enroll_Info.Assignment_Id
   ,P_BUSINESS_GROUP_ID          =>  L_Enroll_Info.Business_Group_Id
   ,P_CHANGE_DATE                =>  L_Enroll_Info.RT_Strt_Dt
   ,P_PROPOSED_SALARY_N          =>  l_Salary
   ,P_OBJECT_VERSION_NUMBER      =>  L_Pay_Proposals_Ovn
   ,P_ELEMENT_ENTRY_ID           =>  L_Element_Entry_Id
   ,P_MULTIPLE_COMPONENTS        =>  'N'
   ,P_APPROVED                   =>  'Y'
   ,P_PROPOSAL_REASON            =>  'GSP'
   ,P_INV_NEXT_SAL_DATE_WARNING  =>  L_INV_NEXT_SAL_DATE_WARNING
   ,P_PROPOSED_SALARY_WARNING    =>  L_PROPOSED_SALARY_WARNING
   ,P_APPROVED_WARNING           =>  L_APPROVED_WARNING
   ,P_PAYROLL_WARNING            =>  L_PAYROLL_WARNING);

   /*
   Hr_Maintain_Proposal_Api.Approve_Salary_Proposal
   (P_PAY_PROPOSAL_ID           =>  L_Pay_Proposal_Id
   ,P_OBJECT_VERSION_NUMBER     =>  L_Pay_Proposals_Ovn
   ,P_INV_NEXT_SAL_DATE_WARNING =>  L_INV_NEXT_SAL_DATE_WARNING
   ,P_PROPOSED_SALARY_WARNING   =>  L_PROPOSED_SALARY_WARNING
   ,P_APPROVED_WARNING          =>  L_APPROVED_WARNING
   ,P_PAYROLL_WARNING           =>  L_PAYROLL_WARNING
   ,P_ERROR_TEXT                =>  L_ERROR_TEXT);  */

    -- l_Rt_Ovn := L_Enroll_Info.Object_Version_Number;

   /*
    Ben_Prtt_Rt_Val_Api.UPDATE_PRTT_RT_VAL
    (P_PRTT_RT_VAL_ID               =>	L_Enroll_Info.PRTT_RT_VAL_ID
    ,P_PK_ID_TABLE_NAME             =>	'PER_PAY_PROPOSALS'
    ,P_PK_ID                        =>	l_Pay_Proposal_Id
    ,P_OBJECT_VERSION_NUMBER        =>	L_Rt_Ovn
    ,P_EFFECTIVE_DATE               =>	P_Effective_Date); */

Elsif L_Update_Salary_Cd = 'SALARY_ELEMENT' Then

  -- If current grade ladder uses a salary element.
  --
  -- Get default element and input value of current ladder.
  --
  If L_DFLT_INPUT_VALUE_ID is NULL or  L_DFLT_ELEMENT_TYPE_ID is NULL Then
     fnd_message.set_name('PQH','PQH_GSP_DFLY_ELMNT_NOT_LNKD');
     fnd_message.raise_error;
  End If;
  --
  -- Check if the assignment is eligible for the element as of current rate start date
  --
  l_Element_Link_Id := hr_entry_api.get_link
                       (L_Enroll_Info.Assignment_Id
                       ,L_DFLT_ELEMENT_TYPE_ID
                       ,L_Enroll_Info.RT_Strt_Dt);

  if l_Element_Link_Id is NULL Then
     fnd_message.set_name('PQH','PQH_GSP_ELMNT_NOT_LNKD');
     fnd_message.raise_error;
  End If;

  --
  -- Check if there is a rate value.
  --
  If L_Enroll_Info.Val is NULL Then
     fnd_message.set_name('PQH','PQH_GSP_RAT_NOT_DFND');
     fnd_message.raise_error;
  End If;
  --
  -- Get current pay proposal
  --
  per_pay_proposals_populate.get_payroll(L_Enroll_Info.Assignment_Id
                                        ,L_Enroll_Info.RT_Strt_Dt
                                        ,l_Payroll_name
                                        ,l_payroll_annualization_factor);

  If L_Payroll_name is NULL Then
     fnd_message.set_name('PQH','PQH_GSP_PAYROLL_NOT_DFND');
     fnd_message.raise_error;
  End If;

  -- check if a element entry already exists, for the default element
  -- If so update the element entru, else create the element entry.
  --
  Open  Elmt_Entry(L_Enroll_Info.Assignment_Id, L_Enroll_Info.Business_Group_Id, L_Enroll_Info.Rt_Strt_Dt);
  Fetch Elmt_Entry into L_Element_Entry_ID, L_Ele_Ovn;
  If Elmt_Entry%Found Then

      L_DATE_TRACK_MODE  := DT_Mode
                           (P_EFFECTIVE_DATE        =>  L_Enroll_Info.RT_Strt_Dt
                           ,P_BASE_TABLE_NAME       =>  'PAY_ELEMENT_ENTRIES_F'
                           ,P_BASE_KEY_COLUMN       =>  'ELEMENT_ENTRY_ID'
                           ,P_BASE_KEY_VALUE        =>  L_Element_Entry_ID);
     hr_utility.set_location('Sal = '||to_char(L_Salary)||',DT_Mode = '||L_DATE_TRACK_MODE,99);

     Pay_Element_Entry_Api.UPDATE_ELEMENT_ENTRY
     (P_DATETRACK_UPDATE_MODE    =>  L_DATE_TRACK_MODE
     ,P_EFFECTIVE_DATE           =>  L_Enroll_Info.RT_Strt_Dt
     ,P_BUSINESS_GROUP_ID        =>  L_Enroll_Info.Business_Group_Id
     ,P_ELEMENT_ENTRY_ID         =>  L_ELEMENT_ENTRY_ID
     ,P_OBJECT_VERSION_NUMBER    =>  L_Ele_Ovn
     ,P_INPUT_VALUE_ID1          =>  L_DFLT_INPUT_VALUE_ID
     ,P_ENTRY_VALUE1             =>  L_Salary
     ,P_EFFECTIVE_START_DATE     =>  L_Effective_Start_Date
     ,P_EFFECTIVE_END_DATE       =>  L_Effective_End_Date
     ,P_UPDATE_WARNING           =>  l_Create_Warn);

  Else
     --
     -- If the element entry is not found for current element, it maybe due to 2 reasons
     -- 1) old grade ladder used a diff element, in which case we have to end date that element
     -- 2) old grade ladder used salary basis, in which case we have to end date the proposal.

     hr_utility.set_location('Calling end_prev_gsp_payment 2',99);
     end_prev_gsp_payment(
              p_assignment_id                => L_Enroll_Info.Assignment_Id
             ,p_business_group_id            => L_Enroll_Info.Business_Group_Id
             ,P_Effective_Date               => p_effective_date
             ,P_Elig_per_Elctbl_Chc_Id       => P_Elig_per_Elctbl_Chc_Id
             ,p_current_rate_change_dt       =>  L_Enroll_Info.RT_Strt_Dt);
     hr_utility.set_location('After end_prev_gsp_payment 2',99);

      Pay_Element_Entry_Api.CREATE_ELEMENT_ENTRY
      (P_EFFECTIVE_DATE               =>   L_Enroll_Info.RT_Strt_Dt
      ,P_BUSINESS_GROUP_ID            =>   L_Enroll_Info.Business_Group_Id
      ,P_ASSIGNMENT_ID                =>   L_Enroll_Info.Assignment_Id
      ,P_ELEMENT_LINK_ID              =>   l_Element_Link_Id
      ,P_ENTRY_TYPE                   =>   'E'
      ,P_INPUT_VALUE_ID1              =>   L_DFLT_INPUT_VALUE_ID
      ,P_ENTRY_VALUE1                 =>   L_Salary
      ,P_EFFECTIVE_START_DATE         =>   L_Effective_Start_Date
      ,P_EFFECTIVE_END_DATE           =>   L_Effective_End_Date
      ,P_ELEMENT_ENTRY_ID             =>   L_Element_Entry_ID
      ,P_OBJECT_VERSION_NUMBER        =>   L_Ele_Ovn
      ,P_CREATE_WARNING               =>   l_Create_Warn);
   End If;
   Close Elmt_Entry;
Else
   Return;
End If; /* Update_Salary_Cd */

End Update_Salary_info;


/**************************************************************************/
/************************* Update Assignment info *************************/
/**************************************************************************/

Procedure Update_Assgmt_Info
(P_Elig_Per_Elctbl_Chc_Id   IN 	Number,
 P_Effective_Date	    IN 	Date) is

 Cursor Enrlmt_Dtls is
 Select Enrlmt.PL_Id           , Enrlmt.Pgm_Id   , Enrlmt.Oipl_Id        , Enrlmt.Business_Group_Id,
        Enrlmt.Enrt_Cvg_Strt_Dt, Pgm.Dflt_Step_CD, Pl.MAPPING_TABLE_PK_ID, Asgt.Assignment_Id,
        Asgt.Object_Version_Number , Asgt.SPECIAL_CEILING_STEP_ID, Asgt.People_Group_Id,
        Asgt.Soft_Coding_Keyflex_Id, Asgt.Grade_Id, Asgt.Grade_Ladder_Pgm_Id
   From Ben_Elig_Per_Elctbl_Chc Enrlmt,
        Ben_Per_in_ler          PIL,
        Ben_Pgm_F               Pgm,
        Ben_PLip_F              Plip,
        Ben_Pl_F                Pl,
        Per_All_Assignments_F   Asgt
  Where Enrlmt.Elig_Per_Elctbl_Chc_Id = P_Elig_Per_Elctbl_Chc_Id
    And Enrlmt.Per_In_Ler_id = Pil.Per_In_Ler_id
    And Asgt.Person_id = PIL.Person_id
    and Pgm.Pgm_Id     = Enrlmt.Pgm_Id
    and P_Effective_Date
Between Pgm.Effective_Start_Date
    and Pgm.Effective_End_Date
    and Pl.Pl_Id       =    Enrlmt.Pl_Id
    and P_Effective_Date
Between Pl.Effective_Start_Date
    and Pl.Effective_End_Date
    and Plip.Pgm_Id	=   Pgm.Pgm_Id
    and Plip.Pl_Id      =   Pl.Pl_Id
    and P_Effective_Date
Between Plip.Effective_Start_Date
    and Plip.Effective_End_Date
    and Asgt.Person_id = Pil.Person_id
    And Asgt.PRIMARY_FLAG =  'Y'
    And Asgt.assignment_type =  'E'
    And P_Effective_Date
Between Asgt.Effective_start_Date and Asgt.Effective_end_Date;

 Cursor Step_Dtls(P_Oipl_Id IN NUmber) Is
 Select Step.Step_id, Step.Spinal_point_id, Step.Grade_spine_id
   From Ben_Oipl_F Oipl,
        Ben_pl_F Pl,
        Ben_Opt_F Opt,
        Per_Spinal_points point,
        Per_Grade_Spines_f GSpine,
        Per_Spinal_point_Steps_F Step
  Where Oipl.Oipl_id  = P_Oipl_Id
    and P_Effective_Date
Between OiPl.Effective_Start_Date and OiPl.Effective_End_Date
    and Pl.Pl_id = Oipl.Pl_Id
    and P_Effective_Date
Between Pl.Effective_Start_Date and Pl.Effective_End_Date
    and Oipl.Opt_id = Opt.Opt_id
    and P_Effective_Date
Between Opt.Effective_Start_Date and Opt.Effective_End_Date
    and Point.Spinal_Point_id  = Opt.Mapping_Table_Pk_Id
    and Pl.Mapping_Table_Pk_Id = Gspine.Grade_Id
    and P_Effective_Date
Between Gspine.Effective_Start_Date and Gspine.Effective_End_Date
    and Step.Grade_Spine_Id    = Gspine.Grade_Spine_Id
    and P_Effective_Date
Between Step.Effective_Start_Date and Step.Effective_End_Date
    and Step.SPINAL_POINT_ID   = Point.SPINAL_POINT_ID;

 Cursor Plcmt_Dtls(P_Assignment_Id IN NUMBER, P_Effective_Date IN Date) is
 Select PLACEMENT_ID        , Object_Version_Number,
        Effective_Start_Date, Effective_End_Date
   from Per_Spinal_Point_Placements_F
  Where Assignment_Id = P_Assignment_Id
    and P_Effective_Date
Between Effective_Start_Date
    and Effective_End_Date;

L_PL_Id                        Ben_Pl_F.Pl_Id%TYPE;
L_Pgm_Id                       Ben_Pgm_F.Pgm_Id%TYPE;
L_Oipl_Id                      Ben_Oipl_F.Oipl_Id%TYPE;
l_DFLT_STEP_CD                 Ben_Pgm_F.DFLT_STEP_CD%TYPE;
l_Grade_Id                     Per_Grades.Grade_Id%TYPE;
l_Step_Id                      Per_Spinal_point_Steps_F.Step_Id%TYPE;
l_Spinal_point_id              Per_Spinal_point_Steps_F.Spinal_Point_Id%TYPE;
l_Grade_spine_id               Per_Spinal_point_Steps_F.Grade_Spine_Id%TYPE;
l_Assignment_id                Per_All_Assignments_F.Assignment_Id%TYPE;
l_Assignment_Ovn               Per_All_Assignments_F.Object_Version_Number%TYPE;
l_SPECIAL_CEILING_STEP_ID      Per_All_Assignments_F.SPECIAL_CEILING_STEP_ID%TYPE;
L_People_Group_Id	       Per_All_Assignments_F.People_Group_Id%TYPE;
l_Soft_Coding_Keyflex_Id       Per_All_Assignments_F.Soft_Coding_Keyflex_Id%TYPE;
l_PLACEMENT_ID                 Per_Spinal_Point_Placements_F.PLacement_Id%TYPE;
l_Placement_Ovn	               Per_Spinal_Point_Placements_F.Object_Version_Number%TYPE;
l_Effective_Start_Date         Per_Spinal_Point_Placements_F.Effective_Start_Date%TYPE;
l_Effective_End_Date           Per_Spinal_Point_Placements_F.Effective_End_Date%TYPE;
l_Business_Group_Id            Ben_PRTT_ENRT_RSLT_F.Business_Group_Id%TYPE;
l_group_name                   Varchar2(250);
l_Asg_effective_start_date     Per_All_Assignments_F.Effective_Start_Date%TYPE;
l_Asg_effective_end_date       Per_All_Assignments_F.Effective_End_Date%TYPE;
l_org_now_no_manager_warning   Boolean;
l_other_manager_warning        Boolean;
l_spp_delete_warning           Boolean;
l_entries_changed_warning      Varchar2(250);
l_tax_district_changed_warning Boolean;
l_concatenated_segments        Varchar2(250);
L_DATE_TRACK_MODE              Varchar2(25);
l_Enrt_Cvg_Strt_Dt             Ben_Elig_Per_Elctbl_Chc.Enrt_Cvg_Strt_Dt%TYPE;
l_Asgt_grade_Id                Per_All_Assignments_F.Grade_Id%TYPE;
l_Asgt_Grdldr_Id               Per_all_Assignments_F.Grade_Ladder_Pgm_Id%TYPE;
Begin

if g_debug then
   hr_utility.set_location(' Inside Update_Assgmt_Info ', 10);
End If;

Open Enrlmt_Dtls;
Fetch Enrlmt_Dtls into l_pl_Id       , l_Pgm_Id   ,l_Oipl_id        , L_Business_group_Id, l_Enrt_Cvg_Strt_Dt,
                       l_DFLT_STEP_CD, l_Grade_Id ,l_Assignment_id  , l_Assignment_Ovn,
                       L_SPECIAL_CEILING_STEP_ID,  L_People_Group_Id, l_Soft_Coding_Keyflex_Id, l_Asgt_Grade_ID, l_Asgt_Grdldr_Id;
Close Enrlmt_Dtls;

If Nvl(l_DFLT_STEP_CD,'PQH_GSP_NP') = 'PQH_GSP_NP' Then
   /* rogression Style is No progression -- So return back */
   Return;
End If;

If ((l_Asgt_Grade_Id <> l_Grade_id) or (Nvl(l_Asgt_Grdldr_Id,-1) <> l_Pgm_id)) Then
  /* Update Assignments with the Grade Ladder / Grade Details */
   L_DATE_TRACK_MODE  := DT_Mode
                        (P_EFFECTIVE_DATE        =>  Nvl(l_Enrt_Cvg_Strt_Dt, P_Effective_Date)
                        ,P_BASE_TABLE_NAME       =>  'PER_ALL_ASSIGNMENTS_F'
                        ,P_BASE_KEY_COLUMN       =>  'ASSIGNMENT_ID'
                        ,P_BASE_KEY_VALUE        =>  L_Assignment_id);

   if g_debug then
      hr_utility.set_location(' L_DATE_TRACK_MODE : '  || L_DATE_TRACK_MODE, 20);
   End If;

   If Nvl(l_DFLT_STEP_CD,'XX') = 'NOSTEP' Then
      Open Plcmt_Dtls(l_Assignment_Id, l_Enrt_Cvg_Strt_Dt);
      Fetch Plcmt_Dtls Into l_PLACEMENT_ID        , l_Placement_Ovn,
                            l_Effective_Start_Date, L_Effective_End_Date;
      If Plcmt_Dtls%FOUND Then
         Hr_Sp_Placement_Api.DELETE_SPP
        (P_EFFECTIVE_DATE          => Nvl(l_Enrt_Cvg_Strt_Dt, P_Effective_Date) - 1
        ,P_DATETRACK_MODE          => 'DELETE'
        ,P_PLACEMENT_ID            => l_PLACEMENT_ID
        ,P_OBJECT_VERSION_NUMBER    => l_Placement_Ovn
        ,P_EFFECTIVE_START_DATE     => l_Effective_Start_Date
        ,P_EFFECTIVE_END_DATE       => L_Effective_End_Date);
      End If;
      Close Plcmt_Dtls;
   End If;

   Hr_Assignment_Api.Update_Emp_Asg_Criteria
  (p_effective_date               =>  Nvl(l_Enrt_Cvg_Strt_Dt, P_Effective_Date)
  ,p_datetrack_update_mode        =>  L_Date_Track_Mode
  ,p_assignment_id                =>  L_Assignment_id
  ,p_grade_id                     =>  L_Grade_Id
  ,p_grade_ladder_pgm_id          =>  L_Pgm_Id
  ,p_object_version_number        =>  L_Assignment_Ovn
  ,p_special_ceiling_step_id      =>  L_special_ceiling_step_id
  ,p_people_group_id              =>  L_People_Group_Id
  ,p_soft_coding_keyflex_id       =>  L_Soft_Coding_Keyflex_Id
  ,p_group_name                   =>  L_group_name
  ,p_effective_start_date         =>  L_Asg_effective_start_date
  ,p_effective_end_date           =>  L_Asg_effective_end_date
  ,p_org_now_no_manager_warning   =>  L_org_now_no_manager_warning
  ,p_other_manager_warning        =>  L_other_manager_warning
  ,p_spp_delete_warning           =>  L_spp_delete_warning
  ,p_entries_changed_warning      =>  L_entries_changed_warning
  ,p_tax_district_changed_warning =>  L_tax_district_changed_warning
  ,p_concatenated_segments        =>  L_concatenated_segments);

If Nvl(l_DFLT_STEP_CD,'XX') = 'NOSTEP' Then
   Return;
End If;

End If;
If Nvl(l_DFLT_STEP_CD,'XX') in ('PQH_GSP_GSP','PQH_GSP_SP','MINSALINCR','MINSTEP','NOSTEP') Then
   Open Step_Dtls(l_Oipl_id);
   Fetch Step_Dtls Into L_Step_id, l_Spinal_point_id, l_Grade_spine_id;

   If Step_Dtls%Found Then
      Open Plcmt_Dtls(l_Assignment_Id, l_Enrt_Cvg_Strt_Dt);
      Fetch Plcmt_Dtls Into l_PLACEMENT_ID        , l_Placement_Ovn,
                            l_Effective_Start_Date, L_Effective_End_Date;

      L_DATE_TRACK_MODE  := NULL;


       If Plcmt_Dtls%FOUND Then

          L_DATE_TRACK_MODE  := DT_Mode
                              (P_EFFECTIVE_DATE        =>  Nvl(l_Enrt_Cvg_Strt_Dt, P_Effective_Date)
                              ,P_BASE_TABLE_NAME       =>  'PER_SPINAL_POINT_PLACEMENTS_F'
                              ,P_BASE_KEY_COLUMN       =>  'PLACEMENT_ID'
                              ,P_BASE_KEY_VALUE        =>  l_PLACEMENT_ID);

          /* Update Placements with the New Step Details */
          Hr_Sp_Placement_Api.UPDATE_SPP
          (P_EFFECTIVE_DATE         => Nvl(l_Enrt_Cvg_Strt_Dt, P_Effective_Date),
           P_DATETRACK_MODE         => l_Date_Track_Mode,
           P_PLACEMENT_ID           => l_PLACEMENT_ID,
           P_OBJECT_VERSION_NUMBER  => l_Placement_Ovn,
           P_REASON                 => 'GSP',
           P_STEP_ID                => L_Step_id,
           P_EFFECTIVE_START_DATE   => l_Effective_Start_Date,
           P_EFFECTIVE_END_DATE     => L_Effective_End_Date);
       Else
          l_Date_track_Mode := hr_api.g_Insert;
          /* Insert Placements with the New Step Details */
          Hr_Sp_Placement_Api.CREATE_SPP
          (P_EFFECTIVE_DATE         => Nvl(l_Enrt_Cvg_Strt_Dt, P_Effective_Date),
           P_BUSINESS_GROUP_ID      => l_Business_Group_Id,
           P_ASSIGNMENT_ID          => L_Assignment_Id,
           P_STEP_ID                => l_Step_Id,
           P_PLACEMENT_ID           => l_PLACEMENT_ID,
           P_OBJECT_VERSION_NUMBER  => l_Placement_Ovn,
           P_REASON                 => 'GSP',
           P_EFFECTIVE_START_DATE   => l_Effective_Start_Date,
           P_EFFECTIVE_END_DATE     => L_Effective_End_Date);
       End If;
       Close Plcmt_Dtls;
   End If;
   Close Step_Dtls;

   if g_debug then
      hr_utility.set_location(' Leaving Assigmt Updates ', 30);
   End If;

End If;
Exception
When Others then

if g_debug then
   hr_utility.set_location(' Error ', 40);
End if;

Raise;
End Update_Assgmt_Info;


/**************************************************************************/
/***************************** Call PP from AUI ***************************/
/**************************************************************************/

Procedure Call_PP_From_AUI
(P_Errbuf                       OUT NOCOPY Varchar2,
 P_Retcode                      OUT NOCOPY Number,
 P_Effective_Date		IN  Varchar2,
 P_Approval_Status_Cd           IN  Varchar2,
 P_Elig_per_Elctbl_Chc_Id       IN  Number) Is


l_Error_Status	      	    varchar2(30);
-- L_PRTT_ENRT_RSLT_ID      Ben_PRTT_ENRT_RSLT_F.PRTT_ENRT_RSLT_ID%TYPE;
L_INV_NEXT_SAL_DATE_WARNING Boolean;
L_PROPOSED_SALARY_WARNING   Boolean;
L_APPROVED_WARNING	    Boolean;
L_PAYROLL_WARNING	    Boolean;
l_Error_Message             Varchar2(250);
L_Concurrent_Req_Id         Number(18);
l_Progression_Style         Ben_Pgm_F.Dflt_Step_Cd%TYPE;

L_Per_In_Ler_id             Ben_Per_In_ler.Per_In_Ler_Id%TYPE;
L_Pil_Ovn                   Ben_Per_In_ler.Object_Version_Number%TYPE;
l_PROCD_DT                  DATE;
l_STRTD_DT                  DATE;
l_VOIDD_DT                  Date;
L_Effective_Date            Date;
l_Per_In_ler_Stat_Cd        Ben_Per_In_Ler.Per_In_Ler_Stat_Cd%TYPE;
l_Error_Exists              Varchar2(1) := 'N';
l_conc_status               boolean;

l_ptnl_ler_for_per_id  ben_ptnl_ler_for_per.ptnl_ler_for_per_id%type;
l_ptnl_ler_for_per_ovn ben_ptnl_ler_for_per.object_version_number%type;

 cursor csr_ptnl_ler_dtls(p_per_in_ler_id in number)
 is
 select ptnl.ptnl_ler_for_per_id, ptnl.object_version_number
   from ben_per_in_ler per
       ,ben_ptnl_ler_for_per ptnl
  where per.per_in_ler_id = p_per_in_ler_id
    and per.ptnl_ler_for_per_id = ptnl.ptnl_ler_for_per_id;

 Cursor Elctbl is
 Select Elct.ELIG_PER_ELCTBL_CHC_ID, Pil.Person_Id, Pil.Per_In_Ler_id, Pil. Object_Version_Number,
        Elct.Enrt_Cvg_Strt_Dt, Pgm.Update_Salary_Cd, Pgm.Dflt_Step_Cd, Elct.Approval_Status_Cd, Person.Full_name
   From ben_Elig_Per_Elctbl_Chc Elct,
        Ben_Ler_F               Ler,
        Ben_Per_in_ler          Pil,
        Ben_Pgm_F               PGM,
        Per_All_People_F        Person
  where Ler.typ_Cd              = 'GSP'
    and L_Effective_Date
Between Ler.Effective_Start_Date
    and Ler.Effective_End_Date
    and Ler.Business_group_id       = Hr_general.get_Business_Group_id
    and Pil.Ler_Id                  = Ler.Ler_id
    and Pil.PER_IN_LER_STAT_CD      = 'STRTD'
    and Elct.Per_In_Ler_id          = Pil.Per_in_Ler_id
    and Elct.DFLT_FLAG              = 'Y'
    and ((P_Approval_Status_Cd       is NULL
    and Elct.Approval_Status_Cd     in ('PQH_GSP_A','PQH_GSP_R'))
    or  (Elct.Approval_Status_Cd     = P_Approval_Status_Cd))
    and Pgm.Pgm_Id                  = Elct.Pgm_Id
    and L_Effective_Date
Between Pgm.Effective_Start_Date
    and Pgm.Effective_End_Date
    and Person.Person_Id = Pil.Person_id
    and l_Effective_Date
Between Person.Effective_Start_Date
    and Person.Effective_End_Date
Order By Person.Full_name Desc;


Begin
L_Effective_Date := Fnd_Date.CANONICAL_TO_DATE(P_Effective_Date);
/* Initialise the Main Process Log */
L_Concurrent_Req_Id := fnd_global.conc_request_id;

Pqh_Gsp_process_Log.Start_log
(P_Txn_ID            =>  L_Concurrent_Req_Id
,P_Txn_Name          =>  Hr_general.Decode_lookup('PQH_GSP_GEN_PROMPTS','AUI') || L_Concurrent_Req_Id
,P_Module_Cd         =>  'PQH_GSP_APPROVAL_UI');

For Elctbl_Rec in Elctbl
Loop
Begin

 if g_debug then
    hr_utility.set_location(' Inside Apprival UI Call ' , 10);
    hr_utility.set_location(' Elctbl_Chc_Id : ' || Elctbl_Rec.ELIG_PER_ELCTBL_CHC_ID, 20);
 End if;

Savepoint Start_Enrlmnt;
/* Start Enrollment process */

/*
Pqh_gsp_Post_Process.Create_Enrollment
(P_Elig_Per_Elctbl_Chc_Id    =>  Elctbl_Rec.ELIG_PER_ELCTBL_CHC_ID
,P_Person_id		     =>  Elctbl_Rec.Person_Id
,P_Progression_Style	     =>  l_Progression_Style
,P_Effective_Date	     =>  Elctbl_Rec.Enrt_Cvg_Strt_Dt
,P_PRTT_ENRT_RSLT_ID	     =>  L_PRTT_ENRT_RSLT_ID
,P_Status                    =>  L_Error_Status); */

If Elctbl_Rec.Approval_Status_Cd = 'PQH_GSP_A' Then

   /* Update Employee Salary */
   if g_debug then
      hr_utility.set_location(' Approve ', 30);
   end if;

   pqh_gsp_Post_Process.Update_Assgmt_Info
   (P_ELIG_PER_ELCTBL_CHC_ID    =>  Elctbl_Rec.ELIG_PER_ELCTBL_CHC_ID
   ,P_Effective_Date            =>  Elctbl_Rec.Enrt_Cvg_Strt_Dt);

   if g_debug then
      hr_utility.set_location(' Update Salary ', 40);
   End If;

   /* If Update_Salary_Cd  is NO_UPDATE -- Salary Updateis not required.
      Hence will not make a call to Salary Update */

   If Elctbl_Rec.Update_Salary_Cd <> 'NO_UPDATE' Then
      pqh_gsp_Post_Process.Update_Salary_Info
      (P_ELIG_PER_ELCTBL_CHC_ID    =>  Elctbl_Rec.ELIG_PER_ELCTBL_CHC_ID
      ,P_Effective_Date            =>  Elctbl_Rec.Enrt_Cvg_Strt_Dt);
  End If;
  l_Per_In_ler_Stat_Cd := 'PROCD';
Else
  l_per_In_Ler_Stat_Cd := 'VOIDD';
End If;

L_Per_In_Ler_Id := Elctbl_Rec.Per_In_Ler_Id;
L_Pil_Ovn       := Elctbl_Rec.Object_Version_NUmber;

Ben_Person_Life_Event_api.UPDATE_PERSON_LIFE_EVENT
(P_PER_IN_LER_ID                   =>  l_PER_IN_LER_ID
,P_PER_IN_LER_STAT_CD              =>  l_Per_In_Ler_Stat_Cd
,P_PROCD_DT                        =>  L_PROCD_DT
,P_STRTD_DT                        =>  L_STRTD_DT
,P_VOIDD_DT                        =>  L_VOIDD_DT
,P_OBJECT_VERSION_NUMBER           =>  L_Pil_Ovn
,P_EFFECTIVE_DATE                  =>  L_Effective_Date);

open csr_ptnl_ler_dtls(l_per_in_ler_id);
fetch csr_ptnl_ler_dtls
 into l_ptnl_ler_for_per_id
     ,l_ptnl_ler_for_per_ovn ;
close csr_ptnl_ler_dtls ;

ben_ptnl_ler_for_per_api.update_ptnl_ler_for_per
  (p_ptnl_ler_for_per_id           => l_PTNL_LER_FOR_PER_ID
  ,p_ptnl_ler_for_per_stat_cd      => l_Per_In_Ler_Stat_Cd
  ,p_voidd_dt                      => l_effective_date
  ,p_object_version_number         => l_PTNL_LER_FOR_PER_OVN
  ,p_effective_date                => l_effective_date);

Pqh_Gsp_process_Log.Log_process_Dtls
(P_Master_txn_Id             =>  L_Concurrent_Req_Id
,P_Txn_Id                    =>  Elctbl_Rec.ELIG_PER_ELCTBL_CHC_ID
,p_module_cd        	     =>  'PQH_GSP_APPROVAL_UI'
,p_message_type_cd           =>  'C'
,p_message_text              =>  NULL
,P_Effective_Date            =>  L_Effective_Date);

Exception
When Others Then
Rollback to Start_Enrlmnt;
l_Error_Exists := 'Y';
-- l_Error_Message := Fnd_Message.Get;
if g_debug then
   hr_utility.set_location(' Error in AUI ', 50);
   hr_utility.set_location(' Error : ' || l_Error_Message, 60);
End If;

Pqh_Gsp_process_Log.Log_process_Dtls
(P_Master_txn_Id             =>  L_Concurrent_Req_Id
,P_Txn_Id                    =>  Elctbl_Rec.ELIG_PER_ELCTBL_CHC_ID
,p_module_cd        	     =>  'PQH_GSP_APPROVAL_UI'
,p_message_type_cd           =>  'E'
,p_message_text              =>  Nvl(Fnd_Message.Get,sqlerrm)
,P_Effective_Date            =>  L_Effective_Date);
End;
End Loop;

If l_Error_Exists = 'N' Then
   fnd_message.set_name('PQH','PQH_GSP_LOG_SUC');
   fnd_Message.Set_Token('MODULE',Hr_general.Decode_lookup('PQH_PROCESS_LOG_TREE','PQH_GSP_APPROVAL_UI'));
   fnd_file.put_line(fnd_file.log,Fnd_Message.get);
Else
   fnd_message.set_name('PQH','PQH_GSP_LOG_ERR');
   fnd_Message.Set_Token('MODULE',Hr_general.Decode_lookup('PQH_PROCESS_LOG_TREE','PQH_GSP_APPROVAL_UI'));
   fnd_file.put_line(fnd_file.log,Fnd_Message.get);
   l_conc_status := fnd_concurrent.set_completion_status(status => 'ERROR'
                                                         ,message=>SQLERRM);
End If;

PQH_PROCESS_BATCH_LOG.END_LOG;

Commit;

End Call_PP_From_AUI;

Procedure Call_Concurrent_Req_Aui
(P_Approval_Status_Cd  IN   Varchar2
,P_Req_Id              OUT  NOCOPY Varchar2) Is

l_Req_Id Number;
begin
l_Req_Id := -1;

l_Req_Id := fnd_request.submit_request
            (application => 'PQH'
            ,program     => 'PQHGSPPRCSAUI'
            ,argument1   => To_Char(Trunc(Sysdate),'rrrr-mm-dd')
            ,argument2   => P_Approval_Status_Cd);

P_Req_Id := l_req_id;

Exception When Others then
l_req_id := -1;
End;


Procedure Approve_Reject_AUI
(P_Elig_Per_Elctbl_Chc_id   IN   Number
,P_Prog_Dt                  IN   Date
,P_Sal_Chg_Dt               IN   Date
,P_Comments                 IN   Varchar2
,P_Approve_Rej              IN   Varchar2) Is

L_Enrt_Rt_Id   ben_Enrt_Rt.Enrt_Rt_Id%TYPE;
l_Enrt_ovn     ben_Enrt_Rt.Object_Version_Number%TYPE;

Cursor Enrt_Rt is
Select Enrt_Rt_Id,
       Object_Version_Number
  From Ben_Enrt_Rt
 Where Elig_per_Elctbl_Chc_Id = P_Elig_Per_Elctbl_Chc_id;

BEgin

If P_Approve_Rej = 'PQH_GSP_A' Then

   Open   Enrt_Rt;
   Fetch  Enrt_Rt into L_Enrt_Rt_Id, l_Enrt_ovn;
   Close  Enrt_Rt;

   Update Ben_Elig_per_elctbl_Chc
      Set Approval_Status_Cd = 'PQH_GSP_A'
         ,Enrt_Cvg_Strt_Dt   =  P_Prog_Dt
         ,Comments           =  P_Comments
    Where Elig_Per_Elctbl_Chc_Id = P_Elig_Per_Elctbl_Chc_id;

   If L_Enrt_Rt_Id is Not NULL and P_Sal_Chg_Dt is Not Null then
      Update Ben_Enrt_Rt
         Set Rt_Strt_Dt = P_Sal_Chg_Dt
       Where Enrt_Rt_Id = L_Enrt_Rt_Id;
   End If;

Elsif P_Approve_Rej = 'PQH_GSP_R' Then

  Update Ben_Elig_per_elctbl_Chc
     Set Approval_Status_Cd = 'PQH_GSP_R'
   Where Elig_Per_Elctbl_Chc_Id = P_Elig_Per_Elctbl_Chc_id;

End If;
End;

-- The following procedure  returns the current grade and grade ladder
-- of an assignment.
--
Procedure get_persons_gl_and_grade(p_person_id            in number,
                                   p_business_group_id    in number,
                                   p_effective_date       in date,
                                   p_persons_pgm_id      out nocopy number,
                                   p_persons_plip_id     out nocopy number,
                                   p_prog_style           out nocopy varchar2)
/*
************** Called from benmngle ********
*/

IS
-- Get assignment details for person from primary assignment.
Cursor csr_asg_details is
Select grade_ladder_pgm_id,grade_id
  From per_all_assignments_f
 Where person_id = p_person_id
   and primary_flag = 'Y'
   and assignment_type ='E'
   and p_effective_date between effective_start_date and effective_end_date;
--
Cursor csr_get_default_gl is
Select pgm_id,dflt_step_cd
  From ben_pgm_f
 Where business_group_id = p_business_group_id
   and pgm_typ_cd = 'GSP'
   and pgm_stat_cd = 'A'
   and nvl(dflt_pgm_flag,'N') = 'Y'
   and p_effective_date between effective_start_date and effective_end_date;
--
Cursor csr_pgm_details(p_pgm_id in number) is
Select dflt_step_cd
  From ben_pgm_f
 Where pgm_id = p_pgm_id
   and p_effective_date between effective_start_date and effective_end_date;
--
Cursor csr_grade_pl(p_grade_id in number) is
select pl_id
from ben_pl_f pl,ben_pl_typ_f pltyp
where pltyp.business_group_id = p_business_group_id
and pltyp.opt_typ_cd =  'GSP'
and p_effective_date between pltyp.effective_start_date and pltyp.effective_end_date
and pl.pl_typ_id = pltyp.pl_typ_id
and pl.business_group_id = p_business_group_id
and pl.mapping_table_name  = 'PER_GRADES'
and pl.mapping_table_pk_id = p_grade_id
and p_effective_date between pl.effective_start_date and pl.effective_end_date
and pl.pl_stat_cd = 'A';
--
Cursor csr_grade_plip(p_pl_id in number, p_pgm_id in number) is
select plip_id from ben_plip_f
 where pl_id = p_pl_id
   and pgm_id = p_pgm_id
   and business_group_id = p_business_group_id
   and p_effective_date between effective_start_date and effective_end_date
   and plip_stat_cd = 'A';

--
l_asg_gl        per_all_assignments_f.grade_ladder_pgm_id%type := NULL;
l_asg_grade     per_all_assignments_f.grade_id%type := NULL;
l_def_gl        ben_pgm_f.pgm_id%type := NULL;
l_dflt_step_cd  ben_pgm_f.dflt_step_cd%type := NULL;
l_grade_pl      ben_pl_f.pl_id%type := NULL;
l_grade_plip    ben_plip_f.plip_id%type := NULL;
--
Begin
  --
  hr_utility.set_location(' Entering get_persons_gl_and_grade', 10);
  p_persons_pgm_id := NULL;
  p_persons_plip_id := NULL;
  p_prog_style := NULL;
  --
  -- Fetch persons grade ladder and grade.
  --
  Open csr_asg_details;
  Fetch csr_asg_details into l_asg_gl, l_asg_grade;
  Close csr_asg_details;
  --
  -- No grade ladder on assignment.
  If l_asg_gl is null then
     --
     hr_utility.set_location('  No grade ladder on assignment', 20);
     Open csr_get_default_gl;
     Fetch csr_get_default_gl into l_def_gl,l_dflt_step_cd;
     Close csr_get_default_gl;
     --
     If l_def_gl IS NOT NULL then
       -- Default found. check if the persons grade belongs to the default GL.
       hr_utility.set_location('  Default GL found: '||to_char(l_def_gl), 30);
       If l_asg_grade IS NOT NULL then
          -- Find the plan corresponding to the grade and check if it belongs to the pgm.
          hr_utility.set_location('Assignment has grade:'||to_char(l_asg_grade), 40);
          Open csr_grade_pl(l_asg_grade);
          Fetch csr_grade_pl into l_grade_pl;
          Close csr_grade_pl;
          -- Find the plip for the plan
          If l_grade_pl is not null then
             --
             hr_utility.set_location('Found plan for grade:'||to_char(l_grade_pl), 50);
             Open csr_grade_plip (p_pgm_id => l_def_gl,p_pl_id => l_grade_pl);
             Fetch csr_grade_plip into l_grade_plip;
             Close csr_grade_plip;
             --
              If l_grade_plip is not null then
                 --
                 hr_utility.set_location('plip for grade is linked to default GL', 60);
                 p_persons_pgm_id := l_def_gl;
                 p_persons_plip_id := l_grade_plip;
                 p_prog_style := l_dflt_step_cd;
                 --
              End if; /** If l_grade_plip is not null **/
          End if; /** If l_grade_pl is not null **/
       End if; /** If l_asg_grade IS NOT NULL then **/
       --
     End if; /** l_def_gl IS NOT NULL **/
     --
  Else
     -- Persons assignment has a grade ladder.
     hr_utility.set_location('Person has grade ladder on assignment:'||to_char(l_asg_gl), 70);
     p_persons_pgm_id := l_asg_gl;

     If l_asg_grade is not null then
        -- Find the plan corresponding to the grade and check if it belongs to the pgm.
        hr_utility.set_location('Assignment has grade:'||to_char(l_asg_grade), 80);
        Open csr_grade_pl(l_asg_grade);
        Fetch csr_grade_pl into l_grade_pl;
        Close csr_grade_pl;
        -- Find the plip for the plan
        If l_grade_pl is not null then
           --
           hr_utility.set_location('Found plan for grade:'|| to_char(l_grade_pl), 90);
           Open csr_grade_plip (p_pgm_id => l_asg_gl,p_pl_id => l_grade_pl);
           Fetch csr_grade_plip into l_grade_plip;
           Close csr_grade_plip;
           --
           If l_grade_plip is not null then
              --
              hr_utility.set_location('plip for grade found:'|| to_char(l_grade_plip),100);
              p_persons_plip_id := l_grade_plip;
              --
              Open csr_pgm_details(p_pgm_id => l_asg_gl);
              Fetch csr_pgm_details into l_dflt_step_cd;
              Close csr_pgm_details;
              --
              p_prog_style := l_dflt_step_cd;
              --
            End if; /**  If l_grade_plip is not null **/
         End if; /**  If l_grade_pl is not null **/
     End if; /** If l_asg_grade is not null then **/
     --
  End if; /** If l_asg_gl is null then **/
  --
  hr_utility.set_location('Leaving get_persons_gl_and_grade',110);
  --
End get_persons_gl_and_grade;

/**************************************************************************/
/************************** GSP_RATE_SYNC**********************************/
/**************************************************************************/

Procedure gsp_rate_sync
(P_Effective_Date          IN Date
,p_per_in_ler_id           IN NUMBER
,p_person_id                 IN NUMBER
,p_assignment_id            IN NUMBER
)
/*
*********  Called from benmngle. Don't change the signature ********
*/
 is


 Cursor per_in_ler_dtls
 IS
 select ler_id,program_id,business_group_id
 from ben_per_in_ler
 where per_in_ler_id = p_per_in_ler_id;

 Cursor Person_Info
 Is
 Select Asgt.Business_Group_id,
        Asgt.Grade_Id , Asgt.pay_basis_id, Asgt.GRADE_LADDER_PGM_ID
   from Per_All_Assignments_f Asgt
  Where P_Effective_Date
Between Asgt.Effective_Start_Date
    and Asgt.Effective_End_Date
    and Asgt.Person_id = p_person_id
    And Asgt.assignment_id = p_assignment_id;

Cursor Ben_Grd_Dtls(P_Pgm_Id In Number, P_Grd_Id In Number) Is
 Select Pl.Pl_Id, plip.Plip_Id, Pgm.DFLT_STEP_CD,
        Pgm.UPDATE_SALARY_CD  , DFLT_ELEMENT_TYPE_ID
   from Ben_Pgm_F  Pgm,
        Ben_Pl_F   Pl,
        Ben_Plip_f Plip
  Where Pgm.Pgm_Id  = P_Pgm_Id
    and P_Effective_Date
Between Pgm.Effective_Start_Date
    and Pgm.Effective_End_Date
    and Pl.Mapping_table_Name  = 'PER_GRADES'
    and Pl.Mapping_Table_Pk_Id = P_Grd_Id
    and P_Effective_Date
Between Pl.Effective_Start_Date
    and Pl.Effective_End_Date
    and Plip.Pgm_Id = Pgm.Pgm_id
    and Plip.Pl_id  = Pl.Pl_Id
    and P_Effective_Date
Between Plip.Effective_Start_Date
    and Plip.Effective_End_Date;

 Cursor Step_Dtls
  Is
 Select Plcmt.Step_id, Step.Spinal_point_id
   From Per_Spinal_POint_Placements_f Plcmt,
        Per_Spinal_point_Steps_F Step
  Where Plcmt.Assignment_id = P_Assignment_Id
    and P_Effective_Date
Between Plcmt.Effective_Start_Date
    and plcmt.Effective_End_Date
    and Step.Step_id = Plcmt.Step_Id
    and P_Effective_Date
Between Step.Effective_Start_Date
    and Step.Effective_End_Date;

 Cursor Ben_Dtls(P_Pl_id In Number,
                 P_Point_id In Number) Is
 Select Oipl.Oipl_Id, Opt.Opt_Id
   From Ben_Opt_F  Opt,
        Ben_Oipl_F Oipl
  Where Opt.Mapping_table_name  = 'PER_SPINAL_POINTS'
    and Opt.mapping_table_Pk_Id = P_Point_id
    and P_Effective_Date
Between Opt.Effective_Start_Date
    and Opt.Effective_End_Date
    and Oipl.Pl_Id  = P_Pl_Id
    and Oipl.Opt_id = Opt.Opt_id
    and P_Effective_Date
Between Oipl.Effective_Start_Date
    and Oipl.Effective_End_Date;

 Cursor PlanType(p_business_group_id in number) is
 Select Pl_typ_Id
   From Ben_Pl_Typ_F
  Where Opt_typ_Cd = 'GSP'
    and P_Effective_Date
Between Effective_Start_Date
    and Effective_End_Date
    and business_group_id = p_business_group_id;


 CURSOR Elmt_Asgmnt_link (P_Element_Type_Id IN NUMBER) IS
 select 'Y'
   from pay_element_types_f   pet
       ,pay_element_links_f   pel
       ,pay_element_entries_f pee
  where Pet.Element_type_id  = P_Element_type_Id
    and p_Effective_date
Between pet.effective_start_date
    and pet.effective_end_date
    and Pel.Element_type_Id  = Pet.Element_type_Id
    and p_Effective_date
Between pel.effective_start_date
    and pel.effective_end_date
    and pee.element_link_id = pel.element_link_id
    and pee.assignment_id   = p_assignment_id
    and p_Effective_date
between pee.effective_start_date
    and pee.effective_end_date;

 Cursor Pl_Bas_rt(l_Pl_Id IN Number) Is
 Select ACTY_BASE_RT_ID, Rt_Typ_cd, Entr_Ann_Val_Flag
   From Ben_Acty_base_Rt_f
  where Pl_id   = l_Pl_Id
    and P_effective_Date
Between Effective_Start_Date
    and Effective_End_Date;

 Cursor Opt_Bas_Rt(l_Opt_Id IN Number) Is
 Select ACTY_BASE_RT_ID, Rt_Typ_cd, Entr_Ann_Val_Flag
   From Ben_Acty_Base_rt_f
  where Opt_Id = L_Opt_id
    and P_effective_Date
Between Effective_Start_Date
    and Effective_End_Date;

 Cursor Yr_Prd is
  Select Yr_Perd_id
    From Ben_Yr_Perd
   Where P_Effective_Date
 Between Start_Date and End_Date;

 Cursor Dflt_GrdLdr is
 Select Pgm_Id
   From Ben_PGM_F
  Where DFLT_PGM_FLAG = 'Y'
    and Pgm_Typ_Cd = 'GSP'
    and P_Effective_Date
Between Effective_Start_Date
    and Effective_End_Date
    and Business_Group_id = Hr_general.get_business_group_id;

L_PTNL_LER_FOR_PER_ID         Ben_Ptnl_Ler_For_Per.PTNL_LER_FOR_PER_ID%TYPE;
l_Ptnl_Ovn                    Ben_Ptnl_Ler_For_Per.Object_Version_Number%TYPE;
L_Pil_Ovn                     Ben_Per_In_Ler.Object_version_Number%TYPE;
L_BG_Id                       Per_All_Assignments_F.Business_Group_id%TYPE;
l_Grade_Id                    Per_Grades.Grade_Id%TYPE;
l_Pgm_Id                      Ben_Pgm_F.Pgm_Id%TYPE;
l_Step_Id                     Per_Spinal_Point_Steps_f.Step_Id%TYPE;
l_Point_id                    Per_Spinal_POints.Spinal_Point_Id%TYPE;
l_PROCD_DT                    DATE;
l_STRTD_DT                    DATE;
l_VOIDD_DT                    Date;
l_Step_Exists                 Varchar2(1) := 'N';
L_Pl_id                       Ben_Pl_F.Pl_Id%TYPE;
L_plip_Id                     Ben_PLip_F.Plip_Id%TYPE;
L_Oipl_Id                     Ben_Oipl_F.Oipl_Id%TYPE;
L_Elig_Per_Elctbl_Chc_Id      Ben_Elig_Per_Elctbl_Chc.Elig_Per_Elctbl_Chc_Id%TYPE;
L_Oipl_Elig_Per_Elctbl_Chc_Id Ben_Elig_Per_Elctbl_Chc.Elig_Per_Elctbl_Chc_Id%TYPE;
l_Pl_Typ_Id                   Ben_Pl_Typ_F.Pl_Typ_Id%TYPE;
l_Elctbl_Ovn                  Ben_Elig_Per_Elctbl_Chc.Object_version_Number%TYPE;
l_oipl_Elctbl_Ovn             Ben_Elig_Per_Elctbl_Chc.Object_version_Number%TYPE;
l_Prog_style                  Ben_Pgm_F.Enrt_Cd%TYPE;
L_Prog_opt                    Ben_Pgm_F.DFLT_STEP_CD%TYPE;
L_Elctbl_Flag                 Varchar2(1) := 'N';
L_Update_Salary_Cd            Ben_Pgm_F.Update_Salary_Cd%TYPE;
L_pay_basis_id                per_pay_bases.pay_basis_id%TYPE;
l_Dflt_Element_typ_Id         Ben_Pgm_F.DFLT_ELEMENT_TYPE_ID%TYPE;
L_Enrt_Rt_Id                  Ben_Enrt_Rt.Enrt_Rt_Id%TYPE;
l_Cur_Sal                     Ben_Enrt_Rt.Val%TYPE;
l_Rt_Typ_Cd                   Ben_Enrt_Rt.Rt_Typ_Cd%TYPE;
L_Rt_Elig_Per_Elctbl_Chc_Id   Ben_Elig_Per_Elctbl_Chc.Elig_Per_Elctbl_Chc_Id%TYPE;
L_Acty_Base_rt_Id             Ben_Acty_Base_Rt.Acty_Base_rt_Id%TYPE;
l_Enrt_Rt_Ovn                 Ben_Elig_Per_Elctbl_Chc.Object_version_Number%TYPE;
l_Opt_id                      Ben_Opt_F.Opt_Id%TYPE;
l_Entr_Ann_Val_Flag           Ben_Acty_Base_rt_F.Entr_Ann_Val_Flag%TYPE;
L_Lee_Rsn_Id                  Ben_Lee_Rsn_f.Lee_Rsn_Id%TYPE;
l_yr_perd_id                  ben_popl_yr_perd.yr_perd_id%TYPE;
L_popl_yr_perd_id             ben_popl_yr_perd.popl_yr_perd_id%TYPE;
l_start_date                  ben_yr_perd.start_date%TYPE;
l_end_date                    ben_yr_perd.end_date%TYPE;
l_Element_Link_Id             Pay_Element_Links_f.Element_Link_Id%TYPE;
l_Curr_Pl_Id                  Ben_Pl_F.Pl_Id%TYPE;
l_Curr_Oipl_Id                Ben_Oipl_F.Oipl_Id%TYPE;


Begin

g_debug := hr_utility.debug_enabled;
if g_debug then
   hr_utility.set_location(' Entering pqh_gsp_post_process.gsp_rate_sync ', 5);
   hr_utility.set_location(' Assgt_Id : ' || p_assignment_id, 10);
   hr_utility.set_location(' Person Id : ' || p_person_id, 20);
   hr_utility.set_location(' Per_In_Ler_Id : ' || p_per_in_ler_id, 30);
   hr_utility.set_location(' Effective_Date  : ' || P_Effective_Date, 40);
End if;

open per_in_ler_dtls;
fetch per_in_ler_dtls into L_Lee_Rsn_Id,l_Pgm_Id,l_bg_id;
close per_in_ler_dtls;
if g_debug then
   hr_utility.set_location(' Ler_Id : ' || L_Lee_Rsn_Id, 50);
   hr_utility.set_location(' Pgm Id : ' || l_pgm_id, 60);
   hr_utility.set_location(' bg_Id : ' || l_bg_id, 70);
End if;

Open  Person_Info;
Fetch Person_Info Into L_BG_Id , L_Grade_Id, L_pay_basis_id, l_Pgm_Id;
Close Person_Info;

if g_debug then
   hr_utility.set_location(' Pgm_Id : ' || l_Pgm_Id, 20);
   hr_utility.set_location(' Pay_basis_Id : ' || l_pay_basis_id, 80);
   hr_utility.set_location(' Grade Id : ' || l_grade_id, 90);
   hr_utility.set_location(' bg_Id : ' || l_bg_id, 100);
End if;

Open  Ben_Grd_Dtls(l_Pgm_Id, L_Grade_Id);
Fetch Ben_Grd_Dtls into L_Pl_id, l_plip_Id  , l_Prog_style, L_Update_Salary_Cd, l_Dflt_Element_typ_Id;
Close Ben_Grd_Dtls;

If l_Pl_Id Is Null Then
   /* Plan is not not linked to the corresponding Grade */
   fnd_message.set_name('PQH','PQH_GSP_PLN_NOTLNKD_TO_GRD');
   fnd_message.raise_error;
End If;

If l_Prog_style = 'PQH_GSP_NP' Then
   Return;
elsif l_Prog_style is NULL then
   fnd_message.set_name('PQH','PQH_GSP_PRGSTYLE_NOT_SET');
   fnd_message.raise_error;
End If;

If L_Update_Salary_Cd = 'SALARY_BASIS' and L_pay_basis_id is NULL Then
   /* Grade Ladder is defined for Salary basis and Pay Basis is not attached to the assignment */
   fnd_message.set_name('PQH','PQH_GSP_SALBSIS_NOT_LNKD');
   fnd_message.raise_error;

/*
ElsIf L_Update_Salary_Cd = 'SALARY_ELEMENT' then */

   /* Grade Ladder uses Salary Element, but Default Salary Element type is not defined */
/*   If l_Dflt_Element_typ_Id is NULL Then
      fnd_message.set_name('PQH','PQH_GSP_DFLT_ELMNT_NOTDFND');
      fnd_message.raise_error;
   End If;

   l_Element_Link_Id := hr_entry_api.get_link
                       (P_Assignment_id
                       ,l_Dflt_Element_typ_Id
                       ,P_Effective_Date);

   If l_Element_Link_Id is NULL Then
      fnd_message.set_name('PQH','PQH_GSP_ELMNT_NOT_LNKD');
      fnd_message.raise_error;
   End If;
 Cursor Step_Dtls(p_assignment_id in number) Is
 Select Plcmt.Step_id, Step.Spinal_point_id, Plcmt.Effective_Start_Date
   */

End If;


If l_Prog_style in ('PQH_GSP_SP','PQH_GSP_GSP','MINSALINCR','MINSTEP','NOSTEP') Then
   Open  Step_Dtls;
   Fetch Step_Dtls Into L_Step_Id, l_Point_id;
   Close Step_Dtls;
   /* Step not defined for Assignment */
   If l_Step_Id is NULL Then
      fnd_message.set_name('PQH','PQH_GSP_NO_STEP');
      fnd_message.raise_error;
   Else
      Open Ben_Dtls(L_Pl_id,
                    L_Point_Id);
      Fetch Ben_Dtls Into L_Oipl_Id, l_Opt_id;
      Close Ben_Dtls;
      If L_Oipl_Id is NULL then
         /* Oipl not linked to Step */
         fnd_message.set_name('PQH','PQH_GSP_OIPL_NOTLNKD_TO_STEP');
         fnd_message.raise_error;
      End If;
   End If;
   L_Elctbl_Flag := 'N';

   Open  Opt_Bas_rt(l_Opt_Id);
   Fetch Opt_Bas_Rt into l_ACTY_BASE_RT_ID, l_Rt_Typ_cd, l_Entr_Ann_Val_Flag;
   Close Opt_Bas_Rt;
   if g_debug then
      hr_utility.set_location(' l_Pgm_Id ' || l_Pgm_Id, 50);
      hr_utility.set_location(' L_Pl_id ' || L_Pl_id, 60);
      hr_utility.set_location(' l_Oipl_Id ' || l_Oipl_Id, 70);
      hr_utility.set_location(' L_Person_Id ' || p_Person_Id, 80);
   End if;
Else

   L_Elctbl_Flag := 'Y';
   Open  Pl_Bas_rt(l_Pl_Id);
   Fetch Pl_Bas_rt into l_ACTY_BASE_RT_ID, l_Rt_Typ_cd, l_Entr_Ann_Val_Flag;
   Close Pl_Bas_rt;

End If;


Open  Plantype(l_bg_id);
Fetch Plantype into l_Pl_Typ_Id;
Close Plantype;

/* Create Electable Choice Records */
/* For Grade */

if g_debug then
   hr_utility.set_location(' Attempting to create Elig_per ', 140);
   hr_utility.set_location(' Business_Group_Id :' || l_Bg_Id, 150);
end if;

 Open Yr_Prd;
Fetch Yr_Prd into l_Yr_Perd_Id;
Close Yr_Prd;

IF l_prog_style = 'PQH_GSP_GP' then

Ben_Elig_Per_Elc_Chc_Api.CREATE_PERF_ELIG_PER_ELC_CHC
(P_ELIG_PER_ELCTBL_CHC_ID       =>   L_Elig_Per_Elctbl_Chc_Id
,P_ENRT_CVG_STRT_DT_CD          =>   P_Effective_Date
,P_DFLT_FLAG                    =>   'Y'
,P_ELCTBL_FLAG                  =>   L_Elctbl_Flag
,P_PL_ID                        =>   l_Pl_Id
,P_PGM_ID                       =>   l_Pgm_Id
,P_PLIP_ID                      =>   l_plip_Id
,P_PGM_TYP_CD                   =>   'GSP'
,P_PL_TYP_ID                    =>   l_Pl_Typ_Id
,P_PER_IN_LER_ID                =>   p_PER_IN_LER_ID
,P_YR_PERD_ID                   =>   l_yr_perd_id
,P_Enrt_Cvg_Strt_Dt             =>   P_Effective_Date
,P_COMP_LVL_CD                  =>   'PLAN'   /* abparekh */
,P_LEE_RSN_ID                   =>   L_LEE_RSN_ID
,P_AUTO_ENRT_FLAG               =>   'Y'
,P_BUSINESS_GROUP_ID            =>   l_Bg_Id
,P_ELIG_FLAG                    =>   'N'
,P_OBJECT_VERSION_NUMBER        =>   l_Elctbl_Ovn
,P_EFFECTIVE_DATE               =>   P_Effective_Date);

 L_Rt_Elig_Per_Elctbl_Chc_Id := L_Elig_Per_Elctbl_Chc_Id;


if g_debug then
   hr_utility.set_location(' Created Elig_per for PLIP', 160);
   hr_utility.set_location(' L_Elig_Per_Elctbl_Chc_Id : ' || L_Elig_Per_Elctbl_Chc_Id, 170);
End If;

elsif l_Prog_style in ('PQH_GSP_SP','PQH_GSP_GSP','MINSALINCR','MINSTEP','NOSTEP') Then

   Ben_Elig_Per_Elc_Chc_Api.CREATE_PERF_ELIG_PER_ELC_CHC
   (P_ELIG_PER_ELCTBL_CHC_ID       =>   L_Oipl_Elig_Per_Elctbl_Chc_Id
   ,P_ENRT_CVG_STRT_DT_CD          =>   P_Effective_Date
   ,P_DFLT_FLAG                    =>   'Y'
   ,P_ELCTBL_FLAG                  =>   'Y'
   ,P_PL_ID                        =>   l_Pl_Id
   ,P_PGM_ID                       =>   l_Pgm_Id
   ,P_PLIP_ID                      =>   l_plip_Id
   ,P_OIPL_ID                      =>   l_Oipl_Id
   ,P_PGM_TYP_CD                   =>   'GSP'
   ,P_PL_TYP_ID                    =>   l_Pl_Typ_Id
   ,P_Enrt_Cvg_Strt_Dt             =>   P_Effective_Date
   ,P_YR_PERD_ID                   =>   l_yr_perd_id
   ,P_PER_IN_LER_ID                =>   p_PER_IN_LER_ID
   ,P_COMP_LVL_CD                  =>   'OIPL'
   ,P_LEE_RSN_ID                   =>   L_LEE_RSN_ID
   ,P_AUTO_ENRT_FLAG               =>   'Y'
   ,P_BUSINESS_GROUP_ID            =>   l_Bg_Id
   ,P_ELIG_FLAG                    =>   'N'
   ,P_OBJECT_VERSION_NUMBER        =>   l_Oipl_Elctbl_Ovn
   ,P_EFFECTIVE_DATE               =>   P_Effective_Date);

   L_Rt_Elig_Per_Elctbl_Chc_Id := L_Oipl_Elig_Per_Elctbl_Chc_Id;
if g_debug then
   hr_utility.set_location(' Created Elig_per for OIPL', 160);
   hr_utility.set_location(' L_Elig_Per_Elctbl_Chc_Id : ' || L_Elig_Per_Elctbl_Chc_Id, 170);
End If;

End If;
If L_Update_Salary_Cd is NULL Then
   fnd_message.set_name('PQH','PQH_GSP_POSTSTYL_NOT_SET');
   fnd_message.raise_error;
End If;
      if g_debug then
         hr_utility.set_location(' Determine Rates ', 190);
      End If;

      ben_env_object.init(p_business_group_id  => l_Bg_Id,
                          p_effective_date     => P_Effective_Date,
                          p_thread_id          => 1,
                          p_chunk_size         => 1,
                          p_threads            => 1,
                          p_max_errors         => 1,
                          p_benefit_action_id  => null);

      ben_env_object.setenv(P_LF_EVT_OCRD_DT  => P_Effective_Date);
      ben_env_object.g_global_env_rec.mode_cd := 'G';
      Ben_determine_rates.Main
      (P_EFFECTIVE_DATE               => P_Effective_Date
      ,P_LF_EVT_OCRD_DT               => P_Effective_Date
      ,P_PERSON_ID                    => p_Person_Id
      ,P_PER_IN_LER_ID                => p_PER_IN_LER_ID
      ,p_elig_per_elctbl_chc_id       => L_Rt_Elig_Per_Elctbl_Chc_Id);

Exception
When Others Then
Raise;
End gsp_rate_sync;

/**************************************************************************/
/************************** Update Rate Sync Salary. **********************/
/**************************************************************************/

Procedure Update_Rate_Sync_Salary
(P_per_in_ler_Id	IN 	Number
,P_Effective_Date	        IN	Date
) Is
/*
*********  Called from benmngle. Don't change the signature ********
*/
Cursor csr_elct_chcs
is
Select Elig_per_Elctbl_Chc_Id,COMP_LVL_CD,pgm_id
from Ben_ELig_per_Elctbl_Chc
where per_in_ler_id = p_per_in_ler_id;

Cursor csr_pil_dtls
IS
select object_version_number,PTNL_LER_FOR_PER_ID
from ben_per_in_ler
where per_in_ler_id = p_per_in_ler_id;

Cursor csr_ptnl_ler_dtls(p_PTNL_LER_FOR_PER_ID in number)
IS
select object_version_number
from ben_ptnl_ler_for_per
where PTNL_LER_FOR_PER_ID = p_PTNL_LER_FOR_PER_ID;




l_Pay_Proposal_Id	    Per_Pay_Proposals.Pay_Proposal_Id%TYPE;
L_Pay_Proposals_Ovn	    Per_Pay_Proposals.Object_version_Number%TYPE;
l_PTNL_LER_FOR_PER_ID  ben_ptnl_ler_for_per.PTNL_LER_FOR_PER_ID%TYPE;
l_PTNL_LER_FOR_PER_OVN ben_ptnl_ler_for_per.object_version_number%TYPE;
l_Rt_Ovn		    Ben_Prtt_Rt_Val.Object_Version_Number%TYPE;
l_salary		    Ben_Prtt_Rt_Val.Rt_Val%TYPE;
L_INV_NEXT_SAL_DATE_WARNING Boolean;
L_PROPOSED_SALARY_WARNING   Boolean;
L_APPROVED_WARNING	    Boolean;
l_salary_change_date date;
L_PAYROLL_WARNING	    Boolean;
l_Del_Warn                  Boolean;
L_ERROR_TEXT                Varchar2(250);
L_Update_Salary_Cd          Ben_Pgm_F.Update_Salary_Cd%TYPE;
L_DFLT_INPUT_VALUE_ID       Ben_Pgm_F.DFLT_INPUT_VALUE_ID%TYPE;
L_DFLT_ELEMENT_TYPE_ID      Ben_Pgm_F.DFLT_ELEMENT_TYPE_ID%TYPE;
l_Element_Link_Id           Pay_Element_Links_f.Element_Link_Id%TYPE;
L_Effective_Start_Date      pay_element_entries_f.Effective_Start_Date%TYPE;
L_Effective_End_Date        pay_element_entries_f.Effective_End_Date%TYPE;
L_Element_Entry_ID          pay_element_entries_f.Element_Entry_Id%TYPE;
L_Ele_Ovn                   pay_element_entries_f.Object_Version_Number%TYPE;
l_Create_Warn               Boolean;
l_DFLT_STEP_CD              Ben_Pgm_F.DFLT_STEP_CD%TYPE;
l_Change_Dt                 Per_Pay_proposals.Change_Date%TYPE;
l_Del_proposal_Id           Per_Pay_proposals.Pay_proposal_Id%TYPE;
l_Del_Proposal_Ovn          per_pay_Proposals.Object_version_Number%TYPE;
l_cur_sal number;
l_per_in_ler_ovn number;
l_procd_date date;
l_strtd_date date;
l_voidd_date date;
l_per_in_ler_id number;

l_ACTY_REF_PERD_CD    ben_pgm_f.ACTY_REF_PERD_CD%TYPE;
l_ANN_VAL   ben_enrt_rt.ann_val%TYPE;

l_payroll_annualization_factor per_time_period_types.number_per_fiscal_year%TYPE;
L_Payroll_name                 pay_all_payrolls_f.Payroll_name%TYPE;

 Cursor Enroll_Info(P_Elig_per_Elctbl_Chc_Id in number) is
 Select Rate.Val       , Rate.Rt_Strt_Dt, Rate.Prtt_Rt_Val_Id,
        Rate.Object_Version_Number, Enrt.Pgm_Id, Enrt.OiPl_Id,
        Asgt.Assignment_Id, Asgt.pay_basis_id, Asgt.Grade_Id, Enrt.Business_Group_id,Pil.per_in_ler_id, Rate.Ann_val
   From Ben_ELig_per_Elctbl_Chc  Enrt,
        ben_Enrt_Rt              Rate,
        Ben_Per_in_ler           PIL,
        Per_All_Assignments_F    Asgt
  Where Enrt.Elig_per_Elctbl_Chc_id = P_Elig_per_Elctbl_Chc_Id
    And Enrt.Per_In_Ler_id = Pil.Per_In_Ler_id
    And Asgt.Person_id = PIL.Person_id
    And P_Effective_Date
Between Asgt.Effective_start_Date and Asgt.Effective_end_Date
    and Enrt.Elig_per_Elctbl_Chc_id = Rate.Elig_per_Elctbl_Chc_id(+)
    and asgt.assignment_type ='E'
    And Asgt.PRIMARY_FLAG =  'Y';


CURSOR Element_Info(P_assignmnet_id number,P_pay_basis_id number, P_Effective_Date in DAte) IS
Select ele.element_entry_id
 from  per_pay_bases bas,
       pay_element_entries_f ele,
       pay_element_entry_values_f entval
 where bas.pay_basis_id = P_pay_basis_id
   and entval.input_value_id = bas.input_value_id
   and p_effective_date
between entval.effective_start_date
    and entval.effective_end_date
    and ele.assignment_id  = P_assignmnet_id
    and p_effective_date between ele.effective_start_date
    and ele.effective_end_date
    and ele.element_entry_id = entval.element_entry_id;

 Cursor Pgm_Dtl(P_Pgm_Id In Number) is
 Select Update_Salary_Cd, DFLT_INPUT_VALUE_ID, DFLT_ELEMENT_TYPE_ID, DFLT_STEP_CD,ACTY_REF_PERD_CD
   From ben_Pgm_F
  Where Pgm_id = P_Pgm_Id
    and P_effective_Date
Between Effective_Start_Date
    and Effective_End_Date;

 CURSOR Elmt_Entry (p_assignment_id IN NUMBER, P_Business_group_Id IN Number, p_Effective_Date IN Date) IS
 select pee.Element_Entry_Id, pee.Object_version_Number
   from pay_element_types_f   pet
       ,pay_element_links_f   pel
       ,pay_element_entries_f pee
  where Pet.Element_type_id  = L_DFLT_ELEMENT_TYPE_ID
    and p_Effective_date
Between pet.effective_start_date
    and pet.effective_end_date
    and Pel.Element_type_Id  = Pet.Element_type_Id
    and p_Effective_date
Between pel.effective_start_date
    and pel.effective_end_date
    and pee.element_link_id = pel.element_link_id
    and pee.assignment_id   = p_assignment_id
    and p_Effective_date
between pee.effective_start_date
    and pee.effective_end_date;

 Cursor Proposal_Dt (P_Assignment_Id   IN Number) is
 Select Max(Change_Date)
   from Per_Pay_Proposals
  Where Assignment_Id = P_Assignment_id;

  Cursor Proposal_Dtls (P_Assignment_Id in Number) is
  Select Pay_Proposal_Id, Object_Version_Number
    From Per_Pay_Proposals
   Where Change_Date   = l_Change_Dt
     and Assignment_id = P_Assignment_id;

  Cursor pay_basis_frequency (p_pay_basis_id in number)is
  select pay_basis,PAY_ANNUALIZATION_FACTOR
  from per_pay_bases
  where pay_basis_id =p_pay_basis_id;


L_Enroll_Info		    Enroll_Info%ROWTYPE;
L_DATE_TRACK_MODE           Varchar2(25);
l_def_elct_chc_id number;
l_plan_elct_chc_id number;
l_oipl_elct_chc_id number;
l_pgm_id number;
l_pay_basis per_pay_bases.PAY_BASIS%TYPE;
l_annualization_factor per_pay_bases.PAY_ANNUALIZATION_FACTOR%TYPE;
l_gl_ann_factor        ben_pgm_extra_info.pgi_information5%TYPE;

Begin

g_debug := hr_utility.debug_enabled;
if g_debug then
   hr_utility.set_location(' Entering pqh_gsp_post_process.update_rate_sync_salary ', 5);
   hr_utility.set_location(' Per_In_Ler_Id : ' || p_per_in_ler_id, 10);
   hr_utility.set_location(' Effective_Date  : ' || P_Effective_Date, 20);
End if;


for i in csr_elct_chcs loop
 if i.comp_lvl_cd = 'OIPL' then
  l_oipl_elct_chc_id := i.Elig_per_Elctbl_Chc_Id;
 else
  l_plan_elct_chc_id := i.Elig_per_Elctbl_Chc_Id;
 end if;
 l_pgm_id := i.pgm_id;
end loop;

OPen Pgm_Dtl(l_Pgm_Id);
Fetch Pgm_Dtl into L_Update_Salary_Cd, L_DFLT_INPUT_VALUE_ID, L_DFLT_ELEMENT_TYPE_ID, l_Dflt_Step_Cd,l_acty_ref_perd_cd;
Close Pgm_Dtl;

if l_Dflt_Step_cd = 'PQH_GSP_GP' then
l_def_elct_chc_id := l_plan_elct_chc_id;
else
l_def_elct_chc_id := l_oipl_elct_chc_id;
end if;


Open  Enroll_Info(l_def_elct_chc_id);
Fetch Enroll_Info into L_Enroll_Info;
Close Enroll_Info;

if g_debug then
   hr_utility.set_location(' Inside Salary Update: Elec_id :' ||l_def_elct_chc_id , 10);
   hr_utility.set_location(' L_Enroll_Info.Business_Group_Id :' || L_Enroll_Info.Business_Group_Id, 20);
   hr_utility.set_location(' L_Enroll_Info.OVN :' || L_Enroll_Info.Object_version_number, 30);
End If;

open csr_pil_dtls;
fetch csr_pil_dtls into l_per_in_ler_ovn, l_PTNL_LER_FOR_PER_ID;
close csr_pil_dtls;

open csr_ptnl_ler_dtls(l_PTNL_LER_FOR_PER_ID);
fetch csr_ptnl_ler_dtls into l_PTNL_LER_FOR_PER_OVN;
close csr_ptnl_ler_dtls;

If L_Enroll_Info.Val is NULL Then

If l_Dflt_Step_cd = 'NOSTEP' and L_Enroll_Info.Oipl_Id is NULL Then

   Return;

Else

   fnd_message.set_name('PQH','PQH_GSP_RAT_NOT_DFND');
   fnd_message.raise_error;

End If;
End If;


   l_Cur_Sal := Pqh_gsp_utility.Get_Cur_Sal
                (P_Assignment_id   => L_Enroll_Info.Assignment_Id
                ,P_Effective_Date  => P_Effective_date);

open pay_basis_frequency(L_Enroll_Info.pay_basis_id);
fetch pay_basis_frequency into l_pay_basis,l_annualization_factor;
close pay_basis_frequency;


l_gl_ann_factor := pqh_gsp_utility.get_gl_ann_factor(p_pgm_id => l_pgm_id);

hr_utility.set_location('l_gl_ann_factor is:' ||l_gl_ann_factor , 40);

    if l_gl_ann_factor is not null then

        l_ANN_VAL :=L_Enroll_Info.Val *to_number(l_gl_ann_factor);

    ELSIF (l_pay_basis = 'MONTHLY' AND l_ACTY_REF_PERD_CD = 'MO')
   OR (l_pay_basis = 'HOURLY' AND l_ACTY_REF_PERD_CD = 'PHR')
   OR (l_pay_basis = 'ANNUAL' AND l_ACTY_REF_PERD_CD = 'PYR') THEN

   l_ANN_VAL :=L_Enroll_Info.Val *l_annualization_factor;

   Else

   l_ANN_VAL := L_Enroll_Info.Ann_Val;

   end if;

if l_Ann_Val = l_cur_sal then
         Ben_Person_Life_Event_api.UPDATE_PERSON_LIFE_EVENT
        (P_PER_IN_LER_ID                   => p_PER_IN_LER_ID
        ,P_PER_IN_LER_STAT_CD              => 'VOIDD'
        ,P_PROCD_DT                        =>  l_procd_date
        ,P_STRTD_DT                        =>  l_strtd_date
        ,P_VOIDD_DT                        =>  l_voidd_date
        ,P_OBJECT_VERSION_NUMBER           =>  l_per_in_ler_ovn
        ,P_EFFECTIVE_DATE                  =>  P_Effective_Date);

         ben_ptnl_ler_for_per_api.update_ptnl_ler_for_per
   (p_ptnl_ler_for_per_id           => l_PTNL_LER_FOR_PER_ID
  ,p_ptnl_ler_for_per_stat_cd       => 'VOIDD'
  ,p_voidd_dt                       => p_effective_date
  ,p_object_version_number          => l_PTNL_LER_FOR_PER_OVN
  ,p_effective_date                 => p_effective_date);

else
l_salary := L_Enroll_Info.Val;
l_salary_change_date := L_Enroll_Info.Rt_Strt_Dt;

l_Salary := Pqh_Gsp_Utility.PGM_TO_BASIS_CONVERSION
           (P_Pgm_Id                       => L_Enroll_Info.Pgm_Id
           ,P_EFFECTIVE_DATE               => P_Effective_Date
           ,P_AMOUNT                       => l_Salary
           ,P_ASSIGNMENT_ID                => L_Enroll_Info.Assignment_Id);



If L_Update_Salary_Cd = 'SALARY_BASIS' Then
   If L_Enroll_Info.Pay_Basis_Id is NULL Then
      fnd_message.set_name('PQH','PQH_GSP_SALBSIS_NOT_LNKD');
      fnd_message.raise_error;
   End If;


   Open  Proposal_Dt(L_Enroll_Info.Assignment_Id);
   Fetch Proposal_Dt into l_Change_Dt;
   Close Proposal_Dt;

   if l_change_dt = l_salary_change_date then

         Open Proposal_Dtls(L_Enroll_Info.Assignment_Id);
        Fetch proposal_Dtls into l_Del_Proposal_Id, l_Del_Proposal_Ovn;
        Close Proposal_Dtls;

        if l_Del_Proposal_Id is Not NULL then

           Hr_Maintain_Proposal_Api.DELETE_SALARY_PROPOSAL
          (P_PAY_PROPOSAL_ID              =>   l_Del_proposal_Id
          ,P_BUSINESS_GROUP_ID           =>    L_Enroll_Info.Business_Group_Id
          ,P_OBJECT_VERSION_NUMBER       =>    l_Del_Proposal_Ovn
          ,P_SALARY_WARNING              =>    l_Del_Warn);

        End If;

        End if;

   Open  Element_Info(L_Enroll_Info.Assignment_Id, L_Enroll_Info.pay_basis_id, l_Enroll_Info.Rt_Strt_Dt);
   Fetch Element_Info Into L_Element_Entry_Id;
   Close Element_Info;

   Hr_Maintain_Proposal_Api.INSERT_SALARY_PROPOSAL
   (P_PAY_PROPOSAL_ID            =>  l_Pay_Proposal_Id
   ,P_ASSIGNMENT_ID              =>  L_Enroll_Info.Assignment_Id
   ,P_BUSINESS_GROUP_ID          =>  L_Enroll_Info.Business_Group_Id
   ,P_CHANGE_DATE                =>  L_Enroll_Info.RT_Strt_Dt
   ,P_PROPOSED_SALARY_N          =>  l_Salary
   ,P_OBJECT_VERSION_NUMBER      =>  L_Pay_Proposals_Ovn
   ,P_ELEMENT_ENTRY_ID           =>  L_Element_Entry_Id
   ,P_MULTIPLE_COMPONENTS        =>  'N'
   ,P_APPROVED                   =>  'Y'
   ,P_PROPOSAL_REASON            =>  'GSP'
   ,P_INV_NEXT_SAL_DATE_WARNING  =>  L_INV_NEXT_SAL_DATE_WARNING
   ,P_PROPOSED_SALARY_WARNING    =>  L_PROPOSED_SALARY_WARNING
   ,P_APPROVED_WARNING           =>  L_APPROVED_WARNING
   ,P_PAYROLL_WARNING            =>  L_PAYROLL_WARNING);

Elsif L_Update_Salary_Cd = 'SALARY_ELEMENT' Then

  If L_DFLT_INPUT_VALUE_ID is NULL or  L_DFLT_ELEMENT_TYPE_ID is NULL Then
     fnd_message.set_name('PQH','PQH_GSP_DFLY_ELMNT_NOT_LNKD');
     fnd_message.raise_error;
  End If;

  l_Element_Link_Id := hr_entry_api.get_link
                       (L_Enroll_Info.Assignment_Id
                       ,L_DFLT_ELEMENT_TYPE_ID
                       ,L_Enroll_Info.RT_Strt_Dt);

  if l_Element_Link_Id is NULL Then
     fnd_message.set_name('PQH','PQH_GSP_ELMNT_NOT_LNKD');
     fnd_message.raise_error;
  End If;

  If L_Enroll_Info.Val is NULL Then
     fnd_message.set_name('PQH','PQH_GSP_RAT_NOT_DFND');
     fnd_message.raise_error;
  End If;


  per_pay_proposals_populate.get_payroll(L_Enroll_Info.Assignment_Id
                                        ,L_Enroll_Info.RT_Strt_Dt
                                        ,l_Payroll_name
                                        ,l_payroll_annualization_factor);

  If L_Payroll_name is NULL Then
     fnd_message.set_name('PQH','PQH_GSP_PAYROLL_NOT_DFND');
     fnd_message.raise_error;
  End If;

  Open  Elmt_Entry(L_Enroll_Info.Assignment_Id, L_Enroll_Info.Business_Group_Id, L_Enroll_Info.Rt_Strt_Dt);
  Fetch Elmt_Entry into L_Element_Entry_ID, L_Ele_Ovn;
  If Elmt_Entry%Found Then

      L_DATE_TRACK_MODE  := DT_Mode
                           (P_EFFECTIVE_DATE        =>  L_Enroll_Info.RT_Strt_Dt
                           ,P_BASE_TABLE_NAME       =>  'PAY_ELEMENT_ENTRIES_F'
                           ,P_BASE_KEY_COLUMN       =>  'ELEMENT_ENTRY_ID'
                           ,P_BASE_KEY_VALUE        =>  L_Element_Entry_ID);

     Pay_Element_Entry_Api.UPDATE_ELEMENT_ENTRY
     (P_DATETRACK_UPDATE_MODE    =>  L_DATE_TRACK_MODE
     ,P_EFFECTIVE_DATE           =>  L_Enroll_Info.RT_Strt_Dt
     ,P_BUSINESS_GROUP_ID        =>  L_Enroll_Info.Business_Group_Id
     ,P_ELEMENT_ENTRY_ID         =>  L_ELEMENT_ENTRY_ID
     ,P_OBJECT_VERSION_NUMBER    =>  L_Ele_Ovn
     ,P_INPUT_VALUE_ID1          =>  L_DFLT_INPUT_VALUE_ID
     ,P_ENTRY_VALUE1             =>  L_Salary
     ,P_EFFECTIVE_START_DATE     =>  L_Effective_Start_Date
     ,P_EFFECTIVE_END_DATE       =>  L_Effective_End_Date
     ,P_UPDATE_WARNING           =>  l_Create_Warn);

  Else

      Pay_Element_Entry_Api.CREATE_ELEMENT_ENTRY
      (P_EFFECTIVE_DATE               =>   L_Enroll_Info.RT_Strt_Dt
      ,P_BUSINESS_GROUP_ID            =>   L_Enroll_Info.Business_Group_Id
      ,P_ASSIGNMENT_ID                =>   L_Enroll_Info.Assignment_Id
      ,P_ELEMENT_LINK_ID              =>   l_Element_Link_Id
      ,P_ENTRY_TYPE                   =>   'E'
      ,P_INPUT_VALUE_ID1              =>   L_DFLT_INPUT_VALUE_ID
      ,P_ENTRY_VALUE1                 =>   L_Salary
      ,P_EFFECTIVE_START_DATE         =>   L_Effective_Start_Date
      ,P_EFFECTIVE_END_DATE           =>   L_Effective_End_Date
      ,P_ELEMENT_ENTRY_ID             =>   L_Element_Entry_ID
      ,P_OBJECT_VERSION_NUMBER        =>   L_Ele_Ovn
      ,P_CREATE_WARNING               =>   l_Create_Warn);
   End If;
   Close Elmt_Entry;
Else
   Return;
End If; /* Update_Salary_Cd */
         Ben_Person_Life_Event_api.UPDATE_PERSON_LIFE_EVENT
        (P_PER_IN_LER_ID                   => p_PER_IN_LER_ID
        ,P_PER_IN_LER_STAT_CD              => 'PROCD'
        ,P_PROCD_DT                        =>  l_procd_date
        ,P_STRTD_DT                        =>  l_strtd_date
        ,P_VOIDD_DT                        =>  l_voidd_date
        ,P_OBJECT_VERSION_NUMBER           =>  l_per_in_ler_ovn
        ,P_EFFECTIVE_DATE                  =>  P_Effective_Date);
End if;

End Update_Rate_Sync_Salary;

--
Procedure call_from_webadi
(P_Elig_Per_Elctbl_Chc_id   IN   Number
,P_PROGRESSION_DATE         IN   Date
,P_Sal_Chg_Dt               IN   Date
,p_assignment_id            IN NUMBER
,p_proposed_rank            in number
,p_life_event_dt            in date
,p_grade_ladder_id          in number
,p_pl_id                    in number
,p_oipl_id                   in number
)
IS
l_temp_prog_date date;
l_temp_sal_chg_date date;
l_temp_proposed_rank number;
L_Enrt_Rt_Id   ben_Enrt_Rt.Enrt_Rt_Id%TYPE;
l_Enrt_ovn     ben_Enrt_Rt.Object_Version_Number%TYPE;

Cursor Enrt_Rt is
Select Enrt_Rt_Id,
       Object_Version_Number
  From Ben_Enrt_Rt
 Where Elig_per_Elctbl_Chc_Id = P_Elig_Per_Elctbl_Chc_id;

Begin
if g_debug then
   hr_utility.set_location(' Entering call_from_webadi',10);
   hr_utility.set_location(' P_Elig_Per_Elctbl_Chc_id ' || P_Elig_Per_Elctbl_Chc_id, 20);
   hr_utility.set_location(' P_PROGRESSION_DATE ' || P_PROGRESSION_DATE,30);
   hr_utility.set_location(' P_Sal_Chg_Dt ' || P_Sal_Chg_Dt, 40);
   hr_utility.set_location(' p_assignment_id ' || p_assignment_id, 50);
   hr_utility.set_location(' p_proposed_rank ' || p_proposed_rank, 60);
   hr_utility.set_location(' p_life_event_dt ' || p_life_event_dt,70);
   hr_utility.set_location(' p_grade_ladder_id ' || p_grade_ladder_id, 80);
   hr_utility.set_location(' p_pl_id ' || p_pl_id, 90);
   hr_utility.set_location(' p_oipl_id ' || p_oipl_id, 100);
End If;

    if p_progression_date < p_life_event_dt then
    fnd_message.set_name('PQH','PQH_GSP_APPRVL_PRGS_DT_CHK_ERR');
    fnd_message.raise_error();
    end if;
    if p_Sal_Chg_Dt < p_progression_date then
    fnd_message.set_name('PQH','PQH_GSP_APPRVL_SALCHG_DT_ERR');
    fnd_message.raise_error();
    end if;
   Open   Enrt_Rt;
   Fetch  Enrt_Rt into L_Enrt_Rt_Id, l_Enrt_ovn;
   Close  Enrt_Rt;

 pqh_rank_utility.update_proposed_rank
            (p_proposed_rank  => p_proposed_rank
            ,p_assignment_id  => p_assignment_id
            ,p_life_event_dt  => p_life_event_dt
            ,p_pgm_id         => p_grade_ladder_id
            ,p_pl_id          => p_pl_id
             );

   Update Ben_Elig_per_elctbl_Chc
      Set Enrt_Cvg_Strt_Dt   =  P_PROGRESSION_DATE
    Where Elig_Per_Elctbl_Chc_Id = P_Elig_Per_Elctbl_Chc_id;

   If L_Enrt_Rt_Id is Not NULL and P_Sal_Chg_Dt is Not Null then
      Update Ben_Enrt_Rt
         Set Rt_Strt_Dt = P_Sal_Chg_Dt
       Where Enrt_Rt_Id = L_Enrt_Rt_Id;
   End If;
   hr_utility.set_location(' Leaving call_from_webadi',10);
commit;
exception when others then
rollback;
raise;
End call_from_webadi;
--
END Pqh_Gsp_Post_Process;

/
