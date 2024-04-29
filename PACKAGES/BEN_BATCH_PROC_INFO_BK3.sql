--------------------------------------------------------
--  DDL for Package BEN_BATCH_PROC_INFO_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_BATCH_PROC_INFO_BK3" AUTHID CURRENT_USER as
/* $Header: bebpiapi.pkh 120.0 2005/05/28 00:46:35 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_batch_proc_info_b >-------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_batch_proc_info_b
  (p_batch_proc_id                  in  number
  ,p_object_version_number          in  number);
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_batch_proc_info_a >-------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_batch_proc_info_a
  (p_batch_proc_id                  in  number
  ,p_object_version_number          in  number);
--
end ben_batch_proc_info_bk3;

 

/
