--------------------------------------------------------
--  DDL for Package Body BEN_EVALUATE_ELIG_CRITERIA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_EVALUATE_ELIG_CRITERIA" as
/* $Header: benelgcr.pkb 120.2 2005/10/26 01:40:56 ssarkar noship $ */
--------------------------------------------------------------------------------
/*
+==============================================================================+
|                       Copyright (c) 1997 Oracle Corporation                  |
|                          Redwood Shores, California, USA                     |
|                               All rights reserved.                           |
+==============================================================================+

Name
        Profile Evaluation Package
Purpose
        This package is used to determine if a person satisfies general  eligiblity
        criteria,rate by criteria  or not.
History
  Date       Who         Version    What?
  ---------  ----------- -------    --------------------------------------------
  13 Jan 04  tjesumic    115.0      Original version
  14 Feb 05  abparekh    115.1      Changed ECV.EXCLUDE_FLAG to ECV.EXCLD_FLAG
  14 Feb 05  tjesumic    115.2      hierarchy position validation fixed for least entry
  24 Feb 05  tjesumic    115.3      if one of the value in is_ok is null the boolean return null
  15 Mar 05  abparekh    115.4      Bug 4234033 : Process non-primary assignments also
  18 oct 05  ssarkar     115.5      Bug 4586880 :eligibility evaluation for set1 and set2.
  26-oct-05  ssarkar     115.6      Bug 4695890 : if set2 returns null , then consider eligibilty not satisfied.
*/
--------------------------------------------------------------------------------
--
g_package varchar2(30) := 'ben_evaluate_elig_criteria.';
--
l_fonm_cvg_strt_dt  date ;
g_debug boolean := hr_utility.debug_enabled;
--
--
-- -----------------------------------------------------
--  find whther any overide value definded for the criteria
-- -----------------------------------------------------

procedure  get_override_value ( p_crit_ovrrd_val_tbl   in pqh_popl_criteria_ovrrd.g_crit_ovrrd_val_tbl
                               ,p_short_code           in varchar2
                               ,p_data_type_cd1        in out nocopy varchar2
                               ,p_value_char1          out nocopy varchar2
                               ,p_value_num1           out nocopy number
                               ,p_value_date1          out nocopy date
                               ,p_data_type_cd2        in out nocopy varchar2
                               ,p_value_char2          out nocopy varchar2
                               ,p_value_num2           out nocopy number
                               ,p_value_date2          out nocopy date
                               ,p_overide_found        out nocopy varchar2
                              ) is

 l_proc          varchar2(100):= g_package||'get_override_value';
 l_dummy_char    varchar2(1) ;
 l_num_val1      number      ;
 l_char_val1     varchar2(15) ;
 l_date_val1     date   ;
 l_num_val2      number  ;
 l_char_val2     varchar2(15) ;
 l_date_val2     date   ;
 l_short_code_found    varchar2(15) ;
begin
  if g_debug then
     hr_utility.set_location('Entering: '||l_proc,10);
     hr_utility.set_location('first: '||p_crit_ovrrd_val_tbl.first ,10);
  end if ;

  p_overide_found       := 'N'  ;
  l_short_code_found    := 'N'  ;
  if p_crit_ovrrd_val_tbl.first  is not null  then
     for i  in p_crit_ovrrd_val_tbl.first .. p_crit_ovrrd_val_tbl.last
     loop
         if  p_short_code =  p_crit_ovrrd_val_tbl(i).criteria_short_code then
             l_num_val1   := p_crit_ovrrd_val_tbl(i).number_value1 ;
             l_num_val2   := p_crit_ovrrd_val_tbl(i).number_value2 ;
             l_char_val1  := p_crit_ovrrd_val_tbl(i).char_value1 ;
             l_char_val2  := p_crit_ovrrd_val_tbl(i).char_value2 ;
             l_date_val1  := p_crit_ovrrd_val_tbl(i).date_value1 ;
             l_date_val2  := p_crit_ovrrd_val_tbl(i).date_value2 ;
             l_short_code_found    := 'Y'  ;
             exit ;
         end if ;
     end loop ;
  end if ;
  -- when the override table has values
  if  l_short_code_found    = 'Y' then
      if  l_num_val1 is not null then
          p_value_num1    := l_num_val1 ;
          p_data_type_cd1 := 'N' ;
          p_overide_found := 'Y' ;
      elsif l_char_val1 is not null then
          p_value_char1    := l_char_val1 ;
          p_data_type_cd1 := 'C' ;
          p_overide_found := 'Y' ;
      elsif l_date_val1 is not null then
          p_value_Date1    := l_date_val1 ;
          p_data_type_cd1 := 'D' ;
          p_overide_found := 'Y' ;
      end if ;
      -- seond value , if the first not nul then  then dont evaluate
      if   p_overide_found = 'Y' then
         if  l_num_val2 is not null then
             p_value_num2    := l_num_val2 ;
             p_data_type_cd2 := 'N' ;
         elsif l_char_val2 is not null then
             p_value_char2    := l_char_val2 ;
             p_data_type_cd2 := 'C' ;
         elsif l_date_val2 is not null then
             p_value_Date2    := l_date_val2 ;
             p_data_type_cd2 := 'D' ;
         end if ;
      end if ;
  end if ;

  if g_debug then
     hr_utility.set_location(' overide data :'||  p_short_code  || ' : ' || l_short_code_found, 5);
     hr_utility.set_location(' overide :' || p_overide_found, 5);
     hr_utility.set_location(' Leaving:' || l_proc, 5);
  end if ;

end  get_override_value ;
--
-- -----------------------------------------------------
--  find whther the organization id in the hierarch
-- -----------------------------------------------------
--
Function find_part_of_org_hierarchy( p_organization_id           in number,
                                    p_org_structure_version_id  in number,
                                    p_start_organization_id     in number,
                                    p_business_group_id         in number,
                                    p_effective_date            in date )
                                    return Boolean  is

 l_proc          varchar2(100):= g_package||'find_part_of_org_hierarchy';
 l_ret_val  boolean  ;
 l_dummy_char    varchar2(1) ;

 -- this cursor validation can not be joined with
 -- other cursor. cieenct by sql statment has issue
 -- when the second table joing with the sql db 9.2.04

 cursor c_osv is
 select 'x'
 from per_org_structure_versions a
 where a.org_structure_version_id = p_org_structure_version_id
   and p_effective_date between nvl(a.date_from,p_effective_date)
       and  nvl(a.date_to,p_effective_date) ;


 cursor c_org_hier is
  select 'x'
  from per_org_structure_elements a
  where a.ORG_STRUCTURE_VERSION_ID = p_org_structure_version_id
  and   a.business_group_id  = p_business_group_id
  and (a.organization_id_parent = p_organization_id
      or a.organization_id_child = p_organization_id)
  start with a.organization_id_parent = p_start_organization_id
  connect by prior a.organization_id_child  = a.organization_id_parent ;
 -- if the least organization defined as start postion
 -- this cursor make sure the person belongs to the org
 cursor c_org is
 select 'x'
 from   per_org_structure_elements a
 where  a.organization_id_child  = p_organization_id
   and  a.organization_id_child  = p_start_organization_id
   and  a.business_group_id  = p_business_group_id
   and  a.ORG_STRUCTURE_VERSION_ID = p_org_structure_version_id
   ;

Begin
  if g_debug then
     hr_utility.set_location('Entering: '||l_proc,10);
  end if ;

  l_ret_val := false ;

  open c_osv ;
  fetch c_osv into l_dummy_char ;
  if c_osv%notfound then
     close c_osv ;
     hr_utility.set_location('Leaving date track : '||l_proc,10);
     Return l_ret_val ;
  end if ;
  close c_osv ;


  open c_org_hier ;
  fetch c_org_hier into l_dummy_char ;
  if c_org_hier%Found then
     l_ret_val := true  ;
     hr_utility.set_location(' Found the organization :' || p_organization_id , 15);
  else
    open  c_org ;
    fetch c_org into l_dummy_char ;
    if c_org%found then
        l_ret_val := true  ;
        hr_utility.set_location(' Found the organization :' || p_organization_id , 20);
    end if ;
    close c_org ;
  end if ;
  close  c_org_hier ;


  if g_debug then
     hr_utility.set_location(' Leaving:' || l_proc, 5);
  end if ;
  Return l_ret_val ;

End find_part_of_org_hierarchy ;

-- -----------------------------------------------------
--  find whther the position id in the hierarchy
-- -----------------------------------------------------
--

Function find_part_of_pos_hierarchy(p_position_id              in number,
                                    p_pos_structure_version_id in number,
                                    p_start_position_id        in number,
                                    p_business_group_id        in number,
                                    p_effective_date           in date)
                                    return Boolean  is

 l_proc          varchar2(100):= g_package||'find_part_of_pos_hierarchy';
 l_ret_val  boolean  ;
 l_dummy_char    varchar2(1) ;

 -- this cursor validation can not be joined with
 -- other cursor. cieenct by sql statment has issue
 -- when the second table joing with the sql db 9.2.04

 cursor c_psv is
 select 'x'
 from per_pos_structure_versions a
 where a.pos_structure_version_id = p_pos_structure_version_id
   and p_effective_date between nvl(a.date_from,p_effective_date)
       and  nvl(a.date_to,p_effective_date) ;


 cursor c_pos_hier is
  select 'x'
  from per_pos_structure_elements  a
  where a.POS_STRUCTURE_VERSION_ID = p_pos_structure_version_id
  and   a.business_group_id  = p_business_group_id
  and (a.parent_position_id = p_position_id
      or a.subordinate_position_id = p_position_id)
  start with a.parent_position_id = p_start_position_id
  connect by prior a.subordinate_position_id  = a.parent_position_id ;


 -- if the least position defined as start postion
 -- this cursor make sure the validation
 -- since it is user defined values
 cursor c_pos is
 select 'x'
 from   per_pos_structure_elements a
 where  a.subordinate_position_id  = p_position_id
   and  a.subordinate_position_id  =  p_start_position_id
   and  a.business_group_id        = p_business_group_id
   and  a.POS_STRUCTURE_VERSION_ID = p_pos_structure_version_id
   ;
Begin
  if g_debug then
     hr_utility.set_location('Entering: '||l_proc,10);
  end if ;
  l_ret_val := false ;

  open c_psv ;
  fetch c_psv into l_dummy_char ;
  if c_psv%notfound then
     close c_psv ;
     hr_utility.set_location('Leaving date track : '||l_proc,10);
     Return l_ret_val ;
  end if ;
  close c_psv ;


  open c_pos_hier ;
  fetch c_pos_hier into l_dummy_char ;
  if c_pos_hier%Found then
     l_ret_val := true  ;
     hr_utility.set_location(' Found the position :' || p_position_id , 15);
  else
    open  c_pos ;
    fetch c_pos into l_dummy_char ;
    if c_pos%found then
        l_ret_val := true  ;
        hr_utility.set_location(' Found the position :' || p_position_id , 20);
    end if ;
    close c_pos ;
  end if ;
  close  c_pos_hier ;


  if g_debug then
     hr_utility.set_location(' Leaving:' || l_proc, 5);
  end if ;
  Return l_ret_val ;

End find_part_of_pos_hierarchy ;


--
-- -----------------------------------------------------
--  get the values from formula
-- -----------------------------------------------------
--4586880
-- Its modified so that it would have only one set of char/num/date output
-- Input =ACCESS_CALC_RULE / ACCESS_CALC_RULE2
procedure get_formula_value
         ( p_person_id        number ,
          p_assignment_id     number,
          p_formula_id        number default null,
          p_business_group_id number ,
          p_data_type_cd     varchar2,
          p_value_char       out nocopy varchar2,
          p_value_num        out nocopy number ,
          p_value_date       out nocopy date   ,
          p_pgm_id            in number default null,
          p_pl_id             in number default null,
          p_opt_id            in number default null,
          p_oipl_id           in number default null,
          p_ler_id            in number default null,
          p_pl_typ_id         in number default null,
          p_effective_date    date ,
          p_fonm_cvg_strt_date date default null ,
          p_fonm_rt_strt_date  date default null
          ) is

 l_proc          varchar2(100):= g_package||'get_formula_value';
 l_statement     varchar2(3000) ;
 l_output        ff_exec.outputs_t;
 l_dummy         varchar2(3000) ;
 l_effective_date date ;
 --
Begin

  if g_debug then
     hr_utility.set_location('Entering: '||l_proc,10);
  end if ;

  if p_formula_id is not null then
      l_output := benutils.formula
                         (p_formula_id        => p_formula_id
                         ,p_effective_date    => p_effective_date
                         ,p_business_group_id => p_business_group_id
                         ,p_assignment_id     => p_assignment_id
                         ,p_pgm_id            => p_pgm_id
                         ,p_pl_id             => p_pl_id
                         ,p_ler_id            => p_ler_id
                         ,p_opt_id            => p_opt_id
                         ,p_pl_typ_id         => p_pl_typ_id
                         ,p_param1            => 'BEN_IV_RT_STRT_DT'
                         ,p_param1_value      => fnd_date.date_to_canonical(p_fonm_rt_strt_date)
                         ,p_param2            => 'BEN_IV_CVG_STRT_DT'
                         ,p_param2_value      => fnd_date.date_to_canonical(p_fonm_cvg_strt_date)
                         );
       for l_count in l_output.first..l_output.last loop
           l_dummy  := l_output(l_count).value;
           hr_utility.set_location(l_count ||' : ' || l_dummy, 5);
           if l_dummy is not null then

                 if p_data_type_cd = 'C' then
                    p_value_char    := l_dummy ;
                 elsif  p_data_type_cd = 'N' then
                    p_value_num    := to_number(l_dummy) ;
                 elsif p_data_type_cd = 'D' then
                    p_value_date    := to_date(l_dummy,'YYYY/MM/DD HH24:MI:SS') ;
                 end if ;

           end if ;-- if dummy
       end loop ;

  end if ;

  if g_debug then
     hr_utility.set_location(' char return :' || p_value_char, 5);
     hr_utility.set_location(' num  return :' || p_value_num , 5);
     hr_utility.set_location(' date  return :'|| p_value_date, 5);

     hr_utility.set_location(' Leaving:' || l_proc, 5);
  end if ;

end get_formula_value ;
--
-- -----------------------------------------------------
--  get the values from   accesss table
-- -----------------------------------------------------
--
procedure get_values_access_table
         (p_table_name        varchar2,
          p_column_name       varchar2,
          p_data_type_cd      varchar2,
          p_person_id         number ,
          p_assignment_id     number,
          p_business_group_id number ,
          p_value_char        out nocopy varchar2,
          p_value_num         out nocopy number ,
          p_value_date        out nocopy date   ,
          p_effective_date    date ,
          p_fonm_cvg_strt_date date default null ,
          p_fonm_rt_strt_date  date default null
          ) is

 l_proc          varchar2(100):= g_package||'get_values_access_table';
 l_statement     varchar2(3000) ;
 l_output        ff_exec.outputs_t;
 l_dummy         varchar2(3000) ;
 l_effective_date date ;
 --
 TYPE valueCurType  is REF CURSOR;
 l_valcur  valueCurType   ;
 --
 l_current_loc NUMBER:=0;
Begin
  if g_debug then
     hr_utility.set_location('Entering: '||l_proc,10);
  end if ;
  l_effective_date := nvl(p_fonm_rt_strt_date,nvl(p_fonm_cvg_strt_date,p_effective_date)) ;

  -- build the dynamic statement
  l_statement  := 'Select  ' || p_column_name ||
                   ' From ' || p_table_name  || ' tbl ' ||
                   ' Where person_id =  ' || p_person_id  ||
                   ' and   to_date(''' || to_char(l_effective_date,'DD-MM-RRRR')|| ''',''DD-MM-RRRR'') ' ||
                   '  between tbl.effective_start_date   and   tbl.effective_end_date  ' ;

  if p_table_name = 'PER_ALL_PEOPLE_F' or p_table_name = 'PER_PEOPLE_F' then
     l_statement := l_statement|| ' order by tbl.effective_start_date desc  '  ; -- for the timing nothing
  elsif p_table_name = 'PER_ALL_ASSIGNMENTS_F' or p_table_name = 'PER_ASSIGNMENTS_F'    then
     l_statement := l_statement|| ' and  Assignment_id = ' || p_assignment_id ||
     --                 ' and  primary_flag = ''Y'' order by tbl.effective_start_date desc  '  ;  /* Bug 4234033 */
                        ' order by tbl.effective_start_date desc  '  ;
  end if ;
  --l_statement := l_statement ||  ' ; ' ;
  --
  --  get the value from the dynamic statment
  --  errors when the statment fails
  begin
     open l_valcur for l_statement ;
  exception
     --
     when others then
        --
        fnd_file.put_line(fnd_file.log,'Error executing this dynamically build SQL Statement: ');
        FOR i in 1..LENGTH(l_statement) LOOP
          IF mod(i,80)=0 OR i=LENGTH(l_statement) THEN
            fnd_file.put_line(fnd_file.log,'  ' ||substr(l_statement,l_current_loc+1,i-l_current_loc));
            l_current_loc:=i;
           END IF;
         END LOOP;
         raise;
         --
  end;
  --- eof dynamic sql

  open l_valcur for l_statement ;
  if p_data_type_cd ='C'  then
      fetch l_valcur  into p_value_char ;
  elsif p_data_type_cd ='N'  then
      fetch l_valcur  into p_value_num ;
  elsif  p_data_type_cd ='D'  then
      fetch l_valcur  into p_value_date ;
  end if ;
  close  l_valcur ;

  if g_debug then
     hr_utility.set_location(' char return :' || p_value_char, 5);
     hr_utility.set_location(' num  return :' || p_value_num , 5);
     hr_utility.set_location(' date  return :'|| p_value_date, 5);
     hr_utility.set_location(' Leaving:' || l_proc, 5);
  end if ;
exception
 when others then
   hr_utility.set_location(' exception:' || substr(sqlerrm,1,110), 5);
   raise ;
End get_values_access_table ;



function is_ok (p_value       varchar2  ,
                p_from_value  varchar2  ,
                p_to_value    varchar2 default null,
                p_range_check  varchar2 default 'N' )
                return boolean is

 l_proc               varchar2(100):= g_package||'is_ok C';
 l_return      boolean ;
begin
  if g_debug then
    hr_utility.set_location('Entering: '||l_proc,10);
    hr_utility.set_location('range : '||p_range_check,10);
  end if ;
 l_return := false ;
 if p_range_check = 'N'  then
    l_return := (p_value = p_from_value ) ;

 else
   l_return  := ( p_value   between p_from_value and  p_to_value ) ;

 end if ;
 -- if one of the value is null then
 -- l_return  is null # 4205818
 if l_return is null then
    l_return := false ;
 end if ;
 if g_debug then
    hr_utility.set_location(' Leaving:' || l_proc, 5);
 end if ;
  return l_return ;
end  is_ok ;


-- override function for numeric
function is_ok (p_value       number  ,
                p_from_value  number  ,
                p_to_value    number default null,
                p_range_check  varchar2 default 'N' )
                return boolean is

 l_proc               varchar2(100):= g_package||'is_ok N';
 l_return      boolean ;
begin
  if g_debug then
    hr_utility.set_location('Entering: '||l_proc,10);
    hr_utility.set_location('range : '||p_range_check,10);
  end if ;
  l_return := false ;
  if  p_range_check = 'N'  then
     l_return := (p_value = p_from_value ) ;

  else
    l_return  := ( p_value   between p_from_value and  p_to_value ) ;

  end if ;

  -- if one of the value is null then
  -- l_return  is null # 4205818
  if l_return is null then
     l_return := false ;
  end if ;

  if g_debug then
     hr_utility.set_location(' Leaving:' || l_proc, 5);
  end if ;
  return l_return ;
end  is_ok ;

-- override function for numeric
function is_ok (p_value       date  ,
                p_from_value  date  ,
                p_to_value    date default null,
                p_range_check  varchar2 default 'N' )
                return boolean is

 l_proc               varchar2(100):= g_package||'is_ok D';
 l_return      boolean ;
begin
  if g_debug then
    hr_utility.set_location('Entering: '||l_proc,10);
    hr_utility.set_location('range : '||p_range_check,10);
  end if ;
  l_return := false ;
  if p_range_check = 'N' then
     l_return := (p_value = p_from_value ) ;

  else
    l_return  := ( p_value   between p_from_value and  p_to_value ) ;

  end if ;
  -- if one of the value is null then
  -- l_return  is null # 4205818
  if l_return is null then
     l_return := false ;
  end if ;

  if g_debug then
     hr_utility.set_location(' Leaving:' || l_proc, 5);
  end if ;
  return l_return ;
end  is_ok ;

-- 4586880
-- --------- Function set_true_false -----------
-- validates the value defined by SET1/SET2
-- returns True if satisfies
-- else False.
------------------------------------------------
Function set_true_false(p_crit_col_datatype           varchar2,
	                p_value_char                  varchar2,
			p_value_num                   number,
     		        p_value_date                  date,
                        p_char_from_value             varchar2,
			p_char_to_value               varchar2 default null,
			p_num_from_value              number,
			p_num_to_value                number default null,
			p_date_from_value             date,
			p_date_to_value               date default null,
			p_allow_range_validation_flag varchar2 default 'N'
			)
			return Boolean  is

 l_proc               varchar2(100):= g_package||'set_true_false';
 l_return      boolean ;

 begin
  if g_debug then
    hr_utility.set_location('Entering: '||l_proc,5);
  end if ;

  if     p_crit_col_datatype = 'C' then
            l_return :=   is_ok(p_value_char,p_char_from_value,p_char_to_value,p_allow_range_validation_flag)  ;
  elsif  p_crit_col_datatype = 'N' then
            l_return :=   is_ok(p_value_num,p_num_from_value,p_num_to_value,p_allow_range_validation_flag)  ;
  elsif  p_crit_col_datatype = 'D' then
            l_return :=  is_ok(p_value_date,p_date_from_value,p_date_to_value,p_allow_range_validation_flag)  ;
  end if ;

  if g_debug then
     hr_utility.set_location(' Leaving:' || l_proc, 10);
  end if ;

  return l_return;

end set_true_false;
--
-- -----------------------------------------------------
--  This procedure determines  define criteria for rate by criteria RBC.
-- -----------------------------------------------------
-- 4586880

procedure main(p_eligy_prfl_id        in number,
               p_person_id            in number,
               p_assignment_id        in number,
               p_business_group_id    in number,
               p_pgm_id               in number default null,
               p_pl_id                in number default null,
               p_opt_id               in number default null,
               p_oipl_id              in number default null,
               p_ler_id               in number default null,
               p_pl_typ_id            in number default null,
               p_effective_date       in date,
               p_fonm_cvg_strt_date   in date default null,
               p_fonm_rt_strt_date    in date default null,
               p_crit_ovrrd_val_tbl   in pqh_popl_criteria_ovrrd.g_crit_ovrrd_val_tbl
              )  is



 l_effective_date  date  ;

 cursor c_dst_egc is
 select distinct egc.eligy_criteria_id
 from  ben_eligy_criteria egc,
       ben_eligy_crit_values_f egv
 where egv.eligy_prfl_id       = p_eligy_prfl_id
   and egv.eligy_criteria_id   = egc.eligy_criteria_id
   and egc.business_group_id   = p_business_group_id
   and egc.criteria_type      <> 'SEED'
   and l_effective_date between egv.effective_Start_date
        and egv.effective_end_date  ;

 cursor c_info_egc (p_eligy_criteria_id number ) is
  select egc.criteria_type ,
        egc.crit_col1_val_type_cd,
        egc.crit_col1_datatype,
        egc.access_table_name1,
        egc.access_column_name1,
        egc.crit_col2_datatype,
        egc.access_table_name2,
        egc.access_column_name2,
        egc.access_calc_rule,
	egc.access_calc_rule2,
        egc.allow_range_validation_flag,
	egc.allow_range_validation_flag2,
        egc.name,
        egc.short_code
  from  ben_eligy_criteria egc
  where eligy_criteria_id = p_eligy_criteria_id ;

  l_info_egc  c_info_egc%rowtype ;

 cursor c_egv (p_eligy_prfl_id number ,
               p_eligy_criteria_id number ) is
 select egv.number_value1 ,
        egv.number_value2 ,
        egv.char_value1 ,
        egv.char_value2 ,
        egv.date_value1 ,
        egv.date_value2 ,
	egv.number_value3 ,
        egv.number_value4 ,
        egv.char_value3 ,
        egv.char_value4 ,
        egv.date_value3 ,
        egv.date_value4 ,
        egv.EXCLD_FLAG
  from  ben_eligy_crit_values_f egv
  where egv.eligy_prfl_id = p_eligy_prfl_id
   and  egv.eligy_criteria_id = p_eligy_criteria_id
   and  egv.business_group_id = p_business_group_id
   and  p_effective_date between egv.effective_Start_date
        and egv.effective_end_date
  -- order by ordr_num
  ;
  l_egv  c_egv%rowtype  ;


 l_proc               varchar2(100):= g_package||'main';
 l_crit_value_checked varchar2(1) ;
 --
 l_value_char1        varchar2(4000) ;
 l_value_num1         number   ;
 l_value_date1        date    ;
 l_value_char2        varchar2(4000) ;
 l_value_num2         number  ;
 l_value_date2        date    ;
 l_true_false1        boolean ;
 l_true_false2        boolean ;
 l_error_value1       varchar2(4000) ;
 l_error_value2       varchar2(4000) ;
 l_eror_crit_name     ben_eligy_criteria.name%type ;
 l_overide_found      varchar2(1) ;
 l_crit_found         varchar2(1) ;

Begin
/*if p_person_id = 282401 then
hr_utility.trace_on(null,'rbc');
end if;*/
  g_debug := hr_utility.debug_enabled;
  if g_debug then
     hr_utility.set_location('Entering: '||l_proc,10);
  end if ;
  l_effective_date     := nvl(p_fonm_cvg_strt_date,nvl(p_fonm_rt_strt_date,p_effective_date)) ;
  l_crit_value_checked := 'Y'  ;
  if g_debug then
     hr_utility.set_location('effective date : '||p_effective_date,11);
     hr_utility.set_location('fonm effective date : '||l_effective_date,11);
  end if ;

  for i in  c_dst_egc
  loop
     hr_utility.set_location('eligy_criteria_id   : '||i.eligy_criteria_id,20);
     open c_info_egc (i.eligy_criteria_id) ;
     fetch c_info_egc into l_info_egc ;
     close c_info_egc ;
     l_overide_found := 'N' ;

     get_override_value ( p_crit_ovrrd_val_tbl => p_crit_ovrrd_val_tbl,
                          p_short_code         => l_info_egc.short_code,
                          p_data_type_cd1      => l_info_egc.crit_col1_datatype,
                          p_value_char1        => l_value_char1 ,
                          p_value_num1         => l_value_num1  ,
                          p_value_date1        => l_value_date1 ,
                          p_data_type_cd2      => l_info_egc.crit_col2_datatype,
                          p_value_char2        => l_value_char2,
                          p_value_num2         => l_value_num2 ,
                          p_value_date2        => l_value_date2,
                          p_overide_found      => l_overide_found
                        ) ;

     if l_overide_found = 'N'  then
     /*** 4586880
       1.  If ACCESS_CALC_RULE defined
           get_formula_value
            o/p =  l_value_num1 ,l_value_char1, l_value_date1
       2.  else get_values_access_table using access_table_name1 ,access_column_name1
            o/p =  l_value_num1 ,l_value_char1, l_value_date1

       3.  if ACCESS_CALC_RULE2 defined
            get_formula_value
            o/p =  l_value_num2 ,l_value_char2, l_value_date2
       4.  else  get_values_access_table using using access_table_name2 ,access_column_name2
            o/p =  l_value_num2 ,l_value_char2, l_value_date2

     ***/
        if l_info_egc.ACCESS_CALC_RULE is not null then
           get_formula_value
              ( p_person_id         => p_person_id ,
                p_assignment_id     => p_assignment_id,
                p_formula_id        => l_info_egc.access_calc_rule,
                p_business_group_id => p_business_group_id,
                p_data_type_cd     => l_info_egc.crit_col1_datatype,
                p_value_char       => l_value_char1 ,
                p_value_num        => l_value_num1  ,
                p_value_date       => l_value_date1 ,
                p_pgm_id            => p_pgm_id ,
                p_pl_id             => p_pl_id ,
                p_opt_id            => p_opt_id ,
                p_oipl_id           => p_oipl_id ,
                p_ler_id            => p_ler_id ,
                p_pl_typ_id         => p_pl_typ_id ,
                p_effective_date    => p_effective_date,
                p_fonm_cvg_strt_date=> p_fonm_cvg_strt_date ,
                p_fonm_rt_strt_date => p_fonm_rt_strt_date
                ) ;

        else
           -- get the values from the table column
	   hr_utility.set_location('get the values from the table column SET1',99099);
           get_values_access_table
              (p_table_name         => l_info_egc.access_table_name1 ,
               p_column_name        => l_info_egc.access_column_name1,
               p_data_type_cd       => l_info_egc.crit_col1_datatype ,
               p_person_id          => p_person_id  ,
               p_assignment_id      => p_assignment_id,
               p_business_group_id  => p_business_group_id,
               p_value_char         => l_value_char1 ,
               p_value_num          => l_value_num1  ,
               p_value_date         => l_value_date1 ,
               p_effective_date     => p_effective_date,
               p_fonm_cvg_strt_date => p_fonm_cvg_strt_date,
               p_fonm_rt_strt_date  => p_fonm_rt_strt_date
               ) ;



            if l_value_char1 is null and l_value_num1 is null and l_value_date1 is null then
              -- RAISE the ERROR a
              null ;
            end if ;

	 end if; --l_info_egc.ACCESS_CALC_RULE
	  hr_utility.set_location('l_info_egc.access_table_name1 '||l_info_egc.access_table_name1,99011);
	      hr_utility.set_location('l_info_egc.access_column_name1 '||l_info_egc.access_column_name1,99011);
	      hr_utility.set_location('l_info_egc.access_calc_rule '||l_info_egc.access_calc_rule,99011);
	      hr_utility.set_location('l_info_egc.crit_col1_datatype '||l_info_egc.crit_col1_datatype,99011);
	      hr_utility.set_location('l_info_egc.allow_range_validation_flag '||l_info_egc.allow_range_validation_flag,99011);
	      hr_utility.set_location('l_value_char1 '||l_value_char1,99011);
	      hr_utility.set_location('l_value_num1 '||l_value_num1,99011);
	      hr_utility.set_location('l_value_date1 '||l_value_date1,99011);

         if l_info_egc.ACCESS_CALC_RULE2 is not null then
           get_formula_value
              ( p_person_id         => p_person_id ,
                p_assignment_id     => p_assignment_id,
                p_formula_id        => l_info_egc.access_calc_rule2,
                p_business_group_id => p_business_group_id,
                p_data_type_cd     => l_info_egc.crit_col2_datatype,
                p_value_char       => l_value_char2 ,
                p_value_num        => l_value_num2  ,
                p_value_date       => l_value_date2 ,
                p_pgm_id            => p_pgm_id ,
                p_pl_id             => p_pl_id ,
                p_opt_id            => p_opt_id ,
                p_oipl_id           => p_oipl_id ,
                p_ler_id            => p_ler_id ,
                p_pl_typ_id         => p_pl_typ_id ,
                p_effective_date    => p_effective_date,
                p_fonm_cvg_strt_date=> p_fonm_cvg_strt_date ,
                p_fonm_rt_strt_date => p_fonm_rt_strt_date
                ) ;

        elsif l_info_egc.access_table_name2 is not null then
	    hr_utility.set_location('get the values from the table column SET2',99099);
               get_values_access_table
                 (p_table_name         => l_info_egc.access_table_name2 ,
                  p_column_name        => l_info_egc.access_column_name2,
                  p_data_type_cd       => l_info_egc.crit_col2_datatype ,
                  p_person_id          => p_person_id  ,
                  p_assignment_id      => p_assignment_id,
                  p_business_group_id  => p_business_group_id,
                  p_value_char         => l_value_char2 ,
                  p_value_num          => l_value_num2  ,
                  p_value_date         => l_value_date2 ,
                  p_effective_date     => p_effective_date,
                  p_fonm_cvg_strt_date => p_fonm_cvg_strt_date,
                  p_fonm_rt_strt_date  => p_fonm_rt_strt_date
                  ) ;

        end if ; --if l_info_egc.ACCESS_CALC_RULE2
	      hr_utility.set_location('l_info_egc.access_table_name2 '||l_info_egc.access_table_name2,99011);
	      hr_utility.set_location('l_info_egc.access_column_name2 '||l_info_egc.access_column_name2,99011);
	      hr_utility.set_location('l_info_egc.access_calc_rule2 '||l_info_egc.access_calc_rule2,99011);
	      hr_utility.set_location('l_info_egc.crit_col2_datatype '||l_info_egc.crit_col2_datatype,99011);
              hr_utility.set_location('l_info_egc.allow_range_validation_flag2 '||l_info_egc.allow_range_validation_flag2,99011);
	      hr_utility.set_location('l_value_char2 '||l_value_char2,99011);
	      hr_utility.set_location('l_value_num2 '||l_value_num2,99011);
	      hr_utility.set_location('l_value_date2 '||l_value_date2,99011);

     end if ; --l_overide_found = 'N'
      --- intialise the falg value
      l_crit_value_checked := 'Y'  ;
      l_true_false1        := true ;
      l_true_false2        := true ;

      --- here is automatic conversion from value to varchar
      --- we dont have to change the date/number formats
      --- this variable displyed in log in case of criteria failure
      l_error_value1 := l_value_char1||l_value_num1||l_value_date1 ;
      l_error_value2 := l_value_char2||l_value_num2||l_value_date2 ;
      if  l_error_value2 is not null then
          l_error_value1 :=  l_error_value1 || ' , ' || l_error_value2  ;
      end if ;
      hr_utility.set_location(' person  values   : '|| l_error_value1 ,30);
      l_eror_crit_name := l_info_egc.name ;
      ---

      for l in   c_egv(p_eligy_prfl_id ,
                  i.eligy_criteria_id)
      loop
         if g_debug then
            hr_utility.set_location('eligy_criteria_values  C  : '||l.char_value1   ||' /  ' || l.char_value2||' and '||l.char_value3 ||'/ '||l.char_value4 ,30);
            hr_utility.set_location('eligy_criteria_values  N  : '||l.number_value1 ||' /  ' || l.number_value2||' and '||l.number_value3 ||'/ '||l.number_value4 ,30);
            hr_utility.set_location('eligy_criteria_values  D  : '||l.date_value1   ||' /  ' || l.date_value2 ||' and '||l.date_value3 ||'/ '||l.date_value4,30);
         end if ;
         -- intialize the variable for the calue row
         l_crit_value_checked := 'Y'  ;
         l_true_false1        := true ;
         l_true_false2        := true ;
	 /***4586880
	   1. check if hierarchy is defined on Organization/Position .
	        Validate the hierarchy .
	   2. Else Validate the output of EGL with those defined at ECV
	     I. Validate l_value_num1 against 1.number_value1 / 1.number_value2
	        similarly goes for l_value_char1, l_value_date1
	     II. Validate l_value_num2 against 1.number_value3 / 1.number_value4
                similarly goes for l_value_char2, l_value_date2
	 ***/
        --1. check if hierarchy is defined on Organization/Position .
         if l_info_egc.crit_col1_val_type_cd in ('ORG_HIER','POS_HIER') then
            if l_info_egc.crit_col1_val_type_cd = 'ORG_HIER' then

               if not (find_part_of_org_hierarchy(p_organization_id           => l_value_num1,
                                                  p_org_structure_version_id  => l.number_value1,
                                                  p_start_organization_id     => l.number_value2,
                                                  p_business_group_id         => p_business_group_id,
                                                  p_effective_date            => p_effective_date)
                                                  ) then
                    l_crit_value_checked := 'N'  ;
                end if ;

            else

               if not (find_part_of_pos_hierarchy(p_position_id              => l_value_num1,
                                                 p_pos_structure_version_id  => l.number_value1,
                                                 p_start_position_id         => l.number_value2,
                                                 p_business_group_id         => p_business_group_id,
                                                 p_effective_date            => p_effective_date)
                                                 ) then
                    l_crit_value_checked := 'N'  ;
                end if ;
            end if ;

         else --2. Else Validate the output of EGL with those defined at ECV
            -- I. Validate l_value_num1 against 1.number_value1 / 1.number_value2
	    --   similarly goes for l_value_char1, l_value_date1
            l_true_false1 := set_true_false( p_crit_col_datatype           => l_info_egc.crit_col1_datatype,
	                                     p_value_char                  => l_value_char1,
					     p_value_num                   => l_value_num1,
					     p_value_date                  => l_value_date1,
                                             p_char_from_value             => l.char_value1,
					     p_char_to_value               => l.char_value2,
					     p_num_from_value              => l.number_value1,
					     p_num_to_value                => l.number_value2,
					     p_date_from_value             => l.date_value1,
					     p_date_to_value               => l.date_value2,
					     p_allow_range_validation_flag => nvl(l_info_egc.allow_range_validation_flag,'N')
					     );
           -- II. Validate l_value_num2 against 1.number_value3 / 1.number_value4
           --     similarly goes for l_value_char2, l_value_date2
	  -- Bug 4695890 -- if condition.
	   if l_info_egc.access_calc_rule2 is not null or (l_info_egc.access_column_name2 is not null and l_info_egc.access_column_name2 is not null)then
             l_true_false2 := set_true_false( p_crit_col_datatype            => l_info_egc.crit_col2_datatype,
	                                     p_value_char                    => l_value_char2,
					     p_value_num                     => l_value_num2 ,
					     p_value_date                    => l_value_date2,
                                             p_char_from_value               => l.char_value3,
					     p_char_to_value                 => l.char_value4,
					     p_num_from_value                => l.number_value3,
					     p_num_to_value                  => l.number_value4,
					     p_date_from_value               => l.date_value3,
					     p_date_to_value                 => l.date_value4,
					     p_allow_range_validation_flag   => nvl(l_info_egc.allow_range_validation_flag2,'N')
					     );
            end if;
           /*** 4586880
	   1.Validate the result of set 1 and set 2
	   I.SET1 defined and SET2 not defined
	       set1  set2
	       true  true   = true
	       false true   = false
	   II.SET1 not defined and SET2 defined
	       set1  set2
               true  true   = true
	       true  false  = false
           III.BOTH SET1 and SET2 defined
	       set1 set2
	       true true   = true
	       true false  = false
	       false true  = false
	       false false = false
	   2. IF result is false means criteria is not satisfied.So, set l_crit_value_checked to 'N'
	   ***/
	   if not ( l_true_false1 and l_true_false2 ) then
                    l_crit_value_checked := 'N'  ;
           end if;

         end if; -- ('ORG_HIER','POS_HIER')


         -- if one of the value satified  exit the  loop , value loop works in OR condition
         -- also validate the exclude flag
        ---    Met the condition   Exclude
        ---            Y             N           exit  and validate further criteria
        ---            Y             Y           exit  consider prfile failed
        ---            N             N           validate further values to see whether he pass any values
        ---            N             Y           treate like he meets the condition  Y and N

         hr_utility.set_location('end result  : '||l_crit_value_checked,20);
         hr_utility.set_location('exclude  : '||l.EXCLD_FLAG,20);
         if  l_crit_value_checked = 'Y' and l.EXCLD_FLAG = 'N'   then
             --- when one of the value satisfied and exclde flag is false
             --- exit, next criteria will be validated for failure
             exit ;
         elsif l_crit_value_checked = 'Y' and l.EXCLD_FLAG = 'Y'   then
             --- when a person met the condition and he is to be exclude
             --- he is not eligible for ne need to validate next criteria
             --- change the  falg to 'N' and exit
             l_crit_value_checked := 'N' ;
             exit ;

         elsif l_crit_value_checked = 'N' and l.EXCLD_FLAG = 'N'   then
             --- when there is failure in value and no exclude flag
             --- dont do  anything, evaluate the next values for the
             --- same criteria -- no need for the if condition
             --- this is added only for better understanding
             null ;
         elsif l_crit_value_checked = 'N' and l.EXCLD_FLAG = 'Y'   then
             --- consider the condition is met and lookup for any further validate
             --- to validate, this is as good as  Y and N
              l_crit_value_checked := 'Y' ;
              exit ;
         end if ;
          hr_utility.set_location('after exclude end result  : '||l_crit_value_checked,20);

      end Loop  ;

      -- if any of the criteria failed (non of the value matched) then exit
      -- criteria works in AND condition
       if l_crit_value_checked = 'N'  then
          exit ;
       end if ;
  end Loop ;


  hr_utility.set_location('end result  : '||l_crit_value_checked,20);
  if l_crit_value_checked = 'N'  then
     ben_evaluate_elig_profiles.g_inelg_rsn_cd := 'RBC';
     fnd_message.set_name('BEN','BEN_94124_RBC_PRFL_FAIL');
     hr_utility.set_location('Criteria Failed: '||l_proc,20);
     benutils.write(p_text => 'Generic Criteria  : '|| l_eror_crit_name
                      );
     benutils.write(p_text => 'Criteria Values   : '||l_error_value1
                      );
  --
     raise  ben_evaluate_elig_profiles.g_criteria_failed;
    --
  end if ;
  if g_debug then
     hr_utility.set_location(' Leaving:' || l_proc, 5);
  end if ;
end main ;



end  ben_evaluate_elig_criteria;

/
