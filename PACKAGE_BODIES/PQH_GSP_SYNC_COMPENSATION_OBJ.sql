--------------------------------------------------------
--  DDL for Package Body PQH_GSP_SYNC_COMPENSATION_OBJ
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_GSP_SYNC_COMPENSATION_OBJ" as
/* $Header: pqgspwiz.pkb 120.1.12010000.2 2008/08/05 13:35:56 ubhat ship $ */
--
Function delete_plan_for_grade(p_grade_id in number) RETURN varchar2 is
  Cursor Pl is
  Select PL_Id, Effective_Start_Date, Effective_End_Date, Object_version_number
    From Ben_Pl_F
   Where MAPPING_TABLE_NAME  = 'PER_GRADES'
     and MAPPING_TABLE_PK_ID = p_grade_id
     and Hr_general.Effective_Date
 between Effective_Start_Date and Effective_End_Date;

  Cursor Plip (P_Pl_id in Number) Is
  Select plip_Id, Effective_Start_Date, Effective_End_Date, Object_version_number
    From Ben_plip_F
   Where Pl_Id = P_Pl_Id
     and Hr_general.Effective_Date
 between Effective_Start_Date and Effective_End_Date;

L_plip_Ovn_No            Ben_Plip_F.Object_Version_Number%TYPE;
L_Plan_Ovn_No            Ben_Pl_F.Object_Version_Number%TYPE;
L_Effective_Start_Date   Ben_Pl_F.Effective_Start_date%TYPE;
L_Effective_End_Date 	 Ben_Pl_F.Effective_End_date%TYPE;
l_datetrack_mode varchar2(30);
l_eot date;
Begin
  --
  l_eot := to_date('31/12/4712','dd/mm/RRRR');
  -- 1. Fetch the plan for the grade id
  -- 2. Fetch the programs to which the plan is added.
  -- 3. Delete plan in program  records.
  -- 4. Delete the Plan
  For Pl_rec in Pl loop
     hr_utility.set_location('deleting plips for pl '||Pl_Rec.Pl_Id,10);
     For Plip_Rec in Plip(Pl_Rec.Pl_Id) Loop
        hr_utility.set_location('deleting plip '||PLip_rec.Plip_Id,15);
        L_plip_Ovn_No := Plip_Rec.Object_version_number;
        if plip_rec.effective_end_date <> l_eot then
           hr_utility.set_location('not on last row ',19);
           l_datetrack_mode := 'FUTURE_CHANGE';
        else
           hr_utility.set_location('on last row ',18);
           l_datetrack_mode := 'DELETE';
        end if;
        begin
          ben_Plan_in_Program_api.delete_Plan_in_Program
          (p_plip_id                        => PLip_rec.Plip_Id
          ,p_effective_start_date           => L_Effective_Start_Date
          ,p_effective_end_date             => L_Effective_End_Date
          ,p_object_version_number          => L_plip_Ovn_No
          ,p_effective_date                 => Hr_general.Effective_Date
          ,p_datetrack_mode                 => l_datetrack_mode);
       exception
          when others then
             hr_utility.set_location('issues in deleting plip ',30);
             Return 'FAILURE';
       End;
     End Loop;
     hr_utility.set_location('deleting pl '||Pl_Rec.Pl_Id,10);
     L_plan_Ovn_No := Pl_Rec.Object_version_number;
     if pl_rec.effective_end_date <> l_eot then
        hr_utility.set_location('not on last row ',19);
        l_datetrack_mode := 'FUTURE_CHANGE';
     else
        hr_utility.set_location('on last row ',18);
        l_datetrack_mode := 'DELETE';
     end if;
     ben_plan_api.delete_Plan
     (p_pl_id                          => Pl_Rec.Pl_Id
     ,p_effective_start_date           => L_Effective_Start_Date
     ,p_effective_end_date             => L_Effective_End_Date
     ,p_object_version_number          => L_Plan_Ovn_No
     ,p_effective_date                 => Hr_general.Effective_Date
     ,p_datetrack_mode                 => l_datetrack_mode);
  End Loop;
  --
  Return 'SUCCESS';
Exception
  When Others Then
     hr_utility.set_location('issues in deleting pl ',30);
     Return 'FAILURE';
End;
--
--------------------------------------------------------------------------------------
--
Function delete_std_rt_for_grade_rule(p_rate_type                 in varchar2 ,
                                      p_grade_or_spinal_point_id  in number,
                                      p_grade_rule_id             in number,
                                      p_effective_date            in date,
                                      p_datetrack_mode            in varchar2)
RETURN varchar2 is

l_Business_group_id     Ben_Acty_base_Rt_F.business_group_id%TYPE;

Cursor csr_business_group_id
is
select business_group_id
from pay_grade_rules_f
where grade_rule_id =p_grade_rule_id
AND grade_or_spinal_point_id = p_grade_or_spinal_point_id
AND p_effective_date between effective_start_date
and effective_end_date;


 Cursor Rates Is
 Select ACTY_BASE_RT_ID,    Effective_Start_Date,
        Effective_End_Date, Object_version_number
   From Ben_Acty_base_Rt_F
  Where PAY_RATE_GRADE_RULE_ID = p_grade_rule_id
    and p_effective_date
Between Effective_Start_Date and Effective_End_Date
      and business_group_id = l_business_group_id;

 Cursor Csr_Var_rt (P_Acty_Base_Rt_Id IN Number) is
 Select Acty_Vrbl_Rt_Id,
        Object_Version_Number
   From Ben_Acty_Vrbl_Rt_F
  Where Acty_base_rt_Id = P_Acty_Base_rt_Id
    and P_Effective_Date
Between Effective_Start_Date
    and Effective_End_Date;

L_Effective_Start_Date  Ben_Acty_base_Rt_F.Effective_Start_Date%TYPE;
L_Effective_End_Date    Ben_Acty_base_Rt_F.Effective_End_Date%TYPE;
l_Object_version_Number Ben_Acty_base_Rt_F.Object_version_Number%TYPE;

L_Vrbl_Esd         Ben_Acty_Vrbl_Rt_F.Effective_Start_Date%TYPE;
L_Vrbl_Eed         Ben_Acty_Vrbl_Rt_F.Effective_End_Date%TYPE;
l_Vrbl_ovn         Ben_Acty_Vrbl_Rt_F.Object_version_Number%TYPE;

Begin
  --
  -- 1. Find the Standard rate which references the grade rule.
  -- 2. Delete the Standard rate.

  hr_utility.set_location('grade rule id is '||p_grade_rule_id,10);
  hr_utility.set_location('rate type is '||p_rate_type,11);
  hr_utility.set_location('grade /point id is '||p_grade_or_spinal_point_id,12);
  hr_utility.set_location('effdt is '||to_char(p_effective_date,'dd-mm-RRRR:hh-mm-ss'),13);

  OPEN csr_business_group_id;
  FETCH csr_business_group_id INTO l_Business_group_id;
  CLOSE csr_business_group_id;

  For Rates_Rec in Rates Loop

     For Var_Rec in Csr_Var_Rt (Rates_Rec.ACTY_BASE_RT_ID)
     Loop

        hr_utility.set_location('Delete VAR Rate' || Var_Rec.ACTY_VRBL_RT_ID ,15);
        If Var_Rec.Acty_Vrbl_rt_Id is NOT NULL then

           l_Vrbl_ovn := Var_rec.Object_Version_Number;

           BEN_ACTY_VRBL_RATE_API.DELETE_ACTY_VRBL_RATE
          (P_ACTY_VRBL_RT_ID              => Var_Rec.ACTY_VRBL_RT_ID
          ,P_EFFECTIVE_START_DATE         => L_Vrbl_esd
          ,P_EFFECTIVE_END_DATE           => l_Vrbl_Eed
          ,P_OBJECT_VERSION_NUMBER        => l_Vrbl_Ovn
          ,P_EFFECTIVE_DATE               => P_Effective_Date
          ,P_DATETRACK_MODE               => p_datetrack_mode);

        End If;
     End Loop;

     hr_utility.set_location('abr to be deleted is '||Rates_Rec.ACTY_BASE_RT_ID,20);
     l_Object_version_Number := Rates_Rec.Object_version_number;
     ben_acty_base_rate_api.delete_acty_base_rate
     (p_acty_base_rt_id                => Rates_Rec.ACTY_BASE_RT_ID
     ,p_effective_start_date           => L_Effective_Start_Date
     ,p_effective_end_date             => L_Effective_End_Date
     ,p_object_version_number          => l_Object_version_Number
     ,p_effective_date                 => p_effective_date
     ,p_datetrack_mode                 => p_datetrack_mode);

  End Loop;
  --
  Return 'SUCCESS';
  --
Exception
When Others Then
     hr_utility.set_location('issues in deleting abr ',30);
     Return 'FAILURE';
End;
--
--------------------------------------------------------------------------------------
--
Function delete_option_for_point(p_spinal_point_id in number)
RETURN varchar2 is
l_effective_date date;
  Cursor Opts Is
  Select Opt_id            , Effective_Start_Date,
         Effective_End_Date, Object_version_number
    From Ben_Opt_F
   Where MAPPING_TABLE_NAME  = 'PER_SPINAL_POINTS'
     and MAPPING_TABLE_PK_ID = p_spinal_point_id
     and l_Effective_Date
 between Effective_Start_Date and Effective_End_Date;

 Cursor csr_Pl_Opt_Type (P_Opt_Id IN Number) is
 Select Pl_typ_opt_Typ_Id,
        Effective_Start_Date,
	Effective_End_Date,
	Object_Version_Number
   from Ben_Pl_Typ_Opt_Typ_F
  Where Opt_Id = P_Opt_id
    and Pl_Typ_Opt_Typ_Cd = 'GSP';

L_Ovn_No               Ben_Opt_F.Object_version_Number%TYPE;
L_Effective_Start_Date Ben_Opt_F.Effective_Start_Date%TYPE;
L_Effective_End_Date   Ben_Opt_F.Effective_End_Date%TYPE;
l_datetrack_mode varchar2(30);
l_eot date;

l_Pl_Typ_Opt_Typ_Id   Ben_Pl_Typ_Opt_Typ_F.Pl_Typ_Opt_Typ_Id%TYPE;
l_opt_typ_Esd         Ben_Pl_Typ_Opt_Typ_F.Effective_Start_Date%TYPE;
l_Opt_Typ_Eed         Ben_Pl_Typ_Opt_Typ_F.Effective_End_Date%TYPE;
l_Opt_typ_Ovn         Ben_Pl_Typ_Opt_Typ_F.Object_Version_Number%TYPE;
Begin
  --
  l_effective_date  := Hr_general.Effective_Date;
  l_eot := to_date('31/12/4712','dd/mm/RRRR');
  --
  --1. Find the option corresponding to the spinal point.
  --2. Delete the option. No need to delete option in plan records
  -- as it will not be able to delete the spinal point if steps are there.

  hr_utility.set_location('spinal point is '||p_spinal_point_id,15);
  hr_utility.set_location('effdt is '||to_char(l_effective_date,'dd-mm-RRRR:hh-mm-ss'),18);
  For Opts_Rec in Opts Loop
     hr_utility.set_location('opt to be deleted is'||Opts_Rec.Opt_id,20);
     L_ovn_No := opts_rec.Object_version_number;

    /* if opts_rec.effective_end_date <> l_eot then
        hr_utility.set_location('not on last row ',19);
        l_datetrack_mode := 'FUTURE_CHANGE';
     else
        hr_utility.set_location('on last row ',18);
        l_datetrack_mode := 'DELETE';
     end if; */
     l_datetrack_mode := 'ZAP';
     Open csr_Pl_Opt_Type(Opts_Rec.Opt_id);
     Fetch csr_Pl_Opt_Type into l_Pl_Typ_Opt_Typ_Id, l_opt_typ_Esd, l_Opt_Typ_Eed, l_Opt_typ_Ovn;
     Close csr_Pl_Opt_Type;

     hr_utility.set_location('PLOptTyp to be deleted is'||l_Pl_Typ_Opt_Typ_Id,30);

     ben_plan_type_option_type_api.Delete_Plan_Type_Option_Type
    (P_PL_TYP_OPT_TYP_ID            =>  l_Pl_Typ_Opt_Typ_Id
    ,P_EFFECTIVE_START_DATE         =>  l_opt_typ_Esd
    ,P_EFFECTIVE_END_DATE           =>  l_Opt_Typ_Eed
    ,P_OBJECT_VERSION_NUMBER        =>  l_Opt_typ_Ovn
    ,P_EFFECTIVE_DATE               =>  l_Effective_Date
    ,P_DATETRACK_MODE               =>  l_datetrack_mode);

    hr_utility.set_location('PLOptTyp Deleted',40);

     ben_option_definition_api.delete_option_definition
    (p_opt_id                         => Opts_Rec.Opt_id
    ,p_effective_start_date           => L_Effective_Start_Date
    ,p_effective_end_date             => L_Effective_End_Date
    ,p_object_version_number          => L_ovn_No
    ,p_effective_date                 => l_Effective_Date
    ,p_datetrack_mode                 => l_datetrack_mode);
  End Loop;
  Return 'SUCCESS';
  --
Exception
When Others Then
     hr_utility.set_location('issues in deleting opt ',30);
     Return 'FAILURE';
End;
--
--------------------------------------------------------------------------------
--
Function delete_oipl_for_step(p_grade_id        in number,
                              p_spinal_point_id in number,
                              p_step_id         in number,
                              p_effective_date  in date,
                              p_datetrack_mode  in varchar2)
RETURN varchar2 is

  Cursor Oipl Is
  Select Oipl.Oipl_id           , Oipl.Effective_Start_Date,
         Oipl.Effective_End_Date, Oipl.Object_version_number
    From Ben_Oipl_F Oipl, Ben_Opt_F opt, Ben_pl_F Pl
   Where Opt.MAPPING_TABLE_NAME  = 'PER_SPINAL_POINTS'
     and Opt.MAPPING_TABLE_PK_ID = p_spinal_point_id
     and p_effective_date
 between Opt.Effective_Start_Date and Opt.Effective_End_Date
     and Pl.MAPPING_TABLE_NAME    = 'PER_GRADES'
     and Pl.MAPPING_TABLE_PK_ID   = p_grade_id
     and p_effective_date
 between Pl.Effective_Start_Date and Pl.Effective_End_Date
     and Opt.Opt_id               = Oipl.Opt_id
     and Pl.Pl_Id		  = Oipl.Pl_Id
     and p_effective_date
 between Oipl.Effective_Start_Date and Oipl.Effective_End_Date;

 L_Effective_Start_Date  Ben_Oipl_F.Effective_Start_Date%TYPE;
 L_Effective_End_Date    Ben_Oipl_F.Effective_End_Date%TYPE;
 l_Object_version_Number Ben_Oipl_F.Object_version_Number%TYPE;

Begin
  --
  -- 1. Find the option in plan record corresponding to the step.
  -- 2. Do not allow deleting the step, if it is the last step in the
  --    grade and the grade ladder is setup for 'Step' or 'Grade-Step' progression
  -- 3. Delete the option in plan records.

  hr_utility.set_location('grade is '||p_grade_id,10);
  hr_utility.set_location('spinal point is '||p_spinal_point_id,15);
  hr_utility.set_location('effdt is '||to_char(p_effective_date,'dd-mm-RRRR:hh-mi-ss'),18);
  For Oipl_Rec in Oipl Loop
     hr_utility.set_location('oipl for deletion is '||Oipl_Rec.Oipl_Id,30);
     l_Object_version_Number := Oipl_Rec.Object_Version_Number;
     ben_Option_in_Plan_api.delete_Option_in_Plan
    (p_oipl_id                        => Oipl_Rec.Oipl_Id
    ,p_effective_start_date           => L_Effective_Start_Date
    ,p_effective_end_date             => L_Effective_End_Date
    ,p_object_version_number          => l_Object_version_Number
    ,p_effective_date                 => p_effective_date
    ,p_datetrack_mode                 => p_datetrack_mode);
  End Loop;
  Return 'SUCCESS';
  --
Exception
When Others Then
     hr_utility.set_location('issues in deleting oipl ',30);
     Return 'FAILURE';
End;

--
----------------------------------------------------------------------------------------
--
function chk_oipl_for_step(p_pl_id          in number,
                           p_opt_id         in number,
                           p_effective_date in date) return boolean is
   l_oipl_id number;
begin
   if p_pl_id is not null and p_opt_id is not null then
      begin
         select oipl_id
         into l_oipl_id
         from ben_oipl_f
         where pl_id = p_pl_id
         and opt_id = p_opt_id
         and p_effective_date between effective_start_date and effective_end_date;
         hr_utility.set_location('oipl is '||l_oipl_id,30);
         return true;
      exception
         when no_data_found then
            hr_utility.set_location('invalid oipl for pl'||p_pl_id,100);
            return false;
         when others then
            hr_utility.set_location('issues in selecting oipl detail',120);
            return false;
      end;
   else
      hr_utility.set_location('either plan or opt is null',150);
      return false;
   end if;
end chk_oipl_for_step;
--
----------------------------------------------------------------------------------------
--
function get_max_oipl_seq(p_pl_id          in number,
                          p_opt_id         in number,
                          p_effective_date in date) return number is
   l_max_seq number;
begin
   if p_pl_id is not null and p_opt_id is not null then
      begin
         select max(ordr_num)
         into l_max_seq
         from ben_oipl_f
         where pl_id = p_pl_id
         and p_effective_date between effective_start_date and effective_end_date;
         hr_utility.set_location('max seq is '||l_max_seq,10);
         l_max_seq := nvl(l_max_seq,0) + 1;
         return l_max_seq;
      exception
         when no_data_found then
            hr_utility.set_location('invalid oipl for pl'||p_pl_id,100);
            return 1;
         when others then
            hr_utility.set_location('issues in selecting oipl detail',120);
            raise;
      end;
   else
      hr_utility.set_location('either plan or opt is null',150);
      return 1;
   end if;
end get_max_oipl_seq;
--
----------------------------------------------------------------------------------------
--
------------------------------------------------------------------------------
--
Function create_option_for_point(p_spinal_point_id   in number,
                                 p_pay_scale_name    in varchar2,
                                 p_business_group_id in number,
                                 p_spinal_point_name in varchar2)
RETURN varchar2 is

l_effective_date date;

Cursor csr_opt_exists is
Select opt_id
  From ben_opt_f
 Where mapping_table_name = 'PER_SPINAL_POINTS'
   and mapping_table_pk_id = p_spinal_point_id;
--
--
Cursor get_pl_typ is
Select pl_typ_id
From ben_pl_typ_f
Where opt_typ_cd = 'GSP'
and business_group_id = p_business_group_id
and l_effective_date between effective_start_date and effective_end_date;

L_Effective_Start_Date Ben_Opt_F.Effective_Start_Date%TYPE;
L_Effective_End_Date   Ben_Opt_F.Effective_End_Date%TYPE;
l_ovn_no               ben_Opt_F.Object_Version_Number%TYPE;
L_opt_id               ben_opt_F.Opt_Id%TYPE;
l_opt_exists           varchar2(10);
--
l_pl_typ_id            ben_pl_typ_f.pl_typ_id%type;
l_pl_typ_opt_typ_id    ben_pl_typ_opt_typ_f.pl_typ_opt_typ_id%type;
l_continue             boolean;
--
Begin
  --
  l_effective_date := pqh_gsp_utility.get_gsp_plntyp_str_date(p_business_group_id, null);
  l_opt_exists  := 'N';
  l_continue := true;
  -- Get the plan type that is to be linked.Assuming that there can be only
  -- one plan type of option type 'GSP'.
  --
  hr_utility.set_location('Entering create_option',5);
  Open get_pl_typ;
  Fetch get_pl_typ into l_pl_typ_id;
  If get_pl_typ%notfound then
    Close get_pl_typ;
    hr_utility.set_location('No plan type found ',5);
    return 'FAILURE';
  End if;
  Close get_pl_typ;
  hr_utility.set_location('plan type found '|| to_char(l_pl_typ_id),5);
  --
  -- Check if the option exists for the point
  --
  Open csr_opt_exists;
  Fetch csr_opt_exists into L_opt_id;
  If csr_opt_exists%notfound then
     l_opt_exists := 'N';
  Else
     l_opt_exists := 'Y';
  End if;
  Close csr_opt_exists;
  -- 1. Generate the name for the option.
  -- 2. Create the option if it does not already exist for the point.
  --
  If l_opt_exists = 'N' then
  --
  hr_utility.set_location('Creating option for '|| p_spinal_point_name,5);
  ben_option_definition_api.create_option_definition
     (P_OPT_ID                       => L_opt_id
     ,P_EFFECTIVE_START_DATE         => L_Effective_Start_Date
     ,P_EFFECTIVE_END_DATE           => L_Effective_End_Date
     ,P_NAME                         => p_pay_scale_name||':'||p_spinal_point_name
     ,P_BUSINESS_GROUP_ID            => p_Business_Group_id
     ,P_OBJECT_VERSION_NUMBER        => l_ovn_no
     ,P_MAPPING_TABLE_NAME           => 'PER_SPINAL_POINTS'
     ,P_MAPPING_TABLE_PK_ID          => P_Spinal_point_Id
     ,P_EFFECTIVE_DATE               => l_effective_date );
  --
  -- Also create plan type option type link.
  --
  hr_utility.set_location('plan type option type'|| p_spinal_point_name,5);
  ben_plan_type_option_type_api.create_plan_type_option_type
  (
   p_validate                       => false
  ,p_pl_typ_opt_typ_id              => l_pl_typ_opt_typ_id
  ,p_effective_start_date           => l_effective_start_date
  ,p_effective_end_date             => l_effective_end_date
  ,p_pl_typ_opt_typ_cd              => 'GSP'
  ,p_opt_id                         => l_opt_id
  ,p_pl_typ_id                      => l_pl_typ_id
  ,p_business_group_id              => P_Business_Group_id
  ,p_object_version_number          => l_ovn_no
  ,p_effective_date                 => l_effective_date
 );

  End if;
  --
  hr_utility.set_location('Leaving create_option',10);
  Return 'SUCCESS';
  --
End;
--
Function create_oipl_for_step(p_grade_id        in number,
                              p_spinal_point_id in number,
                              p_step_id         in number,
                              p_effective_date  in date,
                              p_datetrack_mode  in varchar2)
RETURN varchar2 is

  Cursor Pl is
  Select PL_Id, Effective_Start_Date, Effective_End_Date,business_group_id
    From Ben_Pl_F
   Where MAPPING_TABLE_NAME  = 'PER_GRADES'
     and MAPPING_TABLE_PK_ID = p_grade_id
     and p_effective_date between Effective_Start_Date and Effective_End_Date;

  cursor point is
  select psp.spinal_point_id spinal_point_id,psp.spinal_point spinal_point,pps.name scale_name
  from per_spinal_points psp, per_parent_spines pps
  where psp.spinal_point_id = p_spinal_point_id
  and   psp.parent_spine_id = pps.parent_spine_id;

  Cursor Opt Is
  Select opt.Opt_id        , opt.Effective_Start_Date,
         opt.Effective_End_Date,step.sequence ordr_num
    From Ben_Opt_F opt, Per_Spinal_POint_Steps_F Step
   Where Opt.MAPPING_TABLE_NAME  = 'PER_SPINAL_POINTS'
     and Opt.MAPPING_TABLE_PK_ID = p_spinal_point_id
     and p_effective_date
 between Opt.Effective_Start_Date and Opt.Effective_End_Date
     and Step.Step_id = P_Step_id
     and p_effective_date
 between Step.Effective_Start_Date and Step.Effective_End_Date
     and Step.Spinal_Point_id = p_spinal_point_id;

l_Oipl_id               Ben_oipl_f.oipl_Id%TYPE;
l_effective_Start_Date  Ben_Oipl_F.Effective_Start_Date%TYPE;
L_Effective_End_Date    Ben_Oipl_F.Effective_End_Date%TYPE;
l_bg_id                 Ben_opt_F.Business_Group_id%TYPE;
l_ovn_no 		ben_oipl_f.Object_Version_Number%TYPE;
l_oipl_exists boolean;
l_max_oipl_seq number;
l_continue varchar2(30);
Begin
  --
  --
  l_continue := 'SUCCESS';
  -- Effective Date 1951
  -- 1. Find the plan and option corresponding to the grade and spinal point.
  -- 2. Create a option in plan record.
  --
  For Pl_Rec in Pl Loop
     l_bg_id := pl_Rec.Business_group_id;
     hr_utility.set_location('pl id is'||pl_rec.pl_id,10);
     for pt_rec in point loop
        hr_utility.set_location('pt is '||pt_rec.spinal_point_id,15);
        begin
           l_continue := create_option_for_point(p_spinal_point_id   => pt_rec.spinal_point_id,
                                                 p_pay_scale_name    => pt_rec.scale_name,
                                                 p_business_group_id => l_bg_id,
                                                 p_spinal_point_name => pt_rec.spinal_point);
        exception
           when others then
              hr_utility.set_location('issues in creating option',15);
              raise;
        End;
     end loop;
     if l_continue <> 'SUCCESS' then
        return 'FAILURE';
     else
     For Opt_Rec in OPt Loop
        hr_utility.set_location('opt id is'||opt_rec.opt_id,20);
        l_oipl_exists := chk_oipl_for_step(p_pl_id          => pl_rec.pl_id,
                                           p_opt_id         => opt_rec.opt_id,
                                           p_effective_date => p_effective_date);
        if not l_oipl_exists and pl_rec.pl_id is not null and opt_rec.opt_id is not null then
           hr_utility.set_location('going for oipl create',30);
--start bug fix 6239174
          /* if l_max_oipl_seq is null then
              l_max_oipl_seq := get_max_oipl_seq(p_pl_id          => pl_rec.pl_id,
                                                 p_opt_id         => opt_rec.opt_id,
                                                 p_effective_date => p_effective_date);
           else
              l_max_oipl_seq := l_max_oipl_seq + 1;
           end if;*/
	if Opt_Rec.ordr_num is null then
                l_max_oipl_seq := get_max_oipl_seq(p_pl_id          => pl_rec.pl_id,
                                                 p_opt_id         => opt_rec.opt_id,
                                                 p_effective_date => p_effective_date);
           else
              l_max_oipl_seq := Opt_Rec.ordr_num;
           end if;
--end bug fix 6239174
           hr_utility.set_location('seq is '||l_max_oipl_seq,31);
           ben_Option_in_Plan_api.create_Option_in_Plan
          (p_oipl_id                        => l_Oipl_id
          ,p_effective_start_date           => l_effective_Start_Date
          ,p_effective_end_date             => l_Effective_End_Date
          ,p_opt_id                         => Opt_Rec.Opt_id
          ,p_business_group_id              => l_bg_id
          ,p_pl_id                          => pl_Rec.Pl_Id
          ,p_oipl_stat_cd                   => 'A'
          ,p_auto_enrt_flag                 => 'N'
          ,p_ordr_num                       => l_max_oipl_seq
          ,p_object_version_number          => l_ovn_no
          ,p_effective_date                 => p_effective_date);
        else
           hr_utility.set_location('not enough details exists for oipl creation',40);
        end if;
     --
     End Loop;
     end if;
  End loop;
  hr_utility.set_location('going out ',50);
  Return 'SUCCESS';
  --
Exception
When Others Then
  hr_utility.set_location('issues in creating oipl',40);
  raise;
End;
--
--
END pqh_gsp_sync_compensation_obj;

/
