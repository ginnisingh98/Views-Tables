--------------------------------------------------------
--  DDL for Package Body BEN_CONC_REPORTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_CONC_REPORTS" as
/*$Header: becncrep.pkb 120.2.12010000.2 2008/09/18 10:39:25 pvelvano ship $*/
--
/*
Name
   Benefits Concurrent reports process
Purpose
  This is a wrapper batch process that accepts parameters from conc request window
  and submits different reports.
History
  Version Date       Author     Comment
  -------+----------+----------+------------------------------------------------
  115.0   29-SEP-02  nhunur     Created
  115.7   25-oct-02  nhunur     added code for service area of ENRKIT.
  115.8   28-oct-02  nhunur     added code to exclude COMP plan types.
  115.9   06-Nov-02  hnarayan   bug 2643361 fixed cursors c_person in enrkit
  				and consmrep to pickup the address row as per
  				effective date in the svc_area_id sub query
  115.10  12-Nov-02  nhunur     Bug - 2665181 added format mask for cvg end dt
                                , cvg strt dt. Also made cvg end dt non mandatory.
  115.12  30-Dec-2002 mmudigon  NOCOPY
  115.13  09-Sep-03  rpgupta    Grade step
  				Changed cursor c_person of create_bensmrep_ranges
  				and create_enrkit_ranges to exclude GSP objects
  				and LE's
  115.14  27-Sep-04  abparekh   Bug 3905852 Changed format mask of dates passed to
                                reports in call to submit_request.
  115.15  04-Jun-06  swjain     Bug 5331889 - passed person_id as input param
                                in rep_person_selection_rule
   115.16 07-Dec-06  gsehgal    bug 5663102 Query changed remove option type code
	                              COMP.
  ------------------------------------------------------------------------------
*/
--
g_package             varchar2(80) := ' BECNCREP - ben_conc_reports';
--
g_person_cnt number        := 0;
g_person_actn_cnt number   := 0;
g_error_person_cnt number  := 0;
-- Global structure to hold the parameters that are passed into the master
-- process
--
type g_processes_table is table of number index by binary_integer;
g_processes_rec g_processes_table;
--
--
type g_parm_list is record
    (report_name            varchar2(80)
    ,benefit_action_id      number(15)
    ,effective_date         varchar2(30)
    ,business_group_id      number(15)
    ,person_id              number(15)
    ,person_type_id         number(15)
    ,person_sel_rl          number(15)
    ,organization_id        number(15)
    ,location_id            number(15)
    ,ler_id                 number(15)
    ,pgm_id                 number(15)
    ,pl_nip_id              number(15)
    ,plan_in_pgm_flag       varchar2(30)
    ,comp_selection_rl      number(15)
    ,lf_evt_ocrd_dt         varchar2(30) -- date
    ,rptg_grp               number(15)
    ,svc_area_id 	    number(15)
    ,assgn_type             varchar2(30)
    ,cvg_strt_dt            varchar2(30) -- date
    ,cvg_end_dt             varchar2(30) -- date
    ,ben_sel_flag           varchar2(30) -- these 7 flags will be overloaded for other reports
    ,flx_sum_flag           varchar2(30)
    ,actn_items_flag        varchar2(30)
    ,cov_dpnt_flag          varchar2(30)
    ,prmy_care_flag         varchar2(30)
    ,beneficaries_flag      varchar2(30)
    ,certifications_flag    varchar2(30)
    ,disp_epe_flxfld_flag   varchar2(30)
    ,disp_flex_fields       varchar2(30));
  --
g_parm g_parm_list;
--
g_rec 			    ben_type.g_report_rec;
g_proc_rec 		    ben_type.g_batch_proc_rec;
g_strt_tm_numeric 	number;
g_end_tm_numeric 	number;
--
g_num_processes     number;
g_threads           number;
g_chunk_size        number;
g_max_errors        number;
g_num_ranges        number;
-- ----------------------------------------------------------------------------
-- -----------------------< initialize_globals >-------------------------------
-- ----------------------------------------------------------------------------
--
procedure initialize_globals is
begin
  --
  --fnd_file.put_line(fnd_file.log,'Inside initialise globals ');
  g_person_cnt := 0;
  g_person_actn_cnt  := 0;
  g_error_person_cnt := 0;
  --
  g_strt_tm_numeric := null;
  g_proc_rec.business_group_id := null;
  g_proc_rec.strt_dt := null;
  g_proc_rec.strt_tm := null;
  --
  g_parm.benefit_action_id := null;
  g_parm.effective_date    := null;
  g_parm.business_group_id := null;
  g_parm.person_id         := null;
  g_parm.person_type_id    := null;
  g_parm.person_sel_rl     := null;
  g_parm.organization_id   := null;
  g_parm.location_id       := null;
  g_parm.ler_id            := null;
  g_parm.pgm_id            := null;
  g_parm.pl_nip_id         := null;
  g_parm.plan_in_pgm_flag  := null;
  g_parm.comp_selection_rl := null;
  g_parm.lf_evt_ocrd_dt    := null;
  --
  --  fnd_file.put_line(fnd_file.log,'half way ');
  g_parm.rptg_grp             := null;
  g_parm.svc_area_id 	      := null ;
  g_parm.assgn_type           := null ;
  g_parm.cvg_strt_dt          := null;
  g_parm.cvg_end_dt           := null;
  g_parm.ben_sel_flag         := null;
  g_parm.flx_sum_flag         := null;
  g_parm.actn_items_flag      := null;
  g_parm.cov_dpnt_flag        := null;
  g_parm.prmy_care_flag       := null;
  g_parm.beneficaries_flag    := null;
  g_parm.certifications_flag  := null ;
  g_parm.disp_flex_fields     := null ;
  g_parm.disp_epe_flxfld_flag := null ;
  --
  g_num_processes       := 0 ;
  g_threads             := 3 ;
  g_chunk_size          := 10 ;
  g_max_errors          := 20 ;
  g_num_ranges          := 0 ;
  --fnd_file.put_line(fnd_file.log,'Leaving initialise globals ');

end initialize_globals;
--
-- ----------------------------------------------------------------------------
-- -----------------------< person_error_cnt >---------------------------------
-- ----------------------------------------------------------------------------
procedure person_error_cnt is
--
  error_limit exception;
  --
  l_proc varchar2(80) := g_package || '.person_error_cnt';
--
begin
--
  hr_utility.set_location('Entering : ' || l_proc, 10);
  --
  -- Increment the error count
  --
  g_error_person_cnt := g_error_person_cnt + 1;
  --
  hr_utility.set_location('Leaving : ' || l_proc, 10);
--
end person_error_cnt;
--
-- ----------------------------------------------------------------------------
-- -----------------------< print_parameters >---------------------------------
-- ----------------------------------------------------------------------------
--
procedure print_parameters is
--
  l_proc varchar2(80) := g_package || '.print_parameters';
--
begin
--
  hr_utility.set_location('Entering : ' || l_proc, 10);
  --
  if fnd_global.conc_request_id = -1 then
    return;
  end if;
  --
  fnd_file.put_line(which => fnd_file.log
                   ,buff  => 'Runtime Parameters');
  --
  fnd_file.put_line(which => fnd_file.log
                   ,buff  => '---------------------------');
  --
  fnd_file.put_line(which => fnd_file.log
                   ,buff  => 'Benefit Action ID          : '||
                    benutils.iftrue
                      (p_expression => g_parm.benefit_action_id is null
                      ,p_true       => 'NONE'
                      ,p_false      => g_parm.benefit_action_id));
  --
  fnd_file.put_line(which => fnd_file.log
                   ,buff  => 'Effective Date             : '||
                    g_parm.effective_date );
--                    to_char(g_parm.effective_date,'DD-MON-YYYY'));
  --
  fnd_file.put_line(which => fnd_file.log
                   ,buff  => 'Business Group ID          : '||
                    g_parm.business_group_id);
  --
  fnd_file.put_line(which => fnd_file.log
                   ,buff  => 'Person ID                  : ' ||
                    benutils.iftrue
                      (p_expression => g_parm.person_id is null
                      ,p_true       => 'All'
                      ,p_false      => g_parm.person_id));
  --
  fnd_file.put_line(which => fnd_file.log
                   ,buff  => 'Person Type ID             : ' ||
                    benutils.iftrue
                      (p_expression => g_parm.person_type_id is null
                      ,p_true       => 'All'
                      ,p_false      => g_parm.person_type_id));
  --
  fnd_file.put_line(which => fnd_file.log
                   ,buff  => 'Person Selection Rule      : ' ||
                    benutils.iftrue
                      (p_expression => g_parm.person_sel_rl is null
                      ,p_true       => 'All'
                      ,p_false      => g_parm.person_sel_rl));
  --
  fnd_file.put_line(which => fnd_file.log
                   ,buff  => 'Comp Object Selection Rule : ' ||
                    benutils.iftrue
                      (p_expression => g_parm.comp_selection_rl is null
                      ,p_true       => 'All'
                      ,p_false      => g_parm.comp_selection_rl));
  --
  fnd_file.put_line(which => fnd_file.log
                   ,buff  => 'Organization ID            : ' ||
                    benutils.iftrue
                      (p_expression => g_parm.organization_id is null
                      ,p_true       => 'All'
                      ,p_false      => g_parm.organization_id));
  --
  fnd_file.put_line(which => fnd_file.log
                   ,buff  => 'Location ID                : ' ||
                    benutils.iftrue
                      (p_expression => g_parm.location_id is null
                      ,p_true       => 'All'
                      ,p_false      => g_parm.location_id));
  --
  fnd_file.put_line(which => fnd_file.log
                   ,buff  => 'Life Event Reason ID       : ' ||
                    benutils.iftrue
                      (p_expression => g_parm.ler_id is null
                      ,p_true       => 'All'
                      ,p_false      => g_parm.ler_id));
  --
  fnd_file.put_line(which => fnd_file.log
                   ,buff  => 'Life Event Occured Date    : ' ||
                    benutils.iftrue
                      (p_expression => g_parm.lf_evt_ocrd_dt is null
                      ,p_true       => 'All'
                      ,p_false      => g_parm.lf_evt_ocrd_dt));
  --
  fnd_file.put_line(which => fnd_file.log
                   ,buff  => 'Program ID                 : '||
                    benutils.iftrue
                      (p_expression => g_parm.pgm_id is null
                      ,p_true       => 'All'
                      ,p_false      => g_parm.pgm_id));
  --
  fnd_file.put_line(which => fnd_file.log,
                    buff  => 'Plan ID                    : '||
                    benutils.iftrue
                      (p_expression => g_parm.pl_nip_id is null
                      ,p_true       => 'All'
                      ,p_false      => g_parm.pl_nip_id));
  --
  fnd_file.put_line(which => fnd_file.log,
                    buff  => 'Service Area               : '||
                    benutils.iftrue
                      (p_expression => g_parm.svc_area_id is null
                      ,p_true       => 'All'
                      ,p_false      => g_parm.svc_area_id));
  --
  fnd_file.put_line(which => fnd_file.log,
                    buff  => 'Assignment Type            : '||
                    benutils.iftrue
                      (p_expression => g_parm.assgn_type is null
                      ,p_true       => 'All'
                      ,p_false      => g_parm.assgn_type));
  --
  fnd_file.put_line(which => fnd_file.log,
                    buff  => 'Coverage Start Date        : '||
                    benutils.iftrue
                      (p_expression => g_parm.cvg_strt_dt is null
                      ,p_true       => 'All'
                      ,p_false      => g_parm.cvg_strt_dt));
  --
  fnd_file.put_line(which => fnd_file.log,
                    buff  => 'Coverage End Date          : '||
                    benutils.iftrue
                      (p_expression => g_parm.cvg_end_dt is null
                      ,p_true       => 'All'
                      ,p_false      => g_parm.cvg_end_dt));
  --
  fnd_file.put_line(which => fnd_file.log,
                    buff  => 'Is plan in program?        : '||
                    g_parm.plan_in_pgm_flag);
  --
    fnd_file.put_line(which => fnd_file.log,
                    buff  => 'Benefits Selection         : '||
                    g_parm.ben_sel_flag);
  --
  fnd_file.put_line(which => fnd_file.log,
                    buff  => 'Flex Credit Summary        : '||
                    g_parm.flx_sum_flag);
  --
  fnd_file.put_line(which => fnd_file.log,
                    buff  => 'Action Items Flag          : '||
                    g_parm.actn_items_flag);
  --
  fnd_file.put_line(which => fnd_file.log,
                    buff  => 'Covered Dependent Flag     : '||
                    g_parm.cov_dpnt_flag);
  --
  fnd_file.put_line(which => fnd_file.log,
                    buff  => 'Primary Care Provider Flag : '||
                    g_parm.prmy_care_flag);
  --
  fnd_file.put_line(which => fnd_file.log,
                    buff  => 'Beneficiaries Flag         : '||
                    g_parm.beneficaries_flag);
  --
  fnd_file.put_line(which => fnd_file.log,
                    buff  => 'Certifications Flag        : '||
                    g_parm.certifications_flag);
  --
  fnd_file.put_line(which => fnd_file.log,
                    buff  => 'Display Flexfields Flag    : '||
                    g_parm.disp_flex_fields);

  --
  fnd_file.put_line(which => fnd_file.log,
                    buff  => 'Elec Choice Flexfields Flag: '||
                    g_parm.disp_epe_flxfld_flag );

  hr_utility.set_location('Leaving : ' || l_proc, 10);
  --
--
end print_parameters;
--
--
function verify_person_type_id(p_person_id in number,
                               p_person_type_id in number)
return boolean is
  --
  cursor c1 is
  select 'Y'
    from per_all_people_f ppf, per_person_types ppt
   where ppf.person_id = p_person_id
     and ppf.person_type_id = p_person_type_id
     and ppf.business_group_id = g_parm.business_group_id
     and g_parm.effective_date between ppf.effective_start_date
                                   and ppf.effective_end_date
     and ppf.person_type_id = ppt.person_type_id
     and ppt.business_group_id = g_parm.business_group_id
     and ppt.active_flag = 'Y';
  --
  l_success    varchar2(30) := null;
  --
begin
  --
  if p_person_type_id is null then
     --
     return(true);
     --
  end if;
  --
  open  c1;
  fetch c1 into l_success;
  close c1;
  --
  if l_success = 'Y' then
     --
     return(true);
     --
  else
     --
     return(false);
     --
  end if;
  --
end verify_person_type_id;
--
-- ----------------------------------------------------------------------------
-- -------------------------< check_business_rules >---------------------------
-- ----------------------------------------------------------------------------
--
procedure check_business_rules is
--
  cursor c1 is
  select null
    from per_all_people_f ppf, per_person_types ppt
   where ppf.person_id = g_parm.person_id
     and ppf.person_type_id = g_parm.person_type_id
     and ppf.business_group_id = g_parm.business_group_id
     and g_parm.effective_date between ppf.effective_start_date
                                   and ppf.effective_end_date
     and ppf.person_type_id = ppt.person_type_id
     and ppt.business_group_id = g_parm.business_group_id
     and ppt.active_flag = 'Y';
  --
  l_person_type varchar2(30);
  l_dummy varchar2(30);
  --
  l_proc varchar2(80) := g_package || '.check_business_rules';
--
begin
--
  -- fnd_file.put_line(fnd_file.log,'Inside check rules ');
  hr_utility.set_location ('Entering '||l_proc,10);
  --
  -- This procedure checks validity of parameters that have been passed
  --
  -- Check if mandatory arguments have been stipulated
  --
  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'p_business_group_id',
                             p_argument_value => g_parm.business_group_id);
  --
  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'p_effective_date',
                             p_argument_value => g_parm.effective_date);
  --
  --
  -- Business Rule Checks
  --
  -- p_person_selection_rule_id and p_person_id are mutually exclusive
  --
  if g_parm.person_id is not null and
     g_parm.person_sel_rl is not null then
    fnd_message.set_name('BEN','BEN_91745_RULE_AND_PERSON');
    fnd_message.set_token('PROC',l_proc);
    fnd_message.set_token('PERSON_ID',to_char(g_parm.person_id));
    fnd_message.set_token('PER_SELECT_RL',
                 'person_selection_rule :'||g_parm.person_sel_rl);
    fnd_file.put_line(fnd_file.log, fnd_message.get );
    fnd_message.raise_error;
  end if;
  --
  -- p_person_id must be of p_person_type_id specified
  --
  if g_parm.person_id is not null and
     g_parm.person_type_id is not null then
    --
    -- Make sure person is of the person type specified
    --
    if not(verify_person_type_id(p_person_id      => g_parm.person_id,
                                 p_person_type_id => g_parm.person_type_id)) then
      --
      fnd_message.set_name('BEN','BEN_91748_PERSON_TYPE');
      fnd_message.set_token('PROC',l_proc);
      fnd_message.set_token('PERSON_ID',to_char(g_parm.person_id));
      fnd_message.set_token('PER_TYPE_ID',to_char(g_parm.person_type_id));
      fnd_file.put_line(fnd_file.log, fnd_message.get );
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  -- If a plan is specified as not in a program then the pgm_id should be null
  --
/*
  if g_parm.plan_in_pgm_flag = 'N' and
     g_parm.pgm_id is not null then
    --
    fnd_message.set_name('BEN', 'BEN_92164_PLN_NIP_PGM_NULL');
    -- If you specify a plan as not in a program then the program should be blank.
    fnd_message.set_token('PROC',l_proc);
    fnd_message.raise_error;
    --
  end if;
  --
  if g_parm.plan_in_pgm_flag = 'Y' and
     g_parm.pl_nip_id is not null then
    --
    fnd_message.set_name('BEN', 'BEN_92164_PLN_NIP_PGM_NULL');
    -- If you specify a plan as not in a program then the program should be blank.
    fnd_message.set_token('PROC',l_proc);
    fnd_message.raise_error;
    --
  end if;
*/
  --
  if g_parm.pgm_id is not null and
     g_parm.pl_nip_id is not null then
    --
    fnd_message.set_name('BEN', 'BEN_93247_PLN_NIP_PGM_NULL');
    -- If you specify a plan as not in a program then the program should be blank.
    fnd_message.set_token('PROC',l_proc);
    fnd_file.put_line(fnd_file.log, fnd_message.get );
    fnd_message.raise_error;
    --
  end if;
  --
  if ( g_parm.report_name = 'BEENRKIT' and
      ( g_parm.cvg_strt_dt is not null or g_parm.cvg_end_dt is not null )) then
     --
     fnd_message.set_name('BEN', 'BEN_93245_INVALID_PARM_VALUE');
     fnd_message.set_token('PROC',l_proc);
     fnd_file.put_line(fnd_file.log, fnd_message.get );
     fnd_message.raise_error;
     --
  end if;
  --
  if ( g_parm.report_name = 'BENSMREP' and
       ( g_parm.disp_flex_fields is not null or g_parm.disp_epe_flxfld_flag is not null )) then
       --
       fnd_message.set_name('BEN', 'BEN_93246_INVALID_PARM_VALUE');
       fnd_message.set_token('PROC',l_proc);
       fnd_file.put_line(fnd_file.log, fnd_message.get );
       --
  end if;

  --
  -- If cvg start date is specified then cvg end date must be specified
  --
  if ((g_parm.cvg_strt_dt is not null and g_parm.cvg_end_dt is null )
     or (g_parm.cvg_end_dt is not null and g_parm.cvg_strt_dt is null )) then
     --
     fnd_message.set_name('BEN', 'BEN_93237_CVG_START_END_DT');
     fnd_message.set_token('PROC',l_proc);
     fnd_file.put_line(fnd_file.log, fnd_message.get );
     fnd_message.raise_error;
     --
  end if;
  --
  hr_utility.set_location ('Leaving '||l_proc,10);
  --
end check_business_rules;
--
-- ==================================================================================
--                        << Procedure: rep_person_selection_rule >>
--  Description:
--   this procedure is called from 'process'.  It calls the person selection rule.
-- ==================================================================================
procedure rep_person_selection_rule
     (p_person_id                in  Number
     ,p_business_group_id        in  Number
     ,p_person_selection_rule_id in  Number
     ,p_effective_date           in  Date
     ,p_batch_flag               in  Boolean default FALSE
     ,p_return                   in out nocopy varchar2
     ,p_err_message              in out nocopy varchar2 ) as

  Cursor c1 is
      Select assignment_id
        From per_assignments_f paf
       Where paf.person_id = p_person_id
         and paf.assignment_type <> 'C'
         And paf.primary_flag = 'Y'
         And paf.business_group_id = p_business_group_id
         And p_effective_date between
             paf.effective_start_date and paf.effective_end_date ;
  --
  l_proc   	   varchar2(80) := g_package||'.rep_person_selection_rule';
  l_outputs   	   ff_exec.outputs_t;
  l_return  	   varchar2(30);
  l_assignment_id  number;
  l_actn           varchar2(80);
  value_exception  exception ;
Begin
  hr_utility.set_location ('Entering '||l_proc,10);
  --
  -- Get assignment ID form per_assignments_f table.
  --
  l_actn := 'Opening C1 Assignment cursor...';
  open c1;
  fetch c1 into l_assignment_id;
  If c1%notfound then
      raise ben_batch_utils.g_record_error;
  End if;
  close c1;
  -- Call formula initialise routine
  --
  l_actn := 'Calling benutils.formula procedure...';

  l_outputs := benutils.formula
                      (p_formula_id        => p_person_selection_rule_id
                      ,p_effective_date    => p_effective_date
                      ,p_business_group_id => p_business_group_id
                      ,p_assignment_id     => l_assignment_id
                      ,p_param1            => 'BEN_IV_PERSON_ID'          -- Bug 5331889
                      ,p_param1_value      => to_char(p_person_id));
  p_return := l_outputs(l_outputs.first).value;
  --
  -- fnd_file.put_line(fnd_file.log, to_char(l_assignment_id)||' -> ' || p_return );
  l_actn := 'Evaluating benutils.formula return...';
  --
  If upper(p_return) not in ('Y', 'N')  then
      Raise value_exception ;
  End if;
  --
  hr_utility.set_location ('Leaving '||l_proc,10);
Exception
  When ben_batch_utils.g_record_error then
      p_return := 'N' ;
      fnd_message.set_name('BEN','BEN_91698_NO_ASSIGNMENT_FND');
      fnd_message.set_token('ID' ,to_char(p_person_id) );
      fnd_message.set_token('PROC',l_proc  ) ;
      p_err_message := fnd_message.get ;

  When value_exception then
      p_return := 'N' ;
      fnd_message.set_name('BEN','BEN_91329_FORMULA_RETURN');
      fnd_message.set_token('RL','person_selection_rule_id :'||p_person_selection_rule_id);
      fnd_message.set_token('PROC',l_proc  ) ;
      p_err_message := fnd_message.get ;

  when others then
      p_return := 'N' ;
      p_err_message := 'A unhandled exception has been raised while processing Person : '||to_char(p_person_id)
                       ||' in package : '|| l_proc ||'.';

End rep_person_selection_rule;
--
-- ============================================================================
--                     << comp_selection_Rule >>
-- ============================================================================
--
function comp_selection_rule
                 (p_person_id                in     number
                 ,p_business_group_id        in     number
                 ,p_pgm_id                   in     number
                 ,p_pl_id                    in     number
                 ,p_pl_typ_id                in     number
                 ,p_opt_id                   in     number
                 ,p_ler_id                   in     number
                 ,p_oipl_id                  in     number
                 ,p_comp_selection_rule_id   in     number
                 ,p_effective_date           in     date
                 ) return char is
  cursor c1 is
      select assignment_id,organization_id
        from per_assignments_f paf
       where paf.person_id = p_person_id
         and paf.assignment_type <> 'C'
         and paf.primary_flag = 'Y'
         and paf.business_group_id = p_business_group_id
         and p_effective_date between
                 paf.effective_start_date and paf.effective_end_date;

  l_proc             varchar2(80) := g_package||' .comp_selection_rule';
  l_outputs   	     ff_exec.outputs_t;
  l_return  	     varchar2(30);
  l_assignment_id    number;
  l_organization_id  number;
  l_step             integer;
  asg_record_error   exception;
  wrong_output_error exception;
begin
     l_step := 10;
     hr_utility.set_location ('Entering '||l_proc,10);
     --
     -- Get assignment ID,organization_id form per_assignments_f table.
     --
     open c1;
     fetch c1 into l_assignment_id,l_organization_id;
     if c1%notfound then
	     close c1;
         ben_batch_utils.rpt_error(p_proc => l_proc,
                         p_last_actn => 'Step = '||to_char(l_step),p_rpt_flag => TRUE);
         fnd_message.set_name('BEN','BEN_91698_NO_ASSIGNMENT_FND');
         fnd_message.set_token('PROC',l_proc);
         fnd_message.set_token('ID' , to_char(p_person_id));
         raise asg_record_error;
	 else
		 close c1;
     end if;

     -- Call formula initialise routine
     --
     l_outputs := benutils.formula
                      (p_formula_id        => p_comp_selection_rule_id
                      ,p_effective_date    => p_effective_date
                      ,p_pgm_id            => p_pgm_id
                      ,p_pl_id             => p_pl_id
                      ,p_pl_typ_id         => p_pl_typ_id
                      ,p_opt_id            => p_opt_id
                      ,p_ler_id            => p_ler_id
                      ,p_business_group_id => p_business_group_id
                      ,p_assignment_id     => l_assignment_id
                      ,p_organization_id   => l_organization_id
                      ,p_jurisdiction_code => null);

     l_return := l_outputs(l_outputs.first).value;
     l_step := 30;
     if upper(l_return) not in ('Y', 'N')  then
          --
          ben_batch_utils.rpt_error(p_proc => l_proc,
                        p_last_actn => 'Step = '||to_char(l_step),p_rpt_flag => TRUE);
          fnd_message.set_name('BEN','BEN_91329_FORMULA_RETURN');
          fnd_message.set_token('RL','formula_id :'||p_comp_selection_rule_id);
          fnd_message.set_token('PROC',l_proc);
          raise wrong_output_error;
     end if;
     return l_return;
     hr_utility.set_location ('Leaving '||l_proc,10);
exception
    When asg_record_error then
         ben_batch_utils.rpt_error(p_proc => l_proc,
                p_last_actn => 'Step = '||to_char(l_step),p_rpt_flag => TRUE);
    When wrong_output_error then
         ben_batch_utils.rpt_error(p_proc => l_proc,
                p_last_actn => 'Step = '||to_char(l_step),p_rpt_flag => TRUE);
    when others then
         ben_batch_utils.rpt_error(p_proc => l_proc,
                p_last_actn => 'Step = '||to_char(l_step),p_rpt_flag => TRUE);
end comp_selection_rule;
--
-- ----------------------------------------------------------------------------
-- -----------------------< write_logfile >------------------------------------
-- ----------------------------------------------------------------------------
--
procedure write_logfile is
--
  l_proc varchar2(80) := g_package || '.write_logfile';
--
begin
--
  hr_utility.set_location('Entering : ' || l_proc, 10);
  --
  benutils.write(p_text => benutils.g_banner_minus);
  benutils.write(p_text => 'Batch Process Statistical Information');
  benutils.write(p_text => benutils.g_banner_minus);
  benutils.write(p_text => 'People processed : ' || g_person_cnt);
  benutils.write(p_text => 'People errored   : ' || g_error_person_cnt);
  benutils.write(p_text => benutils.g_banner_minus);
  --
  benutils.write_table_and_file(p_table => true
                               ,p_file  => true);
  commit;
  --
  hr_utility.set_location('Leaving : ' || l_proc, 10);
  --
exception
  --
  when others then
    --
    benutils.write(p_text => sqlerrm);
    fnd_message.set_name('BEN','BEN_91663_BENMNGLE_LOGGING');
    fnd_message.set_token('PROC',l_proc);
    benutils.write(p_text => fnd_message.get);
    fnd_message.raise_error;
    --
end write_logfile;
--
-- ----------------------------------------------------------------------------
-- ---------------------------< create_actions_ranges >------------------------
-- ----------------------------------------------------------------------------
--
-- This procedure creates person actions and batch ranges based on the chunk
-- size. The in-out parameters keep track of the person action ids created.
--
procedure create_actions_ranges
  (p_person_id                in     number  default null
  ,p_ler_id                   in     number  default null
  ,p_start_person_action_id   in out nocopy number
  ,p_ending_person_action_id  in out nocopy number) is
--
  l_person_ok varchar2(1) := 'Y';
  l_person_action_id number;
  l_object_version_number number;
  l_range_id number;
  --
  l_proc varchar2(80) := g_package || '.create_actions_ranges';
--
 rl_ret              char(1);
 skip                boolean;
 l_err_message       varchar2(2000);
 l_actn              varchar2(2000);
begin
  --
  hr_utility.set_location('Entering : ' || l_proc, 10);
  --
  skip := FALSE;
  rl_ret := 'Y';
  --
  l_err_message := null ;
  --
  if g_parm.person_sel_rl is not null then
  --
    rep_person_selection_rule
       		(p_person_id                => p_person_id
       		,p_business_group_id        => g_parm.business_group_id
       		,p_person_selection_rule_id => g_parm.person_sel_rl
       		,p_effective_date           => g_parm.effective_date
       	        ,p_return                   => rl_ret
       		,p_err_message              => l_err_message ) ;

             l_actn := 'After call to person selection rule ...';
       	     if l_err_message  is not null
       	     then
       	         Ben_batch_utils.write(p_text =>
               		'<< Person id : '||to_char(p_person_id)||' failed.'||
       			    '   Reason : '|| l_err_message ||' >>' );
       			 skip := TRUE;
             else
                If (rl_ret = 'N') then
                    skip := TRUE;
                End if;
       	     end if;
  end if;
  --
  -- fnd_file.put_line(fnd_file.log, ' after person selection rule ');
  -- Create a person action only if the person passes the person selection rule
    If ( not skip) then
        --
	    hr_utility.set_location('not skip...Inserting Ben_person_actions',28);
  	-- fnd_file.put_line(fnd_file.log, 'not skip...Inserting Ben_person_actions');
        --
        l_actn := 'Create person actions ...';
        ben_person_actions_api.create_person_actions(
    	      p_validate              => false
	     ,p_person_action_id      => l_person_action_id
	     ,p_person_id             => p_person_id
	     ,p_ler_id                => p_ler_id
	     ,p_benefit_action_id     => g_parm.benefit_action_id
	     ,p_action_status_cd      => 'U'
	     ,p_object_version_number => l_object_version_number
    	     ,p_effective_date        => g_parm.effective_date);

          g_person_actn_cnt := g_person_actn_cnt + 1;

          if mod(g_person_actn_cnt, g_chunk_size) = 1 or g_chunk_size = 1
	      then
              p_start_person_action_id := l_person_action_id;
          end if;
          --
          p_ending_person_action_id := l_person_action_id;
          --
    	  -- fnd_file.put_line(fnd_file.log, 'after we get start , end action ids');
          if mod(g_person_actn_cnt, g_chunk_size) = 0 or g_chunk_size = 1 then
            --
            -- fnd_file.put_line(fnd_file.log, ' before create_batch_ranges');
            ben_batch_ranges_api.create_batch_ranges
            (p_validate                  => FALSE
            ,p_effective_date            => g_parm.effective_date
            ,p_benefit_action_id         => g_parm.benefit_action_id
            ,p_range_id                  => l_range_id
            ,p_range_status_cd           => 'U'
            ,p_starting_person_action_id => p_start_person_action_id
            ,p_ending_person_action_id   => p_ending_person_action_id
            ,p_object_version_number     => l_object_version_number);
            --
            g_num_ranges := g_num_ranges + 1;
            --
      	    -- fnd_file.put_line(fnd_file.log, ' after create_batch_ranges');
          end if;
    else
        -- persons excluded by the selection rule report them on the audit log
        l_actn := 'Print person header information ...';
	ben_batch_utils.person_header
         (p_person_id           => p_person_id
         ,p_business_group_id   => g_parm.business_group_id
         ,p_effective_date      => g_parm.effective_date );
     	  fnd_file.put_line(fnd_file.log, ' persons excluded by the selection rule');
    end if;
  --
  hr_utility.set_location('Leaving : ' || l_proc, 10);
  -- fnd_file.put_line(fnd_file.log, ' Leaving : create_actions_ranges ');
--
exception
  when others then
    fnd_file.put_line(fnd_file.log, sqlerrm || ' ' || sqlcode);
    raise;
--
end create_actions_ranges;
--
-- ==================================================================================
--                        << Procedure: create_bensmrep_ranges >>
--  Description:
--              Benefits Confirmation Summary report sub process
-- ==================================================================================
--
procedure create_bensmrep_ranges is
 -- Cursor for selecting the persons for the report based on the
 -- parameters in the wrapper concurrent program
 --
 cursor c_person is
 	select distinct pen.person_id
	    from   ben_prtt_enrt_rslt_f pen , ben_pl_typ_f ptyp ,
	           ben_per_in_ler pil
	    where   pen.prtt_enrt_rslt_stat_cd is null
	    and     pen.sspndd_flag = 'N' /* unsuspended enrollments */
	    and    (pen.person_id = g_parm.person_id or g_parm.person_id is null)
	    and    (pen.pl_id = g_parm.pl_nip_id  or g_parm.pl_nip_id is null)
	    and    (pen.pgm_id = g_parm.pgm_id or g_parm.pgm_id is null)
	    and    (g_parm.cvg_strt_dt is null  or  pen.enrt_cvg_strt_dt >= g_parm.cvg_strt_dt )
	    and    (g_parm.cvg_end_dt is null  or   pen.enrt_cvg_thru_dt <= g_parm.cvg_end_dt  )
	    and     pen.business_group_id = g_parm.business_group_id
	    and     pen.pl_typ_id  = ptyp.pl_typ_id
	    -- bug 5663102
			-- and     ptyp.opt_typ_cd not in ( 'COMP' , 'CWB' , 'GSP', 'ABS')
			and     ptyp.opt_typ_cd not in ('CWB' , 'GSP', 'ABS')
	    /* Added GSP for grade step*/
 	    and     ptyp.business_group_id = g_parm.business_group_id
	    and     g_parm.effective_date between ptyp.effective_start_date and ptyp.effective_end_date
	    and     g_parm.effective_date between pen.enrt_cvg_strt_dt and pen.enrt_cvg_thru_dt
	    and     pen.enrt_cvg_thru_dt <= pen.effective_end_date
		/* all persons within the specified organization */
	    and    (g_parm.organization_id is null
	    	    or exists ( select '1' from
				(select assignment_id,assignment_type,organization_id,person_id
				       from per_all_assignments_f paf
					   where business_group_id = g_parm.business_group_id
					   and paf.person_id= nvl(g_parm.person_id,paf.person_id)
					   and  g_parm.effective_date
							   between nvl(effective_start_date,g_parm.effective_date )
					       and  nvl(effective_end_date, g_parm.effective_date )
					   and  primary_flag = 'Y'
					   )paf1
				where paf1.organization_id = g_parm.organization_id
				and paf1.assignment_type='E'
				and paf1.person_id=pen.person_id
				union
			select '1' from
			(select assignment_id,assignment_type,organization_id,person_id
			       from per_all_assignments_f paf
				   where business_group_id = g_parm.business_group_id
				   and paf.person_id= nvl(g_parm.person_id,paf.person_id)
				   and  g_parm.effective_date
						   between nvl(effective_start_date,g_parm.effective_date )
				       and  nvl(effective_end_date, g_parm.effective_date )
				   and  primary_flag = 'Y'
				   )paf1
			where paf1.organization_id = g_parm.organization_id
			and paf1.person_id=pen.person_id
			and (paf1.assignment_type='B' and not exists (select 1 from per_all_assignments_f paf2
			where paf2.person_id = paf1.person_id
				   and  paf2.business_group_id = g_parm.business_group_id
				   and  g_parm.effective_date
						   between nvl(paf2.effective_start_date,g_parm.effective_date )
				       and  nvl(paf2.effective_end_date, g_parm.effective_date )
				   and  paf2.primary_flag = 'Y'
				   and  paf2.assignment_type='E')) ))
	    /* person exists with specified person type */
	    and    (g_parm.person_type_id is null
	            or exists (select null
	                       from per_person_type_usages ptu
	                       where ptu.person_id = pen.person_id
	                       and ptu.person_type_id = g_parm.person_type_id))
	    /* person exists with specified assignment type */
	    and    (g_parm.assgn_type is null
	            or exists (select null
	                       from per_assignments_f asg
	                       where asg.assignment_type = substr(g_parm.assgn_type,1,1)
	                       and asg.person_id = pen.person_id
	                       and asg.assignment_type <> 'C'
	                       and asg.primary_flag = 'Y'
	                       and asg.business_group_id = pen.business_group_id
	                       and g_parm.effective_date
	                           between asg.effective_start_date and asg.effective_end_date))
	    /* person exists with specified location */
	    and    (g_parm.location_id is null
	            or exists (select null
	                       from per_assignments_f asg
	                       where asg.location_id = g_parm.location_id
	                       and asg.person_id = pen.person_id
	                       and asg.assignment_type <> 'C'
	                       and asg.primary_flag = 'Y'
	                       and asg.business_group_id = pen.business_group_id
	                       and g_parm.effective_date
	                           between asg.effective_start_date and asg.effective_end_date))
	    /* person's address has zip code specified in service area */
	    and    (g_parm.svc_area_id is null
	            or exists (select null
	                       from per_addresses addr ,
				    ben_svc_area_f  svc ,
	                            ben_svc_area_pstl_zip_rng_f spz ,
	                            ben_pstl_zip_rng_f pstl
	                       where addr.person_id = pen.person_id
	                       and   addr.primary_flag = 'Y'
	                       and   svc.svc_area_id = g_parm.svc_area_id
	                       and   svc. svc_area_id  = spz.svc_area_id
	                       and   spz.pstl_zip_rng_id  =  pstl.pstl_zip_rng_id
	                       and   addr.postal_code between pstl.from_value and pstl.to_value
	                       and   svc.business_group_id = pen.business_group_id
	                       and   g_parm.effective_date
				     between addr.date_from and nvl(addr.date_to,g_parm.effective_date)
	                       and   g_parm.effective_date
				     between pstl.effective_start_date and pstl.effective_end_date
	                       and   g_parm.effective_date
				     between spz.effective_start_date and spz.effective_end_date
	                       and   g_parm.effective_date
				     between svc.effective_start_date and svc.effective_end_date))
	    and    (g_parm.ler_id is null
	            or exists ( select null
	                        from ben_per_in_ler pil2
	                        where pil2.ler_id = g_parm.ler_id
	                        and   pil2.per_in_ler_stat_cd not in ('VOIDD','BCKDT')
	                        and   pil.per_in_ler_id = pil2.per_in_ler_id ))
	    and    (g_parm.lf_evt_ocrd_dt is null
	            or exists ( select null
	                        from  ben_per_in_ler pil3
	                        where pil3.lf_evt_ocrd_dt = g_parm.lf_evt_ocrd_dt
	                        and   pil3.per_in_ler_stat_cd not in ('VOIDD','BCKDT')
	                        and   pil.per_in_ler_id = pil3.per_in_ler_id ))
	    and    pil.per_in_ler_id = pen.per_in_ler_id
	    and    pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT');
 --
 l_package                varchar2(80) := g_package||' .create_bensmrep_ranges';
 l_num_ranges             number;
 l_num_persons            number;
 l_flag                   varchar2(5);
 --
 l_start_person_action_id number;
 l_ending_person_action_id number;
 l_range_id number;
 l_object_version_number number;
 --
 l_per_rec  c_person%rowtype ;
begin
  hr_utility.set_location('Entering : ' || l_package , 10);
  --
  hr_utility.set_location('Creating actions and ranges ' || l_package , 15);
  --
  --fnd_file.put_line(fnd_file.log, 'before person loop : ');
  open c_person ;
  loop
     fetch c_person into l_per_rec ;
	 exit when c_person%notfound ;
    --
    --fnd_file.put_line(fnd_file.log, 'inside person loop : ');
    create_actions_ranges
      (p_person_id                => l_per_rec.person_id
      ,p_ler_id                   => g_parm.ler_id
      ,p_start_person_action_id   => l_start_person_action_id
      ,p_ending_person_action_id  => l_ending_person_action_id);
    --
  end loop;
  close c_person ;
  -- fnd_file.put_line(fnd_file.log, 'after person loop : ');
  --
  -- There could be a few person actions left over from the call in the for
  -- loop above. Create a batch range for them.
  --
  If g_person_actn_cnt > 0 and
     mod(g_person_actn_cnt, g_chunk_size) <> 0 then
    --
    hr_utility.set_location('Ranges for remaining people ' || l_package, 25);
    --
   --fnd_file.put_line(fnd_file.log, 'before create batch ranges ');
    ben_batch_ranges_api.create_batch_ranges
      (p_validate                  => FALSE
      ,p_effective_date            => g_parm.effective_date
      ,p_benefit_action_id         => g_parm.benefit_action_id
      ,p_range_id                  => l_range_id
      ,p_range_status_cd           => 'U'
      ,p_starting_person_action_id => l_start_person_action_id
      ,p_ending_person_action_id   => l_ending_person_action_id
      ,p_object_version_number     => l_object_version_number);
    --
    g_num_ranges := g_num_ranges + 1;
    --
  end if;
  --
  hr_utility.set_location('Leaving : ' || l_package, 10);
  --fnd_file.put_line(fnd_file.log, 'leaving create_bensmrep_ranges ');
end create_bensmrep_ranges;
--
-- ==================================================================================
--                        << Procedure: create_enrkit_ranges >>
--  Description:
--              Benefits Enrollment Kit report sub process
-- ==================================================================================
--
procedure create_enrkit_ranges is
  --
  -- Cursor to select rows from ben_per_in_ler for people that haven't enrolled
  -- in a plan or a program as of the effective date
  --
  cursor c_person is
  select distinct pil.person_id, pil.ler_id
    from ben_per_in_ler pil,
         ben_pil_elctbl_chc_popl pel,
         ben_ler_f ler
   where (g_parm.person_id is null or pil.person_id = g_parm.person_id)
     and pil.per_in_ler_stat_cd = 'STRTD'
     and pil.business_group_id = g_parm.business_group_id
     and pil.per_in_ler_id = pel.per_in_ler_id
     and pil.ler_id = ler.ler_id
     and g_parm.effective_date between ler.effective_start_date and ler.effective_end_date
     and ler.business_group_id = pil.business_group_id
     and ler.typ_cd not in ( 'GSP', 'ABS') /* added for grade step */
     and pel.elcns_made_dt is null
     and g_parm.effective_date between
         nvl(pel.enrt_perd_strt_dt, g_parm.effective_date) and
         nvl(pel.enrt_perd_end_dt, g_parm.effective_date)
     and (g_parm.pgm_id is null or pel.pgm_id = g_parm.pgm_id)
     and (g_parm.pl_nip_id is null or g_parm.pl_nip_id = pel.pl_id )
     and (g_parm.ler_id is null or pil.ler_id = g_parm.ler_id)
     and (g_parm.lf_evt_ocrd_dt is null or pil.lf_evt_ocrd_dt = g_parm.lf_evt_ocrd_dt )
     /* check if the person belongs to the org or location specified */
     and (g_parm.organization_id is null
	      or  exists (select '1'
                     from per_all_assignments_f per
                    where per.person_id = pil.person_id
                      and per.primary_flag = 'Y'
                      and per.assignment_type <> 'C'
                      and (g_parm.organization_id is null or
                           per.organization_id = g_parm.organization_id)
                      and g_parm.effective_date between per.effective_start_date
                                                    and per.effective_end_date ))
     and (g_parm.location_id is null
          or exists (select '1'
                     from per_all_assignments_f per
                    where per.person_id = pil.person_id
                      and per.primary_flag = 'Y'
                      and per.assignment_type <> 'C'
                      and (g_parm.location_id is null or
                           per.location_id = g_parm.location_id)
                      and g_parm.effective_date between per.effective_start_date
                                                    and per.effective_end_date ))
	 /* person exists with specified person type */
     and    (g_parm.person_type_id is null
	            or exists (select null
	                       from per_person_type_usages ptu
	                       where ptu.person_id = pil.person_id
	                       and   ptu.person_type_id = g_parm.person_type_id))
	 /* person exists with specified assignment type */
     and    (g_parm.assgn_type is null
	            or exists (select null
	                       from per_assignments_f asg
	                       where asg.assignment_type = substr(g_parm.assgn_type,1,1)
	                       and asg.person_id = pil.person_id
	                       and asg.assignment_type <> 'C'
	                       and asg.primary_flag = 'Y'
	                       and asg.business_group_id = pil.business_group_id
	                       and g_parm.effective_date
	                           between asg.effective_start_date and asg.effective_end_date))
     	    /* person's address has zip code specified in service area */
     and    (g_parm.svc_area_id is null
	            or exists (select null
	                       from per_addresses addr ,
				    ben_svc_area_f  svc ,
	                            ben_svc_area_pstl_zip_rng_f spz ,
	                            ben_pstl_zip_rng_f pstl
	                       where addr.person_id = pil.person_id
	                       and   addr.primary_flag = 'Y'
	                       and   svc.svc_area_id = g_parm.svc_area_id
	                       and   svc. svc_area_id  = spz.svc_area_id
	                       and   spz.pstl_zip_rng_id  =  pstl.pstl_zip_rng_id
	                       and   addr.postal_code between pstl.from_value and pstl.to_value
	                       and   svc.business_group_id = pil.business_group_id
	                       and   g_parm.effective_date
				     between addr.date_from and nvl(addr.date_to,g_parm.effective_date)
	                       and   g_parm.effective_date
				     between pstl.effective_start_date and pstl.effective_end_date
	                       and   g_parm.effective_date
				     between spz.effective_start_date and spz.effective_end_date
	                       and   g_parm.effective_date
				     between svc.effective_start_date and svc.effective_end_date));
  --
 l_package                varchar2(80) := g_package||' .create_bensmrep_ranges';
 l_num_ranges             number;
 l_num_persons            number;
 l_flag                   varchar2(5);
 --
 l_start_person_action_id number;
 l_ending_person_action_id number;
 l_range_id number;
 l_object_version_number number;
 --
 l_per_rec  c_person%rowtype ;
begin
  hr_utility.set_location('Entering : ' || l_package , 10);
  --
  hr_utility.set_location('Creating actions and ranges ' || l_package , 15);
  --
  --fnd_file.put_line(fnd_file.log, 'before person loop : ');
  open c_person ;
  loop
     fetch c_person into l_per_rec ;
	 exit when c_person%notfound ;
    --
    --fnd_file.put_line(fnd_file.log, 'inside person loop : ');
    create_actions_ranges
      (p_person_id                => l_per_rec.person_id
      ,p_ler_id                   => g_parm.ler_id
      ,p_start_person_action_id   => l_start_person_action_id
      ,p_ending_person_action_id  => l_ending_person_action_id);
    --
  end loop;
  close c_person ;
  -- fnd_file.put_line(fnd_file.log, 'after person loop : ');
  --
  -- There could be a few person actions left over from the call in the for
  -- loop above. Create a batch range for them.
  --
  If g_person_actn_cnt > 0 and
     mod(g_person_actn_cnt, g_chunk_size) <> 0 then
    --
    hr_utility.set_location('Ranges for remaining people ' || l_package, 25);
    --
   --fnd_file.put_line(fnd_file.log, 'before create batch ranges ');
    ben_batch_ranges_api.create_batch_ranges
      (p_validate                  => FALSE
      ,p_effective_date            => g_parm.effective_date
      ,p_benefit_action_id         => g_parm.benefit_action_id
      ,p_range_id                  => l_range_id
      ,p_range_status_cd           => 'U'
      ,p_starting_person_action_id => l_start_person_action_id
      ,p_ending_person_action_id   => l_ending_person_action_id
      ,p_object_version_number     => l_object_version_number);
    --
    g_num_ranges := g_num_ranges + 1;
    --
  end if;
  --
  hr_utility.set_location('Leaving : ' || l_package, 10);
  --fnd_file.put_line(fnd_file.log, 'leaving create_bensmrep_ranges ');

end ;
-- ==================================================================================
--                        << Procedure: process >>
--  Description:
--   this main procedure is called from  SRS window.
-- ==================================================================================
--
procedure process
  (errbuf                     out nocopy    varchar2
  ,retcode                    out nocopy    number
  ,p_report_name              in     varchar2
  ,p_effective_date           in     varchar2
  ,p_benefit_action_id        in     number   default null
  ,p_pgm_id                   in     number   default null
  ,p_pl_nip_id                in     number   default null
  ,p_plan_in_pgm_flag         in     varchar2 default 'N'
  ,p_organization_id          in     number   default null
  ,p_location_id              in     number   default null
  ,p_person_id                in     number   default null
  ,p_ler_id                   in     number   default null
  ,p_lf_evt_ocrd_dt           in     varchar2 default null
  ,p_person_selection_rule_id in     number   default null
  ,p_comp_selection_rule_id   in     number   default null
  ,p_business_group_id        in     number
  ,p_reporting_group_id       in     number   default null
  ,p_svc_area_id	      in     number   default null
  ,p_assignment_type          in     varchar2 default null
  ,p_cvg_strt_dt	      in     varchar2 default null
  ,p_cvg_end_dt		      in     varchar2 default null
  ,p_person_type_id           in     number   default null
  ,p_ben_sel_flag             in     varchar2 default 'Y'
  ,p_flx_sum_flag     	      in     varchar2 default 'Y'
  ,p_actn_items_flag  	      in     varchar2 default 'Y'
  ,p_cov_dpnt_flag     	      in     varchar2 default 'Y'
  ,p_prmy_care_flag           in     varchar2 default 'Y'
  ,p_beneficaries_flag        in     varchar2 default 'Y'
  ,p_certifications_flag      in     varchar2 default 'Y'
  ,p_disp_epe_flxfld_flag     in     varchar2 default 'Y'
  ,p_disp_flex_fields         in     varchar2 default 'Y' )  is
 --
 l_package                varchar2(80) := g_package||'.process';
 l_num_ranges             number;
 l_num_persons            number;
 l_flag                   varchar2(5);
 l_effective_date         date;
 l_lf_evt_ocrd_dt         date;
 l_cvg_strt_dt            date;
 l_cvg_end_dt             date;
 --
 l_request_id             number;
 l_person_id              per_all_people_f.person_id%type;
 l_object_version_number  ben_benefit_actions.object_version_number%type;
 l_benefit_action_id      ben_benefit_actions.benefit_action_id%type;
 l_person_action_id       ben_person_actions.person_action_id%type;
 --
 l_errbuf varchar2(80);
 l_retcode number;
 --
 l_commit            number;
 l_person_cnt        number;
 l_cnt               number;
 l_actn              varchar2(2000);
 l_count             number;
 --
 begin
 --
 hr_utility.set_location ('Entering '|| l_package,10);
 l_effective_date:= to_date(p_effective_date,'YYYY/MM/DD HH24:MI:SS');
 l_effective_date:= to_date(to_char(trunc(l_effective_date),'DD/MM/RRRR'),'DD/MM/RRRR');
 --
 l_lf_evt_ocrd_dt := to_date(p_lf_evt_ocrd_dt,'YYYY/MM/DD HH24:MI:SS');
 l_lf_evt_ocrd_dt := to_date(to_char(trunc(l_lf_evt_ocrd_dt),'DD/MM/RRRR'),'DD/MM/RRRR');
 --
 l_cvg_strt_dt := to_date(p_cvg_strt_dt,'YYYY/MM/DD HH24:MI:SS');
 l_cvg_strt_dt := to_date(to_char(trunc(l_cvg_strt_dt),'DD/MM/RRRR'),'DD/MM/RRRR');
 --

 l_cvg_end_dt := to_date(p_cvg_end_dt,'YYYY/MM/DD HH24:MI:SS');
 l_cvg_end_dt := to_date(to_char(trunc(l_cvg_end_dt),'DD/MM/RRRR'),'DD/MM/RRRR');

 -- Put row in fnd_sessions
 --
 dt_fndate.change_ses_date
       (p_ses_date => l_effective_date,
        p_commit   => l_commit);

 hr_utility.set_location('Checking arguments',12);
 --
 l_actn := 'Initialise globals...';

 initialize_globals;
--
-- Log start time of process
--
g_proc_rec.business_group_id := p_business_group_id;
g_proc_rec.strt_dt := sysdate;
g_proc_rec.strt_tm := to_char(sysdate,'HH24:MI:SS');
g_strt_tm_numeric := dbms_utility.get_time;
--
-- Flush the global-parameter-list and load all the passed parameters into it.
-- All the sub procedures in the main process will be able to access this list
-- and this will keep the procedure calls simple.
--
g_parm.report_name       := p_report_name ;
g_parm.benefit_action_id := p_benefit_action_id;
g_parm.effective_date    := l_effective_date;
g_parm.business_group_id := p_business_group_id;
g_parm.person_id         := p_person_id;
g_parm.person_type_id    := p_person_type_id;
g_parm.person_sel_rl     := p_person_selection_rule_id;
g_parm.organization_id   := p_organization_id;
g_parm.location_id       := p_location_id;
g_parm.ler_id            := p_ler_id;
g_parm.pgm_id            := p_pgm_id;
g_parm.pl_nip_id         := p_pl_nip_id;
g_parm.plan_in_pgm_flag  := p_plan_in_pgm_flag;
g_parm.comp_selection_rl := p_comp_selection_rule_id;
g_parm.lf_evt_ocrd_dt    := l_lf_evt_ocrd_dt;
--
g_parm.rptg_grp             := p_reporting_group_id;
g_parm.svc_area_id 	    := p_svc_area_id ;
g_parm.assgn_type           := p_assignment_type ;
g_parm.cvg_strt_dt          := to_char(l_cvg_strt_dt,'DD-MON-YYYY'); -- 2665181
g_parm.cvg_end_dt           := to_char(l_cvg_end_dt,'DD-MON-YYYY' );
g_parm.ben_sel_flag         := p_ben_sel_flag;
g_parm.flx_sum_flag         := p_flx_sum_flag;
g_parm.actn_items_flag      := p_actn_items_flag;
g_parm.cov_dpnt_flag        := p_cov_dpnt_flag;
g_parm.prmy_care_flag       := p_prmy_care_flag;
g_parm.beneficaries_flag    := p_beneficaries_flag;
g_parm.certifications_flag  := p_certifications_flag ;
g_parm.disp_epe_flxfld_flag := p_disp_epe_flxfld_flag ;
g_parm.disp_flex_fields     := p_disp_flex_fields ;
--
-- fnd_file.put_line(fnd_file.log, 'g_parm.effective_date   : ' || g_parm.effective_date);
-- fnd_file.put_line(fnd_file.log, 'g_parm.lf_evt_ocrd_dt   : ' || g_parm.lf_evt_ocrd_dt);
-- fnd_file.put_line(fnd_file.log, 'g_parm.cvg_strt_dt      : ' || g_parm.cvg_strt_dt );
-- fnd_file.put_line(fnd_file.log, 'g_parm.cvg_end_dt      : ' || g_parm.cvg_end_dt );
-- fnd_file.put_line(fnd_file.log, 'l_cvg_end_dt      : ' || to_char(l_cvg_end_dt,'dd-mon-yyyy'));
l_actn := 'check business rules ...';
-- Check the parameters for validity and incompatibilities.
check_business_rules;
 -- Get the parameters for the batch process so we know how many slaves to
 -- start and what size the chunk size is. Store them in globals.
 --
 if p_report_name = 'BENSMREP' then
    benutils.get_parameter
    (p_business_group_id => p_business_group_id
    ,p_batch_exe_cd      => 'BENSMREP'
    ,p_threads           => g_threads
    ,p_chunk_size        => g_chunk_size
    ,p_max_errors        => g_max_errors);
 elsif p_report_name = 'BEENRKIT' then
    benutils.get_parameter
    (p_business_group_id => p_business_group_id
    ,p_batch_exe_cd      => 'BEENRKIT'
    ,p_threads           => g_threads
    ,p_chunk_size        => g_chunk_size
    ,p_max_errors        => g_max_errors);
 end if;
 --
 g_threads := nvl( g_threads , 3 ) ;
 g_chunk_size := nvl( g_chunk_size , 10 );
 g_max_errors := nvl( g_max_errors , 20 );
 --
 -- fnd_file.put_line(fnd_file.log, 'g_threads      : ' || g_threads );
 -- fnd_file.put_line(fnd_file.log, 'g_chunk_size   : ' || g_chunk_size);
 -- fnd_file.put_line(fnd_file.log, 'g_max_errors   : ' || g_max_errors);
 --
 hr_utility.set_location('Num Threads = ' || g_threads, 10);
 hr_utility.set_location('Chunk Size =  ' || g_chunk_size, 10);
 hr_utility.set_location('Max Errors =  ' || g_max_errors, 10);
 --
 -- Create benefit actions parameters in the benefit action table.
 -- Do not create if a benefit action already exists, in other words
 -- we are doing a restart.
 --
 if p_benefit_action_id is null then
   --
   hr_utility.set_location('p_benefit_action_id is null',14);
   --
   -- This call inserts the parameters given and the request id of
   -- the concurrent program into the Benefit Actions table
   --
   ben_benefit_actions_api.create_perf_benefit_actions
     ( p_benefit_action_id      => l_benefit_action_id
      ,p_process_date           => l_effective_date
      ,p_person_id              => p_person_id
      ,p_pgm_id                 => p_pgm_id
      ,p_business_group_id      => p_business_group_id
      ,p_pl_id                  => p_pl_nip_id
      ,p_comp_selection_rl      => p_comp_selection_rule_id
      ,p_person_selection_rl    => p_person_selection_rule_id
      ,p_ler_id                 => p_ler_id
      ,p_organization_id        => p_organization_id
      ,p_location_id            => p_location_id
      ,p_request_id             => fnd_global.conc_request_id
      ,p_program_application_id => fnd_global.prog_appl_id
      ,p_program_id             => fnd_global.conc_program_id
      ,p_program_update_date    => sysdate
      ,p_object_version_number  => l_object_version_number
      ,p_lf_evt_ocrd_dt         => l_lf_evt_ocrd_dt
      ,p_effective_date         => l_effective_date
      ,p_mode_cd                => 'U'
      ,p_derivable_factors_flag => 'N'
      ,p_validate_flag          => 'N'
      ,p_debug_messages_flag    => 'Y'
      ,p_audit_log_flag         => 'N'
      ,p_no_programs_flag       => p_plan_in_pgm_flag
      ,p_no_plans_flag          => 'N'
      ,p_benfts_grp_id          => null
      ,p_pstl_zip_rng_id        => null
      ,p_rptg_grp_id            => NULL
      ,p_opt_id                 => NULL
      ,p_eligy_prfl_id          => NULL
      ,p_vrbl_rt_prfl_id        => NULL
      ,p_legal_entity_id        => null
      ,p_payroll_id             => null
     );

     g_parm.benefit_action_id := l_benefit_action_id;
     --
     commit;
     --
     -- Delete/clear ranges from ben_batch_ranges table
     --
     hr_utility.set_location('Delete rows from ben_batch_ranges',16);
     --
     Delete from ben_batch_ranges
     Where benefit_action_id = l_benefit_action_id;
     --
	 l_actn := 'After benefit action is created ...';
     -- Create person-actions and batch-ranges for the process.
     if p_report_name = 'BENSMREP' then
        --
	l_actn := 'Before create_bensmrep_ranges  ...';
	--
        create_bensmrep_ranges;
        --
	l_actn := 'After create_bensmrep_ranges ...';
        --
     elsif p_report_name = 'BEENRKIT' then
        --
	l_actn := 'Before create_beenrkit_ranges  ...';
	--
        create_enrkit_ranges;
        --
	l_actn := 'After create_beenrkit_ranges ...';
	--
     end if;
     --
 else -- p_benefit_action_id not null
    --
    -- Benefit action id is not null i.e. the batch process is being restarted
    -- for a certain benefit action id. Create batch ranges and person actions
    -- for restarting.
    --
    hr_utility.set_location('restart batch process ' || l_actn, 20);
    --
    ben_batch_utils.create_restart_person_actions
      (p_benefit_action_id => p_benefit_action_id
      ,p_effective_date    => l_effective_date
      ,p_chunk_size        => g_chunk_size
      ,p_threads           => g_threads
      ,p_num_ranges        => g_num_ranges
      ,p_num_persons       => g_person_cnt
      ,p_commit_data       => 'Y');
    --
    g_parm.benefit_action_id := p_benefit_action_id;
    --
 end if;
 --
 commit ;
 --
 --
 g_person_cnt := g_person_actn_cnt ;
 g_error_person_cnt := 0 ;
 --
 fnd_file.put_line(fnd_file.log, 'Number of persons selected : ' || g_person_cnt);
 --
 print_parameters ;
 --
 write_logfile ;
 -- If there were no people selected with the criteria provided, the number of
 -- ranges created would have been zero. Raise an eexception if so.
 --
 if g_num_ranges = 0 then
    l_actn := 'No persons were found eligible...';
	--
    Ben_batch_utils.write(p_text =>
          '<< No Person got selected with above selection criteria >>' );
    fnd_message.set_name('BEN','BEN_91769_NOONE_TO_PROCESS');
    fnd_message.set_token('PROC',l_package);
 end if;
 --
 -- Set the number of threads to the lesser of the defined number of threads
 -- and the number of ranges created above.
 --
 g_threads := least(g_threads, g_num_ranges);
 --
 hr_utility.set_location('Number of Threads : ' || g_threads, 20);
 --
 --fnd_file.put_line(fnd_file.log, 'Number of Threads : ' || g_threads);
 -- Submit requests
 --
 -- for l_count in 1..g_threads  loop
 if g_num_ranges <> 0 then
    --
    --
    hr_utility.set_location('Sumitting thread : ' || l_count, 25);
	--
    l_actn := 'Submit request for report ...';
	--
	if p_report_name = 'BENSMREP' then
	--
    -- fnd_file.put_line(fnd_file.log, 'before submitting request for BENSMREP ..');
    l_request_id := FND_REQUEST.SUBMIT_REQUEST
       (application  => 'BEN',
     	program      => 'BENSMREP',
        sub_request  => FALSE,
        argument1    => to_char(fnd_date.canonical_to_date(p_effective_date),'YYYY/MM/DD HH24:MI:SS') ,  /* Bug 3905852*/
        argument2    => g_parm.benefit_action_id,
        argument3    => g_parm.pgm_id ,
        argument4    => g_parm.pl_nip_id,
        argument5    => g_parm.organization_id,
        argument6    => g_parm.location_id ,
        argument7    => g_parm.person_id,
        argument8    => g_parm.ler_id,
        argument9    => to_char(fnd_date.canonical_to_date(p_lf_evt_ocrd_dt),'YYYY/MM/DD HH24:MI:SS'),  /* Bug 3905852*/
        argument10   => g_parm.person_sel_rl,
        argument11   => g_parm.comp_selection_rl,
        argument12   => g_parm.business_group_id ,
        argument13   => g_parm.plan_in_pgm_flag ,
        argument14   => g_parm.person_type_id ,
        argument15   => g_parm.rptg_grp,
        argument16   => g_parm.svc_area_id,
        argument17   => g_parm.assgn_type ,
        argument18   => to_char(fnd_date.canonical_to_date(p_cvg_strt_dt),'YYYY/MM/DD HH24:MI:SS'),   /* Bug 3905852*/
        argument19   => to_char(fnd_date.canonical_to_date(p_cvg_end_dt),'YYYY/MM/DD HH24:MI:SS'),    /* Bug 3905852*/
        argument20   => g_parm.ben_sel_flag,
        argument21   => g_parm.flx_sum_flag,
        argument22   => g_parm.cov_dpnt_flag,
        argument23   => g_parm.prmy_care_flag,
        argument24   => g_parm.beneficaries_flag,
        argument25   => g_parm.certifications_flag,
        argument26   => g_parm.actn_items_flag
        );

    elsif p_report_name = 'BEENRKIT' then
	--
    -- fnd_file.put_line(fnd_file.log, 'before submitting request for BEENRKIT..');
    l_request_id := FND_REQUEST.SUBMIT_REQUEST
       (application  => 'BEN',
     	program      => 'BEENRKIT',
        sub_request  => FALSE,
        argument1    => to_char(fnd_date.canonical_to_date(p_effective_date),'YYYY/MM/DD HH24:MI:SS') , /* Bug 3905852*/
        argument2    => g_parm.benefit_action_id,
        argument3    => g_parm.pgm_id ,
        argument4    => g_parm.pl_nip_id,
        argument5    => g_parm.organization_id,
        argument6    => g_parm.location_id ,
	argument7    => g_parm.person_id,
	argument8    => g_parm.ler_id,
	argument9    => to_char(fnd_date.canonical_to_date(p_lf_evt_ocrd_dt),'YYYY/MM/DD HH24:MI:SS'), /* Bug 3905852*/
	argument10   => g_parm.person_sel_rl,
	argument11   => g_parm.comp_selection_rl,
	argument12   => g_parm.business_group_id ,
	argument13   => g_parm.plan_in_pgm_flag ,
	argument14   => g_parm.person_type_id ,
	argument15   => g_parm.rptg_grp,
	argument16   => g_parm.svc_area_id,
	argument17   => g_parm.assgn_type ,
	argument18   => g_parm.ben_sel_flag,
	argument19   => g_parm.flx_sum_flag,
	argument20   => g_parm.cov_dpnt_flag,
	argument21   => g_parm.prmy_care_flag,
	argument22   => g_parm.beneficaries_flag,
	argument23   => g_parm.certifications_flag,
	argument24   => g_parm.actn_items_flag,
	argument25   => g_parm.disp_epe_flxfld_flag ,
        argument26   => g_parm.disp_flex_fields);
		--
	End if ;
    --
    commit;
    --
    g_num_processes := ben_batch_utils.g_num_processes + 1;
    g_processes_rec(g_num_processes) := l_request_id;
    --
    end if ;
 -- end loop;
 --
 l_actn := 'After submitting request for report ...';
 --
 -- fnd_file.put_line(fnd_file.log, 'leaving process  ..');
Exception
  when others then
     ben_batch_utils.rpt_error(p_proc      => l_package
                              ,p_last_actn => l_actn
                              ,p_rpt_flag  => TRUE   );
     --
     benutils.write(p_text => fnd_message.get);
     benutils.write(p_text => sqlerrm);
     benutils.write_table_and_file(p_table => TRUE, p_file  => TRUE);
     hr_utility.set_location ('HR_6153_ALL_PROCEDURE_FAIL',689);
     fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE', l_package);
     fnd_message.set_token('STEP', l_actn );
     fnd_file.put_line(fnd_file.log, fnd_message.get );
     fnd_message.raise_error;
end;
--
end ben_conc_reports;

/
