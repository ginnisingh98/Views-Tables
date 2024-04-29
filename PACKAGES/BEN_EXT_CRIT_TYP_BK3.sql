--------------------------------------------------------
--  DDL for Package BEN_EXT_CRIT_TYP_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_EXT_CRIT_TYP_BK3" AUTHID CURRENT_USER as
/* $Header: bexctapi.pkh 120.0 2005/05/28 12:26:26 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_EXT_CRIT_TYP_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_EXT_CRIT_TYP_b
  (
   p_ext_crit_typ_id                in  number
  ,p_legislation_code               in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_EXT_CRIT_TYP_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_EXT_CRIT_TYP_a
  (
   p_ext_crit_typ_id                in  number
  ,p_legislation_code               in   varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
end ben_EXT_CRIT_TYP_bk3;

 

/
