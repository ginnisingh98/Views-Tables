--------------------------------------------------------
--  DDL for Package BEN_EXT_RSLT_DTL_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_EXT_RSLT_DTL_BK3" AUTHID CURRENT_USER as
/* $Header: bexrdapi.pkh 120.0 2005/05/28 12:38:48 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_EXT_RSLT_DTL_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_EXT_RSLT_DTL_b
  (
   p_ext_rslt_dtl_id                in  number
  ,p_object_version_number          in  number
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_EXT_RSLT_DTL_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_EXT_RSLT_DTL_a
  (
   p_ext_rslt_dtl_id                in  number
  ,p_object_version_number          in  number
  );
--
end ben_EXT_RSLT_DTL_bk3;

 

/
