--------------------------------------------------------
--  DDL for Package Body BEN_BENBATCH_PERSONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_BENBATCH_PERSONS" AS
/* $Header: benbatpe.pkb 120.8.12010000.5 2009/02/24 10:58:03 krupani ship $ */
--------------------------------------------------------------------------------
/*
+==============================================================================+
|       Copyright (c) 1997 Oracle Corporation                                  |
|        Redwood Shores, California, USA                                       |
|           All rights reserved.                                               |
+==============================================================================+

Name
    Benefit Batch Persons
Purpose
    This package is used to create person actions for batch related
    tasks.
History
Date       Who      Version   What?
----       ---      -------   -----
11-AUG-98  GPERRY   110.0     Created, moved code from benmngle.pkb.
26-AUG-98  GPERRY   115.1     Added p_person_selection_rule_id
                              parameter and added function
                              check_sleection_rule.
16-SEP-98  GPERRY   115.2     Fixed bug in restart process.
23-SEP-98  GPERRY   115.3     Added parameter p_commit_data
                              for use in prasads stuff.
29-SEP-98  GPERRY   115.4     p_commit_data = 'Y' to commit
                              not 'N'. Added num_persons parameter.
27-OCT-98  MHOYES   115.5     Replaced business_group_id joins
                              with p_business_group_id in
                              cursor c_person_life.
31-OCT-98  MHOYES   115.6     Backed out nocopy previous change.
03-DEC-98  MHOYES   115.7     Tuned cursor c_person_life.
                              Removed + 0 from the business
                              group condition. Improved
                              cursor gets from 2591 down to 236.
25-JAN-99  GPERRY   115.8     Changed ler_id so it creates a
                              null instead of a 0.
11-MAR-99  GPERRY   115.9     != to <>.
05-APR-99  mhoyes   115.10    - Un-datetrack of per_in_ler_f changes.
                              - Removed DT restriction from
                              - create_life_person_actions/c_person_life
09-APR-99  GPERRY   115.11    Change per Denise. We no
                              longer pick up persons with
                              potentials that are manual.
                              Also rewrote c_person_life
                              cursor to make it more efficient.
21-APR-99  GPERRY   115.12    Changes for temporal mode.
11-JUN-99  bbulusu  115.13    Made cursors dynamic. Tuned cursors.
                              Modified check_sel_rule to accept the
                              assignment_id as a parameter.
16-JUN-99  GPERRY   115.14    Fixed outer join to per_assignments_f
                              errors.
11-JUL-99  mhoyes   115.15    - Added new trace messages.
                              - Removed + 0s from all cursors.
15-JUL-99  mhoyes   115.16    - Added new trace messages.
15-JUL-99  pbodla   115.18    - This is a leap frog : as there a alias error
                                (ler.ler_id instead of ptn.ler_id)
                                in dynamic SQL at open c_person_life
20-JUL-99  Gperry   115.19    genutils -> benutils package rename.
03-AUG-99  Gperry   115.20    performance enhancements.
31-AUG-99  Gperry   115.21    Changed ben_ptnl_ler_for_per cursor
                              to look for all statuses apart from
                              PROCD and VOIDD.
22-DEC-99  Gperry   115.22    Fixed bug 2752.
                              WWBUG 1096742.
                              Added all criteria to make life event work.
07-JAN-00  Gperry   115.23    Fixed bug 3503.
                              WWBUG 1096828.
                              ler_id bind was not working for life
                              event mode, was defaulting to 0.
18-JAN-00  pbodla   115.24    Fixed bug 4146(WWBUG 1120687)
                              p_business_group_id added to benutils.formula
                              call.
03-Apr-00  mmogel   115.25    Added tokens to BEN_91329_FORMULA_
                              RETURN message
21-Jun-00  mhoyes   115.26    - Modified create_life_person_actions
                              and create_normal_person_actions to
                              restrict by benefit group id on
                              per_all_people_f to avoid the full table
                              scan of per_all_people_f
30-Jun-00  dharris  115.27    - Re-wrote major sections of the code to
                                use bulk fetching and inserting.
                              - Modified the dynamically created SQL
                                statement to not to used TO_DATE end of
                                time check for bind variables. Now the SQL
                                statement will use IS NOT NULL.
03-Aug-00  mhoyes   115.28    - Added restriction to
                                create_normal_person_actions to eliminate
                                person types of 'DPNT' and 'BNF' in temporal
                                mode.
28-Aug-00  rchase   115.29    - bug 1386636. Modified restart to recycle
                                old control tables since reports need to have
                                the info.  To do this needed to delete errored
                                person_actions.
29-Aug-00  jcarpent 115.30    - same bug.  Must delete old error when restart.
06-Sep-00  cdaniels 115.31    - OraBug # 6606. Added logic to update the
                                request_id in ben_benefit_actions to the
                                new concurrent request id generated for the
                                restart. wwbug 1386632.
18-Sep-2000 pbodla  115.32    - Healthnet changes : PB : Added parameter
                                 p_lmt_prpnip_by_org_typ_id
30-nov-01   tjesumic 115.33   - joint between payroll and assignment table fixed
01-dec-01   tjesumic 115.34   - 2119804
01-dec-01   tjesumic 115.35   -  set verify added
18-Feb-02   rpillay  115.36   - Bug 2224299. Made changes to select persons
                                correctly when User defined Person Type is
                                passed in as a parameter
19-Feb-02   rpillay  115.37   - Added checkfile line
06-Mar-02   ikasire  115.38     Bug 2248822 to process only the system_person_type
                                of EMP and EX_EMP for CWB .
25-Mar-02   pbodla   115.39   - Bug 2279394 : where clause is not formed
                                correctly, as and is missing in where clause.
08-Jun-02   pabodla  115.40     Do not select the contingent worker
                                assignment when assignment data is
                                fetched.
26-jun-02   nhunur   115.42     added exception handling code in check_selection_rule.
26-jun-02   pbodla  115.43     ABSNCES - in case of absence mode
                               consider persons with absence
                               potential life events only.
31-Jan-03   pbodla  115.44     GRADE/STEP - modified create_life_person_actions
                               to support extra parameters.
06-Feb-02   tjesumic 115.45    l_typ_cd  varaible has value 'no in '  whne the value assind
                               to varaible '=' added with that, it create synex error
10-Feb-03   pbodla  115.46     GRADE/STEP - Restrict to only Employees.
01-Aug-03   rpgupta 115.47     2940151
			       GRADE/STEP - Added new parameters and person
			       selection logic
01-Aug-03   rpgupta 115.47     Changed query for org hierarchy and grade ladder
25-Aug-03   pbodla  115.48     GSP New : When p_asg_events_to_all_sel_dt is set
                               no need to check for existence of potentials.
06-Nov-03   rpgupta 115.49     Iniaitlised bind variable l_grade_ladder_date4_bind
					   and changed the sql accordingly
29-Dec-03   mmudigon 115.50    Bug 3232194. Removed +0 from c_batch_ranges
28-jan-04   nhunur   115.52    Bug 3394157. conditionally append where caluse
                                if p_ler_id is not null.
11-Mar-04   rpgupta  115.53    cwbglobal - Added query to restrict ptnl life events
				with status VOIDD and PROCD to procedure
				create_normal_life_events .
19-Apr-2004 nhunur   115.54    bug 3537113 - for cwb person should have a valid assignment
16-Aug-2004 nhunur   115.55    bug 3537113 - Added effective_date bind while opening cursor.
28-Sep-2004 hmani    115.56    IREC - Main Line Front port 115.52.15102.2
05-Oct-2004 kmahendr 115.57    bug 3537113 - added another effective date condition if the
                               mode is not W
14-Oct-2004 abparekh 115.58    GSP Rate Sync changes : Added p_lf_evt_oper_cd to procedure
                                                       create_life_person_actions
08-Nov-2004 abparekh 115.59    CWB : Bug 3981941 - Modified create_normal_person_actions to rectify the check
                               not to pick up persons with CWB Started person life event.
09-Nov-04   nhunur   115.60    Commented above check. The check needs to be relooked at to prevent issues
                               like bug : 4001483
27-Dec-04   abparekh 115.62    Bug 4030438 : For GSP if person has not grade ladder assigned,
                               process the person if business group has DEFAULT grade ladder.
17-nov-05   nhunur   115.63    bug - 4743143 - GSP query needed a parenthesis.
03-Jan-06   nhunur   115.64    cwb - changes for person type param.
03-feb-06   nhunur   115.65    cwb - changes for picking active assignment.
03-Nov-06   swjain   115.67    Bug 5331889 - passed person_id as input param in check_selection_rule
                               and added input1 as additional param for future use
31-jul-06   nhunur   115.68    cagr - changes for picking people with coll. agreement.
09-Aug-07   vvprabhu 115.69    Bug 5857493 - added g_audit_flag to
                               control person selection rule error logging
28-May-08   krupani  115.70    Bug 6718304 - Relevant changes done in CWB where clause
21-Jan-08   krupani  115.71    Bug 7307975 - Changes to improve performance in GSP
24-Feb-08   krupani  115.72    Bug 7307975 - Further changes
25-Feb-08   krupani  115.73    Bug 7307975 - Corrected the fix in version 115.72
*/
--------------------------------------------------------------------------------
  g_package VARCHAR2(80) := 'ben_benbatch_persons';
  TYPE g_number_table_type IS TABLE OF NUMBER
    INDEX BY BINARY_INTEGER;
--
  FUNCTION check_selection_rule(
    p_person_selection_rule_id IN NUMBER
   ,p_person_id                IN NUMBER
   ,p_business_group_id        IN NUMBER
   ,p_effective_date           IN DATE
   ,p_input1                   in  varchar2 default null    -- Bug 5331889
   ,p_input1_value             in  varchar2 default null)
    RETURN BOOLEAN IS
    --
    l_outputs       ff_exec.outputs_t;
    l_assignment_id NUMBER;
    l_package       VARCHAR2(80)      := g_package || '.check_selection_rule';
    value_exception  exception ;
  --
  BEGIN
    --
    IF p_person_selection_rule_id IS NULL THEN
      --
      RETURN TRUE;
    --
    ELSE
      --
      l_assignment_id  :=
        benutils.get_assignment_id(p_person_id=> p_person_id
         ,p_business_group_id => p_business_group_id
         ,p_effective_date    => p_effective_date);
      --
      if l_assignment_id is null
      then
          raise ben_batch_utils.g_record_error;
      end if ;
      --

      l_outputs        :=
        benutils.formula(p_formula_id=> p_person_selection_rule_id
         ,p_effective_date    => p_effective_date
         ,p_business_group_id => p_business_group_id
         ,p_assignment_id     => l_assignment_id
         ,p_param1            => 'BEN_IV_PERSON_ID'          -- Bug 5331889
         ,p_param1_value      => to_char(p_person_id)
         ,p_param2            => p_input1
         ,p_param2_value      => p_input1_value);
      --
      IF l_outputs(l_outputs.FIRST).VALUE = 'Y' THEN
        --
        RETURN TRUE;
      --
      ELSIF l_outputs(l_outputs.FIRST).VALUE = 'N' THEN
        --
        RETURN FALSE;
      --
      ELSIF upper(l_outputs(l_outputs.FIRST).VALUE) not in ('Y', 'N')  THEN
        --
        RAISE value_exception;
      --
      END IF;
    --
    END IF;
  --
  EXCEPTION
    --
    When ben_batch_utils.g_record_error then
         hr_utility.set_location(l_package ,10);
         if g_audit_flag = true then
         fnd_message.set_name('BEN','BEN_91698_NO_ASSIGNMENT_FND');
         fnd_message.set_token('ID' ,to_char(p_person_id) );
         fnd_message.set_token('PROC',l_package ) ;
    	 Ben_batch_utils.write(p_text => '<< Person id : '||to_char(p_person_id)||' failed.'||
	          		         ' Reason : '|| fnd_message.get ||' >>' );
	 end if;
         RETURN FALSE;
    When value_exception then
         hr_utility.set_location(l_package ,20);
         fnd_message.set_name('BEN','BEN_91329_FORMULA_RETURN');
         fnd_message.set_token('RL','person_selection_rule_id :'||p_person_selection_rule_id);
         fnd_message.set_token('PROC',l_package  ) ;
    	 Ben_batch_utils.write(p_text => '<< Person id : '||to_char(p_person_id)||' failed.'||
	          		         ' Reason : '|| fnd_message.get ||' >>' );
	 RETURN FALSE;
    WHEN OTHERS THEN
         hr_utility.set_location(l_package ,30);
         Ben_batch_utils.write(p_text => '<< Person id : '||to_char(p_person_id)||' failed.'||
	          		         ' Reason : '|| SQLERRM ||' >>' );
         RETURN FALSE;
  --
  END check_selection_rule;
--
  PROCEDURE create_normal_person_actions(
    p_benefit_action_id        IN     NUMBER
   ,p_mode_cd                  IN     VARCHAR2
   ,p_business_group_id        IN     NUMBER
   ,p_person_id                IN     NUMBER
   ,p_ler_id                   IN     NUMBER
   ,p_person_type_id           IN     NUMBER
   ,p_benfts_grp_id            IN     NUMBER
   ,p_location_id              IN     NUMBER
   ,p_legal_entity_id          IN     NUMBER
   ,p_payroll_id               IN     NUMBER
   ,p_pstl_zip_rng_id          IN     NUMBER
   ,p_organization_id          IN     NUMBER
   ,p_ler_override_id          IN     NUMBER
   ,p_person_selection_rule_id IN     NUMBER
   ,p_effective_date           IN     DATE
   ,p_mode                     IN     VARCHAR2
   ,p_chunk_size               IN     NUMBER
   ,p_threads                  IN     NUMBER
   ,p_num_ranges               OUT NOCOPY  NUMBER
   ,p_num_persons              OUT NOCOPY  NUMBER
   ,p_commit_data              IN     VARCHAR2
   ,p_lmt_prpnip_by_org_flag   IN     VARCHAR2
   ,p_popl_enrt_typ_cycl_id    in     number default NULL
   ,p_cwb_person_type          IN     VARCHAR2 default NULL
   ,p_lf_evt_ocrd_dt           in     date) IS
    --
    cursor c_cwb_asg_date_chk is
    select greatest (b.start_date
          ,to_date(nvl(c.strt_mo,1) ||'/'||nvl(c.strt_day,1)||'/'||to_char(b.start_date,'YYYY'),'MM/DD/YYYY')) wth_start_date
          ,greatest(b.end_date
	  ,to_date(nvl(c.end_mo,1)||'/'||nvl(c.end_day,1)||'/'||to_char(b.end_date,'YYYY'),'MM/DD/YYYY')) wth_end_date
    from BEN_ENRT_PERD A,
         ben_yr_perd b,
         ben_wthn_yr_perd c,
         ben_popl_enrt_typ_cycl_f pet,
         ben_ler_f ler
    WHERE a.popl_enrt_typ_cycl_id  = p_popl_enrt_typ_cycl_id
    and a.yr_perd_id = b.yr_perd_id
    and a.wthn_yr_perd_id = c.wthn_yr_perd_id (+)
    and a.popl_enrt_typ_cycl_id = pet.popl_enrt_typ_cycl_id
    and pet.business_group_id  = a.business_group_id
    and p_effective_date between pet.effective_start_date and pet.effective_end_date
--    and p_effective_date between b.start_date and b.end_date   --Bug 6718304
    and a.ler_id = ler.ler_id
    and ler.typ_cd = 'COMP'
    and p_effective_date between ler.effective_start_date and ler.effective_end_date
    and a.asnd_lf_evt_dt = p_lf_evt_ocrd_dt ;
    --
    l_wth_start_date date;
    l_wth_end_date date;
    --
    -- Native dynamic PLSQL cursor
    --
    TYPE cur_type IS REF CURSOR;
    c_person                     cur_type;
    l_start_person_action_id     NUMBER;
    l_end_person_action_id       NUMBER;
    --
    l_person_id_fetch            NUMBER;
    l_person_id_process          ben_benbatch_persons.g_number_table_type;
    l_person_action_id_table     ben_benbatch_persons.g_number_table_type;
    l_to_chunk_loop              NUMBER                                  := 0;
    --
    -- Local variables
    --
    l_query_str                  VARCHAR2(5000);
    l_person_id_bind             NUMBER;
    l_person_type_id_bind        NUMBER;
    l_benfts_grp_id_bind         NUMBER;
    l_location_id_date_bind      DATE;
    l_location_id_bind           NUMBER;
    l_legal_entity_id_date_bind  DATE;
    l_legal_entity_id_bind       NUMBER;
    l_payroll_id_date_bind       DATE;
    l_payroll_id_bind            NUMBER;
    l_payroll_id_date2_bind      DATE;
    l_pstl_zip_rng_id_date_bind  DATE;
    l_pstl_zip_rng_id_date2_bind DATE;
    l_pstl_zip_rng_id_date3_bind DATE;
    l_pstl_zip_rng_id_bind       NUMBER;
    l_pstl_zip_rng_id_date4_bind DATE;
    l_organization_id_date_bind  DATE;
    l_organization_id_bind       NUMBER;
    l_organization_id_date2_bind DATE;
    l_organization_id_date3_bind DATE;
    --
    l_temp_whclause              LONG;
    --
    l_person_type_id_date_bind   DATE; -- Bug 2224299
    l_cwb_whclause               LONG; -- Bug 2248822
  --
  BEGIN


    -- Check for temporal mode
    -- When running in temporal mode we can exclude contacts without PTUs
    -- The assumption is that only contacts exist without PTUs
    hr_utility.set_location('Entering create_normal_person_actions ',19);
    hr_utility.set_location(' p_effective_date '||p_effective_date, 19);
    --
    IF p_mode_cd = 'T'
      and p_person_selection_rule_id is null
    THEN
      --
      l_temp_whclause  :=
        ' and exists ' ||
        '   (select null ' ||
        '   from per_person_type_usages_f ptu, ' ||
        '   per_person_types pet ' ||
        '   where ptu.person_id = ppf.person_id ' ||
        '   and   ptu.person_type_id = pet.person_type_id ' ||
        '   and   pet.system_person_type not in( ' ||
        ''''||'DPNT'||''''||', '||''''||'BNF'||''''||') ' ||
        '   )';
    --
    ELSE
      --
      l_temp_whclause  := ' ';
    --
    END IF;
    --
    -- Create the main query
    --
    -- Bind in business group id
    --
    -- Modified by SMONDAL

    IF p_lmt_prpnip_by_org_flag = 'N' then
       --
        l_query_str    :=
          ' select ppf.person_id from per_all_people_f ppf' ||
                ' where  ppf.business_group_id = :business_group_id ' ||
                  ' and :effective_date is not null ' ||
                l_temp_whclause;
       --
    ELSE
       --
        l_query_str    :=
          ' select ppf.person_id from per_all_people_f ppf' ||
                                   ', per_all_assignments_f paf1' ||
          ' where  ppf.business_group_id = :business_group_id ' ||
            ' and ppf.person_id = paf1.person_id(+) ' ||
            ' and ppf.business_group_id = paf1.business_group_id(+) ' ||
            ' and paf1.primary_flag(+) = ''Y'' ' ||
            ' and (paf1.assignment_id is null '  ||
            '      or paf1.assignment_id = ' ||
                      ' ( select min(paf2.assignment_id) ' ||
                        ' from per_all_assignments_f paf2 ' ||
                        ' where paf2.person_id = paf1.person_id ' ||
                          ' and   paf2.assignment_type <> ''C'''||
                          ' and paf1.business_group_id = paf2.business_group_id ' ||
                          ' and paf2.primary_flag = ''Y'' ' ||
                          ' and :effective_date between paf2.effective_start_date' ||
                                                  ' and paf2.effective_end_date' ||
                      ' ) ' ||
                 ' )' ||
                l_temp_whclause;
       --
    END IF;
    -- Bug 2248822 Restrict the persons to only Employees and Ex-employees
    -- for the CWB Process.
    IF p_mode_cd = 'W' THEN
      --
      hr_utility.set_location(' p_cwb_person_type '||p_cwb_person_type, 19);
      	  fnd_file.put_line(fnd_file.log, p_cwb_person_type );
      if nvl(p_cwb_person_type,'AEXE') = 'AEXE'
      then
      l_cwb_whclause :=  ' and exists ( select ''x'' from per_person_type_usages_f ptu, '||
                                   ' per_person_types ppt '||
                                   ' where ppt.person_type_id = ptu.person_type_id '||
                                   ' and ppt.system_person_type in ( ''EMP'', ''EX_EMP''  ) '||
                                   ' and ppt.business_group_id = ppf.business_group_id '||
                                   ' and ptu.person_id  = ppf.person_id '||
				   ' and ppt.active_flag = ''Y'' ' ||
                                   ' and :effective_date between ptu.effective_start_date '||
                                                          ' and  ptu.effective_end_date ) ' ;
      elsif p_cwb_person_type = 'AE'
      then
      l_cwb_whclause :=  ' and exists ( select ''x'' from per_person_type_usages_f ptu, '||
                                   ' per_person_types ppt '||
                                   ' where ppt.person_type_id = ptu.person_type_id '||
                                   ' and ppt.system_person_type = ''EMP'' '||
                                   ' and ppt.business_group_id = ppf.business_group_id '||
                                   ' and ptu.person_id  = ppf.person_id '||
				   ' and ppt.active_flag = ''Y'' ' ||
                                   ' and :effective_date between ptu.effective_start_date '||
                                                          ' and  ptu.effective_end_date ) ' ;
      else
      l_cwb_whclause :=  ' and exists ( select ''x'' from per_person_type_usages_f ptu, '||
                                   ' per_person_types ppt '||
                                   ' where ppt.person_type_id = ptu.person_type_id '||
                                   ' and ppt.system_person_type in ( ''EMP'', ''EX_EMP''  ) '||
                                   ' and ppt.business_group_id = ppf.business_group_id '||
                                   ' and ptu.person_id  = ppf.person_id '||
				   ' and ppt.active_flag = ''Y'' ' ||
                                   ' and :effective_date between ptu.effective_start_date '||
                                                          ' and  ptu.effective_end_date ) ' ;
      end if;
      -- bug 3537113
      -- for cwb, person should have a valid assignment
      --
      if nvl(p_cwb_person_type,'AEXE') in ( 'AE' , 'AEXE' )
      then
      l_cwb_whclause := l_cwb_whclause || ' and exists ( select 1 from per_all_assignments_f asgn'
                                       || ' where asgn.person_id = ppf.person_id '
          			       || ' and asgn.PRIMARY_FLAG = ''Y'' '
				       || ' and :effective_date between asgn.effective_start_date '
				       || ' and asgn.effective_end_date  '
				       || ' and :l_wth_start_date is null )' ;
      else
          hr_utility.set_location(' p_popl_enrt_typ_cycl_id '|| p_popl_enrt_typ_cycl_id, 19);
          hr_utility.set_location(' p_lf_evt_ocrd_dt '|| p_lf_evt_ocrd_dt, 19);
	  --
	  fnd_file.put_line(fnd_file.log, p_popl_enrt_typ_cycl_id );
	  fnd_file.put_line(fnd_file.log, p_lf_evt_ocrd_dt );

	  if p_popl_enrt_typ_cycl_id is not null
	  and p_lf_evt_ocrd_dt is not null
	  then
              open c_cwb_asg_date_chk;
	      fetch c_cwb_asg_date_chk into l_wth_start_date, l_wth_end_date ;
	      close c_cwb_asg_date_chk;
	      --
              hr_utility.set_location(' l_wth_start_date '|| l_wth_start_date, 19);
	      fnd_file.put_line(fnd_file.log, l_wth_start_date );
	      --
	      if l_wth_start_date is not null
	      then
                  l_cwb_whclause := l_cwb_whclause
	                    || ' and exists ( select 1 from per_all_assignments_f asgn'
                            || ' , per_assignment_status_types pat '
                            || ' where asgn.person_id = ppf.person_id '
                            || ' and pat.assignment_status_type_id = asgn.assignment_status_type_id '
                            || ' and pat.per_system_status = ''ACTIVE_ASSIGN'' '
		            || ' and asgn.PRIMARY_FLAG = ''Y'' '
			    || ' and asgn.assignment_type = ''E'' '
 		            || ' and :effective_date is not null '
                            || ' and asgn.effective_end_date >= :l_wth_start_date  )' ;
          --Bug 6718304
	         else
						l_cwb_whclause := l_cwb_whclause
	                    || ' and exists ( select 1 from per_all_assignments_f asgn'
                            || ' , per_assignment_status_types pat '
                            || ' where asgn.person_id = ppf.person_id '
                            || ' and pat.assignment_status_type_id = asgn.assignment_status_type_id '
                            || ' and pat.per_system_status = ''ACTIVE_ASSIGN'' '
 		            || ' and asgn.PRIMARY_FLAG = ''Y'' '
			    || ' and asgn.assignment_type = ''E'' '
                            || ' and :effective_date between asgn.effective_start_date '
		            || ' and asgn.effective_end_date '
		            || ' and :l_wth_start_date is null )' ;
          -- Bug 6718304
	      end if;
          else
              l_cwb_whclause := l_cwb_whclause
	                    || ' and exists ( select 1 from per_all_assignments_f asgn'
                            || ' , per_assignment_status_types pat '
                            || ' where asgn.person_id = ppf.person_id '
                            || ' and pat.assignment_status_type_id = asgn.assignment_status_type_id '
                            || ' and pat.per_system_status = ''ACTIVE_ASSIGN'' '
 		            || ' and asgn.PRIMARY_FLAG = ''Y'' '
			    || ' and asgn.assignment_type = ''E'' '
                            || ' and :effective_date between asgn.effective_start_date '
		            || ' and asgn.effective_end_date '
		            || ' and :l_wth_start_date is null )' ;
	  end if;
      end if;
      -- bug 3537113
      --
      l_query_str   := l_query_str||l_cwb_whclause ;
      --
      hr_utility.set_location('Building cwb where clause ',29);
      --
    ELSE   -- if p_mode_cd <> 'W' then
      --
      -- Bug 2279394 : where clause is not formed correctly, as and is missing
      -- in where clause.
      --
      l_cwb_whclause :=   ' and :effective_date is NOT NULL  '
                       || ' and :effective_date  is not null '
		       || ' and :l_wth_start_date is null ';
      l_query_str   := l_query_str||l_cwb_whclause ;
      --
    END IF;
    --
    -- If a person id was specified, use it in the main query.
    --
    IF p_person_id IS NOT NULL THEN
      --
      -- Bind in required person id
      --
      l_person_id_bind  := p_person_id;
      l_query_str       := l_query_str || ' and ppf.person_id = :person_id';
    --
    ELSE
      --
      l_person_id_bind  := -1;
      l_query_str       := l_query_str || ' and -1 = :person_id';
    END IF;
    --
    -- cwbglobal
    -- dont pick ptnl ler's with status processed or voided
/*
    if p_mode_cd = 'W' then
       -- Bug 3981941
       -- We dont want to pick up persons that have CWB person life event in Started State.
       -- Corrected the following cursor.

      l_query_str         :=
       l_query_str || ' and exists (select null' ||
        ' from ben_ptnl_ler_for_per ptn' ||
        '      ,ben_ler_f ler' ||
        ' where ptn.person_id = ppf.person_id' ||
        ' and   ler.ler_id = ptn.ler_id' ||
        ' and   ptn.lf_evt_ocrd_dt between ler.effective_start_date and ler.effective_end_date' ||
        ' and   ler.typ_cd =''COMP'' ' ||
        ' and ptn.ptnl_ler_for_per_stat_cd not in(''VOIDD'',''PROCD''))';

     l_query_str         :=
       l_query_str || ' and not exists (select null' ||
        ' from ben_per_in_ler pil' ||
        '      ,ben_ler_f ler' ||
        ' where pil.person_id = ppf.person_id' ||
        ' and   ler.ler_id = pil.ler_id' ||
        ' and   pil.lf_evt_ocrd_dt between ler.effective_start_date and ler.effective_end_date' ||
        ' and   ler.typ_cd =''COMP'' ' ||
        ' and   pil.per_in_ler_stat_cd in(''STRTD''))';
    end if;
*/
  hr_utility.set_location('CWB group pl id'|| ben_manage_cwb_life_events.g_cache_group_plan_rec.group_pl_id ,10);

    -- end cwbglobal


    -- If a person type id was specified, use it in a subquery.
    --
    IF p_person_type_id IS NOT NULL THEN
      --
      -- Bind in required person type id
      --
      l_person_type_id_bind  := p_person_type_id;

     -- Changed the query for fixing Bug 2224299
     -- l_query_str            :=
     --   l_query_str || ' and exists (select null from per_person_types ppt' ||
     --     ' where ppf.person_type_id = ppt.person_type_id' ||
     --     ' and ppt.person_type_id = :person_type_id' ||
     --     ' and ppt.active_flag = ''Y'')';

      l_person_type_id_date_bind  := p_effective_date;

      l_query_str :=
        l_query_str || ' and exists (select null from per_person_types ppt,per_person_type_usages_f ptu ' ||
          ' where ppt.person_type_id = ptu.person_type_id' ||
          ' and ppt.person_type_id = :person_type_id' ||
          ' and ptu.person_id = ppf.person_id' ||
          ' and :person_type_id_date between ptu.effective_start_date and ptu.effective_end_date' ||
          ' and ppt.active_flag = ''Y'')';

    --
    ELSE
      --
      l_person_type_id_bind  := -1;

      -- Changed the query for fixing Bug 2224299
      -- l_query_str := l_query_str || ' and -1 = :person_type_id';

      l_person_type_id_date_bind  := hr_api.g_sot;
      l_query_str := l_query_str ||
          ' and -1 = :person_type_id and :person_type_id_date IS NOT NULL';
      --
    END IF;
    --
    -- If a benfts_grp_id was specified, use it in a subquery.
    --
    IF p_benfts_grp_id IS NOT NULL THEN
      --
      -- Bind in required person type id
      --
      l_benfts_grp_id_bind  := p_benfts_grp_id;
      l_query_str           :=
                   l_query_str || ' and ppf.benefit_group_id = :benfts_grp_id';
    --
    ELSE
      --
      l_benfts_grp_id_bind  := -1;
      l_query_str           := l_query_str || ' and -1 = :benfts_grp_id';
    --
    END IF;
    --
    -- If a location_id was specified, use it the main query.
    --
    IF p_location_id IS NOT NULL THEN
      --
      -- Bind in required variables
      --
      l_location_id_bind       := p_location_id;
      l_location_id_date_bind  := p_effective_date;
      l_query_str              :=
        l_query_str || ' and exists (select null' ||
          ' from per_all_assignments_f paf' ||
          ' where paf.person_id = ppf.person_id' ||
          ' and   paf.assignment_type <> ''C'''||
          ' and paf.primary_flag = ''Y''' ||
          ' and paf.business_group_id = ppf.business_group_id' ||
          ' and :location_id_date' ||
          ' between paf.effective_start_date' ||
          ' and paf.effective_end_date' ||
          ' and paf.location_id = :location_id)';
    --
    ELSE
      --
      l_location_id_bind       := -1;
      l_location_id_date_bind  := hr_api.g_sot;
      l_query_str              :=
        l_query_str ||
          ' and :location_id_date IS NOT NULL and -1 = :location_id ';
    END IF;
    --
    -- If a legal_entity_id was specified, use it in a subquery.
    --
    IF p_legal_entity_id IS NOT NULL THEN
      --
      -- Bind in required legal entity id
      --
      l_legal_entity_id_date_bind  := p_effective_date;
      l_legal_entity_id_bind       := p_legal_entity_id;
      l_query_str                  :=
        l_query_str || ' and exists (select null' ||
          ' from hr_soft_coding_keyflex hsc,' ||
          ' per_all_assignments_f paf' ||
          ' where paf.person_id = ppf.person_id' ||
          ' and   paf.assignment_type <> ''C'''||
          ' and paf.primary_flag = ''Y''' ||
          ' and paf.business_group_id = ppf.business_group_id' ||
          ' and :legal_entity_id_date' ||
          ' between paf.effective_start_date' ||
          ' and paf.effective_end_date ' ||
          ' and paf.soft_coding_keyflex_id = hsc.soft_coding_keyflex_id' ||
          ' and hsc.segment1 = to_char(:legal_entity_id)) ';
    --
    /* Note the use of to_char this is for CBO joins between varchar2
                  and number columns */
    --
    ELSE
      --
      l_legal_entity_id_date_bind  := hr_api.g_sot;
      l_legal_entity_id_bind       := -1;
      l_query_str                  :=
        l_query_str ||
          ' and :legal_entity_id_date IS NOT NULL and -1 = :legal_entity_id ';
    --
    END IF;
    --
    -- If a payroll_id was specified, use it in a subquery.
    --
    IF p_payroll_id IS NOT NULL THEN
      --
      -- Bind in required payroll id
      --
      l_payroll_id_date_bind   := p_effective_date;
      l_payroll_id_bind        := p_payroll_id;
      l_payroll_id_date2_bind  := p_effective_date;
      --
      l_query_str              :=
        l_query_str || ' and exists (select null' || ' from pay_payrolls_f pay,' ||
          ' per_all_assignments_f paf' ||
          ' where paf.person_id = ppf.person_id ' ||
          ' and   paf.assignment_type <> ''C'''||
          ' and paf.primary_flag = ''Y''' ||
          ' and paf.business_group_id = ppf.business_group_id' ||
          ' and :payroll_id_date' ||
          ' between paf.effective_start_date' ||
          ' and paf.effective_end_date ' ||
          ' and pay.payroll_id = :payroll_id' ||
          ' and pay.payroll_id = paf.payroll_id' ||
          ' and :payroll_id_date2' ||
          ' between pay.effective_start_date' ||
          ' and pay.effective_end_date)';
    --
    ELSE
      --
      l_payroll_id_date_bind   := hr_api.g_sot;
      l_payroll_id_bind        := -1;
      l_payroll_id_date2_bind  := hr_api.g_sot;
      --
      l_query_str              :=
        l_query_str ||
          ' and :payroll_id_date IS NOT NULL and -1 = :payroll_id' ||
          ' and :payroll_id_date2 IS NOT NULL ';
    --
    END IF;
    --
    -- If a pstl_zip_rng_id was specified, use it in a subquery.
    --
    IF p_pstl_zip_rng_id IS NOT NULL THEN
      --
      -- Bind in required pstl zip rng id
      --
      l_pstl_zip_rng_id_date_bind   := p_effective_date;
      l_pstl_zip_rng_id_date2_bind  := p_effective_date;
      l_pstl_zip_rng_id_date3_bind  := p_effective_date;
      l_pstl_zip_rng_id_bind        := p_pstl_zip_rng_id;
      l_pstl_zip_rng_id_date4_bind  := p_effective_date;
      --
      l_query_str                   :=
        l_query_str || ' and exists (select null' || ' from  per_addresses pad,' ||
          ' ben_pstl_zip_rng_f rzr' ||
          ' where pad.person_id = ppf.person_id' ||
          ' and pad.primary_flag = ''Y''' ||
          ' and :ptl_zip_rng_id_date' ||
          ' between nvl(pad.date_from,:pstl_zip_rng_id_date2)' ||
          ' and nvl(pad.date_to,:pstl_zip_rng_id_date3)' ||
          ' and rzr.pstl_zip_rng_id = :pstl_zip_rng_id' ||
          ' and pad.postal_code' ||
          ' between rzr.from_value' ||
          ' and rzr.to_value' ||
          ' and :pstl_zip_rng_id_date4' ||
          ' between rzr.effective_start_date' ||
          ' and rzr.effective_end_date)';
    --
    ELSE
      --
      l_pstl_zip_rng_id_date_bind   := hr_api.g_sot;
      l_pstl_zip_rng_id_date2_bind  := hr_api.g_sot;
      l_pstl_zip_rng_id_date3_bind  := hr_api.g_sot;
      l_pstl_zip_rng_id_bind        := -1;
      l_pstl_zip_rng_id_date4_bind  := hr_api.g_sot;
      --
      l_query_str                   :=
        l_query_str || ' and :pstl_zip_rng_id_date IS NOT NULL' ||
          ' and :pstl_zip_rng_id_date2 IS NOT NULL' ||
          ' and :pstl_zip_rng_id_date3 IS NOT NULL' ||
          ' and -1 = :pstl_zip_rng_id' ||
          ' and :pstl_zip_rng_id_date4 IS NOT NULL ';
    --
    END IF;
    --
    -- If an organization_id was specified, use it in a subquery.
    --
    IF p_organization_id IS NOT NULL THEN
      --
      -- Bind in required organization id
      --
      l_organization_id_date_bind   := p_effective_date;
      l_organization_id_bind        := p_organization_id;
      l_organization_id_date2_bind  := p_effective_date;
      l_organization_id_date3_bind  := p_effective_date;
      --
      l_query_str                   :=
        l_query_str || ' and exists (select null' ||
          ' from hr_organization_units org,' ||
          ' per_all_assignments_f paf' ||
          ' where paf.person_id = ppf.person_id' ||
          ' and   paf.assignment_type <> ''C'''||
          ' and paf.primary_flag = ''Y''' ||
          ' and paf.business_group_id = ppf.business_group_id' ||
          ' and :organization_id_date' ||
          ' between paf.effective_start_date' ||
          ' and paf.effective_end_date' ||
          ' and paf.organization_id = org.organization_id' ||
          ' and org.organization_id = :organization_id ' ||
          ' and :organization_id_date2' ||
          ' between org.date_from' ||
          ' and nvl(org.date_to,:organization_id_date3))';
    --
    ELSE
      --
      l_organization_id_date_bind   := hr_api.g_sot;
      l_organization_id_bind        := -1;
      l_organization_id_date2_bind  := hr_api.g_sot;
      l_organization_id_date3_bind  := hr_api.g_sot;
      --
      l_query_str                   :=
        l_query_str || ' and :organization_id_date IS NOT NULL' ||
          ' and -1 = :organization_id' ||
          ' and :organization_id_date2 IS NOT NULL' ||
          ' and :organization_id_date3 IS NOT NULL ';
    --
    END IF;
    --
    -- Finish the main query.
    --
    IF p_lmt_prpnip_by_org_flag = 'N' THEN
       --
       l_query_str    :=
         l_query_str || ' and :effective_date' ||
           ' between ppf.effective_start_date' ||
           ' and ppf.effective_end_date' ||
           ' and :effective_date is not null ' ||
           ' order by ppf.full_name';
       --
    ELSE
       --
       l_query_str    :=
         l_query_str || ' and :effective_date' ||
           ' between ppf.effective_start_date' ||
           ' and ppf.effective_end_date' ||
           ' and :effective_date between paf1.effective_start_date(+)' ||
                        ' and paf1.effective_end_date(+)' ||
           ' order by paf1.organization_id';
       --
    END IF;
    --
    -- fnd_file.put_line(fnd_file.log, l_query_str );
    -- Open the query using business_group_id as the bind variable.
    --
    OPEN c_person FOR l_query_str
    USING p_business_group_id
          ,p_effective_date
          ,p_effective_date -- added for Bug 2248822
          ,p_effective_date -- added for Bug 3537113
	  ,l_wth_start_date
          ,l_person_id_bind
          ,l_person_type_id_bind
          ,l_person_type_id_date_bind  -- added for Bug 2224299
          ,l_benfts_grp_id_bind
          ,l_location_id_date_bind
          ,l_location_id_bind
          ,l_legal_entity_id_date_bind
          ,l_legal_entity_id_bind
          ,l_payroll_id_date_bind
          ,l_payroll_id_bind
          ,l_payroll_id_date2_bind
          ,l_pstl_zip_rng_id_date_bind
          ,l_pstl_zip_rng_id_date2_bind
          ,l_pstl_zip_rng_id_date3_bind
          ,l_pstl_zip_rng_id_bind
          ,l_pstl_zip_rng_id_date4_bind
          ,l_organization_id_date_bind
          ,l_organization_id_bind
          ,l_organization_id_date2_bind
          ,l_organization_id_date3_bind
          ,p_effective_date
          ,p_effective_date;
    --
-- ------------------------------------------------------------
-- NOTE: for some reason the following FETCH statement fails
--       at runtime with an invalid cursor type error:
--       FETCH c_person BULK COLLECT INTO l_person_id_table;
--       To get around this problem, each row is selected
--       individually (how disappointing).
-- ------------------------------------------------------------
    LOOP
      FETCH c_person INTO l_person_id_fetch;
      EXIT WHEN c_person%NOTFOUND;
      -- Only process if person passed selection rule or there is no rule.
      IF check_selection_rule(p_person_selection_rule_id=> p_person_selection_rule_id
          ,p_person_id                => l_person_id_fetch
          ,p_business_group_id        => p_business_group_id
          ,p_effective_date           => p_effective_date)
      or p_mode = 'I' -- IREC
      THEN
        --
        l_person_id_process(l_person_id_process.COUNT + 1)  :=
                                                            l_person_id_fetch;
      END IF;
    END LOOP;
    CLOSE c_person;
    --
    IF l_person_id_process.COUNT > 0 THEN
      -- bulk insert all person action(s)
      FORALL l_count IN l_person_id_process.FIRST .. l_person_id_process.LAST
        --
        INSERT INTO ben_person_actions
                    (
                      person_action_id
                     ,person_id
                     ,ler_id
                     ,benefit_action_id
                     ,action_status_cd
                     ,object_version_number)
             VALUES(
               ben_person_actions_s.nextval
              ,l_person_id_process(l_count)
              ,p_ler_override_id
              ,p_benefit_action_id
              ,'U'
              ,1)
          RETURNING person_action_id BULK COLLECT INTO l_person_action_id_table;
       --
      -- 99999 Delete the duplicates from the ben_person_actions
      -- here.


      IF MOD(l_person_action_id_table.COUNT
          ,p_chunk_size) = 0 THEN
        l_to_chunk_loop  :=
                         TRUNC(l_person_action_id_table.COUNT / p_chunk_size);
      ELSE
        l_to_chunk_loop  :=
                      TRUNC(l_person_action_id_table.COUNT / p_chunk_size) + 1;
      END IF;
      --
      FOR i IN 1 .. l_to_chunk_loop LOOP
        -- set the starting point range
        l_start_person_action_id  :=
                         l_person_action_id_table(((i - 1) * p_chunk_size) + 1);
        IF i <> l_to_chunk_loop THEN
          l_end_person_action_id  :=
                                   l_person_action_id_table(i * p_chunk_size);
        ELSE
          l_end_person_action_id  :=
                     l_person_action_id_table(l_person_action_id_table.COUNT);
        END IF;
        --
        INSERT INTO ben_batch_ranges
                    (
                      range_id
                     ,benefit_action_id
                     ,range_status_cd
                     ,starting_person_action_id
                     ,ending_person_action_id
                     ,object_version_number)
             VALUES(
               ben_batch_ranges_s.nextval
              ,p_benefit_action_id
              ,'U'
              ,l_start_person_action_id
              ,l_end_person_action_id
              ,1);
      --
      END LOOP;
      IF p_commit_data = 'Y' THEN
        -- This is for What IF Functionality
        COMMIT;
      END IF;
    END IF;
    --
    p_num_ranges   := l_to_chunk_loop;
    p_num_persons  := l_person_action_id_table.COUNT;
  --
  END create_normal_person_actions;
--
  PROCEDURE create_life_person_actions(
    p_benefit_action_id        IN     NUMBER
   ,p_business_group_id        IN     NUMBER
   ,p_person_id                IN     NUMBER
   ,p_ler_id                   IN     NUMBER
   ,p_person_type_id           IN     NUMBER
   ,p_benfts_grp_id            IN     NUMBER
   ,p_location_id              IN     NUMBER
   ,p_legal_entity_id          IN     NUMBER
   ,p_payroll_id               IN     NUMBER
   ,p_pstl_zip_rng_id          IN     NUMBER
   ,p_organization_id          IN     NUMBER
   ,p_person_selection_rule_id IN     NUMBER
   ,p_effective_date           IN     DATE
   ,p_chunk_size               IN     NUMBER
   ,p_threads                  IN     NUMBER
   ,p_num_ranges               OUT NOCOPY    NUMBER
   ,p_num_persons              OUT NOCOPY    NUMBER
   ,p_commit_data              IN     VARCHAR2
   ,p_lmt_prpnip_by_org_flag   IN     VARCHAR2
   -- GRADE/STEP : Added for grade/step benmngle
   ,p_org_heirarchy_id         in     number   default null
   ,p_org_starting_node_id     in     number   default null
   ,p_grade_ladder_id          in     number   default null
   ,p_asg_events_to_all_sel_dt in     date     default null
   ,p_rate_id                  in     number   default null
   ,p_per_sel_dt_cd            in     varchar2 default null
   ,p_per_sel_dt_from          in     date     default null
   ,p_per_sel_dt_to            in     date     default null
   ,p_year_from                in     number   default null
   ,p_year_to                  in     number   default null
   ,p_cagr_id                  in     number   default null
   ,p_qual_type                in     number   default null
   ,p_qual_status              in     varchar2 default null
   -- 2940151
   ,p_per_sel_freq_cd          in     varchar2 default 'Y'
   ,p_id_flex_num              in     number   default null
   ,p_concat_segs              in     varchar2 default null
   -- end 2940151
   ,p_mode                     IN     VARCHAR2 default null
   ,p_lf_evt_oper_cd           IN     VARCHAR2 default null   /* GSP Rate Sync */
   ) IS
    --
    -- Native dynamic PLSQL definition
    --
    TYPE cur_type IS REF CURSOR;
    c_person_life                cur_type;
    --
    --
    l_person_id_fetch            NUMBER;
    l_person_id_process          ben_benbatch_persons.g_number_table_type;
    l_person_action_id_table     ben_benbatch_persons.g_number_table_type;
    l_to_chunk_loop              NUMBER                                  := 0;
    --
    --
    -- Local variables
    --
    l_query_str                  VARCHAR2(5000);
    l_start_person_action_id     NUMBER;
    l_end_person_action_id       NUMBER;
    l_person_id_bind             NUMBER;
    l_person_type_id_bind        NUMBER;
    l_benfts_grp_id_bind         NUMBER;
    l_location_id_date_bind      DATE;
    l_location_id_bind           NUMBER;
    l_cagr_id_date_bind          DATE;
    l_cagr_id_bind               NUMBER;
    l_legal_entity_id_date_bind  DATE;
    l_legal_entity_id_bind       NUMBER;
    l_typ_cd                     varchar2(200);
    l_payroll_id_date_bind       DATE;
    l_payroll_id_bind            NUMBER;
    l_payroll_id_date2_bind      DATE;
    l_pstl_zip_rng_id_date_bind  DATE;
    l_pstl_zip_rng_id_date2_bind DATE;
    l_pstl_zip_rng_id_date3_bind DATE;
    l_pstl_zip_rng_id_bind       NUMBER;
    l_pstl_zip_rng_id_date4_bind DATE;
    l_organization_id_date_bind  DATE;
    l_organization_id_bind       NUMBER;
    l_organization_id_date2_bind DATE;
    l_organization_id_date3_bind DATE;
    -- 2940151
    l_grade_ladder_bind          NUMBER;
    l_grade_ladder_date_bind	 DATE;
    l_grade_ladder_date2_bind	 DATE;
    l_grade_ladder_date3_bind	 DATE;
    l_grade_ladder_date4_bind	 DATE;
    l_qual_type_bind		 NUMBER;
    l_qual_status_bind		 VARCHAR2(30);
    l_rate_id_bind		 NUMBER;
    l_rate_id_date_bind		 DATE;
    l_per_sel_dt_from		 DATE;
    l_per_sel_dt_to		 DATE;
    l_per_sel_freq_cd		 NUMBER;
    l_year_from			 NUMBER;
    l_year_to			 NUMBER;
    l_freq               NUMBER;
    l_seg_value          VARCHAR2(100);
    l_def_flag           VARCHAR2(1);
    l_dflt_grade_ldr_id  NUMBER;
    l_count      number := 0;         -- the count of the individual segments
    l_pos        number := 1;         -- the position of the individual segment
    l_pos_sep    number;              -- the position of the separator
    l_length     number;              -- the length of the string
    l_org_heirarchy_date DATE;
    l_org_heirarchy   number;
    l_org_starting_node_id number;
    l_concat_segs_date           DATE;
    -- end 2940151
    l_ler_id_bind                NUMBER;
    l_life_date_bind             DATE;
    l_person_date_bind           DATE;
    --
    l_person_type_id_date_bind   DATE; -- Bug 2224299
    l_gsp_whclause               LONG;
    --
    -- irec
    l_irec_whclause               varchar2(2000);
    l_assignment_id_bind          number;
    -- irec end


-- 2940151 --cursors
    -- Get the delimiter for the kff structure
    cursor c_delimiter is
    select concatenated_segment_delimiter
    from  fnd_id_flex_structures
    where id_flex_num  = p_id_flex_num
    and   application_id = 801
    and   id_flex_code = 'GRP';

    l_concat_sep varchar2(1);

    -- Get the segments in the order defined in the structure
    cursor c_application_column_name is
    select   application_column_name
    from     fnd_id_flex_segments
    where    id_flex_num   = p_id_flex_num
    and      application_id = 801
    and      id_flex_code = 'GRP'
    and      enabled_flag  = 'Y'
    order by segment_num;

    l_application_column_name c_application_column_name%ROWTYPE;

    -- get the default grade ladder
    cursor c_dflt_grade_ladder is
--  select pgm.pgm_prvds_no_dflt_enrt_flag, pgm.pgm_id  /* Bug 4030438 */
    select pgm.dflt_pgm_flag, pgm.pgm_id
    from ben_pgm_f pgm
    where pgm.pgm_id = p_grade_ladder_id
    and p_effective_date between effective_start_date and effective_end_date
    and business_group_id = p_business_group_id ;


  --
  BEGIN
    --
    IF p_lmt_prpnip_by_org_flag = 'N' then
       --
       l_query_str         :=
         ' select ppf.person_id from per_all_people_f ppf' ||
           ' where ppf.business_group_id = :bus_grp_id' ||
             ' and :effective_date is not null ' ;
       --
    else
       --
       l_query_str         :=
         ' select ppf.person_id from per_all_people_f ppf' ||
            ', per_all_assignments_f paf1' ||
                        ' where ppf.business_group_id = :bus_grp_id' ||
            ' and ppf.person_id = paf1.person_id(+) ' ||
            ' and ppf.business_group_id = paf1.business_group_id(+) ' ||
            ' and paf1.primary_flag(+) = ''Y'' ' ||
            ' and (paf1.assignment_id is null '  ||
            '      or paf1.assignment_id = ' ||
                      ' ( select min(paf2.assignment_id) ' ||
                        ' from per_all_assignments_f paf2 ' ||
                        ' where paf2.person_id = paf1.person_id ' ||
                          ' and   paf2.assignment_type <> ''C'''||
                          ' and paf1.business_group_id = paf2.business_group_id ' ||
                          ' and paf2.primary_flag = ''Y'' ' ||
                          ' and :effective_date between paf2.effective_start_date' ||
                                                  ' and paf2.effective_end_date' ||
                      ' ) ' ||
                 ' )' ;
       --
    end if;
    --
    -- If a person id was passed use it in the query.
    IF p_person_id IS NOT NULL THEN
      l_person_id_bind  := p_person_id;
      l_query_str       := l_query_str || ' and ppf.person_id = :person_id';
    ELSE
      l_person_id_bind  := -1;
      l_query_str       := l_query_str || ' and -1 = :person_id';
    END IF;
    --
    -- Attach the subquery
    -- GRADE/STEP : In case mode is grade step and need to create
    -- grade/step life events for everyone then don't check for
    -- potential existence; potentials will be created for everyone.
    --

    if (p_mode = 'M' or (p_mode = 'G' and p_asg_events_to_all_sel_dt is null)) then
      --
      -- ABSENCES : Only consider persons with absence or grade/step potentials.
      --
      if p_mode = 'M' then
         l_typ_cd := '''ABS''';
      elsif p_mode = 'G' then
         l_typ_cd := '''GSP''';
      end if;
      --
      l_query_str         :=
       l_query_str || ' and exists (select null' ||
        ' from ben_ptnl_ler_for_per ptn' ||
        '      ,ben_ler_f ler_abse' ||
        ' where ptn.person_id = ppf.person_id' ||
        ' and   ler_abse.ler_id = ptn.ler_id' ||
        ' and   ptn.lf_evt_ocrd_dt between ler_abse.effective_start_date and ler_abse.effective_end_date' ||
        ' and   ler_abse.typ_cd = ' || l_typ_cd ||
        ' and ptn.ptnl_ler_for_per_stat_cd not in(''VOIDD'',''PROCD'')';
      --
    elsif p_mode = 'L' then
      --
      l_typ_cd := 'not in ( ''COMP'', ''ABS'', ''GSP'')';
      --

      l_query_str         :=
       l_query_str || ' and exists (select null' ||
        ' from ben_ptnl_ler_for_per ptn' ||
        '      ,ben_ler_f ler_ben' ||
        ' where ptn.person_id = ppf.person_id' ||
        ' and   ler_ben.ler_id = ptn.ler_id' ||
        ' and   ptn.lf_evt_ocrd_dt between ler_ben.effective_start_date and ler_ben.effective_end_date' ||
        -- l_type_cd has not in so = not be allowed
        ' and   ler_ben.typ_cd  ' || l_typ_cd ||
        ' and ptn.ptnl_ler_for_per_stat_cd not in(''VOIDD'',''PROCD'')';
      --
    end if;

     -- If a ler_id was passed then attach it to the subquery
    IF p_ler_id IS NOT NULL THEN
      --
      -- 3394157
      if ((p_mode <> 'G' or (p_mode = 'G' and p_asg_events_to_all_sel_dt is null))
      and p_mode not in ( 'I','A') ) then
    	l_ler_id_bind  := p_ler_id;
    	l_query_str    := l_query_str || ' and ptn.ler_id = :ler_id ';
       --
      else
       -- When p_asg_events_to_all_sel_dt is set no need to check
       -- for existence of potentials.
        l_ler_id_bind  := -1;
    	l_query_str    := l_query_str || ' and -1 = :ler_id ';
      end if;
      -- 3394157
    ELSE
      --
      l_ler_id_bind  := -1;
      l_query_str    := l_query_str || ' and -1 = :ler_id ';
    --
    END IF;
    --
    -- If a person type id was specified, use it in a subquery.
    --
    IF p_person_type_id IS NOT NULL THEN
      --
      -- Bind in required person type id
      --
      l_person_type_id_bind  := p_person_type_id;

      -- Changed the query for fixing Bug 2224299
      -- l_query_str            :=
      --  l_query_str || ' and exists (select null' ||
      --    ' from per_person_types ppt' ||
      --    ' where ppf.person_type_id = ppt.person_type_id' ||
      --    ' and ppt.person_type_id = :person_type_id' ||
      --    ' and ppt.active_flag = ''Y'')';

      l_person_type_id_date_bind  := p_effective_date;

      l_query_str :=
        l_query_str || ' and exists (select null from per_person_types ppt,per_person_type_usages_f ptu ' ||
          ' where ppt.person_type_id = ptu.person_type_id' ||
          ' and ppt.person_type_id = :person_type_id' ||
          ' and ptu.person_id = ppf.person_id' ||
          ' and :person_type_id_date between ptu.effective_start_date and ptu.effective_end_date' ||
          ' and ppt.active_flag = ''Y'')';

    ELSE
      l_person_type_id_bind  := -1;

      -- Changed the query for fixing Bug 2224299
      -- l_query_str            := l_query_str || ' and -1 = :person_type_id';

      l_person_type_id_date_bind  := hr_api.g_sot;
      l_query_str := l_query_str ||
          ' and -1 = :person_type_id and :person_type_id_date IS NOT NULL';

    END IF;
    -- If a benfts_grp_id was specified, use it in a subquery.
    IF p_benfts_grp_id IS NOT NULL THEN
      -- Bind in required person type id
      l_benfts_grp_id_bind  := p_benfts_grp_id;
      l_query_str           :=
                   l_query_str || ' and ppf.benefit_group_id = :benfts_grp_id';
    ELSE
      l_benfts_grp_id_bind  := -1;
      l_query_str           := l_query_str || ' and -1 = :benfts_grp_id';
    END IF;
    --
    -- If a location_id was specified, use it the main query.
    --
    IF p_location_id IS NOT NULL THEN
      -- Bind in required variables
      l_location_id_bind       := p_location_id;
      l_location_id_date_bind  := p_effective_date;
      l_query_str              :=
        l_query_str || ' and exists (select null' ||
          ' from per_all_assignments_f paf' ||
          ' where paf.person_id = ppf.person_id' ||
          ' and   paf.assignment_type <> ''C'''||
          ' and paf.primary_flag = ''Y''' ||
          ' and paf.business_group_id = ppf.business_group_id' ||
          ' and :location_id_date' ||
          ' between paf.effective_start_date' ||
          ' and paf.effective_end_date' ||
          ' and paf.location_id = :location_id)';
    ELSE
      l_location_id_bind       := -1;
      l_location_id_date_bind  := hr_api.g_sot;
      l_query_str              :=
        l_query_str ||
          ' and :location_id_date IS NOT NULL and -1 = :location_id ';
    END IF;
    --
    -- GRADE/STEP : If a collective_agreement_id  was specified, use it the main query.
    --
    IF p_cagr_id IS NOT NULL THEN
      -- Bind in required variables
      l_cagr_id_bind       := p_cagr_id;
      l_cagr_id_date_bind  := p_effective_date;
      l_query_str              :=
        l_query_str || ' and exists (select null' ||
          ' from per_all_assignments_f paf' ||
          ' where paf.person_id = ppf.person_id' ||
          ' and   paf.assignment_type <> ''C'''||
          ' and paf.primary_flag = ''Y''' ||
          ' and paf.business_group_id = ppf.business_group_id' ||
          ' and :cagr_id_date' ||
          ' between paf.effective_start_date' ||
          ' and paf.effective_end_date' ||
          ' and paf.collective_agreement_id = :cagr_id)';
    ELSE
      l_cagr_id_bind       := -1;
      l_cagr_id_date_bind  := hr_api.g_sot;
      l_query_str              :=
        l_query_str ||
          ' and :cagr_id_date IS NOT NULL and -1 = :cagr_id ';
    END IF;
    --
    -- GRADE/STEP Restrict the persons to only Employees
    --
    IF p_mode = 'G' THEN
      --
      l_gsp_whclause :=  ' and exists ( select ''x'' from per_person_type_usages_f ptu, '||
                                   ' per_person_types ppt '||
                                   ' where ppt.person_type_id = ptu.person_type_id '||
                                   ' and ppt.system_person_type = ''EMP'''||
                                   ' and ppt.business_group_id = ppf.business_group_id '||
                                   ' and ptu.person_id         = ppf.person_id '||
                                   ' and :effective_date between ptu.effective_start_date '||
                                                          ' and  ptu.effective_end_date ) ' ;
      l_query_str   := l_query_str||l_gsp_whclause ;
      --
      hr_utility.set_location('Building cwb where clause ',29);
      --
    ELSE
      --
      -- Bug 2279394 : where clause is not formed correctly, as and is missing
      -- in where clause.
      --
      l_gsp_whclause := ' and :effective_date is NOT NULL ' ;
      l_query_str   := l_query_str||l_gsp_whclause ;
      --
    END IF;
    --
--
    -- IREC
    -- if its iREC pick up only applicants
    IF p_mode = 'I' THEN
      l_assignment_id_bind := ben_manage_life_events.g_irec_ass_rec.assignment_id;
      l_irec_whclause :=  ' and exists ( select ''x'' from per_person_type_usages_f ptu, '||
                                   ' per_person_types ppt, per_all_assignments_f apl_ass '||
                                   ' where ppt.person_type_id = ptu.person_type_id '||
                                   ' and ppt.system_person_type in( ''APL'', ''APL_EX_APL'',''EMP_APL'', ''EX_EMP_APL'')'||
                                   ' and ppt.business_group_id = ppf.business_group_id '||
                                   ' and ptu.person_id         = ppf.person_id '||
                                   ' and :effective_date between ptu.effective_start_date '||
                                                          ' and  ptu.effective_end_date  ' ||
                                   ' and apl_ass.person_id         = ppf.person_id '||
                                   ' and apl_ass.assignment_id = :assignment_id'||
                                   ' and apl_ass.assignment_type =''A'''||
                                   ' and :effective_date between apl_ass.effective_start_date '||
                                                          ' and  apl_ass.effective_end_date ) ' ;

     l_query_str   := l_query_str||l_irec_whclause ;
    ELSE
      --
      -- Bug 2279394 : where clause is not formed correctly, as and is missing
      -- in where clause.
      --
      l_assignment_id_bind := -1;--ben_manage_life_events.g_irec_ass_rec.assignment_id;
      l_irec_whclause := ' and :effective_date is NOT NULL and :assignment_id =-1 and  :effective_date is NOT NULL ' ;
      l_query_str   := l_query_str||l_irec_whclause ;
      --
    END IF;

    -- If a legal_entity_id was specified, use it in a subquery.
    IF p_legal_entity_id IS NOT NULL THEN
      -- Bind in required legal entity id
      l_legal_entity_id_date_bind  := p_effective_date;
      l_legal_entity_id_bind       := p_legal_entity_id;
      l_query_str                  :=
        l_query_str || ' and exists (select null' ||
          ' from  hr_soft_coding_keyflex hsc,' ||
          ' per_all_assignments_f paf' ||
          ' where paf.person_id = ppf.person_id' ||
          ' and   paf.assignment_type <> ''C''' ||
          ' and paf.primary_flag = ''Y''' ||
          ' and paf.business_group_id = ppf.business_group_id' ||
          ' and :legal_entity_id_date' ||
          ' between paf.effective_start_date' ||
          ' and paf.effective_end_date ' ||
          ' and paf.soft_coding_keyflex_id = hsc.soft_coding_keyflex_id' ||
          ' and hsc.segment1 = to_char(:legal_entity_id)) ';
    /* Note the use of to_char this is for CBO joins between varchar2
                  and number columns */
    ELSE
      l_legal_entity_id_date_bind  := hr_api.g_sot;
      l_legal_entity_id_bind       := -1;
      l_query_str                  :=
        l_query_str ||
          ' and :legal_entity_id_date IS NOT NULL and -1 = :legal_entity_id ';
    END IF;
    -- If a payroll_id was specified, use it in a subquery.
    IF p_payroll_id IS NOT NULL THEN
      -- Bind in required payroll id
      l_payroll_id_date_bind   := p_effective_date;
      l_payroll_id_bind        := p_payroll_id;
      l_payroll_id_date2_bind  := p_effective_date;
      l_query_str              :=
        l_query_str || ' and exists (select null' || ' from pay_payrolls_f pay,' ||
          ' per_all_assignments_f paf' ||
          ' where paf.person_id = ppf.person_id' ||
          ' and   paf.assignment_type <> ''C''' ||
          ' and paf.primary_flag = ''Y''' ||
          ' and paf.business_group_id = ppf.business_group_id' ||
          ' and :payroll_id_date' ||
          ' between paf.effective_start_date' ||
          ' and paf.effective_end_date ' ||
          ' and pay.payroll_id = :payroll_id' ||
          ' and pay.payroll_id = paf.payroll_id' ||
          ' and :payroll_id_date2' ||
          ' between pay.effective_start_date' ||
          ' and pay.effective_end_date)';
    ELSE
      l_payroll_id_date_bind   := hr_api.g_sot;
      l_payroll_id_bind        := -1;
      l_payroll_id_date2_bind  := hr_api.g_sot;
      l_query_str              :=
        l_query_str ||
          ' and :payroll_id_date IS NOT NULL and -1 = :payroll_id' ||
          ' and :payroll_id_date2 IS NOT NULL ';
    END IF;
    -- If a pstl_zip_rng_id was specified, use it in a subquery.
    IF p_pstl_zip_rng_id IS NOT NULL THEN
      -- Bind in required pstl zip rng id
      l_pstl_zip_rng_id_date_bind   := p_effective_date;
      l_pstl_zip_rng_id_date2_bind  := p_effective_date;
      l_pstl_zip_rng_id_date3_bind  := p_effective_date;
      l_pstl_zip_rng_id_bind        := p_pstl_zip_rng_id;
      l_pstl_zip_rng_id_date4_bind  := p_effective_date;
      --
      l_query_str                   :=
        l_query_str || ' and exists (select null' || ' from per_addresses pad,' ||
          ' ben_pstl_zip_rng_f rzr' ||
          ' where pad.person_id = ppf.person_id' ||
          ' and pad.primary_flag = ''Y''' ||
          ' and :ptl_zip_rng_id_date' ||
          ' between nvl(pad.date_from,:pstl_zip_rng_id_date2)' ||
          ' and nvl(pad.date_to,:pstl_zip_rng_id_date3)' ||
          ' and rzr.pstl_zip_rng_id = :pstl_zip_rng_id' ||
          ' and pad.postal_code' ||
          ' between rzr.from_value' ||
          ' and rzr.to_value' ||
          ' and :pstl_zip_rng_id_date4' ||
          ' between rzr.effective_start_date' ||
          ' and rzr.effective_end_date)';
    ELSE
      l_pstl_zip_rng_id_date_bind   := hr_api.g_sot;
      l_pstl_zip_rng_id_date2_bind  := hr_api.g_sot;
      l_pstl_zip_rng_id_date3_bind  := hr_api.g_sot;
      l_pstl_zip_rng_id_bind        := -1;
      l_pstl_zip_rng_id_date4_bind  := hr_api.g_sot;
      l_query_str                   :=
        l_query_str || ' and :pstl_zip_rng_id_date IS NOT NULL' ||
          ' and :pstl_zip_rng_id_date2 IS NOT NULL' ||
          ' and :pstl_zip_rng_id_date3 IS NOT NULL' ||
          ' and -1 = :pstl_zip_rng_id' ||
          ' and :pstl_zip_rng_id_date4 IS NOT NULL ';
    END IF;
    -- If an organization_id was specified, use it in a subquery.
    IF p_organization_id IS NOT NULL THEN
      -- Bind in required organization id
      l_organization_id_date_bind   := p_effective_date;
      l_organization_id_bind        := p_organization_id;
      l_organization_id_date2_bind  := p_effective_date;
      l_organization_id_date3_bind  := p_effective_date;
      l_query_str                   :=
        l_query_str || ' and exists (select null' ||
          ' from hr_organization_units org,' ||
          ' per_all_assignments_f paf' ||
          ' where paf.person_id = ppf.person_id' ||
          ' and   paf.assignment_type <> ''C''' ||
          ' and paf.primary_flag = ''Y''' ||
          ' and paf.business_group_id = ppf.business_group_id' ||
          ' and :organization_id_date' ||
          ' between paf.effective_start_date' ||
          ' and paf.effective_end_date' ||
          ' and paf.organization_id = org.organization_id' ||
          ' and org.organization_id = :organization_id' ||
          ' and :organization_id_date2' ||
          ' between org.date_from' ||
          ' and nvl(org.date_to,:organization_id_date3))';
    ELSE
      l_organization_id_date_bind   := hr_api.g_sot;
      l_organization_id_bind        := -1;
      l_organization_id_date2_bind  := hr_api.g_sot;
      l_organization_id_date3_bind  := hr_api.g_sot;
      l_query_str                   :=
        l_query_str || ' and :organization_id_date IS NOT NULL' ||
          ' and -1 = :organization_id' ||
          ' and :organization_id_date2 IS NOT NULL' ||
          ' and :organization_id_date3 IS NOT NULL ';
    END IF;
    -- Finish the subquery
    l_life_date_bind    := p_effective_date;
    --
    -- GSP New : When p_asg_events_to_all_sel_dt is set no need to check
    -- for existence of potentials.
    --
    if ((p_mode <> 'G' or (p_mode = 'G' and p_asg_events_to_all_sel_dt is null)))
    and p_mode NOT IN ('I','A')    then
       l_query_str         :=
       l_query_str || ' and ptn.lf_evt_ocrd_dt <= :life_date)';
    else
       l_query_str         :=
       l_query_str || ' and  :life_date is not null';
    end if;
    --
    -- GSP New
    --
    --
    -- 2940151
    -- Grade / Step - if grade ladder parameter is specified


    IF p_org_heirarchy_id is NOT NULL THEN
       -- bind variables
       l_org_heirarchy_date := p_effective_date;
       l_org_heirarchy := p_org_heirarchy_id;
       l_org_starting_node_id := p_org_starting_node_id;

       l_query_str  :=
        l_query_str ||' and exists'||
        ' (select 1 from per_org_structure_elements ose'||
        ' , per_all_assignments_f paf' ||
        ' where paf.person_id = ppf.person_id' ||
        ' and   paf.assignment_type <> ''C''' ||
        ' and paf.primary_flag = ''Y''' ||
        ' and paf.business_group_id = ppf.business_group_id' ||
        ' and :org_heirarchy_date' ||
        ' between paf.effective_start_date' ||
        ' and paf.effective_end_date' ||
        ' and ose.org_structure_version_id = :org_hierarchy'||
        ' and paf.organization_id = ose.organization_id_child'||
        ' and paf.assignment_type = ''E'''||
        ' connect by prior ose.organization_id_child = ose.organization_id_parent'||
        ' and ose.org_structure_version_id = :org_hierarchy'||
        ' start with ose.organization_id_parent = :org_starting_node_id'||
        ' and ose.org_structure_version_id = :org_hierarchy'||
	' union all'||
        ' select 1 from per_all_assignments_f paf' ||
        ' where paf.person_id = ppf.person_id' ||
        ' and   paf.assignment_type <> ''C''' ||
        ' and paf.primary_flag = ''Y''' ||
        ' and paf.business_group_id = ppf.business_group_id' ||
        ' and :org_heirarchy_date' ||
        ' between paf.effective_start_date' ||
        ' and paf.effective_end_date' ||
        ' and paf.organization_id = :org_starting_node_id'||
        ' and paf.assignment_type = ''E'''||
	' )';
    ELSE
       -- bind variables
       l_org_heirarchy_date := hr_api.g_sot;
       l_org_heirarchy := -1;
       l_org_starting_node_id := -1;
       l_query_str  :=
        l_query_str || ' and :org_heirarchy_date is not null'||
        ' and -1 = :org_hierarchy '||
        ' and -1 = :org_hierarchy '||
        ' and -1 = :org_starting_node_id'||
        ' and -1 = :org_hierarchy ' ||
        ' and :org_heirarchy_date is not null'||
        ' and -1 = :org_starting_node_id';
    END IF;

      --
    IF p_grade_ladder_id is NOT NULL THEN
       -- bind variables
       l_grade_ladder_bind := p_grade_ladder_id;
       l_grade_ladder_date_bind := p_effective_date;
       l_grade_ladder_date2_bind := p_effective_date;
       l_grade_ladder_date3_bind := p_effective_date;
       -- bug 3171229
       l_grade_ladder_date4_bind := p_effective_date;

       -- check if the grade ladder specified is the default grade ladder
       open c_dflt_grade_ladder;
       fetch c_dflt_grade_ladder into l_def_flag, l_dflt_grade_ldr_id;
       close c_dflt_grade_ladder;

       if l_def_flag ='Y' THEN
          l_query_str         :=
             l_query_str ||
             ' and exists'||
	     ' (select 1 from per_all_assignments_f paf'||
	     ' where paf.person_id = ppf.person_id '||
--           ' and   paf.assignment_type <> ''C''' ||
	     ' and   paf.assignment_type = ''E''' ||   /* Bug 7307975 Assumption is that GSP is run only for Employees */
	     ' and paf.primary_flag = ''Y''' ||
--	     ' and paf.business_group_id = ppf.business_group_id' ||  /* Bug 7307975 */
	     ' and (paf.grade_ladder_pgm_id = :grade_ladder_id'||
	     ' or (paf.grade_ladder_pgm_id is null'||
	     ' and paf.grade_id in'||
	     ' ( select pln.mapping_table_pk_id'||
	     ' from ben_pl_f pln'||
	     ' , ben_pgm_f pgm'||
	     ' , ben_plip_f plip'||
	     ' where pln.pl_id = plip.pl_id'||
	     ' and plip.pgm_id = pgm.pgm_id'||
	     ' and pgm.dflt_pgm_flag = ''Y'''||
--	     ' and pgm.pgm_prvds_no_dflt_enrt_flag = ''Y'''||   /* Bug 4030438 */
	     ' and :grade_ladder_id_date between pln.effective_start_date and pln.effective_end_date'||
	     ' and :grade_ladder_id_date2 between pgm.effective_start_date and pgm.effective_end_date'||
	     ' and :grade_ladder_id_date3 between plip.effective_start_date and plip.effective_end_date)))'||
             ' and :grade_ladder_id_date4 between paf.effective_start_date and paf.effective_end_date)'
             ;
       else
	  -- bug 3171229 -- make variables date2,3,4 as sot
	  -- let l_grade_ladder_date_bind be effective date

          l_grade_ladder_date2_bind := hr_api.g_sot;
          l_grade_ladder_date3_bind := hr_api.g_sot;
          l_grade_ladder_date4_bind := hr_api.g_sot;


          -- bug 3171229 -- changed the bind variable order in the sql
          l_query_str         :=
             l_query_str || ' and exists('||
             ' select 1 from per_all_assignments_f paf' ||
             ' where paf.person_id = ppf.person_id' ||
--           ' and   paf.assignment_type <> ''C''' ||
             ' and   paf.assignment_type = ''E''' ||        /* Bug 7307975 Assumption is that GSP is run only for Employees */
             ' and paf.primary_flag = ''Y''' ||
--             ' and paf.business_group_id = ppf.business_group_id' ||   /* Bug 7307975 */
             ' and paf.grade_ladder_pgm_id = :grade_ladder_id'||
             ' and :grade_ladder_id_date between paf.effective_start_date and paf.effective_end_date)'||
             ' and :grade_ladder_id_date2 is not null'||
             ' and :grade_ladder_id_date3 is not null'||
             ' and :grade_ladder_id_date4 is not null';
       end if;
    ELSE
       /* GSP Rate Sync
       *  Here we need to check that if operation code = SYNC, then only those persons should
       *  be selected, whose grade ladder allows salary updates. Remember that LOV for Grade Ladder
       *  in GSP Rate Sync conc prog would bring up only those grade ladders which allow salary updates
       */
       if p_mode = 'G' and p_lf_evt_oper_cd = 'SYNC'
       then
         --
         l_grade_ladder_bind := -1;
         l_grade_ladder_date_bind  := p_effective_date;    /* GSP Rate Sync */
         l_grade_ladder_date2_bind := p_effective_date;
         l_grade_ladder_date3_bind := hr_api.g_sot;
         l_grade_ladder_date4_bind := hr_api.g_sot;

         /* Bug 4030438
         -- For GSP Rate Sync, check EITHER
         --     (a) the person is assigned to Grade Ladder that allows salary updates
         -- OR  (b) the business group has default grade ladder which allows salary updates
         */
         l_query_str :=
            l_query_str || ' and -1 =:grade_ladder_id'||
            ' and exists'||
    	    ' (select 1 from per_all_assignments_f paf '||
  	    ' where paf.person_id = ppf.person_id '||
  	    ' and   paf.assignment_type <> ''C''' ||
  	    ' and paf.primary_flag = ''Y''' ||
            ' and :grade_ladder_id_date2 between paf.effective_start_date and paf.effective_end_date ' ||
            ' and exists ' ||
            '     ( select 1 from ben_pgm_f pgm ' ||
            '       where ' ||
            '       ( pgm.pgm_id = paf.grade_ladder_pgm_id OR ' ||
            '         pgm.dflt_pgm_flag = ''Y'' ' ||
            '        ) ' ||
            '       and :grade_ladder_id_date between pgm.effective_start_date and pgm.effective_end_date ' ||
            '       and pgm.update_salary_cd <> ''NO_UPDATE'' ' ||
            '       and pgm.business_group_id = paf.business_group_id ' ||
            '      ) ' ||
            '  ) ' ||
            ' and :grade_ladder_id_date3 is not null'||
            ' and :grade_ladder_id_date4 is not null';

       else
         --
         l_grade_ladder_bind := -1;
         l_grade_ladder_date_bind  := hr_api.g_sot;
         l_grade_ladder_date2_bind := hr_api.g_sot;
         l_grade_ladder_date3_bind := hr_api.g_sot;
         l_grade_ladder_date4_bind := hr_api.g_sot;

         l_query_str :=
            l_query_str || ' and -1 =:grade_ladder_id'||
            ' and :grade_ladder_id_date is not null'||
            ' and :grade_ladder_id_date2 is not null'||
            ' and :grade_ladder_id_date3 is not null'||
            ' and :grade_ladder_id_date4 is not null';
          --
       end if;
       /* GSP Rate Sync */
       --
    END IF; -- p_grade_ladder_id is NOT NULL

    IF p_qual_type IS NOT NULL THEN

       -- bind variables
       l_qual_type_bind := p_qual_type;
       l_qual_status_bind := p_qual_status;

       l_query_str         :=
          l_query_str || ' and exists'||
          ' (select 1'||
          ' from per_qualifications pq'||
          ' where ppf.person_id = pq.person_id'||
          ' and pq.qualification_type_id = :qual_type'||
          ' and nvl(pq.status,''xxx'' ) = nvl(nvl(:qual_status, pq.status), ''xxx''))';
    ELSE
       l_qual_type_bind := -1 ;
       l_qual_status_bind := -1 ;

       l_query_str         :=
          l_query_str || ' and -1 = :qual_type'||
          ' and -1 = :qual_status';
    END IF;

    IF p_rate_id IS NOT NULL THEN

       --bind variables
       l_rate_id_bind := p_rate_id ;
       l_rate_id_date_bind := p_effective_date;

       l_query_str         :=
          l_query_str || ' and exists'||
	  ' (select 1'||
	  ' from per_spinal_point_placements_f spp'||
      ' , per_all_assignments_f paf'||
	  ' where paf.person_id = ppf.person_id'||
      ' and :effective_date between paf.effective_start_date and paf.effective_end_date'||
      ' and   paf.assignment_type <> ''C''' ||
      ' and paf.primary_flag = ''Y''' ||
      ' and paf.business_group_id = ppf.business_group_id' ||
      ' and paf.assignment_id = spp.assignment_id'||
	  ' and spp.parent_spine_id = :rate_id'||
	  ' and :effective_date between spp.effective_start_date and spp.effective_end_date)';
    ELSE
       l_rate_id_bind := -1 ;
       l_rate_id_date_bind := hr_api.g_sot;
       l_query_str         :=
          l_query_str || ' and :effective_date is not null'||
          ' and -1 = :rate_id'||
          ' and :effective_date is not null';
    END IF;

    IF p_per_sel_dt_cd IS NOT NULL THEN

       -- bind variables

       l_per_sel_dt_from := p_per_sel_dt_from ;
       l_per_sel_dt_to := p_per_sel_dt_to ;
       --l_per_sel_freq_cd := p_per_sel_freq_cd ;
       l_year_from := p_year_from;
       l_year_to := p_year_to;

       IF p_per_sel_freq_cd = 'M' THEN
          l_freq := 1;
       ELSE
          l_freq := 12;
       END IF;


       IF p_per_sel_dt_cd = 'AOJ' THEN



        l_query_str         :=
             l_query_str || ' and('||
             ' add_months( ppf.original_date_of_hire, '||p_year_from||' *'|| l_freq||' )'||
             ' between '''||to_char(p_per_sel_dt_from, 'DD-MON-YYYY')||''' and '''||to_char(p_per_sel_dt_to, 'DD-MON-YYYY') ||''' or'||
             ' add_months( ppf.original_date_of_hire, '||p_year_to||' * '|| l_freq||' )'||
             ' between '''||to_char(p_per_sel_dt_from, 'DD-MON-YYYY')||''' and '''||to_char(p_per_sel_dt_to, 'DD-MON-YYYY') ||''' or'||
             ' months_between ('''||to_char(p_per_sel_dt_from, 'DD-MON-YYYY')||''', ppf.original_date_of_hire )/ '|| l_freq ||
             ' between nvl('||p_year_from||',floor( months_between ('''||to_char(p_per_sel_dt_from, 'DD-MON-YYYY')||''', ppf.original_date_of_hire )/ '|| l_freq||')) and nvl('||p_year_to||',floor( months_between ('''||
             to_char(p_per_sel_dt_to, 'DD-MON-YYYY')||''',   ppf.original_date_of_hire )/ '||l_freq||')) or'||
             ' months_between ('''||to_char(p_per_sel_dt_to, 'DD-MON-YYYY')||''',   ppf.original_date_of_hire )/ '||l_freq||
             ' between nvl('||p_year_from||',floor( months_between ('''||to_char(p_per_sel_dt_from, 'DD-MON-YYYY')||''', ppf.original_date_of_hire )/ '|| l_freq||')) and nvl('||p_year_to||',floor( months_between ('''||
             to_char(p_per_sel_dt_to, 'DD-MON-YYYY')||''',   ppf.original_date_of_hire )/ '||l_freq||')))'
             ;

       ELSIF p_per_sel_dt_cd = 'DOB' THEN


        l_query_str         :=
             l_query_str || ' and('||
             ' add_months( ppf.date_of_birth, '||p_year_from||' *'|| l_freq||' )'||
             ' between '''||to_char(p_per_sel_dt_from, 'DD-MON-YYYY')||''' and '''||to_char(p_per_sel_dt_to, 'DD-MON-YYYY') ||''' or'||
             ' add_months( ppf.date_of_birth, '||p_year_to||' * '|| l_freq||' )'||
             ' between '''||to_char(p_per_sel_dt_from, 'DD-MON-YYYY')||''' and '''||to_char(p_per_sel_dt_to, 'DD-MON-YYYY') ||''' or'||
             ' months_between ('''||to_char(p_per_sel_dt_from, 'DD-MON-YYYY')||''', ppf.date_of_birth )/ '|| l_freq ||
             ' between nvl('||p_year_from||',floor( months_between ('''||to_char(p_per_sel_dt_from, 'DD-MON-YYYY')||''', ppf.date_of_birth )/ '|| l_freq||')) and nvl('||p_year_to||',floor( months_between ('''||
             to_char(p_per_sel_dt_to, 'DD-MON-YYYY')||''',   ppf.date_of_birth )/ '||l_freq||')) or'||
             ' months_between ('''||to_char(p_per_sel_dt_to, 'DD-MON-YYYY')||''',   ppf.date_of_birth )/ '||l_freq||
             ' between nvl('||p_year_from||',floor( months_between ('''||to_char(p_per_sel_dt_from, 'DD-MON-YYYY')||''', ppf.date_of_birth )/ '|| l_freq||')) and nvl('||p_year_to||',floor( months_between ('''||
             to_char(p_per_sel_dt_to, 'DD-MON-YYYY')||''',   ppf.date_of_birth )/ '||l_freq||')))'
             ;

       ELSIF p_per_sel_dt_cd = 'ASD' THEN

         l_query_str         :=
             l_query_str || ' and exists('||
             ' select 1 from per_periods_of_service pos'||
             ' where pos.person_id = ppf.person_id'||
             ' and ('||
             ' add_months( pos.adjusted_svc_date, '||p_year_from||' *'|| l_freq||' )'||
             ' between '''||to_char(p_per_sel_dt_from, 'DD-MON-YYYY')||''' and '''||to_char(p_per_sel_dt_to, 'DD-MON-YYYY') ||''' or'||
             ' add_months( pos.adjusted_svc_date, '||p_year_to||' * '|| l_freq||' )'||
             ' between '''||to_char(p_per_sel_dt_from, 'DD-MON-YYYY')||''' and '''||to_char(p_per_sel_dt_to, 'DD-MON-YYYY') ||''' or'||
             ' months_between ('''||to_char(p_per_sel_dt_from, 'DD-MON-YYYY')||''', pos.adjusted_svc_date )/ '|| l_freq ||
             ' between nvl('||p_year_from||',floor( months_between ('''||to_char(p_per_sel_dt_from, 'DD-MON-YYYY')||''', pos.adjusted_svc_date )/ '|| l_freq||')) and nvl('||p_year_to||',floor( months_between ('''||
             to_char(p_per_sel_dt_to, 'DD-MON-YYYY')||''',   pos.adjusted_svc_date )/ '||l_freq||')) or'||
             ' months_between ('''||to_char(p_per_sel_dt_to, 'DD-MON-YYYY')||''',   pos.adjusted_svc_date )/ '||l_freq||
             ' between nvl('||p_year_from||',floor( months_between ('''||to_char(p_per_sel_dt_from, 'DD-MON-YYYY')||''', pos.adjusted_svc_date )/ '|| l_freq||')) and nvl('||p_year_to||',floor( months_between ('''||
             to_char(p_per_sel_dt_to, 'DD-MON-YYYY')||''',   pos.adjusted_svc_date )/ '||l_freq||'))))'
             ;

       ELSIF p_per_sel_dt_cd = 'LHD' THEN

         l_query_str         :=
             l_query_str || ' and exists('||
             ' select 1 from per_periods_of_service pos'||
             ' where pos.person_id = ppf.person_id'||
             ' and ('||
             ' add_months( pos.date_start, '||p_year_from||' *'|| l_freq||' )'||
             ' between '''||to_char(p_per_sel_dt_from, 'DD-MON-YYYY')||''' and '''||to_char(p_per_sel_dt_to, 'DD-MON-YYYY') ||''' or'||
             ' add_months( pos.date_start, '||p_year_to||' * '|| l_freq||' )'||
             ' between '''||to_char(p_per_sel_dt_from, 'DD-MON-YYYY')||''' and '''||to_char(p_per_sel_dt_to, 'DD-MON-YYYY') ||''' or'||
             ' months_between ('''||to_char(p_per_sel_dt_from, 'DD-MON-YYYY')||''', pos.date_start )/ '|| l_freq ||
             ' between nvl('||p_year_from||',floor( months_between ('''||to_char(p_per_sel_dt_from, 'DD-MON-YYYY')||''', pos.date_start )/ '|| l_freq||')) and nvl('||p_year_to||',floor( months_between ('''||
             to_char(p_per_sel_dt_to, 'DD-MON-YYYY')||''',   pos.date_start )/ '||l_freq||')) or'||
             ' months_between ('''||to_char(p_per_sel_dt_to, 'DD-MON-YYYY')||''',   pos.date_start )/ '||l_freq||
             ' between nvl('||p_year_from||',floor( months_between ('''||to_char(p_per_sel_dt_from, 'DD-MON-YYYY')||''', pos.date_start )/ '|| l_freq||')) and nvl('||p_year_to||',floor( months_between ('''||
             to_char(p_per_sel_dt_to, 'DD-MON-YYYY')||''',   pos.date_start )/ '||l_freq||'))))'
             ;

	END IF; -- p_per_sel_dt_cd

     END IF;

     IF p_concat_segs IS NOT NULL THEN
     -- if a people group is specified, frame the query accordingly
     l_concat_segs_date := p_effective_date;

        OPEN c_delimiter;
        FETCH c_delimiter INTO l_concat_sep;
        CLOSE c_delimiter;
        -- append the common portion of the query
        l_query_str :=
           l_query_str || ' and exists ('||
           ' select 1 from pay_people_groups ppg'||
           ' , per_all_assignments_f paf'||
           ' where paf.people_group_id = ppg.people_group_id'||
           ' and paf.person_id = ppf.person_id'||
           ' and :effective_date between paf.effective_start_date and paf.effective_end_date'||
           ' and   paf.assignment_type <> ''C''' ||
           ' and paf.primary_flag = ''Y''' /*||
           ' and paf.business_group_id = ppf.business_group_id' */
           ;

        FOR l_application_column_name in c_application_column_name
        LOOP
           l_count := l_count + 1;
           l_pos_sep   := instr (p_concat_segs, l_concat_sep, 1, l_count);
	   --
	   if (l_pos_sep = 0) then    -- the search failed (end of string)
	      l_seg_value := rtrim (substr (p_concat_segs, l_pos));
	   else
	      l_length := l_pos_sep - l_pos;
	      l_seg_value := substr (p_concat_segs, l_pos, l_length);
	   end if;
           l_pos := l_pos + l_length + 1;       -- skip on to next segment

           -- if the value entered by the user is null
           -- dont filter by that segment
           -- hence dont add the condition to the query

           IF l_seg_value IS NOT NULL THEN
              l_query_str         :=
                 l_query_str || ' and ppg.'||l_application_column_name.application_column_name||
                 ' = '''||l_seg_value||'''';
           END IF;

        END LOOP;

        l_query_str := l_query_str || ')' ;

     ELSE
        l_concat_segs_date := hr_api.g_sot;

             l_query_str :=
               l_query_str || ' and :effective_date is not null';

     END IF; --   p_concat_segs is not null

--end if;

---

    -- Finish the main query
    l_person_date_bind  := p_effective_date;
    --
    IF p_lmt_prpnip_by_org_flag = 'N' THEN
       --
       l_query_str         :=
          l_query_str || ' and :people_date' || ' between ppf.effective_start_date' ||
            ' and ppf.effective_end_date' ||
            ' and :people_date is not null ' ||
            ' order by ppf.full_name';
       --
    else
       --
       l_query_str         :=
          l_query_str || ' and :people_date' || ' between ppf.effective_start_date' ||
            ' and ppf.effective_end_date' ||
            ' and :people_date between paf1.effective_start_date(+)' ||
            ' and paf1.effective_end_date(+)' ||
            ' order by paf1.organization_id';
       --
    end if;


    --
    -- Open the query using business_group_id as the bind variable.
    --

    /* Uncomment the following lines when you debug the dynamic sql
       text
    for i in 1..60 loop
        hr_utility.set_location(substr(l_query_str, 60*i-59, 60), 1234);
        if (60*i-59 > length(l_query_str)) then
           exit;
        end if;
    end loop;
    */
    OPEN c_person_life FOR l_query_str
      USING p_business_group_id
       ,l_person_date_bind
       ,l_person_id_bind
       ,l_ler_id_bind
       ,l_person_type_id_bind
       ,l_person_type_id_date_bind  -- added for Bug 2224299
       ,l_benfts_grp_id_bind
       ,l_location_id_date_bind
       ,l_location_id_bind
       ,l_cagr_id_date_bind
       ,l_cagr_id_bind
       ,l_person_date_bind
       ,l_person_date_bind-- -- irec
       ,l_assignment_id_bind -- irec
       ,l_person_date_bind-- --irec
       ,l_legal_entity_id_date_bind
       ,l_legal_entity_id_bind
       ,l_payroll_id_date_bind
       ,l_payroll_id_bind
       ,l_payroll_id_date2_bind
       ,l_pstl_zip_rng_id_date_bind
       ,l_pstl_zip_rng_id_date2_bind
       ,l_pstl_zip_rng_id_date3_bind
       ,l_pstl_zip_rng_id_bind
       ,l_pstl_zip_rng_id_date4_bind
       ,l_organization_id_date_bind
       ,l_organization_id_bind
       ,l_organization_id_date2_bind
       ,l_organization_id_date3_bind
       ,l_life_date_bind
       -- 2940151
       ,l_org_heirarchy_date
       ,l_org_heirarchy
       ,l_org_heirarchy
       ,l_org_starting_node_id
       ,l_org_heirarchy
       ,l_org_heirarchy_date
       ,l_org_starting_node_id
       ,l_grade_ladder_bind
       ,l_grade_ladder_date_bind
       ,l_grade_ladder_date2_bind
       ,l_grade_ladder_date3_bind
       ,l_grade_ladder_date4_bind
       ,l_qual_type_bind
       ,l_qual_status_bind
       ,l_rate_id_date_bind
       ,l_rate_id_bind
       ,l_rate_id_date_bind
       , l_concat_segs_date

       -- end 2940151
       ,l_person_date_bind
       ,l_person_date_bind;
-- ------------------------------------------------------------
-- NOTE: for some reason the following FETCH statement fails
--       at runtime with an invalid cursor type error:
--       FETCH c_person_life BULK COLLECT INTO l_person_id_table;
--       To get around this problem, each row is selected
--       individually (how disappointing).
-- ------------------------------------------------------------
    LOOP
      FETCH c_person_life INTO l_person_id_fetch;


      EXIT WHEN c_person_life%NOTFOUND;

      -- Only process if person passed selection rule or there is no rule.
      IF check_selection_rule(p_person_selection_rule_id=> p_person_selection_rule_id
          ,p_person_id                => l_person_id_fetch
          ,p_business_group_id        => p_business_group_id
          ,p_effective_date           => p_effective_date)
	  or p_mode='I'    -- irec
	  THEN
        --
        l_person_id_process(l_person_id_process.COUNT + 1)  :=
                                                            l_person_id_fetch;
      END IF;
    END LOOP;

    CLOSE c_person_life;
    IF l_person_id_process.COUNT > 0 THEN
      -- bulk insert all person action(s)
      FORALL l_count IN l_person_id_process.FIRST .. l_person_id_process.LAST
        INSERT INTO ben_person_actions
                    (
                      person_action_id
                     ,person_id
                     ,ler_id
                     ,benefit_action_id
                     ,action_status_cd
                     ,object_version_number)
             VALUES(
               ben_person_actions_s.nextval
              ,l_person_id_process(l_count)
              ,NULL
              ,p_benefit_action_id
              ,'U'
              ,1)
          RETURNING person_action_id BULK COLLECT INTO l_person_action_id_table;
      --
      IF MOD(l_person_action_id_table.COUNT
          ,p_chunk_size) = 0 THEN
        l_to_chunk_loop  :=
                         TRUNC(l_person_action_id_table.COUNT / p_chunk_size);
      ELSE
        l_to_chunk_loop  :=
                      TRUNC(l_person_action_id_table.COUNT / p_chunk_size) + 1;
      END IF;
      --
      FOR i IN 1 .. l_to_chunk_loop LOOP
        -- set the starting point range
        l_start_person_action_id  :=
                         l_person_action_id_table(((i - 1) * p_chunk_size) + 1);
        IF i <> l_to_chunk_loop THEN
          l_end_person_action_id  :=
                                   l_person_action_id_table(i * p_chunk_size);
        ELSE
          l_end_person_action_id  :=
                     l_person_action_id_table(l_person_action_id_table.COUNT);
        END IF;
        --
        INSERT INTO ben_batch_ranges
                    (
                      range_id
                     ,benefit_action_id
                     ,range_status_cd
                     ,starting_person_action_id
                     ,ending_person_action_id
                     ,object_version_number)
             VALUES(
               ben_batch_ranges_s.nextval
              ,p_benefit_action_id
              ,'U'
              ,l_start_person_action_id
              ,l_end_person_action_id
              ,1);
      --
      END LOOP;
      IF p_commit_data = 'Y' THEN
        -- This is for What IF Functionality
        COMMIT;
      END IF;
    END IF;
    --
    p_num_ranges        := l_to_chunk_loop;
    p_num_persons       := l_person_action_id_table.COUNT;
  --
  END create_life_person_actions;
--
  PROCEDURE create_restart_person_actions(
    p_benefit_action_id IN     NUMBER
   ,p_effective_date    IN     DATE
   ,p_chunk_size        IN     NUMBER
   ,p_threads           IN     NUMBER
   ,p_num_ranges        OUT NOCOPY    NUMBER
   ,p_num_persons       OUT NOCOPY    NUMBER
   ,p_commit_data       IN     VARCHAR2) IS
    --
    CURSOR c_person_actions IS
      SELECT   act.person_action_id, act.person_id, act.benefit_action_id
      FROM     ben_person_actions act
      WHERE    act.action_status_cd = 'E'
      AND      act.benefit_action_id = p_benefit_action_id
      FOR UPDATE;
    --
    CURSOR c_batch_ranges IS
      SELECT   brng.range_id
      FROM     ben_batch_ranges brng
      WHERE    brng.benefit_action_id = p_benefit_action_id
      AND      brng.range_status_cd <> 'U'
      AND      EXISTS (SELECT null
                         FROM ben_person_actions act
                        WHERE      act.person_action_id between brng.starting_person_action_id and brng.ending_person_action_id
                          AND      act.benefit_action_id = brng.benefit_action_id
                          AND      act.action_status_cd <> 'P')
      FOR UPDATE;
    --
    l_package       VARCHAR2(80)      := g_package || '.create_restart_person_actions';
    l_to_chunk_loop          NUMBER                                   := 0;
  --
  BEGIN
    --
    -- hr_utility.set_location('Entering '||l_package,10);
    --
    -- Updating ranges from ben_batch_ranges table
    -- Rolling back ranges with erred or partially unfinished person actions
    --
    update ben_benefit_actions
    set    request_id = fnd_global.conc_request_id
    where  benefit_action_id = p_benefit_action_id;
    --
    for r_batch_ranges in c_batch_ranges loop
       update ben_batch_ranges
          set range_status_cd = 'U'
        where range_id = r_batch_ranges.range_id;
        l_to_chunk_loop:=l_to_chunk_loop+1;
    end loop;
    --
    p_num_ranges   := l_to_chunk_loop;
    --
    -- Updating person actions from ben_person_actions table
    -- Rolling back erred person_actions
    --
    for r_person_actions in c_person_actions loop
       update ben_person_actions
          set action_status_cd = 'U'
        where person_action_id = r_person_actions.person_action_id;
    --
       delete from ben_reporting
       where person_id = r_person_actions.person_id
       and benefit_action_id = r_person_actions.benefit_action_id;
    end loop;
    --
    select count(*)
      into p_num_persons
      from ben_person_actions
     where benefit_action_id = p_benefit_action_id
       and action_status_cd = 'U';
    --
    if p_commit_data = 'Y' then
      -- This is for What IF Functionality
      commit;
    end if;
  --
  -- hr_utility.set_location('Leaving '||l_package,10);
  --
  END create_restart_person_actions;
--
END ben_benbatch_persons;

/
