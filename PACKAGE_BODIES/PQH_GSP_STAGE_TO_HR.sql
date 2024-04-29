--------------------------------------------------------
--  DDL for Package Body PQH_GSP_STAGE_TO_HR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_GSP_STAGE_TO_HR" as
/* $Header: pqgspshr.pkb 120.1.12010000.3 2009/04/10 12:09:48 lbodired ship $ */

g_package  Varchar2(30) := 'pqh_gsp_stage_to_hr.';

procedure update_lept_data(p_copy_entity_txn_id in number,
                           p_le_id              in number,
                           p_pt_id              in number) is
begin
   -- make sure plan type row exists so that plan copy can read it
   -- if no row doesnot exist, then we have to create it
   -- make sure ptip row also exists else, we have to create it
   -- do we need row in ben_opt_typ_pl_typ for plan copy
   begin
      update ben_copy_entity_results
      set information248 = p_pt_id
      where copy_entity_txn_id = p_copy_entity_txn_id
      and table_alias = 'PLN';
   exception
      when others then
         hr_utility.set_location('issue in updating PT',10);
         raise;
   end;
end update_lept_data;

function get_le_pt_name (p_cd in varchar2 )
return varchar2 is
   l_proc varchar2(72) := g_package||'get_le_pt_name';
   l_name varchar2(80) ;
begin
   select meaning into l_name
     from hr_lookups
    where lookup_type = 'PQH_GSP_LE_PT_NAME'
      and lookup_code = decode(p_cd,'PROG','PROG_LE'
                                   ,'SYNC','SYNC_LE'
                                   ,'PLAN','GSP_PT');
   return l_name ;
exception
   when others then
      hr_utility.set_location('issue in lookup ',10);
      raise;
end get_le_pt_name;

function create_life_event (p_business_group_id in number
                           ,p_copy_entity_txn_id in number
                           ,p_lf_evt_oper_cd    in varchar2
                           ,p_name              in varchar2)
return number is
   l_proc varchar2(72) := g_package||'create_life_event';
   l_start_of_time DATE:= pqh_gsp_utility.get_gsp_plntyp_str_date(p_business_group_id,p_copy_entity_txn_id);
   l_ler_id                number;
   l_effective_start_date  date;
   l_effective_end_date    date;
   l_object_version_number number;
begin
   hr_utility.set_location('Entering:'|| l_proc, 10);
   ben_Life_Event_Reason_api.create_Life_Event_Reason(
       p_ler_id                    =>  l_ler_id
      ,p_effective_start_date      =>  l_effective_start_date
      ,p_effective_end_date        =>  l_effective_end_date
      ,p_object_version_number     =>  l_object_version_number
      ,p_effective_date            =>  l_start_of_time
      ,p_name                      =>  p_name
      ,p_business_group_id         =>  p_business_group_id
      ,p_typ_cd                    =>  'GSP'
      ,p_lf_evt_oper_cd            =>  p_lf_evt_oper_cd
      ,p_ovridg_le_flag            =>  'N'
      ,p_CK_RLTD_PER_ELIG_FLAG     =>  'N'
      ,p_CM_APLY_FLAG              =>  'N'
      ,p_QUALG_EVT_FLAG            =>  'N'
   );
   return l_ler_id ;
end create_life_event ;

function create_plan_type (p_business_group_id  in number
                          ,p_copy_entity_txn_id in number
                          ,p_name               in varchar2)
return number is
   l_proc varchar2(72) := g_package||'create_plan_type';
   l_start_of_time DATE:= pqh_gsp_utility.get_gsp_plntyp_str_date(p_business_group_id,p_copy_entity_txn_id);
   l_pl_typ_id                 number;
   l_effective_start_date      date;
   l_effective_end_date        date;
   l_object_version_number     number;
begin
   hr_utility.set_location('Entering:'|| l_proc, 10);
   ben_plan_type_api.create_plan_type(
       p_pl_typ_id              => l_pl_typ_id
      ,p_effective_start_date   => l_effective_start_date
      ,p_effective_end_date     => l_effective_end_date
      ,p_object_version_number  => l_object_version_number
      ,p_effective_date         => l_start_of_time
      ,p_name                   => p_name
      ,p_business_group_id      => p_business_group_id
      ,p_opt_typ_cd             => 'GSP'
      ,p_pl_typ_stat_cd         => 'A'
      ,p_no_mx_enrl_num_dfnd_flag => 'N'
      ,p_no_mn_enrl_num_dfnd_flag => 'N'
   );
   return l_pl_typ_id;
end create_plan_type;

procedure setup_check(p_copy_entity_txn_id      in number
                     ,p_effective_date          in date
                     ,p_business_group_id       in number
                     ,p_status                 out nocopy varchar2
                     ,p_prog_le_created_flag   out nocopy varchar2
                     ,p_sync_le_created_flag   out nocopy varchar2
                     ,p_plan_tp_created_flag   out nocopy varchar2
                     ) is
   l_status  varchar2(30) ;
   l_ler_id number;
   l_ler_name varchar2(240);
   l_pt_id number;
   l_pt_name varchar2(240);
   l_start_of_time DATE:= pqh_gsp_utility.get_gsp_plntyp_str_date(p_business_group_id,p_copy_entity_txn_id);
   l_effective_start_date date ;
   l_le_pt_name varchar2(80) ;
   l_prog_le_created_flag varchar2(1) :='N' ;
   l_sync_le_created_flag varchar2(1) :='N' ;
   l_plan_tp_created_flag varchar2(1) :='N' ;


begin
   begin
      select ler_id,name,effective_start_date
        into l_ler_id,l_ler_name,l_effective_start_date
        from ben_ler_f
       where effective_end_date = hr_general.end_of_time
         and business_group_id = p_business_group_id
         and typ_cd ='GSP'
         and lf_evt_oper_cd ='PROG';
      hr_utility.set_location('life event '||substr(l_ler_name,1,40),10);

      if l_effective_start_date <> l_start_of_time then
         l_status := 'WRONG-DATE-PROG-LE' ;
      end if ;

   exception
      when no_data_found then
         hr_utility.set_location('No life event of GSP prog type exists',20);
         l_le_pt_name := get_le_pt_name ('PROG');
         l_ler_id := create_life_event (p_business_group_id,p_copy_entity_txn_id,'PROG',l_le_pt_name) ;
         l_prog_le_created_flag := 'Y';
      when too_many_rows then
         hr_utility.set_location('2 life event of GSP prog type exists',20);
         l_status := 'MANY-PROG-LE';
      when others then
         hr_utility.set_location('issue in Getting GSP PROG LE',20);
         l_status := 'PROG-LE-ERR';
   end;

   if l_status is null then
      begin
         select ler_id,name,effective_start_date
           into l_ler_id,l_ler_name,l_effective_start_date
           from ben_ler_f
          where effective_end_date = hr_general.end_of_time
            and business_group_id = p_business_group_id
            and typ_cd ='GSP'
            and lf_evt_oper_cd ='SYNC';
         hr_utility.set_location('life event '||substr(l_ler_name,1,40),10);

         if l_effective_start_date <> l_start_of_time then
            l_status := 'WRONG-DATE-SYNC-LE' ;
         end if ;

      exception
         when no_data_found then
            hr_utility.set_location('No life event of GSP sync type exists',20);
            l_le_pt_name := get_le_pt_name ('SYNC');
            l_ler_id := create_life_event (p_business_group_id,p_copy_entity_txn_id,'SYNC',l_le_pt_name) ;
            l_sync_le_created_flag := 'Y';
         when too_many_rows then
            hr_utility.set_location('2 life event of GSP sync type exists',20);
            l_status := 'MANY-SYNC-LE';
         when others then
            hr_utility.set_location('issue in Getting GSP SYNC LE',20);
            l_status := 'SYNC-LE-ERR';
      end;
   end if;

   if l_status is null then
      begin
         select pl_typ_id,name,effective_start_date
           into l_pt_id,l_pt_name,l_effective_start_date
           from ben_pl_typ_f
          where effective_end_date = hr_general.end_of_time
            and business_group_id = p_business_group_id
            and opt_typ_cd ='GSP'
            and pl_typ_stat_cd ='A';
         hr_utility.set_location('pl_typ name '||substr(l_pt_name,1,40),10);

      if l_effective_start_date <> l_start_of_time then
         l_status := 'WRONG-DATE-PT' ;
      end if ;

      exception
         when no_data_found then
            hr_utility.set_location('No PT of GSP ',20);
            l_le_pt_name := get_le_pt_name ('PLAN');
            l_pt_id := create_plan_type (p_business_group_id,p_copy_entity_txn_id,l_le_pt_name);
            l_plan_tp_created_flag := 'Y';
         when too_many_rows then
            hr_utility.set_location('many PT of GSP ',20);
            l_status := 'MANY-PT';
         when others then
            hr_utility.set_location('issue in Getting GSP PT ',20);
            l_status := 'PT-ERR';
      end;
   end if;

   if l_status is null then
      hr_utility.set_location('setup is fine, update staging area',10);
      update_lept_data(p_copy_entity_txn_id => p_copy_entity_txn_id,
                       p_le_id              => l_ler_id,
                       p_pt_id              => l_pt_id);
      p_prog_le_created_flag  := l_prog_le_created_flag;
      p_sync_le_created_flag  := l_sync_le_created_flag;
      p_plan_tp_created_flag  := l_plan_tp_created_flag;
   else
      p_status := l_status;
      hr_utility.set_location('control goes back with status'||l_status,10);
   end if;

end setup_check;

procedure delete_steps(p_grade_spine_id in number,
                       p_effective_date in date) is
   cursor csr_steps is
      select step_id,object_version_number,effective_start_date,effective_end_date
      from per_spinal_point_steps_f
      where grade_spine_id = p_grade_spine_id
      and p_effective_date between effective_start_date and effective_end_date;
   l_step_id number;
   l_step_ovn number;
   l_step_esd date;
   l_step_eed date;
begin
   for step_rec in csr_steps loop
      l_step_id := step_rec.step_id;
      l_step_ovn := step_rec.object_version_number;
      l_step_esd := step_rec.effective_start_date;
      l_step_eed := step_rec.effective_end_date;
      hr_utility.set_location('deleting step '||l_step_id,10);
      hr_utility.set_location('ovn '||l_step_ovn,15);
      hr_grade_step_api.delete_grade_step
      (p_validate               => FALSE
      ,p_effective_date         => p_effective_date
      ,p_datetrack_mode         => 'DELETE'
      ,p_step_id                => l_step_id
      ,p_object_version_number  => l_step_ovn
      ,p_effective_start_date   => l_step_esd
      ,p_effective_end_date     => l_step_eed
      );
      hr_utility.set_location('delete step complete'||l_step_id,20);
   end loop;
exception
   when others then
      hr_utility.set_location('steps could not be deleted',40);
      raise;
end delete_steps;

procedure delete_grade_spine(p_grade_spine_id  in number,
                             p_effective_date  in date,
			     P_Date_track_mode In Varchar2 Default 'DELETE') is
   l_gs_ovn number;
   l_gs_esd date;
   l_gs_eed date;
begin
   hr_utility.set_location('inside dele grade spine',10);
   begin
      select object_version_number,effective_start_date,effective_end_date
      into l_gs_ovn,l_gs_esd,l_gs_eed
      from per_grade_spines_f
      where grade_spine_id = p_grade_spine_id
      and p_effective_date between effective_start_date and effective_end_date;
   exception
      when others then
         hr_utility.set_location('issues in selecting grade spine',20);
         raise;
   end;
   hr_utility.set_location('grade spine id is'||p_grade_spine_id,10);
   hr_utility.set_location('grade spine ovn is'||l_gs_ovn,15);
   hr_grade_scale_api.delete_grade_scale
   (p_validate               => FALSE
   ,p_effective_date         => p_effective_date
   ,p_datetrack_mode         => P_Date_track_mode
   ,p_grade_spine_id         => p_grade_spine_id
   ,p_object_version_number  => l_gs_ovn
   ,p_effective_start_date   => l_gs_esd
   ,p_effective_end_date     => l_gs_eed
   );
exception
   when others then
      hr_utility.set_location('issues in deleting grade spine',40);
      raise;
end delete_grade_spine;

Procedure Delete_Step (p_copy_entity_txn_id in number,
                       p_effective_date     in date,
                       p_date_track_mode    in varchar2 default null) Is
--

l_Step_Id               Per_Spinal_Point_Steps_F.Step_Id%TYPE;
l_Effective_Start_Date  Per_Spinal_Point_Steps_F.Effective_Start_Date%TYPE;
l_Effective_End_Date    Per_Spinal_Point_Steps_F.Effective_End_Date%TYPE;
l_Step_Ovn              Per_Spinal_Point_Steps_F.Object_Version_Number%TYPE;
l_datetrack_mode        Varchar2(30);
l_Scale_Delete          Varchar2(1) := 'N';
l_Effective_Date        Date;
L_Hr_parent_Spine       Per_grade_Spines_F.Parent_Spine_Id%TYPE;
l_Hr_grade_Scale_id     Per_grade_Spines_F.Grade_Spine_Id%TYPE;
L_Esd                   Date;
l_Eed                   Date;
L_ZAP                   BOOLEAN;
L_DELETE                BOOLEAN;
L_FUTURE_CHANGE         BOOLEAN;
L_DELETE_NEXT_CHANGE    BOOLEAN;
l_Plcmt_Cnt             Number;
-- Bug7674132
l_Acty_Base_Rate_Ovn        ben_acty_base_rt_f.Object_version_Number%TYPE;
l_Acty_Base_Rate_Id         ben_acty_base_rt_f.Acty_Base_Rt_Id%TYPE;

 Cursor csr_Del_Oipl (P_Plip_Cer_Id IN Number) is
 Select information253 Step_id,
        information254 Step_Ovn
   From ben_copy_entity_results
  Where copy_entity_txn_id = p_copy_entity_txn_id
    And Gs_parent_entity_result_id = P_Plip_Cer_Id
    And table_alias = 'COP'
    And dml_operation = 'DELETE';

 Cursor Csr_Step_Dtl(P_Step_Id IN Number) is
 Select Effective_Start_Date,
        Effective_End_Date,
	Object_Version_Number
   From Per_Spinal_Point_Steps_F
  Where Step_Id = P_Step_Id
    and P_Effective_Date
Between Effective_Start_Date
    and Effective_End_Date;

 Cursor Csr_Stg_Grd_Scale is
 Select Copy_Entity_Result_id,
        Information253 Grade_Id,
        Information255 Scale_Id,
	Information258 Scale_Cer_Id
   from Ben_Copy_Entity_Results Cpp
  Where Copy_Entity_Txn_id = P_Copy_Entity_Txn_Id
    and Table_Alias = 'CPP'
    and Result_type_Cd = 'DISPLAY'
    and Exists
    (Select 1
       from Ben_Copy_Entity_Results
      Where Copy_Entity_txn_id = P_Copy_Entity_Txn_id
        and Gs_parent_Entity_Result_id = CPP.Copy_Entity_Result_id
	and Table_Alias = 'COP'
	and Dml_Operation = 'DELETE');

 Cursor Csr_Hr_Scale (P_Grade_Id  in Number) Is
 Select Parent_Spine_Id     , Grade_Spine_Id,
        Effective_Start_Date, Effective_End_Date
   From Per_Grade_Spines_F
  Where Grade_Id = P_grade_Id
    and P_Effective_Date
Between Effective_Start_Date
    and Effective_End_Date;

 Cursor Csr_Del_Scle (P_Scale_Cer_id IN Number) is
 Select 'N'
   From Ben_Copy_Entity_Results Opt
  Where Opt.Copy_Entity_txn_id = P_Copy_Entity_txn_id
    and Opt.Table_Alias = 'OPT'
    and Information256 = P_Scale_Cer_Id
    and Nvl(Dml_Operation,'XX') <> 'DELETE';

-- Bug7674132
cursor Acty_Rts is
select information1 Acty_Base_Rt_id
from ben_copy_entity_results
where Copy_Entity_Txn_Id = P_Copy_Entity_Txn_Id
and table_alias like 'ABR'
And dml_operation = 'DELETE';

Cursor Acty_Rt_Nam_Dtl (Acty_Rate_Id IN NUMBER) is
Select  Acty_Base_Rt_Id, Object_version_Number
From  ben_acty_base_rt_f
Where   Acty_Base_Rt_Id = Acty_Rate_Id;

Begin

For Stg_Rec In Csr_Stg_Grd_Scale
Loop

   l_Scale_Delete := 'N';
   l_Datetrack_Mode := P_Date_Track_Mode;

    Open Csr_Hr_Scale(Stg_rec.Grade_id);
   Fetch Csr_Hr_Scale Into L_Hr_parent_Spine, l_Hr_grade_Scale_id, L_Esd, l_Eed;
   Close Csr_Hr_Scale;

   If Nvl(Stg_Rec.Scale_id,-1) = Nvl(L_Hr_parent_Spine,-1) then

       Open Csr_Del_Scle (Stg_rec.Scale_Cer_id);
      Fetch Csr_Del_Scle into l_Scale_Delete;
      If Csr_Del_Scle%FOUND Then
         l_Scale_Delete := 'N';
         l_Effective_Date := P_Effective_Date;
         -- l_Datetrack_Mode := 'DELETE';
      Else
         l_Scale_Delete := 'Y';
         l_Effective_Date := P_Effective_Date;
      End If;
      Close Csr_Del_Scle;
   Else

      L_ZAP                   := FALSE;
      L_DELETE                := FALSE;
      L_FUTURE_CHANGE         := FALSE;
      L_DELETE_NEXT_CHANGE    := FALSE;

      l_Scale_Delete := 'Y';
      l_Effective_Date := (P_Effective_Date - 1);

  End If;

  Dt_Api.FIND_DT_DEL_MODES
  (P_EFFECTIVE_DATE           => l_Effective_Date
  ,P_BASE_TABLE_NAME          => 'PER_GRADE_SPINES_F'
  ,P_BASE_KEY_COLUMN          => 'GRADE_SPINE_ID'
  ,P_BASE_KEY_VALUE           => l_Hr_grade_Scale_id
  ,P_ZAP                      => L_ZAP
  ,P_DELETE                   => L_DELETE
  ,P_FUTURE_CHANGE            => L_FUTURE_CHANGE
  ,P_DELETE_NEXT_CHANGE       => L_DELETE_NEXT_CHANGE);

  If l_Datetrack_Mode = 'DELETE' then

      IF L_DELETE THEN

	 l_Datetrack_Mode := 'DELETE';

      ElsIf L_FUTURE_CHANGE Then

         l_Datetrack_Mode := 'FUTURE_CHANGE';

      ElsIf L_DELETE_NEXT_CHANGE Then

         l_Datetrack_Mode := 'DELETE_NEXT_CHANGE';

      Elsif L_ZAP Then

         l_Datetrack_Mode := 'ZAP';

      End If;

  ElsIf l_Datetrack_Mode = 'ZAP' then

       IF L_ZAP THEN

	 l_Datetrack_Mode := 'ZAP';

      Elsif L_DELETE Then

         l_Datetrack_Mode := 'DELETE';

      ElsIf L_FUTURE_CHANGE Then

         l_Datetrack_Mode := 'FUTURE_CHANGE';

      ElsIf L_DELETE_NEXT_CHANGE Then

         l_Datetrack_Mode := 'DELETE_NEXT_CHANGE';

      End If;

  End If;

  If l_Datetrack_Mode = 'ZAP' then

     Select Count(Placement_Id)
       into l_Plcmt_Cnt
       from Per_Spinal_POint_Placements_f
      Where Step_Id in
    (Select Step_Id
       from Per_Spinal_Point_Steps_f
      Where Grade_Spine_id = L_hr_Grade_Scale_id);

    If l_Plcmt_Cnt <> 0 Then
       l_Datetrack_Mode := 'DELETE';
    End If;

  End If;

   If l_DateTrack_Mode is Not NULL then

   -- If L_Scale_Delete = 'N' then
      For Oipl_Rec in Csr_Del_Oipl(Stg_Rec.Copy_Entity_Result_id)
      Loop
      If Oipl_Rec.Step_id is  NOT NULL Then

         Open Csr_Step_Dtl(Oipl_Rec.Step_id);
         Fetch Csr_Step_Dtl into l_Effective_Start_Date, l_Effective_End_Date, l_Step_Ovn;
         If Csr_Step_Dtl%NOTFOUND Then
            hr_utility.set_location('Invalid Step Id ..  ',10);
            Close Csr_Step_Dtl;
            Return;
         End If;
         Close Csr_Step_Dtl;
         hr_utility.set_location('Effective Date..  ' || l_Effective_Date,10);
         hr_grade_step_api.delete_grade_step
         (p_validate               => FALSE
         ,p_effective_date         => L_effective_date
         ,p_datetrack_mode         => L_DateTrack_Mode
         ,p_step_id                => Oipl_Rec.Step_id
         ,p_object_version_number  => l_step_ovn
         ,p_effective_start_date   => l_Effective_Start_Date
         ,p_effective_end_date     => l_Effective_End_Date);

      End If;
      End Loop;
   -- End if;

      If L_Scale_Delete = 'Y' then
         delete_grade_spine(L_hr_Grade_Scale_id,
                            L_effective_date,
                            L_Datetrack_Mode);
	--Bug 7674132
	For Acty_Rt_Rec in Acty_Rts
	Loop
	  open Acty_Rt_Nam_Dtl( Acty_Rt_Rec.Acty_Base_Rt_id);
	  Fetch  Acty_Rt_Nam_Dtl into  l_Acty_Base_Rate_Id,  l_Acty_Base_Rate_Ovn;
	  Close Acty_Rt_Nam_Dtl;
	  BEN_ACTY_BASE_RATE_API.DELETE_ACTY_BASE_RATE(
	  p_acty_base_rt_id           =>   l_Acty_Base_Rate_Id
	  ,p_effective_start_date      =>   l_effective_start_date
	  ,p_effective_end_date        =>   l_effective_end_date
	  ,p_object_version_number     =>   l_Acty_Base_Rate_Ovn
	  ,p_effective_date            =>   p_effective_date
	  ,p_datetrack_mode            =>   p_date_track_mode );
	End loop;
      End If;
   End If;
End Loop;

End Delete_Step;


Function Delete_Rate (p_copy_entity_txn_id in number,
                      p_effective_date     in date)

Return Varchar2 Is


 Cursor Csr_Pay_Rts is
 Select Distinct Information293 Rt_Id
   From Ben_Copy_Entity_results
 Where  Copy_Entity_Txn_Id = P_Copy_Entity_Txn_Id
   and  Table_Alias = 'HRRATE'
   and  Dml_operation = 'DELETE';

 Cursor Csr_Hr_Rt (P_Rat_Name_id IN Number) is
 Select Information1,
        Information2,
        Information3,
        Information298
  From  Ben_Copy_Entity_results
 Where  Copy_Entity_Txn_Id = P_Copy_Entity_Txn_Id
   and  Table_Alias = 'HRRATE'
   and  Dml_operation = 'DELETE'
   and  Information293 = P_Rat_Name_Id;

  Cursor Rt_Nam_Dtl (P_Rate_Id IN NUMBER) is
  Select Rate_Id, Rate_type, Object_version_Number
    From Pay_rates
   Where Rate_Id = P_Rate_Id
   and Not Exists
   (Select 1
      from Ben_Copy_Entity_results
     Where Copy_Entity_Txn_Id = P_Copy_Entity_Txn_Id
       and Table_Alias = 'HRRATE'
       and Nvl(Dml_operation,'XX') <> 'DELETE'
       and Information293 = P_Rate_Id);

   L_Hr_Rt_Esd        Ben_Acty_Vrbl_Rt_F.Effective_Start_Date%TYPE;
   L_Hr_Rt_Eed        Ben_Acty_Vrbl_Rt_F.Effective_End_Date%TYPE;
   l_Hr_RT_Ovn        Ben_Acty_Vrbl_Rt_F.Object_version_Number%TYPE;

   l_Rate_type        Pay_Rates.Rate_Type%TYPE;
   l_Rate_Ovn         PAy_rates.Object_version_Number%TYPE;
   l_rate_Id          Pay_rates.Rate_Id%TYPE;
Begin

For Rt_Rec In Csr_Pay_Rts
Loop

    For Hr_Rate_rec in Csr_Hr_Rt(Rt_Rec.Rt_Id)
    Loop

    hr_utility.set_location('Delete HR Rate' || Hr_Rate_Rec.Information1 ,20);
      If Hr_Rate_Rec.Information1 is NOT NULL then

         l_Hr_Rt_Ovn := Hr_rate_Rec.Information298;

         Hr_Rate_Values_Api.DELETE_RATE_VALUE
        (P_GRADE_RULE_ID                => Hr_Rate_Rec.Information1
        ,P_DATETRACK_MODE               => 'ZAP'
        ,P_EFFECTIVE_DATE               => P_Effective_Date
        ,P_OBJECT_VERSION_NUMBER        => l_Hr_Rt_Ovn
        ,P_EFFECTIVE_START_DATE         => l_Hr_Rt_Esd
        ,P_EFFECTIVE_END_DATE           => l_Hr_Rt_Eed);

      End If;
    End Loop;

    l_Rate_type := NULL;
    L_rate_Ovn  := NULL;
    l_rate_Id   := NULL;

     Open Rt_Nam_Dtl (Rt_Rec.Rt_id);
    Fetch Rt_Nam_Dtl into l_rate_Id, l_Rate_type, L_rate_Ovn;
    Close Rt_Nam_Dtl;

    hr_utility.set_location('Delete HR Rate Name ' || l_Rate_Id ,10);
    If l_Rate_Id is NOT NULL Then

       hr_rate_api.DELETE_RATE
      (P_EFFECTIVE_DATE               =>  P_Effective_Date
      ,P_RATE_ID                      =>  l_Rate_Id
      ,P_RATE_TYPE                    =>  l_rate_type
      ,P_OBJECT_VERSION_NUMBER        =>  L_Rate_Ovn);

    End If;
End Loop;
Return 'SUCCESS';

Exception When Others Then
  Return 'FAILURE';
End Delete_Rate;

Function delete_option (p_copy_entity_txn_id in number,
                        p_effective_date     in date)

RETURN varchar2 is
--
Cursor csr_delete_opt is
Select information1 opt_id,
       information2 effective_start_date,
       information3 effective_end_date,
       information4 business_group_id,
       information265 opt_ovn,
       information257  point_id    --bug#8392638
  From ben_copy_entity_results
 Where copy_entity_txn_id = p_copy_entity_txn_id
   And table_alias = 'OPT'
   And dml_operation  ='DELETE';
--   And information104 = 'UNLINK';
--
  Cursor csr_ben_opt (p_opt_id in Number) Is
  Select Mapping_Table_Pk_Id
    From Ben_opt_F
   Where opt_id = p_opt_id
     and p_effective_date
 between Effective_Start_Date and Effective_End_Date
     and Mapping_table_name = 'PER_SPINAL_POINTS';


 Cursor Csr_Spinal_Point (P_Point_id IN Number) is
 Select parent_spine_Id, Object_version_Number
   from Per_Spinal_Points
  Where Spinal_Point_Id = P_Point_id;

 Cursor Csr_Step (P_Point_id IN Number) Is
 Select Step_id
   From Per_Spinal_Point_Steps_F
  Where Spinal_Point_Id = P_Point_id;

 Cursor Csr_Parent_Spine (P_Parent_Spine_Id IN Number) is
 Select Object_Version_Number
   from per_Parent_spines
  Where Parent_spine_Id = P_Parent_Spine_Id;

--

l_Point_Id          Per_Spinal_points.spinal_point_id%TYPE;
l_parent_Spine_id   Per_Parent_Spines.Parent_Spine_Id%TYPE;
l_Step_id           Per_Spinal_POint_Steps_F.Step_Id%TYPE;
l_Point_ovn         Per_Spinal_Points.Object_Version_Number%TYPE;
L_Spinal_Cnt        Number;
l_Prnt_ovn          Per_Parent_Spines.Object_Version_Number%TYPE;
--
--
--
Begin
--
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
     --bug#8392638 - opt_id is null during create mode. But point_id always exists
     /* If del_opt_rec.opt_id is not null then */
     If del_opt_rec.point_id is not null then
      --
      -- Determine the date-tracked mode to use when deleting the row. If no date-tracked
      -- mode is passed, the system will determine date-tracked mode to use when deleting
      -- by reading actual BEN table rows.
      --
         --
         /* Open csr_ben_opt(del_opt_rec.opt_id);
          Fetch csr_ben_opt into  l_point_Id;
          Close csr_ben_opt; */

	  l_point_Id  := del_opt_rec.point_id;    --bug#8392638

          Open Csr_Step (l_Point_Id);
	 Fetch Csr_Step into l_Step_id;
	 If Csr_Step%NOTFOUND then
            --
	   Open Csr_Spinal_Point (l_point_Id);
  	   Fetch Csr_Spinal_Point Into l_parent_Spine_id, l_Point_Ovn;
	   Close Csr_Spinal_Point;

	   hr_utility.set_location('Going to Delete Progression Points' || l_Point_Id ,10);

	   hr_progression_point_api.Delete_Progression_point
           (P_SPINAL_POINT_ID              => l_Point_Id,
            P_OBJECT_VERSION_NUMBER        => l_Point_Ovn);

	    hr_utility.set_location('Progression Points deleted' || l_Point_Id ,20);

	    Select Count(Spinal_Point_Id) into L_Spinal_Cnt
	      From Per_Spinal_Points
	     where Parent_Spine_Id = l_Parent_Spine_Id;

	    If l_Spinal_Cnt = 0 Then
               -- Delete The Pay Scale also
	        Open Csr_Parent_Spine (l_Parent_Spine_Id);
	       Fetch Csr_Parent_Spine  Into l_Prnt_Ovn;
	       Close Csr_Parent_Spine ;

               hr_utility.set_location('PARENT SPINE TO delete' || l_Parent_Spine_Id ,30);

               hr_pay_scale_api.DELETE_PAY_SCALE
              (P_PARENT_SPINE_ID              => l_Parent_Spine_Id
              ,P_OBJECT_VERSION_NUMBER        => l_Prnt_Ovn);

              hr_utility.set_location('PARENT SPINE deleted' || l_Parent_Spine_Id ,30);

	    End If;
           --
         End if; -- Csr_ste
         Close Csr_step;
        --
       End If;

    End loop;
    --
hr_utility.set_location('Leaving: delete_option',10);
--
Return 'SUCCESS';
--
Exception
  When Others Then
     hr_utility.set_location('Exception raised: delete_option',99);
     Hr_Utility.Set_Location(Nvl(fnd_message.get,sqlerrm),100);
     Return 'FAILURE';
End;

Function get_payrate(p_frequency in varchar2 default null,
                     p_business_group_id in number,
                     p_scale_id  in number default null) return number is
   l_rate_id number;
begin
   if p_frequency is null and p_scale_id is null then
      hr_utility.set_location('either freq or scale has to be there ',10);
   elsif p_frequency is not null then
      begin
         select rt.rate_id
         into l_rate_id
         from hr_lookups lkp, pay_rates rt
         where lkp.lookup_code = p_frequency
         and rt.rate_type ='G'
         and rt.business_group_id = p_business_group_id
         and lkp.lookup_type = 'PQH_GSP_GEN_PAY_RATE_NAME'
         and rt.name = lkp.meaning;
         hr_utility.set_location('rate exists for freq '||l_rate_id,22);
      exception
         when no_data_found then
            hr_utility.set_location('no pay rate exists for freq '||p_frequency,25);
            return l_rate_id;
         when others then
            hr_utility.set_location('issues in selecting freq payrate ',30);
            raise;
      end;
   elsif p_scale_id is not null then
      begin
         select rt.rate_id
         into l_rate_id
         from per_parent_spines scl, pay_rates rt
         where rt.parent_spine_id = scl.parent_spine_id
         and scl.parent_spine_id = p_scale_id
         and rt.rate_type ='SP'
         and rt.name = scl.name;
         hr_utility.set_location('rate exists for scl '||l_rate_id,22);
      exception
         when no_data_found then
            hr_utility.set_location('no pay rate exists for scl '||p_scale_id,25);
            return l_rate_id;
         when others then
            hr_utility.set_location('issues in selecting scl payrate ',30);
            raise;
      end;
   end if;
   return l_rate_id;
end get_payrate;
procedure stage_to_prate(p_copy_entity_txn_id in number,
                         p_effective_date     in date,
                         p_business_group_id  in number,
                         p_gl_frequency       in varchar2) is
   l_grd_payrate_id number;
   l_scl_payrate_id number;
   cursor c1 is
      select copy_entity_result_id,information1,information98
      from   ben_copy_entity_results Scl
      where  copy_entity_txn_id = p_copy_entity_txn_id
      and    table_alias        = 'SCALE'
      and Not Exists
      (Select 1
         from ben_copy_entity_results
        where copy_entity_txn_id = p_copy_entity_txn_id
	  and table_alias        = 'OPT'
          and (information256     = Scl.Copy_Entity_Result_Id or information255  = scl.Information1)
	  and Dml_Operation = 'DELETE')
      and Exists
      (Select 1
         from Ben_Copy_Entity_Results
	Where copy_entity_txn_id = p_copy_entity_txn_id
	  and table_alias = 'HRRATE'
          and dml_operation in ('INSERT','UPDATE'));

   cursor c2(p_scl_cer_id number,p_scale_id number) is
      select copy_entity_result_id,information1
      from   ben_copy_entity_results
      where  copy_entity_txn_id = p_copy_entity_txn_id
      and    table_alias        = 'OPT'
      and    (information256     = p_scl_cer_id or information255     = p_scale_id);
   l_ovn number;
begin
   hr_utility.set_location('inside stage_to_payrate',10);
   hr_utility.set_location('gl_freq is '||p_gl_frequency,10);
   hr_utility.set_location('bg is '||p_business_group_id,10);
   hr_utility.set_location('inside stage_to_payrate',10);
   if p_gl_frequency is not null  then
      l_grd_payrate_id := get_payrate(p_frequency => p_gl_frequency,
                                      p_business_group_id => p_business_group_id);
      if l_grd_payrate_id is null then
         hr_utility.set_location('create grd payrate',20);
         pqh_gsp_utility.create_pay_rate
         (p_business_group_id  => p_business_group_id,
          p_ldr_period_code    => p_gl_frequency,
          p_rate_id            => l_grd_payrate_id,
          p_ovn                => l_ovn);
      end if;
      hr_utility.set_location('grd payrate is:'||l_grd_payrate_id,30);
      begin
         update ben_copy_entity_results
         set information293 = l_grd_payrate_id
         where copy_entity_txn_id = p_copy_entity_txn_id
         and table_alias = 'HRRATE'
         and information277 is not null
         and information293 is null;
         hr_utility.set_location('num of hrrs updated'||sql%rowcount,20);
      exception
         when others then
            hr_utility.set_location('issues in updating hrrate',50);
            raise;
      end;
      hr_utility.set_location('grd hrrate rows updated',30);
   end if;
   for i in c1 loop
       if i.information1 is not null then
          l_scl_payrate_id := get_payrate(p_scale_id          => i.information1,
                                          p_business_group_id => p_business_group_id);
          if l_scl_payrate_id is null then
             hr_utility.set_location('create scl payrate',20);
             pqh_gsp_utility.create_pay_rate
                (p_business_group_id  => p_business_group_id,
                 p_scale_id           => i.information1,
                 p_rate_name          => i.information98,
                 p_rate_id            => l_scl_payrate_id,
                 p_ovn                => l_ovn);
          end if;
          hr_utility.set_location('scl payrate is:'||l_scl_payrate_id,20);
          hr_utility.set_location('scl cer is:'||i.copy_entity_result_id,25);
          for j in c2(i.copy_entity_result_id, i.information1) loop
          -- get all the points for the scale
             hr_utility.set_location('pt cer is:'||j.copy_entity_result_id,28);
             begin
                update ben_copy_entity_results
                set information293 = l_scl_payrate_id
                where copy_entity_txn_id = p_copy_entity_txn_id
                and table_alias = 'HRRATE'
                and information278 = j.copy_entity_result_id
                and information293 is null;
                hr_utility.set_location('num of hrrs updated'||sql%rowcount,20);
             exception
                when others then
                   hr_utility.set_location('issues in updating hrrate',50);
                   raise;
             end;
          end loop;
      else
          hr_utility.set_location('scl id is:'||i.information1,20);
      end if;
   end loop;
   hr_utility.set_location('pt hrrate rows updated',30);
end stage_to_prate;
procedure pt_writeback(p_copy_entity_txn_id in number,
                       p_point_id           in number,
                       p_point_cer_id       in number) is
begin
   hr_utility.set_location('pt writeback start for pt :'||p_point_id,10);
   hr_utility.set_location('pt cer:'||p_point_cer_id,10);
   begin
      -- opt row is updated with point id
      update ben_copy_entity_results
      set information257 = p_point_id
      where copy_entity_txn_id = p_copy_entity_txn_id
      and table_alias ='OPT'
      and copy_entity_result_id = p_point_cer_id;
      hr_utility.set_location('num of opt updated'||sql%rowcount,20);
   exception
      when others then
         hr_utility.set_location('issues in updating pt to opt',10);
         raise;
   end;
   begin
      -- oipl rows are to be updated with point id
      update ben_copy_entity_results
      set information256 = p_point_id
      where table_alias = 'COP'
      and copy_entity_txn_id = p_copy_entity_txn_id
      and information262 = p_point_cer_id;
      hr_utility.set_location('num of oipl updated'||sql%rowcount,20);
   exception
      when others then
         hr_utility.set_location('issues in updating pt to oipl ',20);
         raise;
   end;
   begin
      -- hrrate rows are to be updated with point id
      update ben_copy_entity_results
      set information276 = p_point_id
      where table_alias = 'HRRATE'
      and copy_entity_txn_id = p_copy_entity_txn_id
      and information278 = p_point_cer_id;
      hr_utility.set_location('num of hrrs updated'||sql%rowcount,20);
   exception
      when others then
         hr_utility.set_location('issues in updating pt to hrrate ',30);
         raise;
   end;
end pt_writeback;
procedure step_writeback(p_copy_entity_txn_id in number,
                         p_step_id            in number,
                         p_step_cer_id        in number,
                         p_effective_date     in date) is
   l_oipl_id number;
begin
   hr_utility.set_location('step writeback start for step :'||p_step_id,10);
   hr_utility.set_location('step cer:'||p_step_cer_id,10);
   begin
      l_oipl_id := pqh_gsp_hr_to_stage.get_oipl_for_step(p_step_id        => p_step_id,
                                                      p_effective_date => p_effective_date);
   exception
      when others then
         PQH_GSP_PROCESS_LOG.LOG_PROCESS_DTLS
         (P_MASTER_TXN_ID   => p_copy_entity_txn_id,
          P_TXN_ID          => p_copy_entity_txn_id,
          p_context         => 'pqh_gsp_hr_to_stage.get_oipl_for_step',
          P_MODULE_CD       => 'PQH_GSP_STGBEN',
          P_MESSAGE_TYPE_CD => 'E',
          P_MESSAGE_TEXT    => sqlerrm,
          p_effective_date  => p_effective_date);
         raise;
   end;
   begin
      -- oipl row is updated with step id
      update ben_copy_entity_results
      set information253 = p_step_id,
          information1   = nvl(information1,l_oipl_id)
      where copy_entity_txn_id = p_copy_entity_txn_id
      and table_alias ='COP'
      and copy_entity_result_id = p_step_cer_id;
      hr_utility.set_location('num of oipl updated'||sql%rowcount,20);
   exception
      when others then
         hr_utility.set_location('issues in updating step to cop',10);
         raise;
   end;
end step_writeback;
procedure hrr_writeback(p_grade_cer_id       in number,
                        p_point_cer_id       in number,
                        p_copy_entity_txn_id in number,
                        p_hrrate_id          in number) is
begin
   begin
      -- abr row is updated with grade spine id
      update ben_copy_entity_results
      set information266 = p_hrrate_id
      where copy_entity_txn_id = p_copy_entity_txn_id
      and table_alias ='ABR'
      and (information277 is null or information277 = p_grade_cer_id)
      and (information278 is null or information278 = p_point_cer_id);
      hr_utility.set_location('num of abrs updated'||sql%rowcount,20);
   exception
      when others then
         hr_utility.set_location('issues in updating hrrate to abr',10);
         raise;
   end;
end hrr_writeback;
procedure grd_sp_writeback(p_plip_cer_id        in number,
                           p_grade_spine_id     in number,
                           p_copy_entity_txn_id in number) is
begin
   begin
      -- oipl row is updated with grade spine id
      update ben_copy_entity_results
      set information280 = p_grade_spine_id
      where copy_entity_txn_id = p_copy_entity_txn_id
      and table_alias ='CPP'
      and copy_entity_result_id = p_plip_cer_id;
      hr_utility.set_location('num of plips updated'||sql%rowcount,20);
   exception
      when others then
         hr_utility.set_location('issues in updating gs to plip',10);
         raise;
   end;
   begin
      -- oipl row is updated with grade spine id
      update ben_copy_entity_results
      set information255 = p_grade_spine_id
      where copy_entity_txn_id = p_copy_entity_txn_id
      and table_alias ='COP'
      and gs_parent_entity_result_id = p_plip_cer_id;
      hr_utility.set_location('num of oipls updated'||sql%rowcount,20);
   exception
      when others then
         hr_utility.set_location('issues in updating gs to oipl',10);
         raise;
   end;
end grd_sp_writeback;
procedure scl_writeback(p_copy_entity_txn_id in number,
                        p_scale_id           in number,
                        p_scale_cer_id       in number) is
begin
   begin
      -- scale row is updated with Scale id
      update ben_copy_entity_results
      set information1 = p_scale_id
      where copy_entity_txn_id = p_copy_entity_txn_id
      and table_alias ='SCALE'
      and copy_entity_result_id = p_scale_cer_id;
      hr_utility.set_location('num of scales updated'||sql%rowcount,20);
   exception
      when others then
         hr_utility.set_location('issues in updating sclid to scl',5);
         raise;
   end;
   begin
      -- plip row is updated with Scale id
      update ben_copy_entity_results
      set information255 = p_scale_id
      where copy_entity_txn_id = p_copy_entity_txn_id
      and table_alias ='CPP'
      and information258 = p_scale_cer_id;
      hr_utility.set_location('num of plips updated'||sql%rowcount,20);
   exception
      when others then
         hr_utility.set_location('issues in updating scl to plip',10);
         raise;
   end;
   begin
      -- opt rows are to be updated with Scale id
      update ben_copy_entity_results
      set information255 = p_scale_id
      where table_alias = 'OPT'
      and copy_entity_txn_id = p_copy_entity_txn_id
      and information256 = p_scale_cer_id;
      hr_utility.set_location('num of opts updated'||sql%rowcount,20);
   exception
      when others then
         hr_utility.set_location('issues in updating scl to opt ',20);
         raise;
   end;
   begin
      -- oipl rows are to be updated with Scale id
      update ben_copy_entity_results
      set information260 = p_scale_id
      where table_alias = 'COP'
      and copy_entity_txn_id = p_copy_entity_txn_id
      and information259 = p_scale_cer_id;
      hr_utility.set_location('num of plips updated'||sql%rowcount,20);
   exception
      when others then
         hr_utility.set_location('issues in updating scl to oipl ',30);
         raise;
   end;
end scl_writeback;
procedure grd_writeback(p_copy_entity_txn_id in number,
                        p_grade_id           in number,
                        p_grade_cer_id       in number) is
begin
   hr_utility.set_location('writing back grd '||p_grade_id,10);
   hr_utility.set_location('writing back grdcer '||p_grade_cer_id,10);
   begin
      -- plip row is updated with Grade id
      update ben_copy_entity_results
      set information253 = p_grade_id
      where copy_entity_txn_id = p_copy_entity_txn_id
      and table_alias = 'CPP'
      and information252 = p_grade_cer_id;
      hr_utility.set_location('num of plips updated'||sql%rowcount,20);
   exception
      when others then
         hr_utility.set_location('issues in updating grd to plip',10);
         raise;
   end;
   begin
      -- plan row is updated with Grade id
      update ben_copy_entity_results
      set information223 = p_grade_id,
          information294 = p_grade_id
      where copy_entity_result_id = p_grade_cer_id;
      hr_utility.set_location('num of pl updated'||sql%rowcount,20);
   exception
      when others then
         hr_utility.set_location('issues in updating grd to pl',10);
         raise;
   end;
   begin
      -- hrrate row is to be updated with Grade id
      update ben_copy_entity_results
      set information255 = p_grade_id
      where table_alias = 'HRRATE'
      and copy_entity_txn_id = p_copy_entity_txn_id
      and information277 = p_grade_cer_id;
      hr_utility.set_location('num of hrate updated'||sql%rowcount,20);
   exception
      when others then
         hr_utility.set_location('issues in updating grd to hrrate',20);
         raise;
   end;
end grd_writeback;
function get_max_grd_seq(p_business_group_id in number) return number is
   l_max_seq number;
begin
   select max(sequence) into l_max_seq
   from per_grades
   where business_group_id = p_business_group_id;
   l_max_seq := nvl(l_max_seq,0) +1;
   return l_max_seq;
exception
   when no_data_found then
      hr_utility.set_location('no grd found ',10);
      return 0;
   when others then
      hr_utility.set_location('issues in getting max grd seq',20);
      raise;
end get_max_grd_seq;
function get_bg_for_cet(p_copy_entity_txn_id in number) return number is
   l_bg_id number;
begin
   select context_business_group_id
   into l_bg_id
   from pqh_copy_entity_txns
   where copy_entity_txn_id = p_copy_entity_txn_id;
   return l_bg_id;
exception
   when no_data_found then
      hr_utility.set_location('CET doesnot exist'||p_copy_entity_txn_id,10);
      raise;
   when others then
      hr_utility.set_location('issues in getting bg for CET ',20);
      raise;
end get_bg_for_cet;
function get_grd_segment(p_grade_id            in number,
                         p_grade_definition_id in number) return varchar2 is
   l_concat_segs varchar2(2000);
begin
   -- logic needs to be written which will go in here
   return l_concat_segs;
end get_grd_segment;

procedure pre_push_data(p_copy_entity_txn_id in number,
                        p_effective_date     in date,
                        p_business_group_id  in number,
                        p_business_area      in varchar2 default 'PQH_GSP_TASK_LIST',
			P_Date_Track_Mode    in Varchar2) is
   l_return varchar2(30);
   l_effective_date date;
   l_Del_Dt_Mode Varchar2(30);
begin
   hr_utility.set_location('inside pre-push',1);
   If P_Date_Track_Mode = 'UPDATE_OVERRIDE' Then
      l_Del_Dt_Mode := 'DELETE';
   Else
      l_Del_Dt_Mode := 'ZAP';
   End If;
   begin
      select effective_date
      into l_effective_date
      from fnd_sessions
      where session_id = userenv('sessionid');
      update fnd_sessions
      set effective_date = p_effective_date
      where session_id = userenv('sessionid');
   exception
      when no_data_found then
           insert into fnd_sessions(session_id,effective_date) values(userenv('sessionid'), p_effective_date);
      when others then
         raise;
   end;
   hr_utility.set_location('effective date set',1);
   begin
      update ben_copy_entity_results
      set dml_operation = 'DELETE'
      where copy_entity_txn_id = p_copy_entity_txn_id
      and table_alias in ('COP','OPT','CPP','HRRATE','ABR')
      and information104 = 'UNLINK';
      hr_utility.set_location('num of unlinks updated'||sql%rowcount,2);
   exception
      when others then
         hr_utility.set_location('issues in marking recs for delete',1);
         raise;
   end;
   hr_utility.set_location('calling delete obj',1);

   -- Delete HR Steps if any found. This will inturn Delete the OIPLs


 /*  l_return := pqh_gsp_del_grade_ladder_obj.delete_from_ben
     (p_copy_entity_txn_id => p_copy_entity_txn_id,
      p_effective_date     => p_effective_date,
      p_datetrack_mode     => 'DELETE'); */

      -- Unlink Eligibility Profiles
     l_return := pqh_gsp_del_grade_ladder_obj.unlink_elig_prfl(p_copy_entity_txn_id => p_copy_entity_txn_id,
                                                               p_effective_date     => p_effective_date,
                                                               p_datetrack_mode     => l_Del_Dt_Mode);
     If l_return = 'FAILURE' Then

        fnd_message.set_name('PQH','PQH_GSP_BEN_DEL_FAILED');
        fnd_message.raise_error;

     End If;

     -- Unlink Plan In Programs
     l_return := pqh_gsp_del_grade_ladder_obj.unlink_plan_from_pgm (p_copy_entity_txn_id => p_copy_entity_txn_id,
        							    p_effective_date     => p_effective_date,
                                                                    p_datetrack_mode     => l_Del_Dt_Mode);


     If l_return = 'FAILURE' Then

        fnd_message.set_name('PQH','PQH_GSP_BEN_DEL_FAILED');
        fnd_message.raise_error;

     End If;

     --  Delete option

     Delete_Step(p_copy_entity_txn_id  => p_copy_entity_txn_id,
                 p_effective_date      => p_effective_date,
		 P_Date_Track_Mode     => l_Del_Dt_Mode);

     If l_Del_Dt_Mode = 'ZAP' Then

        l_return := Delete_Rate (p_copy_entity_txn_id => p_copy_entity_txn_id,
                                                          p_effective_date     => p_effective_date);

        l_return := delete_option (p_copy_entity_txn_id => p_copy_entity_txn_id,
                                                           p_effective_date     => p_effective_date);

       If l_return = 'FAILURE' Then

           fnd_message.set_name('PQH','PQH_GSP_BEN_DEL_FAILED');
           fnd_message.raise_error;

        End If;
     End If;
     if p_business_area = 'PQH_GSP_TASK_LIST' THEN

pqh_gsp_hr_to_stage.create_payrate(p_copy_entity_txn_id => p_copy_entity_txn_id,
                       p_effective_date   =>  p_effective_date,
                       p_business_group_id => p_business_group_id);

END IF;
   hr_utility.set_location('leaving pre-push',100);
end pre_push_data;

procedure post_push_data(p_copy_entity_txn_id in number,
                         p_effective_date     in date,
                         p_business_group_id  in number,
                         p_business_area      in varchar2 default 'PQH_GSP_TASK_LIST') is
   l_message_text varchar2(2000);
begin
   hr_utility.set_location('inside post_data_push',10);
  /* l_message_text := 'cet id'||p_copy_entity_txn_id
                     ||'business_group_id is '||p_business_group_id
                     ||'effdt is '||to_char(p_effective_date,'dd-mm-RRRR')
                     ||'bus area is '||p_business_area;
            PQH_GSP_PROCESS_LOG.LOG_PROCESS_DTLS
            (P_MASTER_TXN_ID   => p_copy_entity_txn_id,
             P_TXN_ID          => p_copy_entity_txn_id,
             p_context         => 'inside_post_DATA_PUSH',
             P_MODULE_CD       => 'PQH_GSP_STGBEN',
             P_MESSAGE_TYPE_CD => 'E',
             P_MESSAGE_TEXT    => l_message_text,
             p_effective_date  => p_effective_date); */
   pqh_gsp_hr_to_stage.update_gsp_control_rec
      (p_copy_entity_txn_id => p_copy_entity_txn_id,
       p_effective_date     => p_effective_date,
       p_business_area      => p_business_area);
   hr_utility.set_location('leaving post_data_push',10);
end post_push_data;
procedure gsp_data_push(p_copy_entity_txn_id in number,
                        p_effective_date     in date,
                        p_business_group_id  in number,
                        p_datetrack_mode     in varchar2,
                        p_business_area      in varchar2 default 'PQH_GSP_TASK_LIST') is
   l_gl_currency varchar2(30);
   l_gl_freq     varchar2(30);
   l_gl_name     varchar2(80);
   l_datetrack_mode varchar2(30);
   l_continue varchar2(30) := 'Y';
begin
   hr_utility.set_location('inside gsp_data_push',10);
   if p_datetrack_mode = 'CORR' then
      l_datetrack_mode := 'CORRECTION';
   elsif p_datetrack_mode = 'UPDATE' then
      l_datetrack_mode := 'UPDATE_OVERRIDE';
   else
      hr_utility.set_location('invalid dt mode passed',10);
      l_continue := 'N';
   end if;
   if l_continue = 'Y' then
      hr_utility.set_location('dt_mode set',10);
      begin
         hr_utility.set_location('going for pgm datapull',20);
         select information50,information41,substr(information5,1,80)
         into l_gl_currency,l_gl_freq,l_gl_name
         from ben_copy_entity_results
         where copy_entity_txn_id = p_copy_entity_txn_id
         and result_type_cd ='DISPLAY'
         and table_alias = 'PGM';
         hr_utility.set_location('curr and freq of pgm fetched',10);
      exception
         when others then
            hr_utility.set_location('issues in selecting pgm row ',10);
            raise;
      end;
   end if;
   if l_continue = 'Y' then
      PQH_GSP_PROCESS_LOG.START_LOG
      (P_TXN_ID    => p_copy_entity_txn_id,
       P_TXN_NAME  => l_gl_name||p_business_area,
       P_MODULE_CD => 'PQH_GSP_STGBEN');
      begin

         pre_push_data(p_copy_entity_txn_id => p_copy_entity_txn_id,
                       p_effective_date     => p_effective_date,
                       p_business_group_id  => p_business_group_id,
		       P_Date_Track_Mode    => l_datetrack_mode);

         hr_utility.set_location('pre push done ',20);

         stage_to_hr(p_copy_entity_txn_id => p_copy_entity_txn_id,
                     p_effective_date     => p_effective_date,
                     p_business_group_id  => p_business_group_id,
                     p_gl_currency        => l_gl_currency,
                     p_gl_frequency       => l_gl_freq,
                     p_gl_name            => l_gl_name,
                     p_datetrack_mode     => l_datetrack_mode,
                     p_business_area      => p_business_area);

         hr_utility.set_location('data pushed to hr ',20);

         pqh_gsp_stage_to_ben.cre_update_elig_prfl(
                     p_copy_entity_txn_id  => p_copy_entity_txn_id
                    ,p_effective_date      => p_effective_date
                    ,p_business_group_id   => p_business_group_id);

         hr_utility.set_location('Elpros created/updated',20);

         pqh_gsp_stage_to_ben.stage_to_ben
            (p_copy_entity_txn_id => p_copy_entity_txn_id,
             p_effective_date     => p_effective_date,
             p_business_group_id  => p_business_group_id,
             p_datetrack_mode     => l_datetrack_mode,
             p_business_area      => p_business_area);

	 hr_utility.set_location('data pushed to ben ',20);

         post_push_data(p_copy_entity_txn_id => p_copy_entity_txn_id,
                        p_effective_date     => p_effective_date,
                        p_business_group_id  => p_business_group_id,
                        p_business_area      => p_business_area);

	 hr_utility.set_location('post data push done ',40);

	 begin

          update pqh_copy_entity_txns
           set status ='COMPLETED'
           where copy_entity_txn_id = p_copy_entity_txn_id;

	    -- Purging the Copy Entity Txn record as it is no longer required --

	 Delete from Ben_Copy_Entity_Results
	  where Copy_Entity_Txn_Id = p_copy_entity_txn_id
	    and Table_Alias Not In ('PQH_GSP_TASK_LIST','PQH_CORPS_TASK_LIST');

            hr_utility.set_location('txn stat chg to comp',40);
         exception
            when others then
               hr_utility.set_location('issues in updating cet row ',10);
               raise;
         end;
         PQH_PROCESS_BATCH_LOG.END_LOG;
      exception
         when others then
            hr_utility.set_location('issues in writing data ',10);
            PQH_GSP_PROCESS_LOG.LOG_PROCESS_DTLS
            (P_MASTER_TXN_ID   => p_copy_entity_txn_id,
             P_TXN_ID          => p_copy_entity_txn_id,
             p_context         => 'GSP_DATA_PUSH',
             P_MODULE_CD       => 'PQH_GSP_STGBEN',
             P_MESSAGE_TYPE_CD => 'E',
             P_MESSAGE_TEXT    => sqlerrm,
             p_effective_date  => p_effective_date);

            PQH_PROCESS_BATCH_LOG.END_LOG;
            raise;
      end;
   end if;
end gsp_data_push;
procedure stage_to_hr(p_copy_entity_txn_id in number,
                      p_effective_date     in date,
                      p_business_group_id  in number,
                      p_gl_currency        in varchar2,
                      p_gl_name            in varchar2,
                      p_gl_frequency       in varchar2,
                      p_datetrack_mode     in varchar2,
                      p_business_area      in varchar2 default 'PQH_GSP_TASK_LIST') is
-- this procedure will be the callable routine and will be starting before
-- stage_to_ben starts copying the data from staging table to ben tables
-- in this procedure we will traverse the hierarchy and find out what all is
-- hr data
-- for any plan created/updated stage_to_grade
-- for any option created/ updated stage_to_point
-- for any oipl created/ updated stage_to_step
-- for any standard rate created/ updated stage_to_hrate
/* the data should be written in this order
1) Grades
2) Scales
3) Points
4) Grade spines
5) Steps
6) Rates
*/
   l_proc varchar2(61) := 'stage_to_hr' ;
   l_effective_date date := p_effective_date;
begin
   hr_utility.set_location('inside '||l_proc,10);
   hr_utility.set_location('cet is '||p_copy_entity_txn_id,1);
   hr_utility.set_location('bg is '||p_business_group_id,2);
   hr_utility.set_location('curr is '||p_gl_currency,3);
   hr_utility.set_location('dt mode is '||p_datetrack_mode,4);
   stage_to_grade(p_copy_entity_txn_id => p_copy_entity_txn_id,
                  p_effective_date     => l_effective_date,
                  p_business_group_id  => p_business_group_id);
   hr_utility.set_location('grade row checked for update',30);
   stage_to_scale(p_copy_entity_txn_id => p_copy_entity_txn_id,
                  p_effective_date     => l_effective_date,
                  p_business_group_id  => p_business_group_id,
                  p_business_area      => p_business_area);
   hr_utility.set_location('Scale row updated',40);
   stage_to_prate(p_copy_entity_txn_id => p_copy_entity_txn_id,
                  p_effective_date     => l_effective_date,
                  p_business_group_id  => p_business_group_id,
                  p_gl_frequency       => p_gl_frequency);
   hr_utility.set_location('pay rates created if any reqd',41);
   stage_to_grd_sp(p_copy_entity_txn_id => p_copy_entity_txn_id,
                   p_effective_date     => l_effective_date,
                   p_business_group_id  => p_business_group_id,
                   p_datetrack_mode     => p_datetrack_mode);
   hr_utility.set_location('grade spine row updated',40);
   stage_to_point(p_copy_entity_txn_id => p_copy_entity_txn_id,
                  p_effective_date     => l_effective_date,
                  p_business_group_id  => p_business_group_id,
                  p_business_area      => p_business_area);
   hr_utility.set_location('option row updated',50);
   stage_to_step(p_copy_entity_txn_id => p_copy_entity_txn_id,
                 p_effective_date     => l_effective_date,
                 p_business_group_id  => p_business_group_id,
                 p_datetrack_mode     => p_datetrack_mode);
   hr_utility.set_location('oipl row updated',60);
   stage_to_hrate(p_copy_entity_txn_id => p_copy_entity_txn_id,
                  p_effective_date     => l_effective_date,
                  p_gl_currency        => p_gl_currency,
                  p_business_group_id  => p_business_group_id,
                  p_datetrack_mode     => p_datetrack_mode);
   hr_utility.set_location('Hrate row updated',70);
exception
   when others then
      hr_utility.set_location('error encountered',420);
      raise;
end stage_to_hr;
function get_grd_spine(p_grade_id           in number,
                       p_scale_id           in number,
                       p_effective_date     in date) return number is
   l_grade_spine_id number;
   l_parent_spine_id number;
begin
   begin
      select grade_spine_id,parent_spine_id
      into l_grade_spine_id,l_parent_spine_id
      from per_grade_spines_f
      where grade_id = p_grade_id
      and p_effective_date between effective_start_date and effective_end_date;
      hr_utility.set_location('grade_spine id is '||l_grade_spine_id,35);
   exception
      when no_data_found then
         hr_utility.set_location('grade is not attached to any scale ',40);
      when others then
         hr_utility.set_location('issues in getting grade_spine ',50);
         raise;
   end;
   if l_grade_spine_id is null then
   -- grade spine doesnot exist, return null to create new
      hr_utility.set_location('grade spine doesnot exist',50);
      return l_grade_spine_id;
   else
      if l_parent_spine_id = p_scale_id then
      -- grade is linked to same scale in db use the same grade spine
         hr_utility.set_location('grade is linked to same scale ',50);
         return l_grade_spine_id;
      else
      -- grade is linked to different scale in db , we have to delete this grade spine
      -- and steps before create this one.
         hr_utility.set_location('grade is linked to diff scale ',50);
       /*  delete_steps(p_grade_spine_id => l_grade_spine_id,
                      p_effective_date => p_effective_date);
         delete_grade_spine(p_grade_spine_id => l_grade_spine_id,
                            p_effective_date => p_effective_date); */
         return null;
      end if;
   end if;
end get_grd_spine;
procedure stage_to_grd_sp(p_copy_entity_txn_id in number,
                          p_effective_date     in date,
                          p_business_group_id  in number,
                          p_datetrack_mode     in varchar2) is
   cursor csr_gsps is
      select *
      from ben_copy_entity_results
      where copy_entity_txn_id = p_copy_entity_txn_id
      and table_alias = 'CPP'
      and Dml_Operation <> 'DELETE';
   l_proc varchar2(61) := 'stage_to_grd_sp' ;
   l_grade_spine_id number;
   l_gs_ovn number;
   l_gs_esd date;
   l_gs_eed date;
   l_message_text varchar2(2000);
   l_ceiling_step_id number;
   l_scale_id number;
   l_grade_id number;
   l_grd_effstdt date;  --DN code for BugId: 3242976
   l_starting_step number;
   l_db_ovn number;
   l_dt_mode varchar2(30);
   l_object varchar2(80);

begin
   hr_utility.set_location('inside '||l_proc,10);
   for grd_spine in csr_gsps loop
      l_ceiling_step_id := grd_spine.information259;
      l_starting_step := grd_spine.information228;
      l_gs_ovn := grd_spine.information281;

      if grd_spine.information255 is null and grd_spine.information258 is not null then
         begin
            select information1
            into l_scale_id
            from ben_copy_entity_results
            where copy_entity_result_id = grd_spine.information258;
         exception
            when others then
               hr_utility.set_location('scale was created but deleted',10);
         end;
      else
         l_scale_id := grd_spine.information255;
      end if;
      if grd_spine.information253 is null and grd_spine.information252 is not null then
         select information223
         into l_grade_id
         from ben_copy_entity_results
         where copy_entity_result_id = grd_spine.information252;
      else
         l_grade_id := grd_spine.information253;
      end if;
      if l_grade_id is not null and l_scale_id is not null then
         l_grade_spine_id := get_grd_spine(p_grade_id       => l_grade_id,
                                           p_scale_id       => l_scale_id,
                                           p_effective_date => p_effective_date);
      end if;
      if l_grade_spine_id is null
         and grd_spine.information253 is not null
         and grd_spine.information255 is not null then
         hr_utility.set_location('going for cr ',30);
         hr_utility.set_location('grade is '||grd_spine.information253,30);
         hr_utility.set_location('scale is '||grd_spine.information255,30);
         hr_utility.set_location('ceiling step is '||l_ceiling_step_id,30);
         -- HM: Start code for BugId: 3928277
         -- If the payscale linked to grade is changed create grade spine as of effective date
         begin
            select grade_id
              into l_grade_id
              from per_grade_spines_f
             where grade_id = l_grade_id
               and rownum < 2 ;
            l_grd_effstdt := p_effective_date;
         exception
            when no_data_found then
               hr_utility.set_location('new payscale attached ',30);
	       l_grd_effstdt := null;   -- ggnanagu 115.48
         end;
         -- End code for BugId: 3928277

         -- DN: Start code for BugId: 3242976
         if l_grd_effstdt is null then
            -- No Payscale is attached to grade previously
            begin
               select date_from
              into l_grd_effstdt
               from per_grades
             where grade_id = l_grade_id;
            exception
             when others then
                  l_grd_effstdt := p_effective_date;
            end;
         end if;
         --End code for BugId: 3242976
         hr_grade_scale_api.create_grade_scale
         (p_effective_date          => l_grd_effstdt --p_effective_date  --DN code for BugId: 3242976
         ,p_business_group_id       => p_business_group_id
         ,p_parent_spine_id         => l_scale_id
         ,p_grade_id                => l_grade_id
         ,p_ceiling_step_id         => l_ceiling_step_id
         ,p_grade_spine_id          => l_grade_spine_id
         ,p_effective_start_date    => l_gs_esd
         ,p_effective_end_date      => l_gs_eed
         ,p_object_version_number   => l_gs_ovn
         ,p_starting_step           => l_starting_step
         );
      elsif l_grade_spine_id is not null and grd_spine.information103 in ('Y','B','S') then
         hr_utility.set_location('grd_spine exists,ceiling step updated',10);
         begin
            hr_utility.set_location('going for upd',30);
            l_db_ovn := pqh_gsp_stage_to_ben.get_ovn
                     (p_table_name         => 'PER_GRADE_SPINES_F',
                      p_key_column_name    => 'GRADE_SPINE_ID',
                      p_key_column_value   => l_grade_spine_id,
                      p_effective_date     => p_effective_date);
            hr_utility.set_location(' l_db_ovn is '||l_db_ovn,30);
            hr_utility.set_location(' l_gs_ovn is '||l_gs_ovn,30);
            if l_db_ovn <> l_gs_ovn then
               l_object := hr_general.decode_lookup('PQH_GSP_OBJECT_TYPE','GSPINE');
               fnd_message.set_name('PQH','PQH_GSP_OBJ_OVN_INVALID');
               fnd_message.set_token('OBJECT ',l_object);
               fnd_message.set_token('OBJECT_NAME ',l_grade_spine_id);
               fnd_message.raise_error;
            else
               if p_datetrack_mode <> 'CORRECTION' then
                  l_dt_mode := pqh_gsp_stage_to_ben.get_update_mode
                            (p_table_name       => 'PER_GRADE_SPINES_F',
                             p_key_column_name  => 'GRADE_SPINE_ID',
                             p_key_column_value => l_grade_spine_id,
                             p_effective_date   => p_effective_date);
               else
                  l_dt_mode := p_datetrack_mode;
               end if;
               hr_utility.set_location('l_dt_mode is'||l_dt_mode,30);
               hr_grade_scale_api.update_grade_scale
                 (
                  p_effective_date           =>      p_effective_date --l_grd_effstdt
                 ,p_datetrack_mode           =>      l_dt_mode
                 ,p_grade_spine_id           =>      l_grade_spine_id
                 ,p_object_version_number    =>      l_gs_ovn
                 ,p_business_group_id        =>      p_business_group_id
                 ,p_parent_spine_id          =>      l_scale_id
                 ,p_grade_id                 =>      l_grade_id
                 ,p_ceiling_step_id          =>      l_ceiling_step_id
                 ,p_starting_step            =>      l_starting_step
                 ,p_effective_start_date     =>      l_gs_esd
                 ,p_effective_end_date       =>      l_gs_eed
                 );
            end if ;
         exception
            when others then
               hr_utility.set_location('issue in update grade scale'||l_ceiling_step_id,23);
               hr_utility.set_location('for grd_sp '||l_grade_spine_id,23);
               raise;
         end;

/*        if(grd_spine.information103 in ('Y','B')) then
           if grd_spine.information259 is not null then
            begin
               update per_grade_spines_f
               set ceiling_step_id = l_ceiling_step_id
               where grade_spine_id = l_grade_spine_id
               and p_effective_date between effective_start_date and effective_end_date;
               hr_utility.set_location('num of grd_sps updated'||sql%rowcount,20);
            exception
               when others then
                  hr_utility.set_location('issue in upd ceil step'||l_ceiling_step_id,23);
                  hr_utility.set_location('for grd_sp '||l_grade_spine_id,23);
                  raise;
            end;
            end if;
         end if;
         if (grd_spine.information103 in ('S','B')) then
            hr_utility.set_location('grd_spine exists,starting step updated',10);
             if grd_spine.information228 is not null then
            begin
               update per_grade_spines_f
               set starting_step = l_starting_step
               where grade_spine_id = l_grade_spine_id
               and p_effective_date between effective_start_date and effective_end_date;
               hr_utility.set_location('num of grd_sps updated'||sql%rowcount,20);
            exception
               when others then
                  hr_utility.set_location('issue in upd ceil step'||l_ceiling_step_id,23);
                  hr_utility.set_location('for grd_sp '||l_grade_spine_id,23);
                  raise;
            end;
         end if;
         end if;
  */
      elsif l_grade_spine_id is not null then
         hr_utility.set_location('grd_spine exists,no ceiling step changed',10);
      elsif l_grade_spine_id is null and l_scale_id is null and grd_spine.information258 is null then
         hr_utility.set_location('scale is not attached ',10);
     /* else
         l_message_text := 'grade spine is'||l_grade_spine_id
         ||' grade is'||l_grade_id
         ||' pl_cer_id is'||grd_spine.information252
         ||' scl_cer_id is'||grd_spine.information258
         ||' ceil_upd_flg is'||grd_spine.information103
         ||' dml_oper is'||grd_spine.dml_operation
         ||' ceiling step id is'||l_ceiling_step_id
         ||' scale is'||l_scale_id;
         PQH_GSP_PROCESS_LOG.LOG_PROCESS_DTLS
         (P_MASTER_TXN_ID  => p_copy_entity_txn_id,
         P_TXN_ID          => nvl(l_grade_spine_id,p_copy_entity_txn_id),
         P_MODULE_CD       => 'PQH_GSP_STGBEN',
         p_context         => 'GRADE_SPINE',
         P_MESSAGE_TYPE_CD => 'E',
         P_MESSAGE_TEXT    => l_message_text,
         p_effective_date  => p_effective_date); */
      end if;
      if l_grade_spine_id is not null then
         hr_utility.set_location('gs writeback'||l_grade_spine_id,60);
         grd_sp_writeback(p_plip_cer_id    => grd_spine.copy_entity_result_id,
                          p_grade_spine_id => l_grade_spine_id,
                          p_copy_entity_txn_id => p_copy_entity_txn_id);
         hr_utility.set_location('grade spine done'||l_grade_spine_id,80);
      end if;
   end loop;
   hr_utility.set_location('out of gs loop'||l_proc,200);
exception
   when others then
      PQH_GSP_PROCESS_LOG.LOG_PROCESS_DTLS
      (P_MASTER_TXN_ID  => p_copy_entity_txn_id,
      P_TXN_ID          => p_copy_entity_txn_id,
      P_MODULE_CD       => 'PQH_GSP_STGBEN',
      p_context         => 'GRADE-STEP',
      P_MESSAGE_TYPE_CD => 'E',
      P_MESSAGE_TEXT    => 'Grade spine',
      p_effective_date  => p_effective_date);
      raise;
end stage_to_grd_sp;
procedure stage_to_point(p_copy_entity_txn_id in number,
                         p_business_group_id  in number,
                         p_effective_date     in date,
                         p_business_area      in varchar2 default 'PQH_GSP_TASK_LIST') is
l_proc varchar2(61) :='stage_to_point';
l_point_id number;
l_scale_id number;
l_point_ovn number;
l_db_ovn number;
l_object varchar2(80);
l_message_text varchar2(2000);
cursor csr_points is
      select *
      from ben_copy_entity_results
      where copy_entity_txn_id = p_copy_entity_txn_id
      and table_alias = 'OPT'
      and dml_operation in ('INSERT','UPDATE','UPD_INS')
      order by information253 desc; -- do highest seq. first
begin
   hr_utility.set_location('inside '||l_proc,10);
   for point_rec in csr_points loop
      l_point_id := point_rec.information257;
      l_point_ovn := point_rec.information254;
      if point_rec.information255 is null and point_rec.information256 is not null then
         begin
            select information1
            into l_scale_id
            from ben_copy_entity_results
            where copy_entity_result_id = point_rec.information256;
         exception
            when others then
               hr_utility.set_location('scale created but removed',10);
         end;
      elsif point_rec.information255 is not null then
         l_scale_id :=  point_rec.information255;
      end if;
      if point_rec.dml_operation ='INSERT'
         and point_rec.information257 is null
         and l_scale_id is not null then
         hr_utility.set_location('going for ins',20);
         if p_business_area = 'PQH_CORPS_TASK_LIST' then
            pqh_cpd_hr_to_stage.create_point(p_point_id             => l_point_id,
                                             p_point_ovn            => l_point_ovn,
                                             p_information_category => point_rec.information101,
                                             p_information1         => point_rec.information173,
                                             p_information2         => point_rec.information175,
                                             p_information3         => point_rec.information179,
                                             p_information4         => point_rec.information181,
                                             p_information5         => point_rec.information182,
                                             p_effective_date       => p_effective_date,
                                             p_business_group_id    => p_business_group_id,
                                             p_parent_spine_id      => l_scale_id,
                                             p_sequence             => point_rec.information253,
                                             p_spinal_point         => point_rec.information98);
         else
            hr_progression_point_api.create_progression_point
            (p_effective_date                 => p_effective_date
            ,p_business_group_id              => p_business_group_id
            ,p_parent_spine_id                => l_scale_id
            ,p_sequence                       => point_rec.information253
            ,p_spinal_point                   => point_rec.information98
            ,p_spinal_point_id                => l_point_id
            ,p_object_version_number          => l_point_ovn
            );
         end if;
         hr_utility.set_location('ins done '||l_point_id,22);
         pt_writeback(p_copy_entity_txn_id => p_copy_entity_txn_id,
                      p_point_id           => l_point_id,
                      p_point_cer_id       => point_rec.copy_entity_result_id);
         hr_utility.set_location('wrt_back done '||l_point_id,25);
      elsif point_rec.dml_operation in ('UPDATE','UPD_INS')
         and point_rec.information257 is not null
         and point_rec.information255 is not null then
         hr_utility.set_location('going for upd',30);
           l_db_ovn := pqh_gsp_stage_to_ben.get_ovn
                              (p_table_name         => 'PER_SPINAL_POINTS',
                               p_key_column_name    => 'SPINAL_POINT_ID',
                               p_key_column_value   => l_point_id);
           hr_utility.set_location(' ovn is '||l_db_ovn,30);
           if l_db_ovn <> l_point_ovn then
              l_object := hr_general.decode_lookup('PQH_GSP_OBJECT_TYPE','POINT');
              fnd_message.set_name('PQH','PQH_GSP_OBJ_OVN_INVALID');
              fnd_message.set_token('OBJECT ',l_object);
              fnd_message.set_token('OBJECT_NAME ',point_rec.information98);
              fnd_message.raise_error;
           else
              if p_business_area = 'PQH_CORPS_TASK_LIST' then
                 pqh_cpd_hr_to_stage.update_point(p_point_id             => l_point_id,
                                                  p_point_ovn            => l_point_ovn,
                                                  p_information_category => point_rec.information101,
                                                  p_information1         => point_rec.information173,
                                                  p_information2         => point_rec.information175,
                                                  p_information3         => point_rec.information179,
                                                  p_information4         => point_rec.information181,
                                                  p_information5         => point_rec.information182,
                                                  p_effective_date       => p_effective_date,
                                                  p_business_group_id    => p_business_group_id,
                                                  p_parent_spine_id      => l_scale_id,
                                                  p_sequence             => point_rec.information253,
                                                  p_spinal_point         => point_rec.information98);
              else
                 hr_progression_point_api.update_progression_point
                 (p_effective_date                 => p_effective_date
                 ,p_business_group_id              => p_business_group_id
                 ,p_parent_spine_id                => l_scale_id
                 ,p_sequence                       => point_rec.information253
                 ,p_spinal_point                   => point_rec.information98
                 ,p_spinal_point_id                => l_point_id
                 ,p_object_version_number          => l_point_ovn
                 );
              end if;
              hr_utility.set_location('upd done ',32);
          end if;
      else
         l_message_text := 'invalid dml_oper is '||point_rec.dml_operation
         ||' point id is '||l_point_id
         ||' point ovn is '||l_point_ovn
         ||' point seq is '||point_rec.information253
         ||' point name is '||point_rec.information98
         ||' business_area is '||p_business_area
         ||' scale id is '||l_scale_id;
         PQH_GSP_PROCESS_LOG.LOG_PROCESS_DTLS
         (P_MASTER_TXN_ID  => p_copy_entity_txn_id,
         P_TXN_ID          => nvl(l_point_id,p_copy_entity_txn_id),
         P_MODULE_CD       => 'PQH_GSP_STGBEN',
         p_context         => 'POINT',
         P_MESSAGE_TYPE_CD => 'E',
         P_MESSAGE_TEXT    => l_message_text,
         p_effective_date  => p_effective_date);
      end if;
   end loop;
   hr_utility.set_location('leaving '||l_proc,100);
exception
   when others then
      PQH_GSP_PROCESS_LOG.LOG_PROCESS_DTLS
      (P_MASTER_TXN_ID  => p_copy_entity_txn_id,
      P_TXN_ID          => p_copy_entity_txn_id,
      P_MODULE_CD       => 'PQH_GSP_STGBEN',
      p_context         => 'POINT',
      P_MESSAGE_TYPE_CD => 'E',
      P_MESSAGE_TEXT    => 'Point',
      p_effective_date  => p_effective_date);
      raise;
end stage_to_point;
Procedure stage_to_grade(p_copy_entity_txn_id in number,
                         p_business_group_id  in number,
                         p_effective_date     in date) is
l_proc varchar2(61) :='stage_to_grade';
l_grade_id number;
l_grd_seq number;
l_db_ovn number;
l_ovn number;
l_object varchar2(80);
l_concat_segments varchar2(600);
l_message_text varchar2(2000);
cursor csr_grades is
      select *
      from ben_copy_entity_results
      where copy_entity_txn_id = p_copy_entity_txn_id
      and table_alias = 'PLN'
      and dml_operation in ('INSERT','UPDATE','UPD_INS');
begin
   hr_utility.set_location('inside'||l_proc,10);
   for grd_rec in csr_grades loop
      l_ovn := grd_rec.information222;
      l_grade_id := grd_rec.information223;
      if grd_rec.dml_operation = 'INSERT'
         and l_grade_id is null
         and grd_rec.information221 is not null
         and grd_rec.information5 is not null then
         hr_utility.set_location('new grade is being created'||l_proc,20);
         if l_grd_seq is null then
            l_grd_seq := get_max_grd_seq(p_business_group_id => p_business_group_id);
         else
            l_grd_seq := l_grd_seq + 1;
         end if;
         begin
            hr_utility.set_location('grade name'||substr(grd_rec.information5,1,45),20);
            hr_utility.set_location('grade seq'||l_grd_seq,20);
            hr_utility.set_location('date from'||to_char(grd_rec.information307,'DD/MM/RRRR'),20);
            hr_utility.set_location('date to'||to_char(grd_rec.information308,'DD/MM/RRRR'),20);
            hr_grade_api.create_grade(p_business_group_id     => p_business_group_id
                                     ,p_date_from             => grd_rec.information307
                                     ,p_sequence              => l_grd_seq
                                     ,p_effective_date        => p_effective_date
                                     ,p_date_to               => grd_rec.information308
                                     ,p_short_name            => grd_rec.information102
                                     ,p_grade_id              => l_grade_id
                                     ,p_object_version_number => l_ovn
                                     ,p_grade_definition_id   => grd_rec.information221
                                     ,p_name                  => grd_rec.information5);
            hr_utility.set_location('grade id'||l_grade_id,20);
         exception
            when others then
               hr_utility.set_location('issues in creating grade'||grd_rec.information5,30);
               raise;
         end;
         hr_utility.set_location('grade id is '||l_grade_id,30);
         hr_utility.set_location('grade cer id is '||grd_rec.copy_entity_result_id,30);
         grd_writeback(p_copy_entity_txn_id => p_copy_entity_txn_id,
                       p_grade_id           => l_grade_id,
                       p_grade_cer_id       => grd_rec.copy_entity_result_id);
         hr_utility.set_location('grade writeback comp '||l_grade_id,40);
      elsif grd_rec.dml_operation in ('UPDATE','UPD_INS')
      and l_ovn is not null
      and grd_rec.information221 is not null
      and grd_rec.information5 is not null
      and l_grade_id is not null then
         hr_utility.set_location('grade is being updated'||l_grade_id,60);
         hr_utility.set_location('grade ovn'||grd_rec.information222,60);
         l_concat_segments := get_grd_segment(p_grade_id            => l_grade_id,
                                              p_grade_definition_id => grd_rec.information221);
         hr_utility.set_location('con seg is'||substr(l_concat_segments,1,55),61);
         l_db_ovn := pqh_gsp_stage_to_ben.get_ovn
                            (p_table_name         => 'PER_GRADES',
                             p_key_column_name    => 'GRADE_ID',
                             p_key_column_value   => l_grade_id);
         hr_utility.set_location(' ovn is '||l_db_ovn,30);
         if l_db_ovn <> l_ovn then
            l_object := hr_general.decode_lookup('PQH_GSP_OBJECT_TYPE','GRADE');
            fnd_message.set_name('PQH','PQH_GSP_OBJ_OVN_INVALID');
            fnd_message.set_token('OBJECT ',l_object);
            fnd_message.set_token('OBJECT_NAME ',grd_rec.information5);
            fnd_message.raise_error;
         else
            begin
            hr_grade_api.update_grade(p_date_from             => grd_rec.information307
                                     ,p_effective_date	      => p_effective_date
                                     ,p_date_to               => grd_rec.information308
                                     ,p_short_name	      => grd_rec.information102
                                     ,p_grade_id              => l_grade_id
                                     ,p_object_version_number => l_ovn
                                     ,p_concat_segments       => l_concat_segments
                                     ,p_grade_definition_id   => grd_rec.information221
                                     ,p_name                  => grd_rec.information5);
            exception
               when others then
                  hr_utility.set_location('issues in updating grade'||l_grade_id,70);
                  hr_utility.set_location('grade ovn'||l_ovn,75);
                  hr_utility.set_location('grade name'||substr(grd_rec.information5,1,45),78);
                  raise;
            end;
         end if;
      else
         l_message_text := 'invalid operation '||grd_rec.dml_operation
         ||' grd_id'||l_grade_id
         ||' grd_ovn'||l_ovn
         ||' grd_def_id'||grd_rec.information221
         ||' grd_name'||grd_rec.information5;
         PQH_GSP_PROCESS_LOG.LOG_PROCESS_DTLS
         (P_MASTER_TXN_ID  => p_copy_entity_txn_id,
         P_TXN_ID          => nvl(l_grade_id,p_copy_entity_txn_id),
         P_MODULE_CD       => 'PQH_GSP_STGBEN',
         p_context         => 'GRADE',
         P_MESSAGE_TYPE_CD => 'E',
         P_MESSAGE_TEXT    => l_message_text,
         p_effective_date  => p_effective_date);
      end if;
   end loop;
   hr_utility.set_location('leaving '||l_proc,100);
exception
   when others then
      PQH_GSP_PROCESS_LOG.LOG_PROCESS_DTLS
      (P_MASTER_TXN_ID  => p_copy_entity_txn_id,
      P_TXN_ID          => p_copy_entity_txn_id,
      P_MODULE_CD       => 'PQH_GSP_STGBEN',
      p_context         => 'GRADE',
      P_MESSAGE_TYPE_CD => 'E',
      P_MESSAGE_TEXT    => 'Grade',
      p_effective_date  => p_effective_date);
      raise;
end stage_to_grade;
procedure stage_to_step(p_copy_entity_txn_id in number,
                        p_business_group_id  in number,
                        p_effective_date     in date,
                        p_datetrack_mode     in varchar2) is
l_proc varchar2(61) :='stage_to_step';
l_step_id number;
l_step_ovn number;
l_step_seq number;
l_step_esd date;
l_step_eed date;
l_grd_sp_id number;
l_point_id number;
l_message_text varchar2(2000);
l_grd_effstdt date;  --DN code for BugId: 3242976
cursor csr_steps is
      select *
      from ben_copy_entity_results
      where copy_entity_txn_id = p_copy_entity_txn_id
      and table_alias = 'COP'
      and dml_operation = 'INSERT';
begin
   hr_utility.set_location('inside '||l_proc,10);
   for step_rec in csr_steps loop
      l_step_id := step_rec.information253;
      l_step_ovn := step_rec.information254;
      if step_rec.information255 is null then
         select information280
         into l_grd_sp_id
         from ben_copy_entity_results
         where copy_entity_result_id = step_rec.gs_parent_entity_result_id;
      else
         l_grd_sp_id := step_rec.information255;
      end if;
      if step_rec.information256 is null and step_rec.information262 is not null then
         select information257
         into l_point_id
         from ben_copy_entity_results
         where copy_entity_result_id = step_rec.information262;
      else
         l_point_id := step_rec.information256;
      end if;
      if step_rec.dml_operation ='INSERT'
         and step_rec.information253 is null
         and step_rec.information104 = 'LINK'
         and l_grd_sp_id is not null
         and l_point_id is not null then
         hr_utility.set_location('going for ins',20);
         hr_utility.set_location('sequence '||step_rec.information263,20);
         hr_utility.set_location('point id is '||l_point_id,20);
         hr_utility.set_location('grade spine'||l_grd_sp_id,20);
         --DN: Start code for BugId: 3242976
         -- Create step as of grade spine start date
         begin
            SELECT pgs.EFFECTIVE_START_DATE
              INTO l_grd_effstdt
              FROM per_grade_spines_f pgs
             WHERE pgs.grade_spine_id     = l_grd_sp_id
               AND p_effective_date BETWEEN pgs.effective_start_date
                                    AND pgs.effective_end_date;
         exception
            WHEN OTHERS THEN
                l_grd_effstdt := p_effective_date;
         end;
         --End code for BugId: 3242976
         hr_grade_step_api.create_grade_step
         (p_effective_date         => l_grd_effstdt --p_effective_date  --DN code for BugId: 3242976
         ,p_business_group_id      => p_business_group_id
         ,p_effective_start_date   => l_step_esd
         ,p_effective_end_date     => l_step_eed
         ,p_grade_spine_id         => l_grd_sp_id
         ,p_sequence               => step_rec.information263
         ,p_spinal_point_id        => l_point_id
         ,p_step_id                => l_step_id
         ,p_object_version_number  => l_step_ovn
         );
         hr_utility.set_location('ins done '||l_step_id,22);
         step_writeback(p_copy_entity_txn_id => p_copy_entity_txn_id,
                        p_step_id            => l_step_id,
                        p_step_cer_id        => step_rec.copy_entity_result_id,
                        p_effective_date     => p_effective_date);
         hr_utility.set_location('step_writeback done',22);
         if nvl(step_rec.information98,'N') = 'Y' and l_step_id is not null then
            hr_utility.set_location('ceiling step, update grd_sp',23);
            begin
               update per_grade_spines_f
               set ceiling_step_id = l_step_id
               where grade_spine_id = l_grd_sp_id
               and p_effective_date between effective_start_date and effective_end_date;
               hr_utility.set_location('num of grd_sps updated'||sql%rowcount,20);
            exception
               when others then
                  hr_utility.set_location('issue in upd ceil step'||l_step_id,23);
                  hr_utility.set_location('for grd_sp '||l_grd_sp_id,23);
                  raise;
            end;
         else
            hr_utility.set_location('not a ceiling step',24);
         end if;
      else
         l_message_text := 'invalid operation '||step_rec.dml_operation
         ||' step id is '||step_rec.information253
         ||' point id is '||l_point_id
         ||' grade_spine id is '||l_grd_sp_id
         ||' link flag is '||step_rec.information104;
         PQH_GSP_PROCESS_LOG.LOG_PROCESS_DTLS
         (P_MASTER_TXN_ID  => p_copy_entity_txn_id,
         P_TXN_ID          => nvl(l_step_id,p_copy_entity_txn_id),
         P_MODULE_CD       => 'PQH_GSP_STGBEN',
         p_context         => 'STEP',
         P_MESSAGE_TYPE_CD => 'E',
         P_MESSAGE_TEXT    => l_message_text,
         p_effective_date  => p_effective_date);
      end if;
   end loop;
   hr_utility.set_location('leaving '||l_proc,100);
exception
   when others then
      hr_utility.set_location('issues with steps '||l_proc,420);
      PQH_GSP_PROCESS_LOG.LOG_PROCESS_DTLS
      (P_MASTER_TXN_ID  => p_copy_entity_txn_id,
      P_TXN_ID          => p_copy_entity_txn_id,
      P_MODULE_CD       => 'PQH_GSP_STGBEN',
      p_context         => 'STEP',
      P_MESSAGE_TYPE_CD => 'E',
      P_MESSAGE_TEXT    => 'STEP',
      p_effective_date  => p_effective_date);
      raise;
end stage_to_step;
Procedure stage_to_scale(p_copy_entity_txn_id in number,
                         p_business_group_id  in number,
                         p_effective_date     in date,
                         p_business_area      in varchar2 default 'PQH_GSP_TASK_LIST') is
l_proc varchar2(61) :='scale_to_stage';
l_scale_id number;
l_object varchar2(80);
l_scale_ovn number;
l_db_ovn number;
l_message_text varchar2(2000);
cursor csr_scales is
      select *
      from ben_copy_entity_results
      where copy_entity_txn_id = p_copy_entity_txn_id
      and table_alias ='SCALE'
      and dml_operation in ('INSERT','UPDATE');
begin
   hr_utility.set_location('inside'||l_proc,10);
   for scl_rec in csr_scales loop
      l_scale_ovn := scl_rec.information254;
      l_scale_id := scl_rec.information1;
      if scl_rec.dml_operation = 'INSERT'
         and l_scale_id is null
         and scl_rec.information98 is not null then
         hr_utility.set_location('new scale is being created'||l_proc,20);
         hr_utility.set_location('incr_fre'||scl_rec.information253,20);
         hr_utility.set_location('incr_per'||scl_rec.information99,20);
         hr_utility.set_location('scale_id'||l_scale_id,20);
         hr_utility.set_location('scl_ovn'||l_scale_ovn,20);
         hr_utility.set_location('bus_area is'||p_business_area,20);
         if p_business_area = 'PQH_CORPS_TASK_LIST' then
            pqh_cpd_hr_to_stage.create_scale(p_scale_id             => l_scale_id,
                                             p_scale_ovn            => l_scale_ovn,
                                             p_information_category => scl_rec.information101,
                                             p_information1         => scl_rec.information112,
                                             p_information2         => scl_rec.information113,
                                             p_business_group_id    => p_business_group_id,
                                             p_name                 => scl_rec.information98,
                                             p_effective_date       => p_effective_date ,
                                             p_increment_frequency  => scl_rec.information253,
                                             p_increment_period     => scl_rec.information99);
         else
            begin
               hr_pay_scale_api.create_pay_scale
                (p_business_group_id     => p_business_group_id
                ,p_name                  => scl_rec.information98
                ,p_effective_date        => p_effective_date
                ,p_increment_frequency   => scl_rec.information253
                ,p_increment_period      => scl_rec.information99
                ,p_parent_spine_id       => l_scale_id
                ,p_object_version_number => l_scale_ovn
                 ) ;
            exception
               when others then
                  hr_utility.set_location('issues in creating scale'||scl_rec.information98,30);
                  raise;
            end;
         end if;
         hr_utility.set_location('scale id is '||l_scale_id,30);
         scl_writeback(p_copy_entity_txn_id => p_copy_entity_txn_id,
                       p_scale_id           => l_scale_id,
                       p_scale_cer_id       => scl_rec.copy_entity_result_id);
         hr_utility.set_location('scale writeback comp'||l_scale_id,40);
      elsif scl_rec.dml_operation ='UPDATE' and l_scale_id is not null
            and scl_rec.information98 is not null  and l_scale_ovn is not null then
         hr_utility.set_location('scale is being updated'||l_proc,60);
         l_db_ovn := pqh_gsp_stage_to_ben.get_ovn
                            (p_table_name       => 'PER_PARENT_SPINES',
                             p_key_column_name  => 'PARENT_SPINE_ID',
                             p_key_column_value => l_scale_id);
         hr_utility.set_location(' ovn is '||l_db_ovn,30);
         if l_db_ovn <> l_scale_ovn then
            l_object := hr_general.decode_lookup('PQH_GSP_OBJECT_TYPE','SCALE');
            fnd_message.set_name('PQH','PQH_GSP_OBJ_OVN_INVALID');
            fnd_message.set_token('OBJECT ',l_object);
            fnd_message.set_token('OBJECT_NAME ',scl_rec.information98);
            fnd_message.raise_error;
         else
            if p_business_area = 'PQH_CORPS_TASK_LIST' then
               pqh_cpd_hr_to_stage.update_scale(p_scale_id             => l_scale_id,
                                                p_scale_ovn            => l_scale_ovn,
                                                p_information_category => scl_rec.information101,
                                                p_information1         => scl_rec.information112,
                                                p_information2         => scl_rec.information113,
                                                p_business_group_id    => p_business_group_id,
                                                p_name                 => scl_rec.information98,
                                                p_effective_date       => p_effective_date ,
                                                p_increment_frequency  => scl_rec.information253,
                                                p_increment_period     => scl_rec.information99);
            else
               begin
                  hr_pay_scale_api.update_pay_scale
                   (p_name                  => scl_rec.information98
                   ,p_increment_frequency   => scl_rec.information253
                   ,p_increment_period      => scl_rec.information99
                   ,p_parent_spine_id       => l_scale_id
                   ,p_object_version_number => l_scale_ovn
                    ) ;
               exception
                  when others then
                     hr_utility.set_location('issues in updating scale'||l_scale_id,70);
                     hr_utility.set_location('scale ovn'||l_scale_ovn,75);
                     hr_utility.set_location('scale name'||substr(scl_rec.information98,1,45),78);
                     raise;
               end;
            end if;
         end if;
      else
         l_message_text := 'invalid operation '||scl_rec.dml_operation
                           ||' scale id is '||l_scale_id
                           ||' scale ovn is '||l_scale_ovn
                           ||' scale name'||scl_rec.information98;
         PQH_GSP_PROCESS_LOG.LOG_PROCESS_DTLS
         (P_MASTER_TXN_ID  => p_copy_entity_txn_id,
         P_TXN_ID          => nvl(l_scale_id,p_copy_entity_txn_id),
         P_MODULE_CD       => 'PQH_GSP_STGBEN',
         p_context         => 'SCALE',
         P_MESSAGE_TYPE_CD => 'E',
         P_MESSAGE_TEXT    => l_message_text,
         p_effective_date  => p_effective_date);
      end if;
   end loop;
   hr_utility.set_location('leaving '||l_proc,420);
exception
   when others then
      hr_utility.set_location('issue in scale writing'||l_proc,520);
      PQH_GSP_PROCESS_LOG.LOG_PROCESS_DTLS
      (P_MASTER_TXN_ID  => p_copy_entity_txn_id,
      P_TXN_ID          => p_copy_entity_txn_id,
      P_MODULE_CD       => 'PQH_GSP_STGBEN',
      p_context         => 'SCALE',
      P_MESSAGE_TYPE_CD => 'E',
      P_MESSAGE_TEXT    => 'SCALE',
      p_effective_date  => p_effective_date);
      raise;
end stage_to_scale;
procedure stage_to_hrate(p_copy_entity_txn_id in number,
                         p_business_group_id  in number,
                         p_gl_currency        in varchar2,
                         p_effective_date     in date,
                         p_datetrack_mode     in varchar2) is
   l_proc varchar2(61) :='stage_to_hrate';
   l_payrate_id number;
   l_hrrate_id number;
   l_old_grd_cer_id number;
   l_old_pnt_cer_id number;
   l_old_hrr_id number;
   l_hrr_ovn   number;
   l_db_ovn   number;
   l_old_hrr_ovn   number;
   l_grd_sp_id number;
   l_rate_type varchar2(30);
   l_dt_mode   varchar2(30);
   l_effective_date date;
   l_hrr_esd   date;
   l_hrr_eed   date;
   l_object varchar2(80);
   l_message_text varchar2(2000);
   l_dml_operation varchar2(30);
   cursor csr_hrr is
      select *
      from ben_copy_entity_results
      where copy_entity_txn_id = p_copy_entity_txn_id
      and   table_alias = 'HRRATE'
      and   dml_operation in ('INSERT','UPDATE')
      order by INFORMATION277,INFORMATION278,INFORMATION2;
begin
   hr_utility.set_location('inside hr rate ',10);
   for hrr_rec in csr_hrr loop
      hr_utility.set_location('hrrate cer is'||hrr_rec.information1,15);
      if hrr_rec.information1 is null then
         if (hrr_rec.information277 is null or hrr_rec.information277 = l_old_grd_cer_id)
         and (hrr_rec.information278 is null or hrr_rec.information278 = l_old_pnt_cer_id) then
            hr_utility.set_location('reusing prev row pk and ovn',16);
            hr_utility.set_location('grd cer is'||hrr_rec.information277,16);
            hr_utility.set_location('pnt cer is'||hrr_rec.information278,16);
            hr_utility.set_location('old grd cer is'||l_old_grd_cer_id,16);
            hr_utility.set_location('old pnt cer is'||l_old_pnt_cer_id,16);
            l_hrrate_id := l_old_hrr_id; -- previous row created id can be used
            l_hrr_ovn := l_old_hrr_ovn;
         else
            l_hrrate_id := hrr_rec.information1;
            l_hrr_ovn := hrr_rec.information298;
         end if;
      else
         l_hrrate_id := hrr_rec.information1;
         l_hrr_ovn := hrr_rec.information298;
      end if;
      l_effective_date := hrr_rec.information2;
      hr_utility.set_location('hrr effdt is'||to_char(l_effective_date,'DD/MM/RRRR'),15);
      l_payrate_id := hrr_rec.information293;
      if hrr_rec.dml_operation = 'INSERT'
         and nvl(hrr_rec.datetrack_mode,'CORRECTION') <> 'UPDATE_REPLACE' then
         l_dml_operation := 'INSERT';
      elsif hrr_rec.dml_operation = 'INSERT' and hrr_rec.datetrack_mode = 'UPDATE_REPLACE' then
         l_dml_operation := 'UPDATE';
      elsif hrr_rec.dml_operation = 'UPDATE' then
         l_dml_operation := 'UPDATE';
      else
         l_dml_operation := '';
      end if;
      hr_utility.set_location('opt cer id is '||hrr_rec.INFORMATION278,3);
      hr_utility.set_location('pl cer id is '||hrr_rec.INFORMATION277,3);
      if hrr_rec.INFORMATION277 is not null and hrr_rec.INFORMATION255 is null then
         hr_utility.set_location('going for getting pl_id ',3);
         begin
            select information223
            into l_grd_sp_id
            from ben_copy_entity_results
            where copy_entity_result_id = hrr_rec.INFORMATION277;
         exception
            when others then
               l_grd_sp_id := null;
         end;
         l_rate_type := 'G';
      elsif hrr_rec.INFORMATION255 is not null then
         l_grd_sp_id := hrr_rec.INFORMATION255;
         l_rate_type := 'G';
      elsif hrr_rec.INFORMATION276 is not null then
         l_grd_sp_id := hrr_rec.INFORMATION276;
         l_rate_type := 'SP';
      elsif hrr_rec.INFORMATION278 is not null and hrr_rec.INFORMATION276 is null then
         hr_utility.set_location('going for getting opt_id ',3);
         begin
            select information257
            into l_grd_sp_id
            from ben_copy_entity_results
            where copy_entity_result_id = hrr_rec.INFORMATION278;
         exception
            when others then
               l_grd_sp_id := null;
         end;
         l_rate_type := 'SP';
      else
         l_grd_sp_id := null;
         hr_utility.set_location('pl id is '||hrr_rec.INFORMATION255,3);
         hr_utility.set_location('pl cer id is '||hrr_rec.INFORMATION277,3);
         hr_utility.set_location('opt id is '||hrr_rec.INFORMATION276,3);
         hr_utility.set_location('opt cer id is '||hrr_rec.INFORMATION278,3);
      end if;
      hr_utility.set_location('grade or point id '||l_grd_sp_id,20);
      if l_dml_operation = 'INSERT'
         and l_hrrate_id is null
         and l_grd_sp_id is not null
         and l_payrate_id is not null then
         hr_utility.set_location('new hrrate is being created'||l_proc,20);
         hr_utility.set_location('grade or point id '||l_grd_sp_id,20);
         hr_utility.set_location('value'||hrr_rec.information297,20);
         hr_utility.set_location('pay rate id'||l_payrate_id,20);
         hr_utility.set_location('hrr_ovn'||l_hrr_ovn,20);
         begin
            hr_rate_values_api.create_rate_value
            (p_effective_date           => l_effective_date
            ,p_business_group_id        => p_business_group_id
            ,p_rate_id                  => l_payrate_id
            ,p_grade_or_spinal_point_id => l_grd_sp_id
            ,p_rate_type                => l_rate_type
            ,p_currency_code            => p_gl_currency
            ,p_maximum                  => hrr_rec.information295
            ,p_mid_value                => hrr_rec.information296
            ,p_minimum                  => hrr_rec.information294
            ,p_value                    => nvl(hrr_rec.information297,0)
            ,p_grade_rule_id            => l_hrrate_id
            ,p_object_version_number    => l_hrr_ovn
            ,p_effective_start_date     => l_hrr_esd
            ,p_effective_end_date       => l_hrr_eed);
         exception
            when others then
               hr_utility.set_location('grade or point id '||l_grd_sp_id,20);
               raise;
         end;
         hr_utility.set_location('hrrate id is '||l_hrrate_id,30);
         hrr_writeback(p_grade_cer_id       => hrr_rec.information277,
                       p_point_cer_id       => hrr_rec.information278,
                       p_copy_entity_txn_id => p_copy_entity_txn_id,
                       p_hrrate_id          => l_hrrate_id);
         hr_utility.set_location('hrrate wrtback comp '||l_hrrate_id,30);
      elsif l_dml_operation ='UPDATE'
            and l_hrrate_id is not null
            and l_grd_sp_id is not null
            and l_hrr_ovn is not null
            and l_payrate_id is not null then
         hr_utility.set_location('hrrate is being updated'||l_proc,60);
         hr_utility.set_location('grade or point id '||l_grd_sp_id,20);
         hr_utility.set_location('value'||hrr_rec.information297,20);
         hr_utility.set_location('pay rate id'||l_payrate_id,20);
         hr_utility.set_location('hrr_ovn'||l_hrr_ovn,20);
         if hrr_rec.datetrack_mode <> 'CORRECTION' then
            l_dt_mode := pqh_gsp_stage_to_ben.get_update_mode
                            (p_table_name       => 'PAY_GRADE_RULES_F',
                             p_key_column_name  => 'GRADE_RULE_ID',
                             p_key_column_value => l_hrrate_id,
                             p_effective_date   => l_effective_date);
         else
            l_dt_mode := hrr_rec.datetrack_mode;
         end if;
         hr_utility.set_location(' dt mode is '||l_dt_mode,30);
         l_db_ovn := pqh_gsp_stage_to_ben.get_ovn
                            (p_table_name         => 'PAY_GRADE_RULES_F',
                             p_key_column_name    => 'GRADE_RULE_ID',
                             p_key_column_value   => l_hrrate_id,
                             p_effective_date     => l_effective_date);
         hr_utility.set_location(' ovn is '||l_db_ovn,30);
         if l_db_ovn <> l_hrr_ovn then
            l_object := hr_general.decode_lookup('PQH_GSP_OBJECT_TYPE','HRRATE');
            fnd_message.set_name('PQH','PQH_GSP_OBJ_OVN_INVALID');
            fnd_message.set_token('OBJECT ',l_object);
            fnd_message.set_token('OBJECT_NAME ',l_rate_type ||':'|| l_grd_sp_id);
            fnd_message.raise_error;
         else
            begin
            hr_rate_values_api.update_rate_value
            (p_effective_date           => l_effective_date
            ,p_currency_code            => p_gl_currency
            ,p_maximum                  => hrr_rec.information295
            ,p_mid_value                => hrr_rec.information296
            ,p_minimum                  => hrr_rec.information294
            ,p_value                    => nvl(hrr_rec.information297,0)
            ,p_grade_rule_id            => l_hrrate_id
            ,p_datetrack_mode           => l_dt_mode
            ,p_object_version_number    => l_hrr_ovn
            ,p_effective_start_date     => l_hrr_esd
            ,p_effective_end_date       => l_hrr_eed);
            exception
            when others then
               hr_utility.set_location('grade or point id '||l_grd_sp_id,20);
               raise;
            end;
         end if;
         hr_utility.set_location('hrrate id is '||l_hrrate_id,30);
      else
         l_message_text := 'invalid operation '||l_dml_operation
         ||' hrrate id is '||l_hrrate_id
         ||' grade or point id '||l_grd_sp_id
         ||' payrate'||l_payrate_id
         ||' hrr_ovn'||l_hrr_ovn
         ||' rate type'||l_rate_type
         ||' dt mode'||hrr_rec.datetrack_mode;
         PQH_GSP_PROCESS_LOG.LOG_PROCESS_DTLS
         (P_MASTER_TXN_ID  => p_copy_entity_txn_id,
         P_TXN_ID          => nvl(l_hrrate_id,p_copy_entity_txn_id),
         P_MODULE_CD       => 'PQH_GSP_STGBEN',
         p_context         => 'GRADE_RATE',
         P_MESSAGE_TYPE_CD => 'E',
         P_MESSAGE_TEXT    => l_message_text,
         p_effective_date  => p_effective_date);
      end if;
      l_old_hrr_id := l_hrrate_id;
      l_old_hrr_ovn := l_hrr_ovn;
      l_old_grd_cer_id := hrr_rec.information277;
      l_old_pnt_cer_id := hrr_rec.information278;
   end loop;
   hr_utility.set_location('leaving hr rate ',420);
exception
   when others then
      PQH_GSP_PROCESS_LOG.LOG_PROCESS_DTLS
      (P_MASTER_TXN_ID  => p_copy_entity_txn_id,
      P_TXN_ID          => p_copy_entity_txn_id,
      P_MODULE_CD       => 'PQH_GSP_STGBEN',
      p_context         => 'GRADE_RATE',
      P_MESSAGE_TYPE_CD => 'E',
      P_MESSAGE_TEXT    => 'Grade point Rate',
      p_effective_date  => p_effective_date);
      raise;
end stage_to_hrate;


end pqh_gsp_stage_to_hr;

/
