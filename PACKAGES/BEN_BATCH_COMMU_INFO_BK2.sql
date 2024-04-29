--------------------------------------------------------
--  DDL for Package BEN_BATCH_COMMU_INFO_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_BATCH_COMMU_INFO_BK2" AUTHID CURRENT_USER as
/* $Header: bebmiapi.pkh 120.0 2005/05/28 00:43:00 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_batch_commu_info_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_batch_commu_info_b
  (
   p_batch_commu_id                 in  number
  ,p_benefit_action_id              in  number
  ,p_person_id                      in  number
  ,p_per_cm_id                      in  number
  ,p_cm_typ_id                      in  number
  ,p_business_group_id              in  number
  ,p_per_cm_prvdd_id                in  number
  ,p_to_be_sent_dt                  in  date
  ,p_object_version_number          in  number
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_batch_commu_info_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_batch_commu_info_a
  (
   p_batch_commu_id                 in  number
  ,p_benefit_action_id              in  number
  ,p_person_id                      in  number
  ,p_per_cm_id                      in  number
  ,p_cm_typ_id                      in  number
  ,p_business_group_id              in  number
  ,p_per_cm_prvdd_id                in  number
  ,p_to_be_sent_dt                  in  date
  ,p_object_version_number          in  number
  );
--
end ben_batch_commu_info_bk2;

 

/
