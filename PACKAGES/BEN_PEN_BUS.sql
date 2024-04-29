--------------------------------------------------------
--  DDL for Package BEN_PEN_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PEN_BUS" AUTHID CURRENT_USER as
/* $Header: bepenrhi.pkh 120.1.12010000.1 2008/07/29 12:47:02 appldev ship $ */
  --
  -- MH - Split union cursor g_c1 into g_enrolled and g_epenotenrolled to
  -- improve scalability.
  --
  cursor g_enrolled
    (c_effective_date date
    ,c_business_group_id  number
    ,c_person_id number
    ,c_pgm_id number
    ,c_include_erl  varchar2
    )
  is
    select pen.pgm_id,
           pen.ptip_id,
           pen.pl_typ_id,
           /*Bug#: 3255596: Fetching plip_id from CPP record
           when plip_id is null in EPE record*/
           NVL(epe.plip_id, cpp.plip_id) plip_id,
           /* End Bug#: 3255596: change */
           pen.pl_id,
           pen.oipl_id,
           pen.enrt_cvg_strt_dt,
           pen.enrt_cvg_thru_dt,
           pen.prtt_enrt_rslt_id,
           pen.RPLCS_SSPNDD_RSLT_ID,
           pen.SSPNDD_FLAG,
           'N' interim_flag,
           pen.person_id,
           0 Calc_interm,
           nvl(pen.bnft_amt,0) bnft_amt,
           pen.uom,
           epe.elig_per_elctbl_chc_id,
           epe.MUST_ENRL_ANTHR_PL_ID,
           'N' dpnt_cvd_by_othr_apls_flag,
           -9999999999999999999999999999999999999 opt_id
    from ben_prtt_enrt_rslt_f pen,
         ben_elig_per_elctbl_chc epe,
		/*Bug#: 3255596: Fetching plip_id from CPP record
		when plip_id is null in EPE record*/
         ben_plip_f cpp
        /* End Bug#: 3255596: change */
/*
,
         ben_oipl_f cop,
         ben_pl_f pln
*/
    where pen.person_id = c_person_id
    and   pen.prtt_enrt_rslt_stat_cd is null
    and   nvl(pen.pgm_id,-999999) = c_pgm_id
       /*
          Bug 5425 : Following 2 lines are commented as enrollment
          which are created in future due to benmngle run in future
          will not be picked up. Also added check on eef = eot
       and p_effective_date between
            pen.effective_start_date and pen.effective_end_date -1
       */
    and pen.effective_end_date = hr_api.g_eot
   -- 2159253 for enforcing minimum limitation - need to remove comp. objects ending in future
   -- and pen.enrt_cvg_thru_dt   >= c_effective_date
    --Bug 4361013 fix need to get the ended coverage also in case of
    --overriden enrollments.
    and ( pen.enrt_cvg_thru_dt   =  hr_api.g_eot or
          (pen.enrt_cvg_thru_dt   >= c_effective_date and nvl(pen.enrt_ovridn_flag,'N') = 'Y'))
    and pen.effective_end_date >= pen.enrt_cvg_thru_dt
    -- Bug 2677804 Why do we need to exclude this.
    -- If a participant intinues in the same enrollment
    -- the pen contains this info also .
    --  and (pen.ENRT_OVRID_THRU_DT is NULL
    --      or pen.ENRT_OVRID_THRU_DT < c_effective_date)
    and pen.prtt_enrt_rslt_id = epe.prtt_enrt_rslt_id (+)
    and pen.per_in_ler_id     = epe.per_in_ler_id (+)
    and pen.comp_lvl_cd not in ('PLANFC','PLANIMP')
    and (epe.per_in_ler_id is null or
         exists (select null
                 from   ben_per_in_ler pil
                 where  pil.per_in_ler_id = epe.per_in_ler_id
                   and  pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT'))
        )
   /*Bug#: 3255596: Fetching plip_id from CPP record
   when plip_id is null in EPE record*/
    and nvl(cpp.pgm_id(+),-999999) = c_pgm_id
    and cpp.pl_id(+) = pen.pl_id
    and cpp.business_group_id(+) = c_business_group_id
    and c_effective_date between cpp.effective_start_date(+) and cpp.effective_end_date(+)
  /* End Bug#: 3255596: change */
/*
    and pen.oipl_id           = cop.oipl_id (+)
    and c_effective_date
      between cop.effective_start_date (+) and cop.effective_end_date (+)
    and pen.pl_id = pln.pl_id
    and c_effective_date
      between pln.effective_start_date and pln.effective_end_date
*/
   and (c_include_erl = 'Y' or
        not exists (select null
                    from ben_enrt_bnft enb
                    where pen.prtt_enrt_rslt_id = enb.prtt_enrt_rslt_id
                    and enb.cvg_mlt_cd = 'ERL'))
    order by 1,2,3,4,5,6,7;
  --
  cursor g_epenotenrolled
    (c_effective_date date
    ,c_business_group_id  number
    ,c_person_id number
    ,c_pgm_id number
    )
  is
    --
    -- Added union (below) to pick up choices which are not enrolled in
    -- so that we can check minimums when not enrolled in anything.
    -- jcarpent 13-jul-1999
    -- added epe.pgm_id check
    -- jcarpent 11-oct-1999
    select distinct
           epe.pgm_id,
           epe.ptip_id,
           epe.pl_typ_id,
           epe.plip_id,
           epe.pl_id,
           epe.oipl_id,
           pen.enrt_cvg_strt_dt,
           pen.enrt_cvg_thru_dt,
           pen.prtt_enrt_rslt_id,
           pen.RPLCS_SSPNDD_RSLT_ID,
           pen.SSPNDD_FLAG,
           'N' interim_flag,
           pil.person_id,
           0 Calc_interm,
           nvl(pen.bnft_amt,0) bnft_amt,
           pen.uom,
           epe.elig_per_elctbl_chc_id,
           epe.MUST_ENRL_ANTHR_PL_ID,
           'N' dpnt_cvd_by_othr_apls_flag,
           -9999999999999999999999999999999999999 opt_id
/*
           cop.opt_id
*/
     from ben_prtt_enrt_rslt_f pen,
          ben_elig_per_elctbl_chc epe,
          ben_pil_elctbl_chc_popl pel,
/*
          ben_oipl_f              cop,
*/
          ben_per_in_ler pil
     where pil.person_id = c_person_id
       and pil.per_in_ler_stat_cd = 'STRTD'
       and epe.per_in_ler_id = pil.per_in_ler_id
       and epe.pil_elctbl_chc_popl_id = pel.pil_elctbl_chc_popl_id
       and (pel.auto_asnd_dt is not null OR
            pel.dflt_asnd_dt is not null OR
            pel.elcns_made_dt is not null)
       and nvl(epe.pgm_id,-999999) = c_pgm_id
       and c_effective_date between
            pen.effective_start_date(+) and pen.effective_end_date(+) -1
       and pen.effective_end_date(+) >= pen.enrt_cvg_strt_dt(+)
       and pen.enrt_cvg_thru_dt (+) >= c_effective_date
       and pen.prtt_enrt_rslt_stat_cd(+) is null
       --
       --  nvl allows the null condition to be outer joined
       -- Bug 2677804 Why do we need to exclude this.
       -- If a participant intinues in the same enrollment
       -- the pen contains this info also .
       -- and nvl(pen.ENRT_OVRID_THRU_DT(+),c_effective_date-1)
       --     < c_effective_date
       and pen.prtt_enrt_rslt_id(+) = epe.prtt_enrt_rslt_id
       and epe.comp_lvl_cd not in ('PLANFC','PLANIMP')
       --
       -- make sure enrt does not exist.
       --
       -- Bug No. 6454197 Added code to enforce limitation for enrollment at plantype
       and (pen.prtt_enrt_rslt_id is null
        or (pen.prtt_enrt_rslt_id is not null
       and pen.enrt_cvg_thru_dt <> hr_api.g_eot))
/*
       and epe.oipl_id = cop.oipl_id (+)
       and c_effective_date between
               cop.effective_start_date (+) and cop.effective_end_date (+)
*/
    order by 1,2,3,4,5,6,7;
    --
/*
  cursor g_c1
    (p_effective_date date
    ,p_business_group_id  number
    ,p_person_id number
    ,p_pgm_id number
    )
  is
    select pen.pgm_id,
           pen.ptip_id,
           pen.pl_typ_id,
           epe.plip_id,
           pen.pl_id,
           pen.oipl_id,
           pen.enrt_cvg_strt_dt,
           pen.enrt_cvg_thru_dt,
           pen.prtt_enrt_rslt_id,
           pen.RPLCS_SSPNDD_RSLT_ID,
           pen.SSPNDD_FLAG,
           'N' interim_flag,
           pen.person_id,
           0 Calc_interm,
           nvl(pen.bnft_amt,0) bnft_amt,
           pen.uom,
           epe.elig_per_elctbl_chc_id,
           epe.MUST_ENRL_ANTHR_PL_ID,
           pln.dpnt_cvd_by_othr_apls_flag,
           cop.opt_id
      from ben_prtt_enrt_rslt_f pen,
           ben_elig_per_elctbl_chc epe,
           ben_oipl_f cop,
           ben_pl_f pln
     where pen.person_id = p_person_id
       and pen.prtt_enrt_rslt_stat_cd is null
       and nvl(pen.pgm_id,-999999) = nvl(p_pgm_id, -999999)
*/
       /*
          Bug 5425 : Following 2 lines are commented as enrollment
          which are created in future due to benmngle run in future
          will not be picked up. Also added check on eef = eot
       and p_effective_date between
            pen.effective_start_date and pen.effective_end_date -1
       */
/*
       and pen.effective_end_date = hr_api.g_eot
       and pen.enrt_cvg_thru_dt >= p_effective_date
       and pen.effective_end_date >= pen.enrt_cvg_thru_dt
       and (pen.ENRT_OVRID_THRU_DT is NULL
            or pen.ENRT_OVRID_THRU_DT < p_effective_date)
       and pen.prtt_enrt_rslt_id = epe.prtt_enrt_rslt_id (+)
       and pen.per_in_ler_id = epe.per_in_ler_id (+)
       and pen.oipl_id = cop.oipl_id (+)
       and p_effective_date between
               cop.effective_start_date (+) and cop.effective_end_date (+)
       and pen.comp_lvl_cd not in ('PLANFC','PLANIMP')
       and (epe.per_in_ler_id is null or
            exists (select null
                    from   ben_per_in_ler pil
                    where  pil.per_in_ler_id = epe.per_in_ler_id
                      and  pil.business_group_id = epe.business_group_id
                      and  pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT')))
       and pen.pl_id = pln.pl_id
       and p_effective_date between
           pln.effective_start_date and pln.effective_end_date
    UNION
    --
    -- Added union (below) to pick up choices which are not enrolled in
    -- so that we can check minimums when not enrolled in anything.
    -- jcarpent 13-jul-1999
    -- added epe.pgm_id check
    -- jcarpent 11-oct-1999
    select distinct
           epe.pgm_id,
           epe.ptip_id,
           epe.pl_typ_id,
           epe.plip_id,
           epe.pl_id,
           epe.oipl_id,
           pen.enrt_cvg_strt_dt,
           pen.enrt_cvg_thru_dt,
           pen.prtt_enrt_rslt_id,
           pen.RPLCS_SSPNDD_RSLT_ID,
           pen.SSPNDD_FLAG,
           'N' interim_flag,
           pil.person_id,
           0 Calc_interm,
           nvl(pen.bnft_amt,0) bnft_amt,
           pen.uom,
           epe.elig_per_elctbl_chc_id,
           epe.MUST_ENRL_ANTHR_PL_ID,
           'N' dpnt_cvd_by_othr_apls_flag,
           cop.opt_id
      from ben_prtt_enrt_rslt_f pen,
           ben_elig_per_elctbl_chc epe,
           ben_oipl_f              cop,
           ben_per_in_ler pil
     where pil.person_id = p_person_id
       and pil.per_in_ler_stat_cd = 'STRTD'
       and epe.per_in_ler_id = pil.per_in_ler_id
       and nvl(epe.pgm_id,-999999) = nvl(p_pgm_id, -999999)
       and p_effective_date between
            pen.effective_start_date(+) and pen.effective_end_date(+) -1
       and pen.effective_end_date(+) >= pen.enrt_cvg_strt_dt(+)
       and pen.enrt_cvg_thru_dt (+) >= p_effective_date
       and pen.prtt_enrt_rslt_stat_cd(+) is null
       and nvl(pen.ENRT_OVRID_THRU_DT(+),p_effective_date-1)
           < p_effective_date  -- nvl allows the null condition to be
                               -- outer joined
       and pen.prtt_enrt_rslt_id(+) = epe.prtt_enrt_rslt_id
       and epe.comp_lvl_cd not in ('PLANFC','PLANIMP')
       and pen.prtt_enrt_rslt_id is null -- make sure enrt does not exist.
       and epe.oipl_id = cop.oipl_id (+)
       and p_effective_date between
               cop.effective_start_date (+) and cop.effective_end_date (+)
    order by 1,2,3,4,5,6,7;
    --
*/
--
type enrt_table is table of g_enrolled%rowtype index by binary_integer;
--
g_enrt_tbl 	enrt_table;
g_comp_obj_cnt 	integer := 0;
--
cursor g_c_pl (p_effective_date     date
              ,p_business_group_id  ben_pl_f.business_group_id%type
              ,p_pl_id 	            ben_pl_f.pl_typ_id%type
              ) is
    select pl_id,
           name,
           pl_typ_id,
           -999999999999999  ptip_id,
           0 interim_flag,
           mn_opts_rqd_num,
           mn_cvg_rl, mn_cvg_rqd_amt,
           mx_opts_alwd_num,
           mx_cvg_alwd_amt, mx_cvg_rl,
           mx_cvg_incr_alwd_amt,
           mx_cvg_wcfn_amt,
           mx_cvg_incr_wcf_alwd_amt,
           0 tot_opt_enrld,
           0.0 tot_cvg_amt,
           0.0 prev_cvg_amt,
           0.0 tot_cvg_amt_no_interim
      from ben_pl_f
     where pl_id = p_pl_id and
           business_group_id = p_business_group_id and
           p_effective_date between
		      effective_start_date and effective_end_date
           ;
type pl_table is table of g_c_pl%rowtype index by binary_integer;
g_pl_tbl 	pl_table;
g_pl_cnt 	integer := 0;
cursor g_c_pl_typ (p_effective_date 	date,
	   	   p_business_group_id  ben_pl_typ_f.business_group_id%type,
	   	   p_pl_typ_id 		ben_pl_typ_f.pl_typ_id%type) is
    select pl_typ_id, name,
           mx_enrl_alwd_num,
           mn_enrl_rqd_num,
           0 tot_pl_enrld,
           0.0 tot_cvg_amt,
           'N' dpnt_cvd_by_othr_apls_flag,
           0.0 tot_cvg_amt_no_interim
      from ben_pl_typ_f
     where pl_typ_id = p_pl_typ_id
       and business_group_id = p_business_group_id
       and p_effective_date between
               effective_start_date and effective_end_date
           ;
type pl_typ_table is table of g_c_pl_typ%rowtype index by binary_integer;
g_pl_typ_tbl 	pl_typ_table;
g_pl_typ_cnt 	integer := 0;
cursor g_c_ptip(p_effective_date     date,
                p_business_group_id  ben_ptip_f.business_group_id%type,
                p_ptip_id            ben_ptip_f.ptip_id%type
               ) is
    select ptip.ptip_id,
           ptip.pgm_id,
           ptip.pl_typ_id,
           ptip.MX_ENRD_ALWD_OVRID_NUM,
           ptip.no_mx_pl_typ_ovrid_flag,
           ptip.MN_ENRD_RQD_OVRID_NUM,
           ptip.no_mn_pl_typ_overid_flag,
           ptip.MX_CVG_ALWD_AMT,
           ptip.SBJ_TO_SPS_LF_INS_MX_FLAG,
           ptip.SBJ_TO_DPNT_LF_INS_MX_FLAG,
           ptip.USE_TO_SUM_EE_LF_INS_FLAG,
           ptip.COORD_CVG_FOR_ALL_PLS_FLAG,
           0 tot_pl_enrld,
           0.0 tot_cvg_amt,
           plt.name,
           'N' dpnt_cvd_by_othr_apls_flag,
           0.0 tot_cvg_amt_no_interim
      from ben_ptip_f ptip, ben_pl_typ_f plt
     where ptip.ptip_id = p_ptip_id
       and ptip.pl_typ_id = plt.pl_typ_id
       and ptip.business_group_id = p_business_group_id
       and p_effective_date between
               ptip.effective_start_date and ptip.effective_end_date
       and p_effective_date between
               plt.effective_start_date and plt.effective_end_date
           ;
type ptip_table is table of g_c_ptip%rowtype index by binary_integer;
g_ptip_tbl            ptip_table;
g_ptip_cnt            integer := 0;
g_tot_ee_lf_ins_amt   number := 0; -- integer := 0;
g_tot_sps_lf_ins_amt  number := 0; -- integer := 0;
g_tot_dpnt_lf_ins_amt number := 0; -- integer := 0;

g_tot_ee_lf_ins_amt_no          number := 0;
g_tot_sps_lf_ins_amt_no         number := 0;
g_tot_dpnt_lf_ins_amt_no        number := 0;

g_mx_dpnt_pct_prtt_lf integer := 0;
g_mx_sps_pct_prtt_lf  integer := 0;
cursor g_c_pgm (p_effective_date     date,
                p_business_group_id  ben_pgm_f.business_group_id%type,
                p_pgm_id             ben_pgm_f.pgm_id%type
               ) is
    select pgm_id, name,
       	   MX_DPNT_PCT_PRTT_LF_AMT,
           MX_SPS_PCT_PRTT_LF_AMT,
           COORD_CVG_FOR_ALL_PLS_FLG
      from ben_pgm_f
     where pgm_id = p_pgm_id
       and business_group_id = p_business_group_id
       and p_effective_date between
               effective_start_date and effective_end_date
           ;
g_pgm_rec g_c_pgm%rowtype;
--
Procedure cache_enrt_info
  (p_effective_date    in     date
  ,p_business_group_id in     number
  ,p_person_id 	       in     number
  ,p_pgm_id            in     number
  ,p_assignment_id     in     number
  ,p_include_erl       in     varchar2 default  'N'
  );
--
--
--  ---------------------------------------------------------------------------
--  |---------------------< return_legislation_code >-------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Return the legislation code for a specific primary key value
--
--  Prerequisites:
--    The primary key identified by p_prtt_enrt_rslt_id already exists.
--
--  In Arguments:
--    p_prtt_enrt_rslt_id
--
--  Post Success:
--    If the value is found this function will return the values business
--    group legislation code.
--
--  Post Failure:
--    An error is raised if the value does not exist.
--
--  Access Status:
--    Internal Development Use Only.
--
function return_legislation_code
  (p_prtt_enrt_rslt_id in number) return varchar2;
--
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the execution of all insert business rules
--   validation.
--
-- Prerequisites:
--   This private procedure is called from ins procedure.
--
-- In Parameters:
--   A Pl/Sql record structre.
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If a business rules fails the error will not be handled by this procedure
--   unless explicity coded.
--
-- Developer Implementation Notes:
--   For insert, your business rules should be executed from this procedure and
--   should ideally (unless really necessary) just be straight procedure or
--   function calls. Try and avoid using conditional branching logic.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure insert_validate
	(p_rec                   in ben_pen_shd.g_rec_type,
	 p_effective_date        in date,
	 p_datetrack_mode        in varchar2,
	 p_validation_start_date in date,
	 p_validation_end_date	 in date);
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the execution of all update business rules
--   validation.
--
-- Prerequisites:
--   This private procedure is called from upd procedure.
--
-- In Parameters:
--   A Pl/Sql record structre.
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If a business rules fails the error will not be handled by this procedure
--   unless explicity coded.
--
-- Developer Implementation Notes:
--   For update, your business rules should be executed from this procedure and
--   should ideally (unless really necessary) just be straight procedure or
--   function calls. Try and avoid using conditional branching logic.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure update_validate
	(p_rec                   in ben_pen_shd.g_rec_type,
	 p_effective_date        in date,
	 p_datetrack_mode        in varchar2,
	 p_validation_start_date in date,
	 p_validation_end_date	 in date);
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the execution of all delete business rules
--   validation.
--
-- Prerequisites:
--   This private procedure is called from del procedure.
--
-- In Parameters:
--   A Pl/Sql record structre.
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If a business rules fails the error will not be handled by this procedure
--   unless explicity coded.
--
-- Developer Implementation Notes:
--   For delete, your business rules should be executed from this procedure and
--   should ideally (unless really necessary) just be straight procedure or
--   function calls. Try and avoid using conditional branching logic.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure delete_validate
	(p_rec 			         in ben_pen_shd.g_rec_type,
	 p_effective_date	     in date,
	 p_datetrack_mode	     in varchar2,
	 p_validation_start_date in date,
	 p_validation_end_date	 in date);
--
--
procedure multi_rows_edit
    (p_person_id               in number
    ,p_effective_date         in date
    ,p_business_group_id      in number
    ,p_pgm_id                 in number
    ,p_include_erl             in varchar2  default 'N'
    );
--
Procedure manage_per_type_usages
    (p_person_id           in	number
    ,p_business_group_id   in	number
    ,p_effective_date      in	date
    );
--
end ben_pen_bus;

/
