--------------------------------------------------------
--  DDL for Package BEN_EXT_CRIT_CMBN_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_EXT_CRIT_CMBN_BK1" AUTHID CURRENT_USER as
/* $Header: bexccapi.pkh 120.0 2005/05/28 12:22:39 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_EXT_CRIT_CMBN_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_EXT_CRIT_CMBN_b
  (
   p_crit_typ_cd                    in  varchar2
  ,p_oper_cd                        in  varchar2
  ,p_val_1                          in  varchar2
  ,p_val_2                          in  varchar2
  ,p_ext_crit_val_id                in  number
  ,p_business_group_id              in  number
  ,p_legislation_code               in  varchar2
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_EXT_CRIT_CMBN_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_EXT_CRIT_CMBN_a
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
end ben_EXT_CRIT_CMBN_bk1;

 

/
