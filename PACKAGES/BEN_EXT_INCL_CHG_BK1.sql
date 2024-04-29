--------------------------------------------------------
--  DDL for Package BEN_EXT_INCL_CHG_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_EXT_INCL_CHG_BK1" AUTHID CURRENT_USER as
/* $Header: bexicapi.pkh 120.1 2005/06/08 13:23:38 tjesumic noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_EXT_INCL_CHG_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_EXT_INCL_CHG_b
  (
   p_chg_evt_cd                     in  varchar2
  ,p_chg_evt_source              in  varchar2
  ,p_ext_rcd_in_file_id             in  number
  ,p_ext_data_elmt_in_rcd_id        in  number
  ,p_business_group_id              in  number
  ,p_legislation_code               in  varchar2
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_EXT_INCL_CHG_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_EXT_INCL_CHG_a
  (
   p_ext_incl_chg_id                in  number
  ,p_chg_evt_cd                     in  varchar2
  ,p_chg_evt_source              in  varchar2
  ,p_ext_rcd_in_file_id             in  number
  ,p_ext_data_elmt_in_rcd_id        in  number
  ,p_business_group_id              in  number
  ,p_legislation_code               in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
end ben_EXT_INCL_CHG_bk1;

 

/
