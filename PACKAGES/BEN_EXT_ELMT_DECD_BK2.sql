--------------------------------------------------------
--  DDL for Package BEN_EXT_ELMT_DECD_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_EXT_ELMT_DECD_BK2" AUTHID CURRENT_USER as
/* $Header: bexddapi.pkh 120.1 2005/06/08 13:09:11 tjesumic noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_EXT_ELMT_DECD_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_EXT_ELMT_DECD_b
  (
   p_ext_data_elmt_decd_id          in  number
  ,p_val                            in  varchar2
  ,p_dcd_val                        in  varchar2
  ,p_chg_evt_source                 in  varchar2
  ,p_ext_data_elmt_id               in  number
  ,p_business_group_id              in  number
  ,p_legislation_code               in  varchar2
  ,p_object_version_number          in  number
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_EXT_ELMT_DECD_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_EXT_ELMT_DECD_a
  (
   p_ext_data_elmt_decd_id          in  number
  ,p_val                            in  varchar2
  ,p_dcd_val                        in  varchar2
  ,p_chg_evt_source                 in  varchar2
  ,p_ext_data_elmt_id               in  number
  ,p_business_group_id              in  number
  ,p_legislation_code               in  varchar2
  ,p_object_version_number          in  number
  );
--
end ben_EXT_ELMT_DECD_bk2;

 

/