--------------------------------------------------------
--  DDL for Package Body BEN_EXTRACT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_EXTRACT" as
/* $Header: benxtrct.pkb 120.11.12010000.2 2008/08/05 15:01:27 ubhat ship $ */
--
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_extract.';  -- Global package name
--
g_debug boolean := hr_utility.debug_enabled;
--
Procedure setup_rcd_typ_lvl (
  p_ext_file_id             in number
)
is
-- ----------------------------------------------------------------------------
-- |------< setup_rcd_typ_lvl >------|-private-
-- ----------------------------------------------------------------------------
--
  l_proc                        varchar2(72);

  lb_rec_not_exists             BOOLEAN :=TRUE;
--

  cursor ext_rcd_rqd_c (
    p_ext_file_id IN NUMBER
  )
  is
     select distinct a.low_lvl_cd
       from ben_ext_rcd          a,
            ben_ext_rcd_in_file  b
       where a.ext_rcd_id  = b.ext_rcd_id
         and b.ext_file_id = p_ext_file_id
         and b.rqd_flag = 'Y'
         -- Bug fix 1702733 - header/trailer type records should not be checked for required flag = 'Y' here
         --                   since they never get proccessed in xtrct_skltn. Also, ben_ext_person.process_ext_recs
         --                   processes only Detail Type records.
         --                   Hence the gtt_rcd_rqd_vals.rcd_found flag for 'H'/'T' type records, if retreived,
         --                   remains unchanged as FALSE, and this leads to raising of required_error exception
         --                   in ben_ext_person.process_ext_levels.
         and a.rcd_type_cd = 'D'
         -- end fix 1702733
         and a.low_lvl_cd <> 'P';




  cursor ext_rcd_rqd_seq_c (
    p_ext_file_id IN NUMBER
  )
  is
     select a.low_lvl_cd,b.seq_num
       from ben_ext_rcd          a,
            ben_ext_rcd_in_file  b
       where a.ext_rcd_id  = b.ext_rcd_id
         and b.ext_file_id = p_ext_file_id
         and b.rqd_flag = 'Y'
         and a.rcd_type_cd in ( 'D','S') ;   -- subheader
         -- we need person level, person may be excluded if he does no have address
         --and a.low_lvl_cd <> 'P';



  cursor ext_rcd_typ_c (
    p_ext_file_id IN NUMBER
  )
  is
     select a.ext_rcd_id,
            b.sort1_data_elmt_in_rcd_id,
            b.sort2_data_elmt_in_rcd_id,
            b.sort3_data_elmt_in_rcd_id,
            b.sort4_data_elmt_in_rcd_id,
            b.ext_rcd_in_file_id,
            b.seq_num,
            b.sprs_cd,
            b.any_or_all_cd,
            a.rcd_type_cd,
            a.low_lvl_cd
       from ben_ext_rcd          a,
            ben_ext_rcd_in_file  b
       where a.ext_rcd_id  = b.ext_rcd_id
         and b.ext_file_id = p_ext_file_id
     order by b.seq_num;

--
Begin
  --
  g_debug := hr_utility.debug_enabled;
  if g_debug then
    l_proc := g_package||'setup_rcd_typ_lvl';
    hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
  --
  /*
    nw variable created with seq number
  FOR rqd IN ext_rcd_rqd_c (p_ext_file_id => p_ext_file_id)
  LOOP
    lb_rec_not_exists := FALSE;

    gtt_rcd_rqd_vals(ext_rcd_rqd_c%rowcount).low_lvl_cd := rqd.low_lvl_cd;
    gtt_rcd_rqd_vals(ext_rcd_rqd_c%rowcount).rcd_found := FALSE;

  END LOOP;

  IF lb_rec_not_exists
  THEN
    gtt_rcd_rqd_vals(1).low_lvl_cd := 'NOREQDRCD';
    gtt_rcd_rqd_vals(1).rcd_found  := TRUE;
  END IF;
  */

  -- reocrd level mandatory , not low level

  lb_rec_not_exists:= TRUE;
  FOR rqd IN ext_rcd_rqd_seq_c (p_ext_file_id => p_ext_file_id)
  LOOP
    lb_rec_not_exists := FALSE;

    gtt_rcd_rqd_vals_seq(ext_rcd_rqd_seq_c%rowcount).low_lvl_cd := rqd.low_lvl_cd;
    gtt_rcd_rqd_vals_seq(ext_rcd_rqd_seq_c%rowcount).rcd_found  := FALSE;
    gtt_rcd_rqd_vals_seq(ext_rcd_rqd_seq_c%rowcount).seq_num    := rqd.seq_num ;

  END LOOP;

  IF lb_rec_not_exists
  THEN
    gtt_rcd_rqd_vals_seq(1).low_lvl_cd := 'NOREQDRCD';
    gtt_rcd_rqd_vals_seq(1).rcd_found  := TRUE;
  END IF;
  -- eof




  lb_rec_not_exists:= TRUE;

  FOR rtyp IN ext_rcd_typ_c (p_ext_file_id => p_ext_file_id)
  LOOP
    lb_rec_not_exists := FALSE;
    gtt_rcd_typ_vals(ext_rcd_typ_c%rowcount).ext_rcd_id
      := rtyp.ext_rcd_id;
    gtt_rcd_typ_vals(ext_rcd_typ_c%rowcount).sort1
      := rtyp.sort1_data_elmt_in_rcd_id;
    gtt_rcd_typ_vals(ext_rcd_typ_c%rowcount).sort2
      := rtyp.sort2_data_elmt_in_rcd_id;
    gtt_rcd_typ_vals(ext_rcd_typ_c%rowcount).sort3
      := rtyp.sort3_data_elmt_in_rcd_id;
    gtt_rcd_typ_vals(ext_rcd_typ_c%rowcount).sort4
      := rtyp.sort4_data_elmt_in_rcd_id;
    gtt_rcd_typ_vals(ext_rcd_typ_c%rowcount).ext_rcd_in_file_id
      := rtyp.ext_rcd_in_file_id;
    gtt_rcd_typ_vals(ext_rcd_typ_c%rowcount).seq_num
      := rtyp.seq_num;
    gtt_rcd_typ_vals(ext_rcd_typ_c%rowcount).sprs_cd
      := rtyp.sprs_cd;
    gtt_rcd_typ_vals(ext_rcd_typ_c%rowcount).any_or_all_cd
      := rtyp.any_or_all_cd;
    gtt_rcd_typ_vals(ext_rcd_typ_c%rowcount).rcd_type_cd
      := rtyp.rcd_type_cd;
    gtt_rcd_typ_vals(ext_rcd_typ_c%rowcount).low_lvl_cd
      := rtyp.low_lvl_cd;

  END LOOP;

  IF lb_rec_not_exists
  THEN
    gtt_rcd_typ_vals(1).low_lvl_cd := 'NOREQTYP';
  END IF;
  --
  if g_debug then
    hr_utility.set_location('Exiting:'||l_proc, 15);
  end if;
  --
End setup_rcd_typ_lvl;

--
-- ----------------------------------------------------------------------------
-- |------< xtrct_skltn>------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure will assign values for extract specific parameters
--   needed for each thread, such as extract levels/cursors to include.
--   This procedure will loop through person_id values predefined for each
--   thread and invoke extract processing for each person
--
-- Pre-Conditions
--   None.
--
-- In Parameters
--   p_ext_dfn_id
--   p_run_date
--   p_business_group_id
--   p_run_date
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   No database changes
--
-- Access Status
--   Internal table handler use only.
--
-- ----------------------------------------------------------------------------------------------
Procedure xtrct_skltn(p_ext_dfn_id		        in number,
                      p_business_group_id       in number,
                      p_effective_date          in date,
                      p_benefit_action_id       in number,
                      p_range_id                in number,
                      p_start_person_action_id  in number,
                      p_end_person_action_id    in number,
                      p_data_typ_cd             in varchar2,
                      p_ext_typ_cd              in varchar2,
                      p_ext_crit_prfl_id        in number,
                      p_ext_rslt_id             in number,
                      p_ext_file_id             in number,
                      p_ext_strt_dt             in date,
                      p_ext_end_dt              in date,
                      p_prmy_sort_cd            in varchar2,
                      p_scnd_sort_cd            in varchar2,
                      p_request_id              in number,
                      p_use_eff_dt_for_chgs_flag in varchar2,
                      p_penserv_mode             in varchar2
                      )
is
  --
  l_proc                        varchar2(72);
  --
  l_personid_va  benutils.g_number_table   := benutils.g_number_table();
  l_pactid_va    benutils.g_number_table   := benutils.g_number_table();
  l_pactovn_va   benutils.g_number_table   := benutils.g_number_table();
  l_lerid_va     benutils.g_number_table   := benutils.g_number_table();
  --
  cursor bus_c
  is
    select name
    from per_business_groups_perf
    where business_group_id  = p_business_group_id;
  --
  cursor c_ext_dfn
  is
/*    select spcl_hndl_flag,
           upd_cm_sent_dt_flag,
           ext_global_flag
    from ben_ext_dfn xdf
    where xdf.ext_dfn_id = p_ext_dfn_id;
*/ -- Commented in Bug fix 4545881

    select xdf.spcl_hndl_flag,
           xdf.upd_cm_sent_dt_flag,
           decode(xdf.data_typ_cd,'CW','Y',xcr.ext_global_flag) ext_global_flag
    from ben_ext_dfn xdf,
         ben_ext_crit_prfl xcr
    where xdf.ext_dfn_id = p_ext_dfn_id
    and   xdf.ext_crit_prfl_id = xcr.ext_crit_prfl_id (+) ;
  --
  cursor c_overide_dt_cd(p_crit_typ_cd in varchar2) is
    select xcv.val_1
    from ben_ext_crit_val xcv,
         ben_ext_crit_typ xct
    where xct.ext_crit_prfl_id = p_ext_crit_prfl_id
    and   xct.ext_crit_typ_id = xcv.ext_crit_typ_id
    and   xct.crit_typ_cd = p_crit_typ_cd ;


  l_err_message fnd_new_messages.message_text%type ;
  --
BEGIN
  --
  g_debug := hr_utility.debug_enabled;
  if g_debug then
    l_proc := g_package||'xtrct_skltn';
    hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
  --
  -- This next condition was added for performance enhancements.  The
  -- encompassed routines should only be called once per thread, not once
  -- per chunk.  th 3/2/2000
  --
  If nvl(g_request_id,-2) <> p_request_id
    OR p_request_id = -1
  then
    --
    -- Initialize globals
    --
    ben_ext_person.g_err_num            := null;
    ben_ext_person.g_err_name           := null;
    ben_ext_person.g_chg_enrt_rslt_id   := null;
    ben_ext_person.g_chg_input_value_id := null;
    ben_ext_person.g_pay_last_start_date:= null;
    ben_ext_person.g_pay_last_end_date  := null;

    --
    g_ext_dfn_id     := p_ext_dfn_id;
    g_request_id     := p_request_id;
    g_ext_rslt_id    := p_ext_rslt_id;
    g_ext_strt_dt    := p_ext_strt_dt;
    g_ext_end_dt     := p_ext_end_dt;
    g_effective_date := p_effective_date;
    g_spcl_hndl_flag := null;
    g_run_date       := sysdate;
    --
    open c_ext_dfn;
    fetch c_ext_dfn into g_spcl_hndl_flag,
                         ben_ext_person.g_upd_cm_sent_dt_flag ,
                         ben_ext_person.g_ext_global_flag ;
    close c_ext_dfn;
    hr_utility.set_location( 'GLOBAL Flag ' || ben_ext_person.g_ext_global_flag , 99 ) ;
/*
    --
    -- MH moved call to thread level (ben_ext_thread.do_multithread)
    -- rather than chunk level to minimize
    -- memory consumption
    --
    --
    -- Determine extract Levels
    --
    set_ext_lvls(p_ext_file_id         => p_ext_file_id,
                 p_business_group_id   => p_business_group_id);
*/
    --
    -- retrieve business group name only if it is required
    g_proc_business_group_id   := p_business_group_id ;
    if g_bg_csr = 'Y' then
      open bus_c;
      fetch bus_c into g_business_group_name;
      close bus_c;
      g_proc_business_group_name := g_business_group_name ;
    end if;
    --
    --  Load Inclusion Tables for later processing.
    --
    IF p_ext_crit_prfl_id is not null THEN
       --
       ben_ext_evaluate_inclusion.Determine_Incl_Crit_To_Check(p_ext_crit_prfl_id);

       -- cache the person and benefit overide dates.
       -- get the person overide date
       open c_overide_dt_cd ('PASOR') ;
       fetch c_overide_dt_cd into g_pasor_dt_cd ;
       close c_overide_dt_cd ;

       -- get the benefit overide date
       open c_overide_dt_cd ('BDTOR') ;
       fetch c_overide_dt_cd into g_bdtor_dt_cd ;
       close c_overide_dt_cd ;

    END IF;
    --
    -- initialize extract totals
    --
    g_trans_num := 0;
    g_per_num   := 0;
    g_error_num := 0;
/*
    --
    -- Initialize tables
    gtt_rcd_rqd_vals.DELETE;
    --
    -- MH moved call to thread level (ben_ext_thread.do_multithread)
    -- rather than chunk level to minimize
    -- memory consumption
    --
    --  For each Person - pb24/3/00:'not sure what this comment is meant to mean'?
    --
    -- Setup record and required level tables
    --
    setup_rcd_typ_lvl
      (p_ext_file_id => p_ext_file_id
      );
    --
*/
  end if;
  --
  -- Get the person id range for the person action id range
  --
  ben_maintain_benefit_actions.get_peractionrange_persondets
    (p_benefit_action_id      => p_benefit_action_id
    ,p_start_person_action_id => p_start_person_action_id
    ,p_end_person_action_id   => p_end_person_action_id
    --
    ,p_personid_va            => l_personid_va
    ,p_pactid_va              => l_pactid_va
    ,p_pactovn_va             => l_pactovn_va
    ,p_lerid_va               => l_lerid_va
    );
  --
  if l_personid_va.count > 0
  then
    --
    for vaen in l_personid_va.first..l_personid_va.last
    loop
      --
      if g_debug then
        hr_utility.set_location(' Person ID '||l_personid_va(vaen), 00 );
      end if;
     Begin
        --
        ben_ext_person.process_ext_person
          (p_person_id          => l_personid_va(vaen)
          ,p_ext_dfn_id         => p_ext_dfn_id
          ,p_ext_rslt_id        => p_ext_rslt_id
          ,p_ext_file_id        => p_ext_file_id
          ,p_ext_crit_prfl_id   => p_ext_crit_prfl_id
          ,p_data_typ_cd        => p_data_typ_cd
          ,p_ext_typ_cd         => p_ext_typ_cd
          ,p_effective_date     => p_effective_date
          ,p_business_group_id  => p_business_group_id
          ,p_penserv_mode       => p_penserv_mode           ----------vkodedal changes for penserver 30-apr-2008
          );
          --
          -- update the status for the person proceesed
          -- this helps to restart only the person not processed
          --
         --
         -- Bug 4161111 perf issue in GSI.
         --
         ben_person_actions_api.update_person_actions
          (p_person_action_id      =>l_pactid_va(vaen)
          ,p_action_status_cd      => 'P'
          ,p_object_version_number =>l_pactovn_va(vaen)
          ,p_effective_date        => p_effective_date);
        --
      Exception
        when ben_ext_person.detail_restart_error then

           --- update the range to warning
           --- the warning will be later converted to erro because
           --- if error the range  the subseqent range may not be  executed , every time spawn the thread
           --- the process validated for the errored  thread so we set the range status to 'W'

           update ben_batch_ranges set range_status_cd = 'W'
           where range_id = p_range_id and range_status_cd = 'P';

           l_err_message := ben_ext_fmt.get_error_msg(ben_Ext_person.g_err_num,
                                         ben_Ext_person.g_err_name,ben_Ext_person.g_elmt_name ) ;
           if g_debug then
              hr_utility.set_location('err msg ' || l_err_message, 99.98 );
           end if;
           ben_ext_person.write_error(
                p_err_num     => ben_Ext_person.g_err_num,
                p_err_name    => l_err_message,
                p_typ_cd      => 'E',
                p_request_id  => ben_extract.g_request_id,
                p_ext_rslt_id => p_ext_rslt_id
               );
            --- the changes are commited along with the error message in thge write error process

           when Others then

           --- update the range to warning
           --- the warning will be later converted to erro because
           --- if error the range  the subseqent range may not be  executed , every time spawn the thread
           --- the process validated for the errored  thread so we set the range status to 'W'

           update ben_batch_ranges set range_status_cd = 'W'
           where range_id = p_range_id and range_status_cd = 'P';
           if  nvl(ben_ext_person.g_err_num,-1)  <>   94102  then
              l_err_message := substr(sqlerrm,1,2000) ;
              if g_debug then
                 hr_utility.set_location('err msg ' || l_err_message, 99.98 );
              end if;
              ben_ext_person.write_error(
                   p_err_num     => 94701,
                   p_err_name    => l_err_message,
                   p_typ_cd      => 'E',
                   p_request_id  => ben_extract.g_request_id,
                   p_ext_rslt_id => p_ext_rslt_id
                  );
               --- the changes are commited along with the error message in thge write error process
           end if ;
           ben_ext_person.g_err_num := null ;

      End ;
    end loop;
    --
  end if;
  --
/*
  FOR person IN per_cursor LOOP
      --
      --
      --
      if g_debug then
        hr_utility.set_location(' Person ID ' || person.person_id, 00 );
      end if;
      ben_ext_person.process_ext_person
                      ( p_person_id          => person.person_id
                      , p_ext_dfn_id         => p_ext_dfn_id
                      , p_ext_rslt_id        => p_ext_rslt_id
                      , p_ext_file_id        => p_ext_file_id
                      , p_ext_crit_prfl_id   => p_ext_crit_prfl_id
                      , p_data_typ_cd        => p_data_typ_cd
                      , p_ext_typ_cd         => p_ext_typ_cd
                      , p_effective_date     => p_effective_date
                      , p_business_group_id  => p_business_group_id
                      );

   --- update the status for the person proceesed
   --- this helps to restart only the person not processed
   update ben_person_actions act
      set action_status_cd = 'P'
      where   person_id = person.person_id
        and   benefit_action_id = p_benefit_action_id;
    --
  END LOOP;   -- person
*/
--
--
if g_debug then
  hr_utility.set_location('Exiting'||l_proc, 70);
end if;
--
commit;
--
EXCEPTION
  --
  WHEN g_max_err_num_exception THEN
    --
    update ben_batch_ranges set range_status_cd = 'E'
      where range_id = p_range_id;
    --
    commit;
  --
--
END xtrct_skltn;
--

--
-- ----------------------------------------------------------------------------
-- |------< set_ext_lvls >------|
-- ----------------------------------------------------------------------------
--  This procedure will determine extract levels and cursors required
--  for a given exrtact file layout definition.  Package global variables
--  will be assigned values 'Y' or 'N' as appropriate.
--
Procedure set_ext_lvls(p_ext_file_id         in number,
                       p_business_group_id   in number
                      ) IS
--
  l_proc               varchar2(72);
--
  l_dummy              varchar2(30);
  l_rec_lvl_cd         varchar2(30);
  l_cursor_cd          varchar2(30);
--
  l_err_name   varchar2(50);
  job_failure  exception;
--
--
  cursor ext_rec_lvl_c (p_ext_file_id  number) is
    select
      decode(sum(decode(a.low_lvl_cd,'P',1,0)),0,'N','Y')  g_per_lvl,
      decode(sum(decode(a.low_lvl_cd,'E',1,0)),0,'N','Y')  g_enrt_lvl,
      decode(sum(decode(a.low_lvl_cd,'PR',1,0)),0,'N','Y') g_prem_lvl,
      decode(sum(decode(a.low_lvl_cd,'D',1,0)),0,'N','Y')  g_dpnt_lvl,
      decode(sum(decode(a.low_lvl_cd,'Y',1,0)),0,'N','Y')  g_payroll_lvl,
      decode(sum(decode(a.low_lvl_cd,'G',1,0)),0,'N','Y')  g_elig_lvl,
      decode(sum(decode(a.low_lvl_cd,'F',1,0)),0,'N','Y')  g_flex_lvl,
      decode(sum(decode(a.low_lvl_cd,'B',1,0)),0,'N','Y')  g_bnf_lvl,
      decode(sum(decode(a.low_lvl_cd,'A',1,0)),0,'N','Y')  g_actn_lvl,
      decode(sum(decode(a.low_lvl_cd,'R',1,0)),0,'N','Y')  g_runrslt_lvl,
      decode(sum(decode(a.low_lvl_cd,'CO',1,0)),0,'N','Y') g_contact_lvl,
      decode(sum(decode(a.low_lvl_cd,'ED',1,0)),0,'N','Y') g_eligdpnt_lvl,
      decode(sum(decode(a.low_lvl_cd,'WG',1,0)),0,'N','Y') g_cwbgr_lvl,
      decode(sum(decode(a.low_lvl_cd,'WR',1,0)),0,'N','Y') g_cwbrt_lvl,
      decode(sum(decode(a.low_lvl_cd,'OR',1,0)),0,'N','Y') g_org_lvl,               -- subheader
      decode(sum(decode(a.low_lvl_cd,'PO',1,0)),0,'N','Y') g_pos_lvl,               -- subheader
      decode(sum(decode(a.low_lvl_cd,'JB',1,0)),0,'N','Y') g_job_lvl,               -- subheader
      decode(sum(decode(a.low_lvl_cd,'GR',1,0)),0,'N','Y') g_grd_lvl,               -- subheader
      decode(sum(decode(a.low_lvl_cd,'LO',1,0)),0,'N','Y') g_loc_lvl,               -- subheader
      decode(sum(decode(a.low_lvl_cd,'PY',1,0)),0,'N','Y') g_pay_lvl,               -- subheader
      decode(sum(decode(a.low_lvl_cd,'T',1,0)),0,'N','Y') g_otl_summ_lvl,
      decode(sum(decode(a.low_lvl_cd,'TS',1,0)),0,'N','Y') g_otl_detl_lvl
      from  ben_ext_rcd             a,
            ben_ext_rcd_in_file     b
      where a.ext_rcd_id  = b.ext_rcd_id
      and   b.ext_file_id = p_ext_file_id;

  cursor ext_cursors_c (p_ext_file_id  number) is
    select
       decode(sum(decode(e.csr_cd,'ADR',1,0)),0,'N','Y')   g_addr_csr,
       decode(sum(decode(e.csr_cd,'ASG',1,0)),0,'N','Y')   g_asg_csr,
       decode(sum(decode(e.csr_cd,'PHN',1,0)),0,'N','Y')   g_phn_csr,
       decode(sum(decode(e.csr_cd,'RT',1,0)),0,'N','Y')    g_rt_csr,
       decode(sum(decode(e.csr_cd,'LER',1,0)),0,'N','Y')   g_ler_csr,
       decode(sum(decode(e.csr_cd,'BGR',1,0)),0,'N','Y')   g_bgr_csr,
       decode(sum(decode(e.csr_cd,'MA',1,0)),0,'N','Y')    g_ma_csr,
       decode(sum(decode(e.csr_cd,'BP',1,0)),0,'N','Y')    g_bp_csr,
       decode(sum(decode(e.csr_cd,'BA',1,0)),0,'N','Y')    g_ba_csr,
       decode(sum(decode(e.csr_cd,'CHCRT',1,0)),0,'N','Y') g_chcrt_csr,
       decode(sum(decode(e.csr_cd,'CHC',1,0)),0,'N','Y')   g_chc_csr,
       decode(sum(decode(e.csr_cd,'CMA',1,0)),0,'N','Y')   g_cma_csr,
       decode(sum(decode(e.csr_cd,'DP',1,0)),0,'N','Y')    g_dp_csr,
       decode(sum(decode(e.csr_cd,'DA',1,0)),0,'N','Y')    g_da_csr,
       decode(sum(decode(e.csr_cd,'DPCP',1,0)),0,'N','Y')  g_dpcp_csr,
       decode(sum(decode(e.csr_cd,'BG',1,0)),0,'N','Y')    g_bg_csr,
       decode(sum(decode(e.csr_cd,'BB1',1,0)),0,'N','Y')   g_bb1_csr,
       decode(sum(decode(e.csr_cd,'BB2',1,0)),0,'N','Y')   g_bb2_csr,
       decode(sum(decode(e.csr_cd,'BB3',1,0)),0,'N','Y')   g_bb3_csr,
       decode(sum(decode(e.csr_cd,'BB4',1,0)),0,'N','Y')   g_bb4_csr,
       decode(sum(decode(e.csr_cd,'BB5',1,0)),0,'N','Y')   g_bb5_csr,
       decode(sum(decode(e.csr_cd,'PPCP',1,0)),0,'N','Y')  g_ppcp_csr,
       decode(sum(decode(e.csr_cd,'PGN',1,0)),0,'N','Y')   g_pgn_csr,
       decode(sum(decode(e.csr_cd,'ABS',1,0)),0,'N','Y')   g_abs_csr,
       decode(sum(decode(e.csr_cd,'PPREM',1,0)),0,'N','Y') g_pprem_csr,
       decode(sum(decode(e.csr_cd,'EPREM',1,0)),0,'N','Y') g_eprem_csr,
       decode(sum(decode(e.csr_cd,'FLXCR',1,0)),0,'N','Y') g_flxcr_csr,
       decode(sum(decode(e.csr_cd,'ERGRP',1,0)),0,'N','Y') g_ergrp_csr,
       decode(sum(decode(e.csr_cd,'PRGRP',1,0)),0,'N','Y') g_prgrp_csr,
       decode(sum(decode(e.csr_cd,'ASA',1,0)),0,'N','Y')   g_asa_csr,
       decode(sum(decode(e.csr_cd,'EPLYR',1,0)),0,'N','Y') g_eplyr_csr,
       decode(sum(decode(e.csr_cd,'PPLYR',1,0)),0,'N','Y') g_pplyr_csr,
       decode(sum(decode(e.csr_cd,'ELER',1,0)),0,'N','Y')  g_eler_csr,
       decode(sum(decode(e.csr_cd,'PLER',1,0)),0,'N','Y')  g_pler_csr,
       decode(sum(decode(e.csr_cd,'PMPR',1,0)),0,'N','Y')  g_pmpr_csr,
       decode(sum(decode(e.csr_cd,'PMTPR',1,0)),0,'N','Y') g_pmtpr_csr,
       decode(sum(decode(e.csr_cd,'INTRM',1,0)),0,'N','Y') g_intrm_csr,
       decode(sum(decode(e.csr_cd,'INT',1,0)),0,'N','Y')   g_int_csr,
       decode(sum(decode(e.csr_cd,'CBRA',1,0)),0,'N','Y')  g_cbra_csr,
       decode(sum(decode(e.csr_cd,'COA',1,0)),0,'N','Y')   g_coa_csr,
       decode(sum(decode(e.csr_cd,'COP',1,0)),0,'N','Y')   g_cop_csr,
       decode(sum(decode(e.csr_cd,'COED',1,0)),0,'N','Y')  g_coed_csr,
       decode(sum(decode(e.csr_cd,'COCD',1,0)),0,'N','Y')  g_cocd_csr,
       decode(sum(decode(e.csr_cd,'COB',1,0)),0,'N','Y')   g_cob_csr,
       decode(sum(decode(e.csr_cd,'COSL',1,0)),0,'N','Y')  g_cosl_csr,
       decode(sum(decode(e.csr_cd,'COEL',1,0)),0,'N','Y')  g_coel_csr,
       decode(sum(decode(e.csr_cd,'EDP',1,0)),0,'N','Y')   g_edp_csr,
       decode(sum(decode(e.csr_cd,'EDA',1,0)),0,'N','Y')   g_eda_csr,
       decode(sum(decode(e.csr_cd,'POS',1,0)),0,'N','Y')   g_pos_csr,
       decode(sum(decode(e.csr_cd,'SUP',1,0)),0,'N','Y')   g_sup_csr,
       decode(sum(decode(e.csr_cd,'BSL',1,0)),0,'N','Y')   g_bsl_csr,
       decode(sum(decode(e.csr_cd,'SHL',1,0)),0,'N','Y')   g_shl_csr,
       decode(sum(decode(e.csr_cd,'CWPG',1,0)),0,'N','Y')  g_cwbdg_csr ,
       decode(sum(decode(e.csr_cd,'CWPR',1,0)),0,'N','Y')  g_cwbawr_csr,
       decode(sum(decode(e.csr_cd,'CBRADM',1,0)),0,'N','Y')   g_cbradm_csr
       from ben_ext_rcd_in_file        a,
            ben_ext_rcd                b,
            ben_ext_data_elmt_in_rcd   c,
            ben_ext_data_elmt          d,
            ben_ext_fld                e
       where a.ext_file_id      = p_ext_file_id
       and   a.ext_rcd_id       = b.ext_rcd_id
       and   c.ext_rcd_id       = b.ext_rcd_id
       and   d.ext_data_elmt_id = c.ext_data_elmt_id
       and   e.ext_fld_id       = d.ext_fld_id;

  --  subheader global variable for multithread
   cursor c_ext_file (p_file_id number) is
  select ext_data_elmt_in_rcd_id1,
         ext_data_elmt_in_rcd_id2
  from  ben_Ext_file exf
  where exf.ext_file_id = p_file_id ;


  cursor  c_ext_elmt (p_data_elmt_in_rcd_id  number
                      ) is
  select  exf.short_name
  from ben_ext_fld  exf,
       ben_Ext_data_elmt_in_rcd edr,
       ben_ext_data_elmt        ede
  where edr.ext_data_elmt_in_rcd_id = p_data_elmt_in_rcd_id
    and edr.ext_data_elmt_id     = ede.ext_Data_elmt_id
    and ede.ext_fld_id           = exf.ext_fld_id (+)
    ;

  l_ext_rcd c_ext_file%rowtype ;
  -- eof subheader



--
begin
--
 g_debug := hr_utility.debug_enabled;
 if g_debug then
   l_proc := g_package||'set_ext_lvls';
   hr_utility.set_location('Entering'||l_proc, 5);
 end if;
   --
   -- determine extract record levels:
   -- ==============================================================
    open ext_rec_lvl_c(p_ext_file_id => p_ext_file_id);
    fetch ext_rec_lvl_c into
      g_per_lvl,
      g_enrt_lvl,
      g_prem_lvl,
      g_dpnt_lvl,
      g_payroll_lvl,
      g_elig_lvl,
      g_flex_lvl,
      g_bnf_lvl,
      g_actn_lvl,
      g_runrslt_lvl,
      g_contact_lvl,
      g_eligdpnt_lvl,
      g_cwb_bdgt_lvl ,
      g_cwb_awrd_lvl ,
      g_org_lvl,               -- subheader
      g_pos_lvl,               -- subheader
      g_job_lvl,               -- subheader
      g_grd_lvl,               -- subheader
      g_loc_lvl,               -- subheader
      g_pay_lvl,               -- subheader
      g_otl_summ_lvl,
      g_otl_detl_lvl;
    --
    close ext_rec_lvl_c;

     if g_org_lvl = 'Y' or g_pos_lvl = 'Y' or g_job_lvl = 'Y' or g_loc_lvl = 'Y' or
        g_pay_lvl = 'Y' or g_grd_lvl = 'Y'
        then
         g_subhead_dfn := 'Y' ;
    end if ;

    --
    -- ============================================
    -- determine extract cursor needed:
    -- ============================================
    --

    open ext_cursors_c (p_ext_file_id => p_ext_file_id);
    fetch ext_cursors_c into
       g_addr_csr,
       g_asg_csr,
       g_phn_csr,
       g_rt_csr,
       g_ler_csr,
       g_bgr_csr,
       g_ma_csr,
       g_bp_csr,
       g_ba_csr,
       g_chcrt_csr,
       g_chc_csr,
       g_cma_csr,
       g_dp_csr,
       g_da_csr,
       g_dpcp_csr,
       g_bg_csr,
       g_bb1_csr,
       g_bb2_csr,
       g_bb3_csr,
       g_bb4_csr,
       g_bb5_csr,
       g_ppcp_csr,
       g_pgn_csr,
       g_abs_csr,
       g_pprem_csr,
       g_eprem_csr,
       g_flxcr_csr,
       g_ergrp_csr,
       g_prgrp_csr,
       g_asa_csr,
       g_eplyr_csr,
       g_pplyr_csr,
       g_eler_csr,
       g_pler_csr,
       g_pmpr_csr,
       g_pmtpr_csr,
       g_intrm_csr,
       g_int_csr,
       g_cbra_csr,
       g_coa_csr,
       g_cop_csr,
       g_coed_csr,
       g_cocd_csr,
       g_cob_csr,
       g_cosl_csr,
       g_coel_csr,
       g_edp_csr,
       g_eda_csr,
       g_pos_csr,
       g_sup_csr,
       g_bsl_csr,
       g_shl_csr,
       g_cwbdg_csr,
       g_cwbawr_csr,
       g_cbradm_csr ;

    --
    close ext_cursors_c;

    --

    --subhead

   if  ben_ext_thread.g_ext_group_elmt1 is null then
       open c_ext_file(p_ext_file_id) ;
       fetch c_ext_file into l_ext_rcd ;
       close c_ext_file ;

       if l_ext_rcd.ext_data_elmt_in_rcd_id1 is not null then
          open  c_ext_elmt(l_ext_rcd.ext_data_elmt_in_rcd_id1) ;
          fetch c_ext_elmt into ben_ext_thread.g_ext_group_elmt1 ;
          close c_ext_elmt ;

          if l_ext_rcd.ext_data_elmt_in_rcd_id2 is not null then
             open  c_ext_elmt(l_ext_rcd.ext_data_elmt_in_rcd_id2) ;
             fetch c_ext_elmt into ben_ext_thread.g_ext_group_elmt2 ;
             close c_ext_elmt ;
          end if ;
       end if ;
   end if ;
  -- eof subheader

 if g_debug then
   hr_utility.set_location('Exiting'||l_proc, 15);
 end if;
--
End set_ext_lvls;
--
End ben_extract;

/
