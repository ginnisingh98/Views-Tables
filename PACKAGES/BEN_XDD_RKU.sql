--------------------------------------------------------
--  DDL for Package BEN_XDD_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_XDD_RKU" AUTHID CURRENT_USER as
/* $Header: bexddrhi.pkh 120.1 2005/06/08 13:09:34 tjesumic noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (
  p_ext_data_elmt_decd_id          in number
 ,p_val                            in varchar2
 ,p_dcd_val                        in varchar2
 ,p_chg_evt_source                 in varchar2
 ,p_ext_data_elmt_id               in number
 ,p_business_group_id              in number
 ,p_legislation_code               in varchar2
 ,p_object_version_number          in number
 ,p_val_o                          in varchar2
 ,p_dcd_val_o                      in varchar2
 ,p_chg_evt_source_o               in varchar2
 ,p_ext_data_elmt_id_o             in number
 ,p_business_group_id_o            in number
 ,p_legislation_code_o             in varchar2
 ,p_object_version_number_o        in number
  );
--
end ben_xdd_rku;

 

/
