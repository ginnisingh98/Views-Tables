--------------------------------------------------------
--  DDL for Package BEN_BATCH_RATE_INFO_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_BATCH_RATE_INFO_BK3" AUTHID CURRENT_USER as
/* $Header: bebriapi.pkh 120.0 2005/05/28 00:51:31 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_batch_rate_info_b >-------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_batch_rate_info_b
  (p_batch_rt_id                    in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date);
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_batch_rate_info_a >-------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_batch_rate_info_a
  (p_batch_rt_id                    in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date);
--
end ben_batch_rate_info_bk3;

 

/
