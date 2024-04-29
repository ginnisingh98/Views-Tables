--------------------------------------------------------
--  DDL for Package BEN_AUTOMATIC_ENROLLMENTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_AUTOMATIC_ENROLLMENTS" AUTHID CURRENT_USER as
/* $Header: benauten.pkh 120.0.12000000.1 2007/01/19 14:59:22 appldev noship $ */
  --
  procedure main(p_person_id         in number,
                 p_ler_id            in number,
                 p_business_group_id in number,
                 p_mode              in varchar2,
                 p_effective_date    in date);
  --
  procedure reinstate_dpnt(p_pgm_id                 in number,
                           p_pl_id                  in number,
                           p_oipl_id                in number,
                           p_business_group_id      in number,
                           p_person_id              in number,
                           p_per_in_ler_id          in number,
                           p_elig_per_elctbl_chc_id in number,
                           p_dpnt_cvg_strt_dt_cd    in varchar2,
                           p_dpnt_cvg_strt_dt_rl    in number,
                           p_enrt_cvg_strt_dt       in date,
                           p_effective_date         in date,
                           p_prev_prtt_enrt_rslt_id in number default null
                           );
end ben_automatic_enrollments;
--

 

/
