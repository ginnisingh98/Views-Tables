--------------------------------------------------------
--  DDL for Package BEN_ESW_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ESW_RKU" AUTHID CURRENT_USER as
/* $Header: beeswrhi.pkh 120.1 2005/06/17 09:38 abparekh noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_effective_date               in date
  ,p_datetrack_mode               in varchar2
  ,p_validation_start_date        in date
  ,p_validation_end_date          in date
  ,p_elig_scre_wtg_id             in number
  ,p_elig_per_id                  in number
  ,p_elig_per_opt_id              in number
  ,p_elig_rslt_id                 in number
  ,p_per_in_ler_id                in number
  ,p_effective_start_date         in date
  ,p_effective_end_date           in date
  ,p_object_version_number        in number
  ,p_eligy_prfl_id                in number
  ,p_crit_tab_short_name          in varchar2
  ,p_crit_tab_pk_id               in number
  ,p_computed_score               in number
  ,p_benefit_action_id            in number
  ,p_elig_per_id_o                in number
  ,p_elig_per_opt_id_o            in number
  ,p_elig_rslt_id_o               in number
  ,p_per_in_ler_id_o              in number
  ,p_effective_start_date_o       in date
  ,p_effective_end_date_o         in date
  ,p_object_version_number_o      in number
  ,p_eligy_prfl_id_o              in number
  ,p_crit_tab_short_name_o        in varchar2
  ,p_crit_tab_pk_id_o             in number
  ,p_computed_score_o             in number
  ,p_benefit_action_id_o          in number
  );
--
end ben_esw_rku;

 

/
