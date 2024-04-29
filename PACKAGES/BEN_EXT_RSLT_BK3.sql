--------------------------------------------------------
--  DDL for Package BEN_EXT_RSLT_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_EXT_RSLT_BK3" AUTHID CURRENT_USER as
/* $Header: bexrsapi.pkh 120.1 2005/06/08 14:27:02 tjesumic noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_EXT_RSLT_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_EXT_RSLT_b
  (
   p_ext_rslt_id                    in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_EXT_RSLT_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_EXT_RSLT_a
  (
   p_ext_rslt_id                    in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
end ben_EXT_RSLT_bk3;

 

/
