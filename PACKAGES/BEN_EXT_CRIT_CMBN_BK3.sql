--------------------------------------------------------
--  DDL for Package BEN_EXT_CRIT_CMBN_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_EXT_CRIT_CMBN_BK3" AUTHID CURRENT_USER as
/* $Header: bexccapi.pkh 120.0 2005/05/28 12:22:39 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_EXT_CRIT_CMBN_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_EXT_CRIT_CMBN_b
  (
   p_ext_crit_cmbn_id               in  number
  ,p_legislation_code               in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_EXT_CRIT_CMBN_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_EXT_CRIT_CMBN_a
  (
   p_ext_crit_cmbn_id               in  number
  ,p_legislation_code               in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
end ben_EXT_CRIT_CMBN_bk3;

 

/
