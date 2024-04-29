--------------------------------------------------------
--  DDL for Package BEN_EXT_INCL_CHG_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_EXT_INCL_CHG_BK2" AUTHID CURRENT_USER as
/* $Header: bexicapi.pkh 120.1 2005/06/08 13:23:38 tjesumic noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_EXT_INCL_CHG_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_EXT_INCL_CHG_b
  (
   p_ext_incl_chg_id                in  number
  ,p_chg_evt_cd                     in  varchar2
  , p_chg_evt_source                in  varchar2
  ,p_ext_rcd_in_file_id             in  number
  ,p_ext_data_elmt_in_rcd_id        in  number
  ,p_business_group_id              in  number
  ,p_legislation_code               in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_EXT_INCL_CHG_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_EXT_INCL_CHG_a
  (
   p_ext_incl_chg_id                in  number
  ,p_chg_evt_cd                     in  varchar2
  ,p_chg_evt_source                 in  varchar2
  ,p_ext_rcd_in_file_id             in  number
  ,p_ext_data_elmt_in_rcd_id        in  number
  ,p_business_group_id              in  number
  ,p_legislation_code               in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
end ben_EXT_INCL_CHG_bk2;

 

/
