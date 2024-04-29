--------------------------------------------------------
--  DDL for Package BEN_BEI_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_BEI_RKI" AUTHID CURRENT_USER as
/* $Header: bebeirhi.pkh 120.0 2005/05/28 00:38:14 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (
  p_batch_elig_id                  in number
 ,p_benefit_action_id              in number
 ,p_person_id                      in number
 ,p_pgm_id                         in number
 ,p_pl_id                          in number
 ,p_oipl_id                        in number
 ,p_elig_flag                      in varchar2
 ,p_inelig_text                    in varchar2
 ,p_business_group_id              in number
 ,p_object_version_number          in number
 ,p_effective_date                 in date
  );
end ben_bei_rki;

 

/
