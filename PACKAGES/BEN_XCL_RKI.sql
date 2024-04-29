--------------------------------------------------------
--  DDL for Package BEN_XCL_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_XCL_RKI" AUTHID CURRENT_USER as
/* $Header: bexclrhi.pkh 120.0 2005/05/28 12:24:24 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (
  p_ext_chg_evt_log_id             in number
 ,p_chg_evt_cd                     in varchar2
 ,p_chg_eff_dt                     in date
 ,p_chg_user_id                    in number
 ,p_prmtr_01                       in varchar2
 ,p_prmtr_02                       in varchar2
 ,p_prmtr_03                       in varchar2
 ,p_prmtr_04                       in varchar2
 ,p_prmtr_05                       in varchar2
 ,p_prmtr_06                       in varchar2
 ,p_prmtr_07                       in varchar2
 ,p_prmtr_08                       in varchar2
 ,p_prmtr_09                       in varchar2
 ,p_prmtr_10                       in varchar2
 ,p_person_id                      in number
 ,p_business_group_id              in number
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_chg_actl_dt                    in date
 ,p_new_val1                       in varchar2
 ,p_new_val2                       in varchar2
 ,p_new_val3                       in varchar2
 ,p_new_val4                       in varchar2
 ,p_new_val5                       in varchar2
 ,p_new_val6                       in varchar2
 ,p_old_val1                       in varchar2
 ,p_old_val2                       in varchar2
 ,p_old_val3                       in varchar2
 ,p_old_val4                       in varchar2
 ,p_old_val5                       in varchar2
 ,p_old_val6                       in varchar2
  );
end ben_xcl_rki;

 

/
