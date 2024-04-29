--------------------------------------------------------
--  DDL for Package BEN_EXT_CHG_EVT_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_EXT_CHG_EVT_BK2" AUTHID CURRENT_USER as
/* $Header: bexclapi.pkh 120.1 2005/06/23 15:04:14 tjesumic noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_EXT_CHG_EVT_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_EXT_CHG_EVT_b
  (
   p_ext_chg_evt_log_id             in  number
  ,p_chg_evt_cd                     in  varchar2
  ,p_chg_eff_dt                     in  date
  ,p_chg_user_id                    in  number
  ,p_prmtr_01                       in  varchar2
  ,p_prmtr_02                       in  varchar2
  ,p_prmtr_03                       in  varchar2
  ,p_prmtr_04                       in  varchar2
  ,p_prmtr_05                       in  varchar2
  ,p_prmtr_06                       in  varchar2
  ,p_prmtr_07                       in  varchar2
  ,p_prmtr_08                       in  varchar2
  ,p_prmtr_09                       in  varchar2
  ,p_prmtr_10                       in  varchar2
  ,p_person_id                      in  number
  ,p_business_group_id              in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_EXT_CHG_EVT_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_EXT_CHG_EVT_a
  (
   p_ext_chg_evt_log_id             in  number
  ,p_chg_evt_cd                     in  varchar2
  ,p_chg_eff_dt                     in  date
  ,p_chg_user_id                    in  number
  ,p_prmtr_01                       in  varchar2
  ,p_prmtr_02                       in  varchar2
  ,p_prmtr_03                       in  varchar2
  ,p_prmtr_04                       in  varchar2
  ,p_prmtr_05                       in  varchar2
  ,p_prmtr_06                       in  varchar2
  ,p_prmtr_07                       in  varchar2
  ,p_prmtr_08                       in  varchar2
  ,p_prmtr_09                       in  varchar2
  ,p_prmtr_10                       in  varchar2
  ,p_person_id                      in  number
  ,p_business_group_id              in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
end ben_EXT_CHG_EVT_bk2;

 

/
