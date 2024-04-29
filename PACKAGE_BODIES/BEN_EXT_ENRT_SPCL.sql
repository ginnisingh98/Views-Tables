--------------------------------------------------------
--  DDL for Package Body BEN_EXT_ENRT_SPCL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_EXT_ENRT_SPCL" as
/* $Header: benxensp.pkb 120.2 2006/06/15 23:04:37 tjesumic ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_ext_enrt_spcl.';  -- Global package name
--
--
-- procedure to initialize globals - May, 99
-- ----------------------------------------------------------------------------
-- |--------------------< initialize_globals >--------------------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE initialize_globals IS
  --
  l_proc             varchar2(72) := g_package||'initialize_globals';
  --
Begin
  --
   hr_utility.set_location('Entering'||l_proc, 5);
   --
     ben_ext_person.g_enrt_prtt_enrt_rslt_id   := null;
     ben_ext_person.g_enrt_pl_name             := null;
     ben_ext_person.g_enrt_opt_name            := null;
     ben_ext_person.g_enrt_pl_id               := null;
     ben_ext_person.g_enrt_opt_id              := null;
     ben_ext_person.g_enrt_cvg_strt_dt         := null;
     ben_ext_person.g_enrt_cvg_thru_dt         := null;
     ben_ext_person.g_enrt_orgcovg_strdt       := null;
     ben_ext_person.g_enrt_prt_orgcovg_strdt   := null;
     ben_ext_person.g_enrt_cvg_amt             := null;
     ben_ext_person.g_enrt_pgm_id              := null;
     ben_ext_person.g_enrt_benefit_order_num   := null;
     ben_ext_person.g_enrt_method              := null;
     ben_ext_person.g_enrt_ovrd_flag           := null;
     ben_ext_person.g_enrt_ovrd_thru_dt        := null;
     ben_ext_person.g_enrt_ovrd_reason         := null;
     ben_ext_person.g_enrt_suspended_flag      := null;
     ben_ext_person.g_enrt_rslt_effct_strdt    := null;
     ben_ext_person.g_enrt_pgm_name            := null;
     ben_ext_person.g_enrt_pl_typ_id           := null;
     ben_ext_person.g_enrt_pl_typ_name         := null;
     ben_ext_person.g_enrt_attr_1              := null;
     ben_ext_person.g_enrt_attr_2              := null;
     ben_ext_person.g_enrt_attr_3              := null;
     ben_ext_person.g_enrt_attr_4              := null;
     ben_ext_person.g_enrt_attr_5              := null;
     ben_ext_person.g_enrt_attr_6              := null;
     ben_ext_person.g_enrt_attr_7              := null;
     ben_ext_person.g_enrt_attr_8              := null;
     ben_ext_person.g_enrt_attr_9              := null;
     ben_ext_person.g_enrt_attr_10             := null;
     ben_ext_person.g_pl_attr_1                := null;
     ben_ext_person.g_pl_attr_2                := null;
     ben_ext_person.g_pl_attr_3                := null;
     ben_ext_person.g_pl_attr_4                := null;
     ben_ext_person.g_pl_attr_5                := null;
     ben_ext_person.g_pl_attr_6                := null;
     ben_ext_person.g_pl_attr_7                := null;
     ben_ext_person.g_pl_attr_8                := null;
     ben_ext_person.g_pl_attr_9                := null;
     ben_ext_person.g_pl_attr_10               := null;
     ben_ext_person.g_pgm_attr_1               := null;
     ben_ext_person.g_pgm_attr_2               := null;
     ben_ext_person.g_pgm_attr_3               := null;
     ben_ext_person.g_pgm_attr_4               := null;
     ben_ext_person.g_pgm_attr_5               := null;
     ben_ext_person.g_pgm_attr_6               := null;
     ben_ext_person.g_pgm_attr_7               := null;
     ben_ext_person.g_pgm_attr_8               := null;
     ben_ext_person.g_pgm_attr_9               := null;
     ben_ext_person.g_pgm_attr_10              := null;
     ben_ext_person.g_ptp_attr_1               := null;
     ben_ext_person.g_ptp_attr_2               := null;
     ben_ext_person.g_ptp_attr_3               := null;
     ben_ext_person.g_ptp_attr_4               := null;
     ben_ext_person.g_ptp_attr_5               := null;
     ben_ext_person.g_ptp_attr_6               := null;
     ben_ext_person.g_ptp_attr_7               := null;
     ben_ext_person.g_ptp_attr_8               := null;
     ben_ext_person.g_ptp_attr_9               := null;
     ben_ext_person.g_ptp_attr_10              := null;
     ben_ext_person.g_plip_attr_1              := null;
     ben_ext_person.g_plip_attr_2              := null;
     ben_ext_person.g_plip_attr_3              := null;
     ben_ext_person.g_plip_attr_4              := null;
     ben_ext_person.g_plip_attr_5              := null;
     ben_ext_person.g_plip_attr_6              := null;
     ben_ext_person.g_plip_attr_7              := null;
     ben_ext_person.g_plip_attr_8              := null;
     ben_ext_person.g_plip_attr_9              := null;
     ben_ext_person.g_plip_attr_10             := null;
     ben_ext_person.g_oipl_attr_1              := null;
     ben_ext_person.g_oipl_attr_2              := null;
     ben_ext_person.g_oipl_attr_3              := null;
     ben_ext_person.g_oipl_attr_4              := null;
     ben_ext_person.g_oipl_attr_5              := null;
     ben_ext_person.g_oipl_attr_6              := null;
     ben_ext_person.g_oipl_attr_7              := null;
     ben_ext_person.g_oipl_attr_8              := null;
     ben_ext_person.g_oipl_attr_9              := null;
     ben_ext_person.g_oipl_attr_10             := null;
     ben_ext_person.g_enrt_plcy_r_grp          := null;
     ben_ext_person.g_ppr_name                 := null;
     ben_ext_person.g_ppr_ident                := null;
     ben_ext_person.g_ppr_typ                  := null;
     ben_ext_person.g_ppr_strt_dt              := null;
     ben_ext_person.g_ppr_end_dt               := null;
     ben_ext_person.g_enrt_lfevt_name          := null;
     ben_ext_person.g_enrt_lfevt_status        := null;
     ben_ext_person.g_enrt_lfevt_note_dt       := null;
     ben_ext_person.g_enrt_lfevt_ocrd_dt       := null;
     ben_ext_person.g_dpnt_cvrd_dpnt_id        := null;
     --
   --
   hr_utility.set_location('Exiting'||l_proc, 15);
   --
End initialize_globals;
--
-- ----------------------------------------------------------------------------
-- |--------------------< main >----------------------------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE main
    (                        p_dpnt_person_id     in number,
                             p_prtt_person_id     in number,
                             p_ext_rslt_id        in number,
                             p_ext_file_id        in number,
                             p_data_typ_cd        in varchar2,
                             p_ext_typ_cd         in varchar2,
                             p_chg_evt_cd         in varchar2,
                             p_business_group_id  in number,
                             p_effective_date     in date) is
   --
   l_proc             varchar2(72) := g_package||'main';
   --
   l_include          varchar2(1) := 'Y';
   --
   cursor c_dpnt_enrt is
   select
         dpnt.elig_cvrd_dpnt_id   	 elig_cvrd_dpnt_id,
         enrt.prtt_enrt_rslt_id  	 prtt_enrt_rslt_id,
         enrt.pl_id              	 pl_id,
         enrt.oipl_id              	 oipl_id,
         enrt.orgnl_enrt_dt              orgn_strdt,
         dpnt.cvg_strt_dt        	 cvg_strt_dt,
         dpnt.cvg_thru_dt        	 cvg_thru_dt,
         enrt.bnft_amt           	 bnft_amt,
         enrt.pgm_id             	 pgm_id,
         enrt.bnft_ordr_num      	 bnft_order_num,
         enrt.enrt_mthd_cd       	 mthd_cd,
         enrt.enrt_ovridn_flag   	 ovridn_flag,
         enrt.enrt_ovrid_thru_dt 	 ovrid_thru_dt,
         enrt.enrt_ovrid_rsn_cd  	 ovrid_rsn_cd,
         enrt.sspndd_flag        	 sspndd_flag,
         enrt.effective_start_date       effct_strdt,
         enrt.last_update_date,
         enrt.prtt_enrt_rslt_stat_cd,
         enrt.per_in_ler_id,
         enrt.pen_attribute1,
         enrt.pen_attribute2,
         enrt.pen_attribute3,
         enrt.pen_attribute4,
         enrt.pen_attribute5,
         enrt.pen_attribute6,
         enrt.pen_attribute7,
         enrt.pen_attribute8,
         enrt.pen_attribute9,
         enrt.pen_attribute10,
         pl.pl_typ_id            	 pl_typ_id,
         pl.name                 	 pl_name,
         pl.pln_attribute1,
         pl.pln_attribute2,
         pl.pln_attribute3,
         pl.pln_attribute4,
         pl.pln_attribute5,
         pl.pln_attribute6,
         pl.pln_attribute7,
         pl.pln_attribute8,
         pl.pln_attribute9,
         pl.pln_attribute10,
         ptp.name                	 pl_typ_name,
         ptp.ptp_attribute1,
         ptp.ptp_attribute2,
         ptp.ptp_attribute3,
         ptp.ptp_attribute4,
         ptp.ptp_attribute5,
         ptp.ptp_attribute6,
         ptp.ptp_attribute7,
         ptp.ptp_attribute8,
         ptp.ptp_attribute9,
         ptp.ptp_attribute10,
         pil.per_in_ler_stat_cd,
         pil.lf_evt_ocrd_dt,
         pil.ntfn_dt,
         pil.ler_id,
         ler.name   ler_name
    from
         ben_elig_cvrd_dpnt_f  dpnt,
         ben_prtt_enrt_rslt_f  enrt,
         ben_pl_f              pl,
         ben_pl_typ_f          ptp,
         ben_per_in_ler        pil,
         ben_ler_f             ler
   Where
         dpnt.dpnt_person_id    = p_dpnt_person_id
     and enrt.person_id         = p_prtt_person_id
     and enrt.prtt_enrt_rslt_id = dpnt.prtt_enrt_rslt_id
     and p_effective_date between enrt.effective_start_date
         and enrt.effective_end_date
     and p_effective_date between dpnt.effective_start_date
         and dpnt.effective_end_date
     and enrt.pl_id  = pl.pl_id
     and pl.invk_flx_cr_pl_flag = 'N'
     and pl.imptd_incm_calc_cd is null
     and pl.invk_dcln_prtn_pl_flag = 'N'
     and p_effective_date between pl.effective_start_date
                              and pl.effective_end_date
     and pl.pl_typ_id = ptp.pl_typ_id
     and p_effective_date between ptp.effective_start_date
                              and ptp.effective_end_date
     and pil.per_in_ler_id=dpnt.per_in_ler_id
     and pil.ler_id = ler.ler_id
     and p_effective_date between ler.effective_start_date
         and ler.effective_end_date
     ;
   --
    cursor c_pgm_enrt (p_pgm_id number)  is
    select
         pgm.name                	 pgm_name,
         pgm.pgm_attribute1,
         pgm.pgm_attribute2,
         pgm.pgm_attribute3,
         pgm.pgm_attribute4,
         pgm.pgm_attribute5,
         pgm.pgm_attribute6,
         pgm.pgm_attribute7,
         pgm.pgm_attribute8,
         pgm.pgm_attribute9,
         pgm.pgm_attribute10
   from  ben_pgm_f             pgm
   where p_pgm_id = pgm.pgm_id
     and p_effective_date between pgm.effective_start_date
         and pgm.effective_end_date  ;


  cursor c_plip_enrt (p_pl_id  number ,
                      p_pgm_id number ) is
  select cpp.cpp_attribute1,
         cpp.cpp_attribute2,
         cpp.cpp_attribute3,
         cpp.cpp_attribute4,
         cpp.cpp_attribute5,
         cpp.cpp_attribute6,
         cpp.cpp_attribute7,
         cpp.cpp_attribute8,
         cpp.cpp_attribute9,
         cpp.cpp_attribute10
  from ben_plip_f        cpp
 where p_pl_id  = cpp.pl_id
   and p_pgm_id = cpp.pgm_id
   and p_effective_date between cpp.effective_start_date
       and cpp.effective_end_date
   ;

   --
cursor c_oipl_enrt (p_oipl_id number) is
    select
         opt.opt_id              	 opt_id,
         opt.name                	 opt_name,
         oipl.cop_attribute1,
         oipl.cop_attribute2,
         oipl.cop_attribute3,
         oipl.cop_attribute4,
         oipl.cop_attribute5,
         oipl.cop_attribute6,
         oipl.cop_attribute7,
         oipl.cop_attribute8,
         oipl.cop_attribute9,
         oipl.cop_attribute10
    from
         ben_oipl_f            oipl,
         ben_opt_f             opt
    where p_oipl_id = oipl.oipl_id
     and  p_effective_date between oipl.effective_start_date
          and oipl.effective_end_date
     and  opt.opt_id   = oipl.opt_id
     and p_effective_date between opt.effective_start_date
         and opt.effective_end_date
   ;

   cursor plcy_c (l_pl_id Number , l_asg_id number) is
   select ppl.plcy_r_grp
     from ben_popl_org_f ppl,
          per_all_assignments_f asg
    where pl_id = l_pl_id
      and plcy_r_grp is not null
      and asg.assignment_id = l_asg_id
      and ppl.organization_id = asg.organization_id
      and p_effective_date between ppl.effective_start_date
                             and ppl.effective_end_date
      and  p_effective_date between asg.effective_start_date
                             and asg.effective_end_date ;

--
  cursor c_dpnt_prmry_care_prvdr(p_elig_cvrd_dpnt_id  number) is
  SELECT name
        ,ext_ident
        ,prmry_care_prvdr_typ_cd
        ,effective_start_date
        ,effective_end_date
  FROM   ben_prmry_care_prvdr_f ppr
  WHERE  ppr.elig_cvrd_dpnt_id = p_elig_cvrd_dpnt_id
  AND    p_effective_date between ppr.effective_start_date
         and ppr.effective_end_date;
 --
  cursor c_prtt_asg is
  select assignment_id
  from  per_all_assignments_f asg
  where person_id  =  p_prtt_person_id
   and  p_effective_date between asg.effective_start_date
        and asg.effective_end_date
   and  asg.primary_flag = 'Y'  ;

  l_prtt_asg_id    number ;
--
  l_process varchar2(1) := 'Y';
--

   BEGIN
   --
   hr_utility.set_location('Entering'||l_proc, 5);
   --
   FOR dpnt_enrt IN c_dpnt_enrt LOOP
    -- initialize the globals - May, 99
    initialize_globals;
      --
     ben_ext_evaluate_inclusion.Evaluate_Benefit_Incl
                    (p_pl_id    => dpnt_enrt.pl_id,
                     p_sspndd_flag => dpnt_enrt.sspndd_flag,
                     p_enrt_cvg_strt_dt => dpnt_enrt.cvg_strt_dt,
                     p_enrt_cvg_thru_dt => dpnt_enrt.cvg_thru_dt,
                     p_prtt_enrt_rslt_stat_cd => dpnt_enrt.prtt_enrt_rslt_stat_cd,
                     p_enrt_mthd_cd     => dpnt_enrt.mthd_cd,
                     p_pgm_id =>  dpnt_enrt.pgm_id,
                     p_pl_typ_id    =>  dpnt_enrt.pl_typ_id,
                     p_last_update_date => dpnt_enrt.last_update_date,
                     p_ler_id    => dpnt_enrt.ler_id,
                     p_ntfn_dt      => dpnt_enrt.ntfn_dt,
                     p_lf_evt_ocrd_dt  => dpnt_enrt.lf_evt_ocrd_dt,
                     p_per_in_ler_stat_cd  => dpnt_enrt.per_in_ler_stat_cd,
                     p_per_in_ler_id    => dpnt_enrt.per_in_ler_id,
                     p_prtt_enrt_rslt_id => dpnt_enrt.prtt_enrt_rslt_id,
                     p_effective_date => p_effective_date,
                     p_include => l_include
                     );

     IF l_include = 'Y' THEN
       --
       -- assign enrollment info to global variables
       --
          ben_ext_person.g_enrt_prtt_enrt_rslt_id := dpnt_enrt.prtt_enrt_rslt_id ;
          ben_ext_person.g_dpnt_cvrd_dpnt_id      := dpnt_enrt.elig_cvrd_dpnt_id;
          ben_ext_person.g_enrt_pl_name        	  := dpnt_enrt.pl_name;
          ben_ext_person.g_enrt_pl_id           	:= dpnt_enrt.pl_id;
          ben_ext_person.g_enrt_prt_orgcovg_strdt := dpnt_enrt.orgn_strdt ;
          ben_ext_person.g_enrt_cvg_strt_dt     	:= dpnt_enrt.cvg_strt_dt;
          ben_ext_person.g_enrt_cvg_thru_dt	:= dpnt_enrt.cvg_thru_dt;
          ben_ext_person.g_enrt_cvg_amt    	:= dpnt_enrt.bnft_amt;
          ben_ext_person.g_enrt_pgm_id     	:= dpnt_enrt.pgm_id;
          ben_ext_person.g_enrt_benefit_order_num   := dpnt_enrt.bnft_order_num;
          ben_ext_person.g_enrt_method      := dpnt_enrt.mthd_cd;
          ben_ext_person.g_enrt_ovrd_flag   := dpnt_enrt.ovridn_flag;
          ben_ext_person.g_enrt_ovrd_thru_dt   := dpnt_enrt.ovrid_thru_dt;
          ben_ext_person.g_enrt_ovrd_reason := dpnt_enrt.ovrid_rsn_cd;
          ben_ext_person.g_enrt_suspended_flag := dpnt_enrt.sspndd_flag;
          ben_ext_person.g_enrt_rslt_effct_strdt := dpnt_enrt.effct_strdt;
          ben_ext_person.g_enrt_pl_typ_id        := dpnt_enrt.pl_typ_id;
          ben_ext_person.g_enrt_pl_typ_name      := dpnt_enrt.pl_typ_name;
          ben_ext_person.g_enrt_lfevt_name    := dpnt_enrt.ler_name;
          ben_ext_person.g_enrt_lfevt_status  := dpnt_enrt.per_in_ler_stat_cd;
          ben_ext_person.g_enrt_lfevt_note_dt := dpnt_enrt.ntfn_dt;
          ben_ext_person.g_enrt_lfevt_ocrd_dt := dpnt_enrt.lf_evt_ocrd_dt;
          ben_ext_person.g_enrt_attr_1      := dpnt_enrt.pen_attribute1;
          ben_ext_person.g_enrt_attr_2      := dpnt_enrt.pen_attribute2;
          ben_ext_person.g_enrt_attr_3      := dpnt_enrt.pen_attribute3;
          ben_ext_person.g_enrt_attr_4      := dpnt_enrt.pen_attribute4;
          ben_ext_person.g_enrt_attr_5      := dpnt_enrt.pen_attribute5;
          ben_ext_person.g_enrt_attr_6      := dpnt_enrt.pen_attribute6;
          ben_ext_person.g_enrt_attr_7      := dpnt_enrt.pen_attribute7;
          ben_ext_person.g_enrt_attr_8      := dpnt_enrt.pen_attribute8;
          ben_ext_person.g_enrt_attr_9      := dpnt_enrt.pen_attribute9;
          ben_ext_person.g_enrt_attr_10     := dpnt_enrt.pen_attribute10;
          ben_ext_person.g_pl_attr_1        := dpnt_enrt.pln_attribute1;
          ben_ext_person.g_pl_attr_2        := dpnt_enrt.pln_attribute2;
          ben_ext_person.g_pl_attr_3        := dpnt_enrt.pln_attribute3;
          ben_ext_person.g_pl_attr_4        := dpnt_enrt.pln_attribute4;
          ben_ext_person.g_pl_attr_5        := dpnt_enrt.pln_attribute5;
          ben_ext_person.g_pl_attr_6        := dpnt_enrt.pln_attribute6;
          ben_ext_person.g_pl_attr_7        := dpnt_enrt.pln_attribute7;
          ben_ext_person.g_pl_attr_8        := dpnt_enrt.pln_attribute8;
          ben_ext_person.g_pl_attr_9        := dpnt_enrt.pln_attribute9;
          ben_ext_person.g_pl_attr_10       := dpnt_enrt.pln_attribute10;
          ben_ext_person.g_ptp_attr_1       := dpnt_enrt.ptp_attribute1;
          ben_ext_person.g_ptp_attr_2       := dpnt_enrt.ptp_attribute2;
          ben_ext_person.g_ptp_attr_3       := dpnt_enrt.ptp_attribute3;
          ben_ext_person.g_ptp_attr_4       := dpnt_enrt.ptp_attribute4;
          ben_ext_person.g_ptp_attr_5       := dpnt_enrt.ptp_attribute5;
          ben_ext_person.g_ptp_attr_6       := dpnt_enrt.ptp_attribute6;
          ben_ext_person.g_ptp_attr_7       := dpnt_enrt.ptp_attribute7;
          ben_ext_person.g_ptp_attr_8       := dpnt_enrt.ptp_attribute8;
          ben_ext_person.g_ptp_attr_9       := dpnt_enrt.ptp_attribute9;
          ben_ext_person.g_ptp_attr_10      := dpnt_enrt.ptp_attribute10;
         --

         --
         if dpnt_enrt.pgm_id is not null then
            open c_pgm_enrt (dpnt_enrt.pgm_id)  ;
            fetch c_pgm_enrt into
                   ben_ext_person.g_enrt_pgm_name
                  ,ben_ext_person.g_pgm_attr_1
                  ,ben_ext_person.g_pgm_attr_2
                  ,ben_ext_person.g_pgm_attr_3
                  ,ben_ext_person.g_pgm_attr_4
                  ,ben_ext_person.g_pgm_attr_5
                  ,ben_ext_person.g_pgm_attr_6
                  ,ben_ext_person.g_pgm_attr_7
                  ,ben_ext_person.g_pgm_attr_8
                  ,ben_ext_person.g_pgm_attr_9
                  ,ben_ext_person.g_pgm_attr_10
            ;
            close c_pgm_enrt ;
         end if ;

         if dpnt_enrt.pgm_id is not null and dpnt_enrt.pl_id is not null then
            open c_plip_enrt (dpnt_enrt.pl_id   ,
                              dpnt_enrt.pgm_id ) ;
            fetch c_plip_enrt into
                   ben_ext_person.g_plip_attr_1
                  ,ben_ext_person.g_plip_attr_2
                  ,ben_ext_person.g_plip_attr_3
                  ,ben_ext_person.g_plip_attr_4
                  ,ben_ext_person.g_plip_attr_5
                  ,ben_ext_person.g_plip_attr_6
                  ,ben_ext_person.g_plip_attr_7
                  ,ben_ext_person.g_plip_attr_8
                  ,ben_ext_person.g_plip_attr_9
                  ,ben_ext_person.g_plip_attr_10
                  ;
            close c_plip_enrt ;

         end if ;

         if dpnt_enrt.oipl_id is not null then

            open c_oipl_enrt(dpnt_enrt.oipl_id) ;
            fetch c_oipl_enrt into
                   ben_ext_person.g_enrt_opt_id
                  ,ben_ext_person.g_enrt_opt_name
                  ,ben_ext_person.g_oipl_attr_1
                  ,ben_ext_person.g_oipl_attr_2
                  ,ben_ext_person.g_oipl_attr_3
                  ,ben_ext_person.g_oipl_attr_4
                  ,ben_ext_person.g_oipl_attr_5
                  ,ben_ext_person.g_oipl_attr_6
                  ,ben_ext_person.g_oipl_attr_7
                  ,ben_ext_person.g_oipl_attr_8
                  ,ben_ext_person.g_oipl_attr_9
                  ,ben_ext_person.g_oipl_attr_10
                  ;
            close c_oipl_enrt  ;
         end if ;
         --


       -- retrieve additional enrollment information
          --
          -- retrieve policy or group number if required
          if ben_extract.g_pgn_csr = 'Y' then

             open  c_prtt_asg ;
             fetch c_prtt_asg into  l_prtt_asg_id ;
             close c_prtt_asg ;

            open plcy_c(dpnt_enrt.pl_id , nvl(ben_ext_person.g_assignment_id,l_prtt_asg_id));
            fetch plcy_c into ben_ext_person.g_enrt_plcy_r_grp;
            close plcy_c;
          end if;
          --
          -- retrieve primary care provider info if required
          --
          if ben_extract.g_ppcp_csr = 'Y' then
            open c_dpnt_prmry_care_prvdr(dpnt_enrt.elig_cvrd_dpnt_id);
            fetch c_dpnt_prmry_care_prvdr into ben_ext_person.g_ppr_name
                                            ,ben_ext_person.g_ppr_ident
                                            ,ben_ext_person.g_ppr_typ
                                            ,ben_ext_person.g_ppr_strt_dt
                                            ,ben_ext_person.g_ppr_end_dt;
            close c_dpnt_prmry_care_prvdr;
          end if;
          --
          --
         IF ben_extract.g_enrt_lvl = 'Y' THEN
            --
            -- format and write enrollment
            -- ===========================
            --
            ben_ext_fmt.process_ext_recs(p_ext_rslt_id       => p_ext_rslt_id,
                                         p_ext_file_id       => p_ext_file_id,
                                         p_data_typ_cd       => p_data_typ_cd,
                                         p_ext_typ_cd        => p_ext_typ_cd,
                                         p_rcd_typ_cd        => 'D',
                                         p_low_lvl_cd        => 'E',
                                         p_person_id         => p_dpnt_person_id,
                                         p_chg_evt_cd        => p_chg_evt_cd,
                                         p_business_group_id => p_business_group_id,
                                         p_effective_date    => p_effective_date
                                         );
            --
          END IF;
          --
     END IF;  -- l_include = 'Y'
     --
   END LOOP;
   --
   hr_utility.set_location('Exiting'||l_proc, 15);

 END; -- main

 --
END;  -- package

/
