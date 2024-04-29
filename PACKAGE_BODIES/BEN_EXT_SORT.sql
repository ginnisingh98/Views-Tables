--------------------------------------------------------
--  DDL for Package Body BEN_EXT_SORT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_EXT_SORT" as
/* $Header: benxsort.pkb 120.0 2005/05/28 09:47:15 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  ben_ext_sort.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< main >---------------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE main
    (                        p_ext_rcd_in_file_id         in number,
                             p_sort1_data_elmt_in_rcd_id  in number,
                             p_sort2_data_elmt_in_rcd_id  in number,
                             p_sort3_data_elmt_in_rcd_id  in number,
                             p_sort4_data_elmt_in_rcd_id  in number,
                             p_rcd_seq_num                in number,
                             p_low_lvl_cd                 in varchar2,
                             p_prmy_sort_val              out nocopy varchar2,
                             p_scnd_sort_val              out nocopy varchar2,
                             p_thrd_sort_val              out nocopy varchar2) is
 --
  l_proc             varchar2(72) := g_package||'main';
 --
  l_plane                   number;
  l_prmy_seq_num            number;
  l_scnd_seq_num            number;
  l_thrd_seq_num            number;
  l_frth_seq_num            number;
  l_prmy_val                ben_ext_rslt_dtl.val_01%type  := null;
  l_scnd_val                ben_ext_rslt_dtl.val_01%type  := null;
  l_thrd_val                ben_ext_rslt_dtl.val_01%type  := null;
  l_frth_val                ben_ext_rslt_dtl.val_01%type  := null;
  l_trans_count             varchar2(50);
  l_person_id               varchar2(55);
  l_ext_chg_evt_log_id      varchar2(55);
  l_per_cm_prvdd_id         varchar2(15);
  l_dflt_id                 number;
  l_dflt_val                ben_ext_rslt_dtl.val_01%type  := null;
  l_prmy_val_max            number := 25;
  l_scnd_val_max            number := 25;
  l_thrd_val_max            number := 25;
  l_frth_val_max            number := 25;
  l_person_id_max           number := 15;
  l_dflt_id_max             number := 15;
  g_ext_chg_evt_log_id_max  number := 15;
  g_per_cm_prvdd_id_max     number := 10;
  g_elig_pl_ord_no_max      number :=  8;
  g_elig_opt_ord_no_max     number :=  7;
  l_trans_count_max         number := 10;
  l_start_position          number;
 --

  cursor c_get_seq_num (p_ext_data_elmt_in_rcd_id in number) is
    select  xer.seq_num
      from  ben_ext_data_elmt_in_rcd xer
     where  xer.ext_data_elmt_in_rcd_id = p_ext_data_elmt_in_rcd_id;

 --
 BEGIN
 --
   hr_utility.set_location('Entering'||l_proc, 5);
 --

   if p_low_lvl_cd = 'P' then  -- pers
     l_plane := 1;
   elsif p_low_lvl_cd in ('E','G','Y','R','F','CO','WG','WR') then  --enrt, elig, ele, run, cwb grp, cwb rate
     l_plane := 2;
   elsif p_low_lvl_cd in ('D','B','A','ED','PR') then  -- dpnt, bnf, act itm, el dpnt,prem.
     l_plane := 3;
   else  -- no sorting should occur
     hr_utility.set_location('return withoit '||p_low_lvl_cd, 5);
     return;
   end if;
 --
 g_trans_count := g_trans_count + 1;
 --
 -- consider caching for efficiency.
 --
   if p_sort1_data_elmt_in_rcd_id is not null then
     open c_get_seq_num(p_sort1_data_elmt_in_rcd_id);
     fetch c_get_seq_num into l_prmy_seq_num;
     close c_get_seq_num;
     l_prmy_val := nvl(substr(ben_ext_fmt.g_val_tab(l_prmy_seq_num),1,l_prmy_val_max),' ');
   end if;

   if p_sort2_data_elmt_in_rcd_id is not null then
     open c_get_seq_num(p_sort2_data_elmt_in_rcd_id);
     fetch c_get_seq_num into l_scnd_seq_num;
     close c_get_seq_num;
     l_scnd_val := nvl(substr(ben_ext_fmt.g_val_tab(l_scnd_seq_num),1,l_scnd_val_max),' ');
   end if;

   if p_sort3_data_elmt_in_rcd_id is not null then
     open c_get_seq_num(p_sort3_data_elmt_in_rcd_id);
     fetch c_get_seq_num into l_thrd_seq_num;
     close c_get_seq_num;
     l_thrd_val := nvl(substr(ben_ext_fmt.g_val_tab(l_thrd_seq_num),1,l_thrd_val_max),' ');
   end if;

   if p_sort4_data_elmt_in_rcd_id is not null then
     open c_get_seq_num(p_sort4_data_elmt_in_rcd_id);
     fetch c_get_seq_num into l_frth_seq_num;
     close c_get_seq_num;
     l_frth_val := nvl(substr(ben_ext_fmt.g_val_tab(l_frth_seq_num),1,l_frth_val_max),' ');
   end if;

--
   l_trans_count := lpad(to_char(g_trans_count),l_trans_count_max,'0');
--
   if l_plane = 1 then
--
   l_start_position := 1;

   if l_prmy_val is null then
     l_prmy_val := nvl(substr(g_prmy_sort_val,l_start_position,l_prmy_val_max),' '); -- inherit from previous record
   end if;

   l_start_position := l_start_position + l_prmy_val_max;

   if l_scnd_val is null then
     l_scnd_val := nvl(substr(g_prmy_sort_val,l_start_position,l_scnd_val_max),' ');
   end if;

   l_start_position := l_start_position + l_scnd_val_max;

   if l_thrd_val is null then
     l_thrd_val := nvl(substr(g_prmy_sort_val,l_start_position,l_thrd_val_max),' ');
   end if;

   l_start_position := l_start_position + l_thrd_val_max;

   if l_frth_val is null then
     l_frth_val := nvl(substr(g_prmy_sort_val,l_start_position,l_frth_val_max),' ');
   end if;
--
   l_prmy_val := rpad(l_prmy_val,l_prmy_val_max);
   l_scnd_val := rpad(l_scnd_val,l_scnd_val_max);
   l_thrd_val := rpad(l_thrd_val,l_thrd_val_max);
   l_frth_val := rpad(l_frth_val,l_frth_val_max);
--
   l_person_id := lpad(to_char(ben_ext_person.g_person_id),l_person_id_max,'0');
   l_ext_chg_evt_log_id := lpad(to_char(nvl(ben_ext_person.g_ext_chg_evt_log_id,0)),g_ext_chg_evt_log_id_max,'0');
   l_per_cm_prvdd_id := lpad(to_char(nvl(ben_ext_person.g_per_cm_prvdd_id,0)),g_per_cm_prvdd_id_max,'0');
--
      g_prmy_sort_val := l_prmy_val ||
                         l_scnd_val ||
                         l_thrd_val ||
                         l_frth_val ||
                         l_person_id ||  -- 1st default
                         l_ext_chg_evt_log_id ||  -- 2nd default
                         l_per_cm_prvdd_id || -- 3rd default
                         l_trans_count; -- handles same plane ordering.
--
      g_scnd_sort_val := '0';
      g_thrd_sort_val := '0';
--
    elsif l_plane = 2 then
--
   l_start_position := 2;

   if l_prmy_val is null then
     l_prmy_val := nvl(substr(g_scnd_sort_val,l_start_position,l_prmy_val_max),' ');
   end if;

   l_start_position := l_start_position + l_prmy_val_max;

   if l_scnd_val is null then
     l_scnd_val := nvl(substr(g_scnd_sort_val,l_start_position,l_scnd_val_max),' ');
   end if;

   l_start_position := l_start_position + l_scnd_val_max;

   if l_thrd_val is null then
     l_thrd_val := nvl(substr(g_scnd_sort_val,l_start_position,l_thrd_val_max),' ');
   end if;

   l_start_position := l_start_position + l_thrd_val_max;

   if l_frth_val is null then
     l_frth_val := nvl(substr(g_scnd_sort_val,l_start_position,l_frth_val_max),' ');
   end if;
--
   l_prmy_val := rpad(l_prmy_val,l_prmy_val_max);
   l_scnd_val := rpad(l_scnd_val,l_scnd_val_max);
   l_thrd_val := rpad(l_thrd_val,l_thrd_val_max);
   l_frth_val := rpad(l_frth_val,l_frth_val_max);
--
      if p_low_lvl_cd = 'E' then
        l_dflt_id := ben_ext_person.g_enrt_benefit_order_num;
        l_dflt_val := lpad(to_char(nvl(l_dflt_id,0)),l_dflt_id_max,'0');
      elsif p_low_lvl_cd = 'G' then
        l_dflt_val := lpad(to_char(nvl(ben_ext_person.g_elig_pl_ord_no,0)),g_elig_pl_ord_no_max,'0')||
         lpad(to_char(nvl(ben_ext_person.g_elig_opt_ord_no,0)),g_elig_opt_ord_no_max,'0');
      elsif p_low_lvl_cd = 'Y' then
        l_dflt_id := ben_ext_person.g_element_input_value_sequence;
        l_dflt_val := lpad(to_char(nvl(l_dflt_id,0)),l_dflt_id_max,'0');
      elsif p_low_lvl_cd = 'R' then
        l_dflt_id := ben_ext_person.g_runrslt_input_value_sequence;
        l_dflt_val := lpad(to_char(nvl(l_dflt_id,0)),l_dflt_id_max,'0');
      elsif p_low_lvl_cd = 'CO' then
        l_dflt_id := ben_ext_person.g_contact_seq_num;
        l_dflt_val := lpad(to_char(nvl(l_dflt_id,0)),l_dflt_id_max,'0');
      elsif p_low_lvl_cd = 'F' then
        l_dflt_val := ben_ext_person.g_flex_bnft_pool_name;
      elsif p_low_lvl_cd = 'WG' then
        l_dflt_val :=    ben_ext_person.g_CWB_Budget_Group_Plan_Name ;
      elsif p_low_lvl_cd = 'WR' then
        l_dflt_val :=    ben_ext_person.g_CWB_Awrd_Group_Plan_Name ;

      end if;
--
      g_scnd_sort_val := '1' ||
                         l_prmy_val ||
                         l_scnd_val ||
                         l_thrd_val ||
                         l_frth_val ||
                         l_dflt_val ||
                         l_trans_count;
--
      g_thrd_sort_val := '0';
--
    else -- l_plane = 3
--
   l_start_position := 2;

   if l_prmy_val is null then
     l_prmy_val := nvl(substr(g_thrd_sort_val,l_start_position,l_prmy_val_max),' ');
   end if;

   l_start_position := l_start_position + l_prmy_val_max;

   if l_scnd_val is null then
     l_scnd_val := nvl(substr(g_thrd_sort_val,l_start_position,l_scnd_val_max),' ');
   end if;

   l_start_position := l_start_position + l_scnd_val_max;

   if l_thrd_val is null then
     l_thrd_val := nvl(substr(g_thrd_sort_val,l_start_position,l_thrd_val_max),' ');
   end if;

   l_start_position := l_start_position + l_thrd_val_max;

   if l_frth_val is null then
     l_frth_val := nvl(substr(g_thrd_sort_val,l_start_position,l_frth_val_max),' ');
   end if;
--
   l_prmy_val := rpad(l_prmy_val,l_prmy_val_max);
   l_scnd_val := rpad(l_scnd_val,l_scnd_val_max);
   l_thrd_val := rpad(l_thrd_val,l_thrd_val_max);
   l_frth_val := rpad(l_frth_val,l_frth_val_max);
--
      if p_low_lvl_cd = 'D' then
        l_dflt_id := ben_ext_person.g_dpnt_contact_seq_num;
      elsif p_low_lvl_cd = 'B' then
        l_dflt_id := ben_ext_person.g_bnf_contact_seq_num;
      elsif p_low_lvl_cd = 'ED' then
        l_dflt_id := ben_ext_person.g_elig_dpnt_contact_seq_num;
      elsif p_low_lvl_cd = 'A' then
        l_dflt_id := ben_ext_person.g_actn_type_id;
      elsif p_low_lvl_cd = 'PR' then
        l_dflt_val := ben_ext_person.g_prem_type;
      end if;
--
      if p_low_lvl_cd <> 'PR' then
        l_dflt_val := lpad(to_char(nvl(l_dflt_id,0)),l_dflt_id_max,'0');
      end if;
--
      g_thrd_sort_val := '1' ||
                         l_prmy_val ||
                         l_scnd_val ||
                         l_thrd_val ||
                         l_frth_val ||
                         l_dflt_val ||
                         l_trans_count;
--
   end if;  -- l_plane
--
   p_prmy_sort_val := g_prmy_sort_val;
   p_scnd_sort_val := g_scnd_sort_val;
   p_thrd_sort_val := g_thrd_sort_val;
--
   hr_utility.set_location('Exiting'||l_proc, 15);
--
 END; -- main
--
END; -- package

/
