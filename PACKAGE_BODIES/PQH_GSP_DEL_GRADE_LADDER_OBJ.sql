--------------------------------------------------------
--  DDL for Package Body PQH_GSP_DEL_GRADE_LADDER_OBJ
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_GSP_DEL_GRADE_LADDER_OBJ" as
/* $Header: pqgspdel.pkb 120.0 2005/05/29 01:58 appldev noship $ */
--
--
--
-- The following function will process the plans that were already linked
-- to the program in BEN tables and which were unlinked fron the program as a part
-- of this transaction.
-- Deleted plip rows(table_alias = 'CPP') will have dml_operation set as 'DELETE'
--
Function unlink_plan_from_pgm (p_copy_entity_txn_id in number,
                               p_effective_date     in date,
                               p_datetrack_mode     in varchar2)
RETURN varchar2 is
--
Cursor csr_unlink_pln is
Select information1 plip_id,
       information2 effective_start_date,
       information3 effective_end_date,
       information4 business_group_id,
       information261 pl_id,
       information265 ovn
  From ben_copy_entity_results
 Where copy_entity_txn_id = p_copy_entity_txn_id
   And table_alias = 'CPP'
   And dml_operation = 'DELETE';
--   And information104 = 'UNLINK';
--
  Cursor csr_ben_plip (p_plip_id in Number) Is
  Select plip_Id,
         Effective_Start_Date, Effective_End_Date,
         Object_version_number
    From Ben_plip_F
   Where plip_id = p_plip_id
     and p_effective_date
 between Effective_Start_Date and Effective_End_Date;
--
l_plip_start_date ben_plip_f.effective_start_date%type;
l_plip_end_date   ben_plip_f.effective_end_date%type;
l_plip_id         ben_plip_f.plip_id%type;
l_plip_ovn        ben_plip_f.object_version_number%type;
--
l_eot date;
l_datetrack_mode varchar2(30);
--
Begin
--
l_eot := to_date('31/12/4712','dd/mm/yyyy');
hr_utility.set_location('Entering: unlink_plan_from_pgm',1);
hr_utility.set_location('cet is '||p_copy_entity_txn_id,2);
hr_utility.set_location('effdt is '||to_char(p_effective_date,'dd/mm/yyyy'),3);
--
  -- Select all the unlinked plip rows
  --
  For del_plip_rec in csr_unlink_pln loop
    --
    -- If an existing plan is attached as to the grade ladder as a part of this txn
    -- the plip record will be created , and when it is deleted,
    -- the plip_id will be null
    --
    hr_utility.set_location('rec found '||del_plip_rec.plip_id,6);
    If del_plip_rec.plip_id IS NOT NULL then
      --
      -- Determine the date-tracked mode to use when deleting the row. If no date-tracked
      -- mode is passed, the system will determine date-tracked mode to use when deleting
      -- by reading actual BEN table rows.
      --
        --
        hr_utility.set_location('dt mode passed '||p_datetrack_mode,7);
        If p_datetrack_mode IS NULL then
         --
         Open csr_ben_plip(del_plip_rec.plip_id);
         Fetch csr_ben_plip into l_plip_id,l_plip_start_date,l_plip_end_date,l_plip_ovn;
         Close csr_ben_plip;
         --
         if l_plip_end_date <> l_eot then
           hr_utility.set_location('not on last row ',15);
           l_datetrack_mode := 'FUTURE_CHANGE';
         else
           hr_utility.set_location('on last row ',20);
           l_datetrack_mode := 'DELETE';
         end if;
        --
        Else
          l_datetrack_mode := p_datetrack_mode;
        End if;
        hr_utility.set_location('dt mode used '||l_datetrack_mode,8);
        --
        ben_Plan_in_Program_api.delete_Plan_in_Program
          (p_plip_id                        => del_plip_rec.plip_id
          ,p_effective_start_date           => del_plip_rec.effective_start_date
          ,p_effective_end_date             => del_plip_rec.effective_end_date
          ,p_object_version_number          => del_plip_rec.ovn
          ,p_effective_date                 => p_effective_date
          ,p_datetrack_mode                 => l_datetrack_mode);
        --
        hr_utility.set_location('delete success '||l_plip_id,9);
      End if;
      --
    End loop;
    --
hr_utility.set_location('Leaving: unlink_plan_from_pgm',10);
--
Return 'SUCCESS';
--
Exception
  When Others Then
     hr_utility.set_location('Exception raised: unlink_plan_from_pgm'||l_plip_id,99);
     Return 'FAILURE';
End;
--
-------------------------------------------------------------------------------------
--
-- The following function will process the options that were already linked
-- to the plans in BEN tables and which were unlinked as a part
-- of this transaction.
-- Deleted oipl rows(table_alias = 'COP') will have dml_operation set as 'DELETE'
--
Function unlink_oipl_from_plan (p_copy_entity_txn_id in number,
                               p_effective_date     in date,
                               p_datetrack_mode     in varchar2)
RETURN varchar2 is
--
Cursor csr_unlink_opt is
Select information1 oipl_id,
       information2 effective_start_date,
       information3 effective_end_date,
       information4 business_group_id,
       information247 opt_id,
       information265 oipl_ovn
  From ben_copy_entity_results
 Where copy_entity_txn_id = p_copy_entity_txn_id
   And table_alias = 'COP'
   And dml_operation = 'DELETE';
--   And information104 = 'UNLINK';
--
  Cursor csr_ben_oipl (p_oipl_id in Number) Is
  Select oipl_id,
         Effective_Start_Date, Effective_End_Date,
         Object_version_number
    From Ben_oipl_F
   Where oipl_id = p_oipl_id
     and p_effective_date
 between Effective_Start_Date and Effective_End_Date;
--
l_oipl_start_date ben_oipl_f.effective_start_date%type;
l_oipl_end_date   ben_oipl_f.effective_end_date%type;
l_oipl_id         ben_oipl_f.oipl_id%type;
l_oipl_ovn        ben_oipl_f.object_version_number%type;
--
l_eot date;
l_datetrack_mode varchar2(30);
--
Begin
--
l_eot := to_date('31/12/4712','dd/mm/yyyy');
hr_utility.set_location('Entering: unlink_oipl_from_plan',5);
--
  -- Select all the unlinked oipl rows
  --
  For del_oipl_rec in csr_unlink_opt loop
      --
     hr_utility.set_location('checking oipl '||del_oipl_rec.oipl_id,6);
     hr_utility.set_location('checking oipl '||del_oipl_rec.oipl_ovn,7);
     If del_oipl_rec.oipl_id is not null then
      --
      -- Determine the date-tracked mode to use when deleting the row. If no date-tracked
      -- mode is passed, the system will determine date-tracked mode to use when deleting
      -- by reading actual BEN table rows.
      --
        If p_datetrack_mode IS NULL then
         --
         Open csr_ben_oipl(del_oipl_rec.oipl_id);
         Fetch csr_ben_oipl into l_oipl_id,l_oipl_start_date,l_oipl_end_date,l_oipl_ovn;
         Close csr_ben_oipl;
         --
         if l_oipl_end_date <> l_eot then
           hr_utility.set_location('not on last row ',15);
           l_datetrack_mode := 'FUTURE_CHANGE';
         else
           hr_utility.set_location('on last row ',20);
           l_datetrack_mode := 'DELETE';
         end if;
        --
        hr_utility.set_location('datetrack mode is '||l_datetrack_mode,7);
        --
        Else
          l_datetrack_mode := p_datetrack_mode;
        End if;
        --
        ben_Option_in_Plan_api.delete_Option_in_Plan
        (p_oipl_id                        => del_oipl_rec.oipl_id
        ,p_effective_start_date           => del_oipl_rec.effective_start_date
        ,p_effective_end_date             => del_oipl_rec.effective_end_date
        ,p_object_version_number          => del_oipl_rec.oipl_ovn
        ,p_effective_date                 => p_effective_date
        ,p_datetrack_mode                 => l_datetrack_mode);
        --
      End if;
      --
    End loop;
--
Return 'SUCCESS';
--
Exception
  When Others Then
     hr_utility.set_location('Exception raised: unlink_oipl_from_plan',99);
     Return 'FAILURE';
End;
--
-------------------------------------------------------------------------------------
Function Get_Prfl_Del_Eff_Dt (P_Cer_Id             In Number,
                              P_Copy_Entity_Txn_Id IN Number,
                              P_Effective_Date     IN Date) Return Date is

Cursor Csr_Tabl_Alias is
Select Obj.Table_Alias           , Obj.Dml_Operation,
       Obj.Gs_Parent_Entity_Result_Id
  From Ben_Copy_Entity_Results Cep,
       Ben_Copy_Entity_Results Epa,
       Ben_Copy_Entity_Results Obj
 Where Cep.Copy_Entity_Result_id = P_Cer_id
   and Epa.Copy_Entity_Result_id = Cep.GS_MIRROR_SRC_ENTITY_RESULT_ID
   and Obj.Copy_Entity_Result_id = Epa.GS_MIRROR_SRC_ENTITY_RESULT_ID;

Cursor  Csr_plip (P_Cpp_Cer_Id In Number)Is
Select  Information253 Grade_Id,
        Information255 Scale_Id
   from Ben_Copy_Entity_Results Cpp
  Where Copy_Entity_Txn_id    = P_Copy_Entity_Txn_Id
    and Copy_Entity_Result_Id = p_Cpp_Cer_Id
    and Table_Alias = 'CPP'
    and Result_type_Cd = 'DISPLAY';

 Cursor Csr_Hr_Scale (P_Grade_Id  in Number) Is
 Select Parent_Spine_Id
   From Per_Grade_Spines_F
  Where Grade_Id = P_grade_Id
    and P_Effective_Date
Between Effective_Start_Date
    and Effective_End_Date;

l_table_Alias       Ben_Copy_Entity_Results.table_Alias%TYPE;
l_Dml_operation     Ben_Copy_Entity_Results.Dml_operation%TYPE;
l_Plip_Cer_Id       Ben_Copy_Entity_Results.Copy_Entity_Result_id%TYPE;
l_Grade_Id          Per_Grades.Grade_Id%TYPE;
l_Scale_Id          Per_Parent_SPines.PARENT_SPINE_ID%TYPE;
l_Parent_Spine_Id   Per_Parent_SPines.PARENT_SPINE_ID%TYPE;
Begin

 Open Csr_Tabl_Alias;
Fetch Csr_Tabl_Alias Into l_table_Alias, l_Dml_operation, l_Plip_Cer_Id;
Close Csr_Tabl_Alias;

If l_table_Alias = 'COP' and  l_Dml_operation = 'DELETE' then

    Open Csr_plip(l_Plip_Cer_Id);
   Fetch Csr_plip Into l_Grade_Id, l_Scale_Id;
   Close Csr_plip;

    Open Csr_Hr_Scale(l_Grade_Id);
   Fetch Csr_Hr_Scale into l_Parent_Spine_Id;
   Close Csr_Hr_Scale;

   If Nvl(l_Parent_Spine_Id,-1) = Nvl(l_Scale_Id,-1) Then
      Return P_Effective_Date;
   Else
      Return P_Effective_Date -1;
   End If;

Else

  Return P_Effective_Date;

End If;

End Get_Prfl_Del_Eff_Dt;

--
-- The following function will process the elif prfl that were already linked
-- to the plans in BEN tables and which were unlinked as a part
-- of this transaction.
--
Function unlink_elig_prfl (p_copy_entity_txn_id in number,
                           p_effective_date     in date,
                           p_datetrack_mode     in varchar2)
RETURN varchar2 is
--
Cursor csr_delete_cep is
Select information1 cep_id,
       information2 effective_start_date,
       information3 effective_end_date,
       information4 business_group_id,
       information265 cep_ovn,
       Copy_Entity_Result_Id
  From ben_copy_entity_results
 Where copy_entity_txn_id = p_copy_entity_txn_id
   And table_alias = 'CEP'
   And dml_operation  ='DELETE';
--   And information104 = 'UNLINK';
--
  Cursor csr_ben_cep (p_prtn_elig_prfl_id in Number) Is
  Select prtn_elig_prfl_id,
         Effective_Start_Date, Effective_End_Date,
         Object_version_number
    From Ben_prtn_elig_prfl_f
   Where prtn_elig_prfl_id = p_prtn_elig_prfl_id
     and p_effective_date
 between Effective_Start_Date and Effective_End_Date;
--
Cursor csr_delete_epa is
Select information1 epa_id,
       information2 effective_start_date,
       information3 effective_end_date,
       information4 business_group_id,
       information265 epa_ovn,
       Copy_Entity_Result_id
  From ben_copy_entity_results
 Where copy_entity_txn_id = p_copy_entity_txn_id
   And table_alias = 'EPA'
   And dml_operation  ='DELETE';
--   And information104 = 'UNLINK';
--
  Cursor csr_ben_epa (p_prtn_elig_id in Number) Is
  Select prtn_elig_id,
         Effective_Start_Date, Effective_End_Date,
         Object_version_number
    From Ben_prtn_elig_f
   Where prtn_elig_id = p_prtn_elig_id
     and p_effective_date
 between Effective_Start_Date and Effective_End_Date;

 Cursor Csr_Epa_cer (P_Epa_Cer_Id IN Number) is
 Select Copy_Entity_Result_Id
   From Ben_Copy_Entity_Results
  Where Copy_Entity_Txn_Id             = P_Copy_Entity_Txn_Id
    and GS_MIRROR_SRC_ENTITY_RESULT_ID = P_Epa_Cer_id;
--
l_cep_start_date Ben_prtn_elig_prfl_f.effective_start_date%type;
l_cep_end_date   Ben_prtn_elig_prfl_f.effective_end_date%type;
l_cep_id         Ben_prtn_elig_prfl_f.prtn_elig_prfl_id%type;
l_cep_ovn        Ben_prtn_elig_prfl_f.object_version_number%type;
--
l_epa_start_date Ben_prtn_elig_f.effective_start_date%type;
l_epa_end_date   Ben_prtn_elig_f.effective_end_date%type;
l_epa_id         Ben_prtn_elig_f.prtn_elig_id%type;
l_epa_ovn        Ben_prtn_elig_f.object_version_number%type;
--
l_eot date;
l_datetrack_mode varchar2(30);
l_Effective_Date Date;
l_Cep_Cer        Ben_Copy_Entity_Results.Copy_Entity_Result_id%TYPE;
--
Begin
--
l_eot := to_date('31/12/4712','dd/mm/yyyy');
hr_utility.set_location('Entering: unlink_elig_prfl',5);
  --
  -- Select all the unlinked cep rows i.e eligibility profile is unlinked from a
  -- GSP object
  --

  For del_cep_rec in csr_delete_cep loop
      --
      l_Effective_Date := Get_Prfl_Del_Eff_Dt (del_Cep_Rec.Copy_Entity_Result_Id, p_copy_entity_txn_id, P_Effective_Date);

      If L_Effective_Date is NULL then
         l_Effective_Date := P_Effective_Date;
      End If;

     If del_cep_rec.cep_id is not null then
      --
      -- Determine the date-tracked mode to use when deleting the row. If no date-tracked
      -- mode is passed, the system will determine date-tracked mode to use when deleting
      -- by reading actual BEN table rows.
      --
        If p_datetrack_mode IS NULL then
         --
         Open csr_ben_cep(del_cep_rec.cep_id);
         Fetch csr_ben_cep into l_cep_id,l_cep_start_date,l_cep_end_date,l_cep_ovn;
         Close csr_ben_cep;
         --
         if l_cep_end_date <> l_eot then
           hr_utility.set_location('not on last row ',15);
           l_datetrack_mode := 'FUTURE_CHANGE';
         else
           hr_utility.set_location('on last row ',20);
           l_datetrack_mode := 'DELETE';
         end if;
        --
        Else
          l_datetrack_mode := p_datetrack_mode;
        End if;
        --
        ben_PRTN_ELIG_PRFL_api.delete_PRTN_ELIG_PRFL
        (
          p_validate              => false
         ,p_prtn_elig_prfl_id     => del_cep_rec.cep_id
         ,p_effective_start_date  => del_cep_rec.effective_start_date
         ,p_effective_end_date    => del_cep_rec.effective_end_date
         ,p_object_version_number => del_cep_rec.cep_ovn
         ,p_effective_date        => l_effective_date
         ,p_datetrack_mode        => l_datetrack_mode
        );
        --
      End if;
      --
    End loop;
  --
  --
  -- Select all the unlinked epa rows. EPA row is marked for delete when all profiles
  -- under a GSP object have been unlinked.
  --
  For del_epa_rec in csr_delete_epa loop
      --
       Open Csr_Epa_cer (del_epa_rec.Copy_Entity_Result_id);
      Fetch Csr_Epa_cer Into l_Cep_Cer;
      Close Csr_Epa_cer;

      l_Effective_Date := Get_Prfl_Del_Eff_Dt (l_Cep_Cer, p_copy_entity_txn_id, P_Effective_Date);
     If del_epa_rec.epa_id is not null then
      --
      -- Determine the date-tracked mode to use when deleting the row. If no date-tracked
      -- mode is passed, the system will determine date-tracked mode to use when deleting
      -- by reading actual BEN table rows.
      --
        If p_datetrack_mode IS NULL then
         --
         Open csr_ben_epa(del_epa_rec.epa_id);
         Fetch csr_ben_epa into l_epa_id,l_epa_start_date,l_epa_end_date,l_epa_ovn;
         Close csr_ben_epa;
         --
         if l_epa_end_date <> l_eot then
           hr_utility.set_location('not on last row ',25);
           l_datetrack_mode := 'FUTURE_CHANGE';
         else
           hr_utility.set_location('on last row ',30);
           l_datetrack_mode := 'DELETE';
         end if;
        --
        Else
          l_datetrack_mode := p_datetrack_mode;
        End if;
        --
        ben_Participation_Elig_api.delete_Participation_Elig
        (
          p_validate              => false
         ,p_prtn_elig_id          => del_epa_rec.epa_id
         ,p_effective_start_date  => del_epa_rec.effective_start_date
         ,p_effective_end_date    => del_epa_rec.effective_end_date
         ,p_object_version_number => del_epa_rec.epa_ovn
         ,p_effective_date        => l_effective_date
         ,p_datetrack_mode        => l_datetrack_mode
        );
        --
      End if;
      --
    End loop;
    --
hr_utility.set_location('Leaving: unlink_elig_prfl',10);
--
Return 'SUCCESS';
--
Exception
  When Others Then
     hr_utility.set_location('Exception raised: unlink_elig_prfl',99);
     Return 'FAILURE';
  --
End;
--
-------------------------------------------------------------------------------------
--
-- The following function deletes the options, marked for delete in the transaction
-- The deleted option rows will have dml_operation = 'DELETE'.

Function delete_option (p_copy_entity_txn_id in number,
                        p_effective_date     in date,
                        p_datetrack_mode     in varchar2)
RETURN varchar2 is
--
Cursor csr_delete_opt is
Select information1 opt_id,
       information2 effective_start_date,
       information3 effective_end_date,
       information4 business_group_id,
       information265 opt_ovn
  From ben_copy_entity_results
 Where copy_entity_txn_id = p_copy_entity_txn_id
   And table_alias = 'OPT'
   And dml_operation  ='DELETE';
--   And information104 = 'UNLINK';
--
  Cursor csr_ben_opt (p_opt_id in Number) Is
  Select opt_id,
         Effective_Start_Date , Effective_End_Date,
         Object_version_number
    From Ben_opt_F
   Where opt_id = p_opt_id
     and p_effective_date
 between Effective_Start_Date and Effective_End_Date
     and Mapping_table_name = 'PER_SPINAL_POINTS';

 Cursor csr_Pl_Opt_Type (P_Opt_Id IN Number) is
 Select Pl_typ_opt_Typ_Id,
        Effective_Start_Date,
	Effective_End_Date,
	Object_Version_Number
   from Ben_Pl_Typ_Opt_Typ_F
  Where Opt_Id = P_Opt_id
    and Pl_Typ_Opt_Typ_Cd = 'GSP';

 Cursor Csr_OIpl (P_Opt_id IN Number) Is
 Select Oipl_id
   From Ben_Oipl_F
  Where Opt_id = p_Opt_id;

--
l_opt_start_date    ben_opt_f.effective_start_date%type;
l_opt_end_date      ben_opt_f.effective_end_date%type;
l_opt_id            ben_opt_f.opt_id%type;
l_opt_ovn           ben_opt_f.object_version_number%type;
l_Oipl_Id           Ben_Oipl_F.Oipl_Id%TYPE;

--
--
l_Pl_Typ_Opt_Typ_Id   Ben_Pl_Typ_Opt_Typ_F.Pl_Typ_Opt_Typ_Id%TYPE;
l_opt_typ_Esd         Ben_Pl_Typ_Opt_Typ_F.Effective_Start_Date%TYPE;
l_Opt_Typ_Eed         Ben_Pl_Typ_Opt_Typ_F.Effective_End_Date%TYPE;
l_Opt_typ_Ovn         Ben_Pl_Typ_Opt_Typ_F.Object_Version_Number%TYPE;
--
l_eot date;
l_datetrack_mode varchar2(30);
--
Begin
--
l_eot := to_date('31/12/4712','dd/mm/yyyy');
hr_utility.set_location('Entering: delete_option',5);
--
  -- Select all the deleted opt rows.
  --
  For del_opt_rec in csr_delete_opt loop
      --
      -- When a point that is not used as step is brought to staging area, an option
      -- is created for it anyway, if the option does not already exist.
      -- When the point is deleted the option record will be marked
      -- delete but theere will be not opt_id as there is no record in BEN.
      --
      --
     If del_opt_rec.opt_id is not null then
      --
      -- Determine the date-tracked mode to use when deleting the row. If no date-tracked
      -- mode is passed, the system will determine date-tracked mode to use when deleting
      -- by reading actual BEN table rows.
      --
         --
          Open csr_ben_opt(del_opt_rec.opt_id);
          Fetch csr_ben_opt into l_opt_id,l_opt_start_date,l_opt_end_date, l_opt_ovn;
          Close csr_ben_opt;

          Open Csr_Oipl (l_opt_Id);
	 Fetch Csr_Oipl into l_Oipl_id;
	 If Csr_Oipl%NOTFOUND then
            --
	   If p_datetrack_mode IS NULL then
              if l_opt_end_date <> l_eot then
                 hr_utility.set_location('not on last row ',15);
                 l_datetrack_mode := 'FUTURE_CHANGE';
              else
                 hr_utility.set_location('on last row ',20);
                 l_datetrack_mode := 'DELETE';
               end if;
           --
           Else
             l_datetrack_mode := p_datetrack_mode;
           End if;

           --
	   -- Delete Pl_TYp_Opt_typ record
	    Open csr_Pl_Opt_Type(del_opt_rec.opt_id);
   	    Fetch csr_Pl_Opt_Type into l_Pl_Typ_Opt_Typ_Id, l_opt_typ_Esd, l_Opt_Typ_Eed, l_Opt_typ_Ovn;
	    Close csr_Pl_Opt_Type;


          If l_Pl_Typ_Opt_Typ_Id is NOT NULL then

   	      ben_plan_type_option_type_api.Delete_Plan_Type_Option_Type
	      (P_PL_TYP_OPT_TYP_ID            =>  l_Pl_Typ_Opt_Typ_Id
              ,P_EFFECTIVE_START_DATE         =>  l_opt_typ_Esd
              ,P_EFFECTIVE_END_DATE           =>  l_Opt_Typ_Eed
              ,P_OBJECT_VERSION_NUMBER        =>  l_Opt_typ_Ovn
              ,P_EFFECTIVE_DATE               =>  P_Effective_Date
              ,P_DATETRACK_MODE               =>  l_datetrack_mode);

             -- Delete Option

              ben_option_definition_api.delete_option_definition
              (p_opt_id                         => del_opt_rec.opt_id
              ,p_effective_start_date           => del_opt_rec.effective_start_date
              ,p_effective_end_date             => del_opt_rec.effective_end_date
              ,p_object_version_number          => del_opt_rec.opt_ovn
              ,p_effective_date                 => p_effective_date
              ,p_datetrack_mode                 => l_datetrack_mode);

	   End If;
           --
         End if;
        --
       End If; -- Csr_Oipl
       Close Csr_Oipl;
    End loop;
    --
hr_utility.set_location('Leaving: delete_option',10);
--
Return 'SUCCESS';
--
Exception
  When Others Then
     hr_utility.set_location('Exception raised: delete_option',99);
     Return 'FAILURE';
End;

----------------------------------------------------------------------------
--
-- This is the main function called before copying BEN objects from staging
-- tables to actual BEN tables
-- Returns either 'SUCCESS' or 'FAILURE'
--
Function delete_from_ben (p_copy_entity_txn_id in number,
                          p_effective_date     in date,
                          p_datetrack_mode     in varchar2)
RETURN varchar2 is
--
l_status varchar2(30);
--
Begin
--
l_status := 'SUCCESS';
hr_utility.set_location('Entering: delete_from_ben',5);
--
-- Delete from lowest level
-- 1) Delete elig profiles
--
l_status := unlink_elig_prfl(p_copy_entity_txn_id => p_copy_entity_txn_id,
                             p_effective_date     => p_effective_date,
                             p_datetrack_mode     => p_datetrack_mode);

if l_status = 'FAILURE' then
   hr_utility.set_location('Failed in deleting elig',15);
   Return 'FAILURE';
End if;
--
-- 2) Delete plip
--
l_status := unlink_plan_from_pgm (p_copy_entity_txn_id => p_copy_entity_txn_id,
                                  p_effective_date     => p_effective_date,
                                  p_datetrack_mode     => p_datetrack_mode);
if l_status = 'FAILURE' then
   hr_utility.set_location('Failed in deleting plip',30);
   Return 'FAILURE';
End if;
--
-- 3) Delete oipl
--
l_status := unlink_oipl_from_plan(p_copy_entity_txn_id => p_copy_entity_txn_id,
                                  p_effective_date     => p_effective_date,
                                  p_datetrack_mode     => p_datetrack_mode);
if l_status = 'FAILURE' then
   hr_utility.set_location('Failed in deleting oipl',20);
   Return 'FAILURE';
End if;
--
-- 4) Delete option
--
l_status := delete_option (p_copy_entity_txn_id => p_copy_entity_txn_id,
                           p_effective_date     => p_effective_date,
                           p_datetrack_mode     => p_datetrack_mode);
if l_status = 'FAILURE' then
   hr_utility.set_location('Failed in deleting opt',25);
   Return 'FAILURE';
End if;
--
hr_utility.set_location('Leaving: delete_from_ben',10);
--
Return 'SUCCESS';
--
End;
--
--
End pqh_gsp_del_grade_ladder_obj;

/
