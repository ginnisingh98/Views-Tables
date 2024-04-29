--------------------------------------------------------
--  DDL for Package BEN_BATCH_DPNT_INFO_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_BATCH_DPNT_INFO_BK3" AUTHID CURRENT_USER as
/* $Header: bebdiapi.pkh 120.0 2005/05/28 00:36:33 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_batch_dpnt_info_b >-------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_batch_dpnt_info_b
  (p_batch_dpnt_id                  in  number
  ,p_object_version_number          in  varchar2
  ,p_effective_date                 in  date);
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_batch_dpnt_info_a >-------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_batch_dpnt_info_a
  (p_batch_dpnt_id                  in  number
  ,p_object_version_number          in  varchar2
  ,p_effective_date                 in  date);
--
end ben_batch_dpnt_info_bk3;

 

/
