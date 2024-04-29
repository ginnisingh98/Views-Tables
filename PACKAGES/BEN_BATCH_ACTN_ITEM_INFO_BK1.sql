--------------------------------------------------------
--  DDL for Package BEN_BATCH_ACTN_ITEM_INFO_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_BATCH_ACTN_ITEM_INFO_BK1" AUTHID CURRENT_USER as
/* $Header: bebaiapi.pkh 120.0 2005/05/28 00:32:59 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_batch_actn_item_info_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_batch_actn_item_info_b
  (
   p_benefit_action_id              in  number
  ,p_person_id                      in  number
  ,p_actn_typ_id                    in  number
  ,p_cmpltd_dt                      in  date
  ,p_due_dt                         in  date
  ,p_rqd_flag                       in  varchar2
  ,p_actn_cd                        in  varchar2
  ,p_business_group_id              in  number
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_batch_actn_item_info_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_batch_actn_item_info_a
  (
   p_batch_actn_item_id             in  number
  ,p_benefit_action_id              in  number
  ,p_person_id                      in  number
  ,p_actn_typ_id                    in  number
  ,p_cmpltd_dt                      in  date
  ,p_due_dt                         in  date
  ,p_rqd_flag                       in  varchar2
  ,p_actn_cd                        in  varchar2
  ,p_business_group_id              in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
end ben_batch_actn_item_info_bk1;

 

/
