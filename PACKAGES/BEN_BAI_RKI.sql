--------------------------------------------------------
--  DDL for Package BEN_BAI_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_BAI_RKI" AUTHID CURRENT_USER as
/* $Header: bebairhi.pkh 120.0 2005/05/28 00:33:18 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (
  p_batch_actn_item_id             in number
 ,p_benefit_action_id              in number
 ,p_person_id                      in number
 ,p_actn_typ_id                    in number
 ,p_cmpltd_dt                      in date
 ,p_due_dt                         in date
 ,p_rqd_flag                       in varchar2
 ,p_actn_cd                        in varchar2
 ,p_business_group_id              in number
 ,p_object_version_number          in number
 ,p_effective_date                 in date
  );
end ben_bai_rki;

 

/
