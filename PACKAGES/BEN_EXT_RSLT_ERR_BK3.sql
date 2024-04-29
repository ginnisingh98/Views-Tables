--------------------------------------------------------
--  DDL for Package BEN_EXT_RSLT_ERR_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_EXT_RSLT_ERR_BK3" AUTHID CURRENT_USER as
/* $Header: bexreapi.pkh 120.0 2005/05/28 12:39:53 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_EXT_RSLT_ERR_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_EXT_RSLT_ERR_b
  (
   p_ext_rslt_err_id                in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_EXT_RSLT_ERR_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_EXT_RSLT_ERR_a
  (
   p_ext_rslt_err_id                in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
end ben_EXT_RSLT_ERR_bk3;

 

/
