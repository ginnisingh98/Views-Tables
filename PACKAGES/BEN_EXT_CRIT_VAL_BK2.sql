--------------------------------------------------------
--  DDL for Package BEN_EXT_CRIT_VAL_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_EXT_CRIT_VAL_BK2" AUTHID CURRENT_USER as
/* $Header: bexcvapi.pkh 120.0 2005/05/28 12:27:34 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_EXT_CRIT_VAL_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_EXT_CRIT_VAL_b
  (
   p_ext_crit_val_id                in  number
  ,p_val_1                          in  varchar2
  ,p_val_2                          in  varchar2
  ,p_ext_crit_typ_id                in  number
  ,p_business_group_id              in  number
  ,p_ext_crit_bg_id                 in  number
  ,p_legislation_code               in  varchar2
  ,p_object_version_number          in  number
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_EXT_CRIT_VAL_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_EXT_CRIT_VAL_a
  (
   p_ext_crit_val_id                in  number
  ,p_val_1                          in  varchar2
  ,p_val_2                          in  varchar2
  ,p_ext_crit_typ_id                in  number
  ,p_business_group_id              in  number
  ,p_ext_crit_bg_id                 in  number
  ,p_legislation_code               in  varchar2
  ,p_object_version_number          in  number
  );
--
end ben_EXT_CRIT_VAL_bk2;

 

/
