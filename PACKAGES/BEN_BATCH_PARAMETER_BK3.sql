--------------------------------------------------------
--  DDL for Package BEN_BATCH_PARAMETER_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_BATCH_PARAMETER_BK3" AUTHID CURRENT_USER as
/* $Header: bebbpapi.pkh 120.0 2005/05/28 00:33:50 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_batch_parameter_b >-------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_batch_parameter_b
  (p_batch_parameter_id             in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date);
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_batch_parameter_a >-------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_batch_parameter_a
  (p_batch_parameter_id             in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date);
--
end ben_batch_parameter_bk3;

 

/
