--------------------------------------------------------
--  DDL for Package BEN_BATCH_ACTN_ITEM_INFO_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_BATCH_ACTN_ITEM_INFO_BK3" AUTHID CURRENT_USER as
/* $Header: bebaiapi.pkh 120.0 2005/05/28 00:32:59 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_batch_actn_item_info_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_batch_actn_item_info_b
  (
   p_batch_actn_item_id             in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_batch_actn_item_info_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_batch_actn_item_info_a
  (
   p_batch_actn_item_id             in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
end ben_batch_actn_item_info_bk3;

 

/
