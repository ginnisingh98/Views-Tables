--------------------------------------------------------
--  DDL for Package BEN_BEI_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_BEI_RKD" AUTHID CURRENT_USER as
/* $Header: bebeirhi.pkh 120.0 2005/05/28 00:38:14 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_batch_elig_id                  in number
 ,p_benefit_action_id_o            in number
 ,p_person_id_o                    in number
 ,p_pgm_id_o                       in number
 ,p_pl_id_o                        in number
 ,p_oipl_id_o                      in number
 ,p_elig_flag_o                    in varchar2
 ,p_inelig_text_o                  in varchar2
 ,p_business_group_id_o            in number
 ,p_object_version_number_o        in number
  );
--
end ben_bei_rkd;

 

/
