--------------------------------------------------------
--  DDL for Package BEN_BMI_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_BMI_RKU" AUTHID CURRENT_USER as
/* $Header: bebmirhi.pkh 120.0 2005/05/28 00:43:18 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (
  p_batch_commu_id                 in number
 ,p_benefit_action_id              in number
 ,p_person_id                      in number
 ,p_per_cm_id                      in number
 ,p_cm_typ_id                      in number
 ,p_business_group_id              in number
 ,p_per_cm_prvdd_id                in number
 ,p_to_be_sent_dt                  in date
 ,p_object_version_number          in number
 ,p_benefit_action_id_o            in number
 ,p_person_id_o                    in number
 ,p_per_cm_id_o                    in number
 ,p_cm_typ_id_o                    in number
 ,p_business_group_id_o            in number
 ,p_per_cm_prvdd_id_o              in number
 ,p_to_be_sent_dt_o                in date
 ,p_object_version_number_o        in number
  );
--
end ben_bmi_rku;

 

/
