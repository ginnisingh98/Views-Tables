--------------------------------------------------------
--  DDL for Package BEN_EVL_DPNT_ELIG_CRITERIA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_EVL_DPNT_ELIG_CRITERIA" AUTHID CURRENT_USER as
/* $Header: bendpcrt.pkh 120.0.12010000.2 2010/04/13 14:59:40 krupani noship $ */


procedure main(p_dpnt_cvg_eligy_prfl_id        in number,
               p_person_id            in number,
               p_business_group_id    in number,
               p_lf_evt_ocrd_dt       in date,
               p_effective_date       in date,
               p_eligible_flag     out nocopy varchar2,
               p_inelig_rsn_cd     out nocopy varchar2
              )  ;

end ben_evl_dpnt_elig_criteria;

/
