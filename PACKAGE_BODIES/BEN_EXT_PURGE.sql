--------------------------------------------------------
--  DDL for Package Body BEN_EXT_PURGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_EXT_PURGE" as
/* $Header: benxpurg.pkb 120.2 2007/05/01 22:02:46 tjesumic noship $ */
--------------------------------------------------------------------------------
/*
+==============================================================================+
|			Copyright (c) 1997 Oracle Corporation                  |
|			   Redwood Shores, California, USA                     |
|			        All rights reserved.	                         |
+==============================================================================+
Name:
    Extract Write Process.
Purpose:
    This process delete the record as per the paramter provided
    to a flat output file.
History:
     Date             Who        Version    What?
     ----             ---        -------    -----
     26 Aug 98        tjesumic   115.0      Created.
     18 Sep 98        tjesumic   115.1      log purge added.
     18 Sep 98        tjesumic   115.2      log purge added.
     16 Feb 06        tjesumic   115.6      the system allows to delete the extract dfn though  the result exist
                                            the resull without defintion can be deleted now
     01-May-07        tjesumic   115.7      commit added for every result and every 1000 log for performance
*/
-----------------------------------------------------------------------------------
--
g_package              varchar2(30) := ' ben_ext_purge.';



Procedure MAIN
          (errbuf              out nocopy varchar2,   --needed by concurrent manager.
           retcode             out nocopy number,     --needed by concurrent manager.
           p_validate          in varchar2 ,
           p_ext_dfn_id        in number  default null ,
           p_ext_rslt_date     in  varchar2,
           p_business_group_id in number  ,
           p_benefit_action_id in number default null,
           p_ext_rslt_id       in number default null ) is
--
--
--
l_effective_date date  ;

cursor c_xrs (p_date date )  is
 select xrs.ext_rslt_id,xrs.ext_dfn_id ,
        xrs.object_version_number,
        xrs.eff_dt
 from   ben_ext_rslt xrs
 where  ( xrs.ext_dfn_id = p_ext_dfn_id
          or p_ext_dfn_id is null )
  and   ( xrs.ext_rslt_id = p_ext_rslt_id
          or p_ext_rslt_id is null )
  and   xrs.eff_dt  <=  p_date
  and   xrs.business_group_id = p_business_group_id ;

cursor c_xrd  (p_ext_rslt_id number)is
 select ext_rslt_dtl_id,
        object_version_number
 from   ben_ext_rslt_dtl xrd
 where  xrd.ext_rslt_id = p_ext_rslt_id  ;


cursor c_xre  (p_ext_rslt_id number)is
 select ext_rslt_err_id,
        object_version_number
 from   ben_Ext_rslt_err xre
 where  xre.ext_rslt_id = p_ext_rslt_id  ;


cursor c_Xdf (p_ext_dfn_id  number ) is
 select a.name
 from  ben_ext_dfn a
 where a.ext_dfn_id = p_ext_dfn_id ;

--
  l_proc     varchar2(72) := g_package||'main';
  l_object_version_number number ;
  l_rcd_count             number :=  0 ;
  l_file_count            number := 0;
  l_name                  ben_Ext_dfn.name%type ;
--
begin
--
  hr_Utility.set_location('Entering'||l_proc, 5);
  l_effective_date := to_date(p_ext_rslt_date, 'YYYY/MM/DD HH24:MI:SS');
  l_effective_date := to_date(to_char(trunc(l_effective_date), 'DD/MM/RRRR'),
                      'DD/MM/RRRR');

  for l_xrs in   c_xrs(l_effective_date)
  Loop

     open c_xdf(l_xrs.ext_dfn_id) ;
     fetch c_xdf into l_name  ;
     close c_Xdf ;


     hr_Utility.set_location('processing '||l_name, 5);
     --- Deleting Details
     l_rcd_count  :=  0 ;
     for l_xrd in c_xrd(l_xrs.ext_rslt_id)
     Loop
         hr_Utility.set_location('detail '||l_name || ' ' || l_rcd_count, 5);
         l_object_version_number := l_xrd.object_version_number ;
         ben_EXT_RSLT_DTL_api. delete_EXT_RSLT_DTL
                 (p_ext_rslt_dtl_id        => l_xrd.ext_rslt_dtl_id
                 ,p_object_version_number  => l_object_version_number
                 ) ;
         l_rcd_count :=  l_rcd_count + 1 ;

     End loop ;

     -- Deleting Error detail for the resultr
     for l_xre in c_xre(l_xrs.ext_rslt_id)
     Loop
         hr_Utility.set_location('error '||l_name , 5);
         l_object_version_number := l_xre.object_version_number ;
         ben_EXT_RSLT_ERR_api. delete_EXT_RSLT_ERR
                 (p_ext_rslt_err_id        => l_xre.ext_rslt_err_id
                 ,p_object_version_number  => l_object_version_number
                 ,p_effective_date        => l_xrs.eff_dt
                 ) ;

     End loop ;


     -- Deleting Result
     l_object_version_number := l_xrs.object_version_number ;
     ben_EXT_RSLT_api.delete_EXT_RSLT
              (p_ext_rslt_id => l_xrs.ext_rslt_id
              ,p_object_version_number => l_object_version_number
              ,p_effective_date        => l_xrs.eff_dt
               ) ;
     l_file_count := l_file_count + 1  ;
     fnd_file.put_line(fnd_file.log, rpad(l_name, 40)||' '||to_char(l_xrs.eff_dt)||'   '
                      || lpad(to_char(l_rcd_count),7) ) ;

     --- for performance commit every single extrct result when the mode is not rollbak

    if  not ben_populate_rbv.validate_mode
             (p_validate => p_validate)
       then
       --
       hr_utility.set_location('commit  '||l_xrs.ext_rslt_id, 15);
       commit ;

       --
    end if;

 end Loop ;

 if ben_populate_rbv.validate_mode
    (p_validate => p_validate
    )
  then
    --
    hr_utility.set_location('rollback '||l_proc, 15);
    rollback;
    --
 end if;

 -- write to logfile a successful completion message
    fnd_message.set_name('BEN','BEN_91877_GENERAL_JOB_SUCCESS');
    fnd_file.put_line(fnd_file.log, fnd_message.get);


 -- write to logfile the record count
    fnd_file.put_line(fnd_file.log,  to_char(l_file_count) ||' '||'Results are purged') ;

 commit;
 hr_utility.set_location('Exiting'||l_proc, 15);
--
--
EXCEPTION
--

    WHEN others THEN
       fnd_message.set_name('PER','FFU10_GENERAL_ORACLE_ERROR');
       fnd_message.set_token('2',substr(sqlerrm,1,200));
       fnd_file.put_line(fnd_file.log, fnd_message.get);
       fnd_message.raise_error;
--
END main;
--


Procedure chg_log_purge
          (errbuf              out nocopy varchar2,   --needed by concurrent manager.
           retcode             out nocopy number,     --needed by concurrent manager.
           p_validate          in varchar2 ,
           p_person_id         in number   default null ,
           p_effective_date    in varchar2 default null,
           p_actual_date       in varchar2 default null,
           p_business_group_id in number  ,
           p_benefit_action_id in number default null
           ) is

 cursor c_chg_log  (p_eff_date date ,
                    p_act_date date ,
                    p_person_id number )  is
 select cel.person_id,
        cel.object_version_number,
        cel.ext_chg_evt_log_id ,
        cel.chg_eff_dt
 from   ben_ext_chg_evt_log cel
 where  (cel.person_id = p_person_id
         or p_person_id is null )
  and   (trunc(cel.chg_eff_dt) <= p_eff_date
         or  p_eff_date is null )
  and   (trunc(cel.chg_actl_dt) <= p_act_date
         or p_act_date is null )
  and   cel.business_group_id = p_business_group_id
  order by cel.person_id  ;

  cursor c_name(p_person_id number) is
  select full_name
   from  per_all_people_f
   where person_id = p_person_id ;



--
  l_proc     varchar2(72) := g_package||'chg_log_purge';
  l_object_version_number  number ;
  l_log_count               number :=  0 ;
  l_person_id               number ;
  l_person_count            number := 0;
  l_prv_person_id           number := -1 ;
  l_ext_chg_evt_log_id  ben_ext_chg_evt_log.ext_chg_evt_log_id%type ;
  l_effective_date  date ;
  l_eff_date        date ;
  l_actual_date     date ;
  l_person_name     per_all_people_f.full_name%type ;
--
begin
--
  hr_Utility.set_location('Entering'||l_proc, 5);

  if p_effective_date is null and p_actual_date is null then
       fnd_message.set_name('PER','FFU10_GENERAL_ORACLE_ERROR');
       fnd_message.set_token('2' , 'Either Effective date or Actual date must be entered' );
       fnd_file.put_line(fnd_file.log,'Either Effective date or Actual date must be entered');
       fnd_message.raise_error;

  end if ;

  l_effective_date := to_date(p_effective_date, 'YYYY/MM/DD HH24:MI:SS');
  l_effective_date := to_date(to_char(trunc(l_effective_date), 'DD/MM/RRRR'),
                      'DD/MM/RRRR');

  l_actual_date := to_date(p_actual_date, 'YYYY/MM/DD HH24:MI:SS');
  l_actual_date := to_date(to_char(trunc(l_actual_date), 'DD/MM/RRRR'),
                      'DD/MM/RRRR');

  open  c_chg_log (l_effective_date,l_actual_date,p_person_id ) ;
  Loop
     fetch c_chg_log into l_person_id,
           l_object_version_number,
           l_ext_chg_evt_log_id ,
           l_eff_date
           ;
     exit when c_chg_log%notfound ;
     --- count the person when the person_id changex
     if  l_person_id <> l_prv_person_id then
         -- first time dont print , whne the second porson is in the loop
         -- first time , print for the first person
         if l_person_name  is not null  then
             -- write to logfile the record count
             fnd_file.put_line(fnd_file.log,  rpad(l_person_name,45) ||' '||lpad(l_person_count,6)) ;
             hr_utility.set_location(rpad(l_person_name,45) ||' '||lpad(l_person_count,6),99 ) ;
         end if ;
         l_person_count  := 0 ;
         l_prv_person_id := l_person_id ;
         open c_name (l_person_id) ;
         fetch c_name into l_person_name ;
         close c_name ;
     end if;


    ben_EXT_CHG_EVT_api.delete_EXT_CHG_EVT
                       (p_ext_chg_evt_log_id    => l_ext_chg_evt_log_id
                       ,p_object_version_number => l_object_version_number
                       ,p_effective_date        => l_eff_date
                       )  ;
    l_person_count  := l_person_count + 1 ;
    l_log_count     := l_log_count + 1 ;

    if  mod(l_log_count,1000) = 0 then
       if not ben_populate_rbv.validate_mode
              (p_validate => p_validate)
       then
          commit;
       end if ;
    end if;


 end loop ;

 if (l_person_count   is not null) then

      --Bug 4080783 : Display person name even when no. of records purged is 0
      --              provided person name exists.
      open c_name (p_person_id) ;
      fetch c_name into l_person_name ;
      close c_name ;

      if l_person_name is not null then
	fnd_file.put_line(fnd_file.log,  rpad(l_person_name,45) ||' '||lpad(l_person_count,6)) ;
      end if;
      hr_utility.set_location(rpad(l_person_name,45) ||' '||lpad(l_person_count,6),99 ) ;
      fnd_file.put_line(fnd_file.log,  rpad(' ',45) ||' '||'------') ;
      fnd_file.put_line(fnd_file.log,  rpad(' ',45) ||' '||lpad(l_log_count,6)) ;
      hr_utility.set_location(lpad(l_log_count,6),99 ) ;
 end if ;
 close c_chg_log ;


  if ben_populate_rbv.validate_mode
    (p_validate => p_validate
    )
  then
    --
    hr_utility.set_location('rollback '||l_proc, 15);
    rollback;
    --
 end if;

 -- write to logfile a successful completion message
    fnd_message.set_name('BEN','BEN_91877_GENERAL_JOB_SUCCESS');
    fnd_file.put_line(fnd_file.log, fnd_message.get);
 commit;
 hr_utility.set_location('Exiting'||l_proc, 15);
--
--
EXCEPTION
--
    WHEN others THEN
       fnd_message.set_name('PER','FFU10_GENERAL_ORACLE_ERROR');
       fnd_message.set_token('2',substr(sqlerrm,1,200));
       fnd_file.put_line(fnd_file.log, fnd_message.get);
       fnd_message.raise_error;

End chg_log_purge ;



END; --package

/
