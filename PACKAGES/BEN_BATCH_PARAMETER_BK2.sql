--------------------------------------------------------
--  DDL for Package BEN_BATCH_PARAMETER_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_BATCH_PARAMETER_BK2" AUTHID CURRENT_USER as
/* $Header: bebbpapi.pkh 120.0 2005/05/28 00:33:50 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_batch_parameter_b >-------------------|
-- ----------------------------------------------------------------------------
--
procedure update_batch_parameter_b
  (p_batch_parameter_id             in  number
  ,p_batch_exe_cd                   in  varchar2
  ,p_thread_cnt_num                 in  number
  ,p_max_err_num                    in  number
  ,p_chunk_size                     in  number
  ,p_business_group_id              in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date);
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_batch_parameter_a >-------------------|
-- ----------------------------------------------------------------------------
--
procedure update_batch_parameter_a
  (p_batch_parameter_id             in  number
  ,p_batch_exe_cd                   in  varchar2
  ,p_thread_cnt_num                 in  number
  ,p_max_err_num                    in  number
  ,p_chunk_size                     in  number
  ,p_business_group_id              in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date);
--
end ben_batch_parameter_bk2;

 

/
