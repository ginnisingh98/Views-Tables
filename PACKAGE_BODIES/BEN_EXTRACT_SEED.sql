--------------------------------------------------------
--  DDL for Package Body BEN_EXTRACT_SEED
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_EXTRACT_SEED" AS
/* $Header: benextse.pkb 120.19.12000000.4 2007/02/27 19:44:05 tjesumic noship $ */

g_Ext_adv_crit_cmbn  tbl_Ext_adv_crit_cmbn ;

procedure  delete_crit_adv_conditon
                  (p_ext_crit_prfl_id in number ) is


cursor c1 is
select  ecv.ext_crit_val_id ,
        ecv.object_version_number ,
        ecv.LEGISLATION_CODE
from ben_ext_crit_val ecv ,
     ben_ext_crit_typ ect
where  ect.ext_crit_prfl_id = p_ext_crit_prfl_id
  and  ect.ext_crit_typ_id  = ecv.ext_crit_typ_id
  and  ect.crit_typ_cd      = 'ADV'
  ;



cursor c2 (p_ext_crit_val_id number) is
select ext_crit_cmbn_id ,
       object_version_number ,
       LEGISLATION_CODE
  from ben_ext_crit_cmbn
 where ext_crit_val_id = p_ext_crit_val_id
 ;

 l_proc                   varchar2(100) := 'BEN_EXT_SEED.delete_crit_adv_conditon' ;
 l_object_version_number  number ;

Begin
   hr_utility.set_location(' Entering ' || l_proc, 10);

  for i in c1
  Loop

    for k in  c2(i.ext_crit_val_id)
    Loop
       --- celete adv crit combn values
       BEN_ext_crit_cmbn_API.delete_ext_crit_cmbn
                (p_validate           => FALSE
                ,p_EXT_CRIT_CMBN_ID   => k.EXT_CRIT_CMBN_ID
                ,p_LEGISLATION_CODE   => k.LEGISLATION_CODE
                ,p_OBJECT_VERSION_NUMBER => l_OBJECT_VERSION_NUMBER
                ,p_effective_date => trunc(sysdate)
                );

    End Loop ;
    --- delete  the criteria  values
    BEN_ext_crit_val_API.delete_ext_crit_val
            (p_validate           => FALSE
            ,p_EXT_CRIT_VAL_ID    => I.EXT_CRIT_VAL_ID
            ,p_LEGISLATION_CODE   => I.LEGISLATION_CODE
            ,p_OBJECT_VERSION_NUMBER => l_OBJECT_VERSION_NUMBER
          );

  end Loop ;

  --- delete the global collection
  g_Ext_adv_crit_cmbn.delete ;
   hr_utility.set_location(' Leaving ' || l_proc, 10);
end ;


procedure  set_adv_cond_cmbn
                  ( p_old_ext_crit_val_id   in number ,
                    p_new_ext_crit_val_id   in number ) is

  l_count  number      ;
  l_found  varchar2(1) ;
  l_proc                   varchar2(100) := 'BEN_EXT_SEED.set_adv_cond_cmbn' ;
Begin
   hr_utility.set_location(' Entering ' || l_proc, 10);

  l_found := 'N' ;
  l_count := 0   ;
  if p_old_ext_crit_val_id is not null and p_new_ext_crit_val_id is not null then
     l_count := g_Ext_adv_crit_cmbn.count ;
     for  i in 1 .. l_count
     Loop
        if g_Ext_adv_crit_cmbn(i).old_crit_val_id  =  p_old_ext_crit_val_id then
           l_found := 'Y' ;
           exit ;
        end if ;
     End loop ;

     if l_found = 'N'  then
        g_Ext_adv_crit_cmbn(nvl(l_count,0) + 1 ).old_crit_val_id  :=  p_old_ext_crit_val_id  ;
        g_Ext_adv_crit_cmbn(nvl(l_count,0) + 1 ).new_crit_val_id  :=  p_new_ext_crit_val_id  ;
     end if ;
  end if ;

End ;



function get_adv_cond_cmbn ( p_old_ext_crit_val_id   in number )
                    return  number  is
  l_count       number ;
  l_return_val  number ;
Begin

  l_count := g_Ext_adv_crit_cmbn.count ;
  for  i in 1 .. l_count
  Loop
     if g_Ext_adv_crit_cmbn(i).old_crit_val_id  =  p_old_ext_crit_val_id then
        l_return_val  :=  g_Ext_adv_crit_cmbn(i).new_crit_val_id  ;
        exit ;
     end if ;
  End loop ;
  Return l_return_val ;

End ;



PROCEDURE write_err
    (p_err_num                        in  varchar2    default null,
     p_err_msg                        in  varchar2  default null,
     p_typ_cd                         in  varchar2  default null,
     p_business_group_id              in  number    default null
     ) is

l_string  varchar2(50) ;

Begin

 if p_typ_cd  = 'E' then
    g_errors_count :=  g_errors_count + 1 ;
    l_string := '     ERROR : '  ;
 else
    l_string := '     WARNING : '  ;
 end if ;

 if g_business_group_id is not null and  fnd_global.conc_request_id <> -1  then
    if p_err_msg is not null then
       fnd_file.put_line(fnd_file.log,l_string ||  p_err_msg);
    elsif p_err_num is not null then
        fnd_message.set_name(substr(p_err_num,1,3),p_err_num);
    end if ;
 end if ;


 if g_errors_count > g_max_errors_allowed then
    fnd_message.set_name('BEN','BEN_91947_EXT_MX_ERR_NUM');
    fnd_file.put_line(fnd_file.log, fnd_message.get);
    fnd_message.raise_error;
 end if ;

End write_err ;


PROCEDURE validate_data(validate IN VARCHAR2 DEFAULT null  )
         is
Begin
      if nvl(validate,'N') = 'Y'  then
         g_file_count :=  g_file_count + 1 ;
         if g_file_count >= g_total_file then
            ROLLBACK TO SUBMIT_EXIM_REQUEST;
            g_file_count := 0 ;
         end if ;
      end if ;
end validate_data ;


Procedure  load_business_group(p_owner            IN VARCHAR2
                               ,p_legislation_code IN VARCHAR2
                               ,p_business_group   in VARCHAR2
                               ,p_totalcount       in VARCHAR2 default null
                               ,p_allow_override   in VARCHAR2 default null
                              ) is

 l_threads                   number;
 l_chunk_size                number;

Begin
    g_business_group_id  := null ;
    if p_business_group is not null then
      begin
        select business_group_id
          into  g_business_group_id
        from per_business_groups_perf
        where name = p_business_group ;
      exception
       when no_data_found then
          raise ;
      end  ;
    end if ;
    --- validating  the businesss group id with  type of extract
    if  p_owner  = 'CUSTOM'  then
        -- if the extract is custom and and business group_id not provided  error
        if  g_business_group_id is null  then
             fnd_message.set_name('BEN','BEN_91000_INVALID_BUS_GROUP');
             fnd_message.raise_error;
        end if ;
    else
       if g_business_group_id is not null then
          fnd_message.set_name('BEN','BEN_93200_PDC_INVALID_BG_ER');
          fnd_message.raise_error;
       end if ;
    end if ;

    if g_business_group_id is not null and  fnd_global.conc_request_id <> -1  then
       benutils.get_parameter
         (p_business_group_id => g_business_group_id
              ,p_batch_exe_cd => 'BENXEXP'
              ,p_threads      => l_threads
              ,p_chunk_size   => l_chunk_size
              ,p_max_errors   => g_max_errors_allowed);
    end if ;
    g_errors_count := 0 ;
    if p_totalcount is not null then
      g_total_file :=  to_number(p_totalcount)  ;
    end if ;
    g_override  := nvl(p_allow_override,'N') ;
    savepoint SUBMIT_EXIM_REQUEST;
End  load_business_group ;


-----------------------------------------------------
--- This function is added to get the lookup code
--- so far the ldt extract the name that is creating a issue when the lookup meaning are changed
--- this  function also allow to extract the lookup code , the criteria is from hr lookups
-- if the criteria from master tables like person name then return null for the code
------------------------------------------------------

Function  get_lookup_code  (p_crit_typ_cd in VARCHAR2
                   ,p_val         in VARCHAR2
                   ,p_val_order   IN VARCHAR2
                   ,p_bg_group_id IN NUMBER  default null
                  )return varchar2 is



cursor find_lookup ( p_lookup_type in varchar2) is
select 'x' from hr_lookups
where  lookup_type = p_lookup_type
and    lookup_code = p_val
;

l_return_val  varchar2(30) ;
l_dummy       varchar2(1) ;
l_lookup_type hr_lookups.lookup_type%type ;

Begin


  if p_crit_typ_cd = 'PST' then
     l_lookup_type := 'US_STATE' ;

   elsif p_crit_typ_cd in ('BECLES', 'BERLES')  then

     l_lookup_type := 'BEN_PER_IN_LER_STAT' ;

   elsif p_crit_typ_cd = 'BSE'  then

     l_lookup_type := 'BEN_EXT_SUSPEND' ;

   elsif p_crit_typ_cd in ('BECMIS', 'BERMIS','BACMIS')  then

     l_lookup_type := 'BEN_EXT_CRIT_MISC' ;

   --elsif   then

   --  l_lookup_type := 'BEN_ENRT_RSLT_MTHD' ;

   elsif p_crit_typ_cd = 'BERSTA'  then

     l_lookup_type := 'BEN_PRTT_ENRT_RSLT_STAT' ;

   elsif p_crit_typ_cd in ('BDTOR' , 'PASOR' , 'BECESD', 'BECLUD','BECLND', 'BECLED', 'BERCSD','BERCDP','BERLUD',
                           'BERLND', 'BERLOD' , 'MTBSDT', 'MPCLUD', 'MPCPLUD', 'MSDT', 'CAD', 'CED','RPPEDT' ,
                           'EPMNYR','EPLDT' )   then

     l_lookup_type := 'BEN_EXT_DT' ;

   elsif  p_crit_typ_cd in ('CCE'  )    then

     l_lookup_type := 'BEN_EXT_CHG_EVT' ;

   --elsif   then

    -- l_lookup_type := 'BEN_EXT_TTL_COND_OPER' ;

   elsif   p_crit_typ_cd = 'PASU'  then

     l_lookup_type := 'BEN_EXT_ASMT_TO_USE' ;

   elsif p_crit_typ_cd = 'BERENM'  then

     l_lookup_type := 'BEN_ENRT_MTHD' ;

   elsif  p_crit_typ_cd = 'PDL'  then

     l_lookup_type := 'BEN_EXT_PER_DATA_LINK' ;



   End if ;


   if l_lookup_type is not null then
      open  find_lookup(l_lookup_type) ;
      fetch  find_lookup into l_dummy ;
      if  find_lookup%found then
          l_return_val := p_val ;
      end if ;
      close find_lookup ;
   end if ;



   Return l_return_val ;
End ;



FUNCTION get_value (p_crit_typ_cd in VARCHAR2
                   ,p_val         in VARCHAR2
                   ,p_val_order   IN VARCHAR2
                   ,p_bg_group_id IN NUMBER  default null
                  )return varchar2 is
  l_crit_typ_cd    varchar2(30);
  l_oper_cd        varchar2(30);
  l_val1           varchar2(200);
  p_business_group_id  number := p_bg_group_id ;
  p_legislation_code   varchar2(240); --utf8
  l_val2           varchar2(200);
  l_crit_cmbn      varchar2(2000) := '';
  --value      varchar2(80) := '';   UTF8IK
  value      varchar2(240) :=  '';
cursor c1 is select meaning
             from   hr_lookups
             where  lookup_type = 'US_STATE'
             and    lookup_code = p_val;


cursor c2 is select  name
                from  ben_benfts_grp
                where benfts_grp_id = p_val;

cursor c3 is SELECT user_status from PER_ASSIGNMENT_STATUS_TYPES
            WHERE active_flag ='Y'
            and assignment_status_type_id = p_val;

cursor c4 is SELECT name from PER_ORGANIZATION_UNITS
            WHERE internal_external_flag = 'INT'
            and organization_id = p_val;

cursor c5 is select location_code from hr_locations
        where trunc(sysdate) <=
        nvl(inactive_date,to_date('31124712','DDMMYYYY'))
        and location_id = p_val;

cursor c6 is SELECT name from hr_tax_units_v
            WHERE nvl(business_group_id,nvl(p_business_group_id,-1))
                   = nvl(p_business_group_id,-1)
            and trunc(sysdate)
         between nvl(date_from,trunc(sysdate))
         and nvl(date_to,trunc(sysdate))
         and tax_unit_id = p_val;

cursor c7 is SELECT full_name||'   '||national_identifier
           ||'   '||employee_number from per_all_people_f
            WHERE nvl(business_group_id,nvl(p_business_group_id,-1))
                   = nvl(p_business_group_id,-1)
            and trunc(sysdate)
         between nvl(effective_start_date,trunc(sysdate))
         and nvl(effective_end_date,trunc(sysdate))
         and person_id = p_val;



cursor c8 is select  formula_name
             from    ff_formulas_f
             where   --nvl(legislation_code,nvl(p_legislation_code,'~~nvl~~'))
--                      = nvl(p_legislation_code,'~~nvl~~')
--             and     nvl(business_group_id,nvl(p_business_group_id,-1))
--                      = nvl(p_business_group_id,-1) and
                  trunc(sysdate) between effective_start_date
                     and effective_end_date
             and     formula_id = p_val;

cursor c9 is select  name
             from    ben_ler_f
             where   nvl(business_group_id,nvl(p_business_group_id,-1))
                      = nvl(p_business_group_id,-1)
             and     trunc(sysdate) between effective_start_date
                     and effective_end_date
             and     ler_id = p_val;

cursor c10 is select  user_person_type
              from    per_person_types
              where   nvl(business_group_id,nvl(p_business_group_id,-1))
                       = nvl(p_business_group_id,-1)
              and     active_flag = 'Y'
              and     person_type_id = p_val;

cursor ca is SELECT name from ben_cm_typ_f
            WHERE   nvl(business_group_id,nvl(p_business_group_id,-1))
                   = nvl(p_business_group_id,-1)
                and cm_typ_id = p_val;


cursor cb is SELECT payroll_name from pay_all_payrolls_f
          WHERE   nvl(business_group_id,nvl(p_business_group_id,-1))
                   = nvl(p_business_group_id,-1)
            and trunc(sysdate)
         between nvl(effective_start_date,trunc(sysdate))
         and nvl(effective_end_date,trunc(sysdate))
         and payroll_id = p_val;


cursor cc is SELECT element_name from pay_element_types_f
              WHERE   nvl(business_group_id,nvl(p_business_group_id,-1))
                   = nvl(p_business_group_id,-1)
             and element_type_id = p_val;


cursor cd is SELECT name from pay_input_values_f
             WHERE   nvl(business_group_id,nvl(p_business_group_id,-1))
                   = nvl(p_business_group_id,-1)
             and input_value_id = p_val;


cursor ce is select  name
             from    ben_pl_f
             where   business_group_id = p_business_group_id
             and     trunc(sysdate) between nvl(effective_start_date,trunc(sysdate))
                                    and nvl(effective_end_date,trunc(sysdate))
             and     pl_id = p_val;
/*
cursor cf is select  name
             from    ben_rptg_grp_v
               WHERE   nvl(business_group_id,nvl(p_business_group_id,-1))
                   = nvl(p_business_group_id,-1)
             and     rptg_grp_id = p_val;
*/

cursor cf is select meaning
             from   hr_lookups
             where  lookup_type = 'BEN_PER_IN_LER_STAT'
             and    lookup_code = p_val;


cursor cg is select meaning
             from   hr_lookups
             where  lookup_type = 'BEN_EXT_SUSPEND'
             and    lookup_code = p_val;

cursor ch is select  name
             from    ben_ler_v
             where   business_group_id = p_business_group_id
             and    trunc(sysdate) between nvl(effective_start_date,trunc(sysdate))
                                and nvl(effective_end_date,trunc(sysdate))
             and     ler_id = p_val;


cursor ci is select  name
             from    ben_pgm_f
             where   business_group_id = p_business_group_id
             and     trunc(sysdate) between nvl(effective_start_date,trunc(sysdate))
                             and nvl(effective_end_date,trunc(sysdate))
             and     pgm_id = p_val;


cursor cj is select  name
             from    ben_pl_f
             where   business_group_id = p_business_group_id
             and     trunc(sysdate) between nvl(effective_start_date,trunc(sysdate))
                             and nvl(effective_end_date,trunc(sysdate))
             and     pl_id = p_val;

cursor ck is select  name
             from    ben_rptg_grp_v
             where   business_group_id = p_business_group_id
             and     rptg_grp_id = p_val;


cursor cl is select meaning
             from   hr_lookups
             where  lookup_type = 'BEN_EXT_CRIT_MISC'
             and    lookup_code = p_val;


cursor cm is select  name
             from    ben_pl_typ_f
             where   business_group_id = p_business_group_id
             and     trunc(sysdate) between nvl(effective_start_date,trunc(sysdate))
                             and nvl(effective_end_date,trunc(sysdate))
             and     pl_typ_id = p_val;


cursor cn is select  start_date||' - '||end_date
              from    ben_yr_perd
              where   business_group_id = p_business_group_id
              and     yr_perd_id = p_val;

cursor co is select meaning
              from   hr_lookups
              where  lookup_type = 'BEN_EXT_CRIT_MISC'
              and    lookup_code = p_val;

cursor cp is select meaning
              from   hr_lookups
              where  lookup_type = 'BEN_EXT_SUSPEND'
              and    lookup_code = p_val;

cursor cq is select meaning
             from   hr_lookups
             where  lookup_type = 'BEN_ENRT_RSLT_MTHD'
             and    lookup_code = p_val;

cursor cr is select meaning
             from   hr_lookups
             where  lookup_type = 'BEN_PRTT_ENRT_RSLT_STAT'
             and    lookup_code = p_val;

cursor cs is select meaning
             from   hr_lookups
             where  lookup_type = 'BEN_EXT_DT'
             and    lookup_code = p_val;

cursor ct is select  name
             from    ben_actn_typ
             where   actn_typ_id = p_val ;


cursor cu is select meaning
             from   hr_lookups
             where  lookup_type = 'BEN_EXT_DT'
             and    lookup_code = p_val
             and    trunc(sysdate) between nvl(start_date_active, trunc(sysdate))
                                 and nvl(end_date_active, trunc(sysdate))
             ;



cursor cv is select meaning
             from   hr_lookups
             where  lookup_type = 'BEN_EXT_DT'
             and    lookup_code = p_val
             and    trunc(sysdate) between nvl(start_date_active, trunc(sysdate))
                                 and nvl(end_date_active, trunc(sysdate))
             ;

cursor cw is select meaning
             from   hr_lookups
             where  lookup_type = 'BEN_EXT_CHG_EVT'
             and    lookup_code = p_val
             and    trunc(sysdate) between nvl(start_date_active, trunc(sysdate))
                                 and nvl(end_date_active, trunc(sysdate))  ;

cursor cep is select event_group_name
         from  pay_event_groups
         where  event_group_id =  p_val
        ;

cursor cx is select user_name
             from   fnd_user
             where  user_id = p_val
             and    trunc(sysdate) between nvl(start_date, trunc(sysdate))
                                 and nvl(end_date, trunc(sysdate));

cursor cy is select meaning
             from   hr_lookups
             where  lookup_type = 'BEN_EXT_DT'
             and    lookup_code = p_val
             and    trunc(sysdate) between nvl(start_date_active, trunc(sysdate))
                                 and nvl(end_date_active, trunc(sysdate))
            ;

cursor cz is select meaning
             from   hr_lookups
             where  lookup_type = 'BEN_EXT_DT'
             and    lookup_code = p_val
             and    trunc(sysdate) between nvl(start_date_active, trunc(sysdate))
                                 and nvl(end_date_active, trunc(sysdate))
             ;

cursor caa is select meaning
             from   hr_lookups
             where  lookup_type = 'BEN_EXT_DT'
             and    lookup_code = p_val
             and    trunc(sysdate) between nvl(start_date_active, trunc(sysdate))
                                 and nvl(end_date_active, trunc(sysdate))
             ;

cursor cab is select meaning
             from   hr_lookups
             where  lookup_type = 'BEN_EXT_DT'
             and    lookup_code = p_val
             and    trunc(sysdate) between nvl(start_date_active, trunc(sysdate))
                                 and nvl(end_date_active, trunc(sysdate))
             ;

cursor cac is select meaning
             from   hr_lookups
             where  lookup_type = 'BEN_EXT_DT'
             and    lookup_code = p_val
             and    trunc(sysdate) between nvl(start_date_active, trunc(sysdate))
                                 and nvl(end_date_active, trunc(sysdate))
             ;

cursor cad is select meaning
             from   hr_lookups
             where  lookup_type = 'BEN_EXT_DT'
             and    lookup_code = p_val
             and    trunc(sysdate) between nvl(start_date_active, trunc(sysdate))
                                 and nvl(end_date_active, trunc(sysdate))
             ;

cursor cae is select meaning
             from   hr_lookups
             where  lookup_type = 'BEN_EXT_DT'
             and    lookup_code = p_val
             and    trunc(sysdate) between nvl(start_date_active, trunc(sysdate))
                                 and nvl(end_date_active, trunc(sysdate))
             ;

cursor caf is select meaning
             from   hr_lookups
             where  lookup_type = 'BEN_EXT_DT'
             and    lookup_code = p_val
             and    trunc(sysdate) between nvl(start_date_active, trunc(sysdate))
                                 and nvl(end_date_active, trunc(sysdate))
             ;

cursor cag is select meaning
             from   hr_lookups
             where  lookup_type = 'BEN_EXT_DT'
             and    lookup_code = p_val
             and    trunc(sysdate) between nvl(start_date_active, trunc(sysdate))
                                 and nvl(end_date_active, trunc(sysdate))
             ;


cursor cah is select meaning
             from   hr_lookups
             where  lookup_type = 'BEN_EXT_DT'
             and    lookup_code = p_val
             and    trunc(sysdate) between nvl(start_date_active, trunc(sysdate))
                                 and nvl(end_date_active, trunc(sysdate))
             ;


  cursor c_val1_dt
  is
  select meaning
  from   hr_lookups
  where  lookup_type = 'BEN_EXT_DT'
  and    lookup_code = p_val;

  cursor c_val2_dt
  is
  select meaning
  from   hr_lookups
  where  lookup_type = 'BEN_EXT_DT'
  and    lookup_code = p_val;

  cursor c_val1_chg_evt
  is
  select meaning
  from   hr_lookups
  where  lookup_type = 'BEN_EXT_CHG_EVT'
  and    lookup_code = p_val;

  cursor c_val2_chg_evt
  is
  select meaning
  from   hr_lookups
  where  lookup_type = 'BEN_EXT_CHG_EVT'
  and    lookup_code = p_val;

  cursor c_oper
  is
  select meaning
  from   hr_lookups
  where  lookup_type = 'BEN_EXT_TTL_COND_OPER'
  and    lookup_code = p_val; --p_oper_cd;


  cursor c_pasu
    is
    select meaning
    from   hr_lookups
    where  lookup_type = 'BEN_EXT_ASMT_TO_USE'
    and    lookup_code = p_val;  --  value for the criteria Person Assignment To Use

    CURSOR Cai IS
      select MEANING
      from   HR_LOOKUPS
      where  LOOKUP_CODE = p_crit_typ_cd
      and    lookup_type = 'BEN_EXT_CRIT_TYP'
      and    substr(lookup_code, 1, 1) = 'C'
      and    lookup_code not in ('CBU')
      and    trunc(sysdate) between
             nvl(start_date_active, trunc(sysdate))
      and    nvl(end_date_active, trunc(sysdate))
      ;

    cursor c_berenm
    is
    select meaning
    from   hr_lookups
    where  lookup_type = 'BEN_ENRT_MTHD'
    and    lookup_code = p_val;  --  value for the criteria Enrollment method


    cursor c_enb is
    select  to_char(enp.strt_dt, 'DD-MON-RRRR') || ' - ' || to_char( enp.end_dt, 'DD-MON-RRRR')
    from  ben_enrt_perd enp
    where ENRT_PERD_ID = p_val
   ;


   cursor c_lookup(p_type varchar2)  is
   select meaning
    from   hr_lookups
    where  lookup_type = p_type
    and    lookup_code = p_val;  --

  cursor c_job is
  select name
  from  per_jobs_vl job
  where job_id =   p_val;

  cursor c_bg is
  select name
  from  per_business_groups_perf
  where business_group_id =   p_val;

 cursor c_pos is
  select name
  from   HR_ALL_POSITIONS_F  job
  where position_id =  p_val
  and trunc(sysdate) between
      EFFECTIVE_START_DATE
      and   EFFECTIVE_END_DATE ;

 cursor c_asgset  is
 select ASSIGNMENT_SET_NAME from
 hr_assignment_sets
 where ASSIGNMENT_SET_ID = p_val
 ;

  BEGIN
     --
     if p_crit_typ_cd = 'PST' then
        open c1;
        fetch c1 into value;
        close c1;
     elsif p_crit_typ_cd = 'PBG' then
        open c2;
        fetch c2 into value;
        close c2;
   elsif p_crit_typ_cd = 'PAS' then
        open c3;
        fetch c3 into value;
        close c3;

   elsif p_crit_typ_cd = 'POR' then
        open c4;
        fetch c4 into value;
        close c4;
   elsif p_crit_typ_cd = 'PLO' then
        open c5;
        fetch c5 into value;
        close c5;
   elsif p_crit_typ_cd = 'PLE' then
        open c6;
        fetch c6 into value;
        close c6;
   elsif p_crit_typ_cd = 'PID' then
        open c7;
        fetch c7 into value;
        close c7;
   elsif p_crit_typ_cd = 'PRL' then
        open c8;
        fetch c8 into value;
        close c8;
   elsif p_crit_typ_cd = 'PLV' then
        open c9;
        fetch c9 into value;
        close c9;
   elsif p_crit_typ_cd = 'PPT' then
        open c10;
        fetch c10 into value;
        close c10;
   elsif p_crit_typ_cd = 'MTP' then
        open ca;
        fetch ca into value;
        close ca;
   elsif p_crit_typ_cd = 'RRL' then
        open cb;
        fetch cb into value;
        close cb;
   elsif p_crit_typ_cd = 'REE'  and p_val_order = 'VAL_2'then
        open cc;
        fetch cc into value;
        close cc;
   elsif p_crit_typ_cd = 'REE'  and p_val_order = 'VAL_1'then
        open cd;
        fetch cd into value;
        close cd;
  elsif p_crit_typ_cd in ('BECLEN', 'BERLEN') then
       open c9;
       fetch c9 into value;
       close c9;

  elsif p_crit_typ_cd in ('BECLES', 'BERLES') then
       open cf;
       fetch cf into value;
       close cf;

  elsif p_crit_typ_cd in ('BECPLN', 'BPL') then
       open ce;
       fetch ce into value;
       close ce;

  elsif p_crit_typ_cd in ('BECRPG', 'BRG') then
       open ck;
       fetch ck into value;
       close ck;

  elsif p_crit_typ_cd in ('BECPGN', 'BERPGN') then
       open ci;
       fetch ci into value;
       close ci;

  elsif p_crit_typ_cd in ('BECPTN', 'BERPTN') then
       open cm;
       fetch cm into value;
       close cm;

  elsif p_crit_typ_cd = 'BECYRP' then
       open cn;
       fetch cn into value;
       close cn;

  elsif p_crit_typ_cd in ('BECMIS', 'BERMIS','BACMIS') then
       open cl;
       fetch cl into value;
       close cl;


  elsif p_crit_typ_cd = 'BSE' then
       open cg;
       fetch cg into value;
       close cg;

  elsif p_crit_typ_cd = 'BERENM' then
       open c_berenm;
       fetch c_berenm into value;
       close c_berenm;

  elsif p_crit_typ_cd = 'BERSTA' then
       open cr;
       fetch cr into value;
       close cr;

/*  elsif p_crit_typ_cd in ('BECESD', 'BECLUD','BECLND', 'BECLED', 'BERCSD', 'BERCDP', 'BERLUD',
                           'BERLND', 'BERLOD')  then
       open cp;
       fetch cp into value;
       if cp%notfound then
         value := p_val;
       end if;
       close cp;
*/
  elsif p_crit_typ_cd = 'BACN' then
       open ct;
        fetch ct into value;
       close ct;
  elsif p_crit_typ_cd in ('BDTOR')      then
       open cu;
       fetch cu into value;
       if cu%notfound then
         value := p_val;
       end if;
       close cu;
  elsif p_crit_typ_cd in ('PASOR')      then
       open cv;
       fetch cv into value;
       if cv%notfound then
         value := p_val;
       end if;
       close cv;
  elsif p_crit_typ_cd = 'CCE' then
       open cw;
       fetch cw into value;
       close cw;
--  elsif p_crit_typ_cd = 'CEP'  and p_val_order = 'VAL_2'  then
  elsif p_crit_typ_cd = 'CPE'  and p_val_order = 'VAL_2'  then -- anshghos
        value := P_VAL ;
--  elsif p_crit_typ_cd = 'CEP'  and p_val_order = 'VAL_1'  then
  elsif p_crit_typ_cd = 'CPE'  and p_val_order = 'VAL_1'  then -- anshghos
       open CEP;
       fetch CEP into value;
       close CEP;

  elsif p_crit_typ_cd = 'CBU' then
    open cx;
    fetch cx into value;
    close cx;
  elsif p_crit_typ_cd in ('BECESD', 'BECLUD','BECLND', 'BECLED', 'BERCSD','BERCDP','BERLUD',
                           'BERLND', 'BERLOD')  then
    open cy;
    fetch cy into value;
    if cy%notfound then
      value := p_val;
    end if;
    close cy;
 /*
  elsif p_crit_typ_cd in ('BECESD', 'BECLUD','BECLND', 'BECLED', 'BERCSD', 'BERCDP', 'BERLUD',
                           'BERLND', 'BERLOD')  then
    open cz;
    fetch cz into value;
    if cz%notfound then
      value := p_val;
    end if;
    close cz;
 */
  elsif p_crit_typ_cd in ('MTBSDT', 'MPCLUD', 'MPCPLUD', 'MSDT')        then
    open caa;
    fetch caa into value;
    if caa%notfound then
      value := p_val;
    end if;
    close caa;
  elsif p_crit_typ_cd in ('MTBSDT', 'MPCLUD', 'MPCPLUD', 'MSDT') then
    open cab;
    fetch cab into value;
    if cab%notfound then
      value := p_val;
    end if;
    close cab;
  elsif p_crit_typ_cd in ('CAD', 'CED') then
    open cac;
    fetch cac into value;
    if cac%notfound then
      value := p_val;
    end if;
    close cac;
  elsif p_crit_typ_cd in ('CAD', 'CED') then
    open cad;
    fetch cad into value;
    if cad%notfound then
      value := p_val;
    end if;
    close cad;
  elsif p_crit_typ_cd is not null and p_crit_typ_cd = 'RPPEDT' then
    open cag;
    fetch cag into value;
    if cag%notfound then
      value := p_val;
    end if;
    close cag;
  elsif p_crit_typ_cd is not null and p_crit_typ_cd = 'RPPEDT' then
    open cah;
    fetch cah into value;
    if cah%notfound then
      value := p_val;
    end if;
    close cah;


  elsif p_crit_typ_cd  in ( 'CAD','CED','EPMNYR','EPLDT' )  then
    open c_val1_dt;
    fetch c_val1_dt into value;
    close c_val1_dt;
 /*
    open c_val2_dt;
    fetch c_val2_dt into value;
    close c_val2_dt;
 */
  elsif p_crit_typ_cd = 'CCE' then
    open c_val1_chg_evt;
    fetch c_val1_chg_evt into value;
    close c_val1_chg_evt;
    open c_val2_chg_evt;
    fetch c_val2_chg_evt into value;
    close c_val2_chg_evt;

  elsif p_crit_typ_cd = 'PASU' then
    open c_pasu;
    fetch c_pasu into value;
    close c_pasu;

  elsif p_crit_typ_cd = 'HRL' then
        open c8;
        fetch c8 into value;
        close c8;
 elsif p_crit_typ_cd = 'RFFRL' then
        open c8;
        fetch c8 into value;
        close c8;

  elsif p_crit_typ_cd = 'WPLPR'  and p_val_order = 'VAL_2'then
        -- plan
        open cj;
        fetch cj into value;
        close cj;
   elsif p_crit_typ_cd = 'WPLPR'  and p_val_order = 'VAL_1'then
        -- plan enrollment period
        open c_enb;
        fetch c_enb into value;
        close c_enb;

  elsif p_crit_typ_cd = 'PDL' then
        Open c_lookup('BEN_EXT_PER_DATA_LINK') ;
        fetch c_lookup into value;
        close c_lookup;

  elsif p_crit_typ_cd = 'HJOB' then
        open c_job;
        fetch c_job into value;
        close c_job;
  elsif p_crit_typ_cd = 'HORG' then
        open c4;
        fetch c4 into value;
        close c4;
  elsif p_crit_typ_cd = 'HPOS' then
        open c_pos;
        fetch c_pos into value;
        close c_pos;
  elsif p_crit_typ_cd = 'HPY' then
        open cb;
        fetch cb into value;
        close cb;
  elsif p_crit_typ_cd = 'HLOC' then
        open c5;
        fetch c5 into value;
        close c5;
  elsif p_crit_typ_cd = 'HBG' then
        open c_bg;
        fetch c_bg into value;
        close c_bg;
  elsif p_crit_typ_cd = 'PBGR' then
        open c_bg;
        fetch c_bg into value;
        close c_bg;
  elsif p_crit_typ_cd = 'PASGSET' then

       open c_asgset ;
       fetch c_asgset into value ;
       close  c_asgset ;

  else
     value :=  p_val ;

  end if;



   /* OPEN Cai;
    FETCH Cai into value;
    CLOSE Cai;
   */
return value;
end;


function decode_value (p_crit_typ_cd in VARCHAR2,
                  p_meaning in VARCHAR2
                  ,p_val_order IN VARCHAR2
                  ,p_parent_meaning IN VARCHAR2
                  )return varchar2 is
  l_crit_typ_cd    varchar2(30);
  l_oper_cd        varchar2(30);
  l_val1           varchar2(200);
  p_business_group_id  number :=  g_business_group_id ;
  p_legislation_code  varchar2(240); --utf8
  p_val_1           varchar2(200);
  p_val_2           varchar2(200);
  l_val2           varchar2(200);
  l_crit_cmbn      varchar2(2000) := '';
  -- value      varchar2(80) := '';  UTF8IK
  value      varchar2(600):= '';

cursor c1 is select lookup_code
             from   hr_lookups
             where  lookup_type = 'US_STATE'
             and    meaning = p_meaning
             and    trunc(sysdate) between nvl(start_date_active, trunc(sysdate))
                                 and     nvl(end_date_active, trunc(sysdate))
             ;


cursor c2 is select benfts_grp_id
                from    ben_benfts_grp
                where nvl(business_group_id,nvl(p_business_group_id,-1))
                       = nvl(p_business_group_id,-1)
                  and name  = p_meaning;

cursor c3 is SELECT  assignment_status_type_id
             from PER_ASSIGNMENT_STATUS_TYPES
            WHERE
             --    nvl(legislation_code,nvl(p_legislation_code,'~~nvl~~'))
             --    = nvl(p_legislation_code,'~~nvl~~') and
            nvl(business_group_id,nvl(p_business_group_id,-1))
                    = nvl(p_business_group_id,-1)
            and active_flag ='Y'
            and user_status  = p_meaning;

cursor c4 is SELECT organization_id  from PER_ORGANIZATION_UNITS
            WHERE nvl(business_group_id,nvl(p_business_group_id,-1))
                    = nvl(p_business_group_id,-1)
            and trunc(sysdate)
                    between nvl(date_from,trunc(sysdate))
                     and nvl(date_to,trunc(sysdate))
            and internal_external_flag = 'INT'
            and name  = p_meaning;

cursor c5 is select location_id from hr_locations
        where trunc(sysdate) <=
        nvl(inactive_date,to_date('31124712','DDMMYYYY'))
        and location_code  = p_meaning ;

cursor c6 is SELECT tax_unit_id  from hr_tax_units_v
            WHERE nvl(business_group_id,nvl(p_business_group_id,-1))
                   = nvl(p_business_group_id,-1)
            and trunc(sysdate)
         between nvl(date_from,trunc(sysdate))
         and nvl(date_to,trunc(sysdate))
         and name  = p_meaning ;

cursor c7 is  SELECT person_id
            from per_all_people_f
            WHERE nvl(business_group_id,nvl(p_business_group_id,-1))
                   = nvl(p_business_group_id,-1)
            and trunc(sysdate)
         between nvl(effective_start_date,trunc(sysdate))
         and nvl(effective_end_date,trunc(sysdate))
         and   full_name||'   '||national_identifier||'   '||employee_number  = p_meaning
         and  full_name like SUBSTR(p_meaning,1, INSTR(p_meaning,'   ')-1)||'%'; -- 4300295. Perf fix.

cursor c8 is select  formula_id --formula_name
             from    ff_formulas_f
             where   --nvl(legislation_code,nvl(p_legislation_code,'~~nvl~~'))
--                      = nvl(p_legislation_code,'~~nvl~~')
--             and     nvl(business_group_id,nvl(p_business_group_id,-1))
--                      = nvl(p_business_group_id,-1) and
                  trunc(sysdate) between effective_start_date
                     and effective_end_date
             and     formula_name = p_meaning;
cursor c9 is select  ler_id
             from    ben_ler_f
             where   nvl(business_group_id,nvl(p_business_group_id,-1))
                      = nvl(p_business_group_id,-1)
             and     trunc(sysdate) between effective_start_date
                     and effective_end_date
             and     name = p_meaning;

cursor c10 is select  person_type_id
              from    per_person_types
              where   nvl(business_group_id,nvl(p_business_group_id,-1))
                       = nvl(p_business_group_id,-1)
              and     active_flag = 'Y'
              and     user_person_type = p_meaning;

cursor ca is SELECT cm_typ_id from ben_cm_typ_f
            WHERE nvl(business_group_id ,nvl(p_business_group_id,-1))
                = nvl(p_business_group_id,-1)
                and name = p_meaning ;


cursor cb is SELECT payroll_id from pay_all_payrolls_f
            WHERE nvl(business_group_id ,nvl(p_business_group_id,-1))
                = nvl(p_business_group_id,-1)
            and trunc(sysdate)
         between nvl(effective_start_date,trunc(sysdate))
         and nvl(effective_end_date,trunc(sysdate))
         and payroll_name  = p_meaning;


cursor cc is SELECT element_type_id from pay_element_types_f
            WHERE   nvl(business_group_id ,nvl(p_business_group_id,-1))
                = nvl(p_business_group_id,-1)
              and  element_name = p_meaning;


cursor cd is SELECT input_value_id from pay_input_values_f
            WHERE  nvl(business_group_id ,nvl(p_business_group_id,-1))
                = nvl(p_business_group_id,-1)
            and name = p_meaning
            and element_type_id = (SELECT element_type_id from pay_element_types_f
            WHERE nvl(business_group_id ,nvl(p_business_group_id,-1))
                  = nvl(p_business_group_id,-1)
              and element_name = p_parent_meaning);


cursor ce is select  pl_id
             from    ben_pl_f
             where   business_group_id = p_business_group_id
             and     trunc(sysdate) between nvl(effective_start_date,trunc(sysdate))
                                    and nvl(effective_end_date,trunc(sysdate))
             and     name = p_meaning ;
/*
cursor cf is select  name
             from    ben_rptg_grp_v
             where   business_group_id = p_business_group_id
             and     rptg_grp_id = p_val_1;
*/

cursor cf is select lookup_code
             from   hr_lookups
             where  lookup_type = 'BEN_PER_IN_LER_STAT'
             and    meaning = p_meaning;

cursor cg is select lookup_code
             from   hr_lookups
             where  lookup_type = 'BEN_EXT_SUSPEND'
             and    meaning = p_meaning;

cursor ch is select  name
             from    ben_ler_v
             where   business_group_id = p_business_group_id
             and    trunc(sysdate) between nvl(effective_start_date,trunc(sysdate))
                                and nvl(effective_end_date,trunc(sysdate))
             and     ler_id = p_val_1;


cursor ci is select  pgm_id
             from    ben_pgm_f
             where   business_group_id = p_business_group_id
             and     trunc(sysdate) between nvl(effective_start_date,trunc(sysdate))
                             and nvl(effective_end_date,trunc(sysdate))
             and     name  = p_meaning ;


cursor cj is select  pl_id
             from    ben_pl_f
             where   business_group_id = p_business_group_id
             and     trunc(sysdate) between nvl(effective_start_date,trunc(sysdate))
                             and nvl(effective_end_date,trunc(sysdate))
             and     name  = p_meaning ;

cursor ck is select  rptg_grp_id
             from    ben_rptg_grp_v
             where   business_group_id = p_business_group_id
             and      name  = p_meaning  ;

cursor cl is select lookup_code
             from   hr_lookups
             where  lookup_type = 'BEN_EXT_CRIT_MISC'
             and     meaning = p_meaning;


cursor cm is select  pl_typ_id
             from    ben_pl_typ_f
             where   business_group_id = p_business_group_id
             and     trunc(sysdate) between nvl(effective_start_date,trunc(sysdate))
                             and nvl(effective_end_date,trunc(sysdate))
             and     name  = p_meaning;


cursor cn is select   yr_perd_id
              from    ben_yr_perd
              where   business_group_id = p_business_group_id
              and     start_date||' - '||end_date  = p_meaning;

cursor co is select lookup_code
              from   hr_lookups
              where  lookup_type = 'BEN_EXT_CRIT_MISC'
              and    meaning = p_meaning;

cursor cp is select lookup_code
              from   hr_lookups
              where  lookup_type = 'BEN_EXT_SUSPEND'
              and    meaning = p_meaning;

cursor cq is select lookup_code
             from   hr_lookups
             where  lookup_type = 'BEN_ENRT_RSLT_MTHD'
             and    meaning = p_meaning;

cursor cr is select lookup_code
             from   hr_lookups
             where  lookup_type = 'BEN_PRTT_ENRT_RSLT_STAT'
             and    meaning = p_meaning;

cursor cs is select lookup_code
             from   hr_lookups
             where  lookup_type = 'BEN_EXT_DT'
             and    meaning = p_meaning;

cursor ct is select  actn_typ_id
             from    ben_actn_typ
             where   name  = p_meaning ;



cursor cu is select lookup_code
             from   hr_lookups
             where  lookup_type = 'BEN_EXT_DT'
             and    meaning = p_meaning
             and    trunc(sysdate) between nvl(start_date_active, trunc(sysdate))
                                 and nvl(end_date_active, trunc(sysdate))
             ;



cursor cv is select lookup_code
             from   hr_lookups
             where  lookup_type = 'BEN_EXT_DT'
             and    meaning = p_meaning
             and    trunc(sysdate) between nvl(start_date_active, trunc(sysdate))
                                 and nvl(end_date_active, trunc(sysdate))
             ;

cursor cw is select lookup_code
             from   hr_lookups
             where  lookup_type = 'BEN_EXT_CHG_EVT'
             and    meaning = p_meaning
             and    trunc(sysdate) between nvl(start_date_active, trunc(sysdate))
                                 and nvl(end_date_active, trunc(sysdate))
              ;
cursor cep is select event_group_id
             from   pay_event_groups
             where  event_group_name  = p_meaning
             and     nvl(business_group_id,nvl(p_business_group_id,-1))
                      = nvl(p_business_group_id,-1)
              ;

cursor cx is select user_id
             from   fnd_user
             where  user_name  = p_meaning
             and    trunc(sysdate) between nvl(start_date, trunc(sysdate))
                                 and nvl(end_date, trunc(sysdate));

cursor cy is select lookup_code
             from   hr_lookups
             where  lookup_type = 'BEN_EXT_DT'
             and    meaning = p_meaning
             and    trunc(sysdate) between nvl(start_date_active, trunc(sysdate))
                                 and nvl(end_date_active, trunc(sysdate))
             ;

cursor cz is select lookup_code
             from   hr_lookups
             where  lookup_type = 'BEN_EXT_DT'
             and    meaning = p_meaning
             and    trunc(sysdate) between nvl(start_date_active, trunc(sysdate))
                                 and nvl(end_date_active, trunc(sysdate))
             ;

cursor caa is select lookup_code
             from   hr_lookups
             where  lookup_type = 'BEN_EXT_DT'
             and    meaning = p_meaning
             and    trunc(sysdate) between nvl(start_date_active, trunc(sysdate))
                                 and nvl(end_date_active, trunc(sysdate))
             ;

cursor cab is select lookup_code
             from   hr_lookups
             where  lookup_type = 'BEN_EXT_DT'
             and    meaning = p_meaning
             and    trunc(sysdate) between nvl(start_date_active, trunc(sysdate))
                                 and nvl(end_date_active, trunc(sysdate))
             ;


cursor cac is select lookup_code
             from   hr_lookups
             where  lookup_type = 'BEN_EXT_DT'
             and    meaning = p_meaning
             and    trunc(sysdate) between nvl(start_date_active, trunc(sysdate))
                                 and nvl(end_date_active, trunc(sysdate))
             ;

cursor cad is select lookup_code
             from   hr_lookups
             where  lookup_type = 'BEN_EXT_DT'
             and    meaning = p_meaning
             and    trunc(sysdate) between nvl(start_date_active, trunc(sysdate))
                                 and nvl(end_date_active, trunc(sysdate))
             ;

cursor cae is select lookup_code
             from   hr_lookups
             where  lookup_type = 'BEN_EXT_DT'
             and    meaning = p_meaning
             and    trunc(sysdate) between nvl(start_date_active, trunc(sysdate))
                                 and nvl(end_date_active, trunc(sysdate))
             ;

cursor caf is select lookup_code
             from   hr_lookups
             where  lookup_type = 'BEN_EXT_DT'
             and    meaning = p_meaning
             and    trunc(sysdate) between nvl(start_date_active, trunc(sysdate))
                                 and nvl(end_date_active, trunc(sysdate))
             ;

cursor cag is select lookup_code
             from   hr_lookups
             where  lookup_type = 'BEN_EXT_DT'
             and    meaning = p_meaning
             and    trunc(sysdate) between nvl(start_date_active, trunc(sysdate))
                                 and nvl(end_date_active, trunc(sysdate))
             ;


cursor cah is select lookup_code
             from   hr_lookups
             where  lookup_type = 'BEN_EXT_DT'
             and    meaning = p_meaning
             and    trunc(sysdate) between nvl(start_date_active, trunc(sysdate))
                                 and nvl(end_date_active, trunc(sysdate))
             ;


  cursor c_val1_dt
  is
  select lookup_code
  from   hr_lookups
  where  lookup_type = 'BEN_EXT_DT'
  and    meaning = p_meaning;

  cursor c_val2_dt
  is
  select lookup_code
  from   hr_lookups
  where  lookup_type = 'BEN_EXT_DT'
  and    meaning = p_meaning;

  cursor c_val1_chg_evt
  is
  select lookup_code
  from   hr_lookups
  where  lookup_type = 'BEN_EXT_CHG_EVT'
  and    meaning = p_meaning;

  cursor c_val2_chg_evt
  is
  select lookup_code
  from   hr_lookups
  where  lookup_type = 'BEN_EXT_CHG_EVT'
  and    meaning = p_meaning;

  cursor c_oper
  is
  select lookup_code
  from   hr_lookups
  where  lookup_type = 'BEN_EXT_TTL_COND_OPER'
  and    meaning = p_meaning; --p_oper_cd;


    CURSOR Cai IS
      select lookup_code
      from   HR_LOOKUPS
      where  LOOKUP_CODE = p_crit_typ_cd
      and    lookup_type = 'BEN_EXT_CRIT_TYP'
      and    substr(lookup_code, 1, 1) = 'C'
      and    lookup_code not in ('CBU')
      and    trunc(sysdate) between
             nvl(start_date_active, trunc(sysdate))
      and    nvl(end_date_active, trunc(sysdate))
      ;

   cursor c_pasu
    is
    select lookup_code
    from   hr_lookups
    where  lookup_type = 'BEN_EXT_ASMT_TO_USE'
    and    meaning = p_meaning;    --  code for the criteria Person Assignment To Use


    cursor c_berenm
    is
    select lookup_code
    from   hr_lookups
    where  lookup_type = 'BEN_ENRT_MTHD'
    and    meaning = p_meaning;  --  value for the criteria Enrollment method


    cursor c_enb is
    select ENRT_PERD_ID
    from  ben_enrt_perd enp ,
          ben_pl_f  pl,
          ben_popl_enrt_typ_cycl_f pet
    where to_char(enp.strt_dt, 'DD-MON-RRRR') || ' - ' || to_char( enp.end_dt, 'DD-MON-RRRR')  = p_meaning
    and pl.name = p_parent_meaning
    and pl.pl_id = pet.pl_id
    and pet.popl_enrt_typ_cycl_id  = enp.popl_enrt_typ_cycl_id
    and     trunc(sysdate) between nvl(pl.effective_start_date,trunc(sysdate))
                             and nvl(pl.effective_end_date,trunc(sysdate))
    and enp.business_group_id = p_business_group_id
   ;



   cursor c_lookup(p_type varchar2)  is
   select lookup_code
    from   hr_lookups
    where lookup_type = p_type
    and   meaning  = p_meaning
   ;  --

  cursor c_job is
  select job_id
  from  per_jobs_vl job
  where  name  =   p_meaning
  and business_group_id = p_business_group_id
   ;

  cursor c_bg is
  select business_group_id
  from  per_business_groups_perf
  where name  =    p_meaning
   ;

 cursor c_pos is
  select position_id
  from   HR_ALL_POSITIONS_F  job
  where name  =  p_meaning
  and trunc(sysdate) between
      EFFECTIVE_START_DATE
      and   EFFECTIVE_END_DATE
  and business_group_id = p_business_group_id
  ;


 cursor c_asgset  is
 select ASSIGNMENT_SET_ID  from
 hr_assignment_sets
 where ASSIGNMENT_SET_NAME  = p_meaning
  and  nvl(business_group_id,nvl(p_business_group_id,-1))
       = nvl(p_business_group_id,-1)
 ;


  BEGIN
--
   if p_crit_typ_cd = 'PST' then
     open c1;
     fetch c1 into value;
     close c1;

   elsif p_crit_typ_cd = 'PBG' then
     open c2;
     fetch c2 into value;
     close c2;
   elsif p_crit_typ_cd = 'PAS' then
     open c3;
     fetch c3 into value;
     close c3;
   elsif p_crit_typ_cd = 'POR' then
     open c4;
     fetch c4 into value;
     close c4;
   elsif p_crit_typ_cd = 'PLO' then
     open c5;
     fetch c5 into value;
     close c5;
   elsif p_crit_typ_cd = 'PLE' then
     open c6;
     fetch c6 into value;
     close c6;
   elsif p_crit_typ_cd = 'PID' then
     open c7;
     fetch c7 into value;
     close c7;
   elsif p_crit_typ_cd = 'PRL' then
     open c8;
     fetch c8 into value;
     close c8;
   elsif p_crit_typ_cd = 'PLV' then
     open c9;
     fetch c9 into value;
     close c9;
   elsif p_crit_typ_cd = 'PPT' then
     open c10;
     fetch c10 into value;
     close c10;
   elsif p_crit_typ_cd = 'MTP' then
     open ca;
     fetch ca into value;
     close ca;
   elsif p_crit_typ_cd = 'RRL' then
     open cb;
     fetch cb into value;
     close cb;
   elsif p_crit_typ_cd = 'REE'  and p_val_order = 'VAL_2' then
     open cc;
     fetch cc into value;
     close cc;
   elsif p_crit_typ_cd = 'REE'  and p_val_order = 'VAL_1' then
     open cd;
     fetch cd into value;
     close cd;
  elsif p_crit_typ_cd in ('BECLEN', 'BERLEN') then
    open c9;
    fetch c9 into value;
    close c9;

  elsif p_crit_typ_cd in ('BECLES', 'BERLES') then
    open cf;
    fetch cf into value;
    close cf;

  elsif p_crit_typ_cd in ('BECPLN', 'BPL') then
    open ce;
    fetch ce into value;
    close ce;

  elsif p_crit_typ_cd in ('BECRPG', 'BRG') then
    open ck;
    fetch ck into value;
    close ck;

  elsif p_crit_typ_cd in ('BECPGN', 'BERPGN') then
    open ci;
    fetch ci into value;
    close ci;

  elsif p_crit_typ_cd in ('BECPTN', 'BERPTN') then
    open cm;
    fetch cm into value;
    close cm;

  elsif p_crit_typ_cd = 'BECYRP' then
    open cn;
    fetch cn into value;
    close cn;

  elsif p_crit_typ_cd in ('BECMIS', 'BERMIS','BACMIS') then
    open cl;
    fetch cl into value;
    close cl;


  elsif p_crit_typ_cd = 'BSE' then
    open cg;
    fetch cg into value;
    close cg;

  elsif p_crit_typ_cd = 'BERENM' then
    open c_berenm;
    fetch c_berenm into value;
    close c_berenm;

  elsif p_crit_typ_cd = 'BERSTA' then
    open cr;
    fetch cr into value;
    close cr;
 /*
  elsif p_crit_typ_cd in ('BECESD', 'BECLUD','BECLND', 'BECLED', 'BERCSD', 'BERCDP', 'BERLUD',
                           'BERLND', 'BERLOD')  then
    open cp;
    fetch cp into value;
    if cp%notfound then
      value := p_val_1;
    end if;
    close cp;
 */

  elsif p_crit_typ_cd = 'BACN' then
    open ct;
    fetch ct into value;
    close ct;
  elsif p_crit_typ_cd in ('BDTOR')      then
    open cu;
    fetch cu into value;
    if cu%notfound then
      value := p_val_1;
    end if;
    close cu;
  elsif p_crit_typ_cd in ('PASOR')      then
    open cv;
    fetch cv into value;
    if cv%notfound then
      value := p_val_1;
    end if;
    close cv;
  elsif p_crit_typ_cd = 'CCE' then
    open cw;
    fetch cw into value;
    close cw;
--  elsif p_crit_typ_cd = 'CEP'  and p_val_order = 'VAL_2'  then
  elsif p_crit_typ_cd = 'CPE'  and p_val_order = 'VAL_2'  then -- anshghos
    value := P_meaning ;
--  elsif p_crit_typ_cd = 'CEP'  and p_val_order = 'VAL_1'  then
  elsif p_crit_typ_cd = 'CPE'  and p_val_order = 'VAL_1'  then -- anshghos
    open CEP;
    fetch CEP into value;
    close CEP;

  elsif p_crit_typ_cd = 'CBU' then
    open cx;
    fetch cx into value;
    close cx;
  elsif p_crit_typ_cd in ('BECESD', 'BECLUD','BECLND', 'BECLED', 'BERCSD','BERCDP','BERLUD',
                           'BERLND', 'BERLOD')  then
    open cy;
    fetch cy into value;
    if cy%notfound then
      value := p_val_1;
    end if;
    close cy;
 /*
  elsif p_crit_typ_cd in ('BECESD', 'BECLUD','BECLND', 'BECLED', 'BERCSD', 'BERCDP', 'BERLUD',
                           'BERLND', 'BERLOD')  then
    open cz;
    fetch cz into value;
    if cz%notfound then
      value := p_val_2;
    end if;
    close cz;
  */
  elsif p_crit_typ_cd in ('MTBSDT', 'MPCLUD', 'MPCPLUD', 'MSDT')        then
    open caa;
    fetch caa into value;
    if caa%notfound then
      value := p_val_1;
    end if;
    close caa;
  elsif p_crit_typ_cd in ('MTBSDT', 'MPCLUD', 'MPCPLUD', 'MSDT') then
    open cab;
    fetch cab into value;
    if cab%notfound then
      value := p_val_2;
    end if;
    close cab;
  elsif p_crit_typ_cd in ('CAD', 'CED') then
    open cac;
    fetch cac into value;
    if cac%notfound then
      value := p_val_1;
    end if;
    close cac;
  elsif p_crit_typ_cd in ('CAD', 'CED') then
    open cad;
    fetch cad into value;
    if cad%notfound then
      value := p_val_2;
    end if;
    close cad;
  elsif p_crit_typ_cd is not null and p_crit_typ_cd = 'RPPEDT' then
    open cag;
    fetch cag into value;
    if cag%notfound then
      value := p_val_1;
    end if;
    close cag;
  elsif p_crit_typ_cd is not null and p_crit_typ_cd = 'RPPEDT' then
    open cah;
    fetch cah into value;
    if cah%notfound then
      value := p_val_2;
    end if;
    close cah;
        /*open c_oper;
        fetch c_oper into value; --p_oper_cd_nonbase;
        close c_oper;
       */


  elsif p_crit_typ_cd in ( 'CAD','CED', 'EPMNYR','EPLDT' ) then
    open c_val1_dt;
    fetch c_val1_dt into value;
    close c_val1_dt;
   /*
    open c_val2_dt;
    fetch c_val2_dt into value;
    close c_val2_dt;
  */

  elsif p_crit_typ_cd = 'CCE' then
    open c_val1_chg_evt;
    fetch c_val1_chg_evt into value;
    close c_val1_chg_evt;
    open c_val2_chg_evt;
    fetch c_val2_chg_evt into value;
    close c_val2_chg_evt;
 elsif p_crit_typ_cd = 'PASU' then
    open c_pasu;
    fetch c_pasu into value;
    close c_pasu;


  elsif p_crit_typ_cd = 'HRL' then
        open c8;
        fetch c8 into value;
        close c8;

 elsif p_crit_typ_cd = 'RFFRL' then
        open c8;
        fetch c8 into value;
        close c8;

  elsif p_crit_typ_cd = 'WPLPR'  and p_val_order = 'VAL_2'then
        -- plan
        open cj;
        fetch cj into value;
        close cj;
   elsif p_crit_typ_cd = 'WPLPR'  and p_val_order = 'VAL_1'then
        -- plan enrollment period
        open c_enb;
        fetch c_enb into value;
        close c_enb;

  elsif p_crit_typ_cd = 'PDL' then
        Open c_lookup('BEN_EXT_PER_DATA_LINK') ;
        fetch c_lookup into value;
        close c_lookup;

  elsif p_crit_typ_cd = 'HJOB' then
        open c_job;
        fetch c_job into value;
        close c_job;
  elsif p_crit_typ_cd = 'HORG' then
        open c4;
        fetch c4 into value;
        close c4;
  elsif p_crit_typ_cd = 'HPOS' then
        open c_pos;
        fetch c_pos into value;
        close c_pos;
  elsif p_crit_typ_cd = 'HPY' then
        open cb;
        fetch cb into value;
        close cb;
 elsif p_crit_typ_cd = 'HBG' then
        open c_bg;
        fetch c_bg into value;
        close c_bg;
  elsif p_crit_typ_cd = 'PBGR' then
        open c_bg;
        fetch c_bg into value;
        close c_bg;
  elsif p_crit_typ_cd = 'PASGSET' then

       open c_asgset ;
       fetch c_asgset into value ;
       close  c_asgset ;

 else
    value :=  p_meaning ;
  end if;
   /* OPEN Cai;
    FETCH Cai into value;
    CLOSE Cai;
   */
return value;
end;

procedure get_who_values(p_owner IN VARCHAR2
                        ,p_last_update_vc in VARCHAR2
                        ,p_last_update_date OUT NOCOPY DATE
                        ,p_last_updated_by  OUT NOCOPY VARCHAR2
                        ,p_legislation_code IN OUT NOCOPY VARCHAR2
                        ,p_business_group   in   VARCHAR2
                        ,p_business_group_id out NOCOPY  NUMBER
                        ) is
begin
  p_last_update_date := TO_DATE(p_last_update_vc, 'YYYY/MM/DD HH24:MI:SS');
  IF p_owner = 'SEED'
  THEN
     p_last_updated_by := 1;
  ELSE
     p_last_updated_by := 0;
  END IF;
  if p_legislation_code = 'GLOBAL' then
     p_legislation_code := '';
  end if;
  --  the custom extract can not uploaded as seed ( bg id null )
  --  seeded extract can not be uploaded to a  business   group

  if  p_owner = 'CUSTOM' then
      if  p_business_group is null then
         fnd_message.set_name('BEN','BEN_93272_PDC_SRC_BUSINESS_GRP');
         fnd_message.raise_error;
      end if ;
  else
     if p_business_group is not  null then
        fnd_message.set_name('BEN','BEN_93209_PDC_INVALID_BG_ER');
        fnd_message.raise_error;
     end if ;
     /*
     -- there is a possibility of sharing legislative
     -- elements
     if g_business_group_id is not null then
        fnd_message.set_name('BEN','BEN_93200_PDC_INVALID_BG_ER');
        fnd_message.raise_error;
     end if ;
    */
  end if ;
  p_business_group_id := g_business_group_id ;

end get_who_values;


procedure load_extract_group(p_file_name   IN VARCHAR2
                       ,p_ext_group_record in  VARCHAR2
                       ,p_ext_group_elmt1  in  VARCHAR2
                       ,p_ext_group_elmt2  in  VARCHAR2
                       ,p_owner            IN VARCHAR2
                       ,p_last_update_date IN VARCHAR2
                       ,p_legislation_code IN VARCHAR2
                       ,p_business_group   in VARCHAR2
                       ) is
--
l_ext_file_id           NUMBER;
l_ext_rcd_in_file_id    NUMBER;
l_ext_data_elmt_in_rcd_id1     NUMBER;
l_ext_data_elmt_in_rcd_id2     NUMBER;
l_ext_rcd_id                   NUMBER;
l_object_version_number NUMBER;
l_last_update_date      DATE;
l_last_updated_by       NUMBER;
l_sessionid             NUMBER;
l_new_business_group_id number ;
l_ovn                   number ;
l_xml_tag_name          ben_ext_file.xml_tag_name%type ;
l_legislation_code      VARCHAR2(240);

--
BEGIN
  l_legislation_code := p_legislation_code;

 if  p_ext_group_record is not null and p_ext_group_elmt1 is not null then
  --
     get_who_values(p_owner             => p_owner
                ,p_last_update_vc    => p_last_update_date
                ,p_last_update_date  => l_last_update_date
                ,p_last_updated_by   => l_last_updated_by
                ,p_legislation_code  => l_legislation_code
                ,p_business_group    => p_business_group
                ,p_business_group_id => l_new_business_group_id );
      BEGIN
        SELECT ext_file_id ,
               OBJECT_VERSION_NUMBER ,
                XML_TAG_NAME
        INTO   l_ext_file_id ,
               l_ovn,
               l_xml_tag_name
        FROM   ben_ext_file
        WHERE  name             = p_file_name
           AND    nvl(l_new_business_group_id, -1) = nvl(business_group_id , -1)
           AND    nvl(legislation_code,'~NULL~')   = nvl(l_legislation_code,'~NULL~');


       select erf.ext_rcd_in_file_id,
              rcd.ext_rcd_id
         into l_ext_rcd_in_file_id  ,
              l_ext_rcd_id
         from ben_Ext_rcd_in_file erf,
              ben_Ext_rcd  rcd
        where rcd.name =  p_ext_group_record
          and rcd.ext_rcd_id = erf.ext_rcd_id
          and erf.ext_file_id = l_ext_file_id
        ;


       select  der.Ext_data_elmt_in_rcd_id
         into  l_ext_data_elmt_in_rcd_id1
          from ben_Ext_data_elmt elmt  ,
               ben_Ext_data_elmt_in_rcd der
          where der.ext_rcd_id = l_Ext_rcd_id
            and elmt.ext_data_elmt_id =  der.ext_data_elmt_id
            and elmt.name   = p_ext_group_elmt1
       ;

       if p_ext_group_elmt2 is not null then

          select  der.Ext_data_elmt_in_rcd_id
            into  l_ext_data_elmt_in_rcd_id2
             from ben_Ext_data_elmt elmt  ,
                  ben_Ext_data_elmt_in_rcd der
             where der.ext_rcd_id = l_Ext_rcd_id
               and elmt.ext_data_elmt_id =  der.ext_data_elmt_id
               and elmt.name   = p_ext_group_elmt2
          ;

       end if ;


        ben_xfi_upd.upd
             (
              p_ext_file_id                   => l_ext_file_id
             ,p_name                          => p_file_name
             ,p_ext_rcd_in_file_id            => l_ext_rcd_in_file_id
             ,p_ext_data_elmt_in_rcd_id1      => l_ext_data_elmt_in_rcd_id1
             ,p_ext_data_elmt_in_rcd_id2      => l_ext_data_elmt_in_rcd_id2
             ,p_business_group_id             => l_new_business_group_id
             ,p_legislation_code              => l_legislation_code
             ,p_object_version_number         => l_ovn
             );




      EXCEPTION
      WHEN NO_DATA_FOUND THEN
           null ;
       WHEN OTHERS THEN
          null ;
      END;
  end if ;
END load_extract_group;





procedure load_extract(p_file_name IN VARCHAR2
                       ,p_owner IN VARCHAR2
                       ,p_last_update_date IN VARCHAR2
                       ,p_legislation_code IN VARCHAR2
                       ,p_business_group   in VARCHAR2
                       ,p_xml_tag_name     in VARCHAR2
                       ,p_ext_group_record in  VARCHAR2
                       ,p_ext_group_elmt1  in  VARCHAR2
                       ,p_ext_group_elmt2  in  VARCHAR2
                       ) is
--
l_ext_file_id           NUMBER;
l_object_version_number NUMBER;
l_legislation_code      VARCHAR2(240);
l_temp                  VARCHAR2(1);
l_last_update_date      DATE;
l_last_updated_by       NUMBER;
l_sessionid             NUMBER;
l_new_business_group_id number ;
l_ovn                   number ;
l_xml_tag_name          ben_ext_file.xml_tag_name%type ;

  l_proc                   varchar2(100) := 'BEN_EXT_SEED.load_extract' ;

--
BEGIN
   hr_utility.set_location(' Entering ' || l_proc, 10);
  l_legislation_code := p_legislation_code;

  g_group_record     := p_ext_group_record ;
  g_group_elmt1      := p_ext_group_elmt1  ;
  g_group_elmt2      := p_ext_group_elmt2  ;

  SELECT USERENV('SESSIONID')
  INTO   l_sessionid
  FROM   DUAL;
  --


    -- adding these conditions after checking with the code under
    If  ( p_legislation_code = 'GLOBAL'  or p_legislation_code is null)
        and  p_business_group is null   then
       hr_startup_data_api_support.enable_startup_mode(p_mode =>'GENERIC'
                        ,p_startup_session_id =>l_sessionid);
    elsif p_business_group is null  then
       hr_startup_data_api_support.enable_startup_mode(p_mode =>'STARTUP'
                                 ,p_startup_session_id =>l_sessionid);
    End If;

     hr_startup_data_api_support.create_owner_definition('BEN',FALSE);
  --
  get_who_values(p_owner             => p_owner
                ,p_last_update_vc    => p_last_update_date
                ,p_last_update_date  => l_last_update_date
                ,p_last_updated_by   => l_last_updated_by
                ,p_legislation_code  => l_legislation_code
                ,p_business_group    => p_business_group
                ,p_business_group_id => l_new_business_group_id );
  BEGIN
    SELECT ext_file_id ,
           OBJECT_VERSION_NUMBER ,
            XML_TAG_NAME
    INTO   l_ext_file_id ,
           l_ovn,
           l_xml_tag_name
    FROM   ben_ext_file
    WHERE  name             = p_file_name
       AND    nvl(l_new_business_group_id, -1) = nvl(business_group_id , -1)
       AND    nvl(legislation_code,'~NULL~')   = nvl(l_legislation_code,'~NULL~');

    --for the business group extract  dont allow to upload if the extract layout  already exist
    if nvl(fnd_global.conc_request_id,-1) <> -1 and
          ( l_new_business_group_id is not null and g_override <> 'Y' ) then
        fnd_message.set_name('BEN','BEN_93741_EXT_FILE_EXISTS');
        fnd_file.put_line(fnd_file.log, fnd_message.get);
        fnd_message.raise_error;
    end if ;
    --- data exist and global and xml_tag name is not matching
    --- update the  extract file layout
    if  nvl(l_xml_tag_name, '-1') <> nvl( p_xml_tag_name,'-1') then
          ben_xfi_upd.upd
             (
              p_ext_file_id                   => l_ext_file_id
             ,p_name                          => p_file_name
             ,p_xml_tag_name                  => p_xml_tag_name
             ,p_business_group_id             => l_new_business_group_id
             ,p_legislation_code              => l_legislation_code
             ,p_object_version_number         => l_ovn
             );
    end if ;

   EXCEPTION
   WHEN NO_DATA_FOUND THEN
    ben_xfi_ins.ins(p_ext_file_id           =>l_ext_file_id
                   ,p_name                  => p_file_name
                   ,p_business_group_id     => l_new_business_group_id
                   ,p_legislation_code      =>l_legislation_code
                   ,p_last_update_date      => l_last_update_date
                   ,p_creation_date         => l_last_update_date
                   ,p_last_update_login     => 0
                   ,p_created_by            => l_last_updated_by
                   ,p_last_updated_by       => l_last_updated_by
                   ,p_object_version_number => l_object_version_number
                   ,p_xml_tag_name          => p_xml_tag_name
                   );
   WHEN OTHERS THEN
    RAISE;
  END;
   hr_utility.set_location(' Leaving ' || l_proc, 10);
END load_extract;
--
PROCEDURE load_record(p_record_name      IN VARCHAR2
                     ,p_owner            IN VARCHAR2
                     ,p_last_update_date IN VARCHAR2
                     ,p_rcd_type_cd      IN VARCHAR2
                     ,p_low_lvl_cd       IN VARCHAR2
                     ,p_legislation_code IN VARCHAR2
                     ,p_business_group   IN VARCHAR2
                     ,p_xml_tag_name     in VARCHAR2
                     ) IS
--
l_ext_rcd_id number;
l_object_version_number number;
l_legislation_code VARCHAR2(240) := p_legislation_code; --utf8
l_temp VARCHAR2(1);
l_last_update_date      DATE;
l_last_updated_by        NUMBER;
l_new_business_group_id number ;
l_ovn                   number ;
l_xml_tag_name          ben_ext_rcd.xml_tag_name%type ;
l_rcd_type_cd           ben_ext_rcd.RCD_TYPE_CD%type ;
l_low_lvl_cd            ben_ext_rcd.LOW_LVL_CD%type  ;
  l_proc                   varchar2(100) := 'BEN_EXT_SEED.load_record' ;
BEGIN
    hr_utility.set_location(' Entering ' || l_proc, 10);
   get_who_values(p_owner             => p_owner
                ,p_last_update_vc    => p_last_update_date
                ,p_last_update_date  => l_last_update_date
                ,p_last_updated_by   => l_last_updated_by
                ,p_legislation_code  => l_legislation_code
                ,p_business_group    => p_business_group
                ,p_business_group_id => l_new_business_group_id );

   BEGIN
    SELECT EXT_RCD_ID,
           OBJECT_VERSION_NUMBER,
           XML_TAG_NAME,
           RCD_TYPE_CD ,
           LOW_LVL_CD
    INTO   l_ext_rcd_id,
           l_ovn,
           l_xml_tag_name,
           l_RCD_TYPE_CD,
           l_LOW_LVL_CD
    FROM   ben_ext_rcd
    WHERE  name             = p_record_name
    AND    nvl(l_new_business_group_id, -1) = nvl(business_group_id , -1)
    AND    nvl(legislation_code,'~NULL~') =  nvl(l_legislation_code,'~NULL~');

    -- when the extract is global and once of therecord value changed then update
    if  ( l_new_business_group_id is null or g_override = 'Y')  and
        (   nvl(l_xml_tag_name,'-1') <> nvl(p_xml_tag_name,'-1')
         OR l_RCD_TYPE_CD            <>   p_RCD_TYPE_CD
         OR nvl(l_LOW_LVL_CD,'-1') <> nvl(p_LOW_LVL_CD,'-1')
        ) then

      ben_xrc_upd.upd(p_effective_date       => l_last_update_date
                    ,p_ext_rcd_id            => l_ext_rcd_id
                    ,p_name                  => p_record_name
                    ,p_rcd_type_cd           => p_rcd_type_cd
                    ,p_low_lvl_cd            => p_low_lvl_cd
                    ,p_business_group_id     => l_new_business_group_id
                    ,p_legislation_code      => l_legislation_code
                    ,p_object_version_number => l_ovn
                    ,p_xml_tag_name          => p_xml_tag_name   );

    end if ;

  EXCEPTION
   WHEN NO_DATA_FOUND THEN
     ben_xrc_ins.ins(p_effective_date        => l_last_update_date
                    ,p_ext_rcd_id            => l_ext_rcd_id
                    ,p_name                  => p_record_name
                    ,p_rcd_type_cd           => p_rcd_type_cd
                    ,p_low_lvl_cd            => p_low_lvl_cd
                    ,p_business_group_id     => l_new_business_group_id
                    ,p_legislation_code      => l_legislation_code
                    ,p_last_update_date      => l_last_update_date
                    ,p_creation_date         => l_last_update_date
                    ,p_last_update_login     => 0
                    ,p_created_by            => l_last_updated_by
                    ,p_last_updated_by       => l_last_updated_by
                    ,p_object_version_number => l_object_version_number
                    ,p_xml_tag_name          => p_xml_tag_name   );
   WHEN OTHERS THEN
     RAISE;
  END;
   hr_utility.set_location(' Leaving ' || l_proc, 10);
END load_record;



PROCEDURE load_record_in_file(p_file_name            IN VARCHAR2
                             ,p_parent_record_name   IN VARCHAR2
                             ,p_owner                IN VARCHAR2
                             ,p_last_update_date     IN VARCHAR2
                             ,p_rqd_flag             IN VARCHAR2 default 'N'
                             ,p_hide_flag            IN VARCHAR2 default 'N'
                             ,p_CHG_RCD_UPD_FLAG     IN VARCHAR2 default 'N'
                             ,p_seq_num              IN VARCHAR2
                             ,p_sprs_cd              IN VARCHAR2
                             ,p_any_or_all_cd        IN VARCHAR2 default 'N'
                             ,p_sort1_element        IN VARCHAR2 DEFAULT NULL
                             ,p_sort2_element        IN VARCHAR2 DEFAULT NULL
                             ,p_sort3_element        IN VARCHAR2 DEFAULT NULL
                             ,p_sort4_element        IN VARCHAR2 DEFAULT NULL
                             ,p_legislation_code     IN VARCHAR2
                             ,p_business_group       in VARCHAR2
                             ) IS
--
l_ext_file_id           NUMBER;
l_ext_rcd_id            NUMBER;
l_rcd_in_file_id        NUMBER;
l_object_version_number NUMBER;
l_legislation_code      VARCHAR2(240) := p_legislation_code; --utf8
l_temp                  VARCHAR2(1);
l_last_update_date      DATE;
l_last_updated_by       NUMBER;
l_seq_dup_id            NUMBER;
l_new_business_group_id number ;
l_sort1_elm_in_rcd_id   NUMBER;
l_sort2_elm_in_rcd_id   NUMBER;
l_sort3_elm_in_rcd_id   NUMBER;
l_sort4_elm_in_rcd_id   NUMBER;
--rpinjala
l_ext_rcd_in_file_id    NUMBER;
--rpinjala

 cursor c_sort ( c_sort_element varchar2,
                 c_ext_rcd_id  number ,
                 c_legislation_code varchar2 ,
                 c_new_business_group_id number )  is
 SELECT EXT_DATA_ELMT_IN_RCD_ID
 from   ben_ext_data_elmt_in_rcd eir , ben_ext_data_elmt elmt
 where  eir.ext_rcd_id =  c_ext_rcd_id
 and  eir.ext_data_elmt_id = elmt.ext_data_elmt_id
 and  elmt.name    =   c_sort_element
 and  NVL(eir.legislation_code,'~NULL~') =  NVL(c_legislation_code,'~NULL~')
 AND  nvl( c_new_business_group_id, -1) = nvl(eir.business_group_id , -1)
 ;




  l_proc                   varchar2(100) := 'BEN_EXT_SEED.load_record_in_file' ;
BEGIN
   hr_utility.set_location(' Entering ' || l_proc, 10);


   get_who_values(p_owner             => p_owner
                ,p_last_update_vc    => p_last_update_date
                ,p_last_update_date  => l_last_update_date
                ,p_last_updated_by   => l_last_updated_by
                ,p_legislation_code  => l_legislation_code
                ,p_business_group    => p_business_group
                ,p_business_group_id => l_new_business_group_id );


  BEGIN
   SELECT ext_file_id
   INTO   l_ext_file_id
   FROM   ben_ext_file
   WHERE name = p_file_name
   AND NVL(legislation_code,'~NULL~') =  NVL(l_legislation_code,'~NULL~')
    AND    nvl(l_new_business_group_id, -1) = nvl(business_group_id , -1);

  EXCEPTION
   WHEN NO_DATA_FOUND THEN
       RAISE;
  END;


  BEGIN
   SELECT ext_rcd_id
   INTO   l_ext_rcd_id
   FROM   ben_ext_rcd
   WHERE name = p_parent_record_name
   AND NVL(legislation_code,'~NULL~') =  NVL(l_legislation_code,'~NULL~')
   AND    nvl( l_new_business_group_id, -1) = nvl(business_group_id , -1);

  EXCEPTION
   WHEN NO_DATA_FOUND THEN
       RAISE;
  END;


  --- sort1_data_elmt_in_rcd_id


  if  l_ext_rcd_id is not null and p_sort1_element is not null then

      l_sort1_elm_in_rcd_id  := null ;
      open  c_sort ( c_sort_element           => p_sort1_element ,
                     c_ext_rcd_id             => l_ext_rcd_id ,
                     c_legislation_code       => l_legislation_code ,
                     c_new_business_group_id  => l_new_business_group_id ) ;
      fetch c_sort into  l_sort1_elm_in_rcd_id ;
      close c_sort ;


  end if ;

   --- sort2_data_elmt_in_rcd_id
   if  l_ext_rcd_id is not null and p_sort2_element is not null then
       l_sort2_elm_in_rcd_id := null ;

       open  c_sort (c_sort_element           => p_sort2_element ,
                     c_ext_rcd_id             => l_ext_rcd_id ,
                     c_legislation_code       => l_legislation_code ,
                     c_new_business_group_id  => l_new_business_group_id ) ;
      fetch c_sort into  l_sort2_elm_in_rcd_id ;
      close c_sort ;


   end if ;

   --- sort3_data_elmt_in_rcd_id
   if  l_ext_rcd_id is not null and p_sort3_element is not null then

       l_sort3_elm_in_rcd_id := null ;

       open  c_sort (c_sort_element           => p_sort3_element ,
                     c_ext_rcd_id             => l_ext_rcd_id ,
                     c_legislation_code       => l_legislation_code ,
                     c_new_business_group_id  => l_new_business_group_id ) ;
      fetch c_sort into  l_sort3_elm_in_rcd_id ;
      close c_sort ;


  end if ;

   --- sort4_data_elmt_in_rcd_id
  if  l_ext_rcd_id is not null and p_sort4_element is not null then
      l_sort4_elm_in_rcd_id := null ;
      open  c_sort (c_sort_element           => p_sort4_element ,
                     c_ext_rcd_id             => l_ext_rcd_id ,
                     c_legislation_code       => l_legislation_code ,
                     c_new_business_group_id  => l_new_business_group_id ) ;
      fetch c_sort into  l_sort4_elm_in_rcd_id ;
      close c_sort ;

  end if ;


  BEGIN
    --rpinjala
    SELECT ext_rcd_in_file_id,  object_version_number
    INTO   l_ext_rcd_in_file_id,l_object_version_number
    FROM   ben_ext_rcd_in_file
    WHERE  ext_file_id             = l_ext_file_id
    AND    ext_rcd_id              = l_ext_rcd_id
    AND    seq_num                 = p_seq_num
    AND    NVL(legislation_code,'~NULL~')    = NVL(l_legislation_code,'~NULL~')
    AND    NVL( l_new_business_group_id, -1) = NVL(business_group_id , -1);

     ben_xrf_upd.upd
        (p_effective_date            => l_last_update_date
        ,p_ext_rcd_in_file_id        => l_ext_rcd_in_file_id
        ,p_seq_num                   => p_seq_num
        ,p_sprs_cd                   => p_sprs_cd
        ,p_ext_rcd_id                => l_ext_rcd_id
        ,p_ext_file_id               => l_ext_file_id
        ,p_business_group_id         => l_new_business_group_id
        ,p_legislation_code          => l_legislation_code
        ,p_last_update_date          => l_last_update_date
        ,p_creation_date             => l_last_update_date
        ,p_last_updated_by           => l_last_updated_by
        ,p_last_update_login         => 0
        ,p_created_by                => l_last_updated_by
        ,p_object_version_number     => l_object_version_number
        ,p_any_or_all_cd             => p_any_or_all_cd
        ,p_hide_flag                 => p_hide_flag
        ,p_rqd_flag                  => p_rqd_flag
        ,p_CHG_RCD_UPD_FLAG          => nvl(p_CHG_RCD_UPD_FLAG,'N')
        ,p_sort1_data_elmt_in_rcd_id => l_sort1_elm_in_rcd_id
        ,p_sort2_data_elmt_in_rcd_id => l_sort2_elm_in_rcd_id
        ,p_sort3_data_elmt_in_rcd_id => l_sort3_elm_in_rcd_id
        ,p_sort4_data_elmt_in_rcd_id => l_sort4_elm_in_rcd_id
         );
    --rpinjala
  EXCEPTION
   WHEN NO_DATA_FOUND THEN

      /*  If the Same Sequence Find Delete the Record for the Sequence  */
     declare
       cursor c1 (c_ext_rcd_in_file_id number) is
       select 'x'
       from ben_Ext_where_clause
       where ext_rcd_in_file_id = c_ext_rcd_in_file_id ;

       cursor c2 (c_ext_rcd_in_file_id number) is
       select 'x'
       from ben_ext_incl_chg
       where ext_rcd_in_file_id = c_ext_rcd_in_file_id ;

       l_tmp varchar2(1) ;
     Begin
        select object_version_number,ext_rcd_in_file_id
          into l_object_version_number,l_rcd_in_file_id
        from ben_ext_rcd_in_file
        where  ext_file_id             = l_ext_file_id
         and   ext_rcd_id              <> nvl(l_ext_rcd_id,-1)
         and   seq_num                 = p_seq_num
         AND    nvl( l_new_business_group_id, -1) = nvl(business_group_id , -1) ;
         /*  if the sequence found delete the old  reco   */
         -- this delete may error if it has child
         -- **** Before apply any delete keep in mind that every upload  recrod_in_file is
         --      called twice , one for the record_in_file and one for the sort order
         --      this is done in such way to keep the backward copatibility ****

         if  ( l_new_business_group_id is null or g_override = 'Y' ) and
             l_sort1_elm_in_rcd_id is null and
             l_sort2_elm_in_rcd_id is null and
             l_sort4_elm_in_rcd_id is null  then

             -- make sure there us no wheere clause child
             open c1(l_rcd_in_file_id) ;
             fetch c1 into l_tmp ;
             if c1%notfound then

                open c2(l_rcd_in_file_id) ;
                fetch c2 into l_tmp ;
                if c2%notfound then

                    ben_xrf_del.del(p_effective_date        => l_last_update_date
                          ,p_ext_rcd_in_file_id    => l_rcd_in_file_id
                          ,p_legislation_code      => l_legislation_code
                          ,p_object_version_number => l_object_version_number);

                end if ;
                close c2 ;
            end if ;
            close c1 ;
         end if ;
     Exception
        WHEN NO_DATA_FOUND THEN
             null ;
       When Others then
         RAISE ;
     End ;
     /* Deleteion part is over for duplicate seq number */

     ben_xrf_ins.ins(p_effective_date        => l_last_update_date
                    ,p_ext_rcd_in_file_id    => l_rcd_in_file_id
                    ,p_legislation_code      => l_legislation_code
                    ,p_ext_rcd_id            => l_ext_rcd_id
                    ,p_ext_file_id           => l_ext_file_id
                    ,p_business_group_id     => l_new_business_group_id
                    ,p_seq_num               => p_seq_num
                    ,p_sprs_cd               => p_sprs_cd
                    ,p_any_or_all_cd         => p_any_or_all_cd
                    ,p_hide_flag             => p_hide_flag
                    ,p_rqd_flag              => p_rqd_flag
                    ,p_chg_rcd_upd_flag      => nvl(p_chg_rcd_upd_flag,'N')
                    ,p_sort1_data_elmt_in_rcd_id => l_sort1_elm_in_rcd_id
                    ,p_sort2_data_elmt_in_rcd_id => l_sort2_elm_in_rcd_id
                    ,p_sort3_data_elmt_in_rcd_id => l_sort3_elm_in_rcd_id
                    ,p_sort4_data_elmt_in_rcd_id => l_sort4_elm_in_rcd_id
                    ,p_last_update_date      => l_last_update_date
                    ,p_creation_date         => l_last_update_date
                    ,p_last_update_login     => 0
                    ,p_created_by            => l_last_updated_by
                    ,p_last_updated_by       => l_last_updated_by
                    ,p_object_version_number => l_object_version_number);
   WHEN OTHERS THEN
     RAISE;
   END ;
    hr_utility.set_location(' Leaving ' || l_proc, 10);
END load_record_in_file;


PROCEDURE load_ext_data_elmt(p_data_elemt_name     IN VARCHAR2
                            ,p_parent_data_element IN VARCHAR2 DEFAULT NULL
                            ,p_field_short_name    IN VARCHAR2 DEFAULT NULL
                            ,p_parent_record_name  IN VARCHAR2 DEFAULT NULL
                            ,p_owner               IN VARCHAR2
                            ,p_last_update_date    IN VARCHAR2
                            ,p_ttl_fnctn_cd        IN VARCHAR2
                            ,p_ttl_cond_oper_cd    IN VARCHAR2
                            ,p_ttl_cond_val        IN VARCHAR2
                            ,p_data_elmt_typ_cd    IN VARCHAR2
                            ,p_data_elmt_rl        IN VARCHAR2
                            ,p_frmt_mask_cd        IN VARCHAR2
                            ,p_string_val          IN VARCHAR2
                            ,p_dflt_val            IN VARCHAR2
                            ,p_max_length_num      IN VARCHAR2
                            ,p_just_cd             IN VARCHAR2
                            ,p_legislation_code    IN VARCHAR2
                            ,p_business_group      in varchar2
                            ,p_xml_tag_name        in VARCHAR2
                            ,p_defined_balance     in VARCHAR2 DEFAULT NULL
                            ) IS


--
  l_ext_field_id          NUMBER;
  l_ext_data_elmt_id      NUMBER;
  l_ext_rcd_id            NUMBER;
  l_parent_data_elmt_id   NUMBER;
  l_formula_id            NUMBER;
  l_object_version_number NUMBER;
  l_legislation_code      VARCHAR2(240) := p_legislation_code; --utf8
  l_temp                  VARCHAR2(1);
  l_last_update_date      DATE;
  l_last_updated_by       NUMBER;
  l_tmp_id                number ;
  l_tmp_ovn               NUMBER;
  l_new_business_group_id number ;
  l_string                ben_ext_data_elmt.string_val%type ;
  l_defined_balance_id   number ;
--
CURSOR c_dt_rule(p_data_elmt_rl VARCHAR2
                ,l_new_business_group_id NUMBER
                ,l_last_update_date in date ) IS
SELECT formula_id
FROM   ff_formulas_f
WHERE formula_name = p_data_elmt_rl
AND    nvl( l_new_business_group_id, -1) = nvl(business_group_id , -1)
AND   nvl(l_last_update_date,trunc(sysdate)) BETWEEN effective_start_date and effective_end_date ;
--
  l_proc                   varchar2(100) := 'BEN_EXT_SEED.load_ext_data_elmt' ;
BEGIN
   hr_utility.set_location(' Entering ' || l_proc, 10);

   get_who_values(p_owner             => p_owner
                ,p_last_update_vc    => p_last_update_date
                ,p_last_update_date  => l_last_update_date
                ,p_last_updated_by   => l_last_updated_by
                ,p_legislation_code  => l_legislation_code
                ,p_business_group    => p_business_group
                ,p_business_group_id => l_new_business_group_id );

  IF p_data_elmt_typ_cd IN ('R','S') THEN
     IF p_data_elmt_typ_cd = 'R' THEN
        BEGIN
          --OPEN c_dt_rule(p_data_elmt_rl, l_new_business_group_id , l_last_update_date );
          OPEN c_dt_rule(p_data_elmt_rl, l_new_business_group_id , trunc(sysdate) );
          FETCH c_dt_rule into l_formula_id;
          IF c_dt_rule%NOTFOUND THEN
	     close c_dt_rule;
             raise_application_error(-20001,' no formula Data element '||
             p_data_elemt_name||' legislation code '||l_legislation_code);
	  else
	    close c_dt_rule;
           END IF;

        END;
        BEGIN
           l_tmp_id  := null ;
           l_tmp_ovn := null ;
           SELECT ext_data_elmt_id , object_version_number,string_val
           INTO l_tmp_id , l_tmp_ovn,l_string
           FROM ben_ext_data_elmt
           WHERE name = p_data_elemt_name
           AND   NVL(legislation_code,'~NULL~') =  NVL(l_legislation_code,'~NULL~')
            AND    ( ( nvl(l_new_business_group_id, -1) = nvl(business_group_id , -1)) or
           ( p_business_group is null and business_group_id is null ) ) ;

           --AND    nvl( l_new_business_group_id, -1) = nvl(business_group_id , -1) ;
           --AND   data_elmt_rl = l_formula_id;

         -- UPDATE
         -- the element may be found there may be changes in data element attribute
         -- if the record found the the element is updated
         --- Dont update for the custome record used can changed the record
         --  more over thge record may be linked to some other  extrcact defintion
         --  since the forword element reference fixed there is possible
         --  element created for forwored purpose, so update the element
         -- if element exisit and comming element is for forward regerence then dont update
         if (l_new_business_group_id is null or g_override = 'Y'  or l_string = '$FORWARD$')
              and nvl(p_string_val,' ') <> '$FORWARD$'  then
            ben_xel_upd.upd(
                     p_effective_date        => trunc(sysdate)
                    ,p_ext_data_elmt_id      => l_tmp_id
                    ,p_ttl_fnctn_cd          => p_ttl_fnctn_cd
                    ,p_ttl_cond_oper_cd      => p_ttl_cond_oper_cd
                    ,p_ttl_cond_val          => p_ttl_cond_val
                    ,p_data_elmt_typ_cd      => p_data_elmt_typ_cd
                    ,p_ext_fld_id            => null
                    ,p_data_elmt_rl          => l_formula_id
                    ,p_frmt_mask_cd          => p_frmt_mask_cd
                    ,p_string_val            => p_string_val
                    ,p_dflt_val              => p_dflt_val
                    ,p_max_length_num        => p_max_length_num
                    ,p_just_cd               => p_just_cd
                    ,p_legislation_code      => l_legislation_code
                    ,p_business_group_id     => l_new_business_group_id
                    ,p_last_update_date      => l_last_update_date
                    ,p_creation_date         => l_last_update_date
                    ,p_last_update_login     => 0
                    ,p_created_by            => l_last_updated_by
                    ,p_last_updated_by       => l_last_updated_by
                    ,p_object_version_number => l_tmp_ovn
                    ,p_xml_tag_name          => p_xml_tag_name );
          end if ;

        EXCEPTION
           WHEN NO_DATA_FOUND THEN
           ben_xel_ins.ins(p_effective_date  => trunc(sysdate)
                    ,p_ext_data_elmt_id      => l_ext_data_elmt_id
                    ,p_name                  => p_data_elemt_name
                    ,p_ttl_fnctn_cd          => p_ttl_fnctn_cd
                    ,p_ttl_cond_oper_cd      => p_ttl_cond_oper_cd
                    ,p_ttl_cond_val          => p_ttl_cond_val
                    ,p_data_elmt_typ_cd      => p_data_elmt_typ_cd
                    ,p_ext_fld_id            => null
                    ,p_data_elmt_rl          => l_formula_id
                    ,p_frmt_mask_cd          => p_frmt_mask_cd
                    ,p_string_val            => p_string_val
                    ,p_dflt_val              => p_dflt_val
                    ,p_max_length_num        => p_max_length_num
                    ,p_just_cd               => p_just_cd
                    ,p_legislation_code      => l_legislation_code
                    ,p_business_group_id     => l_new_business_group_id
                    ,p_last_update_date      => l_last_update_date
                    ,p_creation_date         => l_last_update_date
                    ,p_last_update_login     => 0
                    ,p_created_by            => l_last_updated_by
                    ,p_last_updated_by       => l_last_updated_by
                    ,p_object_version_number => l_object_version_number
                    ,p_xml_tag_name         => p_xml_tag_name );
        END;
     ELSIF p_data_elmt_typ_cd = 'S' then
        BEGIN
           l_tmp_id  := null ;
           l_tmp_ovn := null ;
           SELECT ext_data_elmt_id , object_version_number,string_val
           INTO l_tmp_id , l_tmp_ovn,l_string
           FROM ben_ext_data_elmt
           WHERE name = p_data_elemt_name
            AND    ( ( nvl(l_new_business_group_id, -1) = nvl(business_group_id , -1)) or
           ( p_business_group is null and business_group_id is null ) )
           --AND   nvl( l_new_business_group_id, -1) = nvl(business_group_id , -1)
           AND   NVL(legislation_code,'~NULL~') =  NVL(l_legislation_code,'~NULL~');
           --AND   string_val = p_string_val;


         -- UPDATE
         -- the element may be found there may be changes in data element attribute
         -- if the record found the the element is updated
         -- Dont update for the custome record used can changed the record
         --  more over thge record may be linked to some other  extrcact defintion
         if (l_new_business_group_id is null or g_override = 'Y' or l_string = '$FORWARD$' )
             and nvl(p_string_val,' ') <> '$FORWARD$'  then
            ben_xel_upd.upd(
                     p_effective_date            => l_last_update_date
                    ,p_ext_data_elmt_id          => l_tmp_id
                    ,p_ttl_fnctn_cd              => p_ttl_fnctn_cd
                    ,p_ttl_cond_oper_cd          => p_ttl_cond_oper_cd
                    ,p_ttl_cond_val              => p_ttl_cond_val
                    ,p_data_elmt_typ_cd          => p_data_elmt_typ_cd
                    ,p_frmt_mask_cd              => p_frmt_mask_cd
                    ,p_string_val                => p_string_val
                    ,p_dflt_val                  => p_dflt_val
                    ,p_max_length_num            => p_max_length_num
                    ,p_just_cd                   => p_just_cd
                    ,p_legislation_code          => l_legislation_code
                    ,p_business_group_id         => l_new_business_group_id
                    ,p_last_update_date          => l_last_update_date
                    ,p_creation_date             => l_last_update_date
                    ,p_last_update_login         => 0
                    ,p_created_by                => l_last_updated_by
                    ,p_last_updated_by           => l_last_updated_by
                    ,p_object_version_number     => l_tmp_ovn
                    ,p_xml_tag_name              => p_xml_tag_name );
        end if ;

        EXCEPTION
           WHEN NO_DATA_FOUND THEN
              ben_xel_ins.ins(p_effective_date        => l_last_update_date
                    ,p_ext_data_elmt_id      => l_ext_data_elmt_id
                    ,p_name                  => p_data_elemt_name
                    ,p_ttl_fnctn_cd          => p_ttl_fnctn_cd
                    ,p_ttl_cond_oper_cd      => p_ttl_cond_oper_cd
                    ,p_ttl_cond_val          => p_ttl_cond_val
                    ,p_data_elmt_typ_cd      => p_data_elmt_typ_cd
                    ,p_ext_fld_id            => null
                    ,p_data_elmt_rl          => null
                    ,p_frmt_mask_cd          => p_frmt_mask_cd
                    ,p_string_val            => p_string_val
                    ,p_dflt_val              => p_dflt_val
                    ,p_max_length_num        => p_max_length_num
                    ,p_just_cd               => p_just_cd
                    ,p_legislation_code      => l_legislation_code
                    ,p_business_group_id     => l_new_business_group_id
                    ,p_last_update_date      => l_last_update_date
                    ,p_creation_date         => l_last_update_date
                    ,p_last_update_login     => 0
                    ,p_created_by            => l_last_updated_by
                    ,p_last_updated_by       => l_last_updated_by
                    ,p_object_version_number => l_object_version_number
                    ,p_xml_tag_name          => p_xml_tag_name );
        END;
     END IF;
  ELSIF p_data_elmt_typ_cd in ( 'T','C')  THEN
     BEGIN
        --- there is possible element creatd for forward reason
        if p_parent_record_name is not null then
           SELECT ext_rcd_id
           INTO   l_ext_rcd_id
           FROM   ben_ext_rcd
           WHERE  name = p_parent_record_name
           AND   nvl( l_new_business_group_id, -1) = nvl(business_group_id , -1)
           AND   NVL(legislation_code,'~NULL~') =  NVL(l_legislation_code,'~NULL~');
        end if ;
     EXCEPTION
        WHEN NO_DATA_FOUND THEN
        --    RAISE;
        raise_application_error(-20001,'No parent record element '||p_data_elemt_name||
          ' legislation code '||l_legislation_code||' parent : '||p_parent_record_name);
     END;
     BEGIN

        IF p_parent_data_element <> 'NULL' THEN
           SELECT ext_data_elmt_id
           INTO   l_parent_data_elmt_id
           FROM   ben_ext_data_elmt
           WHERE  name = p_parent_data_element
            AND    ( ( nvl(l_new_business_group_id, -1) = nvl(business_group_id , -1)) or
           ( p_business_group is null and business_group_id is null ) )
           --AND   nvl( l_new_business_group_id, -1) = nvl(business_group_id , -1)
           AND   NVL(legislation_code,'~NULL~') =  NVL(l_legislation_code,'~NULL~');
        ELSE
           l_parent_data_elmt_id := NULL;
        END IF;

     EXCEPTION
        WHEN NO_DATA_FOUND THEN
           raise_application_error(-20001,'No parent data element '||p_data_elemt_name||
               ' legislation code '||l_legislation_code||' parent : '|| p_parent_data_element);
     END;
     BEGIN
        l_tmp_id  := null ;
        l_tmp_ovn := null ;
        SELECT ext_data_elmt_id , object_version_number,string_val
        INTO l_tmp_id , l_tmp_ovn ,l_string
        FROM ben_ext_data_elmt
        WHERE name = p_data_elemt_name
         AND    ( ( nvl(l_new_business_group_id, -1) = nvl(business_group_id , -1)) or
           ( p_business_group is null and business_group_id is null ) )
        AND   NVL(legislation_code,'~NULL~') =  NVL(l_legislation_code,'~NULL~');

        --- UPDATE
        --- the element may be found there may be changes in data element attribute
        --- if the record found the the element is updated
         --- Dont update for the custome record used can changed the record
         --  more over thge record may be linked to some other  extrcact defintion
         if (l_new_business_group_id is null or g_override = 'Y' or l_string = '$FORWARD$' )
             and nvl(p_string_val,' ') <> '$FORWARD$'   then

             ben_xel_upd.upd(
                     p_effective_date            => l_last_update_date
                    ,p_ext_data_elmt_id          => l_tmp_id
                    ,p_ttl_cond_ext_data_elmt_id => l_ext_rcd_id
                    ,p_ttl_sum_ext_data_elmt_id  => l_parent_data_elmt_id
                    ,p_ttl_fnctn_cd              => p_ttl_fnctn_cd
                    ,p_ttl_cond_oper_cd          => p_ttl_cond_oper_cd
                    ,p_ttl_cond_val              => p_ttl_cond_val
                    ,p_data_elmt_typ_cd          => p_data_elmt_typ_cd
                    ,p_frmt_mask_cd              => p_frmt_mask_cd
                    ,p_dflt_val                  => p_dflt_val
                    ,p_max_length_num            => p_max_length_num
                    ,p_just_cd                   => p_just_cd
                    ,p_legislation_code          => l_legislation_code
                    ,p_business_group_id         => l_new_business_group_id
                    ,p_last_update_date          => l_last_update_date
                    ,p_creation_date             => l_last_update_date
                    ,p_last_update_login         => 0
                    ,p_created_by                => l_last_updated_by
                    ,p_last_updated_by           => l_last_updated_by
                    ,p_object_version_number     => l_tmp_ovn
                    ,p_xml_tag_name              => p_xml_tag_name);
        end if ;

     EXCEPTION WHEN NO_DATA_FOUND THEN
        ben_xel_ins.ins(p_effective_date         => l_last_update_date
                    ,p_ext_data_elmt_id          => l_ext_data_elmt_id
                    ,p_name                      => p_data_elemt_name
                    ,p_ttl_cond_ext_data_elmt_id => l_ext_rcd_id
                    ,p_ttl_sum_ext_data_elmt_id  => l_parent_data_elmt_id
                    ,p_ttl_fnctn_cd              => p_ttl_fnctn_cd
                    ,p_ttl_cond_oper_cd          => p_ttl_cond_oper_cd
                    ,p_ttl_cond_val              => p_ttl_cond_val
                    ,p_data_elmt_typ_cd          => p_data_elmt_typ_cd
                    ,p_ext_fld_id                => NULL
                    ,p_data_elmt_rl              => NULL
                    ,p_frmt_mask_cd              => p_frmt_mask_cd
                    ,p_string_val                => NULL
                    ,p_dflt_val                  => p_dflt_val
                    ,p_max_length_num            => p_max_length_num
                    ,p_just_cd                   => p_just_cd
                    ,p_legislation_code          => l_legislation_code
                    ,p_business_group_id         => l_new_business_group_id
                    ,p_last_update_date          => l_last_update_date
                    ,p_creation_date             => l_last_update_date
                    ,p_last_update_login         => 0
                    ,p_created_by                => l_last_updated_by
                    ,p_last_updated_by           => l_last_updated_by
                    ,p_object_version_number     => l_object_version_number
                    ,p_xml_tag_name              => p_xml_tag_name );
     WHEN OTHERS THEN
        RAISE;
     END;
  ELSIF p_data_elmt_typ_cd =  'P'   THEN    -- payroll balance
      if p_defined_balance is not null then

        Declare
           cursor c_pay_bal is
           select c.defined_balance_id ID
           from  pay_defined_balances c ,
                 pay_balance_types    a ,
                 pay_balance_dimensions b
           where
                 a.balance_type_id = c.balance_type_id
             and c.balance_dimension_id = b.balance_dimension_id
             and b.dimension_level in ( 'PER' ,'ASG')
             and a.balance_name || '   [ ' || b.dimension_name || ' ]' = p_defined_balance
             AND   ( NVL(a.legislation_code,'~NULL~') =  NVL(l_legislation_code,'~NULL~') or l_legislation_code is null )
             AND  ( ( nvl(l_new_business_group_id, -1) = nvl(a.business_group_id , nvl(l_new_business_group_id, -1))) or
                  ( p_business_group is null and a.business_group_id is null ) ) ;


        Begin

           open c_pay_bal ;
           fetch c_pay_bal into l_defined_balance_id ;
           if  c_pay_bal%notfound then
               close c_pay_bal ;

               raise_application_error(-20001,' No Payroll Defined Balance '||
               p_defined_balance ||' legislation code '||l_legislation_code);
           end if ;

           l_tmp_id  := null ;
           l_tmp_ovn := null ;
           SELECT ext_data_elmt_id , object_version_number ,string_val
           INTO    l_tmp_id , l_tmp_ovn,l_string
           FROM   ben_ext_data_elmt
           WHERE name = p_data_elemt_name
            AND    ( ( nvl(l_new_business_group_id, -1) = nvl(business_group_id , -1)) or
             ( p_business_group is null and business_group_id is null ) )
           AND    NVL(legislation_code,'~NULL~') =  NVL(l_legislation_code,'~NULL~');


           -- UPDATE
           -- the element may be found there may be changes in data element attribute
           -- if the record found the the element is updated
              --- Dont update for the custome record used can changed the record
           --  more over thge record may be linked to some other  extrcact defintion
           if (l_new_business_group_id is null or g_override = 'Y'  or l_string = '$FORWARD$' )
               and nvl(p_string_val,' ') <> '$FORWARD$' then
              ben_xel_upd.upd(
                     p_effective_date            => l_last_update_date
                    ,p_ext_data_elmt_id          => l_tmp_id
                    ,p_ttl_fnctn_cd              => p_ttl_fnctn_cd
                    ,p_ttl_cond_oper_cd          => p_ttl_cond_oper_cd
                    ,p_ttl_cond_val              => p_ttl_cond_val
                    ,p_data_elmt_typ_cd          => p_data_elmt_typ_cd
                    ,p_ext_fld_id                => l_ext_field_id
                    ,p_string_val                => p_string_val
                    ,p_frmt_mask_cd              => p_frmt_mask_cd
                    ,p_dflt_val                  => p_dflt_val
                    ,p_max_length_num            => p_max_length_num
                    ,p_just_cd                   => p_just_cd
                    ,p_legislation_code          => l_legislation_code
                    ,p_business_group_id         => l_new_business_group_id
                    ,p_last_update_date          => l_last_update_date
                    ,p_creation_date             => l_last_update_date
                    ,p_last_update_login         => 0
                    ,p_created_by                => l_last_updated_by
                    ,p_last_updated_by           => l_last_updated_by
                    ,p_object_version_number     => l_tmp_ovn
                    ,p_defined_balance_id        => l_defined_balance_id
                    ,p_xml_tag_name             => p_xml_tag_name);

           end if ;

           EXCEPTION
           WHEN NO_DATA_FOUND THEN
             ben_xel_ins.ins(p_effective_date        => l_last_update_date
                    ,p_ext_data_elmt_id      => l_ext_data_elmt_id
                    ,p_name                  => p_data_elemt_name
                    ,p_ttl_fnctn_cd          => p_ttl_fnctn_cd
                    ,p_ttl_cond_oper_cd      => p_ttl_cond_oper_cd
                    ,p_ttl_cond_val          => p_ttl_cond_val
                    ,p_data_elmt_typ_cd      => p_data_elmt_typ_cd
                    ,p_ext_fld_id            => l_ext_field_id
                    ,p_data_elmt_rl          => null -- p_data_elmt_rl
                    ,p_frmt_mask_cd          => p_frmt_mask_cd
                    ,p_string_val            => p_string_val
                    ,p_dflt_val              => p_dflt_val
                    ,p_max_length_num        => p_max_length_num
                    ,p_just_cd               => p_just_cd
                    ,p_legislation_code      => l_legislation_code
                    ,p_business_group_id     => l_new_business_group_id
                    ,p_last_update_date      => l_last_update_date
                    ,p_creation_date         => l_last_update_date
                    ,p_last_update_login     => 0
                    ,p_created_by            => l_last_updated_by
                    ,p_last_updated_by       => l_last_updated_by
                    ,p_object_version_number => l_object_version_number
                    ,p_defined_balance_id    => l_defined_balance_id
                    ,p_xml_tag_name          => p_xml_tag_name);
           WHEN OTHERS THEN
             RAISE;
        end ;

      end if ; -- p_data_elmt_typ_cd
  ELSE
     BEGIN
        SELECT ext_fld_id
        INTO   l_ext_field_id
        FROM   ben_ext_fld
        WHERE  short_name = p_field_short_name;
     EXCEPTION
         WHEN NO_DATA_FOUND THEN
         RAISE;
     END;

     BEGIN
         l_tmp_id  := null ;
         l_tmp_ovn := null ;
         SELECT ext_data_elmt_id , object_version_number ,string_val
         INTO    l_tmp_id , l_tmp_ovn,l_string
         FROM   ben_ext_data_elmt
         WHERE name = p_data_elemt_name
          AND    ( ( nvl(l_new_business_group_id, -1) = nvl(business_group_id , -1)) or
           ( p_business_group is null and business_group_id is null ) )
         AND    NVL(legislation_code,'~NULL~') =  NVL(l_legislation_code,'~NULL~');


         -- UPDATE
         -- the element may be found there may be changes in data element attribute
         -- if the record found the the element is updated
          --- Dont update for the custome record used can changed the record
         --  more over thge record may be linked to some other  extrcact defintion
         if (l_new_business_group_id is null or g_override = 'Y' or l_string = '$FORWARD$' )
              and nvl(p_string_val,' ') <> '$FORWARD$' then
            ben_xel_upd.upd(
                     p_effective_date            => l_last_update_date
                    ,p_ext_data_elmt_id          => l_tmp_id
                    ,p_ttl_fnctn_cd              => p_ttl_fnctn_cd
                    ,p_ttl_cond_oper_cd          => p_ttl_cond_oper_cd
                    ,p_ttl_cond_val              => p_ttl_cond_val
                    ,p_data_elmt_typ_cd          => p_data_elmt_typ_cd
                    ,p_ext_fld_id                => l_ext_field_id
                    ,p_string_val                => p_string_val
                    ,p_frmt_mask_cd              => p_frmt_mask_cd
                    ,p_dflt_val                  => p_dflt_val
                    ,p_max_length_num            => p_max_length_num
                    ,p_just_cd                   => p_just_cd
                    ,p_legislation_code          => l_legislation_code
                    ,p_business_group_id         => l_new_business_group_id
                    ,p_last_update_date          => l_last_update_date
                    ,p_creation_date             => l_last_update_date
                    ,p_last_update_login         => 0
                    ,p_created_by                => l_last_updated_by
                    ,p_last_updated_by           => l_last_updated_by
                    ,p_object_version_number     => l_tmp_ovn
                    ,p_xml_tag_name             => p_xml_tag_name);

         end if ;

     EXCEPTION
         WHEN NO_DATA_FOUND THEN
             ben_xel_ins.ins(p_effective_date        => l_last_update_date
                    ,p_ext_data_elmt_id      => l_ext_data_elmt_id
                    ,p_name                  => p_data_elemt_name
                    ,p_ttl_fnctn_cd          => p_ttl_fnctn_cd
                    ,p_ttl_cond_oper_cd      => p_ttl_cond_oper_cd
                    ,p_ttl_cond_val          => p_ttl_cond_val
                    ,p_data_elmt_typ_cd      => p_data_elmt_typ_cd
                    ,p_ext_fld_id            => l_ext_field_id
                    ,p_data_elmt_rl          => null -- p_data_elmt_rl
                    ,p_frmt_mask_cd          => p_frmt_mask_cd
                    ,p_string_val            => p_string_val
                    ,p_dflt_val              => p_dflt_val
                    ,p_max_length_num        => p_max_length_num
                    ,p_just_cd               => p_just_cd
                    ,p_legislation_code      => l_legislation_code
                    ,p_business_group_id     => l_new_business_group_id
                    ,p_last_update_date      => l_last_update_date
                    ,p_creation_date         => l_last_update_date
                    ,p_last_update_login     => 0
                    ,p_created_by            => l_last_updated_by
                    ,p_last_updated_by       => l_last_updated_by
                    ,p_object_version_number => l_object_version_number
                    ,p_xml_tag_name          => p_xml_tag_name);
         WHEN OTHERS THEN
             RAISE;
     END;
 END IF;
  hr_utility.set_location(' Leaving ' || l_proc, 10);
END load_ext_data_elmt;

--
PROCEDURE load_ext_data_elmt_in_rcd(p_data_element_name  IN VARCHAR2
                                   ,p_record_name        IN VARCHAR2
                                   ,p_owner              IN VARCHAR2
                                   ,p_last_update_date   IN VARCHAR2
                                   ,p_rqd_flag           IN VARCHAR2
                                   ,p_hide_flag          IN VARCHAR2
                                   ,p_seq_num            IN VARCHAR2
                                   ,p_strt_pos           IN VARCHAR2
                                   ,p_dlmtr_val          IN VARCHAR2
                                   ,p_sprs_cd            IN VARCHAR2
                                   ,p_any_or_all_cd      IN VARCHAR2
                                   ,p_legislation_code   IN VARCHAR2
                                   ,p_business_group     in VARCHAR2
                                    ) IS
--
l_ext_rcd_id                   NUMBER;
l_ext_data_elmt_id             NUMBER;
l_ext_data_elmt_in_rcd_id      NUMBER;
l_object_version_number        NUMBER;
l_legislation_code             VARCHAR2(240) := p_legislation_code; --utf8
l_temp                         VARCHAR2(1);
l_last_update_date             DATE;
l_last_updated_by              NUMBER;
l_new_business_group_id        number ;
l_ovn                          number ;
l_STRT_POS                     ben_ext_data_elmt_in_rcd.STRT_POS%type ;
l_DLMTR_VAL                    ben_ext_data_elmt_in_rcd.DLMTR_VAL%type ;
l_HIDE_FLAG                    ben_ext_data_elmt_in_rcd.HIDE_FLAG%type ;
l_RQD_FLAG                     ben_ext_data_elmt_in_rcd.RQD_FLAG%type ;
l_sprs_cd                      ben_ext_data_elmt_in_rcd.sprs_cd%type ;
  l_proc                   varchar2(100) := 'BEN_EXT_SEED.load_ext_data_elmt_in_rcd' ;
BEGIN
   hr_utility.set_location(' Entering ' || l_proc, 10);
   get_who_values(p_owner             => p_owner
                ,p_last_update_vc    => p_last_update_date
                ,p_last_update_date  => l_last_update_date
                ,p_last_updated_by   => l_last_updated_by
                ,p_legislation_code  => l_legislation_code
                ,p_business_group    => p_business_group
                ,p_business_group_id => l_new_business_group_id );

  BEGIN

    SELECT ext_rcd_id
    INTO   l_ext_rcd_id
    FROM   ben_ext_rcd
    WHERE  name = p_record_name
    AND    NVL(legislation_code,'~NVL~') = NVL(l_legislation_code,'~NVL~')
    AND    nvl( l_new_business_group_id, -1) = nvl(business_group_id , -1) ;
  EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RAISE;
  END;
  BEGIN
    SELECT ext_data_elmt_id
    INTO   l_ext_data_elmt_id
    FROM   ben_ext_data_elmt
    WHERE  name = p_data_element_name
     AND    ( ( nvl(l_new_business_group_id, -1) = nvl(business_group_id , -1)) or
           ( p_business_group is null and business_group_id is null ) )
    --AND    nvl( l_new_business_group_id, -1) = nvl(business_group_id , -1)
    AND    NVL(legislation_code,'~NULL~') =  NVL(l_legislation_code,'~NULL~');
  EXCEPTION
      WHEN NO_DATA_FOUND THEN
        --RAISE;
        raise_application_error(-20001,'Data element '||p_data_element_name|| '
 legislation code '||l_legislation_code);
  END;
  BEGIN
    SELECT OBJECT_VERSION_NUMBER,
           EXT_DATA_ELMT_IN_RCD_ID,
           STRT_POS ,
           DLMTR_VAL,
           RQD_FLAG,
           HIDE_FLAG,
           SPRS_CD
    INTO   l_ovn,
           l_EXT_DATA_ELMT_IN_RCD_ID,
           l_STRT_POS ,
           l_DLMTR_VAL,
           l_RQD_FLAG ,
           l_HIDE_FLAG,
           l_SPRS_CD
    FROM   ben_ext_data_elmt_in_rcd
    WHERE  ext_rcd_id                    = l_ext_rcd_id
    AND    ext_data_elmt_id              = l_ext_data_elmt_id
    AND    nvl( l_new_business_group_id, -1) = nvl(business_group_id , -1)
    AND    NVL(legislation_code,'~NVL~') = NVL(l_legislation_code,'~NVL~')
    AND    NVL(seq_num,-987123654) = NVL(p_seq_num,-987123654);

    --- whne the  extract is global and delimiter or start postion changed
    --- then update the extract

    if   ( l_new_business_group_id is null or g_override = 'Y') and
        ( nvl(l_STRT_POS,'-1')  <> nvl(p_STRT_POS,'-1')   or
          nvl(l_DLMTR_VAL,'-1')  <> nvl(p_DLMTR_VAL,'-1') or
          nvl(l_rqd_FLAG,'N')  <> nvl(p_rqd_FLAG,'N')   OR
          nvl(l_SPRS_CD,'-1')  <> nvl(p_SPRS_CD,'-1')   OR
          nvl(l_HIDE_FLAG,'N')  <> nvl(p_HIDE_FLAG,'N')
         ) then


       ben_xer_upd.upd(p_effective_date        => l_last_update_date
                    ,p_ext_data_elmt_in_rcd_id => l_ext_data_elmt_in_rcd_id
                    ,p_business_group_id       => l_new_business_group_id
                    ,p_legislation_code        => l_legislation_code
                    ,p_rqd_flag                => p_rqd_flag
                    ,p_hide_flag               => p_hide_flag
                    ,p_strt_pos                => p_strt_pos
                    ,p_dlmtr_val               => p_dlmtr_val
                    ,p_SPRS_CD                => p_SPRS_CD
                    ,p_object_version_number   => l_ovn);


    end if ;

    -- seq_num should not be null but since the column is nullable put nvl check
    -- what this change does mean is that if this data element does exist
    -- at the specified seq_num then no action will take place
    -- effectively we cannot update attributes of data element in rcd
    -- needs enhancement.
  EXCEPTION
    WHEN NO_DATA_FOUND THEN

     /*  If the Same Sequence Find Delete the Record for the Sequence  */

     Declare


       cursor c_ext_where_clause (p_ext_data_elmt_in_rcd_id number)  is
       select ext_where_clause_id,object_version_number
       from ben_ext_where_clause
       where ext_data_elmt_in_rcd_id = p_ext_data_elmt_in_rcd_id;

       cursor c_ext_incl_chg_id (p_ext_data_elmt_in_rcd_id number)  is
        select ext_incl_chg_id,object_version_number
         from ben_ext_incl_chg
       where ext_data_elmt_in_rcd_id = p_ext_data_elmt_in_rcd_id;

       l_obj_ver_number   number ;

       cursor c_elmt_del1 (c_ext_data_elmt_id  number ,
                           c_Ext_rcd_id        number )  is
       select object_version_number,ext_data_elmt_in_rcd_id
        from ben_ext_data_elmt_in_rcd
        where  ext_data_elmt_id       <> nvl(c_ext_data_elmt_id,-1)
         and   ext_rcd_id              = c_ext_rcd_id
         and   seq_num                 = p_seq_num ;


     Begin

       open   c_elmt_del1(l_ext_data_elmt_id,l_ext_rcd_id)  ;
       fetch  c_elmt_del1 into l_object_version_number,l_ext_data_elmt_in_rcd_id ;
       if  c_elmt_del1%found then
         /*  if the sequence found delete the old  reco   */
         -- before deleting  make sure the chile in where and inclusion are deleted

         if  ( l_new_business_group_id is null  or g_override = 'Y' ) then
             --- delete where clause of the data element in rcd
             for i in  c_ext_where_clause( l_ext_data_elmt_in_rcd_id)
             Loop
                l_obj_ver_number := i.object_version_number ;

                ben_xwc_del.del
                           (
                             p_effective_date        =>  trunc(sysdate),
                             p_ext_where_clause_id   =>  i.ext_where_clause_id ,
                             p_object_version_number =>  l_obj_ver_number
                           )  ;
             end Loop ;

             -- delete the inclusion element of the data element in rcd
             for i in  c_ext_incl_chg_id(l_ext_data_elmt_in_rcd_id)
             Loop
                l_obj_ver_number := i.object_version_number ;

                ben_xic_del.del
                           (
                             p_effective_date        =>  trunc(sysdate),
                             p_ext_incl_chg_id       =>  i.ext_incl_chg_id ,
                             p_object_version_number =>  l_obj_ver_number
                           )  ;
             end Loop ;

             -- delete the data elmt in rcd for order change

              ben_xer_del.del(p_effective_date        => l_last_update_date
                      ,p_ext_data_elmt_in_rcd_id    => l_ext_data_elmt_in_rcd_id
                      ,p_object_version_number => l_object_version_number);
         end if ;
       end if ;
       close  c_elmt_del1 ;
     Exception
        WHEN NO_DATA_FOUND THEN
             null ;
       When Others then
         RAISE ;
     End ;
     /* Deletion part is over for duplicate seq number */

       ben_xer_ins.ins(p_effective_date          => l_last_update_date
                    ,p_ext_data_elmt_in_rcd_id => l_ext_data_elmt_in_rcd_id
                    ,p_business_group_id       => l_new_business_group_id
                    ,p_ext_data_elmt_id        => l_ext_data_elmt_id
                    ,p_ext_rcd_id              => l_ext_rcd_id
                    ,p_legislation_code        => l_legislation_code
                    ,p_rqd_flag                => p_rqd_flag
                    ,p_hide_flag               => p_hide_flag
                    ,p_strt_pos                => p_strt_pos
                    ,p_dlmtr_val               => p_dlmtr_val
                    ,p_sprs_cd                 => p_sprs_cd
                    ,p_seq_num                 => p_seq_num
                    ,p_any_or_all_cd           => p_any_or_all_cd
                    ,p_last_update_date        => l_last_update_date
                    ,p_creation_date           => l_last_update_date
                    ,p_last_update_login       => 0
                    ,p_created_by              => l_last_updated_by
                    ,p_last_updated_by         => l_last_updated_by
                    ,p_object_version_number   => l_object_version_number);

 END;
  hr_utility.set_location(' Leaving ' || l_proc, 10);
END load_ext_data_elmt_in_rcd;

PROCEDURE load_ext_where_clause(p_data_elmt_name         IN VARCHAR2
                               ,p_record_name            IN VARCHAR2
                               ,p_file_name              IN VARCHAR2 DEFAULT NULL
                               ,p_record_data_elmt_name  IN VARCHAR2 DEFAULT NULL
                               ,p_cond_ext_data_elmt_name IN VARCHAR2 DEFAULT NULL
                               ,p_owner                  IN VARCHAR2
                               ,p_last_update_date       IN VARCHAR2
                               ,p_seq_num                IN VARCHAR2
                               ,p_oper_cd                IN VARCHAR2
                               ,p_val                    IN VARCHAR2
                               ,p_and_or_cd              IN VARCHAR2
                               ,p_legislation_code       IN VARCHAR2
                               ,p_business_group         IN VARCHAR2
                               ) is
l_ext_file_id                    NUMBER;
l_ext_rcd_id                     NUMBER;
l_ext_data_elmt_id               NUMBER;
l_cond_ext_data_elmt_id          NUMBER;
l_ext_rcd_in_file_id             NUMBER;
l_ext_data_elmt_in_rcd_id        NUMBER;
l_cond_ext_data_elmt_in_rcd_id        NUMBER;
l_ext_where_clause_id            NUMBER;
l_object_version_number          NUMBER;
l_legislation_code               VARCHAR2(240) := p_legislation_code; -- utf8
l_temp                           VARCHAR2(1);
l_last_update_date               DATE;
l_last_updated_by                NUMBER;
l_new_business_group_id          NUMBER;
l_record_data_elmt_name          varchar2(600)   ;

  l_proc                   varchar2(100) := 'BEN_EXT_SEED.load_ext_where_clause' ;
BEGIN
  hr_utility.set_location(' Entering ' || l_proc, 10);
  get_who_values(p_owner            => p_owner
                ,p_last_update_vc   => p_last_update_date
                ,p_last_update_date => l_last_update_date
                ,p_last_updated_by  => l_last_updated_by
                ,p_legislation_code => l_legislation_code
                ,p_business_group    => p_business_group
                ,p_business_group_id => l_new_business_group_id );

  l_record_data_elmt_name :=  nvl(p_record_data_elmt_name,p_data_elmt_name);

  if p_record_name is not null then
     BEGIN
       SELECT ext_rcd_id
       INTO   l_ext_rcd_id
       FROM   ben_ext_rcd
       WHERE  name = p_record_name
       AND    NVL(legislation_code,'~NVL~') = NVL(l_legislation_code,'~NVL~')
       AND    nvl( l_new_business_group_id, -1) = nvl(business_group_id , -1)
       ;
     EXCEPTION
         WHEN NO_DATA_FOUND THEN

           RAISE;
     END;
  end if ;

  IF p_file_name IS NOT NULL THEN
     BEGIN
       SELECT ext_file_id
       INTO   l_ext_file_id
       FROM   ben_ext_file
       WHERE  name = p_file_name
       AND    NVL(legislation_code,'~NVL~') = NVL(l_legislation_code,'~NVL~')
       AND    nvl( l_new_business_group_id, -1) = nvl(business_group_id , -1)
       ;
     EXCEPTION
         WHEN NO_DATA_FOUND THEN
           RAISE;
     END;
     BEGIN
       SELECT ext_rcd_in_file_id
       INTO   l_ext_rcd_in_file_id
       FROM   ben_ext_rcd_in_file
       WHERE  ext_file_id             = l_ext_file_id
       AND    ext_rcd_id              = l_ext_rcd_id
       AND    nvl( l_new_business_group_id, -1) = nvl(business_group_id , -1)
       AND    NVL(legislation_code,'~NULL~') =  NVL(l_legislation_code,'~NULL~');
     EXCEPTION
         WHEN NO_DATA_FOUND THEN
           RAISE;
     END;
  ELSE
    l_ext_file_id        := NULL;
    l_ext_rcd_in_file_id := NULL;
  END IF;

  BEGIN
    SELECT ext_data_elmt_id
    INTO   l_ext_data_elmt_id
    FROM   ben_ext_data_elmt
    WHERE  name = p_data_elmt_name
    AND    ( ( nvl(l_new_business_group_id, -1) = nvl(business_group_id , -1)) or
           ( p_business_group is null and business_group_id is null ) )
    AND    NVL(legislation_code,'~NULL~') =  NVL(l_legislation_code,'~NULL~')
    ;

  EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RAISE;
  END;

  if p_cond_ext_data_elmt_name is not null then
     BEGIN
       SELECT ext_data_elmt_id
       INTO   l_cond_ext_data_elmt_id
       FROM   ben_ext_data_elmt
       WHERE  name = p_cond_ext_data_elmt_name
        AND    ( ( nvl(l_new_business_group_id, -1) = nvl(business_group_id , -1)) or
           ( p_business_group is null and business_group_id is null ) )
       --AND    nvl( l_new_business_group_id, -1) = nvl(business_group_id , -1)
       AND    NVL(legislation_code,'~NULL~') =  NVL(l_legislation_code,'~NULL~')
      ;
     EXCEPTION
         WHEN NO_DATA_FOUND THEN
         RAISE;
     END;
  end if ;

  if p_record_name is not null then

     BEGIN
       -- the element in record may attched to different element for advance conditions
       -- the first select get the  element in record
       SELECT ext_data_elmt_in_rcd_id
       INTO   l_ext_data_elmt_in_rcd_id
       FROM   ben_ext_data_elmt_in_rcd rcd,
              ben_ext_data_elmt elmt
       WHERE  rcd.ext_rcd_id                    = l_ext_rcd_id
       and    elmt.name                         = l_record_data_elmt_name
       AND    rcd.ext_data_elmt_id              = elmt.ext_data_elmt_id
       AND    nvl( l_new_business_group_id, -1) = nvl(rcd.business_group_id , -1)
       AND    nvl( l_new_business_group_id, -1) = nvl(elmt.business_group_id , -1)
       AND    NVL(rcd.legislation_code,'~NVL~') = NVL(l_legislation_code,'~NVL~')
       AND    NVL(elmt.legislation_code,'~NVL~')= NVL(l_legislation_code,'~NVL~');

       -- this select get the element in advance condition

       SELECT ext_data_elmt_in_rcd_id
       INTO   l_cond_ext_data_elmt_in_rcd_id
       FROM   ben_ext_data_elmt_in_rcd
       WHERE  ext_rcd_id                    = l_ext_rcd_id
       AND    ext_data_elmt_id              = l_ext_data_elmt_id
       AND    nvl(l_new_business_group_id, -1) = nvl(business_group_id , -1)
       AND    NVL(legislation_code,'~NVL~') = NVL(l_legislation_code,'~NVL~');


     EXCEPTION
         WHEN NO_DATA_FOUND THEN
           RAISE;
     END;
  end if ;


  BEGIN
     --- aded by tilek
     if p_file_name is not null then
        l_ext_data_elmt_id          := null ;
        l_ext_data_elmt_in_rcd_id := null ;

       SELECT 'Y'
       INTO   l_temp
       FROM   ben_ext_where_clause
       WHERE  cond_ext_data_elmt_in_rcd_id  = l_cond_ext_data_elmt_in_rcd_id
       AND    ext_rcd_in_file_id = l_ext_rcd_in_file_id
       AND    seq_num               = p_seq_num
       --AND    ext_data_elmt_in_rcd_id = l_ext_data_elmt_in_rcd_id
       AND    nvl( l_new_business_group_id, -1) = nvl(business_group_id , -1)
       AND    NVL(legislation_code,'~NULL~') =  NVL(l_legislation_code,'~NULL~');


     elsif  p_record_name is not null then
       l_ext_data_elmt_id          := null ;
       SELECT 'Y'
       INTO   l_temp
       FROM   ben_ext_where_clause
       WHERE  cond_ext_data_elmt_in_rcd_id  = l_cond_ext_data_elmt_in_rcd_id
       AND    seq_num               = p_seq_num
       AND    ext_data_elmt_in_rcd_id = l_ext_data_elmt_in_rcd_id
       AND    nvl( l_new_business_group_id, -1) = nvl(business_group_id , -1)
       AND    NVL(legislation_code,'~NULL~') =  NVL(l_legislation_code,'~NULL~');
   elsif p_cond_ext_data_elmt_name is not null then

       SELECT 'Y'
       INTO   l_temp
       FROM   ben_ext_where_clause
       WHERE  ext_data_elmt_id = l_ext_data_elmt_id
       AND    cond_ext_data_elmt_id = l_cond_ext_data_elmt_id
       AND    seq_num               = p_seq_num
       AND    nvl( l_new_business_group_id, -1) = nvl(business_group_id , -1)
       AND    NVL(legislation_code,'~NULL~') =  NVL(l_legislation_code,'~NULL~');


   end if ;

    EXCEPTION
      WHEN NO_DATA_FOUND
       THEN


        ---- Delete the Where condition if the same se exist with some othere values
        ---  or the values changed fue to the reordering of element or record

        Declare

           cursor c_xwc_dup_order (p_ext_rcd_in_file_id      number ,
                                   p_ext_data_elmt_in_rcd_id number,
                                   p_ext_data_elmt_id        number )  is
           SELECT ext_where_clause_id, object_version_number
           FROM ben_ext_where_clause xwc
           WHERE ( business_group_id is null
               or business_group_id = l_new_business_group_id )
           and (legislation_code is null
               or legislation_code = l_legislation_code )
           and (ext_rcd_in_file_id = p_ext_rcd_in_file_id
               or p_ext_rcd_in_file_id is null )
           and (ext_data_elmt_in_rcd_id  = p_ext_data_elmt_in_rcd_id
               or p_ext_data_elmt_in_rcd_id is null)
           and (ext_data_elmt_id = p_ext_data_elmt_id
               or p_ext_data_elmt_id is null)
           and seq_num = p_seq_num
             ;


           l_obj_ver_number  number  ;
        Begin

           for i in  c_xwc_dup_order ( p_ext_rcd_in_file_id => l_ext_rcd_in_file_id ,
                                       p_ext_data_elmt_in_rcd_id => l_ext_data_elmt_in_rcd_id ,
                                       p_ext_data_elmt_id        => l_ext_data_elmt_id )
           Loop
              l_obj_ver_number := i.object_version_number ;
               ben_xwc_del.del
                      (
                      p_effective_date        =>  trunc(sysdate),
                      p_ext_where_clause_id   =>  i.ext_where_clause_id ,
                      p_object_version_number =>  l_obj_ver_number
                   )  ;

           End Loop ;


        end  ;





       ben_xwc_ins.ins(p_effective_date          => l_last_update_date
                   ,p_ext_where_clause_id     => l_ext_where_clause_id
                   ,p_seq_num                 => p_seq_num
                   ,p_oper_cd                 => p_oper_cd
                   ,p_val                     => p_val
                   ,p_and_or_cd               => p_and_or_cd
                   ,p_ext_data_elmt_id        => l_ext_data_elmt_id
                   ,p_cond_ext_data_elmt_id   => l_cond_ext_data_elmt_id
                   ,p_ext_rcd_in_file_id      => l_ext_rcd_in_file_id
                   ,p_ext_data_elmt_in_rcd_id => l_ext_data_elmt_in_rcd_id
                   ,p_cond_ext_data_elmt_in_rcd_id => l_cond_ext_data_elmt_in_rcd_id
                   ,p_business_group_id       => l_new_business_group_id
                   ,p_legislation_code        => l_legislation_code
                   ,p_last_update_date        => l_last_update_date
                   ,p_creation_date           => l_last_update_date
                   ,p_last_updated_by         => l_last_updated_by
                   ,p_last_update_login       => 0
                   ,p_created_by              => l_last_updated_by
                   ,p_object_version_number   => l_object_version_number);
   WHEN OTHERS THEN
    RAISE;
  END;
   hr_utility.set_location(' Leaving ' || l_proc, 10);
END load_ext_where_clause;



PROCEDURE load_incl_chgs(p_data_elmt_name    IN VARCHAR2 DEFAULT NULL
                         ,p_record_name      IN VARCHAR2
                         ,p_file_name        IN VARCHAR2 DEFAULT NULL
                         ,p_chg_evt_cd       IN VARCHAR2
                         ,p_owner            IN VARCHAR2
                         ,p_last_update_date IN VARCHAR2
                         ,p_legislation_code IN VARCHAR2
                         ,p_business_group     in VARCHAR2
                         ,p_chg_evt_source   IN VARCHAR2 DEFAULT NULL
                         ) IS


--
cursor cw (c_code varchar2)
           is select 'x'
             from   hr_lookups
             where  lookup_type = 'BEN_EXT_CHG_EVT'
             and    lookup_code  = c_code
             and    enabled_flag = 'Y'
             and    trunc(sysdate) between nvl(start_date_active, trunc(sysdate))
                                 and nvl(end_date_active, trunc(sysdate))
             ;

--

l_ext_file_id             NUMBER;
l_ext_rcd_id              NUMBER;
l_ext_data_elmt_id        NUMBER;
l_ext_rcd_in_file_id      NUMBER;
l_ext_data_elmt_in_rcd_id NUMBER;
l_ext_incl_chg_id         NUMBER;
l_object_version_number   NUMBER;
l_legislation_code        VARCHAR2(240) := p_legislation_code; -- utf8
l_temp VARCHAR2(1);
l_last_update_date      DATE;
l_last_updated_by        NUMBER;
l_proc                   varchar2(100) := 'BEN_EXT_SEED.load_incl_chgs' ;
l_new_business_group_id number ;
l_chg_evt_cd             varchar2(80) ;
BEGIN
  hr_utility.set_location(' Entering ' || l_proc, 10);
   l_chg_evt_cd  := p_chg_evt_cd  ;
   get_who_values(p_owner             => p_owner
                ,p_last_update_vc    => p_last_update_date
                ,p_last_update_date  => l_last_update_date
                ,p_last_updated_by   => l_last_updated_by
                ,p_legislation_code  => l_legislation_code
                ,p_business_group    => p_business_group
                ,p_business_group_id => l_new_business_group_id );
  BEGIN
    SELECT ext_rcd_id
    INTO   l_ext_rcd_id
    FROM   ben_ext_rcd
    WHERE  name = p_record_name
    AND    NVL(legislation_code,'~NVL~') = NVL(l_legislation_code,'~NVL~')
    AND    nvl( l_new_business_group_id, -1) = nvl(business_group_id , -1) ;
  EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RAISE;
  END;

  IF p_file_name IS NOT NULL THEN
     BEGIN
       SELECT ext_file_id
       INTO   l_ext_file_id
       FROM   ben_ext_file
       WHERE  name = p_file_name
       AND    NVL(legislation_code,'~NVL~') = NVL(l_legislation_code,'~NVL~')
       AND    nvl( l_new_business_group_id, -1) = nvl(business_group_id , -1) ;
     EXCEPTION
         WHEN NO_DATA_FOUND THEN
           RAISE;
     END;
     BEGIN
       SELECT ext_rcd_in_file_id
       INTO   l_ext_rcd_in_file_id
       FROM   ben_ext_rcd_in_file
       WHERE  ext_file_id             = l_ext_file_id
       AND    ext_rcd_id              = l_ext_rcd_id
       AND    NVL(legislation_code,'~NULL~')=  NVL(l_legislation_code,'~NULL~')
       AND    nvl( l_new_business_group_id, -1) = nvl(business_group_id , -1) ;
     EXCEPTION
         WHEN NO_DATA_FOUND THEN
           RAISE;
     END;
  ELSE
    l_ext_file_id        := NULL;
    l_ext_rcd_in_file_id := NULL;
  END IF;

  if P_DATA_ELMT_NAME is not null then

     BEGIN
        SELECT ext_data_elmt_id
        INTO   l_ext_data_elmt_id
        FROM   ben_ext_data_elmt
        WHERE  name = p_data_elmt_name
         AND    ( ( nvl(l_new_business_group_id, -1) = nvl(business_group_id , -1)) or
           ( p_business_group is null and business_group_id is null ) )
        --AND    nvl( l_new_business_group_id, -1) = nvl(business_group_id , -1)
        AND    NVL(legislation_code,'~NULL~')= NVL(l_legislation_code,'~NULL~');
     EXCEPTION
        WHEN NO_DATA_FOUND THEN
           RAISE;
     END;
     BEGIN
        SELECT ext_data_elmt_in_rcd_id
        INTO   l_ext_data_elmt_in_rcd_id
        FROM   ben_ext_data_elmt_in_rcd
        WHERE  ext_rcd_id                    = l_ext_rcd_id
        AND    ext_data_elmt_id              = l_ext_data_elmt_id
        AND    nvl( l_new_business_group_id, -1) = nvl(business_group_id , -1)
        AND    NVL(legislation_code,'~NVL~') = NVL(l_legislation_code,'~NVL~');
     EXCEPTION
        WHEN NO_DATA_FOUND THEN
           RAISE;
     END;
  ELSE
     l_ext_data_elmt_id        := null ;
     l_ext_data_elmt_in_rcd_id := null ;
  END IF ;

  IF L_CHG_EVT_CD is  not null then
       if  p_chg_evt_source  = 'PAY'  then
           l_chg_evt_cd := set_chg_evt_cd(l_CHG_EVT_CD,p_chg_evt_source,l_new_business_group_id) ;
           if  l_chg_evt_cd = p_chg_evt_cd then
               write_err
                 (p_err_num           =>  null,
                  p_err_msg           =>  'Advance Condition  Change Event :'|| P_CHG_EVT_CD   || ' Not Enabled '  ,
                  p_typ_cd            =>  'E' ,
                  p_business_group_id =>  l_new_business_group_id
                 );
                return ;
           end if ;
       else
         -- make sure the cahnge evt code is enabled
         if g_business_group_id is not null and  fnd_global.conc_request_id <> -1  then
             open cw(L_CHG_EVT_CD) ;
             fetch cw into l_temp ;
             if cw%notfound then
                close cw ;
                  write_err
                 (p_err_num           =>  null,
                  p_err_msg           =>  'Advance Condition  Change Event :'|| P_CHG_EVT_CD   || ' Not Enabled '  ,
                  p_typ_cd            =>  'E' ,
                  p_business_group_id =>  l_new_business_group_id
                 );
                return ;
             end if ;
             close cw ;
         end if ;
      end if ;
      --

     BEGIN
       --rpinjala
         SELECT 'Y'
           INTO   l_temp
           FROM   ben_ext_incl_chg
            WHERE (l_ext_rcd_in_file_id IS NULL OR
                    ext_rcd_in_file_id      = l_ext_rcd_in_file_id)
             AND   (l_ext_data_elmt_in_rcd_id IS NULL OR
                    ext_data_elmt_in_rcd_id = l_ext_data_elmt_in_rcd_id)
             AND   chg_evt_cd               = l_chg_evt_cd
             AND   NVL(l_new_business_group_id, -1) = NVL(business_group_id , -1)
             AND   NVL(legislation_code,'~NULL~')    = NVL(l_legislation_code,'~NULL~');
         --rpinjala

         EXCEPTION
             WHEN TOO_MANY_ROWS then
                 declare
                    cursor c_incl is
                      SELECT ext_incl_chg_id , object_version_number
                      FROM   ben_ext_incl_chg
                      WHERE (l_ext_rcd_in_file_id IS NULL OR
                             ext_rcd_in_file_id      = l_ext_rcd_in_file_id)
                      AND   (l_ext_data_elmt_in_rcd_id IS NULL OR
                             ext_data_elmt_in_rcd_id = l_ext_data_elmt_in_rcd_id)
                      AND   chg_evt_cd               = l_chg_evt_cd
                      AND   NVL(l_new_business_group_id, -1) = NVL(business_group_id , -1)
                      AND   NVL(legislation_code,'~NULL~') =  NVL(l_legislation_code,'~NULL~');

                 begin
                     for i in c_incl  loop
                          l_object_version_number := i.object_version_number ;
                          ben_xic_del.del(
                                    p_effective_date         => l_last_update_date,
                                    p_ext_incl_chg_id        => i.ext_incl_chg_id,
                                    p_object_version_number  => l_object_version_number
                                   );

                     end loop ;

                     l_object_version_number := null ;
                      hr_utility.set_location('calling ins for  ' || l_chg_evt_cd  , 10);
                      ben_xic_ins.ins(p_effective_date  => l_last_update_date
                       ,p_ext_incl_chg_id        => l_ext_incl_chg_id
                       ,p_chg_evt_cd             => l_chg_evt_cd
                       ,p_ext_rcd_in_file_id     => l_ext_rcd_in_file_id
                       ,p_ext_data_elmt_in_rcd_id=> l_ext_data_elmt_in_rcd_id
                       ,p_business_group_id       => l_new_business_group_id
                       ,p_legislation_code        => l_legislation_code
                       ,p_last_update_date        => l_last_update_date
                       ,p_creation_date           => l_last_update_date
                       ,p_last_updated_by         => l_last_updated_by
                       ,p_last_update_login       => 0
                       ,p_created_by              => l_last_updated_by
                       ,p_object_version_number   => l_object_version_number
                       ,p_chg_evt_source          => p_chg_evt_source );

                 end ;


            WHEN NO_DATA_FOUND THEN
                hr_utility.set_location('calling ins for  ' || l_chg_evt_cd  , 10);
                ben_xic_ins.ins(p_effective_date => l_last_update_date
                       ,p_ext_incl_chg_id        => l_ext_incl_chg_id
                       ,p_chg_evt_cd             => l_chg_evt_cd
                       ,p_ext_rcd_in_file_id     => l_ext_rcd_in_file_id
                       ,p_ext_data_elmt_in_rcd_id=> l_ext_data_elmt_in_rcd_id
                       ,p_business_group_id       => l_new_business_group_id
                       ,p_legislation_code        => l_legislation_code
                       ,p_last_update_date        => l_last_update_date
                       ,p_creation_date           => l_last_update_date
                       ,p_last_updated_by         => l_last_updated_by
                       ,p_last_update_login       => 0
                       ,p_created_by              => l_last_updated_by
                       ,p_object_version_number   => l_object_version_number
                       ,p_chg_evt_source          => p_chg_evt_source );
             WHEN OTHERS THEN
                RAISE;
         END;
     --ELSIF p_chg_evt_source  = 'PAY'  then
           -- we can not support payroll cahnge evnt logs not
           -- we should download the code for extract event and name for
           -- payroll process, till we determine the download part  we dont support pay change event group - tilak
           Return ;

     --END IF ;


  END IF ;
   hr_utility.set_location(' Leaving ' || l_proc, 10);

END load_incl_chgs;




PROCEDURE load_profile(p_profile_name IN VARCHAR2
     ,p_owner IN VARCHAR2
     ,p_last_update_date IN VARCHAR2
     ,p_legislation_code IN VARCHAR2
     ,p_business_group   in VARCHAR2
     ,p_ext_global_flag  in VARCHAR2 default 'N'
  ) IS
--
l_ext_prfl_id             NUMBER;
l_object_version_number   NUMBER;
l_legislation_code        VARCHAR2(240) := p_legislation_code; --utf8
l_temp                    VARCHAR2(1);
l_last_update_date      DATE;
l_last_updated_by        NUMBER;
l_new_business_group_id number ;
l_proc                   varchar2(100) := 'BEN_EXT_SEED.load_profile' ;
BEGIN

    hr_utility.set_location(' Entering ' || l_proc, 10);
   get_who_values(p_owner             => p_owner
                ,p_last_update_vc    => p_last_update_date
                ,p_last_update_date  => l_last_update_date
                ,p_last_updated_by   => l_last_updated_by
                ,p_legislation_code  => l_legislation_code
                ,p_business_group    => p_business_group
                ,p_business_group_id => l_new_business_group_id );

  BEGIN
    SELECT ext_crit_prfl_id
    INTO   l_ext_prfl_id
    FROM   ben_ext_crit_prfl
    WHERE  name = p_profile_name
    AND    nvl( l_new_business_group_id, -1) = nvl(business_group_id , -1)
    AND    NVL(legislation_code,'~NVL~')    = NVL(l_legislation_code,'~NVL~');
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      ben_xcr_ins.ins(p_ext_crit_prfl_id      => l_ext_prfl_id
                     ,p_name                  => p_profile_name
                     ,p_business_group_id     => l_new_business_group_id
                     ,p_legislation_code      => l_legislation_code
                     ,p_last_update_date      => l_last_update_date
                     ,p_creation_date         => l_last_update_date
                     ,p_last_update_login     => 0
                     ,p_created_by            => l_last_updated_by
                     ,p_last_updated_by       => l_last_updated_by
                     ,p_ext_global_flag       => nvl(p_ext_global_flag,'N')
                     ,p_object_version_number => l_object_version_number
                    );
    WHEN OTHERS THEN
      RAISE;
  END;
  --- delete the advace citeria and cmbn value
  delete_crit_adv_conditon
                  (p_ext_crit_prfl_id =>  l_ext_prfl_id  ) ;
    hr_utility.set_location(' Leaving ' || l_proc, 10);
END load_profile;


PROCEDURE load_criteria_type(p_profile_name     IN VARCHAR2
                            ,p_type_code        IN VARCHAR2
                            ,p_owner            IN VARCHAR2
                            ,p_last_update_date IN VARCHAR2
                            ,p_crit_typ_cd      IN VARCHAR2
                            ,p_excld_flag       IN VARCHAR2
                            ,p_legislation_code IN VARCHAR2
                            ,p_business_group   IN VARCHAR2
                           ) IS
--
l_ext_prfl_id             NUMBER;
l_ext_crit_typ_id         NUMBER;
l_object_version_number   NUMBER;
l_legislation_code        VARCHAR2(240) := p_legislation_code; --utf8
l_temp                    VARCHAR2(1);
l_last_update_date        DATE;
l_last_updated_by        NUMBER;
l_new_business_group_id number ;
  l_proc                   varchar2(100) := 'BEN_EXT_SEED.load_criteria_type' ;
BEGIN
   hr_utility.set_location(' Entering ' || l_proc, 10);
   --- for advance criteria once the issues is fixed remove the condition
   /*
   if p_type_code = 'ADV'  then
        write_err
           (p_err_num           =>  null,
            p_err_msg           =>  'Advance Criteria is not uploaded'  ,
            p_typ_cd            =>  'W' ,
            p_business_group_id =>  l_new_business_group_id
           );
     return ;
   end if ;
   */

   ---
   get_who_values(p_owner            => p_owner
                ,p_last_update_vc    => p_last_update_date
                ,p_last_update_date  => l_last_update_date
                ,p_last_updated_by   => l_last_updated_by
                ,p_legislation_code  => l_legislation_code
                ,p_business_group    => p_business_group
                ,p_business_group_id => l_new_business_group_id );

  BEGIN
    SELECT ext_crit_prfl_id
    INTO   l_ext_prfl_id
    FROM   ben_ext_crit_prfl
    WHERE  name = p_profile_name
    AND    nvl( l_new_business_group_id, -1) = nvl(business_group_id , -1)
    AND    NVL(legislation_code,'~NVL~')    = NVL(l_legislation_code,'~NVL~');
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
       RAISE;
  END;
  BEGIN
    SELECT 'Y'
    INTO   l_temp
    FROM   ben_ext_crit_typ
    WHERE  ext_crit_prfl_id = l_ext_prfl_id
    AND    crit_typ_cd = p_type_code
    AND    nvl( l_new_business_group_id, -1) = nvl(business_group_id , -1)
    AND    NVL(legislation_code,'~NVL~')    = NVL(l_legislation_code,'~NVL~');
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      ben_xct_ins.ins(p_effective_date        => l_last_update_date
                     ,p_ext_crit_typ_id       => l_ext_crit_typ_id
                     ,p_crit_typ_cd           => p_type_code
                     ,p_excld_flag            => p_excld_flag
                     ,p_ext_crit_prfl_id      => l_ext_prfl_id
                     ,p_business_group_id     => l_new_business_group_id
                     ,p_legislation_code      => l_legislation_code
                     ,p_last_update_date      => l_last_update_date
                     ,p_creation_date         => l_last_update_date
                     ,p_last_update_login     => 0
                     ,p_created_by            => l_last_updated_by
                     ,p_last_updated_by       => l_last_updated_by
                     ,p_object_version_number => l_object_version_number);
    WHEN OTHERS THEN
      RAISE;
  END;
    hr_utility.set_location(' Leaving ' || l_proc, 10);
END load_criteria_type;
--
PROCEDURE load_criteria_val(p_profile_name      IN VARCHAR2
                           ,p_type_code         IN VARCHAR2
                           ,p_val               IN  VARCHAR2
                           ,p_owner             IN VARCHAR2
                           ,p_last_update_date  IN VARCHAR2
                           ,p_val2              IN VARCHAR2
                           ,p_legislation_code  IN VARCHAR2
                           ,p_business_group    IN VARCHAR2
                           ,p_ext_crit_val_id   in varchar2 default null
                           ,p_lookup_code1      in varchar2 default null
                           ,p_lookup_code2      in varchar2 default null
                          ) IS
--
cursor cw (c_code varchar2)
           is select 'x'
             from   hr_lookups
             where  lookup_type = 'BEN_EXT_CHG_EVT'
             and    lookup_code  = c_code
             and    enabled_flag = 'Y'
             and    trunc(sysdate) between nvl(start_date_active, trunc(sysdate))
                                 and nvl(end_date_active, trunc(sysdate))
             ;

--
l_ext_prfl_id             NUMBER;
l_ext_crit_typ_id         NUMBER;
l_ext_crit_val_id         NUMBER;
l_object_version_number   NUMBER;
l_legislation_code        VARCHAR2(240) := p_legislation_code; --utf8
l_temp                    VARCHAR2(1);
l_code                    VARCHAR2(30);
l_dummy_code                    VARCHAR2(30);
l_meaning                 VARCHAR2(2000);
l_meaning2                 VARCHAR2(2000);
l_last_update_date      DATE;
l_last_updated_by        NUMBER;
l_value VARCHAR2(200);
l_value2 VARCHAR2(200);
l_new_business_group_id number ;
  l_proc                   varchar2(100) := 'BEN_EXT_SEED.load_criteria_val' ;
BEGIN
   --- for advance criteria once the issues is fixed remove the condition
   /*
   if p_type_code = 'ADV'  then
     return ;
   end if ;
   */
   hr_utility.set_location(' Entering ' || l_proc, 10);

   get_who_values(p_owner             => p_owner
                ,p_last_update_vc    => p_last_update_date
                ,p_last_update_date  => l_last_update_date
                ,p_last_updated_by   => l_last_updated_by
                ,p_legislation_code  => l_legislation_code
                ,p_business_group    => p_business_group
                ,p_business_group_id => l_new_business_group_id );

  l_code := p_type_code;
  l_meaning2 := p_val2;

  -- if the code is comming as param , make sure the lookup exisit
  if  p_lookup_code2 is not null then
      l_value2  := ben_extract_seed.get_lookup_code (l_code,p_lookup_code2 ,'VAL_2',null) ;
  end if ;

  --- if the code is null or the code is not null and not exist get the code from name
  if l_value2  is null or p_lookup_code2 is null then
     l_value2   :=  ben_extract_seed.decode_value(l_code,l_meaning2,'VAL_2',null) ;
  end if ;

  l_meaning := p_val;

  if  p_lookup_code1 is not null then
      l_value  := ben_extract_seed.get_lookup_code (l_code,p_lookup_code1 ,'VAL_1',null) ;
  end if ;



  if l_value  is null or p_lookup_code1 is null then
     l_value :=  ben_extract_seed.decode_value(l_code,l_meaning,'VAL_1',l_meaning2) ;
  end if ;

  --- since we are changing the meaning of  TDRASG in passor make sure  the  lookup code
  --- ised even if the name is null

  if l_value is NULL  and l_code = 'PASOR' and l_meaning = 'Today Or Terminated Assignment End Date' then
      l_value := 'TDRASG' ;
  end if ;

  if l_value is NULL THEN
     -- if the concurrent manger does the job log the message
     if g_business_group_id is not null and  fnd_global.conc_request_id <> -1  then
        write_err
         (p_err_num           =>  null,
          p_err_msg           =>  'Criteria value not found : '||hr_general.decode_lookup('BEN_EXT_CRIT_TYP',l_code )||' : '||l_meaning,
          p_typ_cd            =>  'E' ,
          p_business_group_id =>  l_new_business_group_id
         );
        return ;
     else
        raise_application_error(-20001,'Criteria value not found : '||hr_general.decode_lookup('BEN_EXT_CRIT_TYP',l_code)||' : '
                                        ||l_meaning||':');
     end if ;
  END IF;


  -- if the type code is change event  then make sure the change event is valid for business group
  if p_type_code = 'CCE'  then
      if g_business_group_id is not null and  fnd_global.conc_request_id <> -1  then
         open cw(l_value) ;
         fetch cw into l_temp ;
         if cw%notfound then
            close cw ;
              write_err
             (p_err_num           =>  null,
              p_err_msg           =>  'Criteria Change Event Code :'|| l_meaning || ' Not Enabled '  ,
              p_typ_cd            =>  'E' ,
              p_business_group_id =>  l_new_business_group_id
             );
            return ;
         end if ;
         close cw ;
      end if ;
  end if ;

  BEGIN
    SELECT ext_crit_prfl_id
    INTO   l_ext_prfl_id
    FROM   ben_ext_crit_prfl
    WHERE  name = p_profile_name
    AND    nvl( l_new_business_group_id, -1) = nvl(business_group_id , -1)
    AND    NVL(legislation_code,'~NVL~')    = NVL(l_legislation_code,'~NVL~');
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
       RAISE;
  END;
  BEGIN
    SELECT ext_crit_typ_id
    INTO   l_ext_crit_typ_id
    FROM   ben_ext_crit_typ
    WHERE  ext_crit_prfl_id = l_ext_prfl_id
    AND    crit_typ_cd = p_TYPE_CODE
    AND    nvl( l_new_business_group_id, -1) = nvl(business_group_id , -1)
    AND    NVL(legislation_code,'~NVL~')    = NVL(l_legislation_code,'~NVL~');
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
       RAISE;
  END;
  BEGIN
    if p_type_code  <> 'ADV' then
       SELECT 'Y'
       INTO   l_temp
       FROM   ben_ext_crit_val
       WHERE  ext_crit_typ_id = l_ext_crit_typ_id
       AND    val_1 = l_value
       AND    nvl(val_2,'~NVL~') = NVL(l_value2,'~NVL~')
       AND    nvl( l_new_business_group_id, -1) = nvl(business_group_id , -1)
       AND    NVL(legislation_code,'~NVL~')    = NVL(l_legislation_code,'~NVL~')
       ;
    else
       -- there is a possibility of more then once row with same value in adv condition
       Declare

         cursor c1 is
         SELECT 'Y'
         FROM   ben_ext_crit_val
         WHERE  ext_crit_typ_id = l_ext_crit_typ_id
         AND    val_1 = l_value
         AND    nvl(val_2,'~NVL~') = NVL(l_value2,'~NVL~')
         AND    nvl( l_new_business_group_id, -1) = nvl(business_group_id , -1)
         AND    NVL(legislation_code,'~NVL~')    = NVL(l_legislation_code,'~NVL~')
         and    val_1 = p_val ;
       Begin

         open c1 ;
         fetch c1 into l_temp ;
         if c1%notFound then
            close c1;
            Raise NO_DATA_FOUND ;
         end if ;
         close c1;

          -- when the type is adv validate the old id is exist
          -- if not creat a row
          -- this has to be revisted when the adv condtion update is fixed
          if p_type_code  = 'ADV' then
              if nvl(get_adv_cond_cmbn( p_old_ext_crit_val_id => to_number(p_ext_crit_val_id)),0) = 0 then
                 Raise NO_DATA_FOUND ;
              end if ;
          end if ;
       end ;
    end if ;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      ben_xcv_ins.ins(p_effective_date        => trunc(sysdate)
                     ,p_ext_crit_val_id       => l_ext_crit_val_id
                     ,p_val_1                 => l_value
                     ,p_val_2                 => l_value2
                     ,p_ext_crit_typ_id       => l_ext_crit_typ_id
                     ,p_business_group_id     => l_new_business_group_id
                     ,p_legislation_code      => l_legislation_code
                     ,p_last_update_date      => l_last_update_date
                     ,p_creation_date         => l_last_update_date
                     ,p_last_update_login     => 0
                     ,p_created_by            => l_last_updated_by
                     ,p_last_updated_by       => l_last_updated_by
                     ,p_object_version_number => l_object_version_number);

      --- for advance condition it is allways create
      --- so set the old value and new value
      if p_type_code  = 'ADV' then
          set_adv_cond_cmbn
                ( p_old_ext_crit_val_id   => to_number(p_ext_crit_val_id) ,
                  p_new_ext_crit_val_id   => l_ext_crit_val_id  ) ;
      end if ;

    WHEN OTHERS THEN
      RAISE;
  END;
   hr_utility.set_location(' Leaving ' || l_proc, 10);
end load_criteria_val;
--
PROCEDURE load_combination(p_profile_name       IN VARCHAR2
                          ,p_type_code          IN VARCHAR2
                          ,p_val                IN VARCHAR2
                          ,p_val_2              IN VARCHAR2
                          ,p_crit_typ_cd        IN VARCHAR2
                          ,p_oper_cd            IN VARCHAR2
                          ,p_owner              IN VARCHAR2
                          ,p_last_update_date   IN VARCHAR2
                          ,p_legislation_code   IN VARCHAR2
                          ,p_business_group     in VARCHAR2
                          ,p_ext_crit_val_id   in varchar2 default null
                          ,p_lookup_code1      in varchar2 default null
                          ,p_lookup_code2      in varchar2 default null
                          ) IS
--
l_ext_prfl_id             NUMBER;
l_ext_crit_typ_id         NUMBER;
l_ext_crit_val_id         NUMBER;
l_ext_crit_cmbn_id        NUMBER;
l_object_version_number   NUMBER;
l_legislation_code        VARCHAR2(240) := p_legislation_code;
l_temp                    VARCHAR2(1);
l_last_update_date      DATE;
l_last_updated_by        NUMBER;
l_new_business_group_id number ;
l_code                    VARCHAR2(20000) ;
l_val_1                   VARCHAR2(20000) ;
l_val_2                   VARCHAR2(20000) ;
l_meaning2                VARCHAR2(20000) ;
l_meaning                 VARCHAR2(20000) ;

  l_proc                   varchar2(100) := 'BEN_EXT_SEED.load_combination' ;
BEGIN

   --- for advance criteria once the issues is fixed remove the condition
   /*
   if p_type_code = 'ADV'  then
     return ;
   end if ;
   */
    hr_utility.set_location(' Entering ' || l_proc, 10);
   ---
   get_who_values(p_owner             => p_owner
                ,p_last_update_vc    => p_last_update_date
                ,p_last_update_date  => l_last_update_date
                ,p_last_updated_by   => l_last_updated_by
                ,p_legislation_code  => l_legislation_code
                ,p_business_group    => p_business_group
                ,p_business_group_id => l_new_business_group_id );



  l_code := p_crit_typ_cd;
  l_meaning2 := p_val_2;



   -- if the code is comming as param , make sure the lookup exisit
  if  p_lookup_code2 is not null then
      l_val_2  := ben_extract_seed.get_lookup_code (l_code,p_lookup_code2 ,'VAL_2',null) ;
  end if ;

  if  l_val_2 is null or  p_lookup_code2 is null then
      l_val_2 :=  ben_extract_seed.decode_value(l_code,l_meaning2,'VAL_2',null) ;
  end if ;



  l_meaning := p_val;

  if  p_lookup_code1 is not null then
      l_val_1  := ben_extract_seed.get_lookup_code (l_code,p_lookup_code1 ,'VAL_1',null) ;
  end if ;

  if  l_val_1 is null or  p_lookup_code1 is null then
      l_val_1 :=  ben_extract_seed.decode_value(l_code,l_meaning,'VAL_1',l_meaning2) ;
  end if ;

  if l_val_1 is NULL THEN
       -- if the concurrent manger does the job log the message
     if g_business_group_id is not null and  fnd_global.conc_request_id <> -1  then
        write_err
         (p_err_num           =>  null,
          p_err_msg           =>  'Criteria value not found : '||hr_general.decode_lookup('BEN_EXT_CRIT_TYP',l_code)||' : '||l_meaning,
          p_typ_cd            =>  'E' ,
          p_business_group_id =>  l_new_business_group_id
         );
        return ;
     else
         raise_application_error(-20001,'Criteria value not found : '||hr_general.decode_lookup('BEN_EXT_CRIT_TYP',l_code)||' : '
                                 ||l_meaning||':');
     end if ;

  END IF;


  BEGIN
    SELECT ext_crit_prfl_id
    INTO   l_ext_prfl_id
    FROM   ben_ext_crit_prfl
    WHERE  name = p_profile_name
    AND    nvl( l_new_business_group_id, -1) = nvl(business_group_id , -1)
    AND    NVL(legislation_code,'~NVL~')    = NVL(l_legislation_code,'~NVL~');
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
       RAISE;
  END;
  BEGIN

    -- if more then one criteria defined how do we differentiat them - tilak
    SELECT ext_crit_typ_id
    INTO   l_ext_crit_typ_id
    FROM   ben_ext_crit_typ
    WHERE  ext_crit_prfl_id = l_ext_prfl_id
    AND    crit_typ_cd = p_type_code
    AND    nvl( l_new_business_group_id, -1) = nvl(business_group_id , -1)
    AND    NVL(legislation_code,'~NVL~')    = NVL(l_legislation_code,'~NVL~');


 EXCEPTION
    WHEN NO_DATA_FOUND THEN
       RAISE;
  END;
  BEGIN
   /*
    -- how do we differentiate whne more then one criteria val - tilak
    SELECT ext_crit_val_id
    INTO   l_ext_crit_val_id
    FROM   ben_ext_crit_val
    WHERE  ext_crit_typ_id = l_ext_crit_typ_id
    --AND    val_1 = p_val
    AND    nvl( l_new_business_group_id, -1) = nvl(business_group_id , -1)
    AND    NVL(legislation_code,'~NVL~')    = NVL(l_legislation_code,'~NVL~');
    */


    l_ext_crit_val_id := get_adv_cond_cmbn
                          ( p_old_ext_crit_val_id   => to_number(p_ext_crit_val_id)
                           ) ;
    if l_ext_crit_val_id is null then
       return ;
    end if ;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
       RAISE;
  END;
  BEGIN
    SELECT 'Y'
    INTO   l_temp
    FROM   ben_ext_crit_cmbn
    WHERE  ext_crit_val_id = l_ext_crit_val_id
    AND    crit_typ_cd = p_crit_typ_cd
    and    oper_cd     = p_oper_cd
    AND    nvl( l_new_business_group_id, -1) = nvl(business_group_id , -1)
    AND    NVL(legislation_code,'~NVL~')    = NVL(l_legislation_code,'~NVL~');
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      ben_xcc_ins.ins(p_effective_date        => l_last_update_date
                     ,p_ext_crit_cmbn_id      => l_ext_crit_cmbn_id
                     ,p_ext_crit_val_id       => l_ext_crit_val_id
                     ,p_crit_typ_cd           => p_crit_typ_cd
                     ,p_oper_cd               => p_oper_cd
                     ,p_val_1                 => l_val_1
                     ,p_val_2                 => l_val_2
                     ,p_business_group_id     => l_new_business_group_id
                     ,p_legislation_code      => l_legislation_code
                     ,p_last_update_date      => l_last_update_date
                     ,p_creation_date         => l_last_update_date
                     ,p_last_update_login     => 0
                     ,p_created_by            => l_last_updated_by
                     ,p_last_updated_by       => l_last_updated_by
                     ,p_object_version_number => l_object_version_number);
    WHEN OTHERS THEN
      RAISE;
  END;
   hr_utility.set_location(' Leaving ' || l_proc, 10);
END load_combination;
--
PROCEDURE load_definition(p_definition_name          IN   VARCHAR2
                         ,p_file_name                IN  VARCHAR2
                         ,p_profile_name             IN  VARCHAR2
                         ,p_owner                    IN  VARCHAR2
                         ,p_last_update_date         IN  VARCHAR2
                         ,p_kickoff_wrt_prc_flag     IN  VARCHAR2
                         ,p_apnd_rqst_id_flag        IN  VARCHAR2
                         ,p_prmy_sort_cd             IN  VARCHAR2
                         ,p_scnd_sort_cd             IN  VARCHAR2
                         ,p_strt_dt                  IN  VARCHAR2
                         ,p_end_dt                   IN  VARCHAR2
                         ,p_spcl_hndl_flag           IN  VARCHAR2
                         ,p_upd_cm_sent_dt_flag      IN  VARCHAR2
                         ,p_use_eff_dt_for_chgs_flag IN  VARCHAR2
                         ,p_data_typ_cd              IN  VARCHAR2
                         ,p_ext_typ_cd               IN  VARCHAR2
                         ,p_drctry_name              IN  VARCHAR2
                         ,p_output_name              IN  VARCHAR2
                         ,p_post_processing_rule     IN  VARCHAR2
                         ,p_legislation_code         IN  VARCHAR2
                         ,p_business_group           IN VARCHAR2
                         ,p_xml_tag_name             in VARCHAR2
                         ,p_output_type              in VARCHAR2
                         ,p_xdo_template_name        in VARCHAR2
                         ,p_ext_global_flag          in VARCHAR2 default 'N'
                         ,p_cm_display_flag          in VARCHAR2 default 'N'
                         ) IS
--
l_ext_prfl_id             NUMBER;
l_ext_file_id             NUMBER;
l_ext_dfn_id              NUMBER;
l_ext_post_prcs_rl        NUMBER;
l_object_version_number   NUMBER;
l_legislation_code        VARCHAR2(240) := p_legislation_code;
l_temp                    VARCHAR2(1);
l_last_update_date        DATE;
l_last_updated_by         NUMBER;
l_new_business_group_id number ;
l_ovn                     number ;
l_output_type            varchar2(30) ;
l_template_id            number ;
  l_proc                   varchar2(100) := 'BEN_EXT_SEED.load_definition' ;
BEGIN

    hr_utility.set_location(' Entering ' || l_proc, 10);
   get_who_values(p_owner             => p_owner
                ,p_last_update_vc    => p_last_update_date
                ,p_last_update_date  => l_last_update_date
                ,p_last_updated_by   => l_last_updated_by
                ,p_legislation_code  => l_legislation_code
                ,p_business_group    => p_business_group
                ,p_business_group_id => l_new_business_group_id );




  BEGIN
    SELECT ext_file_id
    INTO   l_ext_file_id
    FROM   ben_ext_file
    WHERE  name = p_file_name
    AND    nvl( l_new_business_group_id, -1) = nvl(business_group_id , -1)
    AND    NVL(legislation_code,'~NVL~')    = NVL(l_legislation_code,'~NVL~');
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
       RAISE;
  END;
  BEGIN
    IF p_post_processing_rule = 'NULL' THEN
      l_ext_post_prcs_rl := NULL;
    ELSE
      SELECT formula_id
      INTO   l_ext_post_prcs_rl
      FROM   ff_formulas_f
      WHERE formula_name = p_post_processing_rule
      AND    nvl( l_new_business_group_id, -1) = nvl(business_group_id , -1)
      AND    trunc(sysdate) BETWEEN effective_start_date and effective_end_date ;
    END IF;
    EXCEPTION
     WHEN NO_DATA_FOUND
       THEN
         -- if the concurrent manger does the job log the message
     if g_business_group_id is not null and  fnd_global.conc_request_id <> -1  then
        write_err
         (p_err_num           =>  null,
          p_err_msg           =>  ' No formula of name '||p_post_processing_rule||' Exists for Definition '||p_definition_name   ,
          p_typ_cd            =>  'E' ,
          p_business_group_id =>  l_new_business_group_id
         );
         l_ext_post_prcs_rl := NULL;
     else
         raise_application_error(-20001,' No formula of name '||p_post_processing_rule||' Exists for Definition '||p_definition_name );
     end if ;
  END;

  l_output_type := p_output_type ;
  if P_xdo_template_name is not null then

     Declare
      cursor c is
      select xdo.template_id
      from   xdo_templates_b xdo
      where  xdo.template_code =  P_xdo_template_name
      order by  decode(xdo.application_id ,FND_GLOBAL.resp_appl_id,1,2)
      ;

     Begin
        open c ;
        fetch c into l_template_id ;
        if c%notfound then
           l_output_type := null ;
        end if ;
        close c ;
     End ;

  end if ;

  if  p_profile_name is not null then
     BEGIN
       SELECT ext_crit_prfl_id
       INTO   l_ext_prfl_id
       FROM   ben_ext_crit_prfl
       WHERE  name = p_profile_name
       AND    nvl( l_new_business_group_id, -1) = nvl(business_group_id , -1)
       AND    NVL(legislation_code,'~NVL~')    = NVL(l_legislation_code,'~NVL~');
     EXCEPTION
       WHEN NO_DATA_FOUND THEN
          RAISE;
     END;
  end if ;


  -- call file update to load  group elemt
  if g_group_record is not null and g_group_elmt1 is not null then

      load_extract_group(p_file_name       => p_file_name
                       ,p_ext_group_record => g_group_record
                       ,p_ext_group_elmt1  => g_group_elmt1
                       ,p_ext_group_elmt2  => g_group_elmt2
                       ,p_owner            => p_owner
                       ,p_last_update_date => p_last_update_date
                       ,p_legislation_code => p_legislation_code
                       ,p_business_group   => p_business_group
                       )  ;
     g_group_record := null ;
     g_group_elmt1  := null ;
  end if ;
  --

  BEGIN
    SELECT object_version_number ,ext_dfn_id
    INTO   l_ovn,l_ext_dfn_id
    FROM   ben_ext_dfn
    WHERE  ext_file_id = l_ext_file_id
    AND    name = p_definition_name
    AND    nvl( l_new_business_group_id, -1) = nvl(business_group_id , -1)
    AND    NVL(legislation_code,'~NVL~')    = NVL(l_legislation_code,'~NVL~');
   -- dont update for upload from concurrent manager
   if  ( l_new_business_group_id is null or g_override = 'Y' ) then

        ben_xdf_upd.upd (
            p_ext_dfn_id                    => l_ext_dfn_id
           ,p_name                          => p_definition_name
           ,p_xml_tag_name                  => p_xml_tag_name
           ,p_data_typ_cd                   => p_data_typ_cd
           ,p_ext_typ_cd                    => p_ext_typ_cd
           ,p_output_name                   => p_output_name
           ,p_output_type                   => l_output_type
           ,p_apnd_rqst_id_flag             => p_apnd_rqst_id_flag
           ,p_prmy_sort_cd                  => p_prmy_sort_cd
           ,p_scnd_sort_cd                  => p_scnd_sort_cd
           ,p_strt_dt                       => p_strt_dt
           ,p_end_dt                        => p_end_dt
           ,p_ext_crit_prfl_id              => l_ext_prfl_id
           ,p_ext_file_id                   => l_ext_file_id
           ,p_business_group_id             => l_new_business_group_id
           ,p_legislation_code              => l_legislation_code
           ,p_object_version_number         => l_ovn
           ,p_drctry_name                   => p_drctry_name
           ,p_kickoff_wrt_prc_flag          => p_kickoff_wrt_prc_flag
           ,p_upd_cm_sent_dt_flag           => p_upd_cm_sent_dt_flag
           ,p_spcl_hndl_flag                => p_spcl_hndl_flag
           ,p_use_eff_dt_for_chgs_flag      => p_use_eff_dt_for_chgs_flag
           ,p_ext_post_prcs_rl              => l_ext_post_prcs_rl
           ,p_effective_date                => trunc(sysdate)
           ,p_xdo_template_id               => l_template_id
           ,p_ext_global_flag               => nvl(p_ext_global_flag, 'N')
           ,p_cm_display_flag               => nvl(p_cm_display_flag, 'N')
          );

  end if ;


  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      ben_xdf_ins.ins(p_effective_date           => trunc(sysdate)
                     ,p_ext_dfn_id               => l_ext_dfn_id
                     ,p_name                     => p_definition_name
                     ,p_ext_crit_prfl_id         => l_ext_prfl_id
                     ,p_ext_file_id              => l_ext_file_id
                     ,p_kickoff_wrt_prc_flag     => p_kickoff_wrt_prc_flag
                     ,p_apnd_rqst_id_flag        => p_apnd_rqst_id_flag
                     ,p_prmy_sort_cd             => p_prmy_sort_cd
                     ,p_scnd_sort_cd             => p_scnd_sort_cd
                     ,p_strt_dt                  => p_strt_dt
                     ,p_end_dt                   => p_end_dt
                     ,p_spcl_hndl_flag           => p_spcl_hndl_flag
                     ,p_upd_cm_sent_dt_flag      => p_upd_cm_sent_dt_flag
                     ,p_use_eff_dt_for_chgs_flag => p_use_eff_dt_for_chgs_flag
                     ,p_data_typ_cd              => p_data_typ_cd
                     ,p_ext_typ_cd               => p_ext_typ_cd
                     ,p_drctry_name              => p_drctry_name
                     ,p_output_name              => p_output_name
                     ,p_business_group_id        => l_new_business_group_id
                     ,p_legislation_code         => l_legislation_code
                     ,p_last_update_date         => l_last_update_date
                     ,p_creation_date            => l_last_update_date
                     ,p_last_update_login        => 0
                     ,p_created_by               => l_last_updated_by
                     ,p_last_updated_by          => l_last_updated_by
                     ,p_ext_post_prcs_rl         => l_ext_post_prcs_rl
                     ,p_object_version_number    => l_object_version_number
                     ,p_xml_tag_name             => p_xml_tag_name
                     ,p_output_type              => l_output_type
                     ,p_xdo_template_id          => l_template_id
                     ,p_ext_global_flag          => nvl(p_ext_global_flag, 'N')
                     ,p_cm_display_flag          => nvl(p_cm_display_flag, 'N')
                     );
    WHEN OTHERS THEN
      RAISE;
  END;
   hr_utility.set_location(' Leaving ' || l_proc, 10);
END load_definition;
--
PROCEDURE load_decode(p_element_name      IN VARCHAR2
                     ,p_owner             IN VARCHAR2
                     ,p_last_update_date  IN VARCHAR2
                     ,p_val               IN VARCHAR2
                     ,p_dcd_val           IN VARCHAR2
                     ,p_legislation_code  IN VARCHAR2
                     ,p_business_group    IN VARCHAR2
                     ,p_chg_evt_source    in VARCHAR2 default null
                    ) is
l_ext_data_elmt_decd_id   NUMBER;
l_ext_data_elmt_id        NUMBER;
l_ext_fld_id              number ;
l_object_version_number   NUMBER;
l_legislation_code        VARCHAR2(240) := p_legislation_code;
l_temp                    VARCHAR2(1);
l_last_update_date        DATE;
l_last_updated_by         NUMBER;
l_new_business_group_id number ;

cursor c_1 (p_ext_fld_id number )  is
select decd_flag
from ben_ext_fld
where ext_fld_id = p_ext_fld_id ;

begin


   get_who_values(p_owner             => p_owner
                ,p_last_update_vc    => p_last_update_date
                ,p_last_update_date  => l_last_update_date
                ,p_last_updated_by   => l_last_updated_by
                ,p_legislation_code  => l_legislation_code
                ,p_business_group    => p_business_group
                ,p_business_group_id => l_new_business_group_id );

  BEGIN
    SELECT ext_data_elmt_id,ext_fld_id
    INTO   l_ext_data_elmt_id,l_ext_fld_id
    FROM   ben_ext_data_elmt
    WHERE  name = p_element_name
     AND    ( ( nvl(l_new_business_group_id, -1) = nvl(business_group_id , -1)) or
           ( p_business_group is null and business_group_id is null ) )
    --AND    nvl( l_new_business_group_id, -1) = nvl(business_group_id , -1)
    AND    NVL(legislation_code,'~NULL~') =  NVL(l_legislation_code,'~NULL~');


  --  when the ext_fld_id is not null check whether  the decd flag is 'Y' id so
  --  check whether the  decod falg is  id (by number ), if so dont insert
  --  the decod is a data  the id wont match with current environment
  if l_ext_fld_id is not null then
     open c_1(l_ext_fld_id) ;
     fetch c_1 into l_temp ;
     close c_1 ;
     if nvl(l_temp,'N') = 'Y' then
        -- check wheher it is number
       begin
           -- when the decode can not be  inserted  then raise the warning
           if  ( to_number(p_val) )  is not null  then
                write_err
                    (p_err_num           =>  null,
                     p_err_msg           =>  'Element ' ||  p_element_name ||' Decode Value ' || p_dcd_val ||' not uploaded'   ,
                     p_typ_cd            =>  'W' ,
                     p_business_group_id =>  l_new_business_group_id
                     );
               return ;
           end if ;
       exception
       when others  then  null ;
       end ;

     end if ;
  end if ;
  l_temp :=  null ;
  --

  EXCEPTION
      WHEN NO_DATA_FOUND THEN
        --RAISE;
        raise_application_error(-20001,'Data element '||p_element_name||
          ' legislation code '||l_legislation_code);
  END;
  BEGIN
    SELECT 'Y'
    INTO   l_temp
    FROM   ben_ext_data_elmt_decd
    WHERE  ext_data_elmt_id = l_ext_data_elmt_id
    AND    val = p_val
    AND    dcd_val = p_dcd_val
     AND    ( ( nvl(l_new_business_group_id, -1) = nvl(business_group_id , -1)) or
           ( p_business_group is null and business_group_id is null ) )
    --AND    nvl( l_new_business_group_id, -1) = nvl(business_group_id , -1)
    AND    NVL(legislation_code,'~NVL~')    = NVL(l_legislation_code,'~NVL~');
  EXCEPTION
    WHEN NO_DATA_FOUND THEN

  ben_xdd_ins.ins(p_ext_data_elmt_decd_id => l_ext_data_elmt_decd_id
                 ,p_val                   => p_val
               ,  p_dcd_val               => p_dcd_val
               ,  p_ext_data_elmt_id      => l_ext_data_elmt_id
               ,  p_business_group_id     => l_new_business_group_id
               ,  p_legislation_code      => l_legislation_code
               ,  p_last_update_date      => l_last_update_date
               ,  p_creation_date         => l_last_update_date
               ,  p_last_updated_by       => l_last_updated_by
               ,  p_last_update_login     => 0
               ,  p_created_by            => l_last_updated_by
               ,  p_object_version_number => l_object_version_number
               ,  p_chg_evt_source        => p_chg_evt_source );
  END;
end load_decode;



function  get_chg_evt_cd (p_CHG_EVT_CD      varchar2 ,
                          p_chg_evt_source  varchar2,
                          p_business_group_id number
                         ) return varchar2 as

l_return varchar2(250) ;

cursor cep is select event_group_name
         from  pay_event_groups
         where  event_group_id =  p_CHG_EVT_CD

         ;

begin


 l_return := p_CHG_EVT_CD ;
 if  p_chg_evt_source = 'PAY' then
     open cep ;
     fetch cep into l_return ;
     close cep ;
 end if ;

 if l_return is null then
    l_return := p_CHG_EVT_CD ;
 end if ;

 Return l_return ;
end  ;



function  set_chg_evt_cd (p_CHG_EVT_CD      varchar2 ,
                          p_chg_evt_source  varchar2,
                          p_business_group_id number
                         ) return varchar2 as

l_return varchar2(250) ;

cursor cep is select event_group_id
             from   pay_event_groups
             where  event_group_name  = P_CHG_EVT_CD
             and     nvl(business_group_id,nvl(p_business_group_id,-1))
                      = nvl(p_business_group_id,-1)
              ;

begin

 l_return := p_CHG_EVT_CD ;
 if  p_chg_evt_source = 'PAY' then
     open cep ;
     fetch cep into l_return ;
     close cep ;
 end if ;

 if l_return is null then
    l_return := p_CHG_EVT_CD ;
 end if ;

 Return l_return ;
end ;

END ben_extract_seed;

/
