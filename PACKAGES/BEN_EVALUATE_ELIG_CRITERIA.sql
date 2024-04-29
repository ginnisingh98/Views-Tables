--------------------------------------------------------
--  DDL for Package BEN_EVALUATE_ELIG_CRITERIA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_EVALUATE_ELIG_CRITERIA" AUTHID CURRENT_USER as
/* $Header: benelgcr.pkh 120.0 2005/05/28 08:55:58 appldev noship $ */


procedure main(p_eligy_prfl_id        in number,
               p_person_id            in number,
               p_assignment_id        in number,
               p_business_group_id    in number,
               p_pgm_id               in number default null,
               p_pl_id                in number default null,
               p_opt_id               in number default null,
               p_oipl_id              in number default null,
               p_ler_id               in number default null,
               p_pl_typ_id            in number default null,
               p_effective_date       in date,
               p_fonm_cvg_strt_date   in date default null,
               p_fonm_rt_strt_date    in date default null,
               p_crit_ovrrd_val_tbl   in pqh_popl_criteria_ovrrd.g_crit_ovrrd_val_tbl
              )  ;


end ben_evaluate_elig_criteria;

 

/
