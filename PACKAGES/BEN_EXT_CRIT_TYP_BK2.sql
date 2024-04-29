--------------------------------------------------------
--  DDL for Package BEN_EXT_CRIT_TYP_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_EXT_CRIT_TYP_BK2" AUTHID CURRENT_USER as
/* $Header: bexctapi.pkh 120.0 2005/05/28 12:26:26 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_EXT_CRIT_TYP_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_EXT_CRIT_TYP_b
  (
   p_ext_crit_typ_id                in  number
  ,p_crit_typ_cd                    in  varchar2
  ,p_ext_crit_prfl_id               in  number
  ,p_business_group_id              in  number
  ,p_legislation_code               in   varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_excld_flag                     in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_EXT_CRIT_TYP_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_EXT_CRIT_TYP_a
  (
   p_ext_crit_typ_id                in  number
  ,p_crit_typ_cd                    in  varchar2
  ,p_ext_crit_prfl_id               in  number
  ,p_business_group_id              in  number
  ,p_legislation_code               in   varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_excld_flag                     in varchar2
  );
--
end ben_EXT_CRIT_TYP_bk2;

 

/
