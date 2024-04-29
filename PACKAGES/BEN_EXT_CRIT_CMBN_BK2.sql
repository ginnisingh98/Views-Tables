--------------------------------------------------------
--  DDL for Package BEN_EXT_CRIT_CMBN_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_EXT_CRIT_CMBN_BK2" AUTHID CURRENT_USER as
/* $Header: bexccapi.pkh 120.0 2005/05/28 12:22:39 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_EXT_CRIT_CMBN_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_EXT_CRIT_CMBN_b
  (
   p_ext_crit_cmbn_id               in  number
  ,p_crit_typ_cd                    in  varchar2
  ,p_oper_cd                        in  varchar2
  ,p_val_1                          in  varchar2
  ,p_val_2                          in  varchar2
  ,p_ext_crit_val_id                in  number
  ,p_business_group_id              in  number
  ,p_legislation_code               in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_EXT_CRIT_CMBN_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_EXT_CRIT_CMBN_a
  (
   p_ext_crit_cmbn_id               in  number
  ,p_crit_typ_cd                    in  varchar2
  ,p_oper_cd                        in  varchar2
  ,p_val_1                          in  varchar2
  ,p_val_2                          in  varchar2
  ,p_ext_crit_val_id                in  number
  ,p_business_group_id              in  number
  ,p_legislation_code               in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
end ben_EXT_CRIT_CMBN_bk2;

 

/
