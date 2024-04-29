--------------------------------------------------------
--  DDL for Package BEN_EXT_CRIT_PRFL_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_EXT_CRIT_PRFL_BK3" AUTHID CURRENT_USER as
/* $Header: bexcrapi.pkh 120.0 2005/05/28 12:25:19 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_EXT_CRIT_PRFL_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_EXT_CRIT_PRFL_b
  (
   p_ext_crit_prfl_id               in  number
  ,p_legislation_code               in  varchar2
  ,p_object_version_number          in  number
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_EXT_CRIT_PRFL_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_EXT_CRIT_PRFL_a
  (
   p_ext_crit_prfl_id               in  number
  ,p_legislation_code               in  varchar2
  ,p_object_version_number          in  number
  );
--
end ben_EXT_CRIT_PRFL_bk3;

 

/
