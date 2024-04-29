--------------------------------------------------------
--  DDL for Package BEN_XCV_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_XCV_RKD" AUTHID CURRENT_USER as
/* $Header: bexcvrhi.pkh 120.0 2005/05/28 12:28:09 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_ext_crit_val_id                in number
 ,p_val_1_o                        in varchar2
 ,p_val_2_o                        in varchar2
 ,p_ext_crit_typ_id_o              in number
 ,p_business_group_id_o            in number
 ,p_ext_crit_bg_id_o               in number
 ,p_legislation_code_o             in varchar2
 ,p_object_version_number_o        in number
  );
--
end ben_xcv_rkd;

 

/
