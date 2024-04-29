--------------------------------------------------------
--  DDL for Package Body BEN_RT_PRFL_CACHE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_RT_PRFL_CACHE" AS
/* $Header: bertprch.pkb 120.0.12000000.2 2007/09/14 09:50:37 rgajula noship $ */
--
/*
+==============================================================================+
|			 Copyright (c) 1997 Oracle Corporation		       |
|			    Redwood Shores, California, USA		       |
|				All rights reserved.			       |
+==============================================================================+
--
History
  Version    Date	Author	   Comments
  ---------  ---------	---------- --------------------------------------------
  115.0      24-Jun-99	bbulusu    Created.
  115.1      01-Jul-99	lmcdonal   added ttl_prtt and ttl_cvg
  115.2      16-Jul-99	lmcdonal   Added set locations for debugging.  Fixed
				   l_inst_query for rules and ttl_cvg.
  115.3      16-Aug-99	stee	   Fixed loa_rsn to use
				   absence_attendance_type_id and
				   abs_attendance_reason_id.
  115.4      27-SEP-99	GPerry	   Added missing no min value flags as these
				   are needed as part of the business rule
				   checks.
  115.5      04-OCT-99	GPerry	   Backport of 115.2 with 115.4 fix.
  115.6      04-OCT-99	GPerry	   Leapfrog of 115.4.
  115.7      06-OCT-99	STee	   Added period of enrollment and disabled
				   criteria.
  115.8      12 Nov 99	tguy	   added los_fctr_id and age/comp id for
				   factors criteria.
  115.9      10 Feb 00	GPerry	   Flad was missing from cache.
				   WWBUG 1189087.
  115.10     11-May-00  dcollins   Performance enhancements, implemented
                                   exception capturing instead of exists clauses
                                   added "in out NOCOPY" to all set procs and
                                   removed extra record assignment statements
  115.11     29-May-00  mhoyes   - Upgraded various get procedures to latest
                                   cache on demand.
  115.13     31-May-00  mhoyes   - Fixed age and los problems.
  115.14     15-Dec-00  Tmathers - Change calls for
                                   ben_hash_utility.write_mastDet_Cache to
                                   call ben_cache.write_mastDet_Cache.
                                   WWBUG 1545633.
  115.15     29-Dec-00  Tmathers - fixed check_sql errors
  115.16     20-Mar-02  vsethi     added dbdrv lines
  115.17     29-Apr-02  pabodla    Bug 1631182 : support user created
                                   person type. Added person_type_id
                                   parameter.
  115.9      05-Jun-02  vsethi     Added code to handle the new rates flags
  115.10     12-Jun-02  vsethi     Added code to handle the quartile and
				   performance rating
  115.11	 10-Sep-02		bmanyam	changed the caching query for scheduled hrs as part of
  												'Range of Scheduled Hrs' Enhancement
  115.21     10-feb-03  hnarayan   Added NOCOPY Changes
  115.22     ll-Apr-03  pbodla     FONM : cache is built using the fonm dates.
  115.23     l7-Apr-03  pbodla     get_eff_date : removed date_to_canonical call
                        kmahendr
  115.24     13-Sep-07  rgajula    Bug 6412287 Additional global tables g_poe_lookup, g_poe_instance cleared in procedure clear_down_cache
  -----------------------------------------------------------------------------
*/
--
-- Globals.
--
  g_package varchar2(50) := 'ben_rt_prfl_cache.';
--
-- ----------------------------------------------------------------------------
-- |-----------------------< get_cached_data >--------------------------------|
-- ----------------------------------------------------------------------------
--
-- This procedure returns data that is already in the cache.
--
-- Parameter Name      Comments
-- --------------      ------------------------------
-- p_vrbl_rt_prfl_id   The variable rate profile id for the fetch.
-- p_lookup_name       The name of type of master cache.
-- p_inst_name	       Name of the type of detail cache.
-- p_inst_set_type     The data type of the detail cache structure.
-- p_out_inst_name     Name of the global to which the anynymous dynamic SQL
--		       block below will write the output data.
--
procedure get_cached_data
  (p_vrbl_rt_prfl_id in number
  ,p_lookup_name     in varchar2
  ,p_inst_name	     in varchar2
  ,p_inst_set_type   in varchar2
  ,p_out_inst_name   in varchar2
  )
is
  l_plsql_str long;
  l_proc varchar2(80) := g_package || '.get_cached_data';

begin
  --
  g_inst_count := 0;
  --
  -- Build the plsql string for dynamic SQL
  --
  l_plsql_str :=
    'DECLARE ' ||
      'l_torrwnum	binary_integer; ' ||
      'l_insttorrw_num	binary_integer; ' ||
      'l_master_hv	binary_integer; ' ||
      'l_hash_found	boolean; ' ||
      'l_entry_exists 	boolean; ' ||
      'l_inst_set ' ||	p_inst_set_type || '; ' ||
    'BEGIN ' ||
       --
       -- Hash the master id
       --
      'l_master_hv := mod(' || to_char(p_vrbl_rt_prfl_id) ||
			  ', ben_hash_utility.get_hash_key);' ||
       --
       -- Check if hashed value is already cached
       --
      'begin ' ||
        --
        -- Poke cache for existence of hash value
        --
        'l_entry_exists := true; ' ||
        'if (' || p_lookup_name || '(l_master_hv).starttorele_num = 0) then ' ||
          'null; ' ||
        'end if; ' ||
        'if (l_entry_exists = true) then ' ||
          --
          -- If it does exist make sure it corresponds to the master id
          --
          'if ' || p_lookup_name || '(l_master_hv).id <> ' ||
            to_char(p_vrbl_rt_prfl_id) || ' then ' ||
            --
            'l_hash_found := FALSE; ' ||
            --
            -- Loop until un-allocated has value is derived
            --
            'while l_hash_found = FALSE loop ' ||
              --
              'l_master_hv := l_master_hv + ben_hash_utility.get_hash_jump; ' ||
              --
              -- Check if the hash index exists, if not we can use it
              --
              'l_entry_exists := true; ' ||
              'if (' || p_lookup_name || '(l_master_hv).starttorele_num = 0) then ' ||
                'null; ' ||
              'end if; ' ||
              'if (l_entry_exists = false) then ' ||
                --
                -- Lets store the hash value in the index
                --
                'l_hash_found := TRUE; ' ||
                'exit;' ||
                --
              'else ' ||
                --
                'l_hash_found := FALSE; ' ||
                --
              'end if; ' ||
              --
            'end loop; ' ||
            --
          'end if; ' ||
          --
        'end if; ' ||
      'exception when NO_DATA_FOUND then ' ||
        'l_entry_exists := false; ' ||
      'end; ' ||
       --
       -- Get the instance details
       --
       -- Populate the detail instances based on the range for the master id
       -- hashed value in the lookup cache i.e. between starttorele_num and
       -- endtorele_num
       --
      'l_torrwnum := 0; ' ||
       --
      'for l_insttorrw_num in ' ||
	   p_lookup_name || '(l_master_hv).starttorele_num .. ' ||
	   p_lookup_name || '(l_master_hv).endtorele_num loop ' ||
	 --
	 p_out_inst_name || '(l_torrwnum) := ' ||
	   p_inst_name || '(l_insttorrw_num); ' ||
	 --
	'l_torrwnum := l_torrwnum + 1; ' ||
	 --
      'end loop; ' ||
       --
      'ben_rt_prfl_cache.g_inst_count := l_torrwnum; ' ||
       --
    'END;';

 EXECUTE IMMEDIATE l_plsql_str;

end get_cached_data;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< get_eff_date >-----------------------------------|
-- ----------------------------------------------------------------------------
--
-- This function returns the date string to use.
--
function get_eff_date
  (p_lf_evt_ocrd_dt in date
  ,p_effective_date in date)
return date
is
  l_todate  date;
begin
  --
  -- FONM
  if ben_manage_life_events.fonm = 'Y' then
     --
     if ben_manage_life_events.g_fonm_rt_strt_dt is not null then
        --
        l_todate := ben_manage_life_events.g_fonm_rt_strt_dt;
        --
     elsif ben_manage_life_events.g_fonm_cvg_strt_dt is not null then
        --
        l_todate := ben_manage_life_events.g_fonm_cvg_strt_dt;
        --
     elsif p_lf_evt_ocrd_dt is not null then
       --
       l_todate := p_lf_evt_ocrd_dt;
       --
     else
       --
       l_todate := p_effective_date ;
       --
     end if;
     --
  else
    if p_lf_evt_ocrd_dt is not null then
       --
       l_todate := p_lf_evt_ocrd_dt;
       --
     else
       --
       l_todate := p_effective_date;
       --
     end if;
  end if;
  --
  return l_todate;
  --
end get_eff_date;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< date_str >-----------------------------------|
-- ----------------------------------------------------------------------------
--
-- This function returns the date string to use.
--
function date_str
  (p_lf_evt_ocrd_dt in date
  ,p_effective_date in date)
return varchar2
is
  l_todate_str varchar2(1000);
begin
  --
  -- FONM
  if ben_manage_life_events.fonm = 'Y' then
     --
     if ben_manage_life_events.g_fonm_rt_strt_dt is not null then
        --
        l_todate_str :=
         ' to_date(''' || fnd_date.date_to_canonical(ben_manage_life_events.g_fonm_rt_strt_dt) ||
                ''', ''' || fnd_date.canonical_dt_mask || ''')';
        --
     elsif ben_manage_life_events.g_fonm_cvg_strt_dt is not null then
        --
        l_todate_str :=
         ' to_date(''' || fnd_date.date_to_canonical(ben_manage_life_events.g_fonm_cvg_strt_dt) ||
                ''', ''' || fnd_date.canonical_dt_mask || ''')';
        --
     elsif p_lf_evt_ocrd_dt is not null then
       --
       l_todate_str :=
         ' to_date(''' || fnd_date.date_to_canonical(p_lf_evt_ocrd_dt) ||
                ''', ''' || fnd_date.canonical_dt_mask || ''')';
       --
     else
       --
       l_todate_str :=
         ' to_date(''' || fnd_date.date_to_canonical(p_effective_date) ||
                ''', ''' || fnd_date.canonical_dt_mask || ''')';

     end if;
     --
  else
    if p_lf_evt_ocrd_dt is not null then
       --
       l_todate_str :=
         ' to_date(''' || fnd_date.date_to_canonical(p_lf_evt_ocrd_dt) ||
		''', ''' || fnd_date.canonical_dt_mask || ''')';
       --
     else
       --
       l_todate_str :=
         ' to_date(''' || fnd_date.date_to_canonical(p_effective_date) ||
		''', ''' || fnd_date.canonical_dt_mask || ''')';
       --
     end if;
  end if;
  --
  return l_todate_str;
  --
end date_str;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< get_rt_prfl_cache >------------------------------|
-- ----------------------------------------------------------------------------
--
-- Following are overloaded procedures that get the appropriate caches.
--
-- PEOPLE GROUP
--
procedure get_rt_prfl_cache
  (p_vrbl_rt_prfl_id   in number
  ,p_effective_date    in date
  ,p_lf_evt_ocrd_dt    in date
  ,p_business_group_id in number
  ,p_inst_set	       in out NOCOPY ben_rt_prfl_cache.g_pg_inst_tbl
  ,p_inst_count        out nocopy number)
is
  --
  l_proc varchar2(80) := g_package || '.get_rt_prfl_cache people group';
  l_lookup_query long;
  l_inst_query	 long;
  l_instcolnm_set ben_cache.instcolnmtype;
  --
begin
  --
  g_pg_out.delete;
  --
  if g_pg_lookup.count = 0 then
    --
    -- Cache not populated yet. So populate it now.
    --
    l_lookup_query :=
      'select vrbl_rt_prfl_id, business_group_id'			      ||
       ' from ben_vrbl_rt_prfl_f vpf'					      ||
      ' where business_group_id = ' || to_char(p_business_group_id)	      ||
	' and exists (select null'					      ||
		      ' from ben_ppl_grp_rt_f pgr'			      ||
		     ' where pgr.vrbl_rt_prfl_id = vpf.vrbl_rt_prfl_id'       ||
		       ' and ' || date_str(p_lf_evt_ocrd_dt,p_effective_date) ||
			     ' between pgr.effective_start_date'	      ||
				 ' and pgr.effective_end_date) '	      ||
	' and ' || date_str(p_lf_evt_ocrd_dt, p_effective_date) 	      ||
	      ' between vpf.effective_start_date and vpf.effective_end_date;';
    --
    l_inst_query :=
      'select pgr.vrbl_rt_prfl_id, pgr.people_group_id, pgr.excld_flag ,'           ||
      ' ppg.segment1 ,ppg.segment2 ,ppg.segment3 ,ppg.segment4 ,ppg.segment5 ,'     ||
      ' ppg.segment6 ,ppg.segment7 ,ppg.segment8 ,ppg.segment9, ppg.segment10 ,ppg.segment11 ,'    ||
      ' ppg.segment12 ,ppg.segment13 ,ppg.segment14 ,ppg.segment15 ,ppg.segment16 ,'||
      ' ppg.segment17 ,ppg.segment18 ,ppg.segment19 ,ppg.segment20 ,ppg.segment21 ,'||
      ' ppg.segment22 ,ppg.segment23 ,ppg.segment24 ,ppg.segment25 ,ppg.segment26 ,'||
      ' ppg.segment27 ,ppg.segment28 ,ppg.segment29 ,ppg.segment30 '                ||
      ' from ben_ppl_grp_rt_f pgr , pay_people_groups ppg '		            ||
      ' where pgr.business_group_id = ' || to_char(p_business_group_id)             ||
      ' and   pgr.people_group_id = ppg.people_group_id '                           ||
      ' and ' || date_str(p_lf_evt_ocrd_dt, p_effective_date) 	                    ||
	      ' between pgr.effective_start_date'		   	            ||
		  ' and pgr.effective_end_date' 			            ||
      ' order by pgr.vrbl_rt_prfl_id;';
    --
    l_instcolnm_set(0).col_name    := 'vrbl_rt_prfl_id';
    l_instcolnm_set(0).caccol_name := 'id';
    l_instcolnm_set(1).col_name    := 'people_group_id';
    l_instcolnm_set(1).caccol_name := 'people_group_id';
    l_instcolnm_set(2).col_name    := 'excld_flag';
    l_instcolnm_set(2).caccol_name := 'excld_flag';
    l_instcolnm_set(3).col_name    := 'SEGMENT1';
    l_instcolnm_set(3).caccol_name := 'SEGMENT1';
    l_instcolnm_set(4).col_name    := 'SEGMENT2';
    l_instcolnm_set(4).caccol_name := 'SEGMENT2';

    l_instcolnm_set(5).col_name    := 'SEGMENT3';
    l_instcolnm_set(5).caccol_name := 'SEGMENT3';
    l_instcolnm_set(6).col_name    := 'SEGMENT4';
    l_instcolnm_set(6).caccol_name := 'SEGMENT4';
    l_instcolnm_set(7).col_name    := 'SEGMENT5';
    l_instcolnm_set(7).caccol_name := 'SEGMENT5';
    l_instcolnm_set(8).col_name    := 'SEGMENT6';
    l_instcolnm_set(8).caccol_name := 'SEGMENT6';
    l_instcolnm_set(9).col_name    := 'SEGMENT7';
    l_instcolnm_set(9).caccol_name := 'SEGMENT7';

    l_instcolnm_set(10).col_name    := 'SEGMENT8';
    l_instcolnm_set(10).caccol_name := 'SEGMENT8';
    l_instcolnm_set(11).col_name    := 'SEGMENT9';
    l_instcolnm_set(11).caccol_name := 'SEGMENT9';
    l_instcolnm_set(12).col_name    := 'SEGMENT10';
    l_instcolnm_set(12).caccol_name := 'SEGMENT10';
    l_instcolnm_set(13).col_name    := 'SEGMENT11';
    l_instcolnm_set(13).caccol_name := 'SEGMENT11';
    l_instcolnm_set(14).col_name    := 'SEGMENT12';
    l_instcolnm_set(14).caccol_name := 'SEGMENT12';
    l_instcolnm_set(15).col_name    := 'SEGMENT13';
    l_instcolnm_set(15).caccol_name := 'SEGMENT13';

    l_instcolnm_set(16).caccol_name := 'SEGMENT14';
    l_instcolnm_set(16).col_name    := 'SEGMENT14';

    l_instcolnm_set(17).caccol_name := 'SEGMENT15';
    l_instcolnm_set(17).col_name    := 'SEGMENT15';

    l_instcolnm_set(18).caccol_name := 'SEGMENT16';
    l_instcolnm_set(18).col_name    := 'SEGMENT16';

    l_instcolnm_set(19).caccol_name := 'SEGMENT17';
    l_instcolnm_set(19).col_name    := 'SEGMENT17';

    l_instcolnm_set(20).caccol_name := 'SEGMENT18';
    l_instcolnm_set(20).col_name    := 'SEGMENT18';

    l_instcolnm_set(21).caccol_name := 'SEGMENT19';
    l_instcolnm_set(21).col_name    := 'SEGMENT19';

    l_instcolnm_set(22).caccol_name := 'SEGMENT20';
    l_instcolnm_set(22).col_name    := 'SEGMENT20';

    l_instcolnm_set(23).caccol_name := 'SEGMENT21';
    l_instcolnm_set(23).col_name    := 'SEGMENT21';

    l_instcolnm_set(24).caccol_name := 'SEGMENT22';
    l_instcolnm_set(24).col_name    := 'SEGMENT22';

    l_instcolnm_set(25).caccol_name := 'SEGMENT23';
    l_instcolnm_set(25).col_name    := 'SEGMENT23';

    l_instcolnm_set(26).caccol_name := 'SEGMENT24';
    l_instcolnm_set(26).col_name    := 'SEGMENT24';

    l_instcolnm_set(27).caccol_name := 'SEGMENT25';
    l_instcolnm_set(27).col_name    := 'SEGMENT25';

    l_instcolnm_set(28).caccol_name := 'SEGMENT26';
    l_instcolnm_set(28).col_name    := 'SEGMENT26';

    l_instcolnm_set(29).caccol_name := 'SEGMENT27';
    l_instcolnm_set(29).col_name    := 'SEGMENT27';

    l_instcolnm_set(30).caccol_name := 'SEGMENT28';
    l_instcolnm_set(30).col_name    := 'SEGMENT28';

    l_instcolnm_set(31).caccol_name := 'SEGMENT29';
    l_instcolnm_set(31).col_name    := 'SEGMENT29';

    l_instcolnm_set(32).caccol_name := 'SEGMENT30';
    l_instcolnm_set(32).col_name    := 'SEGMENT30';

    --
    ben_cache.write_mastDet_Cache
      (p_mastercol_name => 'vrbl_rt_prfl_id'
      ,p_detailcol_name => 'vrbl_rt_prfl_id'
      ,p_lkup_name	=> 'ben_rt_prfl_cache.g_pg_lookup'
      ,p_inst_name	=> 'ben_rt_prfl_cache.g_pg_instance'
      ,p_lkup_query	=> l_lookup_query
      ,p_inst_query	=> l_inst_query
      ,p_instcolnm_set	=> l_instcolnm_set
      );
    --
  end if;
  --
  -- Cache already populated. Get record set.
  --
  get_cached_data
    (p_vrbl_rt_prfl_id => p_vrbl_rt_prfl_id
    ,p_lookup_name     => 'ben_rt_prfl_cache.g_pg_lookup'
    ,p_inst_name       => 'ben_rt_prfl_cache.g_pg_instance'
    ,p_inst_set_type   => 'ben_rt_prfl_cache.g_pg_inst_tbl'
    ,p_out_inst_name   => 'ben_rt_prfl_cache.g_pg_out'
    );
  --
  p_inst_set := g_pg_out;
  p_inst_count := g_inst_count;
  --
exception
  --
  when no_data_found then
    --
    p_inst_count := 0;
    hr_utility.set_location('No Person Groups found', 90);
    hr_utility.set_location('Leaving : ' || l_proc, 99);
    --
end;
--
/*procedure get_rt_prfl_cache
  (p_vrbl_rt_prfl_id   in number
  ,p_effective_date    in date
  ,p_lf_evt_ocrd_dt    in date
  ,p_business_group_id in number
  ,p_inst_set	       in out NOCOPY ben_rt_prfl_cache.g_pg_inst_tbl
  ,p_inst_count        out nocopy number)
is
  --
  l_proc varchar2(80) := g_package || '.get_rt_prfl_cache people group';
  l_lookup_query long;
  l_inst_query	 long;
  l_instcolnm_set ben_cache.instcolnmtype;
  --
begin
  --
  g_pg_out.delete;
  --
  if g_pg_lookup.count = 0 then
    --
    -- Cache not populated yet. So populate it now.
    --
    l_lookup_query :=
      'select vrbl_rt_prfl_id, business_group_id'			      ||
       ' from ben_vrbl_rt_prfl_f vpf'					      ||
      ' where business_group_id = ' || to_char(p_business_group_id)	      ||
	' and exists (select null'					      ||
		      ' from ben_ppl_grp_rt_f pgr'			      ||
		     ' where pgr.vrbl_rt_prfl_id = vpf.vrbl_rt_prfl_id'       ||
		       ' and ' || date_str(p_lf_evt_ocrd_dt,p_effective_date) ||
			     ' between pgr.effective_start_date'	      ||
				 ' and pgr.effective_end_date) '	      ||
	' and ' || date_str(p_lf_evt_ocrd_dt, p_effective_date) 	      ||
	      ' between vpf.effective_start_date and vpf.effective_end_date;';
    --
    l_inst_query :=
      'select pgr.vrbl_rt_prfl_id, pgr.people_group_id, pgr.excld_flag'    ||
       ' from ben_ppl_grp_rt_f pgr '					   ||
      ' where pgr.business_group_id = ' || to_char(p_business_group_id)    ||
	' and ' || date_str(p_lf_evt_ocrd_dt, p_effective_date) 	   ||
	      ' between pgr.effective_start_date'			   ||
		  ' and pgr.effective_end_date' 			   ||
      ' order by pgr.vrbl_rt_prfl_id;';
    --
    l_instcolnm_set(0).col_name    := 'vrbl_rt_prfl_id';
    l_instcolnm_set(0).caccol_name := 'id';
    l_instcolnm_set(1).col_name    := 'people_group_id';
    l_instcolnm_set(1).caccol_name := 'people_group_id';
    l_instcolnm_set(2).col_name    := 'excld_flag';
    l_instcolnm_set(2).caccol_name := 'excld_flag';
    --
    ben_cache.write_mastDet_Cache
      (p_mastercol_name => 'vrbl_rt_prfl_id'
      ,p_detailcol_name => 'vrbl_rt_prfl_id'
      ,p_lkup_name	=> 'ben_rt_prfl_cache.g_pg_lookup'
      ,p_inst_name	=> 'ben_rt_prfl_cache.g_pg_instance'
      ,p_lkup_query	=> l_lookup_query
      ,p_inst_query	=> l_inst_query
      ,p_instcolnm_set	=> l_instcolnm_set
      );
    --
  end if;
  --
  -- Cache already populated. Get record set.
  --
  get_cached_data
    (p_vrbl_rt_prfl_id => p_vrbl_rt_prfl_id
    ,p_lookup_name     => 'ben_rt_prfl_cache.g_pg_lookup'
    ,p_inst_name       => 'ben_rt_prfl_cache.g_pg_instance'
    ,p_inst_set_type   => 'ben_rt_prfl_cache.g_pg_inst_tbl'
    ,p_out_inst_name   => 'ben_rt_prfl_cache.g_pg_out'
    );
  --
  p_inst_set := g_pg_out;
  p_inst_count := g_inst_count;
  --
exception
  --
  when no_data_found then
    --
    p_inst_count := 0;
    hr_utility.set_location('No Person Groups found', 90);
    hr_utility.set_location('Leaving : ' || l_proc, 99);
    --
end;
*/
--
-- RULES
--
procedure get_rt_prfl_cache
  (p_vrbl_rt_prfl_id   in number
  ,p_effective_date    in date
  ,p_lf_evt_ocrd_dt    in date
  ,p_business_group_id in number
  ,p_inst_set	       in out NOCOPY ben_rt_prfl_cache.g_rl_inst_tbl
  ,p_inst_count        out nocopy number)
is
  --
  l_proc varchar2(80) := g_package || '.get_rt_prfl_cache RULES';
  l_lookup_query long;
  l_inst_query	 long;
  l_instcolnm_set ben_cache.instcolnmtype;
  --
begin
  g_rl_out.delete;
  --
  if g_rl_lookup.count = 0 then
    --
    -- Cache not populated yet. So populate it now.
    --
    l_lookup_query :=
      'select vrbl_rt_prfl_id, business_group_id'			      ||
       ' from ben_vrbl_rt_prfl_f vpf'					      ||
      ' where business_group_id = ' || to_char(p_business_group_id)	      ||
	' and exists (select null'					      ||
		      ' from ben_vrbl_rt_prfl_rl_f rpr' 		      ||
		     ' where rpr.vrbl_rt_prfl_id = vpf.vrbl_rt_prfl_id'       ||
		       ' and ' || date_str(p_lf_evt_ocrd_dt,p_effective_date) ||
			     ' between rpr.effective_start_date'	      ||
				 ' and rpr.effective_end_date) '	      ||
	' and ' || date_str(p_lf_evt_ocrd_dt, p_effective_date) 	      ||
	      ' between vpf.effective_start_date and vpf.effective_end_date;';
    --
    l_inst_query :=
      'select rpr.vrbl_rt_prfl_id, rpr.formula_id'			   ||
       ' from ben_vrbl_rt_prfl_rl_f rpr'				   ||
      ' where rpr.business_group_id = ' || to_char(p_business_group_id)    ||
	' and ' || date_str(p_lf_evt_ocrd_dt, p_effective_date) 	   ||
	      ' between rpr.effective_start_date'			   ||
		  ' and rpr.effective_end_date' 			   ||
      ' order by rpr.vrbl_rt_prfl_id;';
    l_instcolnm_set(0).col_name    := 'vrbl_rt_prfl_id';
    l_instcolnm_set(0).caccol_name := 'id';
    l_instcolnm_set(1).col_name    := 'formula_id';
    l_instcolnm_set(1).caccol_name := 'formula_id';
    ben_cache.write_mastDet_Cache
      (p_mastercol_name => 'vrbl_rt_prfl_id'
      ,p_detailcol_name => 'vrbl_rt_prfl_id'
      ,p_lkup_name	=> 'ben_rt_prfl_cache.g_rl_lookup'
      ,p_inst_name	=> 'ben_rt_prfl_cache.g_rl_instance'
      ,p_lkup_query	=> l_lookup_query
      ,p_inst_query	=> l_inst_query
      ,p_instcolnm_set	=> l_instcolnm_set
      );
  end if;
  --
  -- Cache already populated. Get record set.
  --
  get_cached_data
    (p_vrbl_rt_prfl_id => p_vrbl_rt_prfl_id
    ,p_lookup_name     => 'ben_rt_prfl_cache.g_rl_lookup'
    ,p_inst_name       => 'ben_rt_prfl_cache.g_rl_instance'
    ,p_inst_set_type   => 'ben_rt_prfl_cache.g_rl_inst_tbl'
    ,p_out_inst_name   => 'ben_rt_prfl_cache.g_rl_out'
    );
  --
  p_inst_set := g_rl_out;
  p_inst_count := g_inst_count;
exception
  --
  when no_data_found then
    --
    p_inst_count := 0;
    hr_utility.set_location('No Rules found', 90);
    hr_utility.set_location('Leaving : ' || l_proc, 99);
    --
end;
--
-- TOBACCO
--
procedure get_rt_prfl_cache
  (p_vrbl_rt_prfl_id   in number
  ,p_effective_date    in date
  ,p_lf_evt_ocrd_dt    in date
  ,p_business_group_id in number
  ,p_inst_set	       in out NOCOPY ben_rt_prfl_cache.g_tbco_inst_tbl
  ,p_inst_count        out nocopy number)
is
  --
  l_proc varchar2(80) := g_package || '.get_rt_prfl_cache';
  l_lookup_query long;
  l_inst_query	 long;
  l_instcolnm_set ben_cache.instcolnmtype;
  --
begin
  --
  g_tbco_out.delete;
  --
  if g_tbco_lookup.count = 0 then
    --
    -- Cache not populated yet. So populate it now.
    --
    l_lookup_query :=
      'select vrbl_rt_prfl_id, business_group_id'			      ||
       ' from ben_vrbl_rt_prfl_f vpf'					      ||
      ' where business_group_id = ' || to_char(p_business_group_id)	      ||
	' and exists (select null'					      ||
		      ' from ben_tbco_use_rt_f btu'			      ||
		     ' where btu.vrbl_rt_prfl_id = vpf.vrbl_rt_prfl_id'       ||
		       ' and ' || date_str(p_lf_evt_ocrd_dt,p_effective_date) ||
			     ' between btu.effective_start_date'	      ||
				 ' and btu.effective_end_date) '	      ||
	' and ' || date_str(p_lf_evt_ocrd_dt, p_effective_date) 	      ||
	      ' between vpf.effective_start_date and vpf.effective_end_date;';
    --
    l_inst_query :=
      'select btu.vrbl_rt_prfl_id, btu.uses_tbco_flag, btu.excld_flag'	   ||
       ' from ben_tbco_use_rt_f btu'					   ||
      ' where btu.business_group_id = ' || to_char(p_business_group_id)    ||
	' and ' || date_str(p_lf_evt_ocrd_dt, p_effective_date) 	   ||
	      ' between btu.effective_start_date'			   ||
		  ' and btu.effective_end_date' 			   ||
      ' order by btu.vrbl_rt_prfl_id;';
    --
    l_instcolnm_set(0).col_name    := 'vrbl_rt_prfl_id';
    l_instcolnm_set(0).caccol_name := 'id';
    l_instcolnm_set(1).col_name    := 'uses_tbco_flag';
    l_instcolnm_set(1).caccol_name := 'uses_tbco_flag';
    l_instcolnm_set(2).col_name    := 'excld_flag';
    l_instcolnm_set(2).caccol_name := 'excld_flag';
    --
    ben_cache.write_mastDet_Cache
      (p_mastercol_name => 'vrbl_rt_prfl_id'
      ,p_detailcol_name => 'vrbl_rt_prfl_id'
      ,p_lkup_name	=> 'ben_rt_prfl_cache.g_tbco_lookup'
      ,p_inst_name	=> 'ben_rt_prfl_cache.g_tbco_instance'
      ,p_lkup_query	=> l_lookup_query
      ,p_inst_query	=> l_inst_query
      ,p_instcolnm_set	=> l_instcolnm_set
      );
    --
  end if;
  --
  -- Cache already populated. Get record set.
  --
  get_cached_data
    (p_vrbl_rt_prfl_id => p_vrbl_rt_prfl_id
    ,p_lookup_name     => 'ben_rt_prfl_cache.g_tbco_lookup'
    ,p_inst_name       => 'ben_rt_prfl_cache.g_tbco_instance'
    ,p_inst_set_type   => 'ben_rt_prfl_cache.g_tbco_inst_tbl'
    ,p_out_inst_name   => 'ben_rt_prfl_cache.g_tbco_out'
    );
  --
  p_inst_set := g_tbco_out;
  p_inst_count := g_inst_count;
  --
exception
  --
  when no_data_found then
    --
    p_inst_count := 0;
    hr_utility.set_location('No Tobacco Data found', 90);
    hr_utility.set_location('Leaving : ' || l_proc, 99);
    --
end;
--
-- GENDER
--
procedure get_rt_prfl_cache
  (p_vrbl_rt_prfl_id   in number
  ,p_effective_date    in date
  ,p_lf_evt_ocrd_dt    in date
  ,p_business_group_id in number
  ,p_inst_set	       in out NOCOPY ben_rt_prfl_cache.g_gndr_inst_tbl
  ,p_inst_count        out nocopy number)
is
  --
  l_proc varchar2(80) := g_package || '.get_rt_prfl_cache';
  l_lookup_query long;
  l_inst_query	 long;
  l_instcolnm_set ben_cache.instcolnmtype;
  --
begin
  --
  g_gndr_out.delete;
  --
  if g_gndr_lookup.count = 0 then
    --
    -- Cache not populated yet. So populate it now.
    --
    l_lookup_query :=
      'select vrbl_rt_prfl_id, business_group_id'			      ||
       ' from ben_vrbl_rt_prfl_f vpf'					      ||
      ' where business_group_id = ' || to_char(p_business_group_id)	      ||
	' and exists (select null'					      ||
		      ' from ben_gndr_rt_f bgr' 			      ||
		     ' where bgr.vrbl_rt_prfl_id = vpf.vrbl_rt_prfl_id'       ||
		       ' and ' || date_str(p_lf_evt_ocrd_dt,p_effective_date) ||
			     ' between bgr.effective_start_date'	      ||
				 ' and bgr.effective_end_date) '	      ||
	' and ' || date_str(p_lf_evt_ocrd_dt, p_effective_date) 	      ||
	      ' between vpf.effective_start_date and vpf.effective_end_date;';
    --
    l_inst_query :=
      'select bgr.vrbl_rt_prfl_id, bgr.gndr_cd, bgr.excld_flag' 	   ||
       ' from ben_gndr_rt_f bgr'					   ||
      ' where bgr.business_group_id = ' || to_char(p_business_group_id)    ||
	' and ' || date_str(p_lf_evt_ocrd_dt, p_effective_date) 	   ||
	      ' between bgr.effective_start_date'			   ||
		  ' and bgr.effective_end_date' 			   ||
      ' order by bgr.vrbl_rt_prfl_id;';
    --
    l_instcolnm_set(0).col_name    := 'vrbl_rt_prfl_id';
    l_instcolnm_set(0).caccol_name := 'id';
    l_instcolnm_set(1).col_name    := 'gndr_cd';
    l_instcolnm_set(1).caccol_name := 'gndr_cd';
    l_instcolnm_set(2).col_name    := 'excld_flag';
    l_instcolnm_set(2).caccol_name := 'excld_flag';
    --
    ben_cache.write_mastDet_Cache
      (p_mastercol_name => 'vrbl_rt_prfl_id'
      ,p_detailcol_name => 'vrbl_rt_prfl_id'
      ,p_lkup_name	=> 'ben_rt_prfl_cache.g_gndr_lookup'
      ,p_inst_name	=> 'ben_rt_prfl_cache.g_gndr_instance'
      ,p_lkup_query	=> l_lookup_query
      ,p_inst_query	=> l_inst_query
      ,p_instcolnm_set	=> l_instcolnm_set
      );
    --
  end if;
  --
  -- Cache already populated. Get record set.
  --
  get_cached_data
    (p_vrbl_rt_prfl_id => p_vrbl_rt_prfl_id
    ,p_lookup_name     => 'ben_rt_prfl_cache.g_gndr_lookup'
    ,p_inst_name       => 'ben_rt_prfl_cache.g_gndr_instance'
    ,p_inst_set_type   => 'ben_rt_prfl_cache.g_gndr_inst_tbl'
    ,p_out_inst_name   => 'ben_rt_prfl_cache.g_gndr_out'
    );
  --
  p_inst_set := g_gndr_out;
  p_inst_count := g_inst_count;
  --
exception
  --
  when no_data_found then
    --
    p_inst_count := 0;
    hr_utility.set_location('No Genders found', 90);
    hr_utility.set_location('Leaving : ' || l_proc, 99);
    --
end;
--
-- Disabled
--
procedure get_rt_prfl_cache
  (p_vrbl_rt_prfl_id   in number
  ,p_effective_date    in date
  ,p_lf_evt_ocrd_dt    in date
  ,p_business_group_id in number
  ,p_inst_set	       in out NOCOPY ben_rt_prfl_cache.g_dsbld_inst_tbl
  ,p_inst_count        out nocopy number)
is
  --
  l_proc varchar2(80) := g_package || '.get_rt_prfl_cache';
  l_lookup_query long;
  l_inst_query	 long;
  l_instcolnm_set ben_cache.instcolnmtype;
  --
begin
  --
  g_dsbld_out.delete;
  --
  if g_dsbld_lookup.count = 0 then
    --
    -- Cache not populated yet. So populate it now.
    --
    l_lookup_query :=
      'select vrbl_rt_prfl_id, business_group_id'			      ||
       ' from ben_vrbl_rt_prfl_f vpf'					      ||
      ' where business_group_id = ' || to_char(p_business_group_id)	      ||
	' and exists (select null'					      ||
		      ' from ben_dsbld_rt_f dbr'			      ||
		     ' where dbr.vrbl_rt_prfl_id = vpf.vrbl_rt_prfl_id'       ||
		       ' and ' || date_str(p_lf_evt_ocrd_dt,p_effective_date) ||
			     ' between dbr.effective_start_date'	      ||
				 ' and dbr.effective_end_date) '	      ||
	' and ' || date_str(p_lf_evt_ocrd_dt, p_effective_date) 	      ||
	      ' between vpf.effective_start_date and vpf.effective_end_date;';
    --
    l_inst_query :=
      'select dbr.vrbl_rt_prfl_id, dbr.dsbld_cd, dbr.excld_flag'	    ||
       ' from ben_dsbld_rt_f dbr'					    ||
      ' where dbr.business_group_id = ' || to_char(p_business_group_id)    ||
	' and ' || date_str(p_lf_evt_ocrd_dt, p_effective_date) 	   ||
	      ' between dbr.effective_start_date'			   ||
		  ' and dbr.effective_end_date' 			   ||
      ' order by dbr.vrbl_rt_prfl_id;';
    --
    l_instcolnm_set(0).col_name    := 'vrbl_rt_prfl_id';
    l_instcolnm_set(0).caccol_name := 'id';
    l_instcolnm_set(1).col_name    := 'dsbld_cd';
    l_instcolnm_set(1).caccol_name := 'dsbld_cd';
    l_instcolnm_set(2).col_name    := 'excld_flag';
    l_instcolnm_set(2).caccol_name := 'excld_flag';
    --
    ben_cache.write_mastDet_Cache
      (p_mastercol_name => 'vrbl_rt_prfl_id'
      ,p_detailcol_name => 'vrbl_rt_prfl_id'
      ,p_lkup_name	=> 'ben_rt_prfl_cache.g_dsbld_lookup'
      ,p_inst_name	=> 'ben_rt_prfl_cache.g_dsbld_instance'
      ,p_lkup_query	=> l_lookup_query
      ,p_inst_query	=> l_inst_query
      ,p_instcolnm_set	=> l_instcolnm_set
      );
    --
  end if;
  --
  -- Cache already populated. Get record set.
  --
  get_cached_data
    (p_vrbl_rt_prfl_id => p_vrbl_rt_prfl_id
    ,p_lookup_name     => 'ben_rt_prfl_cache.g_dsbld_lookup'
    ,p_inst_name       => 'ben_rt_prfl_cache.g_dsbld_instance'
    ,p_inst_set_type   => 'ben_rt_prfl_cache.g_dsbld_inst_tbl'
    ,p_out_inst_name   => 'ben_rt_prfl_cache.g_dsbld_out'
    );
  --
  p_inst_set := g_dsbld_out;
  p_inst_count := g_inst_count;
  --
exception
  --
  when no_data_found then
    --
    p_inst_count := 0;
    hr_utility.set_location('No Disabled Code found', 90);
    hr_utility.set_location('Leaving : ' || l_proc, 99);
    --
end;
--
-- BARGAINING UNIT
--
procedure get_rt_prfl_cache
  (p_vrbl_rt_prfl_id   in number
  ,p_effective_date    in date
  ,p_lf_evt_ocrd_dt    in date
  ,p_business_group_id in number
  ,p_inst_set	       in out NOCOPY ben_rt_prfl_cache.g_brgng_inst_tbl
  ,p_inst_count        out nocopy number)
is
  --
  l_proc varchar2(80) := g_package || '.get_rt_prfl_cache';
  l_lookup_query long;
  l_inst_query	 long;
  l_instcolnm_set ben_cache.instcolnmtype;
  --
begin
  --
  g_brgng_out.delete;
  --
  if g_brgng_lookup.count = 0 then
    --
    -- Cache not populated yet. So populate it now.
    --
    l_lookup_query :=
      'select vrbl_rt_prfl_id, business_group_id'			      ||
       ' from ben_vrbl_rt_prfl_f vpf'					      ||
      ' where business_group_id = ' || to_char(p_business_group_id)	      ||
	' and exists (select null'					      ||
		      ' from ben_brgng_unit_rt_f ebu'			      ||
		     ' where ebu.vrbl_rt_prfl_id = vpf.vrbl_rt_prfl_id'       ||
		       ' and ' || date_str(p_lf_evt_ocrd_dt,p_effective_date) ||
			     ' between ebu.effective_start_date'	      ||
				 ' and ebu.effective_end_date) '	      ||
	' and ' || date_str(p_lf_evt_ocrd_dt, p_effective_date) 	      ||
	      ' between vpf.effective_start_date and vpf.effective_end_date;';
    --
    l_inst_query :=
      'select ebu.vrbl_rt_prfl_id, ebu.brgng_unit_cd, ebu.excld_flag'	   ||
       ' from ben_brgng_unit_rt_f ebu'					   ||
      ' where ebu.business_group_id = ' || to_char(p_business_group_id)    ||
	' and ' || date_str(p_lf_evt_ocrd_dt, p_effective_date) 	   ||
	      ' between ebu.effective_start_date'			   ||
		  ' and ebu.effective_end_date' 			   ||
      ' order by ebu.vrbl_rt_prfl_id;';
    --
    l_instcolnm_set(0).col_name    := 'vrbl_rt_prfl_id';
    l_instcolnm_set(0).caccol_name := 'id';
    l_instcolnm_set(1).col_name    := 'brgng_unit_cd';
    l_instcolnm_set(1).caccol_name := 'brgng_unit_cd';
    l_instcolnm_set(2).col_name    := 'excld_flag';
    l_instcolnm_set(2).caccol_name := 'excld_flag';
    --
    ben_cache.write_mastDet_Cache
      (p_mastercol_name => 'vrbl_rt_prfl_id'
      ,p_detailcol_name => 'vrbl_rt_prfl_id'
      ,p_lkup_name	=> 'ben_rt_prfl_cache.g_brgng_lookup'
      ,p_inst_name	=> 'ben_rt_prfl_cache.g_brgng_instance'
      ,p_lkup_query	=> l_lookup_query
      ,p_inst_query	=> l_inst_query
      ,p_instcolnm_set	=> l_instcolnm_set
      );
    --
  end if;
  --
  -- Cache already populated. Get record set.
  --
  get_cached_data
    (p_vrbl_rt_prfl_id => p_vrbl_rt_prfl_id
    ,p_lookup_name     => 'ben_rt_prfl_cache.g_brgng_lookup'
    ,p_inst_name       => 'ben_rt_prfl_cache.g_brgng_instance'
    ,p_inst_set_type   => 'ben_rt_prfl_cache.g_brgng_inst_tbl'
    ,p_out_inst_name   => 'ben_rt_prfl_cache.g_brgng_out'
    );
  --
  p_inst_set := g_brgng_out;
  p_inst_count := g_inst_count;
  --
exception
  --
  when no_data_found then
    --
    p_inst_count := 0;
    hr_utility.set_location('No Bargining found', 90);
    hr_utility.set_location('Leaving : ' || l_proc, 99);
    --
end;
--
-- BENEFITS GROUP
--
procedure get_rt_prfl_cache
  (p_vrbl_rt_prfl_id   in number
  ,p_effective_date    in date
  ,p_lf_evt_ocrd_dt    in date
  ,p_business_group_id in number
  ,p_inst_set	       in out NOCOPY ben_rt_prfl_cache.g_bnfgrp_inst_tbl
  ,p_inst_count        out nocopy number)
is
  --
  l_proc varchar2(80) := g_package || '.get_rt_prfl_cache';
  l_lookup_query long;
  l_inst_query	 long;
  l_instcolnm_set ben_cache.instcolnmtype;
  --
begin
  --
  g_bnfgrp_out.delete;
  --
  if g_bnfgrp_lookup.count = 0 then
    --
    -- Cache not populated yet. So populate it now.
    --
    l_lookup_query :=
      'select vrbl_rt_prfl_id, business_group_id'			      ||
       ' from ben_vrbl_rt_prfl_f vpf'					      ||
      ' where business_group_id = ' || to_char(p_business_group_id)	      ||
	' and exists (select null'					      ||
		      ' from ben_benfts_grp_rt_f bgr'			      ||
		     ' where bgr.vrbl_rt_prfl_id = vpf.vrbl_rt_prfl_id'       ||
		       ' and ' || date_str(p_lf_evt_ocrd_dt,p_effective_date) ||
			     ' between bgr.effective_start_date'	      ||
				 ' and bgr.effective_end_date) '	      ||
	' and ' || date_str(p_lf_evt_ocrd_dt, p_effective_date) 	      ||
	      ' between vpf.effective_start_date and vpf.effective_end_date;';
    --
    l_inst_query :=
      'select bgr.vrbl_rt_prfl_id, bgr.benfts_grp_id, bgr.excld_flag'	   ||
       ' from ben_benfts_grp_rt_f bgr'					   ||
      ' where bgr.business_group_id = ' || to_char(p_business_group_id)    ||
	' and ' || date_str(p_lf_evt_ocrd_dt, p_effective_date) 	   ||
	      ' between bgr.effective_start_date'			   ||
		  ' and bgr.effective_end_date' 			   ||
      ' order by bgr.vrbl_rt_prfl_id;';
    --
    l_instcolnm_set(0).col_name    := 'vrbl_rt_prfl_id';
    l_instcolnm_set(0).caccol_name := 'id';
    l_instcolnm_set(1).col_name    := 'benfts_grp_id';
    l_instcolnm_set(1).caccol_name := 'benfts_grp_id';
    l_instcolnm_set(2).col_name    := 'excld_flag';
    l_instcolnm_set(2).caccol_name := 'excld_flag';
    --
    ben_cache.write_mastDet_Cache
      (p_mastercol_name => 'vrbl_rt_prfl_id'
      ,p_detailcol_name => 'vrbl_rt_prfl_id'
      ,p_lkup_name	=> 'ben_rt_prfl_cache.g_bnfgrp_lookup'
      ,p_inst_name	=> 'ben_rt_prfl_cache.g_bnfgrp_instance'
      ,p_lkup_query	=> l_lookup_query
      ,p_inst_query	=> l_inst_query
      ,p_instcolnm_set	=> l_instcolnm_set
      );
    --
  end if;
  --
  -- Cache already populated. Get record set.
  --
  get_cached_data
    (p_vrbl_rt_prfl_id => p_vrbl_rt_prfl_id
    ,p_lookup_name     => 'ben_rt_prfl_cache.g_bnfgrp_lookup'
    ,p_inst_name       => 'ben_rt_prfl_cache.g_bnfgrp_instance'
    ,p_inst_set_type   => 'ben_rt_prfl_cache.g_bnfgrp_inst_tbl'
    ,p_out_inst_name   => 'ben_rt_prfl_cache.g_bnfgrp_out'
    );
  --
  p_inst_set := g_bnfgrp_out;
  p_inst_count := g_inst_count;
  --
exception
  --
  when no_data_found then
    --
    p_inst_count := 0;
    hr_utility.set_location('No data found', 90);
    hr_utility.set_location('Leaving : ' || l_proc, 99);
    --
end;
--
-- EMPLOYEE STATUS
--
procedure get_rt_prfl_cache
  (p_vrbl_rt_prfl_id   in number
  ,p_effective_date    in date
  ,p_lf_evt_ocrd_dt    in date
  ,p_business_group_id in number
  ,p_inst_set	       in out NOCOPY ben_rt_prfl_cache.g_eestat_inst_tbl
  ,p_inst_count        out nocopy number)
is
  --
  l_proc varchar2(80) := g_package || '.get_rt_prfl_cache';
  l_lookup_query long;
  l_inst_query	 long;
  l_instcolnm_set ben_cache.instcolnmtype;
  --
begin
  --
  g_eestat_out.delete;
  --
  if g_eestat_lookup.count = 0 then
    --
    -- Cache not populated yet. So populate it now.
    --
    l_lookup_query :=
      'select vrbl_rt_prfl_id, business_group_id'			      ||
       ' from ben_vrbl_rt_prfl_f vpf'					      ||
      ' where business_group_id = ' || to_char(p_business_group_id)	      ||
	' and exists (select null'					      ||
		      ' from ben_ee_stat_rt_f ees'			      ||
		     ' where ees.vrbl_rt_prfl_id = vpf.vrbl_rt_prfl_id'       ||
		       ' and ' || date_str(p_lf_evt_ocrd_dt,p_effective_date) ||
			     ' between ees.effective_start_date'	      ||
				 ' and ees.effective_end_date) '	      ||
	' and ' || date_str(p_lf_evt_ocrd_dt, p_effective_date) 	      ||
	      ' between vpf.effective_start_date and vpf.effective_end_date;';
    --
    l_inst_query :=
      'select ees.vrbl_rt_prfl_id, ees.assignment_status_type_id,'	   ||
	    ' ees.excld_flag'						   ||
       ' from ben_ee_stat_rt_f ees'					   ||
      ' where ees.business_group_id = ' || to_char(p_business_group_id)    ||
	' and ' || date_str(p_lf_evt_ocrd_dt, p_effective_date) 	   ||
	      ' between ees.effective_start_date'			   ||
		  ' and ees.effective_end_date' 			   ||
      ' order by ees.vrbl_rt_prfl_id;';
    --
    l_instcolnm_set(0).col_name    := 'vrbl_rt_prfl_id';
    l_instcolnm_set(0).caccol_name := 'id';
    l_instcolnm_set(1).col_name    := 'assignment_status_type_id';
    l_instcolnm_set(1).caccol_name := 'assignment_status_type_id';
    l_instcolnm_set(2).col_name    := 'excld_flag';
    l_instcolnm_set(2).caccol_name := 'excld_flag';
    --
    ben_cache.write_mastDet_Cache
      (p_mastercol_name => 'vrbl_rt_prfl_id'
      ,p_detailcol_name => 'vrbl_rt_prfl_id'
      ,p_lkup_name	=> 'ben_rt_prfl_cache.g_eestat_lookup'
      ,p_inst_name	=> 'ben_rt_prfl_cache.g_eestat_instance'
      ,p_lkup_query	=> l_lookup_query
      ,p_inst_query	=> l_inst_query
      ,p_instcolnm_set	=> l_instcolnm_set
      );
    --
  end if;
  --
  -- Cache already populated. Get record set.
  --
  get_cached_data
    (p_vrbl_rt_prfl_id => p_vrbl_rt_prfl_id
    ,p_lookup_name     => 'ben_rt_prfl_cache.g_eestat_lookup'
    ,p_inst_name       => 'ben_rt_prfl_cache.g_eestat_instance'
    ,p_inst_set_type   => 'ben_rt_prfl_cache.g_eestat_inst_tbl'
    ,p_out_inst_name   => 'ben_rt_prfl_cache.g_eestat_out'
    );
  --
  p_inst_set := g_eestat_out;
  p_inst_count := g_inst_count;
  --
exception
  --
  when no_data_found then
    --
    p_inst_count := 0;
    hr_utility.set_location('No Employee Status found', 90);
    hr_utility.set_location('Leaving : ' || l_proc, 99);
    --
end;
--
-- FULL TIME PART TIME
--
procedure get_rt_prfl_cache
  (p_vrbl_rt_prfl_id   in number
  ,p_effective_date    in date
  ,p_lf_evt_ocrd_dt    in date
  ,p_business_group_id in number
  ,p_inst_set	       in out NOCOPY ben_rt_prfl_cache.g_ftpt_inst_tbl
  ,p_inst_count        out nocopy number) is
  --
  l_proc varchar2(72) :=  'get_rt_prfl_cache';
  --
  l_instcolnm_set    ben_cache.InstColNmType;
  --
  l_torrwnum         pls_integer;
  l_insttorrw_num    pls_integer;
  l_index            pls_integer;
  l_instcolnm_num    pls_integer;
  l_mastertab_name   varchar2(100);
  l_masterpkcol_name varchar2(100);
  l_lkup_name        varchar2(100);
  l_inst_name        varchar2(100);
  --
  l_not_hash_found   boolean;
  --
begin
  --
  -- Populate the global cache
  --
  if g_ftpt_lookup.count = 0 then
    --
    -- Build the cache
    --
    l_mastertab_name            := 'ben_vrbl_rt_prfl_f';
    l_masterpkcol_name          := 'vrbl_rt_prfl_id';
    l_lkup_name                 := 'ben_rt_prfl_cache.g_ftpt_lookup';
    l_inst_name                 := 'ben_rt_prfl_cache.g_ftpt_instance';
    --
    l_instcolnm_num := 0;
    --
    l_instcolnm_set(l_instcolnm_num).col_name    := l_masterpkcol_name;
    l_instcolnm_set(l_instcolnm_num).caccol_name := 'vrbl_rt_prfl_id';
    l_instcolnm_set(l_instcolnm_num).col_alias   := 'table1';
    l_instcolnm_set(l_instcolnm_num).col_type    := 'MASTER';
    l_instcolnm_num := l_instcolnm_num+1;
    --
    l_instcolnm_set(l_instcolnm_num).col_name    := 'fl_tm_pt_tm_cd';
    l_instcolnm_set(l_instcolnm_num).caccol_name := 'fl_tm_pt_tm_cd';
    l_instcolnm_set(l_instcolnm_num).col_alias   := 'table1';
    l_instcolnm_num := l_instcolnm_num+1;
    --
    l_instcolnm_set(l_instcolnm_num).col_name    := 'excld_flag';
    l_instcolnm_set(l_instcolnm_num).caccol_name := 'excld_flag';
    l_instcolnm_set(l_instcolnm_num).col_alias   := 'table1';
    l_instcolnm_num := l_instcolnm_num+1;
    --
    ben_cache.Write_BGP_Cache
      (p_mastertab_name    => l_mastertab_name
      ,p_masterpkcol_name  => l_masterpkcol_name
      ,p_table1_name       => 'ben_fl_tm_pt_tm_rt_f'
      ,p_business_group_id => p_business_group_id
      ,p_effective_date    => get_eff_date(p_lf_evt_ocrd_dt, p_effective_date)
      ,p_lkup_name         => l_lkup_name
      ,p_inst_name         => l_inst_name
      ,p_instcolnm_set     => l_instcolnm_set
      );
    --
  end if;
  --
  -- Get the instance details
  --
  l_index := ben_hash_utility.get_hashed_index(p_id => p_vrbl_rt_prfl_id);
  --
  -- Check if hashed value is already allocated
  --
  if g_ftpt_lookup.exists(l_index) then
    --
    -- If it does exist make sure its the right one
    --
    if g_ftpt_lookup(l_index).id <> p_vrbl_rt_prfl_id then
      --
      l_not_hash_found := false;
      --
      -- Loop until un-allocated has value is derived
      --
      while not l_not_hash_found loop
        --
        l_index := ben_hash_utility.get_next_hash_index(p_hash_index => l_index);
        --
        -- Check if the hash index exists, if not we can use it
        --
        if not g_ftpt_lookup.exists(l_index) then
          --
          -- Lets store the hash value in the index
          --
          l_not_hash_found := true;
          exit;
          --
        else
          --
          l_not_hash_found := false;
          --
        end if;
        --
      end loop;
    --
    end if;
    --
  end if;
  --
  l_torrwnum := 0;
  for l_insttorrw_num in g_ftpt_lookup(l_index).starttorele_num ..
    g_ftpt_lookup(l_index).endtorele_num loop
    --
    p_inst_set(l_torrwnum) := g_ftpt_instance(l_insttorrw_num);
    l_torrwnum := l_torrwnum+1;
    --
  end loop;
  --
  p_inst_count := l_torrwnum;
  --
exception
  --
  when no_data_found then
    --
    p_inst_count := 0;
    --
end get_rt_prfl_cache;
--
-- GRADE
--
procedure get_rt_prfl_cache
  (p_vrbl_rt_prfl_id   in number
  ,p_effective_date    in date
  ,p_lf_evt_ocrd_dt    in date
  ,p_business_group_id in number
  ,p_inst_set	       in out NOCOPY ben_rt_prfl_cache.g_grd_inst_tbl
  ,p_inst_count        out nocopy number)
is
  --
  l_proc varchar2(80) := g_package || '.get_rt_prfl_cache';
  l_lookup_query long;
  l_inst_query	 long;
  l_instcolnm_set ben_cache.instcolnmtype;
  --
begin
  --
  g_grd_out.delete;
  --
  if g_grd_lookup.count = 0 then
    --
    -- Cache not populated yet. So populate it now.
    --
    l_lookup_query :=
      'select vrbl_rt_prfl_id, business_group_id'			      ||
       ' from ben_vrbl_rt_prfl_f vpf'					      ||
      ' where business_group_id = ' || to_char(p_business_group_id)	      ||
	' and exists (select null'					      ||
		      ' from ben_grade_rt_f egr'			      ||
		     ' where egr.vrbl_rt_prfl_id = vpf.vrbl_rt_prfl_id'       ||
		       ' and ' || date_str(p_lf_evt_ocrd_dt,p_effective_date) ||
			     ' between egr.effective_start_date'	      ||
				 ' and egr.effective_end_date) '	      ||
	' and ' || date_str(p_lf_evt_ocrd_dt, p_effective_date) 	      ||
	      ' between vpf.effective_start_date and vpf.effective_end_date;';
    --
    l_inst_query :=
      'select egr.vrbl_rt_prfl_id, egr.grade_id, egr.excld_flag'	   ||
       ' from ben_grade_rt_f egr'					   ||
      ' where egr.business_group_id = ' || to_char(p_business_group_id)    ||
	' and ' || date_str(p_lf_evt_ocrd_dt, p_effective_date) 	   ||
	      ' between egr.effective_start_date'			   ||
		  ' and egr.effective_end_date' 			   ||
      ' order by egr.vrbl_rt_prfl_id;';
    --
    l_instcolnm_set(0).col_name    := 'vrbl_rt_prfl_id';
    l_instcolnm_set(0).caccol_name := 'id';
    l_instcolnm_set(1).col_name    := 'grade_id';
    l_instcolnm_set(1).caccol_name := 'grade_id';
    l_instcolnm_set(2).col_name    := 'excld_flag';
    l_instcolnm_set(2).caccol_name := 'excld_flag';
    --
    ben_cache.write_mastDet_Cache
      (p_mastercol_name => 'vrbl_rt_prfl_id'
      ,p_detailcol_name => 'vrbl_rt_prfl_id'
      ,p_lkup_name	=> 'ben_rt_prfl_cache.g_grd_lookup'
      ,p_inst_name	=> 'ben_rt_prfl_cache.g_grd_instance'
      ,p_lkup_query	=> l_lookup_query
      ,p_inst_query	=> l_inst_query
      ,p_instcolnm_set	=> l_instcolnm_set
      );
    --
  end if;
  --
  -- Cache already populated. Get record set.
  --
  get_cached_data
    (p_vrbl_rt_prfl_id => p_vrbl_rt_prfl_id
    ,p_lookup_name     => 'ben_rt_prfl_cache.g_grd_lookup'
    ,p_inst_name       => 'ben_rt_prfl_cache.g_grd_instance'
    ,p_inst_set_type   => 'ben_rt_prfl_cache.g_grd_inst_tbl'
    ,p_out_inst_name   => 'ben_rt_prfl_cache.g_grd_out'
    );
  --
  p_inst_set := g_grd_out;
  p_inst_count := g_inst_count;
  --
exception
  --
  when no_data_found then
    --
    p_inst_count := 0;
    hr_utility.set_location('No Grade found', 90);
    hr_utility.set_location('Leaving : ' || l_proc, 99);
    --
end;
--
-- PERCENT FULL TIME
--
procedure get_rt_prfl_cache
  (p_vrbl_rt_prfl_id   in number
  ,p_effective_date    in date
  ,p_lf_evt_ocrd_dt    in date
  ,p_business_group_id in number
  ,p_inst_set	       in out NOCOPY ben_rt_prfl_cache.g_pctft_inst_tbl
  ,p_inst_count        out nocopy number)
is
  --
  l_proc varchar2(80) := g_package || '.get_rt_prfl_cache';
  l_lookup_query long;
  l_inst_query	 long;
  l_instcolnm_set ben_cache.instcolnmtype;
  --
begin
  --
  g_pctft_out.delete;
  --
  if g_pctft_lookup.count = 0 then
    --
    -- Cache not populated yet. So populate it now.
    --
    l_lookup_query :=
      'select vrbl_rt_prfl_id, business_group_id'			      ||
       ' from ben_vrbl_rt_prfl_f vpf'					      ||
      ' where business_group_id = ' || to_char(p_business_group_id)	      ||
	' and exists (select null'					      ||
		      ' from ben_pct_fl_tm_rt_f epf'			      ||
		     ' where epf.vrbl_rt_prfl_id = vpf.vrbl_rt_prfl_id'       ||
		       ' and ' || date_str(p_lf_evt_ocrd_dt,p_effective_date) ||
			     ' between epf.effective_start_date'	      ||
				 ' and epf.effective_end_date) '	      ||
	' and ' || date_str(p_lf_evt_ocrd_dt, p_effective_date) 	      ||
	      ' between vpf.effective_start_date and vpf.effective_end_date;';
    --
    l_inst_query :=
      'select epf.vrbl_rt_prfl_id, pff.mn_pct_val, pff.mx_pct_val,'	      ||
	    ' pff.no_mn_pct_val_flag, pff.no_mx_pct_val_flag, epf.excld_flag' ||
       ' from ben_pct_fl_tm_fctr pff, ben_pct_fl_tm_rt_f epf'		      ||
      ' where pff.pct_fl_tm_fctr_id = epf.pct_fl_tm_fctr_id'		      ||
	' and epf.business_group_id = ' || to_char(p_business_group_id)       ||
	' and ' || date_str(p_lf_evt_ocrd_dt, p_effective_date) 	      ||
	      ' between epf.effective_start_date'			      ||
		  ' and epf.effective_end_date' 			      ||
      ' order by epf.vrbl_rt_prfl_id;';
    --
    l_instcolnm_set(0).col_name    := 'vrbl_rt_prfl_id';
    l_instcolnm_set(0).caccol_name := 'id';
    l_instcolnm_set(1).col_name    := 'mn_pct_val';
    l_instcolnm_set(1).caccol_name := 'mn_pct_val';
    l_instcolnm_set(2).col_name    := 'mx_pct_val';
    l_instcolnm_set(2).caccol_name := 'mx_pct_val';
    l_instcolnm_set(3).col_name    := 'no_mn_pct_val_flag';
    l_instcolnm_set(3).caccol_name := 'no_mn_pct_val_flag';
    l_instcolnm_set(4).col_name    := 'no_mx_pct_val_flag';
    l_instcolnm_set(4).caccol_name := 'no_mx_pct_val_flag';
    l_instcolnm_set(5).col_name    := 'excld_flag';
    l_instcolnm_set(5).caccol_name := 'excld_flag';
    --
    ben_cache.write_mastDet_Cache
      (p_mastercol_name => 'vrbl_rt_prfl_id'
      ,p_detailcol_name => 'vrbl_rt_prfl_id'
      ,p_lkup_name	=> 'ben_rt_prfl_cache.g_pctft_lookup'
      ,p_inst_name	=> 'ben_rt_prfl_cache.g_pctft_instance'
      ,p_lkup_query	=> l_lookup_query
      ,p_inst_query	=> l_inst_query
      ,p_instcolnm_set	=> l_instcolnm_set
      );
    --
  end if;
  --
  -- Cache already populated. Get record set.
  --
  get_cached_data
    (p_vrbl_rt_prfl_id => p_vrbl_rt_prfl_id
    ,p_lookup_name     => 'ben_rt_prfl_cache.g_pctft_lookup'
    ,p_inst_name       => 'ben_rt_prfl_cache.g_pctft_instance'
    ,p_inst_set_type   => 'ben_rt_prfl_cache.g_pctft_inst_tbl'
    ,p_out_inst_name   => 'ben_rt_prfl_cache.g_pctft_out'
    );
  --
  p_inst_set := g_pctft_out;
  p_inst_count := g_inst_count;
  --
exception
  --
  when no_data_found then
    --
    p_inst_count := 0;
    hr_utility.set_location('No Percent Full Time found', 90);
    hr_utility.set_location('Leaving : ' || l_proc, 99);
    --
end;
--
-- HOURS WORKED
--
procedure get_rt_prfl_cache
  (p_vrbl_rt_prfl_id   in number
  ,p_effective_date    in date
  ,p_lf_evt_ocrd_dt    in date
  ,p_business_group_id in number
  ,p_inst_set	       in out NOCOPY ben_rt_prfl_cache.g_hrswkd_inst_tbl
  ,p_inst_count        out nocopy number)
is
  --
  l_proc varchar2(80) := g_package || '.get_rt_prfl_cache';
  l_lookup_query long;
  l_inst_query	 long;
  l_instcolnm_set ben_cache.instcolnmtype;
  --
begin
  --
  g_hrswkd_out.delete;
  --
  if g_hrswkd_lookup.count = 0 then
    --
    -- Cache not populated yet. So populate it now.
    --
    l_lookup_query :=
      'select vrbl_rt_prfl_id, business_group_id'			      ||
       ' from ben_vrbl_rt_prfl_f vpf'					      ||
      ' where business_group_id = ' || to_char(p_business_group_id)	      ||
	' and exists (select null'					      ||
		      ' from ben_hrs_wkd_in_perd_rt_f ehw'		      ||
		     ' where ehw.vrbl_rt_prfl_id = vpf.vrbl_rt_prfl_id'       ||
		       ' and ' || date_str(p_lf_evt_ocrd_dt,p_effective_date) ||
			     ' between ehw.effective_start_date'	      ||
				 ' and ehw.effective_end_date) '	      ||
	' and ' || date_str(p_lf_evt_ocrd_dt, p_effective_date) 	      ||
	      ' between vpf.effective_start_date and vpf.effective_end_date;';
    --
    l_inst_query :=
      'select ehw.vrbl_rt_prfl_id, hwf.mn_hrs_num, hwf.mx_hrs_num,'	      ||
	    ' hwf.no_mn_hrs_wkd_flag, hwf.no_mx_hrs_wkd_flag, ehw.excld_flag' ||
       ' from ben_hrs_wkd_in_perd_fctr hwf, ben_hrs_wkd_in_perd_rt_f ehw'     ||
      ' where hwf.hrs_wkd_in_perd_fctr_id = ehw.hrs_wkd_in_perd_fctr_id'      ||
	' and ehw.business_group_id = ' || to_char(p_business_group_id)       ||
	' and ' || date_str(p_lf_evt_ocrd_dt, p_effective_date) 	      ||
	      ' between ehw.effective_start_date'			      ||
		  ' and ehw.effective_end_date' 			      ||
      ' order by ehw.vrbl_rt_prfl_id;';
    --
    l_instcolnm_set(0).col_name    := 'vrbl_rt_prfl_id';
    l_instcolnm_set(0).caccol_name := 'id';
    l_instcolnm_set(1).col_name    := 'mn_hrs_num';
    l_instcolnm_set(1).caccol_name := 'mn_hrs_num';
    l_instcolnm_set(2).col_name    := 'mx_hrs_num';
    l_instcolnm_set(2).caccol_name := 'mx_hrs_num';
    l_instcolnm_set(3).col_name    := 'no_mn_hrs_wkd_flag';
    l_instcolnm_set(3).caccol_name := 'no_mn_hrs_wkd_flag';
    l_instcolnm_set(4).col_name    := 'no_mx_hrs_wkd_flag';
    l_instcolnm_set(4).caccol_name := 'no_mx_hrs_wkd_flag';
    l_instcolnm_set(5).col_name    := 'excld_flag';
    l_instcolnm_set(5).caccol_name := 'excld_flag';
    --
    ben_cache.write_mastDet_Cache
      (p_mastercol_name => 'vrbl_rt_prfl_id'
      ,p_detailcol_name => 'vrbl_rt_prfl_id'
      ,p_lkup_name	=> 'ben_rt_prfl_cache.g_hrswkd_lookup'
      ,p_inst_name	=> 'ben_rt_prfl_cache.g_hrswkd_instance'
      ,p_lkup_query	=> l_lookup_query
      ,p_inst_query	=> l_inst_query
      ,p_instcolnm_set	=> l_instcolnm_set
      );
    --
  end if;
  --
  -- Cache already populated. Get record set.
  --
  get_cached_data
    (p_vrbl_rt_prfl_id => p_vrbl_rt_prfl_id
    ,p_lookup_name     => 'ben_rt_prfl_cache.g_hrswkd_lookup'
    ,p_inst_name       => 'ben_rt_prfl_cache.g_hrswkd_instance'
    ,p_inst_set_type   => 'ben_rt_prfl_cache.g_hrswkd_inst_tbl'
    ,p_out_inst_name   => 'ben_rt_prfl_cache.g_hrswkd_out'
    );
  --
  p_inst_set := g_hrswkd_out;
  p_inst_count := g_inst_count;
  --
exception
  --
  when no_data_found then
    --
    p_inst_count := 0;
    hr_utility.set_location('No Hours Worked found', 90);
    hr_utility.set_location('Leaving : ' || l_proc, 99);
    --
end;
--
-- HOURS WORKED
--
procedure get_rt_prfl_cache
  (p_vrbl_rt_prfl_id   in number
  ,p_effective_date    in date
  ,p_lf_evt_ocrd_dt    in date
  ,p_business_group_id in number
  ,p_inst_set	       in out NOCOPY ben_rt_prfl_cache.g_poe_inst_tbl
  ,p_inst_count        out nocopy number)
is
  --
  l_proc varchar2(80) := g_package || '.get_rt_prfl_cache';
  l_lookup_query long;
  l_inst_query	 long;
  l_instcolnm_set ben_cache.instcolnmtype;
  --
begin
  --
  g_poe_out.delete;
  --
  if g_poe_lookup.count = 0 then
    --
    -- Cache not populated yet. So populate it now.
    --
    l_lookup_query :=
      'select vrbl_rt_prfl_id, business_group_id'			      ||
       ' from ben_vrbl_rt_prfl_f vpf'					      ||
      ' where business_group_id = ' || to_char(p_business_group_id)	      ||
	' and exists (select null'					      ||
		      ' from ben_poe_rt_f prt'				      ||
		     ' where prt.vrbl_rt_prfl_id = vpf.vrbl_rt_prfl_id'       ||
		       ' and ' || date_str(p_lf_evt_ocrd_dt,p_effective_date) ||
			     ' between prt.effective_start_date'	      ||
				 ' and prt.effective_end_date) '	      ||
	' and ' || date_str(p_lf_evt_ocrd_dt, p_effective_date) 	      ||
	      ' between vpf.effective_start_date and vpf.effective_end_date;';
    --
    l_inst_query :=
      'select prt.vrbl_rt_prfl_id, prt.mn_poe_num, prt.mx_poe_num,'	      ||
	    ' prt.no_mn_poe_flag, prt.no_mx_poe_flag, prt.rndg_cd,'	      ||
	    ' prt.rndg_rl, prt.poe_nnmntry_uom, prt.cbr_dsblty_apls_flag'     ||
       ' from ben_poe_rt_f prt' 					      ||
      ' where prt.business_group_id = ' || to_char(p_business_group_id)       ||
	' and ' || date_str(p_lf_evt_ocrd_dt, p_effective_date) 	      ||
	      ' between prt.effective_start_date'			      ||
		  ' and prt.effective_end_date' 			      ||
      ' order by prt.vrbl_rt_prfl_id;';
    --
    l_instcolnm_set(0).col_name    := 'vrbl_rt_prfl_id';
    l_instcolnm_set(0).caccol_name := 'id';
    l_instcolnm_set(1).col_name    := 'mn_poe_num';
    l_instcolnm_set(1).caccol_name := 'mn_poe_num';
    l_instcolnm_set(2).col_name    := 'mx_poe_num';
    l_instcolnm_set(2).caccol_name := 'mx_poe_num';
    l_instcolnm_set(3).col_name    := 'no_mn_poe_flag';
    l_instcolnm_set(3).caccol_name := 'no_mn_poe_flag';
    l_instcolnm_set(4).col_name    := 'no_mx_poe_flag';
    l_instcolnm_set(4).caccol_name := 'no_mx_poe_flag';
    l_instcolnm_set(5).col_name    := 'rndg_cd';
    l_instcolnm_set(5).caccol_name := 'rndg_cd';
    l_instcolnm_set(6).col_name    := 'rndg_rl';
    l_instcolnm_set(6).caccol_name := 'rndg_rl';
    l_instcolnm_set(7).col_name    := 'poe_nnmntry_uom';
    l_instcolnm_set(7).caccol_name := 'poe_nnmntry_uom';
    l_instcolnm_set(8).col_name    := 'cbr_dsblty_apls_flag';
    l_instcolnm_set(8).caccol_name := 'cbr_dsblty_apls_flag';
    --
    ben_cache.write_mastDet_Cache
      (p_mastercol_name => 'vrbl_rt_prfl_id'
      ,p_detailcol_name => 'vrbl_rt_prfl_id'
      ,p_lkup_name	=> 'ben_rt_prfl_cache.g_poe_lookup'
      ,p_inst_name	=> 'ben_rt_prfl_cache.g_poe_instance'
      ,p_lkup_query	=> l_lookup_query
      ,p_inst_query	=> l_inst_query
      ,p_instcolnm_set	=> l_instcolnm_set
      );
    --
  end if;
  --
  -- Cache already populated. Get record set.
  --
  get_cached_data
    (p_vrbl_rt_prfl_id => p_vrbl_rt_prfl_id
    ,p_lookup_name     => 'ben_rt_prfl_cache.g_poe_lookup'
    ,p_inst_name       => 'ben_rt_prfl_cache.g_poe_instance'
    ,p_inst_set_type   => 'ben_rt_prfl_cache.g_poe_inst_tbl'
    ,p_out_inst_name   => 'ben_rt_prfl_cache.g_poe_out'
    );
  --
  p_inst_set := g_poe_out;
  p_inst_count := g_inst_count;
  --
exception
  --
  when no_data_found then
    --
    p_inst_count := 0;
    hr_utility.set_location('No Period of Enrollment found', 90);
    hr_utility.set_location('Leaving : ' || l_proc, 99);
    --
end;
--
-- LABOR UNION MEMBERSHIP
--
procedure get_rt_prfl_cache
  (p_vrbl_rt_prfl_id   in number
  ,p_effective_date    in date
  ,p_lf_evt_ocrd_dt    in date
  ,p_business_group_id in number
  ,p_inst_set	       in out NOCOPY ben_rt_prfl_cache.g_lbrmmbr_inst_tbl
  ,p_inst_count        out nocopy number)
is
  --
  l_proc varchar2(80) := g_package || '.get_rt_prfl_cache';
  l_lookup_query long;
  l_inst_query	 long;
  l_instcolnm_set ben_cache.instcolnmtype;
  --
begin
  --
  g_lbrmmbr_out.delete;
  --
  if g_lbrmmbr_lookup.count = 0 then
    --
    -- Cache not populated yet. So populate it now.
    --
    l_lookup_query :=
      'select vrbl_rt_prfl_id, business_group_id'			      ||
       ' from ben_vrbl_rt_prfl_f vpf'					      ||
      ' where business_group_id = ' || to_char(p_business_group_id)	      ||
	' and exists (select null'					      ||
		      ' from ben_lbr_mmbr_rt_f elu'			      ||
		     ' where elu.vrbl_rt_prfl_id = vpf.vrbl_rt_prfl_id'       ||
		       ' and ' || date_str(p_lf_evt_ocrd_dt,p_effective_date) ||
			     ' between elu.effective_start_date'	      ||
				 ' and elu.effective_end_date) '	      ||
	' and ' || date_str(p_lf_evt_ocrd_dt, p_effective_date) 	      ||
	      ' between vpf.effective_start_date and vpf.effective_end_date;';
    --
    l_inst_query :=
      'select elu.vrbl_rt_prfl_id, elu.lbr_mmbr_flag, elu.excld_flag'	      ||
       ' from ben_lbr_mmbr_rt_f elu'					      ||
      ' where elu.business_group_id = ' || to_char(p_business_group_id)       ||
	' and ' || date_str(p_lf_evt_ocrd_dt, p_effective_date) 	      ||
	      ' between elu.effective_start_date'			      ||
		  ' and elu.effective_end_date' 			      ||
      ' order by elu.vrbl_rt_prfl_id;';
    --
    l_instcolnm_set(0).col_name    := 'vrbl_rt_prfl_id';
    l_instcolnm_set(0).caccol_name := 'id';
    l_instcolnm_set(1).col_name    := 'lbr_mmbr_flag';
    l_instcolnm_set(1).caccol_name := 'lbr_mmbr_flag';
    l_instcolnm_set(2).col_name    := 'excld_flag';
    l_instcolnm_set(2).caccol_name := 'excld_flag';
    --
    ben_cache.write_mastDet_Cache
      (p_mastercol_name => 'vrbl_rt_prfl_id'
      ,p_detailcol_name => 'vrbl_rt_prfl_id'
      ,p_lkup_name	=> 'ben_rt_prfl_cache.g_lbrmmbr_lookup'
      ,p_inst_name	=> 'ben_rt_prfl_cache.g_lbrmmbr_instance'
      ,p_lkup_query	=> l_lookup_query
      ,p_inst_query	=> l_inst_query
      ,p_instcolnm_set	=> l_instcolnm_set
      );
    --
  end if;
  --
  -- Cache already populated. Get record set.
  --
  get_cached_data
    (p_vrbl_rt_prfl_id => p_vrbl_rt_prfl_id
    ,p_lookup_name     => 'ben_rt_prfl_cache.g_lbrmmbr_lookup'
    ,p_inst_name       => 'ben_rt_prfl_cache.g_lbrmmbr_instance'
    ,p_inst_set_type   => 'ben_rt_prfl_cache.g_lbrmmbr_inst_tbl'
    ,p_out_inst_name   => 'ben_rt_prfl_cache.g_lbrmmbr_out'
    );
  --
  p_inst_set := g_lbrmmbr_out;
  p_inst_count := g_inst_count;
  --
exception
  --
  when no_data_found then
    --
    p_inst_count := 0;
    hr_utility.set_location('No Labor Union found', 90);
    hr_utility.set_location('Leaving : ' || l_proc, 99);
    --
end;
--
-- LEGAL ENTITY
--
procedure get_rt_prfl_cache
  (p_vrbl_rt_prfl_id   in number
  ,p_effective_date    in date
  ,p_lf_evt_ocrd_dt    in date
  ,p_business_group_id in number
  ,p_inst_set	       in out NOCOPY ben_rt_prfl_cache.g_lglenty_inst_tbl
  ,p_inst_count        out nocopy number)
is
  --
  l_proc varchar2(80) := g_package || '.get_rt_prfl_cache';
  l_lookup_query long;
  l_inst_query	 long;
  l_instcolnm_set ben_cache.instcolnmtype;
  --
begin
  --
  g_lglenty_out.delete;
  --
  if g_lglenty_lookup.count = 0 then
    --
    -- Cache not populated yet. So populate it now.
    --
    l_lookup_query :=
      'select vrbl_rt_prfl_id, business_group_id'			      ||
       ' from ben_vrbl_rt_prfl_f vpf'					      ||
      ' where business_group_id = ' || to_char(p_business_group_id)	      ||
	' and exists (select null'					      ||
		      ' from ben_lgl_enty_rt_f eln'			      ||
		     ' where eln.vrbl_rt_prfl_id = vpf.vrbl_rt_prfl_id'       ||
		       ' and ' || date_str(p_lf_evt_ocrd_dt,p_effective_date) ||
			     ' between eln.effective_start_date'	      ||
				 ' and eln.effective_end_date) '	      ||
	' and ' || date_str(p_lf_evt_ocrd_dt, p_effective_date) 	      ||
	      ' between vpf.effective_start_date and vpf.effective_end_date;';
    --
    l_inst_query :=
      'select eln.vrbl_rt_prfl_id, eln.organization_id, eln.excld_flag'       ||
       ' from ben_lgl_enty_rt_f eln'					      ||
      ' where eln.business_group_id = ' || to_char(p_business_group_id)       ||
	' and ' || date_str(p_lf_evt_ocrd_dt, p_effective_date) 	      ||
	      ' between eln.effective_start_date'			      ||
		  ' and eln.effective_end_date' 			      ||
      ' order by eln.vrbl_rt_prfl_id;';
    --
    l_instcolnm_set(0).col_name    := 'vrbl_rt_prfl_id';
    l_instcolnm_set(0).caccol_name := 'id';
    l_instcolnm_set(1).col_name    := 'organization_id';
    l_instcolnm_set(1).caccol_name := 'organization_id';
    l_instcolnm_set(2).col_name    := 'excld_flag';
    l_instcolnm_set(2).caccol_name := 'excld_flag';
    --
    ben_cache.write_mastDet_Cache
      (p_mastercol_name => 'vrbl_rt_prfl_id'
      ,p_detailcol_name => 'vrbl_rt_prfl_id'
      ,p_lkup_name	=> 'ben_rt_prfl_cache.g_lglenty_lookup'
      ,p_inst_name	=> 'ben_rt_prfl_cache.g_lglenty_instance'
      ,p_lkup_query	=> l_lookup_query
      ,p_inst_query	=> l_inst_query
      ,p_instcolnm_set	=> l_instcolnm_set
      );
    --
  end if;
  --
  -- Cache already populated. Get record set.
  --
  get_cached_data
    (p_vrbl_rt_prfl_id => p_vrbl_rt_prfl_id
    ,p_lookup_name     => 'ben_rt_prfl_cache.g_lglenty_lookup'
    ,p_inst_name       => 'ben_rt_prfl_cache.g_lglenty_instance'
    ,p_inst_set_type   => 'ben_rt_prfl_cache.g_lglenty_inst_tbl'
    ,p_out_inst_name   => 'ben_rt_prfl_cache.g_lglenty_out'
    );
  --
  p_inst_set := g_lglenty_out;
  p_inst_count := g_inst_count;
  --
exception
  --
  when no_data_found then
    --
    p_inst_count := 0;
    hr_utility.set_location('No Legal Entity found', 90);
    hr_utility.set_location('Leaving : ' || l_proc, 99);
    --
end;
--
-- LEAVE OF ABSENCE
--
procedure get_rt_prfl_cache
  (p_vrbl_rt_prfl_id   in number
  ,p_effective_date    in date
  ,p_lf_evt_ocrd_dt    in date
  ,p_business_group_id in number
  ,p_inst_set	       in out NOCOPY ben_rt_prfl_cache.g_loa_inst_tbl
  ,p_inst_count        out nocopy number) is
  --
  l_proc varchar2(72) :=  'get_rt_prfl_cache';
  --
  l_instcolnm_set    ben_cache.InstColNmType;
  --
  l_torrwnum         pls_integer;
  l_insttorrw_num    pls_integer;
  l_index            pls_integer;
  l_instcolnm_num    pls_integer;
  l_mastertab_name   varchar2(100);
  l_masterpkcol_name varchar2(100);
  l_lkup_name        varchar2(100);
  l_inst_name        varchar2(100);
  --
  l_not_hash_found   boolean;
  --
begin
  --
  -- Populate the global cache
  --
  if g_loa_lookup.count = 0 then
    --
    -- Build the cache
    --
    l_mastertab_name            := 'ben_vrbl_rt_prfl_f';
    l_masterpkcol_name          := 'vrbl_rt_prfl_id';
    l_lkup_name                 := 'ben_rt_prfl_cache.g_loa_lookup';
    l_inst_name                 := 'ben_rt_prfl_cache.g_loa_instance';
    --
    l_instcolnm_num := 0;
    --
    l_instcolnm_set(l_instcolnm_num).col_name    := l_masterpkcol_name;
    l_instcolnm_set(l_instcolnm_num).caccol_name := 'vrbl_rt_prfl_id';
    l_instcolnm_set(l_instcolnm_num).col_alias   := 'table1';
    l_instcolnm_set(l_instcolnm_num).col_type    := 'MASTER';
    l_instcolnm_num := l_instcolnm_num+1;
    --
    l_instcolnm_set(l_instcolnm_num).col_name    := 'absence_attendance_type_id';
    l_instcolnm_set(l_instcolnm_num).caccol_name := 'absence_attendance_type_id';
    l_instcolnm_set(l_instcolnm_num).col_alias   := 'table1';
    l_instcolnm_num := l_instcolnm_num+1;
    --
    l_instcolnm_set(l_instcolnm_num).col_name    := 'abs_attendance_reason_id';
    l_instcolnm_set(l_instcolnm_num).caccol_name := 'abs_attendance_reason_id';
    l_instcolnm_set(l_instcolnm_num).col_alias   := 'table1';
    l_instcolnm_num := l_instcolnm_num+1;
    --
    l_instcolnm_set(l_instcolnm_num).col_name    := 'excld_flag';
    l_instcolnm_set(l_instcolnm_num).caccol_name := 'excld_flag';
    l_instcolnm_set(l_instcolnm_num).col_alias   := 'table1';
    l_instcolnm_num := l_instcolnm_num+1;
    --
    ben_cache.Write_BGP_Cache
      (p_mastertab_name    => l_mastertab_name
      ,p_masterpkcol_name  => l_masterpkcol_name
      ,p_table1_name       => 'ben_loa_rsn_rt_f'
      ,p_business_group_id => p_business_group_id
      ,p_effective_date    => get_eff_date(p_lf_evt_ocrd_dt, p_effective_date)
      ,p_lkup_name         => l_lkup_name
      ,p_inst_name         => l_inst_name
      ,p_instcolnm_set     => l_instcolnm_set
      );
    --
  end if;
  --
  -- Get the instance details
  --
  l_index := ben_hash_utility.get_hashed_index(p_id => p_vrbl_rt_prfl_id);
  --
  -- Check if hashed value is already allocated
  --
  if g_loa_lookup.exists(l_index) then
    --
    -- If it does exist make sure its the right one
    --
    if g_loa_lookup(l_index).id <> p_vrbl_rt_prfl_id then
      --
      l_not_hash_found := false;
      --
      -- Loop until un-allocated has value is derived
      --
      while not l_not_hash_found loop
        --
        l_index := ben_hash_utility.get_next_hash_index(p_hash_index => l_index);
        --
        -- Check if the hash index exists, if not we can use it
        --
        if not g_loa_lookup.exists(l_index) then
          --
          -- Lets store the hash value in the index
          --
          l_not_hash_found := true;
          exit;
          --
        else
          --
          l_not_hash_found := false;
          --
        end if;
        --
      end loop;
    --
    end if;
    --
  end if;
  --
  l_torrwnum := 0;
  for l_insttorrw_num in g_loa_lookup(l_index).starttorele_num ..
    g_loa_lookup(l_index).endtorele_num loop
    --
    p_inst_set(l_torrwnum) := g_loa_instance(l_insttorrw_num);
    l_torrwnum := l_torrwnum+1;
    --
  end loop;
  --
  p_inst_count := l_torrwnum;
  --
exception
  --
  when no_data_found then
    --
    p_inst_count := 0;
    --
end get_rt_prfl_cache;
--
-- ORGANIZATION UNIT
--
procedure get_rt_prfl_cache
  (p_vrbl_rt_prfl_id   in number
  ,p_effective_date    in date
  ,p_lf_evt_ocrd_dt    in date
  ,p_business_group_id in number
  ,p_inst_set	       in out NOCOPY ben_rt_prfl_cache.g_org_inst_tbl
  ,p_inst_count        out nocopy number) is
  --
  l_proc varchar2(72) :=  'get_rt_prfl_cache';
  --
  l_instcolnm_set    ben_cache.InstColNmType;
  --
  l_torrwnum         pls_integer;
  l_insttorrw_num    pls_integer;
  l_index            pls_integer;
  l_instcolnm_num    pls_integer;
  l_mastertab_name   varchar2(100);
  l_masterpkcol_name varchar2(100);
  l_lkup_name        varchar2(100);
  l_inst_name        varchar2(100);
  --
  l_not_hash_found   boolean;
  --
begin
  --
  -- Populate the global cache
  --
  if g_org_lookup.count = 0 then
    --
    -- Build the cache
    --
    l_mastertab_name            := 'ben_vrbl_rt_prfl_f';
    l_masterpkcol_name          := 'vrbl_rt_prfl_id';
    l_lkup_name                 := 'ben_rt_prfl_cache.g_org_lookup';
    l_inst_name                 := 'ben_rt_prfl_cache.g_org_instance';
    --
    l_instcolnm_num := 0;
    --
    l_instcolnm_set(l_instcolnm_num).col_name    := l_masterpkcol_name;
    l_instcolnm_set(l_instcolnm_num).caccol_name := 'vrbl_rt_prfl_id';
    l_instcolnm_set(l_instcolnm_num).col_alias   := 'table1';
    l_instcolnm_set(l_instcolnm_num).col_type    := 'MASTER';
    l_instcolnm_num := l_instcolnm_num+1;
    --
    l_instcolnm_set(l_instcolnm_num).col_name    := 'organization_id';
    l_instcolnm_set(l_instcolnm_num).caccol_name := 'organization_id';
    l_instcolnm_set(l_instcolnm_num).col_alias   := 'table1';
    l_instcolnm_num := l_instcolnm_num+1;
    --
    l_instcolnm_set(l_instcolnm_num).col_name    := 'excld_flag';
    l_instcolnm_set(l_instcolnm_num).caccol_name := 'excld_flag';
    l_instcolnm_set(l_instcolnm_num).col_alias   := 'table1';
    l_instcolnm_num := l_instcolnm_num+1;
    --
    ben_cache.Write_BGP_Cache
      (p_mastertab_name    => l_mastertab_name
      ,p_masterpkcol_name  => l_masterpkcol_name
      ,p_table1_name       => 'ben_org_unit_rt_f'
      ,p_business_group_id => p_business_group_id
      ,p_effective_date    => get_eff_date(p_lf_evt_ocrd_dt, p_effective_date)
      ,p_lkup_name         => l_lkup_name
      ,p_inst_name         => l_inst_name
      ,p_instcolnm_set     => l_instcolnm_set
      );
    --
  end if;
  --
  -- Get the instance details
  --
  l_index := ben_hash_utility.get_hashed_index(p_id => p_vrbl_rt_prfl_id);
  --
  -- Check if hashed value is already allocated
  --
  if g_org_lookup.exists(l_index) then
    --
    -- If it does exist make sure its the right one
    --
    if g_org_lookup(l_index).id <> p_vrbl_rt_prfl_id then
      --
      l_not_hash_found := false;
      --
      -- Loop until un-allocated has value is derived
      --
      while not l_not_hash_found loop
        --
        l_index := ben_hash_utility.get_next_hash_index(p_hash_index => l_index);
        --
        -- Check if the hash index exists, if not we can use it
        --
        if not g_org_lookup.exists(l_index) then
          --
          -- Lets store the hash value in the index
          --
          l_not_hash_found := true;
          exit;
          --
        else
          --
          l_not_hash_found := false;
          --
        end if;
        --
      end loop;
    --
    end if;
    --
  end if;
  --
  l_torrwnum := 0;
  for l_insttorrw_num in g_org_lookup(l_index).starttorele_num ..
    g_org_lookup(l_index).endtorele_num loop
    --
    p_inst_set(l_torrwnum) := g_org_instance(l_insttorrw_num);
    l_torrwnum := l_torrwnum+1;
    --
  end loop;
  --
  p_inst_count := l_torrwnum;
  --
exception
  --
  when no_data_found then
    --
    p_inst_count := 0;
    --
end get_rt_prfl_cache;
--
-- PERSON TYPE
--
procedure get_rt_prfl_cache
  (p_vrbl_rt_prfl_id   in number
  ,p_effective_date    in date
  ,p_lf_evt_ocrd_dt    in date
  ,p_business_group_id in number
  ,p_inst_set	       in out NOCOPY ben_rt_prfl_cache.g_pertyp_inst_tbl
  ,p_inst_count        out nocopy number)
is
  --
  l_proc varchar2(80) := g_package || '.get_rt_prfl_cache';
  l_lookup_query long;
  l_inst_query	 long;
  l_instcolnm_set ben_cache.instcolnmtype;
  --
begin
  --
  g_pertyp_out.delete;
  --
  if g_pertyp_lookup.count = 0 then
    --
    -- Cache not populated yet. So populate it now.
    --
    l_lookup_query :=
      'select vrbl_rt_prfl_id, business_group_id'			      ||
       ' from ben_vrbl_rt_prfl_f vpf'					      ||
      ' where business_group_id = ' || to_char(p_business_group_id)	      ||
	' and exists (select null'					      ||
		      ' from ben_per_typ_rt_f ptr'			      ||
		     ' where ptr.vrbl_rt_prfl_id = vpf.vrbl_rt_prfl_id'       ||
		       ' and ' || date_str(p_lf_evt_ocrd_dt,p_effective_date) ||
			     ' between ptr.effective_start_date'	      ||
				 ' and ptr.effective_end_date) '	      ||
	' and ' || date_str(p_lf_evt_ocrd_dt, p_effective_date) 	      ||
	      ' between vpf.effective_start_date and vpf.effective_end_date;';
    --
    l_inst_query :=
     --
     -- Bug 1631182 - To support user created person_type_id
     -- decided not to use per_typ_cd instead use person_type_id
     --
     --'select ptr.vrbl_rt_prfl_id, ptr.per_typ_cd, ptr.excld_flag'	      ||
      'select ptr.vrbl_rt_prfl_id, ptr.person_type_id, ptr.excld_flag'	      ||
       ' from ben_per_typ_rt_f ptr'					      ||
      ' where ptr.business_group_id = ' || to_char(p_business_group_id)       ||
	' and ' || date_str(p_lf_evt_ocrd_dt, p_effective_date) 	      ||
	      ' between ptr.effective_start_date'			      ||
		  ' and ptr.effective_end_date' 			      ||
      ' order by ptr.vrbl_rt_prfl_id;';
    --
    l_instcolnm_set(0).col_name    := 'vrbl_rt_prfl_id';
    l_instcolnm_set(0).caccol_name := 'id';
   -- l_instcolnm_set(1).col_name    := 'per_typ_cd';
    l_instcolnm_set(1).col_name    := 'person_type_id';
    --l_instcolnm_set(1).caccol_name := 'per_typ_cd';
    l_instcolnm_set(1).caccol_name := 'person_type_id';
    l_instcolnm_set(2).col_name    := 'excld_flag';
    l_instcolnm_set(2).caccol_name := 'excld_flag';
    --
    ben_cache.write_mastDet_Cache
      (p_mastercol_name => 'vrbl_rt_prfl_id'
      ,p_detailcol_name => 'vrbl_rt_prfl_id'
      ,p_lkup_name	=> 'ben_rt_prfl_cache.g_pertyp_lookup'
      ,p_inst_name	=> 'ben_rt_prfl_cache.g_pertyp_instance'
      ,p_lkup_query	=> l_lookup_query
      ,p_inst_query	=> l_inst_query
      ,p_instcolnm_set	=> l_instcolnm_set
      );
    --
  end if;
  --
  -- Cache already populated. Get record set.
  --
  get_cached_data
    (p_vrbl_rt_prfl_id => p_vrbl_rt_prfl_id
    ,p_lookup_name     => 'ben_rt_prfl_cache.g_pertyp_lookup'
    ,p_inst_name       => 'ben_rt_prfl_cache.g_pertyp_instance'
    ,p_inst_set_type   => 'ben_rt_prfl_cache.g_pertyp_inst_tbl'
    ,p_out_inst_name   => 'ben_rt_prfl_cache.g_pertyp_out'
    );
  --
  p_inst_set := g_pertyp_out;
  p_inst_count := g_inst_count;
  --
exception
  --
  when no_data_found then
    --
    p_inst_count := 0;
    hr_utility.set_location('No Person Type found', 90);
    hr_utility.set_location('Leaving : ' || l_proc, 99);
    --
end;
--
-- POSTAL ZIP RANGE
--
procedure get_rt_prfl_cache
  (p_vrbl_rt_prfl_id   in number
  ,p_effective_date    in date
  ,p_lf_evt_ocrd_dt    in date
  ,p_business_group_id in number
  ,p_inst_set	       in out NOCOPY ben_rt_prfl_cache.g_ziprng_inst_tbl
  ,p_inst_count        out nocopy number)
is
  --
  l_proc varchar2(80) := g_package || '.get_rt_prfl_cache';
  l_lookup_query long;
  l_inst_query	 long;
  l_instcolnm_set ben_cache.instcolnmtype;
  --
begin
  --
  g_ziprng_out.delete;
  --
  if g_ziprng_lookup.count = 0 then
    --
    -- Cache not populated yet. So populate it now.
    --
    l_lookup_query :=
      'select vrbl_rt_prfl_id, business_group_id'			      ||
       ' from ben_vrbl_rt_prfl_f vpf'					      ||
      ' where business_group_id = ' || to_char(p_business_group_id)	      ||
	' and exists (select null'					      ||
		      ' from ben_pstl_zip_rt_f epz'			      ||
		     ' where epz.vrbl_rt_prfl_id = vpf.vrbl_rt_prfl_id'       ||
		       ' and ' || date_str(p_lf_evt_ocrd_dt,p_effective_date) ||
			     ' between epz.effective_start_date'	      ||
				 ' and epz.effective_end_date) '	      ||
	' and ' || date_str(p_lf_evt_ocrd_dt, p_effective_date) 	      ||
	      ' between vpf.effective_start_date and vpf.effective_end_date;';
    --
    l_inst_query :=
      'select epz.vrbl_rt_prfl_id, rzr.from_value,'			      ||
	    ' rzr.to_value, epz.excld_flag'				      ||
       ' from ben_pstl_zip_rng_f rzr, ben_pstl_zip_rt_f epz'		      ||
      ' where epz.business_group_id = ' || to_char(p_business_group_id)       ||
	' and epz.pstl_zip_rng_id = rzr.pstl_zip_rng_id'		      ||
	' and ' || date_str(p_lf_evt_ocrd_dt, p_effective_date) 	      ||
	      ' between epz.effective_start_date'			      ||
		  ' and epz.effective_end_date' 			      ||
      ' order by epz.vrbl_rt_prfl_id;';
    --
    l_instcolnm_set(0).col_name    := 'vrbl_rt_prfl_id';
    l_instcolnm_set(0).caccol_name := 'id';
    l_instcolnm_set(1).col_name    := 'from_value';
    l_instcolnm_set(1).caccol_name := 'from_value';
    l_instcolnm_set(2).col_name    := 'to_value';
    l_instcolnm_set(2).caccol_name := 'to_value';
    l_instcolnm_set(3).col_name    := 'excld_flag';
    l_instcolnm_set(3).caccol_name := 'excld_flag';
    --
    ben_cache.write_mastDet_Cache
      (p_mastercol_name => 'vrbl_rt_prfl_id'
      ,p_detailcol_name => 'vrbl_rt_prfl_id'
      ,p_lkup_name	=> 'ben_rt_prfl_cache.g_ziprng_lookup'
      ,p_inst_name	=> 'ben_rt_prfl_cache.g_ziprng_instance'
      ,p_lkup_query	=> l_lookup_query
      ,p_inst_query	=> l_inst_query
      ,p_instcolnm_set	=> l_instcolnm_set
      );
    --
  end if;
  --
  -- Cache already populated. Get record set.
  --
  get_cached_data
    (p_vrbl_rt_prfl_id => p_vrbl_rt_prfl_id
    ,p_lookup_name     => 'ben_rt_prfl_cache.g_ziprng_lookup'
    ,p_inst_name       => 'ben_rt_prfl_cache.g_ziprng_instance'
    ,p_inst_set_type   => 'ben_rt_prfl_cache.g_ziprng_inst_tbl'
    ,p_out_inst_name   => 'ben_rt_prfl_cache.g_ziprng_out'
    );
  --
  p_inst_set := g_ziprng_out;
  p_inst_count := g_inst_count;
  --
exception
  --
  when no_data_found then
    --
    p_inst_count := 0;
    hr_utility.set_location('No Zip found', 90);
    hr_utility.set_location('Leaving : ' || l_proc, 99);
    --
end;
--
-- PAYROLL
--
procedure get_rt_prfl_cache
  (p_vrbl_rt_prfl_id   in number
  ,p_effective_date    in date
  ,p_lf_evt_ocrd_dt    in date
  ,p_business_group_id in number
  ,p_inst_set	       in out NOCOPY ben_rt_prfl_cache.g_pyrl_inst_tbl
  ,p_inst_count        out nocopy number)
is
  --
  l_proc varchar2(80) := g_package || '.get_rt_prfl_cache';
  l_lookup_query long;
  l_inst_query	 long;
  l_instcolnm_set ben_cache.instcolnmtype;
  --
begin
  --
  g_pyrl_out.delete;
  --
  if g_pyrl_lookup.count = 0 then
    --
    -- Cache not populated yet. So populate it now.
    --
    l_lookup_query :=
      'select vrbl_rt_prfl_id, business_group_id'			      ||
       ' from ben_vrbl_rt_prfl_f vpf'					      ||
      ' where business_group_id = ' || to_char(p_business_group_id)	      ||
	' and exists (select null'					      ||
		      ' from ben_pyrl_rt_f pr'				      ||
		     ' where pr.vrbl_rt_prfl_id = vpf.vrbl_rt_prfl_id'	      ||
		       ' and ' || date_str(p_lf_evt_ocrd_dt,p_effective_date) ||
			     ' between pr.effective_start_date' 	      ||
				 ' and pr.effective_end_date) ' 	      ||
	' and ' || date_str(p_lf_evt_ocrd_dt, p_effective_date) 	      ||
	      ' between vpf.effective_start_date and vpf.effective_end_date;';
    --
    l_inst_query :=
      'select pr.vrbl_rt_prfl_id, pr.payroll_id, pr.excld_flag' 	     ||
       ' from ben_pyrl_rt_f pr' 					     ||
      ' where pr.business_group_id = ' || to_char(p_business_group_id)	     ||
	' and ' || date_str(p_lf_evt_ocrd_dt, p_effective_date) 	     ||
	      ' between pr.effective_start_date'			     ||
		  ' and pr.effective_end_date'				     ||
      ' order by pr.vrbl_rt_prfl_id;';
    --
    l_instcolnm_set(0).col_name    := 'vrbl_rt_prfl_id';
    l_instcolnm_set(0).caccol_name := 'id';
    l_instcolnm_set(1).col_name    := 'payroll_id';
    l_instcolnm_set(1).caccol_name := 'payroll_id';
    l_instcolnm_set(2).col_name    := 'excld_flag';
    l_instcolnm_set(2).caccol_name := 'excld_flag';
    --
    ben_cache.write_mastDet_Cache
      (p_mastercol_name => 'vrbl_rt_prfl_id'
      ,p_detailcol_name => 'vrbl_rt_prfl_id'
      ,p_lkup_name	=> 'ben_rt_prfl_cache.g_pyrl_lookup'
      ,p_inst_name	=> 'ben_rt_prfl_cache.g_pyrl_instance'
      ,p_lkup_query	=> l_lookup_query
      ,p_inst_query	=> l_inst_query
      ,p_instcolnm_set	=> l_instcolnm_set
      );
    --
  end if;
  --
  -- Cache already populated. Get record set.
  --
  get_cached_data
    (p_vrbl_rt_prfl_id => p_vrbl_rt_prfl_id
    ,p_lookup_name     => 'ben_rt_prfl_cache.g_pyrl_lookup'
    ,p_inst_name       => 'ben_rt_prfl_cache.g_pyrl_instance'
    ,p_inst_set_type   => 'ben_rt_prfl_cache.g_pyrl_inst_tbl'
    ,p_out_inst_name   => 'ben_rt_prfl_cache.g_pyrl_out'
    );
  --
  p_inst_set := g_pyrl_out;
  p_inst_count := g_inst_count;
  --
exception
  --
  when no_data_found then
    --
    p_inst_count := 0;
    hr_utility.set_location('No Payroll found', 90);
    hr_utility.set_location('Leaving : ' || l_proc, 99);
    --
end;
--
-- PAY BASIS
--
procedure get_rt_prfl_cache
  (p_vrbl_rt_prfl_id   in number
  ,p_effective_date    in date
  ,p_lf_evt_ocrd_dt    in date
  ,p_business_group_id in number
  ,p_inst_set	       in out NOCOPY ben_rt_prfl_cache.g_py_bss_inst_tbl
  ,p_inst_count        out nocopy number)
is
  --
  l_proc varchar2(80) := g_package || '.get_rt_prfl_cache';
  l_lookup_query long;
  l_inst_query	 long;
  l_instcolnm_set ben_cache.instcolnmtype;
  --
begin
  --
  g_py_bss_out.delete;
  --
  if g_py_bss_lookup.count = 0 then
    --
    -- Cache not populated yet. So populate it now.
    --
    l_lookup_query :=
      'select vrbl_rt_prfl_id, business_group_id'			      ||
       ' from ben_vrbl_rt_prfl_f vpf'					      ||
      ' where business_group_id = ' || to_char(p_business_group_id)	      ||
	' and exists (select null'					      ||
		      ' from ben_py_bss_rt_f pbr'			      ||
		     ' where pbr.vrbl_rt_prfl_id = vpf.vrbl_rt_prfl_id'       ||
		       ' and ' || date_str(p_lf_evt_ocrd_dt,p_effective_date) ||
			     ' between pbr.effective_start_date'	      ||
				 ' and pbr.effective_end_date) '	      ||
	' and ' || date_str(p_lf_evt_ocrd_dt, p_effective_date) 	      ||
	      ' between vpf.effective_start_date and vpf.effective_end_date;';
    --
    l_inst_query :=
      'select pbr.vrbl_rt_prfl_id, pbr.pay_basis_id, pbr.excld_flag'	      ||
       ' from ben_py_bss_rt_f pbr'					      ||
      ' where pbr.business_group_id = ' || to_char(p_business_group_id)       ||
	' and ' || date_str(p_lf_evt_ocrd_dt, p_effective_date) 	      ||
	      ' between pbr.effective_start_date'			      ||
		  ' and pbr.effective_end_date' 			      ||
      ' order by pbr.vrbl_rt_prfl_id;';
    --
    l_instcolnm_set(0).col_name    := 'vrbl_rt_prfl_id';
    l_instcolnm_set(0).caccol_name := 'id';
    l_instcolnm_set(1).col_name    := 'pay_basis_id';
    l_instcolnm_set(1).caccol_name := 'pay_basis_id';
    l_instcolnm_set(2).col_name    := 'excld_flag';
    l_instcolnm_set(2).caccol_name := 'excld_flag';
    --
    ben_cache.write_mastDet_Cache
      (p_mastercol_name => 'vrbl_rt_prfl_id'
      ,p_detailcol_name => 'vrbl_rt_prfl_id'
      ,p_lkup_name	=> 'ben_rt_prfl_cache.g_py_bss_lookup'
      ,p_inst_name	=> 'ben_rt_prfl_cache.g_py_bss_instance'
      ,p_lkup_query	=> l_lookup_query
      ,p_inst_query	=> l_inst_query
      ,p_instcolnm_set	=> l_instcolnm_set
      );
    --
  end if;
  --
  -- Cache already populated. Get record set.
  --
  get_cached_data
    (p_vrbl_rt_prfl_id => p_vrbl_rt_prfl_id
    ,p_lookup_name     => 'ben_rt_prfl_cache.g_py_bss_lookup'
    ,p_inst_name       => 'ben_rt_prfl_cache.g_py_bss_instance'
    ,p_inst_set_type   => 'ben_rt_prfl_cache.g_py_bss_inst_tbl'
    ,p_out_inst_name   => 'ben_rt_prfl_cache.g_py_bss_out'
    );
  --
  p_inst_set := g_py_bss_out;
  p_inst_count := g_inst_count;
  --
exception
  --
  when no_data_found then
    --
    p_inst_count := 0;
    hr_utility.set_location('No Pay Basis found', 90);
    hr_utility.set_location('Leaving : ' || l_proc, 99);
    --
end;
--
-- SCHEDULED HOURS
--
procedure get_rt_prfl_cache
  (p_vrbl_rt_prfl_id   in number
  ,p_effective_date    in date
  ,p_lf_evt_ocrd_dt    in date
  ,p_business_group_id in number
  ,p_inst_set	       in out NOCOPY ben_rt_prfl_cache.g_scdhrs_inst_tbl
  ,p_inst_count        out nocopy number)
is
  --
  l_proc varchar2(80) := g_package || '.get_rt_prfl_cache';
  l_lookup_query long;
  l_inst_query	 long;
  l_instcolnm_set ben_cache.instcolnmtype;
  --
begin
  --
  g_scdhrs_out.delete;
  --
  if g_scdhrs_lookup.count = 0 then
    --
    -- Cache not populated yet. So populate it now.
    --
    l_lookup_query :=
      'select vrbl_rt_prfl_id, business_group_id'			      ||
       ' from ben_vrbl_rt_prfl_f vpf'					      ||
      ' where business_group_id = ' || to_char(p_business_group_id)	      ||
	' and exists (select null'					      ||
		      ' from ben_schedd_hrs_rt_f shr'			      ||
		     ' where shr.vrbl_rt_prfl_id = vpf.vrbl_rt_prfl_id'       ||
		       ' and ' || date_str(p_lf_evt_ocrd_dt,p_effective_date) ||
			     ' between shr.effective_start_date'	      ||
				 ' and shr.effective_end_date) '	      ||
	' and ' || date_str(p_lf_evt_ocrd_dt, p_effective_date) 	      ||
	      ' between vpf.effective_start_date and vpf.effective_end_date;';
    --
    l_inst_query :=
      'select shr.vrbl_rt_prfl_id, shr.hrs_num, shr.freq_cd, '||
      ' shr.max_hrs_num, shr.schedd_hrs_rl, shr.determination_cd, shr.determination_rl, '||
      ' shr.rounding_cd, shr.rounding_rl, ' ||
      ' shr.excld_flag'  ||
       ' from ben_schedd_hrs_rt_f shr'					      ||
      ' where shr.business_group_id = ' || to_char(p_business_group_id)       ||
	' and ' || date_str(p_lf_evt_ocrd_dt, p_effective_date) 	      ||
	      ' between shr.effective_start_date'			      ||
		  ' and shr.effective_end_date' 			      ||
      ' order by shr.vrbl_rt_prfl_id;';
    --
    l_instcolnm_set(0).col_name    := 'vrbl_rt_prfl_id';
    l_instcolnm_set(0).caccol_name := 'id';
    l_instcolnm_set(1).col_name    := 'hrs_num';
    l_instcolnm_set(1).caccol_name := 'hrs_num';
    l_instcolnm_set(2).col_name    := 'freq_cd';
    l_instcolnm_set(2).caccol_name := 'freq_cd';
    l_instcolnm_set(3).col_name    := 'max_hrs_num';
    l_instcolnm_set(3).caccol_name := 'max_hrs_num';
    l_instcolnm_set(4).col_name    := 'schedd_hrs_rl';
    l_instcolnm_set(4).caccol_name := 'schedd_hrs_rl';
    l_instcolnm_set(5).col_name    := 'determination_cd';
    l_instcolnm_set(5).caccol_name := 'determination_cd';
    l_instcolnm_set(6).col_name    := 'determination_rl';
    l_instcolnm_set(6).caccol_name := 'determination_rl';
    l_instcolnm_set(7).col_name    := 'rounding_cd';
    l_instcolnm_set(7).caccol_name := 'rounding_cd';
    l_instcolnm_set(8).col_name    := 'rounding_rl';
    l_instcolnm_set(8).caccol_name := 'rounding_rl';
    l_instcolnm_set(9).col_name    := 'excld_flag';
    l_instcolnm_set(9).caccol_name := 'excld_flag';

    --
    ben_cache.write_mastDet_Cache
      (p_mastercol_name => 'vrbl_rt_prfl_id'
      ,p_detailcol_name => 'vrbl_rt_prfl_id'
      ,p_lkup_name	=> 'ben_rt_prfl_cache.g_scdhrs_lookup'
      ,p_inst_name	=> 'ben_rt_prfl_cache.g_scdhrs_instance'
      ,p_lkup_query	=> l_lookup_query
      ,p_inst_query	=> l_inst_query
      ,p_instcolnm_set	=> l_instcolnm_set
      );
    --
  end if;
  --
  -- Cache already populated. Get record set.
  --
  get_cached_data
    (p_vrbl_rt_prfl_id => p_vrbl_rt_prfl_id
    ,p_lookup_name     => 'ben_rt_prfl_cache.g_scdhrs_lookup'
    ,p_inst_name       => 'ben_rt_prfl_cache.g_scdhrs_instance'
    ,p_inst_set_type   => 'ben_rt_prfl_cache.g_scdhrs_inst_tbl'
    ,p_out_inst_name   => 'ben_rt_prfl_cache.g_scdhrs_out'
    );
  --
  p_inst_set := g_scdhrs_out;
  p_inst_count := g_inst_count;

  --
exception
  --
  when no_data_found then
    --
    p_inst_count := 0;
    hr_utility.set_location('No Scheduled Hours found', 90);
    hr_utility.set_location('Leaving : ' || l_proc, 99);
    --
end;
--
-- WORK LOCATION
--
procedure get_rt_prfl_cache
  (p_vrbl_rt_prfl_id   in number
  ,p_effective_date    in date
  ,p_lf_evt_ocrd_dt    in date
  ,p_business_group_id in number
  ,p_inst_set	       in out NOCOPY ben_rt_prfl_cache.g_wkloc_inst_tbl
  ,p_inst_count        out nocopy number)
is
  --
  l_proc varchar2(80) := g_package || '.get_rt_prfl_cache';
  l_lookup_query long;
  l_inst_query	 long;
  l_instcolnm_set ben_cache.instcolnmtype;
  --
begin
  --
  g_wkloc_out.delete;
  --
  if g_wkloc_lookup.count = 0 then
    --
    -- Cache not populated yet. So populate it now.
    --
    l_lookup_query :=
      'select vrbl_rt_prfl_id, business_group_id'			      ||
       ' from ben_vrbl_rt_prfl_f vpf'					      ||
      ' where business_group_id = ' || to_char(p_business_group_id)	      ||
	' and exists (select null'					      ||
		      ' from ben_wk_loc_rt_f wlr'			      ||
		     ' where wlr.vrbl_rt_prfl_id = vpf.vrbl_rt_prfl_id'       ||
		       ' and ' || date_str(p_lf_evt_ocrd_dt,p_effective_date) ||
			     ' between wlr.effective_start_date'	      ||
				 ' and wlr.effective_end_date) '	      ||
	' and ' || date_str(p_lf_evt_ocrd_dt, p_effective_date) 	      ||
	      ' between vpf.effective_start_date and vpf.effective_end_date;';
    --
    l_inst_query :=
      'select wlr.vrbl_rt_prfl_id, wlr.location_id , wlr.excld_flag'	      ||
       ' from ben_wk_loc_rt_f wlr'					      ||
      ' where wlr.business_group_id = ' || to_char(p_business_group_id)       ||
	' and ' || date_str(p_lf_evt_ocrd_dt, p_effective_date) 	      ||
	      ' between wlr.effective_start_date'			      ||
		  ' and wlr.effective_end_date' 			      ||
      ' order by wlr.vrbl_rt_prfl_id;';
    --
    l_instcolnm_set(0).col_name    := 'vrbl_rt_prfl_id';
    l_instcolnm_set(0).caccol_name := 'id';
    l_instcolnm_set(1).col_name    := 'location_id';
    l_instcolnm_set(1).caccol_name := 'location_id';
    l_instcolnm_set(2).col_name    := 'excld_flag';
    l_instcolnm_set(2).caccol_name := 'excld_flag';
    --
    ben_cache.write_mastDet_Cache
      (p_mastercol_name => 'vrbl_rt_prfl_id'
      ,p_detailcol_name => 'vrbl_rt_prfl_id'
      ,p_lkup_name	=> 'ben_rt_prfl_cache.g_wkloc_lookup'
      ,p_inst_name	=> 'ben_rt_prfl_cache.g_wkloc_instance'
      ,p_lkup_query	=> l_lookup_query
      ,p_inst_query	=> l_inst_query
      ,p_instcolnm_set	=> l_instcolnm_set
      );
    --
  end if;
  --
  -- Cache already populated. Get record set.
  --
  get_cached_data
    (p_vrbl_rt_prfl_id => p_vrbl_rt_prfl_id
    ,p_lookup_name     => 'ben_rt_prfl_cache.g_wkloc_lookup'
    ,p_inst_name       => 'ben_rt_prfl_cache.g_wkloc_instance'
    ,p_inst_set_type   => 'ben_rt_prfl_cache.g_wkloc_inst_tbl'
    ,p_out_inst_name   => 'ben_rt_prfl_cache.g_wkloc_out'
    );
  --
  p_inst_set := g_wkloc_out;
  p_inst_count := g_inst_count;
  --
exception
  --
  when no_data_found then
    --
    p_inst_count := 0;
    hr_utility.set_location('No Work Location found', 90);
    hr_utility.set_location('Leaving : ' || l_proc, 99);
    --
end;
--
-- SERVICE AREA
--
procedure get_rt_prfl_cache
  (p_vrbl_rt_prfl_id   in number
  ,p_effective_date    in date
  ,p_lf_evt_ocrd_dt    in date
  ,p_business_group_id in number
  ,p_inst_set	       in out NOCOPY ben_rt_prfl_cache.g_svcarea_inst_tbl
  ,p_inst_count        out nocopy number)
is
  --
  l_proc varchar2(80) := g_package || '.get_rt_prfl_cache';
  l_lookup_query long;
  l_inst_query	 long;
  l_instcolnm_set ben_cache.instcolnmtype;
  --
begin
  --
  g_svcarea_out.delete;
  --
  if g_svcarea_lookup.count = 0 then
    --
    -- Cache not populated yet. So populate it now.
    --
    l_lookup_query :=
      'select vrbl_rt_prfl_id, business_group_id'			      ||
       ' from ben_vrbl_rt_prfl_f vpf'					      ||
      ' where business_group_id = ' || to_char(p_business_group_id)	      ||
	' and exists (select null'					      ||
		      ' from ben_svc_area_rt_f sar'			      ||
		     ' where sar.vrbl_rt_prfl_id = vpf.vrbl_rt_prfl_id'       ||
		       ' and ' || date_str(p_lf_evt_ocrd_dt,p_effective_date) ||
			     ' between sar.effective_start_date'	      ||
				 ' and sar.effective_end_date) '	      ||
	' and ' || date_str(p_lf_evt_ocrd_dt, p_effective_date) 	      ||
	      ' between vpf.effective_start_date and vpf.effective_end_date;';
    --
    l_inst_query :=
      'select sar.vrbl_rt_prfl_id, pzr.from_value,'			      ||
	    ' pzr.to_value, sar.excld_flag'				      ||
       ' from ben_pstl_zip_rng_f pzr, ben_svc_area_pstl_zip_rng_f spz,'       ||
	    ' ben_svc_area_rt_f sar'					      ||
      ' where sar.business_group_id = ' || to_char(p_business_group_id)       ||
	' and sar.svc_area_id = spz.svc_area_id'			      ||
	' and spz.pstl_zip_rng_id = pzr.pstl_zip_rng_id'		      ||
	' and ' || date_str(p_lf_evt_ocrd_dt, p_effective_date) 	      ||
	      ' between sar.effective_start_date'			      ||
		  ' and sar.effective_end_date' 			      ||
	' and ' || date_str(p_lf_evt_ocrd_dt, p_effective_date) 	      ||
	      ' between pzr.effective_start_date'			      ||
		  ' and pzr.effective_end_date' 			      ||
	' and ' || date_str(p_lf_evt_ocrd_dt, p_effective_date) 	      ||
	      ' between spz.effective_start_date'			      ||
		  ' and spz.effective_end_date' 			      ||
      ' order by sar.vrbl_rt_prfl_id;';
    --
    l_instcolnm_set(0).col_name    := 'vrbl_rt_prfl_id';
    l_instcolnm_set(0).caccol_name := 'id';
    l_instcolnm_set(1).col_name    := 'from_value';
    l_instcolnm_set(1).caccol_name := 'from_value';
    l_instcolnm_set(2).col_name    := 'to_value';
    l_instcolnm_set(2).caccol_name := 'to_value';
    l_instcolnm_set(3).col_name    := 'excld_flag';
    l_instcolnm_set(3).caccol_name := 'excld_flag';
    --
    ben_cache.write_mastDet_Cache
      (p_mastercol_name => 'vrbl_rt_prfl_id'
      ,p_detailcol_name => 'vrbl_rt_prfl_id'
      ,p_lkup_name	=> 'ben_rt_prfl_cache.g_svcarea_lookup'
      ,p_inst_name	=> 'ben_rt_prfl_cache.g_svcarea_instance'
      ,p_lkup_query	=> l_lookup_query
      ,p_inst_query	=> l_inst_query
      ,p_instcolnm_set	=> l_instcolnm_set
      );
    --
  end if;
  --
  -- Cache already populated. Get record set.
  --
  get_cached_data
    (p_vrbl_rt_prfl_id => p_vrbl_rt_prfl_id
    ,p_lookup_name     => 'ben_rt_prfl_cache.g_svcarea_lookup'
    ,p_inst_name       => 'ben_rt_prfl_cache.g_svcarea_instance'
    ,p_inst_set_type   => 'ben_rt_prfl_cache.g_svcarea_inst_tbl'
    ,p_out_inst_name   => 'ben_rt_prfl_cache.g_svcarea_out'
    );
  --
  p_inst_set := g_svcarea_out;
  p_inst_count := g_inst_count;
  --
exception
  --
  when no_data_found then
    --
    p_inst_count := 0;
    hr_utility.set_location('No Service Area found', 90);
    hr_utility.set_location('Leaving : ' || l_proc, 99);
    --
end;
--
-- HOURLY OR SALARIED
--
procedure get_rt_prfl_cache
  (p_vrbl_rt_prfl_id   in number
  ,p_effective_date    in date
  ,p_lf_evt_ocrd_dt    in date
  ,p_business_group_id in number
  ,p_inst_set	       in out NOCOPY ben_rt_prfl_cache.g_hrlyslrd_inst_tbl
  ,p_inst_count        out nocopy number)
is
  --
  l_proc varchar2(80) := g_package || '.get_rt_prfl_cache';
  l_lookup_query long;
  l_inst_query	 long;
  l_instcolnm_set ben_cache.instcolnmtype;
  --
begin
  --
  g_hrlyslrd_out.delete;
  --
  if g_hrlyslrd_lookup.count = 0 then
    --
    -- Cache not populated yet. So populate it now.
    --
    l_lookup_query :=
      'select vrbl_rt_prfl_id, business_group_id'			      ||
       ' from ben_vrbl_rt_prfl_f vpf'					      ||
      ' where business_group_id = ' || to_char(p_business_group_id)	      ||
	' and exists (select null'					      ||
		      ' from ben_hrly_slrd_rt_f hsr'			      ||
		     ' where hsr.vrbl_rt_prfl_id = vpf.vrbl_rt_prfl_id'       ||
		       ' and ' || date_str(p_lf_evt_ocrd_dt,p_effective_date) ||
			     ' between hsr.effective_start_date'	      ||
				 ' and hsr.effective_end_date) '	      ||
	' and ' || date_str(p_lf_evt_ocrd_dt, p_effective_date) 	      ||
	      ' between vpf.effective_start_date and vpf.effective_end_date;';
    --
    l_inst_query :=
      'select hsr.vrbl_rt_prfl_id, hsr.hrly_slrd_cd, hsr.excld_flag'	      ||
       ' from ben_hrly_slrd_rt_f hsr'					      ||
      ' where hsr.business_group_id = ' || to_char(p_business_group_id)       ||
	' and ' || date_str(p_lf_evt_ocrd_dt, p_effective_date) 	      ||
	      ' between hsr.effective_start_date'			      ||
		  ' and hsr.effective_end_date' 			      ||
      ' order by hsr.vrbl_rt_prfl_id;';
    --
    l_instcolnm_set(0).col_name    := 'vrbl_rt_prfl_id';
    l_instcolnm_set(0).caccol_name := 'id';
    l_instcolnm_set(1).col_name    := 'hrly_slrd_cd';
    l_instcolnm_set(1).caccol_name := 'hrly_slrd_cd';
    l_instcolnm_set(2).col_name    := 'excld_flag';
    l_instcolnm_set(2).caccol_name := 'excld_flag';
    --
    ben_cache.write_mastDet_Cache
      (p_mastercol_name => 'vrbl_rt_prfl_id'
      ,p_detailcol_name => 'vrbl_rt_prfl_id'
      ,p_lkup_name	=> 'ben_rt_prfl_cache.g_hrlyslrd_lookup'
      ,p_inst_name	=> 'ben_rt_prfl_cache.g_hrlyslrd_instance'
      ,p_lkup_query	=> l_lookup_query
      ,p_inst_query	=> l_inst_query
      ,p_instcolnm_set	=> l_instcolnm_set
      );
    --
  end if;
  --
  -- Cache already populated. Get record set.
  --
  get_cached_data
    (p_vrbl_rt_prfl_id => p_vrbl_rt_prfl_id
    ,p_lookup_name     => 'ben_rt_prfl_cache.g_hrlyslrd_lookup'
    ,p_inst_name       => 'ben_rt_prfl_cache.g_hrlyslrd_instance'
    ,p_inst_set_type   => 'ben_rt_prfl_cache.g_hrlyslrd_inst_tbl'
    ,p_out_inst_name   => 'ben_rt_prfl_cache.g_hrlyslrd_out'
    );
  --
  p_inst_set := g_hrlyslrd_out;
  p_inst_count := g_inst_count;
  --
exception
  --
  when no_data_found then
    --
    p_inst_count := 0;
    hr_utility.set_location('No Hourly - Salaried found', 90);
    hr_utility.set_location('Leaving : ' || l_proc, 99);
    --
end;
--
-- AGE
--
procedure get_rt_prfl_cache
  (p_vrbl_rt_prfl_id   in number
  ,p_effective_date    in date
  ,p_lf_evt_ocrd_dt    in date
  ,p_business_group_id in number
  ,p_inst_set	       in out NOCOPY ben_rt_prfl_cache.g_age_inst_tbl
  ,p_inst_count        out nocopy number) is
  --
  l_proc varchar2(72) :=  'get_rt_prfl_cache';
  --
  l_instcolnm_set    ben_cache.InstColNmType;
  l_tabdet_set       ben_cache.TabDetType;
  --
  l_torrwnum         pls_integer;
  l_insttorrw_num    pls_integer;
  l_index            pls_integer;
  l_instcolnm_num    pls_integer;
  l_mastertab_name   varchar2(100);
  l_masterpkcol_name varchar2(100);
  l_lkup_name        varchar2(100);
  l_inst_name        varchar2(100);
  --
  l_not_hash_found   boolean;
  --
begin
  --
  -- Populate the global cache
  --
  if g_age_lookup.count = 0 then
    --
    -- Build the cache
    --
    l_mastertab_name            := 'ben_vrbl_rt_prfl_f';
    l_masterpkcol_name          := 'vrbl_rt_prfl_id';
    l_lkup_name                 := 'ben_rt_prfl_cache.g_age_lookup';
    l_inst_name                 := 'ben_rt_prfl_cache.g_age_instance';
    --
    l_tabdet_set(0).tab_name    := 'ben_age_rt_f';
    l_tabdet_set(0).tab_jncolnm := 'age_fctr_id';
    l_tabdet_set(1).tab_name    := 'ben_age_fctr';
    l_tabdet_set(1).tab_datetype := 'nondt';
    --
    l_instcolnm_num := 0;
    --
    l_instcolnm_set(l_instcolnm_num).col_name    := l_masterpkcol_name;
    l_instcolnm_set(l_instcolnm_num).caccol_name := 'vrbl_rt_prfl_id';
    l_instcolnm_set(l_instcolnm_num).col_alias   := 'table1';
    l_instcolnm_set(l_instcolnm_num).col_type    := 'MASTER';
    l_instcolnm_num := l_instcolnm_num+1;
    --
    l_instcolnm_set(l_instcolnm_num).col_name    := 'excld_flag';
    l_instcolnm_set(l_instcolnm_num).caccol_name := 'excld_flag';
    l_instcolnm_set(l_instcolnm_num).col_alias   := 'table1';
    l_instcolnm_set(l_instcolnm_num).col_type    := 'SELECT';
    l_instcolnm_num := l_instcolnm_num+1;
    --
    l_instcolnm_set(l_instcolnm_num).col_name    := 'age_fctr_id';
    l_instcolnm_set(l_instcolnm_num).caccol_name := 'age_fctr_id';
    l_instcolnm_set(l_instcolnm_num).col_alias   := 'table1';
    l_instcolnm_set(l_instcolnm_num).col_type    := 'SELECT';
    l_instcolnm_num := l_instcolnm_num+1;
    --
    l_instcolnm_set(l_instcolnm_num).col_name    := 'mn_age_num';
    l_instcolnm_set(l_instcolnm_num).caccol_name := 'mn_age_num';
    l_instcolnm_set(l_instcolnm_num).col_alias   := 'table2';
    l_instcolnm_set(l_instcolnm_num).col_type    := 'SELECT';
    l_instcolnm_num := l_instcolnm_num+1;
    --
    l_instcolnm_set(l_instcolnm_num).col_name    := 'mx_age_num';
    l_instcolnm_set(l_instcolnm_num).caccol_name := 'mx_age_num';
    l_instcolnm_set(l_instcolnm_num).col_alias   := 'table2';
    l_instcolnm_set(l_instcolnm_num).col_type    := 'SELECT';
    l_instcolnm_num := l_instcolnm_num+1;
    --
    l_instcolnm_set(l_instcolnm_num).col_name    := 'no_mn_age_flag';
    l_instcolnm_set(l_instcolnm_num).caccol_name := 'no_mn_age_flag';
    l_instcolnm_set(l_instcolnm_num).col_alias   := 'table2';
    l_instcolnm_set(l_instcolnm_num).col_type    := 'SELECT';
    l_instcolnm_num := l_instcolnm_num+1;
    --
    l_instcolnm_set(l_instcolnm_num).col_name    := 'no_mx_age_flag';
    l_instcolnm_set(l_instcolnm_num).caccol_name := 'no_mx_age_flag';
    l_instcolnm_set(l_instcolnm_num).col_alias   := 'table2';
    l_instcolnm_set(l_instcolnm_num).col_type    := 'SELECT';
    l_instcolnm_num := l_instcolnm_num+1;
    --
    ben_cache.Write_BGP_Cache
      (p_mastertab_name    => l_mastertab_name
      ,p_masterpkcol_name  => l_masterpkcol_name
      ,p_tabdet_set        => l_tabdet_set
      ,p_table1_name       => null
      ,p_business_group_id => p_business_group_id
      ,p_effective_date    => get_eff_date(p_lf_evt_ocrd_dt, p_effective_date)
      ,p_lkup_name         => l_lkup_name
      ,p_inst_name         => l_inst_name
      ,p_instcolnm_set     => l_instcolnm_set
      );
    --
  end if;
  --
  -- Get the instance details
  --
  l_index := ben_hash_utility.get_hashed_index(p_id => p_vrbl_rt_prfl_id);
  --
  -- Check if hashed value is already allocated
  --
  if g_age_lookup.exists(l_index) then
    --
    -- If it does exist make sure its the right one
    --
    if g_age_lookup(l_index).id <> p_vrbl_rt_prfl_id then
      --
      l_not_hash_found := false;
      --
      -- Loop until un-allocated has value is derived
      --
      while not l_not_hash_found loop
        --
        l_index := ben_hash_utility.get_next_hash_index(p_hash_index => l_index);
        --
        -- Check if the hash index exists, if not we can use it
        --
        if not g_age_lookup.exists(l_index) then
          --
          -- Lets store the hash value in the index
          --
          l_not_hash_found := true;
          exit;
          --
        else
          --
          l_not_hash_found := false;
          --
        end if;
        --
      end loop;
    --
    end if;
    --
  end if;
  --
  l_torrwnum := 0;
  for l_insttorrw_num in g_age_lookup(l_index).starttorele_num ..
    g_age_lookup(l_index).endtorele_num loop
    --
    p_inst_set(l_torrwnum) := g_age_instance(l_insttorrw_num);
    l_torrwnum := l_torrwnum+1;
    --
  end loop;
  --
  p_inst_count := l_torrwnum;
  --
exception
  --
  when no_data_found then
    --
    p_inst_count := 0;
    --
end get_rt_prfl_cache;
--
-- COMP LVL CODE
--
procedure get_rt_prfl_cache
  (p_vrbl_rt_prfl_id   in number
  ,p_effective_date    in date
  ,p_lf_evt_ocrd_dt    in date
  ,p_business_group_id in number
  ,p_inst_set	       in out NOCOPY ben_rt_prfl_cache.g_complvl_inst_tbl
  ,p_inst_count        out nocopy number)
is
  --
  l_proc varchar2(80) := g_package || '.get_rt_prfl_cache';
  l_lookup_query long;
  l_inst_query	 long;
  l_instcolnm_set ben_cache.instcolnmtype;
  --
begin
  --
  g_complvl_out.delete;
  --
  if g_complvl_lookup.count = 0 then
    --
    -- Cache not populated yet. So populate it now. First build master and
    -- detail queries.
    --
    l_lookup_query :=
      'select vrbl_rt_prfl_id, business_group_id'			      ||
       ' from ben_vrbl_rt_prfl_f vpf'					      ||
      ' where business_group_id = ' || to_char(p_business_group_id)	      ||
	' and exists (select null'					      ||
		      ' from ben_comp_lvl_rt_f clr'			      ||
		     ' where clr.vrbl_rt_prfl_id = vpf.vrbl_rt_prfl_id'       ||
		       ' and ' || date_str(p_lf_evt_ocrd_dt,p_effective_date) ||
			     ' between clr.effective_start_date'	      ||
				 ' and clr.effective_end_date) '	      ||
	' and ' || date_str(p_lf_evt_ocrd_dt, p_effective_date) 	      ||
	      ' between vpf.effective_start_date and vpf.effective_end_date;';
    --
    l_inst_query :=
      'select clr.vrbl_rt_prfl_id, clf.mn_comp_val, clf.mx_comp_val,'	      ||
	    ' clr.comp_lvl_fctr_id, clr.excld_flag, no_mn_comp_flag, no_mx_comp_flag'				||
       ' from ben_comp_lvl_fctr clf, ben_comp_lvl_rt_f clr'		      ||
      ' where clr.business_group_id = ' || to_char(p_business_group_id)       ||
	' and clr.comp_lvl_fctr_id = clf.comp_lvl_fctr_id'		      ||
	' and ' || date_str(p_lf_evt_ocrd_dt, p_effective_date) 	      ||
	      ' between clr.effective_start_date'			      ||
		  ' and clr.effective_end_date' 			      ||
      ' order by clr.vrbl_rt_prfl_id;';
    --
    l_instcolnm_set(0).col_name    := 'vrbl_rt_prfl_id';
    l_instcolnm_set(0).caccol_name := 'id';
    l_instcolnm_set(1).col_name    := 'mn_comp_val';
    l_instcolnm_set(1).caccol_name := 'mn_comp_val';
    l_instcolnm_set(2).col_name    := 'mx_comp_val';
    l_instcolnm_set(2).caccol_name := 'mx_comp_val';
    l_instcolnm_set(3).col_name    := 'comp_lvl_fctr_id';
    l_instcolnm_set(3).caccol_name := 'comp_lvl_fctr_id';
    l_instcolnm_set(4).col_name    := 'excld_flag';
    l_instcolnm_set(4).caccol_name := 'excld_flag';
    l_instcolnm_set(5).col_name    := 'no_mn_comp_flag';
    l_instcolnm_set(5).caccol_name := 'no_mn_comp_flag';
    l_instcolnm_set(6).col_name    := 'no_mx_comp_flag';
    l_instcolnm_set(6).caccol_name := 'no_mx_comp_flag';
    --
    ben_cache.write_mastDet_Cache
      (p_mastercol_name => 'vrbl_rt_prfl_id'
      ,p_detailcol_name => 'vrbl_rt_prfl_id'
      ,p_lkup_name	=> 'ben_rt_prfl_cache.g_complvl_lookup'
      ,p_inst_name	=> 'ben_rt_prfl_cache.g_complvl_instance'
      ,p_lkup_query	=> l_lookup_query
      ,p_inst_query	=> l_inst_query
      ,p_instcolnm_set	=> l_instcolnm_set
      );
    --
  end if;
  --
  -- Cache already populated. Get record set.
  --
  get_cached_data
    (p_vrbl_rt_prfl_id => p_vrbl_rt_prfl_id
    ,p_lookup_name     => 'ben_rt_prfl_cache.g_complvl_lookup'
    ,p_inst_name       => 'ben_rt_prfl_cache.g_complvl_instance'
    ,p_inst_set_type   => 'ben_rt_prfl_cache.g_complvl_inst_tbl'
    ,p_out_inst_name   => 'ben_rt_prfl_cache.g_complvl_out'
    );
  --
  p_inst_set := g_complvl_out;
  p_inst_count := g_inst_count;
  --
exception
  --
  when no_data_found then
    --
    p_inst_count := 0;
    hr_utility.set_location('No Comp Lvl Code found', 90);
    hr_utility.set_location('Leaving : ' || l_proc, 99);
    --
end;
--
-- LOS
--
procedure get_rt_prfl_cache
  (p_vrbl_rt_prfl_id   in number
  ,p_effective_date    in date
  ,p_lf_evt_ocrd_dt    in date
  ,p_business_group_id in number
  ,p_inst_set	       in out NOCOPY ben_rt_prfl_cache.g_los_inst_tbl
  ,p_inst_count        out nocopy number) is
  --
  l_proc varchar2(72) :=  'get_rt_prfl_cache';
  --
  l_instcolnm_set    ben_cache.InstColNmType;
  l_tabdet_set       ben_cache.TabDetType;
  --
  l_torrwnum         pls_integer;
  l_insttorrw_num    pls_integer;
  l_index            pls_integer;
  l_instcolnm_num    pls_integer;
  l_mastertab_name   varchar2(100);
  l_masterpkcol_name varchar2(100);
  l_lkup_name        varchar2(100);
  l_inst_name        varchar2(100);
  --
  l_not_hash_found   boolean;
  --
begin
  --
  -- Populate the global cache
  --
  if g_los_lookup.count = 0 then
    --
    -- Build the cache
    --
    l_mastertab_name            := 'ben_vrbl_rt_prfl_f';
    l_masterpkcol_name          := 'vrbl_rt_prfl_id';
    l_lkup_name                 := 'ben_rt_prfl_cache.g_los_lookup';
    l_inst_name                 := 'ben_rt_prfl_cache.g_los_instance';
    --
    l_tabdet_set(0).tab_name    := 'ben_los_rt_f';
    l_tabdet_set(0).tab_jncolnm := 'los_fctr_id';
    l_tabdet_set(1).tab_name    := 'ben_los_fctr';
    l_tabdet_set(1).tab_datetype := 'nondt';
    --
    l_instcolnm_num := 0;
    --
    l_instcolnm_set(l_instcolnm_num).col_name    := l_masterpkcol_name;
    l_instcolnm_set(l_instcolnm_num).caccol_name := 'vrbl_rt_prfl_id';
    l_instcolnm_set(l_instcolnm_num).col_alias   := 'table1';
    l_instcolnm_set(l_instcolnm_num).col_type    := 'MASTER';
    l_instcolnm_num := l_instcolnm_num+1;
    --
    l_instcolnm_set(l_instcolnm_num).col_name    := 'excld_flag';
    l_instcolnm_set(l_instcolnm_num).caccol_name := 'excld_flag';
    l_instcolnm_set(l_instcolnm_num).col_alias   := 'table1';
    l_instcolnm_set(l_instcolnm_num).col_type    := 'SELECT';
    l_instcolnm_num := l_instcolnm_num+1;
    --
    l_instcolnm_set(l_instcolnm_num).col_name    := 'los_fctr_id';
    l_instcolnm_set(l_instcolnm_num).caccol_name := 'los_fctr_id';
    l_instcolnm_set(l_instcolnm_num).col_alias   := 'table1';
    l_instcolnm_set(l_instcolnm_num).col_type    := 'SELECT';
    l_instcolnm_num := l_instcolnm_num+1;
    --
    l_instcolnm_set(l_instcolnm_num).col_name    := 'mn_los_num';
    l_instcolnm_set(l_instcolnm_num).caccol_name := 'mn_los_num';
    l_instcolnm_set(l_instcolnm_num).col_alias   := 'table2';
    l_instcolnm_set(l_instcolnm_num).col_type    := 'SELECT';
    l_instcolnm_num := l_instcolnm_num+1;
    --
    l_instcolnm_set(l_instcolnm_num).col_name    := 'mx_los_num';
    l_instcolnm_set(l_instcolnm_num).caccol_name := 'mx_los_num';
    l_instcolnm_set(l_instcolnm_num).col_alias   := 'table2';
    l_instcolnm_set(l_instcolnm_num).col_type    := 'SELECT';
    l_instcolnm_num := l_instcolnm_num+1;
    --
    l_instcolnm_set(l_instcolnm_num).col_name    := 'no_mn_los_num_apls_flag';
    l_instcolnm_set(l_instcolnm_num).caccol_name := 'no_mn_los_num_apls_flag';
    l_instcolnm_set(l_instcolnm_num).col_alias   := 'table2';
    l_instcolnm_set(l_instcolnm_num).col_type    := 'SELECT';
    l_instcolnm_num := l_instcolnm_num+1;
    --
    l_instcolnm_set(l_instcolnm_num).col_name    := 'no_mx_los_num_apls_flag';
    l_instcolnm_set(l_instcolnm_num).caccol_name := 'no_mx_los_num_apls_flag';
    l_instcolnm_set(l_instcolnm_num).col_alias   := 'table2';
    l_instcolnm_set(l_instcolnm_num).col_type    := 'SELECT';
    l_instcolnm_num := l_instcolnm_num+1;
    --
    ben_cache.Write_BGP_Cache
      (p_mastertab_name    => l_mastertab_name
      ,p_masterpkcol_name  => l_masterpkcol_name
      ,p_tabdet_set        => l_tabdet_set
      ,p_table1_name       => null
      ,p_business_group_id => p_business_group_id
      ,p_effective_date    => get_eff_date(p_lf_evt_ocrd_dt, p_effective_date)
      ,p_lkup_name         => l_lkup_name
      ,p_inst_name         => l_inst_name
      ,p_instcolnm_set     => l_instcolnm_set
      );
    --
  end if;
  --
  -- Get the instance details
  --
  l_index := ben_hash_utility.get_hashed_index(p_id => p_vrbl_rt_prfl_id);
  --
  -- Check if hashed value is already allocated
  --
  if g_los_lookup.exists(l_index) then
    --
    -- If it does exist make sure its the right one
    --
    if g_los_lookup(l_index).id <> p_vrbl_rt_prfl_id then
      --
      l_not_hash_found := false;
      --
      -- Loop until un-allocated has value is derived
      --
      while not l_not_hash_found loop
        --
        l_index := ben_hash_utility.get_next_hash_index(p_hash_index => l_index);
        --
        -- Check if the hash index exists, if not we can use it
        --
        if not g_los_lookup.exists(l_index) then
          --
          -- Lets store the hash value in the index
          --
          l_not_hash_found := true;
          exit;
          --
        else
          --
          l_not_hash_found := false;
          --
        end if;
        --
      end loop;
    --
    end if;
    --
  end if;
  --
  l_torrwnum := 0;
  for l_insttorrw_num in g_los_lookup(l_index).starttorele_num ..
    g_los_lookup(l_index).endtorele_num loop
    --
    p_inst_set(l_torrwnum) := g_los_instance(l_insttorrw_num);
    l_torrwnum := l_torrwnum+1;
    --
  end loop;
  --
  p_inst_count := l_torrwnum;
  --
exception
  --
  when no_data_found then
    --
    p_inst_count := 0;
    --
end get_rt_prfl_cache;
/*
--
-- LOS
--
procedure get_rt_prfl_cache
  (p_vrbl_rt_prfl_id   in number
  ,p_effective_date    in date
  ,p_lf_evt_ocrd_dt    in date
  ,p_business_group_id in number
  ,p_inst_set	       in out NOCOPY ben_rt_prfl_cache.g_los_inst_tbl
  ,p_inst_count        out nocopy number)
is
  --
  l_proc varchar2(80) := g_package || '.get_rt_prfl_cache';
  l_lookup_query long;
  l_inst_query	 long;
  l_instcolnm_set ben_cache.instcolnmtype;
  --
begin
  --
  g_los_out.delete;
  --
  if g_los_lookup.count = 0 then
    --
    -- Cache not populated yet. So populate it now. First build master and
    -- detail queries.
    --
    l_lookup_query :=
      'select vrbl_rt_prfl_id, business_group_id'			      ||
       ' from ben_vrbl_rt_prfl_f vpf'					      ||
      ' where business_group_id = ' || to_char(p_business_group_id)	      ||
	' and exists (select null'					      ||
		      ' from ben_los_rt_f lsr'				      ||
		     ' where lsr.vrbl_rt_prfl_id = vpf.vrbl_rt_prfl_id'       ||
		       ' and ' || date_str(p_lf_evt_ocrd_dt,p_effective_date) ||
			     ' between lsr.effective_start_date'	      ||
				 ' and lsr.effective_end_date) '	      ||
	' and ' || date_str(p_lf_evt_ocrd_dt, p_effective_date) 	      ||
	      ' between vpf.effective_start_date and vpf.effective_end_date;';
    --
    l_inst_query :=
      'select lsr.vrbl_rt_prfl_id, lsf.mn_los_num, lsf.mx_los_num,'	       ||
	    ' lsr.excld_flag, no_mn_los_num_apls_flag, no_mx_los_num_apls_flag, '||
	    ' lsf.los_fctr_id'						      ||
     ' from ben_los_fctr lsf, ben_los_rt_f lsr' 			       ||
      ' where lsr.business_group_id = ' || to_char(p_business_group_id)       ||
	' and lsr.los_fctr_id = lsf.los_fctr_id'			      ||
	' and ' || date_str(p_lf_evt_ocrd_dt, p_effective_date) 	      ||
	      ' between lsr.effective_start_date'			      ||
		  ' and lsr.effective_end_date' 			      ||
      ' order by lsr.vrbl_rt_prfl_id;';
    --
    l_instcolnm_set(0).col_name    := 'vrbl_rt_prfl_id';
    l_instcolnm_set(0).caccol_name := 'id';
    l_instcolnm_set(1).col_name    := 'mn_los_num';
    l_instcolnm_set(1).caccol_name := 'mn_los_num';
    l_instcolnm_set(2).col_name    := 'mx_los_num';
    l_instcolnm_set(2).caccol_name := 'mx_los_num';
    l_instcolnm_set(3).col_name    := 'excld_flag';
    l_instcolnm_set(3).caccol_name := 'excld_flag';
    l_instcolnm_set(4).col_name    := 'no_mn_los_num_apls_flag';
    l_instcolnm_set(4).caccol_name := 'no_mn_los_num_apls_flag';
    l_instcolnm_set(5).col_name    := 'no_mx_los_num_apls_flag';
    l_instcolnm_set(5).caccol_name := 'no_mx_los_num_apls_flag';
    l_instcolnm_set(6).col_name    := 'los_fctr_id';
    l_instcolnm_set(6).caccol_name := 'los_fctr_id';
    --
    ben_cache.write_mastDet_Cache
      (p_mastercol_name => 'vrbl_rt_prfl_id'
      ,p_detailcol_name => 'vrbl_rt_prfl_id'
      ,p_lkup_name	=> 'ben_rt_prfl_cache.g_los_lookup'
      ,p_inst_name	=> 'ben_rt_prfl_cache.g_los_instance'
      ,p_lkup_query	=> l_lookup_query
      ,p_inst_query	=> l_inst_query
      ,p_instcolnm_set	=> l_instcolnm_set
      );
    --
  end if;
  --
  -- Cache already populated. Get record set.
  --
  get_cached_data
    (p_vrbl_rt_prfl_id => p_vrbl_rt_prfl_id
    ,p_lookup_name     => 'ben_rt_prfl_cache.g_los_lookup'
    ,p_inst_name       => 'ben_rt_prfl_cache.g_los_instance'
    ,p_inst_set_type   => 'ben_rt_prfl_cache.g_los_inst_tbl'
    ,p_out_inst_name   => 'ben_rt_prfl_cache.g_los_out'
    );
  --
  p_inst_set := g_los_out;
  p_inst_count := g_inst_count;
  --
exception
  --
  when no_data_found then
    --
    p_inst_count := 0;
    hr_utility.set_location('No Length of Service found', 90);
    hr_utility.set_location('Leaving : ' || l_proc, 99);
    --
end;
*/
--
-- CMBN AGE LOS
--
procedure get_rt_prfl_cache
  (p_vrbl_rt_prfl_id   in number
  ,p_effective_date    in date
  ,p_lf_evt_ocrd_dt    in date
  ,p_business_group_id in number
  ,p_inst_set	       in out NOCOPY ben_rt_prfl_cache.g_age_los_inst_tbl
  ,p_inst_count        out nocopy number)
is
  --
  l_proc varchar2(80) := g_package || '.get_rt_prfl_cache';
  l_lookup_query long;
  l_inst_query	 long;
  l_instcolnm_set ben_cache.instcolnmtype;
  --
begin
  --
  g_age_los_out.delete;
  --
  if g_age_los_lookup.count = 0 then
    --
    -- Cache not populated yet. So populate it now. First build master and
    -- detail queries.
    --
    l_lookup_query :=
      'select vrbl_rt_prfl_id, business_group_id'			      ||
       ' from ben_vrbl_rt_prfl_f vpf'					      ||
      ' where business_group_id = ' || to_char(p_business_group_id)	      ||
	' and exists (select null'					      ||
		      ' from ben_cmbn_age_los_rt_f cmr' 		      ||
		     ' where cmr.vrbl_rt_prfl_id = vpf.vrbl_rt_prfl_id'       ||
		       ' and ' || date_str(p_lf_evt_ocrd_dt,p_effective_date) ||
			     ' between cmr.effective_start_date'	      ||
				 ' and cmr.effective_end_date) '	      ||
	' and ' || date_str(p_lf_evt_ocrd_dt, p_effective_date) 	      ||
	      ' between vpf.effective_start_date and vpf.effective_end_date;';
    --
    l_inst_query :=
      'select cmr.vrbl_rt_prfl_id, cla.cmbnd_min_val, cla.cmbnd_max_val,'     ||
	    ' cmr.excld_flag, cla.cmbn_age_los_fctr_id' 		      ||
       ' from ben_cmbn_age_los_fctr cla, ben_cmbn_age_los_rt_f cmr'	      ||
      ' where cmr.business_group_id = ' || to_char(p_business_group_id)       ||
	' and cmr.cmbn_age_los_fctr_id = cla.cmbn_age_los_fctr_id'	      ||
	' and ' || date_str(p_lf_evt_ocrd_dt, p_effective_date) 	      ||
	      ' between cmr.effective_start_date'			      ||
		  ' and cmr.effective_end_date' 			      ||
      ' order by cmr.vrbl_rt_prfl_id;';
    --
    l_instcolnm_set(0).col_name    := 'vrbl_rt_prfl_id';
    l_instcolnm_set(0).caccol_name := 'id';
    l_instcolnm_set(1).col_name    := 'cmbnd_min_val';
    l_instcolnm_set(1).caccol_name := 'cmbnd_min_val';
    l_instcolnm_set(2).col_name    := 'cmbnd_max_val';
    l_instcolnm_set(2).caccol_name := 'cmbnd_max_val';
    l_instcolnm_set(3).col_name    := 'excld_flag';
    l_instcolnm_set(3).caccol_name := 'excld_flag';
    l_instcolnm_set(4).col_name    := 'cmbn_age_los_fctr_id';
    l_instcolnm_set(4).caccol_name := 'cmbn_age_los_fctr_id';
    --
    ben_cache.write_mastDet_Cache
      (p_mastercol_name => 'vrbl_rt_prfl_id'
      ,p_detailcol_name => 'vrbl_rt_prfl_id'
      ,p_lkup_name	=> 'ben_rt_prfl_cache.g_age_los_lookup'
      ,p_inst_name	=> 'ben_rt_prfl_cache.g_age_los_instance'
      ,p_lkup_query	=> l_lookup_query
      ,p_inst_query	=> l_inst_query
      ,p_instcolnm_set	=> l_instcolnm_set
      );
    --
  end if;
  --
  -- Cache already populated. Get record set.
  --
  get_cached_data
    (p_vrbl_rt_prfl_id => p_vrbl_rt_prfl_id
    ,p_lookup_name     => 'ben_rt_prfl_cache.g_age_los_lookup'
    ,p_inst_name       => 'ben_rt_prfl_cache.g_age_los_instance'
    ,p_inst_set_type   => 'ben_rt_prfl_cache.g_age_los_inst_tbl'
    ,p_out_inst_name   => 'ben_rt_prfl_cache.g_age_los_out'
    );
  --
  p_inst_set := g_age_los_out;
  p_inst_count := g_inst_count;
  --
exception
  --
  when no_data_found then
    --
    p_inst_count := 0;
    hr_utility.set_location('No Cmbn Age Los found', 90);
    hr_utility.set_location('Leaving : ' || l_proc, 99);
    --
end;
------------------------------------------------------------------------
-- TOTAL PARTICIPANTS
------------------------------------------------------------------------
procedure get_rt_prfl_cache
  (p_vrbl_rt_prfl_id   in number
  ,p_effective_date    in date
  ,p_lf_evt_ocrd_dt    in date
  ,p_business_group_id in number
  ,p_inst_set	       in out NOCOPY ben_rt_prfl_cache.g_ttl_prtt_inst_tbl
  ,p_inst_count        out nocopy number) is
  --
  l_proc varchar2(72) :=  'get_rt_prfl_cache';
  --
  l_instcolnm_set    ben_cache.InstColNmType;
  --
  l_torrwnum         pls_integer;
  l_insttorrw_num    pls_integer;
  l_index            pls_integer;
  l_instcolnm_num    pls_integer;
  l_mastertab_name   varchar2(100);
  l_masterpkcol_name varchar2(100);
  l_lkup_name        varchar2(100);
  l_inst_name        varchar2(100);
  --
  l_not_hash_found   boolean;
  --
begin
  --
  -- Populate the global cache
  --
  if g_ttl_prtt_lookup.count = 0 then
    --
    -- Build the cache
    --
    l_mastertab_name            := 'ben_vrbl_rt_prfl_f';
    l_masterpkcol_name          := 'vrbl_rt_prfl_id';
    l_lkup_name                 := 'ben_rt_prfl_cache.g_ttl_prtt_lookup';
    l_inst_name                 := 'ben_rt_prfl_cache.g_ttl_prtt_instance';
    --
    l_instcolnm_num := 0;
    --
    l_instcolnm_set(l_instcolnm_num).col_name    := l_masterpkcol_name;
    l_instcolnm_set(l_instcolnm_num).caccol_name := 'vrbl_rt_prfl_id';
    l_instcolnm_set(l_instcolnm_num).col_alias   := 'table1';
    l_instcolnm_set(l_instcolnm_num).col_type    := 'MASTER';
    l_instcolnm_num := l_instcolnm_num+1;
    --
    l_instcolnm_set(l_instcolnm_num).col_name    := 'mn_prtt_num';
    l_instcolnm_set(l_instcolnm_num).caccol_name := 'mn_prtt_num';
    l_instcolnm_set(l_instcolnm_num).col_alias   := 'table1';
    l_instcolnm_num := l_instcolnm_num+1;
    --
    l_instcolnm_set(l_instcolnm_num).col_name    := 'mx_prtt_num';
    l_instcolnm_set(l_instcolnm_num).caccol_name := 'mx_prtt_num';
    l_instcolnm_set(l_instcolnm_num).col_alias   := 'table1';
    l_instcolnm_num := l_instcolnm_num+1;
    --
    ben_cache.Write_BGP_Cache
      (p_mastertab_name    => l_mastertab_name
      ,p_masterpkcol_name  => l_masterpkcol_name
      ,p_table1_name       => 'ben_ttl_prtt_rt_f'
      ,p_business_group_id => p_business_group_id
      ,p_effective_date    => get_eff_date(p_lf_evt_ocrd_dt, p_effective_date)
      ,p_lkup_name         => l_lkup_name
      ,p_inst_name         => l_inst_name
      ,p_instcolnm_set     => l_instcolnm_set
      );
    --
  end if;
  --
  -- Get the instance details
  --
  l_index := ben_hash_utility.get_hashed_index(p_id => p_vrbl_rt_prfl_id);
  --
  -- Check if hashed value is already allocated
  --
  if g_ttl_prtt_lookup.exists(l_index) then
    --
    -- If it does exist make sure its the right one
    --
    if g_ttl_prtt_lookup(l_index).id <> p_vrbl_rt_prfl_id then
      --
      l_not_hash_found := false;
      --
      -- Loop until un-allocated has value is derived
      --
      while not l_not_hash_found loop
        --
        l_index := ben_hash_utility.get_next_hash_index(p_hash_index => l_index);
        --
        -- Check if the hash index exists, if not we can use it
        --
        if not g_ttl_prtt_lookup.exists(l_index) then
          --
          -- Lets store the hash value in the index
          --
          l_not_hash_found := true;
          exit;
          --
        else
          --
          l_not_hash_found := false;
          --
        end if;
        --
      end loop;
    --
    end if;
    --
  end if;
  --
  l_torrwnum := 0;
  for l_insttorrw_num in g_ttl_prtt_lookup(l_index).starttorele_num ..
    g_ttl_prtt_lookup(l_index).endtorele_num loop
    --
    p_inst_set(l_torrwnum) := g_ttl_prtt_instance(l_insttorrw_num);
    l_torrwnum := l_torrwnum+1;
    --
  end loop;
  --
  p_inst_count := l_torrwnum;
  --
exception
  --
  when no_data_found then
    --
    p_inst_count := 0;
    --
end get_rt_prfl_cache;
------------------------------------------------------------------------
-- TOTAL COVERAGE
------------------------------------------------------------------------
procedure get_rt_prfl_cache
  (p_vrbl_rt_prfl_id   in number
  ,p_effective_date    in date
  ,p_lf_evt_ocrd_dt    in date
  ,p_business_group_id in number
  ,p_inst_set	       in out NOCOPY ben_rt_prfl_cache.g_ttl_cvg_inst_tbl
  ,p_inst_count        out nocopy number)
is
  --
  l_proc varchar2(80) := g_package || '.get_rt_prfl_cache, ttl cvg';
  l_lookup_query long;
  l_inst_query	 long;
  l_instcolnm_set ben_cache.instcolnmtype;
  --
begin
  g_ttl_cvg_out.delete;
  --
  if g_ttl_cvg_lookup.count = 0 then

    --
    -- Cache not populated yet. So populate it now.
    --
    l_lookup_query :=
      'select vrbl_rt_prfl_id, business_group_id'			      ||
       ' from ben_vrbl_rt_prfl_f vpf'					      ||
      ' where business_group_id = ' || to_char(p_business_group_id)	      ||
	' and exists (select null'					      ||
		      ' from ben_ttl_cvg_vol_rt_f bgr'			      ||
		     ' where bgr.vrbl_rt_prfl_id = vpf.vrbl_rt_prfl_id'       ||
		       ' and ' || date_str(p_lf_evt_ocrd_dt,p_effective_date) ||
			     ' between bgr.effective_start_date'	      ||
				 ' and bgr.effective_end_date) '	      ||
	' and ' || date_str(p_lf_evt_ocrd_dt, p_effective_date) 	      ||
	      ' between vpf.effective_start_date and vpf.effective_end_date;';
    --
    l_inst_query :=
      'select bgr.vrbl_rt_prfl_id, bgr.mn_cvg_vol_amt, bgr.mx_cvg_vol_amt' ||
       ' from ben_ttl_cvg_vol_rt_f bgr' 				       ||
      ' where bgr.business_group_id = ' || to_char(p_business_group_id)    ||
	' and ' || date_str(p_lf_evt_ocrd_dt, p_effective_date) 	   ||
	      ' between bgr.effective_start_date'			   ||
		  ' and bgr.effective_end_date' 			   ||
      ' order by bgr.vrbl_rt_prfl_id;';
    --
    l_instcolnm_set(0).col_name    := 'vrbl_rt_prfl_id';
    l_instcolnm_set(0).caccol_name := 'id';
    l_instcolnm_set(1).col_name    := 'mn_cvg_vol_amt';
    l_instcolnm_set(1).caccol_name := 'mn_cvg_vol_amt';
    l_instcolnm_set(2).col_name    := 'mx_cvg_vol_amt';
    l_instcolnm_set(2).caccol_name := 'mx_cvg_vol_amt';

    ben_cache.write_mastDet_Cache
      (p_mastercol_name => 'vrbl_rt_prfl_id'
      ,p_detailcol_name => 'vrbl_rt_prfl_id'
      ,p_lkup_name	=> 'ben_rt_prfl_cache.g_ttl_cvg_lookup'
      ,p_inst_name	=> 'ben_rt_prfl_cache.g_ttl_cvg_instance'
      ,p_lkup_query	=> l_lookup_query
      ,p_inst_query	=> l_inst_query
      ,p_instcolnm_set	=> l_instcolnm_set
      );
    --
  end if;
  --
  -- Cache already populated. Get record set.
  --
  get_cached_data
    (p_vrbl_rt_prfl_id => p_vrbl_rt_prfl_id
    ,p_lookup_name     => 'ben_rt_prfl_cache.g_ttl_cvg_lookup'
    ,p_inst_name       => 'ben_rt_prfl_cache.g_ttl_cvg_instance'
    ,p_inst_set_type   => 'ben_rt_prfl_cache.g_ttl_cvg_inst_tbl'
    ,p_out_inst_name   => 'ben_rt_prfl_cache.g_ttl_cvg_out'
    );
  --
  p_inst_set := g_ttl_cvg_out;
  p_inst_count := g_inst_count;

  --
exception
  --
  when no_data_found then
    --
    p_inst_count := 0;
    hr_utility.set_location('No data found - Coverage', 10);
    hr_utility.set_location('Leaving : ' || l_proc, 99);
    --
end;


------------------------------------------------------------------------
-- JOB
------------------------------------------------------------------------
procedure get_rt_prfl_cache
  (p_vrbl_rt_prfl_id   in number
  ,p_effective_date    in date
  ,p_lf_evt_ocrd_dt    in date
  ,p_business_group_id in number
  ,p_inst_set	       in out NOCOPY ben_rt_prfl_cache.g_job_inst_tbl
  ,p_inst_count        out nocopy number)
is
  --
  l_proc varchar2(80) := g_package || '.get_rt_prfl_cache';
  l_lookup_query long;
  l_inst_query	 long;
  l_instcolnm_set ben_cache.instcolnmtype;
  --
begin
  --
  g_job_out.delete;
  --
  if g_job_lookup.count = 0 then
    --
    -- Cache not populated yet. So populate it now.
    --
    l_lookup_query :=
      'select vrbl_rt_prfl_id, business_group_id'			      ||
       ' from ben_vrbl_rt_prfl_f vpf'					      ||
      ' where business_group_id = ' || to_char(p_business_group_id)	      ||
	' and exists (select null'					      ||
		      ' from ben_job_rt_f jrt'			              ||
		      ' where jrt.vrbl_rt_prfl_id = vpf.vrbl_rt_prfl_id'      ||
		      ' and ' || date_str(p_lf_evt_ocrd_dt,p_effective_date)  ||
			     ' between jrt.effective_start_date'	      ||
				 ' and jrt.effective_end_date) '	      ||
	' and ' || date_str(p_lf_evt_ocrd_dt, p_effective_date) 	      ||
	      ' between vpf.effective_start_date and vpf.effective_end_date;';
    --
    l_inst_query :=
      'select jrt.vrbl_rt_prfl_id, jrt.job_id, jrt.excld_flag'	   ||
       ' from ben_job_rt_f jrt'					   ||
      ' where jrt.business_group_id = ' || to_char(p_business_group_id)    ||
	' and ' || date_str(p_lf_evt_ocrd_dt, p_effective_date) 	   ||
	      ' between jrt.effective_start_date'			   ||
		  ' and jrt.effective_end_date' 			   ||
      ' order by jrt.vrbl_rt_prfl_id;';
    --
    l_instcolnm_set(0).col_name    := 'vrbl_rt_prfl_id';
    l_instcolnm_set(0).caccol_name := 'id';
    l_instcolnm_set(1).col_name    := 'job_id';
    l_instcolnm_set(1).caccol_name := 'job_id';
    l_instcolnm_set(2).col_name    := 'excld_flag';
    l_instcolnm_set(2).caccol_name := 'excld_flag';
    --
    ben_cache.write_mastDet_Cache
      (p_mastercol_name => 'vrbl_rt_prfl_id'
      ,p_detailcol_name => 'vrbl_rt_prfl_id'
      ,p_lkup_name	=> 'ben_rt_prfl_cache.g_job_lookup'
      ,p_inst_name	=> 'ben_rt_prfl_cache.g_job_instance'
      ,p_lkup_query	=> l_lookup_query
      ,p_inst_query	=> l_inst_query
      ,p_instcolnm_set	=> l_instcolnm_set
      );
    --
  end if;
  --
  -- Cache already populated. Get record set.
  --
  get_cached_data
    (p_vrbl_rt_prfl_id => p_vrbl_rt_prfl_id
    ,p_lookup_name     => 'ben_rt_prfl_cache.g_job_lookup'
    ,p_inst_name       => 'ben_rt_prfl_cache.g_job_instance'
    ,p_inst_set_type   => 'ben_rt_prfl_cache.g_job_inst_tbl'
    ,p_out_inst_name   => 'ben_rt_prfl_cache.g_job_out'
    );
  --
  p_inst_set := g_job_out;
  p_inst_count := g_inst_count;
  --
exception
  --
  when no_data_found then
    --
    p_inst_count := 0;
    hr_utility.set_location('No Job found', 90);
    hr_utility.set_location('Leaving : ' || l_proc, 99);
    --
end;

------------------------------------------------------------------------
-- Opted for Medicare
------------------------------------------------------------------------
procedure get_rt_prfl_cache
  (p_vrbl_rt_prfl_id   in number
  ,p_effective_date    in date
  ,p_lf_evt_ocrd_dt    in date
  ,p_business_group_id in number
  ,p_inst_set	       in out NOCOPY ben_rt_prfl_cache.g_optd_mdcr_inst_tbl
  ,p_inst_count        out nocopy number)
is
  --
  l_proc varchar2(80) := g_package || '.get_rt_prfl_cache';
  l_lookup_query long;
  l_inst_query	 long;
  l_instcolnm_set ben_cache.instcolnmtype;
  --
begin
  --
  g_optd_mdcr_out.delete;
  --
  if g_optd_mdcr_lookup.count = 0 then
    --
    -- Cache not populated yet. So populate it now.
    --
    l_lookup_query :=
      'select vrbl_rt_prfl_id, business_group_id'			      ||
       ' from ben_vrbl_rt_prfl_f vpf'					      ||
      ' where business_group_id = ' || to_char(p_business_group_id)	      ||
	' and exists (select null'					      ||
		      ' from  ben_optd_mdcr_rt_f omr'			      ||
		      ' where omr.vrbl_rt_prfl_id = vpf.vrbl_rt_prfl_id'      ||
		      ' and ' || date_str(p_lf_evt_ocrd_dt,p_effective_date)  ||
			     ' between omr.effective_start_date'	      ||
				 ' and omr.effective_end_date) '	      ||
	' and ' || date_str(p_lf_evt_ocrd_dt, p_effective_date) 	      ||
	      ' between vpf.effective_start_date and vpf.effective_end_date;';
    --
    l_inst_query :=
      'select omr.vrbl_rt_prfl_id, omr.optd_mdcr_flag'	   		   ||
       ' from ben_optd_mdcr_rt_f omr'    				   ||
      ' where omr.business_group_id = ' || to_char(p_business_group_id)    ||
	' and ' || date_str(p_lf_evt_ocrd_dt, p_effective_date) 	   ||
	      ' between omr.effective_start_date'			   ||
		  ' and omr.effective_end_date' 			   ||
      ' order by omr.vrbl_rt_prfl_id;';
    --
    l_instcolnm_set(0).col_name    := 'vrbl_rt_prfl_id';
    l_instcolnm_set(0).caccol_name := 'id';
    l_instcolnm_set(1).col_name    := 'optd_mdcr_flag';
    l_instcolnm_set(1).caccol_name := 'optd_mdcr_flag';
    --
    ben_cache.write_mastDet_Cache
      (p_mastercol_name => 'vrbl_rt_prfl_id'
      ,p_detailcol_name => 'vrbl_rt_prfl_id'
      ,p_lkup_name	=> 'ben_rt_prfl_cache.g_optd_mdcr_lookup'
      ,p_inst_name	=> 'ben_rt_prfl_cache.g_optd_mdcr_instance'
      ,p_lkup_query	=> l_lookup_query
      ,p_inst_query	=> l_inst_query
      ,p_instcolnm_set	=> l_instcolnm_set
      );
    --
  end if;
  --
  -- Cache already populated. Get record set.
  --
  get_cached_data
    (p_vrbl_rt_prfl_id => p_vrbl_rt_prfl_id
    ,p_lookup_name     => 'ben_rt_prfl_cache.g_optd_mdcr_lookup'
    ,p_inst_name       => 'ben_rt_prfl_cache.g_optd_mdcr_instance'
    ,p_inst_set_type   => 'ben_rt_prfl_cache.g_optd_mdcr_inst_tbl'
    ,p_out_inst_name   => 'ben_rt_prfl_cache.g_optd_mdcr_out'
    );
  --
  p_inst_set := g_optd_mdcr_out;
  p_inst_count := g_inst_count;
  --
exception
  --
  when no_data_found then
    --
    p_inst_count := 0;
    hr_utility.set_location('No Opted for Medicare found', 90);
    hr_utility.set_location('Leaving : ' || l_proc, 99);
    --
end;
------------------------------------------------------------------------
-- Leaving Reason
------------------------------------------------------------------------
procedure get_rt_prfl_cache
  (p_vrbl_rt_prfl_id   in number
  ,p_effective_date    in date
  ,p_lf_evt_ocrd_dt    in date
  ,p_business_group_id in number
  ,p_inst_set	       in out NOCOPY ben_rt_prfl_cache.g_lvg_rsn_inst_tbl
  ,p_inst_count        out nocopy number)
is
  --
  l_proc varchar2(80) := g_package || '.get_rt_prfl_cache';
  l_lookup_query long;
  l_inst_query	 long;
  l_instcolnm_set ben_cache.instcolnmtype;
  --
begin
  --
  g_lvg_rsn_out.delete;
  --
  if g_lvg_rsn_lookup.count = 0 then
    --
    -- Cache not populated yet. So populate it now.
    --
    l_lookup_query :=
      'select vrbl_rt_prfl_id, business_group_id'			      ||
       ' from ben_vrbl_rt_prfl_f vpf'					      ||
      ' where business_group_id = ' || to_char(p_business_group_id)	      ||
	' and exists (select null'					      ||
		      ' from ben_lvg_rsn_rt_f lrr'			      ||
		      ' where lrr.vrbl_rt_prfl_id = vpf.vrbl_rt_prfl_id'      ||
		      ' and ' || date_str(p_lf_evt_ocrd_dt,p_effective_date)  ||
			     ' between lrr.effective_start_date'	      ||
				 ' and lrr.effective_end_date) '	      ||
	' and ' || date_str(p_lf_evt_ocrd_dt, p_effective_date) 	      ||
	      ' between vpf.effective_start_date and vpf.effective_end_date;';
    --
    l_inst_query :=
      'select lrr.vrbl_rt_prfl_id, lrr.lvg_rsn_cd, lrr.excld_flag'	   ||
       ' from ben_lvg_rsn_rt_f lrr'					   ||
      ' where lrr.business_group_id = ' || to_char(p_business_group_id)    ||
	' and ' || date_str(p_lf_evt_ocrd_dt, p_effective_date) 	   ||
	      ' between lrr.effective_start_date'			   ||
		  ' and lrr.effective_end_date' 			   ||
      ' order by lrr.vrbl_rt_prfl_id;';
    --
    l_instcolnm_set(0).col_name    := 'vrbl_rt_prfl_id';
    l_instcolnm_set(0).caccol_name := 'id';
    l_instcolnm_set(1).col_name    := 'lvg_rsn_cd';
    l_instcolnm_set(1).caccol_name := 'lvg_rsn_cd';
    l_instcolnm_set(2).col_name    := 'excld_flag';
    l_instcolnm_set(2).caccol_name := 'excld_flag';
    --
    ben_cache.write_mastDet_Cache
      (p_mastercol_name => 'vrbl_rt_prfl_id'
      ,p_detailcol_name => 'vrbl_rt_prfl_id'
      ,p_lkup_name	=> 'ben_rt_prfl_cache.g_lvg_rsn_lookup'
      ,p_inst_name	=> 'ben_rt_prfl_cache.g_lvg_rsn_instance'
      ,p_lkup_query	=> l_lookup_query
      ,p_inst_query	=> l_inst_query
      ,p_instcolnm_set	=> l_instcolnm_set
      );
    --
  end if;
  --
  -- Cache already populated. Get record set.
  --
  get_cached_data
    (p_vrbl_rt_prfl_id => p_vrbl_rt_prfl_id
    ,p_lookup_name     => 'ben_rt_prfl_cache.g_lvg_rsn_lookup'
    ,p_inst_name       => 'ben_rt_prfl_cache.g_lvg_rsn_instance'
    ,p_inst_set_type   => 'ben_rt_prfl_cache.g_lvg_rsn_inst_tbl'
    ,p_out_inst_name   => 'ben_rt_prfl_cache.g_lvg_rsn_out'
    );
  --
  p_inst_set := g_lvg_rsn_out;
  p_inst_count := g_inst_count;
  --
exception
  --
  when no_data_found then
    --
    p_inst_count := 0;
    hr_utility.set_location('No Leaving Reason found', 90);
    hr_utility.set_location('Leaving : ' || l_proc, 99);
    --
end;

------------------------------------------------------------------------
-- Cobra Qualified Beneficiary
------------------------------------------------------------------------
procedure get_rt_prfl_cache
  (p_vrbl_rt_prfl_id   in number
  ,p_effective_date    in date
  ,p_lf_evt_ocrd_dt    in date
  ,p_business_group_id in number
  ,p_inst_set	       in out NOCOPY ben_rt_prfl_cache.g_cbr_qual_bnf_inst_tbl
  ,p_inst_count        out nocopy number)
is
  --
  l_proc varchar2(80) := g_package || '.get_rt_prfl_cache';
  l_lookup_query long;
  l_inst_query	 long;
  l_instcolnm_set ben_cache.instcolnmtype;
  --
begin
  --
  g_cbr_qual_bnf_out.delete;
  --
  if g_cbr_qual_bnf_lookup.count = 0 then
    --
    -- Cache not populated yet. So populate it now.
    --
    l_lookup_query :=
      'select vrbl_rt_prfl_id, business_group_id'			      ||
       ' from ben_vrbl_rt_prfl_f vpf'					      ||
      ' where business_group_id = ' || to_char(p_business_group_id)	      ||
	' and exists (select null'					      ||
		      ' from ben_cbr_quald_bnf_rt_f cqr'		      ||
		      ' where cqr.vrbl_rt_prfl_id = vpf.vrbl_rt_prfl_id'      ||
		      ' and ' || date_str(p_lf_evt_ocrd_dt,p_effective_date)  ||
			     ' between cqr.effective_start_date'	      ||
				 ' and cqr.effective_end_date) '	      ||
	' and ' || date_str(p_lf_evt_ocrd_dt, p_effective_date) 	      ||
	      ' between vpf.effective_start_date and vpf.effective_end_date;';
    --
    l_inst_query :=
      'select cqr.vrbl_rt_prfl_id, cqr.ptip_id, cqr.pgm_id,'		   ||
      	      ' cqr.quald_bnf_flag '	   		   ||
       ' from ben_cbr_quald_bnf_rt_f cqr'				   ||
      ' where cqr.business_group_id = ' || to_char(p_business_group_id)    ||
	' and ' || date_str(p_lf_evt_ocrd_dt, p_effective_date) 	   ||
	      ' between cqr.effective_start_date'			   ||
		  ' and cqr.effective_end_date' 			   ||
      ' order by cqr.vrbl_rt_prfl_id;';
    --
    l_instcolnm_set(0).col_name    := 'vrbl_rt_prfl_id';
    l_instcolnm_set(0).caccol_name := 'id';
    l_instcolnm_set(1).col_name    := 'ptip_id';
    l_instcolnm_set(1).caccol_name := 'ptip_id';
    l_instcolnm_set(2).col_name    := 'pgm_id';
    l_instcolnm_set(2).caccol_name := 'pgm_id';
    l_instcolnm_set(3).col_name    := 'quald_bnf_flag';
    l_instcolnm_set(3).caccol_name := 'quald_bnf_flag';

    --
    ben_cache.write_mastDet_Cache
      (p_mastercol_name => 'vrbl_rt_prfl_id'
      ,p_detailcol_name => 'vrbl_rt_prfl_id'
      ,p_lkup_name	=> 'ben_rt_prfl_cache.g_cbr_qual_bnf_lookup'
      ,p_inst_name	=> 'ben_rt_prfl_cache.g_cbr_qual_bnf_instance'
      ,p_lkup_query	=> l_lookup_query
      ,p_inst_query	=> l_inst_query
      ,p_instcolnm_set	=> l_instcolnm_set
      );
    --
  end if;
  --
  -- Cache already populated. Get record set.
  --
  get_cached_data
    (p_vrbl_rt_prfl_id => p_vrbl_rt_prfl_id
    ,p_lookup_name     => 'ben_rt_prfl_cache.g_cbr_qual_bnf_lookup'
    ,p_inst_name       => 'ben_rt_prfl_cache.g_cbr_qual_bnf_instance'
    ,p_inst_set_type   => 'ben_rt_prfl_cache.g_cbr_qual_bnf_inst_tbl'
    ,p_out_inst_name   => 'ben_rt_prfl_cache.g_cbr_qual_bnf_out'
    );
  --
  p_inst_set := g_cbr_qual_bnf_out;
  p_inst_count := g_inst_count;
  --
exception
  --
  when no_data_found then
    --
    p_inst_count := 0;
    hr_utility.set_location('No Cobra Qualified Benificiary found', 90);
    hr_utility.set_location('Leaving : ' || l_proc, 99);
    --
end;

------------------------------------------------------------------------
-- Continuing Participation Profile
------------------------------------------------------------------------
procedure get_rt_prfl_cache
  (p_vrbl_rt_prfl_id   in number
  ,p_effective_date    in date
  ,p_lf_evt_ocrd_dt    in date
  ,p_business_group_id in number
  ,p_inst_set	       in out NOCOPY ben_rt_prfl_cache.g_cntng_prtn_prfl_inst_tbl
  ,p_inst_count        out nocopy number)
is
  --
  l_proc varchar2(80) := g_package || '.get_rt_prfl_cache';
  l_lookup_query long;
  l_inst_query	 long;
  l_instcolnm_set ben_cache.instcolnmtype;
  --
begin
  --
  g_cntng_prtn_prfl_out.delete;
  --
  if g_cntng_prtn_prfl_lookup.count = 0 then
    --
    -- Cache not populated yet. So populate it now.
    --
    l_lookup_query :=
      'select vrbl_rt_prfl_id, business_group_id'			      ||
       ' from ben_vrbl_rt_prfl_f vpf'					      ||
      ' where business_group_id = ' || to_char(p_business_group_id)	      ||
	' and exists (select null'					      ||
		      ' from ben_cntng_prtn_prfl_rt_f cpp'		      ||
		      ' where cpp.vrbl_rt_prfl_id = vpf.vrbl_rt_prfl_id'      ||
		      ' and ' || date_str(p_lf_evt_ocrd_dt,p_effective_date)  ||
			     ' between cpp.effective_start_date'	      ||
				 ' and cpp.effective_end_date ) '	      ||
	' and ' || date_str(p_lf_evt_ocrd_dt, p_effective_date ) 	      ||
	      ' between vpf.effective_start_date and vpf.effective_end_date;';

    l_inst_query :=
      'select cpp.vrbl_rt_prfl_id, cpp.pymt_must_be_rcvd_uom, '	      	   ||
      ' cpp.pymt_must_be_rcvd_num , cpp.pymt_must_be_rcvd_rl '		   ||
      ' from ben_cntng_prtn_prfl_rt_f cpp'				   ||
      ' where cpp.business_group_id = ' || to_char(p_business_group_id)    ||
	' and ' || date_str(p_lf_evt_ocrd_dt, p_effective_date) 	   ||
	      ' between cpp.effective_start_date'			   ||
		  ' and cpp.effective_end_date' 			   ||
      ' order by cpp.vrbl_rt_prfl_id;';


    l_instcolnm_set(0).col_name    := 'vrbl_rt_prfl_id';
    l_instcolnm_set(0).caccol_name := 'id';
    l_instcolnm_set(1).col_name    := 'pymt_must_be_rcvd_uom';
    l_instcolnm_set(1).caccol_name := 'pymt_must_be_rcvd_uom';
    l_instcolnm_set(2).col_name    := 'pymt_must_be_rcvd_num';
    l_instcolnm_set(2).caccol_name := 'pymt_must_be_rcvd_num';
    l_instcolnm_set(3).col_name    := 'pymt_must_be_rcvd_rl';
    l_instcolnm_set(4).caccol_name := 'pymt_must_be_rcvd_rl';
    --
    ben_cache.write_mastDet_Cache
      (p_mastercol_name => 'vrbl_rt_prfl_id'
      ,p_detailcol_name => 'vrbl_rt_prfl_id'
      ,p_lkup_name	=> 'ben_rt_prfl_cache.g_cntng_prtn_prfl_lookup'
      ,p_inst_name	=> 'ben_rt_prfl_cache.g_cntng_prtn_prfl_instance'
      ,p_lkup_query	=> l_lookup_query
      ,p_inst_query	=> l_inst_query
      ,p_instcolnm_set	=> l_instcolnm_set
      );
    --
  end if;
  --
  -- Cache already populated. Get record set.
  --
  get_cached_data
    (p_vrbl_rt_prfl_id => p_vrbl_rt_prfl_id
    ,p_lookup_name     => 'ben_rt_prfl_cache.g_cntng_prtn_prfl_lookup'
    ,p_inst_name       => 'ben_rt_prfl_cache.g_cntng_prtn_prfl_instance'
    ,p_inst_set_type   => 'ben_rt_prfl_cache.g_cntng_prtn_prfl_inst_tbl'
    ,p_out_inst_name   => 'ben_rt_prfl_cache.g_cntng_prtn_prfl_out'
    );
  --
  p_inst_set := g_cntng_prtn_prfl_out;
  p_inst_count := g_inst_count;
  --
exception
  --
  when no_data_found then
    --
    p_inst_count := 0;
    hr_utility.set_location('No continuing participant profile found', 90);
    hr_utility.set_location('Leaving : ' || l_proc, 99);
    --
end;


------------------------------------------------------------------------
-- Position
------------------------------------------------------------------------
procedure get_rt_prfl_cache
  (p_vrbl_rt_prfl_id   in number
  ,p_effective_date    in date
  ,p_lf_evt_ocrd_dt    in date
  ,p_business_group_id in number
  ,p_inst_set	       in out NOCOPY ben_rt_prfl_cache.g_pstn_inst_tbl
  ,p_inst_count        out nocopy number)
is
  --
  l_proc varchar2(80) := g_package || '.get_rt_prfl_cache';
  l_lookup_query long;
  l_inst_query	 long;
  l_instcolnm_set ben_cache.instcolnmtype;
  --
begin
  --
  g_pstn_out.delete;
  --
  if g_pstn_lookup.count = 0 then
    --
    -- Cache not populated yet. So populate it now.
    --
    l_lookup_query :=
      'select vrbl_rt_prfl_id, business_group_id'			      ||
       ' from ben_vrbl_rt_prfl_f vpf'					      ||
      ' where business_group_id = ' || to_char(p_business_group_id)	      ||
	' and exists (select null'					      ||
		      ' from ben_pstn_rt_f psr'		      ||
		      ' where psr.vrbl_rt_prfl_id = vpf.vrbl_rt_prfl_id'      ||
		      ' and ' || date_str(p_lf_evt_ocrd_dt,p_effective_date)  ||
			     ' between psr.effective_start_date'	      ||
				 ' and psr.effective_end_date) '	      ||
	' and ' || date_str(p_lf_evt_ocrd_dt, p_effective_date) 	      ||
	      ' between vpf.effective_start_date and vpf.effective_end_date;';
    --
    l_inst_query :=
      'select psr.vrbl_rt_prfl_id, psr.position_id, psr.excld_flag'	   ||
       ' from ben_pstn_rt_f psr'					   ||
      ' where psr.business_group_id = ' || to_char(p_business_group_id)    ||
	' and ' || date_str(p_lf_evt_ocrd_dt, p_effective_date) 	   ||
	      ' between psr.effective_start_date'			   ||
		  ' and psr.effective_end_date' 			   ||
      ' order by psr.vrbl_rt_prfl_id;';
    --
    l_instcolnm_set(0).col_name    := 'vrbl_rt_prfl_id';
    l_instcolnm_set(0).caccol_name := 'id';
    l_instcolnm_set(1).col_name    := 'position_id';
    l_instcolnm_set(1).caccol_name := 'position_id';
    l_instcolnm_set(2).col_name    := 'excld_flag';
    l_instcolnm_set(2).caccol_name := 'excld_flag';
    --
    ben_cache.write_mastDet_Cache
      (p_mastercol_name => 'vrbl_rt_prfl_id'
      ,p_detailcol_name => 'vrbl_rt_prfl_id'
      ,p_lkup_name	=> 'ben_rt_prfl_cache.g_pstn_lookup'
      ,p_inst_name	=> 'ben_rt_prfl_cache.g_pstn_instance'
      ,p_lkup_query	=> l_lookup_query
      ,p_inst_query	=> l_inst_query
      ,p_instcolnm_set	=> l_instcolnm_set
      );
    --
  end if;
  --
  -- Cache already populated. Get record set.
  --
  get_cached_data
    (p_vrbl_rt_prfl_id => p_vrbl_rt_prfl_id
    ,p_lookup_name     => 'ben_rt_prfl_cache.g_pstn_lookup'
    ,p_inst_name       => 'ben_rt_prfl_cache.g_pstn_instance'
    ,p_inst_set_type   => 'ben_rt_prfl_cache.g_pstn_inst_tbl'
    ,p_out_inst_name   => 'ben_rt_prfl_cache.g_pstn_out'
    );
  --
  p_inst_set := g_pstn_out;
  p_inst_count := g_inst_count;
  --
exception
  --
  when no_data_found then
    --
    p_inst_count := 0;
    hr_utility.set_location('No position found', 90);
    hr_utility.set_location('Leaving : ' || l_proc, 99);
    --
end;


------------------------------------------------------------------------
-- Competency
------------------------------------------------------------------------
procedure get_rt_prfl_cache
  (p_vrbl_rt_prfl_id   in number
  ,p_effective_date    in date
  ,p_lf_evt_ocrd_dt    in date
  ,p_business_group_id in number
  ,p_inst_set	       in out NOCOPY ben_rt_prfl_cache.g_comptncy_inst_tbl
  ,p_inst_count        out nocopy number)
is
  --
  l_proc varchar2(80) := g_package || '.get_rt_prfl_cache';
  l_lookup_query long;
  l_inst_query	 long;
  l_instcolnm_set ben_cache.instcolnmtype;
  --
begin
  --
  g_comptncy_out.delete;
  --
  if g_comptncy_lookup.count = 0 then
    --
    -- Cache not populated yet. So populate it now.
    --
    l_lookup_query :=
      'select vrbl_rt_prfl_id, business_group_id'			      ||
       ' from ben_vrbl_rt_prfl_f vpf'					      ||
       ' where business_group_id = ' || to_char(p_business_group_id)	      ||
       ' and exists (select null'					      ||
		      ' from ben_comptncy_rt_f cty'		      ||
		      ' where cty.vrbl_rt_prfl_id = vpf.vrbl_rt_prfl_id'      ||
		      ' and ' || date_str(p_lf_evt_ocrd_dt,p_effective_date)  ||
			     ' between cty.effective_start_date'	      ||
				 ' and cty.effective_end_date) '	      ||
	' and ' || date_str(p_lf_evt_ocrd_dt, p_effective_date) 	      ||
	      ' between vpf.effective_start_date and vpf.effective_end_date;';
    --
    l_inst_query :=
      'select cty.vrbl_rt_prfl_id, cty.competence_id,'			   ||
      ' cty.rating_level_id, cty.excld_flag'	   			   ||
      ' from ben_comptncy_rt_f cty'					   ||
      ' where cty.business_group_id = ' || to_char(p_business_group_id)    ||
      ' and ' || date_str(p_lf_evt_ocrd_dt, p_effective_date) 	  	   ||
	      ' between cty.effective_start_date'			   ||
		  ' and cty.effective_end_date' 			   ||
      ' order by cty.vrbl_rt_prfl_id;';
    --
    l_instcolnm_set(0).col_name    := 'vrbl_rt_prfl_id';
    l_instcolnm_set(0).caccol_name := 'id';
    l_instcolnm_set(1).col_name    := 'competence_id';
    l_instcolnm_set(1).caccol_name := 'competence_id';
    l_instcolnm_set(2).col_name    := 'rating_level_id';
    l_instcolnm_set(2).caccol_name := 'rating_level_id';
    l_instcolnm_set(3).col_name    := 'excld_flag';
    l_instcolnm_set(3).caccol_name := 'excld_flag';
    --
    ben_cache.write_mastDet_Cache
      (p_mastercol_name => 'vrbl_rt_prfl_id'
      ,p_detailcol_name => 'vrbl_rt_prfl_id'
      ,p_lkup_name	=> 'ben_rt_prfl_cache.g_comptncy_lookup'
      ,p_inst_name	=> 'ben_rt_prfl_cache.g_comptncy_instance'
      ,p_lkup_query	=> l_lookup_query
      ,p_inst_query	=> l_inst_query
      ,p_instcolnm_set	=> l_instcolnm_set
      );
    --
  end if;
  --
  -- Cache already populated. Get record set.
  --
  get_cached_data
    (p_vrbl_rt_prfl_id => p_vrbl_rt_prfl_id
    ,p_lookup_name     => 'ben_rt_prfl_cache.g_comptncy_lookup'
    ,p_inst_name       => 'ben_rt_prfl_cache.g_comptncy_instance'
    ,p_inst_set_type   => 'ben_rt_prfl_cache.g_comptncy_inst_tbl'
    ,p_out_inst_name   => 'ben_rt_prfl_cache.g_comptncy_out'
    );
  --
  p_inst_set := g_comptncy_out;
  p_inst_count := g_inst_count;
  --
exception
  --
  when no_data_found then
    --
    p_inst_count := 0;
    hr_utility.set_location('No compentency found', 90);
    hr_utility.set_location('Leaving : ' || l_proc, 99);
    --
end;


------------------------------------------------------------------------
-- Qualification Title
------------------------------------------------------------------------
procedure get_rt_prfl_cache
  (p_vrbl_rt_prfl_id   in number
  ,p_effective_date    in date
  ,p_lf_evt_ocrd_dt    in date
  ,p_business_group_id in number
  ,p_inst_set	       in out NOCOPY ben_rt_prfl_cache.g_qual_titl_inst_tbl
  ,p_inst_count        out nocopy number)
is
  --
  l_proc varchar2(80) := g_package || '.get_rt_prfl_cache';
  l_lookup_query long;
  l_inst_query	 long;
  l_instcolnm_set ben_cache.instcolnmtype;
  --
begin
  --
  g_qual_titl_out.delete;
  --
  if g_qual_titl_lookup.count = 0 then
    --
    -- Cache not populated yet. So populate it now.
    --
    l_lookup_query :=
      'select vrbl_rt_prfl_id, business_group_id'			      ||
       ' from ben_vrbl_rt_prfl_f vpf'					      ||
       ' where business_group_id = ' || to_char(p_business_group_id)	      ||
       ' and exists (select null'					      ||
		      ' from ben_qual_titl_rt_f qtr'		      	      ||
		      ' where qtr.vrbl_rt_prfl_id = vpf.vrbl_rt_prfl_id'      ||
		      ' and ' || date_str(p_lf_evt_ocrd_dt,p_effective_date)  ||
			     ' between qtr.effective_start_date'	      ||
				 ' and qtr.effective_end_date) '	      ||
	' and ' || date_str(p_lf_evt_ocrd_dt, p_effective_date) 	      ||
	      ' between vpf.effective_start_date and vpf.effective_end_date;';
    --
    l_inst_query :=
      'select qtr.vrbl_rt_prfl_id, qtr.qualification_type_id,'			   ||
      ' qtr.title, qtr.excld_flag'	   			   ||
      ' from ben_qual_titl_rt_f qtr'					   ||
      ' where qtr.business_group_id = ' || to_char(p_business_group_id)    ||
      ' and ' || date_str(p_lf_evt_ocrd_dt, p_effective_date) 	  	   ||
	      ' between qtr.effective_start_date'			   ||
		  ' and qtr.effective_end_date' 			   ||
      ' order by qtr.vrbl_rt_prfl_id;';
    --
    l_instcolnm_set(0).col_name    := 'vrbl_rt_prfl_id';
    l_instcolnm_set(0).caccol_name := 'id';
    l_instcolnm_set(1).col_name    := 'qualification_type_id';
    l_instcolnm_set(1).caccol_name := 'qualification_type_id';
    l_instcolnm_set(2).col_name    := 'title';
    l_instcolnm_set(2).caccol_name := 'title';
    l_instcolnm_set(3).col_name    := 'excld_flag';
    l_instcolnm_set(3).caccol_name := 'excld_flag';
    --
    ben_cache.write_mastDet_Cache
      (p_mastercol_name => 'vrbl_rt_prfl_id'
      ,p_detailcol_name => 'vrbl_rt_prfl_id'
      ,p_lkup_name	=> 'ben_rt_prfl_cache.g_qual_titl_lookup'
      ,p_inst_name	=> 'ben_rt_prfl_cache.g_qual_titl_instance'
      ,p_lkup_query	=> l_lookup_query
      ,p_inst_query	=> l_inst_query
      ,p_instcolnm_set	=> l_instcolnm_set
      );
    --
  end if;
  --
  -- Cache already populated. Get record set.
  --
  get_cached_data
    (p_vrbl_rt_prfl_id => p_vrbl_rt_prfl_id
    ,p_lookup_name     => 'ben_rt_prfl_cache.g_qual_titl_lookup'
    ,p_inst_name       => 'ben_rt_prfl_cache.g_qual_titl_instance'
    ,p_inst_set_type   => 'ben_rt_prfl_cache.g_qual_titl_inst_tbl'
    ,p_out_inst_name   => 'ben_rt_prfl_cache.g_qual_titl_out'
    );
  --
  p_inst_set := g_qual_titl_out;
  p_inst_count := g_inst_count;
  --
exception
  --
  when no_data_found then
    --
    p_inst_count := 0;
    hr_utility.set_location('No qualification title found', 90);
    hr_utility.set_location('Leaving : ' || l_proc, 99);
    --
end;


------------------------------------------------------------------------
-- DCR 	Covered by Other Plan
------------------------------------------------------------------------

procedure get_rt_prfl_cache
  (p_vrbl_rt_prfl_id   in number
  ,p_effective_date    in date
  ,p_lf_evt_ocrd_dt    in date
  ,p_business_group_id in number
  ,p_inst_set	       in out NOCOPY ben_rt_prfl_cache.g_dpnt_cvrd_othr_pl_inst_tbl
  ,p_inst_count        out nocopy number) as

  --
    l_proc varchar2(80) := g_package || '.get_rt_prfl_cache';
    l_lookup_query long;
    l_inst_query	 long;
    l_instcolnm_set ben_cache.instcolnmtype;
    --
  begin
    --
    g_dpnt_cvrd_othr_pl_out.delete;
    --
    if g_dpnt_cvrd_othr_pl_lookup.count = 0 then
      --
      -- Cache not populated yet. So populate it now.
      --
      l_lookup_query :=
        'select vrbl_rt_prfl_id, business_group_id'			      ||
         ' from ben_vrbl_rt_prfl_f vpf'					      ||
         ' where business_group_id = ' || to_char(p_business_group_id)	      ||
         ' and exists (select null'					      ||
  		      ' from BEN_DPNT_CVRD_OTHR_PL_RT_F dcr'		      ||
  		      ' where dcr.vrbl_rt_prfl_id = vpf.vrbl_rt_prfl_id'      ||
  		      ' and ' || date_str(p_lf_evt_ocrd_dt,p_effective_date)  ||
  			     ' between dcr.effective_start_date'	      ||
  				 ' and dcr.effective_end_date) '	      ||
  	' and ' || date_str(p_lf_evt_ocrd_dt, p_effective_date) 	      ||
  	      ' between vpf.effective_start_date and vpf.effective_end_date;';
      --
      l_inst_query :=
        'select dcr.vrbl_rt_prfl_id, dcr.pl_id,'		   	   ||
        ' dcr.cvg_det_dt_cd , dcr.excld_flag'	   			   ||
        ' from BEN_DPNT_CVRD_OTHR_PL_RT_F dcr'				   ||
        ' where dcr.business_group_id = ' || to_char(p_business_group_id)  ||
        ' and ' || date_str(p_lf_evt_ocrd_dt, p_effective_date) 	   ||
  	      ' between dcr.effective_start_date'			   ||
  		  ' and dcr.effective_end_date' 			   ||
        ' order by dcr.vrbl_rt_prfl_id;';
      --
      l_instcolnm_set(0).col_name    := 'vrbl_rt_prfl_id';
      l_instcolnm_set(0).caccol_name := 'id';
      l_instcolnm_set(1).col_name    := 'pl_id';
      l_instcolnm_set(1).caccol_name := 'pl_id';
      l_instcolnm_set(2).col_name    := 'cvg_det_dt_cd';
      l_instcolnm_set(2).caccol_name := 'cvg_det_dt_cd';
      l_instcolnm_set(3).col_name    := 'excld_flag';
      l_instcolnm_set(3).caccol_name := 'excld_flag';
      --
      ben_cache.write_mastDet_Cache
        (p_mastercol_name => 'vrbl_rt_prfl_id'
        ,p_detailcol_name => 'vrbl_rt_prfl_id'
        ,p_lkup_name	  => 'ben_rt_prfl_cache.g_dpnt_cvrd_othr_pl_lookup'
        ,p_inst_name	  => 'ben_rt_prfl_cache.g_dpnt_cvrd_othr_pl_instance'
        ,p_lkup_query	  => l_lookup_query
        ,p_inst_query	  => l_inst_query
        ,p_instcolnm_set  => l_instcolnm_set
        );
      --
    end if;
    --
    -- Cache already populated. Get record set.
    --
    get_cached_data
      (p_vrbl_rt_prfl_id => p_vrbl_rt_prfl_id
      ,p_lookup_name     => 'ben_rt_prfl_cache.g_dpnt_cvrd_othr_pl_lookup'
      ,p_inst_name       => 'ben_rt_prfl_cache.g_dpnt_cvrd_othr_pl_instance'
      ,p_inst_set_type   => 'ben_rt_prfl_cache.g_dpnt_cvrd_othr_pl_inst_tbl'
      ,p_out_inst_name   => 'ben_rt_prfl_cache.g_dpnt_cvrd_othr_pl_out'
      );
    --
    p_inst_set := g_dpnt_cvrd_othr_pl_out;
    p_inst_count := g_inst_count;
    --
  exception
    --
    when no_data_found then
      --
      p_inst_count := 0;
      hr_utility.set_location('Covered by Other Plan found', 90);
      hr_utility.set_location('Leaving : ' || l_proc, 99);
      --
end ;
------------------------------------------------------------------------
-- DCP 	Covered by Other Plan in Program
------------------------------------------------------------------------
--
procedure get_rt_prfl_cache
  (p_vrbl_rt_prfl_id   in number
  ,p_effective_date    in date
  ,p_lf_evt_ocrd_dt    in date
  ,p_business_group_id in number
  ,p_inst_set	       in out NOCOPY ben_rt_prfl_cache.g_dpnt_cvrd_othr_plip_inst_tbl
  ,p_inst_count        out nocopy number) as
  --
      l_proc varchar2(80) := g_package || '.get_rt_prfl_cache';
      l_lookup_query long;
      l_inst_query	 long;
      l_instcolnm_set ben_cache.instcolnmtype;
      --
    begin
      --
      g_dpnt_cvrd_othr_plip_out.delete;
      --
      if g_dpnt_cvrd_othr_plip_lookup.count = 0 then
        --
        -- Cache not populated yet. So populate it now.
        --
        l_lookup_query :=
          'select vrbl_rt_prfl_id, business_group_id'			      ||
           ' from ben_vrbl_rt_prfl_f vpf'				      ||
           ' where business_group_id = ' || to_char(p_business_group_id)      ||
           ' and exists (select null'					      ||
    		      ' from BEN_DPNT_CVRD_PLIP_RT_F dcp'		      ||
    		      ' where dcp.vrbl_rt_prfl_id = vpf.vrbl_rt_prfl_id'      ||
    		      ' and ' || date_str(p_lf_evt_ocrd_dt,p_effective_date)  ||
    			     ' between dcp.effective_start_date'	      ||
    				 ' and dcp.effective_end_date) '	      ||
    	' and ' || date_str(p_lf_evt_ocrd_dt, p_effective_date) 	      ||
    	      ' between vpf.effective_start_date and vpf.effective_end_date;';
        --
        l_inst_query :=
          'select dcp.vrbl_rt_prfl_id, dcp.plip_id,'		   	   ||
          ' dcp.enrl_det_dt_cd , dcp.excld_flag'	   		   ||
          ' from BEN_DPNT_CVRD_PLIP_RT_F dcp'			   ||
          ' where dcp.business_group_id = ' || to_char(p_business_group_id)  ||
          ' and ' || date_str(p_lf_evt_ocrd_dt, p_effective_date) 	   ||
    	      ' between dcp.effective_start_date'			   ||
    		  ' and dcp.effective_end_date' 			   ||
          ' order by dcp.vrbl_rt_prfl_id;';
        --
        l_instcolnm_set(0).col_name    := 'vrbl_rt_prfl_id';
        l_instcolnm_set(0).caccol_name := 'id';
        l_instcolnm_set(1).col_name    := 'plip_id';
        l_instcolnm_set(1).caccol_name := 'plip_id';
        l_instcolnm_set(2).col_name    := 'enrl_det_dt_cd';
        l_instcolnm_set(2).caccol_name := 'enrl_det_dt_cd';
        l_instcolnm_set(3).col_name    := 'excld_flag';
        l_instcolnm_set(3).caccol_name := 'excld_flag';
        --
        ben_cache.write_mastDet_Cache
          (p_mastercol_name => 'vrbl_rt_prfl_id'
          ,p_detailcol_name => 'vrbl_rt_prfl_id'
          ,p_lkup_name	  => 'ben_rt_prfl_cache.g_dpnt_cvrd_othr_plip_lookup'
          ,p_inst_name	  => 'ben_rt_prfl_cache.g_dpnt_cvrd_othr_plip_instance'
          ,p_lkup_query	  => l_lookup_query
          ,p_inst_query	  => l_inst_query
          ,p_instcolnm_set  => l_instcolnm_set
          );
        --
      end if;
      --
      -- Cache already populated. Get record set.
      --
      get_cached_data
        (p_vrbl_rt_prfl_id => p_vrbl_rt_prfl_id
        ,p_lookup_name     => 'ben_rt_prfl_cache.g_dpnt_cvrd_othr_plip_lookup'
        ,p_inst_name       => 'ben_rt_prfl_cache.g_dpnt_cvrd_othr_plip_instance'
        ,p_inst_set_type   => 'ben_rt_prfl_cache.g_dpnt_cvrd_othr_plip_inst_tbl'
        ,p_out_inst_name   => 'ben_rt_prfl_cache.g_dpnt_cvrd_othr_plip_out'
        );
      --
      p_inst_set := g_dpnt_cvrd_othr_plip_out;
      p_inst_count := g_inst_count;
      --
    exception
      --
      when no_data_found then
        --
        p_inst_count := 0;
        hr_utility.set_location('Covered by Other Plan in Program', 90);
        hr_utility.set_location('Leaving : ' || l_proc, 99);
        --
end ;
------------------------------------------------------------------------
-- DCO 	Covered by Other Plan Type in Program
------------------------------------------------------------------------
--
procedure get_rt_prfl_cache
  (p_vrbl_rt_prfl_id   in number
  ,p_effective_date    in date
  ,p_lf_evt_ocrd_dt    in date
  ,p_business_group_id in number
  ,p_inst_set	       in out NOCOPY ben_rt_prfl_cache.g_dpnt_cvrd_othr_ptip_inst_tbl
  ,p_inst_count        out nocopy number) as

  --
      l_proc varchar2(80) := g_package || '.get_rt_prfl_cache';
      l_lookup_query long;
      l_inst_query	 long;
      l_instcolnm_set ben_cache.instcolnmtype;
      --
  begin
      --
      g_dpnt_cvrd_othr_ptip_out.delete;
      --
      if g_dpnt_cvrd_othr_ptip_lookup.count = 0 then
        --
        -- Cache not populated yet. So populate it now.
        --
        l_lookup_query :=
          'select vrbl_rt_prfl_id, business_group_id'			      ||
           ' from ben_vrbl_rt_prfl_f vpf'				      ||
           ' where business_group_id = ' || to_char(p_business_group_id)      ||
           ' and exists (select null'					      ||
    		      ' from BEN_DPNT_CVRD_OTHR_PTIP_RT_F dco'		      ||
    		      ' where dco.vrbl_rt_prfl_id = vpf.vrbl_rt_prfl_id'      ||
    		      ' and ' || date_str(p_lf_evt_ocrd_dt,p_effective_date)  ||
    			     ' between dco.effective_start_date'	      ||
    				 ' and dco.effective_end_date) '	      ||
    	' and ' || date_str(p_lf_evt_ocrd_dt, p_effective_date) 	      ||
    	      ' between vpf.effective_start_date and vpf.effective_end_date;';
        --
        l_inst_query :=
          'select dco.vrbl_rt_prfl_id, dco.ptip_id,'		   	         ||
          ' dco.enrl_det_dt_cd , dco.excld_flag ,dco.only_pls_subj_cobra_flag '	 ||
          ' from BEN_DPNT_CVRD_OTHR_PTIP_RT_F dco'			         ||
          ' where dco.business_group_id = ' || to_char(p_business_group_id)      ||
          ' and ' || date_str(p_lf_evt_ocrd_dt, p_effective_date) 	   ||
    	      ' between dco.effective_start_date'			   ||
    		  ' and dco.effective_end_date' 			   ||
          ' order by dco.vrbl_rt_prfl_id;';
        --
        l_instcolnm_set(0).col_name    := 'vrbl_rt_prfl_id';
        l_instcolnm_set(0).caccol_name := 'id';
        l_instcolnm_set(1).col_name    := 'ptip_id';
        l_instcolnm_set(1).caccol_name := 'ptip_id';
        l_instcolnm_set(2).col_name    := 'enrl_det_dt_cd';
        l_instcolnm_set(2).caccol_name := 'enrl_det_dt_cd';
        l_instcolnm_set(3).col_name    := 'excld_flag';
        l_instcolnm_set(3).caccol_name := 'excld_flag';
        l_instcolnm_set(4).col_name    := 'only_pls_subj_cobra_flag';
        l_instcolnm_set(4).caccol_name := 'only_pls_subj_cobra_flag';

        --
        ben_cache.write_mastDet_Cache
          (p_mastercol_name => 'vrbl_rt_prfl_id'
          ,p_detailcol_name => 'vrbl_rt_prfl_id'
          ,p_lkup_name	  => 'ben_rt_prfl_cache.g_dpnt_cvrd_othr_ptip_lookup'
          ,p_inst_name	  => 'ben_rt_prfl_cache.g_dpnt_cvrd_othr_ptip_instance'
          ,p_lkup_query	  => l_lookup_query
          ,p_inst_query	  => l_inst_query
          ,p_instcolnm_set  => l_instcolnm_set
          );
        --
      end if;
      --
      -- Cache already populated. Get record set.
      --
      get_cached_data
        (p_vrbl_rt_prfl_id => p_vrbl_rt_prfl_id
        ,p_lookup_name     => 'ben_rt_prfl_cache.g_dpnt_cvrd_othr_ptip_lookup'
        ,p_inst_name       => 'ben_rt_prfl_cache.g_dpnt_cvrd_othr_ptip_instance'
        ,p_inst_set_type   => 'ben_rt_prfl_cache.g_dpnt_cvrd_othr_ptip_inst_tbl'
        ,p_out_inst_name   => 'ben_rt_prfl_cache.g_dpnt_cvrd_othr_ptip_out'
        );
      --
      p_inst_set := g_dpnt_cvrd_othr_ptip_out;
      p_inst_count := g_inst_count;
      --
    exception
      --
      when no_data_found then
        --
        p_inst_count := 0;
        hr_utility.set_location('Covered by Other Plan Type in Program', 90);
        hr_utility.set_location('Leaving : ' || l_proc, 99);
        --
end ;
--
------------------------------------------------------------------------
-- DOP 	Covered by Other Program
------------------------------------------------------------------------
--
procedure get_rt_prfl_cache
  (p_vrbl_rt_prfl_id   in number
  ,p_effective_date    in date
  ,p_lf_evt_ocrd_dt    in date
  ,p_business_group_id in number
  ,p_inst_set	       in out NOCOPY ben_rt_prfl_cache.g_dpnt_cvrd_othr_pgm_inst_tbl
  ,p_inst_count        out nocopy number) as
 --
      l_proc varchar2(80) := g_package || '.get_rt_prfl_cache';
      l_lookup_query long;
      l_inst_query	 long;
      l_instcolnm_set ben_cache.instcolnmtype;
      --
begin
      --
      g_dpnt_cvrd_othr_pgm_out.delete;
      --
      if g_dpnt_cvrd_othr_pgm_lookup.count = 0 then
        --
        -- Cache not populated yet. So populate it now.
        --
        l_lookup_query :=
          'select vrbl_rt_prfl_id, business_group_id'			      ||
           ' from ben_vrbl_rt_prfl_f vpf'				      ||
           ' where business_group_id = ' || to_char(p_business_group_id)      ||
           ' and exists (select null'					      ||
    		      ' from BEN_DPNT_CVRD_OTHR_PGM_RT_F dop'		      ||
    		      ' where dop.vrbl_rt_prfl_id = vpf.vrbl_rt_prfl_id'      ||
    		      ' and ' || date_str(p_lf_evt_ocrd_dt,p_effective_date)  ||
    			     ' between dop.effective_start_date'	      ||
    				 ' and dop.effective_end_date) '	      ||
    	' and ' || date_str(p_lf_evt_ocrd_dt, p_effective_date) 	      ||
    	      ' between vpf.effective_start_date and vpf.effective_end_date;';
        --
        l_inst_query :=
          'select dop.vrbl_rt_prfl_id, dop.pgm_id,'		   	   ||
          ' dop.enrl_det_dt_cd , dop.excld_flag , dop.only_pls_subj_cobra_flag'	   		   ||
          ' from BEN_DPNT_CVRD_OTHR_PGM_RT_F dop'			   ||
          ' where dop.business_group_id = ' || to_char(p_business_group_id)  ||
          ' and ' || date_str(p_lf_evt_ocrd_dt, p_effective_date) 	   ||
    	      ' between dop.effective_start_date'			   ||
    		  ' and dop.effective_end_date' 			   ||
          ' order by dop.vrbl_rt_prfl_id;';
        --
        l_instcolnm_set(0).col_name    := 'vrbl_rt_prfl_id';
        l_instcolnm_set(0).caccol_name := 'id';
        l_instcolnm_set(1).col_name    := 'pgm_id';
        l_instcolnm_set(1).caccol_name := 'pgm_id';
        l_instcolnm_set(2).col_name    := 'enrl_det_dt_cd';
        l_instcolnm_set(2).caccol_name := 'enrl_det_dt_cd';
        l_instcolnm_set(3).col_name    := 'excld_flag';
        l_instcolnm_set(3).caccol_name := 'excld_flag';
        l_instcolnm_set(4).col_name    := 'only_pls_subj_cobra_flag';
	l_instcolnm_set(4).caccol_name := 'only_pls_subj_cobra_flag';
        --
        --
        ben_cache.write_mastDet_Cache
          (p_mastercol_name => 'vrbl_rt_prfl_id'
          ,p_detailcol_name => 'vrbl_rt_prfl_id'
          ,p_lkup_name	  => 'ben_rt_prfl_cache.g_dpnt_cvrd_othr_pgm_lookup'
          ,p_inst_name	  => 'ben_rt_prfl_cache.g_dpnt_cvrd_othr_pgm_instance'
          ,p_lkup_query	  => l_lookup_query
          ,p_inst_query	  => l_inst_query
          ,p_instcolnm_set  => l_instcolnm_set
          );
        --
      end if;
      --
      -- Cache already populated. Get record set.
      --
      get_cached_data
        (p_vrbl_rt_prfl_id => p_vrbl_rt_prfl_id
        ,p_lookup_name     => 'ben_rt_prfl_cache.g_dpnt_cvrd_othr_pgm_lookup'
        ,p_inst_name       => 'ben_rt_prfl_cache.g_dpnt_cvrd_othr_pgm_instance'
        ,p_inst_set_type   => 'ben_rt_prfl_cache.g_dpnt_cvrd_othr_pgm_inst_tbl'
        ,p_out_inst_name   => 'ben_rt_prfl_cache.g_dpnt_cvrd_othr_pgm_out'
        );
      --
      p_inst_set := g_dpnt_cvrd_othr_pgm_out;
      p_inst_count := g_inst_count;
      --
exception
      --
      when no_data_found then
        --
        p_inst_count := 0;
        hr_utility.set_location('Covered by Other Program', 90);
        hr_utility.set_location('Leaving : ' || l_proc, 99);
        --
end ;
--
------------------------------------------------------------------------
-- PAP 	Eligible for Another Plan
------------------------------------------------------------------------
--
procedure get_rt_prfl_cache
  (p_vrbl_rt_prfl_id   in number
  ,p_effective_date    in date
  ,p_lf_evt_ocrd_dt    in date
  ,p_business_group_id in number
  ,p_inst_set	       in out NOCOPY ben_rt_prfl_cache.g_prtt_anthr_pl_inst_tbl
  ,p_inst_count        out nocopy number) as
 --
      l_proc varchar2(80) := g_package || '.get_rt_prfl_cache';
      l_lookup_query long;
      l_inst_query	 long;
      l_instcolnm_set ben_cache.instcolnmtype;
      --
begin
      --
      g_prtt_anthr_pl_out.delete;
      --
      if g_prtt_anthr_pl_lookup.count = 0 then
        --
        -- Cache not populated yet. So populate it now.
        --
        l_lookup_query :=
          'select vrbl_rt_prfl_id, business_group_id'			      ||
           ' from ben_vrbl_rt_prfl_f vpf'				      ||
           ' where business_group_id = ' || to_char(p_business_group_id)      ||
           ' and exists (select null'					      ||
    		      ' from BEN_PRTT_ANTHR_PL_RT_F pap'		      ||
    		      ' where pap.vrbl_rt_prfl_id = vpf.vrbl_rt_prfl_id'      ||
    		      ' and ' || date_str(p_lf_evt_ocrd_dt,p_effective_date)  ||
    			     ' between pap.effective_start_date'	      ||
    				 ' and pap.effective_end_date) '	      ||
    	' and ' || date_str(p_lf_evt_ocrd_dt, p_effective_date) 	      ||
    	      ' between vpf.effective_start_date and vpf.effective_end_date;';
        --
        l_inst_query :=
          'select pap.vrbl_rt_prfl_id, pap.pl_id,'		   	   ||
          ' pap.excld_flag '				   		   ||
          ' from BEN_PRTT_ANTHR_PL_RT_F pap'				   ||
          ' where pap.business_group_id = ' || to_char(p_business_group_id)  ||
          ' and ' || date_str(p_lf_evt_ocrd_dt, p_effective_date) 	   ||
    	      ' between pap.effective_start_date'			   ||
    		  ' and pap.effective_end_date' 			   ||
          ' order by pap.vrbl_rt_prfl_id;';
        --
        l_instcolnm_set(0).col_name    := 'vrbl_rt_prfl_id';
        l_instcolnm_set(0).caccol_name := 'id';
        l_instcolnm_set(1).col_name    := 'pl_id';
        l_instcolnm_set(1).caccol_name := 'pl_id';
        l_instcolnm_set(2).col_name    := 'excld_flag';
        l_instcolnm_set(2).caccol_name := 'excld_flag';
        --
        --
        ben_cache.write_mastDet_Cache
          (p_mastercol_name => 'vrbl_rt_prfl_id'
          ,p_detailcol_name => 'vrbl_rt_prfl_id'
          ,p_lkup_name	  => 'ben_rt_prfl_cache.g_prtt_anthr_pl_lookup'
          ,p_inst_name	  => 'ben_rt_prfl_cache.g_prtt_anthr_pl_instance'
          ,p_lkup_query	  => l_lookup_query
          ,p_inst_query	  => l_inst_query
          ,p_instcolnm_set  => l_instcolnm_set
          );
        --
      end if;
      --
      -- Cache already populated. Get record set.
      --
      get_cached_data
        (p_vrbl_rt_prfl_id => p_vrbl_rt_prfl_id
        ,p_lookup_name     => 'ben_rt_prfl_cache.g_prtt_anthr_pl_lookup'
        ,p_inst_name       => 'ben_rt_prfl_cache.g_prtt_anthr_pl_instance'
        ,p_inst_set_type   => 'ben_rt_prfl_cache.g_prtt_anthr_pl_inst_tbl'
        ,p_out_inst_name   => 'ben_rt_prfl_cache.g_prtt_anthr_pl_out'
        );
      --
      p_inst_set := g_prtt_anthr_pl_out;
      p_inst_count := g_inst_count;
      --
exception
      --
      when no_data_found then
        --
        p_inst_count := 0;
        hr_utility.set_location('Eligible for Another Plan', 90);
        hr_utility.set_location('Leaving : ' || l_proc, 99);
        --
end ;
--
------------------------------------------------------------------------
-- OPR 	Eligible for Another Plan Type in Program
------------------------------------------------------------------------
--
procedure get_rt_prfl_cache
  (p_vrbl_rt_prfl_id   in number
  ,p_effective_date    in date
  ,p_lf_evt_ocrd_dt    in date
  ,p_business_group_id in number
  ,p_inst_set	       in out NOCOPY ben_rt_prfl_cache.g_othr_ptip_inst_tbl
  ,p_inst_count        out nocopy number) as
--
      l_proc varchar2(80) := g_package || '.get_rt_prfl_cache';
      l_lookup_query long;
      l_inst_query	 long;
      l_instcolnm_set ben_cache.instcolnmtype;
--
begin
      --
      g_othr_ptip_out.delete;
      --
      if g_othr_ptip_lookup.count = 0 then
        --
        -- Cache not populated yet. So populate it now.
        --
        l_lookup_query :=
          'select vrbl_rt_prfl_id, business_group_id'			      ||
           ' from ben_vrbl_rt_prfl_f vpf'				      ||
           ' where business_group_id = ' || to_char(p_business_group_id)      ||
           ' and exists (select null'					      ||
    		      ' from BEN_OTHR_PTIP_RT_F opr'		      ||
    		      ' where opr.vrbl_rt_prfl_id = vpf.vrbl_rt_prfl_id'      ||
    		      ' and ' || date_str(p_lf_evt_ocrd_dt,p_effective_date)  ||
    			     ' between opr.effective_start_date'	      ||
    				 ' and opr.effective_end_date) '	      ||
    	' and ' || date_str(p_lf_evt_ocrd_dt, p_effective_date) 	      ||
    	      ' between vpf.effective_start_date and vpf.effective_end_date;';
        --
        l_inst_query :=
          'select opr.vrbl_rt_prfl_id, opr.ptip_id,'		   	   ||
          ' opr.excld_flag ,opr.only_pls_subj_cobra_flag '				   		   ||
          ' from BEN_OTHR_PTIP_RT_F opr'				   ||
          ' where opr.business_group_id = ' || to_char(p_business_group_id)  ||
          ' and ' || date_str(p_lf_evt_ocrd_dt, p_effective_date) 	   ||
    	      ' between opr.effective_start_date'			   ||
    		  ' and opr.effective_end_date' 			   ||
          ' order by opr.vrbl_rt_prfl_id;';
        --
        l_instcolnm_set(0).col_name    := 'vrbl_rt_prfl_id';
        l_instcolnm_set(0).caccol_name := 'id';
        l_instcolnm_set(1).col_name    := 'ptip_id';
        l_instcolnm_set(1).caccol_name := 'ptip_id';
        l_instcolnm_set(2).col_name    := 'excld_flag';
        l_instcolnm_set(2).caccol_name := 'excld_flag';
        l_instcolnm_set(3).col_name    := 'only_pls_subj_cobra_flag';
        l_instcolnm_set(3).caccol_name := 'only_pls_subj_cobra_flag';

        --
        --
        ben_cache.write_mastDet_Cache
          (p_mastercol_name => 'vrbl_rt_prfl_id'
          ,p_detailcol_name => 'vrbl_rt_prfl_id'
          ,p_lkup_name	  => 'ben_rt_prfl_cache.g_othr_ptip_lookup'
          ,p_inst_name	  => 'ben_rt_prfl_cache.g_othr_ptip_instance'
          ,p_lkup_query	  => l_lookup_query
          ,p_inst_query	  => l_inst_query
          ,p_instcolnm_set  => l_instcolnm_set
          );
        --
      end if;
      --
      -- Cache already populated. Get record set.
      --
      get_cached_data
        (p_vrbl_rt_prfl_id => p_vrbl_rt_prfl_id
        ,p_lookup_name     => 'ben_rt_prfl_cache.g_othr_ptip_lookup'
        ,p_inst_name       => 'ben_rt_prfl_cache.g_othr_ptip_instance'
        ,p_inst_set_type   => 'ben_rt_prfl_cache.g_othr_ptip_inst_tbl'
        ,p_out_inst_name   => 'ben_rt_prfl_cache.g_othr_ptip_out'
        );
      --
      p_inst_set := g_othr_ptip_out;
      p_inst_count := g_inst_count;
      --
exception
      --
      when no_data_found then
        --
        p_inst_count := 0;
        hr_utility.set_location('Eligible for Another Plan Type in Program', 90);
        hr_utility.set_location('Leaving : ' || l_proc, 99);
        --
end ;
--
------------------------------------------------------------------------
-- ENL Enrolled Another Plan
------------------------------------------------------------------------
--
procedure get_rt_prfl_cache
  (p_vrbl_rt_prfl_id   in number
  ,p_effective_date    in date
  ,p_lf_evt_ocrd_dt    in date
  ,p_business_group_id in number
  ,p_inst_set	       in out NOCOPY ben_rt_prfl_cache.g_enrld_anthr_pl_inst_tbl
  ,p_inst_count        out nocopy number) as
 --
      l_proc varchar2(80) := g_package || '.get_rt_prfl_cache';
      l_lookup_query long;
      l_inst_query	 long;
      l_instcolnm_set ben_cache.instcolnmtype;
      --
begin
      --
      g_enrld_anthr_pl_out.delete;
      --
      if g_enrld_anthr_pl_lookup.count = 0 then
        --
        -- Cache not populated yet. So populate it now.
        --
        l_lookup_query :=
          'select vrbl_rt_prfl_id, business_group_id'			      ||
           ' from ben_vrbl_rt_prfl_f vpf'				      ||
           ' where business_group_id = ' || to_char(p_business_group_id)      ||
           ' and exists (select null'					      ||
    		      ' from BEN_ENRLD_ANTHR_PL_RT_F enl'		      ||
    		      ' where enl.vrbl_rt_prfl_id = vpf.vrbl_rt_prfl_id'      ||
    		      ' and ' || date_str(p_lf_evt_ocrd_dt,p_effective_date)  ||
    			     ' between enl.effective_start_date'	      ||
    				 ' and enl.effective_end_date) '	      ||
    	' and ' || date_str(p_lf_evt_ocrd_dt, p_effective_date) 	      ||
    	      ' between vpf.effective_start_date and vpf.effective_end_date;';
        --
        l_inst_query :=
          'select enl.vrbl_rt_prfl_id, enl.pl_id,'		   	   ||
          ' enl.enrl_det_dt_cd , enl.excld_flag '	   		   ||
          ' from BEN_ENRLD_ANTHR_PL_RT_F enl'			   ||
          ' where enl.business_group_id = ' || to_char(p_business_group_id)  ||
          ' and ' || date_str(p_lf_evt_ocrd_dt, p_effective_date) 	   ||
    	      ' between enl.effective_start_date'			   ||
    		  ' and enl.effective_end_date' 			   ||
          ' order by enl.vrbl_rt_prfl_id;';
        --
        l_instcolnm_set(0).col_name    := 'vrbl_rt_prfl_id';
        l_instcolnm_set(0).caccol_name := 'id';
        l_instcolnm_set(1).col_name    := 'pl_id';
        l_instcolnm_set(1).caccol_name := 'pl_id';
        l_instcolnm_set(2).col_name    := 'enrl_det_dt_cd';
        l_instcolnm_set(2).caccol_name := 'enrl_det_dt_cd';
        l_instcolnm_set(3).col_name    := 'excld_flag';
        l_instcolnm_set(3).caccol_name := 'excld_flag';
        --
        --
        ben_cache.write_mastDet_Cache
          (p_mastercol_name => 'vrbl_rt_prfl_id'
          ,p_detailcol_name => 'vrbl_rt_prfl_id'
          ,p_lkup_name	  => 'ben_rt_prfl_cache.g_enrld_anthr_pl_lookup'
          ,p_inst_name	  => 'ben_rt_prfl_cache.g_enrld_anthr_pl_instance'
          ,p_lkup_query	  => l_lookup_query
          ,p_inst_query	  => l_inst_query
          ,p_instcolnm_set  => l_instcolnm_set
          );
        --
      end if;
      --
      -- Cache already populated. Get record set.
      --
      get_cached_data
        (p_vrbl_rt_prfl_id => p_vrbl_rt_prfl_id
        ,p_lookup_name     => 'ben_rt_prfl_cache.g_enrld_anthr_pl_lookup'
        ,p_inst_name       => 'ben_rt_prfl_cache.g_enrld_anthr_pl_instance'
        ,p_inst_set_type   => 'ben_rt_prfl_cache.g_enrld_anthr_pl_inst_tbl'
        ,p_out_inst_name   => 'ben_rt_prfl_cache.g_enrld_anthr_pl_out'
        );
      --
      p_inst_set := g_enrld_anthr_pl_out;
      p_inst_count := g_inst_count;
      --
exception
      --
      when no_data_found then
        --
        p_inst_count := 0;
        hr_utility.set_location('Enrolled Another Plan', 90);
        hr_utility.set_location('Leaving : ' || l_proc, 99);
        --
end ;
--
------------------------------------------------------------------------
-- EAO Enrolled Another Option in Plan
------------------------------------------------------------------------
--
procedure get_rt_prfl_cache
  (p_vrbl_rt_prfl_id   in number
  ,p_effective_date    in date
  ,p_lf_evt_ocrd_dt    in date
  ,p_business_group_id in number
  ,p_inst_set	       in out NOCOPY ben_rt_prfl_cache.g_enrld_anthr_oipl_inst_tbl
  ,p_inst_count        out nocopy number) as
 --
      l_proc varchar2(80) := g_package || '.get_rt_prfl_cache';
      l_lookup_query long;
      l_inst_query	 long;
      l_instcolnm_set ben_cache.instcolnmtype;
      --
begin
      --
      g_enrld_anthr_oipl_out.delete;
      --
      if g_enrld_anthr_oipl_lookup.count = 0 then
        --
        -- Cache not populated yet. So populate it now.
        --
        l_lookup_query :=
          'select vrbl_rt_prfl_id, business_group_id'			      ||
           ' from ben_vrbl_rt_prfl_f vpf'				      ||
           ' where business_group_id = ' || to_char(p_business_group_id)      ||
           ' and exists (select null'					      ||
    		      ' from BEN_ENRLD_ANTHR_OIPL_RT_F eao'		      ||
    		      ' where eao.vrbl_rt_prfl_id = vpf.vrbl_rt_prfl_id'      ||
    		      ' and ' || date_str(p_lf_evt_ocrd_dt,p_effective_date)  ||
    			     ' between eao.effective_start_date'	      ||
    				 ' and eao.effective_end_date) '	      ||
    	' and ' || date_str(p_lf_evt_ocrd_dt, p_effective_date) 	      ||
    	      ' between vpf.effective_start_date and vpf.effective_end_date;';
        --
        l_inst_query :=
          'select eao.vrbl_rt_prfl_id, eao.oipl_id,'		   	   ||
          ' eao.enrl_det_dt_cd , eao.excld_flag '	   		   ||
          ' from BEN_ENRLD_ANTHR_OIPL_RT_F eao'			   ||
          ' where eao.business_group_id = ' || to_char(p_business_group_id)  ||
          ' and ' || date_str(p_lf_evt_ocrd_dt, p_effective_date) 	   ||
    	      ' between eao.effective_start_date'			   ||
    		  ' and eao.effective_end_date' 			   ||
          ' order by eao.vrbl_rt_prfl_id;';
        --
        l_instcolnm_set(0).col_name    := 'vrbl_rt_prfl_id';
        l_instcolnm_set(0).caccol_name := 'id';
        l_instcolnm_set(1).col_name    := 'oipl_id';
        l_instcolnm_set(1).caccol_name := 'oipl_id';
        l_instcolnm_set(2).col_name    := 'enrl_det_dt_cd';
        l_instcolnm_set(2).caccol_name := 'enrl_det_dt_cd';
        l_instcolnm_set(3).col_name    := 'excld_flag';
        l_instcolnm_set(3).caccol_name := 'excld_flag';
        --
        --
        ben_cache.write_mastDet_Cache
          (p_mastercol_name => 'vrbl_rt_prfl_id'
          ,p_detailcol_name => 'vrbl_rt_prfl_id'
          ,p_lkup_name	  => 'ben_rt_prfl_cache.g_enrld_anthr_oipl_lookup'
          ,p_inst_name	  => 'ben_rt_prfl_cache.g_enrld_anthr_oipl_instance'
          ,p_lkup_query	  => l_lookup_query
          ,p_inst_query	  => l_inst_query
          ,p_instcolnm_set  => l_instcolnm_set
          );
        --
      end if;
      --
      -- Cache already populated. Get record set.
      --
      get_cached_data
        (p_vrbl_rt_prfl_id => p_vrbl_rt_prfl_id
        ,p_lookup_name     => 'ben_rt_prfl_cache.g_enrld_anthr_oipl_lookup'
        ,p_inst_name       => 'ben_rt_prfl_cache.g_enrld_anthr_oipl_instance'
        ,p_inst_set_type   => 'ben_rt_prfl_cache.g_enrld_anthr_oipl_inst_tbl'
        ,p_out_inst_name   => 'ben_rt_prfl_cache.g_enrld_anthr_oipl_out'
        );
      --
      p_inst_set := g_enrld_anthr_oipl_out;
      p_inst_count := g_inst_count;
      --
exception
      --
      when no_data_found then
        --
        p_inst_count := 0;
        hr_utility.set_location('Enrolled Another Option in Plan', 90);
        hr_utility.set_location('Leaving : ' || l_proc, 99);
        --
end ;
--
------------------------------------------------------------------------
-- EAR Enrolled Another Plan in Program
------------------------------------------------------------------------
--
procedure get_rt_prfl_cache
  (p_vrbl_rt_prfl_id   in number
  ,p_effective_date    in date
  ,p_lf_evt_ocrd_dt    in date
  ,p_business_group_id in number
  ,p_inst_set	       in out NOCOPY ben_rt_prfl_cache.g_enrld_anthr_plip_inst_tbl
  ,p_inst_count        out nocopy number) as
 --
      l_proc varchar2(80) := g_package || '.get_rt_prfl_cache';
      l_lookup_query long;
      l_inst_query	 long;
      l_instcolnm_set ben_cache.instcolnmtype;
      --
begin
      --
      g_enrld_anthr_plip_out.delete;
      --
      if g_enrld_anthr_plip_lookup.count = 0 then
        --
        -- Cache not populated yet. So populate it now.
        --
        l_lookup_query :=
          'select vrbl_rt_prfl_id, business_group_id'			      ||
           ' from ben_vrbl_rt_prfl_f vpf'				      ||
           ' where business_group_id = ' || to_char(p_business_group_id)      ||
           ' and exists (select null'					      ||
    		      ' from BEN_ENRLD_ANTHR_PLIP_RT_F ear'		      ||
    		      ' where ear.vrbl_rt_prfl_id = vpf.vrbl_rt_prfl_id'      ||
    		      ' and ' || date_str(p_lf_evt_ocrd_dt,p_effective_date)  ||
    			     ' between ear.effective_start_date'	      ||
    				 ' and ear.effective_end_date) '	      ||
    	' and ' || date_str(p_lf_evt_ocrd_dt, p_effective_date) 	      ||
    	      ' between vpf.effective_start_date and vpf.effective_end_date;';
        --
        l_inst_query :=
          'select ear.vrbl_rt_prfl_id, ear.plip_id,'		   	   ||
          ' ear.enrl_det_dt_cd , ear.excld_flag '	   		   ||
          ' from BEN_ENRLD_ANTHR_PLIP_RT_F ear'			   ||
          ' where ear.business_group_id = ' || to_char(p_business_group_id)  ||
          ' and ' || date_str(p_lf_evt_ocrd_dt, p_effective_date) 	   ||
    	      ' between ear.effective_start_date'			   ||
    		  ' and ear.effective_end_date' 			   ||
          ' order by ear.vrbl_rt_prfl_id;';
        --
        l_instcolnm_set(0).col_name    := 'vrbl_rt_prfl_id';
        l_instcolnm_set(0).caccol_name := 'id';
        l_instcolnm_set(1).col_name    := 'plip_id';
        l_instcolnm_set(1).caccol_name := 'plip_id';
        l_instcolnm_set(2).col_name    := 'enrl_det_dt_cd';
        l_instcolnm_set(2).caccol_name := 'enrl_det_dt_cd';
        l_instcolnm_set(3).col_name    := 'excld_flag';
        l_instcolnm_set(3).caccol_name := 'excld_flag';
        --
        --
        ben_cache.write_mastDet_Cache
          (p_mastercol_name => 'vrbl_rt_prfl_id'
          ,p_detailcol_name => 'vrbl_rt_prfl_id'
          ,p_lkup_name	  => 'ben_rt_prfl_cache.g_enrld_anthr_plip_lookup'
          ,p_inst_name	  => 'ben_rt_prfl_cache.g_enrld_anthr_plip_instance'
          ,p_lkup_query	  => l_lookup_query
          ,p_inst_query	  => l_inst_query
          ,p_instcolnm_set  => l_instcolnm_set
          );
        --
      end if;
      --
      -- Cache already populated. Get record set.
      --
      get_cached_data
        (p_vrbl_rt_prfl_id => p_vrbl_rt_prfl_id
        ,p_lookup_name     => 'ben_rt_prfl_cache.g_enrld_anthr_plip_lookup'
        ,p_inst_name       => 'ben_rt_prfl_cache.g_enrld_anthr_plip_instance'
        ,p_inst_set_type   => 'ben_rt_prfl_cache.g_enrld_anthr_plip_inst_tbl'
        ,p_out_inst_name   => 'ben_rt_prfl_cache.g_enrld_anthr_plip_out'
        );
      --
      p_inst_set := g_enrld_anthr_plip_out;
      p_inst_count := g_inst_count;
      --
exception
      --
      when no_data_found then
        --
        p_inst_count := 0;
        hr_utility.set_location('Enrolled Another Plan in Program', 90);
        hr_utility.set_location('Leaving : ' || l_proc, 99);
        --
end ;
--
------------------------------------------------------------------------
-- ENT Enrolled Another Plan Type in Program
------------------------------------------------------------------------
--
procedure get_rt_prfl_cache
  (p_vrbl_rt_prfl_id   in number
  ,p_effective_date    in date
  ,p_lf_evt_ocrd_dt    in date
  ,p_business_group_id in number
  ,p_inst_set	       in out NOCOPY ben_rt_prfl_cache.g_enrld_anthr_ptip_inst_tbl
  ,p_inst_count        out nocopy number) as
--
      l_proc varchar2(80) := g_package || '.get_rt_prfl_cache';
      l_lookup_query long;
      l_inst_query	 long;
      l_instcolnm_set ben_cache.instcolnmtype;
      --
begin
      --
      g_enrld_anthr_ptip_out.delete;
      --
      if g_enrld_anthr_ptip_lookup.count = 0 then
        --
        -- Cache not populated yet. So populate it now.
        --
        l_lookup_query :=
          'select vrbl_rt_prfl_id, business_group_id'			      ||
           ' from ben_vrbl_rt_prfl_f vpf'				      ||
           ' where business_group_id = ' || to_char(p_business_group_id)      ||
           ' and exists (select null'					      ||
    		      ' from BEN_ENRLD_ANTHR_PTIP_RT_F ent'		      ||
    		      ' where ent.vrbl_rt_prfl_id = vpf.vrbl_rt_prfl_id'      ||
    		      ' and ' || date_str(p_lf_evt_ocrd_dt,p_effective_date)  ||
    			     ' between ent.effective_start_date'	      ||
    				 ' and ent.effective_end_date) '	      ||
    	' and ' || date_str(p_lf_evt_ocrd_dt, p_effective_date) 	      ||
    	      ' between vpf.effective_start_date and vpf.effective_end_date;';
        --
        l_inst_query :=
          'select ent.vrbl_rt_prfl_id, ent.ptip_id,'			   	   ||
          ' ent.enrl_det_dt_cd , ent.excld_flag , ent.only_pls_subj_cobra_flag '   ||
          ' from BEN_ENRLD_ANTHR_PTIP_RT_F ent'					   ||
          ' where ent.business_group_id = ' || to_char(p_business_group_id)  	   ||
          ' and ' || date_str(p_lf_evt_ocrd_dt, p_effective_date) 	   	   ||
    	      ' between ent.effective_start_date'			   	   ||
    		  ' and ent.effective_end_date' 			       	   ||
          ' order by ent.vrbl_rt_prfl_id;';
        --
        l_instcolnm_set(0).col_name    := 'vrbl_rt_prfl_id';
        l_instcolnm_set(0).caccol_name := 'id';
        l_instcolnm_set(1).col_name    := 'ptip_id';
        l_instcolnm_set(1).caccol_name := 'ptip_id';
        l_instcolnm_set(2).col_name    := 'enrl_det_dt_cd';
        l_instcolnm_set(2).caccol_name := 'enrl_det_dt_cd';
        l_instcolnm_set(3).col_name    := 'excld_flag';
        l_instcolnm_set(3).caccol_name := 'excld_flag';
        l_instcolnm_set(4).col_name    := 'only_pls_subj_cobra_flag';
        l_instcolnm_set(4).caccol_name := 'only_pls_subj_cobra_flag';

        --
        --
        ben_cache.write_mastDet_Cache
          (p_mastercol_name => 'vrbl_rt_prfl_id'
          ,p_detailcol_name => 'vrbl_rt_prfl_id'
          ,p_lkup_name	  => 'ben_rt_prfl_cache.g_enrld_anthr_ptip_lookup'
          ,p_inst_name	  => 'ben_rt_prfl_cache.g_enrld_anthr_ptip_instance'
          ,p_lkup_query	  => l_lookup_query
          ,p_inst_query	  => l_inst_query
          ,p_instcolnm_set  => l_instcolnm_set
          );
        --
      end if;
      --
      -- Cache already populated. Get record set.
      --
      get_cached_data
        (p_vrbl_rt_prfl_id => p_vrbl_rt_prfl_id
        ,p_lookup_name     => 'ben_rt_prfl_cache.g_enrld_anthr_ptip_lookup'
        ,p_inst_name       => 'ben_rt_prfl_cache.g_enrld_anthr_ptip_instance'
        ,p_inst_set_type   => 'ben_rt_prfl_cache.g_enrld_anthr_ptip_inst_tbl'
        ,p_out_inst_name   => 'ben_rt_prfl_cache.g_enrld_anthr_ptip_out'
        );
      --
      p_inst_set := g_enrld_anthr_ptip_out;
      p_inst_count := g_inst_count;
      --
exception
      --
      when no_data_found then
        --
        p_inst_count := 0;
        hr_utility.set_location('Enrolled Another Plan Type in Program', 90);
        hr_utility.set_location('Leaving : ' || l_proc, 99);
        --
end ;
--
------------------------------------------------------------------------
-- EAG Enrolled Another Program
------------------------------------------------------------------------
--
procedure get_rt_prfl_cache
  (p_vrbl_rt_prfl_id   in number
  ,p_effective_date    in date
  ,p_lf_evt_ocrd_dt    in date
  ,p_business_group_id in number
  ,p_inst_set	       in out NOCOPY ben_rt_prfl_cache.g_enrld_anthr_pgm_inst_tbl
  ,p_inst_count        out nocopy number) as
--
      l_proc varchar2(80) := g_package || '.get_rt_prfl_cache';
      l_lookup_query long;
      l_inst_query	 long;
      l_instcolnm_set ben_cache.instcolnmtype;
      --
begin
      --
      g_enrld_anthr_pgm_out.delete;
      --
      if g_enrld_anthr_pgm_lookup.count = 0 then
        --
        -- Cache not populated yet. So populate it now.
        --
        l_lookup_query :=
          'select vrbl_rt_prfl_id, business_group_id'			      ||
           ' from ben_vrbl_rt_prfl_f vpf'				      ||
           ' where business_group_id = ' || to_char(p_business_group_id)      ||
           ' and exists (select null'					      ||
    		      ' from BEN_ENRLD_ANTHR_PGM_RT_F eag'		      ||
    		      ' where eag.vrbl_rt_prfl_id = vpf.vrbl_rt_prfl_id'      ||
    		      ' and ' || date_str(p_lf_evt_ocrd_dt,p_effective_date)  ||
    			     ' between eag.effective_start_date'	      ||
    				 ' and eag.effective_end_date) '	      ||
    	' and ' || date_str(p_lf_evt_ocrd_dt, p_effective_date) 	      ||
    	      ' between vpf.effective_start_date and vpf.effective_end_date;';
        --
        l_inst_query :=
          'select eag.vrbl_rt_prfl_id, eag.pgm_id,'			   	   ||
          ' eag.enrl_det_dt_cd , eag.excld_flag ' 				   ||
          ' from BEN_ENRLD_ANTHR_PGM_RT_F eag'					   ||
          ' where eag.business_group_id = ' || to_char(p_business_group_id)  	   ||
          ' and ' || date_str(p_lf_evt_ocrd_dt, p_effective_date) 	   	   ||
    	      ' between eag.effective_start_date'			   	   ||
    		  ' and eag.effective_end_date' 			       	   ||
          ' order by eag.vrbl_rt_prfl_id;';
        --
        l_instcolnm_set(0).col_name    := 'vrbl_rt_prfl_id';
        l_instcolnm_set(0).caccol_name := 'id';
        l_instcolnm_set(1).col_name    := 'pgm_id';
        l_instcolnm_set(1).caccol_name := 'pgm_id';
        l_instcolnm_set(2).col_name    := 'enrl_det_dt_cd';
        l_instcolnm_set(2).caccol_name := 'enrl_det_dt_cd';
        l_instcolnm_set(3).col_name    := 'excld_flag';
        l_instcolnm_set(3).caccol_name := 'excld_flag';

        --
        --
        ben_cache.write_mastDet_Cache
          (p_mastercol_name => 'vrbl_rt_prfl_id'
          ,p_detailcol_name => 'vrbl_rt_prfl_id'
          ,p_lkup_name	  => 'ben_rt_prfl_cache.g_enrld_anthr_pgm_lookup'
          ,p_inst_name	  => 'ben_rt_prfl_cache.g_enrld_anthr_pgm_instance'
          ,p_lkup_query	  => l_lookup_query
          ,p_inst_query	  => l_inst_query
          ,p_instcolnm_set  => l_instcolnm_set
          );
        --
      end if;
      --
      -- Cache already populated. Get record set.
      --
      get_cached_data
        (p_vrbl_rt_prfl_id => p_vrbl_rt_prfl_id
        ,p_lookup_name     => 'ben_rt_prfl_cache.g_enrld_anthr_pgm_lookup'
        ,p_inst_name       => 'ben_rt_prfl_cache.g_enrld_anthr_pgm_instance'
        ,p_inst_set_type   => 'ben_rt_prfl_cache.g_enrld_anthr_pgm_inst_tbl'
        ,p_out_inst_name   => 'ben_rt_prfl_cache.g_enrld_anthr_pgm_out'
        );
      --
      p_inst_set := g_enrld_anthr_pgm_out;
      p_inst_count := g_inst_count;
      --
exception
      --
      when no_data_found then
        --
        p_inst_count := 0;
        hr_utility.set_location('Enrolled Another Program', 90);
        hr_utility.set_location('Leaving : ' || l_proc, 99);
        --
end ;

------------------------------------------------------------------------
-- DOT Dependent Eligible for  another plan type in program
------------------------------------------------------------------------
--
procedure get_rt_prfl_cache
  (p_vrbl_rt_prfl_id   in number
  ,p_effective_date    in date
  ,p_lf_evt_ocrd_dt    in date
  ,p_business_group_id in number
  ,p_inst_set	       in out NOCOPY ben_rt_prfl_cache.g_dpnt_othr_ptip_inst_tbl
  ,p_inst_count        out nocopy number) as
--
      l_proc varchar2(80) := g_package || '.get_rt_prfl_cache';
      l_lookup_query long;
      l_inst_query	 long;
      l_instcolnm_set ben_cache.instcolnmtype;
      --
begin
      --
      g_dpnt_othr_ptip_out.delete;
      --
      if g_dpnt_othr_ptip_lookup.count = 0 then
        --
        -- Cache not populated yet. So populate it now.
        --
        l_lookup_query :=
          'select vrbl_rt_prfl_id, business_group_id'			      ||
           ' from ben_vrbl_rt_prfl_f vpf'				      ||
           ' where business_group_id = ' || to_char(p_business_group_id)      ||
           ' and exists (select null'					      ||
    		      ' from BEN_DPNT_OTHR_PTIP_RT_F dot'		      ||
    		      ' where dot.vrbl_rt_prfl_id = vpf.vrbl_rt_prfl_id'      ||
    		      ' and ' || date_str(p_lf_evt_ocrd_dt,p_effective_date)  ||
    			     ' between dot.effective_start_date'	      ||
    				 ' and dot.effective_end_date) '	      ||
    	' and ' || date_str(p_lf_evt_ocrd_dt, p_effective_date) 	      ||
    	      ' between vpf.effective_start_date and vpf.effective_end_date;';
        --
        l_inst_query :=
          'select dot.vrbl_rt_prfl_id, dot.ptip_id,'			   	   ||
          ' dot.excld_flag  '							   ||
          ' from BEN_DPNT_OTHR_PTIP_RT_F dot'					   ||
          ' where dot.business_group_id = ' || to_char(p_business_group_id)  	   ||
          ' and ' || date_str(p_lf_evt_ocrd_dt, p_effective_date) 	   	   ||
    	      ' between dot.effective_start_date'			   	   ||
    		  ' and dot.effective_end_date' 			       	   ||
          ' order by dot.vrbl_rt_prfl_id;';
        --
        l_instcolnm_set(0).col_name    := 'vrbl_rt_prfl_id';
        l_instcolnm_set(0).caccol_name := 'id';
        l_instcolnm_set(1).col_name    := 'ptip_id';
        l_instcolnm_set(1).caccol_name := 'ptip_id';
        l_instcolnm_set(2).col_name    := 'excld_flag';
        l_instcolnm_set(2).caccol_name := 'excld_flag';

        --
        --
        ben_cache.write_mastDet_Cache
          (p_mastercol_name => 'vrbl_rt_prfl_id'
          ,p_detailcol_name => 'vrbl_rt_prfl_id'
          ,p_lkup_name	  => 'ben_rt_prfl_cache.g_dpnt_othr_ptip_lookup'
          ,p_inst_name	  => 'ben_rt_prfl_cache.g_dpnt_othr_ptip_instance'
          ,p_lkup_query	  => l_lookup_query
          ,p_inst_query	  => l_inst_query
          ,p_instcolnm_set  => l_instcolnm_set
          );
        --
      end if;
      --
      -- Cache already populated. Get record set.
      --
      get_cached_data
        (p_vrbl_rt_prfl_id => p_vrbl_rt_prfl_id
        ,p_lookup_name     => 'ben_rt_prfl_cache.g_dpnt_othr_ptip_lookup'
        ,p_inst_name       => 'ben_rt_prfl_cache.g_dpnt_othr_ptip_instance'
        ,p_inst_set_type   => 'ben_rt_prfl_cache.g_dpnt_othr_ptip_inst_tbl'
        ,p_out_inst_name   => 'ben_rt_prfl_cache.g_dpnt_othr_ptip_out'
        );
      --
      p_inst_set := g_dpnt_othr_ptip_out;
      p_inst_count := g_inst_count;
      --
exception
      --
      when no_data_found then
        --
        p_inst_count := 0;
        hr_utility.set_location('Dependent covered in other plan type in program', 90);
        hr_utility.set_location('Leaving : ' || l_proc, 99);
        --
end ;
------------------------------------------------------------------------
-- NOC 	No Other Coverage
------------------------------------------------------------------------
--
procedure get_rt_prfl_cache
  (p_vrbl_rt_prfl_id   in number
  ,p_effective_date    in date
  ,p_lf_evt_ocrd_dt    in date
  ,p_business_group_id in number
  ,p_inst_set	       in out NOCOPY ben_rt_prfl_cache.g_no_othr_cvg_inst_tbl
  ,p_inst_count        out nocopy number) as
--
      l_proc varchar2(80) := g_package || '.get_rt_prfl_cache';
      l_lookup_query long;
      l_inst_query	 long;
      l_instcolnm_set ben_cache.instcolnmtype;
      --
begin
      --
      g_no_othr_cvg_out.delete;
      --
      if g_no_othr_cvg_lookup.count = 0 then
        --
        -- Cache not populated yet. So populate it now.
        --
        l_lookup_query :=
          'select vrbl_rt_prfl_id, business_group_id'			      ||
           ' from ben_vrbl_rt_prfl_f vpf'				      ||
           ' where business_group_id = ' || to_char(p_business_group_id)      ||
           ' and exists (select null'					      ||
    		      ' from BEN_NO_OTHR_CVG_RT_F noc'			      ||
    		      ' where noc.vrbl_rt_prfl_id = vpf.vrbl_rt_prfl_id'      ||
    		      ' and ' || date_str(p_lf_evt_ocrd_dt,p_effective_date)  ||
    			     ' between noc.effective_start_date'	      ||
    				 ' and noc.effective_end_date) '	      ||
    	' and ' || date_str(p_lf_evt_ocrd_dt, p_effective_date) 	      ||
    	      ' between vpf.effective_start_date and vpf.effective_end_date;';
        --
        l_inst_query :=
          'select noc.vrbl_rt_prfl_id, noc.coord_ben_no_cvg_flag '	   	   ||
          ' from BEN_NO_OTHR_CVG_RT_F noc'					   ||
          ' where noc.business_group_id = ' || to_char(p_business_group_id)  	   ||
          ' and ' || date_str(p_lf_evt_ocrd_dt, p_effective_date) 	   	   ||
    	      ' between noc.effective_start_date'			   	   ||
    		  ' and noc.effective_end_date' 			       	   ||
          ' order by noc.vrbl_rt_prfl_id;';
        --
        l_instcolnm_set(0).col_name    := 'vrbl_rt_prfl_id';
        l_instcolnm_set(0).caccol_name := 'id';
        l_instcolnm_set(1).col_name    := 'coord_ben_no_cvg_flag';
        l_instcolnm_set(1).caccol_name := 'coord_ben_no_cvg_flag';
        --
        --
        ben_cache.write_mastDet_Cache
          (p_mastercol_name => 'vrbl_rt_prfl_id'
          ,p_detailcol_name => 'vrbl_rt_prfl_id'
          ,p_lkup_name	  => 'ben_rt_prfl_cache.g_no_othr_cvg_lookup'
          ,p_inst_name	  => 'ben_rt_prfl_cache.g_no_othr_cvg_instance'
          ,p_lkup_query	  => l_lookup_query
          ,p_inst_query	  => l_inst_query
          ,p_instcolnm_set  => l_instcolnm_set
          );
        --
      end if;
      --
      -- Cache already populated. Get record set.
      --
      get_cached_data
        (p_vrbl_rt_prfl_id => p_vrbl_rt_prfl_id
        ,p_lookup_name     => 'ben_rt_prfl_cache.g_no_othr_cvg_lookup'
        ,p_inst_name       => 'ben_rt_prfl_cache.g_no_othr_cvg_instance'
        ,p_inst_set_type   => 'ben_rt_prfl_cache.g_no_othr_cvg_inst_tbl'
        ,p_out_inst_name   => 'ben_rt_prfl_cache.g_no_othr_cvg_out'
        );
      --
      p_inst_set := g_no_othr_cvg_out;
      p_inst_count := g_inst_count;
      --
exception
      --
      when no_data_found then
        --
        p_inst_count := 0;
        hr_utility.set_location('No Other Coverage', 90);
        hr_utility.set_location('Leaving : ' || l_proc, 99);
        --
end ;

------------------------------------------------------------------------
-- Quartile in Grade
------------------------------------------------------------------------
procedure get_rt_prfl_cache
  (p_vrbl_rt_prfl_id   in number
  ,p_effective_date    in date
  ,p_lf_evt_ocrd_dt    in date
  ,p_business_group_id in number
  ,p_inst_set	       in out NOCOPY ben_rt_prfl_cache.g_qua_in_gr_inst_tbl
  ,p_inst_count        out nocopy number)
is
  --
  l_proc varchar2(80) := g_package || '.get_rt_prfl_cache';
  l_lookup_query long;
  l_inst_query	 long;
  l_instcolnm_set ben_cache.instcolnmtype;
  --
begin
  --
  g_qua_in_gr_out.delete;
  --
  if g_qua_in_gr_lookup.count = 0 then
    --
    -- Cache not populated yet. So populate it now.
    --
    l_lookup_query :=
      'select vrbl_rt_prfl_id, business_group_id'			      ||
       ' from ben_vrbl_rt_prfl_f vpf'					      ||
      ' where business_group_id = ' || to_char(p_business_group_id)	      ||
	' and exists (select null'					      ||
		      ' from ben_qua_in_gr_rt_f qig'			              ||
		      ' where qig.vrbl_rt_prfl_id = vpf.vrbl_rt_prfl_id'      ||
		      ' and ' || date_str(p_lf_evt_ocrd_dt,p_effective_date)  ||
			     ' between qig.effective_start_date'	      ||
				 ' and qig.effective_end_date) '	      ||
	' and ' || date_str(p_lf_evt_ocrd_dt, p_effective_date) 	      ||
	      ' between vpf.effective_start_date and vpf.effective_end_date;';
    --
    l_inst_query :=
      'select qig.vrbl_rt_prfl_id, qig.quar_in_grade_cd, qig.excld_flag'	   ||
       ' from ben_qua_in_gr_rt_f qig'					   ||
      ' where qig.business_group_id = ' || to_char(p_business_group_id)    ||
	' and ' || date_str(p_lf_evt_ocrd_dt, p_effective_date) 	   ||
	      ' between qig.effective_start_date'			   ||
		  ' and qig.effective_end_date' 			   ||
      ' order by qig.vrbl_rt_prfl_id;';
    --
    l_instcolnm_set(0).col_name    := 'vrbl_rt_prfl_id';
    l_instcolnm_set(0).caccol_name := 'id';
    l_instcolnm_set(1).col_name    := 'quar_in_grade_cd';
    l_instcolnm_set(1).caccol_name := 'quar_in_grade_cd';
    l_instcolnm_set(2).col_name    := 'excld_flag';
    l_instcolnm_set(2).caccol_name := 'excld_flag';
    --
    ben_cache.write_mastDet_Cache
      (p_mastercol_name => 'vrbl_rt_prfl_id'
      ,p_detailcol_name => 'vrbl_rt_prfl_id'
      ,p_lkup_name	=> 'ben_rt_prfl_cache.g_qua_in_gr_lookup'
      ,p_inst_name	=> 'ben_rt_prfl_cache.g_qua_in_gr_instance'
      ,p_lkup_query	=> l_lookup_query
      ,p_inst_query	=> l_inst_query
      ,p_instcolnm_set	=> l_instcolnm_set
      );
    --
  end if;
  --
  -- Cache already populated. Get record set.
  --
  get_cached_data
    (p_vrbl_rt_prfl_id => p_vrbl_rt_prfl_id
    ,p_lookup_name     => 'ben_rt_prfl_cache.g_qua_in_gr_lookup'
    ,p_inst_name       => 'ben_rt_prfl_cache.g_qua_in_gr_instance'
    ,p_inst_set_type   => 'ben_rt_prfl_cache.g_qua_in_gr_inst_tbl'
    ,p_out_inst_name   => 'ben_rt_prfl_cache.g_qua_in_gr_out'
    );
  --
  p_inst_set := g_qua_in_gr_out;
  p_inst_count := g_inst_count;
  --
exception
  --
  when no_data_found then
    --
    p_inst_count := 0;
    hr_utility.set_location('No Quartile in Grade found', 90);
    hr_utility.set_location('Leaving : ' || l_proc, 99);
    --
end;

------------------------------------------------------------------------
-- Performance Rating
------------------------------------------------------------------------
procedure get_rt_prfl_cache
  (p_vrbl_rt_prfl_id   in number
  ,p_effective_date    in date
  ,p_lf_evt_ocrd_dt    in date
  ,p_business_group_id in number
  ,p_inst_set	       in out NOCOPY ben_rt_prfl_cache.g_perf_rtng_inst_tbl
  ,p_inst_count        out nocopy number)
is
  --
  l_proc varchar2(80) := g_package || '.get_rt_prfl_cache';
  l_lookup_query long;
  l_inst_query	 long;
  l_instcolnm_set ben_cache.instcolnmtype;
  --
begin
  --
  g_perf_rtng_out.delete;
  --
  if g_perf_rtng_lookup.count = 0 then
    --
    -- Cache not populated yet. So populate it now.
    --
    l_lookup_query :=
      'select vrbl_rt_prfl_id, business_group_id'			      ||
       ' from ben_vrbl_rt_prfl_f vpf'					      ||
       ' where business_group_id = ' || to_char(p_business_group_id)	      ||
       ' and exists (select null'					      ||
		      ' from ben_perf_rtng_rt_f prr'		      	      ||
		      ' where prr.vrbl_rt_prfl_id = vpf.vrbl_rt_prfl_id'      ||
		      ' and ' || date_str(p_lf_evt_ocrd_dt,p_effective_date)  ||
			     ' between prr.effective_start_date'	      ||
				 ' and prr.effective_end_date) '	      ||
	' and ' || date_str(p_lf_evt_ocrd_dt, p_effective_date) 	      ||
	      ' between vpf.effective_start_date and vpf.effective_end_date;';
    --
    l_inst_query :=
      'select prr.vrbl_rt_prfl_id, prr.perf_rtng_cd,'			   ||
      ' prr.event_type, prr.excld_flag'	   			   ||
      ' from ben_perf_rtng_rt_f prr'					   ||
      ' where prr.business_group_id = ' || to_char(p_business_group_id)    ||
      ' and ' || date_str(p_lf_evt_ocrd_dt, p_effective_date) 	  	   ||
	      ' between prr.effective_start_date'			   ||
		  ' and prr.effective_end_date' 			   ||
      ' order by prr.vrbl_rt_prfl_id;';
    --
    l_instcolnm_set(0).col_name    := 'vrbl_rt_prfl_id';
    l_instcolnm_set(0).caccol_name := 'id';
    l_instcolnm_set(1).col_name    := 'perf_rtng_cd';
    l_instcolnm_set(1).caccol_name := 'perf_rtng_cd';
    l_instcolnm_set(2).col_name    := 'event_type';
    l_instcolnm_set(2).caccol_name := 'event_type';
    l_instcolnm_set(3).col_name    := 'excld_flag';
    l_instcolnm_set(3).caccol_name := 'excld_flag';
    --
    ben_cache.write_mastDet_Cache
      (p_mastercol_name => 'vrbl_rt_prfl_id'
      ,p_detailcol_name => 'vrbl_rt_prfl_id'
      ,p_lkup_name	=> 'ben_rt_prfl_cache.g_perf_rtng_lookup'
      ,p_inst_name	=> 'ben_rt_prfl_cache.g_perf_rtng_instance'
      ,p_lkup_query	=> l_lookup_query
      ,p_inst_query	=> l_inst_query
      ,p_instcolnm_set	=> l_instcolnm_set
      );
    --
  end if;
  --
  -- Cache already populated. Get record set.
  --
  get_cached_data
    (p_vrbl_rt_prfl_id => p_vrbl_rt_prfl_id
    ,p_lookup_name     => 'ben_rt_prfl_cache.g_perf_rtng_lookup'
    ,p_inst_name       => 'ben_rt_prfl_cache.g_perf_rtng_instance'
    ,p_inst_set_type   => 'ben_rt_prfl_cache.g_perf_rtng_inst_tbl'
    ,p_out_inst_name   => 'ben_rt_prfl_cache.g_perf_rtng_out'
    );
  --
  p_inst_set := g_perf_rtng_out;
  p_inst_count := g_inst_count;
  --
exception
  --
  when no_data_found then
    --
    p_inst_count := 0;
    hr_utility.set_location('No performance rating found', 90);
    hr_utility.set_location('Leaving : ' || l_proc, 99);
    --
end;

------------------------------------------------------------------------
-- DELETE ALL CACHED DATA
------------------------------------------------------------------------
procedure clear_down_cache
is
begin
  --
  g_pg_lookup.delete;
  g_pg_instance.delete;
  g_rl_lookup.delete;
  g_rl_instance.delete;
  g_tbco_lookup.delete;
  g_tbco_instance.delete;
  g_gndr_lookup.delete;
  g_gndr_instance.delete;
  g_brgng_lookup.delete;
  g_brgng_instance.delete;
  g_bnfgrp_lookup.delete;
  g_bnfgrp_instance.delete;
  g_eestat_lookup.delete;
  g_eestat_instance.delete;
  g_ftpt_lookup.delete;
  g_ftpt_instance.delete;
  g_grd_lookup.delete;
  g_grd_instance.delete;
  g_pctft_lookup.delete;
  g_pctft_instance.delete;
  g_hrswkd_lookup.delete;
  g_hrswkd_instance.delete;
  g_lbrmmbr_lookup.delete;
  g_lbrmmbr_instance.delete;
  g_lglenty_lookup.delete;
  g_lglenty_instance.delete;
  g_loa_lookup.delete;
  g_loa_instance.delete;
  g_org_lookup.delete;
  g_org_instance.delete;
  g_pertyp_lookup.delete;
  g_pertyp_instance.delete;
  g_ziprng_lookup.delete;
  g_ziprng_instance.delete;
  g_pyrl_lookup.delete;
  g_pyrl_instance.delete;
  g_py_bss_lookup.delete;
  g_py_bss_instance.delete;
  g_scdhrs_lookup.delete;
  g_scdhrs_instance.delete;
  g_wkloc_lookup.delete;
  g_wkloc_instance.delete;
  g_svcarea_lookup.delete;
  g_svcarea_instance.delete;
  g_hrlyslrd_lookup.delete;
  g_hrlyslrd_instance.delete;
  g_age_lookup.delete;
  g_age_instance.delete;
  g_complvl_lookup.delete;
  g_complvl_instance.delete;
  g_los_lookup.delete;
  g_los_instance.delete;
  g_age_los_lookup.delete;
  g_age_los_instance.delete;

  g_job_lookup.delete;
  g_job_instance.delete;

  g_optd_mdcr_lookup.delete;
  g_optd_mdcr_instance.delete;

  g_lvg_rsn_lookup.delete;
  g_lvg_rsn_instance.delete;

  g_cbr_qual_bnf_lookup.delete;
  g_cbr_qual_bnf_instance.delete;

  g_qual_titl_lookup.delete;
  g_qual_titl_instance.delete;

  g_cntng_prtn_prfl_lookup.delete;
  g_cntng_prtn_prfl_instance.delete;

  g_pstn_lookup.delete;
  g_pstn_instance.delete;

  g_comptncy_lookup.delete;
  g_comptncy_instance.delete;
  --
  g_no_othr_cvg_lookup.delete;
  g_no_othr_cvg_instance.delete;

  g_dpnt_othr_ptip_lookup.delete;
  g_dpnt_othr_ptip_instance.delete;

  g_enrld_anthr_pgm_lookup.delete;
  g_enrld_anthr_pgm_instance.delete;


  g_enrld_anthr_ptip_lookup.delete;
  g_enrld_anthr_ptip_instance.delete;

  g_enrld_anthr_plip_lookup.delete;
  g_enrld_anthr_plip_instance.delete;

  g_enrld_anthr_oipl_lookup.delete;
  g_enrld_anthr_oipl_instance.delete;

  g_enrld_anthr_pl_lookup.delete;
  g_enrld_anthr_pl_instance.delete;

  g_othr_ptip_lookup.delete;
  g_othr_ptip_instance.delete;

  g_prtt_anthr_pl_lookup.delete;
  g_prtt_anthr_pl_instance.delete;

  g_dpnt_cvrd_othr_pgm_lookup.delete;
  g_dpnt_cvrd_othr_pgm_instance.delete;

  g_dpnt_cvrd_othr_ptip_lookup.delete;
  g_dpnt_cvrd_othr_ptip_instance.delete;

  g_dpnt_cvrd_othr_plip_lookup.delete;
  g_dpnt_cvrd_othr_plip_instance.delete;

  g_dpnt_cvrd_othr_pl_lookup.delete;
  g_dpnt_cvrd_othr_pl_instance.delete;
  --

  g_qua_in_gr_lookup.delete;
  g_qua_in_gr_instance.delete;

  g_perf_rtng_lookup.delete;
  g_perf_rtng_instance.delete;

--Bug 6412287
  g_poe_lookup.delete;
  g_poe_instance.delete;
--End Bug 6412287

end clear_down_cache;
--
end ben_rt_prfl_cache;

/
