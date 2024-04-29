--------------------------------------------------------
--  DDL for Package Body PQH_GSP_DEFAULT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_GSP_DEFAULT" as
/* $Header: pqgspdef.pkb 120.0 2005/05/29 01:58 appldev noship $ */
function get_asg_for_pil(p_per_in_ler_id  in number,
                         p_effective_date in date) return number is
   l_assignment_id number;
begin
   select asg.assignment_id
   into l_assignment_id
   from ben_per_in_ler pil,per_all_assignments_f asg
   where p_effective_date between asg.effective_start_date and asg.effective_end_date
   and pil.per_in_ler_id = p_per_in_ler_id
   and pil.person_id = asg.person_id
   and asg.assignment_type = 'E'
   and asg.primary_flag ='Y';
   return l_assignment_id;
exception
   when no_data_found then
      hr_utility.set_location('no asg for pil person '||p_per_in_ler_id,10);
      raise ;
   when others then
      hr_utility.set_location('issue in getting pil person asg '||p_per_in_ler_id,20);
      raise;
end get_asg_for_pil;
procedure get_def_auto_code(p_per_in_ler_id  in number,
                            p_effective_date in date,
                            p_return_code    out nocopy varchar2,
                            p_electbl_chc_id out nocopy number) is
   l_error_message varchar2(2000);
   L_PIL_OVN NUMBER;
   l_procd_dt date;
   l_strtd_dt date;
   l_voidd_dt date;
   l_Assignment_id  Per_All_Assignments_F.Assignment_Id%TYPE;
   l_legislation_code per_business_groups.legislation_code%type;
   l_return_status varchar2(1);

   l_ptnl_ler_for_per_id  ben_ptnl_ler_for_per.ptnl_ler_for_per_id%type;
   l_ptnl_ler_for_per_ovn ben_ptnl_ler_for_per.object_version_number%type;

   cursor csr_ptnl_ler_dtls(cp_per_in_ler_id in number)
   is
   select ptnl.ptnl_ler_for_per_id, ptnl.object_version_number
     from ben_per_in_ler per
         ,ben_ptnl_ler_for_per ptnl
    where per.per_in_ler_id = cp_per_in_ler_id
      and per.ptnl_ler_for_per_id = ptnl.ptnl_ler_for_per_id;

   cursor lesgislation_info is
   Select legislation_code
   from   per_business_groups bg, ben_per_in_ler pil
   where   pil.business_group_id = bg.business_group_id
   and   pil.per_in_ler_id = p_per_in_ler_id;
begin
-- This routine will be called by benmngle run to determine whether out of electable choice progressions
-- any one which is to be marked default or automatic.
-- if none is found to be found to be def or auto then electble_chc_id will be null and return_code ='NONE'

open csr_ptnl_ler_dtls(p_per_in_ler_id);
fetch csr_ptnl_ler_dtls
 into l_ptnl_ler_for_per_id
     ,l_ptnl_ler_for_per_ovn ;
close csr_ptnl_ler_dtls ;

open lesgislation_info;
fetch lesgislation_info into l_legislation_code;
close lesgislation_info;

if l_legislation_code = 'FR' then
      PQH_FR_CR_PATH_ENGINE_PKG.get_elctbl_chc_career_path (p_per_in_ler_id => p_per_in_ler_id,
                                     p_effective_date => p_effective_date,
                                     P_Elig_Per_Elctbl_Chc_Id => p_electbl_chc_id,
                                     p_return_code => p_return_code,
                                     p_return_status => l_return_status);
  end if;

hr_utility.set_location('p_return_code'||p_return_code,10);
hr_utility.set_location('p_electbl_chc_id'||p_electbl_chc_id,10);
hr_utility.set_location('l_return_status'||l_return_status,10);

 if nvl(l_return_status,'N') = 'N'  then
   get_default_progression(p_per_in_ler_id  => p_per_in_ler_id,
                           p_effective_date => p_effective_date,
                           p_electbl_chc_id => p_electbl_chc_id,
                           p_return_code    => p_return_code,
                           p_error_message  => l_error_message);
   if p_electbl_chc_id is null then
      L_PIL_OVN := pqh_gsp_stage_to_ben.get_ovn(p_table_name      => 'BEN_PER_IN_LER',
                                                p_key_column_name  => 'PER_IN_LER_ID',
                                                p_key_column_value => p_per_in_ler_id);
      Ben_Person_Life_Event_api.UPDATE_PERSON_LIFE_EVENT
      (P_PER_IN_LER_ID          => P_PER_IN_LER_ID
      ,P_PER_IN_LER_STAT_CD     => 'VOIDD'
      ,P_PROCD_DT               =>  l_procd_dt
      ,P_STRTD_DT               =>  l_strtd_dt
      ,P_VOIDD_DT               =>  l_voidd_dt
      ,P_OBJECT_VERSION_NUMBER  =>  L_Pil_Ovn
      ,P_EFFECTIVE_DATE         =>  P_Effective_Date);

      ben_ptnl_ler_for_per_api.update_ptnl_ler_for_per
         (p_ptnl_ler_for_per_id           => l_PTNL_LER_FOR_PER_ID
         ,p_ptnl_ler_for_per_stat_cd      => 'VOIDD'
         ,p_voidd_dt                      => p_effective_date
         ,p_object_version_number         => l_PTNL_LER_FOR_PER_OVN
         ,p_effective_date                => p_effective_date);

   end if;
end if;
Exception
When others then
   l_Assignment_id := get_asg_for_pil(P_PER_IN_LER_ID, P_Effective_Date);

   Pqh_Gsp_process_Log.Log_process_Dtls
   (P_Master_txn_Id    => l_Assignment_id
   ,P_Txn_Id           => l_Assignment_id
   ,p_module_cd        => 'PQH_GSP_DFLT_ENRL'
   ,p_message_type_cd  => 'E'
   ,p_message_text     => Nvl(fnd_Message.Get,sqlerrm)
   ,P_Effective_Date   => P_Effective_Date);

   L_PIL_OVN := pqh_gsp_stage_to_ben.get_ovn(p_table_name       => 'BEN_PER_IN_LER',
                                          p_key_column_name  => 'PER_IN_LER_ID',
                                          p_key_column_value => p_per_in_ler_id);

   Ben_Person_Life_Event_api.UPDATE_PERSON_LIFE_EVENT
   (P_PER_IN_LER_ID          => P_PER_IN_LER_ID
   ,P_PER_IN_LER_STAT_CD     => 'VOIDD'
   ,P_PROCD_DT               =>  l_procd_dt
   ,P_STRTD_DT               =>  l_strtd_dt
   ,P_VOIDD_DT               =>  l_voidd_dt
   ,P_OBJECT_VERSION_NUMBER  =>  L_Pil_Ovn
   ,P_EFFECTIVE_DATE         =>  P_Effective_Date);

   ben_ptnl_ler_for_per_api.update_ptnl_ler_for_per
      (p_ptnl_ler_for_per_id           => l_PTNL_LER_FOR_PER_ID
      ,p_ptnl_ler_for_per_stat_cd      => 'VOIDD'
      ,p_voidd_dt                      => p_effective_date
      ,p_object_version_number         => l_PTNL_LER_FOR_PER_OVN
      ,p_effective_date                => p_effective_date);

end get_def_auto_code;
function get_oipl_elect(p_per_in_ler_id in number,
                        p_oipl_id         in number) return number is
   l_electbl_chc_id number;
begin
   select epe.ELIG_PER_ELCTBL_CHC_ID
   into l_electbl_chc_id
   from ben_elig_per_elctbl_chc epe, ben_per_in_ler pil
   where pil.per_in_ler_id = epe.per_in_ler_id
   and pil.per_in_ler_id = p_per_in_ler_id
   and pil.per_in_ler_stat_cd = 'STRTD'
   and epe.comp_lvl_cd ='OIPL'
   and epe.oipl_id = p_oipl_id;
   hr_utility.set_location('pil oipl elect chc is '||l_electbl_chc_id,10);
   return l_electbl_chc_id;
exception
   when no_data_found then
      hr_utility.set_location('no step elect '||p_oipl_id,10);
      return l_electbl_chc_id;
   when others then
      hr_utility.set_location('issue in getting step elect '||p_oipl_id,10);
      raise;
end;
function get_pl_elect(p_per_in_ler_id in number,
                      p_pl_id         in number) return number is
   l_electbl_chc_id number;
begin
   select epe.ELIG_PER_ELCTBL_CHC_ID
   into l_electbl_chc_id
   from ben_elig_per_elctbl_chc epe, ben_per_in_ler pil
   where pil.per_in_ler_id = epe.per_in_ler_id
   and pil.per_in_ler_id = p_per_in_ler_id
   and pil.per_in_ler_stat_cd = 'STRTD'
   and epe.comp_lvl_cd ='PLAN'
   and epe.pl_id = p_pl_id;
   hr_utility.set_location('pil pl elect chc is '||l_electbl_chc_id,10);
   return l_electbl_chc_id;
exception
   when no_data_found then
      hr_utility.set_location('no plan elect '||p_pl_id,10);
      return l_electbl_chc_id;
   when others then
      hr_utility.set_location('issue in getting plan elect '||p_pl_id,10);
      raise;
end;
procedure get_electbl_chc(p_per_in_ler_id  in number,
                          p_effective_date in date,
                          p_grade_id       in number,
                          p_step_id        in number,
                          p_electbl_chc_id out nocopy number) is
   l_oipl_id number;
   l_pl_id number;
begin
   hr_utility.set_location('inside get elect chc',10);
   if p_step_id is not null then
      l_oipl_id := pqh_gsp_hr_to_stage.get_oipl_for_step
                          (p_step_id        => p_step_id,
                           p_effective_date => p_effective_date);
      hr_utility.set_location('oipl id is '||l_oipl_id,20);
   end if;
   if p_grade_id is not null then
      l_pl_id := pqh_gsp_hr_to_stage.get_plan_for_grade
                        (p_grade_id       => p_grade_id,
                         p_effective_date => p_effective_date);
      hr_utility.set_location('pl id is '||l_pl_id,30);
   end if;
   if l_pl_id is null and l_oipl_id is null then
      hr_utility.set_location('issue in getting plan and oipl '||l_pl_id,40);
   else
      if l_oipl_id is null then
         p_electbl_chc_id := get_pl_elect(p_per_in_ler_id => p_per_in_ler_id,
                                          p_pl_id         => l_pl_id);
         hr_utility.set_location('pl elect chc is '||p_electbl_chc_id,50);
      else
         p_electbl_chc_id := get_oipl_elect(p_per_in_ler_id => p_per_in_ler_id,
                                            p_oipl_id       => l_oipl_id);
         hr_utility.set_location('oipl elect chc is '||p_electbl_chc_id,60);
      end if;
   end if;
end get_electbl_chc;
procedure get_step_seq(p_step_id        in number,
                       p_effective_date in date,
                       p_step_seq       out nocopy number,
                       p_grade_spine_id out nocopy number) is
begin
   select sequence,grade_spine_id
   into p_step_seq,p_grade_spine_id
   from per_spinal_point_steps_f
   where p_effective_date between effective_start_date and effective_end_date
   and step_id = p_step_id;
   hr_utility.set_location('step seq # is '||p_step_seq,10);
exception
   when others then
      hr_utility.set_location('issue in getting step seq '||p_step_id,12);
      raise;
end get_step_seq;
procedure get_result_step(p_step_id         in number,
                          p_effective_date  in date,
                          p_future_step_id  in number,
                          p_ceiling_step_id in number,
                          p_called_from     in varchar2 default 'SP',
                          p_num_incr        in number,
                          p_steps_left      out nocopy number,
                          p_next_step_id    out nocopy number) is
   l_step_seq number;
   l_grade_spine_id number;
   l_fut_grade_spine_id number;
   l_max_grade_spine_id number;
   l_dest_step_seq number;
   l_max_step_seq number;
   l_fut_step_seq number;
   l_Incr   Number := 1;

  Cursor Step(P_Grade_Spine_Id in Number, P_Seq In Number) is
 Select Sequence, Step_Id
   From Per_Spinal_Point_steps_F a
  Where Grade_Spine_id = P_Grade_Spine_id
    and P_Effective_Date Between Effective_Start_Date and effective_End_Date
    and Sequence > P_Seq
    Order By Sequence asc;

begin
-- this procedure will return the step which will add current step level
-- to num_incr and give us the step to which person can be progressed
   hr_utility.set_location('inside get_result_step'||p_step_id,10);
   get_step_seq(p_step_id        => p_step_id,
                p_effective_date => p_effective_date,
                p_step_seq       => l_dest_step_seq,
                p_grade_spine_id => l_grade_spine_id);
   hr_utility.set_location('inside get_result_step'|| l_grade_spine_id,20);
   hr_utility.set_location('curr step seq # is '|| l_dest_step_seq,30);
   if p_future_step_id is not null then
      get_step_seq(p_step_id        => p_future_step_id,
                   p_effective_date => p_effective_date,
                   p_step_seq       => l_fut_step_seq,
                   p_grade_spine_id => l_fut_grade_spine_id);
   End If;
   get_step_seq(p_step_id        => p_ceiling_step_id,
                p_effective_date => p_effective_date,
                p_step_seq       => l_max_step_seq,
                p_grade_spine_id => l_max_grade_spine_id);
   hr_utility.set_location('Max Grade Spine'|| l_Max_grade_spine_id,40);
   hr_utility.set_location('Max step seq # is '|| l_max_step_seq,50);
   For Step_rec in Step(l_Grade_spine_Id, l_dest_step_seq) Loop
   hr_utility.set_location(' Inside Step Loop ', 60);

   l_dest_step_seq := Step_Rec.Sequence;
   p_next_step_id := Step_Rec.Step_Id;
   hr_utility.set_location('Next Step '|| p_next_step_id,70);
   hr_utility.set_location('Dest Step Seq '|| l_dest_step_seq,80);
   if l_dest_step_seq >l_max_step_seq then
      hr_utility.set_location('Inside Max Step IF',90);
      if p_called_from = 'GSP' then
         hr_utility.set_location('steps left to use ',85);
          -- p_steps_left := l_dest_step_seq - l_max_step_seq;
         p_steps_left := Nvl(P_Num_Incr,1) - l_incr;
         Return;
      else
         hr_utility.set_location('max step is marked next',90);
         l_dest_step_seq := l_max_step_seq;
         p_next_step_id := p_ceiling_step_id;
         Return;
      end if;
   end if;
   if l_dest_step_seq > l_fut_step_seq and l_fut_grade_spine_id = l_grade_spine_id then
         hr_utility.set_location('future step is marked next',50);
         l_dest_step_seq := l_fut_step_seq;
         p_next_step_id  := Step_Rec.Step_Id;
         Return;
   end if;
   If l_Incr >= Nvl(P_Num_Incr,1) Then
       hr_utility.set_location(' Incr == Return',100);
      Return;
   Else
     l_Incr := L_Incr + 1;
   End If;
   End Loop;
--   l_dest_step_seq := l_step_seq + nvl(p_num_incr,1);
   If P_next_step_id is NULL and p_called_from = 'SP' then
      fnd_message.set_name('PQH','PQH_GSP_LAST_STEP');
      fnd_message.raise_error;
   End If;
    hr_utility.set_location(' Next Step ' || p_next_step_id ,110);
   If p_next_step_id is NULL Then
      p_steps_left := Nvl(P_Num_Incr,1);
   End If;
 /*  if p_steps_left is null then
      begin
         select step_id
         into p_next_step_id
         from per_spinal_point_steps_f
         where p_effective_date between effective_start_date and effective_end_date
         and grade_spine_id = l_grade_spine_id
         and sequence = l_dest_step_seq;
      exception
         when others then
            hr_utility.set_location('issue in getting step '||l_dest_step_seq,100);
            raise;
      end;
      hr_utility.set_location('next step is'||p_next_step_id,120);
   else
      hr_utility.set_location('left step '||p_steps_left,130);
   end if; */
end get_result_step;

procedure step_progression(p_effective_date in date,
                           p_step_id        in number,
                           p_num_incr       in number,
                           p_ceiling_step_id in number,
                           p_future_step_id  in number,
                           p_next_step_id    out nocopy number) is
   l_continue boolean := TRUE;
   l_steps_left number;
begin
   if p_step_id is null then
      hr_utility.set_location('emp not on step'||p_step_id,5);
      l_continue := FALSE;
      fnd_message.set_name('PQH','PQH_GSP_NO_STEP');
      fnd_message.raise_error;
   elsif p_step_id = p_ceiling_step_id then
      hr_utility.set_location('emp on ceiling no step prog'||p_ceiling_step_id,5);
      l_continue := FALSE;
      fnd_message.set_name('PQH','PQH_GSP_CIEL_STEP');
      fnd_message.raise_error;
   else
      hr_utility.set_location('step id is '||p_step_id,10);
      hr_utility.set_location('# of incr for person are '||p_num_incr,20);
   end if;
   if l_continue then
      get_result_step(p_step_id         => p_step_id,
                      p_effective_date  => p_effective_date,
                      p_future_step_id  => p_future_step_id,
                      p_ceiling_step_id => p_ceiling_step_id,
                      p_num_incr        => p_num_incr,
                      p_called_from     => 'SP',
                      p_next_step_id    => p_next_step_id,
                      p_steps_left      => l_steps_left);
      hr_utility.set_location('next step id is '||p_next_step_id,30);
   end if;
end step_progression;
function is_grade_in_gl(p_grade_id in number,
                        p_gl_id    in number,
                        p_effective_date in date) return number is
   l_ordr_num number;
   l_pl_id number;
begin
-- grade should be mapped to a plan which should be linked to a pgm as plip
   l_pl_id := pqh_gsp_hr_to_stage.get_plan_for_grade
                     (p_grade_id => p_grade_id,
                      p_effective_date => p_effective_date);
   if l_pl_id is not null then
      hr_utility.set_location('pl id is '||l_pl_id,10);
      begin
         select ordr_num
         into l_ordr_num
         from ben_plip_f
         where pgm_id = p_gl_id
         and p_effective_date between effective_start_date and effective_end_date
         and pl_id = l_pl_id;
         hr_utility.set_location('ordr num is '||l_ordr_num,20);
         return l_ordr_num;
      exception
         when no_data_found then
            hr_utility.set_location('plan is not in GL'||l_pl_id,10);
            return l_ordr_num;
         when others then
            hr_utility.set_location('issue in getting plips'||l_pl_id,10);
            raise;
      end;
   else
      return l_ordr_num;
   end if;
end is_grade_in_gl;
function is_next_step_higher(p_cur_step_id    in number,
                             p_next_step_id   in number,
                             p_effective_date in date) return varchar2 is
   l_cur_step_seq number;
   l_cur_grade_spine_id number;
   l_next_step_seq number;
   l_next_grade_spine_id number;
begin
-- the idea of this function is to check whether current step is higher than next step
-- if both the steps belong to the grade spine then only we will be returning something
-- otherwise
   hr_utility.set_location('checking step ',10);
   if p_cur_step_id = p_next_step_id then
      hr_utility.set_location('same step being compared',15);
      return 'SAME';
   else
      hr_utility.set_location('different steps ',18);
      get_step_seq(p_step_id        => p_cur_step_id,
                   p_effective_date => p_effective_date,
                   p_step_seq       => l_cur_step_seq,
                   p_grade_spine_id => l_cur_grade_spine_id);
      hr_utility.set_location('cur step seq is '||l_cur_step_seq,20);
      hr_utility.set_location('cur step GS is '||l_cur_grade_spine_id,25);
      get_step_seq(p_step_id        => p_next_step_id,
                   p_effective_date => p_effective_date,
                   p_step_seq       => l_next_step_seq,
                   p_grade_spine_id => l_next_grade_spine_id);
      hr_utility.set_location('next step seq is '||l_next_step_seq,30);
      hr_utility.set_location('next step GS is '||l_next_grade_spine_id,35);
      if l_cur_grade_spine_id <> l_next_grade_spine_id then
         hr_utility.set_location('steps grade spine not same',40);
         return 'NO';
      else
         hr_utility.set_location('same grade spine ',50);
         if l_next_step_seq > l_cur_step_seq then
            hr_utility.set_location('next step is higher',60);
            return 'YES';
         else
            hr_utility.set_location('cur step is higher',70);
            return 'NO_LOWER';
         end if;
      end if;
   end if;
end is_next_step_higher;
procedure next_asg_grade_step(p_assignment_id   in number,
                              p_cur_asg_eed     in date,
                              p_future_grade_id out nocopy number,
                              p_future_step_id  out nocopy number) is
   l_asg_check_date date;
   cursor csr_asgs is
      select grade_id
      from per_all_assignments_f
      where assignment_id = p_assignment_id
      and l_asg_check_date between effective_start_date and effective_end_date;
   cursor csr_spps is
      select step_id
      from per_spinal_point_placements_f
      where assignment_id = p_assignment_id
      and l_asg_check_date between effective_start_date and effective_end_date;
begin
   hr_utility.set_location('inside next_asg_grade_step',10);
   l_asg_check_date := p_cur_asg_eed + 1;
   open csr_asgs;
   fetch csr_asgs into p_future_grade_id;
   if csr_asgs%found then
      hr_utility.set_location('future grd found '||p_future_grade_id,20);
      close csr_asgs;
      open csr_spps;
      fetch csr_spps into p_future_step_id;
      if csr_spps%found then
         hr_utility.set_location('future step found '||p_future_step_id,40);
         close csr_spps;
      else
         hr_utility.set_location('no step found ',50);
         close csr_spps;
      end if;
   else
      hr_utility.set_location('no grade found ',60);
      close csr_asgs;
   end if;
end next_asg_grade_step;
function get_default_step(p_next_grade_id  in number,
                          p_assignment_id  in number,
                          p_dflt_step_cd   in varchar2,
                          p_effective_date in date) return number is
   l_next_step_id number;
   l_cur_sal number;
begin
-- next garde  is passed and we have to get step which meets the code
   hr_utility.set_location('inside get_default_step',10);
   if p_dflt_step_cd = 'MINSTEP' then
      hr_utility.set_location('1st step is required',20);
      l_next_step_id := get_next_step(p_grade_id       => p_next_grade_id,
                                      p_effective_date => p_effective_date);
      hr_utility.set_location('1st step is '||l_next_step_id,30);
   elsif p_dflt_step_cd = 'MINSALINCR' then
      hr_utility.set_location('min sal incr step is required',40);
      l_cur_sal := get_annual_sal(p_assignment_id => p_assignment_id,
                               p_effective_date => p_effective_date);
      hr_utility.set_location('cur sal is '||l_cur_sal,45);
      l_next_step_id := get_lowest_sal_incr_step(p_cur_sal        => l_cur_sal,
                                                 p_grade_id       => p_next_grade_id,
                                                 p_effective_date => p_effective_date,
                                                 P_Assignment_id  => P_Assignment_id);
      hr_utility.set_location('step is '||l_next_step_id,50);
   elsif p_dflt_step_cd = 'NOSTEP' then
      hr_utility.set_location('no step is required,pass null',60);
      l_next_step_id := get_next_step(p_grade_id       => p_next_grade_id,
                                      p_effective_date => p_effective_date);
      If l_next_step_id is NOT NULL then
         l_next_step_id := NULL;
      Else
         Fnd_message.set_name('PQH','PQH_GSP_LAST_STEP');
         fnd_message.raise_error;
      End If;

   else
      hr_utility.set_location('invalid step_cd ',70);
      l_next_step_id := -1;
   end if;
   return l_next_step_id;
end get_default_step;
function get_sal_for_step(p_step_id in number,
                          p_effective_date in date) return number is
   l_point_id number;
   l_option_id number;
   l_step_rate number;
begin
   hr_utility.set_location('inside get_sal_for_step',10);
   l_point_id := pqh_gsp_hr_to_stage.get_point_for_step
                        (p_step_id        => p_step_id,
                         p_effective_date => p_effective_date);
   hr_utility.set_location('point is '||l_point_id,20);
   if l_point_id is not null then
      l_option_id := pqh_gsp_hr_to_stage.get_opt_for_point
                            (p_point_id       => l_point_id,
                             p_effective_date => p_effective_date);
      hr_utility.set_location('opt is '||l_option_id,30);
      if l_option_id is not null then
         hr_utility.set_location('going for point rate '||l_option_id,35);
         pqh_gsp_hr_to_stage.get_point_rate_values
               (p_effective_date => p_effective_date,
                p_opt_id         => l_option_id,
                p_point_id       => l_point_id,
                p_point_value    => l_step_rate);
         hr_utility.set_location('step sal is '||l_step_rate,40);
      else
         hr_utility.set_location('opt is null ',50);
      end if;
   else
      hr_utility.set_location('point is null ',60);
   end if;
   return l_step_rate;
end get_sal_for_step;
function get_next_oipl(p_oipl_id in number,
                       p_effective_date in date) return number is
   l_step_id number;
   l_next_step_id number;
   l_next_oipl_id number;
begin
   hr_utility.set_location('getting next oipl'||p_oipl_id,10);
   l_step_id := pqh_gsp_hr_to_stage.get_step_for_oipl(p_oipl_id => p_oipl_id,
                                                      p_effective_date => p_effective_date);
   hr_utility.set_location('step is'||l_step_id,20);
   l_next_step_id := get_next_step(p_step_id  => l_step_id,
                                   p_effective_date => p_effective_date);
   hr_utility.set_location('next step is'||l_next_step_id,30);
   if nvl(l_next_step_id,0) > 0 then
      l_next_oipl_id := pqh_gsp_hr_to_stage.get_oipl_for_step(p_step_id => l_next_step_id,
                                                      p_effective_date => p_effective_date);
   else
      l_next_oipl_id := l_next_step_id;
   end if;
   hr_utility.set_location('next oipl is'||l_next_oipl_id,40);
   return l_next_oipl_id;
end get_next_oipl;
function get_next_step(p_grade_id       in number default null,
                       p_step_id        in number default null,
                       p_effective_date in date) return number is
   l_seq number;
   l_grade_spine_id number;
   l_next_seq number;
   l_next_step_id number;
   cursor csr_steps is
      select step_id,sequence
      from per_spinal_point_steps_f
      where grade_spine_id = l_grade_spine_id
      and p_effective_date between effective_start_date and effective_end_date
      and sequence > l_seq
      order by sequence;
begin
--
-- this routine will return null if the step is the topmost
-- (-1) if the step is not valid
-- else next step for the grade will be returned
--
   hr_utility.set_location('getting next step',10);
   if p_step_id is null and p_grade_id is null then
      hr_utility.set_location('grade and step passed null'||p_grade_id,12);
      return l_next_step_id;
   end if;
   if p_step_id is null then
      hr_utility.set_location('getting 1st step of grade'||p_grade_id,20);
      begin
         select grade_spine_id
         into l_grade_spine_id
         from per_grade_spines_f
         where grade_id = p_grade_id
         and p_effective_date between effective_start_date and effective_end_date;
         hr_utility.set_location('grade spine is '||l_grade_spine_id,25);
         l_seq := 0;
      exception
         when no_data_found then
            hr_utility.set_location('grade doesnot have spine',30);
            return l_next_step_id;
         when others then
            hr_utility.set_location('issues in getting gradespine ',35);
            raise;
      end;
   else
      hr_utility.set_location('p_step_id is '||p_step_id,36);
      get_step_seq(p_step_id        => p_step_id,
                   p_effective_date => p_effective_date,
                   p_step_seq       => l_seq,
                   p_grade_spine_id => l_grade_spine_id);
   end if;
   hr_utility.set_location('seq is '||l_seq,40);
   begin
      open csr_steps;
      fetch csr_steps into l_next_step_id,l_next_seq;
      if csr_steps%notfound then
         close csr_steps;
         hr_utility.set_location('current step was on top',50);
      else
         close csr_steps;
         hr_utility.set_location('next step found '||l_next_step_id,60);
         hr_utility.set_location('next step seq '||l_next_seq,70);
      end if;
   exception
      when others then
         hr_utility.set_location('issues in getting step seq',80);
         raise;
   end;
   hr_utility.set_location('next step is'||l_next_step_id,100);
   return l_next_step_id;
end get_next_step;
function get_next_grade(p_grade_id in number,
                        p_gl_id in number,
                        p_effective_date in date) return number is
   l_pl_id number;
   l_next_pl_id number;
   l_next_grade_id number;
begin
   hr_utility.set_location('getting next grade'||p_grade_id,10);
   l_pl_id := pqh_gsp_hr_to_stage.get_plan_for_grade
                    (p_grade_id       => p_grade_id,
                     p_effective_date => p_effective_date);
   hr_utility.set_location('plan is'||l_pl_id,20);
   if l_pl_id is null then
      hr_utility.set_location('grade not linked '||p_grade_id,20);
      return l_next_grade_id;
   else
      l_next_pl_id := get_next_plan(p_pl_id  => l_pl_id,
                                    p_gl_id  => p_gl_id,
                                    p_effective_date => p_effective_date);
      hr_utility.set_location('next plan is'||l_next_pl_id,30);
      if nvl(l_next_pl_id,0) > 0 then
         l_next_grade_id := pqh_gsp_hr_to_stage.get_grade_for_plan
                                  (p_plan_id => l_next_pl_id,
                                   p_effective_date => p_effective_date);
      else
         l_next_grade_id := l_next_pl_id;
      end if;
   end if;
   hr_utility.set_location('next grade is'||l_next_grade_id,40);
   return l_next_grade_id;
end get_next_grade;
function get_next_plan(p_pl_id          in number,
                       p_gl_id          in number,
                       p_effective_date in date) return number is
   l_ordr_num number;
   l_plip_id number;
   l_next_ordr_num number;
   l_next_pl_id number;
   cursor csr_plips is
      select pl_id,ordr_num
      from ben_plip_f
      where pgm_id = p_gl_id
      and p_effective_date between effective_start_date and effective_end_date
      and plip_stat_cd ='A'
      and ordr_num > l_ordr_num
      order by ordr_num;
begin
--
-- this routine will return null if the plan is the topmost
-- (-1) if the pl is not in GL
-- else next plan will be returned
--
   hr_utility.set_location('getting next plan',10);
   begin
      select plip_id,ordr_num
      into l_plip_id,l_ordr_num
      from ben_plip_f
      where pgm_id = p_gl_id
      and p_effective_date between effective_start_date and effective_end_date
      and plip_stat_cd ='A'
      and pl_id = p_pl_id;
      hr_utility.set_location('ordr num is '||l_ordr_num,20);
   exception
      when no_data_found then
         hr_utility.set_location('plan is not linked to pgm',30);
         l_next_pl_id := -1;
      when others then
         hr_utility.set_location('issues in getting plan ordr_num',10);
         raise;
   end;
   hr_utility.set_location('ordr num is '||l_ordr_num,40);
   begin
      open csr_plips;
      fetch csr_plips into l_next_pl_id,l_next_ordr_num;
      if csr_plips%notfound then
         close csr_plips;
         hr_utility.set_location('current pl was on top',50);
      else
         close csr_plips;
         hr_utility.set_location('next pl found '||l_next_pl_id,60);
         hr_utility.set_location('next pl ordr_num '||l_next_ordr_num,70);
      end if;
   exception
      when others then
         hr_utility.set_location('issues in getting plan ordr_num',10);
         raise;
   end;
   hr_utility.set_location('next plan is'||l_next_pl_id,100);
   return l_next_pl_id;
end get_next_plan;
procedure get_default_progression(p_per_in_ler_id  in number,
                                  p_effective_date in date,
                                  p_electbl_chc_id out nocopy number,
                                  p_return_code    out nocopy varchar2,
                                  p_error_message  out nocopy varchar2) is
   l_assignment_id number;
   cursor csr_asg_rec is
      select effective_start_date,effective_end_date,grade_ladder_pgm_id,grade_id,
             special_ceiling_step_id,business_group_id
      from per_all_assignments_f
      where assignment_id = l_assignment_id
      and p_effective_date between effective_start_date and effective_end_date;
   l_asg_esd date;
   l_asg_eed date;
   l_gl_id number;
   l_bg_id number;
   l_plan_id number;
   l_def_gl number;
   l_grade_id number;
   l_spl_ceiling_id number;
   l_prog_style_cd varchar2(30);
   l_post_style_cd varchar2(30);
   l_gl_name ben_pgm_f.name%type;
   l_dflt_step_cd ben_pgm_f.dflt_step_cd%type;
   l_dflt_step_rl ben_pgm_f.dflt_step_rl%type;
   l_continue boolean := TRUE;
   l_scale_id number;
   l_scale_ovn number;
   l_scale_name per_parent_spines.name%type;
   l_grade_spine_ovn number;
   l_grade_spine_id  number;
   l_ceiling_step_id number;
   l_step_id number;
   l_next_grade_id number;
   l_next_step_id number;
   l_eot date := to_date('31/12/4712','dd/mm/RRRR');
   l_future_grade_id number;
   l_future_step_id number;
   l_next_step_higher_cd varchar2(30);
   l_num_incr number;
   l_curr_grd_gl_ordr_num number;
   l_electbl_chc_id number;
   l_starting_step number;
begin
   hr_utility.set_location('inside def prog'||p_per_in_ler_id,5);
   l_assignment_id := get_asg_for_pil(p_per_in_ler_id  => p_per_in_ler_id,
                                      p_effective_date => p_effective_date);
   hr_utility.set_location('asg is '||l_assignment_id,6);
   open csr_asg_rec;
   fetch csr_asg_rec into l_asg_esd,l_asg_eed,l_gl_id,l_grade_id,l_spl_ceiling_id,l_bg_id;
   if csr_asg_rec%notfound then
      close csr_asg_rec;
      l_continue := FALSE;
      hr_utility.set_location('Assignment invalid'||l_assignment_id,10);
   else
      close csr_asg_rec;
      hr_utility.set_location('Assignment is valid'||l_assignment_id,11);
      if l_grade_id is not null then
         hr_utility.set_location('grade is'||l_grade_id,20);
         l_plan_id := pqh_gsp_hr_to_stage.get_plan_for_grade
                            (p_grade_id       => l_grade_id,
                             p_effective_date => p_effective_date);
         hr_utility.set_location('plan is'||l_plan_id,30);
         if l_plan_id is null then
            l_continue := FALSE;
            fnd_message.set_name('PQH','PQH_GSP_PLN_NOTLNKD_TO_GRD');
            fnd_message.raise_error;
         end if;
      else
         hr_utility.set_location('grade is'||l_grade_id,40);
         l_continue := FALSE;
         fnd_message.set_name('PQH','PQH_GSP_GRDNOTLNKD_ASSGT');
         fnd_message.raise_error;
      end if;
      if l_continue then
         if l_gl_id is not null then
            hr_utility.set_location('Assignment on GL'||l_gl_id,50);
         else
            hr_utility.set_location('Assignment not on GL'||l_assignment_id,60);
            -- is assignment on default GL.
            l_def_gl := get_default_gl(p_effective_date    => p_effective_date,
                                       p_business_group_id => l_bg_id);
            if l_def_gl is not null then
               hr_utility.set_location('def GL'||l_def_gl,70);
               l_curr_grd_gl_ordr_num := is_grade_in_gl(p_grade_id => l_grade_id,
                                                        p_gl_id    => l_def_gl,
                                                        p_effective_date => p_effective_date);
               if l_curr_grd_gl_ordr_num is not null then
                  hr_utility.set_location('asg on def GL',80);
                  l_gl_id := l_def_gl;
               else
                  l_continue := FALSE;
		  fnd_message.set_name('PQH','PQH_GSP_GRD_ORDNUM_NOTFND');
                  fnd_message.raise_error;
               end if;
            else
               hr_utility.set_location('def GL not there',80);
               l_continue := FALSE;
	       fnd_message.set_name('PQH','PQH_GSP_NO_GRDLDR');
               fnd_message.raise_error;
            end if;
         end if;
      end if;
      if l_continue then
         get_gl_details(p_gl_id          => l_gl_id,
                        p_effective_date => p_effective_date,
                        p_prog_style_cd  => l_prog_style_cd,
                        p_post_style_cd  => l_post_style_cd,
                        p_gl_name        => l_gl_name,
                        p_dflt_step_cd   => l_dflt_step_cd,
                        p_dflt_step_rl   => l_dflt_step_rl);
         hr_utility.set_location('Assignment on GL'||l_gl_name,55);
         if l_prog_style_cd in ('PQH_GSP_SP','PQH_GSP_GSP') then
            get_emp_step_placement(p_assignment_id  => l_assignment_id,
                                   p_effective_date => p_effective_date,
                                   p_emp_step_id    => l_step_id,
                                   p_num_incr       => l_num_incr);
            hr_utility.set_location('step id is '||l_step_id,55);
            pqh_gsp_hr_to_stage.get_grd_scale_details
                   (p_grade_id        => l_grade_id,
                    p_effective_date  => p_effective_date,
                    p_scale_id        => l_scale_id,
                    p_ceiling_step_id => l_ceiling_step_id,
                    p_grade_spine_ovn => l_grade_spine_ovn,
                    p_grade_spine_id  => l_grade_spine_id ,
                    p_scale_ovn       => l_scale_ovn,
                    p_scale_name      => l_scale_name,
                    p_starting_step   => l_starting_step);
            hr_utility.set_location('grade is linked to scale'||l_scale_name,95);
            hr_utility.set_location('ceiling step id is '||l_ceiling_step_id,96);
            if l_spl_ceiling_id is not null then
               l_ceiling_step_id := l_spl_ceiling_id;
               hr_utility.set_location('ceiling step id is '||l_ceiling_step_id,100);
            end if;
         end if;
         if l_asg_eed < l_eot then
            hr_utility.set_location('get future placement ',150);
            next_asg_grade_step(p_assignment_id   => l_assignment_id,
                                p_cur_asg_eed     => l_asg_eed,
                                p_future_grade_id => l_future_grade_id,
                                p_future_step_id  => l_future_step_id);
            hr_utility.set_location('future grade is '||l_future_grade_id,160);
            hr_utility.set_location('future step is '||l_future_step_id,170);
         else
            hr_utility.set_location('asg is till eot',180);
         end if;
         hr_utility.set_location('progr style is '||l_prog_style_cd,190);
         if l_prog_style_cd ='PQH_GSP_GSP' then
            grd_step_progression_result(p_grade_id        => l_grade_id,
                                        p_step_id         => l_step_id,
                                        p_gl_id           => l_gl_id,
                                        p_assignment_id   => l_assignment_id,
                                        p_effective_date  => p_effective_date,
                                        p_ceiling_step_id => l_ceiling_step_id,
                                        p_num_incr        => l_num_incr,
                                        p_dflt_step_cd    => l_dflt_step_cd,
                                        p_future_step_id  => l_future_step_id,
                                        p_next_grade_id   => l_next_grade_id,
                                        p_next_step_id    => l_next_step_id);
         elsif l_prog_style_cd = 'PQH_GSP_GP' then
            grade_progression(p_assignment_id  => l_assignment_id,
                              p_effective_date => p_effective_date,
                              p_grade_id       => l_grade_id,
                              p_gl_id          => l_gl_id,
                              p_next_grade_id  => l_next_grade_id);
         elsif l_prog_style_cd = 'PQH_GSP_SP' then
            step_progression(p_effective_date  => p_effective_date,
                             p_step_id         => l_step_id,
                             p_num_incr        => l_num_incr,
                             p_ceiling_step_id => l_ceiling_step_id,
                             p_future_step_id  => l_future_step_id,
                             p_next_step_id    => l_next_step_id);
         else
            hr_utility.set_location('invalid prog_style'||l_prog_style_cd,260);
            l_continue := FALSE;
            fnd_message.set_name('PQH','PQH_GSP_PRGSTYLE_NOT_SET');
            fnd_message.raise_error;
         end if;
         hr_utility.set_location('cur grade is'||l_grade_id,260);
         hr_utility.set_location('cur step is'||l_step_id,260);
         hr_utility.set_location('next grade is'||l_next_grade_id,260);
         hr_utility.set_location('next step is'||l_next_step_id,260);
         hr_utility.set_location('future grade is'||l_future_grade_id,260);
         hr_utility.set_location('future step is'||l_future_step_id,260);
      end if;
      if l_next_step_id is null and l_next_grade_id is null then
         l_continue := False;
      end if;
      if l_continue then
         hr_utility.set_location('checking elc chc',260);
         get_electbl_chc(p_per_in_ler_id  => p_per_in_ler_id,
                         p_effective_date => p_effective_date,
                         p_grade_id       => l_next_grade_id,
                         p_step_id        => l_next_step_id,
                         p_electbl_chc_id => l_electbl_chc_id);
         if l_electbl_chc_id is not null then
            if l_post_style_cd ='A' then
               p_return_code := 'A';
               p_electbl_chc_id := l_electbl_chc_id;
            elsif l_post_style_cd ='E' then
               p_return_code := 'D';
               p_electbl_chc_id := l_electbl_chc_id;
            else
               hr_utility.set_location('invalid posting style'||l_post_style_cd,260);
            end if;
         else
            hr_utility.set_location('no electbl chc found ',260);
	    fnd_message.set_name('PQH','PQH_GSP_EMP_NOT_ELGBL');
            fnd_message.raise_error;
            l_continue := False;
         end if;
      end if;
   end if;
end get_default_progression;

procedure grade_progression(p_assignment_id  in number,
                            p_effective_date in date,
                            p_grade_id       in number,
                            p_gl_id          in number,
                            p_next_grade_id  out nocopy number) is
begin
   p_next_grade_id := get_next_grade(p_grade_id => p_grade_id,
                                     p_gl_id    => p_gl_id,
                                     p_effective_date => p_effective_date);
   if p_next_grade_id is null then
      hr_utility.set_location('topmost grade',260);
      fnd_message.set_name('PQH','PQH_GSP_LAST_GRADE');
      fnd_message.raise_error;
   elsif p_next_grade_id = -1 then
      hr_utility.set_location('invalid grd for GL',270);
   else
      hr_utility.set_location('next grade is'||p_next_grade_id,260);
   end if;
end;

procedure get_emp_step_placement(p_assignment_id  in number,
                                 p_effective_date in date,
                                 p_emp_step_id    out nocopy number,
                                 p_num_incr       out nocopy number) is
begin
   hr_utility.set_location('assignment is'||p_assignment_id,10);
   select step_id,increment_number
   into p_emp_step_id,p_num_incr
   from per_spinal_point_placements_f
   where assignment_id = p_assignment_id
   and p_effective_date between effective_start_date and effective_end_date;
   hr_utility.set_location('step is'||p_emp_step_id,15);
exception
   when no_data_found then
      hr_utility.set_location('assignment doesnot have step'||p_assignment_id,20);
   when others then
      hr_utility.set_location('issues in getting assignment step'||p_assignment_id,30);
      raise;
end get_emp_step_placement;
function get_default_gl(p_effective_date in date,
                        p_business_group_id in number) return number is
   l_gl_id number;
begin
   hr_utility.set_location('bg is'||p_business_group_id,5);
   select pgm_id
   into l_gl_id
   from ben_pgm_f
   where p_effective_date between effective_start_date and effective_end_date
   and pgm_stat_cd ='A' -- active program
   and pgm_typ_cd ='GSP' -- context should be GSP
   and dflt_pgm_flag = 'Y' -- default
   and business_group_id = p_business_group_id;
   hr_utility.set_location('def gl is'||l_gl_id,10);
   return l_gl_id;
exception
   when no_data_found then
      hr_utility.set_location('no pgm exists matching crit',20);
      return l_gl_id;
   when too_many_rows then
      hr_utility.set_location('more than 1 pgm marked dflt ',25);
      raise;
   when others then
      hr_utility.set_location('issues in getting def gl ',30);
      raise;
end get_default_gl;
procedure get_gl_details(p_gl_id          in number,
                         p_effective_date in date,
                         p_prog_style_cd  out nocopy varchar2,
                         p_post_style_cd  out nocopy varchar2,
                         p_gl_name        out nocopy varchar2,
                         p_dflt_step_cd   out nocopy varchar2,
                         p_dflt_step_rl   out nocopy varchar2) is
begin
   select enrt_mthd_cd,name,dflt_step_cd,dflt_step_rl
   into   p_post_style_cd,p_gl_name,p_dflt_step_cd,p_dflt_step_rl
   from ben_pgm_f
   where pgm_id = p_gl_id
   and pgm_stat_cd ='A' -- program should be active
   and p_effective_date between effective_start_date and effective_end_date
   and pgm_typ_cd ='GSP' ;-- should be Grade ladder
   If p_dflt_step_cd in ('MINSALINCR','MINSTEP','NOSTEP') then
      p_prog_style_cd := 'PQH_GSP_GSP';
   Else
      p_prog_style_cd := p_dflt_step_cd;
   End If;
exception
   when no_data_found then
      hr_utility.set_location('no pgm exists ',10);
      raise;
   when others then
      hr_utility.set_location('issues in getting gl detls',20);
      raise;
end get_gl_details;

function get_cur_sal(p_assignment_id   in number,
                     p_effective_date  in date) return number Is
L_Cur_Sal         Per_pay_Proposals.PROPOSED_SALARY_N%TYPE;
l_input_value_id  pay_input_values_f.Input_Value_id%TYPE;
  Cursor Sal is
  select pev.screen_entry_value
    from pay_element_entries_f      pee
        ,pay_element_entry_values_f pev
    where pev.element_entry_id = pee.element_entry_id
      and p_Effective_Date between pev.Effective_Start_Date and pev.Effective_End_Date
      and pee.assignment_id    = p_assignment_id
      and p_Effective_Date between pee.Effective_Start_Date and pee.Effective_End_Date
      and pev.Input_Value_id   = l_input_value_id;
  Cursor Pay_Bases_Element is
  Select input_value_id
    From Per_Pay_Bases         ppb,
         Per_All_Assignments_f paf
   Where paf.Assignment_Id = p_Assignment_Id
     and p_Effective_Date Between Paf.Effective_Start_Date and Paf.Effective_End_Date
     and paf.pay_basis_id  = ppb.pay_basis_id;
  Cursor GrdLdr_Element is
  Select DFLT_INPUT_VALUE_ID
    from Ben_Pgm_f             pgm,
         Per_All_Assignments_f paf
   Where paf.Assignment_Id = p_Assignment_Id
     and p_Effective_Date
 Between Paf.Effective_Start_Date and Paf.Effective_End_Date
     and paf.GRADE_LADDER_PGM_ID = pgm.pgm_id
     and p_Effective_Date
 Between pgm.Effective_Start_date and pgm.Effective_End_Date;
Begin
  Open  Pay_Bases_Element;
  Fetch Pay_Bases_Element into l_input_Value_id;
  Close Pay_Bases_Element;
  If l_input_Value_id is NULL Then
     Open  GrdLdr_Element;
     Fetch GrdLdr_Element into l_input_Value_id;
     Close GrdLdr_Element;
  End If;
  if l_Input_Value_id is Not NULL Then
     Open Sal;
     Fetch Sal into L_Cur_Sal;
    Close Sal;
  Else
    l_Cur_Sal := 0;
  End If;
  Return L_Cur_Sal;
End Get_Cur_Sal;
procedure grd_step_progression_result(p_grade_id        in number,
                                      p_step_id         in number,
                                      p_gl_id           in number,
                                      p_assignment_id   in number,
                                      p_effective_date  in date,
                                      p_ceiling_step_id in number,
                                      p_dflt_step_cd    in varchar2,
                                      p_num_incr        in number,
                                      p_future_step_id  in number,
                                      p_next_grade_id   out nocopy number,
                                      p_next_step_id    out nocopy number) is
   l_next_step_id number;
   l_next_step_higher_cd varchar2(30);
   l_steps_left number;
   l_continue boolean := TRUE;
begin
-- we will try for step progression, if you reach the ceiling and still some point left, we will go for GSP
   if p_grade_id is null then
      hr_utility.set_location('emp doesnot have grade'||p_grade_id,10);
      l_continue := false;
      fnd_message.set_name('PQH','PQH_GSP_GRDNOTLNKD_ASSGT');
      fnd_message.raise_error;
   end if;
   if p_step_id is null then
      hr_utility.set_location('emp doesnot have step'||p_step_id,10);
      l_continue := false;
      fnd_message.set_name('PQH','PQH_GSP_NO_STEP');
      fnd_message.raise_error;
   end if;
   if l_continue then
      get_result_step(p_step_id         => p_step_id,
                      p_effective_date  => p_effective_date,
                      p_future_step_id  => p_future_step_id,
                      p_ceiling_step_id => p_ceiling_step_id,
                      p_num_incr        => p_num_incr,
                      p_called_from     => 'GSP',
                      p_next_step_id    => l_next_step_id,
                      p_steps_left      => l_steps_left);
      hr_utility.set_location('next step id is '||l_next_step_id,10);
      hr_utility.set_location('steps left is '||l_steps_left,20);
      if l_steps_left is not null then
         hr_utility.set_location('steps left is '||l_steps_left,20);
         hr_utility.set_location('current grade id is '||p_grade_id,110);
         p_next_grade_id := get_next_grade(p_grade_id       => p_grade_id,
                                           p_gl_id          => p_gl_id,
                                           p_effective_date => p_effective_date);
         hr_utility.set_location('next grade is '||p_next_grade_id,125);
         l_next_step_id := get_default_step(p_next_grade_id  => p_next_grade_id,
                                            p_dflt_step_cd   => p_dflt_step_cd,
                                            p_assignment_id  => p_assignment_id,
                                            p_effective_date => p_effective_date);
         hr_utility.set_location('next step is '||l_next_step_id,140);
         if l_next_step_id is not null then
            if p_future_step_id is not null then
               hr_utility.set_location('chk next step with future step',142);
               l_next_step_higher_cd := is_next_step_higher(p_cur_step_id    => l_next_step_id,
                                                            p_next_step_id   => p_future_step_id,
                                                            p_effective_date => p_effective_date);
               if l_next_step_higher_cd in ('YES','SAME','NO') then
                  hr_utility.set_location('future step is higher',142);
                  p_next_step_id := l_next_step_id;
               elsif l_next_step_higher_cd ='NO_LOWER' then
                  hr_utility.set_location('future step is lower than next step',142);
                  p_next_step_id := p_future_step_id;
               else
                  hr_utility.set_location('different code returned ',143);
                  l_continue := FALSE;
               end if;
               hr_utility.set_location('identified step for progression is'||l_next_step_id,144);
               hr_utility.set_location('identified grade for progression is'||p_next_grade_id,144);
            else
               hr_utility.set_location('next step is '||l_next_step_id,144);
               p_next_step_id := l_next_step_id;
            end if;
         else
	    If p_dflt_step_cd = 'NOSTEP' Then
	       Return;
	    Else
               hr_utility.set_location('next step is '||l_next_step_id,144);
               l_continue := FALSE;
	       fnd_message.set_name('PQH','PQH_GSP_LAST_STEP');
               fnd_message.raise_error;
	   End If;
         end if;
      else
         hr_utility.set_location('step progr was sufficient',200);
         p_next_step_id := l_next_step_id;
      end if;
   end if;
end grd_step_progression_result;
function get_lowest_sal_incr_step(p_cur_sal        in number,
                                  p_grade_id       in number,
                                  p_effective_date in date,
                                  P_Assignment_id  in Number) return number is
   l_min_incr_sal number;
   l_min_incr_step_id number;
   l_next_sal number;

   Cursor Csr_Step is
   Select pqh_gsp_hr_to_stage.get_step_for_oipl(Elctbl.oipl_id, p_effective_date) Step_Id
     from Per_all_Assignments_F   Asgt,
          Ben_Per_In_Ler          Pler,
          Ben_Ler_F               Ler,
          Ben_Elig_Per_Elctbl_Chc ELctbl,
          Ben_Enrt_Rt             Rt
    Where Asgt.Assignment_Id        = P_Assignment_id
      and P_Effective_Date
  Between Asgt.Effective_Start_Date
      and Asgt.Effective_End_Date
      and Pler.Person_id            = Asgt.Person_Id
      and Pler.Per_In_Ler_Stat_cd   = 'STRTD'
      and Ler.Ler_id                = Pler.Ler_id
      and ler.typ_Cd                = 'GSP'
      and P_Effective_Date
  Between ler.Effective_Start_Date
      and Ler.Effective_End_Date
      and Elctbl.Per_In_Ler_id      = Pler.Per_In_ler_id
      and Elctbl.Pl_Id              = pqh_gsp_hr_to_stage.get_plan_for_grade
                                                          (p_grade_id, p_effective_date)
      and Elctbl.Oipl_id is NOT NULL
      and Rt.ELig_Per_Elctbl_Chc_Id = Elctbl.Elig_Per_Elctbl_Chc_id
      and Nvl(rt.ann_Val,0) > P_Cur_Sal
      Order by Rt.ann_Val Asc;
begin

hr_utility.set_location('p_cur_sal ' ||p_cur_sal ,99);
hr_utility.set_location('p_grade_id '|| p_grade_id ,199);
hr_utility.set_location('p_effective_date' ||p_effective_date ,299);
hr_utility.set_location('P_Assignment_id '|| P_Assignment_id ,399);

   Open  Csr_Step;
   Fetch Csr_Step into l_Min_Incr_Step_Id;
   Close Csr_Step;

   If p_grade_id is NOT NULL and l_Min_Incr_Step_Id is NULL then
      fnd_message.set_name('PQH','PQH_GSP_EMP_NOT_ELGBL');
      fnd_message.raise_error;
   End If;
   hr_utility.set_location('min sal is '||l_min_incr_sal,85);
   hr_utility.set_location('min step is '||l_min_incr_step_id,90);
   return l_min_incr_step_id;
end get_lowest_sal_incr_step;
function get_annual_sal(p_assignment_id   in number,
                     p_effective_date  in date) return number Is

L_Cur_Sal         Per_pay_Proposals.PROPOSED_SALARY_N%TYPE;
l_input_value_id  pay_input_values_f.Input_Value_id%TYPE;
l_annualization_factor Per_pay_bases.pay_annualization_factor%TYPE;
L_Payroll_name                 pay_all_payrolls_f.Payroll_name%TYPE;

  Cursor Sal is
  select pev.screen_entry_value*l_annualization_factor
    from pay_element_entries_f      pee
        ,pay_element_entry_values_f pev
    where pev.element_entry_id = pee.element_entry_id
      and p_Effective_Date between pev.Effective_Start_Date and pev.Effective_End_Date
      and pee.assignment_id    = p_assignment_id
      and p_Effective_Date between pee.Effective_Start_Date and pee.Effective_End_Date
      and pev.Input_Value_id   = l_input_value_id;

  Cursor Pay_Bases_Element is
  Select input_value_id,pay_annualization_factor
    From Per_Pay_Bases         ppb,
         Per_All_Assignments_f paf
   Where paf.Assignment_Id = p_Assignment_Id
     and p_Effective_Date Between Paf.Effective_Start_Date and Paf.Effective_End_Date
     and paf.pay_basis_id  = ppb.pay_basis_id;

  Cursor GrdLdr_Element is
  Select DFLT_INPUT_VALUE_ID
    from Ben_Pgm_f             pgm,
         Per_All_Assignments_f paf
   Where paf.Assignment_Id = p_Assignment_Id
     and p_Effective_Date
 Between Paf.Effective_Start_Date and Paf.Effective_End_Date
     and paf.GRADE_LADDER_PGM_ID = pgm.pgm_id
     and p_Effective_Date
 Between pgm.Effective_Start_date and pgm.Effective_End_Date;

Begin
  Open  Pay_Bases_Element;
  Fetch Pay_Bases_Element into l_input_Value_id,l_annualization_factor;
  Close Pay_Bases_Element;
  If l_input_Value_id is NULL Then
     Open  GrdLdr_Element;
     Fetch GrdLdr_Element into l_input_Value_id;
     Close GrdLdr_Element;
       per_pay_proposals_populate.get_payroll(p_assignment_id
                                        ,p_effective_date
                                        ,l_Payroll_name
                                        ,l_annualization_factor);

  End If;
  if l_Input_Value_id is Not NULL Then
     Open Sal;
     Fetch Sal into L_Cur_Sal;
    Close Sal;
  Else
    l_Cur_Sal := 0;
  End If;
  Return L_Cur_Sal;
End Get_annual_Sal;
end pqh_gsp_default;

/
