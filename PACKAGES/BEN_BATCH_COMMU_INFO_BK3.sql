--------------------------------------------------------
--  DDL for Package BEN_BATCH_COMMU_INFO_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_BATCH_COMMU_INFO_BK3" AUTHID CURRENT_USER as
/* $Header: bebmiapi.pkh 120.0 2005/05/28 00:43:00 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_batch_commu_info_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_batch_commu_info_b
  (
   p_batch_commu_id                 in  number
  ,p_object_version_number          in  number
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_batch_commu_info_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_batch_commu_info_a
  (
   p_batch_commu_id                 in  number
  ,p_object_version_number          in  number
  );
--
end ben_batch_commu_info_bk3;

 

/
