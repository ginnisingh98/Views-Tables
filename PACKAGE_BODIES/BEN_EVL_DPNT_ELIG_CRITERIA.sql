--------------------------------------------------------
--  DDL for Package Body BEN_EVL_DPNT_ELIG_CRITERIA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_EVL_DPNT_ELIG_CRITERIA" as
/* $Header: bendpcrt.pkb 120.0.12010000.3 2010/05/12 06:51:22 krupani noship $ */

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
        This package is used to determine if a dependent satisfies general eligiblity
        criteria or not.
History
  Date       Who         Version             What?
  ---------  ----------- -------             --------------------------------------------
  07-Apr-10  krupani     120.0               Enh 9558250 - created package to evaluate
                                             user defined criteria for dependent
  12-May-10  krupani   120.0.12010000.3      Bug 9688328 - changed the inelig_rsn_cd from 'RBC' to 'OTH'.
*/
--------------------------------------------------------------------------------


--
g_package varchar2(30) := 'ben_evl_dpnt_elig_criteria.';
g_debug boolean := hr_utility.debug_enabled;
--
--
-- -----------------------------------------------------
--  get the values from accesss table
-- -----------------------------------------------------
--
procedure get_values_access_table
         (p_table_name        varchar2,
          p_column_name       varchar2,
          p_data_type_cd      varchar2,
          p_person_id         number ,
          p_business_group_id number ,
          p_value_char        out nocopy varchar2,
          p_value_num         out nocopy number ,
          p_value_date        out nocopy date   ,
          p_effective_date    date
          ) is

 l_proc          varchar2(100):= g_package||'get_values_access_table';
 l_statement     varchar2(3000) ;
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

  -- build the dynamic statement
  l_statement  := 'Select  ' || p_column_name ||
                   ' From ' || p_table_name  || ' tbl ' ||
                   ' Where person_id =  ' || p_person_id  ||
                   ' and   to_date(''' || to_char(p_effective_date,'DD-MM-RRRR')|| ''',''DD-MM-RRRR'') ' ||
                   '  between tbl.effective_start_date   and   tbl.effective_end_date  ' ;

  if p_table_name = 'PER_ALL_PEOPLE_F' or p_table_name = 'PER_PEOPLE_F' then
     l_statement := l_statement|| ' order by tbl.effective_start_date desc  '  ;
  end if ;
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

  if l_return is null then
     l_return := false ;
  end if ;

  if g_debug then
     hr_utility.set_location(' Leaving:' || l_proc, 5);
  end if ;
  return l_return ;
end  is_ok ;


-- --------- Function set_true_false -----------
-- validates the value defined by SET1/SET2
-- returns True if satisfies
-- else False.
------------------------------------------------
Function set_true_false
         (p_crit_col_datatype           varchar2,
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

 l_proc        varchar2(100):= g_package||'set_true_false';
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



-- -----------------------------------------------------
--  This procedure determines  define criteria for rate by criteria RBC.
-- -----------------------------------------------------


procedure main(p_dpnt_cvg_eligy_prfl_id        in number,
               p_person_id            in number,
               p_business_group_id    in number,
               p_lf_evt_ocrd_dt       in date,
               p_effective_date       in date,
               p_eligible_flag     out nocopy varchar2,
               p_inelig_rsn_cd     out nocopy varchar2) is

l_effective_date  date  ;


 cursor c_dst_egc is
 select distinct egc.eligy_criteria_dpnt_id
 from  ben_eligy_criteria_dpnt egc,
       ben_dpnt_eligy_crit_values_f egv
 where egv.dpnt_cvg_eligy_prfl_id       = p_dpnt_cvg_eligy_prfl_id
   and egv.eligy_criteria_dpnt_id   = egc.eligy_criteria_dpnt_id
   and egc.business_group_id   = p_business_group_id
   and egc.criteria_type      <> 'SEED'
   and l_effective_date between egv.effective_Start_date
        and egv.effective_end_date  ;


 cursor c_info_egc (p_eligy_criteria_dpnt_id number ) is
  select egc.criteria_type ,
        egc.crit_col1_val_type_cd,
        egc.crit_col1_datatype,
        egc.access_table_name1,
        egc.access_column_name1,
        egc.crit_col2_datatype,
        egc.access_table_name2,
        egc.access_column_name2,
        egc.allow_range_validation_flag,
	     egc.allow_range_validation_flag2,
        egc.name,
        egc.short_code
  from  ben_eligy_criteria_dpnt egc
  where eligy_criteria_dpnt_id = p_eligy_criteria_dpnt_id ;

  l_info_egc  c_info_egc%rowtype ;


 cursor c_egv (p_dpnt_cvg_eligy_prfl_id number ,
               p_eligy_criteria_dpnt_id number ) is
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
  from  ben_dpnt_eligy_crit_values_f egv
  where egv.dpnt_cvg_eligy_prfl_id = p_dpnt_cvg_eligy_prfl_id
   and  egv.eligy_criteria_dpnt_id = p_eligy_criteria_dpnt_id
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
 l_eror_crit_name     ben_eligy_criteria_dpnt.name%type ;
 l_overide_found      varchar2(1) ;
 l_crit_found         varchar2(1) ;
 l_fonm_cvg_strt_dt   date;

Begin

  g_debug := hr_utility.debug_enabled;
  if g_debug then
     hr_utility.set_location('Entering: '||l_proc,10);
  end if ;

  l_effective_date  :=  nvl(p_lf_evt_ocrd_dt,p_effective_date ) ;

  if ben_manage_life_events.fonm = 'Y'
      and ben_manage_life_events.g_fonm_cvg_strt_dt is not null then
     --
     l_fonm_cvg_strt_dt := ben_manage_life_events.g_fonm_cvg_strt_dt ;
     l_effective_date   := nvl(l_fonm_cvg_strt_dt,l_effective_date ) ;

     --
  end if;

  l_crit_value_checked := 'Y'  ;
  if g_debug then
     hr_utility.set_location('effective date : '||p_effective_date,11);
     hr_utility.set_location('fonm effective date : '||l_effective_date,11);
  end if ;


  for i in c_dst_egc
  loop
     hr_utility.set_location('eligy_criteria_dpnt_id   : '||i.eligy_criteria_dpnt_id,20);
     open c_info_egc (i.eligy_criteria_dpnt_id) ;
     fetch c_info_egc into l_info_egc ;
     close c_info_egc ;

	        hr_utility.set_location('get the values from the table column SET1',99099);
           get_values_access_table
              (p_table_name         => l_info_egc.access_table_name1 ,
               p_column_name        => l_info_egc.access_column_name1,
               p_data_type_cd       => l_info_egc.crit_col1_datatype ,
               p_person_id          => p_person_id  ,
               p_business_group_id  => p_business_group_id,
               p_value_char         => l_value_char1 ,
               p_value_num          => l_value_num1  ,
               p_value_date         => l_value_date1 ,
               p_effective_date     => l_effective_date
               ) ;


            if l_value_char1 is null and l_value_num1 is null and l_value_date1 is null then
              -- RAISE the ERROR a
              null ;
            end if ;

	      hr_utility.set_location('l_info_egc.access_table_name1 '||l_info_egc.access_table_name1,99011);
	      hr_utility.set_location('l_info_egc.access_column_name1 '||l_info_egc.access_column_name1,99011);
	      hr_utility.set_location('l_info_egc.crit_col1_datatype '||l_info_egc.crit_col1_datatype,99011);
	      hr_utility.set_location('l_info_egc.allow_range_validation_flag '||l_info_egc.allow_range_validation_flag,99011);
	      hr_utility.set_location('l_value_char1 '||l_value_char1,99011);
	      hr_utility.set_location('l_value_num1 '||l_value_num1,99011);
	      hr_utility.set_location('l_value_date1 '||l_value_date1,99011);


         if l_info_egc.access_table_name2 is not null then
	            hr_utility.set_location('get the values from the table column SET2',99099);
               get_values_access_table
                 (p_table_name         => l_info_egc.access_table_name2 ,
                  p_column_name        => l_info_egc.access_column_name2,
                  p_data_type_cd       => l_info_egc.crit_col2_datatype ,
                  p_person_id          => p_person_id  ,
                  p_business_group_id  => p_business_group_id,
                  p_value_char         => l_value_char2 ,
                  p_value_num          => l_value_num2  ,
                  p_value_date         => l_value_date2 ,
                  p_effective_date     => p_effective_date
                  ) ;
        end if ; --if l_info_egc.ACCESS_CALC_RULE2
	      hr_utility.set_location('l_info_egc.access_table_name2 '||l_info_egc.access_table_name2,99011);
	      hr_utility.set_location('l_info_egc.access_column_name2 '||l_info_egc.access_column_name2,99011);
	      hr_utility.set_location('l_info_egc.crit_col2_datatype '||l_info_egc.crit_col2_datatype,99011);
         hr_utility.set_location('l_info_egc.allow_range_validation_flag2 '||l_info_egc.allow_range_validation_flag2,99011);
	      hr_utility.set_location('l_value_char2 '||l_value_char2,99011);
	      hr_utility.set_location('l_value_num2 '||l_value_num2,99011);
	      hr_utility.set_location('l_value_date2 '||l_value_date2,99011);

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
      for l in   c_egv(p_dpnt_cvg_eligy_prfl_id ,
                  i.eligy_criteria_dpnt_id)
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


         l_true_false1 := set_true_false
               ( p_crit_col_datatype           => l_info_egc.crit_col1_datatype,
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
         if (l_info_egc.access_column_name2 is not null)then
               l_true_false2 := set_true_false
               ( p_crit_col_datatype            => l_info_egc.crit_col2_datatype,
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

         if not ( l_true_false1 and l_true_false2 ) then
                       l_crit_value_checked := 'N'  ;
         end if;

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

     p_inelig_rsn_cd := 'OTH';
     p_eligible_flag := 'N';

  else
     p_inelig_rsn_cd := null;
     p_eligible_flag := 'Y';
   end if ;

  if g_debug then
     hr_utility.set_location(' Leaving:' || l_proc, 5);
  end if ;
end main ;



end  ben_evl_dpnt_elig_criteria;

/
