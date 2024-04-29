--------------------------------------------------------
--  DDL for Package BEN_XIC_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_XIC_RKD" AUTHID CURRENT_USER as
/* $Header: bexicrhi.pkh 120.2 2005/06/08 15:56:05 tjesumic noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_ext_incl_chg_id                in number
 ,p_chg_evt_cd_o                   in varchar2
 ,p_chg_evt_source_o               in varchar2
 ,p_ext_rcd_in_file_id_o           in number
 ,p_ext_data_elmt_in_rcd_id_o      in number
 ,p_business_group_id_o            in number
 ,p_legislation_code_o             in varchar2
 ,p_object_version_number_o        in number
  );
--
end ben_xic_rkd;

 

/
