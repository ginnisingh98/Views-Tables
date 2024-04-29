--------------------------------------------------------
--  DDL for Package Body BEN_FORFEITURE_CONCURRENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_FORFEITURE_CONCURRENT" as
/* $Header: benforfs.pkb 120.0 2005/05/28 09:01:45 appldev noship $ */
--
/* ============================================================================
*    Name
*       Process Forfeiture Concurrent Manager Processes for Contributions
*
*    Purpose
*       This package simply houses the concurrent manager and multi-thread
*       processes for Contribution Forfeiture Calculation.
*
*    History
*      Date        Who        Version    What?
*      -------     ---------  -------    --------------------------------------
*      14-Sep-01   pbodla     115.0      Created
*      29-Sep-01   pbodla     115.1      First cut working from concurrent
*                                        program.
*      29-Sep-01   pbodla     115.2      Modified cursors to filter based on
*                                        provided comp object parameters.
*      02-oct-01   pbodla     115.3      Added logic to write forfeiture data
*                                        to ben_pl_frfs_val_f table.
*                                        In Phase 2 use the actual api's.
*      03-Oct-01   pbodla     115.4      Added cursor c_abr_temp to get
*                                        clf row for contribution abr.
*                                        This is a temporary fix needs to be
*                                        removed later.
*      10-Oct-01   pbodla     115.5      Added code for reporting.
*      18-Oct-01   pbodla     115.6      Added code to initialise the person
*                                        forfeited totals.
*                                        Added proc create_per_frftd_rt to
*                                        prtt rt val row.
*      19-Oct-01   pbodla     115.7      Added code to initialise the
*                                        contribution and distribution vals.
*      22-0ct-01   tjesumic   115.8     new if conditon added to check whether the
*                                       the process is don after the last day of
*                                        receipt allowed
*      23-oct-01   tjesumic   115.9     distribution detrmination code USERMBRQ
*                                       Spelled USERMBQ, corrcted
*                                       Nvl added in payment status code in cursor
*      25-oct-01   tjesumic  115.10     cursor calcualting reimb approve amount corrected
*      26-oct-01   tjesumic  115.11     Cursor c_asg is using the wrong person_id , fixed
*      07-may-01   tjesumic  115.12     'PDINFL','PRTLYPD' added
*      08-may-01   tjesumic  115.13     DBDRV added
*      30-dec-02   ikasire   115.14     nocopy changes
*      13-oct-04   mmudigon  115.15     Bug 3818453. Added call to
*                                       get_latest_paa_id()
*      03-Dec-04   ikasire   115.16     Bug 4046914
* -----------------------------------------------------------------------------
*/
--
-- Global cursor and variables declaration
--
g_package                 varchar2(80) := 'ben_forfeiture_concurrent';
g_persons_processed       number(9) := 0;
g_persons_ended           number(9) := 0;
g_persons_passed          number(9) := 0;
g_persons_errored         number(9) := 0;
g_max_errors_allowed      number(9) := 200;
--
-- ============================================================================
--                        << Procedure: create_per_frftd_rt >>
--  Description:
--      this procedure creates the participant rate val row for person
--      forfeited amount.
--
-- ============================================================================
--
procedure create_per_frftd_rt (
             p_validate              in varchar2 default 'N'
            ,p_pl_id                 in number
            ,p_pgm_id                in number   default null
            ,p_business_group_id     in number
            ,p_effective_date        in date
            ,p_end_date              in date
            ,p_start_date            in date
            ,p_person_id             in number   default null
            ,p_per_frftd_val         in number
) is
  --
  cursor c_pln
    is
    select pln.nip_acty_ref_perd_cd
          ,pln.pl_id
    from   ben_pl_f pln
    where  pln.pl_id = p_pl_id
    and    p_effective_date
           between pln.effective_start_date
           and     pln.effective_end_date;
  --
   Cursor  c_rslt_rec (p_pl_id  number )  is
     select pen.pgm_id,
            pen.per_in_ler_id,
            pen.prtt_enrt_rslt_id
     from   ben_prtt_enrt_rslt_f pen
     where  pen.person_id = p_person_id
       and  pen.pl_id     = p_pl_id
       and  pen.prtt_enrt_rslt_stat_cd is null
       and  pen.business_group_id = p_business_group_id
       and  p_effective_date between
            pen.effective_start_date and pen.effective_end_date;
  --
  l_rslt_rec   c_rslt_rec%rowtype;
  --
  cursor c_acty_base_rt (p_pl_id number)
  is
  select abr.acty_base_rt_id,
          abr.rt_typ_cd,
          abr.tx_typ_cd,
          abr.acty_typ_cd,
          abr.rt_mlt_cd,
          abr.bnft_rt_typ_cd,
          abr.dsply_on_enrt_flag,
          abr.comp_lvl_fctr_id,
          abr.actl_prem_id,
          abr.input_value_id,
          abr.element_type_id
   from ben_acty_base_rt_f abr
   where abr.pl_id = p_pl_id
   and   abr.acty_typ_cd = 'PRFRFS'
   and   abr.acty_base_rt_stat_cd = 'A'
   and   p_effective_date between
         abr.effective_start_date and
         abr.effective_end_date;
   --
   l_acty_base_rt      c_acty_base_rt%rowtype;
   --
   cursor c_pgm
     (c_pgm_id number)
     is
     select pgm.acty_ref_perd_cd
     from   ben_pgm_f pgm
     where  pgm.pgm_id = c_pgm_id
       and  p_effective_date
            between pgm.effective_start_date
            and   pgm.effective_end_date;
  --
  cursor c_prv_rec (p_prtt_enrt_rslt_id number,
                    p_acty_base_rt_id   number,
                    p_start_date        date,
                    p_end_date          date)
  is
  select prv.prtt_rt_val_id,
         prv.object_version_number,
         ecr.enrt_rt_id
   from ben_acty_base_rt_f abr,
        ben_prtt_rt_val prv,
        ben_enrt_rt     ecr
   where prv.prtt_enrt_rslt_id   = p_prtt_enrt_rslt_id
   and   prv.prtt_rt_val_stat_cd is null
   and   prv.acty_base_rt_id = p_acty_base_rt_id
   and   ecr.prtt_rt_val_id  = prv.prtt_rt_val_id
   and   prv.rt_strt_dt      between  p_start_date
                                 and  p_end_date
   and   prv.acty_base_rt_id = abr.acty_base_rt_id
   and   abr.acty_typ_cd = 'PRFRFS'
   and   p_start_date between
         abr.effective_start_date and
         abr.effective_end_date;
  --
  l_prv_rec      c_prv_rec%rowtype;
  --
  -- Declare cursors and local variables
  --
  l_effective_start_date  date;
  l_prtt_rt_val_id        number;
  l_prtt_enrt_rslt_id     number;
  l_object_version_number number;
  l_acty_ref_perd_cd      varchar2(30);
  l_pl_id                 number;
  --
  l_proc                  varchar2(72) := g_package||'.create_per_frftd_rt';
  --
begin
   --
   --  Creating prtt rt val and element entry rows.
   --
   open c_pln;
   fetch c_pln into
        l_acty_ref_perd_cd,
        l_pl_id ;
   close c_pln;

  open c_rslt_rec(p_pl_id);
  fetch c_rslt_rec into l_rslt_rec;
  close c_rslt_rec;

  if  l_rslt_rec.pgm_id is not null then
    --
    hr_utility.set_location('pgm '||l_rslt_rec.pgm_id,100);
    open c_pgm (l_rslt_rec.pgm_id);
    fetch c_pgm into l_acty_ref_perd_cd;
    close c_pgm;
    --
  End if  ;

  open c_acty_base_rt(p_pl_id);
  fetch c_acty_base_rt into l_acty_base_rt;
  close c_acty_base_rt;
  --
  hr_utility.set_location(' l_prtt_rt_val_id = ' || l_prtt_rt_val_id, 9999);
  hr_utility.set_location(' l_rslt_rec.per_in_ler_id = ' || l_rslt_rec.per_in_ler_id, 9999);
  hr_utility.set_location(' l_acty_base_rt.rt_typ_cd = ' || l_acty_base_rt.rt_typ_cd, 9999);
  hr_utility.set_location(' l_acty_base_rt.tx_typ_cd = ' || l_acty_base_rt.tx_typ_cd, 9999);
  hr_utility.set_location(' l_acty_base_rt.acty_typ_cd = ' || l_acty_base_rt.acty_typ_cd, 9999);
  hr_utility.set_location(' l_acty_base_rt.rt_mlt_cd = ' || l_acty_base_rt.rt_mlt_cd, 9999);
  hr_utility.set_location(' l_acty_ref_perd_cd = ' || l_acty_ref_perd_cd, 9999);
  hr_utility.set_location(' p_per_frftd_val = ' || p_per_frftd_val, 9999);
  hr_utility.set_location(' p_end_date = ' || p_end_date, 9999);
  hr_utility.set_location(' l_acty_base_rt.bnft_rt_typ_cd = ' || l_acty_base_rt.bnft_rt_typ_cd, 9999);
  hr_utility.set_location(' l_acty_base_rt.comp_lvl_fctr_id = ' || l_acty_base_rt.comp_lvl_fctr_id, 9999);
  hr_utility.set_location(' p_business_group_id = ' || p_business_group_id, 9999);
  hr_utility.set_location(' l_object_version_number = ' || l_object_version_number, 9999);
  hr_utility.set_location(' l_acty_base_rt.acty_base_rt_id = ' || l_acty_base_rt.acty_base_rt_id, 9999);
  hr_utility.set_location(' p_person_id = ' || p_person_id, 9999);
  hr_utility.set_location(' l_acty_base_rt.input_value_id = ' || l_acty_base_rt.input_value_id, 9999);
  hr_utility.set_location(' l_acty_base_rt.element_type_id = ' || l_acty_base_rt.element_type_id, 9999);
  hr_utility.set_location(' l_prtt_enrt_rslt_id = ' || l_rslt_rec.prtt_enrt_rslt_id, 9999);
  hr_utility.set_location(' p_start_date = ' || p_start_date, 8888);
  hr_utility.set_location(' p_end_date = ' || p_end_date, 8888);
  --
  -- if prtt_rt_val exists delete it by calling
  --
  l_prv_rec.prtt_rt_val_id := null;

  open  c_prv_rec(l_rslt_rec.prtt_enrt_rslt_id,
                  l_acty_base_rt.acty_base_rt_id,
                  p_start_date, p_end_date );
  fetch c_prv_rec into l_prv_rec;
  close c_prv_rec;
  --
  hr_utility.set_location(' l_prv_rec.prtt_rt_val_id = ' || l_prv_rec.prtt_rt_val_id, 9999);
  hr_utility.set_location(' l_prv_rec.enrt_rt_id = ' || l_prv_rec.enrt_rt_id, 9999);
  hr_utility.set_location(' l_prv_rec.obj = ' || l_prv_rec.object_version_number, 9999);
  if l_prv_rec.prtt_rt_val_id is not null then
     --
     ben_prtt_rt_val_api.delete_prtt_rt_val
     (p_validate                       => false
     ,p_prtt_rt_val_id                 => l_prv_rec.prtt_rt_val_id
     ,p_enrt_rt_id                     => l_prv_rec.enrt_rt_id
     ,p_person_id                      => p_person_id
     ,p_business_group_id              => p_business_group_id
     ,p_object_version_number          => l_prv_rec.object_version_number
     ,p_effective_date                 => p_end_date
     );
     --
  end if;
  --
  --
  --  Creating Prtt rate val row
  --
  if l_acty_base_rt.acty_base_rt_id is not null then
     --
     ben_prtt_rt_val_api.create_prtt_rt_val(
           p_prtt_rt_val_id                 => l_prtt_rt_val_id
          ,p_per_in_ler_id                  => l_rslt_rec.per_in_ler_id
          ,p_rt_typ_cd                      => l_acty_base_rt.rt_typ_cd
          ,p_tx_typ_cd                      => l_acty_base_rt.tx_typ_cd
          ,p_acty_typ_cd                    => l_acty_base_rt.acty_typ_cd
          ,p_mlt_cd                         => l_acty_base_rt.rt_mlt_cd
          ,p_acty_ref_perd_cd               => l_acty_ref_perd_cd
          ,p_rt_val                         => p_per_frftd_val
          ,p_rt_strt_dt                     => p_end_date
          ,p_rt_end_dt                      => p_end_date
          ,p_bnft_rt_typ_cd                 => l_acty_base_rt.bnft_rt_typ_cd
          ,p_dsply_on_enrt_flag             => 'N'
                                            --l_acty_base_rt.dsply_on_enrt_flag
          ,p_elctns_made_dt                 => p_end_date
          ,p_cvg_amt_calc_mthd_id           => null
          ,p_actl_prem_id                   => null
          ,p_comp_lvl_fctr_id               => l_acty_base_rt.comp_lvl_fctr_id
          ,p_business_group_id              => p_business_group_id
          ,p_object_version_number          => l_object_version_number
          ,p_effective_date                 => p_end_date
          ,p_acty_base_rt_id                => l_acty_base_rt.acty_base_rt_id
          ,p_person_id                      => p_person_id
          ,p_PRTT_REIMBMT_RQST_ID           => null
          ,p_prtt_rmt_aprvd_fr_pymt_id      => null
          ,p_input_value_id                 => l_acty_base_rt.input_value_id
          ,p_element_type_id                => l_acty_base_rt.element_type_id
          ,p_prtt_enrt_rslt_id              => l_rslt_rec.prtt_enrt_rslt_id
        );
        --
  end if;
  --
end create_per_frftd_rt;
--
-- ===========================================================================
--                 << Procedure: Submit_all_reports >>
-- ===========================================================================
--
Procedure Submit_all_reports (p_rpt_flag  Boolean default FALSE) is
  l_proc        varchar2(80) := g_package||'.submit_all_reports';
  l_actn        varchar2(80);
  l_request_id  number;
Begin
  hr_utility.set_location ('Entering '||l_proc,05);
  l_actn := 'Calling ben_batch_utils.batch_report (BENPRSUM)...';
  ben_batch_utils.batch_report
         (p_concurrent_request_id => fnd_global.conc_request_id
         ,p_program_name          => 'BENFRSUM'
         ,p_request_id            => l_request_id
         );
  l_actn := 'Calling ben_batch_utils.batch_report (BENFRAUD)...';
  ben_batch_utils.batch_report
         (p_concurrent_request_id => fnd_global.conc_request_id
         ,p_program_name          => 'BENFRAUD'
         ,p_request_id            => l_request_id
         );
  l_actn := 'Calling ben_batch_utils.batch_report (BENERTYP)...';
  ben_batch_utils.batch_report
         (p_concurrent_request_id => fnd_global.conc_request_id
         ,p_program_name          => 'BENERTYP'
         ,p_request_id            => l_request_id
         );
  l_actn := 'Calling ben_batch_utils.batch_report (BENERPER)...';
  ben_batch_utils.batch_report
         (p_concurrent_request_id => fnd_global.conc_request_id
         ,p_program_name          => 'BENERPER'
         ,p_request_id            => l_request_id
         );

  hr_utility.set_location ('Leaving '||l_proc,10);
Exception
  When others then
    ben_batch_utils.rpt_error(p_proc      => l_proc
                             ,p_last_actn => l_actn
                             ,p_rpt_flag  => p_rpt_flag
                             );
    raise;
End Submit_all_reports;
--
-- ============================================================================
--                        << Procedure: process_forfeitures >>
--  Description:
--      this procedure determines the forfeitures for the selected plan.
--      routine.
-- ============================================================================
procedure process_forfeitures (
             p_validate              in varchar2 default 'N'
            ,p_pl_id                 in number
            ,p_business_group_id     in number
            ,p_effective_date        in date
            ,p_person_id             in number   default null
            ,p_person_type_id        in number   default null
            ,p_person_selection_rule_id in number   default null) is
  --
  l_package               varchar2(80) := g_package||'.process_forfeitures';
  l_error_text            varchar2(200) := null;
  --
  cursor c_pl_subj_frfs (p_effective_date date) is
    select pln.name, pln.FRFS_DISTR_MTHD_CD,
           pln.FRFS_DISTR_MTHD_RL,
           pln.FRFS_CNTR_DET_CD,
           pln.FRFS_DISTR_DET_CD,
           pln.COST_ALLOC_KEYFLEX_1_ID,
           pln.COST_ALLOC_KEYFLEX_2_ID,
           pln.POST_TO_GL_FLAG,
           pln.FRFS_VAL_DET_CD,
           pln.FRFS_MX_CRYFWD_VAL,
           pln.FRFS_PORTION_DET_CD,
           pln.BNDRY_PERD_CD,
           pyp.Acpt_clm_rqsts_thru_dt,
           yp.start_date,
           yp.end_date
    from   ben_pl_f pln,
           ben_popl_yr_perd pyp,
           ben_yr_perd yp
    where  pln.pl_id = p_pl_id
    and    pln.pl_id = pyp.pl_id
    and    pln.pl_stat_cd = 'A'
    and    pyp.yr_perd_id = yp.yr_perd_id
    and    p_effective_date BETWEEN yp.start_date AND yp.end_date
    and    pyp.business_group_id = p_business_group_id
    and    yp.business_group_id = p_business_group_id
    and    p_effective_date between
           pln.effective_start_date and pln.effective_end_date;
   --
   l_pl_subj_frfs c_pl_subj_frfs%rowtype;
   --
  cursor c_abr (p_effective_date date, p_acty_typ_cd varchar2) is
   select /* abr.*,*/ clf.* -- 9999 Add the only colums required.
   from ben_acty_base_rt_f abr,
        ben_comp_lvl_fctr clf
   where abr.acty_typ_cd like p_acty_typ_cd || '%'
         -- p_acty_typ_cd is like PRD/PRC
     and abr.pl_id = p_pl_id
     and abr.acty_base_rt_stat_cd = 'A'
     and abr.ttl_comp_lvl_fctr_id = clf.comp_lvl_fctr_id
     and p_effective_date between
         abr.effective_start_date and abr.effective_end_date;
  --
  cursor c_abr_temp (p_effective_date date, p_acty_typ_cd varchar2) is
   select /* abr.*,*/ clf.* -- 9999 Add the only colums required.
   from ben_acty_base_rt_f abr,
        ben_comp_lvl_fctr clf
   where abr.acty_typ_cd not like 'PRD%'
     and abr.pl_id = p_pl_id
     and abr.acty_base_rt_stat_cd = 'A'
     and abr.ttl_comp_lvl_fctr_id = clf.comp_lvl_fctr_id
     and p_effective_date between
         abr.effective_start_date and abr.effective_end_date;
  --
  l_cntr_clf  c_abr%rowtype;
  l_distr_clf c_abr%rowtype;
  --
  -- Get all the persons who enrolled in this paln.
  --
  cursor c_persons  (p_pl_id number, p_effective_date date,
                     p_start_date date, p_end_date date) is
   select unique pen.person_id
          /* pen.prtt_enrt_rslt_id, pen.person_id, pen.pl_id, pen.oipl_id,
             pen.pgm_id, pen.pl_typ_id
          */
   from   ben_prtt_enrt_rslt_f pen,
          per_all_people_f per
   where  per.person_id = pen.person_id
    and   per.business_group_id = pen.business_group_id
    and   p_effective_date between per.effective_start_date
                                and per.effective_end_date
    and   pen.prtt_enrt_rslt_stat_cd is null
    and   pen.sspndd_flag = 'N'
    and   pen.comp_lvl_cd not in ('PLANFC', 'PLANIMP')
    and   ( (pen.enrt_cvg_thru_dt = hr_api.g_eot
             and pen.effective_end_date = hr_api.g_eot
             and pen.enrt_cvg_strt_dt < p_end_date
            )
          or(pen.enrt_cvg_thru_dt = hr_api.g_eot
             and pen.effective_end_date between p_start_date and p_end_date
             and pen.enrt_cvg_strt_dt < p_end_date
            )
          or(pen.enrt_cvg_thru_dt = hr_api.g_eot
             and pen.effective_end_date between p_start_date and p_end_date
             and pen.enrt_cvg_strt_dt   between p_start_date and p_end_date
            )
          )
    and   pen.pl_id = p_pl_id
    and   pen.business_group_id = p_business_group_id
    and   (pen.person_id = p_person_id or p_person_id is null)
    and   (per.person_type_id = p_person_type_id or p_person_type_id is null) ;
  --
  cursor c_rmbrq_total (p_pl_id number, p_person_id number,
                        p_effective_date date,
                        p_start_date date, p_end_date date) is
     select sum(nvl(pry.aprvd_fr_pymt_amt,0))
     from   ben_prtt_reimbmt_rqst_f prc,
            ben_prtt_rmt_aprvd_fr_pymt_f pry
     where  prc.pl_id = p_pl_id
       and  prc.prtt_reimbmt_rqst_stat_cd in ( 'APPRVD','PDINFL','PRTLYPD')
       and  nvl(pry.pymt_stat_cd,' ') <> ('RMBPNDNG')
       and  p_effective_date between prc.effective_start_date
                                 and prc.effective_end_date
       and  prc.submitter_person_id = p_person_id
       and  prc.business_group_id  = p_business_group_id
       and  prc.incrd_from_dt between p_start_date and p_end_date
            -- is it clms thru dt
       and  prc.incrd_to_dt between p_start_date and p_end_date
            -- 9999 what is p_end_date
       and prc.prtt_reimbmt_rqst_id = pry.prtt_reimbmt_rqst_id
       and  p_effective_date between pry.effective_start_date
                                 and pry.effective_end_date;
  --
  cursor c_bnft_bal(p_bnfts_bal_id number, p_person_id number) is
    select bnb.val
    from   ben_per_bnfts_bal_f bnb
    where  bnb.bnfts_bal_id = p_bnfts_bal_id
    and    bnb.person_id    = p_person_id
    and    bnb.business_group_id  = p_business_group_id
    and    p_effective_date
           between bnb.effective_start_date
           and     bnb.effective_end_date;
  --
  cursor c_asg(p_assignment_type varchar2,p_person_id number ) is
    select paf.assignment_id
    from   per_all_assignments_f paf
    where  paf.person_id = p_person_id
    and    paf.business_group_id  = p_business_group_id
    and    paf.primary_flag = 'Y'
    and    paf.assignment_type = p_assignment_type
    and    p_effective_date
           between paf.effective_start_date
           and     paf.effective_end_date;
  --
  l_ass_rec           per_all_assignments_f%ROWTYPE;
  l_assignment_id     number;
  --
  l_per_cntr_val      number;
  l_per_distr_val     number;
  l_per_frfd_val      number;
  l_tot_pl_cntr_val   number;
  l_tot_pl_distr_val  number;
  l_total_frfd_val    number;
  l_assignment_action_id number;
  l_start_date        date;
  l_end_date          date;
  l_per_rec           per_all_people_f%rowtype;
  l_err_message       varchar2(1000) ;
  --
begin
  --
  hr_utility.set_location ('Entering '||l_package,10);
  --
  savepoint process_forfeitures;

  hr_utility.set_location ('process pl_id : '||to_char(p_pl_id),10);
  --
  open c_pl_subj_frfs(p_effective_date);
  fetch c_pl_subj_frfs into l_pl_subj_frfs;
  close c_pl_subj_frfs;
  benutils.write('  Plan :  ' || l_pl_subj_frfs.name);
  if  sysdate > l_pl_subj_frfs.acpt_clm_rqsts_thru_dt or p_validate = 'Y'  then
    --
    l_start_date := l_pl_subj_frfs.start_date;
    l_end_date   := l_pl_subj_frfs.end_date;
    --
    hr_utility.set_location ('process l_start_date : '||to_char(l_start_date),15);
    hr_utility.set_location ('process l_end_date : '||to_char(l_end_date),15);
    hr_utility.set_location ('p_effective_date : '||to_char(p_effective_date),15);
    --
    open   c_abr(p_effective_date, 'PRC');
    fetch  c_abr into l_cntr_clf;
    close  c_abr;
    --
    -- This is temporary fix till the new lookups for ben_acty_typ_cd
    -- are added - PRCPR, PRCPPR, PRCPER
    --
    if l_cntr_clf.comp_lvl_fctr_id is null then
       --
       open   c_abr_temp(p_effective_date, 'PRD');
       fetch  c_abr_temp into l_cntr_clf;
       close  c_abr_temp;
       --
    end if;
    -- ???? 99999 ERROR if not found what to do?
    hr_utility.set_location ('Cntr Comp level factor id = '
                             || l_cntr_clf.comp_lvl_fctr_id, 20);
    hr_utility.set_location ('Cntr Comp level name id = ' || l_cntr_clf.name, 22);
    open   c_abr(p_effective_date, 'PRD');
    fetch  c_abr into l_distr_clf;
    close  c_abr;
    hr_utility.set_location ('Distr Comp level factor id = '
                             || l_distr_clf.comp_lvl_fctr_id, 20);
    hr_utility.set_location ('distr Comp level name id = ' || l_distr_clf.name, 22);
    --
    -- ???? 99999 ERROR if not found what to do?
    --
    --
    -- Loop through the results matching pl_id and person_id
    --
    for l_person_rec in c_persons(p_pl_id, p_effective_date,
                                  l_start_date, l_end_date)
    loop
       --
       -- Initialise the totals.
       --
       l_per_cntr_val     := 0;
       l_per_distr_val    := 0;
       l_per_frfd_val     := 0;
       --
       hr_utility.set_location ('process person_id : '||
                                    to_char(l_person_rec.person_id),30);
       fnd_message.set_name('BEN','BEN_91333_CALLING_PROC');
       fnd_message.set_token('PROC','ben_person_object');
       ben_person_object.get_object(p_person_id => l_person_rec.person_id,
                                    p_rec       => l_per_rec);

       hr_utility.set_location ('process det cd ' || l_pl_subj_frfs.frfs_cntr_det_cd,30) ;
       hr_utility.set_location ('process src cd ' || l_cntr_clf.comp_src_cd,30) ;

       if l_pl_subj_frfs.frfs_cntr_det_cd = 'USECLF' then
          --
          if l_cntr_clf.comp_src_cd = 'BNFTBALTYP' THEN
             --
             -- Get the persons balance
             --
             open c_bnft_bal(l_cntr_clf.bnfts_bal_id, l_person_rec.person_id);
             fetch c_bnft_bal into l_per_cntr_val;
             close c_bnft_bal;
             --
          elsif l_cntr_clf.comp_src_cd = 'BALTYP' THEN
             --
             -- Get the persons balance
             --
             l_assignment_id := null;
             open c_asg('E',l_person_rec.person_id );
             fetch c_asg into l_assignment_id;
             close c_asg;
             IF l_assignment_id IS NULL THEN
               --
               hr_utility.set_location (' employee failed   ' || l_assignment_id , 30) ;
               open c_asg('B',l_person_rec.person_id);
               fetch c_asg into l_assignment_id;
               close c_asg;
               --
               -- 9999 Error out if assignment is not found for person.
               --
             END IF;
             --
             hr_utility.set_location (' assignent  ' || l_assignment_id , 30) ;

             ben_derive_part_and_rate_facts.set_taxunit_context
            (p_person_id           => l_person_rec.person_id
            ,p_business_group_id   => p_business_group_id
            ,p_effective_date      => p_effective_date
             ) ;
             --
             -- Bug 3818453. Pass assignment_action_id to get_value() to
             -- improve performance
             --
             l_assignment_action_id :=
                               ben_derive_part_and_rate_facts.get_latest_paa_id
                               (p_person_id         => l_person_rec.person_id
                               ,p_business_group_id => p_business_group_id
                               ,p_effective_date    => p_effective_date);

             if l_assignment_action_id is not null then
                --
                begin
                   l_per_cntr_val  :=
                   pay_balance_pkg.get_value(l_cntr_clf.defined_balance_id
                   ,l_assignment_action_id);
                exception
                  when others then
                  l_per_cntr_val := null ;
                end ;
                --
               --
             end if ;

             --
             -- old code prior to 3818453
             --
/*
             l_per_cntr_val  :=
               pay_balance_pkg.get_value(l_cntr_clf.defined_balance_id
                ,l_assignment_id
                ,p_effective_date); -- 9999 should it be based on comp_lvl_det_cd
*/
             hr_utility.set_location (' value of defined ' || l_per_cntr_val , 30) ;
             --
          end if;
          --
          IF    l_cntr_clf.rndg_cd IS NOT NULL
             OR l_cntr_clf.rndg_rl IS NOT NULL THEN
            --
            l_per_cntr_val  :=
              benutils.do_rounding(p_rounding_cd=> l_cntr_clf.rndg_cd
               ,p_rounding_rl    => l_cntr_clf.rndg_rl
               ,p_value          => nvl(l_per_cntr_val, 0)
               ,p_effective_date => p_effective_date);
          --
          END IF;
       --
       end if;
       --
       -- Compute the total distribution for the person.
       --

       if l_pl_subj_frfs.frfs_distr_det_cd = 'USECLF' then
           --
           if l_distr_clf.comp_src_cd = 'BNFTBALTYP' THEN
              --
              -- Get the persons balance
              --
              open c_bnft_bal(l_distr_clf.bnfts_bal_id, l_person_rec.person_id);
              fetch c_bnft_bal into l_per_distr_val;
              close c_bnft_bal;
              --
           elsif l_distr_clf.comp_src_cd = 'BALTYP' THEN
              --
              -- Get the persons balance
              --
                l_assignment_id :=  null;
                --
                open c_asg('E', l_person_rec.person_id);
                fetch c_asg into l_assignment_id;
                close c_asg;
                IF l_assignment_id IS NULL THEN
                --
                open c_asg('B', l_person_rec.person_id);
                fetch c_asg into l_assignment_id;
                close c_asg;
                --
                -- 9999 Error out if assignment is not found for person.
                --
              END IF;

              ben_derive_part_and_rate_facts.set_taxunit_context
             (p_person_id           => l_person_rec.person_id
             ,p_business_group_id   => p_business_group_id
             ,p_effective_date      => p_effective_date
              ) ;
              --
              -- Bug 3818453. Pass assignment_action_id to get_value() to
              -- improve performance
              --
              l_assignment_action_id :=
                                ben_derive_part_and_rate_facts.get_latest_paa_id
                                (p_person_id         => l_person_rec.person_id
                                ,p_business_group_id => p_business_group_id
                                ,p_effective_date    => p_effective_date);

              if l_assignment_action_id is not null then
                 --
                 begin
                    l_per_distr_val  :=
                    pay_balance_pkg.get_value(l_distr_clf.defined_balance_id
                    ,l_assignment_action_id);
                 exception
                   when others then
                   l_per_distr_val := null ;
                 end ;
                 --
                --
              end if ;

              --
              -- old code prior to 3818453
              --
/*
              l_per_distr_val  :=
                pay_balance_pkg.get_value(l_distr_clf.defined_balance_id
                 ,l_assignment_id
                 ,p_effective_date); -- 9999 should it be based on comp_lvl_det_cd
*/
              --
           end if;
           --
           IF    l_distr_clf.rndg_cd IS NOT NULL
              OR l_distr_clf.rndg_rl IS NOT NULL THEN
             --
             l_per_distr_val  :=
               benutils.do_rounding(p_rounding_cd=> l_distr_clf.rndg_cd
                ,p_rounding_rl    => l_distr_clf.rndg_rl
                ,p_value          => nvl(l_per_distr_val, 0)
                ,p_effective_date => p_effective_date);
           --
           END IF;
        --
       elsif l_pl_subj_frfs.frfs_distr_det_cd = 'USERMBRQ' then
          --
          open c_rmbrq_total (p_pl_id, l_person_rec.person_id,
                              p_effective_date,
                              l_start_date, l_end_date );
          fetch c_rmbrq_total into  l_per_distr_val;
          close c_rmbrq_total;
          hr_utility.set_location(' in USERMBQ ' , 99);
          hr_utility.set_location(' USERMBQ value  '|| l_per_distr_val , 99);
          --
          --
       end if;
       --
       hr_utility.set_location(' det cd  '|| l_pl_subj_frfs.frfs_distr_det_cd  , 99);
       hr_utility.set_location(' pl ' || p_pl_id , 99);
       hr_utility.set_location(' person ' || l_person_rec.person_id , 99 );
       hr_utility.set_location(' start date ' || l_start_date , 99 );
       hr_utility.set_location(' end date ' || l_end_date , 99 );
       hr_utility.set_location(' effective date ' || p_effective_date , 99);


       l_per_frfd_val := nvl(l_per_cntr_val, 0) - nvl(l_per_distr_val, 0) ;
       benutils.write('  Name :  ' || l_per_rec.full_name);
       benutils.write('     Total Contributed = ' || to_char(nvl(l_per_cntr_val, 0)) );
       benutils.write('     Total Distributed = ' || to_char(nvl(l_per_distr_val, 0)) );
         benutils.write('     Total Forfeited   = ' || to_char(nvl(l_per_frfd_val, 0)) );
       --
       hr_utility.set_location('  Name :  ' || l_per_rec.full_name, 9999);
       hr_utility.set_location('     Total Contributed = '
                                     || to_char(l_per_cntr_val) , 9999);
       hr_utility.set_location('     Total Distributed = '
                                     || to_char(l_per_distr_val) , 9999);
       hr_utility.set_location('     Total Forfeited   = '
                                     || to_char(l_per_frfd_val) , 9999);
       -- 9999 if l_per_frfd_val is negative what to do?
       l_tot_pl_cntr_val  := nvl(l_tot_pl_cntr_val, 0) + nvl(l_per_cntr_val, 0);
       l_tot_pl_distr_val := nvl(l_tot_pl_distr_val, 0) + nvl(l_per_distr_val, 0);
       l_total_frfd_val   := nvl(l_total_frfd_val, 0) + nvl(l_per_frfd_val, 0);
       --
       -- Create the participant rate val row.
       --
       if l_per_frfd_val  >= 0 then
          --
          create_per_frftd_rt (
               p_validate              => p_validate
              ,p_pl_id                 => p_pl_id
              ,p_pgm_id                => null
              ,p_business_group_id     => p_business_group_id
              ,p_effective_date        => p_effective_date
              ,p_end_date              => l_end_date
              ,p_start_date            => l_start_date
              ,p_person_id             => l_person_rec.person_id
              ,p_per_frftd_val         => l_per_frfd_val);
          --
       end if;
       --
       -- write forfeiture for person info to reporting table
       --

       g_rec.rep_typ_cd            := 'FRPERPLVAL';
       g_rec.person_id             := l_person_rec.person_id;
       g_rec.pgm_id                := null; -- l_each_result.pgm_id;
       g_rec.pl_id                 := p_pl_id;
       g_rec.oipl_id               := null;
       g_rec.pl_typ_id             := null;
       g_rec.val                   := nvl(l_per_frfd_val, 0);
       g_rec.ler_id                := nvl(l_per_cntr_val, 0);
       g_rec.related_person_id     := nvl(l_per_distr_val, 0);
       benutils.write(p_rec => g_rec);
   end loop;

    benutils.write('  Plan :  ' || l_pl_subj_frfs.name);
    benutils.write('     Total Contributed = ' || to_char(l_tot_pl_cntr_val) );
    benutils.write('     Total Distributed = ' || to_char(l_tot_pl_distr_val) );
    benutils.write('     Total Forfeited   = ' || to_char(l_total_frfd_val) );
    --
    hr_utility.set_location('     Total Contributed = ' || to_char(l_tot_pl_cntr_val) , 9999);
    hr_utility.set_location('     Total Distributed = ' || to_char(l_tot_pl_distr_val) , 9999);
    hr_utility.set_location('     Total Forfeited   = ' || to_char(l_total_frfd_val) , 9999);
    --
    -- write forfeiture for plan info to reporting table
    --
    g_rec.rep_typ_cd            := 'FRPLVAL';
    g_rec.person_id             := null;
    g_rec.pgm_id                := null;  -- ??l_pgm_id;
    g_rec.pl_id                 := p_pl_id;
    g_rec.oipl_id               := null;
    g_rec.pl_typ_id             := null;
    g_rec.val                   := l_total_frfd_val;
    g_rec.ler_id                := nvl(l_tot_pl_cntr_val, 0);
    g_rec.related_person_id     := nvl(l_tot_pl_distr_val, 0);

    benutils.write(p_rec => g_rec);
    --
    if l_pl_subj_frfs.frfs_distr_mthd_cd = 'PRVDR' then
       --
       -- Write to table ben_pl_frfs_val_f
       -- Check whether there exists any row already for
       -- l_start_date, l_end_date and with final_clms_thru_dt.
       -- If exists update it else create one.
       -- Use the actual api's once the api's are generated.
       --
       delete from ben_pl_frfs_val_f
       where pl_id = p_pl_id
         and business_group_id = p_business_group_id
         and start_date = l_start_date
         and end_date   = l_end_date
       ;
       --
       insert into BEN_PL_FRFS_VAL_F
         (PL_FRFS_VAL_ID
         ,EFFECTIVE_START_DATE
         ,EFFECTIVE_END_DATE
         ,BUSINESS_GROUP_ID
         ,PL_ID
         ,start_date
         ,end_date
         ,ttl_cntr_val
         ,ttl_distr_val
         ,ttl_frfd_val
         ,COST_ALLOC_KEYFLEX_1_ID
         ,COST_ALLOC_KEYFLEX_2_ID
         ,OBJECT_VERSION_NUMBER
         ) values
        (
         ben_pl_frfs_val_f_s.nextval,
         p_effective_date,
         hr_api.g_eot,
         p_business_group_id,
         p_pl_id,
         l_start_date,
         l_end_date,
         l_tot_pl_cntr_val,
         l_tot_pl_distr_val,
         l_total_frfd_val,
         l_pl_subj_frfs.COST_ALLOC_KEYFLEX_1_ID,
         l_pl_subj_frfs.COST_ALLOC_KEYFLEX_2_ID,
         1
        );
       --
    end if;
     --
  Else

    fnd_message.set_name('BEN', 'BEN_92774_FORFEITURE_DATE');
    fnd_message.set_token('PLAN', l_pl_subj_frfs.name);
    l_err_message  := fnd_message.get ;
    benutils.write(' Error  :  ' || l_err_message);
  end if ;
  --  sysdate > l_pl_subj_frfs.acpt_clm_rqsts_thru_dt or p_validate = 'Y'
  if (p_validate = 'Y') then
     --
     rollback to process_forfeitures;
     --
  end if;
  --
  hr_utility.set_location ('Leaving '||l_package,500);
  --
exception
  --
  when others then
    l_error_text := sqlerrm;
    fnd_message.raise_error;
  --
end process_forfeitures;
--
--
-- ============================================================================
--                        << Procedure: Do_Multithread >>
--  Description:
--      this procedure is called from 'process'.  It calls the calc_forfeiture
--      routine.
-- ============================================================================
procedure do_multithread
             (errbuf                     out nocopy varchar2
             ,retcode                    out nocopy number
             ,p_benefit_action_id        in     number
             ,p_effective_date           in     varchar2
             ,p_validate                 in     varchar2 default 'N'
             ,p_business_group_id        in     number
             ,p_thread_id                in     number
             -- ,p_organization_id          in     number   default null
             -- ,p_frfs_perd_det_cd         in     varchar2 default null
             -- ,p_person_id                in     number   default null
             -- For Future Enhancement.
             -- ,p_person_type_id           in     number   default null
             -- For Future Enhancement.
             -- ,p_pgm_id                   in     number   default null
             -- ,p_pl_typ_id                in     number   default null
             -- ,p_pl_id                    in     number   default null
             -- ,p_comp_selection_rule_id   in     number   default null
             -- ,p_person_selection_rule_id in     number   default null
             -- For Future Enhancement.
             -- ,p_debug_messages           in     varchar2 default 'N'
             -- ,p_audit_log_flag           in     varchar2 default 'N'
             -- ,p_commit_data_flag         in     varchar2 default 'Y'
             ) is
 --
 -- Local variable declaration
 -- 9999 Check all the local variables and delete them if not used after arcsin.
 --
 l_proc                   varchar2(80) := g_package||'.do_multithread';
 l_person_id              ben_person_actions.person_id%type;
 l_person_action_id       ben_person_actions.person_action_id%type;
 l_object_version_number  ben_person_actions.object_version_number%type;
 l_ler_id                 ben_person_actions.ler_id%type;
 l_range_id               ben_batch_ranges.range_id%type;
 l_record_number          number := 0;
 l_start_person_action_id number := 0;
 l_end_person_action_id   number := 0;
 l_actn                   varchar2(80);
 l_cnt                    number(5):= 0;
 l_chunk_size             number(15);
 l_threads                number(15);
 l_effective_date         date;
 --
 -- Cursors declaration
 --
 Cursor c_range_thread is
   Select ran.range_id
         ,ran.starting_person_action_id
         ,ran.ending_person_action_id
     From ben_batch_ranges ran
    Where ran.range_status_cd = 'U'
      And ran.BENEFIT_ACTION_ID  = P_BENEFIT_ACTION_ID
      And rownum < 2
      For update of ran.range_status_cd
         ;
  Cursor c_person_thread is
    Select ben.person_id
          ,ben.person_action_id
          ,ben.object_version_number
          ,ben.ler_id
      From ben_person_actions ben
     Where ben.benefit_action_id = p_benefit_action_id
       And ben.action_status_cd <> 'P'
       And ben.person_action_id between
              l_start_person_action_id and l_end_person_action_id
     Order by ben.person_action_id
          ;
  Cursor c_parameter is
    Select *
      From ben_benefit_actions ben
     Where ben.benefit_action_id = p_benefit_action_id
          ;
  l_parm c_parameter%rowtype;
  l_ovn                number := null;
  l_commit number;
  --
Begin
  --
  hr_utility.set_location ('Entering '||l_proc,5);
  --
  /*
  l_effective_date:=to_date(p_effective_date,'YYYY/MM/DD HH24:MI:SS');
  l_effective_date:=to_date(to_char(trunc(l_effective_date),'DD/MM/RRRR'),'DD/MM/RRRR');
  */
  --
  l_effective_date := trunc(fnd_date.canonical_to_date(p_effective_date));
  --
  -- Put row in fnd_sessions
  --
  dt_fndate.change_ses_date
      (p_ses_date => l_effective_date,
       p_commit   => l_commit);
  --
  l_actn := 'Calling benutils.get_parameter...';
  --
  benutils.get_parameter(p_business_group_id  => p_business_group_Id
                        ,p_batch_exe_cd       => 'BENFRCON'
                        ,p_threads            => l_threads
                        ,p_chunk_size         => l_chunk_size
                        ,p_max_errors         => g_max_errors_allowed);
  --
  -- Set up benefits environment
  --
  ben_env_object.init(p_business_group_id => p_business_group_id,
                      p_effective_date    => l_effective_date,
                      p_thread_id         => p_thread_id,
                      p_chunk_size        => l_chunk_size,
                      p_threads           => l_threads,
                      p_max_errors        => g_max_errors_allowed,
                      p_benefit_action_id => p_benefit_action_id);
  --
  l_actn := 'Calling ben_batch_utils.ini...';
  ben_batch_utils.ini; -- deletes g_cache_person, g_cache_comp, g_pgm_tbl etc.,
  --
  -- Copy benefit action id to global in benutils package
  --
  benutils.g_benefit_action_id := p_benefit_action_id;
  benutils.g_thread_id         := p_thread_id;
  g_persons_errored            := 0;
  g_persons_processed          := 0;
  open c_parameter;
  fetch c_parameter into l_parm;
  close c_parameter;
  --
  l_actn := 'Calling ben_batch_utils.print_parameters...';
  --
  -- 9999 It calls the write routine in benrptut, in turn calls fnd_file.put_line
  ben_batch_utils.print_parameters
          (p_thread_id                => p_thread_id
          ,p_benefit_action_id        => p_benefit_action_id
          ,p_effective_date           => l_effective_date
          ,p_validate                 => p_validate
          ,p_business_group_id        => l_parm.business_group_id
          -- ,p_frfs_perd_det_cd         => l_parm.frfs_perd_det_cd -- 9999 l_parm needs to be changed.
                                         -- If it comes from l_parm then delete it as parameter.
                                         -- How to store it as param.
          ,p_person_id                => l_parm.person_id
          ,p_person_type_id           => l_parm.person_type_id
          ,p_person_selection_rule_id => null -- 9999 what to send l_parm.person_selection_rule_id
          ,p_comp_selection_rule_id   => l_parm.comp_selection_rl
          ,p_pgm_id                   => l_parm.pgm_id
          ,p_pl_typ_id                => l_parm.pl_typ_id
          ,p_pl_id                    => l_parm.pl_id
          ,p_organization_id          => l_parm.organization_id -- 9999 l_parm needs to be changed.
                                         -- If it comes from l_parm then delete it as parameter.
          ,p_ler_id                   => null
          ,p_benfts_grp_id            => null
          ,p_location_id              => null
          ,p_legal_entity_id          => null
          ,p_payroll_id               => null
          );
  --
  -- While loop to only try and fetch records while they exist
  -- we always try and fetch the size of the chunk, if we get less
  -- then we know that the process is finished so we end the while loop.
  -- The process is as follows :
  -- 1) Lock the rows that are not processed
  -- 2) Grab as many rows as we can upto the chunk size
  -- 3) Put each row into the person cache.
  -- 4) Process the person cache
  -- 5) Go to number 1 again.
  --
  hr_utility.set_location('About to Loop for c_range_thread',38);

  Loop
    l_actn := 'Opening c_range thread and fetch range...';
    open c_range_thread;
    fetch c_range_thread into l_range_id
                             ,l_start_person_action_id
                             ,l_end_person_action_id;
    exit when c_range_thread%notfound;
    close c_range_thread;
    If(l_range_id is not NULL) then
      --
      l_actn := 'Updating ben_batch_ranges row...';
      --
      update ben_batch_ranges ran set ran.range_status_cd = 'P'
         where ran.range_id = l_range_id;
      commit;
    End if;
    --
    -- Remove all records from cache
    --

    --  9999 ?? why is the cache used here, it's not saving any processing time
    --
    l_actn := 'Clearing g_cache_person_process cache...';
    g_cache_person_process.delete;
    open c_person_thread;
    l_record_number := 0;
    hr_utility.set_location('about to loop for c_person_thread',46);
    Loop
      --
      l_actn := 'Loading Plans data into g_cache_person_process cache...';
      --
      fetch c_person_thread
        into g_cache_person_process(l_record_number+1).person_id
            ,g_cache_person_process(l_record_number+1).person_action_id
            ,g_cache_person_process(l_record_number+1).object_version_number
            ,g_cache_person_process(l_record_number+1).ler_id;
      exit when c_person_thread%notfound;
      l_record_number := l_record_number + 1;
    End loop;

    close c_person_thread;

    l_actn := 'Preparing to default each plan/participant from cache...' ;
    If l_record_number > 0 then
      --
      -- Process the rows from the person process cache (This is plan cache)
      --
      hr_utility.set_location('about to Loop thru forfeiture....',50);
      For l_cnt in 1..l_record_number loop
        Begin
          --
          process_forfeitures (
             p_validate              => p_validate
            ,p_pl_id                 => g_cache_person_process(l_cnt).person_id
            ,p_business_group_id     => p_business_group_id
            ,p_effective_date        => l_effective_date
            ,p_person_id             => l_parm.person_id
            ,p_person_type_id        => l_parm.person_type_id
            ,p_person_selection_rule_id => null); -- l_parm.person_selection_rule_id);
          --
          g_persons_processed := g_persons_processed + 1;
          --
          -- If we get here it was successful.
          --
          update ben_person_actions
              set   action_status_cd = 'P'
              where person_id = g_cache_person_process(l_cnt).person_id
              and   benefit_action_id = p_benefit_action_id;
          --
        Exception
          When others then
              g_persons_errored := g_persons_errored + 1;
              --
              -- Need to write to reporting tables as well
              -- by calling benutils.write(p_rec => g_rec);
              --
              update ben_person_actions
              set   action_status_cd = 'E'
              where person_id = g_cache_person_process(l_cnt).person_id
              and   benefit_action_id = p_benefit_action_id;
              --
              commit;
              --
              If (g_persons_errored > g_max_errors_allowed) then
                  hr_utility.set_location ('Errors received exceeds max allowed',05);
                  fnd_message.raise_error;
              End if;
        End;
      End loop;
    Else
      --
      l_actn := 'Erroring out nocopy since no plan/person is found in range...' ;
      hr_utility.set_location ('BEN_92452_PREM_NOT_IN_RNG',05); -- 999
      fnd_message.set_name('BEN','BEN_92452_PREM_NOT_IN_RNG');
      fnd_message.set_token('PROC', l_proc);
      fnd_message.raise_error;
    End if;

    -- 9999 Write only if requested by the user.
    benutils.write_table_and_file(p_table => TRUE, p_file  => TRUE);
  End loop;

  hr_utility.set_location('End of loops',70);
    -- 9999 Write only if requested by the user.
  benutils.write_table_and_file(p_table => TRUE, p_file  => TRUE);
  --
  l_actn := 'Calling Log_statistics...';
  ben_batch_utils.write_logfile(p_num_pers_processed => g_persons_processed
                               ,p_num_pers_errored   => g_persons_errored
                               );
  hr_utility.set_location ('Leaving '||l_proc,70);
Exception
  When others then
    ben_batch_utils.rpt_error(p_proc       => l_proc
                             ,p_last_actn  => l_actn
                             ,p_rpt_flag   => TRUE
                             );
    ben_batch_utils.write_logfile(p_num_pers_processed => g_persons_processed
                                 ,p_num_pers_errored   => g_persons_errored
                                 );
    benutils.write_table_and_file(p_table => TRUE, p_file  => TRUE);
    hr_utility.set_location ('HR_6153_ALL_PROCEDURE_FAIL',05);
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP',l_actn );
    fnd_message.raise_error;
    --
End do_multithread;
-- *************************************************************************
-- *                          << Procedure: Process >>
-- *************************************************************************
--  This is what is called from the concurrent manager screen
--
procedure process_by_plan(errbuf                        out nocopy varchar2
                 ,retcode                       out nocopy number
                 ,p_benefit_action_id        in     number
                 ,p_effective_date           in     varchar2
                 ,p_validate                 in     varchar2 default 'N'
                 ,p_business_group_id        in     number
                 ,p_organization_id          in     number   default null
                 ,p_frfs_perd_det_cd         in     varchar2 default null
                 ,p_person_id                in     number   default null -- For Future Enhancement.
                 ,p_person_type_id           in     number   default null -- For Future Enhancement.
                 ,p_pgm_id                   in     number   default null
                 ,p_pl_typ_id                in     number   default null
                 ,p_pl_id                    in     number   default null
                 ,p_comp_selection_rule_id   in     number   default null
                 ,p_person_selection_rule_id in     number   default null -- For Future Enhancement.
                 ,p_debug_messages           in     varchar2 default 'N'
                 ,p_audit_log_flag           in     varchar2 default 'N'
                 ,p_commit_data_flag         in     varchar2 default 'Y'
                 ,p_threads                  in     number
                 ,p_chunk_size               in     number
                 ,p_max_errors               in     number
                 ,p_restart                  in     boolean default FALSE ) is
  --
  -- Cursors declaration.
  --

  -- Plans subjected to forfeiture to be processed:
  cursor c_pl_subj_frfs (p_effective_date date) is
    select pln.*
    from   ben_pl_f pln
    where  pln.business_group_id = p_business_group_id
    and    pln.frfs_aply_flag    = 'Y'
    and    pln.pl_stat_cd = 'A'
    and    pln.pl_id = NVL(p_pl_id, pln.pl_id)
    and    pln.pl_typ_id = NVL(p_pl_typ_id, pln.pl_typ_id)
    and    p_effective_date between
           pln.effective_start_date and pln.effective_end_date
    and    (p_pgm_id is null
            OR EXISTS
                    (SELECT   NULL
                     FROM     ben_plip_f cpp
                     WHERE    cpp.pl_id = pln.pl_id
                     -- AND      cpp.pgm_id = NVL(p_pgm_id, cpp.pgm_id)
                     AND      cpp.pgm_id = p_pgm_id
                     AND      cpp.business_group_id = pln.business_group_id
                     AND      cpp.plip_stat_cd = 'A'
                     AND      p_effective_date BETWEEN cpp.effective_start_date
                                  AND cpp.effective_end_date));
   l_pl_subj_frfs c_pl_subj_frfs%rowtype;

  l_pl_typ_id number ;
  l_pl_id     number ;
  l_opt_id    number ; -- 9999 it is not necessary remove it later
  l_pgm_id    number ;
  --
  -- local variable declaration.
  --
  l_effective_date         date;
  l_request_id             number;
  l_proc                   varchar2(80) := g_package||'.process_by_plan';
  l_benefit_action_id      ben_benefit_actions.benefit_action_id%type;
  l_object_version_number  ben_benefit_actions.object_version_number%type;
  l_person_action_id       ben_person_actions.person_action_id%type;
  l_ler_id                 ben_ler_f.ler_id%type;
  l_range_id               ben_batch_ranges.range_id%type;
  l_start_person_action_id number := 0;
  l_end_person_action_id   number := 0;
  l_prev_person_id         number := 0;
  -- 9999 make them start with l_
  rl_ret                   char(1);
  skip                     boolean;
  l_person_cnt             number := 0;
  l_cnt                    number := 0;
  l_actn                   varchar2(80);
  l_num_range              number := 0;
  l_chunk_num              number := 1;
  l_num_row                number := 0;
  l_commit                 number;
  l_outputs                ff_exec.outputs_t;
  l_return                 varchar2(30);

Begin
  hr_utility.set_location ('Entering '||l_proc,10);
  hr_utility.set_location ('p_effective_date '||p_effective_date,10);
  /*
  l_effective_date:=to_date(p_effective_date,'YYYY/MM/DD HH24:MI:SS');
  l_effective_date:=to_date(to_char(trunc(l_effective_date),'DD/MM/RRRR'),'DD/MM/RRRR');
  */
  l_effective_date := trunc(fnd_date.canonical_to_date(p_effective_date));
  --
  --
  --9999 Needed?? l_actn := 'Initialize the ben_batch_utils cache...';
  --9999 Needed??   ben_batch_utils.ini;
  --9999 Needed??   l_actn := 'Initialize the ben_batch_utils cache...';
  --9999 Needed??   ben_batch_utils.ini(p_actn_cd => 'PROC_INFO');
  --
  -- Create actions if we are not doing a restart.
  --
  l_benefit_action_id := p_benefit_action_id;

  If NOT(p_restart) then
    hr_utility.set_location('Not a Restart',14);
    --
    -- Now lets create person actions for all the people we are going to
    -- process in the Forfeiture Calculation run.
    --
    hr_utility.set_location('l_effective_date ' || l_effective_date ,14);
    hr_utility.set_location('p_bg ' || p_business_group_id ,14);
    open c_pl_subj_frfs(p_effective_date => l_effective_date);
    l_person_cnt := 0;
    l_cnt := 0;
    l_actn := 'Loading person_actions table..';
    Loop
      fetch c_pl_subj_frfs into l_pl_subj_frfs;
      Exit when c_pl_subj_frfs%notfound;
      l_cnt := l_cnt + 1;
      l_actn := 'Calling ben_batch_utils.comp_obj_selection_rule...';
      hr_utility.set_location('pl_id='||to_char(l_pl_subj_frfs.pl_id)||
                ' l_cnt='||to_char(l_cnt),18);
      --
      -- if comp_obj_selection_rule is pass, test rule.
      -- If the rule return 'N' then
      -- skip that pl_id.
      --
      skip := FALSE;

      -- check criteria that the user entered on the submit form.

      if p_pl_id is not null or p_pl_typ_id is not null or p_pgm_id is not null
         or p_comp_selection_rule_id is not null then
         rl_ret := 'Y';
         --
         ben_prem_pl_oipl_monthly.get_comp_object_info
             (p_oipl_id        => null -- 9999 l_pl_subj_frfs.oipl_id
             ,p_pl_id          => l_pl_subj_frfs.pl_id
             ,p_pgm_id         => p_pgm_id
             ,p_effective_date => l_effective_date
             ,p_out_pgm_id     => l_pgm_id
             ,p_out_pl_typ_id  => l_pl_typ_id
             ,p_out_pl_id      => l_pl_id
             ,p_out_opt_id     => l_opt_id);

         if p_pl_id is not null and p_pl_id <> l_pl_id then
               rl_ret := 'N';
         elsif p_pl_typ_id is not null and p_pl_typ_id <> l_pl_typ_id then
               rl_ret := 'N';
         elsif p_pgm_id is not null and p_pgm_id <> l_pgm_id then
               rl_ret := 'N';
         elsif rl_ret = 'Y' and p_comp_selection_rule_id is not null then
            l_actn := 'found a comp object rule...';
            hr_utility.set_location('found a comp object rule',22);
            l_outputs := benutils.formula
                      (p_formula_id        => p_comp_selection_rule_id
                      ,p_effective_date    => l_effective_date
                      ,p_pgm_id            => l_pgm_id
                      ,p_pl_id             => l_pl_id
                      ,p_pl_typ_id         => l_pl_typ_id
                      ,p_opt_id            => l_opt_id
                      ,p_ler_id            => null
                      ,p_business_group_id => p_business_group_id);
            --
            l_return := l_outputs(l_outputs.first).value;
            if upper(l_return) not in ('Y', 'N')  then
               l_return := 'N';
            end if;

            rl_ret:= l_return;

            --
         end if;

         If (rl_ret = 'N') then
            skip := TRUE;
         End if;

      end if;


      --
      -- Store pl_id into person actions table.
      --
      If ( not skip) then
        hr_utility.set_location('not skip...Inserting Ben_person_actions',28);
        l_actn := 'Inserting Ben_person_actions...';
        select ben_person_actions_s.nextval
        into   l_person_action_id
        from   sys.dual;

        insert into ben_person_actions
              (person_action_id,
               person_id,
               ler_id,
               benefit_action_id,
               action_status_cd,
               object_version_number,
               chunk_number,
               non_person_cd)
            values
              (l_person_action_id,
               l_pl_subj_frfs.pl_id,
               0,
               p_benefit_action_id,
               'U',
               1,
               l_chunk_num,
               'FRFS');

        l_num_row := l_num_row + 1;
        l_person_cnt := l_person_cnt + 1;
        l_end_person_action_id := l_person_action_id;
        If l_num_row = 1 then
          l_start_person_action_id := l_person_action_id;
        End if;
        If l_num_row = p_chunk_size then
          --
          -- Create a range of data to be multithreaded.
          --
          l_actn := 'Inserting Ben_batch_ranges.......';
          hr_utility.set_location('Inserting Ben_batch_ranges',32);
          -- Select next sequence number for the range
          --
          select ben_batch_ranges_s.nextval
          into   l_range_id
          from   sys.dual;

          insert into ben_batch_ranges
            (range_id,
             benefit_action_id,
             range_status_cd,
             starting_person_action_id,
             ending_person_action_id,
             object_version_number)
          values
            (l_range_id,
             p_benefit_action_id,
             'U',
             l_start_person_action_id,
             l_end_person_action_id,
             1);
          l_start_person_action_id := 0;
          l_end_person_action_id   := 0;
          l_num_row                := 0;
          l_num_range              := l_num_range + 1;
          l_chunk_num              := l_chunk_num + 1;
        End if;
      End if;
    End loop;
    Close c_pl_subj_frfs;
    --
    hr_utility.set_location('l_num_row='||to_char(l_num_row),34);
    If (l_num_row <> 0) then
      l_actn := 'Inserting Final Ben_batch_ranges...';
      hr_utility.set_location('Inserting Final Ben_batch_ranges',38);

          select ben_batch_ranges_s.nextval
          into   l_range_id
          from   sys.dual;

          insert into ben_batch_ranges
            (range_id,
             benefit_action_id,
             range_status_cd,
             starting_person_action_id,
             ending_person_action_id,
             object_version_number)
          values
            (l_range_id,
             p_benefit_action_id,
             'U',
             l_start_person_action_id,
             l_end_person_action_id,
             1);
      l_num_range := l_num_range + 1;
    End if;
  Else
    hr_utility.set_location('This is a RESTART',42);
    l_actn := 'Calling Ben_batch_utils.create_restart_person_actions...';
    -- 9999 What this procedure does
    Ben_batch_utils.create_restart_person_actions
      (p_benefit_action_id  => p_benefit_action_id
      ,p_effective_date     => l_effective_date
      ,p_chunk_size         => p_chunk_size
      ,p_threads            => p_threads
      ,p_num_ranges         => l_num_range
      ,p_num_persons        => l_person_cnt
      ,p_non_person_cd      => 'FRFS'  -- code used in benrptut.pkb
      );
  End if;
  commit;
  --
  -- Now to multithread the code.
  --
  hr_utility.set_location('l_num_range '||to_char(l_num_range),46);
  If l_num_range > 1 then
    For l_count in 1..least(p_threads,l_num_range)-1 loop
      --
      l_actn := 'Submitting job to con-current manager...';
      hr_utility.set_location('Submitting BENFRCON to con-current manager ',50);
      -- Conncurrent manage needs the effective date in a varchar form.
      l_request_id := fnd_request.submit_request
                        (application => 'BEN'
                        ,program     => 'BENFRCOM'
                        ,description => NULL
                        ,sub_request => FALSE
                        ,argument1   => l_benefit_action_id
                        ,argument2   => p_effective_date
                        ,argument3   => p_validate
                        ,argument4   => p_business_group_id
                        ,argument5   => l_count
                        );
      --
      -- Store the request id of the concurrent request
      --
      ben_batch_utils.g_num_processes := ben_batch_utils.g_num_processes + 1;
      ben_batch_utils.g_processes_tbl(ben_batch_utils.g_num_processes)
        := l_request_id;
    End loop;
  Elsif (l_num_range = 0 ) then
    l_actn := 'Calling Ben_batch_utils.print_parameters...';
    hr_utility.set_location('Calling Ben_batch_utils.print_parameters ',56);
    -- 9999 Add all other required params.
    Ben_batch_utils.print_parameters
      (p_thread_id                => 99
      ,p_benefit_action_id        => l_benefit_action_id
      ,p_validate                 => p_validate
      ,p_business_group_id        => p_business_group_id
      ,p_effective_date           => l_effective_date
      ,p_mode                     => null
      ,p_comp_selection_rule_id   => p_comp_selection_rule_id
      ,p_pgm_id                   => p_pgm_id
      ,p_pl_typ_id                => p_pl_typ_id
      ,p_pl_id                    => p_pl_id
      ,p_person_id                => p_person_id
      ,p_person_selection_rule_id => p_person_selection_rule_id
      ,p_person_type_id           => p_person_type_id
      ,p_ler_id                   => null
      ,p_organization_id          => p_organization_id
      ,p_benfts_grp_id            => null
      ,p_location_id              => null
      ,p_legal_entity_id          => null
      ,p_payroll_id               => null
      );

     -- Because there  are other processes to run, do not error if first process finds
     -- noone to process.

     -- 9999 Why this is needed.
      Ben_batch_utils.write(p_text =>
          '<< No Plans For Forfeiture were selected with above selection criteria >>' );
      --fnd_message.set_name('BEN','BEN_92453_NO_PREMS_TO_PROCESS');
      --fnd_message.raise_error;
  End if;

  if (l_num_range <> 0 ) then
    -- All other parameters.
    l_actn := 'Calling do_multithread...';
    hr_utility.set_location('Calling do_multithread ',60);
    do_multithread(errbuf               => errbuf
                ,retcode              => retcode
                ,p_validate           => p_validate
                ,p_benefit_action_id  => l_benefit_action_id
                ,p_thread_id          => p_threads+1
                ,p_effective_date     => p_effective_date
                ,p_business_group_id  => p_business_group_id
                );
    l_actn := 'Calling ben_batch_utils.check_all_slaves_finished...';

    hr_utility.set_location('Calling ben_batch_utils.check_all_slaves_finished ',64);
    ben_batch_utils.check_all_slaves_finished(p_rpt_flag => TRUE);
    ben_batch_utils.end_process(p_benefit_action_id => l_benefit_action_id
                             ,p_person_selected   => l_person_cnt
                             ,p_business_group_id => p_business_group_id
                             ,p_non_person_cd     => 'FRFS');  -- used in benrptut
  end if;
  hr_utility.set_location ('Leaving '||l_proc,99);
--
Exception
  when others then
     ben_batch_utils.rpt_error(p_proc      => l_proc
                              ,p_last_actn => l_actn
                              ,p_rpt_flag  => TRUE   );
     --
     benutils.write(p_text => fnd_message.get);
     benutils.write(p_text => sqlerrm);
     benutils.write(p_text => 'Big Error Occured');
     benutils.write_table_and_file(p_table => TRUE, p_file  => TRUE);
     If (l_num_range > 0) then
       ben_batch_utils.check_all_slaves_finished(p_rpt_flag => TRUE);
       ben_batch_utils.end_process(p_benefit_action_id => l_benefit_action_id
                                  ,p_person_selected   => l_person_cnt
                                  ,p_business_group_id => p_business_group_id
       ) ;
     End if;
     hr_utility.set_location ('HR_6153_ALL_PROCEDURE_FAIL',25);
     fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE', l_proc);
     fnd_message.set_token('STEP', l_actn );
     fnd_message.raise_error;
End process_by_plan;
--
procedure process(errbuf                        out nocopy varchar2
                 ,retcode                       out nocopy number
                 ,p_benefit_action_id        in     number
                 ,p_effective_date           in     varchar2
                 ,p_validate                 in     varchar2 default 'N'
                 ,p_business_group_id        in     number
                 ,p_organization_id          in     number   default null
                 ,p_frfs_perd_det_cd         in     varchar2 default null
                 ,p_person_id                in     number   default null -- For Future Enhancement.
                 ,p_person_type_id           in     number   default null -- For Future Enhancement.
                 ,p_pgm_id                   in     number   default null
                 ,p_pl_typ_id                in     number   default null
                 ,p_pl_id                    in     number   default null
                 ,p_comp_selection_rule_id   in     number   default null
                 ,p_person_selection_rule_id in     number   default null -- For Future Enhancement.
                 ,p_debug_messages           in     varchar2 default 'N'
                 ,p_audit_log_flag           in     varchar2 default 'N'
                 ,p_commit_data_flag         in     varchar2 default 'Y'
                 ) is
  --
  -- local variable declaration.
  --
  l_request_id             number;
  l_proc                   varchar2(80) := g_package||'.process';
  l_benefit_action_id      ben_benefit_actions.benefit_action_id%type;
  l_object_version_number  ben_benefit_actions.object_version_number%type;
  l_person_id              per_people_f.person_id%type;
  l_person_action_id       ben_person_actions.person_action_id%type;
  l_ler_id                 ben_ler_f.ler_id%type;
  l_range_id               ben_batch_ranges.range_id%type;
  l_chunk_size             number := 20;
  l_threads                number := 1;
  l_start_person_action_id number := 0;
  l_end_person_action_id   number := 0;
  l_prev_person_id         number := 0;
  rl_ret                   char(1);
  skip                     boolean;
  l_person_cnt             number := 0;
  l_cnt                    number := 0;
  l_actn                   varchar2(80);
  l_num_range              number := 0;
  l_chunk_num              number := 1;
  l_num_row                number := 0;
  l_commit number;
  l_effective_date         date;
  l_effective_date_char    varchar2(19);
  l_errbuf      varchar2(80);
  l_retcode     number;
  l_restart     boolean;

Begin
  hr_utility.set_location ('Entering '||l_proc,10);
  /*
  l_effective_date:=to_date(p_effective_date,'YYYY/MM/DD HH24:MI:SS');
  l_effective_date:=to_date(to_char(trunc(l_effective_date),'DD/MM/RRRR'),'DD/MM/RRRR');
  */
  l_effective_date := trunc(fnd_date.canonical_to_date(p_effective_date));
  --
  hr_utility.set_location ('p_effective_date '||p_effective_date,999);
  hr_utility.set_location ('l_effective_date '||l_effective_date,999);
  --
  --
  -- Put row in fnd_sessions
  --
  dt_fndate.change_ses_date
      (p_ses_date => l_effective_date,
       p_commit   => l_commit);
  --
  l_actn := 'Initialize the ben_batch_utils cache...';
  ben_batch_utils.ini;
  l_actn := 'Initialize the ben_batch_utils cache...';
  ben_batch_utils.ini(p_actn_cd => 'PROC_INFO');
  --
  -- Check that all the mandatory input parameters
  -- such as p_business_group_id, p_mode, p_effective_date
  --
  l_actn := 'Checking arguments...';
  hr_utility.set_location('Checking arguments',12);
  hr_api.mandatory_arg_error(p_api_name       => g_package
                            ,p_argument       => 'p_business_group_id'
                            ,p_argument_value => p_business_group_id
                            );
  hr_api.mandatory_arg_error(p_api_name       => g_package
                            ,p_argument       => 'p_effective_date'
                            ,p_argument_value => p_effective_date );
  --
  -- Get chunk_size and Thread values for multi-thread process, and check to
  -- assure they are sensible.
  --        chunk_size between(10 and 100). If not in range, default to 20.
  --        threads between <1 and 100>. If not in range, default to 1
  --
  l_actn := 'Calling benutils.get_parameter...';
  benutils.get_parameter(p_business_group_id  => p_business_group_Id
                        ,p_batch_exe_cd       => 'BENPRCON'
                        ,p_threads            => l_threads
                        ,p_chunk_size         => l_chunk_size
                        ,p_max_errors         => g_max_errors_allowed);
  benutils.g_benefit_action_id := p_benefit_action_id;
  benutils.g_thread_id         := 99;
  --
  -- Create benefit actions parameters in the benefit action table.
  -- Do not create is a benefit action already exists, in other words
  -- we are doing a restart.
  --
  If(p_benefit_action_id is null) then

    hr_utility.set_location('p_benefit_action_id is null',14);
    l_restart := FALSE;

    ben_benefit_actions_api.create_benefit_actions
      (p_validate               => false
      ,p_benefit_action_id      => l_benefit_action_id
      ,p_process_date           => l_effective_date
      ,p_mode_cd                => 'S'
      ,p_derivable_factors_flag => 'N'
      ,p_validate_flag          => p_validate
      ,p_person_id              => p_person_id
      ,p_person_type_id         => p_person_type_id
      ,p_pgm_id                 => p_pgm_id
      ,p_business_group_id      => p_business_group_id
      ,p_pl_typ_id              => p_pl_typ_id
      ,p_pl_id                  => p_pl_id
      ,p_popl_enrt_typ_cycl_id  => null
      ,p_no_programs_flag       => 'N'
      ,p_no_plans_flag          => 'N'
      ,p_comp_selection_rl      => p_comp_selection_rule_id
      ,p_person_selection_rl    => p_person_selection_rule_id
      ,p_ler_id                 => null
      ,p_organization_id        => p_organization_id
      ,p_benfts_grp_id          => null
      ,p_location_id            => null
      ,p_pstl_zip_rng_id        => NULL
      ,p_rptg_grp_id            => NULL
      ,p_opt_id                 => NULL
      ,p_eligy_prfl_id          => NULL
      ,p_vrbl_rt_prfl_id        => NULL
      ,p_legal_entity_id        => null
      ,p_payroll_id             => null
      ,p_debug_messages_flag    => p_debug_messages
      ,p_object_version_number  => l_object_version_number
      ,p_effective_date         => l_effective_date
      ,p_request_id             => fnd_global.conc_request_id
      ,p_program_application_id => fnd_global.prog_appl_id
      ,p_program_id             => fnd_global.conc_program_id
      ,p_program_update_date    => sysdate
      );
    benutils.g_benefit_action_id := l_benefit_action_id;
    --
    -- Delete/clear ranges from ben_batch_ranges table
    --
    l_actn := 'Delete rows from ben_batch_ranges..';
    hr_utility.set_location('Delete rows from ben_batch_ranges',16);

    Delete from ben_batch_ranges
     Where benefit_action_id = l_benefit_action_id;
    --
    -- Future enhancements for individual person processing goes here.
    --
  Else
    --
    hr_utility.set_location('p_benefit_action_id is not null',30);
    l_restart := TRUE;
    l_benefit_action_id := p_benefit_action_id;
    l_actn := 'Calling Ben_batch_utils.create_restart_person_actions...';
    Ben_batch_utils.create_restart_person_actions
      (p_benefit_action_id  => p_benefit_action_id
      ,p_effective_date     => l_effective_date
      ,p_chunk_size         => l_chunk_size
      ,p_threads            => l_threads
      ,p_num_ranges         => l_num_range
      ,p_num_persons        => l_person_cnt
      );
    --
  End if;
  commit;
  --------------------------------------------------------------------------
  -- Now call the forfeitures by plan processes:
  --------------------------------------------------------------------------
  if p_person_id is null and p_person_selection_rule_id is null then
     --
     -- Only process Plans subject to forfeiture if no person criteria was
     -- selected
     --
     ben_forfeiture_concurrent.process_by_plan(
                  errbuf                     => l_errbuf
                 ,retcode                    => l_retcode
                 ,p_benefit_action_id        => l_benefit_action_id
                 ,p_effective_date           => p_effective_date -- l_effective_date_char
                 ,p_validate                 => p_validate
                 ,p_business_group_id        => p_business_group_id
                 ,p_organization_id          => p_organization_id
                 ,p_frfs_perd_det_cd         => p_frfs_perd_det_cd
                 ,p_person_id                => p_person_id
                 ,p_person_type_id           => p_person_type_id
                 ,p_pgm_id                   => p_pgm_id
                 ,p_pl_typ_id                => p_pl_typ_id
                 ,p_pl_id                    => p_pl_id
                 ,p_comp_selection_rule_id   => p_comp_selection_rule_id
                 ,p_person_selection_rule_id => p_person_selection_rule_id
                 ,p_debug_messages           => p_debug_messages
                 ,p_audit_log_flag           => p_audit_log_flag
                 ,p_commit_data_flag         => p_commit_data_flag
                 ,p_threads                  => l_threads
                 ,p_chunk_size               => l_chunk_size
                 ,p_max_errors               => g_max_errors_allowed
                 ,p_restart                  => l_restart);
  end if;
  --
  submit_all_reports;
  --
  /* Uncomment after future enhancement
  ben_batch_utils.end_process(p_benefit_action_id => l_benefit_action_id
                             ,p_person_selected   => l_person_cnt
                             ,p_business_group_id => p_business_group_id);
  */
  hr_utility.set_location ('Leaving '||l_proc,70);
--
Exception
  when others then
     ben_batch_utils.rpt_error(p_proc      => l_proc
                              ,p_last_actn => l_actn
                              ,p_rpt_flag  => TRUE   );
     --
     benutils.write(p_text => fnd_message.get);
     benutils.write(p_text => sqlerrm);
     benutils.write(p_text => 'Big Error Occured');
     benutils.write_table_and_file(p_table => TRUE, p_file  => TRUE);
     /* 999 Temporarily commented.
     If (l_num_range > 0) then
       ben_batch_utils.check_all_slaves_finished(p_rpt_flag => TRUE);
       ben_batch_utils.end_process(p_benefit_action_id => l_benefit_action_id
                                  ,p_person_selected   => l_person_cnt
                                  ,p_business_group_id => p_business_group_id
       ) ;
     End if;
     */
     hr_utility.set_location ('HR_6153_ALL_PROCEDURE_FAIL',689);
     fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE', l_proc);
     fnd_message.set_token('STEP', l_actn );
     fnd_message.raise_error;
End process;
end ben_forfeiture_concurrent;  -- End of Package.

/
