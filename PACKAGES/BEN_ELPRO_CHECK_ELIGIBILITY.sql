--------------------------------------------------------
--  DDL for Package BEN_ELPRO_CHECK_ELIGIBILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ELPRO_CHECK_ELIGIBILITY" AUTHID CURRENT_USER AS
/* $Header: bendtlep.pkh 120.0.12010000.1 2008/07/29 12:18:12 appldev ship $ */
--
procedure check_elig_othr_ptip_prte
  (p_eligy_prfl_id     in number
  ,p_business_group_id in number
  ,p_effective_date    in date
  ,p_lf_evt_ocrd_dt    in date
  ,p_person_id         in number
  --
  ,p_per_in_ler_id     in number default null
  );
--
procedure check_elig_dpnt_othr_ptip
  (p_eligy_prfl_id     in number
  ,p_business_group_id in number
  ,p_effective_date    in date
  ,p_lf_evt_ocrd_dt    in date
  ,p_person_id         in number
  --
  ,p_per_in_ler_id     in number
  );
--
END ben_elpro_check_eligibility;

/
