--------------------------------------------------------
--  DDL for Package Body BEN_DETERMINE_RATES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_DETERMINE_RATES" AS
/* $Header: benrates.pkb 120.6.12010000.4 2009/04/27 09:15:45 sallumwa ship $ */
--------------------------------------------------------------------------------
/*
+==============================================================================+
|			Copyright (c) 1997 Oracle Corporation                  |
|			   Redwood Shores, California, USA                     |
|			        All rights reserved.	                       |
+==============================================================================+
Name:
    Determine Rates.
Purpose:
    This process determines rates for either elctable choices or coverages, and
    writes them to the ben_enrt_rt table.  This process can only run in benmngle.
History:
        Date             Who        Version    What?
        ----             ---        -------    -----
        7 May 98        Ty Hayden  110.0      Created.
       16 Jun 98        T Guy      110.1      Deleted others exception
       18 Jun 98        Ty Hayden  110.2      Added p_rt_usg_cd
                                              p_bnft_prvdr_pool_id
                                              p_prtt_rt_val_id
       08 jul 98        Pbodla     110.3      Added a local variable
                                              l_elig_per_elctbl_chc_id1 to
                                              avoid making
                                              l_epe.elig_per_elctbl_chc_id null
       08 jul 98        jcarpent   110.4      Added PLANFC and PLANIMP
       10 aug 98        tguy       110.5      Changed inner looping cursor into
	                                      seperate cursors for performance
					      reasons.  Put inner loop logic
                                              into procedure ben_rates.This is
                                              called by associated cursor
					      loop, (ie. plan, ptip, plip, pgm,
                                              or oipl).
       11 Aug 98        Ty Hayden  110.6      Added local variables l_pl_id etc.
       11 Aug 98        Ty Hayden  110.7      Fix to local variable placement.
       07 Oct 98        T Guy      115.2      Implemented schema changes for
                                              ben_enrt_rt. Added location
                                              debugging calls.Added message
                                              numbers.
       18 Oct 98        T Guy      115.3      Added annual values and cmcd
                                              values
       20 Oct 98        T Guy      115.4      p_actl_prem_id,
                                              p_cvg_amt_cal_mthd_id
                                              p_bnft_rt_typ_cd, p_rt_typ_cd
                                              p_rt_mlt_cd, p_comp_lvl_fctr_id
                                              p_entr_ann_val_flag
                                              p_ptd_comp_lvl_fctr_id
                                              p_ann_dflt_val
                                              p_rt_start_dt, p_rt_start_dt_cd
                                              p_rt_start_dt_rl
       23 Oct 98        T Guy      115.5      added person_id to main
       02 Nov 98        T Guy      115.6      fixed asn_on_enrt_flag
                                              assignment for ben_enrt_rt
       02 Dec 98        T Guy      115.7      fixed mx_ann_elcn_val variable
                                              assignment error.
       20 Dec 98        T Guy      115.8      Added in caching information
                                              for the created enrollment rate.
       11 Jan 99        T Guy      115.9      added elctbl_chc_id as passed in parm.
                                              added edit to check if elctbl_chc_id
                                              was passed if so use it, if not then
                                              use the one from electbl_chc
       18 Jan 99        G Perry    115.10     LED V ED
       30 Jan 99        S Das      115.11     Added codes for comp objects.
       04 Mar 99        T Guy      115.12     Fixed dflt_flag and ctfn_rqd_flag
       09 Mar 99        G Perry    115.14     IS to AS.
       05 Apr 99        mhoyes     115.15   - Un-datetrack of per_in_ler_f changes.
                                            - Removed DT restriction from
                                              - main/c_epe
       30 Apr 99        lmcdonal   115.16     Add per_in_ler status restriction.
       08 May 99        G Perry    115.17     Changed PLIP Cursor so it checks
                                              for PLIP first and if there are
                                              no PLIP's of type 'STD' then
                                              it switches to PL or if there are
                                              no PLIP rates. LM speced change.
       18 Jun 99        maagrawa   115.18     Override Oipl level rates, when
                                              oiplip rates are available.
                                              Override Plan rates when plip
                                              rates are present.
       20-JUL-99        Gperry     115.19     genutils -> benutils package
                                              rename.
       22-JUL-99        mhoyes     115.20   - Added new trace messages
       07-SEP-99        shdas      115.21     Added codes for cmbn ptip opt .
       02-Oct-99        lmcdonal   115.22     was loading annual-min into annual-
                                              max field.  fixed it.
       15-Nov-99        mhoyes     115.23   - Added trace messages.
       09-Mar-00        lmcdonal   115.24     Add handling of new comp-lvl-cds
                                              for flex credit choices.  Restructured
                                              main.
       21-Mar-00        mhoyes     115.25   - Fixed batch rate info problem caused
                                              by not setting g_rec.person_id before
                                              calling ben_rates from the sub
                                              electable choice loop.
       30-Mar-00        mmogel     115.26   - Added tokens to messages to more
                                              clearly identify the source of the
                                              problem from the message text
       03-May-00        mhoyes     115.27   - Tuned c_epe. Removed
                                              nvl on p_elig_per_elctbl_chc_id and
                                              request_id restriction.
       12-May-00        mhoyes     115.28   - Added profiling trace messages.
       15-May-00        mhoyes     115.29   - Called performance API.
       29-May-00        mhoyes     115.30   - Added EPE context record.
                                            - Passed around record structures.
       31-May-00        mhoyes     115.31   - Removed nvls from SQL.
       28-Jun-00        mhoyes     115.32   - Moved eligibility cursor outside of
                                              abr loop.
                                            - Referenced elig per cache rather than
                                              sql.
       03-Aug-00        mhoyes     115.34   - Bulk bind of ben_enrt_rt.
       08-Sep-00        kmahendr   115.35   - added more attributes to cursors-plan not in
                                              programs - www#1186195- Variable rate profiles
                                              overriden
       22-Sep-00        mhoyes     115.36   - Added calls clear down ATP and PTA function
                                              caches.
       07-Nov-00        mhoyes     115.37   - Added electable choice context global.
       05-Jan-01        kmahendr   115.38   - Added parameter per_in_ler_id for unrestricted
       02-Aug-01        ikasire    115.39     Bug1895846 added exclusion condition for
                                              suspended enrollment results
       02-Aug-01        ikasre     115.40     added modification history for 115.39
       28-Aug-01        kmahendr   115.41     bug#1936976-for coverage ranze code
                                              prtt_rt_val_id is populated based on
                                              benefit amount
       19-dec-01        pbodla     115.42     CWB Changes - ben_old_retes only
                                              looks at non comp per in ler's
       20-dec-01        ikasire    115.43     added dbdrv lines
       22-feb-02        pbodla     115.44     Bug 2234582 : Some times null
                                              second parameter is giving error.
                                              Explicit second parameter is passed
                                              to hr_utility. set_location
       15-may-02        ikasire    115.45     Bug 2200139 added a new parameter
                                              p_elig_per_elctbl_chc_id to the main
                                              procedure to called from override
                                              process.For other processes it is
                                              always passed as null .
       23-May-02        kmahendr   115.46     Added a parameter to ben_determine_acty_base_rt
       10-jun-02        pabodla    115.47     LGE : Create rate certifications
       28-Sep-02        ikasire    115.49     reverted the changes made in 115.48
       11-Oct-02        vsethi     115.50     Rates Sequence no enhancements. Modified to cater
       					      to new column ord_num on ben_acty_base_rt_f
       28-Oct-02        kmahendr   115.51     Land O Lakes performance fix - cursor c_enrt_rt
                                              split into two.
       26-Dec-02        rpillay    115.52     NOCOPY changes
       13-feb-02        vsethi     115.53     Enclosed all hr_utility debug calls inside if
       13-feb-02        kmahendr   115.54     Added a parameter to call -acty_base_rt.main
       15-Apr-02        tjesumic   115.55     # 2897152 When the  Std. Rate Calc Method code
                                              is No Standard Values Used' NSVU and all vapro
                                              attached to the rate are failed then  no rate
                                              will be created for the std rate.
                                              This is fixed by  deleting all the enrt_rt for
                                              the above condition
       08-May-03        ikasire    115.56     Option Level rates enhancements.
       16-Sep-03        kmahendr   115.57     GSP changes
       17-Dec-03        vvprabhu   115.58     Added the assignment for g_debug at the start of
                                              each public procedure
       14-Jan-03        bmanyam    115.59     Bug: 3234092: GSP Changes. Enabling
                                              calculation of 'Salary Caclculation Rule'
                                              instead of Activity Rates, in GSP mode.
       14-Jan-03        pbodla     115.60,61  GLOBALCWB : Added code to  populate
       06-Feb-04        pbodla     115.62     GLOBALCWB : Added code to  populate
                                              WS_RT_START_DAT in ben_cwb_person_rates
       25-Feb-04        pbodla     115.63     GLOBALCWB : Even if rates are not
                                              defined still populate the cwb
                                              tables - person_groups and
                                              person_rates.
       14-Apr-04        mmudigon   115.64     FONM changes
       21-May-04        pbodla     115.65     FONM changes continued
                        mmudigon
       24-May-04        nhunur     115.66     3633345 - changed cursor c_enrt_ctfn_rt.
       16-Jun-04        mmudigon   115.68     same as version 115.66. Incorrect
                                              arcs in version 115.67
       03-sep-04        nhunur     115.69     3274902 : Changed code to populate cmcd_dflt_val
       03-sep-04        nhunur     115.70     3234092 : Added code to get rt_strt_dt for GSP
       17-sep-04        nhunur     115.71     iRec : c_per_in_ler modified not to look
                                              at gsp/irec/abs/comp type of events.
       15-Nov-04        kmahendr   115.73     Unrest. enh changes
       18-Jan-05        kmahendr   115.74     Bug#4126093 - added check before creating
                                              enrollment rate certificate
       10-Mar-05        abparekh   115.75     Bug 4230502 : Populate L_ENRT_RT_ID_TAB
                                              with created / updated ECR PK Ids
       30-mar-05        nhunur     115.76     GSP change to ensure ff contexts are correctly passed.
       26-Jul-05        nhunur     115.77     assign the FONM CVG date before calling rate calcaultion
       08-Nov-05        pbodla     115.78     Bug 4693040 : When a rate is defined as nsvu
                                              in cwb mode no need to delete the enrt_rt row
                                              as it is not created at all, also rate
                                              certifications not relevant for CWB rates.
       25-Jan-05        swjain     115.79     Absences Enhancement: Added order by abr_seq_num
                                              in all the abr cursors in procedure main
       21-feb-06        pbodla     115.80     CWB : added multi currency support code.
       24-feb-06        pbodla     115.81     CWB : fixed data type for
                                              l_currency_cd
       21-Apr-06        ikasired   115.82     CWB : 5148387 handling for benefit assignment
       22-Feb-08	rtagarra   115.83     Bug 6840074
       17-Jun-08        sagnanas   116.84     Bug 7154229
       27-Apr-09        sallumwa   115.85     Bug 8394662 : Passed acty_base_rt_id while determining
                                              the rate and coverage dates.
*/
----------------------------------------------------------------------------------------------
  g_package VARCHAR2(80)              := 'ben_determine_rates';
  g_rec     benutils.g_batch_rate_rec;
  --
  g_debug boolean := hr_utility.debug_enabled;
  --
  TYPE g_acty_base_rt_id_table IS TABLE OF ben_acty_base_rt_f.acty_base_rt_id%TYPE
    INDEX BY BINARY_INTEGER;
  TYPE g_asn_on_enrt_flag_table IS TABLE OF ben_acty_base_rt_f.asn_on_enrt_flag%TYPE
    INDEX BY BINARY_INTEGER;
--
-- ----------------------------------------------------------------------------
-- |------< ben_rates_old >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to get the old rate/coverage amount for batch information
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   p_person_id  Person's primary key value
--   p_elig_per_elctble_chc_id
--   p_enrt_bnft_id
--   p_acty_base_rt_id
--
-- Out Parameters
-- p_old_val To assign old rate/coverage amount
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Error handled by procedure
--
-- Access Status
--   Internal use only.
--
  PROCEDURE ben_rates_old(
    p_elig_per_elctbl_chc_id IN     NUMBER,
    p_enrt_bnft_id           IN     NUMBER,
    p_acty_base_rt_id        IN     NUMBER,
    p_effective_date         IN     DATE,
    p_person_id              IN     NUMBER,
    p_lf_evt_ocrd_dt         IN     DATE,
    p_pgm_id                 IN     NUMBER,
    p_pl_id                  IN     NUMBER,
    p_oipl_id                IN     NUMBER,
    p_old_val                OUT NOCOPY    NUMBER) IS
    --
    CURSOR c_rate(
      l_elctbl_chc_id NUMBER) IS
      SELECT   b.val
      FROM     ben_enrt_rt b
      WHERE    b.acty_base_rt_id = p_acty_base_rt_id
      AND      b.elig_per_elctbl_chc_id = l_elctbl_chc_id;
    CURSOR c_elig_per_elctbl_chc(
      l_per_in_ler NUMBER) IS
      SELECT   b.elig_per_elctbl_chc_id
      FROM     ben_elig_per_elctbl_chc b
      WHERE    b.per_in_ler_id = l_per_in_ler
      AND      (   b.pgm_id = p_pgm_id
                OR pgm_id IS NULL)
      AND      (   b.pl_id = p_pl_id
                OR pl_id IS NULL)
      AND      (   b.oipl_id = p_oipl_id
                OR p_oipl_id IS NULL);
    l_val           ben_batch_rate_info.old_val%TYPE := 0;
    --
    -- CWB Chnages and GSP changes:
    --
    CURSOR c_per_in_ler IS
      SELECT   pil.per_in_ler_id
      FROM     ben_per_in_ler pil,
               ben_ler_f      ler
      WHERE    pil.person_id  = p_person_id
      and      pil.ler_id = ler.ler_id
      and      ler.typ_cd not in ('COMP','GSP', 'IREC', 'ABS')
      and      pil.per_in_ler_stat_cd not in ('VOIDD', 'BCKDT')
      AND      lf_evt_ocrd_dt =
               (SELECT   MAX(b.lf_evt_ocrd_dt)
                FROM     ben_per_in_ler b,
                         ben_ler_f      ler1
                WHERE    b.person_id = p_person_id
                and      b.ler_id    = ler1.ler_id
                and      b.per_in_ler_stat_cd not in ('VOIDD', 'BCKDT')
                and      ler1.typ_cd not in ('COMP','GSP', 'IREC', 'ABS')
                AND      b.lf_evt_ocrd_dt < p_lf_evt_ocrd_dt);
    --
    l_per_in_ler    NUMBER;
    l_elctbl_chc_id NUMBER;
  BEGIN
    --
    if g_debug then
      hr_utility.set_location('Inside procedure Old Rate  ', 0000);
      hr_utility.set_location('elig per elctbl chc id  ' || p_elig_per_elctbl_chc_id,0000);
      hr_utility.set_location('acty base rate id  ' || p_acty_base_rt_id, 0000);
    end if;
    OPEN c_per_in_ler;
    FETCH c_per_in_ler INTO l_per_in_ler;
    CLOSE c_per_in_ler;
    IF l_per_in_ler IS NOT NULL THEN
      OPEN c_elig_per_elctbl_chc(l_per_in_ler);
      FETCH c_elig_per_elctbl_chc INTO l_elctbl_chc_id;
      CLOSE c_elig_per_elctbl_chc;
    END IF;
    IF l_elctbl_chc_id IS NOT NULL THEN
      OPEN c_rate(l_elctbl_chc_id);
      FETCH c_rate INTO l_val;
      CLOSE c_rate;
    END IF;
    IF l_val > 0 THEN
      p_old_val  := l_val;
    END IF;
  END ben_rates_old;
  --
  PROCEDURE ben_rates(
    p_currepe_row            IN ben_epe_cache.g_pilepe_inst_row,
    p_per_row                IN per_all_people_f%ROWTYPE,
    p_asg_row                IN per_all_assignments_f%ROWTYPE,
    p_ast_row                IN per_assignment_status_types%ROWTYPE,
    p_adr_row                IN per_addresses%ROWTYPE,
    p_person_id              IN NUMBER,
    p_pgm_id                 IN NUMBER,
    p_pl_id                  IN NUMBER,
    p_oipl_id                IN NUMBER,
    p_elig_per_elctbl_chc_id IN NUMBER,
    p_enrt_bnft_id           IN NUMBER,
    p_acty_base_rt_id_table  IN Out nocopy  ben_determine_rates.g_acty_base_rt_id_table,
    p_asn_on_enrt_flag_table IN ben_determine_rates.g_asn_on_enrt_flag_table,
    p_effective_date         IN DATE,
    p_lf_evt_ocrd_dt         IN DATE,
    p_perform_rounding_flg   IN BOOLEAN,
    p_business_group_id      IN NUMBER,
    p_dflt_flag              IN VARCHAR2,
    p_ctfn_rqd_flag          IN VARCHAR2,
    p_mode                   in varchar2) IS
    --
    l_package                     VARCHAR2(80)      := g_package ||
                                                         '.ben_rates';
    --
    l_currepe_row                 ben_determine_rates.g_curr_epe_rec;
    --
    l_elig_per_elctbl_chc_id1     NUMBER;
    --
    l_created_by                  ben_enrt_rt.created_by%TYPE;
    l_creation_date               ben_enrt_rt.creation_date%TYPE;
    l_last_update_date            ben_enrt_rt.last_update_date%TYPE;
    l_last_updated_by             ben_enrt_rt.last_updated_by%TYPE;
    l_last_update_login           ben_enrt_rt.last_update_login%TYPE;
    l_request_id                  ben_enrt_rt.request_id%TYPE
                                                  := fnd_global.conc_request_id;
    l_program_application_id      ben_enrt_rt.program_application_id%TYPE
                                                     := fnd_global.prog_appl_id;
    l_program_id                  ben_enrt_rt.program_id%TYPE
                                                  := fnd_global.conc_program_id;
    l_program_update_date         ben_enrt_rt.program_update_date%TYPE
                                                                     := SYSDATE;
    l_object_version_number       ben_enrt_rt.object_version_number%TYPE  := 1;
    l_no                          VARCHAR2(1)                             := 'N';
    -- the null variables are used to ensure the INSERT statement contains bind
    -- parameters and increases shareability
    l_varchar2_null               VARCHAR2(1);     -- automatically set to NULL
    l_number_null                 NUMBER(1);       -- automatically set to NULL
    --
    TYPE l_number_15_table_type IS TABLE OF NUMBER(15)
      INDEX BY BINARY_INTEGER;
    TYPE l_number_15_2_table_type IS TABLE OF NUMBER(15, 2)
      INDEX BY BINARY_INTEGER;
    TYPE l_number_table_type IS TABLE OF NUMBER
      INDEX BY BINARY_INTEGER;
    TYPE l_varchar2_30_table_type IS TABLE OF VARCHAR2(30)
      INDEX BY BINARY_INTEGER;
    TYPE l_date_table_type IS TABLE OF DATE
      INDEX BY BINARY_INTEGER;
    --
    cursor c_prtt_enrt_rslt (c_prtt_enrt_rslt_id number) is
      select null
      from ben_prtt_enrt_rslt_f pen,
           ben_enrt_bnft enb
      where pen.prtt_enrt_rslt_id = c_prtt_enrt_rslt_id
      and   pen.bnft_ordr_num  = enb.ordr_num
      and   enb.enrt_bnft_id   = p_enrt_bnft_id
      and   pen.prtt_enrt_rslt_stat_cd is null
      and   p_effective_date between
            pen.effective_start_date and pen.effective_end_date;
    --
    l_val                         l_number_table_type;
    l_mn_elcn_val                 l_number_table_type;
    l_mx_elcn_val                 l_number_table_type;
    l_ann_val                     l_number_table_type;
    l_ann_mn_elcn_val             l_number_table_type;
    l_ann_mx_elcn_val             l_number_table_type;
    l_cmcd_val                    l_number_table_type;
    l_cmcd_mn_elcn_val            l_number_table_type;
    l_cmcd_mx_elcn_val            l_number_table_type;
    l_cmcd_acty_ref_perd_cd       l_varchar2_30_table_type;
    l_incrmt_elcn_val             l_number_table_type;
    l_dflt_val                    l_number_table_type;
    l_tx_typ_cd                   l_varchar2_30_table_type;
    l_acty_typ_cd                 l_varchar2_30_table_type;
    l_nnmntry_uom                 l_varchar2_30_table_type;
    l_entr_val_at_enrt_flag       l_varchar2_30_table_type;
    l_dsply_on_enrt_flag          l_varchar2_30_table_type;
    l_use_to_calc_net_flx_cr_flag l_varchar2_30_table_type;
    l_rt_usg_cd                   l_varchar2_30_table_type;
    l_decr_bnft_prvdr_pool_id     l_number_15_table_type;
    l_actl_prem_id                l_number_15_table_type;
    l_cvg_amt_calc_mthd_id        l_number_15_table_type;
    l_bnft_rt_typ_cd              l_varchar2_30_table_type;
    l_rt_typ_cd                   l_varchar2_30_table_type;
    l_rt_mlt_cd                   l_varchar2_30_table_type;
    l_comp_lvl_fctr_id            l_number_15_table_type;
    l_entr_ann_val_flag           l_varchar2_30_table_type;
    l_ptd_comp_lvl_fctr_id        l_number_15_table_type;
    l_clm_comp_lvl_fctr_id        l_number_15_table_type;
    l_ann_dflt_val                l_number_15_2_table_type;
    l_rt_strt_dt                  l_date_table_type;
    l_rt_strt_dt_cd               l_varchar2_30_table_type;
    l_rt_strt_dt_rl               l_number_15_table_type;
    l_prtt_rt_val_id              l_number_15_table_type;
    l_dsply_mn_elcn_val           l_number_15_2_table_type;
    l_dsply_mx_elcn_val           l_number_15_2_table_type;
    l_pp_in_yr_used_num           l_number_15_table_type;
    l_ordr_num			  l_number_15_table_type;
    l_iss_val                     l_number_table_type;
    l_enrt_rt_id_tab              l_number_15_table_type;    -- 2897152

    --
    l_enrt_rt_id                  ben_enrt_rt.enrt_rt_id%type;
    l_enrt_rt_ctfn_id             ben_enrt_rt_ctfn.enrt_rt_ctfn_id%type;
    l_old_val                     NUMBER;
    l_dummy                       varchar2(1);
    --
    cursor c_enrt_rt_id is
    select ben_enrt_rt_s.nextval
    from sys.dual;
    --
  /*  cursor c_enrt_ctfn(p_acty_base_rt_id number,
                       p_elig_per_elctbl_chc_id number) is
      select ecr.enrt_rt_id,
             abc.enrt_ctfn_typ_cd,
             abc.rqd_flag
      from   ben_enrt_rt          ecr,
             ben_enrt_bnft        enb,
             BEN_ACTY_BASE_RT_CTFN_F abc
      where  ecr.acty_base_rt_id = p_acty_base_rt_id
      and    ecr.business_group_id = p_business_group_id
      and    decode(ecr.enrt_bnft_id, null, ecr.elig_per_elctbl_chc_id,
                    enb.elig_per_elctbl_chc_id) =
             p_elig_per_elctbl_chc_id
      and    enb.enrt_bnft_id (+) = ecr.enrt_bnft_id
      and    abc.acty_base_rt_id  = ecr.acty_base_rt_id;
  */
   cursor c_enrt_ctfn_rt(p_acty_base_rt_id number,
                         p_elig_per_elctbl_chc_id number) is
      select ecr.enrt_rt_id,
             abc.enrt_ctfn_typ_cd,
             abc.rqd_flag
      from   ben_enrt_rt          ecr,
             BEN_ACTY_BASE_RT_CTFN_F abc
      where  ecr.acty_base_rt_id = p_acty_base_rt_id
      and    ecr.business_group_id = p_business_group_id
      and    ecr.elig_per_elctbl_chc_id = p_elig_per_elctbl_chc_id
      and    abc.acty_base_rt_id  = ecr.acty_base_rt_id+0;
  --
   --
   cursor c_enrt_ctfn_bnft(p_acty_base_rt_id number,
                       p_elig_per_elctbl_chc_id number) is
      select ecr.enrt_rt_id,
             abc.enrt_ctfn_typ_cd,
             abc.rqd_flag
      from   ben_enrt_rt          ecr,
             ben_enrt_bnft        enb,
             BEN_ACTY_BASE_RT_CTFN_F abc
      where  ecr.acty_base_rt_id = p_acty_base_rt_id
      and    ecr.business_group_id = p_business_group_id
      and    enb.elig_per_elctbl_chc_id = p_elig_per_elctbl_chc_id
      and    enb.enrt_bnft_id  = ecr.enrt_bnft_id
      and    abc.acty_base_rt_id  = ecr.acty_base_rt_id;

  --
  cursor c_enrt_ctfn_exists (p_enrt_rt_id number,
                             p_enrt_ctfn_typ_cd varchar2) is
    select null
    from ben_enrt_rt_ctfn erc
    where erc.enrt_rt_id = p_enrt_rt_id
    and   erc.enrt_ctfn_typ_cd = p_enrt_ctfn_typ_cd;
 --
  -- 2897152
    TYPE l_numlist is table of number(2) index by BINARY_INTEGER ;
    l_nsuv_lst  l_numlist ;
    l_nsuv_num  integer ;
    -- Bug: 3234092 Changes begin **********************************************
    cursor c_pgm is
        SELECT pgm.pgm_typ_cd, pgm.salary_calc_mthd_cd, pgm.salary_calc_mthd_rl
        FROM ben_pgm_f pgm
        where pgm.pgm_id = p_pgm_id
        and p_effective_date between pgm.effective_start_date and pgm.effective_end_date;


        cursor c_abr(p_acty_base_rt_id NUMBER) is
        select abr.acty_typ_cd,
                        abr.tx_typ_cd,
                        abr.dsply_on_enrt_flag,
                        abr.use_to_calc_net_flx_cr_flag,
                        abr.entr_val_at_enrt_flag,
                        abr.entr_ann_val_flag,
                        abr.currency_det_cd,
                        abr.element_det_rl,
                        abr.element_type_id
        from ben_acty_base_rt_f abr
        where abr.acty_base_rt_id = p_acty_base_rt_id
        and p_effective_date between abr.effective_start_date and abr.effective_end_date;

    l_env               ben_env_object.g_global_env_rec_type;
    l_mode                              l_env.mode_cd%TYPE;
    l_pgm_rec                   c_pgm%ROWTYPE;
    l_abr                               c_abr%ROWTYPE;
    l_eval_sal_rule     boolean := FALSE;
    l_rate_outputs      ff_exec.outputs_t;
    l_jurisdiction              VARCHAR2(30);
    -- l_assignment_id     NUMBER;
    -- l_organization_id   NUMBER;
    -- Bug: 3234092 Changes end  **********************************************
    l_cmcd_dflt_val number ;
    l_currency_det_cd      varchar2(30);
    l_element_det_rl       number;
    l_base_element_type_id number;
    l_cwb_acty_base_rt_id  number;
    --
    l_asg_benass_row       per_all_assignments_f%ROWTYPE;
    --
  BEGIN
    --
    l_currepe_row.elig_per_elctbl_chc_id := p_currepe_row.elig_per_elctbl_chc_id;
    l_currepe_row.business_group_id      := p_currepe_row.business_group_id;
    l_currepe_row.person_id              := p_currepe_row.person_id;
    l_currepe_row.ler_id                 := p_currepe_row.ler_id;
    l_currepe_row.per_in_ler_id          := p_currepe_row.per_in_ler_id;
    l_currepe_row.pgm_id                 := p_currepe_row.pgm_id;
    l_currepe_row.pl_typ_id              := p_currepe_row.pl_typ_id;
    l_currepe_row.ptip_id                := p_currepe_row.ptip_id;
    l_currepe_row.plip_id                := p_currepe_row.plip_id;
    l_currepe_row.pl_id                  := p_currepe_row.pl_id;
    l_currepe_row.oipl_id                := p_currepe_row.oipl_id;
    l_currepe_row.oiplip_id              := p_currepe_row.oiplip_id;
    l_currepe_row.opt_id                 := p_currepe_row.opt_id;
    l_currepe_row.enrt_perd_id           := p_currepe_row.enrt_perd_id;
    l_currepe_row.lee_rsn_id             := p_currepe_row.lee_rsn_id;
    l_currepe_row.enrt_perd_strt_dt      := p_currepe_row.enrt_perd_strt_dt;
    l_currepe_row.prtt_enrt_rslt_id      := p_currepe_row.prtt_enrt_rslt_id;
    l_currepe_row.prtn_strt_dt           := p_currepe_row.prtn_strt_dt;
    l_currepe_row.enrt_cvg_strt_dt       := p_currepe_row.enrt_cvg_strt_dt;
    l_currepe_row.enrt_cvg_strt_dt_cd    := p_currepe_row.enrt_cvg_strt_dt_cd;
    l_currepe_row.enrt_cvg_strt_dt_rl    := p_currepe_row.enrt_cvg_strt_dt_rl;
    l_currepe_row.yr_perd_id             := p_currepe_row.yr_perd_id;
    l_currepe_row.prtn_ovridn_flag       := p_currepe_row.prtn_ovridn_flag;
    l_currepe_row.prtn_ovridn_thru_dt    := p_currepe_row.prtn_ovridn_thru_dt;
    l_currepe_row.rt_age_val             := p_currepe_row.rt_age_val;
    l_currepe_row.rt_los_val             := p_currepe_row.rt_los_val;
    l_currepe_row.rt_hrs_wkd_val         := p_currepe_row.rt_hrs_wkd_val;
    l_currepe_row.rt_cmbn_age_n_los_val  := p_currepe_row.rt_cmbn_age_n_los_val;
    --
    l_nsuv_num := 1 ;
    --
    if nvl(p_mode, 'X') = 'W' then
       --
       ben_manage_cwb_life_events.g_cwb_person_groups_rec    := ben_manage_cwb_life_events.g_cwb_person_groups_rec_temp;
       ben_manage_cwb_life_events.g_cwb_person_rates_rec     := ben_manage_cwb_life_events.g_cwb_person_rates_rec_temp;
       --
    end if;
    --
    FOR i IN p_acty_base_rt_id_table.FIRST .. p_acty_base_rt_id_table.LAST LOOP
      if g_debug then
        hr_utility.set_location('Entering ' || l_package, 10);
      end if;
      --

    -- Bug: 3234092 Changes begin  **********************************************
      l_eval_sal_rule := false;
      ben_env_object.get(p_rec => l_env);
      --
	  if g_debug then
        hr_utility.set_location(' ben_env_object: Mode ' || l_env.mode_cd, 10);
      end if;
      --
      -- If mode='G' (gsp) and pgm_typ_cd for the pgm-record is 'GSP'
      -- and formula is defined at pgm-level
      -- then evaluate the formula instead of rates
      -- variable l_eval_sal_rule tells whether to evaluate rule (or the rates).
       if ((l_env.mode_cd IS NOT NULL) AND (l_env.mode_cd = 'G')) then
       	open c_pgm;
       	  fetch c_pgm INTO l_pgm_rec;
       	  --
		  if g_debug then
                     hr_utility.set_location('l_pgm_rec.pgm_typ_cd ' || l_pgm_rec.pgm_typ_cd, 20);
                     hr_utility.set_location('l_pgm_rec.salary_calc_mthd_cd ' || l_pgm_rec.salary_calc_mthd_cd, 20);
                     hr_utility.set_location('l_pgm_rec.salary_calc_mthd_rl ' || l_pgm_rec.salary_calc_mthd_rl, 20);
		  end if;
		  --
		  if (c_pgm%FOUND) THEN
			if (l_pgm_rec.pgm_typ_cd = 'GSP' and l_pgm_rec.salary_calc_mthd_cd = 'RULE'
				and l_pgm_rec.salary_calc_mthd_rl IS NOT NULL) then
				l_eval_sal_rule := true;
			end if;
		  end if;
       	close c_pgm;
      end if;
      --
      if (l_eval_sal_rule) THEN

      ben_determine_activity_base_rt.main(
        p_currepe_row                 => l_currepe_row,
        p_per_row                     => p_per_row,
        p_asg_row                     => p_asg_row,
        p_ast_row                     => p_ast_row,
        p_adr_row                     => p_adr_row,
        p_person_id                   => p_person_id,
        p_elig_per_elctbl_chc_id      => p_elig_per_elctbl_chc_id,
        p_enrt_bnft_id                => p_enrt_bnft_id,
        p_acty_base_rt_id             => p_acty_base_rt_id_table(i),
        p_effective_date              => p_effective_date,
        p_lf_evt_ocrd_dt              => p_lf_evt_ocrd_dt,
        p_perform_rounding_flg        => TRUE,
        p_val                         => l_val(i),
        p_mn_elcn_val                 => l_mn_elcn_val(i),
        p_mx_elcn_val                 => l_mx_elcn_val(i),
        p_ann_val                     => l_ann_val(i),
        p_ann_mn_elcn_val             => l_ann_mn_elcn_val(i),
        p_ann_mx_elcn_val             => l_ann_mx_elcn_val(i),
        p_cmcd_val                    => l_cmcd_val(i),
        p_cmcd_mn_elcn_val            => l_cmcd_mn_elcn_val(i),
        p_cmcd_mx_elcn_val            => l_cmcd_mx_elcn_val(i),
        p_cmcd_acty_ref_perd_cd       => l_cmcd_acty_ref_perd_cd(i),
        p_incrmt_elcn_val             => l_incrmt_elcn_val(i),
        p_dflt_val                    => l_dflt_val(i),
        p_tx_typ_cd                   => l_tx_typ_cd(i),
        p_acty_typ_cd                 => l_acty_typ_cd(i),
        p_nnmntry_uom                 => l_nnmntry_uom(i),
        p_entr_val_at_enrt_flag       => l_entr_val_at_enrt_flag(i),
        p_dsply_on_enrt_flag          => l_dsply_on_enrt_flag(i),
        p_use_to_calc_net_flx_cr_flag => l_use_to_calc_net_flx_cr_flag(i),
        p_rt_usg_cd                   => l_rt_usg_cd(i),
        p_bnft_prvdr_pool_id          => l_decr_bnft_prvdr_pool_id(i),
        p_actl_prem_id                => l_actl_prem_id(i),
        p_cvg_calc_amt_mthd_id        => l_cvg_amt_calc_mthd_id(i),
        p_bnft_rt_typ_cd              => l_bnft_rt_typ_cd(i),
        p_rt_typ_cd                   => l_rt_typ_cd(i),
        p_rt_mlt_cd                   => l_rt_mlt_cd(i),
        p_comp_lvl_fctr_id            => l_comp_lvl_fctr_id(i),
        p_entr_ann_val_flag           => l_entr_ann_val_flag(i),
        p_ptd_comp_lvl_fctr_id        => l_ptd_comp_lvl_fctr_id(i),
        p_clm_comp_lvl_fctr_id        => l_clm_comp_lvl_fctr_id(i),
        p_ann_dflt_val                => l_ann_dflt_val(i),
        p_rt_strt_dt                  => l_rt_strt_dt(i),
        p_rt_strt_dt_cd               => l_rt_strt_dt_cd(i),
        p_rt_strt_dt_rl               => l_rt_strt_dt_rl(i),
        p_prtt_rt_val_id              => l_prtt_rt_val_id(i),
        p_dsply_mn_elcn_val           => l_dsply_mn_elcn_val(i),
        p_dsply_mx_elcn_val           => l_dsply_mx_elcn_val(i),
        p_pp_in_yr_used_num           => l_pp_in_yr_used_num(i),
        p_ordr_num           	      => l_ordr_num(i),
        p_iss_val                     => l_iss_val(i));

        -- GSP issue raised by hallmark cards 30/3/05
        -- contexts are passed using in parameters now instead of local variable
        --
        hr_utility.set_location(' p_asg_row.assignment_id ' || p_asg_row.assignment_id, 20);
        hr_utility.set_location(' p_asg_row.organization_id ' || p_asg_row.organization_id, 20);
        --
	l_rate_outputs := benutils.formula
			 (p_formula_id        => l_pgm_rec.salary_calc_mthd_rl,
			  p_effective_date    => p_effective_date,
			  p_assignment_id     => p_asg_row.assignment_id, -- l_assignment_id,
			  p_organization_id   => p_asg_row.organization_id, -- l_organization_id,
			  p_business_group_id => p_business_group_id,
			  p_pgm_id            => p_pgm_id,
			  p_pl_id             => p_pl_id,
			  p_pl_typ_id         => l_currepe_row.pl_typ_id,
			  p_opt_id            => l_currepe_row.opt_id,
			  p_ler_id            => l_currepe_row.ler_id,
			  p_acty_base_rt_id   => p_acty_base_rt_id_table(i),
			  p_elig_per_elctbl_chc_id   => l_currepe_row.elig_per_elctbl_chc_id,
			  p_jurisdiction_code => l_jurisdiction);
		--
		l_val(i) := l_rate_outputs(l_rate_outputs.first).value;
		--
		if g_debug then
			hr_utility.set_location(' val(i) from Formula ' || l_val(i), 20);
		end if;
		--
		-- set all other values to NULL
		l_mn_elcn_val(i) := NULL;
		l_mx_elcn_val(i) := NULL;
		l_ann_val(i) := NULL;
		l_ann_mn_elcn_val(i) := NULL;
		l_ann_mx_elcn_val(i) := NULL;
		l_cmcd_val(i) := NULL;
		l_cmcd_mn_elcn_val(i) := NULL;
		l_cmcd_mx_elcn_val(i) := NULL;
		l_cmcd_acty_ref_perd_cd(i) := NULL;
		l_incrmt_elcn_val(i) := NULL;
		l_dflt_val(i) := NULL;
		l_tx_typ_cd(i) := NULL;
		l_acty_typ_cd(i) := NULL;
		l_nnmntry_uom(i) := NULL;
		l_entr_val_at_enrt_flag(i) := NULL;
		l_dsply_on_enrt_flag(i) := NULL;
		l_use_to_calc_net_flx_cr_flag(i) := NULL;
		l_rt_usg_cd(i) := NULL;
		l_decr_bnft_prvdr_pool_id(i) := NULL;
		l_actl_prem_id(i) := NULL;
		l_cvg_amt_calc_mthd_id(i) := NULL;
		l_bnft_rt_typ_cd(i) := NULL;
		l_rt_typ_cd(i) := NULL;
		l_rt_mlt_cd(i) := NULL;
		l_comp_lvl_fctr_id(i) := NULL;
		l_entr_ann_val_flag(i) := NULL;
		l_ptd_comp_lvl_fctr_id(i) := NULL;
		l_clm_comp_lvl_fctr_id(i) := NULL;
		l_ann_dflt_val(i) := NULL;
                -- GSP needs this date
		-- l_rt_strt_dt(i) := NULL;
		-- l_rt_strt_dt_cd(i) := NULL;
		-- l_rt_strt_dt_rl(i) := NULL;
		l_prtt_rt_val_id(i) := NULL;
		l_dsply_mn_elcn_val(i) := NULL;
		l_dsply_mx_elcn_val(i) := NULL;
		l_pp_in_yr_used_num(i) := NULL;
		l_ordr_num(i) := NULL;
		l_iss_val(i) := NULL;
		--
		-- Fetch acty_typ_cd and other not-null values
		-- from ben_acty_base_rt_f table.
	   open c_abr(p_acty_base_rt_id_table(i));
	   fetch c_abr into l_abr;
		   if c_abr%FOUND then
				l_acty_typ_cd(i)					:= l_abr.acty_typ_cd;
				l_tx_typ_cd(i)						:= l_abr.tx_typ_cd;
				l_dsply_on_enrt_flag(i)				:= l_abr.dsply_on_enrt_flag;
				l_use_to_calc_net_flx_cr_flag(i)	:= l_abr.use_to_calc_net_flx_cr_flag;
				l_entr_val_at_enrt_flag(i)			:= l_abr.entr_val_at_enrt_flag;
				l_entr_ann_val_flag(i)				:= l_abr.entr_ann_val_flag;
		   end if;
	   close c_abr;
	   --
		if g_debug then
			hr_utility.set_location(' l_acty_typ_cd ' || l_acty_typ_cd(i), 20);
		end if;
	ELSE
		  -- In all other cases evaluate rates, the usual way
		if g_debug then
			hr_utility.set_location(' calculate rate the usual way ' , 20);
		end if;
		--
		-- Bug: 3234092 Changes end **********************************************
      ben_determine_activity_base_rt.main(
        p_currepe_row                 => l_currepe_row,
        p_per_row                     => p_per_row,
        p_asg_row                     => p_asg_row,
        p_ast_row                     => p_ast_row,
        p_adr_row                     => p_adr_row,
        p_person_id                   => p_person_id,
        p_elig_per_elctbl_chc_id      => p_elig_per_elctbl_chc_id,
        p_enrt_bnft_id                => p_enrt_bnft_id,
        p_acty_base_rt_id             => p_acty_base_rt_id_table(i),
        p_effective_date              => p_effective_date,
        p_lf_evt_ocrd_dt              => p_lf_evt_ocrd_dt,
        p_perform_rounding_flg        => TRUE,
        p_val                         => l_val(i),
        p_mn_elcn_val                 => l_mn_elcn_val(i),
        p_mx_elcn_val                 => l_mx_elcn_val(i),
        p_ann_val                     => l_ann_val(i),
        p_ann_mn_elcn_val             => l_ann_mn_elcn_val(i),
        p_ann_mx_elcn_val             => l_ann_mx_elcn_val(i),
        p_cmcd_val                    => l_cmcd_val(i),
        p_cmcd_mn_elcn_val            => l_cmcd_mn_elcn_val(i),
        p_cmcd_mx_elcn_val            => l_cmcd_mx_elcn_val(i),
        p_cmcd_acty_ref_perd_cd       => l_cmcd_acty_ref_perd_cd(i),
        p_incrmt_elcn_val             => l_incrmt_elcn_val(i),
        p_dflt_val                    => l_dflt_val(i),
        p_tx_typ_cd                   => l_tx_typ_cd(i),
        p_acty_typ_cd                 => l_acty_typ_cd(i),
        p_nnmntry_uom                 => l_nnmntry_uom(i),
        p_entr_val_at_enrt_flag       => l_entr_val_at_enrt_flag(i),
        p_dsply_on_enrt_flag          => l_dsply_on_enrt_flag(i),
        p_use_to_calc_net_flx_cr_flag => l_use_to_calc_net_flx_cr_flag(i),
        p_rt_usg_cd                   => l_rt_usg_cd(i),
        p_bnft_prvdr_pool_id          => l_decr_bnft_prvdr_pool_id(i),
        p_actl_prem_id                => l_actl_prem_id(i),
        p_cvg_calc_amt_mthd_id        => l_cvg_amt_calc_mthd_id(i),
        p_bnft_rt_typ_cd              => l_bnft_rt_typ_cd(i),
        p_rt_typ_cd                   => l_rt_typ_cd(i),
        p_rt_mlt_cd                   => l_rt_mlt_cd(i),
        p_comp_lvl_fctr_id            => l_comp_lvl_fctr_id(i),
        p_entr_ann_val_flag           => l_entr_ann_val_flag(i),
        p_ptd_comp_lvl_fctr_id        => l_ptd_comp_lvl_fctr_id(i),
        p_clm_comp_lvl_fctr_id        => l_clm_comp_lvl_fctr_id(i),
        p_ann_dflt_val                => l_ann_dflt_val(i),
        p_rt_strt_dt                  => l_rt_strt_dt(i),
        p_rt_strt_dt_cd               => l_rt_strt_dt_cd(i),
        p_rt_strt_dt_rl               => l_rt_strt_dt_rl(i),
        p_prtt_rt_val_id              => l_prtt_rt_val_id(i),
        p_dsply_mn_elcn_val           => l_dsply_mn_elcn_val(i),
        p_dsply_mx_elcn_val           => l_dsply_mx_elcn_val(i),
        p_pp_in_yr_used_num           => l_pp_in_yr_used_num(i),
        p_ordr_num           	      => l_ordr_num(i),
        p_iss_val                     => l_iss_val(i));
         END IF;
      --
      -- As p_iss_val is only used by CWB and no other mode, we have overloaded it to return
      -- cmcd_dflt_val for which we need not add a new out param in actbr and change all dependencies.
      --
      if nvl(p_mode, 'X') =  'W' then
         l_cmcd_dflt_val := null ;
      else
         l_cmcd_dflt_val := l_iss_val(i) ;
         l_iss_val(i) := null ;
      end if;
      --
      -- GLOBALCWB : If plan is group plan and mode is CWB then populate
      -- CWB rate structures.
      --
      if nvl(p_mode, 'X') =  'W' then
         --
         if l_acty_typ_cd(i) = 'CWBDB' then -- Distribution Budget values.
          --
          if l_currepe_row.pl_id = ben_manage_cwb_life_events.g_cache_group_plan_rec.group_pl_id then
            --
            -- Populate dist_bdgt_val, dist_bdgt_mn_val, dist_bdgt_mx_val,
            -- dist_bdgt_incr_val, dist_bdgt_iss_val, dist_bdgt_iss_date,
            --
            ben_manage_cwb_life_events.g_cwb_person_groups_rec.dist_bdgt_val :=
                                                     nvl(l_val(i), l_dflt_val(i));
            ben_manage_cwb_life_events.g_cwb_person_groups_rec.dist_bdgt_mn_val := l_mn_elcn_val(i);
            ben_manage_cwb_life_events.g_cwb_person_groups_rec.dist_bdgt_mx_val := l_mx_elcn_val(i);
            ben_manage_cwb_life_events.g_cwb_person_groups_rec.dist_bdgt_incr_val := l_incrmt_elcn_val(i);
            ben_manage_cwb_life_events.g_cwb_person_groups_rec.dist_bdgt_iss_val := l_iss_val(i);
            ben_manage_cwb_life_events.g_cwb_person_groups_rec.dist_bdgt_iss_date := null; -- 9999 What is this val
          else
            --
            -- Populate dist_bdgt_val, dist_bdgt_mn_val, dist_bdgt_mx_val,
            -- dist_bdgt_incr_val, dist_bdgt_iss_val, dist_bdgt_iss_date,
            --
            ben_manage_cwb_life_events.g_cwb_person_rates_rec.copy_dist_bdgt_val :=                                                     nvl(l_val(i), l_dflt_val(i));
            ben_manage_cwb_life_events.g_cwb_person_rates_rec.copy_dist_bdgt_mn_val := l_mn_elcn_val(i);
            ben_manage_cwb_life_events.g_cwb_person_rates_rec.copy_dist_bdgt_mx_val := l_mx_elcn_val(i);
            ben_manage_cwb_life_events.g_cwb_person_rates_rec.copy_dist_bdgt_incr_val := l_incrmt_elcn_val(i);
            ben_manage_cwb_life_events.g_cwb_person_rates_rec.copy_dist_bdgt_iss_val := l_iss_val(i);
            ben_manage_cwb_life_events.g_cwb_person_rates_rec.copy_dist_bdgt_iss_date := null; -- 9999 What is this val
          end if;
          --
         elsif l_acty_typ_cd(i) = 'CWBWB' then -- Worksheet Budget values.
          --
          if l_currepe_row.pl_id = ben_manage_cwb_life_events.g_cache_group_plan_rec.group_pl_id then
            --
            -- Populate ws_bdgt_val, ws_bdgt_mn_val, ws_bdgt_mx_val,
            -- ws_bdgt_incr_val, ws_bdgt_iss_val, ws_bdgt_iss_date,
            --
            ben_manage_cwb_life_events.g_cwb_person_groups_rec.ws_bdgt_val :=
                                                    nvl(l_val(i), l_dflt_val(i));
            ben_manage_cwb_life_events.g_cwb_person_groups_rec.ws_bdgt_mn_val := l_mn_elcn_val(i);
            ben_manage_cwb_life_events.g_cwb_person_groups_rec.ws_bdgt_mx_val := l_mx_elcn_val(i);
            ben_manage_cwb_life_events.g_cwb_person_groups_rec.ws_bdgt_incr_val := l_incrmt_elcn_val(i);
            ben_manage_cwb_life_events.g_cwb_person_groups_rec.ws_bdgt_iss_val := l_iss_val(i);
            ben_manage_cwb_life_events.g_cwb_person_groups_rec.ws_bdgt_iss_date := null; -- 9999 What is this val
            --
          else
            --
            -- Populate ws_bdgt_val, ws_bdgt_mn_val, ws_bdgt_mx_val,
            -- ws_bdgt_incr_val, ws_bdgt_iss_val, ws_bdgt_iss_date,
            --
            ben_manage_cwb_life_events.g_cwb_person_rates_rec.copy_ws_bdgt_val :=
                                                    nvl(l_val(i), l_dflt_val(i));
            ben_manage_cwb_life_events.g_cwb_person_rates_rec.copy_ws_bdgt_mn_val := l_mn_elcn_val(i);
            ben_manage_cwb_life_events.g_cwb_person_rates_rec.copy_ws_bdgt_mx_val := l_mx_elcn_val(i);
            ben_manage_cwb_life_events.g_cwb_person_rates_rec.copy_ws_bdgt_incr_val := l_incrmt_elcn_val(i);
            ben_manage_cwb_life_events.g_cwb_person_rates_rec.copy_ws_bdgt_iss_val := l_iss_val(i);
            ben_manage_cwb_life_events.g_cwb_person_rates_rec.copy_ws_bdgt_iss_date := null; -- 9999 What is this val
            --
          end if;
          --
         elsif l_acty_typ_cd(i) = 'CWBR' then -- Reserve Budget values.
          --
          if l_currepe_row.pl_id = ben_manage_cwb_life_events.g_cache_group_plan_rec.group_pl_id then
            --
            -- Populate rsrv_val, rsrv_mn_val, rsrv_mx_val, rsrv_incr_val
            --
            ben_manage_cwb_life_events.g_cwb_person_groups_rec.rsrv_val :=
                                                    nvl(l_val(i), l_dflt_val(i));
            ben_manage_cwb_life_events.g_cwb_person_groups_rec.rsrv_mn_val := l_mn_elcn_val(i);
            ben_manage_cwb_life_events.g_cwb_person_groups_rec.rsrv_mx_val := l_mx_elcn_val(i);
            ben_manage_cwb_life_events.g_cwb_person_groups_rec.rsrv_incr_val := l_incrmt_elcn_val(i);
            --
          else
            --
            -- Populate rsrv_val, rsrv_mn_val, rsrv_mx_val, rsrv_incr_val
            --
            ben_manage_cwb_life_events.g_cwb_person_rates_rec.copy_rsrv_val :=
                                                    nvl(l_val(i), l_dflt_val(i));
            ben_manage_cwb_life_events.g_cwb_person_rates_rec.copy_rsrv_mn_val := l_mn_elcn_val(i);
            ben_manage_cwb_life_events.g_cwb_person_rates_rec.copy_rsrv_mx_val := l_mx_elcn_val(i);
            ben_manage_cwb_life_events.g_cwb_person_rates_rec.copy_rsrv_incr_val := l_incrmt_elcn_val(i);
            --
          end if;
          --
         elsif l_acty_typ_cd(i) = 'CWBWS' then -- Worksheet values.
            --
            -- Populate
            -- ws_val
            --  ws_mn_val
            --  ws_mx_val
            --  ws_incr_val
            --
            ben_manage_cwb_life_events.g_cwb_person_rates_rec.WS_RT_START_DATE := l_rt_strt_dt(i);
            ben_manage_cwb_life_events.g_cwb_person_rates_rec.ws_val :=
                                                    nvl(l_val(i), l_dflt_val(i));
            ben_manage_cwb_life_events.g_cwb_person_rates_rec.ws_mn_val := l_mn_elcn_val(i);
            ben_manage_cwb_life_events.g_cwb_person_rates_rec.ws_mx_val := l_mx_elcn_val(i);
            ben_manage_cwb_life_events.g_cwb_person_rates_rec.ws_incr_val := l_incrmt_elcn_val(i);
            --
            -- Multi currency support. Add caching mechanism
            --
            open c_abr(p_acty_base_rt_id_table(i));
            fetch c_abr into l_abr;
            close c_abr;
            l_currency_det_cd    := l_abr.currency_det_cd;
            l_element_det_rl     := l_abr.element_det_rl;
            l_base_element_type_id := l_abr.element_type_id;
            l_cwb_acty_base_rt_id := p_acty_base_rt_id_table(i);
            --
         elsif l_acty_typ_cd(i) = 'CWBES' then -- Worksheet values.
            --
            -- elig_sal_val
            --
            ben_manage_cwb_life_events.g_cwb_person_rates_rec.elig_sal_val := l_val(i);
            --
         elsif l_acty_typ_cd(i) = 'CWBSS' then -- Worksheet values.
            -- stat_sal_val
            --
            ben_manage_cwb_life_events.g_cwb_person_rates_rec.stat_sal_val := l_val(i);
            --
         elsif l_acty_typ_cd(i) = 'CWBOS' then -- Worksheet values.
            --
            -- oth_comp_val
            --
            ben_manage_cwb_life_events.g_cwb_person_rates_rec.oth_comp_val := l_val(i);
            --
         elsif l_acty_typ_cd(i) = 'CWBTC' then -- Worksheet values.
            --
            -- tot_comp_val
            --
            ben_manage_cwb_life_events.g_cwb_person_rates_rec.tot_comp_val := l_val(i);
            --
         elsif l_acty_typ_cd(i) = 'CWBMR1' then -- Worksheet values.
            --
            -- misc1_val
            --
            ben_manage_cwb_life_events.g_cwb_person_rates_rec.misc1_val := l_val(i);
            --
         elsif l_acty_typ_cd(i) = 'CWBMR2' then -- Worksheet values.
            --
            -- misc2_val
            --
            ben_manage_cwb_life_events.g_cwb_person_rates_rec.misc2_val := l_val(i);
            --
         elsif l_acty_typ_cd(i) = 'CWBMR3' then -- Worksheet values.
            --
            -- misc3_val
            --
            ben_manage_cwb_life_events.g_cwb_person_rates_rec.misc3_val := l_val(i);
            --
         elsif l_acty_typ_cd(i) = 'CWBRA' then -- Worksheet values.
            --
            -- rec_val                          number,
            -- rec_mn_val                       number,
            -- rec_mx_val                       number,
            -- rec_incr_val
            --
            ben_manage_cwb_life_events.g_cwb_person_rates_rec.rec_val :=
                                                    nvl(l_val(i), l_dflt_val(i)) ;
            ben_manage_cwb_life_events.g_cwb_person_rates_rec.rec_mn_val := l_mn_elcn_val(i);
            ben_manage_cwb_life_events.g_cwb_person_rates_rec.rec_mx_val := l_mx_elcn_val(i);
            ben_manage_cwb_life_events.g_cwb_person_rates_rec.rec_incr_val := l_incrmt_elcn_val(i);
            --
         end if;
         --
      end if;
      if nvl(p_mode, 'X') not in ('I', 'W', 'G') then -- No need call for CWB
         --
         -- call procedure ben_rates_old to get old value
         --
         if g_debug then
           hr_utility.set_location('ben_rates_old ' || l_package, 10);
         end if;
         ben_rates_old(
           p_elig_per_elctbl_chc_id => p_elig_per_elctbl_chc_id,
           p_enrt_bnft_id           => p_enrt_bnft_id,
           p_acty_base_rt_id        => p_acty_base_rt_id_table(i),
           p_effective_date         => p_effective_date,
           p_person_id              => p_person_id,
           p_lf_evt_ocrd_dt         => p_lf_evt_ocrd_dt,
           p_pgm_id                 => p_pgm_id,
           p_pl_id                  => p_pl_id,
           p_oipl_id                => p_oipl_id,
           p_old_val                => l_old_val);
         if g_debug then
           hr_utility.set_location('Dn ben_rates_old ' || l_package, 10);
         end if;
         --
         -- Bug 2234582 : Some times null second parameter is giving error.
         -- explicit second parameter is passed to hr_utility. set_location
         --
         if g_debug then
           hr_utility.set_location('Old Rate ' || l_old_val, 11);
         end if;
         --
         g_rec.person_id          := p_person_id;
         g_rec.pgm_id             := p_pgm_id;
         g_rec.pl_id              := p_pl_id;
         g_rec.oipl_id            := p_oipl_id;
         g_rec.dflt_flag          := l_no;
         g_rec.business_group_id  := p_business_group_id;
         g_rec.effective_date     := p_effective_date;
         --
         g_rec.bnft_rt_typ_cd     := l_bnft_rt_typ_cd(i);
         g_rec.val                := l_val(i);
         g_rec.old_val            := l_old_val;
         g_rec.tx_typ_cd          := l_tx_typ_cd(i);
         g_rec.acty_typ_cd        := l_acty_typ_cd(i);
         g_rec.mn_elcn_val        := l_mn_elcn_val(i);
         g_rec.mx_elcn_val        := l_mx_elcn_val(i);
         g_rec.incrmt_elcn_val    := l_incrmt_elcn_val(i);
         g_rec.dflt_val           := l_dflt_val(i);
         g_rec.rt_strt_dt         := l_rt_strt_dt(i);

         benutils.write(p_rec => g_rec);

      end if;
      --  2897152 if the dt mlt cd is NSVU and vapro fail
      --- null value add to a pl/sql table so this can be
      --- delted in latter
      if g_debug then
          hr_utility.set_location('mlt_cd ' || l_rt_mlt_cd(i), 10);
          hr_utility.set_location('value ' || l_val(i), 10);
      end if ;

      if l_rt_mlt_cd(i)= 'NSVU' and l_val(i) is null  then
         l_nsuv_lst(l_nsuv_num)  := i ;
         l_nsuv_num := l_nsuv_num + 1 ;
      end if ;

      --
      if g_debug then
         hr_utility.set_location('After write', 000);
      end if;

    END LOOP;

    --
    -- GLOBALCWB : Populate the CWB tables.
    --
    if nvl(p_mode, 'X') = 'W' then
       --
       If p_asg_row.assignment_id IS NULL THEN
         --BUG 5148387 Need to get Benefit Assignment
          ben_person_object.get_benass_object(
            p_person_id        => p_person_id,
            p_rec              => l_asg_benass_row
          );
         --
       END IF;
       -- Handle auto issue of budgets.
       -- For multi currency support added new paramaters.
       --
       ben_manage_cwb_life_events.populate_cwb_rates(
           --
           -- Columns needed for ben_cwb_person_rates
           --
           p_person_id        => p_person_id
          ,p_assignment_id    => NVL(p_asg_row.assignment_id,l_asg_benass_row.assignment_id)
          ,p_organization_id  => NVL(p_asg_row.organization_id,l_asg_benass_row.organization_id)
          ,p_pl_id            => l_currepe_row.pl_id
          ,p_oipl_id          => l_currepe_row.oipl_id
          ,p_opt_id           => l_currepe_row.opt_id
          ,p_ler_id           => l_currepe_row.ler_id
          ,p_business_group_id=> p_business_group_id
          ,p_acty_base_rt_id  => l_cwb_acty_base_rt_id
          ,p_elig_flag        => null -- 9999 it should come from g_curr_epe_rec
          ,p_inelig_rsn_cd    => null -- 9999 it should come from g_curr_epe_rec
          --
          -- Columns needed by BEN_CWB_PERSON_GROUPS
          --
          ,p_due_dt           => null
          ,p_access_cd        => null -- passed inside the poppulate_cwb_rates
          ,p_elig_per_elctbl_chc_id => p_elig_per_elctbl_chc_id
          -- Multi currency support
          ,p_currency_det_cd  => l_currency_det_cd
          ,p_element_det_rl   => l_element_det_rl
          ,p_base_element_type_id   => l_base_element_type_id
       );
       --
    end if;
    --
    if g_debug then
       hr_utility.set_location('l_nsuv_num ' || l_nsuv_num, 10);
       hr_utility.set_location('Done BDABRT_MN ' || l_package, 10);
    end if;

    --
    -- Since enrt_bnft_id and elig_per_elctbl_chc_id are
    -- mutually exclusive
    -- in ben_enrt_rt then nullify chc_id when bnft_id is not null;
    --

    IF p_enrt_bnft_id IS NOT NULL THEN
      l_elig_per_elctbl_chc_id1  := NULL;
      open c_prtt_enrt_rslt(l_currepe_row.prtt_enrt_rslt_id);
      fetch c_prtt_enrt_rslt into l_dummy;
      if c_prtt_enrt_rslt%notfound then
        FOR i IN l_prtt_rt_val_id.FIRST .. l_prtt_rt_val_id.LAST
          loop
            l_prtt_rt_val_id(i) := null;
          end loop;
      end if;
      close c_prtt_enrt_rslt;
    ELSE
      l_elig_per_elctbl_chc_id1  := p_elig_per_elctbl_chc_id;
    END IF;

    --
    if g_debug then
      hr_utility.set_location('Insert ECR: ' || l_package, 5);
    end if;

    --
    -- GLOBALCWB : No need to populate the ben_enrt_rt table.
    --

    if nvl(p_mode, 'X') <> 'W'  then
     --
      if p_mode in ('U','R') then
        --
        FOR i IN p_acty_base_rt_id_table.FIRST .. p_acty_base_rt_id_table.LAST loop
         l_enrt_rt_id := null;
         l_enrt_rt_id := ben_manage_unres_life_events.ecr_exists
                        (l_elig_per_elctbl_chc_id1,
                         p_enrt_bnft_id,
                         p_acty_base_rt_id_table(i));
         if l_enrt_rt_id is not null then
           --
           l_enrt_rt_id_tab(i) := l_enrt_rt_id;         /* Bug 4230502 */
           --
           ben_manage_unres_life_events.update_enrt_rt
             ( p_enrt_rt_id  => l_enrt_rt_id,
               p_acty_typ_cd => l_acty_typ_cd(i),
               p_tx_typ_cd => l_tx_typ_cd(i),
               p_ctfn_rqd_flag => p_ctfn_rqd_flag,
               p_dflt_flag => p_dflt_flag,
               p_dflt_pndg_ctfn_flag => l_no,
               p_dsply_on_enrt_flag => l_dsply_on_enrt_flag(i),
               p_use_to_calc_net_flx_cr_flag => l_use_to_calc_net_flx_cr_flag(i),
               p_entr_val_at_enrt_flag => l_entr_val_at_enrt_flag(i),
               p_asn_on_enrt_flag => p_asn_on_enrt_flag_table(i),
               p_rl_crs_only_flag => l_no,
               p_dflt_val => l_dflt_val(i),
               p_ann_val => l_ann_val(i),
               p_ann_mn_elcn_val => l_ann_mn_elcn_val(i),
               p_ann_mx_elcn_val => l_ann_mx_elcn_val(i),
               p_val => l_val(i),
               p_nnmntry_uom => l_nnmntry_uom(i),
               p_mx_elcn_val => l_mx_elcn_val(i),
               p_mn_elcn_val => l_mn_elcn_val(i),
               p_incrmt_elcn_val => l_incrmt_elcn_val(i),
               p_cmcd_acty_ref_perd_cd => l_cmcd_acty_ref_perd_cd(i),
               p_cmcd_mn_elcn_val => l_cmcd_mn_elcn_val(i),
               p_cmcd_mx_elcn_val => l_cmcd_mx_elcn_val(i),
               p_cmcd_val => l_cmcd_val(i),
               p_cmcd_dflt_val => l_cmcd_val(i), --7154229
               p_rt_usg_cd => l_rt_usg_cd(i),
               p_ann_dflt_val => l_ann_dflt_val(i),
               p_bnft_rt_typ_cd => l_bnft_rt_typ_cd(i),
               p_rt_mlt_cd => l_rt_mlt_cd(i),
               p_dsply_mn_elcn_val => l_dsply_mn_elcn_val(i),
               p_dsply_mx_elcn_val => l_dsply_mx_elcn_val(i),
               p_entr_ann_val_flag => l_entr_ann_val_flag(i),
               p_rt_strt_dt => l_rt_strt_dt(i),
               p_rt_strt_dt_cd => l_rt_strt_dt_cd(i),
               p_rt_strt_dt_rl => l_rt_strt_dt_rl(i),
               p_rt_typ_cd => l_rt_typ_cd(i),
               p_elig_per_elctbl_chc_id => l_elig_per_elctbl_chc_id1,
               p_acty_base_rt_id => p_acty_base_rt_id_table(i),
               p_spcl_rt_enrt_rt_id => l_number_null,
               p_enrt_bnft_id => p_enrt_bnft_id,
               p_prtt_rt_val_id => l_prtt_rt_val_id(i),
               p_decr_bnft_prvdr_pool_id => l_decr_bnft_prvdr_pool_id(i),
               p_cvg_amt_calc_mthd_id => l_cvg_amt_calc_mthd_id(i),
               p_actl_prem_id => l_actl_prem_id(i),
               p_comp_lvl_fctr_id => l_comp_lvl_fctr_id(i),
               p_ptd_comp_lvl_fctr_id => l_ptd_comp_lvl_fctr_id(i),
               p_clm_comp_lvl_fctr_id => l_clm_comp_lvl_fctr_id(i),
               p_business_group_id => p_business_group_id,
               p_request_id   => l_request_id,
               p_program_application_id => l_program_application_id,
               p_program_id            =>l_program_id,
               p_program_update_date  => l_program_update_date ,
               p_effective_date      => p_effective_date,
               p_pp_in_yr_used_num   => l_pp_in_yr_used_num(i),
               p_ordr_num            => l_ordr_num(i),
               p_iss_val             => l_iss_val(i))
              ;
           --
         else
           --
           INSERT INTO ben_enrt_rt
                  (
                    enrt_rt_id,
                    acty_typ_cd,
                    tx_typ_cd,
                    ctfn_rqd_flag,
                    dflt_flag,
                    dflt_pndg_ctfn_flag,
                    dsply_on_enrt_flag,
                    use_to_calc_net_flx_cr_flag,
                    entr_val_at_enrt_flag,
                    asn_on_enrt_flag,
                    rl_crs_only_flag,
                    dflt_val,
                    ann_val,
                    ann_mn_elcn_val,
                    ann_mx_elcn_val,
                    val,
                    nnmntry_uom,
                    mx_elcn_val,
                    mn_elcn_val,
                    incrmt_elcn_val,
                    cmcd_acty_ref_perd_cd,
                    cmcd_mn_elcn_val,
                    cmcd_mx_elcn_val,
                    cmcd_val,
                    cmcd_dflt_val,
                    rt_usg_cd,
                    ann_dflt_val,
                    bnft_rt_typ_cd,
                    rt_mlt_cd,
                    dsply_mn_elcn_val,
                    dsply_mx_elcn_val,
                    entr_ann_val_flag,
                    rt_strt_dt,
                    rt_strt_dt_cd,
                    rt_strt_dt_rl,
                    rt_typ_cd,
                    elig_per_elctbl_chc_id,
                    acty_base_rt_id,
                    spcl_rt_enrt_rt_id,
                    enrt_bnft_id,
                    prtt_rt_val_id,
                    decr_bnft_prvdr_pool_id,
                    cvg_amt_calc_mthd_id,
                    actl_prem_id,
                    comp_lvl_fctr_id,
                    ptd_comp_lvl_fctr_id,
                    clm_comp_lvl_fctr_id,
                    business_group_id,
                    ecr_attribute_category,
                    ecr_attribute1,
                    ecr_attribute2,
                    ecr_attribute3,
                    ecr_attribute4,
                    ecr_attribute5,
                    ecr_attribute6,
                    ecr_attribute7,
                    ecr_attribute8,
                    ecr_attribute9,
                    ecr_attribute10,
                    ecr_attribute11,
                    ecr_attribute12,
                    ecr_attribute13,
                    ecr_attribute14,
                    ecr_attribute15,
                    ecr_attribute16,
                    ecr_attribute17,
                    ecr_attribute18,
                    ecr_attribute19,
                    ecr_attribute20,
                    ecr_attribute21,
                    ecr_attribute22,
                    ecr_attribute23,
                    ecr_attribute24,
                    ecr_attribute25,
                    ecr_attribute26,
                    ecr_attribute27,
                    ecr_attribute28,
                    ecr_attribute29,
                    ecr_attribute30,
                    last_update_login,
                    created_by,
                    creation_date,
                    last_updated_by,
                    last_update_date,
                    request_id,
                    program_application_id,
                    program_id,
                    program_update_date,
                    object_version_number,
                    pp_in_yr_used_num,
                    ordr_num,
                    iss_val)
           VALUES(
             ben_enrt_rt_s.nextval,
             l_acty_typ_cd(i),
             l_tx_typ_cd(i),
             p_ctfn_rqd_flag,
             p_dflt_flag,
             l_no,
             l_dsply_on_enrt_flag(i),
             l_use_to_calc_net_flx_cr_flag(i),
             l_entr_val_at_enrt_flag(i),
             p_asn_on_enrt_flag_table(i),
             l_no,
             l_dflt_val(i),
             l_ann_val(i),
             l_ann_mn_elcn_val(i),
             l_ann_mx_elcn_val(i),
             l_val(i),
             l_nnmntry_uom(i),
             l_mx_elcn_val(i),
             l_mn_elcn_val(i),
             l_incrmt_elcn_val(i),
             l_cmcd_acty_ref_perd_cd(i),
             l_cmcd_mn_elcn_val(i),
             l_cmcd_mx_elcn_val(i),
             l_cmcd_val(i),
             l_cmcd_val(i) , --7154229
             l_rt_usg_cd(i),
             l_ann_dflt_val(i),
             l_bnft_rt_typ_cd(i),
             l_rt_mlt_cd(i),
             l_dsply_mn_elcn_val(i),
             l_dsply_mx_elcn_val(i),
             l_entr_ann_val_flag(i),
             l_rt_strt_dt(i),
             l_rt_strt_dt_cd(i),
             l_rt_strt_dt_rl(i),
             l_rt_typ_cd(i),
             l_elig_per_elctbl_chc_id1,
             p_acty_base_rt_id_table(i),
             l_number_null,
             p_enrt_bnft_id,
             l_prtt_rt_val_id(i),
             l_decr_bnft_prvdr_pool_id(i),
             l_cvg_amt_calc_mthd_id(i),
             l_actl_prem_id(i),
             l_comp_lvl_fctr_id(i),
             l_ptd_comp_lvl_fctr_id(i),
             l_clm_comp_lvl_fctr_id(i),
             p_business_group_id,
             l_varchar2_null,
             l_varchar2_null,
             l_varchar2_null,
             l_varchar2_null,
             l_varchar2_null,
             l_varchar2_null,
             l_varchar2_null,
             l_varchar2_null,
             l_varchar2_null,
             l_varchar2_null,
             l_varchar2_null,
             l_varchar2_null,
             l_varchar2_null,
             l_varchar2_null,
             l_varchar2_null,
             l_varchar2_null,
             l_varchar2_null,
             l_varchar2_null,
             l_varchar2_null,
             l_varchar2_null,
             l_varchar2_null,
             l_varchar2_null,
             l_varchar2_null,
             l_varchar2_null,
             l_varchar2_null,
             l_varchar2_null,
             l_varchar2_null,
             l_varchar2_null,
             l_varchar2_null,
             l_varchar2_null,
             l_varchar2_null,
             l_last_update_login,
             l_created_by,
             l_creation_date,
             l_last_updated_by,
             l_last_update_date,
             l_request_id,
             l_program_application_id,
             l_program_id,
             l_program_update_date,
             l_object_version_number,
             l_pp_in_yr_used_num(i),
             l_ordr_num(i),
             l_iss_val(i))
             returning enrt_rt_id into l_enrt_rt_id_tab(i) ;        /* Bug 4230502 */
             --
          end if;
          --
        end loop;
        --
      else
       --
       FORALL i IN p_acty_base_rt_id_table.FIRST .. p_acty_base_rt_id_table.LAST
        INSERT INTO ben_enrt_rt
                  (
                    enrt_rt_id,
                    acty_typ_cd,
                    tx_typ_cd,
                    ctfn_rqd_flag,
                    dflt_flag,
                    dflt_pndg_ctfn_flag,
                    dsply_on_enrt_flag,
                    use_to_calc_net_flx_cr_flag,
                    entr_val_at_enrt_flag,
                    asn_on_enrt_flag,
                    rl_crs_only_flag,
                    dflt_val,
                    ann_val,
                    ann_mn_elcn_val,
                    ann_mx_elcn_val,
                    val,
                    nnmntry_uom,
                    mx_elcn_val,
                    mn_elcn_val,
                    incrmt_elcn_val,
                    cmcd_acty_ref_perd_cd,
                    cmcd_mn_elcn_val,
                    cmcd_mx_elcn_val,
                    cmcd_val,
                    cmcd_dflt_val,
                    rt_usg_cd,
                    ann_dflt_val,
                    bnft_rt_typ_cd,
                    rt_mlt_cd,
                    dsply_mn_elcn_val,
                    dsply_mx_elcn_val,
                    entr_ann_val_flag,
                    rt_strt_dt,
                    rt_strt_dt_cd,
                    rt_strt_dt_rl,
                    rt_typ_cd,
                    elig_per_elctbl_chc_id,
                    acty_base_rt_id,
                    spcl_rt_enrt_rt_id,
                    enrt_bnft_id,
                    prtt_rt_val_id,
                    decr_bnft_prvdr_pool_id,
                    cvg_amt_calc_mthd_id,
                    actl_prem_id,
                    comp_lvl_fctr_id,
                    ptd_comp_lvl_fctr_id,
                    clm_comp_lvl_fctr_id,
                    business_group_id,
                    ecr_attribute_category,
                    ecr_attribute1,
                    ecr_attribute2,
                    ecr_attribute3,
                    ecr_attribute4,
                    ecr_attribute5,
                    ecr_attribute6,
                    ecr_attribute7,
                    ecr_attribute8,
                    ecr_attribute9,
                    ecr_attribute10,
                    ecr_attribute11,
                    ecr_attribute12,
                    ecr_attribute13,
                    ecr_attribute14,
                    ecr_attribute15,
                    ecr_attribute16,
                    ecr_attribute17,
                    ecr_attribute18,
                    ecr_attribute19,
                    ecr_attribute20,
                    ecr_attribute21,
                    ecr_attribute22,
                    ecr_attribute23,
                    ecr_attribute24,
                    ecr_attribute25,
                    ecr_attribute26,
                    ecr_attribute27,
                    ecr_attribute28,
                    ecr_attribute29,
                    ecr_attribute30,
                    last_update_login,
                    created_by,
                    creation_date,
                    last_updated_by,
                    last_update_date,
                    request_id,
                    program_application_id,
                    program_id,
                    program_update_date,
                    object_version_number,
                    pp_in_yr_used_num,
                    ordr_num,
                    iss_val)
           VALUES(
             ben_enrt_rt_s.nextval,
             l_acty_typ_cd(i),
             l_tx_typ_cd(i),
             p_ctfn_rqd_flag,
             p_dflt_flag,
             l_no,
             l_dsply_on_enrt_flag(i),
             l_use_to_calc_net_flx_cr_flag(i),
             l_entr_val_at_enrt_flag(i),
             p_asn_on_enrt_flag_table(i),
             l_no,
             l_dflt_val(i),
             l_ann_val(i),
             l_ann_mn_elcn_val(i),
             l_ann_mx_elcn_val(i),
             l_val(i),
             l_nnmntry_uom(i),
             l_mx_elcn_val(i),
             l_mn_elcn_val(i),
             l_incrmt_elcn_val(i),
             l_cmcd_acty_ref_perd_cd(i),
             l_cmcd_mn_elcn_val(i),
             l_cmcd_mx_elcn_val(i),
             l_cmcd_val(i),
             l_cmcd_val(i) , --7154229
             l_rt_usg_cd(i),
             l_ann_dflt_val(i),
             l_bnft_rt_typ_cd(i),
             l_rt_mlt_cd(i),
             l_dsply_mn_elcn_val(i),
             l_dsply_mx_elcn_val(i),
             l_entr_ann_val_flag(i),
             l_rt_strt_dt(i),
             l_rt_strt_dt_cd(i),
             l_rt_strt_dt_rl(i),
             l_rt_typ_cd(i),
             l_elig_per_elctbl_chc_id1,
             p_acty_base_rt_id_table(i),
             l_number_null,
             p_enrt_bnft_id,
             l_prtt_rt_val_id(i),
             l_decr_bnft_prvdr_pool_id(i),
             l_cvg_amt_calc_mthd_id(i),
             l_actl_prem_id(i),
             l_comp_lvl_fctr_id(i),
             l_ptd_comp_lvl_fctr_id(i),
             l_clm_comp_lvl_fctr_id(i),
             p_business_group_id,
             l_varchar2_null,
             l_varchar2_null,
             l_varchar2_null,
             l_varchar2_null,
             l_varchar2_null,
             l_varchar2_null,
             l_varchar2_null,
             l_varchar2_null,
             l_varchar2_null,
             l_varchar2_null,
             l_varchar2_null,
             l_varchar2_null,
             l_varchar2_null,
             l_varchar2_null,
             l_varchar2_null,
             l_varchar2_null,
             l_varchar2_null,
             l_varchar2_null,
             l_varchar2_null,
             l_varchar2_null,
             l_varchar2_null,
             l_varchar2_null,
             l_varchar2_null,
             l_varchar2_null,
             l_varchar2_null,
             l_varchar2_null,
             l_varchar2_null,
             l_varchar2_null,
             l_varchar2_null,
             l_varchar2_null,
             l_varchar2_null,
             l_last_update_login,
             l_created_by,
             l_creation_date,
             l_last_updated_by,
             l_last_update_date,
             l_request_id,
             l_program_application_id,
             l_program_id,
             l_program_update_date,
             l_object_version_number,
             l_pp_in_yr_used_num(i),
             l_ordr_num(i),
             l_iss_val(i))
             returning enrt_rt_id BULK COLLECT into l_enrt_rt_id_tab ;
         end if;
         --
    end if;

    --
    if g_debug then
      hr_utility.set_location('after Insert  ' , 5);
    end if;

    -- 2897152  when the date mult code is NSVU and rate does not have any
    -- values then no rate will be created . so the
    -- rows are deleted here
    -- we could not find way to stop the insert without changing bulk insert
    -- for the above condition
    -- so the row are deleted after insert

    -- Bug 4693040 : In CWB mode as no rates are written no need to delete data.
    -- Also rate certifications are not relevant for cwb mode.
    --
    if nvl(p_mode, 'X') <> 'W'  then
      --
      if l_nsuv_lst.COUNT > 0 then

       if g_debug then
          hr_utility.set_location(' COUNT ' || l_nsuv_lst.COUNT , 99 );
          hr_utility.set_location(' Deleting '  , 99 );
       end if;
       for i in l_nsuv_lst.FIRST  .. l_nsuv_lst.LAST  Loop
          l_nsuv_num := l_nsuv_lst(i) ;
          if   p_acty_base_rt_id_table.EXISTS(l_nsuv_num)
             and l_rt_mlt_cd(l_nsuv_num) = 'NSVU'
             and l_val(l_nsuv_num)  is null then
               if g_debug then
                 hr_utility.set_location(' enrt rt_id  '||l_enrt_rt_id_tab(l_nsuv_num)  , 99 );
               end if ;

               Delete from Ben_enrt_rt
               where val is null
                 and rt_mlt_cd          = l_rt_mlt_cd(l_nsuv_num)
                 and acty_base_rt_id    = p_acty_base_rt_id_table(l_nsuv_num)
                 and business_group_id  = p_business_group_id
                 and enrt_rt_id         = l_enrt_rt_id_tab(l_nsuv_num)  ;
          end if ;
       End Loop ;

      end if ;
      --

      -- LGE : Now create the rate certifications.
      --
      FOR i IN p_acty_base_rt_id_table.FIRST .. p_acty_base_rt_id_table.LAST loop
       --
       if l_rt_mlt_cd(i)= 'NSVU' and l_val(i) is null then
          --- Do nothing
          null ;
       else

          if p_enrt_bnft_id is not null then
            --
              for l_enrt_ctfn in c_enrt_ctfn_bnft(p_acty_base_rt_id_table(i),
                                             p_elig_per_elctbl_chc_id)
              loop
                  -- bug#4126093
                  open c_enrt_ctfn_exists (l_enrt_ctfn.enrt_rt_id,l_enrt_ctfn.enrt_ctfn_typ_cd);
                  fetch c_enrt_ctfn_exists into l_dummy;
                  if c_enrt_ctfn_exists%notfound then
                    ben_enrt_rt_ctfn_api.create_enrt_rt_ctfn
                       (p_validate                  => false
                       ,p_enrt_rt_ctfn_id           => l_enrt_rt_ctfn_id
                       ,p_enrt_ctfn_typ_cd          => l_enrt_ctfn.enrt_ctfn_typ_cd
                       ,p_rqd_flag                  => l_enrt_ctfn.rqd_flag
                       ,p_enrt_rt_id                => l_enrt_ctfn.enrt_rt_id
                       ,p_business_group_id         => p_business_group_id
                       ,p_request_id                => l_request_id
                       ,p_program_application_id    => l_program_application_id
                       ,p_program_id                => l_program_id
                       ,p_program_update_date       => l_program_update_date
                       ,p_object_version_number     => l_object_version_number
                       ,p_effective_date            => p_effective_date
                       ) ;
                  end if;
                  close c_enrt_ctfn_exists;
                  --
               end loop;
          else
             --
              for l_enrt_ctfn in c_enrt_ctfn_rt(p_acty_base_rt_id_table(i),
                                             p_elig_per_elctbl_chc_id)
              loop
                  --
                  open c_enrt_ctfn_exists (l_enrt_ctfn.enrt_rt_id,l_enrt_ctfn.enrt_ctfn_typ_cd);
                  fetch c_enrt_ctfn_exists into l_dummy;
                  if c_enrt_ctfn_exists%notfound then
                    ben_enrt_rt_ctfn_api.create_enrt_rt_ctfn
                       (p_validate                  => false
                       ,p_enrt_rt_ctfn_id           => l_enrt_rt_ctfn_id
                       ,p_enrt_ctfn_typ_cd          => l_enrt_ctfn.enrt_ctfn_typ_cd
                       ,p_rqd_flag                  => l_enrt_ctfn.rqd_flag
                       ,p_enrt_rt_id                => l_enrt_ctfn.enrt_rt_id
                       ,p_business_group_id         => p_business_group_id
                       ,p_request_id                => l_request_id
                       ,p_program_application_id    => l_program_application_id
                       ,p_program_id                => l_program_id
                       ,p_program_update_date       => l_program_update_date
                       ,p_object_version_number     => l_object_version_number
                       ,p_effective_date            => p_effective_date
                       ) ;
                  end if;
                  close c_enrt_ctfn_exists;
                 --
               end loop;
               --
          end if;
       end if ;
      End loop ;
    end if;
    --
    if g_debug then
      hr_utility.set_location('Leaving ' || l_package, 10);
    end if;
    --
  END ben_rates;
  --
  PROCEDURE main(
    p_effective_date IN DATE,
    p_lf_evt_ocrd_dt IN DATE,
    p_person_id      IN NUMBER,
--  added per_in_ler_id parameter for unrestricted enhancement
    p_per_in_ler_id  in number,
    p_elig_per_elctbl_chc_id IN number default null ,
    p_mode                   in varchar2 default null) IS
    --
    l_package                VARCHAR2(80)                := g_package ||
                                                              '.main';
    --
    l_pep_row                ben_derive_part_and_rate_facts.g_cache_structure;
    l_epo_row                ben_derive_part_and_rate_facts.g_cache_structure;
    --
    l_currepe_set            ben_epe_cache.g_pilepe_inst_tbl;
    --
    l_currepe_row            ben_epe_cache.g_pilepe_inst_row;
    --
/*
    l_currepe_row            ben_determine_rates.g_curr_epe_rec;
*/
    l_per_row                per_all_people_f%ROWTYPE;
    l_asg_row                per_all_assignments_f%ROWTYPE;
    l_ast_row                per_assignment_status_types%ROWTYPE;
    l_adr_row                per_addresses%ROWTYPE;
    --
    l_pl_id                  NUMBER;
    l_pgm_id                 NUMBER;
    l_oipl_id                NUMBER;
    l_oiplip_id              NUMBER;
    l_plip_id                NUMBER;
    l_ptip_id                NUMBER;
    l_cmbn_plip_id           NUMBER;
    l_cmbn_ptip_id           NUMBER;
    l_cmbn_ptip_opt_id       NUMBER;
    l_elig_per_elctbl_chc_id NUMBER;
    l_lwr_lvl_rt_exist       BOOLEAN                                   := FALSE;
    --START ENH
    l_opt_id                 NUMBER;
    --END ENH
    --
    l_dummy_num             number;
    l_dummy_char            varchar2(30);
    l_dummy_date            date;
    l_rt_strt_dt            date;
    l_rt_strt_dt_cd         varchar2(30);
    l_rt_strt_dt_rl         number;

    CURSOR c_epe IS
      SELECT   epe.elig_per_elctbl_chc_id,
               epe.comp_lvl_cd,
               epe.oipl_id,
               epe.pl_id,
               epe.pgm_id,
               epe.plip_id,
               epe.oiplip_id,
               epe.ptip_id,
               epe.pl_typ_id,
               epe.cmbn_plip_id,
               epe.cmbn_ptip_id,
               epe.cmbn_ptip_opt_id,
               epe.business_group_id,
               epe.dflt_flag,
               epe.ctfn_rqd_flag,
               enb.enrt_bnft_id,
               epe.per_in_ler_id,
               epe.prtt_enrt_rslt_id,
               epe.enrt_cvg_strt_dt,
               epe.enrt_cvg_strt_dt_cd,
               epe.enrt_cvg_strt_dt_rl,
               epe.yr_perd_id,
               pel.enrt_perd_strt_dt,
               pel.enrt_perd_id,
               pel.lee_rsn_id,
               pel.acty_ref_perd_cd,
               pil.ler_id,
               pil.person_id
      FROM     ben_elig_per_elctbl_chc epe,
               ben_pil_elctbl_chc_popl pel,
               ben_enrt_bnft enb,
               ben_per_in_ler pil
      WHERE    epe.elig_per_elctbl_chc_id = enb.elig_per_elctbl_chc_id (+)
      AND      epe.per_in_ler_id = pil.per_in_ler_id
      AND      epe.per_in_ler_id = pel.per_in_ler_id
      AND      epe.pil_elctbl_chc_popl_id = pel.pil_elctbl_chc_popl_id
   --   AND      pil.per_in_ler_stat_cd = 'STRTD'
   -- added for unrestricted enhancement
      and      pil.per_in_ler_id = p_per_in_ler_id
      AND      pil.person_id = p_person_id
  -- Override Enrollment Changes
      AND      nvl(epe.elig_per_elctbl_chc_id,-1) = nvl(p_elig_per_elctbl_chc_id,-1);
  -- Override Enrollment Changes
    --
    CURSOR c_abr_oiplip(
      c_effective_date DATE) IS
      SELECT   abr.acty_base_rt_id,
               abr.asn_on_enrt_flag
      FROM     ben_acty_base_rt_f abr
      WHERE    abr.oiplip_id = l_oiplip_id
      AND      abr.rt_usg_cd <> 'FLXCR'
      AND      abr.acty_base_rt_stat_cd = 'A'
      AND      c_effective_date BETWEEN abr.effective_start_date
                   AND abr.effective_end_date
      ORDER BY abr_seq_num;
    CURSOR c_abr_oipl(
      c_effective_date DATE) IS
      SELECT   abr.acty_base_rt_id,
               abr.asn_on_enrt_flag
      FROM     ben_acty_base_rt_f abr
      WHERE    abr.acty_base_rt_stat_cd = 'A'
      AND      abr.oipl_id = l_oipl_id
      AND      abr.rt_usg_cd <> 'FLXCR'
      AND      c_effective_date BETWEEN abr.effective_start_date
                   AND abr.effective_end_date
      ORDER BY abr_seq_num;
    --START ENH
    CURSOR c_abr_opt(
      c_effective_date DATE) IS
      SELECT   abr.acty_base_rt_id,
               abr.asn_on_enrt_flag
      FROM     ben_acty_base_rt_f abr
      WHERE    abr.acty_base_rt_stat_cd = 'A'
      AND      abr.opt_id = l_opt_id
      AND      abr.rt_usg_cd <> 'FLXCR'
      AND      c_effective_date BETWEEN abr.effective_start_date
                   AND abr.effective_end_date
      ORDER BY abr_seq_num;
    --END ENH
    CURSOR c_abr_plip(
      c_effective_date DATE) IS
      SELECT   abr.acty_base_rt_id,
               abr.asn_on_enrt_flag
      FROM     ben_acty_base_rt_f abr
      WHERE    abr.acty_base_rt_stat_cd = 'A'
      AND      abr.plip_id = l_plip_id
      AND      abr.rt_usg_cd <> 'FLXCR'
      AND      abr.cmbn_plip_id IS NULL
      AND      c_effective_date BETWEEN abr.effective_start_date
                   AND abr.effective_end_date
      ORDER BY abr_seq_num;
    CURSOR c_abr_pl(
      c_effective_date DATE) IS
      SELECT   abr.acty_base_rt_id,
               abr.asn_on_enrt_flag
      FROM     ben_acty_base_rt_f abr
      WHERE    abr.acty_base_rt_stat_cd = 'A'
      AND      abr.pl_id = l_pl_id
      AND      abr.rt_usg_cd <> 'FLXCR'
      AND      c_effective_date BETWEEN abr.effective_start_date
                   AND abr.effective_end_date
      ORDER BY abr_seq_num;
    CURSOR c_abr_pgm(
      c_effective_date DATE) IS
      SELECT   abr.acty_base_rt_id,
               abr.asn_on_enrt_flag
      FROM     ben_acty_base_rt_f abr
      WHERE    abr.acty_base_rt_stat_cd = 'A'
      AND      abr.pgm_id = l_pgm_id
      AND      c_effective_date BETWEEN abr.effective_start_date
                   AND abr.effective_end_date
      ORDER BY abr_seq_num;
    CURSOR c_abr_ptip(
      c_effective_date DATE) IS
      SELECT   abr.acty_base_rt_id,
               abr.asn_on_enrt_flag
      FROM     ben_acty_base_rt_f abr
      WHERE    abr.acty_base_rt_stat_cd = 'A'
      AND      abr.ptip_id = l_ptip_id
      AND      abr.cmbn_ptip_id IS NULL
      AND      abr.cmbn_ptip_opt_id IS NULL
      AND      c_effective_date BETWEEN abr.effective_start_date
                   AND abr.effective_end_date
      ORDER BY abr_seq_num;
    CURSOR c_abr_cmbn_ptip(
      c_effective_date DATE) IS
      SELECT   abr.acty_base_rt_id,
               abr.asn_on_enrt_flag
      FROM     ben_acty_base_rt_f abr
      WHERE    abr.acty_base_rt_stat_cd = 'A'
      AND      abr.cmbn_ptip_id = l_cmbn_ptip_id
      AND      c_effective_date BETWEEN abr.effective_start_date
                   AND abr.effective_end_date
      AND      abr.cmbn_ptip_opt_id IS NULL
      AND      abr.ptip_id IS NULL
      ORDER BY abr_seq_num;
    CURSOR c_abr_flx_plip(
      c_effective_date DATE) IS
      SELECT   abr.acty_base_rt_id,
               abr.asn_on_enrt_flag
      FROM     ben_acty_base_rt_f abr
      WHERE    abr.acty_base_rt_stat_cd = 'A'
      AND      abr.plip_id = l_plip_id
      AND      abr.rt_usg_cd = 'FLXCR'
      AND      abr.cmbn_plip_id IS NULL
      AND      c_effective_date BETWEEN abr.effective_start_date
                   AND abr.effective_end_date
      ORDER BY abr_seq_num;
    CURSOR c_abr_cmbn_plip(
      c_effective_date DATE) IS
      SELECT   abr.acty_base_rt_id,
               abr.asn_on_enrt_flag
      FROM     ben_acty_base_rt_f abr
      WHERE    abr.acty_base_rt_stat_cd = 'A'
      AND      abr.cmbn_plip_id = l_cmbn_plip_id
      AND      c_effective_date BETWEEN abr.effective_start_date
                   AND abr.effective_end_date
      AND      abr.plip_id IS NULL
      ORDER BY abr_seq_num;
    CURSOR c_abr_flx_oiplip(
      c_effective_date DATE) IS
      SELECT   abr.acty_base_rt_id,
               abr.asn_on_enrt_flag
      FROM     ben_acty_base_rt_f abr
      WHERE    abr.oiplip_id = l_oiplip_id
      AND      abr.rt_usg_cd = 'FLXCR'
      AND      abr.acty_base_rt_stat_cd = 'A'
      AND      c_effective_date BETWEEN abr.effective_start_date
                   AND abr.effective_end_date
      ORDER BY abr_seq_num;
    CURSOR c_abr_cmbn_ptip_opt(
      c_effective_date DATE) IS
      SELECT   abr.acty_base_rt_id,
               abr.asn_on_enrt_flag
      FROM     ben_acty_base_rt_f abr
      WHERE    abr.acty_base_rt_stat_cd = 'A'
      AND      abr.cmbn_ptip_opt_id = l_cmbn_ptip_opt_id
      AND      c_effective_date BETWEEN abr.effective_start_date
                   AND abr.effective_end_date
      AND      abr.ptip_id IS NULL
      AND      abr.cmbn_ptip_id IS NULL
      ORDER BY abr_seq_num;
    CURSOR c_current_plnippepelig(
      c_person_id      NUMBER,
      c_pl_id          NUMBER,
      c_effective_date DATE) IS
      SELECT   ep.prtn_strt_dt,
               ep.prtn_ovridn_flag,
               ep.prtn_ovridn_thru_dt,
               ep.rt_age_val,
               ep.rt_los_val,
               ep.rt_hrs_wkd_val,
               ep.rt_cmbn_age_n_los_val
      FROM     ben_elig_per_f ep, ben_per_in_ler pil
      WHERE    ep.person_id = c_person_id
      AND      ep.pgm_id IS NULL
      AND      ep.pl_id = c_pl_id
      AND      c_effective_date BETWEEN ep.effective_start_date
                   AND ep.effective_end_date
      AND      pil.per_in_ler_id (+) = ep.per_in_ler_id
      AND      (
                    pil.per_in_ler_stat_cd NOT IN ('VOIDD', 'BCKDT')
                 OR pil.per_in_ler_stat_cd IS NULL);
    CURSOR c_current_plnipepoelig(
      c_person_id      NUMBER,
      c_pl_id          NUMBER,
      c_opt_id         NUMBER,
      c_effective_date DATE) IS
      SELECT   epo.prtn_strt_dt,
               epo.prtn_ovridn_flag,
               epo.prtn_ovridn_thru_dt,
               epo.rt_age_val,
               epo.rt_los_val,
               epo.rt_hrs_wkd_val,
               epo.rt_cmbn_age_n_los_val
      FROM     ben_elig_per_f ep, ben_elig_per_opt_f epo, ben_per_in_ler pil
      WHERE    ep.person_id = c_person_id
      AND      ep.pgm_id IS NULL
      AND      ep.pl_id = c_pl_id
      AND      epo.opt_id = c_opt_id
      AND      c_effective_date BETWEEN ep.effective_start_date
                   AND ep.effective_end_date
      AND      ep.elig_per_id = epo.elig_per_id
      AND      c_effective_date BETWEEN epo.effective_start_date
                   AND epo.effective_end_date
      AND      pil.per_in_ler_id (+) = ep.per_in_ler_id
      AND      (
                    pil.per_in_ler_stat_cd NOT IN ('VOIDD', 'BCKDT')
                 OR pil.per_in_ler_stat_cd IS NULL);
    --
    CURSOR c_opt(
      c_effective_date DATE,
      c_oipl_id        NUMBER) IS
      SELECT   oipl.opt_id
      FROM     ben_oipl_f oipl
      WHERE    oipl.oipl_id = c_oipl_id
      AND      c_effective_date BETWEEN oipl.effective_start_date
                   AND oipl.effective_end_date;
    --
    l_effective_date         DATE;
    --
    l_acty_base_rt_id_table  ben_determine_rates.g_acty_base_rt_id_table;
    l_asn_on_enrt_flag_table ben_determine_rates.g_asn_on_enrt_flag_table;
    --
    l_asg_benass_row    per_all_assignments_f%ROWTYPE;
  --
  -----Bug 8394662
  cursor c_get_rate(p_pgm_id number,
                    p_pl_id number,
		    p_opt_id number,
		    p_business_group_id number) is
  SELECT *
  FROM ben_acty_base_rt_f abr
 WHERE abr.business_group_id = p_business_group_id
   AND Nvl(abr.context_pgm_id,-1) = Nvl(p_pgm_id,-1)
   AND Nvl(abr.context_pl_id,-1) = Nvl(p_pl_id,-1)
   AND Nvl(abr.context_opt_id,-1) = Nvl(p_opt_id,-1);

  l_get_rate  c_get_rate%rowtype;
  -------Bug 8394662
  BEGIN
    g_debug := hr_utility.debug_enabled;
    if g_debug then
      hr_utility.set_location('Entering ' || l_package, 10);
    end if;
    IF (p_effective_date IS NULL) THEN
      if g_debug then
        hr_utility.set_location('BEN_91552_BENRATES_INPT_EFFDT', 10);
      end if;
      fnd_message.set_name('BEN', 'BEN_91552_BENRATES_INPT_EFFDT');
      fnd_message.set_token('PACKAGE', l_package);
      fnd_message.set_token('PERSON_ID', p_person_id);
      fnd_message.set_token('LF_EVT_OCRD_DT', p_lf_evt_ocrd_dt);
      fnd_message.raise_error;
    END IF;
    --
    l_effective_date  := NVL(p_lf_evt_ocrd_dt, p_effective_date);
    --
    -- Get person info
    --
    ben_person_object.get_object(
      p_person_id => p_person_id,
      p_rec       => l_per_row);
    --
    ben_person_object.get_object(
      p_person_id => p_person_id,
      p_rec       => l_asg_row);
    --
    IF l_asg_row.assignment_status_type_id IS NOT NULL THEN
      --
      ben_person_object.get_object(
        p_assignment_status_type_id => l_asg_row.assignment_status_type_id,
        p_rec                       => l_ast_row);
    --
    END IF;
    --
    ben_person_object.get_object(
      p_person_id => p_person_id,
      p_rec       => l_adr_row);
    --
    -- added a parameter per_in_ler_id for unrestricted enhancement
    --
    -- Bug 2200139 Override Enrollment changes if the p_elig_per_elctbl_chc_id
    -- is not null let us call only the record not the table from
    -- the cache.
    if p_elig_per_elctbl_chc_id is null then
      --
      ben_epe_cache.get_perpilepe_list
        (p_person_id => p_person_id
         ,p_per_in_ler_id => p_per_in_ler_id
        --
        ,p_inst_set  => l_currepe_set
        );
    else
      -- Override Case
      ben_epe_cache.epe_getepedets
        (p_elig_per_elctbl_chc_id  => p_elig_per_elctbl_chc_id
        ,p_per_in_ler_id           => p_per_in_ler_id
        ,p_inst_row                => l_currepe_row
        );
      -- hr_utility.set_location('EPE '||l_currepe_row.elig_per_elctbl_chc_id,45);
      -- hr_utility.set_location(' comp_lvl_cd '||l_currepe_row.comp_lvl_cd ,45);
      --
      -- l_currepe_set(1) := l_currepe_row ;
      --
    end if;
    --
    -- Clear epe context row
    --
    ben_epe_cache.init_context_pileperow;
    --
/*
    ben_distribute_rates.clear_down_cache;
    --
*/
    -- Bug 2200139 Override Enrollment changes
    if p_elig_per_elctbl_chc_id is not null then
      --
      l_currepe_set(1) := l_currepe_row ;
      --
    end if;
    -- Bug 2200139 Override Enrollment changes
    if l_currepe_set.count > 0 then
      --
      for epe_elenum in l_currepe_set.first..l_currepe_set.last loop
        --
        if g_debug then
          hr_utility.set_location('St EPE loop ' || l_package, 10);
        end if;
        --
        l_currepe_row := l_currepe_set(epe_elenum);
        --
        -- Bug 1895846
        --
      if nvl(l_currepe_row.in_pndg_wkflow_flag,'N') = 'N' then
        --
        l_elig_per_elctbl_chc_id              := l_currepe_row.elig_per_elctbl_chc_id;
        --
        l_pgm_id                              := l_currepe_row.pgm_id;
        l_ptip_id                             := l_currepe_row.ptip_id;
        l_plip_id                             := l_currepe_row.plip_id;
        l_pl_id                               := l_currepe_row.pl_id;
        l_oipl_id                             := l_currepe_row.oipl_id;
        l_oiplip_id                           := l_currepe_row.oiplip_id;
        l_lwr_lvl_rt_exist                    := TRUE;
        -- start with it 'on' for all comp-lvl-cds
        l_cmbn_plip_id                        := l_currepe_row.cmbn_plip_id;
        l_cmbn_ptip_id                        := l_currepe_row.cmbn_ptip_id;
        l_cmbn_ptip_opt_id                    := l_currepe_row.cmbn_ptip_opt_id;
        --
        -- Get opt id for the oipl
        --
        IF l_currepe_row.oipl_id IS NOT NULL THEN
          --
          OPEN c_opt(
            c_effective_date => l_effective_date,
            c_oipl_id        => l_currepe_row.oipl_id);
          FETCH c_opt INTO l_currepe_row.opt_id;
          CLOSE c_opt;
        --
        END IF;
        --
        -- Get eligibility prtn start date for the comp object
        --
        -- Check for oipl eligibility for plan in and not in a program
        --
        -- Note: split into multiple cursors for performance reasons rather
        --       than a union statement
        --
        IF l_currepe_row.opt_id IS NOT NULL THEN
          --START ENH
          l_opt_id := l_currepe_row.opt_id;
          --END ENH
          --
          IF l_currepe_row.pgm_id IS NOT NULL THEN
            --
            -- Get the cached elig per opt info
            --
            if g_debug then
              hr_utility.set_location('PILEPO cache ' || l_package, 10);
            end if;
            ben_pep_cache.get_pilepo_dets(
              p_person_id         => p_person_id,
              p_business_group_id => l_currepe_row.business_group_id,
              p_effective_date    => p_effective_date,
              p_pgm_id            => l_currepe_row.pgm_id,
              p_pl_id             => l_currepe_row.pl_id,
              p_opt_id            => l_currepe_row.opt_id,
              p_inst_row          => l_epo_row);
            if g_debug then
              hr_utility.set_location('Dn PILEPO cache ' || l_package, 10);
            end if;
            --
            l_currepe_row.prtn_strt_dt          := l_epo_row.prtn_strt_dt;
            l_currepe_row.prtn_ovridn_flag      := l_epo_row.prtn_ovridn_flag;
            l_currepe_row.prtn_ovridn_thru_dt   := l_epo_row.prtn_ovridn_thru_dt;
            l_currepe_row.rt_age_val            := l_epo_row.rt_age_val;
            l_currepe_row.rt_los_val            := l_epo_row.rt_los_val;
            l_currepe_row.rt_hrs_wkd_val        := l_epo_row.rt_hrs_wkd_val;
            l_currepe_row.rt_cmbn_age_n_los_val := l_epo_row.rt_cmbn_age_n_los_val;

          --
          ELSE
            --
            OPEN c_current_plnipepoelig(
              c_person_id      => p_person_id,
              c_pl_id          => l_currepe_row.pl_id,
              c_opt_id         => l_currepe_row.opt_id,
              c_effective_date => l_effective_date);
            FETCH c_current_plnipepoelig INTO l_currepe_row.prtn_strt_dt,
                                              l_currepe_row.prtn_ovridn_flag,
                                              l_currepe_row.prtn_ovridn_thru_dt,
                                              l_currepe_row.rt_age_val,
                                              l_currepe_row.rt_los_val,
                                              l_currepe_row.rt_hrs_wkd_val,
                                              l_currepe_row.rt_cmbn_age_n_los_val;
            if g_debug then
              hr_utility.set_location('plan,opt,rt'||l_currepe_row.pl_id||l_currepe_row.opt_id||l_currepe_row.rt_los_val, 111);
            end if;

            CLOSE c_current_plnipepoelig;
          --
          END IF;
        --
        ELSE
          --
          IF l_currepe_row.pgm_id IS NOT NULL THEN
            --
            -- Get the cached elig per info
            --
            if g_debug then
              hr_utility.set_location('PILPEP cache ' || l_package, 10);
            end if;
            ben_pep_cache.get_pilpep_dets(
              p_person_id         => p_person_id,
              p_business_group_id => l_currepe_row.business_group_id,
              p_effective_date    => p_effective_date,
              p_pgm_id            => l_currepe_row.pgm_id,
              p_pl_id             => l_currepe_row.pl_id,
              p_inst_row          => l_pep_row);
            if g_debug then
              hr_utility.set_location('Dn PILPEP cache ' || l_package, 10);
            end if;
            --
            l_currepe_row.prtn_strt_dt          := l_pep_row.prtn_strt_dt;
            l_currepe_row.prtn_ovridn_flag      := l_pep_row.prtn_ovridn_flag;
            l_currepe_row.prtn_ovridn_thru_dt   := l_pep_row.prtn_ovridn_thru_dt;
            l_currepe_row.rt_age_val            := l_pep_row.rt_age_val;
            l_currepe_row.rt_los_val            := l_pep_row.rt_los_val;
            l_currepe_row.rt_hrs_wkd_val        := l_pep_row.rt_hrs_wkd_val;
            l_currepe_row.rt_cmbn_age_n_los_val := l_pep_row.rt_cmbn_age_n_los_val;
          --
          ELSE
            --
            OPEN c_current_plnippepelig(
              c_person_id      => p_person_id,
              c_pl_id          => l_currepe_row.pl_id,
              c_effective_date => l_effective_date);
            FETCH c_current_plnippepelig INTO l_currepe_row.prtn_strt_dt,
                                              l_currepe_row.prtn_ovridn_flag,
                                              l_currepe_row.prtn_ovridn_thru_dt,
                                              l_currepe_row.rt_age_val,
                                              l_currepe_row.rt_los_val,
                                              l_currepe_row.rt_hrs_wkd_val,
                                              l_currepe_row.rt_cmbn_age_n_los_val;

            CLOSE c_current_plnippepelig;
          --
          END IF;
        --
        END IF;
        --
        g_rec.person_id                       := l_currepe_row.person_id;
        g_rec.pgm_id                          := l_currepe_row.pgm_id;
        g_rec.pl_id                           := l_currepe_row.pl_id;
        g_rec.oipl_id                         := l_currepe_row.oipl_id;
        -- reset the collection tables
        l_acty_base_rt_id_table.DELETE;
        l_asn_on_enrt_flag_table.DELETE;
        --
        -- Set the electable choice context variable
        --
        ben_epe_cache.g_currepe_row := l_currepe_row;

        if l_currepe_row.fonm_cvg_strt_dt is not null then
           ben_manage_life_events.fonm := 'Y';
           -- assign the FONM CVG date before calling  rate calcaultion
           if ben_manage_life_events.g_fonm_cvg_strt_dt is null or
              ben_manage_life_events.g_fonm_cvg_strt_dt <> l_currepe_row.fonm_cvg_strt_dt then
               ben_manage_life_events.g_fonm_cvg_strt_dt := l_currepe_row.fonm_cvg_strt_dt ;
           end if ;

           hr_utility.set_location ('fonm cvg '||ben_manage_life_events.g_fonm_cvg_strt_dt ,10);
        else
           ben_manage_life_events.fonm := 'N';
           ben_manage_life_events.g_fonm_rt_strt_dt := null;
           ben_manage_life_events.g_fonm_cvg_strt_dt := null;
        end if;

        hr_utility.set_location ('fonm ?'||ben_manage_life_events.fonm,10);

        if ben_manage_life_events.fonm = 'Y' then
           hr_utility.set_location ('BDD_RACD '||l_package,10);
           hr_utility.set_location ('inside .. '||l_package,10);
	   ---Get the Corresponding Rate ID,Bug 8394662
           open c_get_rate(l_currepe_row.pgm_id,l_currepe_row.pl_id,l_currepe_row.opt_id,l_currepe_row.business_group_id);
	   fetch c_get_rate into l_get_rate;
	   close c_get_rate;
           ben_determine_date.rate_and_coverage_dates
          (p_cache_mode             => TRUE
          ,p_par_ptip_id            => l_currepe_row.ptip_id
          ,p_par_plip_id            => l_currepe_row.plip_id
          ,p_person_id              => l_currepe_row.person_id
          ,p_per_in_ler_id          => l_currepe_row.per_in_ler_id
          ,p_pgm_id                 => l_currepe_row.pgm_id
          ,p_pl_id                  => l_currepe_row.pl_id
          ,p_oipl_id                => l_currepe_row.oipl_id
          ,p_enrt_perd_id           => l_currepe_row.enrt_perd_id
          ,p_lee_rsn_id             => l_currepe_row.lee_rsn_id
          ,p_which_dates_cd         => 'R'
          ,p_date_mandatory_flag    => 'Y'
          ,p_compute_dates_flag     => 'Y'
          ,p_business_group_id      => l_currepe_row.business_group_id
          ,p_acty_base_rt_id        => l_get_rate.acty_base_rt_id ---null --99999 sent as formula context---------Bug 8394662
          ,p_effective_date         => l_effective_date
          ,p_lf_evt_ocrd_dt         => greatest
                          (nvl(p_lf_evt_ocrd_dt,l_currepe_row.prtn_strt_dt)
                          ,nvl(l_currepe_row.prtn_strt_dt,p_lf_evt_ocrd_dt))
          ,p_rt_strt_dt             => l_rt_strt_dt
          ,p_rt_strt_dt_cd          => l_rt_strt_dt_cd
          ,p_rt_strt_dt_rl          => l_rt_strt_dt_rl
          ,p_enrt_cvg_strt_dt       => l_dummy_date
          ,p_enrt_cvg_strt_dt_cd    => l_dummy_char
          ,p_enrt_cvg_strt_dt_rl    => l_dummy_num
          ,p_enrt_cvg_end_dt        => l_dummy_date
          ,p_enrt_cvg_end_dt_cd     => l_dummy_char
          ,p_enrt_cvg_end_dt_rl     => l_dummy_num
          ,p_rt_end_dt              => l_dummy_date
          ,p_rt_end_dt_cd           => l_dummy_char
          ,p_rt_end_dt_rl           => l_dummy_num
          );
          hr_utility.set_location ('Dn BDD_RACD '||l_package,10);
          --
          -- If previous rate start date and current date is different then
          -- clear the caches.
          --
          if nvl(ben_manage_life_events.g_fonm_rt_strt_dt, hr_api.g_sot) <>
             l_rt_strt_dt
          then
            --
            ben_use_cvg_rt_date.fonm_clear_down_cache;
            ben_manage_life_events.g_fonm_rt_strt_dt := l_rt_strt_dt;
            ben_manage_life_events.g_fonm_cvg_strt_dt := l_currepe_row.fonm_cvg_strt_dt;
            --
            -- Get person info
            --
            ben_person_object.get_object(
              p_person_id => p_person_id,
              p_rec       => l_per_row);
            --
            ben_person_object.get_object(
              p_person_id => p_person_id,
              p_rec       => l_asg_row);
            --
            IF l_asg_row.assignment_status_type_id IS NOT NULL THEN
              --
              ben_person_object.get_object(
                p_assignment_status_type_id => l_asg_row.assignment_status_type_id,
                p_rec                       => l_ast_row);
            --
            END IF;
            --
            ben_person_object.get_object(
              p_person_id => p_person_id,
              p_rec       => l_adr_row);
          end if;
          --
          ben_manage_life_events.g_fonm_rt_strt_dt := l_rt_strt_dt;
          ben_manage_life_events.g_fonm_cvg_strt_dt := l_currepe_row.fonm_cvg_strt_dt;
          l_effective_date := l_rt_strt_dt;

        end if;

        --
        -- -----------------------------------------------------------------
        -- note
        -- ----
        -- the use of the cursor loops has replaced the bulk fetch operation
        -- because of a ora-3113 error
        -- -----------------------------------------------------------------
        IF l_currepe_row.comp_lvl_cd = 'OIPL' THEN
          FOR c1 IN c_abr_oiplip(l_effective_date) LOOP
            l_acty_base_rt_id_table(l_acty_base_rt_id_table.COUNT + 1)     :=
                                                              c1.acty_base_rt_id;
            l_asn_on_enrt_flag_table(l_asn_on_enrt_flag_table.COUNT + 1)   :=
                                                             c1.asn_on_enrt_flag;
          END LOOP;
          IF l_acty_base_rt_id_table.COUNT = 0 THEN
            FOR c1 IN c_abr_oipl(l_effective_date) LOOP
              l_acty_base_rt_id_table(l_acty_base_rt_id_table.COUNT + 1)     :=
                                                              c1.acty_base_rt_id;
              l_asn_on_enrt_flag_table(l_asn_on_enrt_flag_table.COUNT + 1)   :=
                                                             c1.asn_on_enrt_flag;
            END LOOP;
          END IF;
          --START ENH
          IF l_acty_base_rt_id_table.COUNT = 0 THEN
            FOR c1 IN c_abr_opt(l_effective_date) LOOP
              l_acty_base_rt_id_table(l_acty_base_rt_id_table.COUNT + 1)     :=
                                                              c1.acty_base_rt_id;
              l_asn_on_enrt_flag_table(l_asn_on_enrt_flag_table.COUNT + 1)   :=
                                                             c1.asn_on_enrt_flag;
            END LOOP;
          END IF;
          --END ENH
        ELSIF l_currepe_row.comp_lvl_cd IN ('PLAN', 'PLANFC', 'PLANIMP') THEN
          FOR c1 IN c_abr_plip(l_effective_date) LOOP
            l_acty_base_rt_id_table(l_acty_base_rt_id_table.COUNT + 1)     :=
                                                              c1.acty_base_rt_id;
            l_asn_on_enrt_flag_table(l_asn_on_enrt_flag_table.COUNT + 1)   :=
                                                             c1.asn_on_enrt_flag;
          END LOOP;
          IF l_acty_base_rt_id_table.COUNT = 0 THEN
            FOR c1 IN c_abr_pl(l_effective_date) LOOP
              l_acty_base_rt_id_table(l_acty_base_rt_id_table.COUNT + 1)     :=
                                                              c1.acty_base_rt_id;
              l_asn_on_enrt_flag_table(l_asn_on_enrt_flag_table.COUNT + 1)   :=
                                                             c1.asn_on_enrt_flag;
            END LOOP;
          END IF;
        ELSIF l_currepe_row.comp_lvl_cd = 'PGM' THEN
          FOR c1 IN c_abr_pgm(l_effective_date) LOOP
            l_acty_base_rt_id_table(l_acty_base_rt_id_table.COUNT + 1)     :=
                                                              c1.acty_base_rt_id;
            l_asn_on_enrt_flag_table(l_asn_on_enrt_flag_table.COUNT + 1)   :=
                                                             c1.asn_on_enrt_flag;
          END LOOP;
        ELSIF l_currepe_row.comp_lvl_cd = 'PTIP' THEN
          FOR c1 IN c_abr_ptip(l_effective_date) LOOP
            l_acty_base_rt_id_table(l_acty_base_rt_id_table.COUNT + 1)     :=
                                                              c1.acty_base_rt_id;
            l_asn_on_enrt_flag_table(l_asn_on_enrt_flag_table.COUNT + 1)   :=
                                                             c1.asn_on_enrt_flag;
          END LOOP;
        ELSIF l_currepe_row.comp_lvl_cd = 'CPTIP' THEN
          FOR c1 IN c_abr_cmbn_ptip(l_effective_date) LOOP
            l_acty_base_rt_id_table(l_acty_base_rt_id_table.COUNT + 1)     :=
                                                              c1.acty_base_rt_id;
            l_asn_on_enrt_flag_table(l_asn_on_enrt_flag_table.COUNT + 1)   :=
                                                             c1.asn_on_enrt_flag;
          END LOOP;
        ELSIF l_currepe_row.comp_lvl_cd = 'PLIP' THEN
          FOR c1 IN c_abr_flx_plip(l_effective_date) LOOP
            l_acty_base_rt_id_table(l_acty_base_rt_id_table.COUNT + 1)     :=
                                                              c1.acty_base_rt_id;
            l_asn_on_enrt_flag_table(l_asn_on_enrt_flag_table.COUNT + 1)   :=
                                                             c1.asn_on_enrt_flag;
          END LOOP;
        ELSIF l_currepe_row.comp_lvl_cd = 'CPLIP' THEN
          FOR c1 IN c_abr_cmbn_plip(l_effective_date) LOOP
            l_acty_base_rt_id_table(l_acty_base_rt_id_table.COUNT + 1)     :=
                                                              c1.acty_base_rt_id;
            l_asn_on_enrt_flag_table(l_asn_on_enrt_flag_table.COUNT + 1)   :=
                                                             c1.asn_on_enrt_flag;
          END LOOP;
        ELSIF l_currepe_row.comp_lvl_cd = 'OIPLIP' THEN
          FOR c1 IN c_abr_flx_oiplip(l_effective_date) LOOP
            l_acty_base_rt_id_table(l_acty_base_rt_id_table.COUNT + 1)     :=
                                                              c1.acty_base_rt_id;
            l_asn_on_enrt_flag_table(l_asn_on_enrt_flag_table.COUNT + 1)   :=
                                                             c1.asn_on_enrt_flag;
          END LOOP;
        ELSIF l_currepe_row.comp_lvl_cd = 'CPTIPOPT' THEN
          FOR c1 IN c_abr_cmbn_ptip_opt(l_effective_date) LOOP
            l_acty_base_rt_id_table(l_acty_base_rt_id_table.COUNT + 1)     :=
                                                              c1.acty_base_rt_id;
            l_asn_on_enrt_flag_table(l_asn_on_enrt_flag_table.COUNT + 1)   :=
                                                             c1.asn_on_enrt_flag;
          END LOOP;
        ELSE
          if g_debug then
            hr_utility.set_location('BEN_91553_BENRATES_UNKN_COMP ', 10);
          end if;
          fnd_message.set_name('BEN', 'BEN_91553_BENRATES_UNKN_COMP');
          fnd_message.set_token('PACKAGE', l_package);
          fnd_message.set_token('PERSON_ID', TO_CHAR(l_currepe_row.person_id));
          fnd_message.set_token(
            'ELIG_PER_ELCTBL_CHC_ID',
            TO_CHAR(l_currepe_row.elig_per_elctbl_chc_id));
          fnd_message.set_token('PGM_ID', TO_CHAR(l_currepe_row.pgm_id));
          fnd_message.set_token('PL_ID', TO_CHAR(l_currepe_row.pl_id));
          fnd_message.set_token('OIPL_ID', TO_CHAR(l_currepe_row.oipl_id));
          fnd_message.set_token('PLIP_ID', TO_CHAR(l_currepe_row.plip_id));
          fnd_message.set_token('PTIP_ID', TO_CHAR(l_currepe_row.ptip_id));
          fnd_message.set_token('OIPLIP_ID', TO_CHAR(l_currepe_row.oiplip_id));
          fnd_message.set_token('CMBN_PLIP_ID', TO_CHAR(l_currepe_row.cmbn_plip_id));
          fnd_message.set_token('CMBN_PTIP_ID', TO_CHAR(l_currepe_row.cmbn_ptip_id));
          fnd_message.set_token(
            'CMBN_PTIP_OPT_ID',
            TO_CHAR(l_currepe_row.cmbn_ptip_opt_id));
          fnd_message.raise_error;
        END IF;
        if g_debug then
          hr_utility.set_location('Call ben_rates ' || l_package, 10);
        end if;
        -- call ben_rates providing at least 1 row exists
        IF    l_acty_base_rt_id_table.COUNT > 0
           OR l_asn_on_enrt_flag_table.COUNT > 0 THEN
          --
          ben_rates(
            p_currepe_row            => l_currepe_row,
            p_per_row                => l_per_row,
            p_asg_row                => l_asg_row,
            p_ast_row                => l_ast_row,
            p_adr_row                => l_adr_row,
            p_person_id              => l_currepe_row.person_id,
            p_pgm_id                 => l_currepe_row.pgm_id,
            p_pl_id                  => l_currepe_row.pl_id,
            p_oipl_id                => l_currepe_row.oipl_id,
            p_elig_per_elctbl_chc_id => l_elig_per_elctbl_chc_id,
            p_enrt_bnft_id           => l_currepe_row.enrt_bnft_id,
            p_acty_base_rt_id_table  => l_acty_base_rt_id_table,
            p_asn_on_enrt_flag_table => l_asn_on_enrt_flag_table,
            p_effective_date         => p_effective_date,
            p_lf_evt_ocrd_dt         => p_lf_evt_ocrd_dt,
            p_perform_rounding_flg   => TRUE,
            p_business_group_id      => l_currepe_row.business_group_id,
            p_dflt_flag              => l_currepe_row.dflt_flag,
            p_ctfn_rqd_flag          => l_currepe_row.ctfn_rqd_flag,
            p_mode                   => p_mode);
          --
        ELSE
          --
          -- GLOBALCWB : even if group plan rates are not defined still need to
          -- write the data into person groups table.
          --
          if nvl(p_mode, 'X') = 'W' then
             --
             --BUG 5148387 Need to get Benefit Assignment is this is null
             IF l_asg_row.assignment_id IS NULL THEN
               ben_person_object.get_benass_object(
                 p_person_id        => p_person_id,
                 p_rec              => l_asg_benass_row
                );
             END IF;
             --
             ben_manage_cwb_life_events.g_cwb_person_groups_rec
                 := ben_manage_cwb_life_events.g_cwb_person_groups_rec_temp;
             ben_manage_cwb_life_events.g_cwb_person_rates_rec
                 := ben_manage_cwb_life_events.g_cwb_person_rates_rec_temp;
             ben_manage_cwb_life_events.populate_cwb_rates(
                 --
                 -- Columns needed for ben_cwb_person_rates
                 --
                 p_person_id        => p_person_id
                ,p_pl_id            => l_currepe_row.pl_id
                ,p_oipl_id          => l_currepe_row.oipl_id
                ,p_opt_id           => l_currepe_row.opt_id
                ,p_assignment_id    => NVL(l_asg_row.assignment_id,l_asg_benass_row.assignment_id)
                ,p_elig_flag        => null -- 9999 it should come from g_curr_epe_rec
                ,p_inelig_rsn_cd    => null -- 9999 it should come from g_curr_epe_rec          --
                -- Columns needed by BEN_CWB_PERSON_GROUPS
                --
                ,p_due_dt           => null
                ,p_access_cd        => null -- passed inside the poppulate_cwb_rates
                ,p_elig_per_elctbl_chc_id => l_elig_per_elctbl_chc_id
                -- ,p_no_person_rates  => 'Y' -- Only create the group rates.
             );
             --
          end if;
          --
        END IF;
       --
       ELSE -- This is for suspended pen or pending workflow epe records
        --
        if g_debug then
          hr_utility.set_location( ' l_currepe_row.elig_per_elctbl_chc_id'||l_currepe_row.elig_per_elctbl_chc_id , 15);
          hr_utility.set_location( 'Suspended pen or in_pndg_wkflow_flag is Y ' ,15);
          hr_utility.set_location('Leaving ' || l_package, 10);
        end if;
        --
        null ;
        --
       END IF;
       --
      END LOOP;
      if g_debug then
        hr_utility.set_location('Leaving ' || l_package, 10);
      end if;
      --
    end if;
    --
    -- Clear epe context row
    --
    ben_epe_cache.init_context_pileperow;
    --
/*
    ben_distribute_rates.clear_down_cache;
    --
*/
  END main;
--
END ben_determine_rates;

/
