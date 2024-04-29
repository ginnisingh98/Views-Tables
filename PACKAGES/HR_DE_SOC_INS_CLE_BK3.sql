--------------------------------------------------------
--  DDL for Package HR_DE_SOC_INS_CLE_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_DE_SOC_INS_CLE_BK3" AUTHID CURRENT_USER as
/* $Header: hrcleapi.pkh 120.1 2005/10/02 02:00:02 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------< delete_soc_ins_contributions_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_soc_ins_contributions_b
  (
   p_soc_ins_contr_lvls_id          in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------< delete_soc_ins_contributions_a>-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_soc_ins_contributions_a
  (
   p_soc_ins_contr_lvls_id          in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in varchar2
  );
--
end hr_de_soc_ins_cle_bk3;

 

/
