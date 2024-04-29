--------------------------------------------------------
--  DDL for Package BEN_XCL_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_XCL_RKD" AUTHID CURRENT_USER as
/* $Header: bexclrhi.pkh 120.0 2005/05/28 12:24:24 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_ext_chg_evt_log_id             in number
 ,p_chg_evt_cd_o                   in varchar2
 ,p_chg_eff_dt_o                   in date
 ,p_chg_user_id_o                  in number
 ,p_prmtr_01_o                     in varchar2
 ,p_prmtr_02_o                     in varchar2
 ,p_prmtr_03_o                     in varchar2
 ,p_prmtr_04_o                     in varchar2
 ,p_prmtr_05_o                     in varchar2
 ,p_prmtr_06_o                     in varchar2
 ,p_prmtr_07_o                     in varchar2
 ,p_prmtr_08_o                     in varchar2
 ,p_prmtr_09_o                     in varchar2
 ,p_prmtr_10_o                     in varchar2
 ,p_person_id_o                    in number
 ,p_business_group_id_o            in number
 ,p_object_version_number_o        in number
  );
--
end ben_xcl_rkd;

 

/
